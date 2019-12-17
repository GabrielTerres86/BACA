PL/SQL Developer Test script 3.0
404
DECLARE 
  
  -- ALTERAR
  NOME_DA_ACAO       VARCHAR2(40)   := 'ALTERARRATING';
  PROCEDURE_DA_ACAO  VARCHAR2(100)  := 'PC_ALTERAR_RATING';
  PACKAGE_DA_ACAO    VARCHAR2(100)  := 'TELA_RATMOV';
  PARAMETROS_DA_ACAO VARCHAR2(1000) := 'pr_nrcpfcgc, pr_nrdconta , pr_nrctro  ,pr_tpproduto ,pr_rating_sugerido, pr_justificativa, pr_botao_chamada' ;
  -- FIM ALTERAR 
                                 
  CURSOR CR_CRAPRDR(PR_NMPROGRA IN CRAPRDR.NMPROGRA%TYPE) IS
    SELECT *
      FROM CRAPRDR
     WHERE CRAPRDR.NMPROGRA = PR_NMPROGRA;
  RW_CRAPRDR CR_CRAPRDR%ROWTYPE;

  CURSOR CR_CRAPACA(PR_NMDEACAO IN CRAPACA.NMDEACAO%TYPE
                   ,PR_NMPACKAG IN CRAPACA.NMPACKAG%TYPE
                   ,PR_NMPROCED IN CRAPACA.NMPROCED%TYPE
                   ,PR_NRSEQRDR IN CRAPACA.NRSEQRDR%TYPE) IS
  SELECT * FROM CRAPACA
   WHERE UPPER(CRAPACA.NMDEACAO) = UPPER(PR_NMDEACAO)
     AND UPPER(CRAPACA.NMPACKAG) = UPPER(PR_NMPACKAG)
     AND UPPER(CRAPACA.NMPROCED) = UPPER(PR_NMPROCED)
     AND CRAPACA.NRSEQRDR = PR_NRSEQRDR;
  RW_CRAPACA CR_CRAPACA%ROWTYPE;
  
  VR_EXEC_ERRO EXCEPTION;
  VR_DSCRITIC  VARCHAR2(1000);  

BEGIN

----------------------------------------------
-------------     AÇÃO ALTERARRATING   -------
----------------------------------------------
  -- ALTERAR
  NOME_DA_ACAO        := 'ALTERARRATING';
  PROCEDURE_DA_ACAO   := 'PC_ALTERAR_RATING';
  PACKAGE_DA_ACAO     := 'TELA_RATMOV';
  PARAMETROS_DA_ACAO  := 'pr_nrcpfcgc, pr_nrdconta , pr_nrctro  ,pr_tpproduto ,pr_rating_sugerido, pr_justificativa, pr_botao_chamada' ;
  -- FIM ALTERAR 

  DBMS_OUTPUT.PUT_LINE('INICIO DO PROGRAMA - ' || NOME_DA_ACAO);
  
  -- MENSAGERIA
  OPEN CR_CRAPRDR(PR_NMPROGRA => PACKAGE_DA_ACAO);
  FETCH CR_CRAPRDR INTO RW_CRAPRDR;
    
  -- VERIFICA SE EXISTE A TELA DO AYLLOS WEB
  IF CR_CRAPRDR%NOTFOUND THEN
   
    -- SE NÃO ENCONTRAR
    CLOSE CR_CRAPRDR;

    -- INSERE AÇÃO DA TELA DO AYLLOAS WEB
    INSERT INTO CRAPRDR(NMPROGRA
                       ,DTSOLICI) 
                 VALUES(PACKAGE_DA_ACAO
                       ,SYSDATE);
    -- POSICIONA NO REGISTRO CRIADO
    OPEN CR_CRAPRDR(PR_NMPROGRA => PACKAGE_DA_ACAO);
    FETCH CR_CRAPRDR INTO RW_CRAPRDR;

    DBMS_OUTPUT.PUT_LINE('INSERE CRAPRDR -> '||PACKAGE_DA_ACAO||': ' || RW_CRAPRDR.NRSEQRDR);

  END IF;  
  
  -- FECHA O CURSOR
  CLOSE CR_CRAPRDR;

  -- INICIO MENSAGERIA   
  
  OPEN CR_CRAPACA(PR_NMDEACAO => NOME_DA_ACAO
                 ,PR_NMPACKAG => PACKAGE_DA_ACAO
                 ,PR_NMPROCED => PROCEDURE_DA_ACAO
                 ,PR_NRSEQRDR => RW_CRAPRDR.NRSEQRDR);
                   
  FETCH CR_CRAPACA INTO RW_CRAPACA;
    
  -- VERIFICA SE EXISTE A AÇÃO TELA DO AYLLOS WEB
  IF CR_CRAPACA%NOTFOUND THEN
    
    -- INSERE AÇÃO DA TELA DO AYLLOS WEB
    INSERT INTO CRAPACA(NMDEACAO, 
                        NMPACKAG, 
                        NMPROCED, 
                        LSTPARAM, 
                        NRSEQRDR) 
                 VALUES(NOME_DA_ACAO,
                        PACKAGE_DA_ACAO,
                        PROCEDURE_DA_ACAO,
                        PARAMETROS_DA_ACAO,
                        RW_CRAPRDR.NRSEQRDR);
                             
    DBMS_OUTPUT.PUT_LINE('INSERE CRAPACA -> '||NOME_DA_ACAO||' -> '||PACKAGE_DA_ACAO||'.'||PROCEDURE_DA_ACAO);
    
  END IF;
  
  CLOSE CR_CRAPACA;  
  
  DBMS_OUTPUT.PUT_LINE('FIM DO PROGRAMA - ' || NOME_DA_ACAO);


