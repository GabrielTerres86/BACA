/*--------------------------------------------------------------------

    b2crap13.p - Consulta  Boletim Caixa
    
    Ultima Atualizacao: 10/01/2017
    
    Alteracoes: 02/03/2006 - Unificacao dos bancos - SQLWorks - Eder
    
                13/12/2006 - Considerar tplotmov = 32 e historico 561 (Evandro)
                
                10/05/2007 - Impressao do Coban para a Creditextil (Magui).    

                29/08/2007 - Histor 561 nao somava no total de creditos(Magui).

                04/03/2008 - Incluidos lancamentos INSS-BANCOOB (Evandro).
                
                31/03/2008 - Incluidos lancamentos guias GPS-BANCOOB (Evandro).

                22/12/2008 - Ajustes para unificacao dos bancos de dados
                             (Evandro).
                             
                16/02/2009 - Alteracao cdempres (Diego).

                05/06/2009 - Incluir cdagenci na leitura do craplcs (Magui).
                
                15/07/2009 - Alteracao CDOPERAD (Diego).
                
                23/11/2009 - Alteracao Codigo Historico (Kbase).
                
                20/10/2010 - Incluido caminho completo nas referencias do 
                             diretorio spool (Elton).
                             
                23/05/2011 - Alterada a leitura da tabela craptab para a 
                             tabela crapope (Isara - RKAM).
                             
                30/09/2011 - Alterar diretorio spool para
                             /usr/coop/sistema/siscaixa/web/spool (Fernando).
                
                02/01/2012 - Ocorria erro com str_1 pois dava display com
                             stream fechado(Tiago).             
                             
                05/06/2013 - Incluido os valores de juros e multa na 
                             contabilizacao de faturas (Elton).
                             
                25/09/2013 - Aumentado o format de aux_qtrttctb, de "z,zz9"
                             para "zz,zz9" (Carlos).
                             
                08/01/2014 - Critica de busca de crapage alterada de 15
                             para 962 (Carlos)

                05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).

                04/11/2015 - Projeto GPS - Adequacao das consultas
                             (Guilherme/SUPERO)

                26/11/2015 - Correcao do cálculo da fita de caixa 
                            (Guilherme/SUPERO)
                            
                27/06/2016 - P290 -> Incluido identificador de CARTAO ou BOLETO para operações de saque, TED, DOC e transferência.
                             (Gil/Rkam)           

                06/10/2016 - SD 489677 - Inclusao do flgativo na CRAPLGP
                             (Guilherme/SUPERO)

                17/10/2016 - #495989 Correção do erro "tentativa de gravar 
                             no fluxo fechado str_1" (Carlos)
                             
                10/01/2017 - #587076 correções de formats para o boletim de caixa (Carlos)
 --------------------------------------------------------------------*/
{dbo/bo-erro1.i}

DEF VAR i-cod-erro   AS INTE.
DEF VAR c-desc-erro  AS CHAR.
DEF VAR c-hist       AS CHAR    FORMAT "X(15)".
DEF VAR c-desc       AS CHAR    FORMAT "X(02)".

DEF VAR aux_nmarqimp AS CHAR                                NO-UNDO.
DEF VAR aux_nrcoluna AS INT                                 NO-UNDO.
DEF VAR r-crapbcx    AS ROWID                               NO-UNDO.

DEF VAR aux_vlrttcrd AS DECI    FORMAT "zzz,zzz,zz9.99-"    NO-UNDO.
DEF VAR aux_vlrttdeb AS DECI    FORMAT "zzz,zzz,zz9.99-"    NO-UNDO.    
DEF VAR aux_vlrttctb AS dec     FORMAT "zzz,zzz,zz9.99-"    NO-UNDO.
DEF VAR aux_qtrttctb AS INT                                 NO-UNDO.
DEF VAR aux_nrctadeb AS INTE    FORMAT "9999"               NO-UNDO.
DEF VAR aux_nrctacrd AS INTE    FORMAT "9999"               NO-UNDO.
DEF VAR aux_descrctb AS CHAR    FORMAT "x(31)"              NO-UNDO.
DEF VAR aux_cdhistor AS INTE    FORMAT "9999"               NO-UNDO.
DEF VAR aux_deschist AS CHAR    FORMAT "x(47)"              NO-UNDO.
DEF VAR aux_vlrtthis AS DECI    FORMAT "zzz,zzz,zz9.99"     NO-UNDO.
DEF VAR aux_deshi717 AS CHAR    FORMAT "X(40)"              NO-UNDO.
DEF VAR aux_vldsdfin LIKE crapbcx.vldsdfin                  NO-UNDO.

DEF VAR aux_vllanchq AS DECIMAL                             NO-UNDO.
DEF VAR aux_qtlanchq AS INT                                 NO-UNDO.

DEF BUFFER crabhis FOR craphis.
DEF STREAM str_1.

DEF VAR rel_dtmvtolt LIKE crapbcx.dtmvtolt                  NO-UNDO.
DEF VAR rel_cdagenci LIKE crapbcx.cdagenci                  NO-UNDO.
DEF VAR rel_cdopecxa LIKE crapbcx.cdopecxa                  NO-UNDO. 
DEF VAR rel_nmoperad LIKE crapope.nmoperad                  NO-UNDO.
DEF VAR rel_nrdcaixa LIKE crapbcx.nrdcaixa                  NO-UNDO. 
DEF VAR rel_nrdmaqui LIKE crapbcx.nrdmaqui                  NO-UNDO.
DEF VAR rel_nrdlacre LIKE crapbcx.nrdlacre                  NO-UNDO.
DEF VAR rel_vldsdini LIKE crapbcx.vldsdini                  NO-UNDO.
DEF VAR rel_qtautent LIKE crapbcx.qtautent                  NO-UNDO.
DEF VAR rel_nmresage AS CHAR                                NO-UNDO.
DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"              NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)"              NO-UNDO.
DEF VAR rel_dsfechad AS CHAR                                NO-UNDO.

DEF VAR aux_nmdafila AS CHAR                                NO-UNDO.
DEF VAR i-nro-vias   AS INTE                                NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                NO-UNDO.

DEF VAR aux_flgsemhi AS LOG                                 NO-UNDO.
DEF VAR aux_flgouthi AS LOG                                 NO-UNDO.
DEF VAR da-data      AS DATE                                NO-UNDO.

DEF VAR aux_dshistor AS CHAR                                NO-UNDO.
DEF VAR tot_qtgerfin AS INT                                 NO-UNDO.
DEF VAR tot_vlgerfin AS DECIMAL                             NO-UNDO.
DEF VAR aux_dsdtraco AS CHAR    INIT "________________"     NO-UNDO.

FORM crapaut.nrsequen COLUMN-LABEL "Aut"
     aux_dshistor     COLUMN-LABEL "Historico" FORMAT "x(23)"
     crapaut.nrdocmto
     crapaut.vldocmto COLUMN-LABEL "Valor" FORMAT "zzzz,zz9.99"
     aux_dsdtraco     COLUMN-LABEL "Nr. Pendencia" FORMAT "x(16)"    
     WITH NO-BOX COLUMN aux_nrcoluna DOWN WIDTH 76 FRAME f_gerfin.
     
FORM HEADER
     SKIP(1)
     FILL("-",76) FORMAT "x(76)" SKIP
     WITH NO-BOX COLUMN aux_nrcoluna DOWN WIDTH 76 FRAME f_fim_estornos.

DEF TEMP-TABLE w-histor
    FIELD cdhistor LIKE craphis.cdhistor
    FIELD dshistor AS CHARACTER FORMAT "x(18)"
    FIELD dsdcompl AS CHARACTER FORMAT "x(50)"
    FIELD qtlanmto AS INTEGER
    FIELD vllanmto AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD qtlanmto-recibo AS INTEGER
    FIELD vllanmto-recibo AS DEC
    FIELD qtlanmto-cartao AS INTEGER
    FIELD vllanmto-cartao AS DEC.
    /*
    INDEX histor1 AS UNIQUE PRIMARY
          cdhistor
          dshistor.
            dsdcompl.  */

DEF TEMP-TABLE work_estorno
    FIELD cdagenci LIKE crapbcx.cdagenci
    FIELD nrdcaixa LIKE crapbcx.nrdcaixa
    FIELD nrseqaut LIKE crapaut.nrseqaut
    INDEX estorno AS UNIQUE PRIMARY
          cdagenci
          nrdcaixa
          nrseqaut.
          
DEF TEMP-TABLE w_empresa                                    NO-UNDO
    FIELD cdempres LIKE crapccs.cdempres
    FIELD qtlanmto AS INT
    FIELD vllanmto LIKE craplcs.vllanmto
    INDEX w_empresa1 cdempres.

FORM HEADER
     "REFERENCIA:" rel_dtmvtolt 
     SKIP(1)
     "PA:" rel_cdagenci FORMAT "ZZ9" "-" rel_nmresage FORMAT "x(13)" SPACE(1)
     "OPERADOR:" rel_cdopecxa FORMAT "x(10)" "-" rel_nmoperad  FORMAT "x(30)"
     SKIP(1)
     "CAIXA:" rel_nrdcaixa FORMAT "ZZ9" "AUTENTICADORA:" AT 16 rel_nrdmaqui
     FORMAT "ZZ9" "QTD. AUT.:" AT 39 rel_qtautent "LACRE:" AT 60 rel_nrdlacre
     SKIP(1)
     "==========================================================================="
     SKIP(1)
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS PAGE-TOP WIDTH 76 FRAME f_cabec_boletim STREAM-IO.


FORM HEADER     
     "SALDO INICIAL" FILL(".",44) FORMAT "x(44)" ":" rel_vldsdini
     SKIP(1)
     "---------------------------------------------------------------------------"
     SKIP
     "***   E N T R A D A S   ***" AT 29 SKIP
     "---------------------------------------------------------------------------"
     SKIP
     "DESCRICAO" AT 1 "CONTABILIDADE   HIST." AT 35 "VALOR R$" AT 67 SKIP
     "---------------------------------------------------------------------------" 
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_inicio_boletim STREAM-IO.

