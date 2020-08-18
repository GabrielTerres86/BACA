BEGIN
DECLARE
  CURSOR cr_coops IS     
    SELECT crapcop.cdcooper       
      FROM crapcop;   
  
  rw_coops cr_coops%ROWTYPE;    
  vr_prtlmult INTEGER :=0;   
  vr_prestorn INTEGER :=0;   
  vr_prpropos VARCHAR2(8);   
  vr_vlempres NUMBER  :=0;   
  vr_pzmaxepr INTEGER :=0;   
  vr_vlmaxest NUMBER  :=0;   
  vr_pcaltpar NUMBER  :=0;   
  vr_vltolemp NUMBER  :=0;   
  vr_qtdpaimo INTEGER :=0;   
  vr_qtdpaaut INTEGER :=0;   
  vr_qtdpaava INTEGER :=0;   
  vr_qtdpaapl INTEGER :=0;   
  vr_qtdpasem INTEGER :=0;   
  vr_qtdpameq INTEGER :=0;   
  vr_qtdibaut INTEGER :=0;   
  vr_qtdibapl INTEGER :=0;   
  vr_qtdibsem INTEGER :=0;   
  vr_qtditava INTEGER :=0;   
  vr_qtditapl INTEGER :=0;   
  vr_qtditsem INTEGER :=0;   
  vr_pctaxpre NUMBER  :=0;   
  vr_qtdictcc INTEGER :=0;   
  vr_avtperda NUMBER  :=0;   
  vr_vlperavt NUMBER  :=0;   
  vr_vlmaxdst NUMBER  :=0;   
  vr_inpreapv VARCHAR2(1);   
  vr_vlmincnt NUMBER  :=0;   
  vr_nrmxrene NUMBER  :=0; -- numero de renegociacoes   
  vr_nrmxcore NUMBER  :=0; -- numero de contratos renegociados   
  vr_pcalttax NUMBER  :=0;
  vr_nrperccc NUMBER  :=0;
  vr_dstextab craptab.dstextab%TYPE; 
  
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(1000);        --> Desc. Erro

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  
  -- Buscar registro da RDR
  CURSOR cr_craprdr(pr_nmprogra IN craprdr.nmprogra%TYPE) IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = pr_nmprogra;
  
  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  vr_nmprogra craprdr.nmprogra%TYPE;
