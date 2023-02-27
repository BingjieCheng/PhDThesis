%This script epochs blink-related events from -0.5 to 2 s (no unfolding) and conducts frequency analysis on the epoched data using the spectopo function on EEGLab.
%Created 06.05.2022


                  %frontal     %parietal    %parOcc  %occipital
all_chanIndex = {[65, 7, 29], [13, 44, 52], [47:49], [17:18]}; 
fields = {'FC', 'P', 'PO', 'O'};
c = cell(length(fields), 1);
%power = cell2struct(c,fields);

% create an empty table

tablePath = 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis';
power_table = table;

eeglab
cd 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis'
pathName = 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\sub-';

p = 1;  %sub counter
for subjectIdx = [28:50 52:54 56:68 70:71 73:76]
    ALLEEG = []; EEG = []; temp_epochs = []; 
    EEG = pop_loadset('filename', [num2str(subjectIdx), '_Merged_IC30_0.5_30_wConds_Nav_new.set'],'filepath', [pathName, num2str(subjectIdx)]);
    EEG = eeg_checkset( EEG );
    %Extracting epochs around blink events from -0.5 to 2s
    EEG = pop_epoch( EEG, {  'blink'  }, [-0.5           2], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');
    % Removing baseline from -500 to -200 ms, similar to bERP
    EEG = pop_rmbase( EEG, [-500 -200] ,[]);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');
    
    NonBlks = [];
    n = 1;  %counter for non-blink events
    
    % Removing non-blink events
    for evIdx = 1:length(EEG.event)
        if ~contains(EEG.event(evIdx).type, 'blink') 
            NonBlks(n, 1) = evIdx;
            n = n + 1;
        end
    end
    EEG.event(NonBlks(:, 1)) = [];
    % Removing extra blinks within an epoch
    % First taking all rows of EEG.event.epoch and putting into a temp array for
    % manipulation
    temp_epochs = vertcat(EEG.event.epoch);
    
    % Getting indices of extra events within each epoch for removal 
    [~, ia] = unique(temp_epochs);
    EEG.event = EEG.event(ia);
    
    % Auto-rejecting bad epochs
    [EEG, rmepochs] = pop_autorej(EEG, 'threshold', 80, 'startprob', 3, 'maxrej', 10, 'eegplot', 'off', 'nogui', 'on');  %5 iterations
    EEG.rmepochs = rmepochs; %save removed epochs in EEG dataset
    EEG = eeg_checkset(EEG);
    
    conds = [3 5 7];
    
    for condIdx = 1:length(conds)
    %Separating blinks by condition
    ldmrkIdx = find(vertcat(EEG.event.eventtype)==conds(condIdx));
    LdMrkEEG = EEG.data(:, :, ldmrkIdx); 
      
    for chan_nr = 1:size(all_chanIndex, 2)
        chans = all_chanIndex{chan_nr};
        chan_label = fields{chan_nr};
        
        mean_chans = mean(LdMrkEEG( chans, :, : ), 1);
        
        [spectra, freqs] = spectopo(mean_chans(:, find(EEG.times==0):end, :), 0, EEG.srate, 'freqfac', 2, 'overlap', 0, 'freqrange', [1 30]);
        %[spectra, freqs] = spectopo(mean_chans(:, find(EEG.times==200):end, :), 0, EEG.srate, 'freqfac', 2, 'overlap', 0, 'freqrange', [1 30]);  %freq spectrum from 200-2000 ms with no overlapping window and 0.5 freq resolution
        %[spectra, freqs] = spectopo(mean_chans(:, find(EEG.times==200):end, :), 0, EEG.srate, 'freqfac', 2, 'overlap', 125, 'freqrange', [1 30]);  %freq spectrum from 200-2000 ms with 50% overlapping window and 0.5 freq resolution
        
        % Set the following frequency bands: delta=1-4, theta=4-8, alpha=8-13, beta=13-30, gamma=30-80.
        deltaIdx = find(freqs>=1 & freqs<4);     
        thetaIdx = find(freqs>=4 & freqs<8);       
        alphaIdx = find(freqs>=8 & freqs<13);        
        upperAlphaIdx = find(freqs>=10 & freqs<13);       
        betaIdx  = find(freqs>=13 & freqs<30);
        
        % Compute absolute power.
        deltaPower = 10^(mean(spectra(deltaIdx))/10); 
        thetaPower = 10^(mean(spectra(thetaIdx))/10);       
        alphaPower = 10^(mean(spectra(alphaIdx))/10);       
        upperAlphaPower = 10^(mean(spectra(upperAlphaIdx))/10);       
        betaPower  = 10^(mean(spectra(betaIdx))/10);
        
        
        %write to table for stats in R: LLM
        tempt = table({subjectIdx}, {chan_label}, conds(condIdx), deltaPower, thetaPower, alphaPower, betaPower, upperAlphaPower,...
        'VariableNames',{'partID', 'channel', 'map_LMs', 'delta', 'theta', 'alpha', 'beta', 'upperAlpha'});
        
        %For sub 51, who has data for only the 3-landmark condition
%         tempt = table({subjectIdx}, {chan_label}, delta3Power, theta3Power, alpha3Power, beta3Power, upperAlpha3Power,...
%         'VariableNames',{'subID', 'channel', 'delta_3', 'theta_3', 'alpha_3', 'beta_3', 'upperAlpha_3'});

        %For sub 69, who has data for only the 5- and 7-landmark conditions
%          tempt = table({subjectIdx}, {chan_label}, delta5Power, delta7Power, theta5Power, theta7Power, alpha5Power, alpha7Power, beta5Power, beta7Power, upperAlpha5Power, upperAlpha7Power,...
%          'VariableNames',{'subID', 'channel', 'delta_5', 'delta_7', 'theta_5', 'theta_7', 'alpha_5', 'alpha_7', 'beta_5', 'beta_7', 'upperAlpha_5', 'upperAlpha_7'});
        
        power_table = [power_table;tempt];
        
        %write sepct to struct for plotting
        
%         if chan_nr ==1
%             power.FC_3(p,:) =spectra;
%             power.FC_5(p,:) =spectra_5;
%             power.FC_7(p,:) =spectra_7;
%         elseif chan_nr ==2
%             power.P_3(p,:) =spectra;
%             power.P_5(p,:) =spectra_5;
%             power.P_7(p,:) =spectra_7;
%         elseif chan_nr ==3
%             power.PO_3(p,:) =spectra;
%             power.PO_5(p,:) =spectra_5;
%             power.PO_7(p,:) =spectra_7;
%         else
%             power.O_3(p,:) =spectra;
%             power.O_5(p,:) =spectra_5;
%             power.O_7(p,:) =spectra_7;
%         end
    end
    end
    p = p+1;
end

writetable(power_table,[tablePath, '\navBlinks_freq_power_clustered_corrected_no_overlap_base_minus500_200.csv'],'Delimiter',',');