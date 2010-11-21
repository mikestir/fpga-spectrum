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

entity bus_routing is
port (
	CLK			:	in		std_logic;
	nRESET		:	in		std_logic;
	
	-- CPU interface
	A			:	in		std_logic_vector(15 downto 0);
	CPU_D_OUT	:	out		std_logic_vector(7 downto 0);
	nMREQ		:	in		std_logic;
	nIOREQ		:	in		std_logic;
	nRD			:	in		std_logic;
	nWR			:	in		std_logic;
	
	-- ROM interface
	ROM_D_IN	:	in		std_logic_vector(7 downto 0);
	
	-- ULA io port enable
	ULA_LATCH	:	out		std_logic;
	ULA_D_IN	:	in		std_logic_vector(7 downto 0);
	
	-- SRAM interface
	SRAM_D_IN	:	in		std_logic_vector(7 downto 0);
	nRAMEN		:	out		std_logic
	);
end bus_routing;

architecture bus_routing_arch of bus_routing is
signal romen		:	std_logic;
signal ramen_low	:	std_logic;
signal ramen_high	:	std_logic;
signal ramen		:	std_logic;
signal ulaen		:	std_logic;

begin
	-- ROM is in the lower 16KB
	romen <= not A(15) and not A(14) and not nMREQ;
	-- Lower (contended) 16KB of RAM is next
	ramen_low <= not A(15) and A(14) and not nMREQ;
	-- Upper 32KB of RAM is next
	ramen_high <= A(15) and not nMREQ;
	-- All RAM
	ramen <= (A(15) or A(14)) and not nMREQ;	
	-- ULA is the only IO port, seen for all even accesses
	ulaen <= not A(0) and not nIOREQ;
	
	nRAMEN <= not ramen;
	
	-- Update ULA IO port
	ULA_LATCH <= ulaen and not nWR;
	
	-- Route data from memories to CPU.  No need to qualify on read
	-- because of the split read/write bus
	CPU_D_OUT <= 
		ROM_D_IN when romen = '1' else
		SRAM_D_IN when ramen = '1' else
		ULA_D_IN when ulaen = '1' else
		-- Idle bus
		(others => '1');
end bus_routing_arch;

--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ula_port is
port (
	CLK		:	in	std_logic;
	nRESET	:	in	std_logic;
	
	-- CPU interface with separate read/write buses
	D_IN	:	in	std_logic_vector(7 downto 0);
	D_OUT	:	out	std_logic_vector(7 downto 0);
	LATCH	:	in	std_logic;
	
	BORDER_OUT	:	out	std_logic_vector(2 downto 0);
	EAR_OUT		:	out	std_logic;
	MIC_OUT		:	out std_logic;
	
	KEYB_IN		:	in 	std_logic_vector(4 downto 0);
	EAR_IN		:	in	std_logic
	);
end ula_port;

architecture ula_port_arch of ula_port is
signal	outreg : std_logic_vector(7 downto 0);
signal	inreg : std_logic_vector(7 downto 0);
begin
	-- Connect up register bits to outputs
	-- 7,6,5 = N/C
	-- 4 = EAR
	-- 3 = MIC
	-- 2,1,0 = BORDER (G, R, B)
	BORDER_OUT <= outreg(2 downto 0);
	EAR_OUT <= outreg(4);
	MIC_OUT <= outreg(3);
	
	-- Load input register onto output bus
	D_OUT <= inreg;
	
	process(CLK,nRESET)
	begin
		if nRESET = '0' then
			inreg <= (others => '0');
			outreg <= (others => '0');
		elsif rising_edge(CLK) then
			-- Register inputs
			-- 7 = N/C
			-- 6 = EAR
			-- 5 = N/C
			-- 4-0 = Keyboard
			inreg <= '0' & EAR_IN & '0' & KEYB_IN;
			if LATCH = '1' then
				-- Latch input data to output register
				outreg <= D_IN;
			end if;
		end if;
	end process;
end ula_port_arch;

