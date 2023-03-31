declare
      
 vr_cdcooper          cecred.crapcop.cdcooper%type;
 vr_nrdconta          cecred.crapass.nrdconta%type;
 rw_crapdat           cecred.BTCH0001.cr_crapdat%ROWTYPE;
 
 vr_cdcritic          cecred.crapcri.cdcritic%type;
 vr_dscritic          cecred.crapcri.dscritic%type;
 vr_nrdrowid          ROWID;
 vr_cdoperad          cecred.craplgm.cdoperad%TYPE;
 vr_dttransa          cecred.craplgm.dttransa%type;
 vr_hrtransa          cecred.craplgm.hrtransa%type;
 vr_arq_path  VARCHAR2(1000):= gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/inc0261870'; 
 vr_nmarquiv  VARCHAR2(100) := 'Contas_LancFuturoTarifa.txt';
 vr_nmarqbkp  VARCHAR2(100) := 'ROLLBACK_LancFuturoTarifa.txt';
 vr_nmarqcri  VARCHAR2(100) := 'CRITICAS_LancFuturoTarifa.txt';  
 vr_hutlfile utl_file.file_type;
 vr_dstxtlid VARCHAR2(1000);
 vr_contador INTEGER := 0;
 vr_qtdctatt INTEGER := 0;
 vr_qtdlancfutatt INTEGER := 0;
 vr_flagfind BOOLEAN := FALSE; 
 vr_tab_linhacsv   gene0002.typ_split;
 vr_des_rollback_xml         CLOB;
 vr_texto_rb_completo  VARCHAR2(32600);
 vr_des_critic_xml         CLOB;
 vr_texto_cri_completo  VARCHAR2(32600);  
 
 vc_dstransaTar       CONSTANT VARCHAR2(4000) := 'Baixa das Tarifas pendentes a lancar em Conta encerrada - INC0261870';
 vc_cdmotest          CONSTANT cecred.craplat.cdmotest%TYPE := 3;
 vc_insitlat          CONSTANT cecred.craplat.insitlat%TYPE := 3;
 vc_cdopeest          CONSTANT cecred.craplat.cdopeest%TYPE := 1;
 
  vr_exc_erro EXCEPTION;
  vr_exc_clob EXCEPTION;
  vr_des_erro VARCHAR2(4000);
        
 CURSOR cr_tar_fut(pr_cdcooper in cecred.crapcop.cdcooper%type,
                   pr_nrdconta in cecred.crapass.nrdconta%type) IS
   SELECT craplat.cdcooper
         ,craplat.nrdconta
         ,craplat.cdmotest
         ,craplat.dtdestor
         ,craplat.cdopeest
         ,craplat.cdlantar
         ,craplat.insitlat
     FROM craplat craplat
    WHERE craplat.cdcooper = pr_cdcooper  
      AND craplat.nrdconta = pr_nrdconta 
      AND craplat.insitlat = 1;

  PROCEDURE pc_escreve_xml_rollback(pr_des_dados IN VARCHAR2,
                                    pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    CECRED.gene0002.pc_escreve_xml(vr_des_rollback_xml, vr_texto_rb_completo, pr_des_dados, pr_fecha_xml);
  END;

  PROCEDURE pc_escreve_xml_critica(pr_des_dados IN VARCHAR2,
                                   pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    CECRED.gene0002.pc_escreve_xml(vr_des_critic_xml, vr_texto_cri_completo, pr_des_dados, pr_fecha_xml);
  END;

Begin
  vr_des_rollback_xml := NULL;
  dbms_lob.createtemporary(vr_des_rollback_xml, TRUE);
  dbms_lob.open(vr_des_rollback_xml, dbms_lob.lob_readwrite);
  vr_texto_rb_completo := NULL;

  vr_des_critic_xml := NULL;
  dbms_lob.createtemporary(vr_des_critic_xml, TRUE);
  dbms_lob.open(vr_des_critic_xml, dbms_lob.lob_readwrite);
  vr_texto_cri_completo := NULL;
    
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := CECRED.GENE0002.fn_busca_time;

  OPEN CECRED.BTCH0001.cr_crapdat(pr_cdcooper => 1);
  FETCH CECRED.BTCH0001.cr_crapdat INTO rw_crapdat;
  IF CECRED.BTCH0001.cr_crapdat%NOTFOUND THEN
     CLOSE CECRED.BTCH0001.cr_crapdat;
     RAISE_APPLICATION_ERROR(-20001,'Erro abrir data para cooperativa:' || vr_cdcooper || ' - ' || sqlerrm);
  ELSE
     CLOSE CECRED.BTCH0001.cr_crapdat;
  END IF;

  CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   
                          ,pr_nmarquiv => vr_nmarquiv   
                          ,pr_tipabert => 'R'           
                          ,pr_utlfileh => vr_hutlfile   
                          ,pr_des_erro => vr_dscritic); 
                          
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro na leitura do arquivo -> '||vr_dscritic;
    pc_escreve_xml_critica(vr_dscritic || chr(10));
    RAISE vr_exc_erro;
  END IF; 
    
  IF utl_file.IS_OPEN(vr_hutlfile) THEN
    BEGIN   
      LOOP  
        vr_cdcooper := 0;
        vr_nrdconta := 0;

        CECRED.gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_hutlfile 
                                    ,pr_des_text => vr_dstxtlid); 
       
        IF length(vr_dstxtlid) <= 1 THEN 
          continue;
        END IF;
        
        vr_contador := vr_contador + 1;
        vr_flagfind := FALSE;
        
        vr_tab_linhacsv := gene0002.fn_quebra_string(vr_dstxtlid,';');
        vr_cdcooper := gene0002.fn_char_para_number(vr_tab_linhacsv(1));
        vr_nrdconta := gene0002.fn_char_para_number(vr_tab_linhacsv(2));       
        
        IF nvl(vr_cdcooper,0) = 0 OR nvl(vr_nrdconta,0) = 0 THEN 
          pc_escreve_xml_critica('Erro ao encontrar cooperativa e conta ' || vr_dstxtlid  || chr(10));
          CONTINUE;
        END IF;

        FOR rw_tar_fut in cr_tar_fut(vr_cdcooper, vr_nrdconta) LOOP
          
          IF NOT vr_flagfind THEN
            vr_flagfind := TRUE;
          END IF;
        
          vr_nrdrowid := null;
          
          CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                                 pr_cdoperad => vr_cdoperad,
                                 pr_dscritic => vr_dscritic,
                                 pr_dsorigem => 'AIMARO',
                                 pr_dstransa => vc_dstransaTar,
                                 pr_dttransa => vr_dttransa,
                                 pr_flgtrans => 1,
                                 pr_hrtransa => vr_hrtransa,
                                 pr_idseqttl => 0,
                                 pr_nmdatela => NULL,
                                 pr_nrdconta => vr_nrdconta,
                                 pr_nrdrowid => vr_nrdrowid);
                                 
          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                           pr_nmdcampo => 'craplat.DTDESTOR',
                                           pr_dsdadant => rw_tar_fut.dtdestor,
                                           pr_dsdadatu => rw_crapdat.dtmvtolt);

          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                           pr_nmdcampo => 'craplat.INSITLAT',
                                           pr_dsdadant => rw_tar_fut.insitlat,
                                           pr_dsdadatu => vc_insitlat);

          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                           pr_nmdcampo => 'craplat.CDMOTEST',
                                           pr_dsdadant => rw_tar_fut.cdmotest,
                                           pr_dsdadatu => vc_cdmotest);

          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                           pr_nmdcampo => 'craplat.CDOPEEST',
                                           pr_dsdadant => rw_tar_fut.cdopeest,
                                           pr_dsdadatu => vc_cdopeest);

          UPDATE cecred.craplat lat
             SET lat.insitlat = vc_insitlat
                ,lat.cdmotest = vc_cdmotest 
                ,lat.dtdestor = rw_crapdat.dtmvtolt
                ,lat.cdopeest = vc_cdopeest
           WHERE lat.cdcooper = rw_tar_fut.cdcooper
             AND lat.nrdconta = rw_tar_fut.nrdconta
             and lat.cdlantar = rw_tar_fut.cdlantar;
          
          vr_qtdlancfutatt := vr_qtdlancfutatt + 1;
          
          pc_escreve_xml_rollback('UPDATE cecred.craplat lat '|| chr(10) ||
                                  '   SET lat.insitlat = ' || nvl(rw_tar_fut.insitlat,'1') || chr(10) ||
                                  '      ,lat.cdmotest = ' || nvl(rw_tar_fut.cdmotest,'0') || chr(10) ||
                                  '      ,lat.dtdestor = ' || case 
                                                                when trim(rw_tar_fut.dtdestor) is null then
                                                                  'null'
                                                                else
                                                                  'to_date(''' || to_char(rw_tar_fut.dtdestor, 'DD/MM/YYYY') || ''',''dd/mm/yyyy'')'
                                                              end || chr(10) ||
                                  '      ,lat.cdopeest = ' || '''' || nvl(rw_tar_fut.cdopeest,' ') || '''' || chr(10) ||
                                  ' WHERE lat.cdcooper = ' || rw_tar_fut.cdcooper || chr(10) ||
                                  '   AND lat.nrdconta = ' || rw_tar_fut.nrdconta || chr(10) ||
                                  '   and lat.cdlantar = ' || rw_tar_fut.cdlantar || ';'||chr(10)||chr(10));
                                  
          
         
        END LOOP; 
             
        IF NOT vr_flagfind THEN
          pc_escreve_xml_critica('>>>> Erro ao processar registro da coop: ' || vr_cdcooper || ', conta: ' || vr_nrdconta || ' - Lancamento Futuro não encontrado.' ||chr(10));
        ELSE
          vr_qtdctatt := vr_qtdctatt + 1;
        END IF;
        
      END LOOP; 
    EXCEPTION 
      WHEN no_data_found THEN 
        pc_escreve_xml_critica('Qtde contas lidas:'||vr_contador||chr(10));
        pc_escreve_xml_critica('Qtde contas atualizadas:'||vr_qtdctatt||chr(10));
        pc_escreve_xml_critica('Qtde lancamentos futuros (tarifas) atualizadas:'||vr_qtdlancfutatt);
        pc_escreve_xml_critica(' ',TRUE);
        
        pc_escreve_xml_rollback('DELETE FROM cecred.craplgi i ' || chr(10) ||
                                ' where (i.cdcooper,i.nrdconta,i.nrsequen,i.dttransa,i.hrtransa) in ' || chr(10) ||
                                '(select l.cdcooper,l.nrdconta,l.nrsequen,l.dttransa,l.hrtransa from craplgm l ' || chr(10) ||
                                '  where l.dstransa = ''Baixa das Tarifas pendentes a lancar em Conta encerrada - INC0261870'');' || chr(10) || chr(10));
   
        pc_escreve_xml_rollback('DELETE FROM cecred.craplgm l ' || chr(10) ||
                                ' where l.dstransa = ''Baixa das Tarifas pendentes a lancar em Conta encerrada - INC0261870'';' || chr(10) || chr(10));   
        pc_escreve_xml_rollback('COMMIT;');
        pc_escreve_xml_rollback(' ',TRUE);
        
        CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);
        
        CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_rollback_xml,
                                      pr_caminho  => vr_arq_path,
                                      pr_arquivo  => vr_nmarqbkp,
                                      pr_des_erro => vr_des_erro);
        IF (vr_des_erro IS NOT NULL) THEN
          dbms_lob.close(vr_des_rollback_xml);
          dbms_lob.freetemporary(vr_des_rollback_xml);
          RAISE vr_exc_clob;
        END IF;
        
        CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_critic_xml,
                                      pr_caminho  => vr_arq_path,
                                      pr_arquivo  => vr_nmarqcri,
                                      pr_des_erro => vr_des_erro);
        IF (vr_des_erro IS NOT NULL) THEN
          dbms_lob.close(vr_des_critic_xml);
          dbms_lob.freetemporary(vr_des_critic_xml);
          RAISE vr_exc_clob;
        END IF;

        dbms_lob.close(vr_des_rollback_xml);
        dbms_lob.freetemporary(vr_des_rollback_xml);

        dbms_lob.close(vr_des_critic_xml);
        dbms_lob.freetemporary(vr_des_critic_xml);

        dbms_output.put_line('Rotina finalizada, verifique arquivo de criticas em :' || vr_arq_path);
      WHEN OTHERS THEN
        dbms_output.put_line('Erro inesperado 1 - ' || SQLERRM);
        cecred.pc_internal_exception;
    END;  
  END IF;  
       
  COMMIT;
  
Exception
  WHEN vr_exc_erro THEN
    ROLLBACK;
  WHEN vr_exc_clob THEN
    dbms_output.put_line('Erro inesperado 2 - ' || vr_des_erro);
    cecred.pc_internal_exception;
    ROLLBACK;
  when others then
    RAISE_APPLICATION_ERROR(-20000,'Erro baixar lancamento futuro da Cooperativa/Conta: ' || sqlerrm);
end; 
