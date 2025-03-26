%% %仿真高发低收ATI GEOSAR径向速度（地形相位）及可见性范围画图
%%% 20250306
clc;clear;close all;
stkInit

%% 先判断可见性再计算下视角范围
StartTime = 1;%后半天，下8
StopTime = 86400;
StepTime = 1;
SatName = {'LUDI_TANCE-4_01A_57624'};
TargetName = {'Target1'};
LonRange = [-180:1:180];
LatRange = [-90:1:90];
% [Lon,Lat] = meshgrid(LonRange,LatRange);

%% 可见性分析
for i = 1:length(LonRange)
    for j = 1:length(LatRange)
        stkSetFacPosLLA(strcat('*/Target/Target1'),...
            [deg2rad(LatRange(j));deg2rad(LonRange(i))]); 
        [AccessData1] = stkAccess(strcat('*/Satellite/',SatName{1}),strcat('*/Target/Target1'));
        if isempty(AccessData1)
            Map(j,i) = 0;
        else
            Map(j,i) = 1;
        end
    end
end
%%%结果存储为0826.mat
%% 画出可见性区域
% worldmap('world');
figure(1);
load coastlines.mat;
imagesc(LonRange,LatRange,Map,'AlphaData',0.5);axis xy;
colormap(gray);
hold on;
geoshow(coastlat,coastlon,'LineWidth',1.5,'Color','k');
hold on;

% plotm(coastlat,coastlon);
%% 计算径向速度大小
[ReportData] = stkReport(['*/Satellite/',SatName{1}],'Fixed Position Velocity',StartTime,StopTime,StepTime);
GEOPosition(1,:) = stkFindData(ReportData{1}, 'x');
GEOPosition(2,:) = stkFindData(ReportData{1}, 'y');
GEOPosition(3,:) = stkFindData(ReportData{1}, 'z');%位置向量为列向量
GEOVelocity(1,:) = stkFindData(ReportData{1}, 'vx');
GEOVelocity(2,:) = stkFindData(ReportData{1}, 'vy');
GEOVelocity(3,:) = stkFindData(ReportData{1}, 'vz');%速度向量为列向量

h = waitbar(0,'Processing');
for i = 1:size(Map,1)
    for j = 1:size(Map,2)
        %判断可见性
        waitbar(i/size(Map,1),h);
        if Map(i,j) == 0
            Phase_topography_max(i,j) = nan;
            Phase_topography_mean(i,j) = nan;
            continue;
        end
        Position = lla2ecef([LatRange(i),LonRange(j),0]);
        OT = repmat(Position,86400,1);
        OS1 = GEOPosition';
        S1T = OT-OS1;
        S1T_norm = S1T./vecnorm(S1T);
        Vr = dot(GEOVelocity',S1T_norm,2);
        Phase_topo = -2*pi/0.24.*Vr*20e-3;%波长0.24，时间延迟20ms
        Phase_topography_max(i,j) = max(Phase_topo);
        Phase_topography_mean(i,j) = mean(Phase_topo);

        
    end
end
delete(h);
h = imagesc(LonRange,LatRange,Phase_topography_mean);
set(h,'alphadata',~isnan(Phase_topography_mean));
% colormap(jet);
colorbar();

%% 画GEO SAR星下点轨迹
[secData] = stkReport(strcat('*/Satellite/',SatName{1}),'LLA Position',StartTime,StopTime,StepTime);
LatGEO = stkFindData(secData{1},'Lat');
LonGEO = stkFindData(secData{1},'Lon');
plot(rad2deg(LonGEO),rad2deg(LatGEO),'LineWidth',2,'Color','m');
