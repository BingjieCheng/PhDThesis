%This script searches for and places blink event markers based on
%participants' vEOG ICA component in the preprocessed_and_ICA dataset using a pre-defined set of parameters
%(see pb_struct_script and Inverse_prctile_thresholds). It first applies a
%highpass filter of 0.5 Hz, searches for blinks, and then place event
%markers on the dataset
%04/03/22

%% Filtering between 0.5-30 Hz and then doing blink detection
pb = [];

%pb28
pb(28).vEOG = [3];
pb(28).hEOG = [2];

%pb29
pb(29).vEOG = [1];
pb(29).hEOG = [2];

%pb30
pb(30).vEOG = [1];
pb(30).hEOG = [2];

%pb31
pb(31).vEOG = [1];
pb(31).hEOG = [2];

%pb32
pb(32).vEOG = [1];
pb(32).hEOG = [2];

%pb33
pb(33).vEOG = [1];
pb(33).hEOG = [2];

%pb34
pb(34).vEOG = [1];
pb(34).hEOG = [2];

%pb35
pb(35).vEOG = [1];
pb(35).hEOG = [2];

%pb36
pb(36).vEOG = [1];
pb(36).hEOG = [2];

%pb37
pb(37).vEOG = [1];
pb(37).hEOG = [2];

%pb38
pb(38).vEOG = [1];
pb(38).hEOG = [2];

%pb39
pb(39).vEOG = [1];
pb(39).hEOG = [2];

%pb40
pb(40).vEOG = [1];
pb(40).hEOG = [2];

%pb41
pb(41).vEOG = [1];
pb(41).hEOG = [2];

%pb42
pb(42).vEOG = [1];
pb(42).hEOG = [2];

%pb43
pb(43).vEOG = [1];
pb(43).hEOG = [2];

%pb44
pb(44).vEOG = [1];
pb(44).hEOG = [4];

%pb45
pb(45).vEOG = [1];
pb(45).hEOG = [3];

%pb46
pb(46).vEOG = [1];
pb(46).hEOG = [2];

%pb47
pb(47).vEOG = [1];
pb(47).hEOG = [2];

%pb48
pb(48).vEOG = [1];
pb(48).hEOG = [2];

%pb49
pb(49).vEOG = [1];
pb(49).hEOG = [2];

%pb50
pb(50).vEOG = [1];
pb(50).hEOG = [2];

%pb51     %Only has data for City 1
pb(51).vEOG = [1];
pb(51).hEOG = [2];

%pb52
pb(52).vEOG = [1];
pb(52).hEOG = [2];

%pb53
pb(53).vEOG = [1];
pb(53).hEOG = [2];

%pb54
pb(54).vEOG = [1];
pb(54).hEOG = [2];

%pb55 missing data/excluded

%pb56
pb(56).vEOG = [1];
pb(56).hEOG = [2];

%pb57
pb(57).vEOG = [2];
pb(57).hEOG = [1];

%pb58
pb(58).vEOG = [1];
pb(58).hEOG = [2];

%pb59
pb(59).vEOG = [1];
pb(59).hEOG = [2];

%pb60
pb(60).vEOG = [1];
pb(60).hEOG = [2];

%pb61
pb(61).vEOG = [1];
pb(61).hEOG = [3];

%pb62
pb(62).vEOG = [1];
pb(62).hEOG = [2];

%pb63
pb(63).vEOG = [1];
pb(63).hEOG = [2];

%pb64
pb(64).vEOG = [1];
pb(64).hEOG = [2];

%pb65
pb(65).vEOG = [1];
pb(65).hEOG = [2];

%pb66
pb(66).vEOG = [1];
pb(66).hEOG = [2];

%pb67
pb(67).vEOG = [1];
pb(67).hEOG = [2];

%pb68
pb(68).vEOG = [2 3];       %This participant has two vEOG components
pb(68).hEOG = [1];

%pb69
pb(69).vEOG = [1];   %Did 7-landmark condition twice and did not do 3-landmark condition
pb(69).hEOG = [2];

%pb70
pb(70).vEOG = [1];
pb(70).hEOG = [2];

%pb71
pb(71).vEOG = [1];
pb(71).hEOG = [2];

%pb72                %exclude? Excluded in ERP and ERSP analyses. Exclude
pb(72).vEOG = [1];
pb(72).hEOG = [2];

%pb73
pb(73).vEOG = [1];
pb(73).hEOG = [2];

%pb74
pb(74).vEOG = [1];
pb(74).hEOG = [2];

%pb75
pb(75).vEOG = [1];
pb(75).hEOG = [2];

%pb76
pb(76).vEOG = [1];
pb(76).hEOG = [2];

eeglab

blinkEvts = [];               %array that stores the number of events for each participant
n = 1; %index for output array

% initialize and define subject-general parameters for blink detection
MinPeakDistance = 25;                                     %Anna's
% value
%MinPeakDistance = 250;
%MinPeakWidth = 5;                                          %Anna's
%value
MinPeakWidth = 5;        
MaxPeakWidth = 65;

%First set the directory to the folder where the files are stored
cd 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis'
pathName = 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\sub-';
    
