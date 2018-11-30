/*-----------------------------------------------------------------------------

    b1crap39.p - OPERAÇÕES PARA RECEBIMENTO DE TARIFAS
    
    Alteracoes: 
                
------------------------------------------------------------------------------ **/
{dbo/bo-erro1.i}

{ sistema/generico/includes/var_internet.i }

DEF VAR i-cod-erro      AS INTEGER.
DEF VAR c-desc-erro     AS CHAR.
DEF VAR h-b1crap00         AS HANDLE                            NO-UNDO.
DEF VAR in99               AS INTE                              NO-UNDO.
DEF VAR p-literal          AS CHAR                              NO-UNDO.
DEF VAR p-ult-sequencia    AS INTE                              NO-UNDO.
DEF var p-registro         AS RECID                             NO-UNDO.

DEF VAR c-docto-salvo      AS CHAR                              NO-UNDO.
DEF VAR c-desc-debito      AS CHAR                              NO-UNDO.
DEF VAR c-desc-credito     AS CHAR                              NO-UNDO.
DEF VAR i-nro-docto        AS DEC                               NO-UNDO.
DEF VAR c-literal          AS CHAR  FORMAT "x(48)" EXTENT 46.
DEF VAR c-linha1           AS CHAR                              NO-UNDO.
DEF VAR c-linha2           AS CHAR                              NO-UNDO.
DEF VAR c-valor            AS CHAR                              NO-UNDO.
DEF VAR c-nome-operador    AS CHAR                              NO-UNDO.
DEF VAR aux_complemento    AS CHAR                              NO-UNDO.
DEF VAR c-texto-2-via      AS CHAR                              NO-UNDO.


DEF VAR c-cgc-cpf1         AS CHAR   FORMAT "x(19)"             NO-UNDO.
DEF VAR c-cgc-cpf2         AS CHAR   FORMAT "x(19)"             NO-UNDO.
DEF VAR c-nome-titular1    AS CHAR   FORMAT "x(40)"             NO-UNDO.
DEF VAR c-nome-titular2    AS CHAR   FORMAT "x(40)"             NO-UNDO.

PROCEDURE retorna-valor-historico:

    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-cod-histor    AS INTE.
    DEF OUTPUT PARAM p-nrctacrd      AS INTE.
    DEF OUTPUT PARAM p-nrctadeb      AS INTE.
    DEF OUTPUT PARAM p-cdhstctb      AS INTE.
    DEF OUTPUT PARAM p-indcompl      AS INTE.
    DEF OUTPUT PARAM p-ds-histor     AS CHAR.
        
    FIND crapcop WHERE crapcop.nmrescop = p-cooper          NO-LOCK NO-ERROR.

    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper  AND
                       crapage.cdagenci = p-cod-agencia     NO-LOCK NO-ERROR.

    FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper  AND
                       craphis.cdhistor = p-cod-histor      NO-LOCK NO-ERROR.
        
    IF craphis.tpctbcxa = 2 THEN
        ASSIGN  p-nrctadeb = crapage.cdcxaage
                p-nrctacrd = craphis.nrctacrd.
    ELSE
        IF craphis.tpctbcxa = 3 THEN
            ASSIGN  p-nrctacrd = crapage.cdcxaage
                    p-nrctadeb = craphis.nrctadeb.
        ELSE
            ASSIGN  p-nrctacrd = craphis.nrctacrd
                    p-nrctadeb = craphis.nrctadeb.

    ASSIGN  p-cdhstctb  = craphis.cdhstctb
            p-indcompl  = craphis.indcompl
            p-ds-histor = craphis.dshistor.

    RETURN "OK".

END PROCEDURE.

