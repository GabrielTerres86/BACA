/* .............................................................................

   Programa: Fontes/crps456.p     
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Setembro/2005.                   Ultima atualizacao: 11/06/2018

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 100
               Processar os TEDs oriundos da compensacao do Banco do Brasil via
               arquivo DEB668 - CONTA INTEGRACAO.
               Emite relatorio 429

   Alteracoes: 28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               21/11/2005 - Ajuste no programa. (Ze).
               
               07/12/2005 - Inclusao de novos historicos no 668 (Ze).

               10/12/2005 - Atualizar craprey.nrdctitg (Magui).

               14/12/2005 - Ajuste de lancamentos integrados (Ze).
               
               22/12/2005 - Nao imprimir a critica 92 - Viacredi (Ze).
               
               23/12/2005 - Incluir o historico de Salario (Ze).
               
               05/01/2006 - Atualizacao dos historicos (Ze).
               
               07/02/2006 - Identificacao no craprej (Ze).
               
               17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               15/12/2008 - Substituir a tab "ContaConve" pela gnctace (Ze).
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
							
               11/06/2018 - Alteraçao  Tratamento de Históricos de Credito/Debito - Fabiano B. Dias AMcom
							
............................................................................. */

DEF STREAM str_1.   /*  Para relatorio de criticas  */
DEF STREAM str_2.   /*  Para arquivo a integrar  */
DEF STREAM str_3.   /*  Para arquivos com os saldos das contas  */

{ includes/var_batch.i }
{ sistema/generico/includes/b1wgen0200tt.i }

DEFINE TEMP-TABLE crawlcm FIELD cdagenci AS INT
                          FIELD nrdconta AS INT
                          FIELD nmprimtl AS CHAR
                          FIELD nrdctabb AS INT
                          FIELD nrdocmto AS DECIMAL
                          FIELD dshistor AS CHAR 
                          FIELD cdpesqbb AS CHAR
                          FIELD vllanmto AS DECIMAL
                          INDEX crawlcm1 AS PRIMARY cdagenci nrdconta nrdocmto.

DEFINE TEMP-TABLE crawarq                                            NO-UNDO
       FIELD nmarquiv  AS CHAR              
       FIELD nrsequen  AS INTEGER
       FIELD qtassoci  AS INTEGER
       INDEX crawarq_1 AS PRIMARY nmarquiv nrsequen.
 
DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR tot_contareg AS INT                                   NO-UNDO.
DEF        VAR tot_vllanmto AS DECIMAL                               NO-UNDO.

DEF        VAR lot_qtcompln AS INT                                   NO-UNDO.
DEF        VAR lot_vlcompcr AS DECIMAL                               NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmarqdat AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_dtleiarq AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmarqlog AS CHAR                                  NO-UNDO.
DEF        VAR aux_tamarqui AS CHAR                                  NO-UNDO.

DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgerros AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgclote AS LOGICAL                               NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdhistor AS INT                                   NO-UNDO.
DEF        VAR aux_nrdolote AS INT                                   NO-UNDO.

DEF        VAR aux_nrdctabb AS INT     FORMAT "99999999"             NO-UNDO.
DEF        VAR rel_nrdctabb AS INT     FORMAT "99999999"             NO-UNDO.
DEF        VAR aux_nrdctitg AS CHAR    FORMAT "9.999.999-X"          NO-UNDO.

DEF        VAR aux_nrdconta AS INT     FORMAT "99999999"             NO-UNDO.
DEF        VAR aux_nmprimtl AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR aux_nrseqint AS INT     FORMAT "999999"               NO-UNDO.
DEF        VAR aux_nrdocmto AS INT     FORMAT "99999999"             NO-UNDO.
DEF        VAR aux_vllanmto AS DECIMAL FORMAT "99999999999999.99"    NO-UNDO.

DEF        VAR aux_dsdlinha AS CHAR    FORMAT "x(210)"               NO-UNDO.
DEF        VAR aux_cdpesqbb AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR aux_dshistor AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR aux_dtrefere AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF        VAR aux_dsageori AS CHAR    FORMAT "x(7)"                 NO-UNDO.
DEF        VAR aux_dshstdep AS CHAR                                  NO-UNDO.
DEF        VAR aux_lscontas AS CHAR                                  NO-UNDO.

