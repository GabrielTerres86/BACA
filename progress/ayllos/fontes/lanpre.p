/* .............................................................................

   Programa: Fontes/lanpre.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jaison
   Data    : Maio/2014.                    Ultima atualizacao: 05/03/2018
   
   Dados referentes ao programa:

   Frequencia: Semanal
   Objetivo  : Atualizar a situacao do cooperado no SPC conforme importacao.
               Exportar lista de Cooperados para consulta do SPC/Serasa.
   
   Alteracoes: 19/01/2016 - Pre-Aprovado fase II. (Jaison/Anderson)

               05/03/2018 - Adequacao chamada pc_crps682 (Paralelismo).
			                (Fabrício)
   
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0171tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF VAR aux_confirma AS CHAR    FORMAT "!(1)"                  NO-UNDO.
DEF VAR aux_dsdireto AS CHAR    FORMAT "x(35)"                 NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR    FORMAT "x(60)"                 NO-UNDO.
DEF VAR aux_dsextens AS CHAR                                   NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                   NO-UNDO.
DEF VAR aux_indsepar AS INTE                                   NO-UNDO.
DEF VAR aux_flgsitua AS CHAR                                   NO-UNDO.
DEF VAR aux_inserasa AS INTE                                   NO-UNDO.
DEF VAR aux_flgerror AS LOGI                                   NO-UNDO.
DEF VAR aux_nrcpfcgc LIKE crapass.nrcpfcgc                     NO-UNDO.
DEF VAR aux_contador AS INTE                                   NO-UNDO.
DEF VAR aux_nmcooper AS CHAR                                   NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                   NO-UNDO.
DEF VAR aux_dtrefere AS CHAR                                   NO-UNDO.

DEF VAR tel_inpessoa LIKE crapass.inpessoa INIT 0              NO-UNDO.
DEF VAR tel_dspessoa AS CHAR                                   NO-UNDO.
DEF VAR tel_dtrefere AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF VAR tel_cdcooper AS CHAR    FORMAT "x(12)" VIEW-AS COMBO-BOX
                                               INNER-LINES 11  NO-UNDO.
DEF TEMP-TABLE tt-arquivo                                      NO-UNDO
    FIELD cdcooper AS INTE
    FIELD nmarquiv AS CHAR.

DEF VAR h-b1wgen0171 AS HANDLE                                 NO-UNDO.

FORM WITH ROW 4 TITLE glb_tldatela OVERLAY SIZE 80 BY 18 FRAME f_moldura.

FORM glb_cddopcao AT 7 LABEL "Opcao" AUTO-RETURN
                  HELP "Entre com a opcao desejada (I: Importacao ou E: Exportacao)."
                  VALIDATE (CAN-DO("I,E",glb_cddopcao),"014 - Opcao errada.")
     SKIP
     tel_cdcooper AT 1 LABEL "Cooperativa"         AUTO-RETURN
                        HELP "Selecione a Cooperativa"
     WITH ROW 6 SIDE-LABELS COLUMN 18 NO-BOX OVERLAY FRAME f_opcao.

FORM SKIP(1)
     tel_inpessoa AT 2 LABEL "Tipo de Pessoa"
                  HELP "Tipo de pessoa: 0 - Todas, 1 - Fisica, 2 - Juridica"
                  VALIDATE (CAN-DO("0,1,2",tel_inpessoa),"014 - Opcao errada.")
     tel_dspessoa            NO-LABEL
     SKIP(1)
     tel_dtrefere AT 1 LABEL "Data do arquivo"     AUTO-RETURN
                  HELP "Informe a data do arquivo"
     SKIP(1)
     "Caminho: " AT 9
     aux_dsdireto NO-LABEL
     SKIP(1)
     WITH ROW 8 SIDE-LABELS CENTERED NO-BOX OVERLAY FRAME f_lanaut.


ON RETURN OF tel_cdcooper IN FRAME f_opcao DO:

    ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE.

    APPLY "GO".
END.
                             
VIEW FRAME f_moldura.
PAUSE 0.


/*************** CARREGA COOPERATIVAS ***************/
ASSIGN aux_contador = 0.

IF  NOT VALID-HANDLE(h-b1wgen0171) THEN
    RUN sistema/generico/procedures/b1wgen0171.p
        PERSISTENT SET h-b1wgen0171.

