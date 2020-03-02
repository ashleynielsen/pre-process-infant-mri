#!/bin/bash

module load fsl
source $FSLDIR/etc/fslconf/fsl.sh

path_to_bids=/projects/p30906/data/w2w_12/bids

path_to_babyFS=/projects/p30906/data/w2w_12/infant_fs_initial

subject_paths=($path_to_bids/*)
numSubs=${#subject_paths[@]}

for (( i=0; i<$numSubs; i++));
do

subject=$(echo ${subject_paths[$i]} | cut -d'/' -f7-) # I HAVE NO IDEA WHY THIS WORKS
path_to_T1=${subject_paths[$i]}/anat/sub-${subject}_ses-12mo_T1w.nii.gz
path_to_output=${path_to_babyFS}/${subject}

# 
if [ -f "$path_to_T1" ]
then
	if [ ! -d "$path_to_output" ]
	then
		mkdir $path_to_output	
		cp $path_to_T1 $path_to_output
		cd $path_to_output
		Bet
	fi
fi

done


	
