library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;

entity ALU is
  
  port (
    op       : in  std_logic_vector(2 downto 0);
    operand1 : in  std_logic_vector(15 downto 0);
    operand2 : in  std_logic_vector(15 downto 0);
    result   : out std_logic_vector(15 downto 0);
    zero     : out std_logic;
    neg      : out std_logic
    );

end ALU;

architecture ALU_Arch of ALU is

  signal output : std_logic_vector(15 downto 0);
  signal shiftbits : std_logic_vector(4 downto 0) := "00000";
  
begin  -- ALU_Arch

  shiftbits <= "01000" when operand2(2 downto 0) = "000" else
               "00" & operand2(2 downto 0);
  
  process (op, shiftbits)
  begin  -- process
    case op is
      when "001" =>
        output <= operand1 + operand2;
      when "010" =>
        output <= operand1 - operand2;
      when "011" =>
        output <= operand1 and operand2;
      when "100" =>
        output <= operand1 or operand2;
      when "101" =>
        output <= to_stdlogicvector(to_bitvector(operand1) sll conv_integer(shiftbits));
      when "110" =>
        output <= to_stdlogicvector(to_bitvector(operand1) sra conv_integer(shiftbits));
      when "111" =>
        output <= not operand1;
      when others => null;
    end case;
  end process;

  result <= output;
  
  zero <= '1' when output = X"0000" else
       '0';
  
  neg <= output(15);
  
end ALU_Arch;
