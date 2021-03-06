clearvars vehicle
%Full model of the Space Shuttle, 4 stages:
%   SSME + SRB
%   constant-thrust SSME mode
%   acceleration-limiting SSME mode
%   OMS
%Data taken from:
%   http://www.braeunig.us/space/specs/shuttle.htm
%   http://www.braeunig.us/space/specs/orbiter.htm
%   http://www.astronautix.com/s/srb.html
%   https://en.wikipedia.org/wiki/Space_Shuttle_orbiter#Shuttle_Orbiter_Specifications_.28OV-105.29
orbiter = 79135;        %OV-105 Endeavour, full OMS/RCS fuel tanks
if ~exist('payload', 'var')
    payload = 25000;        %max for Endeavour
end
SpaceShuttleThrustProfile

%SRB+SSME
stage_m0 = 2*587000 + 765000 + orbiter + payload;   %launch mass [kg]   | SRBs + ET (35t structure, 730t fuel) + orbiter + payload
stage_engines(1) = struct('mode', 1,...
                          'isp0', 452,...
                          'isp1', 366,...
                          'flow', 1462.7,...
                          'data', [0.670 1.045]);   %3 SSMEs
stage_engines(2) = struct('mode', 2,...
                          'isp0', 269,...
                          'isp1', 237,...
                          'flow', 2*13500000/(242*g0),...   %approx. peak thrust from STS-107 mission plots
                          'data', thrustProfile);   %2 SRBs
stage_time = 124;                                   %SRB burn time [s]
stage_area = 2*10.8 + 55.4 + 15.2;                  %cross section [m2]
stage_drag = [ 0.0  0.08;
               250  0.08;
               343  1.20;
               999  0.50;
               9999 0.40; ];                        %drag curve - not supported by any real data!
stage = struct('MODE', 1,...                        %constant thrust
               'm0', stage_m0,...
               'engines', stage_engines,...
               'maxT', stage_time,...
               'gLim', 0,...
               'area', stage_area,...
               'drag', stage_drag);
vehicle(1) = stage;

%SSME const-thrust
stage_m0 = 765000 + orbiter + payload;
stage.engines(2) = [];                              %SRBs were jettisoned
stage_engines(2) = [];
stage_m0 = stage_m0 - vehicleTools('mass', stage, 1, stage.maxT);%SSMEs burned some of the fuel in ET away
stage_time = 320;                                   %acceleration exceeds 3G after that time
stage_area = 55.4 + 15.2;
stage = struct('MODE', 1,...
               'm0', stage_m0,...
               'engines', stage_engines,...
               'maxT', stage_time,...
               'gLim', 0,...
               'area', stage_area,...
               'drag', stage_drag);
vehicle(2) = stage;

%SSME g-limited
stage_m0 = stage_m0 - vehicleTools('mass', stage, 1, stage.maxT);
stage_fuel = 730000 - vehicleTools('mass', stage, 1, 124+320);  %fuel left after previous stages
stage = struct('MODE', 2,...                        %constant acceleration
               'm0', stage_m0,...
               'engines', stage_engines,...
               'maxT', 0,...
               'gLim', 3,...                        %acceleration limit of 3 Gs
               'area', stage_area,...
               'drag', stage_drag);
stage.maxT = vehicleTools('tgo', stage, 2, [stage_fuel stage.gLim]);
vehicle(3) = stage;

%OMS
stage_m0 = orbiter + payload;
stage_area = 15.2;
stage_engines(1) = struct('mode', 1,...
                          'isp0', 313,...
                          'isp1', 313,...
                          'flow', 2*26700/(313*g0),...
                          'data', thrustProfile);
stage = struct('MODE', 1,...
               'm0', stage_m0,...
               'engines', stage_engines,...
               'maxT', 0,...
               'gLim', 0,...
               'area', stage_area,...
               'drag', stage_drag);
stage.maxT = vehicleTools('tgo', stage, 1, 8174+13486); %mass of MMH and N2O4 in OMS/RCS pods
vehicle(4) = stage;

clearvars orbiter payload thrustProfile
clearvars stage_m0 stage_time stage_area stage_drag stage_fuel stage_engines stage