DECLARE
  --
  CURSOR cr_max IS
    SELECT NVL(MAX(a.nrseqaca), 0) + 1 nrsaqaca
      FROM crapaca a;
  lv_max cecred.crapaca.nrseqaca%TYPE;
BEGIN
  --
  OPEN cr_max;
  FETCH cr_max
    INTO lv_max;
  CLOSE cr_max;
  --
  BEGIN
    INSERT INTO cecred.crapaca
      (nrseqaca,
       nmdeacao,
       nmpackag,
       nmproced,
       lstparam,
       nrseqrdr)
    VALUES
      (lv_max,
       'PRVSAQ_NRPROV',
       'TELA_PRVSAQ',
       'pc_checar_data_provisao',
       'pr_cdcooper,pr_nrconta,pr_dtsaque,pr_nrtit',
       1025);
  END;
  --
  BEGIN
    UPDATE tbcc_monitoramento_parametro a
       SET a.vlmonitoracao_pagamento = 2000;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000, dbms_utility.format_error_backtrace);
  END;
  --
  BEGIN
    UPDATE craptab a
       SET a.dstextab = '2000,01'
     WHERE a.cdcooper > -1
       AND a.nmsistem = 'CRED'
       AND a.tptabela = 'GENERI'
       AND a.cdempres = 0
       AND a.cdacesso = 'VLCTRMVESP';
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000, dbms_utility.format_error_backtrace);
  END;
  --
  COMMIT;
END;
/
