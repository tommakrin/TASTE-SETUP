-------------------------------------------------------
--! @file       apb_uart.vhd
--! @brief      Add APB interface and IRQ to UART IP
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

use work.ApbPkg.all;

entity apb_uart is
  port (
    pclk    : in std_logic;
    presetn : in std_logic;

    s_apb_master : in  ApbMasterType;
    s_apb_slave  : out ApbSlaveType;

    rxd : in std_logic;
    txd : out std_logic;

    irq_out : out std_logic
  );
end apb_uart;

architecture struct of apb_uart is
   constant VERSION : std_logic_vector(31 downto 0) := x"01151020";

   constant NB_IRQ        : integer := 8;
   constant BAUD_DIV_SIZE : integer := 16;  -- pour descendre a 1200 a partir du 75M

   -- register index
   constant VERSION_IND  : integer := 0;
   constant CONTROL_IND  : integer := 1;
   constant BAUD_IND     : integer := 2;
   constant CONFIG_IND   : integer := 3;
   constant IRQ_STAT_IND : integer := 4;
   constant IRQ_MASK_IND : integer := 5;
   constant IRQ_ACK_IND  : integer := 6;
   constant RXD_IND      : integer := 7;
   constant TXD_IND      : integer := 8;

   -- no status register. Everything is in irq_stat
   signal control_reg  : std_logic_vector(5 downto 0)                 := (others => '0');
   signal baud_reg     : std_logic_vector(BAUD_DIV_SIZE - 1 downto 0) := std_logic_vector(to_unsigned(62500, BAUD_DIV_SIZE));
   signal config_reg   : std_logic_vector(4 downto 0)                 := (others => '0');
   signal irq_stat_reg : std_logic_vector(NB_IRQ - 1 downto 0)        := (others => '0');
   signal irq_mask_reg : std_logic_vector(NB_IRQ - 1 downto 0)        := (others => '0');
   signal irq_ack_reg  : std_logic_vector(NB_IRQ - 1 downto 0)        := (others => '0');
   signal rx_data_reg  : std_logic_vector(7 downto 0);
   signal tx_data_reg  : std_logic_vector(7 downto 0);

   constant CTL_BIT_RESET    : integer := 0;
   constant CTL_BIT_UART_EN  : integer := 1;  -- global enable
   constant CTL_BIT_RX_EN    : integer := 2;  -- receive enable
   constant CTL_BIT_TX_EN    : integer := 3;  -- transmit enable
   constant CTL_BIT_RX_FLUSH : integer := 4;  -- flush input Autoclear
   constant CTL_BIT_TX_FLUSH : integer := 5;  -- flush output Autoclear

   alias cfg_parityEN      : std_logic is config_reg(0);
   alias cfg_parityODD     : std_logic is config_reg(1);
   alias cfg_shift_msb     : std_logic is config_reg(2);
   alias cfg_two_stop_bits : std_logic is config_reg(3);
   alias cfg_7_bits_data   : std_logic is config_reg(4);

   signal swreset  : std_logic;
   signal txreset  : std_logic;
   signal rxreset  : std_logic;
   signal enable   : std_logic;
   signal txenable : std_logic;
   signal rxenable : std_logic;

   -- apb interface
   signal apb_slave : ApbSlaveType;

   -- irq handling
   constant ZERO_IRQ : std_logic_vector(NB_IRQ - 1 downto 0) := (others => '0');

   signal irq_src : std_logic_vector(NB_IRQ - 1 downto 0) := (others => '0');

   constant IRQ_TX_READY : integer := 0;
   constant IRQ_TX_EMPTY : integer := 1;
   constant IRQ_TX_DONE  : integer := 2;
   constant IRQ_TX_OVF   : integer := 3;
   constant IRQ_RX_READY : integer := 4;
   constant IRQ_RX_OERR  : integer := 5;
   constant IRQ_RX_PERR  : integer := 6;
   constant IRQ_RX_FERR  : integer := 7;

   signal txd_wen  : std_logic;
   signal rxd_done : std_logic;
