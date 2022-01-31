-------------------------------------------------------
--! @file       axi_apb_bridge.vhd
--! @brief      AXI3 to APB Bridge
--! @author     Régis Spadotti (Scalian) 
--! @author     Michel Francis (Scalian)
--! @author     F.Manni (Cnes)
--!
--!-----------------------------------------------------------------------------------------------
--! @copyright  CNES   
--! @verbatim
--! This File is licensed as MIT license
--! Permission is hereby granted, free of charge, to any person obtaining a copy
--! of this software and associated documentation files (the "Software"), to deal
--! in the Software without restriction, including without limitation the rights
--! to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--! copies of the Software, and to permit persons to whom the Software is
--! furnished to do so, subject to the following conditions:
--! 
--! The above copyright notice and this permission notice shall be included in all
--! copies or substantial portions of the Software.
--! 
--! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--! SOFTWARE.
--! @endverbatim
--!
--!-----------------------------------------------------------------------------------------------
--! * Version         : V1.1
--! * Version history : 
--!    * V1 :  2021-03-08 : Scalian : Creation
--!    * V2 :  2021-05-19 : F.Manni (CNES) : 
--!                         * Improve documentation
--! 
--!-----------------------------------------------------------------------------------------------
--! File Creation date : 2021-03-08
--! Project name       : R5 reference Design
--! 
--!-----------------------------------------------------------------------------------------------
--! Softwares             :  
--!     * PC          : Linux Ubuntu 20.04LTS 
--!     * Editor      : Visual studio code 2021-05 + Eclipse 2019-12
--!     * Synthetizer : Nxmap 3.5.0.4 (29th march 2021)
--!     * P&R         : Nxmap 3.5.0.4 (29th march 2021)
--! Automatic VHDL coding :  NO 
--! 
--!-----------------------------------------------------------------------------------------------
--! @details  
--!  
--! @todo provide a detailed description and comments tag for this entity for doxygen
--!
--! Limitations : None
--!
-------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.AxiPkg.all;
use work.ApbPkg.all;
use work.AddrDecoderPkg.all;

--! @brief AXI3 to APB Bridge
entity axi_apb_bridge is
  generic (
    --! @brief APB address range configurations.
    --! @details Any address that is outside of the configuration range generates a `DECERR` on the
    --! AXI Interface port.
    ADDR_MAP : AddrMappingTable := (0 => (start_addr => X"0000_1000", end_addr => X"0000_1FFF"));
    --! MSB of APB slaves addresses
    APB_ADDR_DECODE_MSB : natural := 15;
    --! LSB used to decode APB slaves addresses
    APB_ADDR_DECODE_LSB : natural := 0;
    --! Number of APB master ports
    NR_APB_MASTERS : positive := 4
  );
  port (
    --! AXI clock
    s_axi_aclk      : in  std_logic;
    --! Asynchronous reset, active low
    s_axi_aresetn   : in  std_logic;
    --! AXI Slave Interface master input port
    s_axi_master    : in  AxiMasterType;
    --! AXI Slave Interface slave input port
    s_axi_slave     : out AxiSlaveType;
    --! Master APB interface ouput ports
    m_apb_master    : out ApbMasterArray(NR_APB_MASTERS-1 downto 0);
    --! Master APB interface input ports
    m_apb_slave     : in  ApbSlaveArray(NR_APB_MASTERS-1 downto 0)
  );
end axi_apb_bridge;

architecture rtl of axi_apb_bridge is
  type T_STATE is (IDLE, SETUP, DATA);

  type RegType is record
    axi_slave   : AxiSlaveType;
    psel        : std_logic_vector(NR_APB_MASTERS-1 downto 0);
    apb_master  : ApbMasterType;
    wait_wdata  : std_logic;
    apb_index   : natural range 0 to NR_APB_MASTERS;
    state       : T_STATE;
  end record;

  constant C_REG_INIT : RegType := (
    axi_slave   => C_AXI_SLAVE_INIT,
    psel        => (others => '0'),
    apb_master  => C_APB_MASTER_INIT,
    wait_wdata  => '0',
    apb_index   => 0,
    state       => IDLE
  );

  signal r   : RegType := C_REG_INIT;
  signal rin : RegType;

  signal axi_master_filtered : AxiMasterType;
  signal axi_slave_filtered  : AxiSlaveType;

  signal apb_rindex          : natural range 0 to NR_APB_MASTERS;
  signal apb_windex          : natural range 0 to NR_APB_MASTERS;

