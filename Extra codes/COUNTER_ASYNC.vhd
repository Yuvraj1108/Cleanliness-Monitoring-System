library ieee;
use ieee.std_logic_1164.all;
use work.cs254.all;

entity COUNTER_ASYNC is -- Entity declaration
	port(CLK : in std_logic; -- Clock input of the counter
		RSTN : in std_logic; -- Active low reset input of the counter
		Q : inout std_logic_vector(3 downto 0)); -- Output of the counter
end COUNTER_ASYNC;

architecture FUNCTIONALITY of COUNTER_ASYNC is 

	signal A, B, Bnot, RST: std_logic;
	signal Qn: std_logic_vector(3 downto 0);
	
begin
	--Reset
	U0: OR_1 port map (Q(2), Q(1), A);
	U1: AND_1 port map (Q(3), A, B);
	U2: NOT_1 port map (B, Bnot);
	U3: AND_1 port map (Bnot, RSTN, RST);
	
	U4: D_FF port map (Qn(0), CLK, '1', RST, Q(0), Qn(0));
	U5: D_FF port map (Qn(1), Qn(0), '1', RST, Q(1), Qn(1));
	U6: D_FF port map (Qn(2), Qn(1), '1', RST, Q(2), Qn(2));
	U7: D_FF port map (Qn(3), Qn(2), '1', RST, Q(3), Qn(3));
	
end FUNCTIONALITY;