#!/usr/bin/octave -q
##script to execute imEuler3d from http://in.mathworks.com/matlabcentral/fileexchange/33690-geometric-measures-in-2d-3d-images


####ToDo
## check only once if label actually exists and store result for use in j-loop

addpath ("~/octave/imMinkowski/");

function pairId = CantorPairing(x, y)
  pairId= (x+y)*(x+y+1)/2 + y;
endfunction    

arg_list = argv ();
if nargin != 1
  fprintf(stderr, "Usage: %s <input3D.mha>\n", program_name);
  fprintf(stderr, "Decompressing MHAs/MHDs is very slow!\n");
  exit(1)
else
  fprintf(stderr, "Reading 3D data from %s ...\n", arg_list{1});
  i3dInfo= mha_read_header(arg_list{1});#from ~/octave/functions/
  fprintf(stderr, "ElementSize: %f, %f, %f\n", i3dInfo.PixelDimensions);
  i3d= mha_read_volume(i3dInfo);#from ~/octave/functions/
  fprintf(stderr, "Reading done.\n", arg_list{1});
  fprintf(stderr, "Image size: %d %d %d\n", size(i3d))
  # if nargin == 2
  #   if (arg_list{2} == "-q")
  #     quiet= 1;
  #   endif
  # endif
endif

if ndims(i3d) ~= 3
  error('Image has to be 3D!');
end

ll= min(min(min(i3d)));
ul= max(max(max(i3d)));
fprintf(stderr, "Image value range: %d to %d\n", ll, ul);

printf("PairId\tL1\tL2\tjointSurf\n")

for i= ll:ul-1
  if isempty(find(i3d == i, 1)) #check if label value actually exists in i3d
    fprintf(stderr, "%d not found, skipping.\n", i);
    continue
  endif

  fprintf(stderr, "Evaluating adjacencies of label %d...\n", i);
       
  for j= i+1:ul
    if isempty(find(i3d == j, 1)) #check if label value actually exists in i3d
      fprintf(stderr, "%d not found, skipping.\n", i);
      continue
    endif

    printf("%d\t%d\t%d\t%f\n", CantorPairing(i, j), i, j, imJointSurface(i3d, i, j, 13, i3dInfo.PixelDimensions'))
    fprintf(stderr, "%d\t%d\t%d\t%f\n", CantorPairing(i, j), i, j, imJointSurface(i3d, i, j, 13, i3dInfo.PixelDimensions'))
  end
end



