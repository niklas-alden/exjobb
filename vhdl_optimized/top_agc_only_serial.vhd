----------------------------------------------------------------------------------
-- Engineer: 		Niklas Aldén
-- 
-- Create Date:    	16:23:11 05/11/2015 
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
			i_L_sample	: in std_logic;
			i_R_sample	: in std_logic;
			i_L_start	: in std_logic;
			i_R_start	: in std_logic;
			o_L_sample	: out std_logic_vector(15 downto 0);
			o_R_sample	: out std_logic_vector(15 downto 0);
			o_L_done	: out std_logic;
			o_R_done	: out std_logic
			);
end top;

architecture Behavioral of top is

component agc_optimized is
		Port ( 	clk 			: in std_logic;
				rstn 			: in std_logic;
				i_sample		: in std_logic;
				i_start 		: in std_logic;
				i_gain 			: in std_logic_vector(14 downto 0);
				o_gain_fetch 	: out std_logic;
				o_power 		: out std_logic_vector(7 downto 0);
				o_sample 		: out std_logic_vector(15 downto 0);
				o_done			: out std_logic
		);
	end component;

	component gain_lut is
		Port ( 	clk 		: in std_logic;
				rstn 		: in std_logic;
				i_L_enable 	: in std_logic;
				i_R_enable 	: in std_logic;
				i_L_dB 		: in std_logic_vector(7 downto 0);
				i_R_dB 		: in std_logic_vector(7 downto 0);
				o_L_gain 	: out std_logic_vector(14 downto 0);
				o_R_gain 	: out std_logic_vector(14 downto 0)
			);
	end component;

	-- AGC <-> GAIN LUT
	signal L_power_agc_lut, R_power_agc_lut 	: std_logic_vector(7 downto 0);
	signal L_gain_lut_agc, R_gain_lut_agc 		: std_logic_vector(14 downto 0);
	signal L_fetch_agc_lut, R_fetch_agc_lut 	: std_logic;
	
begin
		
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
			i_sample 		=> i_L_sample,
			i_start 		=> i_L_start,
			i_gain 			=> L_gain_lut_agc,
			o_gain_fetch 	=> L_fetch_agc_lut,
			o_power 		=> L_power_agc_lut,
			o_sample 		=> o_L_sample,
			o_done			=> o_L_done
			);
			
----------------------------------------------------------------------------------
-- RIGHT CHANNEL
----------------------------------------------------------------------------------
	R_agc_inst : agc_optimized
		port map (
			clk 			=> clk,
			rstn 			=> rstn,
			i_sample 		=> i_R_sample,
			i_start 		=> i_R_start,
			i_gain 			=> R_gain_lut_agc,
			o_gain_fetch 	=> R_fetch_agc_lut,
			o_power 		=> R_power_agc_lut,
			o_sample 		=> o_R_sample,
			o_done			=> o_R_done
			);

end Behavioral;