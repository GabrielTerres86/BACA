DECLARE
  
  -- Buscar registro da RDR
  CURSOR cr_craprdr IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = 'ATENDA_CRD';
  
  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  
BEGIN
  
  -- Buscar RDR
  OPEN  cr_craprdr;
  FETCH cr_craprdr INTO vr_nrseqrdr;
  
  -- Se nao encontrar
  IF cr_craprdr%NOTFOUND THEN
  
  INSERT INTO craprdr(nmprogra,dtsolici)
       VALUES('ATENDA_CRD', SYSDATE)
       RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
  
  END IF;
  
  -- Fechar o cursor
  CLOSE cr_craprdr;
  
  INSERT INTO crapaca (
         nmdeacao
         , nmpackag
         , nmproced
         , lstparam
         , nrseqrdr
  ) VALUES (
        'BUSCA_ADM_CRD'
        , 'TELA_ATENDA_CARTAOCREDITO'
        , 'pc_busca_adm_crd'
        , 'pr_cdcooper,pr_nrdconta, pr_tplimcrd'
        , vr_nrseqrdr);
  
  COMMIT;
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Referencia a CCRD0009 criado com sucesso!');
  
END;