for subjectIdx = [28:54 56:76]
    
    for condIdx = 1:3
        ALLEEG = []; EEG = [];
        blinkLocs =[];
        blinkPks = [];
        
        EEG = pop_loadset('filename', [num2str(subjectIdx), '_City', num2str(condIdx), '_Map.set'], 'filepath', [pathName, num2str(subjectIdx)]);    %First condition
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0);
        
        %Applying a highpass filter of 0.5 Hz and recalculating the ICA
        %activation components
        EEG = pop_eegfiltnew(EEG, 'locutoff',0.5);
        EEG = pop_eegfiltnew(EEG, 'hicutoff',30);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off');
        EEG.icaact = [];
        EEG = eeg_checkset( EEG );
        eeglab redraw;
        
        %Flip negative values of 3rd IC component of sub 68 into positive
        if subjectIdx == 68
            EEG.icaact(pb(subjectIdx).vEOG(2),:) = EEG.icaact(pb(subjectIdx).vEOG(2),:)*(-1);
        end
        
        smoothICvEOG = smoothdata(EEG.icaact(pb(subjectIdx).vEOG,:),'movmedian',20);
        %pb(subjectIdx).smoothedICvEOG = smoothICvEOG;              %Uncomment these two lines to run analysis on vEOG ICA histogram
        
        if subjectIdx == 68
            smoothICvEOG = mean(smoothICvEOG);    %taking composite of both vEOG components for sub 68
        end
        %blink detection using moving median and first derivative
        % initialize and define subject-dependent parameters for blink detection
        % MinPeakProminence = double(prctile(smoothICvEOG,90));     %Anna's
        % value
        MinPeakProminence = double(prctile(smoothICvEOG,97));
        % thresholdBlinks = double(prctile(smoothICvEOG,85));       %Anna's
        % value
        thresholdBlinks = double(prctile(smoothICvEOG,96));
        %MinPeakWidth = 5;                                          %Anna's
        %value
        %MaxPeakWidth = 80;                                         %Anna's
        %value gave a lot of false positives
        % find peaks in the smoothed vertical EOG
        [blinkPks,blinkLocs] = findpeaks(smoothICvEOG,'MinPeakProminence',MinPeakProminence,'MinPeakDistance',MinPeakDistance,'MinPeakHeight',thresholdBlinks, 'MinPeakWidth',MinPeakWidth,'MaxPeakWidth',MaxPeakWidth, 'WidthReference', 'halfheight');    %Using half heigh instead of half prominence as reference
        %[blinkPks,blinkLocs] = findpeaks(smoothICvEOG,'MinPeakProminence',MinPeakProminence,'MinPeakDistance',MinPeakDistance,'MinPeakHeight',thresholdBlinks);   % tried without defining widths but it gave more false positives and marked noise as blinks
        
        event_latencies = blinkLocs;
        
        for latency = event_latencies
            i = numel(EEG.event) + 1;
            EEG.event(i).type = 'blink';
            EEG.event(i).latency = latency;
            EEG.event(i).duration = 1/EEG.srate;
        end
        
        EEG = eeg_checkset(EEG, 'eventconsistency');
        eeglab redraw
        
        %Check blink detection
        %EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
        
        %eegplot(EEG.icaact(1:5,:),'srate', EEG.srate,'spacing', 50 ,'eloc_file', 1:5,'winlength',35,'title',[num2str(subjectIdx), 'City ', num2str(condIdx)],'events', EEG.event)
        
        EEG = pop_saveset( EEG, 'filename',[num2str(subjectIdx), '_City', num2str(condIdx), '_Maps_0.5_30_blinkDetected4.set'],'filepath', [pathName, num2str(subjectIdx)]); 
        [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        blinkEvts(n, 1) = subjectIdx;
        blinkEvts(n, condIdx+1) = length(blinkLocs);
    end
    
    n = n + 1;
end

%% check blink and saccade detection
% cd 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis'
% pathName = 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\sub-';
% 
% for subjectIdx = [28:54 56:71 73:76]
%     
%     ALLEEG = []; EEG = [];
%     EEG = pop_loadset('filename', [num2str(subjectIdx), '_Merged datasets resampled_0.5highP_blinkDetected.set'], 'filepath', [pathName, num2str(subjectIdx)]);
%     [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
% 
%     EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
% 
%     eegplot(EEG.icaact(1:5,:),'srate', EEG.srate,'spacing', 50 ,'eloc_file', 1:5,'winlength',25,'title',num2str(subjectIdx),'events', EEG.event)
% end

%% EEG clean with IClable cleaning

eeglab; 
classes_to_keep = [1];
threshold_to_keep = 0.30;

cd 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis'
pathName = 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\sub-';

for subjectIdx = 29%[28:50 52:54 56:71 73:76]
    
    for condIdx = 1:3
        ALLEEG = []; EEG = [];
        EEG = pop_loadset('filename', [num2str(subjectIdx), '_City', num2str(condIdx), '_Maps_0.5_30_blinkDetected4.set'],'filepath', [pathName, num2str(subjectIdx)]);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        
        %datapath_save_figures = [pathName, num2str(subjectIdx), 'ICclean0.5_30'];
        
        % source-based cleaning using IClabel
        [EEG_clean,ic_classification] = bemobil_clean_with_iclabel(EEG, ALLEEG, CURRENTSET, 'lite', classes_to_keep, threshold_to_keep, [num2str(subjectIdx), '_City', num2str(condIdx), 'ICclean30'], [pathName, num2str(subjectIdx)]);
        numberGoodICs(subjectIdx) = size(EEG_clean(2).icaact,1);
        
        %EEG = pop_saveset( EEG_clean, 'filename', [num2str(subjectIdx), '_City', num2str(condIdx), 'noEyeIC30default_blinkEvents.set'],'filepath',[pathName, num2str(subjectIdx)]);
    end
end