/*.............................................................................

    Programa  : sistema/generico/procedures/b1wgen0070.p
    Autor     : David
    Data      : Abril/2010                  Ultima Atualizacao: 17/01/2017
    
    Dados referentes ao programa:

    Objetivo  : BO referente ao modulo Meu Cadastro da Conta On-Line e
                rotina TELEFONE da tela CONTAS.

    Alteracoes:  22/09/2010 -  Adicionado tratamento para conta 'pai' 
                              ou 'filha' (Gabriel - DB1).
                              
                 20/12/2010 - Adicionado parametros na chamada do procedure
                              Replica_Dados para tratamento do log e  erros
                              da validação na replicação (Gabriel - DB1).
                              
                 15/02/2011 - Incluir rotina de Telefone da ATENDA (Gabriel).
                 
                 30/07/2013 - Alterado para pegar o telefone da tabela 
                              craptfc ao invés da crapass (James).
                              
                 16/08/2013 - Incluido a chamada da procedure
                              "atualiza_data_manutencao_cadastro" dentro da
                              procedure "gerenciar-telefone" (James).
                              
                 15/10/2013 - Na inclusao ou alteracao dos telefones, validado
                              o preenchimento de DDD, telefone e ramal, nao
                              permitindo zero ou ? (nulo). Quando comercial,
                              nao permite informar nulo para o ramal (Carlos)
                              
                 05/03/2014 - Inclusao de VALIDATE craptfc (Carlos)
                 
                 30/07/2014 - Retirada a validacao de tipo de telefone que nao
                              permite pessoa de contato pois na tela nao eh 
                              mais possivel preencher este campo (Carlos)
                 
                 22/01/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
				              Transferencia entre PAs (Heitor - RKAM)
                      
                 04/11/2016 - M172 - Atualizacao Telefone (Guilherme/SUPERO)

                      
                 17/01/2017 - Adicionado chamada a procedure de replicacao do 
                              telefone para o CDC. (Reinert Prj 289)     
.............................................................................*/


/*................................ DEFINICOES ...............................*/


{ sistema/generico/includes/b1wgen0070tt.i }
{ sistema/generico/includes/b1wgen0168tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }

{ sistema/generico/includes/var_oracle.i }
    
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_tptelefo AS CHAR EXTENT 4 INIT["RESIDENCIAL","CELULAR",
                                           "COMERCIAL","CONTATO"]      NO-UNDO.
                                           
DEF TEMP-TABLE tt-craptfc-old NO-UNDO LIKE craptfc.
DEF TEMP-TABLE tt-craptfc-new NO-UNDO LIKE craptfc.


/*............................ PROCEDURES EXTERNAS ..........................*/

     
/*****************************************************************************/
/**             Procedure para retornar telefones do cooperado              **/
/*****************************************************************************/
PROCEDURE obtem-telefone-cooperado: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
 
    DEF OUTPUT PARAM par_msgconta AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-telefone-cooperado.

    DEF VAR aux_nrdconta AS INTE                                    NO-UNDO.
    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.
        
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-telefone-cooperado.
 
    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Obter telefones do cooperado".

    FOR EACH craptfc WHERE craptfc.cdcooper = par_cdcooper AND
                           craptfc.nrdconta = par_nrdconta AND
                           craptfc.idseqttl = par_idseqttl NO-LOCK
                           BY craptfc.tptelefo BY craptfc.nrtelefo:
                  
        /** Operadora **/
        FIND craptab WHERE craptab.cdcooper = 0                AND
                           craptab.nmsistem = "CRED"           AND
                           craptab.tptabela = "USUARI"         AND
                           craptab.cdempres = 11               AND
                           craptab.cdacesso = "OPETELEFON"     AND
                           craptab.tpregist = craptfc.cdopetfn NO-LOCK NO-ERROR.

        CREATE tt-telefone-cooperado.
        ASSIGN tt-telefone-cooperado.destptfc = aux_tptelefo[craptfc.tptelefo]
               tt-telefone-cooperado.tptelefo = craptfc.tptelefo
               tt-telefone-cooperado.nrdddtfc = craptfc.nrdddtfc
               tt-telefone-cooperado.nrtelefo = craptfc.nrtelefo
               tt-telefone-cooperado.nrdramal = craptfc.nrdramal
               tt-telefone-cooperado.secpscto = craptfc.secpscto
               tt-telefone-cooperado.nmpescto = craptfc.nmpescto
               tt-telefone-cooperado.cdopetfn = craptfc.cdopetfn
               tt-telefone-cooperado.nmopetfn = IF  AVAILABLE craptab  THEN
                                                    craptab.dstextab
                                                ELSE
                                                IF  craptfc.cdopetfn = 0  THEN
                                                    ""
                                                ELSE
                                                    "NAO CADASTRADO"
               tt-telefone-cooperado.nrdrowid = ROWID(craptfc)
               tt-telefone-cooperado.idsittfc = craptfc.idsittfc
               tt-telefone-cooperado.idorigem = craptfc.idorigem.
        
    END. /** Fim do FOR EACH craptfc **/
    
    /*Alteração: Busca CPF do cooperado e procura por contar filhas. 
      (Gabriel - DB1)*/
    FOR FIRST crapttl FIELDS (nrcpfcgc)
                       WHERE crapttl.cdcooper = par_cdcooper AND 
                             crapttl.nrdconta = par_nrdconta AND 
                             crapttl.idseqttl = par_idseqttl NO-LOCK: 
    END.
    
    IF AVAILABLE crapttl THEN
        DO:
            /* Rotina para controle/replicacao entre contas */
            IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                RUN sistema/generico/procedures/b1wgen0077.p 
                    PERSISTENT SET h-b1wgen0077.
           
            RUN Busca_Conta IN h-b1wgen0077
                ( INPUT par_cdcooper,
                  INPUT par_nrdconta,
                  INPUT crapttl.nrcpfcgc,
                  INPUT par_idseqttl,
                 OUTPUT aux_nrdconta,
                 OUTPUT par_msgconta,
                 OUTPUT aux_cdcritic,
                 OUTPUT aux_dscritic ).
            
            IF  VALID-HANDLE(h-b1wgen0077) THEN
                DELETE OBJECT h-b1wgen0077.
        END.

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


