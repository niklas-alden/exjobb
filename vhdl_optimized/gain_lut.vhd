----------------------------------------------------------------------------------
-- Engineer: 		Niklas Aldén
-- 
-- Create Date:    	12:17:19 03/11/2015 
-- Design Name: 
-- Module Name:    	gain_lut - Behavioral 
-- Project Name: 	Hardware implementation of AGC for active hearing protectors
-- Description: 	Master Thesis
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gain_lut is
    Port ( 	clk 		: in std_logic;						-- clock
			rstn 		: in std_logic;						-- reset, active low
			i_dB 		: in std_logic_vector(7 downto 0);
			i_enable 	: in std_logic;
			o_gain 		: out std_logic_vector(15 downto 0)
			);
end gain_lut;

architecture Behavioral of gain_lut is

	signal dB_max_c, dB_max_n 	: std_logic_vector(7 downto 0) := (others => '0'); 	-- max power
	signal gain_c, gain_n 		: std_logic_vector(15 downto 0) := (others => '0'); -- gain corresponding to max power
	
begin

-- clock process
----------------------------------------------------------------------------------
clk_proc : process(clk, rstn) is
begin
	if rstn = '0' then
		dB_max_c 	<= (others => '0');
		gain_c 		<= (others => '0');
	elsif rising_edge(clk) then
		dB_max_c 	<= dB_max_n;
		gain_c 		<= gain_n;
	end if;
	
end process;

-- lookup power, return gain
----------------------------------------------------------------------------------
lut_proc : process(i_enable, i_dB, gain_c, dB_max_c) is
begin
	if i_enable = '1' then
		dB_max_n <= i_dB;
	else
		dB_max_n <= dB_max_c;
	end if;

	case dB_max_c is -- set corresponding gain
			
-- GAIN LUT 5
-------------------------------------------------
		when x"12" => gain_n <= x"68b0"; -- 100dB
		when x"11" => gain_n <= x"699a"; -- 99dB
		when x"10" => gain_n <= x"6a81"; -- 98dB
		when x"0f" => gain_n <= x"6b66"; -- 97dB
		when x"0e" => gain_n <= x"6c48"; -- 96dB
		when x"0d" => gain_n <= x"6d26"; -- 95dB
		when x"0c" => gain_n <= x"6e02"; -- 94dB
		when x"0b" => gain_n <= x"6edb"; -- 93dB
		when x"0a" => gain_n <= x"6fb0"; -- 92dB
		when x"09" => gain_n <= x"7083"; -- 91dB
		when x"08" => gain_n <= x"7151"; -- 90dB
		when x"07" => gain_n <= x"721d"; -- 89dB
		when x"06" => gain_n <= x"72e4"; -- 88dB
		when x"05" => gain_n <= x"73a8"; -- 87dB
		when x"04" => gain_n <= x"7468"; -- 86dB
		when x"03" => gain_n <= x"7524"; -- 85dB
		when x"02" => gain_n <= x"75db"; -- 84dB
		when x"01" => gain_n <= x"768e"; -- 83dB
		when x"00" => gain_n <= x"773d"; -- 82dB
		when x"ff" => gain_n <= x"77e7"; -- 81dB
		when x"fe" => gain_n <= x"788d"; -- 80dB
		when x"fd" => gain_n <= x"792d"; -- 79dB
		when x"fc" => gain_n <= x"79c8"; -- 78dB
		when x"fb" => gain_n <= x"7a5d"; -- 77dB
		when x"fa" => gain_n <= x"7aed"; -- 76dB
		when x"f9" => gain_n <= x"7b77"; -- 75dB
		when x"f8" => gain_n <= x"7bfb"; -- 74dB
		when x"f7" => gain_n <= x"7c79"; -- 73dB
		when x"f6" => gain_n <= x"7cf0"; -- 72dB
		when x"f5" => gain_n <= x"7d60"; -- 71dB
		when x"f4" => gain_n <= x"7dc8"; -- 70dB
		when x"f3" => gain_n <= x"7e2a"; -- 69dB
		when x"f2" => gain_n <= x"7e83"; -- 68dB
		when x"f1" => gain_n <= x"7ed5"; -- 67dB
		when x"f0" => gain_n <= x"7f1d"; -- 66dB
		when x"ef" => gain_n <= x"7f5d"; -- 65dB
		when x"ee" => gain_n <= x"7f93"; -- 64dB
		when x"ed" => gain_n <= x"7fc0"; -- 63dB
		when x"ec" => gain_n <= x"7fe2"; -- 62dB

