PL/SQL Developer Test script 3.0
123
--inc0016998 Atualizar a situação das instruções de negativação dos títulos da Acredicoop para o SERASA (Carlos)
declare 
  vr_nmdireto    VARCHAR2(100);
  vr_nmarquiv    VARCHAR2(50); 
  vr_input_file  UTL_FILE.FILE_TYPE;

  vr_setlinha    VARCHAR2(10000);
  vr_dscritic    VARCHAR2(1000);
  
  vr_des_xml         CLOB;
  vr_texto_completo  VARCHAR2(32600);
  
  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                          ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_xml
                           ,vr_texto_completo
                           ,pr_des_dados
                           ,pr_fecha_xml);
  END; 
  
BEGIN

  vr_nmarquiv:= 'crapcob_'||to_char(SYSDATE,'RRRRMMDD')||'.sql';
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto := vr_nmdireto||'cpd/bacas/inc0016998_crps330/';

  -- Inicializar o CLOB
  vr_des_xml := NULL;
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  vr_texto_completo := NULL;
  
  -- Exportar historicos (backup)
  FOR reg IN (SELECT cdcooper, cdbandoc, nrdctabb, nrcnvcob, nrdconta, nrdocmto, nrsequencia, dhhistorico, inserasa, dtretser, cdoperad
                FROM tbcobran_his_neg_serasa t
               WHERE t.cdcooper = 2
                 AND trunc(t.dhhistorico) >= '28/05/2019' --28/05
                 AND t.inserasa = 2) LOOP
    
    pc_escreve_xml('insert into tbcobran_his_neg_serasa 
                   (CDCOOPER, CDBANDOC, NRDCTABB, NRCNVCOB, NRDCONTA, NRDOCMTO, NRSEQUENCIA, DHHISTORICO, INSERASA, DTRETSER, CDOPERAD)
                   values (' || reg.cdcooper || 
                   ', ' || reg.cdbandoc || 
                   ', ' || reg.nrdctabb || 
                   ', ' || reg.nrcnvcob || 
                   ', ' || reg.nrdconta || 
                   ', ' || reg.nrdocmto || 
                   ', ' || reg.nrsequencia || 
                   ', to_date(''' || to_char(reg.dhhistorico,'dd/mm/RRRR hh24:mi:ss') || 
                   ''',''dd/mm/RRRR hh24:mi:ss''), ' || reg.inserasa);
    IF (TRIM(reg.dtretser) IS NULL) THEN
      pc_escreve_xml(', NULL, ''' || reg.cdoperad || ''');' || chr(10), TRUE);
    ELSE
      pc_escreve_xml(', ''' || to_char(reg.dtretser,'dd/mm/RRRR') || ''', ''' || reg.cdoperad || ''');' || chr(10), TRUE);      
    END IF;

  END LOOP;

  -- Atualizar situacao da crapcob
  FOR rw IN (SELECT cdcooper, nrdconta, nrcnvcob, nrdocmto 
       FROM tbcobran_his_neg_serasa t
      WHERE t.cdcooper = 2
        AND trunc(t.dhhistorico) >= '28/05/2019' --28/05
        AND t.inserasa = 2) LOOP
       
    FOR reg IN (SELECT inserasa, cdcooper, nrdconta, nrcnvcob, nrdocmto FROM crapcob WHERE
                cdcooper = rw.cdcooper AND
                nrdconta = rw.nrdconta AND
                nrcnvcob = rw.nrcnvcob AND
                nrdocmto = rw.nrdocmto) LOOP
      
      --Backup da situação 
      pc_escreve_xml('update crapcob set inserasa = ' || reg.inserasa || 
      ' where cdcooper = ' || reg.cdcooper || ' and 
      nrdconta = ' || reg.nrdconta || ' and 
      nrcnvcob = ' || reg.nrcnvcob || ' and 
      nrdocmto = ' || reg.nrdocmto || ';'|| chr(10),TRUE);

      --Atualizar situacao
      UPDATE crapcob SET inserasa = 0
       WHERE cdcooper = rw.cdcooper
         AND nrdconta = rw.nrdconta
         AND nrcnvcob = rw.nrcnvcob
         AND nrdocmto = rw.nrdocmto;
    END LOOP;

  END LOOP;
  
  --Apagar os históricos
  DELETE FROM tbcobran_his_neg_serasa t
   WHERE t.cdcooper = 2
     AND TRUNC(t.dhhistorico) >= '28/05/2019'
     AND t.inserasa = 2;

  -- Fim do arquivo
  pc_escreve_xml('COMMIT;',TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_nmdireto, vr_nmarquiv, NLS_CHARSET_ID('UTF8'));
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);

  --Atualizar sequence da Acredicoop para a execução do programa crps330 pegar a sequence 759 na próxima execução, conforme esperado pelo SERASA
  UPDATE crapsqu
     SET nrseqatu = 758
   WHERE UPPER(nmtabela) = 'CRAPCOB'
     AND UPPER(nmdcampo) = 'NRSEQARQ'
     AND UPPER(dsdchave) = '2';

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    ROLLBACK;

    -- Fim do arquivo
    DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_nmdireto, vr_nmarquiv, NLS_CHARSET_ID('UTF8'));
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
end;
0
0