begin
   enable <= control_reg(CTL_BIT_UART_EN);
   swreset <= (not presetn) or control_reg(CTL_BIT_RESET);
   rxreset <= control_reg(CTL_BIT_RX_FLUSH);
   txreset <= control_reg(CTL_BIT_TX_FLUSH);
   rxenable <= control_reg(CTL_BIT_RX_EN);
   txenable <= control_reg(CTL_BIT_TX_EN);

   uartinst : entity work.uart_rxtx
   generic map (
      DIV_WIDTH => BAUD_DIV_SIZE
   )
   Port map (

      clk    => pclk,
      reset  => swreset,
      enable => enable,

      -- configuration
      -- common to TX & RX
      baud        => baud_reg,
      data_7_bits => cfg_7_bits_data,
      parity_en   => cfg_parityEN,
      parity_odd  => cfg_parityODD,
      stop_2      => cfg_two_stop_bits,
      msb_first   => cfg_shift_msb,

      -- TX
      txreset    => txreset,
      txenable   => txenable,
      txdata     => tx_data_reg,
      txdata_w   => txd_wen,
      txready    => irq_src(IRQ_TX_READY),
      txempty    => irq_src(IRQ_TX_EMPTY),
      txdone     => irq_src(IRQ_TX_DONE),
      txoverflow => irq_src(IRQ_TX_OVF),

      -- RX
      rxreset    => rxreset,
      rxenable   => rxenable,
      rxdata     => rx_data_reg,
      rxready    => irq_src(IRQ_RX_READY),
      rxack      => rxd_done,
      rxoverflow => irq_src(IRQ_RX_OERR),
      rxPERR     => irq_src(IRQ_RX_PERR),
      rxFERR     => irq_src(IRQ_RX_FERR),

      -- Interfaces physiques
      TX => txd,
      RX => rxd
   );

   -- register access
   process (pclk, presetn) is
   begin
     if presetn = '0' then
       apb_slave <= C_APB_SLAVE_INIT;

       control_reg <= (others => '0');
       txd_wen     <= '0';

       rxd_done <= '0';
     elsif rising_edge(pclk) then
       apb_slave.pready <= '0';
       apb_slave.pslverr <= '0';

       ----------------------------------------------------------------------
       --     WRITE REGISTERS
       ----------------------------------------------------------------------
       control_reg(CTL_BIT_RX_FLUSH) <= '0';
       control_reg(CTL_BIT_TX_FLUSH) <= '0';
       irq_ack_reg                   <= (others => '0');
       txd_wen                       <= '0';

       -- ecritures registres
       if (s_apb_master.psel and (s_apb_master.pwrite and s_apb_master.penable and not apb_slave.pready)) = '1' then
         apb_slave.pready <= '1';

         case to_integer(unsigned(s_apb_master.paddr(5 downto 2))) is
           when CONTROL_IND =>
             control_reg <= s_apb_master.pwdata(control_reg'length - 1 downto 0);
           when BAUD_IND =>
             baud_reg <= s_apb_master.pwdata(baud_reg'length - 1 downto 0);
           when CONFIG_IND =>
             config_reg <= s_apb_master.pwdata(config_reg'length - 1 downto 0);
           when IRQ_MASK_IND =>
             irq_mask_reg <= s_apb_master.pwdata(irq_mask_reg'length - 1 downto 0);
           when IRQ_ACK_IND =>
             irq_ack_reg <= s_apb_master.pwdata(irq_ack_reg'length - 1 downto 0);
           when TXD_IND =>
             tx_data_reg <= s_apb_master.pwdata(tx_data_reg'length - 1 downto 0);
             txd_wen <= '1';
           when others =>
             apb_slave.pslverr <= '1';
         end case;
       end if;

       -- lecture registres
       if (s_apb_master.psel and (not s_apb_master.pwrite and s_apb_master.penable and not apb_slave.pready)) = '1' then
         apb_slave.pready <= '1';

         case to_integer(unsigned(s_apb_master.paddr(5 downto 2))) is
           when VERSION_IND =>
             apb_slave.prdata <= version;
           when CONTROL_IND =>
             apb_slave.prdata(31 downto control_reg'length)    <= (others => '0');
             apb_slave.prdata(control_reg'length - 1 downto 0) <= control_reg;
           when BAUD_IND =>
             apb_slave.prdata(31 downto baud_reg'length)    <= (others => '0');
             apb_slave.prdata(baud_reg'length - 1 downto 0) <= baud_reg;
           when CONFIG_IND =>
             apb_slave.prdata(31 downto config_reg'length)    <= (others => '0');
             apb_slave.prdata(config_reg'length - 1 downto 0) <= config_reg;
           when IRQ_STAT_IND =>
             apb_slave.prdata(31 downto irq_stat_reg'length)    <= (others => '0');
             apb_slave.prdata(irq_stat_reg'length - 1 downto 0) <= irq_stat_reg;
           when IRQ_MASK_IND =>
             apb_slave.prdata(31 downto irq_mask_reg'length)    <= (others => '0');
             apb_slave.prdata(irq_mask_reg'length - 1 downto 0) <= irq_mask_reg;
           when RXD_IND =>
             apb_slave.prdata(31 downto rx_data_reg'length)    <= (others => '0');
             apb_slave.prdata(rx_data_reg'length - 1 downto 0) <= rx_data_reg;
             rxd_done                                          <= '1';
           when others =>
             apb_slave.pslverr <= '1';
             apb_slave.prdata  <= (others => '0');
         end case;
       end if;
     end if;
   end process;

   s_apb_slave <= apb_slave;

   -- irq handling
   irqhdl : process(pclk, swreset)
   begin
     if swreset = '1' then
         irq_stat_reg <= (others => '0');
      elsif rising_edge(pclk) then
         irq_stat_reg <= (irq_stat_reg and not irq_ack_reg) or irq_src;
      end if;
   end process irqhdl;
   irq_out <= '0' when (irq_stat_reg and irq_mask_reg) = ZERO_IRQ else '1';
end struct;
