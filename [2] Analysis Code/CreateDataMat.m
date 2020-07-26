function [dataMat] = CreateDataMat(fileDirectory)
% CREATEDATAMAT: Function that parses through all of the test flight data
% and sorts all the times and powers for each flight into a labelled cell
% array.
% 
%   dataMat = CreateDataMat(fileDirectory) runs 
% 
%   INPUTS
%       fileDirectory       String that is the file directoryn with all the data
% 
%   OUTPUTS
%       powerMat            Cell array that organizes and stores all of the test data
%                           [      {}     , {pidt values 1}, {pidt values 2}, ...                          
%                            {frequency 1},     [DATA]     ,     [DATA]     , ...
%                            {frequency 2},     [DATA]     ,     [DATA]     , ...
%                                   .             .                 .
%                                   .             .                 .             ]      
% 
%   NOTE: Folders for PIDT must be labelled correctly. Format is "P_I_D_T".
%   Data can be accessed by using 
%       dataMat{a,b}{2,c}{2,d} where  a = environment+1
%                                     b = controller+1
%                                     c = test #
%                                     d = timestamp(f==1) or power(f==2)
% 
%   Cornell University
%   BATL-The Effects of Turbulent Vortex Shedding on the Stability of Quadcopter Drones
%   Ding, Grace
%   13FEB2020
%   Last edited: 17MAR2020

cd (fileDirectory)      %go to directory with all of the data

environmentFolders = dir;  %get all files and folders in type of data folder directory
environmentDirFlags = [environmentFolders.isdir] & ~strcmp({environmentFolders.name},'.') & ~strcmp({environmentFolders.name},'..');    %save just folders in current directory
environmentFolders = environmentFolders(environmentDirFlags);    %update freqFolders to only contain folders
numEnvironmentFolders = length(environmentFolders);   %get number of frequency folders

dataMat = cell(numEnvironmentFolders+1,1);    %initialize PowerMat matrix which reads and stores all data from all frequencies 

for i=1:numEnvironmentFolders      %loop through all frequency folders
    
    dataMat(i+1,1)={environmentFolders(i).name};    %write frequency into first column of PowerMat starting from second row (header)
    
    cd (environmentFolders(i).name);   %go into frequency folder
    
    pidtFolders = dir;  %get all files and folders in current directory
    pidtDirFlags = [pidtFolders.isdir] & ~strcmp({pidtFolders.name},'.') & ~strcmp({pidtFolders.name},'..')& ~strcmp({pidtFolders.name},"Don't Graph");  %save only folders in current directory
    pidtFolders = pidtFolders(pidtDirFlags);    %update pidtFolders to only contain folders
    numPidtFolders = length(pidtFolders);   %get number of pidt folders
    
    for j=1:numPidtFolders      %loop through all pidt folders
        writeToColumn=0;        %save which column to write data to (aka which pidt setting it was)
        isAColumn=false;        %check if this pidt setting has been already saved before
        pidtParsed=strsplit(pidtFolders(j).name,'_');  %get array of [p,i,d,t] from folder name
        headerName=strcat('P=',pidtParsed(1),' I=',pidtParsed(2),' D=',pidtParsed(3),' T=',pidtParsed(4)); %format name
        
        for headers=2:size(dataMat,2)    %loop through all headers to check if this pidt setting has happened before
            if strcmp(dataMat{1,headers},headerName)   %if the headers are the same (same pidt setting)
                isAColumn=true;     %this is already a column
                writeToColumn=headers;      %save this column number
            end
        end
        
        if isAColumn==false         %if this pidt setting hasn't been recorded yet
            dataMat(1,size(dataMat,2)+1)={headerName};    %make a new column with this header
            writeToColumn=size(dataMat,2);     %save last column as column number
            
        end
        
        cd (pidtFolders(j).name);   %go into pidt folder
        
        powerFiles = dir('*.csv');   %get all .csv files in current folder (power data)
        crazyflieFiles = dir('*.txt');       %get all .txt files in current folder (z data)

        data=cell(2,max([length(powerFiles), length(crazyflieFiles)]));    %create data matrix to write into PowerMat
                                    % [ [Power],  [FILE],   [FILE] , [FILE] , ...               
                                    %   [zData],  [FILE] ,  [FILE] , [FILE] , ... 
                                    %         .             .    
                                    %         .             .             ]     
        data(1,1)={'Power data'};
        data(2,1)={'Crazyflie data'};
                                 
        %%%loop for power data%%%
        offsetPowerData=0;     %track ghost files for power in directory
        for k=1:length(powerFiles)       %loop through all files
            file=cell(2,2);   %create file matrix to write into data
            firstChar=strsplit(powerFiles(k).name,'_');  %split file name in order to get first character
            
            if strcmp(firstChar(1),'.')     %check if file name starts with '.' (ghost files???)
                offsetPowerData=offsetPowerData+1;    %if there is a file with '.', ignore and remember offset for labeling
            else
                file(1,1)= {'Timestamp [s]'};       %label Timestamp column
                file(1,2) = {'Power [W]'};          %label Power column
