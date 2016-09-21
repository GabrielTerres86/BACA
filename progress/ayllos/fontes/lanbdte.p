/* .............................................................................

   Programa: Fontes/lanbdte.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Setembro/2008                    Ultima atualizacao: 09/07/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela LANBDT.

   Alteracoes: 09/07/2012 - Exibir Tipo de Cobrança
                          - Chamada da Procedure 'busca_dados_exclusao_bordero'
                            substituida por 'busca_dados_validacao_bordero'
                          - Adicionada funcionalidade de exclusão
                            do Borderô inteiro (Lucas).

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

ASSIGN tel_nmcustod = ""
       tel_nrcustod = 0.

b_browse:HELP = "Pressione ENTER para excluir o titulo ou F4/END para SAIR.".

ON "RETURN" OF b_browse IN FRAME f_browse DO:

    IF  NOT AVAILABLE tt-titulos  THEN
        RETURN.
             
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        ASSIGN aux_confirma = "N".
        MESSAGE "Confirma exclusao?" UPDATE aux_confirma.
        LEAVE.
    END.       

    IF  aux_confirma <> "S"  THEN
        LEAVE.
        
    IF  tel_dtmvtolt = glb_dtmvtolt  THEN
        ASSIGN tel_qtinfoln = tt-dados_validacao.qtinfoln
               tel_qtcompln = tel_qtcompln - 1
               tel_vlinfodb = tt-dados_validacao.vlinfodb 
               tel_vlcompdb = tel_vlcompdb - tt-titulos.vltitulo
               tel_vlinfocr = tt-dados_validacao.vlinfocr  
               tel_vlcompcr = tel_vlcompcr - tt-titulos.vltitulo
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
                                     INPUT "E",
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

/* Exclusão do borderô inteiro */
PAUSE(0).
DO  WHILE TRUE ON ENDKEY UNDO, RETURN:
        
    ASSIGN aux_confirma = "N".
    UPDATE aux_confirma WITH FRAME f_lanbdt_e.

    IF  aux_confirma = "S" THEN 
        DO:
            ASSIGN aux_confirma = "N".
            RUN fontes/confirma.p (INPUT  "",
                                   OUTPUT aux_confirma).
                
            IF  aux_confirma = "S" THEN 
                DO:
                    RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.
                    IF  NOT VALID-HANDLE(h-b1wgen0030) THEN    
                        DO:
                            MESSAGE "Handle invalido para b1wgen0030".
                            LEAVE.
                        END.

                    /* Obtem todos os títulos do lote */
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

                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            DELETE PROCEDURE h-b1wgen0030.
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            IF  AVAIL tt-erro  THEN
                                DO:
                                    BELL.
                                    MESSAGE tt-erro.dscritic.
                                    LEAVE.
                                END.    
                        END.

                    /* Elimina Títulos, Borderô e Lote */
                    RUN excluir-bordero-inteiro IN h-b1wgen0030 (INPUT glb_cdcooper,
                                                                 INPUT tel_cdagenci,
                                                                 INPUT 0, /* Caixa */
                                                                 INPUT glb_cdoperad,
                                                                 INPUT glb_dtmvtolt,
                                                                 INPUT 1, /* Ayllos */
                                                                 INPUT tel_nrcustod,
                                                                 INPUT tel_cdbccxlt,
                                                                 INPUT tel_nrdolote,
                                                                 INPUT glb_dtmvtolt,
                                                                 INPUT TABLE tt-titulos,
                                                                 OUTPUT TABLE tt-erro).
                  
                    DELETE PROCEDURE h-b1wgen0030.
   
                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            IF  AVAIL tt-erro  THEN
                                DO:
                                    BELL.
                                    MESSAGE tt-erro.dscritic.
                                    LEAVE.
                                END.    
                        END.
                    ELSE
                        DO:
                            MESSAGE "Bordero excluido com sucesso.".
                            HIDE FRAME f_lanbdt_e.
                            RETURN.
                        END.
                END.
        END.
        
    HIDE FRAME f_lanbdt_e.   
    LEAVE.
END.
              
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
         
         IF NOT CAN-FIND(FIRST tt-titulos) THEN
            DO:
                MESSAGE "Sem registro de titulos para exclusao.".
                LEAVE.
            END.

         CLOSE QUERY q_browse.
         
         OPEN QUERY q_browse FOR EACH tt-titulos WHERE tt-titulos.flgstats = 0.

         IF  KEYFUNCTION(LASTKEY) = "END-ERROR" OR aux_flgok  THEN 
             LEAVE.

         UPDATE b_browse WITH FRAME f_browse.

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

            RUN sistema/generico/procedures/b1wgen0030.p 
                 PERSISTENT SET h-b1wgen0030.

            IF  NOT VALID-HANDLE(h-b1wgen0030) THEN    
                DO:
                    MESSAGE "Handle invalido para b1wgen0030".
                    LEAVE.
                END.
            
            RUN efetua_exclusao_tit_bordero IN h-b1wgen0030
                                              (INPUT glb_cdcooper,
                                               INPUT tel_cdagenci,
                                               INPUT 0, /*nrdcaixa*/
                                               INPUT glb_cdoperad,
                                               INPUT tel_dtmvtolt,
                                               INPUT 1, /*idorigem*/
                                               INPUT tel_nrcustod,
                                               INPUT tel_cdbccxlt,
                                               INPUT tel_nrdolote,
                                               INPUT glb_dtmvtolt,
                                               INPUT TABLE tt-titulos,
                                              OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0030.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    IF  AVAIL tt-erro  THEN
                        DO:
                            MESSAGE glb_dscritic.
                            LEAVE.
                        END.
                    ELSE
                        DO:
                            MESSAGE "Ocorreu erro na exclusao do titulo.".
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
