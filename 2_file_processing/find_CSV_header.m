function header = find_CSV_header(EBSDfilePathAndEBSDfileName)

fid = fopen(EBSDfilePathAndEBSDfileName);
C=textscan(fid,'%s','delimiter','\n');
C=C{1,1};
C=C{1,1};
fclose(fid);
remain = C;
ii = 1;
while length(remain)>0
    [header{ii}, remain] = strtok(remain,',');
    ii=ii+1;
end

end