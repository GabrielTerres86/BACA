/* ..........................................................................

   Programa: Includes/crps019.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/92.                   Ultima atualizacao: 09/10/2014

   Dados referentes ao programa:

   Frequencia: Sempre que executado o programa crps019.p ou crps076.p.
   Objetivo  : Geracao dos arquivos de microfilmagem.

   Alteracoes: 30/09/94 - Alterado para mostrar a alinea na descricao do histo-
                          rico 47 (Deborah).

               06/10/94 - Alterado para mostrar no codigo de pesquisa do histo-
                          rico 47 a descricao da alinea de devolucao (Odair).

               25/10/94 - Alterado para mostrar no codigo de pesquisa do histo-
                          rico 78 a descricao da alinea de devolucao (Odair).

               03/11/94 - Alterado para comparar tambem o codigo de historico
                          46 (Odair).

               24/01/97 - Tratamento historico 191. (Odair).

               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               29/09/98 - Alterado para NAO tratar o historico 289 (Edson).

               24/06/99 - Tratar historico 338 (Odair).

               23/03/2000 - Tratar arquivos que nao tem lancamentos para funcao
                            transmic (Odair)

               30/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner)

               04/01/2001 - Mostrar o periodo de apuracao do CPMF no lugar do
                            numero do documento. (Eduardo).

               16/01/2001 - Mostrar no extrato de conta corrente as taxas de
                            juros utilizadas & incluir Limite de Credito.
                            (Eduardo).

               27/06/2001 - Gravar dados da 3030 (Margarete).

               13/08/2001 - Acerto no Limite de Credito (Ze Eduardo).

               29/08/2001 - Identificar depositos da cooperativa (Margarete).

               08/10/2001 - Aumentar o campo nrdocmto para 11 histor. 040
                            (Ze Eduardo).

               26/09/2002 - Tratar os historicos 351, 024 e 027 para mostrar
                            o cdpesqbb. (Ze Eduardo).

               07/01/2003 - Mudanca na procura do craptax (Deborah)

               13/03/2003 - Alterado para tratar novos campos craplim (Edson).

               07/04/2003 - Incluir tratamento do histor 399 (Margarete).

               21/05/2003 - Alterado para tratar os historicos 104, 302 e 303
                            (Edson).

               06/08/2003 - Tratamento Historico 156 (Julio).         

               26/09/2003 - ERRO: gravado compe duas vezes e nao gravado
                            agencia do crapchd (Margarete).

               07/10/2005 - Alterado para ler tbm na tabela crapali o codigo
                            da cooperativa (Diego).

               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               27/06/2007 - Acerto na taxas referente ao Lim. Cheque (Ze).

               03/07/2007 - Prever historicos transferencia Internet(Mirtes).

               08/08/2007 - Acerto na taxas - Lim. Cheque (Ze).

               30/10/2008 - Alteracao CDEMPRES (Diego).

               09/09/2009 - Incluir historicos de transferencia de credito de
                            salario (David).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               08/01/2010 - Acrescentar historico 573 no mesmo CAN-DO do 338
                            (Guilherme/Precise)
                            
               19/05/2010 - Acerto no SUBSTRING do campo craplcm.cdpesqbb
                            (Diego).
                            
               24/02/2011 - Ajuste do format do nrdocmto (Henrique)
               
               07/01/2013 - Formatar data de liberacao da crapdpb conforme
                            regra da b1wgen0001.p (David).
                            
               09/10/2014 - Alterada procedure proc_crapchd para tratar deposito
                            intercooperativo. (Reinert)
                            
............................................................................. */

    /*  Verifica se o associado teve lancamentos no mes, caso contrario nao
        imprime o extrato  */

    FIND FIRST craplcm WHERE craplcm.cdcooper  = glb_cdcooper       AND
                             craplcm.nrdconta  = crapass.nrdconta   AND
                             craplcm.dtmvtolt >= aux_dtmvtolt       AND
                             craplcm.dtmvtolt  < aux_dtlimite       AND
                             craplcm.cdhistor <> 289
                             USE-INDEX craplcm2 NO-LOCK NO-ERROR.
        
    IF   NOT AVAILABLE craplcm   THEN
         NEXT.

    ASSIGN aux_regexist = TRUE
           aux_prmchqcc = YES
           aux_cdlcremp = 0
           aux_cdempres = 0.
           
    FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper      AND  
                       crapsld.nrdconta = crapass.nrdconta  NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapsld   THEN
         DO:
             glb_cdcritic = 10.
             RUN fontes/critic.p.
             UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                glb_cdprogra + "' --> '" +
                                glb_dscritic + " >> log/proc_batch.log").
             QUIT.
         END.
      
    /*   Verifica somente o Limite de credito indicado no cabecalho   */

    FIND FIRST craplim WHERE craplim.cdcooper = glb_cdcooper        AND
                             craplim.nrdconta = crapass.nrdconta    AND
                             craplim.tpctrlim = 1                   AND
                             craplim.insitlim = 2
                             NO-LOCK NO-ERROR.

    IF   AVAILABLE craplim  THEN
         ASSIGN aux_cdlcremp = craplim.cddlinha
                aux_salvalim = craplim.vllimite.
    ELSE
         aux_salvalim = 0.  
                       
    /*   Calcula se houve mudancas no limite de credito durante o mes   */
    
    ASSIGN aux_prdiames = DATE(MONTH(glb_dtmvtolt), 01, YEAR(glb_dtmvtolt))
           aux_dsstring = ""
           aux_dslimite = ""
           aux_incremnt = 1
           aux_ahlimite = FALSE.                          
                                           
    FOR EACH craplim WHERE craplim.cdcooper = glb_cdcooper       AND
                           craplim.nrdconta =  crapass.nrdconta  AND
                           craplim.insitlim =  3                 AND
                           craplim.dtfimvig >= aux_dtmvtolt      NO-LOCK
                           BREAK BY craplim.nrdconta
                                    BY craplim.dtfimvig:
            
        IF   NOT aux_ahlimite THEN
             aux_ahlimite = TRUE.
                     
        IF   (aux_dsstring <> "") THEN
             ASSIGN aux_dslimite[aux_incremnt] = aux_dsstring + 
                            STRING(craplim.vllimite,"zz,zzz,zz9.99")
                    aux_incremnt = aux_incremnt + 1
                    aux_dsstring = "".   
        ELSE 
             ASSIGN aux_dslimite[aux_incremnt] = 
                                              "HISTORICO DE LIMITE DE CREDITO"
                    aux_incremnt = aux_incremnt + 1.
            
        aux_dsstring = STRING(craplim.dtfimvig, "99/99/9999") + " DE " + 
                       STRING(craplim.vllimite, "zz,zzz,zz9.99") + " PARA ".
                       
        IF   aux_cdlcremp = 0 THEN
             aux_cdlcremp = craplim.cddlinha.
  
    END.  /*  Fim do FOR EACH  */                                  
    
    IF   aux_ahlimite THEN
         aux_dslimite[aux_incremnt] = aux_dsstring + 
                                      STRING(aux_salvalim, "zz,zzz,zz9.99").
        
    IF   crapass.inpessoa = 1   THEN 
         DO:
             FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper       AND
                                crapttl.nrdconta = crapass.nrdconta   AND
                                crapttl.idseqttl = 1 NO-LOCK NO-ERROR.     
            
             IF   AVAIL crapttl  THEN
                  ASSIGN aux_cdempres = crapttl.cdempres.
         END.
    ELSE
         DO:
             FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                crapjur.nrdconta = crapass.nrdconta
                                NO-LOCK NO-ERROR.
                               
             IF   AVAIL crapjur  THEN
                  ASSIGN aux_cdempres = crapjur.cdempres.
         END.
    
    ASSIGN aux_nrdordem = 0

           reg_cabmex02 = " " +
                          STRING(aux_cdempres,"99999")           + "  "    +
                          STRING(crapass.nrdconta,"z,zzz,zzz,9") + "  "    +
                          STRING(crapass.nmprimtl,"x(36)")       + "   "   +
                          STRING(reg_nmmesref,"x(14)")           + FILL(" ",50)
               
           reg_cabmex03 = "LIMITE CREDITO: " + 
                          STRING(aux_salvalim,"zz,zzz,zz9.99") + "   " +
                          "SALDO ANTERIOR: " +
                          STRING(crapsld.vlsdextr,"zzz,zzz,zzz,zz9.99-") +
                          FILL(" ",33)
                 
           reg_cabmex05 = FILL(" ",32) + "   SALDO ATUAL: " +
                          STRING(crapsld.vlsdmesa,"zzz,zzz,zzz,zz9.99-") +
                          FILL(" ",33).

    IF   aux_flgfirst   THEN
         ASSIGN aux_flgfirst = FALSE
                mex_indsalto = "+".
    ELSE
         IF   aux_contlinh > 77   THEN
              ASSIGN mex_indsalto = "1"
                     aux_contlinh = 0.
         ELSE
              ASSIGN mex_indsalto = "0"
                     aux_contlinh = aux_contlinh + 1.

    { includes/crps019_1.i }    /*  Imprime cabecalho 1 (reg_cabmex01) */

    { includes/crps019_2.i }    /*  Imprime cabecalho 2 (reg_cabmex02) */

    { includes/crps019_3.i }    /*  Imprime cabecalho 3 (reg_cabmex03) */

    { includes/crps019_4.i }    /*  Imprime cabecalho 4 (reg_cabmex04) */

    aux_contlinh = aux_contlinh + 5.

    RELEASE crapsld.

    FOR EACH craplcm WHERE craplcm.cdcooper  = glb_cdcooper      AND
                           craplcm.nrdconta  = crapass.nrdconta  AND
                           craplcm.dtmvtolt >= aux_dtmvtolt      AND
                           craplcm.dtmvtolt  < aux_dtlimite      AND
                           craplcm.cdhistor <> 289
                           USE-INDEX craplcm2 NO-LOCK
                           BREAK BY craplcm.nrdconta:

        FIND tt-craphis WHERE
             tt-craphis.cdhistor = craplcm.cdhistor
             NO-LOCK NO-ERROR.
        
        IF   CAN-DO("375,376,377,537,538,539,771,772",
                    STRING(craplcm.cdhistor))   THEN
             aux_nrdocmto = STRING(INT(SUBSTRING(craplcm.cdpesqbb,45,8)),
                                       "zzzzz,zzz,9").
        ELSE 
        IF   CAN-DO("104,302,303",STRING(craplcm.cdhistor))   THEN
             DO:
                 IF   INT(craplcm.cdpesqbb) > 0   THEN
                      aux_nrdocmto = STRING(INT(craplcm.cdpesqbb),
                                                "zzzzz,zzz,9").
                 ELSE
                      aux_nrdocmto = STRING(craplcm.nrdocmto,"zzz,zzz,zz9").   
             END.
        ELSE     
              DO:
                 IF   craplcm.cdhistor = 100 THEN
                      DO:
                          IF   craplcm.cdpesqbb <> "" THEN
                               aux_nrdocmto = craplcm.cdpesqbb.
                          ELSE 
                               aux_nrdocmto = STRING(craplcm.nrdocmto,
                                                     "zzzzzzz,zz9").
                      END.
                 ELSE 
                      DO:
                          IF CAN-DO(aux_lshistor,STRING(craplcm.cdhistor)) THEN
                               aux_nrdocmto = STRING(craplcm.nrdocmto,
                                                     "zzzzz,zz9,9").
                          ELSE
                               IF  LENGTH(STRING(craplcm.nrdocmto))  < 10 THEN
                                   aux_nrdocmto = STRING(craplcm.nrdocmto,
                                                         "zzzzzzz,zz9").
                               ELSE
                                   aux_nrdocmto = 
                                                 SUBSTR(STRING(craplcm.nrdocmto,
                                                       "zzzzzzzzzzzzzzzzzz9"),
                                                        4,11).
                      END.
             END.
             
        ASSIGN reg_ddmvtolt = SUBSTRING(STRING(craplcm.dtmvtolt),1,2)
               reg_dshistor = IF CAN-DO("24,27,47,78,156,191,338,351,399,573",
                                    STRING(craplcm.cdhistor)) THEN
                                 STRING(tt-craphis.dshistor
                                        + craplcm.cdpesqbb,"x(21)") ELSE
                                 STRING(tt-craphis.dshistor,"x(21)")
               reg_nrdocmto = aux_nrdocmto
               reg_vllanmto = STRING(craplcm.vllanmto,"zzzz,zzz,zz9.99")
               reg_cdagenci = STRING(craplcm.cdagenci,"zz9")
               reg_cdbccxlt = STRING(craplcm.cdbccxlt,"zz9")
               reg_nrdolote = STRING(craplcm.nrdolote,"zzzzz9")
               reg_indebcre = STRING(tt-craphis.indebcre,"x").

        IF   CAN-DO("24,27,47,78,156,191,338,351,399,573",STRING(craplcm.cdhistor))
                                                AND craplcm.cdpesqbb <> "" THEN
             DO:
                 FIND crapali WHERE crapali.cdalinea = INT(craplcm.cdpesqbb)
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE crapali THEN
                      reg_cdpesqbb = "ALINEA " + craplcm.cdpesqbb.
                 ELSE
                      reg_cdpesqbb = CAPS(crapali.dsalinea).
             END.
        ELSE
             IF   CAN-DO("358,340,313,314,319,339,345",
                          STRING(craplcm.cdhistor))     THEN               
                  reg_cdpesqbb = STRING(craplcm.cdbanchq,"999")     + "-" + 
                                 STRING(craplcm.cdagechq,"9999")    + "-" +
                                 STRING(craplcm.cdcmpchq,"999")     + "-" +
                                 STRING(craplcm.nrlotchq,"9999999") + "-" + 
                                 STRING(craplcm.sqlotchq,"999999")  + "-" + 
                                 STRING(craplcm.nrctachq).
             ELSE
                  reg_cdpesqbb = craplcm.cdpesqbb.
        
        IF   tt-craphis.inhistor >= 3   AND
             tt-craphis.inhistor <= 5   THEN
             DO:
                 FIND crapdpb WHERE crapdpb.cdcooper = glb_cdcooper      AND
                                    crapdpb.dtmvtolt = craplcm.dtmvtolt  AND
                                    crapdpb.cdagenci = craplcm.cdagenci  AND
                                    crapdpb.cdbccxlt = craplcm.cdbccxlt  AND
                                    crapdpb.nrdolote = craplcm.nrdolote  AND
                                    crapdpb.nrdconta = craplcm.nrdconta  AND
                                    crapdpb.nrdocmto = craplcm.nrdocmto
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE crapdpb   THEN
                      reg_dtliblan = "**/**".
                 ELSE
                 IF   crapdpb.inlibera = 1   THEN 
                      reg_dtliblan = SUBSTRING(STRING(crapdpb.dtliblan,
                                                      "99/99/99"),1,5).
                 ELSE
                      reg_dtliblan = "Estor".
             END.
        ELSE
             reg_dtliblan = "     ".
        
        /*   Encontra data em que foi gerado o craptax */
 
        FIND LAST craptax WHERE craptax.cdcooper = glb_cdcooper  AND
                                craptax.dtmvtolt < glb_dtmvtolt  AND 
                                craptax.tpdetaxa = 2             
                                NO-LOCK NO-ERROR.

        IF   AVAILABLE craptax THEN
             aux_uldiames = craptax.dtmvtolt.
        ELSE
             DO:
        
                 /*   Calcula o ultimo dia util do mes para o craptax   */
 
                 aux_uldiames = glb_dtmvtolt - DAY(glb_dtmvtolt).
    
                 DO WHILE TRUE:
      
                    IF   CAN-DO("1,7",STRING(WEEKDAY(aux_uldiames)))    OR
                         CAN-FIND(crapfer WHERE
                                  crapfer.cdcooper = glb_cdcooper       AND
                                  crapfer.dtferiad = aux_uldiames)      THEN
                         DO:
                             aux_uldiames = aux_uldiames - 1.
                             NEXT.
                         END.
     
                   LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */
             END.
             
        /*  Verifica as taxas de juros  */
        
        ASSIGN reg_dstptaxa = ""
               aux_tpdetaxa = 0.
        
        IF   CAN-DO("38,57,37",STRING(craplcm.cdhistor))   THEN
             DO: 
                 aux_tpdetaxa =  IF   craplcm.cdhistor = 38 
                                      THEN 2
                                 ELSE 
                                      IF   craplcm.cdhistor = 57 
                                           THEN 3
                                      ELSE 4.
                       
                 /*   Juros do Cheque Especial  */

                 IF   aux_tpdetaxa = 2 THEN 
                      FIND craptax WHERE craptax.cdcooper = glb_cdcooper  AND
                                         craptax.cdlcremp = aux_cdlcremp  AND
                                         craptax.tpdetaxa = aux_tpdetaxa  AND
                                         craptax.dtmvtolt = aux_uldiames  
                                         NO-LOCK NO-ERROR.
                 ELSE
                      FIND craptax WHERE craptax.cdcooper = glb_cdcooper  AND
                                         craptax.cdlcremp = 0             AND
                                         craptax.tpdetaxa = aux_tpdetaxa  AND
                                         craptax.dtmvtolt = aux_uldiames  
                                         NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE craptax   THEN
                      DO:
                          glb_cdcritic = 347.
                          RUN fontes/critic.p. 
                          UNIX SILENT VALUE ("echo " +  STRING(TIME,"HH:MM:SS") 
                                             + " - " + glb_cdprogra +
                                             "' --> '" + glb_dscritic +
                                             " >> log/proc_batch.log").
                          reg_dstptaxa = "".
                      END.
                 ELSE
                      reg_dstptaxa = STRING(craptax.txmensal,"zz9.999999") 
                                     + "%a.m".
             END.  /*  Fim do IF CAN-DO  */
                       
         ASSIGN reg_lindetal = " " +
                        STRING(reg_ddmvtolt,"x(02)") + " " +
                        STRING(reg_dshistor,"x(18)") + " "  +
                        STRING(reg_nrdocmto,"x(11)") + " "  +
                        STRING(reg_dtliblan,"x(05)") + " "  +
                        STRING(reg_vllanmto,"x(15)") + "  " +
                        STRING(reg_indebcre,"x(01)") + "  " +
                        STRING(reg_cdagenci,"x(03)") + " "   +
                        STRING(reg_cdbccxlt,"x(03)") + " "   +
                        STRING(reg_nrdolote,"x(06)") + " "  +
                        STRING(reg_cdpesqbb,"x(41)") + " "  +
                        STRING(reg_dstptaxa,"x(14)").

        IF   aux_contlinh = 84   THEN
             IF   LAST-OF(craplcm.nrdconta)   THEN
                  DO:
                      mex_indsalto = "1".
                      { includes/crps019_1.i }     /* cabecalho 1    */
                      { includes/crps019_2.i }     /* cabecalho 2    */
                      { includes/crps019_4.i }     /* cabecalho 4    */
                      { includes/crps019_7.i }     /* linha detalhe  */
                      { includes/crps019_5.i }     /* cabecalho 5    */
                      { includes/crps019_8.i }     /* limite credito */ 
                      
                      aux_contlinh = aux_incremnt + 6.
                      RUN proc_crapchd.
                      
                      { includes/crps019_6.i }     /* cabecalho 6    */
                      aux_contlinh = aux_contlinh + 2. /*1*/
                      RELEASE craplcm.
                      LEAVE.
                  END.
             ELSE
                  DO:
                      mex_indsalto = "1".
                      { includes/crps019_1.i }     /* cabecalho 1   */
                      { includes/crps019_2.i }     /* cabecalho 2   */
                      { includes/crps019_4.i }     /* cabecalho 4   */
                      { includes/crps019_7.i }     /* linha detalhe */
                      aux_contlinh = 5.
                  END.
        ELSE
             IF   LAST-OF(craplcm.nrdconta)   THEN
                  DO:
                      { includes/crps019_7.i }             /* linha detalhe */
                      aux_contlinh = aux_contlinh + 1.
                      IF   aux_contlinh = 84   THEN
                           DO:
                               mex_indsalto = "1".
                               { includes/crps019_1.i }    /* cabecalho 1    */
                               { includes/crps019_2.i }    /* cabecalho 2    */
                               { includes/crps019_5.i }    /* cabecalho 5    */
                               { includes/crps019_8.i }    /* limite credito */
                               
                               aux_contlinh = aux_incremnt + 3.
                               RUN proc_crapchd.

                               { includes/crps019_6.i } /* cabecalho 6 */ 
                               aux_contlinh = aux_contlinh + 2. /*1*/
                               RELEASE craplcm.
                               LEAVE.
                           END.

                      { includes/crps019_5.i }             /* cabecalho 5    */
                      aux_contlinh = aux_contlinh + 1.
                      IF   aux_contlinh > 82   THEN
                           DO:
                               RUN proc_crapchd.
                               RELEASE craplcm.
                               LEAVE.
                           END.
         
                      ASSIGN aux_incremnt = 1              /* limite credito */
                             mex_indsalto = " ".
                                            
                      DO WHILE  aux_dslimite[aux_incremnt] <> "":  
   
                         ASSIGN mex_registro = mex_indsalto + 
                                    STRING(aux_dslimite[aux_incremnt],"x(132)")
                                aux_incremnt = aux_incremnt + 1.
                                   
                         PUT STREAM str_1 mex_registro SKIP.

                         IF   aux_contlinh = 84  THEN
                              ASSIGN mex_indsalto = "1"
                                     aux_contlinh = 1.
                         ELSE     
                              ASSIGN aux_contlinh = aux_contlinh + 1
                                     mex_indsalto = " ". 
                      END.
                                                          
                      IF   aux_contlinh > 82   THEN
                           DO:
                               RUN proc_crapchd.
                               RELEASE craplcm.
                               LEAVE.
                           END.
                          
                      aux_contlinh = aux_contlinh + 1.
                      RUN proc_crapchd.
                      
                      { includes/crps019_6.i }             /* cabecalho 6    */
                      aux_contlinh = aux_contlinh + 1.
                      RELEASE craplcm.
                      LEAVE.
                  END.
             ELSE
                  DO:
                      { includes/crps019_7.i }             /* linha detalhe  */
                      aux_contlinh = aux_contlinh + 1.
                  END.

        RELEASE craplcm.

    END.   /*  Fim do FOR EACH da pesquisa dos lancamentos  */

    RELEASE crapass.

