begin
  update craptel c
     set c.cdopptel = c.cdopptel||',N'
       , c.lsopptel = c.lsopptel||',ALT. OUTROS'
   where upper(c.nmdatela) = 'HISTOR';
  
  commit;
end;