----------------------------------------
---------------- AÇÃO RATMOV_CONSULTAR  -------
----------------------------------------
  NOME_DA_ACAO       := 'RATMOV_CONSULTAR';
  PROCEDURE_DA_ACAO  := 'PC_CONSULTAR';
  PACKAGE_DA_ACAO    := 'TELA_RATMOV';
  PARAMETROS_DA_ACAO := 'pr_nmprimtl ,pr_nrcpfcgc ';
  

  DBMS_OUTPUT.PUT_LINE('INICIO DO PROGRAMA - ' || NOME_DA_ACAO);
  
  -- MENSAGERIA
  OPEN CR_CRAPRDR(PR_NMPROGRA => PACKAGE_DA_ACAO);
  FETCH CR_CRAPRDR INTO RW_CRAPRDR;
    
  -- VERIFICA SE EXISTE A TELA DO AYLLOS WEB
  IF CR_CRAPRDR%NOTFOUND THEN
   
    -- SE NÃO ENCONTRAR
    CLOSE CR_CRAPRDR;

    -- INSERE AÇÃO DA TELA DO AYLLOAS WEB
    INSERT INTO CRAPRDR(NMPROGRA
                       ,DTSOLICI) 
                 VALUES(PACKAGE_DA_ACAO
                       ,SYSDATE);
    -- POSICIONA NO REGISTRO CRIADO
    OPEN CR_CRAPRDR(PR_NMPROGRA => PACKAGE_DA_ACAO);
    FETCH CR_CRAPRDR INTO RW_CRAPRDR;

    DBMS_OUTPUT.PUT_LINE('INSERE CRAPRDR -> '||PACKAGE_DA_ACAO||': ' || RW_CRAPRDR.NRSEQRDR);

  END IF;  
  
  -- FECHA O CURSOR
  CLOSE CR_CRAPRDR;

  -- INICIO MENSAGERIA   
  
  OPEN CR_CRAPACA(PR_NMDEACAO => NOME_DA_ACAO
                 ,PR_NMPACKAG => PACKAGE_DA_ACAO
                 ,PR_NMPROCED => PROCEDURE_DA_ACAO
                 ,PR_NRSEQRDR => RW_CRAPRDR.NRSEQRDR);
                   
  FETCH CR_CRAPACA INTO RW_CRAPACA;
    
  -- VERIFICA SE EXISTE A AÇÃO TELA DO AYLLOS WEB
  IF CR_CRAPACA%NOTFOUND THEN
    
    -- INSERE AÇÃO DA TELA DO AYLLOS WEB
    INSERT INTO CRAPACA(NMDEACAO, 
                        NMPACKAG, 
                        NMPROCED, 
                        LSTPARAM, 
                        NRSEQRDR) 
                 VALUES(NOME_DA_ACAO,
                        PACKAGE_DA_ACAO,
                        PROCEDURE_DA_ACAO,
                        PARAMETROS_DA_ACAO,
                        RW_CRAPRDR.NRSEQRDR);
                             
    DBMS_OUTPUT.PUT_LINE('INSERE CRAPACA -> '||NOME_DA_ACAO||' -> '||PACKAGE_DA_ACAO||'.'||PROCEDURE_DA_ACAO);
    
  END IF;
  
  CLOSE CR_CRAPACA;  
  
  DBMS_OUTPUT.PUT_LINE('FIM DO PROGRAMA - ' || NOME_DA_ACAO);


