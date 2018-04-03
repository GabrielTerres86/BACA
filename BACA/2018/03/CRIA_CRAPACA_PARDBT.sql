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
  OPEN cr_craprdr(pr_nmprogra => 'DEBITADOR_UNICO');
  FETCH cr_craprdr INTO rw_craprdr;
    
  -- Verifica se existe a tela do ayllos web
  IF cr_craprdr%NOTFOUND THEN
   
    -- Se não encontrar
    CLOSE cr_craprdr;

    -- Insere ação da tela do aylloas web
    INSERT INTO craprdr(nmprogra
                       ,dtsolici) 
                 values('DEBITADOR_UNICO'
                       ,SYSDATE);
    -- Posiciona no registro criado
    OPEN cr_craprdr(pr_nmprogra => 'DEBITADOR_UNICO');
    FETCH cr_craprdr INTO rw_craprdr;

    dbms_output.put_line('Insere CRAPRDR -> DEBITADOR_UNICO: ' || rw_craprdr.nrseqrdr);

  END IF;  
  
  -- Fecha o cursor
  CLOSE cr_craprdr;

  -- INICIO MENSAGERIA   
  
  -- TELA_PARDBT - ACAO BUSCAR HORÁRIOS CADASTRADOS
  OPEN cr_crapaca(pr_nmdeacao => 'DEBITADOR_HR_CONSULTAR'
                 ,pr_nmpackag => 'TELA_DEBITADOR_UNICO'
                 ,pr_nmproced => 'pc_busca_debitador_horarios'
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
                 VALUES('DEBITADOR_HR_CONSULTAR',
                        'TELA_DEBITADOR_UNICO',
                        'pc_busca_debitador_horarios',
                        '',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> DEBITADOR_HR_CONSULTAR -> TELA_DEBITADOR_UNICO.pc_busca_debitador_horarios');
    
  END IF;
  
  CLOSE cr_crapaca;  

  -- TELA_PARDBT - ACAO ALTERAR HORÁRIOS CADASTRADOS
  OPEN cr_crapaca(pr_nmdeacao => 'DEBITADOR_HR_ALTERAR'
                 ,pr_nmpackag => 'TELA_DEBITADOR_UNICO'
                 ,pr_nmproced => 'pc_altera_debitador_horarios'
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
                 VALUES('DEBITADOR_HR_ALTERAR',
                        'TELA_DEBITADOR_UNICO',
                        'pc_altera_debitador_horarios',
                        'pr_idhora_processamento, pr_dhprocessamento',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> DEBITADOR_HR_ALTERAR -> TELA_DEBITADOR_UNICO.pc_altera_debitador_horarios');
    
  END IF;
  
  CLOSE cr_crapaca;

  -- TELA_PARDBT - ACAO INCLUIR HORÁRIOS CADASTRADOS
  OPEN cr_crapaca(pr_nmdeacao => 'DEBITADOR_HR_INCLUIR'
                 ,pr_nmpackag => 'TELA_DEBITADOR_UNICO'
                 ,pr_nmproced => 'pc_inclui_debitador_horarios'
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
                 VALUES('DEBITADOR_HR_INCLUIR',
                        'TELA_DEBITADOR_UNICO',
                        'pc_inclui_debitador_horarios',
                        'pr_dhprocessamento',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> DEBITADOR_HR_INCLUIR -> TELA_DEBITADOR_UNICO.pc_inclui_debitador_horarios');
    
  END IF;
  
  CLOSE cr_crapaca;

  -- TELA_PARDBT - ACAO EXCLUIR HORÁRIOS CADASTRADOS
  OPEN cr_crapaca(pr_nmdeacao => 'DEBITADOR_HR_EXCLUIR'
                 ,pr_nmpackag => 'TELA_DEBITADOR_UNICO'
                 ,pr_nmproced => 'pc_exclui_debitador_horarios'
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
                 VALUES('DEBITADOR_HR_EXCLUIR',
                        'TELA_DEBITADOR_UNICO',
                        'pc_exclui_debitador_horarios',
                        'pr_idhora_processamento',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> DEBITADOR_HR_EXCLUIR -> TELA_DEBITADOR_UNICO.pc_exclui_debitador_horarios');
    
  END IF;
  
  CLOSE cr_crapaca;

   -- TELA_PARDBT - ACAO BUSCAR HISTÓRICOS DE OPERAÇÕES
  OPEN cr_crapaca(pr_nmdeacao => 'DEBITADOR_HIST_CONSULTAR'
                 ,pr_nmpackag => 'TELA_DEBITADOR_UNICO'
                 ,pr_nmproced => 'pc_busca_debitador_hist'
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
                 VALUES('DEBITADOR_HIST_CONSULTAR',
                        'TELA_DEBITADOR_UNICO',
                        'pc_busca_debitador_hist',
                        'pr_tporigem',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> DEBITADOR_HIST_CONSULTAR -> TELA_DEBITADOR_UNICO.pc_busca_debitador_hist');
    
  END IF;
  
  CLOSE cr_crapaca;

   -- TELA_PARDBT - ACAO CONSULTAR DADOS RESUMIDOS DAS PRIORIDADES
  OPEN cr_crapaca(pr_nmdeacao => 'DEBITADOR_PR_RES_CONSULTAR'
                 ,pr_nmpackag => 'TELA_DEBITADOR_UNICO'
                 ,pr_nmproced => 'pc_busca_debitador_priori_res'
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
                 VALUES('DEBITADOR_PR_RES_CONSULTAR',
                        'TELA_DEBITADOR_UNICO',
                        'pc_busca_debitador_priori_res',
                        '',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> DEBITADOR_PR_RES_CONSULTAR -> TELA_DEBITADOR_UNICO.pc_busca_debitador_priori_res');
    
  END IF;
  
  CLOSE cr_crapaca;

   -- TELA_PARDBT - ACAO EXECUTAR EXECUÇÃO EMERGENCIAL
  OPEN cr_crapaca(pr_nmdeacao => 'DEBITADOR_EM_EXECUTAR'
                 ,pr_nmpackag => 'TELA_DEBITADOR_UNICO'
                 ,pr_nmproced => 'pc_executar_debitador_emergen'
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
                 VALUES('DEBITADOR_EM_EXECUTAR',
                        'TELA_DEBITADOR_UNICO',
                        'pc_executar_debitador_emergen',
                        'pr_processos',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> DEBITADOR_EM_EXECUTAR -> TELA_DEBITADOR_UNICO.pc_executar_debitador_emergen');
    
  END IF;
  
  CLOSE cr_crapaca;


   -- TELA_PARDBT - ACAO CONSULTAR DADOS COMPLETOS DAS PRIORIDADES
  OPEN cr_crapaca(pr_nmdeacao => 'DEBITADOR_PR_COMP_CONSULTAR'
                 ,pr_nmpackag => 'TELA_DEBITADOR_UNICO'
                 ,pr_nmproced => 'pc_busca_debitador_priori_comp'
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
                 VALUES('DEBITADOR_PR_COMP_CONSULTAR',
                        'TELA_DEBITADOR_UNICO',
                        'pc_busca_debitador_priori_comp',
                        '',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> DEBITADOR_PR_COMP_CONSULTAR -> TELA_DEBITADOR_UNICO.pc_busca_debitador_priori_comp');
    
  END IF;
  
  CLOSE cr_crapaca;

    -- TELA_PARDBT - ACAO REDEFINIR PRIORIDADE DE UM PROCESSO
  OPEN cr_crapaca(pr_nmdeacao => 'DEBITADOR_PR_REDEF_PRIORIDADE'
                 ,pr_nmpackag => 'TELA_DEBITADOR_UNICO'
                 ,pr_nmproced => 'pc_redefine_debitador_priori'
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
                 VALUES('DEBITADOR_PR_REDEF_PRIORIDADE',
                        'TELA_DEBITADOR_UNICO',
                        'pc_redefine_debitador_priori',
                        'pr_nrprioridade, pr_cdprocesso',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> DEBITADOR_PR_REDEF_PRIORIDADE -> TELA_DEBITADOR_UNICO.pc_redefine_debitador_priori');
    
  END IF;
  
  CLOSE cr_crapaca;

    -- TELA_PARDBT - ACAO ATIVAR PROCESSO
  OPEN cr_crapaca(pr_nmdeacao => 'DEBITADOR_PR_ATIVAR'
                 ,pr_nmpackag => 'TELA_DEBITADOR_UNICO'
                 ,pr_nmproced => 'pc_ativa_debitador_processo'
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
                 VALUES('DEBITADOR_PR_ATIVAR',
                        'TELA_DEBITADOR_UNICO',
                        'pc_ativa_debitador_processo',
                        'pr_cdprocesso, pr_horarios',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> DEBITADOR_PR_ATIVAR -> TELA_DEBITADOR_UNICO.pc_ativa_debitador_processo');
    
  END IF;
  
  CLOSE cr_crapaca;

   -- TELA_PARDBT - INCLUIR HORÁRIO DE EXECUÇÃO DO PROCESSO
  OPEN cr_crapaca(pr_nmdeacao => 'DEBITADOR_PR_INC_HORARIO'
                 ,pr_nmpackag => 'TELA_DEBITADOR_UNICO'
                 ,pr_nmproced => 'pc_inclui_debitador_hr_proces'
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
                 VALUES('DEBITADOR_PR_INC_HORARIO',
                        'TELA_DEBITADOR_UNICO',
                        'pc_inclui_debitador_hr_proces',
                        'pr_cdprocesso, pr_idhora_processamento',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> DEBITADOR_PR_INC_HORARIO -> TELA_DEBITADOR_UNICO.pc_inclui_debitador_hr_proces');
    
  END IF;
  
  CLOSE cr_crapaca;

   -- TELA_PARDBT - EXCLUIR HORÁRIO DE EXECUÇÃO DO PROCESSO
  OPEN cr_crapaca(pr_nmdeacao => 'DEBITADOR_PR_EXC_HORARIO'
                 ,pr_nmpackag => 'TELA_DEBITADOR_UNICO'
                 ,pr_nmproced => 'pc_exclui_debitador_hr_proces'
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
                 VALUES('DEBITADOR_PR_EXC_HORARIO',
                        'TELA_DEBITADOR_UNICO',
                        'pc_exclui_debitador_hr_proces',
                        'pr_cdprocesso, pr_idhora_processamento',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> DEBITADOR_PR_EXC_HORARIO -> TELA_DEBITADOR_UNICO.pc_exclui_debitador_hr_proces');
    
  END IF;
  
  CLOSE cr_crapaca;

   -- TELA_PARDBT - ACAO DESATIVAR PROCESSO
  OPEN cr_crapaca(pr_nmdeacao => 'DEBITADOR_PR_DESATIVAR'
                 ,pr_nmpackag => 'TELA_DEBITADOR_UNICO'
                 ,pr_nmproced => 'pc_desativa_debitador_processo'
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
                 VALUES('DEBITADOR_PR_DESATIVAR',
                        'TELA_DEBITADOR_UNICO',
                        'pc_desativa_debitador_processo',
                        'pr_cdprocesso',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> DEBITADOR_PR_DESATIVAR -> TELA_DEBITADOR_UNICO.pc_desativa_debitador_processo');
    
  END IF;
  
  CLOSE cr_crapaca;

    -- TELA_PARDBT - ACAO BUSCA HORÁRIOS NÃO CADASTRADOS PARA UM PROCESSO
  OPEN cr_crapaca(pr_nmdeacao => 'DEBITADOR_PR_BUSCA_HOR'
                 ,pr_nmpackag => 'TELA_DEBITADOR_UNICO'
                 ,pr_nmproced => 'pc_busca_debitador_hr_proces'
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
                 VALUES('DEBITADOR_PR_BUSCA_HOR',
                        'TELA_DEBITADOR_UNICO',
                        'pc_busca_debitador_hr_proces',
                        'pr_cdprocesso',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> DEBITADOR_PR_BUSCA_HOR -> TELA_DEBITADOR_UNICO.pc_busca_debitador_hr_proces');
    
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