DECLARE

  -- Buscar registro da RDR
  CURSOR cr_craprdr IS
    SELECT t.nrseqrdr FROM craprdr t WHERE t.NMPROGRA = 'CCRD0011';

  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  wk_rotina   varchar2(200) := 'Script Baca RITM0073433';

BEGIN
  begin
    -- Buscar RDR
    OPEN cr_craprdr;
    FETCH cr_craprdr
      INTO vr_nrseqrdr;
  
    -- Se nao encontrar
    IF cr_craprdr%NOTFOUND THEN
    
      INSERT INTO craprdr
        (nmprogra, dtsolici)
      VALUES
        ('CCRD0011', SYSDATE)
      RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
    
    END IF;
  
    -- Fechar o cursor
    CLOSE cr_craprdr;
  
    INSERT INTO crapaca
      (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
      ('RODAR_REL_BASE_CADASTRAL',
       'CCRD0011',
       'pc_rodar_rel_basecad',
       'pr_cdcooper',
       vr_nrseqrdr);
  
    COMMIT;
    -- Apresenta uma mensagem de ok
    dbms_output.put_line('Referencia a CCRD0011 criado com sucesso!');
  
    UPDATE craptel l
       SET l.cdopptel = l.cdopptel || ',R',
           l.lsopptel = l.lsopptel || ',RELATORIO'
     WHERE l.nmdatela = 'CARCRD'
       AND l.nmrotina = 'PRMCRD';
  
    COMMIT;
    dbms_output.put_line('registro da CRAPTEL atualizada com sucesso!');
  
    DELETE FROM crapace a
     WHERE lower(a.cdoperad) IN
           ('f0030641', 'f0030947', 'f0031849', 'f0031749', 'f0031296')
       AND a.nmdatela = 'CARCRD'
       AND a.nmrotina = 'PRMCRD';
  
    COMMIT;
     
    dbms_output.put_line('Acessos antigos a tela CARCRD rotina PRMCRD removidos com sucesso!');
      
     
    -- f0030641 
    INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
    VALUES ('CARCRD', '@', 'f0030641', 'PRMCRD', 3, 1, 1, 2);
    INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
    VALUES ('CARCRD', 'C', 'f0030641', 'PRMCRD', 3, 1, 1, 2);
    INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
    VALUES ('CARCRD', 'R', 'f0030641', 'PRMCRD', 3, 1, 1, 2);  
    
    -- f0030947
    INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
    VALUES ('CARCRD', '@', 'f0030947', 'PRMCRD', 3, 1, 1, 2);
    INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
    VALUES ('CARCRD', 'C', 'f0030947', 'PRMCRD', 3, 1, 1, 2);
    INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
    VALUES ('CARCRD', 'R', 'f0030947', 'PRMCRD', 3, 1, 1, 2);
    
    -- f0031849
    INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
    VALUES ('CARCRD', '@', 'f0031849', 'PRMCRD', 3, 1, 1, 2);
    INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
    VALUES ('CARCRD', 'C', 'f0031849', 'PRMCRD', 3, 1, 1, 2);
    INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
    VALUES ('CARCRD', 'R', 'f0031849', 'PRMCRD', 3, 1, 1, 2);  

    -- f0031749
    INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
    VALUES ('CARCRD', '@', 'f0031749', 'PRMCRD', 3, 1, 1, 2);
    INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
    VALUES ('CARCRD', 'C', 'f0031749', 'PRMCRD', 3, 1, 1, 2);
    INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
    VALUES ('CARCRD', 'R', 'f0031749', 'PRMCRD', 3, 1, 1, 2);  

    -- f0031296
    INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
    VALUES ('CARCRD', '@', 'f0031296', 'PRMCRD', 3, 1, 1, 2);
    INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
    VALUES ('CARCRD', 'C', 'f0031296', 'PRMCRD', 3, 1, 1, 2);
    INSERT INTO crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, Idevento, idambace)
    VALUES ('CARCRD', 'R', 'f0031296', 'PRMCRD', 3, 1, 1, 2);  
  
    COMMIT;
    dbms_output.put_line('Novas permissoes adicionadas com sucesso!');
    dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
  exception
    when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||
                           ' --- detalhes do erro: ' || SQLCODE || ': ' ||
                           SQLERRM);
      ROLLBACK;
  end;
END;
