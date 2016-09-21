/****************************************************************************** 
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE                        
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!             
  +---------------------------------+-----------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                     |
  +---------------------------------+-----------------------------------------+
  | cadastra_taxa_cdi_mensal        | APLI0004.pc_cadastra_taxa_cdi_mensal    |
  | grava_taxa_cdi_mensal           | APLI0004.pc_grava_taxa_cdi_mensal       |
  | cadastra_taxa_cdi_acumulado     | APLI0004.pc_cadastra_taxa_cdi_acumulado |
  | poupanca                        | APLI0004.pc_poupanca                    |
  | calcula_poupanca                | APLI0004.pc_calcula_poupanca            |
  | calcula_qt_dias_uteis           | APLI0004.pc_calcula_qt_dias_uteis       |  
  | atualiza_sol026                 | APLI0004.pc_atualiza_sol026             |   
  | atualiza_tr                     | APLI0004.pc_atualiza_tr                 |   
  +---------------------------------+-----------------------------------------+
    
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.        
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES     
  PESSOAS:                                                                     
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
*******************************************************************************/
/*.............................................................................

    Programa: b1wgen0128.p
    Autor   : Isara - RKAM
    Data    : Novembro/2011                   Ultima atualizacao: 10/02/2014   

    Objetivo  : Cadastro da taxa de CDI, Poupança e TR 

    Alteracoes: 30/03/2012 - Alterar para cadastrar a cadastra_taxa_cdi_mensal
                             e cadastra_taxa_cdi_acumulado no ultimo dia do
                             mes, caso o ultimo nao for dia util (Ze).
                             
                12/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                
                04/02/2014 - Inclusão do CREATE na table crapmfx para procedure
                             poupanca, inclusao de tpmoefix = 19 - Selic.
                             (Jean Michel)
                             
                10/02/2014 - Alteração grava_taxa_cdi_mensal para utilizar
                             nova taxa de poupança. (Jean Michel)
                             
                20/05/2014 - Conversão Progress >> PLSQL (Jean Michel).             
                             
.............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEFINE BUFFER bf-craptab  FOR craptab.
DEFINE BUFFER bf2-craptab FOR craptab.
DEFINE BUFFER bf3-craptab FOR craptab.
DEFINE BUFFER bf-craptrd  FOR craptrd.
DEFINE BUFFER bf-crapmfx  FOR crapmfx.
DEFINE BUFFER bf2-crapmfx FOR crapmfx.
DEFINE BUFFER bf3-crapmfx FOR crapmfx.
DEFINE BUFFER bf4-crapmfx FOR crapmfx.
DEFINE BUFFER bf5-crapmfx FOR crapmfx.
DEFINE BUFFER bf-crapcop  FOR crapcop.
DEFINE BUFFER bf-crapfer  FOR crapfer.

DEFINE VARIABLE aux_cdcritic AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_dscritic AS CHARACTER   NO-UNDO.


/*................................ PROCEDURES................................*/

PROCEDURE cadastra_taxa_cdi_mensal:

    DEFINE INPUT PARAM p_cdcooper  AS INTEGER                NO-UNDO.
    DEFINE INPUT PARAM p_cdi_anual AS DECIMAL                NO-UNDO.
    DEFINE INPUT PARAM p_dtperiod  LIKE craptrd.dtiniper     NO-UNDO.
    DEFINE INPUT PARAM p_dtdiaant  AS DATE                   NO-UNDO.
    DEFINE INPUT PARAM p_dtdiapos  AS DATE                   NO-UNDO.
    DEFINE INPUT PARAM p_flatuant  AS LOGICAL                NO-UNDO.
    
    DEFINE VARIABLE aux_contdias AS INTEGER                  NO-UNDO.
    DEFINE VARIABLE aux_contador AS INTEGER                  NO-UNDO.
    DEFINE VARIABLE aux_dtiniper AS DATE                     NO-UNDO.
    DEFINE VARIABLE aux_dtultdia AS DATE                     NO-UNDO.

    FIND bf-crapcop WHERE bf-crapcop.cdcooper = p_cdcooper NO-LOCK NO-ERROR.
    
    /*  Verifica dias anteriores  */

    IF   p_flatuant = TRUE THEN  /* Certifica se deve atualizar p/ dias ant. */
         DO:
             aux_contador = (p_dtperiod - p_dtdiaant).

             IF   aux_contador > 1 THEN
                  DO:
                      FIND bf2-crapmfx WHERE 
                           bf2-crapmfx.cdcooper = bf-crapcop.cdcooper AND
                           bf2-crapmfx.dtmvtolt = p_dtdiaant          AND
                           bf2-crapmfx.tpmoefix = 6 /* CDI Anual */ 
                           NO-LOCK NO-ERROR.
                                   
                      IF   AVAILABLE bf2-crapmfx THEN
                           DO aux_contdias = 1 TO (aux_contador - 1):

                              aux_dtiniper = p_dtdiaant + aux_contdias.
                                                  
                              RUN grava_taxa_cdi_mensal 
                                               (INPUT bf-crapcop.cdcooper,
                                                INPUT bf2-crapmfx.vlmoefix,
                                                INPUT aux_dtiniper).
                                                    
                              IF   RETURN-VALUE <> "OK" THEN
                                   RETURN "NOK".
                           END.
                  END. 

             
             /*  Cadastra Taxa para dias posteriores do proprio MES
                 Caso a viarada do mes for um final de semana */
                 
             IF   MONTH(p_dtdiapos) <> MONTH(p_dtperiod) THEN
                  DO:
                      aux_dtultdia = DATE(MONTH(p_dtdiapos),1,
                                          YEAR(p_dtdiapos)) - 1.
                      
                      aux_contador = (aux_dtultdia - p_dtperiod).

                      IF   aux_contador > 0 THEN
                           DO:
                               FIND bf2-crapmfx WHERE 
                                 bf2-crapmfx.cdcooper = bf-crapcop.cdcooper AND
                                 bf2-crapmfx.dtmvtolt = p_dtperiod          AND
                                 bf2-crapmfx.tpmoefix = 6 /* CDI Anual */ 
                                 NO-LOCK NO-ERROR.
                                   
                               IF   AVAILABLE bf2-crapmfx THEN
                                    DO aux_contdias = 1 TO aux_contador:

                                       aux_dtiniper = p_dtperiod + aux_contdias.
                                                  
                                       RUN grava_taxa_cdi_mensal 
                                               (INPUT bf-crapcop.cdcooper,
                                                INPUT bf2-crapmfx.vlmoefix,
                                                INPUT aux_dtiniper).
                                                    
                                       IF   RETURN-VALUE <> "OK" THEN
                                            RETURN "NOK".
                                    END.
                           END. 
                  END.
         END.
             
                  
    /*   Grava o CDI do MES diariamente   */

    RUN grava_taxa_cdi_mensal (INPUT bf-crapcop.cdcooper,
                               INPUT p_cdi_anual,
                               INPUT p_dtperiod).

    IF   RETURN-VALUE <> "OK" THEN
         RETURN "NOK".                           


    RETURN "OK".

