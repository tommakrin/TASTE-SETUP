-------------------------------------------------------
--! @file       axi_pkg.vhd
--! @brief      AXI custom type definition
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

--! @brief AXI3 related definitions.
package AxiPkg is
  -------------------------------------------------------------------------------------------------
  --    AXI ADDRESS CHANNEL
  -------------------------------------------------------------------------------------------------

  --! @brief AXI3 address channel definition
  type AxiAddrChannelType is record
    id    : std_logic_vector(3 downto 0);   --! Address Id
    addr  : std_logic_vector(31 downto 0);  --! Address
    len   : std_logic_vector(3 downto 0);   --! Burst length
    size  : std_logic_vector(2 downto 0);   --! Transfer size
    burst : std_logic_vector(1 downto 0);   --! Burst type
    lock  : std_logic_vector(1 downto 0);   --! Lock type
    cache : std_logic_vector(3 downto 0);   --! Cache type
    prot  : std_logic_vector(2 downto 0);   --! Protection type
  end record;

  --! @brief Default value of an `AxiAddrChannelType` signal
  constant C_AXI_ADDR_CHANNEL_INIT : AxiAddrChannelType := (
    id    => (others => '0'),
    addr  => (others => '0'),
    len   => (others => '0'),
    size  => (others => '0'),
    burst => (others => '0'),
    lock  => (others => '0'),
    cache => (others => '0'),
    prot  => (others => '0')
  );

  --! @brief AXI3 Address channel width
  constant C_AXI_ADDR_CHANNEL_WIDTH : natural :=
    4 + 32 + 4 + 3 + 2 + 2 + 4 + 3;

  function axi_addr_flatten(chan : in AxiAddrChannelType) return std_logic_vector;
  function axi_addr_unflatten(v : std_logic_vector) return AxiAddrChannelType;

  -------------------------------------------------------------------------------------------------
  --    AXI DATA CHANNEL
  -------------------------------------------------------------------------------------------------

  --! @brief AXI3 write data channel definition
  type AxiWriteDataChannelType is record
    id   : std_logic_vector(3 downto 0);  --! Data id
    data : std_logic_vector(63 downto 0); --! Data
    strb : std_logic_vector(7 downto 0);  --! Data strobes
    last : std_logic;                     --! Last transfer flag
  end record;

  --! @brief Default value of an `AxiWriteDataChannelType` signal
  constant C_AXI_WRITE_DATA_CHANNEL_INIT : AxiWriteDataChannelType := (
    id   => (others => '0'),
    data => (others => '0'),
    strb => (others => '0'),
    last => '0'
  );

  --! @brief AXI3 write data channel width
  constant C_AXI_WRITE_DATA_CHANNEL_WIDTH : natural :=
    4 + 64 + 8 + 1;

  function axi_write_data_flatten(chan : in AxiWriteDataChannelType) return std_logic_vector;
  function axi_write_data_unflatten(v : std_logic_vector) return AxiWriteDataChannelType;

  --! @brief AXI3 read data channel definition
  type AxiReadDataChannelType is record
    id   : std_logic_vector(3 downto 0);   --! Data id
    data : std_logic_vector(63 downto 0);  --! Data
    last : std_logic;                      --! Last transfer flag
    resp : std_logic_vector(1 downto 0);   --! Transfer response
  end record;

  --! @brief Default value of an `AxiWriteDataChannelType` signal
  constant C_AXI_READ_DATA_CHANNEL_INIT : AxiReadDataChannelType := (
    id   => (others => '0'),
    data => (others => '0'),
    last => '0',
    resp => (others => '0')
  );

  --! @brief AXI3 write data channel width
  constant C_AXI_READ_DATA_CHANNEL_WIDTH : natural :=
    4 + 64 + 1 + 2;

  function axi_read_data_flatten(chan : in AxiReadDataChannelType) return std_logic_vector;
  function axi_read_data_unflatten(v : std_logic_vector) return AxiReadDataChannelType;

  -------------------------------------------------------------------------------------------------
  --    AXI RESPONSE CHANNEL
  -------------------------------------------------------------------------------------------------

  --! @brief AXI3 response channel definition
  type AxiRespChannelType is record
    id   : std_logic_vector(3 downto 0); --! Response id
    resp : std_logic_vector(1 downto 0); --! Transfer response
  end record;

  --! @brief Default value of an `AxiRespChannelType` signal
  constant C_AXI_RESP_CHANNEL_INIT : AxiRespChannelType := (
    id   => (others => '0'),
    resp => (others => '0')
  );

  --! @brief AXI3 write data channel width
  constant C_AXI_RESP_CHANNEL_WIDTH : natural :=
    4 + 2;

  function axi_resp_flatten(chan : in AxiRespChannelType) return std_logic_vector;
  function axi_resp_unflatten(v : std_logic_vector) return AxiRespChannelType;

  -------------------------------------------------------------------------------------------------
  --    AXI MASTER
  -------------------------------------------------------------------------------------------------

  --! @brief AXI3 master definition
  type AxiMasterType is record
    aw      : AxiAddrChannelType;       --! Write address channel
    awvalid : std_logic;                --! Write address valid control flag
    w       : AxiWriteDataChannelType;  --! Write data channel
    wvalid  : std_logic;                --! Write data valid control flag
    bready  : std_logic;                --! Response ready control flag
    ar      : AxiAddrChannelType;       --! Read address channel
    arvalid : std_logic;                --! Read address valid control flag
    rready  : std_logic;                --! Read data ready control flag
  end record;

  --! @brief Default value of an `AxiMasterType` signal
  constant C_AXI_MASTER_INIT : AxiMasterType := (
    aw      => C_AXI_ADDR_CHANNEL_INIT,
    awvalid => '0',
    w       => C_AXI_WRITE_DATA_CHANNEL_INIT,
    wvalid  => '0',
    bready  => '0',
    ar      => C_AXI_ADDR_CHANNEL_INIT,
    arvalid => '0',
    rready  => '0'
  );

  --! @brief Array of `AxiWriteMasterType` definition
  type AxiMasterArray is array (natural range<>) of AxiMasterType;

  -------------------------------------------------------------------------------------------------
  --    AXI SLAVE
  -------------------------------------------------------------------------------------------------

  --! @brief AXI3 slave definition
  type AxiSlaveType is record
    awready : std_logic;                --! Write address ready control flag
    wready  : std_logic;                --! Write ready control flag
    b       : AxiRespChannelType;       --! Response channel
    bvalid  : std_logic;                --! Response valid control flag
    arready : std_logic;                --! Read address ready control flag
    r       : AxiReadDataChannelType;   --! Read data channel
    rvalid  : std_logic;                --! Read data valid control flag
  end record;

  --! @brief Default value of an `AxiWriteSlaveType` signal
  constant C_AXI_SLAVE_INIT : AxiSlaveType := (
    awready => '0',
    wready  => '0',
    b       => C_AXI_RESP_CHANNEL_INIT,
    bvalid  => '0',
    arready => '0',
    r       => C_AXI_READ_DATA_CHANNEL_INIT,
    rvalid  => '0'
  );

  --! @brief Array of `AxiWriteSlaveType` definition
  type AxiSlaveArray is array (natural range<>) of AxiSlaveType;

  -------------------------------------------------------------------------------------------------
  --    AXI CONSTANTS
  -------------------------------------------------------------------------------------------------

  --! @brief AXI `OKAY` response value
  constant C_AXI_RESP_OKAY   : std_logic_vector(1 downto 0) := "00";
  --! @brief AXI `EXOKAY` (exclusive) response value
  constant C_AXI_RESP_EXOKAY : std_logic_vector(1 downto 0) := "01";
  --! @brief AXI `SLVERR` (slave error) response value
  constant C_AXI_RESP_SLVERR : std_logic_vector(1 downto 0) := "10";
  --! @brief AXI `DECERR` (decode error) response value
  constant C_AXI_RESP_DECERR : std_logic_vector(1 downto 0) := "11";
