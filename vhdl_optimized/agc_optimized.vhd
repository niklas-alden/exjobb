----------------------------------------------------------------------------------
-- Engineer: 		Niklas Aldén
-- 
-- Create Date:   	13:51:53 04/21/2015 
-- Design Name: 
-- Module Name:    	agc_optimized - Behavioral 
-- Project Name: 	Hardware implementation of AGC for active hearing protectors
-- Description: 	Master Thesis
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity agc is
    Port ( 	clk 			: in std_logic; 					-- clock
			rstn 			: in std_logic; 					-- reset, active low
			i_sample 		: in std_logic_vector(15 downto 0); -- input sample from AC97
			i_start 		: in std_logic; 					-- start signal from AC97
			i_gain 			: in std_logic_vector(15 downto 0);	-- gain fetched from LUT
			o_power 		: out std_logic_vector(7 downto 0);	-- sample power to LUT
			o_gain_fetch 	: out std_logic;					-- enable signal for LUT
			o_sample 		: out std_logic_vector(15 downto 0)	-- output sample to equalizer filter
			);
end agc;

architecture Behavioral of agc is
	
	constant WIDTH 			: integer 	:= 32;	-- general register width
	signal delay_c, delay_n : std_logic	:= '0';	-- one bit delay counter
	
	-- HIGH PASS FILTER
	-- high pass filter coefficients
	constant hp_b_0 : signed(WIDTH/2-1 downto 0) := to_signed(504, WIDTH/2);
	constant hp_b_1 : signed(WIDTH/2-1 downto 0) := to_signed(-504,WIDTH/2);
	constant hp_a_1 : signed(WIDTH/2-1 downto 0) := to_signed(496, WIDTH/2); -- OBS changed sign
	
	signal hp_x_c, hp_x_n 			: signed(WIDTH/2-1 downto 0) 	:= (others => '0'); -- current input sample
	signal hp_x_prev_c, hp_x_prev_n : signed(WIDTH/2-1 downto 0) 	:= (others => '0'); -- previous input sample
	signal hp_y_prev_c, hp_y_prev_n	: signed(WIDTH/2-1 downto 0) 	:= (others => '0'); -- previous output sample
	
	-- EQUALIZER FILTER
	-- equalizer filter coefficients
	constant eq_b_0 : signed(WIDTH-1 downto 0) := to_signed(55484, WIDTH);
	constant eq_b_1 : signed(WIDTH-1 downto 0) := to_signed(-313, WIDTH);
	constant eq_b_2 : signed(WIDTH-1 downto 0) := to_signed(-55123, WIDTH);
	constant eq_a_1 : signed(WIDTH-1 downto 0) := to_signed(313, WIDTH); 	-- OBS changed sign
	constant eq_a_2 : signed(WIDTH-1 downto 0) := to_signed(151, WIDTH); 	-- OBS changed sign
	
	signal eq_x_c, eq_x_n 						: signed(WIDTH-1 downto 0) 	:= (others => '0'); -- current input sample
	signal eq_x_prev_c, eq_x_prev_n 			: signed(WIDTH-1 downto 0) 	:= (others => '0'); -- previous input sample
	signal eq_x_prev_prev_c, eq_x_prev_prev_n 	: signed(WIDTH-1 downto 0) 	:= (others => '0'); -- before last input sample
	signal eq_y_prev_c, eq_y_prev_n				: signed(WIDTH-1 downto 0) 	:= (others => '0'); -- previous output sample
	signal eq_y_prev_prev_c, eq_y_prev_prev_n	: signed(WIDTH-1 downto 0) 	:= (others => '0'); -- before last output sample
	
	-- AGC
	-- time parameters
	constant alpha 	: unsigned(15 downto 0) := to_unsigned(164, WIDTH/2); -- attack time
	constant beta 	: unsigned(15 downto 0) := to_unsigned(983, WIDTH/2); -- release time
	
	signal curr_sample_c, curr_sample_n : signed(WIDTH/2-1 downto 0) 	:= (others => '0'); -- current input sample
	signal P_in_c, P_in_n 				: unsigned(WIDTH-1 downto 0)	:= (others => '0'); -- power of input sample
	signal P_dB_c, P_dB_n 				: signed(7 downto 0) 			:= (others => '0'); -- weighted power of input sample in decibel
	signal P_prev_c, P_prev_n 			: unsigned(WIDTH-1 downto 0) 	:= (others => '0'); -- power of output sample
	signal agc_out_c, agc_out_n			: signed(WIDTH/2-1 downto 0) 	:= (others => '0'); -- attenuated sample
	
	-- MULTIPLIER AND ADDER
	signal mult_src1_c, mult_src1_n : signed(WIDTH-1 downto 0) 		:= (others => '0');
	signal mult_src2_c, mult_src2_n : signed(WIDTH-1 downto 0) 		:= (others => '0');
	signal mult_out_c, mult_out_n 	: signed(2*WIDTH-1 downto 0) 	:= (others => '0');
	signal add_src1_c, add_src1_n 	: signed(2*WIDTH-1 downto 0) 	:= (others => '0');
	signal add_src2_c, add_src2_n 	: signed(2*WIDTH-1 downto 0) 	:= (others => '0');
	signal add_out_c, add_out_n 	: signed(2*WIDTH-1 downto 0) 	:= (others => '0');
		
	-- states for FSM    
	type state_type is (HOLD, HP_CALC1, HP_CALC2, HP_CALC3, HP_CALC4, 
						EQ_CALC1, EQ_CALC2, EQ_CALC3, EQ_CALC4, EQ_CALC5, EQ_CALC6, FINISH_CALC,
						P_CURR, P_COMP, P_W_1A, P_W_1B, P_W_2A, P_W_2B, P_W_3, P_dB, FETCH_GAIN, GAIN, AGC_SEND, P_OUT); 
	signal state_c, state_n : state_type := HOLD;
	
