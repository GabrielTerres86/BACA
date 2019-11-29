begin
  --#######################################################################################################################################
  --
  -- Criação de referência "CCRD0011.pccrd_lista_motivos_recusa"
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CCRD0011.pccrd_lista_motivos_recusa"';
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CCRD0011';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
    begin
      -- Buscar RDR
      OPEN  cr_craprdr;
      FETCH cr_craprdr INTO vr_nrseqrdr;
      -- Se nao encontrar
      IF cr_craprdr%NOTFOUND THEN
        INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craprdr;
      INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)VALUES('LISTAR_MOTIVOS_REJEITAR', 'CCRD0011', 'pccrd_lista_motivos_recusa', '', vr_nrseqrdr);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de referência "CCRD0011.pccrd_verifica_limop_web"
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CCRD0011.pccrd_verifica_limop_web"';
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CCRD0011';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
    begin
      -- Buscar RDR
      OPEN  cr_craprdr;
      FETCH cr_craprdr INTO vr_nrseqrdr;
      -- Se nao encontrar
      IF cr_craprdr%NOTFOUND THEN
        INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craprdr;
      INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)VALUES('VERIFICA_LIMITE_OPERACIONAL', 'CCRD0011', 'pccrd_verifica_limop_web', 'pr_nrdconta, pr_valorlimite, pr_indlim', vr_nrseqrdr);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de referência "CCRD0011.pccrd_lista_motiv_bloqueio_web"
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CCRD0011.pccrd_lista_motiv_bloqueio_web"';
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CCRD0011';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
    begin
      -- Buscar RDR
      OPEN  cr_craprdr;
      FETCH cr_craprdr INTO vr_nrseqrdr;
      -- Se nao encontrar
      IF cr_craprdr%NOTFOUND THEN
        INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craprdr;
      INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)VALUES('LISTAR_MOTIVOS_BLOQUEIO', 'CCRD0011', 'pccrd_lista_motiv_bloqueio_web', '', vr_nrseqrdr);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de referência "CCRD0011.pccrd_consulta_info_aprovado"
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CCRD0011.pccrd_consulta_info_aprovado"';
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CCRD0011';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
    begin
      -- Buscar RDR
      OPEN  cr_craprdr;
      FETCH cr_craprdr INTO vr_nrseqrdr;
      -- Se nao encontrar
      IF cr_craprdr%NOTFOUND THEN
        INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craprdr;
      INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)VALUES('CONSULTA_INFORMACAO_APROVADO', 'CCRD0011', 'pccrd_consulta_info_aprovado', 'pr_nrdconta', vr_nrseqrdr);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de referência "CCRD0011.pccrd_gravar_motivo_recusa"
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CCRD0011.pccrd_gravar_motivo_recusa"';
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CCRD0011';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
    begin
      -- Buscar RDR
      OPEN  cr_craprdr;
      FETCH cr_craprdr INTO vr_nrseqrdr;
      -- Se nao encontrar
      IF cr_craprdr%NOTFOUND THEN
        INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craprdr;
      INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)VALUES('GRAVAR_MOTIVOS_REJEITAR', 'CCRD0011', 'pccrd_gravar_motivo_recusa', 'pr_nrdconta,pr_coddominio', vr_nrseqrdr);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de referência "CCRD0011.pccrd_verifica_admcrd"
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CCRD0011.pccrd_verifica_admcrd"';
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CCRD0011';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
    begin
      -- Buscar RDR
      OPEN  cr_craprdr;
      FETCH cr_craprdr INTO vr_nrseqrdr;
      -- Se nao encontrar
      IF cr_craprdr%NOTFOUND THEN
        INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craprdr;
      INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)VALUES('VERIFICA_TPADMCRD', 'CCRD0011', 'pccrd_verifica_admcrd', 'pr_nrdconta, nrcrcard', vr_nrseqrdr);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de referência "TELA_ATENDA_CARTAOCREDITO.pc_busca_formas_pgto_adm"
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "TELA_ATENDA_CARTAOCREDITO.pc_busca_formas_pgto_adm"';
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'TELA_ATENDA_CARTAOCREDITO';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
    begin
      -- Buscar RDR
      OPEN  cr_craprdr;
      FETCH cr_craprdr INTO vr_nrseqrdr;
      -- Se nao encontrar
      IF cr_craprdr%NOTFOUND THEN
        INSERT INTO craprdr(nmprogra,dtsolici) VALUES('TELA_ATENDA_CARTAOCREDITO', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craprdr;
      INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)VALUES('BUSCAR_FORMAS_PGTO_ADM', 'TELA_ATENDA_CARTAOCREDITO', 'pc_busca_formas_pgto_adm', '', vr_nrseqrdr);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Carga de limites "tbcrd_config_categoria" (tela LIMCRD)
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Carga de limites "tbcrd_config_categoria" (tela LIMCRD)';
    begin
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (1, 11, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (1, 12, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (1, 13, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (1, 14, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (1, 15, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (2, 11, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (2, 12, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (2, 13, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (2, 14, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (2, 15, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (3, 11, 500, 10000.00, '3,7,11,19,22,27', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (3, 12, 500, 10000.00, '3,7,11,19,22,27', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (3, 13, 500, 10000.00, '3,7,11,19,22,27', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (3, 14, 500, 10000.00, '3,7,11,19,22,27', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (3, 15, 500, 10000.00, '3,7,11,19,22,27', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (5, 11, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (5, 12, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (5, 13, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (5, 14, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (5, 15, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (6, 11, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (6, 12, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (6, 13, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (6, 14, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (6, 15, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (7, 11, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (7, 12, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (7, 13, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (7, 14, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (7, 15, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (8, 11, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (8, 12, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (8, 13, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (8, 14, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (8, 15, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (9, 11, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (9, 12, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (9, 13, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (9, 14, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (9, 15, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (10, 11, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (10, 12, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (10, 13, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (10, 14, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (10, 15, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (11, 11, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (11, 12, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (11, 13, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (11, 14, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (11, 15, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (12, 11, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (12, 12, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (12, 13, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (12, 14, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (12, 15, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (13, 11, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (13, 12, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (13, 13, 500, 10000.00, '11', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (13, 14, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (13, 15, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (14, 11, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (14, 12, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (14, 13, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (14, 14, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (14, 15, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (16, 11, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (16, 12, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (16, 13, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (16, 14, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (16, 15, 500, 10000.00, '3,7,11,19,22', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (17, 11, 500, 10000.00, '3,7,11,19,22,27', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (17, 12, 500, 10000.00, '3,7,11,19,22,27', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (17, 13, 500, 10000.00, '3,7,11,19,22,27', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (17, 14, 500, 10000.00, '3,7,11,19,22,27', 2);
      insert into tbcrd_config_categoria (CDCOOPER, CDADMCRD, VLLIMITE_MINIMO, VLLIMITE_MAXIMO, DSDIAS_DEBITO, TPLIMCRD)values (17, 15, 500, 10000.00, '3,7,11,19,22,27', 2);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação do parâmetro PRAZOENTREGACRDBANCOOB (tabela crapprm) 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação do parâmetro PRAZOENTREGACRDBANCOOB (tabela crapprm)';
    CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
    begin
      -- Percorrer as cooperativas do cursor
      FOR rw_crapcop IN cr_crapcop LOOP
        INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'PRAZOENTREGACRDBANCOOB', 'Prazo médio de entrega dos cartões em dias. ', '20');
      END LOOP;
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação do parâmetro BLOQCARGAPREAPROV (tabela crapprm) 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação do parâmetro BLOQCARGAPREAPROV (tabela crapprm)';
    CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
    begin
      -- Percorrer as cooperativas do cursor
      FOR rw_crapcop IN cr_crapcop LOOP
        INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'BLOQCARGAPREAPROV', 'Parametro para informar o periodo do bloqueio da carga para o cooperado. M = Mensal, T = Trimestral, S = Semestral, A = Anual', 'S');
      END LOOP;
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação do parâmetro DIAVIGENCIACARGAPREAPROV (tabela crapprm) 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação do parâmetro DIAVIGENCIACARGAPREAPROV (tabela crapprm)';
    CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
    begin
      -- Percorrer as cooperativas do cursor
      FOR rw_crapcop IN cr_crapcop LOOP
        INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'DIAVIGENCIACARGAPREAPROV', 'Parametro para informar o periodo de vigencia da carga de pre-aprovado.', '30');
      END LOOP;
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação do parâmetro ATIVACAOCARGAPREAPROV (tabela crapprm) 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação do parâmetro ATIVACAOCARGAPREAPROV (tabela crapprm)';
    CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
    begin
      -- Percorrer as cooperativas do cursor
      FOR rw_crapcop IN cr_crapcop LOOP
        INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'ATIVACAOCARGAPREAPROV', 'Parametro para informar se a carga sera bloqueada/desbloqueada quando inserida no Aimaro. Opcao: M - Manual/A - Automatico', 'M');
      END LOOP;
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de referência "VERLOG.pc_busca_logs" e "VERLOG.pc_busca_log_itens" 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "VERLOG.pc_busca_logs" e "VERLOG.pc_busca_log_itens"';
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'VERLOG';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
    begin
      -- Buscar RDR
      OPEN  cr_craprdr;
      FETCH cr_craprdr INTO vr_nrseqrdr;
      -- Se nao encontrar
      IF cr_craprdr%NOTFOUND THEN
        INSERT INTO craprdr(nmprogra,dtsolici) VALUES('VERLOG', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craprdr;
      INSERT INTO crapaca(nmpackag, nmdeacao, nmproced, lstparam, nrseqrdr) VALUES ('TELA_VERLOG','BUSCA_LOGS','pc_busca_logs','pr_cdcooperativa,pr_nrdconta,pr_dtopeini,pr_dtopefin,pr_dsorigem,pr_cdoperad,pr_dstransa,pr_pagina,pr_idseqttl',vr_nrseqrdr);
      INSERT INTO crapaca(nmpackag, nmdeacao, nmproced, lstparam, nrseqrdr) VALUES ('TELA_VERLOG','BUSCA_LOG_ITENS','pc_busca_log_itens','pr_dsrowid',vr_nrseqrdr);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação do parâmetro VERLOG_NRITENS_PAGINACAO (tabela crapprm) 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação do parâmetro VERLOG_NRITENS_PAGINACAO (tabela crapprm)';
    CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
    begin
      -- Percorrer as cooperativas do cursor
      FOR rw_crapcop IN cr_crapcop LOOP
        INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'VERLOG_NRITENS_PAGINACAO', 'Maximo de itens para paginacao na listagem da VERLOG.', '15');
      END LOOP;
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Alteração do registro da tela VERLOG (tabela CRAPTEL) 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'CAlteração do registro da tela VERLOG (tabela CRAPTEL) ';
    begin
      UPDATE craptel SET idambtel = 0 WHERE nmdatela = 'VERLOG';  
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de referência "CCRD0011.pccrd_salvar_limites_ope"
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CCRD0011.pccrd_salvar_limites_ope"';
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CCRD0011';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
    begin
      -- Buscar RDR
      OPEN  cr_craprdr;
      FETCH cr_craprdr INTO vr_nrseqrdr;
      -- Se nao encontrar
      IF cr_craprdr%NOTFOUND THEN
        INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craprdr;
      INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)VALUES ('SALVA_LIMITES_OPERACIONAIS', 'CCRD0011', 'pccrd_salvar_limites_ope', 'pr_cdcooperativa, pr_id, pr_vllimite_outo, pr_vllimite_cons, pr_vllimite_disp, pr_perseguranca, pr_perdisp_majo, pr_perdisp_prea, pr_perdisp_oper, pr_email_notif', vr_nrseqrdr);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de referência "CCRD0011.pccrd_buscar_limites_ope"
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CCRD0011.pccrd_buscar_limites_ope"';
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CCRD0011';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
    begin
      -- Buscar RDR
      OPEN  cr_craprdr;
      FETCH cr_craprdr INTO vr_nrseqrdr;
      -- Se nao encontrar
      IF cr_craprdr%NOTFOUND THEN
        INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craprdr;
      INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)VALUES ('BUSCA_LIMITES_OPERACIONAIS', 'CCRD0011', 'pccrd_buscar_limites_ope', 'pr_cdcooperativa', vr_nrseqrdr);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de referência "CCRD0011.pccrd_bloqdesbloq_carga"
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CCRD0011.pccrd_bloqdesbloq_carga"';
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CCRD0011';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
    begin
      -- Buscar RDR
      OPEN  cr_craprdr;
      FETCH cr_craprdr INTO vr_nrseqrdr;
      -- Se nao encontrar
      IF cr_craprdr%NOTFOUND THEN
        INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craprdr;
      INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)  VALUES ('BLOQUEAR_DESBLOQUEAR_CARGA', 'CCRD0011', 'pccrd_bloqdesbloq_carga', 'pr_idcarga, pr_cdcooperativa', vr_nrseqrdr);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de referência "CCRD0011.pccrd_buscar_historico"
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CCRD0011.pccrd_buscar_historico"';
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CCRD0011';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
    begin
      -- Buscar RDR
      OPEN  cr_craprdr;
      FETCH cr_craprdr INTO vr_nrseqrdr;
      -- Se nao encontrar
      IF cr_craprdr%NOTFOUND THEN
        INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craprdr;
      INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)  VALUES ('BUSCA_HISTORICO', 'CCRD0011', 'pccrd_buscar_historico', 'pr_cdcooperativa, pr_idcarga, pr_pagina, pr_tamanho_pagina', vr_nrseqrdr);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de referência para nova tela LOPCRD
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência para nova tela LOPCRD';
    aux_rsprogra  VARCHAR2(50) := 'Limites operacionais de cartao de credito';
    aux_nmdatela  VARCHAR2(50) := 'CARCRD';
    aux_dsprogra  VARCHAR2(50) := 'Limites operacionais de cartao de credito';
    aux_cdopcoes  VARCHAR2(50) := '@,C,a';
    aux_dsopcoes  VARCHAR2(90) := 'ACESSO,CONSULTAR';
    aux_nmrotina  VARCHAR2(90) := 'LOPCRD';
    aux_nrmodulo  NUMBER       := 5;
    aux_nrordprg  NUMBER;
    -- Cursor para as cooperativas
    CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
    begin
      -- Percorrer as cooperativas do cursor
      FOR rw_crapcop IN cr_crapcop LOOP
        INSERT INTO craptel(cdcooper,nmdatela,cdopptel,lsopptel,tldatela,tlrestel,nrmodulo,inacesso,nrordrot,nrdnivel,idevento,idambtel,idsistem,nmrotina)
        VALUES (rw_crapcop.cdcooper,aux_nmdatela,aux_cdopcoes,aux_dsopcoes,aux_dsprogra,aux_rsprogra,aux_nrmodulo,0,1,1
        ,0    /* 0 - na    , 1 - progrid, 2 - assemb */ 
        ,2    /* 0 - todos , 1 - ayllos , 2 - web */
        ,1    /* 1 - ayllos, 2 - progrid */ 
        ,aux_nmrotina);  
      END LOOP;
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de acessos a tela LOPCRD 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de acessos a tela LOPCRD';
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.flgativo = 1;

    CURSOR cr_crapope IS 
      SELECT  ope.cdoperad, 
          ope.cdcooper 
        FROM crapope ope 
       WHERE UPPER(ope.cdoperad) LIKE UPPER('f%')
         AND ope.cdsitope = 1
         AND ope.cdoperad NOT IN ('f0030519','f0030260','f0031839','f0030947','f0032094','f0030641');

    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
    vr_exc_saida     EXCEPTION;
    vr_qtdsuces      INTEGER := 0;
    vr_qtderror      INTEGER := 0;
    begin
      --Limpa registros
      DELETE FROM crapace ace WHERE ace.nmdatela = 'LOPCRD';
      FOR rw_crapcop IN cr_crapcop LOOP
        -- Opção '@'
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030519', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030260', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0031839', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030947', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030641', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0032094', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);
        -- Opção 'C'
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030519', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030260', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0031839', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030947', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030641', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0032094', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);
        -- Opção 'A'
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030519', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030260', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0031839', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030947', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030641', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);    
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0032094', 'LOPCRD', rw_crapcop.cdcooper, 1, 1, 2);    
      END LOOP;  
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de referência "CCRD0011.pccrd_buscar_carga_coop_sas"
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CCRD0011.pccrd_buscar_carga_coop_sas"';
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CCRD0011';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
    begin
      -- Buscar RDR
      OPEN  cr_craprdr;
      FETCH cr_craprdr INTO vr_nrseqrdr;
      -- Se nao encontrar
      IF cr_craprdr%NOTFOUND THEN
        INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craprdr;
      INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('BUSCAR_CARGA_COOPERATIVA_SAS', 'CCRD0011', 'pccrd_buscar_carga_coop_sas', 'pr_cdcooperativa, pr_pagina, pr_tamanho_pagina', vr_nrseqrdr);  
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de referência para nova tela CARCRD
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência para nova tela CARCRD';
    aux_rsprogra  VARCHAR2(50) := 'OFERTA E CONTRATACAO DO CARTAO';
    aux_nmdatela  VARCHAR2(50) := 'CARCRD';
    aux_dsprogra  VARCHAR2(50) := 'OFERTA E CONTRATACAO DO CARTAO';
    aux_cdopcoes  VARCHAR2(50) := '@,C';
    aux_dsopcoes  VARCHAR2(90) := 'ACESSO,CONSULTAR';
    aux_nrordprg  NUMBER;
    -- Cursor para as cooperativas
    CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
    begin
      -- Percorrer as cooperativas do cursor
      FOR rw_crapcop IN cr_crapcop LOOP
        SELECT NVL(MAX(prg.nrordprg),0) + 1 
        INTO aux_nrordprg
        FROM crapprg prg
         WHERE prg.cdcooper = rw_crapcop.cdcooper
         AND prg.nrsolici = 50;

        INSERT INTO crapprg(cdcooper,cdprogra,dsprogra##1,inctrprg,inlibprg,nmsistem,nrordprg,nrsolici)
        VALUES(rw_crapcop.cdcooper,aux_nmdatela,aux_dsprogra
        ,1 /* nao executado */
        ,1 /* liberado */
        ,'CRED',aux_nrordprg,50);

        INSERT INTO craptel(cdcooper,nmdatela,cdopptel,lsopptel,tldatela,tlrestel,nrmodulo,inacesso,nrordrot,nrdnivel,idevento,idambtel,idsistem)
        VALUES (rw_crapcop.cdcooper,aux_nmdatela,aux_cdopcoes,aux_dsopcoes,aux_dsprogra,aux_rsprogra,5,0,1,1
        ,0    /* 0 - na    , 1 - progrid, 2 - assemb */ 
        ,2    /* 0 - todos , 1 - ayllos , 2 - web */
        ,1);  /* 1 - ayllos, 2 - progrid */ 
        
      END LOOP;
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de acessos a tela CARCRD 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de acessos a tela CARCRD';
    CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1;

    CURSOR cr_crapope IS 
    SELECT ope.cdoperad, 
         ope.cdcooper 
      FROM crapope ope 
     WHERE UPPER(ope.cdoperad) LIKE UPPER('f%')
         AND ope.cdsitope = 1
         AND ope.cdoperad NOT IN ('f0030519','f0030641','f0030260','f0031839','f0032094','f0030947');

    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
    vr_exc_saida     EXCEPTION;
    vr_qtdsuces      INTEGER := 0;
    vr_qtderror      INTEGER := 0;
    begin
      --Limpa registros
      DELETE FROM crapace ace WHERE ace.nmdatela = 'CARCRD';
      FOR rw_crapcop IN cr_crapcop LOOP
        -- Opção '@'
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030519', ' ', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030641', ' ', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030260', ' ', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0031839', ' ', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030947', ' ', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0032094', ' ', rw_crapcop.cdcooper, 1, 1, 2);
        -- Opção 'C'
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030519', ' ', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030641', ' ', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030260', ' ', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0031839', ' ', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030947', ' ', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0032094', ' ', rw_crapcop.cdcooper, 1, 1, 2);
      END LOOP;  
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;  
  --#######################################################################################################################################
  --
  -- Criação de referência para nova tela APRCAR
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência para nova tela APRCAR';
    aux_rsprogra  VARCHAR2(50) := 'Aprovacao carga de cartao pre-aprovado';
    aux_nmdatela  VARCHAR2(50) := 'CARCRD';
    aux_dsprogra  VARCHAR2(50) := 'Aprovacao carga de cartao pre-aprovado';
    aux_cdopcoes  VARCHAR2(50) := '@,C';
    aux_dsopcoes  VARCHAR2(90) := 'ACESSO,CONSULTAR';
    aux_nmrotina  VARCHAR2(90) := 'APRCAR';
    aux_nrmodulo  NUMBER       := 5;

    aux_nrordprg  NUMBER;

    -- Cursor para as cooperativas
    CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
    begin
      -- Percorrer as cooperativas do cursor
      FOR rw_crapcop IN cr_crapcop LOOP
        INSERT INTO craptel(cdcooper,nmdatela,cdopptel,lsopptel,tldatela,tlrestel,nrmodulo,inacesso,nrordrot,nrdnivel,idevento,idambtel,idsistem,nmrotina)
        VALUES (rw_crapcop.cdcooper,aux_nmdatela,aux_cdopcoes,aux_dsopcoes,aux_dsprogra,aux_rsprogra,aux_nrmodulo,0,1,1
        ,0    /* 0 - na    , 1 - progrid, 2 - assemb */ 
        ,2    /* 0 - todos , 1 - ayllos , 2 - web */
        ,1    /* 1 - ayllos, 2 - progrid */ 
        ,aux_nmrotina);  
      END LOOP;
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de acessos a tela APRCAR 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de acessos a tela APRCAR';
    CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1;
    
    CURSOR cr_crapope IS 
    SELECT ope.cdoperad, 
         ope.cdcooper 
      FROM crapope ope 
     WHERE UPPER(ope.cdoperad) LIKE UPPER('f%')
         AND ope.cdsitope = 1
        AND ope.cdoperad NOT IN ('f0030519','f0030260','f0031839','f0030947','f0032094','f0030641');
    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
    vr_exc_saida     EXCEPTION;
    vr_qtdsuces      INTEGER := 0;
    vr_qtderror      INTEGER := 0;
    begin
      --Limpa registros
      DELETE FROM crapace ace WHERE ace.nmdatela = 'APRCAR';
      FOR rw_crapcop IN cr_crapcop LOOP
        -- Opção '@'
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030519', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030260', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0031839', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030947', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030641', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0032094', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
        -- Opção 'C'
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030519', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030260', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0031839', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030947', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030641', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0032094', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
        -- Opção 'A'
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030519', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030260', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0031839', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030947', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030641', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);    
        INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0032094', 'APRCAR', rw_crapcop.cdcooper, 1, 1, 2);    
      END LOOP;
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;  
  --#######################################################################################################################################
  --
  -- Criação de referência "CCRD0011.pccrd_consulta_info_bloq_web"
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CCRD0011.pccrd_consulta_info_bloq_web"';
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CCRD0011';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
    begin
      -- Buscar RDR
      OPEN  cr_craprdr;
      FETCH cr_craprdr INTO vr_nrseqrdr;
      -- Se nao encontrar
      IF cr_craprdr%NOTFOUND THEN
        INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craprdr;
      INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)VALUES('CONSULTA_INFORMACAO_EXCLUSAO', 'CCRD0011', 'pccrd_consulta_info_bloq_web', 'pr_nrdconta, pr_nrcpfcnpjgc', vr_nrseqrdr);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  
  --#######################################################################################################################################
  --
  -- Criação de referência "CCRD0011.pccrd_consulta_bloqueio"
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CCRD0011.pccrd_consulta_bloqueio"';
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CCRD0011';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
    begin
      -- Buscar RDR
      OPEN  cr_craprdr;
      FETCH cr_craprdr INTO vr_nrseqrdr;
      -- Se nao encontrar
      IF cr_craprdr%NOTFOUND THEN
        INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craprdr;
      INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)VALUES('BUSCA_HISTORICO_BLOQUEIOS', 'CCRD0011', 'pccrd_consulta_bloqueio', 'pr_cdcooperativa, pr_nrdconta, pr_pagina, pr_tamanho_pagina', vr_nrseqrdr);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;        
  --#######################################################################################################################################
  --
  -- Criação de referência "CCRD0011.pccrd_gravar_bloqueio_web"
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CCRD0011.pccrd_gravar_bloqueio_web"';
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CCRD0011';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
    begin
      -- Buscar RDR
      OPEN  cr_craprdr;
      FETCH cr_craprdr INTO vr_nrseqrdr;
      -- Se nao encontrar
      IF cr_craprdr%NOTFOUND THEN
        INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craprdr;
      INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)VALUES('GRAVAR_MOTIVOS_BLOQUEIO', 'CCRD0011', 'pccrd_gravar_bloqueio_web', 'pr_nrdconta, pr_coddominio, pr_indtbloq, pr_inacao', vr_nrseqrdr);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;        
  --#######################################################################################################################################
  --
  -- Criação de referência "CCRD0011.pccrd_consulta_limite_web"
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de referência "CCRD0011.pccrd_consulta_limite_web"';
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CCRD0011';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
    begin
      -- Buscar RDR
      OPEN  cr_craprdr;
      FETCH cr_craprdr INTO vr_nrseqrdr;
      -- Se nao encontrar
      IF cr_craprdr%NOTFOUND THEN
        INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craprdr;
      INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)VALUES('CONSULTA_CARTAO_APROVADO', 'CCRD0011', 'pccrd_consulta_limite_web', 'pr_cdcooperativa, pr_cdoperad, pr_nmdatela, pr_nrdconta, pr_flgerlog, pr_nrcpfcnpjgc', vr_nrseqrdr);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;        
  --#######################################################################################################################################
  --
  -- Cria dominios de cartão - FRMPAGAMENTOADM; TPPREAPROVADOBLOQUEIOAIMARO; TPPREAPROVADOBLOQUEIOCANAIS; TPENDERECOENTREGAMOBILE
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Cria dominios de cartão - FRMPAGAMENTOADM; TPPREAPROVADOBLOQUEIOAIMARO; TPPREAPROVADOBLOQUEIOCANAIS; TPENDERECOENTREGAMOBILE';
    begin
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('TPENDERECOENTREGAMOBILE', '10', 'Residêncial', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('TPENDERECOENTREGAMOBILE', '13', 'Correspondência', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('TPENDERECOENTREGAMOBILE', '14', 'Complementar', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('TPENDERECOENTREGAMOBILE', '9', 'Comercial', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('TPENDERECOENTREGAMOBILE', '90', 'PA', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('TPENDERECOENTREGAMOBILE', '91', 'Outro PA', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('FRMPAGAMENTOADM', '2', 'Debito conta corrente (valor mínimo)', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('FRMPAGAMENTOADM', '1', 'Debito conta corrente (valor total)', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('FRMPAGAMENTOADM', '3', 'Boleto Bancário', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('TPPREAPROVADOBLOQUEIOAIMARO', '101', 'Sem interesse', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('TPPREAPROVADOBLOQUEIOAIMARO', '102', 'Limite não adequado', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('TPPREAPROVADOBLOQUEIOAIMARO', '103', 'Conta de Risco', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('TPPREAPROVADOBLOQUEIOAIMARO', '104', 'Já possuo cartão de crédito', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('TPPREAPROVADOBLOQUEIOAIMARO', '105', 'Cobrança de anuidade', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('TPPREAPROVADOBLOQUEIOCANAIS', '201', 'O limite do cartão não atende minhas necessidades', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('TPPREAPROVADOBLOQUEIOCANAIS', '202', 'O valor da anuidade não atende minhas expectativas', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('TPPREAPROVADOBLOQUEIOCANAIS', '203', 'Os benefícios oferecidos não me atendem', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('TPPREAPROVADOBLOQUEIOCANAIS', '204', 'Estou insatisfeito com os serviços da cooperativa', 1);
      insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('TPPREAPROVADOBLOQUEIOCANAIS', '205', 'Outros motivos', 1);
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;  
  --#######################################################################################################################################
  --
  -- Criação do parâmetro CRD_ATIVA_PRE_APROVADO (tabela crapprm) 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação do parâmetro CRD_ATIVA_PRE_APROVADO (tabela crapprm)';
    CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
    begin
      -- Percorrer as cooperativas do cursor
      FOR rw_crapcop IN cr_crapcop LOOP
        INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CRD_ATIVA_PRE_APROVADO', 'Parametro para informar se a funcionalidade de cartao de credito pre-aprovado esta ativa ou nao para a cooperativa', '0');
      END LOOP;
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação de registros de notificações  
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de registros de notificações';
	wk_cdmensagem number;
    begin
    
	  
	  
      -- Menu para o mobile abrir ao clicar no CADASTRAR
      INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)VALUES (1006,900,'Cartões',1,1,1,'2.7.0.0',NULL);
      
	  
	  --busca último código existente;
	  select max(mm.cdmensagem)+1 into wk_cdmensagem from tbgen_notif_msg_cadastro mm;
	  -- Inicio Limite pre-aprovado disponivel
	  
      INSERT INTO cecred.tbgen_notif_msg_cadastro(cdmensagem,cdorigem_mensagem,dstitulo_mensagem,dstexto_mensagem,dshtml_mensagem,cdicone,inexibir_banner,nmimagem_banner,inexibe_botao_acao_mobile,dstexto_botao_acao_mobile,cdmenu_acao_mobile,dslink_acao_mobile,dsmensagem_acao_mobile,dsparam_acao_mobile,inenviar_push)
      VALUES(wk_cdmensagem,8,'Oferta de cartão pré-aprovado','Tem um cartão Ailos esperando por você','<p>Voc&ecirc; possui um cart&atilde;o de cr&eacute;dito com limite pr&eacute;-aprovado. Conheça os benef&iacute;cios e solicite agora.</p>',3,0,NULL,1,'CONTRATAR',1006,NULL,NULL,NULL,1);
      -- Inserir na tbgen_notif_automatica_prm
      INSERT INTO tbgen_notif_automatica_prm(cdorigem_mensagem,cdmotivo_mensagem,dsmotivo_mensagem,cdmensagem,dsvariaveis_mensagem,inmensagem_ativa,intipo_repeticao,nrdias_semana,nrsemanas_repeticao,nrdias_mes,nrmeses_repeticao,hrenvio_mensagem,nmfuncao_contas,dhultima_execucao)
      VALUES(8,12,'Oferta de cartão pré-aprovado',wk_cdmensagem,'<p>Você possui um cartão de crédito com limite pré-aprovado. Conheça os benefícios e solicite agora.</p>',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
      -- Fim Limite pre-aprovado disponivel
      
	  --busca último código existente;
	  select max(mm.cdmensagem)+1 into wk_cdmensagem from tbgen_notif_msg_cadastro mm;
	  -- Inicio solicitacao sem assinatura
      INSERT INTO cecred.tbgen_notif_msg_cadastro(cdmensagem,cdorigem_mensagem,dstitulo_mensagem,dstexto_mensagem,dshtml_mensagem,cdicone,inexibir_banner,nmimagem_banner,inexibe_botao_acao_mobile,dstexto_botao_acao_mobile,cdmenu_acao_mobile,dslink_acao_mobile,dsmensagem_acao_mobile,dsparam_acao_mobile,inenviar_push)
      VALUES(wk_cdmensagem,8,'Solicitação de Cartão','Solicitação cartão - Pendente de autorização','<p>Solicita&ccedil;&atilde;o de Cart&atilde;o Ailos pendente de autoriza&ccedil;&atilde;o</p><p>Voc&ecirc; possui uma proposta de cart&atilde;o pendente para aprova&ccedil;&atilde;o.</p><p>Acesse o menu Cart&otilde;es &gt; Autoriza&ccedil;&atilde;o de solicita&ccedil;&atilde;o do Cart&atilde;o, verifique as informa&ccedil;&otilde;es e proceda com a aprova&ccedil;&atilde;o.</p><p>.</p>',3,0,NULL,0,NULL,NULL,NULL,NULL,NULL,1);

      INSERT INTO tbgen_notif_automatica_prm(cdorigem_mensagem,cdmotivo_mensagem,dsmotivo_mensagem,cdmensagem,dsvariaveis_mensagem,inmensagem_ativa,intipo_repeticao,nrdias_semana,nrsemanas_repeticao,nrdias_mes,nrmeses_repeticao,hrenvio_mensagem,nmfuncao_contas,dhultima_execucao)
      VALUES(8,13,'CARTÃO DE CREDITO - Solicitação de Cartão - sem assinatura conjunta',wk_cdmensagem,'<p>Solicita&ccedil;&atilde;o de Cart&atilde;o Ailos pendente de autoriza&ccedil;&atilde;o</p>',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
      -- Fim solicitacao sem assinatura
	  
	  --busca último código existente;
	  select max(mm.cdmensagem)+1 into wk_cdmensagem from tbgen_notif_msg_cadastro mm;
	  
      -- Inicio solicitacao com assinatura
      INSERT INTO cecred.tbgen_notif_msg_cadastro(cdmensagem,cdorigem_mensagem,dstitulo_mensagem,dstexto_mensagem,dshtml_mensagem,cdicone,inexibir_banner,nmimagem_banner,inexibe_botao_acao_mobile,dstexto_botao_acao_mobile,cdmenu_acao_mobile,dslink_acao_mobile,dsmensagem_acao_mobile,dsparam_acao_mobile,inenviar_push)
      VALUES(wk_cdmensagem,8,'Solicitação de Cartão',' ','<p>Voc&ecirc; possui uma proposta de cart&atilde;o pendente para aprova&ccedil;&atilde;o.</p><p>Acesse o menu Cart&otilde;es &gt; Autoriza&ccedil;&atilde;o de solicita&ccedil;&atilde;o do Cart&atilde;o e/ou Transa&ccedil;&otilde;es Pendentes, verifique as informa&ccedil;&otilde;es e proceda com a aprova&ccedil;&atilde;o</p>',3,0,NULL,0,NULL,NULL,NULL,NULL,NULL,1);

      INSERT INTO tbgen_notif_automatica_prm(cdorigem_mensagem,cdmotivo_mensagem,dsmotivo_mensagem,cdmensagem,dsvariaveis_mensagem,inmensagem_ativa,intipo_repeticao,nrdias_semana,nrsemanas_repeticao,nrdias_mes,nrmeses_repeticao,hrenvio_mensagem,nmfuncao_contas,dhultima_execucao)
      VALUES(8,14,'CARTÃO DE CREDITO - Solicitação de Cartão - com assinatura conjunta',wk_cdmensagem,'<p>Solicita&ccedil;&atilde;o de Cart&atilde;o Ailos pendente de autoriza&ccedil;&atilde;o</p>',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
      -- Fim solicitacao com assinatura   
	  
	  --busca último código existente;
	  select max(mm.cdmensagem)+1 into wk_cdmensagem from tbgen_notif_msg_cadastro mm;
	  
      -- Inicio Upgrade/Downgrade
      INSERT INTO cecred.tbgen_notif_msg_cadastro(cdmensagem,cdorigem_mensagem,dstitulo_mensagem,dstexto_mensagem,dshtml_mensagem,cdicone,inexibir_banner,nmimagem_banner,inexibe_botao_acao_mobile,dstexto_botao_acao_mobile,cdmenu_acao_mobile,dslink_acao_mobile,dsmensagem_acao_mobile,dsparam_acao_mobile,inenviar_push)
      VALUES(wk_cdmensagem,8,'Upgrade/Downgrade','Solicitação cartão - Pendente de autorização ','<p>Voc&ecirc; possui uma proposta de cart&atilde;o pendente para aprova&ccedil;&atilde;o.</p><p>Acesse o menu Cart&otilde;es &gt; Autoriza&ccedil;&atilde;o de solicita&ccedil;&atilde;o do Cart&atilde;o, verifique as informa&ccedil;&otilde;es e proceda com a aprova&ccedil;&atilde;o.</p><p>&nbsp;</p> ',3,0,NULL,0,NULL,NULL,NULL,NULL,NULL,1);

      INSERT INTO tbgen_notif_automatica_prm(cdorigem_mensagem,cdmotivo_mensagem,dsmotivo_mensagem,cdmensagem,dsvariaveis_mensagem,inmensagem_ativa,intipo_repeticao,nrdias_semana,nrsemanas_repeticao,nrdias_mes,nrmeses_repeticao,hrenvio_mensagem,nmfuncao_contas,dhultima_execucao)
      VALUES(8,15,'CARTÃO DE CREDITO - Upgrade/downgrade ',wk_cdmensagem,'<p>Solicita&ccedil;&atilde;o de Cart&atilde;o Ailos pendente de autoriza&ccedil;&atilde;o</p>',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
      -- Fim Upgrade/Downgrade

	  --busca último código existente;
	  select max(mm.cdmensagem)+1 into wk_cdmensagem from tbgen_notif_msg_cadastro mm;
	  
      -- Inicio Alteracao de limite
      INSERT INTO cecred.tbgen_notif_msg_cadastro(cdmensagem,cdorigem_mensagem,dstitulo_mensagem,dstexto_mensagem,dshtml_mensagem,cdicone,inexibir_banner,nmimagem_banner,inexibe_botao_acao_mobile,dstexto_botao_acao_mobile,cdmenu_acao_mobile,dslink_acao_mobile,dsmensagem_acao_mobile,dsparam_acao_mobile,inenviar_push)
      VALUES(wk_cdmensagem,8,'Limite de Crédito','Alteração de Limite de Crédito','<p>Informamos que o limite do seu cart&atilde;o Ailos foi alterado. Para visualizar seu novo limite acesse o APP Ailos Cart&otilde;es ou entre em contato com sua Cooperativa.</p>',3,0,NULL,0,NULL,NULL,NULL,NULL,NULL,1);

      INSERT INTO tbgen_notif_automatica_prm(cdorigem_mensagem,cdmotivo_mensagem,dsmotivo_mensagem,cdmensagem,dsvariaveis_mensagem,inmensagem_ativa,intipo_repeticao,nrdias_semana,nrsemanas_repeticao,nrdias_mes,nrmeses_repeticao,hrenvio_mensagem,nmfuncao_contas,dhultima_execucao)
      VALUES(8,16,'ALTERAÇÃO LIMITE',wk_cdmensagem,'<p>Altera&ccedil;&atilde;o de Limite de Cr&eacute;dito</p>',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
      -- Fim Alteracao Limite
	  
	  --busca último código existente;
	  select max(mm.cdmensagem)+1 into wk_cdmensagem from tbgen_notif_msg_cadastro mm;
	  
	  
      -- Inicio Erros NOTURNO
      INSERT INTO cecred.tbgen_notif_msg_cadastro(cdmensagem,cdorigem_mensagem,dstitulo_mensagem,dstexto_mensagem,dshtml_mensagem,cdicone,inexibir_banner,nmimagem_banner,inexibe_botao_acao_mobile,dstexto_botao_acao_mobile,cdmenu_acao_mobile,dslink_acao_mobile,dsmensagem_acao_mobile,dsparam_acao_mobile,inenviar_push)
      VALUES(wk_cdmensagem,8,'Processos Noturnos','Erros noturnos processos Bancob','<p>Comunicamos que ocorreu uma inconsist&ecirc;ncia na solicita&ccedil;&atilde;o do seu cart&atilde;o Ailos. Favor entre em contato com sua Cooperativa.</p>',3,0,NULL,0,NULL,NULL,NULL,NULL,NULL,1);

      INSERT INTO tbgen_notif_automatica_prm(cdorigem_mensagem,cdmotivo_mensagem,dsmotivo_mensagem,cdmensagem,dsvariaveis_mensagem,inmensagem_ativa,intipo_repeticao,nrdias_semana,nrsemanas_repeticao,nrdias_mes,nrmeses_repeticao,hrenvio_mensagem,nmfuncao_contas,dhultima_execucao)
      VALUES(8,17,'ERRO NOTURNO - Erros noturnos processos Bancob',wk_cdmensagem,'<p>Inconsist&ecirc;ncia na aprova&ccedil;&atilde;o da proposta do cart&atilde;o</p>',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
      -- Fim Noturno   
	  
	  --busca último código existente;
	  select max(mm.cdmensagem)+1 into wk_cdmensagem from tbgen_notif_msg_cadastro mm;
	  
	  
      -- Inicio Recusa Esteira
      INSERT INTO cecred.tbgen_notif_msg_cadastro(cdmensagem,cdorigem_mensagem,dstitulo_mensagem,dstexto_mensagem,dshtml_mensagem,cdicone,inexibir_banner,nmimagem_banner,inexibe_botao_acao_mobile,dstexto_botao_acao_mobile,cdmenu_acao_mobile,dslink_acao_mobile,dsmensagem_acao_mobile,dsparam_acao_mobile,inenviar_push)
      VALUES(wk_cdmensagem,8,'Erro na solicitação do cartão','Solicitação não aprovada','<p>Comunicamos que ocorreu uma inconsist&ecirc;ncia na solicita&ccedil;&atilde;o do seu cart&atilde;o Ailos. Favor entre em contato com sua Cooperativa.</p>',3,0,NULL,0,NULL,NULL,NULL,NULL,NULL,1);

      INSERT INTO tbgen_notif_automatica_prm(cdorigem_mensagem,cdmotivo_mensagem,dsmotivo_mensagem,cdmensagem,dsvariaveis_mensagem,inmensagem_ativa,intipo_repeticao,nrdias_semana,nrsemanas_repeticao,nrdias_mes,nrmeses_repeticao,hrenvio_mensagem,nmfuncao_contas,dhultima_execucao)
      VALUES(8,18,'Erro na solicitação do cartão',wk_cdmensagem,'<p>Inconsist&ecirc;ncia na aprova&ccedil;&atilde;o da proposta do cart&atilde;o</p>',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
      -- Fim Recusa Esteira
    
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação do parâmetro PAGIHISTCARGAPREAPROV (tabela crapprm) 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação do parâmetro PAGIHISTCARGAPREAPROV (tabela crapprm)';
    CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
    begin
      -- Percorrer as cooperativas do cursor
      FOR rw_crapcop IN cr_crapcop LOOP
        INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'PAGIHISTCARGAPREAPROV', 'Define a quantidade de registros apresentados na pagina de historicos de bloqueio de carga', '10');
      END LOOP;
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação do parâmetro PAGINACAOHISTBLOQ (tabela crapprm) 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação do parâmetro PAGINACAOHISTBLOQ (tabela crapprm)';
    CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
    begin
      -- Percorrer as cooperativas do cursor
      FOR rw_crapcop IN cr_crapcop LOOP
        INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'PAGINACAOHISTBLOQ', 'Define a quantidade de registros apresentados na pagina de historicos', '10');
      END LOOP;
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação do parâmetro HABILITAPREAPROV (tabela crapprm) 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação do parâmetro HABILITAPREAPROV (tabela crapprm)';
    CURSOR cr_crapcop IS
    SELECT  *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
    begin
      -- Percorrer as cooperativas do cursor
      FOR rw_crapcop IN cr_crapcop LOOP
        INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'HABILITAPREAPROV', 'Ativar/Desativar opcao de pre aprovado na cooperativa (0 - desativada e 1 - ativada)', '0');
      END LOOP;
      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;
  --#######################################################################################################################################
  --
  -- Criação dos limites operacionais 
  --
  begin
    declare 
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação dos limites operacionais';
    begin
      
      --1  VIACREDI
      insert into tbcrd_limoper (IDLIMOP, CDCOOPER, VLLIMOUTORG, VLLIMCONSUMD, VLLIMDISP, NRPERCSEG, NRPERCDISPMAJOR, NRPERCDISPPA, NRPERCDISPOPNORM, DSEMAILS, CDOPERAD, DTALTERA, DTCADASTRO)
      values (1, 1, 800000000.00,636390620.89, 163609379.11, 10, 15, 16, 59, 'monique.tenfen@ailos.coop.br;otavio.theiss@ailos.coop.br', 'RDM', null, sysdate);

      --2  ACREDICOOP
      insert into tbcrd_limoper (IDLIMOP, CDCOOPER, VLLIMOUTORG, VLLIMCONSUMD, VLLIMDISP, NRPERCSEG, NRPERCDISPMAJOR, NRPERCDISPPA, NRPERCDISPOPNORM, DSEMAILS, CDOPERAD, DTALTERA, DTCADASTRO)
      values (2, 2, 36500000.00, 24510848.16, 11989151.84, 10, 15, 16, 59, 'monique.tenfen@ailos.coop.br;otavio.theiss@ailos.coop.br', 'RDM', null, sysdate);

      --5  ACENTRA
      insert into tbcrd_limoper (IDLIMOP, CDCOOPER, VLLIMOUTORG, VLLIMCONSUMD, VLLIMDISP, NRPERCSEG, NRPERCDISPMAJOR, NRPERCDISPPA, NRPERCDISPOPNORM, DSEMAILS, CDOPERAD, DTALTERA, DTCADASTRO)
      values (3, 5, 22500000.00, 17742071.34, 4757928.66, 10, 15, 16, 59, 'monique.tenfen@ailos.coop.br;otavio.theiss@ailos.coop.br', 'RDM', null, sysdate);

      --6  UNILOS
      insert into tbcrd_limoper (IDLIMOP, CDCOOPER, VLLIMOUTORG, VLLIMCONSUMD, VLLIMDISP, NRPERCSEG, NRPERCDISPMAJOR, NRPERCDISPPA, NRPERCDISPOPNORM, DSEMAILS, CDOPERAD, DTALTERA, DTCADASTRO)
      values (4, 6, 367000000.00,353986819.73 , 13013180.27, 10, 15, 16, 59, 'monique.tenfen@ailos.coop.br;otavio.theiss@ailos.coop.br', 'RDM', null, sysdate);

      --7  CREDCREA 
      insert into tbcrd_limoper (IDLIMOP, CDCOOPER, VLLIMOUTORG, VLLIMCONSUMD, VLLIMDISP, NRPERCSEG, NRPERCDISPMAJOR, NRPERCDISPPA, NRPERCDISPOPNORM, DSEMAILS, CDOPERAD, DTALTERA, DTCADASTRO)
      values (5, 7, 69600000.00, 49479396.78, 20120603.22, 10, 15, 16, 59, 'monique.tenfen@ailos.coop.br;otavio.theiss@ailos.coop.br', 'RDM', null, sysdate);

      --8  CREDELESC
      insert into tbcrd_limoper (IDLIMOP, CDCOOPER, VLLIMOUTORG, VLLIMCONSUMD, VLLIMDISP, NRPERCSEG, NRPERCDISPMAJOR, NRPERCDISPPA, NRPERCDISPOPNORM, DSEMAILS, CDOPERAD, DTALTERA, DTCADASTRO)
      values (6, 8, 7700000.00, 4266310.67, 3433689.33, 10, 15, 16, 59, 'monique.tenfen@ailos.coop.br;otavio.theiss@ailos.coop.br', 'RDM', null, sysdate);

      --9  TRANSPOCRED
      insert into tbcrd_limoper (IDLIMOP, CDCOOPER, VLLIMOUTORG, VLLIMCONSUMD, VLLIMDISP, NRPERCSEG, NRPERCDISPMAJOR, NRPERCDISPPA, NRPERCDISPOPNORM, DSEMAILS, CDOPERAD, DTALTERA, DTCADASTRO)
      values (7, 9, 38350000.00, 30509016.40, 7840983.60, 10, 15, 16, 59, 'monique.tenfen@ailos.coop.br;otavio.theiss@ailos.coop.br', 'RDM', null, sysdate);

      --10  CREDICOMIN
      insert into tbcrd_limoper (IDLIMOP, CDCOOPER, VLLIMOUTORG, VLLIMCONSUMD, VLLIMDISP, NRPERCSEG, NRPERCDISPMAJOR, NRPERCDISPPA, NRPERCDISPOPNORM, DSEMAILS, CDOPERAD, DTALTERA, DTCADASTRO)
      values (8, 10, 12750000.00, 11173448.89, 1576551.11, 10, 15, 16, 59, 'monique.tenfen@ailos.coop.br;otavio.theiss@ailos.coop.br', 'RDM', null, sysdate);

      --11  CREDIFOZ
      insert into tbcrd_limoper (IDLIMOP, CDCOOPER, VLLIMOUTORG, VLLIMCONSUMD, VLLIMDISP, NRPERCSEG, NRPERCDISPMAJOR, NRPERCDISPPA, NRPERCDISPOPNORM, DSEMAILS, CDOPERAD, DTALTERA, DTCADASTRO)
      values (9, 11, 65600000.00, 51009247.85, 14590752.15, 10, 15, 16, 59, 'monique.tenfen@ailos.coop.br;otavio.theiss@ailos.coop.br', 'RDM', null, sysdate);

      --12  CREVISC
      insert into tbcrd_limoper (IDLIMOP, CDCOOPER, VLLIMOUTORG, VLLIMCONSUMD, VLLIMDISP, NRPERCSEG, NRPERCDISPMAJOR, NRPERCDISPPA, NRPERCDISPOPNORM, DSEMAILS, CDOPERAD, DTALTERA, DTCADASTRO)
      values (10, 12, 15300000.00, 11182165.16, 4117834.84, 10, 15, 16, 59, 'monique.tenfen@ailos.coop.br;otavio.theiss@ailos.coop.br', 'RDM', null, sysdate);

      --13  CIVIA
      insert into tbcrd_limoper (IDLIMOP, CDCOOPER, VLLIMOUTORG, VLLIMCONSUMD, VLLIMDISP, NRPERCSEG, NRPERCDISPMAJOR, NRPERCDISPPA, NRPERCDISPOPNORM, DSEMAILS, CDOPERAD, DTALTERA, DTCADASTRO)
      values (11, 13, 33000000.00, 25643131.78, 7356868.22, 10, 15, 16, 59, 'monique.tenfen@ailos.coop.br;otavio.theiss@ailos.coop.br', 'RDM', null, sysdate);

      --14  EVOLUA
      insert into tbcrd_limoper (IDLIMOP, CDCOOPER, VLLIMOUTORG, VLLIMCONSUMD, VLLIMDISP, NRPERCSEG, NRPERCDISPMAJOR, NRPERCDISPPA, NRPERCDISPOPNORM, DSEMAILS, CDOPERAD, DTALTERA, DTCADASTRO)
      values (12, 14, 21500000.00, 18179308.68, 3320691.32, 10, 15, 16, 59, 'monique.tenfen@ailos.coop.br;otavio.theiss@ailos.coop.br', 'RDM', null, sysdate);

      --16  VIACREDI AV
      insert into tbcrd_limoper (IDLIMOP, CDCOOPER, VLLIMOUTORG, VLLIMCONSUMD, VLLIMDISP, NRPERCSEG, NRPERCDISPMAJOR, NRPERCDISPPA, NRPERCDISPOPNORM, DSEMAILS, CDOPERAD, DTALTERA, DTCADASTRO)
      values (13, 6, 95000000.00, 73498642.04, 21501357.96, 10, 15, 16, 59, 'monique.tenfen@ailos.coop.br;otavio.theiss@ailos.coop.br', 'RDM', null, sysdate);

      commit;
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
    end;
  end;

	--#######################################################################################################################################
	--
	-- Criação de referência "TELA_ATENDA_CARTAOCREDITO.pc_busca_prm_aprovacao_canais"
	--
	begin
	  declare 
		-- nome da rotina
		wk_rotina varchar2(200) := 'Criação de referência "TELA_ATENDA_CARTAOCREDITO.pc_busca_prm_aprovacao_canais"';
		-- Buscar registro da RDR
		CURSOR cr_craprdr IS
			SELECT t.nrseqrdr
			  FROM craprdr t
			 WHERE t.NMPROGRA = 'ATENDA_CRD';
		-- Variaveis
		vr_nrseqrdr craprdr.nrseqrdr%TYPE;
		begin
			-- Buscar RDR
			OPEN  cr_craprdr;
			FETCH cr_craprdr INTO vr_nrseqrdr;
			-- Se nao encontrar
			IF cr_craprdr%NOTFOUND THEN
				INSERT INTO craprdr(nmprogra,dtsolici) VALUES('ATENDA_CRD', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
			END IF;
			-- Fechar o cursor
			CLOSE cr_craprdr;
			INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)VALUES ('PRM_APROVACAO_CANAIS', 'TELA_ATENDA_CARTAOCREDITO', 'pc_busca_prm_aprovacao_canais', 'pr_cdcooper,pr_nrdconta,pr_nrctrcrd', vr_nrseqrdr);
			commit;
			dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
		exception
			when others then
			dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
			ROLLBACK;
		end;
	end;
	--#######################################################################################################################################
	--
	-- Criação de referência "TELA_ATENDA_CARTAOCREDITO.pc_busca_adm_crd"
	--
	begin
	  declare 
		-- nome da rotina
		wk_rotina varchar2(200) := 'Criação de referência "TELA_ATENDA_CARTAOCREDITO.pc_busca_adm_crd"';
		-- Buscar registro da RDR
		CURSOR cr_craprdr IS
			SELECT t.nrseqrdr
			  FROM craprdr t
			 WHERE t.NMPROGRA = 'ATENDA_CRD';
		-- Variaveis
		vr_nrseqrdr craprdr.nrseqrdr%TYPE;
		begin
			-- Buscar RDR
			OPEN  cr_craprdr;
			FETCH cr_craprdr INTO vr_nrseqrdr;
			-- Se nao encontrar
			IF cr_craprdr%NOTFOUND THEN
				INSERT INTO craprdr(nmprogra,dtsolici) VALUES('ATENDA_CRD', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
			END IF;
			-- Fechar o cursor
			CLOSE cr_craprdr;
			INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)VALUES ('BUSCA_ADM_CRD', 'TELA_ATENDA_CARTAOCREDITO', 'pc_busca_adm_crd', 'pr_cdcooper,pr_nrdconta, pr_tplimcrd', vr_nrseqrdr);
			commit;
			dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
		exception
			when others then
			dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
			ROLLBACK;
		end;
	end;
	--#######################################################################################################################################
	--
	-- Criação do parâmetro CRD_ATIVA_AUTORIZ_CANAIS (tabela crapprm) 
	--
	begin
	  declare 
		-- nome da rotina
		wk_rotina varchar2(200) := 'Criação do parâmetro CRD_ATIVA_AUTORIZ_CANAIS (tabela crapprm)';
		CURSOR cr_crapcop IS
		SELECT  *
		  FROM crapcop cop
		 WHERE cop.flgativo = 1;
		begin
			-- Percorrer as cooperativas do cursor
			FOR rw_crapcop IN cr_crapcop LOOP
				INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CRD_ATIVA_AUTORIZ_CANAIS', 'Parametro para informar se a funcionalidade de autorizacao de cartao de credito via canais esta ativa ou nao para a cooperativa', '0');
			END LOOP;
			commit;
			dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
		exception
			when others then
			dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
			ROLLBACK;
		end;
	end;
	--#######################################################################################################################################
	--
	-- Criação do parâmetro CRD_PZ_EXP_NOTI_CANAIS (tabela crapprm) 
	--
	begin
	  declare 
		-- nome da rotina
		wk_rotina varchar2(200) := 'Criação do parâmetro CRD_PZ_EXP_NOTI_CANAIS (tabela crapprm)';
		CURSOR cr_crapcop IS
		SELECT  *
		  FROM crapcop cop
		 WHERE cop.flgativo = 1;
		begin
			--Limpa registros
			DELETE FROM crapprm prm WHERE prm.cdacesso = 'CRD_PZ_EXP_NOTI_CANAIS';
			-- Percorrer as cooperativas do cursor
			FOR rw_crapcop IN cr_crapcop LOOP
				INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CRD_PZ_EXP_NOTI_CANAIS', 'Prazo em quantidade de dias para que as notificações (Transaçõies Pendentes) e propostas expirem - Aprovação por Canais', '10');
			END LOOP;
			commit;
			dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
		exception
			when others then
			dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
			ROLLBACK;
		end;
	end;
	--#######################################################################################################################################
	--
	-- Cria dominios de cartão - STATUSCRDCANAIS; MOTNAOAUTORIZACAO
	--
	begin
	  declare 
		-- nome da rotina
		wk_rotina varchar2(200) := 'Cria dominios de cartão - STATUSCRDCANAIS; MOTNAOAUTORIZACAO';
		begin
			insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('STATUSCRDCANAIS', '101', 'Aguardando Autorização', 0);
			insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('STATUSCRDCANAIS', '102', 'Aguardando Aprovação', 0);
			insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('STATUSCRDCANAIS', '103', 'Aguardando Entrega', 0);
			insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('MOTNAOAUTORIZACAO', '1', 'Limite divergente da solicitação', 1);
			insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('MOTNAOAUTORIZACAO', '2', 'Modalidade do cartão divergente da solicitação', 1);
			insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('MOTNAOAUTORIZACAO', '3', 'Desinteresse da solicitação do cartão', 1);
			insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)values ('MOTNAOAUTORIZACAO', '4', 'Endereço divergente do solicitado', 1);
			
			commit;
			dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
		exception
			when others then
			dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
			ROLLBACK;
		end;
	end;  
	--#######################################################################################################################################
	--
	-- Criação de referência "CCRD0011.pccracrd_salvar_param_cartao"
	--
	begin
	  declare 
		-- nome da rotina
		wk_rotina varchar2(200) := 'Criação de referência "CCRD0011.pccracrd_salvar_param_cartao"';
		-- Buscar registro da RDR
		CURSOR cr_craprdr IS
			SELECT t.nrseqrdr
			  FROM craprdr t
			 WHERE t.NMPROGRA = 'CCRD0011';
		-- Variaveis
		vr_nrseqrdr craprdr.nrseqrdr%TYPE;
		begin
			-- Buscar RDR
			OPEN  cr_craprdr;
			FETCH cr_craprdr INTO vr_nrseqrdr;
			-- Se nao encontrar
			IF cr_craprdr%NOTFOUND THEN
				INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
			END IF;
			-- Fechar o cursor
			CLOSE cr_craprdr;
			DELETE FROM crapaca WHERE nmdeacao = 'SALVAR_PARAMETROS_CARTAO';
			INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)VALUES ('SALVAR_PARAMETROS_CARTAO', 'CCRD0011', 'pccracrd_salvar_param_cartao', 'pr_cdcooper,pr_parametros', vr_nrseqrdr);
			commit;
			dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
		exception
			when others then
			dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
			ROLLBACK;
		end;
	end;
	--#######################################################################################################################################
	--
	-- Criação de referência "CCRD0011.pccracrd_obter_param_cartao"
	--
	begin
	  declare 
		-- nome da rotina
		wk_rotina varchar2(200) := 'Criação de referência "CCRD0011.pccracrd_obter_param_cartao"';
		-- Buscar registro da RDR
		CURSOR cr_craprdr IS
			SELECT t.nrseqrdr
			  FROM craprdr t
			 WHERE t.NMPROGRA = 'CCRD0011';
		-- Variaveis
		vr_nrseqrdr craprdr.nrseqrdr%TYPE;
		begin
			-- Buscar RDR
			OPEN  cr_craprdr;
			FETCH cr_craprdr INTO vr_nrseqrdr;
			-- Se nao encontrar
			IF cr_craprdr%NOTFOUND THEN
				INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CCRD0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
			END IF;
			-- Fechar o cursor
			CLOSE cr_craprdr;
			INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)VALUES ('OBTER_PARAMETROS_CARTAO', 'CCRD0011', 'pccracrd_obter_param_cartao', 'pr_cdcooper', vr_nrseqrdr);
			commit;
			dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
		exception
			when others then
			dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
			ROLLBACK;
		end;
	end;
	--#######################################################################################################################################
	--
	-- Criação de referência para nova tela PRMCRD
	--
	begin
	  declare 
		-- nome da rotina
		wk_rotina varchar2(200) := 'Criação de referência para nova tela PRMCRD';
		aux_rsprogra  VARCHAR2(50) := 'Parametros do cartao';
		aux_nmdatela  VARCHAR2(50) := 'CARCRD';
		aux_dsprogra  VARCHAR2(50) := 'Parametros do cartao';
		aux_cdopcoes  VARCHAR2(50) := '@,C';
		aux_dsopcoes  VARCHAR2(90) := 'ACESSO,CONSULTAR';
		aux_nmrotina  VARCHAR2(90) := 'PRMCRD';
		aux_nrmodulo  NUMBER       := 5;

		aux_nrordprg  NUMBER;

		-- Cursor para as cooperativas
		CURSOR cr_crapcop IS
		SELECT  *
		  FROM crapcop cop
		 WHERE cop.flgativo = 1;
		begin
			-- Percorrer as cooperativas do cursor
			FOR rw_crapcop IN cr_crapcop LOOP
				INSERT INTO craptel(cdcooper,nmdatela,cdopptel,lsopptel,tldatela,tlrestel,nrmodulo,inacesso,nrordrot,nrdnivel,idevento,idambtel,idsistem,nmrotina)
				VALUES (rw_crapcop.cdcooper,aux_nmdatela,aux_cdopcoes,aux_dsopcoes,aux_dsprogra,aux_rsprogra,aux_nrmodulo,0,1,1
				,0    /* 0 - na    , 1 - progrid, 2 - assemb */ 
				,2    /* 0 - todos , 1 - ayllos , 2 - web */
				,1    /* 1 - ayllos, 2 - progrid */ 
				,aux_nmrotina);  
			END LOOP;
			commit;
			dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
		exception
			when others then
			dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
			ROLLBACK;
		end;
	end;
	--#######################################################################################################################################
	--
	-- Criação de acessos a tela PRMCRD 
	--
	begin
	  declare 
		-- nome da rotina
		wk_rotina varchar2(200) := 'Criação de acessos a tela PRMCRD';
		CURSOR cr_crapcop IS
		SELECT cop.cdcooper
		  FROM crapcop cop
		 WHERE cop.flgativo = 1;

		CURSOR cr_crapope IS 
		SELECT ope.cdoperad, 
			   ope.cdcooper 
		  FROM crapope ope 
		 WHERE UPPER(ope.cdoperad) LIKE UPPER('f%')
		   AND ope.cdsitope = 1
		   AND ope.cdoperad NOT IN ('f0030519','f0030260','f0031839','f0030947','f0030641','f0032094');

		-- Vari�vel de cr�ticas
		vr_cdcritic      crapcri.cdcritic%TYPE;
		vr_dscritic      VARCHAR2(10000);
		vr_exc_saida     EXCEPTION;
		vr_qtdsuces      INTEGER := 0;
		vr_qtderror      INTEGER := 0;
		begin
			--Limpa registros
			DELETE FROM crapace ace WHERE ace.nmdatela = 'PRMCRD';
			FOR rw_crapcop IN cr_crapcop LOOP
				-- Opção '@'
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030519', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030260', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0031839', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030947', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0030641', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', '@', 'f0032094', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
				-- Opção 'C'
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030519', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030260', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0031839', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030947', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0030641', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'C', 'f0032094', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
				-- Opção 'A'
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030519', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030260', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0031839', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030947', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0030641', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);    
				INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE) values ('CARCRD', 'A', 'f0032094', 'PRMCRD', rw_crapcop.cdcooper, 1, 1, 2);    
			END LOOP;
			commit;
			dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
		exception
			when others then
			dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
			ROLLBACK;
		end;
	end;
	--#######################################################################################################################################
	--
	-- Criação de referência "CADA0011.pc_valida_endereco_ass"
	--
	begin
	  declare 
		-- nome da rotina
		wk_rotina varchar2(200) := 'Criação de referência "CADA0011.pc_valida_endereco_ass"';
		-- Buscar registro da RDR
		CURSOR cr_craprdr IS
			SELECT t.nrseqrdr
			  FROM craprdr t
			 WHERE t.NMPROGRA = 'CADA0011';
		-- Variaveis
		vr_nrseqrdr craprdr.nrseqrdr%TYPE;
		begin
			-- Buscar RDR
			OPEN  cr_craprdr;
			FETCH cr_craprdr INTO vr_nrseqrdr;
			-- Se nao encontrar
			IF cr_craprdr%NOTFOUND THEN
				INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CADA0011', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
			END IF;
			-- Fechar o cursor
			CLOSE cr_craprdr;
			INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)VALUES ('VALIDA_ENDERECO_ASS', 'CADA0011', 'pc_valida_endereco_ass', 'pr_cdcooper,pr_nrdconta', vr_nrseqrdr);
			commit;
			dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
		exception
			when others then
			dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
			ROLLBACK;
		end;
	end;
	--#######################################################################################################################################
	--
	-- Alteração de parâmetros na CRAPACA inserindo parâmetro pr_tipo_acao
	--
	begin
	  declare 
		-- nome da rotina
		wk_rotina varchar2(200) := 'Alteração de parâmetros na CRAPACA inserindo parâmetro pr_tipo_acao';
		begin
			-- incluir parametro para identificar o coordenador a assinar
			UPDATE CRAPACA SET LSTPARAM = LSTPARAM || ',pr_tipo_acao' WHERE NMDEACAO = 'INSERE_APROVADOR_CRD' AND NMPACKAG = 'TELA_ATENDA_CARTAOCREDITO';
			commit;
			dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
		exception
			when others then
			dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
			ROLLBACK;
		end;
	end;
	--#######################################################################################################################################
	--
	-- Alteração de parâmetros na CRAPACA inserindo parâmetro pr_flgestei
	--
	begin
	  declare 
		-- nome da rotina
		wk_rotina varchar2(200) := 'Alteração de parâmetros na CRAPACA inserindo parâmetro pr_flgestei';
		begin
			-- incluir parametro para identificar o coordenador a assinar
			UPDATE CRAPACA SET LSTPARAM = LSTPARAM || ',pr_flgestei' WHERE NMDEACAO = 'INSERE_APROVADOR_CRD' AND NMPACKAG = 'TELA_ATENDA_CARTAOCREDITO';
			commit;
			dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
		exception
			when others then
			dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
			ROLLBACK;
		end;
	end;
	--#######################################################################################################################################
	--
	-- Criação do parâmetro CRD_APROVACAO_CANAIS (tabela crapprm) 
	--
	begin
	  declare 
		-- nome da rotina
		wk_rotina varchar2(200) := 'Criação do parâmetro CRD_APROVACAO_CANAIS (tabela crapprm)';
		CURSOR cr_crapcop IS
		SELECT  *
		  FROM crapcop cop
		 WHERE cop.flgativo = 1;
		begin
			--Limpa registros
			DELETE FROM crapprm prm WHERE prm.cdacesso = 'CRD_APROVACAO_CANAIS';
			-- Percorrer as cooperativas do cursor
			FOR rw_crapcop IN cr_crapcop LOOP
				INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CRD_APROVACAO_CANAIS', 'Ativar/Desativar a autorização de solicitação de cartão de credito pelo cooperado por meio dos Canais. (o - desativada e 1 - ativada)', '0');
			END LOOP;
			commit;
			dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
		exception
			when others then
			dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
			ROLLBACK;
		end;
	end;
end;