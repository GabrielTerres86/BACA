DECLARE 

  CURSOR cr_crapass IS
   SELECT ass.cdcooper
        , ass.nrdconta
        , ass.nrdctitg
        , ass.flgctitg
        , dat.dtmvtolt
     FROM cecred.crapass ass
        , cecred.crapdat dat
    WHERE ass.cdcooper = dat.cdcooper
      AND ass.progress_recid IN (465388,465390,465391,465398,465411,465415,465418,465457,465465,465495
                                ,465506,465514,465528,465547,465568,465576,465591,465596,465604,465613
                                ,465618,465621,465629,465630,465638,465661,465669,465844,465864,465867
                                ,465869,465870,465888,465900,465907,465932,465964,466023,466037,466039
                                ,466086,466094,466101,466151,466154,466187,466188,466208,466295,466431
                                ,466437,466465,466518,466570,466673,466818,545824,762601,843822,465440
                                ,465632,465653,465657,465687,465710,465714,465732,465758,465902,465947
                                ,466021,466031,466214,466032,466071,466082,466096,466149,466169,466402
                                ,466407,466425,466852,466916,466920,539734,602528,606356,630522,630524
                                ,704892,722277,752511,759147,767240,782127,788519,803726,832561,843750
                                ,971971,985693,1348169,905899,910388,978119,981962,985541,993785,1091107
                                ,1113901,1124642,1189363);

  CURSOR cr_crapalt (pr_cdcooper cecred.crapalt.cdcooper%TYPE
                    ,pr_nrdconta cecred.crapalt.nrdconta%TYPE
                    ,pr_dtaltera cecred.crapalt.dtaltera%TYPE ) IS
    SELECT cdcooper
         , nrdconta
         , dsaltera
         , dtaltera
      FROM cecred.crapalt
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND trunc(dtaltera) = trunc(pr_dtaltera);

  vr_arq_path  VARCHAR2(1000):= cecred.gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/RITM0283478' ; 

  vr_nmarqbkp  VARCHAR2(100) := 'RITM0283478_ROLLBACK_Contas_ITG.txt';
  vr_nmarqcri  VARCHAR2(100) := 'RITM0283478_CRITICAS_Contas_ITG.txt';  

  vr_dstxtlid VARCHAR2(1000);
  vr_qtdctatt INTEGER := 0;
  vr_tab_linhacsv   gene0002.typ_split;

  rw_crapass  cr_crapass%rowtype;
  rw_crapalt  cr_crapalt%ROWTYPE;
  
  vr_dscritic VARCHAR(2000);
  vr_exc_erro EXCEPTION;

  vr_des_rollback_xml         CLOB;
  vr_texto_rb_completo  VARCHAR2(32600);
  vr_des_critic_xml         CLOB;
  vr_texto_cri_completo  VARCHAR2(32600);  
  
  PROCEDURE pc_escreve_xml_rollback(pr_des_dados IN VARCHAR2,
                                    pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_rollback_xml, vr_texto_rb_completo, pr_des_dados, pr_fecha_xml);
  END;

  PROCEDURE pc_escreve_xml_critica(pr_des_dados IN VARCHAR2,
                                   pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_critic_xml, vr_texto_cri_completo, pr_des_dados, pr_fecha_xml);
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
  
  FOR rw_crapass IN cr_crapass LOOP
    
    OPEN cr_crapalt(pr_cdcooper => rw_crapass.cdcooper
                   ,pr_nrdconta => rw_crapass.nrdconta
                   ,pr_dtaltera => rw_crapass.dtmvtolt);
    FETCH cr_crapalt INTO rw_crapalt;

    BEGIN
      IF (cr_crapalt%NOTFOUND) THEN
        INSERT INTO crapalt 
                (nrdconta
                ,dtaltera
                ,cdoperad
                ,dsaltera
                ,tpaltera
                ,flgctitg
                ,cdcooper)
              VALUES
                (rw_crapass.nrdconta
                ,trunc(rw_crapass.dtmvtolt)
                ,1
                ,'exclusao conta-itg('||rw_crapass.nrdctitg||')- ope.1'
                ,2 
                ,0 
                ,rw_crapass.cdcooper);
              
        pc_escreve_xml_rollback('DELETE FROM crapalt '||
                                ' WHERE cdcooper = ' || rw_crapass.cdcooper ||
                                '   AND nrdconta = ' || rw_crapass.nrdconta ||
                                '   AND dtaltera = ''' || to_char(rw_crapass.dtmvtolt, 'DD/MM/YYYY') || 
                                ''';'||chr(10));
              
      ELSE 
        pc_escreve_xml_rollback('UPDATE crapalt '||
                                ' SET dsaltera = ''' || rw_crapalt.dsaltera || 
                                ''' WHERE cdcooper = ' ||rw_crapass.cdcooper ||
                                '   AND nrdconta = ' || rw_crapass.nrdconta ||
                                '   AND dtaltera = ''' || to_char(rw_crapass.dtmvtolt, 'DD/MM/YYYY') || 
                                ''';'||chr(10));  
            
        UPDATE crapalt
           SET dsaltera = rw_crapalt.dsaltera || ',exclusao conta-itg('||rw_crapass.nrdctitg||')- ope.1,',
               flgctitg = 0,
               tpaltera = 2
         WHERE cdcooper = rw_crapass.cdcooper
           AND nrdconta = rw_crapass.nrdconta
           AND dtaltera = trunc(rw_crapass.dtmvtolt);
               
      END IF;

      UPDATE CRAPASS
         SET flgctitg = 3
       WHERE cdcooper = rw_crapass.cdcooper
         AND nrdconta = rw_crapass.nrdconta;
             
      pc_escreve_xml_rollback('UPDATE CRAPASS '||
                              'SET flgctitg = ' ||rw_crapass.flgctitg||
                              ' WHERE cdcooper = ' || rw_crapass.cdcooper ||
                              '   AND nrdconta = '|| rw_crapass.nrdconta ||';'||chr(10)); 


      vr_qtdctatt := vr_qtdctatt + 1;

    EXCEPTION
      WHEN OTHERS THEN
        pc_escreve_xml_critica('>>>> Erro ao processar registro da coop: ' || rw_crapass.cdcooper || ', conta: ' || rw_crapass.nrdconta ||chr(10));
        dbms_output.put_line(SQLERRM);
    END;

    CLOSE cr_crapalt;         
        
  END LOOP;
        
  COMMIT;
  
  pc_escreve_xml_critica(' ',TRUE);
        
  pc_escreve_xml_rollback('COMMIT;');
  pc_escreve_xml_rollback(' ',TRUE);
        
  gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_rollback_xml,
                                pr_caminho  => vr_arq_path,
                                pr_arquivo  => vr_nmarqbkp,
                                pr_des_erro => vr_dscritic);
                                      
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro ao gravar arquivo de rollback: '||vr_dscritic; 
    RAISE vr_exc_erro;
  END IF;
        
  gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_critic_xml,
                                pr_caminho  => vr_arq_path,
                                pr_arquivo  => vr_nmarqcri,
                                pr_des_erro => vr_dscritic);
                                      
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro ao gravar arquivo de criticas: '||vr_dscritic; 
    RAISE vr_exc_erro;
  END IF;
  
  dbms_lob.close(vr_des_rollback_xml);
  dbms_lob.freetemporary(vr_des_rollback_xml);

  dbms_lob.close(vr_des_critic_xml);
  dbms_lob.freetemporary(vr_des_critic_xml);
  
EXCEPTION 
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20001,vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000,'Erro geral: '||SQLERRM);
END;
