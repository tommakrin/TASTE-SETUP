-------------------------------------------------------
--! @file       axi_cdc.vhd
--! @brief      Clock domain changer for AXI
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

use work.AxiPkg.all;

entity axi_cdc is
  port (
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;
    s_axi_master  : in  AxiMasterType;
    s_axi_slave   : out AxiSlaveType;
    m_axi_aclk    : in  std_logic;
    m_axi_aresetn : in  std_logic;
    m_axi_master  : out AxiMasterType;
    m_axi_slave   : in  AxiSlaveType
  );
end entity axi_cdc;

architecture struct of axi_cdc is

  signal aw_full, aw_empty : std_logic;
  signal s_aw, m_aw        : std_logic_vector(C_AXI_ADDR_CHANNEL_WIDTH-1 downto 0);

  signal w_full, w_empty : std_logic;
  signal s_w, m_w        : std_logic_vector(C_AXI_WRITE_DATA_CHANNEL_WIDTH-1 downto 0);

  signal b_full, b_empty : std_logic;
  signal s_b, m_b        : std_logic_vector(C_AXI_RESP_CHANNEL_WIDTH-1 downto 0);

  signal ar_full, ar_empty : std_logic;
  signal s_ar, m_ar        : std_logic_vector(C_AXI_ADDR_CHANNEL_WIDTH-1 downto 0);

  signal r_full, r_empty : std_logic;
  signal s_r, m_r        : std_logic_vector(C_AXI_READ_DATA_CHANNEL_WIDTH-1 downto 0);

begin

  -------------------------------------------------------------------------------------------------
  --    WRITE ADDRESS CHANNEL
  -------------------------------------------------------------------------------------------------
  s_axi_slave.awready <= not aw_full;
  s_aw <= axi_addr_flatten(s_axi_master.aw);

  aw_async_fifo_inst: entity work.async_fifo
    generic map (
      DW => C_AXI_ADDR_CHANNEL_WIDTH,
      AW => 3)
    port map (
      wr_clk_i  => s_axi_aclk,
      wr_rst_ni => s_axi_aresetn,
      wr_en_i   => s_axi_master.awvalid,
      full_o    => aw_full,
      data_i    => s_aw,
      rd_clk_i  => m_axi_aclk,
      rd_rst_ni => m_axi_aresetn,
      rd_en_i   => m_axi_slave.awready,
      empty_o   => aw_empty,
      data_o    => m_aw);

  m_axi_master.aw <= axi_addr_unflatten(m_aw);
  m_axi_master.awvalid <= not aw_empty;

  -------------------------------------------------------------------------------------------------
  --    WRITE DATA CHANNEL
  -------------------------------------------------------------------------------------------------
  s_axi_slave.wready <= not w_full;
  s_w <= axi_write_data_flatten(s_axi_master.w);

  w_async_fifo_inst: entity work.async_fifo
    generic map (
      DW => C_AXI_WRITE_DATA_CHANNEL_WIDTH,
      AW => 3)
    port map (
      wr_clk_i  => s_axi_aclk,
      wr_rst_ni => s_axi_aresetn,
      wr_en_i   => s_axi_master.wvalid,
      full_o    => w_full,
      data_i    => s_w,
      rd_clk_i  => m_axi_aclk,
      rd_rst_ni => m_axi_aresetn,
      rd_en_i   => m_axi_slave.wready,
      empty_o   => w_empty,
      data_o    => m_w);

  m_axi_master.w <= axi_write_data_unflatten(m_w);
  m_axi_master.wvalid <= not w_empty;

  -------------------------------------------------------------------------------------------------
  --    WRITE RESP CHANNEL
  -------------------------------------------------------------------------------------------------
  m_axi_master.bready <= not b_full;
  m_b <= axi_resp_flatten(m_axi_slave.b);

  b_async_fifo_inst: entity work.async_fifo
    generic map (
      DW => C_AXI_RESP_CHANNEL_WIDTH,
      AW => 3)
    port map (
      wr_clk_i  => m_axi_aclk,
      wr_rst_ni => m_axi_aresetn,
      wr_en_i   => m_axi_slave.bvalid,
      full_o    => b_full,
      data_i    => m_b,
      rd_clk_i  => s_axi_aclk,
      rd_rst_ni => s_axi_aresetn,
      rd_en_i   => s_axi_master.bready,
      empty_o   => b_empty,
      data_o    => s_b);

  s_axi_slave.b <= axi_resp_unflatten(s_b);
  s_axi_slave.bvalid <= not b_empty;

  -------------------------------------------------------------------------------------------------
  --    READ ADDRESS CHANNEL
  -------------------------------------------------------------------------------------------------
  s_axi_slave.arready <= not ar_full;
  s_ar <= axi_addr_flatten(s_axi_master.ar);

  ar_async_fifo_inst: entity work.async_fifo
    generic map (
      DW => C_AXI_ADDR_CHANNEL_WIDTH,
      AW => 3)
    port map (
      wr_clk_i  => s_axi_aclk,
      wr_rst_ni => s_axi_aresetn,
      wr_en_i   => s_axi_master.arvalid,
      full_o    => ar_full,
      data_i    => s_ar,
      rd_clk_i  => m_axi_aclk,
      rd_rst_ni => m_axi_aresetn,
      rd_en_i   => m_axi_slave.arready,
      empty_o   => ar_empty,
      data_o    => m_ar);

  m_axi_master.ar <= axi_addr_unflatten(m_ar);
  m_axi_master.arvalid <= not ar_empty;

  -------------------------------------------------------------------------------------------------
  --    READ DATA CHANNEL
  -------------------------------------------------------------------------------------------------
  m_axi_master.rready <= not r_full;
  m_r <= axi_read_data_flatten(m_axi_slave.r);

  r_async_fifo_inst: entity work.async_fifo
    generic map (
      DW => C_AXI_READ_DATA_CHANNEL_WIDTH,
      AW => 3)
    port map (
      wr_clk_i  => m_axi_aclk,
      wr_rst_ni => m_axi_aresetn,
      wr_en_i   => m_axi_slave.rvalid,
      full_o    => r_full,
      data_i    => m_r,
      rd_clk_i  => s_axi_aclk,
      rd_rst_ni => s_axi_aresetn,
      rd_en_i   => s_axi_master.rready,
      empty_o   => r_empty,
      data_o    => s_r);

  s_axi_slave.r <= axi_read_data_unflatten(s_r);
  s_axi_slave.rvalid <= not r_empty;

end architecture struct;