RUN carrega-cooperativas IN h-b1wgen0171
                  ( INPUT FALSE,  /* Lista Coop CECRED ? */ 
                    INPUT YES,  /* Lista item TODAS  ? */ 
                   OUTPUT TABLE tt-erro,
                   OUTPUT TABLE tt-cooper).

IF  VALID-HANDLE(h-b1wgen0171) THEN
    DELETE PROCEDURE h-b1wgen0171.

IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN DO:
    FIND FIRST tt-erro NO-LOCK NO-ERROR.

    IF  AVAIL tt-erro  THEN DO:
        MESSAGE tt-erro.dscritic.
        PAUSE 2 NO-MESSAGE.
        HIDE MESSAGE.
        NEXT.
    END.
END.

FOR EACH tt-cooper NO-LOCK
    BY tt-cooper.cdcooper:

    IF   aux_contador = 0 THEN
         ASSIGN aux_nmcooper = CAPS(tt-cooper.nmrescop) + "," +
                               STRING(tt-cooper.cdcooper)
                aux_contador = 1.
    ELSE
         ASSIGN aux_nmcooper = aux_nmcooper + "," + CAPS(tt-cooper.nmrescop)
                                            + "," + STRING(tt-cooper.cdcooper)
                aux_contador = aux_contador + 1.
END.

ASSIGN tel_cdcooper:LIST-ITEM-PAIRS IN FRAME f_opcao = aux_nmcooper .
/*************** CARREGA COOPERATIVAS ***************/


ASSIGN glb_cdcritic = 0.

