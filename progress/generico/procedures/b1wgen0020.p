
/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------------+-------------------------------------------+
  | Rotina Progress                       | Rotina Oracle PLSQL                       |
  +---------------------------------------+-------------------------------------------+
  | b1wgen0020.p (Variaveis)              | EXTR0001                                  |
  | extrato_investimento                  | EXTR0002.pc_extrato_investimento          |        
  | obtem-saldo-investimento              | CADA0004.fn_saldo_invetimento             |         
  +---------------------------------------+-------------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*..............................................................................

   Programa: b1wgen0020.p
   Autor   : Murilo/David
   Data    : Setembro/2007                     Ultima atualizacao: 27/08/2015

   Adaptação do programa: fontes/sciresg.p

   Objetivo  : BO CONTA INVESTIMENTO

   Alteracoes: 12/11/2007 - Gerar log nas procedures (David).

               19/02/2008 - Procedure para obter saldo da conta investimento 
                            (David). 

               03/06/2008 - Incluir cdcooper nos FIND's da craphis (David).
               
               29/09/2008 - Verificar bloqueio de aplicacao para emprestimo
                            quando tentar efetuar resgate (David).
                            
               10/11/2008 - Limpar variaveis de erro (Guilherme).              
                             
               19/08/2009 - Acerto na geracao de log e liberacao de registros 
                            em LOCK (David).
 
               23/11/2009 - Alteracao Codigo Historico (Kbase).
               
               16/09/2011 - Alteração na leitura dos lançamentos na proc.
                            extrato_investimento. Adicionado tratamento 
                            para retorno do campo dshistor para tela IMPRES
                            (Gabriel Capoia - DB1)
                          - Incluir parametro para geracao de log na procedure
                            extrato_investimento (David).
                            
               03/10/2012 - Incluir campo dsextrat na tt-extrato_inv (Lucas R.).
                             
               19/12/2013 - Adicionado validate para as tabelas craplot,
                            craplcm, craplci (Tiago).
                            
               01/09/2014 - Procedure extrato_investimento alterada para tratar
                            o bloqueio de lancamentos de aplicacoes de captacao.
                            (Reinert)
                            
               03/09/2014 - Procedure obtem-resgate alterada para tratar o 
                            bloqueio de resgates de lancamentos de aplicacoes de
                            captacao. (Reinert)
                            
               01/10/2014 - Alterado para quando o saldo de resgate estiver atrelado com 
                            emprestimo, não exibir mais a mensagem de confirmacao. Sempre
                            bloquear. (Douglas - Projeto Captação Internet 2014/2).
                            
               27/08/2015 - Ajuste para verificar antes de transferir valor da conta 
                            investimento para a conta corrente, caso haja bloqueio
                            judicial, deixar apenas valor excedente do bloqueio.
                            (Jorge/Gielow) - SD 310965             
                            
               01/12/2017 - Alterar obtem-resgate para utilizar rotina para validar bloqueios             
                            PRJ404-Garantia(Odirlei-AMcom)
..............................................................................*/


/*................................ DEFINICOES ................................*/


