DECLARE
  TYPE typ_rec_ctsal IS RECORD
    (cdcooper CECRED.crappfp.cdcooper%TYPE,
     nrdconta CECRED.craplfp.nrdconta%TYPE,
     cdempres CECRED.craplfp.cdempres%TYPE,
     dthorcre CECRED.crappfp.dthorcre%TYPE,
     vllancto CECRED.craplfp.vllancto%TYPE);
  TYPE typ_tab_ctsal IS TABLE OF typ_rec_ctsal 
    INDEX BY PLS_INTEGER;
  vr_tab_ctsal typ_tab_ctsal;
  vr_dthorcre CECRED.crappfp.dthorcre%TYPE;
  
  CURSOR cr_crappfp(pr_cdcooper CECRED.crappfp.cdcooper%TYPE
                   ,pr_nrdconta CECRED.craplfp.nrdconta%TYPE
                   ,pr_cdempres CECRED.craplfp.cdempres%TYPE
                   ,pr_dthorcre CECRED.crappfp.dthorcre%TYPE
                   ,pr_vllancto CECRED.craplfp.vllancto%TYPE) IS
    SELECT lfp.rowid lfp_rowid
      FROM CECRED.crapemp emp
          ,CECRED.crappfp pfp
          ,CECRED.craplfp lfp
          ,CECRED.crapofp ofp
          ,CECRED.crapass ass
          ,CECRED.crapccs ccs
     WHERE emp.cdcooper = pfp.cdcooper
       AND emp.cdempres = pfp.cdempres
       AND pfp.cdcooper = lfp.cdcooper
       AND pfp.cdempres = lfp.cdempres
       AND pfp.nrseqpag = lfp.nrseqpag
       AND lfp.cdcooper = ofp.cdcooper
       AND lfp.cdorigem = ofp.cdorigem
       AND ass.cdcooper(+) = lfp.cdcooper
       AND ass.nrdconta(+) = lfp.nrdconta
       AND ass.nrcpfcgc(+) = lfp.nrcpfemp
       AND ccs.cdcooper(+) = lfp.cdcooper
       AND ccs.nrdconta(+) = lfp.nrdconta
       AND ccs.nrcpfcgc(+) = lfp.nrcpfemp
       AND pfp.cdcooper = pr_cdcooper
       AND lfp.nrdconta = pr_nrdconta
       AND emp.cdempres = pr_cdempres
       AND TRUNC(pfp.dthorcre) = pr_dthorcre
       AND lfp.vllancto = pr_vllancto
       AND pfp.flsitcre IN (1, 2)
       AND lfp.idsitlct = 'L';
       rw_crappfp_temp cr_crappfp%ROWTYPE;
       
       vr_dsobslctant CECRED.craplfp.dsobslct%TYPE;
       vr_dsobslctatu CECRED.craplfp.dsobslct%TYPE;
       
       vr_idsitlctant CECRED.craplfp.idsitlct%TYPE;
       vr_idsitlctatu CECRED.craplfp.idsitlct%TYPE;
       
       vr_nrdrowid ROWID;
       
