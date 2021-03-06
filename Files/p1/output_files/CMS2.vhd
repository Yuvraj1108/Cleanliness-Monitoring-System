library ieee;						-- Library declaration
use ieee.std_logic_1164.all;	-- Use std_logic_1164 package from ieee library
use ieee.numeric_std.all;
use work.EE214.all;

entity CMS2 is
	port (CLK : in std_logic;
			RSTN : in std_logic;
			--Ports for LCD
			D : out std_logic_vector(7 downto 0);
			RS, RW, EN : out std_logic;
			--Ports for counter
			RST : inout std_logic;
			inp1 : in std_logic;
			inp2 : in std_logic;
			
			Y1 : out std_logic_vector(6 downto 0);
			Y2 : out std_logic_vector(6 downto 0);
			
		   m : buffer unsigned(3 downto 0) := (others => '0');
			n : buffer unsigned(3 downto 0) := (others => '0')
			
			);
end CMS2;

architecture behaviour of CMS2 is

	--Variables for LCD
	type STATE_TYPE is (S0, S1, S2, S3, S4, S5, S6, IDLE);
	type ARR_TYPE4 is array (0 to 4) of std_logic_vector(7 downto 0);
	type ARR_TYPE2 is array (0 to 2) of std_logic_vector(7 downto 0);
	
	signal CNT_CMD : integer range 0 to 5;
	signal CNT_DATA : integer range 0 to 3;
	signal A2 : integer range 0 to 9 := 0;
	signal A1 : integer range 0 to 7 := 0;
	signal X, Y, Z : std_logic_vector(3 downto 0);
	constant LCD_CMD : ARR_TYPE4 := (X"38", X"01", X"0C", X"80", X"06");
	signal LCD_DATA : ARR_TYPE2 := (X"30", X"30", X"30");
	
	signal Q, QPLUS : STATE_TYPE;
	
	--Variables for COUNTER SSD
    signal input_delay : std_logic;
	 signal input_delay2 : std_logic;
    signal input_rising_edge : std_logic;
	 signal input_rising_edge2 : std_logic;
    signal c1 : std_logic_vector(3 downto 0);
	 signal c2 : std_logic_vector(3 downto 0);
    signal kpcounter1 : unsigned(3 downto 0) := (others => '0');
	 signal kpcounter2 : unsigned(3 downto 0) := (others => '0');
	 
	 signal CLK1 : std_logic := '0';								-- 10Hz clock which needs to be derived
	 signal CNT0 : integer range 0 to 5000000 := 0;			-- Internal counter to generate 10Hz from 50MHz
	
	
begin

process(CLK) 
begin										
	if (CLK'event and CLK = '1') then								
		if(CNT0 = 499999) then
			CNT0 <= 0;
			CLK1 <= not CLK1;
		else
			CNT0 <= CNT0 + 1;
		end if;
	end if;
end process;

process(Q)
	
	begin
	
	case Q is
		-- Initialization of LCD display	
	
	when S0 => 
		if (CNT_CMD < 5) then
			QPLUS <= S1;
			D <= LCD_CMD(CNT_CMD); RS <= '0'; RW <= '0'; EN <='0';
		else
			QPLUS <= S3;
		end if;
		
	when S1 =>
		QPLUS <= S2;
		D <= LCD_CMD(CNT_CMD); RS <= '0'; RW <= '0'; EN <='1';
		
	when S2 =>
		QPLUS <= S0;
		D <= LCD_CMD(CNT_CMD); RS <= '0'; RW <= '0'; EN <='0';	
		
	when S3 =>
		if (CNT_DATA < 3) then
			QPLUS <= S4;
			D <= LCD_DATA(CNT_DATA); RS <= '1'; RW <= '0'; EN <='0';
		else
			QPLUS <= S6;
		end if;
		
	when S4 =>
		QPLUS <= S5;
		D <= LCD_DATA(CNT_DATA); RS <= '1'; RW <= '0'; EN <='1';
		
	when S5 =>
		QPLUS <= S3;
		D <= LCD_DATA(CNT_DATA); RS <= '1'; RW <= '0'; EN <='0';
		
	when S6 =>
		QPLUS <= S0;
	
	when IDLE =>
		QPLUS <= IDLE;
		D <= X"00"; RS <= '0'; RW <= '0'; EN <='0';
		
	when others =>
		QPLUS <= S0;
		D <= X"00"; RS <= '0'; RW <= '0'; EN <='0';

	end case;
end process;

process(RSTN, CLK1)-- ­­ Process for reset and state change

	begin

	if RSTN = '0' then
		Q <= S0; CNT_CMD <= 0; CNT_DATA <= 0;
	elsif (CLK1'event and CLK1 = '1') then
		Q <= QPLUS;
	
		if Q = S2 then
			CNT_CMD <= CNT_CMD + 1;
		end if;
		
		if Q = S5 then
			CNT_DATA <= CNT_DATA + 1;
		end if;
		
		if Q = S6 then	
			CNT_CMD <= 0;
			CNT_DATA <= 0;
			
			if(A2 < 9) then
				A2 <= A2 + 1;
			elsif(A2 = 9) then
				A2 <= 0;
				if(A1 < 7) then
					A1 <= A1 + 1;
				elsif(A1 = 7) then
					A1 <= 0;
				end if;
			end if;
		end if;	
		
	end if;
	
end process;

process (CLK1) 
	begin

	Y <= std_logic_vector(to_unsigned(A1, 4));
	Z <= std_logic_vector(to_unsigned(A2, 4));
	LCD_DATA(2) <= ('0', '0', '1', '1', Z(3), Z(2), Z(1), Z(0));
	LCD_DATA(1) <= ('0', '0', '1', '1', Y(3), Y(2), Y(1), Y(0));
	LCD_DATA(0) <= ('0', '0', '1', '1','0' , '0', '0', '0');
end process;


 delay_input : process(CLK1)
 begin
	  if (CLK1'event and CLK1 = '1') then
			input_delay <= inp1;
			input_delay2 <= inp2;
	  end if;
 end process;
 input_rising_edge <= '1' when inp1 = '1' and input_delay = '0' else '0';
 input_rising_edge2 <= '1' when inp2 = '1' and input_delay2 = '0' else '0';
 kpcounter_proc : process(CLK1)
 begin
	  if (CLK1'event and CLK1 = '1') then
			if rst = '1' then
				 kpcounter1 <= (others => '0');
				 kpcounter2 <= (others => '0');
				 n <= kpcounter2;
				 m <= kpcounter1;
			elsif input_rising_edge = '1' then
				 kpcounter1 <= kpcounter1 + 1;
				 m <= kpcounter1 + 1;
			elsif m = "1000" then
				 kpcounter1 <= (others => '0'); 
				 m <= (others => '0'); 
			elsif input_rising_edge2 = '1' then
				 kpcounter2 <= kpcounter2 + 1;
				 n <= kpcounter2 + 1;
			elsif n = "1000" then
				 kpcounter2 <= (others => '0'); 
				 n <= (others => '0');
			end if;
	  end if;
	  c1 <= std_logic_vector(m);
	  c2 <= std_logic_vector(n);
 end process;
	
	 U0 : BCD2SSD port map(c1,Y1);
	 U1 : BCD2SSD port map(c2,Y2);

	
end behaviour;