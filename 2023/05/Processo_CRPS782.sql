DECLARE

   pr_flgincre1 boolean;
   pr_flgcredi1 boolean;
   vr_cdcritic INTEGER := 0;
   vr_dscritic VARCHAR2(4000);
   vr_idprglog NUMBER;
   pr_cdcooper tbgen_batch_relatorio_wrk.cdcooper%TYPE;
   vr_cdprogra tbgen_batch_relatorio_wrk.cdprograma%TYPE;
   vr_exc_saida EXCEPTION;
   vr_controle number;

  CURSOR cr_atualote_wrk IS
    select tab.cdcooper,
           tab.dtmvtolt,
           tab.cdagenci,
           tab.nrdconta,
           tab.nrctremp,
           tab.dtmvtolt as dtpagemp,
           substr(tab.dsxml,instr(tab.dsxml, '#', 1, 1) + 1,instr(tab.dsxml, '#', 1, 2) -instr(tab.dsxml, '#', 1, 1) - 1) cdbccxlt,
             substr(tab.dsxml,instr(tab.dsxml, '#', 1, 2) + 1,instr(tab.dsxml, '#', 1, 3) -instr(tab.dsxml, '#', 1, 2) - 1) cdoperad,
             substr(tab.dsxml,instr(tab.dsxml, '#', 1, 3) + 1,instr(tab.dsxml, '#', 1, 4) -instr(tab.dsxml, '#', 1, 3) - 1) tplotmov,
             substr(tab.dsxml,instr(tab.dsxml, '#', 1, 4) + 1,instr(tab.dsxml, '#', 1, 5) -instr(tab.dsxml, '#', 1, 4) - 1) nrdolote,
             substr(tab.dsxml,instr(tab.dsxml, '#', 1, 5) + 1,instr(tab.dsxml, '#', 1, 6) -instr(tab.dsxml, '#', 1, 5) - 1) cdhistor,
             substr(tab.dsxml,instr(tab.dsxml, '#', 1, 6) + 1,instr(tab.dsxml, '#', 1, 7) -instr(tab.dsxml, '#', 1, 6) - 1) vllanmto,
             substr(tab.dsxml,instr(tab.dsxml, '#', 1, 7) + 1,instr(tab.dsxml, '#', 1, 8) -instr(tab.dsxml, '#', 1, 7) - 1) txjurepr,
             substr(tab.dsxml,instr(tab.dsxml, '#', 1, 8) + 1,instr(tab.dsxml, '#', 1, 9) -instr(tab.dsxml, '#', 1, 8) - 1) vlpreemp,
             substr(tab.dsxml,instr(tab.dsxml, '#', 1, 9) + 1,instr(tab.dsxml, '#', 1, 10) -instr(tab.dsxml, '#', 1, 9) - 1) nrsequni,
             substr(tab.dsxml,instr(tab.dsxml, '#', 1, 10) + 1,instr(tab.dsxml, '#', 1, 11) -instr(tab.dsxml, '#', 1, 10) - 1) nrparepr,
             substr(tab.dsxml,instr(tab.dsxml, '#', 1, 11) + 1,instr(tab.dsxml, '#', 1, 12) -instr(tab.dsxml, '#', 1, 11) - 1) flgincre,
             substr(tab.dsxml,instr(tab.dsxml, '#', 1, 12) + 1,instr(tab.dsxml, '#', 1, 13) -instr(tab.dsxml, '#', 1, 12) - 1) flgcredi,
             substr(tab.dsxml,instr(tab.dsxml, '#', 1, 13) + 1,instr(tab.dsxml, '#', 1, 14) -instr(tab.dsxml, '#', 1, 13) - 1) nrseqava,
             substr(tab.dsxml,instr(tab.dsxml, '#', 1, 14) + 1,instr(tab.dsxml, '#', 1, 15) -instr(tab.dsxml, '#', 1, 14) - 1) cdorigem,
             substr(tab.dsxml,instr(tab.dsxml, '#', 1, 15) + 1,instr(tab.dsxml, '#', 1, 16) -instr(tab.dsxml, '#', 1, 15) - 1) cdcritic,
             substr(tab.dsxml,instr(tab.dsxml, '#', 1, 16) + 1,instr(tab.dsxml, '#', 1, 17) -instr(tab.dsxml, '#', 1, 16) - 1) dscritic,
             tab.rowid
      from (select wrk.CDCOOPER,
                   wrk.DTMVTOLT,
                   wrk.CDAGENCI,
                   wrk.NRDCONTA,
                   wrk.nrctremp,
                   wrk.tpparcel,
                   dbms_lob.substr(wrk.dsxml, 1000, 1) dsxml
              from tbgen_batch_relatorio_wrk wrk
             where wrk.cdprograma = 'CRPS782'
               and wrk.dsrelatorio = 'CONSEGUINADO_782'
               and wrk.tpparcel = 1) tab
               order by tab.cdcooper;

