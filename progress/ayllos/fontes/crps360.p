/* ..........................................................................

   Programa: Fontes/crps360.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo        
   Data    : Dezembro/2003                     Ultima atualizacao: 24/04/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 1 - ordem 13.
               Processamento de devolucoes de cheques do Banco do Brasil.
               Emite relatorio 309 e 310.

   Alteracoes: 30/12/2003 - Alteracao para rodar pelo COMPEFORA (Margarete).
   
               02/02/2004 - Alteracao no formato da Data (Ze Eduardo).
               
               29/03/2004 - Verificar se cheque foi transferido(leitura
                            craptrf) (Mirtes).

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot e
                            craplcm (Diego).

               09/08/2005 - Ajuste na leitura dos depositos bloqueados e
                            tratamento do historico 657 para as devolucoes
                            de cheques em custodia (Edson).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               26/10/2005 - Alterado relatorio 310, para imprimir as 2 vias
                            (cooperativa + socio) na mesma folha (Diego).
                            
               15/12/2005 - Tratamento COMPEFORA (Ze).
               
               17/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               06/08/2009 - Diferenciar do lanctos BB e Bancoob atraves do
                            campo craplcm.dsidenti  (Ze).
                            
               08/09/2009 - Retirar msg impressa no LOG - critica 244 - Cheque
                            inexistente (Ze).
               
               05/08/2013 - Alterado para pegar o telefone da tabela 
                            craptfc ao invés da crapass (James).
                            
               01/10/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).       
                            
               21/01/2014 - Incluir VALIDATE craplot, craplcm (Lucas R.)      
               
               24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

               03/05/2017 - #643531 Correcao de criticas; Script para retirar 
                            o programa da cadeia da CECRED. (Carlos)
............................................................................. */

DEF STREAM str_1.   /*  Para relatorio - 310        */
DEF STREAM str_2.   /*  Para relatorio - 309 PA    */
DEF STREAM str_3.   /*  Para relatorio - 309 TOTAL  */
DEF STREAM str_4.   /*  Para arquivo                */
DEF STREAM str_5.   /*  Para arquivo                */

{ includes/var_batch.i }   
{ sistema/generico/includes/var_oracle.i }
{ includes/gera_log_batch.i }
{ sistema/generico/includes/b1wgen0200tt.i }

DEF TEMP-TABLE crawrel                                               NO-UNDO
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nmsegntl LIKE crapttl.nmextttl
    FIELD nrfonres AS CHAR
    FIELD cdcmpchq LIKE crapchd.cdcmpchq
    FIELD cdagechq LIKE crapchd.cdagechq
    FIELD cdbanchq LIKE crapchd.cdbanchq
    FIELD nrctachq LIKE crapchd.nrctachq
    FIELD nrcheque LIKE crapchd.nrcheque
    FIELD nralinea AS INTEGER
    FIELD vlcheque LIKE crapchd.vlcheque
    INDEX crawrel1 AS PRIMARY
          cdbanchq cdagechq nrctachq nrcheque
    INDEX crawrel2 
          cdagenci nrdconta nrcheque.
          
DEF TEMP-TABLE rel310                                                NO-UNDO
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nmsegntl LIKE crapttl.nmextttl
    FIELD nrfonres AS CHAR
    FIELD cdbanchq LIKE crapchd.cdbanchq
    FIELD nrcheque LIKE crapchd.nrcheque
    FIELD nralinea AS INTEGER
    FIELD vlcheque LIKE crapchd.vlcheque
    FIELD auxaline AS CHAR
    FIELD auxqtdch AS INTEGER
    FIELD totchequ AS DECIMAL.
                      
                      
DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF        VAR rel_nmresemp AS CHAR                                  NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.
                                     
DEF        VAR dpb_cdagenci AS INT                                   NO-UNDO.
DEF        VAR dpb_cdbccxlt AS INT                                   NO-UNDO.
DEF        VAR dpb_nrdolote AS INT                                   NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR    FORMAT "x(70)"                NO-UNDO.
DEF        VAR aux_nmarqdeb AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_setlinha AS CHAR    FORMAT "x(210)"               NO-UNDO.
DEF        VAR tab_nmarquiv AS CHAR    FORMAT "x(50)"   EXTENT 99    NO-UNDO.
DEF        VAR i            AS INT                                   NO-UNDO.
DEF        VAR i2           AS INT                                   NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgrejei AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgerros AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgerro2 AS LOGICAL                               NO-UNDO.

DEF        VAR aux_diarefer AS INT                                   NO-UNDO.
DEF        VAR aux_mesrefer AS INT                                   NO-UNDO.
DEF        VAR aux_anorefer AS INT                                   NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqrl1 AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqrl2 AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrtelefo AS CHAR                                  NO-UNDO.

DEF        VAR aux_dtmtoarq AS DATE                                  NO-UNDO.

DEF        VAR aux_nrcoluna AS INT                                   NO-UNDO.

DEF        VAR aux_cdbanchq AS INT                                   NO-UNDO.
DEF        VAR aux_cdagechq AS INT                                   NO-UNDO.
DEF        VAR aux_nrctachq AS DEC                                   NO-UNDO.
DEF        VAR aux_nrcheque AS INT                                   NO-UNDO.
DEF        VAR aux_nralinea AS INT                                   NO-UNDO.
DEF        VAR aux_vlcheque AS DEC                                   NO-UNDO.

DEF        VAR aux_nrodomes AS CHAR                                  NO-UNDO.
DEF        VAR aux_contareg AS INT                                   NO-UNDO.

DEF        VAR aux_cdhistor AS INT                                   NO-UNDO.
DEF        VAR aux_dsalinea AS CHAR                                  NO-UNDO.

DEF        VAR aux_dtleiarq AS DATE                                  NO-UNDO.
DEF        VAR aux_qtdecheq AS INT                                   NO-UNDO.
DEF        VAR aux_totdcheq AS DECIMAL                               NO-UNDO.
DEF        VAR tot_qtdecheq AS INT                                   NO-UNDO.
DEF        VAR tot_totdcheq AS DECIMAL                               NO-UNDO.