FORM aux_descrctb FORMAT "x(31)"
     " D" 
     aux_nrctadeb FORMAT "9999"
     "- C"
     aux_nrctacrd FORMAT "9999" 
     aux_cdhistor FORMAT "zzzz9"
     "... :"
     aux_vlrttctb FORMAT "zzz,zzz,zz9.99-"
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_ctb_boletim STREAM-IO.

FORM SPACE(2)
     aux_deschist FORMAT "x(41)"
     ":"
     aux_vlrtthis FORMAT "zzz,zzz,zz9.99"
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_his_boletim STREAM-IO.

FORM HEADER
     SKIP(1)
     "TOTAL DE CREDITOS" 
     "........................................" ":"
     aux_vlrttcrd FORMAT "zzz,zzz,zz9.99-"
     SKIP(1)
     "---------------------------------------------------------------------------" SKIP
     "***   S A I D A S   ***" AT 29
     "---------------------------------------------------------------------------" SKIP
     "DESCRICAO" AT 1 "CONTABILIDADE   COD. HIST." AT 26 "VALOR R$" AT 67  SKIP
     "---------------------------------------------------------------------------"
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_saidas_boletim STREAM-IO.

FORM HEADER
     SKIP(1)
     "TOTAL DE DEBITOS"
     FILL(".",41) FORMAT "x(41)" ":"
     aux_vlrttdeb FORMAT "zzz,zzz,zz9.99-"
     SKIP(1)
     "---------------------------------------------------------------------------" SKIP(1)
     "SALDO FINAL" FILL(".",46) FORMAT "x(46)" ":"
     aux_vldsdfin  FORMAT "zzz,zzz,zz9.99-" SKIP(1)
     "==========================================================================="
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_saldo_final STREAM-IO.

FORM HEADER
    SKIP(1)
    "---------------------------------------------------------------------------" SKIP
    "***   E S T O R N O S   ***" AT 29
    "---------------------------------------------------------------------------" SKIP
    SKIP 
    WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_inicio_estorno STREAM-IO.

FORM HEADER
    SKIP(1)
    "---------------------------------------------------------------------------" 
    SKIP(1)
    WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_fim_estorno STREAM-IO.

FORM HEADER
    SKIP(1)
    "--------------------------------------------------------------------------~-" SKIP
    "***   Diferencas Caixa  ***" AT 29
 "---------------------------------------------------------------------------" SKIP
    SKIP 
    WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS 
    WIDTH 76 FRAME f_inicio_diferenca  STREAM-IO.

FORM HEADER
    SKIP(1)
 "---------------------------------------------------------------------------" 
    SKIP(1)
    WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS 
    WIDTH 76 FRAME f_fim_diferenca STREAM-IO.

FORM aux_deshi717
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_descricao_717 STREAM-IO.

FORM SKIP(1)
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_linha_branco STREAM-IO.
     
FORM  "VISTOS: " SPACE(42) 
      rel_dsfechad FORMAT "x(21)" NO-LABEL
      SKIP(4)
      "------------------ ------------------"
      "------------------ "
      SKIP   
      SPACE(7) "OPERADOR" SPACE(8) "RESPONSAVEL" 
      SPACE(8) "CONTABILIDADE"
      WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_vistos STREAM-IO.

FORM 
     crapaut.nrsequen  COLUMN-LABEL "Aut."  
     c-hist            COLUMN-LABEL "Historico"  
     crapaut.nrdocmto  COLUMN-LABEL "Docto"   
     crapaut.vldocmto  COLUMN-LABEL "Valor"  
     c-desc            COLUMN-LABEL "PG/RC"  
     crapaut.nrseqaut  COLUMN-LABEL "Aut.Est"  
     WITH NO-BOX COLUMN aux_nrcoluna DOWN WIDTH 76 FRAME f_estornos STREAM-IO.
        

