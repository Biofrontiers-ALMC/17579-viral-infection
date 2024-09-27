clearvars
clc

reader = BioformatsImage('D:\Projects\ALMC Tickets\EmmaWS\data\20240912\Round 1--seg 1 550 seg 2 633\H3N2\well_1_D10.nd2');
moving = getPlane(reader, 1, 2, 1);

reader2 = BioformatsImage('D:\Projects\ALMC Tickets\EmmaWS\data\20240912\Round 4--seg 8 550 seg 2 633\H3N2\well_1_D10.nd2');
fixed = getPlane(reader2, 1, 1, 1);


tform = imregtform(moving, fixed, "rigid", optimizer, metric);

movingRegistered = imwarp(moving, tform, "OutputView", imref2d(size(fixed)));

imshowpair(fixed, movingRegistered, "Scaling", "joint")

%%

movingTest = imtophat(moving, strel('disk', 2));
movingTest = medfilt2(movingTest, [2 2]);
imshow(movingTest, [])

fixedTest = imtophat(fixed, strel('disk', 2));
fixedTest = medfilt2(fixedTest, [2 2]);
imshow(fixedTest, [])

tform = imregtform(movingTest, fixedTest, "rigid", optimizer, metric);
movingRegistered = imwarp(movingTest, tform, "OutputView", imref2d(size(fixed)));

imshowpair(fixedTest, movingRegistered, "Scaling", "joint")


%%
%Try to enhance circles

movingR = imresize(moving, 2);

mask = imbinarize(movingR);
mask = imopen(mask, strel('disk', 2));

mask = imresize(mask, 0.5, 'nearest');
mask = uint8(mask * 255);

fixedR = imresize(fixed, 2);

maskF = imbinarize(fixedR);
maskF = imopen(maskF, strel('disk', 2));

maskF = imresize(maskF, 0.5, 'nearest');
maskF = uint8(maskF * 255);

[optimizer,metric] = imregconfig("multimodal");
tform = imregtform(mask, maskF, "rigid", optimizer, metric);

movingRegistered = imwarp(moving, tform, "OutputView", imref2d(size(fixed)));
imshowpair(fixedTest, movingRegistered, "Scaling", "joint")


%%

[centers, radii] = imfindcircles(movingTest, [2, 8]);



mask = false(size(moving));
for ii = 1:size(centers, 1)
end

mask = circles2mask(centers, radii, size(moving));

imshowpair(moving, mask)