DEF        VAR h-b1wgen0200 AS HANDLE                                NO-UNDO.
DEF        VAR aux_incrineg AS INT                                   NO-UNDO.
DEF        VAR aux_cdcritic AS INT                                   NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.

DEF        VAR aux_nrdconta LIKE crapchd.nrdconta                    NO-UNDO.

FORM aux_setlinha  FORMAT "x(210)"
     WITH FRAME AA WIDTH 210 NO-BOX NO-LABELS.

FORM HEADER
     rel_nmresemp                   AT   1 FORMAT "x(11)"
     "-"                            AT  13
     rel_nmrelato[1]                AT  15 FORMAT "x(16)"
     "REF."                         AT  32
     glb_dtmvtolt                   AT  36 FORMAT "99/99/9999"
     glb_cdrelato[1]                AT  47 FORMAT "999"
     "/"                            AT  50
     glb_progerad                   AT  51 FORMAT "x(03)"
     "-"                            AT  55
     TODAY                          AT  57 FORMAT "99/99/9999"
     STRING(TIME,"HH:MM")           AT  68 FORMAT "x(5)"
     SKIP(1)
     glb_nmdestin[1]                       FORMAT "x(40)"
     SKIP(1)
WITH PAGE-TOP NO-BOX NO-ATTR-SPACE WIDTH 80 FRAME f_cabrel080_1.

FORM SKIP(1)
     crawrel.cdagenci   AT 02  FORMAT "zz9"             LABEL "PA"
     crawrel.nrdconta   AT 16  FORMAT "zzzz,zz9,9"      LABEL "CONTA/DV"
     " - "              AT 36
     crawrel.nmprimtl   AT 39  FORMAT "x(40)"           NO-LABEL
     SKIP
     crawrel.nrfonres   AT 16  FORMAT "x(40)"           LABEL "FONE"
     SKIP(1)
     "RELACAO DE CHEQUES DEVOLVIDOS:"   AT 01                
     SKIP(1)
     "BANCO"            AT 01                           
     "CHEQUE"           AT 16                           
     "ALINEA"           AT 30                           
     "VALOR"            AT 76                           
     SKIP(1)
     WITH NO-BOX DOWN SIDE-LABELS WIDTH 80 FRAME f_cabec_310.

FORM crawrel.cdbanchq   AT 01  FORMAT "zz9"          
     crawrel.nrcheque   AT 15  FORMAT "zzz,zz9"     
     crawrel.nralinea   AT 33  FORMAT "z9"
     " - "              AT 35
     aux_dsalinea       AT 38  FORMAT "x(25)"
     crawrel.vlcheque   AT 68  FORMAT "zz,zzz,zz9.99"
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_lanc_310.

FORM SKIP(1)
     "TOTAL -->"        AT 01
     aux_qtdecheq       AT 15  FORMAT "zzz,zz9"               NO-LABEL
     aux_totdcheq       AT 63  FORMAT "zzz,zzz,zzz,zz9.99"    NO-LABEL
     SKIP(2)
     "TERMO    DE    RECEBIMENTO"   AT 28
     SKIP(3)
  "Declaro   para  os  devidos  fins,  ter  recebido  o(s)  documento(s)  acima"
     AT 5   SKIP(1)
     "especificado(s) em ____/____/______ ."  AT 01  
     SKIP(3)
     "TITULAR"             AT 01 SKIP(4)
     "-----------------------------------"       AT 01 
     "-------------------------"                 AT 50
     SKIP 
     crawrel.nmprimtl     AT 01  FORMAT "x(40)"         NO-LABEL
     "Cadastro e Visto"   AT 56
     crawrel.nmsegntl     AT 01  FORMAT "x(40)"         NO-LABEL
     SKIP
     crawrel.nrdconta     AT 01  FORMAT "zzzz,zz9,9"    LABEL "CONTA/DV"
     WITH NO-BOX SIDE-LABEL DOWN WIDTH 80 FRAME f_total_310.
     
/* Para 2 via */
FORM SKIP(1)
     rel310.cdagenci   AT 02  FORMAT "zz9"             LABEL "PA"
     rel310.nrdconta   AT 16  FORMAT "zzzz,zz9,9"      LABEL "CONTA/DV"
     " - "             AT 36
     rel310.nmprimtl   AT 39  FORMAT "x(40)"           NO-LABEL
     SKIP
     rel310.nrfonres   AT 16  FORMAT "x(40)"           LABEL "FONE"
     SKIP(1)
     "RELACAO DE CHEQUES DEVOLVIDOS:"   AT 01                
     SKIP(1)
     "BANCO"            AT 01                           
     "CHEQUE"           AT 16                           
     "ALINEA"           AT 30                           
     "VALOR"            AT 76                           
     SKIP(1)
     WITH NO-BOX DOWN SIDE-LABELS WIDTH 80 FRAME f_cabec_rel310.

FORM rel310.cdbanchq   AT 01  FORMAT "zz9"          
     rel310.nrcheque   AT 15  FORMAT "zzz,zz9"     
     rel310.nralinea   AT 33  FORMAT "z9"
     " - "             AT 35
     rel310.auxaline   AT 38  FORMAT "x(25)"
     rel310.vlcheque   AT 68  FORMAT "zz,zzz,zz9.99"
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_lanc_rel310.

FORM SKIP(1)
     "TOTAL -->"           AT 01
     rel310.auxqtdch       AT 15  FORMAT "zzz,zz9"               NO-LABEL
     rel310.totchequ       AT 63  FORMAT "zzz,zzz,zzz,zz9.99"    NO-LABEL
     SKIP(2)
     "TERMO    DE    RECEBIMENTO"   AT 28
     SKIP(3)
  "Declaro   para  os  devidos  fins,  ter  recebido  o(s)  documento(s)  acima"
     AT 5   SKIP(1)
     "especificado(s) em ____/____/______ ."  AT 01  
     SKIP(3)
     "TITULAR"             AT 01 SKIP(4)
     "-----------------------------------"       AT 01 
     "-------------------------"                 AT 50
     SKIP 
     rel310.nmprimtl     AT 01  FORMAT "x(40)"         NO-LABEL
     "Cadastro e Visto"  AT 56
     rel310.nmsegntl     AT 01  FORMAT "x(40)"         NO-LABEL
     SKIP
     rel310.nrdconta     AT 01  FORMAT "zzzz,zz9,9"    LABEL "CONTA/DV"
     WITH NO-BOX SIDE-LABEL DOWN WIDTH 80 FRAME f_total_rel310.