PROCEDURE disponibiliza-dados-boletim-caixa:
 
    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-operador  AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-rowid         AS ROWID.
    DEF INPUT  PARAM p-nome-arquivo  AS CHAR.
    DEF INPUT  PARAM p-impressao     AS LOG.
    DEF INPUT  PARAM p-programa      AS CHAR.
    DEF OUTPUT PARAM p-valor-credito AS DEC.
    DEF OUTPUT PARAM p-valor-debito  AS DEC.

    DEF VAR aux_vlrtotal             AS DEC. 

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
 
    ASSIGN p-valor-credito = 0
           p-valor-debito  = 0.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    ASSIGN aux_vlrttcrd = 0
           aux_vlrttdeb = 0.

    FIND crapbcx WHERE ROWID(crapbcx) = p-rowid NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapbcx THEN 
        DO:
            ASSIGN i-cod-erro  = 11
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    ASSIGN da-data = crapbcx.dtmvtolt. /* utilizar no lugar de crapdat */

    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper  AND
                       crapage.cdagenci = crapbcx.cdagenci  NO-LOCK NO-ERROR.
         
    IF  NOT AVAIL crapage   THEN 
        DO:
            ASSIGN i-cod-erro  = 962
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper  AND
                       crapope.cdoperad = crapbcx.cdopecxa  NO-LOCK NO-ERROR.
    IF NOT AVAIL crapope THEN 
        DO:
            ASSIGN i-cod-erro  = 67
                   c-desc-erro = " ".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

    IF  p-impressao  = YES  THEN 
        DO: /* Impressora */
            IF crapope.dsimpres = "" THEN
            DO:                          
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = 
                            "Registro de impressora nao encontrado para o Operador".
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK".
            END.
            
            ASSIGN aux_nmdafila = LC(crapope.dsimpres). 
       
            ASSIGN aux_nmarqimp = "/usr/coop/sistema/siscaixa/web/spool/" + 
                                  crapcop.dsdircop      +
                                  STRING(p-cod-agencia) + 
                                  STRING(p-nro-caixa)   + 
                                  "b2013.txt".  /* Nome Fixo  */
        
            ASSIGN p-nome-arquivo  = aux_nmarqimp.
       
        END.
    ELSE 
        DO:
            ASSIGN aux_nmarqimp = p-nome-arquivo.
        END.

    FIND crapemp WHERE crapemp.cdcooper = crapcop.cdcooper  AND
                       crapemp.cdempres = 11                NO-LOCK NO-ERROR.
         
    IF   NOT AVAIL crapemp   THEN
         ASSIGN rel_nmresemp = FILL("?",11).
    ELSE
         ASSIGN rel_nmresemp = SUBSTRING(crapemp.nmresemp,1,11).

    FIND craprel WHERE craprel.cdcooper = crapcop.cdcooper  AND
                       craprel.cdrelato = 258               NO-LOCK NO-ERROR.
         
    IF   NOT AVAILABLE craprel   THEN
         ASSIGN rel_nmrelato    = FILL("?",17).
    ELSE
         ASSIGN rel_nmrelato    = craprel.nmrelato.

    FORM HEADER 
         rel_nmresemp               FORMAT "x(11)"
         "-"
         rel_nmrelato               FORMAT "x(36)"
         "REF P013 "                      
         STRING(TIME,"HH:MM")       FORMAT "x(5)"
         "PAG: "                   
         PAGE-NUMBER(str_1)         FORMAT "zz9"
         SKIP
         WITH PAGE-TOP NO-BOX NO-ATTR-SPACE FRAME f_cabrel080_1 STREAM-IO.
    
    IF  p-impressao = YES  THEN 
        DO:    /* Relatorio */

            ASSIGN aux_nrcoluna = 5.
         
            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
        
            IF LINE-COUNTER > 56 THEN PAGE.

            VIEW   STREAM str_1 FRAME f_cabrel080_1.
   
            /*  Configura a impressora para 1/8"  */
                   
            PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
            PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

        END.
    ELSE 
        DO:  /* Visualiza - Rotina Fechamento */
  
            ASSIGN aux_nrcoluna = 1.

            IF  p-nome-arquivo <> " "  THEN 
                DO:           
                    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) 
                                        PAGED PAGE-SIZE 84. 
             
                END.
        END.

    ASSIGN rel_dtmvtolt = crapbcx.dtmvtolt 
           rel_cdagenci = crapbcx.cdagenci
           rel_nmresage = crapage.nmresage
           rel_cdopecxa = crapbcx.cdopecxa 
           rel_nmoperad = crapope.nmoperad
           rel_nrdcaixa = crapbcx.nrdcaixa
           rel_nrdmaqui = crapbcx.nrdmaqui
           rel_qtautent = crapbcx.qtautent
           rel_nrdlacre = crapbcx.nrdlacre
           rel_vldsdini = crapbcx.vldsdini
           aux_flgsemhi = no.

    IF  p-nome-arquivo <> " "  THEN 
        DO:
            VIEW STREAM str_1 FRAME f_cabec_boletim.
            VIEW STREAM str_1 FRAME f_inicio_boletim.
        END.

        /* Criar indice cdcooper, tplotmov e cdhistor  - Fernando */

    FOR EACH craphis WHERE 
             craphis.cdcooper = crapcop.cdcooper   AND
            (craphis.tplotmov = 22   OR
             craphis.tplotmov = 24   OR
             craphis.tplotmov = 25   OR    
             craphis.tplotmov = 28   OR /* COBAN */
             craphis.tplotmov = 29   OR /* CONTA INVESTIMENTO */
             craphis.tplotmov = 30   OR /* GPS */
             craphis.tplotmov = 31   OR /* Recebimento INSS */
             craphis.tplotmov = 32   OR /* Conta salario */
             craphis.tplotmov = 33   OR /* Receb. INSS-BANCOOB */
            (craphis.tplotmov = 5    AND /* Pagto emprestimo   */
             craphis.cdhistor = 92)  OR
            (craphis.tplotmov = 0    AND /* GPS SICREDI */
             craphis.cdhistor = 1414))
             NO-LOCK
             BREAK BY craphis.indebcre
                   BY craphis.dshistor:     

        ASSIGN aux_flgouthi = NO
               aux_vlrttctb = 0
               aux_qtrttctb = 0
               aux_vllanchq = 0
               aux_qtlanchq = 0.
        
        FOR EACH w-histor:
            DELETE w-histor.    
        END.
       
        IF  craphis.nmestrut = "craplcm"   THEN 
            DO:

                /* Verificar quantidade de leitura - criar indice com nrdcaixa 
                   Verificar baixa de banco para testes com varios caixas abertos */

                FOR EACH craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                                       craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                                       craplot.cdagenci = crapbcx.cdagenci  AND
                                       craplot.cdbccxlt = 11                AND
                                       craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                                       craplot.cdopecxa = crapbcx.cdopecxa  AND
                                       craplot.tplotmov = 1 
                                       NO-LOCK:
                                       
                    /* Verificar situacao utilizando indice craplcm3  - Diego */
                    FOR EACH craplcm WHERE 
                             craplcm.cdcooper = crapcop.cdcooper    AND
                             craplcm.dtmvtolt = craplot.dtmvtolt    AND
                             craplcm.cdagenci = craplot.cdagenci    AND
                             craplcm.cdbccxlt = craplot.cdbccxlt    AND
                             craplcm.nrdolote = craplot.nrdolote
                             USE-INDEX craplcm1 NO-LOCK:

                        /* MODIFICANDO GIL RKAM */
                            { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } /* incluir session oracle */
                            RUN STORED-PROCEDURE pc_busca_tipo_cartao_mvt aux_handproc = PROC-HANDLE NO-ERROR /* Consulta Oracle da tablela tbcrd_log_operacao - retorno tipo de cartao */
                               (INPUT craplcm.cdcooper,
                                INPUT craplcm.nrdconta,
                                INPUT craplcm.nrdocmto,
                                INPUT craplcm.cdhistor,
                                INPUT craplcm.dtmvtolt,
                                OUTPUT pr_tpcartao,
                                OUTPUT pr_dscritic).
                            
                            IF  ERROR-STATUS:ERROR  THEN DO:
                                DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
                                    ASSIGN aux_msgerora = aux_msgerora + 
                                                          ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
                                END.
                                    
                                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                                  " -  caixa on-line b2crap13 ' --> '"  +
                                                  "Erro ao executar Stored Procedure: '" +
                                                  aux_msgerora + " - " + pr_dscritic + "' >> log/proc_batch.log").
                                RETURN.
                            END.
                            
                            CLOSE STORED-PROCEDURE pc_busca_tipo_cartao_mvt WHERE PROC-HANDLE = aux_handproc.
                            { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } /* sair session oracle */
                            
                     
                        RUN  pi-gera-w-histor (INPUT p-cooper,
                                               INPUT craplcm.cdhistor,
                                               INPUT craplcm.vllanmto,
                                               INPUT "",
                                               INPUT pr_tpcartao).
                    END.    
                END.
            END.
        ELSE
        IF  craphis.nmestrut  = "craplem"   AND
            craphis.tplotmov <> 5           THEN 
            DO:
                  /* Verificar quantidade de leitura - criar indice com nrdcaixa 
                   Verificar baixa de banco para testes com varios caixas abertos */
                
                FOR EACH craplot WHERE 
                         craplot.cdcooper = crapcop.cdcooper    AND
                         craplot.dtmvtolt = crapbcx.dtmvtolt    AND
                         craplot.cdagenci = crapbcx.cdagenci    AND
                         craplot.cdbccxlt = 11                  AND
                         craplot.nrdcaixa = crapbcx.nrdcaixa    AND
                         craplot.cdopecxa = crapbcx.cdopecxa    AND
                         craplot.tplotmov = 5                   NO-LOCK:
                          
                    /* Verificar situacao utilizando indice craplem3  - Diego */
                    FOR EACH craplem WHERE
                             craplem.cdcooper = crapcop.cdcooper    AND
                             craplem.dtmvtolt = craplot.dtmvtolt    AND
                             craplem.cdagenci = craplot.cdagenci    AND
                             craplem.cdbccxlt = craplot.cdbccxlt    AND
                             craplem.nrdolote = craplot.nrdolote 
                             USE-INDEX craplem1 NO-LOCK:
                        
                        RUN pi-gera-w-histor (INPUT p-cooper,
                                              INPUT craplem.cdhistor,
                                              INPUT craplem.vllanmto,
                                              INPUT "",
                                              INPUT 9). 
                    END.    
                END.
            END.
        ELSE
        IF  craphis.nmestrut = "crapcbb"    AND
            craphis.tplotmov  = 31          THEN 
            DO:
                RUN gera_crapcbb_INSS. 
            END.
        ELSE    
        IF  craphis.nmestrut = "crapcbb"    THEN 
            DO:
                RUN gera_crapcbb. 
            END.
        ELSE
        IF  craphis.nmestrut = "craplpi"    THEN 
            DO:
                RUN gera_craplpi. 
            END.
        ELSE
        IF  craphis.nmestrut = "craplcs"    THEN 
            DO:
                RUN gera_craplcs.
            END.
        ELSE
        IF  craphis.nmestrut = "craplgp"    THEN 
            DO:

                /* Verifica qual historico deve rodar conforme cadastro da COOP
                   Se tem Credenciamento, deve ser historico 582 senao 458 */
                IF (   (crapcop.cdcrdarr = 0 AND
                        craphis.cdhistor = 458)
                   OR  (crapcop.cdcrdarr <> 0 AND
                        craphis.cdhistor = 582)) THEN DO:

                     RUN gera_craplgp.

                 END.
                 ELSE DO:
                    IF (crapcop.cdcrdins <> 0  AND /* GPS SICREDI NOVO */
                        craphis.cdhistor = 1414) THEN
                        RUN gera_craplgp_gps.
                 END.
            END.
        ELSE
        IF  craphis.nmestrut = "craplem"    THEN 
            DO:
                RUN gera_craplem.
            END.
        ELSE 
        IF  craphis.nmestrut = "craplci"    THEN 
            DO:
                RUN gera_craplci.
            END.
        ELSE
        IF  craphis.nmestrut = "craplft"    THEN 
            DO:

                /*  Verificar com o indice e ajustar os ORs - Diego - OK */
                FOR EACH craplot WHERE (craplot.cdcooper = crapcop.cdcooper  AND
                                        craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                                        craplot.cdagenci = crapbcx.cdagenci  AND
                                        craplot.cdbccxlt = 30                AND
                                        craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                                        craplot.cdopecxa = crapbcx.cdopecxa  AND
                                        craplot.tplotmov = 13)               
                                       OR
                                       (craplot.cdcooper = crapcop.cdcooper  AND
                                        craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                                        craplot.cdagenci = crapbcx.cdagenci  AND
                                        craplot.cdbccxlt = 31                AND
                                        craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                                        craplot.cdopecxa = crapbcx.cdopecxa  AND
                                        craplot.tplotmov = 13)               
                                       OR
                                       (craplot.cdcooper = crapcop.cdcooper  AND
                                        craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                                        craplot.cdagenci = crapbcx.cdagenci  AND
                                        craplot.cdbccxlt = 11                AND
                                        craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                                        craplot.cdopecxa = crapbcx.cdopecxa  AND
                                        craplot.tplotmov = 13)
          /*  FOR EACH craplot WHERE  craplot.cdcooper = crapcop.cdcooper  AND
                                        craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                                        craplot.cdagenci = crapbcx.cdagenci  AND
                                        (craplot.cdbccxlt = 30               OR
                                         craplot.cdbccxlt = 31               OR
                                         craplot.cdbccxlt = 11) AND
                                        craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                                        craplot.cdopecxa = crapbcx.cdopecxa  AND
                                        craplot.tplotmov = 13 */
                                        NO-LOCK:
                                       
                    FOR EACH craplft WHERE 
                             craplft.cdcooper = crapcop.cdcooper    AND
                             craplft.dtmvtolt = craplot.dtmvtolt    AND
                             craplft.cdagenci = craplot.cdagenci    AND
                             craplft.cdbccxlt = craplot.cdbccxlt    AND
                             craplft.nrdolote = craplot.nrdolote
                             USE-INDEX craplft1 NO-LOCK:
                                                          
                        ASSIGN aux_vlrtotal = craplft.vllanmto +
                                              craplft.vlrmulta + 
                                              craplft.vlrjuros.
                        
                        RUN  pi-gera-w-histor (INPUT p-cooper,
                                               INPUT craplft.cdhistor,
                                               INPUT aux_vlrtotal, 
                                               INPUT "",
                                               INPUT 9).
                    END.    
                END.

                FOR EACH craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                                       craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                                       craplot.cdagenci = crapbcx.cdagenci  AND
                                       craplot.cdbccxlt = 11                AND
                                       craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                                       craplot.cdopecxa = crapbcx.cdopecxa  AND
                                       craplot.tplotmov = 21 
                                       NO-LOCK:
                               
                    FOR EACH craptit WHERE 
                             craptit.cdcooper = crapcop.cdcooper    AND
                             craptit.dtmvtolt = craplot.dtmvtolt    AND
                             craptit.cdagenci = craplot.cdagenci    AND
                             craptit.cdbccxlt = craplot.cdbccxlt    AND
                             craptit.nrdolote = craplot.nrdolote
                             USE-INDEX craptit1 NO-LOCK:
                                                              
                        RUN pi-gera-w-histor (INPUT p-cooper,
                                              INPUT 373,
                                              INPUT craptit.vldpagto,
                                              INPUT "",
                                              INPUT 9).    
                    END.    
                END.
            END.
        ELSE
        IF  craphis.nmestrut = "craptit"  AND  
            craphis.cdhistor = 713 THEN
            DO:
                FOR EACH craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                                       craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                                       craplot.cdagenci = crapbcx.cdagenci  AND
                                       craplot.cdbccxlt = 11                AND
                                       craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                                       craplot.cdopecxa = crapbcx.cdopecxa  AND
                                       craplot.tplotmov = 20 
                                       NO-LOCK:
                                       
                    FOR EACH craptit WHERE
                             craptit.cdcooper = crapcop.cdcooper    AND
                             craptit.dtmvtolt = craplot.dtmvtolt    AND
                             craptit.cdagenci = craplot.cdagenci    AND
                             craptit.cdbccxlt = craplot.cdbccxlt    AND
                             craptit.nrdolote = craplot.nrdolote    AND
                             craptit.intitcop = 0   /*  Tit.Outros Bancos */
                             USE-INDEX craptit1 NO-LOCK:
                             
                             ASSIGN aux_vlrttctb = aux_vlrttctb +
                                                       craptit.vldpagto
                                    aux_qtrttctb = aux_qtrttctb + 1.
                    END.    
                END.
            END.
        ELSE

        IF  craphis.nmestrut = "craptit"  AND  
            craphis.cdhistor = 751 THEN       /* Titulo Cooperativa */
            DO:
                FOR EACH craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                                       craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                                       craplot.cdagenci = crapbcx.cdagenci  AND
                                       craplot.cdbccxlt = 11                AND
                                       craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                                       craplot.cdopecxa = crapbcx.cdopecxa  AND
                                       craplot.tplotmov = 20 
                                       NO-LOCK:
                                       
                    FOR EACH craptit WHERE
                             craptit.cdcooper = crapcop.cdcooper    AND
                             craptit.dtmvtolt = craplot.dtmvtolt    AND
                             craptit.cdagenci = craplot.cdagenci    AND
                             craptit.cdbccxlt = craplot.cdbccxlt    AND
                             craptit.nrdolote = craplot.nrdolote    AND
                             craptit.intitcop = 1   /*  Tit.Cooperativa   */
                             USE-INDEX craptit1 NO-LOCK:
                             
                             ASSIGN aux_vlrttctb = aux_vlrttctb +
                                                       craptit.vldpagto
                                    aux_qtrttctb = aux_qtrttctb + 1.
                    END.    
                END.
            END.
        ELSE
 
        IF  craphis.nmestrut = "crapchd"   THEN  
            DO: /*  Cheques capturados  */
                
                /* Ajustar OR cdbccxlt - Diego - OK */
                
                FOR EACH craplot WHERE (craplot.cdcooper = crapcop.cdcooper  AND
                                        craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                                        craplot.cdagenci = crapbcx.cdagenci  AND
                                        craplot.cdbccxlt = 11                AND
                                        craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                                        craplot.cdopecxa = crapbcx.cdopecxa  AND
                                        (craplot.tplotmov = 1                 OR
                                         craplot.tplotmov = 23                OR
                                         craplot.tplotmov = 29))             
                                       OR
                                       (craplot.cdcooper = crapcop.cdcooper  AND
                                        craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                                        craplot.cdagenci = crapbcx.cdagenci  AND
                                        craplot.cdbccxlt = 500               AND
                                        craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                                        craplot.cdopecxa = crapbcx.cdopecxa  AND
                                        (craplot.tplotmov = 1                 OR
                                         craplot.tplotmov = 23                OR
                                         craplot.tplotmov = 29))
          /*  FOR EACH craplot WHERE  craplot.cdcooper = crapcop.cdcooper  AND
                                        craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                                        craplot.cdagenci = crapbcx.cdagenci  AND
                                        (craplot.cdbccxlt = 11               OR
                                         craplot.cdbccxlt = 500)           AND
                                        craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                                        craplot.cdopecxa = crapbcx.cdopecxa  AND
                                        (craplot.tplotmov = 1                 OR
                                         craplot.tplotmov = 23                OR
                                         craplot.tplotmov = 29) */
                                       NO-LOCK:

                                       
                    FOR EACH crapchd WHERE
                             crapchd.cdcooper = crapcop.cdcooper    AND
                             crapchd.dtmvtolt = craplot.dtmvtolt    AND
                             crapchd.cdagenci = craplot.cdagenci    AND
                             crapchd.cdbccxlt = craplot.cdbccxlt    AND
                             crapchd.nrdolote = craplot.nrdolote    AND
                             crapchd.inchqcop = 0
                             USE-INDEX crapchd3 NO-LOCK:
                             
                             /*========*/
                             IF crapchd.cdbccxlt = 500   THEN
                                ASSIGN aux_vllanchq = aux_vllanchq +
                                                          crapchd.vlcheque
                                       aux_qtlanchq = aux_qtlanchq + 1.
                             ELSE
                             /*=========*/
                                ASSIGN aux_vlrttctb = aux_vlrttctb +
                                                          crapchd.vlcheque
                                       aux_qtrttctb = aux_qtrttctb + 1.
                    END.    
                END.
            END.
        ELSE
        IF  craphis.nmestrut = "craplcx"   THEN
            DO:
                /******  Lancamentos extra-sistema *******/ 
                FOR EACH craplcx WHERE craplcx.cdcooper = crapcop.cdcooper  AND
                                       craplcx.dtmvtolt = crapbcx.dtmvtolt  AND
                                       craplcx.cdagenci = crapbcx.cdagenci  AND
                                       craplcx.nrdcaixa = crapbcx.nrdcaixa  AND
                                       craplcx.cdopecxa = crapbcx.cdopecxa 
                                       USE-INDEX craplcx1 NO-LOCK:
                                       
                    IF  craplcx.cdhistor <> craphis.cdhistor THEN NEXT.   
                    
                    IF  craphis.indcompl <> 0   THEN     
                        RUN  pi-gera-w-histor (INPUT p-cooper,
                                               INPUT craplcx.cdhistor,
                                               INPUT craplcx.vldocmto,
                                               INPUT craplcx.dsdcompl,
                                               INPUT 9).
                    ELSE
                        ASSIGN  aux_vlrttctb = aux_vlrttctb
                                                   + craplcx.vldocmto
                                aux_qtrttctb  = aux_qtrttctb + 1.
                END.                   
            END.
        ELSE
        IF  craphis.nmestrut = "craptvl"   THEN
            DO:                
                FOR EACH craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                                       craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                                       craplot.cdagenci = crapbcx.cdagenci  AND
                                       craplot.cdbccxlt = 11                AND
                                       craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                                       craplot.cdopecxa = crapbcx.cdopecxa  AND
                                       craplot.tplotmov = craphis.tplotmov 
                                       NO-LOCK:
 
                    FOR EACH craptvl WHERE 
                             craptvl.cdcooper = crapcop.cdcooper    AND
                             craptvl.dtmvtolt = craplot.dtmvtolt    AND
                             craptvl.cdagenci = craplot.cdagenci    AND
                             craptvl.cdbccxlt = craplot.cdbccxlt    AND
                             craptvl.nrdolote = craplot.nrdolote
                             USE-INDEX craptvl2 NO-LOCK:
                     
                             ASSIGN aux_vlrttctb = aux_vlrttctb + 
                                                       craptvl.vldocrcb
                                    aux_qtrttctb = aux_qtrttctb + 1.

                    END.    
                END.
            END.
        ELSE 
            DO:
                ASSIGN aux_flgsemhi = yes.
            END.
         
        IF  LAST-OF(craphis.dshistor)  AND
               /**** Outros  Tipos de Historicos ******/
            craphis.cdhistor <> 717    AND
            craphis.cdhistor <> 561    AND
           (aux_vlrttctb     <> 0      OR
            aux_vllanchq     <> 0)     THEN 
            DO:
            
                IF  aux_vllanchq <> 0 THEN 
                    DO:
                        IF  craphis.indebcre = "D" THEN
                            aux_vlrttdeb = aux_vlrttdeb + aux_vllanchq.
                        ELSE 
                            aux_vlrttcrd = aux_vlrttcrd + aux_vllanchq.
                    END.
             
                IF  craphis.indebcre = "C"   THEN      
                    ASSIGN aux_vlrttcrd = aux_vlrttcrd + aux_vlrttctb.
                ELSE
                    ASSIGN aux_vlrttdeb = aux_vlrttdeb + aux_vlrttctb.

                IF  craphis.tpctbcxa = 2   THEN       
                    ASSIGN aux_nrctadeb = crapage.cdcxaage
                           aux_nrctacrd = craphis.nrctacrd.
                ELSE
                    IF  craphis.tpctbcxa = 3   THEN
                        ASSIGN aux_nrctacrd = crapage.cdcxaage
                               aux_nrctadeb = craphis.nrctadeb.
                    ELSE
                        ASSIGN aux_nrctacrd = craphis.nrctacrd
                               aux_nrctadeb = craphis.nrctadeb.

                IF  aux_vllanchq > 0   THEN
                    DO:
                        ASSIGN aux_descrctb = TRIM(SUBSTR(craphis.dshistor,
                                                         1,24)) +
                                             "(LANCHQ)".
                        ASSIGN SUBSTR(aux_descrctb,
                                      LENGTH(aux_descrctb) + 2,
                                      (24 - LENGTH(aux_descrctb) - 1)) =
                                             FILL(".",24 - 
                                                  LENGTH(aux_descrctb) - 1)
                               aux_descrctb = SUBSTRING(aux_descrctb,1,24) + 
                                              "(" +
                                              STRING(aux_qtlanchq, "zz,zz9") + 
                                              ")"
                               aux_cdhistor = craphis.cdhstctb.

                        IF  p-nome-arquivo <> " "  THEN 
                            DO:    
                                DISPLAY STREAM str_1
                                        WITH FRAME f_linha_branco.
                                DOWN    STREAM str_1
                                        WITH FRAME f_linha_branco.       

                                DISPLAY STREAM str_1
                                        aux_descrctb aux_nrctadeb aux_nrctacrd 
                                        aux_cdhistor aux_vllanchq @ aux_vlrttctb
                                        WITH FRAME f_ctb_boletim.
                                DOWN  STREAM str_1
                                      WITH FRAME f_ctb_boletim.
                           
                                IF  p-impressao         = YES   AND
                                    LINE-COUNTER(str_1) = 80    THEN
                                    PAGE STREAM str_1.
                                 
                            END.
                    END.
              
                ASSIGN aux_descrctb = TRIM(SUBSTRING(craphis.dshistor,1,24)).
                ASSIGN 
                     SUBSTR(aux_descrctb,length(aux_descrctb) + 2,(24 - 
                                    length(aux_descrctb) - 1)) =
                                         fill(".",24 - length(aux_descrctb) - 1)
                     aux_descrctb = SUBSTRING(aux_descrctb,1,24) + "(" +
                                    STRING(aux_qtrttctb, "zz,zz9") + ")"
                     aux_cdhistor = craphis.cdhstctb.
           
                IF  p-nome-arquivo <> " "  THEN 
                    DO: 
                       
                        DISPLAY STREAM str_1
                                WITH FRAME f_linha_branco.
                        DOWN    STREAM str_1
                                WITH FRAME f_linha_branco.       
             
                        DISPLAY STREAM str_1
                                aux_descrctb aux_nrctadeb aux_nrctacrd 
                                aux_cdhistor aux_vlrttctb
                                WITH FRAME f_ctb_boletim.
                        DOWN    STREAM str_1
                                WITH FRAME f_ctb_boletim.

                        IF  p-impressao         = YES   AND
                            LINE-COUNTER(str_1) = 80    THEN
                            PAGE STREAM str_1.
                        
                    END.
             
                IF  aux_flgouthi   THEN  
                    DO:
                        FOR EACH w-histor NO-LOCK BY w-histor.cdhistor:
                            ASSIGN aux_deschist = ""
                                   aux_vlrtthis = w-histor.vllanmto.

                            IF  craphis.nmestrut <> "craplcx"   THEN DO:
                                   ASSIGN aux_deschist = 
                                   STRING(w-histor.cdhistor,"9999")   + "-" +  
                                   STRING(w-histor.dshistor,"x(18)")  + "(" +
                                   STRING(w-histor.qtlanmto, "zz,zz9") + ")"
                                   SUBSTR(aux_deschist,length(aux_deschist) + 2,
                                   (41 - length(aux_deschist) - 1)) =
                                   FILL(".",41 - length(aux_deschist) - 1).
                                   IF  p-nome-arquivo <> " "  THEN 
                                   DO:
                                    DISPLAY STREAM str_1
                                            aux_deschist aux_vlrtthis 
                                            WITH FRAME f_his_boletim.
                                    DOWN    STREAM str_1
                                            WITH FRAME f_his_boletim.
                                
                                    IF  p-impressao         = YES   AND
                                        LINE-COUNTER(str_1) = 80    THEN
                                        PAGE STREAM str_1.
                                   END.

                                   IF w-histor.qtlanmto-recibo > 0 THEN
                                    DO:
                                        ASSIGN aux_deschist = ""
                                           aux_vlrtthis = w-histor.vllanmto-recibo.
                                        
                                        ASSIGN aux_deschist = 
                                           "   RECIBO              "  + "(" +
                                           STRING(w-histor.qtlanmto-recibo, "zz,zz9") + ")" +
                                           " .........".

                                        IF p-nome-arquivo <> " " THEN
                                        DO:
                                        DISPLAY STREAM str_1
                                            aux_deschist aux_vlrtthis 
                                            WITH FRAME f_his_boletim.
                                            DOWN STREAM str_1 WITH FRAME f_his_boletim.
                                             
                                        IF  w-histor.qtlanmto-recibo > 0   AND
                                            LINE-COUNTER(str_1) = 80 THEN
                                            PAGE STREAM str_1.
                                    END.
                                    END.
                                IF w-histor.qtlanmto-cartao > 0 THEN
                                    DO:
                                        ASSIGN aux_deschist = ""
                                           aux_vlrtthis = w-histor.vllanmto-cartao.
                                        
                                        ASSIGN aux_deschist = 
                                           "   CARTAO              "  + "(" +
                                           STRING(w-histor.qtlanmto-cartao, "zz,zz9") + ") " +
                                           " ........".

                                        IF p-nome-arquivo <> " " THEN
                                        DO:
                                        DISPLAY STREAM str_1
                                            aux_deschist aux_vlrtthis 
                                            WITH FRAME f_his_boletim.
                                            DOWN STREAM str_1 WITH FRAME f_his_boletim.
                                             
                                        IF  w-histor.qtlanmto-cartao > 0   AND
                                                LINE-COUNTER(str_1) = 80 THEN
                                                PAGE STREAM str_1.
                                    END.
                            END.
                            END.
                            ELSE
                            DO:
                            
                                ASSIGN aux_deschist =  
                                   SUBSTR(w-histor.dsdcompl,1,40)
                                   SUBSTR(aux_deschist,length(aux_deschist) + 
                                   2,(44 - length(aux_deschist) - 1)) =
                                   FILL(".",44 - length(aux_deschist) - 1).

                                IF  p-nome-arquivo <> " "  THEN 
                                    DO:
                                        DISPLAY STREAM str_1
                                                aux_deschist aux_vlrtthis 
                                                WITH FRAME f_his_boletim.
                                        DOWN    STREAM str_1
                                                WITH FRAME f_his_boletim.
                                    
                                        IF  p-impressao         = YES   AND
                                            LINE-COUNTER(str_1) = 80    THEN
                                            PAGE STREAM str_1.
                                    END.
                            END.
                        END.  /* for each w-histor */        
                    END. /* IF  aux_flgouthi   THEN */
            END. /* IF  LAST-OF(craphis.dshistor) */
    
        IF  LAST-OF(craphis.dshistor)   AND  /* Hist. 717-arrecadacoes **/
            craphis.cdhistor = 717      AND
           (aux_vlrttctb <> 0           OR
            aux_vllanchq <> 0)          THEN 
            DO:

                IF  p-impressao         = YES   AND
                    LINE-COUNTER(str_1) > 76    THEN
                    PAGE STREAM str_1.
               
                ASSIGN aux_deshi717 = TRIM(craphis.dshistor) + ":".
             
                IF  p-nome-arquivo <> " "  THEN 
                    DO: 

                        DISPLAY STREAM str_1
                                WITH FRAME f_linha_branco.
                        DOWN    STREAM str_1
                                WITH FRAME f_linha_branco.       
             
                        DISPLAY STREAM str_1 
                                aux_deshi717 
                                WITH FRAME f_descricao_717.
                        DOWN    STREAM str_1
                                WITH FRAME f_descricao_717.  
                    END.

                FOR EACH w-histor NO-LOCK 
                       BY w-histor.cdhistor:

                    FIND crabhis WHERE 
                         crabhis.cdcooper = crapcop.cdcooper   AND
                         crabhis.cdhistor = w-histor.cdhistor
                         NO-LOCK NO-ERROR.
                 
                    IF  craphis.indebcre = "C"   THEN      
                        ASSIGN aux_vlrttcrd = aux_vlrttcrd + w-histor.vllanmto.
                    ELSE
                        ASSIGN aux_vlrttdeb = aux_vlrttdeb + w-histor.vllanmto.

                    IF  crabhis.tpctbcxa = 2   THEN       
                        ASSIGN aux_nrctadeb = crapage.cdcxaage
                               aux_nrctacrd = crabhis.nrctacrd.
                    ELSE
                        IF  crabhis.tpctbcxa = 3   THEN
                            ASSIGN aux_nrctacrd = crapage.cdcxaage
                                   aux_nrctadeb = crabhis.nrctadeb.
                        ELSE
                            ASSIGN aux_nrctacrd = crabhis.nrctacrd
                                   aux_nrctadeb = crabhis.nrctadeb.

                    ASSIGN aux_descrctb = ""
                           aux_descrctb = "  " + 
                           STRING(w-histor.cdhistor,"9999") + "-" +  
                           STRING(w-histor.dshistor,"x(18)") + "(" +
                           STRING(w-histor.qtlanmto, "zz,zz9") + ")"
                           aux_cdhistor = crabhis.cdhstctb
                           aux_vlrttctb = w-histor.vllanmto.
           
                    IF  p-nome-arquivo <> " "  THEN 
                        DO:
 
                            DISPLAY STREAM str_1  
                                    aux_descrctb aux_nrctadeb aux_nrctacrd 
                                    aux_cdhistor aux_vlrttctb
                                    WITH FRAME f_ctb_boletim.
                            DOWN    STREAM str_1
                                    WITH FRAME f_ctb_boletim.

                            IF  p-impressao         = YES   AND
                                LINE-COUNTER(str_1) = 80    THEN
                                PAGE STREAM str_1.         
                        END.
                END.  /* for each w-histor */
            END. /* IF  LAST-OF(craphis.dshistor)  */   
            
        IF  LAST-OF(craphis.dshistor)   AND  /* Hist. 561-salario **/
            craphis.cdhistor = 561      AND
           (aux_vlrttctb <> 0           OR
            aux_vllanchq <> 0)          THEN 
            DO:
                IF  p-impressao         = YES   AND
                    LINE-COUNTER(str_1) > 76    THEN
                    PAGE STREAM str_1.
                    
                ASSIGN aux_descrctb = TRIM(SUBSTRING(craphis.dshistor,1,24))
    
                       SUBSTR(aux_descrctb,length(aux_descrctb) + 2,(24 - 
                              length(aux_descrctb) - 1)) =
                                  FILL(".",24 - length(aux_descrctb) - 1)
                       aux_descrctb = SUBSTRING(aux_descrctb,1,24) + "(" +
                                      STRING(aux_qtrttctb, "zz,zz9") + ") ".

                IF p-nome-arquivo <> " " THEN
                DO:
                    DISPLAY STREAM str_1 WITH FRAME f_linha_branco.

                    DISPLAY STREAM str_1
                            aux_descrctb aux_nrctadeb aux_nrctacrd 
                            aux_cdhistor aux_vlrttctb
                            WITH FRAME f_ctb_boletim.
                    DOWN STREAM str_1 WITH FRAME f_ctb_boletim. 
                END.

                FOR EACH w_empresa NO-LOCK:
                
                    FIND crapemp WHERE crapemp.cdcooper = crapcop.cdcooper
                                   AND crapemp.cdempres = w_empresa.cdempres
                                       NO-LOCK.
                    
                    ASSIGN aux_vlrtthis = w_empresa.vllanmto
                           aux_deschist = 
                               STRING(w_empresa.cdempres,"99999")    + "-" +  
                               STRING(crapemp.nmresemp,"x(16)")  + "(" +
                               STRING(w_empresa.qtlanmto, "zz,zz9") + ")"
                               SUBSTR(aux_deschist,length(aux_deschist) + 2,
                               (41 - length(aux_deschist) - 1)) =
                               FILL(".",41 - length(aux_deschist) - 1).
                       
                    IF p-nome-arquivo <> " " THEN
                    DO:  
                        DISPLAY STREAM str_1 aux_deschist aux_vlrtthis 
                                             WITH FRAME f_his_boletim.
    
                        DOWN STREAM str_1 WITH FRAME f_his_boletim.
                    END.
                END.
               
            END. /* IF  LAST-OF(craphis.dshistor)  */   
    
        IF  LAST-OF(craphis.indebcre) THEN 
            DO:
                IF  craphis.indebcre = "C"   THEN  
                    DO:
                        IF  p-nome-arquivo <> " "  THEN 
                            DO:     
                                VIEW STREAM str_1 FRAME f_saidas_boletim.

                                IF  p-impressao         = YES   AND
                                    LINE-COUNTER(str_1) > 80    THEN
                                    PAGE STREAM str_1.
                            END.
                    END.
                ELSE 
                    DO:
                        ASSIGN aux_vldsdfin    =
                               crapbcx.vldsdini + aux_vlrttcrd - aux_vlrttdeb
                               p-valor-credito = aux_vlrttcrd
                               p-valor-debito  = aux_vlrttdeb.
                        IF  p-nome-arquivo <> " " THEN 
                            DO:
                                IF  p-impressao         = YES  AND
                                    LINE-COUNTER(str_1) > 80   THEN
                                    PAGE STREAM str_1.
                                                       
                                VIEW STREAM str_1 FRAME f_saldo_final. 
                            END.
                    END.
            END. /* IF LAST-OF(craphis.indebcre) THEN  */                 
    END.  /* for each craphis */

    FOR EACH work_estorno:
        DELETE work_estorno.
    END.
        
    IF  p-impressao  = yes   THEN 
        DO:
            IF  LINE-COUNTER(str_1) > 72   THEN
                PAGE STREAM str_1.

            FOR EACH crapaut WHERE crapaut.cdcooper = crapcop.cdcooper  AND
                                   crapaut.cdagenci = p-cod-agencia     AND
                                   crapaut.nrdcaixa = p-nro-caixa       AND
                                   crapaut.dtmvtolt = da-data           AND
                                   crapaut.estorno  = YES               NO-LOCK
                                   BREAK BY crapaut.dtmvtolt
                                            BY crapaut.nrsequen:
                                            
                FIND FIRST craphis WHERE craphis.cdcooper = crapaut.cdcooper   AND
                                         craphis.cdhistor = crapaut.cdhistor
                                         NO-LOCK NO-ERROR.
                IF  AVAIL craphis THEN
                    ASSIGN c-hist = TRIM(SUBSTR(craphis.dshistor,1,15)).

                IF  crapaut.tpoperac = YES THEN
                    ASSIGN c-desc = "PG".
                ELSE 
                    ASSIGN c-desc = "RC".
                            
                IF  FIRST-OF(crapaut.dtmvtolt) THEN  
                    VIEW STREAM str_1 FRAME f_inicio_estorno.
             
                DISP STREAM str_1 
                     crapaut.nrsequen
                     c-hist
                     crapaut.nrdocmto
                     crapaut.vldocmto
                     c-desc
                     crapaut.nrseqaut
                     WITH  FRAME f_estornos.
                DOWN STREAM str_1 WITH  FRAME f_estornos.
               
                              
                CREATE  work_estorno.
                ASSIGN  work_estorno.cdagenci = p-cod-agencia       
                        work_estorno.nrdcaixa = p-nro-caixa          
                        work_estorno.nrseqaut = crapaut.nrseqaut.
                               
                IF  LAST-OF(crapaut.dtmvtolt) THEN  
                    VIEW STREAM str_1 FRAME f_fim_estorno.
                                 
            END. /* FOR EACH crapaut */
         
         /*=== Historicos Dif.Caixa/Recuperacao Caixa(701/702/733/734 ===*/
            FOR EACH craplcx WHERE (craplcx.cdcooper = crapcop.cdcooper     AND
                                    craplcx.cdagenci = p-cod-agencia        AND
                                    craplcx.nrdcaixa = p-nro-caixa          AND
                                    craplcx.dtmvtolt = da-data              AND
                                    craplcx.cdhistor = 701)
                                   OR
                                   (craplcx.cdcooper = crapcop.cdcooper     AND
                                    craplcx.cdagenci = p-cod-agencia        AND
                                    craplcx.nrdcaixa = p-nro-caixa          AND
                                    craplcx.dtmvtolt = da-data              AND
                                    craplcx.cdhistor = 702)
                                   OR
                                   (craplcx.cdcooper = crapcop.cdcooper     AND
                                    craplcx.cdagenci = p-cod-agencia        AND
                                    craplcx.nrdcaixa = p-nro-caixa          AND
                                    craplcx.dtmvtolt = da-data              AND
                                    craplcx.cdhistor = 733)
                                   OR
                                   (craplcx.cdcooper = crapcop.cdcooper     AND
                                    craplcx.cdagenci = p-cod-agencia        AND
                                    craplcx.nrdcaixa = p-nro-caixa          AND
                                    craplcx.dtmvtolt = da-data              AND
                                    craplcx.cdhistor = 734)
          /*  FOR EACH craplcx WHERE  craplcx.cdcooper = crapcop.cdcooper     AND
                                    craplcx.cdagenci = p-cod-agencia        AND
                                    craplcx.nrdcaixa = p-nro-caixa          AND
                                    craplcx.dtmvtolt = da-data              AND
                                    (craplcx.cdhistor = 701 OR
                                     craplcx.cdhistor = 702 OR
                                     craplcx.cdhistor = 733 OR
                                     craplcx.cdhistor = 734) */
                                   NO-LOCK
                                   BREAK BY craplcx.dtmvtolt
                                            BY craplcx.nrautdoc:
                                         
                FIND FIRST craphis WHERE craphis.cdcooper = craplcx.cdcooper AND
                                         craphis.cdhistor = craplcx.cdhistor
                                         NO-LOCK NO-ERROR.
                                     
                ASSIGN c-hist = " ".
                IF  AVAIL craphis THEN
                    ASSIGN c-hist = STRING(craphis.cdhistor,"9999") + "-" +
                                    TRIM(SUBSTR(craphis.dshistor,1,11)).

                FIND crapaut WHERE crapaut.cdcooper = crapcop.cdcooper     AND
                                   crapaut.cdagenci = craplcx.cdagenci     AND
                                   crapaut.nrdcaixa = craplcx.nrdcaixa     AND
                                   crapaut.dtmvtolt = craplcx.dtmvtolt     AND
                                   crapaut.nrsequen = craplcx.nrautdoc 
                                   NO-LOCK NO-ERROR.

                IF  FIRST-OF(craplcx.dtmvtolt) THEN  
                    VIEW STREAM str_1 FRAME f_inicio_diferenca.
 
                IF  crapaut.tpoperac = YES THEN
                    ASSIGN c-desc = "PG".
                ELSE 
                    ASSIGN c-desc = "RC".

                DISP STREAM str_1 
                     crapaut.nrsequen
                     c-hist
                     crapaut.nrdocmto
                     crapaut.vldocmto
                     c-desc
                     crapaut.nrseqaut
                     WITH  FRAME f_estornos.
                DOWN STREAM str_1 WITH  FRAME f_estornos.
    
                IF  LAST-OF(craplcx.dtmvtolt) THEN  
                    VIEW STREAM str_1 FRAME f_fim_diferenca.
              
            END. /* FOR EACH craplcx */
         
            IF  crapbcx.cdsitbcx = 2   THEN
                rel_dsfechad = "** BOLETIM FECHADO **".
            ELSE
                rel_dsfechad = " ** BOLETIM ABERTO **".

            DISPLAY STREAM str_1 
                    rel_dsfechad WITH FRAME f_vistos.        
     
            RUN lista_doctos_gerenciador.
     
            IF  crapbcx.cdsitbcx = 2   THEN
                rel_dsfechad = "** BOLETIM FECHADO **".
            ELSE
                rel_dsfechad = " ** BOLETIM ABERTO **".

            DISPLAY STREAM str_1 
                rel_dsfechad WITH FRAME f_vistos.        
     
        END.
     ELSE 
        DO:
            IF  p-nome-arquivo <> " "  THEN 
                DO:
                    FOR EACH crapaut WHERE
                             crapaut.cdcooper = crapcop.cdcooper    AND
                             crapaut.cdagenci = p-cod-agencia       AND
                             crapaut.nrdcaixa = p-nro-caixa         AND
                             crapaut.dtmvtolt = da-data             AND
                             crapaut.estorno  = YES                 NO-LOCK
                             BREAK BY crapaut.dtmvtolt
                                      BY crapaut.nrsequen:
                                      
                        IF  FIRST-OF(crapaut.dtmvtolt) THEN  
                            VIEW STREAM str_1 FRAME f_inicio_estorno.
             
                        FIND FIRST craphis WHERE 
                                   craphis.cdcooper = crapaut.cdcooper   AND
                                   craphis.cdhistor = crapaut.cdhistor  
                                   NO-LOCK NO-ERROR.
                                   
                        IF  AVAIL craphis THEN
                            ASSIGN c-hist = 
                                      TRIM(SUBSTRING(craphis.dshistor,1,15)).

                        IF   crapaut.tpoperac = YES THEN
                             ASSIGN c-desc = "PG".
                        ELSE 
                             ASSIGN c-desc = "RC".

                        DISP STREAM str_1
                              crapaut.nrsequen 
                              c-hist
                              crapaut.nrdocmto
                              crapaut.vldocmto
                              c-desc
                              crapaut.nrseqaut
                              WITH  FRAME f_estornos.
                        DOWN STREAM str_1
                              WITH  FRAME f_estornos.
                        

                        CREATE  work_estorno.
                        ASSIGN  work_estorno.cdagenci = p-cod-agencia       
                                work_estorno.nrdcaixa = p-nro-caixa          
                                work_estorno.nrseqaut = crapaut.nrseqaut.
                 
                        IF  LAST-OF(crapaut.dtmvtolt) THEN 
                            VIEW STREAM str_1 FRAME f_fim_estorno. 
                    END. /* for each crapaut */

          /*=== Historicos Dif.Caixa/Recuperacao Caixa(701/702/733/734) ===*/
                    FOR EACH craplcx WHERE 
                             (craplcx.cdcooper = crapcop.cdcooper AND
                              craplcx.cdagenci = p-cod-agencia    AND
                              craplcx.nrdcaixa = p-nro-caixa      AND
                              craplcx.dtmvtolt = da-data          AND
                              craplcx.cdhistor = 701)
                             OR
                             (craplcx.cdcooper = crapcop.cdcooper AND
                              craplcx.cdagenci = p-cod-agencia    AND
                              craplcx.nrdcaixa = p-nro-caixa      AND
                              craplcx.dtmvtolt = da-data          AND
                              craplcx.cdhistor = 702)
                             OR
                             (craplcx.cdcooper = crapcop.cdcooper AND
                              craplcx.cdagenci = p-cod-agencia    AND
                              craplcx.nrdcaixa = p-nro-caixa      AND
                              craplcx.dtmvtolt = da-data          AND
                              craplcx.cdhistor = 733)
                             OR
                             (craplcx.cdcooper = crapcop.cdcooper AND
                              craplcx.cdagenci = p-cod-agencia    AND
                              craplcx.nrdcaixa = p-nro-caixa      AND
                              craplcx.dtmvtolt = da-data          AND
                              craplcx.cdhistor = 734)
                   /* FOR EACH craplcx WHERE 
                             craplcx.cdcooper = crapcop.cdcooper AND
                              craplcx.cdagenci = p-cod-agencia    AND
                              craplcx.nrdcaixa = p-nro-caixa      AND
                              craplcx.dtmvtolt = da-data          AND
                              (craplcx.cdhistor = 701  OR
                               craplcx.cdhistor = 702 OR
                               craplcx.cdhistor = 733 OR
                               craplcx.cdhistor = 734) */
                             NO-LOCK
                             BREAK BY craplcx.dtmvtolt
                                      BY craplcx.nrautdoc:

                        FIND FIRST craphis WHERE
                                   craphis.cdcooper = craplcx.cdcooper   AND
                                   craphis.cdhistor = craplcx.cdhistor 
                                   NO-LOCK NO-ERROR.
                        
                        ASSIGN c-hist = " ".
                        IF  AVAIL craphis THEN
                            ASSIGN c-hist = STRING(craphis.cdhistor,"9999") + 
                                            "-" +
                                            TRIM(
                                               SUBSTR(craphis.dshistor,1,11)).

                        FIND crapaut WHERE 
                             crapaut.cdcooper = crapcop.cdcooper     AND
                             crapaut.cdagenci = craplcx.cdagenci     AND
                             crapaut.nrdcaixa = craplcx.nrdcaixa     AND
                             crapaut.dtmvtolt = craplcx.dtmvtolt     AND
                             crapaut.nrsequen = craplcx.nrautdoc   
                             NO-LOCK NO-ERROR.

                        IF  FIRST-OF(craplcx.dtmvtolt) THEN  
                            VIEW STREAM str_1 FRAME f_inicio_diferenca.
             
                        IF  crapaut.tpoperac = YES THEN
                            ASSIGN c-desc = "PG".
                        ELSE 
                            ASSIGN c-desc = "RC".

                        DISP STREAM str_1 
                             crapaut.nrsequen
                             c-hist
                             crapaut.nrdocmto
                             crapaut.vldocmto
                             c-desc
                             crapaut.nrseqaut
                             WITH  FRAME f_estornos.
                        DOWN STREAM str_1 WITH  FRAME f_estornos.
    
                        IF  LAST-OF(craplcx.dtmvtolt) THEN  
                            VIEW STREAM str_1 FRAME f_fim_diferenca.
                    END. /* FOR EACH craplcx */
             
                    RUN lista_doctos_gerenciador.

                END. /*  IF  p-nome-arquivo <> " " */
        END. /* ELSE DO */

    IF  p-nome-arquivo <> " " THEN 
        OUTPUT STREAM str_1 CLOSE.

    IF  aux_flgsemhi = YES THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro =
       "Atencao! Avise a Informatica urgente. Ha lancamentos novos no CRAPHIS".
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

   IF  p-impressao = YES  THEN  
       DO:
            ASSIGN i-nro-vias   = 1
                   aux_dscomand = "lp -d" + aux_nmdafila +
                                  " -n" + STRING(i-nro-vias) +   
                                  " -oMTl88 " + aux_nmarqimp +     
                                  " > /dev/null".

            UNIX SILENT VALUE(aux_dscomand).
      
       END.  /* impressora */

   RETURN "OK".
    
