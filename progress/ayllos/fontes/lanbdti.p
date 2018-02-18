/* .............................................................................

   Programa: Fontes/lanbdti.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Setembro/2008                    Ultima atualizacao: 10/03/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela LANBDT.

   Alteracoes: 17/02/2009 - Comentado critica de valor excedido 
               17/03/2009 - Descomentado a critica de valor excedido(Guilherme).
              
               06/04/2009 - Inclusao da tt-dados_cecred_dsctit nos
                            parametros da busca_parametros_dsctit(Guilherme).
                            
               19/10/2010 - Mostrar critica da temp-table em caso de erro na
                            procedure efetua_inclusao_bordero (David).
              
               27/06/2012 - Incluido novo parametro na busca_parametros_dsctit
                            (David Kruger).
                            
               11/10/2012 - Filtragem de Títulos por Tipo de Cobrança, permitindo a 
                            inclusão de Títulos com Cobrança Registrada no Borderô
                          - Chamada da procedure 'valida-titulo-bordero' 
                          - Críticar caso o sacado possuir títulos em cartório
                            ou protestados (Lucas).
                            
               01/12/2014 - Incluir chamada da procedure valida_situacao_pa
                            Softdesk 100471 (Lucas R./Rodrigo)
                
               05/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                            Cedente por Beneficiário e  Sacado por Pagador 
                            Chamado 229313 (Jean Reddiga - RKAM).    
                            
               11/05/2015 - #278936 Inclusao de busca de cooperado com atalho
                            na tecla F7; Inclusao de filtro por nome do pagador
                            (Carlos)
                           
			   10/03/2017 - Ajuste devido ao tratamento para validar se o titulo ja esta
			                incluso em um bordero
							(Adriano - SD 603451).
			          
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_lanbdt.i }

PAUSE 0.

DEF VAR h-b1wgen0030 AS HANDLE                                      NO-UNDO.
DEF VAR h-browse     AS HANDLE                                      NO-UNDO.

DEF VAR aux_flgok    AS LOGICAL INIT TRUE                           NO-UNDO.
DEF VAR aux_flgalter AS LOGICAL                                     NO-UNDO.
DEF VAR aux_vlutiliz AS DECIMAL                                     NO-UNDO.
DEF VAR aux_qttitpro AS INTEGER                                     NO-UNDO.
DEF VAR aux_qttitcar AS INTEGER                                     NO-UNDO.

DEF QUERY q-criticas FOR tt-erro.

DEF BROWSE b-criticas QUERY q-criticas
    DISPLAY tt-erro.dscritic format "x(48)"
    WITH 5 DOWN WIDTH 50 NO-BOX NO-LABELS OVERLAY.

FORM b-criticas                            
     HELP "Pressione ENTER, F4/END para sair"
     WITH ROW 9 CENTERED NO-LABELS OVERLAY WIDTH 55 TITLE COLOR NORMAL " Inconsistencias " FRAME f_criticas.

ASSIGN tel_nmcustod = ""
       tel_nrcustod = 0
       b_browse:HELP = "Pressione ENTER para incluir o titulo ou F4/END para" +
                       " SAIR.".

ON "END-ERROR" OF b_browse IN FRAME f_browse DO:
    
    IF  NOT aux_flgalter  THEN
        DO:
            ASSIGN tel_nrcustod = 0
                   tel_nmcustod = ""
                   tel_nmdopaga = "".
                   
            DISPLAY tel_nrcustod tel_nmcustod tel_nmdopaga WITH FRAME f_lanbdt.       
            LEAVE.
        END.    
        
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE.
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
                   tel_vldifecr = 0
                   tel_nrcustod = 0
                   tel_nmcustod = "".
                   
            DISPLAY tel_qtinfoln tel_qtcompln tel_vlinfodb tel_vlcompdb 
                    tel_vlinfocr tel_vlcompcr tel_qtdifeln tel_vldifedb
                    tel_vldifecr tel_nrcustod tel_nmcustod tel_tpcobran
                    WITH FRAME f_lanbdt.                   
            
            LEAVE.
        END.    
            
    RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.
    IF  NOT VALID-HANDLE(h-b1wgen0030) THEN    
        DO:
            MESSAGE "Handle invalido para b1wgen0030".
            LEAVE.
        END.

    RUN efetua_inclusao_bordero IN h-b1wgen0030
                                (INPUT glb_cdcooper,
                                 INPUT tel_cdagenci,
                                 INPUT 0, /*nrdcaixa*/
                                 INPUT glb_cdoperad,
                                 INPUT glb_dtmvtolt,
                                 INPUT 1, /*idorigem*/
                                 INPUT tel_nrcustod,
                                 INPUT tel_cdbccxlt,
                                 INPUT tel_nrdolote,
                                 INPUT tel_qtinfoln, /*quantidade de titulos */
                                 INPUT tel_vlinfodb, /*valor total de titulos*/
                                 INPUT TABLE tt-titulos,
                                OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0030.
            
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro  THEN
                DO:
				    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          
						OPEN QUERY q-criticas FOR EACH tt-erro	NO-LOCK.
                              
						UPDATE b-criticas
								WITH FRAME f_criticas.
                   
						LEAVE.
                   
					END.
                   
					CLOSE QUERY q-criticas.
					HIDE FRAME f_criticas.
                   
				END.
            ELSE
                MESSAGE "Ocorreu erro na inclusao de titulos.".

        END.
