%% detect peaks: amp & lat
clear

%Loading data arrays for analysis
load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\3LdmrkFCz_Nav_new.mat');
load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\3LdmrkFz_Nav_new.mat');
load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\3LdmrkOz_Nav_new.mat');
load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\3LdmrkPOz_Nav_new.mat');
load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\3LdmrkPz_Nav_new.mat');
load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\5LdmrkFCz_Nav_new.mat');
load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\5LdmrkFz_Nav_new.mat');
load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\5LdmrkOz_Nav_new.mat');
load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\5LdmrkPOz_Nav_new.mat');
load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\5LdmrkPz_Nav_new.mat');
load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\7LdmrkFCz_Nav_new.mat');
load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\7LdmrkFz_Nav_new.mat');
load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\7LdmrkOz_Nav_new.mat');
load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\7LdmrkPOz_Nav_new.mat');
load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\7LdmrkPz_Nav_new.mat');

%Epoch rejected
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\3LdmrkFCz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\3LdmrkFz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\3LdmrkOz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\3LdmrkPOz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\3LdmrkPz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\5LdmrkFCz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\5LdmrkFz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\5LdmrkOz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\5LdmrkPOz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\5LdmrkPz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\7LdmrkFCz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\7LdmrkFz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\7LdmrkOz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\7LdmrkPOz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\7LdmrkPz_Nav_epRej.mat');

%For sub 51
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\51_3LdmrkFCz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\51_3LdmrkFz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\51_3LdmrkOz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\51_3LdmrkPOz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\51_3LdmrkPz_Nav_epRej.mat');

% % For sub 69
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_5LdmrkFCz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_5LdmrkFz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_5LdmrkOz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_5LdmrkPOz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_5LdmrkPz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_7LdmrkFCz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_7LdmrkFz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_7LdmrkOz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_7LdmrkPOz_Nav_epRej.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_7LdmrkPz_Nav_epRej.mat');

%Epoch rejected with 5 SD
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\3LdmrkFCz_Nav_epRej5SD.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\3LdmrkFz_Nav_epRej5SD.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\3LdmrkOz_Nav_epRej5SD.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\3LdmrkPOz_Nav_epRej5SD.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\3LdmrkPz_Nav_epRej5SD.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\5LdmrkFCz_Nav_epRej5SD.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\5LdmrkFz_Nav_epRej5SD.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\5LdmrkOz_Nav_epRej5SD.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\5LdmrkPOz_Nav_epRej5SD.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\5LdmrkPz_Nav_epRej5SD.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\7LdmrkFCz_Nav_epRej5SD.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\7LdmrkFz_Nav_epRej5SD.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\7LdmrkOz_Nav_epRej5SD.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\7LdmrkPOz_Nav_epRej5SD.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\7LdmrkPz_Nav_epRej5SD.mat');


% threeLdMrk_Fz_dec = threeLdMrk_Fz_dec_epRej;
% threeLdMrk_Oz_dec = threeLdMrk_Oz_dec_epRej;
% threeLdMrk_Fcz_dec = threeLdMrk_Fcz_dec_epRej;
% threeLdMrk_Pz_dec = threeLdMrk_Pz_dec_epRej;
% threeLdMrk_Poz_dec = threeLdMrk_Poz_dec_epRej;

% fiveLdMrk_Fz_dec = fiveLdMrk_Fz_dec_epRej;  
% fiveLdMrk_Oz_dec = fiveLdMrk_Oz_dec_epRej;
% fiveLdMrk_Fcz_dec = fiveLdMrk_Fcz_dec_epRej;
% fiveLdMrk_Pz_dec = fiveLdMrk_Pz_dec_epRej;
% fiveLdMrk_Poz_dec = fiveLdMrk_Poz_dec_epRej;
% 
% sevenLdMrk_Fz_dec = sevenLdMrk_Fz_dec_epRej;  
% sevenLdMrk_Oz_dec = sevenLdMrk_Oz_dec_epRej;
% sevenLdMrk_Fcz_dec = sevenLdMrk_Fcz_dec_epRej;
% sevenLdMrk_Pz_dec = sevenLdMrk_Pz_dec_epRej;
% sevenLdMrk_Poz_dec = sevenLdMrk_Poz_dec_epRej;

