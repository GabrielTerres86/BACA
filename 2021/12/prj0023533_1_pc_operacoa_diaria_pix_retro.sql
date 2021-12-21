CREATE OR REPLACE PROCEDURE CECRED.pc_operacoa_diaria_pix_retro(pr_cdcooper IN crapcop.cdcooper%TYPE
                                                               ,pr_idparale IN crappar.idparale%TYPE
                                                               ,pr_idprogra IN crappar.idprogra%TYPE ) IS

  ------------------------------- VARIAVEIS ---------------------------------
  vr_dataini DATE := TO_DATE('01/01/2021', 'DD/MM/RRRR');
  vr_datafim DATE := TO_DATE('19/12/2021', 'DD/MM/RRRR');
  pr_dscritic          VARCHAR2(5000) := ' ';
  vr_dscritic          VARCHAR2(5000) := ' ';  
  vr_nmarqimp2         VARCHAR2(100) := ' ';
  vr_nmarqimp3         VARCHAR2(100) := ' ';
  vr_nmarqimp22        VARCHAR2(100)  := 'loga_';
  vr_nmarqimp33        VARCHAR2(100)  := 'erro_';
  vr_rootmicros        VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS'); -- '/progress/f0033330/micros/'; --
  vr_nmdireto          VARCHAR2(4000) := vr_rootmicros || 'cpd/bacas/prj0023533';
  vr_excsaida          EXCEPTION;

  vr_des_xml_1         CLOB;
  vr_des_xml_2         CLOB;
  vr_des_xml_3         CLOB;
  vr_texto_completo_1  VARCHAR2(32600);
  vr_texto_completo_2  VARCHAR2(32600);
  vr_texto_completo_3  VARCHAR2(32600);

  PROCEDURE loga (pr_msg VARCHAR2) IS
  BEGIN
--      GENE0001.pc_escr_linha_arquivo(vr_ind_arquiv2, pr_msg);
    gene0002.pc_escreve_xml(pr_xml => vr_des_xml_2,
                            pr_texto_completo => vr_texto_completo_2,
                            pr_texto_novo => pr_msg || chr(10),
                            pr_fecha_xml => FALSE);

  END;

  PROCEDURE erro (pr_msg VARCHAR2) IS
  BEGIN
--      GENE0001.pc_escr_linha_arquivo(vr_ind_arquiv3, pr_msg);
    gene0002.pc_escreve_xml(pr_xml => vr_des_xml_3,
                            pr_texto_completo => vr_texto_completo_3,
                            pr_texto_novo => pr_msg || chr(10),
                            pr_fecha_xml => FALSE);

  END;

  PROCEDURE abre_arquivos IS
  BEGIN
    vr_nmarqimp2 := pr_cdcooper || '_' || vr_nmarqimp22 ||to_char(sysdate,'HH24MISS');
    vr_nmarqimp3 := pr_cdcooper || '_' || vr_nmarqimp33 ||to_char(sysdate,'HH24MISS');

    vr_des_xml_1 := NULL;
    dbms_lob.createtemporary(vr_des_xml_1, TRUE);
    dbms_lob.open(vr_des_xml_1, dbms_lob.lob_readwrite);

    vr_des_xml_2 := NULL;
    dbms_lob.createtemporary(vr_des_xml_2, TRUE);
    dbms_lob.open(vr_des_xml_2, dbms_lob.lob_readwrite);

    vr_des_xml_3 := NULL;
    dbms_lob.createtemporary(vr_des_xml_3, TRUE);
    dbms_lob.open(vr_des_xml_3, dbms_lob.lob_readwrite);
  END;

  PROCEDURE fecha_arquivos IS
    vr_dscritic VARCHAR2(1000);
  BEGIN

    --- arq 1
    gene0002.pc_escreve_xml(pr_xml            => vr_des_xml_1,
                            pr_texto_completo => vr_texto_completo_1,
                            pr_texto_novo     => ' ',
                            pr_fecha_xml      => TRUE);

    dbms_lob.close(vr_des_xml_1);
    dbms_lob.freetemporary(vr_des_xml_1);


    --- arq 2
    gene0002.pc_escreve_xml(pr_xml            => vr_des_xml_2,
                            pr_texto_completo => vr_texto_completo_2,
                            pr_texto_novo     => ' ',
                            pr_fecha_xml      => TRUE);
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml_2
                                 ,pr_caminho  => vr_nmdireto
                                 ,pr_arquivo  => vr_nmarqimp2 || '.txt'
                                 ,pr_des_erro => vr_dscritic);
    dbms_lob.close(vr_des_xml_2);
    dbms_lob.freetemporary(vr_des_xml_2);

    --- arq 3
    gene0002.pc_escreve_xml(pr_xml            => vr_des_xml_3,
                            pr_texto_completo => vr_texto_completo_3,
                            pr_texto_novo     => ' ',
                            pr_fecha_xml      => TRUE);
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml_3
                                 ,pr_caminho  => vr_nmdireto
                                 ,pr_arquivo  => vr_nmarqimp3 || '.txt'
                                 ,pr_des_erro => vr_dscritic);
    dbms_lob.close(vr_des_xml_3);
    dbms_lob.freetemporary(vr_des_xml_3);

  END;

