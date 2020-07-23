% pidPR Read

clear; clc;

% read csv
file = 'pidPitchRoll-20190503T14-42-01.csv';   % << INPUT FILENAME
T = readtable(file);  %2nd in time

file = 'pidPitchRoll-20190503T14-10-18.csv';   % << INPUT FILENAME
M = readtable(file);

% unpack log blocks
t = T.Timestamp/1000;  % milliseconds to seconds
d = T.pid_rate_roll_outD;
i = T.pid_rate_roll_outI;
p = T.pid_rate_roll_outP;

tm = M.Timestamp/1000;  % milliseconds to seconds
dm = M.pid_rate_roll_outD;
im = M.pid_rate_roll_outI;
pm = M.pid_rate_roll_outP;

% plotting ---------------------------------------------------------------

%bounds = [61.6 63.6 0 7e4];  % << INPUT BOUNDS

% hold on
% grid on
% plot(t, pwm1, '-b')
% meanpwm1 = movmean(pwm1,5);
% plot(t, meanpwm1, '-k')
% axis(bounds)
% %legend('m1', 'pwm1')
% hold off


% add up all the motor values, divide by 100 to make it more comparable to
% battery data... a qualitative valie
% qualm = (d+i+p+m4)/100;

figure;
hold on
grid on
% plot(t, qualm)
% plot(t, d)
% plot(t, i)
plot(t, p)

% plot(tm, dm)
% plot(tm, im)
plot(tm, pm)

legend('2nd in time','1st in time')



%axis(bounds)
%legend('m1', 'm2', 'm3', 'm4')
hold off


