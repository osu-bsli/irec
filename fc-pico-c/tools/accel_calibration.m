    % accel_calibration.m
%
% Computes accelerometer calibration values (scale + offset) from a CSV
% produced by CONFIG_TEST_ACCEL_CALIBRATION firmware mode.
%
% Calibration model: corrected = scale * (raw + offset)
%   offset: removes zero-G bias
%   scale:  corrects gain error so output is in true G
%
% Algorithm: finds the 6 parameters [sx sy sz bx by bz] per sensor that
% minimise the sum of squared errors in ||calibrated_vector||^2 = 1 across
% all captures. No orientation labelling is needed — any spread of static
% orientations that reasonably covers 3-D space works.
% Recommended minimum: 6 captures. More is better.
%
% Workflow:
%   1. Enable CONFIG_TEST_ACCEL_CALIBRATION in src/config.h and flash.
%   2. Open a serial terminal at 921600 baud.
%   3. For each orientation (e.g. +X/-X/+Y/-Y/+Z/-Z up, plus diagonals if
%      desired): hold the board still and press Enter.
%   4. Copy accel_cal.csv from the SD card to this machine.
%   5. Run this script and provide the CSV path when prompted.
%   6. Paste the printed #define lines into src/config.h.

csv_path = input('Path to accel_cal.csv: ', 's');
if isempty(csv_path)
    csv_path = 'accel_cal.csv';
end

T = readtable(csv_path);

required_cols = {'capture_id', 'sample_id', ...
                 'bmi323_x_G',  'bmi323_y_G',  'bmi323_z_G', ...
                 'adxl375_x_G', 'adxl375_y_G', 'adxl375_z_G'};
for c = required_cols
    if ~ismember(c{1}, T.Properties.VariableNames)
        error('Missing column ''%s'' in CSV.', c{1});
    end
end

capture_ids  = unique(T.capture_id);
num_captures = numel(capture_ids);
fprintf('Found %d capture(s).\n\n', num_captures);

if num_captures < 6
    warning('Fewer than 6 captures — problem may be under-constrained. Recommend at least 6 diverse orientations.');
end

sensors   = {'bmi323',   'adxl375'};
col_bases = {{'bmi323_x_G',  'bmi323_y_G',  'bmi323_z_G'}, ...
             {'adxl375_x_G', 'adxl375_y_G', 'adxl375_z_G'}};
ax_names  = {'X', 'Y', 'Z'};

% ---- compute per-capture means (reduces noise before optimising) ----------
all_means = cell(1, numel(sensors));
for s = 1:numel(sensors)
    means = zeros(num_captures, 3);
    for ci = 1:num_captures
        mask = T.capture_id == capture_ids(ci);
        for ax = 1:3
            means(ci, ax) = mean(T.(col_bases{s}{ax})(mask));
        end
    end
    all_means{s} = means;
    fprintf('%s raw per-capture means (G):\n', sensors{s});
    for ci = 1:num_captures
        m = means(ci, :);
        fprintf('  cap %2d: [%+.5f  %+.5f  %+.5f]   |raw| = %.5f G\n', ...
            capture_ids(ci), m(1), m(2), m(3), norm(m));
    end
    fprintf('\n');
end

% ---- optimiser -----------------------------------------------------------
% Residual vector: one element per capture.
%   r_c = (sx*(mx+bx))^2 + (sy*(my+by))^2 + (sz*(mz+bz))^2 - 1
% Using the squared-magnitude form avoids the sqrt and keeps the Jacobian
% well-defined when the estimate is far from the constraint surface.
%
% p = [sx, sy, sz, bx, by, bz]
resid_fn = @(p, means) ...
    (p(1) .* (means(:,1) + p(4))).^2 + ...
    (p(2) .* (means(:,2) + p(5))).^2 + ...
    (p(3) .* (means(:,3) + p(6))).^2 - 1;

p0 = [1, 1, 1, 0, 0, 0];   % identity starting point
lb = [0, 0, 0, -inf, -inf, -inf];  % scales must stay positive

fprintf('%s\n', repmat('=', 1, 60));
fprintf('Calibration results\n');
fprintf('%s\n', repmat('=', 1, 60));

for s = 1:numel(sensors)
    means        = all_means{s};
    sensor_upper = upper(sensors{s});
    cost_fn      = @(p) resid_fn(p, means);

    % Try lsqnonlin (Optimization Toolbox) first; fall back to fminsearch.
    use_lsq = license('test', 'Optimization_Toolbox') && exist('lsqnonlin', 'file');
    if use_lsq
        opts  = optimoptions('lsqnonlin', 'Display', 'off', ...
                             'FunctionTolerance', 1e-12, 'StepTolerance', 1e-12);
        [p_opt, ~, resid_opt] = lsqnonlin(cost_fn, p0, lb, [], opts);
        rms_resid = sqrt(mean(resid_opt.^2));
    else
        warning('Optimization Toolbox not found — falling back to fminsearch (no bounds on scale).');
        scalar_cost = @(p) sum(cost_fn(p).^2);
        p_opt     = fminsearch(scalar_cost, p0, optimset('TolFun', 1e-12, 'TolX', 1e-12, 'MaxFunEvals', 1e5));
        rms_resid = sqrt(mean(cost_fn(p_opt).^2));
    end

    sx = p_opt(1);  sy = p_opt(2);  sz = p_opt(3);
    bx = p_opt(4);  by = p_opt(5);  bz = p_opt(6);

    fprintf('\n// %s  (RMS ||cal||^2 residual = %.2e G^2)\n', sensor_upper, rms_resid);
    scales  = [sx, sy, sz];
    offsets = [bx, by, bz];
    for ax = 1:3
        fprintf('#define CONFIG_CALIB_%s_ACCEL_SCALE_%s  %.8ff\n', sensor_upper, ax_names{ax}, scales(ax));
        fprintf('#define CONFIG_CALIB_%s_ACCEL_OFFSET_%s %.8ff\n', sensor_upper, ax_names{ax}, offsets(ax));
    end

    fprintf('  Calibrated magnitude per capture:\n');
    for ci = 1:num_captures
        xc = sx * (means(ci,1) + bx);
        yc = sy * (means(ci,2) + by);
        zc = sz * (means(ci,3) + bz);
        fprintf('    cap %2d: %.6f G\n', capture_ids(ci), norm([xc, yc, zc]));
    end
end

fprintf('\n%s\n', repmat('=', 1, 60));
fprintf('Paste the #define lines above into src/config.h, replacing the defaults.\n');
fprintf('Calibration formula applied in firmware: corrected = scale * (raw + offset)\n');
