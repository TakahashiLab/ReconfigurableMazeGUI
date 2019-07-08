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


%「セットアップ」-----------------------------------------------------------
%GUIのセットアップで呼ばれる関数。構造体に変数を追加するならここで
function ReconfigurableMaze_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ReconfigurableMaze (see VARARGIN)

% Choose default command line output for ReconfigurableMaze
handles.output = hObject;

%シリアルポート
%このパソコンでは有効なポートはUNO:COM6,MEGA:COM7
s = serial('COM10');
%ボーレート
set(s, 'BaudRate', 9600);
%コールバック関数のための設定
handles.serial = s;
s.BytesAvailableFcnCount = 1;
s.BytesAvailableFcnMode = 'byte';
s.BytesAvailableFcn = '';
%handlesにシリアルポートを渡す
handles.serial = s;

%handles構造体に変数を追加--------------------------------------------------
%迷路を編集するデータの一時格納
%操作を変えたいセンサ
handles.targetsnsr = 0;
%出力を変えたいアウトプット
handles.targetoutput = zeros(4,1);
%出力をどうするか（HIGHorLOW)
handles.outputHorL = zeros(4,2);
%連続動作の不許可
handles.mlt_disallow = zeros(4,1);
%delay time
handles.delay_time = zeros(4,1);
%ミルの動作時間
handles.milltime = 0;
%外部ファイルの利用状況
handles.userfile = 0;
%--------------------------------------------------------------------------
%snsr2outputに対応するデータ●
%[出力先ピン×４][出力内容×４][連続動作不許可×４][遅延時間×４]  センサ１
%                  …
%[出力先ピン×４][出力内容×４][連続動作不許可×４][遅延時間×４]　センサ１２（センサ８ミル２ポーク２）
%cell{x, y}(z)で各データにアクセスする
cell = {zeros(1, 4), zeros(1, 4), zeros(1, 4), zeros(1, 4)};
c = cell;
for i = 1:11
    cell = vertcat(cell, c);
end
%GUIで編集中のデータ
handles.s2oGUI = cell;
%Arduinoが現在持ってるデータ
handles.s2oArd = cell;
%ミルのデータ
%[出力先ピン×４]　：　[出力内容×４]  ：　[動作時間]　ミル１
%[出力先ピン×４]　：　[出力内容×４]  ：　[動作時間]　ミル２
cell = {zeros(1, 4), zeros(1, 4), 0};
c = cell;
cell = vertcat(cell, c);
%ミルの動作
handles.millGUI = cell;
%--------------------------------------------------------------------------
%セッション編集▲
%初期状態
%a = zeros(1,8);
a = ones(1,8);
%スタートセンサ
b = zeros(1,4);
%ゴールセンサ
c = zeros(1,4);
%セッション数
d = 0;
%分岐の列（未使用）
e = zeros(1,256);
%まとめてcellデータとする
cell = {a, b ,c, d, e};
%ユーザが編集したデータ
handles.sessionGUI = cell;
%Arduinoのデータ　※使わないようにしよう
%handles.sessionArd = cell;
%--------------------------------------------------------------------------
%シリアル通信を開く
% 自動化するとUSBささないと実行できないため、明示的にポートを開く
%--------------------------------------------------------------------------
%前回のセッションの情報を引き継ぎ、それをGUIに表示させる
%fnc_LoadMazeData(handles, 'load', hObject);
%--------------------------------------------------------------------------
%セッション開始のフラグ。終了時の処理を一部切り替え
handles.sessionstarted = false;
% セーブ
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


%シリアルポートを開く-------------------------------------------------------
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
%シリアルポート
s = handles.serial;
%シリアル通信を開通
fopen(s);
%ポートを開くのに２秒必要
set(handles.edit1, 'String', 'シリアルポートを開き中');
pause(2);
set(handles.edit1, 'String', 'シリアルポート開通');
%セーブ
handles.serial = s;
guidata(hObject, handles);
%--------------------------------------------------------------------------
%シリアルポートを閉じる-----------------------------------------------------
% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s = handles.serial;
fclose(s);
set(handles.edit1, 'String', 'シリアルポートを切断');
%--------------------------------------------------------------------------


%出力用テキストボックス-----------------------------------------------------
%主に通信状況などを出力
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


