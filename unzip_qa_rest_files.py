import os
import tarfile

# PATH to qa_rest
path_to_qa = '/projects/p30906/data/w2w_12/qa_rest'
f = open('path_to_motion.txt','a+')

for subject in os.listdir(path_to_qa):
	subject
	path_to_subject = path_to_qa+'/'+subject
	path_to_seq = path_to_subject+'/'+os.listdir(path_to_subject)[0]
	for seq in os.listdir(path_to_seq):
		path_to_tar = path_to_seq+'/'+seq
		if os.listdir(path_to_tar)[0].endswith('bz2'):		
			f.write(path_to_tar+"\n")
			os.chdir(path_to_tar)			
			tarfile.open(path_to_tar+'/'+os.listdir(path_to_tar)[0],'r:bz2').extractall()
			os.listdir(path_to_tar)[0]

