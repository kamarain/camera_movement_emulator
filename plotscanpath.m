function plotscanpath(scanpath);

hoo = ishold;
plot(scanpath.points(1,:), scanpath.points(2,:), 'bo');
hold on
plotdirvec(scanpath.points, scanpath.dirvecs, 20, 'r-');
if ~hoo
	hold off
end
