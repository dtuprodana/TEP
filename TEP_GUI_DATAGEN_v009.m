 function TEP_GUI_DATAGEN_v009
 % 2020-07-28 / v009
% -- Simulink object variables introduced
% -- some code clean-up

 % 2020-07-13 / v008
% -- GUI to Ricker Closed-Loop Simulation
% -- Quick generation of large data sets
 
clc;                                               
close all; % Close open windows

% Simulink object variables                 % -- Choose model here! --
%SYSTEMOBJ = 'MultiLoop_mode1';             %     (1) Ricker          
SYSTEMOBJ = 'tesysbasecontrol_2';           %     (2) Simple

RT1OBJ    = strcat(SYSTEMOBJ,'/rt1');
TfRTOBJ   = strcat(SYSTEMOBJ,'/Timer for Real-Time');
DISTOBJ   = strcat(SYSTEMOBJ,'/Disturbances');
TECODEOBJ = strcat(SYSTEMOBJ,'/TE Plant/TE Code');

load_system(SYSTEMOBJ); % Open Simulink model

%% Initalise settings

% Vectors with start and end times for disturbances
M.IDVT0 = zeros(1,28);
M.IDVT1 = zeros(1,28);
M.dist = zeros(1,28);


% String with simulation summary
M.string = '';

% Array with setup information
M.setups = 0;

% Default is that realtime data export is off
set_param(RT1OBJ,'commented','on');


%% Table variable names

% Names and numbers of manipulated variables
mvnames = {'Time','Stream2Valve','Stream3Valve','Stream1Valve','Stream4Valve',...
    'CompressorRecycleValve','Stream9Valve','Stream10Valve',...
    'Stream11Valve','SteamFlowValve','ReactorcCoolingWaterValve',...
    'CondenserCoolingWaterValve','AgitatorSpeedValve'};
mvnumbers = cell(1,13);
for i = 1:13
    if i == 1
        mvnumbers{i} = 'Time';
    else
        mvnumbers{i} = sprintf('XMV%d',i-1);
    end
end

% Names and numbers of controlled variables
cvnames = {'Time','Stream1','Stream2','Stream3','Stream4','Stream8',...
    'Stream6','ReactorPressure','ReactorLevel','ReactorTemperature',...
    'Stream9','SeparatorTemperature','SeparatorLevel',...
    'SeparatorPressure','Stream10','StripperLevel','StripperPressure',...
    'Stream11','StripperTemperature','SteamFlow','CompressorWork',...
    'ReactorCoolingWaterOutletTemperature',...
    'CondenserCoolingWaterOutletTemperature','Stream6A','Stream6B',...
    'Stream6C','Stream6D','Stream6E','Stream6F','Stream9A',...
    'Stream9B','Stream9C','Stream9D','Stream9E','Stream9F',...
    'Stream9G','Stream9H','Stream11D','Stream11E','Stream11F',...
    'Stream11G','Stream11H'};
cvnumbers = cell(1,42);
for i = 1:42
    if i == 1
        cvnumbers{i} = 'Time';
    else
        cvnumbers{i} = sprintf('XMEAS%d',i-1);
    end
end

% Numbers of disturbances
distnames = cell(1,29);
for i = 1:29
    if i == 1
        distnames{i} = 'Time';
    else
        distnames{i} = sprintf('IDV%d',i-1);
    end
end

% Names and numbers of controlled variables divided in categories
safetynames = {'Time','ReactorPressure','ReactorLevel',...
    'ReactorTemperature','SeparatorLevel','StripperLevel'};
safetynumbers = {'Time','XMEAS7','XMEAS8','XMEAS9','XMEAS12','XMEAS15'};

econnames = {'Time','Stream9','Stream9A',...
    'Stream9B','Stream9C','Stream9D','Stream9E','Stream9F',...
    'Stream9G','Stream9H','Stream11','Stream11D',...
    'Stream11E','Stream11F','Stream11G','Stream11H',...
    'SteamFlow','CompressorWork'};
econnumbers = {'Time','XMEAS10','XMEAS29','XMEAS30','XMEAS31','XMEAS32',...
    'XMEAS33','XMEAS34','XMEAS35','XMEAS36','XMEAS17',...
    'XMEAS37','XMEAS38','XMEAS39','XMEAS40','XMEAS41','XMEAS19','XMEAS20'};

% Setup of saved file table structures
cvssafety = [7,8,9,12,15];
cvsecon = [10,29,30,31,32,33,34,35,36,17,37,38,39,40,41,19,20];
simnames = {'ManipulatedVariables','AllProcessVariables',...
    'Disturbances','SafetyVariables','EconomicVariables'}; 
allnames = ['Time','BLANK1',mvnames(2:end),'BLANK2',...
    cvnames(2:end),'BLANK3',distnames(2:end)];
allnumbers = ['Time','BLANK1',mvnumbers(2:end),'BLANK2',...
    cvnumbers(2:end),'BLANK3',distnames(2:end)];


% Disturbance names
idvs = {'-- none --', 'IDV1 - A/C feed ratio stream 4 - step',...
    'IDV2 - B composition stream 4 - step',...
    'IDV3 - D feed temperature - step',...
    'IDV4 - Reactor cooling water temperature - step',...
    'IDV5 - Condenser cooling water temperature - random',...
    'IDV6 - A feed loss - Step',...
    'IDV7 - C feed reduced availability - step',...
    'IDV8 - A,B,C feed composition - random',...
    'IDV9 - D feed temperature - random',...
    'IDV10 - C feed temperature - random',...
    'IDV11 - Reactor cooling water temperature - random',...
    'IDV12 - Condenser cooling water temperature - random',...
    'IDV13 - Reaction kinetics - slow drift',...
    'IDV14 - Reactor cooling water valve - sticking',...
    'IDV15 - Condenser cooling water valve - sticking',...
    'IDV16 - coefficient of the steam supply of the heat exchanger of the stripper',...
    'IDV17 - reactor coefficient of heat transfer - unknown',...
    'IDV18 - condenser coefficient of heat transfer - unknown',...
    'IDV19 - unknown',...
    'IDV20 - unknown',...
    'IDV21 - A feed temperature - random',...
    'IDV22 - E feed temperature - random',...
    'IDV23 - A feed pressure - random',...
    'IDV24 - D feed pressure - random',...
    'IDV25 - E feed pressure - random',...
    'IDV26 - A and C feed pressure - random',...
    'IDV27 - reactor cooling water pressure - random',...
    'IDV28 - condenser cooling water pressure - random',...
    'Random disturbance'};
