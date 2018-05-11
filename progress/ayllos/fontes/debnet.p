/*..............................................................................

   Programa: fontes/debnet.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Abril/2008                        Ultima atualizacao: 24/10/2016

   Dados referentes ao programa:

   Frequencia: Diario (On-Line).
   Objetivo  : Mostrar Tela DEBNET. Efetuar debitos de agendamentos pendentes.
   
   Alteracoes: 28/10/2009 - Acerto no browse b_agendamentos (David).
   
               28/06/2010 - Quando CECRED(3), mostrar campo cooperativa na tela
                            e processar para todas as coops. (Guilherme/Supero)
                            
               17/07/2011 - Separar relatorio gerado com as informacoes de cada 
                            cooperativa (Henrique).
                            
               05/03/2014 - Projeto Oracle - Adicionado include (Guilherme).
               
               20/11/2014 - Verificar se o processo automatico da DEBNET 
                            esta ativo e nao deixar utilizar a tela debnet
                            SD 224547 (Tiago).
                            
               09/03/2015 - Ajustes display do campo Documento.
                            (Chamado 229249 # PRJ Melhoria) - (Fabricio)
                            
               27/03/2015 - Alterado para qdo fosse mostrar o campo
                            w_agendamento.nrdocmto para mostrar o campo
                            w_agendamento.dsdocmto (SD270304 Tiago)

               27/07/2015 - Alterado para utilizar as procedures Oracle ao invés 
                            do crps509.i (Douglas - Chamado 285228 obtem-saldo-dia)
                            
               23/11/2015 - Inserido procedure gera_log_execucao para o log 
                            da execucao manual da DEBNET (Tiago SD338533).

               24/10/2016 - Inserido nova opcao na tela "S - Sumario" para contabilizar
                            os lancamentos do dia - Melhoria349 (Tiago/Elton). 
                            
               15/01/2018 - Adicionar flgativo na busca da crapcop (Lucas Ranghetti #822845)
..............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqcen AS CHAR                                           NO-UNDO.
DEF VAR aux_nmaqcesv AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.

DEF VAR aux_dtmvtopg AS DATE                                           NO-UNDO.

DEF VAR aux_flconfir AS LOGI FORMAT "S/N"                              NO-UNDO.
DEF VAR aux_flsgproc AS LOGI                                           NO-UNDO.
DEF VAR aux_flgimpri AS LOGI FORMAT "S/N"                              NO-UNDO.
DEF VAR tel_cdcooper AS CHAR        FORMAT "x(12)" VIEW-AS COMBO-BOX   
                                                   INNER-LINES 11      NO-UNDO.
DEF VAR aux_nmcooper AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcooper AS INT                                            NO-UNDO.
DEF VAR aux_cdcoopin AS INT                                            NO-UNDO.
DEF VAR aux_cdcoopfi AS INT                                            NO-UNDO.

DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_cdcritic LIKE crapcri.cdcritic                             NO-UNDO.
DEF VAR aux_dscritic LIKE crapcri.dscritic                             NO-UNDO.
DEF VAR aux_dsxmlage AS LONGCHAR                                       NO-UNDO.

DEF VAR aux_qtefetiv  AS  DECIMAL                                      NO-UNDO.
DEF VAR aux_qtnefeti  AS  DECIMAL                                      NO-UNDO.
DEF VAR aux_qtpenden  AS  DECIMAL                                      NO-UNDO.
DEF VAR aux_qttotlan  AS  DECIMAL                                      NO-UNDO.  

/* Variaveis para o XML */ 
DEF VAR xDoc          AS HANDLE   NO-UNDO.   
DEF VAR xRoot         AS HANDLE   NO-UNDO.  
DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
DEF VAR xField        AS HANDLE   NO-UNDO. 
DEF VAR xText         AS HANDLE   NO-UNDO. 
DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
DEF VAR xml_req       AS LONGCHAR NO-UNDO.

