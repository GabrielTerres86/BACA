/* ............................................................................

   Programa: fontes/prccon.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Lunelli
   Data    : Fevereiro/2013                   Ultima alteracao: 17/12/2013
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar rotinas de Convenio - SICREDI.
               Chamado Softdesk 43660.
   
   Alteracoes: 29/05/2013 - Solicitação para crps637 alterada para 92 (Lucas).
   
               10/12/2013 - Incluir script login_cifs_mount.sh (Lucas R.)
               
               17/12/2013 - Inclusao de VALIDATE crapsol (Carlos)
               
               09/01/2018 - Inclusao do processamento de convenios Bancoob - PRJ406
                            
............................................................................ */

{ sistema/generico/includes/var_internet.i } 
{ includes/var_online.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/gera_erro.i}

DEF STREAM str_1.

DEF VAR tel_pesquisa AS CHAR        FORMAT "x(20)"                     NO-UNDO.
DEF VAR tel_cddopcao AS CHAR        FORMAT "!(1)"                      NO-UNDO.
DEF VAR tel_cdcooper LIKE crapcop.cdcooper                             NO-UNDO.
DEF VAR tel_nmrescop LIKE crapcop.nmrescop                             NO-UNDO.
DEF VAR tel_cdempres AS CHAR        FORMAT "x(10)"                     NO-UNDO.
DEF VAR tel_nmextcon LIKE crapcon.nmextcon                             NO-UNDO.
DEF VAR aux_cdcooper LIKE crapcop.cdcooper                             NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nomedarq AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR        FORMAT "!"                         NO-UNDO.
DEF VAR aux_tamarqui AS CHAR                                           NO-UNDO.
DEF VAR tel_datadlog AS DATE        FORMAT "99/99/9999"                NO-UNDO.
DEF VAR tel_opagente AS CHAR        FORMAT "x(12)" VIEW-AS COMBO-BOX   
                                                   INNER-LINES 11      NO-UNDO.

/* variaveis para impressao */
DEF VAR tel_dsimprim AS CHAR        FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF VAR tel_dscancel AS CHAR        FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF VAR aux_nmendter AS CHAR        FORMAT "x(20)"                     NO-UNDO.
DEF VAR par_flgrodar AS LOGICAL INIT TRUE                              NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                        NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                              NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                        NO-UNDO.
DEF VAR aux_contador AS INT         INIT 0                             NO-UNDO.

DEF TEMP-TABLE tt-cooperativas NO-UNDO
    FIELD cdcooper1 LIKE crapcop.cdcooper 
    FIELD nmrescop LIKE crapcop.nmrescop.
    
DEF TEMP-TABLE tt-convenios NO-UNDO
    FIELD cdempres AS CHAR
    FIELD nmextcon LIKE crapcon.nmextcon.

DEF QUERY q-coope FOR tt-cooperativas.

DEF QUERY q-conve FOR tt-convenios.

DEF BROWSE b-coope QUERY q-coope
      DISP SPACE(2)
           cdcooper1                     COLUMN-LABEL "Codigo"
           SPACE(1)
           nmrescop                     COLUMN-LABEL "Nome"
           WITH 9 DOWN OVERLAY NO-BOX.
           
DEF BROWSE b-conve QUERY q-conve
      DISP SPACE(2)
           cdempres                     COLUMN-LABEL "Codigo"
           SPACE(1)
           nmextcon                     COLUMN-LABEL "Nome"
           WITH 9 DOWN OVERLAY NO-BOX.

DEF FRAME f-coope
          b-coope HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 VIEW-AS DIALOG-BOX.
          
DEF FRAME f-conve
          b-conve HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 VIEW-AS DIALOG-BOX.

FORM tel_datadlog    AT 03 LABEL "Data Log"
                           HELP "Informe a data para visualizar LOG"
     tel_pesquisa    AT 32 LABEL "Pesquisar"
                           HELP "Informe texto a pesquisar (espaco em branco, tudo)."
                           WITH ROW 7 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_prccon_l.
                           
FORM tel_cdcooper    AT 03 LABEL "Cooperativa"
                           HELP "Informe o Cod.Cooperativa / F7 Consulta ou 0 para TODAS."
     tel_nmrescop    AT 32
                           WITH ROW 7 COLUMN 2 NO-LABELS SIDE-LABELS OVERLAY NO-BOX FRAME f_prccon_m.