END PROCEDURE.

PROCEDURE pi-gera-w-histor:
   DEF INPUT PARAM p-cooper    AS CHAR.
   DEF INPUT PARAM pi_cdhistor LIKE craphis.cdhistor.
   DEF INPUT PARAM pi_vllanmto AS DEC FORMAT "zzz,zzz,zzz,zz9.99-".
   DEF INPUT PARAM pi_dsdcompl LIKE craplcx.dsdcompl.
   DEF INPUT PARAM pr_tpcartao AS INTE. /* tpcartao */
   DEF VAR qtlanmto-recibo AS INTE.
   DEF VAR vllanmto-recibo AS DECIMAL.
   DEF VAR qtlanmto-cartao AS INTE.
   DEF VAR vllanmto-cartao AS DECIMAL.
   
   FIND crapcop WHERE crapcop.nmrescop = p-cooper    NO-LOCK NO-ERROR.

   FIND crabhis WHERE crabhis.cdcooper = crapcop.cdcooper   AND
                      crabhis.cdhistor = pi_cdhistor
                      NO-LOCK NO-ERROR.
                     
   IF   NOT AVAIL crabhis THEN NEXT.
   
   IF   craphis.cdhistor <> 717                 AND /* Arrecadacoes */
        crabhis.indebcre <> craphis.indebcre    THEN NEXT.

   /* rotina conta recibo */
   IF pr_tpcartao = 0 THEN
       ASSIGN qtlanmto-recibo = 1
              vllanmto-recibo = pi_vllanmto.
   /* rotina conta cartao */
   IF pr_tpcartao = 1 OR pr_tpcartao = 2 THEN
       ASSIGN qtlanmto-cartao = 1
              vllanmto-cartao = pi_vllanmto.
           
   FIND w-histor WHERE
        w-histor.cdhistor = pi_cdhistor             AND
        w-histor.dshistor = TRIM(crabhis.dshistor)  AND
        w-histor.dsdcompl = TRIM(pi_dsdcompl)       NO-ERROR.
        
   IF   NOT AVAIL w-histor   THEN 
        DO:
            CREATE w-histor.
            ASSIGN w-histor.cdhistor = pi_cdhistor
                   w-histor.dshistor = TRIM(crabhis.dshistor)
                   w-histor.dsdcompl = TRIM(pi_dsdcompl).
        END.
           
   ASSIGN aux_flgouthi      = YES  
          aux_vlrttctb      = aux_vlrttctb      + pi_vllanmto
          aux_qtrttctb      = aux_qtrttctb      + 1
          w-histor.qtlanmto = w-histor.qtlanmto + 1
          w-histor.vllanmto = w-histor.vllanmto + pi_vllanmto
          w-histor.qtlanmto-recibo = w-histor.qtlanmto-recibo + qtlanmto-recibo
          w-histor.vllanmto-recibo = w-histor.vllanmto-recibo + vllanmto-recibo
          w-histor.qtlanmto-cartao = w-histor.qtlanmto-cartao + qtlanmto-cartao
          w-histor.vllanmto-cartao = w-histor.vllanmto-cartao + vllanmto-cartao.