END PROCEDURE.


PROCEDURE grava_taxa_cdi_mensal:

    DEFINE INPUT PARAM p_cdcooper  AS INTEGER                       NO-UNDO.
    DEFINE INPUT PARAM p_cdi_anual AS DECIMAL                       NO-UNDO.
    DEFINE INPUT PARAM p_dtiniper  LIKE craptrd.dtiniper            NO-UNDO.

    DEFINE VARIABLE aux_dtfimper AS DATE      FORMAT 99/99/9999     NO-UNDO.
    DEFINE VARIABLE aux_cartaxas AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_vllidtab AS CHARACTER                       NO-UNDO.
    DEFINE VARIABLE aux_contador AS INTEGER   FORMAT "z9"           NO-UNDO.
    DEFINE VARIABLE aux_tptaxcdi AS INTEGER   EXTENT 99             NO-UNDO.
    DEFINE VARIABLE aux_vlfaixas AS DECIMAL   EXTENT 99             NO-UNDO.
    DEFINE VARIABLE aux_qtdtxtab AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_qtdiaute AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_cdimensa AS DECIMAL DECIMALS 8              NO-UNDO.
    DEFINE VARIABLE aux_txadical AS DECIMAL DECIMALS 8 EXTENT 99    NO-UNDO.
    DEFINE VARIABLE aux_vltxadic AS DECIMAL DECIMALS 8              NO-UNDO.
    DEFINE VARIABLE aux_txmespop AS DECIMAL DECIMALS 8              NO-UNDO.
    DEFINE VARIABLE aux_txdiapop AS DECIMAL DECIMALS 8              NO-UNDO.

    FIND bf-crapmfx WHERE bf-crapmfx.cdcooper = p_cdcooper  AND
                          bf-crapmfx.dtmvtolt = p_dtiniper  AND
                          bf-crapmfx.tpmoefix = 16 /* CDI Mensal*/ 
                          EXCLUSIVE-LOCK NO-ERROR.
                                 
    IF   NOT AVAILABLE bf-crapmfx THEN
         DO:
             CREATE bf-crapmfx.
             ASSIGN bf-crapmfx.cdcooper = p_cdcooper
                    bf-crapmfx.dtmvtolt = p_dtiniper
                    bf-crapmfx.tpmoefix = 16.
             VALIDATE bf-crapmfx.
         END.

    FIND FIRST bf3-crapmfx WHERE bf3-crapmfx.cdcooper = p_cdcooper  AND
                                 bf3-crapmfx.dtmvtolt = p_dtiniper  AND
                                 bf3-crapmfx.tpmoefix = 8 /* Poupanca */ 
                                 NO-LOCK NO-ERROR.

    /***** Calcula Quantidade de Dias Uteis e Retorna a Data *****/
    RUN calcula_qt_dias_uteis (INPUT  p_dtiniper,
                               INPUT  p_cdcooper,
                               OUTPUT aux_qtdiaute,
                               OUTPUT aux_dtfimper).

    FOR EACH bf-craptab WHERE bf-craptab.cdcooper = p_cdcooper      AND
                              bf-craptab.nmsistem = "CRED"          AND
                              bf-craptab.tptabela = "CONFIG"        AND
                              bf-craptab.cdacesso = "TXADIAPLIC"
                              NO-LOCK:
    
        DO aux_cartaxas = 1 TO NUM-ENTRIES(bf-craptab.dstextab,";"):
    
           ASSIGN aux_vllidtab               =                                
                                  ENTRY(aux_cartaxas,bf-craptab.dstextab,";")
                  aux_contador               = aux_contador + 1
                  aux_tptaxcdi[aux_contador] = bf-craptab.tpregist
                  aux_txadical[aux_contador] = DEC(ENTRY(2,aux_vllidtab,"#"))
                  aux_vlfaixas[aux_contador] = DEC(ENTRY(1,aux_vllidtab,"#")).
        END.

    END.

    /* Gravar o CDI Mensal no crapmfx (tipo 16) e no craptrd */
    DO aux_qtdtxtab = 1 TO aux_contador:
    
       ASSIGN aux_cdimensa        = ROUND(((EXP(1 + (p_cdi_anual / 100), 
                                            aux_qtdiaute / 252) - 1) * 100),8)
              bf-crapmfx.vlmoefix = aux_cdimensa.

       FIND bf-craptrd WHERE bf-craptrd.cdcooper = p_cdcooper             AND
                             bf-craptrd.dtiniper = p_dtiniper             AND
                             bf-craptrd.tptaxrda = 
                                               aux_tptaxcdi[aux_qtdtxtab] AND
                             bf-craptrd.incarenc = 0                      AND
                             bf-craptrd.vlfaixas =
                                               aux_vlfaixas[aux_qtdtxtab]
                             EXCLUSIVE-LOCK NO-ERROR.
          
       IF   NOT AVAILABLE bf-craptrd THEN
            DO:
                CREATE bf-craptrd.
                ASSIGN bf-craptrd.tptaxrda = aux_tptaxcdi[aux_qtdtxtab]
                       bf-craptrd.dtiniper = p_dtiniper 
                       bf-craptrd.dtfimper = aux_dtfimper 
                       bf-craptrd.qtdiaute = aux_qtdiaute
                       bf-craptrd.vlfaixas = aux_vlfaixas[aux_qtdtxtab]
                       bf-craptrd.incarenc = 0
                       bf-craptrd.incalcul = 0
                       bf-craptrd.cdcooper = p_cdcooper.
            END.

       ASSIGN aux_vltxadic        = aux_txadical[aux_qtdtxtab]
              bf-craptrd.txofimes = ROUND(((aux_cdimensa * aux_vltxadic)
                                                 / 100),6)
              bf-craptrd.txofidia =
                            ROUND(((EXP(1 + (bf-craptrd.txofimes / 100),
                            1 / aux_qtdiaute) - 1) * 100),6).
       VALIDATE bf-craptrd.


       /*   Verifica se a Poupanca eh maior que o CDI e se irá utilizar antiga regra  */
       IF aux_tptaxcdi[aux_qtdtxtab] < 4 THEN
           DO:
                IF   AVAILABLE bf3-crapmfx THEN
                    DO:
                        RUN calcula_poupanca(INPUT  p_cdcooper,
                                             INPUT  aux_qtdiaute,
                                             INPUT  bf3-crapmfx.vlmoefix, 
                                             OUTPUT aux_txmespop,
                                             OUTPUT aux_txdiapop).
                  
                        ASSIGN bf-craptrd.vltrapli = 
                                   IF   bf-craptrd.txofimes < aux_txmespop THEN
                                        bf3-crapmfx.vlmoefix /* Poupança */
                                   ELSE 
                                        bf-crapmfx.vlmoefix  /* CDI */
                            
                               bf-craptrd.txofimes = 
                                   IF   bf-craptrd.txofimes < aux_txmespop THEN
                                        aux_txmespop         /* Poupança */
                                   ELSE 
                                        bf-craptrd.txofimes
        
                               bf-craptrd.txofidia = 
                                   IF   bf-craptrd.txofidia < aux_txdiapop THEN
                                        aux_txdiapop
                                   ELSE 
                                        bf-craptrd.txofidia.
                    END.
               ELSE
                    ASSIGN bf-craptrd.vltrapli = bf-crapmfx.vlmoefix.  /* CDI */
           END.
       ELSE
            DO:
                FIND FIRST bf4-crapmfx WHERE bf4-crapmfx.cdcooper = p_cdcooper  AND
                                    bf4-crapmfx.dtmvtolt = p_dtiniper  AND
                                    bf4-crapmfx.tpmoefix = 20 /* Poupanca Novo Indexador */ 
                                    NO-LOCK NO-ERROR.

                /*   Verifica se a Poupanca eh maior que o CDI e se irá utilizar nova regra  */
       
       
                IF   AVAILABLE bf4-crapmfx THEN
                    DO:
                        RUN calcula_poupanca(INPUT  p_cdcooper,
                                             INPUT  aux_qtdiaute,
                                             INPUT  bf4-crapmfx.vlmoefix, 
                                             OUTPUT aux_txmespop,
                                             OUTPUT aux_txdiapop).
                  
                        ASSIGN bf-craptrd.vltrapli = 
                                   IF   bf-craptrd.txofimes < aux_txmespop THEN
                                        bf4-crapmfx.vlmoefix /* Poupança */
                                   ELSE 
                                        bf-crapmfx.vlmoefix  /* CDI */
                            
                               bf-craptrd.txofimes = 
                                   IF   bf-craptrd.txofimes < aux_txmespop THEN
                                        aux_txmespop         /* Poupança */
                                   ELSE 
                                        bf-craptrd.txofimes
        
                               bf-craptrd.txofidia = 
                                   IF   bf-craptrd.txofidia < aux_txdiapop THEN
                                        aux_txdiapop
                                   ELSE 
                                        bf-craptrd.txofidia.
                    END.
               ELSE
                    ASSIGN bf-craptrd.vltrapli = bf-crapmfx.vlmoefix.  /* CDI */
           END.


       RELEASE bf-craptrd.

    END.
    
    RETURN "OK".
    
