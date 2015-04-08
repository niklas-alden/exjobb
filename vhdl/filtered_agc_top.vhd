----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:41:15 03/12/2015 
-- Design Name: 
-- Module Name:    filtered_agc_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity filtered_agc_top is
    Port ( clk : in  STD_LOGIC;
           rstn : in  STD_LOGIC;
           i_sample : in  STD_LOGIC_VECTOR (15 downto 0);
		   i_start : in std_logic;
           o_sample : out  STD_LOGIC_VECTOR (15 downto 0)--;
		   --o_done : out std_logic
		   );
end filtered_agc_top;

architecture Behavioral of filtered_agc_top is

	
	component high_pass_filter
		Port ( 	clk : in  std_logic;
				rstn : in  std_logic;
				i_sample : in  std_logic_vector (15 downto 0);
				i_start : in std_logic;
				o_sample : out  std_logic_vector (15 downto 0);
				o_done : out std_logic
				);
	end component;
	
	component eq_filter
		Port ( 	clk : in  std_logic;
				rstn : in  std_logic;
				i_sample : in  std_logic_vector (15 downto 0);
				i_start : in std_logic;
				o_sample : out  std_logic_vector (15 downto 0);
				o_done : out std_logic
				);
	end component;
	
	component agc
		Port (	clk : in  STD_LOGIC;
				rstn : in  STD_LOGIC;
				i_sample : in  STD_LOGIC_VECTOR (15 downto 0);
				i_start : in std_logic;
				i_gain : in  STD_LOGIC_VECTOR (15 downto 0);
				o_power : out  STD_LOGIC_VECTOR (7 downto 0);
				o_sample : out  STD_LOGIC_VECTOR (15 downto 0)--;
				--o_done : out std_logic
				);
	end component;

	component gain_lut 
		Port (	i_dB : in  STD_LOGIC_VECTOR (7 downto 0);
				o_gain : out  STD_LOGIC_VECTOR (15 downto 0)
				);
	end component;


	signal P_agc_lut : std_logic_vector(7 downto 0);
	signal gain_lut_agc : std_logic_vector(15 downto 0);
	signal sample_hp_eq, sample_eq_agc : std_logic_vector(15 downto 0);
	signal done_hp_eq, done_eq_agc : std_logic;


begin

	hp_filter_inst : high_pass_filter
		port map (
			clk => clk,
			rstn => rstn,
			i_sample => i_sample,
			i_start => i_start,
			o_sample => sample_hp_eq,
			o_done => done_hp_eq
			);
			
	eq_filter_inst : eq_filter
		port map (
			clk => clk,
			rstn => rstn,
			i_sample => sample_hp_eq,
			i_start => done_hp_eq,
			o_sample => sample_eq_agc,
			o_done => done_eq_agc
			);


	agc_inst : agc
		port map (
			clk => clk,
			rstn => rstn,
			i_sample => sample_eq_agc,
			i_start => done_eq_agc,
			i_gain => gain_lut_agc,
			o_power => P_agc_lut,
			o_sample => o_sample--,
			--o_done => o_done
			);
			
	gain_lut_inst : gain_lut
		port map (
			i_dB => P_agc_lut,
			o_gain => gain_lut_agc
			);
			

end Behavioral;

