DEF VAR glb_cdcooper         AS INT                             NO-UNDO.
DEF VAR glb_dtmvtolt         AS DATE                            NO-UNDO.
DEF VAR glb_dtmvtopr         AS DATE                            NO-UNDO.
DEF VAR glb_dtultdia         AS DATE                            NO-UNDO.
DEF VAR glb_inproces         AS INTE INIT 1                     NO-UNDO.
DEF VAR his_cdhistor         AS INT                             NO-UNDO.
DEF VAR his_nrdolote         AS INT                             NO-UNDO.
DEF VAR his_nrdolote_lcm     AS INT                             NO-UNDO.
DEF VAR his_tplotmov         AS INT                             NO-UNDO.
DEF VAR glb_cdcritic         AS INT                             NO-UNDO.
DEF VAR glb_dscritic         AS CHAR                            NO-UNDO.
DEF VAR aux_flgativo         AS INT                             NO-UNDO.
DEF VAR glb_cdoperad         AS CHAR                            NO-UNDO.
DEF VAR tel_nrdctabb         LIKE crapass.nrdconta              NO-UNDO.
DEF VAR tel_cdagenci         LIKE crapass.cdagenci              NO-UNDO.
DEF VAR tel_cdbccxlt         LIKE crapass.cdagenci              NO-UNDO.
DEF VAR tel_nrdocmto         LIKE crapepr.nrctremp              NO-UNDO.
DEF VAR his_nrctremp         LIKE crapepr.nrctremp              NO-UNDO.
DEF VAR tel_vllanmto         LIKE craplem.vllanmto              NO-UNDO.
DEF VAR h-b1wgen0002         AS HANDLE                          NO-UNDO.
DEF VAR h-b1wgen0043         AS HANDLE                          NO-UNDO.
DEF VAR aux_qtregist         AS INTEGER                         NO-UNDO.
DEF VAR aux_contador         AS INTEGER                         NO-UNDO.

