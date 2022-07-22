function [m] = sph_coeff_vec2mat(v, axis)
% sph_coeff_vec2mat
%   convert spherical coefficient vector to a lower triangular matrix containing coefficients, indexed as M[n,m]. 
% For axis = 'x' and 'z', these are the cosine coefficients, and for axis = 'y', these are the sine coefficients.
% i.e., M[n,m] is the coefficient of 
%   r^n * cos(m*phi) * L(m,n,cos(theta)) * (-1)^m
%   r^n * sin(m*phi) * L(m,n,cos(theta)) * (-1)^m
%
%   inputs: v = vector, axis = {'x', 'y', 'z'}
%   outputs: matrices. c[n,m] = coefficents.

    switch axis
        case {'x', 'y'}
            n = (-1 + sqrt(1+8*numel(v)))/2;
        case 'z'
            n = numel(v);
    end

    m = zeros(n,n);

    switch axis
        case {'x', 'y'}
            % set lower triangular part to v
            ix = find(triu(ones(n)));
            m(ix) = v;
            m = m.';

            % fill zeros
            m = kron(m, [0 0; 0 1]);

        case 'z'
            m(:, 1) = v;
            m = kron(m, [0 0; 1 0]);
    end


end
