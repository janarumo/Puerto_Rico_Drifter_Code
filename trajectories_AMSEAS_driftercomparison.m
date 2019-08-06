%% Script to generate particle trajectories of Sargassum seaweed near Puerto Rico.
% Written by Joseph Anarumo on 3/19/2019

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

addpath([root '/codaradm/HFR_Progs-2_1_3beta/matlab/external_matlab_packages/m_map/']);
addpath([root '/codaradm/HFR_Progs-2_1_3beta/matlab/general']);
addpath([root '/codaradm/HFR_Progs-2_1_3beta/matlab/trajectories']);
addpath([root '/codaradm/HFR_Progs-2_1_3beta/matlab/totals']);
%add_subdirectories_to_path([root '/codaradm/HFR_Progs-2_1_3beta/matlab/'],{'CVS','private','@'});


%% Load NOAA data
%AMSEAS Model
f = 'https://ecowatch.ncddc.noaa.gov/thredds/dodsC/ncom_amseas_agg/AmSeas_Apr_05_2013_to_Current_best.ncd';

% OSCAR Model
%

% FVCOM Model

%% Set date & time variables.

dnow= ((round(now*24))/24);
% dtime = dnow-1:1/24:dnow;
dtime = datenum(2019,5,29,10, 0, 0):1/24:datenum(2019,5,30,10, 0, 0);

%% Set Latitude & Longitude for figure window limits for each study region.

%sites={'North','East','South','La Parguera','West','VirginIslandsNorth','VirginIslandsSouth'};
sites={'La Parguera'};
 
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
        Area = 'VirginIslandsSouth';
end
 


% conf.HourPlot.axisLims=[-66 -65-36/60 17+50/60 18+10/60];

conf.HourPlot.Print=false;
conf.HourPlot.grid=1;

%% Create a Directory for all Processed Imagery 
%AFAI process imagery directories are created within the function
%AFAI_img2coordhighres_v1.m

