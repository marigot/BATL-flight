function [fitPeaksMat]=plotAnalysis(fftMat,rawPeaksMat,typeOfData,loggedVariable,useGradientColors)
figure();
global dataMat;
graphData=[];   %holds: P,ftunnel,windspeed,diameter,sheddingfreq,apeak,fpeak

for i=2:size(fftMat,1)       %loop through environment
    subplot(round((size(fftMat,1)-1)/3),3,i-1);
    controllerNames=[""];
    
    handles=[];
    
    controllerParsed=strsplit(string(fftMat{i,1}),'-');  %get array of [ftunnel,diameter] from folder name
    controllerFreqTemp=char(controllerParsed(1));
    diameterTemp=char(controllerParsed(2));
    fTunnel=str2double(controllerFreqTemp(2:end));
    diameter=str2double(diameterTemp(2:end));
    windSpeed=0.196*fTunnel+0.103;  %equation from hotwire measurements
    sheddingFreq=.22*windSpeed/(diameter/39.37);  %equation from something idk ask marigot
    
    for j=2:size(fftMat,2)   %loop through controllers
        if ~isempty(fftMat{i,j}) %&& ~isempty(dataMat{i,j}{typeOfData,loggedVariable})     %check if there was any data for this controller and add controller to list of names if yes
            controllerNames=[controllerNames, dataMat{1,j}];
            f=fftMat{i,j}(:,1);
            smoothedData=fftMat{i,j}(:,2);
            if typeOfData==3 && loggedVariable==2  %for zpos data, want data*f (normalized)
                smoothedData=smoothedData.*f;
%             elseif typeOfData==2 && loggedVariable==6
%                 smoothedData=smoothedData.*f';
            end  
%plot fft
            pidtParsed=strsplit(controllerNames(end),' ');  %get array of [p,i,d,t] from folder name
            p=strsplit(pidtParsed(1),'=');
            pval=str2double(p(2));
            c=[1-pval/5 0 pval/5];
            if useGradientColors==1
                %if typeOfData==2 && loggedVariable==2
                    h1=semilogy(f,smoothedData,'Color',c,'Linewidth',2);
                    handles=[handles h1];
                %else
                %    h1=loglog(f,smoothedData,'Color',c,'Linewidth',2);
                %    handles=[handles h1];
                %end
            else
                %if typeOfData==2 && loggedVariable==2
                    h1=loglog(f,smoothedData,'Linewidth',2.5);
                    handles=[handles h1];
                %else
                %    h1=loglog(f,smoothedData,'Linewidth',2.5);
                %    handles=[handles h1];
                %end
            end
            hold on;
            
% plot raw peak points
            for z=1:size(rawPeaksMat{i,j},1)
                plot(rawPeaksMat{i,j}(z,1),rawPeaksMat{i,j}(z,2),'c*','HandleVisibility','off');
            end
            
            

