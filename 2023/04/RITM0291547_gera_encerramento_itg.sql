DECLARE 
  CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE
                      ,pr_nrdconta crapass.nrdconta%TYPE) IS
   SELECT ass.cdcooper, ass.nrdconta, ass.nrdctitg, ass.flgctitg, dat.dtmvtolt
    FROM   CECRED.CRAPASS ass, CECRED.crapdat dat
    WHERE ass.Cdcooper=dat.cdcooper
    AND ass.cdcooper = pr_cdcooper
    AND    ass.nrdconta = pr_nrdconta;

  CURSOR cr_crapalt (pr_cdcooper crapalt.cdcooper%TYPE
                    ,pr_nrdconta crapalt.nrdconta%TYPE
                    ,pr_dtaltera crapalt.dtaltera%TYPE ) IS
    SELECT cdcooper, nrdconta, dsaltera, dtaltera
      FROM CECRED.crapalt
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND trunc(dtaltera) = trunc(pr_dtaltera);

  vr_arq_path  VARCHAR2(1000):= gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/ritm0291547'; 


  vr_nmarquiv  VARCHAR2(100) := 'Contas_ITG.txt';
  vr_nmarqbkp  VARCHAR2(100) := 'ROLLBACK_Contas_ITG.txt';
  vr_nmarqcri  VARCHAR2(100) := 'CRITICAS_Contas_ITG.txt';  

  vr_hutlfile utl_file.file_type;
  vr_dstxtlid VARCHAR2(1000);
  vr_contador INTEGER := 0;
  vr_qtdctatt INTEGER := 0;
  vr_flagfind BOOLEAN := FALSE; 
  vr_tab_linhacsv   gene0002.typ_split;
  vr_dttransa    cecred.craplgm.dttransa%type;
  vr_hrtransa    cecred.craplgm.hrtransa%type;
  vr_cdoperad    cecred.craplgm.cdoperad%TYPE;
  vr_nrdrowid    ROWID;


  rw_crapass  cr_crapass%rowtype;
  rw_crapalt  cr_crapalt%ROWTYPE;
  vr_cdcooper crapass.cdcooper%TYPE;
  vr_nrdconta crapass.nrdconta%TYPE;

  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;
  vr_exc_clob EXCEPTION;
  vr_des_erro VARCHAR2(4000);


  vr_des_rollback_xml         CLOB;
  vr_texto_rb_completo  VARCHAR2(32600);
  vr_des_critic_xml         CLOB;
  vr_texto_cri_completo  VARCHAR2(32600);  
  
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
  

