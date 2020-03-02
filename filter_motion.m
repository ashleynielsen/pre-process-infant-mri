function filter_motion(path_to_motion,plots_on,write_tmasks)
% Filter head motion parameters to reduce respiratory effects and identify
% true motion

% INPUTS:
%   path to motion - structure containing the paths to the motion paramters
%                    output by the QA_EPI_Human pipeline. These paths can
%                    be found by loading path_to_motion.txt, the output of
%                    unzip_qa_rest_files.py 
%
%   plots_on - if interested in seeing plots, 1, if not, 0.
%   
%   write_tmasks - I need to write this part, so that eventually will write
%   the tmasks in a location that I want


% PARAMETERS: ONLY MODIFY IF TOLD TO!
head_radius = 50; % Depends on age - give recs here
TR = 0.8; % Depends on scan
contig = 3; % How many contiguous frames?
min_frames = 120; % Minimum number of frames within a subject


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

count = 1;
for n = 1:size(path_to_motion,1)
ind_motion_data = load([path_to_motion{n,:},'/r3dvolreg.1d']);
if size(ind_motion_data,1)== 415 % only take long runs
   % create a file with all the paths with real sequences
   grp_motion_data(:,:,count) = ind_motion_data;
   count = count+1;
end
end

mvm = zeros(size(grp_motion_data,1),6,size(grp_motion_data,3));
% time x mvm x sub 
mvm(:,1,:) = grp_motion_data(:,6,:); % x trans
mvm(:,2,:) = grp_motion_data(:,7,:); % y trans
mvm(:,3,:) = grp_motion_data(:,5,:); % z trans
mvm(:,4,:) = grp_motion_data(:,2,:)*pi/180*head_radius; % x rot
mvm(:,5,:) = grp_motion_data(:,3,:)*pi/180*head_radius; % y rot
mvm(:,6,:) = grp_motion_data(:,4,:)*pi/180*head_radius; % z rot

%function FDfilt = filter_butter(TR,mvm)

% do the filtering
[butta buttb]=butter(1,0.1/(0.5/.8),'low');
pad = 100;
d = size(mvm);
temp_mot = cat(1, zeros(pad, 6, d(3)), mvm, zeros(pad, 6, d(3))); 
[temp_mot]=filtfilt(butta,buttb,double(temp_mot)); 
temp_mot = temp_mot(pad+1:end-pad, :,:); 
mvm_filt = temp_mot;

% diff filtered params
ddt_mvm_filt = [zeros(1,6,d(3)); diff(mvm_filt)];
ddt_mvm = [zeros(1,6,d(3)); diff(mvm)];

% calculate FD
FD = squeeze(sum(abs(ddt_mvm),2));
FD_filt = squeeze(sum(abs(ddt_mvm_filt),2));

% Find contiguous frames
FD_thresh = .2;
tmask_FD_contig = zeros(size(FD,1),size(FD,2));

for s = 1:size(FD,2)
    on_idx = find(diff(FD(:,s)<FD_thresh)==1)+1;
    off_idx = find(diff(FD(:,s)<FD_thresh)==-1)+1;
    
    % get the first bit
    if off_idx(1) >= contig
        tmask_FD_contig(1:off_idx(1)-1,s) = 1;
    end
    
    % get the last bit
    if on_idx(end)>off_idx(end)
        if size(FD,1)-on_idx(end) >= contig-1
            tmask_FD_contig(on_idx(end):end,s) = 1;
        end
    else
        if off_idx(end) - on_idx(end) >=contig
            tmask_FD_contig(on_idx(end):off_idx(end)-1,s) = 1;
        end
    end
    
    % get the middle bits
    for i = 1:length(on_idx)-1
        if off_idx(i+1) - on_idx(i) >= contig
            tmask_FD_contig(on_idx(i):off_idx(i+1)-1,s) = 1;
        end
    end
end
        
        
    
FD_thresh = .08;

tmask_FD_filt_contig = zeros(size(FD_filt,1),size(FD_filt,2));

for s = 1:size(FD_filt,2)
    on_idx = find(diff(FD_filt(:,s)<FD_thresh)==1)+1;
    off_idx = find(diff(FD_filt(:,s)<FD_thresh)==-1)+1;
    
    if ~isempty(off_idx) && ~isempty(on_idx)
        % get the first bit
        if off_idx(1) >= contig
            tmask_FD_filt_contig(1:off_idx(1)-1,s) = 1;
        end
        
        % get the last bit
        if on_idx(end)>off_idx(end)
            if size(FD_filt,1)-on_idx(end) >= contig-1
                tmask_FD_filt_contig(on_idx(end):end,s) = 1;
            end
        else
            if off_idx(end) - on_idx(end) >=contig
                tmask_FD_filt_contig(on_idx(end):off_idx(end)-1,s) = 1;
            end
        end
        
        % get the middle bits
        for i = 1:length(on_idx)-1
            if off_idx(i+1) - on_idx(i) >= contig
                tmask_FD_filt_contig(on_idx(i):off_idx(i+1)-1,s) = 1;
            end
        end
    else
        tmask_FD_filt_contig(:,s) = 1;
    end
end

% Get total number frames
total_frames_FD = sum(tmask_FD_contig);
total_frames_FD_filt = sum(tmask_FD_filt_contig);


