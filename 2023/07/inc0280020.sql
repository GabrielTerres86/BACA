BEGIN

  UPDATE pagamento.tb_baixa_pcr_remessa tbprem
     SET tbprem.cdsituacao = 0
        ,tbprem.nrdolote = 99
   WHERE tbprem.cdsituacao = 2
     AND tbprem.dhinclusao >= to_date('01072023', 'ddmmyyyy')
     AND tbprem.tpoperjd = 'BX'
     AND NOT EXISTS (
                     SELECT 1
                     FROM cecred.tbcobran_baixa_operac tbo
                     WHERE tbo.nrdident = tbprem.nrtitulo_npc
                    );

  dbms_output.put_line('Linhas afetadas:'||sql%rowcount);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    cecred.pc_internal_exception(pr_cdcooper => 3);
    ROLLBACK;
    RAISE;
END;
/
