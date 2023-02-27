%Cut participants' data into the segments that contain only blinks during navigation for
%the three different conditions and name them ...City1, City2, City3, etc.

city1_str = ['City 1 showMapAt'];
city2_str = ['City 2 showMapAt'];
city3_str = ['City 3 showMapAt'];

cd 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis'
pathName = 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\sub-';
eeglab

for subjectIdx = [28:50 52:54 56:71 73:76]
    ALLEEG = []; 
    EEG = [];
    city1_MapEvents = [];
    city2_MapEvents = [];
    city3_MapEvents = [];
    for mapIdx = 1:3
        EEG = pop_loadset('filename', [num2str(subjectIdx), '_City', num2str(mapIdx), 'ICclean30.set'], 'filepath', [pathName, num2str(subjectIdx)]);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0);
        
        for markerIdx = 1:length(EEG.event)
            if contains(EEG.event(markerIdx).type, 'End')    %Skips to next map once it hits the end marker for the map and ignores subsequent blinks
                break
            end
            if contains(EEG.event(markerIdx).type, city1_str)
                city1_MapEvents = [city1_MapEvents, {EEG.event(markerIdx).type}];
            elseif contains(EEG.event(markerIdx).type, city2_str)
                city2_MapEvents = [city2_MapEvents, {EEG.event(markerIdx).type}];
            elseif contains(EEG.event(markerIdx).type, city3_str)
                city3_MapEvents = [city3_MapEvents, {EEG.event(markerIdx).type}];
            end
        end
        
        %Getting blink events only during navigation
        if mapIdx == 1
            EEG = pop_rmdat( EEG, city1_MapEvents ,[-0.2 5] ,1);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname',[num2str(subjectIdx), '_City1_Nav'],'gui','off');
            EEG = pop_saveset( EEG, 'filename',[num2str(subjectIdx), '_City1_NavBlinks.set'],'filepath', [pathName, num2str(subjectIdx)]); %% overwritten the previous version :(
            [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        elseif mapIdx == 2
            %[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'retrieve',1,'study',0);
            EEG = pop_rmdat( EEG, city2_MapEvents, [-0.2 5] ,1);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname',[num2str(subjectIdx), '_City2_Nav'],'gui','off');
            EEG = pop_saveset( EEG, 'filename',[num2str(subjectIdx), '_City2_NavBlinks.set'],'filepath', [pathName, num2str(subjectIdx)]); %% overwritten the previous version :(
            [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        elseif mapIdx == 3
            %[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'retrieve',1,'study',0);
            EEG = pop_rmdat( EEG, city3_MapEvents, [-0.2 5] ,1);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname',[num2str(subjectIdx), '_City3_Nav'],'gui','off');
            EEG = pop_saveset( EEG, 'filename',[num2str(subjectIdx), '_City3_NavBlinks.set'],'filepath', [pathName, num2str(subjectIdx)]); %% overwritten the previous version :(
            [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        end
    end
    eeglab redraw;
    
    %EEG = pop_mergeset(ALLEEG, [2 4 6], 0);                                     %Merging the datasets for unfolding
    %EEG = pop_saveset( EEG, 'filename',[num2str(subjectIdx), '_ICclean30_0.5_30_NavBlinks.set'],'filepath', [pathName, num2str(subjectIdx)]);
    %[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
end