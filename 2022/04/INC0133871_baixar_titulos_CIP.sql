/*
Baixar título em lote via sistema (Renier Padilha - INC0133871)
*/
DECLARE
  --
  vr_cdcritic            crapcri.cdcritic%TYPE;
  vr_dscritic            crapcri.dscritic%TYPE;
  vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
  vr_dtmvtolt            crapdat.dtmvtolt%TYPE;
  vr_cdprogra            VARCHAR2(20) := 'INC0133871';
  vr_idprglog            tbgen_prglog.idprglog%TYPE;
  --
  CURSOR cr_crapcob IS
    SELECT cob.rowid
          ,cob.nrdocmto
      FROM crapcob cob
     WHERE 1 = 1
       AND cob.idlottck = 'BC23DF8E40B24C32A578394A0E80F5A0'
       AND cob.cdcooper = 1
       AND cob.nrdconta = 4043596
       AND cob.nrcnvcob = 101004
       AND cob.incobran = 0;
  --
BEGIN
  --
  pc_log_programa(pr_dstiplog   => 'I'
                 ,pr_cdprograma => vr_cdprogra
                 ,pr_cdcooper   => 1
                 ,pr_tpexecucao => 0
                 ,pr_idprglog   => vr_idprglog);
  --
  SELECT dtmvtolt INTO vr_dtmvtolt FROM crapdat WHERE cdcooper = 1;
  --
  FOR rw IN cr_crapcob LOOP
    --
    BEGIN
      --
      COBR0007.pc_inst_pedido_baixa_titulo(pr_idregcob            => rw.rowid
                                          ,pr_cdocorre            => 2
                                          ,pr_dtmvtolt            => vr_dtmvtolt
                                          ,pr_cdoperad            => '1'
                                          ,pr_nrremass            => 0
                                          ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                                          ,pr_cdcritic            => vr_cdcritic
                                          ,pr_dscritic            => vr_dscritic);
      --
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --
        pc_log_programa(pr_dstiplog      => 'E'
                       ,pr_cdprograma    => vr_cdprogra
                       ,pr_cdcooper      => 1
                       ,pr_tpexecucao    => 0
                       ,pr_tpocorrencia  => 3
                       ,pr_cdcriticidade => 0
                       ,pr_cdmensagem    => vr_cdcritic
                       ,pr_dsmensagem    => vr_dscritic
                       ,pr_idprglog      => vr_idprglog);
        --
        ROLLBACK;
        --
        CONTINUE;
        --
      END IF;
      --
      pc_log_programa(pr_dstiplog      => 'O'
                     ,pr_cdprograma    => vr_cdprogra
                     ,pr_cdcooper      => 1
                     ,pr_tpexecucao    => 0
                     ,pr_tpocorrencia  => 4
                     ,pr_cdcriticidade => 0
                     ,pr_cdmensagem    => 0
                     ,pr_dsmensagem    => rw.nrdocmto || ' baixado!'
                     ,pr_idprglog      => vr_idprglog);
      --
      COMMIT;
      --
    EXCEPTION
      WHEN OTHERS THEN
        SISTEMA.excecaoInterna(pr_compleme => 'INC0133871');
        ROLLBACK;
    END;
  END LOOP;
  --
  pc_log_programa(pr_dstiplog   => 'F'
                 ,pr_cdprograma => vr_cdprogra
                 ,pr_cdcooper   => 1
                 ,pr_tpexecucao => 0
                 ,pr_flgsucesso => 1
                 ,pr_idprglog   => vr_idprglog);
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    SISTEMA.excecaoInterna(pr_compleme => 'INC0133871');
    --
    ROLLBACK;
    --
    pc_log_programa(pr_dstiplog   => 'F'
                   ,pr_cdprograma => vr_cdprogra
                   ,pr_cdcooper   => 1
                   ,pr_tpexecucao => 0
                   ,pr_flgsucesso => 0
                   ,pr_idprglog   => vr_idprglog);
    --
END;
