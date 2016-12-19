/*..............................................................................

    Programa: fontes/prcged.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Guilherme Luis Maba
    Data    : Maio/2012                   Ultima atualizacao: 06/12/2016

    Dados referentes ao programa:

    Frequencia: Diario.
    Objetivo  : Rotina de digitalização de documentos. Opções para gerar
                batimento e visualização de LOG.

    Alteracoes: 09/07/2013 - Adicionado parametro para 'efetua_batimento_ged'
                             (Lucas).

                28/11/2013 - Alteração da procedure efetua_batimento_ged,
                             inclusao do parametro de retorno par_nmarqcre
                             (Jean Michel).

                23/01/2014 - Alteração n chamada da procedure efetua_batimento_ged,
                             inclusao de novos campos na tela (Jean Michel).

                06/02/2014 - Incluir na opcao "B" validacao de confirmacao
                             antes de efetuar o batimento "aux_confirma"
                             (Lucas R.)

                20/02/2014 - Alterado 132col por 234dh na impressao do cadastro
                             (Lucas R.)

                06/03/2014 - Incluir novo tipo de opcao para gerar batimento
                             Matricula,3 (Lucas R.)

                07/07/2014 - Novo relatorio para contole interno. (Chamado
                             143037) (Jonata-RKAM)

                31/07/2015 - Opção para todos os relatórios foi alterada para
                             para 0, enquanto a opção 4 foi alterada para ser
                             utilizada para o novo relatório de termos.
                             Projeto 158 Folha de Pagamento (Lombardi)

                15/03/2016 - Desabilitar batimento de credito para a viacredi
                             (Lucas Ranghetti #394316 )

				        25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).
                
                14/10/2016 - Retirar validacao que desabilitava o batimento do credito para a Viacredi 
                             (Lucas Ranghetti #510032)
                
                06/12/2016 - Alterado campo dsdepart para cddepart.
                             PRJ341 - BANCENJUD (Odirlei-AMcom)
                             
.............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0137tt.i }
{ sistema/generico/includes/var_internet.i }

DEF STREAM str_2.
DEF VAR tel_datadlog AS DATE        FORMAT "99/99/9999"                NO-UNDO.
DEF VAR tel_pesquisa AS CHAR        FORMAT "x(20)"                     NO-UNDO.
DEF VAR tel_cddopcao AS CHAR        FORMAT "!(1)"                      NO-UNDO.
DEF VAR aux_tamarqui AS CHAR                                           NO-UNDO.
DEF VAR aux_nomedarq AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_flgerros AS LOGICAL                                        NO-UNDO.
DEF VAR h-b1wgen0137 AS HANDLE                                         NO-UNDO.
DEF VAR aux_nmcooper AS CHAR                                           NO-UNDO.
DEF VAR aux_contador AS INT         INIT 0                             NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqcre AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqmat AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqter AS CHAR                                           NO-UNDO.
DEF VAR tel_cdcooper AS CHAR        FORMAT "x(12)"           VIEW-AS COMBO-BOX
                                                       INNER-LINES 11  NO-UNDO.
DEF VAR tel_datafina AS DATE        FORMAT "99/99/9999"                NO-UNDO.
DEF VAR tel_datainic AS DATE        FORMAT "99/99/9999"                NO-UNDO.
DEF VAR tel_emailbat AS CHAR        FORMAT "x(300)"                    NO-UNDO.
DEF VAR aux_qtdmeses AS DEC         INIT 0                             NO-UNDO.
DEF VAR tel_tipopcao AS CHAR        FORMAT "x(12)"           VIEW-AS COMBO-BOX
                                                         INNER-LINES 5 NO-UNDO.

/* variaveis para impressao */
DEF VAR tel_dsimprim AS CHAR        FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF VAR tel_dscancel AS CHAR        FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF VAR aux_nmendter AS CHAR        FORMAT "x(20)"                     NO-UNDO.
DEF VAR par_flgrodar AS LOGICAL INIT TRUE                              NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                        NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                              NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                        NO-UNDO.
DEF VAR tel_dsdemail AS CHAR     FORMAT "x(40)" EXTENT 6               NO-UNDO.

DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.

