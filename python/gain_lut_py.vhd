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
    Port( 	
		i_dB : in  STD_LOGIC_VECTOR (7 downto 0);
		o_gain : out  STD_LOGIC_VECTOR (15 downto 0)
		);
end gain_lut;

architecture Behavioral of gain_lut is
begin

lut_proc : process(i_dB) is
begin
	o_gain <= x"7fff"; -- gain = 1
	
	if i_dB < std_logic_vector(to_signed(11,16)) then
		
		case i_dB is
            when x"12" => o_gain <= x"68b0"; -- 100dB
            when x"11" => o_gain <= x"699a"; -- 99dB
            when x"10" => o_gain <= x"6a81"; -- 98dB
            when x"0f" => o_gain <= x"6b66"; -- 97dB
            when x"0e" => o_gain <= x"6c48"; -- 96dB
            when x"0d" => o_gain <= x"6d26"; -- 95dB
            when x"0c" => o_gain <= x"6e02"; -- 94dB
            when x"0b" => o_gain <= x"6edb"; -- 93dB
            when x"0a" => o_gain <= x"6fb0"; -- 92dB
            when x"09" => o_gain <= x"7083"; -- 91dB
            when x"08" => o_gain <= x"7151"; -- 90dB
            when x"07" => o_gain <= x"721d"; -- 89dB
            when x"06" => o_gain <= x"72e4"; -- 88dB
            when x"05" => o_gain <= x"73a8"; -- 87dB
            when x"04" => o_gain <= x"7468"; -- 86dB
            when x"03" => o_gain <= x"7524"; -- 85dB
            when x"02" => o_gain <= x"75db"; -- 84dB
            when x"01" => o_gain <= x"768e"; -- 83dB
            when x"00" => o_gain <= x"773d"; -- 82dB
            when x"ff" => o_gain <= x"77e7"; -- 81dB
            when x"fe" => o_gain <= x"788d"; -- 80dB
            when x"fd" => o_gain <= x"792d"; -- 79dB
            when x"fc" => o_gain <= x"79c8"; -- 78dB
            when x"fb" => o_gain <= x"7a5d"; -- 77dB
            when x"fa" => o_gain <= x"7aed"; -- 76dB
            when x"f9" => o_gain <= x"7b77"; -- 75dB
            when x"f8" => o_gain <= x"7bfb"; -- 74dB
            when x"f7" => o_gain <= x"7c79"; -- 73dB
            when x"f6" => o_gain <= x"7cf0"; -- 72dB
            when x"f5" => o_gain <= x"7d60"; -- 71dB
            when x"f4" => o_gain <= x"7dc8"; -- 70dB
            when x"f3" => o_gain <= x"7e2a"; -- 69dB
            when x"f2" => o_gain <= x"7e83"; -- 68dB
            when x"f1" => o_gain <= x"7ed5"; -- 67dB
            when x"f0" => o_gain <= x"7f1d"; -- 66dB
            when x"ef" => o_gain <= x"7f5d"; -- 65dB
            when x"ee" => o_gain <= x"7f93"; -- 64dB
            when x"ed" => o_gain <= x"7fc0"; -- 63dB
            when x"ec" => o_gain <= x"7fe2"; -- 62dB
            when x"eb" => o_gain <= x"7fff"; -- 61dB
            when x"ea" => o_gain <= x"7fff"; -- 60dB
            when x"e9" => o_gain <= x"7fff"; -- 59dB
            when x"e8" => o_gain <= x"7fff"; -- 58dB
            when x"e7" => o_gain <= x"7fff"; -- 57dB
            when x"e6" => o_gain <= x"7fff"; -- 56dB
            when x"e5" => o_gain <= x"7fff"; -- 55dB
            when x"e4" => o_gain <= x"7fff"; -- 54dB
            when x"e3" => o_gain <= x"7fff"; -- 53dB
            when x"e2" => o_gain <= x"7fff"; -- 52dB
            when x"e1" => o_gain <= x"7fff"; -- 51dB
            when x"e0" => o_gain <= x"7fff"; -- 50dB
            when x"df" => o_gain <= x"7fff"; -- 49dB
            when x"de" => o_gain <= x"7fff"; -- 48dB
            when x"dd" => o_gain <= x"7fff"; -- 47dB
            when x"dc" => o_gain <= x"7fff"; -- 46dB
            when x"db" => o_gain <= x"7fff"; -- 45dB
            when x"da" => o_gain <= x"7fff"; -- 44dB
            when x"d9" => o_gain <= x"7fff"; -- 43dB
            when x"d8" => o_gain <= x"7fff"; -- 42dB
            when x"d7" => o_gain <= x"7fff"; -- 41dB
            when x"d6" => o_gain <= x"7fff"; -- 40dB
            when x"d5" => o_gain <= x"7fff"; -- 39dB
            when x"d4" => o_gain <= x"7fff"; -- 38dB
            when x"d3" => o_gain <= x"7fff"; -- 37dB
            when x"d2" => o_gain <= x"7fff"; -- 36dB
            when x"d1" => o_gain <= x"7fff"; -- 35dB
            when x"d0" => o_gain <= x"7fff"; -- 34dB
            when x"cf" => o_gain <= x"7fff"; -- 33dB
            when x"ce" => o_gain <= x"7fff"; -- 32dB
            when x"cd" => o_gain <= x"7fff"; -- 31dB
            when x"cc" => o_gain <= x"7fff"; -- 30dB
            when x"cb" => o_gain <= x"7fff"; -- 29dB
            when x"ca" => o_gain <= x"7fff"; -- 28dB
            when x"c9" => o_gain <= x"7fff"; -- 27dB
            when x"c8" => o_gain <= x"7fff"; -- 26dB
            when x"c7" => o_gain <= x"7fff"; -- 25dB
            when x"c6" => o_gain <= x"7fff"; -- 24dB
            when x"c5" => o_gain <= x"7fff"; -- 23dB
            when x"c4" => o_gain <= x"7fff"; -- 22dB
            when x"c3" => o_gain <= x"7fff"; -- 21dB
            when x"c2" => o_gain <= x"7fff"; -- 20dB
            when x"c1" => o_gain <= x"7fff"; -- 19dB
            when x"c0" => o_gain <= x"7fff"; -- 18dB
            when x"bf" => o_gain <= x"7fff"; -- 17dB
            when x"be" => o_gain <= x"7fff"; -- 16dB
            when x"bd" => o_gain <= x"7fff"; -- 15dB
            when x"bc" => o_gain <= x"7fff"; -- 14dB
            when x"bb" => o_gain <= x"7fff"; -- 13dB
            when x"ba" => o_gain <= x"7fff"; -- 12dB
            when x"b9" => o_gain <= x"7fff"; -- 11dB
            when x"b8" => o_gain <= x"7fff"; -- 10dB
            when x"b7" => o_gain <= x"7fff"; -- 9dB
            when x"b6" => o_gain <= x"7fff"; -- 8dB
            when x"b5" => o_gain <= x"7fff"; -- 7dB
            when x"b4" => o_gain <= x"7fff"; -- 6dB
            when x"b3" => o_gain <= x"7fff"; -- 5dB
            when x"b2" => o_gain <= x"7fff"; -- 4dB
            when x"b1" => o_gain <= x"7fff"; -- 3dB
            when x"b0" => o_gain <= x"7fff"; -- 2dB
            when x"af" => o_gain <= x"7fff"; -- 1dB
		
			when others => o_gain <= x"7fff"; -- 0dB
		end case;
	end if;

end process;

end Behavioral;

