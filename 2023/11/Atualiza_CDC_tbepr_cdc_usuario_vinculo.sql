DECLARE
   
    vidusuario NUMBER := 141493;
	vidvendedor NUMBER := 137385;

BEGIN
		
	while vidusuario < 142096 LOOP
	
	    UPDATE CECRED.tbepr_cdc_usuario_vinculo
	    SET idvendedor = vidvendedor
	    WHERE idusuario = vidusuario;
	   
	   vidusuario := vidusuario + 1;
	   vidvendedor := vidvendedor + 1;
	  
	  COMMIT;
	  
	END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
	
END;