begin

-- clock process
----------------------------------------------------------------------------------
clk_proc : process(clk, rstn) is
begin
	if rstn = '0' then
		state_c 			<= HOLD;
		hp_x_c 				<= (others => '0');
		hp_x_prev_c 		<= (others => '0');
		hp_y_prev_c			<= (others => '0');
		eq_x_c 				<= (others => '0');
		eq_x_prev_c 		<= (others => '0');
		eq_x_prev_prev_c	<= (others => '0');
		eq_y_prev_c			<= (others => '0');
		eq_y_prev_prev_c 	<= (others => '0');
		P_in_c 				<= (others => '0');
		P_dB_c 				<= (others => '0');
		P_prev_c 			<= (others => '0');
		agc_out_c 			<= (others => '0');
		curr_sample_c 		<= (others => '0');
		mult_src1_c 		<= (others => '0');
		mult_src2_c			<= (others => '0');
		mult_out_c			<= (others => '0');
		add_src1_c			<= (others => '0');
		add_src2_c			<= (others => '0');
		add_out_c			<= (others => '0');
		delay_c				<= '0';
	elsif rising_edge(clk) then
		state_c 			<= state_n;
		hp_x_c 				<= hp_x_n;
		hp_x_prev_c 		<= hp_x_prev_n;
		hp_y_prev_c 		<= hp_y_prev_n;
		eq_x_c 				<= eq_x_n;
		eq_x_prev_c 		<= eq_x_prev_n;
		eq_x_prev_prev_c 	<= eq_x_prev_prev_n;
		eq_y_prev_c 		<= eq_y_prev_n;
		eq_y_prev_prev_c 	<= eq_y_prev_prev_n;
		P_in_c 				<= P_in_n;
		P_dB_c 				<= P_dB_n;
		P_prev_c 			<= P_prev_n;
		agc_out_c 			<= agc_out_n;
		curr_sample_c 		<= curr_sample_n;
		mult_src1_c 		<= mult_src1_n;
		mult_src2_c			<= mult_src2_n;
		mult_out_c			<= mult_out_n;
		add_src1_c			<= add_src1_n;
		add_src2_c			<= add_src2_n;
		add_out_c			<= add_out_n;
		delay_c				<= delay_n;
	end if;
end process;

fsm_proc : process(	state_c, i_start, i_sample, hp_x_c, hp_x_prev_c, hp_y_prev_c, eq_x_c, eq_x_prev_c, eq_x_prev_prev_c,
					eq_y_prev_c, eq_y_prev_prev_c, curr_sample_c, P_in_c, P_dB_c, i_gain, P_prev_c, agc_out_c,
					mult_src1_c, mult_src2_c, mult_out_c, add_src1_c, add_src2_c, add_out_c, delay_c) is
