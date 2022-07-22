function [r, theta, phi] = r_cart2sph(x,y,z)

    % r_cart2sph
    % for recon

    x2 = x.^2;
    y2 = y.^2;
    z2 = z.^2;

    r = sqrt(x2 + y2 + z2);
    phi = atan2(y, x);
    theta = atan2(sqrt(x2 + y2), z);
end
