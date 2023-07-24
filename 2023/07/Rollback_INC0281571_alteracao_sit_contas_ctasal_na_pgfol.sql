DECLARE
  vc_dstransa CONSTANT VARCHAR2(4000) := 'Atualizar Lancamento Folha Pagamento - CTSAL - INC0281571';
  vr_dsobslct CECRED.craplfp.dsobslct%TYPE;
  vr_idsitlct CECRED.craplfp.idsitlct%TYPE;
  vr_nmdcampo CECRED.craplgi.nmdcampo%TYPE;
  vr_cdcooper CECRED.craplfp.cdcooper%TYPE;
  vr_nrdconta CECRED.craplfp.nrdconta%TYPE;
  vr_nrdrowid ROWID;
  vr_linha_lancamento_folha gene0002.typ_split;
  vr_lancamento_folha gene0002.typ_split;
  vr_index PLS_INTEGER := 1;
 
  TYPE typ_rec_ctsal IS RECORD
    (cdcooper CECRED.crappfp.cdcooper%TYPE,
     nrdconta CECRED.craplfp.nrdconta%TYPE);
  TYPE typ_tab_ctsal IS TABLE OF typ_rec_ctsal 
    INDEX BY PLS_INTEGER;
  vr_tab_ctsal typ_tab_ctsal;
  
  TYPE typ_rec_lgi IS RECORD
    (cdcooper  CECRED.craplfp.cdcooper%TYPE
    ,nrdconta  CECRED.craplfp.nrdconta%TYPE
    ,cdempres  CECRED.craplfp.cdempres%TYPE
    ,dthorcre  CECRED.crappfp.dthorcre%TYPE
    ,vllancto  CECRED.craplfp.vllancto%TYPE);
  TYPE typ_tab_lgi IS TABLE OF typ_rec_lgi 
    INDEX BY PLS_INTEGER;
  vr_tab_lgi typ_tab_lgi;
  
  TYPE typ_nmdcampo IS TABLE OF VARCHAR2(30)
    INDEX BY PLS_INTEGER;
  vr_tab_nmdcampo  typ_nmdcampo;
  
  TYPE typ_valores IS TABLE OF VARCHAR2(30)
    INDEX BY PLS_INTEGER;
  vr_tab_valores_lancamento  typ_valores;
 
  CURSOR cr_lgi(pr_cdcooper  CECRED.craplfp.cdcooper%TYPE
               ,pr_nrdconta  CECRED.craplfp.nrdconta%TYPE
               ,pr_cdempres  CECRED.craplfp.cdempres%TYPE
               ,pr_dthorcre  CECRED.crappfp.dthorcre%TYPE
               ,pr_vllancto  CECRED.craplfp.vllancto%TYPE
               ,pr_nmdcampo  CECRED.craplgi.nmdcampo%TYPE) IS    
  SELECT lgi.dsdadant
    FROM craplgi lgi
        ,crapccs ccs
        ,craplfp lfp
        ,crappfp pfp
        ,crapemp emp
        ,crapass ass
   WHERE pfp.cdcooper = lfp.cdcooper
     AND pfp.cdempres = lfp.cdempres
     AND pfp.nrseqpag = lfp.nrseqpag
     AND emp.cdcooper = pfp.cdcooper
     AND emp.cdempres = pfp.cdempres
     AND lfp.cdcooper = ccs.cdcooper
     AND lfp.nrdconta = ccs.nrdconta
     AND lfp.nrcpfemp = ccs.nrcpfcgc
     AND emp.cdcooper = ass.cdcooper
     AND emp.nrdconta = ass.nrdconta
     AND lgi.cdcooper = lfp.cdcooper
     AND lgi.nrdconta = lfp.nrdconta
     AND lfp.cdcooper = pr_cdcooper
     AND lfp.nrdconta = pr_nrdconta
     AND lfp.cdempres = pr_cdempres
     AND lfp.vllancto = pr_vllancto
     AND TRUNC(pfp.dthorcre) = pr_dthorcre
     AND lgi.nmdcampo = pr_nmdcampo;
     
  CURSOR cr_lgm(pr_dstransa CECRED.craplgm.dstransa%TYPE
               ,pr_cdcooper CECRED.craplgm.cdcooper%TYPE
               ,pr_nrdconta CECRED.craplgm.nrdconta%TYPE) IS
   SELECT lgm.dscritic
     FROM CECRED.craplgm lgm
    WHERE lgm.dstransa = pr_dstransa
      AND lgm.cdcooper = pr_cdcooper
      AND lgm.nrdconta = pr_nrdconta;
      
  CURSOR cr_lancamento_folha (pr_idx NUMBER) IS
    SELECT SUBSTR(vr_lancamento_folha(pr_idx),
                  INSTR(vr_lancamento_folha(pr_idx), ':') + 1) AS dados
      FROM dual;
  rw_lancamento_folha cr_lancamento_folha%ROWTYPE;
  
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
     AND lfp.vllancto = pr_vllancto;
  rw_crappfp cr_crappfp%ROWTYPE;
  
