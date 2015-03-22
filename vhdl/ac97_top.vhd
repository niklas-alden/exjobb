----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Niklas Aldén
-- 
-- Create Date:    17:12:17 03/20/2015 
-- Design Name: 
-- Module Name:    ac97_top - Behavioral 
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

entity ac97_top is
    Port ( clk : in  STD_LOGIC;
           rstn : in  STD_LOGIC;
           i_volume : in  STD_LOGIC_VECTOR (4 downto 0);
           i_sdata_in : in  STD_LOGIC;
           o_sdata_out : out  STD_LOGIC;
           o_sync : out  STD_LOGIC;
           o_ac97_rstn : out  STD_LOGIC;
           i_bit_clk : in  STD_LOGIC;
		   
		   i_L_AGC : in  STD_LOGIC_VECTOR (15 downto 0);-- lt chan output from AGC
           i_R_AGC : in  STD_LOGIC_VECTOR (15 downto 0);-- rt chan output from AGC
		   o_L_AGC : out  STD_LOGIC_VECTOR (19 downto 0);-- L channel input from ADC to send to AGC
           o_R_AGC : out  STD_LOGIC_VECTOR (19 downto 0);-- R channel input from ADC to send to AGC
		   o_AGC_start : out STD_LOGIC -- L/R data ready for AGC
		   
--		   i_L_from_ADC : in STD_LOGIC_VECTOR(15 downto 0);
--		   i_R_from_ADC : in STD_LOGIC_VECTOR(15 downto 0);
--		   o_L_to_DAC : out STD_LOGIC_VECTOR(19 downto 0);
--		   o_R_to_DAC : out STD_LOGIC_VECTOR(19 downto 0)
		   );
end ac97_top;

architecture Behavioral of ac97_top is


component ac97_comb is
    Port ( clk : in  STD_LOGIC;
           rstn : in  STD_LOGIC;
           i_ac97_ctrl_ready : in  STD_LOGIC;
           i_volume : in  STD_LOGIC_VECTOR (4 downto 0);
           o_cmd_addr : out  STD_LOGIC_VECTOR (7 downto 0);
           o_cmd_data : out  STD_LOGIC_VECTOR (15 downto 0);
           o_latching_cmd : out  STD_LOGIC
		   );
end component;


component ac97_ctrl is
    Port ( clk : in  STD_LOGIC;
           rstn : in  STD_LOGIC;
           i_ac97_sdata_in : in  STD_LOGIC;-- ac97 input from SDATA_IN
           o_ac97_sdata_out : out  STD_LOGIC;-- ac97 output to SDATA_OUT
           o_ac97_sync : out  STD_LOGIC;-- SYNC signal to ac97
           i_ac97_bit_clk : in  STD_LOGIC;-- 12.288 MHz clock from ac97
           o_ac97_rstn : out  STD_LOGIC;-- ac97 reset for initialization
           o_ac97_ctrl_ready : out  STD_LOGIC;-- pulse for one cycle
           
		   i_L_from_AGC : in  STD_LOGIC_VECTOR (15 downto 0);-- lt chan output from AGC
           i_R_from_AGC : in  STD_LOGIC_VECTOR (15 downto 0);-- rt chan output from ADC
           
		   o_L_to_AGC : out  STD_LOGIC_VECTOR (19 downto 0);-- lt chan input from ADC to send to AGC
           o_R_to_AGC : out  STD_LOGIC_VECTOR (19 downto 0);-- rt chan input to DAC
		   o_AGC_ready : out STD_LOGIC; -- L/R data ready for AGC
		   
--		   i_L_ADC : in  STD_LOGIC_VECTOR (15 downto 0);-- lt chan output from ADC
--           i_R_ADC : in  STD_LOGIC_VECTOR (15 downto 0);-- rt chan output from ADC
--           o_L_DAC : out  STD_LOGIC_VECTOR (19 downto 0);-- lt chan input to DAC
--           o_R_DAC : out  STD_LOGIC_VECTOR (19 downto 0);-- rt chan input to DAC
           i_latching_cmd : in  STD_LOGIC;
           i_cmd_addr : in  STD_LOGIC_VECTOR(7 downto 0);-- cmd address coming in from ac97cmd state machine
           i_cmd_data : in  STD_LOGIC_VECTOR(15 downto 0)-- cmd data coming in from ac97cmd state machine
		   );
end component;

	signal cmd_addr_comb_ctrl : std_logic_vector(7 downto 0);
	signal cmd_data_comb_ctrl : std_logic_vector(15 downto 0);
	signal latching_data_comb_ctrl : std_logic;
	signal ready_ctrl_comb : std_logic;
	signal L_bypass, R_bypass : std_logic_vector(19 downto 0);
	

begin

	ac97_comb_inst : ac97_comb
		port map (
			clk 				=> clk,
			rstn 				=> rstn,
			i_ac97_ctrl_ready 	=> ready_ctrl_comb,
			i_volume 			=> i_volume,
			o_cmd_addr 			=> cmd_addr_comb_ctrl,
			o_cmd_data 			=> cmd_data_comb_ctrl,
			o_latching_cmd 		=> latching_data_comb_ctrl
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
			
			i_L_from_AGC 		=> L_bypass(19 downto 4), --i_L_AGC,
			i_R_from_AGC 		=> R_bypass(19 downto 4), --i_R_AGC,
			o_L_to_AGC 			=> L_bypass, --o_L_AGC,
			o_R_to_AGC 			=> R_bypass, --o_R_AGC,
			o_AGC_ready 		=> o_AGC_start,
--			i_L_ADC 			=> i_L_from_ADC,
--			i_R_ADC 			=> i_R_from_ADC,
--			o_L_DAC 			=> o_L_to_DAC,
--			o_R_DAC 			=> o_R_to_DAC,
			i_latching_cmd 		=> latching_data_comb_ctrl,
			i_cmd_addr 			=> cmd_addr_comb_ctrl,
			i_cmd_data 			=> cmd_data_comb_ctrl
			);

end Behavioral;

