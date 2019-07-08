function varargout = MazeAppearance(varargin)
% MAZEAPPEARANCE MATLAB code for MazeAppearance.fig
%      MAZEAPPEARANCE, by itself, creates a new MAZEAPPEARANCE or raises the existing
%      singleton*.
%
%      H = MAZEAPPEARANCE returns the handle to a new MAZEAPPEARANCE or the handle to
%      the existing singleton*.
%
%      MAZEAPPEARANCE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAZEAPPEARANCE.M with the given input arguments.
%
%      MAZEAPPEARANCE('Property','Value',...) creates a new MAZEAPPEARANCE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MazeAppearance_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MazeAppearance_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MazeAppearance

% Last Modified by GUIDE v2.5 16-Aug-2018 16:17:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MazeAppearance_OpeningFcn, ...
                   'gui_OutputFcn',  @MazeAppearance_OutputFcn, ...
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


% --- Executes just before MazeAppearance is made visible.
function MazeAppearance_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MazeAppearance (see VARARGIN)

% Choose default command line output for MazeAppearance
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MazeAppearance wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MazeAppearance_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_root.
function button_root_Callback(hObject, eventdata, handles)
% hObject    handle to button_root (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of button_root


% --- Executes on button press in button_erazor.
function button_erazor_Callback(hObject, eventdata, handles)
% hObject    handle to button_erazor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of button_erazor


% --- Executes when selected cell(s) is changed in data_table.
function data_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to data_table (see GCBO)
% eventdata  structure with the following field (see UITABLE)
%  Indices:  row and column indices of the cell(s) currently selected
% handles    structure with handles and user data (see GUIDATA)

% ---- Customized as follows ----
% Obtain 1st column of current selection indices from event data;
% this contains row indices. We don't need column indices.
%行データを獲得
rowID = eventdata.Indices(:,1);
rowID = unique(rowID);
%列データを獲得
colID = eventdata.Indices(:,2);
colID = unique(colID);
%テーブルを獲得
cl = get(handles.data_table, 'Data');
%迷路を編集
cl = EditMaze(rowID, colID, cl, handles);
%迷路を表示
set(handles.data_table, 'Data', cl);


%迷路を編集
function cl = EditMaze(rowID, colID, cl, handles)
%消しゴム
if get(handles.button_erazor, 'Value')
    %複数幅の塗りを禁止
    a = size(rowID);
    a = a(1,1);
    b = size(colID);
    b = b(1,1);
    if (a > 1) && (b > 1)
        return;
    end
    %セルを初期化
    for row = min(rowID) : max(rowID)
        for col = min(colID) : max(colID)
            cl(row, col) = {''};
        end
    end
    return;
end
%通路ライン塗り
% if get(handles.button_root, 'Value')
%     %複数行塗りを禁止
%     a = size(rowID);
%     a = a(1,1);
%     b = size(colID);
%     b = b(1,1);
%     if (a > 1) && (b > 1)
%         return;
%     end
%     str = '';
%     for row = min(rowID) : max(rowID)
%         for col = min(colID) : max(colID)
%             cl(row,col )...
%                 = {['<html><pre><font bgcolor=#000000 face="MS Sans Serif" size="2.5">',...
%                 [str,'                                  '], '</font></pre></html>']};
%         end
%     end
% end
%縦横を取得
if get(handles.button_horaizontal, 'Value')
    ishoraizontal = 1;
else
    ishoraizontal = 0;
end
if get(handles.button_vertical, 'Value')
    isvertical = 1;
else
    isvertical = 0;
end
%以下の処理ではテーブル上での選択は１点のみ許可
a = size(rowID);
a = a(1,1);
b = size(colID);
b = b(1,1);
if (a ~= 1) || (b ~= 1)
    return;
end
%座標を取得
row = min(rowID);
col = min(colID);
%エサ箱
if get(handles.button_feeder, 'Value')
    %上書き禁止
    c = cl(row, col);
    if ~isempty(c{1})
        return;
    end
    %ポップアップメニュの情報を獲得
    str = get(handles.popup_feeder, 'String');
    val = get(handles.popup_feeder, 'Value');
    str = str(val);
    %番号を取り出す
    n = str{1}(7);
    %文字列
    str = ['F' n];
    %着色
    cl(row, col )...
        = {['<html><pre><font bgcolor=#D2B48C face="MS Sans Serif" size="2.5">',...
        [str,'                                  '], '</font></pre></html>']};
    return;
end
%以下の処理ではテーブルの外周のクリックは禁止
A = size(cl);
rowMax=A(1);
colMax=A(2);
if row==1 || row==rowMax || col==1 || col==colMax
    return;
end
%通路
if get(handles.button_root, 'Value')
    %上書き禁止
    for i=-1:1
        if ishoraizontal
            c = cl(row, col+i);
            if ~isempty(c{1})
                return;
            end
        elseif isvertical
            c = cl(row+i, col);
            if ~isempty(c{1})
                return;
            end
        end
    end
    %文字と色
    str = '';
    A = {['<html><pre><font bgcolor=#000000 face="MS Sans Serif" size="2.5">',...
        [str,'                                  '], '</font></pre></html>']};
    %テーブルを更新
    for i=-1:1
        if ishoraizontal
            cl(row, col+i) = A;
        elseif isvertical
            cl(row+i, col) = A;
        end
    end
    return;
end
%トレッドミル
if get(handles.button_treadmill, 'Value')
    %上書き禁止
    for i=-1:1
        if ishoraizontal
            c = cl(row, col+i);
            if ~isempty(c{1})
                return;
            end
        elseif isvertical
            c = cl(row+i, col);
            if ~isempty(c{1})
                return;
            end
        end
    end
    %ポップアップメニュの情報を獲得
    str = get(handles.popup_treadmill, 'String');
    val = get(handles.popup_treadmill, 'Value');
    str = str(val);
    %番号を取り出す
    n = str{1}(10);
    %文字と色
    str = ['M' n];
    A = {['<html><pre><font bgcolor=#98FB98 face="MS Sans Serif" size="2.5">',...
        [str,'                                  '], '</font></pre></html>']};
    %テーブルを更新
    for i=-1:1
        if ishoraizontal
            cl(row, col+i) = A;
        elseif isvertical
            cl(row+i, col) = A;
        end
    end
    return;
end
%ゲート
if get(handles.button_gate, 'Value')
    %上書き禁止
    for i=-1:2:1
        if ishoraizontal
            c = cl(row, col+i);
            if ~isempty(c{1})
                return;
            end
        elseif isvertical
            c = cl(row+i, col);
            if ~isempty(c{1})
                return;
            end
        end
    end
    %ポップアップメニュの情報を獲得
    str = get(handles.popup_gate, 'String');
    val = get(handles.popup_gate, 'Value');
    str = str(val);
    %番号を取り出す
    n = str{1}(5);
    %文字と色
    str = ['G' n];
    A = {['<html><pre><font bgcolor=#cbcbcb face="MS Sans Serif" size="2.5">',...
        [str,'                                  '], '</font></pre></html>']};
    %テーブルを更新
    for i=-1:2:1
        if ishoraizontal
            cl(row, col+i) = A;
        elseif isvertical
            cl(row+i, col) = A;
        end
    end
    return;
end
%センサ
if get(handles.button_sensor, 'Value')
    %上書き禁止
    for i=-1:2:1
        if ishoraizontal
            c = cl(row, col+i);
            if ~isempty(c{1})
                return;
            end
        elseif isvertical
            c = cl(row+i, col);
            if ~isempty(c{1})
                return;
            end
        end
    end
    %ポップアップメニュの情報を獲得
    str = get(handles.popup_sensor, 'String');
    val = get(handles.popup_sensor, 'Value');
    str = str(val);
    %番号を取り出す
    n = str{1}(7);
    %文字と色
    str = ['S' n];
    A = {['<html><pre><font bgcolor=#FFC0CB face="MS Sans Serif" size="2.5">',...
        [str,'                                  '], '</font></pre></html>']};
    %テーブルを更新
    for i=-1:2:1
        if ishoraizontal
            cl(row, col+i) = A;
        elseif isvertical
            cl(row+i, col) = A;
        end
    end
    return;
end
%ミルセンサ
if get(handles.button_millsensor, 'Value')
    %上書き禁止
    for i=-1:2:1
        if ishoraizontal
            c = cl(row, col+i);
            if ~isempty(c{1})
                return;
            end
        elseif isvertical
            c = cl(row+i, col);
            if ~isempty(c{1})
                return;
            end
        end
    end
    %ポップアップメニュの情報を獲得
    str = get(handles.popup_millsensor, 'String');
    val = get(handles.popup_millsensor, 'Value');
    str = str(val);
    %番号を取り出す
    n = str{1}(10);
    %文字と色
    str = ['M' n];
    A = {['<html><pre><font bgcolor=#FFC0CB face="MS Sans Serif" size="2.5">',...
        [str,'                                  '], '</font></pre></html>']};
    %テーブルを更新
    for i=-1:2:1
        if ishoraizontal
            cl(row, col+i) = A;
        elseif isvertical
            cl(row+i, col) = A;
        end
    end
    return;
end


% --- Executes on selection change in popup_sensor.
function popup_sensor_Callback(hObject, eventdata, handles)
% hObject    handle to popup_sensor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_sensor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_sensor


% --- Executes during object creation, after setting all properties.
function popup_sensor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_sensor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_gate.
function popup_gate_Callback(hObject, eventdata, handles)
% hObject    handle to popup_gate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_gate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_gate


% --- Executes during object creation, after setting all properties.
function popup_gate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_gate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_treadmill.
function popup_treadmill_Callback(hObject, eventdata, handles)
% hObject    handle to popup_treadmill (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_treadmill contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_treadmill


% --- Executes during object creation, after setting all properties.
function popup_treadmill_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_treadmill (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_feeder.
function popup_feeder_Callback(hObject, eventdata, handles)
% hObject    handle to popup_feeder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_feeder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_feeder


% --- Executes during object creation, after setting all properties.
function popup_feeder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_feeder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function popup_millsensor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_feeder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_millsensor.
function popup_millsensor_Callback(hObject, eventdata, handles)
% hObject    handle to popup_millsensor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_millsensor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_millsensor


% --- Executes on button press in push_save.
function push_save_Callback(hObject, eventdata, handles)
% hObject    handle to push_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%テーブルを獲得
cl = get(handles.data_table, 'Data');
save('MazeAppearance.mat', 'cl');
%uisave({cl}, 'NameOfMazeAppearance');


% --- Executes on button press in push_load.
function push_load_Callback(hObject, eventdata, handles)
% hObject    handle to push_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('MazeAppearance.mat', 'cl');
%uiopen(*.mat);
set(handles.data_table, 'Data', cl);


%全消去
% --- Executes on button press in push_clear.
function push_clear_Callback(hObject, eventdata, handles)
% hObject    handle to push_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cl = get(handles.data_table, 'Data');
c = size(cl);
rowMax=c(1);
colMax=c(2);
for i=1:rowMax
    for j=1:colMax
        cl(i,j)={''};
    end
end
set(handles.data_table, 'Data', cl);       


%上へ一行シフト
% --- Executes on button press in push_up.
function push_up_Callback(hObject, eventdata, handles)
% hObject    handle to push_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cl = get(handles.data_table, 'Data');
c=size(cl);
colMax=c(2);
c=cl(1,:);
cl(1,:)=[];
for i=1:colMax
    c(1,i)={''};
end
cl= vertcat(cl,c);
set(handles.data_table, 'Data', cl);


%下へ一行シフト
% --- Executes on button press in push_down.
function push_down_Callback(hObject, eventdata, handles)
% hObject    handle to push_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cl = get(handles.data_table, 'Data');
c=size(cl);
rowMax=c(1);
colMax=c(2);
c=cl(1,:);
cl(rowMax,:)=[];
for i=1:colMax
    c(1,i)={''};
end
cl= vertcat(c,cl);
set(handles.data_table, 'Data', cl);


%右へ一行シフト
% --- Executes on button press in push_right.
function push_right_Callback(hObject, eventdata, handles)
% hObject    handle to push_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cl = get(handles.data_table, 'Data');
c=size(cl);
rowMax=c(1);
colMax=c(2);
c=cl(:,1);
cl(:,colMax)=[];
for i=1:rowMax
    c(i,1)={''};
end
cl= horzcat(c,cl);
set(handles.data_table, 'Data', cl);


%左へ一行シフト
% --- Executes on button press in push_left.
function push_left_Callback(hObject, eventdata, handles)
% hObject    handle to push_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cl = get(handles.data_table, 'Data');
c=size(cl);
rowMax=c(1);
c=cl(:,1);
cl(:,1)=[];
for i=1:rowMax
    c(i,1)={''};
end
cl= horzcat(cl,c);
set(handles.data_table, 'Data', cl);


% --- Executes when entered data in editable cell(s) in data_table.
function data_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to data_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
