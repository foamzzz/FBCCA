function filterbank = generate_filterbank(passbands, stopbands, srate, order, rp)
    if nargin < 4
        order = [];  % Set default for order if not provided
    end
    if nargin < 5
        rp = 0.5;  % Set default for rp if not provided
    end
    
    filterbank = {};  % Initialize the filterbank as a cell array

    % Loop through the passbands and stopbands
    for i = 1:length(passbands)
        wp = passbands{i};  % Passband
        ws = stopbands{i};  % Stopband
        
        % Normalize the frequencies by the Nyquist frequency (srate/2)
        wp_norm = wp / (srate / 2);
        ws_norm = ws / (srate / 2);
        
        if isempty(order)  % If order is not specified
            % Use cheb1ord to find the optimal order and cutoff frequencies
            [N, wn] = cheb1ord(wp_norm, ws_norm, 3, 40);  % Find order and normalized cutoff frequencies
            % Use cheby1 to design the filter with the calculated order
            sos = cheby1(N, rp, wn, 'bandpass', 's');  % Design the filter with 'sos'
        else
            % When order is specified, use the fixed order for the design
            sos = cheby1(order, rp, wp_norm, 'bandpass', 's');  % Design the filter with fixed order
        end
        
        filterbank{i} = sos;  % Append the filter to the filterbank
    end
end

