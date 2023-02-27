%This script unfolds blink events from the dataset. It goes through the map
%events and assigns conditions based on participants' randomly assigned
%order.

%Created by Enru Lin 21.03.2022

%% Set up the Import Options and import the data
cd 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data'     %Change directory to file location

opts = spreadsheetImportOptions("NumVariables", 3);

% Specify sheet and range
opts.Sheet = "Sheet1";
opts.DataRange = "A2:C143";

% Specify column names and types
opts.VariableNames = ["PartID", "City", "mapLMs"];
opts.VariableTypes = ["double", "double", "double"];

% Import the data
SubjCond = readtable("C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\Subj_conditions.ods", opts, "UseExcel", true);

%% Convert to output type
SubjCond = table2array(SubjCond);

%% Clear temporary variables
clear opts

%% Add conditions to blink events and then merge the 3 maps into one

eeglab
cd 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis'
pathName = 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\sub-';

%lant_corr = round(0.133 *250);     %To correct delays in time. Not needed
%for blink events because they are extracted from the EEG itself

for subjectIdx = [28:50 52:54 56:71 73:76]
    ALLEEG = []; 
    city_MapEvents = strings([3, 17]);   %Pre-setting string array for map events: 3 conditions by 17 map pop-ups 
    [temp_cond] = find(SubjCond(:, 1) == subjectIdx);    %Getting the row numbers in the conditions file
    
    for mapIDx = 1:3
        counter = 1;
        EEG = [];
        EEG = pop_loadset('filename', [num2str(subjectIdx), '_City', num2str(mapIDx), '_NavBlinks.set'],'filepath', [pathName, num2str(subjectIdx)]);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
       
        for eventIdx = 1:length(EEG.event)
            if contains(EEG.event(eventIdx).type, 'End')    %Skips to next map once it hits the end marker for the map and ignores subsequent blinks
                EEG.event(eventIdx+1:end) = [];
                break
            end
            
            if strcmp('blink', EEG.event(eventIdx).type) == 1 && mapIDx == 1       % blink events in map 1
                EEG.event(eventIdx).eventtype = SubjCond(temp_cond(1), 3);         %put condition (3, 5, 7) into EEG.event.eventtype
            elseif strcmp('blink', EEG.event(eventIdx).type) == 1 && mapIDx == 2       % blink events in map 2
                EEG.event(eventIdx).eventtype = SubjCond(temp_cond(2), 3);
            elseif strcmp('blink', EEG.event(eventIdx).type) == 1 && mapIDx == 3       % blink events in map 3
                EEG.event(eventIdx).eventtype = SubjCond(temp_cond(3), 3);
            end
            %EEG.event(eventIdx).latency = EEG.event(eventIdx).latency + lant_corr;
        end
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'gui','off', 'overwrite', 'on');
    end
    
    EEG = pop_mergeset(ALLEEG, [1 2 3], 0);                                     %Merging the datasets for unfolding
    EEG = pop_saveset(EEG, 'filename',[num2str(subjectIdx), '_Merged_IC30_0.5_30_wConds_Nav_new.set'],'filepath', [pathName, num2str(subjectIdx)]); 
end

%% Unfolding
eeglab
cd 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis'
pathName = 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\sub-';
run('init_unfold.m')                      %Start unfold toolbox

cfg = [];                    %Defining the factorial design for unfolding. We want to extract blinks and categorize them into their conditions
cfg.timelimits = [-0.5, 2]; % time window for response estimation
cfg.eventtypes = {  'blink' };
cfg.formula = {'y ~ 1' };   %This formula is only for sub 51 because they went through only 1 condition
%cfg.formula = {'y ~ 1 + cat(eventtype)' };
cfg.channel = 1:65;     %Have to check why there are 65 channels
n = 1;      %subj counter
blinkEvnts = [];
for subjectIdx = 51%[28:50 52:54 56:68 70:71 73:76]
    cfg.channel = 1:65;
    ALLEEG = []; EEG = [];
    p = 1;                                  %p, q, r are counters for the blink events in each condition
    q = 1;
    r = 1;
    EEG = pop_loadset('filename', [num2str(subjectIdx), '_Merged_IC30_0.5_30_wConds_Nav_new.set'],'filepath', [pathName, num2str(subjectIdx)]);
    EEG = eeg_checkset( EEG );
    blinkEvnts(n, 1) = subjectIdx;
    for eventIdx = 1:length(EEG.event)
        
        if isempty(EEG.event(eventIdx).eventtype)            %giving dummy event code for non-blink events otherwise unfolding does not work
            EEG.event(eventIdx).eventtype = 1;
        elseif EEG.event(eventIdx).eventtype == 3
            blinkEvnts(n, 2) = p;
            p = p + 1;
        elseif EEG.event(eventIdx).eventtype == 5
            blinkEvnts(n, 3) = q;
            q = q + 1;
        elseif EEG.event(eventIdx).eventtype == 7
            blinkEvnts(n, 4) = r;
            r = r + 1;
        end
    end
    
    % run model & plot results
    EEG_uf = uf_designmat(EEG,cfg); % create design matrix
    EEG_uf = uf_timeexpandDesignmat(EEG_uf,cfg); % time-expand design matrix
    
    % threshold value
    winrej= [];
    winrej = uf_continuousArtifactDetect(EEG_uf,'amplitudeThreshold',80);     %Anna's value
    EEG_uf = uf_continuousArtifactExclude(EEG_uf,struct('winrej',winrej));
    
    EEG_uf = uf_glmfit(EEG_uf,cfg); % solve regression model
    ufresult = uf_condense(EEG_uf); % reformat results (e.g. for plotting)
    
    % run model without deconvolution
    EEG_uf = uf_epoch(EEG_uf,'winrej',winrej,'timelimits', cfg.timelimits);
    EEG_uf_nodc = uf_glmfit_nodc(EEG_uf,cfg); % solve regression model
    ufresult_nodc = uf_condense(EEG_uf_nodc); % reformat results (e.g. for plotting)
    cfg.add_intercept = 1; % sum the intercept to each column
    cfg.include_intercept = 1; % include the intercept as dashed line
    
    ufresult2 = uf_condense(EEG_uf);
    
    ufresult.effects = ufresult2.beta * 2; % * 2 due to effect coding with -1 / 1.