DO WHILE TRUE:
   CLEAR FRAME f_opcao   NO-PAUSE.
   CLEAR FRAME f_lanaut  NO-PAUSE.
   HIDE  FRAME f_lanaut  NO-PAUSE.

   ASSIGN glb_cddopcao = "I".

   DISPLAY glb_cddopcao 
           WITH FRAME f_opcao.

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao tel_cdcooper
             WITH FRAME f_opcao.
      LEAVE.

   END. /** Fim do DO WHILE TRUE **/

   IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
   DO: 
       RUN fontes/novatela.p.
        
       IF  CAPS(glb_nmdatela) <> "LANPRE" THEN
       DO:
           HIDE FRAME f_opcao  NO-PAUSE.
           HIDE FRAME f_lanaut NO-PAUSE.
           RETURN.               
       END.
       ELSE
           NEXT.
   END.
   ELSE
   DO:
       { includes/acesso.i }
   END.

   ASSIGN tel_dtrefere = glb_dtmvtolt
          tel_inpessoa = 0
          tel_dspessoa = "TODAS"
          aux_dsdireto = "/micros/cecred/preaprovado/" + IF glb_cddopcao = "I"
                                                         THEN "Importa/"
                                                         ELSE "Exporta/".

   DISPLAY aux_dsdireto tel_inpessoa tel_dspessoa tel_dtrefere
           WITH FRAME f_lanaut.

   IF glb_cddopcao = "I" THEN
   DO: /* Importacao */
       EMPTY TEMP-TABLE tt-arquivo.

       /* Exibe o campo de tipo de pessoa somente na importacao */
       tel_inpessoa:VISIBLE IN FRAME f_lanaut = TRUE.
       tel_dspessoa:VISIBLE IN FRAME f_lanaut = TRUE.

       Opcoes: DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           UPDATE tel_inpessoa tel_dtrefere 
                  WITH FRAME f_lanaut

           EDITING:
             READKEY.     

             IF  FRAME-FIELD = "tel_inpessoa"  THEN
                 DO:
                    ASSIGN aux_inpessoa = INPUT tel_inpessoa.
                    IF  aux_inpessoa = 0   THEN
                        tel_dspessoa = "TODAS".
                    ELSE
                        IF  aux_inpessoa = 1   THEN
                            tel_dspessoa = "FISICA".
                        ELSE
                            IF  aux_inpessoa = 2   THEN
                                tel_dspessoa = "JURIDICA".
                            ELSE
                                ASSIGN tel_inpessoa = ?
                                       tel_dspessoa = "".

                    IF  KEYFUNCTION(LASTKEY) = "RETURN"  THEN
                        DISPLAY tel_dspessoa WITH FRAME f_lanaut.
                                        
                 END. 

                 IF  FRAME-FIELD = "tel_dtrefere"  THEN
                     DO:
                        IF  KEYFUNCTION(LASTKEY) = "RETURN"  THEN
                            UNDO Opcoes, LEAVE Opcoes.
                     END.  

              APPLY LASTKEY. 

           END. /* fim do EDITING */
       END. /* OPCOES */

       IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
          LEAVE.          

       ASSIGN aux_flgerror = FALSE
              aux_dtrefere = STRING(DAY(tel_dtrefere),"99") + 
                             STRING(MONTH(tel_dtrefere),"99") + 
                             STRING(YEAR(tel_dtrefere),"9999").

       FOR EACH crapcop FIELDS (cdcooper nmrescop)
                         WHERE crapcop.flgativo = TRUE
                           AND crapcop.cdcooper <> 3
                           AND (crapcop.cdcooper = INT(tel_cdcooper) OR                              
                                0 = INT(tel_cdcooper)) NO-LOCK:
           /* Pessoa Fisica */
           IF  CAN-DO("0,1",STRING(aux_inpessoa))  THEN
               DO:
                  ASSIGN aux_nmarquiv = "F" + STRING(crapcop.cdcooper,"99") + 
                                        "_" + aux_dtrefere + ".txt".
                  
                  /* Caso NAO encontre o arquivo */
                  IF  SEARCH(aux_dsdireto + aux_nmarquiv) = ? THEN 
                      DO:
                         ASSIGN aux_flgerror = TRUE.
                         MESSAGE "Arquivo " + aux_nmarquiv + " da " + 
                                 crapcop.nmrescop + " nao encontrado.".
                      END.
                  ELSE
                      DO:
                         /* Adiciona na temp table o arquivo */
                         CREATE tt-arquivo.
                         ASSIGN tt-arquivo.cdcooper = crapcop.cdcooper
                                tt-arquivo.nmarquiv = aux_nmarquiv.
                      END.
               END.

           /* Pessoa Juridica */
           IF  CAN-DO("0,2",STRING(aux_inpessoa))  THEN
               DO:
                  ASSIGN aux_nmarquiv = "J" + STRING(crapcop.cdcooper,"99") + 
                                        "_" + aux_dtrefere + ".txt".
                  
                  /* Caso NAO encontre o arquivo */
                  IF  SEARCH(aux_dsdireto + aux_nmarquiv) = ? THEN 
                      DO:
                         ASSIGN aux_flgerror = TRUE.
                         MESSAGE "Arquivo " + aux_nmarquiv + " da " + 
                                 crapcop.nmrescop + " nao encontrado.".
                      END.
                  ELSE
                      DO:
                         /* Adiciona na temp table o arquivo */
                         CREATE tt-arquivo.
                         ASSIGN tt-arquivo.cdcooper = crapcop.cdcooper
                                tt-arquivo.nmarquiv = aux_nmarquiv.
                      END.
               END.
       END.

       /* Se possui erro */
       IF  aux_flgerror  THEN
           NEXT.

       FORM aux_setlinha  FORMAT "x(210)"
            WITH FRAME f_atualiza WIDTH 210 NO-BOX NO-LABELS.

       /* Listagem de arquivos de importacao */
       FOR EACH tt-arquivo NO-LOCK
                           BY tt-arquivo.cdcooper:
    
           /* Leitura do arquivo */
           INPUT STREAM str_1 FROM VALUE(aux_dsdireto + tt-arquivo.nmarquiv) NO-ECHO.
        
           Atualiza:
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
               /* Faz a leitura da linha e seta na variavel */
               SET STREAM str_1 aux_setlinha WITH FRAME f_atualiza WIDTH 210.
    
               ASSIGN aux_indsepar = INDEX(aux_setlinha, ";")
                      aux_nrcpfcgc = DEC(SUBSTR(aux_setlinha, 1, aux_indsepar - 1))
                      aux_flgsitua = CAPS(SUBSTR(aux_setlinha, aux_indsepar + 1, 1))
                      aux_inserasa = IF aux_flgsitua = "S"
                                     THEN 1  /* com restricao */
                                     ELSE 2. /* sem restricao */
    
               /* Caso o arquivo esteja fora do padrao */
               IF  aux_indsepar = 0 THEN
               DO:
                   MESSAGE "Arquivo fora do padrao.".
                   NEXT.
               END.
    
               FOR EACH crapass FIELDS(nrcpfcgc)
                                WHERE crapass.cdcooper = tt-arquivo.cdcooper AND
                                      crapass.nrcpfcgc = aux_nrcpfcgc EXCLUSIVE-LOCK:
                   /* Atualiza a flag */
                   ASSIGN crapass.inserasa = aux_inserasa.
               END.
    
           END.
    
           INPUT STREAM str_1 CLOSE.

       END.

       RUN Gera_log(INPUT INT(tel_cdcooper),
                    INPUT glb_cdoperad,
                    INPUT "Importou").
   END.
   ELSE
   DO: /* Exportacao */

       /* Oculta o campo de tipo de pessoa somente na importacao */
       tel_inpessoa:VISIBLE IN FRAME f_lanaut = FALSE.
       tel_dspessoa:VISIBLE IN FRAME f_lanaut = FALSE.

       RUN confirma.

       IF RETURN-VALUE <> "OK" THEN
          LEAVE.

       { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_crps682 aux_handproc = PROC-HANDLE
           (INPUT INT(tel_cdcooper),
            INPUT  0,
            INPUT  0,
            INPUT  0,
            INPUT INT(STRING(glb_flgresta,"1/0")),
            INPUT  1, /* Gerar arquivo TXT para SPC/Serasa */
            OUTPUT 0,
            OUTPUT 0,
            OUTPUT 0, 
            OUTPUT "").
        
        IF  ERROR-STATUS:ERROR  THEN DO:
            DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
                ASSIGN aux_msgerora = aux_msgerora + 
                                      ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
            END.
        
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - " + glb_cdprogra + "' --> '"  +
                              "Erro ao executar Stored Procedure: '" +
                              aux_msgerora + "' >> log/proc_batch.log").
            LEAVE.
        END.
        
        CLOSE STORED-PROCEDURE pc_crps682 WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN glb_cdcritic = 0
               glb_dscritic = ""
               glb_cdcritic = pc_crps682.pr_cdcritic WHEN pc_crps682.pr_cdcritic <> ?
               glb_dscritic = pc_crps682.pr_dscritic WHEN pc_crps682.pr_dscritic <> ?
               glb_stprogra = IF pc_crps682.pr_stprogra = 1 THEN TRUE ELSE FALSE
               glb_infimsol = IF pc_crps682.pr_infimsol = 1 THEN TRUE ELSE FALSE.
        
        
        IF  glb_cdcritic <> 0   OR
            glb_dscritic <> ""  THEN
            DO:
                MESSAGE "Erro ao rodar: " + STRING(glb_cdcritic) + " " + glb_dscritic.
                PAUSE 2 NO-MESSAGE.
                LEAVE.
            END.

       RUN Gera_log(INPUT INT(tel_cdcooper),
                    INPUT glb_cdoperad,
                    INPUT "Exportou").
   END.

   MESSAGE "Processo realizado com sucesso.".
   PAUSE 2 NO-MESSAGE.

   LEAVE.

