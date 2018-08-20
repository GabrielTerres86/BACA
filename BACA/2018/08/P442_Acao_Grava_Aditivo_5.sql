DECLARE 
  num_nrseqrdr PLS_INTEGER := 1150;
BEGIN
  
  -- Incluir novas ações para a ADITIV (Ja existia RDR com id 1150)
  INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
               VALUES(num_nrseqrdr, 'GRAVA_ADT_TP5','TELA_ADITIV','pc_grava_aditivo_tipo5','pr_nrdconta,pr_nrctremp,pr_tpctrato,pr_dscatbem,pr_dstipbem,pr_dsmarbem,pr_nrmodbem,pr_nranobem,pr_dsbemfin,pr_vlfipbem,pr_vlrdobem,pr_tpchassi,pr_dschassi,pr_dscorbem,pr_ufdplaca,pr_nrdplaca,pr_nrrenava,pr_uflicenc,pr_nrcpfcgc,pr_idseqbem,pr_cdopeapr');  
  INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
               VALUES(num_nrseqrdr, 'BUSCA_BENS_TP5','TELA_ADITIV','pc_busca_bens_aditiv','pr_nrdconta,pr_nrctremp,pr_tpctrato');  
  
  -- Criar Interface para a MANBEM (RDR e ACA)
  INSERT INTO craprdr(nmprogra,dtsolici) VALUES ('TELA_MANBEM',SYSDATE) RETURNING nrseqrdr INTO num_nrseqrdr;
  INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
               VALUES(num_nrseqrdr, 'VALIDA_BEM_ALIENA','TELA_MANBEM','pc_valida_dados_alienacao_web','pr_nrdconta,pr_nrctremp,pr_tpctrato,pr_cddeacao,pr_dscatbem,pr_dstipbem,pr_nrmodbem,pr_nranobem,pr_dsbemfin,pr_vlrdobem,pr_tpchassi,pr_dschassi,pr_dscorbem,pr_ufdplaca,pr_nrdplaca,pr_nrrenava,pr_uflicenc,pr_nrcpfcgc,pr_idseqbem');

  commit;
end;



