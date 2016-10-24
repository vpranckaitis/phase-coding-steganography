function [recovered_watermark] = extract_echo_watermark(encoded_wav, Fs, zero_delay, one_delay)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

    % divide up a signal into windows
    zero_delay = zero_delay / 1000;
    one_delay = one_delay / 1000;

    nx = length(encoded_wav);                            % size of signal
    w = hamming(2000);                          % hamming window
    nw = length(w);                            % size of window
    pos=1;

    zero_delay_signal = [];
    one_delay_signal = [];
    decision_signal = [];

    while (pos+nw <= nx)                       % while enough signal left
            y = encoded_wav(pos:pos+nw-1).*w;           % make window y
            c = abs(rceps(y));
            ac = autoceps(y);
            
            zero_delay_signal(pos) = c(round(zero_delay * Fs) + 1);
            one_delay_signal(pos) = c(round(one_delay * Fs) + 1);
            
            pos = pos + round(nw/25);                 % next window
    end

    last_recorded_bit = 0;
    for pos=1:length(zero_delay_signal),
            if one_delay_signal(pos) - zero_delay_signal(pos) > 0
                decision_signal(pos) = 1;
                last_recorded_bit = 1;
            elseif one_delay_signal(pos) - zero_delay_signal(pos) < 0
                decision_signal(pos) = 0;
                last_recorded_bit = 0;
            else
                decision_signal(pos) = last_recorded_bit;
            end        
    end

    current_bit = 2;
    current_run = 0;
    decoded_bit_string = [];
    runs = [];
    deciders = [];
    for pos=1:length(decision_signal),
        if current_bit == 2
            current_bit = decision_signal(pos);
        end

        if decision_signal(pos) == current_bit
            current_run = current_run + 1;
        else
            % calculate the number of corresponding bits we decoded
            seg = current_run / round(1412);
            if ceil(seg) - seg > 0.9
                dsegments = ceil(seg);
            else
                dsegments = floor(seg);
            end
            nbits = round(seg);
            for i=1:nbits,
                decoded_bit_string = [decoded_bit_string, current_bit];
            end

            current_bit = decision_signal(pos);
            runs = [runs, current_run];
            deciders = [deciders, seg];
            current_run = 0;
        end
    end

    runs
    deciders

    figure(1);
    hold on;
    %axis([-20, length(decision_signal), -0.1, 1.1]);
    plot(decision_signal);
    figure(3);
    plot(one_delay_signal - zero_delay_signal);
    %figure(4);
    %plot(one_delay_signal);
    %figure(5);
    %plot(zero_delay_signal);

    recovered_watermark = decoded_bit_string;

end