END PROCEDURE.

PROCEDURE gera_craplem:

    FOR EACH craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                           craplot.cdagenci = crapbcx.cdagenci  AND
                           craplot.cdbccxlt = 11                AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                           craplot.cdopecxa = crapbcx.cdopecxa  AND
                           craplot.tplotmov = 5                 NO-LOCK:
             
        FOR EACH craplem WHERE craplem.cdcooper = crapcop.cdcooper  AND
                               craplem.dtmvtolt = craplot.dtmvtolt  AND
                               craplem.cdagenci = craplot.cdagenci  AND
                               craplem.cdbccxlt = craplot.cdbccxlt  AND
                               craplem.nrdolote = craplot.nrdolote 
                               USE-INDEX craplem1 NO-LOCK:
            ASSIGN aux_vlrttctb = aux_vlrttctb + craplem.vllanmto
                   aux_qtrttctb = aux_qtrttctb + 1.
        END.    
    END.              
END PROCEDURE.

PROCEDURE gera_crapcbb:

    FOR EACH craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                           craplot.cdagenci = crapbcx.cdagenci  AND
                           craplot.cdbccxlt = 11                AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                           craplot.cdopecxa = crapbcx.cdopecxa  AND
                           craplot.tplotmov = 28                NO-LOCK:
                           
        FOR EACH crapcbb WHERE crapcbb.cdcooper = crapcop.cdcooper  AND
                               crapcbb.dtmvtolt = craplot.dtmvtolt  AND
                               crapcbb.cdagenci = craplot.cdagenci  AND
                               crapcbb.cdbccxlt = craplot.cdbccxlt  AND
                               crapcbb.nrdolote = craplot.nrdolote  AND
                               crapcbb.tpdocmto < 3                 AND
                               crapcbb.flgrgatv = YES               NO-LOCK:
                               
            ASSIGN aux_vlrttctb = aux_vlrttctb + crapcbb.valorpag
                                  aux_qtrttctb = aux_qtrttctb + 1.
        END.    
    END.              