DEF TEMP-TABLE w_agendamentos                                          NO-UNDO
    FIELD cdcooper AS INTE  FORMAT "z9"
    FIELD dscooper AS CHAR  FORMAT "x(11)"
    FIELD cdagenci AS INTE  FORMAT "zz9"
    FIELD nrdconta AS INTE  FORMAT "zzzz,zzz,9"
    FIELD nmprimtl AS CHAR  FORMAT "x(40)"
    FIELD cdtiptra AS INTE  FORMAT "9"
    FIELD fltiptra AS LOGI  
    FIELD dstiptra AS CHAR  FORMAT "x(13)"
    FIELD fltipdoc AS LOGI  
    FIELD dstransa AS CHAR  FORMAT "x(32)"
    FIELD vllanaut AS DECI  FORMAT "zzz,zzz,zz9.99"
    FIELD dttransa AS DATE  FORMAT "99/99/9999"
    FIELD hrtransa AS CHAR  FORMAT "x(8)"
    FIELD nrdocmto AS DECI  FORMAT "zzz,zzz,zzz,zzz,zzz,zzz,zz9"
    FIELD dslindig AS CHAR  FORMAT "x(55)"
    FIELD dscritic AS CHAR  FORMAT "x(40)"
    FIELD fldebito AS LOGI
    FIELD dsorigem AS CHAR
    FIELD idseqttl AS INT
    FIELD dsdocmto AS CHAR FORMAT "x(27)".

DEF TEMP-TABLE w_relatorios                                            NO-UNDO
    FIELD cdcooper AS INTE 
    FIELD dsdircop AS CHAR 
    FIELD nmrelato AS CHAR.

DEF QUERY q_agendamentos FOR w_agendamentos.

DEF BROWSE b_agendamentos QUERY q_agendamentos
    DISPLAY w_agendamentos.nrdconta COLUMN-LABEL "Conta/dv"
            w_agendamentos.dstiptra COLUMN-LABEL "Tipo"
            w_agendamentos.dstransa COLUMN-LABEL "Descricao da Transacao"
            w_agendamentos.vllanaut COLUMN-LABEL "Valor"            
            WITH NO-BOX 7 DOWN.
    
FORM 
    WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela
    ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 FRAME f_moldura.

FORM glb_cddopcao AT 03 LABEL "Opcao" AUTO-RETURN
                  HELP "Informe a opcao (C,P,S)."
                  VALIDATE (CAN-DO("C,P,S",glb_cddopcao),"014 - Opcao Errada")
     tel_cdcooper AT 17 LABEL "Cooperativa"
                  HELP "Selecione a Cooperativa"
     aux_dtmvtopg AT 50 LABEL "Data Agendamento" FORMAT "99/99/9999"
     WITH NO-LABEL SIDE-LABELS COLUMN 2 ROW 6 OVERLAY NO-BOX FRAME f_opcao.
                 
FORM b_agendamentos HELP "Use as setas para navegar ou <END>/<F4> para sair."  
     WITH ROW 7 OVERLAY COLUMN 2 TITLE COLOR NORMAL " AGENDAMENTOS " 
     FRAME f_b_agendamentos.

FORM w_agendamentos.dscooper AT 07 LABEL "Cooperativa"
     w_agendamentos.dsdocmto AT 40 LABEL "Documento"
     SKIP
     w_agendamentos.dttransa AT 04 LABEL "Data Transacao"
     w_agendamentos.hrtransa AT 35 LABEL "Hora Transacao"
     SKIP
     w_agendamentos.dslindig AT 03 LABEL "Linha Digitavel"
     WITH ROW 18 SIDE-LABELS OVERLAY COLUMN 2 NO-BOX FRAME f_dados_pagto.
    
FORM w_agendamentos.dscooper AT 07 LABEL "Cooperativa"
     w_agendamentos.dsdocmto AT 40 LABEL "Documento"
     SKIP
     w_agendamentos.dttransa AT 04 LABEL "Data Transacao"
     w_agendamentos.hrtransa AT 35 LABEL "Hora Transacao"
     SKIP
     w_agendamentos.dstransa AT 05 LABEL "Conta Destino"  FORMAT "x(55)"
     WITH ROW 18 SIDE-LABELS OVERLAY COLUMN 2 NO-BOX FRAME f_dados_transf.    

FORM SKIP(1)
     aux_qtefetiv FORMAT "z,zzz,zz9"  LABEL "        Efetivados" SKIP(1)
     aux_qtnefeti FORMAT "z,zzz,zz9"  LABEL "    Nao Efetivados" SKIP(1) 
     aux_qtpenden FORMAT "z,zzz,zz9"  LABEL "         Pendentes" SKIP(1)
     aux_qttotlan FORMAT "z,zzz,zz9"  LABEL "             Total" SKIP(1)
     WITH SIDE-LABELS COLUMN 2 ROW 8 OVERLAY WIDTH 78 TITLE "SUMARIO DE AGENDAMENTOS" FRAME f_sumario.
     

