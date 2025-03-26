% % uiap = actxserver('STK11.application');
% % root = uiap.Personality2;
% % root.NewScenario('specialorbit');
% % sc = root.CurrentScenario;
% % sat = sc.Children.New(18,'mysat');
% % %生成高度500km的太阳同步轨道
% % root.ExecuteCommand('OrbitWizard */Satellite/mysat SunSynchronous Altitude 400e3 Local Time of Ascending Node 0');
% % sat1 = sat.CopyObject('mysat1');

clc;clear;close all;
stkInit
remMachine = stkDefaultHost;%返回STK的默认地址
conid=stkOpen(remMachine);%建立连接
% rtn=stkConnect(conid,'<Command>','<ObjectPath>','<Parameters>')
%前提是先要手动创建个Satellite1星
%创建太阳同步回归轨道示例
% rtn = stkConnect(conid, 'OrbitWizard', '*/Satellite/Satellite1','RepeatingSunSync ApproxRevsPerDay 8 RevsToRepeat 80');
%创建回归轨道示例1
% rtn = stkConnect(conid, 'OrbitWizard', '*/Satellite/Satellite1','RepeatingGroundTrace ApproxRevsPerDay 12  Inclination 98 RevsToRepeat 12');
rtn = stkConnect(conid, 'OrbitWizard', '*/Satellite/Satellite1',...
    [' RepeatingGroundTrace '...
    ' ApproxRevsPerDay ' num2str(12)...
    ' Inclination ' num2str(30)...
    ' RevsToRepeat ' num2str(12)...
    ' LongitudeFirstAN ' num2str(0)]);

stkClose('all');%务必断开连接