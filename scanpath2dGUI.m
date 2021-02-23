function scanpath = scanpath2dGUI(img, varargin);

defconf = struct(...
	'initcenter', 0 ...
	);
conf = getargs(defconf, varargin);

[pt, dir] = inputpathGUI(img, conf.initcenter);

scanpath = struct(...
	'points', pt, ...
	'dirvecs', dir ...
	);


function [pt, dir] = inputpathGUI(img, initcenter);
image(img);
pt = [];
dir = [];
hold on
if initcenter
	pt = [0.5+size(img,2)/2; 0.5+size(img,1)/2];
	dir = [0; -1];
	plot(pt(1), pt(2), 'go');
	plotdirvec(pt, dir, 50, 'g-');
end
while 1;
	[x, y] = ginput(1);
	if isempty(x)
		break;
	end
	plot(x, y, 'ro');
	[a, b] = ginput(1);
	if isempty(a)
		break;
	end
	d = dirvec([x; y], [a; b]);
	plotdirvec([x; y], d, 50, 'g-');
	pt(:, end+1) = [x; y];
	dir(:, end+1)= d(:);
end
hold off



function d = dirvec(p1, p2);
d = (p2-p1) ./ norm(p2-p1);

