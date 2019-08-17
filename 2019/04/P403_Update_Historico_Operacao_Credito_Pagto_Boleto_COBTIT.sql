BEGIN
  FOR rw_lcb IN (SELECT lcb.rowid
                  FROM tbrecup_cobranca rco
                 INNER JOIN crapcob cob ON cob.cdcooper = rco.cdcooper
                                       AND cob.nrdconta = rco.nrdconta_cob
                                       AND cob.nrcnvcob = rco.nrcnvcob
                                       AND cob.nrdocmto = rco.nrboleto
                 INNER JOIN craptdb tdb ON tdb.cdcooper = rco.cdcooper
                                       AND tdb.nrdconta = rco.nrdconta
                                       AND tdb.nrborder = rco.nrctremp
                                       AND tdb.nrtitulo IN (SELECT to_number(regexp_substr(rco.dsparcelas,'[^,]+', 1, LEVEL)) FROM dual
                                                            CONNECT BY regexp_substr(rco.dsparcelas, '[^,]+', 1, LEVEL) IS NOT NULL)
                 INNER JOIN tbdsct_lancamento_bordero lcb ON lcb.cdcooper = rco.cdcooper
                                                         AND lcb.nrdconta = rco.nrdconta
                                                         AND lcb.nrborder = rco.nrctremp
                                                         AND lcb.nrdocmto = tdb.nrdocmto
                                                         AND lcb.dtmvtolt = cob.dtdpagto
                                                         AND lcb.cdhistor IN (2672,2673)
                 WHERE rco.tpproduto = 3)
  LOOP
    UPDATE cecred.tbdsct_lancamento_bordero lcb
       SET cdhistor = 2671
     WHERE lcb.rowid = rw_lcb.rowid;
  END LOOP;
  COMMIT;  
END;
