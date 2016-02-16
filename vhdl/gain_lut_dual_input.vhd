----------------------------------------------------------------------------------
-- Engineer: 		Niklas Aldn
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
			o_L_gain 	: out std_logic_vector(14 downto 0);-- output gain to left channel AGC
			o_R_gain 	: out std_logic_vector(14 downto 0)	-- output gain to right channel AGC
		);
end gain_lut;

architecture Behavioral of gain_lut is

	signal dB_max_c, dB_max_n 	: std_logic_vector(7 downto 0) := (others => '0'); 	-- max power
	signal gain_c, gain_n 		: std_logic_vector(14 downto 0) := (others => '0'); -- gain corresponding to max power

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
--		46 dB limit
--		when x"12" => gain_n <= "000000000000000"; -- 100dB
--		when x"11" => gain_n <= "000000000000000"; -- 99dB
--		when x"10" => gain_n <= "000000000000000"; -- 98dB
--		when x"0f" => gain_n <= "000000000000000"; -- 97dB
--		when x"0e" => gain_n <= "000000000000000"; -- 96dB
--		when x"0d" => gain_n <= "000000000000000"; -- 95dB
--		when x"0c" => gain_n <= "000000000000000"; -- 94dB
		when x"0b" => gain_n <= "000000000000000"; -- 93dB
		when x"0a" => gain_n <= "000000000000000"; -- 92dB
		when x"09" => gain_n <= "000000000000001"; -- 91dB
		when x"08" => gain_n <= "000000000000001"; -- 90dB
		when x"07" => gain_n <= "000000000000001"; -- 89dB
		when x"06" => gain_n <= "000000000000010"; -- 88dB
		when x"05" => gain_n <= "000000000000010"; -- 87dB
		when x"04" => gain_n <= "000000000000011"; -- 86dB
		when x"03" => gain_n <= "000000000000100"; -- 85dB
		when x"02" => gain_n <= "000000000000101"; -- 84dB
		when x"01" => gain_n <= "000000000000110"; -- 83dB
		when x"00" => gain_n <= "000000000001000"; -- 82dB
		when x"ff" => gain_n <= "000000000001010"; -- 81dB
		when x"fe" => gain_n <= "000000000001101"; -- 80dB
		when x"fd" => gain_n <= "000000000010000"; -- 79dB
		when x"fc" => gain_n <= "000000000010100"; -- 78dB
		when x"fb" => gain_n <= "000000000011010"; -- 77dB
		when x"fa" => gain_n <= "000000000100000"; -- 76dB
		when x"f9" => gain_n <= "000000000101001"; -- 75dB
		when x"f8" => gain_n <= "000000000110011"; -- 74dB
		when x"f7" => gain_n <= "000000001000001"; -- 73dB
		when x"f6" => gain_n <= "000000001010010"; -- 72dB
		when x"f5" => gain_n <= "000000001100111"; -- 71dB
		when x"f4" => gain_n <= "000000010000010"; -- 70dB
		when x"f3" => gain_n <= "000000010100100"; -- 69dB
		when x"f2" => gain_n <= "000000011001110"; -- 68dB
		when x"f1" => gain_n <= "000000100000100"; -- 67dB
		when x"f0" => gain_n <= "000000101000111"; -- 66dB
		when x"ef" => gain_n <= "000000110011100"; -- 65dB
		when x"ee" => gain_n <= "000001000000111"; -- 64dB
		when x"ed" => gain_n <= "000001010001101"; -- 63dB
		when x"ec" => gain_n <= "000001100110111"; -- 62dB
		when x"eb" => gain_n <= "000010000001100"; -- 61dB
		when x"ea" => gain_n <= "000010100011000"; -- 60dB
		when x"e9" => gain_n <= "000011001101010"; -- 59dB
		when x"e8" => gain_n <= "000100000010011"; -- 58dB
		when x"e7" => gain_n <= "000101000101010"; -- 57dB
		when x"e6" => gain_n <= "000110011001100"; -- 56dB
		when x"e5" => gain_n <= "001000000011101"; -- 55dB
		when x"e4" => gain_n <= "001010001001001"; -- 54dB
		when x"e3" => gain_n <= "001100110001010"; -- 53dB
		when x"e2" => gain_n <= "010000000100110"; -- 52dB
		when x"e1" => gain_n <= "010100111110101"; -- 51dB
		when x"e0" => gain_n <= "011010110101000"; -- 50dB
		when x"df" => gain_n <= "100000001101110"; -- 49dB
		when x"de" => gain_n <= "100101001001011"; -- 48dB
		when x"dd" => gain_n <= "101001101000100"; -- 47dB
		when x"dc" => gain_n <= "101101101011100"; -- 46dB
		when x"db" => gain_n <= "110001010011001"; -- 45dB
		when x"da" => gain_n <= "110100100000001"; -- 44dB
		when x"d9" => gain_n <= "110111010011010"; -- 43dB
		when x"d8" => gain_n <= "111001101101001"; -- 42dB
		when x"d7" => gain_n <= "111011101110111"; -- 41dB
		when x"d6" => gain_n <= "111101011001011"; -- 40dB
		when x"d5" => gain_n <= "111110101101101"; -- 39dB
		when x"d4" => gain_n <= "111111101100111"; -- 38dB

		when others => gain_n <= (others => '1'); -- 0dB
		
	end case;

	-- return same gain to left and right channel AGC
	o_L_gain <= gain_c;
	o_R_gain <= gain_c;
	
end process;

end Behavioral;

