-- noinspection SqlNoDataSourceInspectionForFile


/******************************************************************************************************** 
  Baca para criar tela PREJU referente a Melhoria 324
  que tem como objetivo consultar, forçar o envio para prejuizo e estornar os registros encaminhados para prejuízo
  -----------------
   Autor: Jean Calão (Mout´S)                                 Data: 27/05/2017
  -----------------
*********************************************************************************************************/

DECLARE
  vr_nmdatela craptel.nmdatela%TYPE;
  vr_dsprogra crapprg.dsprogra##1%TYPE;
  vr_rsprogra craptel.tlrestel%TYPE;
  vr_cdopcoes craptel.cdopptel%TYPE;
  vr_dsopcoes craptel.lsopptel%TYPE;
  
  vr_nrordprg INTEGER;
  
  CURSOR cr_crapprg_exist(pr_nrordprg IN crapprg.nrordprg%TYPE) IS
    SELECT * FROM crapprg
     WHERE crapprg.nrsolici = 50
       AND crapprg.nrordprg = pr_nrordprg;
  rw_crapprg_exist cr_crapprg_exist%ROWTYPE; 

  CURSOR cr_craptel_exist(pr_cdcooper IN craptel.cdcooper%TYPE
                         ,pr_nmdatela IN craptel.nmdatela%TYPE) IS
    SELECT * FROM craptel
     WHERE craptel.cdcooper = pr_cdcooper
       AND craptel.nmdatela = pr_nmdatela
       AND (craptel.nmrotina IS NULL 
         OR craptel.nmrotina = ' ');
  rw_craptel_exist cr_craptel_exist%ROWTYPE; 
  
  CURSOR cr_crapprg_exist2(pr_cdcooper IN crapprg.cdcooper%TYPE
                          ,pr_nmdatela IN crapprg.cdprogra%TYPE
                          ,pr_nrordprg IN crapprg.nrordprg%TYPE) IS
    SELECT * FROM crapprg
     WHERE crapprg.cdcooper = pr_cdcooper
       AND ((    crapprg.cdprogra = pr_nmdatela
             AND crapprg.nmsistem = 'CRED') OR
            (    crapprg.nrsolici = 50
             AND crapprg.nrordprg = pr_nrordprg)) ;
  
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
  
  -- A tela deverá ser criada apenas para cooperativa 3
  CURSOR cr_crapcop IS
    SELECT * FROM crapcop p WHERE p.cdcooper = 3; --p.flgativo = 1 and
  
BEGIN
  -- Informações da Tela
  vr_nmdatela:= 'IMPSIM';
  vr_dsprogra:= 'Importação cadastros cooperados Simples Nacional';
  vr_rsprogra:= 'CON. IMP. EXP.';
  vr_cdopcoes:= '@,I,E';
  vr_dsopcoes:= 'CONSULTA,IMPORTAR,EXPORTAR';
  
  vr_nrordprg:= 1;
  /* vai verificar qual nrordprg esta disponivel */
  WHILE TRUE LOOP
    OPEN cr_crapprg_exist(pr_nrordprg => vr_nrordprg);
    
    FETCH cr_crapprg_exist
      INTO rw_crapprg_exist;
    
    IF cr_crapprg_exist%NOTFOUND THEN
      CLOSE cr_crapprg_exist;
      EXIT;
    END IF;  
    
    CLOSE cr_crapprg_exist;
    vr_nrordprg := vr_nrordprg + 1;
  END LOOP;

  dbms_output.put_line('Ordem do Programa: ' || vr_nrordprg);

  FOR rw_crapcop IN cr_crapcop LOOP