END PROCEDURE.

PROCEDURE gera_craplpi:

    FOR EACH craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                           craplot.cdagenci = crapbcx.cdagenci  AND
                           craplot.cdbccxlt = 11                AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                           craplot.cdopecxa = crapbcx.cdopecxa  AND
                           craplot.tplotmov = 33                NO-LOCK:
                           
        FOR EACH craplpi WHERE craplpi.cdcooper = craplot.cdcooper   AND
                               craplpi.dtmvtolt = craplot.dtmvtolt   AND
                               craplpi.cdagenci = craplot.cdagenci   AND
                               craplpi.cdbccxlt = craplot.cdbccxlt   AND
                               craplpi.nrdolote = craplot.nrdolote
                               NO-LOCK:
                               
            ASSIGN aux_vlrttctb = aux_vlrttctb + craplpi.vllanmto
                                  aux_qtrttctb = aux_qtrttctb + 1.
        END.    
    END.              
END PROCEDURE.


PROCEDURE gera_crapcbb_INSS:

    FOR EACH craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                           craplot.cdagenci = crapbcx.cdagenci  AND
                           craplot.cdbccxlt = 11                AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                           craplot.cdopecxa = crapbcx.cdopecxa  AND
                           craplot.tplotmov = 31                NO-LOCK:
                           
        FOR EACH crapcbb WHERE crapcbb.cdcooper = crapcop.cdcooper    AND
                               crapcbb.dtmvtolt = craplot.dtmvtolt    AND
                               crapcbb.cdagenci = craplot.cdagenci    AND
                               crapcbb.cdbccxlt = craplot.cdbccxlt    AND
                               crapcbb.nrdolote = craplot.nrdolote    AND
                               crapcbb.tpdocmto = 3                   NO-LOCK:
                 
            ASSIGN aux_vlrttctb = aux_vlrttctb + crapcbb.valorpag
                                  aux_qtrttctb = aux_qtrttctb + 1.
        END.    
    END.              
