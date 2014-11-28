library ieee;
use ieee.std_logic_1164.all;

entity RegDataUnit is
  
  port (
    CPU_CLK     : in  std_logic;
    RegDataSrc  : in  std_logic_vector(2 downto 0);
    CmpCode     : in  std_logic;
    zero        : in  std_logic;
    neg         : in  std_logic;
    RegDataCtrl : out std_logic_vector(3 downto 0)
    );

end RegDataUnit;

architecture RegDataUnit_Arch of RegDataUnit is

begin  -- RegDataUnit_Arch

  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      if RegDataSrc = "111" then
        if (CmpCode = '0' and zero = '0') or (CmpCode = '1' and neg = '0') then
          RegDataCtrl <= "0111";
        elsif (CmpCode = '0' and zero = '1') or (CmpCode = '1' and neg = '1') then
          RegDataCtrl <= "1000";
        end if;
      else
        RegDataCtrl <= '0' & RegDataSrc;
      end if;
    end if;
  end process;

end RegDataUnit_Arch;
