function varargout = filtro(varargin)
% FILTRO MATLAB code for filtro.fig
%      FILTRO, by itself, creates a new FILTRO or raises the existing
%      singleton*.
%
%      H = FILTRO returns the handle to a new FILTRO or the handle to
%      the existing singleton*.
%
%      FILTRO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILTRO.M with the given input arguments.
%
%      FILTRO('Property','Value',...) creates a new FILTRO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before filtro_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to filtro_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help filtro

% Last Modified by GUIDE v2.5 29-Nov-2019 10:57:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @filtro_OpeningFcn, ...
                   'gui_OutputFcn',  @filtro_OutputFcn, ...
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


% --- Executes just before filtro is made visible.
function filtro_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to filtro (see VARARGIN)

% Choose default command line output for filtro
handles.output = hObject;

% configura��o do plot do filtro
x_min1 = 1e-6;
x_max1 = 1e6;
y_min1 = 0;
y_max1 = 1.1;
% estado inicial do plot do filtro
axes(handles.plot_filtro);
xlabel('Frequency (Hz)');
ylabel('Q(j\omega) (abs)');
set(handles.plot_filtro, 'XLim', [x_min1, x_max1], 'YLim', [y_min1, y_max1]);
grid on;

% defini��o valores inciais
set(handles.edit_q_init, 'value', 1);
set(handles.edit_q_step, 'value', 0.05);
set(handles.edit_f_init, 'value', -6);
set(handles.edit_f_fin, 'value', 6);
set(handles.edit_f_step, 'value', 100);
set(handles.edit_a_filtro, 'value', 0);

% estado inicial
set(handles.button_ws, 'enable', 'off');

% para salvar no workspace
data = struct('freq', [], 'q_value', [], 'ordem', 0, 'corte', 0);
setappdata(handles.fig_filtro, 'FilterData', data);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = filtro_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_filtro.
function button_filtro_Callback(hObject, eventdata, handles)
% hObject    handle to button_filtro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

GUI1        = findobj(allchild(groot), 'flat', 'Tag', 'fig_main');
handlesGUI1 = guidata(GUI1);
PlantData = getappdata(handlesGUI1.fig_main, 'PlantData');

% Hint: get(hObject,'Value') returns toggle state of button_filtro
if (~get(hObject, 'value'))
    % nome no bot�o
    set(hObject, 'string','Run');
    set(handles.button_ws, 'enable', 'off');
    
    % permitir modifica��es j� que 'run' ainda n�o foi apertado
    set(handles.edit_q_step, 'enable', 'on');
    set(handles.edit_f_step, 'enable', 'on');
    set(handles.edit_a_filtro, 'enable', 'on');
    set(handles.edit_q_init, 'enable', 'on');
    set(handles.edit_f_init, 'enable', 'on');
    set(handles.edit_f_fin, 'enable', 'on');
    set(handles.listbox_filtro, 'enable', 'on');   
    
    set(handles.edit_ordem, 'string', '-');
    set(handles.edit_corte, 'string', '-');
    
    % limpar plot
    lim_x = get(handles.plot_filtro, 'XLim');
    lim_y = get(handles.plot_filtro, 'YLim');
    
    axes(handles.plot_filtro);
    semilogx(0, 0);
     
    check_type = get(handles.listbox_filtro, 'value');
    if (check_type == 1)
        eixo_y = 'Q(j\omega) (abs)';
        set(handles.plot_filtro, 'XLim', [lim_x(1), lim_x(2)], 'YLim', [0, lim_y(2)]);
    elseif (check_type == 2)
        eixo_y = 'Q(j\omega) (dB)';
        set(handles.plot_filtro, 'XLim', [lim_x(1), lim_x(2)], 'YLim', [mag2db(0.01), mag2db(lim_y(2))]);
    end
    
    xlabel('Frequency (Hz)');
    ylabel(eixo_y);
    grid on;
    
