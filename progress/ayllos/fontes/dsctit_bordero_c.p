/* .............................................................................

   Programa: Fontes/dsctit_bordero_c.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2008                  Ultima atualizacao: 23/08/2012  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para consultar os borderos de descontos de titulos.

   Alteracoes: 23/08/2012 - Adicionado parametro 'nrdconta' na chamada do
                            fonte 'dsctit_bordero_m.p' (Lucas).
    
............................................................................. */

DEF INPUT PARAM par_nrborder AS INTE NO-UNDO.

DEF STREAM str_1.

{ includes/var_online.i }
{ includes/var_atenda.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ includes/var_dsctit.i }

DEF VAR tel_qtcheque AS INT                                          NO-UNDO.
DEF VAR tel_vlcheque AS DECIMAL                                      NO-UNDO.
DEF VAR tel_dsdlinha AS CHAR                                         NO-UNDO.
DEF VAR tel_dspesqui AS CHAR                                         NO-UNDO.
DEF VAR tel_dsopedig AS CHAR                                         NO-UNDO.
DEF VAR tel_dsopelib AS CHAR                                         NO-UNDO.
DEF VAR rel_nmcheque AS CHAR                                         NO-UNDO.
DEF VAR rel_dscpfcgc AS CHAR                                         NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                         NO-UNDO.

DEF VAR h-b1wgen0030 AS HANDLE NO-UNDO.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.
   
    IF  NOT VALID-HANDLE(h-b1wgen0030)  THEN
        DO:
            MESSAGE "Handle Invalido para h-b1wgen0030".
            
            RETURN.
        END.
    ELSE
        DO:
            RUN busca_dados_bordero IN h-b1wgen0030
                                    (INPUT glb_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT glb_cdoperad,
                                     INPUT glb_dtmvtolt,
                                     INPUT 1,
                                     INPUT tel_nrdconta,
                                     INPUT par_nrborder,
                                     INPUT "C",
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-dsctit_dados_bordero).
            
            DELETE PROCEDURE h-b1wgen0030.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
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
            opc_dsimprim 
            opc_dsvisual  
            WITH FRAME f_bordero.
   
    NEXT-PROMPT opc_dsvisual WITH FRAME f_bordero.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
        CHOOSE FIELD opc_dsimprim opc_dsvisual 
            WITH FRAME f_bordero.

        IF  FRAME-VALUE = opc_dsimprim   THEN
            RUN fontes/dsctit_bordero_m.p (INPUT tel_nrdconta,
                                           INPUT par_nrborder).
        ELSE
        IF  FRAME-VALUE = opc_dsvisual   THEN
            RUN fontes/dsctit_bordero_vt.p (INPUT par_nrborder,
                                            INPUT tel_nrdconta).
   
   END.  /*  Fim do DO WHILE TRUE  */

   LEAVE.
   
END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_bordero.

/* .......................................................................... */
