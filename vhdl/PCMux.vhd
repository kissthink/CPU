library ieee;
use ieee.std_logic_1164.all;

entity PCMux is
  
  port (
    CPU_CLK : in  std_logic;
    PC_Src  : in  std_logic;
    PC_New  : in  std_logic_vector(15 downto 0);
    PC_1    : in  std_logic_vector(15 downto 0);
    PC_Next : out std_logic_vector(15 downto 0)
    );

end PCMux;

architecture PCMux_Arch of PCMux is

begin  -- PCMux_Arch

  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      if PC_Src = '0' then
        PC_Next <= PC_1;
      else
        PC_Next <= PC_Next;
      end if;
    end if;
  end process;

end PCMux_Arch;
