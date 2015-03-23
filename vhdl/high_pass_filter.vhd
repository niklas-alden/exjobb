----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Niklas Aldén
-- 
-- Create Date:    10:22:18 03/09/2015 
-- Design Name: 
-- Module Name:    high_pass_filter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity high_pass_filter is
    Port ( 	clk : in  std_logic;
			rstn : in  std_logic;
			i_sample : in  std_logic_vector(15 downto 0);
			i_start : in std_logic;
			o_sample : out  std_logic_vector(15 downto 0);
			o_done : out std_logic
			);
end high_pass_filter;

architecture Behavioral of high_pass_filter is

--	filter coefficients
	constant b_0 : signed(15 downto 0) := to_signed(504, 16);
	constant b_1 : signed(15 downto 0) := to_signed(-504,16);
	constant a_1 : signed(15 downto 0) := to_signed(-496, 16);
	
	signal x_c, x_n : signed(15 downto 0) := (others => '0');
	signal x_prev_c, x_prev_n : signed(15 downto 0) := (others => '0');
	signal y_prev : signed(15 downto 0) := (others => '0');
	signal y_c, y_n : signed(31 downto 0) := (others => '0');
	
	type state_type is (HOLD, CALC, SEND);
	signal state_c, state_n : state_type := HOLD;
	
begin


clk_proc : process(clk, rstn) is
begin

	if rstn = '0' then
		state_c <= HOLD;
		x_c <= (others => '0');
		x_prev_c <= (others => '0');
		y_prev <= (others => '0');
		y_c <= (others => '0');
	elsif rising_edge(clk) then
		state_c <= state_n;
		x_c <= x_n;
		x_prev_c <= x_prev_n;
		y_prev <= y_n(24 downto 9);
		y_c <= y_n;
	end if;
	
end process;


filter_proc : process(x_c, x_prev_c, y_prev, y_c, state_c, i_sample, i_start) is
begin
	-- default
	state_n <= state_c;
	x_n <= x_c;
	y_n <= y_c;
	x_prev_n <= x_prev_c;
	o_done <= '0';
	o_sample <= std_logic_vector(y_c(24 downto 9));
	
	case state_c is
	
		when HOLD =>
			if i_start = '1' then
				state_n <= CALC;
				x_n <= signed(i_sample);
			end if;
				
		when CALC =>
			y_n <= ((b_0 * x_c) + (b_1 * x_prev_c)) - (a_1 * y_prev);
			x_prev_n <= x_c;
			state_n <= SEND;
			
		when SEND =>
			o_done <= '1';
			state_n <= HOLD;
			
	end case;
	
end process;

end Behavioral;