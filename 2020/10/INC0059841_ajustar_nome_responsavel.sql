begin 
  update crapcrl c
     set c.nmrespon = 'MARCELINO CORDEIRO'
   where c.nrctamen = 11696915
     and c.cdcooper = 1;
  commit;
end;
