#V1

def bank(option=None):
    ioBanks = { 'IOB0'   : {'voltage': '2.5'}##
          , 'IOB1'   : {'voltage': '3.3'}##
          #, 'IOB2'   : {'voltage': '3.3'}#Not connected
          #, 'IOB3'   : {'voltage': '3.3'}#Not connected
          #, 'IOB4'   : {'voltage': '3.3'}#Not connected
          , 'IOB5'   : {'voltage': '3.3'}##
          , 'IOB6'   : {'voltage': '2.5'}##
          #, 'IOB7'   : {'voltage': '3.3'}#Not connected
          , 'IOB8'   : {'voltage': '2.5'}##
          , 'IOB9'   : {'voltage': '2.5'}##
          , 'IOB10'  : {'voltage': '2.5'}##
          , 'IOB11'  : {'voltage': '3.3'}##
          , 'IOB12'  : {'voltage': '3.3'}##
          , 'IOB13'  : {'voltage': '3.3'}##
          , 'IOB14'  : {'voltage': '3.3'}##
          , 'IOB15'  : {'voltage': '3.3'}##
          , 'IOB16'  : {'voltage': '3.3'}##
          , 'IOB17'  : {'voltage': '3.3'}## SRAM
          , 'IOB18'  : {'voltage': '3.3'}## SRAM
          , 'IOB19'  : {'voltage': '2.5'}##
          , 'IOB20'  : {'voltage': '2.5'}##
          , 'IOB21'  : {'voltage': '2.5'}##
          , 'IOB22'  : {'voltage': '2.5'}##
          , 'IOB23'  : {'voltage': '2.5'}##
          }
    return ioBanks


