library ieee;
use ieee.std_logic_1164.all;

entity ControlUnit is
  
  port (
    instruc    : in  std_logic_vector(15 downto 0);
    ForceZero  : in  std_logic;
    RegWrite   : out std_logic;
    RegDataSrc : out std_logic_vector(2 downto 0);
    CmpCode    : out std_logic;
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

  signal output : std_logic_vector(20 downto 0) := (others => '0');  -- all signals
  
begin  -- ControlUnit_Arch

  RegWrite <= output(20);
  RegDataSrc <= output(19 downto 17);
  CmpCode <= output(16);
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
          output <= "10000" & "000" & "000001" & "0010000";
        when "01000" =>                 -- ADDIU3
          output <= "10000" & "000" & "000001" & "0010001";
        when "01100" =>
          case instruc(10 downto 8) is
            when "011" =>               -- ADDSP
              output <= "10000" & "000" & "000001" & "1010011";
            when "000" =>               -- BTEQZ
              output <= "00000" & "000" & "101000" & "0000000";
            when "100" =>               -- MTSP
              output <= "11010" & "000" & "000000" & "0000011";
            when others => null;
          end case;
        when "11100" =>
          case instruc(1 downto 0) is
            when "01" =>                -- ADDU
              output <= "10000" & "000" & "000001" & "0001010";
            when "11" =>                -- SUBU
              output <= "10000" & "000" & "000010" & "0001010";
            when others => null;
          end case;
        when "11101" =>
          case instruc(4 downto 0) is
            when "01100" =>             -- AND
              output <= "10000" & "000" & "000011" & "0001000";
            when "01010" =>             -- CMP
              output <= "11110" & "000" & "000010" & "0001100";
            when "00000" =>
              case instruc(7 downto 5) is
                when "000" =>           -- JR
                  output <= "00000" & "000" & "001000" & "0000000";
                when "010" =>           -- MFPC
                  output <= "10100" & "000" & "000000" & "0000000";
                when others => null;
              end case;
            when "01101" =>             -- OR
              output <= "10000" & "000" & "000100" & "0001000";
            when "01111" =>             -- NOT
              output <= "10000" & "000" & "000111" & "0101000";
            when "00100" =>             -- SLLV
              output <= "10000" & "000" & "000101" & "0100001";
            when "00111" =>             -- SRAV
              output <= "10000" & "000" & "000110" & "0100001";
            when others => null;
          end case;
        when "00010" =>                 -- B
          output <= "00000" & "000" & "010000" & "0000000";
        when "00100" =>                 -- BEQZ
          output <= "00000" & "000" & "011000" & "0000000";
        when "00101" =>                 -- BNEZ
          output <= "00000" & "000" & "100000" & "0000000";
        when "01101" =>                 -- LI
          output <= "11100" & "000" & "000000" & "0000000";
        when "10011" =>                 -- LW
          output <= "10010" & "001" & "000001" & "0010001";
        when "10010" =>                 -- LW_SP
          output <= "10010" & "001" & "000001" & "1010000";
        when "11110" =>
          case instruc(7 downto 0) is
            when X"00" =>               -- MFIH
              output <= "10110" & "000" & "000000" & "0000000";
            when X"01" =>               -- MTIH
              output <= "11000" & "000" & "000000" & "0000101";
            when others => null;
          end case;
        when "00001" =>                 -- NOP
          output <= (others => '0');
        when "00110" =>
          case instruc(1 downto 0) is
            when "00" =>                -- SLL
              output <= "10000" & "000" & "000101" & "0110000";
            when "11" =>                -- SRA
              output <= "10000" & "000" & "000110" & "0110000";
            when others => null;
          end case;
        when "11011" =>                 -- SW
          output <= "00000" & "110" & "000001" & "0010000";
        when "11010" =>                 -- SW_SP
          output <= "00000" & "010" & "000001" & "1010000";
        when "01110" =>                 -- CMPI
          output <= "11110" & "000" & "000010" & "0010100";
        when "01010" =>                 -- SLTI
          output <= "11111" & "000" & "000010" & "0010100";
        when others => null;
      end case;
    end if;
  end process;
  
end ControlUnit_Arch;
