function [fftMat,rawPeaksMat,fitPeaksMat]=FFTAnalysis(typeOfData,loggedVariable)
%typeOfData: 1=arduino, 2=crazyflie
%loggedVariable: 
%       arduino: 2=power
%       crazyflie: 2=kalman.stateZ, 3=gyro.x (roll), 6=gyro.y (pitch)

global dataMat;
%global freqsMat;

%close all;
%clearvars;
%dataMat=CreateDataMat('/Users/grace/Documents/GitHub/BATL-flight/Data');
%cd /Users/grace/Documents/GitHub/BATL-flight/Code/Data_Analysis_MATLAB
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
                t=(0:dataSize-1)*T;    %create time vector
                y=fft(detrend(powerData));      %fft of powerData

                P2=abs(y/dataSize);
                P1=P2(1:dataSize/2+1);
                P1(2:end-1)=2*P1(2:end-1);

                f=Fs*(0:(dataSize/2))/dataSize;
                
                P1Matrix(k-1,:)=P1; %#ok<*SAGROW>
                %totalPowerSum=totalPowerSum+sum(powerData,'all');
                
                %loglog(f,P1);
            end
        end
        if ~isempty(dataMat{i,j}) && ~isempty(dataMat{i,j}{typeOfData,loggedVariable})     %check if there was any data for this controller and add controller to list of names if yes
            controllerNames=[controllerNames, dataMat{1,j}];
            smoothedData=smooth(mean(P1Matrix),15);%,11,'sgolay',0);     %smooth data //sometimes 15//
            smoothedData=smooth(smoothedData,10);
            fftMat(i,j)={[f',smoothedData]}; %save the fft graphed data [f,smoothed data]
        end
%             if typeOfData==2 && loggedVariable==2  %for zpos data, want data*f (normalized)
%                 smoothedData=smoothedData.*f';
% %             elseif typeOfData==2 && loggedVariable==6
% %                 smoothedData=smoothedData.*f';
%             end  
% %get raw peaks
% %             rawPeaksMat=getRawPeaks(rawPeaksMat,f',smoothedData,i,j);
% %             if typeOfData==1
% %                 lowFreqCutoff=1;   %cutoff value found by inspection of graphs
% %                 highFreqCutoff=10;
% %             else
% %                 switch loggedVariable
% %                     case 2
% %                         lowFreqCutoff=1;   %cutoff value found by inspection of graphs
% %                         highFreqCutoff=10;
% %                     case 6
% %                         lowFreqCutoff=.5;  %cutoff value found by inspection of graphs
% %                         highFreqCutoff=30;
% %                 end
% %             end
% %             fCounter=1;
% %             fStart=0;
% %             fEnd=0;
% %             while f(fCounter)<lowFreqCutoff
% %                 fStart=fCounter;
% %                 fCounter=fCounter+1;
% %             end
% %             fCounter=1;
% %             while f(fCounter)<highFreqCutoff
% %                 fEnd=fCounter;
% %                 fCounter=fCounter+1;
% %             end
% %             %smoothedData=smoothedData.*f';
% %             fTemp=f(fStart:fEnd);  %eliminate anything below cutoff Hz
% %             smoothedDataTemp=smoothedData(fStart:fEnd);  %eliminate anything below cutoff Hz
% %             %if typeOfData==2 && loggedVariable==2
% %             %    [pks,locs,width,prom] = findpeaks(smoothedDataTemp.*fTemp');  %find peaks for zpos*freq
% %             %else
% %                 [pks,locs,width,prom] = findpeaks(smoothedDataTemp);  %find peaks
% %             %end
% %             freqPks=zeros(length(pks),1);
% %             for l=1:length(pks)     %use locs to find the corresponding freqs for the peaks
% %                 freqPks(l)=fTemp(locs(l));
% %             end
% %             [B,I]=sort(prom,'descend');     %sort prominences from largest to smallest
% %             if typeOfData==1
% %                 if B(2)>=0.005
% %                     rawPeaksMat(i,j)={[freqPks(I(1:2)),pks(I(1:2))]};
% %                 else
% %                     rawPeaksMat(i,j)={[freqPks(I(1)),pks(I(1))]};
% %                 end
% %             else
% %                 switch loggedVariable
% %                     case 2 %zpos
% %                         rawPeaksMat(i,j)={[freqPks(sort(I(1:2))),pks(sort(I(1:2)))]};  
% %                     case 6 %pitch                    
% %                         rawPeaksMat(i,j)={[freqPks(sort(I(1:4))),pks(sort(I(1:4)))]};     
% %                 end
% %             end
%             
% %plot fft
%             pidtParsed=strsplit(controllerNames(end),' ');  %get array of [p,i,d,t] from folder name
%             p=strsplit(pidtParsed(1),'=');
%             pval=str2double(p(2));
%             c=[1-pval/5 0 pval/5];
%             if useGradientColors==1
%                 %if typeOfData==2 && loggedVariable==2
%                     h1=loglog(f,smoothedData,'Color',c,'Linewidth',2);
%                     handles=[handles h1];
%                 %else
%                 %    h1=loglog(f,smoothedData,'Color',c,'Linewidth',2);
%                 %    handles=[handles h1];
%                 %end
%             else
%                 %if typeOfData==2 && loggedVariable==2
%                     h1=loglog(f,smoothedData,'Linewidth',2.5);
%                     handles=[handles h1];
%                 %else
%                 %    h1=loglog(f,smoothedData,'Linewidth',2.5);
%                 %    handles=[handles h1];
%                 %end
%             end
%             hold on;
%             
% %plot raw peak points
% % %             plot(rawPeaksMat{i,j}(1,1),rawPeaksMat{i,j}(1,2),'c*','HandleVisibility','off');
% % %             if size(rawPeaksMat{i,j},1)>1
% % %                 plot(rawPeaksMat{i,j}(2,1),rawPeaksMat{i,j}(2,2),'c*','HandleVisibility','off');
% % %             end
% 
% %graph fitted peaks and plot fitted peak points
% %             if typeOfData==1
% %                 index1=find(fftMat{i,j}(:,1) == rawPeaksMat{i,j}(1,1));
% %                 index1Min=index1-10;
% %                 index1Max=index1+10;
% %                 fitX1=f(index1Min:index1Max)';
% %                 fitCurve1=polyfit(fitX1,smoothedData(index1Min:index1Max),2);
% %                 fitY1=polyval(fitCurve1,fitX1);
% %                 plot(fitX1,fitY1,'Color',[0.4660 0.6740 0.1880],'Linewidth',1.5);
% %                 [maxVal1,I1]=max(fitY1);
% %                 if size(rawPeaksMat{i,j},1)>1
% %                     index2=find(fftMat{i,j}(:,1) == rawPeaksMat{i,j}(2,1));
% %                     index2Min=index2-10;
% %                     index2Max=index2+10;
% %                     fitX2=f(index2Min:index2Max)';
% %                     fitCurve2=polyfit(fitX2,smoothedData(index2Min:index2Max),2);
% %                     fitY2=polyval(fitCurve2,fitX2);
% %                     plot(fitX2,fitY2,'Color',[0.4660 0.6740 0.1880],'Linewidth',1.5);
% %                     [maxVal2,I2]=max(fitY2);
% %                     fitPeaksMat(i,j)={[[fitX1(I1); fitX2(I2)],[fitY1(I1); fitY2(I2)]]};
% %                     plot(fitPeaksMat{i,j}(1,1),fitPeaksMat{i,j}(1,2),'k*','HandleVisibility','off');
% %                     plot(fitPeaksMat{i,j}(2,1),fitPeaksMat{i,j}(2,2),'k*','HandleVisibility','off');
% %                 else
% %                     fitPeaksMat(i,j)={[fitX1(I1),fitY1(I1)]};
% %                     plot(fitPeaksMat{i,j}(1,1),fitPeaksMat{i,j}(1,2),'k*','HandleVisibility','off');
% %                 end
% %                 integratedPower=trapz(smoothedData);
% %                 integPowerMat(i,j)={integratedPower};
% %             else
% %                 fitPeaksArray=[];
% %                 pointsOnEachSide=10;    %number of points to take on each side of the raw peak
% %                 for l=1:size(rawPeaksMat{i,j},1)
% %                     index1=find(fftMat{i,j}(:,1) == rawPeaksMat{i,j}(l,1)); %find index of the raw peak in fftMat
% %                     if index1-pointsOnEachSide<1    %check that index1Min is within range of points
% %                         index1Min=1;    %not in range so make it the first value
% %                     else
% %                         index1Min=index1-pointsOnEachSide;  %in range
% %                     end
% %                     if index1+pointsOnEachSide>size(smoothedData)   %check that index1Min is within range of points
% %                         index1Max=size(smoothedData);   %not in range so make it the last value
% %                     else
% %                         index1Max=index1+pointsOnEachSide;  %in range
% %                     end
% %                     fitX1=f(index1Min:index1Max)';
% %                     fitCurve1=polyfit(fitX1,smoothedData(index1Min:index1Max),2);
% %                     fitY1=polyval(fitCurve1,fitX1);
% %                     plot(fitX1,fitY1,'Color',[0.4660 0.6740 0.1880],'Linewidth',1.5);
% %                     [maxVal1,I1]=max(fitY1);
% %                     fitPeaksArray=[fitPeaksArray; fitX1(I1),fitY1(I1)];
% %                     plot(fitPeaksArray(l,1),fitPeaksArray(l,2),'k*','HandleVisibility','off');
% %                 end
% %                 fitPeaksMat(i,j)={fitPeaksArray};
% %             end
% %             %P,ftunnel,windspeed,diameter,sheddingfreq,apeak,fpeak
% %             graphData=[graphData;[repmat(pval,size(fitPeaksMat{i,j},1),1),...
% %             repmat(fTunnel,size(fitPeaksMat{i,j},1),1),repmat(windSpeed,size(fitPeaksMat{i,j},1),1),...
% %             repmat(diameter,size(fitPeaksMat{i,j},1),1),repmat(sheddingFreq,size(fitPeaksMat{i,j},1),1),...
% %             fitPeaksMat{i,j}(:,2),fitPeaksMat{i,j}(:,1)]];
%         end
%     end
%     controllerNames = controllerNames(~cellfun('isempty',controllerNames));     %remove empty strings from controller name list
%     title(['Environment = ',dataMat{i,1}]);
%     set(gca,'TickLabelInterpreter','Latex','Fontsize',10);
%     xlabel('Frequency [Hz]','Interpreter','Latex');
%     ylabel('FFT','Interpreter','Latex');
%     %clear xlim;
%     xlim([5*10^(-1) 13]);
%     if typeOfData==1
%         ylim([0.01 0.15]);
%         sgtitle('Power')
%     elseif typeOfData==2
%         switch loggedVariable
%             case 2
%                 ylim([1e-5 4e-3]);
%                 sgtitle('Z Position*Frequency');
%             case 3
%                 ylim([4e-2 10]);
%                 sgtitle('Roll');
%             case 6
%                 ylim([4e-2 20]);
%                 sgtitle('Pitch');
%         end
%     end
%     grid on;
%     legend(handles,string(controllerNames));
%     hold off;


    end
end
rawPeaksMat=getRawPeaks(fftMat,typeOfData,loggedVariable);
plotAnalysis(fftMat,rawPeaksMat,typeOfData,loggedVariable,useGradientColors);
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