ON VALUE-CHANGED, ENTRY OF b_agendamentos DO:
  
   HIDE FRAME f_dados_pagto  NO-PAUSE.
   HIDE FRAME f_dados_transf NO-PAUSE.
   HIDE FRAME f_sumario NO-PAUSE.
    
   IF   w_agendamentos.fltiptra  THEN
        DISPLAY w_agendamentos.dscooper   
                w_agendamentos.dttransa w_agendamentos.hrtransa
                w_agendamentos.dsdocmto w_agendamentos.dstransa
                WITH FRAME f_dados_transf.
   ELSE
        DISPLAY w_agendamentos.dscooper
                w_agendamentos.dttransa w_agendamentos.hrtransa
                w_agendamentos.dsdocmto w_agendamentos.dslindig
                WITH FRAME f_dados_pagto.

END.

ON RETURN OF tel_cdcooper DO:

   ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE.
   ASSIGN aux_contador = 0.
   APPLY "GO".

END.

    
    
VIEW FRAME f_moldura.

PAUSE(0).

RUN fontes/inicia.p.

ASSIGN glb_cddopcao    = "C"
       glb_cdempres    = 11
       glb_cdrelato[1] = 483
       glb_nmdestin[1] = "DESTINO: ADMINISTRATIVO"
       aux_dtmvtopg    = glb_dtmvtolt.


/* Alimenta SELECTION-LIST de COOPERATIVAS */
IF   glb_cdcooper = 3 THEN
     DO:
         FOR EACH crapcop WHERE crapcop.cdcooper <> 3 AND
                                crapcop.flgativo = TRUE NO-LOCK 
                                BY crapcop.dsdircop:
         
             IF   aux_contador = 0 THEN
                  ASSIGN aux_nmcooper = "TODAS,0," + 
                                        CAPS(crapcop.dsdircop) + "," +
                                        STRING(crapcop.cdcooper)
                         aux_contador = 1.
             ELSE
                  ASSIGN aux_nmcooper = aux_nmcooper + "," +
                                        CAPS(crapcop.dsdircop) + "," +
                                        STRING(crapcop.cdcooper).
         END.
     
         ASSIGN tel_cdcooper:LIST-ITEM-PAIRS = aux_nmcooper.

         DISPLAY glb_cddopcao tel_cdcooper aux_dtmvtopg WITH FRAME f_opcao.
     END.
ELSE
     DO:
         DISPLAY glb_cddopcao aux_dtmvtopg WITH FRAME f_opcao.
         HIDE tel_cdcooper IN FRAME f_opcao.
     END.

DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        IF   glb_cdcooper = 3 THEN
             UPDATE glb_cddopcao tel_cdcooper WITH FRAME f_opcao.
        ELSE
             UPDATE glb_cddopcao WITH FRAME f_opcao.
             
        LEAVE.
    END.
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.
            
            IF  CAPS(glb_nmdatela) <> "DEBNET"  THEN
                DO:
                    HIDE FRAME f_moldura NO-PAUSE.
                    HIDE FRAME f_opcao   NO-PAUSE.
                    HIDE FRAME f_sumario NO-PAUSE.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> INPUT glb_cddopcao  THEN
        DO:
            { includes/acesso.i }

            ASSIGN aux_cddopcao = INPUT glb_cddopcao.
        END.

    /* Verificar se o processo automatico da DEBNET está ativo 
       e nao deixar utilizar a tela debnet */
    FIND FIRST craphec WHERE craphec.dsprogra  =  "DEBNET"     AND 
                             craphec.flgativo  =  TRUE         AND
                             craphec.hriniexe  <= TIME         AND
                             craphec.hrfimexe  >= TIME         AND
                            (craphec.dtultexc  <= glb_dtmvtolt OR
                             craphec.dtultexc = ?)  NO-LOCK NO-ERROR.

    IF  AVAIL(craphec) THEN
        DO:
            ASSIGN glb_dscritic = "".

            /*Esta validação foi feita pois o programa que executa a DEBNET
              automaticamente coloca data e hora de processamento na tabela
              assim que inicia o processo, por isso esta verificando
              somando mais 5min que eh a media de execucao da DEBNET
              para cada cooperativa*/
            IF  craphec.dtultexc = glb_dtmvtolt THEN
                DO:
                    IF (craphec.hrultexc + 300) >= TIME THEN
                        DO:
                            ASSIGN glb_dscritic = "Processo autmomatico DEBNET executando. ".
                                   glb_dscritic = glb_dscritic + "Tente novamente mais tarde.".
                        END.                                                                   
                END.
            ELSE
                DO:
                    ASSIGN glb_dscritic = "Processo autmomatico DEBNET executando. ".
                           glb_dscritic = glb_dscritic + "Tente novamente mais tarde.".
                END.

            IF  glb_dscritic <> "" THEN
                DO:
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.
        END.

    ASSIGN aux_nmarqcen = "crrl483_" + STRING(TIME) + ".lst"
           aux_nmaqcesv = "rlnsv/" + aux_nmarqcen
           aux_nmarqcen = "rl/" + aux_nmarqcen.               
        

    /**** Define Inicio e Fim para cooperativas */
    ASSIGN aux_cdcoopin = IF  glb_cdcooper = 3 THEN
                              INT(tel_cdcooper)
                          ELSE 
                              glb_cdcooper.

    ASSIGN aux_cdcoopfi = IF  aux_cdcoopin = 0 THEN
                              99
                          ELSE
                              aux_cdcoopin.

    IF  glb_cddopcao = "C"  THEN
        DO:
            /*** PROCESSA COOPERATIVAS ***/
            EMPTY TEMP-TABLE w_agendamentos.
    
            FOR EACH crapcop WHERE crapcop.cdcooper <> 3            AND 
                                   crapcop.cdcooper >= aux_cdcoopin AND
                                   crapcop.cdcooper <= aux_cdcoopfi AND
                                   crapcop.flgativo = TRUE NO-LOCK:

                RUN carrega-agendamentos-debito(INPUT crapcop.cdcooper).

                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.

            END. /* END do FOR EACH crapcop */
    
            OPEN QUERY q_agendamentos FOR EACH w_agendamentos 
                                            BY w_agendamentos.cdcooper
                                            BY w_agendamentos.nrdconta
                                            BY w_agendamentos.dttransa
                                            BY w_agendamentos.nrdocmto.
    
            IF  NUM-RESULTS("q_agendamentos") = 0  THEN
                DO:
                    BELL.
                    MESSAGE "Nao foram encontrados agendamentos pendentes.".
                    CLOSE QUERY q_agendamentos.
                    NEXT.
                END.
    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                UPDATE b_agendamentos WITH FRAME f_b_agendamentos.
                LEAVE.
    
            END.
    
            CLOSE QUERY q_agendamentos.
    
            HIDE FRAME f_b_agendamentos NO-PAUSE.
            HIDE FRAME f_dados_pagto    NO-PAUSE.
            HIDE FRAME f_dados_transf   NO-PAUSE.
            HIDE FRAME f_sumario NO-PAUSE.
            
        END.
    ELSE
    IF  glb_cddopcao = "P"  THEN
        DO:

            EMPTY TEMP-TABLE w_agendamentos.

            /* Validar as informações de processamento 
               apenas carrega os agendamentos em tela */
            RUN executa-agendamento(INPUT aux_cdcoopin
                                   ,INPUT aux_cdcoopfi
                                   ,INPUT FALSE).
                     
            OPEN QUERY q_agendamentos FOR EACH w_agendamentos 
                                            BY w_agendamentos.cdcooper
                                            BY w_agendamentos.nrdconta
                                            BY w_agendamentos.dttransa
                                            BY w_agendamentos.nrdocmto.

            IF  NUM-RESULTS("q_agendamentos") = 0  THEN
                DO:
                    BELL.
                    MESSAGE "Nao foram encontrados agendamentos pendentes.".
                    CLOSE QUERY q_agendamentos.
                    NEXT.
                END.
                
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
                UPDATE b_agendamentos WITH FRAME f_b_agendamentos.
                LEAVE.

            END.

            ASSIGN aux_flconfir = FALSE.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                ASSIGN glb_cdcritic = 78.
                RUN fontes/critic.p.    
                BELL.
                MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_flconfir.
                ASSIGN glb_cdcritic = 0.
                LEAVE.
                    
            END.

            CLOSE QUERY q_agendamentos.
                    
            HIDE FRAME f_b_agendamentos NO-PAUSE.
            HIDE FRAME f_dados_pagto    NO-PAUSE.
            HIDE FRAME f_dados_transf   NO-PAUSE.
            HIDE FRAME f_sumario NO-PAUSE.
    
            IF  NOT aux_flconfir OR KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                DO:
                    ASSIGN glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    ASSIGN glb_cdcritic = 0.
                    NEXT.
                END.            

            MESSAGE "Aguarde, debitando agendamentos ...".
            
            /* Executa os agendamentos */
            RUN executa-agendamento(INPUT aux_cdcoopin
                                   ,INPUT aux_cdcoopfi
                                   ,INPUT TRUE).

            HIDE MESSAGE NO-PAUSE.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.

            /* Percorrer todos os relatorios gerados e exibir em um unico */
            FOR EACH w_relatorios NO-LOCK:
                ASSIGN aux_nmarquiv = w_relatorios.nmrelato + ".lst"
                       aux_nmarqimp = "/usr/coop/" + w_relatorios.dsdircop + 
                                      "/rl/" + aux_nmarquiv
                       aux_nmarquiv = "/usr/coop/" + w_relatorios.dsdircop + 
                                      "/rlnsv/" + aux_nmarquiv.

                IF  RETURN-VALUE = "OK"  THEN
                    UNIX SILENT VALUE ("cat " + aux_nmarqimp + " >> " +
                                       aux_nmarqcen).
            END.

            ASSIGN aux_flgimpri = YES.

            MESSAGE "Deseja visualizar o Relatorio em Tela? "
                    UPDATE aux_flgimpri.

            IF  aux_flgimpri THEN
                RUN fontes/visrel.p (INPUT aux_nmarqcen).

            IF  glb_cdcooper = 3 THEN
                DO:
                    UNIX SILENT VALUE("cp " + aux_nmarqcen + " " + 
                                      aux_nmaqcesv + " 2>/dev/null").

                    ASSIGN glb_nrcopias = 1            
                           glb_nmformul = "132col"     
                           glb_nmarqimp = aux_nmarqcen.
                        
                    RUN fontes/imprim.p.
                END.
            ELSE
                UNIX SILENT VALUE("rm " + aux_nmarqcen + " 2>/dev/null").

        END.
    ELSE     
    IF  glb_cddopcao = "S" THEN /*S - Sumario*/
        DO:
            MESSAGE "Carregando...".
        
            RUN sumario_lancamentos(INPUT  aux_cdcoopin
                                   ,INPUT  aux_cdcoopfi
                                   ,INPUT  glb_dtmvtolt
                                   ,OUTPUT aux_qtpenden
                                   ,OUTPUT aux_qtefetiv
                                   ,OUTPUT aux_qtnefeti
                                   ,OUTPUT aux_qttotlan).
                        
            HIDE FRAME f_b_agendamentos NO-PAUSE.
            HIDE FRAME f_dados_pagto    NO-PAUSE.
            HIDE FRAME f_dados_transf   NO-PAUSE.
        
            DISPLAY aux_qtpenden aux_qtefetiv aux_qtnefeti aux_qttotlan WITH FRAME f_sumario.
            
            HIDE MESSAGE NO-PAUSE.
        
        END.
    
