#/bin/bash
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

STARTCPUENERGY=`cat /sys/class/powercap/intel-rapl/intel-rapl\:0/energy_uj`
STARTTIME=`gettime`

./my_application --parameters

ENDTIME=`gettime`
ENDCPUENERGY=`cat /sys/class/powercap/intel-rapl/intel-rapl\:0/energy_uj`


UJMAX=`cat /sys/class/powercap/intel-rapl/intel-rapl\:0/max_energy_range_uj`

if [[ $STARTCPUENERGY -gt $ENDCPUENERGY ]]; then
    CPUENERGY=`echo "scale=3; (($UJMAX - $STARTCPUENERGY) + $ENDCPUENERGY) / 1000000" | bc -l `
else
    CPUENERGY=`echo "scale=3; ($ENDCPUENERGY - $STARTCPUENERGY) / 1000000" | bc -l`
fi

TIME=`echo "scale=3; ($ENDTIME - $STARTTIME) / 1000" | bc -l`
CPUPOWER=`echo "scale=3; ($CPUENERGY / $TIME)" | bc -l`

echo "Runtime: ${TIME} seconds"
echo "CPU Energy: ${CPUENERGY} J"
echo "Power: ${CPUPOWER} W"


