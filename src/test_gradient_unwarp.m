config_name = 'GCT_WA_MRL';

if 1
in_nii_filename = 'uncorrected.nii.gz';
out_warp_filename = 'warp.nii.gz';
out_nii_filename  = 'corrected.nii.gz';
end

if 0
in_nii_filename = 'cor_uncorrected.nii.gz';
out_warp_filename = 'cor_warp.nii.gz';
out_nii_filename  = 'cor_corrected.nii.gz';
end

nii = nii_tool('load', in_nii_filename);
nii = gradient_unwarp(nii, config_name);
nii_tool('save', nii, out_nii_filename);
