DECLARE
  
  -- Buscar registro da RDR
  CURSOR cr_craprdr IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = 'CCRD0009';
  
  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  
BEGIN
  
  -- Buscar RDR
  OPEN  cr_craprdr;
  FETCH cr_craprdr INTO vr_nrseqrdr;
  
  -- Se nao encontrar
  IF cr_craprdr%NOTFOUND THEN
  
  INSERT INTO craprdr(nmprogra,dtsolici)
       VALUES('CCRD0009', SYSDATE)
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
        'GRAVAR_MOTIVOS_REJEITAR'
        , 'CCRD0009'
        , 'pccrd_gravar_motivo_recusa'
        , 'pr_nrdconta,pr_coddominio'
        , vr_nrseqrdr);
  
  COMMIT;
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Referencia a CCRD0009 criado com sucesso!');
  
END;