begin
	-- default values
	state_n				<= state_c;
	hp_x_n 				<= hp_x_c;
	hp_x_prev_n 		<= hp_x_prev_c;
	hp_y_prev_n 		<= hp_y_prev_c;
	eq_x_n				<= eq_x_c;
	eq_x_prev_n 		<= eq_x_prev_c;
	eq_x_prev_prev_n 	<= eq_x_prev_prev_c;
	eq_y_prev_n 		<= eq_y_prev_c;
	eq_y_prev_prev_n 	<= eq_y_prev_prev_c;
	P_in_n 				<= P_in_c;
	P_dB_n 				<= P_dB_c;
	curr_sample_n 		<= curr_sample_c;
	P_prev_n 			<= P_prev_c;
	agc_out_n 			<= agc_out_c;
	mult_src1_n 		<= mult_src1_c;
	mult_src2_n 		<= mult_src2_c;
	mult_out_n			<= mult_out_c;
	add_src1_n 			<= add_src1_c;
	add_src2_n 			<= add_src2_c;
	add_out_n			<= add_out_c;
	delay_n				<= delay_c;
	o_sample 			<= std_logic_vector(agc_out_c); -- output sample
	o_power 			<= std_logic_vector(P_dB_n); 	-- output power to LUT
	o_gain_fetch 		<= '0'; 						-- don't enable LUT

	
	case state_c is
----------------------------------------------------------------------------------	
-- HIGH PASS FILTER
----------------------------------------------------------------------------------	
		-- wait for start signal before latching input sample
		when HOLD =>
			if i_start = '1' then
				hp_x_n	<= signed(i_sample);
				state_n	<= HP_CALC1;
			end if;

		-- multiply current input sample with filter coefficient
		when HP_CALC1 =>
			mult_src1_n <= resize(hp_x_c, WIDTH);
			mult_src2_n <= resize(hp_b_0, WIDTH);
			add_src1_n 	<= (others => '0');
			add_src2_n 	<= (others => '0');
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n	<= HP_CALC1;
			else
				delay_n <= '0';
				state_n	<= HP_CALC2;
			end if;
		
		-- multiply previous input sample with filter coefficient
		when HP_CALC2 =>
			mult_src1_n <= resize(hp_x_prev_c, WIDTH);
			mult_src2_n <= resize(hp_b_1, WIDTH);
			add_src1_n 	<= mult_out_c;
			add_src2_n 	<= (others => '0');
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n <= HP_CALC2;
			else
				delay_n <= '0';	
				state_n <= HP_CALC3;
			end if;
		
		-- multiply previous output sample with filter coefficient
		when HP_CALC3 =>
			mult_src1_n <= resize(hp_y_prev_c, WIDTH);
			mult_src2_n <= resize(hp_a_1, WIDTH);
			add_src1_n 	<= mult_out_c;
			add_src2_n 	<= add_out_c;
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n <= HP_CALC3;
			else
				delay_n <= '0';
				state_n <= HP_CALC4;
			end if;
		
		-- sum up to get output sample from high pass filter
		when HP_CALC4 =>
			mult_src1_n <= (others => '0');
			mult_src2_n <= (others => '0');
			add_src1_n 	<= mult_out_c;
			add_src2_n 	<= add_out_c;
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n <= HP_CALC4;
			else
				delay_n <= '0';
				state_n <= EQ_CALC1;
			end if;

