function varargout = cipproject(varargin)


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cipproject_OpeningFcn, ...
                   'gui_OutputFcn',  @cipproject_OutputFcn, ...
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


% --- Executes just before cipproject is made visible.
function cipproject_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cipproject (see VARARGIN)
handles.output = hObject;
N = str2num(get(handles.imageSize,'string'));
handles.W = [];
handles.hPatternsDisplay = [];
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = cipproject_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in reset.
function reset_Callback(hObject, ~, handles)
% cleans all data and enables the change of the number of neurons used
    for n=1 : length(handles.hPatternsDisplay)
        delete(handles.hPatternsDisplay(n));
    end
    handles.hPatternsDisplay = [];
    set(handles.imageSize,'enable','on');
    handles.W = [];
    guidata(hObject, handles);


function imageSize_Callback(hObject, ~, ~)
% hObject    handle to imageSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    num = get(hObject,'string');
    n = str2num(num);
    if isempty(n)
        num = '32';
        set(hObject,'string',num);
    end
    if n > 32
        warndlg('It is strongly recomended NOT to work with networks with more then 32^2 neurons!','!! Warning !!')
    end


% --- Executes during object creation, after setting all properties.
function imageSize_CreateFcn(hObject, ~, ~)
% hObject    handle to imageSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


  
function train_Callback(hObject, ~, handles)
    
    Npattern = length(handles.hPatternsDisplay);
    if Npattern > 9 
        msgbox('more then 10 paterns isn''t supported!','error');
        return
    end    
    im = getimage(handles.neurons1);
    N = get(handles.imageSize,'string');
    disp(N);
    N = str2num(N);
    disp(N);
    W = handles.W;  
   % disp(W);
    avg = mean(im(:)); 
    disp(avg);
    if ~isempty(W)
        %W = W +( kron(im,im))/(N^2);
        W = W + (kron(im-avg,im-avg))/(N^2)/avg/(1-avg);
    else
         %W = kron(im,im)/(N^2);
        W = (kron(im-avg,im-avg))/(N^2)/avg/(1-avg);
    end
    ind = 1:N^2;
    f = find(mod(ind,N+1)==1);
    W(ind(f),ind(f)) = 0;
    handles.W = W;
    
    xStart = 0.01;
    xEnd = 0.99;
    height = 0.65;
    width = 0.09;
    xLength = xEnd-xStart;
    xStep = xLength/10;
    offset = 4-ceil(Npattern/2);
    offset = max(offset,0);
    y = 0.1;
    
    if Npattern > 0
        for n=1 : Npattern
            x = xStart+(n+offset-1)*xStep;
            h = handles.hPatternsDisplay(n);
            set(h,'units','normalized');
            set(h,'position',[x y width height]);
        end
        x = xStart+(n+offset)*xStep;
        h = axes('units','normalized','position',[x y width height]);
        handles.hPatternsDisplay(n+1) = h;
        imagesc(im,'Parent',h);
    else
        x = xStart+(offset)*xStep;
        h = axes('units','normalized','position',[x y width height]);
        handles.hPatternsDisplay = h;
    end
    
    imagesc(im,'Parent',h);
    set(h, 'YTick',[],'XTick',[],'XTickMode','manual','Parent',handles.learnedPaterns);
    guidata(hObject,handles);

   

function im = fixImage(im,N)
%    if isrgb(im)
	if length( size(im) ) == 3
        im = rgb2gray(im);
    end
    im = double(im);
    m = min(im(:));
    M = max(im(:));
    im = (im-m)/(M-m);  %normelizing the image
    im = imresize(im,[N N],'bilinear');
    %im = (im > 0.5)*2-1;    %changing image values to -1 & 1
    im = (im > 0.5);    %changing image values to 0 & 1

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(~, ~, handles)
global fName;
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fName, dirName] = uigetfile('*.bmp;*.tif;*.jpg;*.tiff;*.png');
    if fName
        set(handles.imageSize,'enable','off');
        cd(dirName);
        im = imread(fName);
        N = str2num(get(handles.imageSize,'string'));
        N=N*1.5;
        im = fixImage(im,N);
       imagesc(im,'Parent',handles.neurons1);
        colormap('gray'); 
    end
    
