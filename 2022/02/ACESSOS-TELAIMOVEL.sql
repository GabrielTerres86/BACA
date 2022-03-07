DECLARE
  TYPE tp_varray IS VARRAY(50) OF VARCHAR2(10);
  vr_user tp_varray := tp_varray('f0050332',
								 'f0050058',
								 'f0050040',
								 'f0033715',
								 'f0033379',
								 'f0033210',
								 'f0033304',
								 'f0033328',
								 'f0033406');								 
BEGIN
  DELETE FROM crapace
   WHERE UPPER(crapace.nmdatela) = 'IMOVEL'          
     AND crapace.cdcooper <> 1;  
  COMMIT; 	 
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'F', vr_user(i), ' ', 5, 1, 0, 2);      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'A', vr_user(i), ' ', 5, 1, 0, 2);
	 
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'N', vr_user(i), ' ', 5, 1, 0, 2);
      	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'C', vr_user(i), ' ', 5, 1, 0, 2);
      	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'I', vr_user(i), ' ', 5, 1, 0, 2);
      	
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'P', vr_user(i), ' ', 5, 1, 0, 2);      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'L', vr_user(i), ' ', 5, 1, 0, 2);		
		      
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
	COMMIT;
  END LOOP;
  
  vr_user.delete;
  vr_user := tp_varray('f0130197',
					   'f0130474',
					   'f0130372',
					   'f0130495',
					   'f0130392',
					   'f0130035',
					   'f0130538',
					   'f0130479',
					   'f0130245',
					   'f0130405',
					   'f0033715',
					   'f0033379',
					   'f0033210',
					   'f0033304',
					   'f0033328',
					   'f0033406');								   
    
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'F', vr_user(i), ' ', 13, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'A', vr_user(i), ' ', 13, 1, 0, 2);
	
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'P', vr_user(i), ' ', 13, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'L', vr_user(i), ' ', 13, 1, 0, 2);	
		      
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
  END LOOP;
  
  vr_user.delete;
  vr_user := tp_varray('f0130188',
			    	   'f0130202',
			    	   'f0130035',
			    	   'f0130372',
			    	   'f0130118',
			    	   'f0130536',
			    	   'f0130197',
			    	   'f0130474',								 
			    	   'f0130495',
			    	   'f0130392',								 
			    	   'f0130538',
			    	   'f0130479',
			    	   'f0130245',
			    	   'f0130405',
			    	   'f0033715',
			    	   'f0033379',
			    	   'f0033210',
			    	   'f0033304',
			    	   'f0033328',
			    	   'f0033406');								   
  
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'N', vr_user(i), ' ', 13, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'C', vr_user(i), ' ', 13, 1, 0, 2);
      
	  
	  	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'I', vr_user(i), ' ', 13, 1, 0, 2);
      	 
		      
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
	COMMIT;
  END LOOP;
  
   
  vr_user.delete;
  vr_user := tp_varray('f0070451',
					   'f0070397',
					   'f0070079',
					   'f0070681',
					   'f0070686',
					   'f0070001',
					   'f0033715',
					   'f0033379',
					   'f0033210',
					   'f0033304',
					   'f0033328',
					   'f0033406');								   
  
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'F', vr_user(i), ' ', 7, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'A', vr_user(i), ' ', 7, 1, 0, 2);
		
		
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'P', vr_user(i), ' ', 7, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'L', vr_user(i), ' ', 7, 1, 0, 2);		
		      
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
  END LOOP;
  
  vr_user.delete;
  vr_user := tp_varray('f0070618',
					   'f0070686',
					   'f0070631',
					   'f0070451',
					   'f0070397',
					   'f0070079',
					   'f0070681',
					   'f0070001',
					   'f0033715',
					   'f0033379',
					   'f0033210',
					   'f0033304',
					   'f0033328',
					   'f0033406');								   
  
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'N', vr_user(i), ' ', 7, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'C', vr_user(i), ' ', 7, 1, 0, 2);
      
	  
	  	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'I', vr_user(i), ' ', 7, 1, 0, 2);
      	  
		      
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
	COMMIT;
  END LOOP;
  
  vr_user.delete;
  vr_user := tp_varray('f0080029',
					   'f0080195',
					   'f0033715',
					   'f0033379',
					   'f0033210',
					   'f0033304',
					   'f0033328',
					   'f0033406');								   
  
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'F', vr_user(i), ' ', 8, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'A', vr_user(i), ' ', 8, 1, 0, 2);
		

	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'P', vr_user(i), ' ', 8, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'L', vr_user(i), ' ', 8, 1, 0, 2);		
		      
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
  END LOOP;
  
  vr_user.delete;
  vr_user := tp_varray('f0080029',
					   'f0080195',
					   'f0080211',
					   'f0033715',
					   'f0033379',
					   'f0033210',
					   'f0033304',
					   'f0033328',
					   'f0033406');							   
  
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'N', vr_user(i), ' ', 8, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'C', vr_user(i), ' ', 8, 1, 0, 2);
      
	  
	  	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'I', vr_user(i), ' ', 8, 1, 0, 2);
      	  
		      
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
	COMMIT;
  END LOOP;
  
  vr_user.delete;
  vr_user := tp_varray('f0110357',
					   'f0110365',
					   'f0110478',
					   'f0110255',
					   'f0110243',
					   'f0110318',
					   'f0110595',
					   'f0110381',
					   'f0110008',
					   'f0110263',
					   'f0110320',
					   'f0033715',
					   'f0033379',
					   'f0033210',
					   'f0033304',
					   'f0033328',
					   'f0033406');								   
  
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'F', vr_user(i), ' ', 11, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'A', vr_user(i), ' ', 11, 1, 0, 2);
		
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'P', vr_user(i), ' ', 11, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'L', vr_user(i), ' ', 11, 1, 0, 2);		
		
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
  END LOOP;
  
  vr_user.delete;
  vr_user := tp_varray('f0110454',
					   'f0110470',
					   'f0110595',
					   'f0110357',
					   'f0110365',
					   'f0110478',
					   'f0110255',
					   'f0110243',
					   'f0110318',
					   'f0110595',
					   'f0110381',
					   'f0110008',
					   'f0110263',
					   'f0110320',
					   'f0033715',
					   'f0033379',
					   'f0033210',
					   'f0033304',
					   'f0033328',
					   'f0033406');							   
  
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'N', vr_user(i), ' ', 11, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'C', vr_user(i), ' ', 11, 1, 0, 2);
      
	  
	  	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'I', vr_user(i), ' ', 11, 1, 0, 2);
      	  
		
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
	COMMIT;
  END LOOP;
  
  vr_user.delete;
  vr_user := tp_varray('f0090424',
					   'f0090256',
					   'f0090190',
					   'f0090337',
					   'f0090534',
					   'f0090317',
					   'f0090585',
					   'f0090197',
					   'f0090407',
					   'f0090498',
					   'f0090540',
					   'f0033715',
					   'f0033379',
					   'f0033210',
					   'f0033304',
					   'f0033328',
					   'f0033406');								   
  
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'F', vr_user(i), ' ', 9, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'A', vr_user(i), ' ', 9, 1, 0, 2);
		
		
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'P', vr_user(i), ' ', 9, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'L', vr_user(i), ' ', 9, 1, 0, 2);
		
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
	COMMIT;
  END LOOP;
  
  vr_user.delete;
  vr_user := tp_varray('f0090546',
					   'f0090584',
					   'f0090396',
					   'f0090540',
					   'f0090482',
					   'f0090405',
					   'f0090238',
					   'f0090516',
					   'f0090378',
					   'f0090423',
					   'f0090424',
					   'f0090256',
					   'f0090190',
					   'f0090337',
					   'f0090534',
					   'f0090317',
					   'f0090585',
					   'f0090197',
					   'f0090407',
					   'f0090498',
					   'f0033715',
					   'f0033379',
					   'f0033210',
					   'f0033304',
					   'f0033328',
					   'f0033406');
					   
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'N', vr_user(i), ' ', 9, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'C', vr_user(i), ' ', 9, 1, 0, 2);
      
	  
	  	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'I', vr_user(i), ' ', 9, 1, 0, 2);
      	  
		
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
	COMMIT;
  END LOOP;
    
  vr_user.delete;
  vr_user := tp_varray('f0160198',
					   'f0160656',
					   'f0160262',
					   'f0160718',
					   'f0160017',
					   'f0160019',
					   'f0160351',
					   'f0160507',
					   'f0160255',
					   'f0160003',
					   'f0160039',
					   'f0160107',
					   'f0160062',
					   'f0160597',
					   'f0160595',
					   'f0160055',
					   'f0033715',
					   'f0033379',
					   'f0033210',
					   'f0033304',
					   'f0033328',
                       'f0033406');
					   
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'N', vr_user(i), ' ', 16, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'C', vr_user(i), ' ', 16, 1, 0, 2);
      
	  
	  	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'I', vr_user(i), ' ', 16, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'P', vr_user(i), ' ', 16, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'L', vr_user(i), ' ', 16, 1, 0, 2);
		
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'F', vr_user(i), ' ', 16, 1, 0, 2);      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'A', vr_user(i), ' ', 16, 1, 0, 2);	
		
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
	COMMIT;
  END LOOP;
  
  vr_user.delete;
  vr_user := tp_varray('f0060078',
					   'f0060259',
					   'f0033715',
					   'f0033379',
					   'f0033210',
					   'f0033304',
					   'f0033328',
					   'f0033406');
 
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'N', vr_user(i), ' ', 6, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'C', vr_user(i), ' ', 6, 1, 0, 2);
      
	  
	  	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'I', vr_user(i), ' ', 6, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'P', vr_user(i), ' ', 6, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'L', vr_user(i), ' ', 6, 1, 0, 2);
		
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'F', vr_user(i), ' ', 6, 1, 0, 2);      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'A', vr_user(i), ' ', 6, 1, 0, 2);	
		
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
	COMMIT;
  END LOOP;  
   
  vr_user.delete;
  vr_user := tp_varray('f0140178',
					   'f0140332',
					   'f0140175',
					   'f0033715',
					   'f0033379',
					   'f0033210',
					   'f0033304',
					   'f0033328',
					   'f0033406');

  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'N', vr_user(i), ' ', 14, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'C', vr_user(i), ' ', 14, 1, 0, 2);
      
	  
	  	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'I', vr_user(i), ' ', 14, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'P', vr_user(i), ' ', 14, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'L', vr_user(i), ' ', 14, 1, 0, 2);
		
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'F', vr_user(i), ' ', 14, 1, 0, 2);      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'A', vr_user(i), ' ', 14, 1, 0, 2);	
		
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
	COMMIT;
  END LOOP;
  
  vr_user.delete;
  vr_user := tp_varray('f0120064',
					   'f0120085',
					   'f0120179',
					   'f0033715',
					   'f0033379',
					   'f0033210',
					   'f0033304',
					   'f0033328',
					   'f0033406');
 
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'N', vr_user(i), ' ', 12, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'C', vr_user(i), ' ', 12, 1, 0, 2);
      
	  
	  	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'I', vr_user(i), ' ', 12, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'P', vr_user(i), ' ', 12, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'L', vr_user(i), ' ', 12, 1, 0, 2);
		
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'F', vr_user(i), ' ', 12, 1, 0, 2);      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'A', vr_user(i), ' ', 12, 1, 0, 2);	
		
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
	COMMIT;
  END LOOP;
    
  vr_user.delete;
  vr_user := tp_varray('f0100107',
					   'f0100213',
					   'f0100052',
					   'f0100231',
					   'f0033715',
					   'f0033379',
					   'f0033210',
					   'f0033304',
					   'f0033328',
					   'f0033406');

  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'N', vr_user(i), ' ', 10, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'C', vr_user(i), ' ', 10, 1, 0, 2);
      
	  
	  	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'I', vr_user(i), ' ', 10, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'P', vr_user(i), ' ', 10, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'L', vr_user(i), ' ', 10, 1, 0, 2);
		
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'F', vr_user(i), ' ', 10, 1, 0, 2);      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'A', vr_user(i), ' ', 10, 1, 0, 2);	
		
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
	COMMIT;
  END LOOP;
  
    
  vr_user.delete;
  vr_user := tp_varray('f0020460',
					   'f0020379',
					   'f0020471',
					   'f0020380',
					   'f0020295',
					   'f0020405',
					   'f0020661',
					   'f0020695',
					   'f0020403',
					   'f0033715',
					   'f0033379',
					   'f0033210',
					   'f0033304',
					   'f0033328',
					   'f0033406');

  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'N', vr_user(i), ' ', 2, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'C', vr_user(i), ' ', 2, 1, 0, 2);
      
	  
	  	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'I', vr_user(i), ' ', 2, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'P', vr_user(i), ' ', 2, 1, 0, 2);
      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'L', vr_user(i), ' ', 2, 1, 0, 2);
		
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'F', vr_user(i), ' ', 2, 1, 0, 2);      
	  
	  INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'A', vr_user(i), ' ', 2, 1, 0, 2);	
		     
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
	COMMIT;
  END LOOP;
      
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;	   