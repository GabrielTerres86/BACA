DECLARE

  vr_exc_erro      EXCEPTION;

  vr_desclob       CLOB;
  vr_cdmodali      VARCHAR2(4000);
  vr_nmarqcsv      VARCHAR2(50);  
  vr_csv_9805      CLOB;
  vr_csv_9805_temp VARCHAR2(32672);
  vr_nmdireto      VARCHAR2(100); 
  vr_des_erro      VARCHAR2(4000);
  vr_txtcompl      VARCHAR2(32000);
  
  TYPE typ_reg_principal IS
  RECORD( cdcooper  cecred.tbrisco_operacoes.cdcooper%type
         ,nrdconta  cecred.tbrisco_operacoes.nrdconta%type
         ,nrctremp  cecred.tbrisco_operacoes.nrctremp%type
         ,inrisco_melhora  cecred.tbrisco_operacoes.inrisco_melhora%type
         ,dtrisco_melhora  cecred.crapris.dtrefere%type
         ,dtvencto_rating  cecred.crapris.dtrefere%type  
         ,dtrefere  cecred.crapris.dtrefere%type     
         ,dsinfaux  cecred.crapris.dsinfaux%type
         ,dtencerramento cecred.crapris.dtrefere%type
         ,inpessoa  cecred.crapris.inpessoa%type 
         ,cdmodali  cecred.crapris.cdmodali%type
         ,cdorigem  cecred.crapris.cdorigem%type
         ,inmodelo  pls_integer
         );
  TYPE typ_tab_principal_bulk IS TABLE OF typ_reg_principal INDEX BY PLS_INTEGER;
  TYPE typ_tab_cr_principal IS TABLE OF typ_reg_principal INDEX BY VARCHAR2(25); 
  vr_tab_cr_principal typ_tab_cr_principal;
  vr_tab_cr_principal_bulk typ_tab_principal_bulk;
  idx_principal VARCHAR2(25); 
  
  CURSOR cr_principal IS
    SELECT o.cdcooper,
           o.nrdconta,
           o.nrctremp,
           o.inrisco_melhora,
           o.dtrisco_melhora,
           o.dtvencto_rating,
           r.dtrefere,
           case 
             when (select count(1) 
                     from cecred.crapebn e 
                    where e.cdcooper = r.cdcooper 
                      and e.nrctremp = r.nrctremp  
                      and e.nrdconta = r.nrdconta) > 1
             then 'BNDES' 
             else '' 
           end as dsinfaux,
           case when o.dtvencto_rating < (select dtmvtolt from cecred.crapdat where cdcooper = o.cdcooper) then o.dtvencto_rating else null end as dtencerramento,
           r.inpessoa,
           r.cdmodali,
           r.cdorigem,
           1 as inmodelo
      from cecred.tbrisco_operacoes o,
           cecred.crapris r,
           cecred.crapdat d
     where d.cdcooper = r.cdcooper
       AND d.dtmvcentral = r.dtrefere
       AND o.cdcooper = r.cdcooper 
       and o.nrdconta = r.nrdconta 
       and o.nrctremp = r.nrctremp 
       AND o.cdcooper IN (16)
       and o.inrisco_melhora > 0
       and o.tpctrato = 90
       and o.flencerrado = 0;
  rw_principal cr_principal%ROWTYPE;
  
  PROCEDURE pc_escreve_linha(pr_dsdlinha IN VARCHAR2, pr_fechaarq IN BOOLEAN DEFAULT FALSE) IS
    vr_des_dados VARCHAR2(32000);
    BEGIN
      vr_des_dados := pr_dsdlinha||chr(10);
      
      gene0002.pc_escreve_xml(vr_desclob, 
                              vr_txtcompl, 
                              vr_des_dados, 
                              pr_fechaarq);    
  END;   
    
