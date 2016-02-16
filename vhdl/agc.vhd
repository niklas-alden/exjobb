----------------------------------------------------------------------------------
-- Engineer: 		Niklas Aldn
-- 
-- Create Date:		20:09:18 03/10/2015 
-- Module Name:		agc - Behavioral 
-- Project Name: 	Hardware implementation of AGC for active hearing protectors
-- Description: 	Master Thesis
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity agc is
	Port ( clk 			: in std_logic;						-- clock
           rstn 		: in std_logic;						-- reset, active low
           i_sample 	: in std_logic_vector(15 downto 0);	-- input sample from equalizer filter
		   i_start 		: in std_logic;						-- start signal from equalizer filter
           i_gain 		: in std_logic_vector(14 downto 0);	-- gain fetched from LUT
           o_power 		: out std_logic_vector(7 downto 0);	-- sample power to LUT
		   o_gain_fetch : out std_logic;					-- enable signal for LUT
           o_sample 	: out std_logic_vector(15 downto 0)	-- output sample to AC97
	);
end agc;

architecture Behavioral of agc is

	-- time parameters
	constant alpha 						: unsigned(15 downto 0) := to_unsigned(768, 16); -- attack time
	constant beta 							: unsigned(15 downto 0) := to_unsigned(1, 16);  -- release time
	
	signal curr_sample_c, curr_sample_n 	: signed(15 downto 0) := (others => '0'); -- current input sample
	signal P_in_c, P_in_n 					: unsigned(31 downto 0) := (others => '0'); -- power of input sample
	
	signal P_weighted_c							: unsigned(31 downto 0) := (others => '0'); -- weighted power of input sample
	signal P_weighted_n							: unsigned(63 downto 0) := (others => '0'); -- weighted power of input sample
	signal P_weighted_prev_c, P_weighted_prev_n	: unsigned(31 downto 0) := (others => '0'); -- weighted power of input sample
	signal P_w_fast_c 							: unsigned(31 downto 0) := (others => '0'); -- weighted power of input sample
	signal P_w_fast_n							: unsigned(63 downto 0) := (others => '0'); -- weighted power of input sample
	signal P_w_fast_prev_c, P_w_fast_prev_n		: unsigned(31 downto 0) := (others => '0'); -- weighted power of input sample

	signal P_dB_c, P_dB_n 				: signed(7 downto 0) := (others => '0'); -- weighted power of input sample in decibel
	signal lut_delay_c, lut_delay_n 	: unsigned(0 downto 0) := (others => '0'); -- one bit delay counter for LUT look-up time	
	signal agc_out_c, agc_out_n			: signed(31 downto 0) := (others => '0'); -- attenuated sample
	
	type state_type is (HOLD, P_curr, P_W1, P_W2, P_W3, P_dB, FETCH_GAIN, GAIN, SEND); -- states for FSM
	signal state_c, state_n 			: state_type := HOLD;

begin

-- clock process
----------------------------------------------------------------------------------
clk_proc : process(clk, rstn) is
begin
	if rstn = '0' then
		state_c 		<= HOLD;
		P_in_c 			<= (others => '0');
		P_weighted_c 	<= (others => '0');
		P_weighted_prev_c 	<= (others => '0');
		P_w_fast_c 		<= (others => '0');
		P_w_fast_prev_c <= (others => '0');
		P_dB_c 			<= (others => '0');
		agc_out_c 		<= (others => '0');
		curr_sample_c 	<= (others => '0');
		lut_delay_c 	<= (others => '0');
	elsif rising_edge(clk) then
		state_c 		<= state_n;
		P_in_c 			<= P_in_n;
		P_weighted_c 	<= P_weighted_n(46 downto 15);
		P_weighted_prev_c 	<= P_weighted_prev_n;
		P_w_fast_c 		<= P_w_fast_n(46 downto 15);
		P_w_fast_prev_c <= P_w_fast_prev_n;
		P_dB_c 			<= P_dB_n;
		agc_out_c 		<= agc_out_n;
		curr_sample_c 	<= curr_sample_n;
		lut_delay_c 	<= lut_delay_n;
	end if;
