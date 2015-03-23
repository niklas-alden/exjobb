----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Niklas Aldén
-- 
-- Create Date:    17:24:04 03/11/2015 
-- Design Name: 
-- Module Name:    agc_top - Behavioral 
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

entity agc_top is
	Port ( clk : in  STD_LOGIC;
			 rstn : in  STD_LOGIC;
			 i_sample : in  STD_LOGIC_VECTOR (15 downto 0);
			 i_start : in std_logic;
			 o_sample : out  STD_LOGIC_VECTOR (15 downto 0);
			 o_done : out std_logic
			);
end agc_top;

architecture Behavioral of agc_top is

	component agc
		Port (clk : in  STD_LOGIC;
				rstn : in  STD_LOGIC;
				i_sample : in  STD_LOGIC_VECTOR (15 downto 0);
				i_gain : in  STD_LOGIC_VECTOR (15 downto 0);
				i_start : in std_logic;
				o_power : out  STD_LOGIC_VECTOR (7 downto 0);
				o_sample : out  STD_LOGIC_VECTOR (15 downto 0);
				o_done : out std_logic
				);
	end component;

	component gain_lut 
		Port (i_dB : in  STD_LOGIC_VECTOR (7 downto 0);
				o_gain : out  STD_LOGIC_VECTOR (15 downto 0)
				);
	end component;


	signal P_agc_lut : std_logic_vector(7 downto 0);
	signal gain_lut_agc : std_logic_vector(15 downto 0);
	

begin

	agc_inst : agc
		port map (
			clk => clk,
			rstn => rstn,
			i_sample => i_sample,
			i_start => i_start,
			i_gain => gain_lut_agc,
			o_power => P_agc_lut,
			o_sample => o_sample,
			o_done => o_done
			);
			
	gain_lut_inst : gain_lut
		port map (
			i_dB => P_agc_lut,
			o_gain => gain_lut_agc
			);


end Behavioral;