END PROCEDURE.


PROCEDURE cadastra_taxa_cdi_acumulado:

    DEFINE INPUT PARAM p_cdcooper  AS INTEGER                NO-UNDO.
    DEFINE INPUT PARAM p_cdi_anual AS DECIMAL                NO-UNDO.
    DEFINE INPUT PARAM p_dtperiod  LIKE craptrd.dtiniper     NO-UNDO.
    DEFINE INPUT PARAM p_dtdiaant  AS DATE                   NO-UNDO.
    DEFINE INPUT PARAM p_dtdiapos  AS DATE                   NO-UNDO.
    DEFINE INPUT PARAM p_flatuant  AS LOGICAL                NO-UNDO.
    
    DEFINE VARIABLE aux_cdidiari AS DECIMAL  DECIMALS 8      NO-UNDO.
    DEFINE VARIABLE aux_cdiacuml AS DECIMAL  DECIMALS 8      NO-UNDO.
    DEFINE VARIABLE aux_dtpridia AS DATE                     NO-UNDO.
    DEFINE VARIABLE aux_contdias AS INTEGER                  NO-UNDO.
    DEFINE VARIABLE aux_contador AS INTEGER                  NO-UNDO.
    DEFINE VARIABLE aux_dtiniper AS DATE                     NO-UNDO.
    DEFINE VARIABLE aux_dtultdia AS DATE                     NO-UNDO.

    FIND bf-crapcop WHERE bf-crapcop.cdcooper = p_cdcooper NO-LOCK NO-ERROR.

    /*  Calcular CDI Diário  */

    ASSIGN aux_cdidiari = 
                 ROUND(((EXP(1 + (p_cdi_anual / 100), 1 / 252) - 1) * 100),8)
           aux_cdiacuml = 0.

    FIND bf-crapmfx WHERE bf-crapmfx.cdcooper = bf-crapcop.cdcooper AND
                          bf-crapmfx.dtmvtolt = p_dtperiod          AND
                          bf-crapmfx.tpmoefix = 18 /* CDI Diario */ 
                          EXCLUSIVE-LOCK NO-ERROR.
                              
    IF   NOT AVAILABLE bf-crapmfx THEN
         DO: 
             CREATE bf-crapmfx.
             ASSIGN bf-crapmfx.cdcooper = bf-crapcop.cdcooper
                    bf-crapmfx.dtmvtolt = p_dtperiod
                    bf-crapmfx.tpmoefix = 18
                    bf-crapmfx.vlmoefix = aux_cdidiari.
             VALIDATE bf-crapmfx.
         END.
    ELSE
         bf-crapmfx.vlmoefix = aux_cdidiari.
                
    /*   Calcular CDI ACUMULADO   - 
         Gravar o CDI Acumulado no crapmfx (tipo 17)  */
        
    /*   Verificar o primeiro dia útil do mês   */

    RUN calcula_primeiro_dia_util (INPUT  p_dtperiod,
                                   INPUT  bf-crapcop.cdcooper,
                                   OUTPUT aux_dtpridia).

    
    /*  Quando for o primeiro dia útil do mês, o valor do 
        CDI Acumulado será igual ao valor do CDI Diário    */
           
    IF   p_dtperiod = aux_dtpridia THEN
         DO:
             FIND bf-crapmfx WHERE 
                  bf-crapmfx.cdcooper = p_cdcooper          AND
                  bf-crapmfx.dtmvtolt = aux_dtpridia        AND
                  bf-crapmfx.tpmoefix = 17 /* CDI Acum.*/
                  EXCLUSIVE-LOCK NO-ERROR.

             IF   NOT AVAILABLE bf-crapmfx THEN
                  DO: 
                      CREATE bf-crapmfx.
                      ASSIGN bf-crapmfx.cdcooper = bf-crapcop.cdcooper
                             bf-crapmfx.dtmvtolt = aux_dtpridia
                             bf-crapmfx.tpmoefix = 17
                             bf-crapmfx.vlmoefix = aux_cdidiari.
                      VALIDATE bf-crapmfx.
                  END.
             ELSE
                  bf-crapmfx.vlmoefix = aux_cdidiari.
         END.
    ELSE
         DO: /*  Para os demais dias do mes - o calculo é acumulado */
                 
             /*  Verifica dias anteriores  */
                 
             IF   p_flatuant = TRUE THEN  /* Ver se deve atual. p/ dias ant. */
                  DO:
                      aux_contador = (p_dtperiod - p_dtdiaant).

                      IF   aux_contador > 1 THEN
                           DO:
                               FIND bf-crapmfx WHERE 
                                  bf-crapmfx.cdcooper = bf-crapcop.cdcooper AND
                                  bf-crapmfx.dtmvtolt = p_dtdiaant          AND
                                  bf-crapmfx.tpmoefix = 17 /* CDI Acumul*/ 
                                  NO-LOCK NO-ERROR.
                                   
                               IF   AVAILABLE bf-crapmfx THEN
                                    DO aux_contdias = 1 TO (aux_contador - 1):
                                 
                                       aux_dtiniper = p_dtdiaant +
                                                      aux_contdias.

                                       RUN grava_taxa_cdi_acumulado 
                                                 (INPUT p_cdcooper,
                                                  INPUT bf-crapmfx.vlmoefix,
                                                  INPUT aux_dtiniper).
                                               
                                       IF   RETURN-VALUE <> "OK" THEN
                                            RETURN "NOK".                
                                    END.
                           END.
                  END.
                           
             /*   Grava o CDI ACUMULADO diariamente   */
                 
             FIND bf-crapmfx WHERE 
                  bf-crapmfx.cdcooper = bf-crapcop.cdcooper AND
                  bf-crapmfx.dtmvtolt = p_dtdiaant          AND
                  bf-crapmfx.tpmoefix = 17 /* CDI Acumul*/ 
                  NO-LOCK NO-ERROR.
                                   
             IF   AVAILABLE bf-crapmfx THEN
                  aux_cdiacuml = ROUND(((((aux_cdidiari / 100) + 1 ) * 
                            ((bf-crapmfx.vlmoefix / 100) + 1)) - 1) * 100, 8).
             ELSE
                  aux_cdiacuml = aux_cdidiari.
                         
             RUN grava_taxa_cdi_acumulado (INPUT p_cdcooper,
                                           INPUT aux_cdiacuml,
                                           INPUT p_dtperiod).
                                               
             IF   RETURN-VALUE <> "OK" THEN
                  RETURN "NOK".                              
         
 
             IF   p_flatuant = TRUE THEN  /* Ver se deve atual. p/ dias post. */
                  DO:
                      /*  Cadastra Taxa para dias posteriores do proprio MES
                          Caso a viarada do mes for um final de semana */
                 
                      IF   MONTH(p_dtdiapos) <> MONTH(p_dtperiod) THEN
                           DO:
                              aux_dtultdia = DATE(MONTH(p_dtdiapos),1,
                                                  YEAR(p_dtdiapos)) - 1.
                      
                              aux_contador = (aux_dtultdia - p_dtperiod).

                              IF   aux_contador > 0 THEN
                                   DO:
                                       FIND bf-crapmfx WHERE 
                                            bf-crapmfx.cdcooper = 
                                                 bf-crapcop.cdcooper AND
                                            bf-crapmfx.dtmvtolt = 
                                                 p_dtperiod          AND
                                            bf-crapmfx.tpmoefix = 17 
                                                /* CDI Acumul*/ 
                                            NO-LOCK NO-ERROR.
                                   
                                       IF   AVAILABLE bf-crapmfx THEN
                                            DO aux_contdias = 1 TO aux_contador:
                                 
                                               aux_dtiniper = p_dtperiod +
                                                              aux_contdias.

                                               RUN grava_taxa_cdi_acumulado 
                                                 (INPUT p_cdcooper,
                                                  INPUT bf-crapmfx.vlmoefix,
                                                  INPUT aux_dtiniper).
                                               
                                               IF   RETURN-VALUE <> "OK" THEN
                                                    RETURN "NOK".
                                            END.
                                   END.
                           END. 
                  END.
         END.
             
    
    RETURN "OK".
    
