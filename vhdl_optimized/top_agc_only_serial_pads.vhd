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
	Port ( 	clk 		: inout std_logic;
			rstn 		: inout std_logic;
			i_L_sample	: inout std_logic;
			i_R_sample	: inout std_logic;
			i_L_start	: inout std_logic;
			i_R_start	: inout std_logic;
			o_L_sample	: inout std_logic;
			o_R_sample	: inout std_logic;
			o_L_done	: inout std_logic;
			o_R_done	: inout std_logic
			);
end top;

architecture Behavioral of top is

component BD2SCARUDQP_1V8_SF_LIN
    port( ZI :  out std_logic;
           A :  in std_logic;
          EN :  in std_logic;
          TA :  in std_logic;
         TEN :  in std_logic;
          TM :  in std_logic;
         PUN :  in std_logic;
         PDN :  in std_logic;
        HYST :  in std_logic;
          IO :  inout std_logic );  -- Pad Surface
  end component;
  
component agc is
		Port ( 	clk 			: in std_logic;
				rstn 			: in std_logic;
				i_sample		: in std_logic;
				i_start 		: in std_logic;
				i_gain 			: in std_logic_vector(14 downto 0);
				o_gain_fetch 	: out std_logic;
				o_power 		: out std_logic_vector(7 downto 0);
				o_sample 		: out std_logic;
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
	-- Pad signals
	signal HIGH, LOW 						: std_logic;
	signal clk_pad, rstn_pad 				: std_logic;
	signal i_L_start_pad, i_R_start_pad 	: std_logic;
	signal i_L_sample_pad, i_R_sample_pad 	: std_logic;
	signal o_L_done_pad, o_R_done_pad 		: std_logic; 
	signal o_L_sample_pad, o_R_sample_pad 	: std_logic;

	begin

----------------------------------------------------------------------------------
-- I/O PADS
----------------------------------------------------------------------------------
	HIGH 	<= '1';
	LOW 	<= '0';
	
	clkpad : BD2SCARUDQP_1V8_SF_LIN
		port map (IO => clk, ZI => clk_pad, A => LOW, EN => HIGH, TA => LOW,
				TEN => HIGH, TM => LOW, PUN => HIGH, PDN => LOW, HYST => LOW);

	inpad_rstn : BD2SCARUDQP_1V8_SF_LIN
		port map( IO => rstn, ZI => rstn_pad, A => LOW, EN => HIGH, TA => LOW,
				TEN => HIGH, TM => LOW, PUN => HIGH, PDN => LOW, HYST => LOW);

	inpad_L_start : BD2SCARUDQP_1V8_SF_LIN
		port map( IO => i_L_start, ZI => i_L_start_pad, A => LOW, EN => HIGH, TA => LOW,
				TEN => HIGH, TM => LOW, PUN => HIGH, PDN => LOW, HYST => LOW);

	inpad_R_start : BD2SCARUDQP_1V8_SF_LIN
		port map( IO => i_R_start, ZI => i_R_start_pad, A => LOW, EN => HIGH, TA => LOW,
				TEN => HIGH, TM => LOW, PUN => HIGH, PDN => LOW, HYST => LOW);

	inpad_L_sample : BD2SCARUDQP_1V8_SF_LIN
		port map( IO => i_L_sample, ZI => i_L_sample_pad, A => LOW, EN => HIGH, TA => LOW,
				TEN => HIGH, TM => LOW, PUN => HIGH, PDN => LOW, HYST => LOW);
	
	inpad_R_sample : BD2SCARUDQP_1V8_SF_LIN
		port map( IO => i_R_sample, ZI => i_R_sample_pad, A => LOW, EN => HIGH, TA => LOW,
				TEN => HIGH, TM => LOW, PUN => HIGH, PDN => LOW, HYST => LOW);

	-- check directions of signals
	outpad_L_done : BD2SCARUDQP_1V8_SF_LIN
		port map(IO => o_L_done_pad, ZI => o_L_done, A => LOW, EN => LOW, TA => LOW,
				TEN => LOW, TM => LOW, PUN => HIGH, PDN => LOW, HYST => LOW);
	
	-- check directions of signals
	outpad_R_done : BD2SCARUDQP_1V8_SF_LIN
		port map(IO => o_R_done_pad, ZI => o_R_done, A => LOW, EN => LOW, TA => LOW,
				TEN => LOW, TM => LOW, PUN => HIGH, PDN => LOW, HYST => LOW);

	-- check directions of signals				
	outpad_L_sample : BD2SCARUDQP_1V8_SF_LIN
		port map(IO => o_L_sample_pad, ZI => o_L_sample, A => LOW, EN => LOW, TA => LOW,
				TEN => LOW, TM => LOW, PUN => HIGH, PDN => LOW, HYST => LOW);
				
	-- check directions of signals
	outpad_R_sample : BD2SCARUDQP_1V8_SF_LIN
		port map(IO => o_R_sample_pad, ZI => o_R_sample, A => LOW, EN => LOW, TA => LOW,
				TEN => LOW, TM => LOW, PUN => HIGH, PDN => LOW, HYST => LOW);
				

----------------------------------------------------------------------------------
-- GAIN LOOKUP-TABLE
----------------------------------------------------------------------------------				
	gain_lut_inst : gain_lut
		port map (
			clk			=> clk_pad,
			rstn		=> rstn_pad,
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
	L_agc_inst : agc
		port map (
			clk 			=> clk_pad,
			rstn 			=> rstn_pad,
			i_sample 		=> i_L_sample_pad,
			i_start 		=> i_L_start_pad,
			i_gain 			=> L_gain_lut_agc,
			o_gain_fetch 	=> L_fetch_agc_lut,
			o_power 		=> L_power_agc_lut,
			o_sample 		=> o_L_sample_pad,
			o_done			=> o_L_done_pad
			);
			
----------------------------------------------------------------------------------
-- RIGHT CHANNEL
----------------------------------------------------------------------------------
	R_agc_inst : agc
		port map (
			clk 			=> clk_pad,
			rstn 			=> rstn_pad,
			i_sample 		=> i_R_sample_pad,
			i_start 		=> i_R_start_pad,
			i_gain 			=> R_gain_lut_agc,
			o_gain_fetch 	=> R_fetch_agc_lut,
			o_power 		=> R_power_agc_lut,
			o_sample 		=> o_R_sample_pad,
			o_done			=> o_R_done_pad
			);

end Behavioral;