%% Clear workspace

close all
clear all
clc

% Determine which computer you are working on

compType=computer;

if ~isempty(strmatch('PCWIN64',compType))
    root='L:';
else
    root='/home';
end

%% Add directories to MATLAB path for following functions.

addpath([root '/codaradm/HFR_Progs-2_1_3beta/matlab/external_matlab_packages/m_map/'])
addpath([root '/codaradm/HFR_Progs-2_1_3beta/matlab/general']);
addpath([root '/codaradm/HFR_Progs-2_1_3beta/matlab/trajectories']);
addpath([root '/codaradm/HFR_Progs-2_1_3beta/matlab/totals']);
%add_subdirectories_to_path([root '/codaradm/HFR_Progs-2_1_3beta/matlab/'],{'CVS','private','@'});


conf.HourPlot.axisLims=[-68 -64-30/60 17+30/60 18+55/60];
% box_one_x1 = -68;
% box_one_x2 = -64-30/60;
% box_one_y1 = 17+30/60;
% box_one_y2 = 18+55/60;

%conf.HourPlot.Print=false;
%conf.HourPlot.grid=1;


%% plot 

f1=[root '/jpa104/caricoos/etopo1_Puerto_Rico.nc'];
 
[LON,LAT,Z] = read_in_etopo_bathy(f1);
% bathy=load ('/Users/roarty/Documents/GitHub/HJR_Scripts/data/bathymetry/puerto_rico/puerto_rico_6second_grid.mat');
% ind2= bathy.depthi==99999;
% bathy.depthi(ind2)=NaN;
bathylines=[ -50 -100 -500 -1000 -2000 -3000 -4000 -5000];

close all


hold on
m_proj('albers equal-area','lat',conf.HourPlot.axisLims(3:4),'long',conf.HourPlot.axisLims(1:2),'rect','on');
m_gshhs_f('patch',[240,230,140]./255);
m_grid('box','fancy','tickdir','in','xaxisloc','bottom','yaxisloc','left');

%% plot bathymetry
% [cs, h1] = m_contour(LON,LAT, Z,bathylines);
% clabel(cs,h1,'fontsize',8,'Color',[0.8 0.8 0.8]);
% set(h1,'LineColor',[0.8 0.8 0.8])

%% Set Latitude & Longitude for figure window limits for each study region.

sites={'North','East','South','La Parguera','West','VirginIslandsNorth','VirginIslandsSouth'};
% sites={'North'};
 
for gg=1:length(sites)
 
n=sites{gg};
 
switch n
    case 'North'
       conf.HourPlot.axisLims=[-66-20/60 -65-54/60 18+25/60 18+45/60];
        conf.HourPlot.DomainName='Puerto_Rico_North';
        vLon = [-66-20/60 -65-54/60];
        vLat = [18+25/60 18+45/60];
        Area = 'North';
    case 'East'
        conf.HourPlot.axisLims=[-66 -65-34/60 17+50/60 18+10/60];
        conf.HourPlot.DomainName='Puerto_Rico_East';
        vLon = [-66 -65-34/60];
        vLat = [17+50/60 18+10/60];
        Area = 'East';
    case 'South'
        conf.HourPlot.axisLims=[-66-50/60 -66-24/60 17+40/60 18];
        conf.HourPlot.DomainName='Puerto_Rico_South';
        vLon = [-66-50/60 -66-24/60];
        vLat = [17+40/60 18];
        Area = 'South';
    case 'La Parguera'       
        conf.HourPlot.axisLims=[-67-13/60 -66-47/60 17+40/60 18];
        conf.HourPlot.DomainName='Puerto_Rico_LaParguera';
        vLon = [-67-13/60 -66-47/60];
        vLat = [17+40/60 18];
        Area = 'La_Parguera';
    case 'West'
        conf.HourPlot.axisLims=[-67-36/60 -67-10/60 18 18+20/60];
        conf.HourPlot.DomainName='Puerto_Rico_West'; 
        vLon = [-67-36/60 -67-10/60];
        vLat = [18 18+20/60];
        Area = 'West';
    case 'VirginIslandsNorth'
        conf.HourPlot.axisLims=[-65-14/60 -64-48/60 18+20/60 18+40/60];
        conf.HourPlot.DomainName='Virgin_Islands_North';
        vLon = [-65-14/60 -64-48/60];
        vLat = [18+20/60 18+40/60];
        Area = 'VirginIslandsNorth';
    case 'VirginIslandsSouth'
        conf.HourPlot.axisLims=[-65-14/60 -64-48/60 18 18+20/60];
        conf.HourPlot.DomainName='Virgin_Islands_South';
        vLon = [-65-14/60 -64-48/60];
        vLat = [18 18+20/60];
        Area = 'VirginIslandsSouth'