END PROCEDURE.


PROCEDURE grava_taxa_cdi_acumulado:

    DEFINE INPUT PARAM p_cdcooper AS INTEGER              NO-UNDO.
    DEFINE INPUT PARAM p_cdidiari AS DECIMAL              NO-UNDO.
    DEFINE INPUT PARAM p_dtiniper LIKE craptrd.dtiniper   NO-UNDO.
        FIND bf2-crapmfx WHERE bf2-crapmfx.cdcooper = bf-crapcop.cdcooper AND
                           bf2-crapmfx.dtmvtolt = p_dtiniper          AND
                           bf2-crapmfx.tpmoefix = 17 /* CDI Acum.*/ 
                           EXCLUSIVE-LOCK NO-ERROR.

    IF   NOT AVAILABLE bf2-crapmfx THEN
         DO:
             CREATE bf2-crapmfx.
             ASSIGN bf2-crapmfx.cdcooper = p_cdcooper
                    bf2-crapmfx.dtmvtolt = p_dtiniper
                    bf2-crapmfx.tpmoefix = 17.
         END.

    ASSIGN bf2-crapmfx.vlmoefix = p_cdidiari.

    RELEASE bf2-crapmfx.

    RETURN "OK".

END PROCEDURE.


PROCEDURE poupanca:

    DEFINE INPUT  PARAM p_cdcooper AS INT                     NO-UNDO.
    DEFINE INPUT  PARAM p_dtperiod AS DATE                    NO-UNDO.
    DEFINE INPUT  PARAM p_vltaxatr AS DEC                     NO-UNDO.
    DEFINE OUTPUT PARAM p_vlpoupan AS DEC                     NO-UNDO.
    DEFINE OUTPUT PARAM p_dscritic AS CHAR                    NO-UNDO.

    DEF VAR   aux_vlpoupan AS DECIMAL   DECIMALS 8            NO-UNDO.
    DEF VAR   aux_vlpoupnr AS DECIMAL   DECIMALS 8            NO-UNDO.
    DEF VAR   aux_cartaxas AS INTEGER                         NO-UNDO.
    DEF VAR   aux_vllidtab AS CHARACTER                       NO-UNDO.
    DEF VAR   aux_diasutil AS INT                             NO-UNDO.
    DEF VAR   aux_dtfimper AS DATE      FORMAT 99/99/9999     NO-UNDO.
    DEF VAR   aux_contador AS INTEGER   FORMAT "z9"           NO-UNDO.
    DEF VAR   aux_tptaxcdi AS INTEGER   EXTENT 99             NO-UNDO.
    DEF VAR   aux_txadical AS DECIMAL   DECIMALS 8 EXTENT 99  NO-UNDO.
    DEF VAR   aux_vlfaixas AS DECIMAL   EXTENT 99             NO-UNDO.
    DEF VAR   aux_qtdiaute AS INTEGER                         NO-UNDO.
    DEF VAR   aux_qtdtxtab AS INTEGER                         NO-UNDO.
    DEF VAR   aux_vltxadic AS DECIMAL   DECIMALS 8            NO-UNDO.
    DEF VAR   aux_txmespop AS DECIMAL   DECIMALS 8            NO-UNDO.
    DEF VAR   aux_txdiapop AS DECIMAL   DECIMALS 8            NO-UNDO.
    DEF VAR   aux_txofimes AS DECIMAL   DECIMALS 8            NO-UNDO.
    DEF VAR   aux_txofidia AS DECIMAL   DECIMALS 8            NO-UNDO.
    DEF VAR   aux_vlcdimes AS DECIMAL   DECIMALS 8            NO-UNDO.
    
    
    /* VERIFICA SE TAXA SELIC ESTA CADASTRADA */
    
    FIND bf5-crapmfx WHERE bf5-crapmfx.cdcooper = p_cdcooper          AND
                           bf5-crapmfx.dtmvtolt = p_dtperiod          AND
                           bf5-crapmfx.tpmoefix = 19 /* SELIC */
                           NO-LOCK NO-ERROR NO-WAIT.

    IF NOT AVAIL bf5-crapmfx THEN
        DO:
            ASSIGN p_dscritic = "Para cadastrar a TR, primeiro cadastre a SELIC Meta " + 
                                  "para o dia informado".

            RETURN "NOK".
        END.
    
    /* FIM VERIFICACAO */


    FIND bf-crapmfx WHERE bf-crapmfx.cdcooper = p_cdcooper          AND
                          bf-crapmfx.dtmvtolt = p_dtperiod          AND
                          bf-crapmfx.tpmoefix = 11 /* TR */
                          EXCLUSIVE-LOCK NO-ERROR. 
    
    IF   NOT AVAILABLE bf-crapmfx THEN
         DO:
             CREATE bf-crapmfx.
             ASSIGN bf-crapmfx.dtmvtolt = p_dtperiod
                    bf-crapmfx.tpmoefix = 11
                    bf-crapmfx.cdcooper = p_cdcooper.
         END.
    
    ASSIGN bf-crapmfx.vlmoefix = p_vltaxatr.

    ASSIGN aux_vlpoupan = ROUND((((p_vltaxatr / 100) + 1) *  
                                 ((0.5 / 100) + 1)  - 1)  * 100, 8).

    IF bf5-crapmfx.vlmoefix > 8.5 THEN
        DO:
            ASSIGN aux_vlpoupnr = ROUND((((p_vltaxatr / 100) + 1) *  
                                 ((0.5 / 100) + 1)  - 1)  * 100, 8).
        END.
    ELSE
        DO:
            ASSIGN aux_vlpoupnr = ROUND((((p_vltaxatr / 100) + 1) * 
                                  (EXP(((bf5-crapmfx.vlmoefix / 100) * 0.7) + 1, 1 / 12)) - 1)  * 100, 8).
        END.

    RELEASE bf-crapmfx.
        
    FIND bf-crapmfx WHERE bf-crapmfx.cdcooper = p_cdcooper          AND
                          bf-crapmfx.dtmvtolt = p_dtperiod          AND
                          bf-crapmfx.tpmoefix = 20 /* Taxa Poupança Nova Regra */
                          EXCLUSIVE-LOCK NO-ERROR. 
    
    IF   NOT AVAILABLE bf-crapmfx THEN
         DO:
             CREATE bf-crapmfx.
             ASSIGN bf-crapmfx.dtmvtolt = p_dtperiod
                    bf-crapmfx.tpmoefix = 20
                    bf-crapmfx.cdcooper = p_cdcooper.
         END.

    ASSIGN bf-crapmfx.vlmoefix = aux_vlpoupnr.

    RELEASE bf-crapmfx.

    FIND bf2-crapmfx WHERE bf2-crapmfx.cdcooper = p_cdcooper          AND
                           bf2-crapmfx.dtmvtolt = p_dtperiod          AND
                           bf2-crapmfx.tpmoefix = 8 /* Poupança */
                           EXCLUSIVE-LOCK NO-ERROR. 
    
    IF   NOT AVAILABLE bf2-crapmfx THEN
         DO:
             CREATE bf2-crapmfx.
             ASSIGN bf2-crapmfx.dtmvtolt = p_dtperiod
                    bf2-crapmfx.tpmoefix = 8
                    bf2-crapmfx.cdcooper = p_cdcooper.
         END.

    ASSIGN bf2-crapmfx.vlmoefix = aux_vlpoupan.

    RELEASE bf2-crapmfx.

    FIND bf3-crapmfx WHERE bf3-crapmfx.cdcooper = p_cdcooper          AND
                           bf3-crapmfx.dtmvtolt = p_dtperiod          AND
                           bf3-crapmfx.tpmoefix = 16 /* CDI Mensal*/ 
                           NO-LOCK NO-ERROR.

    IF   AVAILABLE bf3-crapmfx THEN
         aux_vlcdimes = bf3-crapmfx.vlmoefix.

    aux_contador = 0.

    FOR EACH bf-craptab WHERE bf-craptab.cdcooper = p_cdcooper      AND
                              bf-craptab.nmsistem = "CRED"          AND
                              bf-craptab.tptabela = "CONFIG"        AND
                              bf-craptab.cdacesso = "TXADIAPLIC"
                              NO-LOCK:
                   
        DO aux_cartaxas = 1 TO NUM-ENTRIES(bf-craptab.dstextab,";"):
        
           ASSIGN aux_vllidtab               =
                                  ENTRY(aux_cartaxas,bf-craptab.dstextab,";")
                  aux_contador               = aux_contador + 1
                  aux_tptaxcdi[aux_contador] = bf-craptab.tpregist
                  aux_txadical[aux_contador] = DEC(ENTRY(2,aux_vllidtab,"#"))
                  aux_vlfaixas[aux_contador] = DEC(ENTRY(1,aux_vllidtab,"#")).
                  
        END.
    END.

    /*  Calcula Quantidade de Dias Uteis e Retorna a Data */
    RUN calcula_qt_dias_uteis (INPUT  p_dtperiod,
                               INPUT  p_cdcooper,
                               OUTPUT aux_qtdiaute,
                               OUTPUT aux_dtfimper).

    DO aux_qtdtxtab = 1 TO aux_contador:
                                             
       FIND FIRST bf-craptrd WHERE bf-craptrd.cdcooper = p_cdcooper   AND
                                   bf-craptrd.dtiniper = p_dtperiod   AND
                                   bf-craptrd.tptaxrda = 
                                           aux_tptaxcdi[aux_qtdtxtab] AND
                                   bf-craptrd.incarenc = 0            AND
                                   bf-craptrd.vlfaixas = aux_vlfaixas[aux_qtdtxtab] 
                                   EXCLUSIVE-LOCK NO-ERROR.

       IF   NOT AVAILABLE bf-craptrd THEN 
            DO:
                CREATE bf-craptrd.
                ASSIGN bf-craptrd.tptaxrda = aux_tptaxcdi[aux_qtdtxtab]
                       bf-craptrd.dtiniper = p_dtperiod
                       bf-craptrd.dtfimper = aux_dtfimper            
                       bf-craptrd.qtdiaute = aux_qtdiaute
                       bf-craptrd.vlfaixas = aux_vlfaixas[aux_qtdtxtab]
                       bf-craptrd.incarenc = 0                         
                       bf-craptrd.incalcul = 0                         
                       bf-craptrd.cdcooper = p_cdcooper.
            END.
                   
       IF aux_tptaxcdi[aux_qtdtxtab] = 4 THEN

        RUN calcula_poupanca (INPUT  p_cdcooper,
                              INPUT  aux_qtdiaute,
                              INPUT  aux_vlpoupnr, /*Taxa Nova Regra*/
                              OUTPUT aux_txmespop,
                              OUTPUT aux_txdiapop).
       ELSE
        RUN calcula_poupanca (INPUT  p_cdcooper,
                              INPUT  aux_qtdiaute,
                              INPUT  aux_vlpoupan, /*Taxa Regra Antiga*/
                              OUTPUT aux_txmespop,

                              OUTPUT aux_txdiapop).
       /*  Calculo do CDI para comparar com a Poupanca */
       IF   AVAILABLE bf3-crapmfx THEN
            DO:
                ASSIGN aux_vltxadic = aux_txadical[aux_qtdtxtab]
                       aux_txofimes = 
                                ROUND(((aux_vlcdimes * aux_vltxadic) / 100),6)
                       aux_txofidia = 
                                ROUND(((EXP(1 + (aux_txofimes / 100),
                                            1 / aux_qtdiaute) - 1) * 100),6).
                                         
                ASSIGN bf-craptrd.vltrapli =  
                                        IF   aux_txofimes < aux_txmespop THEN
                                             aux_vlpoupan           
                                        ELSE 
                                             aux_vlcdimes
                                             
                       bf-craptrd.txofimes = 
                                        IF   aux_txofimes < aux_txmespop THEN
                                             aux_txmespop
                                        ELSE 
                                             aux_txofimes
                                             
                       bf-craptrd.txofidia = 
                                        IF   aux_txofidia < aux_txdiapop THEN
                                             aux_txdiapop
                                        ELSE 
                                             aux_txofidia.
            END.
       ELSE
            ASSIGN bf-craptrd.vltrapli = aux_vlpoupan           
                   bf-craptrd.txofimes = aux_txmespop
                   bf-craptrd.txofidia = aux_txdiapop.
              
       RELEASE bf-craptrd.

    END.
    
    ASSIGN p_vlpoupan = IF aux_tptaxcdi[aux_qtdtxtab] = 4 THEN aux_vlpoupnr ELSE aux_vlpoupan.

    RETURN "OK".

