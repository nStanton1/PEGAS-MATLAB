initSimulation

Ariane5

site = createLaunchSite('Kourou');

%alt = 300;
inc = 5;
[lan, azm, target] = launchTargeting(site, 250, 35943, inc, 2.5);

stage1 = struct('type', 0, 'pitch', 5, 'velocity', 65, 'azimuth', azm);

AV5 = flightManager(vehicle, site, target, 0.2, stage1, 2, 5, []);

telemetry(AV5.powered, AV5.coast, 1);
dbgIntegrals(AV5.powered(2:AV5.n), 2);
trajectory(AV5.powered, AV5.coast, target, 2, 1, 3);

clearvars site alt inc lan azm target stage1