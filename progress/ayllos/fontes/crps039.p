/* ..........................................................................

   Programa: Fontes/crps039.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/92.                        Ultima atualizacao: 28/12/1999

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Filtra arquivo de compensacao do Banco do Brasil e prepara
               arquivo para ser integrado ao sistema CRED.

   Alteracoes: 21/06/94 - Alterado para acessar a tabela de conversao para o
                          real e para dar tratamento para a conta 2.400-7.

               12/08/94 - Alterado para exportar a data do lancamento retroati-
                          vo (Edson).

               26/01/95 - Alterado para tratar a conta 2.401-5 (Deborah).

               16/11/95 - Alterado para tratar a conta 2.402-3 (Edson).

               02/05/97 - Alterado para tratar recepcao do arquivo via
                          Linha Direta do Banco do Brasil (Edson).

               25/06/98 - Incluido a agencia de origem do Banco do Brasil no
                          arquivo de integracao (Edson).

               03/08/98 - Alterado para tratar o historco 630-ANOT. CRED com 
                          data maior que a do movimento (Edson).

               12/09/98 - Adaptar o layout para o milenio (Deborah). 

               25/09/98 - Tratar estornos de depositos bloqueados (Deborah). 

               28/12/1999 - Tratar terceiro campo no arquivo dataproc (Edson).

..............................................................................*/

DEF STREAM str_1.   /*  Para entrada do arquivo do Bando do Brasil  */
DEF STREAM str_2.   /*  Para saida formatada no padrao do sistema CRED  */
DEF STREAM str_3.   /*  Para acesso ao sistema operacional  */
DEF STREAM str_4.   /*  Para saida do resumo de saldo das contas  */

DEF NEW SHARED TEMP-TABLE crawest /* Tabela temporaria para estornos */

    FIELD nrdctabb AS INT 
    FIELD dshistor AS CHAR
    FIELD nrdconta AS INT
    FIELD nrdigcta AS INT
    FIELD cdpesqbb AS CHAR
    FIELD vllanmto AS DECIMAL 
    FIELD indebcre AS CHAR
    FIELD dtrefere AS CHAR
    FIELD cdagenci AS CHAR.
    
{ includes/var_real.i "NEW" }
/*
{ includes/var_batch.i "NEW" } 
*/

DEF NEW SHARED VAR glb_dtmvtolt AS DATE    FORMAT "99/99/9999"       NO-UNDO.
DEF NEW SHARED VAR glb_dscritic AS CHAR    FORMAT "x(40)"            NO-UNDO.

DEF        VAR tab_flgtrata AS LOGICAL EXTENT 99                     NO-UNDO.
DEF        VAR tab_nrdctabb AS INT     EXTENT 99                     NO-UNDO.
DEF        VAR tab_dtmvtolt AS CHAR    EXTENT 99                     NO-UNDO.

DEF        VAR tel_dsdisqte AS CHAR    INIT "Disquete"               NO-UNDO.
DEF        VAR tel_dslinhad AS CHAR    INIT "Linha Direta"           NO-UNDO.
DEF        VAR tel_confirma AS LOGICAL FORMAT "SIM/NAO"              NO-UNDO.

DEF        VAR tot_vldresto AS DECIMAL EXTENT 7
                                       FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.

DEF        VAR aux_vllanmto AS DECIMAL                               NO-UNDO.

DEF        VAR aux_qtlancto AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_contaarq AS INT                                   NO-UNDO.
DEF        VAR aux_contacta AS INT                                   NO-UNDO.

DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgfstct AS LOGICAL                               NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgdcruz AS LOGICAL                               NO-UNDO.

DEF        VAR aux_confirma AS LOGICAL FORMAT "OK/FIM"               NO-UNDO.
DEF        VAR aux_flgdisco AS LOGICAL FORMAT "Disquete/Linha Direta" NO-UNDO.

DEF        VAR aux_dtcruzei AS DATE FORMAT "99/99/9999"              NO-UNDO.

