/* .............................................................................

   Programa: Fontes/dsctit_bordero_e.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2008                   Ultima atualizacao: 13/07/2009    

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para excluir os borderos de descontos de de titulos.

   Alteracoes: 13/07/2009 - Log para exclusao de bordero (Guilherme).
    
............................................................................. */

DEF INPUT PARAM par_nrborder AS INTE NO-UNDO.

{ includes/var_online.i }
{ includes/var_atenda.i } 
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_dsctit.i }

DEF VAR h-b1wgen0030 AS HANDLE NO-UNDO.

RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.

IF  NOT VALID-HANDLE(h-b1wgen0030)  THEN
    DO:
        MESSAGE "Handle invalido para b1wgen0030".
        RETURN.
    END.

RUN busca_dados_bordero IN h-b1wgen0030 (INPUT glb_cdcooper,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT glb_cdoperad,
                                         INPUT glb_dtmvtolt,
                                         INPUT 1,
                                         INPUT tel_nrdconta,
                                         INPUT par_nrborder,
                                         INPUT "E",
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-dsctit_dados_bordero).
            
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0030.
        
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
        IF  AVAILABLE tt-erro  THEN
            DO:
                MESSAGE tt-erro.dscritic.
                       
                RETURN.
            END.                
        ELSE
            DO:
                MESSAGE "Bordero nao encontrado".
                            
                RETURN.
            END.
    END.
    
FIND FIRST tt-dsctit_dados_bordero NO-LOCK NO-ERROR.
    
DISPLAY tt-dsctit_dados_bordero.dspesqui                     
        tt-dsctit_dados_bordero.nrborder 
        tt-dsctit_dados_bordero.nrctrlim 
        tt-dsctit_dados_bordero.dsdlinha      
        tt-dsctit_dados_bordero.qttitulo      
        tt-dsctit_dados_bordero.dsopedig 
        tt-dsctit_dados_bordero.vltitulo      
        tt-dsctit_dados_bordero.txmensal  
        tt-dsctit_dados_bordero.dtlibbdt
        tt-dsctit_dados_bordero.txdiaria  
        tt-dsctit_dados_bordero.dsopelib      
        tt-dsctit_dados_bordero.txjurmor 
        WITH FRAME f_bordero2.    

DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
    ASSIGN aux_confirma = "N"
           glb_cdcritic = 78.
    RUN fontes/critic.p.
    BELL.
    MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
    ASSIGN glb_cdcritic = 0.
    LEAVE.
END.

IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
    aux_confirma <> "S" THEN
    DO:
        DELETE PROCEDURE h-b1wgen0030.
        ASSIGN glb_cdcritic = 79.
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic.
        ASSIGN glb_cdcritic = 0.
        HIDE FRAME f_bordero2.
        RETURN.
    END.

RUN efetua_exclusao_bordero IN h-b1wgen0030 
                        (INPUT glb_cdcooper,
                         INPUT 0,
                         INPUT 0,
                         INPUT glb_cdoperad,
                         INPUT glb_dtmvtolt,
                         INPUT 1,
                         INPUT tel_nrdconta,
                         INPUT 1, /* idseqttl */
                         INPUT "ATENDA",
                         INPUT par_nrborder,
                         INPUT TRUE,
                         INPUT TRUE, /* LOG */
                        OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0030.
HIDE FRAME f_bordero2.

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
        IF  AVAIL tt-erro  THEN
            DO:
                MESSAGE tt-erro.dscritic.
                RETURN.
            END.
    END.

/* .......................................................................... */
