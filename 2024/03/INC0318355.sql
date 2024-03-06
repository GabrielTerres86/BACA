DECLARE
  CURSOR cr_crapret IS
    SELECT ret.rowid
      FROM tbcobran_arquivo_cob615_detalhe tacd
     INNER JOIN tbcobran_cob615_ocorrencia_liquidacao tcol
        ON tacd.idarquivo_cob615_detalhe = tcol.idarquivo_cob615_detalhe
     INNER JOIN tbcobran_ocorrencia_liquidacao_crapret tolc
        ON tcol.idocorrencia_liquidacao = tolc.idocorrencia_liquidacao
     INNER JOIN crapret ret
        ON tolc.nrprogress_recid_crapret = ret.progress_recid
     WHERE tacd.idarquivo_cob615_header = HEXTORAW('56082EAFD5954FB1A5A1B12A00B1B8BC')
       AND ret.dtcredit = TO_DATE('04/03/2024', 'DD/MM/YYYY');
BEGIN
  FOR rw_crapret IN cr_crapret LOOP
    BEGIN
      UPDATE crapret
         SET crapret.dtcredit = TO_DATE('06/03/2024', 'DD/MM/YYYY')
       WHERE crapret.rowid = rw_crapret.rowid;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        SISTEMA.excecaoInterna(pr_compleme => 'INC0318355');
        ROLLBACK;
    END;
  END LOOP;
END;