end



lims=conf.HourPlot.axisLims;
LON=lims([1 2 2 1 1]);
LAT=lims([3 3 4 4 3]);


m_plot(LON,LAT,'r','LineWidth',2)

end

m_plot(-65.8281,18.05245, 'go', 'LineWidth', 5)
m_plot(-67.1889,18.0999, 'go', 'LineWidth', 5)


%% read in the MARACOOS HFR sites
dir='C:\Users\Joe Anarumo\Documents\Rutgers work docs\';
file='maracoos_codar_sites_2018.txt';
[C]=read_in_maracoos_sites(dir,file);


%% ------------------------------------------------------------------------
% Plot location of HFR sites
%try

% site_num=18:24;%% 13 MHz Network
% site_num=[19 20 21 29 30];%% 13 MHz Network
% site_num=30;%% 13 MHz Network
site_num=[44 45 46 47 48];%% 
spacing2 = 0.1
% plot the location of the 13 MHz sites

for ii=1:length(site_num)
    hdls.RadialSites=m_plot(C{3}(site_num(ii)),C{4}(site_num(ii)),'^r','markersize',8,'linewidth',2,'MarkerFaceColor','r');
%     m_text(C{3}(site_num(ii))-spacing2,C{4}(site_num(ii)),C{2}(site_num(ii)),'FontSize',12,'FontWeight','bold','Color','r');
end

%catch
%end


% Yabucoa - El Negro wind sensor: 18.05245 and lon: -65.8281



%% Add title string

conf.HourPlot.TitleString = ['Puerto Rico/Virgin Islands Study Areas'];

hdls.title = title( conf.HourPlot.TitleString, 'fontsize', 12,'color',[0 0 0] );

timestamp(1,'Puerto_Rico_Area_Plot.m')

print('Puerto_Rico_Area_Plot','-dpng')

% close all
% clear conf.HourPlot.TitleString

for gg=1:length(sites)
 
n=sites{gg};
 
switch n
    case 'North'
       conf.HourPlot.axisLims=[-66-20/60 -65-54/60 18+25/60 18+45/60];
        conf.HourPlot.DomainName='Puerto_Rico_North';
    case 'East'
        conf.HourPlot.axisLims=[-66 -65-34/60 17+50/60 18+10/60];
        conf.HourPlot.DomainName='Puerto_Rico_East';
    case 'South'
        conf.HourPlot.axisLims=[-66-50/60 -66-24/60 17+40/60 18];
        conf.HourPlot.DomainName='Puerto_Rico_South';
    case 'La Parguera'       
        conf.HourPlot.axisLims=[-67-13/60 -66-47/60 17+40/60 18];
        conf.HourPlot.DomainName='Puerto_Rico_LaParguera';      
    case 'West'
        conf.HourPlot.axisLims=[-67-36/60 -67-10/60 18 18+20/60];
        conf.HourPlot.DomainName='Puerto_Rico_West';     
    case 'VirginIslandsNorth'
        conf.HourPlot.axisLims=[-65-14/60 -64-48/60 18+20/60 18+40/60];
        conf.HourPlot.DomainName='Virgin_Islands_North';
    case 'VirginIslandsSouth'
        conf.HourPlot.axisLims=[-65-14/60 -64-48/60 18 18+20/60];
        conf.HourPlot.DomainName='Virgin_Islands_South';
end



lims=conf.HourPlot.axisLims;
% LON=lims([1 2 2 1 1]);
% LAT=lims([3 3 4 4 3]);

% m_plot(LON,LAT,'r','LineWidth',2)

%% Google Earth boxes

box_two_x1 = lims([2]);
box_two_x2 = lims([1]);
box_two_y1 = lims([4]);
box_two_y2 = lims([3]);

% output1 = ge_box(box_one_x1,...
%                  box_one_x2,...
%                  box_one_y1,...
%                  box_one_y2,...
%                  'altitude', 20);

output2 = ge_box(box_two_x2,...
                 box_two_x1,...
                 box_two_y2,...
                 box_two_y1,...
                 'altitude',5000, ...
                     'name','box number 2', ...
                'lineWidth',5.0, ...
                'lineColor','FFFF0000', ...
                'polyColor','403e83ff',...
              'description','mumbojumbo',...
              'msgToScreen',1);

kmlFileName = [conf.HourPlot.DomainName '.kml'];

ge_output(kmlFileName,[output2],'name',kmlFileName);
end




