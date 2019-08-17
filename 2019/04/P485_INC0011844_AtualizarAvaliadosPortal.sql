BEGIN
  
  UPDATE tbcc_portabilidade_recebe t
     SET t.dtavaliacao        = to_date('30012019','ddmmyyyy')
       , t.dtretorno          = to_date('30012019','ddmmyyyy')
       , t.nmarquivo_resposta = 'RESPOSTA VIA PORTAL'
       , t.dsdominio_motivo   = 'MOTVREPRVCPORTDDCTSALR'
       , t.cdmotivo           = 7
       , t.cdoperador         = '1'
       , t.idsituacao         = 3
   WHERE t.nrnu_portabilidade = 201901180000080234006;
   
  UPDATE tbcc_portabilidade_recebe t
     SET t.dtavaliacao        = to_date('23012019','ddmmyyyy')
       , t.dtretorno          = to_date('23012019','ddmmyyyy')
       , t.nmarquivo_resposta = 'RESPOSTA VIA PORTAL'
       , t.dsdominio_motivo   = 'MOTVREPRVCPORTDDCTSALR'
       , t.cdmotivo           = 7
       , t.cdoperador         = '1'
       , t.idsituacao         = 3
   WHERE t.nrnu_portabilidade = 201901210000080337736;
   
  COMMIT;
  
END;
