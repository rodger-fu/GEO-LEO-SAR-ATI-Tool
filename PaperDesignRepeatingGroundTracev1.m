%% �������������LEO���ӽ�40~50�㣬
%б�ӽ�10�����ڣ�
%����˫����10��~20��
%�ع�������

clc;clear;close all;
stkInit
%% ������������
ThetaL_Thresh = [35,50];%���ӽǷ�Χ
SquintThetaL_Thresh = [0,10];%б�ӽǷ�Χ
GroundBiangle_Thresh = [0,40];%����˫����
StartTime = 0;%ȫ��
StopTime = 86400;
StepTime = 1;
SatName = {'GEOSAR', 'Satellite1'};
TargetName = {'ValuableTarget'};
%-----------------��������ٶ�------------------------------------
%��ȡGEOλ�ü��ٶ�
[ReportData] = stkReport(['*/Satellite/',SatName{1}],'Fixed Position Velocity',StartTime,StopTime,StepTime);
GEOPosition(1,:) = stkFindData(ReportData{1}, 'x');
GEOPosition(2,:) = stkFindData(ReportData{1}, 'y');
GEOPosition(3,:) = stkFindData(ReportData{1}, 'z');
GEOVelocity(1,:) = stkFindData(ReportData{1}, 'vx');
GEOVelocity(2,:) = stkFindData(ReportData{1}, 'vy');
GEOVelocity(3,:) = stkFindData(ReportData{1}, 'vz');
%��ȡĿ��λ��
[secData] = stkReport(['*/Target/',TargetName{1}],'LLA Position',StartTime,StopTime,StepTime);
TargetPosition_lla(1) = rad2deg(stkFindData(secData{1},'Lat'));
TargetPosition_lla(2) = rad2deg(stkFindData(secData{1},'Lon'));
TargetPosition_lla(3) = stkFindData(secData{1},'Alt');
TargetPosition = lla2ecef(TargetPosition_lla);

        OS1 = GEOPosition;%����ָ��GEO����
        OT = repmat(TargetPosition',1,size(GEOPosition,2));
        S1T = OT-OS1;
        ThetaG = rad2deg(acos(dot(S1T',-OS1',2)./(sqrt(dot(S1T',S1T',2)).*sqrt(dot(-OS1',-OS1',2)))));
        Judge4 = find(ThetaG>6 & ThetaG<7);


%-----------------------------------------------------------------------------------------
%% ������ͬ�����Ļع������ж�
remMachine = stkDefaultHost;%����STK��Ĭ�ϵ�ַ
conid=stkOpen(remMachine);%��������
%%%-----------------1���ڻع飬15Ȧ-------------------------
% OrbitWizard ������ƻع�������
Inclination = [90:2:180];%������
ApproximateRevsPerDay = 15;%ÿ��Ȧ��
RevsToRepeat = 15;%�ع������ڵ���Ȧ��
LongitudeofFirstAscendingNode = [200:2:360];%�״������㾭��
for i = 1:length(Inclination)
    inclination = Inclination(i);%���
    for j = 1:length(LongitudeofFirstAscendingNode)
        tic
        LongitudeFirstAN = LongitudeofFirstAscendingNode(j);%�����㾭��
        rtn = stkConnect(conid, 'OrbitWizard', '*/Satellite/Satellite1',...
            [' RepeatingGroundTrace '...
             ' ApproxRevsPerDay ' num2str(ApproximateRevsPerDay)...                       %ÿ��Ȧ��
             ' Inclination ' num2str(inclination)...                        %���
             ' RevsToRepeat ' num2str(RevsToRepeat)...                %��Ȧ��
             ' LongitudeFirstAN ' num2str(LongitudeFirstAN)]); %������
         %-------------��������----------------------------------------------

         %��ȡLEOλ�ü��ٶ�
        [ReportData] = stkReport(['*/Satellite/',SatName{2}],'Fixed Position Velocity',StartTime,StopTime,StepTime);
        LEOPosition(1,:) = stkFindData(ReportData{1}, 'x');
        LEOPosition(2,:) = stkFindData(ReportData{1}, 'y');
        LEOPosition(3,:) = stkFindData(ReportData{1}, 'z');
        LEOVelocity(1,:) = stkFindData(ReportData{1}, 'vx');
        LEOVelocity(2,:) = stkFindData(ReportData{1}, 'vy');
        LEOVelocity(3,:) = stkFindData(ReportData{1}, 'vz');

        %%---------------------����͹����ӽ�----------------------------
        OS2 = LEOPosition;%����ָ��LEO����
        S2T = OT-OS2;
        ThetaL = rad2deg(acos(dot(S2T',-OS2',2)./(sqrt(dot(S2T',S2T',2)).*sqrt(dot(-OS2',-OS2',2)))));
        %%---------------------����͹�б�ӽ�-----------------------------
        I = eye(3);
        nV = LEOVelocity'./sqrt(dot(LEOVelocity',LEOVelocity',2));%�ٶȷ�������
        parfor k = 1:size(nV,1)
            VT = I-nV(k,:).'*nV(k,:);%ͶӰ����
            S2T_zerodop(k,:) = (VT*S2T(:,k))';
        end
        SquintThetaLEO = rad2deg(acos(dot(S2T',S2T_zerodop,2)./(sqrt(dot(S2T',S2T',2)).*sqrt(dot(S2T_zerodop,S2T_zerodop,2)))));
        LOS = (S1T'+S2T')';%��Ч����ʸ��
        %% �������˫����
        nT = OT'./sqrt(dot(OT',OT',2));%Ŀ�괦������
        parfor k = 1:size(nT,1)
            PT = I-nT(k,:).'*nT(k,:);%ͶӰ����   
            S1Tn(k,:) = (PT*(S1T(:,k)))';
            S2Tn(k,:) = (PT*(S2T(:,k)))';
            LOSn(k,:) = (PT*(LOS(:,k)))';
        end
        GroundBiangle = rad2deg(acos(dot(S1Tn,S2Tn,2)./(sqrt(dot(S1Tn,S1Tn,2)).*sqrt(dot(S2Tn,S2Tn,2)))));
%         GroundBiangle(find(GroundBiangle>90)) =  180-GroundBiangle(find(GroundBiangle>90));
        
        %%--------------------�жϽǶ���������-----------------------
        Judge1 = find(ThetaL>ThetaL_Thresh(1) & ...
            ThetaL<ThetaL_Thresh(2));
        Judge2 = find(SquintThetaLEO>SquintThetaL_Thresh(1) & ...
            SquintThetaLEO<SquintThetaL_Thresh(2));
        Judge3 = find(GroundBiangle>GroundBiangle_Thresh(1) & ...
            GroundBiangle<GroundBiangle_Thresh(2));
        Judge = intersect(intersect(Judge1,Judge2),intersect(Judge3,Judge4),'stable'); 
        if length(Judge) ~=0
        %--------------�жϿɼ���-------------------------------------------
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
            disp('�У�')
        end
        
        
         disp(['Inclination=',num2str(inclination)]);
         disp(['LAN=',num2str(LongitudeFirstAN)]);
         toc
    end
end
stkClose('all');%��ضϿ�����


