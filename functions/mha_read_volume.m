function V = mha_read_volume(info)
% Function for reading the volume of a Insight Meta-Image (.mha, .mhd) file
% 
% from: http://www.mathworks.com/matlabcentral/fileexchange/29344-read-medical-data-3d/content//mha/mha_read_volume.m
% for zlib compression with java see e.g. http://www.mathworks.com/matlabcentral/fileexchange/8899-rapid-lossless-data-compression-of-numerical-or-string-variables/content//dunzip.m
% volume = tk_read_volume(file-header)
%
% examples:
% 1: info = mha_read_header()
%    V = mha_read_volume(info);
%    imshow(squeeze(V(:,:,round(end/2))),[]);
%
% 2: V = mha_read_volume('test.mha');

if(~isstruct(info)), info=mha_read_header(info); end


switch(lower(info.DataFile))
    case 'local'
    otherwise
    % Seperate file
    info.Filename=fullfile(fileparts(info.Filename),info.DataFile);
end
        
% Open file
switch(info.ByteOrder)
    case ('true')
        fid=fopen(info.Filename,'rb','ieee-be');
    otherwise
        fid=fopen(info.Filename,'rb','ieee-le');
end

switch(lower(info.DataFile))
    case 'local'
        % Skip header
        fseek(fid,info.HeaderSize,'bof');
    otherwise
        fseek(fid,0,'bof');
end

switch(info.CompressedData(1))
    case 'f'
        % Read the Data
        switch(info.DataType)
            case 'char'
              V = fread(fid,'*int8'); 
            case 'uchar'
              V = fread(fid,'*uint8'); 
            case 'short'
              V = fread(fid,'*int16'); 
            case 'ushort'
              V = fread(fid,'*uint16'); 
            case 'int'
              V = fread(fid,'*int32'); 
            case 'uint'
              V = fread(fid,'*uint32'); 
            case 'long'
              V = fread(fid,'*int64'); 
            case 'ulong'
              V = fread(fid,'*uint64'); 
            case 'float'
              V = fread(fid,'*float32');   
            case 'double'
              V = fread(fid,'*float64');
        end
    case 't'
        switch(info.DataType)
            case 'char', DataType='int8';
            case 'uchar', DataType='uint8';
            case 'short', DataType='int16';
            case 'ushort', DataType='uint16';
            case 'int', DataType='int32';
            case 'uint', DataType='uint32';
            case 'long', DataType='int64';
            case 'ulong', DataType='uint64';
            case 'float', DataType='single';
            case 'double', DataType='double';
        end
        V = zlib_decompress(info.Filename,info.HeaderSize,DataType,info.ByteOrder(1));

end
fclose(fid);
V = reshape(V,info.Dimensions);

function M = zlib_decompress(fname,hsize,DataType,BO)
a= javaObject('java.io.FileInputStream', fname);#replacement for java.io.ByteArrayInputStream(Z);
a.skip(hsize);
b= javaObject('java.util.zip.InflaterInputStream', a);

##BEGIN: replacement for com.mathworks.mlwidgets.io.InterruptibleStreamCopier copyStream(b,c);
ba=uint8([]); #avoiding jByteArray, works, but very slow
while ((n = b.read()) >= 0)
  ba(end+1)= n;
end
##END: replacement for com.mathworks.mlwidgets.io.InterruptibleStreamCopier

b.close();
a.close();

if(BO == 't')
  if(strcmp(DataType,'single'))
    ba=swapbytes(typecast(ba,'uint32'));#workaround for swapbytes(single())
    M=typecast(ba,DataType);
  else
    M=swapbytes(typecast(ba,DataType));
  endif
else
  M=typecast(ba,DataType);
endif
