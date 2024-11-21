function measureIntensity(dataDir, outputDir, varargin)
%MEASUREINTENSITY  Analyze images to identify cells and measure intensity
%
%  MEASUREINTENSITY(DATADIR, OUTPUTDIR) will process all TIFF files in the
%  specified DATADIR. It is assumed that each TIFF file is a stack, with
%  each image corresponding to different fluorescent markers. The images
%  should already be registered.
%
%  See also: registerImages

%Parse the inputs
ip = inputParser;
addParameter(ip, 'NuclearImage', 1);
addParameter(ip, 'CellMaskImage', 14);
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
    Inucl = imread(currFN, ip.Results.NuclearImage);    
    %Imask = imread(currFN, ip.Results.MaskImage);
    
    nuclMask = imbinarize(Inucl);
    nuclMask = imopen(nuclMask, strel('disk', 1));

    %Try to separate clusters of objects
    dd = -bwdist(~nuclMask);
    dd(~nuclMask) = 0;
    dd = imhmin(dd, 1);    

    LL = watershed(dd);
    nuclMask(LL == 0) = 0;

    nuclMask = imclearborder(nuclMask);

%%
    Icell = imread(currFN, ip.Results.CellMaskImage);
    
    cellMask = imbinarize(Icell, 'adaptive');
    cellMask = imopen(cellMask, strel('disk', 1));

    dd = -bwdist(~cellMask);
    dd(~cellMask) = 0;
    dd = imimposemin(dd, nuclMask);

    LL = watershed(dd);
    cellMask(LL == 0) = 0;

    cellMask = imclearborder(cellMask);
    cellMask = bwareaopen(cellMask, 30);

    %% Measure data

    nImages = numel(imfinfo(fullfile(dataDir, files(iFile).name)));

    [~, fn] = fileparts(files(iFile).name);

    for ch = 1:nImages

        I = imread(fullfile(dataDir, files(iFile).name), ch);
        
        currData = regionprops(cellMask, I, 'Centroid', 'PixelIdxList');

        if ch == 1

            %Initialize a struct for storage
            cellData = currData;

            for iCell = 1:numel(currData)
                cellData(iCell).RawPixelValues = cell(nImages, 1);
                cellData(iCell).RawMeanIntensity = zeros(nImages, 1);
                cellData(iCell).RawMaxIntensity = zeros(nImages, 1);
                cellData(iCell).NormPixelValues = cell(nImages, 1);
                cellData(iCell).NormMeanIntensity = zeros(nImages, 1);
                cellData(iCell).NormMaxIntensity = zeros(nImages, 1);
            end

        end

        %Background subtract image
        Iclean = imtophat(I, strel('disk', 30));
        Iclean = medfilt2(Iclean, [3, 3]);
        Iclean = double(Iclean);

        %Calculate the background mean and use this as the threshold
        bgMean = mean(Iclean(~cellMask), 'all');
        bgStd = std(Iclean(~cellMask), 0, 'all');

        th = bgMean + bgStd;


        % imshow(Iclean,  [])
        % keyboard

        % %Normalize the image data to a similar range
        % meanI = mean(Iclean, "all");
        % stdI = std(double(Iclean), 0, 'all');
        % normI = (double(Iclean) - meanI)/stdI;

        %Measure all cell data
        for iCell = 1:numel(currData)

            cellData(iCell).RawPixelValues{ch} = I(cellData(iCell).PixelIdxList);
            cellData(iCell).RawMeanIntensity(ch) = mean(I(cellData(iCell).PixelIdxList), 'all');
            cellData(iCell).RawMaxIntensity(ch) = max(I(cellData(iCell).PixelIdxList), [], 'all');

            %Find any pixels which are greater than the background
            %threshold
            cellData(iCell).positivePixels{ch} = cellData(iCell).PixelIdxList(cellData(iCell).RawPixelValues{ch} > th);
            cellData(iCell).isPositive = numel(cellData(iCell).positivePixels{ch}) > 1;

            % cellData(iCell).NormPixelValues{ch} = normI(cellData(iCell).PixelIdxList);
            % cellData(iCell).NormMeanIntensity(ch) = mean(normI(cellData(iCell).PixelIdxList), 'all');
            % cellData(iCell).NormMaxIntensity(ch) = max(normI(cellData(iCell).PixelIdxList), [], 'all');

        end

        % for iCell = 1:numel(cellData)
        %     %innerThreshold = prctile(cellData(iCell).PixelValues, 50, 'all');
        %     %upperPrctileIntensity(iCell, ch) = mean(cellData(iCell).PixelValues(cellData(iCell).PixelValues > innerThreshold), "all");
        %     %upperPrctileIntensity(iCell, ch) = prctile(cellData(iCell).PixelValues, 95, 'all');
        %     % th = otsuthresh(I(cellData(iCell).PixelIdxList));
        %     % th = th * max(I(cellData(iCell).PixelIdxList));
        % 
        %     %Measure the local background?
        %     cm = false(size(I));
        %     cm(cellData(iCell).PixelIdxList) = true;
        % 
        %     bgm = imdilate(cm, strel('disk', 10));
        %     bgm(cellMask) = false;
        %     th = mean(normI(bgm), 'all') + 1.8 * std(double(normI(bgm)), 1, 'all');
        % 
        %     upperPrctileIntensity(iCell, ch) = mean(cellData(iCell).PixelValues(cellData(iCell).PixelValues > th), "all");
        % 
        % end        

        %Make an output image showing the segmentation
        Iout = imfuse(I, bwperim(cellMask));
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
    
    save(fullfile(outputDir, [fn, '.mat']), 'currFN', 'cellData')


    

end