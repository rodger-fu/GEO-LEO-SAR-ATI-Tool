%% 论文中设计满足LEO下视角40~50°，
%斜视角10°以内，
%地面双基角10°~20°
%回归轨道卫星

clc;clear;close all;
stkInit
%% 基本参数设置
ThetaL_Thresh = [35,50];%下视角范围
SquintThetaL_Thresh = [0,10];%斜视角范围
GroundBiangle_Thresh = [0,40];%地面双基角
StartTime = 0;%全天
StopTime = 86400;
StepTime = 1;
SatName = {'GEOSAR', 'Satellite1'};
TargetName = {'ValuableTarget'};
%-----------------提高运行速度------------------------------------
%获取GEO位置及速度
[ReportData] = stkReport(['*/Satellite/',SatName{1}],'Fixed Position Velocity',StartTime,StopTime,StepTime);
GEOPosition(1,:) = stkFindData(ReportData{1}, 'x');
GEOPosition(2,:) = stkFindData(ReportData{1}, 'y');
GEOPosition(3,:) = stkFindData(ReportData{1}, 'z');
GEOVelocity(1,:) = stkFindData(ReportData{1}, 'vx');
GEOVelocity(2,:) = stkFindData(ReportData{1}, 'vy');
GEOVelocity(3,:) = stkFindData(ReportData{1}, 'vz');
%获取目标位置
[secData] = stkReport(['*/Target/',TargetName{1}],'LLA Position',StartTime,StopTime,StepTime);
TargetPosition_lla(1) = rad2deg(stkFindData(secData{1},'Lat'));
TargetPosition_lla(2) = rad2deg(stkFindData(secData{1},'Lon'));
TargetPosition_lla(3) = stkFindData(secData{1},'Alt');
TargetPosition = lla2ecef(TargetPosition_lla);

        OS1 = GEOPosition;%地心指向GEO卫星
        OT = repmat(TargetPosition',1,size(GEOPosition,2));
        S1T = OT-OS1;
        ThetaG = rad2deg(acos(dot(S1T',-OS1',2)./(sqrt(dot(S1T',S1T',2)).*sqrt(dot(-OS1',-OS1',2)))));
        Judge4 = find(ThetaG>6 & ThetaG<7);


%-----------------------------------------------------------------------------------------
%% 创建不同参数的回归轨道并判断
remMachine = stkDefaultHost;%返回STK的默认地址
conid=stkOpen(remMachine);%建立连接
%%%-----------------1天内回归，15圈-------------------------
% OrbitWizard 辅助设计回归轨道参数
Inclination = [90:2:180];%轨道倾角
ApproximateRevsPerDay = 15;%每天圈数
RevsToRepeat = 15;%回归周期内的总圈数
LongitudeofFirstAscendingNode = [200:2:360];%首次升交点经度
for i = 1:length(Inclination)
    inclination = Inclination(i);%倾角
    for j = 1:length(LongitudeofFirstAscendingNode)
        tic
        LongitudeFirstAN = LongitudeofFirstAscendingNode(j);%升交点经度
        rtn = stkConnect(conid, 'OrbitWizard', '*/Satellite/Satellite1',...
            [' RepeatingGroundTrace '...
             ' ApproxRevsPerDay ' num2str(ApproximateRevsPerDay)...                       %每天圈数
             ' Inclination ' num2str(inclination)...                        %倾角
             ' RevsToRepeat ' num2str(RevsToRepeat)...                %总圈数
             ' LongitudeFirstAN ' num2str(LongitudeFirstAN)]); %升交点
         %-------------分析过程----------------------------------------------

         %获取LEO位置及速度
        [ReportData] = stkReport(['*/Satellite/',SatName{2}],'Fixed Position Velocity',StartTime,StopTime,StepTime);
        LEOPosition(1,:) = stkFindData(ReportData{1}, 'x');
        LEOPosition(2,:) = stkFindData(ReportData{1}, 'y');
        LEOPosition(3,:) = stkFindData(ReportData{1}, 'z');
        LEOVelocity(1,:) = stkFindData(ReportData{1}, 'vx');
        LEOVelocity(2,:) = stkFindData(ReportData{1}, 'vy');
        LEOVelocity(3,:) = stkFindData(ReportData{1}, 'vz');

        %%---------------------计算低轨下视角----------------------------
        OS2 = LEOPosition;%地心指向LEO卫星
        S2T = OT-OS2;
        ThetaL = rad2deg(acos(dot(S2T',-OS2',2)./(sqrt(dot(S2T',S2T',2)).*sqrt(dot(-OS2',-OS2',2)))));
        %%---------------------计算低轨斜视角-----------------------------
        I = eye(3);
        nV = LEOVelocity'./sqrt(dot(LEOVelocity',LEOVelocity',2));%速度方向向量
        parfor k = 1:size(nV,1)
            VT = I-nV(k,:).'*nV(k,:);%投影矩阵
            S2T_zerodop(k,:) = (VT*S2T(:,k))';
        end
        SquintThetaLEO = rad2deg(acos(dot(S2T',S2T_zerodop,2)./(sqrt(dot(S2T',S2T',2)).*sqrt(dot(S2T_zerodop,S2T_zerodop,2)))));
        LOS = (S1T'+S2T')';%等效径向矢量
        %% 计算地面双基角
        nT = OT'./sqrt(dot(OT',OT',2));%目标处法向量
        parfor k = 1:size(nT,1)
            PT = I-nT(k,:).'*nT(k,:);%投影矩阵   
            S1Tn(k,:) = (PT*(S1T(:,k)))';
            S2Tn(k,:) = (PT*(S2T(:,k)))';
            LOSn(k,:) = (PT*(LOS(:,k)))';
        end
        GroundBiangle = rad2deg(acos(dot(S1Tn,S2Tn,2)./(sqrt(dot(S1Tn,S1Tn,2)).*sqrt(dot(S2Tn,S2Tn,2)))));
%         GroundBiangle(find(GroundBiangle>90)) =  180-GroundBiangle(find(GroundBiangle>90));
        
        %%--------------------判断角度区间数量-----------------------
        Judge1 = find(ThetaL>ThetaL_Thresh(1) & ...
            ThetaL<ThetaL_Thresh(2));
        Judge2 = find(SquintThetaLEO>SquintThetaL_Thresh(1) & ...
            SquintThetaLEO<SquintThetaL_Thresh(2));
        Judge3 = find(GroundBiangle>GroundBiangle_Thresh(1) & ...
            GroundBiangle<GroundBiangle_Thresh(2));
        Judge = intersect(intersect(Judge1,Judge2),intersect(Judge3,Judge4),'stable'); 
        if length(Judge) ~=0
        %--------------判断可见性-------------------------------------------
        [AccessData1] = stkAccReport(strcat('*/Satellite/',SatName{2}),...
            strcat('*/Target/ValuableTarget'), 'Access',Judge(1),Judge(end),1);
        if length(AccessData1{1})~=0
        AccessTime = [round(stkFindData(AccessData1{1},'Start Time'),0)...
            :1:round(stkFindData(AccessData1{1},'Stop Time'),0)]';
        else 
            AccessTime = [];
        end
        Judge = intersect(Judge,AccessTime);
        end
        Result(i,j) = length(Judge);
        
        if max(max(Result))~=0
            disp('有！')
        end
        
        
         disp(['Inclination=',num2str(inclination)]);
         disp(['LAN=',num2str(LongitudeFirstAN)]);
         toc
    end
end
stkClose('all');%务必断开连接


