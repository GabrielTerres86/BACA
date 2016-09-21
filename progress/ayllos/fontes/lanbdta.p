/* .............................................................................

   Programa: Fontes/lanbdta.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Junho/2009                    Ultima atualizacao: 09/07/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela LANBDT.

   Alteracoes: 09/07/2012 - Filtragem de Títulos por Tipo de Cobrança, permitindo a 
                            inclusão de Títulos com Cobrança Registrada no Borderô
                          - Chamada da procedure 'valida-titulos-bordero' 
                          - Chamada da Procedure 'busca_dados_exclusao_bordero'
                            substituida por 'busca_dados_validacao_bordero' (Lucas).
                          
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_lanbdt.i }

DEF VAR h-b1wgen0001 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0030 AS HANDLE                                      NO-UNDO.
DEF VAR h-browse     AS HANDLE                                      NO-UNDO.

DEF VAR aux_flgok    AS LOGICAL                                     NO-UNDO.
DEF VAR aux_flgalter AS LOGICAL                                     NO-UNDO.
DEF VAR aux_vlutiliz AS DECIMAL                                     NO-UNDO.

ASSIGN tel_nmcustod = ""
       tel_nrcustod = 0.

b_browse:HELP = "Pressione ENTER para incluir o titulo ou F4/END para SAIR.".

ON "RETURN" OF b_browse IN FRAME f_browse DO:

    IF  NOT AVAILABLE tt-titulos  THEN
        DO:
            MESSAGE "Titulo nao encontrado.".
            RETURN.
        END.
             
    RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.
    IF  NOT VALID-HANDLE(h-b1wgen0030) THEN    
        DO:
            MESSAGE "Handle invalido para b1wgen0030".
            LEAVE.
        END.
        
    RUN valida-titulo-bordero IN h-b1wgen0030
                                 (INPUT glb_cdcooper,
                                  INPUT tel_cdagenci,
                                  INPUT 0,
                                  INPUT glb_cdoperad,
                                  INPUT tel_dtmvtolt,
                                  INPUT 1,
                                  INPUT tt-titulos.nrcnvcob,
                                  INPUT tt-titulos.nrdocmto,
                                  INPUT aux_vlutiliz,
                                  INPUT tt-dados_validacao.vllimite,
                                  INPUT TABLE tt-titulos,
                                  INPUT TABLE tt-dados_dsctit,
                                  INPUT TABLE tt-dados_dsctit_cr,
                                  OUTPUT TABLE tt-erro).
    
    DELETE PROCEDURE h-b1wgen0030.
        
    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro THEN
                MESSAGE tt-erro.dscritic.
            ELSE
                MESSAGE "Numero do lote esta incorreto.".
    
            RETURN.
        END.
    ELSE
        ASSIGN aux_vlutiliz = aux_vlutiliz + tt-titulos.vltitulo.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        ASSIGN aux_confirma = "N".
        MESSAGE "Confirma inclusao de um novo titulo no bordero?" 
                UPDATE aux_confirma.
        LEAVE.
    END.       

    IF  aux_confirma <> "S"  THEN
        DO:
            aux_vlutiliz = aux_vlutiliz - tt-titulos.vltitulo.
            LEAVE.
        END.
        
    /* Somente altera dados do lote se a data da alteracao for a mesma
       data do sistema, exclusao segue a mesma ideia */
    IF  tel_dtmvtolt = glb_dtmvtolt  THEN
        ASSIGN tel_qtcompln = tel_qtcompln + 1
               tel_vlcompdb = tel_vlcompdb + tt-titulos.vltitulo
               tel_vlcompcr = tel_vlcompcr + tt-titulos.vltitulo
               tel_qtdifeln = tel_qtcompln - tel_qtinfoln
               tel_vldifedb = tel_vlcompdb - tel_vlinfodb
               tel_vldifecr = tel_vlcompcr - tel_vlinfocr.    
    
    DISPLAY tel_qtinfoln tel_qtcompln tel_vlinfodb tel_vlcompdb 
            tel_vlinfocr tel_vlcompcr tel_qtdifeln tel_vldifedb
            tel_vldifecr WITH FRAME f_lanbdt.
    
    ASSIGN tt-titulos.flgstats = 1
           aux_flgalter = TRUE
           aux_ultlinha = CURRENT-RESULT-ROW("q_browse").
        
    CLOSE QUERY q_browse.
    
    OPEN QUERY q_browse FOR EACH tt-titulos WHERE tt-titulos.flgstats = 0.
    
    REPOSITION q_browse TO ROW aux_ultlinha.
    
END.

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
                                     INPUT "A",
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
       aux_vlutiliz = tt-dados_validacao.vlutiliz
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
              
