----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:15:31 03/20/2015 
-- Design Name: 
-- Module Name:    ac97_ctrl - Behavioral 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ac97_ctrl is
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
           
		   i_latching_cmd : in  STD_LOGIC;
           i_cmd_addr : in  STD_LOGIC_VECTOR(7 downto 0);-- cmd address coming in from ac97cmd state machine
           i_cmd_data : in  STD_LOGIC_VECTOR(15 downto 0)-- cmd data coming in from ac97cmd state machine
		   );
end ac97_ctrl;

architecture Behavioral of ac97_ctrl is

	signal Q1, Q2 : std_logic := '0';-- signals to deliver one cycle pulse at specified time
	signal bit_cnt_c, bit_cnt_n : unsigned(7 downto 0) := (others => '0');-- counter for aligning slots
	signal reset_cnt : integer range 0 to 4095 := 0;-- counter to set ac97_reset high for ac97 init
	
	signal latch_cmd_addr : std_logic_vector(19 downto 0) := (others => '0');-- signals to latch in registers and commands
	signal latch_cmd_data   : std_logic_vector(19 downto 0) := (others => '0');

	signal latch_left_data	: std_logic_vector(19 downto 0) := (others => '0');
	signal latch_right_data : std_logic_vector(19 downto 0) := (others => '0');

	signal left_data     	: std_logic_vector(19 downto 0) := (others => '0');
	signal right_data    	: std_logic_vector(19 downto 0) := (others => '0');
	signal left_in_data  	: std_logic_vector(19 downto 0) := (others => '0');
	signal right_in_data 	: std_logic_vector(19 downto 0) := (others => '0');

begin

-- concat for 18 bit usage can concat further for 16 bit use 
	-- by using <& "0000"> and <left_in_data(19 downto 4)>
	-------------------------------------------------------------------------------------
	left_data  <= i_L_from_AGC & "0000";
	right_data <= i_R_from_AGC & "0000";

--	o_L_DAC <= left_in_data(19 downto 0);
--	o_R_DAC <= right_in_data(19 downto 0);
	

	-- Delay for ac97_reset signal, clk = 100MHz
	-- delay 37.89 us / 10 ns = 3789 for active low reset on init 
	--------------------------------------------------------------------------------------
clk_proc : process(clk, rstn) is
begin
	if rising_edge(clk) then
		bit_cnt_c <= bit_cnt_n;
		if rstn = '0' then
			bit_cnt_c <= (others => '0');
			reset_cnt <= 0;
			o_ac97_rstn <= '0';
		elsif reset_cnt = 3789 then
			reset_cnt <= 0;
			o_ac97_rstn <= '1';
		else
			reset_cnt <= reset_cnt + 1;
			o_ac97_rstn <= '1';
		end if;
	end if;
end process;


ctrl_ready_proc : process(clk, rstn, bit_cnt_c) is
begin
	if rising_edge(clk) then
		Q2 <= Q1;
		if bit_cnt_c = 0 then
			Q1 <= '0';
			Q2 <= '0';
		elsif bit_cnt_c >= 129 then
			Q1 <= '1';
		end if;
		o_ac97_ctrl_ready <= Q1 and not Q2;
	end if;
end process;


out_frame_proc : process(i_ac97_bit_clk, rstn, bit_cnt_c) is
begin
	
	if rstn = '0' then
		bit_cnt_n <= (others => '0');

	elsif rising_edge(i_ac97_bit_clk) then
		---o_ac97_sync <= '0';
		bit_cnt_n <= bit_cnt_c + 1;
		
		if bit_cnt_c = 255 then
			o_ac97_sync <= '1';
		end if;
		
		if bit_cnt_c = 15 then
			o_ac97_sync <= '0';
		end if;
	
		if bit_cnt_c = 255 then
			latch_cmd_addr <= i_cmd_addr & x"000";
			latch_cmd_data <= i_cmd_data & x"0";
			latch_left_data <= left_data;
			latch_right_data <= right_data;
		end if;
		
		-- TAG PHASE
		if (bit_cnt_c >= 0) and (bit_cnt_c <= 15) then -- bit count 0 to 15		
			-- Slot 0 : Tag Phase
			case bit_cnt_c is
				when x"00" => o_ac97_sdata_out <= '1';-- AC Link Interface ready
				when x"01" => o_ac97_sdata_out <= i_latching_cmd;-- Vaild Status Adress or Slot request
				when x"02" => o_ac97_sdata_out <= '1';-- Valid Status data
				when x"03" => o_ac97_sdata_out <= '1';-- Valid PCM Data (Left ADC)
				when x"04" => o_ac97_sdata_out <= '1';-- Valid PCM Data (Right ADC)
				when others => o_ac97_sdata_out <= '0';
			end case;
		
		elsif (bit_cnt_c >= 16) and (bit_cnt_c <= 35) then -- bit count 16 to 35
			-- Slot 1 : Command address (8-bits, left justified)
			if i_latching_cmd = '1' then
				o_ac97_sdata_out <= latch_cmd_addr(35 - to_integer(bit_cnt_c));
			else
				o_ac97_sdata_out <= '0';
			end if;
			
		elsif (bit_cnt_c >= 36) and (bit_cnt_c <= 55) then -- bit count 36 to 55
			-- Slot 2 : Command data (16-bits, left justified)
			if i_latching_cmd = '1' then
				o_ac97_sdata_out <= latch_cmd_data(55 - to_integer(bit_cnt_c));
			else
				o_ac97_sdata_out <= '0';
			end if;
		
		elsif (bit_cnt_c >= 56) and (bit_cnt_c <= 75) then -- bit count 56 to 75
			-- Slot 3 : left channel
			o_ac97_sdata_out <= latch_left_data(19);
			latch_left_data <= latch_left_data(18 downto 0) &  latch_left_data(19);
			
		elsif (bit_cnt_c >= 76) and (bit_cnt_c <= 95) then -- bit count 76 to 95
			-- Slot 4 : right channel
			o_ac97_sdata_out <= latch_right_data(95 - to_integer(bit_cnt_c));
		
		else
			o_ac97_sdata_out <= '0';
		end if;
		
	end if;	
	
end process;


in_frame_proc : process(i_ac97_bit_clk) is
begin
	-- clock on falling edge of bitclk
	if falling_edge(i_ac97_bit_clk) then
		if (bit_cnt_c >= 56) and (bit_cnt_c <= 75) then -- from 57 to 76
			-- Slot 3 : left channel
			left_in_data <= left_in_data(18 downto 0) & i_ac97_sdata_in; -- concat incoming bits on end

		elsif (bit_cnt_c >= 76) and (bit_cnt_c <= 95) then -- from 77 to 96
			-- Slot 4 : right channel
			right_in_data <= right_in_data(18 downto 0) & i_ac97_sdata_in; -- concat incoming bits on end
		end if;
	end if;
end process;


send_to_agc_proc : process(i_ac97_bit_clk) is
begin

	if rising_edge(i_ac97_bit_clk) then
		o_L_to_AGC <= left_in_data(19 downto 0);
		o_R_to_AGC <= right_in_data(19 downto 0);
		
		if bit_cnt_c = 96 then
			o_AGC_ready <= '1';
		else
--			o_L_to_AGC <= (others => '0');
--			o_R_to_AGC <= (others => '0');
			o_AGC_ready <= '0';
		end if;
	end if;
	
end process;
	
end Behavioral;