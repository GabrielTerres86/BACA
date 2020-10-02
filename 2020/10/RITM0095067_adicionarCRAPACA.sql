DECLARE 

  CURSOR cr_craprdr IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.nmprogra = 'TELA_ATENDA_REVISAO';

  vr_nrseqrdr   NUMBER;

BEGIN
  
  OPEN  cr_craprdr;
  FETCH cr_craprdr INTO vr_nrseqrdr;
  
  IF cr_craprdr%NOTFOUND THEN
    
    INSERT INTO craprdr(nrseqrdr
                       ,nmprogra
                       ,dtsolici)
                 VALUES((SELECT NVL(MAX(nrseqrdr),0) + 1 FROM craprdr)
                       , 'TELA_ATENDA_REVISAO'
                       , SYSDATE) RETURNING nrseqrdr INTO vr_nrseqrdr;
  END IF;
  
  CLOSE cr_craprdr;
  

  INSERT INTO CECRED.CRAPACA
    (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES
    ((SELECT NVL(MAX(nrseqaca),0)+1 FROM crapaca)
    ,'BUSCAR_DADOS_REVISAO_CADASTRAL'
    ,NULL
    ,'buscarDadosRevisaoCadastral'
    ,'pr_nrdconta'
    ,vr_nrseqrdr);

  COMMIT;

END;
