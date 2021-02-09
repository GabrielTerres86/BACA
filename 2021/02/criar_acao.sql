declare 
  -- ALTERAR
  NOME_DA_ACAO VARCHAR2(40) := 'RODAR_PROCESSO';
  PROCEDURE_DA_ACAO VARCHAR2(100) := 'pc_rodar_diario_job';
  PACKAGE_DA_ACAO VARCHAR2(100) := 'UTIL_BATCH';
  PARAMETROS_DA_ACAO VARCHAR2(1000):= 'pr_cdcooper,pr_flgdscto,pr_flgemprt_pos,pr_flgemprt_pp,pr_flgemprt_tr,pr_flgcyber';
  -- FIM ALTERAR
							
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
  delete from crapaca where crapaca.nmdeacao = 'RODAR_PROCESSO';
  delete from crapaca where crapaca.nmdeacao = 'MUDAR_DATA';
  delete from craprdr where craprdr.nmprogra = PACKAGE_DA_ACAO;
  
  -- Mensageria
  OPEN cr_craprdr(pr_nmprogra => PACKAGE_DA_ACAO);
  FETCH cr_craprdr INTO rw_craprdr;
    
  -- Verifica se existe a tela do ayllos web
  IF cr_craprdr%NOTFOUND THEN
   
    -- Se não encontrar
    CLOSE cr_craprdr;

    -- Insere ação da tela do aylloas web
    INSERT INTO craprdr(nmprogra
                       ,dtsolici) 
                 values(PACKAGE_DA_ACAO
                       ,SYSDATE);
    -- Posiciona no registro criado
    OPEN cr_craprdr(pr_nmprogra => PACKAGE_DA_ACAO);
    FETCH cr_craprdr INTO rw_craprdr;

    dbms_output.put_line('Insere CRAPRDR -> '||PACKAGE_DA_ACAO||': ' || rw_craprdr.nrseqrdr);

  END IF;  
  
  -- Fecha o cursor
  CLOSE cr_craprdr;

  -- INICIO MENSAGERIA   
  
  OPEN cr_crapaca(pr_nmdeacao => NOME_DA_ACAO
                 ,pr_nmpackag => PACKAGE_DA_ACAO
                 ,pr_nmproced => PROCEDURE_DA_ACAO
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
                 VALUES(NOME_DA_ACAO,
                        PACKAGE_DA_ACAO,
                        PROCEDURE_DA_ACAO,
                        PARAMETROS_DA_ACAO,
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> '||NOME_DA_ACAO||' -> '||PACKAGE_DA_ACAO||'.'||PROCEDURE_DA_ACAO);
    
  END IF;
  
  CLOSE cr_crapaca;  
  
  -- Insere ação da tela do ayllos web
    INSERT INTO crapaca(nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                 VALUES('MUDAR_DATA',
                        'UTIL_BATCH',
                        'pc_muda_data_web',
                        'pr_cdcooper,pr_dtmvtolt',
                        rw_craprdr.nrseqrdr);
  
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
