    function LiFi_Chat_System_v1_0
% LiFi Chat System - Digital Communication Micro Project
% Fully software-based MATLAB GUI simulation.
% Theme: Dark
% Modulation: OOK (On-Off Keying)
% Encoding: UTF-8 bytes -> bits
% Channel: Optical intensity channel with optional noise
% Detection: Threshold detector
%
% Run:
%   LiFi_Chat_System_v1_0
%
% No hardware or special toolbox is required.

    clc;
    close all;

    % -------------------- STATE --------------------
    S = struct();
    S.version = 'v1.0';
    S.lastMessage = '';
    S.txBits = [];
    S.rxBits = [];
    S.rxText = '';
    S.ber = 0;
    S.noiseLevel = 0.00;
    S.threshold = 0.50;
    S.bitRate = 100;
    S.lightIntensity = 1.00;
    S.time = [];
    S.waveTx = [];
    S.waveRx = [];
    S.channel = [];

    % -------------------- COLORS --------------------
    C.bg       = [0.055 0.065 0.080];
    C.panel    = [0.085 0.100 0.125];
    C.panel2   = [0.105 0.120 0.150];
    C.text     = [0.92 0.95 1.00];
    C.muted    = [0.62 0.68 0.78];
    C.accent   = [0.25 0.75 1.00];
    C.green    = [0.30 0.90 0.58];
    C.orange   = [1.00 0.67 0.25];
    C.red      = [1.00 0.35 0.38];
    C.grid     = [0.20 0.23 0.29];

    % -------------------- FIGURE --------------------
    f = figure( ...
        'Name','LiFi Chat System | Digital Communication', ...
        'NumberTitle','off', ...
        'Color',C.bg, ...
        'MenuBar','none', ...
        'ToolBar','none', ...
        'Resize','on', ...
        'Position',[40 40 1400 850], ...
        'WindowState','maximized');

    % Header
    uipanel(f,'Position',[0 0.925 1 0.075], ...
        'BackgroundColor',C.panel,'BorderType','none');

    uicontrol(f,'Style','text', ...
        'String','LiFi CHAT SYSTEM', ...
        'Units','normalized', ...
        'Position',[0.025 0.943 0.44 0.040], ...
        'BackgroundColor',C.panel, ...
        'ForegroundColor',C.text, ...
        'FontSize',22,'FontWeight','bold', ...
        'HorizontalAlignment','left');

    uicontrol(f,'Style','text', ...
        'String','Digital Communication  |  Optical Wireless Simulation  |  OOK', ...
        'Units','normalized', ...
        'Position',[0.47 0.946 0.505 0.030], ...
        'BackgroundColor',C.panel, ...
        'ForegroundColor',C.muted, ...
        'FontSize',10,'HorizontalAlignment','right');

    % Left control panel
    pLeft = uipanel(f,'Title','  TRANSMITTER / RECEIVER  ', ...
        'Position',[0.025 0.075 0.27 0.815], ...
        'BackgroundColor',C.panel, ...
        'ForegroundColor',C.accent, ...
        'FontSize',11,'FontWeight','bold');

    uicontrol(pLeft,'Style','text','String','Enter message', ...
        'Units','normalized','Position',[0.07 0.835 0.86 0.045], ...
        'BackgroundColor',C.panel,'ForegroundColor',C.text, ...
        'FontSize',11,'FontWeight','bold','HorizontalAlignment','left');

    hMsg = uicontrol(pLeft,'Style','edit', ...
        'String','Hello LiFi!', ...
        'Max',4,'Min',0, ...
        'Units','normalized','Position',[0.07 0.675 0.86 0.16], ...
        'BackgroundColor',C.panel2,'ForegroundColor',C.text, ...
        'FontSize',12,'HorizontalAlignment','left');

    uicontrol(pLeft,'Style','text','String','Channel noise', ...
        'Units','normalized','Position',[0.07 0.605 0.45 0.04], ...
        'BackgroundColor',C.panel,'ForegroundColor',C.text, ...
        'FontSize',10,'HorizontalAlignment','left');

    hNoise = uicontrol(pLeft,'Style','slider', ...
        'Min',0,'Max',0.25,'Value',0.00, ...
        'Units','normalized','Position',[0.07 0.56 0.58 0.035], ...
        'BackgroundColor',C.panel2, ...
        'Callback',@updateNoise);

    hNoiseValue = uicontrol(pLeft,'Style','text','String','0.00', ...
        'Units','normalized','Position',[0.68 0.545 0.25 0.06], ...
        'BackgroundColor',C.panel,'ForegroundColor',C.green, ...
        'FontSize',10,'FontWeight','bold');

    uicontrol(pLeft,'Style','text','String','Detection threshold', ...
        'Units','normalized','Position',[0.07 0.475 0.50 0.04], ...
        'BackgroundColor',C.panel,'ForegroundColor',C.text, ...
        'FontSize',10,'HorizontalAlignment','left');

    hThreshold = uicontrol(pLeft,'Style','slider', ...
        'Min',0.1,'Max',0.9,'Value',0.5, ...
        'Units','normalized','Position',[0.07 0.43 0.58 0.035], ...
        'BackgroundColor',C.panel2, ...
        'Callback',@updateThreshold);

    hThresholdValue = uicontrol(pLeft,'Style','text','String','0.50', ...
        'Units','normalized','Position',[0.68 0.415 0.25 0.06], ...
        'BackgroundColor',C.panel,'ForegroundColor',C.orange, ...
        'FontSize',10,'FontWeight','bold');

    hSend = uicontrol(pLeft,'Style','pushbutton', ...
        'String','SEND MESSAGE', ...
        'Units','normalized','Position',[0.07 0.315 0.86 0.075], ...
        'BackgroundColor',C.accent,'ForegroundColor',[0.02 0.04 0.06], ...
        'FontSize',12,'FontWeight','bold', ...
        'Callback',@sendMessage);

    hReset = uicontrol(pLeft,'Style','pushbutton', ...
        'String','RESET', ...
        'Units','normalized','Position',[0.07 0.225 0.86 0.06], ...
        'BackgroundColor',C.panel2,'ForegroundColor',C.text, ...
        'FontSize',10,'FontWeight','bold', ...
        'Callback',@resetSystem);

    % Status card
    uipanel(pLeft,'Position',[0.07 0.055 0.86 0.125], ...
        'BackgroundColor',C.panel2,'BorderType','none');

    hStatus = uicontrol(pLeft,'Style','text', ...
        'String','●  READY — Enter a message and press SEND', ...
        'Units','normalized','Position',[0.09 0.10 0.82 0.075], ...
        'BackgroundColor',C.panel2,'ForegroundColor',C.green, ...
        'FontSize',9,'FontWeight','bold','HorizontalAlignment','center');

    % Right output area
    pRight = uipanel(f,'Title','  LiFi LINK MONITOR  ', ...
        'Position',[0.315 0.075 0.66 0.815], ...
        'BackgroundColor',C.panel, ...
        'ForegroundColor',C.accent, ...
        'FontSize',11,'FontWeight','bold');

    % Chat output
    uicontrol(pRight,'Style','text','String','RECEIVED MESSAGE', ...
        'Units','normalized','Position',[0.035 0.875 0.25 0.045], ...
        'BackgroundColor',C.panel,'ForegroundColor',C.muted, ...
        'FontSize',10,'FontWeight','bold','HorizontalAlignment','left');

    hReceived = uicontrol(pRight,'Style','text', ...
        'String','Waiting for transmission...', ...
        'Units','normalized','Position',[0.035 0.805 0.93 0.075], ...
        'BackgroundColor',C.panel2,'ForegroundColor',C.green, ...
        'FontSize',16,'FontWeight','bold','HorizontalAlignment','left');

    % Metrics
    hBits = makeMetric(pRight,[0.035 0.70 0.215 0.085],'BITS SENT','0',C.accent);
    hBytes = makeMetric(pRight,[0.275 0.70 0.215 0.085],'BYTES','0',C.accent);
    hBER = makeMetric(pRight,[0.515 0.70 0.215 0.085],'BIT ERROR RATE','0.00 %',C.green);
    hThresholdMetric = makeMetric(pRight,[0.755 0.70 0.215 0.085],'THRESHOLD','0.50',C.orange);

    % Axes
    ax1 = axes('Parent',pRight,'Units','normalized', ...
        'Position',[0.035 0.405 0.45 0.24], ...
        'Color',C.bg,'XColor',C.muted,'YColor',C.muted, ...
        'GridColor',C.grid,'FontSize',8);
    title(ax1,'TRANSMITTED OOK LIGHT','Color',C.text,'FontSize',10);
    xlabel(ax1,'Bit index'); ylabel(ax1,'Light level');
    grid(ax1,'on'); ylim(ax1,[-0.1 1.15]);

    ax2 = axes('Parent',pRight,'Units','normalized', ...
        'Position',[0.515 0.405 0.45 0.24], ...
        'Color',C.bg,'XColor',C.muted,'YColor',C.muted, ...
        'GridColor',C.grid,'FontSize',8);
    title(ax2,'RECEIVED OPTICAL SIGNAL','Color',C.text,'FontSize',10);
    xlabel(ax2,'Sample'); ylabel(ax2,'Amplitude');
    grid(ax2,'on'); ylim(ax2,[-0.5 1.5]);

    ax3 = axes('Parent',pRight,'Units','normalized', ...
        'Position',[0.035 0.105 0.93 0.24], ...
        'Color',C.bg,'XColor',C.muted,'YColor',C.muted, ...
        'GridColor',C.grid,'FontSize',8);
    title(ax3,'DIGITAL DETECTION — THRESHOLD DECISION','Color',C.text,'FontSize',10);
    xlabel(ax3,'Bit index'); ylabel(ax3,'Detected bit');
    grid(ax3,'on'); ylim(ax3,[-0.15 1.15]);

    % Synchronize initial control values/display.
    S.noiseLevel = get(hNoise,'Value');
    S.threshold = get(hThreshold,'Value');
    set(hNoiseValue,'String',sprintf('%.2f',S.noiseLevel));
    set(hThresholdValue,'String',sprintf('%.2f',S.threshold));
    set(hThresholdMetric.value,'String',sprintf('%.2f',S.threshold));

    % Initialize plots
    cla(ax1); cla(ax2); cla(ax3);
    axes(ax1); text(0.5,0.5,'No transmission yet','Units','normalized', ...
        'Color',C.muted,'HorizontalAlignment','center');
    axes(ax2); text(0.5,0.5,'Optical channel idle','Units','normalized', ...
        'Color',C.muted,'HorizontalAlignment','center');
    axes(ax3); text(0.5,0.5,'Detector idle','Units','normalized', ...
        'Color',C.muted,'HorizontalAlignment','center');

    % Footer
    uicontrol(f,'Style','text', ...
        'String','SOFTWARE SIMULATION  •  UTF-8 → BITS → OOK LED INTENSITY → OPTICAL CHANNEL → PHOTODETECTOR → THRESHOLD → UTF-8', ...
        'Units','normalized','Position',[0.025 0.018 0.95 0.028], ...
        'BackgroundColor',C.bg,'ForegroundColor',C.muted, ...
        'FontSize',8,'HorizontalAlignment','center');

    % Keep the GUI responsive when the user maximizes/restores/resizes it.
    f.SizeChangedFcn = @windowResized;

    % -------------------- CALLBACKS --------------------
    function windowResized(~,~)
        % All controls use normalized units, so MATLAB automatically
        % scales the complete dark dashboard with the window.
        drawnow limitrate;
    end


    function updateNoise(~,~)
        S.noiseLevel = get(hNoise,'Value');
        set(hNoiseValue,'String',sprintf('%.2f',S.noiseLevel));
    end

    function updateThreshold(~,~)
        S.threshold = get(hThreshold,'Value');
        set(hThresholdValue,'String',sprintf('%.2f',S.threshold));
        set(hThresholdMetric.value,'String',sprintf('%.2f',S.threshold));
        if ~isempty(S.waveRx)
            detected = S.waveRx >= S.threshold;
            S.rxBits = detected(1:numel(S.txBits));
            updateDetectionPlot();
        end
    end

    function sendMessage(~,~)
        msg = get(hMsg,'String');
        if iscell(msg)
            msg = strjoin(msg,' ');
        end
        msg = char(msg);

        if isempty(strtrim(msg))
            set(hStatus,'String','●  ERROR — Please enter a message', ...
                'ForegroundColor',C.red);
            return;
        end

        set(hSend,'Enable','off');
        set(hStatus,'String','●  TRANSMITTING — Encoding and modulating...', ...
            'ForegroundColor',C.orange);
        drawnow;

        % UTF-8 encoding. MATLAB char -> UTF-8 bytes.
        bytes = unicode2native(msg,'UTF-8');
        S.txBits = bytesToBits(bytes);

        % OOK: bit 1 = light ON, bit 0 = light OFF.
        ook = double(S.txBits) * S.lightIntensity;

        % Optical channel with additive Gaussian noise.
        rng('shuffle');
        noise = S.noiseLevel * randn(size(ook));
        received = ook + noise;

        % Photodetector + threshold detector.
        detected = received >= S.threshold;
        detected = double(detected);

        % Decode.
        rxBytes = bitsToBytes(detected);
        try
            rxText = native2unicode(rxBytes,'UTF-8');
            if ~isrow(rxText), rxText = rxText(:).'; end
        catch
            rxText = '[Decoding error: adjust threshold/noise]';
        end

        S.waveTx = ook;
        S.waveRx = received;
        S.rxBits = detected;
        S.rxText = rxText;

        if isempty(S.txBits)
            S.ber = 0;
        else
            S.ber = mean(S.txBits ~= S.rxBits(1:numel(S.txBits)));
        end

        % Update GUI.
        set(hReceived,'String',rxText);
        set(hBits.value,'String',num2str(numel(S.txBits)));
        set(hBytes.value,'String',num2str(numel(bytes)));
        set(hBER.value,'String',sprintf('%.2f %%',100*S.ber));
        set(hThresholdMetric.value,'String',sprintf('%.2f',S.threshold));

        plotTransmission();
        updateDetectionPlot();

        if S.ber == 0
            set(hStatus,'String','●  SUCCESS — Message received correctly', ...
                'ForegroundColor',C.green);
        else
            set(hStatus,'String',sprintf('●  COMPLETE — %.2f %% bit errors detected',100*S.ber), ...
                'ForegroundColor',C.orange);
        end

        set(hSend,'Enable','on');
    end

    function resetSystem(~,~)
        set(hMsg,'String','');
        set(hReceived,'String','Waiting for transmission...');
        set(hBits.value,'String','0');
        set(hBytes.value,'String','0');
        set(hBER.value,'String','0.00 %');
        set(hStatus,'String','●  READY — Enter a message and press SEND', ...
            'ForegroundColor',C.green);

        S.txBits = [];
        S.rxBits = [];
        S.waveTx = [];
        S.waveRx = [];

        cla(ax1); cla(ax2); cla(ax3);
        formatAxes(ax1,'TRANSMITTED OOK LIGHT','Bit index','Light level',[-0.1 1.15]);
        formatAxes(ax2,'RECEIVED OPTICAL SIGNAL','Sample','Amplitude',[-0.5 1.5]);
        formatAxes(ax3,'DIGITAL DETECTION — THRESHOLD DECISION','Bit index','Detected bit',[-0.15 1.15]);

        axes(ax1); text(0.5,0.5,'No transmission yet','Units','normalized', ...
            'Color',C.muted,'HorizontalAlignment','center');
        axes(ax2); text(0.5,0.5,'Optical channel idle','Units','normalized', ...
            'Color',C.muted,'HorizontalAlignment','center');
        axes(ax3); text(0.5,0.5,'Detector idle','Units','normalized', ...
            'Color',C.muted,'HorizontalAlignment','center');
    end

    function plotTransmission()
        cla(ax1);
        stairs(ax1,1:numel(S.waveTx),S.waveTx,'LineWidth',2);
        hold(ax1,'on');
        yline(ax1,S.threshold,'--','Threshold', ...
            'Color',C.orange,'LineWidth',1);
        hold(ax1,'off');
        formatAxes(ax1,'TRANSMITTED OOK LIGHT','Bit index','Light level',[-0.1 1.15]);

        cla(ax2);
        plot(ax2,1:numel(S.waveRx),S.waveRx,'LineWidth',1.5);
        hold(ax2,'on');
        yline(ax2,S.threshold,'--','Threshold', ...
            'Color',C.orange,'LineWidth',1);
        hold(ax2,'off');
        formatAxes(ax2,'RECEIVED OPTICAL SIGNAL','Sample','Amplitude',[-0.5 1.5]);
    end

    function updateDetectionPlot()
        cla(ax3);
        if isempty(S.rxBits)
            return;
        end
        stairs(ax3,1:numel(S.rxBits),S.rxBits,'LineWidth',2);
        hold(ax3,'on');
        yline(ax3,0.5,'--','Decision boundary', ...
            'Color',C.orange,'LineWidth',1);
        hold(ax3,'off');
        formatAxes(ax3,'DIGITAL DETECTION — THRESHOLD DECISION','Bit index','Detected bit',[-0.15 1.15]);
    end

    function formatAxes(ax,t,xl,yl,yr)
        title(ax,t,'Color',C.text,'FontSize',10);
        xlabel(ax,xl,'Color',C.muted);
        ylabel(ax,yl,'Color',C.muted);
        set(ax,'Color',C.bg,'XColor',C.muted,'YColor',C.muted, ...
            'GridColor',C.grid,'FontSize',8);
        grid(ax,'on');
        ylim(ax,yr);
    end

    function out = bytesToBits(bytes)
        bytes = uint8(bytes(:));
        out = zeros(1,numel(bytes)*8);
        k = 1;
        for ii = 1:numel(bytes)
            b = bytes(ii);
            for jj = 8:-1:1
                out(k) = bitget(b,jj);
                k = k + 1;
            end
        end
    end

    function bytes = bitsToBytes(bits)
        bits = double(bits(:).');
        n = floor(numel(bits)/8);
        bytes = zeros(1,n,'uint8');
        for ii = 1:n
            value = uint8(0);
            for jj = 1:8
                value = bitor(value,bitshift(uint8(bits((ii-1)*8+jj)),8-jj));
            end
            bytes(ii) = value;
        end
    end

    function h = makeMetric(parent,pos,label,value,fg)
        p = uipanel(parent,'Position',pos,'BackgroundColor',C.panel2, ...
            'BorderType','none');
        uicontrol(p,'Style','text','String',label, ...
            'Units','normalized','Position',[0.05 0.55 0.90 0.30], ...
            'BackgroundColor',C.panel2,'ForegroundColor',C.muted, ...
            'FontSize',8,'FontWeight','bold','HorizontalAlignment','center');
        h.value = uicontrol(p,'Style','text','String',value, ...
            'Units','normalized','Position',[0.05 0.08 0.90 0.48], ...
            'BackgroundColor',C.panel2,'ForegroundColor',fg, ...
            'FontSize',13,'FontWeight','bold','HorizontalAlignment','center');
    end
end
