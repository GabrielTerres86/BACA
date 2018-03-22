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
  OPEN cr_craprdr(pr_nmprogra => 'ZOOM0001');
  FETCH cr_craprdr INTO rw_craprdr;
    
  -- Verifica se existe a tela do ayllos web
  IF cr_craprdr%NOTFOUND THEN
   
    -- Se não encontrar
    CLOSE cr_craprdr;

    -- Insere ação da tela do aylloas web
    INSERT INTO craprdr(nmprogra
                       ,dtsolici) 
                 values('ZOOM0001'
                       ,SYSDATE);
    -- Posiciona no registro criado
    OPEN cr_craprdr(pr_nmprogra => 'ZOOM0001');
    FETCH cr_craprdr INTO rw_craprdr;

    dbms_output.put_line('Insere CRAPRDR -> ZOOM0001: ' || rw_craprdr.nrseqrdr);

  END IF;  
  
  -- Fecha o cursor
  CLOSE cr_craprdr;

  -- INICIO MENSAGERIA   
  
  -- TELA_ATENDA_PRESTACOES - ACAO CONSULTAR
  OPEN cr_crapaca(pr_nmdeacao => 'CONSULTAR_CCL_LIMITE'
                 ,pr_nmpackag => 'ZOOM0001'
                 ,pr_nmproced => 'pc_consultar_ccl_limite'
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
                 VALUES('CONSULTAR_CCL_LIMITE',
                        'ZOOM0001',
                        'pc_consultar_ccl_limite',
                        'pr_cdcooper, pr_nrdconta, pr_nrctrlim',
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> CONSULTAR_CONTROLE -> ZOOM0001.pc_consultar_ccl_limite');
    
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