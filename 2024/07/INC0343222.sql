DECLARE
  
  vr_cdcriticGeral       cecred.crapcri.cdcritic%type;
  vr_dscriticGeral       cecred.crapcri.dscritic%type;
  vr_cdcooper            cecred.crapcop.cdcooper%type;
  vr_nrdconta            cecred.crapass.nrdconta%type;
  vr_cdagenew            number;
  vr_vldcotasGeral       cecred.crapcot.vldcotas%type;
  vr_dtmvtolt            cecred.crapdat.dtmvtolt%type;
  vr_arq_path            VARCHAR2(1000):= cecred.gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/INC0343222';
  vr_nmarquiv            VARCHAR2(100) := 'transf_pa_evolua.txt';
  vr_nmarqbkp            VARCHAR2(100) := 'INC0343222_script_rollback_test.sql';
  vr_nmarqcri            VARCHAR2(100) := 'INC0343222_script_log_test.txt';
  
  vr_hutlfile            utl_file.file_type;
  vr_dstxtlid            VARCHAR2(1000);
  vr_contador            INTEGER := 0;
  vr_qtdctatt            INTEGER := 0;
  vr_flagfind            BOOLEAN := FALSE;
  vr_tab_linhacsv        cecred.gene0002.typ_split;
  vr_vet_dados           SISTEMA.tipoSplit.typ_split;
  vr_dstextab            varchar2(4000);
  vr_dsdrowid            VARCHAR2(50);

  vr_flarqrol            utl_file.file_type;
  vr_flarqlog            utl_file.file_type;
  vr_des_rollback_xml    CLOB;
  vr_texto_rb_completo   VARCHAR2(32600);
  vr_des_critic_xml      CLOB;
  vr_texto_cri_completo  VARCHAR2(32600);  
  
  vr_exc_erro            EXCEPTION;
  vr_exc_clob            EXCEPTION;
  vr_des_erroGeral       VARCHAR2(4000);

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
  
  
  PROCEDURE TrocaPA(pr_cdcooper  IN  crapass.cdcooper%TYPE
                   ,pr_nrdconta  IN  crapass.nrdconta%TYPE
                   ,pr_cdagenew  IN  number
                   ,o_erro       OUT VARCHAR2) IS
           
           
    CURSOR cr_crapass(pr_cdcooper number, pr_nrdconta number) is
      SELECT a.cdcooper
           , a.nrdconta
           , a.cdagenci
           , ROWID dsdrowid
        FROM CECRED.CRAPASS a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta;
    conta cr_crapass%rowtype;
  
    CURSOR cr_altera(pr_cdcooper  NUMBER
                    ,pr_nrdconta  NUMBER
                    ,pr_dtmvtolt  DATE) IS
      SELECT t.dsaltera
           , ROWID  dsdrowid
        FROM cecred.crapalt t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND t.dtaltera = pr_dtmvtolt;
    rg_altera  cr_altera%ROWTYPE;        
  
    vr_flarqrol    utl_file.file_type;
    vr_flarqlog    utl_file.file_type;
  
    TYPE vr_tpaltdel IS TABLE OF VARCHAR2(2000) INDEX BY VARCHAR2(50);
    TYPE vr_tpaltupd IS TABLE OF VARCHAR2(2000) INDEX BY VARCHAR2(50);
  
    vr_tbaltdel    vr_tpaltdel;
    vr_tbaltupd    vr_tpaltupd;
    vr_dsindice    VARCHAR2(50);
    vr_dtmvtolt    DATE := datascooperativa(14).dtmvtolt;
    vr_lgrowid     ROWID;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(2000);
    vr_exc_erro    EXCEPTION;
  
  BEGIN
    
  open cr_crapass(pr_cdcooper, pr_nrdconta);
  fetch cr_crapass into conta;
  if cr_crapass%found THEN
     BEGIN 
         UPDATE CECRED.crapass t SET t.cdagenci = pr_cdagenew
                                   , t.dtultalt = vr_dtmvtolt
          WHERE ROWID = conta.dsdrowid;
        
          pc_escreve_xml_rollback(chr(10)||'  UPDATE cecred.crapass SET cdagenci = '||to_char(conta.cdagenci)||'  WHERE rowid = '''||conta.dsdrowid||'''; ');
     EXCEPTION
          WHEN OTHERS THEN
               vr_dscritic := 'Erro ao atualizar PA: '||SQLERRM;
               RAISE vr_exc_erro;
       END;
    
       gene0001.pc_gera_log(pr_cdcooper => conta.cdcooper
                           ,pr_cdoperad => '1'
                           ,pr_dscritic => ' '
                           ,pr_dsorigem => 'AIMARO'
                           ,pr_dstransa => 'Altera dados da Conta Corrente'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 1
                           ,pr_hrtransa => gene0002.fn_busca_time
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => ''
                           ,pr_nrdconta => conta.nrdconta
                           ,pr_nrdrowid => vr_lgrowid);
      
       gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                ,pr_nmdcampo => 'cdagenci'
                                ,pr_dsdadant => conta.cdagenci
                                ,pr_dsdadatu => pr_cdagenew);
  
       gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                ,pr_nmdcampo => 'dtultalt'
                                ,pr_dsdadant => NULL
                                ,pr_dsdadatu => to_char(vr_dtmvtolt,'dd/mm/yyyy'));
    
       pc_escreve_xml_rollback(chr(10)||'  DELETE cecred.craplgi i WHERE EXISTS (SELECT 1 FROM cecred.craplgm m WHERE m.rowid = '''||vr_lgrowid||''' '
                                                      || ' AND i.cdcooper = m.cdcooper AND i.nrdconta = m.nrdconta AND i.idseqttl = m.idseqttl AND '
                                                      || ' i.dttransa = m.dttransa AND i.hrtransa = m.hrtransa AND i.nrsequen = m.nrsequen);');
    
       pc_escreve_xml_rollback(chr(10)||'  DELETE cecred.craplgm WHERE rowid = '''||vr_lgrowid||'''; '); 
     
       OPEN  cr_altera(conta.cdcooper,conta.nrdconta,vr_dtmvtolt);
       FETCH cr_altera INTO rg_altera;
      
       IF cr_altera%NOTFOUND THEN
        
          BEGIN
            INSERT INTO cecred.crapalt
                             (nrdconta
                             ,dtaltera
                             ,cdoperad
                             ,dsaltera
                             ,tpaltera
                             ,cdcooper)
                      VALUES (conta.nrdconta
                             ,vr_dtmvtolt
                            ,'1'
                            ,'PA '||conta.cdagenci||'-'||pr_cdagenew||','
                            ,2
                            ,conta.cdcooper) RETURNING ROWID INTO rg_altera.dsdrowid;
          
            IF NOT vr_tbaltdel.EXISTS(rg_altera.dsdrowid) THEN
               vr_tbaltdel(rg_altera.dsdrowid) := '  DELETE cecred.crapalt WHERE rowid = '''||rg_altera.dsdrowid||'''; ';
            END IF;     
                      
          EXCEPTION
            WHEN OTHERS THEN
                raise_application_error(-20003,'Erro ao incluir registro na ALTERA: '||SQLERRM);
          END;
        
       ELSE
        
          BEGIN
            UPDATE cecred.crapalt SET dsaltera = rg_altera.dsaltera||'PA '||conta.cdagenci||'-'||pr_cdagenew||','
             WHERE ROWID    = rg_altera.dsdrowid;
          
            IF NOT vr_tbaltupd.EXISTS(rg_altera.dsdrowid) THEN
               vr_tbaltupd(rg_altera.dsdrowid) := '  UPDATE cecred.crapalt SET dsaltera = '''||rg_altera.dsaltera||''' WHERE rowid = '''||rg_altera.dsdrowid||'''; ';
            END IF;
                           
          EXCEPTION
            WHEN OTHERS THEN
            raise_application_error(-20004,'Erro ao atualizar registro na ALTERA: '||SQLERRM);
          END;
        
       END IF;
       
     IF vr_tbaltupd.count() > 0 THEN
          vr_dsindice := vr_tbaltupd.FIRST;
          LOOP
      
              pc_escreve_xml_rollback(chr(10)||vr_tbaltupd(vr_dsindice));
    
           EXIT WHEN vr_dsindice = vr_tbaltupd.LAST;
              vr_dsindice := vr_tbaltupd.NEXT(vr_dsindice);
           END LOOP;
       END IF;
    
       IF vr_tbaltdel.count() > 0 THEN
          vr_dsindice := vr_tbaltdel.FIRST;
          LOOP
      
             pc_escreve_xml_rollback(chr(10)||vr_tbaltdel(vr_dsindice));
    
          EXIT WHEN vr_dsindice = vr_tbaltdel.LAST;
             vr_dsindice := vr_tbaltdel.NEXT(vr_dsindice);
          END LOOP;
       END IF;
     CLOSE cr_altera;    
  
  
  end if;
  
  EXCEPTION
      WHEN vr_exc_erro THEN
         o_erro := vr_dscritic;
         raise_application_error(-20001, vr_dscritic);
      WHEN OTHERS THEN
         o_erro := sqlerrm;
         raise_application_error(-20000,'ERRO AO EXECUTAR SCRIPT: '||SQLERRM);
  END TrocaPA;
        
  

BEGIN
    CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path
                          ,pr_nmarquiv => vr_nmarquiv
                          ,pr_tipabert => 'R'
                          ,pr_utlfileh => vr_hutlfile
                          ,pr_des_erro => vr_dscriticGeral);

  IF vr_dscriticGeral IS NOT NULL THEN
    vr_dscriticGeral := 'Erro na leitura do arquivo -> '||vr_dscriticGeral;
    pc_escreve_xml_critica(vr_dscriticGeral || chr(10));
    RAISE vr_exc_erro;
  END IF;

  vr_des_rollback_xml := NULL;
  dbms_lob.createtemporary(vr_des_rollback_xml, TRUE);
  dbms_lob.open(vr_des_rollback_xml, dbms_lob.lob_readwrite);
  vr_texto_rb_completo := NULL;

  vr_des_critic_xml := NULL;
  dbms_lob.createtemporary(vr_des_critic_xml, TRUE);
  dbms_lob.open(vr_des_critic_xml, dbms_lob.lob_readwrite);
  vr_texto_cri_completo := NULL;
  
  

  IF utl_file.IS_OPEN(vr_hutlfile) THEN
    BEGIN
      LOOP
        
        vr_cdcooper := 0;
        vr_nrdconta := 0;
		vr_cdagenew := 0;

        CECRED.gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_hutlfile
                                           ,pr_des_text => vr_dstxtlid);

        IF length(vr_dstxtlid) <= 1 THEN
          continue;
        END IF;

        vr_contador := vr_contador + 1;
        vr_flagfind := FALSE;

        vr_tab_linhacsv := CECRED.gene0002.fn_quebra_string(vr_dstxtlid,';');
        vr_cdcooper := CECRED.gene0002.fn_char_para_number(vr_tab_linhacsv(1));
        vr_nrdconta := CECRED.gene0002.fn_char_para_number(vr_tab_linhacsv(2));
        vr_cdagenew := CECRED.gene0002.fn_char_para_number(vr_tab_linhacsv(3));
        
        vr_dtmvtolt := sistema.datascooperativa(vr_cdcooper).dtmvtolt;

        IF nvl(vr_cdcooper,0) = 0 OR nvl(vr_nrdconta,0) = 0 THEN
          pc_escreve_xml_critica('Erro ao encontrar cooperativa e conta ' || vr_dstxtlid  || chr(10));
        END IF;               
        
		if vr_cdagenew is not null then
           TrocaPA(vr_cdcooper
                  ,vr_nrdconta
                  ,vr_cdagenew
                  ,vr_dscriticGeral);
		end if;
                    
        IF TRIM(vr_dscriticGeral) IS NOT NULL THEN
           pc_escreve_xml_critica('Não foi possível efetuar a troca do PA (' || vr_cdcooper || '/' || vr_nrdconta || '). ' || vr_dscriticGeral);
        END IF;
        
        vr_qtdctatt := vr_qtdctatt + 1;
        
        IF mod(vr_qtdctatt,100) = 0 THEN
          COMMIT;
          dbms_output.put_line('Commit de ' || vr_qtdctatt || ' registros.');
        END IF;
        
      END LOOP;      

    EXCEPTION
      WHEN no_data_found THEN
        

        pc_escreve_xml_rollback(chr(10)||'COMMIT;');
        pc_escreve_xml_rollback(' ',TRUE);

        CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);

        CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_rollback_xml,
                                      pr_caminho  => vr_arq_path,
                                      pr_arquivo  => vr_nmarqbkp,
                                      pr_des_erro => vr_des_erroGeral);
        IF (vr_des_erroGeral IS NOT NULL) THEN
          dbms_lob.close(vr_des_rollback_xml);
          dbms_lob.freetemporary(vr_des_rollback_xml);
          RAISE vr_exc_clob;
        END IF;

        CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_critic_xml,
                                      pr_caminho  => vr_arq_path,
                                      pr_arquivo  => vr_nmarqcri,
                                      pr_des_erro => vr_des_erroGeral);
        IF (vr_des_erroGeral IS NOT NULL) THEN
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

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;

    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);

    raise_application_error(-20001, vr_dscriticGeral);

  WHEN OTHERS THEN
    ROLLBACK;

    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);

    raise_application_error(-20000,'ERRO AO EXECUTAR SCRIPT: '||SQLERRM);  
END;
