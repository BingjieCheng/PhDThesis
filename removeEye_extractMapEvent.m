%% After bemobile pipeline
%% remove eye component

clear all;
eeglab;

cd 'D:\EEG_2022\bemobil_preproc';
allfilesVR = dir('*ICA.set');

for n=1:length(allfilesVR) 
     
     loadName = allfilesVR(n).name;
     partID=loadName(5:6);
     EEG = pop_loadset('filename',loadName);
     
     EEG = iclabel(EEG, 'default');
    eye_prob = EEG.etc.ic_classification.ICLabel.classifications(:, 3);
    components_to_remove = find(eye_prob > 0.7)
    %components_to_remove = find(components_to_remove < 15)

    %OUTEEG = pop_subcomp( INEEG, components, confirm); 
    EEG = pop_subcomp( EEG, components_to_remove, 0); %0=do not ask. Default 0.
    
    dataName = ['sub-' partID '_eyeRemoved'];
    EEG = pop_saveset( EEG, 'filename',dataName, 'filepath', 'D:\EEG_2022\eyeRemoved');
     
end

%% high pass filter the continuous data

clear all;
eeglab;
cd 'D:\EEG_2022\eyeRemoved';

allfiles = dir('*.set');
for n=1:length(allfiles) 
    loadName = allfiles(n).name;
     
     EEG = pop_loadset('filename',loadName);
     
    %high pass filter makes difference on removing epochs
    EEG = pop_eegfiltnew(EEG, 'locutoff',0.5,'plotfreqz',1); %low cutoff: 0.5HZ
    EEG = pop_eegfiltnew(EEG, 'hicutoff',40,'plotfreqz',1); %high cutoff: 40HZ
    
    dataName = [loadName(1:end-4) '_filter.set']
    EEG = pop_saveset( EEG, 'filename',dataName, 'filepath', 'D:\EEG_2022\eyeRemoved_filter_0.5_40');
    
end


%% correct event delay

%133 ms delay, 250 is the sampling rate.
clear all;
clean all;
eeglab;

cd 'D:\EEG_2022\eyeRemoved_filter_0.5_40';
allfiles = dir('*.set');

lant_corr = round(0.133 *250);

for n=1:length(allfiles) 
    loadName = allfiles(n).name;
     
     EEG = pop_loadset('filename',loadName);
     
        %EEG.correvent = EEG.event;
        
        for j = 1:size(EEG.event,2)
            EEG.event(j).latency = EEG.event(j).latency + lant_corr;
        end

    
    dataName = [loadName(1:end-4) '_eventCorr.set']
    EEG = pop_saveset( EEG, 'filename',dataName, 'filepath', 'D:\EEG_2022\eyeRemoved_filter_0.5_40_eventCorr');
    
end




%% extract epochs
clear all;
eeglab;

cd D:\EEG_2022\eyeRemoved_filter_0.5_40_eventCorr;
allfilesVR = dir('*eventCorr.set');

% select navigation events per city
%!!!delete partID 51, city 2 

MapEventStrings1 = {'City 1 showMap'};
MapEventStrings2 = {'City 2 showMap'};
MapEventStrings3 = {'City 3 showMap'};

for n=1:length(allfilesVR) 
     
     loadName = allfilesVR(n).name;
     partID=loadName(5:6);
     EEG = pop_loadset('filename',loadName);
    
    city1Events = {};
    city2Events = {};
    city3Events = {};
    
    for j = 1:size(EEG.event,2)
        if contains(EEG.event(j).type, MapEventStrings1) 
            city1Events = [city1Events, {EEG.event(j).type}];
        elseif contains(EEG.event(j).type, MapEventStrings2) 
            city2Events = [city2Events, {EEG.event(j).type}];
        elseif contains(EEG.event(j).type, MapEventStrings3) 
            city3Events = [city3Events, {EEG.event(j).type}];
        else
            continue;
        end
        
    end
      
        
     EEG1 = EEG; 
     EEG2 = EEG; 
     EEG3 = EEG; 
     
    %City 1 epoching 
    dataName = [partID '_city1_mapEpochs'];
    EEG1 = pop_epoch( EEG1, city1Events, [-1  5], 'newname', dataName , 'epochinfo', 'yes'); %check city1Events

    %remove baseline
    EEG1 = pop_rmbase( EEG1, [-200 0] ,[]);
    
    dataName = ['sub-' partID '_city1_mapEpochs'];
    EEG1 = pop_saveset( EEG1, 'filename',dataName,'filepath', 'D:\EEG_2022\mapEpochs_delay_corr');


     
     %City 2 epoching
    
    dataName = [partID '_city2_mapEpochs'];
    EEG2 = pop_epoch( EEG2, city2Events, [-1  5], 'newname', dataName , 'epochinfo', 'yes');
   
    %remove baseline
    EEG2 = pop_rmbase( EEG2, [-200 0] ,[]);
    dataName = ['sub-' partID '_city2_mapEpochs'];
    EEG2 = pop_saveset( EEG2, 'filename',dataName,'filepath', 'D:\EEG_2022\mapEpochs_delay_corr');
    
    
    %City 3 epoching
    
    dataName = [partID '_city3_mapEpochs'];
    EEG3 = pop_epoch( EEG3, city3Events, [-1  5], 'newname', dataName , 'epochinfo', 'yes');
    
    %remove baseline
    EEG3 = pop_rmbase( EEG3, [-200 0] ,[]);
    dataName = ['sub-' partID '_city3_mapEpochs'];
    EEG3 = pop_saveset( EEG3, 'filename',dataName,'filepath', 'D:\EEG_2022\mapEpochs_delay_corr');
    