else
    
    % validar valores escolhidos
    q_init = str2num(get(handles.edit_q_init, 'string'));
    [q_initRows, q_initCols] = size(q_init);
    if (isempty(q_init) || q_initRows ~= 1 || q_initCols ~= 1)
        errordlg('"Initial Value" of Q must be a number','Invalid Input','modal');
        return 
    end
    
    q_step = str2num(get(handles.edit_q_step, 'string'));
    [q_stepRows, q_stepCols] = size(q_step);
    if (isempty(q_step) || q_stepRows ~= 1 || q_stepCols ~= 1)
        errordlg('Q "Step" must be a number','Invalid Input','modal');
        return 
    end
    
    if q_step >= q_init
        errordlg('"Initial Value" of Q must be greater than its "Step"','Invalid Input','modal');
        return
    end 
    
    f_init = str2num(get(handles.edit_f_init, 'string'));
    [f_initRows, f_initCols] = size(f_init);
    if (isempty(f_init) || f_initRows ~= 1 || f_initCols ~= 1)
        errordlg('"Initial Value" of Frequency must be a number','Invalid Input','modal');
        return 
    end
    
    f_fin = str2num(get(handles.edit_f_fin, 'string'));
    [f_finRows, f_finCols] = size(f_fin);
    if (isempty(f_fin) || f_finRows ~= 1 || f_finCols ~= 1)
        errordlg('"Final Value" of Frequency must be a number','Invalid Input','modal');
        return 
    end
    
    if f_init >= f_fin
        errordlg('"Final Value" of Frequency must be greater than its "Initial Value"','Invalid Input','modal');
        return
    end  
    
    f_step = str2num(get(handles.edit_f_step, 'string'));
    [f_stepRows, f_stepCols] = size(f_step);
    if (isempty(f_step) || f_stepRows ~= 1 || f_stepCols ~= 1 || f_step <= 0)
        errordlg('The "Number of Points" for the Frequency must be a positive number','Invalid Input','modal');
        return 
    end

    a = str2num(get(handles.edit_a_filtro, 'string'));
    [aRows, aCols] = size(a);
    if (isempty(a) || aRows ~= 1 || aCols ~= 1)
        errordlg('"a value" must be a number','Invalid Input','modal');
        return 
    end
            
    % nome no bot�o
    set(hObject, 'string','Stop');
    set(handles.button_ws, 'enable', 'on');
    
    % n�o permitir modifica��es j� que 'run' foi apertado
    set(handles.edit_q_step, 'enable', 'off');
    set(handles.edit_f_step, 'enable', 'off');
    set(handles.edit_a_filtro, 'enable', 'off');
    set(handles.edit_q_init, 'enable', 'off');
    set(handles.edit_f_init, 'enable', 'off');
    set(handles.edit_f_fin, 'enable', 'off');
    set(handles.listbox_filtro, 'enable', 'off');
    
    % algoritmo filtro fir
    freq = logspace(f_init, f_fin, f_step); % f_step � o n�mero de pontos
    algo_filtro(handles, q_init, q_step, freq, a);
end
 

