----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Niklas Aldén
-- 
-- Create Date:    22:20:49 03/09/2015 
-- Design Name: 
-- Module Name:    eq_filter - Behavioral 
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

entity eq_filter is
	Port ( 	clk : in  std_logic;
			rstn : in  std_logic;
			i_sample : in  std_logic_vector (15 downto 0);
			i_start : in std_logic;
			o_sample : out std_logic_vector (15 downto 0);
			o_done : out std_logic
			);
end eq_filter;

architecture Behavioral of eq_filter is

--	filter coefficients
	constant b_0 : signed(31 downto 0) := to_signed(55484, 32);
	constant b_1 : signed(31 downto 0) := to_signed(-313, 32);
	constant b_2 : signed(31 downto 0) := to_signed(-55123, 32);
	constant a_1 : signed(31 downto 0) := to_signed(-313, 32);
	constant a_2 : signed(31 downto 0) := to_signed(-151, 32);
	
	signal x_c, x_n : signed(31 downto 0) := (others => '0');
	signal x_prev_c, x_prev_n : signed(31 downto 0) := (others => '0');
	signal x_prev_prev_c, x_prev_prev_n : signed(31 downto 0) := (others => '0');
	signal y_prev_c : signed(31 downto 0) := (others => '0');
	signal y_prev_prev_c, y_prev_prev_n : signed(31 downto 0) := (others => '0');
	signal y_c, y_n : signed(63 downto 0) := (others => '0');
	
	type state_type is (HOLD, CALC, SEND);
	signal state_c, state_n : state_type := HOLD;
	
begin

clk_proc : process(clk, rstn) is
begin

	if rstn = '0' then
		state_c <= HOLD;
		x_c <= (others => '0');
		x_prev_c <= (others => '0');
		x_prev_prev_c <= (others => '0');
		y_prev_c <= (others => '0');
		y_prev_prev_c <= (others => '0');
		y_c <= (others => '0');
	elsif rising_edge(clk) then
		state_c <= state_n;
		x_c <= x_n;
		x_prev_c <= x_prev_n;
		x_prev_prev_c <= x_prev_prev_n;
		y_prev_c <= y_n(40 downto 9);
		y_prev_prev_c <= y_prev_prev_n;
		y_c <= y_n;
	end if;
	
end process;


filter_proc : process(state_c, x_c, x_prev_c, x_prev_prev_c, y_c, y_prev_c, y_prev_prev_c, i_sample, i_start)
begin
	-- default
	state_n <= state_c;
	x_n <= x_c;
	x_prev_n <= x_prev_c;
	x_prev_prev_n <= x_prev_prev_c;
	y_n <= y_c;
	y_prev_prev_n <= y_prev_prev_c;
	o_done <= '0';
	o_sample <= std_logic_vector(y_c(31 downto 16));	
	
	case state_c is
	
	when HOLD =>
		if i_start = '1' then
			x_n <= signed(resize(signed(i_sample), 32));
			state_n <= CALC;
		end if;
		
	when CALC =>
		y_n <= ((((b_0 * x_c) + (b_1 * x_prev_c)) + (b_2 * x_prev_prev_c)) - (a_1 * y_prev_c)) - (a_2 * y_prev_prev_c);
		x_prev_n <= x_c;
		x_prev_prev_n <= x_prev_c;
		y_prev_prev_n <= y_prev_c;
		state_n <= SEND;
		
	when SEND =>
		o_done <= '1';
		state_n <= HOLD;
	
	end case;
	
end process;

end Behavioral;