END.

PROCEDURE confirma:
   
   ASSIGN aux_confirma = "N".

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
     MESSAGE COLOR NORMAL "Confirma a exportacao do arquivo? (S/N):" UPDATE aux_confirma.
     LEAVE.
   END. /** Fim do DO WHILE TRUE **/

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"  OR 
      aux_confirma <> "S"                 THEN
      DO:
          RETURN "NOK".
      END.

   RETURN "OK".

END PROCEDURE.

PROCEDURE Gera_log:

    DEF INPUT PARAM par_cdcooper AS INTE            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR            NO-UNDO.
    DEF INPUT PARAM par_dsdopcao AS CHAR            NO-UNDO.

    DEF VARIABLE aux_dstexto     AS CHAR INIT ""    NO-UNDO.

    IF  par_cdcooper > 0  THEN
        DO:
            FIND FIRST crapcop 
                 WHERE crapcop.cdcooper = par_cdcooper
                 NO-LOCK NO-ERROR.

            IF  AVAIL crapcop THEN
                DO:
                    ASSIGN aux_dstexto = crapcop.nmrescop.
                END.
        END.
    ELSE
        DO:
            ASSIGN aux_dstexto = "opcao TODAS".
        END.

    UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " " +
                      STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador " +
                      par_cdoperad + " '-->' " + par_dsdopcao + " o arquivo " + 
                      "de CPF/CNPJ na " + aux_dstexto + 
                      " >> /usr/coop/cecred/log/lanpre.log").

    RETURN 'OK'.
    
END PROCEDURE.