function edit3_Callback(~, ~, ~)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, ~, ~)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(~, ~, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fName;
str1='F:\cip-project\database\';
str2=(get(handles.edit3, 'string'));
str3=strcat(str1,str2);
if exist(str3,'file')
str4='\sign1';
samples=1;
halfaddr=strcat(str3,str4);
fulladdr1=strcat(halfaddr,'.png');
fulladdr2=strcat(halfaddr,'.jpg');
fulladdr3=strcat(halfaddr,'.tif');
fulladdr4=strcat(halfaddr,'.tiff');
fulladdr5=strcat(halfaddr,'.bmp');
if exist (fulladdr1,'file')
    fulladdr=fulladdr1; 
    elseif exist (fulladdr2,'file')   
    fulladdr=fulladdr2;
    elseif exist (fulladdr3,'file')   
    fulladdr=fulladdr3;
    elseif exist (fulladdr4,'file')   
    fulladdr=fulladdr4;
    elseif exist (fulladdr5,'file')   
    fulladdr=fulladdr5;
else 
    samples=0;
end
if samples==1    
imread(fulladdr);
disp(fName);
fName1=strcat('F:\input\',fName);
disp(fName1);
oq=imread(fName1);
odprz=imresize(oq,[300 300]);
imwrite(odprz,fName1);
sw=imread(fulladdr);
stprz=imresize(sw,[300 300]);
imwrite(stprz,fulladdr);
pic1=imread(fName1);
disp(pic1);
pic2 = imread(fulladdr);
disp(pic2);
[~,~,z] = size(pic1);
if(z==1)
     
else
    pic1 = rgb2gray(pic1);
end
[~,~,z] = size(pic2);
if(z==1)
    
else
    pic2 = rgb2gray(pic2);
end
 
edge_det_pic1 =edge(pic1,'canny');
 
edge_det_pic2 = edge(pic2,'canny');
 
matched_data = 0;
matched_data1 = 0;
white_points = 0;
black_points = 0;
x=0;
y=0;
l=0;
m=0;
 
for a = 1:1:256
    for b = 1:1:256
        if(edge_det_pic1(a,b)==1)
            white_points = white_points+1;
        else
            black_points = black_points+1;
        end
    end
end
 
for i = 1:1:256
    for j = 1:1:256
        if(edge_det_pic1(i,j)==1)&&(edge_det_pic2(i,j)==1)
            matched_data = matched_data+1;
            else
          matched_data1 = matched_data1+1;
        end
    end
end
total_data = white_points;
total_matched_percentage = (matched_data/total_data)*100;
 
om=min(odprz);
sm=min(stprz);
 
if om==255
    total_matched_percentage=0;
elseif sm==255
    total_matched_percentage=0;
end
 
disp(total_matched_percentage)
result1=total_matched_percentage;
disp(result1)
disp('process1 completed')
end 

str1='F:\cip-project\database\';
str2=(get(handles.edit3, 'string'));
str3=strcat(str1,str2);
str4='\sign2';
halfaddr=strcat(str3,str4);
fulladdr1=strcat(halfaddr,'.png');
fulladdr2=strcat(halfaddr,'.jpg');
fulladdr3=strcat(halfaddr,'.tif');
fulladdr4=strcat(halfaddr,'.tiff');
fulladdr5=strcat(halfaddr,'.bmp');
if exist (fulladdr1,'file')
    fulladdr=fulladdr1; 
    elseif exist (fulladdr2,'file')   
    fulladdr=fulladdr2;
    elseif exist (fulladdr3,'file')   
    fulladdr=fulladdr3;
    elseif exist (fulladdr4,'file')   
    fulladdr=fulladdr4;
    elseif exist (fulladdr5,'file')   
    fulladdr=fulladdr5;
else 
    samples=0;
end

if samples==1
imread(fulladdr);
fName1=strcat('F:\input\',fName);
disp(fName1);
oq=imread(fName1);
odprz=imresize(oq,[300 300]);
imwrite(odprz,fName1);
sw=imread(fulladdr);
stprz=imresize(sw,[300 300]);
imwrite(stprz,fulladdr);
pic1=imread(fName1);
disp(pic1);
pic2 = imread(fulladdr);
disp(pic2);
[~,~,z] = size(pic1);
if(z==1)
     
else
    pic1 = rgb2gray(pic1);
end
[~,~,z] = size(pic2);
if(z==1)
    
else
    pic2 = rgb2gray(pic2);
end
 
edge_det_pic1 =edge(pic1,'canny');
 
edge_det_pic2 = edge(pic2,'canny');
 
matched_data = 0;
matched_data1 = 0;
white_points = 0;
black_points = 0;
x=0;
y=0;
l=0;
m=0;
 
for a = 1:1:256
    for b = 1:1:256
        if(edge_det_pic1(a,b)==1)
            white_points = white_points+1;
        else
            black_points = black_points+1;
        end
    end
end
 
for i = 1:1:256
    for j = 1:1:256
        if(edge_det_pic1(i,j)==1)&&(edge_det_pic2(i,j)==1)
            matched_data = matched_data+1;
            else
          matched_data1 = matched_data1+1;
        end
    end
end
total_data = white_points;
total_matched_percentage = (matched_data/total_data)*100;
 
om=min(odprz);
sm=min(stprz);
 
if om==255
    total_matched_percentage=0;
elseif sm==255
    total_matched_percentage=0;
end
 
disp(total_matched_percentage)
result2=total_matched_percentage;
disp(result1)
disp(result2)
disp('process completed')
end


str1='F:\cip-project\database\';
str2=(get(handles.edit3, 'string'));
str3=strcat(str1,str2);
str4='\sign3';
samples=1;
halfaddr=strcat(str3,str4);
fulladdr1=strcat(halfaddr,'.png');
fulladdr2=strcat(halfaddr,'.jpg');
fulladdr3=strcat(halfaddr,'.tif');
fulladdr4=strcat(halfaddr,'.tiff');
fulladdr5=strcat(halfaddr,'.bmp');
if exist (fulladdr1,'file')
    fulladdr=fulladdr1; 
    elseif exist (fulladdr2,'file')   
    fulladdr=fulladdr2;
    elseif exist (fulladdr3,'file')   
    fulladdr=fulladdr3;
    elseif exist (fulladdr4,'file')   
    fulladdr=fulladdr4;
    elseif exist (fulladdr5,'file')   
    fulladdr=fulladdr5;
else
    samples=0;
end
if samples==1
imread(fulladdr);
fName1=strcat('F:\input\',fName);
disp(fName1);
oq=imread(fName1);
odprz=imresize(oq,[300 300]);
imwrite(odprz,fName1);
sw=imread(fulladdr);
stprz=imresize(sw,[300 300]);
imwrite(stprz,fulladdr);
pic1=imread(fName1);
disp(pic1);
pic2 = imread(fulladdr);
disp(pic2);
[~,~,z] = size(pic1);
if(z==1)
     
else
    pic1 = rgb2gray(pic1);
end
[~,~,z] = size(pic2);
if(z==1)
    
else
    pic2 = rgb2gray(pic2);
end
 
edge_det_pic1 =edge(pic1,'canny');
 
edge_det_pic2 = edge(pic2,'canny');
 
matched_data = 0;
matched_data1 = 0;
white_points = 0;
black_points = 0;
x=0;
y=0;
l=0;
m=0;

for a = 1:1:256
    for b = 1:1:256
        if(edge_det_pic1(a,b)==1)
            white_points = white_points+1;
        else
            black_points = black_points+1;
        end
    end
end
 
for i = 1:1:256
    for j = 1:1:256
        if(edge_det_pic1(i,j)==1)&&(edge_det_pic2(i,j)==1)
            matched_data = matched_data+1;
            else
          matched_data1 = matched_data1+1;
        end
    end
end
total_data = white_points;
total_matched_percentage = (matched_data/total_data)*100;
 
om=min(odprz);
sm=min(stprz);
 
if om==255
    total_matched_percentage=0;
elseif sm==255
    total_matched_percentage=0;
end
 
disp(total_matched_percentage)
result3=total_matched_percentage;
disp(result1)
disp(result2)
disp(result3)
disp('process completed')
finalresult=(result1+result2+result3)/3;
disp(finalresult)
disp(num2str(finalresult))
msgbox(strcat('percentage matched:',num2str(finalresult)),'%matched')
else
    msgbox('no sign in db','error')
end
else
    msgbox('check ur id','error')
end


% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(~, ~, ~)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton2