%For sub 51
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\51_3LdmrkFCz_Nav_new.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\51_3LdmrkFz_Nav_new.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\51_3LdmrkOz_Nav_new.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\51_3LdmrkPOz_Nav_new.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\51_3LdmrkPz_Nav_new.mat');
%
% % For sub 69
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_5LdmrkFCz_Nav_new.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_5LdmrkFz_Nav_new.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_5LdmrkOz_Nav_new.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_5LdmrkPOz_Nav_new.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_5LdmrkPz_Nav_new.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_7LdmrkFCz_Nav_new.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_7LdmrkFz_Nav_new.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_7LdmrkOz_Nav_new.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_7LdmrkPOz_Nav_new.mat');
% load('C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis\69_7LdmrkPz_Nav_new.mat');

tablePath = 'C:\Users\Enru\Documents\Postdoc UZH\Bingjie_Data\5_single-subject-EEG-analysis';
fields = {'FC', 'PO', 'Oz'};
%fields = {'PO'};
peaks = {'N2', 'P3', 'N1'};
%peaks = {'P2', 'N2'};
LM_conds = [3 5 7];



subs = [28:50 52:54 56:68 70:71 73:76];
%subs = 51;
%subs = 69;

LMM_table = table;   %setting LMM table

preStimTime= 500; %in ms

%N2 in FC
electr(1).t1 = 250;
electr(1).t2 = 390;

%P300 in PO
electr(2).t1 = 250;
electr(2).t2 = 340;

%P2 in PO
% electr(2).peak(1).t1 = 180;
% electr(2).peak(1).t2 = 212;
% 
% %N2 in PO
% electr(2).peak(2).t1 = 212;
% electr(2).peak(2).t2 = 248;

%P1 in occipital region
electr(3).t1 = 110;
electr(3).t2 = 150;

temp_FC3 = cat(3, threeLdMrk_Fcz_dec, threeLdMrk_Fz_dec);      %stacking FCz and Fz for 3-landmark condition to take composite of fronto-central region
cond(1).elec(1).ERPs = mean(temp_FC3, 3);                      %taking the average of the matrices in the 3rd dimension

temp_FC5 = cat(3, fiveLdMrk_Fcz_dec, fiveLdMrk_Fz_dec);
cond(2).elec(1).ERPs = mean(temp_FC5, 3);

temp_FC7 = cat(3, sevenLdMrk_Fcz_dec, sevenLdMrk_Fz_dec);
cond(3).elec(1).ERPs = mean(temp_FC7, 3);

temp_PO3 = cat(3, threeLdMrk_Oz_dec, threeLdMrk_Poz_dec, threeLdMrk_Pz_dec);
cond(1).elec(2).ERPs = mean(temp_PO3, 3);                     %averaging Pz, Oz, and POz for 3-landmark condition

temp_PO5 = cat(3, fiveLdMrk_Oz_dec, fiveLdMrk_Poz_dec, fiveLdMrk_Pz_dec);
cond(2).elec(2).ERPs = mean(temp_PO5, 3);

temp_PO7 = cat(3, sevenLdMrk_Oz_dec, sevenLdMrk_Poz_dec, sevenLdMrk_Pz_dec);
cond(3).elec(2).ERPs = mean(temp_PO7, 3);

cond(1).elec(3).ERPs = threeLdMrk_Oz_dec;
cond(2).elec(3).ERPs = fiveLdMrk_Oz_dec;
cond(3).elec(3).ERPs = sevenLdMrk_Oz_dec;

for el = 1:length(electr)      %number of electrodes of interest
    % get start time in sample points
    t1 = round((preStimTime + electr(el).t1)/4) + 1; %4: 1000/samplingrate ; +1: 0ms -> position 1
    
    % get end time in sample points
    t2 = round((preStimTime + electr(el).t2)/4) + 1;
    
    %for pk = 1:2   %extra loop is only for P2 and N2 in PO
