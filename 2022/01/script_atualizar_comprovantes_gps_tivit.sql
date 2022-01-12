DECLARE
  CURSOR cr_registros IS
    SELECT DISTINCT 
           b.idsicredi, 
           a.dtmvtolt, 
           b.cdempresa_documento,
           SUBSTR(b.dsprocessamento,-39) dsautent,
           TRIM(a.dsprotoc) dsprotoc,
           b.cdcooper,
           b.nrdconta
      FROM crappro a
     INNER JOIN tbconv_registro_remessa_pagfor b
        ON b.cdcooper = a.cdcooper
       AND b.nrdconta = a.nrdconta
       AND b.nrautenticacao_documento = a.nrseqaut
     WHERE a.dtmvtolt = '20/12/2021'
       AND b.idremessa = 158729
       AND a.dscomprovante_parceiro IS NULL
       AND b.cdstatus_processamento = 3
       AND UPPER(a.dsprotoc) NOT LIKE '%ESTORNADO%';
    rw_registro cr_registros%ROWTYPE;

  CURSOR cr_craplgp(pr_idsicredi   IN tbconv_registro_remessa_pagfor.idsicredi%TYPE,
                    pr_dtmovimento IN tbconv_remessa_pagfor.dtmovimento%TYPE) IS  
    SELECT lgp.dtmvtolt
          ,lgp.vlrtotal
          ,lgp.cdcooper
          ,lgp.nrctapag
          ,lgp.cdagenci
          ,lgp.cddpagto
          ,lgp.cdidenti2
          ,lgp.mmaacomp
          ,lgp.vlrdinss
          ,lgp.vlrouent
          ,lgp.vlrjuros
      FROM craplgp lgp
     WHERE lgp.idsicred = pr_idsicredi
       AND lgp.dtmvtolt = pr_dtmovimento;
   rw_craplgp cr_craplgp%ROWTYPE;
   
   vr_idsicredi      tbconv_registro_remessa_pagfor.idsicredi%TYPE;
   vr_dtmovimento    tbconv_remessa_pagfor.dtmovimento%TYPE;
   pr_cdempres       tbconv_registro_remessa_pagfor.cdempresa_documento%TYPE;
   pr_cdagente       NUMBER(3) := 341;
   pr_dtcomprovante  DATE;
   pr_dsautenticacao VARCHAR2(100);
   vr_dsprotoc       crappro.dsprotoc%TYPE;
   vr_dscomprovante  crappro.dscomprovante_parceiro%TYPE;
   vr_exec_saida     EXCEPTION;
   vr_dscritic      VARCHAR2(4000);
   
 BEGIN
   
   FOR rw_registro IN cr_registros LOOP
     
     vr_dscomprovante := ' ';
     vr_idsicredi := rw_registro.idsicredi;
     vr_dtmovimento := rw_registro.dtmvtolt;
     pr_cdempres := rw_registro.cdempresa_documento;
     pr_dsautenticacao := rw_registro.dsautent;
     pr_dtcomprovante := SYSDATE;
     vr_dsprotoc := rw_registro.dsprotoc;
     
     IF pr_cdempres = 'C06' THEN -- GPS Sem Barras 
        OPEN cr_craplgp(pr_idsicredi => vr_idsicredi, pr_dtmovimento => vr_dtmovimento);
          FETCH cr_craplgp INTO rw_craplgp; 
          
            IF cr_craplgp%NOTFOUND THEN
              CLOSE cr_craplgp;
              RAISE vr_exec_saida;
            END IF;        
            
        CLOSE cr_craplgp;                            
            
        PAGA0003.pc_comprovante_darf_gps_tivit (pr_cdcooper  => rw_craplgp.cdcooper,
                                                pr_nrdconta  => rw_craplgp.nrctapag,
                                                pr_cdagenci  => rw_craplgp.cdagenci,
                                                pr_dtmvtolt  => vr_dtmovimento,
                                                pr_cdempres  => pr_cdempres,
                                                pr_cdagente  => pr_cdagente,
                                                pr_dttransa  => pr_dtcomprovante,
                                                pr_hrtransa  => TO_NUMBER(TO_CHAR(pr_dtcomprovante,'sssss')),
                                                pr_dsprotoc  => vr_dsprotoc,
                                                pr_dsautent  => pr_dsautenticacao,
                                                pr_idsicred  => vr_idsicredi,
                                                pr_nrsequen  => 0,
                                                pr_cdtribut  => ' ',
                                                pr_nrrefere  => ' ',
                                                pr_vllanmto  => 0,
                                                pr_vlrjuros  => rw_craplgp.vlrjuros,
                                                pr_vlrmulta  => 0,
                                                pr_vlrtotal  => rw_craplgp.vlrtotal,
                                                pr_nrcpfcgc  => ' ',
                                                pr_dtapurac  => NULL,
                                                pr_dtlimite  => NULL,
                                                pr_cddpagto  => rw_craplgp.cddpagto,
                                                pr_cdidenti2 => rw_craplgp.cdidenti2,
                                                pr_mmaacomp  => rw_craplgp.mmaacomp,
                                                pr_vlrdinss  => rw_craplgp.vlrdinss,
                                                pr_vlrouent  => rw_craplgp.vlrouent,
                                                pr_flgcaixa  => FALSE,
                                                pr_dscomprv  => vr_dscomprovante);
                                                
           IF NVL(vr_dscomprovante,' ') <>  ' ' THEN
              GENE0006.pc_grava_comprovante_parceiro (pr_cdcooper               => rw_registro.cdcooper,
                                                      pr_dsprotoc               => vr_dsprotoc,
                                                      pr_dscomprovante_parceiro => vr_dscomprovante,
                                                      pr_dscritic               => vr_dscritic);
                                                     
              IF TRIM(vr_dscritic) IS NOT NULL THEN
                vr_dscritic := vr_dscritic || ' - IDArrecadacao: ' || vr_idsicredi;
                RAISE vr_exec_saida;
              END IF;

              GENE0006.pc_grava_arrecadador_parceiro (pr_cdcooper => rw_registro.cdcooper,
                                                      pr_nrdconta => rw_registro.nrdconta,
                                                      pr_dsprotoc => vr_dsprotoc,
                                                      pr_cdagente => pr_cdagente,
                                                      pr_dscritic => vr_dscritic);
              IF TRIM(vr_dscritic) IS NOT NULL THEN
                vr_dscritic := vr_dscritic || ' (pc_grava_arrecadador_parceiro) - IDArrecadacao: ' || vr_idsicredi;
                RAISE vr_exec_saida;
              END IF;
            END IF;
        END IF;
      END LOOP;
      
      COMMIT;
      
EXCEPTION
  WHEN vr_exec_saida THEN 
    ROLLBACK;
    dbms_output.put_line(vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line(vr_dscritic);
 END;
