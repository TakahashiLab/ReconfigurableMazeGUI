function trials = ScoreTransition(trials)

%�m�l����
%trials = Mean(trials, 5);
%trials = Mean(trials, 10);

%�m�l���ς̕��ςƕ��U
%trials = MeanNMean(trials, 39, 5);
%trials = MeanNMean(trials, 19, 10);

%�m�l���ς̕��ςƕ��U�̃O���[�v�ʉ��
%trials = MeanNMeanGroup(trials, 19, 10, [1 3:5], 'betaB�ȊO�P�O�l');
%trials = MeanNMeanGroup(trials, 19, 10, [3 4], '���ш���g');
%trials = MeanNMeanGroup(trials, 19, 10, [1 2 5], '���я㏸�g');
%trials = MeanNMeanGroup(trials, 19, 10, 1:5, '�S��');

%�m�l���ς̐��ڂ̕\��(�T���v����n�A���ς����m�A�\������O���[�v�j
%PlotNMeans(trials, 19, 10, 1:5);

%���ς̕��ς̕\���O���[�v�Ή�
%PlotMeanNMean(trials);
PlotMeanNMean2(trials, 3);

return


%���ς̕��ρA�G���[�o�[�t���A�O���[�v�����Ή�
function PlotMeanNMean2(trials, Gid)

figure

%���т̕`��
errorbar(10:10:190, trials.group(Gid).mean, trials.group(Gid).SEM);

%title
title(trials.group(Gid).name);

%label
xlabel('Number of trials');
ylabel('Score (%)');
return


% %���ς̕��ρA�G���[�o�[�t��
% function PlotMeanNMean(trials)
% 
% %���т̕`��
% errorbar(10:10:190, trials.mean10mean, trials.mean10SEM);
%     
% %label
% xlabel('Number of trials');
% ylabel('Score (%)');
% return


%�m�l���ς̐��ڂ̕\�� n:�T���v���� N:N�l����
function PlotNMeans(trials, n, N, Group) %#ok<INUSL>

%x���p�̒l
x=N:N:n*N; %#ok<NASGU>

%�O���t�̕`��
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


% %�T�l���ς̐��ڂ̕\��
% function PlotMeans(trials,Xmax)
% 
% %x���p�̒l
% x=5:5:Xmax*5;
% 
% %�O���t�̕`��
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
% %legend���ύX�ɑΉ�
% str='legend(';    
% for i=1:max(size(trials.rat))
%     str = [str 'trials.rat(' num2str(i) ').name, ']; %#ok<AGROW>
% end
% str = [str '''Location'', ''southeast'')'];
% eval(str);
% 
% return


%N�l���ς̔z���.meanN�̖��O�ō\���̂ɒǉ�
function [trials] = Mean(trials, n)

%�̐��Ń��[�v
for i=1:max(size(trials.rat))
    
    %���[�v�T�C�Y
    loop = floor(max(size(trials.rat(i).score)) / n);
    
    %�o�͒l�̐錾
    means = zeros(1,loop);
    
    %�e�̂̕W�{�I���܂Ń��[�v
    for j=1:loop
        
        %�W�{n���̕���
        means(j) = mean(trials.rat(i).score(1,(n*j-(n-1)):(n*j)));
        
        %�o�͒l�̑��
        str = ['trials.rat(i).mean' num2str(n) '=means;'];
        eval(str);
    end    
end
return


% %���ς̕��ρi�s�g�p�H�j n=�ŏ��̃T���v�����A�蓮����
% function [trials] = MeanMean(trials, n)
% 
% %�v�Z�p�̍s��̐錾
% M=[];
% 
% %�̐��Ń��[�v
% for i=1:max(size(trials.rat))
%     
%     %���ϒl�̉��x�N�g�����c�ɘA��
%     M = vertcat(M, trials.rat(i).mean5(1:n)); %#ok<AGROW>
% end
% 
% %����
% trials.meanmean=mean(M);
% %�W���덷
% trials.meanSEM=var(M)/sqrt(5);
% 
% return


%�m�l���ς̕��ςƕ��U�̃O���[�v�ʉ�́@n=�ŏ��̃T���v�����A�蓮���� N=N�l����
function [trials] = MeanNMeanGroup(trials, n, N, group, name) %#ok<INUSL>

%�v�Z�p�̍s��̐錾
M=[]; 

%��̓O���[�v�V�K�ǉ��p�C���f�b�N�XGid
if ~isfield(trials, 'group')
    Gid=1;
else
    Gid = max(size(trials.group))+1;
end

%group���Ń��[�v
for i=group
    
    %���ϒl�̉��x�N�g�����c�ɘA��
    str = ['M = vertcat(M, trials.rat(i).mean' num2str(N) '(1:n));'];
    eval(str);
    %M = vertcat(M, trials.rat(i).mean10(1:n)); %#ok<AGROW>
end

%�O���[�v��
trials.group(Gid).name = name;
%����
trials.group(Gid).mean = mean(M);
%�W���덷
trials.group(Gid).SEM = var(M)/sqrt(N);
return


%�m�l���ς̕��ςƕ��U�@n=�ŏ��̃T���v�����A�蓮���� N=N�l����
function [trials] = MeanNMean(trials, n, N) %#ok<INUSL>

%�v�Z�p�̍s��̐錾
M=[]; %#ok<NASGU>

%�̐��Ń��[�v
for i=1:max(size(trials.rat))
    
    %���ϒl�̉��x�N�g�����c�ɘA��
    str = ['M = vertcat(M, trials.rat(i).mean' num2str(N) '(1:n));'];
    eval(str);
    %M = vertcat(M, trials.rat(i).mean10(1:n)); %#ok<AGROW>
end

%����
str = ['trials.mean' num2str(N) 'mean=mean(M);'];
eval(str);
%trials.meanmean=mean(M);
%�W���덷
str = ['trials.mean' num2str(N) 'SEM=var(M)/sqrt(N);'];
eval(str);
%trials.meanSEM=var(M)/sqrt(N);

return