%プッシュボタン３「現在の迷路」----------------------------------------------★
%Arduinoが現在実装している迷路のデータをコールし、獲得し、表示する
%識別コード「A」を送り１秒待つ。
%送られてきたデータが適正なら迷路データとして解釈。画面に表示する
% -------------------------------------------------------------------------
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%set(handles.edit1, 'String','testing');
%シリアルポートを受け取る
s = handles.serial;
%Arduinoにデータを要請する（識別コード「A」）
fprintf(s, '%c', 'A');
%データの返答を待つ
pause(1);
%通信中のアナウンス
set(handles.edit1, 'String', 'データ通信中');
%利用可能なバッファの量を表示する
n = s.BytesAvailable;
str = num2str(n);
set(handles.edit1, 'String', str);
%データ長が不正な場合
if n ~= 96
    %バッファをクリアして終了
    while s.BytesAvailable
        fread(s,1);
    end
    return;
end
%受け取ったシリアルデータをhandles.s2oArdに適応する
for i = 1:12
    for j = 1:4
        handles.s2oArd{i,1}(j) = fread(s,1);
        handles.s2oArd{i,2}(j) = fread(s,1);
    end
end
%変更をセーブ
guidata(hObject, handles);
%テキスト表示用文字列を生成
st = s2o_Display(handles.s2oArd, 0);
%文字列を表示
set(handles.text7, 'String', st);
%通信終了
set(handles.edit1, 'String', '');
%--------------------------------------------------------------------------


%「popupmenu1」操作を変えたいセンサを選ぶ------------------------------------★
% センサ・ミルセンサ：センサを踏んだ時の出力
% ポーキング：インタラプト利用のため、現在編集不可
% ミル：トレッドミルを指定秒動かした後の動作
%--------------------------------------------------------------------------
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
str = get(hObject, 'String');
val = get(hObject, 'value');
%snsr2output[i]のインデックスiに相当。数値を変える場合は注意
switch str{val}
case 'センサ１'
        handles.targetsnsr = 0;
case 'センサ２'
        handles.targetsnsr = 1;
case 'センサ３'
        handles.targetsnsr = 2;
case 'センサ４'
        handles.targetsnsr = 3;        
case 'センサ５'
        handles.targetsnsr = 4;
case 'センサ６'
        handles.targetsnsr = 5;        
case 'センサ７'
        handles.targetsnsr = 6;        
case 'センサ８'
        handles.targetsnsr = 7;
case 'ミルセンサ１'
        handles.targetsnsr = 8;        
case 'ミルセンサ２'
        handles.targetsnsr = 9;        
case 'ポーキング１'
        handles.targetsnsr = 10;
case 'ポーキング２'
        handles.targetsnsr = 11;
case 'ミル１'
        handles.targetsnsr = 12;
case 'ミル２'
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
%「popupmenu2～5」出力を変えたいアウトプットピンを選ぶ------------------------★
%handles.targetoutput(0～3)に操作するセンサの値を格納
%popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles) %#ok<*INUSL>
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(hObject, 'String');
val = get(hObject, 'value');
%出力を変えたいアウトプットピン。０（未使用）または２２～３７
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
%GUIのユーザ入力を受けてセンサに対応する出力を与える---------------------------★
%arduinoのセンサの定義に従う
% 出力なし：０
% ゲート：２２～２９
% ミル稼動：３０・３１
% ミルの向き：３２・３３
% feed：３４・３５
% discard：３６・３７
% 条件分岐：１０１、１０２
%--------------------------------------------------------------------------
function m = TargetOutput(str, val)
switch str{val}
case '(使用しない)'
        m = 0;
case 'ゲート１'
        m = 22;
case 'ゲート２'
        m = 23;        
case 'ゲート３'
        m = 24;
case 'ゲート４'
        m = 25;
case 'ゲート５'
        m = 26;
case 'ゲート６'
        m = 27;
case 'ゲート７'
        m = 28;
case 'ゲート８'
        m = 29;  
case 'ミル１向き'
        m = 32;
case 'ミル２向き'
        m = 33;
case 'ミル１動作'
        m = 30;
case 'ミル２動作'
        m = 31;
case '分岐１'
        m = 101;