end process;


-- FSM for AGC process
----------------------------------------------------------------------------------
power_proc : process(state_c, curr_sample_c, P_in_c, P_weighted_c, P_weighted_prev_c, P_w_fast_c, P_w_fast_prev_c, P_dB_c, agc_out_c, i_sample, i_start, i_gain, lut_delay_c) is
begin
	--default assignments
	state_n 		<= state_c;
	curr_sample_n 	<= curr_sample_c;
	P_in_n 			<= P_in_c;
	P_weighted_n 	<= '0' & x"0000" & P_weighted_c & x"000" & "000";
	P_weighted_prev_n 	<= P_weighted_prev_c;
	P_w_fast_n 		<= '0' & x"0000" & P_w_fast_c & x"000" & "000";
	P_w_fast_prev_n <= P_w_fast_prev_c;
	P_dB_n 			<= P_dB_c;
	agc_out_n 		<= agc_out_c;
	lut_delay_n 	<= lut_delay_c;
	o_sample 		<= std_logic_vector(agc_out_c(30 downto 15)); -- output sample
	o_power 		<= std_logic_vector(P_dB_n); -- output power to LUT
	o_gain_fetch 	<= '0'; -- don't enable LUT
	
	case state_c is
	
		-- wait for start signal until latching in input sample
		when HOLD =>
			if i_start = '1' then
				curr_sample_n 	<= signed(i_sample);
				state_n 		<= P_curr;
			end if;
		
		-- calculate power of current sample
		when P_curr =>
			P_in_n 	<= unsigned(abs(signed(curr_sample_c)) * abs(signed(curr_sample_c)));
			state_n <= P_W1;
		
		-- compare the power of the current sample against previous sample to determine increasing or decreasing power
		-- then weigh the power of the current sample against previous sample
		when P_W1 =>
			P_w_fast_n <= ((31999) * P_w_fast_prev_c) + (alpha * P_in_c); -- increasing power
			state_n <= P_W2;
			
		when P_W2 =>
			if P_w_fast_c > P_weighted_prev_c then
				P_weighted_n <= '0' & x"0000" & P_w_fast_c & x"000" & "000";
			else
				P_weighted_n <= '0' & x"0000" & P_weighted_prev_c & x"000" & "000";
			end if;
			state_n <= P_W3;
			
		when P_W3 =>
			if P_w_fast_prev_c >= P_w_fast_c then
				P_weighted_n <= ((32766) * P_weighted_c); -- decreasing power
			end if;
			state_n <= P_dB;
		
		-- convert the weighted power of the current sample to decibel
		when P_dB =>
		
			if unsigned(P_weighted_c) > x"69fe63f3" then -- >92.5dB
				P_dB_n <= to_signed(11, 8);
			elsif unsigned(P_weighted_c) > x"54319cc9" then -- >91.5dB
				P_dB_n <= to_signed(10, 8);
			elsif unsigned(P_weighted_c) > x"42e0a497" then -- >90.5dB
				P_dB_n <= to_signed(9, 8);
			elsif unsigned(P_weighted_c) > x"351f68fb" then -- >89.5dB
				P_dB_n <= to_signed(8, 8);
			elsif unsigned(P_weighted_c) > x"2a326539" then -- >88.5dB
				P_dB_n <= to_signed(7, 8);
			elsif unsigned(P_weighted_c) > x"2184a5ce" then -- >87.5dB
				P_dB_n <= to_signed(6, 8);
			elsif unsigned(P_weighted_c) > x"1a9fd9c9" then -- >86.5dB
				P_dB_n <= to_signed(5, 8);
			elsif unsigned(P_weighted_c) > x"152605ce" then -- >85.5dB
				P_dB_n <= to_signed(4, 8);
			elsif unsigned(P_weighted_c) > x"10cc82d6" then -- >84.5dB
				P_dB_n <= to_signed(3, 8);
			elsif unsigned(P_weighted_c) > x"d580472" then -- >83.5dB
				P_dB_n <= to_signed(2, 8);
			elsif unsigned(P_weighted_c) > x"a997066" then -- >82.5dB
				P_dB_n <= to_signed(1, 8);
			elsif unsigned(P_weighted_c) > x"86b5c7b" then -- >81.5dB
				P_dB_n <= to_signed(0, 8);
			elsif unsigned(P_weighted_c) > x"6b01076" then -- >80.5dB
				P_dB_n <= to_signed(-1, 8);
			elsif unsigned(P_weighted_c) > x"54ff0e6" then -- >79.5dB
				P_dB_n <= to_signed(-2, 8);
			elsif unsigned(P_weighted_c) > x"4383d53" then -- >78.5dB
				P_dB_n <= to_signed(-3, 8);
			elsif unsigned(P_weighted_c) > x"35a1095" then -- >77.5dB
				P_dB_n <= to_signed(-4, 8);
			elsif unsigned(P_weighted_c) > x"2a995c8" then -- >76.5dB
				P_dB_n <= to_signed(-5, 8);
			elsif unsigned(P_weighted_c) > x"21d66fb" then -- >75.5dB
				P_dB_n <= to_signed(-6, 8);
			elsif unsigned(P_weighted_c) > x"1ae0d16" then -- >74.5dB
				P_dB_n <= to_signed(-7, 8);
			elsif unsigned(P_weighted_c) > x"1559a0c" then -- >73.5dB
				P_dB_n <= to_signed(-8, 8);
			elsif unsigned(P_weighted_c) > x"10f580b" then -- >72.5dB
				P_dB_n <= to_signed(-9, 8);
			elsif unsigned(P_weighted_c) > x"d78940" then -- >71.5dB
				P_dB_n <= to_signed(-10, 8);
			elsif unsigned(P_weighted_c) > x"ab34d9" then -- >70.5dB
				P_dB_n <= to_signed(-11, 8);
			elsif unsigned(P_weighted_c) > x"87fe7e" then -- >69.5dB
				P_dB_n <= to_signed(-12, 8);
			elsif unsigned(P_weighted_c) > x"6c0622" then -- >68.5dB
				P_dB_n <= to_signed(-13, 8);
			elsif unsigned(P_weighted_c) > x"55ce76" then -- >67.5dB
				P_dB_n <= to_signed(-14, 8);
			elsif unsigned(P_weighted_c) > x"442894" then -- >66.5dB
				P_dB_n <= to_signed(-15, 8);
			elsif unsigned(P_weighted_c) > x"3623e6" then -- >65.5dB
				P_dB_n <= to_signed(-16, 8);
			elsif unsigned(P_weighted_c) > x"2b014f" then -- >64.5dB
				P_dB_n <= to_signed(-17, 8);
			elsif unsigned(P_weighted_c) > x"222902" then -- >63.5dB
				P_dB_n <= to_signed(-18, 8);
			elsif unsigned(P_weighted_c) > x"1b2268" then -- >62.5dB
				P_dB_n <= to_signed(-19, 8);
			elsif unsigned(P_weighted_c) > x"158dba" then -- >61.5dB
				P_dB_n <= to_signed(-20, 8);
			elsif unsigned(P_weighted_c) > x"111ee3" then -- >60.5dB
				P_dB_n <= to_signed(-21, 8);
			elsif unsigned(P_weighted_c) > x"d9973" then -- >59.5dB
				P_dB_n <= to_signed(-22, 8);
			elsif unsigned(P_weighted_c) > x"acd6a" then -- >58.5dB
				P_dB_n <= to_signed(-23, 8);
			elsif unsigned(P_weighted_c) > x"894a6" then -- >57.5dB
				P_dB_n <= to_signed(-24, 8);
			elsif unsigned(P_weighted_c) > x"6d0dc" then -- >56.5dB
				P_dB_n <= to_signed(-25, 8);
			elsif unsigned(P_weighted_c) > x"569fe" then -- >55.5dB
				P_dB_n <= to_signed(-26, 8);
			elsif unsigned(P_weighted_c) > x"44cef" then -- >54.5dB
				P_dB_n <= to_signed(-27, 8);
			elsif unsigned(P_weighted_c) > x"36a81" then -- >53.5dB
				P_dB_n <= to_signed(-28, 8);
			elsif unsigned(P_weighted_c) > x"2b6a4" then -- >52.5dB
				P_dB_n <= to_signed(-29, 8);
			elsif unsigned(P_weighted_c) > x"227c6" then -- >51.5dB
				P_dB_n <= to_signed(-30, 8);
			elsif unsigned(P_weighted_c) > x"1b64a" then -- >50.5dB
				P_dB_n <= to_signed(-31, 8);
			elsif unsigned(P_weighted_c) > x"15c26" then -- >49.5dB
				P_dB_n <= to_signed(-32, 8);
			elsif unsigned(P_weighted_c) > x"1148b" then -- >48.5dB
				P_dB_n <= to_signed(-33, 8);
			elsif unsigned(P_weighted_c) > x"dbab" then -- >47.5dB
				P_dB_n <= to_signed(-34, 8);
			elsif unsigned(P_weighted_c) > x"ae7d" then -- >46.5dB
				P_dB_n <= to_signed(-35, 8);
			elsif unsigned(P_weighted_c) > x"8a9a" then -- >45.5dB
				P_dB_n <= to_signed(-36, 8);
			elsif unsigned(P_weighted_c) > x"6e18" then -- >44.5dB
				P_dB_n <= to_signed(-37, 8);
			elsif unsigned(P_weighted_c) > x"5774" then -- >43.5dB
				P_dB_n <= to_signed(-38, 8);
			elsif unsigned(P_weighted_c) > x"4577" then -- >42.5dB
				P_dB_n <= to_signed(-39, 8);
			elsif unsigned(P_weighted_c) > x"372e" then -- >41.5dB
				P_dB_n <= to_signed(-40, 8);
			elsif unsigned(P_weighted_c) > x"2bd5" then -- >40.5dB
				P_dB_n <= to_signed(-41, 8);
			elsif unsigned(P_weighted_c) > x"22d1" then -- >39.5dB
				P_dB_n <= to_signed(-42, 8);
			elsif unsigned(P_weighted_c) > x"1ba8" then -- >38.5dB
				P_dB_n <= to_signed(-43, 8);
			elsif unsigned(P_weighted_c) > x"15f8" then -- >37.5dB
				P_dB_n <= to_signed(-44, 8);
			
			else									-- >=0dB
				P_dB_n <= to_signed(-82, 8);
			end if;
					
			state_n <= FETCH_GAIN;
		
		-- enable LUT and what for returned gain
		when FETCH_GAIN =>
			if lut_delay_c = 0 then
				o_gain_fetch 	<= '1'; -- enable LUT
				lut_delay_n 	<= lut_delay_c + 1; -- increase delay counter
				state_n 		<= FETCH_GAIN; -- stay in same state
			else
				lut_delay_n 	<= (others => '0'); -- clear delay counter
				state_n 		<= GAIN;
			end if;
			
		-- multiply current sample with the gain fetched from LUT
		when GAIN =>
			agc_out_n <= signed(curr_sample_c) * signed('0' & i_gain); -- multiply with gain from LUT
			state_n <= SEND;
		
		-- calculate power of output sample for comparison and weighting with next input sample
		when SEND =>
			P_w_fast_prev_n <= P_w_fast_c;
			P_weighted_prev_n <= P_weighted_c;
			state_n 	<= HOLD;
			
	end case;
end process;

end Behavioral;
