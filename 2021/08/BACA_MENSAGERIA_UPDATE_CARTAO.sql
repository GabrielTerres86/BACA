BEGIN
  DECLARE 
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CRD_UNICRED_SERVICES';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  BEGIN
    -- Buscar RDR
    OPEN  cr_craprdr;
    FETCH cr_craprdr INTO vr_nrseqrdr;
    -- Se nao encontrar
    IF cr_craprdr%NOTFOUND THEN
      INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CRD_UNICRED_SERVICES', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
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
           'GRAVAR_NRCARTAO_VISA', 
           'CRD_UNICRED_SERVICES', 
           'pc_gravar_nrcartao_visa', 
           'pr_cdcooper,pr_nrdconta,pr_nrctrcrd,pr_nrcrcard,pr_dtvalida', 
           vr_nrseqrdr
    );
  
    COMMIT;
    
  EXCEPTION 
    WHEN OTHERS THEN
    dbms_output.put_line('Erro ao executar: CRD_UNICRED_SERVICES --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
    ROLLBACK;
  END;
END;
