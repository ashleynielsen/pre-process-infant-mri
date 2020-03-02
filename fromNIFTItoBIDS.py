import os
from os import path	
import sys

## BEFORE THIS SCRIPT IS RUN
# Need to run fromNUNDAtoNIFTI.sh

path_to_data='/projects/p30906/data/w2w_12/raw_nifti'

path_to_bids='/projects/p30906/data/w2w_12/bids'

T1='T1'
T2='T2'
rest='rfMRI'
DTI='mb4'
fmap='FieldMap'


for subject in os.listdir(path_to_data):
	path_to_subject=path_to_data+'/'+subject
	directory = os.listdir(path_to_subject)
	for fname in directory:
		if T1 in fname:
			if fname.endswith('Ra.nii.gz'):
				# copy nifti
				os.system('cp '+path_to_subject+'/'+fname+' '+path_to_bids+'/'+subject+'/anat/sub-'+subject+'_ses-12mo_T1w.nii.gz')
			if fname.endswith('Ra.json'):
				# copy json
				os.system('cp '+path_to_subject+'/'+fname+' '+path_to_bids+'/'+subject+'/anat/sub-'+subject+'_ses-12mo_T1w.json')
			if fname.endswith('R.nii.gz'):
				# copy nifti only if there isn't already a file there
				if not os.path.exists(path_to_bids+'/'+subject+'/anat/sub-'+subject+'_ses-12mo_T1w.nii.gz'):
					os.system('cp '+path_to_subject+'/'+fname+' '+path_to_bids+'/'+subject+'/anat/sub-'+subject+'_ses-12mo_T1w.nii.gz')
			if fname.endswith('R.json'):
				# copy json only if there isn't already a file there
				if not os.path.exists(path_to_bids+'/'+subject+'/anat/sub-'+subject+'_ses_12mo_T1w.json'):
					os.system('cp '+path_to_subject+'/'+fname+' '+path_to_bids+'/'+subject+'/anat/sub-'+subject+'_ses-12mo_T1w.json')
		if T2 in fname:
			if fname.endswith('Ca.nii.gz'):
				# copy nifti
				os.system('cp '+path_to_subject+'/'+fname+' '+path_to_bids+'/'+subject+'/anat/sub-'+subject+'_ses-12mo_T2w.nii.gz')
			if fname.endswith('Ca.json'):
				# copy json
				os.system('cp '+path_to_subject+'/'+fname+' '+path_to_bids+'/'+subject+'/anat/sub-'+subject+'_ses-12mo_T2w.json')
			if fname.endswith('C.nii.gz'):
				# copy nifti only if there isn't already a file there
				if not os.path.exists(path_to_bids+'/'+subject+'/anat/sub-'+subject+'_ses-12mo_T1w.nii.gz'):
					os.system('cp '+path_to_subject+'/'+fname+' '+path_to_bids+'/'+subject+'/anat/sub-'+subject+'_ses-12mo_T2w.nii.gz')
			if fname.endswith('C.json'):
				# copy json only if there isn't already a file there
				if not os.path.exists(path_to_bids+'/'+subject+'/anat/sub-'+subject+'_ses_12mo_T1w.json'):
					os.system('cp '+path_to_subject+'/'+fname+' '+path_to_bids+'/'+subject+'/anat/sub-'+subject+'_ses-12mo_T2w.json')

		if DTI in fname:
			if fname.endswith('P.nii.gz'):
				# copy nifti
				os.system('cp '+path_to_subject+'/'+fname+' '+path_to_bids+'/'+subject+'/dwi/sub-'+subject+'_ses-12mo_dwi.nii.gz')
			if fname.endswith('P.json'):
				# copy json
				os.system('cp '+path_to_subject+'/'+fname+' '+path_to_bids+'/'+subject+'/dwi/sub-'+subject+'_ses-12mo_dwi.json')
			if fname.endswith('P.bval'):
				# copy bval
				os.system('cp '+path_to_subject+'/'+fname+' '+path_to_bids+'/'+subject+'/dwi/sub-'+subject+'_ses-12mo_dwi.bval')
			if fname.endswith('P.bvec'):
				# copy bvec
				os.system('cp '+path_to_subject+'/'+fname+' '+path_to_bids+'/'+subject+'/dwi/sub-'+subject+'_ses-12mo_dwi.bvec')
		if fmap in fname:
			if fname.endswith('P.nii.gz'):
				# copy nifti
				os.system('cp '+path_to_subject+'/'+fname+' '+path_to_bids+'/'+subject+'/fmap/sub-'+subject+'_ses-12mo_spinecho.nii.gz')
			if fname.endswith('P.json'):
				# copy json
				os.system('cp '+path_to_subject+'/'+fname+' '+path_to_bids+'/'+subject+'/fmap/sub-'+subject+'_ses-12mo_spinecho.json')
		if rest in fname:  # NEED TO THINK ABOUT WHAT TO DO WITH MULTI RUN
			if fname.endswith('P.nii.gz'):
				# copy nifti
				os.system('cp '+path_to_subject+'/'+fname+' '+path_to_bids+'/'+subject+'/func/sub-'+subject+'_ses-12mo_task-sleep_bold.nii.gz')
			if fname.endswith('P.json'):
				# copy json
				os.system('cp '+path_to_subject+'/'+fname+' '+path_to_bids+'/'+subject+'/func/sub-'+subject+'_ses-12mo_task-sleep_bold.json')
			

					


