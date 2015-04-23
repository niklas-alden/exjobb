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
    Port ( 	--clk 			: in std_logic; -- main clock, 100MHz
			--rstn 			: in std_logic; -- reset, active low
			i_bit_clk 		: in std_logic; -- codec clock, 12.288MHz
			o_inv_clk 	: out std_logic -- output clock, sync on bit_clock falling edge
		   );
end bit_clock_invert;

architecture Behavioral of bit_clock_invert is

--	signal sync0_c, sync0_n, sync1_c, sync1_n, Q0_c, Q0_n, Q1_c, Q1_n, Q2_c, Q2_n, Q3_c, Q3_n : std_logic := '0';
	
begin

	clk_proc : process(i_bit_clk) is
	begin
--		if rstn = '0' then
--			o_inv_clk <= '0';
--			sync0_c <= '0';
--			sync1_c <= '0';
--			Q0_c 	<= '0';
--			Q1_c 	<= '0';
--			Q2_c 	<= '0';
--			Q3_c 	<= '0';
--		elsif rising_edge(i_bit_clk) then
			o_inv_clk <= not i_bit_clk;
--			sync0_c <= sync0_n;
--			sync1_c <= sync1_n;
--			Q0_c 	<= Q0_n;
--			Q1_c 	<= Q1_n;
--			Q2_c 	<= Q2_n;
--			Q3_c 	<= Q3_n;
--		end if;
	end process;
	
--	reg_proc : process(i_bit_clk, sync0_c, sync1_c, Q0_c, Q1_c, Q2_c) is
--	begin
--		sync0_n <= i_bit_clk;
--		sync1_n <= sync0_c;
--		Q0_n 	<= sync1_c;
--		Q1_n 	<= Q0_c;
--		Q2_n 	<= Q1_c;
--		Q3_n 	<= Q2_c;
--	end process;
--	
--	sync_fall_proc : process(Q0_c, Q1_c, Q2_c, Q3_c) is
--	begin
--		if Q0_c = '1' and Q1_c = '1' and Q2_c = '1' and Q3_c = '0' then
--			o_falling_clk <= '1';
--		else
--			o_falling_clk <= '0';
--		end if;
--	end process;

end Behavioral;