input = {'-- none --', 'XMV1','XMV2','XMV3','XMV4','XMV5','XMV6','XMV7',...
    'XMV8','XMV9','XMV10','XMV11','XMV12'};
inputvalues = [63.053 53.980 24.644 61.302 22.210 40.064 38.100 46.534 47.446 41.106 18.114 50 ];
IDVS = string(idvs);
INPUT = string(input);
M.InNew = inputvalues;

%% Start Figure

% Start window
M.start = figure(...
        'Visible','on',...
        'Name','Welcome',...
        'MenuBar','none',...
        'NumberTitle','off',...
        'Position',[500,500,250,200],...
        'resize','off'...
        );
    
% Set up simulation in GUI pushbutton 
manual = uicontrol('Style','pushbutton',...
             'String','Choose simulation set-up',...
             'Units','Normalized',...   
             'Position',[0,0,1,0.5],...
             'Interruptible','off',...
             'parent',M.start,...
             'Callback',@manual_Callback);

% Input setup from file pushbutton
file = uicontrol('Style','pushbutton',...
             'String','Enter file',...
             'Units','Normalized',...   
             'Position',[0,0.5,1,0.5],...
             'Interruptible','off',...
             'parent',M.start,...
             'Callback',@getfile_Callback);

%% File summary window

% Window 
M.filesummary = figure(...
        'Visible','off',...
        'Name','Summary',...
        'MenuBar','none',...
        'NumberTitle','off',...
        'Position',[500,500,350,350],...
        'resize','on'...
        );
    
% Textbox
filesummarywindow = uicontrol('Style','edit',...
    'String','',...
    'Max',100000,...
    'Position',[0,0,250,350],...
    'HorizontalAlignment','Left',...
    'TooltipString','Editing this text will not change the simulation set up',...
    'parent',M.filesummary);

% Start sim pushbutton
startfilesim = uicontrol('Style','pushbutton',...
             'String','Start simulation',...
             'Position',[260,200,80,100],...
             'Interruptible','off',...
             'parent',M.filesummary,...
             'Callback',@startfilesim_Callback);
         
% Return to start window pushbutton 
filegoback = uicontrol('Style','pushbutton',...
             'String','New file',...
             'Position',[260,50,80,100],...
             'Interruptible','off',...
             'parent',M.filesummary,...
             'Callback',@filegoback_Callback);

%% Simulation set up window

% Window 
M.f = figure(...
        'Visible','off',...
        'Name','Control panel',...
        'MenuBar','none',...
        'NumberTitle','off',...
        'Position',[500,500,500,500],...
        'resize','off'...
        );

% Disturbances panel    
distparam = uipanel(...
    'Position',[0 1/2 1 1/2],...
    'Units','Normalized',...
    'Title','Disturbance parameters',...
    'parent',M.f...
    );

% Select IDV panel
dist1 = uipanel(...
    'Position',[6/300 0.5 188/300 0.5],...
    'Units','Normalized',...
    'parent',distparam,...
    'Title','IDV'...
    );

% Enter start time panel
dist2 = uipanel(...
    'Position',[6/300 0 91/300 0.5],...
    'Units','Normalized',...
    'parent',distparam,...
    'Title','Start time'...
    );

% Enter end time panel
dist3 = uipanel(...
    'Position',[103/300 0 91/300 0.5],...
    'Units','Normalized',...
    'parent',distparam,...
    'Title','End time'...
    );

% Select IDV pop-up
dist11 = uicontrol(...
    'Style','popup',...
    'String', idvs,...
    'Units','Normalized',...
    'Position',[0.02 0.375 0.96 0.25],...
    'parent',dist1,...
    'TooltipString','Select a disturbance'...
    );

% Select start time editbox
dist21 = uicontrol(...
    'Style','edit',...
    'Units','Normalized',...
    'Position',[0.25 0.3 0.5 0.40],...
    'parent',dist2,...
    'String','5',...
    'TooltipString','Select when the disturbance should start'...
    );

% Select end time editbox
dist31 = uicontrol(...
    'Style','edit',...
    'Units','Normalized',...
    'Position',[0.25 0.3 0.5 0.40],...
    'parent',dist3,...
    'String','20',...
    'TooltipString','Select when the disturbance should end'...
    );

% Add IDV set up
addbutton = uicontrol('Style','pushbutton',...
             'String','Add disturbance',...
             'Units','Normalized',...   
             'Position',[2/3,0.8,8/25,0.2],...
             'Interruptible','off',...
             'parent',distparam,...
             'Callback',@addbutton_Callback);
     
% Summary of setup
distsum = uicontrol('Style','text',...
    'String',sprintf('Disturbances added:'),...
    'HorizontalAlignment','Left',...
    'Units','Normalized',...
    'Position',[2/3,0,8/25,0.75],...
    'parent',distparam);

setupsum = uicontrol('Style','text',...
    'String',sprintf('Setups added:'),...
    'HorizontalAlignment','Left',...
    'Units','Normalized',...
    'Position',[2/3,0,8/25,0.07],...
    'parent',distparam);

% Simulation parameters panel
simparam = uipanel(...
    'Position',[0 0 1 1/2],...
    'Units','Normalized',...
    'Title','Simulation parameters',...
    'parent',M.f...
    );