-------------------------------------------
---------------- AÇÃO CONSULTARRAT  -------
-------------------------------------------
  -- ALTERAR
  NOME_DA_ACAO       := 'CONSULTARRAT';
  PROCEDURE_DA_ACAO  := 'PC_CONSULTAR_RATING';
  PACKAGE_DA_ACAO    := 'TELA_RATMOV';
  PARAMETROS_DA_ACAO := 'pr_nrcpfcgc,pr_nrdconta,pr_nrctro,pr_status,pr_datafim,pr_dataini,pr_crapbdc,pr_crapbdt,pr_craplim,pr_crawepr,pr_crapcpa,pr_contrliq';
  -- FIM ALTERAR

  DBMS_OUTPUT.PUT_LINE('INICIO DO PROGRAMA - ' || NOME_DA_ACAO);
  
  -- MENSAGERIA
  OPEN CR_CRAPRDR(PR_NMPROGRA => PACKAGE_DA_ACAO);
  FETCH CR_CRAPRDR INTO RW_CRAPRDR;
    
  -- VERIFICA SE EXISTE A TELA DO AYLLOS WEB
  IF CR_CRAPRDR%NOTFOUND THEN
   
    -- SE NÃO ENCONTRAR
    CLOSE CR_CRAPRDR;

    -- INSERE AÇÃO DA TELA DO AYLLOAS WEB
    INSERT INTO CRAPRDR(NMPROGRA
                       ,DTSOLICI) 
                 VALUES(PACKAGE_DA_ACAO
                       ,SYSDATE);
    -- POSICIONA NO REGISTRO CRIADO
    OPEN CR_CRAPRDR(PR_NMPROGRA => PACKAGE_DA_ACAO);
    FETCH CR_CRAPRDR INTO RW_CRAPRDR;

    DBMS_OUTPUT.PUT_LINE('INSERE CRAPRDR -> '||PACKAGE_DA_ACAO||': ' || RW_CRAPRDR.NRSEQRDR);

  END IF;  
  
  -- FECHA O CURSOR
  CLOSE CR_CRAPRDR;

  -- INICIO MENSAGERIA   
  
  OPEN CR_CRAPACA(PR_NMDEACAO => NOME_DA_ACAO
                 ,PR_NMPACKAG => PACKAGE_DA_ACAO
                 ,PR_NMPROCED => PROCEDURE_DA_ACAO
                 ,PR_NRSEQRDR => RW_CRAPRDR.NRSEQRDR);
                   
  FETCH CR_CRAPACA INTO RW_CRAPACA;
    
  -- VERIFICA SE EXISTE A AÇÃO TELA DO AYLLOS WEB
  IF CR_CRAPACA%NOTFOUND THEN
    
    -- INSERE AÇÃO DA TELA DO AYLLOS WEB
    INSERT INTO CRAPACA(NMDEACAO, 
                        NMPACKAG, 
                        NMPROCED, 
                        LSTPARAM, 
                        NRSEQRDR) 
                 VALUES(NOME_DA_ACAO,
                        PACKAGE_DA_ACAO,
                        PROCEDURE_DA_ACAO,
                        PARAMETROS_DA_ACAO,
                        RW_CRAPRDR.NRSEQRDR);
                             
    DBMS_OUTPUT.PUT_LINE('INSERE CRAPACA -> '||NOME_DA_ACAO||' -> '||PACKAGE_DA_ACAO||'.'||PROCEDURE_DA_ACAO);
    
  END IF;
  
  CLOSE CR_CRAPACA;  
  
  DBMS_OUTPUT.PUT_LINE('FIM DO PROGRAMA - ' || NOME_DA_ACAO);