DEF        VAR aux_nmarqfil AS CHAR    EXTENT 99                     NO-UNDO.
DEF        VAR aux_nmarqerr AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqsai AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqsal AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqsld AS CHAR                                  NO-UNDO.
DEF        VAR aux_lsparame AS CHAR                                  NO-UNDO.

DEF        VAR aux_dsdlinha AS CHAR    FORMAT "x(134)"               NO-UNDO.
DEF        VAR aux_dtmvtolt AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF        VAR aux_dtarquiv AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF        VAR aux_dtrefere AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF        VAR aux_dtteste  AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF        VAR aux_dshistor AS CHAR    FORMAT "x(14)"                NO-UNDO.
DEF        VAR aux_lshistor AS CHAR                                  NO-UNDO.

DEF        VAR aux_nrdctabb AS INT                                   NO-UNDO.
DEF        VAR aux_nrseqint AS INT                                   NO-UNDO.
DEF        VAR aux_nrarqsal AS INT                                   NO-UNDO.
DEF        VAR aux_nrdesloc AS INT                                   NO-UNDO.

FORM aux_dsdlinha AT 1 WITH WIDTH 200.

FORM " Transmita o arquivo da compensacao do Banco do " SKIP
     " Brasil do PC para o HP e digite OK para conti- " SKIP
     " nuar ou FIM para encerrar.                     " SKIP(1)
     aux_confirma AT 2
     WITH ROW 4 CENTERED TITLE " Geracao do arquivo da Compensacao "
          OVERLAY NO-LABELS FRAME f_disquete.

FORM SKIP(1)
     "  " tel_dsdisqte FORMAT "x(8)" "  "
     tel_dslinhad FORMAT "x(12)" "  "
     SKIP(1)
     WITH ROW 10 CENTERED NO-LABELS OVERLAY
          TITLE " Tipo de Transmissao " FRAME f_transmis.

/*  Cria arquivo de controle de processo .................................... */

UNIX SILENT > arquivos/.039PR 2> /dev/null.

/*  Copia o diretorio procbak para o proc ................................... */

UNIX SILENT cp procbak/* proc 2> /dev/null.

/*  Carrega data do sistema ................................................. */

INPUT STREAM str_1 THROUGH cat proc/dataproc 2> /dev/null NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1
       glb_dtmvtolt glb_vldaurvs ^ WITH NO-BOX NO-LABELS FRAME f_cat.

END.  /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_1 CLOSE.

IF   glb_dtmvtolt = ?   THEN
     DO:
         BELL.
         MESSAGE "Nao existe arquivo com a data do sistema.".
         PAUSE 3 NO-MESSAGE.
         QUIT.
     END.

IF   glb_vldaurvs = 1 AND glb_dtmvtolt > 06/30/94  THEN
     DO:
         BELL.
         MESSAGE "Nao existe valor da URV para conversao".
         PAUSE 3 NO-MESSAGE.
         QUIT.
     END.

ASSIGN aux_contacta = 0
       aux_qtlancto = 0
       aux_nmarquiv = "".

/*  Monta tabela das contas e datas a serem tratadas ........................ */

INPUT STREAM str_1 THROUGH ls proc/0* 2> /dev/null NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1
       aux_nmarquiv FORMAT "x(40)" WITH NO-BOX NO-LABELS FRAME f_ls.

   ASSIGN aux_contacta = aux_contacta + 1

          tab_nrdctabb[aux_contacta] = INTEGER(SUBSTRING(aux_nmarquiv,06,08))
          tab_dtmvtolt[aux_contacta] = SUBSTRING(aux_nmarquiv,14,08).

END.  /*  Fim do DO WHILE TRUE  */


