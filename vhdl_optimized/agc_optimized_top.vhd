----------------------------------------------------------------------------------
-- Engineer: 		Niklas Aldén
-- 
-- Create Date:		11:25:42 04/23/2015 
-- Module Name:		agc_optimized_top - Behavioral 
-- Project Name: 	Hardware implementation of AGC for active hearing protectors
-- Description: 	Master Thesis
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity agc_optimized_top is
	Port ( 	clk 		: in std_logic;
			rstn 		: in std_logic;
			i_sample 	: in std_logic_vector(15 downto 0);
			i_start 	: in std_logic;
			o_sample 	: out std_logic_vector(15 downto 0)
			);
end agc_optimized_top;

architecture Behavioral of agc_optimized_top is

	component agc
		Port (	clk 			: in std_logic;
				rstn 			: in std_logic;
				i_sample 		: in std_logic_vector(15 downto 0);
				i_gain 			: in std_logic_vector(15 downto 0);
				i_start 		: in std_logic;
				o_power 		: out std_logic_vector(7 downto 0);
				o_gain_fetch	: out std_logic;
				o_sample 		: out std_logic_vector(15 downto 0)
				);
	end component;

	component gain_lut 
		Port (	clk 		: in std_logic;
				rstn 		: in std_logic;
				i_dB 		: in std_logic_vector(7 downto 0);
				i_enable 	: in std_logic;
				o_gain 		: out std_logic_vector(15 downto 0)
				);
	end component;


	signal P_agc_lut 		: std_logic_vector(7 downto 0);
	signal fetch_agc_lut 	: std_logic;
	signal gain_lut_agc 	: std_logic_vector(15 downto 0);
	

begin

	agc_inst : agc
		port map (
			clk 			=> clk,
			rstn 			=> rstn,
			i_sample 		=> i_sample,
			i_start 		=> i_start,
			i_gain 			=> gain_lut_agc,
			o_gain_fetch	=> fetch_agc_lut,
			o_power 		=> P_agc_lut,
			o_sample 		=> o_sample
			);
			
	gain_lut_inst : gain_lut
		port map (
			clk			=> clk,
			rstn		=> rstn,
			i_dB 		=> P_agc_lut,
			i_enable	=> fetch_agc_lut,
			o_gain 		=> gain_lut_agc
			);


end Behavioral;

