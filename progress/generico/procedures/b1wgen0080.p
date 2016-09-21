
/*.............................................................................

    Programa: b1wgen0080.p
    Autor   : Guilherme
    Data    : Agosto/2011                   Ultima atualizacao:   13/12/2013

    Objetivo  : Tranformacao BO tela CONTAS - PARTICIPACAO EM OUTRAS EMPRESAS

    Alteracoes: 02/12/2011 - Alterado para permitir a exlusao de uma empresa
                             participante, caso haja algum representante com
                             percentual societario; e nao como vinha sendo
                             feito, atrelado ao cargo de "SOCIO/PROPRIETARIO".
                             (Fabricio)
   
                14/12/2012 - Implementado log para tela LOGTEL das operacoes
                             inclusao, alteracao e exclusao (Tiago).
                             
                28/03/2013 - Incluido a chamada da procedure alerta_fraude
                             dentro da Grava_Dados (Adriano).     
                             
                05/06/2013 - Remover procedures grava_grupo_economico e
                             exclui_grupo_economico (Lucas R.)        
                             
                19/08/2013 - Incluido a chamada da procedure 
                             "atualiza_data_manutencao_cadastro" dentro da
                             procedure "grava_dados" (James).
                             
                13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)      
                             
.............................................................................*/


/*............................. DEFINICOES ..................................*/
{ sistema/generico/includes/b1wgen0080tt.i &TT-LOG=SIM }
{ sistema/generico/includes/b1wgen0168tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfcto AS DECI                                           NO-UNDO.
DEF VAR aux_msgdolog AS CHAR                                           NO-UNDO.

FUNCTION ValidaUf      RETURNS LOGICAL 
    ( INPUT par_cdufdavt AS CHARACTER ) FORWARD.

FUNCTION ValidaCpfCnpj RETURNS LOGICAL
    ( INPUT  par_nrcpfcgc AS DECIMAL,
      OUTPUT par_cdcritic AS INTEGER ) FORWARD.

FUNCTION CarregaCpfCnpj RETURNS DECIMAL
    ( INPUT par_cdcpfcgc AS CHARACTER ) FORWARD.

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
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-crapepa.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca dados da empresa participante"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno  = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapepa.
        EMPTY TEMP-TABLE tt-erro.   

        FiltroBusca: DO ON ERROR UNDO FiltroBusca, LEAVE FiltroBusca:           
            IF  par_nrdrowid <> ? THEN
               DO:
                    RUN Busca_Dados_Id
                        ( INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_nrdrowid,
                          INPUT par_cddopcao,
                         OUTPUT aux_cdcritic,
                         OUTPUT aux_dscritic ) NO-ERROR.

                    IF  ERROR-STATUS:ERROR THEN
                        DO:
                           ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                           LEAVE FiltroBusca.
                        END.
                END.
            ELSE
                IF  par_nrdctato <> 0 OR par_nrcpfcto <> 0 THEN
                    DO:
                        RUN Busca_Dados_Cto
                            ( INPUT par_cdcooper,
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT par_nrdctato,
                              INPUT par_nrcpfcto,
                              INPUT par_cddopcao,
                             OUTPUT aux_cdcritic,
                             OUTPUT aux_dscritic ) NO-ERROR.
                        IF  ERROR-STATUS:ERROR THEN
                            DO:
                               ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                               LEAVE FiltroBusca.
                            END.
                    END.

        END.

        IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
            LEAVE Busca.

        IF  par_cddopcao <> "C" THEN
            LEAVE Busca.

        /* se encontrou registros na pesquisa [C], nao e preciso o for each */
        IF  TEMP-TABLE tt-crapepa:HAS-RECORDS THEN
            LEAVE Busca.

        /* Carrega a lista de procuradores */
        FOR EACH crapepa WHERE crapepa.cdcooper = par_cdcooper   AND
                               crapepa.nrdconta = par_nrdconta   NO-LOCK:
            RUN Busca_Dados_Id
                ( INPUT par_cdcooper,
                  INPUT par_nrdconta,
                  INPUT ROWID(crapepa),
                  INPUT par_cddopcao,
                 OUTPUT aux_cdcritic,
                 OUTPUT aux_dscritic ).
            
            IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
                UNDO Busca, LEAVE Busca.

        END. /* FOR EACH crapepa ... */

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
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF BUFFER crabepa FOR crapepa.
    DEF BUFFER craeepa FOR crapepa.
    DEF BUFFER craeavt FOR crapavt.

    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.
    DEFINE VARIABLE aux_dsdrendi AS CHARACTER   NO-UNDO.

    ASSIGN aux_retorno = "NOK".

    BuscaId: DO ON ERROR UNDO BuscaId, LEAVE BuscaId:
        EMPTY TEMP-TABLE tt-erro.

        FIND crabepa WHERE ROWID(crabepa) = par_nrdrowid NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crabepa THEN
            DO:
               ASSIGN par_dscritic = "Empresa participante nao encontrado".
               LEAVE BuscaId.
            END.

       /* Verifica se ha mais de um socio pra poder excluir */
       IF  par_cddopcao = "E" AND 
           CAN-FIND(FIRST crapass WHERE
                          crapass.cdcooper = par_cdcooper AND
                          crapass.nrdconta = par_nrdconta AND
                          crapass.inpessoa > 1) THEN
           DO:
              IF  NOT CAN-FIND(FIRST craeepa WHERE
                               craeepa.cdcooper = par_cdcooper AND
                               craeepa.nrdconta = par_nrdconta AND
                               ROWID(craeepa)  <> par_nrdrowid NO-LOCK) AND
                  NOT CAN-FIND(FIRST craeavt WHERE
                               craeavt.cdcooper = par_cdcooper AND
                               craeavt.tpctrato = 6 /*jur*/    AND
                               craeavt.nrdconta = par_nrdconta AND
                               /*craeavt.dsproftl = "SOCIO/PROPRIETARIO" NO-LOCK) THEN*/
                               craeavt.persocio > 0 NO-LOCK) THEN
                  DO:
                     ASSIGN par_dscritic = "Eh obrigatorio o cadastro " + 
                     "de no minimo um socio.".
                     LEAVE BuscaId.
                  END.
           END.

       /* Se for associado, pega os dados da crapass */
       IF  crabepa.nrctasoc <> 0 THEN
           DO:
              RUN Busca_Dados_Ass
                  ( INPUT crabepa.cdcooper,
                    INPUT crabepa.nrdconta,
                    INPUT 0,
                    INPUT crabepa.nrctasoc,
                   OUTPUT par_cdcritic,
                   OUTPUT par_dscritic ).
           END.
       ELSE
           DO:
              CREATE tt-crapepa.
              BUFFER-COPY crabepa EXCEPT nrdconta TO tt-crapepa
                  ASSIGN 
                     tt-crapepa.cddconta = TRIM(STRING(crabepa.nrctasoc,
                                                       "zzzz,zzz,9"))
                     tt-crapepa.nrdrowid = ROWID(crabepa)
                     tt-crapepa.vledvmto = crabepa.vledvmto
                     tt-crapepa.cdcpfcgc = STRING(STRING(crabepa.nrdocsoc,
                                                      "99999999999999"),
                                                "xx.xxx.xxx/xxxx-xx") NO-ERROR.
    
              IF  ERROR-STATUS:ERROR THEN
                  DO:
                     ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                     LEAVE BuscaId.
                  END.

              FIND gncdntj WHERE gncdntj.cdnatjur = tt-crapepa.natjurid 
                          NO-LOCK NO-ERROR.

              IF   tt-crapepa.cdseteco <> 0   THEN
                   DO:
                       FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                                          craptab.cdacesso = "SETORECONO" AND
                                          craptab.tpregist = tt-crapepa.cdseteco
                                          NO-LOCK NO-ERROR.

                       ASSIGN tt-crapepa.nmseteco = IF   AVAILABLE craptab THEN 
                                                           craptab.dstextab
                                                      ELSE 
                                                           "Nao cadastrado".
                   END.

              IF   tt-crapepa.cdrmativ <> 0   AND
                   tt-crapepa.cdseteco <> 0   THEN
                   DO:
                        FIND gnrativ WHERE 
                                     gnrativ.cdseteco = tt-crapepa.cdseteco AND
                                     gnrativ.cdrmativ = tt-crapepa.cdrmativ
                                     NO-LOCK NO-ERROR.

                        ASSIGN tt-crapepa.dsrmativ = IF   AVAILABLE gnrativ THEN 
                                                            gnrativ.nmrmativ
                                                       ELSE 
                                                            "NAO CADASTRADO".
                   END.

              ASSIGN
              tt-crapepa.dsnatjur = IF   AVAILABLE gncdntj THEN 
                                           gncdntj.dsnatjur
                                      ELSE 
                                           "Nao Cadastrado".


           END.
        IF  AVAILABLE tt-crapepa THEN
            ASSIGN 
               tt-crapepa.dtadmiss = crabepa.dtadmiss
               tt-crapepa.persocio = crabepa.persocio.
          LEAVE BuscaId.
    END.
    
    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_retorno = "OK".

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Dados_Cto:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabepa FOR crapepa.

    ASSIGN aux_retorno = "NOK".

    BuscaCto: DO ON ERROR UNDO BuscaCto, LEAVE BuscaCto:
        EMPTY TEMP-TABLE tt-erro.

        IF  par_cddopcao = "I" THEN
            DO:
               /* Busca se o procurador ja foi cadastrado - CPF */
               IF  par_nrcpfcto <> 0 THEN
                   DO:
                      IF  CAN-FIND(FIRST crabepa WHERE 
                                   crabepa.cdcooper = par_cdcooper AND
                                   /*
                                   nao tem isto
                                   crabepa.tpctrato = 6 /* jur */  AND
                                   */
                                   crabepa.nrdconta = par_nrdconta AND
                                   /*
                                   crabepa.nrctremp = par_idseqttl AND
                                   */
                                   crabepa.nrdocsoc = par_nrcpfcto) THEN
                          DO:
                             ASSIGN par_dscritic = "Participante ja cadastrado " +
                                                   "para o associado.".
                             LEAVE BuscaCto.
                          END.
                   END.

               /* Busca se o procurador ja foi cadastrado - NR.DA CONTA */
               IF  par_nrdctato <> 0 THEN
                   DO:
                      IF  CAN-FIND(FIRST crabepa WHERE 
                                   crabepa.cdcooper = par_cdcooper AND
                                   /*
                                   nao tem isto
                                   crabepa.tpctrato = 6 /* jur */  AND
                                   */
                                   crabepa.nrdconta = par_nrdconta AND
                                   /*
                                   nao tem isto
                                   crabepa.nrctremp = par_idseqttl AND
                                   */
                                   crabepa.nrctasoc = par_nrdctato) THEN
                          DO:
                             ASSIGN par_dscritic = "Participante ja cadastrado " +
                                                   "para o associado.".
                             LEAVE BuscaCto.
                          END.
                   END.
            END.

        /* efetua a busca tanto por nr da conta como por cpf */
        IF  par_nrdctato <> 0  THEN
        DO:
            FOR FIRST crabass FIELDS(cdcooper nrdconta nrcpfcgc inpessoa)
                              WHERE crabass.cdcooper = par_cdcooper AND
                                    crabass.nrdconta = par_nrdctato NO-LOCK:
            END.
        END.
        ELSE
        IF  par_nrcpfcto <> 0  THEN
        DO:
            FOR FIRST crabass FIELDS(cdcooper nrdconta nrcpfcgc inpessoa)
                              WHERE crabass.cdcooper = par_cdcooper AND
                                    crabass.nrcpfcgc = par_nrcpfcto NO-LOCK:
            END.
        END.

        IF  NOT AVAILABLE crabass THEN
        DO:
           IF  par_nrdctato <> 0 THEN
               ASSIGN par_cdcritic = 9.

           LEAVE BuscaCto.
        END.

        IF  par_nrdconta = crabass.nrdconta  THEN
        DO:
            ASSIGN par_dscritic = "Titular da conta nao " +
                                  "pode ser participante.".
            LEAVE BuscaCto.
        END.

        /* somente pessoa juridica */
        IF  crabass.inpessoa = 1 THEN 
            DO:
               ASSIGN par_cdcritic = 331.
               LEAVE BuscaCto.
            END.

        RUN Busca_Dados_Ass
            ( INPUT crabass.cdcooper,
              INPUT par_nrdconta,
              INPUT par_idseqttl,
              INPUT crabass.nrdconta,
             OUTPUT par_cdcritic,
             OUTPUT par_dscritic ).

        LEAVE BuscaCto.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_retorno = "OK".

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Dados_Ass:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.

    DEFINE VARIABLE aux_dsdrendi AS CHARACTER   NO-UNDO.

    DEF BUFFER crabepa FOR crapepa.
    DEF BUFFER crabass FOR crapass.
    
    DEF BUFFER crabjur FOR crapjur.
    DEF BUFFER crabenc FOR crapenc.

    ASSIGN aux_retorno = "NOK".

    Busca: DO ON ERROR UNDO, RETURN "Erro na busca":
        EMPTY TEMP-TABLE tt-erro.

        FIND crabass WHERE crabass.cdcooper = par_cdcooper AND
                           crabass.nrdconta = par_nrdctato 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE  crabass THEN
            DO:
               ASSIGN aux_dscritic = "Associado nao cadastrado".
               LEAVE Busca.
            END.

        FIND crabjur WHERE crabjur.cdcooper = crabass.cdcooper AND
                           crabjur.nrdconta = crabass.nrdconta 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE  crabjur THEN
            DO:
               aux_dscritic = "Dados da pessoa Juridica nao encontrados".
               LEAVE Busca.
                END.

        FIND gncdntj WHERE gncdntj.cdnatjur = crabjur.natjurid 
                     NO-LOCK NO-ERROR.
        
        CREATE tt-crapepa.
        ASSIGN 
            tt-crapepa.cddconta = TRIM(STRING(crabass.nrdconta,
                                              "zzzz,zzz,9"))
            tt-crapepa.cdcooper = par_cdcooper
            tt-crapepa.nrdocsoc = crabass.nrcpfcgc
            tt-crapepa.nrctasoc = crabass.nrdconta
            tt-crapepa.nmprimtl = crabass.nmprimtl 
            tt-crapepa.cdcpfcgc = STRING(STRING(crabass.nrcpfcgc,
                                                  "99999999999999"),
                                           "xx.xxx.xxx/xxxx-xx")
            tt-crapepa.nmfansia = crabjur.nmfansia
            tt-crapepa.natjurid = crabjur.natjurid
            tt-crapepa.dsnatjur = IF   AVAILABLE gncdntj THEN 
                                         gncdntj.dsnatjur
                                    ELSE 
                                         "Nao Cadastrado"
            tt-crapepa.cdrmativ = crabjur.cdrmativ 
            tt-crapepa.dsendweb = crabjur.dsendweb 
            tt-crapepa.qtfilial = crabjur.qtfilial 
            tt-crapepa.qtfuncio = crabjur.qtfuncio 
            tt-crapepa.dtiniatv = crabjur.dtiniatv 
            tt-crapepa.cdseteco = crabjur.cdseteco.        
        
        IF   tt-crapepa.cdseteco <> 0   THEN
             DO:
                 FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                                    craptab.cdacesso = "SETORECONO" AND
                                    craptab.tpregist = tt-crapepa.cdseteco
                                    NO-LOCK NO-ERROR.

                 ASSIGN tt-crapepa.nmseteco = IF   AVAILABLE craptab THEN 
                                                     craptab.dstextab
                                                ELSE 
                                                     "Nao cadastrado".
             END.

        IF   tt-crapepa.cdrmativ <> 0   AND
             tt-crapepa.cdseteco <> 0   THEN
             DO:
                  FIND gnrativ WHERE 
                               gnrativ.cdseteco = tt-crapepa.cdseteco AND
                               gnrativ.cdrmativ = tt-crapepa.cdrmativ
                               NO-LOCK NO-ERROR.

                  ASSIGN tt-crapepa.dsrmativ = IF   AVAILABLE gnrativ THEN 
                                                      gnrativ.nmrmativ
                                                 ELSE 
                                                      "NAO CADASTRADO".
             END.

         /* Valor do endividamento */
         FOR EACH crapsdv FIELDS(vldsaldo tpdsaldo)
             WHERE crapsdv.cdcooper = crabass.cdcooper AND
                   crapsdv.nrdconta = crabass.nrdconta AND
                   CAN-DO("1,2,3,6",STRING(crapsdv.tpdsaldo)) 
                   NO-LOCK:

             ACCUMULATE crapsdv.vldsaldo (TOTAL).
         END.

         ASSIGN tt-crapepa.vledvmto = ACCUM TOTAL crapsdv.vldsaldo.


         FOR FIRST crabepa FIELDS(persocio dtadmiss vledvmto)
                           WHERE crabepa.cdcooper = crabass.cdcooper AND
                                 crabepa.nrdconta = par_nrdconta     AND
                                 crabepa.nrdocsoc = crabass.nrcpfcgc 
                                 NO-LOCK:
    
             ASSIGN 
                 tt-crapepa.nrdrowid = ROWID(crabepa)
                 tt-crapepa.persocio = crabepa.persocio
                 tt-crapepa.dtadmiss = crabepa.dtadmiss.
         END.


         
        LEAVE Busca.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

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
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmfatasi AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniatv AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnatjur AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdseteco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrmativ AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtadmsoc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_persocio AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vledvmto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro. 

    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_dssitcpf AS CHAR                                    NO-UNDO.
    DEF VAR tot_persocio AS DECI                                    NO-UNDO.
    DEF VAR tab_persocio AS DECI                                    NO-UNDO.


    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida dados da empresa participante"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_retorno  = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        ASSIGN aux_nrcpfcto = CarregaCpfCnpj(par_nrcpfcgc).

        IF  NOT ValidaCpfCnpj(aux_nrcpfcto,OUTPUT aux_cdcritic) THEN
            LEAVE Valida.

        CASE par_cddopcao:
            WHEN "I" THEN DO:
                RUN Valida_Inclui
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT par_nrdctato,
                      INPUT aux_nrcpfcto,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic ).
            END.
            WHEN "E" THEN DO:
                RUN Valida_Exclui
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT par_nrdctato,
                      INPUT aux_nrcpfcto,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic ).
            END.
        END CASE.

        IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
            LEAVE Valida.

        IF  par_cddopcao = "E" THEN
            LEAVE Valida.

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
                PERSISTENT SET h-b1wgen0060.

        /* Nome Fantasia */
        IF  par_nmfatasi = "" THEN
            DO:
                ASSIGN aux_dscritic = "Nome Fantasia deve ser informado." .
                LEAVE Valida.
            END.

        /* Natureza Juridica */
        IF  NOT CAN-FIND(gncdntj WHERE gncdntj.cdnatjur = par_cdnatjur NO-LOCK)
            OR par_cdnatjur = 0 THEN 
            DO:
                ASSIGN aux_dscritic = "Natureza Juridica incorreta.".
                LEAVE Valida.
            END.

        /* Inicio Atividade */                
        IF   par_dtiniatv = ? THEN
             DO:
                 ASSIGN aux_dscritic = "Data do inicio da atividade deve " + 
                                       "ser informada.".
                 LEAVE Valida.
             END.
        ELSE
        IF   par_dtiniatv > par_dtmvtolt THEN
             DO:
                 ASSIGN aux_dscritic = "Data do inicio da atividade invalida.".
                 LEAVE Valida.
             END.

        /* Setor Economico */
        IF   NOT CAN-FIND(craptab WHERE craptab.cdcooper = par_cdcooper AND
                                        craptab.cdacesso = "SETORECONO" AND
                                        craptab.tpregist = par_cdseteco
                                        NO-LOCK) THEN
             DO:
                 ASSIGN aux_cdcritic = 879.
                 LEAVE Valida.
             END.

        /* Ramo Atividade */                
        IF  NOT CAN-FIND(gnrativ WHERE gnrativ.cdseteco = par_cdseteco AND
                                       gnrativ.cdrmativ = par_cdrmativ 
                                       NO-LOCK)  THEN
             DO:
                 ASSIGN aux_cdcritic = 878.
                 LEAVE Valida.
             END.

        IF  par_persocio = 0  THEN
        DO:
           ASSIGN 
               aux_dscritic = "% Societ. devera ser informado.".
           LEAVE Valida.
        END.
        ELSE
        IF  par_persocio > 100  THEN
        DO:
           ASSIGN 
               aux_dscritic = "% Societ. nao deve ultrapassar 100%.".
           LEAVE Valida.
        END.

        IF  par_dtadmsoc = ?  THEN
        DO:
           ASSIGN 
               aux_dscritic = "Data de admissao deve ser informada.".
           LEAVE Valida.
        END.

        RUN busca_perc_socio (INPUT par_cdcooper,
                              OUTPUT tab_persocio,
                              OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND LAST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
                aux_dscritic = tt-erro.dscritic.
            ELSE
                aux_dscritic = "Nao foi possivel encontrar % societario - TAB036".
            LEAVE Valida.
        END.
            
        /* alimenta o percentual da conta em questao */
        ASSIGN tot_persocio = par_persocio.
        
        /* procuradores da conta */
        FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper   AND
                               crapavt.tpctrato = 6 /*procurad*/ AND
                               crapavt.nrdconta = par_nrdconta   AND
                               crapavt.nrctremp = par_idseqttl   NO-LOCK:
            
            ASSIGN tot_persocio = tot_persocio + crapavt.persocio.
        END.


        /* empresas quem tem participacao na empresa */
        FOR EACH crapepa WHERE crapepa.cdcooper = par_cdcooper   AND
                               crapepa.nrdconta = par_nrdconta   NO-LOCK:
            /* despreza a conta em questao pois ja alimentou no variavel tot_persocio */
          /*  IF  crapepa.nrctasoc = par_nrdctato  THEN
                NEXT. */

            IF  crapepa.nrdocsoc = aux_nrcpfcto  THEN
                NEXT.

            ASSIGN tot_persocio = tot_persocio + crapepa.persocio.
        END.
        
        IF  tot_persocio > 100  THEN
        DO:
           ASSIGN 
               aux_dscritic = "% Societ. total nao deve ultrapassar 100%.".
           LEAVE Valida.
        END.

        LEAVE Valida.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  (aux_dscritic <> "" OR aux_cdcritic <> 0) AND NOT
        CAN-FIND(LAST tt-erro) THEN 
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    /*ELSE
        ASSIGN aux_retorno = "OK".*/

    IF NOT CAN-FIND(LAST tt-erro) THEN
        ASSIGN aux_retorno = "OK".

    IF  aux_retorno <> "OK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT NO,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN aux_retorno.
END.


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
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmfatasi AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdnatjur AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniatv AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrmativ AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtfilial AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtfuncio AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsendweb AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdseteco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtadmsoc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_persocio AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vledvmto AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro. 

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_dsrotina AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0168 AS HANDLE                                  NO-UNDO.

    DEF BUFFER b-crapepa FOR crapepa.

    EMPTY TEMP-TABLE tt-erro. 

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Grava dados da empresa participante"
           aux_retorno  = "NOK"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsrotina = "".
    
    IF par_cddopcao = "I" THEN
       DO:  
           ASSIGN aux_msgdolog = "Incluiu na conta " + 
                                STRING(par_nrdconta) +
                                " Empresa participante conta "          + 
                                STRING(par_nrdctato) + " CNPJ "         +
                                STRING(par_nrcpfcgc) + ", Admissao "    +
                                STRING(par_dtadmsoc) + ", %Societario " +
                                STRING(par_persocio,"z99.99").
           
           RUN grava_logtel(INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT aux_msgdolog). 
       END.
    ELSE
       DO:
          IF par_cddopcao = "A" THEN
             DO: 
                 ASSIGN aux_nrcpfcto = CarregaCpfCnpj(par_nrcpfcgc).

                 FIND b-crapepa WHERE b-crapepa.cdcooper = par_cdcooper AND
                                      b-crapepa.nrdocsoc = aux_nrcpfcto AND
                                      b-crapepa.nrdconta = par_nrdconta 
                                      NO-LOCK NO-ERROR.

                 IF AVAIL(b-crapepa) THEN
                    DO: 
                        ASSIGN aux_msgdolog = "Alterou na conta "             +
                                              STRING(par_nrdconta)            +
                                              " Empresa participante conta "  +
                                              STRING(par_nrdctato) + " CNPJ " +
                                              STRING(par_nrcpfcgc). 
                        

                        IF par_persocio <> b-crapepa.persocio THEN
                           DO:
                              ASSIGN aux_msgdolog = aux_msgdolog              +
                                          ", %Societario de "                 +
                                          STRING(b-crapepa.persocio,"z99.99") +
                                          " para "                            +
                                          STRING(par_persocio,"z99.99").
                                
                           END.

                        IF par_dtadmsoc <> b-crapepa.dtadmiss THEN
                           DO:
                               ASSIGN aux_msgdolog = aux_msgdolog + 
                                      ", Admissao de "            +
                                      STRING(b-crapepa.dtadmiss)  +
                                      " para "                    +
                                      STRING(par_dtadmsoc).
                           END.

                        RUN grava_logtel(INPUT par_cdcooper,
                                         INPUT par_cdoperad,
                                         INPUT par_dtmvtolt,
                                         INPUT aux_msgdolog). 

                    END.

             END.

       END.


    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava 
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:


        ASSIGN aux_nrcpfcto = CarregaCpfCnpj(par_nrcpfcgc).

        Contador: DO aux_contador = 1 TO 10:
            
            FIND crapepa WHERE crapepa.cdcooper = par_cdcooper AND
                               crapepa.nrdconta = par_nrdconta AND
                               crapepa.nrdocsoc = aux_nrcpfcto
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF NOT AVAILABLE crapepa THEN
               DO:
                  IF LOCKED crapepa  THEN
                     DO:
                        ASSIGN aux_dscritic = "Cadastro de empresa "      +
                                              "participante esta sendo "  + 
                                              "alterado em outra estacao".
                        PAUSE 1 NO-MESSAGE.
                        NEXT Contador.

                     END.
                  ELSE
                     DO:
                        IF par_cddopcao = "A" THEN
                           DO:
                              ASSIGN aux_dscritic = "Cadastro de empresa " +
                                                    "participante nao "    + 
                                                    "encontrado.".
                              LEAVE Contador.
                           END.
                        ELSE 
                           DO:
                              CREATE crapepa.

                              ASSIGN crapepa.cdcooper = par_cdcooper
                                     crapepa.nrdconta = par_nrdconta
                                     crapepa.nrctasoc = par_nrdctato
                                     crapepa.dtmvtolt = par_dtmvtolt
                                     crapepa.nrdocsoc = aux_nrcpfcto.
                              
                              VALIDATE crapepa.

                              LEAVE Contador.

                           END.

                     END.

               END.
            ELSE
               DO:
                   ASSIGN aux_dscritic = ""
                          aux_cdcritic = 0.
    
                   LEAVE Contador.
               END.

        END.

        IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
           UNDO Grava, LEAVE Grava.

        /* se nao for socio alimenta os dados */
        IF par_nrdctato = 0   THEN
           DO:
              ASSIGN crapepa.nmfansia = CAPS(par_nmfatasi)
                     crapepa.nmprimtl = CAPS(par_nmprimtl)
                     crapepa.natjurid = par_cdnatjur
                     crapepa.dtiniatv = DATE(STRING(par_dtiniatv,"99/99/9999"))
                     crapepa.cdrmativ = par_cdrmativ
                     crapepa.qtfilial = par_qtfilial
                     crapepa.qtfuncio = par_qtfuncio
                     crapepa.dsendweb = par_dsendweb
                     crapepa.cdseteco = par_cdseteco NO-ERROR.
          
              IF ERROR-STATUS:ERROR THEN
                 DO:
                    ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                    LEAVE Grava.
                 END.

           END.

        ASSIGN crapepa.dtadmiss = par_dtadmsoc
               crapepa.persocio = par_persocio 
               crapepa.vledvmto = par_vledvmto NO-ERROR.

        IF ERROR-STATUS:ERROR THEN
           DO:
              ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
              LEAVE Grava.
           END.

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

    RELEASE crapepa.

    IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
       DO:
          ASSIGN aux_retorno = "NOK".

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
       END.

    IF aux_retorno = "OK"  AND 
       par_cddopcao <> "E" THEN
       Cad_Restritivo:
       DO WHILE TRUE:

          FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                             crapass.nrdconta = par_nrdconta
                             NO-LOCK NO-ERROR.

          IF NOT AVAIL crapass THEN
             DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".
                      
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                ASSIGN aux_retorno = "NOK".

                LEAVE Cad_Restritivo.

             END.
                
          ASSIGN aux_dsrotina = "Inclusao/alteracao da "                     +
                                "empresa participante conta "                +
                                STRING(par_nrdctato,"zzzz,zzz,9")            +
                                " - CPF/CNPJ "                               +
                                STRING((STRING(CarregaCpfCnpj(par_nrcpfcgc),
                                               "99999999999999")),
                                               "xx.xxx.xxx/xxxx-xx")         +
                                " na conta "                                 +
                                STRING(crapass.nrdconta,"zzzz,zzz,9")        +
                                " - CPF/CNPJ "                               +
                                STRING((STRING(crapass.nrcpfcgc,
                                               "99999999999999")),
                                               "xx.xxx.xxx/xxxx-xx").

          IF NOT VALID-HANDLE(h-b1wgen0110) THEN
             RUN sistema/generico/procedures/b1wgen0110.p
                 PERSISTENT SET h-b1wgen0110.
       
          /*Verifica se o associado esta no cadastro restritivo. Se estiver,
            sera enviado um e-mail informando a situacao*/
          RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_dtmvtolt,
                                            INPUT par_idorigem,
                                            INPUT crapass.nrcpfcgc, 
                                            INPUT crapass.nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT FALSE, /*nao bloq. operacao*/
                                            INPUT 30, /*cdoperac*/
                                            INPUT aux_dsrotina,
                                            OUTPUT TABLE tt-erro).
         
          IF RETURN-VALUE <> "OK" THEN
             DO:
                IF VALID-HANDLE(h-b1wgen0110) THEN
                   DELETE PROCEDURE(h-b1wgen0110).
       
                IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                   DO:
                      ASSIGN aux_dscritic = "Nao foi possivel verificar o " + 
                                            "cadastro restritivo.".
                      
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1, /*sequencia*/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).
       
                   END.
       
                ASSIGN aux_retorno = "NOK".

                LEAVE Cad_Restritivo.
       
             END.
       
          /*Verifica se a empresa participante esta no cadastro restritivo. Se 
            estiver, sera enviado um e-mail informando a situacao*/
          RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_dtmvtolt,
                                            INPUT par_idorigem,
                                            INPUT CarregaCpfCnpj(par_nrcpfcgc), 
                                            INPUT par_nrdctato,
                                            INPUT 1,     /*idseqttl*/
                                            INPUT FALSE, /*nao bloq. operacao*/
                                            INPUT 30,    /*cdoperac*/
                                            INPUT aux_dsrotina,
                                            OUTPUT TABLE tt-erro).
       
          IF VALID-HANDLE(h-b1wgen0110) THEN
             DELETE PROCEDURE(h-b1wgen0110).
       
          IF RETURN-VALUE <> "OK" THEN
             DO:
                IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                   DO:
                      ASSIGN aux_dscritic = "Nao foi possivel verificar o " + 
                                            "cadastro restritivo.".
       
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1, /*sequencia*/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).
       
                   END.
       
                ASSIGN aux_retorno = "NOK".

                LEAVE Cad_Restritivo.
       
             END.

          LEAVE Cad_Restritivo.

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
              INPUT BUFFER tt-crapepa-ant:HANDLE,
              INPUT BUFFER tt-crapepa-atl:HANDLE ).
    
    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Valida_Inclui:

    DEF  INPUT PARAM par_cdcooper AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                     NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                     NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                     NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                              NO-UNDO.
    DEF VAR aux_flgcarta AS LOG                               NO-UNDO.

    DEF BUFFER crabass FOR crapass.

    ASSIGN 
        par_dscritic = "Erro na validacao dos dados".
        aux_returnvl = "NOK".

    ValidaI: DO ON ERROR UNDO ValidaI, LEAVE ValidaI:

        /* Busca se o procurador ja foi cadastrado - CPF */
        IF  par_nrcpfcgc <> 0 THEN
            DO:
               IF  CAN-FIND(FIRST crapepa WHERE 
                            crapepa.cdcooper = par_cdcooper AND
                            crapepa.nrdconta = par_nrdconta AND
                            crapepa.nrdocsoc = par_nrcpfcgc) THEN
                   DO:
                      ASSIGN aux_dscritic = "Participante ja cadastrado " +
                                            "para o associado.".
                      LEAVE ValidaI.
                   END.

               FOR FIRST crabass FIELDS(nrdconta inpessoa)
                                 WHERE crabass.cdcooper = par_cdcooper AND
                                       crabass.nrcpfcgc = par_nrcpfcgc NO-LOCK:
               END.
            END.

        /* Busca se o procurador ja foi cadastrado - NR.DA CONTA */
        IF  par_nrdctato <> 0 THEN
            DO:
               IF  CAN-FIND(FIRST crapepa WHERE 
                            crapepa.cdcooper = par_cdcooper AND
                            crapepa.nrdconta = par_nrdconta AND
                            crapepa.nrctasoc = par_nrdctato) THEN
                   DO:
                      ASSIGN par_dscritic = "Participante ja cadastrado " +
                                            "para o associado.".
                      LEAVE ValidaI.
                   END.

               FOR FIRST crabass FIELDS(nrdconta inpessoa)
                                 WHERE crabass.cdcooper = par_cdcooper AND
                                       crabass.nrdconta = par_nrdctato NO-LOCK:
               END.
            END.

        IF  AVAILABLE crabass  THEN
            DO: 
               IF  par_nrdconta = crabass.nrdconta  THEN
                   DO:
                      ASSIGN par_dscritic = "Titular da conta nao " +
                                            "pode ser participante.".
                      LEAVE ValidaI.
                   END.

               /* somente pessoa juridica */
               IF  crabass.inpessoa = 1 THEN 
                   DO:
                      ASSIGN par_cdcritic = 331.
                      LEAVE ValidaI.
                   END.
            END.                   

        ASSIGN par_dscritic = "".

        LEAVE ValidaI.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Valida_Exclui:

    DEF  INPUT PARAM par_cdcooper AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                     NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                     NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                     NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                              NO-UNDO.
    DEF VAR aux_flagdsnh AS LOG                               NO-UNDO.
    DEF VAR aux_flgcarta AS LOG                               NO-UNDO.
    DEF VAR aux_rowidavt AS ROWID                             NO-UNDO.
    DEF VAR aux_rowidepa AS ROWID                             NO-UNDO.

    ASSIGN 
        par_dscritic = "Erro na validacao dos dados".
        aux_returnvl = "NOK".

    ValidaE: DO ON ERROR UNDO ValidaE, LEAVE ValidaE:
        
        /* Se for pessoa fisica, nao validar exclusao */
        IF  CAN-FIND(FIRST crapass WHERE 
                           crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta AND
                           crapass.inpessoa = 1)  THEN
            DO:
               ASSIGN par_dscritic = "".
               LEAVE ValidaE.
            END.

        FOR FIRST crapepa FIELDS(nrdocsoc)
                          WHERE crapepa.cdcooper = par_cdcooper AND
                                crapepa.nrdconta = par_nrdconta AND
                                (IF par_nrdctato <> 0 THEN
                                    crapepa.nrctasoc = par_nrdctato
                                 ELSE crapepa.nrdocsoc = par_nrcpfcgc) NO-LOCK:
            ASSIGN aux_rowidepa = ROWID(crapepa).
        END.

        FOR FIRST crapavt FIELDS(nrcpfcgc)
                          WHERE crapavt.cdcooper = par_cdcooper AND
                                crapavt.tpctrato = 6 /* jur */  AND
                                crapavt.nrdconta = par_nrdconta AND
                                crapavt.nrctremp = par_idseqttl AND
                                (IF par_nrdctato <> 0 THEN
                                    crapavt.nrdctato = par_nrdctato
                                 ELSE crapavt.nrcpfcgc = par_nrcpfcgc) NO-LOCK:
            ASSIGN aux_rowidavt = ROWID(crapavt).
        END.

        /* Verifica se ha mais de um procurador p/ poder excluir */
        IF  NOT CAN-FIND(FIRST crapepa WHERE
                         crapepa.cdcooper = par_cdcooper AND
                         crapepa.nrdconta = par_nrdconta AND
                         ROWID(crapepa)  <> aux_rowidepa) AND
            NOT CAN-FIND(FIRST crapavt WHERE
                         crapavt.cdcooper = par_cdcooper AND
                         crapavt.tpctrato = 6 /*jur*/    AND
                         crapavt.nrdconta = par_nrdconta AND
                         /*crapavt.dsproftl = "SOCIO/PROPRIETARIO") THEN*/
                         crapavt.persocio > 0) THEN
            DO:
                ASSIGN par_dscritic = "Eh obrigatorio o cadastro " +
                                     "de no minimo um socio.".
               LEAVE ValidaE.
            END.

        /* verifica se ha um socio proprietario,se houver verifica 
           se eh o unico */
        IF  CAN-FIND(FIRST crapepa NO-LOCK WHERE
                           crapepa.cdcooper = par_cdcooper         AND
                           crapepa.nrdconta = par_nrdconta) OR
            CAN-FIND(FIRST crapavt NO-LOCK WHERE
                           crapavt.cdcooper = par_cdcooper         AND
                           crapavt.tpctrato = 6 /*juridica*/       AND
                           crapavt.nrdconta = par_nrdconta         AND
                           crapavt.dsproftl = "SOCIO/PROPRIETARIO")            
            THEN
        DO:
           /* Verifica se eh o unico socio/proprietario p/ poder excluir */
           IF  NOT CAN-FIND(FIRST crapepa NO-LOCK WHERE
                            crapepa.cdcooper = par_cdcooper         AND
                            crapepa.nrdconta = par_nrdconta         AND
                            ROWID(crapepa)  <> aux_rowidepa) AND
               NOT CAN-FIND(FIRST crapavt NO-LOCK WHERE
                            crapavt.cdcooper = par_cdcooper         AND
                            crapavt.tpctrato = 6 /*juridica*/       AND
                            crapavt.nrdconta = par_nrdconta         AND
                            /*crapavt.dsproftl = "SOCIO/PROPRIETARIO" AND*/
                            crapavt.persocio > 0 AND
                            ROWID(crapavt)  <> aux_rowidavt)                
               THEN
               DO:
                   ASSIGN par_dscritic = "Eh obrigatorio o cadastro " +
                                         "de no minimo um socio.".
                  LEAVE ValidaE.
               END.
        END.
        
        /* Verifica se representante/procurador eh representante de cartao 
           de credito desta conta e se o mesmo eh titular de cartao ativo */
        FOR EACH craphcj WHERE craphcj.cdcooper = par_cdcooper  AND
                               craphcj.nrdconta = par_nrdconta  AND
                              (craphcj.nrcpfpri = par_nrcpfcgc OR
                               craphcj.nrcpfseg = par_nrcpfcgc OR
                               craphcj.nrcpfter = par_nrcpfcgc)   NO-LOCK,
           FIRST crawcrd WHERE crawcrd.cdcooper = craphcj.cdcooper  AND
                               crawcrd.nrdconta = craphcj.nrdconta  AND
                              (crawcrd.insitcrd = 0   /* estudo */ OR 
                               crawcrd.insitcrd = 1   /* aprov */  OR 
                               crawcrd.insitcrd = 2   /* solic */  OR 
                               crawcrd.insitcrd = 3   /* liberado */  OR 
                               crawcrd.insitcrd = 4   /* em uso */ )   NO-LOCK:
                               
            ASSIGN par_dscritic = "Participante com cartao de credito.".
            LEAVE ValidaE.
        END.

        ASSIGN par_dscritic = "".

        LEAVE ValidaE.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Exclui_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_flgcarta AS LOG                                     NO-UNDO.

    DEF VAR h-b1wgen0168 AS HANDLE                                  NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Exclusao da empresa participante"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Exclui: DO TRANSACTION
        ON ERROR  UNDO Exclui, LEAVE Exclui
        ON QUIT   UNDO Exclui, LEAVE Exclui
        ON STOP   UNDO Exclui, LEAVE Exclui
        ON ENDKEY UNDO Exclui, LEAVE Exclui:

        EMPTY TEMP-TABLE tt-erro.

        ASSIGN aux_nrcpfcto = CarregaCpfCnpj(par_nrcpfcgc).


        Contador: DO aux_contador = 1 TO 10:

            FIND crapepa WHERE crapepa.cdcooper = par_cdcooper AND
                               crapepa.nrdconta = par_nrdconta AND
                               crapepa.nrdocsoc = aux_nrcpfcto
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapepa THEN
                DO:
                    IF  LOCKED crapepa  THEN
                        DO:
                           aux_dscritic = "Cadastro de empresa " +
                                          "participante esta sendo alterado " +
                                          "em outra estacao".
                           PAUSE 1 NO-MESSAGE.
                           NEXT Contador.
                        END.
                    ELSE
                        DO:
                            aux_dscritic = "Cadastro de empresa "     +
                                           " participante nao foi encontrado.".
                            LEAVE Contador.
                        END.
                END.

            ASSIGN
                aux_dscritic = ""
                aux_cdcritic = 0.

            LEAVE Contador.
        END.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Exclui, LEAVE Exclui.

        EMPTY TEMP-TABLE tt-crapepa-ant.
        EMPTY TEMP-TABLE tt-crapepa-atl.

        CREATE tt-crapepa-ant.
        BUFFER-COPY crapepa TO tt-crapepa-ant.
    
        
        ASSIGN aux_msgdolog = "Excluiu na conta " + 
                             STRING(par_nrdconta) +
                             " Empresa participante conta "      + 
                             STRING(crapepa.nrctasoc) + " CNPJ "  +
                             STRING(par_nrcpfcgc).                    

        FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper 
                                 NO-LOCK NO-ERROR.

        RUN grava_logtel(INPUT par_cdcooper,
                         INPUT par_cdoperad,
                         INPUT crapdat.dtmvtolt,
                         INPUT aux_msgdolog). 

        DELETE crapepa.
        CREATE tt-crapepa-atl.
        
        /* INICIO - Atualizar os dados da tabela crapcyb (CYBER) */
        IF NOT VALID-HANDLE(h-b1wgen0168) THEN
           RUN sistema/generico/procedures/b1wgen0168.p
               PERSISTENT SET h-b1wgen0168.
                 
        EMPTY TEMP-TABLE tt-crapcyb.

        CREATE tt-crapcyb.
        ASSIGN tt-crapcyb.cdcooper = par_cdcooper
               tt-crapcyb.nrdconta = par_nrdconta
               tt-crapcyb.dtmancad = crapdat.dtmvtolt.

        RUN atualiza_data_manutencao_cadastro
            IN h-b1wgen0168(INPUT TABLE tt-crapcyb,
                            OUTPUT aux_cdcritic,
                            OUTPUT aux_dscritic ).

        IF RETURN-VALUE <> "OK" THEN
           UNDO Exclui, LEAVE Exclui.
        /* FIM - Atualizar os dados da tabela crapcyb */

        ASSIGN aux_retorno = "OK".

        LEAVE Exclui.
    END. /* Exclui */

    IF VALID-HANDLE(h-b1wgen0168) THEN
       DELETE PROCEDURE(h-b1wgen0168).

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
              INPUT BUFFER tt-crapepa-ant:HANDLE,
              INPUT BUFFER tt-crapepa-atl:HANDLE ).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Idade:

    DEF  INPUT PARAM par_dtnascto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_nrdeanos AS INTE                           NO-UNDO.

    DEF VAR aux_nrdmeses AS INTE                                    NO-UNDO.
    DEF VAR aux_dsdidade AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    RUN idade IN h-b1wgen9999
         ( INPUT par_dtnascto,
           INPUT par_dtmvtolt,
          OUTPUT par_nrdeanos,
          OUTPUT aux_nrdmeses,
          OUTPUT aux_dsdidade ).

    DELETE PROCEDURE h-b1wgen9999.

    RETURN "OK".

