----------------------------------------------------------------------------------
-- Engineer: 		Niklas Aldén
-- 
-- Create Date:    	12:15:31 03/20/2015 
-- Module Name:    	ac97_ctrl - Behavioral 
-- Project Name: 	Hardware implementation of AGC for active hearing protectors
-- Description: 	Master Thesis
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ac97_ctrl is
    Port ( 	clk 				: in std_logic; 						-- clock
			rstn 				: in std_logic; 						-- reset, active low
			i_ac97_sdata_in 	: in std_logic; 						-- input data from codec
			o_ac97_sdata_out 	: out std_logic;						-- output data to codec
			o_ac97_sync 		: out std_logic; 						-- sync signal to codec
			i_ac97_bit_clk 		: in std_logic; 						-- 12.288 MHz clock from codec
			i_falling_bit_clk 	: in std_logic;							-- clock that's high on falling edges of bit_clk
			o_ac97_rstn 		: out std_logic; 						-- ac97 codec reset, active low
			o_ac97_ctrl_ready 	: out std_logic; 						-- ready for new register address and data
			i_L_from_AGC 		: in std_logic_vector(15 downto 0); 	-- L channel data from AGC
			i_R_from_AGC 		: in std_logic_vector(15 downto 0); 	-- R channel data from AGC
			o_L_to_AGC 			: out std_logic_vector(15 downto 0); 	-- L channel data from ADC to send to AGC
			o_R_to_AGC 			: out std_logic_vector(15 downto 0); 	-- R channel data from ADC to send to AGC
			o_L_AGC_ready 		: out std_logic; 						-- L channel data ready for AGC
			o_R_AGC_ready 		: out std_logic; 						-- R channel data ready for AGC
			i_cmd_addr 			: in std_logic_vector(7 downto 0); 		-- register address 
			i_cmd_data 			: in std_logic_vector(15 downto 0) 		-- register data
			);
end ac97_ctrl;

architecture Behavioral of ac97_ctrl is

	signal Q1, Q2 				: std_logic := '0'; 						-- signals to set "o_ac97_ctrl_ready" and "o_L/R_AGC_ready"
	signal bit_cnt_c, bit_cnt_n : unsigned(7 downto 0) := (others => '0'); 	-- counter for aligning slots
	signal reset_cnt 			: integer range 0 to 101 := 0; 				-- counter to delay ac97_reset
	
	-- signals to latch in/out data
	signal latch_cmd_addr 		: std_logic_vector(19 downto 0) := (others => '0'); -- codec register address
	signal latch_cmd_data   	: std_logic_vector(19 downto 0) := (others => '0'); -- codec register data
	signal latch_left_data		: std_logic_vector(19 downto 0) := (others => '0'); -- left channel data to DAC
	signal latch_right_data 	: std_logic_vector(19 downto 0) := (others => '0'); -- right channel data to DAC
	signal left_in_data  		: std_logic_vector(19 downto 0) := (others => '0'); -- left channel data from ADC
	signal right_in_data 		: std_logic_vector(19 downto 0) := (others => '0'); -- right channel data from ADC

begin


-- set delay of "o_ac97_reset" signal
----------------------------------------------------------------------------------
clk_proc : process(clk, rstn) is
begin
	if rising_edge(clk) then
		bit_cnt_c <= bit_cnt_n;
		reset_cnt <= reset_cnt + 1; -- increase reset counter
		if rstn = '0' then
			bit_cnt_c 	<= (others => '0');
			reset_cnt 	<= 0;
			o_ac97_rstn <= '0';
		elsif reset_cnt = 100 then 	-- 100 ~ 1µs @ 100MHz, COLD RESET
			reset_cnt 	<= 0;
			o_ac97_rstn <= '1';
		end if;
	end if;
end process;


-- set "o_ac97_ctrl_ready" (for new register address and register data) and 
-- "o_L/R_AGC_ready" (left + right channel ADC data is read) when all used slots are read/sent
----------------------------------------------------------------------------------
ctrl_ready_proc : process(clk, rstn, bit_cnt_c) is
begin
	if rising_edge(clk) then
		Q2 <= Q1;
		if bit_cnt_c = 0 then
			Q1 <= '0';
			Q2 <= '0';
		elsif bit_cnt_c >= 100 then 			-- control register data and left + right channel data are sent/read before bit 100 of the frame
			Q1 <= '1';
		end if;
		o_ac97_ctrl_ready 	<= Q1 and not Q2; 	-- ready signal for new register data from the combinatorial FSM
		o_L_AGC_ready 		<= Q1 and not Q2; 	-- send start signal for left AGC when all data is read
		o_R_AGC_ready 		<= Q1 and not Q2; 	-- send start signal for right AGC when all data is read
	end if;
