library ieee;
use ieee.std_logic_1164.all;

entity CPU is
  
  port (
    clk50     : in std_logic;           -- 50M
    clk       : in std_logic;           -- single step
    rst       : in std_logic;
    
    Ram1Addr  : out   std_logic_vector(17 downto 0);
    Ram1Data  : inout std_logic_vector(15 downto 0);
    Ram1OE    : out   std_logic;
    Ram1RW    : out   std_logic;
    Ram1EN    : out   std_logic;
    
    Ram2Addr  : out   std_logic_vector(17 downto 0);
    Ram2Data  : inout std_logic_vector(15 downto 0);
    Ram2OE    : out   std_logic;
    Ram2RW    : out   std_logic;
    Ram2EN    : out   std_logic;

    rdn       : out   std_logic;
    wrn       : out   std_logic;

    input     : out   std_logic_vector(15 downto 0);
    output    : out   std_logic_vector(15 downto 0)
    );

end CPU;

architecture CPU_Arch of CPU is

  signal CPU_CLK : std_logic;
  signal PC : std_logic_vector(15 downto 0) := X"0000";
  signal IF_ID_Instruc : std_logic_vector(15 downto 0);
  
  component IM
    port (
      CPU_CLK   : in    std_logic;
      PC        : in    std_logic_vector(15 downto 0);
      Ram2Addr  : out   std_logic_vector(17 downto 0);
      Ram2Data  : inout std_logic_vector(15 downto 0);
      Ram2OE    : out   std_logic;
      Ram2RW    : out   std_logic;
      Ram2EN    : out   std_logic;
      instruc   : out   std_logic_vector(15 downto 0)
      );
  end component;
  
begin  -- CPU_Arch

  rdn <= '1';
  wrn <= '1';
  output <= IF_ID_Instruc;

  process (clk50)
  begin  -- process
    if rising_edge(clk50) then
      CPU_CLK <= not CPU_CLK;
    end if;
  end process;
  
  InstrMem : IM
    port map (
      CPU_CLK  => clk,                  -- For test
      PC       => PC,
      Ram2Addr => Ram2Addr,
      Ram2Data => Ram2Data,
      Ram2OE   => Ram2OE,
      Ram2RW   => Ram2RW,
      Ram2EN   => Ram2EN,
      instruc  => IF_ID_Instruc
      );
  
end CPU_Arch;