%     cfg.channel = 26;
    %  ax = uf_plotParam(ufresult2,cfg);
    
    ufRoutes(n).ufresult = ufresult; % includes the effect coding
    ufRoutes(n).ufresult_nodc = ufresult_nodc; % includes the no deconvolved ERPs
    ufRoutes(n).cfg = cfg;
    
    EEG_uf = eeg_checkset( EEG_uf ); % load dataset into EEGLAB
    
    %EEG_uf = pop_saveset( EEG_uf, 'filename', [num2str(subjectIdx), '_Merged_IC30_0.5_30_wConds_Nav_new_unfolded.set'], 'filepath', [pathName, num2str(subjectIdx)]);
    %[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    n = n + 1;
end

%% Auto-rejecting bad unfolded epochs before beta extraction and individual peak detection(testing only to check if it makes a difference)
cd 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis'
pathName = 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\sub-';
eeglab
n = 1;
blinkEvnts = [];
for subjectIdx = [28:54 56:71 73:76]
    ALLEEG = []; EEG = [];
    EEG = pop_loadset('filename', [num2str(subjectIdx), '_Merged_IC30_0.5_30_wConds_Nav_new_unfolded.set'],'filepath', [pathName, num2str(subjectIdx)]);
    EEG = eeg_checkset( EEG );
    allEvents = [EEG.event.eventtype];
    blinkEvnts(n, 1) = subjectIdx;
    if subjectIdx == 51
        blinkEvnts(n, 2) = length(find(allEvents == 3));
    elseif subjectIdx == 69
        blinkEvnts(n, 3) = length(find(allEvents == 5));
        blinkEvnts(n, 4) = length(find(allEvents == 7));
    else
        blinkEvnts(n, 2) = length(find(allEvents == 3));  %counting blinks for 3-landmark condition
        blinkEvnts(n, 3) = length(find(allEvents == 5));
        blinkEvnts(n, 4) = length(find(allEvents == 7));
    end
    n = n +1;
    %[EEG, rmepochs] = pop_autorej(EEG, 'threshold', 80, 'startprob', 3,
    %'maxrej', 10, 'eegplot', 'off', 'nogui', 'on');  %5 iterations, 3 SD
    %(original)
    [EEG, rmepochs] = pop_autorej(EEG, 'threshold', 80, 'startprob', 5, 'maxrej', 10, 'eegplot', 'off', 'nogui', 'on');  %5 iterations and 5 SD 
    EEG.rmepochs = rmepochs;
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset( EEG, 'filename',[num2str(subjectIdx), '_unfolded_epoch_rejected_5SD.set'],'filepath', [pathName, num2str(subjectIdx)]); %% overwritten the previous version :(
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
end

clear
cd 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis'
pathName = 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\sub-';
eeglab
%Beta extraction
subjectIndex = [28:50 52:54 56:68 70:71 73:76];
%subjectIndex = 51;
%subjectIndex = 69;
electrodeIndex = [1:65];

%Pre-allocating arrays

threeLdMrk_Fz_dec_epRej = [];
threeLdMrk_Oz_dec_epRej = [];
threeLdMrk_Fcz_dec_epRej = [];
threeLdMrk_Pz_dec_epRej = [];
threeLdMrk_Poz_dec_epRej = [];

fiveLdMrk_Fz_dec_epRej = [];
fiveLdMrk_Oz_dec_epRej = [];
fiveLdMrk_Fcz_dec_epRej = [];
fiveLdMrk_Pz_dec_epRej = [];
fiveLdMrk_Poz_dec_epRej = [];

sevenLdMrk_Fz_dec_epRej = [];
sevenLdMrk_Oz_dec_epRej = [];
sevenLdMrk_Fcz_dec_epRej = [];
sevenLdMrk_Pz_dec_epRej = [];
sevenLdMrk_Poz_dec_epRej = [];

blinkEvnts = NaN(length(subjectIndex), 4);

for subjectIdx = 1:length(subjectIndex)
    ALLEEG = []; EEG = []; allEvents = [];
    EEG = pop_loadset('filename', [num2str(subjectIndex(subjectIdx)), '_unfolded_epoch_rejected_5SD.set'],'filepath', [pathName, num2str(subjectIndex(subjectIdx))]);
    EEG = eeg_checkset( EEG );
    blinkEvnts(subjectIdx, 1) = subjectIndex(subjectIdx);
    allEvents = [EEG.event.eventtype];
    blinkEvnts(subjectIdx, 2) = length(find(allEvents == 3));  %counting blinks for 3-landmark condition
    blinkEvnts(subjectIdx, 3) = length(find(allEvents == 5));
    blinkEvnts(subjectIdx, 4) = length(find(allEvents == 7));
    for elecIdx =  1:length(electrodeIndex)
        ufRoutes(subjectIdx).plots.electrode(elecIdx).name = EEG.chanlocs(electrodeIndex(elecIdx)).labels;
        % average across trials
        electrode = squeeze(EEG.unfold.beta_dc(electrodeIndex(elecIdx),:,:));
        %For sub 51
        %electrode = (squeeze(EEG.unfold.beta_dc(electrodeIndex(elecIdx),:,:)))';
        %electrode = bsxfun(@minus,electrode,mean(electrode((EEG.unfold.times>=-0.5)& (EEG.unfold.times<-0.2)),1));  %subtracting baseline
        
        % substract baseline
        electrode = bsxfun(@minus,electrode,mean(electrode((EEG.unfold.times>=-0.5)& (EEG.unfold.times<-0.2),:),1));
        ufRoutes(subjectIdx).plots.electrode(elecIdx).activity = electrode;
        ufRoutes(subjectIdx).plots.electrode(elecIdx).blink3_dec = electrode * [1,0,0]';  % 1*3-landmark + 0*5-landmark + 0*7-landmark
        ufRoutes(subjectIdx).plots.electrode(elecIdx).blink5_dec = electrode * [1,1,0]';  % 1*3-landmark + 1*5-landmark + 0*7-landmark
        ufRoutes(subjectIdx).plots.electrode(elecIdx).blink7_dec = electrode * [1,0,1]';  % 1*3-landmark + 0*5-landmark + 1*7-landmark
        
        %For sub 51, who has only the 3-landmark condition
        %ufRoutes(subjectIdx).plots.electrode(elecIdx).blink3_dec = electrode * [1]';
        
        %For sub 69, who has only the 5- and 7-landmark conditions
%         ufRoutes(subjectIdx).plots.electrode(elecIdx).blink5_dec = electrode * [1,0]';  % 1*5-landmark + 0*7-landmark
%         ufRoutes(subjectIdx).plots.electrode(elecIdx).blink7_dec = electrode * [1,1]';
    end
    threeLdMrk_Fz_dec_epRej = [threeLdMrk_Fz_dec_epRej; (ufRoutes(subjectIdx).plots.electrode(2).blink3_dec)'];   %Putting all participants' 3-landmark condition in Fz into one array for timewise averaging later
    threeLdMrk_Oz_dec_epRej = [threeLdMrk_Oz_dec_epRej; (ufRoutes(subjectIdx).plots.electrode(17).blink3_dec)'];
    threeLdMrk_Fcz_dec_epRej = [threeLdMrk_Fcz_dec_epRej; (ufRoutes(subjectIdx).plots.electrode(65).blink3_dec)'];
    threeLdMrk_Pz_dec_epRej = [threeLdMrk_Pz_dec_epRej; (ufRoutes(subjectIdx).plots.electrode(13).blink3_dec)'];
    threeLdMrk_Poz_dec_epRej = [threeLdMrk_Poz_dec_epRej; (ufRoutes(subjectIdx).plots.electrode(48).blink3_dec)'];
    
    fiveLdMrk_Fz_dec_epRej = [fiveLdMrk_Fz_dec_epRej; (ufRoutes(subjectIdx).plots.electrode(2).blink5_dec)'];   %Putting all participants' 3-landmark condition in Fz into one array for timewise averaging later
    fiveLdMrk_Oz_dec_epRej = [fiveLdMrk_Oz_dec_epRej; (ufRoutes(subjectIdx).plots.electrode(17).blink5_dec)'];
    fiveLdMrk_Fcz_dec_epRej = [fiveLdMrk_Fcz_dec_epRej; (ufRoutes(subjectIdx).plots.electrode(65).blink5_dec)'];
    fiveLdMrk_Pz_dec_epRej = [fiveLdMrk_Pz_dec_epRej; (ufRoutes(subjectIdx).plots.electrode(13).blink5_dec)'];
    fiveLdMrk_Poz_dec_epRej = [fiveLdMrk_Poz_dec_epRej; (ufRoutes(subjectIdx).plots.electrode(48).blink5_dec)'];
    
    sevenLdMrk_Fz_dec_epRej = [sevenLdMrk_Fz_dec_epRej; (ufRoutes(subjectIdx).plots.electrode(2).blink7_dec)'];   %Putting all participants' 3-landmark condition in Fz into one array for timewise averaging later
    sevenLdMrk_Oz_dec_epRej = [sevenLdMrk_Oz_dec_epRej; (ufRoutes(subjectIdx).plots.electrode(17).blink7_dec)'];
    sevenLdMrk_Fcz_dec_epRej = [sevenLdMrk_Fcz_dec_epRej; (ufRoutes(subjectIdx).plots.electrode(65).blink7_dec)'];
    sevenLdMrk_Pz_dec_epRej = [sevenLdMrk_Pz_dec_epRej; (ufRoutes(subjectIdx).plots.electrode(13).blink7_dec)'];
    sevenLdMrk_Poz_dec_epRej = [sevenLdMrk_Poz_dec_epRej; (ufRoutes(subjectIdx).plots.electrode(48).blink7_dec)'];
end

% save('3LdmrkFz_Nav_epRej.mat', 'threeLdMrk_Fz_dec_epRej');
% save('3LdmrkOz_Nav_epRej.mat', 'threeLdMrk_Oz_dec_epRej');
% save('3LdmrkFCz_Nav_epRej.mat', 'threeLdMrk_Fcz_dec_epRej');
% save('3LdmrkPz_Nav_epRej.mat', 'threeLdMrk_Pz_dec_epRej');
% save('3LdmrkPOz_Nav_epRej.mat', 'threeLdMrk_Poz_dec_epRej');

save('3LdmrkFz_Nav_epRej5SD.mat', 'threeLdMrk_Fz_dec_epRej');
save('3LdmrkOz_Nav_epRej5SD.mat', 'threeLdMrk_Oz_dec_epRej');
save('3LdmrkFCz_Nav_epRej5SD.mat', 'threeLdMrk_Fcz_dec_epRej');
save('3LdmrkPz_Nav_epRej5SD.mat', 'threeLdMrk_Pz_dec_epRej');
save('3LdmrkPOz_Nav_epRej5SD.mat', 'threeLdMrk_Poz_dec_epRej');

%For sub 51
% save('51_3LdmrkFz_Nav_epRej.mat', 'threeLdMrk_Fz_dec_epRej');
% save('51_3LdmrkOz_Nav_epRej.mat', 'threeLdMrk_Oz_dec_epRej');
% save('51_3LdmrkFCz_Nav_epRej.mat', 'threeLdMrk_Fcz_dec_epRej');
% save('51_3LdmrkPz_Nav_epRej.mat', 'threeLdMrk_Pz_dec_epRej');
% save('51_3LdmrkPOz_Nav_epRej.mat', 'threeLdMrk_Poz_dec_epRej');

% save('5LdmrkFz_Nav_epRej.mat', 'fiveLdMrk_Fz_dec_epRej');
% save('5LdmrkOz_Nav_epRej.mat', 'fiveLdMrk_Oz_dec_epRej');
% save('5LdmrkFCz_Nav_epRej.mat', 'fiveLdMrk_Fcz_dec_epRej');
% save('5LdmrkPz_Nav_epRej.mat', 'fiveLdMrk_Pz_dec_epRej');
% save('5LdmrkPOz_Nav_epRej.mat', 'fiveLdMrk_Poz_dec_epRej');
% 
% save('7LdmrkFz_Nav_epRej.mat', 'sevenLdMrk_Fz_dec_epRej');
% save('7LdmrkOz_Nav_epRej.mat', 'sevenLdMrk_Oz_dec_epRej');
% save('7LdmrkFCz_Nav_epRej.mat', 'sevenLdMrk_Fcz_dec_epRej');
% save('7LdmrkPz_Nav_epRej.mat', 'sevenLdMrk_Pz_dec_epRej');
% save('7LdmrkPOz_Nav_epRej.mat', 'sevenLdMrk_Poz_dec_epRej');

save('5LdmrkFz_Nav_epRej5SD.mat', 'fiveLdMrk_Fz_dec_epRej');
save('5LdmrkOz_Nav_epRej5SD.mat', 'fiveLdMrk_Oz_dec_epRej');
save('5LdmrkFCz_Nav_epRej5SD.mat', 'fiveLdMrk_Fcz_dec_epRej');
save('5LdmrkPz_Nav_epRej5SD.mat', 'fiveLdMrk_Pz_dec_epRej');
save('5LdmrkPOz_Nav_epRej5SD.mat', 'fiveLdMrk_Poz_dec_epRej');

save('7LdmrkFz_Nav_epRej5SD.mat', 'sevenLdMrk_Fz_dec_epRej');
save('7LdmrkOz_Nav_epRej5SD.mat', 'sevenLdMrk_Oz_dec_epRej');
save('7LdmrkFCz_Nav_epRej5SD.mat', 'sevenLdMrk_Fcz_dec_epRej');
save('7LdmrkPz_Nav_epRej5SD.mat', 'sevenLdMrk_Pz_dec_epRej');
save('7LdmrkPOz_Nav_epRej5SD.mat', 'sevenLdMrk_Poz_dec_epRej');

%For sub 69
% save('69_5LdmrkFz_Nav_epRej.mat', 'fiveLdMrk_Fz_dec_epRej');
% save('69_5LdmrkOz_Nav_epRej.mat', 'fiveLdMrk_Oz_dec_epRej');
% save('69_5LdmrkFCz_Nav_epRej.mat', 'fiveLdMrk_Fcz_dec_epRej');
% save('69_5LdmrkPz_Nav_epRej.mat', 'fiveLdMrk_Pz_dec_epRej');
% save('69_5LdmrkPOz_Nav_epRej.mat', 'fiveLdMrk_Poz_dec_epRej');
% 
% save('69_7LdmrkFz_Nav_epRej.mat', 'sevenLdMrk_Fz_dec_epRej');
% save('69_7LdmrkOz_Nav_epRej.mat', 'sevenLdMrk_Oz_dec_epRej');
% save('69_7LdmrkFCz_Nav_epRej.mat', 'sevenLdMrk_Fcz_dec_epRej');
% save('69_7LdmrkPz_Nav_epRej.mat', 'sevenLdMrk_Pz_dec_epRej');
% save('69_7LdmrkPOz_Nav_epRej.mat', 'sevenLdMrk_Poz_dec_epRej');

%% extract betas from all participants and plot for intersubject comparisons
%Need to run unfolding and have the ufRoutes structure in MAtlab workspace
%to run

baseline = [ufRoutes(1).ufresult.times(1) -0.2];
subjectIndex = 51%[28:50 52:54 56:68 70:71 73:76];
electrodeIndex = [1:65];

%Pre-allocating arrays to have the number of subjects as rows and number of
%time points as columns. Speeds up process
threeLdMrk_Fz_dec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
threeLdMrk_Oz_dec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
threeLdMrk_Fcz_dec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
threeLdMrk_Pz_dec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
threeLdMrk_Poz_dec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% threeLdMrk_Fz_nodec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% threeLdMrk_Oz_nodec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% threeLdMrk_Fcz_nodec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% threeLdMrk_Pz_nodec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% threeLdMrk_Poz_nodec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));

% fiveLdMrk_Fz_dec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% fiveLdMrk_Oz_dec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% fiveLdMrk_Fcz_dec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% fiveLdMrk_Pz_dec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% fiveLdMrk_Poz_dec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% fiveLdMrk_Fz_nodec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% fiveLdMrk_Oz_nodec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% fiveLdMrk_Fcz_nodec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% fiveLdMrk_Pz_nodec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% fiveLdMrk_Poz_nodec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));

% sevenLdMrk_Fz_dec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% sevenLdMrk_Oz_dec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% sevenLdMrk_Fcz_dec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% sevenLdMrk_Pz_dec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% sevenLdMrk_Poz_dec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% sevenLdMrk_Fz_nodec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% sevenLdMrk_Oz_nodec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% sevenLdMrk_Fcz_nodec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% sevenLdMrk_Pz_nodec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));
% sevenLdMrk_Poz_nodec = NaN(length(subjectIndex), length(ufRoutes(1).ufresult.times));

for subjectIdx = 1:length(subjectIndex)
    for elecIdx =  1:length(electrodeIndex)
       ufRoutes(subjectIdx).plots.electrode(elecIdx).name = ufRoutes(subjectIdx).ufresult.chanlocs(electrodeIndex(elecIdx)).labels;
        
        % average across trials
        %electrode = squeeze(ufRoutes(subjectIdx).ufresult_nodc.unfold.beta_dc(electrodeIndex(elecIdx),:,:));
        %For sub 51
        electrode = (squeeze(ufRoutes(subjectIdx).ufresult_nodc.unfold.beta_dc(electrodeIndex(elecIdx),:,:)))';
        %electrode_nodc = squeeze(ufRoutes(subjectIdx).ufresult_nodc.unfold.beta_nodc(electrodeIndex(elecIdx),:,:));
        
        % substract baseline
        electrode = bsxfun(@minus,electrode,mean(electrode((ufRoutes(subjectIdx).ufresult.times>=baseline(1))& (ufRoutes(subjectIdx).ufresult.times<baseline(2)),:),1));
        
        %For sub 51
        %electrode = bsxfun(@minus,electrode,mean(electrode((ufRoutes(subjectIdx).ufresult.times>=baseline(1))& (ufRoutes(subjectIdx).ufresult.times<baseline(2))),1));
        %electrode_nodc = bsxfun(@minus,electrode_nodc,mean(electrode_nodc((ufRoutes(subjectIdx).ufresult.times>=baseline(1))& (ufRoutes(subjectIdx).ufresult.times<baseline(2)),:),1));

        ufRoutes(subjectIdx).plots.electrode(elecIdx).activity = electrode;
        %ufRoutes(subjectIdx).plots.electrode_nodc(elecIdx).activity = electrode_nodc;
        
        %For sub 69, who has only the 5- and 7-landmark conditions
%         ufRoutes(subjectIdx).plots.electrode(elecIdx).blink5_dec = electrode * [1,0]';  % 1*5-landmark + 0*7-landmark
%         ufRoutes(subjectIdx).plots.electrode(elecIdx).blink7_dec = electrode * [1,1]';
        %For sub 51, who has only the 3-landmark condition
        ufRoutes(subjectIdx).plots.electrode(elecIdx).blink3_dec = electrode * [1]';
        
        %with deconvolution
%         ufRoutes(subjectIdx).plots.electrode(elecIdx).blink3_dec = electrode * [1,0,0]';  % 1*3-landmark + 0*5-landmark + 0*7-landmark
%         ufRoutes(subjectIdx).plots.electrode(elecIdx).blink5_dec = electrode * [1,1,0]';  % 1*3-landmark + 1*5-landmark + 0*7-landmark
%         ufRoutes(subjectIdx).plots.electrode(elecIdx).blink7_dec = electrode * [1,0,1]';  % 1*3-landmark + 0*5-landmark + 1*7-landmark
%         
        %without deconvolution
%         ufRoutes(subjectIdx).plots.electrode(elecIdx).blink3_nodec = electrode_nodc * [1,1,0,0]';  % 1*intercept + 1*3-landmark + 0*5-landmark + 0*7-landmark
%         ufRoutes(subjectIdx).plots.electrode(elecIdx).blink5_nodec = electrode_nodc * [1,0,1,0]';  % 1*intercept + 0*3-landmark + 1*5-landmark + 0*7-landmark
%         ufRoutes(subjectIdx).plots.electrode(elecIdx).blink7_nodec = electrode_nodc * [1,0,0,1]';  % 1*intercept + 0*3-landmark + 0*5-landmark + 1*7-landmark
    end
    
    threeLdMrk_Fz_dec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(2).blink3_dec;   %Putting all participants' 3-landmark condition in Fz into one array for timewise averaging later
    threeLdMrk_Oz_dec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(17).blink3_dec;
    threeLdMrk_Fcz_dec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(65).blink3_dec;
    threeLdMrk_Pz_dec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(13).blink3_dec;
    threeLdMrk_Poz_dec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(48).blink3_dec;
%     threeLdMrk_Fz_nodec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(2).blink3_nodec;
%     threeLdMrk_Oz_nodec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(17).blink3_nodec;
%     threeLdMrk_Fcz_nodec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(65).blink3_nodec;
%     threeLdMrk_Pz_nodec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(13).blink3_nodec;
%     threeLdMrk_Poz_nodec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(48).blink3_nodec;
    
%     fiveLdMrk_Fz_dec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(2).blink5_dec;   
%     fiveLdMrk_Oz_dec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(17).blink5_dec;
%     fiveLdMrk_Fcz_dec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(65).blink5_dec;
%     fiveLdMrk_Pz_dec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(13).blink5_dec;
%     fiveLdMrk_Poz_dec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(48).blink5_dec;
%     fiveLdMrk_Fz_nodec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(2).blink5_nodec;
%     fiveLdMrk_Oz_nodec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(17).blink5_nodec;
%     fiveLdMrk_Fcz_nodec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(65).blink5_nodec;
%     fiveLdMrk_Pz_nodec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(13).blink5_nodec;
%     fiveLdMrk_Poz_nodec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(48).blink5_nodec;
    
%     sevenLdMrk_Fz_dec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(2).blink7_dec;  
%     sevenLdMrk_Oz_dec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(17).blink7_dec;
%     sevenLdMrk_Fcz_dec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(65).blink7_dec; 
%     sevenLdMrk_Pz_dec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(13).blink7_dec;
%     sevenLdMrk_Poz_dec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(48).blink7_dec;
%     sevenLdMrk_Fz_nodec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(2).blink7_nodec;
%     sevenLdMrk_Oz_nodec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(17).blink7_nodec;
%     sevenLdMrk_Fcz_nodec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(65).blink7_nodec;
%     sevenLdMrk_Pz_nodec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(13).blink7_nodec;
%     sevenLdMrk_Poz_nodec(subjectIdx, :) = ufRoutes(subjectIdx).plots.electrode(48).blink7_nodec;
end

%Saving betas for statistical analyses

%For sub 51
% save('51_3LdmrkFz_Nav_new.mat', 'threeLdMrk_Fz_dec');
% save('51_3LdmrkOz_Nav_new.mat', 'threeLdMrk_Oz_dec');
% save('51_3LdmrkFCz_Nav_new.mat', 'threeLdMrk_Fcz_dec');
% save('51_3LdmrkPz_Nav_new.mat', 'threeLdMrk_Pz_dec');
% save('51_3LdmrkPOz_Nav_new.mat', 'threeLdMrk_Poz_dec');

%For sub 69
% save('69_5LdmrkFz_Nav_new.mat', 'fiveLdMrk_Fz_dec');
% save('69_5LdmrkOz_Nav_new.mat', 'fiveLdMrk_Oz_dec');
% save('69_5LdmrkFCz_Nav_new.mat', 'fiveLdMrk_Fcz_dec');
% save('69_5LdmrkPz_Nav_new.mat', 'fiveLdMrk_Pz_dec');
% save('69_5LdmrkPOz_Nav_new.mat', 'fiveLdMrk_Poz_dec');
% 
% save('69_7LdmrkFz_Nav_new.mat', 'sevenLdMrk_Fz_dec');
% save('69_7LdmrkOz_Nav_new.mat', 'sevenLdMrk_Oz_dec');
% save('69_7LdmrkFCz_Nav_new.mat', 'sevenLdMrk_Fcz_dec');
% save('69_7LdmrkPz_Nav_new.mat', 'sevenLdMrk_Pz_dec');
% save('69_7LdmrkPOz_Nav_new.mat', 'sevenLdMrk_Poz_dec');

% save('3LdmrkFz_Nav_new.mat', 'threeLdMrk_Fz_dec');
% save('3LdmrkOz_Nav_new.mat', 'threeLdMrk_Oz_dec');
% save('3LdmrkFCz_Nav_new.mat', 'threeLdMrk_Fcz_dec');
% save('3LdmrkPz_Nav_new.mat', 'threeLdMrk_Pz_dec');
% save('3LdmrkPOz_Nav_new.mat', 'threeLdMrk_Poz_dec');
% 
% save('5LdmrkFz_Nav_new.mat', 'fiveLdMrk_Fz_dec');
% save('5LdmrkOz_Nav_new.mat', 'fiveLdMrk_Oz_dec');
% save('5LdmrkFCz_Nav_new.mat', 'fiveLdMrk_Fcz_dec');
% save('5LdmrkPz_Nav_new.mat', 'fiveLdMrk_Pz_dec');
% save('5LdmrkPOz_Nav_new.mat', 'fiveLdMrk_Poz_dec');
% 
% save('7LdmrkFz_Nav_new.mat', 'sevenLdMrk_Fz_dec');
% save('7LdmrkOz_Nav_new.mat', 'sevenLdMrk_Oz_dec');
% save('7LdmrkFCz_Nav_new.mat', 'sevenLdMrk_Fcz_dec');
% save('7LdmrkPz_Nav_new.mat', 'sevenLdMrk_Pz_dec');
% save('7LdmrkPOz_Nav_new.mat', 'sevenLdMrk_Poz_dec');
%% Plotting
x = [-496:4:2000];
%Figure of ERP 
figure(1)
subplot(2, 1, 1);
plot(x, mean(threeLdMrk_Fz_dec), 'Marker', 'o', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerIndices', 1:50:length(x), 'MarkerSize', 13);
hold on
plot(x, mean(fiveLdMrk_Fz_dec), 'LineStyle', '--', 'Marker', '^', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 10:50:length(x), 'MarkerSize', 13);
plot(x, mean(sevenLdMrk_Fz_dec), 'Marker', 's', 'Color', 'k', 'Linewidth', 1.7, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 20:50:length(x), 'MarkerSize', 13);
lgd = legend('3 Landmark', '5 Landmark', '7 Landmark', 'Orientation', 'horizontal');
ax = gca;
ax.LineWidth = 2;
ax.FontName = 'Arial';
ax.FontSize = 14;
ax.XLabel.String = 'Time (ms)';
ax.YLabel.String = 'Fz (\muV)';
ax.YLabel.FontSize = 14;
title('With deconvolution');
subplot(2, 1, 2);
plot(x, mean(threeLdMrk_Fz_nodec), 'Marker', 'o', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerIndices', 1:50:length(x), 'MarkerSize', 13);
hold on
plot(x, mean(fiveLdMrk_Fz_nodec), 'LineStyle', '--', 'Marker', '^', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 10:50:length(x), 'MarkerSize', 13);
plot(x, mean(sevenLdMrk_Fz_nodec), 'Marker', 's', 'Color', 'k', 'Linewidth', 1.7, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 20:50:length(x), 'MarkerSize', 13);
ax = gca;
ax.LineWidth = 2;
ax.FontName = 'Arial';
ax.FontSize = 14;
ax.XLabel.String = 'Time (ms)';
ax.YLabel.String = 'Fz (\muV)';
ax.YLabel.FontSize = 14;
title('Without deconvolution');

figure(2)
subplot(2, 1, 1);
plot(x, mean(threeLdMrk_Oz_dec), 'Marker', 'o', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerIndices', 1:50:length(x), 'MarkerSize', 13);
hold on
plot(x, mean(fiveLdMrk_Oz_dec), 'LineStyle', '--', 'Marker', '^', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 10:50:length(x), 'MarkerSize', 13);
plot(x, mean(sevenLdMrk_Oz_dec), 'Marker', 's', 'Color', 'k', 'Linewidth', 1.7, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 20:50:length(x), 'MarkerSize', 13);
lgd = legend('3 Landmark', '5 Landmark', '7 Landmark', 'Orientation', 'horizontal');
ax = gca;
ax.LineWidth = 2;
ax.FontName = 'Arial';
ax.FontSize = 14;
ax.XLabel.String = 'Time (ms)';
ax.YLabel.String = 'Oz (\muV)';
ax.YLabel.FontSize = 14;
title('With deconvolution');
subplot(2, 1, 2);
plot(x, mean(threeLdMrk_Oz_nodec), 'Marker', 'o', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerIndices', 1:50:length(x), 'MarkerSize', 13);
hold on
plot(x, mean(fiveLdMrk_Oz_nodec), 'LineStyle', '--', 'Marker', '^', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 10:50:length(x), 'MarkerSize', 13);
plot(x, mean(sevenLdMrk_Oz_nodec), 'Marker', 's', 'Color', 'k', 'Linewidth', 1.7, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 20:50:length(x), 'MarkerSize', 13);
ax = gca;
ax.LineWidth = 2;
ax.FontName = 'Arial';
ax.FontSize = 14;
ax.XLabel.String = 'Time (ms)';
ax.YLabel.String = 'Oz (\muV)';
ax.YLabel.FontSize = 14;
title('Without deconvolution');

figure(3)
subplot(2, 1, 1);
line([50 50], [-4 3], 'Color', [1, 1, 1], 'LineWidth', 0.3);
hold on
line([150 150], [-4 3], 'Color', [1, 1, 1], 'LineWidth', 0.3);
patch([50 150 150 50], [-4 -4 3 3], [0.8, 0.8, 0.8], 'FaceAlpha', 0.5);
plot(x, mean(threeLdMrk_Oz_dec), 'Marker', 'o', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerIndices', 1:50:length(x), 'MarkerSize', 13);
plot(x, mean(fiveLdMrk_Oz_dec), 'LineStyle', '--', 'Marker', '^', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 10:50:length(x), 'MarkerSize', 13);
plot(x, mean(sevenLdMrk_Oz_dec), 'Marker', 's', 'Color', 'k', 'Linewidth', 1.7, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 20:50:length(x), 'MarkerSize', 13);
lgd = legend('', '', '', '3 Landmark', '5 Landmark', '7 Landmark', 'Orientation', 'horizontal');
axis([-500 1000 -4 3]);
ax = gca;
ax.LineWidth = 2;
ax.FontName = 'Arial';
ax.FontSize = 14;
ax.XLabel.String = 'Time (ms)';
ax.YLabel.String = 'Oz (\muV)';
ax.YLabel.FontSize = 14;
ax.XAxis.TickValues = [-500:100:x(end)];
title('Oz');
subplot(2, 1, 2);
line([150 150], [-4 3], 'Color', [1, 1, 1], 'LineWidth', 0.3);
hold on
line([250 250], [-4 3], 'Color', [1, 1, 1], 'LineWidth', 0.3);
patch([150 250 250 150], [-4 -4 3 3], [0.8, 0.8, 0.8], 'FaceAlpha', 0.5);
plot(x, mean(threeLdMrk_Fz_dec), 'Marker', 'o', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerIndices', 1:50:length(x), 'MarkerSize', 13);
plot(x, mean(fiveLdMrk_Fz_dec), 'LineStyle', '--', 'Marker', '^', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 10:50:length(x), 'MarkerSize', 13);
plot(x, mean(sevenLdMrk_Fz_dec), 'Marker', 's', 'Color', 'k', 'Linewidth', 1.7, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 20:50:length(x), 'MarkerSize', 13);
axis([-500 1000 -4 3])
ax = gca;
ax.LineWidth = 2;
ax.FontName = 'Arial';
ax.FontSize = 14;
ax.XLabel.String = 'Time (ms)';
ax.YLabel.String = 'Fz (\muV)';
ax.YLabel.FontSize = 14;
ax.XAxis.TickValues = [-500:100:x(end)];
title('Fz');

figure(4)
line([100 100], [-4 3], 'Color', [1, 1, 1], 'LineWidth', 0.3);
hold on
line([200 200], [-4 3], 'Color', [1, 1, 1], 'LineWidth', 0.3);
patch([100 200 200 100], [-4 -4 3 3], [0.8, 0.8, 0.8], 'FaceAlpha', 0.5);
plot(x, mean(threeLdMrk_Fcz_dec), 'Marker', 'o', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerIndices', 1:50:length(x), 'MarkerSize', 13);
plot(x, mean(fiveLdMrk_Fcz_dec), 'LineStyle', '--', 'Marker', '^', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 10:50:length(x), 'MarkerSize', 13);
plot(x, mean(sevenLdMrk_Fcz_dec), 'Marker', 's', 'Color', 'k', 'Linewidth', 1.7, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 20:50:length(x), 'MarkerSize', 13);
%axis([-500 1000 -4 3])
ax = gca;
ax.LineWidth = 2;
ax.FontName = 'Arial';
ax.FontSize = 14;
ax.XLabel.String = 'Time (ms)';
ax.YLabel.String = 'Fcz (\muV)';
ax.YLabel.FontSize = 14;
%ax.XAxis.TickValues = [-500:100:x(end)];
lgd = legend('', '', '', '3 Landmark', '5 Landmark', '7 Landmark', 'Orientation', 'horizontal');
title('Fcz');

figure(5)
line([100 100], [-4 3], 'Color', [1, 1, 1], 'LineWidth', 0.3);
hold on
line([200 200], [-4 3], 'Color', [1, 1, 1], 'LineWidth', 0.3);
patch([100 200 200 100], [-4 -4 3 3], [0.8, 0.8, 0.8], 'FaceAlpha', 0.5);
plot(x, mean(threeLdMrk_Pz_dec), 'Marker', 'o', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerIndices', 1:50:length(x), 'MarkerSize', 13);
plot(x, mean(fiveLdMrk_Pz_dec), 'LineStyle', '--', 'Marker', '^', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 10:50:length(x), 'MarkerSize', 13);
plot(x, mean(sevenLdMrk_Pz_dec), 'Marker', 's', 'Color', 'k', 'Linewidth', 1.7, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 20:50:length(x), 'MarkerSize', 13);
%axis([-500 1000 -4 3])
ax = gca;
ax.LineWidth = 2;
ax.FontName = 'Arial';
ax.FontSize = 14;
ax.XLabel.String = 'Time (ms)';
ax.YLabel.String = 'Pz (\muV)';
ax.YLabel.FontSize = 14;
%ax.XAxis.TickValues = [-500:100:x(end)];
lgd = legend('', '', '', '3 Landmark', '5 Landmark', '7 Landmark', 'Orientation', 'horizontal');
title('Pz');

figure(6)
line([100 100], [-4 3], 'Color', [1, 1, 1], 'LineWidth', 0.3);
hold on
line([200 200], [-4 3], 'Color', [1, 1, 1], 'LineWidth', 0.3);
patch([100 200 200 100], [-4 -4 3 3], [0.8, 0.8, 0.8], 'FaceAlpha', 0.5);
plot(x, mean(threeLdMrk_Poz_dec), 'Marker', 'o', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerIndices', 1:50:length(x), 'MarkerSize', 13);
plot(x, mean(fiveLdMrk_Poz_dec), 'LineStyle', '--', 'Marker', '^', 'Color', 'k', 'Linewidth', 1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 10:50:length(x), 'MarkerSize', 13);
plot(x, mean(sevenLdMrk_Poz_dec), 'Marker', 's', 'Color', 'k', 'Linewidth', 1.7, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'MarkerIndices', 20:50:length(x), 'MarkerSize', 13);
%axis([-500 1000 -4 3])
ax = gca;
ax.LineWidth = 2;
ax.FontName = 'Arial';
ax.FontSize = 14;
ax.XLabel.String = 'Time (ms)';
ax.YLabel.String = 'POz (\muV)';
ax.YLabel.FontSize = 14;
%ax.XAxis.TickValues = [-500:100:x(end)];
lgd = legend('', '', '', '3 Landmark', '5 Landmark', '7 Landmark', 'Orientation', 'horizontal');
title('POz');

