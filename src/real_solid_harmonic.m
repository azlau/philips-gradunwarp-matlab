function [Yc, Ys] = real_solid_harmonic(n, r, theta, phi)
% returns a [n+1, size(r)] matrix containing coefficients
%
% legendre(n, x) == scipy.special.lpmv(m, n, x)
% legendre(n,x) returns a [n+1, size(x)] matrix containing all L_m,n coefficients for m=0...n.

m = (0:n)';

L = legendre(n, cos(theta));

% remove Condon-Shortley phase
L = bsxfun(@times, L, (-1).^m);

nd = ndims(phi);
mphi = bsxfun(@times, m, permute(phi, [nd+1, 1:nd]));
cos_mphi = cos(mphi);
sin_mphi = sin(mphi);

r = permute(r, [nd+1, 1:nd]);

Yc = bsxfun(@times, bsxfun(@times, r.^n, cos_mphi), L);
Ys = bsxfun(@times, bsxfun(@times, r.^n, sin_mphi), L);

end
