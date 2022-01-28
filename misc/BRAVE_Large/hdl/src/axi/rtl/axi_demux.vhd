-------------------------------------------------------
--! @file       axi_demux.vhd
--! @brief      wrapper for custom axi types
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

use work.common_functions_pkg.all;
use work.AxiPkg.all;

entity axi_demux is
  generic (
    --! Number of AXI master ports
    NM : natural range 2 to 8 := 4
  );
  port (
    --! AXI Clock
    s_axi_aclk    : in  std_logic;
    --! AXI asynchronous reset, active low
    s_axi_aresetn : in  std_logic;
    --! Write master port select (valid when awvalid is asserted)
    awsel         : in  std_logic_vector(clog2(NM)-1 downto 0);
    --! Read master port select (valid when arvalid is asserted)
    arsel         : in  std_logic_vector(clog2(NM)-1 downto 0);
    --! Slave Interface master input port
    s_axi_master  : in  AxiMasterType;
    --! Slave Interface slave input port
    s_axi_slave   : out AxiSlaveType;
    --! Master Interface master output ports
    m_axi_masters : out AxiMasterArray(NM-1 downto 0);
    --! Master Interface slave input ports
    m_axi_slaves  : in  AxiSlaveArray(NM-1 downto 0)
  );
end entity axi_demux;

architecture rtl of axi_demux is

  type RegType is record
    --! write channel busy state
    w_busy  : std_logic;
    --! master interface write address data valid control flag
    awvalid : std_logic_vector(NM-1 downto 0);
    --! master interface write data valid control flag
    wvalid  : std_logic_vector(NM-1 downto 0);
    --! stores the current master interface write port index for current transaction
    wsel    : integer range 0 to 2**NM-1;
    --! read channel busy state
    r_busy  : std_logic;
    --! master interface read address data valid control flag
    arvalid : std_logic_vector(NM-1 downto 0);
    --! stores the current master interface read port index for current transaction
    rsel    : integer range 0 to 2**NM-1;
  end record;

  constant C_REG_INIT: RegType := (
    w_busy  => '0',
    awvalid => (others => '0'),
    wvalid  => (others => '0'),
    wsel    => 0,
    r_busy  => '0',
    arvalid => (others => '0'),
    rsel    => 0
  );

  signal r   : RegType := C_REG_INIT;
  signal rin : RegType;

begin

  comb: process (arsel, awsel, m_axi_slaves, r, s_axi_master) is
    variable v : RegType;
  begin
    v := r;

  -------------------------------------------------------------------------------------------------
  --    WRITE CHANNEL PROCESSING
  -------------------------------------------------------------------------------------------------

    if (s_axi_master.awvalid and not r.w_busy) = '1' then
      v.w_busy := '1';
      v.wsel := to_integer(unsigned(awsel));
      v.awvalid(v.wsel) := '1';
      v.wvalid(v.wsel) := '1';
    end if;

    for i in m_axi_slaves'range loop
      if (r.awvalid(i) and m_axi_slaves(i).awready) = '1' then
        v.awvalid(i) := '0';
      end if;

      if (r.wvalid(i) and s_axi_master.wvalid and m_axi_slaves(i).wready) = '1' then
        v.wvalid(i) := not s_axi_master.w.last;
      end if;
    end loop;

    if (r.w_busy and (s_axi_master.bready and m_axi_slaves(r.wsel).bvalid)) = '1' then
      v.w_busy := '0';
    end if;

  -------------------------------------------------------------------------------------------------
  --    READ CHANNEL PROCESSING
  -------------------------------------------------------------------------------------------------

    if (s_axi_master.arvalid and not r.r_busy) = '1' then
      v.r_busy := '1';
      v.rsel   := to_integer(unsigned(arsel));
      v.arvalid(v.rsel) := '1';
    end if;

    for i in m_axi_slaves'range loop
      if (r.arvalid(i) and m_axi_slaves(i).arready) = '1' then
        v.arvalid(i) := '0';
      end if;
    end loop;

    if (r.r_busy and s_axi_master.rready and m_axi_slaves(r.rsel).rvalid) = '1' then
      v.r_busy := not m_axi_slaves(r.rsel).r.last;
    end if;

  -------------------------------------------------------------------------------------------------
  --    OUTPUT ASSIGNMENTS
  -------------------------------------------------------------------------------------------------
    s_axi_slave.awready <= r.awvalid(r.wsel) and m_axi_slaves(r.wsel).awready;
    s_axi_slave.arready <= r.arvalid(r.rsel) and m_axi_slaves(r.rsel).arready;

    s_axi_slave.wready <= r.wvalid(r.wsel) and m_axi_slaves(r.wsel).wready;
    s_axi_slave.bvalid <= r.w_busy and m_axi_slaves(r.wsel).bvalid;
    s_axi_slave.b      <= m_axi_slaves(r.wsel).b;
    s_axi_slave.rvalid <= r.r_busy and m_axi_slaves(r.rsel).rvalid;
    s_axi_slave.r      <= m_axi_slaves(r.rsel).r;

    for i in m_axi_masters'range loop
      m_axi_masters(i).awvalid <= '0';
      m_axi_masters(i).wvalid  <= '0';
      m_axi_masters(i).bready  <= '0';

      m_axi_masters(i).arvalid <= '0';
      m_axi_masters(i).rready  <= '0';

      m_axi_masters(i).aw         <= s_axi_master.aw;
      m_axi_masters(i).aw.lock(1) <= '0';
      m_axi_masters(i).w          <= s_axi_master.w;

      m_axi_masters(i).ar         <= s_axi_master.ar;
      m_axi_masters(i).ar.lock(1) <= '0';

      m_axi_masters(i).awvalid <= r.awvalid(i);
      m_axi_masters(i).arvalid <= r.arvalid(i);

      m_axi_masters(i).wvalid <= r.wvalid(i) and s_axi_master.wvalid;
    end loop;

    --m_axi_masters(r.wsel).wvalid <= r.wvalid and s_axi_master.wvalid;
    m_axi_masters(r.wsel).bready <= r.w_busy and s_axi_master.bready;

    m_axi_masters(r.rsel).rready <= r.r_busy and s_axi_master.rready;

    rin <= v;
  end process;

  ff: process (s_axi_aclk, s_axi_aresetn) is
  begin
    if s_axi_aresetn = '0' then
      r <= C_REG_INIT;
    elsif rising_edge(s_axi_aclk) then
      r <= rin;
    end if;
  end process ff;

end architecture rtl;
