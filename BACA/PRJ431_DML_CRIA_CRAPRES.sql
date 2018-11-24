/******************************************************************************************************** 
  Baca para criar tela CADRES
  Cadastro de responsáveis
  -----------------
   Autor: André Clemer (Supero)                                 Data: 16/07/2018
  -----------------
*********************************************************************************************************/

DECLARE
    VR_NMDATELA CRAPTEL.NMDATELA%TYPE;
    VR_DSPROGRA CRAPPRG.DSPROGRA##1%TYPE;
    VR_RSPROGRA VARCHAR2(242);
    VR_CDOPCOES CRAPTEL.CDOPPTEL%TYPE;
    VR_DSOPCOES CRAPTEL.LSOPPTEL%TYPE;
    VR_NRMODULO INTEGER;

    VR_NRORDPRG INTEGER;

    CURSOR CR_CRAPPRG_EXIST(PR_NRORDPRG IN CRAPPRG.NRORDPRG%TYPE) IS
        SELECT *
          FROM CRAPPRG
         WHERE CRAPPRG.NRSOLICI = 50
           AND CRAPPRG.NRORDPRG = PR_NRORDPRG;
    RW_CRAPPRG_EXIST CR_CRAPPRG_EXIST%ROWTYPE;

    CURSOR CR_CRAPTEL_EXIST(PR_CDCOOPER IN CRAPTEL.CDCOOPER%TYPE, PR_NMDATELA IN CRAPTEL.NMDATELA%TYPE) IS
        SELECT *
          FROM CRAPTEL
         WHERE CRAPTEL.CDCOOPER = PR_CDCOOPER
           AND CRAPTEL.NMDATELA = PR_NMDATELA
           AND (CRAPTEL.NMROTINA IS NULL OR CRAPTEL.NMROTINA = ' ');
    RW_CRAPTEL_EXIST CR_CRAPTEL_EXIST%ROWTYPE;

    CURSOR CR_CRAPPRG_EXIST2(PR_CDCOOPER IN CRAPPRG.CDCOOPER%TYPE,
                             PR_NMDATELA IN CRAPPRG.CDPROGRA%TYPE,
                             PR_NRORDPRG IN CRAPPRG.NRORDPRG%TYPE) IS
        SELECT *
          FROM CRAPPRG
         WHERE CRAPPRG.CDCOOPER = PR_CDCOOPER
           AND ((CRAPPRG.CDPROGRA = PR_NMDATELA AND CRAPPRG.NMSISTEM = 'CRED') OR
               (CRAPPRG.NRSOLICI = 50 AND CRAPPRG.NRORDPRG = PR_NRORDPRG));

    CURSOR CR_CRAPRDR(PR_NMPROGRA IN CRAPRDR.NMPROGRA%TYPE) IS
        SELECT * FROM CRAPRDR WHERE CRAPRDR.NMPROGRA = PR_NMPROGRA;
    RW_CRAPRDR CR_CRAPRDR%ROWTYPE;

    CURSOR CR_CRAPACA(PR_NMDEACAO IN CRAPACA.NMDEACAO%TYPE,
                      PR_NMPACKAG IN CRAPACA.NMPACKAG%TYPE,
                      PR_NMPROCED IN CRAPACA.NMPROCED%TYPE,
                      PR_NRSEQRDR IN CRAPACA.NRSEQRDR%TYPE) IS
        SELECT *
          FROM CRAPACA
         WHERE UPPER(CRAPACA.NMDEACAO) = UPPER(PR_NMDEACAO)
           AND UPPER(CRAPACA.NMPACKAG) = UPPER(PR_NMPACKAG)
           AND UPPER(CRAPACA.NMPROCED) = UPPER(PR_NMPROCED)
           AND CRAPACA.NRSEQRDR = PR_NRSEQRDR;
    RW_CRAPACA CR_CRAPACA%ROWTYPE;

    -- A tela deverá ser criara para as coops ativas
    CURSOR CR_CRAPCOP IS
        SELECT * FROM CRAPCOP P WHERE P.FLGATIVO = 1;

