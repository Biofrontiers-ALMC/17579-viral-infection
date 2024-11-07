clearvars
clc
data_mock = load('D:\Projects\ALMC Tickets\EmmaWS\Processed\20241107\H3N2\mock_F10.mat');
data_mock2 = load('D:\Projects\ALMC Tickets\EmmaWS\Processed\20241107\H3N2\mock_G6.mat')';
data_well = load('D:\Projects\ALMC Tickets\EmmaWS\Processed\20241107\H3N2\well_2_C10.mat');

%%
figure(1);
subplot(2, 2, 1)
bar(data_mock.meanIntensity(:,[2 3 4, 6 7 8, 10 11 12, 15 16]))
ylim([0 4500])

subplot(2, 2, 2)
bar(data_well.meanIntensity(:,[2 3 4, 6 7 8, 10 11 12, 15 16]))
ylim([0 4500])

subplot(2, 2, 3)
bar(data_mock2.meanIntensity(:,[2 3 4, 6 7 8, 10 11 12, 15 16]))
ylim([0 4500])

% subplot(2, 2, 4)
% bar(data_mock.meanIntensity(:,[2 3 4, 6 7 8, 10 11 12, 15 16]))
% ylim([0 4500])