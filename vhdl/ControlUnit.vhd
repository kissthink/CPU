library ieee;
use ieee.std_logic_1164.all;

entity ControlUnit is
  
  port (
    CPU_CLK    : in  std_logic;
    instruc    : in  std_logic_vector(15 downto 0);
    ForceZero  : in  std_logic;
    RegWrite   : out std_logic;
    RegDataSrc : out std_logic;
    CmpCode    : out std_logic_vector(1 downto 0);
    MemDataSrc : out std_logic;
    MemWrite   : out std_logic;
    MemRead    : out std_logic;
    BranchCtrl : out std_logic_vector(2 downto 0);
    ALU_Op     : out std_logic_vector(2 downto 0);
    ALU_Src1   : out std_logic_vector(2 downto 0);
    ALU_Src2   : out std_logic_vector(1 downto 0);
    RegDst     : out std_logic_vector(2 downto 0)
    );

end ControlUnit;

architecture ControlUnit_Arch of ControlUnit is

  signal output : std_logic_vector(20 downto 0) := (others => '0');  -- all signals
  
begin  -- ControlUnit_Arch

  RegWrite <= output(20);
  RegDataSrc <= output(19);
  CmpCode <= output(18 downto 17);
  MemDataSrc <= output(16);
  MemWrite <= output(15);
  MemRead <= output(14);
  BranchCtrl <= output(13 downto 11);
  ALU_Op <= output(10 downto 8);
  ALU_Src1 <= output(7 downto 5);
  ALU_Src2 <= output(4 downto 3);
  RegDst <= output(2 downto 0);

  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      if ForceZero = '1' then
        output <= (others => '0');
      else
        case instruc(15 downto 11) is
          when "01001" =>                 -- ADDIU
            output <= "1000" & "000" & "000001" & "00111" & "000";
          when "01000" =>                 -- ADDIU3
            output <= "1000" & "000" & "000001" & "00111" & "001";
          when "01100" =>
            case instruc(10 downto 8) is
              when "011" =>               -- ADDSP
                output <= "1000" & "000" & "000001" & "01011" & "011";
              when "000" =>               -- BTEQZ
                output <= "0000" & "000" & "101000" & "00000" & "000";
              when "100" =>               -- MTSP
                output <= "1000" & "000" & "000001" & "00001" & "011";
              when others => null;
            end case;
          when "11100" =>
            case instruc(1 downto 0) is
              when "01" =>                -- ADDU
                output <= "1000" & "000" & "000001" & "00101" & "010";
              when "11" =>                -- SUBU
                output <= "1000" & "000" & "000010" & "00101" & "010";
              when others => null;
            end case;
          when "11101" =>
            case instruc(4 downto 0) is
              when "01100" =>             -- AND
                output <= "1000" & "000" & "000011" & "00101" & "000";
              when "01010" =>             --    CMP
                output <= "1001" & "000" & "000010" & "00101" & "100";
              when "00000" =>
                case instruc(7 downto 5) is
                  when "000" =>           -- JR
                    output <= "0000" & "000" & "001000" & "00000" & "000";
                  when "010" =>           -- MFPC
                    output <= "1000" & "000" & "000001" & "01100" & "000";
                  when others => null;
                end case;
              when "01101" =>             -- OR
                output <= "1000" & "000" & "000100" & "00101" & "000";
              when "01111" =>             -- NOT
                output <= "1000" & "000" & "000111" & "00001" & "000";
              when "00100" =>             -- SLLV
                output <= "1000" & "000" & "000101" & "00101" & "001";
              when "00111" =>             -- SRAV
                output <= "1000" & "000" & "000110" & "00101" & "001";
              when others => null;
            end case;
          when "00010" =>                 -- B
            output <= "0000" & "000" & "010000" & "00000" & "000";
          when "00100" =>                 -- BEQZ
            output <= "0000" & "000" & "011000" & "00000" & "000";
          when "00101" =>                 -- BNEZ
            output <= "0000" & "000" & "100000" & "00000" & "000";
          when "01101" =>                 -- LI
            output <= "1000" & "000" & "000001" & "10000" & "000";
          when "10011" =>                 -- LW
            output <= "1100" & "001" & "000001" & "00111" & "001";
          when "10010" =>                 -- LW_SP
            output <= "1100" & "001" & "000001" & "01011" & "000";
          when "11110" =>
            case instruc(7 downto 0) is
              when X"00" =>               -- MFIH
                output <= "1000" & "000" & "000001" & "00010" & "000";
              when X"01" =>               -- MTIH
                output <= "1000" & "000" & "000001" & "00100" & "101";
              when others => null;
            end case;
          when "00001" =>                 -- NOP
            output <= (others => '0');
          when "00110" =>
            case instruc(1 downto 0) is
              when "00" =>                -- SLL
                output <= "1000" & "000" & "000101" & "10001" & "000";
              when "11" =>                -- SRA
                output <= "1000" & "000" & "000110" & "10001" & "000";
              when others => null;
            end case;
          when "11011" =>                 -- SW
            output <= "0000" & "110" & "000001" & "00111" & "000";
          when "11010" =>                 -- SW_SP
            output <= "0000" & "010" & "000001" & "01011" & "000";
          when "01110" =>                 -- CMPI
            output <= "1001" & "000" & "000010" & "00111" & "100";
          when "01010" =>                 -- SLTI
            output <= "1010" & "000" & "000010" & "00111" & "100";
          when others =>
            output <= (others => '0');
        end case;
      end if;
    end if;
  end process;
  
end ControlUnit_Arch;
