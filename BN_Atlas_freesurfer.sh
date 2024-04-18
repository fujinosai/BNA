#! /bin/bash

## Author: Raven / qiaokn123@163.com 

## print script usage
Usage () {
    cat <<USAGE
------------------------------------------------------------------------------------------
`basename $0` parcellates the brain using non-builtin atlases (BN_Atlas) based on recon-all results
------------------------------------------------------------------------------------------
Usage example:

bash $0 -a /home/alex/input/freesurfer
------------------------------------------------------------------------------------------
Required arguments:
        -a: FreeSurfer recon-all directory

------------------------------------------------------------------------------------------
USAGE
    exit 1
}

## parse arguments
if [[ $# -lt 4 ]]
then
    Usage >&2
    exit 1
else
        while getopts "a:b:" OPT
        do
          case $OPT in
                a) ## recon-all directory
                RECONALL=$OPTARG
                ;;
                b) ## output directory
                OUTDIR=$OPTARG
                ;;
                *) ## getopts issues an error message
                echo "ERROR:  unrecognized option -$OPT $OPTARG"
                exit 1
                ;;
        esac
    done
fi

## set FreeSurfer required environmental variables
export SUBJECTS_DIR=$(dirname ${RECONALL})
SUBJECT=$(basename ${RECONALL})

ATLASDIR=/home/qiaokn/Desktop/MyFeatures/0scripts/Atlases

for hemi in lh rh
do
        # mapping BN_atlas cortex to subjects
        mris_ca_label -l ${SUBJECTS_DIR}/${SUBJECT}/label/${hemi}.cortex.label ${SUBJECT} ${hemi} ${SUBJECTS_DIR}/${SUBJECT}/surf/${hemi}.sphere.reg ${ATLASDIR}/BN_Atlas/${hemi}.BN_Atlas.gcs ${SUBJECTS_DIR}/${SUBJECT}/label/${hemi}.BN_Atlas.annot -t ${ATLASDIR}/BN_Atlas/BN_Atlas_210_LUT.txt
        mris_anatomical_stats -mgz -cortex ${SUBJECTS_DIR}/${SUBJECT}/label/${hemi}.cortex.label -f ${SUBJECTS_DIR}/${SUBJECT}/stats/${hemi}.BN_Atlas.stats -b -a ${SUBJECTS_DIR}/${SUBJECT}/label/${hemi}.BN_Atlas.annot -c ${ATLASDIR}/BN_Atlas/BN_Atlas_210_LUT.txt ${SUBJECT} ${hemi} white
done

mri_aparc2aseg --s ${SUBJECT} --annot BN_Atlas --o ${SUBJECTS_DIR}/${SUBJECT}/mri/BN_Atlas.nii.gz

### mapping BN_atlas subcortex to subjects 
mri_ca_label ${SUBJECTS_DIR}/${SUBJECT}/mri/brain.mgz ${SUBJECTS_DIR}/${SUBJECT}/mri/transforms/talairach.m3z ${ATLASDIR}/BN_Atlas/BN_Atlas_subcortex.gca ${SUBJECTS_DIR}/${SUBJECT}/mri/BN_Atlas_subcortex.mgz
mri_segstats --seg ${SUBJECTS_DIR}/${SUBJECT}/mri/BN_Atlas_subcortex.mgz --ctab ${ATLASDIR}/BN_Atlas/BN_Atlas_246_LUT.txt --excludeid 0 --sum ${SUBJECTS_DIR}/${SUBJECT}/stats/BN_Atlas_subcortex.stats


for meas in thickness area volume
do
        for hemi in lh rh
        do
                aparcstats2table --subjects ${SUBJECT} --hemi ${hemi} --parc BN_Atlas --meas ${meas} --tablefile ${OUTDIR}/BN_Atlas_${hemi}_${meas}.txt
        done
done

asegstats2table --subjects ${SUBJECT} --meas volume --tablefile ${OUTDIR}/BN_Atlas_subcortex.txt --stats=BN_Atlas_subcortex.stats
