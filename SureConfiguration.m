%%%确定构型参数范围，画性能函数
clc;clear all;close all;

load('Scene1_test.mat');
% Scene1 = Scene2;
nPop = length(Scene1.ThetaG);
CostFunction = @(x) MOP2(x);  % Cost Function

empty_individual.Position = [];%个体位置
empty_individual.Cost = [];%个体对应的目标函数值
empty_individual.Rank = [];%个体等级（非支配排序）
empty_individual.DominationSet = [];%支配集
empty_individual.DominatedCount = [];%被支配数
empty_individual.NormalizedCost = [];%归一化目标函数
empty_individual.AssociatedRef = [];%与参考点之间的关系？？？
empty_individual.DistanceToAssociatedRef = [];%与参考点之间距离

pop = repmat(empty_individual, nPop, 1);%重复数组副本

for i = 1:nPop

    x1 = Scene1.ThetaG(i);

    x2 = Scene1.ThetaL(i);

    x3 = Scene1.SquintThetaLEO(i);

    x4 = Scene1.GroundBiangle(i);
    pop(i).Position = [x1,x2,x3,x4];%创建每个个体位置：[-1 1]五个值
    [~,pop(i).Cost] = CostFunction(pop(i).Position);
end

%% 画图
for i = 1:nPop
    Cost1(i) = pop(i).Cost(1);%分辨单元面积
    Cost2(i) = pop(i).Cost(2);%速度分辨率
    Cost3(i) = pop(i).Cost(3);%最大不模糊速度
    Cost4(i) = pop(i).Cost(4);%测速精度
end


figure;
yyaxis left
plot([1:1:nPop],Cost1,'LineWidth',2);
hold on;
yyaxis right
plot([1:1:nPop],Cost2.*100,'LineWidth',2);%cm/s/deg
hold on;
plot([1:1:nPop],abs(Cost3),'LineWidth',2);
hold on;
plot([1:1:nPop],Cost4.*100,'LineWidth',2);%cm/s
hold on;
legend('分辨单元面积','速度分辨率[cm/s/deg]','最大不模糊速度[m/s]','测速精度[cm/s]');
