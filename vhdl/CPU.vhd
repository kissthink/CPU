library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity CPU is
  
  port (
    clk50     : in std_logic;           -- 50M
    rst       : in std_logic;
    
    input     : in   std_logic_vector(15 downto 0);
    
    --Ram1Addr  : out   std_logic_vector(17 downto 0);
    --Ram1Data  : inout std_logic_vector(15 downto 0);
    --Ram1OE    : out   std_logic;
    --Ram1RW    : out   std_logic;
    --Ram1EN    : out   std_logic;
    
    Ram2Addr  : out   std_logic_vector(17 downto 0);
    Ram2Data  : inout std_logic_vector(15 downto 0);
    Ram2OE    : out   std_logic;
    Ram2RW    : out   std_logic;
    Ram2EN    : out   std_logic;

    rdn       : out   std_logic;
    wrn       : out   std_logic;

    output    : out   std_logic_vector(15 downto 0)
    );

end CPU;

architecture CPU_Arch of CPU is

  component IM
    port (
      clk50     : in    std_logic;
      PC        : in    std_logic_vector(15 downto 0);
      Ram2Addr  : out   std_logic_vector(17 downto 0);
      Ram2Data  : inout std_logic_vector(15 downto 0);
      Ram2OE    : out   std_logic;
      Ram2RW    : out   std_logic;
      Ram2EN    : out   std_logic;
      instruc   : out   std_logic_vector(15 downto 0)
      );
  end component;

  component RegisterFile
    port (
      CPU_CLK  : in  std_logic;
      RegWrite : in  std_logic;
      Rx, Ry   : in  std_logic_vector(2 downto 0);
      Rd       : in  std_logic_vector(3 downto 0);
      wData    : in  std_logic_vector(15 downto 0);
      RxVal    : out std_logic_vector(15 downto 0);
      RyVal    : out std_logic_vector(15 downto 0);
      RspVal   : out std_logic_vector(15 downto 0);
      RtVal    : out std_logic_vector(15 downto 0);
      RihVal   : out std_logic_vector(15 downto 0)
      );
  end component;

  component SignExt
    port (
      CPU_CLK : in  std_logic;
      input   : in  std_logic_vector(15 downto 0);
      output  : out std_logic_vector(15 downto 0)
      );
  end component;

  component ZeroExt
    port (
      CPU_CLK : in  std_logic;
      input   : in  std_logic_vector(7 downto 0);
      output  : out std_logic_vector(15 downto 0)
      );
  end component;

  component ControlUnit
    port (
      CPU_CLK    : in  std_logic;
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
  end component;

  
  signal CPU_CLK : std_logic;
  
  signal PC : std_logic_vector(15 downto 0) := X"0000";
  signal PC_1 : std_logic_vector(15 downto 0);
  signal IF_ID_PC_1 : std_logic_vector(15 downto 0);
  signal IF_ID_Instruc : std_logic_vector(15 downto 0);

  signal RegWrite : std_logic := '0';
  signal Rd : std_logic_vector(3 downto 0);
  signal wData : std_logic_vector(15 downto 0);
  signal ForceZero : std_logic := '0';
  signal ID_EX_PC_1 : std_logic_vector(15 downto 0);
  signal ID_EX_Rx : std_logic_vector(10 downto 8);
  signal ID_EX_Ry : std_logic_vector(7 downto 5);
  signal ID_EX_Rz : std_logic_vector(4 downto 2);
  signal ID_EX_RxVal : std_logic_vector(15 downto 0);
  signal ID_EX_RyVal : std_logic_vector(15 downto 0);
  signal ID_EX_RspVal : std_logic_vector(15 downto 0);
  signal ID_EX_RtVal : std_logic_vector(15 downto 0);
  signal ID_EX_RihVal : std_logic_vector(15 downto 0);
  signal ID_EX_SignImm : std_logic_vector(15 downto 0);
  signal ID_EX_ZeroImm : std_logic_vector(15 downto 0);
  signal ID_EX_RegWrite : std_logic := '0';
  signal ID_EX_RegDataSrc : std_logic_vector(2 downto 0);
  signal ID_EX_CmpCode : std_logic;
  signal ID_EX_MemDataSrc : std_logic;
  signal ID_EX_MemWrite : std_logic := '0';
  signal ID_EX_MemRead : std_logic := '0';
  signal ID_EX_BranchCtrl : std_logic_vector(2 downto 0);
  signal ID_EX_ALU_Op : std_logic_vector(2 downto 0);
  signal ID_EX_ALU_Src1 : std_logic_vector(1 downto 0);
  signal ID_EX_ALU_Src2 : std_logic_vector(1 downto 0);
  signal ID_EX_RegDst : std_logic_vector(2 downto 0);
  
begin  -- CPU_Arch

  rdn <= '1';
  wrn <= '1';

  output <= IF_ID_Instruc when input = X"0000" else
            PC when input = X"0001" else
            IF_ID_PC_1 when input = X"0002" else
            (others => '1');
  
  process (clk50)
  begin  -- process
    if rising_edge(clk50) then
      CPU_CLK <= not CPU_CLK;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Start / IF
  -----------------------------------------------------------------------------

  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      PC_1 <= PC + 1;
    end if;
  end process;

  IF_ID_PC_1 <= PC_1;

  PC <= PC_1;
  
  InstrMem : IM
    port map (
      clk50  => clk50,
      PC       => PC,
      Ram2Addr => Ram2Addr,
      Ram2Data => Ram2Data,
      Ram2OE   => Ram2OE,
      Ram2RW   => Ram2RW,
      Ram2EN   => Ram2EN,
      instruc  => IF_ID_Instruc
      );
  -----------------------------------------------------------------------------
  -- IF / ID
  -----------------------------------------------------------------------------

  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      ID_EX_PC_1 <= IF_ID_PC_1;
      ID_EX_Rx <= IF_ID_Instruc(10 downto 8);
      ID_EX_Ry <= IF_ID_Instruc(7 downto 5);
      ID_EX_Rz <= IF_ID_Instruc(4 downto 2);
    end if;
  end process;
  
  RegFile : RegisterFile
    port map (
      CPU_CLK  => CPU_CLK,
      RegWrite => RegWrite,
      Rx       => IF_ID_Instruc(10 downto 8),
      Ry       => IF_ID_Instruc(7 downto 5),
      Rd       => Rd,
      wData    => wData,
      RxVal    => ID_EX_RxVal,
      RyVal    => ID_EX_RyVal,
      RspVal   => ID_EX_RspVal,
      RtVal    => ID_EX_RtVal,
      RihVal   => ID_EX_RihVal
      );

  SignExtend : SignExt
    port map (
      CPU_CLK => CPU_CLK,
      input   => IF_ID_Instruc,
      output  => ID_EX_SignImm
      );

  ZeroExtend : ZeroExt
    port map (
      CPU_CLK => CPU_CLK,
      input   => IF_ID_Instruc(7 downto 0),
      output  => ID_EX_ZeroImm
      );

  CtrlUnit : ControlUnit
    port map (
      CPU_CLK    => CPU_CLK,
      instruc    => IF_ID_Instruc,
      ForceZero  => ForceZero,
      RegWrite   => ID_EX_RegWrite,
      RegDataSrc => ID_EX_RegDataSrc,
      CmpCode    => ID_EX_CmpCode,
      MemDataSrc => ID_EX_MemDataSrc,
      MemWrite   => ID_EX_MemWrite,
      MemRead    => ID_EX_MemRead,
      BranchCtrl => ID_EX_BranchCtrl,
      ALU_Op     => ID_EX_ALU_Op,
      ALU_Src1   => ID_EX_ALU_Src1,
      ALU_Src2   => ID_EX_ALU_Src2,
      RegDst     => ID_EX_RegDst
      );
  -----------------------------------------------------------------------------
  -- ID / EX
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- EX / MEM
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- MEM / WB
  -----------------------------------------------------------------------------

  
end CPU_Arch;
