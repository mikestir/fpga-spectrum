library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity i2s_intf_tb is
end i2s_intf_tb;

architecture test of i2s_intf_tb is
component i2s_intf is
generic(
	mclk_rate : positive := 12000000;
	sample_rate : positive := 8000;
	preamble : positive := 1; -- I2S
	word_length : positive := 16
	);
port (
	-- 2x MCLK in (e.g. 24 MHz for WM8731 USB mode)
	CLK			:	in	std_logic;
	nRESET		:	in	std_logic;
	
	-- Parallel IO
	PCM_INL		:	out	std_logic_vector(word_length - 1 downto 0);
	PCM_INR		:	out	std_logic_vector(word_length - 1 downto 0);
	PCM_OUTL	:	in	std_logic_vector(word_length - 1 downto 0);
	PCM_OUTR	:	in	std_logic_vector(word_length - 1 downto 0);
	
	-- Codec interface (right justified mode)
	-- MCLK is generated at half of the CLK input
	I2S_MCLK	:	out	std_logic;
	-- LRCLK is equal to the sample rate and is synchronous to
	-- MCLK.  It must be related to MCLK by the oversampling ratio
	-- given in the codec datasheet.
	I2S_LRCLK	:	out	std_logic;
	
	-- Data is shifted out on the falling edge of BCLK, sampled
	-- on the rising edge.  The bit rate is determined such that
	-- it is fast enough to fit preamble + word_length bits into
	-- each LRCLK half cycle.  The last cycle of each word may be 
	-- stretched to fit to LRCLK.  This is OK at least for the 
	-- WM8731 codec.
	-- The first falling edge of each timeslot is always synchronised
	-- with the LRCLK edge.
	I2S_BCLK	:	out	std_logic;
	-- Output bitstream
	I2S_DOUT	:	out	std_logic;
	-- Input bitstream
	I2S_DIN		:	in	std_logic
	);
end component;

signal clk : std_logic := '0';
signal nreset : std_logic := '0';
signal pcminl : std_logic_vector(15 downto 0);
signal pcminr : std_logic_vector(15 downto 0);
signal pcmoutl : std_logic_vector(15 downto 0) := "0011001100110011";
signal pcmoutr : std_logic_vector(15 downto 0) := "1010101010101010";

signal i2smclk : std_logic;
signal i2slrclk : std_logic;
signal i2sbclk : std_logic;
signal i2sdout : std_logic;
signal i2sdin : std_logic := '0';
begin
  uut : i2s_intf port map (clk,nreset,pcminl,pcminr,pcmoutl,pcmoutr,
  i2smclk,i2slrclk,i2sbclk,i2sdout,i2sdin);
  
  -- Serial loopback
  i2sdin <= i2sdout;
  
  clk <= not clk after 100 ps;
  
  process
    begin
      wait for 500 ps;
      
      nreset <= '1';
    end process;
    
  process
  begin
      wait for 800000 ps;
      
      pcmoutl <= "1110001110001100";
      pcmoutr <= "0110110110110111";
  end process;
end test;