case '分岐２'
        m = 102;
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% アウトプット出力をどう変えたいか。HIGH（１）またはLOW（０）
%チェックボックスのオン（１）オフ（０）をhandles.outputHorLで参照できるようにする
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
%ミルの動作時間をhandlesに格納する
%--------------------------------------------------------------------------
function edit8_Callback(hObject, ~, handles)
i = str2double( get(hObject, 'String') );
%不正な動作時間をはじく
%60秒まで
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


%プッシュボタン８「編集」----------------------------------------------------★
%ユーザが編集した迷路データを適用し、その後、現在のGUI側の迷路データをテキスト表示
function pushbutton8_Callback(hObject, ~, handles)
%targetsnsrは０～１１はセンサ・ミルセンサ・ポーキング
if handles.targetsnsr < 12
    %操作を変えたいセンサ １～１２
    i = handles.targetsnsr + 1;
    for j = 1:4
        %操作を変えたいアウトプットピン　０、２２～３７
        handles.s2oGUI{i,1}(j) = handles.targetoutput(j);
        %操作の種類　０：ロー　１：ハイ
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
%targetsnsrが１２・１３はミルの動作
elseif handles.targetsnsr < 14
    %操作を変えたいミル　１～２
    i = handles.targetsnsr - 11;
    for j = 1:4
        %操作を変えたいアウトプットピン　０、２２～３７
        handles.millGUI{i,1}(j) = handles.targetoutput(j);
        %操作の種類　０：ロー　１：ハイ
        HL = 0;
        if handles.outputHorL(j,1) == 1
            HL = 1;
        end
        if handles.outputHorL(j,2) == 1
            HL = 0;
        end
        handles.millGUI{i,2}(j) = HL;
    end
    %ミルの動作時間
    handles.millGUI{i,3} = handles.milltime;
end
%変更をセーブ
guidata(hObject, handles);
%テキスト表示用文字列を生成
s = s2o_Display(handles.s2oGUI, 1);
t = [];%mill_Display(handles.millGUI);
%文字列を表示
set(handles.text7, 'String', [s t]);
%--------------------------------------------------------------------------


%s2oデータをGUIのスタティックテキストに表示するために文字列にする関数----------●
function s = s2o_Display(cell, isGUI)
%表示するテキスト
s = '';
%現在表示しているデータの種類
if isGUI == 1
    s = [s '◆迷路編集中◆' newline];
else
    s = [s '◆実装◆' newline];
end
for i = 1:10 %ポーキングでの動作はGUIからはいまは設定できないように
    %センサの種類を表示
    %１～８：センサ。９～１０：ミルセンサ。１１～１２：ポーキング
    if i <= 8
        s = [s 'sensor' char(i+48) ':' newline];
    elseif i <= 10
        s = [s 'MillSensor' char(i+40) ':' newline];
    elseif i <= 12
        s = [s 'Porking' char(i+38) ':' newline];
    end
    for j = 1:4
        %出力先ピンの種類
        %０：未使用。２２～２９：ゲート。３０～３１：ミル稼動。３２～３３：ミル向き。
        %３４～３５：エサ出し。３６～３７：エサ落とし。
        k = cell{i,1}(j);
        l = cell{i,2}(j);
        if k > 0
            %出力の種類
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
            %出力のHIGHorLOW
            if l == 1
                s = [s 'HIGH '];
            elseif l == 0
                s = [s 'LOW '];
            end
            %連続動作不許可
            if cell{i,3}(j) > 0
                s = [s '連続x '];
            end
            %遅延する場合
            if cell{i,4}(j) > 0
                s = [s 'dly:' num2str( cell{i,4}(j) ) ' '];
            end
        end
    end
    s = [s newline];
end
%--------------------------------------------------------------------------
%millデータをGUIのスタティックテキストに表示するために文字列にする関数---------●
function s = mill_Display(cell)
%表示するテキスト
s = '';
for i = 1:2
    %mill1,mill2
    s = [s 'mill' char(i+48) ':' newline];
    %ミル動作時間
    s = [s ' 動作時間：' num2str(cell{i,3}) '秒 '];
    for j = 1:4
        %出力先ピンの種類
        %０：未使用。２２～２９：ゲート。３０～３１：ミル稼動。３２～３３：ミル向き。
        %３４～３５：エサ出し。３６～３７：エサ落とし。
        k = cell{i,1}(j);
        l = cell{i,2}(j);
        if k > 0
            %出力の種類
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
            %出力のHIGHorLOW
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