BEGIN
  vr_tab_nmdcampo(1) := 'craplfp.dsobslct';
  vr_tab_nmdcampo(2) := 'craplfp.idsitlct';
  
  vr_tab_ctsal(1).cdcooper := 1;
  vr_tab_ctsal(1).nrdconta := 9957006;

  vr_tab_ctsal(2).cdcooper := 1;
  vr_tab_ctsal(2).nrdconta := 9957014;

  vr_tab_ctsal(3).cdcooper := 1;
  vr_tab_ctsal(3).nrdconta := 9956840;

  vr_tab_ctsal(4).cdcooper := 1;
  vr_tab_ctsal(4).nrdconta := 9957081;

  vr_tab_ctsal(5).cdcooper := 1;
  vr_tab_ctsal(5).nrdconta := 10400303;
  
  vr_tab_ctsal(6).cdcooper := 1;
  vr_tab_ctsal(6).nrdconta := 9957138;

  vr_tab_ctsal(7).cdcooper := 16;
  vr_tab_ctsal(7).nrdconta := 371424;
  
  FOR vr_idx IN vr_tab_ctsal.FIRST .. vr_tab_ctsal.LAST LOOP
    FOR rw_lgm IN cr_lgm(pr_dstransa => vc_dstransa
                        ,pr_cdcooper => vr_tab_ctsal(vr_idx).cdcooper
                        ,pr_nrdconta => vr_tab_ctsal(vr_idx).nrdconta) LOOP
                        
      vr_linha_lancamento_folha := gene0002.fn_quebra_string(pr_string => rw_lgm.dscritic
                                                            ,pr_delimit => ';');
    
      FOR vr_idx2 IN vr_linha_lancamento_folha.FIRST .. vr_linha_lancamento_folha.LAST LOOP
        vr_lancamento_folha := gene0002.fn_quebra_string(pr_string => vr_linha_lancamento_folha(vr_idx2)
                                                        ,pr_delimit => ':');
                                                        
        FOR vr_idx3 IN vr_lancamento_folha.FIRST .. vr_lancamento_folha.LAST LOOP
          IF MOD(vr_idx3,2) = 0 THEN
            OPEN cr_lancamento_folha(vr_idx3);
            FETCH cr_lancamento_folha INTO rw_lancamento_folha;
            CLOSE cr_lancamento_folha;
            vr_tab_valores_lancamento(vr_index) := rw_lancamento_folha.dados;
            vr_index := vr_index + 1;
          END IF;
        END LOOP;
      END LOOP; 
      vr_tab_lgi(vr_idx).cdcooper := vr_tab_valores_lancamento(1);
      vr_tab_lgi(vr_idx).nrdconta := vr_tab_valores_lancamento(2);
      vr_tab_lgi(vr_idx).cdempres := vr_tab_valores_lancamento(3);
      vr_tab_lgi(vr_idx).dthorcre := vr_tab_valores_lancamento(4);
      vr_tab_lgi(vr_idx).vllancto := vr_tab_valores_lancamento(5);
      vr_index := 1;
    END LOOP; 
  END LOOP; 
    
  FOR vr_idx_lgi IN vr_tab_lgi.FIRST .. vr_tab_lgi.LAST LOOP
    FOR vr_idx_nmdcampo IN vr_tab_nmdcampo.FIRST .. vr_tab_nmdcampo.LAST LOOP
      OPEN cr_lgi(pr_cdcooper => vr_tab_lgi(vr_idx_lgi).cdcooper  
                 ,pr_nrdconta => vr_tab_lgi(vr_idx_lgi).nrdconta  
                 ,pr_cdempres => vr_tab_lgi(vr_idx_lgi).cdempres  
                 ,pr_dthorcre => vr_tab_lgi(vr_idx_lgi).dthorcre  
                 ,pr_vllancto => vr_tab_lgi(vr_idx_lgi).vllancto  
                 ,pr_nmdcampo => vr_tab_nmdcampo(vr_idx_nmdcampo));
                 
      IF vr_tab_nmdcampo(vr_idx_nmdcampo) = 'craplfp.dsobslct' THEN
        FETCH cr_lgi INTO vr_dsobslct;
      ELSE 
        FETCH cr_lgi INTO vr_idsitlct;
      END IF; 
      
      IF cr_lgi%FOUND THEN
        CLOSE cr_lgi;
        CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_tab_lgi(vr_idx_lgi).cdcooper
                                   ,pr_cdoperad => 1
                                   ,pr_dscritic => 'Lancamento Folha Pagamento revertido com sucesso! ' ||
                                                   'campo:'|| vr_tab_nmdcampo(vr_idx_nmdcampo) || ';' ||
                                                   ' Dados do Lancamento: ' || 
                                                   'cdcooper:' || vr_tab_lgi(vr_idx_lgi).cdcooper || ';' ||
                                                   'nrdconta:' || vr_tab_lgi(vr_idx_lgi).nrdconta || ';' ||
                                                   'cdempres:' || vr_tab_lgi(vr_idx_lgi).cdempres || ';' ||
                                                   'dthorcre:' || vr_tab_lgi(vr_idx_lgi).dthorcre || ';' ||
                                                   'vllancto:' || vr_tab_lgi(vr_idx_lgi).vllancto
                                   ,pr_dsorigem => 'AIMARO'
                                   ,pr_dstransa => 'Reverter valor do campo '||vr_tab_nmdcampo(vr_idx_nmdcampo)||' Lancamento Folha Pagamento - CTSAL - INC0281571'
                                   ,pr_dttransa => trunc(SYSDATE)
                                   ,pr_flgtrans => 0
                                   ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                                   ,pr_idseqttl => vr_idx_lgi
                                   ,pr_nmdatela => NULL
                                   ,pr_nrdconta => vr_tab_lgi(vr_idx_lgi).nrdconta
                                   ,pr_nrdrowid => vr_nrdrowid);  
      ELSE                   
        CLOSE cr_lgi;
        CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_tab_lgi(vr_idx_lgi).cdcooper
                                   ,pr_cdoperad => 1
                                   ,pr_dscritic => 'Lancamento Folha Pagamento nao localizado para reverter o campo ' 
                                                   || vr_tab_nmdcampo(vr_idx_nmdcampo) ||
                                                   ' Dados do Lancamento: ' || 
                                                   'cdcooper:' || vr_tab_lgi(vr_idx_lgi).cdcooper || ';' ||
                                                   'nrdconta:' || vr_tab_lgi(vr_idx_lgi).nrdconta || ';' ||
                                                   'cdempres:' || vr_tab_lgi(vr_idx_lgi).cdempres || ';' ||
                                                   'dthorcre:' || vr_tab_lgi(vr_idx_lgi).dthorcre || ';' ||
                                                   'vllancto:' || vr_tab_lgi(vr_idx_lgi).vllancto
                                   ,pr_dsorigem => 'AIMARO'
                                   ,pr_dstransa => 'Reverter valor do campo '|| vr_tab_nmdcampo(vr_idx_nmdcampo) ||' Lancamento Folha Pagamento - CTSAL - INC0281571'
                                   ,pr_dttransa => trunc(SYSDATE)
                                   ,pr_flgtrans => 0
                                   ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                                   ,pr_idseqttl => vr_idx_lgi
                                   ,pr_nmdatela => NULL
                                   ,pr_nrdconta => vr_tab_lgi(vr_idx_lgi).nrdconta
                                   ,pr_nrdrowid => vr_nrdrowid);  
      END IF;
    END LOOP; 
    OPEN cr_crappfp(pr_cdcooper => vr_tab_lgi(vr_idx_lgi).cdcooper
                   ,pr_nrdconta => vr_tab_lgi(vr_idx_lgi).nrdconta
                   ,pr_cdempres => vr_tab_lgi(vr_idx_lgi).cdempres
                   ,pr_dthorcre => vr_tab_lgi(vr_idx_lgi).dthorcre
                   ,pr_vllancto => vr_tab_lgi(vr_idx_lgi).vllancto);
    FETCH cr_crappfp INTO rw_crappfp;
    IF cr_crappfp%FOUND THEN
      UPDATE CECRED.craplfp lfp
         SET lfp.dsobslct = vr_dsobslct
            ,lfp.idsitlct = vr_idsitlct
      WHERE lfp.rowid = rw_crappfp.lfp_rowid;
      COMMIT;
    END IF;
    CLOSE cr_crappfp;
  END LOOP; 
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    CECRED.pc_internal_exception(pr_cdcooper => 1
                                ,pr_compleme => 'INC0281571 Erro na reversao da situacao das contas CTASAL na PAGFOL');
END;
