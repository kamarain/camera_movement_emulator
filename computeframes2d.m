function M = computeframes2d(img, scanpath, opti, sensor, outfmt);

imarea = sensor.size .* opti.interpf ./ opti.magn ./ 2;
offs = [-imarea(1) -imarea(2)] - 0.5;
imareai = [-imarea(2) imarea(2) -imarea(1) imarea(1)] - ...
	[offs(2) offs(2)+1 offs(1) offs(1)+1];

fr = 1;
M = {};
wbh = waitbar(0, 'computing frames');
for k = 1:length(scanpath.points);
	T = trans2mat( scanpath.points(:,k), ...
	      atan2(scanpath.dirvecs(2,k), scanpath.dirvecs(1,k))+pi/2, ...
	      opti.interpf, offs );
	[nim, newT] = evex_imtrans(img, T, 'outregion', round(imareai), ...
	                   'outfmt', 'double', 'interp', '*nearest', ...
			   'pxlimit', 1e8);
	nim(isnan(nim)) = 0;
	[sim, sensT] = sensorexpose(nim, sensor, newT);
	
	fname = sprintf(outfmt, k);
	imwrite(sim, fname, 'PPM');
	
	M{fr} = struct('image', fname, 'tempT', newT, ...
	               'origT', T, 'outreg', imarea, ...
		       'sensorT', sensT);
	fr = fr+1;
	waitbar(k/length(scanpath.points), wbh);
end
close(wbh);
