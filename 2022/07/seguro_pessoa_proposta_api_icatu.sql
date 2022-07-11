BEGIN
  FOR rw_cdcooper IN (SELECT p.cdcooper
                        FROM crapcop p
                       WHERE p.cdcooper <> 3
                         AND p.flgativo = 1) LOOP
    INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
      VALUES('CRED', rw_cdcooper.cdcooper, 'PROPOSTA_API_ICATU', 'Chave para ativar a utilização da API Icatu online', 'N');
  END LOOP;
  COMMIT;
END;
/
BEGIN
  INSERT INTO crapcri(cdcritic,dscritic,tpcritic,flgchama)
  VALUES (5050,'Aguardando retorno do numero de proposta da seguradora. Aguarde!',4,0);
  COMMIT;
END;
/
BEGIN
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
      VALUES('CRED', 0, 'PROPOSTA_API_ICATU_TEMPO', 'Tempo em minutos de aguardo do retorno da API', '5');
  COMMIT;
END;
/

   
