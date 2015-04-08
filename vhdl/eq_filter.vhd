----------------------------------------------------------------------------------
-- Engineer: 		Niklas Aldén
-- 
-- Create Date:    	22:20:49 03/09/2015 
-- Module Name:    	eq_filter - Behavioral 
-- Project Name: 	Hardware implementation of AGC for active hearing protectors
-- Description: 	Master Thesis
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eq_filter is
	Port ( 	clk 		: in std_logic;							-- clock
			rstn 		: in std_logic;							-- reset, active low
			i_sample 	: in std_logic_vector (15 downto 0);	-- input sample from high pass filter
			i_start 	: in std_logic;							-- start signal from high pass filter
			o_sample 	: out std_logic_vector (15 downto 0);	-- output sample to AGC
			o_done 		: out std_logic							-- done signal to AGC
			);
end eq_filter;

architecture Behavioral of eq_filter is

	-- filter coefficients
	constant b_0 : signed(31 downto 0) := to_signed(55484, 32);
	constant b_1 : signed(31 downto 0) := to_signed(-313, 32);
	constant b_2 : signed(31 downto 0) := to_signed(-55123, 32);
	constant a_1 : signed(31 downto 0) := to_signed(-313, 32);
	constant a_2 : signed(31 downto 0) := to_signed(-151, 32);
	
	signal x_c, x_n 					: signed(31 downto 0) := (others => '0'); -- current input sample
	signal x_prev_c, x_prev_n 			: signed(31 downto 0) := (others => '0'); -- previous input sample
	signal x_prev_prev_c, x_prev_prev_n : signed(31 downto 0) := (others => '0'); -- before last input sample
	signal y_c, y_n 					: signed(63 downto 0) := (others => '0'); -- current output sample
	signal y_prev_c 					: signed(31 downto 0) := (others => '0'); -- previous output sample
	signal y_prev_prev_c, y_prev_prev_n : signed(31 downto 0) := (others => '0'); -- before last output sample
	
	signal t0_c, t0_n, t1_c, t1_n, t2_c, t2_n, t3_c, t3_n, t4_c, t4_n : signed(63 downto 0) := (others => '0'); -- temporary registers for filter multiplications

	type state_type is (HOLD, MULT, ADD, SEND); -- states for FSM
	signal state_c, state_n 			: state_type := HOLD;
	
begin

-- clock process
----------------------------------------------------------------------------------
clk_proc : process(clk, rstn) is
begin
	if rstn = '0' then
		state_c 		<= HOLD;
		x_c 			<= (others => '0');
		x_prev_c 		<= (others => '0');
		x_prev_prev_c 	<= (others => '0');
		y_prev_c 		<= (others => '0');
		y_prev_prev_c 	<= (others => '0');
		y_c 			<= (others => '0');
		t0_c			<= (others => '0');
		t1_c			<= (others => '0');
		t2_c			<= (others => '0');
		t3_c			<= (others => '0');
		t4_c			<= (others => '0');
	elsif rising_edge(clk) then
		state_c 		<= state_n;
		x_c 			<= x_n;
		x_prev_c 		<= x_prev_n;
		x_prev_prev_c 	<= x_prev_prev_n;
		y_prev_c 		<= y_n(40 downto 9);
		y_prev_prev_c 	<= y_prev_prev_n;
		y_c 			<= y_n;
		t0_c			<= t0_n;
		t1_c			<= t1_n;
		t2_c			<= t2_n;
		t3_c			<= t3_n;
		t4_c			<= t4_n;
	end if;
end process;


-- FSM to filter input sample and send filtered output sample
----------------------------------------------------------------------------------
filter_proc : process(state_c, x_c, x_prev_c, x_prev_prev_c, y_c, y_prev_c, y_prev_prev_c, i_sample, i_start, t0_c, t1_c, t2_c, t3_c, t4_c)
begin
	-- default assignments
	state_n 		<= state_c;
	x_n 			<= x_c;
	x_prev_n 		<= x_prev_c;
	x_prev_prev_n 	<= x_prev_prev_c;
	y_n 			<= y_c;
	y_prev_prev_n 	<= y_prev_prev_c;
	t0_n			<= t0_c;
	t1_n			<= t1_c;
	t2_n			<= t2_c;
	t3_n			<= t3_c;
	t4_n			<= t4_c;
	o_done 			<= '0';
	o_sample 		<= std_logic_vector(y_c(31 downto 16));	
	
	case state_c is
	
		-- wait for start signal until latching in input sample
		when HOLD =>
			if i_start = '1' then
				x_n 	<= signed(resize(signed(i_sample), 32));
				state_n <= MULT;
			end if;
		
		-- multiply input sample with filter coefficints
		when MULT =>
			t0_n			<= b_0 * x_c;
			t1_n			<= b_1 * x_prev_c;
			t2_n			<= b_2 * x_prev_prev_c;
			t3_n			<= a_1 * y_prev_c;
			t4_n			<= a_2 * y_prev_prev_c;
			x_prev_n 		<= x_c;
			x_prev_prev_n 	<= x_prev_c;
			y_prev_prev_n 	<= y_prev_c;
			state_n 		<= ADD;
			
		-- add the multiplied temporary values to get output sample
		when ADD =>
			y_n				<= t0_c + t1_c + t2_c - t3_c - t4_c;
			state_n			<= SEND;
			
		-- send filtered sample along with a done signal to start AGC
		when SEND =>
			o_done 		<= '1';
			state_n 	<= HOLD;
	
	end case;
end process;

end Behavioral;