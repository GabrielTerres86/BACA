/* .............................................................................

   Programa: Fontes/lanbdtc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Setembro/2008                    Ultima atualizacao: 09/07/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela LANBDT.

   Alteracoes: 09/07/2012 - Exibir Tipo de Cobrança
                          - Chamada da Procedure 'busca_dados_consulta_bordero'
                            substituida por 'busca_dados_validacao_bordero' (Lucas).

............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_lanbdt.i }

DEF VAR h-b1wgen0001 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0030 AS HANDLE                                      NO-UNDO.
DEF VAR h-browse     AS HANDLE                                      NO-UNDO.

ASSIGN tel_nmcustod = ""
       tel_nrcustod = 0.

b_browse:HELP = "Utilize as SETAS para navegar ou F4/END para SAIR.".

RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.
             
IF  NOT VALID-HANDLE(h-b1wgen0030) THEN    
    DO:
        MESSAGE "Handle invalido para b1wgen0030".
        LEAVE.
    END.

RUN busca_dados_validacao_bordero IN h-b1wgen0030
                                    (INPUT glb_cdcooper,
                                     INPUT tel_cdagenci, 
                                     INPUT 0, /*nrdcaixa*/
                                     INPUT glb_cdoperad,
                                     INPUT tel_dtmvtolt,
                                     INPUT 1, /*idorigem*/
                                     INPUT 0, /*nrdconta*/
                                     INPUT tel_cdbccxlt,
                                     INPUT tel_nrdolote,
                                     INPUT "C",
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-dados_validacao).

DELETE PROCEDURE h-b1wgen0030.
                         
IF  RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        IF  AVAIL tt-erro THEN
            DO:
                MESSAGE tt-erro.dscritic.
                RETURN.
            END.
        ELSE
            RETURN.
    END.            

FIND FIRST tt-dados_validacao NO-LOCK NO-ERROR.

ASSIGN tel_nrcustod = tt-dados_validacao.nrcustod
       tel_nmcustod = tt-dados_validacao.nmcustod
       tel_nrborder = tt-dados_validacao.nrborder
       tel_qtinfoln = tt-dados_validacao.qtinfoln
       tel_qtcompln = tt-dados_validacao.qtcompln
       tel_vlinfodb = tt-dados_validacao.vlinfodb 
       tel_vlcompdb = tt-dados_validacao.vlcompdb
       tel_vlinfocr = tt-dados_validacao.vlinfocr  
       tel_vlcompcr = tt-dados_validacao.vlcompcr
       tel_qtdifeln = tt-dados_validacao.qtcompln - tt-dados_validacao.qtinfoln
       tel_vldifedb = tt-dados_validacao.vlcompdb - tt-dados_validacao.vlinfodb
       tel_vldifecr = tt-dados_validacao.vlcompcr - tt-dados_validacao.vlinfocr.

/* Executa procedure de tipos de cobrança disponiveis */
RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.
IF  NOT VALID-HANDLE(h-b1wgen0030) THEN    
    DO:
        MESSAGE "Handle invalido para b1wgen0030".
        LEAVE.
    END.

RUN busca_tipos_cobranca IN h-b1wgen0030
                           (INPUT glb_cdcooper,
                            INPUT 0,
                            INPUT 0,
                            INPUT glb_cdoperad,
                            INPUT glb_dtmvtolt,
                            INPUT 1,
                            INPUT tel_nrcustod,
                            OUTPUT aux_tpcobran).

DELETE PROCEDURE h-b1wgen0030.

DISPLAY tel_nrcustod tel_nmcustod tel_nrborder tel_tpcobran WITH FRAME f_lanbdt.

IF  aux_tpcobran = "T" THEN
    ASSIGN tel_tpcobran = "TODOS".
ELSE
    IF  aux_tpcobran = "S" THEN
        ASSIGN tel_tpcobran = "SEM REGISTRO".
ELSE    
    IF  aux_tpcobran = "R" THEN
        ASSIGN tel_tpcobran = "REGISTRADA".

IF  tel_tpcobran <> "SEM REGISTRO" THEN
    DO:
        /* Habilitar coluna do Browse */
        h-browse = b_browse:ADD-LIKE-COLUMN("tt-titulos.tpcobran",1).
        h-browse:LABEL = "Tipo Cob.".
    END.
   
DISPLAY tel_qtinfoln tel_qtcompln tel_vlinfodb tel_vlcompdb tel_vlinfocr
        tel_vlcompcr tel_qtdifeln tel_vldifedb tel_vldifecr                    
        tel_nrcustod tel_nmcustod tel_nrborder tel_tpcobran WITH FRAME f_lanbdt.

RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.
IF  NOT VALID-HANDLE(h-b1wgen0030) THEN    
    DO:
        MESSAGE "Handle invalido para b1wgen0030".
        LEAVE.
    END.

RUN busca_titulos_bordero_lote IN h-b1wgen0030 
                                 (INPUT glb_cdcooper,
                                  INPUT tel_cdagenci,
                                  INPUT 0, /*nrdcaixa*/
                                  INPUT glb_cdoperad,
                                  INPUT tel_dtmvtolt,
                                  INPUT 1, /*cdorigem*/
                                  INPUT tel_nrcustod,
                                  INPUT tel_cdbccxlt,
                                  INPUT tel_nrdolote,
                                  INPUT glb_cddopcao,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT TABLE tt-titulos).

DELETE PROCEDURE h-b1wgen0030.
         
IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        IF  AVAIL tt-erro THEN
            DO:
                MESSAGE tt-erro.dscritic.
                LEAVE.
            END.
        ELSE
            DO:            
                MESSAGE "Ocorrreu um erro ao tentar encontrar titulos.".
                LEAVE.
            END.
    END.

IF  NOT CAN-FIND(FIRST tt-titulos) THEN
    DO:
        MESSAGE "Sem registro de titulos neste lote.".
        LEAVE.
    END.

CLOSE QUERY q_browse.
         
OPEN QUERY q_browse FOR EACH tt-titulos.
         
UPDATE b_browse WITH FRAME f_browse.

HIDE FRAME f_lanctos.

LEAVE.
      
/* .......................................................................... */