END PROCEDURE.

/* Buscar parametro de percentual de socio para o GE */
PROCEDURE busca_perc_socio:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    
    DEFINE OUTPUT PARAMETER opt_persocio AS DECIMAL     NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEFINE VARIABLE aux_persocio AS DECIMAL     NO-UNDO.
        
    EMPTY TEMP-TABLE tt-erro.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 00             AND
                       craptab.cdacesso = "PROVISAOCL"   AND
                       craptab.tpregist = 999
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL craptab THEN
    DO:
        ASSIGN aux_dscritic = "Tabela percentual de " +
                              "socio nao econtrada.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1,           
                       INPUT 0,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    ASSIGN opt_persocio = DEC(SUBSTR(craptab.dstextab,28,6)).

    IF  opt_persocio = 0  THEN
    DO:
        ASSIGN aux_dscritic = "Percentual de " +
                              "socio invalido. Utilize TAB036.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1,           
                       INPUT 0,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    RETURN "OK".
END.
/*................................. FUNCTIONS ...............................*/
FUNCTION ValidaContato RETURNS LOGICAL:

END FUNCTION.

FUNCTION ValidaUf RETURNS LOGICAL
    ( INPUT par_cdufdavt AS CHARACTER ):

    RETURN (LOOKUP(par_cdufdavt,"AC,AL,AP,AM,BA,CE,DF,ES,GO,MA," +
                                "MT,MS,MG,PA,PB,PR,PE,PI,RJ,RN," +
                                "RS,RO,RR,SC,SP,SE,TO,") <> 0).

