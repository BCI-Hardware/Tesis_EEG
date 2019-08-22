%%% V=25 mm/seg
%%% cuadricula 200 ms / division grande
%%%             40 ms / division chica


function varargout = ecg(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ecg_OpeningFcn, ...
                   'gui_OutputFcn',  @ecg_OutputFcn, ...
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


% --- Executes just before ecg is made visible.
function ecg_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

% global var;
% var.x=0;
% var.tmr=timer('TimerFcn',{@TimerCallback,hObject,handles},'Period',0.1,'ExecutionMode','FixedRate');

global s;
delete(instrfindall)
%s = serial('/dev/tty.wchusbserial1410','BaudRate',38400);
%4800, 9600, 19200, 57600, 115200
%s = serial('/dev/ttyUSB0','BaudRate',115200);
s = serial('COM6');
fopen(s)
pause(6)
global escalado;
escalado=2.42/6/((2^23)-1); %cuanto representa 1 muestra en tension
global c1 c2;
c1=zeros(1,2000);
c2=zeros(1,2000);
global L1;
L1=100*escalado;
global L2;
L2=100*escalado;
global X1;
X1=1000;
global X2;
X2=2000;
global save;
save=0;
global fid;
fid=fopen('output.txt','wb');
global archivo_c1;
archivo_c1=strcat('./Datos/', datestr(now,'yyyy-mm-dd_HH-MM-SS'),'_c1.txt');
global archivo_c2;
archivo_c2=strcat('./Datos/', datestr(now,'yyyy-mm-dd_HH-MM-SS'),'_c2.txt');

% UIWAIT makes ecg wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ecg_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
global s;
global running;
global leer_muestras;
global escalado;
global c1 c2;
global L1 L2;
global X1 X2;
global fid;
global archivo_c1;
global archivo_c2;
global save;
running=1;
leer_muestras=1;

flp=lowpass();
fhp=highpass();
b=[1.0, -2.0, 1.0];
a=[1.0, -1.9749029659, 0.9765156251];
fwrite(s,'1');
pause(1)
while running
    if (leer_muestras==1)
        c = fread(s, 200, 'int16');
        if(length(c)<200)
            delete(instrfindall)
            break;
        end
        cint=c;
%%
        %Busca el inicio de la trama
%         while c!= inicio_trama
%             c = fread(s, 3, 'int8');
%         end
% 
%         c = fread(s, largo_trama, 'int16');

        %num_canal=c(1);
        %cant_muestras=c(2);
        %muestras=c(3:end-1);
        %chksum=c(end);
        %     
        %     
        %     %cint=c(1:2:end)+256*c(2:2:end); %Pasa a enteros de 16 bits los 2 bytes de cada canal que se reciben
        % if (c(1)==1)
        %     c1aux=(c(1:2:end)+256*c(2:2:end))';
        % elseif (c(1)==2)
        %     c2aux=(c(1:2:end)+256*c(2:2:end))';

        %if(save==1)
        %    fwrite(fid,cint,'int16');
        %end
%%
        c1aux=cint(1:2:end)'*escalado;
        c2aux=cint(2:2:end)'*escalado;
        c1=[c1(101:end) c1aux];
        c2=[c2(101:end) c2aux];
        c1hp=filter(b,a,c1);
        c2hp=filter(b,a,c2);
        wo=50/(250/2);
        bw=wo/5;
        [bn,an]=iirnotch(wo,bw);
        c1filt=smooth(c1hp,5);%  filter(fhp,c1notch);
        c2filt=smooth(c2hp,5);%filter(fhp,c2notch);
        if(save==1)
            dlmwrite(archivo_c1, c1filt(end-50:end), '-append');
            dlmwrite(archivo_c2, c2filt(end-50:end), '-append');
        end
    %     c1filt=filter(fhp,c1filt);
    %     c2filt=filter(fhp,c2filt);
    end
    axes(handles.C1)
    plot(c1filt,'linewidth',2)
    set(gca,'xtick',1000:250:2000,'xticklabel',0:4)
    ylim([-L1 L1])
    xlim([X1 X2])
    axes(handles.C2)
    plot(c2filt,'linewidth',2)
    ylim([-L2 L2])
    xlim([X1 X2])
    axes(handles.V1)
    [y0 x0]=find(min(c1filt(end-250:end).^2+c2filt(end-250:end).^2))
    plot(c2filt(end-250:end),-c1filt(end-250:end))
    xlim([-L2 L2])
    ylim([-L1 L1])
    pause(0.000001)
end


% --- Executes on button press in Stop.
function Stop_Callback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global running;
running=0;



% --- Executes on button press in upc1.
function upc1_Callback(hObject, eventdata, handles)
% hObject    handle to upc1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global L1
L1=0.9*L1;


% --- Executes on button press in downc1.
function downc1_Callback(hObject, eventdata, handles)
% hObject    handle to downc1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global L1
L1=1.1*L1;


% --- Executes on button press in up2.
function up2_Callback(hObject, eventdata, handles)
% hObject    handle to up2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global L2
L2=0.9*L2;


% --- Executes on button press in down2.
function down2_Callback(hObject, eventdata, handles)
% hObject    handle to down2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global L2
L2=1.1*L2;


% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global save;
global var;
status=get(handles.Save,'String');
if status=='Save'
    save=1;
    start(var.tmr);
    set(handles.Save,'String','Stop')
else
    save=0;
    stop(var.tmr);
    set(handles.Save,'String','Save')
end
    
function TimerCallback(obj,event,hObject,handles)
global var;
set(handles.text1,'String',var.x);
var.x=var.x+1;


% --- Executes on button press in Atras.
function Atras_Callback(hObject, eventdata, handles)
% hObject    handle to Atras (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)global running;
global leer_muestras;
global running;
global X1 X2;
leer_muestras=0;
running=1;
X1=X1-100;
X2=X2-100;
if (X2<900)
    set(handles.Atras,'Enable','off')
end
if (X2<2000)
    set(handles.Adelante,'Enable','on')
end

% --- Executes on button press in Adelante.
function Adelante_Callback(hObject, eventdata, handles)
% hObject    handle to Adelante (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global leer_muestras;
global running;
global X1 X2;
leer_muestras=0;
running=1;
X1=X1+100;
X2=X2+100;
if (X2>900)
    set(handles.Atras,'Enable','on')
end
if (X2>2000)
    set(handles.Adelante,'Enable','off')
end