DEF        VAR h-b1wgen0200 AS HANDLE                                NO-UNDO.
DEF        VAR aux_incrineg AS INT                                   NO-UNDO.
DEF        VAR aux_cdcritic AS INT                                   NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.

ASSIGN glb_cdprogra = "crps456"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FORM SKIP(2)
     "LANCAMENTOS INTEGRADOS:"
     SKIP(1)
  "PA    CONTA/DV  NOME                                   CONTA-ITG  DOCUMENTO"
      AT  1
     "HISTORICO        COD. PESQUISA     VALOR DO LANCAMENTO"   AT 79
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_labelace.

FORM crawlcm.cdagenci AT   1 FORMAT "z99"
     crawlcm.nrdconta AT   5 FORMAT "zzzz,zz9,9"
     crawlcm.nmprimtl AT  17 FORMAT "x(36)"
     crawlcm.nrdctabb AT  55 FORMAT "zzzz,zz9,9"
     crawlcm.nrdocmto AT  66 FORMAT "zzzz,zzz,9"
     crawlcm.dshistor AT  79 FORMAT "x(15)"
     crawlcm.cdpesqbb AT  96 FORMAT "x(20)"
     crawlcm.vllanmto AT 119 FORMAT "zzz,zzz,zz9.99"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_aceitos.

FORM SKIP(3)
     "LANCAMENTOS COM CRITICAS:"
     SKIP(1)
     "SEQ.ARQ HISTORICO BB    CONTA BASE DATA REF    DOCUMENTO COD. PESQUISA"
      AT  1
     "VALOR DO LANCAMENTO    CONTA/DV CRITICA"                      AT 72
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_labelrej.

FORM craprej.nrseqdig AT   1 FORMAT "zzz,zz9"
     craprej.dshistor AT   9 FORMAT "x(15)"
     craprej.nrdctabb AT  25 FORMAT "zzzz,zz9,9"
     craprej.dtrefere AT  36 FORMAT "x(10)"
     craprej.nrdocmto AT  47 FORMAT "zzzz,zzz,9"
     craprej.cdpesqbb AT  58 FORMAT "x(13)"
     craprej.vllanmto AT  72 FORMAT "zzzzzzz,zzz,zz9.99"
     craprej.indebcre AT  91 FORMAT "x"
     craprej.nrdconta AT  93 FORMAT "zzzz,zzz,9"
     glb_dscritic     AT 104 FORMAT "x(29)"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_rejeitados.

FORM SKIP(1)
     tot_contareg AT 1 FORMAT "zzz,zz9" LABEL "QUANTIDADE DE LANCAMENTOS"
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 132 FRAME f_totalrej.

FORM SKIP(1)
     tot_contareg AT  1 FORMAT "zz,zzz,zz9" LABEL "QUANTIDADE DE LANCAMENTOS"
     tot_vllanmto AT 59 FORMAT "z,zzz,zzz,zzz,zzz,zz9.99" LABEL "TOTAL"
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 132 FRAME f_totalint.

FORM SKIP(7)
     "-----------------------------------"    AT 01 
     SKIP 
     "VISTO RESPONSAVEL"   AT 10
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 132 FRAME f_visto.
 

  /*******   FUNCAO PARA CONVERTER CONTA INTEGRACAO PARA NUMERICO *******/
  
  FUNCTION f_ver_contaitg RETURN INTEGER(INPUT  par_nrdctitg AS CHAR):
       
    IF   par_nrdctitg = "" THEN
         RETURN 0.
    ELSE
         DO:
             IF   CAN-DO("1,2,3,4,5,6,7,8,9,0",
                         SUBSTR(par_nrdctitg,LENGTH(par_nrdctitg),1)) THEN
                  RETURN INTEGER(STRING(par_nrdctitg,"99999999")).
             ELSE
                  RETURN INTEGER(SUBSTR(STRING(par_nrdctitg,"99999999"),
                                        1,LENGTH(par_nrdctitg) - 1) + "0").
         END.

  END. /* FUNCTION */

  /*******   FUNCAO PARA VERIFICAR A ULTIMA CONTACONVE CADASTRADA   *******/

  FUNCTION f_ultctaconve RETURNS CHAR(INPUT par_dstextab AS CHAR).

     IF   (R-INDEX(par_dstextab, ",") = LENGTH(TRIM(par_dstextab)))   THEN
          DO:
               par_dstextab = SUBSTR(par_dstextab, 1, 
                                     LENGTH(TRIM(par_dstextab)) - 1).
               par_dstextab = SUBSTR(par_dstextab, 
                                   R-INDEX(par_dstextab, ",") + 1, 10).
          END.
     ELSE
     IF  (R-INDEX(par_dstextab, ",") > 0)   THEN
         par_dstextab = SUBSTR(par_dstextab, R-INDEX(par_dstextab,",") + 1,10). 
 
     RETURN par_dstextab.

  END FUNCTION.

