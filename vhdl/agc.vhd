----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Niklas Aldén
-- 
-- Create Date:    20:09:18 03/10/2015 
-- Design Name: 
-- Module Name:    agc - Behavioral 
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
use ieee.math_real.all;

entity agc is
	Port ( clk : in  STD_LOGIC;
           rstn : in  STD_LOGIC;
           i_sample : in  STD_LOGIC_VECTOR (15 downto 0);
		   i_start : in std_logic;
           i_gain : in  STD_LOGIC_VECTOR (15 downto 0);
           o_power : out  STD_LOGIC_VECTOR (7 downto 0);
           o_sample : out  STD_LOGIC_VECTOR (15 downto 0);
		   o_done : out STD_LOGIC
	);
end agc;

architecture Behavioral of agc is

	constant alpha : unsigned(15 downto 0) := to_unsigned(164, 16);
	constant beta : unsigned(15 downto 0) := to_unsigned(983, 16);
	
	signal P_in_c : unsigned(30 downto 0) := (others => '0');
	signal P_in_n : unsigned(31 downto 0) := (others => '0');
	signal P_tmp_c : unsigned(31 downto 0) := (others => '0');
	signal P_tmp_n : unsigned(46 downto 0) := (others => '0');
	signal P_dB_c, P_dB_n : signed(7 downto 0) := (others => '0');
	signal P_prev_c, P_prev_n : unsigned(31 downto 0) := (others => '0');
	signal agc_out_c : signed(15 downto 0) := (others => '0');
	signal agc_out_n : signed(31 downto 0) := (others => '0');
	signal curr_sample_c, curr_sample_n : signed(15 downto 0) := (others => '0');
	
	type state_type is (HOLD, P_curr, P_weighted, P_dB, GAIN, SEND);
	signal state_c, state_n : state_type := HOLD;
	

begin

clk_proc : process(clk, rstn) is
begin

	if rstn = '0' then
		state_c <= HOLD;
		P_in_c <= (others => '0');
		P_tmp_c <= (others => '0');
		P_dB_c <= (others => '0');
		P_prev_c <= (others => '0');
		agc_out_c <= (others => '0');
		curr_sample_c <= (others => '0');
	elsif rising_edge(clk) then
		state_c <= state_n;
		P_in_c <= P_in_n(30 downto 0);
		P_tmp_c <= P_tmp_n(46 downto 15);
		P_dB_c <= P_dB_n;
		P_prev_c <= P_prev_n;
		agc_out_c <= agc_out_n(30 downto 15);
		curr_sample_c <= curr_sample_n;
	end if;
	
end process;


