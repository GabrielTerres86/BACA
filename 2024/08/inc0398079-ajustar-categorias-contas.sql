DECLARE

  CURSOR cr_contas IS
    SELECT *
      FROM (SELECT ass.cdcooper
                 , ass.nrdconta
                 , ass.inpessoa
                 , NVL(ass.cdcatego,0) cdcatego
                 , ass.rowid dsdrowid
                 , CASE ass.inpessoa 
                          WHEN 1 THEN 
                            (SELECT COUNT(*)
                               FROM crapttl ttl
                              WHERE ttl.cdcooper = ass.cdcooper
                                AND ttl.nrdconta = ass.nrdconta)
                          ELSE
                            0
                   END qtd_titulares
              FROM crapass ass
             WHERE ass.dtdemiss IS NULL) x
     WHERE (x.inpessoa = 2 AND x.cdcatego <> 1)
        OR (x.inpessoa = 1 AND 
                  ((x.cdcatego = 1 AND x.qtd_titulares > 1) OR
                   (x.cdcatego = 2 AND x.qtd_titulares = 1))
           );
  
  vr_rootmicros     VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto       VARCHAR2(4000) := vr_rootmicros || '/cpd/bacas/INC0328079';
  vr_clobxml        CLOB;
  vr_dstexto        VARCHAR2(32767);
  vr_cdcatego       NUMBER;
  vr_dscritic       VARCHAR2(2000);
  vr_nrdrowid       ROWID;
  vr_dsrollback     VARCHAR2(2000);
  
BEGIN
  
  dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

  GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'BEGIN'||CHR(10));

  FOR conta IN cr_contas LOOP
    
    IF conta.inpessoa = 2 THEN
      vr_cdcatego := 1;
    ELSE
      IF conta.qtd_titulares > 1 THEN
        vr_cdcatego := 2;
      ELSE
        vr_cdcatego := 1;
      END IF;
    END IF;
  
    BEGIN
      UPDATE crapass ass
         SET ass.cdcatego = vr_cdcatego
       WHERE ROWID = conta.dsdrowid;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        raise_application_error(-20001,'Erro ao atualizar categoria: '||SQLERRM);
    END;
    
    GENE0001.pc_gera_log(pr_cdcooper => conta.cdcooper
                        ,pr_cdoperad => '1'
                        ,pr_dscritic => vr_dscritic
                        ,pr_dsorigem => 'AIMARO'
                        ,pr_dstransa => 'Ajuste da categoria da conta - INC0328079'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 0
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'CONTAS'
                        ,pr_nrdconta => conta.nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    
    GENE0001.pc_gera_log_item
                    (pr_nrdrowid => vr_nrdrowid
                    ,pr_nmdcampo => 'Categoria'
                    ,pr_dsdadant => conta.cdcatego
                    ,pr_dsdadatu => vr_cdcatego);
    
    vr_dsrollback := '  DELETE cecred.craplgi WHERE (cdcooper, nrdconta, idseqttl, dttransa, hrtransa, nrsequen) IN (SELECT cdcooper, nrdconta, idseqttl, dttransa, hrtransa, nrsequen FROM cecred.craplgm WHERE ROWID = '''||vr_nrdrowid||''');';
    GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,vr_dsrollback||CHR(10));
    
    vr_dsrollback := '  DELETE cecred.craplgm WHERE ROWID = '''||vr_nrdrowid||''';';
    GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,vr_dsrollback||CHR(10));
    
    vr_dsrollback := '  UPDATE crapass ass SET ass.cdcatego = '||conta.cdcatego||' WHERE ROWID = '''||conta.dsdrowid||''';';
    GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,vr_dsrollback||CHR(10));
    
  END LOOP;

  GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'  COMMIT;'||CHR(10));
  GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'END;',TRUE);
  
  gene0002.pc_clob_para_arquivo(pr_clob     => vr_clobxml
                               ,pr_caminho  => vr_nmdireto
                               ,pr_arquivo  => 'INC0328079_rollback.sql'
                               ,pr_des_erro => vr_dscritic);
  
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    ROLLBACK;
    raise_application_error(-20002,'Não foi possivel gerar arquivo de Rollback: '||vr_dscritic);
  END IF;
  
  dbms_lob.close(vr_clobxml);
  dbms_lob.freetemporary(vr_clobxml);
  
  COMMIT;
  
END;
