-- Created on 01/07/2020 by F0030248 
-- Baca para atualizar a numeração de remessa de cobrança do cooperado
-- Conta 314820 / Transpocred
declare 
  -- Local variables here
  i integer;
  vr_max craprtc.nrremret%TYPE;
begin
  -- Test statements here
  SELECT MAX(nrremret)+1 INTO vr_max
    FROM craprtc
    WHERE cdcooper = 9
      AND nrdconta = 314820
     AND nrremret < 9999999;    
		 
  dbms_output.put_line('Conta 314820 / Transpocred');		  
  dbms_output.put_line('Numero de remessa a ser atualizado: ' || to_char(vr_max));		  	
     
  UPDATE craprtc SET nrremret = vr_max
    WHERE cdcooper = 9
     AND nrdconta = 314820
     AND nrremret = 9999999;
	
	dbms_output.put_line('craprtc = ' || to_char(SQL%ROWCOUNT) || ' atualizados');
     
  UPDATE crapcob SET nrremass = vr_max
   WHERE cdcooper = 9
      AND nrdconta = 314820 
     AND nrremass = 9999999;

	dbms_output.put_line('crapcob = ' || to_char(SQL%ROWCOUNT) || ' atualizados');		 
     
  UPDATE crapret SET nrremass = vr_max
   WHERE cdcooper = 9
      AND nrdconta = 314820 
     AND nrremass = 9999999;       
		 
	dbms_output.put_line('crapret = ' || to_char(SQL%ROWCOUNT) || ' atualizados');		 		 

  COMMIT;
	
	EXCEPTION WHEN OTHERS THEN
	
	ROLLBACK;
	dbms_output.put_line('Erro ao executar baca: ' || SQLERRM);
end;
