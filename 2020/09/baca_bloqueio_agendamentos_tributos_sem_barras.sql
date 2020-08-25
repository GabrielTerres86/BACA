DECLARE

  CURSOR cr_darf (pr_cdcooper IN craplau.cdcooper%TYPE,
                  pr_dtmvtopg IN craplau.dtmvtopg%TYPE) IS
    SELECT l.rowid,
           l.nrdconta,
           a.cdagenci,
           l.dtmvtopg,
           d.dtapuracao,
           d.nrcpfcgc,
           d.cdtributo,
           d.nrrefere,
           d.dtvencto,
           d.vlprincipal,
           d.vlmulta,
           d.vljuros,
           l.vllanaut,
           a.inpessoa 
      FROM craplau l, tbpagto_agend_darf_das d, crapass a
     WHERE l.cdcooper  = pr_cdcooper 
       AND l.dtmvtopg  = pr_dtmvtopg
       AND l.insitlau  = 1
       AND l.cdtiptra  = 10
       AND d.idlancto  = l.idlancto
       AND d.tpcaptura = 2
       AND a.cdcooper  = l.cdcooper 
       AND a.nrdconta  = l.nrdconta;
  rw_darf cr_darf%ROWTYPE; 
       
  CURSOR cr_gps (pr_cdcooper IN craplau.cdcooper%TYPE,
                 pr_dtmvtopg IN craplau.dtmvtopg%TYPE) IS     
    SELECT l.rowid,
           l.cdcooper,
           l.nrdconta,
           l.nrseqagp,
           a.cdagenci,
           l.dtmvtopg,
           g.dtvencto,
           g.cddpagto,
           g.mmaacomp,
           g.cdidenti2,
           g.vlrdinss,
           g.vlrouent,
           g.vlrjuros,
           g.vlrtotal,
           a.inpessoa           
      FROM craplau l, craplgp g, crapass a
     WHERE l.cdcooper  = pr_cdcooper 
       AND l.dtmvtopg  = pr_dtmvtopg
       AND l.insitlau  = 1
       AND l.nrseqagp  > 0
       AND l.dscodbar = ' ' 
       AND l.dslindig = ' '
       AND g.cdcooper = l.cdcooper
       AND g.nrctapag = l.nrdconta
       AND g.nrseqagp = l.nrseqagp
       AND a.cdcooper = l.cdcooper
       AND a.nrdconta = l.nrdconta;
  rw_gps cr_gps%ROWTYPE; 
       
  CURSOR cr_crapcop IS
    SELECT c.cdcooper,
           c.nmrescop
      FROM crapcop c
     WHERE c.flgativo = 1;    
  rw_crapcop cr_crapcop%ROWTYPE;    
  
  CURSOR cr_craptfc (pr_cdcooper IN crapass.cdcooper%TYPE,
                     pr_nrdconta IN crapass.nrdconta%TYPE,
                     pr_inpessoa IN crapass.inpessoa%TYPE) IS
    SELECT t.nrtelefo,
           t.nrdddtfc
      FROM craptfc t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta
  ORDER BY t.idseqttl,
           decode(pr_inpessoa,2,decode(t.tptelefo,3,-1,2,0,t.tptelefo),t.tptelefo),
           t.cdseqtfc;
  rw_craptfc cr_craptfc%ROWTYPE;  
  
  vr_dtmvtopg DATE;
  vr_dtlimite DATE;  
    
  vr_cdcooper  craplgp.cdcooper%TYPE;
  vr_dtmvtolt  craplgp.dtmvtolt%TYPE;
  vr_cdagenci  craplgp.cdagenci%TYPE;
  vr_cdbccxlt  craplgp.cdbccxlt%TYPE;
  vr_nrdolote  craplgp.nrdolote%TYPE;
  vr_cdidenti  craplgp.cdidenti%TYPE;
  vr_mmaacomp  craplgp.mmaacomp%TYPE;
  vr_vlrdinss  craplgp.vlrdinss%TYPE;
  vr_vlrouent  craplgp.vlrouent%TYPE;
  vr_vlrjuros  craplgp.vlrjuros%TYPE;
  vr_vlrtotal  craplgp.vlrtotal%TYPE;
  vr_cdopecxa  craplgp.cdopecxa%TYPE;
  vr_nrdcaixa  craplgp.nrdcaixa%TYPE;
  vr_nrdmaqui  craplgp.nrdmaqui%TYPE;
  vr_nrautdoc  craplgp.nrautdoc%TYPE;
  vr_nrseqdig  craplgp.nrseqdig%TYPE;
  vr_flgenvio  craplgp.flgenvio%TYPE;
  vr_hrtransa  craplgp.hrtransa%TYPE;
  vr_cddpagto  craplgp.cddpagto%TYPE;
  vr_idsicred  craplgp.idsicred%TYPE;
  vr_cdbarras  craplgp.cdbarras%TYPE;
  vr_nrctapag  craplgp.nrctapag%TYPE;
  vr_nrseqagp  craplgp.nrseqagp%TYPE;
  vr_inpesgps  craplgp.inpesgps%TYPE;
  vr_tpdpagto  craplgp.tpdpagto%TYPE;
  vr_dslindig  craplgp.dslindig%TYPE;
  vr_dtvencto  craplgp.dtvencto%TYPE;
  vr_nrsequni  craplgp.nrsequni%TYPE;
  vr_dstiparr  craplgp.dstiparr%TYPE;
  vr_flgpagto  craplgp.flgpagto%TYPE;
  vr_tpleitur  craplgp.tpleitur%TYPE;
  vr_flgativo  craplgp.flgativo%TYPE;
  vr_nrautsic  craplgp.nrautsic%TYPE;
  vr_idanafrd  craplgp.idanafrd%TYPE;
  vr_idseqttl  craplgp.idseqttl%TYPE;
  vr_tppagmto  craplgp.tppagmto%TYPE;
  vr_cdidenti2 craplgp.cdidenti2%TYPE;  
  
  vr_insituacao        tbinss_agendamento_gps.insituacao%TYPE;
  vr_dtcancelamento    tbinss_agendamento_gps.dtcancelamento%TYPE;
  vr_cdoperador_cancel tbinss_agendamento_gps.cdoperador_cancel%TYPE;
  
  vr_hutlfile utl_file.file_type;
  vr_hutlrgps utl_file.file_type;
  vr_hutlrdar utl_file.file_type;
  vr_dsdireto VARCHAR2(100);
  vr_nmarqrbk VARCHAR2(100);
  vr_nmrelgps VARCHAR2(100);
  vr_nmreldar VARCHAR2(100);
  vr_dslinreg VARCHAR2(4000);
  vr_nrrefere VARCHAR2(20);
  vr_dtcompet VARCHAR2(7);
  vr_nrtelefo VARCHAR2(100);  
  
  vr_exc_erro EXCEPTION;
  vr_dscritic VARCHAR2(4000);
                                     
