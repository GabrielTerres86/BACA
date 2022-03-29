DECLARE  

  vr_incidente VARCHAR2(50):= 'PRB0046599';

  CURSOR cr_crapepr IS
    SELECT r.cdcooper
          ,r.nrdconta
          ,r.nrctremp
          ,a.nracordo
          ,a.dhacordo
          ,r.qtdiaatr
          ,e.inrisco_refin
          ,c.inrisco_acordo
          ,e.rowid rowid_epr
      FROM tbrecup_acordo          a
          ,tbrecup_acordo_contrato c
          ,crapris                 r
          ,crapepr                 e
          ,crapdat                 d
     WHERE a.nracordo = c.nracordo
       AND a.cdcooper = r.cdcooper
       AND a.nrdconta = r.nrdconta
       AND c.nrctremp = r.nrctremp
       AND a.cdcooper = e.cdcooper
       AND a.nrdconta = e.nrdconta
       AND c.nrctremp = e.nrctremp
       AND e.cdcooper = d.cdcooper
       AND c.cdorigem = 3
       AND c.cdmodelo = 2
       AND r.cdmodali = 299
       AND a.cdsituacao = 1
       AND r.dtrefere = d.dtmvtoan
       AND e.cdfinemp = 69
       AND e.inrisco_refin > c.inrisco_acordo;
       
  vr_desclob                   CLOB;
  vr_txtcompl                  VARCHAR2(32600);
  vr_dscomando_rollback        VARCHAR2(32600);    
  vr_nmdireto                  VARCHAR2(200); 
  vr_des_erro                  VARCHAR2(2000); 
       
  PROCEDURE pc_add_clob( pr_dsdlinha IN VARCHAR2,
                         pr_fechaarq IN BOOLEAN DEFAULT FALSE) IS
    vr_des_dados VARCHAR2(32000);
  BEGIN
    vr_des_dados := pr_dsdlinha;
    gene0002.pc_escreve_xml(vr_desclob, vr_txtcompl, vr_des_dados, pr_fechaarq);    
  END;       
       
BEGIN 
  
  vr_nmdireto := gene0001.fn_diretorio( pr_tpdireto => 'M'
                                       ,pr_cdcooper => 0
                                       ,pr_nmsubdir => 'cpd/bacas');

  vr_nmdireto := vr_nmdireto || '/'||vr_incidente;
  vr_desclob := NULL;
  dbms_lob.createtemporary(vr_desclob, TRUE);
  dbms_lob.open(vr_desclob, dbms_lob.lob_readwrite);

  FOR rw_crapepr IN cr_crapepr LOOP
    
    vr_dscomando_rollback := 'UPDATE crapepr e '||
                             'SET e.inrisco_refin = '||rw_crapepr.inrisco_refin ||
                             ' WHERE e.rowid = '''||rw_crapepr.rowid_epr||''';';    
  
    pc_add_clob(pr_dsdlinha => vr_dscomando_rollback||chr(10)); 
    
    UPDATE crapepr e
       SET e.inrisco_refin = rw_crapepr.inrisco_acordo
     WHERE e.rowid = rw_crapepr.rowid_epr;  
     
  END LOOP; 
  
  pc_add_clob(pr_dsdlinha => ' ',
              pr_fechaarq => TRUE);     
  
  gene0002.pc_clob_para_arquivo(pr_clob     => vr_desclob,
                                pr_caminho  => vr_nmdireto,
                                pr_arquivo  => vr_incidente||'_rollback.sql',
                                pr_des_erro => vr_des_erro);
                                
  IF dbms_lob.isopen(vr_desclob) <> 1 THEN
    dbms_lob.close(vr_desclob);        
  END IF;  
  
  COMMIT;
  
END ;
