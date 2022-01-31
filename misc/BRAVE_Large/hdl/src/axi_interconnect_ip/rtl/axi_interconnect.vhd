-------------------------------------------------------
--! @file       axi_interconnect.vhd
--! @brief      AXI decoder and address management for interconnect
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
use work.AddrDecoderPkg.all;
use work.AxiPkg.all;

entity axi_interconnect is
  generic (
    --! Number of master ports
    NR_MASTERS     : natural range 1 to 8 := 4;
    --! Address mapping table (one address range per ports)
    ADDR_MAP_TABLE : AddrMappingTable     := C_ADDR_MAPPING_TABLE_DEFAULT(0 to 3);
    --! MSB position used to decode address
    ADDR_DEC_MSB   : natural              := 31;
    --! LSB position used to decode address
    ADDR_DEC_LSB   : natural              := 0
  );
  port (
    --! AXI Clock
    s_axi_aclk    : in  std_logic;
    --! Axi asynchronous reset, active low
    s_axi_aresetn : in  std_logic;
    --! Slave Interface master input port
    s_axi_master  : in  AxiMasterType;
    --! Slave Interface slave input port
    s_axi_slave   : out AxiSlaveType;
    --! Master Interface master output ports
    m_axi_masters : out AxiMasterArray(NR_MASTERS-1 downto 0);
    --! Master Interface master input ports
    m_axi_slaves  : in  AxiSlaveArray(NR_MASTERS-1 downto 0)
  );
end entity axi_interconnect;

architecture struct of axi_interconnect is

  constant NM : positive := NR_MASTERS + 1;

  signal awsel, arsel : std_logic_vector(clog2(NM)-1 downto 0);
  signal axi_masters  : AxiMasterArray(NM-1 downto 0);
  signal axi_slaves   : AxiSlaveArray(NM-1 downto 0);

begin

  addr_decoder: process (s_axi_master)
    variable w_slv_idx, r_slv_idx : integer;
  begin
    addr_map_decode(ADDR_MAP_TABLE, ADDR_DEC_MSB, ADDR_DEC_LSB, s_axi_master.aw.addr, w_slv_idx);
    addr_map_decode(ADDR_MAP_TABLE, ADDR_DEC_MSB, ADDR_DEC_LSB, s_axi_master.ar.addr, r_slv_idx);
    awsel <= std_logic_vector(to_unsigned(w_slv_idx, awsel'length));
    arsel <= std_logic_vector(to_unsigned(r_slv_idx, arsel'length));
  end process addr_decoder;

  demux_inst: entity work.axi_demux
    generic map (NM => NM)
    port map (
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      awsel         => awsel,
      arsel         => arsel,
      s_axi_master  => s_axi_master,
      s_axi_slave   => s_axi_slave,
      m_axi_masters => axi_masters,
      m_axi_slaves  => axi_slaves);

  slave_err : entity work.axi_slave_err
    generic map ( AXI_ERR_RESP => C_AXI_RESP_DECERR )
    port map (
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      s_axi_master  => axi_masters(NR_MASTERS),
      s_axi_slave   => axi_slaves(NR_MASTERS));

  m_axi_masters <= axi_masters(NR_MASTERS-1 downto 0);
  axi_slaves(NR_MASTERS-1 downto 0) <= m_axi_slaves;

end architecture struct;
