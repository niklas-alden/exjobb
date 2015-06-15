----------------------------------------------------------------------------------
-- Engineer: 		Niklas Aldén
-- 
-- Create Date:    	17:45:14 04/22/2015 
-- Module Name:    	top - Behavioral 
-- Project Name: 	Hardware implementation of AGC for active hearing protectors
-- Description: 	Master Thesis
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity top is
    Port ( 	clk 		: in std_logic;
			rstn 		: in std_logic;
			i_volume 	: in std_logic_vector(4 downto 0);
			i_SDATA_IN 	: in std_logic;
			o_SDATA_out : out std_logic;
			o_SYNC 		: out std_logic;
			o_RSTN 		: out std_logic;
			i_BIT_CLK 	: in std_logic--;
--		   led_test : out std_logic_vector(15 downto 0)
			);
end top;

architecture Behavioral of top is

	component bit_clock_invert is
		Port ( 	i_bit_clk 		: in std_logic;
				o_inv_clk 		: out std_logic
				);
	end component;

	component ac97_top is
		Port ( 	clk 				: in std_logic;
				rstn 				: in std_logic;
				i_volume 			: in std_logic_vector(4 downto 0);
				i_sdata_in 			: in std_logic;
				o_sdata_out 		: out std_logic;
				o_sync 				: out std_logic;
				o_ac97_rstn 		: out std_logic;
				i_bit_clk 			: in std_logic;
				i_falling_bit_clk 	: in std_logic;
				i_L_from_AGC 		: in std_logic_vector(15 downto 0);
				i_R_from_AGC 		: in std_logic_vector(15 downto 0);
				o_L_to_AGC 			: out std_logic_vector(15 downto 0);
				o_R_to_AGC 			: out std_logic_vector(15 downto 0);
				o_L_AGC_start 		: out std_logic;
				o_R_AGC_start 		: out std_logic
				);
	end component;

	component agc_optimized is
		Port ( 	clk 			: in std_logic;
				rstn 			: in std_logic;
				i_sample		: in std_logic_vector(15 downto 0);
				i_start 		: in std_logic;
				i_gain 			: in std_logic_vector(15 downto 0);
				o_gain_fetch 	: out std_logic;
				o_power 		: out std_logic_vector(7 downto 0);
				o_sample 		: out std_logic_vector(15 downto 0)
		);
	end component;

	component gain_lut is
		Port ( 	clk 		: in std_logic;
				rstn 		: in std_logic;
				i_L_enable 	: in std_logic;
				i_R_enable 	: in std_logic;
				i_L_dB 		: in std_logic_vector(7 downto 0);
				i_R_dB 		: in std_logic_vector(7 downto 0);
				o_L_gain 	: out std_logic_vector(15 downto 0);
				o_R_gain 	: out std_logic_vector(15 downto 0)
			);
	end component;

-- INV BIT CLOCK -> AC97 TOP
	signal invert_bit_clk_ac97					: std_logic;
-- AC97 -> AGC
	signal L_sample_ac97_agc, R_sample_ac97_agc 	: std_logic_vector(15 downto 0);
	signal L_start_ac97_agc, R_start_ac97_agc 	: std_logic;
-- AGC <-> GAIN LUT
	signal L_power_agc_lut, R_power_agc_lut 	: std_logic_vector(7 downto 0);
	signal L_gain_lut_agc, R_gain_lut_agc 		: std_logic_vector(15 downto 0);
	signal L_fetch_agc_lut, R_fetch_agc_lut 	: std_logic;
-- AGC -> AC97
	signal L_sample_agc_ac97, R_sample_agc_ac97 : std_logic_vector(15 downto 0);
	
-- loopback
	signal L_loop, R_loop : std_logic_vector(15 downto 0);
	
begin

	bit_clk_inv_inst : bit_clock_invert 
		port map( 
			i_bit_clk 		=> i_BIT_CLK,
			o_inv_clk 		=> invert_bit_clk_ac97
			);

	ac97_inst : ac97_top
		port map (
			clk 				=> clk,
			rstn 				=> rstn,
			i_volume 			=> i_volume,
			i_sdata_in 			=> i_SDATA_IN,
			o_sdata_out 		=> o_SDATA_OUT,
			o_sync 				=> o_SYNC,
			o_ac97_rstn 		=> o_RSTN,
			i_bit_clk 			=> i_BIT_CLK,
			i_falling_bit_clk	=> invert_bit_clk_ac97,
			i_L_from_AGC 		=> L_sample_agc_ac97,--L_loop,--
			i_R_from_AGC 		=> R_sample_agc_ac97,--R_loop,--
			o_L_to_AGC 			=> L_sample_ac97_agc,--L_loop,--led_test,--
			o_R_to_AGC 			=> R_sample_ac97_agc,--R_loop,--led_test,--
			o_L_AGC_start 		=> L_start_ac97_agc,
			o_R_AGC_start 		=> R_start_ac97_agc
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
			
----------------------------------------------------------------------------------
-- LEFT CHANNEL
----------------------------------------------------------------------------------
	L_agc_inst : agc_optimized
		port map (
			clk 			=> clk,
			rstn 			=> rstn,
			i_sample 		=> L_sample_ac97_agc,
			i_start 		=> L_start_ac97_agc,
			i_gain 			=> L_gain_lut_agc,
			o_gain_fetch 	=> L_fetch_agc_lut,
			o_power 		=> L_power_agc_lut,
			o_sample 		=> L_sample_agc_ac97
			);
			
----------------------------------------------------------------------------------
-- RIGHT CHANNEL
----------------------------------------------------------------------------------
	R_agc_inst : agc_optimized
		port map (
			clk 			=> clk,
			rstn 			=> rstn,
			i_sample 		=> R_sample_ac97_agc,
			i_start 		=> R_start_ac97_agc,
			i_gain 			=> R_gain_lut_agc,
			o_gain_fetch 	=> R_fetch_agc_lut,
			o_power 		=> R_power_agc_lut,
			o_sample 		=> R_sample_agc_ac97
			);

end Behavioral;

