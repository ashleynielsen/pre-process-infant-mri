#!/bin/tcsh -ef

set subject_id = 4480
set ses = 12mo
set subject_age = 15
set study = w2w_12

source $FSLDIR/etc/fslconf/fsl.csh

# Load infant freesurfer
setenv FREESURFER_HOME ~/bin/freesurfer
setenv FS_LICENSE ~/scripts/license.txt
source $FREESURFER_HOME/SetUpFreeSurfer.csh
#setenv FSFAST_HOME ~/bin/infant_fs/freesurfer/fsfast

source ~/bin/freesurfer/bin/set_babydev_packages.csh

setenv SUBJECTS_DIR /projects/p30906/data/${study}/infant_fs_initial

# Do FSLmaths
fslmaths ${SUBJECTS_DIR}/${subject_id}/sub-${subject_id}_ses-${ses}_T1w.nii.gz -mul ${SUBJECTS_DIR}/${subject_id}/sub-${subject_id}_ses-${ses}_T1w_brain_mask_revised.nii.gz ${SUBJECTS_DIR}/${subject_id}/sub-${subject_id}_ses-${ses}_T1w_brain.nii.gz

# Intensity normalization - Apparently this one is bad
#mri_nu_correct.mni --i ${SUBJECTS_DIR}/${subject_id}/sub-${subject_id}_ses-${ses}_T1w_masked_afterEdits.nii.gz --o ${SUBJECTS_DIR}/${subject_id}/mprage_nu.nii.gz --n 2

# Intensity normalization
set maxval = `fslstats ${SUBJECTS_DIR}/${subject_id}/sub-${subject_id}_ses-${ses}_T1w_brain.nii.gz -R | awk '{print $2}'`
fslmaths ${SUBJECTS_DIR}/${subject_id}/sub-${subject_id}_ses-${ses}_T1w_brain.nii.gz -div $maxval -mul 255 ${SUBJECTS_DIR}/${subject_id}/sub-${subject_id}_ses-${ses}_T1w_brain_255 -odt char
cp ${SUBJECTS_DIR}/${subject_id}/sub-${subject_id}_ses-${ses}_T1w_brain_255.nii.gz ${SUBJECTS_DIR}/${subject_id}/mprage.nii.gz
mri_convert ${SUBJECTS_DIR}/${subject_id}/mprage.nii.gz ${SUBJECTS_DIR}/${subject_id}/mprage.mgz

# Try mri_convert
#mri_convert --conform mprage_nu.nii.gz mprage_nu.nii.gz

# Run infant_fs
infant_recon_all --s ${subject_id} --force --masked ${SUBJECTS_DIR}/${subject_id}/mprage.nii.gz --age ${subject_age}