disp(['Number of subs with at least ',num2str(min_frames),' frames: ',num2str(sum(total_frames_FD>=min_frames))]);
disp(['Number of subs with at least ',num2str(min_frames),' frames: ',num2str(sum(total_frames_FD_filt>=min_frames))]);

% Plot Figures
if plots_on
    
    % plot stuff for a random subject
    sub_idx = randperm(size(mvm,3),1);
    
    figure;
    subplot(2,2,1)
    plot(mvm(:,:,sub_idx))
    xlabel('TR')
    ylabel('Movement')
    legend({'x-trans','y-trans','z-trans','x-rot','y-rot','z-rot'})
    title('Before Filter')
    
    subplot(2,2,3)
    plot(mvm_filt(:,:,sub_idx))
    xlabel('TR')
    ylabel('Movement')
    legend({'x-trans','y-trans','z-trans','x-rot','y-rot','z-rot'})
    title('After Filter')
    
    subplot(2,2,2)
    plot(FD(:,sub_idx))
    hold on
    plot([1 size(FD,1)],[.2 .2],'r--')
    xlabel('TR')
    ylabel('Framewise Displacement')
    title('Before Filter')
    
    subplot(2,2,4)
    plot(FD_filt(:,sub_idx))
    hold on
    plot([1 size(FD_filt,1)],[.08 .08],'r--')
    xlabel('TR')
    ylabel('Framewise Displacement')
    title('After Filter')
    
    
    
    Fs = 1/TR; % Sampling frequency
    %L = size(r3dvolreg,1); % Signal length
    %t = [0:L-1]*TR; % time vector
    %NFFT = L;% 2^nextpow2(L); % next power of 2 from length
    %freq = Fs/2*linspace(0,1,NFFT/2+1)';
    % PMTM approach (as used in D. Fair paper)
    [pd_x_trans freq] = pmtm(squeeze(mvm(:,1,:)),8,[],Fs);
    [pd_y_trans freq] = pmtm(squeeze(mvm(:,2,:)),8,[],Fs);
    [pd_z_trans freq] = pmtm(squeeze(mvm(:,3,:)),8,[],Fs);
    [pd_x_rot freq] = pmtm(squeeze(mvm(:,4,:)),8,[],Fs);
    [pd_y_rot freq] = pmtm(squeeze(mvm(:,5,:)),8,[],Fs);
    [pd_z_rot freq] = pmtm(squeeze(mvm(:,6,:)),8,[],Fs);

    % Create power plots for each motion estimate BEFORE FILTER
    figure;
    title('BEFORE FILTER')
    subplot(2,3,1)
    plot(freq,pd_x_trans./sum(pd_x_trans))
    title('X-trans')
    subplot(2,3,2)
    plot(freq,pd_y_trans./sum(pd_y_trans))
    title('Y-trans')
    subplot(2,3,3)
    plot(freq,pd_z_trans./sum(pd_z_trans))
    title('Z-trans')
    subplot(2,3,4)
    plot(freq,pd_x_rot./sum(pd_x_rot))
    title('X-rot')
    subplot(2,3,5)
    plot(freq,pd_y_rot./sum(pd_y_rot))
    title('Y-rot')
    subplot(2,3,6)
    plot(freq,pd_z_rot./sum(pd_z_rot))
    title('Z-rot')
    
    % PMTM approach (as used in D. Fair paper)
    [pd_x_trans freq] = pmtm(squeeze(mvm_filt(:,1,:)),8,[],Fs);
    [pd_y_trans freq] = pmtm(squeeze(mvm_filt(:,2,:)),8,[],Fs);
    [pd_z_trans freq] = pmtm(squeeze(mvm_filt(:,3,:)),8,[],Fs);
    [pd_x_rot freq] = pmtm(squeeze(mvm_filt(:,4,:)),8,[],Fs);
    [pd_y_rot freq] = pmtm(squeeze(mvm_filt(:,5,:)),8,[],Fs);
    [pd_z_rot freq] = pmtm(squeeze(mvm_filt(:,6,:)),8,[],Fs);

    % Create power plots for each motion estimate AFTER FILTER
    figure;
    title('AFTER FILTER')
    subplot(2,3,1)
    plot(freq,pd_x_trans./sum(pd_x_trans))
    title('X-trans')
    subplot(2,3,2)
    plot(freq,pd_y_trans./sum(pd_y_trans))
    title('Y-trans')
    subplot(2,3,3)
    plot(freq,pd_z_trans./sum(pd_z_trans))
    title('Z-trans')
    subplot(2,3,4)
    plot(freq,pd_x_rot./sum(pd_x_rot))
    title('X-rot')
    subplot(2,3,5)
    plot(freq,pd_y_rot./sum(pd_y_rot))
    title('Y-rot')
    subplot(2,3,6)
    plot(freq,pd_z_rot./sum(pd_z_rot))
    
    % Plot how many subject have good data
    
     
    min_subs = 10:10:415;
    for m = 1:length(min_subs)
        survive_subs(m) = sum(total_frames_FD>=min_subs(m));
        survive_subs_filt(m) = sum(total_frames_FD_filt>=min_subs(m));
    end
    
    figure;
    plot(min_subs.*.8/60, survive_subs,'ro-')
    hold on
    plot(min_subs.*.8/60, survive_subs_filt,'ko-')
    xlabel('Minutes of data')
    ylabel('Number of subjects with good data')
    legend({'Before Filter','After Filter'})


end