/*  Nao roda para CECRED  */

IF   glb_cdcooper = 3 THEN
     DO:
         RUN fontes/fimprg.p.
         RETURN.
     END.

/*  Busca dados da cooperativa  */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.

/*FOR EACH crawarq:
    DELETE crawarq.
END.*/
EMPTY TEMP-TABLE crawarq.
   
FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper AND
                       craprej.cdagenci = 668 EXCLUSIVE-LOCK TRANSACTION:
    DELETE craprej.
END.    

ASSIGN aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log"
       aux_dtleiarq = STRING(DAY(glb_dtmvtolt),"99") +
                      STRING(MONTH(glb_dtmvtolt),"99") +
                      SUBSTR(STRING(YEAR(glb_dtmvtolt),"9999"),3,2)
       aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                      "/compel/recepcao/DEB668*RET"
       aux_flgfirst = TRUE
       aux_contador = 0
       aux_nrdolote = 0
       aux_flgclote = TRUE.

INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
             NO-ECHO.
                                              
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .

   /* Verifica se o arquivo esta vazio e o remove */
   INPUT STREAM str_2 THROUGH VALUE("wc -m " + aux_nmarquiv + 
                                              " 2> /dev/null") NO-ECHO.
                                                  
   SET STREAM str_2 aux_tamarqui FORMAT "x(30)".
                
   IF   INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0   THEN
        DO:
            UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").
            INPUT STREAM str_2 CLOSE.
            NEXT.
        END.

   INPUT STREAM str_2 CLOSE.

   ASSIGN aux_contador = aux_contador + 1
          aux_nmarqdat = "integra/deb668" + STRING(DAY(glb_dtmvtolt),"99") +
                                            STRING(MONTH(glb_dtmvtolt),"99") +
                                            STRING(YEAR(glb_dtmvtolt),"9999") +
                                            "_" +
                                            STRING(aux_contador,"99999") +
                                            "_" +
                                            STRING(TIME,"99999") +
                                            ".bb".
   
   UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " +
                     aux_nmarqdat + " 2> /dev/null").
   
   UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

   UNIX SILENT VALUE("quoter " + aux_nmarqdat + " > " + 
                      aux_nmarqdat + ".q 2> /dev/null").

   INPUT STREAM str_2 FROM VALUE(aux_nmarqdat + ".q") NO-ECHO.
      
   IMPORT STREAM str_2 UNFORMATTED aux_dsdlinha.

   IF   aux_dtleiarq <> SUBSTR(aux_dsdlinha,96,06) THEN
        DO:
             UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").
             UNIX SILENT VALUE("rm " + aux_nmarqdat + " 2> /dev/null").
             UNIX SILENT VALUE("rm " + aux_nmarqdat + ".q 2> /dev/null").
             NEXT.
        END.
      
   CREATE crawarq.
   ASSIGN crawarq.nrsequen = INT(SUBSTR(aux_dsdlinha,040,07))
          crawarq.nmarquiv = aux_nmarqdat
          aux_flgfirst     = FALSE.
   
   INPUT STREAM str_2 CLOSE.
                                                       
END.  /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_1 CLOSE.

IF   aux_flgfirst  THEN
     DO:
         glb_cdcritic = 258.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                             glb_cdprogra + "' --> '" + glb_dscritic +
                             " >> " + aux_nmarqlog).
         RETURN.
     END.

/* .......................................................................... */

/*  Le tabela com as contas convenio do Banco do Brasil - CTA. ITG. ......... */

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 4,
                       OUTPUT aux_lscontas).

IF   aux_lscontas = "" THEN
     DO:
         glb_cdcritic = 393.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                             glb_cdprogra + "' --> '" + glb_dscritic +
                             " >> " + aux_nmarqlog).
         RETURN.
     END.
ELSE
     ASSIGN rel_nrdctabb = INT(f_ultctaconve(aux_lscontas)).