%         t1 = round((preStimTime + electr(el).peak(pk).t1)/4) + 1; %4: 1000/samplingrate ; +1: 0ms -> position 1
%         
%         % get end time in sample points
%         t2 = round((preStimTime + electr(el).peak(pk).t2)/4) + 1;
        
        for conds = 1:3
            meanAmp = [];
            range = cond(conds).elec(el).ERPs(:, t1:t2);
            % peak detection
            if el == 1 || el == 3 %if region is fronto-central or Oz, then it's N2 or N1 so find minimum
                [temp_amp, temp_lat] = min(range,[], 2);
            else       %for PO regions then find maximum
                [temp_amp, temp_lat] = max(range,[], 2);
            end
            % peak detection only for P2 and N2 in PO
%             if pk == 1   %P2 so find max
%                 [temp_amp, temp_lat] = max(range,[], 2);
%             elseif pk == 2  %N2 so find min
%                 [temp_amp, temp_lat] = min(range,[], 2);
%             end
            %define peak amplitude as mean of the maximum +/- 1 samplepoints (3 data sample points)
            realLat = temp_lat + t1 - 1;
            for i = 1:length(realLat)
                meanAmp(i, 1) = mean(cond(conds).elec(el).ERPs(i, realLat(i)-1:realLat(i)+1),2);
            end
            
            tempt = table(subs', repmat(fields{el}, length(meanAmp), 1), repmat(LM_conds(conds), length(meanAmp), 1), repmat(peaks{el}, length(meanAmp), 1), meanAmp,...
                'VariableNames',{'partID', 'channel', 'mapLMs', 'peaks', 'meanAmp'});
            
            %For P2 and N2 in PO
%             tempt = table(subs', repmat(fields, length(meanAmp), 1), repmat(LM_conds(conds), length(meanAmp), 1), repmat(peaks{pk}, length(meanAmp), 1), meanAmp,...
%                 'VariableNames',{'partID', 'channel', 'mapLMs', 'peaks', 'meanAmp'});
            
            %for subs 51 and 69. not writing regions and peaks into the table because
            %Matlab complains about entering strings into tables when there's
            %only one line
%                     tempt = table(subs, LM_conds(conds), meanAmp,...
%                         'VariableNames',{'partID', 'mapLMs', 'meanAmp'});
            
            LMM_table = [LMM_table; tempt];
        end
   %end
end
writetable(LMM_table,[tablePath, '\navBlinks_ERPs_epRej5SD_LMM.csv'],'Delimiter',',');
%% Plotting (used for paper)
%grouping Fz and FCz together
frontN2 = NaN(6, length(threeLdMrk_Fcz_dec));
frontN2(1, :) = mean(threeLdMrk_Fcz_dec);  %first 2 rows are the 3 landmark condition
frontN2(2, :) = mean(threeLdMrk_Fz_dec);
frontN2(3, :) = mean(fiveLdMrk_Fcz_dec);     
frontN2(4, :) = mean(fiveLdMrk_Fz_dec);
frontN2(5, :) = mean(sevenLdMrk_Fcz_dec);
frontN2(6, :) = mean(sevenLdMrk_Fz_dec);
frontN2_3_SE = std(frontN2(1:2,:)) / sqrt(length(subs));
frontN2_5_SE = std(frontN2(3:4,:)) / sqrt(length(subs));
frontN2_7_SE = std(frontN2(5:6,:)) / sqrt(length(subs));

%Grouping Oz, POz, and Pz together
ParOccP3 = NaN(9, length(threeLdMrk_Fcz_dec));
ParOccP3(1, :) = mean(threeLdMrk_Oz_dec);
ParOccP3(2, :) = mean(threeLdMrk_Poz_dec);
ParOccP3(3, :) = mean(threeLdMrk_Pz_dec);
ParOccP3(4, :) = mean(fiveLdMrk_Oz_dec);
ParOccP3(5, :) = mean(fiveLdMrk_Poz_dec);
ParOccP3(6, :) = mean(fiveLdMrk_Pz_dec);
ParOccP3(7, :) = mean(sevenLdMrk_Oz_dec);
ParOccP3(8, :) = mean(sevenLdMrk_Poz_dec);
ParOccP3(9, :) = mean(sevenLdMrk_Pz_dec);

ParOccP3_3_SE = std(ParOccP3(1:3, :)) / sqrt(length(subs));
ParOccP3_5_SE = std(ParOccP3(4:6, :)) / sqrt(length(subs));
ParOccP3_7_SE = std(ParOccP3(7:9, :)) / sqrt(length(subs));