FORM tel_datadlog    AT 10 LABEL "Data Log"
                           HELP "Informe a data para visualizar LOG"
     tel_pesquisa    AT 32 LABEL "Pesquisar"
                           HELP "Informe texto a pesquisar (espaco em branco, tudo)."
                           WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_prcged_l.

FORM tel_cdcooper    AT 07 LABEL "Cooperativa"
                           HELP "Selecione a Cooperativa"
     tel_tipopcao    AT 37 LABEL "Tipo"
                           HELP "Selecione o tipo de batimento."
                           VALIDATE(CAN-DO("0,1,2,3,4",tel_tipopcao), "014 - Opcao errada.")

                           WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_cooperativas.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao    AT 03 LABEL "Opcao" AUTO-RETURN
                           HELP  "Informe a opcao desejada (B, L ou R)."
                           VALIDATE(CAN-DO("B,L,R",glb_cddopcao), "014 - Opcao errada.")
                           WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_prcged.

FORM tel_datainic AT 03 LABEL "Data Inicial"
     tel_datafina AT 28 LABEL "Data Final"
     SKIP(1)
     tel_dsdemail[1] AT 15 LABEL " Emails para envio"
     HELP "Informe e-mails para envio."
     tel_dsdemail[2] AT 35 NO-LABEL
     HELP "Informe e-mails para envio."
     tel_dsdemail[3] AT 35 NO-LABEL
     HELP "Informe e-mails para envio."
     tel_dsdemail[4] AT 35 NO-LABEL
     HELP "Informe e-mails para envio."
     tel_dsdemail[5] AT 35 NO-LABEL
     HELP "Informe e-mails para envio."
     tel_dsdemail[6] AT 35 NO-LABEL
     HELP "Informe e-mails para envio."
     SKIP(1)
     WITH ROW 8 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_datas.

ON RETURN OF tel_cdcooper DO:

    ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE IN FRAME f_cooperativas
           aux_contador = 0.

    IF   glb_cddopcao = "B"   THEN
         APPLY "TAB".
    ELSE
         APPLY "GO".

END.

ON RETURN OF tel_tipopcao DO:

    ASSIGN tel_tipopcao = tel_tipopcao:SCREEN-VALUE IN FRAME f_cooperativas.

    APPLY "GO".
END.

ASSIGN glb_cddopcao = "B"
       glb_cdcritic = 0
       aux_nmarqlog = "prcged_" +
                      STRING(YEAR(glb_dtmvtolt),"9999") +
                      STRING(MONTH(glb_dtmvtolt),"99") +
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).

