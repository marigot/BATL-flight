function [fftMat,rawPeaksMat,fitPeaksMat]=FFTAnalysis(typeOfData,loggedVariable)
%typeOfData: 1=arduino, 2=crazyflie
%loggedVariable: 
%       arduino: 2=power
%       crazyflie: 2=kalman.stateZ, 3=gyro.x (roll), 6=gyro.y (pitch)

global dataMat;
%close all;
%clearvars;
% dataMat=CreateDataMat('/Users/grace/Documents/GitHub/BATL-flight/Data');
% cd /Users/grace/Documents/GitHub/BATL-flight/Code/Data_Analysis_MATLAB

global estFreqsMat;
estFreqsMat=cell(size(dataMat,1)-1,2);
estFreqsMat(:,1)=dataMat(2:end,1);
switch typeOfData
    case 1
        estFreqsMat(1,2)={[1.5]};       %f0-d0
        estFreqsMat(2,2)={[1.5, 4]};    %f10-d3.5
        estFreqsMat(3,2)={[1.5]};       %f13-d0
        estFreqsMat(4,2)={[1.5, 5.75]}; %f13-d3.5
        estFreqsMat(5,2)={[1.5, 6.75]}; %f15-d3.5
    case 2
        switch loggedVariable
            case 2
                estFreqsMat(1,2)={[0.25, 1.25]};%, 22, 23, 44.5, 45.5]};                              %f0-d0
                estFreqsMat(2,2)={[0.25, 1.25]};%, 4]};           %f10-d3.5
                estFreqsMat(3,2)={[0.25, 1.25]};                           %f13-d0  
                estFreqsMat(4,2)={[0.25, 1.25]}; %f13-d3.5
                estFreqsMat(5,2)={[0.25, 1.25]};       %f15-d3.5
            case 3
            case 6
                estFreqsMat(1,2)={[1, 8]};                              %f0-d0
                estFreqsMat(2,2)={[1, 4, 7.75, 12.25, 16.5]};           %f10-d3.5
                estFreqsMat(3,2)={[1, 7.25]};                           %f13-d0  
                estFreqsMat(4,2)={[1, 2.75, 5.75, 6.75 11.5 17.25 23]}; %f13-d3.5
                estFreqsMat(5,2)={[1.5, 5.25, 6.75, 13.75 20.5]};       %f15-d3.5
        end
end

useGradientColors=1;
%figure();  

fftMat=cell(size(dataMat,1),size(dataMat,2));
integPowerMat=cell(size(dataMat,1),size(dataMat,2));
%rawPeaksMat=cell(size(dataMat,1),size(dataMat,2));
fitPeaksMat=cell(size(dataMat,1),size(dataMat,2));
%graph these arrays
graphData=[];   %holds: P,ftunnel,windspeed,diameter,sheddingfreq,apeak,fpeak
for i=2:size(dataMat,1)       %loop through environment
    %subplot(round((size(dataMat,1)-1)/3),3,i-1);
    controllerNames=[""];
    
    fftMat(i,1)=dataMat(i,1);
    integPowerMat(i,1)=dataMat(i,1);
    %rawPeaksMat(i,1)=dataMat(i,1);
    fitPeaksMat(i,1)=dataMat(i,1);
    handles=[];
    
    controllerParsed=strsplit(string(dataMat{i,1}),'-');  %get array of [ftunnel,diameter] from folder name
    controllerFreqTemp=char(controllerParsed(1));
    diameterTemp=char(controllerParsed(2));
    fTunnel=str2double(controllerFreqTemp(2:end));
    diameter=str2double(diameterTemp(2:end));
    windSpeed=0.196*fTunnel+0.103;  %equation from hotwire measurements
    sheddingFreq=.22*windSpeed/(diameter/39.37);  %equation from something idk ask marigot
    
    for j=2:size(dataMat,2)   %loop through controllers
        %totalPowerSum=0;
        %totalPowerDataPoints=0;
        fftMat(1,j)=dataMat(1,j);
        integPowerMat(1,j)=dataMat(1,j);
        rawPeaksMat(1,j)=dataMat(1,j);
        fitPeaksMat(1,j)=dataMat(1,j);
        P1Matrix=[];
