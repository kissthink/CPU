library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity CPU is
  
  port (
    clk50     : in std_logic;           -- 50M
    rst       : in std_logic;
    
    input     : in   std_logic_vector(15 downto 0);
    
    Ram1Addr  : out   std_logic_vector(17 downto 0);
    Ram1Data  : inout std_logic_vector(15 downto 0);
    Ram1OE    : out   std_logic;
    Ram1RW    : out   std_logic;
    Ram1EN    : out   std_logic;
    
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

  component ALU
    port (
      op       : in  std_logic_vector(2 downto 0);
      operand1 : in  std_logic_vector(15 downto 0);
      operand2 : in  std_logic_vector(15 downto 0);
      result   : out std_logic_vector(15 downto 0);
      zero     : out std_logic;
      neg      : out std_logic
      );
  end component;

  component ForwardingUnit
    port (
      ID_EX_Rx          : in std_logic_vector(2 downto 0);
      ID_Ex_Ry          : in std_logic_vector(2 downto 0);
      ALU_Src1          : in std_logic_vector(1 downto 0);
      ALU_Src2          : in std_logic_vector(1 downto 0);
      EX_MEM_ALU_Result : in std_logic_vector(15 downto 0);
      EX_MEM_Rd         : in std_logic_vector(2 downto 0);
      EX_MEM_RegWrite   : in std_logic;
      MEM_WB_ALU_Result : in std_logic_vector(15 downto 0);
      MEM_WB_Rd         : in std_logic_vector(3 downto 0);
      MEM_WB_RegWrite   : in std_logic;
      Forward1          : out std_logic_vector(18 downto 0);
      Forward2          : out std_logic_vector(18 downto 0);
      );
  end component;

  component RegDataUnit
    port (
      CPU_CLK     : in  std_logic;
      RegDataSrc  : in  std_logic_vector(2 downto 0);
      CmpCode     : in  std_logic;
      zero        : in  std_logic;
      neg         : in  std_logic;
      RegDataCtrl : out std_logic_vector(3 downto 0)
      );
  end component;

  component DM
    port (
      clk50     : in    std_logic;
      rdn, wrn  : in    std_logic;
      wMemAddr  : in    std_logic_vector(15 downto 0);
      wMemData  : in    std_logic_vector(15 downto 0);
      MemRead   : in    std_logic;
      MemWrite  : in    std_logic;
      Ram1Addr  : out   std_logic_vector(17 downto 0);
      Ram1Data  : inout std_logic_vector(15 downto 0);
      Ram1OE    : out   std_logic;
      Ram1RW    : out   std_logic;
      Ram1EN    : out   std_logic;
      MemOutput : out   std_logic_vector(15 downto 0)
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

  signal operand1 : std_logic_vector(15 downto 0);
  signal operand2 : std_logic_vector(15 downto 0);
  signal Forward1 : std_logic_vector(18 downto 0);
  signal Forward2 : std_logic_vector(18 downto 0);
  signal EX_MEM_ALU_Result : std_logic_vector(15 downto 0);
  signal EX_MEM_Zero : std_logic;
  signal EX_MEM_Neg : std_logic;
  signal EX_MEM_RegWrite : std_logic;
  signal EX_MEM_RegDataSrc : std_logic_vector(2 downto 0);
  signal EX_MEM_CmpCode : std_logic;
  signal EX_MEM_MemDataSrc : std_logic;
  signal EX_MEM_MemRead : std_logic;
  signal EX_MEM_MemWrite : std_logic;
  signal EX_MEM_PC_1 : std_logic_vector(15 downto 0);
  signal EX_MEM_RihVal : std_logic_vector(15 downto 0);
  signal EX_MEM_RxVal : std_logic_vector(15 downto 0);
  signal EX_MEM_RyVal : std_logic_vector(15 downto 0);
  signal EX_MEM_ZeroImm : std_logic_vector(15 downto 0);
  signal EX_MEM_Rd : std_logic_vector(3 downto 0);

  signal wMemData : std_logic_vector(15 downto 0);
  signal MEM_WB_ALU_Result : std_logic_vector(15 downto 0);
  signal MEM_WB_Rd : std_logic_vector(15 downto 0);
  signal MEM_WB_RegWrite : std_logic;
  signal MEM_WB_PC_1 : std_logic_vector(15 downto 0);
  signal MEM_WB_RihVal : std_logic_vector(15 downto 0);
  signal MEM_WB_RxVal : std_logic_vector(15 downto 0);
  signal MEM_WB_RyVal : std_logic_vector(15 downto 0);
  signal MEM_WB_ZeroImm : std_logic_vector(15 downto 0);
  signal MEM_WB_Rd : std_logic_vector(3 downto 0);
  signal MEM_WB_MemOutput : std_logic_vector(15 downto 0);
  
begin  -- CPU_Arch

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

  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      EX_MEM_RegWrite <= ID_EX_RegWrite;
      EX_MEM_RegDataSrc <= ID_EX_RegDataSrc;
      EX_MEM_CmpCode <= ID_EX_CmpCode;
      EX_MEM_MemDataSrc <= ID_EX_MemDataSrc;
      EX_MEM_MemRead <= ID_EX_MemRead;
      EX_MEM_MemWrite <= ID_EX_MemWrite;
      EX_MEM_PC_1 <= ID_EX_PC_1;
      EX_MEM_RihVal <= ID_EX_RihVal;
      EX_MEM_RxVal <= ID_EX_RxVal;
      EX_MEM_RyVal <= ID_EX_RyVal;
      EX_MEM_ZeroImm <= ID_EX_ZeroImm;
    end if;
  end process;

  -- out : operand1
  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      case Forward1(18) is
        when '1' =>
          operand1 <= Forward1(15 downto 0);
        when '0' =>
          case Forward1(17 downto 16) is
            when "00" =>                -- Rx
              operand1 <= ID_EX_RxVal;
            when "01" =>                -- Ry
              operand1 <= ID_EX_RyVal;
            when "10" =>                -- Rsp
              operand1 <= ID_EX_RspVal;
            when others => null;
          end case;
        when others => null;
      end case;
    end if;
  end process;

  -- out : operand2
  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      case Forward2(18) is
        when '1' =>
          operand2 <= Forward2(15 downto 0);
        when '0' =>
          case Forward2(17 downto 16) is
            when "00" =>                -- Rx
              operand2 <= ID_EX_RxVal;
            when "01" =>                -- Ry
              operand2 <= ID_EX_RyVal;
            when "10" =>                -- SignImm
              operand2 <= ID_EX_SignImm;
            when others => null;
          end case;
        when others => null;
      end case;
    end if;
  end process;

  -- out : Rd
  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      case ID_EX_RegDst is
        when "000" =>                   -- Rx
          EX_MEM_Rd <= '0' & ID_EX_Rx;
        when "001" =>                   -- Ry
          EX_MEM_Rd <= '0' & ID_EX_Ry;
        when "010" =>                   -- Rz
          EX_MEM_Rd <= '0' & ID_EX_Rz;
        when "011" =>                   -- Rsp
          EX_MEM_Rd <= "1000";
        when "100" =>                   -- Rt
          EX_MEM_Rd <= "1001";
        when "101" =>                   -- Rih
          EX_MEM_Rd <= "1010";
        when others => null;
      end case;
    end if;
  end process;
  
  ALU : ALU
    port map (
      op       => ID_EX_ALU_Op,
      operand1 => operand1,
      operand2 => operand2,
      result   => EX_MEM_ALU_Result,
      zero     => EX_MEM_Zero,
      neg      => EX_MEM_Neg
      );

  ForwUnit : ForwardingUnit
    port map (
      ID_EX_Rx          => ID_EX_Rx,
      ID_EX_Ry          => ID_EX_Ry,
      ALU_Src1          => ID_EX_ALU_Src1,
      ALU_Src2          => ID_EX_ALU_Src2,
      EX_MEM_ALU_Result => EX_MEM_ALU_Result,
      EX_MEM_Rd         => EX_MEM_Rd,
      EX_MEM_RegWrite   => EX_MEM_RegWrite,
      MEM_WB_ALU_Result => MEM_WB_ALU_Result,
      MEM_WB_Rd         => MEM_WB_Rd,
      MEM_WB_RegWrite   => MEM_WB_RegWrite,
      Forward1          => Forward1,
      Forward2          => Forward2
      );

  -----------------------------------------------------------------------------
  -- EX / MEM
  -----------------------------------------------------------------------------

  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      MEM_WB_RegWrite <= EX_MEM_RegWrite;
      MEM_WB_ALU_Result <= EX_MEM_ALU_Result;
      MEM_WB_PC_1 <= EX_MEM_PC_1;
      MEM_WB_RihVal <= EX_MEM_RihVal;
      MEM_WB_RxVal <= EX_MEM_RxVal;
      MEM_WB_RyVal <= EX_MEM_RyVal;
      MEM_WB_ZeroImm <= EX_MEM_ZeroImm;
      MEM_WB_Rd <= EX_MEM_Rd;
    end if;
  end process;

  -- out : wMemData
  process (CPU_CLK)
  begin  -- process
    if rising_edge(CPU_CLK) then
      if EX_MEM_MemDataSrc = '0' then
        wMemData <= EX_MEM_RxVal;
      else
        wMemData <= EX_MEM_RyVal;
      end if;
    end if;
  end process;
  
  RegData : RegDataUnit
    port map (
      CPU_CLK    => CPU_CLK,
      RegDataSrc => EX_MEM_RegDataSrc,
      CmpCode    => EX_MEM_CmpCode,
      zero       => EX_MEM_Zero,
      neg        => EX_MEM_Neg,
      RegDataSrc => MEM_WB_RegDataCtrl
      );

  DataMem : DM
    port map (
      clk50     => clk50,
      rdn       => rdn,
      wrn       => wrn,
      wMemAddr  => EX_MEM_ALU_Result,
      wMemData  => wMemData,
      MemRead   => EX_MEM_MemRead,
      MemWrite  => EX_MEM_MemWrite,
      Ram1Addr  => Ram1Addr,
      Ram1Data  => Ram1Data,
      Ram1OE    => Ram1OE,
      Ram1RW    => Ram1RW,
      Ram1EN    => Ram1EN,
      MemOutput => MEM_WB_MemOutput
      );
  
  -----------------------------------------------------------------------------
  -- MEM / WB
  -----------------------------------------------------------------------------

  
end CPU_Arch;
