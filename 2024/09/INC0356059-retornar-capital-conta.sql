DECLARE

  vr_cdcooper            CONSTANT cecred.crapass.cdcooper%TYPE := 6;
  vr_nrdconta            CONSTANT cecred.crapass.nrdconta%TYPE := 172430;
  vr_cdhistor            CONSTANT NUMBER := 2519;

  CURSOR cr_devolucao IS
    SELECT ROWID dsdrowid
         , t.vlcapital
      FROM cecred.tbcotas_devolucao t
     WHERE cdcooper    = vr_cdcooper
       AND nrdconta    = vr_nrdconta
       AND tpdevolucao = 3;

  CURSOR cr_cotas IS
    SELECT t.vldcotas
      FROM cecred.crapcot t
     WHERE nrdconta    = vr_nrdconta
       AND cdcooper    = vr_cdcooper;

  vr_arq_path            VARCHAR2(1000):= cecred.gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/INC0356059';
  vr_nmarqbkp            VARCHAR2(100) := 'INC0356059_script_rollback.sql';
  
  vr_vllanmto            NUMBER;
  vr_dsrowdev            ROWID;
  vr_dsdrowid            ROWID;
  
  vr_flarqrol            utl_file.file_type;
  vr_des_rollback_xml    CLOB;
  vr_texto_rb_completo   VARCHAR2(32600);

  vr_vldcotas            NUMBER;
  vr_nrseqdig            NUMBER;
  vr_dtmvtolt            DATE;
  vr_des_erro            VARCHAR2(4000);

  PROCEDURE pc_escreve_xml_rollback(pr_des_dados IN VARCHAR2,
                                    pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    CECRED.gene0002.pc_escreve_xml(vr_des_rollback_xml, vr_texto_rb_completo, pr_des_dados, pr_fecha_xml);
  END;

BEGIN

  vr_des_rollback_xml := NULL;
  dbms_lob.createtemporary(vr_des_rollback_xml, TRUE);
  dbms_lob.open(vr_des_rollback_xml, dbms_lob.lob_readwrite);
  vr_texto_rb_completo := NULL;

  vr_dtmvtolt := sistema.datascooperativa(1).dtmvtolt;
  
  vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG', vr_cdcooper || ';' ||to_char(vr_dtmvtolt,'DD/MM/YYYY') || ';1;100;600043');
  
  OPEN  cr_devolucao;
  FETCH cr_devolucao INTO vr_dsrowdev, vr_vllanmto;
  CLOSE cr_devolucao;
  
  BEGIN
    INSERT INTO CECRED.craplct
                        (cdcooper
                        ,cdagenci
                        ,cdbccxlt
                        ,nrdolote
                        ,dtmvtolt
                        ,cdhistor
                        ,nrctrpla
                        ,nrdconta
                        ,nrdocmto
                        ,nrseqdig
                        ,vllanmto
                        ,cdopeori
                        ,dtinsori)
                 VALUES (vr_cdcooper
                        ,1
                        ,100
                        ,600043
                        ,vr_dtmvtolt
                        ,vr_cdhistor
                        ,0
                        ,vr_nrdconta
                        ,0
                        ,vr_nrseqdig
                        ,vr_vllanmto
                        ,1
                        ,SYSDATE) RETURN ROWID INTO vr_dsdrowid;

        
    pc_escreve_xml_rollback('DELETE cecred.craplct WHERE rowid = '''||vr_dsdrowid||'''; ' || chr(10) || chr(10));

  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001,'Erro ao realizar lançamento de cota na cooperativa/conta: ' || vr_cdcooper || '/' || vr_nrdconta || ' - ' || SQLERRM);
  END;

  BEGIN
    vr_vldcotas := 0;

    OPEN  cr_cotas;
    FETCH cr_cotas INTO vr_vldcotas;
    CLOSE cr_cotas;

    UPDATE CECRED.crapcot
      SET vldcotas = ( NVL(vldcotas,0) + NVL(vr_vllanmto,0) )
    WHERE cdcooper = vr_cdcooper
      AND nrdconta = vr_nrdconta;

    pc_escreve_xml_rollback('UPDATE cecred.crapcot SET vldcotas = '||to_char(NVL(vr_vldcotas,0),'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')||' WHERE cdcooper = '||vr_cdcooper||' AND nrdconta = '||vr_nrdconta||'; ' || chr(10) || chr(10));

  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20002,'Erro ao atualizar valor de cota na cooperativa/conta: ' || vr_cdcooper || '/' || vr_nrdconta || ' - ' || SQLERRM);
  END;

  BEGIN
    DELETE cecred.tbcotas_devolucao
     WHERE ROWID = vr_dsrowdev;

    pc_escreve_xml_rollback('INSERT INTO cecred.tbcotas_devolucao' ||
                            ' (cdcooper,nrdconta,tpdevolucao,vlcapital,qtparcelas,dtinicio_credito,vlpago) ' ||
                            ' VALUES ('||vr_cdcooper ||
                            ' ,'||vr_nrdconta ||
                            ' ,3'||
                            ' ,'||to_char(vr_vllanmto,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''') ||
                            ' ,NULL'||
                            ' ,to_date(''24/09/2024'',''dd/mm/yyyy'')'||
                            ' ,0);' || chr(10) || chr(10));

  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20003,'Erro ao excluir registro de devolução tipo 3 na cooperativa/conta: ' || vr_cdcooper || '/' || vr_nrdconta || ' - ' || SQLERRM);
  END;
  
  COMMIT;

  pc_escreve_xml_rollback('COMMIT;');
  pc_escreve_xml_rollback(' ',TRUE);

  CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_rollback_xml,
                                       pr_caminho  => vr_arq_path,
                                       pr_arquivo  => vr_nmarqbkp,
                                       pr_des_erro => vr_des_erro);
  
  dbms_lob.close(vr_des_rollback_xml);
  dbms_lob.freetemporary(vr_des_rollback_xml);
 
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000,'ERRO AO EXECUTAR SCRIPT: '||SQLERRM);
END;
/
