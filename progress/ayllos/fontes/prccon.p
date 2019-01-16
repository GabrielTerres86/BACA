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
               
               09/01/2018 - Inclusao do processamento de convenios Bancoob - PRJ406.

			   10/12/2018 - Remoção script login_cifs_mount.sh (Wagner da Silva - #INC0027407)
                            
............................................................................ */

{ sistema/generico/includes/var_internet.i } 
{ includes/var_online.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/gera_erro.i}

DEF STREAM str_1.

DEF VAR tel_pesquisa AS CHAR        FORMAT "x(20)"                     NO-UNDO.
DEF VAR tel_cddopcao AS CHAR        FORMAT "!(1)"                      NO-UNDO.
DEF VAR tel_cdcooper AS CHAR        FORMAT "x(20)" VIEW-AS COMBO-BOX   
                                                   INNER-LINES 11      NO-UNDO.

DEF VAR tel_cdempres AS CHAR        FORMAT "x(10)"                     NO-UNDO.
DEF VAR tel_nmextcon LIKE crapcon.nmextcon                             NO-UNDO.

DEF VAR aux_cdcooper LIKE crapcop.cdcooper                             NO-UNDO.
DEF VAR aux_cdcritic LIKE crapcri.cdcritic                             NO-UNDO.
DEF VAR aux_dscritic LIKE crapcri.dscritic                             NO-UNDO.
DEF VAR aux_nmcooper AS CHAR                                           NO-UNDO.
DEF VAR aux_nmextcon AS CHAR                                           NO-UNDO.
DEF VAR xml_req      AS LONGCHAR                                       NO-UNDO.
DEF VAR ponteiro_xml AS MEMPTR                                         NO-UNDO.
DEF VAR aux_cont_raiz AS INTEGER                                       NO-UNDO. 
DEF VAR aux_cont     AS INTEGER                                        NO-UNDO.
DEF VAR xDoc         AS HANDLE                                         NO-UNDO.   
DEF VAR xRoot        AS HANDLE                                         NO-UNDO.  
DEF VAR xRoot2       AS HANDLE                                         NO-UNDO.  
DEF VAR xField       AS HANDLE                                         NO-UNDO. 
DEF VAR xText        AS HANDLE                                         NO-UNDO. 
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nomedarq AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR        FORMAT "!"                         NO-UNDO.
DEF VAR aux_tamarqui AS CHAR                                           NO-UNDO.
DEF VAR tel_datadlog AS DATE        FORMAT "99/99/9999"                NO-UNDO.
DEF VAR tel_opagente AS CHAR        FORMAT "x(12)" VIEW-AS COMBO-BOX   
                                                   INNER-LINES 2       NO-UNDO.

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
    
DEF QUERY q-conve FOR tt-convenios.

DEF BROWSE b-conve QUERY q-conve
      DISP SPACE(2)
           cdempres                     COLUMN-LABEL "Codigo"
           SPACE(1)
           nmextcon                     COLUMN-LABEL "Nome"
           WITH 7 DOWN OVERLAY NO-BOX.

DEF FRAME f-conve
          b-conve HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 9 VIEW-AS DIALOG-BOX.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao    AT 09 LABEL "Opcao" AUTO-RETURN
                           HELP  "Informe a opcao desejada (I, B ou L)."
                           VALIDATE(CAN-DO("L,I,B",glb_cddopcao), "014 - Opcao errada.")
     tel_opagente    AT 35 LABEL "Agente"
                           HELP "Selecione o agente"
                           WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_prccon.

FORM tel_datadlog    AT 06 LABEL "Data Log"
                           HELP "Informe a data para visualizar LOG"
     tel_pesquisa    AT 32 LABEL "Pesquisar"
                           HELP "Informe texto a pesquisar (espaco em branco, tudo)."
                           WITH ROW 8 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_prccon_l.

FORM tel_cdcooper    AT 03 LABEL "Cooperativa"
                           HELP "Selecione a Cooperativa"
                           WITH ROW 8 COLUMN 2 NO-LABELS SIDE-LABELS OVERLAY NO-BOX FRAME f_prccon_m.

FORM tel_cdempres    AT 06 LABEL "Convenio"
                           HELP "Informe o Cod.Convenio / F7 Consulta ou 0 para TODOS."
     tel_nmextcon    AT 28
                           WITH ROW 10 COLUMN 2 NO-LABELS SIDE-LABELS OVERLAY NO-BOX FRAME f_prccon_n.

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

DO:
  FOR EACH crapcop WHERE crapcop.cdcooper <> 3 AND
                         crapcop.flgativo = TRUE NO-LOCK
                      BY crapcop.dsdircop:
   
  IF aux_contador = 0 THEN
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
  
END.


DO:
  ASSIGN aux_contador = 0.  
  
  EMPTY TEMP-TABLE tt-convenios.
  
  RUN pi-busca-convenio (INPUT INT(tel_cdempres)
                        ,INPUT '0').
  
  FOR EACH tt-convenios:
  IF aux_contador = 0 THEN
    ASSIGN aux_nmextcon = "TODOS,0," + 
                          CAPS(tt-convenios.nmextcon) + "," +
                          STRING(tt-convenios.cdempres)
           aux_contador = 1.
  ELSE
    ASSIGN aux_nmextcon = aux_nmextcon + "," +
                          CAPS(tt-convenios.nmextcon) + "," +
                          STRING(tt-convenios.cdempres).
  END.

  ASSIGN tel_cdempres:LIST-ITEM-PAIRS = aux_nmextcon.
END.

ASSIGN tel_opagente:LIST-ITEM-PAIRS = "Sicredi,S,Bancoob,B".

ON RETURN OF tel_cdcooper DO:

   ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE.
   ASSIGN aux_contador = 0.
   APPLY "GO".

END.

ON RETURN OF tel_cdempres DO:

   ASSIGN tel_cdempres = tel_cdempres:SCREEN-VALUE.
   ASSIGN aux_contador = 0.
   APPLY "GO".

END.

VIEW FRAME f_moldura.
PAUSE(0).

prccon:
DO WHILE TRUE:

    HIDE tel_opagente IN FRAME f_prccon NO-PAUSE.
    HIDE tel_cdcooper IN FRAME f_prccon_m.
    HIDE tel_cdempres tel_nmextcon IN FRAME f_prccon_n.
    HIDE tel_datadlog tel_pesquisa IN FRAME f_prccon_l.

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
                    HIDE FRAME f_prccon NO-PAUSE.
                    HIDE FRAME f_moldura NO-PAUSE.
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

    IF glb_cddopcao = "B"   THEN
      DO:
        HIDE tel_datadlog tel_pesquisa IN FRAME f_prccon_l.
        
        DO WHILE TRUE ON ENDKEY UNDO, NEXT prccon:
          
          UPDATE tel_opagente WITH FRAME f_prccon.
                
          IF tel_opagente = "S" THEN
            DO:
              HIDE tel_cdcooper IN FRAME f_prccon_m.
              HIDE tel_cdempres tel_nmextcon IN FRAME f_prccon_n.
              LEAVE.
            END.
          ELSE
            DO: 
              ASSIGN tel_cdempres = "0"
                     tel_nmextcon = "TODOS".
              DISPLAY tel_cdempres tel_nmextcon WITH FRAME f_prccon_n.
              /*Cooperativa*/
              UPDATE tel_cdcooper WITH FRAME f_prccon_m.
              
              /*Convenio*/
              empres:
              DO WHILE TRUE ON ENDKEY UNDO, NEXT prccon:
                UPDATE tel_cdempres WITH FRAME f_prccon_n
                  EDITING:
      
                    READKEY.
                    IF  LASTKEY =  KEYCODE("F7") THEN
                      DO:
                        RUN pi-exibe-browse.
                      END.
                        
                    APPLY LASTKEY.
                  END. /* Editing */
                  IF tel_cdempres <> '0' THEN
                    DO:
                      FIND tt-convenios WHERE tt-convenios.cdempres = tel_cdempres NO-LOCK NO-ERROR.
                        IF AVAIL tt-convenios THEN
                          DO:
                            ASSIGN tel_nmextcon = tt-convenios.nmextcon.
                            DISPLAY tel_nmextcon WITH FRAME f_prccon_n.
                          END.
                        ELSE
                          DO:
                             MESSAGE "Convenio nao encontrado.".
                             NEXT empres.
                          END.
                    END.
                  ELSE
                    DO:
                       ASSIGN tel_nmextcon = "TODOS".
                       DISPLAY tel_nmextcon WITH FRAME f_prccon_n.
                    END.
                  LEAVE.
              END.
                  
            END.
            LEAVE.
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
            ASSIGN aux_confirma = "N".
            RUN fontes/confirma.p (INPUT  "Exportar o(s) arquivo(s) do Bancoob?",
                                   OUTPUT aux_confirma).

            IF  aux_confirma <> "S" THEN 
              NEXT.
              
            MESSAGE "Realizando exportacao dos arquivos...".
            
            RUN pc_gera_arrecadacao.
            
            ASSIGN tel_cdcooper = ""
                   tel_cdempres = ""
                   tel_nmextcon = "".
            
            HIDE tel_cdcooper IN FRAME f_prccon_m.
            HIDE tel_cdempres tel_nmextcon IN FRAME f_prccon_n.
            
            HIDE MESSAGE NO-PAUSE.
            MESSAGE "Exportacao finalizada!".
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
            HIDE tel_datadlog tel_pesquisa IN FRAME f_prccon_l.
        END.
END.

PROCEDURE pi-busca-convenio:

  DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper NO-UNDO.
  DEF INPUT  PARAM par_cdempres AS CHAR NO-UNDO.
  
  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

  /* Efetuar a chamada da rotina Oracle */ 
  RUN STORED-PROCEDURE pc_busca_convenios_bcb
      aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper, /*Cooperativa*/
                                          INPUT par_cdempres, /*Convenio   */
                                         OUTPUT "",           /*Saida OK/NOK */
                                         OUTPUT ?,            /*Tab. retorno */
                                         OUTPUT 0,            /*Cod. critica */
                                         OUTPUT "").          /*Desc. critica*/

  /* Fechar o procedimento para buscarmos o resultado */ 
  CLOSE STORED-PROC pc_busca_convenios_bcb
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }HIDE MESSAGE NO-PAUSE.

  /* Busca possíveis erros */ 
  ASSIGN aux_cdcritic = 0
         aux_dscritic = ""
         aux_cdcritic = pc_busca_convenios_bcb.pr_cdcritic 
                        WHEN pc_busca_convenios_bcb.pr_cdcritic <> ?
         aux_dscritic = pc_busca_convenios_bcb.pr_dscritic 
                        WHEN pc_busca_convenios_bcb.pr_dscritic <> ?.

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
  ASSIGN xml_req = pc_busca_convenios_bcb.pr_clob_ret.

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
  
  CREATE tt-convenios.
  ASSIGN tt-convenios.cdempres = "0"
         tt-convenios.nmextcon = "TODOS".
         
  MESSAGE "Processando XML...".
  
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

PROCEDURE pc_gera_arrecadacao.

    /*Chamada da rotina ORACLE pc_gera_arrecadacao_bancoob proveniente da package PAGA003*/
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

    /* Gera os arquivos de arrecadacao bancoob */ 
    RUN STORED-PROCEDURE pc_gera_arrecadacao_bancoob
       aux_handproc = PROC-HANDLE NO-ERROR
                               (INPUT INT(tel_cdcooper),
                                INPUT tel_cdempres,
                               OUTPUT "").

    CLOSE STORED-PROC pc_gera_arrecadacao_bancoob
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_SICR0001_obtem_agen_deb.pr_dscritic 
                          WHEN pc_SICR0001_obtem_agen_deb.pr_dscritic <> ?.

   IF aux_dscritic <> "" THEN
     DO:
         ASSIGN glb_dscritic = aux_dscritic.
         RETURN "NOK".
     END.
                
 END PROCEDURE.

PROCEDURE pi-exibe-browse:

  DO:
    OPEN QUERY q-conve FOR EACH tt-convenios
                             BY tt-convenios.cdempres
                             BY tt-convenios.nmextcon.

    IF NOT AVAIL tt-convenios THEN
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
