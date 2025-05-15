# RMSFscript
Scripts to calculate the RMSF of atomistic and CG trajectories.

Scripts to calculate the Calpha/backbone Root Mean Square Fluctuation 
(RMSF) of atomistic and coarse-grained (CG) trajectories. Trajectories 
are sliced into 200ns (atomistic)/50ns (CG) snippets and fitted to the 
Calpha atoms/BB beads with a RMSF below 0.15 nm. The script returns a 
.xvg file with the RMSF for each time window. An explanation of the 
script can be found at https://doi.org/10.1101/2025.03.17.64360.
