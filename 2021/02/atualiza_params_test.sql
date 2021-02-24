BEGIN

UPDATE crapprm prm
  SET prm.dsvlrprm = 3
WHERE prm.cdcooper = 1
  AND prm.cdacesso = 'QT_DIASMINPARC_RENCAN';
          
UPDATE crapprm prm
  SET prm.dsvlrprm = 30
WHERE prm.cdcooper = 1
  AND prm.cdacesso = 'QT_DIASMAXPARC_RENCAN';
       
UPDATE crapprm prm
  SET prm.dsvlrprm = 15502
WHERE prm.cdcooper = 1
  AND prm.cdacesso = 'CD_LINHAPP_RENCAN';
       
UPDATE crapprm prm
  SET prm.dsvlrprm = 35501
WHERE prm.cdcooper = 1
  AND prm.cdacesso = 'CD_LINHAPOS_RENCAN';
       
UPDATE crapprm prm
  SET prm.dsvlrprm = 62
WHERE prm.cdcooper = 1
  AND prm.cdacesso = 'CD_FINALI_RENCAN';
          
UPDATE crapprm prm
  SET prm.dsvlrprm = 1
WHERE prm.cdcooper = 1
  AND prm.cdacesso = 'ID_CARENCIAPOS_RENCAN';
       
UPDATE crapprm prm
  SET prm.dsvlrprm = 1
WHERE prm.cdcooper = 1
  AND prm.cdacesso = 'TP_CONVERSAOTR_RENCAN';
       
UPDATE crapprm prm
  SET prm.dsvlrprm = 1
WHERE prm.cdcooper = 1
  AND prm.cdacesso = 'CD_FINANCIAIOF_RENCAN';
       
UPDATE crapprm prm
  SET prm.dsvlrprm = 1
WHERE prm.cdcooper = 1
  AND prm.cdacesso = 'CD_CANCLIMITE_RENCAN';

UPDATE crapprm prm
  SET prm.dsvlrprm = 0
WHERE prm.cdcooper = 1
  AND prm.cdacesso = 'CD_CORESPONSAVEL_RENCAN';
       
UPDATE crapprm prm
  SET prm.dsvlrprm = 10
WHERE prm.cdcooper = 1
  AND prm.cdacesso = 'QT_NRMXRECA_RENCAN';

UPDATE crapprm prm
  SET prm.dsvlrprm = 10
WHERE prm.cdcooper = 1
  AND prm.cdacesso = 'QT_NRMXCOCA_RENCAN';
  
  COMMIT;
END;