{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdcooper = 1
       glb_dtmvtolt = 07/20/2017 /* Ajustar */
       glb_dtmvtopr = 07/21/2017 /* Ajustar */
       glb_dtultdia = 07/31/2017 
       glb_cdoperad = "1"
       tel_cdagenci = 1
       tel_cdbccxlt = 100.
       
FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                       craptab.nmsistem = "CRED" AND
                       craptab.tptabela = "TESTE" AND
                       craptab.cdacesso = "ESTORNOPGTO":
                                           
          
          /*Busca da tabela de estorno */
         ASSIGN
           tel_nrdctabb = INTEGER(SUBSTRING(craptab.dstextab,1,8)) /* Ajustar CONTA */
           tel_nrdocmto = INTEGER(SUBSTRING(craptab.dstextab,10,8)) /* Ajustar CONTRATO */
           his_nrctremp = INTEGER(SUBSTRING(craptab.dstextab,10,8)) 
           tel_vllanmto = DECIMAL(SUBSTRING(craptab.dstextab,19,8))  /* Ajustar VALOR */
       
       /* Dados do Lancamento */
       his_cdhistor = 88
       his_nrdolote = 10001
       his_tplotmov = 5
       
       /* Dados da Extrato */
       his_nrdolote_lcm = 4501.

{includes/atualiza_epr.i}

/* Validar se todos os contratos podem fazer estornos */
FIND craplem WHERE craplem.cdcooper = glb_cdcooper AND
                   craplem.dtmvtolt = glb_dtmvtolt AND
                   craplem.cdagenci = 1            AND
                   craplem.cdbccxlt = 100          AND
                   craplem.nrdolote = his_nrdolote AND
                   craplem.nrdconta = tel_nrdctabb AND
                   craplem.nrdocmto = tel_nrdocmto
                   NO-LOCK NO-ERROR.
     
IF AVAILABLE craplem THEN
   DO:
       MESSAGE "ESTORNO JAH EFETUADO".
       RETURN "NOK".
   END.

FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                   crapass.nrdconta = tel_nrdctabb
                   NO-LOCK NO-ERROR.
IF NOT AVAILABLE crapass THEN
   DO:
       MESSAGE "ASSOCIADO NAO ENCONTRADO".
       RETURN "NOK".
   END.

INICIO:
DO TRANSACTION:

   /* Verificacao de contrato de acordo */  
   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

   /* Verifica se ha contratos de acordo */
   RUN STORED-PROCEDURE pc_verifica_acordo_ativo
     aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper
                                         ,INPUT tel_nrdctabb
                                         ,INPUT his_nrctremp
                                        /* ,INPUT 3 */
                                         ,OUTPUT 0
                                         ,OUTPUT 0
                                         ,OUTPUT "").

   CLOSE STORED-PROC pc_verifica_acordo_ativo
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

   ASSIGN glb_cdcritic = 0
          glb_dscritic = ""
          glb_cdcritic = INT(pc_verifica_acordo_ativo.pr_cdcritic) WHEN pc_verifica_acordo_ativo.pr_cdcritic <> ?
          glb_dscritic = pc_verifica_acordo_ativo.pr_dscritic WHEN pc_verifica_acordo_ativo.pr_dscritic <> ?
          aux_flgativo = INT(pc_verifica_acordo_ativo.pr_flgativo).
   
   IF glb_cdcritic > 0 THEN
      DO:
          RUN fontes/critic.p.
          MESSAGE glb_dscritic.
          UNDO, RETURN "NOK".
      END.
   ELSE 
   IF glb_dscritic <> ? AND glb_dscritic <> "" THEN
      DO:
          MESSAGE glb_dscritic.
          UNDO, RETURN "NOK".
      END.
     
   IF aux_flgativo = 1 THEN
     DO:
         MESSAGE "Lancamento nao permitido, emprestimo em acordo.".
         UNDO, RETURN "NOK".
     END.
   /* Fim verificacao contrato acordo */   
   
   IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
       RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

   RUN obtem-dados-emprestimos IN h-b1wgen0002
           ( INPUT glb_cdcooper, /** Cooperativa   **/
             INPUT tel_cdagenci, /** Agencia       **/
             INPUT tel_cdbccxlt, /** Caixa         **/
             INPUT glb_cdoperad, /** Operador      **/             INPUT "landpv.p",   /** Nome da tela  **/
             INPUT 1,            /** Origem=Ayllos **/
             INPUT tel_nrdctabb, /** Num. da conta **/
             INPUT 1,            /** Sq.do titular **/
             INPUT glb_dtmvtolt, /** Data de Movto **/
             INPUT glb_dtmvtopr, /** Data de Movto **/
             INPUT ?,            /** Data de Calc. **/
             INPUT his_nrctremp, /** Nr.do Contrato**/
             INPUT "landpvi.p",  /** Tela atual    **/
             INPUT glb_inproces, /** Indic.Process.**/
             INPUT FALSE,        /** Gera log erro **/
             INPUT TRUE,         /** Flag Condic.C.**/
             INPUT 0,                               /** nriniseq      **/
             INPUT 0,                         /** nrregist      **/
            OUTPUT aux_qtregist,
            OUTPUT TABLE tt-erro,
            OUTPUT TABLE tt-dados-epr ).

   IF VALID-HANDLE(h-b1wgen0002) THEN
      DELETE OBJECT h-b1wgen0002.

   IF RETURN-VALUE <> "OK"  THEN
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
          IF AVAILABLE tt-erro  THEN
             ASSIGN glb_dscritic = tt-erro.dscritic.
          ELSE
             ASSIGN glb_dscritic = "Erro no carregamento de emprestimos.".

          MESSAGE glb_dscritic.
          UNDO, RETURN "NOK".
      END.
                            
   FIND FIRST tt-dados-epr NO-LOCK NO-ERROR.
   IF NOT AVAILABLE tt-dados-epr THEN
      DO:
          MESSAGE "Erro no carregamento de emprestimos.".
          UNDO, RETURN "NOK".
      END.                              

   DO aux_contador = 1 TO 10:

      FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper AND
                         crapepr.nrdconta = tel_nrdctabb AND
                         crapepr.nrctremp = his_nrctremp
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF NOT AVAIL crapepr THEN
         IF LOCKED crapepr THEN
            DO:
                glb_cdcritic = 371.
                PAUSE 1 NO-MESSAGE.
                NEXT.
            END.
         ELSE
            DO: 
                MESSAGE 356.
                UNDO, RETURN "NOK".
            END.

      glb_cdcritic = 0.
                  glb_dscritic = "".
      LEAVE.
      
   END.

   IF crapepr.dtmvtolt = glb_dtmvtolt THEN
      DO:
          MESSAGE 934.
          UNDO, RETURN "NOK".
      END.
   
   IF crapepr.qtmesdec > 0 THEN
      RUN p_atualiza_dtdpagto(INPUT TRUE,
                              INPUT tel_vllanmto).
      
   /* Criar Lote para o estorno do emprestimo */
   DO aux_contador = 1 TO 10:

      FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                         craplot.dtmvtolt = glb_dtmvtolt   AND
                         craplot.cdagenci = tel_cdagenci   AND
                         craplot.cdbccxlt = tel_cdbccxlt   AND
                         craplot.nrdolote = his_nrdolote
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF NOT AVAILABLE craplot   THEN
         IF LOCKED craplot  THEN
            DO:
                ASSIGN glb_cdcritic = 84.
                PAUSE 1 NO-MESSAGE.
                NEXT.
            END.
         ELSE
            DO: 
                MESSAGE glb_cdcritic = 60.
                UNDO, RETURN "NOK".
            END.
      ELSE
        ASSIGN glb_cdcritic = 0
                                             glb_dscritic = "".
         
      LEAVE.
      
   END. /** Fim do DO .. TO **/
   
   CREATE craplem.
   ASSIGN craplem.cdcooper = glb_cdcooper
          craplem.dtmvtolt = glb_dtmvtolt
          craplem.cdagenci = 1
          craplem.cdbccxlt = 100
          craplem.nrdolote = his_nrdolote
          craplem.nrdconta = tel_nrdctabb
          craplem.nrdocmto = tel_nrdocmto
          craplem.cdhistor = his_cdhistor
          craplem.nrctremp = his_nrctremp
          craplem.nrseqdig = craplot.nrseqdig + 1
          craplem.vllanmto = tel_vllanmto
          craplem.vlpreemp = crapepr.vlpreemp.
   VALIDATE craplem.   
    
   ASSIGN crapepr.inliquid = 0
          crapepr.dtultpag = glb_dtmvtolt.
   
   RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT SET h-b1wgen0043.

   /* Verifica se tem que ativar/desativar o Rating */
   RUN verifica_contrato_rating IN h-b1wgen0043
                           (INPUT glb_cdcooper,
                            INPUT 0,
                            INPUT 0,
                            INPUT glb_cdoperad,
                            INPUT glb_dtmvtolt,
                            INPUT glb_dtmvtopr,
                            INPUT crapepr.nrdconta,
                            INPUT 90, /* Emprestimo*/
                            INPUT crapepr.nrctremp,
                            INPUT 1,
                            INPUT 1,
                            INPUT "LANDPV",
                            INPUT glb_inproces,
                            INPUT FALSE,
                            OUTPUT TABLE tt-erro).

   DELETE PROCEDURE h-b1wgen0043.

   IF RETURN-VALUE <> "OK"   THEN
      DO:  
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
          IF AVAIL tt-erro   THEN
             MESSAGE tt-erro.dscritic.
          
          MESSAGE tt-erro.dscritic.
          UNDO, RETURN "NOK".
      END.

   ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
          craplot.qtcompln = craplot.qtcompln + 1
          craplot.qtinfoln = craplot.qtinfoln + 1
          craplot.vlcompdb = craplot.vlcompdb + tel_vllanmto
          craplot.vlinfodb = craplot.vlinfodb + tel_vllanmto.
          
          
  /* Andrino */
  /* Criar Lote para o estorno do emprestimo */
  DO aux_contador = 1 TO 10:

     FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                        craplot.dtmvtolt = glb_dtmvtolt   AND
                        craplot.cdagenci = tel_cdagenci   AND
                        craplot.cdbccxlt = tel_cdbccxlt   AND
                        craplot.nrdolote = his_nrdolote_lcm
                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
     IF NOT AVAILABLE craplot   THEN
        IF LOCKED craplot  THEN
           DO:
               ASSIGN glb_cdcritic = 84.
               PAUSE 1 NO-MESSAGE.
               NEXT.
           END.
        ELSE
           DO: 
               MESSAGE glb_cdcritic = 60.
               UNDO, RETURN "NOK".
           END.
     ELSE
       ASSIGN glb_cdcritic = 0
                                     glb_dscritic = "".
        
     LEAVE.
      
  END. /** Fim do DO .. TO **/


  CREATE craplcm.
  ASSIGN craplcm.cdcooper = glb_cdcooper
         craplcm.cdoperad = glb_cdoperad
         craplcm.dtmvtolt = glb_dtmvtolt 
         craplcm.dtrefere = glb_dtmvtolt
         craplcm.cdagenci = tel_cdagenci
         craplcm.cdbccxlt = tel_cdbccxlt 
         craplcm.nrdolote = his_nrdolote_lcm /* andrino */
         craplcm.nrdconta = tel_nrdctabb
         craplcm.nrdctabb = tel_nrdctabb
         craplcm.nrdctitg = crapass.nrdctitg
         craplcm.nrdocmto = tel_nrdocmto
         craplcm.vllanmto = tel_vllanmto 
         craplcm.cdhistor = 317
         craplcm.nrseqdig = craplot.nrseqdig + 1
         craplcm.nrautdoc = 0
         craplcm.cdbanchq = 0
         craplcm.cdagechq = 0
         craplcm.nrctachq = tel_nrdctabb
         craplcm.cdpesqbb = STRING(tel_nrdocmto,"99,999,999").

   ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
          craplot.qtcompln = craplot.qtcompln + 1
          craplot.qtinfoln = craplot.qtinfoln + 1
          craplot.vlcompdb = craplot.vlcompdb + tel_vllanmto
          craplot.vlinfodb = craplot.vlinfodb + tel_vllanmto.

  VALIDATE craplcm.  
END. /*FOR EACH */          
END.