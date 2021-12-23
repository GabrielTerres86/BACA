DECLARE
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
  vr_dtini             DATE;
  vr_dtfim             DATE;

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
  
  FOR mes IN 1..12 LOOP
  BEGIN
    loga('****************** MES ' || mes);
    vr_dataini := sysdate;
    vr_dtini := to_date('01/' || to_char(mes,'fm00') || '/2021');
    vr_dtfim := last_day(vr_dtini);
    
    IF mes = 12 THEN
      vr_dtfim := TO_DATE('19/12/2021', 'DD/MM/RRRR');
    END IF;
    
    loga('----- INICIO OPERAÇÃO 24: ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));

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
       AND lcm.cdcooper = 1
     GROUP BY lcm.cdcooper, lcm.nrdconta, lcm.dtmvtolt);

    loga('Linhas afetadas: ' || TO_CHAR(SQL%ROWCOUNT));
    loga('Tempo estimado em segundo: ' || TO_CHAR(((sysdate - vr_dataini)*1440)*60));
    loga('----- FIM OPERAÇÃO 24: '|| to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
    loga('----- INICIO OPERAÇÃO 25: ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
    vr_dataini := sysdate;

      
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
        AND lcm.cdcooper = 1
      GROUP BY lcm.cdcooper, lcm.nrdconta, lcm.dtmvtolt);

      

    loga('Linhas afetadas: ' || TO_CHAR(SQL%ROWCOUNT));
    loga('Tempo estimado em segundo: ' || TO_CHAR(((sysdate - vr_dataini)*1440)*60));
    loga('----- FIM OPERAÇÃO 25: '|| to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
    loga('');
    
    COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        loga('Insert para o mês ' || mes || ' finalizado com erro: ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
        erro('Erro ao inserir registros na tabela tbcc_operacoes_diarias para o mês ' || mes || '. Erro: ' || SQLERRM);
    END;
  END LOOP;
  
  fecha_arquivos;
END;
