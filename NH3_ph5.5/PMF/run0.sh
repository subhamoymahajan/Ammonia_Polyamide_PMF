#!/bin/bash --login
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --time=24:00:00
#SBATCH --mem=10G
#SBATCH --job-name=n48_NH3
#SBATCH --account=nawimem
#SBATCH --error=%x-%j.err
#SBATCH --output=%x-%j.out

GP="-nb gpu -pme gpu -pmefft gpu "

#module load fftw/3.3.10-openmpi-gcc gcc/12.2.0 cuda/12.2 mpich/4.1-gcc openmpi/4.1.6-gcc
#GM=~/software/gmx_plumed_gpu2/bin/gmx


module load fftw/3.3.10-openmpi-gcc gcc/12.2.0 mpich/4.1-gcc openmpi/4.1.6-gcc
GM=~/software/gmx2023_gpu/bin/gmx_mpi

function run_sim () {
	NAME=$1
	MDP=$2
	LAST=$3
	NDX=$4
	TOP=$5
	EXTRA=$6
        if [ -f ${NAME}.cpt ]
        then
           srun $GM  mdrun -v -deffnm ${NAME} -rdd 1.3 -s ${NAME}.tpr -cpi ${NAME}.cpt -append -px ${NAME}_pullx.xvg -pf ${NAME}_pullf.xvg $GP -nsteps 30000000

        else
	    if [ -z $EXTRA ]
	    then
                   srun --ntasks=1 $GM grompp -f $MDP -c $LAST -n $NDX -p $TOP -o ${NAME}.tpr -maxwarn 2 
            else
                   srun --ntasks=1 $GM grompp -f $MDP -c $LAST -n $NDX -p $TOP -o ${NAME}.tpr -maxwarn 2 ${EXTRA} 
	    fi
            srun $GM mdrun -v -deffnm ${NAME} -rdd 1.3 $GP 
        
        fi
}

#if [ ! -f temper[I].gro ]
#then
#    run_sim temper[I] temper[I].mdp sys[I].gro index.ndx swiss_mem2.top 
#fi
#
#if [ ! -f npt_umb[I].gro ]
#then
#run_sim npt_umb[I] npt_umb[I].mdp temper[I].gro index.ndx swiss_mem2.top "-t temper[I].trr" 
#fi

#if [ ! -f md_umb[I].gro ]
#then
run_sim md_umb[I] md_umb[I].mdp npt_umb[I].gro index.ndx swiss_mem2.top "-t npt_umb[I].trr" 
#fi
