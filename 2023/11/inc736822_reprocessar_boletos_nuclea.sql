DECLARE
  CURSOR cr_crapcob (pr_idtitleg IN CECRED.crapcob.idtitleg%TYPE
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
   WHERE (trn.idtitleg, trn.idopeleg) 
      IN ((116180585,	205496237)
         ,(116180586,	205496238)
         ,(116180587,	205496239)
         ,(116180588,	205496240));
  
  vr_nmufpaga         VARCHAR2(02);
  vr_idopelegnovo     CECRED.crapcob.idopeleg%TYPE;
  vr_rowidlog         ROWID;
  vr_rowidremessa     ROWID;
  vr_nmprograma       tbgen_prglog.cdprograma%TYPE := 'Reprocessar Boletos Nuclea - INC736822';
  
  vr_cdcritic         CECRED.crapcri.cdcritic%TYPE;
  vr_dscritic         VARCHAR2(4000);
  vr_des_erro         VARCHAR2(4000);
    
BEGIN 
  FOR rw_titulos_reprocessar IN cr_reprocessar_titulos LOOP
    OPEN cr_crapcob(rw_titulos_reprocessar.idtitleg 
                   ,rw_titulos_reprocessar.idopeleg);
    FETCH cr_crapcob INTO rw_crapcob;
    CLOSE cr_crapcob;
    
    vr_idopelegnovo := seqcob_idopeleg.NEXTVAL;
    
    IF TRIM(rw_titulos_reprocessar.nmufpaga) IS NULL THEN
      OPEN cr_crapdne(pr_nrceplog => rw_titulos_reprocessar.nrceppag);
      FETCH cr_crapdne INTO rw_crapdne;
      
      IF cr_crapdne%NOTFOUND THEN        
        CLOSE cr_crapdne;
        
        CECRED.PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
                                            ,pr_cdoperad => 't0035324'
                                            ,pr_dtmvtolt => TRUNC(SYSDATE)
                                            ,pr_dsmensag => 'Etapa 1 - UF pagador nao foi encontrada atraves do CEP - INC736822'
                                            ,pr_des_erro => vr_des_erro
                                            ,pr_dscritic => vr_dscritic);
       CONTINUE;
      ELSE
        CLOSE cr_crapdne;
        vr_nmufpaga:= rw_crapdne.cduflogr;
      END IF;
    ELSE
      vr_nmufpaga:= rw_titulos_reprocessar.nmufpaga;
    END IF;
    
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
        ,vr_nmufpaga
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
        vr_dscritic := 'Etapa 2 - Erro ao inserir na tabela tbcobran_remessa_npc - INC736822. ' || SQLERRM;
        BEGIN
          CECRED.NPCB0001.pc_gera_log_npc(pr_cdcooper => rw_titulos_reprocessar.cdcooper
                                         ,pr_nmrotina => 'Script INC736822 - Reprocessar titulos Nuclea'
                                         ,pr_dsdolog  => vr_dscritic   || ' - idtitleg:'||rw_titulos_reprocessar.idtitleg
                                                         ||';idopeleg:'|| rw_titulos_reprocessar.idopeleg);
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            CECRED.pc_internal_exception(pr_cdcooper => 0
                                        ,pr_compleme => 'Etapa 2 - Erro ao inserir na tabela tbcobran_remessa_npc - INC736822');
        END;
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
                                     ,pr_cdoperad => 't0035324'
                                     ,pr_dtmvtolt => TRUNC(SYSDATE)
                                     ,pr_dsmensag => 'Etapa 2 - Erro ao integrar instrução na cabine JDNPC (OPTIT) - INC736822'
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);                                    
    END;
    
    BEGIN                                                                 
      UPDATE CECRED.crapcob cob
         SET cob.idopeleg = vr_idopelegnovo,
             cob.inenvcip = 3
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
        vr_dscritic := 'Etapa 3 - Erro ao atualizar tabela crapcob - INC736822. ' || SQLERRM;
        BEGIN
          CECRED.NPCB0001.pc_gera_log_npc(pr_cdcooper => rw_crapcob.cdcooper
                                         ,pr_nmrotina => 'Script INC736822 - Reprocessar titulos Nuclea'
                                         ,pr_dsdolog  => vr_dscritic   || ' - idtitleg:'||rw_crapcob.idtitleg
                                                         ||';idopeleg:'|| rw_crapcob.idopeleg);
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            CECRED.pc_internal_exception(pr_cdcooper => rw_crapcob.cdcooper
                                        ,pr_compleme => 'Etapa 3 - Erro ao atualizar tabela crapcob - INC736822');
        END;
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
                                     ,pr_cdoperad => 't0035324'
                                     ,pr_dtmvtolt => TRUNC(SYSDATE)
                                     ,pr_dsmensag => 'Etapa 3 - Erro ao atualizar tabela crapcob - INC736822'
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic); 
    END;      
  END LOOP;
  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
      CECRED.pc_internal_exception(pr_cdcooper => 0
                                  ,pr_compleme => 'Script INC736822 - Reprocessar titulos Nuclea'); 
END;   