END. /** Fim do DO WHILE TRUE **/

/*............................................................................*/

PROCEDURE carrega-agendamentos-debito:
    
    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper NO-UNDO.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

    /* Buscar as informações dos agendamentos */ 
    RUN STORED-PROCEDURE pc_PAGA0001_obtem_agen_deb
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,
                                 INPUT glb_dtmvtolt,
                                 INPUT glb_inproces,
                                OUTPUT ?,   /* clobxmlc */
                                OUTPUT 0,   /* cdcritic */ 
                                OUTPUT ""). /* dscritic */

    CLOSE STORED-PROC pc_PAGA0001_obtem_agen_deb
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsxmlage = ""
           aux_cdcritic = pc_PAGA0001_obtem_agen_deb.pr_cdcritic 
                              WHEN pc_PAGA0001_obtem_agen_deb.pr_cdcritic <> ?
           aux_dscritic = pc_PAGA0001_obtem_agen_deb.pr_dscritic 
                              WHEN pc_PAGA0001_obtem_agen_deb.pr_dscritic <> ?
           aux_dsxmlage = pc_PAGA0001_obtem_agen_deb.pr_clobxmlc.

    IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
    DO:
        ASSIGN glb_dscritic = aux_dscritic.
        RETURN "NOK".
    END.

    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

    /*Leitura do XML de retorno da proc e criacao dos registros na w_agendamentos
    para visualizacao dos registros na tela */

    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(aux_dsxmlage) + 1. 
    PUT-STRING(ponteiro_xml,1) = aux_dsxmlage. 

    IF ponteiro_xml <> ? THEN
        DO:
            xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
            xDoc:GET-DOCUMENT-ELEMENT(xRoot).

            DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 

                xRoot:GET-CHILD(xRoot2,aux_cont_raiz).

                IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                 NEXT. 

                IF xRoot2:NUM-CHILDREN > 0 THEN
                  CREATE w_agendamentos.

                DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:

                    xRoot2:GET-CHILD(xField,aux_cont).

                    IF xField:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 

                    xField:GET-CHILD(xText,1).

                    ASSIGN w_agendamentos.cdcooper =  INT(xText:NODE-VALUE) WHEN xField:NAME = "cdcooper"
                           w_agendamentos.dscooper =      xText:NODE-VALUE  WHEN xField:NAME = "dscooper"
                           w_agendamentos.cdagenci =  INT(xText:NODE-VALUE) WHEN xField:NAME = "cdagenci"
                           w_agendamentos.nrdconta =  INT(xText:NODE-VALUE) WHEN xField:NAME = "nrdconta"
                           w_agendamentos.nmprimtl =      xText:NODE-VALUE  WHEN xField:NAME = "nmprimtl"
                           w_agendamentos.cdtiptra =  INT(xText:NODE-VALUE) WHEN xField:NAME = "cdtiptra"
                           w_agendamentos.dstiptra =      xText:NODE-VALUE  WHEN xField:NAME = "dstiptra"
                           w_agendamentos.dstransa =      xText:NODE-VALUE  WHEN xField:NAME = "dstransa"
                           w_agendamentos.vllanaut =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vllanaut"
                           w_agendamentos.dttransa = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dttransa"
                           w_agendamentos.hrtransa =      xText:NODE-VALUE  WHEN xField:NAME = "hrtransa"
                           w_agendamentos.nrdocmto =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "nrdocmto"
                           w_agendamentos.dslindig =      xText:NODE-VALUE  WHEN xField:NAME = "dslindig"
                           w_agendamentos.dscritic =      xText:NODE-VALUE  WHEN xField:NAME = "dscritic"
                           w_agendamentos.dsorigem =      xText:NODE-VALUE  WHEN xField:NAME = "dsorigem"
                           w_agendamentos.idseqttl =  INT(xText:NODE-VALUE) WHEN xField:NAME = "idseqttl"
                           w_agendamentos.dsdocmto =      xText:NODE-VALUE  WHEN xField:NAME = "dsdocmto"

                           w_agendamentos.fltiptra = LOGICAL(INT(xText:NODE-VALUE)) WHEN xField:NAME = "fltiptra"
                           w_agendamentos.fltipdoc = LOGICAL(INT(xText:NODE-VALUE)) WHEN xField:NAME = "fltipdoc"
                           w_agendamentos.fldebito = LOGICAL(INT(xText:NODE-VALUE)) WHEN xField:NAME = "fldebito".
                END.
            END.

            SET-SIZE(ponteiro_xml) = 0. 
        END.

    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.

    RETURN "OK".

