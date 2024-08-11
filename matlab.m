data = readtable('Extracted_data-final.xlsx');


NE_SOC = data{:,1}; 
NE_OCV = data{:,2}; 
PE_SOC = data{:,3}; 
PE_OCV = data{:,4}; 
FC_Cap = data{:,5}; 
FC_OCV = data{:,6}; 


FC_SOC = FC_Cap / 4.8261;


Up = [PE_SOC PE_OCV];
Un = [NE_SOC NE_OCV];


function rmse = objectiveFunction(params, Q_actual, V_actual, Up, Un, Cp, Cn, PE_SOC, NE_SOC)
    y0 = params(1);
    x0 = params(2);
    Cp = params(3);
    Cn = params(4);
    
        y = y0 + Q_actual/ Cp;
        x = x0 +Q_actual / Cn;
        Un1 = interp1(Un(1:36,1), Un(1:36,2), x, 'linear', 'extrap');
        Up1 = interp1(Up(1:36,1), Up(1:36,2), y, 'linear', 'extrap');
        V_simulated = Up1 - Un1;
    rmse = sqrt(mean((V_actual - V_simulated).^2, 'omitnan'));
end


y0 = 0.1;
x0 = 0.034;
Cp = 5.281203911;
Cn = 5.125548657;


lb = [0, 0, 4.85, 4.85];
ub = [0.1, 0.08, 6, 6];


params0 = [y0, x0, Cp, Cn];
objective = @(params) objectiveFunction(params, FC_Cap, FC_OCV, Up, Un, Cp, Cn, PE_SOC, NE_SOC);
options = optimoptions('fmincon', 'MaxFunctionEvaluations', 1000, 'Display', 'iter', 'Algorithm', 'sqp');
[optimal_params, optimal_rmse] = fmincon(objective, params0, [], [], [], [], lb, ub, [], options);

y0_optimal = optimal_params(1);
x0_optimal = optimal_params(2);
Q_actual = FC_Cap;
V_actual = FC_OCV;
V_simulated = zeros(size(Q_actual));
y_values = zeros(size(Q_actual));
x_values = zeros(size(Q_actual));
Up_values = zeros(size(Q_actual));
Un_values = zeros(size(Q_actual));

for i = 1:length(Q_actual)
    Q = Q_actual(i);
    y = y0_optimal + Q / Cp;
    x = x0_optimal + Q / Cn;
    y_values(i) = y;
    x_values(i) = x;
    if y < min(PE_SOC) || y > max(PE_SOC) || x < min(NE_SOC) || x > max(NE_SOC)
        V_simulated(i) = NaN; 
        Up_values(i) = NaN;
        Un_values(i) = NaN;
    else
        Up_values(i) = Up(y);
        Un_values(i) = Un(x);
        V_simulated(i) = Up_values(i) - Un_values(i);
    end
end


valid_idx = isfinite(V_simulated);
Q_actual_valid = Q_actual(valid_idx);
V_actual_valid = V_actual(valid_idx);
V_simulated_valid = V_simulated(valid_idx);
y_values_valid = y_values(valid_idx);
x_values_valid = x_values(valid_idx);
Up_values_valid = Up_values(valid_idx);
Un_values_valid = Un_values(valid_idx);


results = table(Q_actual_valid, V_actual_valid, y_values_valid, x_values_valid, V_simulated_valid, Up_values_valid, Un_values_valid, ...
    'VariableNames', {'Q_actual', 'V_actual', 'y', 'x', 'V_simulated', 'Up', 'Un'});
disp(results);


disp(['Optimal RMSE: ', num2str(optimal_rmse)]);
disp(['Optimized y0: ', num2str(y0_optimal)]);
disp(['Optimized x0: ', num2str(x0_optimal)]);


figure;
subplot(2, 2, 1);
plot(PE_SOC_cleaned, PE_OCV_cleaned, 'o-');
xlabel('PE_SOC');
ylabel('PE_OCV');
title('Cleaned PE_SOC vs PE_OCV');


subplot(2, 2, 2);
plot(NE_SOC_cleaned, NE_OCV_cleaned, 'o-');
xlabel('NE_SOC');
ylabel('NE_OCV');
title('Cleaned NE_SOC vs NE_OCV');


subplot(2, 2, 3);
plot(Q_actual_valid, V_actual_valid, 'o-');
xlabel('Q_actual');
ylabel('V_actual');
title('Q_actual vs V_actual');


subplot(2, 2, 4);
plot(Q_actual_valid, V_simulated_valid, 'o-');
xlabel('Q_actual');
ylabel('V_simulated');
title('Q_actual vs V_simulated');


figure;
plot(Q_actual_valid, V_actual_valid, 'o-', 'DisplayName', 'V_actual');
hold on;
plot(Q_actual_valid, V_simulated_valid, 'x-', 'DisplayName', 'V_simulated');
plot(Q_actual_valid, Up_values_valid, '*-', 'DisplayName', 'Up');
plot(Q_actual_valid, Un_values_valid, 's-', 'DisplayName', 'Un');
xlabel('Q_actual');
ylabel('Voltage');
title('V_actual, V_simulated, Up, and Un vs Q_actual');
legend('show');
hold off;

legend(["V_actual", "V_simulated", "Up", "Un"], "Position", [0.6494 0.4423 0.2240, 0.1730])


figure;
plot(Q_actual_valid, V_actual_valid, 'o-', 'DisplayName', 'V_actual');
hold on;
plot(Q_actual_valid, V_simulated_valid, 'x-', 'DisplayName', 'V_simulated');
xlabel('Q_actual');
ylabel('Voltage');
title('V_actual vs V_simulated');
legend('show');