BEGIN     
  
  vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'M', pr_cdcooper => 3, pr_nmsubdir => 'david');
  vr_nmarqrbk := 'RDM0036155_rollback_baca_bloqueio_agendamentos.sql';
  vr_dtlimite := TO_DATE('16/09/2030','DD/MM/RRRR'); 
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto || '/'
                          ,pr_nmarquiv => vr_nmarqrbk   
                          ,pr_tipabert => 'W'           
                          ,pr_utlfileh => vr_hutlfile   
                          ,pr_des_erro => vr_dscritic); 
                          
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro ao criar script de rollback';
    RAISE vr_exc_erro;
  END IF;

  FOR rw_crapcop IN cr_crapcop LOOP
    
    vr_nmrelgps := 'BLOQUEIO_GPS_'  || REPLACE(rw_crapcop.nmrescop,' ','') || '.csv';
    vr_nmreldar := 'BLOQUEIO_DARF_' || REPLACE(rw_crapcop.nmrescop,' ','') || '.csv';
    vr_dtmvtopg := TO_DATE('16/09/2020','DD/MM/RRRR');
    
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto || '/'
                            ,pr_nmarquiv => vr_nmrelgps   
                            ,pr_tipabert => 'W'           
                            ,pr_utlfileh => vr_hutlrgps   
                            ,pr_des_erro => vr_dscritic); 
                            
    IF vr_dscritic IS NOT NULL THEN
      vr_dscritic := 'Erro ao criar relatório de GPS - ' || vr_nmrelgps;
      RAISE vr_exc_erro;
    END IF;    
    
    vr_dslinreg := 'Conta;PA;Telefone;Data Agendamento;Data Vencimento;Codigo Pagamento;Competência;Identificador;Valor INSS;Valor Outras Entidades;ATM/Multa e Juros;Valor Total' ;         
    gene0001.pc_escr_linha_arquivo(vr_hutlrgps, vr_dslinreg);    
    
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto || '/'
                            ,pr_nmarquiv => vr_nmreldar   
                            ,pr_tipabert => 'W'           
                            ,pr_utlfileh => vr_hutlrdar   
                            ,pr_des_erro => vr_dscritic); 
                            
    IF vr_dscritic IS NOT NULL THEN
      vr_dscritic := 'Erro ao criar relatório de DARF - ' || vr_nmreldar;
      RAISE vr_exc_erro;
    END IF;     
    
    vr_dslinreg := 'Conta;PA;Telefone;Data Agendamento;Periodo Apuracao;Numero CPF/CNPJ;Codigo Receita;Numero Referencia;Data Vencimento;Valor Principal;Valor Multa;Valor Juros;Valor Total' ;         
    gene0001.pc_escr_linha_arquivo(vr_hutlrdar, vr_dslinreg);        
    
    WHILE vr_dtmvtopg <= vr_dtlimite LOOP
      
      FOR rw_darf IN cr_darf (pr_cdcooper => rw_crapcop.cdcooper,
                              pr_dtmvtopg => vr_dtmvtopg) LOOP
                              
        OPEN cr_craptfc (pr_cdcooper => rw_crapcop.cdcooper,
                         pr_nrdconta => rw_darf.nrdconta,
                         pr_inpessoa => rw_darf.inpessoa);        
        FETCH cr_craptfc INTO rw_craptfc;

        IF cr_craptfc%FOUND THEN
          IF NVL(rw_craptfc.nrdddtfc,0) <> 0  THEN
            vr_nrtelefo := '('||rw_craptfc.nrdddtfc ||')';
          END IF;

          vr_nrtelefo := vr_nrtelefo || rw_craptfc.nrtelefo;
        ELSE
          vr_nrtelefo := ' ';
        END IF;
        CLOSE cr_craptfc;                              
                             
        IF NVL(rw_darf.nrrefere,0) = 0 THEN
          vr_nrrefere := ' ';
        ELSE
          vr_nrrefere := TO_CHAR(rw_darf.nrrefere);  
        END IF;
               
        vr_dslinreg := rw_darf.nrdconta    || ';' ||
                       rw_darf.cdagenci    || ';' ||
                       vr_nrtelefo         || ';' ||
                       rw_darf.dtmvtopg    || ';' ||                       
                       rw_darf.dtapuracao  || ';' ||
                       rw_darf.nrcpfcgc    || ';' ||
                       rw_darf.cdtributo   || ';' ||
                       vr_nrrefere         || ';' ||
                       rw_darf.dtvencto    || ';' ||
                       rw_darf.vlprincipal || ';' ||
                       rw_darf.vlmulta     || ';' ||
                       rw_darf.vljuros     || ';' ||
                       rw_darf.vllanaut;        
        gene0001.pc_escr_linha_arquivo(vr_hutlrdar, vr_dslinreg);                               
                                      
        UPDATE craplau l 
           SET l.insitlau = 4, 
               l.dtdebito = TRUNC(SYSDATE), 
               l.dscritic = 'Convênio bloqueado para pagamento' 
         WHERE l.rowid = rw_darf.rowid;
         
        vr_dslinreg := 'UPDATE craplau l SET l.insitlau = 1, l.dtdebito = NULL, l.dscritic = '''' WHERE l.rowid = ''' || rw_darf.rowid || ''';' ;         
        gene0001.pc_escr_linha_arquivo(vr_hutlfile, vr_dslinreg);          
         
      END LOOP;
      
      FOR rw_gps IN cr_gps (pr_cdcooper => rw_crapcop.cdcooper,
                            pr_dtmvtopg => vr_dtmvtopg) LOOP
                            
        OPEN cr_craptfc (pr_cdcooper => rw_crapcop.cdcooper,
                         pr_nrdconta => rw_gps.nrdconta,
                         pr_inpessoa => rw_gps.inpessoa);        
        FETCH cr_craptfc INTO rw_craptfc;

        IF cr_craptfc%FOUND THEN
          IF NVL(rw_craptfc.nrdddtfc,0) <> 0  THEN
            vr_nrtelefo := '('||rw_craptfc.nrdddtfc ||')';
          END IF;

          vr_nrtelefo := vr_nrtelefo || rw_craptfc.nrtelefo;
        ELSE
          vr_nrtelefo := ' ';
        END IF;
        CLOSE cr_craptfc;                             
                            
        vr_dtcompet := LPAD(TO_CHAR(rw_gps.mmaacomp),6,'0');
        vr_dtcompet := SUBSTR(vr_dtcompet,1,2) || '/' || SUBSTR(vr_dtcompet,3,4);
                            
        vr_dslinreg := rw_gps.nrdconta  || ';' ||
                       rw_gps.cdagenci  || ';' ||
                       vr_nrtelefo      || ';' ||
                       rw_gps.dtmvtopg  || ';' ||
                       rw_gps.dtvencto  || ';' ||
                       rw_gps.cddpagto  || ';' ||
                       vr_dtcompet      || ';' ||
                       rw_gps.cdidenti2 || ';' ||
                       rw_gps.vlrdinss  || ';' ||
                       rw_gps.vlrouent  || ';' ||
                       rw_gps.vlrjuros  || ';' ||
                       rw_gps.vlrtotal;        
        gene0001.pc_escr_linha_arquivo(vr_hutlrgps, vr_dslinreg);                             
                            
        UPDATE craplau l 
           SET l.insitlau = 4, 
               l.dtdebito = TRUNC(SYSDATE), 
               l.dscritic = 'Convênio bloqueado para pagamento' 
         WHERE l.rowid = rw_gps.rowid;    
         
        vr_dslinreg := 'UPDATE craplau l SET l.insitlau = 1, l.dtdebito = NULL, l.dscritic = '''' WHERE l.rowid = ''' || rw_gps.rowid || ''';' ;         
        gene0001.pc_escr_linha_arquivo(vr_hutlfile, vr_dslinreg);     
        
        vr_cdcooper := NULL;    
         
        DELETE craplgp g           
         WHERE g.cdcooper = rw_gps.cdcooper
           AND g.nrctapag = rw_gps.nrdconta
           AND g.nrseqagp = rw_gps.nrseqagp
           AND g.flgpagto = 0
        RETURNING g.cdcooper,g.dtmvtolt,g.cdagenci,g.cdbccxlt,g.nrdolote,g.cdidenti,g.mmaacomp,g.vlrdinss,g.vlrouent,g.vlrjuros,g.vlrtotal,g.cdopecxa,g.nrdcaixa,g.nrdmaqui,g.nrautdoc,g.nrseqdig,g.flgenvio,g.hrtransa,g.cddpagto,g.idsicred,g.cdbarras,g.nrctapag,g.nrseqagp,g.inpesgps,g.tpdpagto,g.dslindig,g.dtvencto,g.nrsequni,g.dstiparr,g.flgpagto,g.tpleitur,g.flgativo,g.nrautsic,g.idanafrd,g.idseqttl,g.tppagmto,g.cdidenti2
        INTO vr_cdcooper,vr_dtmvtolt,vr_cdagenci,vr_cdbccxlt,vr_nrdolote,vr_cdidenti,vr_mmaacomp,vr_vlrdinss,vr_vlrouent,vr_vlrjuros,vr_vlrtotal,vr_cdopecxa,vr_nrdcaixa,vr_nrdmaqui,vr_nrautdoc,vr_nrseqdig,vr_flgenvio,vr_hrtransa,vr_cddpagto,vr_idsicred,vr_cdbarras,vr_nrctapag,vr_nrseqagp,vr_inpesgps,vr_tpdpagto,vr_dslindig,vr_dtvencto,vr_nrsequni,vr_dstiparr,vr_flgpagto,vr_tpleitur,vr_flgativo,vr_nrautsic,vr_idanafrd,vr_idseqttl,vr_tppagmto,vr_cdidenti2;
           
        IF vr_cdcooper IS NOT NULL THEN
          IF vr_idanafrd IS NULL THEN
            vr_dslinreg := 'INSERT INTO craplgp(cdcooper,dtmvtolt,cdagenci,cdbccxlt,nrdolote,cdidenti,mmaacomp,vlrdinss,vlrouent,vlrjuros,vlrtotal,cdopecxa,nrdcaixa,nrdmaqui,nrautdoc,nrseqdig,flgenvio,hrtransa,cddpagto,idsicred,cdbarras,nrctapag,nrseqagp,inpesgps,tpdpagto,dslindig,dtvencto,nrsequni,dstiparr,flgpagto,tpleitur,flgativo,nrautsic,idseqttl,tppagmto,cdidenti2) ' ||
                           'VALUES('||vr_cdcooper||',to_date('''||to_char(vr_dtmvtolt,'dd/mm/rrrr')||''',''dd/mm/rrrr''),'||vr_cdagenci||','||vr_cdbccxlt||','||vr_nrdolote||','||vr_cdidenti||','||vr_mmaacomp||','||REPLACE(TO_CHAR(vr_vlrdinss,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=,.'),',','.')||','||REPLACE(TO_CHAR(vr_vlrouent,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=,.'),',','.')||','||REPLACE(TO_CHAR(vr_vlrjuros,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=,.'),',','.')||','||REPLACE(TO_CHAR(vr_vlrtotal,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=,.'),',','.')||','''||vr_cdopecxa||''','||vr_nrdcaixa||','||vr_nrdmaqui||','||vr_nrautdoc||','||vr_nrseqdig||','||vr_flgenvio||','||vr_hrtransa||','||vr_cddpagto||','||vr_idsicred||','''||vr_cdbarras||''','||vr_nrctapag||','||vr_nrseqagp||','||vr_inpesgps||','||vr_tpdpagto||','''||vr_dslindig||''',to_date('''||to_char(vr_dtvencto,'dd/mm/rrrr')||''',''dd/mm/rrrr''),'||vr_nrsequni||','''||vr_dstiparr||''','||vr_flgpagto||','||vr_tpleitur||','||vr_flgativo||','||vr_nrautsic||','||vr_idseqttl||','||vr_tppagmto||','''||vr_cdidenti2||''''|| ');' ;
            gene0001.pc_escr_linha_arquivo(vr_hutlfile, vr_dslinreg);           
          ELSE
            vr_dslinreg := 'INSERT INTO craplgp(cdcooper,dtmvtolt,cdagenci,cdbccxlt,nrdolote,cdidenti,mmaacomp,vlrdinss,vlrouent,vlrjuros,vlrtotal,cdopecxa,nrdcaixa,nrdmaqui,nrautdoc,nrseqdig,flgenvio,hrtransa,cddpagto,idsicred,cdbarras,nrctapag,nrseqagp,inpesgps,tpdpagto,dslindig,dtvencto,nrsequni,dstiparr,flgpagto,tpleitur,flgativo,nrautsic,idanafrd,idseqttl,tppagmto,cdidenti2) ' ||
                           'VALUES('||vr_cdcooper||',to_date('''||to_char(vr_dtmvtolt,'dd/mm/rrrr')||''',''dd/mm/rrrr''),'||vr_cdagenci||','||vr_cdbccxlt||','||vr_nrdolote||','||vr_cdidenti||','||vr_mmaacomp||','||REPLACE(TO_CHAR(vr_vlrdinss,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=,.'),',','.')||','||REPLACE(TO_CHAR(vr_vlrouent,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=,.'),',','.')||','||REPLACE(TO_CHAR(vr_vlrjuros,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=,.'),',','.')||','||REPLACE(TO_CHAR(vr_vlrtotal,'FM9999999999990D00','NLS_NUMERIC_CHARACTERS=,.'),',','.')||','''||vr_cdopecxa||''','||vr_nrdcaixa||','||vr_nrdmaqui||','||vr_nrautdoc||','||vr_nrseqdig||','||vr_flgenvio||','||vr_hrtransa||','||vr_cddpagto||','||vr_idsicred||','''||vr_cdbarras||''','||vr_nrctapag||','||vr_nrseqagp||','||vr_inpesgps||','||vr_tpdpagto||','''||vr_dslindig||''',to_date('''||to_char(vr_dtvencto,'dd/mm/rrrr')||''',''dd/mm/rrrr''),'||vr_nrsequni||','''||vr_dstiparr||''','||vr_flgpagto||','||vr_tpleitur||','||vr_flgativo||','||vr_nrautsic||','||vr_idanafrd||','||vr_idseqttl||','||vr_tppagmto||','''||vr_cdidenti2||''''|| ');' ;
            gene0001.pc_escr_linha_arquivo(vr_hutlfile, vr_dslinreg); 
          END IF;
        END IF;
         
        vr_cdcooper := NULL;
        
        UPDATE tbinss_agendamento_gps a
           SET a.insituacao        = 1,  
               a.dtcancelamento    = TRUNC(SYSDATE),
               a.cdoperador_cancel = '1'
         WHERE a.cdcooper = rw_gps.cdcooper
           AND a.nrdconta = rw_gps.nrdconta
           AND a.nrseqagp = rw_gps.nrseqagp
        RETURNING a.cdcooper INTO vr_cdcooper;
        
        IF vr_cdcooper IS NOT NULL THEN   
          vr_dslinreg := 'UPDATE tbinss_agendamento_gps a SET a.insituacao = 0, a.dtcancelamento = NULL, a.cdoperador_cancel = ''''' ||
                         ' WHERE a.cdcooper = ' || rw_gps.cdcooper || 
                           ' AND a.nrdconta = ' || rw_gps.nrdconta || 
                           ' AND a.nrseqagp = ' || rw_gps.nrseqagp || ';' ;         
          gene0001.pc_escr_linha_arquivo(vr_hutlfile, vr_dslinreg);            
        END IF;
           
      END LOOP;      
      
      vr_dtmvtopg := vr_dtmvtopg + 1;
      
    END LOOP;
    
    IF utl_file.IS_OPEN(vr_hutlrgps) THEN
      -- Fechar arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlrgps);
    END IF; 
    
    IF utl_file.IS_OPEN(vr_hutlrdar) THEN
      -- Fechar arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlrdar);
    END IF;      
    
  END LOOP;
  
  vr_dslinreg := 'COMMIT;';
  gene0001.pc_escr_linha_arquivo(vr_hutlfile, vr_dslinreg);
  
  IF utl_file.IS_OPEN(vr_hutlfile) THEN
    -- Fechar arquivo
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);
  END IF;  
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    dbms_output.put_line(vr_dscritic);
    
    IF utl_file.IS_OPEN(vr_hutlfile) THEN
      -- Fechar arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);
    END IF;    
    
    IF utl_file.IS_OPEN(vr_hutlrgps) THEN
      -- Fechar arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlrgps);
    END IF; 
    
    IF utl_file.IS_OPEN(vr_hutlrdar) THEN
      -- Fechar arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlrdar);
    END IF;         
    
    ROLLBACK;
  WHEN OTHERS THEN
    vr_dscritic := 'Erro não tratado: ' || SQLERRM;
    dbms_output.put_line(vr_dscritic);
    
    IF utl_file.IS_OPEN(vr_hutlfile) THEN
      -- Fechar arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);
    END IF;    
    
    IF utl_file.IS_OPEN(vr_hutlrgps) THEN
      -- Fechar arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlrgps);
    END IF; 
    
    IF utl_file.IS_OPEN(vr_hutlrdar) THEN
      -- Fechar arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlrdar);
    END IF;       
    
    cecred.pc_internal_exception;
    
    ROLLBACK;  
   
END;
      