END PROCEDURE.

/*sumario*/
PROCEDURE sumario_lancamentos:

  DEF INPUT  PARAM par_cdcooper      LIKE    crapcop.cdcooper    NO-UNDO.
  DEF INPUT  PARAM par_cdcopfin      LIKE    crapcop.cdcooper    NO-UNDO.
  DEF INPUT  PARAM par_dtmvtolt      LIKE    crapdat.dtmvtolt    NO-UNDO.
  
  DEF OUTPUT PARAM par_qtpenden      AS      DECIMAL             NO-UNDO.
  DEF OUTPUT PARAM par_qtefetiv      AS      DECIMAL             NO-UNDO.
  DEF OUTPUT PARAM par_qtnefeti      AS      DECIMAL             NO-UNDO.
  DEF OUTPUT PARAM par_qtdtotal      AS      DECIMAL             NO-UNDO.

  DEF VAR var_qtpenden   AS  DECIMAL       NO-UNDO.
  DEF VAR var_qtefetiv   AS  DECIMAL       NO-UNDO.
  DEF VAR var_qtnefeti   AS  DECIMAL       NO-UNDO.
  DEF VAR var_qtdtotal   AS  DECIMAL       NO-UNDO.

  /*inicializa as variaveis*/
  ASSIGN var_qtpenden = 0
         var_qtefetiv = 0 
         var_qtnefeti = 0
         var_qtdtotal = 0
         par_qtpenden = 0
         par_qtefetiv = 0
         par_qtnefeti = 0
         par_qtdtotal = 0.
    
  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

  /* Buscar as informações dos agendamentos */ 
  RUN STORED-PROCEDURE pc_sumario_debnet
      aux_handproc = PROC-HANDLE NO-ERROR
                              (INPUT par_cdcooper,
                               INPUT par_cdcopfin,
                              OUTPUT ?,   /* clobxmlc */
                              OUTPUT 0,   /* cdcritic */ 
                              OUTPUT ""). /* dscritic */

  CLOSE STORED-PROC pc_sumario_debnet
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_dsxmlage = ""
         aux_cdcritic = pc_sumario_debnet.pr_cdcritic 
                            WHEN pc_sumario_debnet.pr_cdcritic <> ?
         aux_dscritic = pc_sumario_debnet.pr_dscritic 
                            WHEN pc_sumario_debnet.pr_dscritic <> ?
         aux_dsxmlage = pc_sumario_debnet.pr_clobxmlc.

  IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
  DO:
      ASSIGN glb_dscritic = aux_dscritic.
      RETURN "NOK".
  END.

  /* Inicializando objetos para leitura do XML */ 
  CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
  CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
  CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
  CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

  /*Leitura do XML de retorno da proc e criacao dos registros na w_agendamentos
  para visualizacao dos registros na tela */

  /* Efetuar a leitura do XML*/ 
  SET-SIZE(ponteiro_xml) = LENGTH(aux_dsxmlage) + 1. 
  PUT-STRING(ponteiro_xml,1) = aux_dsxmlage. 

  IF ponteiro_xml <> ? THEN
      DO:
          xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
          xDoc:GET-DOCUMENT-ELEMENT(xRoot).

          DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 

              xRoot:GET-CHILD(xField,aux_cont_raiz).

              IF xField:SUBTYPE <> "ELEMENT" THEN 
                 NEXT. 

              xField:GET-CHILD(xText,1).

              ASSIGN var_qtpenden =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "qtdpendentes"
                     var_qtefetiv =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "qtefetivados"
                     var_qtnefeti =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "qtnaoefetiva"
                     var_qtdtotal =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "qtdtotallanc".
          END.

          SET-SIZE(ponteiro_xml) = 0. 
      END.

  DELETE OBJECT xDoc. 
  DELETE OBJECT xRoot. 
  DELETE OBJECT xField. 
  DELETE OBJECT xText.

  ASSIGN par_qtpenden = var_qtpenden
         par_qtefetiv = var_qtefetiv
         par_qtnefeti = var_qtnefeti
         par_qtdtotal = var_qtdtotal.

    RETURN "OK".

