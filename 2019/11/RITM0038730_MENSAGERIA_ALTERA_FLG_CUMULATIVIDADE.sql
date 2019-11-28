DECLARE
  
  -- Buscar registro da RDR
  CURSOR cr_craprdr IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = 'TELA_GRUPO_ECONOMICO';
  
  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  
BEGIN
  
  -- Buscar RDR
  OPEN  cr_craprdr;
  FETCH cr_craprdr INTO vr_nrseqrdr;
  
  -- Se nao encontrar
  IF cr_craprdr%NOTFOUND THEN
  
  INSERT INTO craprdr(nmprogra,dtsolici)
       VALUES('TELA_GRUPO_ECONOMICO', SYSDATE)
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
        'GRUPO_ECONOMICO_TXCUMULATIVIDADE'
        , 'TELA_CONTAS_GRUPO_ECONOMICO'
        , 'pc_tela_atualiza_flg_cumula'
        , 'pr_idgrupo, pr_flgcumulatividade, pr_cdcoordenador'
        , vr_nrseqrdr);
  
  COMMIT;
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Referencia a TELA_GRUPO_ECONOMICO criado com sucesso!');
  
END;
