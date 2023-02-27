%% average ERPs
clear all;
close all;
eeglab

front_chanLabels = {'FCz', 'FC1', 'FC2'}; 
pariet_chanLabels = {'Pz', 'P1', 'P2'};
po_chanLabels = {'POz', 'PO3', 'PO4'};
o_chanLabels = {'Oz', 'O1', 'O2'};


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
    
    %create empty matrices
    frontal_all = zeros(length(allfilesEpochs), size(EEG.data, 2) + 2); % +2: partID, city_nr
    pariet_all = zeros(length(allfilesEpochs), size(EEG.data, 2) + 2);
    po_all = zeros(length(allfilesEpochs), size(EEG.data, 2) + 2);
    o_all = zeros(length(allfilesEpochs), size(EEG.data, 2) + 2);

for n=1:length(allfilesEpochs)  
     loadName = allfilesEpochs(n).name;
     EEG = pop_loadset('filename',loadName);
     
     partID=loadName(5:6);
     cityName = loadName(12);
     
     
     %cluster electrodes in the frontal region
    front_data = EEG.data( front_chanIndex, :, : );
    front_data_mean = mean(front_data,1);
    
     %average all trials
    front_data_mean_trial = mean(front_data_mean,3);
    %add partID and city information
    front_data_mean_trial (end+1) = str2double(partID);
    front_data_mean_trial (end+1) = str2double(cityName);
    %append epoch rows
    frontal_all(n,:) = front_data_mean_trial;

    
        %cluster electrodes in the parietal region
    pariet_data = EEG.data( pariet_chanIndex, :, : );
    pariet_data_mean = mean(pariet_data, 1);
    
    %average all trials
    pariet_data_mean_trial = mean(pariet_data_mean,3);   
    %add partID and city information
    pariet_data_mean_trial (end+1) = str2double(partID);;
    pariet_data_mean_trial (end+1) = str2double(cityName);
    pariet_all(n,:) = pariet_data_mean_trial;
    
        %cluster electrodes in the parietal-occipital region
    po_data = EEG.data( po_chanIndex, :, : );
    po_data_mean = mean(po_data, 1);
    
    %average all trials
    po_data_mean_trial = mean(po_data_mean,3);   
    %add partID and city information
    po_data_mean_trial (end+1) = str2double(partID);;
    po_data_mean_trial (end+1) = str2double(cityName);
    po_all(n,:) = po_data_mean_trial;
    
    %cluster electrodes in the occipital region
    o_data = EEG.data( o_chanIndex, :, : );
    o_data_mean = mean(o_data, 1);
    
    %average all trials
    o_data_mean_trial = mean(o_data_mean,3);   
    %add partID and city information
    o_data_mean_trial (end+1) = str2double(partID);;
    o_data_mean_trial (end+1) = str2double(cityName);
    o_all(n,:) = o_data_mean_trial;
    
end

%append landmark condition information in the end column
mapLMs = readtable('D:\EEG_2022\scripts\City_LMsForMatlab.txt');
mapLMs = table2array(mapLMs);
mapLMs(mapLMs(:,:,:)== 72, :, :)= [];  % remove part 72
frontal_all = [frontal_all mapLMs(:,3)] ;
pariet_all = [pariet_all mapLMs(:,3)] ;
po_all = [po_all mapLMs(:,3)] ;
o_all = [o_all mapLMs(:,3)] ;
% 
% % write to table for later use
% tablePath = 'D:\EEG_2022\ERP\';
% T_frontal = array2table(frontal_all);
% writetable(T_frontal, [tablePath 'erp_fc.csv'],'Delimiter',',');
% 
% T_pariet = array2table(pariet_all);
% writetable(T_pariet, [tablePath 'erp_pariet.csv'],'Delimiter',',');
% 
% T_po = array2table(po_all);
% writetable(T_po, [tablePath 'erp_po.csv'],'Delimiter',',');
% 
% T_o = array2table(po_all);
% writetable(T_po, [tablePath 'erp_o.csv'],'Delimiter',',');


%% plotting data for the papers

