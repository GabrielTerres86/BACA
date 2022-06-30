DECLARE  
  CURSOR cr_crapcob  IS
  SELECT cob.cdcooper,
         cob.nrdconta,
         cob.nrcnvcob,
         cob.nrdocmto,
         cob.vltitulo,
         cob.dtvencto,
         cob.dsinform,
         cob.incobran,
         cob.cdtitprt,
         cob.flgcbdda,
         cob.ininscip,
         cob.nrdident,
         cob.inenvcip,
         cob.insitpro, 
         cob.nrdctabb, 
         cob.cdbandoc, 
         cob.cdcartei,
         rowid
    FROM crapcob cob
    WHERE cob.incobran = 0
                    AND   cob.inenvcip = 2
                    AND   idtitleg in (73922420, 73922419, 73922418, 73922417);

   rw_crapcob cr_crapcob%ROWTYPE;

   vr_cdbarras VARCHAR2(60);    
   vr_lindigi1 NUMBER;
   vr_lindigi2 NUMBER;
   vr_lindigi3 NUMBER;
   vr_lindigi4 NUMBER;
   vr_lindigi5 NUMBER;

   vr_nrdocbenf     NUMBER;  
   vr_tppesbenf     VARCHAR2(100); 
   vr_dsbenefic     VARCHAR2(100); 
   vr_nrdocbenf_fin NUMBER;
   vr_tppesbenf_fin VARCHAR2(100);
   vr_dsbenefic_fin VARCHAR2(100);   
   vr_vlrtitulo     NUMBER;       
   vr_cdctrlcs      VARCHAR2(100);  
   vr_tbtitulocip   NPCB0001.typ_reg_titulocip;        
   vr_flblq_valor   INTEGER;
   vr_flgtitven     INTEGER;
   vr_flcontig      NUMBER;   
   vr_vlrjuros NUMBER;
   vr_vlrmulta NUMBER;
   vr_vldescto NUMBER;
   
   vr_cdcritic crapcri.cdcritic%TYPE;
   vr_dscritic VARCHAR2(4000);
   vr_des_erro VARCHAR2(4000);
   vr_situacao INTEGER;
   vr_idsacavalst NUMBER;
       
  BEGIN   
    
    FOR rw_crapcob IN cr_crapcob LOOP

      cobr0005.pc_calc_codigo_barras
                 (pr_dtvencto => rw_crapcob.dtvencto,
                  pr_cdbandoc => rw_crapcob.cdbandoc,
                  pr_vltitulo => rw_crapcob.vltitulo,
                  pr_nrcnvcob => rw_crapcob.nrcnvcob,
                  pr_nrcnvceb => 0,
                  pr_nrdconta => rw_crapcob.nrdconta,
                  pr_nrdocmto => rw_crapcob.nrdocmto,
                  pr_cdcartei => rw_crapcob.cdcartei,
                  pr_cdbarras => vr_cdbarras);


      vr_lindigi1 := 0;
      vr_lindigi2 := 0;
      vr_lindigi3 := 0;
      vr_lindigi4 := 0;
      vr_lindigi5 := 0;

      NPCB0002.pc_consultar_titulo_cip(pr_cdcooper      => rw_crapcob.cdcooper 
                                      ,pr_nrdconta      => rw_crapcob.nrdconta      
                                      ,pr_cdagenci      => 90
                                      ,pr_flmobile      => 0
                                      ,pr_dtmvtolt      => trunc(SYSDATE)
                                      ,pr_titulo1       => vr_lindigi1  
                                      ,pr_titulo2       => vr_lindigi2  
                                      ,pr_titulo3       => vr_lindigi3  
                                      ,pr_titulo4       => vr_lindigi4  
                                      ,pr_titulo5       => vr_lindigi5  
                                      ,pr_codigo_barras => vr_cdbarras  
                                      ,pr_cdoperad      => '1'
                                      ,pr_idorigem      => 3
                                      ,pr_nrdocbenf     => vr_nrdocbenf
                                      ,pr_tppesbenf     => vr_tppesbenf
                                      ,pr_dsbenefic     => vr_dsbenefic      
                                      ,pr_nrdocbenf_fin => vr_nrdocbenf_fin
                                      ,pr_tppesbenf_fin => vr_tppesbenf_fin
                                      ,pr_dsbenefic_fin => vr_dsbenefic_fin
                                      ,pr_idsacavalst   => vr_idsacavalst
                                      ,pr_vlrtitulo     => vr_vlrtitulo      
                                      ,pr_vlrjuros      => vr_vlrjuros       
                                      ,pr_vlrmulta      => vr_vlrmulta       
                                      ,pr_vlrdescto     => vr_vldescto      
                                      ,pr_cdctrlcs      => vr_cdctrlcs       
                                      ,pr_tbtitulocip   => vr_tbtitulocip    
                                      ,pr_flblq_valor   => vr_flblq_valor    
                                      ,pr_fltitven      => vr_flgtitven
                                      ,pr_flcontig      => vr_flcontig
                                      ,pr_des_erro      => vr_des_erro       
                                      ,pr_cdcritic      => vr_cdcritic       
                                      ,pr_dscritic      => vr_dscritic);     
                                                         
      IF vr_des_erro = 'OK' THEN
          dbms_output.put_line(vr_tbtitulocip.NumIdentcTit ||'-'|| vr_tbtitulocip.NumRefAtlCadTit);
          UPDATE crapcob cob
          SET cob.inenvcip = 3
             ,cob.nrdident = vr_tbtitulocip.NumIdentcTit
             ,cob.nratutit = vr_tbtitulocip.NumRefAtlCadTit
          WHERE rowid = rw_crapcob.rowid;             
          
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
                                     ,pr_cdoperad => '1'
                                     ,pr_dtmvtolt => SYSDATE
                                     ,pr_dsmensag => 'Titulo Registrado Manual - CIP'
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);          
      ELSE 
        dbms_output.put_line('Boleto não atualizado - '||rw_crapcob.cdcooper||'-'||rw_crapcob.nrdconta||'-'||rw_crapcob.nrdocmto  );        
      END IF;                    

    END LOOP;
    COMMIT;
  EXCEPTION 
    WHEN OTHERS THEN
      SISTEMA.excecaoInterna(pr_compleme => 'INC00106744');
      ROLLBACK;
  END ;
