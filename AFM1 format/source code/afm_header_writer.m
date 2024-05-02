%% open mrc file
f = fopen("test.mrc", "w");

%% write the header
% write Word 1-56
ss = struct2cell(s);
for i = 1:numel(ss)-1
    value = cell2mat(ss(i));
    for j = 1:numel(value)
        a = value(j);
        fwrite(f, a, class(value));
    end
end

% write Word 57-256 10 * 80 char text labels
value = cell2mat(ss(end));
for j = 1:10
    a = value(j, :);
    fwrite(f, a, class(value));
end
%% write the volume data
a = reshape(P, [s.NC*s.NR*s.NS, 1]);
fwrite(f, a, '*float32');
"done"

%% close mrc file
fclose(f);