----------------------------------------------------------------------------------
-- Engineer: 		Niklas Aldén
-- 
-- Create Date:		13:46:18 04/22/2015 
-- Module Name:		agc_tmp - Behavioral 
-- Project Name: 	Hardware implementation of AGC for active hearing protectors
-- Description: 	Master Thesis
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity agc_tmp is
	Port ( clk 			: in std_logic;						-- clock
           rstn 		: in std_logic;						-- reset, active low
           i_sample 	: in std_logic_vector(15 downto 0);	-- input sample from equalizer filter
		   i_start 		: in std_logic;						-- start signal from equalizer filter
           i_gain 		: in std_logic_vector(15 downto 0);	-- gain fetched from LUT
           o_power 		: out std_logic_vector(7 downto 0);	-- sample power to LUT
		   o_gain_fetch : out std_logic;					-- enable signal for LUT
           o_sample 	: out std_logic_vector(15 downto 0)	-- output sample to AC97
	);
end agc_tmp;

architecture Behavioral of agc_tmp is

	constant WIDTH	: integer := 32;
	-- time parameters
	constant alpha 	: unsigned(15 downto 0) := to_unsigned(164, 16); 				-- attack time
	constant beta 	: unsigned(15 downto 0) := to_unsigned(983, 16); 				-- release time
	
	signal mult_src1 	: signed(WIDTH-1 downto 0) := (others => '0');
	signal mult_src2 	: signed(WIDTH-1 downto 0) := (others => '0');
	signal mult_out		: signed(2*WIDTH-1 downto 0) := (others => '0');
	signal add_src1 	: signed(2*WIDTH-1 downto 0) := (others => '0');
	signal add_src2 	: signed(2*WIDTH-1 downto 0) := (others => '0');
	signal add_out 		: signed(2*WIDTH-1 downto 0) := (others => '0');
	
	signal curr_sample_c, curr_sample_n : signed(WIDTH/2-1 downto 0) 	:= (others => '0'); -- current input sample
	signal P_in_c 						: unsigned(WIDTH-1 downto 0) := (others => '0'); -- power of input sample
	signal P_in_n 						: unsigned(WIDTH-1 downto 0) := (others => '0');
	signal P_weigh_c 					: unsigned(WIDTH-1 downto 0) := (others => '0'); -- weighted power of input sample
	signal P_weigh_n 					: unsigned(46 downto 0) := (others => '0');
	signal P_dB_c, P_dB_n 				: signed(7 downto 0) 	:= (others => '0'); -- weighted power of input sample in decibel
	signal P_prev_c, P_prev_n 			: unsigned(WIDTH-1 downto 0) := (others => '0'); -- power of output sample
	signal lut_delay_c, lut_delay_n 	: unsigned(0 downto 0) 	:= (others => '0'); -- one bit delay counter for LUT look-up time	
	signal agc_out_c, agc_out_n			: signed(WIDTH-1 downto 0) 	:= (others => '0'); -- attenuated sample
	
	signal P_w0_c, P_w0_n, P_w1_c, P_w1_n : unsigned(46 downto 0) := (others => '0'); -- temporary registers for weightening multiplications
	
	type state_type is (HOLD, P_CURR, P_COMP, P_W_11, P_W_12, P_W_21, P_W_22, P_W_3, P_dB, FETCH_GAIN, GAIN, SEND); -- states for FSM
	signal state_c, state_n 			: state_type := HOLD;

begin