%ファイルへセーブ-----------------------------------------------------------
% --- Executes on button press in push_save.
function push_save_Callback(hObject, eventdata, handles)
fnc_SaveMazeData(handles, 'uisave');
%--------------------------------------------------------------------------
%ファイルをロード-----------------------------------------------------------
% --- Executes on button press in push_load.
function push_load_Callback(hObject, eventdata, handles)
%迷路情報、セッション情報をロード
fnc_LoadMazeData(handles, 'uiopen', hObject);
%--------------------------------------------------------------------------


%セッションスタート---------------------------------------------------------
%セッション開始をコールする
%正常開始の識別コード'd'を受け取った場合、エディットモードを終了してセッションを開始する
%--------------------------------------------------------------------------
function push_sessionstart_Callback(hObject, eventdata, handles)
%シリアルポート
s = handles.serial;
if strcmp(s.Status, 'closed')
    set(handles.edit1, 'String', 'シリアルポートを開いてください');
    return;
end
%Arduinoにデータを要請する（識別コード「D」）
SerialCommunication(handles, 'D');
%データの返答を待つ
pause(0.1);
%シリアルポートをGUI間で移行するために外部セーブ
save('serial', 's');
%正しくセッションを開始できた場合、GUIを切り替える
if s.BytesAvailable
    %セッション開始を通知するシリアル通信
    if fread(s, 1) == 'd'
        %次回以降起動時に呼び出すために、実行するセッションのデータを保存
        fnc_SaveMazeData(handles,'save');
        %close処理でシリアルポートを落とさないように
        handles.sessionstarted = true;
        guidata(hObject, handles);
        %現在のfigureを閉じる
        close(handles.figure1);
        %セッションGUIを開始する
        Sessions;
    end
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% プッシュボタン１３「迷路のデータを適用」
% Arduinoにセンサ２アウトプット/ミル２アウトプットのデータを送信する
%--------------------------------------------------------------------------
function push_sendmazedata_Callback(hObject, eventdata, handles)
%ポートが開いてなければ通信しない
s = handles.serial;
if strcmp(s.Status, 'closed')
    set(handles.edit1, 'String', 'シリアルポートを開いてください');
    return;
end
%通信中のアナウンス
set(handles.edit1, 'String', 'データ通信中');
%センサ２アウトプットのデータをシリアル通信
SerialCommunication(handles, 'B');
%ミル２アウトプットのデータをシリアル通信
SerialCommunication(handles, 'G');
%セッションの設定をシリアル通信
pause(0.1);
SerialCommunication(handles, 'C');
%正解ルート・分岐
if handles.userfile==1 && handles.sessionGUI{4}>0
    %セッションデータの処理が終わるまで待つ
    pause(0.2);
    load('cells.mat', 'c');
    handles.userdata = c;
    %セッション回数だけ通信
    for i=1:handles.sessionGUI{4}
        SerialCommunication(handles, 'H', i);
        pause(0.1);
    end
end
%オルタネイション
if handles.userfile==2
    %セッションデータの処理が終わるまで待つ
    pause(0.2);
    load('alternation.mat', 'c');
    handles.userdata = c;
    SerialCommunication(handles, 'J');
end
%実装したデータを表示する（Arduinoの通信は介さない）
%テキスト表示用文字列を生成
s = s2o_Display(handles.s2oGUI, 0);
t = mill_Display(handles.millGUI);
%文字列を表示
set(handles.text7, 'String', [s t]);
%sessionGUIから文字列を生成
s = session_Display(handles,'◆実装◆');
%文字列を表示
set(handles.text16, 'String', s);
%通信終了のアナウンス
set(handles.edit1, 'String', '通信終了');
%--------------------------------------------------------------------------















