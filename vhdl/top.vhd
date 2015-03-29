----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Niklas Aldén
-- 
-- Create Date:    11:47:44 03/28/2015 
-- Design Name: 
-- Module Name:    top - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port ( clk : in  STD_LOGIC;
           rstn : in  STD_LOGIC;
           i_volume : in  STD_LOGIC_VECTOR (4 downto 0);
		   i_SDATA_IN : in std_logic;
		   o_SDATA_out : out  STD_LOGIC;
           o_SYNC : out  STD_LOGIC;
           o_RSTN : out  STD_LOGIC;
           i_BIT_CLK : in  STD_LOGIC
		);
end top;

architecture Behavioral of top is

	component ac97_top is
		Port ( clk : in  STD_LOGIC;
			   rstn : in  STD_LOGIC;
			   i_volume : in  STD_LOGIC_VECTOR (4 downto 0);
			   i_sdata_in : in  STD_LOGIC;
			   o_sdata_out : out  STD_LOGIC;
			   o_sync : out  STD_LOGIC;
			   o_ac97_rstn : out  STD_LOGIC;
			   i_bit_clk : in  STD_LOGIC;
			   i_L_from_AGC : in  STD_LOGIC_VECTOR (15 downto 0);-- L channel output from AGC
			   i_R_from_AGC : in  STD_LOGIC_VECTOR (15 downto 0);-- R channel output from AGC
			   o_L_to_AGC : out  STD_LOGIC_VECTOR (15 downto 0);-- L channel input from ADC to send to AGC
			   o_R_to_AGC : out  STD_LOGIC_VECTOR (15 downto 0);-- R channel input from ADC to send to AGC
			   o_L_AGC_start : out STD_LOGIC; -- L data ready for AGC
			   o_R_AGC_start : out STD_LOGIC -- R data ready for AGC
			   );
	end component;

	component high_pass_filter is
		Port ( 	clk : in  std_logic;
				rstn : in  std_logic;
				i_sample : in  std_logic_vector(15 downto 0);
				i_start : in std_logic;
				o_sample : out  std_logic_vector(15 downto 0);
				o_done : out std_logic
				);
	end component;

	component eq_filter is
		Port ( 	clk : in  std_logic;
				rstn : in  std_logic;
				i_sample : in  std_logic_vector (15 downto 0);
				i_start : in std_logic;
				o_sample : out std_logic_vector (15 downto 0);
				o_done : out std_logic
				);
	end component;

	component agc is
		Port ( clk : in  STD_LOGIC;
			   rstn : in  STD_LOGIC;
			   i_sample : in  STD_LOGIC_VECTOR (15 downto 0);
			   i_start : in std_logic;
			   i_gain : in  STD_LOGIC_VECTOR (15 downto 0);
			   o_gain_fetch : out std_logic;
			   o_power : out  STD_LOGIC_VECTOR (7 downto 0);
			   o_sample : out  STD_LOGIC_VECTOR (15 downto 0)
		);
	end component;

	component gain_lut is
		Port ( 	clk : in std_logic;
				rstn : in std_logic;
				i_L_enable : in std_logic;
				i_R_enable : in std_logic;
				i_L_dB : in  std_logic_vector(7 downto 0);
				i_R_dB : in  std_logic_vector(7 downto 0);
				o_L_gain : out  STD_LOGIC_VECTOR (15 downto 0);
				o_R_gain : out  STD_LOGIC_VECTOR (15 downto 0)
			);
	end component;

-- AC97 -> HIGH PASS FILTER
	signal L_sample_ac97_hp, R_sample_ac97_hp : std_logic_vector(15 downto 0);
	signal L_start_ac97_hp, R_start_ac97_hp : std_logic;
-- HIGH PASS FITLER -> EQUALIZER FILTER
	signal L_sample_hp_eq, R_sample_hp_eq : std_logic_vector(15 downto 0);
	signal L_start_hp_eq, R_start_hp_eq : std_logic;
-- EQUALIZER FILTER -> AGC
	signal L_sample_eq_agc, R_sample_eq_agc : std_logic_vector(15 downto 0);
	signal L_start_eq_agc, R_start_eq_agc : std_logic;
