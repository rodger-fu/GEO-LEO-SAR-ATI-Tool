% % uiap = actxserver('STK11.application');
% % root = uiap.Personality2;
% % root.NewScenario('specialorbit');
% % sc = root.CurrentScenario;
% % sat = sc.Children.New(18,'mysat');
% % %���ɸ߶�500km��̫��ͬ�����
% % root.ExecuteCommand('OrbitWizard */Satellite/mysat SunSynchronous Altitude 400e3 Local Time of Ascending Node 0');
% % sat1 = sat.CopyObject('mysat1');

clc;clear;close all;
stkInit
remMachine = stkDefaultHost;%����STK��Ĭ�ϵ�ַ
conid=stkOpen(remMachine);%��������
% rtn=stkConnect(conid,'<Command>','<ObjectPath>','<Parameters>')
%ǰ������Ҫ�ֶ�������Satellite1��
%����̫��ͬ���ع���ʾ��
% rtn = stkConnect(conid, 'OrbitWizard', '*/Satellite/Satellite1','RepeatingSunSync ApproxRevsPerDay 8 RevsToRepeat 80');
%�����ع���ʾ��1
% rtn = stkConnect(conid, 'OrbitWizard', '*/Satellite/Satellite1','RepeatingGroundTrace ApproxRevsPerDay 12  Inclination 98 RevsToRepeat 12');
rtn = stkConnect(conid, 'OrbitWizard', '*/Satellite/Satellite1',...
    [' RepeatingGroundTrace '...
    ' ApproxRevsPerDay ' num2str(12)...
    ' Inclination ' num2str(30)...
    ' RevsToRepeat ' num2str(12)...
    ' LongitudeFirstAN ' num2str(0)]);

stkClose('all');%��ضϿ�����