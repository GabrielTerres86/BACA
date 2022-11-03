DECLARE
  
  CURSOR cr_crapcob (pr_idtitleg IN crapcob.idtitleg%type) IS
    SELECT  cob.rowid rowidcob
      FROM cecred.crapcob cob
     WHERE cob.idtitleg = pr_idtitleg;
  rw_crapcob cr_crapcob%ROWTYPE;   

  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(100);

  vr_idopelegnovo crapcob.idopeleg%type;
  
BEGIN

  FOR rw_npc_reproc IN (
 SELECT trn.*
    FROM cecred.tbcobran_remessa_npc trn
    WHERE (trn.idtitleg, trn.idopeleg) IN
     ((82921480,163480078)
      ,(86759594,163480079))
     )   LOOP

    vr_idopelegnovo := seqcob_idopeleg.NEXTVAL;

    BEGIN
     INSERT INTO CECRED.TBCOBRAN_REMESSA_NPC
        (CDLEGADO, 
        IDTITLEG,  
        IDOPELEG,  
        NRISPBAD,  
        NRISPBPR,  
        TPOPERAD,  
        DHOPERAD,  
        TPPESORI,  
        NRDOCORI,  
        NMDOCORI,  
        NMFANORI,  
        TPPESFIN,  
        NRDOCFIN,  
        NMDOCFIN,  
        NMFANFIN,  
        TPPESPAG,  
        NRDOCPAG,  
        NMDOCPAG,  
        NMFANPAG,  
        NMLOGPAG,  
        NMCIDPAG,  
        NMUFPAGA,  
        NRCEPPAG,  
        TPIDESAC,  
        NRIDESAC,  
        NMDOCSAC,  
        CDCARTEI,  
        CODMOEDA,  
        NRNOSNUM,  
        CDCODBAR,  
        NRLINDIG,      
        DTVENCTO,      
        VLVALOR,       
        NRNUMDOC,      
        CDESPECI,      
        DTEMISSA,      
        QTDIAPRO,      
        DTLIMPGTO,     
        TPPGTO,        
        IDTIPNEG,      
        IDBLOQPAG,     
        IDPAGPARC,     
        VLABATIM,      
        DTJUROS,       
        CODJUROS,      
        VLPERJUR,      
        DTMULTA,       
        CODMULTA,      
        VLPERMUL,      
        DTDESCO1,      
        CDDESCO1,      
        VLPERDE1,      
        NRNOTFIS,      
        TPPEMITT,      
        VLPEMITT,      
        TPPEMATT,      
        VLPEMATT,      
        TPMODCAL,      
        TPRECVLD,      
        IDNRCALC,      
        NRIDENTI,      
        NRFACATI,      
        TPBAIXEFT,     
        NRISPBTE,      
        CDPATTER,      
        DHBAIXEF,      
        DTBAIXEF,      
        VLBAIXEF,      
        CDCANPGT,      
        CDMEIOPG,      
        CDSITUAC,      
        CDCOOPER,      
        FLONLINE,      
        DTMVTOLT       
        )
              
      VALUES
        (rw_npc_reproc.CDLEGADO, 
        rw_npc_reproc.IDTITLEG,  
        vr_idopelegnovo,         
        rw_npc_reproc.NRISPBAD,  
        rw_npc_reproc.NRISPBPR,  
        rw_npc_reproc.TPOPERAD,  
        rw_npc_reproc.DHOPERAD,  
        rw_npc_reproc.TPPESORI,  
        rw_npc_reproc.NRDOCORI,  
        rw_npc_reproc.NMDOCORI,  
        rw_npc_reproc.NMFANORI,  
        rw_npc_reproc.TPPESFIN,  
        rw_npc_reproc.NRDOCFIN,  
        rw_npc_reproc.NMDOCFIN,  
        rw_npc_reproc.NMFANFIN,  
        rw_npc_reproc.TPPESPAG,  
        rw_npc_reproc.NRDOCPAG,  
        rw_npc_reproc.NMDOCPAG,  
        rw_npc_reproc.NMFANPAG,  
        rw_npc_reproc.NMLOGPAG,      
        rw_npc_reproc.NMCIDPAG,      
        rw_npc_reproc.NMUFPAGA,      
        rw_npc_reproc.NRCEPPAG,      
        rw_npc_reproc.TPIDESAC,      
        rw_npc_reproc.NRIDESAC,      
        rw_npc_reproc.NMDOCSAC,      
        rw_npc_reproc.CDCARTEI,      
        rw_npc_reproc.CODMOEDA,      
        rw_npc_reproc.NRNOSNUM,      
        rw_npc_reproc.CDCODBAR,      
        rw_npc_reproc.NRLINDIG,      
        rw_npc_reproc.DTVENCTO,      
        rw_npc_reproc.VLVALOR,       
        rw_npc_reproc.NRNUMDOC,      
        rw_npc_reproc.CDESPECI,      
        rw_npc_reproc.DTEMISSA,      
        rw_npc_reproc.QTDIAPRO,      
        rw_npc_reproc.DTLIMPGTO,     
        rw_npc_reproc.TPPGTO,        
        rw_npc_reproc.IDTIPNEG,      
        rw_npc_reproc.IDBLOQPAG,     
        rw_npc_reproc.IDPAGPARC,     
        rw_npc_reproc.VLABATIM,      
        rw_npc_reproc.DTJUROS,       
        rw_npc_reproc.CODJUROS,      
        rw_npc_reproc.VLPERJUR,      
        rw_npc_reproc.DTMULTA,       
        rw_npc_reproc.CODMULTA,      
        rw_npc_reproc.VLPERMUL,      
        rw_npc_reproc.DTDESCO1,      
        rw_npc_reproc.CDDESCO1,      
        rw_npc_reproc.VLPERDE1,      
        rw_npc_reproc.NRNOTFIS,      
        rw_npc_reproc.TPPEMITT,      
        rw_npc_reproc.VLPEMITT,      
        rw_npc_reproc.TPPEMATT,      
        rw_npc_reproc.VLPEMATT,      
        rw_npc_reproc.TPMODCAL,      
        rw_npc_reproc.TPRECVLD,      
        rw_npc_reproc.IDNRCALC,      
        rw_npc_reproc.NRIDENTI,      
        rw_npc_reproc.NRFACATI,      
        rw_npc_reproc.TPBAIXEFT,     
        rw_npc_reproc.NRISPBTE,      
        rw_npc_reproc.CDPATTER,      
        rw_npc_reproc.DHBAIXEF,      
        rw_npc_reproc.DTBAIXEF,      
        rw_npc_reproc.VLBAIXEF,      
        rw_npc_reproc.CDCANPGT,      
        rw_npc_reproc.CDMEIOPG,      
        0,             
        rw_npc_reproc.CDCOOPER,
        rw_npc_reproc.FLONLINE,
        TRUNC(SYSDATE)       
        );                        

      OPEN cr_crapcob(rw_npc_reproc.idtitleg);
      FETCH cr_crapcob INTO rw_crapcob;
      CLOSE cr_crapcob;

      UPDATE cecred.crapcob cob
      SET cob.idopeleg = vr_idopelegnovo
      WHERE ROWID = rw_crapcob.rowidcob;

      DBMS_OUTPUT.put_line('Sucesso - '||rw_npc_reproc.idtitleg||'  / '||vr_idopelegnovo);

    EXCEPTION
      WHEN Others THEN

        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao inserir na tabela TBCOBRAN_REMESSA_NPC. ' ||
                       sqlerrm;
                   
        DBMS_OUTPUT.put_line(vr_dscritic);  
        
        BEGIN
          NPCB0001.pc_gera_log_npc( pr_cdcooper => rw_npc_reproc.cdcooper,
                                    pr_nmrotina => 'Baca - Insere TBCOBRAN_REMESSA_NPC',
                                    pr_dsdolog  => 'IdTitleg:'||rw_npc_reproc.idtitleg||'-'||vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END; 
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowidcob
                                     ,pr_cdoperad => '1'
                                     ,pr_dtmvtolt => SYSDATE
                                     ,pr_dsmensag => 'BACA - Erro ao integrar instrucao na cabine JDNPC (OPTIT)'
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
    END;
  END LOOP;
  
  COMMIT;
  
END;
