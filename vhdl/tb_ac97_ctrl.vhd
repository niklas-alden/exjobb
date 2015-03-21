--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:27:49 03/20/2015
-- Design Name:   
-- Module Name:   D:/Google Drive/Exjobb/vhdl/ac97/tb_ac97_ctrl.vhd
-- Project Name:  ac97
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ac97_ctrl
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
 
ENTITY tb_ac97_ctrl IS
END tb_ac97_ctrl;
 
ARCHITECTURE behavior OF tb_ac97_ctrl IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ac97_ctrl
    PORT(
         clk : IN  std_logic;
         rstn : IN  std_logic;
         i_ac97_sdata_in : IN  std_logic;
         o_ac97_sdata_out : OUT  std_logic;
         o_ac97_sync : OUT  std_logic;
         i_ac97_bit_clk : IN  std_logic;
         o_ac97_rstn : OUT  std_logic;
         o_ac97_ctrl_ready : OUT  std_logic;
         i_L_ADC : IN  std_logic_vector(15 downto 0);
         i_R_ADC : IN  std_logic_vector(15 downto 0);
         o_L_DAC : OUT  std_logic_vector(19 downto 0);
         o_R_DAC : OUT  std_logic_vector(19 downto 0);
         i_latching_cmd : IN  std_logic;
         i_cmd_addr : IN  std_logic_vector(7 downto 0);
         i_cmd_data : IN  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rstn : std_logic := '0';
   signal i_ac97_sdata_in : std_logic := '0';
   signal i_ac97_bit_clk : std_logic := '0';
   signal i_L_ADC : std_logic_vector(15 downto 0) := (others => '0');
   signal i_R_ADC : std_logic_vector(15 downto 0) := (others => '0');
   signal i_latching_cmd : std_logic := '1';
   signal i_cmd_addr : std_logic_vector(7 downto 0) := (others => '0');
   signal i_cmd_data : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal o_ac97_sdata_out : std_logic;
   signal o_ac97_sync : std_logic;
   signal o_ac97_rstn : std_logic;
   signal o_ac97_ctrl_ready : std_logic;
   signal o_L_DAC : std_logic_vector(19 downto 0);
   signal o_R_DAC : std_logic_vector(19 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns; 				-- 100 MHz
   constant i_ac97_bit_clk_period : time := 81.38 ns; 	-- 12.288 MHz
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ac97_ctrl PORT MAP (
          clk => clk,
          rstn => rstn,
          i_ac97_sdata_in => i_ac97_sdata_in,
          o_ac97_sdata_out => o_ac97_sdata_out,
          o_ac97_sync => o_ac97_sync,
          i_ac97_bit_clk => i_ac97_bit_clk,
          o_ac97_rstn => o_ac97_rstn,
          o_ac97_ctrl_ready => o_ac97_ctrl_ready,
          i_L_ADC => i_L_ADC,
          i_R_ADC => i_R_ADC,
          o_L_DAC => o_L_DAC,
          o_R_DAC => o_R_DAC,
          i_latching_cmd => i_latching_cmd,
          i_cmd_addr => i_cmd_addr,
          i_cmd_data => i_cmd_data
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   i_ac97_bit_clk_process :process
   begin
		i_ac97_bit_clk <= '0';
		wait for i_ac97_bit_clk_period/2;
		i_ac97_bit_clk <= '1';
		wait for i_ac97_bit_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      rstn <= '0';
      wait for 10 ns;	
	  rstn <= '1';
	  
      wait for clk_period;

      -- insert stimulus here
		i_ac97_sdata_in <= '1';
		i_cmd_addr <= x"02";
        i_cmd_data <= x"0000";
		wait for i_ac97_bit_clk_period*256;
		i_ac97_sdata_in <= '0';
		i_cmd_addr <= x"04";
        i_cmd_data <= x"1F1F";
		wait for i_ac97_bit_clk_period*256;
		i_cmd_addr <= x"10";
        i_cmd_data <= x"0808";
		wait for i_ac97_bit_clk_period*256;
		i_cmd_addr <= x"18";
        i_cmd_data <= x"0808";
		wait for i_ac97_bit_clk_period*256;
		i_cmd_addr <= x"1A";
        i_cmd_data <= x"0404";
		wait for i_ac97_bit_clk_period*256;
		i_cmd_addr <= x"1C";
        i_cmd_data <= x"0F0F";
		wait for i_ac97_bit_clk_period*256;
		i_cmd_addr <= x"2C";
        i_cmd_data <= x"BB80";
		wait for i_ac97_bit_clk_period*256;
		i_cmd_addr <= x"32";
        i_cmd_data <= x"BB80";
		wait for i_ac97_bit_clk_period*256;	
		i_cmd_addr <= x"02";
        i_cmd_data <= x"0000";		
      wait;
   end process;

END;