PROCEDURE retorna-tarifa:

    DEF INPUT  PARAM pr_cdcooper    AS INTE     NO-UNDO.
    DEF INPUT  PARAM pr_cdbattar    AS CHAR     NO-UNDO.
    DEF INPUT  PARAM pr_cdprogra    AS CHAR     NO-UNDO.
    
    DEF OUTPUT PARAM out_cdhistor   AS  DECI    NO-UNDO.
    DEF OUTPUT PARAM out_cdhisest   AS  DECI    NO-UNDO.
    DEF OUTPUT PARAM out_vltarifa   AS  DECI    NO-UNDO.
    DEF OUTPUT PARAM out_cdcritic   AS  DECI    NO-UNDO.
    DEF OUTPUT PARAM out_dscritic   AS  CHAR    NO-UNDO.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
    RUN STORED-PROCEDURE pc_carrega_dados_tar_vigen_prg 
      aux_handproc = PROC-HANDLE NO-ERROR (  INPUT pr_cdcooper /* INTEGER */
                                            ,INPUT pr_cdbattar /* VARCHAR2 */
                                            ,INPUT pr_cdprogra /* VARCHAR2 */
                                            ,OUTPUT 0   /* pr_cdhistor  OUT INTEGER */
                                            ,OUTPUT 0   /* pr_cdhisest  OUT NUMBER */
                                            ,OUTPUT 0   /* pr_vltarifa  OUT NUMBER */
                                            ,OUTPUT 0   /* pr_cdcritic  OUT INTEGER */
                                            ,OUTPUT "").  /* pr_dscritic  OUT VARCHAR2 */

    CLOSE STORED-PROC pc_carrega_dados_tar_vigen_prg
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN  out_cdhistor = pc_carrega_dados_tar_vigen_prg.pr_cdhistor
            out_cdhisest = pc_carrega_dados_tar_vigen_prg.pr_cdhisest
            out_vltarifa = pc_carrega_dados_tar_vigen_prg.pr_vltarifa
            out_cdcritic = pc_carrega_dados_tar_vigen_prg.pr_cdcritic
            out_dscritic = pc_carrega_dados_tar_vigen_prg.pr_dscritic.

    IF out_dscritic <> ? THEN
    DO:
        RETURN "NOK".
    END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE grava-cobranca-tarifa:

    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-cod-histor    AS INTE.
    DEF INPUT  PARAM p-cod-operador  AS CHAR.
    DEF INPUT  PARAM p-nro-docto     AS CHAR.
    DEF INPUT  PARAM p-vlr-docto     AS DECI.
    DEF INPUT  PARAM p-conta         AS INTE.
    DEF INPUT  PARAM p_cdbattar      AS CHAR.
    DEF INPUT  PARAM p-debito        AS CHAR.
    DEF INPUT  PARAM p-credito       AS CHAR.
    DEF INPUT  PARAM p-hist-contab   AS CHAR.
    DEF INPUT  PARAM p-dsc-compl1    AS CHAR.
    DEF INPUT  PARAM p-dsc-compl2    AS CHAR.
    DEF INPUT  PARAM p-dsc-compl3    AS CHAR.
     
    
    DEF OUTPUT PARAM p-pg                   AS LOG.
    DEF OUTPUT PARAM p-literal-autentica    AS CHAR.
    DEF OUTPUT PARAM p-ult-sequencia        AS INTE.

    DEF VAR aux_nrseqdig            AS DEC.
                                                       
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND crapcop WHERE crapcop.nmrescop = p-cooper   NO-LOCK NO-ERROR.
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
    
    FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                       craphis.cdhistor = p-cod-histor
                       NO-LOCK NO-ERROR.
    
    IF  craphis.indebcre = "C" THEN
        ASSIGN p-pg = NO.   /* Credito = Recebimento */
    ELSE
        ASSIGN p-pg = YES.  /* Debito = Pagamento */

    ASSIGN i-nro-docto = DEC(p-nro-docto).
    
    ASSIGN in99 = 0.
    DO WHILE TRUE:
    
        FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper     AND
                                crapbcx.dtmvtolt = crapdat.dtmvtocd     AND
                                crapbcx.cdagenci = p-cod-agencia        AND
                                crapbcx.nrdcaixa = p-nro-caixa          AND
                                crapbcx.cdopecxa = p-cod-operador       AND
                                crapbcx.cdsitbcx = 1  
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
        ASSIGN in99 = in99 + 1.
        IF  NOT AVAILABLE crapbcx THEN  
            DO:
                IF  LOCKED crapbcx   THEN  
                    DO:
                        IF  in99 <  100  THEN  
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE 
                            DO:
                                ASSIGN i-cod-erro  = 0
                                       c-desc-erro = "Tabela CRAPBCX em uso ".
                                RUN cria-erro (INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                RETURN "NOK".
                            END.
                    END.
                ELSE 
                    DO:
                        ASSIGN i-cod-erro  = 698
                               c-desc-erro = " ".           
                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.
            END.
        LEAVE.
    END.  /*  DO WHILE */

    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    RUN grava-autenticacao  IN h-b1crap00 (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT p-cod-operador,
                                           INPUT p-vlr-docto,
                                           INPUT DEC(p-nro-docto),
                                           INPUT p-pg, /* YES (PG), NO (REC) */
                                           INPUT "1",  /* On-line           */ 
                                           INPUT NO,    /* Nao estorno        */
                                           INPUT p-cod-histor, 
                                           INPUT ?, /* Data off-line */
                                           INPUT 0, /* Sequencia off-line */
                                           INPUT 0, /* Hora off-line */
                                           INPUT 0, /* Seq.orig.Off-line */
                                           OUTPUT p-literal,
                                           OUTPUT p-ult-sequencia,
                                           OUTPUT p-registro).
    DELETE PROCEDURE h-b1crap00.
    
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
    
    /* Busca a proxima sequencia do campo crapmat.nrseqcar */
    RUN STORED-PROCEDURE pc_sequence_progress
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLOT"
                                        ,INPUT "NRSEQDIG"
                                        ,INPUT STRING(crapcop.cdcooper)
                                        ,INPUT "N"
                                        ,"").
        
    CLOSE STORED-PROC pc_sequence_progress
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                  
    ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
                          WHEN pc_sequence_progress.pr_sequence <> ?.

    CREATE craplcx.
	  ASSIGN craplcx.cdcooper = crapcop.cdcooper
					 craplcx.cdagenci = p-cod-agencia
					 craplcx.nrdcaixa = p-nro-caixa
					 craplcx.cdopecxa = p-cod-operador
					 craplcx.dtmvtolt = crapdat.dtmvtocd
					 craplcx.cdhistor = p-cod-histor					         
					 craplcx.dsdcompl = "Tarifa: " + p_cdbattar + " Agencia: " + STRING(p-cod-agencia,"999") + " Conta/DV: " + STRING(p-conta,"99999999")
					 craplcx.nrdocmto = DEC(p-nro-docto)
					 craplcx.nrseqdig = crapbcx.qtcompln + 1 /*ou aux_nrseqdig*/
                     crapbcx.qtcompln = crapbcx.qtcompln + 1
                     craplcx.vldocmto = p-vlr-docto
                     craplcx.nrdmaqui = crapbcx.nrdmaqui /* p-nro-caixa OR crapbcx.nrdmaqui*/
					 craplcx.nrdconta = p-conta
					 craplcx.nrautdoc = p-ult-sequencia. /*p-ult-sequencia*/

    ASSIGN p-literal-autentica = p-literal.
    
    IF  craphis.indcompl = 1 THEN 
    DO:
  
      /*----- Gera Autenticacao Recebimento   --------*/ 

      IF  p-debito BEGINS "11" THEN
          ASSIGN c-desc-debito = " - CAIXA".
      ELSE
          ASSIGN c-desc-debito = " - ________________________________".
  
      IF  p-credito BEGINS "11" THEN
          ASSIGN c-desc-credito = " - CAIXA".
      ELSE
          ASSIGN c-desc-credito = " - ________________________________".

      ASSIGN c-literal = " ".
      ASSIGN c-literal[1] = TRIM(crapcop.nmrescop) +  " - " + 
                            TRIM(crapcop.nmextcop) 
             c-literal[2] = " "
             c-literal[3] = STRING(crapdat.dtmvtocd,"99/99/99") + " " +
                            STRING(TIME,"HH:MM:SS")     +  " PA " + 
                            STRING(p-cod-agencia,"999") + 
                            "  CAIXA: " +
                            STRING(p-nro-caixa,"Z99") + "/" +
                            SUBSTR(p-cod-operador,1,10)  
             c-literal[4] = " " 
             c-literal[5] = "      ** DOCUMENTO DE CAIXA " + 
                                  STRING(i-nro-docto,"ZZZZZZZZZZ")  + " **" 
             c-literal[6] = " " 

             c-literal[7] = STRING(p-cod-histor,"9999") +
                             " - " + craphis.dshistor              

             c-literal[8]  = " "            
             c-literal[9]  = "DEBITO : " + p-debito +  c-desc-debito
             c-literal[10] = " "      

             c-literal[11] = "CREDITO: " + p-credito + c-desc-credito
             c-literal[12] = " "      

             c-literal[13] = "HST CTL: " + p-hist-contab  
             c-literal[14] = " ".      

      IF  p-dsc-compl1 <> " " THEN
          ASSIGN c-literal[15] = CAPS(p-dsc-compl1).           
      ELSE
          ASSIGN c-literal[15] = " ". 
                    
      IF  p-dsc-compl2 <> " " THEN
          ASSIGN c-literal[16] = CAPS(p-dsc-compl2).        
      ELSE
          ASSIGN c-literal[16] = " ". 

      IF  p-dsc-compl3 <> " " THEN
          ASSIGN c-literal[17] = CAPS(p-dsc-compl3).       
      ELSE
          ASSIGN c-literal[17] = " ". 

      RUN dbo/pcrap12.p (INPUT  p-vlr-docto,
                         INPUT  47,
                         INPUT  47,
                         INPUT  "M",
                         OUTPUT c-linha1,
                         OUTPUT c-linha2).

      ASSIGN c-valor = FILL(" ",14 - 
                       LENGTH(TRIM(STRING(p-vlr-docto,
                                          "zzz,zzz,zz9.99")))) + 
                       "*" + 
                      (TRIM(STRING(p-vlr-docto,"zzz,zzz,zz9.99"))).

      FIND FIRST crapope WHERE crapope.cdcooper = crapcop.cdcooper    AND
                               crapope.cdoperad = p-cod-operador 
                               NO-LOCK NO-ERROR.
                               
      IF  AVAIL crapope THEN
          ASSIGN c-nome-operador = crapope.nmoperad.

      ASSIGN c-literal[20] = " "
             c-literal[21] = "VALOR DE R$    " + c-valor
             c-literal[22] = "(" + TRIM(c-linha1)
             c-literal[23] = TRIM(c-linha2) + ")"
             c-literal[24] = " "
             c-literal[25] = " "          
             c-literal[26] = " "
             c-literal[27] = "ASSINATURAS:"
             c-literal[28] = " "
             c-literal[29] = " "
             c-literal[30] = 
                      "_______________________________________________"
             c-literal[31] = SUBSTR(p-cod-operador,1,10) + " - " +
                             c-nome-operador
             c-literal[32] = " "
             c-literal[33] = " "
             c-literal[34] = " "
             c-literal[35] = 
                      "APROVADO POR: _________________________________" 
             c-literal[36] = " "
             c-literal[37] = p-literal   
             c-literal[38] = " "
             c-literal[39] = " "
             c-literal[40] = " "
             c-literal[41] = " "
             c-literal[42] = " "
             c-literal[43] = " "
             c-literal[44] = " "
             c-literal[45] = " "
             c-literal[46] = " ".

      ASSIGN p-literal-autentica = STRING(c-literal[1],"x(48)")    + 
                                   STRING(c-literal[2],"x(48)")    + 
                                   STRING(c-literal[3],"x(48)")    + 
                                   STRING(c-literal[4],"x(48)")    + 
                                   STRING(c-literal[5],"x(48)")    + 
                                   STRING(c-literal[6],"x(48)")    + 
                                   STRING(c-literal[7],"x(48)")    + 
                                   STRING(c-literal[8],"x(48)")    + 
                                   STRING(c-literal[9],"x(48)")    + 
                                   STRING(c-literal[10],"x(48)")   +   
                                   STRING(c-literal[11],"x(48)")   + 
                                   STRING(c-literal[12],"x(48)")   +
                                   STRING(c-literal[13],"x(48)")   + 
                                   STRING(c-literal[14],"x(48)").    

      IF  c-literal[15] <> " " THEN
          ASSIGN p-literal-autentica = p-literal-autentica +                                              STRING(c-literal[15],"x(48)").

      IF  c-literal[16] <> " " THEN
          ASSIGN p-literal-autentica = p-literal-autentica +                                              STRING(c-literal[16],"x(48)").

      IF  c-literal[17] <> " " THEN
          ASSIGN p-literal-autentica = p-literal-autentica +                                              STRING(c-literal[17],"x(48)").

      IF  c-literal[18] <> " " THEN
          ASSIGN p-literal-autentica = p-literal-autentica +                                              STRING(c-literal[18],"x(48)").
               
      IF  c-literal[19] <> " " THEN
          ASSIGN p-literal-autentica = p-literal-autentica +                                              STRING(c-literal[19],"x(48)"). 

      ASSIGN p-literal-autentica = p-literal-autentica             +
                                   STRING(c-literal[20],"x(48)")   + 
                                   STRING(c-literal[21],"x(48)")   + 
                                   STRING(c-literal[22],"x(48)")   + 
                                   STRING(c-literal[23],"x(48)")   + 
                                   STRING(c-literal[24],"x(48)")   + 
                                   STRING(c-literal[25],"x(48)")   +
                                   STRING(c-literal[26],"x(48)")   + 
                                   STRING(c-literal[27],"x(48)")   + 
                                   STRING(c-literal[28],"x(48)")   + 
                                   STRING(c-literal[29],"x(48)")   + 
                                   STRING(c-literal[30],"x(48)")   + 
                                   STRING(c-literal[31],"x(48)")   + 
                                   STRING(c-literal[32],"x(48)")   + 
                                   STRING(c-literal[33],"x(48)")   + 
                                   STRING(c-literal[34],"x(48)")   +
                                   STRING(c-literal[35],"x(48)")   +
                                   STRING(c-literal[36],"x(48)")   + 
                                   STRING(c-literal[37],"x(48)")   + 
                                   STRING(c-literal[38],"x(48)")   + 
                                   STRING(c-literal[39],"x(48)")   + 
                                   STRING(c-literal[40],"x(48)")   + 
                                   STRING(c-literal[41],"x(48)")   + 
                                   STRING(c-literal[42],"x(48)")   + 
                                   STRING(c-literal[43],"x(48)")   + 
                                   STRING(c-literal[44],"x(48)")   +
                                   STRING(c-literal[45],"x(48)")   + 
                                   STRING(c-literal[46],"x(48)").     

      /*-- 
      ASSIGN c-texto-2-via = p-literal-autentica.

      ASSIGN p-literal-autentica = p-literal-autentica + c-texto-2-via.
      --*/

      ASSIGN in99 = 0. 
      DO  WHILE TRUE:
  
          ASSIGN in99 = in99 + 1.
          FIND FIRST crapaut WHERE RECID(crapaut) = p-registro 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF  NOT AVAIL  crapaut  THEN  
              DO:
                  IF  LOCKED crapaut  THEN 
                      DO:
                          IF  in99 <  100  THEN 
                              DO:
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT.
                              END.
                          ELSE 
                              DO:
                                  ASSIGN i-cod-erro  = 0
                                         c-desc-erro = 
                                              "Tabela CRAPAUT em uso ".
                                  RUN cria-erro (INPUT p-cooper,
                                                 INPUT p-cod-agencia,
                                                 INPUT p-nro-caixa,
                                                 INPUT i-cod-erro,
                                                 INPUT c-desc-erro,
                                                 INPUT YES).
                                  RETURN "NOK".
                              END.
                      END.
              END.
          ELSE 
              DO:
                  ASSIGN  crapaut.dslitera = p-literal-autentica.
                  RELEASE crapaut.
                  LEAVE.
              END.
      END. /* DO  WHILE TRUE */
    END. /*craphis.indcompl = 1*/
    
    RELEASE crapbcx.
    RELEASE craplcx.

    RETURN "OK".

END PROCEDURE.