end process;


-- shift out data from controller to codec
----------------------------------------------------------------------------------
out_frame_proc : process(i_ac97_bit_clk, rstn, bit_cnt_c) is
begin
	if rstn = '0' then
		bit_cnt_n <= (others => '0');

	elsif rising_edge(i_ac97_bit_clk) then
		bit_cnt_n <= bit_cnt_c + 1; -- increase bit counter
		
		if bit_cnt_c = 255 then 	-- set "o_ac97_sync" high one clock cycle before the next frame
			o_ac97_sync <= '1';
		end if;
		
		if bit_cnt_c = 15 then 		-- lower "o_ac97_sync" one clock cycle before slot 1 begins
			o_ac97_sync <= '0';
		end if;

		----------------------------------
		-- send one bit to codec each bit_clock cycle
		----------------------------------	
		if bit_cnt_c = 255 then -- latch in new data before the next frame begins
			-- concatenate to 20 bits for 8 bit address and 16 bit data
			latch_cmd_addr 		<= i_cmd_addr & x"000";
			latch_cmd_data 		<= i_cmd_data & x"0";
			latch_left_data 	<= i_L_from_AGC & x"0";
			latch_right_data 	<= i_R_from_AGC & x"0";
		end if;
		
		-- SLOT 0 : tag phase
		if (bit_cnt_c >= 0) and (bit_cnt_c <= 15) then 	-- bit count 0 to 15		
			case bit_cnt_c is
				when x"00" => o_ac97_sdata_out <= '1'; 	-- valid frame
				when x"01" => o_ac97_sdata_out <= '1'; 	-- vaild register control address
				when x"02" => o_ac97_sdata_out <= '1'; 	-- valid register control data
				when x"03" => o_ac97_sdata_out <= '1'; 	-- valid left PCM data
				when x"04" => o_ac97_sdata_out <= '1'; 	-- valid right PCM data
				when others => o_ac97_sdata_out <= '0'; -- remaining slots are invalid
			end case;
		
		-- SLOT 1 : send codec control register address
		elsif (bit_cnt_c >= 16) and (bit_cnt_c <= 35) then 	-- bit count 16 to 35
			o_ac97_sdata_out <= latch_cmd_addr(35 - to_integer(bit_cnt_c));
		
		-- SLOT 2 : send codec control register data
		elsif (bit_cnt_c >= 36) and (bit_cnt_c <= 55) then 	-- bit count 36 to 55
			o_ac97_sdata_out <= latch_cmd_data(55 - to_integer(bit_cnt_c));
		
		-- SLOT 3 : left channel data to DAC
		elsif (bit_cnt_c >= 56) and (bit_cnt_c <= 75) then 	-- bit count 56 to 75
			o_ac97_sdata_out <= latch_left_data(75 - to_integer(bit_cnt_c));
		
		-- SLOT 4 : right channel  data to DAC
		elsif (bit_cnt_c >= 76) and (bit_cnt_c <= 95) then 	-- bit count 76 to 95
			o_ac97_sdata_out <= latch_right_data(95 - to_integer(bit_cnt_c));
		
		-- Remaining slots, no data
		else
			o_ac97_sdata_out <= '0';
			
		end if;
		
		----------------------------------		
		-- send the 16 most significant bits (16 bit ADC) to the AGC 
		----------------------------------
		o_L_to_AGC <= left_in_data(19 downto 4); 
		o_R_to_AGC <= right_in_data(19 downto 4); 
		
	end if;	
end process;


-- shift in and concatenate left and right channel data from codec (ADC)
----------------------------------------------------------------------------------
in_frame_proc : process(i_falling_bit_clk) is
begin
	-- clock on falling edge of bit_clk
	if rising_edge(i_falling_bit_clk) then
	
		-- Slot 3 : left channel data from ADC
		if (bit_cnt_c >= 57) and (bit_cnt_c <= 76) then 	-- bit count 56 to 75
			left_in_data <= left_in_data(18 downto 0) & i_ac97_sdata_in; 

		-- Slot 4 : right channel data from ADC
		elsif (bit_cnt_c >= 77) and (bit_cnt_c <= 96) then 	-- bit count 76 to 95
			right_in_data <= right_in_data(18 downto 0) & i_ac97_sdata_in;
			
		end if;
		
	end if;
end process;
	
end Behavioral;