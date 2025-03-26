%%%ȷ�����Ͳ�����Χ�������ܺ���
clc;clear all;close all;

load('Scene1_test.mat');
% Scene1 = Scene2;
nPop = length(Scene1.ThetaG);
CostFunction = @(x) MOP2(x);  % Cost Function

empty_individual.Position = [];%����λ��
empty_individual.Cost = [];%�����Ӧ��Ŀ�꺯��ֵ
empty_individual.Rank = [];%����ȼ�����֧������
empty_individual.DominationSet = [];%֧�伯
empty_individual.DominatedCount = [];%��֧����
empty_individual.NormalizedCost = [];%��һ��Ŀ�꺯��
empty_individual.AssociatedRef = [];%��ο���֮��Ĺ�ϵ������
empty_individual.DistanceToAssociatedRef = [];%��ο���֮�����

pop = repmat(empty_individual, nPop, 1);%�ظ����鸱��

for i = 1:nPop

    x1 = Scene1.ThetaG(i);

    x2 = Scene1.ThetaL(i);

    x3 = Scene1.SquintThetaLEO(i);

    x4 = Scene1.GroundBiangle(i);
    pop(i).Position = [x1,x2,x3,x4];%����ÿ������λ�ã�[-1 1]���ֵ
    [~,pop(i).Cost] = CostFunction(pop(i).Position);
end

%% ��ͼ
for i = 1:nPop
    Cost1(i) = pop(i).Cost(1);%�ֱ浥Ԫ���
    Cost2(i) = pop(i).Cost(2);%�ٶȷֱ���
    Cost3(i) = pop(i).Cost(3);%���ģ���ٶ�
    Cost4(i) = pop(i).Cost(4);%���پ���
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
legend('�ֱ浥Ԫ���','�ٶȷֱ���[cm/s/deg]','���ģ���ٶ�[m/s]','���پ���[cm/s]');
