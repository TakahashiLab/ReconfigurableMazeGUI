function trials = ScoreTransitionPerDay(trials)

%Ｎ値平均（日毎）
%trials = Mean(trials, 5); %５値ずつ

%日全部の平均をmeaneachdayに配列でまとめる
%trials = MeanAll(trials);
%日全部の平均をプロット。(trials, plot日数n)
MeanAll2(trials, 4);

%Ｎ値平均のｄ日目をプロット(trials, N値平均, day, group)
%PlotNMeans(trials, 5, 2, 1:5);

%Ｎ値平均の平均と分散(trials, 最小サンプル数n, N値平均, 日d, 解析グループ, 名前)
%trials = MeanNMeanGroup(trials, 5, 5, 1, 1:5, '全個体');

%Ｎ値平均の平均と分散(trials, 描画サンプル数n, N値平均, 日d, 解析グループ, 名前)
% trials = MeanNMeanGroup2(trials, 5, 5, 1, 1:5, '全個体day1');
% trials = MeanNMeanGroup2(trials, 5, 5, 2, 1:5, '全個体day2');
% trials = MeanNMeanGroup2(trials, 5, 5, 3, 1:5, '全個体day3');
% trials = MeanNMeanGroup2(trials, 5, 5, 4, 1:5, '全個体day4');

%Ｎ値平均の平均のプロット (trials, Gid)　※手動
%PlotMeanNMeans2(trials, 1);

%日ごとの平均の推移
%PlotMeanEachDay(trials);

return


% function PlotMeanEachDay(trials)
% 
% M=[];
% 
% for i=1:max(size(trials.rat))
%     trials.rat(i).meaneachday;
%     M = vertcat(M, trials.rat(i).meaneachday);
% end
% 
% %平均
% means = mean(M);
% %標準誤差
% SEM = std(M)/sqrt(5);
% 
% errorbar(1:4, means(1:4), SEM(1:4));
% 
% title('日ごとの成績推移（SEM)');
% 
% xlabel('Day');
% ylabel('Score (%)');
% 
% xlim([0 5]);
% 
% return


% %Ｎ値平均の平均のプロット ※手動
% function PlotMeanNMeans2(trials, Gid)
% 
% figure
% 
% %成績の描画
% errorbar(5:5:25, trials.group2(Gid).mean, trials.group2(Gid).SEM);
% 
% %title
% title(trials.group2(Gid).name);
% 
% %label
% xlabel('Number of trials');
% ylabel('Score (%)');
% 
% %x描画範囲
% xlim([0 30]);
% return


%Ｎ値平均の平均と分散のグループ別解析　「描画」サンプル数n, N値平均, 日d, 解析グループ, 名前
%サンプル数のズレを無視して平均を取る。またプロットも行う
function [trials] = MeanNMeanGroup2(trials, n, N, d, group, name) 

%計算用行列Mの宣言
%meannanを使うため、適切なサイズのNaN行列を作っておく
num=0;
for i=group
    num = max(num, max(size(trials.rat(i).mean{N, d})));
end
M=nan(max(size(group)), num);

%グループでループ
for i=group
    %データをMに格納
    M(i, 1:max(size(trials.rat(i).mean{N,d}))) = trials.rat(i).mean{N, d};
end

%平均
MN = nanmean(M);
MM = nanmedian(M)
%標準偏差
SD = nanstd(M);
%nonNaNの数
nonNaN = sum(~isnan(M));
%標準誤差
SEM = SD ./ sqrt(nonNaN);

% M
% M(1:15)
% MN

%成績の描画
figure
errorbar(N:N:N*n, MM(1,1:n)*100, SD(1,1:n)*100);

%title
title(name);

%label
xlabel('Number of trials');
ylabel('Score (%)');

%x描画範囲
xlim([0 N*(n+1)]);

%プロットするための点を取得
px=[];
py=[];
%サンプル数でループ
for i=1:n
    %グループ数でループ
    gmax = max(size(group));
    for g=1:gmax
        px((i-1)*gmax + g) = N*i + (-0.5) + (1/gmax * (g-1)); %#ok<AGROW>
        py((i-1)*gmax + g) = M(g, i)*100; %#ok<AGROW>
    end
end

%個別の点をプロット
hold on
scatter(px, py)
hold off
return