-- AGC <-> GAIN LUT
	signal L_power_agc_lut, R_power_agc_lut : std_logic_vector(7 downto 0);
	signal L_gain_lut_agc, R_gain_lut_agc : std_logic_vector(15 downto 0);
	signal L_fetch_agc_lut, R_fetch_agc_lut : std_logic;
-- AGC -> AC97
	signal L_sample_agc_ac97, R_sample_agc_ac97 : std_logic_vector(15 downto 0);
	
	
begin

	ac97_inst : ac97_top
		port map (
			clk 			=> clk,
			rstn 			=> rstn,
			i_volume 		=> i_volume,
			i_sdata_in 		=> i_SDATA_IN,
			o_sdata_out 	=> o_SDATA_OUT,
			o_sync 			=> o_SYNC,
			o_ac97_rstn 	=> o_RSTN,
			i_bit_clk 		=> i_BIT_CLK,
			i_L_from_AGC 	=> L_sample_agc_ac97,
			i_R_from_AGC 	=> R_sample_agc_ac97,
			o_L_to_AGC 		=> L_sample_ac97_hp,
			o_R_to_AGC 		=> R_sample_ac97_hp,
			o_L_AGC_start 	=> L_start_ac97_hp,
			o_R_AGC_start 	=> R_start_ac97_hp
			);

-- LEFT CHANNEL

	L_hp_filter_inst : high_pass_filter
		port map (
			clk 		=> clk,
			rstn 		=> rstn,
			i_sample 	=> L_sample_ac97_hp,
			i_start 	=> L_start_ac97_hp,
			o_sample 	=> L_sample_hp_eq,
			o_done 		=> L_start_hp_eq
			);
	
	L_eq_filter_inst : eq_filter
		port map (
			clk 		=> clk,
			rstn 		=> rstn,
			i_sample 	=> L_sample_hp_eq,
			i_start 	=> L_start_hp_eq,
			o_sample 	=> L_sample_eq_agc,
			o_done 		=> L_start_eq_agc
			);
			
	L_agc_inst : agc
		port map (
			clk 		=> clk,
			rstn 		=> rstn,
			i_sample 	=> L_sample_eq_agc,
			i_start 	=> L_start_eq_agc,
			i_gain 		=> L_gain_lut_agc,
			o_gain_fetch => L_fetch_agc_lut,
			o_power 	=> L_power_agc_lut,
			o_sample 	=> L_sample_agc_ac97
			);

-- RIGHT CHANNEL

	R_hp_filter_inst : high_pass_filter
		port map (
			clk 		=> clk,
			rstn 		=> rstn,
			i_sample 	=> R_sample_ac97_hp,
			i_start 	=> R_start_ac97_hp,
			o_sample 	=> R_sample_hp_eq,
			o_done 		=> R_start_hp_eq
			);
	
	R_eq_filter_inst : eq_filter
		port map (
			clk 		=> clk,
			rstn 		=> rstn,
			i_sample 	=> R_sample_hp_eq,
			i_start 	=> R_start_hp_eq,
			o_sample 	=> R_sample_eq_agc,
			o_done 		=> R_start_eq_agc
			);
			
	R_agc_inst : agc
		port map (
			clk 		=> clk,
			rstn 		=> rstn,
			i_sample 	=> R_sample_eq_agc,
			i_start 	=> R_start_eq_agc,
			i_gain 		=> R_gain_lut_agc,
			o_gain_fetch => R_fetch_agc_lut,
			o_power 	=> R_power_agc_lut,
			o_sample 	=> R_sample_agc_ac97
			);
			
	gain_lut_inst : gain_lut
		port map (
			clk			=> clk,
			rstn		=> rstn,
			i_L_enable	=> L_fetch_agc_lut,
			i_R_enable	=> R_fetch_agc_lut,
			i_L_dB 		=> L_power_agc_lut,
			i_R_dB 		=> R_power_agc_lut,
			o_L_gain 	=> L_gain_lut_agc,
			o_R_gain 	=> R_gain_lut_agc
			);
end Behavioral;

