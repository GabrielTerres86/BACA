DECLARE
  CURSOR cr_crapcob(pr_idtitleg IN CECRED.crapcob.idtitleg%TYPE
                   ,pr_idopeleg IN CECRED.crapcob.idopeleg%TYPE) IS
    SELECT cob.rowid
          ,cob.cdcooper
          ,cob.nrdconta
          ,cob.idseqttl
          ,cob.inenvcip
          ,cob.idopeleg
          ,cob.idtitleg
      FROM CECRED.crapcob cob
     WHERE cob.idtitleg = pr_idtitleg
       AND cob.idopeleg = pr_idopeleg;
  rw_crapcob cr_crapcob%ROWTYPE;

  CURSOR cr_crapdne(pr_nrceplog IN CECRED.crapdne.nrceplog%TYPE) IS
    SELECT dne.cduflogr
      FROM CECRED.crapdne dne
     WHERE dne.nrceplog = pr_nrceplog
       AND rownum = 1;
  rw_crapdne cr_crapdne%ROWTYPE;

  CURSOR cr_reprocessar_titulos IS
    SELECT trn.*
      FROM CECRED.tbcobran_remessa_npc trn
     WHERE (trn.idtitleg, trn.idopeleg) IN ((142036924, 233518839)
                                           ,(142036925, 233518840)
                                           ,(142036926, 233518841)
                                           ,(142036927, 233518842)
                                           ,(142036928, 233518843)
                                           ,(142036929, 233518844)
                                           ,(142036933, 233518848)
                                           ,(142036934, 233518849)
                                           ,(142036935, 233518850)
                                           ,(142036936, 233518851)
                                           ,(142036937, 233518852)
                                           ,(142036940, 233518855)
                                           ,(142036945, 233518860)
                                           ,(142036949, 233518864)
                                           ,(142036950, 233518865)
                                           ,(142036951, 233518866)
                                           ,(142036962, 233518877)
                                           ,(142036984, 233518899)
                                           ,(142036987, 233518902)
                                           ,(142036985, 233518900)
                                           ,(142036963, 233518878)
                                           ,(142036986, 233518901)
                                           ,(142036938, 233518853)
                                           ,(142036939, 233518854)
                                           ,(142036941, 233518856)
                                           ,(142036942, 233518857)
                                           ,(142036944, 233518859)
                                           ,(142036946, 233518861)
                                           ,(142036947, 233518862)
                                           ,(142036948, 233518863)
                                           ,(142036952, 233518867)
                                           ,(142036953, 233518868)
                                           ,(142036955, 233518870)
                                           ,(142036956, 233518871)
                                           ,(142036957, 233518872)
                                           ,(142036958, 233518873)
                                           ,(142036959, 233518874)
                                           ,(142036960, 233518875)
                                           ,(142036961, 233518876)
                                           ,(142036954, 233518869)
                                           ,(142036943, 233518858)
                                           ,(142036930, 233518845)
                                           ,(142036931, 233518846)
                                           ,(142036932, 233518847)
                                           ,(142036966, 233518881)
                                           ,(142036964, 233518879)
                                           ,(142036965, 233518880)
                                           ,(142036923, 233518838)
                                           ,(142036967, 233518882)
                                           ,(142036968, 233518883)
                                           ,(142036969, 233518884)
                                           ,(142036970, 233518885)
                                           ,(142036971, 233518886)
                                           ,(142036972, 233518887)
                                           ,(142036973, 233518888)
                                           ,(142036974, 233518889)
                                           ,(142036975, 233518890)
                                           ,(142036976, 233518891)
                                           ,(142036977, 233518892)
                                           ,(142036978, 233518893)
                                           ,(142036979, 233518894)
                                           ,(142036980, 233518895)
                                           ,(142036981, 233518896)
                                           ,(142036982, 233518897)
                                           ,(142036983, 233518898));

  vr_idopelegnovo CECRED.crapcob.idopeleg%TYPE;
  vr_rowidlog     ROWID;
  vr_rowidremessa ROWID;
  vr_nmprograma   tbgen_prglog.cdprograma%TYPE := 'Reprocessar Boletos Nuclea - INC0346948';

  vr_cdcritic CECRED.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(4000);

