#!/bin/bash
set -e
# GP="-nb gpu -pme gpu -pmefft gpu -ntomp 8" #Uncomment and change based on GPU settings.

# Load required modeules: e.g.
# module load fftw/3.3.10-openmpi-gcc gcc/12.2.0 cuda/12.2 mpich/4.1-gcc openmpi/4.1.6-gcc
G=gmx #Change to the gromacs binary

if [ ! -f mem_em.gro ]
then
     $G grompp -f minim.mdp -c solv.gro -p swiss_mem2.top -o mem_em.tpr -maxwarn 2
     $G mdrun -v -deffnm mem_em -rdd 1.3 -ntomp 8
fi

if [ ! -f mem_nvt.gro ]
then
     $G grompp -f nvt.mdp -c mem_em.gro -p swiss_mem2.top -o mem_nvt.tpr -maxwarn 2 -n index.ndx 
     $G mdrun -v -deffnm mem_nvt -rdd 1.3 $GP
fi
     
if [ ! -f mem_npt.gro ]
then
     $G grompp -f npt.mdp -c mem_nvt.gro -p swiss_mem2.top -o mem_npt.tpr -maxwarn 2 -n index.ndx  
     $G mdrun -v -deffnm mem_npt -rdd 1.3 $GP 
fi

if [ ! -f pull2.cpt ]
then
     sbatch run_pull2.sh 
fi

if [ ! -f pull.cpt ]
then
     $G grompp -f pull.mdp -c mem_npt.gro -p swiss_mem2.top -o pull.tpr -maxwarn 2  -n index.ndx 
     $G mdrun -v -deffnm pull -rdd 1.3 $GP 
fi

#Might need additional pulling in opposite direction to span the required CV