ASSIGN aux_nmarqsai = "integra/compbb" + STRING(MONTH(glb_dtmvtolt),"99") +
                                         STRING(DAY(glb_dtmvtolt),"99") + ".dat"

       aux_nmarqsld = "arq/crps039.dat"
        
       aux_lshistor = "411-EST.DEP.1D,412-EST.DEP.2D,413-EST.DEP.3D," + 
                      "414-EST.DEP.4D,415-EST.DEP.5D,416-EST.DEP.6D," +
                      "417-EST.DEP.7D,418-EST.DEP.8D,419-EST.DEP.9D," +
                      "420-EST.BL.IND"

       aux_nrseqint = -1.

OUTPUT STREAM str_2 TO VALUE(aux_nmarqsai).
OUTPUT STREAM str_4 TO VALUE(aux_nmarqsld).

INPUT STREAM str_1 CLOSE.

LEITURA:

/*  Le disquetes provenientes do BANCO DO BRASIL ............................ */

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   ASSIGN aux_regexist = FALSE
          aux_contaarq = 0
          aux_nmarqfil = ""
          glb_dscritic = "Disquete vazio ou erro de leitura.".

   HIDE ALL NO-PAUSE.
   BELL.

   UPDATE aux_confirma WITH FRAME f_disquete.

   IF   NOT aux_confirma   THEN
        DO:
            RUN grava-estornos.
            
            IF   aux_qtlancto > 0   THEN
                 DO:
                     DISPLAY "Foram selecionados" aux_qtlancto "registros."
                             WITH ROW 10 CENTERED NO-LABELS FRAME f_selecao.

                     IF   tot_vldresto[1] > 0   OR
                          tot_vldresto[2] > 0   OR
                          tot_vldresto[3] > 0   OR
                          tot_vldresto[4] > 0   OR
                          tot_vldresto[5] > 0   OR
                          tot_vldresto[6] > 0   OR
                          tot_vldresto[7] > 0   THEN
                          DISPLAY "  Conta  2.301.9:" tot_vldresto[1] SKIP
                                  "  Conta  2.302.7:" tot_vldresto[2] SKIP
                                  "  Conta  2.303.5:" tot_vldresto[5] SKIP
                                  "  Conta  2.400.7:" tot_vldresto[6] SKIP
                                  "  Conta  2.401.5:" tot_vldresto[7] SKIP
                                  "  Conta 97.531.1:" tot_vldresto[4] SKIP
                                  "  Conta 97.880.9:" tot_vldresto[3]
                                  WITH ROW 13 CENTERED NO-LABELS
                                       TITLE " Perda na Conversao para Reais "
                                       FRAME f_conversao.
                 END.
            ELSE
                 DO:
                     BELL.
                     DISPLAY "Nenhum registro foi selecionado!" SKIP(1)
                             "CONFIRME ANTES DE PROSSEGUIR COM O PROCESSO"
                             WITH ROW 10 CENTERED TITLE " Atencao "
                                  FRAME f_nenhum.
                 END.

            PAUSE MESSAGE "Tecle <espaco> para sair...".

            LEAVE.
        END.

   aux_flgdisco = FALSE.
   /*
   
   DISPLAY tel_dsdisqte tel_dslinhad WITH FRAME f_transmis.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      CHOOSE FIELD tel_dsdisqte tel_dslinhad WITH FRAME f_transmis.

      IF   FRAME-VALUE = tel_dsdisqte   THEN
           aux_flgdisco = TRUE.
      ELSE
           aux_flgdisco = FALSE.

      tel_confirma = FALSE.

      MESSAGE "Confirme a operacao utilizando"
              TRIM(STRING(aux_flgdisco,"DISQUETE/LINHA DIRETA")) "(S/N):"
              UPDATE tel_confirma.

      IF   NOT tel_confirma   THEN
           NEXT.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            HIDE FRAME f_transmis NO-PAUSE.
            NEXT.
        END.
   */
   IF   aux_flgdisco   THEN
        DO:
            aux_lsparame = "stress/*.str 2> /dev/null".

            INPUT STREAM str_1 THROUGH VALUE("ls " + aux_lsparame) NO-ECHO.

            DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

               SET STREAM str_1
                   aux_nmarquiv FORMAT "x(40)" WITH NO-BOX NO-LABELS FRAME f_ls.

               IF   aux_nmarquiv = aux_lsparame   THEN
                    DO:
                        glb_dscritic = "Nao existe arquivo compactado.".
                        LEAVE.
                    END.

               ASSIGN aux_regexist = TRUE
                      aux_contaarq = aux_contaarq + 1
                      aux_nmarqfil[aux_contaarq] = aux_nmarquiv.

            END.  /*  Fim do DO WHILE TRUE  */

            INPUT STREAM str_1 CLOSE.

            IF   NOT aux_regexist   THEN
                 DO:
                     BELL.
                     MESSAGE glb_dscritic.
                     PAUSE MESSAGE "Tecle algo para continuar...".
                     NEXT.         /*  Volta a pedir outro disquete  */
                 END.

            DO aux_contaarq = 1 TO 99:

               IF   aux_nmarqfil[aux_contaarq] = ""   THEN
                    LEAVE.

               HIDE MESSAGE NO-PAUSE.

               MESSAGE "Aguarde! Lendo arquivo" aux_nmarqfil[aux_contaarq].
               UNIX SILENT VALUE("ledisco " + aux_nmarqfil[aux_contaarq] +
                                 " 2> /dev/null").

               aux_nmarqerr = "erro/" + aux_nmarqfil[aux_contaarq] + ".e".

               IF   SEARCH(aux_nmarqerr) <> ?   THEN
                    DO:
                        glb_dscritic = "".

                        INPUT STREAM str_3 THROUGH VALUE("cat " + aux_nmarqerr +
                                                " 2> /dev/null") NO-ECHO.

                       DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

                           SET STREAM str_3 glb_dscritic FORMAT "x(65)"
                                            WITH NO-BOX NO-LABELS FRAME f_scat.

                       END.  /*  Fim do DO WHILE TRUE  */

                        INPUT STREAM str_3 CLOSE.

                        IF   glb_dscritic <> ""   THEN
                             DO:
                                 MESSAGE glb_dscritic.
                                 PAUSE MESSAGE "Tecle algo para continuar...".
                                 NEXT.
                             END.
                    END.

            END.  /*  Fim do DO .. TO  */
        END.

   ASSIGN aux_regexist = FALSE
          aux_contaarq = 0
          aux_nmarqfil = ""
          aux_lsparame = "compbb/* 2> /dev/null".

   /*  Carrega para uma tabela os arquivos a serem filtrados ................ */

   INPUT STREAM str_1 THROUGH VALUE("ls " + aux_lsparame) NO-ECHO.

   DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

      SET STREAM str_1
          aux_nmarquiv FORMAT "x(40)" WITH NO-BOX NO-LABELS FRAME f_ls.

      IF   aux_nmarquiv = aux_lsparame   THEN
           LEAVE.

      ASSIGN aux_regexist = TRUE
             aux_contaarq = aux_contaarq + 1
             aux_nmarqfil[aux_contaarq] = aux_nmarquiv.

   END.  /*  Fim do DO WHILE TRUE  --  Carga dos arquivos a serem filtrados  */

   INPUT STREAM str_1 CLOSE.

   IF   NOT aux_regexist   THEN
        DO:
            BELL.
            MESSAGE "Nao existe arquivo para filtrar.".
            PAUSE 3 NO-MESSAGE.
            LEAVE LEITURA.
        END.

   ARQUIVO:

   DO aux_contaarq = 1 TO 99:       /*  Contador de arquivos  */

      IF   aux_nmarqfil[aux_contaarq] = ""   THEN
           LEAVE.

      UNIX SILENT VALUE("quoter " + aux_nmarqfil[aux_contaarq] + " > " +
                        aux_nmarqfil[aux_contaarq] + ".q 2> /dev/null").

      ASSIGN aux_flgfirst = TRUE
             aux_flgfstct = TRUE
             aux_flgretor = FALSE.

      INPUT STREAM str_1 FROM VALUE(aux_nmarqfil[aux_contaarq] + ".q") NO-ECHO.

      /*  Leitura do arquivo a ser filtrado  */

      DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

         SET STREAM str_1 aux_dsdlinha.

         aux_dtarquiv = SUBSTRING(aux_dsdlinha,28,5). 
         
         IF   aux_dtarquiv = ""   THEN
              ASSIGN aux_dtrefere = aux_dtarquiv
                     aux_dtarquiv = SUBSTRING(aux_dsdlinha,16,10).
         ELSE
              ASSIGN aux_dtrefere = SUBSTRING(aux_dsdlinha,16,10)
                     aux_dtarquiv = aux_dtarquiv + "." + 
                     STRING(YEAR(glb_dtmvtolt),"9999").

         IF   SUBSTRING(aux_dsdlinha,1,1) = "1"   THEN
              DO:
                  ASSIGN aux_flgretor = FALSE
                         aux_nrdesloc = 9.

                  DO aux_contador = 1 TO aux_nrdesloc:  /* Cabec. arquivo BB */

                     SET STREAM str_1 aux_dsdlinha.

                     IF   aux_flgfstct   THEN
                          IF   SUBSTRING(aux_dsdlinha,1,1) = "0"   THEN
                               ASSIGN aux_nrdctabb =
                                         INTEGER(SUBSTRING(aux_dsdlinha,17,10) +
                                                 SUBSTRING(aux_dsdlinha,28,01))

                                      aux_flgfstct = FALSE

                                      aux_dtmvtolt = "99.99.9999".
                     /*                 
                     IF   CAN-DO("24023,978809",STRING(aux_nrdctabb))   THEN
                          aux_nrdesloc = 10.
                     */     
                  END.  /*  Fim do DO .. TO  */
              END.
         ELSE
         IF   aux_flgretor   THEN
              NEXT.                                /*  Le o proximo registro  */
         ELSE
         IF   SUBSTRING(aux_dsdlinha,1,1) = "0"  THEN
              DO:
                  ASSIGN aux_flgfirst = TRUE
                         aux_flgfstct = TRUE
                         aux_flgretor = TRUE.

                  NEXT.                            /*  Le o proximo registro  */
              END.
         ELSE
              DO:
                  IF   SUBSTRING(aux_dsdlinha,112,22) <> ""   THEN
                       PUT STREAM str_4
                           aux_nrdctabb FORMAT "99999999" ' "'
                           aux_dtarquiv FORMAT "x(10)"    '" "'
                           aux_dtrefere FORMAT "x(10)"    '" "'
                           SUBSTRING(aux_dsdlinha,112,22) FORMAT "x(24)" '"'
                           SKIP.

                  IF   SUBSTRING(aux_dsdlinha,044,14) = "SALDO-ANTERIOR"   THEN
                       NEXT.                       /*  Le o proximo registro  */

                  IF   aux_flgfirst   THEN
                       DO:
                           DO aux_contacta = 1 TO 99:

                              IF   tab_nrdctabb[aux_contacta] = 0   THEN
                                   LEAVE.

                              IF   tab_flgtrata[aux_contacta]   THEN
                                   NEXT.

                              IF   tab_nrdctabb[aux_contacta] <>
                                                aux_nrdctabb   THEN
                                   NEXT.

                              IF   aux_dtarquiv <>
                                       STRING(tab_dtmvtolt[aux_contacta],
                                              "xx.xx.xxxx")   THEN
                                   NEXT.

                              ASSIGN aux_dtmvtolt = aux_dtarquiv
                                     tab_flgtrata[aux_contacta] = TRUE.

                              LEAVE.

                           END.  /*  Fim do DO .. TO  */

                           IF   aux_dtmvtolt = "99.99.9999"   THEN
                                NEXT.              /*  Le o proximo registro  */

                           ASSIGN aux_flgfirst = FALSE
                                  aux_nrseqint = aux_nrseqint + 1.

                           RUN grava-estornos.
                           
                           PUT STREAM str_2
                               "1"                            " "
                               aux_nrseqint FORMAT "999999"   " "
                               '"H E A D E R    "'            " "
                               aux_nrdctabb FORMAT "99999999" " "
                               '"REF'
                               aux_dtmvtolt FORMAT "x(10)"    '" '
                               "99999999999999,99 X"          " "
                               '"99.99.9999" "9999.99"' SKIP.
                       END.