PROCEDURE proc_crapchd:

    DEF VAR aux_datarefe AS DATE                                NO-UNDO.

    FOR FIRST crapcop FIELDS(cdagectl)
                      WHERE crapcop.cdcooper = glb_cdcooper
                      NO-LOCK:
    END.

    DO aux_datarefe = aux_dtmvtolt TO aux_dtlimite - 1:

        FOR EACH crapchd WHERE crapchd.cdcooper  = glb_cdcooper      AND
                               crapchd.nrdconta  = crapass.nrdconta  AND
                               crapchd.dtmvtolt  = aux_dtrefere      AND
                               crapchd.cdagedst  =  0 /* Intercooperativa */
                               USE-INDEX crapchd2   OR
                               NO-LOCK
                               BREAK BY crapchd.dtmvtolt:
    
            IF   aux_prmchqcc   THEN 
                 DO:
                    IF   aux_contlinh > 81    THEN
                         DO:
                             ASSIGN mex_indsalto = "1".
                             { includes/crps019_1.i } /* cabecalho 1 */
                             { includes/crps019_2.i } /* cabecalho 2 */
                             ASSIGN aux_contlinh = 2.               
                         END.
                         
                    { includes/crps019_9.i  } /* cabecalho  9 */
                    { includes/crps019_10.i } /* cabecalho 10 */
                    
                    ASSIGN aux_prmchqcc = NO
                           aux_contlinh = aux_contlinh + 2.
                 END.        
            
            ASSIGN reg_lindetal = 
                                                                     " " +
                       STRING(DAY(crapchd.dtmvtolt),"99")          + " " +  
                       STRING(crapchd.cdbanchq,"999")              + " " +
                       STRING(crapchd.cdagechq,"9999")             + " " +
                       STRING(crapchd.cdcmpchq,"999")              + " " +
                       STRING(crapchd.nrctachq,"zz,zzz,zzz,zzz,z") + " " +
                       STRING(crapchd.nrcheque,"zzz,zz9")          + " " +
                       STRING(crapchd.cdtipchq,"9")                + "  " +
                       STRING(crapchd.nrddigc1,"9")                + "  " +
                       STRING(crapchd.nrddigc2,"9")                + "  " +
                       STRING(crapchd.nrddigc3,"9")                + "  " +
                       STRING(crapchd.nrddigv1,"9")                + "  " +
                       STRING(crapchd.nrddigv2,"9")                + "  " +
                       STRING(crapchd.nrddigv3,"9")                + " " +
                       STRING(crapchd.vlcheque,"zzz,zzz,zz9.99")   + " " +
                       crapchd.dsdocmc7.    
                                                           
            IF   aux_contlinh = 84    THEN
                 DO:
                     ASSIGN mex_indsalto = "1".
                     { includes/crps019_1.i  } /* cabecalho 1 */
                     { includes/crps019_2.i  } /* cabecalho 2 */
                     { includes/crps019_9.i  } /* cabecalho  9 */
                     { includes/crps019_10.i } /* cabecalho 10 */
                    
                    ASSIGN aux_contlinh = 4.
    
                 END.         
    
            { includes/crps019_7.i } /* linha detalhe */
            ASSIGN aux_contlinh = aux_contlinh + 1.
                       
        END.                             
    
        FOR EACH crapchd WHERE crapchd.cdagedst  = crapcop.cdagectl  AND
                               crapchd.nrctadst  = crapass.nrdconta  AND
                               crapchd.dtmvtolt  = aux_dtrefere
                               USE-INDEX crapchd5 NO-LOCK
                               BREAK BY crapchd.dtmvtolt:
        
            IF   aux_prmchqcc   THEN 
                 DO:
                    IF   aux_contlinh > 81    THEN
                         DO:
                             ASSIGN mex_indsalto = "1".
                             { includes/crps019_1.i } /* cabecalho 1 */
                             { includes/crps019_2.i } /* cabecalho 2 */
                             ASSIGN aux_contlinh = 2.               
                         END.
        
                    { includes/crps019_9.i  } /* cabecalho  9 */
                    { includes/crps019_10.i } /* cabecalho 10 */
        
                    ASSIGN aux_prmchqcc = NO
                           aux_contlinh = aux_contlinh + 2.
                 END.        
        
            ASSIGN reg_lindetal = 
                                                                     " " +
                       STRING(DAY(crapchd.dtmvtolt),"99")          + " " +  
                       STRING(crapchd.cdbanchq,"999")              + " " +
                       STRING(crapchd.cdagechq,"9999")             + " " +
                       STRING(crapchd.cdcmpchq,"999")              + " " +
                       STRING(crapchd.nrctachq,"zz,zzz,zzz,zzz,z") + " " +
                       STRING(crapchd.nrcheque,"zzz,zz9")          + " " +
                       STRING(crapchd.cdtipchq,"9")                + "  " +
                       STRING(crapchd.nrddigc1,"9")                + "  " +
                       STRING(crapchd.nrddigc2,"9")                + "  " +
                       STRING(crapchd.nrddigc3,"9")                + "  " +
                       STRING(crapchd.nrddigv1,"9")                + "  " +
                       STRING(crapchd.nrddigv2,"9")                + "  " +
                       STRING(crapchd.nrddigv3,"9")                + " " +
                       STRING(crapchd.vlcheque,"zzz,zzz,zz9.99")   + " " +
                       crapchd.dsdocmc7.    
        
            IF   aux_contlinh = 84    THEN
                 DO:
                     ASSIGN mex_indsalto = "1".
                     { includes/crps019_1.i  } /* cabecalho 1 */
                     { includes/crps019_2.i  } /* cabecalho 2 */
                     { includes/crps019_9.i  } /* cabecalho  9 */
                     { includes/crps019_10.i } /* cabecalho 10 */
        
                    ASSIGN aux_contlinh = 4.
        
                 END.         
        
            { includes/crps019_7.i } /* linha detalhe */
            ASSIGN aux_contlinh = aux_contlinh + 1.
        
        END.                 
    END.

END PROCEDURE.

/* .......................................................................... */