END PROCEDURE.

PROCEDURE executa-agendamento:

    DEF INPUT PARAM par_cdcoopin AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdcoopfi AS INTE NO-UNDO.
    DEF INPUT PARAM par_flgproce AS LOGI NO-UNDO.

    /* Limpar a tabela de relatorios */
    EMPTY TEMP-TABLE w_relatorios.

    /*** PROCESSA COOPERATIVAS ***/
    FOR EACH crapcop WHERE crapcop.cdcooper <> 3            AND
                           crapcop.cdcooper >= par_cdcoopin AND
                           crapcop.cdcooper <= par_cdcoopfi AND
                           crapcop.flgativo = TRUE  NO-LOCK:

        ASSIGN glb_dscritic = "".
        
        /*   Verifica somente das cooperativas que tiverem 
             agendamentos */
        FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper AND
                           craptab.nmsistem = "CRED"           AND
                           craptab.tptabela = "GENERI"         AND
                           craptab.cdempres = 00               AND
                           craptab.cdacesso = "HRTRTITULO"     AND
                           craptab.tpregist = 90  NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE craptab  THEN
            ASSIGN glb_dscritic = crapcop.nmrescop +
                                 " - Tabela HRTRTITULO nao cadastrada.".
        ELSE
            DO:   
                IF   SUBSTR(craptab.dstextab,15,3) = "SIM"  THEN
                     ASSIGN aux_flsgproc = TRUE.
                ELSE
                     ASSIGN aux_flsgproc = FALSE.
                                                           
                /** Verifica se cooperativa optou pelo segundo processo **/
                IF  NOT aux_flsgproc  THEN
                    ASSIGN glb_dscritic = crapcop.nmrescop +
                                        " - Opcao para processo manual "
                                          + "desabilitada.". 
                                          /***
                ELSE                                           
                /** Verifica se horario para pagamentos nao esgotou **/
                IF  TIME <= INTE(SUBSTR(craptab.dstextab,3,5))  THEN
                    ASSIGN glb_dscritic = crapcop.nmrescop +
                                          " - Horario limite para " + 
                                   "pagamentos na Internet nao esgotou".
                ******************/
            
            END.                            
            
            IF  glb_dscritic <> ""  THEN
                DO:
                    MESSAGE glb_dscritic.
                    /* Se houve critica, desconsidera a cooperativa */
                    NEXT.
                END.

        IF par_flgproce THEN
        DO:
            /* Processar o agendamento */
            RUN executa-agendamentos-debito(INPUT crapcop.cdcooper,
                                            INPUT crapcop.dsdircop,
                                            INPUT aux_flsgproc).
        END.
        ELSE 
        DO:
            /* Carregar o agendamento */
            RUN carrega-agendamentos-debito(INPUT crapcop.cdcooper).
        END.
        
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                BELL.
                MESSAGE glb_dscritic.
                NEXT.
            END.
    END. /* END do FOR EACH crapcop */

