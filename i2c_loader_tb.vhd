library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity i2c_loader_tb is
end i2c_loader_tb;

architecture test of i2c_loader_tb is
component i2c_loader is
port (
	CLK			:	in	std_logic;
	CLKEN		:	in	std_logic;
	nRESET		:	in	std_logic;
	
	I2C_SCL		:	inout	std_logic;
	I2C_SDA		:	inout	std_logic;
	
	IS_DONE		:	out std_logic;
	IS_ERROR		:	out	std_logic
	);
end component;
signal clk : std_logic := '0';
signal clken : std_logic := '1';
signal nreset : std_logic := '0';
signal scl : std_logic := 'Z';
signal sda : std_logic := 'Z';
signal done : std_logic;
signal error : std_logic;
begin
  uut: i2c_loader port map(
    clk,clken,nreset,scl,sda,done,error);
    
  clk <= not clk after 100 ps;
  
  process
    begin
      wait for 500 ps;
      nreset <= '1';
    end process;
end test;

