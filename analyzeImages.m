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

    currFN = fullfile(dataDir, files(iFile).name);

    %Mask the images
    Imask = imread(currFN, ip.Results.MaskImage);
    
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

    [~, fn] = fileparts(files(iFile).name);

    for ch = 1:nImages

        I = imread(fullfile(dataDir, files(iFile).name), ch);
        cellData = regionprops(mask, I, 'Centroid', 'MeanIntensity', 'PixelIdxList');

        if ch == 1
            
            meanIntensity = nan(numel(cellData), nImages);
            hitOrMiss = false(numel(cellData), nImages);
            pixelIdxList = {cellData.PixelIdxList};
        end

        meanIntensity(:, ch) = cat(1, cellData.MeanIntensity);

        %threshold = mean(double(I), 'all') + std(double(I), 0, 'all');
        threshold = 1000;
        hitOrMiss(:, ch) = meanIntensity(:, ch) > threshold;
        
        %Make an output image showing the segmentation
        Iout = imfuse(I, bwperim(mask));
        Iout = imresize(Iout, 2);
        for ii = 1:numel(cellData)
            Iout = insertText(Iout, cellData(ii).Centroid *2, int2str(ii), 'BoxOpacity', 0, 'FontColor', 'white');
        end

        outputSubDir = fullfile(outputDir, fn);
        if ~exist(outputSubDir, 'dir')
            mkdir(outputSubDir)
        end
        imwrite(Iout, fullfile(outputSubDir, [fn, sprintf('img%02d_masked.tif', ch)]))

    end

    %%
    
    save(fullfile(outputDir, [fn, '.mat']), 'currFN', 'meanIntensity', 'mask', 'hitOrMiss', 'pixelIdxList')


    

end