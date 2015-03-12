--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:17:17 03/09/2015
-- Design Name:   
-- Module Name:   C:/Users/Niklas/Google Drive/Exjobb/vhdl/filters/tb_hp_filter.vhd
-- Project Name:  filters
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: high_pass_filter
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
 
ENTITY tb_hp_filter IS
END tb_hp_filter;
 
ARCHITECTURE behavior OF tb_hp_filter IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT high_pass_filter
    PORT(
		 clk : IN  std_logic;
         rstn : IN  std_logic;
         i_sample : IN  std_logic_vector(15 downto 0);
         o_sample : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rstn : std_logic := '1';
   signal i_sample : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal o_sample : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: high_pass_filter PORT MAP (
          clk => clk,
          rstn => rstn,
          i_sample => i_sample,
          o_sample => o_sample
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		rstn <= '0';
      wait for 10 ns;	
		rstn <= '1';
      wait for clk_period;
		i_sample <= (others => '0');
		wait for clk_period;
		
--		HIGH PASS FILTER
--		i_sample <= std_logic_vector(to_signed(-864, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(720, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(2000, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(2832, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(3024, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(2768, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(2256, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(1664, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(1168, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(816, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(368, 16));
--		wait for clk_period;
		
--		EQ FILTER
		i_sample <= std_logic_vector(to_signed(-851, 16));
		wait for clk_period;
		i_sample <= std_logic_vector(to_signed(735, 16));
		wait for clk_period;
		i_sample <= std_logic_vector(to_signed(1972, 16));
		wait for clk_period;
		i_sample <= std_logic_vector(to_signed(2729, 16));
		wait for clk_period;
		i_sample <= std_logic_vector(to_signed(2833, 16));
		wait for clk_period;
		i_sample <= std_logic_vector(to_signed(2492, 16));
		wait for clk_period;
		i_sample <= std_logic_vector(to_signed(1910, 16));
		wait for clk_period;
		i_sample <= std_logic_vector(to_signed(1268, 16));
		wait for clk_period;
		i_sample <= std_logic_vector(to_signed(740, 16));
		wait for clk_period;
		i_sample <= std_logic_vector(to_signed(370, 16));
		wait for clk_period;
		i_sample <= std_logic_vector(to_signed(-83, 16));
		wait for clk_period;

		i_sample <= (others => '0');
      wait;
   end process;

END;