END PROCEDURE.


PROCEDURE executa-agendamentos-debito:
    
    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper NO-UNDO.
    DEF INPUT PARAM par_dsdircop LIKE crapcop.dsdircop NO-UNDO.
    DEF INPUT PARAM par_flsgproc AS LOGICAL            NO-UNDO.
    
    DEF VAR aux_cdcritic AS INTE                       NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                       NO-UNDO.
    DEF VAR aux_nmrelato AS CHAR                       NO-UNDO.


    RUN gera_log_execucao(INPUT "DEBNET",
                          INPUT "Inicio execucao",
                          INPUT par_cdcooper,
                          INPUT "").                        

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

    /* Buscar as informações dos agendamentos */ 
    RUN STORED-PROCEDURE pc_PAGA0001_efetua_debitos
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper, /* cdcooper */
                                 INPUT "DEBNET",     /* cdprogra */
                                 INPUT glb_dtmvtolt, /* dtmvtopg */
                                 INPUT glb_inproces, /* inproces */
                                 INPUT INT(par_flsgproc), /* flsgproc */
                                OUTPUT "",           /* nmrelato */
                                OUTPUT 0,            /* cdcritic */
                                OUTPUT "").          /* dscritic */

    CLOSE STORED-PROC pc_PAGA0001_efetua_debitos
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_nmrelato = ""
           aux_cdcritic = pc_PAGA0001_efetua_debitos.pr_cdcritic 
                              WHEN pc_PAGA0001_efetua_debitos.pr_cdcritic <> ?
           aux_dscritic = pc_PAGA0001_efetua_debitos.pr_dscritic 
                              WHEN pc_PAGA0001_efetua_debitos.pr_dscritic <> ?
           aux_nmrelato = pc_PAGA0001_efetua_debitos.pr_nmrelato
                              WHEN pc_PAGA0001_efetua_debitos.pr_nmrelato <> ?.

    /* Verificar se foi criado algum relatorio */
    IF aux_nmrelato <> "" THEN
    DO:
        CREATE w_relatorios.
        ASSIGN w_relatorios.cdcooper = par_cdcooper
               w_relatorios.dsdircop = par_dsdircop
               w_relatorios.nmrelato = aux_nmrelato.
    END.
        
    RUN gera_log_execucao(INPUT "DEBNET",
                          INPUT "Fim execucao",
                          INPUT par_cdcooper,
                          INPUT "").                        

    IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
    DO:
        ASSIGN glb_dscritic = aux_dscritic.
        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE gera_log_execucao:

    DEF INPUT PARAM par_nmprgexe    AS  CHAR        NO-UNDO.
    DEF INPUT PARAM par_indexecu    AS  CHAR        NO-UNDO.
    DEF INPUT PARAM par_cdcooper    AS  INT         NO-UNDO.
    DEF INPUT PARAM par_tpexecuc    AS  CHAR        NO-UNDO.
    
    DEF VAR aux_nmarqlog            AS  CHAR        NO-UNDO.

    ASSIGN aux_nmarqlog = "log/prcctl_" + STRING(YEAR(glb_dtmvtolt),"9999") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(DAY(glb_dtmvtolt),"99") + ".log".
    
    UNIX SILENT VALUE("echo " + "Manual - " + 
                      STRING(TIME,"HH:MM:SS") + "' --> '"  +
                      "Coop.:" + STRING(par_cdcooper) + " '" +  
                      par_tpexecuc + "' - '" + 
                      par_nmprgexe + "': " + 
                      par_indexecu +  
                      " >> " + aux_nmarqlog).

    RETURN "OK".  
END PROCEDURE.
