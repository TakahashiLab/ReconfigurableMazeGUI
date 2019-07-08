function varargout = Sessions(varargin)
% SESSIONS MATLAB code for Sessions.fig
%      SESSIONS, by itself, creates a new SESSIONS or raises the existing
%      singleton*.
%
%      H = SESSIONS returns the handle to a new SESSIONS or the handle to
%      the existing singleton*.
%
%      SESSIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SESSIONS.M with the given input arguments.
%
%      SESSIONS('Property','Value',...) creates a new SESSIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Sessions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Sessions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Sessions

% Last Modified by GUIDE v2.5 05-Oct-2017 19:23:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Sessions_OpeningFcn, ...
                   'gui_OutputFcn',  @Sessions_OutputFcn, ...
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


% --- Executes just before Sessions is made visible.
%--------------------------------------------------------------------------
% handles�̕ϐ���錾�A������
%--------------------------------------------------------------------------
function Sessions_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Sessions (see VARARGIN)

% Choose default command line output for Sessions
handles.output = hObject;

%�V���A���|�[�g�������p��
load('serial', 's');
handles.serial = s;
%���[�U��`�t�@�C���̓ǂݍ���
load('cells.mat', 'c');
handles.userdata = c;
%string for result
handles.string_for_result = 'test';
%�Z�[�u
guidata(hObject, handles);

%�V���A���ʐM����M�����Ƃ��̃R�[���o�b�N
s.BytesAvailableFcn = {@GetSessionData2, handles, hObject};    %����


% Update handles structure
guidata(hObject, handles);
%--------------------------------------------------------------------------

% UIWAIT makes Sessions wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Sessions_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% push_exitsession.-------------------------------------------------------------����
% �Z�b�V�������I������
%--------------------------------------------------------------------------
function push_exitsession_Callback(~, ~, handles)
%�V���A���|�[�g�����
s=handles.serial;
fclose(s);
delete(s);
clear('s');
%figure�����
close(handles.figure1);
%�G�f�B�b�gGUI���J�n����
ReconfigurableMaze
% hObject    handle to push_exitsession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% %�V���A���|�[�g
% s = handles.serial;
% %Arduino�ɃZ�b�V�����̏I����v������i���ʃR�[�h�uE�v�j
% fprintf(s, '%c', 'E');
% %�f�[�^�̕ԓ���҂�
% pause(0.1);
% %�������Z�b�V�������I���ł����ꍇ�AGUI��؂�ւ���
% if s.BytesAvailable
%     %�Z�b�V�����I����ʒm���鎯�ʃR�[�h
%     if fread(s, 1) == 'e'
%         %�V���A���|�[�g�����
%         fclose(s);
%         delete(s);
%         clear('s');
%         %figure�����
%         close(handles.figure1);
%         %�G�f�B�b�gGUI���J�n����
%         SerialTest;
%     end
% end


%debgu�p�{�^��
% --- Executes on button press in push_debug.
function push_debug_Callback(~, ~, handles)
% hObject    handle to push_debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=handles.serial;
fwrite(s, 'Z');
pause(1);
DisplayBufferData(handles);

        
        
%GUI�I�����̏���-----------------------------------------------------------
%Guide�̃��j���[�o�[����G�f�B�^�ɏ����o����
function figure1_CloseRequestFcn(hObject, ~, handles)
%�I�����̓V���A���|�[�g�����
s = handles.serial;
fclose(s);
delete(s);
clear('s');
delete(hObject);
%--------------------------------------------------------------------------


%�u�V���A���ʐM�R�[���o�b�N�v------------------------------------------------
% �V���A���ʐM�̎�M�œ���
% ���̊֐��̒��œ�����ꌳ�Ǘ�����
%--------------------------------------------------------------------------
function GetSessionData2( ~, ~, handles, hObject)  %����
%�V���A���|�[�g
s = handles.serial;
%�o�b�t�@������ꍇ�A�L���Ȏ��ʃR�[�h�Ȃ�A�Ή����鏈��������
if s.BytesAvailable
    %���ʃR�[�h��ǂݏo��
    id = fread(s,1);
    %���ʃR�[�h�ɑΉ����鏈��
    switch id
    case 'f'
        %�Z�b�V�������̌��ʕ�->�g���C�A��
        DisplaySessionResult(handles, hObject);
    case 'h'
        %���ʃR�[�h'H'�̃G�R�[�o�b�N
        %DisplayBufferData(handles);
    case 'i'
        %�����̃Z���T��E���݂̃Z���T����󂯎��Bdebug�p
        pause(0.2);
        t = ['�����̃Z���T��F' newline '  '];
        for i=1:8
            t = [t num2str( fread(s,1)+0 ) ','];
        end
        t = [t newline '���݂̃Z���T��F' newline '  '];
        for i=1:8
            t = [t num2str( fread(s,1)+0 ) ','];
        end
        set(handles.text5, 'String', t);
    otherwise
        %�s���Ȏ��ʃR�[�h
        %�o�b�t�@����ɂ���
        while s.BytesAvailable
            fread(s,1);
        end
    end
end
%--------------------------------------------------------------------------
% �Z�b�V�����̌��ʂ���ʂɕ\������
%--------------------------------------------------------------------------
function DisplaySessionResult(handles, hObject)
%data is... [trial count][sensor record][success or not][success count]
%data syze... 1+8+1+1 bytes
%�V���A���|�[�g
s = handles.serial;
%�f�[�^��M
pause(0.1);
%read serial data
sessionNum = fread(s,1);
t = ['�Z�b�V�������F' num2str(sessionNum) newline '����̃Z���T��F'];
snsr = [];
for i = 1:8
    snsr = [snsr num2str( fread(s,1)+0) ','];
end
t = [t snsr];
is_success = num2str( fread(s,1)+0 );
t = [t newline '���ہF' is_success newline '�������F'];
success_trials = num2str( fread(s,1)+0 );
t = [t success_trials];
handles.string_for_result = [get(handles.edit_result, 'String') snsr ' ' is_success ', ' success_trials '; '];
%handles.string_for_result = [handles.string_for_result snsr ' ' is_success ', ' success_trials '; '];
%guidata(hObject, handles);

%�c���Ă���o�b�t�@������Γǂݏo��
while s.BytesAvailable
    t = [t num2str(fread(s,1)) ', '];
end
%�`��
set(handles.text2, 'String', t );
set(handles.edit_result, 'String', handles.string_for_result);
%--------------------------------------------------------------------------


%�o�b�t�@���ꕶ�����ǂݏo���ĕ\������
function DisplayBufferData(handles)
%�V���A���|�[�g
s = handles.serial;
%�f�[�^��M
%pause(1);
t= ['�o�b�t�@�̃o�C�g���F' num2str(s.BytesAvailable) newline];
%�o�b�t�@�����ׂēǂݏo���ĕ������
while s.BytesAvailable
    u = num2str( (fread(s,1)+0) );
    t = [t u ', '];
end
%�`��
t = [newline t num2str(rand())];
%set(handles.text5, 'String', t );
%--------------------------------------------------------------------------



function edit_result_Callback(hObject, eventdata, handles)
% hObject    handle to edit_result (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_result as text
%        str2double(get(hObject,'String')) returns contents of edit_result as a double


% --- Executes during object creation, after setting all properties.
function edit_result_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_result (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
