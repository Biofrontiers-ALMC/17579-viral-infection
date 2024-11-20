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
addParameter(ip, 'GridImages', [2, 5, 10, 13]);
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

    % imshow(nuclMask)
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

    % imshowpair(nuclMask, cellMask)

    %imshowpair(Imask, bwperim(mask))

    %% Measure data

    nImages = numel(imfinfo(fullfile(dataDir, files(iFile).name)));

    [~, fn] = fileparts(files(iFile).name);

    for ch = 1:nImages

        I = imread(fullfile(dataDir, files(iFile).name), ch);

        %Normalize the image data to a similar range
        meanI = mean(I, "all");
        stdI = std(double(I), 0, 'all');
        normI = (double(I) - meanI)/stdI;

        cellData = regionprops(cellMask, normI, 'Centroid', 'MeanIntensity', 'PixelIdxList', 'PixelValues');
        % nuclData = regionprops(nuclMask, I, 'MeanIntensity');
        
        if ch == 1
            meanCellIntensity = nan(numel(cellData), nImages);
            upperPrctileIntensity = nan(numel(cellData), nImages);
            pixelIdxList = {cellData.PixelIdxList};            
        end

        meanCellIntensity(:, ch) = cat(1, cellData.MeanIntensity);

        for iCell = 1:numel(cellData)
            %innerThreshold = prctile(cellData(iCell).PixelValues, 50, 'all');
            %upperPrctileIntensity(iCell, ch) = mean(cellData(iCell).PixelValues(cellData(iCell).PixelValues > innerThreshold), "all");
            %upperPrctileIntensity(iCell, ch) = prctile(cellData(iCell).PixelValues, 95, 'all');
            % th = otsuthresh(I(cellData(iCell).PixelIdxList));
            % th = th * max(I(cellData(iCell).PixelIdxList));

            %Measure the local background?
            cm = false(size(I));
            cm(cellData(iCell).PixelIdxList) = true;
            
            bgm = imdilate(cm, strel('disk', 10));
            bgm(cellMask) = false;
            th = mean(normI(bgm), 'all') + 1.8 * std(double(normI(bgm)), 1, 'all');

            upperPrctileIntensity(iCell, ch) = mean(cellData(iCell).PixelValues(cellData(iCell).PixelValues > th), "all");

            % if iCell == 60            
            %     Iout = imfuse(I, bwperim(cm));
            % 
            %     cm(normI < th) = false;
            %     Iout = imfuse(Iout, bwperim(cm));
            %     imshow(Iout)
            %     keyboard
            % end
        end
        % meanNuclIntensity(:, ch) = cat(1, nuclData.MeanIntensity);

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
    
    save(fullfile(outputDir, [fn, '.mat']), 'currFN', 'meanCellIntensity', 'cellMask', 'nuclMask', 'pixelIdxList', 'upperPrctileIntensity')


    

end