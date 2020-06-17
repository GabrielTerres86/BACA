-- Created on 28/04/2020 by T0032613 
declare 
  -- Local variables here
  i integer;
  
  -- Buscar todas propostas com dtsolici nulas para atualizar
  CURSOR cr_propostas_dtsolici IS
     SELECT w.dtlibera
            ,w.cdcooper
            ,w.nrdconta
            ,w.nrctrcrd
       FROM crawcrd w 
      WHERE w.insitcrd = 4 
        AND w.dtpropos < to_date('29/04/2020', 'DD/MM/RRRR') 
        AND w.dtlibera IS NOT NULL
        AND w.dtsolici IS NULL;
begin
  -- Test statements here
  
  FOR rw_dados IN cr_propostas_dtsolici LOOP
      BEGIN
         UPDATE crawcrd w
            SET w.dtsolici = rw_dados.dtlibera
          WHERE w.cdcooper = rw_dados.cdcooper
            AND w.nrdconta = rw_dados.nrdconta
            AND w.nrctrcrd = rw_dados.nrctrcrd;
      EXCEPTION    
        WHEN OTHERS THEN    
          ROLLBACK;        
          raise_application_error(-20101, 'Erro ao alterar registro: Cooperativa: '||rw_dados.cdcooper||' Conta:' || rw_dados.nrdconta ||' Proposta: ' || rw_dados.nrctrcrd);        
          
      END;
      
  END LOOP;
  
  COMMIT;  
end;