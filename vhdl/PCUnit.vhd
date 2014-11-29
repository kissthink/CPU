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

begin  -- PCUnit_Arch

  Force_Nop <= PC_Src;
  ID_EX_Clear <= PC_Src;
  
  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      case BranchCtrl is
        when "001" =>                   -- JR
          New_PC <= RxVal;
          PC_Src <= '1';
        when "010" =>                   -- B
          New_PC <= PC_1 + SignImm;
          PC_Src <= '1';
        when "011" =>                   -- BEQZ
          New_PC <= PC_1 + SignImm;
          if RxVal = X"0000" then
            PC_Src <= '1';
          else
            PC_Src <= '0';
          end if;
        when "100" =>                   -- BNEQZ
          New_PC <= PC_1 + SignImm;
          if RxVal = X"0000" then
            PC_Src <= '0';
          else
            PC_Src <= '1';
          end if;
        when "101" =>                   -- BTEQZ
          New_PC <= PC_1 + SignImm;
          if RtVal = X"0000" then
            PC_Src <= '1';
          else
            PC_Src <= '0';
          end if;
        when others =>                  -- Not B/J
          PC_Src <= '0';
      end case;
    end if;
  end process;

end PCUnit_Arch;
