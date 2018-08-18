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
  OPEN cr_craprdr(pr_nmprogra => 'PREJ0003');
  FETCH cr_craprdr INTO rw_craprdr;
    
  -- Verifica se existe a tela do ayllos web
  IF cr_craprdr%NOTFOUND THEN
   
    -- Se n�o encontrar
    CLOSE cr_craprdr;

    -- Insere a��o da tela do aylloas web
    INSERT INTO craprdr(nmprogra
                       ,dtsolici) 
                 values('PREJ0003'
                       ,SYSDATE);
    -- Posiciona no registro criado
    OPEN cr_craprdr(pr_nmprogra => 'PREJ0003');
    FETCH cr_craprdr INTO rw_craprdr;

    dbms_output.put_line('Insere CRAPRDR -> PREJ0003: ' || rw_craprdr.nrseqrdr);

  END IF;  
  
  -- Fecha o cursor
  CLOSE cr_craprdr;

  -- INICIO MENSAGERIA   
  
  -- TELA_ATENDA_PRESTACOES - ACAO CONSULTAR
  OPEN cr_crapaca(pr_nmdeacao => 'CONSULTAR_SLDPRJ'
                 ,pr_nmpackag => 'PREJ0003'
                 ,pr_nmproced => 'pc_consulta_sld_cta_prj'
                 ,pr_nrseqrdr => rw_craprdr.nrseqrdr);
                   
  FETCH cr_crapaca INTO rw_crapaca;
    
  -- Verifica se existe a a��o tela do ayllos web
  IF cr_crapaca%NOTFOUND THEN
    
    -- Insere a��o da tela do ayllos web
    INSERT INTO crapaca(nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                 VALUES('CONSULTAR_SLDPRJ',
                        'PREJ0003',
                        'pc_consulta_sld_cta_prj',
                        'pr_cdcooper, pr_nrdconta',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> CONSULTAR_SLDPRJ -> PREJ0003.pc_consulta_sld_cta_prj');
    
  END IF;
  
  CLOSE cr_crapaca; 
  
  -- INICIO MENSAGERIA 
  -- TELA_ATENDA_PRESTACOES - ACAO GERA_LCM
  OPEN cr_crapaca(pr_nmdeacao => 'GERA_LCM'
                 ,pr_nmpackag => 'PREJ0003'
                 ,pr_nmproced => 'pc_gera_lcm_cta_prj'
                 ,pr_nrseqrdr => rw_craprdr.nrseqrdr);
                   
  FETCH cr_crapaca INTO rw_crapaca;
    
  -- Verifica se existe a a��o tela do ayllos web
  IF cr_crapaca%NOTFOUND THEN
    
    -- Insere a��o da tela do ayllos web
    INSERT INTO crapaca(nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                 VALUES('GERA_LCM',
                        'PREJ0003',
                        'pc_gera_lcm_cta_prj',
                        'pr_cdcooper, pr_nrdconta, pr_cdoperad, pr_vlrlanc',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> GERA_LCM -> PREJ0003.pc_gera_lcm_cta_prj');
    
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