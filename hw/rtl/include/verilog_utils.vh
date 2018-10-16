function integer clog2;
input integer in;
begin
   in = in - 1;
   for (clog2 = 0; in > 0; clog2 = clog2+1)
      in = in >> 1;
end
endfunction
