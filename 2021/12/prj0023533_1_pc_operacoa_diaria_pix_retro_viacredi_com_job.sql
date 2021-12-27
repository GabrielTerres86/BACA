CREATE OR REPLACE PROCEDURE CECRED.pc_operacoa_diaria_pix_retro_viacredi(pr_cdcooper IN crapcop.cdcooper%TYPE
                                                                        ,pr_idparale IN crappar.idparale%TYPE
                                                                        ,pr_idprogra IN crappar.idprogra%TYPE
                                                                        ,pr_cdmes IN INTEGER ) IS

  ------------------------------- VARIAVEIS ---------------------------------
  vr_dscritic          VARCHAR2(5000) := ' ';
  vr_nmarqimp2         VARCHAR2(100) := ' ';
  vr_nmarqimp3         VARCHAR2(100) := ' ';
  vr_nmarqimp22        VARCHAR2(100)  := 'loga_';
  vr_nmarqimp33        VARCHAR2(100)  := 'erro_';
  vr_rootmicros        VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS'); -- '/progress/f0033330/micros/'; --
  vr_nmdireto          VARCHAR2(4000) := vr_rootmicros || 'cpd/bacas/prj0023533';

  vr_des_xml_2         CLOB;
  vr_des_xml_3         CLOB;
  vr_texto_completo_2  VARCHAR2(32600);
  vr_texto_completo_3  VARCHAR2(32600);
  
  vr_dataini           DATE;
  vr_dtini             DATE := to_date('01/' || to_char(pr_cdmes,'fm00') || '/2021');
  vr_dtfim             DATE := last_day(vr_dtini);

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
    vr_nmarqimp2 := 'viacredi_' || '_' || vr_nmarqimp22 ||to_char(sysdate,'HH24MISS');
    vr_nmarqimp3 := 'viacredi_' || '_' || vr_nmarqimp33 ||to_char(sysdate,'HH24MISS');

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
  abre_arquivos;
  loga('Inicio do processo de inserção de operações diaria retroativas para cooperativa ' || pr_cdcooper || ' e mes ' || pr_cdmes || ': ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
  vr_dataini := sysdate;
  loga('Inicio do insert para o mês ' || pr_cdmes || ' da operação 24: ' || to_char(vr_dataini,'DD/MM/YYYY HH24:MI:SS'));

  BEGIN
    IF pr_cdmes = 12 THEN
      vr_dtfim := TO_DATE('19/12/2021', 'DD/MM/RRRR');
    END IF;
    
    DELETE FROM tbcc_operacoes_diarias
    WHERE cdoperacao IN (24, 25)
      AND cdcooper = pr_cdcooper
      AND (dtoperacao >= vr_dtini AND dtoperacao <= vr_dtfim);


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
      FROM craplcm lcm,
            (SELECT vr_dtini - 1 + LEVEL dtmvtolt
             FROM dual
             CONNECT BY LEVEL <= (vr_dtfim - vr_dtini + 1)) aux
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
       AND lcm.dtmvtolt = aux.dtmvtolt
       AND lcm.cdcooper = pr_cdcooper
     GROUP BY lcm.cdcooper, lcm.nrdconta, lcm.dtmvtolt);

    loga('Linhas afetadas: ' || TO_CHAR(SQL%ROWCOUNT));
    loga('Tempo estimado em segundo: ' || TO_CHAR(((sysdate - vr_dataini)*1440)*60));
    vr_dataini := sysdate;
    loga('Inicio do insert para o mês ' || pr_cdmes || ' da operação 25: ' || to_char(vr_dataini,'DD/MM/YYYY HH24:MI:SS'));
        
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
      FROM craplcm lcm,
          (SELECT vr_dtini - 1 + LEVEL dtmvtolt
           FROM dual
           CONNECT BY LEVEL <= (vr_dtfim - vr_dtini + 1)) aux
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
       AND lcm.dtmvtolt = aux.dtmvtolt
       AND lcm.cdcooper = pr_cdcooper
     GROUP BY lcm.cdcooper, lcm.nrdconta, lcm.dtmvtolt);
     
    loga('Insert da operação 25 para o mês ' || pr_cdmes || ' finalizado com sucesso: ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
    loga('Linhas afetadas: ' || TO_CHAR(SQL%ROWCOUNT));
    loga('Tempo estimado em segundo: ' || TO_CHAR(((sysdate - vr_dataini)*1440)*60));
    
    --COMMIT;

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
      loga('ERRO ' || TO_CHAR(sysdate,'DD/MM/YYYY HH24:MI:SS'));
      erro(pr_dscritic);
      fecha_arquivos;
      --ROLLBACK;
    WHEN OTHERS THEN
      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => pr_idprogra
                                  ,pr_des_erro => vr_dscritic);

      pr_dscritic := 'ERRO ' || pr_dscritic || sqlerrm;
      loga('ERRO ' || TO_CHAR(sysdate,'DD/MM/YYYY HH24:MI:SS'));
      erro(pr_dscritic);
      fecha_arquivos;
      --ROLLBACK;

END;
