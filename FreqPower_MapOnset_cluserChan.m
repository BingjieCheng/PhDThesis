%% FreqPower at Map onset: cluster channels

clear all;
close all;
eeglab

%% create channel clusters
front_chanLabels = {'Fz',  'F1', 'F2'}; %'EEG.data', which is a matrix of channels*samples*epoch
fc_chanLabels = {'FCz', 'FC1', 'FC2'}; %'EEG.data', which is a matrix of channels*samples*epoch
pariet_chanLabels = {'Pz', 'P1', 'P2'};
po_chanLabels = { 'POz', 'PO3', 'PO4'};
o_chanLabels = { 'Oz', 'O1', 'O2'};


cd D:\EEG_2022\mapEpochs_delay_corr_rej_80_3_10;
allfilesEpochs = dir('*epochAutorej.set');

    %load EEG dataset
    loadName = allfilesEpochs(1).name;
     EEG = pop_loadset('filename',loadName);

        front_chanIndex = zeros(1, length(front_chanLabels));
    for chan_nr = 1:length(front_chanLabels)
        chan = front_chanLabels(chan_nr);
        chanIndex = find(strcmp({EEG.chanlocs.labels}, chan));
        front_chanIndex(chan_nr) =   chanIndex;
    end
            fc_chanIndex = zeros(1, length(fc_chanLabels));
    for chan_nr = 1:length(fc_chanLabels)
        chan = fc_chanLabels(chan_nr);
        chanIndex = find(strcmp({EEG.chanlocs.labels}, chan));
        fc_chanIndex(chan_nr) =   chanIndex;
    end
        pariet_chanIndex = zeros(1, length(pariet_chanLabels));
    for chan_nr = 1:length(pariet_chanLabels)
        chan = pariet_chanLabels(chan_nr);
        chanIndex = find(strcmp({EEG.chanlocs.labels}, chan));
        pariet_chanIndex(chan_nr) = chanIndex;
    end
    
            po_chanIndex = zeros(1, length(po_chanLabels));
    for chan_nr = 1:length(po_chanLabels)
        chan = po_chanLabels(chan_nr);
        chanIndex = find(strcmp({EEG.chanlocs.labels}, chan));
        po_chanIndex(chan_nr) = chanIndex;
    end

             o_chanIndex = zeros(1, length(o_chanLabels));
    for chan_nr = 1:length(o_chanLabels)
        chan = o_chanLabels(chan_nr);
        chanIndex = find(strcmp({EEG.chanlocs.labels}, chan));
        o_chanIndex(chan_nr) = chanIndex;
    end
    
 %% extract power
figure;
% create a list of regions of interest
all_chanIndex = {[front_chanIndex], [fc_chanIndex], [pariet_chanIndex], [po_chanIndex], [o_chanIndex]};

% create an empty struct with pre-defined fields
fields = {'F', 'FC', 'P', 'PO', 'O'};
c = cell(length(fields),1);
power = cell2struct(c,fields);

% create an empty table

tablePath = 'D:\EEG_2022\Epoch_FrequencyPower\mapEvent\';
power_table = table;
%length(allfilesEpochs)  
for n=1:length(allfilesEpochs) 
     loadName = allfilesEpochs(n).name;
     EEG = pop_loadset('filename',loadName);
     
     partID=loadName(5:6);
     cityName = loadName(12);
     
     
     %loop through the regions of interest
     
     for chan_nr = 1:size(all_chanIndex, 2)
         chans = all_chanIndex{chan_nr};
        chan_label = fields{chan_nr}
        chans_data = EEG.data( chans, :, : );
        chans_data_mean = mean(chans_data,1);
    
        pos_baseline = find(EEG.times==0);
        %pos_end = find(EEG.times==2000);
        chans_data = chans_data_mean(:,pos_baseline:end,:);
        
      
         [spectra,freqs] = spectopo(chans_data, 0, EEG.srate, 'freqfac', 2, 'overlap', 0, 'freqrange', [1 30]); % 50% overlap: 'overlap', 125
        

        % Set the following frequency bands: delta=1-4, theta=4-8, alpha=8-13, beta=13-30, gamma=30-80.
        deltaIdx = find(freqs>=1 & freqs<4);
        thetaIdx = find(freqs>=4 & freqs<8);
        alphaIdx = find(freqs>=8 & freqs<13);
         lowerAlphaIdx = find(freqs>=8 & freqs<10);
        upperAlphaIdx = find(freqs>=10 & freqs<13);
        betaIdx  = find(freqs>=13 & freqs<30);
     
