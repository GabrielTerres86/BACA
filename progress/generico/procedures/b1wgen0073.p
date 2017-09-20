/*.............................................................................

    Programa: b1wgen0073.p
    Autor   : Jose Luis Marchezoni (DB1)
    Data    : Maio/2010                   Ultima atualizacao: 17/04/2017   

    Objetivo  : Tranformacao BO tela CONTAS - CONTATOS

    Alteracoes: 12/08/2010 - Ajuste na validacao de UF (David).
    
                11/03/2011 - Retirar o campo dsdemail da crapass (Gabriel).
                
                15/04/2011 - Inclusão de validação de CEP. (André - DB1)
                
                05/08/2013 - Alterado para pegar o telefone da tabela 
                             craptfc ao invés da crapass (James).
                             
                19/08/2013 - Incluido a chamada da procedure 
                             "atualiza_data_manutencao_cadastro" dentro da
                             procedure "grava_dados" (James).
                             
                13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                          
                02/10/2014 - Remoção da validação que obrigava a existência
                             de 1 contato cooperado assoiciado. (Dionathan)
                             
                23/10/2014 - Condição da remoção da validação de contato apenas
                             para VIACREDI SD. 205276 (Lunelli).
                             
				17/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							 (Adriano - P339).
                             
.............................................................................*/

/*............................. DEFINICOES ..................................*/
{ sistema/generico/includes/b1wgen0073tt.i &TT-LOG=SIM }
{ sistema/generico/includes/b1wgen0168tt.i}
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.

