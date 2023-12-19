BEGIN 

    UPDATE cecred.tbseg_parametros_prst p
       SET p.dtinivigencia = to_date('01/11/2023','dd/mm/yyyy'),
		   p.dtfimvigencia = to_date('27/11/2054','dd/mm/yyyy'),
		   p.dtctrmista = to_date('01/11/2023','dd/mm/yyyy')
     WHERE p.idseqpar = 1012;
    
	UPDATE cecred.tbseg_parametros_prst p
       SET p.dtinivigencia = to_date('31/10/2023','dd/mm/yyyy')
     WHERE p.idseqpar = 13;
	
    COMMIT;
END;