END PROCEDURE.


PROCEDURE atualiza_sol026:

    DEF INPUT PARAM p_cdcooper  AS INT                          NO-UNDO.
    DEF INPUT PARAM p_dtperiod  AS DATE                         NO-UNDO.
    DEF INPUT PARAM p_vlpoupan  AS DEC                          NO-UNDO.
    
    DEF VAR   aux_dtcalcul      AS DATE                         NO-UNDO.
    DEF VAR   aux_contador      AS INT   FORMAT "z9"            NO-UNDO.

    DEF VAR   aux_dstextab      AS CHAR                         NO-UNDO.
    DEF VAR   tel_tpcalcul      AS INT   FORMAT "9"             NO-UNDO.
    DEF VAR   ant_tpcalcul      AS INT   FORMAT "9"             NO-UNDO.
    DEF VAR   ant_txjurcap      AS DEC   DECIMALS 8 EXTENT 12   NO-UNDO.
    DEF VAR   tel_txjurcap      AS DEC   DECIMALS 8 EXTENT 12   NO-UNDO.

    IF   p_dtperiod = DATE(MONTH(p_dtperiod),01,YEAR(p_dtperiod)) THEN 
         DO:
             /* Atualizar a taxa de Poupança para todas as Cooperativas */
             
             FIND bf-craptab WHERE bf-craptab.cdcooper = p_cdcooper   AND
                                   bf-craptab.nmsistem = "CRED"       AND
                                   bf-craptab.tptabela = "GENERI"     AND
                                   bf-craptab.cdempres = 00           AND
                                   bf-craptab.cdacesso = "EXEJUROCAP" AND
                                   bf-craptab.tpregist = 001
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

             IF   NOT AVAILABLE bf-craptab THEN 
                  DO:
                      ASSIGN aux_cdcritic = 0
                             aux_dscritic = 
                                      "Tabela EXEJUROCAP em uso ou nao existe.".

                      RUN gera_erro (INPUT p_cdcooper,
                                     INPUT 1,  /*  PAC  */
                                     INPUT 1,  /*  Caixa  */
                                     INPUT 1,  /*  Sequencia  */
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).

                      RETURN "NOK".
                  END.  
                        
             ASSIGN aux_dstextab = SUBSTR(bf-craptab.dstextab,5,200)
                    tel_tpcalcul = INT(SUBSTR(bf-craptab.dstextab,1,1))
                    ant_tpcalcul = tel_tpcalcul.

             DO aux_contador = 1 TO NUM-ENTRIES(aux_dstextab,";"):
                     
                ASSIGN tel_txjurcap[aux_contador] = 
                             DEC(ENTRY(aux_contador,aux_dstextab,";"))
                       ant_txjurcap[aux_contador] = 
                             DEC(ENTRY(aux_contador,aux_dstextab,";")).

                IF  MONTH(p_dtperiod) = aux_contador THEN
                    ASSIGN tel_txjurcap[aux_contador] = p_vlpoupan
                           ant_txjurcap[aux_contador] = p_vlpoupan.

             END.  /*  Fim do DO .. TO  */
    
             ASSIGN SUBSTR(bf-craptab.dstextab,1,001) = STRING(tel_tpcalcul)
                    SUBSTR(bf-craptab.dstextab,5,200) = "".

             DO aux_contador = 1 TO 12:
                        
                SUBSTR(bf-craptab.dstextab,5,200) =
                          SUBSTR(bf-craptab.dstextab,5,200) +
                          STRING(tel_txjurcap[aux_contador],"999.999999") +
                          IF   aux_contador <> 12 THEN 
                               ";"
                          ELSE "" .
                        
             END.  /*  Fim do DO .. TO  */

             RELEASE bf-craptab.

         END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE atualiza_tr:
        
    DEFINE INPUT PARAM p_cdcooper AS INT                              NO-UNDO.
    DEFINE INPUT PARAM p_dtperiod AS DATE    FORMAT "99/99/9999"      NO-UNDO.
    DEFINE INPUT PARAM p_txrefmes AS DECIMAL FORMAT "zzz9.99999999"   NO-UNDO.

    DEFINE VARIABLE aux_qtdiaute AS INTEGER                           NO-UNDO.
    DEFINE VARIABLE aux_dtfimper AS DATE     FORMAT "99/99/9999"      NO-UNDO.
    DEFINE VARIABLE aux_txjurfix AS DECIMAL  DECIMALS 8               NO-UNDO.
    DEFINE VARIABLE aux_txjurvar AS DECIMAL  DECIMALS 8               NO-UNDO.
    DEFINE VARIABLE aux_txmensal AS DECIMAL  DECIMALS 8               NO-UNDO.
    DEFINE VARIABLE aux_txminima AS DECIMAL  DECIMALS 8               NO-UNDO.
    DEFINE VARIABLE aux_txmaxima AS DECIMAL  DECIMALS 8               NO-UNDO.
    DEFINE VARIABLE aux_txdiaria AS DECIMAL  DECIMALS 8               NO-UNDO.


    IF   p_dtperiod = DATE(MONTH(p_dtperiod),01,YEAR(p_dtperiod)) AND
         p_cdcooper <> 3                                          THEN 
         DO:
             FIND bf-craptab WHERE bf-craptab.cdcooper = p_cdcooper         AND
                                   bf-craptab.nmsistem = "CRED"             AND
                                   bf-craptab.tptabela = "GENERI"           AND
                                   bf-craptab.cdempres = 0                  AND
                                   bf-craptab.cdacesso = "TAXASDOMES"       AND
                                   bf-craptab.tpregist = 001 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
             IF   NOT AVAILABLE bf-craptab THEN
                  DO:
                      ASSIGN aux_cdcritic = 0
                             aux_dscritic = 
                                  "Tabela TAXASDOMES em uso ou nao existe.".
            
                      RUN gera_erro (INPUT p_cdcooper,
                                     INPUT 1,  /*  PAC  */
                                     INPUT 1,  /*  Caixa  */
                                     INPUT 1,  /*  Sequencia  */
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).

                      RETURN "NOK".
                  END.
    
             /*   Calcula Quantidade de Dias Uteis e Retorna a Data   */
             RUN calcula_qt_dias_uteis (INPUT  p_dtperiod,
                                        INPUT  p_cdcooper,
                                        OUTPUT aux_qtdiaute,
                                        OUTPUT aux_dtfimper).

             ASSIGN SUBSTR(bf-craptab.dstextab,03,10) = 
                              STRING(p_txrefmes,"999.999999")
                    SUBSTR(bf-craptab.dstextab,25,08) = 
                              STRING(p_dtperiod,"99999999")
                    SUBSTR(bf-craptab.dstextab,34,08) = 
                              STRING(aux_dtfimper,"99999999").

         
             /*  Atualizando a taxa de juros para o cheque especial  */

             FOR EACH craplrt WHERE craplrt.cdcooper = p_cdcooper
                                    EXCLUSIVE-LOCK:
    
                  ASSIGN craplrt.txmensal = 
                       ROUND(((p_txrefmes * (craplrt.txjurvar / 100) + 100) *
                              (1 + (craplrt.txjurfix / 100)) - 100),6).

             END. /*  Fim da atualizacao da taxa de juros para chq. especial */


             /*  Atualizando a taxa de juros para o saque s/bloqueado */

             FIND FIRST bf2-craptab WHERE 
                        bf2-craptab.cdcooper = p_cdcooper   AND
                        bf2-craptab.nmsistem = "CRED"       AND
                        bf2-craptab.tptabela = "USUARI"     AND
                        bf2-craptab.cdempres = 11           AND
                        bf2-craptab.cdacesso = "JUROSSAQUE" AND
                        bf2-craptab.tpregist = 1 
                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

             IF   AVAILABLE bf2-craptab THEN
                  ASSIGN aux_txjurfix = DEC(SUBSTR(bf2-craptab.dstextab,12,06))
                         aux_txjurvar = DEC(SUBSTR(bf2-craptab.dstextab,19,06))
                         aux_txmensal = ROUND(((p_txrefmes * 
                                      (aux_txjurvar / 100) + 100) * 
                                      (1 + (aux_txjurfix / 100)) - 100),6)
               
                         bf2-craptab.dstextab =
                                       STRING(aux_txmensal,"999.999999") +
                                       SUBSTR(bf2-craptab.dstextab,11,14).

             /*  Atualizando taxa de juros para os saldos negativos - MULTA  */

             FIND bf3-craptab WHERE 
                  bf3-craptab.cdcooper = p_cdcooper          AND
                  bf3-craptab.nmsistem = "CRED"              AND
                  bf3-craptab.tptabela = "USUARI"            AND
                  bf3-craptab.cdempres = 11                  AND
                  bf3-craptab.cdacesso = "JUROSNEGAT"        AND
                  bf3-craptab.tpregist = 1 
                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
  
             IF   AVAILABLE bf3-craptab THEN
                  ASSIGN aux_txjurfix = DEC(SUBSTR(bf3-craptab.dstextab,12,06))
                         aux_txjurvar = DEC(SUBSTR(bf3-craptab.dstextab,19,06))
    
                         aux_txmensal = ROUND(((p_txrefmes * 
                                      (aux_txjurvar / 100) + 100) *
                                      (1 + (aux_txjurfix / 100)) - 100),6)
    
                         bf3-craptab.dstextab = 
                                   STRING(aux_txmensal,"999.999999") +
                                   SUBSTRING(bf3-craptab.dstextab,11,14).

             /*  Alterando as linhas de credito  */

             FOR EACH craplcr WHERE craplcr.cdcooper = p_cdcooper
                                    EXCLUSIVE-LOCK:

                 IF   craplcr.cdcooper = 4  AND 
                     (craplcr.cdlcremp = 4  OR 
                      craplcr.cdlcremp = 5  OR 
                      craplcr.cdlcremp = 6) THEN
                      NEXT.
        
                 ASSIGN aux_txjurfix = craplcr.txjurfix
                        aux_txjurvar = craplcr.txjurvar
                        aux_txminima = craplcr.txminima
                        aux_txmaxima = craplcr.txmaxima

                        aux_txmensal = ROUND(((p_txrefmes * 
                                     (aux_txjurvar / 100) + 100) *
                                     (1 + (aux_txjurfix / 100)) - 100),6)

                        aux_txmensal = IF   aux_txminima > aux_txmensal THEN
                                            aux_txminima
                                       ELSE 
                                       IF   aux_txmaxima > 0 AND
                                            aux_txmaxima < aux_txmensal THEN
                                            aux_txmaxima
                                       ELSE 
                                            aux_txmensal
                              
                        aux_txdiaria = ROUND(aux_txmensal / 3000,7)

                        craplcr.txmensal = aux_txmensal
                        craplcr.txdiaria = aux_txdiaria.

             END.  /*  Fim do FOR EACH  -- Atualizar linhas de credito  */

    END.

    RETURN "OK".

