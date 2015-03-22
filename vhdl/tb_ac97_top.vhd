--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:30:21 03/22/2015
-- Design Name:   
-- Module Name:   C:/Users/Niklas/Google Drive/Exjobb/vhdl/ac97_laptop/tb_ac97_top.vhd
-- Project Name:  ac97_laptop
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ac97_top
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
 
ENTITY tb_ac97_top IS
END tb_ac97_top;
 
ARCHITECTURE behavior OF tb_ac97_top IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ac97_top
    PORT(
         clk : IN  std_logic;
         rstn : IN  std_logic;
         i_volume : IN  std_logic_vector(4 downto 0);
         i_sdata_in : IN  std_logic;
         o_sdata_out : OUT  std_logic;
         o_sync : OUT  std_logic;
         o_ac97_rstn : OUT  std_logic;
         i_bit_clk : IN  std_logic;
         i_L_AGC : IN  std_logic_vector(15 downto 0);
         i_R_AGC : IN  std_logic_vector(15 downto 0);
         o_L_AGC : OUT  std_logic_vector(19 downto 0);
         o_R_AGC : OUT  std_logic_vector(19 downto 0);
         o_AGC_start : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rstn : std_logic := '0';
   signal i_volume : std_logic_vector(4 downto 0) := (others => '0');
   signal i_sdata_in : std_logic := '0';
   signal i_bit_clk : std_logic := '0';
   signal i_L_AGC : std_logic_vector(15 downto 0) := (others => '0');
   signal i_R_AGC : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal o_sdata_out : std_logic;
   signal o_sync : std_logic;
   signal o_ac97_rstn : std_logic;
   signal o_L_AGC : std_logic_vector(19 downto 0);
   signal o_R_AGC : std_logic_vector(19 downto 0);
   signal o_AGC_start : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant i_bit_clk_period : time := 81.38 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ac97_top PORT MAP (
          clk => clk,
          rstn => rstn,
          i_volume => i_volume,
          i_sdata_in => i_sdata_in,
          o_sdata_out => o_sdata_out,
          o_sync => o_sync,
          o_ac97_rstn => o_ac97_rstn,
          i_bit_clk => i_bit_clk,
          i_L_AGC => i_L_AGC,
          i_R_AGC => i_R_AGC,
          o_L_AGC => o_L_AGC,
          o_R_AGC => o_R_AGC,
          o_AGC_start => o_AGC_start
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
      wait for 100 ns;	
		rstn <= '1';
	  
      wait for clk_period;
		i_L_AGC <= x"0042";
		i_R_AGC <= x"0073";
      -- insert stimulus here
		for i in 0 to 255 loop
			if (i mod 8) = 1 then
				i_sdata_in <= '1'; 
			else 
				i_sdata_in <= '0';
			end if;
			wait for i_bit_clk_period;
		end loop;
		
		for i in 0 to 255 loop
			if (i mod 4) = 1 then
				i_sdata_in <= '1'; 
			else 
				i_sdata_in <= '0';
			end if;
			wait for i_bit_clk_period;
		end loop;
		
		for i in 0 to 255 loop
			if (i mod 2) = 1 then
				i_sdata_in <= '1'; 
			else 
				i_sdata_in <= '0';
			end if;
			wait for i_bit_clk_period;
		end loop;
		
      wait;
   end process;

END;
