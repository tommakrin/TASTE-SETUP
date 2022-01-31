#V3

def bank(option=None):
    ioBanks = { 'IOB0'  : {'voltage': '3.3'}
          , 'IOB1'  : {'voltage': '3.3'}
          , 'IOB2'  : {'voltage': '2.5'}
          , 'IOB3'  : {'voltage': '2.5'}
          , 'IOB4'  : {'voltage': '2.5'}
          , 'IOB5'  : {'voltage': '2.5'}
          , 'IOB6'  : {'voltage': '2.5'}
          , 'IOB7'  : {'voltage': '2.5'}
          , 'IOB8'  : {'voltage': '2.5'}
          , 'IOB9'  : {'voltage': '2.5'}
          , 'IOB10' : {'voltage': '1.8'}
          , 'IOB11' : {'voltage': '1.8'}
          , 'IOB12' : {'voltage': '2.5'}
          }
    return ioBanks
          
def pads(option=None):    
    pads = {
## To use the JTAG interface for USER1/2 access in the fabric
#    'fabric_jtag_tck_i'      : {'location':'JTAG_TCK'},
#    'fabric_jtag_trst_i'     : {'location':'JTAG_TRST'},
#    'fabric_jtag_tms_i'      : {'location':'JTAG_TMS'},
#    'fabric_jtag_tdi_i'      : {'location':'JTAG_TDI'},
#    'fabric_jtag_usr1_i'     : {'location':'JTAG_USR1'},
#    'fabric_jtag_usr2_i'     : {'location':'JTAG_USR2'},
#    'fabric_jtag_tdo_usr1_o' : {'location':'JTAG_TDO1'},
#    'fabric_jtag_tdo_usr2_o' : {'location':'JTAG_TDO2'},
#
## To use the ProgInterface SpaceWire macro
#
##RESET
#    'spw_rst_n_o'         : {'location':'SPW_RST_N'},
#    'spw_arst_n_o'        : {'location':'SPW_ARST_N'},
##CLOCK
#    'spw_clk_o'           : {'location':'SPW_CLK'},
#    'spw_clk_tx_o'        : {'location':'SPW_CLK_TX'},
##MOSI / MISO
#    'spw_cfg_mosi_o'      : {'location':'SPW_CFG_MOSI'},
#    'spw_cfg_mosi_en_o'   : {'location':'SPW_CFG_MOSI_EN'},
#    'spw_cfg_miso_i'      : {'location':'SPW_CFG_MISO'},
#    'spw_cfg_miso_en_i'   : {'location':'SPW_CFG_MISO_EN'},
##WRITE}, READ}, FULL & EMPTY
#    'spw_tx_fifo_wr_o'    : {'location':'SPW_TX_FIFO_WR'},
#    'spw_rx_fifo_rd_o'    : {'location':'SPW_RX_FIFO_RD'},
#    'spw_tx_fifo_full_i'  : {'location':'SPW_TX_FIFO_FULL'},
#    'spw_rx_fifo_empty_i' : {'location':'SPW_RX_FIFO_EMPTY'},
##DATA TX
#    'spw_tx_fifo_data0_o' : {'location':'SPW_TX_FIFO_DATA0'},
#    'spw_tx_fifo_data1_o' : {'location':'SPW_TX_FIFO_DATA1'},
#    'spw_tx_fifo_data2_o' : {'location':'SPW_TX_FIFO_DATA2'},
#    'spw_tx_fifo_data3_o' : {'location':'SPW_TX_FIFO_DATA3'},
#    'spw_tx_fifo_data4_o' : {'location':'SPW_TX_FIFO_DATA4'},
#    'spw_tx_fifo_data5_o' : {'location':'SPW_TX_FIFO_DATA5'},
#    'spw_tx_fifo_data6_o' : {'location':'SPW_TX_FIFO_DATA6'},
#    'spw_tx_fifo_data7_o' : {'location':'SPW_TX_FIFO_DATA7'},
#    'spw_tx_fifo_data8_o' : {'location':'SPW_TX_FIFO_DATA8'},
##DATA RX
#    'spw_rx_fifo_data0_i' : {'location':'SPW_RX_FIFO_DATA0'},
#    'spw_rx_fifo_data1_i' : {'location':'SPW_RX_FIFO_DATA1'},
#    'spw_rx_fifo_data2_i' : {'location':'SPW_RX_FIFO_DATA2'},
#    'spw_rx_fifo_data3_i' : {'location':'SPW_RX_FIFO_DATA3'},
#    'spw_rx_fifo_data4_i' : {'location':'SPW_RX_FIFO_DATA4'},
#    'spw_rx_fifo_data5_i' : {'location':'SPW_RX_FIFO_DATA5'},
#    'spw_rx_fifo_data6_i' : {'location':'SPW_RX_FIFO_DATA6'},
#    'spw_rx_fifo_data7_i' : {'location':'SPW_RX_FIFO_DATA7'},
#    'spw_rx_fifo_data8_i' : {'location':'SPW_RX_FIFO_DATA8'},
##  
## To use the SlaveParallel interface pads 
#    'slavepar_data0_io'      : {'location':'USER_D0'}, # LED9
#    'slavepar_data1_io'      : {'location':'USER_D1'}, # LED10
#    'slavepar_data2_io'      : {'location':'USER_D2'}, # LED11
#    'slavepar_data3_io'      : {'location':'USER_D3'}, # LED12
#    'slavepar_data4_io'      : {'location':'USER_D4'}, # LED13
#    'slavepar_data5_io'      : {'location':'USER_D5'}, # LED14
#    'slavepar_data6_io'      : {'location':'USER_D6'}, # LED15
#    'slavepar_data7_io'      : {'location':'USER_D7'}, # LED16
#    'slavepar_data8_io'      : {'location':'USER_D8'}, # LED17
#    'slavepar_data9_io'      : {'location':'USER_D9'}, # LED18
#    'slavepar_data10_io'     : {'location':'USER_D10'},# LED19
#    'slavepar_data11_io'     : {'location':'USER_D11'},
#    'slavepar_data12_io'     : {'location':'USER_D12'},
#    'slavepar_data13_io'     : {'location':'USER_D13'},
#    'slavepar_data14_io'     : {'location':'USER_D14'},
#    'slavepar_data15_io'     : {'location':'USER_D15'},
#    'slavepar_clk_in'        : {'location':'USER_CLK'},
#    'slavepar_cs_n_in'       : {'location':'USER_CS_N'},
#    'slavepar_we_n_in'       : {'location':'USER_WE_N'},
#    'slavepar_data_oe_in'    : {'location':'USER_DATA_OE'},
#
## To use the internal thermal sensors  
#    'ths_ovf'   : {'location':'THS_OVF'},
#    'ths_rdy'   : {'location':'THS_DRDY'},
#    'ths_data0' : {'location':'THS_DATA0'},
#    'ths_data1' : {'location':'THS_DATA1'},
#    'ths_data2' : {'location':'THS_DATA2'},
#    'ths_data3' : {'location':'THS_DATA3'},
#    'ths_data4' : {'location':'THS_DATA4'},
#    'ths_data5' : {'location':'THS_DATA5'},
#    'ths_data6' : {'location':'THS_DATA6'},
#
##To use Bitstream Manager bits
#    'bsm_cold_start'  : {'location':'BSM_COLD_START'},
#    'bsm_cmic_corr0'  : {'location':'BSM_CMIC_CORR0'},
#    'bsm_cmic_corr1'  : {'location':'BSM_CMIC_CORR1'},
#    'bsm_cmic_corr2'  : {'location':'BSM_CMIC_CORR2'},
#    'bsm_cmic_corr3'  : {'location':'BSM_CMIC_CORR3'},
#    'bsm_cmic_corr4'  : {'location':'BSM_CMIC_CORR4'},
#    'bsm_cmic_corr5'  : {'location':'BSM_CMIC_CORR5'},
#    'bsm_cmic_corr6'  : {'location':'BSM_CMIC_CORR6'},
#    'bsm_cmic_corr7'  : {'location':'BSM_CMIC_CORR7'},
#    'bsm_cmic_corr8'  : {'location':'BSM_CMIC_CORR8'},
#    'bsm_cmic_corr9'  : {'location':'BSM_CMIC_CORR9'},
#    'bsm_cmic_corr10' : {'location':'BSM_CMIC_CORR10'},
#
#
#    # Clock sources
#    'osc0_clk_25MHz'  : {'location':'IOB12_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}, # Standard 25MHz clock oscillator
#    'osc1_socket'     : {'location':'IOB12_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}, # Frequency = user def
#    'J8_ext_SMA_input': {'location':'IOB0_D10P' , 'standard': 'LVCMOS', 'drive' :'2mA'}, # Frequency = user def
#    'J9_ext_SMA_input': {'location':'IOB10_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}  # Frequency = user def
#    
#    # Switches and Pushbuttons      
#    #        
#    #        ###### SWITCHES #####
#    #        # S5 #         # S6 #
#    #        # S1 # S2 # S3 # S4 #
#    , 'sw1'              : {'location':'IOB10_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'} # PA09 switch S1
#    , 'sw2'              : {'location':'IOB10_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'} # PA03 switch S2
#    , 'sw3'              : {'location':'IOB10_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'} # NA03 switch S3
#    , 'sw4'              : {'location':'IOB10_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'} # PA04 switch S4
#    , 'sw5'              : {'location':'IOB10_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'} # NA09 switch S5
#    , 'sw6'              : {'location':'IOB10_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'} # NA04 switch S6
#    
#    #        ##### PUSHBUTTONS #####
#    #              ##  S11 ##
#    #        ## S8 ##  S9  ## S10 ##
#    #              ##  S10 ##
#    , 'pb8'             : {'location':'IOB10_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'} # PA07 (Pushbutton S8)
#    , 'pb9'             : {'location':'IOB10_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'} # PA12 (Pushbutton S9)
#    , 'pb10'            : {'location':'IOB10_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'} # NA07 (Pushbutton S10)
#    , 'pb11'            : {'location':'IOB10_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'} # NA12 (Pushbutton S11)
#    , 'pb12'            : {'location':'IOB10_D14P', 'standard': 'LVCMOS', 'drive' :'2mA'} # PA14 (Pushbutton S12)
#    
#    
#    # User LEDs       
#    , 'led_n[1]'        : {'location':'IOB0_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}  # LED1
#    , 'led_n[2]'        : {'location':'IOB0_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}  # LED2
#    , 'led_n[3]'        : {'location':'IOB0_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}  # LED3
#    , 'led_n[4]'        : {'location':'IOB1_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}  # LED4
#    , 'led_n[5]'        : {'location':'IOB1_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}  # LED5
#    , 'led_n[6]'        : {'location':'IOB1_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}  # LED6
#    , 'led_n[7]'        : {'location':'IOB1_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}  # LED7
#    , 'led_n[8]'        : {'location':'IOB1_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}  # LED8
#    
#    # Additional User LEDs
#    , 'led_n[9]'        : {'location':'USER_D0', 'standard': 'LVCMOS', 'drive' :'2mA'}  # USER LED9
#    , 'led_n[10]'       : {'location':'USER_D1', 'standard': 'LVCMOS', 'drive' :'2mA'}  # USER LED10
#    , 'led_n[11]'       : {'location':'USER_D2', 'standard': 'LVCMOS', 'drive' :'2mA'}  # USER LED11
#    , 'led_n[12]'       : {'location':'USER_D3', 'standard': 'LVCMOS', 'drive' :'2mA'}  # USER LED12
#    , 'led_n[13]'       : {'location':'USER_D4', 'standard': 'LVCMOS', 'drive' :'2mA'}  # USER LED13
#    , 'led_n[14]'       : {'location':'USER_D5', 'standard': 'LVCMOS', 'drive' :'2mA'}  # USER LED14
#    , 'led_n[15]'       : {'location':'USER_D6', 'standard': 'LVCMOS', 'drive' :'2mA'}  # USER LED15
#    , 'led_n[16]'       : {'location':'USER_D7', 'standard': 'LVCMOS', 'drive' :'2mA'}  # USER LED16
#    , 'led_n[14]'       : {'location':'CS_N'   , 'standard': 'LVCMOS', 'drive' :'2mA'}  # USER LED17
#    , 'led_n[15]'       : {'location':'WE_N'   , 'standard': 'LVCMOS', 'drive' :'2mA'}  # USER LED18
#    , 'led_n[16]'       : {'location':'DAT_OE' , 'standard': 'LVCMOS', 'drive' :'2mA'}  # USER LED19
#    
#    # J2 SERIAL PROM expansion connector
#    #       #DUMP MODE
#    , 'clock_serial_dump'       : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'rdy_serial_dump'         : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'gnd_serial_dump'         : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'rst_oe_serial_dump'      : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'ser_en_serial_dump'      : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'vcc_serial_dump'         : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'not_used_serial_dump'    : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'prog_led_serial_dump'    : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'miso_serial_dump'        : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'cs_n_serial_dump'        : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    #       #SPI MODE
#    , 'clock_serial_dump'       : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'prog_led_serial_dump'    : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'gnd_serial_dump'         : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'mosi_serial_dump'        : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'not_used1_serial_dump'   : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'vcc_serial_dump'         : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'not_used2_serial_dump'   : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'not_used3_serial_dump'   : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'miso_serial_dump'        : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'cs_n_serial_dump'        : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    #       #SPI VCC MODE
#    , 'clock_serial_dump'       : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'prog_led_serial_dump'    : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'gnd_serial_dump'         : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'mosi_serial_dump'        : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'vcc0_serial_dump'        : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'not_used_serial_dump'    : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'vcc2_serial_dump'        : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'vcc1_serial_dump'        : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'miso_serial_dump'        : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    , 'cs_n_serial_dump'        : {'location':'', 'standard': 'LVCMOS', 'drive' :'2mA'}  # 
#    
#    # J3 Configuration SpaceWire
#    , 'spw_cfg_dip'  : {'location':'IOB12_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW CONFIG DIP 
#    , 'spw_cfg_sip'  : {'location':'IOB12_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW CONFIG SIP 
#    , 'spw_cfg_son'  : {'location':'IOB12_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW CONFIG SON 
#    , 'spw_cfg_don'  : {'location':'IOB12_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW CONFIG DON 
#    , 'spw_cfg_din'  : {'location':'IOB12_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW CONFIG DIN 
#    , 'spw_cfg_sin'  : {'location':'IOB12_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW CONFIG SIN 
#    , 'spw_cfg_sop'  : {'location':'IOB12_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW CONFIG SOP 
#    , 'spw_cfg_dop'  : {'location':'IOB12_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW CONFIG DOP 
#    
#    # J4 User1 SpaceWire
#    , 'spw_u1_dip'  : {'location':'IOB12_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW USER1 DIP 
#    , 'spw_u1_sip'  : {'location':'IOB12_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW USER1 SIP 
#    , 'spw_u1_son'  : {'location':'IOB12_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW USER1 SON 
#    , 'spw_u1_don'  : {'location':'IOB12_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW USER1 DON 
#    , 'spw_u1_din'  : {'location':'IOB12_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW USER1 DIN 
#    , 'spw_u1_sin'  : {'location':'IOB12_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW USER1 SIN 
#    , 'spw_u1_sop'  : {'location':'IOB12_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW USER1 SOP 
#    , 'spw_u1_dop'  : {'location':'IOB12_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW USER1 DOP 
#    
#    # J5 User2 SpaceWire
#    , 'spw_u2_dip'  : {'location':'IOB12_D14P', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW USER2 DIP 
#    , 'spw_u2_sip'  : {'location':'IOB12_D15P', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW USER2 SIP 
#    , 'spw_u2_son'  : {'location':'IOB12_D13N', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW USER2 SON 
#    , 'spw_u2_don'  : {'location':'IOB12_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW USER2 DON 
#    , 'spw_u2_din'  : {'location':'IOB12_D14N', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW USER2 DIN 
#    , 'spw_u2_sin'  : {'location':'IOB12_D15N', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW USER2 SIN 
#    , 'spw_u2_sop'  : {'location':'IOB12_D13P', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW USER2 SOP 
#    , 'spw_u2_dop'  : {'location':'IOB12_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}   # SPW USER2 DOP 
#    
#    # J6 HSMC interface
#    , 'hsmc_hcki0'      : {'location':'IOB5_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hcko0'      : {'location':'IOB5_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd0n'       : {'location':'IOB3_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd0p'       : {'location':'IOB3_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd1n '      : {'location':'IOB3_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd1p '      : {'location':'IOB3_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd2n'       : {'location':'IOB3_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd2p'       : {'location':'IOB3_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd3n'       : {'location':'IOB3_D13N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd3p'       : {'location':'IOB3_D13P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd4n'       : {'location':'IOB3_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd4p'       : {'location':'IOB3_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd5n'       : {'location':'IOB3_D15P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd5p'       : {'location':'IOB3_D15N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd6n'       : {'location':'IOB2_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd6p'       : {'location':'IOB2_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd7n'       : {'location':'IOB2_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd7p'       : {'location':'IOB2_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd8n'       : {'location':'IOB2_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd8p'       : {'location':'IOB2_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd9n'       : {'location':'IOB2_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd9p'       : {'location':'IOB2_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd10n'      : {'location':'IOB2_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd10p'      : {'location':'IOB2_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd11n'      : {'location':'IOB2_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd11p'      : {'location':'IOB2_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd12n'      : {'location':'IOB2_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd12p'      : {'location':'IOB2_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd13n'      : {'location':'IOB2_D15N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd13p'      : {'location':'IOB2_D15P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd14n'      : {'location':'IOB5_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd14p'      : {'location':'IOB5_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd15n'      : {'location':'IOB5_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd15p'      : {'location':'IOB5_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd16n'      : {'location':'IOB5_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd16p'      : {'location':'IOB5_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd17n'      : {'location':'IOB5_D14N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd17p'      : {'location':'IOB5_D14P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd18n'      : {'location':'IOB4_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd18p'      : {'location':'IOB4_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd19n'      : {'location':'IOB4_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd19p'      : {'location':'IOB4_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd20n'      : {'location':'IOB4_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd20p'      : {'location':'IOB4_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd21n'      : {'location':'IOB4_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd21p'      : {'location':'IOB4_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd22n'      : {'location':'IOB4_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd22p'      : {'location':'IOB4_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd23n'      : {'location':'IOB4_D13N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd23p'      : {'location':'IOB4_D13P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd24n'      : {'location':'IOB3_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd24p'      : {'location':'IOB3_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd25n'      : {'location':'IOB4_D15N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd25p'      : {'location':'IOB4_D15P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd26n'      : {'location':'IOB3_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd26p'      : {'location':'IOB3_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd27n'      : {'location':'IOB4_D14N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd27p'      : {'location':'IOB4_D14P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd28n'      : {'location':'IOB3_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd28p'      : {'location':'IOB3_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd29n'      : {'location':'IOB3_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd29p'      : {'location':'IOB3_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd30n'      : {'location':'IOB3_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd30p'      : {'location':'IOB3_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd31n'      : {'location':'IOB3_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd31p'      : {'location':'IOB3_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd32n'      : {'location':'IOB2_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd32p'      : {'location':'IOB2_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd33n'      : {'location':'IOB3_D14N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd33p'      : {'location':'IOB3_D14P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd34n'      : {'location':'IOB2_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd34p'      : {'location':'IOB2_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd35n'      : {'location':'IOB2_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd35p'      : {'location':'IOB2_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd36n'      : {'location':'IOB2_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd36p'      : {'location':'IOB2_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd37n'      : {'location':'IOB2_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd37p'      : {'location':'IOB2_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd38n'      : {'location':'IOB2_D14N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd38p'      : {'location':'IOB2_D14P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd39n'      : {'location':'IOB2_D13N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hd39p'      : {'location':'IOB2_D13P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hrx0n'      : {'location':'IOB3_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hrx0p'      : {'location':'IOB3_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hrx1n'      : {'location':'IOB4_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hrx1p'      : {'location':'IOB4_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hrx2n'      : {'location':'IOB4_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hrx2p'      : {'location':'IOB4_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hrx3n'      : {'location':'IOB4_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hrx3p'      : {'location':'IOB4_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hrx4n'      : {'location':'IOB5_D13N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hrx4p'      : {'location':'IOB5_D13P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hrx5n'      : {'location':'IOB5_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hrx5p'      : {'location':'IOB5_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hrx6n'      : {'location':'IOB5_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hrx6p'      : {'location':'IOB5_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hrx7n'      : {'location':'IOB5_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hrx7p'      : {'location':'IOB5_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htx0n'      : {'location':'IOB3_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htx0p'      : {'location':'IOB3_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htx1n'      : {'location':'IOB4_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htx1p'      : {'location':'IOB4_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htx2n'      : {'location':'IOB4_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htx2p'      : {'location':'IOB4_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htx3n'      : {'location':'IOB4_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htx3p'      : {'location':'IOB4_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htx4n'      : {'location':'IOB4_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htx4p'      : {'location':'IOB4_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htx5n'      : {'location':'IOB5_D15N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htx5p'      : {'location':'IOB5_D15P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htx6n'      : {'location':'IOB5_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htx6p'      : {'location':'IOB5_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htx7n'      : {'location':'IOB5_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htx7p'      : {'location':'IOB5_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_hscl'       : {'location':'IOB1_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'} # HSMC I2C 
#    , 'hsmc_hsda'       : {'location':'IOB1_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}           
#    , 'hsmc_htms'       : {'location':'IOB1_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'} # HSMC JTAG
#    , 'hsmc_htck'       : {'location':'IOB1_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htdi'       : {'location':'IOB1_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'hsmc_htdo'       : {'location':'IOB1_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    
#    # J7 FMC interface
#    , 'fmc_fclk0n'      : {'location':'IOB9_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fclk0p'      : {'location':'IOB9_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fclk1n'      : {'location':'IOB9_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fclk1p'      : {'location':'IOB9_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha00n'      : {'location':'IOB6_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha00p'      : {'location':'IOB6_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha01n'      : {'location':'IOB6_D14N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha01p'      : {'location':'IOB6_D14P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha02n'      : {'location':'IOB7_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha02p'      : {'location':'IOB7_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha03n'      : {'location':'IOB7_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha03p'      : {'location':'IOB7_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha04n'      : {'location':'IOB7_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha04p'      : {'location':'IOB7_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha05n'      : {'location':'IOB6_D13N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha05p'      : {'location':'IOB6_D13P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha06n'      : {'location':'IOB7_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha06p'      : {'location':'IOB7_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha07n'      : {'location':'IOB6_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha07p'      : {'location':'IOB6_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha08n'      : {'location':'IOB7_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha08p'      : {'location':'IOB7_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha09n'      : {'location':'IOB6_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha09p'      : {'location':'IOB6_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha10n'      : {'location':'IOB8_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha10p'      : {'location':'IOB8_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha11n'      : {'location':'IOB8_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha11p'      : {'location':'IOB8_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha12n'      : {'location':'IOB7_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha12p'      : {'location':'IOB7_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha13n'      : {'location':'IOB6_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha13p'      : {'location':'IOB6_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha14n'      : {'location':'IOB7_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha14p'      : {'location':'IOB7_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha15n'      : {'location':'IOB8_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha15p'      : {'location':'IOB8_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha16n'      : {'location':'IOB7_D14N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha16p'      : {'location':'IOB7_D14P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha17n'      : {'location':'IOB8_D15N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha17p'      : {'location':'IOB8_D15P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha18n'      : {'location':'IOB9_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha18p'      : {'location':'IOB9_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha19n'      : {'location':'IOB7_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha19p'      : {'location':'IOB7_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha20n'      : {'location':'IOB7_D13N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha20p'      : {'location':'IOB7_D13P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha21n'      : {'location':'IOB9_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha21p'      : {'location':'IOB9_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha22n'      : {'location':'IOB9_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha22p'      : {'location':'IOB9_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha23n'      : {'location':'IOB9_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fha23p'      : {'location':'IOB9_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla00n'      : {'location':'IOB6_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla00p'      : {'location':'IOB6_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla01n'      : {'location':'IOB6_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla01p'      : {'location':'IOB6_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla02n'      : {'location':'IOB6_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla02p'      : {'location':'IOB6_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla03n'      : {'location':'IOB7_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla03p'      : {'location':'IOB7_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla04n'      : {'location':'IOB7_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla04p'      : {'location':'IOB7_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla05n'      : {'location':'IOB6_D15N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla05p'      : {'location':'IOB6_D15P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla06n'      : {'location':'IOB6_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla06p'      : {'location':'IOB6_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla07n'      : {'location':'IOB8_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla07p'      : {'location':'IOB8_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla08n'      : {'location':'IOB7_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla08p'      : {'location':'IOB7_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla09n'      : {'location':'IOB6_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla09p'      : {'location':'IOB6_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla10n'      : {'location':'IOB6_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla10p'      : {'location':'IOB6_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla11n'      : {'location':'IOB8_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla11p'      : {'location':'IOB8_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla12n'      : {'location':'IOB8_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla12p'      : {'location':'IOB8_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla13n'      : {'location':'IOB6_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla13p'      : {'location':'IOB6_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla14n'      : {'location':'IOB6_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla14p'      : {'location':'IOB6_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla15n'      : {'location':'IOB8_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla15p'      : {'location':'IOB8_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla16n'      : {'location':'IOB8_D13N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla16p'      : {'location':'IOB8_D13P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla17n'      : {'location':'IOB7_D15N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla17p'      : {'location':'IOB7_D15P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla18n'      : {'location':'IOB7_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla18p'      : {'location':'IOB7_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla19n'      : {'location':'IOB9_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla19p'      : {'location':'IOB9_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla20n'      : {'location':'IOB8_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla20p'      : {'location':'IOB8_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla21n'      : {'location':'IOB9_D15N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla21p'      : {'location':'IOB9_D15P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla22n'      : {'location':'IOB9_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla22p'      : {'location':'IOB9_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla23n'      : {'location':'IOB8_D14N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla23p'      : {'location':'IOB8_D14P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla24n'      : {'location':'IOB9_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla24p'      : {'location':'IOB9_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla25n'      : {'location':'IOB9_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla25p'      : {'location':'IOB9_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla26n'      : {'location':'IOB8_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla26p'      : {'location':'IOB8_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla27n'      : {'location':'IOB8_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla27p'      : {'location':'IOB8_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla28n'      : {'location':'IOB9_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla28p'      : {'location':'IOB9_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla29n'      : {'location':'IOB8_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla29p'      : {'location':'IOB8_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla30n'      : {'location':'IOB9_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla30p'      : {'location':'IOB9_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla31n'      : {'location':'IOB8_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla31p'      : {'location':'IOB8_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla32n'      : {'location':'IOB9_D14N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla32p'      : {'location':'IOB9_D14P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla33n'      : {'location':'IOB9_D13N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fla33p'      : {'location':'IOB9_D13P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fpgc2m'      : {'location':'IOB1_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fpgm2c'      : {'location':'IOB1_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_fps_n'       : {'location':'IOB1_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'} # FMC Presence detect
#    , 'fmc_fscl'        : {'location':'IOB1_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'} # FMC I2C
#    , 'fmc_fsda'        : {'location':'IOB1_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_ftrn'        : {'location':'IOB1_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'} # FMC JTAG
#    , 'fmc_ftms'        : {'location':'IOB1_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_ftck'        : {'location':'IOB1_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_ftdi'        : {'location':'IOB1_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'fmc_ftdo'        : {'location':'IOB1_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    
#    # TP1 & TP2: Bank0 spare I/Os
#    , 'n001'       : {'location':'IOB0_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'n002'       : {'location':'IOB0_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'n004'       : {'location':'IOB0_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'n005'       : {'location':'IOB0_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'n006'       : {'location':'IOB0_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'n007'       : {'location':'IOB0_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'n008'       : {'location':'IOB0_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'n009'       : {'location':'IOB0_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'n010'       : {'location':'IOB0_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'n011'       : {'location':'IOB0_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'p002'       : {'location':'IOB0_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'p004'       : {'location':'IOB0_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'p005'       : {'location':'IOB0_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'p006'       : {'location':'IOB0_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'p007'       : {'location':'IOB0_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'p008'       : {'location':'IOB0_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'p009'       : {'location':'IOB0_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    
#    # TP3 & TP4: Bank12 spare I/Os
#    , 'nc05'      : {'location':'IOB12_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'nc06'      : {'location':'IOB12_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'nc07'      : {'location':'IOB12_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'nc08'      : {'location':'IOB12_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'nc09'      : {'location':'IOB12_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'nc10'      : {'location':'IOB12_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'nc11'      : {'location':'IOB12_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'pc05'      : {'location':'IOB12_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'pc06'      : {'location':'IOB12_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'pc07'      : {'location':'IOB12_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'pc09'      : {'location':'IOB12_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'pc10'      : {'location':'IOB12_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    
#    # TP5: Bank5 spare I/Os 
#    , 'n501'       : {'location':'IOB5_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'n503'       : {'location':'IOB5_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'n505'       : {'location':'IOB5_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'p501'       : {'location':'IOB5_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'p503'       : {'location':'IOB5_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    , 'p505'       : {'location':'IOB5_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#    
#    # Micron MT47H128M16 DDR2 SDRAM
#      , 'mcke'       : {'location':'IOB10_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mckn '      : {'location':'IOB11_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mckp '      : {'location':'IOB11_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mcsn'       : {'location':'IOB11_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mcasn'      : {'location':'IOB10_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mrasn'      : {'location':'IOB10_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mwen'       : {'location':'IOB10_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mldm'       : {'location':'IOB11_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mudm'       : {'location':'IOB11_D14P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'modt'       : {'location':'IOB11_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'ldqsn'      : {'location':'IOB11_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'ldqsp'      : {'location':'IOB11_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'udqsn'      : {'location':'IOB11_D13N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'udqsp'      : {'location':'IOB11_D13P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mad0'       : {'location':'IOB11_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mad1'       : {'location':'IOB10_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mad2'       : {'location':'IOB10_D15N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mad3'       : {'location':'IOB10_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mad4'       : {'location':'IOB11_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mad5'       : {'location':'IOB10_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mad6'       : {'location':'IOB10_D15P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mad7'       : {'location':'IOB10_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mad8'       : {'location':'IOB11_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mad9'       : {'location':'IOB10_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mad10'      : {'location':'IOB10_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mad11'      : {'location':'IOB10_D13N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mad12'      : {'location':'IOB10_D14N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mad13'      : {'location':'IOB10_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mad14'      : {'location':'IOB11_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mad15'      : {'location':'IOB10_D13P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mba0'       : {'location':'IOB10_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mba1'       : {'location':'IOB10_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mba2'       : {'location':'IOB10_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mdq0'       : {'location':'IOB11_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mdq1'       : {'location':'IOB11_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mdq2'       : {'location':'IOB11_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mdq3'       : {'location':'IOB11_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mdq4'       : {'location':'IOB11_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mdq5'       : {'location':'IOB11_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mdq6'       : {'location':'IOB11_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mdq7'       : {'location':'IOB11_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mdq8'       : {'location':'IOB11_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mdq9'       : {'location':'IOB11_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mdq10'      : {'location':'IOB11_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mdq11'      : {'location':'IOB11_D14N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mdq12'      : {'location':'IOB11_D15P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mdq13'      : {'location':'IOB11_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mdq14'      : {'location':'IOB11_D15N', 'standard': 'LVCMOS', 'drive' :'2mA'}
#      , 'mdq15'      : {'location':'IOB11_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}
    }
    return pads
