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
    v{epoch_count,1}=reshape(NC(:, v_index(epoch_count):v_index(epoch_count)+(v_values(1,epoch_count)-1)), [], 1);
    v_x{epoch_count,1}=reshape(NC2(:, v_index(epoch_count):v_index(epoch_count)+(v_values(1,epoch_count)-1)), [], 1);
end 

NREMEpoches = v;
PFCEpoches = v_x;