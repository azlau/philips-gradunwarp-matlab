# philips-gradunwarp-matlab

Matlab implementation of Philips gradient nonlinearity correction

Angus Lau (angus.lau@sri.utoronto.ca)

Please let me know if you see any bugs, thanks!

## install

### Dependencies:
* FSL (for applywarp): https://fsl.fmrib.ox.ac.uk/fsl/fslwiki
* matlab nii reader: https://github.com/xiangruili/dicm2nii

### matlab
* add `src` to path

## usage

```matlab
filename_distorted = 'distorted.nii.gz';
filename_unwarped = 'unwarped.nii.gz';

nii = nii_tool('load', filename_distorted);

nii_unwarped = gradient_unwarp(nii, 'GCT_WA_MRL');

% save output
nii_tool('save', filename_unwarped);
```

## Notes:

The gradient spherical harmonic coefficients are taken from the Philips file `methpdf/src/mpghw_gr.res`. An example is shown for the MR-Linac gradient called `GCT_WA_MRL`. For a different scanner, find the appropriate gradient set and update the parameters in `src/config/gradient_config.m`. Alternatively, the coefficients can be extracted from the header of the raw data file.