-- clock process
----------------------------------------------------------------------------------
clk_proc : process(clk, rstn) is
begin
	if rstn = '0' then
		state_c 		<= HOLD;
		P_in_c 			<= (others => '0');
		P_w0_c			<= (others => '0');
		P_w1_c			<= (others => '0');
		P_weigh_c 		<= (others => '0');
		P_dB_c 			<= (others => '0');
		P_prev_c 		<= (others => '0');
		agc_out_c 		<= (others => '0');
		curr_sample_c 	<= (others => '0');
		lut_delay_c 	<= (others => '0');
	elsif rising_edge(clk) then
		state_c 		<= state_n;
		P_in_c 			<= P_in_n;--(30 downto 0);
		P_w0_c			<= P_w0_n;
		P_w1_c			<= P_w1_n;
		P_weigh_c 		<= P_weigh_n(46 downto 15);
		P_dB_c 			<= P_dB_n;
		P_prev_c 		<= P_prev_n;
		agc_out_c 		<= agc_out_n;
		curr_sample_c 	<= curr_sample_n;
		lut_delay_c 	<= lut_delay_n;
	end if;
end process;


-- FSM for AGC process
----------------------------------------------------------------------------------
power_proc : process(state_c, curr_sample_c, P_in_c, P_w0_c, P_w1_c, P_weigh_c, P_dB_c, P_prev_c, agc_out_c, i_sample, i_start, i_gain, lut_delay_c) is
begin
	--default assignments
	state_n 		<= state_c;
	P_in_n 			<= resize(P_in_c, 32);
	P_w0_n			<= P_w0_c;
	P_w1_n			<= P_w1_c;
	P_weigh_n 		<= P_weigh_c & "000000000000000";
	P_dB_n 			<= P_dB_c;
	curr_sample_n 	<= curr_sample_c;
	P_prev_n 		<= P_prev_c;
	agc_out_n 		<= agc_out_c;
	lut_delay_n 	<= lut_delay_c;

	add_src1 	<= (others => '0');
	add_src2 	<= (others => '0');
	mult_src1 	<= (others => '0');
	mult_src2 	<= (others => '0');

	o_sample 		<= std_logic_vector(agc_out_c(30 downto 15)); 	-- output sample
	o_power 		<= std_logic_vector(P_dB_n); 					-- output power to LUT
	o_gain_fetch 	<= '0'; 										-- don't enable LUT
	
	case state_c is

		-- wait for start signal until latching in input sample
		when HOLD =>
			if i_start = '1' then
				curr_sample_n 	<= signed(i_sample);
				state_n 		<= P_CURR;
			end if;
		
		-- calculate power of current sample
		when P_CURR =>