% Type of simulation button group
bgsimtype = uibuttongroup(...
    'Position',[0.02 0.5 0.92/3 0.5],...
    'Units','Normalized',...
    'Title','Type of simulation',...
    'parent',simparam,...
    'SelectionChangedFcn',@bgsimtypeselection...
    );

% Fast simulation button
fast = uicontrol('Style','Radio',...
             'String','High speed simulation',...
             'Position',[5 50 130 20],...
             'parent',bgsimtype,...
             'TooltipString','Simulation is carried out as quickly as possible, and the results can be found in a .mat file when the simulation is done.'...
             );

% Realtime button
realtime = uicontrol(...
             'Style','Radio',...
             'String','Real-time simulation',...
             'Position',[5 20 130 20],...
             'parent',bgsimtype,...
             'TooltipString','Simulation is carried out at 3 seconds per hour of simulation and the results are plotted continuously'...
             );

% Number of simulations panel
sims = uipanel(...
    'Position',[0.02 0 0.92/3 0.5],...
    'Units','Normalized',...
    'parent',simparam,...
    'Title','Number of simulations'...
    );

% Number of simulations editbox
sims1 = uicontrol(...
    'Style','edit',...
    'Units','Normalized',...
    'Position',[0.25 0.3 0.5 0.40],...
    'string','1',...
    'parent',sims,...
    'TooltipString','This number specifies how many times the simulation is run with the chosen set up'...
    );

% Filename panel
filename = uipanel(...
    'Position',[0.04+0.92/3 0 0.92/3 0.5],...
    'Units','Normalized',...
    'parent',simparam,...
    'Title','Enter filename'...
    );

% Filename editbox
filename1 = uicontrol(...
    'Style','edit',...
    'Units','Normalized',...
    'Position',[0.25 0.3 0.5 0.40],...
    'string','simulation',...
    'parent',filename,...
    'TooltipString','This specifies the name of the file with the simulation results'...
    );

% Simulation time panel
time = uipanel(...
    'Position',[0.04+0.92/3 0.5 0.92/3 0.5],...
    'Units','Normalized',...
    'parent',simparam,...
    'Title','Simulation time (hours)'...
    );

% Simulation time editbox
time1 = uicontrol(...
    'Style','edit',...
    'Units','Normalized',...
    'Position',[0.25 0.3 0.5 0.40],...
    'string','20',...
    'parent',time,...
    'TooltipString', 'This specifies the number of simulation hours'...
    );

% Simulation seed panel
seed = uipanel(...
    'Position',[0.06+2*0.92/3 0.5 0.92/3 0.5],...
    'Units','Normalized',...
    'parent',simparam,...
    'Title','Seed'...
    );

% Simulation seed editbox
seed1 = uicontrol(...
    'Style','edit',...
    'Units','Normalized',...
    'Position',[0.25 0.3 0.5 0.40],...
    'string','r',...
    'parent',seed,...
    'TooltipString', 'This specifies the seed for the random number generator in the simulator. Entering r gives a random seed.'...
    );

% Continue to summary pushbutton
Addsetup = uicontrol('Style','pushbutton',...
             'String','Add setup',...
             'Units','Normalized',...
             'Position',[0.06+2*0.92/3,3/40+0.8/3,0.92/3,0.4/3],...
             'Interruptible','off',...
             'parent',simparam,...
             'Callback',@addsetup_Callback);
         
% Continue to summary pushbutton
Continue = uicontrol('Style','pushbutton',...
             'String','Continue',...
             'Units','Normalized',...
             'Position',[0.06+2*0.92/3,2/40+0.4/3,0.92/3,0.4/3],...
             'Interruptible','off',...
             'parent',simparam,...
             'Callback',@continue_Callback);
         
% Go back to start pushbutton
goback = uicontrol('Style','pushbutton',...
             'String','Go back',...
             'Units','Normalized',...
             'Position',[0.06+2*0.92/3,1/40,0.92/3,0.4/3],...
             'Interruptible','off',...
             'parent',simparam,...
             'Callback',@goback_Callback);

%% Manual set up summary window

% Window
M.manualsummary = figure(...
        'Visible','off',...
        'Name','Summary',...
        'MenuBar','none',...
        'NumberTitle','off',...
        'Position',[500,500,350,350],...
        'resize','on'...
        );
    
% Summary textbox
manualsummarywindow = uicontrol('Style','edit',...
    'String','',...
    'Max',100000,...
    'Position',[0,0,250,350],...
    'HorizontalAlignment','Left',...
    'TooltipString','Editing this text will not change the simulation set up',...
    'parent',M.manualsummary);

% Start simulation pushbutton
startfilesim = uicontrol('Style','pushbutton',...
             'String','Start simulation',...
             'Position',[260,200,80,100],...
             'Interruptible','off',...
             'parent',M.manualsummary,...
             'Callback',@startmanualsim_Callback);

% Choose another setup
filegoback = uicontrol('Style','pushbutton',...
             'String','New setup',...
             'Position',[260,50,80,100],...
             'Interruptible','off',...
             'parent',M.manualsummary,...
             'Callback',@manualgoback_Callback);


