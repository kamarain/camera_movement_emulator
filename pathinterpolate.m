function [newpath] = pathinterpolate(scanpath, mltpl);

pt = scanpath.points;
dir = scanpath.dirvecs;

origx = 1:size(pt,2);
intx = 1:(1/mltpl):size(pt,2);

pti = interp1(origx, pt', intx, 'pchip')';

angs = atan2(dir(2,:), dir(1,:));
ad = diff(angs);
for k = 1:length(ad)
	if ad(k)<-pi
		angs((k+1):end) = angs((k+1):end) + 2*pi;
		ad = diff(angs);
	end
	if ad(k)>pi
		angs((k+1):end) = angs((k+1):end) - 2*pi;
		ad = diff(angs);
	end
end
angsi = interp1(origx, angs, intx, 'pchip');
diri = [cos(angsi); sin(angsi)];

newpath = struct(...
	'points', pti, ...
	'dirvecs', diri ...
	);

