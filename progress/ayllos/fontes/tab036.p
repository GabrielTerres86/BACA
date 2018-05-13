/* .............................................................................

   Programa: Fontes/tab036.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor  : Diego         
   Data    : Marco/2005                         Ultima alteracao: 08/11/2011 
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Parametro Valor Rating
   
   Alteracoes: 03/03/2009 - Permitir somente operador 799 ou 1 na opcao A.
                            (Fernando).
            
               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               11/08/2011 - Incluir % Grupo Economico (Guilherme).
               
               08/11/2011 - Adaptações para trabalhar com a BO124 (Lucas).
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }

DEF    VAR tel_vlrating  AS DECIMAL FORMAT "zz,zzz,zz9.99"          NO-UNDO.
DEF    VAR tel_pcgrpeco  AS DECIMAL FORMAT "zz9.99"                 NO-UNDO.
DEF    VAR tel_dstextab  AS CHAR    EXTENT 2                        NO-UNDO.                                                                       
DEF    VAR aux_cddopcao  AS CHAR                                    NO-UNDO.
DEF    VAR aux_confirma  AS CHAR    FORMAT "!(1)"                   NO-UNDO.
DEF    VAR aux_dstextab  AS CHAR                                    NO-UNDO.

DEF VAR h-b1wgen0124 AS HANDLE                                      NO-UNDO.

FORM WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela          
     ROW 4 COLUMN 1 SIZE 80 BY 18 OVERLAY WITH FRAME f_moldura.

FORM  SKIP(1)
      glb_cddopcao AT 29 LABEL "Opcao" AUTO-RETURN
                         HELP "Entre com a opcao desejada (A ou C)"
                         VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                  "014 - Opcao errada.")
      SKIP(4)
      tel_vlrating AT  9 LABEL "Valor Rating" 
                         HELP "Informe o Valor do Rating." 
      SKIP
      tel_pcgrpeco AT  6 LABEL "Grupo Economico" 
                         HELP "Informe o % de participacao para participar do GE." 
      "%" AT 29
WITH ROW 5 COLUMN 2 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_tab036.

VIEW FRAME f_moldura. 
PAUSE(0).

RUN fontes/inicia.p.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:
            
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
        UPDATE glb_cddopcao WITH FRAME f_tab036.
        LEAVE.
        
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "TAB036"   THEN
                DO:
                    HIDE FRAME f_tab036.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

    RUN sistema/generico/procedures/b1wgen0124.p 
        PERSISTENT SET h-b1wgen0124.
                
    RUN busca_tab036 IN h-b1wgen0124 (INPUT glb_cdcooper,
                                      INPUT 0, /* Agencia*/
                                      INPUT 0, /* Caixa  */
                                      INPUT glb_cdoperad,
                                      OUTPUT tel_vlrating,
                                      OUTPUT tel_pcgrpeco,
                                      OUTPUT TABLE tt-erro).
                         
    DELETE PROCEDURE h-b1wgen0124.

    /* Verifica se a Procedure retornou erro */
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAILABLE tt-erro  THEN
                MESSAGE tt-erro.dscritic.
                NEXT.
        END.
    
    DISPLAY tel_vlrating tel_pcgrpeco WITH FRAME f_tab036.
    
    IF  glb_cddopcao = "A" THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0124.p 
                    PERSISTENT SET h-b1wgen0124.
                            
            RUN permiss_tab036 IN h-b1wgen0124 (INPUT glb_cdcooper,
                                                INPUT 0, /* Agencia*/
                                                INPUT 0, /* Caixa  */
                                                INPUT glb_cdoperad,
                                                INPUT glb_dsdepart,
                                                OUTPUT TABLE tt-erro).
                                 
            DELETE PROCEDURE h-b1wgen0124.
            
            /* Verifica se a Procedure retornou erro */
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                    IF  AVAILABLE tt-erro  THEN
                        MESSAGE tt-erro.dscritic.
                        NEXT.
                END.

            DO WHILE TRUE ON ENDKEY UNDO, NEXT:

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    DO:
                        DISPLAY tel_vlrating tel_pcgrpeco WITH FRAME f_tab036.
                        LEAVE.
                    END.
                
                UPDATE tel_vlrating tel_pcgrpeco WITH FRAME f_tab036.
                   
                ASSIGN aux_confirma = "N".
                RUN fontes/confirma.p (INPUT  "",
                                       OUTPUT aux_confirma).
  
                IF  aux_confirma = "S" THEN
                    DO:
                        RUN sistema/generico/procedures/b1wgen0124.p 
                        PERSISTENT SET h-b1wgen0124.
                        
                        RUN altera_tab036 IN h-b1wgen0124 (INPUT glb_cdcooper,
                                                           INPUT 0, /* Agencia*/
                                                           INPUT 0, /* Caixa  */
                                                           INPUT glb_cdoperad,
                                                           INPUT "tab036",
                                                           INPUT 1, /* Ayllos */
                                                           INPUT glb_dtmvtolt, 
                                                           INPUT TRUE, /* Gerar log */
                                                           INPUT aux_dstextab,
                                                           INPUT glb_dsdepart,
                                                           INPUT tel_vlrating,
                                                           INPUT tel_pcgrpeco,
                                                           OUTPUT TABLE tt-erro).
                        
                        DELETE PROCEDURE h-b1wgen0124.
                        
                        IF  RETURN-VALUE = "NOK"  THEN
                            DO:
                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        
                                IF  AVAILABLE tt-erro  THEN
                                    MESSAGE tt-erro.dscritic.
                                    NEXT.
                        
                            END.
                    END.
                ELSE
                    NEXT.

                LEAVE.
            END.
        
        END. /* Opcao "A" */   
END.

/* .......................................................................... */