--    dbms_output.put_line('LOOP - Cooperativa : ' || rw_crapcop.cdcooper);
      
    -- Verifica se a crapprg existe
    OPEN cr_crapprg_exist2(pr_cdcooper => rw_crapcop.cdcooper
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrordprg => vr_nrordprg);
    FETCH cr_crapprg_exist2
      INTO rw_crapprg_exist;
    
    IF cr_crapprg_exist2%NOTFOUND THEN
      dbms_output.put_line('Programa Criado! Coop: ' || rw_crapcop.cdcooper);
      /* inctrprg = nao executado */
      /* inlibprg = liberado */
      INSERT INTO crapprg (           cdcooper,   cdprogra,       dsprogra##1,inctrprg,inlibprg,nmsistem,   nrordprg,nrsolici)
                   VALUES (rw_crapcop.cdcooper,vr_nmdatela,upper(vr_dsprogra),       1,       1,  'CRED',vr_nrordprg,      50);
    END IF;
    CLOSE cr_crapprg_exist2;

    -- Verifica se a craptel existe
    OPEN cr_craptel_exist(pr_cdcooper => rw_crapcop.cdcooper
                         ,pr_nmdatela => vr_nmdatela);
    FETCH cr_craptel_exist
      INTO rw_craptel_exist;
    
    IF cr_craptel_exist%NOTFOUND THEN
      dbms_output.put_line('Tela Criada! Coop: ' || rw_crapcop.cdcooper);
      /* idevento = 0 - na    , 1 - progrid, 2 - assemb */ 
      /* idambtel = 0 - todos , 1 - ayllos , 2 - web */
      /* idsistem = 1 - ayllos, 2 - progrid */
      INSERT INTO craptel (           cdcooper,   nmdatela,   cdopptel,   lsopptel,         tldatela,   tlrestel,nrmodulo,inacesso,nrordrot,nrdnivel,idevento,idambtel,idsistem)
                   VALUES (rw_crapcop.cdcooper,vr_nmdatela,vr_cdopcoes,vr_dsopcoes,upper(vr_dsprogra),vr_rsprogra,       6,       1,       1,       1,       0,       2,       1);
    END IF;
    CLOSE cr_craptel_exist;

  END LOOP; 

  -- Mensageria
  OPEN cr_craprdr(pr_nmprogra => vr_nmdatela);
  FETCH cr_craprdr
    INTO rw_craprdr;
  
  -- Verifica se existe a tela do ayllos web
  IF cr_craprdr%NOTFOUND THEN
    -- Se não encontrar
    CLOSE cr_craprdr;

    dbms_output.put_line('Insere CRAPRDR -> ' || vr_nmdatela);

    -- Insere tela do ayllos web
    INSERT INTO craprdr(nmprogra, dtsolici) VALUES(vr_nmdatela,  SYSDATE);
    -- Busca o registro que acabou de ser inserido            
    OPEN cr_craprdr(pr_nmprogra => vr_nmdatela);
    FETCH cr_craprdr
      INTO rw_craprdr;
  END IF;  

  -- Fecha o cursor
  CLOSE cr_craprdr;
----------------------------------------------------------------------------------------------------------------------------------------
   
   -- AÇÃO DA MENSAGERIA
  OPEN cr_crapaca(pr_nmdeacao => 'IMPSIM_IMPORTA_ARQUIVO'
                 ,pr_nmpackag => 'TELA_IMPSIM'
                 ,pr_nmproced => 'pc_importar_arquivo_SIM'
                 ,pr_nrseqrdr => rw_craprdr.nrseqrdr);
  FETCH cr_crapaca
    INTO rw_crapaca;
  -- Verifica se existe a ação tela do ayllos web
  IF cr_crapaca%NOTFOUND THEN
    
    dbms_output.put_line('Insere CRAPACA -> TELA_IMPSIM -> TELA_IMPSIM.pc_importar_arquivo_SIM');
    
    -- Insere ação da tela do ayllos web
    INSERT INTO crapaca(nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                 VALUES('IMPSIM_IMPORTA_ARQUIVO',
                        'TELA_IMPSIM',
                        'pc_importar_arquivo_SIM',
                        'pr_arquivo ',
                        rw_craprdr.nrseqrdr);
  END IF;  
  close cr_crapaca;
  
  -- AÇÃO DA MENSAGERIA
  OPEN cr_crapaca(pr_nmdeacao => 'IMPSIM_EXPORTA_ARQUIVO'
                 ,pr_nmpackag => 'TELA_IMPSIM'
                 ,pr_nmproced => 'pc_exportar_arquivo_SIM'
                 ,pr_nrseqrdr => rw_craprdr.nrseqrdr);
  FETCH cr_crapaca
    INTO rw_crapaca;
  -- Verifica se existe a ação tela do ayllos web
  IF cr_crapaca%NOTFOUND THEN
    
    dbms_output.put_line('Insere CRAPACA -> TELA_IMPSIM -> TELA_IMPSIM.pc_exportar_arquivo_SIM');
    
    -- Insere ação da tela do ayllos web
    INSERT INTO crapaca(nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                 VALUES('IMPSIM_EXPORTA_ARQUIVO',
                        'TELA_IMPSIM',
                        'pc_exportar_arquivo_SIM',
                        'pr_arquivo ',
                        rw_craprdr.nrseqrdr);
  END IF;  
  close cr_crapaca;
  
  dbms_output.put_line('FIM');

  COMMIT;  
    
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro: ' || Sqlerrm);
    ROLLBACK;
END;
