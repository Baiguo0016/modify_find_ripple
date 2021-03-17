close all; clear all;

%% Load the file
%Make sure that the file is in the folder
load('PFC_100_CH52_0.continuous.mat');
load('HPC_100_CH17_0.continuous.mat')
load('2018-07-30_13-56-00_Post-Trial3-states.mat');
%% Rearrange signal in 1 sec epochs.
e_t=1;
fn = 1000;
e_samples = e_t*(fn); %fs=1kHz
ch=length(HPC);
nc=floor(ch/e_samples); %Number of epochsw
NC=[];
NC2 = [];

%% Rearrange signal in 1 sec epochs.
for kk=1:nc
    NC(:,kk)= HPC(1+e_samples*(kk-1) : e_samples*kk);
    NC2(:,kk)= PFC(1+e_samples*(kk-1) : e_samples*kk);
end

%% Find if epoch is NREM (state=3)
vec_bin=states;
vec_bin(vec_bin~=3)=0;
vec_bin(vec_bin==3)=1;

%% Cluster one values:
v2 = ConsecutiveOnes(vec_bin);
v_index = find(v2~=0);
v_values = v2(v2~=0);

%% Extract NREM epochs    
for epoch_count=1:length(v_index)
    NREMEpoches{epoch_count,1}=reshape(NC(:, v_index(epoch_count):v_index(epoch_count)+(v_values(1,epoch_count)-1)), [], 1);
    PFCEpoches{epoch_count,1}=reshape(NC2(:, v_index(epoch_count):v_index(epoch_count)+(v_values(1,epoch_count)-1)), [], 1);
end 

%% Params (defaults listed below)

% For PFCE
% ripthresh = [2 5]; %min std, max std
% ripdur = [10 100];

% For SWR
ripthresh = [0.5 4]; %min std, max std
ripdur = [10 100];

%% This has already down-sampled
clear ripple;
fs=1000; 
nr_epoches = size(NREMEpoches);


% data = NREMEpoches{16};
% t = [0:length(data)-1]*(1/fs);
% t = t';
% ripples = bz_FindRipples(data ,t, 'thresholds',ripthresh, 'durations',ripdur,'show','on','EMGThresh', 0, 'saveMat',true);


for idx_epoches = 1 : nr_epoches
    
    data = NREMEpoches{idx_epoches};
    t = [0:length(data)-1]*(1/fs);
    t = t.';
    ripples = bz_FindRipples(data ,t, 'thresholds',ripthresh, 'durations',ripdur,'show','off','EMGThresh', 0, 'saveMat',true);
    size_ripple = size(ripples.timestamps);
    nr_ripples(idx_epoches) = size_ripple(1);
    previous_ripple_nr(idx_epoches) = sum(nr_ripples) - nr_ripples(idx_epoches);
    for i = 1 : nr_ripples(idx_epoches)
        start_idx = find(t == ripples.timestamps(i, 1));
        end_idx = find(t == ripples.timestamps(i, 2));
        index = i + previous_ripple_nr(idx_epoches);
        ripple.timestamp{index} = t(start_idx : end_idx);
        ripple.amplitude{index} = data(start_idx : end_idx);
    end
end

save(fullfile(pwd, ['ripple.info.mat']),'ripple');