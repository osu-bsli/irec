%% Apogee sweep analysis
% Reads apogee_sweep.csv produced by BatchSimulate and plots
% achieved apogee as a function of target apogee and launch rod angle.

data = readtable('apogee_sweep.csv');

target_apogees = unique(data.target_apogee_m);
launch_angles  = unique(data.launch_rod_angle_deg);

nT = length(target_apogees);
nA = length(launch_angles);

% achieved(i,j) = achieved apogee for launch_angles(i), target_apogees(j)
achieved = reshape(data.achieved_apogee_m, nA, nT);
error_m  = achieved - target_apogees';   % row-broadcast over angles

[T, A] = meshgrid(target_apogees, launch_angles);

%% Figure 1: surface — achieved apogee
figure(1); clf;
surf(T, A, achieved, 'EdgeColor', 'none');
hold on;
% Draw the "perfect control" diagonal
surf(T, A, repmat(target_apogees', nA, 1), ...
     'FaceAlpha', 0.25, 'EdgeColor', 'none', 'FaceColor', [0.8 0.2 0.2]);
xlabel('Target Apogee (m)');
ylabel('Launch Rod Angle (deg)');
zlabel('Achieved Apogee (m)');
title('Achieved Apogee vs Target Apogee and Launch Rod Angle');
colorbar;
legend({'Achieved', 'Target (perfect)'}, 'Location', 'northwest');
view(45, 30);

%% Figure 2: surface — apogee error (achieved − target)
figure(2); clf;
surf(T, A, error_m, 'EdgeColor', 'none');
hold on;
contour3(T, A, error_m, [0 0], 'k-', 'LineWidth', 2);   % zero-error contour
xlabel('Target Apogee (m)');
ylabel('Launch Rod Angle (deg)');
zlabel('Apogee Error (m)');
title('Apogee Error (Achieved − Target)');
colorbar;
colormap(gca, 'coolwarm');

%% Figure 3: line plots — achieved vs target, one line per launch angle
figure(3); clf;
hold on;
colors = lines(nA);
for i = 1:nA
    plot(target_apogees, achieved(i,:), '-o', 'Color', colors(i,:), ...
         'DisplayName', sprintf('%.0f°', launch_angles(i)));
end
plot(target_apogees, target_apogees, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Perfect');
xlabel('Target Apogee (m)');
ylabel('Achieved Apogee (m)');
title('Achieved vs Target Apogee by Launch Rod Angle');
legend('Location', 'northwest');
grid on;

%% Figure 4: line plots — error vs target, one line per launch angle
figure(4); clf;
hold on;
for i = 1:nA
    plot(target_apogees, error_m(i,:), '-o', 'Color', colors(i,:), ...
         'DisplayName', sprintf('%.0f°', launch_angles(i)));
end
yline(0, 'k--', 'LineWidth', 1.5);
xlabel('Target Apogee (m)');
ylabel('Apogee Error (m)');
title('Apogee Error (Achieved − Target) by Launch Rod Angle');
legend('Location', 'best');
grid on;

%% Figure 5: heatmap — error
figure(5); clf;
imagesc(target_apogees, launch_angles, error_m);
set(gca, 'YDir', 'normal');
colorbar;
colormap(gca, 'coolwarm');
clim_val = max(abs(error_m(:)));
clim([-clim_val clim_val]);
xlabel('Target Apogee (m)');
ylabel('Launch Rod Angle (deg)');
title('Apogee Error Heatmap (m)  [red = over, blue = under]');

%% Print summary table
fprintf('\n%-20s', 'Angle \\ Target →');
fprintf('%8.0f', target_apogees);
fprintf('\n');
for i = 1:nA
    fprintf('%-20s', sprintf('%.0f deg', launch_angles(i)));
    fprintf('%+8.1f', error_m(i,:));
    fprintf('\n');
end
