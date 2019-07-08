function SerialCommunication(handles, str, num)
%�V���A���|�[�g
s = handles.serial;
%��������
switch str
  %�Z���T�Q�A�E�g�v�b�g�̑��M--------------------------------------------------
  % �f�[�^��
  % ['B'][�Z���T�ԍ�]([�o�͐�ԍ�][�n�C���[][�A������s����][�x������])�~�S�@�̂P�W�o�C�g���P�Z�b�g
  %--------------------------------------------------------------------------
  case 'B'
    %�P�Q�Z�b�g
    for i = 1:12
      %���ʃR�[�h�uB�v
      fprintf(s, '%c', 'B');
      %�Z���T�̃C���f�b�N�X
      c = char( i - 1 );
      fprintf(s, '%c', c);
      for j = 1:4
        %�A�E�g�v�b�g�̎��
        c = char( handles.s2oGUI{i,1}(j) );
        fprintf(s, '%c', c);
        %�n�C���[
        c = char( handles.s2oGUI{i,2}(j) );
        fprintf(s, '%c', c);
        %�A������s����
        c = char( handles.s2oGUI{i,3}(j) );
        fprintf(s, '%c', c);
        %�x������
        c = char( handles.s2oGUI{i,4}(j) );
        fprintf(s, '%c', c);
      end
      %arduino�̏�����҂�
      pause(200/1000);
    end
    %--------------------------------------------------------------------------
    %�~���Q�A�E�g�v�b�g�̑��M----------------------------------------------------
    % �f�[�^��
    % ['G'][�Z���T�ԍ�]([�o�͐�ԍ�][�n�C���[])�~�S[�쓮����]�@�̂P�P�o�C�g���P�Z�b�g
    %--------------------------------------------------------------------------
  case 'G'
    %�Q�Z�b�g
    for i = 1:2
      %���ʃR�[�h�uG�v
      fprintf(s, '%c', 'G');
      %�Z���T�̃C���f�b�N�X
      c = char( i - 1 );
      fprintf(s, '%c', c);
      for j = 1:4
        %�A�E�g�v�b�g�̎��
        c = char( handles.millGUI{i,1}(j) );
        fprintf(s, '%c', c);
        %�n�C���[
        c = char( handles.millGUI{i,2}(j) );
        fprintf(s, '%c', c);
      end
      %�~���̓��쎞��
      c = handles.millGUI{i,3} ;
      fprintf(s, '%c', c);
      %arduino�̏�����҂�
      pause(200/1000);
    end
    %--------------------------------------------------------------------------
    %�Z�b�V�����̐ݒ�̑��M-------------------------------------------------------
    %�f�[�^�͎��̌`��
    %���ʃR�[�h�uC�v
    %������ԁ@�@�@�@�W�o�C�g
    %�X�^�[�g�Z���T�@�S�o�C�g
    %�S�[���Z���T�@�@�S�o�C�g
    %�Z�b�V�������@�@�P�o�C�g
    %--------------------------------------------------------------------------
  case 'C'
    %���ʃR�[�h
    fprintf(s, '%c', 'C');
    %�Z�b�V�����̐ݒ�
    cl = handles.sessionGUI;
    %������ԁ@�W�̃Q�[�g�ɂ��āA�Q�[�g�J�Ȃ�P�A�Q�[�g�Ȃ�O
    for i = 1:8
      fprintf(s, '%c', cl{1}(i) );
    end
    %�X�^�[�g�Z���T�@�ǂ̃Z���T���g�����B�O���g�p�A�P�`�W�Z���T�A�X�`�P�O�~���̃Z���T
    for i = 1:4
      fprintf(s, '%c', cl{2}(i) );
    end
    %�S�[���Z���T�@��ɓ���
    for i = 1:4
      fprintf(s, '%c', cl{3}(i) );
    end
    %�Z�b�V�����񐔁@�O�`�P�Q�V�̐����B�P�o�C�g
    fprintf(s ,'%c', cl{4});
    %--------------------------------------------------------------------------
    %����E�����Z���T��𑗐M����------------------------------------------------
    %--------------------------------------------------------------------------
    % [���ʃR�[�h�uH�v]                               �P
    % [�Z�b�V�����̃C���f�b�N�X]
    % [�����Z���T�P][�����Z���T�Q]�c[127(��؂�R�[�h)] �ő�P�U�{�P
    % [���[�U�o�͂P][���[�U�o�͂Q]�c[127(��؂�R�[�h)] �ő�W�@�{�P
    %--------------------------------------------------------------------------
  case 'H'
    %���ʃR�[�h
    fprintf(s, '%c', 'H');
    %�Z�b�V�����̃C���f�b�N�X
    fwrite(s, num-1);
    %�����Z���T��̃T�C�Y
    a = size( handles.userdata{num+1,2} );
    a = a(2);
    %�����Z���T����Z���T�̃s���A�T�C���ɕϊ����ĒʐM
    if a>0
      for i=1:a
        str = char( handles.userdata{num+1,2}(i) );
        t = MakeSensorNum( str );
        fprintf(s, '%c', t);
      end
    end
    %��؂�R�[�h
    fprintf(s, '%c', 127);
    %����̃T�C�Y
    a = size( handles.userdata );
    a = a(2) - 2;
    %����̏o�͐��ʐM����B�s���A�T�C���ŋL�q����Ă���̂ŕϊ��s�v
    %�s�K�ȃf�[�^���͂����i���L�q�j
    if a>0
      for i=1:a
        fprintf(s, '%c', handles.userdata{num+1,i+2} );
      end
    end
    %��؂�R�[�h
    fprintf(s, '%c', 127);
    %--------------------------------------------------------------------------
    %�I���^�l�C�V�������[�h------------------------------------------------------
    %[�Z���T�̗�]�c[127]
    %[�Z���T�̗�]�c[127]
  case 'J'
    fwrite(s, 'J');
    %�ЂƂ߂̐����Z���T��̃T�C�Y
    a = size( handles.userdata(1,:) );
    a = a(2);
    if a>0
      for i=1:a
        str = char( handles.userdata{1,i} );
        t = MakeSensorNum( str );
        fprintf(s, '%c', t);
      end
    end
    %��؂�R�[�h
    fprintf(s, '%c', 127);
    %�ӂ��߂̐����Z���T��̃T�C�Y
    a = size( handles.userdata(2,:) );
    a = a(2);
    if a>0
      for i=1:a
        str = char( handles.userdata{2,i} );
        t = MakeSensorNum( str );
        fprintf(s, '%c', t);
      end
    end
    %��؂�R�[�h
    fprintf(s, '%c', 127);
    %--------------------------------------------------------------------------
    %�Z�b�V�����J�n�̐\��-------------------------------------------------------
  case 'D'
    fprintf(s, '%c', 'D');
    %--------------------------------------------------------------------------
end


%--------------------------------------------------------------------------
% �����Z���T���s���A�T�C���l�ɕϊ�
%--------------------------------------------------------------------------
function t = MakeSensorNum(str)
switch str
  case 'sensor1'
    t=38;
  case 'sensor2'
    t=39;
  case 'sensor3'
    t=40;
  case 'sensor4'
    t=41;
  case 'sensor5'
    t=42;
  case 'sensor6'
    t=43;
  case 'sensor7'
    t=44;
  case 'sensor8'
    t=45;
  case 'millsensor1'
    t=46;
  case 'millsensor2'
    t=47;
  otherwise
    t=0;
end
%--------------------------------------------------------------------------