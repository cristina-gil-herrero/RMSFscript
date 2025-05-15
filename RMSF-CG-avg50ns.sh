# Script to calculate the BB RMSF of an CG trajectory of 1us.

run="dynamic" # change this according to the file names of you production run

# Removing pbc and slicing the trajectory in 50 ns parts 
echo "1 0" | gmx_mpi trjconv -f $run.xtc -pbc whole -center -s $run.tpr -b 0      -e    50000 -o CG-CK1d-0-50ns.xtc 
echo "1 0" | gmx_mpi trjconv -f $run.xtc -pbc whole -center -s $run.tpr -b 50000  -e   100000 -o CG-CK1d-50-100ns.xtc 
echo "1 0" | gmx_mpi trjconv -f $run.xtc -pbc whole -center -s $run.tpr -b 100000 -e   150000 -o CG-CK1d-100-150ns.xtc 
echo "1 0" | gmx_mpi trjconv -f $run.xtc -pbc whole -center -s $run.tpr -b 150000 -e   200000 -o CG-CK1d-150-200ns.xtc 
echo "1 0" | gmx_mpi trjconv -f $run.xtc -pbc whole -center -s $run.tpr -b 200000 -e   250000 -o CG-CK1d-200-250ns.xtc 

mkdir -p RMSF_calc
cd RMSF_calc

# Looping over the 50ns snippets
for time_range in "0-50ns" "50-100ns" "100-150ns" "150-200ns" "200-250ns"
do
    rm -rf ${time_range}
    mkdir ${time_range}
    
    cd ${time_range}
    cp ../../get_BB-lowRMSF.py .

    # Creating alpha carbon index
    printf "a BB\nq\n" | gmx_mpi make_ndx -f ../../$run.gro -o BB.ndx

    # First iteration - different index needed
    cat BB.ndx  > index_BBrigid.ndx # creating the index file for the rigid BB
    echo "15 0" | gmx_mpi trjconv -f ../../CG-CK1d-${time_range}.xtc -s ../../$run.tpr -fit rot+trans -n index_BBrigid.ndx -o md_fitBB.xtc # fitting the trajectory to the rigid BB
    echo "15" | gmx_mpi rmsf -f md_fitBB.xtc -s ../../$run.tpr -n index_BBrigid.ndx -o rmsf_BBall.xvg -nofit # calculating the RMSF for all BB
    python3 get_BB-lowRMSF.py # getting the indices of the rigid BB
    
    # Entering the loop
    for i in $(seq 1 6)
    do
        cat BB.ndx ind.tmp > index_BBrigid.ndx
        echo "16 0" | gmx_mpi trjconv -f ../../CG-CK1d-${time_range}.xtc -s ../../$run.tpr -fit rot+trans -n index_BBrigid.ndx -o md_fitBB.xtc # fitting the trajectory to the rigid CA
        echo "15" | gmx_mpi rmsf -f md_fitBB.xtc -s ../../$run.tpr -n index_BBrigid.ndx -o rmsf_BBall.xvg -nofit # calculating the RMSF for all BB
        python3 get_BB-lowRMSF.py
    done
    
    echo "15" | gmx_mpi rmsf -f md_fitBB.xtc -s ../../$run.tpr -n index_BBrigid.ndx -o rmsf_BBall.xvg -nofit -res # calculating the final RMSF
    cp rmsf_BBall.xvg ../rmsf_BBall-${time_range}.xvg # copying the final RMSF to the parent directory
    rm \#* # removing the temporary files    
    cd ..
done
cd ..