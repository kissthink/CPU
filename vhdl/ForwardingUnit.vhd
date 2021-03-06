library ieee;
use ieee.std_logic_1164.all;

entity ForwardingUnit is
  
  port (
    ID_EX_Rx          : in std_logic_vector(2 downto 0);
    ID_Ex_Ry          : in std_logic_vector(2 downto 0);
    ALU_Src1          : in std_logic_vector(2 downto 0);
    ALU_Src2          : in std_logic_vector(1 downto 0);
    
    EX_MEM_ALU_Result : in std_logic_vector(15 downto 0);
    wData             : in std_logic_vector(15 downto 0);
    
    EX_MEM_Rd         : in std_logic_vector(3 downto 0);
    EX_MEM_RegWrite   : in std_logic;
    MEM_WB_Rd         : in std_logic_vector(3 downto 0);
    MEM_WB_RegWrite   : in std_logic;
    
    -- [18, 18] : whether use forward ; [17, 16] : ALU_Src; [15, 0] : forward data.
    Forward1          : out std_logic_vector(19 downto 0);
    Forward2          : out std_logic_vector(18 downto 0);
    ForwardB          : out std_logic_vector(16 downto 0)
    );

end ForwardingUnit;

architecture ForwardingUnit_Arch of ForwardingUnit is

  signal UseForward1 : std_logic := '0';
  signal UseForward2 : std_logic := '0';
  signal UseForwardB : std_logic := '0';
  signal ForwardData1 : std_logic_vector(15 downto 0);
  signal ForwardData2 : std_logic_vector(15 downto 0);
  signal ForwardDataB : std_logic_vector(15 downto 0);
  signal Rs : std_logic_vector(3 downto 0);
  signal Rt : std_logic_vector(3 downto 0);
  signal Rb : std_logic_vector(3 downto 0);
  
begin  -- ForwardingUnit_Arch

  Forward1 <= UseForward1 & ALU_Src1 & ForwardData1;
  Forward2 <= UseForward2 & ALU_Src2 & ForwardData2;
  ForwardB <= UseForwardB & ForwardDataB;

  Rs <= '0' & ID_EX_Rx when ALU_Src1 = "001" else  -- Rx
        "1000" when ALU_Src1 = "010" else  -- Rsp
        "1111";

  Rt <= '0' & ID_EX_Ry when ALU_Src2 = "01" else  -- Ry
        "1010" when ALU_Src2 = "10" else  -- Rih
        "1111";

  Rb <= '0' & ID_EX_Rx;

  ForwardData1 <= EX_MEM_ALU_Result when EX_MEM_RegWrite = '1' and EX_MEM_Rd = Rs else
                  wData when MEM_WB_RegWrite = '1' and MEM_WB_Rd = Rs else
                  (others => '0');
  UseForward1 <= '1' when EX_MEM_RegWrite = '1' and EX_MEM_Rd = Rs else
                 '1' when MEM_WB_RegWrite = '1' and MEM_WB_Rd = Rs else
                 '0';

  ForwardData2 <= EX_MEM_ALU_Result when EX_MEM_RegWrite = '1' and EX_MEM_Rd = Rt else
                  wData when MEM_WB_RegWrite = '1' and MEM_WB_Rd = Rt else
                  (others => '0');
  UseForward2 <= '1' when EX_MEM_RegWrite = '1' and EX_MEM_Rd = Rt else
                 '1' when MEM_WB_RegWrite = '1' and MEM_WB_Rd = Rt else
                 '0';

  ForwardDataB <= EX_MEM_ALU_Result when EX_MEM_RegWrite = '1' and EX_MEM_Rd = Rb else
                  wData when MEM_WB_RegWrite = '1' and MEM_WB_Rd = Rb else
                  (others => '0');
  UseForwardB <= '1' when EX_MEM_RegWrite = '1' and EX_MEM_Rd = Rb else
                 '1' when MEM_WB_RegWrite = '1' and MEM_WB_Rd = Rb else
                 '0';

end ForwardingUnit_Arch;
