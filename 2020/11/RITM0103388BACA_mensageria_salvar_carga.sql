BEGIN
  DECLARE 
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CCRD0011';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  BEGIN
    -- Buscar RDR
    OPEN  cr_craprdr;
    FETCH cr_craprdr INTO vr_nrseqrdr;
    -- Se nao encontrar
    IF cr_craprdr%NOTFOUND THEN
      INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
    END IF;
    -- Fechar o cursor
    CLOSE cr_craprdr;
    
    INSERT INTO crapaca (
           nmdeacao, 
           nmpackag, 
           nmproced, 
           lstparam, 
           nrseqrdr
    ) VALUES (
           'SALVA_CARGA_PREAPROV', 
           'CCRD0011', 
           'pc_salvar_carga_web', 
           'pr_idcarga, pr_dtinivigencia, pr_dtfinvigencia', 
           vr_nrseqrdr
    );
    COMMIT;
    
  EXCEPTION 
    WHEN OTHERS THEN
    dbms_output.put_line('Erro ao executar: BUSCA_CARGA_PREAPROV --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
    ROLLBACK;
  END;
END;
