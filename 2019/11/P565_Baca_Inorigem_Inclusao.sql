DECLARE
 --/
 BEGIN
   --/
	UPDATE gnconve g
      SET g.cdcooper = 1  
    WHERE g.cdconven IN (120,121);
	
	update gnconve 
         set inorigem_inclusao = 3
    where cdconven in(15,30,82);
	
	update gnconve g
		set g.dsccdrcb = REPLACE(g.dsccdrcb,' ')
	WHERE g.cdconven IN (4,68);

   --/
   COMMIT;  
END;
