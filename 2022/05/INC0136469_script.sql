DECLARE
  
  CURSOR cr_crapcob (pr_idtitleg IN crapcob.idtitleg%type) IS
    SELECT  cob.rowid rowidcob
      FROM crapcob cob
     WHERE cob.idtitleg = pr_idtitleg;
  rw_crapcob cr_crapcob%ROWTYPE;   

  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(100);

  vr_idopelegnovo crapcob.idopeleg%type;
  
BEGIN

  FOR rw_npc_reproc IN (
 SELECT trn.*
    FROM tbcobran_remessa_npc trn
    WHERE (trn.idtitleg, trn.idopeleg) IN
     ((46220130, 134518994),
(61448886,  134485874),
(61448895,  134485882),
(62149183,  134487820),
(62149186,  134485878),
(62149198,  134487821),
(62149199,  134485879),
(72394169,  134054856),
(73358512,  134054857),
(74012543,  134086591),
(74012545,  134086592),
(74012546,  134086590),
(56095305,  134518995),
(61796193,  134518989),
(61796194,  134518990),
(61796195,  134485872),
(61796196,  134485873),
(66780006,  134518996),
(66780044,  134518999),
(66780121,  134519000),
(66780143,  134519001),
(66780176,  134485880),
(66780229,  134516820),
(66780250,  134485883),
(66780272,  134516821),
(66780295,  134516822),
(66780332,  134518991),
(66780335,  134516823),
(66780349,  134518992),
(66780350,  134516824),
(66780365,  134518993),
(66780367,  134516825),
(66780422,  134485875),
(66780444,  134485876),
(66780459,  134485881),
(66780478,  134516826),
(66780515,  134516827),
(70412121,  134487815),
(71711438,  133729670),
(71711460,  133727960),
(71711461,  133727959),
(71965656,  133745803),
(71969334,  133911769),
(72299453,  134054855),
(72497416,  133745804),
(72497417,  133729669),
(73843234,  133730019),
(59553065,  134487819),
(59553068,  134485877),
(64434005,  134518997),
(66157279,  134516819),
(66901573,  134022955),
(70770745,  134487816),
(70770747,  134487817),
(72278741,  134022956),
(74232388,  134516816),
(60040734,  134487818),
(63771644,  133872263),
(63771645,  133890397),
(64877323,  134359982),
(64877324,  134372816),
(65682579,  134518998),
(66524296,  134241724),
(70845980,  134054854),
(71986302,  133727961),
(72256837,  134347170),
(73575696,  134068769),
(73905588,  133901140),
(74084172,  134347168),
(74084173,  134347169),
(74084214,  134241721))                  )   LOOP

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

      UPDATE crapcob cob
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
