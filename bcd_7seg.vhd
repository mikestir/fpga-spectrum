library ieee;
use ieee.std_logic_1164.all;

-- Convert BCD to 7-segment display characters
entity seg7 is
port (
	D			: in std_logic_vector(3 downto 0);
	Q			: out std_logic_vector(6 downto 0)
);
end seg7;

architecture seg7_arch of seg7 is
begin
	Q <=	"1000000" when D = "0000" else
			"1111001" when D = "0001" else
			"0100100" when D = "0010" else
			"0110000" when D = "0011" else
			"0011001" when D = "0100" else
			"0010010" when D = "0101" else
			"0000010" when D = "0110" else
			"1111000" when D = "0111" else
			"0000000" when D = "1000" else
			"0010000" when D = "1001" else
			"0001000" when D = "1010" else
			"0000011" when D = "1011" else
			"1000110" when D = "1100" else
			"0100001" when D = "1101" else
			"0000110" when D = "1110" else
			"0001110";
end seg7_arch;
