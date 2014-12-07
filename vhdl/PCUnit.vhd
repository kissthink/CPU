library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity PCUnit is
  
  port (
    CPU_CLK     : in  std_logic;
    BranchCtrl  : in  std_logic_vector(2 downto 0);
    PC_1        : in  std_logic_vector(15 downto 0);
    SignImm     : in  std_logic_vector(15 downto 0);
    RxVal       : in  std_logic_vector(15 downto 0);
    RtVal       : in  std_logic_vector(15 downto 0);
    PC_New      : out std_logic_vector(15 downto 0);
    PC_Src      : out std_logic;
    Force_Nop   : out std_logic;
    ID_EX_Clear : out std_logic
    );

end PCUnit;

architecture PCUnit_Arch of PCUnit is

  signal GoBranch : std_logic;
  
begin  -- PCUnit_Arch

  PC_Src <= GoBranch;
  Force_Nop <= GoBranch;
--  ID_EX_Clear <= GoBranch;
  ID_EX_Clear <= '0';
  
  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      case BranchCtrl is
        when "001" =>                   -- JR
          PC_New <= RxVal;
          GoBranch <= '1';
        when "010" =>                   -- B
          PC_New <= PC_1 + SignImm;
          GoBranch <= '1';
        when "011" =>                   -- BEQZ
          PC_New <= PC_1 + SignImm;
          if RxVal = X"0000" then
            GoBranch <= '1';
          else
            GoBranch <= '0';
          end if;
        when "100" =>                   -- BNEQZ
          PC_New <= PC_1 + SignImm;
          if RxVal = X"0000" then
            GoBranch <= '0';
          else
            GoBranch <= '1';
          end if;
        when "101" =>                   -- BTEQZ
          PC_New <= PC_1 + SignImm;
          if RtVal = X"0000" then
            GoBranch <= '1';
          else
            GoBranch <= '0';
          end if;
        when "110" =>
          PC_New <= X"0006";
          GoBranch <= '1';
        when others =>                  -- Not B/J
          GoBranch <= '0';
      end case;
    end if;
  end process;

end PCUnit_Arch;
