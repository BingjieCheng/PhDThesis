%This script reads each participant's ICA component activations and smooths
%the vEOG component and puts it into each participant's structure. Then it
%calculates the mean vEOG component at each time point and plots a
%histogram of the average VEOG values. The histogram of each participant is
%then inspected by eye to determine an appropriate value than can be used as a threshold level for peak height detection. These values are than entered into a table called "Pb_thresh_values" for use in the next step. 
%Created by Enru Lin 22/02/22

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

%pb51
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
pb(68).vEOG = [2];
pb(68).hEOG = [1];

%pb69
pb(69).vEOG = [1];
pb(69).hEOG = [2];

%pb70
pb(70).vEOG = [1];
pb(70).hEOG = [2];

%pb71
pb(71).vEOG = [1];
pb(71).hEOG = [2];

%pb72                %exclude? Excluded in ERP and ERSP analyses
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
%cd 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data'
cd 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis'
%pathName = 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\sub-';



timePts = [];               %array that stores the number of data points for each participant
n = 1; %index for output array

for subjectIdx = [28:54 56:76]
    ALLEEG = []; EEG = [];
    %EEG = pop_loadset('filename', ['sub-', num2str(subjectIdx), '_dipfitted.set'], 'filepath', [pathName, num2str(subjectIdx)]);
    cd 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis'
    pathName = 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\sub-';
    EEG = pop_loadset('filename', ['sub-', num2str(subjectIdx), '_preprocessed_and_ICA.set'], 'filepath', [pathName, num2str(subjectIdx)]);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    copyEvents = EEG.event;
    
    smoothICvEOG = smoothdata(EEG.icaact(pb(subjectIdx).vEOG,:),'movmedian',20);
    %pb(subjectIdx).smoothedICvEOG = smoothICvEOG;              %Uncomment these two lines to run analysis on vEOG ICA histogram
    %timePts(n, 1) = length(smoothICvEOG);
    
    %blink detection using moving median and first derivative 
    % initialize and define all parameters for blink detection
    blinkLocs =[];
    blinkPks = [];
    MinPeakDistance = 25;                                     %Anna's
    % value
    %MinPeakDistance = 250;
    % MinPeakProminence = double(prctile(smoothICvEOG,90));     %Anna's
    % value
    MinPeakProminence = double(prctile(smoothICvEOG,99));
    % thresholdBlinks = double(prctile(smoothICvEOG,85));       %Anna's
    % value
    thresholdBlinks = double(prctile(smoothICvEOG,96));
    %MinPeakWidth = 5;                                          %Anna's
    %value
    MinPeakWidth = double(prctile(smoothICvEOG,96))*0.5;
    MaxPeakWidth = MinPeakWidth+50;
    %MaxPeakWidth = 80;                                         %Anna's
    %value
    % find peaks in the smoothed vertical EOG 
    [blinkPks,blinkLocs] = findpeaks(smoothICvEOG,'MinPeakProminence',MinPeakProminence,'MinPeakDistance',MinPeakDistance,'MinPeakHeight',thresholdBlinks, 'MinPeakWidth',MinPeakWidth,'MaxPeakWidth',MaxPeakWidth);
    
    event_latencies = blinkLocs;
        
    for latency = event_latencies
        i = numel(EEG.event) + 1;
        EEG.event(i).type = 'blink';
        EEG.event(i).latency = latency;
        EEG.event(i).duration = 1/EEG.srate;
    end

    EEG = eeg_checkset(EEG, 'eventconsistency');
    eeglab redraw
    % plot the component activation
    figure(subjectIdx);
    pop_eegplot( EEG, 0, 1, 1);
    
    %figure(subjectIdx);                    %Uncomment these two lines to plot each subject's histogram
    %histogram(smoothICvEOG);
    
    n = n + 1;
end

%max number of data points in the sample is 1280180
%For each subject, pad their data points with NaN if they have fewer than
%1280180 data points

%And then put the smoothed vEOG vector of all participants into a separate
%array to facilitate averaging while ignoring NaN values

smoothvEOG_subs = [];              %array to place all subjects' smoothed vEOG ICs to plot histogram
p = 1;                             %counter for array

for subjectIdx = [28:54 56:76]
    if length(pb(subjectIdx).smoothedICvEOG) < max(timePts)
        pb(subjectIdx).smoothedICvEOG(1, end+1:max(timePts)) = NaN;
    end
    
    smoothvEOG_subs(p, :) = pb(subjectIdx).smoothedICvEOG;
    
    p = p + 1;
end

ave_Pb = mean(smoothvEOG_subs, 'omitnan');
histogram(ave_Pb);

%Then run the Inverse_prctile_thresholds script to determine which
%percentile value to use for threshold of blinks