END FUNCTION.

FUNCTION ValidaCpfCnpj RETURNS LOGICAL
    ( INPUT  par_nrcpfcgc AS DECIMAL,
      OUTPUT par_cdcritic AS INTEGER ):

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_stsnrcal AS LOG                                     NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    RUN valida-cpf-cnpj IN h-b1wgen9999
        ( INPUT par_nrcpfcgc,
         OUTPUT aux_stsnrcal,
         OUTPUT aux_inpessoa ).

     IF  NOT aux_stsnrcal   THEN
         ASSIGN par_cdcritic = 27.

     /* so aceita pessoa juridica */
     IF  aux_inpessoa = 1   THEN
         ASSIGN par_cdcritic = 331.

    DELETE PROCEDURE h-b1wgen9999.

    RETURN (par_cdcritic = 0).

END FUNCTION.

FUNCTION CarregaCpfCnpj RETURNS DECIMAL
    ( INPUT par_cdcpfcgc AS CHARACTER ):

    RETURN DEC(REPLACE(REPLACE(REPLACE(par_cdcpfcgc,".",""),"-",""),"/","")).

END.

PROCEDURE grava_logtel:

    DEF INPUT PARAM par_cdcooper    LIKE    crapass.cdcooper    NO-UNDO.
    DEF INPUT PARAM par_cdoperad    LIKE    crapope.cdoperad    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS      DATE                NO-UNDO.
    DEF INPUT PARAM par_msgdolog    AS      CHAR                NO-UNDO.


         
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                       NO-LOCK NO-ERROR.
           
    IF  NOT AVAIL(crapcop) THEN
        RETURN "NOK".

    UNIX SILENT VALUE 
        ("echo "      +   STRING(par_dtmvtolt,"99/99/9999")     +
         " "          +   STRING(TIME,"HH:MM:SS")               +
         " --'> ' Operador "  + par_cdoperad + " - "            +
         par_msgdolog                                           +
         " >> /usr/coop/" + TRIM(crapcop.dsdircop)              +
         "/log/contas.log").
           

    RETURN "OK".
END PROCEDURE.


