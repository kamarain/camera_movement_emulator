% DEMO_INTERACTIVE Interactive demo of the camera emulator
%

% Run the config 
if ~exist('demo_interactive_conf.m','file')
  error(' Hint: Copy demo_interactive_conf.m.templ to demo_interactive_conf.m and run again!')
else
  fprintf('  Running the config script...\n')
  demo_interactive_conf
  confS
  fprintf('  done!\n')
end;


% Read given input image
img = double(imread(confS.input_image));

% Scale values to [0,1]
img = img./255;

% UI to acquire the scanning path
disp('Provide the scanning path as the pairs of image center and angle.')
disp('Each path point is two given as two points: image center and angle.')
disp('Starting point is always in the middle.');
disp('N points is interpolated between the start and stop points.');
disp('Longer distance between the intermediate points corresponds to faster camera movement.');
disp('Press <RETURN> to finish.');

h = figure;
inputpath = scanpath2dGUI(img, 'initcenter', 1);
close(h);

% Interpolate more points to scan path
disp('Interpolating a requested number of scan path points.');

scanpath = pathinterpolate(inputpath, confS.interp_frame_num);

% Show the interpolated points
figure;
image(img);
hold on
plotscanpath(scanpath);
hold off
drawnow;

disp('Some max and mean statistics of the interpolated points.');
trspeeds = sqrt(sum( diff(scanpath.points, 1, 2).^2, 1));
max_translation_speed = max(trspeeds)
mean(trspeeds)

angs = atan2(scanpath.dirvecs(2,:), scanpath.dirvecs(1,:));
angspeeds = abs(diff(angs)) * 180/pi;
angspeeds(angspeeds>180) = 360 - angspeeds(angspeeds>180);
max_angular_speed = max(angspeeds)
mean(angspeeds)
size(scanpath.points)

% Compute artificial frames using simulated camera 
disp('Generating video');

% Optical image settings
opti = struct(...
    'magn', confS.opti.base_pixel_magnification, ...
    'interpf', confS.opti.interp_factor ...
    );
	
% Camera settings
sensor = struct(...
    'size', configS.sensor.size, ...
    'pixloc', configS.sensor.pix_effective_area_offset, ...
    'pixarea', configS.sensor.pix_effective_area, ...
    'cmask', configS.sensor.color_mask );
	
tic
  M = computeframes2d(img, scanpath, opti, sensor, ...
                      fullfile(confS.frame_save_dir,'/f%04d.ppm'));
toc
drawnow;
force = true;

% Save all variables
save(fullfile(confS.frame_save_dir, '/vars.mat'))

return;

% BELOW SOME OLD CODE FOR REFERENCE

%dirname = 'out-imdev';

force_newimg = force;

if isempty(whos('basearea')) || force
	disp('Computing base area mask');
	tic;
	baseimscale = max(1, opti.magn);
	basearea = basemask(M, size(img), baseimscale);
	toc
	force = true;
end

if isempty(whos('baseimg')) || force
	disp('Forming base area image');
	baseimg = imgscale(img, baseimscale);
	for i = 1:size(baseimg,3)
		temp = baseimg(:,:,i);
		temp(~basearea) = 0;
		baseimg(:,:,i) = temp;
	end
	force = true;
	clear i temp
	
	save([dirname '/basetemp.mat']);
end


% ----------------------------------

rotstd = [ 0.01 0.05 0.1 0.5 1 5];
linetype = {'r-', 'g-', 'b-', 'r--','g--', 'b--'};

if isempty(whos('newimg')) || force_newimg
	tic
	disp('Composing mosaic');
	M = add2dnoise(M, 0, rotstd(testno));
	newimg = compose(size(img), M, 'usenoisy', 0, 'magn', opti.magn);
	nmosaic = imgscale(newimg, size(baseimg,2), size(baseimg,1));
	% contains NaN on undetermined areas
	toc
	force = true;
end

compare_images(nmosaic, baseimg, basearea, 'diffim', 1, ...
	'line', linetype{testno}, 'fig', 5, 'metric', 'RGB');

% b- 0.01
% g- 0.05
% r- 0.1
% b-- 0.5
% g-- 1
% r-- 5



