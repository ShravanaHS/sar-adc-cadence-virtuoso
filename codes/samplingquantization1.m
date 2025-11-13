% --- 1. Define Parameters ---
clear; clc; close all;

% ADC Parameters
n_bits = 3;           % Number of bits (e.g., a 3-bit ADC)
V_min = 0;            % Minimum voltage of the ADC
V_max = 8;            % Maximum voltage of the ADC (Full-Scale)
V_FSR = V_max - V_min;  % Full-Scale Range

% Analog Signal Parameters
f_analog = 1;         % 1 Hz (Input signal frequency)
A = 3.5;              % Amplitude (Set to 3.5V)
DC_offset = 4.0;      % DC Offset (Set to 4.0V)
% This creates a signal that swings from 0.5V to 7.5V, 
% fitting nicely inside our 0V-8V ADC range.

% Sampling Parameters
Fs = 20;              % 20 Hz (Sampling frequency, Fs > 2*f_analog)
T_duration = 2;       % Show 2 seconds of the signal

% --- 2. Calculate "High-Resolution" Analog Signal ---
% We simulate "continuous time" by using many points
t_analog = linspace(0, T_duration, 1000); 
v_analog = A * sin(2 * pi * f_analog * t_analog) + DC_offset;

% --- 3. Perform Sampling ---
% This is the discrete time vector for the ADC's clock
t_digital = 0 : 1/Fs : T_duration;
v_sampled = A * sin(2 * pi * f_analog * t_digital) + DC_offset;

% --- 4. Perform Quantization ---
num_levels = 2^n_bits;
LSB = V_FSR / num_levels; % LSB = 8V / 2^3 = 1.0V

% Quantize: Divide by LSB, round to the nearest integer, then multiply by LSB
v_quantized = round(v_sampled / LSB) * LSB;

% --- 5. Plot the Signals ---
figure; % Create a new figure window

% Plot the original analog signal as a smooth blue line
plot(t_analog, v_analog, 'b-', 'LineWidth', 2);
hold on; % Hold the plot to add more lines

% Plot the sampled points as red 'x' marks
stem(t_digital, v_sampled, 'rx', 'MarkerSize', 10, 'LineWidth', 2);

% Plot the quantized "digital" signal using a "stairs" plot
% This simulates the Zero-Order Hold (ZOH) output of a DAC
stairs(t_digital, v_quantized, 'g-', 'LineWidth', 2.5);

% --- 6. Format the Plot ---
hold off;
title(['Analog vs. Digital (Sampled & Quantized) Signal (' num2str(n_bits) '-bit ADC)']);
xlabel('Time (s)');
ylabel('Voltage (V)');
legend('Original Analog Signal', 'Sampled Points', 'Quantized (Digital) Output', 'Location', 'southeast');
grid on;
ylim([V_min V_max]); % Set y-axis to match the ADC's FSR

% --- 7. Set 16:9 Aspect Ratio ---
% This command sets the plot box's aspect ratio
pbaspect([16 9 1]);