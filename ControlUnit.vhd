library ieee;
use ieee.std_logic_1164.all;

entity ControlUnit is
  
  port (
    instruc    : in  std_logic_vector(15 downto 0);
    ForceZero  : in  std_logic;
    RegWrite   : out std_logic;
    RegDataSrc : out std_logic_vector(2 downto 0);
    MemDataSrc : out std_logic;
    MemWrite   : out std_logic;
    MemRead    : out std_logic;
    BranchCtrl : out std_logic_vector(2 downto 0);
    ALU_Op     : out std_logic_vector(2 downto 0);
    ALU_Src1   : out std_logic_vector(1 downto 0);
    ALU_Src2   : out std_logic_vector(1 downto 0);
    RegDst     : out std_logic_vector(2 downto 0)
    );

end ControlUnit;

architecture ControlUnit_Arch of ControlUnit is

  signal output : std_logic_vector(19 downto 0) := X"00000";  -- all signals
  
begin  -- ControlUnit_Arch

  RegWrite <= output(19);
  RegDataSrc <= output(18 downto 16);
  MemDataSrc <= output(15);
  MemWrite <= output(14);
  MemRead <= output(13);
  BranchCtrl <= output(12 downto 10);
  ALU_Op <= output(9 downto 7);
  ALU_Src1 <= output(6 downto 5);
  ALU_Src2 <= output(4 downto 3);
  RegDst <= output(2 downto 0);

  process (instruc)
  begin  -- process
    if ForceZero = '1' then
      output <= (others => '0');
    else
      case instruc(15 downto 11) is
        when "01001" =>                 -- ADDIU
          output <= "1000" & "000" & "000001" & "0010000";
        when "01000" =>                 -- ADDIU3
          output <= "1000" & "000" & "000001" & "0010001";
        when "01100" =>
          case instruc(10 downto 8) is
            when "011" =>               -- ADDSP
              output <= "1000" & "000" & "000001" & "1010011";
            when "000" =>               -- BTEQZ
              output <= "0000" & "000" & "101000" & "0000000";
            when "100" =>               -- MTSP
              output <= "1101" & "000" & "000000" & "0000011";
            when others => null;
          end case;
        when "11100" =>
          case instruc(1 downto 0) is
            when "01" =>                -- ADDU
              output <= "1000" & "000" & "000001" & "0001010";
            when "11" =>                -- SUBU
              output <= "1000" & "000" & "000010" & "0001010";
            when others => null;
          end case;
        when "11101" =>
          case instruc(4 downto 0) is
            when "01100" =>             -- AND
              output <= "1000" & "000" & "000011" & "0001000";
            when "01010" =>             -- CMP
              output <= "1111" & "000" & "000010" & "0001100";
            when "00000" =>
              case instruc(7 downto 5) is
                when "000" =>           -- JR
                  output <= "0000" & "000" & "001000" & "0000000";
                when "010" =>           -- MFPC
                  output <= "1010" & "000" & "000000" & "0000000";
                when others => null;
              end case;
            when "01101" =>             -- OR
              output <= "1000" & "000" & "000100" & "0001000";
            when "01111" =>             -- NOT
              output <= "1000" & "000" & "000111" & "0101000";
            when "00100" =>             -- SLLV
              output <= "1000" & "000" & "000101" & "0100001";
            when "00111" =>             -- SRAV
              output <= "1000" & "000" & "000110" & "0100001";
            when others => null;
          end case;
        when "00010" =>                 -- B
          output <= "0000" & "000" & "010000" & "0000000";
        when "00100" =>                 -- BEQZ
          output <= "0000" & "000" & "011000" & "0000000";
        when "00101" =>                 -- BNEZ
          output <= "0000" & "000" & "100000" & "0000000";
        when "01101" =>                 -- LI
          output <= "1110" & "000" & "000000" & "0000000";
        when "10011" =>                 -- LW
          output <= "1001" & "001" & "000001" & "0010001";
        when "10010" =>                 -- LW_SP
          output <= "1001" & "001" & "000001" & "1010000";
        when "11110" =>
          case instruc(7 downto 0) is
            when X"00" =>               -- MFIH
              output <= "1011" & "000" & "000000" & "0000000";
            when X"01" =>               -- MTIH
              output <= "1100" & "000" & "000000" & "0000101";
            when others => null;
          end case;
        when "00001" =>                 -- NOP
          output <= (others => '0');
        when "00110" =>
          case instruc(1 downto 0) is
            when "00" =>                -- SLL
              output <= "1000" & "000" & "000101" & "0110000";
            when "11" =>                -- SRA
              output <= "1000" & "000" & "000110" & "0110000";
            when others => null;
          end case;
        when "11011" =>                 -- SW
          output <= "0000" & "110" & "000001" & "0010000";
        when "11010" =>                 -- SW_SP
          output <= "0000" & "010" & "000001" & "1010000";
        when "01110" =>                 -- CMPI
          output <= "1111" & "000" & "000010" & "0010100";
        when "01010" =>                 -- SLTI
          output <= "1111" & "000" & "000010" & "0010100";
        when others => null;
      end case;
    end if;
  end process;
  
end ControlUnit_Arch;