/* Conforme numero de cheques impressos */
FORM SKIP(4)
     "----------------------------------------------------------------------"
     "----------" AT 71
     SKIP(2)
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_tracejado1.
     
FORM SKIP(5)
     "----------------------------------------------------------------------"
     "----------" AT 71
     SKIP(2)
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_tracejado2.
     
FORM SKIP(6)
     "----------------------------------------------------------------------"
     "----------" AT 71
     SKIP(2)
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_tracejado3.

FORM SKIP(3)
     "DEVOLUCOES NAO PROCESSADAS"      AT 28
     SKIP(3)
     WITH NO-BOX WIDTH 80 FRAME f_cabec_erro_309.

FORM crawrel.nmprimtl   AT 01  FORMAT "x(40)"       LABEL "DESCRICAO DO ERRO"
     SKIP                   
     crawrel.cdbanchq   AT 21  FORMAT "zz9"         LABEL "BANCO"
     crawrel.cdagechq   AT 39  FORMAT "zzz9"        LABEL "AGENCIA"
     crawrel.vlcheque   AT 57  FORMAT "zz,zzz,zzz,zz9.99"  LABEL "VALOR"
     SKIP
     crawrel.nralinea   AT 01  FORMAT "z9"          LABEL "ALINEA"
     crawrel.nrcheque   AT 21  FORMAT "zzz,zz9"     LABEL "CHEQUE"
     SKIP(2)
     WITH NO-BOX DOWN SIDE-LABEL WIDTH 80 FRAME f_lanc_erro_309.

FORM SKIP(3)
     "RESUMO DAS DEVOLUCOES"     AT 20
     "   -    PA"                AT 42
     crawrel.cdagenci            AT 53   FORMAT "z9"
     crapage.nmresage            AT 57   FORMAT "x(15)"
     SKIP(3)
     "CONTA/DV"         AT 03
     "NOME"             AT 13
     "BANCO"            AT 47                           
     "CHEQUE"           AT 54                           
     "ALINEA"           AT 61                           
     "VALOR"            AT 76                           
     SKIP(1)
     WITH NO-BOX NO-LABEL WIDTH 80 FRAME f_cabec_309.

FORM crawrel.nrdconta   AT 01  FORMAT "zzzz,zz9,9"
     crawrel.nmprimtl   AT 13  FORMAT "x(33)"
     crawrel.cdbanchq   AT 49  FORMAT "zz9"          
     crawrel.nrcheque   AT 53  FORMAT "zzz,zz9"     
     crawrel.nralinea   AT 64  FORMAT "z9"
     crawrel.vlcheque   AT 68  FORMAT "zz,zzz,zz9.99"
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_lanc_309.

FORM SKIP(1)
     "TOTAL -->"        AT 01
     aux_qtdecheq       AT 53  FORMAT "zzz,zz9"          
     aux_totdcheq       AT 63  FORMAT "zzz,zzz,zzz,zz9.99"
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_total_309.

FORM SKIP(7)
     "------------------------------"   AT 49
     SKIP
     "Visto do Coordenador"             AT 54
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_visto_309.

FORM SKIP(2)
     "TOTAL GERAL -->"  AT 01
     tot_qtdecheq       AT 53  FORMAT "zzz,zz9"          
     tot_totdcheq       AT 63  FORMAT "zzz,zzz,zzz,zz9.99"
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_total_geral_309.
     
ASSIGN glb_cdprogra = "crps360"
       glb_flgbatch = false.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.           

/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         RETURN.
     END.

/* Tabela que contem as dados sobre a compensacao cheques do Banco do Brasil */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "CONFIG"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "COMPELBBCH"  AND
                   craptab.tpregist = 000           NO-LOCK NO-ERROR NO-WAIT.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 55.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
         PAUSE(5) NO-MESSAGE.
         RETURN.
     END.    

ASSIGN  aux_nmarqdeb = "compbb/dnr259*"
        aux_contador = 0.
                    
INPUT STREAM str_4 THROUGH VALUE( "ls " + aux_nmarqdeb + " 2> /dev/null")
      NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_4 aux_nmarquiv FORMAT "x(70)".
   
   UNIX SILENT VALUE("quoter " + aux_nmarquiv + " > " +
                      aux_nmarquiv + ".q 2> /dev/null").

   INPUT STREAM str_5 FROM VALUE(aux_nmarquiv + ".q") NO-ECHO.

   SET STREAM str_5 aux_setlinha WITH FRAME AA WIDTH 210.
   
   /*   Verifica a data do movimento do arquivo   */
   
   IF   glb_nmtelant = "COMPEFORA"   THEN 
        ASSIGN aux_dtleiarq = glb_dtmvtoan.
   ELSE
        ASSIGN aux_dtleiarq = glb_dtmvtolt.
                
   ASSIGN aux_dtmtoarq = DATE(INTEGER(SUBSTR(aux_setlinha,06,02)),
                              INTEGER(SUBSTR(aux_setlinha,08,02)),
                              INTEGER(SUBSTR(aux_setlinha,02,04))).

   IF   aux_dtleiarq <> aux_dtmtoarq THEN
        DO:
            glb_cdcritic = 013.
            RUN fontes/critic.p.

            RUN gera_log_batch_prog("E", 2, /* 2 - erro */
                               STRING(TIME,"HH:MM:SS") + 
                               " - " + glb_cdprogra + " --> " +
                               glb_dscritic + " --> " + aux_nmarquiv).
            
            UNIX SILENT VALUE("rm " + aux_nmarquiv + ".q").
            NEXT.    
        END.

   INPUT STREAM str_5 CLOSE.
    
   ASSIGN aux_contador = aux_contador + 1.
          tab_nmarquiv[aux_contador] = aux_nmarquiv.

END.  /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_4 CLOSE.