END PROCEDURE.

PROCEDURE gera_craplcs:

    DEF VAR aux_qtlanmto AS INT                                     NO-UNDO.
    DEF VAR aux_vllanmto AS DEC                                     NO-UNDO.
    
    EMPTY TEMP-TABLE w_empresa.
    
    FOR EACH craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                           craplot.cdagenci = crapbcx.cdagenci  AND
                           craplot.cdbccxlt = 11                AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                           craplot.cdopecxa = crapbcx.cdopecxa  AND
                           craplot.tplotmov = 32                NO-LOCK:
                           
        FOR EACH  craplcs WHERE craplcs.cdcooper = craplot.cdcooper   AND
                                craplcs.dtmvtolt = craplot.dtmvtolt   AND
                                craplcs.cdagenci = craplot.cdagenci   AND
                                craplcs.cdhistor = 561 /* Cta. Sal */ AND
                                craplcs.nrdolote = craplot.nrdolote   NO-LOCK,
            FIRST crapccs WHERE crapccs.cdcooper = craplcs.cdcooper   AND
                                crapccs.nrdconta = craplcs.nrdconta   NO-LOCK
                                BREAK BY crapccs.cdempres:
            
                   /* Total da empresa */
            ASSIGN aux_qtlanmto = aux_qtlanmto + 1
                   aux_vllanmto = aux_vllanmto + craplcs.vllanmto
                   
                   /* Total do historico */
                   aux_vlrttctb = aux_vlrttctb + craplcs.vllanmto
                   aux_qtrttctb = aux_qtrttctb + 1
                   
                   /* Total de creditos */
                   aux_vlrttcrd = aux_vlrttcrd + craplcs.vllanmto.
                   
            IF   LAST-OF(crapccs.cdempres)   THEN
                 DO:
                     CREATE w_empresa.
                     ASSIGN w_empresa.cdempres = crapccs.cdempres
                            w_empresa.qtlanmto = aux_qtlanmto
                            w_empresa.vllanmto = aux_vllanmto.
                            
                     ASSIGN aux_qtlanmto = 0
                            aux_vllanmto = 0.
                 END.
        END.    
    END.
    