BEGIN
  vr_nmprogra := 'ATENDA';
  OPEN  cr_craprdr (pr_nmprogra => vr_nmprogra);
  FETCH cr_craprdr INTO vr_nrseqrdr;
  CLOSE cr_craprdr;
  
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('OBTDADOSCC', 'EMPR0021', 'pc_obtem_dados_cc_web', 'pr_nrdconta', vr_nrseqrdr);
  
  UPDATE crapaca SET lstparam = REPLACE(lstparam, 'pr_flgdeftr', 'pr_tpliquid') WHERE nmdeacao = 'RECALCULA_RENEG_CONTRATO';
  
  UPDATE crapaca SET lstparam = lstparam || ',pr_nrperccc' WHERE nmdeacao = 'TAB089_ALTERAR';
  
  /*------------------------------------------------------------------*/
  FOR rw_coops IN cr_coops LOOP
    -- Buscar dados da TAB
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_coops.cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'PAREMPREST'
                                             ,pr_tpregist => 01);

    --Se encontrou parametro, atribui valor. Caso contrario, mantem Zero 
    IF TRIM(vr_dstextab) IS NOT NULL THEN
      -- EFETUA OS PROCEDIMENTOS COM O DADO RETORNADO DA CRAPTAB
      vr_prtlmult := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,3));
      vr_prestorn := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,9,3));
      vr_prpropos := SUBSTR(vr_dstextab,13,8);
      vr_vlempres := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,22,12));
      vr_pzmaxepr := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,35,4));
      vr_vlmaxest := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,40,12));
      vr_pcaltpar := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,53,6)),0);
      vr_vltolemp := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,60,12)),0);
      vr_qtdpaimo := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,73,3)),0);
      vr_qtdpaaut := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,77,3)),0);
      vr_qtdpaava := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,81,3)),0);
      vr_qtdpaapl := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,85,3)),0);
      vr_qtdpasem := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,89,3)),0);
      vr_qtdibaut := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,93,3)),0);
      vr_qtdibapl := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,97,3)),0);
      vr_qtdibsem := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,101,3)),0);
      vr_qtdpameq := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,105,3)),0);
      vr_qtditava := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,109,3)),0);
      vr_qtditapl := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,113,3)),0);
      vr_qtditsem := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,117,3)),0);
      vr_pctaxpre := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,121,6)),0);
      vr_qtdictcc := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,128,3)),0);            
      vr_avtperda := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,132,1)),0);
      vr_vlperavt := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,134,12)),0);
      
      vr_nrmxrene := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,147,5)),0); -- P577 
      vr_nrmxcore := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,153,5)),0); -- P577 
      vr_pcalttax := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,159,6)),0); 
      vr_nrperccc := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,166,5)),10); -- RITM0072477 
    END IF;
    -- dbms_output.put_line(rw_coops.cdcooper || ' - Anti -   ' || vr_dstextab);
    vr_dstextab := to_char(vr_prtlmult,   'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(0          ,   'FM000')       || ' ' ||
                   to_char(vr_prestorn,   'FM000')       || ' ' ||
                   vr_prpropos                           || ' ' ||
                   to_char(vr_vlempres,   'FM000000000D00'  , 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(vr_pzmaxepr,   'FM0000', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(vr_vlmaxest,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(vr_pcaltpar,   'FM000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(vr_vltolemp,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(vr_qtdpaimo,   'FM000')       || ' ' ||
                   to_char(vr_qtdpaaut,   'FM000')       || ' ' ||
                   to_char(vr_qtdpaava,   'FM000')       || ' ' ||
                   to_char(vr_qtdpaapl,   'FM000')       || ' ' ||
                   to_char(vr_qtdpasem,   'FM000')       || ' ' ||
                   to_char(vr_qtdibaut,   'FM000')       || ' ' ||
                   to_char(vr_qtdibapl,   'FM000')       || ' ' ||
                   to_char(vr_qtdibsem,   'FM000')       || ' ' ||
                   to_char(vr_qtdpameq,   'FM000')       || ' ' ||
                   to_char(vr_qtditava,   'FM000')       || ' ' ||
                   to_char(vr_qtditapl,   'FM000')       || ' ' ||
                   to_char(vr_qtditsem,   'FM000')       || ' ' ||
                   to_char(vr_pctaxpre,   'FM000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(vr_qtdictcc,   'FM000') || ' ' ||
                   to_char(vr_avtperda)|| ' ' ||
                   to_char(vr_vlperavt,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''')|| ' ' ||
                   to_char(vr_nrmxrene,   'FM00000', 'NLS_NUMERIC_CHARACTERS='',.''')|| ' ' || -- P577
                   to_char(vr_nrmxcore,   'FM00000', 'NLS_NUMERIC_CHARACTERS='',.''')|| '' ||  -- P577
                   to_char(vr_pcalttax,   'FM000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(vr_nrperccc,   'FM00000', 'NLS_NUMERIC_CHARACTERS='',.''')|| ''; -- RITM0072477
	   -- dbms_output.put_line(rw_coops.cdcooper || ' - Novo -   ' || vr_dstextab);
	   BEGIN
       UPDATE craptab tab
          SET tab.dstextab = vr_dstextab
        WHERE tab.cdcooper        = rw_coops.cdcooper
          AND upper(tab.nmsistem) = 'CRED'
          AND upper(tab.tptabela) = 'USUARI'
          AND tab.cdempres        = 11
          AND upper(tab.cdacesso) = 'PAREMPREST'
          AND tab.tpregist        = 01;
      
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar Parametros!';
        RAISE vr_exc_saida;

    END;
  
  END LOOP;
  
  COMMIT;
  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        dbms_output.put_line(GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic));
      ELSE
        dbms_output.put_line(vr_dscritic);
      END IF;
      ROLLBACK;
    WHEN OTHERS THEN
      dbms_output.put_line('Erro geral na rotina - ' || SQLERRM);
      ROLLBACK;
  END;
END;