FORM tel_cdempres    AT 03 LABEL "Convenio"
                           HELP "Informe o Cod.Convenio / F7 Consulta ou 0 para TODOS."
     tel_nmextcon    AT 32
                           WITH ROW 7 COLUMN 2 NO-LABELS SIDE-LABELS OVERLAY NO-BOX FRAME f_prccon_n.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao    AT 03 LABEL "Opcao" AUTO-RETURN
                           HELP  "Informe a opcao desejada (I, B ou L)."
                           VALIDATE(CAN-DO("L,I,B",glb_cddopcao), "014 - Opcao errada.")
     tel_opagente    AT 32 LABEL "Agente"
                           HELP "Selecione o agente"
                           WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_prccon.

ON END-ERROR OF b-coope DO:

    DISABLE b-coope WITH FRAME f-coope.

    CLOSE QUERY q-coope.
    HIDE FRAME f-coope.

    NEXT-PROMPT tel_cdcooper WITH FRAME f_prccon_m.

END.

ON END-ERROR OF b-conve DO:

    DISABLE b-conve WITH FRAME f-conve.

    CLOSE QUERY q-conve.
    HIDE FRAME f-conve.

    NEXT-PROMPT tel_cdempres WITH FRAME f_prccon_n.

END.

ON RETURN OF tel_opagente DO:

   ASSIGN tel_opagente = tel_opagente:SCREEN-VALUE.
   APPLY "GO".

END.

ASSIGN glb_cddopcao = "I"
       glb_cdcritic = 0.

RUN fontes/inicia.p.

ASSIGN tel_opagente:LIST-ITEM-PAIRS = "Sicredi,S,Bancoob,B".

VIEW FRAME f_moldura.
PAUSE(0).