def pads(option=None):
    pads = {
#    #BANK 0
#    'OSC_BY_Socket'               : {'location': 'IOB00_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #
#
#    #BANK 1
#    'REQ_SYNC'                    : {'location': 'IOB01_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #3.3 LMK FMC N°2
#    'FMC_I2C_SCL'                 : {'location': 'IOB01_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #3.3 LMK FMC N°1
#    'FMC_I2C_SDA'                 : {'location': 'IOB01_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #3.3 LMK FMC N°1
#    'F1_TCK'                      : {'location': 'IOB01_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1 TCK
#    'F1_TDI'                      : {'location': 'IOB01_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1 TDI
#    'F1_TDO'                      : {'location': 'IOB01_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1 TDO
#    'F1_TMS'                      : {'location': 'IOB01_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1 TMS
#
#    #BANK 2
#    #BANK 3
#    #BANK 4
#
#    #BANK 5
#    'ReadExtConfig11'            : {'location': 'IOB05_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'},  #ReadExtConfig11
#    'ReadExtConfig10'            : {'location': 'IOB05_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'},  #ReadExtConfig10
#    'ReadExtConfig7'             : {'location': 'IOB05_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'},  #ReadExtConfig7
#    'ReadExtConfig5'             : {'location': 'IOB05_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'},  #ReadExtConfig5
#    'ReadExtConfig0'             : {'location': 'IOB05_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'},  #ReadExtConfig0
#    'ReadExtConfig4'             : {'location': 'IOB05_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'},  #ReadExtConfig4
#    'ReadExtConfig2'             : {'location': 'IOB05_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'},  #ReadExtConfig2
#    'ReadExtConfig6'             : {'location': 'IOB05_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'},  #ReadExtConfig6
#    'ReadExtConfig8'             : {'location': 'IOB05_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'},  #ReadExtConfig8
#    'ReadExtConfig9'             : {'location': 'IOB05_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'},  #ReadExtConfig9
#    'ReadExtConfig1'             : {'location': 'IOB05_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'},  #ReadExtConfig1
#    'ReadExtConfig3'             : {'location': 'IOB05_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'},  #ReadExtConfig3
#    'ReadExtConfig12'            : {'location': 'IOB05_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'},  #ReadExtConfig12
#    'CLK_ANGIE'                  : {'location': 'IOB05_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'},  #CLK_ANGIE
#
#    #BANK 6
#    'SW2_DOUT_N'                  : {'location': 'IOB06_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'},  #SW2_DOUT_N
#    'SW2_DOUT_P'                  : {'location': 'IOB06_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'},  #SW2_DOUT_P
#    'SW2_SOUT_N'                  : {'location': 'IOB06_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'},  #SW2_SOUT_N
#    'SW2_SOUT_P'                  : {'location': 'IOB06_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'},  #SW2_SOUT_P
#    'SW2_DIN_N'                   : {'location': 'IOB06_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'},  #SW2_DIN_N
#    'SW2_DIN_P'                   : {'location': 'IOB06_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'},  #SW2_DIN_P
#    'SW2_SIN_N'                   : {'location': 'IOB06_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'},  #SW2_SIN_N
#    'SW2_SIN_P'                   : {'location': 'IOB06_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'},  #SW2_SIN_P
#    ##
#    'SW1_DOUT_N'                  : {'location': 'IOB06_D14N', 'standard': 'LVCMOS', 'drive' :'2mA'},  #SW2_DOUT_N
#    'SW1_DOUT_P'                  : {'location': 'IOB06_D14P', 'standard': 'LVCMOS', 'drive' :'2mA'},  #SW2_DOUT_P
#    'SW1_SOUT_N'                  : {'location': 'IOB06_D15N', 'standard': 'LVCMOS', 'drive' :'2mA'},  #SW2_SOUT_N
#    'SW1_SOUT_P'                  : {'location': 'IOB06_D15P', 'standard': 'LVCMOS', 'drive' :'2mA'},  #SW2_SOUT_P
#    'SW1_DIN_N'                   : {'location': 'IOB06_D16N', 'standard': 'LVCMOS', 'drive' :'2mA'},  #SW2_DIN_N
#    'SW1_DIN_P'                   : {'location': 'IOB06_D16P', 'standard': 'LVCMOS', 'drive' :'2mA'},  #SW2_DIN_P
#    'SW1_SIN_N'                   : {'location': 'IOB06_D17N', 'standard': 'LVCMOS', 'drive' :'2mA'},  #SW2_SIN_N
#    'SW1_SIN_P'                   : {'location': 'IOB06_D17P', 'standard': 'LVCMOS', 'drive' :'2mA'},  #SW2_SIN_P
#
#    #BANK 7
#
#    #BANK 8
#    'DDR_DQ4'                     : {'location': 'IOB08_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ4
#    'DDR_DQ0'                     : {'location': 'IOB08_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ0
#    'DDR_DM0'                     : {'location': 'IOB08_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DM0
#    'DDR_DQ1'                     : {'location': 'IOB08_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ1
#    'DDR_DQS0_N'                  : {'location': 'IOB08_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQS0_N
#    'DDR_DQS0_P'                  : {'location': 'IOB08_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQS0_P
#    'DDR_DQ5'                     : {'location': 'IOB08_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ5
#    'DDR_DQ6'                     : {'location': 'IOB08_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ6
#    'DDR_DQ2'                     : {'location': 'IOB08_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ2
#    'DDR_DQ3'                     : {'location': 'IOB08_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ3
#    'DDR_RSTn'                    : {'location': 'IOB08_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_RSTn
#    'DDR_DQ7'                     : {'location': 'IOB08_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ7
#    'DDR_A3'                      : {'location': 'IOB08_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_A3
#    'DDR_CSn'                     : {'location': 'IOB08_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_CSn
#    'DDR_A2'                      : {'location': 'IOB08_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_A2
#    'DDR_A6'                      : {'location': 'IOB08_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_A6
#    'DDR_A15'                     : {'location': 'IOB08_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_A15
#    'DDR_A14'                     : {'location': 'IOB08_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_A14
#    'DDR_A4'                      : {'location': 'IOB08_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_A4
#    'DDR_A11'                     : {'location': 'IOB08_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_A11
#    'DDR_BA1'                     : {'location': 'IOB08_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_BA1
#    'DDR_CKE'                     : {'location': 'IOB08_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_CKE
#    'DDR_DQ8'                     : {'location': 'IOB08_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ8
#    'DDR_A7'                      : {'location': 'IOB08_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_A7
#    'DDR_DQ12'                    : {'location': 'IOB08_D13N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ12
#    'DDR_DQ9'                     : {'location': 'IOB08_D13P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ9
#    'DDR_DQ10'                    : {'location': 'IOB08_D14N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ10
#    'DDR_DQ13'                    : {'location': 'IOB08_D14P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ13
#    'DDR_DQS1_N'                  : {'location': 'IOB08_D15N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQS1_N
#    'DDR_DQS1_P'                  : {'location': 'IOB08_D15P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQS1_P
#    'DDR_DQ14'                    : {'location': 'IOB08_D16N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ14
#    'DDR_DQ11'                    : {'location': 'IOB08_D16P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ11
#    'DDR_DM1'                     : {'location': 'IOB08_D17N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DM1
#    'DDR_DQ15'                    : {'location': 'IOB08_D17P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ15
#
#
#    #BANK 9
#    'DDR_DQ16'                    : {'location': 'IOB09_D17P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ16
#    'DDR_DQ17'                    : {'location': 'IOB09_D17N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ17
#    'DDR_DQ18'                    : {'location': 'IOB09_D16P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ18
#    'DDR_DQ19'                    : {'location': 'IOB09_D16N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ19
#    'DDR_DQS2_P'                  : {'location': 'IOB09_D15P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQS2_P
#    'DDR_DQS2_N'                  : {'location': 'IOB09_D15N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQS2_N
#    'DDR_DQ20'                    : {'location': 'IOB09_D14P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ20
#    'DDR_DQ21'                    : {'location': 'IOB09_D14N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ21
#    'DDR_DQ22'                    : {'location': 'IOB09_D13P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ22
#    'DDR_DQ23'                    : {'location': 'IOB09_D13N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ23
#    'DDR_A0'                      : {'location': 'IOB09_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_A0
#    'DDR_DM2'                     : {'location': 'IOB09_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DM2
#    'DDR_CLK_P'                   : {'location': 'IOB09_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_CLK_P
#    'DDR_CLK_N'                   : {'location': 'IOB09_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_CLK_N
#    'DDR_A1'                      : {'location': 'IOB09_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_A1
#    'DDR_A8'                      : {'location': 'IOB09_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_A8
#    'DDR_A12'                     : {'location': 'IOB09_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_A12
#    'DDR_BA2'                     : {'location': 'IOB09_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_BA2
#    'DDR_A9'                      : {'location': 'IOB09_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_A9
#    'DDR_A5'                      : {'location': 'IOB09_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_A5
#    'DDR_BA0'                     : {'location': 'IOB09_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_BA0
#    'DDR_A10'                     : {'location': 'IOB09_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_A10
#    'DDR_DQ28'                    : {'location': 'IOB09_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ28
#    'DDR_ODT'                     : {'location': 'IOB09_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_ODT
#    'DDR_DQ24'                    : {'location': 'IOB09_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ24
#    'DDR_DQ25'                    : {'location': 'IOB09_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ25
#    'DDR_DQ30'                    : {'location': 'IOB09_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ30
#    'DDR_DQ29'                    : {'location': 'IOB09_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ29
#    'DDR_DQS3_P'                  : {'location': 'IOB09_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQS3_P
#    'DDR_DQS3_N'                  : {'location': 'IOB09_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQS3_N
#    'DDR_DQ26'                    : {'location': 'IOB09_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ26
#    'DDR_DM3'                     : {'location': 'IOB09_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DM3
#    'DDR_DQ27'                    : {'location': 'IOB09_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ27
#    'DDR_DQ31'                    : {'location': 'IOB09_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_DQ31
#
#    #BANK 10
#    'DDR_CASn'                    : {'location': 'IOB10_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_CASn
#    'DDR_A13'                     : {'location': 'IOB10_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_A13
#    'DDR_RASn'                    : {'location': 'IOB10_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_RASn
#    'DDR_WEn'                     : {'location': 'IOB10_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DDR_WEn
#
#
    #BANK 11
    'EXT_SW_RST_NI'                  : {'location': 'IOB11_D01N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #PushB1 = SW2
    'EXT_POR_RST_NI'                    : {'location': 'IOB11_D01P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #PushB2 = SW4
    'PushB3'                       : {'location': 'IOB11_D02N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #PushB3 = SW6
    'switch'                       : {'location': 'IOB11_D02P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #PushB4 = SW8
    'PushB5'                       : {'location': 'IOB11_D03N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #PushB5 = SW10
    'TRIG_IN'                      : {'location': 'IOB11_D03P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #PushB6 = SW12
#    'PushB7'                      : {'location': 'IOB11_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #PushB7 = SW14
#    'PushB8'                      : {'location': 'IOB11_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #PushB8 = SW16
    'LEDS_N_O[0]'                  : {'location': 'IOB11_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Uled1
    'LEDS_N_O[1]'                  : {'location': 'IOB11_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Uled2
    'LEDS_N_O[2]'                  : {'location': 'IOB11_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Uled3
    'LEDS_N_O[3]'                  : {'location': 'IOB11_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Uled4
    'LEDS_N_O[4]'                  : {'location': 'IOB11_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Uled5
    'LEDS_N_O[5]'                  : {'location': 'IOB11_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Uled6
    'LEDS_N_O[6]'                  : {'location': 'IOB11_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Uled7
    'LEDS_N_O[7]'                  : {'location': 'IOB11_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Uled8
#    'OSC_BOTTOM'                  : {'location': 'IOB11_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #OSC_BOTTOM
#    'SMA_CLK_IN'                  : {'location': 'IOB11_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #SMA_CLK_IN



    #BANK 12
#    'Usw1'                        : {'location': 'IOB12_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Usw1
#    'Usw2'                        : {'location': 'IOB12_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Usw2
#    'Usw3'                        : {'location': 'IOB12_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Usw3
#    'Usw4'                        : {'location': 'IOB12_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Usw4
#    'Usw5'                        : {'location': 'IOB12_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Usw5
#    'Usw6'                        : {'location': 'IOB12_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Usw6
#    'Usw7'                        : {'location': 'IOB12_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Usw7
#    'Usw8'                        : {'location': 'IOB12_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Usw8
    ##
    'JTAG_TDI_I'                     : {'location': 'IOB12_D08N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #ARM_TDI
    'JTAG_TDO_O'                     : {'location': 'IOB12_D07P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #ARM_TDO
    'JTAG_TCK_I'                     : {'location': 'IOB12_D07N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #ARM_TCK
    'JTAG_TMS_I'                     : {'location': 'IOB12_D06P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #ARM_TMS
#    'ARM_RTCK'                    : {'location': 'IOB12_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #ARM_RTCK
    'JTAG_TRST_NI'                   : {'location': 'IOB12_D05P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #ARM_TRSTn
#    'ARM_DBGACK'                  : {'location': 'IOB12_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #ARM_DBGACK
    'ARM_DEBUG_RST'                  : {'location': 'IOB12_D03P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #ARM_RST #Pull up on board
#    'ARM_DBGRQ'                   : {'location': 'IOB12_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #ARM_DBGRQ

    #BANK 13
    #'gpio_o[20]'                   : {'location': 'IOB13_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO21 - J16-3
    #'gpio_o[21]'                   : {'location': 'IOB13_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO22 - J16-5
    #'gpio_o[22]'                   : {'location': 'IOB13_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO23 - J16-7
    #'gpio_o[23]'                   : {'location': 'IOB13_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO24 - J16-9
    #'gpio_o[24]'                   : {'location': 'IOB13_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO25 - J16-11
    #'gpio_o[25]'                   : {'location': 'IOB13_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO26 - J16-13
    #'gpio_o[26]'                   : {'location': 'IOB13_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO27 - J16-15
    #'gpio_o[27]'                   : {'location': 'IOB13_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO28 - J16-17
    #'gpio_o[28]'                   : {'location': 'IOB13_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO29 - J16-19
    #'gpio_o[29]'                   : {'location': 'IOB13_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO30 - J16-2
    #'gpio_o[30]'                   : {'location': 'IOB13_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO31 - J16-4
    #'gpio_o[31]'                   : {'location': 'IOB13_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO32 - J16-6
    #'gpio_o[32]'                   : {'location': 'IOB13_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO33 - J16-8
    #'gpio_o[33]'                   : {'location': 'IOB13_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO34 - J16-10
    #'gpio_o[34]'                   : {'location': 'IOB13_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO35 - J16-12
    #'gpio_o[35]'                   : {'location': 'IOB13_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO36 - J16-14
    #'gpio_o[36]'                   : {'location': 'IOB13_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO37 - J16-16
    #'gpio_o[37]'                   : {'location': 'IOB13_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO38 - J16-18


    #BANK 14
    'IRQ_DBG'                    : {'location': 'IOB14_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO1 - J15-1
    'DBGDONE'                    : {'location': 'IOB14_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO2 - J15-3
    'DONEBLDBG'                    : {'location': 'IOB14_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO3 - J15-5
    'STARTDBG'                    : {'location': 'IOB14_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO4 - J15-7
    #'gpio_o[4]'                    : {'location': 'IOB14_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO5 - J15-9
    #'gpio_o[5]'                    : {'location': 'IOB14_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO6 - J15-11
    #'gpio_o[6]'                    : {'location': 'IOB14_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO7 - J15-13
    #'gpio_o[7]'                    : {'location': 'IOB14_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO8 - J15-15
    #'gpio_o[8]'                    : {'location': 'IOB14_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO9 - J15-17
    #'gpio_o[9]'                    : {'location': 'IOB14_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO10 - J15-19
    #'gpio_o[10]'                   : {'location': 'IOB14_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO11 - J15-2
    #'gpio_o[11]'                   : {'location': 'IOB14_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO12 - J15-4
    #'gpio_o[12]'                   : {'location': 'IOB14_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO13 - J15-6
    #'gpio_o[13]'                   : {'location': 'IOB14_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO14 - J15-8
    #'gpio_o[14]'                   : {'location': 'IOB14_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO15 - J15-10
    #'gpio_o[15]'                   : {'location': 'IOB14_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO16 - J15-12
    #'gpio_o[16]'                   : {'location': 'IOB14_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO17 - J15-14
    #'gpio_o[17]'                   : {'location': 'IOB14_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO18 - J15-16
    #'gpio_o[18]'                   : {'location': 'IOB14_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO19 - J15-18
    #'gpio_o[19]'                   : {'location': 'IOB14_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO20 - J16-1

    #BANK 15
    'UART_CP2105_TXD_O'           : {'location': 'IOB15_D01N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #UART_RXD1
    'UART_CP2105_RXD_I'           : {'location': 'IOB15_D01P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #UART_TXD1
    'UART_CST1'                   : {'location': 'IOB15_D02N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #UART_CST1
    'UART_RTS1'                   : {'location': 'IOB15_D02P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #UART_RTS1
    'UART_RXD2'                   : {'location': 'IOB15_D03N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #UART_RXD2
    'UART_TXD2'                   : {'location': 'IOB15_D03P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #UART_TXD2
    'UART_CST2'                   : {'location': 'IOB15_D04N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #UART_CST2
    'UART_RTS2'                   : {'location': 'IOB15_D04P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #UART_RTS2
    'TC_485'                      : {'location': 'IOB15_D05P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #TC_485

    #BANK 16
    'SRAM_DATA[1]'                : {'location': 'IOB16_D01N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_D1
    'SRAM_DATA[0]'                : {'location': 'IOB16_D01P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_D0
    'SRAM_DATA[4]'                : {'location': 'IOB16_D02N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_D4
    'SRAM_DATA[2]'                : {'location': 'IOB16_D02P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_D2
    'SRAM_DATA[3]'                : {'location': 'IOB16_D03N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_D3
    'SRAM_ADDR[14]'               : {'location': 'IOB16_D03P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_A14
    'SRAM_DATA[6]'                : {'location': 'IOB16_D04N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_D6
    'SRAM_DATA[5]'                : {'location': 'IOB16_D04P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_D5
    'SRAM_ADDR[15]'               : {'location': 'IOB16_D05N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_A15
    'SRAM_ADDR[8]'                : {'location': 'IOB16_D05P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_A8
    'SRAM_ADDR[13]'               : {'location': 'IOB16_D06N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_A13
    'SRAM_ADDR[12]'               : {'location': 'IOB16_D06P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_A12
    'SRAM_ADDR[11]'               : {'location': 'IOB16_D07N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_A11
    'SRAM_ADDR[10]'               : {'location': 'IOB16_D07P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_A10
    'SRAM_ADDR[9]'                : {'location': 'IOB16_D08N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_A9
    'SRAM_ADDR[0]'                : {'location': 'IOB16_D08P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_A0
    'SRAM_ADDR[7]'                : {'location': 'IOB16_D09N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_A7
    'SRAM_CE_N'                   : {'location': 'IOB16_D10P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_CEn
    'SRAM_WE_N'                   : {'location': 'IOB16_D10N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_WEn

    #BANK 17
    'SRAM_ADDR[6]'                : {'location': 'IOB17_D11N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_A6
    'SRAM_DATA[9]'                : {'location': 'IOB17_D01N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_D9
    'SRAM_DATA[7]'                : {'location': 'IOB17_D01P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_D7
    'SRAM_DATA[15]'               : {'location': 'IOB17_D02N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_D15
    'SRAM_DATA[14]'               : {'location': 'IOB17_D02P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_D14
    'SRAM_ADDR[2]'                : {'location': 'IOB17_D03N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_A2
    'SRAM_ADDR[1]'                : {'location': 'IOB17_D03P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_A1
    'SRAM_DATA[12]'               : {'location': 'IOB17_D04P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_D12
    'SRAM_DATA[13]'               : {'location': 'IOB17_D05N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_D13
    'SRAM_ADDR[5]'                : {'location': 'IOB17_D05P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_A5
    'SRAM_DATA[10]'               : {'location': 'IOB17_D06N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_A5
    'SRAM_DATA[11]'               : {'location': 'IOB17_D06P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_D11
    'SRAM_ADDR[4]'                : {'location': 'IOB17_D07N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_A4
    'SRAM_DATA[8]'                : {'location': 'IOB17_D07P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_D8
    'SRAM_ADDR[3]'                : {'location': 'IOB17_D08N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_A3
    'SRAM_OE_N'                   : {'location': 'IOB17_D08P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_OEN
    'SRAM_BE_N[1]'                : {'location': 'IOB17_D10P', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_UBn
    'SRAM_BE_N[0]'                : {'location': 'IOB17_D10N', 'standard': 'LVCMOS', 'drive' :'2mA', 'registered' : 'IOC'}, #SRAM_LBn

    #BANK 18
#    'OSC_TOP'                     : {'location': 'IOB18_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #OSC_TOP
     'EXT_CLK_I'                     : {'location': 'IOB18_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #OSC_TOP
#
#    #BANK 19
#    'NET0_GTXCLK'                 : {'location': 'IOB19_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_GTXCLK  or TRACEPKT6
#    'NET0_TX_EN'                  : {'location': 'IOB19_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_TX_EN   or TRACEPKT14
#    'LED_DS1'                     : {'location': 'IOB19_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #LED_DS1'
#    'NET0_TX_ER'                  : {'location': 'IOB19_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_TX_ER'
#    'Esi_CSn'                     : {'location': 'IOB19_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_CSn      or NET0_RX_ER
#    'LED_DS2'                     : {'location': 'IOB19_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #LED_DS2'
#    'LED_DS3'                     : {'location': 'IOB19_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #LED_DS3'
#    'LED_DS4'                     : {'location': 'IOB19_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #LED_DS4'
#    'NET0_TX_D3'                  : {'location': 'IOB19_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_TX_D3'
#    'NET0_TX_D7'                  : {'location': 'IOB19_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_TX_D7'
#    'NET0_TX_D5'                  : {'location': 'IOB19_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_TX_D5'
#    'Esi_MISO'                    : {'location': 'IOB19_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_MISO     or NET0_TX_D6
#    'NET0_TX_D2'                  : {'location': 'IOB19_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_TX_D2'  or TRACEPKT1
#    'Esi_MOSI'                    : {'location': 'IOB19_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_MOSI'    or NET0_TX_D4
#    'NET0_TX_D1'                  : {'location': 'IOB19_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_TX_D1'  or TRACEPKT2
#    'NET0_TX_D0'                  : {'location': 'IOB19_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_TX_D0'  or TRACEPKT15
#    'Esi_SCLK'                    : {'location': 'IOB19_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_SCLK'
#    'NET0_TX_CLK'                 : {'location': 'IOB19_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_TX_CLK'
#    'NET0_TX_CRS'                 : {'location': 'IOB19_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_TX_CRS'
#    'NET0_RX_CLK'                 : {'location': 'IOB19_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_RX_CLK'
#    'Esi_SYNCTRIG_N'              : {'location': 'IOB19_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_SYNCTRIG_N'
#    'Esi_SYNCTRIG_P'              : {'location': 'IOB19_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_SYNCTRIG_P'
#    'Esi_AFU2_N'                  : {'location': 'IOB19_D13N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_AFU2_N'
#    'Esi_AFU2_P'                  : {'location': 'IOB19_D13P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_AFU2_P'
#    'SpW4_Dout_N'                 : {'location': 'IOB19_D14N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #SpW4_Dout_N'
#    'SpW4_Dout_P'                 : {'location': 'IOB19_D14P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #SpW4_Dout_P'
#    'SpW4_Sout_N'                 : {'location': 'IOB19_D15N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #SpW4_Sout_N'
#    'SpW4_Sout_P'                 : {'location': 'IOB19_D15P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #SpW4_Sout_P'
#    'SpW_B1_N'                    : {'location': 'IOB19_D16N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #SpW_B1_N'
#    'SpW_B1_P'                    : {'location': 'IOB19_D16P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #SpW_B1_P'
#    'Esi_ADR_SWB2_N'              : {'location': 'IOB19_D17N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_ADR_SWB2_N'
#    'Esi_ADR_SWB2_P'              : {'location': 'IOB19_D17P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_ADR_SWB2_P'
#
#    #BANK 20
#    'SpW_A4_P'                    : {'location': 'IOB20_D17P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #SpW_A4_P'
#    'SpW_A4_N'                    : {'location': 'IOB20_D17N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #SpW_A4_N'
#    'SpW_A2_P'                    : {'location': 'IOB20_D16P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #SpW_A2_P'
#    'SpW_A2_N'                    : {'location': 'IOB20_D16N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #SpW_A2_N'
#    'SpW1_Sout_P'                 : {'location': 'IOB20_D15P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #SpW1_Sout_P'
#    'SpW1_Sout_N'                 : {'location': 'IOB20_D15N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #SpW1_Sout_N'
#    'SpW1_Dout_P'                 : {'location': 'IOB20_D14P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #SpW1_Dout_P  or TRACEPKT4
#    'SpW1_Dout_N'                 : {'location': 'IOB20_D14N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #SpW1_Dout_N  or TRACEPKT5
#    'NET0_MDIO'                   : {'location': 'IOB20_D13P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_MDIO'   or TRACE_SYNC
#    'NET0_MDC'                    : {'location': 'IOB20_D13N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_MDC'    or TRACEPKT0
#    'NET0_RX_DV'                  : {'location': 'IOB20_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_RX_DV'  or TRACEPKT9
#    'Esi_SPImode'                 : {'location': 'IOB20_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_SPImode'
#    'NET0_RX_D2'                  : {'location': 'IOB20_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_RX_D2'  or TRACEPKT3
#    'NET0_RX_D5'                  : {'location': 'IOB20_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_RX_D5'
#    'NET0_RX_D3'                  : {'location': 'IOB20_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_RX_D3'  or TRACEPKT10
#    'NET0_RX_D0'                  : {'location': 'IOB20_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_RX_D0'  or TRACEPKT11
#    'Esi_reset'                   : {'location': 'IOB20_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_reset'
#    'NET0_RX_D1'                  : {'location': 'IOB20_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_RX_D1'  or TRACEPKT8
#    'PG_C2M'                      : {'location': 'IOB20_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #PG_C2M'
#    'NET0_RX_D6'                  : {'location': 'IOB20_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_RX_D6'
#    'NET0_RX_D7'                  : {'location': 'IOB20_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_RX_D7'
#    'NET0_RX_D4'                  : {'location': 'IOB20_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_RX_D4'
#    'Esi_SSO_SF_RCLK0_P'          : {'location': 'IOB20_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_SSO_SF_RCLK0_P'
#    'Esi_SSO_SF_RCLK0_N'          : {'location': 'IOB20_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_SSO_SF_RCLK0_N'
#    'Esi_SYNCO_P'                 : {'location': 'IOB20_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_SYNCO_P'
#    'Esi_SYNCO_N'                 : {'location': 'IOB20_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_SYNCO_N'
#    'Esi_AFU1_P'                  : {'location': 'IOB20_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_AFU1_P'
#    'Esi_AFU1_N'                  : {'location': 'IOB20_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #Esi_AFU1_N'
#    'TRACEPKT7'                   : {'location': 'IOB20_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #TRACEPKT7'
#    'PIPESTAT0'                   : {'location': 'IOB20_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #PIPESTAT0'
#    'PIPESTAT1'                   : {'location': 'IOB20_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #PIPESTAT1'
#
#    #BANK 21
#    'CAR_SYSREF_N'                : {'location': 'IOB21_D01N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #CAR_SYSREF_N
#    'CAR_SYSREF_P'                : {'location': 'IOB21_D01P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #CAR_SYSREF_P
#    'DAC38_SYNC_N'                : {'location': 'IOB21_D02N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DAC38_SYNC_N
#    'DAC38_SYNC_P'                : {'location': 'IOB21_D02P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #DAC38_SYNC_P
#    'F2_HB0'                      : {'location': 'IOB21_D03N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F2_HB0
#    'F2_HB1'                      : {'location': 'IOB21_D03P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F2_HB1
#    'GTX_CLK_N'                   : {'location': 'IOB21_D04N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #GTX_CLK_N
#    'GTX_CLK_P'                   : {'location': 'IOB21_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #GTX_CLK_P
#    'F2_HB2'                      : {'location': 'IOB21_D05N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F2_HB2
#    'F2_HB3'                      : {'location': 'IOB21_D05P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F2_HB3
#    'F2_HB4'                      : {'location': 'IOB21_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F2_HB4
#    'F2_HB5'                      : {'location': 'IOB21_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F2_HB5
#    'F2_HB8'                      : {'location': 'IOB21_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F2_HB8
#    'F2_HB7'                      : {'location': 'IOB21_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F2_HB7
#    'F2_HB9'                      : {'location': 'IOB21_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F2_HB9
#
#
#    #BANK 22
#    'OVRA'                        : {'location': 'IOB22_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO2
#    'FMC_SDO'                     : {'location': 'IOB22_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO3
#    'FMC_SEN_LMK'                 : {'location': 'IOB22_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO5
#    'FMC_DIR_CTRL'                : {'location': 'IOB22_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO6
#    'FMC_SDIO'                    : {'location': 'IOB22_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO7
#    'FMC_B6'                      : {'location': 'IOB22_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO8
#    'FMC_SEN_DAC'                 : {'location': 'IOB22_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO9
#    'FMC_SCLK'                    : {'location': 'IOB22_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO10
#    'FMC_SEN_B5'                  : {'location': 'IOB22_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #User_IO12
#
#    #BANK 23
#    'F1_GA0'                      : {'location': 'IOB23_D04P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1_GA0
#    'NET0_INTn'                   : {'location': 'IOB23_D06N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_INTn
#    'F1_GA1'                      : {'location': 'IOB23_D06P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1_GA1
#    'TRACEPKT12'                  : {'location': 'IOB23_D07N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #TRACEPKT12
#    'PG1_M2C'                     : {'location': 'IOB23_D07P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #PG1_M2C
#    'TRACEPKT13'                  : {'location': 'IOB23_D08N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #TRACEPKT13
#    'F1_IO0'                      : {'location': 'IOB23_D08P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1_IO0
#    'F1_IO8'                      : {'location': 'IOB23_D09N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1_IO8
#    'F1_IO9'                      : {'location': 'IOB23_D09P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1_IO9
#    'F1_IO10'                     : {'location': 'IOB23_D10N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1_IO10
#    'TRACE_CLK'                   : {'location': 'IOB23_D10P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #TRACE_CLK
#    'F1_IO11'                     : {'location': 'IOB23_D11N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1_IO11
#    'F1_IO1'                      : {'location': 'IOB23_D11P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1_IO1
#    'F1_IO13'                     : {'location': 'IOB23_D12N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1_IO13
#    'F1_IO14'                     : {'location': 'IOB23_D12P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1_IO14
#    'F1_IO6'                      : {'location': 'IOB23_D13N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1_IO6
#    'F1_IO7'                      : {'location': 'IOB23_D13P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1_IO7
#    'F1_IO5'                      : {'location': 'IOB23_D14N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1_IO5
#    'F1_IO4'                      : {'location': 'IOB23_D14P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1_IO4
#    'F1_IO2'                      : {'location': 'IOB23_D15N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1_IO2
#    'NET0_RSTn'                   : {'location': 'IOB23_D15P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_RSTn
#    'F1_IO12'                     : {'location': 'IOB23_D16N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1_IO12
#    'F1_IO15'                     : {'location': 'IOB23_D16P', 'standard': 'LVCMOS', 'drive' :'2mA'}, #F1_IO15
#    'NET0_RXS_COL'                : {'location': 'IOB23_D17N', 'standard': 'LVCMOS', 'drive' :'2mA'}, #NET0_RXS_COL
#    'F1_IO3'                      : {'location': 'IOB23_D17P', 'standard': 'LVCMOS', 'drive' :'2mA'} #F1_IO3
#
   }
    return pads