-------------------------------------------
---------------- AÇÃO PC_IMPRIMIR  -------
-------------------------------------------
  -- ALTERAR
  NOME_DA_ACAO       := 'PC_IMPRIMIR';
  PROCEDURE_DA_ACAO  := 'PC_IMP_HISTORICO_WEB';
  PACKAGE_DA_ACAO    := 'TELA_RATMOV';
  PARAMETROS_DA_ACAO := 'pr_nrcpfcgc,pr_nrdconta,pr_nrctro,pr_status,pr_datafim,pr_dataini,pr_crapbdc,pr_crapbdt,pr_craplim,pr_crawepr,pr_crapcpa,pr_contrliq';
  -- FIM ALTERAR

  DBMS_OUTPUT.PUT_LINE('INICIO DO PROGRAMA - ' || NOME_DA_ACAO);

  -- MENSAGERIA
  OPEN CR_CRAPRDR(PR_NMPROGRA => PACKAGE_DA_ACAO);
  FETCH CR_CRAPRDR INTO RW_CRAPRDR;

  -- VERIFICA SE EXISTE A TELA DO AYLLOS WEB
  IF CR_CRAPRDR%NOTFOUND THEN

    -- SE NÃO ENCONTRAR
    CLOSE CR_CRAPRDR;

    -- INSERE AÇÃO DA TELA DO AYLLOAS WEB
    INSERT INTO CRAPRDR(NMPROGRA
                       ,DTSOLICI)
                 VALUES(PACKAGE_DA_ACAO
                       ,SYSDATE);
    -- POSICIONA NO REGISTRO CRIADO
    OPEN CR_CRAPRDR(PR_NMPROGRA => PACKAGE_DA_ACAO);
    FETCH CR_CRAPRDR INTO RW_CRAPRDR;

    DBMS_OUTPUT.PUT_LINE('INSERE CRAPRDR -> '||PACKAGE_DA_ACAO||': ' || RW_CRAPRDR.NRSEQRDR);

  END IF;

  -- FECHA O CURSOR
  CLOSE CR_CRAPRDR;

  -- INICIO MENSAGERIA

  OPEN CR_CRAPACA(PR_NMDEACAO => NOME_DA_ACAO
                 ,PR_NMPACKAG => PACKAGE_DA_ACAO
                 ,PR_NMPROCED => PROCEDURE_DA_ACAO
                 ,PR_NRSEQRDR => RW_CRAPRDR.NRSEQRDR);

  FETCH CR_CRAPACA INTO RW_CRAPACA;

  -- VERIFICA SE EXISTE A AÇÃO TELA DO AYLLOS WEB
  IF CR_CRAPACA%NOTFOUND THEN

    -- INSERE AÇÃO DA TELA DO AYLLOS WEB
    INSERT INTO CRAPACA(NMDEACAO,
                        NMPACKAG,
                        NMPROCED,
                        LSTPARAM,
                        NRSEQRDR)
                 VALUES(NOME_DA_ACAO,
                        PACKAGE_DA_ACAO,
                        PROCEDURE_DA_ACAO,
                        PARAMETROS_DA_ACAO,
                        RW_CRAPRDR.NRSEQRDR);

    DBMS_OUTPUT.PUT_LINE('INSERE CRAPACA -> '||NOME_DA_ACAO||' -> '||PACKAGE_DA_ACAO||'.'||PROCEDURE_DA_ACAO);

  END IF;

  CLOSE CR_CRAPACA;

  DBMS_OUTPUT.PUT_LINE('FIM DO PROGRAMA - ' || NOME_DA_ACAO);



