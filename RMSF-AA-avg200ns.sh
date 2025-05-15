# Script to calculate the CA RMSF of an atomistic trajectory of 1us.

run="step5.0_production" # change this according to the file names of you production run

# Removing pbc and slicing the trajectory in 200 ns parts 
echo "1 0" | gmx_mpi trjconv -f $run.xtc -pbc whole -center -s $run.tpr -b 0      -e 200000  -o AA-CK1d-0-200ns.xtc   
echo "1 0" | gmx_mpi trjconv -f $run.xtc -pbc whole -center -s $run.tpr -b 200000 -e 400000  -o AA-CK1d-200-400ns.xtc 
echo "1 0" | gmx_mpi trjconv -f $run.xtc -pbc whole -center -s $run.tpr -b 400000 -e 600000  -o AA-CK1d-400-600ns.xtc 
echo "1 0" | gmx_mpi trjconv -f $run.xtc -pbc whole -center -s $run.tpr -b 600000 -e 800000  -o AA-CK1d-600-800ns.xtc 
echo "1 0" | gmx_mpi trjconv -f $run.xtc -pbc whole -center -s $run.tpr -b 800000 -e 1000000 -o AA-CK1d-800-1micro.xtc

mkdir -p RMSF_calc
cd RMSF_calc

# Looping over the 200ns snippets
for time_range in 0-200ns 200-400ns 400-600ns 600-800ns 800-1micro
do
    rm -rf ${time_range}
    mkdir ${time_range}
    
    cd ${time_range}
    cp ../../get_BB-lowRMSF.py .

    # Creating alpha carbon index
    printf "a CA\nq\n" | gmx_mpi make_ndx -f ../../$run.gro -o CA.ndx

    # First iteration - different index needed
    cat CA.ndx  > index_CArigid.ndx # creating the index file for the rigid CA
    echo "16 0" | gmx_mpi trjconv -f ../../AA-CK1d-${time_range}.xtc -s ../../$run.tpr -fit rot+trans -n index_CArigid.ndx -o md_fitBB.xtc # fitting the trajectory to the rigid CA
    echo "16" | gmx_mpi rmsf -f md_fitBB.xtc -s ../../$run.tpr -n index_CArigid.ndx -o rmsf_BBall.xvg -nofit # calculating the RMSF for all CA
    python3 get_BB-lowRMSF.py # getting the indices of the rigid CA
    
    # Entering the loop
    for i in $(seq 1 6)
    do
    cat CA.ndx ind.tmp > index_CArigid.ndx # creating the index file for the rigid CA
    echo "17 0" | gmx_mpi trjconv -f ../../AA-CK1d-${time_range}.xtc -s ../../$run.tpr -fit rot+trans -n index_CArigid.ndx -o md_fitBB.xtc  # fitting the trajectory to the rigid CA
    echo "16" | gmx_mpi rmsf -f md_fitBB.xtc -s ../../$run.tpr -n index_CArigid.ndx -o rmsf_BBall.xvg -nofit # calculating the RMSF for all CA
    python3 get_BB-lowRMSF.py # getting the indices of the rigid CA
    done
    
    echo "16" | gmx_mpi rmsf -f md_fitBB.xtc -s ../../$run.tpr -n index_CArigid.ndx -o rmsf_BBall.xvg -nofit -res # calculating the final RMSF
    cp rmsf_BBall.xvg ../rmsf_BBall-${time_range}.xvg # copying the final RMSF to the parent directory
    rm \#* # removing the temporary files
    cd ..
done
cd ..