%                 time = csvread(powerFiles(k).name,20,0,[20,0,1499,0]);       %reads time data from line 501 to line 1250
%                 current = csvread(powerFiles(k).name,20,1,[20,1,1499,1]);    %reads current data from line 21 to line 1500
%                 voltage = csvread(powerFiles(k).name,20,2,[20,2,1499,2]);    %reads voltage data from line 21 to line 1500
                time = csvread(powerFiles(k).name,500,0,[500,0,1249,0]);       %reads time data from line 501 to line 1250 (20s-45s)
                current = csvread(powerFiles(k).name,500,1,[500,1,1249,1]);    %reads current data from line 21 to line 1500
                voltage = csvread(powerFiles(k).name,500,2,[500,2,1249,2]);    %reads voltage data from line 21 to line 1500
                file(2,1) = {time./1000};       %put time in time column
                file(2,2) = {current.*(voltage./1000)};     %put power in power column
                data(1,k-offsetPowerData+1)={file};        %save file cell array into correct test column in data cell array
            end
        end
        
        %%%loop for crazyflie data%%%
        offsetCrazyflieData=0;     %track ghost files for crazyflie in directory
        for k=1:length(crazyflieFiles)       %loop through all files
            file=cell(2,7);   %create file matrix to write into data
            firstChar=strsplit(crazyflieFiles(k).name,'_');  %split file name in order to get first character
            
            if strcmp(firstChar(1),'.')     %check if file name starts with '.' (ghost files???)
                offsetCrazyflieData=offsetCrazyflieData+1;    %if there is a file with '.', ignore and remember offset for labeling
            else
                fid=fopen(crazyflieFiles(k).name,'r');      %open the current txt file
                headers=fgetl(fid);                         %getting headers from first line
                headers=strsplit(headers,',');              %split header by commas
                for n=1:size(headers,2)                     %loop through headers and save them into cells
                    file(1,n)=headers(1,n);
                end         
                txtData=textscan(fid,'%d %f %f %f %f %f %f %f','Delimiter',',');    %read the txt file
                for n=1:size(txtData,2)             %loop through txtData and put each column into right place
                    txtData(1,n)={txtData{1,n}(2001:4500,1)};   %reads data from 20 seconds to 45 seconds
                    file(2,n)=txtData(1,n);
                end
                fclose(fid);        %close file
                data(2,k-offsetCrazyflieData+1)={file};        %save file cell array into correct test column in data cell array
            end
        end
        
        dataMat(i+1,writeToColumn)={data};       %save data cell array into correct spot in powerMat cell array
        
        cd ..;  %go back to frequency folder
    end
    cd ..;  %go back to data folder
end

end

