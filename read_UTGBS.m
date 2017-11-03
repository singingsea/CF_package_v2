function data = read_UTGBS(year)
% this function read those QDOAS processed UTGBS dSCDs files
data_path = 'H:\work\Eureka\GBS\CI\from_K\v2\';
f_nm = ['UT-GBS_' year '_reanalysis_VIS_O3X.ASC'];
%f_nm = ['UT-GBS_' year '_reanalysis_VIS_300_O3X.ASC'];
%f_nm = 'UT-GBS_2003_reanalysis_VIS_600+300_O3X.ASC';
export_f_nm = ['u1_' year '_v2.mat'];
%export_f_nm = ['u0_' year '_v2.mat'];
%export_f_nm = 'u01_2003_v2.mat';
cd(data_path);

fid = fopen([data_path f_nm], 'r');
fgetl(fid);                                  % Read/discard line.
buffer = fread(fid, Inf) ;                    % Read rest of the file.
fclose(fid);
fid = fopen('temp.ASC', 'w') ;   % Open destination file.
fwrite(fid, buffer);                         % Save to file.
fclose(fid);

data = importfile('temp.ASC');
save(export_f_nm,'data');

function temp = importfile(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as a matrix.
%   TEMP = IMPORTFILE(FILENAME) Reads data from text file FILENAME for the
%   default selection.
%
%   TEMP = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from rows
%   STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   temp = importfile('temp.ASC', 2, 35783);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2017/08/25 16:57:04

%% Initialize variables.
delimiter = '\t';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,5,6,7,8,9,10,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end

dateFormats = {'dd/MM/yyyy', 'HH:mm:ss'};
dateFormatIndex = 1;
blankDates = cell(1,size(raw,2));
anyBlankDates = false(size(raw,1),1);
invalidDates = cell(1,size(raw,2));
anyInvalidDates = false(size(raw,1),1);
for col=[11,12]% Convert the contents of columns with dates to MATLAB datetimes using date format string.
    try
        dates{col} = datetime(dataArray{col}, 'Format', dateFormats{col==[11,12]}, 'InputFormat', dateFormats{col==[11,12]}); %#ok<SAGROW>
    catch
        try
            % Handle dates surrounded by quotes
            dataArray{col} = cellfun(@(x) x(2:end-1), dataArray{col}, 'UniformOutput', false);
            dates{col} = datetime(dataArray{col}, 'Format', dateFormats{col==[11,12]}, 'InputFormat', dateFormats{col==[11,12]}); %%#ok<SAGROW>
        catch
            dates{col} = repmat(datetime([NaN NaN NaN]), size(dataArray{col})); %#ok<SAGROW>
        end
    end
    
    dateFormatIndex = dateFormatIndex + 1;
    blankDates{col} = cellfun(@isempty, dataArray{col});
    anyBlankDates = blankDates{col} | anyBlankDates;
    invalidDates{col} = isnan(dates{col}.Hour) - blankDates{col};
    anyInvalidDates = invalidDates{col} | anyInvalidDates;
end
dates = dates(:,[11,12]);
blankDates = blankDates(:,[11,12]);
invalidDates = invalidDates(:,[11,12]);

%% Split data into numeric and cell columns.
rawNumericColumns = raw(:, [1,2,3,4,5,6,7,8,9,10,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58]);

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
temp = table;
temp.SpecNo = cell2mat(rawNumericColumns(:, 1));
temp.Year = cell2mat(rawNumericColumns(:, 2));
temp.Fractionalday = cell2mat(rawNumericColumns(:, 3));
temp.Fractionaltime = cell2mat(rawNumericColumns(:, 4));
temp.Scans = cell2mat(rawNumericColumns(:, 5));
temp.Tint = cell2mat(rawNumericColumns(:, 6));
temp.SZA = cell2mat(rawNumericColumns(:, 7));
temp.SolarAzimuthAngle = cell2mat(rawNumericColumns(:, 8));
temp.Elevviewingangle = cell2mat(rawNumericColumns(:, 9));
temp.Azimviewingangle = cell2mat(rawNumericColumns(:, 10));
temp.DateDDMMYYYY = dates{:, 1};
temp.Timehhmmss = dates{:, 2};
temp.TotalExperimentTimesec = cell2mat(rawNumericColumns(:, 11));
% temp.O3_XRMS = cell2mat(rawNumericColumns(:, 12));
% temp.O3_XRefZm = cell2mat(rawNumericColumns(:, 13));
% temp.O3_Xprocessing_error = cell2mat(rawNumericColumns(:, 14));
% temp.O3_XSlColh2o = cell2mat(rawNumericColumns(:, 15));
% temp.O3_XSlErrh2o = cell2mat(rawNumericColumns(:, 16));
% temp.O3_XSlColo4 = cell2mat(rawNumericColumns(:, 17));
% temp.O3_XSlErro4 = cell2mat(rawNumericColumns(:, 18));
% temp.O3_XSlColRing = cell2mat(rawNumericColumns(:, 19));
% temp.O3_XSlErrRing = cell2mat(rawNumericColumns(:, 20));
% temp.O3_XSlColno2 = cell2mat(rawNumericColumns(:, 21));
% temp.O3_XSlErrno2 = cell2mat(rawNumericColumns(:, 22));
% temp.O3_XSlColo3 = cell2mat(rawNumericColumns(:, 23));
% temp.O3_XSlErro3 = cell2mat(rawNumericColumns(:, 24));
% temp.O3_XSlColX = cell2mat(rawNumericColumns(:, 25));
% temp.O3_XSlErrX = cell2mat(rawNumericColumns(:, 26));
% temp.O3_XSlColx0 = cell2mat(rawNumericColumns(:, 27));
% temp.O3_XSlErrx0 = cell2mat(rawNumericColumns(:, 28));
% temp.O3_XSlColx1 = cell2mat(rawNumericColumns(:, 29));
% temp.O3_XSlErrx1 = cell2mat(rawNumericColumns(:, 30));
% temp.O3_XSlColx2 = cell2mat(rawNumericColumns(:, 31));
% temp.O3_XSlErrx2 = cell2mat(rawNumericColumns(:, 32));
% temp.O3_XSlColx3 = cell2mat(rawNumericColumns(:, 33));
% temp.O3_XSlErrx3 = cell2mat(rawNumericColumns(:, 34));
% temp.O3_XShiftSpectrum = cell2mat(rawNumericColumns(:, 35));
% temp.O3_XStretchSpectrum1 = cell2mat(rawNumericColumns(:, 36));
% temp.O3_XStretchSpectrum2 = cell2mat(rawNumericColumns(:, 37));
temp.O3RMS = cell2mat(rawNumericColumns(:, 12));
temp.O3RefZm = cell2mat(rawNumericColumns(:, 13));
temp.O3processing_error = cell2mat(rawNumericColumns(:, 14));
temp.O3SlColh2o = cell2mat(rawNumericColumns(:, 15));
temp.O3SlErrh2o = cell2mat(rawNumericColumns(:, 16));
temp.O3SlColo4 = cell2mat(rawNumericColumns(:, 17));
temp.O3SlErro4 = cell2mat(rawNumericColumns(:, 18));
temp.O3SlColRing = cell2mat(rawNumericColumns(:, 19));
temp.O3SlErrRing = cell2mat(rawNumericColumns(:, 20));
temp.O3SlColno2 = cell2mat(rawNumericColumns(:, 21));
temp.O3SlErrno2 = cell2mat(rawNumericColumns(:, 22));
temp.O3SlColo3 = cell2mat(rawNumericColumns(:, 23));
temp.O3SlErro3 = cell2mat(rawNumericColumns(:, 24));
temp.O3SlColX = cell2mat(rawNumericColumns(:, 25));
temp.O3SlErrX = cell2mat(rawNumericColumns(:, 26));
temp.O3SlColx0 = cell2mat(rawNumericColumns(:, 27));
temp.O3SlErrx0 = cell2mat(rawNumericColumns(:, 28));
temp.O3SlColx1 = cell2mat(rawNumericColumns(:, 29));
temp.O3SlErrx1 = cell2mat(rawNumericColumns(:, 30));
temp.O3SlColx2 = cell2mat(rawNumericColumns(:, 31));
temp.O3SlErrx2 = cell2mat(rawNumericColumns(:, 32));
temp.O3SlColx3 = cell2mat(rawNumericColumns(:, 33));
temp.O3SlErrx3 = cell2mat(rawNumericColumns(:, 34));
temp.O3ShiftSpectrum = cell2mat(rawNumericColumns(:, 35));
temp.O3StretchSpectrum1 = cell2mat(rawNumericColumns(:, 36));
temp.O3StretchSpectrum2 = cell2mat(rawNumericColumns(:, 37));
temp.Fluxes355 = cell2mat(rawNumericColumns(:, 38));
temp.Fluxes360 = cell2mat(rawNumericColumns(:, 39));
temp.Fluxes380 = cell2mat(rawNumericColumns(:, 40));
temp.Fluxes385 = cell2mat(rawNumericColumns(:, 41));
temp.Fluxes390 = cell2mat(rawNumericColumns(:, 42));
temp.Fluxes405 = cell2mat(rawNumericColumns(:, 43));
temp.Fluxes420 = cell2mat(rawNumericColumns(:, 44));
temp.Fluxes425 = cell2mat(rawNumericColumns(:, 45));
temp.Fluxes435 = cell2mat(rawNumericColumns(:, 46));
temp.Fluxes440 = cell2mat(rawNumericColumns(:, 47));
temp.Fluxes445 = cell2mat(rawNumericColumns(:, 48));
temp.Fluxes450 = cell2mat(rawNumericColumns(:, 49));
temp.Fluxes455 = cell2mat(rawNumericColumns(:, 50));
temp.Fluxes460 = cell2mat(rawNumericColumns(:, 51));
temp.Fluxes470 = cell2mat(rawNumericColumns(:, 52));
temp.Fluxes490 = cell2mat(rawNumericColumns(:, 53));
temp.Fluxes500 = cell2mat(rawNumericColumns(:, 54));
temp.Fluxes532 = cell2mat(rawNumericColumns(:, 55));
temp.Fluxes550 = cell2mat(rawNumericColumns(:, 56));

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).

% temp.DateDDMMYYYY=datenum(temp.DateDDMMYYYY);
% temp.Timehhmmss=datenum(temp.Timehhmmss);