-------------------------------------------
---------------- AÇÃO APRESENTA_RATING_MOTOR  -------
-------------------------------------------
  -- ALTERAR
  NOME_DA_ACAO      := 'APRESENTA_RATING_MOTOR';
  PROCEDURE_DA_ACAO := 'PC_APRESENTA_RATING_MOTOR';
  PACKAGE_DA_ACAO   := 'TELA_RATMOV';
  PARAMETROS_DA_ACAO:= 'pr_nrdconta, pr_nrctro, pr_tpctrato ';
  -- FIM ALTERAR

  DBMS_OUTPUT.PUT_LINE('INICIO DO PROGRAMA - ' || NOME_DA_ACAO);
  -- MENSAGERIA
  OPEN CR_CRAPRDR(PR_NMPROGRA => PACKAGE_DA_ACAO);
  FETCH CR_CRAPRDR INTO RW_CRAPRDR;
    
  -- VERIFICA SE EXISTE A TELA DO AYLLOS WEB
  IF CR_CRAPRDR%NOTFOUND THEN
   
    -- SE NÃO ENCONTRAR
    CLOSE CR_CRAPRDR;

    -- INSERE AÇÃO DA TELA DO AYLLOAS WEB
    INSERT INTO CRAPRDR(NMPROGRA
                       ,DTSOLICI) 
                 VALUES(PACKAGE_DA_ACAO
                       ,SYSDATE);
    -- POSICIONA NO REGISTRO CRIADO
    OPEN CR_CRAPRDR(PR_NMPROGRA => PACKAGE_DA_ACAO);
    FETCH CR_CRAPRDR INTO RW_CRAPRDR;

    DBMS_OUTPUT.PUT_LINE('INSERE CRAPRDR -> '||PACKAGE_DA_ACAO||': ' || RW_CRAPRDR.NRSEQRDR);

  END IF;  
  
  -- FECHA O CURSOR
  CLOSE CR_CRAPRDR;

  -- INICIO MENSAGERIA   
  
  OPEN CR_CRAPACA(PR_NMDEACAO => NOME_DA_ACAO
                 ,PR_NMPACKAG => PACKAGE_DA_ACAO
                 ,PR_NMPROCED => PROCEDURE_DA_ACAO
                 ,PR_NRSEQRDR => RW_CRAPRDR.NRSEQRDR);
                   
  FETCH CR_CRAPACA INTO RW_CRAPACA;
    
  -- VERIFICA SE EXISTE A AÇÃO TELA DO AYLLOS WEB
  IF CR_CRAPACA%NOTFOUND THEN
    
    -- INSERE AÇÃO DA TELA DO AYLLOS WEB
    INSERT INTO CRAPACA(NMDEACAO, 
                        NMPACKAG, 
                        NMPROCED, 
                        LSTPARAM, 
                        NRSEQRDR) 
                 VALUES(NOME_DA_ACAO,
                        PACKAGE_DA_ACAO,
                        PROCEDURE_DA_ACAO,
                        PARAMETROS_DA_ACAO,
                        RW_CRAPRDR.NRSEQRDR);
                             
    DBMS_OUTPUT.PUT_LINE('INSERE CRAPACA -> '||NOME_DA_ACAO||' -> '||PACKAGE_DA_ACAO||'.'||PROCEDURE_DA_ACAO);
    
  END IF;
  
  CLOSE CR_CRAPACA;  
  
  DBMS_OUTPUT.PUT_LINE('FIM DO PROGRAMA - ' || NOME_DA_ACAO);
  




  COMMIT;
  
EXCEPTION 
  WHEN VR_EXEC_ERRO THEN
    
    DBMS_OUTPUT.PUT_LINE('ERRO:' || VR_DSCRITIC);
    ROLLBACK;
   
  WHEN OTHERS THEN
        
    DBMS_OUTPUT.PUT_LINE('ERRO A EXECUTAR O PROGRAMA:' || SQLERRM);

    ROLLBACK;
    
END;
0
0
