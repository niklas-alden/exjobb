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
			
		when others => gain_n <= x"7fff"; -- 0dB
		
	end case;

	-- return same gain to left and right channel AGC
	o_L_gain <= gain_c;
	o_R_gain <= gain_c;
	
end process;

end Behavioral;