begin
  update craptel c
     set c.cdopptel = c.cdopptel||',S'
       , c.lsopptel = c.lsopptel||',PRM. SEGURADORAS'
   where upper(c.nmdatela) = 'HISTOR';
  
  commit;
end;