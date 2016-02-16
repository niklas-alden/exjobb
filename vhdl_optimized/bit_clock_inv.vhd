----------------------------------------------------------------------------------
-- Engineer: 		Niklas Aldén
-- 
-- Create Date:    	15:28:00 03/30/2015 
-- Module Name:    	clock_falling - Behavioral 
-- Project Name: 	Hardware implementation of AGC for active hearing protectors
-- Description: 	Master Thesis
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity bit_clock_invert is
    Port ( 	i_bit_clk 		: in std_logic; -- codec clock, 12.288MHz
			o_inv_clk 	: out std_logic -- output clock, sync on bit_clock falling edge
		   );
end bit_clock_invert;

architecture Behavioral of bit_clock_invert is
	
begin

	clk_proc : process(i_bit_clk) is
	begin
		o_inv_clk <= not i_bit_clk;
	end process;
	
end Behavioral;