/*............................. PROCEDURES ..................................*/
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-crapavt.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca dados do Contato"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno  = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapavt.
        EMPTY TEMP-TABLE tt-erro.   

        FiltroBusca: DO ON ERROR UNDO FiltroBusca, LEAVE FiltroBusca:
            IF  par_nrdrowid <> ? THEN
                DO:
                    RUN Busca_Dados_Id
                        ( INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT par_nrdrowid,
                          INPUT par_cddopcao,
                         OUTPUT aux_cdcritic,
                         OUTPUT aux_dscritic ).
                END.
            ELSE
                IF  par_nrdctato <> 0 THEN
                    DO:
                        RUN Busca_Dados_Cto
                            ( INPUT par_cdcooper,
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT par_nrdctato,
                              INPUT par_cddopcao,
                             OUTPUT aux_cdcritic,
                             OUTPUT aux_dscritic ).
                    END.
        END.

        IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
            LEAVE Busca.

        IF  par_cddopcao <> "C" THEN
            LEAVE Busca.

        /* Carrega a lista de contatos */
        FOR EACH crapavt FIELDS(nrdctato nmdavali nrtelefo dsdemail)
                         WHERE crapavt.cdcooper = par_cdcooper   AND
                               crapavt.tpctrato = 5 /*contato*/  AND
                               crapavt.nrdconta = par_nrdconta   AND
                               crapavt.nrctremp = par_idseqttl   NO-LOCK:

           CREATE tt-crapavt.
           ASSIGN 
               tt-crapavt.cddctato = TRIM(STRING(crapavt.nrdctato,
                                                 "zzzz,zzz,9"))
               tt-crapavt.nrdctato = crapavt.nrdctato
               tt-crapavt.nmdavali = crapavt.nmdavali
               tt-crapavt.nrtelefo = crapavt.nrtelefo
               tt-crapavt.dsdemail = crapavt.dsdemail
               tt-crapavt.dsdemiss = NO
               tt-crapavt.nrdrowid = ROWID(crapavt).

           /* Se for associado, pega os dados da crapass */
            IF  tt-crapavt.nrdctato <> 0 THEN
                DO:
                    FOR FIRST crapass FIELDS(cdcooper nrdconta dtdemiss nmprimtl)
                                      WHERE 
                                      crapass.cdcooper = par_cdcooper AND
                                      crapass.nrdconta = tt-crapavt.nrdctato
                                      NO-LOCK:

                        /* Telefones */
                        FOR FIRST craptfc FIELDS(nrtelefo)
                            WHERE craptfc.cdcooper = crapass.cdcooper AND
                                  craptfc.nrdconta = crapass.nrdconta AND
                                  craptfc.idseqttl = 1                AND
                                  craptfc.cdseqtfc = 1 NO-LOCK:
                        END.
                                                  
                        /* Emails */
                        FOR FIRST crapcem FIELDS(dsdemail)
                            WHERE crapcem.cdcooper = crapass.cdcooper AND
                                  crapcem.nrdconta = crapass.nrdconta AND
                                  crapcem.idseqttl = 1                AND
                                  crapcem.cddemail = 1 NO-LOCK:
                        END.
                        
                        ASSIGN 
                            tt-crapavt.nmdavali = crapass.nmprimtl
                            tt-crapavt.nrtelefo = IF AVAILABLE craptfc THEN
                                                     STRING(craptfc.nrtelefo)
                                                  ELSE ""
                            tt-crapavt.dsdemail = crapcem.dsdemail
                                                  WHEN AVAIL crapcem 
                            tt-crapavt.dsdemiss = IF crapass.dtdemiss <> ? THEN
                                                     YES 
                                                  ELSE NO.
                    END.
                END.
        END.

        LEAVE Busca.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,           
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE
        ASSIGN aux_retorno = "OK".

    IF  par_flgerlog AND par_cddopcao = "C" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Dados_Id:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF BUFFER crabavt FOR crapavt.

    ASSIGN aux_retorno = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapavt.
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crapavt FIELDS(nmdavali nrcepend dsendres nrendere complend
                                 nmbairro nmcidade cdufresd nrcxapst nrtelefo
                                 dsdemail nrdctato)
                          WHERE ROWID(crapavt) = par_nrdrowid NO-LOCK.
        END.

        IF  NOT AVAILABLE crapavt THEN
            DO:
               ASSIGN par_dscritic = "Contato nao encontrado.".
               LEAVE Busca.
            END.

        IF  crapavt.nrdctato = 0 THEN
            DO:
                CREATE tt-crapavt.
                ASSIGN
                    tt-crapavt.nrdctato = crapavt.nrdctato
                    tt-crapavt.nmdavali = crapavt.nmdavali
                    tt-crapavt.nrcepend = crapavt.nrcepend
                    tt-crapavt.dsendere = crapavt.dsendres[1]
                    tt-crapavt.nrendere = crapavt.nrendere
                    tt-crapavt.complend = crapavt.complend
                    tt-crapavt.nmbairro = crapavt.nmbairro
                    tt-crapavt.nmcidade = crapavt.nmcidade
                    tt-crapavt.cdufende = CAPS(crapavt.cdufresd)
                    tt-crapavt.nrcxapst = crapavt.nrcxapst
                    tt-crapavt.nrtelefo = crapavt.nrtelefo
                    tt-crapavt.dsdemail = crapavt.dsdemail
                    tt-crapavt.nrdrowid = ROWID(crapavt).
            END.
        ELSE 
            DO:
               CASE par_cddopcao:
                   WHEN "A" THEN DO:
                       ASSIGN par_dscritic = "Nao e possivel alterar um " + 
                                             "contato que e associado da" + 
                                             " cooperativa.".
                   END.
                   WHEN "E" THEN DO:
                       /* Por hora, somente a Viacredi não irá exigir o contato. A area de canais 
                          está verificando com as demais cooperativas. Por este motivo está 
                          fixo Viacredi, e não fizemos um parametro */
                       IF  par_cdcooper <> 1 THEN
                           DO:
                               /* Para o 1o titular, verifica se existe mais 
                                  contatos cooperados */
                               IF  crapavt.nrctremp = 1 AND
                                   NOT CAN-FIND(FIRST crabavt WHERE 
                                                crabavt.cdcooper = par_cdcooper   AND
                                                crabavt.nrdconta = par_nrdconta   AND
                                                crabavt.tpctrato = 5              AND
                                                crabavt.nrctremp = par_nrctremp   AND
                                                crabavt.nrdctato <> 0             AND
                                                ROWID(crabavt)   <> par_nrdrowid) THEN
                                    DO:
                                       par_dscritic = "Deve existir pelo menos 1 " + 
                                                      "contato cooperado.".
                                    END.
                           END.
                   END.
               END CASE.

               IF  par_dscritic <> "" THEN
                   LEAVE Busca.

               RUN Busca_Dados_Cto
                   ( INPUT crapavt.cdcooper,
                     INPUT crapavt.nrdconta,
                     INPUT crapavt.nrctremp,
                     INPUT crapavt.nrdctato,
                     INPUT par_cddopcao,
                    OUTPUT par_cdcritic,
                    OUTPUT par_dscritic ).
            END.

        IF  AVAILABLE tt-crapavt THEN
            ASSIGN tt-crapavt.nrdrowid = ROWID(crapavt).

        LEAVE Busca.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_retorno = "OK".

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Dados_Cto:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    ASSIGN aux_retorno = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapavt.
        EMPTY TEMP-TABLE tt-erro.

        /* nao pode ter no mesmo nr. da conta do associado */
        IF  par_nrdctato = par_nrdconta THEN
            DO:
               ASSIGN par_cdcritic = 121.
               LEAVE Busca.
            END.

        /* verificar se o resp.legal ja esta cadastrado */
        IF  CAN-FIND(FIRST crapavt WHERE
                           crapavt.cdcooper = par_cdcooper  AND
                           crapavt.tpctrato = 5 /*contato*/ AND
                           crapavt.nrdconta = par_nrdconta  AND
                           crapavt.nrctremp = par_nrctremp  AND
                           crapavt.nrdctato = par_nrdctato) AND 
            par_cddopcao = "I" AND par_nrdctato <> 0 THEN
            DO:
               ASSIGN par_dscritic = "Contato ja existente para a conta".
               LEAVE Busca.
            END.

        FOR FIRST crapass FIELDS(cdcooper nrdconta nmprimtl
                                 indnivel cdtipcta)
                          WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdctato NO-LOCK:
        END.

        IF  NOT AVAILABLE crapass THEN
            DO:
               ASSIGN par_cdcritic = 9.
               LEAVE Busca.
            END.

        IF  (crapass.indnivel < 2) AND (crapass.cdtipcta > 7) THEN
            DO:
               ASSIGN par_dscritic = "Contato com cadastro incompleto".
               LEAVE Busca.
            END.

        CREATE tt-crapavt.

        /* Endereco */
        FOR FIRST crapenc FIELDS(nrcepend dsendere nrendere complend nmbairro 
                                 nmcidade cdufende nrcxapst)
            WHERE crapenc.cdcooper = crapass.cdcooper AND
                  crapenc.nrdconta = crapass.nrdconta AND
                  crapenc.idseqttl = 1                AND
                  crapenc.cdseqinc = 1 NO-LOCK:

            ASSIGN
                tt-crapavt.nrcepend = crapenc.nrcepend
                tt-crapavt.dsendere = crapenc.dsendere
                tt-crapavt.nrendere = crapenc.nrendere
                tt-crapavt.complend = crapenc.complend
                tt-crapavt.nmbairro = crapenc.nmbairro
                tt-crapavt.nmcidade = crapenc.nmcidade
                tt-crapavt.cdufende = CAPS(crapenc.cdufende)
                tt-crapavt.nrcxapst = crapenc.nrcxapst.
        END.

        /* Telefones */
        FOR FIRST craptfc FIELDS(nrtelefo)
            WHERE craptfc.cdcooper = crapass.cdcooper AND
                  craptfc.nrdconta = crapass.nrdconta AND
                  craptfc.idseqttl = 1                AND
                  craptfc.cdseqtfc = 1 NO-LOCK:
        END.

        /* Emails */
        FOR FIRST crapcem FIELDS(dsdemail)
            WHERE crapcem.cdcooper = crapass.cdcooper AND
                  crapcem.nrdconta = crapass.nrdconta AND
                  crapcem.idseqttl = 1                AND
                  crapcem.cddemail = 1 NO-LOCK:
        END.

        ASSIGN 
            tt-crapavt.nrdctato = crapass.nrdconta
            tt-crapavt.nmdavali = crapass.nmprimtl
            tt-crapavt.nrtelefo = IF AVAILABLE craptfc THEN
                                     STRING(craptfc.nrtelefo)
                                  ELSE ""
            tt-crapavt.dsdemail = crapcem.dsdemail
                                  WHEN AVAIL crapcem.

        LEAVE Busca.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_retorno = "OK".

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Valida_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdavali AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelefo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdemail AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Valida dados do Contato"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        /* nao pode ser o mesmo numero de conta */
        IF  par_nrdctato = par_nrdconta  THEN
            DO:
               ASSIGN aux_cdcritic = 121.
               LEAVE Valida.
            END.

        /* verificar se o contato ja esta cadastrado */
        IF  par_cddopcao = "I"  AND 
            par_nrdctato <> 0   AND
            CAN-FIND(FIRST crapavt WHERE
                           crapavt.cdcooper = par_cdcooper  AND
                           crapavt.tpctrato = 5 /*contato*/ AND
                           crapavt.nrdconta = par_nrdconta  AND
                           crapavt.nrctremp = par_idseqttl  AND
                           crapavt.nrdctato = par_nrdctato) THEN
            DO:
               ASSIGN aux_dscritic = "Contato ja existente para a conta".
               LEAVE Valida.
            END.

        IF  par_nmdavali = ""  THEN
            DO:               
               ASSIGN aux_dscritic = "Informe o nome do Contato.".
               LEAVE Valida.
            END.
        
        IF  par_nrdctato = 0  THEN
            DO:
                IF  par_cddopcao = "I"  AND
                    CAN-FIND(FIRST crapavt WHERE 
                             crapavt.cdcooper = par_cdcooper AND
                             crapavt.nrdconta = par_nrdconta AND
                             crapavt.tpctrato = 5            AND
                             crapavt.nmdavali = par_nmdavali AND
                             crapavt.nrctremp = par_idseqttl NO-LOCK) THEN
                    DO:
                       ASSIGN aux_dscritic = "Contato ja existente para a " + 
                                             "conta.".
                       LEAVE Valida.
                    END.
                ELSE
                IF  par_cddopcao = "A"  AND 
                    CAN-FIND(FIRST crapavt WHERE 
                             crapavt.cdcooper = par_cdcooper AND
                             crapavt.nrdconta = par_nrdconta AND
                             crapavt.tpctrato = 5            AND
                             crapavt.nmdavali = par_nmdavali AND
                             crapavt.nrctremp = par_idseqttl AND
                             ROWID(crapavt)  <> par_nrdrowid NO-LOCK) THEN
                    DO:
                       ASSIGN aux_dscritic = "Contato ja existente para a " + 
                                             "conta.".
                       LEAVE Valida.
                    END.

                IF  par_nrcepend <> 0 OR par_dsendere <> "" THEN
                    DO:
                        IF  NOT CAN-FIND(FIRST crapdne 
                                 WHERE crapdne.nrceplog = par_nrcepend)  THEN
                            DO:
                                ASSIGN aux_dscritic = "CEP nao cadastrado.".
                                LEAVE Valida.
                            END.

                        IF  NOT CAN-FIND(FIRST crapdne
                                         WHERE crapdne.nrceplog = par_nrcepend  
                                           AND (TRIM(par_dsendere) MATCHES 
                                               ("*" + TRIM(crapdne.nmextlog) + "*")
                                            OR TRIM(par_dsendere) MATCHES
                                               ("*" + TRIM(crapdne.nmreslog) + "*"))) 
                            THEN
                            DO:
                            
                                ASSIGN aux_dscritic = "Endereco nao pertence " +
                                                      " ao CEP.".
                                LEAVE Valida.
                            END.
        
                        IF  LOOKUP(par_cdufende,"AC,AL,AP,AM,BA,CE,DF,ES,GO," +
                                        "MA,MT,MS,MG,PA,PB,PR,PE,PI,RJ,RN," +
                                        "RS,RO,RR,SC,SP,SE,TO") = 0 THEN
                            DO:
                               ASSIGN aux_cdcritic = 33.
                               LEAVE Valida.
                            END.
        
                        IF  par_nmcidade = "" OR par_cdufende = ""  THEN
                            DO:
                               ASSIGN aux_dscritic = "Cidade e UF devem " +
                                                     "ser informados.".
                               LEAVE Valida.
                            END. 
                    END.
        
                IF  par_nrtelefo = "" AND par_dsdemail = "" THEN
                    DO:
                       ASSIGN aux_dscritic = "O telefone ou o email deve " +
                                             "estar  preenchido.".
                       LEAVE Valida.
                    END.
            END.
        LEAVE Valida.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,           
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE
        ASSIGN aux_retorno = "OK".

    IF  par_flgerlog AND aux_retorno <> "OK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK"
                                   THEN TRUE ELSE FALSE),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdavali AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrendere AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complend AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelefo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdemail AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_sqcpfcgc AS INTE                                    NO-UNDO.

    DEF VAR h-b1wgen0168 AS HANDLE                                  NO-UNDO.

    DEF BUFFER crabavt FOR crapavt.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = (IF par_cddopcao = "E" THEN "Exclui" 
                        ELSE IF par_cddopcao = "I" THEN
                             "Inclui" ELSE "Altera") + 
                       " dados do Contato"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-erro.   

        ContadorAss: DO  aux_contador = 1 TO 10:

            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                               crapass.nrdconta = par_nrdconta 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF  NOT AVAILABLE crapass THEN
                DO:
                    IF  LOCKED(crapass) THEN
                        DO:
                           IF  aux_contador = 10 THEN
                               DO:
                                  ASSIGN aux_cdcritic = 341.
                                  LEAVE ContadorAss.
                               END.
                           ELSE 
                               DO:
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT ContadorAss.
                               END.
                        END.
                    ELSE 
                        DO:
                           ASSIGN aux_cdcritic = 9.
                           LEAVE ContadorAss.
                        END.
                END.
            ELSE 
                LEAVE ContadorAss.
        END.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        ContadorAvt: DO aux_contador = 1 TO 10:
            FIND crapavt WHERE ROWID(crapavt) = par_nrdrowid 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapavt THEN
                DO:
                    IF  LOCKED(crapavt) THEN
                        DO:
                           IF  aux_contador = 10 THEN
                               DO:
                                  ASSIGN aux_cdcritic = 341.
                                  LEAVE ContadorAvt.
                               END.
                           ELSE 
                               DO:
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT ContadorAvt.
                               END.
                        END.
                    ELSE 
                        DO:
                           IF  par_cddopcao = "I" THEN
                               DO:
                                   ASSIGN aux_sqcpfcgc = 1.

                                   FOR LAST crabavt FIELDS(nrcpfcgc) WHERE 
                                       crabavt.cdcooper = par_cdcooper  AND
                                       crabavt.tpctrato = 5 /*contato*/ AND
                                       crabavt.nrdconta = par_nrdconta  AND
                                       crabavt.nrctremp = par_idseqttl
                                       NO-LOCK:

                                       aux_sqcpfcgc = crabavt.nrcpfcgc + 1.
                                   END.

                                   CREATE crapavt.
                                   ASSIGN
                                      crapavt.cdcooper = par_cdcooper
                                      crapavt.tpctrato = 5 /*contato*/   
                                      crapavt.nrdconta = par_nrdconta 
                                      crapavt.nrdctato = par_nrdctato 
                                      crapavt.nrctremp = par_idseqttl 
                                      crapavt.nrcpfcgc = aux_sqcpfcgc NO-ERROR.
                                   VALIDATE crapavt. 

                                   IF  ERROR-STATUS:ERROR THEN
                                       DO:
                                         aux_dscritic = 
                                             ERROR-STATUS:GET-MESSAGE(1).
                                       END.

                                   LEAVE ContadorAvt.
                               END.
                           ELSE 
                               DO:
                                  aux_dscritic = "Dados do Contato nao foram"
                                                 + " encontrados.".
                                  LEAVE ContadorAvt.
                               END.
                        END.
                END.
            ELSE 
                LEAVE ContadorAvt.
        END.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        EMPTY TEMP-TABLE tt-crapavt-ant.
        EMPTY TEMP-TABLE tt-crapavt-atl.

        CREATE tt-crapavt-ant.
        IF  par_cddopcao <> "I" THEN
            BUFFER-COPY crapavt TO tt-crapavt-ant.
        
        CASE par_cddopcao:
            WHEN "E" THEN DO:
               IF  par_idseqttl = 1 THEN
                   DO:
                       IF  crapass.nrctacto = par_nrdctato  THEN
                           ASSIGN crapass.nrctacto = 0.
                       ELSE
                           IF  crapass.nrctaprp = par_nrdctato  THEN
                               ASSIGN crapass.nrctaprp = 0.  
                   END.
            END.
            WHEN "A" OR WHEN "I" THEN DO:
                IF  par_idseqttl = 1 AND par_cddopcao = "I" THEN
                    DO:
                       IF  crapass.nrctacto = 0 THEN
                           ASSIGN crapass.nrctacto = par_nrdctato.
                       ELSE
                           IF  crapass.nrctaprp = 0 THEN
                               ASSIGN crapass.nrctaprp = par_nrdctato.  
                    END.
            END.
            OTHERWISE DO:
                ASSIGN aux_dscritic = "Opcao deve ser (I=Incluir) (A=Alterar)" 
                                      + " ou (E=Excluir).".
                UNDO Grava, LEAVE Grava.
            END.
        END CASE.

        IF  par_cddopcao <> "I"  THEN
            DO:
                { sistema/generico/includes/b1wgenalog.i }
            END.

        /* Se nao for associado ou esta demitido guarda os dados */
        IF  par_nrdctato = 0 AND par_cddopcao <> "E" THEN
            ASSIGN 
                crapavt.nrdctato    = par_nrdctato 
                crapavt.nmdavali    = CAPS(par_nmdavali)
                crapavt.nrcepend    = par_nrcepend 
                crapavt.dsendres[1] = CAPS(par_dsendere)
                crapavt.nrendere    = par_nrendere 
                crapavt.complend    = CAPS(par_complend)
                crapavt.nmbairro    = CAPS(par_nmbairro)
                crapavt.nmcidade    = CAPS(par_nmcidade)
                crapavt.cdufresd    = par_cdufende
                crapavt.nrcxapst    = par_nrcxapst 
                crapavt.nrtelefo    = par_nrtelefo
                crapavt.dsdemail    = par_dsdemail.

        IF  par_cddopcao <> "I"  THEN
            DO:
                { sistema/generico/includes/b1wgenllog.i }
            END.

        CREATE tt-crapavt-atl.
        IF  par_cddopcao <> "E" THEN
            BUFFER-COPY crapavt TO tt-crapavt-atl.
        ELSE
            DELETE crapavt.

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
            IN h-b1wgen0168(INPUT TABLE tt-crapcyb,
                            OUTPUT aux_cdcritic,
                            OUTPUT aux_dscritic).

        IF RETURN-VALUE <> "OK" THEN
           UNDO Grava, LEAVE Grava.
        /* FIM - Atualizar os dados da tabela crapcyb */

        ASSIGN aux_retorno = "OK".

        LEAVE Grava.
    END.

    IF VALID-HANDLE(h-b1wgen0168) THEN
       DELETE PROCEDURE(h-b1wgen0168).

    RELEASE crapavt.
    RELEASE crapass.
    
    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_retorno = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,           
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.

    IF  par_flgerlog THEN
        RUN proc_gerar_log_tab
            ( INPUT par_cdcooper,
              INPUT par_cdoperad,
              INPUT aux_dscritic,
              INPUT aux_dsorigem,
              INPUT aux_dstransa,
              INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
              INPUT par_idseqttl,
              INPUT par_nmdatela,
              INPUT par_nrdconta,
              INPUT YES,
              INPUT BUFFER tt-crapavt-ant:HANDLE,
              INPUT BUFFER tt-crapavt-atl:HANDLE ).

    RETURN aux_retorno.

END PROCEDURE.
