function result = LiFi_Backend(action, varargin)
% ================================================================
% LiFi_Backend.m
% ================================================================
% Backend Processing Module for LiFi-Based Chat System
%
% This file performs the complete digital communication processing:
%
% Message
%    ↓
% UTF-8 Encoding
%    ↓
% Binary Conversion
%    ↓
% OOK Modulation
%    ↓
% Optical Channel + Noise
%    ↓
% Threshold Detection
%    ↓
% Binary to Bytes
%    ↓
% UTF-8 Decoding
%    ↓
% Received Message + BER
%
% ================================================================

    switch lower(action)

        % =========================================================
        % COMPLETE TRANSMISSION PROCESS
        % =========================================================
        case 'transmit'

            message        = varargin{1};
            noiseLevel     = varargin{2};
            threshold      = varargin{3};
            lightIntensity = varargin{4};

            result = processTransmission( ...
                message, ...
                noiseLevel, ...
                threshold, ...
                lightIntensity);


        % =========================================================
        % RE-DETECT EXISTING SIGNAL
        % Used when threshold slider is changed
        % =========================================================
        case 'detect'

            receivedSignal = varargin{1};
            txBits         = varargin{2};
            threshold      = varargin{3};

            result = detectSignal( ...
                receivedSignal, ...
                txBits, ...
                threshold);


        otherwise

            error('LiFi_Backend:InvalidAction', ...
                'Unknown backend action.');

    end

end


% =================================================================
% COMPLETE TRANSMISSION FUNCTION
% =================================================================
function result = processTransmission( ...
    message, ...
    noiseLevel, ...
    threshold, ...
    lightIntensity)

    % -------------------------------------------------------------
    % STEP 1: Convert text message into UTF-8 bytes
    % -------------------------------------------------------------

    bytes = unicode2native(message,'UTF-8');


    % -------------------------------------------------------------
    % STEP 2: Convert bytes into binary bits
    % -------------------------------------------------------------

    txBits = bytesToBits(bytes);


    % -------------------------------------------------------------
    % STEP 3: OOK MODULATION
    %
    % Binary 1 → Light ON
    % Binary 0 → Light OFF
    % -------------------------------------------------------------

    ookSignal = double(txBits) * lightIntensity;


    % -------------------------------------------------------------
    % STEP 4: OPTICAL CHANNEL
    %
    % Add Gaussian noise to simulate channel disturbance
    % -------------------------------------------------------------

    rng('shuffle');

    noise = noiseLevel * randn(size(ookSignal));

    receivedSignal = ookSignal + noise;


    % -------------------------------------------------------------
    % STEP 5: PHOTODETECTION AND THRESHOLD DETECTION
    % -------------------------------------------------------------

    detectedBits = receivedSignal >= threshold;

    detectedBits = double(detectedBits);


    % -------------------------------------------------------------
    % STEP 6: Convert detected bits into bytes
    % -------------------------------------------------------------

    rxBytes = bitsToBytes(detectedBits);


    % -------------------------------------------------------------
    % STEP 7: Decode UTF-8 bytes into received text
    % -------------------------------------------------------------

    try

        receivedText = native2unicode(rxBytes,'UTF-8');

        if ~isrow(receivedText)
            receivedText = receivedText(:).';
        end

    catch

        receivedText = ...
            '[Decoding error: adjust threshold/noise]';

    end


    % -------------------------------------------------------------
    % STEP 8: CALCULATE BIT ERROR RATE
    % -------------------------------------------------------------

    if isempty(txBits)

        ber = 0;

    else

        compareLength = min( ...
            numel(txBits), ...
            numel(detectedBits));

        ber = mean( ...
            txBits(1:compareLength) ~= ...
            detectedBits(1:compareLength));

    end


    % -------------------------------------------------------------
    % RETURN ALL RESULTS TO FRONTEND
    % -------------------------------------------------------------

    result = struct();

    result.message         = message;
    result.bytes           = bytes;

    result.txBits          = txBits;
    result.rxBits          = detectedBits;

    result.ookSignal       = ookSignal;
    result.receivedSignal  = receivedSignal;

    result.receivedText    = receivedText;

    result.ber             = ber;

    result.noiseLevel      = noiseLevel;
    result.threshold       = threshold;
    result.lightIntensity  = lightIntensity;

end


% =================================================================
% RE-DETECTION FUNCTION
%
% This is used when the user changes the threshold slider.
% =================================================================
function result = detectSignal( ...
    receivedSignal, ...
    txBits, ...
    threshold)

    % -------------------------------------------------------------
    % THRESHOLD DETECTION
    % -------------------------------------------------------------

    detectedBits = receivedSignal >= threshold;

    detectedBits = double(detectedBits);


    % -------------------------------------------------------------
    % CONVERT BITS TO BYTES
    % -------------------------------------------------------------

    rxBytes = bitsToBytes(detectedBits);


    % -------------------------------------------------------------
    % DECODE MESSAGE
    % -------------------------------------------------------------

    try

        receivedText = native2unicode(rxBytes,'UTF-8');

        if ~isrow(receivedText)
            receivedText = receivedText(:).';
        end

    catch

        receivedText = ...
            '[Decoding error: adjust threshold/noise]';

    end


    % -------------------------------------------------------------
    % CALCULATE BER
    % -------------------------------------------------------------

    if isempty(txBits)

        ber = 0;

    else

        compareLength = min( ...
            numel(txBits), ...
            numel(detectedBits));

        ber = mean( ...
            txBits(1:compareLength) ~= ...
            detectedBits(1:compareLength));

    end


    % -------------------------------------------------------------
    % RETURN RESULTS
    % -------------------------------------------------------------

    result = struct();

    result.rxBits       = detectedBits;
    result.receivedText = receivedText;
    result.ber          = ber;
    result.threshold    = threshold;

end


% =================================================================
% BYTE TO BIT CONVERSION
% =================================================================
function bits = bytesToBits(bytes)

    bytes = uint8(bytes(:));

    bits = zeros(1,numel(bytes)*8);

    k = 1;

    for ii = 1:numel(bytes)

        currentByte = bytes(ii);

        for jj = 8:-1:1

            bits(k) = bitget(currentByte,jj);

            k = k + 1;

        end

    end

end


% =================================================================
% BIT TO BYTE CONVERSION
% =================================================================
function bytes = bitsToBytes(bits)

    bits = double(bits(:).');

    numberOfBytes = floor(numel(bits)/8);

    bytes = zeros(1,numberOfBytes,'uint8');


    for ii = 1:numberOfBytes

        value = uint8(0);


        for jj = 1:8

            bitValue = uint8( ...
                bits((ii-1)*8 + jj));

            value = bitor( ...
                value, ...
                bitshift(bitValue,8-jj));

        end


        bytes(ii) = value;

    end

end