/*  Le numero de lote a ser usado na integracao  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper       AND
                   craptab.nmsistem = "CRED"             AND
                   craptab.tptabela = "GENERI"           AND
                   craptab.cdempres = 0                  AND
                   craptab.cdacesso = "NUMLOTECBB"       AND
                   craptab.tpregist = 1
                   USE-INDEX craptab1 NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 259.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '" +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RETURN.
     END.
ELSE
     aux_nrdolote = INTEGER(craptab.dstextab).

/* .......................................................................... */

ASSIGN aux_dshstdep = "0502DEPOSITO,0505DEP.CHEQUE,0830DEP.ONLINE," +
                      "0870TRF.ONLINE,0688IMP. RENDA,0874TRF.ONLINE," +
                      "0830DEP.ONLINE,0978BUNGE,0623DOC,0901SALARIO," +
                      "0615AV.CREDITO,0612CRD.INSTR.,0604PROVENTOS," +
                      "0875POUPANCA,0976TED,0976TED-OP FIN,0976TED-DEPOS," +
                     "0976TED-FGTS,0976TED-CREDIT,0976TED-ATP,0976TED-FORNEC," +
                      "0677EMPRESTIMO,0977SEARA,0656CAMBIO,0632ORDEM BANC" +
                      "0886REMUN.ACAO,0626POUPANCA,0910DEP CH BB," +
                      "0805WEG S.A.,0623DEP. COMPE,0805WEG S.A.," +
                      "0734AJUDA ALIM,0789ECT,0787CRCART.PAG," +
                      "0729TRANSFRCIA,0710PROVENTOS".

