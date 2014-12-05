library ieee;
use ieee.std_logic_1164.all;

entity ZeroExt is
  
  port (
    CPU_CLK : in  std_logic;
    input   : in  std_logic_vector(15 downto 0);  -- instruction
    output  : out std_logic_vector(15 downto 0)  -- ZeroExt Imm
    );

end ZeroExt;

architecture ZeroExt_Arch of ZeroExt is

begin  -- ZeroExt_Arch

  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      case input(15 downto 11) is
        when "01101" =>                 -- LI
          output(7 downto 0) <= input(7 downto 0);
          output(15 downto 8) <= (others => '0');
        when "00110" =>                 -- SLL / SRA
          output(2 downto 0) <= input(4 downto 2);
          output(15 downto 3) <= (others => '0');
        when others => null;
      end case;
    end if;
  end process;

end ZeroExt_Arch;