% % %graph fitted peaks and plot fitted peak points
%             if typeOfData==1
%                 index1=find(fftMat{i,j}(:,1) == rawPeaksMat{i,j}(1,1));
%                 index1Min=index1-10;
%                 index1Max=index1+10;
%                 fitX1=f(index1Min:index1Max);
%                 fitCurve1=polyfit(fitX1,smoothedData(index1Min:index1Max),2);
%                 fitY1=polyval(fitCurve1,fitX1);
%                 plot(fitX1,fitY1,'Color',[0.4660 0.6740 0.1880],'Linewidth',1.5);
%                 [maxVal1,I1]=max(fitY1);
%                 if size(rawPeaksMat{i,j},1)>1
%                     index2=find(fftMat{i,j}(:,1) == rawPeaksMat{i,j}(2,1));
%                     index2Min=index2-10;
%                     index2Max=index2+10;
%                     fitX2=f(index2Min:index2Max)';
%                     fitCurve2=polyfit(fitX2,smoothedData(index2Min:index2Max),2);
%                     fitY2=polyval(fitCurve2,fitX2);
%                     plot(fitX2,fitY2,'Color',[0.4660 0.6740 0.1880],'Linewidth',1.5);
%                     [maxVal2,I2]=max(fitY2);
%                     fitPeaksMat(i,j)={[[fitX1(I1); fitX2(I2)],[fitY1(I1); fitY2(I2)]]};
%                     plot(fitPeaksMat{i,j}(1,1),fitPeaksMat{i,j}(1,2),'k*','HandleVisibility','off');
%                     plot(fitPeaksMat{i,j}(2,1),fitPeaksMat{i,j}(2,2),'k*','HandleVisibility','off');
%                 else
%                     fitPeaksMat(i,j)={[fitX1(I1),fitY1(I1)]};
%                     plot(fitPeaksMat{i,j}(1,1),fitPeaksMat{i,j}(1,2),'k*','HandleVisibility','off');
%                 end
%                 integratedPower=trapz(smoothedData);
%                 integPowerMat(i,j)={integratedPower};
%             else
%                 fitPeaksArray=[];
%                 pointsOnEachSide=10;    %number of points to take on each side of the raw peak
%                 for l=1:size(rawPeaksMat{i,j},1)
%                     index1=find(fftMat{i,j}(:,1) == rawPeaksMat{i,j}(l,1)); %find index of the raw peak in fftMat
%                     if index1-pointsOnEachSide<2    %check that index1Min is within range of points
%                         index1Min=2;    %not in range so make it the first value
%                     else
%                         index1Min=index1-pointsOnEachSide;  %in range
%                     end
%                     if index1+pointsOnEachSide>size(smoothedData)   %check that index1Min is within range of points
%                         index1Max=size(smoothedData);   %not in range so make it the last value
%                     else
%                         index1Max=index1+pointsOnEachSide;  %in range
%                     end
%                     fitX1=f(index1Min:index1Max);
%                     fitCurve1=polyfit(fitX1,smoothedData(index1Min:index1Max),2);
%                     fitY1=polyval(fitCurve1,fitX1);
%                     plot(fitX1,fitY1,'Color',[0.4660 0.6740 0.1880],'Linewidth',1.5);
%                     %[maxVal1,I1]=max(fitY1);
%                     concavity=diff(fitY1,2);
%                     [B,I]=sort(concavity);
%                     fitPeaksArray=[fitPeaksArray; fitX1(I(1)),fitY1(I(1))];
%                     %fitPeaksArray=[fitPeaksArray; fitX1(I1),fitY1(I1)];
%                     plot(fitPeaksArray(l,1),fitPeaksArray(l,2),'k*','HandleVisibility','off');
%                 end
%                 fitPeaksMat(i,j)={fitPeaksArray};
%             end
%             %P,ftunnel,windspeed,diameter,sheddingfreq,apeak,fpeak
%             graphData=[graphData;[repmat(pval,size(fitPeaksMat{i,j},1),1),...
%             repmat(fTunnel,size(fitPeaksMat{i,j},1),1),repmat(windSpeed,size(fitPeaksMat{i,j},1),1),...
%             repmat(diameter,size(fitPeaksMat{i,j},1),1),repmat(sheddingFreq,size(fitPeaksMat{i,j},1),1),...
%             fitPeaksMat{i,j}(:,2),fitPeaksMat{i,j}(:,1)]];
        end
    end
    controllerNames = controllerNames(~cellfun('isempty',controllerNames));     %remove empty strings from controller name list
    title(['Environment = ',dataMat{i,1}]);
    set(gca,'TickLabelInterpreter','Latex','Fontsize',10);
    xlabel('Frequency [Hz]','Interpreter','Latex');
    ylabel('FFT','Interpreter','Latex');
    %clear xlim;
    xlim([5*10^(-1) 50]);
    %xlim([0 2]);
    if typeOfData==1
        ylim([0.01 0.15]);
        sgtitle('Power')
    elseif typeOfData==2
        switch loggedVariable
            case 2
                ylim([1e-5 4e-3]);
                %ylim([1e-4 1e-2]);
                sgtitle('Z Position*Frequency');
            case 3
                ylim([4e-2 10]);
                sgtitle('Roll');
            case 6
                ylim([4e-2 20]);
                xlim([0 25])
                sgtitle('Pitch');
        end
    end
    grid on;
    legend(handles,string(controllerNames));
    hold off;
end
end