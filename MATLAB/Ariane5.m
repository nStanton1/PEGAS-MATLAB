clearvars vehicle
% Ariane 5

% Data taken from:
% https://www.esa.int/Our_Activities/Space_Transportation/Launch_vehicles/Boosters_EAP

%% Payload
if ~exist('payload', 'var')
    payload = 7500;    %certified max to GTO = 10000kg
end

%% Scale SS-SRB to time of Ariane 5
scaleTo = 132;  % Time of SRB cutout
SpaceShuttleThrustProfile  % SS-SRB thrust profile


%% Stage 1
%SRBs + Core+
stage_m0 = (14700+159000+1686) + ...     % Core Stage:inertMass + fuelMass + interstage
            2 * 268000 + ...             % #SRBs * mass SRBs
            1370 + ...                   % Vehicle Equipment Bay
            (4540+14900) + ...           % Stage 2:inert+fuel 
            2500 + ...                   % Payload Fairing
            payload;                     % Payload
% Core Stage:
stage_engines(1) = struct('mode', 1,...
                          'isp0', 434,...  % Vacuum
                          'isp1', 318,...  % Sea level
                          'flow', 316.5,... % Mass flow rate
                          'data', [1.000 1.000]);   %Throttle Settings
% SRB 
stage_engines(2) = struct('mode', 1,...%%%%%%%%%%%%%%%%%%%%%%
                          'isp0', 274.5,...  % Vacuum
                          'isp1', 235.5,...  % Sea level
                          'flow', 2*2000,... % Mass flow rate
                          'data', thrustProfile);   %3 SRBs
stage_time = 132; %Stage Time
stage_area = pi*(5.4/2)^2; %Area assuming cylinder
%I have no idea what this is
stage_drag = [ 0.0  0.08;
               250  0.08;
               343  0.80;
               999  0.50;
               9999 0.40; ];            %not supported by any real data!
stage = struct('MODE', 1,...
               'm0', stage_m0,...
               'engines', stage_engines,...
               'maxT', stage_time,...
               'gLim', 0,...
               'area', stage_area,...
               'drag', stage_drag);
vehicle(1) = stage;
%% Stage 2
stage_m0 = (14700+159000+1686) + ...     % Core Stage:inertMass + fuelMass + interstage
            1370 + ...                   % Vehicle Equipment Bay
            (4540+14900) + ...           % Stage 2:inert+fuel 
            2500 + ...                   % Payload Fairing
            payload;                     % Payload
stage_engines(2) = [];
stage.engines(2) = [];
stage_m0 = stage_m0 - vehicleTools('mass', stage, 1, stage_time);
stage_time = vehicleTools('tgo', stage, 1, 159000) - 132;
stage_area = pi*(5.4/2)^2;
stage = struct('MODE', 1,...
               'm0', stage_m0,...
               'engines', stage_engines,...
               'maxT', stage_time,...
               'gLim', 0,...
               'area', stage_area,...
               'drag', stage_drag);
vehicle(2) = stage;

%% Stage 3
stage_m0 = (4540+14900) + ...           % Stage 2:inert+fuel 
            payload;                    % Payload

stage_engines(1) = struct('mode', 1,...
                          'isp0', 446,...
                          'isp1', 446,...
                          'flow', 67000/(446*g0),...
                          'data', [1.000 1.000]);   %RL-10C-1
stage_area = pi*(5.4/2)^2;
stage = struct('MODE', 1,...
               'm0', stage_m0,...
               'engines', stage_engines,...
               'maxT', 0,...
               'gLim', 0,...
               'area', stage_area,...
               'drag', stage_drag);
stage.maxT = vehicleTools('tgo', stage, 1, 14900);
vehicle(3) = stage;

%%
clearvars payload
clearvars scaleTo thrustProfile
clearvars stage_m0 stage_time stage_area stage_drag stage_engines stage