% --- Executes on button press in button_ws.
function button_ws_Callback(hObject, eventdata, handles)
% hObject    handle to button_ws (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

FilterData = getappdata(handles.fig_filtro, 'FilterData');
% freq = FilterData.freq;
% q = FilterData.q_value;
check_type = get(handles.listbox_filtro, 'value');
if (check_type == 1)
    aux_q = FilterData.q_value;
elseif (check_type == 2)
    aux_q = mag2db(FilterData.q_value);
end

data = struct('frequency', FilterData.freq, 'q_value', aux_q, 'order', FilterData.ordem, 'cutoff_frequency', FilterData.corte);
% https://www.mathworks.com/help/matlab/ref/save.html
% https://www.mathworks.com/help/matlab/ref/assignin.html
assignin('base', 'FilterData', data);
msgbox({'Operation Completed!';'Data saved as a struct called "FilterData".'},'Success');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                         FUN��ES CRIADAS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function algo_filtro(handles, init_q, step_q, fr, a_value)
    q_init = init_q;
    q_step = step_q;
    freq = fr;        
    a = real(a_value);
    
    % pegar dados de outros callbacks
    GUI1        = findobj(allchild(groot), 'flat', 'Tag', 'fig_main');
    handlesGUI1 = guidata(GUI1);
    
    PlantData = getappdata(handlesGUI1.fig_main, 'PlantData');
    ganho = PlantData.ganho;
    num = PlantData.num;
    den = PlantData.den;
    ts = PlantData.ts;
    
    ft = ganho*tf(num, den, ts);    
    [re, im] = nyquist(ft, 2*pi*freq);    
    
    % algoritmo
    len = length(freq);
    q = q_init*ones(1, len); 
    flag = 1;
    
    mag_corte1 = 0;
    mag_corte2 = 0;
    f_c1 = 10;
    f_c2 = 0;
    
    for i = 1:1:len
        aux = abs(q(i))^2;
        cond = inequacao(a, aux, re(i), im(i));
        while(~cond)
            q(i:end) = q(i) - q_step;
            aux = abs(q(i))^2;
            cond = inequacao(a, aux, re(i), im(i));
        end
        % encontrar coef angular (decaimento) pelas redondezas da frequ�ncia de corte
        if (flag == 0 && mag2db(q(i)) < -3)
            mag_corte1 = mag2db(q(i-1));
            mag_corte2 = mag2db(q(i));
            f_c1 = freq(i-1);
            f_c2 = freq(i);
            flag = 1;
        end
        % se entrar na condi��o anterior com i=1 vai dar problema no i-1
        if (i==1)
            flag=0; 
        end
    end
    
    % calculo da frequ�ncia de corte
    coef_angular = (mag_corte1-mag_corte2)/log10(f_c1/f_c2);
    if coef_angular == 0
        errordlg('You must increase the frequency range.','Invalid Input','modal');
        return    
    else
        freq_corte = 10^(log10(f_c1) - (mag_corte1+3)/coef_angular);
        filtro_ordem = ceil(coef_angular/-20);
        if mod(filtro_ordem, 2) ~= 0
            filtro_ordem = filtro_ordem + 1;
        end
                
        FilterData = getappdata(handles.fig_filtro, 'FilterData');
        FilterData.freq = freq;
        FilterData.q_value = q;
        FilterData.ordem = filtro_ordem;
        FilterData.corte = freq_corte;
        setappdata(handles.fig_filtro, 'FilterData', FilterData);
        
        set(handles.edit_ordem, 'string', num2str(filtro_ordem));
        set(handles.edit_corte, 'string', num2str(round(freq_corte ,2)));
      
        check_type = get(handles.listbox_filtro, 'value');
        lim_ymin = 0.9*abs(q(end));
        lim_ymax = 1.1*abs(q(1));

        axes(handles.plot_filtro);
        if (check_type == 1)
            % https://www.mathworks.com/help/matlab/ref/semilogx.html
            semilogx(freq, q, 'b');
            eixo_y = 'Q(j\omega) (abs)';
            set(handles.plot_filtro, 'XLim', [freq(1), freq(end)], 'YLim', [0, lim_ymax]);
        elseif (check_type == 2)
            % https://www.mathworks.com/help/signal/ref/mag2db.html
            semilogx(freq, mag2db(q), 'b');
            eixo_y = 'Q(j\omega) (dB)';
            set(handles.plot_filtro, 'XLim', [freq(1), freq(end)], 'YLim', [mag2db(lim_ymin), mag2db(lim_ymax)]);
        end

        xlabel('Frequency (Hz)');
        ylabel(eixo_y);
        grid on;
    end    
    
   