%FFT
        for k=2:size(dataMat{i,j},2)   %loop through runs
            if ~isempty(dataMat{i,j}{typeOfData,k})      %make sure that run isn't empty
                powerTimestamp=dataMat{i,j}{typeOfData,k}{2,1};
                powerData=dataMat{i,j}{typeOfData,k}{2,loggedVariable};

                T=mean(diff(powerTimestamp));    %get average timestep between data points
                if typeOfData==2    %crazyflie time data is in ms not s
                    T=T/1000;
                end
                Fs=1/T;     %frequency is 1/T
                dataSize=length(powerData);  %size of both data arrays
                %t=(0:dataSize-1)*T;    %create time vector
                y=fft(detrend(powerData));      %fft of powerData

                P2=abs(y/dataSize);
                P1=P2(1:dataSize/2+1);
                P1(2:end-1)=2*P1(2:end-1);

                f=Fs*(0:(dataSize/2))/dataSize;
                
                P1Matrix(k-1,:)=P1; %#ok<*SAGROW>
            end
        end
        if ~isempty(dataMat{i,j}) && ~isempty(dataMat{i,j}{typeOfData,loggedVariable})     %check if there was any data for this controller and add controller to list of names if yes
            controllerNames=[controllerNames, dataMat{1,j}];
            smoothedData=smooth(mean(P1Matrix),15);%,11,'sgolay',0);     %smooth data //sometimes 15//
            smoothedData=smooth(smoothedData,10);
            smoothedData=smooth(smoothedData,5);
            fftMat(i,j)={[f',smoothedData]}; %save the fft graphed data [f,smoothed data]
        end
    end
end
rawPeaksMat=getRawPeaks(fftMat,typeOfData,loggedVariable);
fitPeaksMat=plotAnalysis(fftMat,rawPeaksMat,typeOfData,loggedVariable,useGradientColors);
%% second graph subplots
% 
% %            1    2        3        4          5         6     7
% %graphData: [P,ftunnel,windspeed,diameter,sheddingfreq,apeak,fpeak]
% 
% figure();
% subplot(2,2,1);
% uniqueShedFreqs=unique(graphData(:,5));
% uniquePs=unique(graphData(:,1));
% numOfSheddingFreqs=length(uniqueShedFreqs);
% numOfPs=length(uniquePs);
% 
% %graph peak frequency vs sheddingfreq
% for i=1:size(graphData,1)
%     c=[1-uniquePs(find(graphData(i,1)==uniquePs))/uniquePs(end) 0 uniquePs(find(graphData(i,1)==uniquePs))/uniquePs(end)];
%     plot(graphData(i,5),graphData(i,7),'x','Color',c,'Linewidth',1.0);
%     hold on;
% end
% handlesPs=[];
% legendPs=[];
% for i=1:length(uniquePs) 
%     c=[1-uniquePs(i)/uniquePs(end) 0 uniquePs(i)/uniquePs(end)];
%     graphX=graphData(find(graphData(:,1)==uniquePs(i)),5);
%     graphY=graphData(find(graphData(:,1)==uniquePs(i)),7);
%     firstPeakX=graphX(find(graphY(:)<2));
%     firstPeakY=graphY(find(graphY(:)<2));
%     secondPeakX=graphX(find(graphY(:)>2));
%     secondPeakY=graphY(find(graphY(:)>2));
%     if useGradientColors==1
%         if ~isempty(firstPeakX(find(~isinf(firstPeakX(:)))))
%             legendPs=[legendPs strcat('P=',string(uniquePs(i)))];
%             hPs=plot(firstPeakX(find(~isinf(firstPeakX(:)))),firstPeakY(find(~isinf(firstPeakX(:)))),'Color',c,'Linewidth',1.0);
%             handlesPs=[handlesPs hPs];
%             hold on;
%             plot(secondPeakX,secondPeakY,'--o','Color',c,'Linewidth',1.0,'HandleVisibility','off');
%         end
%     else
%         if ~isempty(firstPeakX(find(~isinf(firstPeakX(:)))))
%             legendPs=[legendPs strcat('P=',string(uniquePs(i)))];
%             hPs=plot(firstPeakX(find(~isinf(firstPeakX(:)))),firstPeakY(find(~isinf(firstPeakX(:)))),'Linewidth',1.0);
%             handlesPs=[handlesPs hPs];
%             hold on;
%             plot(secondPeakX,secondPeakY,'--o','Linewidth',1.0,'HandleVisibility','off');
%         end
%     end
% end
% legend(handlesPs,legendPs);
% grid on;
% xlabel('f_{v} [Hz]');
% ylabel('f_{peak} [Hz]');
% xlim([5,8]);
% 
% %graph peak amplitude vs sheddingfreq
% subplot(2,2,2);
% for i=1:size(graphData,1)
%     c=[1-uniquePs(find(graphData(i,1)==uniquePs))/uniquePs(end) 0 uniquePs(find(graphData(i,1)==uniquePs))/uniquePs(end)];
%     plot(graphData(i,5),graphData(i,6),'x','Color',c,'Linewidth',1.0);
%     hold on;
% end
% handlesPs=[];
% legendPs=[];
% for i=1:length(uniquePs)
%     c=[1-uniquePs(i)/uniquePs(end) 0 uniquePs(i)/uniquePs(end)];
%     graphX=graphData(find(graphData(:,1)==uniquePs(i)),5);
%     graphY=graphData(find(graphData(:,1)==uniquePs(i)),6);
%     graphPeakFreqs=graphData(find(graphData(:,1)==uniquePs(i)),7);
%     firstPeakX=graphX(find(graphPeakFreqs(:)<2));
%     firstPeakY=graphY(find(graphPeakFreqs(:)<2));
%     secondPeakX=graphX(find(graphPeakFreqs(:)>2));
%     secondPeakY=graphY(find(graphPeakFreqs(:)>2));
%     if useGradientColors==1
%         if ~isempty(firstPeakX(find(~isinf(firstPeakX(:)))))
%             legendPs=[legendPs strcat('P=',string(uniquePs(i)))];
%             hPs=plot(firstPeakX(find(~isinf(firstPeakX(:)))),firstPeakY(find(~isinf(firstPeakX(:)))),'Color',c,'Linewidth',1.0);
%             handlesPs=[handlesPs hPs];
%             plot(secondPeakX,secondPeakY,'--o','Color',c,'Linewidth',1.0,'HandleVisibility','off');
%         end
%     else
%         if ~isempty(firstPeakX(find(~isinf(firstPeakX(:)))))
%             legendPs=[legendPs strcat('P=',string(uniquePs(i)))];
%             hPs=plot(firstPeakX(find(~isinf(firstPeakX(:)))),firstPeakY(find(~isinf(firstPeakX(:)))),'Linewidth',1.0);
%             handlesPs=[handlesPs hPs];
%             plot(secondPeakX,secondPeakY,'--o','Linewidth',1.0,'HandleVisibility','off');
%         end
%     end
% end
% legend(handlesPs,legendPs);
% grid on;
% %set(gca,'XScale','log','YScale','log');
% xlabel('f_{v} [Hz]');
% ylabel('A_{peak}');
% xlim([5,8]);
% 
% %graph peak frequency vs P
% subplot(2,2,3);
% for i=1:size(graphData,1)
%     if ~isinf(uniqueShedFreqs(find(graphData(i,5)==uniqueShedFreqs))) 
%         c=[1-(uniqueShedFreqs(find(graphData(i,5)==uniqueShedFreqs))-uniqueShedFreqs(1))/(uniqueShedFreqs(end-1)-uniqueShedFreqs(1)) ...
%             0 (uniqueShedFreqs(find(graphData(i,5)==uniqueShedFreqs))-uniqueShedFreqs(1))/(uniqueShedFreqs(end-1)-uniqueShedFreqs(1))];
%         plot(graphData(i,1),graphData(i,7),'x','Color',c,'Linewidth',1.0);
%         hold on;
%     end
% end
% handlesShedFreqs=[];
% legendShedFreqs=[];
% for i=1:length(uniqueShedFreqs)-1
%     c=[1-(uniqueShedFreqs(i)-uniqueShedFreqs(1))/(uniqueShedFreqs(end-1)-uniqueShedFreqs(1)) ...
%         0 (uniqueShedFreqs(i)-uniqueShedFreqs(1))/(uniqueShedFreqs(end-1)-uniqueShedFreqs(1))];
%     graphX=graphData(find(graphData(:,5)==uniqueShedFreqs(i)),1);
%     graphY=graphData(find(graphData(:,5)==uniqueShedFreqs(i)),7);
%     firstPeakX=graphX(find(graphY(:)<2));
%     firstPeakY=graphY(find(graphY(:)<2));
%     [firstPeakX,firstPeakIs]=sort(firstPeakX);
%     firstPeakY=firstPeakY(firstPeakIs);
%     secondPeakX=graphX(find(graphY(:)>2));
%     secondPeakY=graphY(find(graphY(:)>2));
%     [secondPeakX,secondPeakIs]=sort(secondPeakX);
%     secondPeakY=secondPeakY(secondPeakIs);
%     if useGradientColors==1
%         if ~isempty(firstPeakX(find(~isinf(firstPeakX(:)))))
%             legendShedFreqs=[legendShedFreqs strcat('f_{v}=',string(uniqueShedFreqs(i)))];
%             hShedFreqs=plot(firstPeakX(find(~isinf(firstPeakX(:)))),firstPeakY(find(~isinf(firstPeakX(:)))),'Color',c,'Linewidth',1.0); %#ok<*FNDSB>
%             handlesShedFreqs=[handlesShedFreqs hShedFreqs]; %#ok<*AGROW>
%             hold on;
%             plot(secondPeakX,secondPeakY,'--o','Color',c,'Linewidth',1.0,'HandleVisibility','off');
%         end
%     else
%         if ~isempty(firstPeakX(find(~isinf(firstPeakX(:)))))
%             legendShedFreqs=[legendShedFreqs strcat('f_{v}=',string(uniqueShedFreqs(i)))];
%             hShedFreqs=plot(firstPeakX(find(~isinf(firstPeakX(:)))),firstPeakY(find(~isinf(firstPeakX(:)))),'Linewidth',1.0);
%             handlesShedFreqs=[handlesShedFreqs hShedFreqs];
%             hold on;
%             plot(secondPeakX,secondPeakY,'--o','Linewidth',1.0,'HandleVisibility','off');
%         end
%     end
% end
% legend(handlesShedFreqs,legendShedFreqs);
% grid on;
% xlabel('P');
% ylabel('f_{peak} [Hz]');
% xlim([0,5.5]);
% 
% %graph peak amplitude vs P
% subplot(2,2,4);
% for i=1:size(graphData,1)
%     if ~isinf(uniqueShedFreqs(find(graphData(i,5)==uniqueShedFreqs))) 
%         c=[1-(uniqueShedFreqs(find(graphData(i,5)==uniqueShedFreqs))-uniqueShedFreqs(1))/(uniqueShedFreqs(end-1)-uniqueShedFreqs(1)) ...
%             0 (uniqueShedFreqs(find(graphData(i,5)==uniqueShedFreqs))-uniqueShedFreqs(1))/(uniqueShedFreqs(end-1)-uniqueShedFreqs(1))];
%         plot(graphData(i,1),graphData(i,6),'x','Color',c,'Linewidth',1.0);
%         hold on;
%     end
% end
% handlesShedFreqs=[];
% legendShedFreqs=[];
% for i=1:length(uniqueShedFreqs)-1
%     c=[1-(uniqueShedFreqs(i)-uniqueShedFreqs(1))/(uniqueShedFreqs(end-1)-uniqueShedFreqs(1)) ...
%         0 (uniqueShedFreqs(i)-uniqueShedFreqs(1))/(uniqueShedFreqs(end-1)-uniqueShedFreqs(1))];
%     graphX=graphData(find(graphData(:,5)==uniqueShedFreqs(i)),1);
%     graphY=graphData(find(graphData(:,5)==uniqueShedFreqs(i)),6);
%     graphPeakFreqs=graphData(find(graphData(:,5)==uniqueShedFreqs(i)),7);
%     firstPeakX=graphX(find(graphPeakFreqs(:)<2));
%     firstPeakY=graphY(find(graphPeakFreqs(:)<2));
%     [firstPeakX,firstPeakIs]=sort(firstPeakX);
%     firstPeakY=firstPeakY(firstPeakIs);
%     secondPeakX=graphX(find(graphPeakFreqs(:)>2));
%     secondPeakY=graphY(find(graphPeakFreqs(:)>2));
%     [secondPeakX,secondPeakIs]=sort(secondPeakX);
%     secondPeakY=secondPeakY(secondPeakIs);
%     if useGradientColors==1
%         if ~isempty(firstPeakX(find(~isinf(firstPeakX(:)))))
%             legendShedFreqs=[legendShedFreqs strcat('f_{v}=',string(uniqueShedFreqs(i)))];
%             hShedFreqs=plot(firstPeakX(find(~isinf(firstPeakX(:)))),firstPeakY(find(~isinf(firstPeakX(:)))),'Color',c,'Linewidth',1.0);
%             handlesShedFreqs=[handlesShedFreqs hShedFreqs];
%             plot(secondPeakX,secondPeakY,'--o','Color',c,'Linewidth',1.0,'HandleVisibility','off');
%         end
%     else
%         if ~isempty(firstPeakX(find(~isinf(firstPeakX(:)))))
%             legendShedFreqs=[legendShedFreqs strcat('f_{v}=',string(uniqueShedFreqs(i)))];
%             hShedFreqs=plot(firstPeakX(find(~isinf(firstPeakX(:)))),firstPeakY(find(~isinf(firstPeakX(:)))),'Linewidth',1.0);
%             handlesShedFreqs=[handlesShedFreqs hShedFreqs];
%             plot(secondPeakX,secondPeakY,'--o','Linewidth',1.0,'HandleVisibility','off');
%         end
%     end
% end
% legend(handlesShedFreqs,legendShedFreqs);
% grid on;
% xlabel('P');
% ylabel('A_{peak}');
% xlim([0,5.5]);
% 
% 
% % full subplot title
% if typeOfData==1
%         ylim([0.01 0.15]);
%         sgtitle('Power: solid=peak1, hashed=peak2')
% elseif typeOfData==2
%     switch loggedVariable
%         case 2
%             ylim([1e-5 4e-3]);
%             sgtitle('Z Position*Frequency: solid=peak1, hashed=peak2');
%         case 3
%             ylim([4e-2 10]);
%             sgtitle('Roll: solid=peak1, hashed=peak2');
%         case 6
%             ylim([4e-2 20]);
%             sgtitle('Pitch: solid=peak1, hashed=peak2');
%     end
% end
    
end