%         delta_RP = mean(spectra(deltaIdx))/mean(spectra);
%         theta_RP = mean(spectra(thetaIdx))/mean(spectra);
%         alpha_RP = mean(spectra(alphaIdx))/mean(spectra);
%         upperAlpha_RP = mean(spectra(upperAlphaIdx))/mean(spectra);
%         beta_RP = mean(spectra(betaIdx))/mean(spectra);
%     
%         deltaPower_RP = 10^(delta_RP/10); 
%         thetaPower_RP = 10^(theta_RP/10); 
%         alphaPower_RP = 10^(alpha_RP/10); 
%         upperAlphaPower_RP = 10^(upperAlpha_RP/10); 
%         betaPower_RP  = 10^(beta_RP/10); 
        
        
%         % Compute absolute power. -> corrected on the website
        deltaPower = 10^(mean(spectra(deltaIdx))/10); 
        thetaPower = 10^(mean(spectra(thetaIdx))/10); 
        alphaPower = 10^(mean(spectra(alphaIdx))/10); 
        lowerAlphaPower = 10^(mean(spectra(lowerAlphaIdx))/10); 
        upperAlphaPower = 10^(mean(spectra(upperAlphaIdx))/10); 
        betaPower  = 10^(mean(spectra(alphaIdx))/10); 



%           % Compute absolute power.
%         deltaPower = mean(10.^(spectra(deltaIdx)/10));
%         thetaPower = mean(10.^(spectra(thetaIdx)/10));
%         alphaPower = mean(10.^(spectra(alphaIdx)/10));
%         upperAlphaPower = mean(10.^(spectra(upperAlphaIdx)/10));
%         betaPower  = mean(10.^(spectra(betaIdx)/10));
% %         
%         %write to table for stats in R: LLM
        tempt = table({partID}, {cityName}, {chan_label}, deltaPower, thetaPower, alphaPower, betaPower, lowerAlphaPower, upperAlphaPower,...
        'VariableNames',{'partID', 'city_nr', 'channel', 'delta','theta', 'alpha', 'beta', 'lowerAlpha','upperAlpha'});
       
%       tempt = table({partID}, {cityName}, {chan_label}, deltaPower_RP, thetaPower_RP, alphaPower_RP, betaPower_RP, upperAlphaPower_RP,...
%         'VariableNames',{'partID', 'city_nr', 'channel', 'delta','theta', 'alpha', 'beta', 'upperAlpha'});

    
        power_table = [power_table;tempt]; 
        
        
        %write sepct to struct for plotting
        if chan_nr == 1
            power.F(n,:) =spectra;
        elseif chan_nr == 2
            power.FC(n,:) =spectra;
        elseif chan_nr ==3
            power.P(n,:) =spectra;
        elseif chan_nr ==4
            power.PO(n,:) =spectra;
        elseif chan_nr ==5
            power.O(n,:) =spectra;
        end

    
     end
end

writetable(power_table,[tablePath 'mapEvent_freq_power_clusteredChann_newFreqband_nooverlap_1Hz.csv'],'Delimiter',',');

%% plotting spectrum data