/* Edson */       IF   aux_dtarquiv <> STRING(STRING(glb_dtmvtolt,"99999999"),
                                            "xx.xx.xxxx")   THEN
                  IF   aux_dtmvtolt <> aux_dtarquiv   AND
                       TRIM(SUBSTR(aux_dsdlinha,44,14)) <> "630-ANOT.CRED" THEN
                       DO:
                           aux_dtmvtolt = "99.99.9999".

                           DO aux_contacta = 1 TO 99:

                              IF   tab_nrdctabb[aux_contacta] = 0   THEN
                                   LEAVE.

                              IF   tab_flgtrata[aux_contacta]   THEN
                                   NEXT.

                              IF   tab_nrdctabb[aux_contacta] <>
                                                    aux_nrdctabb   THEN
                                   NEXT.

                              IF   aux_dtarquiv <>
                                       STRING(tab_dtmvtolt[aux_contacta],
                                              "xx.xx.xxxx")   THEN
                                   NEXT.

                              ASSIGN aux_dtmvtolt = aux_dtarquiv
                                     tab_flgtrata[aux_contacta] = TRUE.

                              LEAVE.

                           END.  /*  Fim do DO .. TO  */

                           IF   aux_dtmvtolt = "99.99.9999"   THEN
                                NEXT.              /*  Le o proximo registro  */

                           RUN grava-estornos.
                           
                           aux_nrseqint = aux_nrseqint + 1.

                           PUT STREAM str_2
                               "1"                            " "
                               aux_nrseqint FORMAT "999999"   " "
                               '"H E A D E R    "'            " "
                               aux_nrdctabb FORMAT "99999999" " "
                               '"REF'
                               aux_dtmvtolt FORMAT "x(10)"    '" '
                               "99999999999999,99 X"          " "
                               '"99.99.9999" "9999.99"' SKIP.
                       END.

                  aux_vllanmto = DECIMAL(SUBSTRING(aux_dsdlinha,92,18)).

                  IF   aux_dtrefere <> ""   THEN
                       DO:
                          aux_dtcruzei = DATE(INTEGER(SUBSTR(aux_dtrefere,4,2)),
                                              INTEGER(SUBSTR(aux_dtrefere,1,2)),
                                              INTEGER(SUBSTR(aux_dtrefere,7,4))
                                              ).

                          IF   aux_dtcruzei < 7/1/1994   THEN
                               DO:
                                   ASSIGN glb_vldentra = aux_vllanmto
                                          glb_vldsaida = TRUNCATE(glb_vldentra /
                                                         glb_vldaurvs,2)
                                          glb_vldresto = glb_vldentra -
                                              (glb_vldsaida * glb_vldaurvs).

                                   IF   SUBSTRING(aux_dsdlinha,110,1) = "D" THEN
                                        glb_vldresto = glb_vldresto * -1.
                                   ELSE
                                   IF   SUBSTRING(aux_dsdlinha,110,1) = "*" THEN
                                        glb_vldresto = 0.

                                   IF   aux_nrdctabb = 24023   THEN
                                        tot_vldresto[1] = tot_vldresto[1] +
                                                              glb_vldresto.
                                   ELSE
                                   IF   aux_nrdctabb = 23027   THEN
                                        tot_vldresto[2] = tot_vldresto[2] +
                                                              glb_vldresto.
                                   ELSE
                                   IF   aux_nrdctabb = 978809   THEN
                                        tot_vldresto[3] = tot_vldresto[3] +
                                                              glb_vldresto.
                                   ELSE
                                   IF   aux_nrdctabb = 975311   THEN
                                        tot_vldresto[4] = tot_vldresto[4] +
                                                              glb_vldresto.
                                   ELSE
                                   IF   aux_nrdctabb = 23035   THEN
                                        tot_vldresto[5] = tot_vldresto[5] +
                                                              glb_vldresto.
                                   ELSE
                                   IF   aux_nrdctabb = 24007   THEN
                                        tot_vldresto[6] = tot_vldresto[6] +
                                                              glb_vldresto.
                                   ELSE
                                   IF   aux_nrdctabb = 24015   THEN
                                        tot_vldresto[7] = tot_vldresto[7] +
                                                              glb_vldresto.

                                   IF   glb_vldsaida = 0   THEN
                                        NEXT.
                                   ELSE
                                        aux_vllanmto = glb_vldsaida.
                               END.
                       END.

                  aux_dshistor = SUBSTRING(aux_dsdlinha,044,14).
                  
                  IF   CAN-DO(aux_lshistor,aux_dshistor)  THEN
                       DO:
                           CREATE crawest.
                            
                           ASSIGN crawest.nrdctabb = aux_nrdctabb
                                  crawest.dshistor =
                                          SUBSTRING(aux_dsdlinha,44,14) 
                                  crawest.nrdconta = 
                                      INT(SUBSTRING(aux_dsdlinha,82,07))
                                  crawest.nrdigcta = 
                                      INT(SUBSTRING(aux_dsdlinha,90,01))
                                  crawest.cdpesqbb = 
                                          SUBSTRING(aux_dsdlinha,60,13)
                                  crawest.vllanmto = DECIMAL(aux_vllanmto)
                                  crawest.indebcre = 
                                          SUBSTRING(aux_dsdlinha,110,01) 
                                  crawest.dtrefere = aux_dtrefere 
                                  crawest.cdagenci = 
                                          SUBSTRING(aux_dsdlinha,35,07).
                       END.
                  ELSE
                       DO:
                           ASSIGN aux_nrseqint = aux_nrseqint + 1
                                  aux_qtlancto = aux_qtlancto + 1.

                           PUT STREAM str_2
                               "0" " "
                               aux_nrseqint FORMAT "999999" ' "'
                               SUBSTRING(aux_dsdlinha,44,14) FORMAT "x(15)" '" '
                               INTEGER(SUBSTRING(aux_dsdlinha,82,07)) FORMAT                                           "9999999"
                               INTEGER(SUBSTRING(aux_dsdlinha,90,01)) FORMAT "9"                                             ' "'
                               SUBSTRING(aux_dsdlinha,60,13) FORMAT "x(13)" '" '
                               aux_vllanmto FORMAT "99999999999999.99" " "
                               SUBSTRING(aux_dsdlinha,110,01) FORMAT "x(1)" ' "'
                               aux_dtrefere FORMAT "x(10)" '" "'
                               SUBSTRING(aux_dsdlinha,35,07) FORMAT "x(7)" '"'
                               SKIP.
                       END.        
              END.

      END.  /* Fim do DO WHILE TRUE  --  Leitura do arquivos a ser filtrado  */

      INPUT STREAM str_1 CLOSE.

   END.  /*  Fim do DO .. TO  --  Contador de arquivos  */

   UNIX SILENT rm compbb/*.q 2> /dev/null.

   ASSIGN aux_contaarq = 0
          aux_nmarqfil = ""
          aux_regexist = FALSE.

   /*  Carrega para uma tabela os arquivos a serem salvos ................... */

   INPUT STREAM str_1 THROUGH VALUE("ls " + aux_lsparame) NO-ECHO.

   DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

      SET STREAM str_1
          aux_nmarquiv FORMAT "x(40)" WITH NO-BOX NO-LABELS FRAME f_ls.

      IF   aux_nmarquiv = aux_lsparame   THEN
           LEAVE.

      ASSIGN aux_regexist = TRUE
             aux_contaarq = aux_contaarq + 1
             aux_nmarqfil[aux_contaarq] = aux_nmarquiv.

   END.  /*  Fim do DO WHILE TRUE  --  Carga dos arquivos a serem filtrados  */

   INPUT STREAM str_1 CLOSE.

   IF   NOT aux_regexist   THEN
        DO:
            BELL.
            MESSAGE "Nao existe arquivo para salvar.".
            PAUSE 3 NO-MESSAGE.
        END.

   DO aux_contaarq = 1 TO 99:

      IF   aux_nmarqfil[aux_contaarq] = ""   THEN
           LEAVE.

      DO WHILE TRUE:

         ASSIGN aux_nrarqsal = aux_nrarqsal + 1.
                aux_nmarqsal = "salvar/comp" +
                               STRING(MONTH(glb_dtmvtolt),"99") +
                               STRING(DAY(glb_dtmvtolt),"99") + "_" +
                               STRING(aux_nrarqsal,"99") + ".bb".

         IF   SEARCH(aux_nmarqsal) <> ?   THEN
              NEXT.

         UNIX SILENT VALUE("mv " + aux_nmarqfil[aux_contaarq] + " " +
                           aux_nmarqsal + " 2> /dev/null").

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

   END.  /*  Fim do DO .. TO  */

