from numpy import *
from pymatlab.matlab import MatlabSession

# export LD_LIBRARY_PATH=/home/goshawk/Matlab/bin/glnxa64:$LD_LIBRARY_PATH

s = MatlabSession('matlab -nosplash -nodisplay')

s.run('''addpath(genpath('/home/goshawk/Desktop/recSys'))''')

s.run("load('/home/goshawk/Desktop/recSys/dataset/icm.mat')")
s.run("load('/home/goshawk/Desktop/recSys/dataset/urmTraining.mat')")

s.run("[model, recList] = full_flowLSA(urmTraining, icm, 5)")

print s.getvalue('recList')

s.run("recList1 = flowLSA(model, urmTraining, icm, 184)")

print s.getvalue('recList1')

s.close()