%append landmark condition information in the end column
mapLMs = readtable('D:\EEG_2022\scripts\City_LMsForMatlab.txt');
mapLMs = table2array(mapLMs);
mapLMs(mapLMs(:,:,:)== 72, :, :)= [];  % remove part 72
power.FC = [power.FC mapLMs(:,3)] ;
power.P = [power.P mapLMs(:,3)] ;
power.PO = [power.PO mapLMs(:,3)] ;
power.O = [power.O mapLMs(:,3)] ;

frontal_all_3LM =  power.FC(power.FC(:,end) == 3,:);
frontal_all_5LM =  power.FC(power.FC(:,end) == 5,:);
frontal_all_7LM =  power.FC(power.FC(:,end) == 7,:);

frontal_all_3LM_mean = mean(frontal_all_3LM,1);
frontal_all_5LM_mean = mean(frontal_all_5LM,1);
frontal_all_7LM_mean = mean(frontal_all_7LM,1);

pariet_all_3LM =  power.P(power.P(:,end) == 3,:);
pariet_all_5LM =  power.P(power.P(:,end) == 5,:);
pariet_all_7LM =  power.P(power.P(:,end) == 7,:);

pariet_all_3LM_mean = mean(pariet_all_3LM,1);
pariet_all_5LM_mean = mean(pariet_all_5LM,1);
pariet_all_7LM_mean = mean(pariet_all_7LM,1);

po_all_3LM =  power.PO(power.PO(:,end) == 3,:);
po_all_5LM =  power.PO(power.PO(:,end) == 5,:);
po_all_7LM =  power.PO(power.PO(:,end) == 7,:);

po_all_3LM_mean = mean(po_all_3LM,1);
po_all_5LM_mean = mean(po_all_5LM,1);
po_all_7LM_mean = mean(po_all_7LM,1);


o_all_3LM =  power.O(power.O(:,end) == 3,:);
o_all_5LM =  power.O(power.O(:,end) == 5,:);
o_all_7LM =  power.O(power.O(:,end) == 7,:);

o_all_3LM_mean = mean(o_all_3LM,1);
o_all_5LM_mean = mean(o_all_5LM,1);
o_all_7LM_mean = mean(o_all_7LM,1);


%% plot scalp topography in paper
%load EEG data.
%calculate spectra
%put spectra in an matrix
%add conditions
%plot topography
clear all;
eeglab;

mapLMs = readtable('D:\EEG_2022\scripts\City_LMsForMatlab.txt');
mapLMs = table2array(mapLMs);
mapLMs(mapLMs(:,:,:)== 72, :, :)= [];  % remove part 72
F_theta= [9:16];%theta
F_alpha = [17:26];

fields = {'LM3', 'LM5', 'LM7'};
c = cell(length(fields),1);
theta_all = cell2struct(c,fields);
alpha_all = cell2struct(c,fields);

%baseline


fields = {'alpha', 'theta'};
c = cell(length(fields),1);
bsl_spectra = cell2struct(c,fields);



cd D:\EEG_2022\bsl_pre_exp_epoch_rej80_3_10;
allfilesEpochs = dir('*Autorej.set');
for n=1:10
     loadName = allfilesEpochs(n).name;
     EEG = pop_loadset('filename',loadName);
     
     partID=loadName(5:6);
     cityName = loadName(12);
       pos_baseline = find(EEG.times==0);
     [spectra,freqs] = spectopo(EEG.data(:,pos_baseline:end,:), 0, EEG.srate, 'freqfac', 2, 'overlap', 0, 'freqrange', [1 30]); % 50% overlap: 'overlap', 125
     
     
            %write sepct to struct for plotting
            %relative power
            rel_theta= mean(spectra(:, F_theta), 2)./mean(spectra(:, :),2);
            rel_alpha= mean(spectra(:, F_alpha), 2)./mean(spectra(:, :),2);
       
            bsl_spectra.theta=[bsl_spectra.theta rel_theta];
             bsl_spectra.alpha=[bsl_spectra.alpha rel_alpha];
        
end



