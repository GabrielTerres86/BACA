declare
  vr_nrseqrdr number;

BEGIN


  INSERT INTO craprdr(nmprogra,dtsolici)
               VALUES('TELA_FINALI',SYSDATE)
           RETURNING nrseqrdr INTO vr_nrseqrdr;  
  
	INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
               VALUES(vr_nrseqrdr, 'EXCLUI_FINALI_LINHA','tela_finali','pc_excluir_lcr_finali','pr_cdfinemp,pr_dslstlin');
   
  commit;
end;
