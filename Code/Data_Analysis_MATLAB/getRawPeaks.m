function [rawPeaksMat]=getRawPeaks(fftMat,typeOfData,loggedVariable)
global dataMat;
rawPeaksMat=cell(size(fftMat,1),size(fftMat,2));
ll=0;   %lower frequency limit for peaks
ul=0;   %upper frequency limit for peaks
pt=0;   %peak prominence threshold
switch typeOfData
    case 1  %arduino power data
        ll=1;
        ul=12;
        pt=.05;
    case 2  %crazyflie data
        switch loggedVariable
            case 2  %kalman.stateZ
                ll=.1;
                ul=25;
                pt=.009;
            case 3  %gyro.x (roll)
                ll=.1;
                ul=25;
                pt=.009;
            case 6  %gyro.y (pitch)
                ll=.1;
                ul=25;
                pt=.009;
        end
end

for i=2:size(fftMat,1)  %loop through environments
    rawPeaksMat(i,1)=dataMat(i,1);
    pval=0;
    col=0; %column number
    for j=2:size(fftMat,2)  %get highest p value and save the column
        rawPeaksMat(1,j)=dataMat(1,j);
        if ~isempty(fftMat{i,j})
            pidtParsed=strsplit(fftMat{1,j}{1},' ');  %get array of [p,i,d,t] from folder name
            pStr=strsplit(pidtParsed{1},'=');
            p=str2double(pStr(2));
            if p>pval
                pval=p;
                col=j;
            end
        end
    end
    %find peaks and prominences
    %[pks,locs,width,prom] = findpeaks(log10(fftMat{i,col}(:,2)),fftMat{i,col}(:,1));
    if typeOfData==2 && loggedVariable==2
        [pks,locs,width,prom]=findpeaks(log10(fftMat{i,col}(:,2).*fftMat{i,col}(:,1)),fftMat{i,col}(:,1));
    else
        [pks,locs,width,prom]=findpeaks(log10(fftMat{i,col}(:,2)),fftMat{i,col}(:,1));%,logspace(0,1,size(fftMat{i,col},1)));
    end
    [B,I]=sort(prom,'descend');
    %normalize prominences to be within 0-1
    B=B./B(1);
    %calculate "slope" between all points
    for k=1:length(B)-1
        B(k,2)=B(k,1)-B(k+1,1);
    end
    %find peaks that meet threshold
    numOfPeaks=0;
    
    for a=1:size(B,1)-1
        if B(a,2)>pt || ~(B(a-1,2)<pt && B(a+1,2)<pt)
            if locs(I(a))>ll && locs(I(a))<ul
                numOfPeaks=numOfPeaks+1;
            end
        end
    end
    checkOutliers=[];
    for j=2:size(fftMat,2)  %get actual peaks
        if ~isempty(fftMat{i,j})
            %find peaks and prominences
            if typeOfData==2 && loggedVariable==2
                [pks,locs,width,prom]=findpeaks(log10(fftMat{i,j}(:,2).*fftMat{i,j}(:,1)),fftMat{i,j}(:,1));
            else
                [pks,locs,width,prom]=findpeaks(log10(fftMat{i,j}(:,2)),fftMat{i,j}(:,1));
            end
            [B,I]=sort(prom,'descend');
            
            %find number of peaks determined earlier
            peaks=[];
            freqs=[];
            a=1;
            while size(peaks,1)~=numOfPeaks
                if locs(I(a))>ll && locs(I(a))<ul
%                     tempOutliers=[];
%                     TF=[];
%                     if ~isempty(checkOutliers)
%                         tempOutliers=[checkOutliers(:,size(peaks,1)+1); locs(I(a))];
%                         TF=isoutlier(tempOutliers,'mean','ThresholdFactor',1.4);
%                     end
%                     if isempty(checkOutliers) || isempty(find(TF)) || find(TF)~=length(tempOutliers)
                        peaks=[peaks;locs(I(a)) 10^pks(I(a))];                    
%                         freqs=[freqs locs(I(a))];
%                     end
                end
                a=a+1;
            end
%             checkOutliers=[checkOutliers; freqs];
            rawPeaksMat(i,j)={peaks};
        end
    end
end

end