END.

ON "RETURN" OF b_browse IN FRAME f_browse DO:

    IF  NOT AVAILABLE tt-titulos  THEN
        DO:
            MESSAGE "Titulo nao encontrado.".
            LEAVE.
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

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
            LEAVE.

        IF  tt-titulos.flgregis THEN
            DO: 
                /* Realiza validações */
                RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.
                IF  NOT VALID-HANDLE(h-b1wgen0030) THEN    
                    DO:
                        MESSAGE "Handle invalido para b1wgen0030".
                        LEAVE.
                    END.

                /* Conta títulos remetidos ao cartório pelo cedente para aquele sacado */
                RUN retorna-titulos-ocorrencia IN h-b1wgen0030 (INPUT glb_cdcooper,
                                                                INPUT tel_nrcustod,        /* Conta/DV */
                                                                INPUT tt-titulos.nrinssac, /* Sacado */
                                                                INPUT 23,                  /* Ocorrência */
                                                                INPUT 0,                   /* Motivo */
                                                                INPUT FALSE,               /* Apenas tit. em bord.*/
                                                                OUTPUT aux_qttitcar,       /* Tot. Títulos */
                                                                OUTPUT TABLE tt-erro).

                /* Conta títulos protestados pelo cedente para aquele sacado */
                RUN retorna-titulos-ocorrencia IN h-b1wgen0030 (INPUT glb_cdcooper,
                                                                INPUT tel_nrcustod,        /* Conta/DV */
                                                                INPUT tt-titulos.nrinssac, /* Sacado */
                                                                INPUT 9,                   /* Ocorrência */
                                                                INPUT 14,                  /* Motivo */
                                                                INPUT FALSE,               /* Apenas tit. em bord.*/
                                                                OUTPUT aux_qttitpro,       /* Tot. Títulos */
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
                    END.

                /* Se retornarem títulos protestados ou em cartório */
                IF  aux_qttitpro > 0 OR
                    aux_qttitcar > 0 THEN
                    DO: 
                        /* Traz valores parametrizados da TAB052 */
                        RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.
                        IF  NOT VALID-HANDLE(h-b1wgen0030) THEN    
                            DO:
                                MESSAGE "Handle invalido para b1wgen0030".
                                LEAVE.
                            END.

                        /* GGS - Inicio */      
                        /* Buscar dados do Associado */
                        FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                           crapass.nrdconta = tel_nrcustod 
                                           NO-LOCK NO-ERROR.
                                           
                        IF NOT AVAIL(crapass) THEN
                            DO:
                                MESSAGE "Associado nao encontrado.".
                                RETURN  "NOK".                                
                            END.
                        /* GGS - Fim */      

                        RUN busca_parametros_dsctit IN h-b1wgen0030 (INPUT glb_cdcooper,
                                                                     INPUT 0,
                                                                     INPUT 0,
                                                                     INPUT glb_cdoperad,
                                                                     INPUT glb_dtmvtolt,
                                                                     INPUT 0,
                                                                     INPUT TRUE,             /* COB.REGISTRADA */                                                                  
                                                                     INPUT crapass.inpessoa, /* GGS - Incluido Tipo Pessoa */
                                                                     OUTPUT TABLE tt-erro,
                                                                     OUTPUT TABLE tt-dados_dsctit_cr,
                                                                     OUTPUT TABLE tt-dados_cecred_dsctit).
                                    
                        IF  RETURN-VALUE = "NOK"  THEN
                            DO:
                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                IF  AVAIL tt-erro  THEN
                                    DO:
                                        MESSAGE tt-erro.dscritic.
                                        LEAVE.
                                    END.
                            END.
                        
                        DELETE PROCEDURE h-b1wgen0030.

                        FIND FIRST tt-dados_dsctit_cr  NO-LOCK NO-ERROR NO-WAIT.

                        IF  aux_qttitcar > 0 AND
                            aux_qttitcar >= tt-dados_dsctit_cr.qtremcrt and
                            tt-dados_dsctit_cr.qtremcrt > 0 THEN
                            DO:
                                ASSIGN aux_confirma = "N".
                                MESSAGE "O Pagador possui " + STRING(aux_qttitcar) +
                                        " titulo(s) em cartorio. Confirma inclusao?" UPDATE aux_confirma.
                        
                                IF  aux_confirma <> "S"  THEN
                                    LEAVE.
                            END.
                        
                        IF  aux_qttitpro > 0 AND
                            aux_qttitpro >= tt-dados_dsctit_cr.qttitprt AND 
                            tt-dados_dsctit_cr.qttitprt > 0 THEN
                            DO:
                                ASSIGN aux_confirma = "N".
                                MESSAGE "O Pagador possui " + STRING(aux_qttitpro) +
                                        " titulo(s) protestado(s). Confirma inclusao?" UPDATE aux_confirma.
                        
                                IF  aux_confirma <> "S"  THEN
                                    LEAVE.
                            END.
                    END.
            END.

        HIDE MESSAGE NO-PAUSE.

        ASSIGN aux_confirma = "N".
        MESSAGE "Confirma inclusao?" UPDATE aux_confirma.

        LEAVE.
    END.

    IF  aux_confirma <> "S"  THEN
        DO:
            aux_vlutiliz = aux_vlutiliz - tt-titulos.vltitulo.
            LEAVE.
        END.
    
    ASSIGN tel_qtinfoln = tel_qtinfoln + 1
           tel_qtcompln = tel_qtcompln + 1
           tel_vlinfodb = tel_vlinfodb + tt-titulos.vltitulo
           tel_vlcompdb = tel_vlcompdb + tt-titulos.vltitulo
           tel_vlinfocr = tel_vlinfocr + tt-titulos.vltitulo
           tel_vlcompcr = tel_vlcompcr + tt-titulos.vltitulo
           tel_qtdifeln = 0
           tel_vldifedb = 0
           tel_vldifecr = 0.
    
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

IF  glb_cdbccxlt <> 700  THEN
    DO:
        glb_cdcritic = 584.
        RUN fontes/critic.p.
        MESSAGE glb_dscritic.
        glb_cdcritic = 0.
        RETURN.
    END.

IF  NOT VALID-HANDLE(h-b1wgen0030) THEN    
    RUN sistema/generico/procedures/b1wgen0030.p 
        PERSISTENT SET h-b1wgen0030.
    
RUN valida_situacao_pa IN h-b1wgen0030
                      (INPUT glb_cdcooper,
                       INPUT tel_cdagenci,
                       INPUT 0,
                      OUTPUT TABLE tt-erro).

IF  VALID-HANDLE(h-b1wgen0030) THEN
    DELETE PROCEDURE h-b1wgen0030.

IF  RETURN-VALUE <> "OK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  AVAIL tt-erro THEN
            MESSAGE tt-erro.dscritic.

        RETURN.
    END.

IF  NOT VALID-HANDLE(h-b1wgen0030) THEN
    RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.

RUN valida_dados_lote IN h-b1wgen0030
                        (INPUT glb_cdcooper,
                         INPUT tel_cdagenci,
                         INPUT 0,
                         INPUT glb_cdoperad,
                         INPUT tel_dtmvtolt,
                         INPUT 1,
                         INPUT tel_nrcustod,
                         INPUT tel_cdbccxlt,
                         INPUT tel_nrdolote,
                         OUTPUT TABLE tt-erro).

IF  VALID-HANDLE(h-b1wgen0030) THEN
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
    
ASSIGN aux_flgalter = FALSE.

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

            IF  glb_cdcritic > 0 THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                END.            
           
            HIDE tel_nrborder IN FRAME f_lanbdt.
         
            UPDATE tel_nrcustod WITH FRAME f_lanbdt
            EDITING:
                DO WHILE TRUE:
                    READKEY PAUSE 1.

                    IF   LASTKEY = KEYCODE("F7") THEN
                    DO:
                        RUN fontes/zoom_associados.p (INPUT  glb_cdcooper,
                                                      OUTPUT tel_nrcustod).
                        IF   tel_nrcustod > 0   THEN
                        DO:
                            DISPLAY tel_nrcustod WITH FRAME f_lanbdt.
                            PAUSE 0.
                            APPLY "RETURN".
                        END.
                    END.
                    ELSE
                        APPLY LASTKEY.
                    LEAVE.
                END.  /*  Fim do DO WHILE TRUE  */
            END.  /*  Fim do EDITING  */

/* chw */            
         
            glb_nrcalcul = tel_nrcustod.
                                   
            RUN fontes/digfun.p.
         
            IF  NOT glb_stsnrcal   THEN
                DO:
                    glb_cdcritic = 8.
                    NEXT.
                END.
         
            RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.
            IF  NOT VALID-HANDLE(h-b1wgen0030) THEN    
                DO:
                    MESSAGE "Handle invalido para b1wgen0030".
                    LEAVE.
                END.
         
            RUN valida_dados_inclusao IN h-b1wgen0030
                                        (INPUT glb_cdcooper,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT glb_cdoperad,
                                         INPUT glb_dtmvtolt,
                                         INPUT 1,
                                         INPUT tel_nrcustod,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-dados_validacao,
                                         OUTPUT TABLE tt-msg-confirma).
         
            DELETE PROCEDURE h-b1wgen0030.
         
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    IF  AVAIL tt-erro  THEN
                        DO:
                            MESSAGE tt-erro.dscritic.
                            aux_flgok = FALSE.
                            LEAVE.
                        END.
                END.
         
            FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR.

            IF  AVAIL tt-msg-confirma  THEN
                MESSAGE tt-msg-confirma.dsmensag.
         
            FIND FIRST tt-dados_validacao NO-LOCK NO-ERROR.

            IF  AVAIL tt-dados_validacao  THEN
                ASSIGN aux_vlutiliz = tt-dados_validacao.vlutiliz
                       tel_nmcustod = tt-dados_validacao.nmcustod.

            LEAVE.

        END. /* Final DO WHILE update conta */
         
        IF  NOT aux_flgok OR KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
            LEAVE.
           
        DISPLAY tel_nmcustod WITH FRAME f_lanbdt.
        
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
               tel_tpcobran:HELP = "'R' Cobranca Registrada, 'S' Cobranca S/ Registro, 'T' Todos.".
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

        UPDATE tel_nmdopaga WITH FRAME f_lanbdt.
           
        DISPLAY tel_tpcobran tel_nrcustod WITH FRAME f_lanbdt.
        
        RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.
       
        IF  NOT VALID-HANDLE(h-b1wgen0030) THEN    
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
               
        IF  NOT CAN-FIND(FIRST tt-titulos) THEN
            DO:
                MESSAGE "Sem registro de titulos para inclusao.".
                LEAVE.
            END.
       
        /* Deixa apenas os registros que atendem o filtro do nome do pagador */
        IF tel_nmdopaga <> "" THEN
        DO:
            FOR EACH tt-titulos WHERE NOT (tt-titulos.nmdsacad MATCHES "*" + tel_nmdopaga + "*"):
                DELETE tt-titulos.
            END.
        END.

        CLOSE QUERY q_browse.
        
        OPEN QUERY q_browse FOR EACH tt-titulos WHERE tt-titulos.flgstats = 0.
        
        ENABLE b_browse WITH FRAME f_browse.
        
        WAIT-FOR END-ERROR OF CURRENT-WINDOW.

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN 
            DO:
                aux_flgok = FALSE.
                LEAVE.
            END.   
        
        HIDE FRAME f_lanctos.
        
        LEAVE.
        
    END.  /*  Fim do DO WHILE TRUE  */
    LEAVE.
 
END.   /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