begin
  assert ADDR_MAP'length <= NR_APB_MASTERS report "ADDR_MAP too big" severity failure;

  axi_filt_inst: entity work.axi_filter
  generic map(
    AXI_MIN_AXSIZE        => 0,
    AXI_MAX_AXSIZE        => 2,
    AXI_MIN_AXLEN         => 0,
    AXI_MAX_AXLEN         => 0,
    AXI_ALLOW_FIXED_BURST => false,
    AXI_ALLOW_INCR_BURST  => true,
    AXI_ALLOW_WRAP_BURST  => true,
    ADDR_MAP              => ADDR_MAP,
    ADDR_MSB              => APB_ADDR_DECODE_MSB,
    ADDR_LSB              => APB_ADDR_DECODE_LSB
  )
  port map(
    s_axi_aclk    => s_axi_aclk,
    s_axi_aresetn => s_axi_aresetn,
    s_axi_master  => s_axi_master,
    s_axi_slave   => s_axi_slave,
    m_axi_master  => axi_master_filtered,
    m_axi_slave   => axi_slave_filtered,
    r_index       => apb_rindex,
    w_index       => apb_windex
  );

  comb : process (m_apb_slave(NR_APB_MASTERS - 1 downto 0), r,
                  axi_master_filtered, apb_rindex, apb_windex)  is
    variable v         : RegType;
  begin
    v := r;

    ----------------------------------------------------------------------------
    --                           ADDRESS CHANNEL                              --
    ----------------------------------------------------------------------------
    v.axi_slave.awready := '0';
    v.axi_slave.arready  := '0';

    -- handle reads with priority over writes
    if (r.state = IDLE) and (r.wait_wdata = '0') and (axi_master_filtered.arvalid = '1') then
      v.axi_slave.arready := '1';
      v.state             := SETUP;
      v.wait_wdata        := '0';

      v.apb_master.paddr  := axi_master_filtered.ar.addr;
      v.apb_master.pprot  := axi_master_filtered.ar.prot;
      v.psel(apb_rindex)  := '1';
      v.apb_master.pwrite := '0';
      v.apb_master.pstrb  := (others => '0');

      v.axi_slave.r.id     := axi_master_filtered.ar.id;

      v.apb_index          := apb_rindex;
    elsif (r.state = IDLE) and (r.wait_wdata = '0') and (axi_master_filtered.awvalid = '1') then
      v.axi_slave.awready := '1';
      v.wait_wdata        := '1';

      v.apb_master.paddr  := axi_master_filtered.aw.addr;
      v.apb_master.pprot  := axi_master_filtered.aw.prot;

      v.axi_slave.b.id    := axi_master_filtered.aw.id;

      v.apb_index         := apb_windex;
    end if;

    ----------------------------------------------------------------------------
    --                             DATA CHANNEL                               --
    ----------------------------------------------------------------------------
    v.axi_slave.wready := '0';

    if (v.state = IDLE) and (r.wait_wdata = '1') then
      if (axi_master_filtered.wvalid) = '1' then
        v.axi_slave.wready  := '1';
        if r.apb_master.paddr(2) = '0' then
          v.apb_master.pwdata := axi_master_filtered.w.data(31 downto 0);
          v.apb_master.pstrb  := axi_master_filtered.w.strb(3 downto 0);
        else
          v.apb_master.pwdata := axi_master_filtered.w.data(63 downto 32);
          v.apb_master.pstrb  := axi_master_filtered.w.strb(7 downto 4);
        end if;
        v.psel(r.apb_index) := '1';
        v.apb_master.pwrite := '1';
        v.wait_wdata := '0';
        v.state      := SETUP;
      end if;
    end if;

----------------------------------------------------------------------------
--                             RESP CHANNEL                               --
----------------------------------------------------------------------------
    if r.state = SETUP then
      v.apb_master.penable := '1';
      v.state := DATA;
    end if;

    -- End of APB transaction
    if (r.state = DATA) and (m_apb_slave(r.apb_index).pready = '1') then
      v.apb_master.penable := '0';
      v.psel(r.apb_index)    := '0';

      if r.apb_master.pwrite = '0' then
        if r.apb_master.paddr(2) = '0' then
          v.axi_slave.r.data := X"0000_0000" & m_apb_slave(r.apb_index).prdata;
        else
          v.axi_slave.r.data := m_apb_slave(r.apb_index).prdata & X"0000_0000";
        end if;
        v.axi_slave.r.resp(1) := m_apb_slave(r.apb_index).pslverr;
        v.axi_slave.rvalid    := '1';
        v.axi_slave.r.last    := '1';
      else
        v.axi_slave.b.resp(1) := m_apb_slave(r.apb_index).pslverr;
        v.axi_slave.bvalid    := '1';
      end if;
    end if;

    -- End of AXI transaction
    if (r.state = DATA) then
      -- handshake on read transaction
      if (r.axi_slave.rvalid and axi_master_filtered.rready) = '1' then
        v.axi_slave.rvalid := '0';
        v.state            := IDLE;
      end if;
      -- handshake on write transaction
      if (r.axi_slave.bvalid and axi_master_filtered.bready) = '1' then
        v.axi_slave.bvalid := '0';
        v.state            := IDLE;
      end if;
    end if;


    ----------------------------------------------------------------------------
    --                               OUTPUTS                                  --
    ----------------------------------------------------------------------------
    axi_slave_filtered         <= r.axi_slave;
    axi_slave_filtered.awready <= v.axi_slave.awready;
    axi_slave_filtered.wready  <= v.axi_slave.wready;
    axi_slave_filtered.arready <= v.axi_slave.arready;

    for I in m_apb_master'range loop
      m_apb_master(I).pprot   <= r.apb_master.pprot;
      m_apb_master(I).pwrite  <= r.apb_master.pwrite;
      m_apb_master(I).penable <= r.apb_master.penable;
      m_apb_master(I).pstrb   <= r.apb_master.pstrb;
      m_apb_master(I).pwdata  <= r.apb_master.pwdata;
      -- Every transfer is seen as a 32-bits wide transfer on APB
      m_apb_master(I).paddr   <= r.apb_master.paddr(31 downto 2) & "00";
      m_apb_master(I).psel    <= r.psel(I);
    end loop;

    rin <= v;
  end process;

  ff : process (s_axi_aclk, s_axi_aresetn) is
  begin
    if s_axi_aresetn = '0' then
      r <= C_REG_INIT;
    elsif rising_edge(s_axi_aclk) then
      r <= rin;
    end if;
  end process;
end rtl;