----------------------------------------------------------------------------------
-- EQUALIZER FILTER
----------------------------------------------------------------------------------
		-- save input and output sample as previous samples for high pass filter
		-- multiply current input sample with filter coefficient
		when EQ_CALC1 =>
			hp_x_prev_n <= hp_x_c;
			hp_y_prev_n <= add_out_c(24 downto 9);
			eq_x_n		<= resize(add_out_c(WIDTH-1 downto 9), WIDTH);
			mult_src1_n <= resize(add_out_c(WIDTH-1 downto 9), WIDTH);
			mult_src2_n <= eq_b_0;
			add_src1_n 	<= (others => '0');
			add_src2_n 	<= (others => '0');
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n <= EQ_CALC1;
			else
				delay_n <= '0';
				state_n <= EQ_CALC2;
			end if;
		
		-- multiply previous input sample with filter coefficient
		when EQ_CALC2 =>
			mult_src1_n <= eq_x_prev_c;
			mult_src2_n <= eq_b_1;
			add_src1_n 	<= mult_out_c;
			add_src2_n 	<= (others => '0');
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n <= EQ_CALC2;
			else
				delay_n <= '0';
				state_n	<= Eq_CALC3;
			end if;
		
		-- multiply before last input sample with filter coefficient
		when EQ_CALC3 =>
			mult_src1_n <= eq_x_prev_prev_c;
			mult_src2_n <= eq_b_2;
			add_src1_n 	<= add_out_c;
			add_src2_n 	<= mult_out_c;
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n <= EQ_CALC3;
			else
				delay_n <= '0';
				state_n	<= EQ_CALC4;
			end if;
		
		-- multiply previous output sample with filter coefficient
		when EQ_CALC4 =>
			mult_src1_n <= eq_y_prev_c;
			mult_src2_n <= eq_a_1;
			add_src1_n 	<= add_out_c;
			add_src2_n 	<= mult_out_c;
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n <= EQ_CALC4;
			else
				delay_n <= '0';
				state_n	<= EQ_CALC5;
			end if;
		
		-- multiply before last ouput sample with filter coefficient
		when EQ_CALC5 =>
			mult_src1_n <= eq_y_prev_prev_c;
			mult_src2_n <= eq_a_2;
			add_src1_n 	<= add_out_c;
			add_src2_n 	<= mult_out_c;
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n <= EQ_CALC5;
			else
				delay_n <= '0';
				state_n	<= EQ_CALC6;
			end if;
		
		-- sum up to get output sample from high pass filter
		when EQ_CALC6 =>
			mult_src1_n <= (others => '0');
			mult_src2_n <= (others => '0');
			add_src1_n 	<= add_out_c;
			add_src2_n 	<= mult_out_c;
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n <= EQ_CALC6;
			else
				delay_n <= '0';
				state_n	<= FINISH_CALC;
			end if;
		
		-- save input and output sample as previous and before last samples for equalizer filter
		-- latch in current sample to AGC
		when FINISH_CALC =>
			eq_x_prev_n			<= eq_x_c;
			eq_x_prev_prev_n	<= eq_x_prev_c;
			eq_y_prev_n			<= add_out_c(40 downto 9);
			eq_y_prev_prev_n	<= eq_y_prev_c;			
			curr_sample_n		<= add_out_c(31 downto 16);
			state_n				<= P_CURR;
			
