%% 误差图画图示例
load('GEOVrerror.mat')
figure
plot(log10(Sigma_VG),VG_ERR,'LineWidth',2);
hold on
plot(log10(Sigma_VG),VG_ERR1,'LineWidth',2);
%% 设置不等间距的网格线
set(gca,'XMinorGrid','on')
xticks([-3:0.4:-1,0:1:1])
%% 网格线粗细、样式在属性里面手动调整。
set(gca,'fontsize',16)

set(gca,'YMinorGrid','on')
yticks([0:0.1,0.5:6])
legend('X_1','X_r_e_f')
xlabel('log_1_0(σ_{V_{G}^r})')
ylabel('Error(m*s^-^1)')
