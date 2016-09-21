/* .............................................................................

   Programa: fontes/contas_imunidade.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Julho/2006                          Ultima Atualizacao: 18/07/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados referentes a Imunidade Tributaria.

   Alteracoes:

..............................................................................*/

{ sistema/generico/includes/b1wgen0159tt.i }
{ sistema/generico/includes/var_internet.i }

{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF INPUT PARAM par_cdcooper LIKE crapass.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_nrcpfcgc LIKE crapass.nrcpfcgc                     NO-UNDO.
DEF INPUT PARAM par_nmdatela AS CHAR                                   NO-UNDO.

/* Variaveis para impressao */
DEF VAR tel_dsimprim AS CHAR             FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF VAR tel_dscancel AS CHAR             FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                           NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR par_flgrodar AS LOGI                                           NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                           NO-UNDO.
DEF VAR par_flgcance AS LOGI                                           NO-UNDO.

DEF VAR aux_flgsuces AS LOGICAL                                        NO-UNDO.
DEF VAR aux_flgimuni AS LOGICAL                                        NO-UNDO.
DEF VAR aux_flgedita AS LOG                                            NO-UNDO.

DEF VAR tel_cddopcao AS CHAR             FORMAT "!(1)" INIT "T"        NO-UNDO.

DEF VAR tel_cddentid AS INTE                                           NO-UNDO.
DEF VAR tel_dsdentid AS CHAR                                           NO-UNDO.
DEF VAR tel_dssitcad AS CHAR                                           NO-UNDO.
DEF VAR reg_dsdopcao AS CHAR EXTENT 2 INIT ["Alterar",
                                            "Imprimir"]                NO-UNDO.
DEF VAR reg_cddopcao AS CHAR EXTENT 2 INIT ["A","R"]                   NO-UNDO.
DEF VAR reg_contador AS INTE          INIT 0                           NO-UNDO.
DEF VAR tel_cdsitcad LIKE crapimt.cdsitcad                             NO-UNDO.
DEF VAR aux_dsdentid AS CHAR                           FORMAT "x(60)"  NO-UNDO.
DEF VAR aux_cddentid AS INTE                                           NO-UNDO.
DEF VAR aux_cdsitcad LIKE crapimt.cdsitcad                             NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0159 AS HANDLE                                         NO-UNDO.


DEF QUERY q-entidade FOR tt-entidade.

DEF BROWSE  b-entidade QUERY q-entidade
    DISPLAY tt-entidade.cddentid LABEL "Codigo"     FORMAT "z9"
            tt-entidade.dsdentid LABEL "Entidade"   FORMAT "x(55)"
            WITH CENTERED 5 DOWN TITLE " Entidade ".

FORM b-entidade
     WITH CENTERED NO-BOX OVERLAY ROW 10 COLUMN
                                       3 WIDTH 70 FRAME f_entidade.

FORM  SKIP(1)
      tel_cddentid    AT  1  LABEL "Tipo de Endidade" FORMAT "z9"
      HELP "Entre com Entidade ou pressione <F7> p/ listar."
      tel_dsdentid    AT 23  NO-LABEL                 FORMAT "X(52)"
      SKIP(1)
      tel_cdsitcad    AT  9  LABEL "Situacao"         FORMAT "z9"
      HELP "Informe o Cod. Situacao (3 - Cancelamento)."
      tel_dssitcad    AT 23  NO-LABEL                 FORMAT "X(25)"
      SKIP(2)
      reg_dsdopcao[1] AT 30  NO-LABEL                 FORMAT "x(7)"
      HELP "Pressione ENTER para Alterar / F4 ou END para sair"
      reg_dsdopcao[2] AT 39  NO-LABEL                 FORMAT "x(8)"
      HELP "Pressione ENTER para Imprimir / F4 ou END para sair"
      WITH ROW 12 WIDTH 78 OVERLAY SIDE-LABELS TITLE " IMUNIDADE TRIBUTARIA "
                  CENTERED FRAME f_dados_juridica.

ASSIGN aux_flgsuces = FALSE
       aux_flgimuni = FALSE.

RUN cria-entidade.
RUN cria-situacao.

ON ENTER OF reg_dsdopcao[1] /* Alterar */
DO:
    reg_contador = 1.
END.

ON ENTER OF reg_dsdopcao[2] /* Imprimir */
DO:
    reg_contador = 2.
END.

Principal: DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
    ASSIGN aux_flgsuces = FALSE.

    /* Busca dados de Imunidade Tributaria */
    IF  NOT VALID-HANDLE(h-b1wgen0159) THEN
        RUN sistema/generico/procedures/b1wgen0159.p
        PERSISTENT SET h-b1wgen0159.

    RUN consulta-imunidade-contas
        IN h-b1wgen0159 (INPUT par_cdcooper,
                         INPUT par_nrcpfcgc,
                         OUTPUT TABLE tt-erro,
                         OUTPUT TABLE tt-imunidade).

    IF  VALID-HANDLE(h-b1wgen0159) THEN
        DELETE PROCEDURE h-b1wgen0159.

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro  THEN
                DO:
                    BELL.
                    MESSAGE  tt-erro.dscritic
                        VIEW-AS ALERT-BOX INFO BUTTONS OK.
                END.
            /*LEAVE Principal.*/
        END.

    RUN Exibe-Dados.

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            MESSAGE RETURN-VALUE.
            LEAVE Principal.
        END.

    DISPLAY reg_dsdopcao
       WITH FRAME f_dados_juridica.

    CHOOSE FIELD reg_dsdopcao WITH FRAME f_dados_juridica.

    IF  reg_cddopcao[reg_contador] = "A" THEN DO: /* Alterar */

        Edita: DO WHILE TRUE TRANSACTION:
                  RUN Edita-Dados.

                  IF  RETURN-VALUE <> "OK" THEN
                      NEXT Principal.

                  IF  aux_flgsuces THEN DO:
                      DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                          MESSAGE "Alteracao efetuada com sucesso!".
                          PAUSE NO-MESSAGE.
                          HIDE MESSAGE NO-PAUSE.
                          NEXT Principal.
                      END.
                  END.

                  LEAVE Edita.
               END. /* Fim TRANSACTION */
    END.

    IF  reg_cddopcao[reg_contador] = "R" THEN DO: /* Imprimir */

        Imprimir: DO WHILE TRUE:
                     RUN Impressao-Dados.

                     IF  RETURN-VALUE <> "OK" THEN
                         NEXT Principal.

                     LEAVE Imprimir.
                  END. /* Fim DO WHILE TRUE */
    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
         aux_confirma <> "S"                  THEN
         NEXT Principal.
    ELSE
        DO:
            IF  aux_flgsuces THEN
            NEXT Principal.
        END.

   

END. /* Fim DO WHILE TRUE Principal */

HIDE FRAME f_dados_juridica NO-PAUSE.
HIDE MESSAGE NO-PAUSE.

/*...........................................................................*/

PROCEDURE Exibe-Dados:

    /* Verifica se tem cadastro na crapimt */
    FIND FIRST tt-imunidade NO-LOCK NO-ERROR.

    IF  AVAIL tt-imunidade THEN DO:

        ASSIGN aux_flgimuni = TRUE /* Se encontro registro */
               aux_cddentid = tt-imunidade.cddentid
               aux_cdsitcad = tt-imunidade.cdsitcad
               tel_cdsitcad = tt-imunidade.cdsitcad
               tel_cddentid = tt-imunidade.cddentid
               tel_dsdentid = tt-imunidade.dsdentid
               tel_dssitcad = tt-imunidade.dssitcad.

        DISPLAY tel_cddentid
                tel_dsdentid
                tel_cdsitcad
                tel_dssitcad
                reg_dsdopcao
                WITH FRAME f_dados_juridica.
    END.
    ELSE DO:
        ASSIGN aux_flgimuni = FALSE /* Se nao encontro registro */
             /*  tel_cddentid = 0*/
               aux_cddentid = 0
               aux_cdsitcad = 0.

        VIEW FRAME f_dados_juridica.
    END.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE Edita-Dados:

    ASSIGN glb_nmrotina = "IMUNIDADE TRIBUTARIA"
           glb_cddopcao = "A"
           tel_cddentid = aux_cddentid
           tel_cdsitcad = aux_cdsitcad.

    { includes/acesso.i }

    DISPLAY tel_cddentid
            tel_dsdentid
            tel_cdsitcad WHEN aux_flgimuni = TRUE
            tel_dssitcad WHEN aux_flgimuni = TRUE
            WITH FRAME f_dados_juridica.

    UPDATE tel_cddentid
      WITH FRAME f_dados_juridica
      EDITING:

        READKEY.

            IF  LASTKEY = KEYCODE("F7")   THEN DO:

                IF  FRAME-FIELD = "tel_cddentid"   THEN
                    DO:
                        b-entidade:HELP IN FRAME f_entidade =
                                        "Pressione <ENTER> p/"
                                        + " selecionar " +
                                        "a entidade.".

                        RUN busca_entidade(INPUT-OUTPUT tel_cddentid,
                                           INPUT-OUTPUT tel_dsdentid).

                        DISPLAY tel_cddentid
                                tel_dsdentid
                                WITH FRAME f_dados_juridica.
                END.
                ELSE
                    APPLY LASTKEY.

            END. /* Fim do F7 */
            ELSE
                APPLY LASTKEY.
      END. /* Fim do Editing */

    /* Tratamento quando nao escolher a opcao <F7> */
    IF  tel_cddentid <> aux_cddentid  THEN DO:

        /* Busca a descricao da entidade coforme escolhe o codigo */
        FIND tt-entidade WHERE tt-entidade.cddentid = tel_cddentid
                               NO-LOCK NO-ERROR.

        IF  AVAIL tt-entidade THEN
            DISPLAY tt-entidade.cddentid @ tel_cddentid
                    tt-entidade.dsdentid @ tel_dsdentid
                    WITH FRAME f_dados_juridica.
    END.
    ELSE DO:
        /* Se escolheu uma opcao e depois voltou p/ opcao original */
        FIND tt-entidade WHERE tt-entidade.cddentid = tel_cddentid
                               NO-LOCK NO-ERROR.

        IF  AVAIL tt-entidade THEN
            DISPLAY tt-entidade.cddentid @ tel_cddentid
                    tt-entidade.dsdentid @ tel_dsdentid
                    WITH FRAME f_dados_juridica.
    END.

    /* Verifica se tem registro de imunidade
    e o cod. entidade for o mesmo da tabela */
    ASSIGN aux_flgedita = (aux_flgimuni = TRUE AND
                           tel_cddentid = tt-imunidade.cddentid).

    IF  aux_flgedita = FALSE THEN DO:

        FIND FIRST tt-situacao WHERE tt-situacao.cdsitcad = 0
                                 NO-LOCK NO-ERROR.

        IF  AVAIL tt-situacao THEN
            DISPLAY 0  @ tel_cdsitcad
                    tt-situacao.dssitcad @ tel_dssitcad
                    WITH FRAME f_dados_juridica.

        ASSIGN tel_cdsitcad = 0.

    END.

    UPDATE tel_cdsitcad WHEN aux_flgedita
      WITH FRAME f_dados_juridica.

    RUN busca-situacao(INPUT tel_cdsitcad).

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ASSIGN aux_confirma = "N"
               glb_cdcritic = 78.
        RUN fontes/critic.p.
        BELL.
        glb_cdcritic = 0.
        MESSAGE COLOR NORMAL glb_dscritic
        UPDATE aux_confirma.
        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
        aux_confirma <> "S"                  THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            PAUSE 2 NO-MESSAGE.
            HIDE MESSAGE NO-PAUSE.
            aux_flgsuces = FALSE.
            RETURN "OK".
        END.
    ELSE DO:

           IF  NOT VALID-HANDLE(h-b1wgen0159) THEN
           RUN sistema/generico/procedures/b1wgen0159.p
           PERSISTENT SET h-b1wgen0159.

           RUN gravar-imunidade
                IN h-b1wgen0159 (INPUT glb_cdcooper,
                                 INPUT par_nrcpfcgc,
                                 INPUT tel_cdsitcad,
                                 INPUT tel_cddentid,
                                 INPUT glb_dtmvtolt,
                                 INPUT glb_cdoperad,
                                 INPUT par_nmdatela,
                                 OUTPUT TABLE tt-erro).

           IF  VALID-HANDLE(h-b1wgen0159) THEN
               DELETE PROCEDURE h-b1wgen0159.

           IF  RETURN-VALUE <> "OK" THEN
               DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAIL tt-erro  THEN
                        DO:
                            BELL.
                            MESSAGE tt-erro.dscritic.
                            PAUSE.
                            HIDE MESSAGE NO-PAUSE.
                    END.

                    RETURN "NOK".
               END.
        
        aux_flgsuces = TRUE.

    END.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE Impressao-Dados:

    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.

    aux_confirma = "N".


    DO WHILE TRUE ON END-KEY UNDO , LEAVE:
       MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.
       LEAVE.
    END.

    HIDE MESSAGE NO-PAUSE.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        RETURN.


    /* Busca dados de Imunidade Tributaria */
    IF  NOT VALID-HANDLE(h-b1wgen0159) THEN
        RUN sistema/generico/procedures/b1wgen0159.p
        PERSISTENT SET h-b1wgen0159.

    RUN imprime-imunidade
        IN h-b1wgen0159 (INPUT par_cdcooper,
                         INPUT par_nrcpfcgc,
                         INPUT tel_cddentid,
                         INPUT 1, /* aux_idorigem = 1 AYLLOS */
                         INPUT tel_cddopcao,
                         OUTPUT aux_nmarqimp,
                         OUTPUT aux_nmarqpdf,
                         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0159) THEN
        DELETE PROCEDURE h-b1wgen0159.

    IF  RETURN-VALUE <> "OK" THEN DO:

        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        BELL.
        IF  AVAILABLE tt-erro  THEN DO:
            MESSAGE tt-erro.dscritic.
        END.
        ELSE
            MESSAGE "Erro na geracao do relatorio!".

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           PAUSE.
           LEAVE.
        END.
        NEXT.
    END. /* END do RETURN <> "OK" */

    IF  tel_cddopcao = "T"   THEN
        RUN fontes/visrel.p (INPUT aux_nmarqimp).
    ELSE
    IF  tel_cddopcao = "I"   THEN DO:

        ASSIGN par_flgrodar = TRUE
               glb_nmformul = "80col"
               glb_nrdevias = 1.

        FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                 NO-LOCK NO-ERROR.

        { includes/impressao.i }

    END.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE busca_entidade:

    DEF INPUT-OUTPUT PARAM tel_cddentid AS INTE                       NO-UNDO.
    DEF INPUT-OUTPUT PARAM tel_dsdentid AS CHAR                       NO-UNDO.

    /* Posicionar no Item entrado */
    ON ENTRY OF b-entidade IN FRAME f_entidade DO:

       FIND tt-entidade NO-LOCK NO-ERROR.

       IF   AVAIL tt-entidade  THEN
            REPOSITION q-entidade TO ROWID ROWID(tt-entidade).

    END.

    ON RETURN OF b-entidade IN FRAME f_entidade DO:

        IF   NOT AVAIL tt-entidade THEN
             APPLY "GO".

        ASSIGN tel_cddentid = tt-entidade.cddentid
               tel_dsdentid = tt-entidade.dsdentid.

        APPLY "GO".

    END.

    OPEN QUERY q-entidade
        FOR EACH tt-entidade NO-LOCK
                             BY tt-entidade.cddentid.

    IF   NUM-RESULTS("q-entidade")  = 0  THEN
         RETURN.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       UPDATE b-entidade
              WITH FRAME f_entidade.
       LEAVE.

    END.

    HIDE FRAME f_entidade.

END PROCEDURE.

/*............................................................................*/

PROCEDURE busca-situacao:

    DEF INPUT PARAM tel_cdsitcad AS INTE                              NO-UNDO.

    FIND FIRST tt-situacao WHERE tt-situacao.cdsitcad = tel_cdsitcad
                                 NO-LOCK NO-ERROR.

    IF  AVAIL tt-situacao THEN DO:

        tel_dssitcad = tt-situacao.dssitcad.

        IF  aux_flgedita THEN
            DISPLAY tel_dssitcad
                    WITH FRAME f_dados_juridica.
    END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE cria-entidade:

   /* Procedimento que cria registro de entidade. */
   CREATE tt-entidade.
   ASSIGN tt-entidade.cddentid = 1
          tt-entidade.dsdentid = "Templo de qualquer culto".

   CREATE tt-entidade.
   ASSIGN tt-entidade.cddentid = 2
          tt-entidade.dsdentid = "Partido Politico, fundacao de " +
                                 "Partido Politico".

   CREATE tt-entidade.
   ASSIGN tt-entidade.cddentid = 3
          tt-entidade.dsdentid = "Entidade Sindical de Trabalhadores".

   CREATE tt-entidade.
   ASSIGN tt-entidade.cddentid = 4
          tt-entidade.dsdentid = "Instituicao de Educacao " +
                                 "s/ fins lucrativos".

   CREATE tt-entidade.
   ASSIGN tt-entidade.cddentid = 5
          tt-entidade.dsdentid = "Instituicao de Assistencia " +
                                 "Social s/ fins lucrativos".

END PROCEDURE.

/*............................................................................*/

PROCEDURE cria-situacao:

    /* Procedimento que cria a descricao do status do registro Imunidade */
    CREATE tt-situacao.
    ASSIGN tt-situacao.cdsitcad = 0
           tt-situacao.dssitcad = "Pendente".

    CREATE tt-situacao.
    ASSIGN tt-situacao.cdsitcad = 1
           tt-situacao.dssitcad = "Aprovado".

    CREATE tt-situacao.
    ASSIGN tt-situacao.cdsitcad = 2
           tt-situacao.dssitcad = "Nao Aprovado".

    CREATE tt-situacao.
    ASSIGN tt-situacao.cdsitcad = 3
           tt-situacao.dssitcad = "Cancelado".

END PROCEDURE.
