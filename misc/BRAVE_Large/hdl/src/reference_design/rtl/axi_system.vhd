-------------------------------------------------------
--! @file       axi_system.vhd
--! @brief      simple AXI infrastructure with AXI UART only
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

use work.AddrDecoderPkg.all;
use work.AxiPkg.all;
use work.ApbPkg.all;

entity axi_system is
  port (
    s_axi_aclk    : in std_logic;
    s_axi_aresetn : in std_logic;

    s_axi_master : in  AxiMasterType;
    s_axi_slave  : out AxiSlaveType;

    uart_txd_o : out std_logic;
    uart_rxd_i : in  std_logic;

    irq_o : out std_logic
  );
end entity axi_system;

architecture struct of axi_system is
  constant NR_AXI_MASTERS : natural := 1;
  constant AXI_ADDR_MAP_TABLE : AddrMappingTable(0 to NR_AXI_MASTERS-1) := (
    0 => (start_addr => X"1000_0000", end_addr => X"1FFF_FFFF")--,
    --1 => (start_addr => X"2000_0000", end_addr => X"2FFF_FFFF")
  );

  signal axi_masters : AxiMasterArray(NR_AXI_MASTERS-1 downto 0);
  signal axi_slaves  : AxiSlaveArray(NR_AXI_MASTERS-1 downto 0);

  -- constant NR_APB_MASTERS : natural := 2;
  -- constant APB_ADDR_MAP_TABLE : AddrMappingTable(0 to NR_APB_MASTERS-1) := (
  --   -- APB register slave example
  --   0 => (start_addr => X"1000_0000", end_addr => X"1000_0FFF"),
  --   -- APB UART slave
  --   1 => (start_addr => X"1000_1000", end_addr => X"1000_1FFF")
  -- );

  -- signal apb_masters : ApbMasterArray(NR_APB_MASTERS-1 downto 0);
  -- signal apb_slaves  : ApbSlaveArray(NR_APB_MASTERS-1 downto 0);
begin
  axi_interconnect_1: entity work.axi_interconnect
    generic map (
      NR_MASTERS     => NR_AXI_MASTERS,
      ADDR_MAP_TABLE => AXI_ADDR_MAP_TABLE,
      ADDR_DEC_MSB   => 31,
      ADDR_DEC_LSB   => 0)
    port map (
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      s_axi_master  => s_axi_master,
      s_axi_slave   => s_axi_slave,
      m_axi_masters => axi_masters,
      m_axi_slaves  => axi_slaves);

  axi_bram_1: entity work.axi_bram
    port map (
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      s_axi_master  => axi_masters(0),
      s_axi_slave   => axi_slaves(0));

  -- axi_apb_bridge_1: entity work.axi_apb_bridge
  --   generic map (
  --     ADDR_MAP             => APB_ADDR_MAP_TABLE,
  --     APB_ADDR_DECODE_MSB => 31,
  --     APB_ADDR_DECODE_LSB => 0,
  --     NR_APB_MASTERS      => NR_APB_MASTERS)
  --   port map (
  --     s_axi_aclk    => s_axi_aclk,
  --     s_axi_aresetn => s_axi_aresetn,
  --     s_axi_master  => axi_masters(1),
  --     s_axi_slave   => axi_slaves(1),
  --     m_apb_master  => apb_masters,
  --     m_apb_slave   => apb_slaves);

  -- apb_reg_slave_1: entity work.apb_reg_slave
  --   port map (
  --     clk_i        => s_axi_aclk,
  --     rst_ni       => s_axi_aresetn,
  --     s_apb_master => apb_masters(0),
  --     s_apb_slave  => apb_slaves(0));

  -- apb_uart_1: entity work.apb_uart
  --   port map (
  --     pclk         => s_axi_aclk,
  --     presetn      => s_axi_aresetn,
  --     s_apb_master => apb_masters(1),
  --     s_apb_slave  => apb_slaves(1),
  --     rxd          => uart_rxd_i,
  --     txd          => uart_txd_o,
  --     irq_out      => irq_o);
end architecture struct;
