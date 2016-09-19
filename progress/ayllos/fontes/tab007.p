/* .............................................................................

   Programa: Fontes/tab007.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/93.                        Ultima atualizacao: 25/11/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB007.

   Alteracoes: 17/07/95 - Alterado para tratar mais um parametro no texto da
                          tabela (Deborah).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               06/07/2009 - Limitar utilizacao da tela aos departamentos
                            "COORD.ADM/FINANCEIRO" e "COORD.PRODUTOS" (Diego).
               
               06/01/2010 - Adicionados dois parametros - maiores aplicadores e
                            maiores cotistas (Fernando).
                            
               23/04/2010 - Alterado programa para nao validar o acesso no 
                            opcao consulta (Gati - Daniel).  
                            
               25/11/2011 - Alterado para utilizar a BO132 (Lucas).  
               
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
............................................................................. */

{ includes/var_online.i } 
{ sistema/generico/includes/var_internet.i }

DEF  VAR tel_vlmaidep AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF  VAR tel_vlmaisal AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF  VAR tel_vlmaiapl AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF  VAR tel_vlmaicot AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF  VAR tel_vlsldneg AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.

DEF  VAR aux_dsacesso AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF  VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF  VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF  VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF  VAR h-b1wgen0132 AS HANDLE                                NO-UNDO.

FORM SKIP(2)
     glb_cddopcao AT 39 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (A ou C)"
                         VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(2)
     tel_vlmaidep AT 17 LABEL " Depositos acima de (geral)"
             HELP "Entre com o valor dos maiores depositos a serem listados."
     SKIP(1)
     tel_vlmaiapl AT 17 LABEL "Aplicacoes acima de (geral)"
             HELP "Entre com o valor dos maiores aplicadores a serem listados."
     SKIP(1)
     tel_vlmaicot AT 17 LABEL "     Cotas acima de (geral)"
             HELP "Entre com o valor dos maiores cotistas a serem listados."
     SKIP(1)
     tel_vlmaisal AT 18 LABEL "  Saldos acima de (por PA)"
             HELP "Entre com o valor dos maiores saldos a serem listados."
     SKIP(1)
     tel_vlsldneg AT 18 LABEL "Maiores negativos (por PA)"
             HELP "Entre com o valor dos maiores negativos a serem listados."
     SKIP(2)
WITH ROW 4 OVERLAY SIDE-LABELS TITLE glb_tldatela WIDTH 80 FRAME f_tab007.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

RUN fontes/inicia.p.

DO WHILE TRUE:
    
    CLEAR FRAME f_tab007.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE glb_cddopcao WITH FRAME f_tab007.
        LEAVE.

    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "TAB007"   THEN
                DO:
                    HIDE FRAME f_tab007.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> INPUT glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = INPUT glb_cddopcao.
        END.
   
    IF  glb_cddopcao = "A" THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0132.p 
                PERSISTENT SET h-b1wgen0132.
                                 
            RUN permiss_tab007 IN h-b1wgen0132 (INPUT glb_cdcooper,
                                                INPUT 0, /* Agencia*/
                                                INPUT 0, /* Caixa  */
                                                INPUT glb_cdoperad,
                                                INPUT glb_dsdepart,
                                                OUTPUT TABLE tt-erro).
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    DELETE PROCEDURE h-b1wgen0132.

                    CLEAR FRAME f_tab007.
            
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                    IF  AVAILABLE tt-erro  THEN
                        MESSAGE tt-erro.dscritic.
            
                    LEAVE.
                END.
            
            RUN busca_tab007 IN h-b1wgen0132 (INPUT glb_cdcooper,
                                              INPUT 0, /* Agencia*/
                                              INPUT 0, /* Caixa  */
                                              INPUT glb_cdoperad,
                                              OUTPUT tel_vlmaidep,
                                              OUTPUT tel_vlmaiapl,
                                              OUTPUT tel_vlmaicot,
                                              OUTPUT tel_vlmaisal,
                                              OUTPUT tel_vlsldneg,
                                              OUTPUT TABLE tt-erro).
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    DELETE PROCEDURE h-b1wgen0132.
            
                    CLEAR FRAME f_tab007.
            
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAILABLE tt-erro  THEN
                        MESSAGE tt-erro.dscritic.
            
                    LEAVE.
                END.
            
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                DO:
                    DISPLAY tel_vlmaidep tel_vlmaiapl tel_vlmaicot 
                            tel_vlmaisal tel_vlsldneg WITH FRAME f_tab007.
                    LEAVE.
                END.
            
            UPDATE tel_vlmaidep tel_vlmaiapl tel_vlmaicot 
                   tel_vlmaisal tel_vlsldneg WITH FRAME f_tab007
                EDITING:
                    READKEY PAUSE 1.
         
                    IF (KEYFUNCTION(LASTKEY) = "END-ERROR") THEN
                        DELETE PROCEDURE h-b1wgen0132.

                    APPLY LASTKEY.
                END.
                
            ASSIGN aux_confirma = "N".
            RUN fontes/confirma.p (INPUT  "",
                                   OUTPUT aux_confirma).
            
            IF  aux_confirma = "S" THEN
                DO:
                    RUN altera_tab007 IN h-b1wgen0132 (INPUT glb_cdcooper,
                                                       INPUT 0, /* Agencia*/
                                                       INPUT 0, /* Caixa  */
                                                       INPUT glb_cdoperad,
                                                       INPUT "tab007",
                                                       INPUT 1, /* Ayllos */
                                                       INPUT glb_dtmvtolt, 
                                                       INPUT TRUE, /* Gerar log */
                                                       INPUT glb_dsdepart,
                                                       INPUT tel_vlmaidep,
                                                       INPUT tel_vlmaiapl,
                                                       INPUT tel_vlmaicot,
                                                       INPUT tel_vlmaisal,
                                                       INPUT tel_vlsldneg,
                                                       OUTPUT TABLE tt-erro).
                    
                    DELETE PROCEDURE h-b1wgen0132.
                    
                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            CLEAR FRAME f_tab007.
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                            IF  AVAILABLE tt-erro  THEN
                                MESSAGE tt-erro.dscritic.

                            LEAVE.    
                       
                        END.  
                END.
            ELSE
                DO:
                    DELETE PROCEDURE h-b1wgen0132.
                    NEXT.
                END.
        END.
   
    IF  glb_cddopcao = "C" THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0132.p 
                PERSISTENT SET h-b1wgen0132.
                
            RUN busca_tab007 IN h-b1wgen0132 (INPUT glb_cdcooper,
                                              INPUT 0, /* Agencia*/
                                              INPUT 0, /* Caixa  */
                                              INPUT glb_cdoperad,
                                              OUTPUT tel_vlmaidep,
                                              OUTPUT tel_vlmaiapl,
                                              OUTPUT tel_vlmaicot,
                                              OUTPUT tel_vlmaisal,
                                              OUTPUT tel_vlsldneg,
                                              OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0132.

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    CLEAR FRAME f_tab007.
            
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAILABLE tt-erro  THEN
                        MESSAGE tt-erro.dscritic.

                    NEXT.
                END.

            DISPLAY tel_vlmaidep tel_vlmaisal tel_vlsldneg
                    tel_vlmaiapl tel_vlmaicot WITH FRAME f_tab007.

        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