power_proc : process(state_c, curr_sample_c, P_in_c, P_tmp_c, P_dB_c, P_prev_c, agc_out_c, i_sample, i_start, i_gain) is
begin
	--default
	state_n <= state_c;
	P_in_n <= resize(P_in_c, 32);
	P_tmp_n <= P_tmp_c & "000000000000000";
	P_dB_n <= P_dB_c;
	curr_sample_n <= curr_sample_c;
	P_prev_n <= P_prev_c;
	agc_out_n <= signed(resize(signed(agc_out_c), 32));
	o_sample <= std_logic_vector(agc_out_c);
	o_power <= std_logic_vector(P_dB_n);
	o_done <= '0';
	
	case state_c is
	
		when HOLD =>
			if i_start = '1' then
				curr_sample_n <= signed(i_sample);
				state_n <= P_curr;
			end if;
		
		when P_curr =>
			P_in_n <= unsigned(abs(signed(curr_sample_c)) * abs(signed(curr_sample_c)));
			state_n <= P_weighted;
			
		when P_weighted =>
			if P_in_c > P_prev_c then
				P_tmp_n <= (32768 - alpha) * P_prev_c(30 downto 0) + alpha * P_in_c;
			else
				P_tmp_n <= (32768 - beta) * P_prev_c(30 downto 0) + beta * P_in_c;
			end if;
			state_n <= P_dB;
			
		when P_dB =>
			if P_tmp_c > x"2133a19c6" then -- >99.5dB
				P_dB_n <= to_signed(18, 8);
			elsif P_tmp_c > x"1a5f7f434" then -- >98.5dB
				P_dB_n <= to_signed(17, 8);
			elsif P_tmp_c > x"14f2e7a04" then -- >97.5dB
				P_dB_n <= to_signed(16, 8);
			elsif P_tmp_c > x"10a3e81d2" then -- >96.5dB
				P_dB_n <= to_signed(15, 8);
			elsif P_tmp_c > x"d37c3a05" then -- >95.5dB
				P_dB_n <= to_signed(14, 8);
			elsif P_tmp_c > x"a7fd1c54" then -- >94.5dB
				P_dB_n <= to_signed(13, 8);
			elsif P_tmp_c > x"85702c73" then -- >93.5dB
				P_dB_n <= to_signed(12, 8);
			elsif P_tmp_c > x"69fe63f3" then -- >92.5dB
				P_dB_n <= to_signed(11, 8);
			elsif P_tmp_c > x"54319cc9" then -- >91.5dB
				P_dB_n <= to_signed(10, 8);
			elsif P_tmp_c > x"42e0a497" then -- >90.5dB
				P_dB_n <= to_signed(9, 8);
			elsif P_tmp_c > x"351f68fb" then -- >89.5dB
				P_dB_n <= to_signed(8, 8);
			elsif P_tmp_c > x"2a326539" then -- >88.5dB
				P_dB_n <= to_signed(7, 8);
			elsif P_tmp_c > x"2184a5ce" then -- >87.5dB
				P_dB_n <= to_signed(6, 8);
			elsif P_tmp_c > x"1a9fd9c9" then -- >86.5dB
				P_dB_n <= to_signed(5, 8);
			elsif P_tmp_c > x"152605ce" then -- >85.5dB
				P_dB_n <= to_signed(4, 8);
			elsif P_tmp_c > x"10cc82d6" then -- >84.5dB
				P_dB_n <= to_signed(3, 8);
			elsif P_tmp_c(27 downto 0) > x"d580472" then -- >83.5dB
				P_dB_n <= to_signed(2, 8);
			elsif P_tmp_c(27 downto 0) > x"a997066" then -- >82.5dB
				P_dB_n <= to_signed(1, 8);
			elsif P_tmp_c(27 downto 0) > x"86b5c7b" then -- >81.5dB
				P_dB_n <= to_signed(0, 8);
			elsif P_tmp_c(27 downto 0) > x"6b01076" then -- >80.5dB
				P_dB_n <= to_signed(-1, 8);
			elsif P_tmp_c(27 downto 0) > x"54ff0e6" then -- >79.5dB
				P_dB_n <= to_signed(-2, 8);
			elsif P_tmp_c(27 downto 0) > x"4383d53" then -- >78.5dB
				P_dB_n <= to_signed(-3, 8);
			elsif P_tmp_c(27 downto 0) > x"35a1095" then -- >77.5dB
				P_dB_n <= to_signed(-4, 8);
			elsif P_tmp_c(27 downto 0) > x"2a995c8" then -- >76.5dB
				P_dB_n <= to_signed(-5, 8);
			elsif P_tmp_c(27 downto 0) > x"21d66fb" then -- >75.5dB
				P_dB_n <= to_signed(-6, 8);
			elsif P_tmp_c(27 downto 0) > x"1ae0d16" then -- >74.5dB
				P_dB_n <= to_signed(-7, 8);
			elsif P_tmp_c(27 downto 0) > x"1559a0c" then -- >73.5dB
				P_dB_n <= to_signed(-8, 8);
			elsif P_tmp_c(27 downto 0) > x"10f580b" then -- >72.5dB
				P_dB_n <= to_signed(-9, 8);
			elsif P_tmp_c(23 downto 0) > x"d78940" then -- >71.5dB
				P_dB_n <= to_signed(-10, 8);
			elsif P_tmp_c(23 downto 0) > x"ab34d9" then -- >70.5dB
				P_dB_n <= to_signed(-11, 8);
			elsif P_tmp_c(23 downto 0) > x"87fe7e" then -- >69.5dB
				P_dB_n <= to_signed(-12, 8);
			elsif P_tmp_c(23 downto 0) > x"6c0622" then -- >68.5dB
				P_dB_n <= to_signed(-13, 8);
			elsif P_tmp_c(23 downto 0) > x"55ce76" then -- >67.5dB
				P_dB_n <= to_signed(-14, 8);
			elsif P_tmp_c(23 downto 0) > x"442894" then -- >66.5dB
				P_dB_n <= to_signed(-15, 8);
			elsif P_tmp_c(23 downto 0) > x"3623e6" then -- >65.5dB
				P_dB_n <= to_signed(-16, 8);
			elsif P_tmp_c(23 downto 0) > x"2b014f" then -- >64.5dB
				P_dB_n <= to_signed(-17, 8);
			elsif P_tmp_c(23 downto 0) > x"222902" then -- >63.5dB
				P_dB_n <= to_signed(-18, 8);
			elsif P_tmp_c(23 downto 0) > x"1b2268" then -- >62.5dB
				P_dB_n <= to_signed(-19, 8);
			elsif P_tmp_c(23 downto 0) > x"158dba" then -- >61.5dB
				P_dB_n <= to_signed(-20, 8);
			elsif P_tmp_c(23 downto 0) > x"111ee3" then -- >60.5dB
				P_dB_n <= to_signed(-21, 8);
			elsif P_tmp_c(19 downto 0) > x"d9973" then -- >59.5dB
				P_dB_n <= to_signed(-22, 8);
			elsif P_tmp_c(19 downto 0) > x"acd6a" then -- >58.5dB
				P_dB_n <= to_signed(-23, 8);
			elsif P_tmp_c(19 downto 0) > x"894a6" then -- >57.5dB
				P_dB_n <= to_signed(-24, 8);
			elsif P_tmp_c(19 downto 0) > x"6d0dc" then -- >56.5dB
				P_dB_n <= to_signed(-25, 8);
			elsif P_tmp_c(19 downto 0) > x"569fe" then -- >55.5dB
				P_dB_n <= to_signed(-26, 8);
			elsif P_tmp_c(19 downto 0) > x"44cef" then -- >54.5dB
				P_dB_n <= to_signed(-27, 8);
			elsif P_tmp_c(19 downto 0) > x"36a81" then -- >53.5dB
				P_dB_n <= to_signed(-28, 8);
			elsif P_tmp_c(19 downto 0) > x"2b6a4" then -- >52.5dB
				P_dB_n <= to_signed(-29, 8);
			elsif P_tmp_c(19 downto 0) > x"227c6" then -- >51.5dB
				P_dB_n <= to_signed(-30, 8);
			elsif P_tmp_c(19 downto 0) > x"1b64a" then -- >50.5dB
				P_dB_n <= to_signed(-31, 8);
			elsif P_tmp_c(19 downto 0) > x"15c26" then -- >49.5dB
				P_dB_n <= to_signed(-32, 8);
			elsif P_tmp_c(19 downto 0) > x"1148b" then -- >48.5dB
				P_dB_n <= to_signed(-33, 8);
			elsif P_tmp_c(15 downto 0) > x"dbab" then -- >47.5dB
				P_dB_n <= to_signed(-34, 8);
			elsif P_tmp_c(15 downto 0) > x"ae7d" then -- >46.5dB
				P_dB_n <= to_signed(-35, 8);
			elsif P_tmp_c(15 downto 0) > x"8a9a" then -- >45.5dB
				P_dB_n <= to_signed(-36, 8);
			elsif P_tmp_c(15 downto 0) > x"6e18" then -- >44.5dB
				P_dB_n <= to_signed(-37, 8);
			elsif P_tmp_c(15 downto 0) > x"5774" then -- >43.5dB
				P_dB_n <= to_signed(-38, 8);
			elsif P_tmp_c(15 downto 0) > x"4577" then -- >42.5dB
				P_dB_n <= to_signed(-39, 8);
			elsif P_tmp_c(15 downto 0) > x"372e" then -- >41.5dB
				P_dB_n <= to_signed(-40, 8);
			elsif P_tmp_c(15 downto 0) > x"2bd5" then -- >40.5dB
				P_dB_n <= to_signed(-41, 8);
			elsif P_tmp_c(15 downto 0) > x"22d1" then -- >39.5dB
				P_dB_n <= to_signed(-42, 8);
			elsif P_tmp_c(15 downto 0) > x"1ba8" then -- >38.5dB
				P_dB_n <= to_signed(-43, 8);
			elsif P_tmp_c(15 downto 0) > x"15f8" then -- >37.5dB
				P_dB_n <= to_signed(-44, 8);
			elsif P_tmp_c(15 downto 0) > x"1173" then -- >36.5dB
				P_dB_n <= to_signed(-45, 8);
			elsif P_tmp_c(11 downto 0) > x"ddd" then -- >35.5dB
				P_dB_n <= to_signed(-46, 8);
			elsif P_tmp_c(11 downto 0) > x"b03" then -- >34.5dB
				P_dB_n <= to_signed(-47, 8);
			elsif P_tmp_c(11 downto 0) > x"8bf" then -- >33.5dB
				P_dB_n <= to_signed(-48, 8);
			elsif P_tmp_c(11 downto 0) > x"6f3" then -- >32.5dB
				P_dB_n <= to_signed(-49, 8);
			elsif P_tmp_c(11 downto 0) > x"585" then -- >31.5dB
				P_dB_n <= to_signed(-50, 8);
			elsif P_tmp_c(11 downto 0) > x"463" then -- >30.5dB
				P_dB_n <= to_signed(-51, 8);
			elsif P_tmp_c(11 downto 0) > x"37c" then -- >29.5dB
				P_dB_n <= to_signed(-52, 8);
			elsif P_tmp_c(11 downto 0) > x"2c4" then -- >28.5dB
				P_dB_n <= to_signed(-53, 8);
			elsif P_tmp_c(11 downto 0) > x"233" then -- >27.5dB
				P_dB_n <= to_signed(-54, 8);
			elsif P_tmp_c(11 downto 0) > x"1bf" then -- >26.5dB
				P_dB_n <= to_signed(-55, 8);
			elsif P_tmp_c(11 downto 0) > x"163" then -- >25.5dB
				P_dB_n <= to_signed(-56, 8);
			elsif P_tmp_c(11 downto 0) > x"11a" then -- >24.5dB
				P_dB_n <= to_signed(-57, 8);
			elsif P_tmp_c(7 downto 0) > x"e0" then -- >23.5dB
				P_dB_n <= to_signed(-58, 8);
			elsif P_tmp_c(7 downto 0) > x"b2" then -- >22.5dB
				P_dB_n <= to_signed(-59, 8);
			elsif P_tmp_c(7 downto 0) > x"8e" then -- >21.5dB
				P_dB_n <= to_signed(-60, 8);
			elsif P_tmp_c(7 downto 0) > x"71" then -- >20.5dB
				P_dB_n <= to_signed(-61, 8);
			elsif P_tmp_c(7 downto 0) > x"5a" then -- >19.5dB
				P_dB_n <= to_signed(-62, 8);
			elsif P_tmp_c(7 downto 0) > x"47" then -- >18.5dB
				P_dB_n <= to_signed(-63, 8);
			elsif P_tmp_c(7 downto 0) > x"39" then -- >17.5dB
				P_dB_n <= to_signed(-64, 8);
			elsif P_tmp_c(7 downto 0) > x"2d" then -- >16.5dB
				P_dB_n <= to_signed(-65, 8);
			elsif P_tmp_c(7 downto 0) > x"24" then -- >15.5dB
				P_dB_n <= to_signed(-66, 8);
			elsif P_tmp_c(7 downto 0) > x"1d" then -- >14.5dB
				P_dB_n <= to_signed(-67, 8);
			elsif P_tmp_c(7 downto 0) > x"17" then -- >13.5dB
				P_dB_n <= to_signed(-68, 8);
			elsif P_tmp_c(7 downto 0) > x"12" then -- >12.5dB
				P_dB_n <= to_signed(-69, 8);
			elsif P_tmp_c(3 downto 0) > x"f" then -- >11.5dB
				P_dB_n <= to_signed(-70, 8);
			elsif P_tmp_c(3 downto 0) > x"c" then -- >10.5dB
				P_dB_n <= to_signed(-71, 8);
			elsif P_tmp_c(3 downto 0) > x"9" then -- >9.5dB
				P_dB_n <= to_signed(-72, 8);
			elsif P_tmp_c(3 downto 0) > x"7" then -- >8.5dB
				P_dB_n <= to_signed(-73, 8);
			elsif P_tmp_c(3 downto 0) > x"6" then -- >7.5dB
				P_dB_n <= to_signed(-74, 8);
			elsif P_tmp_c(3 downto 0) > x"5" then -- >6.5dB
				P_dB_n <= to_signed(-75, 8);
			elsif P_tmp_c(3 downto 0) > x"4" then -- >6dB
				P_dB_n <= to_signed(-76, 8);
			elsif P_tmp_c(3 downto 0) > x"3" then -- >4.5dB
				P_dB_n <= to_signed(-77, 8);
			elsif P_tmp_c(3 downto 0) > x"2" then -- >3dB
				P_dB_n <= to_signed(-79, 8);
			else									-- >=0dB
				P_dB_n <= to_signed(-82, 8);
			end if;
			state_n <= GAIN;
			
		when GAIN =>
			if P_dB_c > to_signed(-82,16) then -- optimize
				agc_out_n <= signed(curr_sample_c) * signed(i_gain); 
			else
				agc_out_n <= resize(signed(curr_sample_c), 32); 
			end if;
	
			state_n <= SEND;
		
		when SEND =>
			o_done <= '1';
			P_prev_n <= unsigned(abs(signed(agc_out_c)) * abs(signed(agc_out_c)));
			state_n <= HOLD;
			
	end case;
	
end process;

end Behavioral;