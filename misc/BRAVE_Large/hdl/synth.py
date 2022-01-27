Variant     = 'NG-LARGE'
TopCellName = 'top'
import sys
sys.path.insert(0, "./sub_scripts")
import script
if len(sys.argv) > 1:
    Option = sys.argv[1]
else:
    Option = None
script.__main__(Variant,TopCellName,Option)
