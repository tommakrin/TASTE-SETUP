####################################################################################################
#########################################GLOBAL DECLARATION#########################################
####################################################################################################

#########################################LIBRARY IMPORTATION########################################
import sys
import traceback
import os

from nxmap import *

from variant_custom import variant_custom

def __main__(Variant,TopCellName,Option=None):

    ##########################################GLOBAL CONSTANT###########################################

    script_path  = os.getcwd()

    project_path = script_path + '/'+ TopCellName + '_' + Variant

    if not os.path.isdir(project_path):
            os.makedirs(project_path)

    sources_files_directory = script_path + '/src'
    rtl_files_directory     = project_path + '/rtl'

    ####################################################################################################
    ##########################################PROJECT CREATION##########################################
    ####################################################################################################

    ###########################################GLOBAL SETTING###########################################
    p = createProject(project_path)
    p.setVariantName(Variant)
    p.setTopCellName(TopCellName)

    ###########################################VARIANT SETTINGS#########################################

    board = variant_custom(Variant,sources_files_directory)
    board.add_files(p,Option)
    board.set_parameters(p,Option)
    board.set_options(p,Option)

    if not board.is_embedded():
        p.addBanks(board.bank(Option))
        p.addPads(board.pads(Option))

    ####################################################################################################
    ##########################################PROJECT PROGRESS##########################################
    ####################################################################################################

    ##########################################PROJECT SYNTHESIZE########################################

    p.save(rtl_files_directory + '/native_'+ str(Option) + '.nym')
    if not p.synthesize():
        p.destroy()
        sys.exit(1)
    p.save(rtl_files_directory + '/synthesized_'+ str(Option) + '.nym')

    ############################################PROJECT PLACE###########################################

    #Placing
    if not p.place():
        p.destroy()
        sys.exit(1)
    p.save(rtl_files_directory + '/placed_'+ str(Option) + '.nym')

    ############################################PROJECT ROUTE###########################################

    if not p.route():
        p.destroy()
        sys.exit(1)

    p.save(rtl_files_directory + '/routed_'+ str(Option) + '.nym')

    ############################################PROJECT REPORT##########################################

    p.reportInstances()

    ############################################TIMING ANALYSIS#########################################

    #Bestcase
    Timing_analysis = p.createAnalyzer()
    Timing_analysis.launch({'conditions': 'bestcase', 'maximumSlack': 500, 'searchPathsLimit': 10})
    #standard
    Timing_analysis = p.createAnalyzer()
    Timing_analysis.launch({'conditions': 'typical', 'maximumSlack': 500, 'searchPathsLimit': 10})
    #Worstcase
    Timing_analysis = p.createAnalyzer()
    Timing_analysis.launch({'conditions': 'worstcase', 'maximumSlack': 500, 'searchPathsLimit': 10})

    ##########################################BISTREAM GENERATION#######################################

    p.generateBitstream(format("%s/../bitstream/R5.nxb" % project_path))

    ################################################SUMMARY#############################################
    print('Errors: ', getErrorCount())
    print('Warnings: ', getWarningCount())
    printText('Design successfully generated')
