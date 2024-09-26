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

    for ii = 1:nImages

        I = imread(files(iFile).name, ii);

        cellData = regionprops(mask, I, 'MeanIntensity');

        if ii == 1

            storeData = nan(numel(cellData), nImages);

        end

        storeData(:, ii) = cat(1, cellData.MeanIntensity);
    end

    %%
    [~, fn] = fileparts(files(iFile).name);
    save([fn, '.mat'], 'storeData', 'mask')

end