library ieee;
use ieee.std_logic_1164.all;
use work.cs254.all;

entity COUNTER_SYNC_1 is -- Entity declaration
port (CLK : in std_logic; -- Clock input of the counter
		EN : in std_logic; -- Enable input of the counter
		RSTN : in std_logic; -- Active low reset input of the counter
		LDN : in std_logic; -- Active low load input of the counter
		D : in std_logic_vector(3 downto 0); -- Value to be assigned to the counter
		C : out std_logic; -- Carry output from the counter
		Q : inout std_logic_vector(3 downto 0)); -- Output of the counter
end COUNTER_SYNC_1;

architecture FUNCTIONALITY of COUNTER_SYNC_1 is

signal Q1, Q2  : std_logic_vector(3 downto 0);
signal Qn  : std_logic_vector(3 downto 0);
signal RST : std_logic_vector(1 downto 0);
signal LD1 : std_logic_vector(3 downto 0);
signal RS : std_logic_vector(3 downto 0);
signal EN1 : std_logic_vector(2 downto 0);
signal A, RSTF : std_logic;

begin
        
    U1 : OR_1 port map(Q(1), Q(2), RST(0));
    U2 : AND_1 port map(RST(0), Q(3), RST(1));
    U4 : NOT_1 port map(RST(1), A);
	 U3 : AND_1 port map(A, RSTN, RSTF);
    
	
    
    U5 : XOR_1 port map(EN, Q(0), LD1(0) );
    U6 : MUX_2_1 port map(D(0), LD1(0), LDN, RS(0) );
    U7 : MUX_2_1 port map('1', RS(0), RSTF, Qn(0) );
    U8 : D_FF port map( Qn(0), CLK, '1','1',Q(0),Q1(0));
    
    
    U9 : AND_1 port map(EN, Q1(0), EN1(0) );
    U10 : XOR_1 port map(EN1(0), Q(1), LD1(1) );
    U11 : MUX_2_1 port map(D(1), LD1(1), LDN, RS(1) );
    U12 : MUX_2_1 port map('0', RS(1), RSTF, Qn(1) );
    U13 : D_FF port map( Qn(1), CLK, '1','1',Q(1),Q1(1));
    
    
    U14 : AND_1 port map(EN1(0), Q1(1), EN1(1) );
    U15 : XOR_1 port map(EN1(1), Q(2), LD1(2) );
    U16 : MUX_2_1 port map(D(2), LD1(2), LDN, RS(2) );
    U17 : MUX_2_1 port map('0', RS(2), RSTN, Qn(2) );
    U18 : D_FF port map( Qn(2), CLK, '1','1',Q(2),Q1(2));
    

    U19 : AND_1 port map(EN1(1), Q1(2), EN1(2) );
    U20 : XOR_1 port map(EN1(2), Q(3), LD1(3) );
    U21 : MUX_2_1 port map(D(3), LD1(3), LDN, RS(3) );
    U22 : MUX_2_1 port map('1', RS(3), RSTF, Qn(3) );
    U23 : D_FF port map( Qn(3), CLK, '1','1',Q(3),Q1(3));
    

    U24 : AND_1 port map(EN1(2), Q1(3), C);


end FUNCTIONALITY;