BEGIN
 
  vr_nmarqcsv := 'ALTOVALE_'||TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS');
   
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/VIRADACENTRAL';
 
  vr_desclob := NULL;
  dbms_lob.createtemporary(vr_desclob, TRUE);
  dbms_lob.open(vr_desclob, dbms_lob.lob_readwrite);
  
  vr_tab_cr_principal_bulk.DELETE;
  OPEN cr_principal;
  FETCH cr_principal BULK COLLECT INTO vr_tab_cr_principal_bulk;
  CLOSE cr_principal;

  cecred.gene0002.pc_escreve_xml(vr_desclob, vr_txtcompl, 'BEGIN'||chr(13), false);  
   
  IF vr_tab_cr_principal_bulk.count > 0 THEN 
    FOR idx IN vr_tab_cr_principal_bulk.first .. vr_tab_cr_principal_bulk.last LOOP         

      vr_cdmodali := cecred.fn_busca_modalidade_bacen(pr_cdmodali => vr_tab_cr_principal_bulk(idx).cdmodali
                                                     ,pr_cdcooper => vr_tab_cr_principal_bulk(idx).cdcooper
                                                     ,pr_nrdconta => vr_tab_cr_principal_bulk(idx).nrdconta
                                                     ,pr_nrctremp => vr_tab_cr_principal_bulk(idx).nrctremp
                                                     ,pr_inpessoa => vr_tab_cr_principal_bulk(idx).inpessoa
                                                     ,pr_cdorigem => vr_tab_cr_principal_bulk(idx).cdorigem
                                                     ,pr_dsinfaux => vr_tab_cr_principal_bulk(idx).dsinfaux
                                                     ,pr_dtrefere => vr_tab_cr_principal_bulk(idx).dtrefere
                                                     ,pr_inmodelo => vr_tab_cr_principal_bulk(idx).inmodelo);

      vr_csv_9805_temp := '  INSERT INTO CREDITOGESTAO.TB_RISCO_MELHORA (IDCOOPERATIVA, NRCONTA, NRCONTRATO, CDMODALIDADE, CDRISCO_MELHORA, DTRISCO_MELHORA, DHINATIVADAO) VALUES (' 
                          || vr_tab_cr_principal_bulk(idx).cdcooper           || ','
                          || vr_tab_cr_principal_bulk(idx).nrdconta           || ','
                          || vr_tab_cr_principal_bulk(idx).nrctremp           || ','
                          || vr_cdmodali                                      || ','
                          || '''' || RISC0004.fn_traduz_risco(vr_tab_cr_principal_bulk(idx).inrisco_melhora) || ''','
                          || 'TO_DATE(''' || vr_tab_cr_principal_bulk(idx).dtrisco_melhora || ''',''DD/MM/RRRR''),'
                          || 'TO_DATE(''' || vr_tab_cr_principal_bulk(idx).dtencerramento  || ''',''DD/MM/RRRR'')'
                          ||');';

       pc_escreve_linha(pr_dsdlinha => vr_csv_9805_temp); 
                                        
    END LOOP;

    cecred.gene0002.pc_escreve_xml(vr_desclob, vr_txtcompl, '  COMMIT;'||chr(13)||'END; '||chr(13), TRUE);

    gene0002.pc_clob_para_arquivo(pr_clob     => vr_desclob
                                 ,pr_caminho  => vr_nmdireto
                                 ,pr_arquivo  => vr_nmarqcsv||'.sql'
                                 ,pr_des_erro => vr_des_erro);
    IF vr_des_erro IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  END IF;
  
  dbms_lob.close(vr_desclob);
  dbms_lob.freetemporary(vr_desclob);
  
  COMMIT;
  
EXCEPTION
 WHEN vr_exc_erro THEN
    ROLLBACK;
    dbms_lob.close(vr_desclob);
    dbms_lob.freetemporary(vr_desclob);
    raise_application_error(-20010, 'Erro: ' || vr_des_erro || SQLERRM);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20010, 'Erro: ' || SQLERRM);
END;
