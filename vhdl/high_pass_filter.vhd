----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Niklas ALdén
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
				i_sample : in  std_logic_vector (15 downto 0);
				o_sample : out  std_logic_vector (15 downto 0)
			);
end high_pass_filter;

architecture Behavioral of high_pass_filter is

--	filter coefficients
	constant b_0 : signed(15 downto 0) := to_signed(504, 16);
	constant b_1 : signed(15 downto 0) := to_signed(-504,16);
	constant a_1 : signed(15 downto 0) := to_signed(-496, 16);
--	
	signal x_c : signed(15 downto 0) := (others => '0');
	signal x_prev_c, x_prev_n : signed(15 downto 0) := (others => '0');
	signal y_prev : signed(15 downto 0) := (others => '0');
--	signal y_hp_c, y_hp_n : signed(31 downto 0) := (others => '0');
	signal y_hp_c : signed(15 downto 0) := (others => '0');
	signal y_hp_n : signed(31 downto 0) := (others => '0');
	
begin


clk_proc : process(clk, rstn) is
begin

	if rstn = '0' then
		x_prev_c <= (others => '0');
		y_prev <= (others => '0');
		y_hp_c <= (others => '0');
	elsif rising_edge(clk) then
		x_c <= signed(i_sample);
		x_prev_c <= x_prev_n;
		y_prev <= y_hp_n(24 downto 9);
		y_hp_c <= y_hp_n(24 downto 9);
	end if;
	
end process;


filter_proc : process(x_c, x_prev_c, y_prev) is
begin

	y_hp_n <= b_0 * x_c + b_1 * x_prev_c - a_1 * y_prev;
	x_prev_n <= x_c;
	
end process;


out_proc : process(y_hp_c) is
begin

	o_sample <= std_logic_vector(y_hp_c);
	
end process;


end Behavioral;