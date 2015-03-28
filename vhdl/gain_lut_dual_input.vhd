----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Niklas Aldén
-- 
-- Create Date:    12:17:19 03/11/2015 
-- Design Name: 
-- Module Name:    gain_lut - Behavioral 
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

entity gain_lut is
    Port ( 	i_L_dB : in  std_logic_vector(7 downto 0);
			i_R_dB : in  std_logic_vector(7 downto 0);
			o_L_gain : out  STD_LOGIC_VECTOR (15 downto 0);
			o_R_gain : out  STD_LOGIC_VECTOR (15 downto 0)
		);
end gain_lut;

architecture Behavioral of gain_lut is

	signal dB_max : std_logic_vector(7 downto 0) := (others => '0');
	signal gain : std_logic_vector(15 downto 0) := (others => '0');

begin

lut_proc : process(i_L_dB, i_R_dB) is
begin
	
	if i_L_dB > i_R_dB then
		dB_max <= i_L_dB;
	else
		dB_max <= i_R_dB;
	end if;

	--gain <= x"7fff"; -- gain = 1
	
		case dB_max is
				
            when x"12" => gain <= x"68b0"; -- 100dB
            when x"11" => gain <= x"699a"; -- 99dB
            when x"10" => gain <= x"6a81"; -- 98dB
            when x"0f" => gain <= x"6b66"; -- 97dB
            when x"0e" => gain <= x"6c48"; -- 96dB
            when x"0d" => gain <= x"6d26"; -- 95dB
            when x"0c" => gain <= x"6e02"; -- 94dB
            when x"0b" => gain <= x"6edb"; -- 93dB
            when x"0a" => gain <= x"6fb0"; -- 92dB
            when x"09" => gain <= x"7083"; -- 91dB
            when x"08" => gain <= x"7151"; -- 90dB
            when x"07" => gain <= x"721d"; -- 89dB
            when x"06" => gain <= x"72e4"; -- 88dB
            when x"05" => gain <= x"73a8"; -- 87dB
            when x"04" => gain <= x"7468"; -- 86dB
            when x"03" => gain <= x"7524"; -- 85dB
            when x"02" => gain <= x"75db"; -- 84dB
            when x"01" => gain <= x"768e"; -- 83dB
            when x"00" => gain <= x"773d"; -- 82dB
            when x"ff" => gain <= x"77e7"; -- 81dB
            when x"fe" => gain <= x"788d"; -- 80dB
            when x"fd" => gain <= x"792d"; -- 79dB
            when x"fc" => gain <= x"79c8"; -- 78dB
            when x"fb" => gain <= x"7a5d"; -- 77dB
            when x"fa" => gain <= x"7aed"; -- 76dB
            when x"f9" => gain <= x"7b77"; -- 75dB
            when x"f8" => gain <= x"7bfb"; -- 74dB
            when x"f7" => gain <= x"7c79"; -- 73dB
            when x"f6" => gain <= x"7cf0"; -- 72dB
            when x"f5" => gain <= x"7d60"; -- 71dB
            when x"f4" => gain <= x"7dc8"; -- 70dB
            when x"f3" => gain <= x"7e2a"; -- 69dB
            when x"f2" => gain <= x"7e83"; -- 68dB
            when x"f1" => gain <= x"7ed5"; -- 67dB
            when x"f0" => gain <= x"7f1d"; -- 66dB
            when x"ef" => gain <= x"7f5d"; -- 65dB
            when x"ee" => gain <= x"7f93"; -- 64dB
            when x"ed" => gain <= x"7fc0"; -- 63dB
            when x"ec" => gain <= x"7fe2"; -- 62dB