BEGIN
  vr_dthorcre := '08/07/2023';
  
  vr_tab_ctsal(1).cdcooper := 1;
  vr_tab_ctsal(1).nrdconta := 9957006;
  vr_tab_ctsal(1).cdempres := 6179;
  vr_tab_ctsal(1).dthorcre := vr_dthorcre;
  vr_tab_ctsal(1).vllancto := 1721;
  
  vr_tab_ctsal(2).cdcooper := 1;
  vr_tab_ctsal(2).nrdconta := 9957014;
  vr_tab_ctsal(2).cdempres := 6179;
  vr_tab_ctsal(2).dthorcre := vr_dthorcre;
  vr_tab_ctsal(2).vllancto := 480;
  
  vr_tab_ctsal(3).cdcooper := 1;
  vr_tab_ctsal(3).nrdconta := 9956840;
  vr_tab_ctsal(3).cdempres := 6179;
  vr_tab_ctsal(3).dthorcre := vr_dthorcre;
  vr_tab_ctsal(3).vllancto := 301;
  
  vr_tab_ctsal(4).cdcooper := 1;
  vr_tab_ctsal(4).nrdconta := 9957081;
  vr_tab_ctsal(4).cdempres := 6179;
  vr_tab_ctsal(4).dthorcre := vr_dthorcre;
  vr_tab_ctsal(4).vllancto := 481;
  
  vr_tab_ctsal(5).cdcooper := 1;
  vr_tab_ctsal(5).nrdconta := 10400303;
  vr_tab_ctsal(5).cdempres := 6179;
  vr_tab_ctsal(5).dthorcre := vr_dthorcre;
  vr_tab_ctsal(5).vllancto := 480;
  
  vr_tab_ctsal(6).cdcooper := 1;
  vr_tab_ctsal(6).nrdconta := 9957138;
  vr_tab_ctsal(6).cdempres := 6179;
  vr_tab_ctsal(6).dthorcre := vr_dthorcre;
  vr_tab_ctsal(6).vllancto := 721;
  
  vr_tab_ctsal(7).cdcooper := 16;
  vr_tab_ctsal(7).nrdconta := 371424;
  vr_tab_ctsal(7).cdempres := 232;
  vr_tab_ctsal(7).dthorcre := vr_dthorcre;
  vr_tab_ctsal(7).vllancto := '2103,47';
   
  FOR vr_idx IN vr_tab_ctsal.FIRST .. vr_tab_ctsal.LAST LOOP
    OPEN cr_crappfp(pr_cdcooper => vr_tab_ctsal(vr_idx).cdcooper
                   ,pr_nrdconta => vr_tab_ctsal(vr_idx).nrdconta
                   ,pr_cdempres => vr_tab_ctsal(vr_idx).cdempres
                   ,pr_dthorcre => vr_tab_ctsal(vr_idx).dthorcre
                   ,pr_vllancto => vr_tab_ctsal(vr_idx).vllancto);
    FETCH cr_crappfp INTO rw_crappfp_temp;
    IF cr_crappfp%NOTFOUND THEN
      CLOSE cr_crappfp;
      CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_tab_ctsal(vr_idx).cdcooper
                                 ,pr_cdoperad => 1
                                 ,pr_dscritic => 'Lancamento com a situacao ''L'' nao foi encontrado - ' ||
                                                 'cdcooper:' || vr_tab_ctsal(vr_idx).cdcooper || '; ' ||
                                                 'nrdconta:' || vr_tab_ctsal(vr_idx).nrdconta || '; ' ||
                                                 'cdempres:' || vr_tab_ctsal(vr_idx).cdempres || '; ' ||
                                                 'dthorcre:' || vr_tab_ctsal(vr_idx).dthorcre || '; ' ||
                                                 'vllancto:' || vr_tab_ctsal(vr_idx).vllancto
                                  ,pr_dsorigem => 'AIMARO'
                                  ,pr_dstransa => 'Verificar Lancamento Folha Pagamento - CTSAL - INC0281571'
                                  ,pr_dttransa => trunc(SYSDATE)
                                  ,pr_flgtrans => 0
                                  ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                                  ,pr_idseqttl => vr_idx
                                  ,pr_nmdatela => NULL
                                  ,pr_nrdconta => vr_tab_ctsal(vr_idx).nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid);
      CONTINUE;
    END IF;
    CLOSE cr_crappfp;
    
    FOR rw_crappfp IN cr_crappfp(pr_cdcooper => vr_tab_ctsal(vr_idx).cdcooper
                                ,pr_nrdconta => vr_tab_ctsal(vr_idx).nrdconta
                                ,pr_cdempres => vr_tab_ctsal(vr_idx).cdempres
                                ,pr_dthorcre => vr_tab_ctsal(vr_idx).dthorcre
                                ,pr_vllancto => vr_tab_ctsal(vr_idx).vllancto) LOOP      
      vr_dsobslctatu := 'Registro devolvido a empresa por Rejeição da TEC';
      vr_idsitlctatu := 'D';
             
      SELECT lfp.dsobslct
        INTO vr_dsobslctant
        FROM CECRED.craplfp lfp
       WHERE lfp.rowid = rw_crappfp.lfp_rowid;
       
      SELECT lfp.idsitlct
        INTO vr_idsitlctant
        FROM CECRED.craplfp lfp
       WHERE lfp.rowid = rw_crappfp.lfp_rowid;
          
      CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_tab_ctsal(vr_idx).cdcooper
                                 ,pr_cdoperad => 1
                                 ,pr_dscritic => 'cdcooper:' || vr_tab_ctsal(vr_idx).cdcooper || '; ' ||
                                                 'nrdconta:' || vr_tab_ctsal(vr_idx).nrdconta || '; ' ||
                                                 'cdempres:' || vr_tab_ctsal(vr_idx).cdempres || '; ' ||
                                                 'dthorcre:' || vr_tab_ctsal(vr_idx).dthorcre || '; ' ||
                                                 'vllancto:' || vr_tab_ctsal(vr_idx).vllancto
                                  ,pr_dsorigem => 'AIMARO'
                                  ,pr_dstransa => 'Atualizar Lancamento Folha Pagamento - CTSAL - INC0281571'
                                  ,pr_dttransa => trunc(SYSDATE)
                                  ,pr_flgtrans => 0
                                  ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                                  ,pr_idseqttl => vr_idx
                                  ,pr_nmdatela => NULL
                                  ,pr_nrdconta => vr_tab_ctsal(vr_idx).nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid);
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'craplfp.dsobslct'
                                      ,pr_dsdadant => vr_dsobslctant
                                      ,pr_dsdadatu => vr_dsobslctatu);
                                     
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'craplfp.idsitlct'
                                      ,pr_dsdadant => vr_idsitlctant
                                      ,pr_dsdadatu => vr_idsitlctatu);
                          
      UPDATE CECRED.craplfp lfp
         SET lfp.dsobslct = vr_dsobslctatu
            ,lfp.idsitlct = vr_idsitlctatu
       WHERE lfp.rowid = rw_crappfp.lfp_rowid;
      COMMIT;
    END LOOP;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    CECRED.pc_internal_exception(pr_cdcooper => 1
                                ,pr_compleme => 'INC0281571 Erro na alteracao da situacao das contas CTASAL na PAGFOL: ' 
                                                ||  TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS'));
    
END;
