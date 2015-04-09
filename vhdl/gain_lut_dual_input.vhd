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

		when others => gain_n <= x"7fff"; -- 0dB
		
	end case;

	-- return same gain to left and right channel AGC
	o_L_gain <= gain_c;
	o_R_gain <= gain_c;
	
end process;

end Behavioral;

