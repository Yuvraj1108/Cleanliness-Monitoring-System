library ieee;						-- Library declaration
use ieee.std_logic_1164.all;	-- Use std_logic_1164 package from ieee library
use ieee.numeric_std.all;	

entity test0 is
	port(I : in std_logic;
		  O1, O2 : out std_logic);
end test0;

Architecture functionality of test0 is

begin
			O1 <= not I;
			O2 <= I;

end functionality;			