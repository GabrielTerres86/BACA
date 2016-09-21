/*..............................................................................
                
    Programa: fontes/lista_criticas_rating.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : David
    Data    : Abril/2010                      Ultima atualizacao: 00/00/0000
   
    Dados referentes ao programa:
   
    Frequencia: Sera chamado sempre que uma operacao para proposta gere 
                criticas no calculo do rating do cooperado. 
               
    Alteracoes:
    
..............................................................................*/
   
{ sistema/generico/includes/var_internet.i }               

DEF  INPUT PARAM TABLE FOR tt-erro.

FORM tt-erro.dscritic COLUMN-LABEL "Descricao" FORMAT "x(62)"
     WITH 4 DOWN TITLE COLOR NORMAL " Criticas do Rating " 
     OVERLAY CENTERED ROW 11 WIDTH 64 FRAME f_criticas.

/** BO retornou somente uma critica **/
IF  NOT CAN-FIND(FIRST tt-erro WHERE tt-erro.nrsequen > 1)  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-erro  THEN
            MESSAGE tt-erro.dscritic.
        ELSE
            MESSAGE "Erro na geraçao do Rating.".

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            PAUSE.
            LEAVE.
        END.
    END.
ELSE
    DO:
        FIND tt-erro WHERE tt-erro.cdcritic = 830 NO-LOCK NO-ERROR.

        /** Faltam dados cadastrais **/
        IF  AVAILABLE tt-erro  THEN
            MESSAGE tt-erro.dscritic.
        ELSE
            MESSAGE "Erro na geraçao do Rating.".

        /** Mostrar todas as criticas para os usuarios **/
        FOR EACH tt-erro WHERE tt-erro.cdcritic <> 830 NO-LOCK:

            DISPLAY tt-erro.dscritic WITH FRAME f_criticas.
            DOWN WITH FRAME f_criticas.

        END. /** Fim do FOR EACH tt-erro **/

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            PAUSE.
            LEAVE.
        END.
    
        HIDE MESSAGE NO-PAUSE.
        HIDE FRAME f_criticas.
    END.

/*............................................................................*/
