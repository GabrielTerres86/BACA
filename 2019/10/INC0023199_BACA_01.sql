DECLARE
  
  -- Buscar registro da RDR
  CURSOR cr_craprdr IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = 'TELA_ATENDA_CARTAOCREDITO';
  
  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  
BEGIN
  
  -- Buscar RDR
  OPEN  cr_craprdr;
  FETCH cr_craprdr INTO vr_nrseqrdr;
  
  -- Se nao encontrar
  IF cr_craprdr%NOTFOUND THEN
  
  INSERT INTO craprdr(nmprogra,dtsolici)
       VALUES('TELA_ATENDA_CARTAOCREDITO', SYSDATE)
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
        'VERIFICA_PROPOSTA_HIST'
        , 'TELA_ATENDA_CARTAOCREDITO'
        , 'pccrd_efetua_copia_propost_web'
        , 'pr_nrdconta, pr_nrctrcrd'
        , vr_nrseqrdr);
  
  COMMIT;
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Referencia a TELA_ATENDA_CARTAOCREDITO criado com sucesso!');
  
END;
