--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:59:19 05/11/2015
-- Design Name:   
-- Module Name:   C:/Users/Niklas/Desktop/exjobb/vhdl_optimized/tb_top_agc_only_parallel.vhd
-- Project Name:  agc_only_parallell
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: top
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
 
ENTITY tb_top IS
END tb_top;
 
ARCHITECTURE behavior OF tb_top IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top
    PORT(
         clk : IN  std_logic;
         rstn : IN  std_logic;
         i_L_sample : IN  std_logic;
         i_R_sample : IN  std_logic;
         i_L_start : IN  std_logic;
         i_R_start : IN  std_logic;
         o_L_sample : OUT  std_logic_vector(15 downto 0);
         o_R_sample : OUT  std_logic_vector(15 downto 0);
         o_L_done : OUT  std_logic;
         o_R_done : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rstn : std_logic := '0';
   signal i_L_sample : std_logic := '0';
   signal i_R_sample : std_logic := '0';
   signal i_L_start : std_logic := '0';
   signal i_R_start : std_logic := '0';

 	--Outputs
   signal o_L_sample : std_logic_vector(15 downto 0);
   signal o_R_sample : std_logic_vector(15 downto 0);
   signal o_L_done : std_logic;
   signal o_R_done : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
  constant len : integer range 0 to 128 := 104;
   
	type t_sample is array(19 downto 0) of std_logic;
	type t_sample_matrix is array(0 to len-1) of t_sample;
	
	signal s : t_sample_matrix := (
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"fff00",-- -16
		x"00000",-- 0
		x"00000",-- 0
		x"00100",-- 16
		x"00000",-- 0
		x"fff00",-- -16
		x"fff00",-- -16
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"fff00",-- -16
		x"fff00",-- -16
		x"fff00",-- -16
		x"00000",-- 0
		x"00100",-- 16
		x"00000",-- 0
		x"fff00",-- -16
		x"fff00",-- -16
		x"00000",-- 0
		x"00100",-- 16
		x"00100",-- 16
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"00100",-- 16
		x"00100",-- 16
		x"00100",-- 16
		x"00200",-- 32
		x"00200",-- 32
		x"00100",-- 16
		x"00000",-- 0
		x"00000",-- 0
		x"00100",-- 16
		x"00100",-- 16
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"00100",-- 16
		x"00100",-- 16
		x"00100",-- 16
		x"00100",-- 16
		x"00000",-- 0
		x"00000",-- 0
		x"00100",-- 16
		x"00100",-- 16
		x"00100",-- 16
		x"00000",-- 0
		x"00000",-- 0
		x"00100",-- 16
		x"00100",-- 16
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"00100",-- 16
		x"00200",-- 32
		x"00200",-- 32
		x"00100",-- 16
		x"00100",-- 16
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"fff00",-- -16
		x"fff00",-- -16
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"00200",-- 32
		x"00200",-- 32
		x"00200",-- 32
		x"00000",-- 0
		x"00000",-- 0
		x"00000",-- 0
		x"00100",-- 16
		x"00200",-- 32
		x"00100",-- 16
		x"00000",-- 0
		x"fff00",-- -16
		x"00000",-- 0
		x"00100",-- 16
		x"00000",-- 0
		x"ffe00",-- -32
		x"ffc00",-- -64
		x"ffd00",-- -48
		x"00000",-- 0
		x"00200",-- 32
		x"00100",-- 16
		x"ffe00",-- -32
		x"ffe00",-- -32
		x"fff00",-- -16
		x"00100",-- 16
		x"00300"-- 48
		);
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top PORT MAP (
          clk => clk,
          rstn => rstn,
          i_L_sample => i_L_sample,
          i_R_sample => i_R_sample,
          i_L_start => i_L_start,
          i_R_start => i_R_start,
          o_L_sample => o_L_sample,
          o_R_sample => o_R_sample,
          o_L_done => o_L_done,
          o_R_done => o_R_done
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
		-- hold reset state for 100 ns.
		wait for 100 ns;	
		rstn <= '1';
		
		for i in 0 to len-1 loop
			i_L_start <= '1';
			i_R_start <= '1';
			wait for clk_period;
			i_L_start <= '0';
			i_R_start <= '0';
			for j in 19 downto 4 loop
				i_L_sample <= s(i)(j);
				i_R_sample <= s(i)(j);
				wait for clk_period;
			end loop;
			wait for clk_period*200;
		end loop;

		wait;
   end process;

END;
