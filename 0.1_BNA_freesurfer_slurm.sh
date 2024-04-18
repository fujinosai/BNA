DATADIR=/data02/BIM_data/Project135/process/phipipe/v1.1/V1
OUTDIR=/home/qiaokn/Desktop/MyFeatures/BN_Atlas_Features
for SUBJ in $( ls  $DATADIR )
do
        JOBDIR=${OUTDIR}/${SUBJ}
        mkdir -p ${JOBDIR}
        JOBFILE="${JOBDIR}/BN_Atlas_freesurfer_${SUBJ}.job"
        echo "#! /bin/bash

#SBATCH --job-name=BN_Atlas_freesurfer_${SUBJ}
#SBATCH --partition=long.q
#SBATCH --output=${JOBDIR}/BN_Atlas_freesurfer_${SUBJ}.out
#SBATCH --error=${JOBDIR}/BN_Atlas_freesurfer_${SUBJ}.err
bash BNA_freesurfer.sh -a $DATADIR/$SUBJ/t1_proc/freesurfer -b $OUTDIR/${SUBJ}
sleep 10m" > ${JOBFILE}
        sbatch ${JOBFILE}
done
