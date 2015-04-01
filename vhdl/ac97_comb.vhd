----------------------------------------------------------------------------------
-- Engineer: 		Niklas Aldén
-- 
-- Create Date:    	09:54:51 03/20/2015 
-- Module Name:    	ac97_comb - Behavioral 
-- Project Name: 	Hardware implementation of AGC for active hearing protectors
-- Description: 	Master Thesis
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ac97_comb is
    Port ( clk 				: in std_logic; 					-- clock
           rstn 			: in std_logic; 					-- reset, active low
           i_ac97_ctrl_ready : in std_logic; 					-- controller ready for new control register address and data
           i_volume 		: in std_logic_vector(4 downto 0); 	-- volume, set by user
           o_cmd_addr 		: out std_logic_vector(7 downto 0); -- codec control register address
           o_cmd_data 		: out std_logic_vector(15 downto 0) -- codec control register data
		   );
end ac97_comb;

architecture Behavioral of ac97_comb is

	signal cmd_c, cmd_n : std_logic_vector(23 downto 0) := (others => '0'); -- address and data
	signal attenuation 	: std_logic_vector(4 downto 0) := (others => '0'); -- attenuation for headphone output

	type state_type is (HP_VOL, MIC_VOL, OUT_VOL, REC_SEL, REC_GAIN, DAC_RATE, ADC_RATE, MIC_2CH); -- states for FSM
	signal state_c, state_n : state_type := HP_VOL;
	
begin

	o_cmd_addr 	<= cmd_c(23 downto 16); -- address output
	o_cmd_data 	<= cmd_c(15 downto 0); -- data output
	attenuation <= std_logic_vector(31 - unsigned(i_volume)); -- turn volume into attenuation


-- clock process
----------------------------------------------------------------------------------
clk_proc : process(clk, rstn) is
begin
	if rstn = '0' then
		state_c <= HP_VOL;
		cmd_c 	<= (others => '0');
	elsif rising_edge(clk) then
		cmd_c 	<= cmd_n;
		if i_ac97_ctrl_ready = '1' then -- update state when triggered by controller
			state_c <= state_n;
		end if;
	end if;
end process;


-- FSM for selecting control register address and data
----------------------------------------------------------------------------------
fsm_proc : process(state_c, attenuation, cmd_c) is
begin
	case state_c is
		
		-- reg 0x04 HEADPHONE VOLUME
		when HP_VOL =>
			cmd_n 	<= x"04" & "000" & attenuation & "000" & attenuation; -- headphone volume
			state_n <= MIC_VOL;
		
		-- reg 0x0E MICROPHONE VOLUME (TO MIXER), PRE AMP GAIN
		when MIC_VOL =>
--			cmd_n 	<= x"0E_0008"; -- MIC volume = 0dB, no MIC GAIN
--			cmd_n 	<= x"0E_8048"; -- MIC volume = 0dB, 20dB MIC GAIN, MUTED to mixer
			cmd_n 	<= x"0E_8008"; -- MIC volume = 0dB, no MIC GAIN, MUTED to mixer
			state_n <= OUT_VOL;
		
		-- reg 0x18 PCM-OUT VOLUME (FROM DAC)
		when OUT_VOL =>
			cmd_n 	<= x"18_0808"; -- PCM out volume = 0dB
--			cmd_n 	<= x"18_1F1F"; -- PCM out volume = -34.5dB
			state_n <= REC_SEL;
		
		-- reg 0x1A RECORD SELECT 
		when REC_SEL => 
			cmd_n 	<= x"1A_0000"; -- record select = MIC
			state_n <= REC_GAIN;
		
		-- reg 0x1C RECORD GAIN 
		when REC_GAIN =>
--			cmd_n <= x"1C_0F0F"; -- record gain = 22.5dB
			cmd_n 	<= x"1C_0000"; -- record gain = 0dB
			state_n <= DAC_RATE;
		
		-- reg 0x2C PCM FRONT DAC SAMPLE RATE 
		when DAC_RATE =>
			cmd_n 	<= x"2C_BB80"; -- PCM DAC sample rate, 0xBB80 = 48kHz
--			cmd_n 	<= x"2C_1F40"; -- PCM DAC sample rate, 0x1F40 = 8kHz
			state_n <= ADC_RATE;
		
		-- reg 0x32 PCM ADC SAMPLE RATE 
		when ADC_RATE =>
			cmd_n 	<= x"32_BB80"; -- PCM ADC sample rate, 0xBB80 = 48kHz
--			cmd_n 	<= x"32_1F40"; -- PCM ADC sample rate, 0x1F40 = 8kHz
			state_n <= MIC_2CH;
		
		-- reg 0x76 MISCELLANEOUS CONTROL BIT REGISTER
		when MIC_2CH =>
			cmd_n 	<= x"76_0240"; -- DAC to MIXER muted, stereo microphone input, MIC GAIN = 20dB if enabled
			state_n <= HP_VOL;
		
		when others =>
			cmd_n 	<= cmd_c;
			state_n <= state_c;
			
	end case;
end process;
			
end Behavioral;