FOR EACH crawarq BREAK BY crawarq.nrsequen:

   INPUT STREAM str_2 FROM VALUE(crawarq.nmarquiv + ".q") NO-ECHO.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE ON ERROR UNDO, RETURN:

      SET STREAM str_2 aux_dsdlinha WITH WIDTH 212.
      
      ASSIGN glb_cdcritic = 0
             aux_dshistor = TRIM(SUBSTRING(aux_dsdlinha,46,29)).

      IF   SUBSTRING(aux_dsdlinha,1,1) <> "1"   THEN
           NEXT.

      IF   NOT CAN-DO(aux_dshstdep,aux_dshistor)   THEN   /*  Deposito  */
           NEXT.
      
      /*   Se for Debito passa para o proximo registro  */
      
      IF   INT(SUBSTRING(aux_dsdlinha,43,3)) < 200 THEN 
           NEXT.

      /*  Conta da CECRED no Banco do Brasil  */
      
      IF   SUBSTRING(aux_dsdlinha,34,8) = STRING(rel_nrdctabb,"99999999") THEN
           glb_cdcritic = 127.
      ELSE
           DO:
              ASSIGN aux_nrdctabb = f_ver_contaitg(SUBSTR(aux_dsdlinha,34,08)).

              FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                 crapass.nrdctitg = SUBSTR(aux_dsdlinha,34,08)
                                 NO-LOCK NO-ERROR.

              IF   NOT AVAILABLE crapass   THEN
                   glb_cdcritic = 9.
              ELSE
                   IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl)) THEN
                        glb_cdcritic = 695.
                   ELSE
                        IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl)) THEN
                             glb_cdcritic = 95.
                        ELSE
                        IF   crapass.dtelimin <> ?   THEN
                             glb_cdcritic = 410.
                        ELSE
                             DO:
                                 ASSIGN aux_nrdconta = crapass.nrdconta
                                        aux_nmprimtl = crapass.nmprimtl
                                        aux_nrdctitg = crapass.nrdctitg.
                                    
                                 CASE SUBSTR(aux_dshistor,01,04):
                               
                                      WHEN "0688" THEN aux_cdhistor = 646.
                                      WHEN "0623" THEN aux_cdhistor = 314.
                                      WHEN "0976" THEN aux_cdhistor = 651.
                                      OTHERWISE        aux_cdhistor = 169.

                                 END CASE.
                                 
                             END.       
           END.
     
      IF   glb_cdcritic = 0   THEN
           DO:
               ASSIGN aux_nrseqint = INT(SUBSTRING(aux_dsdlinha,195,06))
                      aux_nrdocmto = INT(SUBSTRING(aux_dsdlinha,75,06))
                      aux_vllanmto = DEC(SUBSTRING(aux_dsdlinha,87,18)) / 100
                      aux_cdpesqbb = SUBSTRING(aux_dsdlinha,111,5) + "-000-" +
                                     SUBSTRING(aux_dsdlinha,120,3)
                      aux_dsageori = SUBSTRING(aux_dsdlinha,116,4) + ".00"
                      aux_dtrefere = 
                         IF INT(SUBSTRING(aux_dsdlinha,174,8)) > 0 THEN
                                STRING(DATE(INT(SUBSTRING(aux_dsdlinha,176,2)),
                                            INT(SUBSTRING(aux_dsdlinha,174,2)),
                                            INT(SUBSTRING(aux_dsdlinha,178,4))),
                                                "99.99.9999")
                         ELSE "".
           
               IF   aux_nrdocmto = 0   THEN
                    glb_cdcritic = 22.
               ELSE
                    IF   aux_vllanmto = 0   THEN
                         glb_cdcritic = 91.
           END.
      
      IF   glb_cdcritic = 0  THEN
           DO:
           
               /*  VER SE O TED INTEGROU ANTERIORMENTE  */
         
               /*  CUIDADO: 
                   
                   NAO SELECIONAR POR DOCUMENTO, A NUMERACAO CADASTRADA 
                   NO AYLLOS NEM SEMPRE EH O MESMO QUE VEM DO BANCO DO
                   BRASIL. 
                   PODE HAVER DOIS DOC. COM VALORES DIFERENTE COM A MESMA
                   NUMERACAO DE DOCUMENTO OU DOIS DOC. COM VALORES IGUAIS E 
                   DIFERENTES NUMERACAO DE DOCUMENTO    -    ZE             */
               

               FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper     AND
                                      craplcm.nrdconta = crapass.nrdconta AND
                                      craplcm.dtmvtolt = glb_dtmvtolt     AND
                                      craplcm.cdhistor = aux_cdhistor
                                      NO-LOCK USE-INDEX craplcm2:
                                 
                   IF   craplcm.vllanmto = aux_vllanmto THEN
                        glb_cdcritic = 92.
                   ELSE
                        IF   craplcm.nrdocmto = aux_nrdocmto THEN
                             aux_nrdocmto = (craplcm.nrdocmto + 1000000).
               END.                   
           END.

      TRANS_1:

      DO TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

         IF   glb_cdcritic > 0  THEN
              DO:
                  /* Formata conta integracao */
                  RUN fontes/digbbx.p (INPUT  aux_nrdctabb,
                                       OUTPUT glb_dsdctitg,
                                       OUTPUT glb_stsnrcal).
 
                  CREATE craprej.
                  ASSIGN craprej.cdagenci = 668
                         craprej.dtmvtolt = glb_dtmvtolt
                         craprej.nrdconta = aux_nrdconta
                         craprej.nrdctabb = aux_nrdctabb
                         craprej.nrdctitg = glb_dsdctitg
                         craprej.dshistor = STRING(aux_dshistor,"x(30)") +
                                            aux_dsageori
                         craprej.cdpesqbb = aux_cdpesqbb
                         craprej.nrseqdig = aux_nrseqint
                         craprej.nrdocmto = aux_nrdocmto
                         craprej.vllanmto = aux_vllanmto
                         craprej.indebcre = "C"
                         craprej.dtrefere = aux_dtrefere
                         craprej.cdcritic = glb_cdcritic
                         
                         craprej.dtdaviso = 
                                 IF TRIM(aux_dtrefere) <> ""
                                    THEN DATE(INT(SUBSTR(aux_dtrefere,4,2)),
                                              INT(SUBSTR(aux_dtrefere,1,2)),
                                              INT(SUBSTR(aux_dtrefere,7,4)))
                                    ELSE glb_dtmvtolt
                         
                         craprej.tpintegr = 1
                         craprej.cdcooper = glb_cdcooper
                         glb_cdcritic = 0.
              END.
         ELSE
              DO:
                  IF   aux_flgclote   THEN
                       DO:
                           aux_nrdolote = aux_nrdolote + 1.

                           IF   CAN-FIND(craplot WHERE
                                         craplot.cdcooper = glb_cdcooper   AND
                                         craplot.dtmvtolt = glb_dtmvtolt   AND
                                         craplot.cdagenci = aux_cdagenci   AND
                                         craplot.cdbccxlt = aux_cdbccxlt   AND
                                         craplot.nrdolote = aux_nrdolote
                                         USE-INDEX craplot1)   THEN
                                DO:
                                    glb_cdcritic = 59.
                                    RUN fontes/critic.p.
                                    UNIX SILENT VALUE("echo " + 
                                               STRING(TIME,"HH:MM:SS") +
                                               " - " + glb_cdprogra + "' --> '"
                                               + glb_dscritic +
                                               " COMPBB - LOTE = " +
                                               STRING(aux_nrdolote,"999,999") +
                                               " >> " + aux_nmarqlog).

                                    UNDO TRANS_1, RETURN.
                                END.

                           CREATE craplot.
                           ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                  craplot.cdagenci = aux_cdagenci
                                  craplot.cdbccxlt = aux_cdbccxlt
                                  craplot.nrdolote = aux_nrdolote
                                  craplot.tplotmov = 1
                                  craplot.cdcooper = glb_cdcooper
                                  craptab.dstextab = STRING(aux_nrdolote,"9999")
                                  aux_flgclote     = FALSE.
                       END.
                  ELSE
                       DO:
                          FIND craplot WHERE craplot.cdcooper = glb_cdcooper AND
                                             craplot.dtmvtolt = glb_dtmvtolt AND
                                             craplot.cdagenci = aux_cdagenci AND
                                             craplot.cdbccxlt = aux_cdbccxlt AND
                                             craplot.nrdolote = aux_nrdolote
                                             USE-INDEX craplot1 NO-ERROR.

                          IF   NOT AVAILABLE craplot   THEN
                               DO:
                                   glb_cdcritic = 60.
                                   RUN fontes/critic.p.
                                   UNIX SILENT VALUE("echo " + 
                                            STRING(TIME,"HH:MM:SS") +
                                            " - " + glb_cdprogra + "' --> '" +
                                            glb_dscritic +
                                            " COMPBB - LOTE = " +
                                            STRING(aux_nrdolote,"999,999") +
                                            " >> " + aux_nmarqlog).
                                   UNDO TRANS_1, RETURN.
                               END.
                       END.
                  
                  FIND craphis WHERE craphis.cdcooper = glb_cdcooper AND
                                     craphis.cdhistor = aux_cdhistor
                                     NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE craphis   THEN
                       DO:
                           glb_cdcritic = 80.
                           RUN fontes/critic.p.
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             glb_dscritic + "HST = " +
                                             STRING(aux_cdhistor,"9999") +
                                             " >> " + aux_nmarqlog).
                           UNDO TRANS_1, RETURN.
                       END.

                  /* Identificar orgao expedidor */
                  IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                     RUN sistema/generico/procedures/b1wgen0200.p
                     PERSISTENT SET h-b1wgen0200.

                  RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                     (INPUT craplot.dtmvtolt               /* par_dtmvtolt */
                     ,INPUT craplot.cdagenci               /* par_cdagenci */
                     ,INPUT craplot.cdbccxlt               /* par_cdbccxlt */
                     ,INPUT craplot.nrdolote               /* par_nrdolote */
                     ,INPUT aux_nrdconta                   /* par_nrdconta */
                     ,INPUT aux_nrdocmto                   /* par_nrdocmto */
                     ,INPUT aux_cdhistor                   /* par_cdhistor */
                     ,INPUT aux_nrseqint                   /* par_nrseqdig */
                     ,INPUT aux_vllanmto                   /* par_vllanmto */
                     ,INPUT aux_nrdctabb                   /* par_nrdctabb */
                     ,INPUT aux_cdpesqbb                   /* par_cdpesqbb */
                     ,INPUT 0                              /* par_vldoipmf */
                     ,INPUT 0                              /* par_nrautdoc */
                     ,INPUT 0                              /* par_nrsequni */
                     ,INPUT 0                              /* par_cdbanchq */
                     ,INPUT 0                              /* par_cdcmpchq */
                     ,INPUT 0                              /* par_cdagechq */
                     ,INPUT 0                              /* par_nrctachq */
                     ,INPUT 0                              /* par_nrlotchq */
                     ,INPUT 0                              /* par_sqlotchq */
                     ,INPUT ""                             /* par_dtrefere */
                     ,INPUT ""                             /* par_hrtransa */
                     ,INPUT ""                             /* par_cdoperad */
                     ,INPUT ""                             /* par_dsidenti */
                     ,INPUT glb_cdcooper                   /* par_cdcooper */
                     ,INPUT aux_nrdctitg                   /* par_nrdctitg */
                     ,INPUT ""                             /* par_dscedent */
                     ,INPUT 0                              /* par_cdcoptfn */
                     ,INPUT 0                              /* par_cdagetfn */
                     ,INPUT 0                              /* par_nrterfin */
                     ,INPUT 0                              /* par_nrparepr */
                     ,INPUT 0                              /* par_nrseqava */
                     ,INPUT 0                              /* par_nraplica */
                     ,INPUT 0                              /* par_cdorigem */
                     ,INPUT 0                              /* par_idlautom */
                     /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
                     ,INPUT 0                              /* Processa lote                                 */
                     ,INPUT 0                              /* Tipo de lote a movimentar                     */
                     /* CAMPOS DE SAÍDA                                                                     */                                            
                     ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
                     ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
                     ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
                     ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */
  
  
  
                  IF  VALID-HANDLE(h-b1wgen0200) THEN
                    DELETE PROCEDURE h-b1wgen0200.
                    

                  IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:                    
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       aux_dscritic + " Conta = " +
                                       STRING(aux_nrdconta) +
                                       " >> " + aux_nmarqlog).
                     UNDO TRANS_1, RETURN.
                  END.
                  
					   
                  /* CREATE craplcm. */
                  ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
                         craplot.qtcompln = craplot.qtcompln + 1
                         craplot.vlinfocr = craplot.vlinfocr + aux_vllanmto
                         craplot.vlcompcr = craplot.vlcompcr + aux_vllanmto
                         craplot.nrseqdig = aux_nrseqint. /* craplcm.nrseqdig. */

                  CREATE crawlcm.
                  ASSIGN crawlcm.cdagenci = crapass.cdagenci
                         crawlcm.nrdconta = aux_nrdconta  /* craplcm.nrdconta */
                         crawlcm.nmprimtl = aux_nmprimtl
                         crawlcm.nrdctabb = aux_nrdctabb  /* craplcm.nrdctabb */
                         crawlcm.nrdocmto = aux_nrdocmto  /* craplcm.nrdocmto */
                         crawlcm.dshistor = craphis.dshistor
                         crawlcm.cdpesqbb = aux_cdpesqbb  /* craplcm.cdpesqbb */
                         crawlcm.vllanmto = aux_vllanmto. /* craplcm.vllanmto. */
              END.
              
      END.  /*  Fim da Transacao  */

   END.   /*  Fim do DO WHILE TRUE  */

   INPUT STREAM str_2 CLOSE.
   
   /*  Move arquivo integrado para o diretorio salvar  */

   UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " salvar").
   UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2>/dev/null").