prccon:
DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        IF  glb_cdcritic > 0   THEN 
            DO:
                RUN fontes/critic.p.
                MESSAGE glb_dscritic.
                glb_cdcritic = 0.
                PAUSE 2 NO-MESSAGE.
            END.

        UPDATE glb_cddopcao WITH FRAME f_prccon.

        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN 
        DO:
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "PRCCON"  THEN
                DO:
                    HIDE FRAME f_prccon.
                    HIDE FRAME f_moldura.
                    HIDE MESSAGE NO-PAUSE.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.
    
    IF  aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

    /* Executar script de login das cifs */
    UNIX SILENT VALUE ("/usr/local/cecred/bin/login_cifs_mount.sh").

    HIDE MESSAGE NO-PAUSE.
         
    IF  glb_cddopcao = "I"   THEN
        DO:
            HIDE tel_datadlog tel_pesquisa IN FRAME f_prccon_l.
            HIDE tel_opagente IN FRAME f_prccon.
            ASSIGN aux_confirma = "N".
            RUN fontes/confirma.p (INPUT  "Importar os arquivos do Sicredi?",
                                   OUTPUT aux_confirma).
                    
            IF  aux_confirma <> "S" THEN 
                NEXT.

            MESSAGE "Realizando importacao dos arquivos...".

            /* Cria solicitação */
            DO TRANSACTION:
                FIND FIRST crapsol WHERE 
                           crapsol.cdcooper = glb_cdcooper   AND 
                           crapsol.nrsolici = 92             AND
                           crapsol.dtrefere = glb_dtmvtolt   
                           NO-LOCK NO-ERROR.
                           
                IF  AVAILABLE crapsol  THEN
                     DO:
                         FIND CURRENT crapsol EXCLUSIVE-LOCK.
                         DELETE crapsol.
                     END.

                CREATE crapsol. 
                ASSIGN crapsol.nrsolici = 92
                       crapsol.dtrefere = glb_dtmvtolt
                       crapsol.nrseqsol = 1
                       crapsol.cdempres = 11
                       crapsol.dsparame = ""
                       crapsol.insitsol = 1
                       crapsol.nrdevias = 0
                       crapsol.cdcooper = glb_cdcooper.
                VALIDATE crapsol.
            END.
            
            UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")        + 
                               " - "   + STRING(TIME,"HH:MM:SS")           +
                               " - "   + CAPS(glb_cdprogra) + "'  --> '"   +
                               "Iniciada execucao manual da importacao."   +
                               " >> log/prccon.log").

            /* Executa programa de importação dos arquivos */
            RUN fontes/crps637.p.

            UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999") + 
                               " - "   + STRING(TIME,"HH:MM:SS")           +
                               " - "   + CAPS(glb_cdprogra) + "'  --> '"   +
                               "Finalizada execucao manual da importacao." +
                               " >> log/prccon.log").

            DO TRANSACTION:
                /* Limpa solicitacao se existente */
                FIND FIRST crapsol WHERE 
                           crapsol.cdcooper = glb_cdcooper   AND 
                           crapsol.nrsolici = 92             AND
                           crapsol.dtrefere = glb_dtmvtolt   
                           NO-LOCK NO-ERROR.
                           
                IF  AVAILABLE crapsol  THEN
                     DO:
                         FIND CURRENT crapsol EXCLUSIVE-LOCK.
                         DELETE crapsol.
                     END.

            END. /* Fim TRANSACTION */

            HIDE MESSAGE NO-PAUSE.
            MESSAGE "Importacao finalizada!".
            
        END.

    IF  glb_cddopcao = "B"   THEN
        DO:
            HIDE tel_datadlog tel_pesquisa IN FRAME f_prccon_l.
            ASSIGN tel_nmrescop = "".
            
            DO WHILE TRUE ON ENDKEY UNDO, NEXT prccon:
                
                UPDATE tel_opagente WITH FRAME f_prccon.
                
                IF tel_opagente = "S" THEN
                  DO:
                    HIDE FRAME f_prccon_m.
                    HIDE FRAME f_prccon_n.
                    LEAVE.
                  END.
                ELSE
                  DO:
                    /*Cooperativa*/
                    UPDATE tel_cdcooper WITH FRAME f_prccon_m
                      EDITING:
          
                        READKEY.
                        IF  LASTKEY =  KEYCODE("F7") THEN
                            RUN pi-exibe-browse (INPUT FRAME-FIELD).
                            
                        APPLY LASTKEY.
                      END. /* Editing */
                      IF tel_cdcooper <> 0 THEN
                        DO:
                           FIND crapcop WHERE crapcop.cdcooper = tel_cdcooper AND
                                              crapcop.cdcooper <> 3 AND
                                              crapcop.flgativo = TRUE.
                            IF AVAIL crapcop THEN
                               DO:
                                  ASSIGN tel_nmrescop = crapcop.nmrescop.
                                  DISPLAY tel_nmrescop WITH FRAME f_prccon_m.
                               END.
                            ELSE
                              DO:
                                 MESSAGE "Cooperativa nao encontrado.".
                                 NEXT.
                              END.
                        END.
                      ELSE
                        DO:
                           ASSIGN tel_nmrescop = "TODAS".
                           DISPLAY tel_nmrescop WITH FRAME f_prccon_m.
                        END.
                    /*Convenio*/
                    UPDATE tel_cdempres WITH FRAME f_prccon_n
                      EDITING:
          
                        READKEY.
                        IF  LASTKEY =  KEYCODE("F7") THEN
                            RUN pi-exibe-browse (INPUT FRAME-FIELD).
                            
                        APPLY LASTKEY.
                      END. /* Editing */
                      IF tel_cdempres <> '0' THEN
                        DO:
                          RUN pi-busca-convenio (INPUT INPUT tel_cdcooper,
                                                 INPUT INPUT tel_cdempres).
                          FIND tt-convenios WHERE tt-convenios.cdempres = tel_cdempres.
                            IF AVAIL tt-convenios THEN
                              DO:
                                ASSIGN tel_nmextcon = tt-convenios.nmextcon.
                                DISPLAY tel_nmextcon WITH FRAME f_prccon_n.
                              END.
                            ELSE
                              DO:
                                 MESSAGE "Convenio nao encontrado.".
                                 NEXT.
                              END.
                        END.
                      ELSE
                        DO:
                           ASSIGN tel_nmextcon = "TODAS".
                           DISPLAY tel_nmextcon WITH FRAME f_prccon_n.
                        END.
                  END.
            END.
            
            IF tel_opagente = "S" THEN
              DO:
                ASSIGN aux_confirma = "N".
                RUN fontes/confirma.p (INPUT  "Exportar os arquivos do Sicredi?",
                                       OUTPUT aux_confirma).

                IF  aux_confirma <> "S" THEN 
                    NEXT.

                MESSAGE "Realizando exportacao dos arquivos...".

                /* Cria solicitação */
                DO TRANSACTION:
                    FIND FIRST crapsol WHERE 
                               crapsol.cdcooper = glb_cdcooper   AND 
                               crapsol.nrsolici = 89             AND
                               crapsol.dtrefere = glb_dtmvtolt   
                               NO-LOCK NO-ERROR.
                               
                    IF  AVAILABLE crapsol  THEN
                         DO:
                             FIND CURRENT crapsol EXCLUSIVE-LOCK.
                             DELETE crapsol.
                         END.
            
                    CREATE crapsol. 
                    ASSIGN crapsol.nrsolici = 89
                           crapsol.dtrefere = glb_dtmvtolt
                           crapsol.nrseqsol = 1
                           crapsol.cdempres = 11
                           crapsol.dsparame = ""
                           crapsol.insitsol = 1
                           crapsol.nrdevias = 0
                           crapsol.cdcooper = glb_cdcooper.
                    VALIDATE crapsol.
                END.
            
                UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999") + 
                                   " - "   + STRING(TIME,"HH:MM:SS")           +
                                   " - "   + CAPS(glb_cdprogra) + "'  --> '"   +
                                   "Iniciada execucao manual da exportacao."   +
                                   " >> log/prccon.log").

                /* Executa programa de exportação dos arquivos */
                RUN fontes/crps636.p.

                UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999") + 
                                   " - "   + STRING(TIME,"HH:MM:SS")           +
                                   " - "   + CAPS(glb_cdprogra) + "'  --> '"   +
                                   "Finalizada execucao manual da exportacao." +
                                   " >> log/prccon.log").

                DO TRANSACTION:
                    /* Limpa solicitacao se existente */
                    FIND FIRST crapsol WHERE 
                               crapsol.cdcooper = glb_cdcooper   AND 
                               crapsol.nrsolici = 89             AND
                               crapsol.dtrefere = glb_dtmvtolt   
                               NO-LOCK NO-ERROR.
                               
                    IF  AVAILABLE crapsol  THEN
                         DO:
                             FIND CURRENT crapsol EXCLUSIVE-LOCK.
                             DELETE crapsol.
                         END.

                END. /* Fim TRANSACTION */

                HIDE MESSAGE NO-PAUSE.
                MESSAGE "Exportacao finalizada!".

              END.
            ELSE IF tel_opagente = "B" THEN
              DO:
                /*Chamada da rotina ORACLE pc_gera_arrecadacao_bancoob proveniente da package PAGA003*/
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

                /* Gera os arquivos de arrecadacao bancoob */ 
                RUN STORED-PROCEDURE pc_gera_arrecadacao_bancoob
                   aux_handproc = PROC-HANDLE NO-ERROR
                                           (INPUT tel_cdcooper,
                                            INPUT tel_cdempres).

                CLOSE STORED-PROC pc_gera_arrecadacao_bancoob
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
              END.
          END.

    IF  glb_cddopcao = "L"   THEN
        DO:
            DISPLAY tel_datadlog tel_pesquisa WITH FRAME f_prccon_l.

            ASSIGN tel_pesquisa = ""
                   aux_nomedarq = ""
                   tel_datadlog = glb_dtmvtolt.

            DO WHILE TRUE ON ENDKEY UNDO, NEXT prccon:
                
                UPDATE tel_opagente WITH FRAME f_prccon.
                
                UPDATE tel_datadlog tel_pesquisa WITH FRAME f_prccon_l.
                LEAVE.

            END.

            HIDE tel_datadlog tel_pesquisa IN FRAME f_prccon_l.
            
            IF tel_opagente = "S" THEN
              ASSIGN aux_nmarqimp = "/usr/coop/cecred/log/prccon.log".
            ELSE
              ASSIGN aux_nmarqimp = "/usr/coop/cecred/log/prccon_b.log".

            IF  SEARCH(aux_nmarqimp) = ? THEN
                DO:
                    MESSAGE "NAO HA REGISTRO DE LOG PARA ESTA DATA!".
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.

            /* nome do arquivo temporário */
            IF tel_opagente = "S" THEN
              ASSIGN aux_nomedarq = "log/tmp_ged_" + STRING(TIME).
            ELSE
              ASSIGN aux_nomedarq = "log/tmp_ged_b_" + STRING(TIME).
              
            IF  tel_datadlog <> ?  THEN
                UNIX SILENT VALUE('grep -i "' + STRING(tel_datadlog,"99/99/9999") + '" ' + aux_nmarqimp + ' | grep -i "' + tel_pesquisa + '" ' +
                                  ' >> '   + aux_nomedarq + ' 2> /dev/null').
            ELSE
                UNIX SILENT VALUE('grep -i "' + tel_pesquisa + '" ' + aux_nmarqimp +
                                  ' >> '   + aux_nomedarq + ' 2> /dev/null').

            ASSIGN aux_nmarqimp = aux_nomedarq.

            /* Verifica se o arquivo esta vazio e critica */
            INPUT STREAM str_1 THROUGH VALUE("wc -m " +
                                             aux_nmarqimp + " 2> /dev/null") 
                                             NO-ECHO.
            
            SET STREAM str_1 aux_tamarqui FORMAT "x(30)".
            
            IF  INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0 THEN
                DO:
                    MESSAGE "Nenhuma ocorrencia encontrada.".
                    INPUT STREAM str_1 CLOSE.
                    NEXT.
                END.

            /* inicializa com opção T(Terminal) */
            ASSIGN tel_cddopcao = "T".
           
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.
                LEAVE.

            END.
           
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                NEXT.
           
            IF  tel_cddopcao = "T" THEN
                RUN fontes/visrel.p (INPUT aux_nmarqimp).
            ELSE
                IF  tel_cddopcao = "I" THEN
                    DO:
                        /* somente para o includes/impressao.i */
                        FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                                 NO-LOCK NO-ERROR.
           
                        { includes/impressao.i }
                    END.
                ELSE
                    DO:
                        ASSIGN glb_cdcritic = 14.
                        RUN fontes/critic.p.
                        MESSAGE glb_dscritic.
                        ASSIGN glb_cdcritic = 0.
                        NEXT.
                    END.
           
            /* apaga arquivo temporario */
            IF aux_nomedarq <> "" THEN
                UNIX SILENT VALUE ("rm " + aux_nomedarq + " 2> /dev/null").
                            
        END.
