function varargout = ReconfigurableMaze(varargin)
% RECONFIGURABLEMAZE MATLAB code for ReconfigurableMaze.fig
%      RECONFIGURABLEMAZE, by itself, creates a new RECONFIGURABLEMAZE or raises the existing
%      singleton*.
%
%      H = RECONFIGURABLEMAZE returns the handle to a new RECONFIGURABLEMAZE or the handle to
%      the existing singleton*.
%
%      RECONFIGURABLEMAZE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECONFIGURABLEMAZE.M with the given input arguments.
%
%      RECONFIGURABLEMAZE('Property','Value',...) creates a new RECONFIGURABLEMAZE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ReconfigurableMaze_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ReconfigurableMaze_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ReconfigurableMaze

% Last Modified by GUIDE v2.5 15-Apr-2019 15:29:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ReconfigurableMaze_OpeningFcn, ...
                   'gui_OutputFcn',  @ReconfigurableMaze_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


%�u�Z�b�g�A�b�v�v-----------------------------------------------------------
%GUI�̃Z�b�g�A�b�v�ŌĂ΂��֐��B�\���̂ɕϐ���ǉ�����Ȃ炱����
function ReconfigurableMaze_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ReconfigurableMaze (see VARARGIN)

% Choose default command line output for ReconfigurableMaze
handles.output = hObject;

