function [result_table] = generate_stats_int(table)

data_to_write = table2array(table);

%Write data to files

%.csv
tic
writetable(table,"data/dat.csv")
csv_write_time = toc;
%.Parquet
tic
parquetwrite("data/dat.parquet", table)
parquet_write_time =toc;
%.H5
tic
h5filename = "data/dat.h5";
if exist(h5filename)
    delete(h5filename)
end

h5create(h5filename, "/table", size(data_to_write),"Datatype",class(data_to_write))
h5write(h5filename, "/table", data_to_write)

h5_write_time = toc;
%h5disp(h5filename)

%.NC
tic
filename = "data/dat.nc";
if exist(filename)
    delete(filename)
end


nccreate(filename, "table", "Dimensions",{"table", length(data_to_write)}, 'Datatype', class(data_to_write), 'Format', 'netcdf4')
ncwrite(filename, "table", data_to_write)

nc_write_time =toc;
%ncdisp(filename)



%Read timing
%.csv
tic
readtable("data/dat.csv");
csv_read_time = toc;
%.parquet
tic
parquetread("data/dat.parquet");
parquet_read_time = toc;

%.h5
tic
h5read("data/dat.h5","/table");
h5_read_time = toc;
%.nc
tic
ncread("data/dat.nc","table");
nc_read_time = toc;

%Agreggate Performance Statistics
[i]= dir("data/dat*");i_table=struct2table(i);
result_table =i_table(:, ["name", "bytes"]);
write_times = [csv_write_time, h5_write_time, nc_write_time, parquet_write_time]';
read_times = [csv_read_time, h5_read_time, nc_read_time, parquet_read_time]';
result_table.write_time = write_times;
result_table.read_time = read_times;

end