library ieee;
use ieee.std_logic_1164.all;

entity HazardUnit is
  
  port (
    ID_EX_Rx      : in  std_logic_vector(2 downto 0);
    ID_EX_Ry      : in  std_logic_vector(2 downto 0);
    ID_EX_RegDst  : in  std_logic_vector(2 downto 0);
    ID_EX_MemRead : in  std_logic;
    IF_ID_Rx      : in  std_logic_vector(2 downto 0);
    IF_ID_Ry      : in  std_logic_vector(2 downto 0);
    Force_Nop     : out std_logic;
    IF_ID_Keep    : out std_logic
    );

end HazardUnit;

architecture HazardUnit_Arch of HazardUnit is

  signal Rs : std_logic_vector(2 downto 0) := "111";
  signal enable : std_logic := '0';
  
begin  -- HazardUnit_Arch

  Rs <= ID_EX_Rx when ID_EX_RegDst = "000" else
        ID_EX_Ry when ID_EX_RegDst = "001" else
        "111";
  
  enable <= '1' when ID_EX_MemRead = '1' and (Rs = IF_ID_Rx or Rs = IF_ID_Ry) else
            '0';

  IF_ID_Keep <= enable;
  Force_Nop <= enable;

end HazardUnit_Arch;
