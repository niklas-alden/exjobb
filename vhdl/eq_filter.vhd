----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
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
				o_sample : out  std_logic_vector (15 downto 0)
			);
end eq_filter;

architecture Behavioral of eq_filter is

--	filter coefficients
	constant b_0 : signed(31 downto 0) := to_signed(55484, 32);
	constant b_1 : signed(31 downto 0) := to_signed(-313, 32);
	constant b_2 : signed(31 downto 0) := to_signed(-55123, 32);
	constant a_1 : signed(31 downto 0) := to_signed(-313, 32);
	constant a_2 : signed(31 downto 0) := to_signed(-151, 32);
--	
	signal x_c : signed(31 downto 0) := (others => '0');
	signal x_prev_c, x_prev_n : signed(31 downto 0) := (others => '0');
	signal x_prev_prev_c, x_prev_prev_n : signed(31 downto 0) := (others => '0');
	
	signal y_prev_c, y_prev_n : signed(31 downto 0) := (others => '0');
	signal y_prev_prev_c, y_prev_prev_n : signed(31 downto 0) := (others => '0');
	
	signal y_hp_c : signed(63 downto 0) := (others => '0');
	signal y_hp_n : signed(63 downto 0) := (others => '0');
	
begin

clk_proc : process(clk, rstn) is
begin

	if rstn = '0' then
		x_c <= (others => '0');
		x_prev_c <= (others => '0');
		x_prev_prev_c <= (others => '0');
		y_prev_c <= (others => '0');
		y_prev_prev_c <= (others => '0');
		y_hp_c <= (others => '0');
	elsif rising_edge(clk) then
		x_c <= signed(resize(signed(i_sample), 32));
		x_prev_c <= x_prev_n;
		x_prev_prev_c <= x_prev_prev_n;
		y_prev_c <= y_hp_n(40 downto 9);
		y_prev_prev_c <= y_prev_prev_n;
		y_hp_c <= y_hp_n;
	end if;
	
end process;


filter_proc : process(x_c, x_prev_c, x_prev_prev_c, y_prev_c, y_prev_prev_c)
begin
	
	if i_start = '1' then
		y_hp_n <= b_0 * x_c + b_1 * x_prev_c + b_2 * x_prev_prev_c - a_1 * y_prev_c - a_2 * y_prev_prev_c;
		x_prev_n <= x_c;
		x_prev_prev_n <= x_prev_c;
		y_prev_prev_n <= y_prev_c;
	else
		y_hp_n <= y_hp_c;
		x_prev_n <= x_prev_c;
		x_prev_prev_n <= x_prev_prev_c;
		y_prev_prev_n <= y_prev_prev_c;
	end if;
	
end process;


out_proc : process(y_hp_c) is
begin

	o_sample <= std_logic_vector(y_hp_c(31 downto 16));
	
end process;
	

end Behavioral;