END PROCEDURE.



PROCEDURE calcula_poupanca:

   DEF INPUT  PARAMETER p_cdcooper   AS INTE                 NO-UNDO.
   DEF INPUT  PARAMETER aux_qtdiaute AS INTE                 NO-UNDO.
   DEF INPUT  PARAMETER aux_vlmoefix LIKE crapmfx.vlmoefix   NO-UNDO.
   DEF OUTPUT PARAMETER aux_txmespop AS DECIMAL DECIMALS 8   NO-UNDO.
   DEF OUTPUT PARAMETER aux_txdiapop AS DECIMAL DECIMALS 8   NO-UNDO.

   DEF VAR aux_vllidtab AS CHAR                              NO-UNDO.
   DEF VAR aux_qtdfaxir AS INT  FORMAT "z9"                  NO-UNDO.
   DEF VAR aux_qtmestab AS INTE EXTENT 99                    NO-UNDO.
   DEF VAR aux_perirtab AS DEC  EXTENT 99 DECIMALS 8         NO-UNDO.
   DEF VAR aux_cartaxas AS INTE                              NO-UNDO.
   
   ASSIGN aux_vllidtab = ""
          aux_qtdfaxir = 0
          aux_qtmestab = 0
          aux_perirtab = 0.


   FIND craptab WHERE craptab.cdcooper = p_cdcooper   AND
                      craptab.nmsistem = "CRED"       AND
                      craptab.cdempres = 0            AND
                      craptab.tptabela = "CONFIG"     AND
                      craptab.cdacesso = "PERCIRRDCA" AND
                      craptab.tpregist = 0            NO-LOCK NO-ERROR.

   DO aux_cartaxas = 1 TO NUM-ENTRIES(craptab.dstextab,";"):
      ASSIGN aux_vllidtab = ENTRY(aux_cartaxas,craptab.dstextab,";")
             aux_qtdfaxir = aux_qtdfaxir + 1
             aux_qtmestab[aux_qtdfaxir] = DECIMAL(ENTRY(1,aux_vllidtab,"#"))
             aux_perirtab[aux_qtdfaxir] = DECIMAL(ENTRY(2,aux_vllidtab,"#")).
   END.

   ASSIGN aux_txmespop = ROUND(aux_vlmoefix / (1 - (aux_perirtab[1] / 100)),6)
          aux_txdiapop = ROUND(((EXP(1 + (aux_txmespop / 100),
                                1 / aux_qtdiaute) - 1) * 100),6).
                                
