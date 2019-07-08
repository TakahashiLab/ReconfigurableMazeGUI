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
% handlesの変数を宣言、初期化
%--------------------------------------------------------------------------
function Sessions_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Sessions (see VARARGIN)

% Choose default command line output for Sessions
handles.output = hObject;

%シリアルポートを引き継ぐ
load('serial', 's');
handles.serial = s;
%ユーザ定義ファイルの読み込み
load('cells.mat', 'c');
handles.userdata = c;
%string for result
handles.string_for_result = 'test';
%セーブ
guidata(hObject, handles);

%シリアル通信を受信したときのコールバック
s.BytesAvailableFcn = {@GetSessionData2, handles, hObject};    %動く


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


% push_exitsession.-------------------------------------------------------------◆◆
% セッションを終了する
%--------------------------------------------------------------------------
function push_exitsession_Callback(~, ~, handles)
%シリアルポートを閉じる
s=handles.serial;
fclose(s);
delete(s);
clear('s');
%figureを閉じる
close(handles.figure1);
%エディットGUIを開始する
ReconfigurableMaze
% hObject    handle to push_exitsession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% %シリアルポート
% s = handles.serial;
% %Arduinoにセッションの終了を要求する（識別コード「E」）
% fprintf(s, '%c', 'E');
% %データの返答を待つ
% pause(0.1);
% %正しくセッションを終了できた場合、GUIを切り替える
% if s.BytesAvailable
%     %セッション終了を通知する識別コード
%     if fread(s, 1) == 'e'
%         %シリアルポートを閉じる
%         fclose(s);
%         delete(s);
%         clear('s');
%         %figureを閉じる
%         close(handles.figure1);
%         %エディットGUIを開始する
%         SerialTest;
%     end
% end


%debgu用ボタン
% --- Executes on button press in push_debug.
function push_debug_Callback(~, ~, handles)
% hObject    handle to push_debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=handles.serial;
fwrite(s, 'Z');
pause(1);
DisplayBufferData(handles);

        
        
%GUI終了時の処理-----------------------------------------------------------
%Guideのメニューバーからエディタに書き出せる
function figure1_CloseRequestFcn(hObject, ~, handles)
%終了時はシリアルポートを閉じる
s = handles.serial;
fclose(s);
delete(s);
clear('s');
delete(hObject);
%--------------------------------------------------------------------------


%「シリアル通信コールバック」------------------------------------------------
% シリアル通信の受信で動作
% この関数の中で動作を一元管理する
%--------------------------------------------------------------------------
function GetSessionData2( ~, ~, handles, hObject)  %動く
%シリアルポート
s = handles.serial;
%バッファがある場合、有効な識別コードなら、対応する処理をする
if s.BytesAvailable
    %識別コードを読み出す
    id = fread(s,1);
    %識別コードに対応する処理
    switch id
    case 'f'
        %セッション毎の結果報告->トライアル
        DisplaySessionResult(handles, hObject);
    case 'h'
        %識別コード'H'のエコーバック
        %DisplayBufferData(handles);
    case 'i'
        %正解のセンサ列・現在のセンサ列を受け取る。debug用
        pause(0.2);
        t = ['正解のセンサ列：' newline '  '];
        for i=1:8
            t = [t num2str( fread(s,1)+0 ) ','];
        end
        t = [t newline '現在のセンサ列：' newline '  '];
        for i=1:8
            t = [t num2str( fread(s,1)+0 ) ','];
        end
        set(handles.text5, 'String', t);
    otherwise
        %不正な識別コード
        %バッファを空にする
        while s.BytesAvailable
            fread(s,1);
        end
    end
end
%--------------------------------------------------------------------------
% セッションの結果を画面に表示する
%--------------------------------------------------------------------------
function DisplaySessionResult(handles, hObject)
%data is... [trial count][sensor record][success or not][success count]
%data syze... 1+8+1+1 bytes
%シリアルポート
s = handles.serial;
%データ受信
pause(0.1);
%read serial data
sessionNum = fread(s,1);
t = ['セッション数：' num2str(sessionNum) newline '今回のセンサ列：'];
snsr = [];
for i = 1:8
    snsr = [snsr num2str( fread(s,1)+0) ','];
end
t = [t snsr];
is_success = num2str( fread(s,1)+0 );
t = [t newline '成否：' is_success newline '成功数：'];
success_trials = num2str( fread(s,1)+0 );
t = [t success_trials];
handles.string_for_result = [get(handles.edit_result, 'String') snsr ' ' is_success ', ' success_trials '; '];
%handles.string_for_result = [handles.string_for_result snsr ' ' is_success ', ' success_trials '; '];
%guidata(hObject, handles);

%残っているバッファがあれば読み出し
while s.BytesAvailable
    t = [t num2str(fread(s,1)) ', '];
end
%描画
set(handles.text2, 'String', t );
set(handles.edit_result, 'String', handles.string_for_result);
%--------------------------------------------------------------------------


%バッファを一文字ずつ読み出して表示する
function DisplayBufferData(handles)
%シリアルポート
s = handles.serial;
%データ受信
%pause(1);
t= ['バッファのバイト数：' num2str(s.BytesAvailable) newline];
%バッファをすべて読み出して文字列に
while s.BytesAvailable
    u = num2str( (fread(s,1)+0) );
    t = [t u ', '];
end
%描画
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
