function trials = ScoreTransitionPerDay(trials)

%�m�l���ρi�����j
%trials = Mean(trials, 5); %�T�l����

%���S���̕��ς�meaneachday�ɔz��ł܂Ƃ߂�
%trials = MeanAll(trials);
%���S���̕��ς��v���b�g�B(trials, plot����n)
MeanAll2(trials, 4);

%�m�l���ς̂����ڂ��v���b�g(trials, N�l����, day, group)
%PlotNMeans(trials, 5, 2, 1:5);

%�m�l���ς̕��ςƕ��U(trials, �ŏ��T���v����n, N�l����, ��d, ��̓O���[�v, ���O)
%trials = MeanNMeanGroup(trials, 5, 5, 1, 1:5, '�S��');

%�m�l���ς̕��ςƕ��U(trials, �`��T���v����n, N�l����, ��d, ��̓O���[�v, ���O)
% trials = MeanNMeanGroup2(trials, 5, 5, 1, 1:5, '�S��day1');
% trials = MeanNMeanGroup2(trials, 5, 5, 2, 1:5, '�S��day2');
% trials = MeanNMeanGroup2(trials, 5, 5, 3, 1:5, '�S��day3');
% trials = MeanNMeanGroup2(trials, 5, 5, 4, 1:5, '�S��day4');

%�m�l���ς̕��ς̃v���b�g (trials, Gid)�@���蓮
%PlotMeanNMeans2(trials, 1);

%�����Ƃ̕��ς̐���
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
% %����
% means = mean(M);
% %�W���덷
% SEM = std(M)/sqrt(5);
% 
% errorbar(1:4, means(1:4), SEM(1:4));
% 
% title('�����Ƃ̐��ѐ��ځiSEM)');
% 
% xlabel('Day');
% ylabel('Score (%)');
% 
% xlim([0 5]);
% 
% return


% %�m�l���ς̕��ς̃v���b�g ���蓮
% function PlotMeanNMeans2(trials, Gid)
% 
% figure
% 
% %���т̕`��
% errorbar(5:5:25, trials.group2(Gid).mean, trials.group2(Gid).SEM);
% 
% %title
% title(trials.group2(Gid).name);
% 
% %label
% xlabel('Number of trials');
% ylabel('Score (%)');
% 
% %x�`��͈�
% xlim([0 30]);
% return


%�m�l���ς̕��ςƕ��U�̃O���[�v�ʉ�́@�u�`��v�T���v����n, N�l����, ��d, ��̓O���[�v, ���O
%�T���v�����̃Y���𖳎����ĕ��ς����B�܂��v���b�g���s��
function [trials] = MeanNMeanGroup2(trials, n, N, d, group, name) 

%�v�Z�p�s��M�̐錾
%meannan���g�����߁A�K�؂ȃT�C�Y��NaN�s�������Ă���
num=0;
for i=group
    num = max(num, max(size(trials.rat(i).mean{N, d})));
end
M=nan(max(size(group)), num);

%�O���[�v�Ń��[�v
for i=group
    %�f�[�^��M�Ɋi�[
    M(i, 1:max(size(trials.rat(i).mean{N,d}))) = trials.rat(i).mean{N, d};
end

%����
MN = nanmean(M);
MM = nanmedian(M)
%�W���΍�
SD = nanstd(M);
%nonNaN�̐�
nonNaN = sum(~isnan(M));
%�W���덷
SEM = SD ./ sqrt(nonNaN);

% M
% M(1:15)
% MN

%���т̕`��
figure
errorbar(N:N:N*n, MM(1,1:n)*100, SD(1,1:n)*100);

%title
title(name);

%label
xlabel('Number of trials');
ylabel('Score (%)');

%x�`��͈�
xlim([0 N*(n+1)]);

%�v���b�g���邽�߂̓_���擾
px=[];
py=[];
%�T���v�����Ń��[�v
for i=1:n
    %�O���[�v���Ń��[�v
    gmax = max(size(group));
    for g=1:gmax
        px((i-1)*gmax + g) = N*i + (-0.5) + (1/gmax * (g-1)); %#ok<AGROW>
        py((i-1)*gmax + g) = M(g, i)*100; %#ok<AGROW>
    end
end

%�ʂ̓_���v���b�g
hold on
scatter(px, py)
hold off
return


% %�m�l���ς̕��ςƕ��U�̃O���[�v�ʉ�́@�ŏ��T���v����n, N�l����, ��d, ��̓O���[�v, ���O
% function [trials] = MeanNMeanGroup(trials, n, N, d, group, name) 
% 
% %�v�Z�p�̍s��̐錾
% M=[]; 
% 
% %��̓O���[�v�V�K�ǉ��p�C���f�b�N�XGid
% if ~isfield(trials, 'group2')
%     Gid=1;
% else
%     Gid = max(size(trials.group2))+1;
% end
% 
% %group���Ń��[�v
% for i=group
%     
%     %���ϒl�̉��x�N�g�����c�ɘA��
%     M = vertcat(M, trials.rat(i).mean{N, d}(1:n)); %#ok<AGROW>
% end
% 
% %�O���[�v��
% trials.group2(Gid).name = name;
% %����
% trials.group2(Gid).mean = mean(M);
% %�W���΍�
% trials.group2(Gid).SD = std(M);%var(M)/sqrt(N);
% %�W���덷
% trials.group2(Gid).SEM = std(M)/sqrt(N);
% return


%�m�l���ς̐��ڂ̕\�� n:�T���v���� N:N�l����
function PlotNMeans(trials, N, d, Group) 

%�O���t�̕`��
figure
hold on
for i=Group
    
    %x��
    x=N:N:N*max(size(trials.rat(i).mean{N,d}));
    %�`��
    plot(x, trials.rat(i).mean{N,d}); 
end

%label
xlabel('Number of trials');
ylabel('Score (%)');

%legend ��group�̐��̕ύX�ɑΉ����邽��eval
str='legend(';    
for i=Group%1:max(size(trials.rat))
    str = [str 'trials.rat(' num2str(i) ').name, ']; %#ok<AGROW>
end
str = [str '''Location'', ''southeast'')'];
eval(str);

return


% %�����Ƃ̑S���̕���
% function [trials] = MeanAll(trials)
% 
% %�̐�i�Ń��[�v
% for i=1:max(size(trials.rat))
%     
%     %����d�Ń��[�v
%     for d=1:max(size(trials.rat(i).alter))
%         
%         %��i�̓���d�̃X�R�A
%         scores = trials.rat(i).alter{d};
%         
%         if ~scores
%             %�X�R�A����Ȃ珈���Ȃ�
%         else
%             
%             %����
%             meaneachday(d) = mean(scores); %#ok<AGROW>
%         end
%     end
%     
%     trials.rat(i).meaneachday = meaneachday;
% end
% return


%�����Ƃ̑S���̕���, ����ѕ`��
function [trials] = MeanAll2(trials, n)

%�̐�i�Ń��[�v
for i=1:max(size(trials.rat))
    
    %����d�Ń��[�v
    for d=1:max(size(trials.rat(i).alter))
        
        %��i�̓���d�̃X�R�A
        scores = trials.rat(i).alter{d};
        
        if ~scores
            %�X�R�A����Ȃ珈���Ȃ�
        else
            
            %����
            meaneachday(d) = mean(scores); %#ok<AGROW>
        end
    end
    
    trials.rat(i).meaneachday = meaneachday;
end

%�v�Z�p�s��M�̐錾
M=[];

%M�Ƀf�[�^���i�[
for i=1:max(size(trials.rat))
    trials.rat(i).meaneachday;
    M = vertcat(M, trials.rat(i).meaneachday); %#ok<AGROW>
end

%����
means = nanmean(M);
MD = nanmedian(M);
%�W���΍�
SD = nanstd(M);
%nonNaN�̐�
nonNaN = sum(~isnan(M));
%�W���덷
SEM = SD ./ sqrt(nonNaN);

%�`��
errorbar(1:n, MD(1:n), SD(1:n));

%figure�ݒ�
title('�����Ƃ̐��ѐ���');
xlabel('Day');
ylabel('Score (%)');
xlim([0 n+1]);

%�v���b�g���邽�߂̓_���擾
px=[];
py=[];
%�T���v�����Ń��[�v
for i=1:n
    %�O���[�v���Ń��[�v
    gmax = max(size(trials.rat));
    for g=1:gmax
        px((i-1)*gmax + g) = i + (-0.05) + (0.1/gmax * (g-1)); %#ok<AGROW>
        py((i-1)*gmax + g) = M(g, i); %#ok<AGROW>
    end
end

%�ʂ̓_���v���b�g
hold on
scatter(px, py)
hold off
return


%�����ڂ̂m�l���ς� trials.rat(1).mean{N, d}�̌`�ŕۑ�
function [trials] = Mean(trials, N)

%�̐�i�Ń��[�v
for i=1:max(size(trials.rat))
    
    %����d�Ń��[�v
    for d=1:max(size(trials.rat(i).alter))
        
        %��i�̓���d�̃X�R�A
        scores = trials.rat(i).alter{d};
        
        %���[�v�T�C�Y
        loop = floor(max(size(scores)) / N);
        
        if ~loop
            %���[�v�T�C�Y���O�Ȃ珈���Ȃ�
        else
            
            %�o�͒l�̐錾
            means = zeros(1,loop);
            
            %�e�̂̕W�{�I���܂Ń��[�v
            for j=1:loop
                
                %�W�{n���̕���
                samples = trials.rat(i).alter{d};
                means(j) = mean(samples(1,(N*j-(N-1)):(N*j)));
                
                %�o�͒l�̑��
                trials.rat(i).mean{N, d} = means;
            end
        end
    end
end
return