%--------------------------------------------------------------------------▲
%セッションのユーザ編集をhandlesに格納する
%--------------------------------------------------------------------------
%セッションの初期状態
%handles.sessionGUI{1}(1-8)
%--------------------------------------------------------------------------
% --- Executes on selection change in popup_initialgate1.
function popup_initialgate1_Callback(hObject, eventdata, handles)
%GUIの変化を受け取る
str = get(hObject, 'String');
val = get(hObject, 'value');
%データを格納しセーブ
s = 0;
switch str{val}
    case 'ゲート１　OPEN'
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
%GUIの変化を受け取る
str = get(hObject, 'String');
val = get(hObject, 'value');
%データを格納しセーブ
s = 0;
switch str{val}
    case 'ゲート２　OPEN'
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
%GUIの変化を受け取る
str = get(hObject, 'String');
val = get(hObject, 'value');
%データを格納しセーブ
s = 0;
switch str{val}
    case 'ゲート３　OPEN'
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
%GUIの変化を受け取る
str = get(hObject, 'String');
val = get(hObject, 'value');
%データを格納しセーブ
s = 0;
switch str{val}
    case 'ゲート４　OPEN'
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
%GUIの変化を受け取る
str = get(hObject, 'String');
val = get(hObject, 'value');
%データを格納しセーブ
s = 0;
switch str{val}
    case 'ゲート５　OPEN'
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
%GUIの変化を受け取る
str = get(hObject, 'String');
val = get(hObject, 'value');
%データを格納しセーブ
s = 0;
switch str{val}
    case 'ゲート６　OPEN'
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
%GUIの変化を受け取る
str = get(hObject, 'String');
val = get(hObject, 'value');
%データを格納しセーブ
s = 0;
switch str{val}
    case 'ゲート７　OPEN'
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
%GUIの変化を受け取る
str = get(hObject, 'String');
val = get(hObject, 'value');
%データを格納しセーブ
s = 0;
switch str{val}
    case 'ゲート８　OPEN'
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
%--------------------------------------------------------------------------▲▲
%セッションのスタートを決めるセンサ
%handles.sessionGUI{2}(1-4)
%--------------------------------------------------------------------------
% --- Executes on selection change in popupmenu29.
function popupmenu29_Callback(hObject, eventdata, handles)
%GUIの変化を受け取る
str = get(hObject, 'String');
val = get(hObject, 'value');
%データを格納しセーブ
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
%GUIの変化を受け取る
str = get(hObject, 'String');
val = get(hObject, 'value');
%データを格納しセーブ
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
%GUIの変化を受け取る
str = get(hObject, 'String');
val = get(hObject, 'value');
%データを格納しセーブ
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
%GUIの変化を受け取る
str = get(hObject, 'String');
val = get(hObject, 'value');
%データを格納しセーブ
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
%--------------------------------------------------------------------------▲▲
%セッションのゴールを決めるセンサ
%handles.sessionGUI{3}(1-4)
%--------------------------------------------------------------------------
% --- Executes on selection change in popupmenu33.
function popupmenu33_Callback(hObject, eventdata, handles)
%GUIの変化を受け取る
str = get(hObject, 'String');
val = get(hObject, 'value');
%データを格納しセーブ
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
%GUIの変化を受け取る
str = get(hObject, 'String');
val = get(hObject, 'value');
%データを格納しセーブ
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
%GUIの変化を受け取る
str = get(hObject, 'String');
val = get(hObject, 'value');
%データを格納しセーブ
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
%GUIの変化を受け取る
str = get(hObject, 'String');
val = get(hObject, 'value');
%データを格納しセーブ
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
%どのセンサをスタートまたはゴールにするかを変数にする
function s = SorG_Snsr(str,val)
switch str{val}
    case '（未使用）'
        s=0;
    case 'センサ１'
        s=1;
    case 'センサ２'
        s=2;
    case 'センサ３'
        s=3;        
    case 'センサ４'
        s=4;        
    case 'センサ５'
        s=5;        
    case 'センサ６'
        s=6;        
    case 'センサ７'
        s=7;        
    case 'センサ８'
        s=8;
    case 'ミルセンサ１'
        s=9;
    case 'ミルセンサ２'
        s=10;
end
%--------------------------------------------------------------------------▲▲
%セッション回数を格納する
%--------------------------------------------------------------------------
function edit5_Callback(hObject, eventdata, handles)
i = str2double( get(hObject, 'String') );
%不正なセッション回数をはじく
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
% 外部ファイルの利用状況
%--------------------------------------------------------------------------
function popupmenu38_Callback(hObject, eventdata, handles)
%GUIの変化を受け取る
str = get(hObject, 'String');
val = get(hObject, 'value');
switch str{val}
    case '（未使用）'
        s=0;
    case '分岐・正解ルート'
        s=1;
    case 'オルタネイション'
        s=2;