%�V���A���|�[�g
%���̃p�\�R���ł͗L���ȃ|�[�g��UNO:COM6,MEGA:COM7
s = serial('COM10');
%�{�[���[�g
set(s, 'BaudRate', 9600);
%�R�[���o�b�N�֐��̂��߂̐ݒ�
handles.serial = s;
s.BytesAvailableFcnCount = 1;
s.BytesAvailableFcnMode = 'byte';
s.BytesAvailableFcn = '';
%handles�ɃV���A���|�[�g��n��
handles.serial = s;

%handles�\���̂ɕϐ���ǉ�--------------------------------------------------
%���H��ҏW����f�[�^�̈ꎞ�i�[
%�����ς������Z���T
handles.targetsnsr = 0;
%�o�͂�ς������A�E�g�v�b�g
handles.targetoutput = zeros(4,1);
%�o�͂��ǂ����邩�iHIGHorLOW)
handles.outputHorL = zeros(4,2);
%�A������̕s����
handles.mlt_disallow = zeros(4,1);
%delay time
handles.delay_time = zeros(4,1);
%�~���̓��쎞��
handles.milltime = 0;
%�O���t�@�C���̗��p��
handles.userfile = 0;
%--------------------------------------------------------------------------
%snsr2output�ɑΉ�����f�[�^��
%[�o�͐�s���~�S][�o�͓��e�~�S][�A������s���~�S][�x�����ԁ~�S]  �Z���T�P
%                  �c
%[�o�͐�s���~�S][�o�͓��e�~�S][�A������s���~�S][�x�����ԁ~�S]�@�Z���T�P�Q�i�Z���T�W�~���Q�|�[�N�Q�j
%cell{x, y}(z)�Ŋe�f�[�^�ɃA�N�Z�X����
cell = {zeros(1, 4), zeros(1, 4), zeros(1, 4), zeros(1, 4)};
c = cell;
for i = 1:11
    cell = vertcat(cell, c);
end
%GUI�ŕҏW���̃f�[�^
handles.s2oGUI = cell;
%Arduino�����ݎ����Ă�f�[�^
handles.s2oArd = cell;
%�~���̃f�[�^
%[�o�͐�s���~�S]�@�F�@[�o�͓��e�~�S]  �F�@[���쎞��]�@�~���P
%[�o�͐�s���~�S]�@�F�@[�o�͓��e�~�S]  �F�@[���쎞��]�@�~���Q
cell = {zeros(1, 4), zeros(1, 4), 0};
c = cell;
cell = vertcat(cell, c);
%�~���̓���
handles.millGUI = cell;
%--------------------------------------------------------------------------
%�Z�b�V�����ҏW��
%�������
%a = zeros(1,8);
a = ones(1,8);
%�X�^�[�g�Z���T
b = zeros(1,4);
%�S�[���Z���T
c = zeros(1,4);
%�Z�b�V������
d = 0;
%����̗�i���g�p�j
e = zeros(1,256);
%�܂Ƃ߂�cell�f�[�^�Ƃ���
cell = {a, b ,c, d, e};
%���[�U���ҏW�����f�[�^
handles.sessionGUI = cell;
%Arduino�̃f�[�^�@���g��Ȃ��悤�ɂ��悤
%handles.sessionArd = cell;
%--------------------------------------------------------------------------
%�V���A���ʐM���J��
% �����������USB�����Ȃ��Ǝ��s�ł��Ȃ����߁A�����I�Ƀ|�[�g���J��
%--------------------------------------------------------------------------
%�O��̃Z�b�V�����̏��������p���A�����GUI�ɕ\��������
%fnc_LoadMazeData(handles, 'load', hObject);
%--------------------------------------------------------------------------
%�Z�b�V�����J�n�̃t���O�B�I�����̏������ꕔ�؂�ւ�
handles.sessionstarted = false;
% �Z�[�u
guidata(hObject, handles);
%--------------------------------------------------------------------------

% UIWAIT makes ReconfigurableMaze wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ReconfigurableMaze_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%�V���A���|�[�g���J��-------------------------------------------------------
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
%�V���A���|�[�g
s = handles.serial;
%�V���A���ʐM���J��
fopen(s);
%�|�[�g���J���̂ɂQ�b�K�v
set(handles.edit1, 'String', '�V���A���|�[�g���J����');
pause(2);
set(handles.edit1, 'String', '�V���A���|�[�g�J��');
%�Z�[�u
handles.serial = s;
guidata(hObject, handles);
%--------------------------------------------------------------------------
%�V���A���|�[�g�����-----------------------------------------------------
% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s = handles.serial;
fclose(s);
set(handles.edit1, 'String', '�V���A���|�[�g��ؒf');
%--------------------------------------------------------------------------


%�o�͗p�e�L�X�g�{�b�N�X-----------------------------------------------------
%��ɒʐM�󋵂Ȃǂ��o��
%--------------------------------------------------------------------------
function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.edit1 = get(hObject, 'String');
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------


%�v�b�V���{�^���R�u���݂̖��H�v----------------------------------------------��
%Arduino�����ݎ������Ă�����H�̃f�[�^���R�[�����A�l�����A�\������
%���ʃR�[�h�uA�v�𑗂�P�b�҂B
%�����Ă����f�[�^���K���Ȃ���H�f�[�^�Ƃ��ĉ��߁B��ʂɕ\������
% -------------------------------------------------------------------------
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%set(handles.edit1, 'String','testing');
%�V���A���|�[�g���󂯎��
s = handles.serial;
%Arduino�Ƀf�[�^��v������i���ʃR�[�h�uA�v�j
fprintf(s, '%c', 'A');
%�f�[�^�̕ԓ���҂�
pause(1);
%�ʐM���̃A�i�E���X
set(handles.edit1, 'String', '�f�[�^�ʐM��');
%���p�\�ȃo�b�t�@�̗ʂ�\������
n = s.BytesAvailable;
str = num2str(n);
set(handles.edit1, 'String', str);
%�f�[�^�����s���ȏꍇ
if n ~= 96
    %�o�b�t�@���N���A���ďI��
    while s.BytesAvailable
        fread(s,1);
    end
    return;
end
%�󂯎�����V���A���f�[�^��handles.s2oArd�ɓK������
for i = 1:12
    for j = 1:4
        handles.s2oArd{i,1}(j) = fread(s,1);
        handles.s2oArd{i,2}(j) = fread(s,1);
    end
end
%�ύX���Z�[�u
guidata(hObject, handles);
%�e�L�X�g�\���p������𐶐�
st = s2o_Display(handles.s2oArd, 0);
%�������\��
set(handles.text7, 'String', st);
%�ʐM�I��
set(handles.edit1, 'String', '');
%--------------------------------------------------------------------------


%�upopupmenu1�v�����ς������Z���T��I��------------------------------------��
% �Z���T�E�~���Z���T�F�Z���T�𓥂񂾎��̏o��
% �|�[�L���O�F�C���^���v�g���p�̂��߁A���ݕҏW�s��
% �~���F�g���b�h�~�����w��b����������̓���
%--------------------------------------------------------------------------
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
str = get(hObject, 'String');
val = get(hObject, 'value');
%snsr2output[i]�̃C���f�b�N�Xi�ɑ����B���l��ς���ꍇ�͒���
switch str{val}
case '�Z���T�P'
        handles.targetsnsr = 0;
case '�Z���T�Q'
        handles.targetsnsr = 1;
case '�Z���T�R'
        handles.targetsnsr = 2;
case '�Z���T�S'
        handles.targetsnsr = 3;        
case '�Z���T�T'
        handles.targetsnsr = 4;
case '�Z���T�U'
        handles.targetsnsr = 5;        
case '�Z���T�V'
        handles.targetsnsr = 6;        
case '�Z���T�W'
        handles.targetsnsr = 7;
case '�~���Z���T�P'
        handles.targetsnsr = 8;        
case '�~���Z���T�Q'
        handles.targetsnsr = 9;        
case '�|�[�L���O�P'
        handles.targetsnsr = 10;
case '�|�[�L���O�Q'
        handles.targetsnsr = 11;
case '�~���P'
        handles.targetsnsr = 12;
case '�~���Q'
        handles.targetsnsr = 13;
end
%save
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
%�upopupmenu2�`5�v�o�͂�ς������A�E�g�v�b�g�s����I��------------------------��
%handles.targetoutput(0�`3)�ɑ��삷��Z���T�̒l���i�[
%popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles) %#ok<*INUSL>
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(hObject, 'String');
val = get(hObject, 'value');
%�o�͂�ς������A�E�g�v�b�g�s���B�O�i���g�p�j�܂��͂Q�Q�`�R�V
%handles.targetoutput0 = TargetOutput(str, val);
handles.targetoutput(1,1) = TargetOutput(str, val);
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(hObject, 'String');
val = get(hObject, 'value');
%handles.targetoutput1 = TargetOutput(str, val);
handles.targetoutput(2,1) = TargetOutput(str, val);
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(hObject, 'String');
val = get(hObject, 'value');
%handles.targetoutput2 = TargetOutput(str, val);
handles.targetoutput(3,1) = TargetOutput(str, val);
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(hObject, 'String');
val = get(hObject, 'value');
%handles.targetoutput3 = TargetOutput(str, val);
handles.targetoutput(4,1) = TargetOutput(str, val);
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%GUI�̃��[�U���͂��󂯂ăZ���T�ɑΉ�����o�͂�^����---------------------------��
%arduino�̃Z���T�̒�`�ɏ]��
% �o�͂Ȃ��F�O
% �Q�[�g�F�Q�Q�`�Q�X
% �~���ғ��F�R�O�E�R�P
% �~���̌����F�R�Q�E�R�R
% feed�F�R�S�E�R�T
% discard�F�R�U�E�R�V
% ��������F�P�O�P�A�P�O�Q
%--------------------------------------------------------------------------
function m = TargetOutput(str, val)
switch str{val}
case '(�g�p���Ȃ�)'
        m = 0;
case '�Q�[�g�P'
        m = 22;
case '�Q�[�g�Q'
        m = 23;        
case '�Q�[�g�R'
        m = 24;
case '�Q�[�g�S'
        m = 25;
case '�Q�[�g�T'
        m = 26;
case '�Q�[�g�U'
        m = 27;
case '�Q�[�g�V'
        m = 28;
case '�Q�[�g�W'
        m = 29;  
case '�~���P����'
        m = 32;
case '�~���Q����'
        m = 33;
case '�~���P����'
        m = 30;
case '�~���Q����'
        m = 31;
case '����P'
        m = 101;
case '����Q'
        m = 102;
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% �A�E�g�v�b�g�o�͂��ǂ��ς��������BHIGH�i�P�j�܂���LOW�i�O�j
%�`�F�b�N�{�b�N�X�̃I���i�P�j�I�t�i�O�j��handles.outputHorL�ŎQ�Ƃł���悤�ɂ���
%--------------------------------------------------------------------------
%checkbox_high1.
function checkbox_high1_Callback(hObject, ~, handles) %#ok<*DEFNU>
handles.outputHorL(1,1) = get(hObject, 'Value');
guidata(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of checkbox_high1
%checkbox_high2.
function checkbox_high2_Callback(hObject, ~, handles)
handles.outputHorL(2,1) = get(hObject, 'Value');
guidata(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of checkbox_high2
%checkbox_high3.
function checkbox_high3_Callback(hObject, ~, handles)
handles.outputHorL(3,1) = get(hObject, 'Value');
guidata(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of checkbox_high3
%checkbox_high4.
function checkbox_high4_Callback(hObject, ~, handles)
handles.outputHorL(4,1) = get(hObject, 'Value');
guidata(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of checkbox_high4
%checkbox_low1.
function checkbox_low1_Callback(hObject, ~, handles)
handles.outputHorL(1,2) = get(hObject, 'Value');
guidata(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of checkbox_low1
%checkbox_low2.
function checkbox_low2_Callback(hObject, ~, handles)
handles.outputHorL(2,2) = get(hObject, 'Value');
guidata(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of checkbox_low2
% --- Executes on button press in checkbox_low3.
function checkbox_low3_Callback(hObject, ~, handles) %#ok<*INUSD>
handles.outputHorL(3,2) = get(hObject, 'Value');
guidata(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of checkbox_low3
% --- Executes on button press in checkbox_low4.
function checkbox_low4_Callback(hObject, ~, handles)
handles.outputHorL(4,2) = get(hObject, 'Value');
guidata(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of checkbox_low4
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%�~���̓��쎞�Ԃ�handles�Ɋi�[����
%--------------------------------------------------------------------------
function edit8_Callback(hObject, ~, handles)
i = str2double( get(hObject, 'String') );
%�s���ȓ��쎞�Ԃ��͂���
%60�b�܂�
if i<0 || 60<i
    i = 0;
end
handles.milltime = i;
guidata(hObject, handles);
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------


%�v�b�V���{�^���W�u�ҏW�v----------------------------------------------------��
%���[�U���ҏW�������H�f�[�^��K�p���A���̌�A���݂�GUI���̖��H�f�[�^���e�L�X�g�\��
function pushbutton8_Callback(hObject, ~, handles)
%targetsnsr�͂O�`�P�P�̓Z���T�E�~���Z���T�E�|�[�L���O
if handles.targetsnsr < 12
    %�����ς������Z���T �P�`�P�Q
    i = handles.targetsnsr + 1;
    for j = 1:4
        %�����ς������A�E�g�v�b�g�s���@�O�A�Q�Q�`�R�V
        handles.s2oGUI{i,1}(j) = handles.targetoutput(j);
        %����̎�ށ@�O�F���[�@�P�F�n�C
        HL = 0;
        if handles.outputHorL(j,1) == 1
            HL = 1;
        end
        if handles.outputHorL(j,2) == 1
            HL = 0;
        end
        handles.s2oGUI{i,2}(j) = HL;
        % is multi-activation disallowed?
        handles.s2oGUI{i,3}(j) = handles.mlt_disallow(j);
        % delay time
        handles.s2oGUI{i,4}(j) = handles.delay_time(j);
    end
%targetsnsr���P�Q�E�P�R�̓~���̓���
elseif handles.targetsnsr < 14
    %�����ς������~���@�P�`�Q
    i = handles.targetsnsr - 11;
    for j = 1:4
        %�����ς������A�E�g�v�b�g�s���@�O�A�Q�Q�`�R�V
        handles.millGUI{i,1}(j) = handles.targetoutput(j);
        %����̎�ށ@�O�F���[�@�P�F�n�C
        HL = 0;
        if handles.outputHorL(j,1) == 1
            HL = 1;
        end
        if handles.outputHorL(j,2) == 1
            HL = 0;
        end
        handles.millGUI{i,2}(j) = HL;
    end
    %�~���̓��쎞��
    handles.millGUI{i,3} = handles.milltime;
end
%�ύX���Z�[�u
guidata(hObject, handles);
%�e�L�X�g�\���p������𐶐�
s = s2o_Display(handles.s2oGUI, 1);
t = [];%mill_Display(handles.millGUI);
%�������\��
set(handles.text7, 'String', [s t]);
%--------------------------------------------------------------------------


%s2o�f�[�^��GUI�̃X�^�e�B�b�N�e�L�X�g�ɕ\�����邽�߂ɕ�����ɂ���֐�----------��
function s = s2o_Display(cell, isGUI)
%�\������e�L�X�g
s = '';
%���ݕ\�����Ă���f�[�^�̎��
if isGUI == 1
    s = [s '�����H�ҏW����' newline];
else
    s = [s '��������' newline];
end
for i = 1:10 %�|�[�L���O�ł̓����GUI����͂��܂͐ݒ�ł��Ȃ��悤��
    %�Z���T�̎�ނ�\��
    %�P�`�W�F�Z���T�B�X�`�P�O�F�~���Z���T�B�P�P�`�P�Q�F�|�[�L���O
    if i <= 8
        s = [s 'sensor' char(i+48) ':' newline];
    elseif i <= 10
        s = [s 'MillSensor' char(i+40) ':' newline];
    elseif i <= 12
        s = [s 'Porking' char(i+38) ':' newline];
    end
    for j = 1:4
        %�o�͐�s���̎��
        %�O�F���g�p�B�Q�Q�`�Q�X�F�Q�[�g�B�R�O�`�R�P�F�~���ғ��B�R�Q�`�R�R�F�~�������B
        %�R�S�`�R�T�F�G�T�o���B�R�U�`�R�V�F�G�T���Ƃ��B
        k = cell{i,1}(j);
        l = cell{i,2}(j);
        if k > 0
            %�o�͂̎��
            if k <= 29
                s = [s ' Gate' char(k+27) '->'];
            elseif k <= 31
                s = [s ' Treadmill' char(k+19) '->'];
            elseif k <= 33
                s = [s ' DirofMill' char(k+17) '->'];
            elseif k <= 35
                s = [s ' Feed' char(k+15) '->'];
            elseif k <= 37
                s = [s ' Discard' char(k+13) '->'];
            end
            %�o�͂�HIGHorLOW
            if l == 1
                s = [s 'HIGH '];
            elseif l == 0
                s = [s 'LOW '];
            end
            %�A������s����
            if cell{i,3}(j) > 0
                s = [s '�A��x '];
            end
            %�x������ꍇ
            if cell{i,4}(j) > 0
                s = [s 'dly:' num2str( cell{i,4}(j) ) ' '];
            end
        end
    end
    s = [s newline];
end
%--------------------------------------------------------------------------
%mill�f�[�^��GUI�̃X�^�e�B�b�N�e�L�X�g�ɕ\�����邽�߂ɕ�����ɂ���֐�---------��
function s = mill_Display(cell)
%�\������e�L�X�g
s = '';
for i = 1:2
    %mill1,mill2
    s = [s 'mill' char(i+48) ':' newline];
    %�~�����쎞��
    s = [s ' ���쎞�ԁF' num2str(cell{i,3}) '�b '];
    for j = 1:4
        %�o�͐�s���̎��
        %�O�F���g�p�B�Q�Q�`�Q�X�F�Q�[�g�B�R�O�`�R�P�F�~���ғ��B�R�Q�`�R�R�F�~�������B
        %�R�S�`�R�T�F�G�T�o���B�R�U�`�R�V�F�G�T���Ƃ��B
        k = cell{i,1}(j);
        l = cell{i,2}(j);
        if k > 0
            %�o�͂̎��
            if k <= 29
                s = [s ' Gate' char(k+27) '->'];
            elseif k <= 31
                s = [s ' Treadmill' char(k+19) '->'];
            elseif k <= 33
                s = [s ' DirofMill' char(k+17) '->'];
            elseif k <= 35
                s = [s ' Feed' char(k+15) '->'];
            elseif k <= 37
                s = [s ' Discard' char(k+13) '->'];
            end
            %�o�͂�HIGHorLOW
            if l == 1
                s = [s 'HIGH '];
            elseif l == 0
                s = [s 'LOW '];
            end
        end
    end
    s = [s newline];
end
%--------------------------------------------------------------------------


%�t�@�C���փZ�[�u-----------------------------------------------------------
% --- Executes on button press in push_save.
function push_save_Callback(hObject, eventdata, handles)
fnc_SaveMazeData(handles, 'uisave');
%--------------------------------------------------------------------------
%�t�@�C�������[�h-----------------------------------------------------------
% --- Executes on button press in push_load.
function push_load_Callback(hObject, eventdata, handles)
%���H���A�Z�b�V�����������[�h
fnc_LoadMazeData(handles, 'uiopen', hObject);
%--------------------------------------------------------------------------


%�Z�b�V�����X�^�[�g---------------------------------------------------------
%�Z�b�V�����J�n���R�[������
%����J�n�̎��ʃR�[�h'd'���󂯎�����ꍇ�A�G�f�B�b�g���[�h���I�����ăZ�b�V�������J�n����
%--------------------------------------------------------------------------
function push_sessionstart_Callback(hObject, eventdata, handles)
%�V���A���|�[�g
s = handles.serial;
if strcmp(s.Status, 'closed')
    set(handles.edit1, 'String', '�V���A���|�[�g���J���Ă�������');
    return;
end
%Arduino�Ƀf�[�^��v������i���ʃR�[�h�uD�v�j
SerialCommunication(handles, 'D');
%�f�[�^�̕ԓ���҂�
pause(0.1);
%�V���A���|�[�g��GUI�Ԃňڍs���邽�߂ɊO���Z�[�u
save('serial', 's');
%�������Z�b�V�������J�n�ł����ꍇ�AGUI��؂�ւ���
if s.BytesAvailable
    %�Z�b�V�����J�n��ʒm����V���A���ʐM
    if fread(s, 1) == 'd'
        %����ȍ~�N�����ɌĂяo�����߂ɁA���s����Z�b�V�����̃f�[�^��ۑ�
        fnc_SaveMazeData(handles,'save');
        %close�����ŃV���A���|�[�g�𗎂Ƃ��Ȃ��悤��
        handles.sessionstarted = true;
        guidata(hObject, handles);
        %���݂�figure�����
        close(handles.figure1);
        %�Z�b�V����GUI���J�n����
        Sessions;
    end
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% �v�b�V���{�^���P�R�u���H�̃f�[�^��K�p�v
% Arduino�ɃZ���T�Q�A�E�g�v�b�g/�~���Q�A�E�g�v�b�g�̃f�[�^�𑗐M����
%--------------------------------------------------------------------------
function push_sendmazedata_Callback(hObject, eventdata, handles)
%�|�[�g���J���ĂȂ���ΒʐM���Ȃ�
s = handles.serial;
if strcmp(s.Status, 'closed')
    set(handles.edit1, 'String', '�V���A���|�[�g���J���Ă�������');
    return;
end
%�ʐM���̃A�i�E���X
set(handles.edit1, 'String', '�f�[�^�ʐM��');
%�Z���T�Q�A�E�g�v�b�g�̃f�[�^���V���A���ʐM
SerialCommunication(handles, 'B');
%�~���Q�A�E�g�v�b�g�̃f�[�^���V���A���ʐM
SerialCommunication(handles, 'G');
%�Z�b�V�����̐ݒ���V���A���ʐM
pause(0.1);
SerialCommunication(handles, 'C');
%�������[�g�E����
if handles.userfile==1 && handles.sessionGUI{4}>0
    %�Z�b�V�����f�[�^�̏������I���܂ő҂�
    pause(0.2);
    load('cells.mat', 'c');
    handles.userdata = c;
    %�Z�b�V�����񐔂����ʐM
    for i=1:handles.sessionGUI{4}
        SerialCommunication(handles, 'H', i);
        pause(0.1);
    end
end
%�I���^�l�C�V����
if handles.userfile==2
    %�Z�b�V�����f�[�^�̏������I���܂ő҂�
    pause(0.2);
    load('alternation.mat', 'c');
    handles.userdata = c;
    SerialCommunication(handles, 'J');
end
%���������f�[�^��\������iArduino�̒ʐM�͉�Ȃ��j
%�e�L�X�g�\���p������𐶐�
s = s2o_Display(handles.s2oGUI, 0);
t = mill_Display(handles.millGUI);
%�������\��
set(handles.text7, 'String', [s t]);
%sessionGUI���當����𐶐�
s = session_Display(handles,'��������');
%�������\��
set(handles.text16, 'String', s);
%�ʐM�I���̃A�i�E���X
set(handles.edit1, 'String', '�ʐM�I��');
%--------------------------------------------------------------------------















%--------------------------------------------------------------------------��
%�Z�b�V�����̃��[�U�ҏW��handles�Ɋi�[����
%--------------------------------------------------------------------------
%�Z�b�V�����̏������
%handles.sessionGUI{1}(1-8)
%--------------------------------------------------------------------------
% --- Executes on selection change in popup_initialgate1.
function popup_initialgate1_Callback(hObject, eventdata, handles)
%GUI�̕ω����󂯎��
str = get(hObject, 'String');
val = get(hObject, 'value');
%�f�[�^���i�[���Z�[�u
s = 0;
switch str{val}
    case '�Q�[�g�P�@OPEN'
        s = 1;
end
handles.sessionGUI{1}(1) = s;
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function popup_initialgate1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_initialgate1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on selection change in popup_initialgate2.
function popup_initialgate2_Callback(hObject, eventdata, handles)
%GUI�̕ω����󂯎��
str = get(hObject, 'String');
val = get(hObject, 'value');
%�f�[�^���i�[���Z�[�u
s = 0;
switch str{val}
    case '�Q�[�g�Q�@OPEN'
        s = 1;
end
handles.sessionGUI{1}(2) = s;
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function popup_initialgate2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_initialgate2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on selection change in popup_initialgate3.
function popup_initialgate3_Callback(hObject, eventdata, handles)
%GUI�̕ω����󂯎��
str = get(hObject, 'String');
val = get(hObject, 'value');
%�f�[�^���i�[���Z�[�u
s = 0;
switch str{val}
    case '�Q�[�g�R�@OPEN'
        s = 1;
end
handles.sessionGUI{1}(3) = s;
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function popup_initialgate3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_initialgate3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on selection change in popup_initialgate4.
function popup_initialgate4_Callback(hObject, eventdata, handles)
%GUI�̕ω����󂯎��
str = get(hObject, 'String');
val = get(hObject, 'value');
%�f�[�^���i�[���Z�[�u
s = 0;
switch str{val}
    case '�Q�[�g�S�@OPEN'
        s = 1;
end
handles.sessionGUI{1}(4) = s;
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function popup_initialgate4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_initialgate4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on selection change in popup_initialgate5.
function popup_initialgate5_Callback(hObject, eventdata, handles)
%GUI�̕ω����󂯎��
str = get(hObject, 'String');
val = get(hObject, 'value');
%�f�[�^���i�[���Z�[�u
s = 0;
switch str{val}
    case '�Q�[�g�T�@OPEN'
        s = 1;
end
handles.sessionGUI{1}(5) = s;
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function popup_initialgate5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_initialgate5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on selection change in popup_initialgate6.
function popup_initialgate6_Callback(hObject, eventdata, handles)
%GUI�̕ω����󂯎��
str = get(hObject, 'String');
val = get(hObject, 'value');
%�f�[�^���i�[���Z�[�u
s = 0;
switch str{val}
    case '�Q�[�g�U�@OPEN'
        s = 1;
end
handles.sessionGUI{1}(6) = s;
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function popup_initialgate6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_initialgate6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on selection change in popup_initialgate7.
function popup_initialgate7_Callback(hObject, eventdata, handles)
%GUI�̕ω����󂯎��
str = get(hObject, 'String');
val = get(hObject, 'value');
%�f�[�^���i�[���Z�[�u
s = 0;
switch str{val}
    case '�Q�[�g�V�@OPEN'
        s = 1;
end
handles.sessionGUI{1}(7) = s;
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function popup_initialgate7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_initialgate7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on selection change in popup_initialgate8.
function popup_initialgate8_Callback(hObject, eventdata, handles)
%GUI�̕ω����󂯎��
str = get(hObject, 'String');
val = get(hObject, 'value');
%�f�[�^���i�[���Z�[�u
s = 0;
switch str{val}
    case '�Q�[�g�W�@OPEN'
        s = 1;
end
handles.sessionGUI{1}(8) = s;
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function popup_initialgate8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_initialgate8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------����
%�Z�b�V�����̃X�^�[�g�����߂�Z���T
%handles.sessionGUI{2}(1-4)
%--------------------------------------------------------------------------
% --- Executes on selection change in popupmenu29.
function popupmenu29_Callback(hObject, eventdata, handles)
%GUI�̕ω����󂯎��
str = get(hObject, 'String');
val = get(hObject, 'value');
%�f�[�^���i�[���Z�[�u
handles.sessionGUI{2}(1) = SorG_Snsr(str,val);
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function popupmenu29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on selection change in popupmenu30.
function popupmenu30_Callback(hObject, eventdata, handles)
%GUI�̕ω����󂯎��
str = get(hObject, 'String');
val = get(hObject, 'value');
%�f�[�^���i�[���Z�[�u
handles.sessionGUI{2}(2) = SorG_Snsr(str,val);
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function popupmenu30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on selection change in popupmenu31.
function popupmenu31_Callback(hObject, eventdata, handles)
%GUI�̕ω����󂯎��
str = get(hObject, 'String');
val = get(hObject, 'value');
%�f�[�^���i�[���Z�[�u
handles.sessionGUI{2}(3) = SorG_Snsr(str,val);
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function popupmenu31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on selection change in popupmenu32.
function popupmenu32_Callback(hObject, eventdata, handles)
%GUI�̕ω����󂯎��
str = get(hObject, 'String');
val = get(hObject, 'value');
%�f�[�^���i�[���Z�[�u
handles.sessionGUI{2}(4) = SorG_Snsr(str,val);
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function popupmenu32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------����
%�Z�b�V�����̃S�[�������߂�Z���T
%handles.sessionGUI{3}(1-4)
%--------------------------------------------------------------------------
% --- Executes on selection change in popupmenu33.
function popupmenu33_Callback(hObject, eventdata, handles)
%GUI�̕ω����󂯎��
str = get(hObject, 'String');
val = get(hObject, 'value');
%�f�[�^���i�[���Z�[�u
handles.sessionGUI{3}(1) = SorG_Snsr(str,val);
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function popupmenu33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on selection change in popupmenu34.
function popupmenu34_Callback(hObject, eventdata, handles)
%GUI�̕ω����󂯎��
str = get(hObject, 'String');
val = get(hObject, 'value');
%�f�[�^���i�[���Z�[�u
handles.sessionGUI{3}(2) = SorG_Snsr(str,val);
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function popupmenu34_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on selection change in popupmenu35.
function popupmenu35_Callback(hObject, eventdata, handles)
%GUI�̕ω����󂯎��
str = get(hObject, 'String');
val = get(hObject, 'value');
%�f�[�^���i�[���Z�[�u
handles.sessionGUI{3}(3) = SorG_Snsr(str,val);
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function popupmenu35_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on selection change in popupmenu36.
function popupmenu36_Callback(hObject, eventdata, handles)
%GUI�̕ω����󂯎��
str = get(hObject, 'String');
val = get(hObject, 'value');
%�f�[�^���i�[���Z�[�u
handles.sessionGUI{3}(4) = SorG_Snsr(str,val);
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function popupmenu36_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%�ǂ̃Z���T���X�^�[�g�܂��̓S�[���ɂ��邩��ϐ��ɂ���
function s = SorG_Snsr(str,val)
switch str{val}
    case '�i���g�p�j'
        s=0;
    case '�Z���T�P'
        s=1;
    case '�Z���T�Q'
        s=2;
    case '�Z���T�R'
        s=3;        
    case '�Z���T�S'
        s=4;        
    case '�Z���T�T'
        s=5;        
    case '�Z���T�U'
        s=6;        
    case '�Z���T�V'
        s=7;        
    case '�Z���T�W'
        s=8;
    case '�~���Z���T�P'
        s=9;
    case '�~���Z���T�Q'
        s=10;
end
%--------------------------------------------------------------------------����
%�Z�b�V�����񐔂��i�[����
%--------------------------------------------------------------------------
function edit5_Callback(hObject, eventdata, handles)
i = str2double( get(hObject, 'String') );
%�s���ȃZ�b�V�����񐔂��͂���
if i<0 || 127<i
    i = 100;
end
handles.sessionGUI{4} = i;
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
% �O���t�@�C���̗��p��
%--------------------------------------------------------------------------
function popupmenu38_Callback(hObject, eventdata, handles)
%GUI�̕ω����󂯎��
str = get(hObject, 'String');
val = get(hObject, 'value');
switch str{val}
    case '�i���g�p�j'
        s=0;
    case '����E�������[�g'
        s=1;
    case '�I���^�l�C�V����'
        s=2;
end
handles.userfile = s;
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function popupmenu38_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------����


%--------------------------------------------------------------------------����
%�u�Z�b�V�������e�K�p�v
function push_editsession_Callback(hObject, eventdata, handles)
%sessionGUI���當����𐶐�
s = session_Display(handles,'���Z�b�V�����̓��e��');
%�������\��
set(handles.text16, 'String', s);
%--------------------------------------------------------------------------����
%�Z�b�V�����̓��e�𕶎���ɂ��ĕԂ��֐�
%--------------------------------------------------------------------------
function s = session_Display(handles, str)
cl = handles.sessionGUI;
%�ŏI�I�ɕ\�����镶����
s = [str char(10)];
s = [s '������ԁF' char(10)];
%�������
for i = 1:8
    s = [s '�@Gate' num2str(i) ' '];
    sb= 'CLOSE';
    if cl{1}(i) == 1
        sb= 'OPEN';
    end
    s = [s sb char(10)];
end
%�X�^�[�g�Z���T
%cl{2}(1-4)�ɂ��ĂO�Ȃ疢�g�p�A�P�`�W�Z���T�A�X�`�P�O�~���Z���T
s = [s '�X�^�[�g�Z���T�F' char(10)];
for i = 1:4
    j = cl{2}(i);
    if 0 < j
        if j < 9
            s = [s '�@Sensor' char(j+48) char(10)]; 
        elseif j < 11
            s = [s '�@MillSensor' char(j+40) char(10)];
        end
    end
end
%�S�[���Z���T
%cl{3}(1-4)�ɂ��ĂO�Ȃ疢�g�p�A�P�`�W�Z���T�A�X�`�P�O�~���Z���T
s = [s '�S�[���Z���T�F' char(10)];
for i = 1:4
    j = cl{3}(i);
    if 0 < j
        if j < 9
            s = [s '�@Sensor' char(j+48) char(10)];
        elseif j < 11
            s = [s '�@MillSensor' char(j+40) char(10)];
        end
    end
end
%�Z�b�V������
s = [s '�Z�b�V�������F' char(10) '�@' num2str(cl{4}) char(10)]; 
%���[�U�t�@�C���̗��p��
switch handles.userfile
    case 0
        str = '���p���Ȃ�';
    case 1
        str = '����E�������[�g';
    case 2
        str = '�I���^�l�C�V����';
end
s = [s '���[�U��`�t�@�C���F' char(10) '�@' str];
%--------------------------------------------------------------------------


%�쓮�e�X�g�Ȃǂŗ��p����
% --- Executes on button press in push_test.
function push_test_Callback(hObject, eventdata, handles)
s=handles.serial;
% fwrite(s, 'Z');
% pause(1);
%�V���A���ʐM�𐔒l�ŕ\��
t = '';
while s.BytesAvailable
    t = [t num2str(fread(s,1)+0) ', '];
end
set(handles.text7, 'String', t);



%GUI�I�����̏���-----------------------------------------------------------
%Guide�̃��j���[�o�[����G�f�B�^�ɏ����o����
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%�|�[�g���J���Ă���Ε���
s = handles.serial;
%�Z�b�V�����J�n�̏ꍇ�̓V���A������Ȃ�
if ~handles.sessionstarted
    if strcmp(s.Status, 'open')
        fclose(s);
    end
    delete(s);
    clear('s');
end
%���H�T�σE�B���h�E���J���Ă���΍폜����
c = findobj('Name', 'MazeAppearance');
if ~isempty(c)
    close('MazeAppearance');
end
%�I�u�W�F�N�g���폜����
delete(hObject);
%--------------------------------------------------------------------------


%���H�ҏWGUI���Ăяo��
% --- Executes on button press in push_MazeAppearance.
function push_MazeAppearance_Callback(hObject, eventdata, handles)
MazeAppearance


%save maze data
function fnc_SaveMazeData(handles,str)
cl = handles.s2oGUI;
ml = handles.millGUI;
ss = handles.sessionGUI;
uf = handles.userfile;
switch str
    case 'uisave'
        uisave({'cl','ml','ss','uf'},'NameOfMaze');
    case 'save'
        save('ReconfigurableMaze.mat', 'cl', 'ml', 'ss', 'uf');
end


%load maze data
function fnc_LoadMazeData(handles, str, hObject)
switch str
    case 'load'
        load('ReconfigurableMaze.mat', 'cl', 'ml', 'ss', 'uf');
    case 'uiopen'
        uiopen('*.mat');
end
handles.s2oGUI = cl;
handles.millGUI = ml;
handles.sessionGUI = ss;
handles.userfile = uf;
%�e�L�X�g�\���p������𐶐��i���H�f�[�^�j
s = s2o_Display(handles.s2oGUI, 1);
t = []; %mill_Display(handles.millGUI);
%�������\��
set(handles.text7, 'String', [s t]);
%�e�L�X�g�\���p��������쐬�i�Z�b�V�����f�[�^�j
s = session_Display(handles, '���Z�b�V�����̓��e��');
%�������\��
set(handles.text16, 'String', s);
%���[�h��K�p
guidata(hObject, handles);


%--------------------------------------------------------------------------
% �Z���T�̕����񓮍�̋���
% GUI�ł̕ύX��handles�Ɋi�[
%--------------------------------------------------------------------------
% --- Executes on button press in checkbox_mlt_disallow1.
function checkbox_mlt_disallow1_Callback(hObject, ~, handles)
handles.mlt_disallow(1,1) = get(hObject, 'Value');
guidata(hObject, handles)
% --- Executes on button press in checkbox_mlt_disallow2.
function checkbox_mlt_disallow2_Callback(hObject, ~, handles)
handles.mlt_disallow(2,1) = get(hObject, 'Value');
guidata(hObject, handles)
% --- Executes on button press in checkbox_mlt_disallow3.
function checkbox_mlt_disallow3_Callback(hObject, ~, handles)
handles.mlt_disallow(3,1) = get(hObject, 'Value');
guidata(hObject, handles)
% --- Executes on button press in checkbox_mlt_disallow4.
function checkbox_mlt_disallow4_Callback(hObject, ~, handles)
handles.mlt_disallow(4,1) = get(hObject, 'Value');
guidata(hObject, handles)
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% �x������̒x�����Ԃ�ݒ�
%--------------------------------------------------------------------------
function edit_delaytime1_Callback(hObject, ~, handles)
i = str2double( get(hObject, 'String') );
%�s���ȓ��쎞�Ԃ��͂���
if i<0 || 255<i
    i = 0;
end
handles.delay_time(1,1) = i;
guidata(hObject, handles);
function edit_delaytime1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_delaytime1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_delaytime2_Callback(hObject, ~, handles)
i = str2double( get(hObject, 'String') );
%�s���ȓ��쎞�Ԃ��͂���
if i<0 || 255<i
    i = 0;
end
handles.delay_time(2,1) = i;
guidata(hObject, handles);
function edit_delaytime2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_delaytime2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_delaytime3_Callback(hObject, ~, handles)
i = str2double( get(hObject, 'String') );
%�s���ȓ��쎞�Ԃ��͂���
if i<0 || 255<i
    i = 0;
end
handles.delay_time(3,1) = i;
guidata(hObject, handles);
function edit_delaytime3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_delaytime3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_delaytime4_Callback(hObject, ~, handles)
i = str2double( get(hObject, 'String') );
%�s���ȓ��쎞�Ԃ��͂���
if i<0 || 255<i
    i = 0;
end
handles.delay_time(4,1) = i;
guidata(hObject, handles);
function edit_delaytime4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_delaytime4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
