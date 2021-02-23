% SENSOREXPOSE - given an optical image, compute sensor array response
%
% sensim = sensorexpose(opticim, sensor)
% [sensim, newT] = sensorexpose(opticim, sensor, origT)
%
% opticim     optical image,  height x width x color channels
% sensor      sensor struct, see below
% origT       coordinate transform matrix, as returned from evex_imtrans().
% newT        new coordinate transform matrix, accounting for sensorexpose.
%
% sensor struct
% - size     array size in pixels [width, height]
% - pixloc   pixel photosensitive area top left corner, [0..1, 0..1]
% - pixarea  pixel photosensitive area size, [0..1, 0..1]
% - cmask    color masking elements
%
% Color masking elements:
%  cmask is an array of size N x M x C, where
%    - C must be equal to optical image channels
%    - height of optical image must be multiple of N
%    - width of optical image must be multiple of M
%  Usually cmask contains logical values denoting which channel is
%  preserved for which pixel, i.e. to realize a Bayer mask.
%  The returned image has the same channels as optical image, but
%  pixels are multiplied by cmask(n,m,:).
%  cmask can be empty to avoid applying it.

function [sensim, newT] = sensorexpose(opticim, sensor, origT, imarea);

if any( [sensor.pixloc sensor.pixarea] < 0 )
	error('negative photosensitive area parameter');
end

if any( (sensor.pixloc + sensor.pixarea) > 1 )
	error('photosensitive area out of pixel bounds');
end

[cmaskw, cmaskh, cmaskch] = size(sensor.cmask);
if cmaskw > 0 && any( mod(sensor.size, [cmaskw, cmaskh]) ~= 0 )
	error(['sensor array size is not a multiple of color' ...
	       ' masking element size']);
end

if nargin < 4
	imarea = [0.5 size(opticim,1)+0.5 0.5 size(opticim,2)+0.5];
end

chs = size(opticim, 3);
h = imarea(2) - imarea(1);
w = imarea(4) - imarea(3);
[sw sh schs] = deal(sensor.size(1), sensor.size(2), size(sensor.cmask, 3));

if cmaskw > 0 && chs ~= schs
	error('color planes mismatch');
end

dx = w/sw;
dy = h/sh;
sensim = zeros(sh, sw, chs);

offx = -1+sensor.pixloc(1)+[0; sensor.pixarea(1)];
offy = -1+sensor.pixloc(2)+[0; sensor.pixarea(2)];
x = 1:sensor.size(1);
y = 1:sensor.size(2);
lrmat = 0.5 + ( repmat(x, 2, 1) + repmat(offx, 1, size(x,2)) )'.*dx;
tbmat = 0.5 + ( repmat(y, 2, 1) + repmat(offy, 1, size(y,2)) )'.*dy;

for y = 1:sensor.size(2)
	tb = tbmat(y,:);
	tbf = round(tb);

	for x = 1:sensor.size(1)
		lr = lrmat(x,:);
		
		% round() tells through which pixel the border goes
		% pixel range, including partial pixels
		lrf = round(lr);
		
		% create weight mask
		masksz = [ tbf(2)-tbf(1)+1, lrf(2)-lrf(1)+1 ];
		mask = ones(masksz);
		mask(1, :) = mask(1, :) .* (tbf(1)-tb(1)+0.5);
		mask(masksz(1), :) = mask(masksz(1), :) .* (tb(2)-tbf(2)+0.5);
		mask(:, 1) = mask(:, 1) .* (lrf(1)-lr(1)+0.5);
		mask(:, masksz(2)) = mask(:, masksz(2)) .* (lr(2)-lrf(2)+0.5);
		
		if lrf(2) > size(opticim, 2)
			lrf(2) = size(opticim, 2);
			mask = mask(:, 1:(end-1));
		end
		if tbf(2) > size(opticim, 1)
			tbf(2) = size(opticim, 1);
			mask = mask(1:(end-1), :);
		end
		
		% integrate
		n = sum(mask(:));
		farea = opticim(tbf(1):tbf(2), lrf(1):lrf(2), :);
		for ch = 1:size(farea,3)
			farea(:,:,ch)= farea(:,:,ch) .* mask;
		end
		fsum = sum( sum(farea, 1), 2);
		
		sensim(y, x, :) = fsum./n;
	end
end

if cmaskw > 0
	sensim = sensim .* repmat(sensor.cmask, sensor.size(2)/cmaskh, ...
	                          sensor.size(1)/cmaskw);
end

sensim(sensim<0) = 0;
sensim(sensim>1) = 1;

if (nargin > 2) && (nargout > 1)
	newT = [1/dx 0 -0.5/dx+0.5; ...
	        0 1/dy -0.5/dy+0.5; ...
		0 0 1] * origT;
end