BEGIN 
  vr_des_rollback_xml := NULL;
  dbms_lob.createtemporary(vr_des_rollback_xml, TRUE);
  dbms_lob.open(vr_des_rollback_xml, dbms_lob.lob_readwrite);
  vr_texto_rb_completo := NULL;

  vr_des_critic_xml := NULL;
  dbms_lob.createtemporary(vr_des_critic_xml, TRUE);
  dbms_lob.open(vr_des_critic_xml, dbms_lob.lob_readwrite);
  vr_texto_cri_completo := NULL;
  
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := GENE0002.fn_busca_time;
  
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
        
        FOR rw_crapass IN cr_crapass(pr_cdcooper => vr_cdcooper
                                    ,pr_nrdconta => vr_nrdconta) LOOP
          
          vr_flagfind := TRUE;
          OPEN cr_crapalt(pr_cdcooper => vr_cdcooper
                        ,pr_nrdconta => vr_nrdconta
                        ,pr_dtaltera => rw_crapass.dtmvtolt);
          FETCH cr_crapalt INTO rw_crapalt;

          BEGIN
            IF (cr_crapalt%NOTFOUND) THEN
              INSERT INTO CECRED.crapalt 
                (nrdconta
                ,dtaltera
                ,cdoperad
                ,dsaltera
                ,tpaltera
                ,flgctitg
                ,cdcooper)
              VALUES
                (vr_nrdconta
                ,trunc(rw_crapass.dtmvtolt)
                ,1
                ,'exclusao conta-itg('||rw_crapass.nrdctitg||')- ope.1'
                ,2 
                ,0  
                ,vr_cdcooper);
              
              pc_escreve_xml_rollback('DELETE FROM crapalt '||
                       ' WHERE cdcooper = ' ||vr_cdcooper ||
                       '   AND nrdconta = ' || vr_nrdconta ||
                       '   AND dtaltera = to_date(''' || to_char(rw_crapass.dtmvtolt, 'DD/MM/YYYY') || 
                       ''',''dd/mm/yyyy'');'||chr(10));
              
            ELSE 
              pc_escreve_xml_rollback('UPDATE crapalt '||
                       ' SET dsaltera = ''' || rw_crapalt.dsaltera || 
                       ''' WHERE cdcooper = ' ||vr_cdcooper ||
                       '   AND nrdconta = ' || vr_nrdconta ||
                       '   AND dtaltera = ''' || to_char(rw_crapass.dtmvtolt, 'DD/MM/YYYY') || 
                       ''';'||chr(10));  
            
              UPDATE CECRED.crapalt
                 SET dsaltera = rw_crapalt.dsaltera || ',exclusao conta-itg('||rw_crapass.nrdctitg||')- ope.1,',
                     flgctitg = 0,
                     tpaltera = 2
               WHERE cdcooper = vr_cdcooper
                 AND nrdconta = vr_nrdconta
                 AND dtaltera = trunc(rw_crapass.dtmvtolt);
               
            END IF; 
            CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                                 pr_cdoperad => vr_cdoperad,
                                 pr_dscritic => vr_dscritic,
                                 pr_dsorigem => 'AIMARO',
                                 pr_dstransa => 'Alteracao do ITG de conta por script - RITM0257734',
                                 pr_dttransa => vr_dttransa,
                                 pr_flgtrans => 1,
                                 pr_hrtransa => vr_hrtransa,
                                 pr_idseqttl => 0,
                                 pr_nmdatela => NULL,
                                 pr_nrdconta => vr_nrdconta,
                                 pr_nrdrowid => vr_nrdrowid);
  
       CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                 pr_nmdcampo => 'crapass.flgctitg',
                                 pr_dsdadant => rw_crapass.flgctitg,
                                 pr_dsdadatu => 3);

            UPDATE CECRED.CRAPASS
            SET    flgctitg = 3
            WHERE  cdcooper = vr_cdcooper
            AND    nrdconta = vr_nrdconta;
             
            pc_escreve_xml_rollback('UPDATE CRAPASS '||
                              'SET flgctitg = ' ||rw_crapass.flgctitg||
                           ' WHERE cdcooper = ' ||vr_cdcooper||
                           '   AND nrdconta = '||vr_nrdconta||';'||chr(10)); 


            vr_qtdctatt := vr_qtdctatt + 1;

          EXCEPTION
           WHEN OTHERS THEN
             pc_escreve_xml_critica('>>>> Erro ao processar registro da coop: ' || vr_cdcooper || ', conta: ' || vr_nrdconta ||chr(10));
             dbms_output.put_line(SQLERRM);
          END;

          CLOSE cr_crapalt;         
        
        END LOOP;
        
        IF NOT vr_flagfind THEN
          pc_escreve_xml_critica('>>>> Erro ao processar registro da coop: ' || vr_cdcooper || ', conta: ' || vr_nrdconta || ' - Conta não encontrada.' ||chr(10));
        END IF;
        
        IF mod(vr_qtdctatt,100) = 0 THEN
          COMMIT;
          dbms_output.put_line('Commit de ' || vr_qtdctatt || ' registros.');   
        END IF;
        
      END LOOP; 

      COMMIT;

    EXCEPTION 
      WHEN no_data_found THEN 
        pc_escreve_xml_critica('Qtde contas lidas:'||vr_contador||chr(10));
        pc_escreve_xml_critica('Qtde contas atualizadas:'||vr_qtdctatt);
        pc_escreve_xml_critica(' ',TRUE);
        
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
  
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
  WHEN vr_exc_clob THEN
    dbms_output.put_line('Erro inesperado 2 - ' || vr_des_erro);
    cecred.pc_internal_exception;
    ROLLBACK;
  WHEN OTHERS THEN
    dbms_output.put_line('Erro inesperado 3 - ' || SQLERRM);    
    cecred.pc_internal_exception;
    ROLLBACK;
END;
