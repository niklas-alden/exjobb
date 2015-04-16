----------------------------------------------------------------------------------
-- Engineer: 		Niklas Aldén
-- 
-- Create Date:    	12:17:19 03/11/2015 
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
			i_L_enable 	: in std_logic;						-- enable signal from left channel AGC
			i_R_enable 	: in std_logic;						-- enable signal from right channel AGC
			i_L_dB 		: in std_logic_vector(7 downto 0);	-- power from left channel AGC
			i_R_dB 		: in std_logic_vector(7 downto 0);	-- power from right channel AGC
			o_L_gain 	: out std_logic_vector(15 downto 0);-- output gain to left channel AGC
			o_R_gain 	: out std_logic_vector(15 downto 0)	-- output gain to right channel AGC
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


-- compare power of left and right channel, max power determines gain for both channels
----------------------------------------------------------------------------------
lut_proc : process(i_L_enable, i_R_enable, i_L_dB, i_R_dB, gain_c, dB_max_c) is
begin
	if i_L_enable = '1' or i_R_enable = '1' then
		if i_L_dB > i_R_dB then -- compare left and right channel
			dB_max_n <= i_L_dB;
		else
			dB_max_n <= i_R_dB;
		end if;
	else
		dB_max_n <= dB_max_c;
	end if;

	case dB_max_c is -- set corresponding gain
        when x"12" => gain_n <= x"2878"; -- 100dB
        when x"11" => gain_n <= x"2957"; -- 99dB
        when x"10" => gain_n <= x"2a40"; -- 98dB
        when x"0f" => gain_n <= x"2b31"; -- 97dB
        when x"0e" => gain_n <= x"2c2a"; -- 96dB
        when x"0d" => gain_n <= x"2d2c"; -- 95dB
        when x"0c" => gain_n <= x"2e36"; -- 94dB
        when x"0b" => gain_n <= x"2f48"; -- 93dB
        when x"0a" => gain_n <= x"3063"; -- 92dB
        when x"09" => gain_n <= x"3186"; -- 91dB
        when x"08" => gain_n <= x"32b0"; -- 90dB
        when x"07" => gain_n <= x"33e3"; -- 89dB
        when x"06" => gain_n <= x"351e"; -- 88dB
        when x"05" => gain_n <= x"3660"; -- 87dB
        when x"04" => gain_n <= x"37aa"; -- 86dB
        when x"03" => gain_n <= x"38fb"; -- 85dB
        when x"02" => gain_n <= x"3a54"; -- 84dB
        when x"01" => gain_n <= x"3bb4"; -- 83dB
        when x"00" => gain_n <= x"3d1c"; -- 82dB
        when x"ff" => gain_n <= x"3e8a"; -- 81dB
        when x"fe" => gain_n <= x"3fff"; -- 80dB
        when x"fd" => gain_n <= x"417c"; -- 79dB
        when x"fc" => gain_n <= x"42ff"; -- 78dB
        when x"fb" => gain_n <= x"4488"; -- 77dB
        when x"fa" => gain_n <= x"4618"; -- 76dB
        when x"f9" => gain_n <= x"47ae"; -- 75dB
        when x"f8" => gain_n <= x"4949"; -- 74dB
        when x"f7" => gain_n <= x"4aeb"; -- 73dB
        when x"f6" => gain_n <= x"4c92"; -- 72dB
        when x"f5" => gain_n <= x"4e3f"; -- 71dB
        when x"f4" => gain_n <= x"4ff1"; -- 70dB
        when x"f3" => gain_n <= x"51a8"; -- 69dB
        when x"f2" => gain_n <= x"5363"; -- 68dB
        when x"f1" => gain_n <= x"5523"; -- 67dB
        when x"f0" => gain_n <= x"56e7"; -- 66dB
        when x"ef" => gain_n <= x"58ae"; -- 65dB
        when x"ee" => gain_n <= x"5a7a"; -- 64dB
        when x"ed" => gain_n <= x"5c48"; -- 63dB
        when x"ec" => gain_n <= x"5e19"; -- 62dB
        when x"eb" => gain_n <= x"5fed"; -- 61dB
        when x"ea" => gain_n <= x"61c3"; -- 60dB
        when x"e9" => gain_n <= x"639a"; -- 59dB
        when x"e8" => gain_n <= x"6572"; -- 58dB
        when x"e7" => gain_n <= x"674b"; -- 57dB
        when x"e6" => gain_n <= x"6924"; -- 56dB
        when x"e5" => gain_n <= x"6afd"; -- 55dB
        when x"e4" => gain_n <= x"6cd4"; -- 54dB
        when x"e3" => gain_n <= x"6ea9"; -- 53dB
        when x"e2" => gain_n <= x"707d"; -- 52dB
        when x"e1" => gain_n <= x"724c"; -- 51dB
        when x"e0" => gain_n <= x"7418"; -- 50dB
        when x"df" => gain_n <= x"75df"; -- 49dB
        when x"de" => gain_n <= x"779f"; -- 48dB
        when x"dd" => gain_n <= x"7959"; -- 47dB
        when x"dc" => gain_n <= x"7b0a"; -- 46dB
        when x"db" => gain_n <= x"7cb2"; -- 45dB
        when x"da" => gain_n <= x"7e4f"; -- 44dB
        when x"d9" => gain_n <= x"7fe0"; -- 43dB
        when x"d8" => gain_n <= x"7fff"; -- 42dB
        when x"d7" => gain_n <= x"7fff"; -- 41dB
        when x"d6" => gain_n <= x"7fff"; -- 40dB
        when x"d5" => gain_n <= x"7fff"; -- 39dB
        when x"d4" => gain_n <= x"7fff"; -- 38dB
        when x"d3" => gain_n <= x"7fff"; -- 37dB
        when x"d2" => gain_n <= x"7fff"; -- 36dB
        when x"d1" => gain_n <= x"7fff"; -- 35dB
        when x"d0" => gain_n <= x"7fff"; -- 34dB
        when x"cf" => gain_n <= x"7fff"; -- 33dB
        when x"ce" => gain_n <= x"7fff"; -- 32dB
        when x"cd" => gain_n <= x"7fff"; -- 31dB
        when x"cc" => gain_n <= x"7fff"; -- 30dB
        when x"cb" => gain_n <= x"7fff"; -- 29dB
        when x"ca" => gain_n <= x"7fff"; -- 28dB
        when x"c9" => gain_n <= x"7fff"; -- 27dB
        when x"c8" => gain_n <= x"7fff"; -- 26dB
        when x"c7" => gain_n <= x"7fff"; -- 25dB
        when x"c6" => gain_n <= x"7fff"; -- 24dB
        when x"c5" => gain_n <= x"7fff"; -- 23dB
        when x"c4" => gain_n <= x"7fff"; -- 22dB
        when x"c3" => gain_n <= x"7fff"; -- 21dB
        when x"c2" => gain_n <= x"7fff"; -- 20dB
        when x"c1" => gain_n <= x"7fff"; -- 19dB
        when x"c0" => gain_n <= x"7fff"; -- 18dB
        when x"bf" => gain_n <= x"7fff"; -- 17dB
        when x"be" => gain_n <= x"7fff"; -- 16dB
        when x"bd" => gain_n <= x"7fff"; -- 15dB
        when x"bc" => gain_n <= x"7fff"; -- 14dB
        when x"bb" => gain_n <= x"7fff"; -- 13dB
        when x"ba" => gain_n <= x"7fff"; -- 12dB
        when x"b9" => gain_n <= x"7fff"; -- 11dB
        when x"b8" => gain_n <= x"7fff"; -- 10dB
        when x"b7" => gain_n <= x"7fff"; -- 9dB
        when x"b6" => gain_n <= x"7fff"; -- 8dB
        when x"b5" => gain_n <= x"7fff"; -- 7dB
        when x"b4" => gain_n <= x"7fff"; -- 6dB
        when x"b3" => gain_n <= x"7fff"; -- 5dB
        when x"b2" => gain_n <= x"7fff"; -- 4dB
        when x"b1" => gain_n <= x"7fff"; -- 3dB
        when x"b0" => gain_n <= x"7fff"; -- 2dB
        when x"af" => gain_n <= x"7fff"; -- 1dB
			
		when others => gain_n <= x"7fff"; -- 0dB
		
	end case;

	-- return same gain to left and right channel AGC
	o_L_gain <= gain_c;
	o_R_gain <= gain_c;
	
end process;

end Behavioral;