%Directory for all k-means clustered algorithem imagery
AMSEAS_dir = [pwd '\AMSEAS_animations\'];
if ~exist(AMSEAS_dir, 'dir')
    mkdir(AMSEAS_dir);
end

%PNG images to be turned into animations
AMSEAS_imgs = [AMSEAS_dir  'AMSEAS_imgs_onedrifter\' ];
if ~exist(AMSEAS_imgs, 'dir')
    mkdir(AMSEAS_imgs);
end

%Sort by region
regionfolder = [AMSEAS_imgs n '\'];
if ~exist(regionfolder, 'dir')
    mkdir(regionfolder);
end

%Sort by date
dir_save = datestr(dtime(1), 'yyyymmdd');
dayfolder = [regionfolder dir_save '\'];
if ~exist(dayfolder, 'dir')
    mkdir(dayfolder);
end

%High Res Particle Tracking folder
gifs = [AMSEAS_dir  'AMSEAS_gifs_onedrifter\' ];
if ~exist(gifs, 'dir')
    mkdir(gifs);
end

% Also Sort gifs by region
regionfolder2 = [gifs n '\'];
if ~exist(regionfolder2, 'dir')
    mkdir(regionfolder2);
end

%% Process data
%conf.Totals.DomainName

conf.Totals.grid_lims=[(conf.HourPlot.axisLims(1)+360-1) (conf.HourPlot.axisLims(2)+360+1) ...
    conf.HourPlot.axisLims(3)-1 conf.HourPlot.axisLims(4)+1];

[TUVcat] = convert_AmSeas_NC_to_TUVstruct(f,dtime,conf);


%% Grid the total data onto a rectangular grid
[TUVcat,dim]=gridTotals(TUVcat,0,0);

X=TUVcat.LonLat(:,1);
Y=TUVcat.LonLat(:,2);
U=TUVcat.U;
V=TUVcat.V;
tt=TUVcat.TimeStamp(1:end);
tspan=TUVcat.TimeStamp(1):1/24:TUVcat.TimeStamp(end);

% %wp1=[17+52/60+0/3600 -65-55/60-0/3600];
% %wp1=[35.25 -75];
wp1=[conf.HourPlot.axisLims(3)+2/60 conf.HourPlot.axisLims(1)+5/60];%lat lon

resolution=2;
range=25;
 
% For just one drifter for quantitative analysis in middle of La Parguera:
% drifter=[-67 17+48/60];

[wp]=release_point_generation_matrix(wp1,resolution,range);

drifter=[wp(:,2) wp(:,1)];

[X1,Y1]=meshgrid(unique(X),unique(Y));

[r,c]=size(X1);

U1=reshape(U,r,c,length(TUVcat.TimeStamp));
V1=reshape(V,r,c,length(TUVcat.TimeStamp));

%% generate the particle trajectories
[x,y,ts]=particle_track_ode_grid_LonLat(X1,Y1,U1,V1,tt,tspan,drifter);

testdrift = [x,y,ts];
nn = datestr(TUVcat.TimeStamp(1), 'yyyymmdd');
save(['J:\caricoos\Drifter_mats\AMSEAS_mats_' nn '.mat'],'testdrift');

[r1,c1]=size(x);

%% determine which position estimates are Nans to use in the coloring of the 
%% particles
color_flag=~isnan(x);

%% When the drifter leaves the domain the position turns into nans
%% replace the nans with the last known position
xx=x;
for ii=1:c1
    tf=find(isnan(x(:,ii)),1,'first');
    x(tf:end,ii)=x(tf-1,ii);
    y(tf:end,ii)=y(tf-1,ii);
end

%% plot the results

%WHERE THE PNG FILES ARE BEING SAVED TO
% conf.Plot.BaseDir='C:\Users\Joe Anarumo\Documents\Puerto_Rico\Sargassum\Test_trajectories\Realtime_AMSEAS\';


conf.Plot.BaseDir=dayfolder;

f1=[root '/jpa104/caricoos/etopo1_Puerto_Rico.nc'];
 
[LON,LAT,Z] = read_in_etopo_bathy(f1);
% bathy=load ('/Users/roarty/Documents/GitHub/HJR_Scripts/data/bathymetry/puerto_rico/puerto_rico_6second_grid.mat');
% ind2= bathy.depthi==99999;
% bathy.depthi(ind2)=NaN;
bathylines=[ -50 -100 -500 -1000 -2000 -3000 -4000 -5000];

close all

for ii=1:r1
hold on
% m_proj('albers equal-area','lat',conf.HourPlot.axisLims(3:4),'long',conf.HourPlot.axisLims(1:2),'rect','on');
% m_gshhs_f('patch',[240,230,140]./255);
% m_grid('box','fancy','tickdir','in','xaxisloc','bottom','yaxisloc','left');
plotBasemap(vLon,vLat,Area,'Mercator','patch',[1 .69412 0.39216],'edgecolor','k');

conf.HourPlot.CoastfileN = 'j/caricoos/data/PR_North.mat';
conf.HourPlot.CoastfileE = 'j/caricoos/data/PR_East.mat';
conf.HourPlot.CoastfileS = 'j/caricoos/data/PR_South.mat';
conf.HourPlot.CoastfileLP = 'j/caricoos/data/PR_LaParguera.mat';
conf.HourPlot.CoastfileW = 'j/caricoos/data/PR_West.mat';
conf.HourPlot.CoastfileVIN = 'j/caricoos/data/VI_North.mat';
conf.HourPlot.CoastfileVIS = 'j/caricoos/data/VI_South.mat';

%% plot bathymetry
[cs, h1] = m_contour(LON,LAT, Z,bathylines);
clabel(cs,h1,'fontsize',8,'Color',[0.8 0.8 0.8]);
set(h1,'LineColor',[0.8 0.8 0.8])


%% plot entire track in gray
if ii>=2 
    m_plot(x(1:ii,:),y(1:ii,:),'-','Color',[0.5 0.5 0.5]);
end 

%% plot last 6 hours in black 
if ii>6
    m_plot(x(ii-6:ii,:),y(ii-6:ii,:),'-','Color','k','LineWidth',2);
elseif ii>1
    m_plot(x(1:ii,:),y(1:ii,:),'-','Color','k','LineWidth',2);
end

%% plot last location of drifter in red
m_plot(x(ii,:),y(ii,:),'ro','MarkerFaceColor','r');

if ~isempty(find(isnan(xx(ii,:)), 1)) 
    m_plot(x(ii,find(isnan(xx(ii,:)))),y(ii,find(isnan(xx(ii,:)))),'bo','MarkerFaceColor','b');
end 

%% add zeros before the number string
N=append_zero(ii);

%%-------------------------------------------------
%% Add title string

conf.HourPlot.TitleString = [n,' Particle Trajectories: ', ...
                            datestr(tspan(ii),'mm/dd/yyyy HH:MM'),' ',TUVcat.TimeZone(1:3)];

hdls.title = title( conf.HourPlot.TitleString, 'fontsize', 12,'color',[0 0 0] );

timestamp(1,'trajectories_AMSEAS.m')

if ~exist(conf.Plot.BaseDir, 'dir')
    mkdir(conf.Plot.BaseDir)
end

print(1,'-dpng','-r100',[ conf.Plot.BaseDir conf.HourPlot.DomainName '_' datestr(tspan(ii),'yyyy_mm_dd_HHMM') '.png'])

close all
clear conf.HourPlot.TitleString

end


%% TURN DAILY FILES INTO ANIMATED GIFS

for ii=1:length(tspan)
    if ii==1
        file_NameTemp = [ conf.HourPlot.DomainName '_' datestr(tspan(ii),'yyyy_mm_dd_HHMM') '.png'];
file_name = file_NameTemp;
    else
        file_NameTemp = [ conf.HourPlot.DomainName '_' datestr(tspan(ii),'yyyy_mm_dd_HHMM') '.png'];
        file_name = [file_name {file_NameTemp}];
    end
end
%WHERE THE PNG FILES CAN BE FOUND
file_path = dayfolder;
file_name=sort(file_name);

file_name2 = [ 'Puerto Rico' '_'  datestr(tspan(1),'yyyy_mm_dd') '.gif'];
%WHERE ANIMATED GIFS ARE BEING SAVED TO
file_path2 = regionfolder2;

loops=65535;    %Forever loop
delay=0;        %delay between images

h = waitbar(0,['0% done'],'name','Progress') ;
for i=1:length(file_name)
    if strcmpi('gif',file_name{i}(end-2:end))
        [M  c_map]=imread([file_path,file_name{i}]);
    else
        a=imread([file_path,file_name{i}]);
        [M  c_map]= rgb2ind(a,256);
    end
    if i==1
        imwrite(M,c_map,[file_path2,file_name2],'gif','LoopCount',loops,'DelayTime',delay)
    elseif i==length(file_name)
        imwrite(M,c_map,[file_path2,file_name2],'gif','WriteMode','append','DelayTime',delay)
    else
        imwrite(M,c_map,[file_path2,file_name2],'gif','WriteMode','append','DelayTime',delay)
    end
    waitbar(i/length(file_name),h,[num2str(round(100*i/length(file_name))),'% done']) ;
end
close(h);
end
