DECLARE

  -- Buscar portabilidades com retorno pendente
  CURSOR cr_portab IS 
    SELECT ROWID dsdrowid
      FROM tbcc_portabilidade_envia t 
     WHERE t.nrnu_portabilidade IS NOT NULL       -- Tem código de portabilidade
       AND t.idsituacao           = 2             -- Solicitada
       AND TRUNC(t.dtsolicitacao) = '23/10/2020'; -- Data de solicitação
   
BEGIN
  
  FOR reg IN cr_portab LOOP
  
    UPDATE tbcc_portabilidade_envia t
       SET t.idsituacao        = 3 -- Aprovada
         , t.dsdominio_motivo  = 'MOTVACTECOMPRIOPORTDDCTSALR'
         , t.cdmotivo          = 1
         , t.dtretorno         = to_date('09/11/2020 04:51:00','dd/mm/yyyy hh24:mi:ss')
         , t.nmarquivo_retorno = 'APCS108_05463212_20201106_00082'
     WHERE ROWID = reg.dsdrowid;
     
  END LOOP;
  
  COMMIT;
  
END;
