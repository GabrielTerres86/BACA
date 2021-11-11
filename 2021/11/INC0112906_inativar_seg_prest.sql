begin
 UPDATE crapseg p 
         SET p.cdsitseg = 2
       WHERE p.progress_recid = 610106;  
commit;
end;