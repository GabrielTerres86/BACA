PL/SQL Developer Test script 3.0
342
declare  

  --Busca todas as cooperativas
  CURSOR cr_crapcop IS
  SELECT crapcop.cdcooper
        ,crapcop.nmrescop
    FROM crapcop;
  rw_crapcop cr_crapcop%ROWTYPE;
         
  --Busca todos os registros da tela 
  CURSOR cr_craptel(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nmdatela IN craptel.nmdatela%TYPE
                   ,pr_nmrotina IN craptel.nmrotina%TYPE) IS
  SELECT *
    FROM craptel
   WHERE craptel.cdcooper = pr_cdcooper
     AND UPPER(craptel.nmdatela) = pr_nmdatela 
     AND upper(nvl(TRIM(craptel.nmrotina),' '))  = upper(nvl(trim(pr_nmrotina),' '));
  rw_craptel cr_craptel%ROWTYPE; 
  
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
  
  --Busca todos os operadores ativos no sistema
  CURSOR cr_crapope(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
  SELECT *
    FROM crapope
   WHERE crapope.cdcooper = pr_cdcooper
     AND crapope.cdsitope = 1; --Somente ativos
  rw_crapope cr_crapope%ROWTYPE;
    
  CURSOR cr_crapprm (pr_cdacesso IN crapprm.cdacesso%TYPE)IS
  SELECT 1 
    FROM crapprm
  WHERE crapprm.nmsistem = 'CRED'
    AND crapprm.cdcooper = 0
    AND crapprm.cdacesso = pr_cdacesso;
  rw_crapprm cr_crapprm%ROWTYPE;
  
  --Busca acessoa a tela no ambiente caracter
  --Busca acessoa a tela no ambiente web
  CURSOR cr_crapace(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_cdoperad IN crapope.cdoperad%TYPE
                   ,pr_nmdatela IN crapace.nmdatela%TYPE
                   ,pr_nmrotina IN crapace.nmrotina%TYPE
                   ,pr_cddopcao IN crapace.cddopcao%TYPE) IS
  SELECT *
    FROM crapace
   WHERE crapace.cdcooper = pr_cdcooper
     AND UPPER(crapace.cdoperad) = UPPER(pr_cdoperad)
     AND UPPER(crapace.nmdatela) = UPPER(pr_nmdatela)
     AND crapace.idambace = 2 --Somente no ambiente web
     AND UPPER(crapace.nmrotina) = UPPER(pr_nmrotina)
     AND crapace.cddopcao = pr_cddopcao; 
  rw_crapace cr_crapace%ROWTYPE;
  
  --Busca acessoa a tela no ambiente web
  CURSOR cr_crapace_web(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE
                       ,pr_nmdatela IN crapace.nmdatela%TYPE
                       ,pr_nmrotina IN crapace.nmrotina%TYPE
                       ,pr_cddopcao IN crapace.cddopcao%TYPE) IS
  SELECT crapace.cdcooper
    FROM crapace
   WHERE crapace.cdcooper = pr_cdcooper
     AND UPPER(crapace.cdoperad) = UPPER(pr_cdoperad)
     AND UPPER(crapace.nmdatela) = UPPER(pr_nmdatela)
     AND crapace.idambace = 2 --Somente no ambiente web
     AND UPPER(crapace.nmrotina) = UPPER(pr_nmrotina)
     AND crapace.cddopcao = pr_cddopcao; 
  rw_crapace_web cr_crapace_web%ROWTYPE;
  
  vr_exec_erro EXCEPTION;
  vr_dscritic  VARCHAR2(1000);
  vr_nmdatela  VARCHAR2(6) := 'INSS';
  vr_nmpackag  VARCHAR2(11) := 'inss0001';

begin
  
  dbms_output.put_line('Inicio do programa');
  
  OPEN cr_crapprm(pr_cdacesso => 'TOKEN_API_REENV_CAD_INSS');
  
  FETCH cr_crapprm INTO rw_crapprm;
  
  IF cr_crapprm%NOTFOUND THEN
    
    CLOSE cr_crapprm;
    
    BEGIN 
      INSERT INTO crapprm
                  (crapprm.nmsistem
                  ,crapprm.cdcooper
                  ,crapprm.cdacesso
                  ,crapprm.dstexprm
                  ,crapprm.dsvlrprm)
            VALUES('CRED'
                  ,0
                  ,'TOKEN_API_REENV_CAD_INSS'
                  ,'TOKEN para acesso ao WebService SICREDI - Reenvio Cadastral'
                  ,'https://apigw.sicredi.com.br/token?grant_type=client_credentials');        
    
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel incluir o registro crapprm.'; 
        RAISE vr_exec_erro; 
        
    END;
  
  ELSE
    CLOSE cr_crapprm;
                
  END IF;
  
  OPEN cr_crapprm(pr_cdacesso => 'LINK_API_REENV_CAD_INSS');
  
  FETCH cr_crapprm INTO rw_crapprm;
  
  IF cr_crapprm%NOTFOUND THEN
    
    CLOSE cr_crapprm;
    
    BEGIN 
      INSERT INTO crapprm
                  (crapprm.nmsistem
                  ,crapprm.cdcooper
                  ,crapprm.cdacesso
                  ,crapprm.dstexprm
                  ,crapprm.dsvlrprm)
            VALUES('CRED'
                  ,0
                  ,'LINK_API_REENV_CAD_INSS'
                  ,'Link para acesso ao WebService SICREDI - Reenvio Cadastral'
                  ,'https://apigw.sicredi.com.br/BeneficiarioINSSService');        
    
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel incluir o registro crapprm.'; 
        RAISE vr_exec_erro; 
        
    END;
  
  ELSE
    CLOSE cr_crapprm;
                
  END IF;
  
  OPEN cr_crapprm(pr_cdacesso => 'COD_TOKEN_API_INSS');
  
  FETCH cr_crapprm INTO rw_crapprm;
  
  IF cr_crapprm%NOTFOUND THEN
    
    CLOSE cr_crapprm;
    
    BEGIN 
      INSERT INTO crapprm
                  (crapprm.nmsistem
                  ,crapprm.cdcooper
                  ,crapprm.cdacesso
                  ,crapprm.dstexprm
                  ,crapprm.dsvlrprm)
            VALUES('CRED'
                  ,0
                  ,'COD_TOKEN_API_INSS'
                  ,'Codigo token para acesso ao WebService SICREDI'
                  ,'RVU5MWlmQlJQTGx5Nkp2SjdGVnJlQUZFVVJBYTpEbXFUTGZYTXVudDBMRWR2c0E5YzVxU3Y4ZWdh');        
    
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel incluir o registro crapprm.'; 
        RAISE vr_exec_erro; 
        
    END;
  
  ELSE
    CLOSE cr_crapprm;
                
  END IF;
  
  --Percorre todas as cooperativas
  FOR rw_crapcop IN cr_crapcop LOOP
    
    UPDATE craptel 
      SET craptel.cdopptel = '@,A,C,T,R' 
         ,craptel.lsopptel = 'ACESSO,ALTERA CADASTRO,COMPROVA VIDA,TROCA CONTA,REENVIO DE CADASTRO'
    WHERE craptel.cdcooper = rw_crapcop.cdcooper
      AND craptel.nmdatela = vr_nmdatela
      AND upper(craptel.nmrotina) = 'CONSULTA';
    
    --Busca os operadores
    FOR rw_crapope IN cr_crapope(pr_cdcooper => rw_crapcop.cdcooper) LOOP
            
      --Busca todos os acesso do operador para a tela em questão
      OPEN cr_crapace(pr_cdcooper => rw_crapcop.cdcooper
                     ,pr_cdoperad => rw_crapope.cdoperad
                     ,pr_nmdatela => vr_nmdatela
                     ,pr_nmrotina => 'CONSULTA'
                     ,pr_cddopcao => 'T');
                     
      FETCH cr_crapace INTO rw_crapace;
             
      --Se não encontroue
      IF cr_crapace%FOUND THEN
          
        --Fecha o cursor
        CLOSE cr_crapace;
                               
        --Busca registro de acesso a tela para o ambiente web      
        OPEN cr_crapace_web(pr_cdcooper => rw_crapcop.cdcooper
                           ,pr_cdoperad => rw_crapope.cdoperad
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmrotina => 'CONSULTA'
                           ,pr_cddopcao => 'R');                             
                                 
        FETCH cr_crapace_web INTO rw_crapace_web;
             
        --Se não encontroue
        IF cr_crapace_web%NOTFOUND THEN
               
          --Fecha o cursor
          CLOSE cr_crapace_web;
               
          BEGIN
            --Criar os acesso para a tela Web
            INSERT INTO crapace (crapace.nmdatela
                                ,crapace.cddopcao
                                ,crapace.cdoperad
                                ,crapace.nmrotina
                                ,crapace.cdcooper
                                ,crapace.nrmodulo
                                ,crapace.idevento
                                ,crapace.idambace)
                         VALUES (rw_crapace.nmdatela
                                ,'R'
                                ,rw_crapope.cdoperad
                                ,rw_crapace.nmrotina
                                ,rw_crapcop.cdcooper
                                ,rw_crapace.nrmodulo
                                ,rw_crapace.idevento
                                ,rw_crapace.idambace); --Ambiente web
                                     
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Nao foi possivel incluir o registro crapace "' || rw_crapace.cddopcao || '" da cooperativa: ' || rw_crapcop.nmrescop; 
              RAISE vr_exec_erro; 
          END;  
                   
        ELSE
          --Fecha o cursor
          CLOSE cr_crapace_web;  
                 
        END IF; 
      
      ELSE
        --Fecha o cursor
        CLOSE cr_crapace;
      END IF;
              
    END LOOP;  
              
  END LOOP;
  
  -- Mensageria
  OPEN cr_craprdr(pr_nmprogra => vr_nmdatela);
  
  FETCH cr_craprdr INTO rw_craprdr;
    
  -- Verifica se existe a tela do ayllos web
  IF cr_craprdr%NOTFOUND THEN
    
    -- Se não encontrar
    CLOSE cr_craprdr;

     vr_dscritic := 'Registros na craprdr não encontrado.'; 
     RAISE vr_exec_erro; 
    
  END IF;  
  
  -- Fecha o cursor
  CLOSE cr_craprdr;

  -- INICIO MENSAGERIA   
  OPEN cr_crapaca(pr_nmdeacao => 'REENVIACADBENEF'
                 ,pr_nmpackag => vr_nmpackag
                 ,pr_nmproced => 'pc_reenviar_cadastro_benef'
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
                 VALUES('REENVIACADBENEF',
                        vr_nmpackag,
                        'pc_reenviar_cadastro_benef',     
                        'pr_cddopcao,pr_nrdconta,pr_dtmvtolt,pr_cdorgins,pr_nrrecben,pr_idseqttl,pr_nrcpfcgc,pr_flgerlog',                   
                        rw_craprdr.nrseqrdr);
                             
    dbms_output.put_line('Insere CRAPACA -> REENVIACADBENEF -> INSS.pc_reenviar_cadastro_benef');
    
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
0
0
