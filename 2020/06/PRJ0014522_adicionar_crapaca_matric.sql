DECLARE
  
  vr_nrseqrdr   craprdr.nrseqrdr%TYPE;
  
BEGIN
  BEGIN
    SELECT t.nrseqrdr
      INTO vr_nrseqrdr
      FROM craprdr t
     WHERE t.nmprogra = 'MATRIC';
  EXCEPTION
    WHEN no_data_found THEN
      BEGIN
        INSERT INTO craprdr(nrseqrdr
                           ,nmprogra
                           ,dtsolici)
                     VALUES(craprdr_nrseqrdr.nextval
                           ,'MATRIC'
                           ,SYSDATE)
                 RETURNING nrseqrdr 
                      INTO vr_nrseqrdr;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20005, 'Erro ao inserir CRAPRDR: '||SQLERRM);
      END;
    WHEN OTHERS THEN
      raise_application_error(-20004, 'Erro ao buscar CRAPRDR: '||SQLERRM);
  END;
  
  BEGIN
    INSERT INTO crapaca(nrseqaca
                       ,nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr)
                VALUES ((SELECT NVL(MAX(a.nrseqaca),0)+1 FROM crapaca a)
                       ,'GRAVAR_PRE_CADASTRO'
                       ,NULL
                       ,'GravarPreCadastro'
                       ,'pr_cdcooper,pr_cdagenci,pr_cdoperad,pr_dsxmltel'
                       ,vr_nrseqrdr);
                
  EXCEPTION
    WHEN dup_val_on_index THEN
      dbms_output.put_line('Registro LIST_ORGAO_EMISSOR, já cadastrado.');
    WHEN OTHERS THEN
      raise_application_error(-20005, 'Erro ao inserir CRAPACA: '||SQLERRM);
  END;
  
  BEGIN
    INSERT INTO crapaca(nrseqaca
                       ,nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr)
                VALUES ((SELECT NVL(MAX(a.nrseqaca),0)+1 FROM crapaca a)
                       ,'BUSCA_NATURALIDADE_UF'
                       ,NULL
                       ,'listarNaturalidadeUF'
                       ,'pr_dsnaturalidade,pr_cdufnaturalidade,pr_nrregist,pr_nriniseq'
                       ,vr_nrseqrdr);
                
  EXCEPTION
    WHEN dup_val_on_index THEN
      dbms_output.put_line('Registro BUSCA_CIDADE_UF, já cadastrado.');
    WHEN OTHERS THEN
      raise_application_error(-20006, 'Erro ao inserir CRAPACA: '||SQLERRM);
  END;
  
  
  BEGIN
    INSERT INTO crapaca(nrseqaca
                       ,nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr)
                VALUES ((SELECT NVL(MAX(a.nrseqaca),0)+1 FROM crapaca a)
                       ,'BUSCA_EMPREGADOR'
                       ,NULL
                       ,'listarEmpregador'
                       ,'pr_nrdocnpj,pr_cdempres,pr_nmextemp,pr_nrregist,pr_nriniseq'
                       ,vr_nrseqrdr);
  EXCEPTION
    WHEN dup_val_on_index THEN
      dbms_output.put_line('Registro BUSCA_EMPREGADOR, já cadastrado.');
    WHEN OTHERS THEN
      raise_application_error(-20017, 'Erro ao inserir CRAPACA: '||SQLERRM);
  END;
  
  BEGIN
    INSERT INTO crapaca(nrseqaca
                       ,nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr)
                VALUES ((SELECT NVL(MAX(a.nrseqaca),0)+1 FROM crapaca a)
                       ,'ADMITIR_COOPERADO'
                       ,NULL
                       ,'admitirCooperado'
                       ,'pr_idprecadastro'
                       ,vr_nrseqrdr);
  EXCEPTION
    WHEN dup_val_on_index THEN
      dbms_output.put_line('Registro BUSCA_EMPREGADOR, já cadastrado.');
    WHEN OTHERS THEN
      raise_application_error(-20017, 'Erro ao inserir CRAPACA: '||SQLERRM);
  END;
    
  BEGIN
    SELECT t.nrseqrdr
      INTO vr_nrseqrdr
      FROM craprdr t
     WHERE t.nmprogra = 'GENE0010';
  EXCEPTION
    WHEN no_data_found THEN
      BEGIN
        INSERT INTO craprdr(nrseqrdr
                           ,nmprogra
                           ,dtsolici)
                     VALUES(craprdr_nrseqrdr.nextval
                           ,'GENE0010'
                           ,SYSDATE)
                 RETURNING nrseqrdr 
                      INTO vr_nrseqrdr;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20005, 'Erro ao inserir CRAPRDR: '||SQLERRM);
      END;
    WHEN OTHERS THEN
      raise_application_error(-20004, 'Erro ao buscar CRAPRDR: '||SQLERRM);
  END;
  
  BEGIN
    INSERT INTO crapaca(nrseqaca
                       ,nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr)
                VALUES ((SELECT NVL(MAX(a.nrseqaca),0)+1 FROM crapaca a)
                       ,'BUSCA_DOMINIOS_GENERICO'
                       ,'GENE0010'
                       ,'pc_dominios_generico'
                       ,'pr_dscolcod,pr_dscoldes,pr_nmtabela,pr_dsfiltro'
                       ,vr_nrseqrdr);
  EXCEPTION
    WHEN dup_val_on_index THEN
      dbms_output.put_line('Registro BUSCA_DOMINIOS_GENERICO, já cadastrado.');
    WHEN OTHERS THEN
      raise_application_error(-20016, 'Erro ao inserir CRAPACA: '||SQLERRM);
  END;
  
  COMMIT;
 
END;