begin

  FOR rw_atualote_wrk IN cr_atualote_wrk LOOP
    pr_flgincre1 := CASE rw_atualote_wrk.flgincre
                      WHEN 'TRUE' THEN
                       TRUE
                      ELSE
                       FALSE
                    END;
    pr_flgcredi1 := CASE rw_atualote_wrk.flgcredi
                      WHEN 'TRUE' THEN
                       TRUE
                      ELSE
                       FALSE
                    END;
  
     EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => rw_atualote_wrk.cdcooper,
                                    pr_dtmvtolt => rw_atualote_wrk.dtmvtolt,
                                    pr_cdagenci => rw_atualote_wrk.cdagenci,
                                    pr_cdbccxlt => rw_atualote_wrk.cdbccxlt,
                                    pr_cdoperad => rw_atualote_wrk.cdoperad,
                                    pr_cdpactra => rw_atualote_wrk.cdagenci,
                                    pr_tplotmov => rw_atualote_wrk.tplotmov,
                                    pr_nrdolote => rw_atualote_wrk.nrdolote,
                                    pr_nrdconta => rw_atualote_wrk.nrdconta,
                                    pr_cdhistor => rw_atualote_wrk.cdhistor,
                                    pr_nrctremp => rw_atualote_wrk.nrctremp,
                                    pr_vllanmto => rw_atualote_wrk.vllanmto,
                                    pr_dtpagemp => rw_atualote_wrk.dtpagemp,
                                    pr_txjurepr => rw_atualote_wrk.txjurepr,
                                    pr_vlpreemp => rw_atualote_wrk.vlpreemp,
                                    pr_nrsequni => rw_atualote_wrk.nrsequni,
                                    pr_nrparepr => rw_atualote_wrk.nrparepr,
                                    pr_flgincre => pr_flgincre1,
                                    pr_flgcredi => pr_flgcredi1,
                                    pr_nrseqava => rw_atualote_wrk.nrseqava,
                                    pr_cdorigem => rw_atualote_wrk.cdorigem,
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic);
    
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      vr_dscritic := vr_dscritic || ' (' || rw_atualote_wrk.nrdconta || '/' ||
                     rw_atualote_wrk.nrctremp || '/' ||
                     rw_atualote_wrk.nrparepr || '/' || ')';
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                 ' - ' || vr_cdprogra ||' --> ' || vr_dscritic);
      RAISE vr_exc_saida;
    END IF;
  
    BEGIN
      UPDATE tbgen_batch_relatorio_wrk
         SET tpparcel = 3
       where CDCOOPER = rw_atualote_wrk.cdcooper
         and cdprograma = 'CRPS782'
         and dsrelatorio = 'CONSEGUINADO_782'
         and dtmvtolt = rw_atualote_wrk.dtmvtolt
         and nrctremp = rw_atualote_wrk.nrctremp
         and nrdconta = rw_atualote_wrk.nrdconta
         and cdagenci = rw_atualote_wrk.cdagenci
         and rowid = rw_atualote_wrk.rowid
         and tpparcel = 1;
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar tabela work. ' || SQLERRM;
        vr_dscritic := vr_dscritic || ' (' || rw_atualote_wrk.cdcooper || '/' ||
                       rw_atualote_wrk.NRCTREMP || ')';
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2 
                                  ,
                                   pr_des_log      => to_char(sysdate,
                                                              'hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || vr_dscritic);
        RAISE vr_exc_saida;
    END;
    
  END LOOP;
  commit;
END;
