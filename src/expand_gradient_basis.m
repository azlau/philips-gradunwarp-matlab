function [F_x, F_y, F_z] = expand_gradient_basis(r, theta, phi, config_name)
% Expand gradient basis using gradient calibration info
%
% inputs: r, theta, phi = N-dimensional array, same size
% config_name = gradient parameters, default = 'GCT_WA_MRL'
% outputs:
%   F_x, F_y, F_z: expand gradient basis using coefficients

s = size(r);
F_x = 0*r;
F_y = 0*r;
F_z = 0*r;

if nargin < 4
    config_name = 'GCT_WA_MRL';
end

config = gradient_config();
data = config.(config_name);

coeffs_x = sph_coeff_vec2mat(data.gx_field_c_coeffs, 'x');
coeffs_y = sph_coeff_vec2mat(data.gy_field_s_coeffs, 'y');
coeffs_z = sph_coeff_vec2mat(data.gz_field_c_coeffs, 'z');

ref_x = data.gx_ref_radius;
ref_y = data.gy_ref_radius;
ref_z = data.gz_ref_radius;

norm_x = ref_x / coeffs_x(2,2);
norm_y = ref_y / coeffs_y(2,2);
norm_z = ref_z / coeffs_z(2,1);

coeffs_x = coeffs_x * norm_x;
coeffs_y = coeffs_y * norm_y;
coeffs_z = coeffs_z * norm_z;

% legendre order for each axis
n_x = size(coeffs_x, 1) - 1;
n_y = size(coeffs_y, 1) - 1;
n_z = size(coeffs_z, 1) - 1;

n = n_x;
assert(n == n_x);
assert(n == n_y);
assert(n == n_z);

n_odd = 1:2:n;

% Loop over legendre n, then for each axis, select
% the non-zero m values.
for ix = 1:numel(n_odd)
    nn = n_odd(ix);
    [Yc, Ys] = real_solid_harmonic(nn, r, theta, phi);
    
    % index into coeffs_x:

    % index into odd m and current (odd) n; see below
    index_m_odd = 2:2:nn+1;
    index_nn = nn + 1;

    % select coefficients for odd n, odd m:
    c_x = coeffs_x(index_nn, index_m_odd).';
    c_y = coeffs_y(index_nn, index_m_odd).';
    % select coefficients for odd n, m=0 (for axis=z):
    c_z = coeffs_z(index_nn, 1);

    % calculate increment for X: (this is c * Yc, summed over m, for the current n)
    inc_x = sum(bsxfun(@times, c_x, Yc(index_m_odd, :)), 1) / ref_x^nn;
    inc_x = reshape(inc_x, s);
    F_x = F_x + inc_x;

    inc_y = sum(bsxfun(@times, c_y, Ys(index_m_odd, :)), 1) / ref_x^nn;
    inc_y = reshape(inc_y, s);
    F_y = F_y + inc_y;

    inc_z = sum(bsxfun(@times, c_z, Yc(1, :)), 1) / ref_x^nn;
    inc_z = reshape(inc_z, s);
    F_z = F_z + inc_z;
end


% for each n, calculate basis
% retrieve basis functions for those n which are non zero ...
% [Yc, Ys] = real_solid_harmonic(n, r, theta, phi);


% (...) in the below is a linear combination of terms
% of the form
%
% (r/r0)^n * P(n,m)(cos(theta)) * cos(m*phi)
% (r/r0)^n * P(n,m)(cos(theta)) * sin(m*phi)

% Bx = (r0/C[1,1]) * (...);
% By = (r0/S[1,1]) * (...);
% Bz = (r0/C[1,0]) * (...);

        % X:
        % // coeffs are filled using the following scheme:
        % // C(1,1), C(3,1), C(3,3),
        % // C(5,1), C(5,3), C(5,5),
        % // C(7,1), C(7,3), C(7,5),
        % // C(7,7), C(9,1), C(9,3), ...

        % Y:
        % // coeffs are filled using the following scheme:
        % // S(1,1), S(3,1), S(3,3),
        % // S(5,1), S(5,3), S(5,5),
        % // S(7,1), S(7,3), S(7,5),
        % // S(7,7), S(9,1), S(9,3), ...

        % Z:
        % // coeffs are filled using the following scheme:
        % // C(1,0), C(3,0), C(5,0),
        % // C(7,0), ...

