fileID = fopen('list.lst');
A = textscan(fileID,'%s %s %s');
A = cell2mat(A{1,3}(5:end));
sim_data = typecast(uint16(bin2dec(A)), 'int16');
fclose(fileID);
fileID = fopen('in_fix_filtered.txt');
B = textscan(fileID, '%d');
B = cell2mat(B);

clf
plot(sim_data)
hold on
plot(B, 'r')

