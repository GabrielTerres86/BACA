DECLARE
  vr_nrseqrdr NUMBER := 0;
BEGIN
  BEGIN
    SELECT rdr.nrseqrdr
      INTO vr_nrseqrdr
      FROM craprdr rdr
     WHERE rdr.nmprogra = 'HISTOR';
  EXCEPTION
    WHEN OTHERS THEN
      vr_nrseqrdr := 0;
  END;
  
  IF vr_nrseqrdr > 0 THEN
    insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
                 values('HISTOR_CONSULTA_SEGURADORA','TELA_HISTOR','pc_consulta_seguradora',null,vr_nrseqrdr);

    insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
                 values('HISTOR_SALVA_SEGURADORA','TELA_HISTOR','pc_salva_seguradora','pr_dsvlrprm',vr_nrseqrdr);

    commit;
  END IF;
end;