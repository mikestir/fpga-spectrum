-- ZX Spectrum for Altera DE1
--
-- Copyright (c) 2009-2010 Mike Stirling
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- * Redistributions of source code must retain the above copyright notice,
--   this list of conditions and the following disclaimer.
--
-- * Redistributions in synthesized form must reproduce the above copyright
--   notice, this list of conditions and the following disclaimer in the
--   documentation and/or other materials provided with the distribution.
--
-- * Neither the name of the author nor the names of other contributors may
--   be used to endorse or promote products derived from this software without
--   specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Rename this to bus_mon
entity addr_mon is
port (
	CLK		:	in	std_logic;

	A		:	in	std_logic_vector(15 downto 0);
	D		:	in	std_logic_vector(7 downto 0);
	
	nMREQ	:	in	std_logic;
	nRD		:	in	std_logic;
	nWR		:	in	std_logic;
	
	HEX3	:	out	std_logic_vector(6 downto 0);
	HEX2	:	out	std_logic_vector(6 downto 0);
	HEX1	:	out	std_logic_vector(6 downto 0);
	HEX0	:	out	std_logic_vector(6 downto 0);
	
	BUSOUT	:	out	std_logic_vector(7 downto 0)
);
end addr_mon;

architecture addr_mon_arch of addr_mon is
component seg7
port (
	D			: in std_logic_vector(3 downto 0);
	Q			: out std_logic_vector(6 downto 0)
);
end component;

signal A_LATCH : std_logic_vector(15 downto 0);
signal D_LATCH : std_logic_vector(7 downto 0);
signal STROBE : std_logic;
begin
		
	digit3 : seg7 port map(A_LATCH(15 downto 12),HEX3);
	digit2 : seg7 port map(A_LATCH(11 downto 8),HEX2);
	digit1 : seg7 port map(A_LATCH(7 downto 4),HEX1);
	digit0 : seg7 port map(A_LATCH(3 downto 0),HEX0);

	-- Strobe is high when MREQ is asserted and qualified by
	-- a read or write strobe (i.e. not a refresh cycle)
	STROBE <= not (nMREQ or (nRD and nWR));
	BUSOUT <= D_LATCH;

	process
	begin
		wait until rising_edge(CLK);
		
		if STROBE = '1' then
			-- Latch address and data during the MREQ access
			A_LATCH <= A;
			D_LATCH <= D;
		end if;
	end process;
	
end addr_mon_arch;

--

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
