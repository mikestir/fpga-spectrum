library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ps2_intf_tb is

end ps2_intf_tb;

architecture tb of ps2_intf_tb is
component ps2_intf is
port(
	CLK			:	in	std_logic;
	nRESET		:	in	std_logic;
	
	-- PS/2 interface (could be bi-dir)
	PS2_CLK		:	in	std_logic;
	PS2_DATA	:	in	std_logic;
	
	-- Byte-wide data interface - only valid for one clock
	-- so must be latched externally if required
	DATA		:	out	std_logic_vector(7 downto 0);
	VALID		:	out	std_logic;
	ERROR		:	out	std_logic
	);
end component;
signal CLK : std_logic := '0';
signal nRESET : std_logic := '0';
signal PS2_CLK : std_logic := '1';
signal PS2_DATA : std_logic := '1';
signal DATA  : std_logic_vector(7 downto 0);
signal VALID : std_logic;
signal ERROR : std_logic;
begin
  uut : ps2_intf port map(
    CLK,nRESET,PS2_CLK,PS2_DATA,DATA,VALID,ERROR);
  
  CLK <= not CLK after 100 ps;
    
  process
  begin
    wait for 2000 ps;
    nRESET <= '1';
  end process;
  
  process
  begin
    wait for 2000 ps;
    
    PS2_DATA <= '0'; --start
    PS2_CLK <= '0';
    wait for 2000 ps;
    PS2_CLK <= '1';
    wait for 2000 ps;
    
    PS2_DATA <= '1';
    PS2_CLK <= '0';
    wait for 2000 ps;
    PS2_CLK <= '1';
    wait for 2000 ps;
    
    PS2_DATA <= '0';
    PS2_CLK <= '0';
    wait for 2000 ps;
    PS2_CLK <= '1';
    wait for 2000 ps;
    
    
    PS2_DATA <= '1';
    PS2_CLK <= '0';
    wait for 2000 ps;
    PS2_CLK <= '1';
    wait for 2000 ps;
    
    PS2_DATA <= '1'; 
    PS2_CLK <= '0';
    wait for 2000 ps;
    PS2_CLK <= '1';
    wait for 2000 ps;
    
    PS2_DATA <= '0';
    PS2_CLK <= '0';
    wait for 2000 ps;
    PS2_CLK <= '1';
    wait for 2000 ps;
    
    PS2_DATA <= '0';
    PS2_CLK <= '0';
    wait for 2000 ps;
    PS2_CLK <= '1';
    wait for 2000 ps;
    
    PS2_DATA <= '1';
    PS2_CLK <= '0';
    wait for 2000 ps;
    PS2_CLK <= '1';
    wait for 2000 ps;
    
    PS2_DATA <= '1';
    PS2_CLK <= '0';
    wait for 2000 ps;
    PS2_CLK <= '1';
    wait for 2000 ps;
    
    PS2_DATA <= '0'; -- odd parity
    PS2_CLK <= '0';
    wait for 2000 ps;
    PS2_CLK <= '1';
    wait for 2000 ps;
    
    PS2_DATA <= '1'; -- stop
    PS2_CLK <= '0';
    wait for 2000 ps;
    PS2_CLK <= '1';
    wait for 2000 ps;
  end process;

end tb;