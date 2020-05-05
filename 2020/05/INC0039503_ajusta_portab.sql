BEGIN
UPDATE tbcc_portabilidade_recebe t
   SET t.dsdominio_motivo = 'MOTVREPRVCPORTDDCTSALR'
     , t.cdmotivo  = 7
     , t.idsituacao  = 3
WHERE t.cdcooper = 1
AND t.nrdconta = 6874851 
AND t.nrnu_portabilidade =201812270000078399691;

COMMIT;
END;
