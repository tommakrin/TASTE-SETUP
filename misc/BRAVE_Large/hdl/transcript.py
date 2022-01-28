import sys
import traceback
from nxmap import *
p = createProject()
p.destroy()
p = createProject()
p.load('/work/hdl/top_NG-LARGE/synthesized-auto.nym')
p.progress('Place', 3)
