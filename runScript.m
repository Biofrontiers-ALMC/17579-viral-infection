clearvars
clc

% registerImages('D:\Projects\ALMC Tickets\EmmaWS\data\20240912', ...
%     'D:\Projects\ALMC Tickets\EmmaWS\Processed\20241107\RegisteredImages');

%%
% measureIntensity('D:\OneDrive - UCB-O365\Shared\temp2\Processed\20241107\RegisteredImages\H1N1', ...
%     'D:\OneDrive - UCB-O365\Shared\temp2\Processed\20241119\H1N1')
% measureIntensity('D:\OneDrive - UCB-O365\Shared\temp2\Processed\20241107\RegisteredImages\H3N2', ...
%     'D:\OneDrive - UCB-O365\Shared\temp2\Processed\20241119\H3N2')

measureIntensity('D:\Projects\ALMC Tickets\EmmaWS\Processed\20241107\RegisteredImages\H1N1', ...
    'D:\OneDrive - UCB-O365\Shared\temp2\Processed\20241119\H1N1')
measureIntensity('D:\Projects\ALMC Tickets\EmmaWS\Processed\20241107\RegisteredImages\H3N2', ...
    'D:\OneDrive - UCB-O365\Shared\temp2\Processed\20241119\H3N2')

%% Analyze the resulting data
exportData('D:\OneDrive - UCB-O365\Shared\temp2\Processed\20241119\H3N2', 'D:\OneDrive - UCB-O365\Shared\temp2\Processed\20241119\H3N2', {'mock_F10', 'mock_G6'});
exportData('D:\OneDrive - UCB-O365\Shared\temp2\Processed\20241119\H1N1', 'D:\OneDrive - UCB-O365\Shared\temp2\Processed\20241119\H1N1', {'mock_E_bottom', 'mock_E8'});