#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --partition=haswell64
#SBATCH --time=00:15:00
#SBATCH --exclusive
#SBATCH -J my_job

gettime () 
{
    echo $(($(date +%s%N)/1000000))
}

APP="./my_application"

export OMP_NUM_THREADS=24

STARTTIME=`gettime`

srun --acctg-freq=2,energy=1 --profile=energy --ntasks 1 --cpus-per-task $OMP_NUM_THREADS $APP

ENDTIME=`gettime`
TIME=`echo "scale=3; ($ENDTIME - $STARTTIME) / 1000" | bc -l`

mv /scratch/profiling/`whoami`/$SLURM_JOB_ID*h5 .

echo "My application took: ${TIME} s"
echo "HDEEM energy profile can be found in: $SLURM_JOB_ID HDF5 file"