end
handles.userfile = s;
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function popupmenu38_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------▲▲


%--------------------------------------------------------------------------▲▲
%「セッション内容適用」
function push_editsession_Callback(hObject, eventdata, handles)
%sessionGUIから文字列を生成
s = session_Display(handles,'◆セッションの内容◆');
%文字列を表示
set(handles.text16, 'String', s);
%--------------------------------------------------------------------------▲▲
%セッションの内容を文字列にして返す関数
%--------------------------------------------------------------------------
function s = session_Display(handles, str)
cl = handles.sessionGUI;
%最終的に表示する文字列
s = [str char(10)];
s = [s '初期状態：' char(10)];
%初期状態
for i = 1:8
    s = [s '　Gate' num2str(i) ' '];
    sb= 'CLOSE';
    if cl{1}(i) == 1
        sb= 'OPEN';
    end
    s = [s sb char(10)];
end
%スタートセンサ
%cl{2}(1-4)について０なら未使用、１～８センサ、９～１０ミルセンサ
s = [s 'スタートセンサ：' char(10)];
for i = 1:4
    j = cl{2}(i);
    if 0 < j
        if j < 9
            s = [s '　Sensor' char(j+48) char(10)]; 
        elseif j < 11
            s = [s '　MillSensor' char(j+40) char(10)];
        end
    end
end
%ゴールセンサ
%cl{3}(1-4)について０なら未使用、１～８センサ、９～１０ミルセンサ
s = [s 'ゴールセンサ：' char(10)];
for i = 1:4
    j = cl{3}(i);
    if 0 < j
        if j < 9
            s = [s '　Sensor' char(j+48) char(10)];
        elseif j < 11
            s = [s '　MillSensor' char(j+40) char(10)];
        end
    end
end
%セッション数
s = [s 'セッション数：' char(10) '　' num2str(cl{4}) char(10)]; 
%ユーザファイルの利用状況
switch handles.userfile
    case 0
        str = '利用しない';
    case 1
        str = '分岐・正解ルート';
    case 2
        str = 'オルタネイション';
end
s = [s 'ユーザ定義ファイル：' char(10) '　' str];
%--------------------------------------------------------------------------


%作動テストなどで利用■■
% --- Executes on button press in push_test.
function push_test_Callback(hObject, eventdata, handles)
s=handles.serial;
% fwrite(s, 'Z');
% pause(1);
%シリアル通信を数値で表示
t = '';
while s.BytesAvailable
    t = [t num2str(fread(s,1)+0) ', '];
end
set(handles.text7, 'String', t);



%GUI終了時の処理-----------------------------------------------------------
%Guideのメニューバーからエディタに書き出せる
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%ポートが開いていれば閉じる
s = handles.serial;
%セッション開始の場合はシリアルを閉じない
if ~handles.sessionstarted
    if strcmp(s.Status, 'open')
        fclose(s);
    end
    delete(s);
    clear('s');
end
%迷路概観ウィンドウが開いていれば削除する
c = findobj('Name', 'MazeAppearance');
if ~isempty(c)
    close('MazeAppearance');
end
%オブジェクトを削除する
delete(hObject);
%--------------------------------------------------------------------------


%迷路編集GUIを呼び出す
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
%テキスト表示用文字列を生成（迷路データ）
s = s2o_Display(handles.s2oGUI, 1);
t = []; %mill_Display(handles.millGUI);
%文字列を表示
set(handles.text7, 'String', [s t]);
%テキスト表示用文字列を作成（セッションデータ）
s = session_Display(handles, '◆セッションの内容◆');
%文字列を表示
set(handles.text16, 'String', s);
%ロードを適用
guidata(hObject, handles);


%--------------------------------------------------------------------------
% センサの複数回動作の許可
% GUIでの変更をhandlesに格納
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
% 遅延動作の遅延時間を設定
%--------------------------------------------------------------------------
function edit_delaytime1_Callback(hObject, ~, handles)
i = str2double( get(hObject, 'String') );
%不正な動作時間をはじく
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
%不正な動作時間をはじく
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
%不正な動作時間をはじく
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
%不正な動作時間をはじく
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