--            when x"eb" => gain <= x"7fff"; -- 61dB
--            when x"ea" => gain <= x"7fff"; -- 60dB
--            when x"e9" => gain <= x"7fff"; -- 59dB
--            when x"e8" => gain <= x"7fff"; -- 58dB
--            when x"e7" => gain <= x"7fff"; -- 57dB
--            when x"e6" => gain <= x"7fff"; -- 56dB
--            when x"e5" => gain <= x"7fff"; -- 55dB
--            when x"e4" => gain <= x"7fff"; -- 54dB
--            when x"e3" => gain <= x"7fff"; -- 53dB
--            when x"e2" => gain <= x"7fff"; -- 52dB
--            when x"e1" => gain <= x"7fff"; -- 51dB
--            when x"e0" => gain <= x"7fff"; -- 50dB
--            when x"df" => gain <= x"7fff"; -- 49dB
--            when x"de" => gain <= x"7fff"; -- 48dB
--            when x"dd" => gain <= x"7fff"; -- 47dB
--            when x"dc" => gain <= x"7fff"; -- 46dB
--            when x"db" => gain <= x"7fff"; -- 45dB
--            when x"da" => gain <= x"7fff"; -- 44dB
--            when x"d9" => gain <= x"7fff"; -- 43dB
--            when x"d8" => gain <= x"7fff"; -- 42dB
--            when x"d7" => gain <= x"7fff"; -- 41dB
--            when x"d6" => gain <= x"7fff"; -- 40dB
--            when x"d5" => gain <= x"7fff"; -- 39dB
--            when x"d4" => gain <= x"7fff"; -- 38dB
--            when x"d3" => gain <= x"7fff"; -- 37dB
--            when x"d2" => gain <= x"7fff"; -- 36dB
--            when x"d1" => gain <= x"7fff"; -- 35dB
--            when x"d0" => gain <= x"7fff"; -- 34dB
--            when x"cf" => gain <= x"7fff"; -- 33dB
--            when x"ce" => gain <= x"7fff"; -- 32dB
--            when x"cd" => gain <= x"7fff"; -- 31dB
--            when x"cc" => gain <= x"7fff"; -- 30dB
--            when x"cb" => gain <= x"7fff"; -- 29dB
--            when x"ca" => gain <= x"7fff"; -- 28dB
--            when x"c9" => gain <= x"7fff"; -- 27dB
--            when x"c8" => gain <= x"7fff"; -- 26dB
--            when x"c7" => gain <= x"7fff"; -- 25dB
--            when x"c6" => gain <= x"7fff"; -- 24dB
--            when x"c5" => gain <= x"7fff"; -- 23dB
--            when x"c4" => gain <= x"7fff"; -- 22dB
--            when x"c3" => gain <= x"7fff"; -- 21dB
--            when x"c2" => gain <= x"7fff"; -- 20dB
--            when x"c1" => gain <= x"7fff"; -- 19dB
--            when x"c0" => gain <= x"7fff"; -- 18dB
--            when x"bf" => gain <= x"7fff"; -- 17dB
--            when x"be" => gain <= x"7fff"; -- 16dB
--            when x"bd" => gain <= x"7fff"; -- 15dB
--            when x"bc" => gain <= x"7fff"; -- 14dB
--            when x"bb" => gain <= x"7fff"; -- 13dB
--            when x"ba" => gain <= x"7fff"; -- 12dB
--            when x"b9" => gain <= x"7fff"; -- 11dB
--            when x"b8" => gain <= x"7fff"; -- 10dB
--            when x"b7" => gain <= x"7fff"; -- 9dB
--            when x"b6" => gain <= x"7fff"; -- 8dB
--            when x"b5" => gain <= x"7fff"; -- 7dB
--            when x"b4" => gain <= x"7fff"; -- 6dB
--            when x"b3" => gain <= x"7fff"; -- 5dB
--            when x"b2" => gain <= x"7fff"; -- 4dB
--            when x"b1" => gain <= x"7fff"; -- 3dB
--            when x"b0" => gain <= x"7fff"; -- 2dB
--            when x"af" => gain <= x"7fff"; -- 1dB
		
			when others => gain <= x"7fff"; -- 0dB
			
		end case;

	o_L_gain <= gain;
	o_R_gain <= gain;
	
end process;

end Behavioral;

