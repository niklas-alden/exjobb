----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Niklas Ald�n
-- 
-- Create Date:    09:54:51 03/20/2015 
-- Design Name: 
-- Module Name:    ac97_comb - Behavioral 
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

entity ac97_comb is
    Port ( clk : in  STD_LOGIC;
           rstn : in  STD_LOGIC;
           i_ac97_ctrl_ready : in  STD_LOGIC;
           i_volume : in  STD_LOGIC_VECTOR (4 downto 0);
           o_cmd_addr : out  STD_LOGIC_VECTOR (7 downto 0);
           o_cmd_data : out  STD_LOGIC_VECTOR (15 downto 0)--;
--           o_latching_cmd : out  STD_LOGIC
		   );
end ac97_comb;

architecture Behavioral of ac97_comb is

	signal cmd_c, cmd_n : std_logic_vector(23 downto 0) := (others => '0');
	signal attenuation : std_logic_vector(4 downto 0) := (others => '0');
	
	type state_type is (HP_VOL, MIC_VOL, OUT_VOL, REC_SEL, REC_GAIN, DAC_RATE, ADC_RATE, MIC_2CH);
	signal state_c, state_n : state_type := HP_VOL;
	
begin

	o_cmd_addr <= cmd_c(23 downto 16);
	o_cmd_data <= cmd_c(15 downto 0);
	attenuation <= std_logic_vector(31 - unsigned(i_volume));
	
--	with cmd_c(23 downto 16) select
--		o_latching_cmd <=
--			'1' when 	x"02" | x"04"  | x"0E" | x"10" | x"18" | x"1A" | x"1C" | x"2C" | x"32" | x"76" | x"20",
--			'0' when others;
	
	
clk_proc : process(clk, rstn) is
begin

	if rstn = '0' then
		state_c <= HP_VOL;
		cmd_c <= (others => '0');
	elsif rising_edge(clk) then
		if i_ac97_ctrl_ready = '1' then
			state_c <= state_n;
		end if;
		cmd_c <= cmd_n;
	end if;
	
end process;


fsm_proc : process(state_c, attenuation, cmd_c) is
begin

	case state_c is
		when HP_VOL =>
			cmd_n <= x"04" & "000" & attenuation & "000" & attenuation; -- headphone volume
			state_n <= MIC_VOL;
		when MIC_VOL =>
--			cmd_n <= x"0E_0008"; -- MIC volume = 0dB, no MIC GAIN
--			cmd_n <= x"0E_8048"; -- MIC volume = 0dB, 20dB MIC GAIN, MUTED to mixer
			cmd_n <= x"0E_8008"; -- MIC volume = 0dB, no MIC GAIN, MUTED to mixer
			state_n <= OUT_VOL;
		when OUT_VOL =>
			cmd_n <= x"18_0808"; -- PCM out volume = 0dB
--			cmd_n <= x"18_1F1F"; -- PCM out volume = -34.5dB
			state_n <= REC_SEL;
		when REC_SEL => 
			cmd_n <= x"1A_0000"; -- record select = MIC
			state_n <= REC_GAIN;
		when REC_GAIN =>
			--cmd_n <= x"1C_0F0F"; -- record gain = 22.5dB
			cmd_n <= x"1C_0000"; -- record gain = 0dB
			state_n <= DAC_RATE;
		when DAC_RATE =>
			cmd_n <= x"2C_BB80"; -- PCM DAC sample rate, 0xBB80 = 48kHz
--			cmd_n <= x"2C_1F40"; -- PCM DAC sample rate, 0x1F40 = 8kHz
			state_n <= ADC_RATE;
		when ADC_RATE =>
			cmd_n <= x"32_BB80"; -- PCM ADC sample rate, 0xBB80 = 48kHz
--			cmd_n <= x"32_1F40"; -- PCM ADC sample rate, 0x1F40 = 8kHz
			state_n <= MIC_2CH;
		when MIC_2CH =>
			cmd_n <= x"76_0240"; -- DAC to MIXER muted, stereo microphone input, MIC GAIN = 20dB if enabled
			state_n <= HP_VOL;
		when others =>
			cmd_n <= cmd_c;
			state_n <= state_c;
	end case;
	
end process;
			
end Behavioral;

