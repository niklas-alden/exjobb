----------------------------------------------------------------------------------
-- Engineer: 		Niklas Aldén
-- 
-- Create Date:    	10:22:18 03/09/2015 
-- Module Name:    	high_pass_filter - Behavioral 
-- Project Name: 	Hardware implementation of AGC for active hearing protectors
-- Description: 	Master Thesis
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity high_pass_filter is
    Port ( 	clk 		: in std_logic; 					-- clock
			rstn 		: in std_logic; 					-- reset, active low
			i_sample 	: in std_logic_vector(15 downto 0); -- input sample from AC97
			i_start 	: in std_logic; 					-- start signal from AC97
			o_sample 	: out std_logic_vector(15 downto 0);-- output sample to equalizer filter
			o_done 		: out std_logic						-- done signal to equalizer filter
			);
end high_pass_filter;

architecture Behavioral of high_pass_filter is

	-- filter coefficients
	constant b_0 : signed(15 downto 0) := to_signed(504, 16);
	constant b_1 : signed(15 downto 0) := to_signed(-504,16);
	constant a_1 : signed(15 downto 0) := to_signed(-496, 16);
	
	signal x_c, x_n 			: signed(15 downto 0) := (others => '0'); -- current input sample
	signal x_prev_c, x_prev_n 	: signed(15 downto 0) := (others => '0'); -- previous input sample
	signal y_c, y_n 			: signed(31 downto 0) := (others => '0'); -- current output sample
	signal y_prev 				: signed(15 downto 0) := (others => '0'); -- previous output sample
	
	type state_type is (HOLD, CALC, SEND); -- states for FSM
	signal state_c, state_n 	: state_type := HOLD;
	
begin

-- clock process
----------------------------------------------------------------------------------
clk_proc : process(clk, rstn) is
begin
	if rstn = '0' then
		state_c 	<= HOLD;
		x_c 		<= (others => '0');
		x_prev_c 	<= (others => '0');
		y_prev 		<= (others => '0');
		y_c 		<= (others => '0');
	elsif rising_edge(clk) then
		state_c 	<= state_n;
		x_c 		<= x_n;
		x_prev_c 	<= x_prev_n;
		y_prev 		<= y_n(24 downto 9);
		y_c 		<= y_n;
	end if;
end process;


-- FSM to filter input sample and send filtered output sample
----------------------------------------------------------------------------------
filter_proc : process(x_c, x_prev_c, y_prev, y_c, state_c, i_sample, i_start) is
begin
	-- default assignments
	state_n 	<= state_c;
	x_n 		<= x_c;
	y_n 		<= y_c;
	x_prev_n 	<= x_prev_c;
	o_done 		<= '0';
	o_sample 	<= std_logic_vector(y_c(24 downto 9));
	
	case state_c is
	
		-- wait for start signal until latching in input sample
		when HOLD =>
			if i_start = '1' then
				state_n <= CALC;
				x_n 	<= signed(i_sample);
			end if;
		
		-- filter input sample
		when CALC =>
			y_n 		<= ((b_0 * x_c) + (b_1 * x_prev_c)) - (a_1 * y_prev);
			x_prev_n 	<= x_c;
			state_n 	<= SEND;
		
		-- send filtered sample along with a done signal to start next filter
		when SEND =>
			o_done 		<= '1';
			state_n 	<= HOLD;
			
	end case;
end process;

end Behavioral;