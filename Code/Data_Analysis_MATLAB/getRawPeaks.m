function [rawPeaksMat]=getRawPeaks(fftMat,typeOfData,loggedVariable)

global dataMat;
global estFreqsMat;

rawPeaksMat=cell(size(fftMat,1),size(fftMat,2));
rawPeaksMat(:,1)=dataMat(:,1);
rawPeaksMat(1,:)=dataMat(1,:);
% if typeOfData==2 && loggedVariable==2
%     searchThreshold=.25;
% else
searchThreshold=.75;
% end

freqInterval=0; %the x-distance between the points of the fft. it gets set in the loop.
concavityRange=15;

for i=2:size(fftMat,1)  %loop through environments
    numOfPeaks=length(estFreqsMat{i-1,2});
    for j=2:size(fftMat,2)  %get actual peaks
        if ~isempty(fftMat{i,j})
            freqInterval=fftMat{i,j}(2,1)-fftMat{i,j}(1,1); %set the x-distance
            %find peaks and prominences
%             if typeOfData==2 && loggedVariable==2
%                 [pks,locs,width,prom]=findpeaks(log10(fftMat{i,j}(:,2).*fftMat{i,j}(:,1)),fftMat{i,j}(:,1));
%             else
            [pks,locs,width,prom]=findpeaks(log10(fftMat{i,j}(:,2)),fftMat{i,j}(:,1));
%             end
            peaks=[];
            for a=1:numOfPeaks
                indices=find((locs<estFreqsMat{i-1,2}(a)+searchThreshold) & (locs>estFreqsMat{i-1,2}(a)-searchThreshold));
                if isempty(indices)
                    begFreq=estFreqsMat{i-1,2}(a)-freqInterval/2;
                    endFreq=estFreqsMat{i-1,2}(a)+freqInterval/2;
                    if begFreq<fftMat{i,j}(2,1)
                        begFreq=fftMat{i,j}(2,1);
                    end
                    if endFreq>fftMat{i,j}(end,1)
                        endFreq=fftMat{i,j}(end,1);
                    end
                    center=find(fftMat{i,j}(:,1)<=endFreq & fftMat{i,j}(:,1)>=begFreq);
                    if length(center)>1
                        disp('what the heck');
                        center=center(1);
                    end
                    
                    begConcavityRange=center-concavityRange;
                    endConcavityRange=center+concavityRange;
                    if begConcavityRange<2
                        begConcavityRange=2;
                    end
                    if endConcavityRange>length(fftMat{i,j}(:,1))
                        endConcavityRange=length(fftMat{i,j}(:,1));
                    end
                    freqSection=fftMat{i,j}(begConcavityRange:endConcavityRange,1);
                    ampSection=fftMat{i,j}(begConcavityRange:endConcavityRange,2);
                    concavity=diff(ampSection,2);
                    [B,I]=sort(concavity);
                    peaks=[peaks; freqSection(I(1)) ampSection(I(1))];
                else
                    [B,I]=sort(10.^pks(indices),'descend');
                    peaks=[peaks; locs(indices(I(1))) B(1)]; 
                end
                
            end
            rawPeaksMat(i,j)={peaks};
        end
    end
end

end