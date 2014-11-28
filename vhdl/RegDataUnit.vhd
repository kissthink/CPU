library ieee;
use ieee.std_logic_1164.all;

entity RegDataUnit is
  
  port (
    RegDataSrc  : in  std_logic_vector(2 downto 0);
    CmpCode     : in  std_logic;
    zero        : in  std_logic;
    neg         : in  std_logic;
    RegDataCtrl : out std_logic_vector(3 downto 0)
    );

end RegDataUnit;

architecture RegDataUnit_Arch of RegDataUnit is

begin  -- RegDataUnit_Arch

  RegDataCtrl <= "0111" when RegDataSrc = "111" and CmpCode = '0' and zero = '0' else
                 "0111" when RegDataSrc = "111" and CmpCode = '1' and neg = '0' else
                 -- op : !=
                 "1000" when RegDataSrc = "111" and CmpCode = '0' and zero = '1' else
                 -- op : <
                 "1000" when RegDataSrc = "111" and CmpCode = '1' and neg = '1' else
                 "1111";

end RegDataUnit_Arch;
