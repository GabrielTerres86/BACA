/* .............................................................................

    Programa: fontes/tab042.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : David
    Data    : Setembro/2006                      Ultima atualizacao: 02/08/2011

    Dados referentes ao programa:

    Frequencia: Diario (On-Line).
    Objetivo  : Mostrar Tela TAB042.
                Cadastrar Contas Para Liberacao de Prazo.

    Alteracoes:  28/07/2008 - Incluir log usando a craplog e permitir somente
                              que os operadores 1,996,997,799 facam alteracoes
                              (Gabriel).

                 08/09/2008 - Permitir tambem aos gerentes das cooperativas 
                              acessar a opcao de alteracao (Gabriel).

                 23/01/2009 - Retirar permissao do operador 799 e liberar o
                              979 (Gabriel).
               
                 07/04/2009 - Permitir tambem aos gerentes das cooperativas 
                              acessar a opcao de alteracao (Mirtes).
                              
                 25/05/2009 - Alteracao CDOPERAD (Kbase).
                 
                 18/02/2010 - Criacao de um arquivo de log para funcao 
                              alteracao - (GATI - Daniel)
                              
                 02/08/2011 - Alterado para utilizar as procedures da BO 106 
                              (Henrique).
............................................................................. */

{ includes/var_online.i}
{ sistema/generico/includes/var_internet.i }

DEF VAR tel_dstextab AS CHAR EXTENT 4                                  NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.
DEF VAR aux_dstextab AS CHAR                                           NO-UNDO.
DEF VAR aux_dstextlg AS CHAR                                           NO-UNDO.
DEF VAR aux_contador AS INT                                            NO-UNDO.

DEF VAR h-b1wgen0106 AS HANDLE                                       NO-UNDO.

FORM
    SKIP(3)
    glb_cddopcao    AT 8
                    LABEL "Opcao"
                    HELP "Informe a opcao desejada - (A)lterar ou (C)onsultar."
                    VALIDATE(CAN-DO("A,C",glb_cddopcao),"014 - Opcao Errada.")
    SKIP(3)
    tel_dstextab[1] AT 8  AUTO-RETURN
                    LABEL "Descricao" FORMAT "x(50)" 
                    HELP "Informe o valor do parametro."
    SKIP
    tel_dstextab[2] AT 19 AUTO-RETURN FORMAT "x(50)"
                    HELP "Informe o valor do parametro."
    SKIP
    tel_dstextab[3] AT 19 AUTO-RETURN FORMAT "x(50)"
                    HELP "Informe o valor do parametro."
    SKIP
    tel_dstextab[4] AT 19 AUTO-RETURN FORMAT "x(50)"
                    HELP "Informe o valor do parametro."
 
    WITH NO-LABEL SIDE-LABEL OVERLAY TITLE glb_tldatela SIZE 80 BY 18
    ROW 4 FRAME f_tab042.
    
RUN fontes/inicia.p.

VIEW FRAME f_tab042.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

    DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
         UPDATE glb_cddopcao WITH FRAME f_tab042.
         LEAVE.
    END.
    
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN 
         DO:
             RUN fontes/novatela.p.
         
             IF   CAPS(glb_nmdatela) <> "tab042"   THEN
                  DO:
                      HIDE FRAME f_tab042.
                      RETURN.
                  END.
             ELSE
                  NEXT.
         END.
   
    IF   aux_cddopcao <> glb_cddopcao   THEN
         DO:
             { includes/acesso.i }
             aux_cddopcao = glb_cddopcao.
         END.

    RUN sistema/generico/procedures/b1wgen0106.p 
        PERSISTENT SET h-b1wgen0106.

    RUN busca_tab042 IN h-b1wgen0106 (INPUT glb_cdcooper,
                                      INPUT 0, /* Agencia*/
                                      INPUT 0, /* Caixa  */
                                      INPUT glb_cdoperad,
                                     OUTPUT aux_dstextab,
                                     OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0106.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                MESSAGE tt-erro.dscritic.
       
            NEXT.
        END.

    ASSIGN tel_dstextab[1] = SUBSTR(aux_dstextab,001,50)
           tel_dstextab[2] = SUBSTR(aux_dstextab,051,50)
           tel_dstextab[3] = SUBSTR(aux_dstextab,101,50)
           tel_dstextab[4] = SUBSTR(aux_dstextab,151,50).
    
    DISPLAY tel_dstextab[1] tel_dstextab[2] tel_dstextab[3]
            tel_dstextab[4] WITH FRAME f_tab042.

    IF  glb_cddopcao = "A"  THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               UPDATE tel_dstextab[1] tel_dstextab[2]
                      tel_dstextab[3] tel_dstextab[4]
                      WITH FRAME f_tab042.
                LEAVE.
            END.
            
            ASSIGN aux_confirma = "N".
            RUN fontes/confirma.p (INPUT  "",
                                   OUTPUT aux_confirma).
            IF  aux_confirma = "S" THEN
                DO:
                    ASSIGN aux_dstextab = tel_dstextab[1] + tel_dstextab[2] +
                                          tel_dstextab[3] + tel_dstextab[4].

                    
                    RUN sistema/generico/procedures/b1wgen0106.p 
                        PERSISTENT SET h-b1wgen0106.

                    RUN altera_tab042 IN h-b1wgen0106 (INPUT glb_cdcooper,
                                                       INPUT 0, /* Agencia*/
                                                       INPUT 0, /* Caixa  */
                                                       INPUT glb_cdoperad,
                                                       INPUT "tab042",
                                                       INPUT 1, /* Ayllos */
                                                       INPUT glb_dtmvtolt, 
                                                       INPUT TRUE, /* Gerar log */
                                                       INPUT aux_dstextab,
                                                       INPUT glb_dsdepart,
                                                      OUTPUT TABLE tt-erro).

                    DELETE PROCEDURE h-b1wgen0106.

                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.

                            IF  AVAILABLE tt-erro  THEN
                                MESSAGE tt-erro.dscritic.

                            NEXT.
                        END.
                    ELSE
                        DO:
                            MESSAGE "Contas alteradas com sucesso.".
                            NEXT.
                        END.

                END.
        END.

END. /* Fim do DO WHILE */

/* .......................................................................... */
