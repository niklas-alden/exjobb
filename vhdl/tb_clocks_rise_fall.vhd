--------------------------------------------------------------------------------
-- Company: 
-- Engineer: Niklas Aldén
--
-- Create Date:   15:44:28 03/30/2015
-- Design Name:   
-- Module Name:   C:/Users/Niklas/Google Drive/Exjobb/vhdl/clocks_rising_falling/tb_clocks.vhd
-- Project Name:  clocks_rising_falling
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: clocks
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_clocks_rise_fall IS
END tb_clocks_rise_fall;
 
ARCHITECTURE behavior OF tb_clocks_rise_fall IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT clocks_rise_fall
    PORT(
         clk : IN  std_logic;
         rstn : IN  std_logic;
         i_bit_clk : IN  std_logic;
         o_rising_clk : OUT  std_logic;
         o_falling_clk : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rstn : std_logic := '0';
   signal i_bit_clk : std_logic := '0';

 	--Outputs
   signal o_rising_clk : std_logic;
   signal o_falling_clk : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;--37.037 ns; 30.3 ns;
   constant i_bit_clk_period : time := 81.38 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: clocks_rise_fall PORT MAP (
          clk => clk,
          rstn => rstn,
          i_bit_clk => i_bit_clk,
          o_rising_clk => o_rising_clk,
          o_falling_clk => o_falling_clk
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   i_bit_clk_process :process
   begin
		i_bit_clk <= '0';
		wait for i_bit_clk_period/2;
		i_bit_clk <= '1';
		wait for i_bit_clk_period/2;
   end process;
 
 

   -- Stimulus process
   stim_proc: process
   begin		
      
	rstn <= '0';
    wait for 97 ns;	
	rstn <= '1';
  
    wait;
   end process;

END;
