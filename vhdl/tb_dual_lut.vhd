--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:57:21 03/26/2015
-- Design Name:   
-- Module Name:   D:/Google Drive/Exjobb/vhdl/gain_lut_dual_input/tb_dual_lut.vhd
-- Project Name:  gain_lut_dual_input
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: gain_lut
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY tb_dual_lut IS
END tb_dual_lut;
 
ARCHITECTURE behavior OF tb_dual_lut IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT gain_lut
    PORT(
         i_L_dB : IN  std_logic_vector(7 downto 0);
         i_R_dB : IN  std_logic_vector(7 downto 0);
         o_L_gain : OUT  std_logic_vector(15 downto 0);
         o_R_gain : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal i_L_dB : std_logic_vector(7 downto 0) := (others => '0');
   signal i_R_dB : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal o_L_gain : std_logic_vector(15 downto 0);
   signal o_R_gain : std_logic_vector(15 downto 0);
   -- No clocks detected in port list. Replace clock below with 
   -- appropriate port name 
 
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: gain_lut PORT MAP (
          i_L_dB => i_L_dB,
          i_R_dB => i_R_dB,
          o_L_gain => o_L_gain,
          o_R_gain => o_R_gain
        );

   -- Clock process definitions
--   clock_process :process
--   begin
--		clock <= '0';
--		wait for clock_period/2;
--		clock <= '1';
--		wait for clock_period/2;
--   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clock_period*10;

      -- insert stimulus here 
		i_L_dB <= x"10";
		i_R_dB <= x"10";
		wait for clock_period;
		i_L_dB <= x"42";
		i_R_dB <= x"41";
		wait for clock_period;
		i_L_dB <= x"42";
		i_R_dB <= x"43";
		wait for clock_period;
		i_L_dB <= x"f1";
		i_R_dB <= x"ff";
		wait for clock_period;
		i_L_dB <= x"f1";
		i_R_dB <= x"73";
		wait for clock_period;
		i_L_dB <= x"00";
		i_R_dB <= x"ee";
		wait for clock_period;
		i_L_dB <= x"10";
		i_R_dB <= x"10";
		wait for clock_period;
		i_L_dB <= x"0a";
		i_R_dB <= x"0a";
		wait for clock_period;
      wait;
   end process;

END;
