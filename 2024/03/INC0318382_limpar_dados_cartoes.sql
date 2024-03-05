BEGIN

  DELETE FROM crapvri x
  WHERE x.rowid IN(SELECT DISTINCT r.rowid
                     FROM tbcrd_risco t, crapvri r
                    WHERE t.IDARQUIVO = 5002
                      AND r.dtrefere = t.DTREFERE
                      AND r.cdcooper = t.cdcooper
                      AND r.nrdconta = t.nrdconta
                      AND r.nrctremp = t.NRCONTRATO
                      AND r.cdmodali = t.NRMODALIDADE
                      );

  DELETE FROM crapris x
  WHERE x.rowid IN(SELECT DISTINCT r.rowid
                     FROM tbcrd_risco t, crapris r
                    WHERE t.IDARQUIVO = 5002
                      AND r.dtrefere = t.DTREFERE
                      AND r.cdcooper = t.cdcooper
                      AND r.nrdconta = t.nrdconta
                      AND r.nrctremp = t.NRCONTRATO
                      AND r.cdmodali = t.NRMODALIDADE
                      AND r.INDDOCTO = 4
                      );

  DELETE FROM tbcrd_risco x
   WHERE x.idarquivo IN (SELECT t.idarquivo
                           FROM tbcrd_arq_risco t
                          WHERE t.dtrefere = to_date('29/02/2024','dd/mm/RRRR')
                            AND t.idbandeira = 5);

  DELETE FROM tbcrd_arq_risco t
   WHERE t.DTREFERE = to_date('29/02/2024','dd/mm/RRRR')
     AND t.IDBANDEIRA = 5
     ;

  UPDATE crapprm t
     SET t.DSVLRPRM = '06/02/2024;0;0;1'
   WHERE t.CDACESSO = 'RISCO_CARTAO_BACEN'
     AND t.cdcooper = 1;

  COMMIT;
  
END;
