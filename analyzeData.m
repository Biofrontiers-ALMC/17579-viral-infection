clearvars
close all
clc

% thresholds = [3500, 500, 750, 100, 317, 369, 359, 40, 3200, 410, 165, 82, 500, ...
%     2000, 246, 40];

files = dir('*.mat');

for ii = 1:numel(files)

    data(ii) = load(files(ii).name);

    [~, fn] = fileparts(files(ii).name);

    if ~exist(fn, 'dir')
        mkdir(fn)
    end

    figure;
    for jj = 1:12

        maskHit = false(size(data(ii).mask));
        maskMiss = maskHit;

        for cell = 1:size(data(ii).hitOrMiss, 1)
            if data(ii).hitOrMiss(cell, jj)

                maskHit(data(ii).pixelIdxList{cell}) = true;

            else

                maskMiss(data(ii).pixelIdxList{cell}) = true;

            end
        end

        % subplot(4, 3, jj)
        I = imread([fn, '.tif'], jj);
        
        Iout = showoverlay(I, bwperim(maskHit), 'Color', [0, 1, 0]);
        Iout = showoverlay(Iout, bwperim(maskMiss), 'Color', [1, 0, 0]);

        imwrite(Iout, fullfile(fn, [fn, '_ch', int2str(jj), '.tif']))
        % imshow(Iout)

    end
    


end


% %% Visualize
% 
% allData = [];
% 
% for ii = 1:numel(files)
% 
%     allData = [allData; data(ii).meanIntensity];
% 
% end
% 
% % %%
% 
% % 
% % T = otsuthresh(allData(:, ii));
% % T = T * max(allData(:, ii))
% 
% for kk = 1:16
%     figure
%     histogram(allData(:, kk), 100)
% end