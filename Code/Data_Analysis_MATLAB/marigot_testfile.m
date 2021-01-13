%% MARIGOT'S TEST FILE

%% WHAT IS WRONG WITH THE CONCAVITY??

x = [1 2 3 4 5 6 7 8 9 10];
y = [1 5 9 12 14 15 15 14 12.5 10.5];

x1 = [1.5 2.5 3.5 4.5 5.5 6.5 7.5 8.5 9.5];
yd = diff(y,1); 
yd_log = diff(log10(y),1); 

x2 = [2 3 4 5 6 7 8 9];
ydd = diff(y,2); 
ydd_log = diff(log10(y),2); 

ydd_log_alt = diff(yd_log,1); 

xchange = ischange(x,'linear')


% CONCAVITY OF LINEAR SCALE
figure(1)

subplot(3,1,1)
plot(x, y)

subplot(3,1,2)
plot(x1, yd)

subplot(3,1,3)
plot(x2, ydd)



% CONCAVITY OF LOG SCALE
figure(2)

subplot(3,1,1)
semilogy(x, y)

subplot(3,1,2)
plot(x1, yd_log)

subplot(3,1,3)
plot(x2, ydd_log)


% CONCAVITY OF LOG SCALE [ALT]
figure(3)

subplot(3,1,1)
semilogy(x, y)

subplot(3,1,2)
plot(x1, yd_log)

subplot(3,1,3)
plot(x2, ydd_log_alt)



%% ANOTHER TRY; DIFFERENT STRAT


x = linspace(-7,5, 100);
y = 2*x.^5 - 5*x.^4 - 20*x.^3 + 30*x.^2 - x + 700;
%y = -3*x.^4 + 0.2*x.^3 - 0.1*x.^2 - x + 1;

sig = [x; y]';

% peakfit(signal,center,window,NumPeaks,peakshape);
[FitResults,GOF,baseline,coeff,residual,xi,yi,BootResults] = peakfit(sig,-1,8,2,5,-0.5);