end   


%% extract walk(map offset) event for 5 seconds

cd 'E:\Berlin\2Hz_strictChanRemov_FCz\noDelay_Corr\eyeRemoved_highpassfilter';
allfilesVR = dir('*.set');

% select navigation events per city
%!!!delete partID 51, city 2 

MapEventStrings1 = {'City 1 hideMap'};
MapEventStrings2 = {'City 2 hideMap'};
MapEventStrings3 = {'City 3 hideMap'};

for n=1:length(allfilesVR) 
     
     loadName = allfilesVR(n).name;
     partID=loadName(5:6);
     EEG = pop_loadset('filename',loadName);
    
    city1Events = {};
    city2Events = {};
    city3Events = {};
    
    for j = 1:size(EEG.event,2)
        if contains(EEG.event(j).type, MapEventStrings1) 
            city1Events = [city1Events, {EEG.event(j).type}];
        elseif contains(EEG.event(j).type, MapEventStrings2) 
            city2Events = [city2Events, {EEG.event(j).type}];
        elseif contains(EEG.event(j).type, MapEventStrings3) 
            city3Events = [city3Events, {EEG.event(j).type}];
        else
            continue;
        end
        
    end
      
        
     EEG1 = EEG; 
     EEG2 = EEG; 
     EEG3 = EEG; 
     
    %City 1 epoching 
    dataName = [partID '_city1_mapOffEpochs'];
    EEG1 = pop_epoch( EEG1, city1Events, [-1  5], 'newname', dataName , 'epochinfo', 'yes'); %check city1Events

    %remove baseline
    EEG1 = pop_rmbase( EEG1, [-1000 0] ,[]);
    
    dataName = ['sub-' partID '_city1_mapOffEpochs'];
    EEG1 = pop_saveset( EEG1, 'filename',dataName,'filepath', 'E:\Berlin\2Hz_strictChanRemov_FCz\noDelay_Corr\epochs_mapOffset_epoch_highpassfiltered');


     
     %City 2 epoching
    
    dataName = [partID '_city2_mapOffEpochs'];
    EEG2 = pop_epoch( EEG2, city2Events, [-1  5], 'newname', dataName , 'epochinfo', 'yes');
   
    %remove baseline
    EEG2 = pop_rmbase( EEG2, [-1000 0] ,[]);
    dataName = ['sub-' partID '_city2_mapOffEpochs'];
    EEG2 = pop_saveset( EEG2, 'filename',dataName,'filepath', 'E:\Berlin\2Hz_strictChanRemov_FCz\noDelay_Corr\epochs_mapOffset_epoch_highpassfiltered');
    
    
    %City 3 epoching
    
    dataName = [partID '_city3_mapOffEpochs'];
    EEG3 = pop_epoch( EEG3, city3Events, [-1  5], 'newname', dataName , 'epochinfo', 'yes');
    
    %remove baseline
    EEG3 = pop_rmbase( EEG3, [-1000 0] ,[]);
    dataName = ['sub-' partID '_city3_mapOffEpochs'];
    EEG3 = pop_saveset( EEG3, 'filename',dataName,'filepath', 'E:\Berlin\2Hz_strictChanRemov_FCz\noDelay_Corr\epochs_mapOffset_epoch_highpassfiltered');
    
end   


