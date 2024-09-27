clearvars
clc

files = dir('*.tif');

for iFile = 1:numel(files)

    maskImage = 1;

    %Mask the images
    Imask = imread(files(iFile).name, maskImage);
    
    mask = imbinarize(Imask);
    mask = imopen(mask, strel('disk', 1));

    dd = - bwdist(mask);
    dd = imhmin(dd, 1);

    dd(~mask) = -Inf;

    LL = watershed(dd);
    mask(LL == 0) = 0;

    %imshowpair(Imask, bwperim(mask))

    %% Measure data

    nImages = numel(imfinfo(files(iFile).name));

    for ch = 1:nImages

        I = imread(files(iFile).name, ch);

        cellData = regionprops(mask, I, 'MeanIntensity', 'PixelIdxList');

        if ch == 1
            meanIntensity = nan(numel(cellData), nImages);
            hitOrMiss = false(numel(cellData), nImages);
        end

        meanIntensity(:, ch) = cat(1, cellData.MeanIntensity);

        threshold = mean(double(I), 'all') + std(double(I), 0, 'all');

        
        % if ismember(ch, [1 9 14])
        %     threshold = 3500;
        % else
        %     threshold = 100;
        % end

        hitOrMiss(:, ch) = meanIntensity(:, ch) > threshold;
        pixelIdxList = {cellData.PixelIdxList};

    end

    %%
    [~, fn] = fileparts(files(iFile).name);
    save([fn, '.mat'], 'meanIntensity', 'mask', 'hitOrMiss', 'pixelIdxList')

end