END.  /*  Fim do DO WHILE TRUE  --  Leitura dos disquetes do B. Brasil  */

/*  Coloca registro que marca o fim do arquivo .............................. */

aux_nrseqint = aux_nrseqint + 1.

PUT STREAM str_2
    "9" " "
    aux_nrseqint FORMAT "999999" ' "'
    FILL("X",15) FORMAT "x(15)" '" 99999999 "'
    FILL("X",13) FORMAT "x(13)" '" 99999999999999,99 X '
    '"99.99.9999" "9999.99"' SKIP.

PUT STREAM str_4
    '99999999 "99.99.9999" "99.99.9999" "9999999999999999999999 X"' SKIP.

OUTPUT STREAM str_2 CLOSE.
OUTPUT STREAM str_4 CLOSE.

/*  Remove as contas processadas em suas respectivas datas .................. */

DO aux_contacta = 1 TO 99:

   IF   tab_nrdctabb[aux_contacta] = 0   THEN
        LEAVE.

   IF   tab_flgtrata[aux_contacta]   THEN
        UNIX SILENT VALUE("rm proc/" +
                          STRING(tab_nrdctabb[aux_contacta],"99999999") +
                          STRING(tab_dtmvtolt[aux_contacta],"x(8)") +
                          " 2> /dev/null").

