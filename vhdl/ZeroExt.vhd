library ieee;
use ieee.std_logic_1164.all;

entity ZeroExt is
  
  port (
    CPU_CLK : in  std_logic;
    input   : in  std_logic_vector(7 downto 0);  -- instruction LI only
    output  : out std_logic_vector(15 downto 0)  -- ZeroExt Imm
    );

end ZeroExt;

architecture ZeroExt_Arch of ZeroExt is

begin  -- ZeroExt_Arch

  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      output(7 downto 0) <= input;
      output(15 downto 8) <= (others => '0');
    end if;
  end process;

end ZeroExt_Arch;
