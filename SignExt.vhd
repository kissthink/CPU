library ieee;
use ieee.std_logic_1164.all;

entity SignExt is
  
  port (
    input  : in  std_logic_vector(15 downto 0);  -- instruction
    output : out std_logic_vector(15 downto 0)  -- SignExt Imm
    );

end SignExt;

architecture SignExt_Arch of SignExt is

  signal op : std_logic_vector(4 downto 0);
  
begin  -- SignExt_Arch

  op <= input(15 downto 11);
  
  process (op)
  begin  -- process
    case op is
      when "01000" =>                   -- ADDIU3
        output(3 downto 0) <= input(3 downto 0);
        output(15 downto 4) <= (others => input(3));
      when "10011" =>                   -- LW
        output(4 downto 0) <= input(4 downto 0);
        output(15 downto 5) <= (others => input(4));
      when "11011" =>                   -- SW
        output(4 downto 0) <= input(4 downto 0);
        output(15 downto 5) <= (others => input(4));
      when "00010" =>                   -- B
        output(10 downto 0) <= input(10 downto 0);
        output(15 downto 11) <= (others => input(10));
      when others =>                    -- default
        output(7 downto 0) <= input(7 downto 0);
        output(15 downto 8) <= (others => input(7));
    end case;
  end process;

end SignExt_Arch;
