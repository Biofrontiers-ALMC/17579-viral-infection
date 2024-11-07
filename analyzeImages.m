function analyzeImages(dataDir, outputDir, varargin)
%ANALYZEIMAGES  Analyze images to identify cells and measure intensity
%
%  ANALYZEIMAGES(DATADIR, OUTPUTDIR) will process all TIFF files in the
%  specified DATADIR. It is assumed that each TIFF file is a stack, with
%  each image corresponding to different fluorescent markers. 
% 
%  

%Parse the inputs
ip = inputParser;
addParameter(ip, 'MaskImage', 1);
parse(ip, varargin{:})

files = dir(fullfile(dataDir, '*.tif'));

if isempty(files)
    error('analyzeImages:NoTIFFfiles', ...
        'No .tif files were found in the directory %s.', dataDir);
end

if ~exist(outputDir)
    mkdir(outputDir)
end

%Process the images
for iFile = 1:numel(files)

    %Mask the images
    Imask = imread(fullfile(dataDir, files(iFile).name), ip.Results.MaskImage);
    
    mask = imbinarize(Imask);
    mask = imopen(mask, strel('disk', 1));

    %Try to separate clusters of objects
    dd = -bwdist(mask);
    dd = imhmin(dd, 1);

    dd(~mask) = -Inf;

    LL = watershed(dd);
    mask(LL == 0) = 0;

    mask = imclearborder(mask);

    %imshowpair(Imask, bwperim(mask))

    %% Measure data

    nImages = numel(imfinfo(fullfile(dataDir, files(iFile).name)));

    for ch = 1:nImages

        I = imread(fullfile(dataDir, files(iFile).name), ch);

        cellData = regionprops(mask, I, 'MeanIntensity', 'PixelIdxList');

        if ch == 1
            meanIntensity = nan(numel(cellData), nImages);
            hitOrMiss = false(numel(cellData), nImages);
        end

        meanIntensity(:, ch) = cat(1, cellData.MeanIntensity);

        threshold = mean(double(I), 'all') + std(double(I), 0, 'all');
        hitOrMiss(:, ch) = meanIntensity(:, ch) > threshold;
        
        pixelIdxList = {cellData.PixelIdxList};

    end

    %%
    [~, fn] = fileparts(files(iFile).name);
    save(fullfile(outputDir, [fn, '.mat']), 'meanIntensity', 'mask', 'hitOrMiss', 'pixelIdxList')

end