----------------------------------------------------------------------------------			
-- AGC
----------------------------------------------------------------------------------
		
		-- calculate power of current sample
		when P_CURR =>
			mult_src1_n <= resize(abs(curr_sample_c), WIDTH);
			mult_src2_n	<= resize(abs(curr_sample_c), WIDTH);
			add_src1_n 	<= (others => '0');
			add_src2_n 	<= (others => '0');
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n <= P_CURR;
			else
				delay_n <= '0';
				state_n <= P_COMP;
			end if;
		
		-- compare the power of the current sample against previous sample to determine increasing or decreasing power
		when P_COMP =>
			P_in_n <= unsigned(abs(mult_out_c(WIDTH-1 downto 0)));
			
			if unsigned(abs(mult_out_c(WIDTH-1 downto 0))) > P_prev_c then
				state_n <= P_W_1A;
			else
				state_n <= P_W_1B;
			end if;
		
		-- increasing power, weigh against previous sample
		when P_W_1A =>
			mult_src1_n	<= resize(signed(32768 - alpha), WIDTH); -- 32768 - alpha(164) = 32604
			mult_src2_n	<= signed(P_prev_c);
			add_src1_n 	<= (others => '0');
			add_src2_n 	<= (others => '0');
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n <= P_W_1A;
			else
				delay_n <= '0';
				state_n <= P_W_2A;
			end if;
		
		-- decreasing power, weigh against previous sample
		when P_W_1B =>
			mult_src1_n <= resize(signed(32768 - beta), WIDTH); -- 32768 - beta(983) = 31785
			mult_src2_n	<= signed(P_prev_c);
			add_src1_n 	<= (others => '0');
			add_src2_n 	<= (others => '0');
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n <= P_W_1B;
			else
				delay_n <= '0';
				state_n <= P_W_2B;
			end if;
		
		-- increasing power, weigh in current sample
		when P_W_2A =>
			mult_src1_n	<= resize(signed(alpha), WIDTH);
			mult_src2_n	<= signed(P_in_c);
			add_src1_n 	<= mult_out_c;
			add_src2_n 	<= (others => '0');
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n <= P_W_2A;
			else
				delay_n <= '0';
				state_n <= P_W_3;
			end if;
		
		-- decreasing power, weigh in current sample
		when P_W_2B =>
			mult_src1_n	<= resize(signed(beta), WIDTH);
			mult_src2_n	<= signed(P_in_c);
			add_src1_n 	<= mult_out_c;
			add_src2_n 	<= (others => '0');
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n <= P_W_2B;
			else
				delay_n <= '0';
				state_n <= P_W_3;
			end if;
	
		-- sum up to get weighted power of current sample
		when P_W_3 =>
			mult_src1_n	<= (others => '0');
			mult_src2_n	<= (others => '0');
			add_src1_n	<= add_out_c;
			add_src2_n	<= mult_out_c;
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n <= P_W_3;
			else
				delay_n <= '0';
				state_n	<= P_dB;
			end if;
		
		-- convert the weighted power to decibel 
		when P_dB =>
			if unsigned(add_out_c(46 downto 15)) > x"2133a19c6" then -- >99.5dB
				P_dB_n <= to_signed(18, 8);
			elsif unsigned(add_out_c(46 downto 15)) > x"1a5f7f434" then -- >98.5dB
				P_dB_n <= to_signed(17, 8);
			elsif unsigned(add_out_c(46 downto 15)) > x"14f2e7a04" then -- >97.5dB
				P_dB_n <= to_signed(16, 8);
			elsif unsigned(add_out_c(46 downto 15)) > x"10a3e81d2" then -- >96.5dB
				P_dB_n <= to_signed(15, 8);
			elsif unsigned(add_out_c(46 downto 15)) > x"d37c3a05" then -- >95.5dB
				P_dB_n <= to_signed(14, 8);
			elsif unsigned(add_out_c(46 downto 15)) > x"a7fd1c54" then -- >94.5dB
				P_dB_n <= to_signed(13, 8);
			elsif unsigned(add_out_c(46 downto 15)) > x"85702c73" then -- >93.5dB
				P_dB_n <= to_signed(12, 8);
			elsif unsigned(add_out_c(46 downto 15)) > x"69fe63f3" then -- >92.5dB
				P_dB_n <= to_signed(11, 8);
			elsif unsigned(add_out_c(46 downto 15)) > x"54319cc9" then -- >91.5dB
				P_dB_n <= to_signed(10, 8);
			elsif unsigned(add_out_c(46 downto 15)) > x"42e0a497" then -- >90.5dB
				P_dB_n <= to_signed(9, 8);
			elsif unsigned(add_out_c(46 downto 15)) > x"351f68fb" then -- >89.5dB
				P_dB_n <= to_signed(8, 8);
			elsif unsigned(add_out_c(46 downto 15)) > x"2a326539" then -- >88.5dB
				P_dB_n <= to_signed(7, 8);
			elsif unsigned(add_out_c(46 downto 15)) > x"2184a5ce" then -- >87.5dB
				P_dB_n <= to_signed(6, 8);
			elsif unsigned(add_out_c(46 downto 15)) > x"1a9fd9c9" then -- >86.5dB
				P_dB_n <= to_signed(5, 8);
			elsif unsigned(add_out_c(46 downto 15)) > x"152605ce" then -- >85.5dB
				P_dB_n <= to_signed(4, 8);
			elsif unsigned(add_out_c(46 downto 15)) > x"10cc82d6" then -- >84.5dB
				P_dB_n <= to_signed(3, 8);
			elsif unsigned(add_out_c(42 downto 15)) > x"d580472" then -- >83.5dB
				P_dB_n <= to_signed(2, 8);
			elsif unsigned(add_out_c(42 downto 15)) > x"a997066" then -- >82.5dB
				P_dB_n <= to_signed(1, 8);
			elsif unsigned(add_out_c(42 downto 15)) > x"86b5c7b" then -- >81.5dB
				P_dB_n <= to_signed(0, 8);
			elsif unsigned(add_out_c(42 downto 15)) > x"6b01076" then -- >80.5dB
				P_dB_n <= to_signed(-1, 8);
			elsif unsigned(add_out_c(42 downto 15)) > x"54ff0e6" then -- >79.5dB
				P_dB_n <= to_signed(-2, 8);
			elsif unsigned(add_out_c(42 downto 15)) > x"4383d53" then -- >78.5dB
				P_dB_n <= to_signed(-3, 8);
			elsif unsigned(add_out_c(42 downto 15)) > x"35a1095" then -- >77.5dB
				P_dB_n <= to_signed(-4, 8);
			elsif unsigned(add_out_c(42 downto 15)) > x"2a995c8" then -- >76.5dB
				P_dB_n <= to_signed(-5, 8);
			elsif unsigned(add_out_c(42 downto 15)) > x"21d66fb" then -- >75.5dB
				P_dB_n <= to_signed(-6, 8);
			elsif unsigned(add_out_c(42 downto 15)) > x"1ae0d16" then -- >74.5dB
				P_dB_n <= to_signed(-7, 8);
			elsif unsigned(add_out_c(42 downto 15)) > x"1559a0c" then -- >73.5dB
				P_dB_n <= to_signed(-8, 8);
			elsif unsigned(add_out_c(42 downto 15)) > x"10f580b" then -- >72.5dB
				P_dB_n <= to_signed(-9, 8);
			elsif unsigned(add_out_c(38 downto 15)) > x"d78940" then -- >71.5dB
				P_dB_n <= to_signed(-10, 8);
			elsif unsigned(add_out_c(38 downto 15)) > x"ab34d9" then -- >70.5dB
				P_dB_n <= to_signed(-11, 8);
			elsif unsigned(add_out_c(38 downto 15)) > x"87fe7e" then -- >69.5dB
				P_dB_n <= to_signed(-12, 8);
			elsif unsigned(add_out_c(38 downto 15)) > x"6c0622" then -- >68.5dB
				P_dB_n <= to_signed(-13, 8);
			elsif unsigned(add_out_c(38 downto 15)) > x"55ce76" then -- >67.5dB
				P_dB_n <= to_signed(-14, 8);
			elsif unsigned(add_out_c(38 downto 15)) > x"442894" then -- >66.5dB
				P_dB_n <= to_signed(-15, 8);
			elsif unsigned(add_out_c(38 downto 15)) > x"3623e6" then -- >65.5dB
				P_dB_n <= to_signed(-16, 8);
			elsif unsigned(add_out_c(38 downto 15)) > x"2b014f" then -- >64.5dB
				P_dB_n <= to_signed(-17, 8);
			elsif unsigned(add_out_c(38 downto 15)) > x"222902" then -- >63.5dB
				P_dB_n <= to_signed(-18, 8);
			elsif unsigned(add_out_c(38 downto 15)) > x"1b2268" then -- >62.5dB
				P_dB_n <= to_signed(-19, 8);
			elsif unsigned(add_out_c(38 downto 15)) > x"158dba" then -- >61.5dB
				P_dB_n <= to_signed(-20, 8);
			elsif unsigned(add_out_c(38 downto 15)) > x"111ee3" then -- >60.5dB
				P_dB_n <= to_signed(-21, 8);
			elsif unsigned(add_out_c(34 downto 15)) > x"d9973" then -- >59.5dB
				P_dB_n <= to_signed(-22, 8);
			elsif unsigned(add_out_c(34 downto 15)) > x"acd6a" then -- >58.5dB
				P_dB_n <= to_signed(-23, 8);
			elsif unsigned(add_out_c(34 downto 15)) > x"894a6" then -- >57.5dB
				P_dB_n <= to_signed(-24, 8);
			elsif unsigned(add_out_c(34 downto 15)) > x"6d0dc" then -- >56.5dB
				P_dB_n <= to_signed(-25, 8);
			elsif unsigned(add_out_c(34 downto 15)) > x"569fe" then -- >55.5dB
				P_dB_n <= to_signed(-26, 8);
			elsif unsigned(add_out_c(34 downto 15)) > x"44cef" then -- >54.5dB
				P_dB_n <= to_signed(-27, 8);
			elsif unsigned(add_out_c(34 downto 15)) > x"36a81" then -- >53.5dB
				P_dB_n <= to_signed(-28, 8);
			elsif unsigned(add_out_c(34 downto 15)) > x"2b6a4" then -- >52.5dB
				P_dB_n <= to_signed(-29, 8);
			elsif unsigned(add_out_c(34 downto 15)) > x"227c6" then -- >51.5dB
				P_dB_n <= to_signed(-30, 8);
			elsif unsigned(add_out_c(34 downto 15)) > x"1b64a" then -- >50.5dB
				P_dB_n <= to_signed(-31, 8);
			elsif unsigned(add_out_c(34 downto 15)) > x"15c26" then -- >49.5dB
				P_dB_n <= to_signed(-32, 8);
			elsif unsigned(add_out_c(34 downto 15)) > x"1148b" then -- >48.5dB
				P_dB_n <= to_signed(-33, 8);
			elsif unsigned(add_out_c(30 downto 15)) > x"dbab" then -- >47.5dB
				P_dB_n <= to_signed(-34, 8);
			elsif unsigned(add_out_c(30 downto 15)) > x"ae7d" then -- >46.5dB
				P_dB_n <= to_signed(-35, 8);
			elsif unsigned(add_out_c(30 downto 15)) > x"8a9a" then -- >45.5dB
				P_dB_n <= to_signed(-36, 8);
			elsif unsigned(add_out_c(30 downto 15)) > x"6e18" then -- >44.5dB
				P_dB_n <= to_signed(-37, 8);
			elsif unsigned(add_out_c(30 downto 15)) > x"5774" then -- >43.5dB
				P_dB_n <= to_signed(-38, 8);
			elsif unsigned(add_out_c(30 downto 15)) > x"4577" then -- >42.5dB
				P_dB_n <= to_signed(-39, 8);
			elsif unsigned(add_out_c(30 downto 15)) > x"372e" then -- >41.5dB
				P_dB_n <= to_signed(-40, 8);
			elsif unsigned(add_out_c(30 downto 15)) > x"2bd5" then -- >40.5dB
				P_dB_n <= to_signed(-41, 8);
			elsif unsigned(add_out_c(30 downto 15)) > x"22d1" then -- >39.5dB
				P_dB_n <= to_signed(-42, 8);
			elsif unsigned(add_out_c(30 downto 15)) > x"1ba8" then -- >38.5dB
				P_dB_n <= to_signed(-43, 8);
			elsif unsigned(add_out_c(30 downto 15)) > x"15f8" then -- >37.5dB
				P_dB_n <= to_signed(-44, 8);
			elsif unsigned(add_out_c(30 downto 15)) > x"1173" then -- >36.5dB
				P_dB_n <= to_signed(-45, 8);
			elsif unsigned(add_out_c(26 downto 15)) > x"ddd" then -- >35.5dB
				P_dB_n <= to_signed(-46, 8);
			elsif unsigned(add_out_c(26 downto 15)) > x"b03" then -- >34.5dB
				P_dB_n <= to_signed(-47, 8);
			elsif unsigned(add_out_c(26 downto 15)) > x"8bf" then -- >33.5dB
				P_dB_n <= to_signed(-48, 8);
			elsif unsigned(add_out_c(26 downto 15)) > x"6f3" then -- >32.5dB
				P_dB_n <= to_signed(-49, 8);
			elsif unsigned(add_out_c(26 downto 15)) > x"585" then -- >31.5dB
				P_dB_n <= to_signed(-50, 8);
			elsif unsigned(add_out_c(26 downto 15)) > x"463" then -- >30.5dB
				P_dB_n <= to_signed(-51, 8);
			elsif unsigned(add_out_c(26 downto 15)) > x"37c" then -- >29.5dB
				P_dB_n <= to_signed(-52, 8);
			elsif unsigned(add_out_c(26 downto 15)) > x"2c4" then -- >28.5dB
				P_dB_n <= to_signed(-53, 8);
			elsif unsigned(add_out_c(26 downto 15)) > x"233" then -- >27.5dB
				P_dB_n <= to_signed(-54, 8);
			elsif unsigned(add_out_c(26 downto 15)) > x"1bf" then -- >26.5dB
				P_dB_n <= to_signed(-55, 8);
			elsif unsigned(add_out_c(26 downto 15)) > x"163" then -- >25.5dB
				P_dB_n <= to_signed(-56, 8);
			elsif unsigned(add_out_c(26 downto 15)) > x"11a" then -- >24.5dB
				P_dB_n <= to_signed(-57, 8);
			elsif unsigned(add_out_c(22 downto 15)) > x"e0" then -- >23.5dB
				P_dB_n <= to_signed(-58, 8);
			elsif unsigned(add_out_c(22 downto 15)) > x"b2" then -- >22.5dB
				P_dB_n <= to_signed(-59, 8);
			elsif unsigned(add_out_c(22 downto 15)) > x"8e" then -- >21.5dB
				P_dB_n <= to_signed(-60, 8);
			elsif unsigned(add_out_c(22 downto 15)) > x"71" then -- >20.5dB
				P_dB_n <= to_signed(-61, 8);
			elsif unsigned(add_out_c(22 downto 15)) > x"5a" then -- >19.5dB
				P_dB_n <= to_signed(-62, 8);
			elsif unsigned(add_out_c(22 downto 15)) > x"47" then -- >18.5dB
				P_dB_n <= to_signed(-63, 8);
			elsif unsigned(add_out_c(22 downto 15)) > x"39" then -- >17.5dB
				P_dB_n <= to_signed(-64, 8);
			elsif unsigned(add_out_c(22 downto 15)) > x"2d" then -- >16.5dB
				P_dB_n <= to_signed(-65, 8);
			elsif unsigned(add_out_c(22 downto 15)) > x"24" then -- >15.5dB
				P_dB_n <= to_signed(-66, 8);
			elsif unsigned(add_out_c(22 downto 15)) > x"1d" then -- >14.5dB
				P_dB_n <= to_signed(-67, 8);
			elsif unsigned(add_out_c(22 downto 15)) > x"17" then -- >13.5dB
				P_dB_n <= to_signed(-68, 8);
			elsif unsigned(add_out_c(22 downto 15)) > x"12" then -- >12.5dB
				P_dB_n <= to_signed(-69, 8);
			elsif unsigned(add_out_c(18 downto 15)) > x"f" then -- >11.5dB
				P_dB_n <= to_signed(-70, 8);
			elsif unsigned(add_out_c(18 downto 15)) > x"c" then -- >10.5dB
				P_dB_n <= to_signed(-71, 8);
			elsif unsigned(add_out_c(18 downto 15)) > x"9" then -- >9.5dB
				P_dB_n <= to_signed(-72, 8);
			elsif unsigned(add_out_c(18 downto 15)) > x"7" then -- >8.5dB
				P_dB_n <= to_signed(-73, 8);
			elsif unsigned(add_out_c(18 downto 15)) > x"6" then -- >7.5dB
				P_dB_n <= to_signed(-74, 8);
			elsif unsigned(add_out_c(18 downto 15)) > x"5" then -- >6.5dB
				P_dB_n <= to_signed(-75, 8);
			elsif unsigned(add_out_c(18 downto 15)) > x"4" then -- >6dB
				P_dB_n <= to_signed(-76, 8);
			elsif unsigned(add_out_c(18 downto 15)) > x"3" then -- >4.5dB
				P_dB_n <= to_signed(-77, 8);
			elsif unsigned(add_out_c(18 downto 15)) > x"2" then -- >3dB
				P_dB_n <= to_signed(-79, 8);
			else												-- >=0dB
				P_dB_n <= to_signed(-82, 8);
			end if;			
			state_n <= FETCH_GAIN;
		
		-- enable LUT and wait for returned gain
		when FETCH_GAIN =>
			if delay_c = '0' then
				o_gain_fetch	<= '1'; 		-- enable LUT
				delay_n 		<= not delay_c;
				state_n 		<= FETCH_GAIN;
			else
				delay_n 		<= '0';
				state_n 		<= GAIN;
			end if;

			
		-- multiply current sample with the gain fetched from LUT
		when GAIN =>
			if P_dB_c > to_signed(-82,16) then
				-- multiply with gain from LUT
				mult_src1_n	<= resize(curr_sample_c, WIDTH);
				mult_src2_n	<= resize(signed(i_gain), WIDTH);
			else
				-- multiply with default gain = no attenuation
				mult_src1_n	<= resize(curr_sample_c, WIDTH);
				mult_src2_n	<= to_signed(32767, WIDTH);
			end if;
			add_src1_n 	<= (others => '0');
			add_src2_n 	<= (others => '0');
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n <= GAIN;
			else
				delay_n <= '0';
				state_n <= AGC_SEND;
			end if;
		
		-- output processed sample and calculate power of output sample 
		when AGC_SEND =>
			mult_src1_n	<= abs(mult_out_c(46 downto 15));
			mult_src2_n	<= abs(mult_out_c(46 downto 15));
			add_src1_n 	<= (others => '0');
			add_src2_n 	<= (others => '0');
			agc_out_n 	<= mult_out_c(30 downto 15);
			if delay_c = '0' then
				delay_n <= not delay_c;
				state_n <= AGC_SEND;
			else
				delay_n <= '0';
				state_n <= P_OUT;
			end if;
			
		-- save power of output sample for comparison and weighting with next input sample	
		when P_OUT =>
			mult_src1_n <= (others => '0');
			mult_src2_n <= (others => '0');
			add_src1_n 	<= (others => '0');
			add_src2_n 	<= (others => '0');
			P_prev_n 	<= unsigned(mult_out_c(WIDTH-1 downto 0));
			state_n 	<= HOLD;

	end case;
	
	mult_out_n 	<= mult_src1_c * mult_src2_c;
	add_out_n 	<= add_src1_c + add_src2_c;
	
end process;

end Behavioral;

