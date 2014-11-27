library ieee;
use ieee.std_logic_1164.all;

entity ForwardingUnit is
  
  port (
    ID_EX_Rx          : in std_logic_vector(2 downto 0);
    ID_Ex_Ry          : in std_logic_vector(2 downto 0);
    ALU_Src1          : in std_logic_vector(1 downto 0);
    ALU_Src2          : in std_logic_vector(1 downto 0);
    EX_MEM_ALU_Result : in std_logic_vector(15 downto 0);
    EX_MEM_Rd         : in std_logic_vector(2 downto 0);
    EX_MEM_RegWrite   : in std_logic;
    MEM_WB_ALU_Result : in std_logic_vector(15 downto 0);
    MEM_WB_Rd         : in std_logic_vector(2 downto 0);
    MEM_WB_RegWrite   : in std_logic;
    -- highest 2 bits control mux; 16 bits data.
    Forward1          : in std_logic_vector(17 downto 0);
    Forward2          : in std_logic_vector(17 downto 0);
    );

end ForwardingUnit;

architecture ForwardingUnit_Arch of ForwardingUnit is

begin  -- ForwardingUnit_Arch

  

end ForwardingUnit_Arch;