END PROCEDURE.



PROCEDURE calcula_dia_util:

    /*  Busca o dia útil anterior ao sábado, domingo ou feriado   */

    DEFINE INPUT  PARAM p_dtmvtolt AS DATE                     NO-UNDO.
    DEFINE INPUT  PARAM p_cdcooper LIKE crapdat.cdcooper       NO-UNDO. 
    DEFINE OUTPUT PARAM p_dtcalcul AS DATE                     NO-UNDO.

    DEFINE VARIABLE aux_dtcalcul   AS DATE                     NO-UNDO.

    aux_dtcalcul = p_dtmvtolt.

    DO WHILE TRUE:
    
       IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtcalcul)))                   OR
            CAN-FIND(FIRST crapfer WHERE crapfer.cdcooper = p_cdcooper    AND
                                         crapfer.dtferiad = aux_dtcalcul) THEN
            DO:
                aux_dtcalcul = aux_dtcalcul - 1.
                NEXT.
            END.
        
        LEAVE.
    
    END.  /*  Fim do DO WHILE TRUE  */

    p_dtcalcul = aux_dtcalcul.

END PROCEDURE.

 
PROCEDURE calcula_primeiro_dia_util:

    /*  Busca o primeiro dia útil do mês.   */

    DEFINE INPUT  PARAM p_dtmvtolt AS DATE                     NO-UNDO.
    DEFINE INPUT  PARAM p_cdcooper LIKE crapdat.cdcooper       NO-UNDO. 
    DEFINE OUTPUT PARAM p_dtcalcul AS DATE                     NO-UNDO.

    DEFINE VARIABLE aux_dtcalcul   AS DATE                     NO-UNDO.
    
    
    ASSIGN aux_dtcalcul = DATE(MONTH(p_dtmvtolt),01,YEAR(p_dtmvtolt)).
    
    DO WHILE TRUE:
        
       IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtcalcul)))                   OR
            CAN-FIND(FIRST crapfer WHERE crapfer.cdcooper = p_cdcooper    AND
                                         crapfer.dtferiad = aux_dtcalcul) THEN
            DO:
                aux_dtcalcul = aux_dtcalcul + 1.
                NEXT.
            END.

       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    p_dtcalcul = aux_dtcalcul.

