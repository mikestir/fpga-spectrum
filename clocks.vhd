library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clocks is
port (
	-- 28 MHz master clock
	CLK				:	in std_logic;
	-- Master reset
	nRESET			:	in std_logic;
	
	-- 3.5 MHz clock enable (1 in 8)
	CLKEN_CPU		:	out std_logic;
	-- 14 MHz clock enable (out of phase with CPU)
	CLKEN_VID		:	out std_logic;
	-- 427.5 kHz clock enable for I2C
	CLKEN_I2C		:	out	std_logic;
	
	-- Set to slow the CPU
	SLOW			:	in	std_logic
	);
end clocks;

-- Clock enables for uncontended VRAM access
-- 0    1    2    3    4    5    6    7
-- CPU  VID       VID       VID       VID

architecture clocks_arch of clocks is
signal counter	:	std_logic_vector(19 downto 0);
begin
	CLKEN_CPU <= not (counter(0) or counter(1) or counter(2)) and counter(3) and
		counter(4) and counter(5) and counter(6) and counter(7) and counter(8) and
		counter(9) and counter(10) and counter(11) and counter(12) and counter(13) and
		counter(14) and counter(15) and counter(16) and counter(17) and counter(18) and
		counter(19) when SLOW = '1' else
		-- 000
		not (counter(0) or counter(1) or counter(2));
		
	-- 00X
	CLKEN_VID <= counter(0);
	
	-- 111111 (/64)
	CLKEN_I2C <= counter(0) and counter(1) and counter(2) and counter(3) and counter(4) and
		counter(5);

	process(nRESET,CLK)
	begin
		if nRESET = '0' then
			counter <= (others => '0');
		elsif falling_edge(CLK) then
			counter <= counter + '1';
		end if;
	end process;
end clocks_arch;

