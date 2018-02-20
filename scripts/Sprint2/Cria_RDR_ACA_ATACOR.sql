declare 

  CURSOR cr_craprdr(pr_nmprogra IN craprdr.nmprogra%TYPE) IS
  SELECT * FROM craprdr
   WHERE craprdr.nmprogra = pr_nmprogra;
  rw_craprdr cr_craprdr%ROWTYPE;

  CURSOR cr_crapaca(pr_nmdeacao IN crapaca.nmdeacao%TYPE
                   ,pr_nmpackag IN crapaca.nmpackag%TYPE
                   ,pr_nmproced IN crapaca.nmproced%TYPE
                   ,pr_nrseqrdr IN crapaca.nrseqrdr%TYPE) IS
  SELECT * FROM crapaca
   WHERE UPPER(crapaca.nmdeacao) = UPPER(pr_nmdeacao)
     AND UPPER(crapaca.nmpackag) = UPPER(pr_nmpackag)
     AND UPPER(crapaca.nmproced) = UPPER(pr_nmproced)
     AND crapaca.nrseqrdr = pr_nrseqrdr;
  rw_crapaca cr_crapaca%ROWTYPE;
  
  vr_exec_erro EXCEPTION;
  vr_dscritic  VARCHAR2(1000);  

begin
  
  dbms_output.put_line('Inicio do programa');
  
  -- Mensageria
  OPEN cr_craprdr(pr_nmprogra => 'TELA_ATACOR');
  FETCH cr_craprdr INTO rw_craprdr;
    
  -- Verifica se existe a tela do ayllos web
  IF cr_craprdr%NOTFOUND THEN
   
    -- Se não encontrar
    CLOSE cr_craprdr;

    -- Insere ação da tela do aylloas web
    INSERT INTO craprdr(nmprogra
                       ,dtsolici) 
                 values('TELA_ATACOR'
                       ,SYSDATE);
    -- Posiciona no registro criado
    OPEN cr_craprdr(pr_nmprogra => 'TELA_ATACOR');
    FETCH cr_craprdr INTO rw_craprdr;

    dbms_output.put_line('Insere CRAPRDR -> TELA_ATACOR: ' || rw_craprdr.nrseqrdr);

  END IF;  
  
  -- Fecha o cursor
  CLOSE cr_craprdr;

  -- INICIO MENSAGERIA   
  
  -- TELA_ATENDA_OCORRENCIAS - ACAO BUSCAR CONTRATOS LC100
  OPEN cr_crapaca(pr_nmdeacao => 'BUSCA_CONTRATOS_LC100'
                 ,pr_nmpackag => 'TELA_ATACOR'
                 ,pr_nmproced => 'pc_busca_contratos_lc100'
                 ,pr_nrseqrdr => rw_craprdr.nrseqrdr);
                   
  FETCH cr_crapaca INTO rw_crapaca;
    
  -- Verifica se existe a ação tela do ayllos web
  IF cr_crapaca%NOTFOUND THEN
    
    -- Insere ação da tela do ayllos web
    INSERT INTO crapaca(nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                 VALUES('BUSCA_CONTRATOS_LC100',
                        'TELA_ATACOR',
                        'pc_busca_contratos_lc100',
                        'pr_nracordo, pr_cdcooper',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> BUSCA_CONTRATOS_LC100 -> TELA_ATACOR.pc_busca_contratos_lc100');
    
  END IF;
  
  CLOSE cr_crapaca;  

  -- TELA_ATENDA_OCORRENCIAS - ACAO VALIDA CONTRATO LC100
  OPEN cr_crapaca(pr_nmdeacao => 'VALIDA_CONTRATO_LC100'
                 ,pr_nmpackag => 'TELA_ATACOR'
                 ,pr_nmproced => 'pc_valida_contrato_lc100'
                 ,pr_nrseqrdr => rw_craprdr.nrseqrdr);
                   
  FETCH cr_crapaca INTO rw_crapaca;
    
  -- Verifica se existe a ação tela do ayllos web
  IF cr_crapaca%NOTFOUND THEN
    
    -- Insere ação da tela do ayllos web
    INSERT INTO crapaca(nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                 VALUES('VALIDA_CONTRATO_LC100',
                        'TELA_ATACOR',
                        'pc_valida_contrato_lc100',
                        'pr_nracordo, pr_nrctremp, pr_cdcooper',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> VALIDA_CONTRATO_LC100 -> TELA_ATACOR.pc_valida_contrato_lc100');
    
  END IF;
  
  CLOSE cr_crapaca;

  -- TELA_ATENDA_OCORRENCIAS - ACAO BUSCA CONTRATOS DO ACORDO
  OPEN cr_crapaca(pr_nmdeacao => 'BUSCA_CONTRATOS_ACORDO'
                 ,pr_nmpackag => 'TELA_ATACOR'
                 ,pr_nmproced => 'pc_busca_contratos_acordo'
                 ,pr_nrseqrdr => rw_craprdr.nrseqrdr);
                   
  FETCH cr_crapaca INTO rw_crapaca;
    
  -- Verifica se existe a ação tela do ayllos web
  IF cr_crapaca%NOTFOUND THEN
    
    -- Insere ação da tela do ayllos web
    INSERT INTO crapaca(nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                 VALUES('BUSCA_CONTRATOS_ACORDO',
                        'TELA_ATACOR',
                        'pc_busca_contratos_acordo',
                        'pr_nracordo, pr_cdcooper',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> BUSCA_CONTRATOS_ACORDO -> TELA_ATACOR.pc_busca_contratos_acordo');
    
  END IF;
  
  CLOSE cr_crapaca;

  -- TELA_ATENDA_OCORRENCIAS - INCLUSÃO DE CONTRATO NO ACORDO
  OPEN cr_crapaca(pr_nmdeacao => 'INCLUI_CONTRATO_ACORDO'
                 ,pr_nmpackag => 'TELA_ATACOR'
                 ,pr_nmproced => 'pc_inclui_contrato_acordo'
                 ,pr_nrseqrdr => rw_craprdr.nrseqrdr);
                   
  FETCH cr_crapaca INTO rw_crapaca;
    
  -- Verifica se existe a ação tela do ayllos web
  IF cr_crapaca%NOTFOUND THEN
    
    -- Insere ação da tela do ayllos web
    INSERT INTO crapaca(nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                 VALUES('INCLUI_CONTRATO_ACORDO',
                        'TELA_ATACOR',
                        'pc_inclui_contrato_acordo',
                        'pr_nracordo, pr_nrctremp',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> INCLUI_CONTRATO_ACORDO -> TELA_ATACOR.pc_inclui_contrato_acordo');
    
  END IF;
  
  CLOSE cr_crapaca;

  -- TELA_ATENDA_OCORRENCIAS - ATUALIZAÇÃO DE CONTRATO NO ACORDO
  OPEN cr_crapaca(pr_nmdeacao => 'ATUALIZA_CONTRATO_ACORDO'
                 ,pr_nmpackag => 'TELA_ATACOR'
                 ,pr_nmproced => 'pc_atualiza_contrato_acordo'
                 ,pr_nrseqrdr => rw_craprdr.nrseqrdr);
                   
  FETCH cr_crapaca INTO rw_crapaca;
    
  -- Verifica se existe a ação tela do ayllos web
  IF cr_crapaca%NOTFOUND THEN
    
    -- Insere ação da tela do ayllos web
    INSERT INTO crapaca(nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                 VALUES('ATUALIZA_CONTRATO_ACORDO',
                        'TELA_ATACOR',
                        'pc_atualiza_contrato_acordo',
                        'pr_nracordo, pr_nrctremp, pr_indpagar',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> ATUALIZA_CONTRATO_ACORDO -> TELA_ATACOR.pc_atualiza_contrato_acordo');
    
  END IF;
  
  CLOSE cr_crapaca;

  -- TELA_ATENDA_OCORRENCIAS - REMOÇÃO DE CONTRATO DO ACORDO
  OPEN cr_crapaca(pr_nmdeacao => 'EXCLUI_CONTRATO_ACORDO'
                 ,pr_nmpackag => 'TELA_ATACOR'
                 ,pr_nmproced => 'pc_exclui_contrato_acordo'
                 ,pr_nrseqrdr => rw_craprdr.nrseqrdr);
                   
  FETCH cr_crapaca INTO rw_crapaca;
    
  -- Verifica se existe a ação tela do ayllos web
  IF cr_crapaca%NOTFOUND THEN
    
    -- Insere ação da tela do ayllos web
    INSERT INTO crapaca(nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                 VALUES('EXCLUI_CONTRATO_ACORDO',
                        'TELA_ATACOR',
                        'pc_exclui_contrato_acordo',
                        'pr_nracordo, pr_nrctremp',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> EXCLUI_CONTRATO_ACORDO -> TELA_ATACOR.pc_exclui_contrato_acordo');
    
  END IF;
  
  CLOSE cr_crapaca;
  
  dbms_output.put_line('Fim do programa');
   
  COMMIT;
  
EXCEPTION 
  WHEN vr_exec_erro THEN
    
    dbms_output.put_line('Erro:' || vr_dscritic);
    ROLLBACK;
   
  WHEN OTHERS THEN
        
    dbms_output.put_line('Erro a executar o programa:' || SQLERRM);

    ROLLBACK;
    
end;