%% Waitbar 
w = waitbar(0,'','visible','off',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
setappdata(w,'canceling',0)       

%% Plots Figure

% Window
fPlot = figure(...
    'Visible','off',...
    'Name','Figures',...
    'MenuBar','none',...
    'NumberTitle','off',...
    'Position',[500,120,1024,1000/sqrt(2)]...
    );

% Tab group
plottabs = uitabgroup(fPlot,...
    'Units','Normalized',...
    'Position',[0 0 1 1]...
    );

% for loop for tabs
for k = 1:2
    tab(k)=uitab(plottabs,'Title', sprintf('Tab_%i', k));
    axes('parent',tab(k))
    % First tab - Manipulated variables
    if k == 1

% Define the data
        d = {'D Feed (Stream 2)',               'XMV 1', 63.053, 0, 100, true;...
            'E Feed (Stream 3)',                'XMV 2', 53.980, 0, 100, true;...
            'A Feed (Stream 1)',                'XMV 3', 24.644, 0, 100, true;...
            'C+A Feed (Stream 4)',              'XMV 4', 61.302, 0, 100, true;...
            'Compr. Recycle Valve',             'XMV 5', 22.210, 0, 100, true;...
            'Purge Valve (Stream 6)',           'XMV 6', 40.064, 0, 100, true;...
            'Flash Liq. Outflow (Stream 10)',   'XMV 7', 38.100, 0, 100, true;...
            'Stripper Liq. Product (Stream 11)','XMV 8', 46.534, 0, 100, true;...
            'Stripper Steam Valve',             'XMV 9', 47.446, 0, 100, true;...
            'Reactor Cooling Water Flow',       'XMV 10', 41.106, 0, 100, true;...
            'Condenser Cooling Water Flow',     'XMV 11', 18.114, 0, 100, true;...
            'Agitator Speed',                   'XMV 12', 50.000, 0, 100, true;};
        
% Create Subfigures
        np = length(d(:,1));
        nr = floor(sqrt(np));
        nc = ceil(np/nr);

        tout = 1;
        yout = zeros(1,82);
        
% Input data for each graph
        for i = 1:12 %(nc*nr)
            subplot(nr,nc,i);
            f.UserData.h_fig{i} = plot(tout, yout(:,i));
            title(d(i,1),...
                'FontSize', 10);
            ylim([0 100]);
            set(f.UserData.h_fig{i}, 'XDataSource', 'tout', 'YDataSource', strcat('yout(:,',num2str(i),')'));

        end % for
        tab(k).Title = 'Manipulated Variables';
        
% second tab - safety variables
    elseif k == 2
   
        nr_out = 2;
        nc_out = 3;

        tout = 1;
        yout = zeros(1,41);

% Data set - {XMEAS number, name}
        fCrit_titles = {{7, 'XMEAS7: R pressure'}; ...
                        {8, 'XMEAS8: R level'}; ...
                        {9, 'XMEAS9: R temp.'}; ...
                        {12, 'XMEAS12: Sep. level'}; ...
                        {15, 'XMEAS15: Stripper level'} };

% Input data to graphs
        for i = 1:5 %(nc*nr)
            subplot(nr_out,nc_out,i);
            f.UserData.h_figCrit{i} = plot(tout, yout(:,fCrit_titles{i}{1}+12));
            title(fCrit_titles{i}{2},...
                'FontSize', 10);
            set(f.UserData.h_figCrit{i}, 'XDataSource', 'tout', 'YDataSource', strcat('yout(:,',num2str(fCrit_titles{i}{1}+12),')'));
        end % for
        tab(k).Title = 'Safety Variables';
    end
end

%% Create Timer for auto-update

% Timer
h_timer = timer(...
    'ExecutionMode', 'fixedRate', ...         % Run timer repeatedly.
    'Period', 0.5, ...                        % Initial period is 1 sec.
    'TimerFcn', {@update_display});             % Specify callback function.


%% Index Log for limit Check

% Index Log
ii = 1;
ii_new = 1;

flag = zeros(41);

%% Callback functions

% Excecutes when file has been chosen
function getfile_Callback(source,eventdata) 
    % Gets information of file, saved in structure M. If no file is chosen, the
    % start window reappears
    [file,path] = uigetfile('*.*','All Files');
    if isequal(file,0)
        return
    end
    
    % Reads file into table
    M.setup = readtable(fullfile(path,file),'Format','%f%f%f%s%f%f%s');    
    
    % Reads table into cell array saved in structure M
    M.setup = table2cell(M.setup);
    
    % Reads dimensions of cell array
    [s1,s2] = size(M.setup(:,1));

    % Creates empty string for summary
    summary = '';

    % Loop for each setup
    for i = 1:s1
        % Number of runs 
        r = cell2mat(M.setup(i,2));
        % Simulation time
        t = cell2mat(M.setup(i,3));
        % Which IDV is on
        M.distcheck = cell2mat(M.setup(i,4));
        % If random IDV is chosen, IDV is found at random
        if strcmp(M.distcheck,'r') || strcmp(M.distcheck,'R')
            M.d{i} = randi([1,28]);
        else
           M.d{i} = cell2mat(M.setup(i,4));
           M.d{i} = str2double(M.d{i}) ;
        end
        % The start and end time of the disturbance. If d = 0 there is no
        % disturbance
        if 0<M.d{i} && M.d{i}<29
            dt0 = cell2mat(M.setup(i,5));
            dt1 = cell2mat(M.setup(i,6));
        end
        % Seed is found. If random seed is desired, a seed between 0 and 10000 is
        % generated
        M.seedcheck = cell2mat(M.setup(i,7));
        if strcmp(M.seedcheck,'r') || strcmp(M.seedcheck,'R')
            M.seed{i} = randi([0,10000]) ;
        else
            M.seed{i} = cell2mat(M.setup(i,7));
            M.seed{i} = str2double( M.seed{i}) ;
        end
        % Summary of the simulations that will be made is created
        if strcmp(summary,'')
            summary = strcat(summary,sprintf('Setup %d: \n %d runs of %d hours duration.',i,r,t));
        else
            summary = strcat(summary,sprintf('\n\nSetup %d: \n %d runs of %d hours duration.',i,r,t));
        end
        if M.d{i}<1 || M.d{i}>28
            summary = strcat(summary,sprintf('\n No disturbances are on.'));
        else
            summary = strcat(summary,sprintf('\n IDV %d is on from hours %d to %d. \n',M.d{i},dt0,dt1));
        end
        summary = strcat(summary,sprintf('\n Seed is %d to %d.',M.seed{i},M.seed{i}+r-1));
    end

    % Summary is saved to structure M and to enter file summary textbox
    M.summary = summary;
    filesummarywindow.String = summary;

    % Enter file summary window is opened and start window is closed
    M.start.Visible = 'Off';
    M.filesummary.Visible = 'On';
end

% Excecuted if enter another file is chosen from enter file summary window
function filegoback_Callback(source,eventdata) 
    % Enter file summary window is closed and start window is opened
    M.start.Visible = 'On';
    M.filesummary.Visible = 'Off';
end

% Excecuted if choose another setup is chosen from manual setup summary window
function manual_Callback(source,eventdata) 
    % Manual setup summary window is closed and manual setup window is opened
    M.start.Visible = 'Off';
    M.f.Visible = 'On';
end

% Excecuted if start simulation is chosen from enter file summary window
function startfilesim_Callback(source,eventdata) 
    % Enter file summary window is closed
    M.filesummary.Visible = 'Off';

    % size of cell array
    [s1,s2] = size(M.setup(:,1));

    % Total amount of simulation runs
    tr = sum(cell2mat(M.setup(:,2)));

    % Sets the simulation speed as fast as possible
    set_param(TfRTOBJ,'Parameters','0.00000001');

    % Loop for number of setups
    for i = 1:s1
        % Resetting disturbance vectors
        M.IDVT0 = zeros(1,28);
        M.IDVT1 = zeros(1,28);
        
        % Turning on waitbar 
        w.Visible = 'on';
        if i == 1
            waitbar(0,w,sprintf('Simulations completed: %d of %d',0,tr));
        end
        
        % Number of runs
        r = cell2mat(M.setup(i,2));
        
        % Length of simulation entered into simulink
        t = num2str(cell2mat(M.setup(i,3)));
        set_param(SYSTEMOBJ,'StopTime',t);
        
        % Setting up disturbance vector and entering it into simulink
        if M.d{i} ~=0
            dt0 = cell2mat(M.setup(i,5));
            dt1 = cell2mat(M.setup(i,6));
            M.IDVT0(M.d{i}) = dt0;
            M.IDVT1(M.d{i}) = dt1;
        end
        M.IDVT0 = strcat('[',num2str(M.IDVT0),']');
        M.IDVT1 = strcat('[',num2str(M.IDVT1),']');
        set_param(DISTOBJ,'IDVT0',M.IDVT0);
        set_param(DISTOBJ,'IDVT1',M.IDVT1);
        
        % Loop for number of runs
        for j = 1:r
            % Defining filename for csv file
            filename = sprintf('Setup %d, run %d.csv',i,j);
            
            % Defing seed for this run and entering it into simulink
            seed = num2str(M.seed{i}+j-1) ;
            sfunc_param = strcat('[],',seed,',0') ;
            set_param(TECODEOBJ,'Parameters',sfunc_param)
            
            % Actual simulation
             simOut = sim(SYSTEMOBJ,...
                'saveFormat','Array',...
                'timeout',1000);
            
            % Saving data to a big table
            all = [get(simOut,'tout'),get(simOut,'yout')];
            all = [all(:,1),nan(length(all),1),all(:,2:13),...
                nan(length(all),1),all(:,14:54),nan(length(all),1),...
                all(:,55:82)];
            alltable = array2table(all,'VariableNames',allnames);
            
            % Saving table to csv file
            writetable(alltable,filename);
    
            % Calculating how many runs have been completed
            p = sum(cell2mat(M.setup(1:i,2)))-r+j;
    
            % Creating a cell array of strings with filenames
            filenames{j} = filename;
    
            % Updating waitbar
            waitbar(p/tr,w,sprintf('Simulations completed: %d of %d',p,tr));
        end % Loop for number of runs
    
        % saving all csv for runs of the same setup in a .zip file
        zipname = sprintf('Setup %d',i); 
        zip(zipname,filenames)
    
        % Creating a cell array of strings with .zip file names
        zipnames{i} = strcat(zipname,'.zip');
    
        % Deleting csv files, as they are now all saved in .zip
        delete(filenames{:})
        clear filename                                                   
        clear filenames
    
        %Removing waitbar
        w.Visible = 'off';
    
    end % Loop for number of setups

    %Creating summary.txt
    fid = fopen('Summary.txt','wt');
    fprintf(fid,'%s',M.summary);
    fclose(fid);
    
    %Saving the .zip files for each setup in one .zip file together with
    %summary.txt
    zipnames{length(zipnames)+1} = 'Summary.txt';
    zip('TEPresults',zipnames)
    
    % Deleting the files that are now in the .zip file
    delete(zipnames{:})
end

% Executes when a button in simulation type button group is selected
function bgsimtypeselection(~,event)
    % If high speed is selected
    if strcmp(event.NewValue.String,'High speed simulation')
        % Number of simulations can be edited and real time export of data when
        % simulation is running is turned off
        set(sims1,'Style','Edit');
        set_param(RT1OBJ,'commented','on')
    
    else
        % Number of simulations is fixed at 1 and real time export of data when
        % simulation is running is turned on
        set(sims1,'Style','Text');
        set(sims1,'String','1');
        set_param(RT1OBJ,'commented','off')
    end
end

% Excecutes when add disturbance button is pressed
function addbutton_Callback(source,eventdata) 
    % Which IDV has been added
    idv = get(dist11,'value')-1;
    
    % Start and end time for IDV
    T0 = str2double(get(dist21,'string'));
    T1 = str2double(get(dist31,'string'));
    
    % string with summary is initialised
    % if random IDV is chosen, the random IDV is generated
    if idv == 29
        idv = randi([1,28]);
    elseif idv == 0
        return;
    end
    
    % Start and end time entered to vector
    M.dist(idv) = 1;
    M.IDVT0(idv) = T0;
    M.IDVT1(idv) = T1;
    
    % Added IDV is written in summary
    distsummary = 'Disturbances added:';
    for j = 1:28
        if M.IDVT0(j) ~= 0
            distsummary = strcat(distsummary,sprintf('\n IDV %d from %d to %d. \n',j,M.IDVT0(j),M.IDVT1(j)));
        end
    end
    set(distsum,'string',distsummary);
    
    % GUI disturbance panel is reset
    set(dist21,'string','5');
    set(dist31,'string','20');
    set(dist11,'value',1);
end   

function goback_Callback(source,eventdata) 
    set(dist21,'string','');
    set(dist31,'string','');
    set(dist11,'value',1);
    set(distsum,'string','Disturbances added:');
    set(sims1,'string','1');
    set(time1,'string','20');
    set(filename1,'string','simulation');
    set(fast,'Value',1);
    set(seed1,'string','r');
    M.start.Visible = 'On';
    M.f.Visible = 'Off';
end

function addsetup_Callback(source,eventdata) 
    M.setups = M.setups + 1;
    
    % number of runs
    M.setup(M.setups).r = str2double(get(sims1,'string'));
    
    % length of simulation
    M.setup(M.setups).t = str2double(get(time1,'string'));
    
    % Seed is found
    seed = lower(get(seed1,'String'));
    if strcmp(seed,'r')
        M.setup(M.setups).seed = randi([0,10000]);
    else
        M.setup(M.setups).seed = str2double(seed);
    end
    M.setup(M.setups).dist = M.dist;
    M.setup(M.setups).T0 = M.IDVT0;
    M.setup(M.setups).T1 = M.IDVT1;

    % Summary is written
    set(dist21,'string','5');
    set(dist31,'string','20');
    set(dist11,'value',1);
    set(distsum,'string','Disturbances added:');
    set(sims1,'string','1');
    set(time1,'string','20');
    set(filename1,'string','simulation');
    set(fast,'Value',1);
    set(seed1,'string','r');
    setupsummary = sprintf('Setups added: %d',M.setups);
    set(setupsum,'string',setupsummary);
    M.IDVT0 = zeros(1,28);
    M.IDVT1 = zeros(1,28);
    M.dist = zeros(1,28);
end

function continue_Callback(source,eventdata) 
    M.setups = M.setups + 1;
    
    % number of runs
    M.setup(M.setups).r = str2double(get(sims1,'string'));
    
    % length of simulation
    M.setup(M.setups).t = str2double(get(time1,'string'));
    
    % Seed is found
    seed = lower(get(seed1,'String'));
    if strcmp(seed,'r')
        M.setup(M.setups).seed = randi([0,10000]);
    else
        M.setup(M.setups).seed = str2double(seed);
    end
    M.setup(M.setups).dist = M.dist;
    M.setup(M.setups).T0 = M.IDVT0;
    M.setup(M.setups).T1 = M.IDVT1;
    summary = '';
    
    % Loop for each setup
    for i = 1:M.setups
        % Number of runs 
        r = M.setup(i).r;
        
        % Simulation time
        t =  M.setup(i).t;
        
        % Which IDV is on
        d = M.setup(i).dist;
        
        % The start and end time of the disturbance. If d = 0 there is no
        % disturbance
        T0 = M.setup(i).T0;
        T1 = M.setup(i).T1;
        
        % Seed is found. If random seed is desired, a seed between 0 and 10000 is
        % generated
        seed = M.setup(i).seed;
        
        % Summary of the simulations that will be made is created
        if strcmp(summary,'')
            summary = strcat(summary,sprintf('Setup %d: \n %d runs of %d hours duration.',i,r,t));
        else
            summary = strcat(summary,sprintf('\n\nSetup %d: \n %d runs of %d hours duration.',i,r,t));
        end
        if nnz(d) == 28
            summary = strcat(summary,sprintf('\n No disturbances are on.'));
        else
            for j = 1:28
                if d(j)~=0
                    summary = strcat(summary,sprintf('\n IDV %d is on from hours %d to %d. \n',j,T0(j),T1(j)));
                end
            end
        end
        summary = strcat(summary,sprintf('\n Seed is %d to %d.',seed,seed+r-1));
    end
    % The real time data export file is renamed
    set_param(RT1OBJ,'filename',get(filename1,'String'));

    % Summary window is opened with new summary and set up window is closed
    M.summary = summary;
    manualsummarywindow.String = summary;
    M.f.Visible = 'Off';
    M.manualsummary.Visible = 'On';
    set(dist21,'string','5');
    set(dist31,'string','20');
    set(dist11,'value',1);
    set(distsum,'string','Disturbances added:');
    set(sims1,'string','1');
    set(time1,'string','20');
    set(filename1,'string','simulation');
    set(fast,'Value',1);
    set(seed1,'string','r');
end

% Executes when new setup option is chosen from manual summary window
function manualgoback_Callback(source,eventdata) 
    % Set up window is opened, summary windowis closed and set up is reset
    M.f.Visible = 'On';
    M.manualsummary.Visible = 'Off';
    M.IDVT0 = zeros(1,28);
    M.IDVT1 = zeros(1,28);
    M.dist = zeros(1,28);
    M.setups = 0;
end

% Executes when start simulation is chosen from summary window
function startmanualsim_Callback(source,eventdata)
    FLAGFLAG = 0;    
    % Enter file summary window is closed
    M.manualsummary.Visible = 'Off';
    
    % number of setups
    n = length(M.setup);

    % Total amount of simulation runs
    tr = 0;
    for i = 1:n
        tr = tr + M.setup(i).r;
    end

    % Sets the simulation speed as fast as possible
    set_param(TfRTOBJ,'Parameters','0.00000001');

    % Loop for number of setups
    for i = 1:n
        % Turning on waitbar 
        w.Visible = 'on';
            if i == 1
                waitbar(0,w,sprintf('Simulations completed: %d of %d',0,tr));
            end
        % Number of runs 
        r = M.setup(i).r;
        % Length of simulation entered into simulink
        t = num2str(M.setup(i).t);
        set_param(SYSTEMOBJ,'StopTime',t);
        % Setting up disturbance vector and entering it into simulink
        M.IDVT0 = M.setup(i).T0;
        M.IDVT1 = M.setup(i).T1;
        M.IDVT0 = strcat('[',num2str(M.IDVT0),']');
        M.IDVT1 = strcat('[',num2str(M.IDVT1),']');
        set_param(DISTOBJ,'IDVT0',M.IDVT0);
        set_param(DISTOBJ,'IDVT1',M.IDVT1);
     
        % Loop for number of runs
        for j = 1:r
            % Defining filename for csv file
            filename = sprintf('Setup %d, run %d.csv',i,j);
            % Defining seed for this run and entering it into simulink
            seed = num2str(M.setup(i).seed+j-1);
            sfunc_param = strcat('[],',seed,',0');
            set_param(TECODEOBJ,'Parameters',sfunc_param)
            % Real time or fast sim
            if strcmp(get(sims1,'Style'),'text')
                rt = 1;
            else
                rt = 0;
            end
            % Actual simulation
            if rt == 1
                fPlot.Visible = 'on';
                set_param(TfRTOBJ,'Parameters','60');
                set_param(SYSTEMOBJ,'SimulationCommand','start');
                if strcmp(get(h_timer, 'Running'), 'off')
                    start(h_timer);
                end
                FLAGFLAG = 1;
                break
            else
            simOut = sim(SYSTEMOBJ,...
                'saveFormat','Array',...
                'timeout',1000);
            end
            
            % Saving data to a big table
            all = [get(simOut,'tout'),get(simOut,'yout')];
            all = [all(:,1),nan(length(all),1),all(:,2:13),...
                nan(length(all),1),all(:,14:54),nan(length(all),1),...
                all(:,55:82)];
            alltable = array2table(all,'VariableNames',allnames);
            
            % Saving table to csv file
            writetable(alltable,filename);
            
            % Calculating how many runs have been completed
            p=0;
            for k = 1:i-1
                if k == 0
                else
                    p = p + M.setup(i-k).r;
                end
            end
            p = p +j;
            
            % Creating a cell array of strings with filenames
            filenames{j} = filename;
            
            % Updating waitbar
            waitbar(p/tr,w,sprintf('Simulations completed: %d of %d',p,tr));
        end % Loop for number of runs
        
        if FLAGFLAG == 1
            break
        end
        
        % saving all csv for runs of the same setup in a .zip file
        zipname = sprintf('Setup %d',i); 
        zip(zipname,filenames)
        
        % Creating a cell array of strings with .zip file names
        zipnames{i} = strcat(zipname,'.zip');
        
        % Deleting csv files, as they are now all saved in .zip
        delete(filenames{:})
        clear filename                                               
        clear filenames                                              
        
        % Removing waitbar
        w.Visible = 'off';
    end % Loop for number of setups
    
    if FLAGFLAG == 1
        return
    end
    
    % Creating summary.txt
    fid = fopen('Summary.txt','wt');
    fprintf(fid,'%s',M.summary);
    fclose(fid);
    
    % Saving the .zip files for each setup in one .zip file together with
    % summary.txt
    zipnames{length(zipnames)+1} = 'Summary.txt';
    zip('TEPresults',zipnames)
    
    % Deleting the files that are now in the .zip file
    delete(zipnames{:})
end    

% Executes continously with h_timer when real time simulation is chosen
function update_display(~,~)
    % Pauses simulation
    set_param(SYSTEMOBJ,'SimulationCommand','pause');
    
    % Total number of iterations
    ii_new = evalin('base', 'length(tout);');
    
    % Refreshes all manipulated variable graphs
    for i = 1:12
        refreshdata(f.UserData.h_fig{i});
    end % for
    
    % Safety variables
    for i = 1:5
        % Data is refreshed
        refreshdata(f.UserData.h_figCrit{i});
        
        % Check Limits --> New Function
        if fCrit_titles{i}{1} == 7
            % Find the highest point in the last few iterations
            str = strcat('max(yout(', int2str(ii),':',int2str(ii_new),',',int2str(fCrit_titles{i}{1}+12),'))');
            maxVal = evalin('base', str);
            
            % If highest point is above high limit, title of the graph will turn red and a
            % string is printed in command window
            if maxVal >= 2895 && flag(7) == 0 % Reactor Pressure
                if ~(strcmp(get_param(SYSTEMOBJ,'SimulationStatus'), 'stopped'))
                    disp(strcat('High Limit: ', strcat(fCrit_titles{i}{2})));
                    flag(7) = 1;
                    fPlot.Children(1).Children(2).Children(5).Title.Color(1) = 1;
                    %keyboard;
                end % if
            end % if
            
            % If highest point is below high limit the title of the graph turns black
            if maxVal <= 2895 && flag(7) == 1
                flag(7) = 0;
                fPlot.Children(1).Children(2).Children(5).Title.Color(1) = 0;
            end % if
        end % if
        if fCrit_titles{i}{1} == 8 % Reactor Level
            % Find the highest point in the last few iterations
            str = strcat('max(yout(', int2str(ii),':',int2str(ii_new),',',int2str(fCrit_titles{i}{1}+12),'))');
            maxVal = evalin('base', str);
            
            % Find the lowest point in the last few iterations
            str = strcat('min(yout(', int2str(ii),':',int2str(ii_new),',',int2str(fCrit_titles{i}{1}+12),'))');
            minVal = evalin('base', str);
            
            % If highest point is above high limit, title of the graph will turn red and a
            % string is printed in command window
            if maxVal >= 100 && flag(8) == 0
                if ~(strcmp(get_param(SYSTEMOBJ,'SimulationStatus'), 'stopped'))
                    disp(strcat('High Limit: ', strcat(fCrit_titles{i}{2})));
                    flag(8) = 1;
                    fPlot.Children(1).Children(2).Children(4).Title.Color(1) = 1;
                end % if
            end % if
            
            % If highest point is below high limit the title of the graph turns black
            if maxVal <= 100 && flag(8) == 1
                flag(8) = 0;
                fPlot.Children(1).Children(2).Children(4).Title.Color(1) = 0;
            end % if
            
            % If lowest point is below low limit, title of the graph will turn red and a
            % string is printed in command window
            if minVal <= 50 && flag(8) == 0
                if ~(strcmp(get_param(SYSTEMOBJ,'SimulationStatus'), 'stopped'))
                    disp(strcat('Low Limit: ', strcat(fCrit_titles{i}{2})));
                    flag(8) = -1;
                    fPlot.Children(1).Children(2).Children(4).Title.Color(1) = 0.7;
                end % if
            end % if
            
            % If lowest point is above low limit the title of the graph turns black
            if minVal >= 50 && flag(8) == -1
                flag(8) = 0;
                fPlot.Children(1).Children(2).Children(4).Title.Color(1) = 0;
            end % if
        end % if
        if fCrit_titles{i}{1} == 9 % Reactor Temperature
        
            % Find the highest point in the last few iterations
            str = strcat('max(yout(', int2str(ii),':',int2str(ii_new),',',int2str(fCrit_titles{i}{1}+12),'))');
            maxVal = evalin('base', str);
            
            % If highest point is above high limit, title of the graph will turn red and a
            % string is printed in command window
            if maxVal >= 150 && flag(9) == 0
                if ~(strcmp(get_param(SYSTEMOBJ,'SimulationStatus'), 'stopped'))
                    disp(strcat('High Limit: ', strcat(fCrit_titles{i}{2})));
                    flag(9) = 1;
                    fPlot.Children(1).Children(2).Children(3).Title.Color(1) = 1;
                end % if
            end % if
        
            % If highest point is below high limit the title of the graph turns black
            if maxVal <= 150 && flag(9) == 1
                flag(9) = 0;
                fPlot.Children(1).Children(2).Children(3).Title.Color(1) = 0;
            end % if
        end % if
        
        if fCrit_titles{i}{1} == 12 % Prod. Seperator Level
            % Find the highest point in the last few iterations
            str = strcat('max(yout(', int2str(ii),':',int2str(ii_new),',',int2str(fCrit_titles{i}{1}+12),'))');
            maxVal = evalin('base', str);
            
            % Find the lowest point in the last few iterations
            str = strcat('min(yout(', int2str(ii),':',int2str(ii_new),',',int2str(fCrit_titles{i}{1}+12),'))');
            minVal = evalin('base', str);
            
            % If highest point is above high limit, title of the graph will turn red and a
            % string is printed in command window
            if maxVal >= 100 && flag(12) == 0
                if ~(strcmp(get_param(SYSTEMOBJ,'SimulationStatus'), 'stopped'))
                    disp(strcat('High Limit: ', strcat(fCrit_titles{i}{2})));
                    flag(12) = 1;
                    fPlot.Children(1).Children(2).Children(2).Title.Color(1) = 1;
                    %keyboard;
                end % if
            end % if
            
            % If highest point is below high limit the title of the graph turns black
            if maxVal <= 100 && flag(12) == 1
                flag(12) = 0;
                fPlot.Children(1).Children(2).Children(3).Title.Color(1) = 0;
            end % if
            
            % If lowest point is below low limit, title of the graph will turn red and a
            % string is printed in command window
            if minVal <= 30 && flag(12) == 0
                if ~(strcmp(get_param(SYSTEMOBJ,'SimulationStatus'), 'stopped'))
                    disp(strcat('Low Limit: ', strcat(fCrit_titles{i}{2})));
                    flag(12) = -1;
                    fPlot.Children(1).Children(2).Children(2).Title.Color(1) = 0.7;
                    %keyboard;
                end % if
            end % if
            
            % If lowest point is above low limit the title of the graph turns black
            if minVal >= 30 && flag(12) == -1
                flag(12) = 0;
                fPlot.Children(1).Children(2).Children(3).Title.Color(1) = 0;
            end % if
        end % if
        
        if fCrit_titles{i}{1} == 15 % Stripper Base Level
        % Find the highest point in the last few iterations
            str = strcat('max(yout(', int2str(ii),':',int2str(ii_new),',',int2str(fCrit_titles{i}{1}+12),'))');
            maxVal = evalin('base', str);
            
            % Find the lowest point in the last few iterations
            str = strcat('min(yout(', int2str(ii),':',int2str(ii_new),',',int2str(fCrit_titles{i}{1}+12),'))');
            minVal = evalin('base', str);
            
            % If highest point is above high limit, title of the graph will turn red and a
            % string is printed in command window
            if maxVal >= 100 && flag(15) == 0
                if ~(strcmp(get_param(SYSTEMOBJ,'SimulationStatus'), 'stopped'))
                    disp(strcat('High Limit: ', strcat(fCrit_titles{i}{2})));
                    flag(15) = 1;
                    fPlot.Children(1).Children(2).Children(1).Title.Color(1) = 1;
                end % if
            end % if
            
            % If highest point is below high limit the title of the graph turns black
            if maxVal <= 100 && flag(15) == 1
                flag(15) = 0;
                fPlot.Children(1).Children(2).Children(1).Title.Color(1) = 0;
            end % if
            
            % If lowest point is below low limit, title of the graph will turn red and a
            % string is printed in command window
            if minVal <= 30 && flag(15) == 0
                if ~(strcmp(get_param(SYSTEMOBJ,'SimulationStatus'), 'stopped'))
                    disp(strcat('Low Limit: ', strcat(fCrit_titles{i}{2})));
                    flag(15) = -1;
                    fPlot.Children(1).Children(2).Children(1).Title.Color(1) = 0.7;
                end % if
            end % if
            
            % If lowest point is above low limit the title of the graph turns black
            if minVal >= 30 && flag(15) == -1
                flag(15) = 0;
                fPlot.Children(1).Children(2).Children(1).Title.Color(1) = 0;
            end % if
        end % if
        
    end % for
    ii = ii_new;
    pause(1e-4);
    % resume simulation
    set_param(SYSTEMOBJ,'SimulationCommand','continue');    
end % function


end