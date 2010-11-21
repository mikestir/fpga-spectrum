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

-- PS/2 scancode to Spectrum matrix conversion
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity keyboard is
port (
	CLK			:	in	std_logic;
	nRESET		:	in	std_logic;
	
	A			:	in	std_logic_vector(15 downto 0);
	KEYB		:	out	std_logic_vector(4 downto 0);
	
	PS2_DATA	:	in	std_logic_vector(7 downto 0);
	-- This pulses high for one tick when a new byte is
	-- received from the keyboard
	PS2_VALID	:	in	std_logic
	);
end keyboard;

architecture keyboard_arch of keyboard is
type key_matrix is array (7 downto 0) of std_logic_vector(4 downto 0);
signal keys		:	key_matrix;
signal release	:	std_logic;
signal extended	:	std_logic;
begin	
	-- Output addressed row to ULA
	KEYB <= keys(0) when A(8) = '0' else
		keys(1) when A(9) = '0' else
		keys(2) when A(10) = '0' else
		keys(3) when A(11) = '0' else
		keys(4) when A(12) = '0' else
		keys(5) when A(13) = '0' else
		keys(6) when A(14) = '0' else
		keys(7) when A(15) = '0' else
		(others => '1');

	process(nRESET,CLK)
	begin
		if nRESET = '0' then
			release <= '0';
			extended <= '0';
			
			keys(0) <= (others => '1');
			keys(1) <= (others => '1');
			keys(2) <= (others => '1');
			keys(3) <= (others => '1');
			keys(4) <= (others => '1');
			keys(5) <= (others => '1');
			keys(6) <= (others => '1');
			keys(7) <= (others => '1');
		elsif rising_edge(CLK) then
			if PS2_VALID = '1' then
				if PS2_DATA = X"e0" then
					-- Extended key code follows
					extended <= '1';
				elsif PS2_DATA = X"f0" then
					-- Release code follows
					release <= '1';
				else
					-- Cancel extended/release flags for next time
					release <= '0';
					extended <= '0';
				
					case PS2_DATA is					
					when X"12" => keys(0)(0) <= release; -- Left shift (CAPS SHIFT)
					when X"59" => keys(0)(0) <= release; -- Right shift (CAPS SHIFT)
					when X"1a" => keys(0)(1) <= release; -- Z
					when X"22" => keys(0)(2) <= release; -- X
					when X"21" => keys(0)(3) <= release; -- C
					when X"2a" => keys(0)(4) <= release; -- V
					
					when X"1c" => keys(1)(0) <= release; -- A
					when X"1b" => keys(1)(1) <= release; -- S
					when X"23" => keys(1)(2) <= release; -- D
					when X"2b" => keys(1)(3) <= release; -- F
					when X"34" => keys(1)(4) <= release; -- G
					
					when X"15" => keys(2)(0) <= release; -- Q
					when X"1d" => keys(2)(1) <= release; -- W
					when X"24" => keys(2)(2) <= release; -- E
					when X"2d" => keys(2)(3) <= release; -- R
					when X"2c" => keys(2)(4) <= release; -- T				
				
					when X"16" => keys(3)(0) <= release; -- 1
					when X"1e" => keys(3)(1) <= release; -- 2
					when X"26" => keys(3)(2) <= release; -- 3
					when X"25" => keys(3)(3) <= release; -- 4
					when X"2e" => keys(3)(4) <= release; -- 5			
					
					when X"45" => keys(4)(0) <= release; -- 0
					when X"46" => keys(4)(1) <= release; -- 9
					when X"3e" => keys(4)(2) <= release; -- 8
					when X"3d" => keys(4)(3) <= release; -- 7
					when X"36" => keys(4)(4) <= release; -- 6
					
					when X"4d" => keys(5)(0) <= release; -- P
					when X"44" => keys(5)(1) <= release; -- O
					when X"43" => keys(5)(2) <= release; -- I
					when X"3c" => keys(5)(3) <= release; -- U
					when X"35" => keys(5)(4) <= release; -- Y
					
					when X"5a" => keys(6)(0) <= release; -- ENTER
					when X"4b" => keys(6)(1) <= release; -- L
					when X"42" => keys(6)(2) <= release; -- K
					when X"3b" => keys(6)(3) <= release; -- J
					when X"33" => keys(6)(4) <= release; -- H
					
					when X"29" => keys(7)(0) <= release; -- SPACE
					when X"14" => keys(7)(1) <= release; -- CTRL (Symbol Shift)
					when X"3a" => keys(7)(2) <= release; -- M
					when X"31" => keys(7)(3) <= release; -- N
					when X"32" => keys(7)(4) <= release; -- B
					
					-- Cursor keys - these are actually extended (E0 xx), but
					-- the scancodes for the numeric keypad cursor keys are
					-- are the same but without the extension, so we'll accept
					-- the codes whether they are extended or not
					when X"6B" => 	keys(0)(0) <= release; -- Left (CAPS 5)
									keys(3)(4) <= release;
					when X"72" =>	keys(0)(0) <= release; -- Down (CAPS 6)
									keys(4)(4) <= release;
					when X"75" =>	keys(0)(0) <= release; -- Up (CAPS 7)
									keys(4)(3) <= release;
					when X"74" =>	keys(0)(0) <= release; -- Right (CAPS 8)
									keys(4)(2) <= release;
									
					-- Other special keys sent to the ULA as key combinations
					when X"66" =>	keys(0)(0) <= release; -- Backspace (CAPS 0)
									keys(4)(0) <= release;
					when X"58" =>	keys(0)(0) <= release; -- Caps lock (CAPS 2)
									keys(3)(1) <= release;
					when X"76" =>	keys(0)(0) <= release; -- Escape (CAPS SPACE)
									keys(7)(0) <= release;
					
					when others =>
						null;
					end case;
				end if;
			end if;
		end if;
	end process;

end keyboard_arch;
