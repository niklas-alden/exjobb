--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:10:15 03/09/2015
-- Design Name:   
-- Module Name:   D:/Google Drive/Exjobb/vhdl/filters/tb_eq_filter.vhd
-- Project Name:  filters
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: eq_filter
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

use IEEE.std_logic_textio.all;
--library STD;
use std.textio.all;
--use work.txt_util.all;
 
ENTITY tb_eq_filter IS
END tb_eq_filter;
 
ARCHITECTURE behavior OF tb_eq_filter IS 

    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT eq_filter
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
   uut: eq_filter PORT MAP (
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
	 
--	variable read_len: natural;
--	variable in_data: std_logic_vector(15 downto 0);
--	
--	type text is file of std_logic_vector;
--	file stimulus: TEXT open read_mode is "SIMULATION_DATA.txt";
	file stimulus : text is in "SIMULATION_DATA.txt";
	variable in_line : line;
--	variable in_data : std_logic_vector(15 downto 0);
	variable in_data : integer;
	

   begin		
		rstn <= '0';
      wait for 10 ns;	
		rstn <= '1';
      wait for clk_period;
		
		while not endfile(stimulus) loop

          -- read digital data from input file 
          readline(stimulus, in_line);
			 read(in_line, in_data);
			 i_sample <= std_logic_vector(to_signed(in_data,16));

--          read(stimulus, in_data, read_len);
--          i_sample <= std_logic_vector(in_data);

          wait for clk_period;

        end loop;
		
--		i_sample <= std_logic_vector(to_signed(-851, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(735, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(1972, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(2729, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(2833, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(2492, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(1910, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(1268, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(740, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(370, 16));
--		wait for clk_period;
--		i_sample <= std_logic_vector(to_signed(-83, 16));
--		wait for clk_period;

		i_sample <= (others => '0');
      wait;
   end process;

END;