--			P_in_c
			mult_src1 	<= resize(curr_sample_c, WIDTH);
			mult_src2	<= resize(curr_sample_c, WIDTH);
			
			P_in_n 	<= unsigned(abs(signed(curr_sample_c)) * abs(signed(curr_sample_c)));
			state_n <= P_COMP;
		
		-- compare the power of the current sample against previous sample to determine increasing or decreasing power
		-- then weigh the power of the current sample against previous sample
		when P_COMP =>
			if P_in_c > P_prev_c then
				state_n <= P_W_11;
			else
				state_n <= P_W_12;
			end if;
			
		when P_W_11 =>
			mult_src1 	<= signed(32768 - alpha);
			mult_src2	<= signed(P_prev_c);
			state_n 	<= P_W_21;
			
		when P_W_12 =>
			mult_src1 	<= signed(32768 - beta);
			mult_src2	<= signed(P_prev_c);
			state_n 	<= P_W_22;
			
		when P_W_21 =>
			mult_src1 	<= resize(signed(alpha), WIDTH);
			mult_src2	<= signed(P_in_c);
			add_src1 	<= mult_out;
			add_src2 	<= (others => '0');
			state_n 	<= P_W_3;
			
		when P_W_22 =>
			mult_src1 	<= resize(signed(beta), WIDTH);
			mult_src2	<= signed(P_in_c);
			add_src1 	<= mult_out;
			add_src2 	<= (others => '0');
			state_n 	<= P_W_3;
	
		-- add the multiplied temporary values to get the samples weighted power
		when P_W_3 =>
			add_src1	<= add_out;
			add_src2	<= mult_out;
			state_n		<= P_dB;
		
		-- convert the weighted power to decibel
		when P_dB =>
			if P_weigh_c > x"2133a19c6" then -- >99.5dB
				P_dB_n <= to_signed(18, 8);
			elsif P_weigh_c > x"1a5f7f434" then -- >98.5dB
				P_dB_n <= to_signed(17, 8);
			elsif P_weigh_c > x"14f2e7a04" then -- >97.5dB
				P_dB_n <= to_signed(16, 8);
			elsif P_weigh_c > x"10a3e81d2" then -- >96.5dB
				P_dB_n <= to_signed(15, 8);
			elsif P_weigh_c > x"d37c3a05" then -- >95.5dB
				P_dB_n <= to_signed(14, 8);
			elsif P_weigh_c > x"a7fd1c54" then -- >94.5dB
				P_dB_n <= to_signed(13, 8);
			elsif P_weigh_c > x"85702c73" then -- >93.5dB
				P_dB_n <= to_signed(12, 8);
			elsif P_weigh_c > x"69fe63f3" then -- >92.5dB
				P_dB_n <= to_signed(11, 8);
			elsif P_weigh_c > x"54319cc9" then -- >91.5dB
				P_dB_n <= to_signed(10, 8);
			elsif P_weigh_c > x"42e0a497" then -- >90.5dB
				P_dB_n <= to_signed(9, 8);
			elsif P_weigh_c > x"351f68fb" then -- >89.5dB
				P_dB_n <= to_signed(8, 8);
			elsif P_weigh_c > x"2a326539" then -- >88.5dB
				P_dB_n <= to_signed(7, 8);
			elsif P_weigh_c > x"2184a5ce" then -- >87.5dB
				P_dB_n <= to_signed(6, 8);
			elsif P_weigh_c > x"1a9fd9c9" then -- >86.5dB
				P_dB_n <= to_signed(5, 8);
			elsif P_weigh_c > x"152605ce" then -- >85.5dB
				P_dB_n <= to_signed(4, 8);
			elsif P_weigh_c > x"10cc82d6" then -- >84.5dB
				P_dB_n <= to_signed(3, 8);
			elsif P_weigh_c(27 downto 0) > x"d580472" then -- >83.5dB
				P_dB_n <= to_signed(2, 8);
			elsif P_weigh_c(27 downto 0) > x"a997066" then -- >82.5dB
				P_dB_n <= to_signed(1, 8);
			elsif P_weigh_c(27 downto 0) > x"86b5c7b" then -- >81.5dB
				P_dB_n <= to_signed(0, 8);
			elsif P_weigh_c(27 downto 0) > x"6b01076" then -- >80.5dB
				P_dB_n <= to_signed(-1, 8);
			elsif P_weigh_c(27 downto 0) > x"54ff0e6" then -- >79.5dB
				P_dB_n <= to_signed(-2, 8);
			elsif P_weigh_c(27 downto 0) > x"4383d53" then -- >78.5dB
				P_dB_n <= to_signed(-3, 8);
			elsif P_weigh_c(27 downto 0) > x"35a1095" then -- >77.5dB
				P_dB_n <= to_signed(-4, 8);
			elsif P_weigh_c(27 downto 0) > x"2a995c8" then -- >76.5dB
				P_dB_n <= to_signed(-5, 8);
			elsif P_weigh_c(27 downto 0) > x"21d66fb" then -- >75.5dB
				P_dB_n <= to_signed(-6, 8);
			elsif P_weigh_c(27 downto 0) > x"1ae0d16" then -- >74.5dB
				P_dB_n <= to_signed(-7, 8);
			elsif P_weigh_c(27 downto 0) > x"1559a0c" then -- >73.5dB
				P_dB_n <= to_signed(-8, 8);
			elsif P_weigh_c(27 downto 0) > x"10f580b" then -- >72.5dB
				P_dB_n <= to_signed(-9, 8);
			elsif P_weigh_c(23 downto 0) > x"d78940" then -- >71.5dB
				P_dB_n <= to_signed(-10, 8);
			elsif P_weigh_c(23 downto 0) > x"ab34d9" then -- >70.5dB
				P_dB_n <= to_signed(-11, 8);
			elsif P_weigh_c(23 downto 0) > x"87fe7e" then -- >69.5dB
				P_dB_n <= to_signed(-12, 8);
			elsif P_weigh_c(23 downto 0) > x"6c0622" then -- >68.5dB
				P_dB_n <= to_signed(-13, 8);
			elsif P_weigh_c(23 downto 0) > x"55ce76" then -- >67.5dB
				P_dB_n <= to_signed(-14, 8);
			elsif P_weigh_c(23 downto 0) > x"442894" then -- >66.5dB
				P_dB_n <= to_signed(-15, 8);
			elsif P_weigh_c(23 downto 0) > x"3623e6" then -- >65.5dB
				P_dB_n <= to_signed(-16, 8);
			elsif P_weigh_c(23 downto 0) > x"2b014f" then -- >64.5dB
				P_dB_n <= to_signed(-17, 8);
			elsif P_weigh_c(23 downto 0) > x"222902" then -- >63.5dB
				P_dB_n <= to_signed(-18, 8);
			elsif P_weigh_c(23 downto 0) > x"1b2268" then -- >62.5dB
				P_dB_n <= to_signed(-19, 8);
			elsif P_weigh_c(23 downto 0) > x"158dba" then -- >61.5dB
				P_dB_n <= to_signed(-20, 8);
			elsif P_weigh_c(23 downto 0) > x"111ee3" then -- >60.5dB
				P_dB_n <= to_signed(-21, 8);
			elsif P_weigh_c(19 downto 0) > x"d9973" then -- >59.5dB
				P_dB_n <= to_signed(-22, 8);
			elsif P_weigh_c(19 downto 0) > x"acd6a" then -- >58.5dB
				P_dB_n <= to_signed(-23, 8);
			elsif P_weigh_c(19 downto 0) > x"894a6" then -- >57.5dB
				P_dB_n <= to_signed(-24, 8);
			elsif P_weigh_c(19 downto 0) > x"6d0dc" then -- >56.5dB
				P_dB_n <= to_signed(-25, 8);
			elsif P_weigh_c(19 downto 0) > x"569fe" then -- >55.5dB
				P_dB_n <= to_signed(-26, 8);
			elsif P_weigh_c(19 downto 0) > x"44cef" then -- >54.5dB
				P_dB_n <= to_signed(-27, 8);
			elsif P_weigh_c(19 downto 0) > x"36a81" then -- >53.5dB
				P_dB_n <= to_signed(-28, 8);
			elsif P_weigh_c(19 downto 0) > x"2b6a4" then -- >52.5dB
				P_dB_n <= to_signed(-29, 8);
			elsif P_weigh_c(19 downto 0) > x"227c6" then -- >51.5dB
				P_dB_n <= to_signed(-30, 8);
			elsif P_weigh_c(19 downto 0) > x"1b64a" then -- >50.5dB
				P_dB_n <= to_signed(-31, 8);
			elsif P_weigh_c(19 downto 0) > x"15c26" then -- >49.5dB
				P_dB_n <= to_signed(-32, 8);
			elsif P_weigh_c(19 downto 0) > x"1148b" then -- >48.5dB
				P_dB_n <= to_signed(-33, 8);
			elsif P_weigh_c(15 downto 0) > x"dbab" then -- >47.5dB
				P_dB_n <= to_signed(-34, 8);
			elsif P_weigh_c(15 downto 0) > x"ae7d" then -- >46.5dB
				P_dB_n <= to_signed(-35, 8);
			elsif P_weigh_c(15 downto 0) > x"8a9a" then -- >45.5dB
				P_dB_n <= to_signed(-36, 8);
			elsif P_weigh_c(15 downto 0) > x"6e18" then -- >44.5dB
				P_dB_n <= to_signed(-37, 8);
			elsif P_weigh_c(15 downto 0) > x"5774" then -- >43.5dB
				P_dB_n <= to_signed(-38, 8);
			elsif P_weigh_c(15 downto 0) > x"4577" then -- >42.5dB
				P_dB_n <= to_signed(-39, 8);
			elsif P_weigh_c(15 downto 0) > x"372e" then -- >41.5dB
				P_dB_n <= to_signed(-40, 8);
			elsif P_weigh_c(15 downto 0) > x"2bd5" then -- >40.5dB
				P_dB_n <= to_signed(-41, 8);
			elsif P_weigh_c(15 downto 0) > x"22d1" then -- >39.5dB
				P_dB_n <= to_signed(-42, 8);
			elsif P_weigh_c(15 downto 0) > x"1ba8" then -- >38.5dB
				P_dB_n <= to_signed(-43, 8);
			elsif P_weigh_c(15 downto 0) > x"15f8" then -- >37.5dB
				P_dB_n <= to_signed(-44, 8);
			elsif P_weigh_c(15 downto 0) > x"1173" then -- >36.5dB
				P_dB_n <= to_signed(-45, 8);
			elsif P_weigh_c(11 downto 0) > x"ddd" then -- >35.5dB
				P_dB_n <= to_signed(-46, 8);
			elsif P_weigh_c(11 downto 0) > x"b03" then -- >34.5dB
				P_dB_n <= to_signed(-47, 8);
			elsif P_weigh_c(11 downto 0) > x"8bf" then -- >33.5dB
				P_dB_n <= to_signed(-48, 8);
			elsif P_weigh_c(11 downto 0) > x"6f3" then -- >32.5dB
				P_dB_n <= to_signed(-49, 8);
			elsif P_weigh_c(11 downto 0) > x"585" then -- >31.5dB
				P_dB_n <= to_signed(-50, 8);
			elsif P_weigh_c(11 downto 0) > x"463" then -- >30.5dB
				P_dB_n <= to_signed(-51, 8);
			elsif P_weigh_c(11 downto 0) > x"37c" then -- >29.5dB
				P_dB_n <= to_signed(-52, 8);
			elsif P_weigh_c(11 downto 0) > x"2c4" then -- >28.5dB
				P_dB_n <= to_signed(-53, 8);
			elsif P_weigh_c(11 downto 0) > x"233" then -- >27.5dB
				P_dB_n <= to_signed(-54, 8);
			elsif P_weigh_c(11 downto 0) > x"1bf" then -- >26.5dB
				P_dB_n <= to_signed(-55, 8);
			elsif P_weigh_c(11 downto 0) > x"163" then -- >25.5dB
				P_dB_n <= to_signed(-56, 8);
			elsif P_weigh_c(11 downto 0) > x"11a" then -- >24.5dB
				P_dB_n <= to_signed(-57, 8);
			elsif P_weigh_c(7 downto 0) > x"e0" then -- >23.5dB
				P_dB_n <= to_signed(-58, 8);
			elsif P_weigh_c(7 downto 0) > x"b2" then -- >22.5dB
				P_dB_n <= to_signed(-59, 8);
			elsif P_weigh_c(7 downto 0) > x"8e" then -- >21.5dB
				P_dB_n <= to_signed(-60, 8);
			elsif P_weigh_c(7 downto 0) > x"71" then -- >20.5dB
				P_dB_n <= to_signed(-61, 8);
			elsif P_weigh_c(7 downto 0) > x"5a" then -- >19.5dB
				P_dB_n <= to_signed(-62, 8);
			elsif P_weigh_c(7 downto 0) > x"47" then -- >18.5dB
				P_dB_n <= to_signed(-63, 8);
			elsif P_weigh_c(7 downto 0) > x"39" then -- >17.5dB
				P_dB_n <= to_signed(-64, 8);
			elsif P_weigh_c(7 downto 0) > x"2d" then -- >16.5dB
				P_dB_n <= to_signed(-65, 8);
			elsif P_weigh_c(7 downto 0) > x"24" then -- >15.5dB
				P_dB_n <= to_signed(-66, 8);
			elsif P_weigh_c(7 downto 0) > x"1d" then -- >14.5dB
				P_dB_n <= to_signed(-67, 8);
			elsif P_weigh_c(7 downto 0) > x"17" then -- >13.5dB
				P_dB_n <= to_signed(-68, 8);
			elsif P_weigh_c(7 downto 0) > x"12" then -- >12.5dB
				P_dB_n <= to_signed(-69, 8);
			elsif P_weigh_c(3 downto 0) > x"f" then -- >11.5dB
				P_dB_n <= to_signed(-70, 8);
			elsif P_weigh_c(3 downto 0) > x"c" then -- >10.5dB
				P_dB_n <= to_signed(-71, 8);
			elsif P_weigh_c(3 downto 0) > x"9" then -- >9.5dB
				P_dB_n <= to_signed(-72, 8);
			elsif P_weigh_c(3 downto 0) > x"7" then -- >8.5dB
				P_dB_n <= to_signed(-73, 8);
			elsif P_weigh_c(3 downto 0) > x"6" then -- >7.5dB
				P_dB_n <= to_signed(-74, 8);
			elsif P_weigh_c(3 downto 0) > x"5" then -- >6.5dB
				P_dB_n <= to_signed(-75, 8);
			elsif P_weigh_c(3 downto 0) > x"4" then -- >6dB
				P_dB_n <= to_signed(-76, 8);
			elsif P_weigh_c(3 downto 0) > x"3" then -- >4.5dB
				P_dB_n <= to_signed(-77, 8);
			elsif P_weigh_c(3 downto 0) > x"2" then -- >3dB
				P_dB_n <= to_signed(-79, 8);
			else									-- >=0dB
				P_dB_n <= to_signed(-82, 8);
			end if;
					
			state_n <= FETCH_GAIN;
		
		-- enable LUT and what for returned gain
		when FETCH_GAIN =>
			if lut_delay_c = 0 then
				o_gain_fetch 	<= '1'; 			-- enable LUT
				lut_delay_n 	<= lut_delay_c + 1; -- increase delay counter
				state_n 		<= FETCH_GAIN; 		-- stay in same state
			else
				lut_delay_n 	<= (others => '0'); -- clear delay counter
				state_n 		<= GAIN;
			end if;
			
		-- multiply current sample with the gain fetched from LUT
		when GAIN =>
			if P_dB_c > to_signed(-82,16) then
--				agc_out_n <= signed(curr_sample_c) * signed(i_gain); 		-- multiply with gain from LUT
				mult_src1 	<= resize(curr_sample_c, WIDTH);
				mult_src2 	<= resize(signed(i_gain), WIDTH);
			else
--				agc_out_n <= signed(curr_sample_c) * to_signed(32767, 16); 	-- multiply with default gain => no attenuation
				mult_src1 	<= resize(curr_sample_c, WIDTH);
				mult_src2 	<= to_signed(32767, 16);
			end if;
			state_n <= SEND;
		
		-- calculate power of output sample for comparison and weighting with next input sample
		when SEND =>
--			P_prev_n 	<= unsigned(abs(signed(agc_out_c(30 downto 15))) * abs(signed(agc_out_c(30 downto 15))));
			mult_src1 	<= abs(mult_out(46 downto 15));
			mult_src2 	<= abs(mult_out(46 downto 15));
			state_n 	<= HOLD;
			
	end case;
	
	add_out 	<= add_src1 + add_src2;
	mult_out 	<= mult_src1 * mult_src2;
	
end process;

end Behavioral;