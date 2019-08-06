tic

clear all
close all
clc
%% determine which computer you are running the script on
compType = computer;

if ~isempty(strmatch('PCWIN64', compType))
     root = '/Volumes';
else
     root = '/home';
end


conf.HourPlot.Type='UWLS';

conf.HourPlot.VectorScale=0.004;
conf.HourPlot.ColorMap='jet';
conf.HourPlot.ColorTicks=0:10:100;
conf.HourPlot.axisLims=[-69 -65 16+00/60 18+40/60];

conf.Totals.grid_lims=[-69 -65 16+00/60 18+40/60];

radial_type='measured';

conf.HourPlot.DomainName='Puerto Rico';
conf.HourPlot.Print=false;
conf.HourPlot.CoastFile='C:/meanHFRcoverage/PR_coast3.mat';


conf.UWLS.BaseDir=[root '/codaradm/data/totals/caracoos/oi/mat/13MHz/measured/'];
conf.UWLS.FilePrefix='tuv_CARA_';
conf.UWLS.FileSuffix='.mat';
conf.UWLS.MonthFlag=true;

conf.OI.BaseDir=[root '/codaradm/data/totals/caracoos/oi/mat/13MHz/' radial_type '/'];
conf.OI.FilePrefix='tuv_OI_CARA_';
conf.OI.FileSuffix='.mat';
conf.OI.MonthFlag=true;

% conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/MARACOOS/20151202_YR5.0_Progress/PR_Plots/';
% conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/02_Collaborations/Puerto_Rico/20160614_Progress_Report/PR_Plots_South/';
% conf.Plot.PrintPath='/Users/hroarty/COOL/01_CODAR/02_Collaborations/Puerto_Rico/20161201_Progress_Report/';

conf.Plot.PrintPath='C:/Users/Joe Anarumo/Documents/MATLAB/HFRcoveragetotals/daily/';
% conf.Plot.PrintPath='C:/Users/Joe Anarumo/Documents/MATLAB/HFRcoveragetotals/monthly/';

%dtime = datenum(2014,5,1,0,0,2):1/24:datenum(2014,05,2,0,0,0);

% months=[datenum(2019,05,1) datenum(2019 ,6,1)];
months=[ datenum(2019 ,05 ,22):datenum(2019,06,19)];

% months=datenum(2015,12,1:3);

for ii=1:numel(months)-1

%% Declare the time that you want to load
dtime = months(ii):1/24:months(ii+1);



%% load the total data depending on the config
s=conf.HourPlot.Type;
% [f]=datenum_to_directory_filename(conf.(s).BaseDir,dtime,conf.(s).FilePrefix,conf.(s).FileSuffix,conf.(s).MonthFlag);
% f='http://hfrnet.ucsd.edu/thredds/dodsC/HFR/PRVI/6km/hourly/RTV/HFRADAR,_Puerto_Rico_and_the_US_Virgin_Islands,_6km_Resolution,_Hourly_RTV_best.ncd';
f='http://hfrnet-tds.ucsd.edu/thredds/dodsC/HFR/PRVI/6km/hourly/RTV/HFRADAR_Puerto_Rico_and_the_US_Virgin_Islands_6km_Resolution_Hourly_RTV_best.ncd';

%% concatenate the total data
[TUVcat] = convert_NN_NC_to_TUVstruct(f,dtime,conf);

ii = false(size(TUVcat));

%% Plot the base map for the radial file
plotBasemap( conf.HourPlot.axisLims(1:2),conf.HourPlot.axisLims(3:4),conf.HourPlot.CoastFile,'Mercator','patch',[240,230,140]./255,'edgecolor','k')

hold on

%% Plot the percent coverage
colormap('jet');
colorbar

percentLimits = [0,100];
conf.HourPlot.ColorTicks = 0:10:100;
[h,ts]=plotdata(TUVcat,'perc','m_line',percentLimits);
set(h,'markersize',15);

%% plot bathymetry
f='C:/Users/Joe Anarumo/Documents/Puerto_Rico/Sargassum/etopo1_Puerto_Rico.nc';
 
[LON,LAT,Z] = read_in_etopo_bathy(f);
% bathy=load ('/Users/roarty/Documents/GitHub/HJR_Scripts/data/bathymetry/puerto_rico/puerto_rico_6second_grid.mat');
% ind2= bathy.depthi==99999;
% bathy.depthi(ind2)=NaN;
bathylines=[ -50 -100 -500 -1000 -2000 -3000 -4000 -5000];

[cs, h1] = m_contour(LON,LAT, Z,bathylines);
clabel(cs,h1,'fontsize',8,'Color',[0.8 0.8 0.8]);
set(h1,'LineColor',[0.8 0.8 0.8])


%%-------------------------------------------------
%% Plot location of sites
try
%% read in the MARACOOS sites
dir='/Users/roarty/Documents/GitHub/HJR_Scripts/data/';
file='caricoos_codar_sites_2018.txt';
[C]=read_in_maracoos_sites(dir,file);


%% plot the location of the radar sites

for ii=1:5
    hdls.RadialSites=m_plot(C{3}(ii),C{4}(ii),'^k','markersize',8,'linewidth',2);
end

catch
end

%-------------------------------------------------
% Plot the colorbar
try
  conf.HourPlot.ColorTicks;
catch
  ss = max( cart2magn( data.TUV.U(:,I), data.TUV.V(:,I) ) );
  conf.HourPlot.ColorTicks = 0:10:ss+10;
end
caxis( [ min(conf.HourPlot.ColorTicks), max(conf.HourPlot.ColorTicks) ] );
%colormap( feval( p.HourPlot.ColorMap, numel(p.HourPlot.ColorTicks)-1 ) );

%colormap(winter(10));

% load ('/home/hroarty/Matlab/cm_jet_32.mat')


cax = colorbar;
hdls.colorbar = cax;
hdls.ylabel = ylabel( cax, ['NOTE: Data outside color range will be ' ...
                    'saturated.'], 'fontsize', 8 );
hdls.xlabel = xlabel( cax, '%', 'fontsize', 12 );

set(cax,'ytick',conf.HourPlot.ColorTicks,'fontsize',14,'fontweight','bold')

%-------------------------------------------------
% % Add title string
% try, p.HourPlot.TitleString;
% catch
%   p.HourPlot.TitleString = [p.HourPlot.DomainName,' ',p.HourPlot.Type,': ', ...
%                             datestr(dtime,'yyyy/mm/dd HH:MM'),' ',TUVcat.TimeZone(1:3)];
% end
% hdls.title = title( p.HourPlot.TitleString, 'fontsize', 16,'color',[.2 .3 .9] );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add title string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
titleStr = {sprintf('%s %s Coverage', ...
                    conf.HourPlot.DomainName,conf.HourPlot.Type),
            sprintf('From %s to %s',datestr(dtime(1),'dd-mmm-yyyy HH:MM'),datestr(dtime(end),'dd-mmm-yyyy HH:MM'))};
hdls.title = title(titleStr, 'fontsize', 14 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add path of script to image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timestamp(1,'mean_coverage_plot_PR_NN.m')

sd_str=datestr(min(dtime),'yyyymmdd');
ed_str=datestr(max(dtime),'yyyymmdd');

print(1,'-dpng','-r400',[conf.Plot.PrintPath 'Total_Coverage_' conf.HourPlot.Type '_' ...
    conf.HourPlot.DomainName '_' radial_type '_' sd_str '_' ed_str '.png'])

close all

end

toc




