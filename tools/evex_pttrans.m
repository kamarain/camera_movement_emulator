%EVEX_PTTRANS - 2D homogeneous transformation of points.
%
% trpt = evex_pttrans(T, orpt)
%
% 'orpt' - N point coordinates in 2xN or 3xN matrix
% 'T'    - transformation matrix from source to target coordinates
% 'trpt' - N point coordinates in matrix with the same size as 'orpt'
%
% The coordinates are 2D, the 3rd input coordinate will be assumed 1 if
% not given, and the 3rd output coordinate will be scaled to 1.
%
% Essentially computes: trpt = T * orpt
%
% evex_pttrans will return real numbers. If you need to convert them
% to matrix indices (integers), use round().
% See the Image Coordinate Reference in evex_imtrans.
%
% See: evex_affinemat, evex_imtrans

%  Peter Kovesi
%  School of Computer Science & Software Engineering
%  The University of Western Australia
%  pk @ csse uwa edu au
%  http://www.csse.uwa.edu.au/~pk
%
%  April 2000
%
% Pekka Paalanen, pekka.paalanen@lut.fi
%  November 2004 - see the CVS log for changes.

% $Id: evex_pttrans.m,v 1.4 2004/11/30 08:44:50 paalanen Exp $

function t = evex_pttrans(P,v);

outsize = 3;
if size(v,1) == 2
	v = [v; ones(1, size(v,2))];
	outsize = 2;
end

t = P*v;
t(1,:) = t(1,:)./t(3,:);   %  Now normalise
t(2,:) = t(2,:)./t(3,:);
t(3,:) = ones(1,size(v,2));

t = t(1:outsize, :);
