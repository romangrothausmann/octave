#!/usr/bin/octave -q
##script to execute imRAG to get the neighbours of each or a specific label


####ToDo
## use narg > 2 to output neighbours of multiple labels

file_path = fileparts(mfilename('fullpath')); # https://stackoverflow.com/questions/50151829/how-do-i-get-the-current-script-path-in-gnu-octave#50151830
addpath([file_path "/../functions/"]); # https://octave.org/doc/v4.4.0/Concatenating-Strings.html
addpath([file_path "/../functions/imMeasures/"]);

function pairId = CantorPairing(x, y)
  x= uint64(x);  y= uint64(y); # https://www.gnu.org/software/octave/doc/interpreter/Integer-Arithmetic.html#Integer-Arithmetic
  pairId= (x+y).*(x+y+1)./2 + y; # .* and ./ to work with vector input
endfunction    

arg_list = argv ();
if nargin < 1
  fprintf(stderr, "Usage: %s <input3D.mha> [label]\n", program_name);
  fprintf(stderr, "Decompressing MHAs/MHDs is very slow!\n");
  exit(1)
else
  fprintf(stderr, "Reading 3D data from %s ...\n", arg_list{1});
  i3dInfo= mha_read_header(arg_list{1});#from ../functions/
  fprintf(stderr, "ElementSize: %f, %f, %f\n", i3dInfo.PixelDimensions);
  i3d= mha_read_volume(i3dInfo);#from ../functions/
  fprintf(stderr, "Reading done.\n", arg_list{1});
  fprintf(stderr, "Image size: %d %d %d\n", size(i3d))
endif

if ndims(i3d) ~= 3
  error('Image has to be 3D!');
end

ll= min(min(min(i3d)));
ul= max(max(max(i3d)));
fprintf(stderr, "Image value range: %d to %d\n", ll, ul);

n= imRAG(i3d); # excludes 0, gap= 1 pixel by default, only contains unique pairs, i.e. 1 2 but not 2 1
l= unique(n); # list of all appearing labels

## construct list: label, adj label, i.e. 1 2 and 2 1
a= n;
for j = 1:length(l)
  n= [n; a(a(:,2) == l(j), [2 1])]; # append rows whose second value equals l(i), swapped https://stackoverflow.com/a/4940630
end

if nargin == 2 # print neighbours of specific label i
  i= str2double(arg_list{2}); # should work upto flintmax("double")
  n= n(n(:,1) == i,:);
endif
printf("L1\tL2\tPairId\n")
printf("%d\t%d\t%d\n", horzcat(uint64(n), CantorPairing(n(:,1), n(:,2)))') # without uint64(n), concat as uint16