{ sistema/generico/includes/b1wgen0020tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.


/*............................ PROCEDURES EXTERNAS ...........................*/


/******************************************************************************/
/**             Procedure para obter saldo da conta investimento             **/
/******************************************************************************/
PROCEDURE obtem-saldo-investimento:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-saldo-investimento.
    
    EMPTY TEMP-TABLE tt-saldo-investimento.
        
    FIND crapsli WHERE crapsli.cdcooper  = par_cdcooper        AND
                       crapsli.nrdconta  = par_nrdconta        AND
                 MONTH(crapsli.dtrefere) = MONTH(par_dtmvtolt) AND
                  YEAR(crapsli.dtrefere) = YEAR(par_dtmvtolt)
                       NO-LOCK NO-ERROR.
                                   
    CREATE tt-saldo-investimento.
    ASSIGN tt-saldo-investimento.vlsldinv = IF  AVAILABLE crapsli  THEN
                                                crapsli.vlsddisp
                                            ELSE
                                                0.
                                                
    RETURN "OK".                                            
        
END PROCEDURE.


/******************************************************************************/
/**          Procedure para consultar extrato da conta investimento          **/
/******************************************************************************/
PROCEDURE extrato_investimento:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_vlsldant AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-extrato_inv.

    DEF BUFFER crabhis FOR craphis.
    
    DEF VAR aux_vlsldtot AS DECI INIT 0                             NO-UNDO.
    DEF VAR aux_flgavlap AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_cdbloque AS CHAR                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-extrato_inv.

    /** Atribui descricao da origem e da transacao **/
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar extrato da conta investimento".
           
    /** Calcula o valor do saldo ate o periodo solicitado **/
    FOR EACH craplci WHERE craplci.cdcooper = par_cdcooper AND
                           craplci.nrdconta = par_nrdconta AND
                           craplci.dtmvtolt < par_dtiniper NO-LOCK:

        FIND craphis WHERE craphis.cdcooper = par_cdcooper     AND
                           craphis.cdhistor = craplci.cdhistor NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE craphis   THEN
             NEXT.
         
        IF   craphis.indebcre = "C" THEN
             aux_vlsldtot = aux_vlsldtot + craplci.vllanmto.
        ELSE
        IF   craphis.indebcre = "D"  THEN
             aux_vlsldtot = aux_vlsldtot - craplci.vllanmto.

    END. /** Fim do FOR EACH craplci - Calcular saldo **/

    ASSIGN par_vlsldant = aux_vlsldtot.

    EMPTY TEMP-TABLE tt-extrato_inv.

    /** Leitura dos lancamentos **/
    FOR EACH craplci WHERE craplci.cdcooper  = par_cdcooper AND
                           craplci.nrdconta  = par_nrdconta AND
                           craplci.dtmvtolt >= par_dtiniper AND
                           craplci.dtmvtolt <= par_dtfimper 
                           USE-INDEX craplci2 NO-LOCK,
        FIRST craphis WHERE craphis.cdcooper = par_cdcooper     AND
                            craphis.cdhistor = craplci.cdhistor NO-LOCK
                            BREAK BY craplci.dtmvtolt
                                     BY craplci.nrdocmto
                                        BY craphis.indebcre:
                         
        ASSIGN aux_cdbloque = ""
               aux_flgavlap = FALSE.
        
        FOR EACH craplap WHERE craplap.cdcooper = par_cdcooper     AND
                               craplap.dtmvtolt = craplci.dtmvtolt AND
                               craplap.nrdconta = craplci.nrdconta AND
                               craplap.vllanmto = craplci.vllanmto 
                               USE-INDEX craplap2 NO-LOCK:

            FIND crabhis WHERE crabhis.cdcooper = par_cdcooper     AND
                               crabhis.cdhistor = craplap.cdhistor
                               NO-LOCK NO-ERROR.
           
            IF  crabhis.indebcre <> "D"  THEN
                NEXT.
    
            FIND FIRST craptab WHERE 
                       craptab.cdcooper = par_cdcooper             AND
                       craptab.nmsistem = "CRED"                   AND
                       craptab.tptabela = "BLQRGT"                 AND
                       craptab.cdempres = 00                       AND
                       craptab.cdacesso = STRING(craplap.nrdconta,
                                                 "9999999999")     AND
                       INTE(SUBSTR(craptab.dstextab,1,7)) = craplap.nraplica
                       NO-LOCK NO-ERROR.
        
            IF  AVAILABLE craptab  THEN 
                ASSIGN aux_cdbloque = "B"
                       aux_flgavlap = TRUE.
        
        END. /** Fim do FOR EACH craplap **/

        IF  aux_flgavlap = FALSE THEN
            DO:
                FOR EACH craplac FIELDS (cdcooper nrdconta nraplica cdhistor)
                                  WHERE craplac.cdcooper = par_cdcooper     AND
                                        craplac.dtmvtolt = craplci.dtmvtolt AND
                                        craplac.cdagenci = 1                AND
                                        craplac.cdbccxlt = 100              AND
                                        craplac.nrdolote = 8504             AND
                                        craplac.nrdconta = craplci.nrdconta AND
                                        craplac.vllanmto = craplci.vllanmto NO-LOCK:

                    FOR FIRST crabhis FIELDS (indebcre)
                        WHERE crabhis.cdcooper = par_cdcooper AND
                              crabhis.cdhistor = craplac.cdhistor NO-LOCK: END.
                
                    IF  NOT AVAIL crabhis OR crabhis.indebcre <> "D"  THEN
                        NEXT.
                                    
                    FOR FIRST craprac FIELDS (idblqrgt)
                        WHERE craprac.cdcooper = craplac.cdcooper AND
                              craprac.nrdconta = craplac.nrdconta AND
                              craprac.nraplica = craplac.nraplica NO-LOCK: END.
                
                    IF  AVAIL craprac AND craprac.idblqrgt > 0  THEN
                        ASSIGN aux_cdbloque = "B". 

                END.

            END.        

        IF   craphis.indebcre = "C" THEN
             aux_vlsldtot = aux_vlsldtot + craplci.vllanmto.
        ELSE
        IF   craphis.indebcre = "D"  THEN
             aux_vlsldtot = aux_vlsldtot - craplci.vllanmto.

        /** Criacao da tabela **/
        CREATE tt-extrato_inv.
        ASSIGN tt-extrato_inv.dtmvtolt = craplci.dtmvtolt
               tt-extrato_inv.dshistor = IF par_nmdatela <> "IMPRES" THEN
                                         STRING(craplci.cdhistor,"9999") + "-" +
                                         craphis.dshistor
                                         ELSE craphis.dshistor
               tt-extrato_inv.nrdocmto = craplci.nrdocmto
               tt-extrato_inv.indebcre = craphis.indebcre
               tt-extrato_inv.vllanmto = craplci.vllanmto
               tt-extrato_inv.vlsldtot = aux_vlsldtot
               tt-extrato_inv.cdbloque = aux_cdbloque
               tt-extrato_inv.dsextrat = craphis.dsextrat.

    END. /** Fim do FOR EACH craplci **/

    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
                       
    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**            Procedure para gerar resgate na conta investimento            **/
/******************************************************************************/
PROCEDURE obtem-resgate:
   
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlresgat AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_inconfir AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
        
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_dsmensag AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_vlblqjud AS DECI FORMAT "zzz,zzz,zz9.99"            NO-UNDO.
    DEF VAR aux_vlresblq AS DECI FORMAT "zzz,zzz,zz9.99"            NO-UNDO.
    DEF VAR aux_vlresgok AS DECI FORMAT "zzz,zzz,zz9.99"            NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma.
    
    /** Atribui descricao da origem e da transacao **/
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Cadastrar resgate na conta investimento"
           aux_flgtrans = FALSE.
           
    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
        
        /* Verificar bloqueio judicial */

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_retorna_valor_blqjud 
            aux_handproc = PROC-HANDLE NO-ERROR
                             (INPUT par_cdcooper /* pr_cdcooper --Cooperativa */
                             ,INPUT par_nrdconta /* pr_nrdconta --Conta */
                             ,INPUT 0 /* pr_nrcpfcgc fixo       --Cpf/cnpj */
                             ,INPUT 1 /* pr_cdtipmov bloqueio   --Tipo Movimento */
                             ,INPUT 2 /* pr_cdmodali aplicacao  --Modalidade */
                             ,INPUT par_dtmvtolt /* pr_dtmvtolt --Data Atual */
                            ,OUTPUT 0 /* pr_vlbloque --Valor Bloqueado */
                            ,OUTPUT 0 /* pr_vlresblq --Valor Residual */
                            ,OUTPUT "" /* pr_dscritic --Critica */).
    
        CLOSE STORED-PROC pc_retorna_valor_blqjud
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_cdcritic = 0
               aux_dscritic = ""
               aux_vlblqjud = pc_retorna_valor_blqjud.pr_vlbloque 
                              WHEN pc_retorna_valor_blqjud.pr_vlbloque <> ?
               aux_vlresblq = pc_retorna_valor_blqjud.pr_vlresblq 
                              WHEN pc_retorna_valor_blqjud.pr_vlresblq <> ?
               aux_dscritic = pc_retorna_valor_blqjud.pr_dscritic
                              WHEN pc_retorna_valor_blqjud.pr_dscritic <> ?
               aux_vlblqjud = ROUND(aux_vlblqjud,2)
               aux_vlresblq = ROUND(aux_vlresblq,2).
            
        IF  aux_cdcritic <> 0   OR
            aux_dscritic <> ""  THEN
            DO:                                  
                CREATE tt-erro.
                ASSIGN tt-erro.cdcritic = aux_cdcritic
                       tt-erro.dscritic = aux_dscritic.
    
                RETURN "NOK".
            END.

        /* Fim verificar bloquei Judicial */

        DO aux_contador = 1 TO 10:
    
            FIND crapsli WHERE crapsli.cdcooper  = par_cdcooper        AND
                               crapsli.nrdconta  = par_nrdconta        AND
                         MONTH(crapsli.dtrefere) = MONTH(par_dtmvtolt) AND
                          YEAR(crapsli.dtrefere) = YEAR(par_dtmvtolt)  AND
                               crapsli.vlsddisp  > 0                    
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            IF  LOCKED crapsli  THEN
                DO:
                    aux_dscritic = "Registro de conta investimento esta " +
                                   "sendo alterado. Tente Novamente.". 
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
            ELSE
            IF  NOT AVAILABLE crapsli OR crapsli.vlsddisp < par_vlresgat  THEN
                DO:
                    aux_dscritic = "Nao ha saldo suficiente na Conta de " + 
                                   "Investimento.".
                    LEAVE.
                END.
            ELSE
            DO:
                  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                  /* Efetuar a chamada a rotina Oracle */ 
                  RUN STORED-PROCEDURE pc_ver_bloqueio_aplica_prog
                     aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper,  /* pr_cdcooper */
                                                         INPUT par_cdagenci,  /* pr_cdagenci */
                                                         INPUT par_nrdcaixa,  /* pr_nrdcaixa */
                                                         INPUT par_cdoperad,  /* pr_cdoperad */
                                                         INPUT par_nmdatela,  /* pr_nmdatela */
                                                         INPUT par_idorigem,  /* pr_idorigem */
                                                         INPUT par_nrdconta,  /* pr_nrdconta */
                                                         INPUT 0,             /* pr_nraplica */
                                                         INPUT par_idseqttl,  /* pr_idseqttl */
                                                         INPUT par_nmdatela,  /* pr_cdprogra */
                                                         INPUT par_dtmvtolt,  /* pr_dtmvtolt */
                                                         INPUT par_vlresgat,  /* pr_vlresgat */
                                                         INPUT 0,             /* pr_flgerlog */
                                                         INPUT 0,             /* pr_innivblq */
                                                         INPUT 0,             /* pr_vlsldinv */                                                                              
                                                         OUTPUT 0,
                                                         OUTPUT "").

                  /* Fechar o procedimento para buscarmos o resultado */ 
                  CLOSE STORED-PROC pc_ver_bloqueio_aplica_prog
                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                  /* Busca possíveis erros */ 
                  ASSIGN aux_cdcritic = 0
                         aux_dscritic = ""
                         aux_cdcritic = pc_ver_bloqueio_aplica_prog.pr_cdcritic 
                                        WHEN pc_ver_bloqueio_aplica_prog.pr_cdcritic <> ?
                         aux_dscritic = pc_ver_bloqueio_aplica_prog.pr_dscritic 
                                        WHEN pc_ver_bloqueio_aplica_prog.pr_dscritic <> ?.
                  
                  IF aux_cdcritic <> 0 OR
                     aux_dscritic <> "" THEN
                   DO:
                        LEAVE.
                   END.
            
            END.

            aux_dscritic = "".
        
            LEAVE.
        
        END. /** Fim do DO ... TO **/
            
        IF  aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                   
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                               
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  par_inconfir = 1  THEN
            DO:
                FOR EACH craplci WHERE craplci.cdcooper  = par_cdcooper AND
                                       craplci.dtmvtolt >= par_dtmvtolt AND
                                       craplci.nrdconta  = par_nrdconta 
                                       USE-INDEX craplci2 NO-LOCK:
                    FOR EACH craplap WHERE craplap.cdcooper = par_cdcooper     AND
                                           craplap.dtmvtolt = craplci.dtmvtolt AND
                                           craplap.nrdconta = craplci.nrdconta AND
                                           craplap.vllanmto = craplci.vllanmto 
                                           USE-INDEX craplap2 NO-LOCK:

                        FIND craphis WHERE craphis.cdcooper = par_cdcooper     AND
                                           craphis.cdhistor = craplap.cdhistor
                                           NO-LOCK NO-ERROR.
    
                        IF  craphis.indebcre <> "D"  THEN
                            NEXT.
        
                        FIND FIRST craptab WHERE 
                                   craptab.cdcooper = par_cdcooper             AND
                                   craptab.nmsistem = "CRED"                   AND
                                   craptab.tptabela = "BLQRGT"                 AND
                                   craptab.cdempres = 00                       AND
                                   craptab.cdacesso = STRING(craplap.nrdconta,
                                                             "9999999999")     AND
                                   INTE(SUBSTR(craptab.dstextab,1,7)) = 
                                               craplap.nraplica
                                   NO-LOCK NO-ERROR.
            
                        IF  AVAILABLE craptab  THEN 
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Saldo de resgate atrelado com " +
                                                      "emprestimo.".
                                                            
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,            /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                   
                                UNDO TRANSACAO, RETURN "NOK".
                            END.

                    END. /* Fim do FOR EACH craplap  */

                    FOR EACH craplac FIELDS (cdcooper nrdconta nraplica cdhistor)
                                      WHERE craplac.cdcooper = par_cdcooper     AND
                                            craplac.dtmvtolt = craplci.dtmvtolt AND
                                            craplac.cdagenci = 1                AND
                                            craplac.cdbccxlt = 100              AND
                                            craplac.nrdolote = 8504             AND
                                            craplac.nrdconta = craplci.nrdconta AND
                                            craplac.vllanmto = craplci.vllanmto NO-LOCK:
    
                        FOR FIRST craphis FIELDS (indebcre)
                            WHERE craphis.cdcooper = par_cdcooper AND
                                  craphis.cdhistor = craplac.cdhistor NO-LOCK: END.
                    
                        IF  NOT AVAIL craphis OR craphis.indebcre <> "D"  THEN
                            NEXT.
                                        
                        FOR FIRST craprac FIELDS (idblqrgt)
                            WHERE craprac.cdcooper = craplac.cdcooper AND
                                  craprac.nrdconta = craplac.nrdconta AND
                                  craprac.nraplica = craplac.nraplica NO-LOCK: END.
                    
                        IF  AVAIL craprac AND craprac.idblqrgt > 0  THEN
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Saldo de resgate atrelado com " +
                                                      "emprestimo.".
    
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,            /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
    
                                UNDO TRANSACAO, RETURN "NOK".
                            END.    

                    END. /* Fim do FOR EACH craplac  */
    
                END. /** Fim do FOR EACH craplci**/
            END.
            
        /** Gera lancamentos Conta-Corrente - CRAPLCM **/
        DO aux_contador = 1 TO 10:
      
            FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                               craplot.dtmvtolt = par_dtmvtolt AND
                               craplot.cdagenci = 1            AND
                               craplot.cdbccxlt = 100          AND
                               craplot.nrdolote = 10005          
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                         
            IF  NOT AVAILABLE craplot  THEN
                DO:
                    IF  LOCKED craplot  THEN
                        DO:
                            aux_dscritic = "Registro de lote esta sendo " +
                                           "alterado. Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            CREATE craplot.
                            ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                   craplot.cdagenci = 1
                                   craplot.cdbccxlt = 100
                                   craplot.nrdolote = 10005
                                   craplot.tplotmov = 1
                                   craplot.cdcooper = par_cdcooper.
                        END.
                END.
            
            aux_dscritic = "".
        
            LEAVE.
   
        END. /** Fim do DO ... TO **/
   
        IF  aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).                
                
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        CREATE craplcm.
        ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
               craplcm.cdagenci = craplot.cdagenci
               craplcm.cdbccxlt = craplot.cdbccxlt
               craplcm.nrdolote = craplot.nrdolote
               craplcm.nrdconta = par_nrdconta
               craplcm.nrdctabb = par_nrdconta
               craplcm.nrdctitg = STRING(par_nrdconta,"99999999")
               craplcm.nrdocmto = craplot.nrseqdig + 1
               craplcm.cdhistor = 483
               craplcm.vllanmto = par_vlresgat 
               craplcm.nrseqdig = craplot.nrseqdig + 1
               craplcm.cdcooper = par_cdcooper
              
               /** Credito **/
               craplot.qtinfoln = craplot.qtinfoln + 1
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.vlinfocr = craplot.vlinfocr 
               craplot.vlcompcr = craplot.vlcompcr 
               craplot.nrseqdig = craplcm.nrseqdig.
        VALIDATE craplot.
        
        /** Gera lancamentos para a conta Investimento - CRAPLCI **/   
        DO aux_contador = 1 TO 10:
      
            FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                               craplot.dtmvtolt = par_dtmvtolt AND
                               craplot.cdagenci = 1            AND
                               craplot.cdbccxlt = 100          AND
                               craplot.nrdolote = 10004 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                         
            IF  NOT AVAILABLE craplot  THEN
                DO:
                    IF  LOCKED craplot  THEN
                        DO:
                            aux_dscritic = "Registro de lote esta sendo " +
                                           "alterado. Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            CREATE craplot.
                            ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                   craplot.cdagenci = 1
                                   craplot.cdbccxlt = 100
                                   craplot.nrdolote = 10004
                                   craplot.tplotmov = 29
                                   craplot.cdcooper = par_cdcooper.
                        END.
                END.
            
            aux_dscritic = "".
        
            LEAVE.
   
        END. /** Fim do DO ... TO **/
   
        IF  aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                   
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
        
        CREATE craplci.
        ASSIGN craplci.dtmvtolt = craplot.dtmvtolt
               craplci.cdagenci = craplot.cdagenci
               craplci.cdbccxlt = craplot.cdbccxlt
               craplci.nrdolote = craplot.nrdolote
               craplci.nrdconta = par_nrdconta
               craplci.nrdocmto = craplot.nrseqdig + 1
               craplci.cdhistor = 484
               craplci.vllanmto = par_vlresgat
               craplci.nrseqdig = craplot.nrseqdig + 1
               craplci.cdcooper = par_cdcooper
               crapsli.vlsddisp = crapsli.vlsddisp - par_vlresgat
               craplcm.cdpesqbb = STRING(craplci.nrdocmto)
          
               /** Debito **/
               craplot.qtinfoln = craplot.qtinfoln + 1
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.vlinfodb = craplot.vlinfodb + par_vlresgat
               craplot.vlcompdb = craplot.vlcompdb + par_vlresgat
               craplot.nrseqdig = craplcm.nrseqdig.
               

        VALIDATE craplcm.
        VALIDATE craplot.
        VALIDATE craplci.

        /** Retirar LOCK **/
        FIND CURRENT crapsli NO-LOCK NO-ERROR.
        FIND CURRENT craplot NO-LOCK NO-ERROR.
        FIND CURRENT craplcm NO-LOCK NO-ERROR.
        FIND CURRENT craplci NO-LOCK NO-ERROR.
        
        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION **/
     
    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Erro na transacao. Nao foi " + 
                                          "possivel efetuar o resgate.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.
                   
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT aux_dscritic,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
                                           
            RETURN "NOK".
        END.
            
    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT par_nmdatela,
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).
                       
    RUN log_itens_saque (INPUT par_vlresgat,
                         INPUT craplcm.nrdocmto).
     
    RETURN "OK".
                 
