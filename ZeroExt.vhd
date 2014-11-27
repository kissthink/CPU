library ieee;
use ieee.std_logic_1164.all;

entity ZeroExt is
  
  port (
    input  : in  std_logic_vector(7 downto 0);  -- instruction LI only
    output : out std_logic_vector(15 downto 0)  -- ZeroExt Imm
    );

end ZeroExt;

architecture ZeroExt_Arch of ZeroExt is

begin  -- ZeroExt_Arch

  output(7 downto 0) <= input;
  output(15 downto 8) <= (others => '0');

end ZeroExt_Arch;