/*****************************************************************************/
/**         Procedure para obter dados para alterar/incluir telefone        **/
/*****************************************************************************/
PROCEDURE obtem-dados-gerenciar-telefone: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-operadoras-celular.
    DEF OUTPUT PARAM TABLE FOR tt-telefone-cooperado.

    DEF VAR aux_tipofone AS INT                                     NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-operadoras-celular.
    EMPTY TEMP-TABLE tt-telefone-cooperado.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter dados para gerenciar telefone".

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                           
            IF  par_flgerlog  THEN
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

    ASSIGN par_inpessoa = crapass.inpessoa.

    FOR EACH craptab WHERE craptab.cdcooper = 0            AND
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "USUARI"     AND
                           craptab.cdempres = 11           AND
                           craptab.cdacesso = "OPETELEFON" NO-LOCK:
     
        CREATE tt-operadoras-celular.
        ASSIGN tt-operadoras-celular.cdopetfn = craptab.tpregist 
               tt-operadoras-celular.nmopetfn = craptab.dstextab.
    
    END. /** Fim do FOR EACH craptab **/
    
    IF  par_cddopcao = "I"  THEN
        DO:
            IF  crapass.inpessoa = 1  THEN
                DO: 
                    
                    FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                       crapttl.nrdconta = par_nrdconta AND
                                       crapttl.idseqttl = par_idseqttl
                                       NO-LOCK NO-ERROR.
                               
                    IF  NOT AVAILABLE crapttl  THEN
                        DO:
                            
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Titular nao cadastrado.".
                                   
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,           /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                                           
                            IF  par_flgerlog  THEN
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
                END.
            
            IF crapass.inpessoa = 1 THEN
               ASSIGN aux_tipofone = 1.
            ELSE
               ASSIGN aux_tipofone = 3.

            FIND FIRST craptfc WHERE craptfc.cdcooper = par_cdcooper AND
                                     craptfc.nrdconta = par_nrdconta AND
                                     craptfc.tptelefo = aux_tipofone
                                     NO-LOCK NO-ERROR.

            IF AVAILABLE craptfc THEN
               DO:
                   CREATE tt-telefone-cooperado.
                   ASSIGN tt-telefone-cooperado.nrfonass = 
                            "(" + STRING(craptfc.nrdddtfc) + ") " +
                            STRING(craptfc.nrtelefo).
               END.
                   
            FIND FIRST craptfc WHERE craptfc.cdcooper = par_cdcooper AND
                                     craptfc.nrdconta = par_nrdconta AND
                                     craptfc.tptelefo = 2
                                     NO-LOCK NO-ERROR.
                                       
            IF AVAILABLE craptfc THEN
               DO:
                   CREATE tt-telefone-cooperado.
                   ASSIGN tt-telefone-cooperado.nrfonass = 
                            "(" + STRING(craptfc.nrdddtfc) + ") " +
                            STRING(craptfc.nrtelefo).
               END.
        END.
    ELSE
        DO:                                                 
            FIND craptfc WHERE ROWID(craptfc) = par_nrdrowid NO-LOCK NO-ERROR.
                               
            IF  NOT AVAILABLE craptfc  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Telefone nao cadastrado.".
                           
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                   
                    IF  par_flgerlog  THEN
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

            FIND craptab WHERE craptab.cdcooper = 0                AND
                               craptab.nmsistem = "CRED"           AND
                               craptab.tptabela = "USUARI"         AND
                               craptab.cdempres = 11               AND
                               craptab.cdacesso = "OPETELEFON"     AND
                               craptab.tpregist = craptfc.cdopetfn
                               NO-LOCK NO-ERROR.
                
            CREATE tt-telefone-cooperado.
            ASSIGN tt-telefone-cooperado.cdseqtfc = craptfc.cdseqtfc
                   tt-telefone-cooperado.destptfc = 
                                         aux_tptelefo[craptfc.tptelefo]
                   tt-telefone-cooperado.tptelefo = craptfc.tptelefo
                   tt-telefone-cooperado.nrdddtfc = craptfc.nrdddtfc
                   tt-telefone-cooperado.nrtelefo = craptfc.nrtelefo   
                   tt-telefone-cooperado.nrdramal = craptfc.nrdramal
                   tt-telefone-cooperado.nmpescto = craptfc.nmpescto
                   tt-telefone-cooperado.secpscto = craptfc.secpscto 
                   tt-telefone-cooperado.cdopetfn = craptfc.cdopetfn  
                   tt-telefone-cooperado.nmopetfn = IF AVAILABLE craptab THEN
                                                       craptab.dstextab
                                                    ELSE
                                                    IF craptfc.cdopetfn = 0 THEN
                                                       ""
                                                    ELSE
                                                       "NAO CADASTRADO"
                   tt-telefone-cooperado.nrdrowid = ROWID(craptfc)
                   tt-telefone-cooperado.idsittfc = craptfc.idsittfc
                   tt-telefone-cooperado.idorigem = craptfc.idorigem.
        END.
    
    RETURN "OK".
    