DO WHILE TRUE:

   /* limpa e esconde frame da opção "B" e "L" */
   CLEAR FRAME f_cooperativas NO-PAUSE.
   CLEAR FRAME f_prcged_l NO-PAUSE.
   CLEAR FRAME f_datas   NO-PAUSE.
   HIDE  FRAME f_cooperativas NO-PAUSE.
   HIDE  FRAME f_prcged_l NO-PAUSE.
   HIDE  FRAME f_datas   NO-PAUSE.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       IF   glb_cdcritic > 0   THEN
            DO:
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                glb_cdcritic = 0.
                PAUSE 2 NO-MESSAGE.
            END.

       UPDATE glb_cddopcao WITH FRAME f_prcged.

       LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN DO: /*   F4 OU FIM   */
        RUN fontes/novatela.p.
        IF   CAPS(glb_nmdatela) <> "PRCGED"  THEN DO:
             HIDE FRAME f_prcged.
             HIDE FRAME f_moldura.
             HIDE MESSAGE NO-PAUSE.
             RETURN.
        END.
        ELSE
             NEXT.
   END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF  glb_cddopcao = "B"   THEN
   DO:
      /* verifica permissão para rotina de batimento */
      IF glb_cdcooper =  3   AND
         glb_cddepart <> 20  THEN /*TI*/
      DO:
            BELL.
            MESSAGE "Sem autorizacao para opcao 'B'.".
            NEXT.
      END.

      ASSIGN aux_flgerros = FALSE.

      /* Alimenta SELECTION-LIST de COOPERATIVAS */
      RUN alimenta-selection (INPUT TRUE).

      tel_tipopcao = "0".

      ASSIGN tel_cdcooper:LIST-ITEM-PAIRS IN FRAME f_cooperativas = aux_nmcooper
             tel_tipopcao:LIST-ITEM-PAIRS IN FRAME f_cooperativas = "Todos,0,Cadastro,1,Credito,2,Matricula,3,Termos,4".

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
          UPDATE tel_cdcooper tel_tipopcao WITH FRAME f_cooperativas.
          UPDATE tel_datainic tel_datafina tel_dsdemail WITH FRAME f_datas.
          LEAVE.
      END.

      DO aux_contador = 1 TO 6:
        IF tel_dsdemail[aux_contador] <> "" AND aux_contador = 1 THEN
            ASSIGN tel_emailbat = TRIM(tel_dsdemail[aux_contador]).
        ELSE IF  tel_dsdemail[aux_contador] <> "" AND aux_contador = 6 THEN
            ASSIGN tel_emailbat = tel_emailbat + "," + TRIM(tel_dsdemail[aux_contador]).
        ELSE IF  tel_dsdemail[aux_contador] <> "" THEN
            ASSIGN tel_emailbat = tel_emailbat + "," + TRIM(tel_dsdemail[aux_contador]).

      END.

      IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
      DO:
          HIDE FRAME f_cooperativas NO-PAUSE.
          HIDE FRAME f_datas   NO-PAUSE.
          NEXT.
      END.

      aux_qtdmeses = (tel_datafina - tel_datainic) / 30.

      IF  aux_qtdmeses > 3  THEN
        DO:
            MESSAGE "Nao e possivel realizar o batimento em um periodo superior a 3 meses".
            BELL.
            CLEAR FRAME f_dados.
            NEXT.
        END.

      IF  tel_datafina = ? OR  tel_datainic = ? THEN
        DO:
            MESSAGE "Informe as datas para realizar o batimento".
            BELL.
            CLEAR FRAME f_dados.
            NEXT.
        END.

      RUN fontes/confirma.p (INPUT "",
                            OUTPUT aux_confirma).

      IF   aux_confirma <> "S"   THEN
           NEXT.

      MESSAGE "Aguarde, efetuando batimento das informacoes ...".

      IF  INTE(tel_cdcooper) = 0  THEN
          DO:
              FOR EACH crapcop NO-LOCK:
                  RUN GeraBatimento (INPUT crapcop.cdcooper,
                                     INPUT tel_datainic,
                                     INPUT tel_datafina,
                                     INPUT tel_emailbat,
                                     INPUT INT(tel_tipopcao),
                                     INPUT crapcop.nmrescop,
                                     INPUT aux_nmarqlog).
              END.
          END.
      ELSE
          DO:
              FIND crapcop WHERE crapcop.cdcooper = INTE(tel_cdcooper) NO-LOCK NO-ERROR.

              RUN GeraBatimento (INPUT INTE(tel_cdcooper),
                                 INPUT tel_datainic,
                                 INPUT tel_datafina,
                                 INPUT tel_emailbat,
                                 INPUT INT(tel_tipopcao),
                                 INPUT crapcop.nmrescop,
                                 INPUT aux_nmarqlog).


          END. /* end if */

      HIDE MESSAGE NO-PAUSE.

      IF  aux_flgerros THEN
          DO:
              MESSAGE "Batimento efetuado com ERRO, favor verificar " +
                      "log pela opcao L.".
              PAUSE 6 NO-MESSAGE.
          END.
      ELSE DO:
          MESSAGE "Batimento efetuado com sucesso.".
          PAUSE 4 NO-MESSAGE.
      END.

   END. /* END do IF "B" */
   ELSE
   IF glb_cddopcao = "L" THEN DO: /* opção L(LOG) */

      RUN MostraLog.

   END. /* END do IF "L" */
   ELSE
   IF   glb_cddopcao = "R"   THEN
        DO:
            RUN alimenta-selection (INPUT FALSE).

            ASSIGN tel_cdcooper:LIST-ITEM-PAIRS IN FRAME f_cooperativas = aux_nmcooper.

            tel_tipopcao = "2".
            tel_tipopcao:LIST-ITEM-PAIRS IN FRAME f_cooperativas = "Credito,2".

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               UPDATE tel_cdcooper
                      tel_tipopcao
                      WITH FRAME f_cooperativas.
               LEAVE.
            END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 NEXT.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               UPDATE tel_datainic
                      tel_datafina
                      tel_dsdemail
                      WITH FRAME f_datas.

               IF  tel_datafina = ? OR  tel_datainic = ? THEN
                   DO:
                       MESSAGE "Informe as datas para continuar.".
                       NEXT.
                   END.

               LEAVE.
            END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 NEXT.

            DO aux_contador = 1 TO 6:
                IF tel_dsdemail[aux_contador] <> "" AND aux_contador = 1 THEN
                   ASSIGN tel_emailbat = TRIM(tel_dsdemail[aux_contador]).
                ELSE IF tel_dsdemail[aux_contador] <> "" AND aux_contador = 6 THEN
                   ASSIGN tel_emailbat = tel_emailbat + "," + TRIM(tel_dsdemail[aux_contador]).
                ELSE IF  tel_dsdemail[aux_contador] <> "" THEN
                   ASSIGN tel_emailbat = tel_emailbat + "," + TRIM(tel_dsdemail[aux_contador]).
            END.

            RUN fontes/confirma.p (INPUT "",
                                  OUTPUT aux_confirma).

            IF   aux_confirma <> "S"   THEN
                 NEXT.

            MESSAGE "Consultando dados ...".

            RUN sistema/generico/procedures/b1wgen0137.p
                PERSISTENT SET h-b1wgen0137.

            RUN gera_dados_pendencias IN h-b1wgen0137 (INPUT tel_cdcooper,
                                                       INPUT glb_dtmvtolt,
                                                       INPUT tel_datainic,
                                                       INPUT tel_datafina,
                                                       INPUT tel_emailbat,
                                                      OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0137.

            IF  RETURN-VALUE <> "OK"   THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF   AVAIL tt-erro   THEN
                         MESSAGE tt-erro.dscritic.
                    ELSE
                         MESSAGE "Erro na geracao do relatorio.".

                    NEXT.
                END.

            HIDE MESSAGE NO-PAUSE.
            MESSAGE "E-mail enviado com sucesso!".
            PAUSE 3 NO-MESSAGE.
            HIDE MESSAGE.
            NEXT.

        END.

END. /* FIM - DO WHILE TRUE */

/* PROCEDURE para gerar batimento */
PROCEDURE GeraBatimento:

    DEF  INPUT PARAM par_cdcooper AS INTE   NO-UNDO.
    DEF  INPUT PARAM par_datainic AS DATE   NO-UNDO.
    DEF  INPUT PARAM par_datafina AS DATE   NO-UNDO.
    DEF  INPUT PARAM par_emailbat AS CHAR   NO-UNDO.
    DEF  INPUT PARAM par_tipopcao AS INT    NO-UNDO.
    DEF  INPUT PARAM par_nmrescop AS CHAR   NO-UNDO.
    DEF  INPUT PARAM par_nmarqlog AS CHAR   NO-UNDO.

    DEF VAR aux_dstipoop AS CHAR            NO-UNDO.    
    
    CASE par_tipopcao:
      WHEN 0 THEN aux_dstipoop = "Todos".
      WHEN 1 THEN aux_dstipoop = "Cadastro".
      WHEN 2 THEN aux_dstipoop = "Credito".
      WHEN 3 THEN aux_dstipoop = "Matricula".
      WHEN 4 THEN aux_dstipoop = "Termos".
    END.    
    
    RUN sistema/generico/procedures/b1wgen0137.p PERSISTENT SET h-b1wgen0137.

    IF  NOT VALID-HANDLE(h-b1wgen0137) THEN
    DO:
        ASSIGN glb_cdcritic = 0
               glb_dscritic = "Handle invalido para h-b1wgen0137".

        /* Grava o LOG */
        UNIX SILENT VALUE("echo "          + STRING(glb_dtmvtolt,"99/99/9999")  +
                          " - "            + STRING(TIME,"HH:MM:SS")            +
                          " Operador: "    + glb_cdoperad + " --- "             +
                          "Batimento efetuado. Coop: " + par_nmrescop           +
                          ", Data inicio: " + STRING(par_datainic,"99/99/9999") +
                          ", Data fim: " + STRING(par_datafina,"99/99/9999")    +
                          ", Tipo: " + aux_dstipoop + ", "                      +
                          glb_dscritic                                          +
                          " >> /usr/coop/cecred/log/" + par_nmarqlog).
                RETURN.
        END.   

    RUN efetua_batimento_ged IN h-b1wgen0137 (INPUT par_cdcooper,
                                              INPUT par_datainic,
                                              INPUT par_datafina,
                                              INPUT par_emailbat,
                                              INPUT 1, /* 0 - Batch / 1 - Tela */
                                              INPUT par_tipopcao,
                                              OUTPUT aux_nmarqimp,
                                              OUTPUT aux_nmarqcre,
                                              OUTPUT aux_nmarqmat,
                                              OUTPUT aux_nmarqter,
                                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            MESSAGE "ERRO" VIEW-AS ALERT-BOX INFO BUTTONS OK.
            FIND LAST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
                ASSIGN glb_dscritic = tt-erro.dscritic + " Coop: " +
                                      STRING(par_nmrescop).
            ELSE
                ASSIGN glb_dscritic = "Nao foi possivel efetuar o batimento " +
                                      "da digitalizacao de documentos. "      +
                                      "Coop: " + STRING(par_nmrescop).

            /* Grava o LOG */
            UNIX SILENT VALUE
                        ("echo "          + STRING(glb_dtmvtolt,"99/99/9999") +
                        " - "            + STRING(TIME,"HH:MM:SS")            +
                        " Operador: "    + glb_cdoperad + " --- "             +
                        "Batimento efetuado. Coop: " + par_nmrescop           +
                        ", Data inicio: " + STRING(par_datainic,"99/99/9999") +
                        ", Data fim: " + STRING(par_datafina,"99/99/9999")    +
                        ", Tipo: " + aux_dstipoop + ", "                      +
                        glb_dscritic                                          +
                        " >> /usr/coop/cecred/log/" + par_nmarqlog).
            ASSIGN aux_flgerros = TRUE.

            DELETE PROCEDURE h-b1wgen0137.

            RETURN "NOK".
        END.

    IF  VALID-HANDLE(h-b1wgen0137) THEN
        DELETE PROCEDURE h-b1wgen0137.

    IF aux_nmarqimp <> "" AND aux_nmarqimp <> ? THEN
        DO:
            ASSIGN glb_nmformul = "234dh"
               glb_nmarqimp = aux_nmarqimp
               glb_nrcopias = 1.

            RUN fontes/imprim_unif.p (INPUT INTE(par_cdcooper)).
        END.


    IF aux_nmarqcre <> "" AND aux_nmarqcre <> ? THEN
        DO:

            ASSIGN glb_nmformul = "132col"
                   glb_nmarqimp = aux_nmarqcre
                   glb_nrcopias = 1.

            RUN fontes/imprim_unif.p (INPUT INTE(par_cdcooper)).
        END.

    IF aux_nmarqmat <> "" AND aux_nmarqmat <> ? THEN
        DO:

            ASSIGN glb_nmformul = "132col"
                   glb_nmarqimp = aux_nmarqmat
                   glb_nrcopias = 1.

            RUN fontes/imprim_unif.p (INPUT INTE(par_cdcooper)).
        END.

    IF aux_nmarqter <> "" AND aux_nmarqter <> ? THEN
        DO:

            ASSIGN glb_nmformul = "132col"
                   glb_nmarqimp = aux_nmarqter
                   glb_nrcopias = 1.

            RUN fontes/imprim_unif.p (INPUT INTE(par_cdcooper)).
        END.   

    /* Grava o LOG */
    UNIX SILENT VALUE
                ("echo "          + STRING(glb_dtmvtolt,"99/99/9999")  +
                 " - "            + STRING(TIME,"HH:MM:SS")            +
                 " Operador: "    + glb_cdoperad + " --- "             +
                 "Batimento efetuado. Coop: " + par_nmrescop           +
                 ", Data inicio: " + STRING(par_datainic,"99/99/9999") +
                 ", Data fim: " + STRING(par_datafina,"99/99/9999")    +
                 ", Tipo: " + aux_dstipoop +
                 " >> /usr/coop/cecred/log/" + par_nmarqlog).


    RETURN "OK".

END PROCEDURE. /* END GeraBatimento */

/* PROCEDURE visualiza log debatimentos de determinada data e/ou pesquisa */
PROCEDURE MostraLog:

    HIDE MESSAGE NO-PAUSE.

    ASSIGN tel_pesquisa = "".

    VIEW FRAME f_prcged_l.

    ASSIGN tel_datadlog = glb_dtmvtolt.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE tel_datadlog WITH FRAME f_prcged_l.
        UPDATE tel_pesquisa WITH FRAME f_prcged_l.
        LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN DO: /* F4 OU FIM */
        HIDE tel_datadlog tel_pesquisa IN FRAM f_prcged_l.
        NEXT.
    END.

    ASSIGN aux_nmarqimp = "log/prcged_" +
                          STRING(YEAR(tel_datadlog),"9999") +
                          STRING(MONTH(tel_datadlog),"99") +
                          STRING(DAY(tel_datadlog),"99") + ".log".

    IF SEARCH(aux_nmarqimp) = ? THEN DO:
        MESSAGE "NAO HA REGISTRO DE LOG PARA ESTA DATA!".
        PAUSE 1 NO-MESSAGE.
        RETURN.
    END.

    /* nome do arquivo temporário */
    ASSIGN aux_nomedarq = "log/tmp_ged_" + STRING(TIME).

    IF TRIM(tel_pesquisa) = "" THEN
         UNIX SILENT VALUE("cp " + aux_nmarqimp + " " + aux_nomedarq).
    ELSE
         UNIX SILENT VALUE ("grep -i '" + tel_pesquisa + "' " + aux_nmarqimp +
                            " > "   + aux_nomedarq + " 2> /dev/null").

    aux_nmarqimp = aux_nomedarq.

    /* Verifica se o arquivo esta vazio e critica */
    INPUT STREAM str_2 THROUGH VALUE( "wc -m " +
                                       aux_nmarqimp + " 2> /dev/null")
                                     NO-ECHO.

    SET STREAM str_2 aux_tamarqui FORMAT "x(30)".

    IF INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0 THEN DO:
        BELL.
        MESSAGE "Nenhuma ocorrencia encontrada.".
        INPUT STREAM str_2 CLOSE.
        NEXT.
    END.

    /* inicializa com opção T(Terminal) */
    ASSIGN tel_cddopcao = "T".

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.
        LEAVE.
    END.

    IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        NEXT.

    IF   tel_cddopcao = "T" THEN
        RUN fontes/visrel.p (INPUT aux_nmarqimp).
    ELSE
    IF tel_cddopcao = "I" THEN DO:
            /* somente para o includes/impressao.i */
            FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                     NO-LOCK NO-ERROR.

            { includes/impressao.i }
    END.
    ELSE DO:
        glb_cdcritic = 14.
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic.
        glb_cdcritic = 0.
        NEXT.
    END.

    /* apaga arquivo temporario */
    IF aux_nomedarq <> "" THEN
        UNIX SILENT VALUE ("rm " + aux_nomedarq + " 2> /dev/null").

END PROCEDURE. /* END MostraLog */

PROCEDURE alimenta-selection:

    DEF INPUT PARAM par_flgtodas AS LOGI                       NO-UNDO.


    ASSIGN aux_contador = 0
           aux_nmcooper = "".

    IF  glb_cdcooper = 3  THEN
        FOR EACH crapcop NO-LOCK BY crapcop.dsdircop:

            IF   aux_contador = 0 THEN
                 DO:
                     ASSIGN aux_contador = 1.

                     IF   par_flgtodas THEN
                          ASSIGN aux_nmcooper = "TODAS,0," +
                                                CAPS(crapcop.dsdircop) + "," +
                                                STRING(crapcop.cdcooper).
                    ELSE
                          ASSIGN aux_nmcooper = CAPS(crapcop.dsdircop) + "," +
                                                STRING(crapcop.cdcooper).
                 END.
            ELSE
                 ASSIGN aux_nmcooper = aux_nmcooper + "," + CAPS(crapcop.dsdircop)
                                       + "," + STRING(crapcop.cdcooper).
          END.
    ELSE
         FOR EACH crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK:

             ASSIGN aux_nmcooper = CAPS(crapcop.dsdircop)
                                   + "," + STRING(crapcop.cdcooper).
         END.

END PROCEDURE.

/* .........................................................................*/