END.

PROCEDURE pi-busca-convenio:

  DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper NO-UNDO.
  DEF INPUT  PARAM par_cdempres AS CHAR NO-UNDO.
  
  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

  /* Efetuar a chamada da rotina Oracle */ 
  RUN STORED-PROCEDURE pc_busca_convenios
      aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper, /*Cooperativa*/
                                          INPUT par_cdempres, /*Convenio   */
                                         OUTPUT "",           /*Saida OK/NOK */
                                         OUTPUT ?,            /*Tab. retorno */
                                         OUTPUT 0,            /*Cod. critica */
                                         OUTPUT "").          /*Desc. critica*/

  /* Fechar o procedimento para buscarmos o resultado */ 
  CLOSE STORED-PROC pc_busca_convenios
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }HIDE MESSAGE NO-PAUSE.

  /* Busca possíveis erros */ 
  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_cdcritic = pc_busca_convenios.pr_cdcritic 
                        WHEN pc_busca_convenios.pr_cdcritic <> ?
         aux_dscritic = pc_busca_convenios.pr_dscritic 
                        WHEN pc_busca_convenios.pr_dscritic <> ?.

  /* Apresenta a critica */
  IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
      DO: 
         RUN gera_erro (INPUT glb_cdcooper,
                        INPUT 0,
                        INPUT 0,
                        INPUT 1,          /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).

         MESSAGE aux_dscritic.            
         PAUSE 3 NO-MESSAGE.
         RETURN "NOK".
      END.

  /* Buscar o XML na tabela de retorno da procedure Oracle */ 
  ASSIGN xml_req = pc_busca_convenios.pr_clob_ret.

  /* Ler o XML de retorno da proc e criar os registros na tt-historico
     para visualizacao dos registros na tela */
  SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
  PUT-STRING(ponteiro_xml,1) = xml_req. 

  /* Se o ponteiro for nulo ou o XML estiver vazio, sai da procedure */
  IF  ponteiro_xml = ? THEN
      RETURN "OK".

  /* Inicializando objetos para leitura do XML */ 
  CREATE X-DOCUMENT xDoc.    /* XML completo */ 
  CREATE X-NODEREF  xRoot.   /* Tag raiz em diante */ 
  CREATE X-NODEREF  xRoot2.  /* Tag aplicacao em diante */ 
  CREATE X-NODEREF  xField.  /* Campos dentro da tag INF */ 
  CREATE X-NODEREF  xText.   /* Texto que existe dentro da tag xField */

  /* Inicia o bloco para popular a temp-table com os dados do XML */
  xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
  xDoc:GET-DOCUMENT-ELEMENT(xRoot).

  DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
     xRoot:GET-CHILD(xRoot2,aux_cont_raiz).

     IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
        NEXT. 

     IF xRoot2:NUM-CHILDREN > 0 THEN
        DO:
           CREATE tt-convenios.
        END.

     DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
        xRoot2:GET-CHILD(xField,aux_cont).

        IF xField:SUBTYPE <> "ELEMENT" THEN 
           NEXT. 

        xField:GET-CHILD(xText,1).

        ASSIGN tt-convenios.cdempres = xText:NODE-VALUE WHEN xField:NAME = "cdempres"
               tt-convenios.nmextcon = xText:NODE-VALUE WHEN xField:NAME = "nmextcon" NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN 
            DO:
               ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1) + "Erro ao " +
                                     "converter o campo " + xField:NAME       + 
                                     " - " + xText:NODE-VALUE.
            END.

     END. /* DO aux_cont */
  END. /* DO aux_cont_raiz */

  SET-SIZE(ponteiro_xml) = 0. 

  DELETE OBJECT xDoc. 
  DELETE OBJECT xRoot. 
  DELETE OBJECT xRoot2. 
  DELETE OBJECT xField. 
  DELETE OBJECT xText.

  HIDE MESSAGE NO-PAUSE.

  RETURN "OK".
  
