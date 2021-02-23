function plotdirvec(p, d, l, mark);
p2 = p + d.*l;
for k = 1:size(p,2)
	plot([p(1,k) p2(1,k)], [p(2,k) p2(2,k)], mark);
end