DISPLAY tel_qtinfoln tel_qtcompln tel_vlinfodb tel_vlcompdb tel_vlinfocr
        tel_vlcompcr tel_qtdifeln tel_vldifedb tel_vldifecr                    
        tel_nrcustod tel_nmcustod tel_nrborder WITH FRAME f_lanbdt.

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

IF  aux_tpcobran = "T" THEN
    DO:
        ASSIGN tel_tpcobran = "TODOS".
        tel_tpcobran:HELP = "'R' Cobranca Registrada, 'S' Cobranca S/ Registro, 'T' todos.".
        UPDATE tel_tpcobran WITH FRAME f_lanbdt.
    END.     
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
   
DISPLAY tel_tpcobran WITH FRAME f_lanbdt.

ASSIGN aux_flgok    = FALSE
       aux_flgalter = FALSE.

DO WHILE TRUE:
 
    RUN fontes/inicia.p.
 
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
        IF   glb_cdcritic > 0 THEN
             DO:
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                glb_cdcritic = 0.
             END.
        
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
            RUN sistema/generico/procedures/b1wgen0030.p 
                PERSISTENT SET h-b1wgen0030.
                
            IF NOT VALID-HANDLE(h-b1wgen0030) THEN    
               DO:
                   MESSAGE "Handle invalido para b1wgen0030".
                   LEAVE.
               END.
               
            RUN busca_titulos IN h-b1wgen0030(INPUT glb_cdcooper,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT glb_cdoperad,
                                              INPUT glb_dtmvtolt,
                                              INPUT 1, /*idorigem*/
                                              INPUT tel_nrcustod,
                                              INPUT aux_tpcobran,
                                              OUTPUT TABLE tt-titulos,
                                              OUTPUT TABLE tt-dados_dsctit,
                                              OUTPUT TABLE tt-dados_dsctit_cr,
                                              OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0030.
            
            IF NOT CAN-FIND(FIRST tt-titulos) THEN
               DO:
                   MESSAGE "Sem registro de titulos para incluir.".
                   LEAVE.
               END.
            
            FIND FIRST tt-dados_dsctit NO-LOCK NO-ERROR.
            
            CLOSE QUERY q_browse.
            
            OPEN QUERY q_browse FOR EACH tt-titulos WHERE tt-titulos.flgstats = 0.
            
            UPDATE b_browse WITH FRAME f_browse.
            
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR aux_flgok  THEN 
                LEAVE.
            
            HIDE FRAME f_lanctos.
            
            LEAVE.
            
        END.  /*  Fim do DO WHILE TRUE  */
       
        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" AND aux_flgalter THEN
            DO:
                ASSIGN aux_flgok = TRUE.
                
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE.
                    ASSIGN glb_cdcritic = 78
                           aux_confirma = "N".
                    RUN fontes/critic.p.
                    BELL.
                    ASSIGN glb_cdcritic = 0.
                    MESSAGE glb_dscritic UPDATE aux_confirma.
                    LEAVE.
                END.
                IF  aux_confirma = "N"  THEN 
                    DO:
                        ASSIGN tel_qtinfoln = 0
                               tel_qtcompln = 0
                               tel_vlinfodb = 0
                               tel_vlcompdb = 0
                               tel_vlinfocr = 0
                               tel_vlcompcr = 0
                               tel_qtdifeln = 0
                               tel_vldifedb = 0
                               tel_vldifecr = 0.
                        
                        LEAVE.
                    END.  

                RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.
                IF  NOT VALID-HANDLE(h-b1wgen0030) THEN    
                    DO:
                        MESSAGE "Handle invalido para b1wgen0030".
                        LEAVE.
                    END.
                
                RUN efetua_alteracao_bordero IN h-b1wgen0030
                                               (INPUT glb_cdcooper,
                                                INPUT tel_cdagenci,
                                                INPUT 0, /*nrdcaixa*/
                                                INPUT glb_cdoperad,
                                                INPUT glb_dtmvtolt,
                                                INPUT 1, /*idorigem*/
                                                INPUT tel_nrcustod,
                                                INPUT tel_nrborder,
                                                INPUT tel_qtcompln, /*quantidade de titulos */
                                                INPUT tel_vlcompdb, /*valor total de titulos*/
                                                INPUT TABLE tt-titulos,
                                               OUTPUT TABLE tt-erro).
                
                DELETE PROCEDURE h-b1wgen0030.
                
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        IF  AVAIL tt-erro  THEN
                            DO:
                                MESSAGE tt-erro.dscritic.
                                LEAVE.
                            END.
                        ELSE
                            DO:
                                MESSAGE "Ocorreu erro na alteracao do bordero.".
                                LEAVE.
                            END.    
                    END.
               
                LEAVE.
            END.
       
        IF  VALID-HANDLE(h-b1wgen0030)  THEN
            DELETE PROCEDURE h-b1wgen0030.
        
        LEAVE.    
 
    END.  /*  Fim do DO WHILE TRUE  */
    LEAVE.
 
END.   /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