END PROCEDURE.

               
PROCEDURE calcula_qt_dias_uteis:

    DEFINE INPUT  PARAMETER p_data          AS DATE                    NO-UNDO.
    DEFINE INPUT  PARAMETER p_cdcooper      LIKE crapdat.cdcooper      NO-UNDO. 
    DEFINE OUTPUT PARAMETER p_qt_dias_uteis AS INT                     NO-UNDO.
    DEFINE OUTPUT PARAMETER p_dtfimper      AS DATE  FORMAT 99/99/9999 NO-UNDO.
    
    DEFINE VARIABLE aux_dtmvtolt AS DATE                               NO-UNDO.
    DEFINE VARIABLE aux_qtdiaute AS INTEGER                            NO-UNDO.

    /*   Cálculo dos dias úteis   */
    RUN fontes/calcdata.p (INPUT p_data,       /* Inicio Periodo */
                           INPUT 1,
                           INPUT "M",          /* CDI Mensal */
                           INPUT 0,
                           OUTPUT p_dtfimper). /* Fim Periodo */
         
    ASSIGN aux_dtmvtolt = p_data
           aux_qtdiaute = 0.
    
    DO WHILE aux_dtmvtolt < p_dtfimper:
    
       IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt)))        OR
            CAN-FIND(FIRST bf-crapfer WHERE 
                           bf-crapfer.cdcooper = p_cdcooper    AND
                           bf-crapfer.dtferiad = aux_dtmvtolt) THEN
            .
       ELSE 
            aux_qtdiaute = aux_qtdiaute + 1.
        
       aux_dtmvtolt = aux_dtmvtolt + 1.
    
    END.  /*  Fim do DO WHILE TRUE  */

    ASSIGN p_qt_dias_uteis = aux_qtdiaute.

END PROCEDURE.
/*............................................................................*/