%Plot P1 in Oz
x = [-496:4:2000];
f1 = figure(1);
xline(0, 'Color', 'k', 'LineWidth', 1.5);
hold on
yline(0, 'Color', 'k', 'LineWidth', 1.5);
f1.Position = [100 100 700 700];
patch([110 150 150 110], [-4 -4 3 3], [0.8, 0.8, 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
plot(x, mean(threeLdMrk_Oz_dec), 'Color', [0.4, 0.4, 0.4], 'Linewidth', 2);
plot(x, mean(fiveLdMrk_Oz_dec), 'LineStyle', '--', 'Color', [0.4, 0.4, 0.4], 'Linewidth', 2);
plot(x, mean(sevenLdMrk_Oz_dec), 'Color', 'k', 'Linewidth', 2.5);
legend('', '', '', '3 Landmark', '5 Landmark', '7 Landmark', 'Orientation', 'horizontal', 'FontSize', 24);
legend boxoff
axis([-500 1000 -4 3])
ax = gca;
ax.LineWidth = 2;
ax.FontName = 'Arial';
ax.FontSize = 24;
ax.XLabel.String = 'Time (ms)';
ax.YLabel.String = 'Amplitude (\muV)';
ax.YLabel.FontSize = 24;
ax.XAxis.TickValues = [-500:200:x(end)];
ax.YAxis.TickValues = [-4:2:2];
title('Oz');

f2 = figure(2);
xline(0, 'Color', 'k', 'LineWidth', 1.5);
hold on
yline(0, 'Color', 'k', 'LineWidth', 1.5);
f2.Position = [100 100 700 700];
patch([250 390 390 250], [-2 -2 3 3], [0.8, 0.8, 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
plot(x, mean(frontN2(1:2, :)), 'Color', [0.4, 0.4, 0.4], 'Linewidth', 2);
plot(x, mean(frontN2(3:4, :)), 'LineStyle', '--', 'Color', [0.4, 0.4, 0.4], 'Linewidth', 2);
plot(x, mean(frontN2(5:6, :)), 'Color', 'k', 'Linewidth', 2.5);
axis([-500 1000 -2 3])
ax = gca;
ax.LineWidth = 2;
ax.FontName = 'Arial';
ax.FontSize = 24;
ax.XLabel.String = 'Time (ms)';
ax.YLabel.String = 'Amplitude (\muV)';
ax.YLabel.FontSize = 24;
ax.XAxis.TickValues = [-500:250:x(end)];
ax.YAxis.TickValues = [-2:2:2];
lgd = legend('', '', '', '3 Landmark', '5 Landmark', '7 Landmark', 'Orientation', 'horizontal');
legend boxoff
lgd.FontSize = 24;
%title('Fronto-central');

f3 = figure(3);
xline(0, 'Color', 'k', 'LineWidth', 1.5);
hold on
yline(0, 'Color', 'k', 'LineWidth', 1.5);
f3.Position = [100 100 700 700];
patch([250 340 340 250], [-2 -2 3 3], [0.8, 0.8, 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
plot(x, mean(ParOccP3(1:3, :)), 'Color', [0.4, 0.4, 0.4], 'Linewidth', 2);
plot(x, mean(ParOccP3(4:6, :)), 'LineStyle', '--', 'Color', [0.4, 0.4, 0.4], 'Linewidth', 2);
plot(x, mean(ParOccP3(7:9, :)), 'Color', [0.63, 0.13, 0.94], 'Linewidth', 2.5);
axis([-500 1000 -2 3])
ax = gca;
ax.LineWidth = 2;
ax.FontName = 'Arial';
ax.FontSize = 24;
ax.XLabel.String = 'Time (ms)';
ax.YLabel.String = 'Amplitude (\muV)';
ax.YLabel.FontSize = 24;
ax.XAxis.TickValues = [-500:250:x(end)];
ax.YAxis.TickValues = [-2:2:2];
%lgd = legend('', '', '', '3 Landmark', '5 Landmark', '7 Landmark', 'Orientation', 'horizontal');
%title('Parieto-Occipital');