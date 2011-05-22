import sys
sys.path.append('build/lib.linux-x86_64-2.7')
from numpy import *
import rec

a=arange(10).reshape(2,5)

print a

rec.full_flowLSA([(1,1,1)], [(1,1,1)], 1)