END PROCEDURE.


/******************************************************************************/
/**       Procedure para cancelar resgate gerado na conta investimento       **/
/******************************************************************************/
PROCEDURE obtem-cancelamento:
   
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INTE                           NO-UNDO.  
              
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_vllanmto AS DECI                                    NO-UNDO.
    
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.    
    
    /** Atribui descricao da origem e da transacao **/
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Cancelar resgate na conta investimento"
           aux_flgtrans = FALSE.
           
    IF  NOT CAN-FIND(craplcm WHERE craplcm.cdcooper = par_cdcooper  AND
                                   craplcm.dtmvtolt = par_dtmvtolt  AND
                                   craplcm.cdagenci = 1             AND
                                   craplcm.cdbccxlt = 100           AND
                                   craplcm.nrdolote = 10005         AND
                                   craplcm.nrdctabb = par_nrdconta  AND
                                   craplcm.nrdocmto = par_nrdocmto
                                   USE-INDEX craplcm1)              THEN
        DO:
            ASSIGN aux_cdcritic = 90
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                   
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT aux_dscritic,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
            
            RETURN "NOK".            
        END.
        
    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        /*** Lancamentos Conta Corrente ***/
        DO aux_contador = 1 TO 10:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
    
            FIND craplcm WHERE craplcm.cdcooper = par_cdcooper AND
                               craplcm.dtmvtolt = par_dtmvtolt AND
                               craplcm.cdagenci = 1            AND
                               craplcm.cdbccxlt = 100          AND
                               craplcm.nrdolote = 10005        AND
                               craplcm.nrdctabb = par_nrdconta AND
                               craplcm.nrdocmto = par_nrdocmto   
                               USE-INDEX craplcm1 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF  NOT AVAILABLE craplcm  THEN
                DO:
                    IF  LOCKED craplcm  THEN
                        DO:
                            aux_dscritic = "Registro do lancamento sendo " +
                                           "alterado. Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                         END.
                    ELSE
                         aux_cdcritic = 90.
                END.
            
            LEAVE.
        
        END. /** Fim do DO ... TO **/

        IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                               
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
   
        ASSIGN aux_vllanmto = craplcm.vllanmto.
                      
        DELETE craplcm.
    
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
                   
            FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                               craplot.dtmvtolt = par_dtmvtolt AND
                               craplot.cdagenci = 1            AND
                               craplot.cdbccxlt = 100          AND
                               craplot.nrdolote = 10005        
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                      
            IF  NOT AVAILABLE craplot  THEN
                DO:
                    IF  LOCKED craplot  THEN
                        DO:
                            aux_dscritic = "Registro do lote sendo alterado. " +
                                           "Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        aux_dscritic = "Registro de lote nao encontrado.".
                END.
            
            LEAVE.
        
        END. /** Fim do DO ... TO **/
    
        IF  aux_dscritic <> ""  THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                   
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        ASSIGN craplot.qtcompln = craplot.qtcompln - 1
               craplot.qtinfoln = craplot.qtinfoln - 1
               craplot.vlcompcr = craplot.vlcompcr - aux_vllanmto
               craplot.vlinfocr = craplot.vlinfocr - aux_vllanmto.
              
        IF  craplot.qtcompln = 0 AND craplot.qtinfoln = 0  AND
            craplot.vlcompdb = 0 AND craplot.vlinfodb = 0  AND
            craplot.vlcompcr = 0 AND craplot.vlinfocr = 0  THEN
            DELETE craplot.
        
        /** Eliminar os lancamentos CI **/
        DO aux_contador = 1 TO 10:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
    
            FIND craplci WHERE craplci.cdcooper = par_cdcooper AND
                               craplci.dtmvtolt = par_dtmvtolt AND
                               craplci.cdagenci = 1            AND
                               craplci.cdbccxlt = 100          AND
                               craplci.nrdolote = 10004        AND
                               craplci.nrdocmto = par_nrdocmto 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT. 
                      
            IF  NOT AVAILABLE craplci  THEN
                DO:
                    IF  LOCKED craplci  THEN
                        DO:
                            aux_dscritic = "Registro do lancamento sendo " +
                                           "alterado. Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        aux_cdcritic = 90.
                END.
                
            LEAVE.
        
        END. /** Fim do DO ... TO **/
    
        IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                   
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
                   
            FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                               craplot.dtmvtolt = par_dtmvtolt AND
                               craplot.cdagenci = 1            AND
                               craplot.cdbccxlt = 100          AND
                               craplot.nrdolote = 10004        AND
                               craplot.tplotmov = 29           
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                      
            IF  NOT AVAILABLE craplot  THEN
                DO:
                    IF  LOCKED craplot  THEN
                        DO:
                            aux_dscritic = "Registro do lote sendo alterado. " +
                                           "Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        aux_dscritic = "Registro de lote nao encontrado.".
                END.
            
            LEAVE.
        
        END. /** Fim do DO ... TO **/
    
        IF  aux_dscritic <> ""  THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                   
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
        
        DELETE craplci.
   
        ASSIGN craplot.qtcompln = craplot.qtcompln - 1
               craplot.qtinfoln = craplot.qtinfoln - 1
               craplot.vlcompdb = craplot.vlcompdb - aux_vllanmto
               craplot.vlinfodb = craplot.vlinfodb - aux_vllanmto.
              
        IF  craplot.qtcompln = 0 AND craplot.qtinfoln = 0  AND
            craplot.vlcompdb = 0 AND craplot.vlinfodb = 0  AND
            craplot.vlcompcr = 0 AND craplot.vlinfocr = 0  THEN
            DELETE craplot.
   
        /** Atualizacao CRAPSLI **/
        DO aux_contador = 1 TO 10:
    
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
                   
            FIND crapsli WHERE crapsli.cdcooper  = par_cdcooper        AND
                               crapsli.nrdconta  = par_nrdconta        AND
                         MONTH(crapsli.dtrefere) = MONTH(par_dtmvtolt) AND
                          YEAR(crapsli.dtrefere) = YEAR(par_dtmvtolt)   
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
   
            IF  NOT AVAILABLE crapsli  THEN
                DO:
                    IF  LOCKED crapsli  THEN
                        DO:
                            aux_dscritic = "Registro de conta investimento " +
                                           "esta sendo alterado. Tente " +
                                           "novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        aux_dscritic = "Registro de conta investimento " +
                                       "nao encontrado.".
                END.
    
            LEAVE.
        
        END. /** Fim do DO ... TO **/
    
        IF  aux_dscritic <> ""  THEN
            DO:
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                   
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
        
        ASSIGN crapsli.vlsddisp = crapsli.vlsddisp + aux_vllanmto.
        
        /** Retirar LOCK **/
        FIND CURRENT crapsli NO-LOCK NO-ERROR.
        
        IF  AVAILABLE craplot  THEN
            FIND CURRENT craplot NO-LOCK NO-ERROR.
        
        ASSIGN aux_flgtrans = TRUE.
    
    END. /** Fim do DO TRANSACTION **/

    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Erro na transacao. Nao foi " + 
                                          "possivel cancelar o resgate.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.
                   
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT aux_dscritic,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
                                           
            RETURN "NOK".
        END.
        
    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT par_nmdatela,
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).

    RUN log_itens_saque (INPUT aux_vllanmto,
                         INPUT par_nrdocmto).
                       
    RETURN "OK".

END PROCEDURE.


/*............................ PROCEDURES INTERNAS ...........................*/


/******************************************************************************/
/**        Procedure para montar dados que serao gravados no protocolo       **/
/******************************************************************************/
PROCEDURE log_itens_saque:

    DEF  INPUT PARAM par_vlresgat AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INTE                           NO-UNDO.

    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                             INPUT "vlresgat",
                             INPUT "",
                             INPUT TRIM(STRING(par_vlresgat,
                                               "zzz,zzz,zz9.99"))).
            
    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                             INPUT "nrdocmto",
                             INPUT "",
                             INPUT TRIM(STRING(par_nrdocmto,
                                               "zzz,zzz,zzz,zz9"))).
                                                                            
    RETURN "OK".                                     
    
END PROCEDURE.


/*............................................................................*/

