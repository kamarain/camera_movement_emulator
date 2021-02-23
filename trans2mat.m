% trans2mat  - create 3x3 transformation matrix from parameters
%
% T = trans2mat(t, alpha, s, pt)
%
% t      translation, 2-vector, required
% alpha  rotation angle, scalar, optional, default 0
% s      scale factor, scalar or 2-vector, optional, default 1
% pt     post-translation, optional, default [0; 0]
% T      the resulting homogenous transformation matrix
function T = trans2mat(t, alpha, s, pt);

if nargin < 4
	pt = [0; 0];
end

if nargin < 3
	s = [1; 1];
end
if nargin < 2
	alpha = 0;
end
if length(s) < 2
	s = [s; s];
end

a = [sin(alpha) cos(alpha)];
R = [a(2) a(1) 0;
     -a(1) a(2) 0;
     0 0 1];

tr = [1 0 -t(1);
      0 1 -t(2);
      0 0 1];

S = [s(1) 0 0;
     0 s(2) 0;
     0 0 1];

ptr = [1 0 -pt(1);
       0 1 -pt(2);
       0 0 1];

T = ptr * S * R * tr;