IF   aux_contador = 0 THEN
     DO:
         glb_cdcritic = 258. /* nao ha arquivo para integrar */
         RUN fontes/critic.p.

         RUN gera_log_batch_prog("E", 1, /* 1 - mensagem */
                            STRING(TIME,"HH:MM:SS") + 
                            " - " + glb_cdprogra + " --> " + glb_dscritic).

         RUN fontes/fimprg.p.
         RETURN.                
     END.

DO  i = 1 TO aux_contador:
      
    ASSIGN aux_contareg = 1
           aux_flgrejei = FALSE.
                      
    glb_cdcritic = 219.
    RUN fontes/critic.p.

    RUN gera_log_batch_prog("E", 1, /* 1 - mensagem */
                      STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + " --> " +
                      glb_dscritic + " --> " + tab_nmarquiv[i]).
                       
    glb_cdcritic = 0.

    INPUT STREAM str_5 FROM VALUE(tab_nmarquiv[i] + ".q") NO-ECHO.

    SET STREAM str_5 aux_setlinha  WITH FRAME AA WIDTH 210.

    IF    INTEGER(STRING(SUBSTR(aux_setlinha,01,01),"9")) <> 0 THEN
          glb_cdcritic = 468.
    
    IF    glb_cdcritic <> 0 THEN
          DO:
              RUN fontes/critic.p.
              aux_nmarquiv = "compbb/err" + SUBSTR(tab_nmarquiv[i],12,29).
              UNIX SILENT VALUE("rm " + tab_nmarquiv[i] + ".q 2> /dev/null").
              UNIX SILENT VALUE("mv " + tab_nmarquiv[i] + " " + aux_nmarquiv).

              RUN gera_log_batch_prog("E", 2, /* 2 - erro */ 
                                STRING(TIME,"HH:MM:SS") +
                                " - " + glb_cdprogra + "' --> '" +
                                glb_dscritic + " " + tab_nmarquiv[i] + " Seq." +
                                STRING(aux_contareg, "9999")).

              glb_cdcritic = 0.
              NEXT.
          END.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       SET STREAM str_5 aux_setlinha WITH FRAME AA WIDTH 210.

       ASSIGN aux_contareg = aux_contareg + 1.
       
       /*  Verifica se eh final do Arquivo  */
       
       IF   INTEGER(SUBSTR(aux_setlinha,1,1)) = 9 THEN
            LEAVE.
          
       DO   i2 = 1 TO 4:
       
            CASE i2:
                               
                 WHEN 1 THEN aux_nrcoluna = 10.
                 WHEN 2 THEN aux_nrcoluna = 52.
                 WHEN 3 THEN aux_nrcoluna = 94.
                 WHEN 4 THEN aux_nrcoluna = 136.
                        
            END CASE.

            ASSIGN aux_cdbanchq = 
                       INT(SUBSTR(aux_setlinha,aux_nrcoluna,03))
                   aux_cdagechq = 
                       INT(SUBSTR(aux_setlinha,aux_nrcoluna + 3,04))
                   aux_nrctachq = 
                       DEC(SUBSTR(aux_setlinha,aux_nrcoluna + 7,10))
                   aux_nrcheque = 
                       INT(SUBSTR(aux_setlinha,aux_nrcoluna + 17,06))
                   aux_nralinea = 
                       INT(SUBSTR(aux_setlinha,aux_nrcoluna + 40,02))
                   aux_vlcheque = 
                       DEC(SUBSTR(aux_setlinha,aux_nrcoluna + 23,17)) / 100.

            FIND crawrel WHERE crawrel.cdbanchq = aux_cdbanchq AND
                               crawrel.cdagechq = aux_cdagechq AND
                               crawrel.nrctachq = aux_nrctachq AND
                               crawrel.nrcheque = aux_nrcheque
                               USE-INDEX crawrel1 NO-LOCK NO-ERROR.
                     
            IF   AVAILABLE crawrel OR
                 aux_cdbanchq = 0  THEN
                 NEXT.

            FIND FIRST crapchd WHERE crapchd.cdcooper = glb_cdcooper    AND
                                     crapchd.cdbanchq = aux_cdbanchq    AND
                                     crapchd.cdagechq = aux_cdagechq    AND
                                     crapchd.nrctachq = aux_nrctachq    AND
                                     crapchd.nrcheque = aux_nrcheque
                                     USE-INDEX crapchd4 NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapchd THEN
                 glb_cdcritic = 244.
                                    
            IF   glb_cdcritic <> 0 THEN
                 DO:
                     RUN fontes/critic.p.
                                   
                     ASSIGN glb_cdcritic = 0
                            aux_flgrejei = TRUE.
                 
                     CREATE crawrel.
                     ASSIGN crawrel.cdagenci = 0
                            crawrel.nrdconta = 0
                            crawrel.nmprimtl = glb_dscritic
                            crawrel.nralinea = aux_nralinea
                            crawrel.cdcmpchq = 0
                            crawrel.cdbanchq = aux_cdbanchq
                            crawrel.cdagechq = aux_cdagechq
                            crawrel.nrctachq = aux_nrctachq
                            crawrel.nrcheque = aux_nrcheque
                            crawrel.vlcheque = aux_vlcheque.
                     
                     NEXT.
                 END.
        
            /* --- Verificar se Houve transferencia ---*/
            ASSIGN aux_nrdconta = crapchd.nrdconta.
                 
            DO WHILE TRUE:

               FIND crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                                  crapass.nrdconta = aux_nrdconta
                                  USE-INDEX crapass1 NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE crapass   THEN
                    glb_cdcritic = 9.
               ELSE
               IF   crapass.dtelimin <> ?  THEN
                    glb_cdcritic = 410.
               ELSE
               IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
                    glb_cdcritic = 695.
               ELSE
               IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
                    DO:
                       FIND FIRST craptrf WHERE  
                                  craptrf.cdcooper = glb_cdcooper       AND
                                  craptrf.nrdconta = crapass.nrdconta   AND
                                  craptrf.tptransa = 1                  AND
                                  craptrf.insittrs = 2
                                  USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                        IF   AVAILABLE craptrf THEN
                             DO:
                                aux_nrdconta = craptrf.nrsconta.
                                NEXT.
                             END.
                        ELSE
                             glb_cdcritic = 95.
                    END.

               FIND FIRST craptfc WHERE craptfc.cdcooper = glb_cdcooper     AND
                                        craptfc.nrdconta = crapass.nrdconta 
                                        NO-LOCK NO-ERROR.
               IF AVAIL craptfc THEN
                  aux_nrtelefo = "(" + STRING(craptfc.nrdddtfc) + ") " +
                                 STRING(craptfc.nrtelefo).
               ELSE
                  aux_nrtelefo = "".

               LEAVE.
            
            END.  /*  Fim do DO WHILE TRUE  */

            IF   glb_cdcritic <> 0 THEN
                 DO:
                     RUN fontes/critic.p.

                     RUN gera_log_batch_prog("E", 2,
                                       STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " " + tab_nmarquiv[i] +
                                       " Seq." +  STRING(aux_contareg, "9999")).

                     ASSIGN glb_cdcritic = 0
                            aux_flgrejei = TRUE.
                 
                     CREATE crawrel.
                     ASSIGN crawrel.cdagenci = 0
                            crawrel.nrdconta = 0
                            crawrel.nmprimtl = glb_dscritic
                            crawrel.nralinea = aux_nralinea
                            crawrel.cdcmpchq = 0
                            crawrel.cdbanchq = aux_cdbanchq
                            crawrel.cdagechq = aux_cdagechq
                            crawrel.nrctachq = aux_nrctachq
                            crawrel.nrcheque = aux_nrcheque
                            crawrel.vlcheque = aux_vlcheque.
                     
                     NEXT.
                 END.
            /*--------------------------------*/
            
            IF   crapchd.cdbccxlt = 600   THEN           /*  Cheque custodia  */
                 ASSIGN dpb_cdagenci = 1
                        dpb_cdbccxlt = 100
                        dpb_nrdolote = 4500.
            ELSE
                 ASSIGN dpb_cdagenci = crapchd.cdagenci
                        dpb_cdbccxlt = crapchd.cdbccxlt
                        dpb_nrdolote = crapchd.nrdolote.

            FIND crapdpb WHERE crapdpb.cdcooper = glb_cdcooper      AND
                               crapdpb.dtmvtolt = crapchd.dtmvtolt  AND
                               crapdpb.cdagenci = dpb_cdagenci      AND
                               crapdpb.cdbccxlt = dpb_cdbccxlt      AND
                               crapdpb.nrdolote = dpb_nrdolote      AND
                               crapdpb.nrdconta = aux_nrdconta      AND
                               crapdpb.nrdocmto = crapchd.nrdocmto
                               USE-INDEX crapdpb1 NO-ERROR.
                          
            IF   NOT AVAILABLE crapdpb THEN
                 aux_cdhistor = 351.     
            ELSE
                 DO:
                     IF   crapdpb.inlibera = 1 THEN
                          DO:
                              IF   crapdpb.dtliblan <= glb_dtmvtolt THEN
                                   aux_cdhistor = 351.
                              ELSE
                                   DO:
                                       CASE crapdpb.cdhistor:
                               
                                            WHEN   3 THEN aux_cdhistor =  24.
                                            WHEN   4 THEN aux_cdhistor =  27.
                                            WHEN 357 THEN aux_cdhistor = 657.
                                            OTHERWISE     aux_cdhistor = 351.
                         
                                       END CASE.
                                   END.    
                          END.
                     ELSE
                          aux_cdhistor = 351.
                 END.
       
            IF   crapchd.cdbccxlt = 700 THEN  /*  desconto de cheques  */
                 aux_cdhistor = 399.
            
            DO TRANSACTION:

               DO WHILE TRUE:

                  FIND craplot WHERE craplot.cdcooper = glb_cdcooper    AND
                                     craplot.dtmvtolt = glb_dtmvtolt    AND
                                     craplot.cdagenci = 1               AND
                                     craplot.cdbccxlt = 100             AND
                                     craplot.nrdolote = 4650
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE craplot   THEN
                       IF   LOCKED craplot   THEN
                            DO:
                                PAUSE 2 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            DO:
                                CREATE craplot.
                                ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                       craplot.dtmvtopg = glb_dtmvtopr
                                       craplot.cdagenci = 1
                                       craplot.cdbccxlt = 100
                                       craplot.cdoperad = "1"
                                       craplot.nrdolote = 4650
                                       craplot.tplotmov = 1
                                       craplot.tpdmoeda = 1
                                       craplot.cdcooper = glb_cdcooper.
                            END.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               aux_nrcheque = crapchd.nrcheque.

               DO WHILE TRUE:

                  FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper    AND
                                     craplcm.dtmvtolt = glb_dtmvtolt    AND
                                     craplcm.cdagenci = 1               AND
                                     craplcm.cdbccxlt = 100             AND
                                     craplcm.nrdolote = 4650            AND
                                     craplcm.nrdctabb = aux_nrdconta    AND
                                     craplcm.nrdocmto = aux_nrcheque
                                     USE-INDEX craplcm1
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   AVAILABLE craplcm THEN
                       aux_nrcheque = (aux_nrcheque + 1000000).
                  ELSE
                       LEAVE.
          
               END.  /*  Fim do DO WHILE TRUE  */

               IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                 RUN sistema/generico/procedures/b1wgen0200.p
                   PERSISTENT SET h-b1wgen0200.

               RUN gerar_lancamento_conta_comple IN h-b1wgen0200
                 (INPUT glb_dtmvtolt                              /* par_dtmvtolt */
                 ,INPUT 1                                         /* par_cdagenci */
                 ,INPUT 100                                       /* par_cdbccxlt */
                 ,INPUT 4650                                      /* par_nrdolote */
                 ,INPUT aux_nrdconta                              /* par_nrdconta */
                 ,INPUT aux_nrcheque                              /* par_nrdocmto */
                 ,INPUT aux_cdhistor                              /* par_cdhistor */
                 ,INPUT craplot.nrseqdig + 1                      /* par_nrseqdig */
                 ,INPUT aux_vlcheque                              /* par_vllanmto */
                 ,INPUT aux_nrdconta                              /* par_nrdctabb */
                 ,INPUT STRING(aux_nralinea,"99")                 /* par_cdpesqbb */
                 ,INPUT 0                                         /* par_vldoipmf */
                 ,INPUT 0                                         /* par_nrautdoc */
                 ,INPUT 0                                         /* par_nrsequni */
                 ,INPUT crapchd.cdbanchq                          /* par_cdbanchq */
                 ,INPUT crapchd.cdcmpchq                          /* par_cdcmpchq */
                 ,INPUT crapchd.cdagechq                          /* par_cdagechq */
                 ,INPUT crapchd.nrctachq                          /* par_nrctachq */
                 ,INPUT 0                                         /* par_nrlotchq */
                 ,INPUT 0                                         /* par_sqlotchq */
                 ,INPUT aux_dtleiarq                              /* par_dtrefere */
                 ,INPUT ""                                        /* par_hrtransa */
                 ,INPUT 0                                         /* par_cdoperad */
                 ,INPUT "BB"                                      /* par_dsidenti */
                 ,INPUT glb_cdcooper                              /* par_cdcooper */
                 ,INPUT STRING(aux_nrdconta,"99999999")           /* par_nrdctitg */
                 ,INPUT ""                                        /* par_dscedent */
                 ,INPUT 0                                         /* par_cdcoptfn */
                 ,INPUT 0                                         /* par_cdagetfn */
                 ,INPUT 0                                         /* par_nrterfin */
                 ,INPUT 0                                         /* par_nrparepr */
                 ,INPUT 0                                         /* par_nrseqava */
                 ,INPUT 0                                         /* par_nraplica */
                 ,INPUT 0                                         /* par_cdorigem */
                 ,INPUT 0                                         /* par_idlautom */
                 /* CAMPOS OPCIONAIS DO LOTE                                                            */
                 ,INPUT 0                              /* Processa lote                                 */
                 ,INPUT 0                              /* Tipo de lote a movimentar                     */
                 /* CAMPOS DE SAÍDA                                                                     */
                 ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
                 ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
                 ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
                 ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */

               /* Trata critica se retornada */
               IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
               DO:
                      RUN gera_log_batch_prog("E", 1,
                      STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '" +
                      glb_dscritic + "' --> '").
                 ASSIGN glb_cdcritic = 0
                        aux_flgrejei = TRUE.

                 CREATE crawrel.
                 ASSIGN crawrel.cdagenci = 1
                        crawrel.nrdconta = aux_nrdconta
                        crawrel.nmprimtl = aux_dscritic
                        crawrel.nralinea = aux_nralinea
                        crawrel.cdcmpchq = crapchd.cdcmpchq
                        crawrel.cdbanchq = crapchd.cdbanchq
                        crawrel.cdagechq = crapchd.cdagechq
                        crawrel.nrctachq = crapchd.nrctachq
                        crawrel.nrcheque = aux_nrcheque
                        crawrel.vlcheque = aux_vlcheque.

                 NEXT.
               END.

               IF  VALID-HANDLE(h-b1wgen0200) THEN
                 DELETE PROCEDURE h-b1wgen0200.

               /* continua processamento do registro se não houve nenhuma critica */
               ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
                      craplot.qtcompln = craplot.qtcompln + 1
                      craplot.qtinfoln = craplot.qtinfoln + 1
                      craplot.vlcompdb = craplot.vlcompdb + aux_vlcheque

                      craplot.vlcompcr = 0
                      craplot.vlinfodb = craplot.vlcompdb
                      craplot.vlinfocr = 0. 

                VALIDATE craplot.

               /*   Tratamento de Cheques Bloqueados  */
               IF   aux_cdhistor = 24    OR
                    aux_cdhistor = 27    OR
                    aux_cdhistor = 657   THEN
                    DO:
                        IF   aux_vlcheque = crapdpb.vllanmto THEN
                             crapdpb.inlibera = 2.   /* Dep. Estornado */
                        ELSE
                             /*  Deposito com varios cheques */
                             crapdpb.vllanmto = (crapdpb.vllanmto - 
                                                 aux_vlcheque).
                    END.
      
			   IF crapass.inpessoa = 1 THEN
			      DO:
				     FOR FIRST crapttl FIELDS(nmextttl)
					                   WHERE crapttl.cdcooper = crapass.cdcooper AND
									         crapttl.nrdconta = crapass.nrdconta AND
											 crapttl.idseqttl = 2
											 NO-LOCK:

                     END.
					  
				  END.

               CREATE crawrel.
               ASSIGN crawrel.cdagenci = crapass.cdagenci
                      crawrel.nrdconta = aux_nrdconta
                      crawrel.nmprimtl = crapass.nmprimtl
                      crawrel.nmsegntl = crapttl.nmextttl WHEN AVAIL crapttl
                      crawrel.nrfonres = aux_nrtelefo
                      crawrel.cdbanchq = crapchd.cdbanchq
                      crawrel.nrcheque = crapchd.nrcheque
                      crawrel.nrctachq = aux_nrctachq
                      crawrel.cdagechq = aux_cdagechq
                      crawrel.nralinea = aux_nralinea
                      crawrel.vlcheque = crapchd.vlcheque.
                                   
               /*   Atualizacao no Cadastro de Emitentes de Cheques  */
          
               FIND crapcec WHERE crapcec.cdcooper = glb_cdcooper       AND
                                  crapcec.cdcmpchq = crapchd.cdcmpchq   AND
                                  crapcec.cdbanchq = crapchd.cdbanchq   AND
                                  crapcec.cdagechq = crapchd.cdagechq   AND
                                  crapcec.nrctachq = crapchd.nrctachq   AND
                                  crapcec.nrdconta = aux_nrdconta
                                  EXCLUSIVE-LOCK NO-ERROR.
 
               IF   AVAILABLE crapcec THEN
                    ASSIGN crapcec.dtultdev = glb_dtmvtolt
                           crapcec.qtchqdev = crapcec.qtchqdev + 1.
    
            END.   /*    Fim do Transaction   */

       END.  /*  Fim do DO TO  */
    
    END.  /*   Fim  do DO WHILE TRUE  */

    INPUT STREAM str_5 CLOSE.
                  
    UNIX SILENT VALUE("mv " + tab_nmarquiv[i] + " salvar"). 
    UNIX SILENT VALUE("rm " + tab_nmarquiv[i] + ".q 2> /dev/null"). 

    glb_cdcritic = IF   aux_flgrejei THEN 
                        191 
                   ELSE 
                        190.
 
    RUN fontes/critic.p.

    RUN gera_log_batch_prog("E", 1,
                      STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '" +
                      glb_dscritic + "' --> '" +  tab_nmarquiv[i]).                      

END.   /*   Fim  do DO TO   */

/***   Geracao dos Avisos de Devolucao - 310   ***/

aux_flgfirst = TRUE.

FOR EACH crawrel USE-INDEX crawrel2 BREAK BY crawrel.cdagenci 
                                             BY crawrel.nrdconta:    

    IF   crawrel.cdagenci = 0 THEN
         NEXT.
    
    IF   aux_flgfirst THEN
         DO:
             aux_nmarqimp = "rl/crrl310.lst".
    
             OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 85.

             FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper     AND
                                crapemp.cdempres = glb_cdempres 
                                NO-LOCK NO-ERROR.
                                
             IF   NOT AVAILABLE crapemp   THEN
                  rel_nmresemp = FILL("?",11).
             ELSE
                  rel_nmresemp = SUBSTRING(crapemp.nmresemp,1,11).
             
             FIND craprel WHERE craprel.cdcooper = glb_cdcooper     AND
                                craprel.cdrelato = glb_cdrelato[1]
                                NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE craprel   THEN
                  ASSIGN rel_nmrelato[1] = FILL("?",17)
                         rel_nrmodulo    = 1.
             ELSE
                  ASSIGN rel_nmrelato[1] = craprel.nmrelato
                         rel_nrmodulo    = craprel.nrmodulo.
            
             VIEW STREAM str_1 FRAME f_cabrel080_1. 
                                             
             ASSIGN aux_flgfirst = FALSE.
         END.
    
    IF   FIRST-OF(crawrel.nrdconta) THEN
         DO:
             ASSIGN aux_qtdecheq = 0
                    aux_totdcheq = 0.
         
             DISPLAY STREAM str_1 crawrel.cdagenci crawrel.nrdconta
                                  crawrel.nmprimtl crawrel.nrfonres
                                  WITH FRAME f_cabec_310.
         END.

    ASSIGN aux_qtdecheq = aux_qtdecheq + 1
           aux_totdcheq = aux_totdcheq + crawrel.vlcheque.
    
    FIND crapali WHERE crapali.cdalinea = crawrel.nralinea  NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapali THEN 
         aux_dsalinea = "NAO CADASTRADA".
    ELSE
         aux_dsalinea = crapali.dsalinea.
    
    DISPLAY STREAM str_1 crawrel.cdbanchq  crawrel.nrcheque
                         crawrel.nralinea  aux_dsalinea
                         crawrel.vlcheque  
                         WITH FRAME f_lanc_310.
    
    DOWN STREAM str_1 WITH FRAME f_lanc_310.

    CREATE rel310.
    ASSIGN rel310.cdagenci = crawrel.cdagenci
           rel310.nrdconta = crawrel.nrdconta
           rel310.nmprimtl = crawrel.nmprimtl
           rel310.nmsegntl = crawrel.nmsegntl
           rel310.nrfonres = crawrel.nrfonres 
           rel310.cdbanchq = crawrel.cdbanchq
           rel310.nrcheque = crawrel.nrcheque
           rel310.nralinea = crawrel.nralinea
           rel310.vlcheque = crawrel.vlcheque
           rel310.auxaline = aux_dsalinea
           rel310.auxqtdch = aux_qtdecheq
           rel310.totchequ = aux_totdcheq.
             
    IF   LAST-OF(crawrel.nrdconta) THEN
         DO:
             DISPLAY STREAM str_1 aux_qtdecheq     aux_totdcheq
                                  crawrel.nmprimtl crawrel.nmsegntl
                                  crawrel.nrdconta
                                  WITH FRAME f_total_310.

             IF   aux_qtdecheq > 3  THEN
                  PAGE STREAM str_1.
             ELSE
             IF   aux_qtdecheq = 1  THEN
                  DO:
                      DISPLAY STREAM str_1 WITH FRAME f_tracejado3.
                      DISPLAY STREAM str_1 WITH FRAME f_cabrel080_1.
                  END.
             ELSE
             IF   aux_qtdecheq = 2  THEN
                  DO:
                      DISPLAY STREAM str_1 WITH FRAME f_tracejado2.
                      DISPLAY STREAM str_1 WITH FRAME f_cabrel080_1.
                  END.
             ELSE
                  IF   aux_qtdecheq = 3  THEN
                       DO: 
                           DISPLAY STREAM str_1 WITH FRAME f_tracejado1.
                           DISPLAY STREAM str_1 WITH FRAME f_cabrel080_1.
                       END.
                                  
             FOR EACH rel310 BREAK BY rel310.cdagenci
                                      BY rel310.nrdconta:

                 IF   FIRST-OF(rel310.nrdconta)  THEN
                      DO:
                          DISPLAY STREAM str_1 rel310.cdagenci
                                               rel310.nrdconta
                                               rel310.nmprimtl
                                               rel310.nrfonres
                                               WITH FRAME f_cabec_rel310. 
                      END.        
       
                 DISPLAY STREAM str_1 rel310.cdbanchq  rel310.nrcheque
                                                       rel310.nralinea
                                                       rel310.auxaline
                                                       rel310.vlcheque  
                                                       WITH FRAME f_lanc_rel310.
                                  
                 DOWN STREAM str_1 WITH FRAME f_lanc_rel310. 
               
                 IF   LAST-OF(rel310.nrdconta)  THEN
                      DO:
                          DISPLAY STREAM str_1 rel310.auxqtdch
                                               rel310.totchequ
                                               rel310.nmprimtl
                                               rel310.nmsegntl
                                               rel310.nrdconta
                                               WITH FRAME  f_total_rel310.
                
                          IF   rel310.auxqtdch > 3  THEN
                               PAGE STREAM str_1.                             
                      END.
             END.
             
             EMPTY TEMP-TABLE  rel310.

         END.
              
END.  /* Fim FOR EACH -- crawrel */
            
IF   NOT aux_flgfirst THEN
     DO:
         OUTPUT STREAM str_1 CLOSE.
 
         ASSIGN glb_nrcopias = 1
                glb_nmformul = "80col"
                glb_nmarqimp = aux_nmarqimp.
             
         RUN fontes/imprim.p.
     END.
 
/***   Geracao do Resumo das Devolucoes - 309   ***/

ASSIGN aux_flgfirst = TRUE    
       aux_flgerros = TRUE
       aux_flgerro2 = TRUE
       tot_qtdecheq = 0
       tot_totdcheq = 0.

{ includes/cabrel080_2.i }
{ includes/cabrel080_3.i }

FOR EACH crawrel USE-INDEX crawrel2 BREAK BY crawrel.cdagenci
                                             BY crawrel.nrdconta:    
    
    IF   aux_flgfirst THEN
         DO:
             ASSIGN aux_nmarqrl1 = "rl/crrl309_999.lst"
                    aux_flgfirst = FALSE.
             
             OUTPUT STREAM str_2 TO VALUE(aux_nmarqrl1) PAGED PAGE-SIZE 84.

             VIEW STREAM str_2 FRAME f_cabrel080_2.
         END.
    
    IF   crawrel.cdagenci = 0 THEN
         DO:
             IF   aux_flgerro2 THEN
                  DO:
                      VIEW STREAM str_2 FRAME f_cabec_erro_309.
                      aux_flgerro2 = FALSE.
                  END.

             ASSIGN tot_qtdecheq = tot_qtdecheq + 1
                    tot_totdcheq = tot_totdcheq + crawrel.vlcheque.

             DISPLAY STREAM str_2 crawrel.nmprimtl crawrel.cdbanchq
                                  crawrel.cdagechq crawrel.vlcheque           
                                  crawrel.nralinea crawrel.nrcheque
                                  WITH FRAME f_lanc_erro_309.

             DOWN STREAM str_2 WITH FRAME f_lanc_erro_309.
             
             NEXT.
         END.
    
    IF    aux_flgerros THEN
          DO:
              DISPLAY STREAM str_2 tot_qtdecheq tot_totdcheq 
                     WITH FRAME f_total_geral_309.
       
              PAGE STREAM str_2.
              
              ASSIGN aux_qtdecheq = 0
                     aux_totdcheq = 0
                     tot_qtdecheq = 0
                     tot_totdcheq = 0
                     aux_flgerros = FALSE.
          END.
     
    IF   FIRST-OF(crawrel.cdagenci) THEN
         DO:
             aux_nmarqrl2 = "rl/crrl309_" + STRING(crawrel.cdagenci,"999") +
                            ".lst".
    
             OUTPUT STREAM str_3 TO VALUE(aux_nmarqrl2) PAGED PAGE-SIZE 84.

             VIEW STREAM str_3 FRAME f_cabrel080_3.

             ASSIGN aux_qtdecheq = 0
                    aux_totdcheq = 0.
         
             FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                                crapage.cdagenci = crawrel.cdagenci 
                                NO-LOCK NO-ERROR.
                                
             IF   NOT AVAILABLE crapage THEN
                  DO:
                      glb_cdcritic = 015.
                      RUN fontes/critic.p.
                                        
                      RUN gera_log_batch_prog("E", 2,
                                        STRING(TIME,"HH:MM:SS") +
                                        " - " + glb_cdprogra + " --> " +
                                        glb_dscritic + "  " + 
                                        aux_nmarqrl2).
                                        
                      glb_cdcritic = 0.
                      NEXT.
                  END.
             
             DISPLAY STREAM str_2 crawrel.cdagenci crapage.nmresage
                                  WITH FRAME f_cabec_309.
             
             DISPLAY STREAM str_3 crawrel.cdagenci crapage.nmresage
                                  WITH FRAME f_cabec_309.
         END.

    DISPLAY STREAM str_2 crawrel.nrdconta  crawrel.nmprimtl
                         crawrel.cdbanchq  crawrel.nrcheque
                         crawrel.nralinea  crawrel.vlcheque
                         WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_lanc_309.
 
    DISPLAY STREAM str_3 crawrel.nrdconta  crawrel.nmprimtl
                         crawrel.cdbanchq  crawrel.nrcheque
                         crawrel.nralinea  crawrel.vlcheque
                         WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_lanc_309.
                     
    DOWN STREAM str_2 WITH FRAME f_lanc_309.
    
    DOWN STREAM str_3 WITH FRAME f_lanc_309.

    ASSIGN aux_qtdecheq = aux_qtdecheq + 1
           aux_totdcheq = aux_totdcheq + crawrel.vlcheque
           tot_qtdecheq = tot_qtdecheq + 1
           tot_totdcheq = tot_totdcheq + crawrel.vlcheque.
        
    IF   LINE-COUNTER(str_2) > 77 THEN
         PAGE STREAM str_2.
         
    IF   LINE-COUNTER(str_3) > 77 THEN
         PAGE STREAM str_3.
 
    IF   LAST-OF(crawrel.cdagenci) THEN
         DO:
             DISPLAY STREAM str_2 aux_qtdecheq aux_totdcheq 
                     WITH FRAME f_total_309.
       
             DISPLAY STREAM str_3 aux_qtdecheq aux_totdcheq 
                     WITH FRAME f_total_309.

             DISPLAY STREAM str_3 WITH FRAME f_visto_309.
       
             OUTPUT STREAM str_3 CLOSE.
         END.
                           
END.   /*   Fim  do rel.  crrl309  */
 
IF   tot_qtdecheq > 0 THEN
     DO:
         DISPLAY STREAM str_2 tot_qtdecheq tot_totdcheq 
                     WITH FRAME f_total_geral_309.
       
         OUTPUT STREAM str_2 CLOSE.
 
         ASSIGN glb_nrcopias = 1
                glb_nmformul = "80col"
                glb_nmarqimp = aux_nmarqrl1.
             
         RUN fontes/imprim.p.
     END.

RUN fontes/fimprg.p.

/* .......................................................................... */
