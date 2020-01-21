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
	
	UPDATE gnconve g
	SET g.intpconvenio = 2
		,g.inorigem_inclusao = 2
	WHERE g.cdconven in( 147,148,149,150);

   --/
   COMMIT;  
END;
