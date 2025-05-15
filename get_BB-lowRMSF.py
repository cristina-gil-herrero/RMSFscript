import numpy as np

file_dat = 'rmsf_BBall.xvg'
path = '' 
thresh = 0.15		# RMSD threshold [nm], can be modified

# # # # # # # # # # # # # # # # # #
#
#  read xvg file
#
def get_xvgdat(file_name, do_x2us, do_norm):
    xvgdat = np.loadtxt(file_name, dtype=float, comments=['#', '@'])
    xvgdat = xvgdat.T
    if do_x2us:
        xvgdat[0,:] = xvgdat[0,:] / 1000000.0
    
    if do_norm:
        max_dens = xvgdat[1:,:].max(1)
        for k in range(1, np.shape(xvgdat)[0]):
            xvgdat[k,:] = xvgdat[k,:] / max_dens[k]
    return xvgdat[0,:], xvgdat[1:,:]
#
# # # # # # # # # # # # # # # # # #

# main
BBind, rmsf = get_xvgdat(file_dat, 0, 0)

print( np.shape(BBind), np.shape(rmsf) )

count = 0
indlist = np.array([])

for k in rmsf[0,:]:
    if k <= thresh:
        indlist = np.append( indlist, BBind[count] )
    count = count + 1

print(indlist)

# save the data
np.savetxt('ind.tmp', indlist, fmt='%d', header='[ BB_rigid ]')
print ('All indices with RMSD <= thresh saved!')