END PROCEDURE.


/*****************************************************************************/
/**                Procedure para validar telefone do cooperado             **/
/*****************************************************************************/
PROCEDURE validar-telefone: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_tptelefo AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdddtfc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelefo AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdramal AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_secpscto AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmpescto AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdopetfn AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctarep AS INTE                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabtfc FOR craptfc.

    DEF VAR aux_cddfrenv AS INTE                                    NO-UNDO.

    DEF VAR aux_flgerror AS LOGI                                    NO-UNDO.

    DEF VAR aux_msgconta AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validar telefone do cooperado"
           aux_flgerror = TRUE
           aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE.
            END.

        IF  par_cddopcao <> "I"  THEN
            DO:
                FIND crabtfc WHERE ROWID(crabtfc) = par_nrdrowid 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crabtfc  THEN
                    DO:
                        ASSIGN aux_dscritic = "Telefone nao cadastrado.".
                        LEAVE.
                    END.
            END.
        
        IF  par_cddopcao = "A"  OR 
            par_cddopcao = "I"  THEN 
            DO:
                IF  NOT CAN-DO("1,2,3,4",STRING(par_tptelefo))  THEN
                    DO:
                        ASSIGN aux_dscritic = "Tipo de telefone invalido.".
                        LEAVE.
                    END.

                IF  par_nrdddtfc = 0 OR par_nrdddtfc = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Informe o DDD.".
                        LEAVE.
                    END.

                IF  par_nrtelefo = 0 OR par_nrtelefo = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Informe o telefone.".
                        LEAVE.
                    END.

                IF  par_tptelefo <> 3  AND
                    par_nrdramal <> 0  THEN
                    DO:
                        ASSIGN aux_dscritic = "Tipo de telefone nao possui " +
                                              "ramal.".
                        LEAVE.
                    END.

                IF  par_tptelefo = 3 AND par_nrdramal = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Informe o ramal.".
                        LEAVE.
                    END.

                IF  crapass.inpessoa = 1  AND 
                    par_tptelefo <> 3     AND
                    par_secpscto <> ""    THEN
                    DO:
                        ASSIGN aux_dscritic = "Tipo de telefone nao possui " +
                                              "setor.".
                        LEAVE.
                    END.

                IF  par_tptelefo <> 2  AND
                    par_cdopetfn <> 0  THEN
                    DO:
                        ASSIGN aux_dscritic = "Tipo de telefone nao possui " +
                                              "operadora.".
                        LEAVE.
                    END.

                IF  par_tptelefo = 2  AND   
                   (par_idorigem <> 4 AND
                    NOT CAN-FIND(FIRST craptab WHERE 
                                       craptab.cdcooper = 0            AND
                                       craptab.nmsistem = "CRED"       AND
                                       craptab.tptabela = "USUARI"     AND
                                       craptab.cdempres = 11           AND
                                       craptab.cdacesso = "OPETELEFON" AND
                                       craptab.tpregist = par_cdopetfn NO-LOCK))
                    THEN DO:
                        ASSIGN aux_dscritic = "Operadora nao cadastrada.". 
                        LEAVE.
                    END.

                IF (par_tptelefo = 3   OR
                    par_tptelefo = 4)  AND
                   (par_idorigem <> 3  AND
                    par_idorigem <> 4) AND
                    par_nmpescto = ""  THEN DO:
                        ASSIGN aux_dscritic = "Informe a pessoa de contato.".
                        LEAVE.
                    END.

                IF  par_cddopcao = "I"  AND
                    par_idorigem <> 4   AND
                    CAN-FIND(LAST craptfc WHERE 
                             craptfc.cdcooper = par_cdcooper AND
                             craptfc.nrdconta = par_nrdconta AND
                             craptfc.idseqttl = par_idseqttl AND
                             craptfc.nrtelefo = par_nrtelefo AND
                             craptfc.nrdramal = par_nrdramal NO-LOCK) THEN
                    DO:
                        ASSIGN aux_dscritic = "Telefone ja cadastrado para o " +
                                              "titular.".
                        LEAVE.                    
                    END.
                ELSE
                IF  par_cddopcao = "A"  AND
                    CAN-FIND(LAST craptfc WHERE 
                             craptfc.cdcooper  = par_cdcooper     AND
                             craptfc.nrdconta  = par_nrdconta     AND
                             craptfc.idseqttl  = par_idseqttl     AND
                             craptfc.nrtelefo  = par_nrtelefo     AND
                             craptfc.nrdramal  = par_nrdramal     AND
                             craptfc.cdseqtfc <> crabtfc.cdseqtfc NO-LOCK) THEN
                    DO:
                        ASSIGN aux_dscritic = "Telefone ja cadastrado para o " +
                                              "titular.".
                        LEAVE.
                    END.
            END.        
        ELSE
        IF  par_cddopcao = "E"  THEN
            DO:
                /** Existindo somente um fone cadastrado, nao pode excluir **/
                IF  NOT par_nrctarep > 0 AND /*Se não é chamado na replicacao*/
                    NOT(CAN-FIND(FIRST craptfc WHERE
                                 craptfc.cdcooper = par_cdcooper AND
                                 craptfc.nrdconta = par_nrdconta AND
                                 craptfc.idseqttl = par_idseqttl AND
                                 ROWID(craptfc)  <> par_nrdrowid NO-LOCK)) THEN
                    DO:
                        ASSIGN aux_dscritic = "Deve existir pelo menos um " + 
                                              "telefone cadastrado.".
                        LEAVE.
                    END.

                /** Verifica se o fone esta vinculado para informativo **/
                FOR EACH craptab WHERE craptab.cdcooper = 0            AND
                                       craptab.nmsistem = "CRED"       AND
                                       craptab.tptabela = "USUARI"     AND
                                       craptab.cdempres = 11           AND
                                       craptab.cdacesso = "FORENVINFO" NO-LOCK:

                    IF  ENTRY(2,craptab.dstextab,",") = "craptfc"  THEN
                        ASSIGN aux_cddfrenv = craptab.tpregist.

                END. /** Fim do FOR EACH craptab **/

                IF  CAN-FIND(FIRST crapcra WHERE 
                             crapcra.cdcooper = par_cdcooper     AND
                             crapcra.nrdconta = par_nrdconta     AND
                             crapcra.idseqttl = par_idseqttl     AND
                             crapcra.cddfrenv = aux_cddfrenv     AND
                             crapcra.cdseqinc = crabtfc.cdseqtfc NO-LOCK) THEN
                    DO:
                        IF  par_nrctarep > 0  THEN  /** Replicacao **/
                            DO:
                                RUN obtem-telefone-cooperado 
                                         (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_cdoperad,
                                          INPUT par_nmdatela,
                                          INPUT par_idorigem,
                                          INPUT par_nrctarep,
                                          INPUT 1,
                                          INPUT FALSE,
                                         OUTPUT aux_msgconta,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-telefone-cooperado).

                                IF  RETURN-VALUE = "NOK"  THEN
                                    LEAVE.
                            END.

                        /* Se fone excluido na conta replicadora, criticar */
                        IF  par_nrctarep = 0 OR
                            NOT CAN-FIND(FIRST tt-telefone-cooperado WHERE 
                                   tt-telefone-cooperado.nrtelefo = par_nrtelefo
                               AND tt-telefone-cooperado.nrdramal = par_nrdramal
                                   NO-LOCK)  THEN
                            DO:
                                ASSIGN aux_dscritic = "Existem informativos " +
                                                      "cadastrados com este " +
                                                      "telefone.".
                                LEAVE.
                            END.
                    END.

            END.

        ASSIGN aux_flgerror = FALSE.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  aux_flgerror  THEN
        DO:

            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,            /** Sequencia **/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
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

    RETURN "OK".

