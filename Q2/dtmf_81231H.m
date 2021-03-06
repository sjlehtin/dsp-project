function [ returnString ] = dtmf_81231H( filename )
    [x fT] = wavread(filename);
    lengthInSeconds = length(x)/fT;
    windowLength = 20; % millisecons
    totalChunks = ceil(lengthInSeconds*1000/windowLength);
    chunkSize = fT*windowLength/1000;
    
    
    dtmfMatrix = ['1' '2' '3' 'A'; '4' '5' '6' 'B'; '7' '8' '9' 'C';
        '*' '0' '#' 'D'];
    XAxisFreqs = [1209 1336 1477 1633];
    YAxisFreqs = [697 770 852 941];
    
    % Gathers pressed buttons
    returnString = '';
    
     % Boolean which makes sure only one chunk from each key press is
     % processed.
    chunkProcessed = 0;
    
    for j = 1:totalChunks
        if j == 1 % goddamnit matlab
            part = x(1:chunkSize);
        elseif j == totalChunks
            part = x((j-1)*chunkSize:length(x));
        else
            part = x((j-1)*chunkSize:j*chunkSize);
        end
        % Now 'part' is the chunk we want to inpect, of length windowLength
        
        energyPerMilli = sum(part.^2)/(windowLength*fT);
        
        % If this chunk has enough energy and hasn't been processed, do so
        if energyPerMilli >= 0.0001 && chunkProcessed == 0
            chunkProcessed = 1;
            xF = fft(part);
            MF = length(part);
            mag = 20*log10(abs(xF));
            w = fT * [0 : (MF-1)]/MF;
            plot(w, mag);
            magLimit = mag > 20;
            dialedFrequencies = [];
            
            for n = 1:length(magLimit)
                if magLimit(n) == 1 && magLimit(n-1) ~= 1
                    dialedFrequencies = [dialedFrequencies w(n)];
                    
                    % We only need the first two frequencies
                    if (length(dialedFrequencies) == 2)
                        break;
                    end
                end
            end
            
            if length(dialedFrequencies) ~= 2
                display('Error, no two frequencies received')
            end
            
            guessedIndices = zeros(2,1); % Stores the indices of guesses
            
            for n = 1:2
                if (dialedFrequencies(n) >= 1075)
                    xDifference = abs(XAxisFreqs - dialedFrequencies(n));
                    % Find the index of minimum
                    [r,c] = find(xDifference==min(xDifference));
                    guessedIndices(1) = c;
                else
                    yDifference = abs(YAxisFreqs - dialedFrequencies(n));
                    [r,c] = find(yDifference==min(yDifference));
                    guessedIndices(2) = c;
                end
            end
            if min(guessedIndices) ~= 0
                dialedChar = dtmfMatrix(guessedIndices(2), guessedIndices(1));
                returnString = strcat(returnString, dialedChar);
            else
                display('One of the guessed indices was zero')
            end
        elseif energyPerMilli < 0.0001
            chunkProcessed = 0;
        end
    end
end

