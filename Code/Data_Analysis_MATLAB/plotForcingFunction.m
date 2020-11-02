%close all; clc;

cd /Users/bewleylab/Documents/GitHub/Data/
%no wind
%M=csvread("2020-11-01 16:41:57.313245_sine_amp_20cm.csv");
%with wind
%M=csvread("2020-11-01 16:55:35.746241_sine_amp_20cm.csv");
M=csvread("2020-11-01 17:06:46.499779_sine_amp_50cm.csv");
figure
plot(M(1,:),M(2,:));
hold on
yline(0.42-.075+.07+.01);

[~,I]=min(M(4,:));
figure
plot(M(3,1:I-1),M(4,1:I-1));
hold on
yline(0.42-.075+.07+.01);
ylim([.3 .5]);
cd /Users/bewleylab/Documents/GitHub/BATL-flight/Code/Data_Analysis_MATLAB/