END PROCEDURE.

                
/*****************************************************************************/
/**          Procedure para alteracao/exclusao/inclusao de telefone         **/
/*****************************************************************************/
PROCEDURE gerenciar-telefone: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_tptelefo AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdddtfc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelefo AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdramal AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_secpscto AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmpescto AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdopetfn AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_prgqfalt AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_idsittfc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigee AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgrvcad AS CHAR                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_cdseqtfc AS INTE                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    
    DEFINE BUFFER bcrapttl FOR crapttl.
    DEF VAR h-b1wgen0168 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-craptfc-old.
    EMPTY TEMP-TABLE tt-craptfc-new.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = IF  par_cddopcao = "A"  THEN
                              "Alteracao de Telefone"
                          ELSE
                          IF  par_cddopcao = "E"  THEN
                              "Exclusao de Telefone"
                          ELSE
                              "Inclusao de Telefone"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    TRANS_FONE:
    
    DO TRANSACTION ON ERROR  UNDO TRANS_FONE, LEAVE TRANS_FONE
                   ON ENDKEY UNDO TRANS_FONE, LEAVE TRANS_FONE:
    
        IF  par_idorigem <> 3  THEN /** InternetBank **/
            DO:
                DO aux_contador = 1 TO 10:

                    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                       crapass.nrdconta = par_nrdconta 
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crapass  THEN
                        DO:
                            IF  LOCKED crapass  THEN
                                DO:
                                    IF  aux_contador = 10  THEN
                                        DO:
                                            FIND LAST crapass WHERE 
                                             crapass.cdcooper = par_cdcooper AND
                                             crapass.nrdconta = par_nrdconta 
                                             NO-LOCK NO-ERROR.
                                            
                                            RUN critica-lock 
                                               (INPUT RECID(crapass),
                                                INPUT "banco",
                                                INPUT "crapass",
                                                INPUT par_idorigem).
                                        END.
                                    ELSE
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                END.
                            ELSE
                                ASSIGN aux_cdcritic = 9.
                        END.

                    LEAVE.

                END. /** Fim do DO ... TO **/

                IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
                    UNDO TRANS_FONE, LEAVE TRANS_FONE.
            END.

        IF  par_cddopcao = "I"  THEN 
            DO: 
                IF par_nmdatela = "MATRIC" THEN 
                  DO:
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                
                    RUN STORED-PROCEDURE pc_busca_nrseqtel 
                    aux_handproc = PROC-HANDLE NO-ERROR
                             (INPUT crapass.nrcpfcgc,  
                              INPUT par_tptelefo,						  
                             OUTPUT 0,
                             OUTPUT "").

                    CLOSE STORED-PROC pc_busca_nrseqtel
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
              
                    ASSIGN aux_cdseqtfc = 0
                           aux_cdseqtfc = pc_busca_nrseqtel.pr_nrseqtel 
                                WHEN pc_busca_nrseqtel.pr_nrseqtel <> ?
                           aux_dscritic = ""                         
                           aux_dscritic = pc_busca_nrseqtel.pr_dscritic 
                                WHEN pc_busca_nrseqtel.pr_dscritic <> ?.						
                  
                   
                    /* Verificar se sequencial ja esta em uso, caso esteja buscar o ultimo
                      tratamento necessario, pois na tela MATRIC permite cadastrar dois telefones
                      assim a nova estrutura ainda nao estara atualizada retornando o mesmo seq, duas vezes */
                    FIND FIRST craptfc 
                         WHERE craptfc.cdcooper = par_cdcooper AND
                               craptfc.nrdconta = par_nrdconta AND
                               craptfc.idseqttl = par_idseqttl AND
                               craptfc.cdseqtfc = aux_cdseqtfc
                              NO-LOCK NO-ERROR.
                              
                    IF AVAILABLE craptfc THEN          
                      ASSIGN aux_cdseqtfc = 0.
                  
                  END.
                
                IF par_nmdatela <> "MATRIC" OR aux_cdseqtfc = 0 THEN
                  DO:
                    FIND LAST craptfc WHERE craptfc.cdcooper = par_cdcooper AND
                                            craptfc.nrdconta = par_nrdconta AND
                                            craptfc.idseqttl = par_idseqttl
                                            NO-LOCK NO-ERROR.
                            
                    ASSIGN aux_cdseqtfc = IF  AVAILABLE craptfc  THEN 
                                              craptfc.cdseqtfc + 1
                                          ELSE 
                                              1.

                /* Se veio pelo TAA, validar se fone ja existe */
                IF  par_idorigem = 4 THEN DO:

                    DO aux_contador = 1 TO 10:

                        /* Verificar se telefone ja existe */
                        FIND LAST craptfc
                            WHERE craptfc.cdcooper = par_cdcooper
                              AND craptfc.nrdconta = par_nrdconta
                              AND craptfc.idseqttl = par_idseqttl
                              AND craptfc.nrtelefo = par_nrtelefo
                          EXCLUSIVE-LOCK NO-ERROR.

                        IF  NOT AVAILABLE craptfc  THEN DO:
               
                            IF  LOCKED craptfc  THEN DO:
                                IF  aux_contador = 10  THEN DO:
                                    FIND LAST craptfc
                                        WHERE craptfc.cdcooper = par_cdcooper
                                          AND craptfc.nrdconta = par_nrdconta
                                          AND craptfc.idseqttl = par_idseqttl
                                          AND craptfc.nrtelefo = par_nrtelefo
                                      NO-LOCK NO-ERROR.

                                    RUN critica-lock
                                            (INPUT RECID(craptfc),
                                             INPUT "banco",
                                             INPUT "craptfc",
                                             INPUT par_idorigem).
                                END.
                                ELSE DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            END.
                        END.

                        LEAVE.

                    END. /** Fim do DO ... TO **/

                    IF  aux_dscritic <> ""  THEN
                        UNDO TRANS_FONE, LEAVE TRANS_FONE.

                    IF  AVAIL craptfc THEN
                        DELETE craptfc.

                END. /* FIM par_idorigem = 4 */

               
                CREATE craptfc.
                ASSIGN craptfc.cdcooper = par_cdcooper
                       craptfc.nrdconta = par_nrdconta
                       craptfc.idseqttl = par_idseqttl
                       craptfc.cdseqtfc = aux_cdseqtfc
                       craptfc.tptelefo = par_tptelefo
                       craptfc.cdopetfn = IF  par_tptelefo = 2  THEN
                                              par_cdopetfn
                                          ELSE
                                              0
                       craptfc.nrdddtfc = par_nrdddtfc
                       craptfc.nrtelefo = par_nrtelefo
                       craptfc.nrdramal = par_nrdramal
                       craptfc.secpscto = CAPS(par_secpscto)
                       craptfc.nmpescto = IF  par_tptelefo = 3  OR 
                                              par_tptelefo = 4  THEN 
                                              CAPS(par_nmpescto)
                                          ELSE
                                              ""
                       craptfc.prgqfalt = par_prgqfalt
                       craptfc.idsittfc = par_idsittfc
                       craptfc.idorigem = par_idorigee.
                VALIDATE craptfc.

                /** Cria registro vazio para executar buffer-compare **/
                CREATE tt-craptfc-old. 
                CREATE tt-craptfc-new.
                BUFFER-COPY craptfc TO tt-craptfc-new. 

                IF  par_nmdatela = "CONTAS"  AND
                    par_flgerlog             THEN
                    DO:
                        { sistema/generico/includes/b1wgenalog.i }
                        { sistema/generico/includes/b1wgenllog.i }
                    END.
            END.
        ELSE
            DO: 
                DO aux_contador = 1 TO 10:
        
                    FIND craptfc WHERE ROWID(craptfc) = par_nrdrowid
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE craptfc  THEN
                        DO:
                            IF  LOCKED craptfc  THEN
                                DO:
                                    IF  aux_contador = 10  THEN
                                        DO:
                                            FIND craptfc WHERE 
                                                 ROWID(craptfc) = par_nrdrowid
                                                 NO-LOCK NO-ERROR.

                                            RUN critica-lock 
                                                (INPUT RECID(craptfc),
                                                 INPUT "banco",
                                                 INPUT "craptfc",
                                                 INPUT par_idorigem).
                                        END.
                                    ELSE
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                END.
                            ELSE    
                                ASSIGN aux_dscritic = "Telefone nao " + 
                                                      "cadastrado.".
                        END.
                
                    LEAVE.
                   
                END. /** Fim do DO ... TO **/
                     
                IF  aux_dscritic <> ""  THEN
                    UNDO TRANS_FONE, LEAVE TRANS_FONE.

                IF  par_nmdatela = "CONTAS"  AND
                    par_flgerlog             THEN
                    DO:
                        { sistema/generico/includes/b1wgenalog.i }
                    END.                       

                CREATE tt-craptfc-old.
                BUFFER-COPY craptfc TO tt-craptfc-old.

                IF  par_cddopcao = "A"  THEN
                    DO:
                        IF  par_idorigem = 3  THEN
                            ASSIGN par_nrdramal = craptfc.nrdramal
                                   par_secpscto = craptfc.secpscto
                                   par_nmpescto = craptfc.nmpescto.

                        ASSIGN craptfc.tptelefo = par_tptelefo
                               craptfc.nrdddtfc = par_nrdddtfc
                               craptfc.nrtelefo = par_nrtelefo
                               craptfc.nrdramal = par_nrdramal
                               craptfc.cdopetfn = IF  par_tptelefo = 2  THEN
                                                      par_cdopetfn
                                                  ELSE
                                                      0
                               craptfc.secpscto = CAPS(par_secpscto)
                               craptfc.nmpescto = CAPS(par_nmpescto)
                               craptfc.prgqfalt = par_prgqfalt
                               craptfc.idsittfc = par_idsittfc
                               craptfc.idorigem = par_idorigee.

                        CREATE tt-craptfc-new.
                        BUFFER-COPY craptfc TO tt-craptfc-new.

                        IF  par_nmdatela = "CONTAS"  AND
                            par_flgerlog             THEN 
                            DO:
                                { sistema/generico/includes/b1wgenllog.i }
                            END.
                    END.
                ELSE
                IF  par_cddopcao = "E"  THEN
                    DO:
                        /** Cria registro vazio para executar buffer-compare **/
                        CREATE tt-craptfc-new. 

                        IF  par_nmdatela = "CONTAS"  AND
                            par_flgerlog             THEN
                            DO:
                                { sistema/generico/includes/b1wgenllog.i }
                            END.                        

                        DELETE craptfc.
                    END.
            END.

        IF  AVAILABLE crapass  THEN
            FIND CURRENT crapass NO-LOCK NO-ERROR.

        IF  AVAILABLE craptfc  THEN
            FIND CURRENT craptfc NO-LOCK NO-ERROR.

        /* Realiza a replicacao dos dados p/as contas relacionadas ao coop. */
        IF  par_idseqttl = 1 AND par_nmdatela = "CONTAS" THEN 
            DO:
               IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                   RUN sistema/generico/procedures/b1wgen0077.p 
                        PERSISTENT SET h-b1wgen0077.
    
               RUN Replica_Dados IN h-b1wgen0077
                   ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT "TELEFONE",
                     INPUT par_dtmvtolt,
                     INPUT FALSE, /*par_flgerlog*/
                    OUTPUT aux_cdcritic,
                    OUTPUT aux_dscritic,
                    OUTPUT TABLE tt-erro ).

               IF  VALID-HANDLE(h-b1wgen0077) THEN
                   DELETE OBJECT h-b1wgen0077.

               IF  RETURN-VALUE <> "OK" THEN
                   UNDO TRANS_FONE, LEAVE TRANS_FONE.

               FIND FIRST bcrapttl WHERE bcrapttl.cdcooper = par_cdcooper AND
                                         bcrapttl.nrdconta = par_nrdconta AND
                                         bcrapttl.idseqttl = par_idseqttl
                                         NO-ERROR.
    
               IF AVAILABLE bcrapttl THEN DO:                      
                   IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                       RUN sistema/generico/procedures/b1wgen0077.p
                           PERSISTENT SET h-b1wgen0077.

                   RUN Revisao_Cadastral IN h-b1wgen0077
                     ( INPUT par_cdcooper,
                       INPUT bcrapttl.nrcpfcgc,
                       INPUT par_nrdconta,
                      OUTPUT par_msgrvcad ).
                   
                   IF  VALID-HANDLE(h-b1wgen0077) THEN
                       DELETE OBJECT h-b1wgen0077.
               END.

            END.

        /*** M172 - ATUALIZACAO TELEFEONES - ATUALIZA DATA ***/

        IF  CAN-DO("1,3,4",STRING(par_idorigem)) /* 1-AYLLOS / 3-IB / 4-TAA  */
        AND CAN-DO("A,I",par_cddopcao) THEN      /* I-INCLUSAO / A-ALTERACAO */
            RUN pi_atualiza_data_manutencao_telefone
                    (INPUT par_cdcooper
                    ,INPUT par_nrdconta
                    ,INPUT par_idseqttl).

        /*** M172 - ATUALIZACAO TELEFEONES - ATUALIZA DATA ***/


        /* INICIO - Atualizar os dados da tabela crapcyb (CYBER) */
        IF NOT VALID-HANDLE(h-b1wgen0168) THEN
           RUN sistema/generico/procedures/b1wgen0168.p
               PERSISTENT SET h-b1wgen0168.
                     
        EMPTY TEMP-TABLE tt-crapcyb.
    
        CREATE tt-crapcyb.
        ASSIGN tt-crapcyb.cdcooper = par_cdcooper
               tt-crapcyb.nrdconta = par_nrdconta
               tt-crapcyb.dtmancad = par_dtmvtolt.
    
        RUN atualiza_data_manutencao_cadastro
            IN h-b1wgen0168(INPUT  TABLE tt-crapcyb,
                            OUTPUT aux_cdcritic,
                            OUTPUT aux_dscritic ).
                     
        IF VALID-HANDLE(h-b1wgen0168) THEN
           DELETE PROCEDURE(h-b1wgen0168).
    
        IF RETURN-VALUE <> "OK" THEN
           UNDO TRANS_FONE, LEAVE TRANS_FONE.
        /* FIM - Atualizar os dados da tabela crapcyb */

        /* Quando for primeiro titular e o telefone for comercial, 
           vamos ver ser o cooperado eh um conveniado CDC. Caso 
           positivo, vamos replicar os dados alterados de telefone
           para as tabelas do CDC. */
        IF par_tptelefo = 3 AND
           par_idseqttl = 1 THEN
          DO:
              FOR FIRST crapcdr WHERE crapcdr.cdcooper = par_cdcooper
                                  AND crapcdr.nrdconta = par_nrdconta
                                  AND crapcdr.flgconve = TRUE NO-LOCK:

                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                
                RUN STORED-PROCEDURE pc_replica_cdc
                  aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                      ,INPUT par_nrdconta
                                                      ,INPUT par_cdoperad
                                                      ,INPUT par_idorigem
                                                      ,INPUT par_nmdatela
                                                      ,INPUT 0
                                                      ,INPUT 1
                                                      ,INPUT 0
                                                      ,INPUT 0
                                                      ,0
                                                      ,"").

                CLOSE STORED-PROC pc_replica_cdc
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                ASSIGN aux_cdcritic = 0
                       aux_dscritic = ""
                       aux_cdcritic = pc_replica_cdc.pr_cdcritic 
                                        WHEN pc_replica_cdc.pr_cdcritic <> ?
                       aux_dscritic = pc_replica_cdc.pr_dscritic 
                                        WHEN pc_replica_cdc.pr_dscritic <> ?.
                                        
              END.
          END.
          
        ASSIGN aux_flgtrans = TRUE.
    
    END. /** Fim do DO TRANSACTION - TRANS_FONE **/
                              
    IF  VALID-HANDLE(h-b1wgen0077) THEN
        DELETE OBJECT h-b1wgen0077.

    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel " +
                                     (IF  par_cddopcao = "A"  THEN
                                          "alterar"
                                      ELSE
                                      IF  par_cddopcao = "E"  THEN
                                          "excluir"
                                      ELSE
                                          "incluir") +
                                      " o telefone.".
               
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
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

    IF  par_flgerlog  THEN 
        RUN proc_gerar_log_tab (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl, 
                                INPUT par_nmdatela, 
                                INPUT par_nrdconta, 
                                INPUT TRUE,
                                INPUT BUFFER tt-craptfc-old:HANDLE,
                                INPUT BUFFER tt-craptfc-new:HANDLE).

    RETURN "OK".            