end package AxiPkg;

package body AxiPkg is
  function axi_addr_flatten(chan : in AxiAddrChannelType) return std_logic_vector is
    alias c    : AxiAddrChannelType is chan;
    variable v : std_logic_vector(C_AXI_ADDR_CHANNEL_WIDTH-1 downto 0);
  begin
    v := c.id & c.addr & c.len & c.size & c.burst & c.lock & c.cache & c.prot;

    return v;
  end function axi_addr_flatten;

  function axi_addr_unflatten(v : std_logic_vector) return AxiAddrChannelType is
    variable c : AxiAddrChannelType;
  begin
    c.id    := v(53 downto 50);
    c.addr  := v(49 downto 18);
    c.len   := v(17 downto 14);
    c.size  := v(13 downto 11);
    c.burst := v(10 downto 9);
    c.lock  := v(8 downto 7);
    c.cache := v(6 downto 3);
    c.prot  := v(2 downto 0);

    return c;
  end function axi_addr_unflatten;

  function axi_write_data_flatten(chan : in AxiWriteDataChannelType) return std_logic_vector is
    alias c    : AxiWriteDataChannelType is chan;
    variable v : std_logic_vector(C_AXI_WRITE_DATA_CHANNEL_WIDTH-1 downto 0);
  begin
    v := c.id & c.data & c.strb & c.last;

    return v;
  end function axi_write_data_flatten;

  function axi_write_data_unflatten(v : std_logic_vector) return AxiWriteDataChannelType is
    variable c : AxiWriteDataChannelType;
  begin
    c.id   := v(76 downto 73);
    c.data := v(72 downto 9);
    c.strb := v(8 downto 1);
    c.last := v(0);

    return c;
  end function axi_write_data_unflatten;

  function axi_read_data_flatten(chan : in AxiReadDataChannelType) return std_logic_vector is
    alias c    : AxiReadDataChannelType is chan;
    variable v : std_logic_vector(C_AXI_READ_DATA_CHANNEL_WIDTH-1 downto 0);
  begin
    v := c.id & c.data & c.last & c.resp;

    return v;
  end function axi_read_data_flatten;

  function axi_read_data_unflatten(v : std_logic_vector) return AxiReadDataChannelType is
    variable c : AxiReadDataChannelType;
  begin
    c.id   := v(70 downto 67);
    c.data := v(66 downto 3);
    c.last := v(2);
    c.resp := v(1 downto 0);

    return c;
  end function axi_read_data_unflatten;

  function axi_resp_flatten(chan : in AxiRespChannelType) return std_logic_vector is
    alias c    : AxiRespChannelType is chan;
    variable v : std_logic_vector(C_AXI_RESP_CHANNEL_WIDTH-1 downto 0);
  begin
    v := c.id & c.resp;

    return v;
  end function axi_resp_flatten;

  function axi_resp_unflatten(v : std_logic_vector) return AxiRespChannelType is
    variable c : AxiRespChannelType;
  begin
    c.id   := v(5 downto 2);
    c.resp := v(1 downto 0);

    return c;
  end function axi_resp_unflatten;
end package body AxiPkg;