%frontal-centeral 
frontal_all_3LM =  frontal_all(frontal_all(:,end) == 3,:);
frontal_all_5LM =  frontal_all(frontal_all(:,end) == 5,:);
frontal_all_7LM =  frontal_all(frontal_all(:,end) == 7,:);

%pariet
pariet_all_3LM =  pariet_all(pariet_all(:,end) == 3,:);
pariet_all_5LM =  pariet_all(pariet_all(:,end) == 5,:);
pariet_all_7LM =  pariet_all(pariet_all(:,end) == 7,:);

%po
po_all_3LM =  po_all(po_all(:,end) == 3,:);
po_all_5LM =  po_all(po_all(:,end) == 5,:);
po_all_7LM =  po_all(po_all(:,end) == 7,:);


%o
o_all_3LM =  o_all(o_all(:,end) == 3,:);
o_all_5LM =  o_all(o_all(:,end) == 5,:);
o_all_7LM =  o_all(o_all(:,end) == 7,:);


% plot parietal-occipital region
f=figure;
hold on;
xline(0, 'Color', 'k', 'LineWidth', 1.5); hold on;
yline(0, 'Color', 'k', 'LineWidth', 1.5);

patch([450 700 700 450], [-5.99 -5.99 4.99 4.99], [0.8, 0.8, 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none');


plot(EEG.times, mean(po_all_3LM(:, 1:end-3),1), 'LineStyle', ':', 'Color', [0.4, 0.4, 0.4], 'Linewidth', 2);
plot(EEG.times, mean(po_all_5LM(:, 1:end-3),1), 'LineStyle', '--', 'Color', [0.4, 0.4, 0.4], 'Linewidth', 2);
plot(EEG.times, mean(po_all_7LM(:, 1:end-3),1), 'Color', [0.63, 0.13, 0.94], 'Linewidth', 2.5);
axis([-200 1000 -6 5])

ax = gca;
ax.LineWidth = 2;
ax.FontName = 'Arial';
ax.FontSize = 24;
ax.XLabel.String = 'Time (ms)';
ax.YLabel.String = 'Amplitude (\muV)';
ax.YLabel.FontSize = 24;
ax.XAxis.TickValues = [-200:200:1000];
ax.YAxis.TickValues = [-6:2:6];
lgd = legend('', '', '', '3 Landmarks', '5 Landmarks', '7 Landmarks', 'Orientation', 'vertical');
legend('boxoff');
%title('Parieto-Occipital');

f.Position = [100 100 700 700];% set graph size

saveas(f,'po_ERP','png')


% plot occipital region
f2=figure;

xline(0, 'Color', 'k', 'LineWidth', 1.5); hold on;
yline(0, 'Color', 'k', 'LineWidth', 1.5);

patch([80 170 170 80], [-5.99 -5.99 4.99 4.99], [0.8, 0.8, 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
hold on;

plot(EEG.times, mean(o_all_3LM(:, 1:end-3),1), 'LineStyle', ':', 'Color', [0.4, 0.4, 0.4], 'Linewidth', 2);
hold on; plot(EEG.times, mean(o_all_5LM(:, 1:end-3),1),'LineStyle', '--', 'Color', [0.4, 0.4, 0.4], 'Linewidth', 2);
hold on; plot(EEG.times, mean(o_all_7LM(:, 1:end-3),1), 'Color', [0.4, 0.4, 0.4], 'Linewidth', 2);
axis([-200 1000 -6 5])


ax = gca;
ax.LineWidth = 2;
ax.FontName = 'Arial';
ax.FontSize = 24;
ax.XLabel.String = 'Time (ms)';
%ax.YLabel.String = 'Amplitude (\muV)';
ax.YLabel.FontSize = 24;
ax.XAxis.TickValues = [-200:200:1000];
ax.YAxis.TickValues = [-6:2:6];
lgd = legend('', '', '', '3 Landmarks', '5 Landmarks', '7 Landmarks', 'Orientation', 'vertical')
legend('boxoff');
%title('Occipital');

f2.Position = [100 100 700 700]% set graph size


saveas(f2,'o_ERP','png')


%% detect peaks: amp & lat

preStimTime= 1000; %in ms

% P2 at frontal region
frontal.peak2.t1 = 200;
frontal.peak2.t2 = 400;

% n2 at frontal region
frontal.n2.t1 = 450;
frontal.n2.t2 = 600;

                    % get start time in sample points
                    t1 = round( (preStimTime+frontal.n2.t1)/4) + 1; %4: 1000/samplingrate ; +1: 0ms -> position 1
                    % get end time in sample points
                    t2 = round( (preStimTime+frontal.n2.t1)/4) + 1;
                    range = frontal_all(:,t1:t2);
                    % peak detection
                    %[amp, lat] = max(range,[],2); 
                    [amp, lat] = min(range,[],2); 
                    realLat = lat + t1 - 1;
                    
                    %meanAmp = mean(frontal_all(:, t1:t2),2);
                    
                    meanAmp= [];
                    %define peak amplitude as mean of the maximum +/- 1 samplepoints (3 data sample points) 
                    
                    for i = 1: length(realLat)
                        meanAmp(i) = mean(frontal_all(i, realLat(i)-1:realLat(i)+1),2);
                    end
                    meanAmp = meanAmp';
                    
                    %write computed amplitude and latence in struct
                    %frontal.peak(2).amp = meanAmp;%peak_detection.peak_localmax;%
                    %frontal.peak(2).lat = realLat*4-latCorrect-1000;
                    peak_lat = realLat*4-1000;
                    % write computed amplitude and latence in array
                    %ERP(counter,6+6*i3) = meanAmp;%peak_detection.peak_localmax;%
                    %ERP(counter,7+6*i3) = subject(1,Index).electrode(electrodeCentralLine).Peak(1).lat;


front_peak = [meanAmp peak_lat frontal_all(:, end-2:end)];

tablePath = 'D:\EEG_2022\ERP\';
T_frontal_peak = array2table(front_peak);
writetable(T_frontal_peak, [tablePath 'erp_fc_fz_n2.csv'],'Delimiter',',');


% P3 at parietal region

preStimTime= 1000; %in ms
pariet.peak3.t1 = 450;
pariet.peak3.t2 = 700;



                    % get start time in sample points
                    t1 = round( (preStimTime+pariet.peak3.t1)/4) + 1; %4: 1000/samplingrate ; +1: 0ms -> position 1
                    % get end time in sample points
                    t2 = round( (preStimTime+pariet.peak3.t2)/4) + 1;
                    range = pariet_all(:,t1:t2);
                    % peak detection
                    [amp, lat] = max(range,[],2); 
                    
                    realLat = lat + t1 - 1;
                    
                    %meanAmp = mean(pariet_all(:, t1:t2),2);
                    %define peak amplitude as mean of the maximum +/- 1 samplepoints (3 data sample points) 
                      meanAmp= [];
                    %define peak amplitude as mean of the maximum +/- 1 samplepoints (3 data sample points) 
                    for i = 1: length(realLat)
                        meanAmp(i) = mean(pariet_all(i, realLat(i)-1:realLat(i)+1),2);
                    end
                    meanAmp= meanAmp';
                    % write computed amplitude and latence in struct
                    %frontal.peak(2).amp = meanAmp;%peak_detection.peak_localmax;%
                    %frontal.peak(2).lat = realLat*4-latCorrect-1000;
                    peak_lat = realLat*4-1000;
                    % write computed amplitude and latence in array
                    %ERP(counter,6+6*i3) = meanAmp;%peak_detection.peak_localmax;%
                    %ERP(counter,7+6*i3) = subject(1,Index).electrode(electrodeCentralLine).Peak(1).lat;


pariet_peak = [meanAmp peak_lat pariet_all(:, end-2:end)];

tablePath = 'D:\EEG_2022\ERP\';
T_pariet_peak = array2table(pariet_peak);
writetable(T_pariet_peak, [tablePath 'erp_pariet_p3.csv'],'Delimiter',',');

% Peaks at parietal-occipital region

preStimTime= 1000; %in ms
po.p3.t1 = 450;
po.p3.t2 = 700;

po.n2.t1 = 200;
po.n2.t2 = 400;

po.p1.t1 = 50;
po.p1.t2 = 200;

%                     % get start time in sample points
%                     t1 = round( (preStimTime+po.peak3.t1)/4) + 1; %4: 1000/samplingrate ; +1: 0ms -> position 1
%                     % get end time in sample points
%                     t2 = round( (preStimTime+po.peak3.t2)/4) + 1;
                    
                                        % get start time in sample points
                    t1 = round( (preStimTime+po.p3.t1)/4) + 1; %4: 1000/samplingrate ; +1: 0ms -> position 1
                    % get end time in sample points
                    t2 = round( (preStimTime+po.p3.t1)/4) + 1;
                    range = po_all(:,t1:t2);
                    % peak detection
                    [amp, lat] = max(range,[],2); 
                     %[amp, lat] = min(range,[],2); 
                    realLat = lat + t1 - 1;
                    
                    meanAmp = mean(po_all(:, t1:t2),2);
                    
                    %define peak amplitude as mean of the maximum +/- 1 samplepoints (3 data sample points) 
                   meanAmp= [];
                    for i = 1: length(realLat)
                        meanAmp(i) = mean(po_all(i, realLat(i)-1:realLat(i)+1),2);
                    end
                    meanAmp= meanAmp';
                    % write computed amplitude and latence in struct
                    %frontal.peak(2).amp = meanAmp;%peak_detection.peak_localmax;%
                    %frontal.peak(2).lat = realLat*4-latCorrect-1000;
                    peak_lat = realLat*4-1000;
                    % write computed amplitude and latence in array
                    %ERP(counter,6+6*i3) = meanAmp;%peak_detection.peak_localmax;%
                    %ERP(counter,7+6*i3) = subject(1,Index).electrode(electrodeCentralLine).Peak(1).lat;


po_peak = [meanAmp peak_lat po_all(:, end-2:end)];

tablePath = 'D:\EEG_2022\ERP\';
T_po_peak = array2table(po_peak);
writetable(T_po_peak, [tablePath 'erp_po_p3.csv'],'Delimiter',',');

% P1 at occipital region
o.p1.t1 = 80;
o.p1.t2 = 170;

                    % get start time in sample points
                    t1 = round( (preStimTime+o.p1.t1)/4) + 1; %4: 1000/samplingrate ; +1: 0ms -> position 1
                    % get end time in sample points
                    t2 = round( (preStimTime+o.p1.t2)/4) + 1;
                    range = o_all(:,t1:t2);
                    % peak detection
                    [amp, lat] = max(range,[],2); 
                    
                    realLat = lat + t1 - 1;
                    %define peak amplitude as mean of the maximum +/- 1 samplepoints (3 data sample points) 
                  % meanAmp = mean(o_all(:, t1:t2),2);
                    meanAmp= [];
                    for i = 1: length(realLat)
                        meanAmp(i) = mean(o_all(i, realLat(i)-1:realLat(i)+1),2);
                   end
                    
                   meanAmp= meanAmp';
                    % write computed amplitude and latence in struct
                    %frontal.peak(2).amp = meanAmp;%peak_detection.peak_localmax;%
                    %frontal.peak(2).lat = realLat*4-latCorrect-1000;
                    peak_lat = realLat*4-1000;
                    % write computed amplitude and latence in array
                    %ERP(counter,6+6*i3) = meanAmp;%peak_detection.peak_localmax;%
                    %ERP(counter,7+6*i3) = subject(1,Index).electrode(electrodeCentralLine).Peak(1).lat;


o_peak = [meanAmp peak_lat o_all(:, end-2:end)];

tablePath = 'D:\EEG_2022\ERP\';
T_o_peak = array2table(o_peak);
writetable(T_o_peak, [tablePath 'erp_o_p1.csv'],'Delimiter',',');


% P2 at occipital region
o.peak1.t1 = 50;
o.peak1.t2 = 200;

o.n2.t1 = 50;
o.n2.t2 = 200;

o.peak3.t1 = 450;
o.peak3.t2 = 700;

                    % get start time in sample points
                    t1 = round( (preStimTime+o.n2.t1)/4) + 1; %4: 1000/samplingrate ; +1: 0ms -> position 1
                    % get end time in sample points
                    t2 = round( (preStimTime+o.n2.t2)/4) + 1;
                    range = o_all(:,t1:t2);
                    % peak detection
                    %[amp, lat] = max(range,[],2); 
                    [amp, lat] = min(range,[],2); 
                    
                    realLat = lat + t1 - 1;
                    %define peak amplitude as mean of the maximum +/- 1 samplepoints (3 data sample points) 
                  % meanAmp = mean(o_all(:, t1:t2),2);
                    meanAmp= [];
                    for i = 1: length(realLat)
                        meanAmp(i) = mean(o_all(i, realLat(i)-1:realLat(i)+1),2);
                   end
                    
                   meanAmp= meanAmp';
                    % write computed amplitude and latence in struct
                    %frontal.peak(2).amp = meanAmp;%peak_detection.peak_localmax;%
                    %frontal.peak(2).lat = realLat*4-latCorrect-1000;
                    peak_lat = realLat*4-1000;
                    % write computed amplitude and latence in array
                    %ERP(counter,6+6*i3) = meanAmp;%peak_detection.peak_localmax;%
                    %ERP(counter,7+6*i3) = subject(1,Index).electrode(electrodeCentralLine).Peak(1).lat;


o_peak = [meanAmp peak_lat o_all(:, end-2:end)];

tablePath = 'D:\EEG_2022\ERP\';
T_o_peak = array2table(o_peak);
writetable(T_o_peak, [tablePath 'erp_o_p2.csv'],'Delimiter',',');

%% plotting data -- old

% plot data based on conditions
%frontal 
frontal_all_3LM =  frontal_all(frontal_all(:,end) == 3,:);
frontal_all_5LM =  frontal_all(frontal_all(:,end) == 5,:);
frontal_all_7LM =  frontal_all(frontal_all(:,end) == 7,:);

%pariet
pariet_all_3LM =  pariet_all(pariet_all(:,end) == 3,:);
pariet_all_5LM =  pariet_all(pariet_all(:,end) == 5,:);
pariet_all_7LM =  pariet_all(pariet_all(:,end) == 7,:);

%po
po_all_3LM =  po_all(po_all(:,end) == 3,:);
po_all_5LM =  po_all(po_all(:,end) == 5,:);
po_all_7LM =  po_all(po_all(:,end) == 7,:);


%o
o_all_3LM =  o_all(o_all(:,end) == 3,:);
o_all_5LM =  o_all(o_all(:,end) == 5,:);
o_all_7LM =  o_all(o_all(:,end) == 7,:);

% plot frontal region
figure1 = figure;
axes1 = axes('Parent', figure1);
hold(axes1,'on');
rectangle('Parent',axes1,'Position', [200 -5.99 150 12.99], 'EdgeColor','w', 'FaceColor', [.75 .75 .75])
hold on;
plot(EEG.times, mean(frontal_all_3LM(:, 1:end-3),1), 'Color','#77AC30', 'LineWidth',2);
hold on; plot(EEG.times, mean(frontal_all_5LM(:, 1:end-3),1), 'Color','#0072BD', 'LineWidth',2);
hold on; plot(EEG.times, mean(frontal_all_7LM(:, 1:end-3),1), 'Color','#D95319', 'LineWidth',2);
axis([-200 1000 -6 7])
title('Frontal ERP')
set(gcf,'position',[200,1,600,600])
legend('3LM','5LM', '7LM');
xlabel('Latency (ms)') 
ylabel('Amplitude (μV)') 
saveas(gcf,'fc_ERP','png')


% plot parietal-occipital region
figure1 = figure;
axes1 = axes('Parent', figure1);
hold(axes1,'on');
rectangle('Parent',axes1,'Position', [400 -5.99 300 12.99], 'EdgeColor','w', 'FaceColor', [.75 .75 .75])
hold on;
plot(EEG.times, mean(po_all_3LM(:, 1:end-3),1), 'Color','#77AC30', 'LineWidth',2);
hold on; plot(EEG.times, mean(po_all_5LM(:, 1:end-3),1), 'Color','#0072BD', 'LineWidth',2);
hold on; plot(EEG.times, mean(po_all_7LM(:, 1:end-3),1), 'Color','#D95319', 'LineWidth',2);
axis([-200 1000 -6 7])
title('PO ERP')
set(gcf,'position',[200,1,600,600])
legend('3LM','5LM', '7LM');
saveas(gcf,'po_ERP','png')



% plot occipital region
figure1 = figure;
axes1 = axes('Parent', figure1);
hold(axes1,'on');
rectangle('Parent',axes1,'Position', [50 -5.99 150 12.99], 'EdgeColor','w', 'FaceColor', [.75 .75 .75])
hold on;
plot(EEG.times, mean(o_all_3LM(:, 1:end-3),1), 'Color','#77AC30', 'LineWidth',2);
hold on; plot(EEG.times, mean(o_all_5LM(:, 1:end-3),1), 'Color','#0072BD', 'LineWidth',2);
hold on; plot(EEG.times, mean(o_all_7LM(:, 1:end-3),1), 'Color','#D95319', 'LineWidth',2);
axis([-200 1000 -6 7])
title('occipital ERP')
set(gcf,'position',[200,1,600,600])
saveas(gcf,'occipitalERP','png')
legend('3LM','5LM', '7LM')

% plot parietal region
figure1 = figure;
axes1 = axes('Parent', figure1);
hold(axes1,'on');
rectangle('Parent',axes1,'Position', [500 -5.99 150 12.99], 'EdgeColor','w', 'FaceColor', [.75 .75 .75])
hold on;
plot(EEG.times, mean(pariet_all_3LM(:, 1:end-3),1), 'Color','#77AC30', 'LineWidth',2);
hold on; plot(EEG.times, mean(pariet_all_5LM(:, 1:end-3),1), 'Color','#0072BD', 'LineWidth',2);
hold on; plot(EEG.times, mean(pariet_all_7LM(:, 1:end-3),1), 'Color','#D95319', 'LineWidth',2);
axis([-200 1000 -6 7])
title('parietal ERP')
set(gcf,'position',[200,1,600,600])
legend('3LM','5LM', '7LM');
saveas(gcf,'parietalERP','png')

%%% add std curves -> failed at stdfills = fill(x2, inBetween);
% figure;
% x=EEG.times;
% std_3LM = std(frontal_all_3LM(:, 1:end-3),1);
% std_5LM = std(frontal_all_5LM(:, 1:end-3),1);
% std_7LM = std(frontal_all_7LM(:, 1:end-3),1);
% curve1 = mean(frontal_all_3LM(:, 1:end-3) + std_3LM, 1);
% plot(x, curve1, 'r', 'LineWidth', 2);
% hold on;
% curve2 = mean(frontal_all_3LM(:, 1:end-3) - std_3LM, 1);
% plot(x, curve2, 'b', 'LineWidth', 2);
% hold on;
% x2 = [EEG.times, fliplr(EEG.times)];
% inBetween = [curve1, fliplr(curve2)];
% stdfills = fill(x2, inBetween);
% set(stdfills, 'facealpha', .25, 'Color','#77AC30'); %Specify the FaceAlpha property for each hexagon as a value less than 1 to plot semitransparent hexagons.
% hold on;

%% plot single subject
% plot frontal region
figure1 = figure;
axes1 = axes('Parent', figure1);
hold(axes1,'on');
rectangle('Parent',axes1,'Position', [200 -5.99 150 12.99], 'EdgeColor','w', 'FaceColor', [.75 .75 .75])
hold on;
plot(EEG.times, frontal_all(2, 1:end-3));

axis([-200 1000 -6 7])
title('Frontal ERP')
set(gcf,'position',[200,1,600,600])
legend('3LM','5LM', '7LM');
xlabel('Latency (ms)') 
ylabel('Amplitude (μV)') 
saveas(gcf,'frontalERP','png')