BEGIN

  /* ####################################################################### */
  /* ############              INICIO               ######################## */
  /* ####################################################################### */
  abre_arquivos;
  loga('Inicio do processo de inserção de operações diaria retroativas para cooperativa ' || pr_cdcooper || ': ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
  loga('Inicio do delete da operação 24 e 25: ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
  
  DELETE FROM tbcc_operacoes_diarias
  WHERE cdoperacao IN (24, 25)
    AND cdcooper = pr_cdcooper;
   
  loga('Fim do delete da operação 24 e 25: ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));   
  loga('Inicio do insert da operação 24: ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
  
  BEGIN
    INSERT INTO cecred.tbcc_operacoes_diarias
    (cdcooper,
    nrdconta,
    cdoperacao,
    dtoperacao,
    nrsequen,
    flgisencao_tarifa)
    (SELECT lcm.cdcooper,
            lcm.nrdconta,
            24,
            lcm.dtmvtolt,
            COUNT(lcm.nrdconta) qtd,
            0
    FROM craplcm lcm
    WHERE lcm.cdhistor IN (3318,
                           3320,
                           3371,
                           3373,
                           3450,
                           3671,
                           3677,
                           3675,
                           3396,
                           3397,
                           3437,
                           3438,
                           3468)
      AND lcm.dtmvtolt BETWEEN vr_dataini AND vr_datafim
      AND lcm.cdcooper = pr_cdcooper
    GROUP BY lcm.cdcooper, lcm.nrdconta, lcm.dtmvtolt);
        
    EXCEPTION       
      WHEN OTHERS THEN
        erro('Erro ao inserir registros na tabela tbcc_operacoes_diarias para operação 24. '||SQLERRM);
        loga('Insert da operação 24 finalizado com erro: ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
        --Levantar Exceção
        RAISE vr_excsaida;
    END;
    
    loga('Insert da operação 24 finalizado com sucesso: ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
    loga('Inicio do insert da operação 25: ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
    
    BEGIN
      INSERT INTO cecred.tbcc_operacoes_diarias
      (cdcooper,
      nrdconta,
      cdoperacao,
      dtoperacao,
      nrsequen,
      flgisencao_tarifa)
      (SELECT lcm.cdcooper,
              lcm.nrdconta,
              25,
              lcm.dtmvtolt,
              COUNT(lcm.nrdconta) qtd,
              0
      FROM craplcm lcm
      WHERE lcm.cdhistor IN (3319,
                             3321,
                             3322,
                             3323,
                             3377,
                             3375,
                             3379,
                             3380,
                             3451,
                             3452,
                             3453,
                             3673,
                             3681,
                             3684,
                             3683,
                             3679,
                             3435,
                             3436,
                             3469,
                             3470)
       AND lcm.dtmvtolt BETWEEN vr_dataini AND vr_datafim
       AND lcm.cdcooper = pr_cdcooper
      GROUP BY lcm.cdcooper, lcm.nrdconta, lcm.dtmvtolt);
          
    EXCEPTION       
      WHEN OTHERS THEN
        erro('Erro ao inserir registros na tabela tbcc_operacoes_diarias para operação 25. '||SQLERRM);
        loga('Insert da operação 25 finalizado com erro: ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
        --Levantar Exceção
        RAISE vr_excsaida;
    END;
    
    loga('Insert da operação 25 finalizado com sucesso: ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
        
    COMMIT;
        
    fecha_arquivos;
    -- Encerrar o job do processamento paralelo dessa agência
    gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                ,pr_idprogra => pr_idprogra
                                ,pr_des_erro => vr_dscritic);  

  EXCEPTION
    WHEN vr_excsaida THEN
      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => pr_idprogra
                                  ,pr_des_erro => vr_dscritic);  
       
      pr_dscritic := 'ERRO ' || pr_dscritic;
      loga('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
      erro(pr_dscritic);
      fecha_arquivos;
      ROLLBACK;
    WHEN OTHERS THEN     
      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => pr_idprogra
                                  ,pr_des_erro => vr_dscritic);  
      
      pr_dscritic := 'ERRO ' || pr_dscritic || sqlerrm;
      loga('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
      erro(pr_dscritic);
      fecha_arquivos;
      ROLLBACK;

END;
