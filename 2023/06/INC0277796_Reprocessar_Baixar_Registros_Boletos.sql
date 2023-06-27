DECLARE
  vr_cdcritic CECRED.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(100);

  vr_tab_remessa_dda CECRED.DDDA0001.typ_tab_remessa_dda;
  vr_tab_retorno_dda CECRED.DDDA0001.typ_tab_retorno_dda;
  vr_exc_erro EXCEPTION;

BEGIN
  FOR rw_npc_reproc IN (SELECT ROWID rowidcob
                              ,c.vldescto
                              ,c.vlabatim
                              ,c.dtvencto
                              ,c.flgdprot
                              ,c.idtitleg
                          FROM CECRED.crapcob c
                         WHERE (idtitleg, idopeleg) IN
                               ((106853427, 193918824)
                               ,(106854208, 193914060)
                               ,(106854209, 193914061)
                               ,(106854210, 193914062)
                               ,(106854211, 193914063))) LOOP
  
    vr_tab_remessa_dda.delete;
    CECRED.ddda0001.pc_procedimentos_dda_jd(pr_rowid_cob       => rw_npc_reproc.rowidcob
                                           ,pr_tpoperad        => 'I'
                                           ,pr_tpdbaixa        => ''
                                           ,pr_dtvencto        => rw_npc_reproc.dtvencto
                                           ,pr_vldescto        => rw_npc_reproc.vldescto
                                           ,pr_vlabatim        => rw_npc_reproc.vlabatim
                                           ,pr_flgdprot        => rw_npc_reproc.flgdprot
                                           ,pr_tab_remessa_dda => vr_tab_remessa_dda
                                           ,pr_tab_retorno_dda => vr_tab_retorno_dda
                                           ,pr_cdcritic        => vr_cdcritic
                                           ,pr_dscritic        => vr_dscritic);
  
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    DBMS_OUTPUT.put_line('Erro inc0277796: ' || vr_dscritic);
    RAISE;
  
  WHEN OTHERS THEN
    ROLLBACK;
    SISTEMA.excecaoInterna(pr_cdcooper => 3);
    RAISE;
END;
