library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity video_tb is

end video_tb;

architecture video_tb_arch of video_tb is
component video
port (
	-- Master clock (28 MHz)
	CLK			:	in std_logic;
	-- Video domain clock enable (14 MHz)
	CLKEN		:	in std_logic;
	-- Master reset
	nRESET 		: 	in std_logic;

	-- Mode
	VGA			:	in std_logic;

	-- Memory interface
	VID_A		:	out	std_logic_vector(12 downto 0);
	VID_D_IN	:	in	std_logic_vector(7 downto 0);
	nVID_RD	:	out	std_logic;
	nWAIT		:	out	std_logic;
	
	-- IO interface
	BORDER_IN	:	in	std_logic_vector(2 downto 0);

	-- Video outputs
	R			:	out	std_logic_vector(3 downto 0);
	G			:	out	std_logic_vector(3 downto 0);
	B			:	out	std_logic_vector(3 downto 0);
	nVSYNC		:	out std_logic;
	nHSYNC		:	out std_logic;
	nCSYNC		:	out	std_logic;
	nHCSYNC		:	out std_logic;
	IS_BORDER	: 	out std_logic;
	IS_VALID	:	out std_logic;
	
	-- Clock outputs, might be useful
	PIXCLK		:	out std_logic;
	FLASHCLK	: 	out std_logic;
	
	-- Interrupt to CPU (asserted for 32 T-states, 64 ticks)
	nIRQ		:	out	std_logic
	);
end component;
signal clk :  std_logic := '0';
signal clken : std_logic;
signal clken_cpu : std_logic;

signal clken_counter : std_logic_vector(2 downto 0) := "000";

signal nreset : std_logic := '0';

signal vga : std_logic := '1';
signal vid_a : std_logic_vector(12 downto 0);
signal vid_d_in : std_logic_vector(7 downto 0) := "10101010";
signal nvid_rd : std_logic;
signal nwait : std_logic;

signal border_in : std_logic_vector(2 downto 0) := "111";
signal r : std_logic_vector(3 downto 0);
signal g : std_logic_vector(3 downto 0);
signal b : std_logic_vector(3 downto 0);
signal nvsync : std_logic;
signal nhsync : std_logic;
signal ncsync : std_logic;
signal nhcsync : std_logic;

signal is_border : std_logic;
signal is_valid : std_logic;

signal pixclk : std_logic;
signal flashclk : std_logic;

signal nirq : std_logic;

begin
  uut: video port map (
  clk,clken,nreset,
  vga,vid_a,vid_d_in,nvid_rd,nwait,
  border_in,r,g,b,nvsync,nhsync,ncsync,nhcsync,
  is_border,is_valid,pixclk,flashclk,nirq
  );
  
  clken_cpu <= not (clken_counter(0) or clken_counter(1) or clken_counter(2));
  clken <= clken_counter(0);
  
  -- clk
  process
  begin
    wait for 50 ps;
    
    clk <= not clk;
  end process;
  
  -- clken
  process
  begin
    wait for 100 ps;
    
    if nreset = '1' then
      clken_counter <= clken_counter + '1';
    end if;
  end process;
  
  process
  begin
    wait for 500 ps;
    
    -- release reset
    nreset <= '1';
  end process;
end video_tb_arch;
