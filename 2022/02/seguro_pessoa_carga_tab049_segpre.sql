DECLARE
  vr_dstextab   craptab.dstextab%TYPE; --> Busca na craptab
  vr_seqarquivo NUMBER(5);
  vr_apolice    VARCHAR2(20);
  vr_pgtosegu   NUMBER;
  vr_valormin   NUMBER;
  vr_valormax   NUMBER;
  vr_vallidps   NUMBER;
  vr_datadvig   DATE;
  vr_fimvigen   DATE;
  vr_endereco   VARCHAR2(100);
  vr_login      VARCHAR2(100);
  vr_senha      VARCHAR2(100);
  vr_idseqpar   NUMBER;
  vr_vlpercmo   NUMBER;
  vr_vlpercin   NUMBER;
  -- Realizar por cooperativas ativas
  CURSOR cr_crapop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1
       AND cop.cdcooper <> 3;
BEGIN
  FOR rw_idseqpar IN (SELECT p.idseqpar
                        FROM tbseg_parametros_prst p
                       WHERE p.tppessoa = 1
                         AND p.cdsegura = 514
                         AND p.tpcustei = 1) LOOP
    DELETE
      FROM tbseg_param_prst_cap_seg p
     WHERE p.idseqpar = rw_idseqpar.idseqpar;
     
    DELETE
      FROM tbseg_param_prst_tax_cob p
     WHERE p.idseqpar = rw_idseqpar.idseqpar;
    
    DELETE
      FROM tbseg_parametros_prst p
     WHERE p.idseqpar = rw_idseqpar.idseqpar;
  END LOOP;

  FOR rw_crapop IN cr_crapop LOOP
  -- Leitura dos valores de mínimo e máximo
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => rw_crapop.cdcooper,
                                              pr_nmsistem => 'CRED',
                                              pr_tptabela => 'USUARI',
                                              pr_cdempres => 11,
                                              pr_cdacesso => 'SEGPRESTAM',
                                              pr_tpregist => 0);

    -- Se não encontrar
    IF vr_dstextab IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('TAB049 não cadastrado para cdcooper: ' || rw_crapop.cdcooper);
      CONTINUE;
    ELSE
      -- EFETUA OS PROCEDIMENTOS COM O DADO RETORNADO DA CRAPTAB
      vr_valormin   := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,12));
      vr_valormax   := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,14,12));
      vr_datadvig   := TO_DATE(SUBSTR(vr_dstextab,40,10),'DD/MM/RRRR');
      vr_pgtosegu   := to_char(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,51,7)),'FM0D00000');            
      vr_vallidps   := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,94,12));
      vr_seqarquivo := SUBSTR(vr_dstextab,139,5);
      vr_apolice    := SUBSTR(vr_dstextab,145,16);
      vr_fimvigen   := TO_DATE(SUBSTR(vr_dstextab,162,10),'DD/MM/RRRR');
      vr_endereco   := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => rw_crapop.cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_ENDERECO');
      vr_login      := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => rw_crapop.cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_LOGIN');
      vr_senha      := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => rw_crapop.cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_SENHA');
      -- Percentual de Morte
      vr_vlpercmo := gene0002.fn_char_para_number(gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                            pr_cdcooper => rw_crapop.cdcooper,
                                                                            pr_cdacesso => 'PRST_PERC_MORTE'));
      -- Percentual de Invalidez
      vr_vlpercin := gene0002.fn_char_para_number(gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                            pr_cdcooper => rw_crapop.cdcooper,
                                                                            pr_cdacesso => 'PRST_PERC_INVALIDEZ'));
      BEGIN
        SELECT NVL(MAX(idseqpar)+1,1)
          INTO vr_idseqpar
          FROM tbseg_parametros_prst;
        
        INSERT INTO tbseg_parametros_prst(idseqpar,
                                          cdcooper,
                                          tppessoa,
                                          cdsegura,
                                          tpcustei,
                                          tpadesao,
                                          dtinivigencia,                                        
                                          pagsegu,
                                          limitdps,
                                          seqarqu,
                                          nrapolic,
                                          dtfimvigencia,
                                          enderftp,
                                          loginftp,
                                          senhaftp)
        VALUES(vr_idseqpar
              ,rw_crapop.cdcooper
              ,1   -- Fisica
              ,514 -- ICATU Seguros
              ,1   -- Não Contributário
              ,1   -- Compulsória
              ,vr_datadvig
              ,vr_pgtosegu
              ,vr_vallidps
              ,vr_seqarquivo
              ,vr_apolice
              ,vr_fimvigen
              ,vr_endereco
              ,vr_login
              ,vr_senha);
              
        INSERT INTO tbseg_param_prst_cap_seg(idseqpar,
                                             idademin,
                                             idademax,
                                             capitmin,
                                             capitmax)
        VALUES(vr_idseqpar
              ,0
              ,999
              ,vr_valormin
              ,vr_valormax);
              
        INSERT INTO tbseg_param_prst_tax_cob(idseqpar,
                                             gbidamin,
                                             gbidamax,
                                             gbsegmin,
                                             gbsegmax)
        VALUES(vr_idseqpar
              ,0
              ,999
              ,vr_vlpercmo
              ,vr_vlpercin);              
        COMMIT;  
      EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
        ROLLBACK;
      END;
    END IF;
  END LOOP;
END;
/
