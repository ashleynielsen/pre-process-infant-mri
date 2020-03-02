#!/bin/bash

# Written by Ashley Nielsen, completed XXXX

# This script will:
# (1) Download data from NUNDA to QUEST (and clean it up)
# (2) Convert DICOMS to NIFTI (and clean it up)
# (3) Re-name and re-format to BIDS


# CHANGE THESE INPUTS
output_directory=/projects/p30906/data/w2w_12

nunda_script=/home/ann0213/scripts/NUNDA
nunda_username=nielsena
nunda_password=2059857
nunda_id=W2W_12

dcm2niix_script=/home/ann0213/scripts
T1=SAG_T1w_MPRa
T2=SAG_T2W_SPCa
rest=rfMRI_REST_AP
dti=mb4_3k_79dir_1pt5mm_AP
fieldmap=SpinEchoFieldMap_AP

# MUST RUN THESE COMMANDS FIRST!!
# Downloading the raw dicoms takes a while...
# download DICOMS from NUNDA  	
#$nunda_script/download_scans.sh -u nielsena -p 2059857 -d $output_directory/raw_dicoms -i $nunda_id
#$nunda_script/download_reconstruction_file.sh -u nielsena -p 2059857 -d $output_directory/qa_rest -i $nunda_id -r QA_EPI_Human -f plQA.human.epi.*.bz2


######### MAIN SEQUENCE ##########
home_path=$(pwd)

# clean-up and get subject folders
rm $output_directory/raw_dicoms/*.gif
rm -rf $output_directory/raw_dicoms/NUNDA_metadata

# loop through subject dir
mkdir $output_directory/bids
mkdir $output_directory/raw_nifti
mkdir $output_directory/qa_rest/raw_files

subject_paths=($output_directory/raw_dicoms/*)
numSubs=${#subject_paths}
echo $numSubs

for (( i=0; i<$numSubs; i++));
do
	echo $i
	subjID=$(echo ${subject_paths[$i]} | cut -d'/' -f7-) # I HAVE NO IDEA WHY THIS WORKS
	echo $output_directory
	echo $subjID
	if [ -d "$ouput_directory/raw_nifti/$subjID" ]; then
	mkdir $output_directory/raw_nifti/$subjID
	$dcm2niix_script/dcm2niix -b y -o $output_directory/raw_nifti/$subjID -z y -f "%i_%d" ${subject_paths[$i]}/SCANS
	fi

	# Create BIDS structure
	mkdir $output_directory/bids/$subjID
	mkdir $output_directory/bids/$subjID/anat
	mkdir $output_directory/bids/$subjID/dwi
	mkdir $output_directory/bids/$subjID/func
	mkdir $output_directory/bids/$subjID/fmap

	
done


