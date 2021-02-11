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
  COMMIT;
END;
/