BEGIN
  FOR rw_titulos_reprocessar IN cr_reprocessar_titulos LOOP
    OPEN cr_crapcob(rw_titulos_reprocessar.idtitleg, rw_titulos_reprocessar.idopeleg);
    FETCH cr_crapcob
      INTO rw_crapcob;
    CLOSE cr_crapcob;
  
    vr_idopelegnovo := seqcob_idopeleg.NEXTVAL;
  
    BEGIN
      INSERT INTO CECRED.tbcobran_remessa_npc
        (cdlegado
        ,idtitleg
        ,idopeleg
        ,nrispbad
        ,nrispbpr
        ,tpoperad
        ,dhoperad
        ,tppesori
        ,nrdocori
        ,nmdocori
        ,nmfanori
        ,tppesfin
        ,nrdocfin
        ,nmdocfin
        ,nmfanfin
        ,tppespag
        ,nrdocpag
        ,nmdocpag
        ,nmfanpag
        ,nmlogpag
        ,nmcidpag
        ,nmufpaga
        ,nrceppag
        ,tpidesac
        ,nridesac
        ,nmdocsac
        ,cdcartei
        ,codmoeda
        ,nrnosnum
        ,cdcodbar
        ,nrlindig
        ,dtvencto
        ,vlvalor
        ,nrnumdoc
        ,cdespeci
        ,dtemissa
        ,qtdiapro
        ,dtlimpgto
        ,tppgto
        ,idtipneg
        ,idbloqpag
        ,idpagparc
        ,vlabatim
        ,dtjuros
        ,codjuros
        ,vlperjur
        ,dtmulta
        ,codmulta
        ,vlpermul
        ,dtdesco1
        ,cddesco1
        ,vlperde1
        ,nrnotfis
        ,tppemitt
        ,vlpemitt
        ,tppematt
        ,vlpematt
        ,tpmodcal
        ,tprecvld
        ,idnrcalc
        ,nridenti
        ,nrfacati
        ,tpbaixeft
        ,nrispbte
        ,cdpatter
        ,dhbaixef
        ,dtbaixef
        ,vlbaixef
        ,cdcanpgt
        ,cdmeiopg
        ,cdsituac
        ,cdcooper
        ,flonline
        ,dtmvtolt)
      VALUES
        (rw_titulos_reprocessar.cdlegado
        ,rw_titulos_reprocessar.idtitleg
        ,vr_idopelegnovo
        ,rw_titulos_reprocessar.nrispbad
        ,rw_titulos_reprocessar.nrispbpr
        ,rw_titulos_reprocessar.tpoperad
        ,rw_titulos_reprocessar.dhoperad
        ,rw_titulos_reprocessar.tppesori
        ,rw_titulos_reprocessar.nrdocori
        ,rw_titulos_reprocessar.nmdocori
        ,rw_titulos_reprocessar.nmfanori
        ,rw_titulos_reprocessar.tppesfin
        ,rw_titulos_reprocessar.nrdocfin
        ,rw_titulos_reprocessar.nmdocfin
        ,rw_titulos_reprocessar.nmfanfin
        ,rw_titulos_reprocessar.tppespag
        ,rw_titulos_reprocessar.nrdocpag
        ,rw_titulos_reprocessar.nmdocpag
        ,rw_titulos_reprocessar.nmfanpag
        ,rw_titulos_reprocessar.nmlogpag
        ,rw_titulos_reprocessar.nmcidpag
        ,rw_titulos_reprocessar.nmufpaga
        ,rw_titulos_reprocessar.nrceppag
        ,rw_titulos_reprocessar.tpidesac
        ,rw_titulos_reprocessar.nridesac
        ,rw_titulos_reprocessar.nmdocsac
        ,rw_titulos_reprocessar.cdcartei
        ,rw_titulos_reprocessar.codmoeda
        ,rw_titulos_reprocessar.nrnosnum
        ,rw_titulos_reprocessar.cdcodbar
        ,rw_titulos_reprocessar.nrlindig
        ,rw_titulos_reprocessar.dtvencto
        ,rw_titulos_reprocessar.vlvalor
        ,rw_titulos_reprocessar.nrnumdoc
        ,rw_titulos_reprocessar.cdespeci
        ,rw_titulos_reprocessar.dtemissa
        ,rw_titulos_reprocessar.qtdiapro
        ,rw_titulos_reprocessar.dtlimpgto
        ,rw_titulos_reprocessar.tppgto
        ,rw_titulos_reprocessar.idtipneg
        ,rw_titulos_reprocessar.idbloqpag
        ,rw_titulos_reprocessar.idpagparc
        ,rw_titulos_reprocessar.vlabatim
        ,rw_titulos_reprocessar.dtjuros
        ,rw_titulos_reprocessar.codjuros
        ,rw_titulos_reprocessar.vlperjur
        ,rw_titulos_reprocessar.dtmulta
        ,rw_titulos_reprocessar.codmulta
        ,rw_titulos_reprocessar.vlpermul
        ,rw_titulos_reprocessar.dtdesco1
        ,rw_titulos_reprocessar.cddesco1
        ,rw_titulos_reprocessar.vlperde1
        ,rw_titulos_reprocessar.nrnotfis
        ,rw_titulos_reprocessar.tppemitt
        ,rw_titulos_reprocessar.vlpemitt
        ,rw_titulos_reprocessar.tppematt
        ,rw_titulos_reprocessar.vlpematt
        ,rw_titulos_reprocessar.tpmodcal
        ,rw_titulos_reprocessar.tprecvld
        ,rw_titulos_reprocessar.idnrcalc
        ,rw_titulos_reprocessar.nridenti
        ,rw_titulos_reprocessar.nrfacati
        ,rw_titulos_reprocessar.tpbaixeft
        ,rw_titulos_reprocessar.nrispbte
        ,rw_titulos_reprocessar.cdpatter
        ,rw_titulos_reprocessar.dhbaixef
        ,rw_titulos_reprocessar.dtbaixef
        ,rw_titulos_reprocessar.vlbaixef
        ,rw_titulos_reprocessar.cdcanpgt
        ,rw_titulos_reprocessar.cdmeiopg
        ,0
        ,rw_titulos_reprocessar.cdcooper
        ,rw_titulos_reprocessar.flonline
        ,TRUNC(SYSDATE))
      RETURNING ROWID INTO vr_rowidremessa;
    
      CECRED.GENE0001.pc_gera_log(pr_cdcooper => rw_titulos_reprocessar.cdcooper
                                 ,pr_nrdconta => 0
                                 ,pr_idseqttl => 0
                                 ,pr_cdoperad => 't0035324'
                                 ,pr_dscritic => vr_rowidremessa
                                 ,pr_dsorigem => 'COBRANCA'
                                 ,pr_dstransa => vr_nmprograma
                                 ,pr_dttransa => TRUNC(SYSDATE)
                                 ,pr_flgtrans => 1
                                 ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                                 ,pr_nmdatela => 'NOVA REMESSA'
                                 ,pr_nrdrowid => vr_rowidlog);
    
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        vr_dscritic := 'Etapa 2 - Erro ao inserir na tabela tbcobran_remessa_npc - INC0346948. ' ||
                       SQLERRM;
        BEGIN
          CECRED.NPCB0001.pc_gera_log_npc(pr_cdcooper => rw_titulos_reprocessar.cdcooper
                                         ,pr_nmrotina => 'Script INC0346948 - Reprocessar titulos Nuclea'
                                         ,pr_dsdolog  => vr_dscritic || ' - idtitleg:' ||
                                                         rw_titulos_reprocessar.idtitleg ||
                                                         ';idopeleg:' ||
                                                         rw_titulos_reprocessar.idopeleg);
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            CECRED.pc_internal_exception(pr_cdcooper => 0
                                        ,pr_compleme => 'Etapa 2 - Erro ao inserir na tabela tbcobran_remessa_npc - INC0346948');
        END;
    END;
  
    BEGIN
      UPDATE CECRED.crapcob cob
         SET cob.idopeleg = vr_idopelegnovo
            ,cob.inenvcip = 3
       WHERE ROWID = rw_crapcob.rowid;
    
      CECRED.GENE0001.pc_gera_log(pr_cdcooper => rw_crapcob.cdcooper
                                 ,pr_nrdconta => rw_crapcob.nrdconta
                                 ,pr_idseqttl => rw_crapcob.idseqttl
                                 ,pr_cdoperad => 't0035324'
                                 ,pr_dscritic => rw_crapcob.rowid
                                 ,pr_dsorigem => 'COBRANCA'
                                 ,pr_dstransa => vr_nmprograma
                                 ,pr_dttransa => TRUNC(SYSDATE)
                                 ,pr_flgtrans => 1
                                 ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                                 ,pr_nmdatela => 'UPDT crapcob'
                                 ,pr_nrdrowid => vr_rowidlog);
    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                                      ,pr_nmdcampo => 'crapcob.idopeleg'
                                      ,pr_dsdadant => rw_crapcob.idopeleg
                                      ,pr_dsdadatu => vr_idopelegnovo);
    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_rowidlog
                                      ,pr_nmdcampo => 'crapcob.inenvcip'
                                      ,pr_dsdadant => rw_crapcob.inenvcip
                                      ,pr_dsdadatu => 3);
    
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        vr_dscritic := 'Etapa 3 - Erro ao atualizar tabela crapcob - INC0346948. ' || SQLERRM;
        BEGIN
          CECRED.NPCB0001.pc_gera_log_npc(pr_cdcooper => rw_crapcob.cdcooper
                                         ,pr_nmrotina => 'Script INC0346948 - Reprocessar titulos Nuclea'
                                         ,pr_dsdolog  => vr_dscritic || ' - idtitleg:' ||
                                                         rw_crapcob.idtitleg || ';idopeleg:' ||
                                                         rw_crapcob.idopeleg);
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            CECRED.pc_internal_exception(pr_cdcooper => rw_crapcob.cdcooper
                                        ,pr_compleme => 'Etapa 3 - Erro ao atualizar tabela crapcob - INC0346948');
        END;
    END;
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    CECRED.pc_internal_exception(pr_cdcooper => 0
                                ,pr_compleme => 'Script INC0346948 - Reprocessar titulos Nuclea');
END;
