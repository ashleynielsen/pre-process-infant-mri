#!/bin/bash

# CHANGE THESE INPUTS FOR EVERY SUBJECT
subject=1171
# scan numbers to delete:
delete_scans=(1 2 5 7 99)

# CHANGE THESE INPUTS FOR EACH PROJECT
dicom_directory=/projects/p30906/data/phbp/raw_dicoms
nifti_directory=/projects/p30906/data/phbp/raw_nifti
bids_directory=/projects/p30906/data/phbp/bids
nunda_script=/home/ann0213/scripts/NUNDA
nifti_script=/home/ann0213/scripts
nunda_username=nielsena
nunda_password=2059857
nunda_id=PHBP

# ----- DON'T CHANGE ANYTHING BELOW HERE ----- #

# Download all scans from NUNDA
$nunda_script/download_scans.sh -s $subject -u $nunda_username -p $nunda_password -d $dicom_directory -i $nunda_id

# Remove unnecessary scans
rm $dicom_directory/*.gif
rm -rf $dicom_directory/NUNDA_metadata
numDelete=${#delete_scans}

for i in ${delete_scans[@]}; do
	rm -rf ${dicom_directory}/${subject}/SCANS/${i}
done

# convert to nifti
mkdir $nifti_directory/$subject
$nifti_script/dcm2niix -b y -o ${nifti_directory}/${subject} -z y -f "%i_%d" ${dicom_directory}/${subject}

# make BIDS directory
mkdir ${bids_directory}/$subject
mkdir ${bids_directory}/${subject}/anat
mkdir ${bids_directory}/${subject}/dwi
mkdir ${bids_directory}/${subject}/fmap
mkdir ${bids_directory}/${subject}/func