-- GAIN LUT 6
-------------------------------------------------
--		when x"12" => gain_n <= x"207"; -- 100dB
--        when x"11" => gain_n <= x"28d"; -- 99dB
--        when x"10" => gain_n <= x"337"; -- 98dB
--        when x"0f" => gain_n <= x"40c"; -- 97dB
--        when x"0e" => gain_n <= x"518"; -- 96dB
--        when x"0d" => gain_n <= x"66a"; -- 95dB
--        when x"0c" => gain_n <= x"813"; -- 94dB
--        when x"0b" => gain_n <= x"a2a"; -- 93dB
--        when x"0a" => gain_n <= x"ccc"; -- 92dB
--        when x"09" => gain_n <= x"101d"; -- 91dB
--        when x"08" => gain_n <= x"1449"; -- 90dB
--        when x"07" => gain_n <= x"198a"; -- 89dB
--        when x"06" => gain_n <= x"2026"; -- 88dB
--        when x"05" => gain_n <= x"287a"; -- 87dB
--        when x"04" => gain_n <= x"32f5"; -- 86dB
--        when x"03" => gain_n <= x"4026"; -- 85dB
--        when x"02" => gain_n <= x"50c3"; -- 84dB
--        when x"01" => gain_n <= x"65ac"; -- 83dB

-- GAIN LUT 7
-------------------------------------------------
--		when x"12" => gain_n <= x"2878"; -- 100dB
--        when x"11" => gain_n <= x"2957"; -- 99dB
--        when x"10" => gain_n <= x"2a40"; -- 98dB
--        when x"0f" => gain_n <= x"2b31"; -- 97dB
--        when x"0e" => gain_n <= x"2c2a"; -- 96dB
--        when x"0d" => gain_n <= x"2d2c"; -- 95dB
--        when x"0c" => gain_n <= x"2e36"; -- 94dB
--        when x"0b" => gain_n <= x"2f48"; -- 93dB
--        when x"0a" => gain_n <= x"3063"; -- 92dB
--        when x"09" => gain_n <= x"3186"; -- 91dB
--        when x"08" => gain_n <= x"32b0"; -- 90dB
--        when x"07" => gain_n <= x"33e3"; -- 89dB
--        when x"06" => gain_n <= x"351e"; -- 88dB
--        when x"05" => gain_n <= x"3660"; -- 87dB
--        when x"04" => gain_n <= x"37aa"; -- 86dB
--        when x"03" => gain_n <= x"38fb"; -- 85dB
--        when x"02" => gain_n <= x"3a54"; -- 84dB
--        when x"01" => gain_n <= x"3bb4"; -- 83dB
--        when x"00" => gain_n <= x"3d1c"; -- 82dB
--        when x"ff" => gain_n <= x"3e8a"; -- 81dB
--        when x"fe" => gain_n <= x"3fff"; -- 80dB
--        when x"fd" => gain_n <= x"417c"; -- 79dB
--        when x"fc" => gain_n <= x"42ff"; -- 78dB
--        when x"fb" => gain_n <= x"4488"; -- 77dB
--        when x"fa" => gain_n <= x"4618"; -- 76dB
--        when x"f9" => gain_n <= x"47ae"; -- 75dB
--        when x"f8" => gain_n <= x"4949"; -- 74dB
--        when x"f7" => gain_n <= x"4aeb"; -- 73dB
--        when x"f6" => gain_n <= x"4c92"; -- 72dB
--        when x"f5" => gain_n <= x"4e3f"; -- 71dB
--        when x"f4" => gain_n <= x"4ff1"; -- 70dB
--        when x"f3" => gain_n <= x"51a8"; -- 69dB
--        when x"f2" => gain_n <= x"5363"; -- 68dB
--        when x"f1" => gain_n <= x"5523"; -- 67dB
--        when x"f0" => gain_n <= x"56e7"; -- 66dB
--        when x"ef" => gain_n <= x"58ae"; -- 65dB
--        when x"ee" => gain_n <= x"5a7a"; -- 64dB
--        when x"ed" => gain_n <= x"5c48"; -- 63dB
--        when x"ec" => gain_n <= x"5e19"; -- 62dB
--        when x"eb" => gain_n <= x"5fed"; -- 61dB
--        when x"ea" => gain_n <= x"61c3"; -- 60dB
--        when x"e9" => gain_n <= x"639a"; -- 59dB
--        when x"e8" => gain_n <= x"6572"; -- 58dB
--        when x"e7" => gain_n <= x"674b"; -- 57dB
--        when x"e6" => gain_n <= x"6924"; -- 56dB
--        when x"e5" => gain_n <= x"6afd"; -- 55dB
--        when x"e4" => gain_n <= x"6cd4"; -- 54dB
--        when x"e3" => gain_n <= x"6ea9"; -- 53dB
--        when x"e2" => gain_n <= x"707d"; -- 52dB
--        when x"e1" => gain_n <= x"724c"; -- 51dB
--        when x"e0" => gain_n <= x"7418"; -- 50dB
--        when x"df" => gain_n <= x"75df"; -- 49dB
--        when x"de" => gain_n <= x"779f"; -- 48dB
--        when x"dd" => gain_n <= x"7959"; -- 47dB
--        when x"dc" => gain_n <= x"7b0a"; -- 46dB
--        when x"db" => gain_n <= x"7cb2"; -- 45dB
--        when x"da" => gain_n <= x"7e4f"; -- 44dB
--        when x"d9" => gain_n <= x"7fe0"; -- 43dB

		when others => gain_n <= x"7fff"; -- 0dB
		
	end case;

	-- return gain to AGC
	o_gain <= gain_c;
	
end process;

end Behavioral;
