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
% This creates a signal that swings from 0.5V to 7.5V

% Sampling Parameters
Fs = 20;              % 20 Hz (Sampling frequency, Fs > 2*f_analog)
T_duration = 2;       % Show 2 seconds of the signal

% --- 2. Calculate "High-Resolution" Analog Signal ---
t_analog = linspace(0, T_duration, 1000); 
v_analog = A * sin(2 * pi * f_analog * t_analog) + DC_offset;

% --- 3. Perform Sampling ---
t_digital = 0 : 1/Fs : T_duration;
v_sampled = A * sin(2 * pi * f_analog * t_digital) + DC_offset;

% --- 4. Perform Quantization ---
num_levels = 2^n_bits;
LSB = V_FSR / num_levels; % LSB = 8V / 2^3 = 1.0V
v_quantized = round(v_sampled / LSB) * LSB;

% --- 5. Plot the Signals in Separate Windows ---

% --- Figure 1: Original Analog Signal ---
figure(1);
plot(t_analog, v_analog, 'b-', 'LineWidth', 2);
title('1. Original Analog Signal (Continuous)');
xlabel('Time (s)');
ylabel('Voltage (V)');
grid on;
ylim([V_min V_max]);
% Set 16:9 Aspect Ratio
pbaspect([16 9 1]);

% --- Figure 2: Sampled Signal ---
figure(2);
% Use 'stem' to show discrete sample points
stem(t_digital, v_sampled, 'rx', 'MarkerSize', 10, 'LineWidth', 2);
title('2. Sampled Signal (Discrete Time)');
xlabel('Time (s)');
ylabel('Voltage (V)');
grid on;
ylim([V_min V_max]);
% Set 16:9 Aspect Ratio
pbaspect([16 9 1]);

% --- Figure 3: Quantized (Digital) Signal ---
figure(3);
% Use 'stairs' to show the Zero-Order Hold output
stairs(t_digital, v_quantized, 'g-', 'LineWidth', 2.5);
title('3. Quantized Signal (Discrete Time & Amplitude)');
xlabel('Time (s)');
ylabel('Voltage (V)');
grid on;
ylim([V_min V_max]);
% Set 16:9 Aspect Ratio
pbaspect([16 9 1]);