END.

/*  Ver se houve lancamentos no arquivo para a impressao dos relatorios  */
        
IF   NOT  aux_flgfirst  THEN
     DO:
          /*  Emite resumo da integracao  */

          { includes/cabrel132_1.i }       /* Monta cabecalho do relatorio */
          
          IF   NOT aux_flgclote   THEN
               DO:
                   FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                      craplot.dtmvtolt = glb_dtmvtolt   AND
                                      craplot.cdagenci = aux_cdagenci   AND
                                      craplot.cdbccxlt = aux_cdbccxlt   AND
                                      craplot.nrdolote = aux_nrdolote
                                      USE-INDEX craplot1 NO-LOCK NO-ERROR.

                   IF   NOT AVAILABLE craplot   THEN
                        IF   aux_nrdolote > 0   THEN
                             DO:
                                 glb_cdcritic = 60.
                                 RUN fontes/critic.p.
                                 UNIX SILENT VALUE("echo " + 
                                            STRING(TIME,"HH:MM:SS") +
                                            " - " + glb_cdprogra + "' --> '" +
                                            glb_dscritic + " COMPBB - LOTE = " +
                                            STRING(aux_nrdolote,"999,999") +
                                            " >> " + aux_nmarqlog).
                                 RETURN.
                             END.
               END.
          ELSE
               aux_nrdolote = 0.
               
          ASSIGN aux_flgerros = FALSE
                 aux_nmarqimp = "rl/crrl429_" + STRING(TIME,"99999") + ".lst"
                   
                 tot_contareg = 0
                 tot_vllanmto = 0.
                  
          OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

          VIEW STREAM str_1 FRAME f_cabrel132_1.

          /*  Leitura dos lancamentos Integrados  */
           
          ASSIGN tot_contareg = 0
                 tot_vllanmto = 0.
          
          VIEW STREAM str_1 FRAME f_labelace.
          
          FOR EACH crawlcm:
            
              DISPLAY STREAM str_1  crawlcm.cdagenci   crawlcm.nrdconta
                                    crawlcm.nmprimtl   crawlcm.nrdctabb
                                    crawlcm.nrdocmto   crawlcm.dshistor
                                    crawlcm.cdpesqbb   crawlcm.vllanmto   
                                    WITH FRAME f_aceitos.

              DOWN STREAM str_1 WITH FRAME f_aceitos.

              ASSIGN tot_contareg = tot_contareg + 1
                     tot_vllanmto = tot_vllanmto + crawlcm.vllanmto.
              
              IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                   DO:
                       PAGE STREAM str_1.
                       VIEW STREAM str_1 FRAME f_labelace.
                   END.    
          END.
         
          DISPLAY STREAM str_1 tot_contareg tot_vllanmto 
                         WITH FRAME f_totalint.
            
          /*  Leitura dos lancamentos Rejeitados  */

          ASSIGN tot_contareg = 0.
            
          VIEW STREAM str_1 FRAME f_labelrej.
          
          FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                                 craprej.cdagenci = 668           AND
                                 craprej.dtmvtolt = glb_dtmvtolt  NO-LOCK
                                 BREAK BY craprej.dtmvtolt
                                          BY craprej.nrdctabb
                                              BY craprej.nrdocmto:

              IF   glb_cdcooper = 1       AND
                   craprej.cdcritic = 92  THEN
                   NEXT.
              
              IF   glb_cdcritic <> craprej.cdcritic   THEN
                   DO:
                       ASSIGN aux_flgerros = TRUE
                              glb_cdcritic = craprej.cdcritic.

                       RUN fontes/critic.p.

                       glb_dscritic = SUBSTRING(glb_dscritic,7,50).
                   END.

              DISPLAY STREAM str_1
                      craprej.nrseqdig  craprej.dshistor  craprej.nrdctabb
                      craprej.dtrefere  craprej.nrdocmto  craprej.cdpesqbb
                      craprej.vllanmto  craprej.indebcre  craprej.nrdconta
                      glb_dscritic      WITH FRAME f_rejeitados.

              DOWN STREAM str_1 WITH FRAME f_rejeitados.

              tot_contareg = tot_contareg + 1.
                
              IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                   DO:
                       PAGE STREAM str_1.
                       VIEW STREAM str_1 FRAME f_labelrej.
                   END.

          END.   /*  Fim do FOR EACH  --  Leitura dos rejeitados  */

          IF   LINE-COUNTER(str_1) > 78   THEN
               PAGE STREAM str_1.

          DISPLAY STREAM str_1 tot_contareg WITH FRAME f_totalrej.

          DISPLAY STREAM str_1 WITH FRAME f_visto.

          OUTPUT STREAM str_1 CLOSE.

          /*     copia relatorio para "/rlnsv"    */
          
          UNIX SILENT VALUE("cp " + aux_nmarqimp + " rlnsv/" +
                          SUBSTRING(aux_nmarqimp,R-INDEX(aux_nmarqimp,"/") + 1,
                          LENGTH(aux_nmarqimp) - R-INDEX(aux_nmarqimp,"/"))).

          ASSIGN glb_nrcopias = 1
                 glb_nmformul = "132dm"
                 glb_nmarqimp = aux_nmarqimp.
                       
          RUN fontes/imprim.p.
            
          IF   aux_nrdolote > 0 THEN
               ASSIGN lot_qtcompln = craplot.qtcompln
                      lot_vlcompcr = craplot.vlcompcr.
          ELSE
               ASSIGN lot_qtcompln = 0
                      lot_vlcompcr = 0.

          glb_cdcritic = IF NOT aux_flgerros THEN 190 ELSE 191.

          RUN fontes/critic.p.
          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" +
                            glb_dscritic + "' --> '" +
                            crawarq.nmarquiv + "  '('Qtd: " +
                            STRING(lot_qtcompln,"zzz,zz9") + "  Valor: " +
                            STRING(lot_vlcompcr,"zzz,zzz,zzz,zz9.99") + 
                            "')'" + " >> " + aux_nmarqlog).
     END.
                
RUN fontes/fimprg.p.

/* .......................................................................... */

