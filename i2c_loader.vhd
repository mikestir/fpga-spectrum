-- FIXME: Check for updates from S/PDIF project (2010/07/06)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2c_loader is
-- Address of slave to be loaded
generic (device_address : positive := 16#1a#);
port (
	CLK			:	in	std_logic;
	CLKEN		:	in	std_logic;
	nRESET		:	in	std_logic;
	
	I2C_SCL		:	inout	std_logic;
	I2C_SDA		:	inout	std_logic;
	
	IS_DONE		:	out std_logic;
	IS_ERROR		:	out	std_logic
	);
end i2c_loader;

architecture i2c_loader_arch of i2c_loader is
type regs is array(0 to 19) of std_logic_vector(7 downto 0);
constant init_regs : regs := (
	-- Left line in, 0dB, unmute
	X"00", X"17",
	-- Right line in, 0dB, unmute
	X"02", X"17",
	-- Left headphone out, 0dB
	X"04", X"79",
	-- Right headphone out, 0dB
	X"06", X"79",
	-- Audio path, DAC enabled, Line in, Bypass off, mic unmuted
	X"08", X"10",
	-- Digital path, Unmute, HP filter enabled
	X"0A", X"00",
	-- Power down mic, clkout and xtal osc
	X"0C", X"62",
	-- Format 16-bit I2S, no bit inversion or phase changes
	X"0E", X"02",
	-- Sampling control, 8 kHz USB mode (MCLK = 250fs * 6)
	X"10", X"0D",
	-- Activate
	X"12", X"01"
	);
-- Number of bursts (i.e. total number of registers)
constant burst_length : positive := 2;
-- Number of bytes to transfer per burst
constant num_bursts : positive := (init_regs'length / burst_length);
	
type state_t is (Idle, Start, Data, Ack, Stop, Pause, Done);
signal state : state_t;
signal phase : std_logic_vector(1 downto 0);
subtype nbit_t is integer range 0 to 7;
signal nbit : nbit_t;
subtype nbyte_t is integer range 0 to burst_length; -- +1 for address byte
signal nbyte : nbyte_t;
subtype thisbyte_t is integer range 0 to init_regs'length; -- +1 for "done"
signal thisbyte : thisbyte_t;
signal shiftreg : std_logic_vector(7 downto 0);
begin

	process(nRESET,CLK)
	begin
		if nRESET = '0' then
			I2C_SDA <= 'Z';
			I2C_SCL <= 'Z';
			IS_DONE <= '0'; -- Not done
			IS_ERROR <= '0'; -- No error
			state <= Idle;
			phase <= "00";
			nbit <= 0;
			nbyte <= 0;
			thisbyte <= 0;
			shiftreg <= (others => '0');
		elsif rising_edge(CLK) and CLKEN = '1' then
  			-- Next phase by default
			phase <= phase + 1;

      -- STATE: IDLE
			if state = Idle then
				-- Start loading the device registers straight away
				-- A 'GO' bit could be polled here if required
				state <= Start;
				phase <= "00";
				
		  -- STATE: START
			elsif state = Start then
				-- Generate START condition
				case phase is
				when "00" =>
					-- Drop SDA first
					I2C_SDA <= '0';
				when "10" =>
					-- Then drop SCL
					I2C_SCL <= '0';
				when "11" =>
					-- Advance to next state
					-- Shift register loaded with device slave address
					state <= Data;
					nbit <= 7;
					shiftreg <= std_logic_vector(to_unsigned(device_address,7)) & '0'; -- writing
					nbyte <= burst_length;
				when others =>
					null;
				end case;
				
			-- STATE: DATA
			elsif state = Data then
				-- Generate data
				case phase is
				when "00" =>
					-- Drop SCL
					I2C_SCL <= '0';
				when "01" =>
					-- Output data and shift (MSb first)
					if shiftreg(7) = '0' then
						I2C_SDA <= '0';
					else
						I2C_SDA <= 'Z';
					end if;
					shiftreg <= shiftreg(6 downto 0) & '0';
				when "10" =>
					-- Raise SCL
					I2C_SCL <= 'Z';
				when "11" =>
					-- Next bit or advance to next state when done
					if nbit = 0 then
						state <= Ack;
					else
						nbit <= nbit - 1;
					end if;
				when others =>
				  null;
				end case;
				
			-- STATE: ACK
			elsif state = Ack then
				-- Generate ACK clock and check for error condition
				case phase is
				when "00" =>
					-- Drop SCL
					I2C_SCL <= '0';
				when "01" =>
					-- Float data
					I2C_SDA <= 'Z';
				when "10" =>
					-- Sample ack bit
					if I2C_SDA = '1' then
						-- Error
						IS_ERROR <= '1';
						nbyte <= 0; -- Close this burst and skip remaining registers
						thisbyte <= init_regs'length;
					else
						-- Hold ACK to avoid spurious stops - this seems to fix a
						-- problem with the Wolfson codec which releases the ACK
						-- right on the falling edge of the clock pulse.  It looks like
						-- the device interprets this is a STOP condition and then fails
						-- to acknowledge the next byte.  We can avoid this by holding the
						-- ACK condition for a little longer.
						I2C_SDA <= '0';
					end if;
					-- Raise SCL
					I2C_SCL <= 'Z';
				when "11" =>
					-- Advance to next state
					if nbyte = 0 then
						-- No more bytes in this burst - generate a STOP
						state <= Stop;
					else
						-- Generate next byte
						state <= Data;
						nbit <= 7;
						shiftreg <= init_regs(thisbyte);
						nbyte <= nbyte - 1;
						thisbyte <= thisbyte + 1;
					end if;
				when others =>
					null;
				end case;
				
			-- STATE: STOP
			elsif state = Stop then
				-- Generate STOP condition
				case phase is
				when "00" =>
					-- Drop SCL first
					I2C_SCL <= '0';
				when "01" =>
					-- Drop SDA
					I2C_SDA <= '0';
				when "10" =>
					-- Raise SCL
					I2C_SCL <= 'Z';
				when "11" =>
					if thisbyte = init_regs'length then
						-- All registers done, advance to finished state.  This will
						-- bring SDA high while SCL is still high, completing the STOP
						-- condition
						IS_DONE <= '1';
						state <= Done;
					else
						-- Load the next register after a short delay
						state <= Pause;
					end if;
				when others =>
					null;
				end case;
				
			-- STATE: PAUSE
			elsif state = Pause then
				-- Delay for one cycle of 'phase' then start the next burst
				I2C_SDA <= 'Z';
				I2C_SCL <= 'Z';
				if phase = "11" then
					state <= Start;
				end if;
				
			-- STATE: DONE
			else
				-- Finished, wait for reset
				I2C_SDA <= 'Z';
				I2C_SCL <= 'Z';
			end if;
		end if;
	end process;

end i2c_loader_arch;