END PROCEDURE.
                  

PROCEDURE pi_atualiza_data_manutencao_telefone:
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_atualiz_data_manut_fone
    aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,
                                 INPUT par_nrdconta,
                                 OUTPUT 0,
                                 OUTPUT ""). /* pr_dscritic */

    CLOSE STORED-PROC pc_atualiz_data_manut_fone
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_atualiz_data_manut_fone.pr_dscritic
                              WHEN pc_atualiz_data_manut_fone.pr_dscritic <> ?
                              .


END PROCEDURE.

/***************************************************************************
Procedure para a rotina TELEFONES da tela ATENDA.
Se nao achar telefone para o 1.tit, buscar nos 2.tit, senao pegar da ass.
***************************************************************************/
PROCEDURE obtem-telefone-titulares:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-telefone-cooperado.


    DEF  VAR         par_msgconta AS CHAR                           NO-UNDO.
    DEF  VAR         aux_flgerror AS LOGI INIT TRUE                 NO-UNDO.


    IF  par_flgerlog   THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Consulta telefones da conta".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-telefone-cooperado.

    TELEFONE:    
    DO WHILE TRUE:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                           crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapass   THEN
             DO:
                 ASSIGN aux_cdcritic = 9.                       
                 LEAVE.
             END.

        IF   crapass.inpessoa = 1   THEN
             DO:
                 FOR EACH crapttl WHERE 
                          crapttl.cdcooper = par_cdcooper   AND
                          crapttl.nrdconta = par_nrdconta   NO-LOCK
                          BY crapttl.idseqttl:

                     RUN obtem-telefone-cooperado 
                                        (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nmdatela,
                                         INPUT par_idorigem,
                                         INPUT par_nrdconta,
                                         INPUT crapttl.idseqttl,
                                         INPUT FALSE,
                                        OUTPUT par_msgconta,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-telefone-cooperado).

                     IF   RETURN-VALUE <> "OK"   THEN
                          LEAVE TELEFONE.                          

                     /* Se achou telefones, entao sai */
                     IF   TEMP-TABLE tt-telefone-cooperado:HAS-RECORDS   THEN
                          LEAVE.

                 END. /* For each Titulares */     
             END.
        ELSE
             DO:
                 RUN obtem-telefone-cooperado
                             (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_nmdatela,
                              INPUT par_idorigem,
                              INPUT par_nrdconta,
                              INPUT 1, /* 1. Tit */
                              INPUT FALSE,
                             OUTPUT par_msgconta,
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-telefone-cooperado).

                 IF   RETURN-VALUE <> "OK"   THEN
                      LEAVE.                                                                          
             END.

        /* Passar para tabela devolvida como Parametro */
        IF   TEMP-TABLE tt-telefone-cooperado:HAS-RECORDS   THEN
             FOR EACH tt-telefone-cooperado:
             
                 ASSIGN tt-telefone-cooperado.nrfonres =
                              STRING(tt-telefone-cooperado.nrtelefo).
             
             END.
        
        ASSIGN aux_flgerror = FALSE.
        LEAVE.

    END.

    IF   aux_flgerror   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   NOT AVAIL tt-erro   THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
             ELSE
                  ASSIGN aux_dscritic = tt-erro.dscritic.

             IF  par_flgerlog  THEN
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


/*............................ PROCEDURES INTERNAS ..........................*/


PROCEDURE critica-lock:

    DEF  INPUT PARAM par_nrdrecid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdbanco AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmtabela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_loginusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmusuari AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdevice AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtconnec AS CHAR                                    NO-UNDO.
    DEF VAR aux_numipusr AS CHAR                                    NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "Registro sendo alterado em outro terminal (" + 
                          par_nmtabela + ").".

    IF  par_idorigem = 3  THEN  /** InternetBank **/
        RETURN.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        RETURN.
        
    RUN acha-lock IN h-b1wgen9999 (INPUT par_nrdrecid,
                                   INPUT par_nmdbanco,
                                   INPUT par_nmtabela,
                                  OUTPUT aux_loginusr,
                                  OUTPUT aux_nmusuari,
                                  OUTPUT aux_dsdevice,
                                  OUTPUT aux_dtconnec, 
                                  OUTPUT aux_numipusr).

    DELETE PROCEDURE h-b1wgen9999.

    ASSIGN aux_dscritic = aux_dscritic + " Operador: " + 
                          aux_loginusr + " - " + aux_nmusuari.

    RETURN "OK".

END PROCEDURE.


/*...........................................................................*/
                               

