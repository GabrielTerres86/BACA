declare
  vr_nrseqrdr number;
BEGIN
  
  BEGIN
    INSERT INTO CECRED.craprdr(nmprogra,dtsolici) values('COBRAN',sysdate) returning nrseqrdr into vr_nrseqrdr;
  EXCEPTION
    WHEN dup_val_on_index THEN
      SELECT rdr.nrseqrdr
        INTO vr_nrseqrdr
        FROM cecred.craprdr rdr
       WHERE rdr.nmprogra = 'COBRAN';
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001,'Erro ao incluir CRAPRDR: '||SQLERRM);
  END;

 INSERT INTO CECRED.crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    ('BUSCA_MULTIPLO_DESCONTO','TELA_COBRAN','pc_busca_multiplo_desconto_web','pr_cdcooper,pr_cdbandoc,pr_nrdctabb,pr_nrcnvcob,pr_nrdconta,pr_nrdocmto',vr_nrseqrdr);

  COMMIT;
END;
