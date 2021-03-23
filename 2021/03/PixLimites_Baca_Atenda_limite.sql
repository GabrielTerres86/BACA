declare
  vr_nrseqrdr number/* := 2184*/;
BEGIN

  insert into craprdr(nmprogra,dtsolici) 
               values('ATENDA_LIMITE',sysdate)
            returning nrseqrdr into vr_nrseqrdr;

 INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    ('OBTEM_LIMITE_HABILITA','inet0001','pc_obtem_dados_limites_web','pr_tlcooper,pr_nrdconta,pr_idseqttl',vr_nrseqrdr);


 INSERT INTO crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    ('VALIDA_ALTERA_LIMITE_PIX','inet0001','pc_valida_altera_limite_pix','pr_tlcooper,pr_nrdconta,pr_idseqttl,pr_vlmovted,pr_vldebcar,pr_vlmovpix',vr_nrseqrdr);
    
  COMMIT;
END;
