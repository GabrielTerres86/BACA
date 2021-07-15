DECLARE

  vr_data       DATE;
   
BEGIN

  vr_data:= to_date('22/04/2021 14:31:39','DD/MM/YYYY hh24:mi:ss');
  
  -- Atualizar apenas um registro
  UPDATE tbcc_portabilidade_recebe t 
     SET t.idsituacao = 5 
       , t.dsdominio_motivo = 'MOTVCANCELTPORTDDCTSALR'
       , t.cdmotivo = '1'
       , t.dtretorno = vr_data
       , t.nmarquivo_solicitacao = 'APCS106_05463212_20210422_00061'
   WHERE t.nrnu_portabilidade = 202104220000183741932;
  
  -- Eliminar o log do erro.
  DELETE tbcc_portabilidade_rcb_erros 
   WHERE nrnu_portabilidade = 202104220000183741932;
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
END;
