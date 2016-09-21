/* .............................................................................

   Programa: Fontes/dsctit_limite_e.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2008                         Ultima atualizacao: 14/07/2009

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para excluir o limite de descontos de cheques.

   Alteracoes: 14/07/2009 - Incluir parametro de log quando efetuar (Guilherme).

............................................................................. */

DEF INPUT PARAM par_nrctrlim AS INTE        NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_dsctit.i }

DEF VAR h-b1wgen0030 AS HANDLE              NO-UNDO.

RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.

IF  NOT VALID-HANDLE(h-b1wgen0030)  THEN
    DO:
        MESSAGE "Handle Invalido para h-b1wgen0030".
        RETURN.
    END.
ELSE
    DO:
        RUN busca_dados_limite IN h-b1wgen0030 
                                       (INPUT glb_cdcooper,
                                        INPUT 0, /*agencia*/
                                        INPUT 0, /*caixa*/
                                        INPUT glb_cdoperad,
                                        INPUT glb_dtmvtolt,
                                        INPUT 1, /*origem*/
                                        INPUT tel_nrdconta,
                                        INPUT 1, /*idseqttl*/
                                        INPUT glb_nmdatela,
                                        INPUT par_nrctrlim,
                                        INPUT glb_cddopcao,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-dsctit_dados_limite,
                                        OUTPUT TABLE tt-dados_dsctit).
                                
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                DELETE PROCEDURE h-b1wgen0030.
                
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF  AVAIL tt-erro  THEN
                    DO:
                        MESSAGE tt-erro.dscritic.
                        RETURN.
                    END.
                ELSE
                    DO:
                        MESSAGE "Registro temporario nao encontrado".
                        RETURN.
                    END.
            END.
    END.

FIND tt-dsctit_dados_limite NO-LOCK NO-ERROR.

IF  NOT AVAIL tt-dsctit_dados_limite  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0030.
        MESSAGE "Registro de limite nao encontrado".
        RETURN.
    END.
        
DISPLAY tt-dsctit_dados_limite.nrctrlim  tt-dsctit_dados_limite.vllimite  
        tt-dsctit_dados_limite.qtdiavig  tt-dsctit_dados_limite.cddlinha  
        tt-dsctit_dados_limite.dsdlinha  tt-dsctit_dados_limite.txjurmor 
        tt-dsctit_dados_limite.txdmulta  tt-dsctit_dados_limite.dsramati 
        tt-dsctit_dados_limite.vlmedtit  tt-dsctit_dados_limite.vlfatura  
        tt-dsctit_dados_limite.dtcancel
        WITH FRAME f_dsctit_prolim.

HIDE tt-dsctit_dados_limite.dtcancel IN FRAME f_dsctit_prolim.

/*  Confirmacao do cancelamento  */
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   ASSIGN aux_confirma = "N"
          glb_cdcritic = 78.
   RUN fontes/critic.p.
   BELL.
   glb_cdcritic = 0.
   MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
   HIDE FRAME f_dsctit_prolim.
   LEAVE.
END.  /*  Fim do DO WHILE TRUE  */

IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma <> "S" THEN
    DO:
        DELETE PROCEDURE h-b1wgen0030.
        glb_cdcritic = 79.
        RUN fontes/critic.p.
        BELL.
        glb_cdcritic = 0.
        MESSAGE glb_dscritic.
        HIDE FRAME f_dsctit_prolim.
        RETURN.
    END.
              
RUN efetua_exclusao_limite IN h-b1wgen0030
                                       (INPUT glb_cdcooper,
                                        INPUT 0, /*agencia*/
                                        INPUT 0, /*caixa*/
                                        INPUT glb_cdoperad,
                                        INPUT glb_dtmvtolt,
                                        INPUT 1, /*origem*/
                                        INPUT tel_nrdconta,
                                        INPUT 1, /*idseqttl*/
                                        INPUT glb_nmdatela,
                                        INPUT par_nrctrlim,
                                        INPUT TRUE,
                                        OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0030.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        IF  AVAIL tt-erro  THEN
            DO:
                MESSAGE tt-erro.dscritic.
                RETURN.
            END.
        ELSE
            DO:
                MESSAGE "Nao foi possivel concluir o cancelamento".
                RETURN.
            END.

    END.

HIDE FRAME f_dsctit_prolim.

/* .......................................................................... */
