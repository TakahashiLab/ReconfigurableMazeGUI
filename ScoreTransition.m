function trials = ScoreTransition(trials)

%Ｎ値平均
%trials = Mean(trials, 5);
%trials = Mean(trials, 10);

%Ｎ値平均の平均と分散
%trials = MeanNMean(trials, 39, 5);
%trials = MeanNMean(trials, 19, 10);

%Ｎ値平均の平均と分散のグループ別解析
%trials = MeanNMeanGroup(trials, 19, 10, [1 3:5], 'betaB以外１０値');
%trials = MeanNMeanGroup(trials, 19, 10, [3 4], '成績安定組');
%trials = MeanNMeanGroup(trials, 19, 10, [1 2 5], '成績上昇組');
%trials = MeanNMeanGroup(trials, 19, 10, 1:5, '全部');

%Ｎ値平均の推移の表示(サンプル数n、平均したＮ、表示するグループ）
%PlotNMeans(trials, 19, 10, 1:5);

%平均の平均の表示グループ対応
%PlotMeanNMean(trials);
PlotMeanNMean2(trials, 3);

return


%平均の平均、エラーバー付き、グループ分け対応
function PlotMeanNMean2(trials, Gid)

figure

%成績の描画
errorbar(10:10:190, trials.group(Gid).mean, trials.group(Gid).SEM);

%title
title(trials.group(Gid).name);

%label
xlabel('Number of trials');
ylabel('Score (%)');
return


% %平均の平均、エラーバー付き
% function PlotMeanNMean(trials)
% 
% %成績の描画
% errorbar(10:10:190, trials.mean10mean, trials.mean10SEM);
%     
% %label
% xlabel('Number of trials');
% ylabel('Score (%)');
% return


%Ｎ値平均の推移の表示 n:サンプル数 N:N値平均
function PlotNMeans(trials, n, N, Group) %#ok<INUSL>

%x軸用の値
x=N:N:n*N; %#ok<NASGU>

%グラフの描画
figure
hold on
for i=Group%1:max(size(trials.rat))
    str = ['plot(x, trials.rat(i).mean' num2str(N) '(1:n) *100);'];
    eval(str);
    %plot(x, trials.rat(i).mean5(1:n) * 100);    
end

%label
xlabel('Number of trials');
ylabel('Score (%)');

%legend
str='legend(';    
for i=Group%1:max(size(trials.rat))
    str = [str 'trials.rat(' num2str(i) ').name, ']; %#ok<AGROW>
end
str = [str '''Location'', ''southeast'')'];
eval(str);

return


% %５値平均の推移の表示
% function PlotMeans(trials,Xmax)
% 
% %x軸用の値
% x=5:5:Xmax*5;
% 
% %グラフの描画
% figure
% hold on
% for i=1:max(size(trials.rat))
%     plot(x, trials.rat(i).mean5(1:Xmax) * 100);
% end
% 
% %label
% xlabel('Number of trials');
% ylabel('Score (%)');
% 
% %legend
% % legend(trials.rat(1).name, ...
% %         trials.rat(2).name, ...
% %         trials.rat(3).name, ...
% %         trials.rat(4).name, ...
% %         trials.rat(5).name, ...
% %         'Location', 'southeast');
% 
% %legend数変更に対応
% str='legend(';    
% for i=1:max(size(trials.rat))
%     str = [str 'trials.rat(' num2str(i) ').name, ']; %#ok<AGROW>
% end
% str = [str '''Location'', ''southeast'')'];
% eval(str);
% 
% return


%N値平均の配列を.meanNの名前で構造体に追加
function [trials] = Mean(trials, n)

%個体数でループ
for i=1:max(size(trials.rat))
    
    %ループサイズ
    loop = floor(max(size(trials.rat(i).score)) / n);
    
    %出力値の宣言
    means = zeros(1,loop);
    
    %各個体の標本終わりまでループ
    for j=1:loop
        
        %標本n個ずつの平均
        means(j) = mean(trials.rat(i).score(1,(n*j-(n-1)):(n*j)));
        
        %出力値の代入
        str = ['trials.rat(i).mean' num2str(n) '=means;'];
        eval(str);
    end    
end
return


% %平均の平均（不使用？） n=最小のサンプル数、手動入力
% function [trials] = MeanMean(trials, n)
% 
% %計算用の行列の宣言
% M=[];
% 
% %個体数でループ
% for i=1:max(size(trials.rat))
%     
%     %平均値の横ベクトルを縦に連結
%     M = vertcat(M, trials.rat(i).mean5(1:n)); %#ok<AGROW>
% end
% 
% %平均
% trials.meanmean=mean(M);
% %標準誤差
% trials.meanSEM=var(M)/sqrt(5);
% 
% return


%Ｎ値平均の平均と分散のグループ別解析　n=最小のサンプル数、手動入力 N=N値平均
function [trials] = MeanNMeanGroup(trials, n, N, group, name) %#ok<INUSL>

%計算用の行列の宣言
M=[]; 

%解析グループ新規追加用インデックスGid
if ~isfield(trials, 'group')
    Gid=1;
else
    Gid = max(size(trials.group))+1;
end

%group内でループ
for i=group
    
    %平均値の横ベクトルを縦に連結
    str = ['M = vertcat(M, trials.rat(i).mean' num2str(N) '(1:n));'];
    eval(str);
    %M = vertcat(M, trials.rat(i).mean10(1:n)); %#ok<AGROW>
end

%グループ名
trials.group(Gid).name = name;
%平均
trials.group(Gid).mean = mean(M);
%標準誤差
trials.group(Gid).SEM = var(M)/sqrt(N);
return


%Ｎ値平均の平均と分散　n=最小のサンプル数、手動入力 N=N値平均
function [trials] = MeanNMean(trials, n, N) %#ok<INUSL>

%計算用の行列の宣言
M=[]; %#ok<NASGU>

%個体数でループ
for i=1:max(size(trials.rat))
    
    %平均値の横ベクトルを縦に連結
    str = ['M = vertcat(M, trials.rat(i).mean' num2str(N) '(1:n));'];
    eval(str);
    %M = vertcat(M, trials.rat(i).mean10(1:n)); %#ok<AGROW>
end

%平均
str = ['trials.mean' num2str(N) 'mean=mean(M);'];
eval(str);
%trials.meanmean=mean(M);
%標準誤差
str = ['trials.mean' num2str(N) 'SEM=var(M)/sqrt(N);'];
eval(str);
%trials.meanSEM=var(M)/sqrt(N);

return
