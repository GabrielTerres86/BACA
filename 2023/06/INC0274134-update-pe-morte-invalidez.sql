begin
  
update cecred.tbseg_prestamista
   set pemorte = 0.46410300,
       peinvalidez = 0.02589700
 where nrproposta IN ('202305311243');
 
commit;
end; 