cd D:\EEG_2022\mapEpochs_delay_corr_rej_80_3_10;
allfilesEpochs = dir('*epochAutorej.set');
%length(allfilesEpochs) 
for n=1:10
     loadName = allfilesEpochs(n).name;
     EEG = pop_loadset('filename',loadName);
     
     partID=loadName(5:6);
     cityName = loadName(12);
       pos_baseline = find(EEG.times==0);
     [spectra,freqs] = spectopo(EEG.data(:,pos_baseline:end,:), 0, EEG.srate, 'freqfac', 2, 'overlap', 0, 'freqrange', [1 30]); % 50% overlap: 'overlap', 125
     
     
            %write sepct to struct for plotting
            %relative power
            rel_theta= mean(spectra(:, F_theta), 2)./mean(spectra(:, :),2);
            rel_alpha= mean(spectra(:, F_alpha), 2)./mean(spectra(:, :),2);
        if mapLMs(n,3) == 3
            theta_all.LM3=[theta_all.LM3 rel_theta];
            alpha_all.LM3=[alpha_all.LM3 rel_alpha];
        elseif mapLMs(n,3) == 5
            theta_all.LM5=[theta_all.LM5 rel_theta];
            alpha_all.LM5=[alpha_all.LM5 rel_alpha];
        elseif mapLMs(n,3) == 7
              theta_all.LM7=[theta_all.LM7 rel_theta];
              alpha_all.LM7=[alpha_all.LM7 rel_alpha];
        end
        
        
end

bsl_corr_3 = (mean(theta_all.LM3,2) - mean(bsl_spectra.theta,2))./ mean(bsl_spectra.theta,2);
bsl_corr_5 = (mean(theta_all.LM5,2) - mean(bsl_spectra.theta,2))./ mean(bsl_spectra.theta,2);


bsl_corr_5 = (mean(alpha_all.LM5,2) - mean(bsl_spectra.alpha,2))./ mean(bsl_spectra.alpha,2);


figure;
topoplot(mean(bsl_corr_5,2), EEG.chanlocs)

figure;
topoplot(mean(theta_all.LM5,2), EEG.chanlocs)

figure;
topoplot(mean(theta_all.LM7,2), EEG.chanlocs)

figure;
topoplot(mean(alpha_all.LM3,2), EEG.chanlocs)

figure;
topoplot(mean(alpha_all.LM5,2), EEG.chanlocs)

figure;
topoplot(mean(alpha_all.LM7,2), EEG.chanlocs)


figure;
topoplot(alpha, EEG.chanlocs)

figure; pop_spectopo(EEG, 1, [0  4996], 'EEG' , 'percent', 50, 'freq', [6 10], 'freqrange',[2 25],'electrodes','off');

figure;
plot(freqs(1:30), o_all_3LM_mean(1, 1:30), 'g');
hold on;


    plot(freqs(1:30), o_all_5LM_mean(1, 1:30), 'r');
    hold on;


    plot(freqs(1:30), o_all_7LM_mean(1, 1:30), 'b');
  


legend('3LM','5LM', '7LM');

%% plot ERSP
%get indices of LM conditions.
% create a list of regions of interest
all_chanIndex = {[front_chanIndex], [pariet_chanIndex], [po_chanIndex], [o_chanIndex]};

% create an empty struct with pre-defined fields
fields = {'FC', 'P', 'PO', 'O'};
c = cell(length(fields),1);
EEG_3LM = cell2struct(c,fields);
EEG_5LM = cell2struct(c,fields);
EEG_7LM = cell2struct(c,fields);

mapLMs = readtable('D:\EEG_2022\scripts\City_LMsForMatlab.txt');
mapLMs = table2array(mapLMs);
mapLMs(mapLMs(:,:,:)== 72, :, :)= [];  % remove part 72

LM3_idx = find(mapLMs(:,3) == 3);
LM5_idx = find(mapLMs(:,3) == 5);
LM7_idx = find(mapLMs(:,3) == 7);