BEGIN
    -- Informações da Tela
    VR_NMDATELA := 'CADRES';
    VR_DSPROGRA := 'Cadastro de responsáveis';
    VR_RSPROGRA := 'TELA_CADRES';
    VR_CDOPCOES := 'C,A,I,E';
    VR_DSOPCOES := 'CONSULTA,ALTERAR,INCLUIR,EXCLUIR';
    VR_NRMODULO := 5; -- 5 = Cadastros

    VR_NRORDPRG := 1;
    /* vai verificar qual nrordprg esta disponivel */
    WHILE TRUE LOOP
        OPEN CR_CRAPPRG_EXIST(PR_NRORDPRG => VR_NRORDPRG);
    
        FETCH CR_CRAPPRG_EXIST
            INTO RW_CRAPPRG_EXIST;
    
        IF CR_CRAPPRG_EXIST%NOTFOUND THEN
            CLOSE CR_CRAPPRG_EXIST;
            EXIT;
        END IF;
    
        CLOSE CR_CRAPPRG_EXIST;
        VR_NRORDPRG := VR_NRORDPRG + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Ordem do Programa: ' || VR_NRORDPRG);

    FOR RW_CRAPCOP IN CR_CRAPCOP LOOP
        -- Verifica se a crapprg existe
        OPEN CR_CRAPPRG_EXIST2(PR_CDCOOPER => RW_CRAPCOP.CDCOOPER,
                               PR_NMDATELA => VR_NMDATELA,
                               PR_NRORDPRG => VR_NRORDPRG);
        FETCH CR_CRAPPRG_EXIST2
            INTO RW_CRAPPRG_EXIST;
    
        IF CR_CRAPPRG_EXIST2%NOTFOUND THEN
            DBMS_OUTPUT.PUT_LINE('Programa Criado! Coop: ' || RW_CRAPCOP.CDCOOPER);
            /* inctrprg = nao executado */
            /* inlibprg = liberado */
            INSERT INTO CRAPPRG
                (CDCOOPER, CDPROGRA, DSPROGRA##1, INCTRPRG, INLIBPRG, NMSISTEM, NRORDPRG, NRSOLICI)
            VALUES
                (RW_CRAPCOP.CDCOOPER, VR_NMDATELA, UPPER(VR_DSPROGRA), 1, 1, 'CRED', VR_NRORDPRG, 50);
        END IF;
        CLOSE CR_CRAPPRG_EXIST2;
    
        -- Verifica se a craptel existe
        OPEN CR_CRAPTEL_EXIST(PR_CDCOOPER => RW_CRAPCOP.CDCOOPER, PR_NMDATELA => VR_NMDATELA);
        FETCH CR_CRAPTEL_EXIST INTO RW_CRAPTEL_EXIST;

        IF CR_CRAPTEL_EXIST%NOTFOUND THEN
            DBMS_OUTPUT.PUT_LINE('Tela Criada! Coop: ' || RW_CRAPCOP.CDCOOPER);
            /* idevento = 0 - na    , 1 - progrid, 2 - assemb */
            /* idambtel = 0 - todos , 1 - ayllos , 2 - web */
            /* idsistem = 1 - ayllos, 2 - progrid */
            INSERT INTO CRAPTEL
                (CDCOOPER,
                 NMDATELA,
                 CDOPPTEL,
                 LSOPPTEL,
                 TLDATELA,
                 TLRESTEL,
                 NRMODULO,
                 INACESSO,
                 NRORDROT,
                 NRDNIVEL,
                 IDEVENTO,
                 IDAMBTEL,
                 IDSISTEM)
            VALUES
                (RW_CRAPCOP.CDCOOPER,
                 VR_NMDATELA,
                 VR_CDOPCOES,
                 VR_DSOPCOES,
                 UPPER(VR_DSPROGRA),
                 VR_DSPROGRA,
                 VR_NRMODULO,
                 1,
                 1,
                 1,
                 0,
                 2,
                 1);
        END IF;
        CLOSE CR_CRAPTEL_EXIST;

    END LOOP;

    -- Mensageria
    OPEN CR_CRAPRDR(PR_NMPROGRA => VR_RSPROGRA);
    FETCH CR_CRAPRDR INTO RW_CRAPRDR;

    -- Verifica se existe a tela do ayllos web
    IF CR_CRAPRDR%NOTFOUND THEN
        -- Se não encontrar
        CLOSE CR_CRAPRDR;
    
        DBMS_OUTPUT.PUT_LINE('Insere CRAPRDR -> ' || VR_RSPROGRA);
    
        -- Insere tela do ayllos web
        INSERT INTO CRAPRDR (NMPROGRA, DTSOLICI) VALUES (VR_RSPROGRA, SYSDATE);
        -- Busca o registro que acabou de ser inserido            
        OPEN CR_CRAPRDR(PR_NMPROGRA => VR_RSPROGRA);
        FETCH CR_CRAPRDR INTO RW_CRAPRDR;
    END IF;

    -- Fecha o cursor
    CLOSE CR_CRAPRDR;

    DBMS_OUTPUT.PUT_LINE('FIM');

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
        ROLLBACK;
END;
