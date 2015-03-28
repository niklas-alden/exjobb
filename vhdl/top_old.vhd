----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:22:37 03/25/2015 
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

component filtered_agc_top is
    Port ( clk : in  STD_LOGIC;
           rstn : in  STD_LOGIC;
           i_sample : in  STD_LOGIC_VECTOR (15 downto 0);
		   i_start : in std_logic;
           o_sample : out  STD_LOGIC_VECTOR (15 downto 0);
		   o_done : out std_logic
		   );
end component;

component ac97_top is
    Port ( clk : in  STD_LOGIC;
           rstn : in  STD_LOGIC;
           i_volume : in  STD_LOGIC_VECTOR (4 downto 0);
           i_sdata_in : in  STD_LOGIC;
           o_sdata_out : out  STD_LOGIC;
           o_sync : out  STD_LOGIC;
           o_ac97_rstn : out  STD_LOGIC;
           i_bit_clk : in  STD_LOGIC;
		   i_L_from_AGC : in  STD_LOGIC_VECTOR (15 downto 0);-- lt chan output from AGC
           i_R_from_AGC : in  STD_LOGIC_VECTOR (15 downto 0);-- rt chan output from AGC
		   o_L_to_AGC : out  STD_LOGIC_VECTOR (15 downto 0);-- L channel input from ADC to send to AGC
           o_R_to_AGC : out  STD_LOGIC_VECTOR (15 downto 0);-- R channel input from ADC to send to AGC
		   o_L_AGC_start : out STD_LOGIC; -- L data ready for AGC
		   o_R_AGC_start : out STD_LOGIC -- R data ready for AGC
		   );
end component;

	signal L_sample_ac97_agc, L_sample_agc_ac97 : std_logic_vector(15 downto 0);
	signal R_sample_ac97_agc, R_sample_agc_ac97 : std_logic_vector(15 downto 0);
	signal L_start_ac97_agc : std_logic;
	signal R_start_ac97_agc : std_logic;

begin

	agc_L_inst : filtered_agc_top
		port map (
			clk			=> clk,
			rstn		=> rstn,
			i_sample	=> L_sample_ac97_agc, 
			i_start		=> L_start_ac97_agc,
			o_sample	=> L_sample_agc_ac97
			);
			
	agc_R_inst : filtered_agc_top
		port map (
			clk			=> clk,
			rstn		=> rstn,
			i_sample	=> R_sample_ac97_agc, 
			i_start		=> R_start_ac97_agc,
			o_sample	=> R_sample_agc_ac97
			);

	ac97_inst : ac97_top
		port map (
			clk 		=> clk,
			rstn 		=> rstn,
			i_volume 	=> i_volume,
			i_sdata_in 	=> i_SDATA_IN,
			o_sdata_out => o_SDATA_OUT,
			o_sync 		=> o_SYNC,
			o_ac97_rstn => o_RSTN,
			i_bit_clk 	=> i_BIT_CLK,
			i_L_from_AGC => L_sample_agc_ac97,
			i_R_from_AGC => R_sample_agc_ac97,
			o_L_to_AGC 	=> L_sample_ac97_agc,
			o_R_to_AGC 	=> R_sample_ac97_agc,
			o_L_AGC_start => L_start_ac97_agc,
			o_R_AGC_start => R_start_ac97_agc
			);


end Behavioral;