%categorize the data into three conditions
cd D:\EEG_2022\mapEpochs_delay_corr_rej_80_3_10;
allfilesEpochs = dir('*epochAutorej.set');

% EEG_3LM = [];
% EEG_5LM = [];
% EEG_7LM = [];

for n=1:length(allfilesEpochs)
     loadName = allfilesEpochs(n).name;
     EEG = pop_loadset('filename',loadName);
     
  for chan_nr = 1:size(all_chanIndex, 2)
         chans = all_chanIndex{chan_nr};
        chan_label = fields{chan_nr}
        chans_data = EEG.data( chans, :, : );
        chans_data_mean = mean(chans_data,1);
     
        if ismember(n, LM3_idx)
             if chan_nr ==1
                EEG_3LM.FC = cat(3, EEG_3LM.FC, chans_data_mean);
            elseif chan_nr ==2
                EEG_3LM.P =cat(3, EEG_3LM.P, chans_data_mean);
            elseif chan_nr ==3
                EEG_3LM.PO =cat(3, EEG_3LM.PO, chans_data_mean);
             else
                EEG_3LM.O =cat(3, EEG_3LM.O, chans_data_mean);
             end
             
        elseif ismember(n, LM5_idx)
             if chan_nr ==1
                EEG_5LM.FC = cat(3, EEG_5LM.FC, chans_data_mean);
            elseif chan_nr ==2
                EEG_5LM.P =cat(3, EEG_5LM.P, chans_data_mean);
            elseif chan_nr ==3
                EEG_5LM.PO =cat(3, EEG_5LM.PO, chans_data_mean);
             else
                EEG_5LM.O =cat(3, EEG_5LM.O, chans_data_mean);
             end
        elseif ismember(n, LM7_idx)
             if chan_nr ==1
                EEG_7LM.FC = cat(3, EEG_7LM.FC, chans_data_mean);
            elseif chan_nr ==2
                EEG_7LM.P =cat(3, EEG_7LM.P, chans_data_mean);
            elseif chan_nr ==3
                EEG_7LM.PO =cat(3, EEG_7LM.PO, chans_data_mean);
             else
                EEG_7LM.O =cat(3, EEG_7LM.O, chans_data_mean);
             end
        end
    
     
%              if chan_nr ==1
%             EEG_3LM.FC(n,:) =cat(3, EEG_3LM, chans_data_mean);
%         elseif chan_nr ==2
%             EEG_3LM.P(n,:) =cat(3, EEG_3LM, chans_data_mean);
%         elseif chan_nr ==3
%             EEG_3LM.PO(n,:) =cat(3, EEG_3LM, chans_data_mean);
%         else
%             EEG_3LM.O(n,:) =cat(3, EEG_3LM, chans_data_mean);
%              end
        
  end

end

figure;
[ersp_3,~,powbase, times,freqs_3]=newtimef(EEG_3LM.O ,EEG.pnts,[EEG.xmin EEG.xmax]*1000, EEG.srate, 0, 'freqs', [3 30], 'plotitc' , 'off', 'title', '3LM O', 'erspmax' , 2);

figure;
[ersp_5,~,powbase, times,freqs_5]=newtimef(EEG_5LM.O ,EEG.pnts,[EEG.xmin EEG.xmax]*1000, EEG.srate, 0, 'freqs', [3 30], 'plotitc' , 'off', 'title', '5LM O', 'erspmax' , 2);

figure;
[ersp_7,~,powbase, times,freqs_7]=newtimef(EEG_7LM.O ,EEG.pnts,[EEG.xmin EEG.xmax]*1000, EEG.srate, 0, 'freqs', [3 30], 'plotitc' , 'off', 'title', '7LM O', 'erspmax' , 2);


%% use matlab function spectrogram to plot
s = spectrogram(EEG_mean);

spectrogram(EEG_mean,250);
