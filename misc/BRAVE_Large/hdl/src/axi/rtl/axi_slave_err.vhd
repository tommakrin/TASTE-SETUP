-------------------------------------------------------
--! @file       axi_slave_err.vhd
--! @brief      Axi3 slave consuming all AXI transactions and returning a pre-defined error response
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

--! @brief Axi3 slave consuming all AXI transactions and returning a pre-defined error response
entity axi_slave_err is
  generic (
    --! Response value used on AXI transaction completion
    AXI_ERR_RESP : std_logic_vector(1 downto 0) := C_AXI_RESP_SLVERR
  );
  port (
    s_axi_aclk    : in  std_logic;      --! AXI clock
    s_axi_aresetn : in  std_logic;      --! AXI asynchronous reset, active low
    s_axi_master  : in  AxiMasterType;  --! AXI3 master input port
    s_axi_slave   : out AxiSlaveType    --! AXI3 slave output port
  );
end entity axi_slave_err;

architecture rtl of axi_slave_err is
  type RegType is record
    --! write address ready control flag (0 => busy, 1 => idle)
    awready  : std_logic;
    --! stores the current write transaction id
    bid      : std_logic_vector(3 downto 0);
    --! write data ready control flag (0 => block incoming data, 1 => consume incoming data)
    wready   : std_logic;
    --! response valid control flag
    bvalid   : std_logic;
    --! read address ready control flag (0 => busy, 1 => idle)
    arready  : std_logic;
    --! stores the current read transaction id
    rid      : std_logic_vector(3 downto 0);
    --! read data valid control flag
    rvalid   : std_logic;
    --! tracks number of remaining read transfers (valid when arready = '0')
    xfer_cnt : unsigned(3 downto 0);
  end record;

  constant C_REG_INIT : RegType := (
    awready  => '1',
    bid      => (others => '0'),
    wready   => '0',
    bvalid   => '0',
    arready  => '1',
    rid      => (others => '0'),
    rvalid   => '0',
    xfer_cnt => (others => '0')
  );

  signal r : RegType := C_REG_INIT;
  signal rin : RegType;

  signal rlast : std_logic;
begin
  rlast <= '1' when r.xfer_cnt = 0 else '0';

  comb : process (s_axi_master, r, rlast) is
    variable v : RegType;
  begin
    v := r;

  -------------------------------------------------------------------------------------------------
  --    WRITE CHANNEL PROCESSING
  -------------------------------------------------------------------------------------------------

    -- start of write transaction
    if (s_axi_master.awvalid and r.awready) = '1' then
      v.awready := '0';
      v.bid     := s_axi_master.aw.id;
      v.wready  := '1';
    end if;

    -- consume incoming write data until last transfer
    if (s_axi_master.wvalid and r.wready) = '1' then
      v.wready := not s_axi_master.w.last;
      v.bvalid := s_axi_master.w.last;
    end if;

    -- end of write transaction
    if (s_axi_master.bready and r.bvalid) = '1' then
      v.bvalid  := '0';
      v.awready := '1';
    end if;

  -------------------------------------------------------------------------------------------------
  --    READ CHANNEL PROCESSING
  -------------------------------------------------------------------------------------------------

    -- start of read transaction
    if (s_axi_master.arvalid and r.arready) = '1' then
      v.arready := '0';
      v.rid := s_axi_master.ar.id;
      v.rvalid := '1';
      v.xfer_cnt := unsigned(s_axi_master.ar.len);
    end if;

    -- send output data until last transfer
    if (s_axi_master.rready and r.rvalid) = '1' then
      if rlast = '1' then
        v.arready := '1';
        v.rvalid  := '0';
      else
        v.xfer_cnt := v.xfer_cnt - 1;
      end if;
    end if;

    rin <= v;

  -------------------------------------------------------------------------------------------------
  --    OUTPUT ASSIGNMENTS
  -------------------------------------------------------------------------------------------------
    s_axi_slave.awready <= r.awready;
    s_axi_slave.wready  <= r.wready;
    s_axi_slave.bvalid  <= r.bvalid;
    s_axi_slave.b       <= (
      id => r.bid, resp => AXI_ERR_RESP
    );

    s_axi_slave.arready <= r.arready;
    s_axi_slave.rvalid  <= r.rvalid;
    s_axi_slave.r       <= (
      id => r.rid, data => (others => '0'), last => rlast, resp => AXI_ERR_RESP
    );
  end process comb;

  ff: process (s_axi_aclk, s_axi_aresetn) is
  begin
    if s_axi_aresetn = '0' then
      r.awready <= C_REG_INIT.awready;
      r.wready  <= C_REG_INIT.wready;
      r.bvalid  <= C_REG_INIT.bvalid;
      r.arready <= C_REG_INIT.arready;
      r.rvalid  <= C_REG_INIT.rvalid;
    elsif rising_edge(s_axi_aclk) then
      r <= rin;
    end if;
  end process ff;
end architecture rtl;
