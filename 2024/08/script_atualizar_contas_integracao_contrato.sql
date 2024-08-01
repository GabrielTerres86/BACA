BEGIN
  UPDATE credito.tbcred_integracao_contrato ctt
     SET ctt.nrconta_corrente =
         (SELECT nrdconta
            FROM cecred.crapepr
           WHERE nrctremp = ctt.nrcontrato
             AND cdcooper = ctt.cdcooperativa
             AND ROWNUM <= 1)
   WHERE ctt.cdcooperativa = 1
     AND ctt.idtipo_integracao = 7;
  COMMIT;
END;