END PROCEDURE.

PROCEDURE gera_craplgp:

    FOR EACH craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                           craplot.cdagenci = crapbcx.cdagenci  AND
                           craplot.cdbccxlt = 11                AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                           craplot.cdopecxa = crapbcx.cdopecxa  AND
                           craplot.tplotmov = 30                NO-LOCK:

        FOR EACH craplgp WHERE craplgp.cdcooper = crapcop.cdcooper  AND
                               craplgp.dtmvtolt = craplot.dtmvtolt  AND
                               craplgp.cdagenci = craplot.cdagenci  AND
                               craplgp.cdbccxlt = craplot.cdbccxlt  AND
                               craplgp.nrdolote = craplot.nrdolote  NO-LOCK:

            ASSIGN aux_vlrttctb = aux_vlrttctb + craplgp.vlrtotal
                   aux_qtrttctb = aux_qtrttctb + 1.
        END.    
    END.                                                                   
END PROCEDURE.

PROCEDURE gera_craplgp_gps:

    FOR EACH craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                           craplot.cdagenci = crapbcx.cdagenci  AND
                           craplot.cdbccxlt = 100               AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                           craplot.cdopecxa = crapbcx.cdopecxa  AND
                           craplot.tplotmov = 30                NO-LOCK:

        FOR EACH craplgp WHERE craplgp.cdcooper = crapcop.cdcooper  AND
                               craplgp.dtmvtolt = craplot.dtmvtolt  AND
                               craplgp.cdagenci = craplot.cdagenci  AND
                               craplgp.cdbccxlt = craplot.cdbccxlt  AND
                               craplgp.nrdolote = craplot.nrdolote  AND
                               craplgp.idsicred <> 0                AND
                               craplgp.nrseqagp = 0
                           AND craplgp.flgativo = YES               NO-LOCK:
                     /** Nao pegar GPS agendada */
            ASSIGN aux_vlrttctb = aux_vlrttctb + craplgp.vlrtotal
                                  aux_qtrttctb = aux_qtrttctb + 1.
        END.    
    END.                                                                   
END PROCEDURE.


PROCEDURE gera_craplci:
    FOR EACH craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                           craplot.cdagenci = crapbcx.cdagenci  AND
                           craplot.cdbccxlt = 11                AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                           craplot.cdopecxa = crapbcx.cdopecxa  AND
                           craplot.tplotmov = 29                NO-LOCK:
                           
        FOR EACH craplci WHERE craplci.cdcooper = crapcop.cdcooper  AND
                               craplci.dtmvtolt = craplot.dtmvtolt  AND
                               craplci.cdagenci = craplot.cdagenci  AND
                               craplci.cdbccxlt = craplot.cdbccxlt  AND
                               craplci.nrdolote = craplot.nrdolote  AND   
                               craplci.cdhistor = craphis.cdhistor  NO-LOCK:
                               
            ASSIGN aux_vlrttctb = aux_vlrttctb + craplci.vllanmto
                                  aux_qtrttctb = aux_qtrttctb + 1.
        END.    
    END.              
END PROCEDURE.
                
PROCEDURE lista_doctos_gerenciador:
                 
    IF  crapbcx.cdsitbcx = 2   AND 
       (crapcop.cdcooper = 1   OR        /* para a VIACREDI */
        crapcop.cdcooper = 2)  THEN      /* para a CREDITEXTIL */
        DO:
            /*  Historicos transitados no gerenciador financeiro - Edson */

            FOR EACH crapaut WHERE crapaut.cdcooper = crapcop.cdcooper      AND
                                   crapaut.dtmvtolt = crapbcx.dtmvtolt      AND
                                   crapaut.cdagenci = crapbcx.cdagenci      AND
                                   crapaut.nrdcaixa = crapbcx.nrdcaixa      AND
                            CAN-DO("707,708,747",STRING(crapaut.cdhistor))  AND
                                   crapaut.estorno  = NO
                                   NO-LOCK
                                   BREAK BY crapaut.nrsequen:
             
                IF  FIRST(crapaut.nrsequen)   THEN 
                    DO:
                        PAGE STREAM str_1.
             
                        DISPLAY STREAM str_1
                            "DOCUMENTOS TRANSITADOS VIA GERENCIADOR FINANCEIRO"
                            SKIP(1)
                            WITH NO-BOX COLUMN aux_nrcoluna
                               NO-LABELS WIDTH 76 FRAME f_cab_gerfin.
                    END.
                FIND work_estorno WHERE 
                     work_estorno.cdagenci = crapbcx.cdagenci   AND
                     work_estorno.nrdcaixa = crapbcx.nrdcaixa   AND
                     work_estorno.nrseqaut = crapaut.nrsequen 
                     NO-LOCK NO-ERROR.
                     
                IF  NOT AVAIL work_estorno THEN  
                    DO:
                        IF  NOT crapaut.estorno THEN 
                            DO:
                                FIND craphis WHERE
                                     craphis.cdcooper = crapaut.cdcooper   AND
                                     craphis.cdhistor = crapaut.cdhistor
                                     NO-LOCK NO-ERROR.
         
                                ASSIGN aux_dshistor = 
                                        STRING(crapaut.cdhistor,"9999") + "-".
         
                                IF  AVAIL craphis   THEN  
                                    ASSIGN aux_dshistor = 
                                            aux_dshistor + craphis.dshistor.
                                ELSE
                                    ASSIGN aux_dshistor = 
                                            aux_dshistor + "***************".
    
                                ASSIGN tot_qtgerfin = tot_qtgerfin + 1
                                       tot_vlgerfin = tot_vlgerfin + 
                                                      crapaut.vldocmto.
                
                                DISPLAY STREAM str_1
                                        crapaut.nrsequen   aux_dshistor
                                        crapaut.nrdocmto   crapaut.vldocmto
                                        aux_dsdtraco
                                        WITH FRAME f_gerfin.

                                DOWN 2 STREAM str_1 WITH FRAME f_gerfin.
                            END. 
                    END.         
                IF  LINE-COUNTER(str_1) = 80   THEN
                    DO:
                        PAGE STREAM str_1.
                       
                        DISPLAY STREAM str_1
                            "DOCUMENTOS TRANSITADOS VIA GERENCIADOR FINANCEIRO"
                                SKIP(1)
                                WITH NO-BOX COLUMN aux_nrcoluna
                                     NO-LABELS WIDTH 76 FRAME f_cab_gerfin.
                    END.
                IF  LAST(crapaut.nrsequen)   THEN
                    DO:
                        DISPLAY STREAM str_1
                                "T O T A I S ===>" AT  1
                                tot_qtgerfin       AT 41 FORMAT "zz,zz9"
                                tot_vlgerfin       AT 48 FORMAT "zzzz,zzz.99"
                                SKIP
                                WITH NO-BOX COLUMN aux_nrcoluna
                                     NO-LABELS WIDTH 76 FRAME f_total_gerfin.
                  
                        DISPLAY STREAM str_1 WITH FRAME f_fim_estornos.
                  
                        DOWN STREAM str_1 WITH FRAME f_fim_estornos.
                    END.    
             
            END.  /*  Fim do FOR EACH -- crapaut  */

        END.
END PROCEDURE. 

/*  b2crap13.p */

/* .......................................................................... */

