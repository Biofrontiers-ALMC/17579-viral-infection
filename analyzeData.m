clearvars
clc

files = dir('*.mat');

for ii = 1:numel(files)

    data(ii) = load(files(ii).name);

end


allData = [];

for ii = 1:numel(files)

    allData = [allData; data(ii).storeData];

end

%%

thresholds = [3500, 500, 750, 100, 317, 369, 359, 40, 3200, 410, 165, 82, 500, ...
    2000, 246, 40];


%% Visualize
for ii = 1:12
    subplot(4, 3, ii)
    I = imread('well_3_K9.tif', ii);
    imshowpair(I, bwperim(data(ii).mask))
end



%TODO: Plot diagnostic images, count number of cells


% 
% %%
% ii = 16
% 
% T = otsuthresh(allData(:, ii));
% T = T * max(allData(:, ii))
% histogram(allData(:, ii), 100)