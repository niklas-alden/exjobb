--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:37:23 03/20/2015
-- Design Name:   
-- Module Name:   D:/Google Drive/Exjobb/vhdl/ac97/tb_ac97_comb.vhd
-- Project Name:  ac97
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ac97_comb
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
 
ENTITY tb_ac97_comb IS
END tb_ac97_comb;
 
ARCHITECTURE behavior OF tb_ac97_comb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ac97_comb
    PORT(
         clk : IN  std_logic;
         rstn : IN  std_logic;
         i_ac97_ctrl_ready : IN  std_logic;
         i_volume : IN  std_logic_vector(4 downto 0);
         o_cmd_addr : OUT  std_logic_vector(7 downto 0);
         o_cmd_data : OUT  std_logic_vector(15 downto 0);
         o_latching_cmd : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rstn : std_logic := '0';
   signal i_ac97_ctrl_ready : std_logic := '0';
   signal i_volume : std_logic_vector(4 downto 0) := (others => '0');

 	--Outputs
   signal o_cmd_addr : std_logic_vector(7 downto 0);
   signal o_cmd_data : std_logic_vector(15 downto 0);
   signal o_latching_cmd : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ac97_comb PORT MAP (
          clk => clk,
          rstn => rstn,
          i_ac97_ctrl_ready => i_ac97_ctrl_ready,
          i_volume => i_volume,
          o_cmd_addr => o_cmd_addr,
          o_cmd_data => o_cmd_data,
          o_latching_cmd => o_latching_cmd
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

      -- insert stimulus here 
	  
		for i in 0 to 10 loop
			i_ac97_ctrl_ready <= '1';
			wait for clk_period;
			i_ac97_ctrl_ready <= '0';
			wait for 1 us;
		end loop;
	  
		i_volume <= "01000";
	  
		for i in 0 to 10 loop
			i_ac97_ctrl_ready <= '1';
			wait for clk_period;
			i_ac97_ctrl_ready <= '0';
			wait for 1 us;
		end loop;
	  

		wait;
   end process;

END;