% %Ｎ値平均の平均と分散のグループ別解析　最小サンプル数n, N値平均, 日d, 解析グループ, 名前
% function [trials] = MeanNMeanGroup(trials, n, N, d, group, name) 
% 
% %計算用の行列の宣言
% M=[]; 
% 
% %解析グループ新規追加用インデックスGid
% if ~isfield(trials, 'group2')
%     Gid=1;
% else
%     Gid = max(size(trials.group2))+1;
% end
% 
% %group内でループ
% for i=group
%     
%     %平均値の横ベクトルを縦に連結
%     M = vertcat(M, trials.rat(i).mean{N, d}(1:n)); %#ok<AGROW>
% end
% 
% %グループ名
% trials.group2(Gid).name = name;
% %平均
% trials.group2(Gid).mean = mean(M);
% %標準偏差
% trials.group2(Gid).SD = std(M);%var(M)/sqrt(N);
% %標準誤差
% trials.group2(Gid).SEM = std(M)/sqrt(N);
% return


%Ｎ値平均の推移の表示 n:サンプル数 N:N値平均
function PlotNMeans(trials, N, d, Group) 

%グラフの描画
figure
hold on
for i=Group
    
    %x軸
    x=N:N:N*max(size(trials.rat(i).mean{N,d}));
    %描画
    plot(x, trials.rat(i).mean{N,d}); 
end

%label
xlabel('Number of trials');
ylabel('Score (%)');

%legend ※groupの数の変更に対応するためeval
str='legend(';    
for i=Group%1:max(size(trials.rat))
    str = [str 'trials.rat(' num2str(i) ').name, ']; %#ok<AGROW>
end
str = [str '''Location'', ''southeast'')'];
eval(str);

return


% %日ごとの全部の平均
% function [trials] = MeanAll(trials)
% 
% %個体数iでループ
% for i=1:max(size(trials.rat))
%     
%     %日数dでループ
%     for d=1:max(size(trials.rat(i).alter))
%         
%         %個体iの日数dのスコア
%         scores = trials.rat(i).alter{d};
%         
%         if ~scores
%             %スコアが空なら処理なし
%         else
%             
%             %平均
%             meaneachday(d) = mean(scores); %#ok<AGROW>
%         end
%     end
%     
%     trials.rat(i).meaneachday = meaneachday;
% end
% return


%日ごとの全部の平均, および描画
function [trials] = MeanAll2(trials, n)

%個体数iでループ
for i=1:max(size(trials.rat))
    
    %日数dでループ
    for d=1:max(size(trials.rat(i).alter))
        
        %個体iの日数dのスコア
        scores = trials.rat(i).alter{d};
        
        if ~scores
            %スコアが空なら処理なし
        else
            
            %平均
            meaneachday(d) = mean(scores); %#ok<AGROW>
        end
    end
    
    trials.rat(i).meaneachday = meaneachday;
end

%計算用行列Mの宣言
M=[];

%Mにデータを格納
for i=1:max(size(trials.rat))
    trials.rat(i).meaneachday;
    M = vertcat(M, trials.rat(i).meaneachday); %#ok<AGROW>
end

%平均
means = nanmean(M);
MD = nanmedian(M);
%標準偏差
SD = nanstd(M);
%nonNaNの数
nonNaN = sum(~isnan(M));
%標準誤差
SEM = SD ./ sqrt(nonNaN);

%描画
errorbar(1:n, MD(1:n), SD(1:n));

%figure設定
title('日ごとの成績推移');
xlabel('Day');
ylabel('Score (%)');
xlim([0 n+1]);

%プロットするための点を取得
px=[];
py=[];
%サンプル数でループ
for i=1:n
    %グループ数でループ
    gmax = max(size(trials.rat));
    for g=1:gmax
        px((i-1)*gmax + g) = i + (-0.05) + (0.1/gmax * (g-1)); %#ok<AGROW>
        py((i-1)*gmax + g) = M(g, i); %#ok<AGROW>
    end
end

%個別の点をプロット
hold on
scatter(px, py)
hold off
return


%ｄ日目のＮ値平均を trials.rat(1).mean{N, d}の形で保存
function [trials] = Mean(trials, N)

%個体数iでループ
for i=1:max(size(trials.rat))
    
    %日数dでループ
    for d=1:max(size(trials.rat(i).alter))
        
        %個体iの日数dのスコア
        scores = trials.rat(i).alter{d};
        
        %ループサイズ
        loop = floor(max(size(scores)) / N);
        
        if ~loop
            %ループサイズが０なら処理なし
        else
            
            %出力値の宣言
            means = zeros(1,loop);
            
            %各個体の標本終わりまでループ
            for j=1:loop
                
                %標本n個ずつの平均
                samples = trials.rat(i).alter{d};
                means(j) = mean(samples(1,(N*j-(N-1)):(N*j)));
                
                %出力値の代入
                trials.rat(i).mean{N, d} = means;
            end
        end
    end
end
return