END.  /*  Fim do DO .. TO  --  Remocao das contas processadas  */

/*  Remove dataproc do diretorio proc e cria fleg de execucao ok ............ */

UNIX SILENT rm proc/dataproc 2> /dev/null.


IF   SEARCH("integra/compefora.txt") <> ? THEN
     RETURN.
ELSE
     QUIT.

PROCEDURE grava-estornos:

   FOR EACH crawest:
         
       ASSIGN aux_nrseqint = aux_nrseqint + 1
              aux_qtlancto = aux_qtlancto + 1.

       PUT STREAM str_2
           "0" " "
           aux_nrseqint FORMAT "999999" ' "'
           crawest.dshistor FORMAT "x(15)" '" '
           crawest.nrdconta FORMAT "9999999" 
           crawest.nrdigcta FORMAT "9" ' "'
           crawest.cdpesqbb FORMAT "x(13)" '" '
           crawest.vllanmto FORMAT "99999999999999.99" " "
           crawest.indebcre FORMAT "x(1)" ' "'
           crawest.dtrefere FORMAT "x(10)" '" "'
           crawest.cdagenci FORMAT "x(07)" '"'
           SKIP.
   END.
   
   FOR EACH crawest:
       
       DELETE crawest.
   END.
    
END PROCEDURE.

/* .......................................................................... */