END PROCEDURE.

PROCEDURE pi-exibe-browse:

    DEF  INPUT   PARAM  par_frmfield    AS CHAR                   NO-UNDO.

    IF par_frmfield = "tel_cdcooper" THEN
       DO:
          EMPTY TEMP-TABLE tt-cooperativas.
          
          CREATE tt-cooperativas.
          ASSIGN tt-cooperativas.cdcooper1 = 0
                 tt-cooperativas.nmrescop = "TODAS".
          
          FOR EACH crapcop WHERE crapcop.cdcooper <> 3 AND
                                 crapcop.flgativo = TRUE NO-LOCK:
          
              CREATE tt-cooperativas.
              ASSIGN tt-cooperativas.cdcooper1 = crapcop.cdcooper
                     tt-cooperativas.nmrescop = crapcop.nmrescop.
          
          END.

          OPEN QUERY q-coope FOR EACH tt-cooperativas
                                   BY tt-cooperativas.cdcooper1
                                   BY tt-cooperativas.nmrescop.

          IF  NOT AVAIL tt-cooperativas THEN
              RETURN "NOK".
                 
          ENABLE b-coope WITH FRAME f-coope.

          WAIT-FOR RETURN OF b-coope.

          DISABLE b-coope WITH FRAME f-coope.

          ASSIGN tel_cdcooper = tt-cooperativas.cdcooper1
                 tel_nmrescop = tt-cooperativas.nmrescop.
          
          DISPLAY tel_cdcooper
                  tel_nmrescop WITH FRAME f_prccon_m.
          
          CLOSE QUERY q-coope.
          HIDE FRAME f-coope.
       END.
    
    ELSE IF par_frmfield = "tel_cdempres" THEN
       DO:
          EMPTY TEMP-TABLE tt-convenios.
          
          CREATE tt-convenios.
          ASSIGN tt-convenios.cdempres = 0
                 tt-convenios.nmextcon = "TODOS".
          
          FOR EACH tbconv_arrecadacao WHERE tbconv_arrecadacao.tparrecadacao = 2 NO-LOCK:
              IF tel_cdcooper = 0 THEN
                ASSIGN aux_cdcooper = 1.
              ELSE
                ASSIGN aux_cdcooper = tel_cdcooper.
                
              FIND crapcon WHERE crapcon.cdempcon = tbconv_arrecadacao.cdempcon AND
                                 crapcon.cdsegmto = tbconv_arrecadacao.cdsegmto AND
                                 crapcon.cdcooper = aux_cdcooper.
              CREATE tt-convenios.
              ASSIGN tt-convenios.cdempres = crapcon.cdempres
                     tt-convenios.nmextcon = crapcon.nmextcon.
          END.

          OPEN QUERY q-conve FOR EACH tt-convenios
                                   BY tt-convenios.cdempres
                                   BY tt-convenios.nmextcon.

          IF  NOT AVAIL tt-convenios THEN
              RETURN "NOK".
                 
          ENABLE b-conve WITH FRAME f-conve.

          WAIT-FOR RETURN OF b-conve.

          DISABLE b-conve WITH FRAME f-conve.

          ASSIGN tel_cdempres = tt-convenios.cdempres
                 tel_nmextcon = tt-convenios.nmextcon.
          
          DISPLAY tel_cdempres
                  tel_nmextcon WITH FRAME f_prccon_n.
          
          CLOSE QUERY q-conve.
          HIDE FRAME f-conve.
       END.

    RETURN "OK".
    
END PROCEDURE.
