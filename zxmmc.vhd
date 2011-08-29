-- Emulation of ZXMMC interface
--
-- (C) 2011 Mike Stirling

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity zxmmc is
port (
	CLOCK		:	in	std_logic;
	nRESET		:	in	std_logic;
	CLKEN		:	in	std_logic;
	
	-- Bus interface
	ENABLE		:	in	std_logic;
	-- 0 - W  - Card chip selects (active low)
	-- 1 - RW - SPI tx/rx data register
	RS			:	in	std_logic;
	nWR			:	in	std_logic;
	DI			:	in	std_logic_vector(7 downto 0);
	DO			:	out	std_logic_vector(7 downto 0);
	
	-- SD card interface
	SD_CS0		:	out	std_logic;
	SD_CS1		:	out	std_logic;
	SD_CLK		:	out	std_logic;
	SD_MOSI		:	out	std_logic;
	SD_MISO		:	in	std_logic
	);
end entity;

architecture rtl of zxmmc is
signal counter		:	unsigned(3 downto 0);
-- Shift register has an extra bit because we write on the
-- falling edge and read on the rising edge
signal shift_reg	:	std_logic_vector(8 downto 0);
signal in_reg		:	std_logic_vector(7 downto 0);
begin
	-- Input register read when RS=1
	DO <= in_reg when RS='1' else (others => '1');
	
	-- SD card outputs from clock divider and shift register
	SD_CLK <= counter(0);
	SD_MOSI <= shift_reg(8);

	-- Chip selects
	process(CLOCK,nRESET)
	begin
		if nRESET = '0' then
			SD_CS0 <= '1';
			SD_CS1 <= '1';
		elsif rising_edge(CLOCK) and CLKEN = '1' then
			if ENABLE = '1' and RS = '0' and nWR = '0' then
				-- The two chip select outputs are controlled directly
				-- by writes to the lowest two bits of the control register
				SD_CS0 <= DI(0);
				SD_CS1 <= DI(1);
			end if;
		end if;
	end process;
	
	-- SPI write
	process(CLOCK,nRESET)
	begin		
		if nRESET = '0' then
			shift_reg <= (others => '1');
			in_reg <= (others => '1');
			counter <= "1111"; -- Idle
		elsif rising_edge(CLOCK) and CLKEN = '1' then
			if counter = "1111" then
				-- Store previous shift register value in input register
				in_reg <= shift_reg(7 downto 0);
				
				-- Idle - check for a bus access
				if ENABLE = '1' and RS = '1' then
					-- Write loads shift register with data
					-- Read loads it with all 1s
					if nWR = '1' then
						shift_reg <= (others => '1');
					else
						shift_reg <= DI & '1';
					end if;
					counter <= "0000"; -- Initiates transfer
				end if;
			else
				-- Transfer in progress
				counter <= counter + 1;
				
				if counter(0) = '0' then
					-- Input next bit on rising edge
					shift_reg(0) <= SD_MISO;
				else
					-- Output next bit on falling edge
					shift_reg <= shift_reg(7 downto 0) & '1';
				end if;
			end if;
		end if;
	end process;
end architecture;
