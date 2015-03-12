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
		
			when others => o_gain <= x"7fff"; -- 0dB
		end case;
	end if;

end process;

end Behavioral;

