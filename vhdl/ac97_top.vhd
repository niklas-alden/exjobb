----------------------------------------------------------------------------------
-- Engineer: 		Niklas Aldén
-- 
-- Create Date:    	17:12:17 03/20/2015 
-- Module Name:    	ac97_top - Behavioral 
-- Project Name: 	Hardware implementation of AGC for active hearing protectors
-- Description: 	Master Thesis
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity ac97_top is
    Port ( clk 			: in std_logic;						-- clock
           rstn 		: in std_logic;						-- reset, active low
           i_volume 	: in std_logic_vector(4 downto 0);	-- volume, set by user
           i_sdata_in 	: in std_logic;						-- input data from codec
           o_sdata_out 	: out std_logic;					-- output data to codec
           o_sync 		: out std_logic;					-- sync signal to codec
           o_ac97_rstn 	: out std_logic;					-- ac97 codec reset, active low
           i_bit_clk 	: in std_logic;						-- 12.288 MHz clock from codec
		   i_L_from_AGC : in std_logic_vector(15 downto 0);	-- L channel data from AGC
		   i_R_from_AGC : in std_logic_vector(15 downto 0);	-- R channel data from AGC
		   o_L_to_AGC 	: out std_logic_vector(15 downto 0);-- L channel data from ADC to send to AGC
           o_R_to_AGC 	: out std_logic_vector(15 downto 0);-- R channel data from ADC to send to AGC
		   o_L_AGC_start : out std_logic; 					-- L channel data ready for AGC
		   o_R_AGC_start : out std_logic 					-- R channel data ready for AGC
		   );
end ac97_top;

architecture Behavioral of ac97_top is

	component ac97_comb is
		Port ( clk 				: in std_logic;
			   rstn 			: in std_logic;
			   i_ac97_ctrl_ready : in std_logic;
			   i_volume 		: in std_logic_vector(4 downto 0);
			   o_cmd_addr 		: out std_logic_vector(7 downto 0);
			   o_cmd_data 		: out std_logic_vector(15 downto 0)
			   );
	end component;

	component ac97_ctrl is
		Port ( clk 				: in std_logic;
			   rstn 			: in std_logic;
			   i_ac97_sdata_in 	: in std_logic;
			   o_ac97_sdata_out : out std_logic;
			   o_ac97_sync 		: out std_logic;
			   i_ac97_bit_clk 	: in std_logic;
			   o_ac97_rstn 		: out std_logic;
			   o_ac97_ctrl_ready : out std_logic;
			   i_L_from_AGC 	: in std_logic_vector(15 downto 0);
			   i_R_from_AGC 	: in std_logic_vector(15 downto 0);
			   o_L_to_AGC 		: out std_logic_vector(15 downto 0);
			   o_R_to_AGC 		: out std_logic_vector(15 downto 0);
			   o_L_AGC_ready 	: out std_logic;
			   o_R_AGC_ready 	: out std_logic;
			   i_cmd_addr 		: in std_logic_vector(7 downto 0);
			   i_cmd_data 		: in std_logic_vector(15 downto 0)
			   );
	end component;
-- COMBINATORIAL FSM -> CONTROLLER
	signal cmd_addr_comb_ctrl 	: std_logic_vector(7 downto 0);
	signal cmd_data_comb_ctrl 	: std_logic_vector(15 downto 0);
-- CONTROLLER -> COMBINATORIAL FSM
	signal ready_ctrl_comb 		: std_logic;

begin

	ac97_comb_inst : ac97_comb
		port map (
			clk 				=> clk,
			rstn 				=> rstn,
			i_ac97_ctrl_ready 	=> ready_ctrl_comb,
			i_volume 			=> i_volume,
			o_cmd_addr 			=> cmd_addr_comb_ctrl,
			o_cmd_data 			=> cmd_data_comb_ctrl
			);
			
	ac97_ctrl_inst : ac97_ctrl
		port map (
			clk 				=> clk,
			rstn 				=> rstn,
			i_ac97_sdata_in 	=> i_sdata_in,
			o_ac97_sdata_out 	=> o_sdata_out,
			o_ac97_sync 		=> o_sync,
			i_ac97_bit_clk 		=> i_bit_clk,
			o_ac97_rstn 		=> o_ac97_rstn,
			o_ac97_ctrl_ready 	=> ready_ctrl_comb,
			i_L_from_AGC 		=> i_L_from_AGC,
			i_R_from_AGC 		=> i_R_from_AGC,
			o_L_to_AGC 			=> o_L_to_AGC,
			o_R_to_AGC 			=> o_R_to_AGC,
			o_L_AGC_ready 		=> o_L_AGC_start,
			o_R_AGC_ready 		=> o_R_AGC_start,
			i_cmd_addr 			=> cmd_addr_comb_ctrl,
			i_cmd_data 			=> cmd_data_comb_ctrl
			);

end Behavioral;

