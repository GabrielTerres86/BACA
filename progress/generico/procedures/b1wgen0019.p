/*..............................................................................
 
   Programa: b1wgen0019.p
   Autor   : Murilo/David
   Data    : 21/06/2007                        Ultima atualizacao: 26/05/2018

   Objetivo  : BO LIMITE DE CRÉDITO

   Alteracoes: 12/03/2008 - Continuar desenvolvimento da BO (David).

               05/01/2009 - Acerto na geracao de critica na procedure
                            obtem-valor-limite (David).

               13/02/2009 - Alteracao cdempres (Diego).

               01/07/2009 - Inclusao de campo dstitulo na temp-table 
                            tt-cabec-limcredito (GATI - Eder)
                          - Incluir tt-cabec-limcredito.nmopelib (Guilherme).

               05/10/2009 - Alimentar o crapass.cdtipcta (Guilherme).

               23/10/2009 - operadores estavam digitando F4/END quando registro 
                            do crapass alocado no cancelamento(Guilherme).

               17/11/2009 - Corrigido o uso do cdcooper na crabavl (Evandro).

               10/12/2009 - Incluir novos campos para o Rating.
                            Retirado tratamento de atualizacao do Rating. 
                            (Gabriel).
                          - Substituido campo vlopescr por vltotsfn (Elton).
                          - Incluso desativa_rating nas procedures (Guilherme).

               04/03/2010 - Novos parametros para procedure consulta-poupanca
                            da BO b1wgen0006 (David).

               07/04/2010 - Corrigir criticas da confirmacao do limite
                            (Gabriel). 

               20/04/2010 - Adaptar novo RATING para o Ayllos Web (David).

               23/06/2010 - Incluir campo de envio a sede (Gabriel).

               01/09/2010 - Incluir parametros na chamada da procedure que
                            cria os avalistas e que os valida (Gabriel).

               16/09/2010 - Incluir procedure para gerar impressao da proposta
                            e contrato (David).

               21/10/2010 - Alteracoes para implementacao de limites de credito
                            com taxas diferenciadas:
                            - Inclusao de campos de linha de credito nas 
                              temp-tables de informacoes do limite e de proposta
                              de limite (tt-cabec-limcredito e 
                              tt-proposta-limcredito) 
                            - Alteracao das procedures obtem-cabecalho-limite,
                              validar-novo-limite e cadastrar-novo-limite para
                              tratamento do novo campo Linha de Credito
                              (GATI - Eder)

               28/10/2010 - Incluidos parametros flgativo e nrctrhcj na 
                             procedure lista_cartoes (Diego).

               16/11/2010 - Incluida a palavra "CADIN" na proposta de limite
                            de credito (Vitor).

               18/11/2010 - Melhorar a apresentacao do campo da observacao
                            na impressao da proposta (Gabriel).

               25/11/2010 - Inclusao temporariamente do parametro flgliber
                            (Transferencia do PAC5 Acredi) (Irlan)

               02/12/2010 - Trocada a procedure que cuida da impressao dos
                            ratings (Gabriel). 

               11/01/2011 - Alterado as procedures obtem-cabecalho-limite,
                            cadastrar-novo-limite, gera-impressao-limite,
                            obtem-dados-contrato para insercao do campo
                            dsenfin3 (Adriano).

                          - Passar como parametro a conta para validacao
                            do avalista (Gabriel).

               15/02/2011 - Ajuste devido a alteracao do campo nome (Henrique).

               05/04/2011 - Incluso parametro tt-impressao-risco-tl na
                            gera_rating (Guilherme).

               11/04/2011 - Incluido parametro tt-impressao-risco-tl na
                            confirmar-novo-limite. (Fabricio)

               19/04/2011 - Inclusao de parametros de CEP integrado no
                            procedimento cadastrar-novo-limite e 
                            valida-dados-avalistas. (André - DB1)

               24/05/2011 - Ajuste na impressao dos avalistas, utilizando os
                            novos parametros da alteracao acima (David).

               25/05/2011 - Desmembrado algumas informacoes do campo endeass2 
                            da tt-dados-ctr e passado para o campo endeass3.
                            (Fabricio)

               07/06/2011 - Alterado AT e FORMAT do campo tt-dados-ctr.dsvlnpr1;
                            PF e PJ. Alterado tambem a ordem de impressao das
                            assinaturas; cooperativa apos cooperado, e, operador
                            na posicao que era a cooperativa. (Fabricio)

               17/06/2011 - Passado o conteudo do FRAME f_assina_operador 
                            para o FRAME f_assina_cooperativa_operador.
                            Aumentado o espacamento entre a assinatura do
                            cooperado e da cooperativa, e entre a assinatura
                            da cooperativa e das testemunhas. (Fabricio)

               21/07/2011 - Nao gerar a proposta quando a impressao for completa 
                            (Isara - RKAM)

               30/08/2011 - Ajuste na listagem 'Ultimas alteracoes' para 
                            considerar somente o limite de credito
                            (Gabriel).

               15/09/2011 - Adaptacoes Rating Singulares na Central (Guilherme)

               26/10/2011 - Adicionado na procedure obtem-novo-limite, a chamada
                            da procedure valida_percentual_societario. 
                            (Fabricio)
                            
               21/11/2011 - Colocado em comentario temporariamente a chamada
                            da procedure valida_percentual_societario. 
                            (Fabricio)

               11/10/2012 - Incluido a passagem de um novo parametro na chamada
                            da procedure saldo_utiliza - Projeto GE (Adriano).

               12/11/2012 - Incluir function busca_grupo na procedure 
                            validar-novo-limite e tratamento para verificar se 
                            conta pertence a Grupo Economico ou nao - GE 
                            (Lucas R.).

               28/12/2012 - Incluso a passagem do parametro par_cdoperad na 
                            procedure cria-tabelas-avalistas (Daniel).

               31/01/2013 - Aumentado format da conta pessoa juridica.
                            (David Kruger).

               21/03/2013 - Incluido a chamada da procedure alerta_fraude 
                            dentro das procedures validar-novo-limite,
                            confirmar-novo-limite (Adriano).

               04/04/2013 - Incluir Verificaçao de idade na procedure 
                            obtem-novo-limite (Lucas R.)

               25/06/2013 - RATING BNDES - Gravar campo dtmvtolt crapprp
                            (Guilherme/Supero)

               12/11/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (Guilherme Gielow) 

               19/10/2013 - Adicionado validate para as tabelas crapmcr,
                            crapjfn, craplim, crapprp, crapact, crapneg
                            (Tiago).

               24/01/2014 - Aumentado o format de tt-dados-prp.vlsalari e do 
                            salario do conjuge também. Alterado "P.A.C." para 
                            "PA" (Carlos)

               18/03/2014 - Incluir cadastro na crapdoc na procedure 
                            cadastrar-novo-limite (Lucas R.)

               11/04/2014 - Incluir ajustes referentes a digitalizacao de 
                            documentos na obtem-cabecalho-limite (Lucas R.) 

               28/04/2014 - Ajuste para buscar a sequence do banco Oracle da
                            tabela crapneg. (James)

               18/06/2014 - Exclusao do uso da tabela crapcar
                           (Tiago Castro - Tiago RKAM)

               25/06/2014 - Adicionado o parametro par_dsoperac 
                            (com valor 'LIMITE CREDITO') 'a chamada da
                            procedure cria-tabelas-avalistas.
                            (Chamado 166383) - (Fabricio)

               02/07/2014 - Possibilitar alterar a observacao das propostas
                            (Chamado 169007) (Jonata - RKAM).

               07/07/2014 - Inclusao da include b1wgen0138tt para uso da
                           temp-table tt-grupo.
                           (Chamado 130880) - (Tiago Castro - RKAM)

               14/07/2014 - Incluso parametros na procedure cria-tabelas-avalistas.
                            (Daniel/Thiago).

               28/07/2014 - adicionado parametro de saida em chamada da
                            proc. cria-tabelas-avalistas.
                            (Jorge/Gielow) - SD 156112    

               22/08/2014 - Incluir Ajustes para imprimir o Calculo do cet
                            Projeto Cet (Lucas R./Gielow)

               08/09/2014 - Alterado crapcop.nmcidade para crapage.nmcidade
                            estava buscando a cidade da sede. (SD 163504 Lucas R.)

               10/09/2014 - Ajustar a buscar da informações do conjuge para quando 
                            possuir apenas a conta na crapcje as informaçoes sejam
                            carregadas da crapttl (Douglas - Chamado 193317)

               06/11/2014 - Alterado parametro passado na chamada da procedure
                            cria-tabelas-avalistas; de: 'LIMITE CREDITO' 
                            para: 'LIMITE CRED.'.
                            Motivo: Possibilidade de erro ao tentar gravar
                            registro de log (craplgm). (Fabricio)

               23/11/2014 - Ajuste na procedure obtem-cabecalho-limite para
                            carregar a quantidade de renovacao e a data de
                            renocacao. (James)

               30/12/2014 - Incluir a procedure "renovar_limite_credito_manual".
                            (James)

               19/01/2015 - Incluir novas procedures para realizar alteracao de
                            proposta - SD 237152 (Tiago/Gielow)

               09/02/2015 - Retirado inpessoa da chamada da procedure
                            valida-avalistas (Lucas R. #245726)

               03/03/2015 - Conversão da fn_sequence para procedure para não
                            gerar cursores abertos no Oracle. (Dionathan)

               05/03/2015 - Incluir mais espaçamento para o frame f_digitaliza
                            (Lucas R. #183889)

               13/03/2015 - Substituida a chamada da procedure consulta-aplicacoes da 
                            BO b1wgen0004 pela procedure obtem-dados-aplicacoes da 
                            BO b1wgen0081. (Carlos Rafael Tanholi - Projeto Captacao)

               13/03/2015 - Aumentado format da variavel tt-dados-prp.vloutras 
                            pois nao estava suportando valor passado
                            (SD 253911 - Tiago).

               16/03/2015 - Aumentado format da variavel tt-dados-ctr.vllimite 
                            pois nao estava suportando valor passado
                            (SD 253911 - Tiago).

               29/04/2015 - Projeto consultas automatizadas (Gabriel-RKAM).

               29/05/2015 - Alterado para apresentar mensagem de confirmacao ao
                            realizar nova proposta de limite de credito para 
                            menores nao emancipados. (Reinert)

               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).

               04/09/2015 - Diminuido page-size na procedure gera-impressao-limite
                            para solucionar o problema relatado no chamado 316346
                            (Kelvin).

               13/11/2015 - Adicionado os itens no log da procedure alterar-novo-limite e 
                            conforme solicitado no chamado 353115. (Kelvin)

               10/12/2015 - Ajustado a rotina junta_arquivos para verificar se o primeiro 
                            caracter é uma quebra de pagina e assim forçar a quebra, 
                            pois sem a utilizacao do comando page stream o contador de 
                            linhas nao é zerado gerando quebra de pagina no momento errado 
                            SD344244(Odirlei-AMcom)

               22/12/2015 - Criada procedure para edição de número do contrato de limite 
                            (Lucas Lunelli - SD 360072 [M175])

               03/03/2016 - Ajustado a rotina imprime-scr-consultas para controlar 
                            a quebra de pagina e evitar o bug na geracao de pdf
                            que qnd quebra a pagina e a primeira linha esta em branco
                            nao conta como uma pagina nova (Douglas - Chamado 405904)

               17/06/2016 - Inclusão de campos de controle de vendas - M181 ( Rafael Maciel - RKAM)

               02/08/2016 - #480602 Melhoria de tratamentos de erros para <> "OK" no lugar de 
                             = "NOK". Inclusao de VALIDATE na crapass. (Carlos)

               14/09/2016 - Ajuste para aceitar mais uma casa decimal nos juros anual do CET
                             (Andrey Formigari - RKAM)

               15/09/2016 - Inclusao dos parametros default na rotina oracle
                            pc_imprime_limites_cet PRJ314 (Odirlei-AMcom)

               25/10/2016 - Validacao de CNAE restrito Melhoria 310 (Tiago/Thiago)

               07/02/2017 - Alterardo a forma de pegar o cdagenci na hora de 
                            confirmar o limite de credito na procedure
                            confirmar-novo-limite (Tiago/Ademir SD590361).

               19/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
                            crapass, crapttl, crapjur 
                            (Adriano - P339).

               12/05/2017 - Passagem de 0 para a nacionalidade. (Jaison/Andrino)

               17/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                            PRJ339 - CRM (Odirlei-AMcom) 

               29/07/2017 - Desenvolvimento da melhoria 364 - Grupo Economico Novo. (Mauro)

               28/09/2017 - Ajuste leitura IDORGEXP.
                            PRJ339 - CRM (Odirlei-AMcom)

               22/11/2017 - Incluído o número do cpf ou cnpj na tabela crapdoc.
                            Projeto 339 - CRM. (Lombardi)

               05/12/2017 - Adicionada chamada para a rotina pc_bloq_desbloq_cob_operacao nas procedures
                            cconfirmar-novo-limite e cancelar-limite-atual.
                            Adicionado campo idcobope e chamada para a rotina pc_vincula_cobertura_operacao
                            nas procedures alterar-novo-limite e altera-numero-proposta-limite.
                            Projeto 404 (Lombardi)

               06/03/2018 - Adicionado campo idcobope na temp-table tt-cabec-limcredito
                            para as novas propostas de limite na procedure obtem-cabecalho-limite.
                            (PRJ404 Reinert)
                
               20/03/2018 - Substituida verificacao "cdtipcta = 8,9,10,11" pela consulta se 
                            o produto limite de credito está liberado para o tipo de conta.
                            - Retirada alteracao do tipo de conta. Projeto 366 (Lombardi).

               26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

               08/08/2018 - Ajustes na busca do contrato de limite de crédito (INC0021296 - Andrey Formigari).

               15/03/2019 - prj450 - Rating - Tratamento do Botao Confirmar Novo Limite na tela - Limite de Credito
                            valida rating antes de efetivar novo limte (Fabio Adriano - Amcom).

               21/03/2019 - Ajuste no Termo de Recisao para assinatura eletronica
                            Pj470 SM 1 - Ze Gracik - Mouts

               28/03/2019 - prj450 - Padronizaçao no tratamento do Status do Rating para todos produtos
                            (Fabio Adriano - AMcom).

               17/04/2019 - prj450 - verificar o endividamento somado com o contrato atual, caso for maior que 
                            o parâmetro da tab056, gravar o rating com o status 4 - efetivado.
                            Fabio Adriano (AMcom).

               05/05/2019 - PRJ 438 - Sprint 7 - Alterado rotinas de gravar/alterar limite com os novos campos da tela avalista,
                            alterado impressao de proposta PJ - (Mateus Z - Mouts).

               14/05/2019 - Adicionado pc_atualiza_contrato_rating para alteracao do numero do contrato/proposta
                            P450 - Luiz Otavio Olinger Momm (AMCOM).

               22/05/2019 - Padronizado os campos da tt-ratings-novo para o padrao atual do progress
                            P450 - Luiz Otavio Olinger Momm (AMCOM).

..............................................................................*/


/*................................ DEFINICOES ................................*/

{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/b1wgen0019tt.i }
{ sistema/generico/includes/b1wgen0021tt.i }
{ sistema/generico/includes/b1wgen0024tt.i }
{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen0138tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/ayllos/includes/var_online.i NEW }

DEF STREAM str_limcre.

DEF STREAM str_1. /* juntar arquivos */
DEF STREAM str_2.
DEF STREAM str_3.
DEF STREAM str_4.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

DEF        VAR aux_possuipr AS CHAR                                  NO-UNDO.

/* Informacoes com os Ratings do Cooperado */
DEF TEMP-TABLE tt-ratings-novo  NO-UNDO
    FIELD cdagenci AS INTE
    FIELD nrdconta AS INTE
    FIELD nrctrrat AS INTE
    FIELD tpctrrat AS INTE
    FIELD indrisco AS CHAR
    FIELD dtmvtolt AS DATE
    FIELD dteftrat AS DATE
    FIELD cdoperad AS CHAR
    FIELD insitrat AS INTE
    FIELD dsditrat AS CHAR
    FIELD nrnotrat AS DECI
    FIELD vlutlrat AS DECI
    FIELD vloperac AS DECI
    FIELD dsdopera AS CHAR
    FIELD dsdrisco AS CHAR
    FIELD flgorige AS LOGI
    FIELD inrisctl AS CHAR
    FIELD nrnotatl AS DECI
    FIELD dtrefere AS DATE
    FIELD inrisrat AS CHAR       
    FIELD inponrat AS INTE
    FIELD innivrat AS CHAR
    FIELD insegrat AS CHAR.

/* Informacoes dos campos de rating do cooperado */
DEF TEMP-TABLE tt-valores-rating-novo   NO-UNDO
    FIELD nrinfcad AS INTE 
    FIELD nrpatlvr AS INTE 
    FIELD nrperger AS INTE
    FIELD vltotsfn AS DECI
    FIELD perfatcl LIKE crapjfn.perfatcl
    FIELD nrgarope AS INTE
    FIELD nrliquid AS INTE
    FIELD inpessoa AS INTE.

/*............................ PROCEDURES EXTERNAS ...........................*/


/******************************************************************************/
/**              Procedure para obter valor do limite de credito             **/
/******************************************************************************/
PROCEDURE obtem-valor-limite: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
            
    DEF OUTPUT PARAM TABLE FOR tt-limite-credito.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
 
    EMPTY TEMP-TABLE tt-limite-credito.
    EMPTY TEMP-TABLE tt-erro.
        
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter valor do limite de credito".

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

    CREATE tt-limite-credito.
    ASSIGN tt-limite-credito.vllimcre = crapass.vllimcre.
    
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
/**              Procedure para obter dados do limite de credito             **/
/******************************************************************************/
PROCEDURE obtem-cabecalho-limite: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-cabec-limcredito.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF BUFFER crabope FOR crapope.

    EMPTY TEMP-TABLE tt-cabec-limcredito.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter dados do limite de credito".

    RUN obtem-registro-limite (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtmvtolt,
                               INPUT FALSE,
                              OUTPUT TABLE tt-erro).
                               
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
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

    CREATE tt-cabec-limcredito.
    
    IF  AVAILABLE craplim  THEN /** FIND executado na obtem-registro-limite **/
        DO:
            FIND crapope WHERE crapope.cdcooper = par_cdcooper       AND
                               crapope.cdoperad = craplim.cdoperad 
                               NO-LOCK NO-ERROR.

            FIND crabope WHERE crabope.cdcooper = par_cdcooper       AND
                               crabope.cdoperad = craplim.cdopelib
                               NO-LOCK NO-ERROR.

            FIND crapprp WHERE crapprp.cdcooper = par_cdcooper       AND
                               crapprp.nrdconta = craplim.nrdconta   AND
                               crapprp.tpctrato = craplim.tpctrlim   AND
                               crapprp.nrctrato = craplim.nrctrlim
                               NO-LOCK NO-ERROR.

            FIND craplrt WHERE craplrt.cdcooper = par_cdcooper       AND
                               craplrt.cddlinha = craplim.cddlinha   
                               NO-LOCK NO-ERROR.
            
            ASSIGN tt-cabec-limcredito.vllimite = craplim.vllimite
                   tt-cabec-limcredito.dslimcre = IF  craplim.inbaslim = 1  THEN
                                                      "COTAS DE CAPITAL"
                                                  ELSE "CADASTRAL"
                   tt-cabec-limcredito.dtmvtolt = craplim.dtinivig
                   tt-cabec-limcredito.dsfimvig = "Fim:"
                   tt-cabec-limcredito.dtfimvig = craplim.dtfimvig
                   tt-cabec-limcredito.nrctrlim = craplim.nrctrlim
                   tt-cabec-limcredito.qtdiavig = craplim.qtdiavig
                   tt-cabec-limcredito.dsencfi1 = craplim.dsencfin[1]
                   tt-cabec-limcredito.dsencfi2 = craplim.dsencfin[2]
                   tt-cabec-limcredito.dsencfi3 = craplim.dsencfin[3]
                   tt-cabec-limcredito.dssitlli = IF  craplim.insitlim = 0  THEN
                                                      "" 
                                                  ELSE 
                                                  IF  craplim.insitlim = 1  THEN
                                                      "ESTUDO"
                                                  ELSE 
                                                  IF  craplim.insitlim = 2  THEN
                                                      "ATIVO"
                                                  ELSE 
                                                  IF  craplim.insitlim = 3  THEN
                                                      "CANCELADO"
                                                  ELSE
                                                      "DIFERENTE"
                   tt-cabec-limcredito.dsmotivo = IF  craplim.cdmotcan = 0  THEN
                                                      "" 
                                                  ELSE 
                                                  IF  craplim.cdmotcan = 1  THEN
                                                      "ALTERACAO DE LIMITE"
                                                  ELSE 
                                                  IF  craplim.cdmotcan = 2  THEN
                                                      "PELO ASSOCIADO"
                                                  ELSE 
                                                  IF  craplim.cdmotcan = 3  THEN
                                                      "PELA COOPERATIVA"
                                                  ELSE 
                                                  IF  craplim.cdmotcan = 4  THEN
                                                      "TRANSFERENCIA C/C"
                                                  ELSE
                                                      "DIFERENTE"
                   tt-cabec-limcredito.nmoperad = IF  AVAILABLE crapope  THEN
                                                      crapope.nmoperad
                                                  ELSE
                                                      craplim.cdoperad +
                                                      " - NAO CADASTRADO"
                   tt-cabec-limcredito.nmopelib = IF  AVAILABLE crabope  THEN
                                                      crabope.nmoperad
                                                  ELSE
                                                      craplim.cdopelib +
                                                      " - NAO CADASTRADO"
                                                         
                   tt-cabec-limcredito.flgenvio = IF   AVAIL crapprp   THEN
                                                       IF    crapprp.flgenvio 
                                                             THEN
                                                             "SIM"
                                                       ELSE
                                                             "NAO"
                                                  ELSE
                                                       "NAO"
                   tt-cabec-limcredito.cddlinha = craplim.cddlinha
                   tt-cabec-limcredito.dsdlinha = IF   AVAIL craplrt   THEN 
                                                       craplrt.dsdlinha
                                                  ELSE
                                                       ""
                   tt-cabec-limcredito.flgdigit = craplim.flgdigit
                   tt-cabec-limcredito.qtrenova = craplim.qtrenova
                   tt-cabec-limcredito.dtrenova = craplim.dtrenova
                   tt-cabec-limcredito.tprenova = craplim.tprenova
                   tt-cabec-limcredito.dstprenv = IF craplim.tprenova = "A" THEN
                                                     "Automatica"
                                                  ELSE
                                                  IF craplim.tprenova = "M" THEN
                                                     "Manual"
                                                  ELSE ""
                   /* PRJ 438 - Sprint 7 - Retornar a taxa da linha de credito */
                   tt-cabec-limcredito.nivrisco = "A"
                   tt-cabec-limcredito.dsdtxfix = IF   AVAIL craplrt   THEN
                                                         STRING(craplrt.txjurfix) + '% + TR'
                                                    ELSE
                                                         "".
        END.
    ELSE
        ASSIGN tt-cabec-limcredito.vllimite = 0 
               tt-cabec-limcredito.dslimcre = ""
               tt-cabec-limcredito.dtmvtolt = ?
               tt-cabec-limcredito.dsfimvig = ""
               tt-cabec-limcredito.dtfimvig = ?
               tt-cabec-limcredito.nrctrlim = 0
               tt-cabec-limcredito.qtdiavig = 0
               tt-cabec-limcredito.dsencfi1 = ""
               tt-cabec-limcredito.dsencfi2 = ""
               tt-cabec-limcredito.dsencfi3 = ""
               tt-cabec-limcredito.dssitlli = ""
               tt-cabec-limcredito.dsmotivo = ""
               tt-cabec-limcredito.nmoperad = ""
               tt-cabec-limcredito.flgenvio = "NAO"
               tt-cabec-limcredito.qtrenova = 0
               tt-cabec-limcredito.dtrenova = ?
               tt-cabec-limcredito.tprenova = ""
               tt-cabec-limcredito.dstprenv = ""
               tt-cabec-limcredito.nivrisco = "A"
               tt-cabec-limcredito.dsdtxfix = "".

    FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                             craplim.nrdconta = par_nrdconta AND
                             craplim.tpctrlim = 1            AND
                             craplim.insitlim = 1 /** ESTUDO **/
                             NO-LOCK NO-ERROR.
                                
    IF  AVAILABLE craplim  THEN 
        DO:
            FIND crapprp WHERE crapprp.cdcooper = par_cdcooper       AND
                               crapprp.nrdconta = craplim.nrdconta   AND
                               crapprp.tpctrato = craplim.tpctrlim   AND
                               crapprp.nrctrato = craplim.nrctrlim
                               NO-LOCK NO-ERROR.

            FIND craplrt WHERE craplrt.cdcooper = par_cdcooper       AND
                               craplrt.cddlinha = craplim.cddlinha   
                               NO-LOCK NO-ERROR.


            ASSIGN tt-cabec-limcredito.dsobserv = crapprp.dsobserv[1]
                   tt-cabec-limcredito.flgpropo = TRUE
                   tt-cabec-limcredito.nrctrpro = craplim.nrctrlim
                   tt-cabec-limcredito.cdlinpro = craplim.cddlinha
                   tt-cabec-limcredito.dslimpro = IF   AVAIL craplrt   THEN 
                                                       craplrt.dsdlinha
                                                  ELSE
                                                       ""
                   tt-cabec-limcredito.vllimpro = craplim.vllimite
                   tt-cabec-limcredito.flgenpro = 
                                       IF   AVAIL crapprp   THEN
                                            IF    crapprp.flgenvio   THEN
                                                  TRUE
                                            ELSE
                                                  FALSE
                                       ELSE
                                            FALSE
                   tt-cabec-limcredito.idcobope = craplim.idcobope.
        END.
    ELSE
        ASSIGN tt-cabec-limcredito.flgpropo = FALSE
               tt-cabec-limcredito.nrctrpro = 0
               tt-cabec-limcredito.cdlinpro = 0
               tt-cabec-limcredito.vllimpro = 0
               tt-cabec-limcredito.flgenpro = FALSE
               tt-cabec-limcredito.idcobope = 0.
               
    IF  crapass.inpessoa = 1  THEN
        ASSIGN tt-cabec-limcredito.dstitulo = " LIMITE DE CREDITO ".
    ELSE
        ASSIGN tt-cabec-limcredito.dstitulo = " LIMITE EMPRESARIAL ".
   
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
/**       Procedure para listar ultimas alteracos de limite de credito       **/
/******************************************************************************/
PROCEDURE obtem-ultimas-alteracoes:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-ultimas-alteracoes.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-ultimas-alteracoes.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter ultimas alteracoes do limite de credito".

    RUN obtem-registro-limite (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtmvtolt,
                               INPUT FALSE,
                              OUTPUT TABLE tt-erro).
                               
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
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
    
    IF  par_nrctrlim = 0  THEN
        DO:
            /** FIND da craplim executado na obtem-registro-limite **/
            IF  AVAILABLE craplim  THEN 
                par_nrctrlim = craplim.nrctrlim.
        END.
        
    FOR EACH craplim WHERE craplim.cdcooper = par_cdcooper AND
                           craplim.nrdconta = par_nrdconta AND
                           craplim.tpctrlim = 1            AND 
                           craplim.insitlim = 3            AND /* CANCELADO */
                           craplim.nrctrlim <> par_nrctrlim NO-LOCK
                           BY craplim.dtinivig DESC:
            
        CREATE tt-ultimas-alteracoes.            
        ASSIGN tt-ultimas-alteracoes.nrctrlim = craplim.nrctrlim
               tt-ultimas-alteracoes.dtinivig = craplim.dtinivig 
               tt-ultimas-alteracoes.dtfimvig = craplim.dtfimvig 
               tt-ultimas-alteracoes.vllimite = craplim.vllimite
               tt-ultimas-alteracoes.dssitlli = "CANCELADO"
               tt-ultimas-alteracoes.dsmotivo = IF  craplim.cdmotcan = 1  THEN
                                                    "ALT. DE LIMITE"
                                                ELSE
                                                IF  craplim.cdmotcan = 2  THEN
                                                    "PELO ASSOCIADO"
                                                ELSE
                                                IF  craplim.cdmotcan = 3  THEN
                                                    "PELA COOPERATIVA"
                                                ELSE
                                                IF  craplim.cdmotcan = 4  THEN
                                                    "TRANSFERENCIA C/C"
                                                ELSE
                                                    "DIFERENTE".

    END. /** Fim do FOR EACH craplim **/
      
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
/**               Procedure para ativar novo limite de credito               **/
/******************************************************************************/
PROCEDURE confirmar-novo-limite: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inconfir AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-singulares.
    
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-cabrel.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-coop.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-rating.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-risco.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-risco-tl.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-assina.
    DEF OUTPUT PARAM TABLE FOR tt-efetivacao.
    DEF OUTPUT PARAM TABLE FOR tt-ratings.
    
    DEF VAR aux_dsmensag AS CHAR                                    NO-UNDO.
    
    DEF VAR old_dtultlcr AS DATE                                    NO-UNDO.
    
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_vlmaxleg AS DECI                                    NO-UNDO.
    DEF VAR aux_vlmaxutl AS DECI                                    NO-UNDO.
    DEF VAR aux_vlutiliz AS DECI                                    NO-UNDO.
    DEF VAR aux_vlcalcul AS DECI                                    NO-UNDO.
    DEF VAR old_vllimite AS DECI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
  /*DEF VAR aux_cdtipcta AS INTE                                    NO-UNDO.
    DEF VAR old_cdtipcta AS INTE                                    NO-UNDO.*/
    DEF VAR old_nrctrlim AS INTE                                    NO-UNDO.
    DEF VAR old_tplimcre AS INTE                                    NO-UNDO.
    DEF VAR old_cddlinha AS INTE                                    NO-UNDO.
    DEF VAR aux_dsoperac AS CHAR                                    NO-UNDO.

    DEF VAR aux_cdagenci LIKE crapass.cdagenci                      NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0043 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0138 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-cabrel.
    EMPTY TEMP-TABLE tt-impressao-coop.
    EMPTY TEMP-TABLE tt-impressao-rating. 
    EMPTY TEMP-TABLE tt-impressao-risco. 
    EMPTY TEMP-TABLE tt-impressao-risco-tl. 
    EMPTY TEMP-TABLE tt-impressao-assina.
    EMPTY TEMP-TABLE tt-efetivacao.
    EMPTY TEMP-TABLE tt-ratings.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Confirmar novo limite de credito".

    IF  par_inproces <> 1  THEN
        DO:
            ASSIGN aux_cdcritic = 138
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


    /* Buscar dados do cooperado */
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF NOT AVAIL(crapass)  THEN
       DO:
           ASSIGN aux_cdcritic = 9
                  aux_dscritic = "".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           IF par_flgerlog  THEN                           
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
    
    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p
           PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    ASSIGN aux_dsoperac = "Tentativa de alterar/incluir limite de credito "   +
                          "na conta " + STRING(crapass.nrdconta,"zzzz,zzz,9") +
                          " - CPF/CNPJ "                                      +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),
                                     "xx.xxx.xxx/xxxx-xx")).

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
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT 8, /*cdoperac*/
                                      INPUT aux_dsoperac,
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

          IF par_flgerlog  THEN
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

    RUN obtem-registro-limite (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtmvtolt,
                               INPUT TRUE,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
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

    IF  NOT AVAILABLE craplim  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Associado nao possui proposta de limite " +
                                  "de credito.".
                   
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
  
            RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
                SET h-b1wgen9999.
                
            IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
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
       
            RUN saldo_utiliza IN h-b1wgen9999 (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nmdatela,
                                               INPUT par_idorigem,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT par_dtmvtolt,
                                               INPUT par_dtmvtopr,
                                               INPUT "",
                                               INPUT par_inproces,
                                               INPUT FALSE, /*Consulta por cpf*/
                                              OUTPUT aux_vlutiliz,
                                              OUTPUT TABLE tt-erro).
                                              
            IF  RETURN-VALUE <> "OK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.
                        
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
                            
                    DELETE PROCEDURE h-b1wgen9999.
                    
                    RETURN "NOK".
                END.
            DELETE PROCEDURE h-b1wgen9999.

       ASSIGN aux_vlmaxleg = 0
              aux_vlmaxutl = 0.
       
       FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR. 
                           
       IF  AVAILABLE crapcop  THEN
           ASSIGN aux_vlmaxleg = crapcop.vlmaxleg
                  aux_vlmaxutl = crapcop.vlmaxutl.
 
    IF  aux_vlmaxutl > 0  THEN
        DO:
            ASSIGN aux_vlcalcul = aux_vlutiliz + craplim.vllimite -
                                  crapass.vllimcre.
                                  
            IF  aux_vlcalcul > aux_vlmaxleg  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Vlr(Legal) Excedido(Utiliz. "
                                  + TRIM(STRING(aux_vlutiliz,
                                                "zzz,zzz,zz9.99")) +
                                  " Excedido " +
                                  TRIM(STRING((aux_vlcalcul - 
                                  aux_vlmaxleg),"zzz,zzz,zz9.99")) + 
                                          ") ". 
                    
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
                
            IF  aux_vlcalcul > aux_vlmaxutl  AND 
                par_inconfir = 1             THEN
                DO:
                    aux_dsmensag = "Vlr(Utl) Excedido(Utiliz. " +
                           TRIM(STRING(aux_vlutiliz,"zzz,zzz,zz9.99")) +
                           " Excedido " +
                           TRIM(STRING((aux_vlcalcul - aux_vlmaxutl),
                                       "zzz,zzz,zz9.99")) +
                           "). Confirma?". 
                    
                    CREATE tt-msg-confirma.
                    ASSIGN tt-msg-confirma.inconfir = 1
                           tt-msg-confirma.dsmensag = aux_dsmensag.
                    
                    RETURN "OK".
                END.
        END.           
          

    ASSIGN aux_flgtrans = FALSE.

    TRANSACAO:
    
    DO TRANSACTION ON ERROR  UNDO TRANSACAO, LEAVE TRANSACAO
                   ON ENDKEY UNDO TRANSACAO, LEAVE TRANSACAO:

        IF  crapass.dtelimin <> ?  THEN
            DO:
                ASSIGN aux_cdcritic = 410
                       aux_dscritic = "".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  LOOKUP(STRING(crapass.cdsitdtl),"5,6,7,8,17,18") <> 0  THEN
            DO:
                ASSIGN aux_cdcritic = 695
                       aux_dscritic = "".
                      
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  LOOKUP(STRING(crapass.cdsitdtl),"2,4,6,8") <> 0  THEN
            DO:
                ASSIGN aux_cdcritic = 95
                       aux_dscritic = "".
                      
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        /* P450 - Rating */
        /*AQUI VALIDA RATING ANTES DA EFETIVAR PROPOSTA DE LIMITE*/
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_busca_status_rating
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper     /* pr_cdcooper */
                                            ,INPUT par_nrdconta     /* pr_nrdconta */
                                            ,INPUT 1                /* pr_tpctrato */
                                            ,INPUT craplim.nrctrlim /* pr_nrctrato */
                                            ,OUTPUT 0               /* pr_strating */
                                            ,OUTPUT 0               /* Flag do Rating */
                                            ,OUTPUT 0               /* pr_cdcritic */
                                            ,OUTPUT "").            /* pr_dscritic */

        CLOSE STORED-PROC pc_busca_status_rating
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic = pc_busca_status_rating.pr_dscritic
               WHEN pc_busca_status_rating.pr_dscritic <> ?.
        ASSIGN aux_cdcritic = pc_busca_status_rating.pr_cdcritic
               WHEN pc_busca_status_rating.pr_cdcritic <> ?.  
               
        IF aux_dscritic <> "" THEN
        DO:
            ASSIGN aux_flgtrans = FALSE.
            UNDO TRANSACAO, LEAVE TRANSACAO.
        END.       
              
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
     
        RUN STORED-PROCEDURE pc_busca_endivid_param aux_handproc = PROC-HANDLE
            (INPUT  par_cdcooper
            ,INPUT  par_nrdconta
            ,OUTPUT 0  /*pr_vlendivi */ 
            ,OUTPUT 0  /*pr_vlrating */
            ,OUTPUT "").
                                           
        CLOSE STORED-PROCEDURE pc_busca_endivid_param WHERE PROC-HANDLE = aux_handproc.
         
        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
         
        ASSIGN aux_dscritic = pc_busca_endivid_param.pr_dscritic
                         WHEN pc_busca_endivid_param.pr_dscritic <> ?.
          
        IF aux_dscritic <> "" THEN
        DO:
		    ASSIGN aux_flgtrans = FALSE.
            UNDO TRANSACAO, LEAVE TRANSACAO.
        END.          
              
        IF  pc_busca_status_rating.pr_flgrating = 0 THEN 
        DO:
            ASSIGN aux_cdcritic = 0
			       aux_flgtrans = FALSE
                   aux_dscritic = "Proposta nao pode ser efetivada, pois nao ha Rating valido".
                   
            UNDO TRANSACAO, LEAVE TRANSACAO.
        END.  
        /* Status do rating válido */ 
        ELSE 
        DO:
              
             /* Se Endividamento + Contrato atual > Parametro Rating (TAB056) */

             IF ((pc_busca_endivid_param.pr_vlendivi + craplim.VLLIMITE) >
                  pc_busca_endivid_param.pr_vlrating)  THEN 
             DO:

                 /* Gravar o Rating da operaçao, efetivando-o */
                 { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                 
                  /* procedure confirmar-novo-limite */
                  RUN STORED-PROCEDURE pc_grava_rating_operacao 
                  aux_handproc = PROC-HANDLE  NO-ERROR
                                  (INPUT par_cdcooper
                                  ,INPUT par_nrdconta
                                  ,INPUT 1            /* Tipo Contrato */
                                  ,INPUT craplim.nrctrlim
                                  ,INPUT ?
                                  ,INPUT ?             /* null para pr_ntrataut */
                                  ,INPUT par_dtmvtolt  /* pr_dtrating */
                                  ,INPUT 4     /* pr_strating => 4 -- efetivado */
                                  ,INPUT ?     /* pr_orrating => 4 --contingencia */
                                  ,INPUT par_cdoperad
                                  ,INPUT ?             /* null para pr_dtrataut */
                                  ,INPUT ?             /* null pr_innivel_rating */
                                  ,INPUT crapass.nrcpfcnpj_base
                                  ,INPUT ?             /* pr_inpontos_rating     */
                                  ,INPUT ?             /* pr_insegmento_rating   */
                                  ,INPUT ?             /* pr_inrisco_rat_inc     */
                                  ,INPUT ?             /* pr_innivel_rat_inc     */
                                  ,INPUT ?             /* pr_inpontos_rat_inc    */
                                  ,INPUT ?             /* pr_insegmento_rat_inc  */
                                  ,INPUT ?             /* pr_efetivacao_rating   */
                                  ,INPUT "1" /* pr_cdoperad*/
                                  ,INPUT par_dtmvtolt
                                  ,INPUT craplim.VLLIMITE
                                  ,INPUT ? /*sugerido*/
                                  ,INPUT "" /*Justif*/
                                  ,INPUT ?
                                  ,OUTPUT 0            /* pr_cdcritic */
                                  ,OUTPUT "").         /* pr_dscritic */


                  CLOSE STORED-PROCEDURE pc_grava_rating_operacao
                        WHERE PROC-HANDLE = aux_handproc.
             
                  { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                     
                  ASSIGN aux_dscritic = pc_grava_rating_operacao.pr_dscritic
                         WHEN pc_grava_rating_operacao.pr_dscritic <> ?.
                      
                 IF aux_dscritic <> "" THEN
                 DO:
					 ASSIGN aux_flgtrans = FALSE.
                     UNDO TRANSACAO, LEAVE TRANSACAO.
                       
                 END.      
               
             END.
        END.    
    

         /*AQUI VALIDA DATA RATING EXPIRADO ANTES DA EFETIVAR PROPOSTA DE LIMITE*/
        /*{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_busca_rat_expirado
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper     /* pr_cdcooper */
                                            ,INPUT par_nrdconta     /* pr_nrdconta */
                                            ,INPUT 1                /* pr_tpctrato */
                                            ,INPUT craplim.nrctrlim /* pr_nrctrato */
                                            ,OUTPUT 0               /* pr_cdcritic */
                                            ,OUTPUT "").            /* pr_dscritic */

        CLOSE STORED-PROC pc_busca_rat_expirado
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic = pc_busca_rat_expirado.pr_dscritic
               WHEN pc_busca_rat_expirado.pr_dscritic <> ?.
        ASSIGN aux_cdcritic = pc_busca_rat_expirado.pr_cdcritic
               WHEN pc_busca_rat_expirado.pr_cdcritic <> ?.  
               
        IF aux_dscritic <> "" THEN
        DO:
            ASSIGN aux_flgtrans = FALSE.
            UNDO TRANSACAO, LEAVE TRANSACAO.
        END.*/
	/* P450 - Rating */

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        
        RUN STORED-PROCEDURE pc_permite_produto_tipo
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT 13,               /* Codigo do produto */
                                             INPUT crapass.cdtipcta, /* Tipo de conta */
                                             INPUT crapass.cdcooper, /* Cooperativa */
                                             INPUT crapass.inpessoa, /* Tipo de pessoa */
                                            OUTPUT "",   /* Possui produto */
                                            OUTPUT 0,   /* Codigo da crítica */
                                            OUTPUT "").  /* Descriçao da crítica */
        
        CLOSE STORED-PROC pc_permite_produto_tipo
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN aux_possuipr = ""
               aux_cdcritic = 0
               aux_dscritic = ""
               aux_possuipr = pc_permite_produto_tipo.pr_possuipr 
                              WHEN pc_permite_produto_tipo.pr_possuipr <> ?
               aux_cdcritic = pc_permite_produto_tipo.pr_cdcritic 
                              WHEN pc_permite_produto_tipo.pr_cdcritic <> ?
               aux_dscritic = pc_permite_produto_tipo.pr_dscritic
                              WHEN pc_permite_produto_tipo.pr_dscritic <> ?.
        
        IF aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
            DO:
                UNDO TRANSACAO, LEAVE TRANSACAO.
             END.
        
        IF aux_possuipr = "N" THEN 
            DO:
                ASSIGN aux_cdcritic = 104
                       aux_dscritic = "".
                      
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
          
        ASSIGN /*aux_cdtipcta = crapass.cdtipcta
               old_cdtipcta = crapass.cdtipcta*/
               old_tplimcre = crapass.tplimcre
               old_dtultlcr = crapass.dtultlcr
               old_nrctrlim = 0
               old_vllimite = 0
               old_cddlinha = 0.
        /*
        IF  CAN-DO("1,3,8,10,12,14",STRING(crapass.cdtipcta))  THEN
            ASSIGN aux_cdtipcta = crapass.cdtipcta + 1.
        */
        /** Cancela limite atual **/
        DO aux_contador = 1 TO 10:  

            FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND 
                                     craplim.nrdconta = par_nrdconta AND
                                     craplim.tpctrlim = 1            AND
                                     craplim.insitlim = 2
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            ASSIGN aux_dscritic = "".
                    
            IF  NOT AVAILABLE craplim  THEN
                DO:
                    IF  LOCKED craplim  THEN
                        DO:
                            aux_dscritic = "Registro do limite de esta sendo " +
                                           "alterado. Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                END.
            ELSE
                DO:


                    /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                    IF par_cdagenci = 0 THEN
                      ASSIGN par_cdagenci = glb_cdagenci.
                    /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */


                    /** Armazena dados do limite atual **/
                    ASSIGN old_nrctrlim = craplim.nrctrlim
                           old_vllimite = craplim.vllimite
                           old_cddlinha = craplim.cddlinha.
                           
                    /** Atualiza dados **/       
                    ASSIGN craplim.insitlim = 3
                           craplim.cdmotcan = 1
                           /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                           craplim.cdopeexc = par_cdoperad
                           craplim.cdageexc = par_cdagenci
                           craplim.dtinsexc = TODAY
                           /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                           craplim.dtfimvig = par_dtmvtolt.
  
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                    /* Faz a vinculaçao da garantia com a proposta */
                    RUN STORED-PROCEDURE pc_bloq_desbloq_cob_operacao
                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT ""               /* pr_nmdatela */
                                                        ,INPUT craplim.idcobope /* pr_idcobertura */
                                                        ,INPUT "D"              /* pr_inbloq_desbloq */
                                                        ,INPUT par_cdoperad     /* pr_cdoperador */
                                                        ,INPUT ""               /* pr_cdcoordenador_desbloq */
                                                        ,INPUT 0                /* pr_vldesbloq */
                                                        ,INPUT "S"              /* pr_flgerar_log */
                                                        ,"").                   /* pr_dscritic */

                    CLOSE STORED-PROC pc_bloq_desbloq_cob_operacao
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                    ASSIGN aux_dscritic = pc_bloq_desbloq_cob_operacao.pr_dscritic
                                         WHEN pc_bloq_desbloq_cob_operacao.pr_dscritic <> ?.

                    IF  aux_dscritic <> "" THEN
                        UNDO TRANSACAO, LEAVE TRANSACAO.
  
                    RUN sistema/generico/procedures/b1wgen0043.p 
                                         PERSISTENT SET h-b1wgen0043.

                    IF  NOT VALID-HANDLE(h-b1wgen0043)  THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Handle invalido para BO " +
                                                  "b1wgen0043.".

                            UNDO TRANSACAO, LEAVE TRANSACAO.
                        END.

                
                    RUN desativa_rating IN h-b1wgen0043
                                            (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_dtmvtolt,
                                             INPUT par_dtmvtopr,
                                             INPUT par_nrdconta,
                                             INPUT 1, /* Limite cred.*/
                                             INPUT craplim.nrctrlim,
                                             INPUT FALSE,
                                             INPUT par_idseqttl,
                                             INPUT par_idorigem,
                                             INPUT par_nmdatela,
                                             INPUT par_inproces,
                                             INPUT FALSE,
                                            OUTPUT TABLE tt-erro).

                    DELETE PROCEDURE h-b1wgen0043.

                    IF  RETURN-VALUE <> "OK"  THEN
                        UNDO TRANSACAO, LEAVE TRANSACAO.

                    DO aux_contador = 1 TO 10:
                
                        FIND crapmcr WHERE 
                             crapmcr.cdcooper = par_cdcooper     AND
                             crapmcr.nrdconta = par_nrdconta     AND
                             crapmcr.nrcontra = craplim.nrctrlim AND
                             crapmcr.tpctrmif = 2 /** Limite **/ AND
                             crapmcr.tpctrlim = craplim.tpctrlim
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                       
                        ASSIGN aux_dscritic = "".
                             
                        IF  NOT AVAILABLE crapmcr  THEN
                            DO:
                                IF  LOCKED crapmcr  THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 0
                                               aux_dscritic = "Registro de " +
                                                  "microfilmagem esta sendo " +
                                                  "alterado. Tente novamente.".
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                                ELSE
                                    ASSIGN aux_cdcritic = 752
                                           aux_dscritic = " ".
                            END.

                        LEAVE.
                    
                    END. /** Fim do DO ... TO **/

                    IF  aux_dscritic <> ""  THEN
                        UNDO TRANSACAO, LEAVE TRANSACAO.

                    IF  craplim.dtinivig >= 04/01/2003  THEN
                        ASSIGN crapmcr.dtcancel = par_dtmvtolt.

                END.
 
            LEAVE.

        END. /** Fim do DO ... TO **/


        IF  aux_dscritic <> ""  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.
            
        FIND crapope WHERE crapope.cdcooper = par_cdcooper
                       AND UPPER(crapope.cdoperad) = UPPER(par_cdoperad)
                       NO-LOCK NO-ERROR.
        
        /** Ativa proposta de limite **/
        DO aux_contador = 1 TO 10:

            FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                                     craplim.nrdconta = par_nrdconta AND
                                     craplim.tpctrlim = 1            AND
                                     craplim.insitlim = 1
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            ASSIGN aux_dscritic = "".
                    
            IF  NOT AVAILABLE craplim  THEN
                DO:
                    IF  LOCKED craplim  THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Registro do limite esta " +
                                                  "sendo alterado. Tente " +
                                                  "novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_cdcritic = 484
                               aux_dscritic = " ".
                END.
 
            LEAVE.

        END. /** Fim do DO ... TO **/


        IF  aux_dscritic <> ""  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.

        /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
        IF par_cdagenci = 0 THEN
          ASSIGN par_cdagenci = glb_cdagenci.
        /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */

        ASSIGN aux_cdagenci = par_cdagenci.

        IF AVAIL(crapope) THEN
           DO:
             aux_cdagenci = crapope.cdpactra.
           END.

        ASSIGN craplim.insitlim = 2
               craplim.dtinivig = par_dtmvtolt
               craplim.cdopelib = par_cdoperad
               /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               craplim.cdopeori = par_cdoperad
               craplim.cdageori = aux_cdagenci
               craplim.dtinsori = TODAY
               /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               craplim.dtfimvig = craplim.dtinivig + craplim.qtdiavig.

        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* Faz a vinculaçao da garantia com a proposta */
        RUN STORED-PROCEDURE pc_bloq_desbloq_cob_operacao
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT ""               /* pr_nmdatela */
                                            ,INPUT craplim.idcobope /* pr_idcobertura */
                                            ,INPUT "B"              /* pr_inbloq_desbloq */
                                            ,INPUT par_cdoperad     /* pr_cdoperador */
                                            ,INPUT ""               /* pr_cdcoordenador_desbloq */
                                            ,INPUT 0                /* pr_vldesbloq */
                                            ,INPUT "S"              /* pr_flgerar_log */
                                            ,"").                   /* pr_dscritic */

        CLOSE STORED-PROC pc_bloq_desbloq_cob_operacao
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic = pc_bloq_desbloq_cob_operacao.pr_dscritic
                             WHEN pc_bloq_desbloq_cob_operacao.pr_dscritic <> ?.

        IF  aux_dscritic <> "" THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.

        
        FIND crapmcr WHERE crapmcr.cdcooper = par_cdcooper     AND
                           crapmcr.nrdconta = par_nrdconta     AND
                           crapmcr.dtmvtolt = par_dtmvtolt     AND
                           crapmcr.cdagenci = aux_cdagenci     AND
                           crapmcr.cdbccxlt = 0                AND
                           crapmcr.nrdolote = 0                AND
                           crapmcr.nrcontra = craplim.nrctrlim AND
                           crapmcr.tpctrmif = 2 /** Limite **/
                           NO-LOCK NO-ERROR.

        IF  AVAILABLE crapmcr  THEN                   
            DO:
                ASSIGN aux_cdcritic = 753
                       aux_dscritic = "".

                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
        ELSE
            DO:
                CREATE crapmcr.
                ASSIGN crapmcr.dtmvtolt = par_dtmvtolt
                       crapmcr.cdagenci = aux_cdagenci
                       crapmcr.cdbccxlt = 0
                       crapmcr.nrdolote = 0
                       crapmcr.nrdconta = par_nrdconta
                       crapmcr.nrcontra = craplim.nrctrlim
                       crapmcr.tpctrmif = 2
                       crapmcr.vlcontra = craplim.vllimite
                       crapmcr.nrctaav1 = craplim.nrctaav1
                       crapmcr.nrctaav2 = craplim.nrctaav2
                       crapmcr.tpctrlim = craplim.tpctrlim
                       crapmcr.qtrenova = craplim.qtrenova
                       crapmcr.cddlinha = craplim.cddlinha
                       crapmcr.cdcooper = par_cdcooper.
                VALIDATE crapmcr.
            END.

        RUN atualiza-registro-associado (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nrdconta,
                                         INPUT par_dtmvtolt,
                                         INPUT 0,
                                         INPUT craplim.vllimite,
                                         INPUT craplim.inbaslim,
                                        OUTPUT TABLE tt-erro).
                                         
        IF  RETURN-VALUE <> "OK"  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.

        RUN sistema/generico/procedures/b1wgen0043.p 
                                        PERSISTENT SET h-b1wgen0043.

        IF  NOT VALID-HANDLE(h-b1wgen0043)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO b1wgen0043.".

                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  par_cdcooper = 3  THEN
        DO:
            RUN gera_rating_singulares 
                            IN h-b1wgen0043 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT par_dtmvtolt,
                                             INPUT par_dtmvtopr,
                                             INPUT par_inproces,
                                             INPUT 1,  /** Limite Credito **/
                                             INPUT craplim.nrctrlim,
                                             INPUT TRUE,
                                             INPUT FALSE,
                                             INPUT TABLE tt-singulares,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-cabrel,
                                            OUTPUT TABLE tt-impressao-coop,
                                            OUTPUT TABLE tt-impressao-rating,
                                            OUTPUT TABLE tt-impressao-risco,
                                            OUTPUT TABLE tt-impressao-risco-tl,
                                            OUTPUT TABLE tt-impressao-assina,
                                            OUTPUT TABLE tt-efetivacao,
                                            OUTPUT TABLE tt-ratings). 
        END.
        ELSE
        DO:
            RUN gera_rating IN h-b1wgen0043 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT par_dtmvtolt,
                                             INPUT par_dtmvtopr,
                                             INPUT par_inproces,
                                             INPUT 1,  /** Limite Credito **/
                                             INPUT craplim.nrctrlim,
                                             INPUT TRUE,
                                             INPUT FALSE,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-cabrel,
                                            OUTPUT TABLE tt-impressao-coop,
                                            OUTPUT TABLE tt-impressao-rating,
                                            OUTPUT TABLE tt-impressao-risco,
                                            OUTPUT TABLE tt-impressao-risco-tl,
                                            OUTPUT TABLE tt-impressao-assina,
                                            OUTPUT TABLE tt-efetivacao,
                                            OUTPUT TABLE tt-ratings). 
        END.

        DELETE PROCEDURE h-b1wgen0043.

        IF  RETURN-VALUE <> "OK"  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.
                
        ASSIGN aux_flgtrans = TRUE. 

    END. /** Fim do DO TRANSACTION - TRANSACAO **/
    

    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE
                DO:
                    IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                        ASSIGN aux_dscritic = "Erro na transacao. Nao foi " + 
                                              "possivel confirmar novo limite.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.
                   
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
        DO:
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
                               
            /** Numero de Contrato do Limite **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctrlim",
                                     INPUT TRIM(STRING(old_nrctrlim,
                                                       "zzz,zzz,zz9")),
                                     INPUT TRIM(STRING(craplim.nrctrlim,
                                                       "zzz,zzz,zz9"))).

            /** Linha de Credito do Limite **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "cddlinha",
                                     INPUT TRIM(STRING(old_cddlinha,
                                                       "zz9")),
                                     INPUT TRIM(STRING(craplim.cddlinha,
                                                       "zz9"))).
                                                    
            /** Valor do Limite **/
            IF  old_vllimite <> craplim.vllimite  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "vllimite",
                                         INPUT TRIM(STRING(old_vllimite,
                                                           "zzz,zzz,zz9,99")),
                                         INPUT TRIM(STRING(craplim.vllimite,
                                                           "zzz,zzz,zz9.99"))).
            /*
            /** Tipo da Conta **/
            IF  old_cdtipcta <> aux_cdtipcta  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "cdtipcta",
                                         INPUT TRIM(STRING(old_cdtipcta,
                                                           "z9")),
                                         INPUT TRIM(STRING(aux_cdtipcta,
                                                           "z9"))).
            */
            /** Tipo do Limite **/
            IF  old_tplimcre <> craplim.inbaslim  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "tplimcre",
                                         INPUT TRIM(STRING(old_tplimcre,
                                                           "9")),
                                         INPUT TRIM(STRING(craplim.inbaslim,
                                                           "9"))).
                         
            /** Data Alteracao do Limite **/
            IF  old_dtultlcr <> par_dtmvtolt  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtultlcr",
                                         INPUT STRING(old_dtultlcr,
                                                      "99/99/9999"),
                                         INPUT STRING(par_dtmvtolt,
                                                      "99/99/9999")).
        END.                               


    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**    Procedure para obter proposta ou contrato de limite de credito        **/
/******************************************************************************/
PROCEDURE obtem-limite:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flpropos AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inconfir AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-proposta-limcredito.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.
    
    DEF VAR h-b1wgen0001 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0058 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_nrdeanos AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdmeses AS INTE                                    NO-UNDO.
    DEF VAR aux_dsdidade AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI INIT FALSE                         NO-UNDO.
    DEF VAR aux_nrcpfcjg AS DECI                                    NO-UNDO.
    DEF VAR aux_nrctacje AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-proposta-limcredito.
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obtem proposta de limite de credito".

    Obtem_Limite:
    DO ON ERROR UNDO, LEAVE:
    
       /* rotina para buscar o crapttl.inhabmen */
       FIND FIRST crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                crapttl.nrdconta = par_nrdconta   AND
                                crapttl.idseqttl = 1
                                NO-LOCK NO-ERROR.
       IF  AVAIL crapttl THEN
           DO:
                     
               IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                   RUN sistema/generico/procedures/b1wgen9999.p 
                       PERSISTENT SET h-b1wgen9999.
              
               /*  Rotina que retorna a idade do cooperado */
               RUN idade IN h-b1wgen9999(INPUT crapttl.dtnasttl,
                                         INPUT par_dtmvtolt,
                                         OUTPUT aux_nrdeanos,
                                         OUTPUT aux_nrdmeses,
                                         OUTPUT aux_dsdidade).
              
               IF  VALID-HANDLE(h-b1wgen9999) THEN
                   DELETE PROCEDURE h-b1wgen9999.
              
               IF  par_inconfir = 1     AND
                   aux_nrdeanos >= 16   AND 
                   aux_nrdeanos <  18   AND 
                   crapttl.inhabmen = 0 THEN 
                   DO:
                       CREATE tt-msg-confirma.                    
                       ASSIGN tt-msg-confirma.inconfir = par_inconfir + 1
                              tt-msg-confirma.dsmensag = "Atencao! Cooperado menor de idade. Deseja continuar?".
                       RETURN "OK".
                   END.

               IF  aux_nrdeanos < 16 THEN 
                   DO:
                      ASSIGN aux_cdcritic = 0
                             aux_dscritic = 
                          "Cooperado menor de idade, nao e " +
                          "possivel realizar a operacao.".

                      LEAVE Obtem_Limite.
                   END.

               FIND crapcje WHERE crapcje.cdcooper = par_cdcooper   AND
                                  crapcje.nrdconta = par_nrdconta   AND
                                  crapcje.idseqttl = 1
                                  NO-LOCK NO-ERROR.

               IF   AVAIL crapcje   THEN
                    ASSIGN aux_nrcpfcjg = crapcje.nrcpfcjg
                           aux_nrctacje = crapcje.nrctacje.

           END.

       RUN obtem-registro-limite (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_nmdatela,
                                  INPUT par_idorigem,
                                  INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT par_dtmvtolt,
                                  INPUT par_flpropos,
                                 OUTPUT TABLE tt-erro).
                               
       IF   RETURN-VALUE <> "OK"  THEN
            LEAVE Obtem_Limite.

       RUN sistema/generico/procedures/b1wgen0001.p 
           PERSISTENT SET h-b1wgen0001.
                
       IF  NOT VALID-HANDLE(h-b1wgen0001)  THEN
           DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Handle invalido para BO b1wgen0001.".
                       
               LEAVE Obtem_Limite.
           END.

       IF par_inconfir = 1 THEN
           DO:
           
             RUN ver_cadastro IN h-b1wgen0001 (INPUT par_cdcooper,
                                               INPUT par_nrdconta,
                                               INPUT par_cdagenci, 
                                               INPUT par_nrdcaixa, 
                                               INPUT par_dtmvtolt,
                                               INPUT par_idorigem,
                                              OUTPUT TABLE tt-erro).
        
             DELETE PROCEDURE h-b1wgen0001.
              
             IF   RETURN-VALUE <> "OK"  THEN
                  LEAVE Obtem_Limite.

           END.

       FIND craplrt WHERE craplrt.cdcooper = craplim.cdcooper   AND
                          craplrt.cddlinha = craplim.cddlinha   NO-LOCK NO-ERROR.
                   
       CREATE tt-proposta-limcredito.
       ASSIGN tt-proposta-limcredito.nrctacje = aux_nrctacje
              tt-proposta-limcredito.nrcpfcjg = aux_nrcpfcjg.
            
       
       /** Verifica se procedure obtem-registro-limite encontrou uma proposta **/
       IF  AVAILABLE craplim  THEN
           ASSIGN tt-proposta-limcredito.nrctrpro = craplim.nrctrlim
                  tt-proposta-limcredito.vllimpro = craplim.vllimite
                  tt-proposta-limcredito.flgimpnp = craplim.flgimpnp
                  tt-proposta-limcredito.cddlinha = craplim.cddlinha
                  tt-proposta-limcredito.nrgarope = craplim.nrgarope
                  tt-proposta-limcredito.nrinfcad = craplim.nrinfcad
                  tt-proposta-limcredito.nrliquid = craplim.nrliquid
                  tt-proposta-limcredito.nrpatlvr = craplim.nrpatlvr
                  tt-proposta-limcredito.vltotsfn = craplim.vltotsfn
                  tt-proposta-limcredito.nrperger = craplim.nrperger
                  tt-proposta-limcredito.dtconbir = craplim.dtconbir
                  tt-proposta-limcredito.nivrisco = "A"
                  tt-proposta-limcredito.inconcje = craplim.inconcje
                  tt-proposta-limcredito.dsdlinha = IF   AVAIL craplrt   THEN
                                                         craplrt.dsdlinha
                                                    ELSE
                                                         ""
                  /* PRJ 438 - Sprint 7 - Retornar a taxa da linha de credito */                                       
                  tt-proposta-limcredito.dsdtxfix = IF   AVAIL craplrt   THEN
                                                         STRING(craplrt.txjurfix) + '% + TR'
                                                    ELSE
                                                         ""
                                                         .
       ELSE           
           ASSIGN tt-proposta-limcredito.nrctrpro = 0
                  tt-proposta-limcredito.vllimpro = 0
                  tt-proposta-limcredito.flgimpnp = TRUE
                  tt-proposta-limcredito.cddlinha = 0
                  tt-proposta-limcredito.dsdlinha = ""
                  tt-proposta-limcredito.nrgarope = 0
                  tt-proposta-limcredito.nrinfcad = 0
                  tt-proposta-limcredito.nrliquid = 0
                  tt-proposta-limcredito.nrpatlvr = 0
                  tt-proposta-limcredito.vltotsfn = 0
                  tt-proposta-limcredito.nrperger = 0
                  /* PRJ 438 - Sprint 7 - Retornar a taxa da linha de credito */
                  tt-proposta-limcredito.dsdtxfix = ""
                  tt-proposta-limcredito.nivrisco = "A"
                  tt-proposta-limcredito.inconcje = 0.

       ASSIGN aux_flgtrans = TRUE.
                      
    END.

    IF   NOT aux_flgtrans   THEN
         DO: 
             IF   NOT TEMP-TABLE tt-erro:HAS-RECORDS   THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
                     
             IF  par_flgerlog  THEN
                 DO:
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
            
                 END.
                 
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


/******************************************************************************/
/**           Procedure para excluir proposta de limite de credito           **/
/******************************************************************************/
PROCEDURE excluir-novo-limite:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    
    DEF BUFFER crabavl FOR crapavl.
    DEF BUFFER crabavt FOR crapavt.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Excluir proposta de limite de credito".

    RUN obtem-registro-limite (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtmvtolt,
                               INPUT TRUE,
                              OUTPUT TABLE tt-erro).
                               
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
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
        
    ASSIGN aux_flgtrans = FALSE.
    
    TRANSACAO:
    
    DO TRANSACTION ON ENDKEY UNDO TRANSACAO, LEAVE TRANSACAO:

        DO aux_contador = 1 TO 10:

            FIND CURRENT craplim EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            ASSIGN aux_dscritic = "".
            
            IF  NOT AVAILABLE craplim  THEN
                DO:
                    IF  LOCKED craplim  THEN
                        DO:
                            aux_dscritic = "Registro de limite de credito " + 
                                           "esta sendo alterado. Tente " +
                                           "novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        aux_dscritic = "Registro de limite de credito nao " +
                                       "encontrado.".
                END.
            
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

        DO aux_contador = 1 TO 10:
        
            FIND FIRST crapprp WHERE crapprp.cdcooper = par_cdcooper     AND
                                     crapprp.nrdconta = par_nrdconta     AND
                                     crapprp.tpctrato = 1                AND
                                     crapprp.nrctrato = craplim.nrctrlim
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            ASSIGN aux_dscritic = "".
            
            IF  NOT AVAILABLE crapprp  THEN
                DO:
                    IF  LOCKED crapprp  THEN
                        DO:
                            aux_dscritic = "Registro de proposta esta sendo " +
                                           "alterado. Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                END.
            ELSE
                DELETE crapprp.

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
                            
        FOR EACH crabavl WHERE crabavl.cdcooper = par_cdcooper      AND
                             ((craplim.nrctaav1 <> 0                AND
                               crabavl.nrdconta = craplim.nrctaav1) OR
                              (craplim.nrctaav2 <> 0                AND
                               crabavl.nrdconta = craplim.nrctaav2)) AND
                               crabavl.nrctravd = craplim.nrctrlim  AND
                               crabavl.tpctrato = 3
                               NO-LOCK USE-INDEX crapavl1:

            DO aux_contador = 1 TO 10:
                    
                FIND crapavl WHERE RECID(crapavl) = RECID(crabavl)
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                       
                ASSIGN aux_dscritic = "".
                        
                IF  NOT AVAILABLE crapavl  THEN
                    DO:
                        IF  LOCKED crapavl  THEN
                            DO:
                                aux_dscritic = "Registro de avalista esta " +
                                               "sendo alterado. Tente " +
                                               "novamente.".
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE
                            aux_dscritic = "Registro de avalista nao " +
                                           "encontrado.".
                    END.
                ELSE    
                    DELETE crapavl.

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
                    
        END. /** Fim do FOR EACH crabavl **/
                                    
        FOR EACH crabavt WHERE crabavt.cdcooper = par_cdcooper     AND
                               crabavt.nrdconta = craplim.nrdconta AND
                               crabavt.nrctremp = craplim.nrctrlim AND
                               crabavt.tpctrato = 3                NO-LOCK:
                               
            DO aux_contador = 1 TO 10:
                    
                FIND crapavt WHERE RECID(crapavt) = RECID(crabavt)
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                       
                ASSIGN aux_dscritic = "".
                        
                IF  NOT AVAILABLE crapavt  THEN
                    DO:
                        IF  LOCKED crapavt  THEN
                            DO:
                                aux_dscritic = "Registro de avalista esta " +
                                               "sendo alterado. Tente " +
                                               "novamente.".
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE
                            aux_dscritic = "Registro de avalista nao " + 
                                           "encontrado.".
                    END.
                ELSE    
                    DELETE crapavt.

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

        END. /** Fim do FOR EACH crabavt **/

        DELETE craplim.
                                    
        ASSIGN aux_flgtrans = TRUE.
        
    END. /** Fim do DO TRANSACTION - TRANSACAO **/

    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Erro na transacao. Nao foi " + 
                                          "possivel excluir novo limite.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.
                   
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


/******************************************************************************/
/**              Procedure para excluir limite de credito atual              **/
/******************************************************************************/
PROCEDURE cancelar-limite-atual:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR old_dtultlcr AS DATE                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
  /*DEF VAR aux_cdtipcta AS INTE                                    NO-UNDO.
    DEF VAR old_cdtipcta AS INTE                                    NO-UNDO.*/
    DEF VAR old_nrctrlim AS INTE                                    NO-UNDO.
    DEF VAR old_tplimcre AS INTE                                    NO-UNDO.
        
    DEF VAR old_vllimite AS DECI                                    NO-UNDO.
    
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR h-b1wgen0043 AS HANDLE                                  NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Cancelar limite de credito atual".

    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
   
    IF  NOT AVAIL crapdat  THEN
        DO:
            ASSIGN aux_cdcritic = 1
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
    
    RUN obtem-registro-limite (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtmvtolt,
                               INPUT FALSE,
                              OUTPUT TABLE tt-erro).
                               
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
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

    IF  AVAILABLE craplim AND craplim.insitlim <> 2  THEN
        DO:
            ASSIGN aux_cdcritic = 105
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
        
    ASSIGN aux_flgtrans = FALSE.
    
    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
        
        IF  crapass.dtelimin <> ?  THEN
            DO:
                ASSIGN aux_cdcritic = 410
                       aux_dscritic = "".
                       
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
                   
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        
        RUN STORED-PROCEDURE pc_permite_produto_tipo
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT 13,               /* Codigo do produto */
                                             INPUT crapass.cdtipcta, /* Tipo de conta */
                                             INPUT crapass.cdcooper, /* Cooperativa */
                                             INPUT crapass.inpessoa, /* Tipo de pessoa */
                                            OUTPUT "",   /* Possui produto */
                                            OUTPUT 0,   /* Codigo da crítica */
                                            OUTPUT "").  /* Descriçao da crítica */
        
        CLOSE STORED-PROC pc_permite_produto_tipo
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN aux_possuipr = ""
               aux_cdcritic = 0
               aux_dscritic = ""
               aux_possuipr = pc_permite_produto_tipo.pr_possuipr 
                              WHEN pc_permite_produto_tipo.pr_possuipr <> ?
               aux_cdcritic = pc_permite_produto_tipo.pr_cdcritic 
                              WHEN pc_permite_produto_tipo.pr_cdcritic <> ?
               aux_dscritic = pc_permite_produto_tipo.pr_dscritic
                              WHEN pc_permite_produto_tipo.pr_dscritic <> ?.
        
        IF aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
             DO:
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
                   
        IF aux_possuipr = "N" THEN 
            DO:
                ASSIGN aux_cdcritic = 104
                       aux_dscritic = "".
                      
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
        
        IF  crapass.vllimcre = 0  THEN
            DO:
                ASSIGN aux_cdcritic = 105
                       aux_dscritic = "".
                      
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        ASSIGN /*aux_cdtipcta = crapass.cdtipcta
               old_cdtipcta = crapass.cdtipcta*/
               old_tplimcre = crapass.tplimcre
               old_dtultlcr = crapass.dtultlcr
               old_nrctrlim = 0
               old_vllimite = 0.
        /*
        IF  CAN-DO("2,4,9,11,13,15",STRING(crapass.cdtipcta))  THEN
            ASSIGN aux_cdtipcta = crapass.cdtipcta - 1.
        */
          
        DO aux_contador = 1 TO 10:

            FIND CURRENT craplim EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            ASSIGN aux_dscritic = "".
            
            IF  NOT AVAILABLE craplim  THEN
                DO:
                    IF  LOCKED craplim  THEN
                        DO:
                            aux_dscritic = "Registro de limite de credito " +
                                           "esta sendo alterado. Tente " +
                                           "novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        aux_dscritic = "Registro de limite de credito nao " +
                                       "encontrado.".
                END.

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
                
        /** Armazena dados do limite atual **/
        ASSIGN old_nrctrlim = craplim.nrctrlim
               old_vllimite = craplim.vllimite.
               
        /** Atualiza dados **/       
        ASSIGN craplim.insitlim = 3
               craplim.cdmotcan = 0
               /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               craplim.cdopeexc = par_cdoperad
               craplim.cdageexc = par_cdagenci
               craplim.dtinsexc = TODAY
               /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               craplim.dtfimvig = par_dtmvtolt.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* Faz a vinculaçao da garantia com a proposta */
        RUN STORED-PROCEDURE pc_bloq_desbloq_cob_operacao
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT ""               /* pr_nmdatela */
                                            ,INPUT craplim.idcobope /* pr_idcobertura */
                                            ,INPUT "D"              /* pr_inbloq_desbloq */
                                            ,INPUT par_cdoperad     /* pr_cdoperador */
                                            ,INPUT ""               /* pr_cdcoordenador_desbloq */
                                            ,INPUT 0                /* pr_vldesbloq */
                                            ,INPUT "S"              /* pr_flgerar_log */
                                            ,"").                   /* pr_dscritic */

        CLOSE STORED-PROC pc_bloq_desbloq_cob_operacao
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic = pc_bloq_desbloq_cob_operacao.pr_dscritic
                             WHEN pc_bloq_desbloq_cob_operacao.pr_dscritic <> ?.

        IF  aux_dscritic <> "" THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.
        
        DO aux_contador = 1 TO 10:
        
            FIND crapmcr WHERE crapmcr.cdcooper = par_cdcooper     AND    
                               crapmcr.nrdconta = par_nrdconta     AND
                               crapmcr.nrcontra = craplim.nrctrlim AND
                               crapmcr.tpctrmif = 2 /** Limite **/ AND
                               crapmcr.tpctrlim = craplim.tpctrlim
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapmcr  THEN
                DO:
                    IF  LOCKED crapmcr  THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Registro de microfilmagem " +
                                                  "esta sendo alterado. Tente" +
                                                  " novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_cdcritic = 752
                               aux_dscritic = " ".
                END.
                
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
                               
        IF  craplim.dtinivig >= 04/01/2003  THEN
            ASSIGN crapmcr.dtcancel = par_dtmvtolt.
    
        RUN atualiza-registro-associado (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nrdconta,
                                         INPUT par_dtmvtolt,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT craplim.inbaslim,
                                        OUTPUT TABLE tt-erro).
                                         
        /* operadores estavam digitando F4/END quando registro alocado */
        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
            DO:
                ASSIGN aux_cdcritic = 79
                       aux_dscritic = "".
               
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                      
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
        
        IF  RETURN-VALUE = "NOK"  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.

        RUN sistema/generico/procedures/b1wgen0043.p 
                                        PERSISTENT SET h-b1wgen0043.

        IF  NOT VALID-HANDLE(h-b1wgen0043)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO b1wgen0043.".

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

        /* Desativar rating desta operacao (se existir) */
        /* E efetivar um novo dependendo a situacao do cooperado */
        RUN desativa_rating IN h-b1wgen0043 
                            (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_cdoperad,
                             INPUT par_dtmvtolt,
                             INPUT crapdat.dtmvtopr,
                             INPUT par_nrdconta,
                             INPUT 1, /*Limite credito*/
                             INPUT craplim.nrctrlim,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_idorigem,
                             INPUT par_nmdatela,
                             INPUT crapdat.inproces,
                             INPUT par_flgerlog,
                             OUTPUT TABLE tt-erro).

        DELETE PROCEDURE h-b1wgen0043.

        IF  RETURN-VALUE <> "OK"  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.
        
        ASSIGN aux_flgtrans = TRUE.
        
    END. /** Fim do DO TRANSACTION - TRANSACAO **/
    
    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Erro na transacao. Nao foi " + 
                                          "possivel cancelar limite atual.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.
                   
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
        DO:
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

            /** Situacao do Limite **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "insitlim",
                                     INPUT "2",
                                     INPUT "3").
            
            /** Numero de Contrato do Limite **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrctrlim",
                                     INPUT TRIM(STRING(old_nrctrlim,
                                                       "zzz,zzz,zz9")),
                                     INPUT "0").
                                                    
            /** Valor do Limite **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "vllimite",
                                     INPUT TRIM(STRING(old_vllimite,
                                                       "zzz,zzz,zz9,99")),
                                     INPUT "0").
            /*                  
            /** Tipo da Conta **/
            IF  old_cdtipcta <> aux_cdtipcta  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "cdtipcta",
                                         INPUT TRIM(STRING(old_cdtipcta,
                                                           "z9")),
                                         INPUT TRIM(STRING(aux_cdtipcta,
                                                           "z9"))).
            */
            /** Data Alteracao do Limite **/
            IF  old_dtultlcr <> par_dtmvtolt  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dtultlcr",
                                         INPUT STRING(old_dtultlcr,
                                                      "99/99/9999"),
                                         INPUT STRING(par_dtmvtolt,
                                                      "99/99/9999")).
        END.                                                      
                                                      
    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**           Procedure para validar proposta de limite de credito           **/
/******************************************************************************/
PROCEDURE validar-novo-limite:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inconfir AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vllimite AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgimpnp AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cddlinha AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_inconfi2 AS INTE                           NO-UNDO.
        
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-grupo.
    
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0138 AS HANDLE                                  NO-UNDO. 
    DEF VAR h-b1wgen0110 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_flgerros AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.
    
    DEF VAR aux_vlmaxleg AS DECI                                    NO-UNDO.
    DEF VAR aux_vlmaxutl AS DECI                                    NO-UNDO.
    DEF VAR aux_vlutiliz AS DECI                                    NO-UNDO.
    DEF VAR aux_vlcalcul AS DECI                                    NO-UNDO.
    DEF VAR aux_vllimite AS DECI                                    NO-UNDO.
    
    DEF VAR aux_dsmensag AS CHAR                                    NO-UNDO.

    DEF VAR aux_dsdrisco AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdgrupo AS INTE                                    NO-UNDO.
    DEF VAR aux_gergrupo AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdrisgp AS CHAR                                    NO-UNDO.
    DEF VAR aux_pertengp AS LOGI                                    NO-UNDO.
    DEF VAR aux_dsoperac AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-grupo.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validar novo limite de credito".

    /* Buscar dados do cooperado */
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF NOT AVAIL(crapass)  THEN
       DO:
           ASSIGN aux_cdcritic = 9
                  aux_dscritic = "".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           IF par_flgerlog  THEN
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
    
    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p
           PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    ASSIGN aux_dsoperac = "Tentativa de alterar/incluir limite de credito "   +
                          "na conta " + STRING(crapass.nrdconta,"zzzz,zzz,9") +
                          " - CPF/CNPJ "                                      +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),
                                     "xx.xxx.xxx/xxxx-xx")).


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
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT 8, /*cdoperac*/
                                      INPUT aux_dsoperac,
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

          IF par_flgerlog  THEN
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


    RUN obtem-registro-limite (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtmvtolt,
                               INPUT FALSE,
                              OUTPUT TABLE tt-erro).
                               
    IF  RETURN-VALUE = "NOK"  THEN
        DO:   
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
                
    ASSIGN aux_inpessoa = IF  crapass.inpessoa = 1  THEN
                              1
                          ELSE
                              2
           aux_vllimite = IF  AVAILABLE craplim  THEN
                              craplim.vllimite
                          ELSE
                              0.
    
    /* Validacao de linha nao cadastrada */
    FIND craplrt WHERE craplrt.cdcooper = par_cdcooper   AND
                       craplrt.cddlinha = par_cddlinha   
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craplrt  THEN
        DO:
            ASSIGN aux_cdcritic = 363
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

    /* Validacao de linha ativa / liberada */
    IF   craplrt.flgstlcr = NO  THEN
         DO:
            ASSIGN aux_cdcritic = 470
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

    /* Validacao de tipo de linha de acordo com o tipo de pessoa da conta */
    IF   craplrt.tpdlinha <> aux_inpessoa  THEN
         DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Tipo de linha selecionado nao corresponde " +
                                  "ao tipo de pessoa da conta.".

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
           
    IF NOT VALID-HANDLE(h-b1wgen0138) THEN
       RUN sistema/generico/procedures/b1wgen0138.p
           PERSISTENT SET h-b1wgen0138.
    
    ASSIGN aux_pertengp =  DYNAMIC-FUNCTION("busca_grupo" IN h-b1wgen0138,
                                                       INPUT par_cdcooper, 
                                                       INPUT par_nrdconta, 
                                                      OUTPUT aux_nrdgrupo,
                                                      OUTPUT aux_gergrupo, 
                                                      OUTPUT aux_dsdrisgp).

    IF par_inconfi2 = 30  AND aux_gergrupo <> "" THEN
        DO:
           IF VALID-HANDLE(h-b1wgen0138) THEN
              DELETE OBJECT h-b1wgen0138.
        
           CREATE tt-msg-confirma.

           ASSIGN tt-msg-confirma.inconfir = par_inconfi2 + 1
                  tt-msg-confirma.dsmensag = aux_gergrupo + "Confirma?".

           RETURN "OK".
                  
        END.

    IF aux_pertengp THEN
       DO: 
          /* Procedure responsavel para calcular o endividamento do grupo */
           RUN calc_endivid_grupo IN h-b1wgen0138
                                    (INPUT par_cdcooper,
                                     INPUT par_cdagenci, 
                                     INPUT par_nrdcaixa, 
                                     INPUT par_cdoperad, 
                                     INPUT par_dtmvtolt, 
                                     INPUT par_nmdatela, 
                                     INPUT par_idorigem, 
                                     INPUT aux_nrdgrupo, 
                                     INPUT TRUE, /*Consulta por conta*/
                                    OUTPUT aux_dsdrisco, 
                                    OUTPUT aux_vlutiliz,
                                    OUTPUT TABLE tt-grupo, 
                                    OUTPUT TABLE tt-erro).

           IF VALID-HANDLE(h-b1wgen0138) THEN
              DELETE OBJECT h-b1wgen0138.
           
           IF RETURN-VALUE <> "OK"   THEN
              RETURN "NOK". 
    

       END. 
    ELSE    /*nao e do grupo*/
       DO:
           IF VALID-HANDLE(h-b1wgen0138) THEN
              DELETE OBJECT h-b1wgen0138.

           IF NOT VALID-HANDLE(h-b1wgen9999) THEN
              RUN sistema/generico/procedures/b1wgen9999.p 
                  PERSISTENT SET h-b1wgen9999.
               
           IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
               DO:
                   ASSIGN aux_cdcritic = 0
                          aux_dscritic = "Handle invalido para BO b1wgen9999.".
                          
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
               
           RUN saldo_utiliza IN h-b1wgen9999 (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT par_nmdatela,
                                              INPUT par_idorigem,
                                              INPUT par_nrdconta,
                                              INPUT par_idseqttl,
                                              INPUT par_dtmvtolt,
                                              INPUT par_dtmvtopr,
                                              INPUT "",
                                              INPUT par_inproces,
                                              INPUT FALSE, /*Consulta por cpf*/
                                             OUTPUT aux_vlutiliz,
                                             OUTPUT TABLE tt-erro).
                                             
           IF VALID-HANDLE(h-b1wgen9999) THEN
              DELETE OBJECT h-b1wgen9999.

           IF  RETURN-VALUE = "NOK"  THEN
               DO:
                   FIND FIRST tt-erro NO-LOCK NO-ERROR.
                           
                   IF  AVAILABLE tt-erro  THEN
                       ASSIGN aux_cdcritic = tt-erro.cdcritic
                              aux_dscritic = tt-erro.dscritic.
          
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

    ASSIGN aux_vlmaxleg = 0
           aux_vlmaxutl = 0.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR. 

    IF  AVAILABLE crapcop  THEN
        ASSIGN aux_vlmaxleg = crapcop.vlmaxleg
               aux_vlmaxutl = crapcop.vlmaxutl.
                       
    IF  par_inconfir = 1  THEN
        DO:
            ASSIGN aux_flgerros = TRUE.

            DO WHILE TRUE:
    
                IF  par_vllimite <= 0  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Valor do limite deve ser maior" +
                                              " que zero.".
                        LEAVE.
                    END.
        
                IF  CAN-FIND(craplim WHERE craplim.cdcooper = par_cdcooper  AND
                                           craplim.nrdconta = par_nrdconta  AND
                                           craplim.tpctrlim = 1             AND
                                           craplim.nrctrlim = par_nrctrlim 
                                           USE-INDEX craplim1)              THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Numero de contrato ja " +
                                              "existe.".
                        LEAVE.
                    END.

                IF  par_nrctrlim = 0  THEN
                    DO:
                        ASSIGN aux_cdcritic = 361
                               aux_dscritic = "".
                        LEAVE.
                    END.

                IF  par_vllimite > craplrt.vllimmax  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Valor acima do permitido. " +
                                              "Maximo de " + 
                                              TRIM(STRING(craplrt.vllimmax,
                                                          "zzz,zzz,zz9.99")).
                        LEAVE.
                    END.
                    
                IF  NOT par_flgimpnp  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Indicador de impressao de " +
                                              "nota promissoria invalido.".
                        LEAVE.                      
                    END.

                ASSIGN aux_flgerros = FALSE.

                LEAVE.
    
            END. /** Fim do DO WHILE TRUE **/

            IF  aux_flgerros  THEN
                DO:
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

            ASSIGN par_inconfir = par_inconfir + 1.

        END.                

    ASSIGN aux_vlcalcul = aux_vlutiliz + par_vllimite - crapass.vllimcre.
            
    IF par_inconfir = 2  THEN
       DO:
          IF aux_vlmaxutl > 0  THEN
             DO: 
                IF aux_vlcalcul > aux_vlmaxleg  THEN
                   DO: 
                      ASSIGN aux_dsmensag = "Vlr(Legal) Excedido(Utiliz. "
                                            + TRIM(STRING(aux_vlutiliz,
                                                        "zzz,zzz,zz9.99")) +
                                            " Excedido " +
                                            TRIM(STRING((aux_vlcalcul - 
                                            aux_vlmaxleg),"zzz,zzz,zz9.99")) + 
                                            ") ". 
                             
                      CREATE tt-msg-confirma.

                      ASSIGN tt-msg-confirma.inconfir = par_inconfir + 1.
                             tt-msg-confirma.dsmensag = aux_dsmensag.


                      ASSIGN aux_cdcritic = 79
                             aux_dscritic = "". 
                
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1,            /** Sequencia **/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).
                                       
                      IF par_flgerlog  THEN
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
                
                IF aux_vlcalcul > aux_vlmaxutl  THEN
                   DO:
                       ASSIGN aux_dsmensag = "Vlr(Utl) Excedido(Utiliz. " +
                              TRIM(STRING(aux_vlutiliz,"zzz,zzz,zz9.99")) +
                              " Excedido " +
                              TRIM(STRING((aux_vlcalcul - aux_vlmaxutl),
                                          "zzz,zzz,zz9.99")) +
                              "). Confirma?".
                              
                       CREATE tt-msg-confirma.

                       ASSIGN tt-msg-confirma.inconfir = par_inconfir
                              tt-msg-confirma.dsmensag = aux_dsmensag.

                       RETURN "OK".

                   END.

             END.

          ASSIGN par_inconfir = par_inconfir + 1.

       END.

    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**        Procedure para carregar dados do avalista para novo limite        **/
/******************************************************************************/
PROCEDURE obtem-dados-avalista:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaava AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
       
    DEF OUTPUT PARAM TABLE FOR tt-dados-avais.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    
    EMPTY TEMP-TABLE tt-dados-avais.
    EMPTY TEMP-TABLE tt-erro.
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                     
            RETURN "NOK".
        END.
           
    RUN consulta-avalista IN h-b1wgen9999 (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_idorigem,
                                           INPUT par_nrdconta,
                                           INPUT par_dtmvtolt,
                                           INPUT par_nrctaava,
                                           INPUT par_nrcpfcgc,
                                          OUTPUT TABLE tt-dados-avais,
                                          OUTPUT TABLE tt-erro).
                
    DELETE PROCEDURE h-b1wgen9999.
                                           
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
        
    RETURN "OK".
        
END PROCEDURE.


/******************************************************************************/
/**       Procedure para validar dados dos avalistas para novo limite        **/
/******************************************************************************/
PROCEDURE valida-dados-avalistas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    /** ------------------- Parametros do 1 avalista ------------------- **/
    DEF  INPUT PARAM par_nrctaav1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdaval1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepen1 AS INTE                           NO-UNDO.
    /** ------------------- Parametros do 2 avalista ------------------- **/
    DEF  INPUT PARAM par_nrctaav2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdaval2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepen2 AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR par_nmdcampo AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                     
            RETURN "NOK".
        END.

    RUN valida-avalistas IN h-b1wgen9999 (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_nrdconta,
                                          /** 1o avalista **/
                                          INPUT par_nrctaav1,
                                          INPUT par_nmdaval1,
                                          INPUT par_nrcpfav1,
                                          INPUT par_cpfcjav1,
                                          INPUT par_ende1av1,
                                          INPUT par_nrcepen1,
                                          /** 2 avalista **/
                                          INPUT par_nrctaav2,
                                          INPUT par_nmdaval2,
                                          INPUT par_nrcpfav2,
                                          INPUT par_cpfcjav2,
                                          INPUT par_ende1av2,
                                          INPUT par_nrcepen2,
                                         OUTPUT par_nmdcampo,
                                         OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen9999.
                                           
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
        
    RETURN "OK".
        
END PROCEDURE.
 
 
/******************************************************************************/
/**          Procedure para cadastrar proposta de limite de credito          **/
/******************************************************************************/
PROCEDURE cadastrar-novo-limite:

    /*** Parametros Gerais ***/
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inconfir AS INTE                           NO-UNDO.
    /*** Dados do Novo Limite */
    DEF  INPUT PARAM par_vllimite AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgimpnp AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cddlinha AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlsalari AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlsalcon AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vloutras AS DECI                           NO-UNDO.
    /* Campos Rating */
    DEF  INPUT PARAM par_nrgarope AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinfcad AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrliquid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrpatlvr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrperger AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vltotsfn AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_perfatcl AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlalugue AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsobserv AS CHAR                           NO-UNDO.
    /** ------------------- Parametros do 1 avalista ------------------- **/
    DEF  INPUT PARAM par_nrctaav1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdaval1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdocav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdcjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tdccjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_doccjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende2av1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrfonav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_emailav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufava1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepav1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrender1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complen1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaps1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlrenme1 AS DECI                           NO-UNDO.
    /* PRJ 438 Sprint 7 */
    DEF  INPUT PARAM par_vlrecjg1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacio1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpesso1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasct1 AS DATE                           NO-UNDO.    
    
    /** ------------------- Parametros do 2 avalista ------------------- **/
    DEF  INPUT PARAM par_nrctaav2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdaval2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdocav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdcjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tdccjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_doccjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende2av2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrfonav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_emailav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufava2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepav2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrender2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complen2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaps2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlrenme2 AS DECI                           NO-UNDO.
    /* PRJ 438 Sprint 7 */
    DEF  INPUT PARAM par_vlrecjg2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacio2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpesso2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasct2 AS DATE                           NO-UNDO.
    
    DEF  INPUT PARAM par_inconcje AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_dtconbir AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idcobope AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    
    DEF VAR h-b1wgen0021 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0043 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0191 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.  
    DEF VAR aux_vlsldcap AS DECI                                    NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_flmudfai AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgrestrito AS INTE                                 NO-UNDO.
    DEF VAR aux_dsfrase  AS CHAR                                    NO-UNDO. /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
    
    DEF VAR aux_mensagens    AS CHAR                                NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           /* Caso seja efetuada alguma alteracao na descricao deste log,
              devera ser tratado o relatorio de "demonstrativo produtos por
              colaborador" da tela CONGPR. (Fabricio - 04/05/2012) */
           aux_dstransa = "Cadastrar novo limite de credito".

    RUN obtem-registro-limite (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtmvtolt,
                               INPUT FALSE,
                              OUTPUT TABLE tt-erro).
                               
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
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
        
    ASSIGN aux_inpessoa = IF  crapass.inpessoa = 1  THEN
                              1
                          ELSE
                              2.

    FIND craplrt WHERE craplrt.cdcooper = par_cdcooper   AND
                       craplrt.cddlinha = par_cddlinha   NO-LOCK NO-ERROR.

    RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT
        SET h-b1wgen0021.
        
    IF  NOT VALID-HANDLE(h-b1wgen0021)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0021.".
                   
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

    RUN obtem-saldo-cotas IN h-b1wgen0021 (INPUT par_cdcooper,  
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT par_nrdconta,
                                           INPUT par_idseqttl,
                                          OUTPUT TABLE tt-saldo-cotas,
                                          OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0021.
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_cdcritic = tt-erro.cdcritic
                       aux_dscritic = tt-erro.dscritic.
                   
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

    FIND FIRST tt-saldo-cotas NO-LOCK NO-ERROR.
    
    ASSIGN aux_flgtrans = FALSE
           aux_vlsldcap = tt-saldo-cotas.vlsldcap.

    TRANSACAO:
    DO  TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:     
                                       
        IF   crapass.inpessoa > 1   THEN
             DO:

                /*Se tem cnae verificar se e um cnae restrito*/
                IF  crapass.cdclcnae > 0 THEN
                    DO:

                      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                      /* Busca a se o CNAE eh restrito */
                      RUN STORED-PROCEDURE pc_valida_cnae_restrito
                      aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.cdclcnae
                                                          ,0).

                      CLOSE STORED-PROC pc_valida_cnae_restrito
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                      ASSIGN aux_flgrestrito = INTE(pc_valida_cnae_restrito.pr_flgrestrito)
                                               WHEN pc_valida_cnae_restrito.pr_flgrestrito <> ?.

                      IF  aux_flgrestrito = 1 THEN
                          DO:
                             CREATE tt-msg-confirma.
                             ASSIGN aux_contador = aux_contador + 1				  
                                    tt-msg-confirma.inconfir = aux_contador
                                    tt-msg-confirma.dsmensag = "CNAE restrito, conforme previsto na Política de Responsabilidade Socioambiental do Sistema AILOS. Necessário apresentar Licença Regulatória.".
                          END.

                    END.

                 DO aux_contador = 1 TO 10:

                    FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper   AND
                                       crapjfn.nrdconta = par_nrdconta  
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF   NOT AVAILABLE crapjfn   THEN
                         DO:
                             IF   LOCKED crapjfn  THEN
                                  DO:
                                      aux_cdcritic = 77.
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT.
                                  END.
                             
                              CREATE crapjfn.
                              ASSIGN crapjfn.cdcooper = par_cdcooper
                                     crapjfn.nrdconta = par_nrdconta.

                         END.

                    ASSIGN crapjfn.perfatcl = par_perfatcl
                           aux_cdcritic     = 0.

                    VALIDATE crapjfn.

                    LEAVE.

                 END.  /* Fim DO .. TO */

                 IF   aux_cdcritic <>  0   THEN
                      DO:
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1,            /** Sequencia **/
                                         INPUT aux_cdcritic,
                                         INPUT-OUTPUT aux_dscritic).
     
                          UNDO TRANSACAO, LEAVE TRANSACAO.
                      END.
             END.
         
        /* cria registros na crapdoc de 19 - Contratos de limite de credito */
        ContadorDoc: DO aux_contador = 1 TO 10:
            
            FIND FIRST crapdoc WHERE 
                       crapdoc.cdcooper = par_cdcooper AND
                       crapdoc.nrdconta = par_nrdconta AND
                       crapdoc.nrcpfcgc = crapass.nrcpfcgc AND
                       crapdoc.tpdocmto = 19           AND
                       crapdoc.dtmvtolt = par_dtmvtolt AND
                       crapdoc.idseqttl = par_idseqttl 
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
            IF  NOT AVAILABLE crapdoc THEN
                DO:
                    IF  LOCKED(crapdoc) THEN
                        DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                    ASSIGN aux_cdcritic = 341.
                                    LEAVE ContadorDoc.
                                END.
                            ELSE 
                                DO: 
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT ContadorDoc.
                                END.
                        END.
                    ELSE
                        DO:
                            CREATE crapdoc.
                            ASSIGN crapdoc.cdcooper = par_cdcooper
                                   crapdoc.nrdconta = par_nrdconta
                                   crapdoc.flgdigit = FALSE
                                   crapdoc.dtmvtolt = par_dtmvtolt
                                   crapdoc.tpdocmto = 19
                                   crapdoc.nrcpfcgc = crapass.nrcpfcgc
                                   crapdoc.idseqttl = par_idseqttl.
                            VALIDATE crapdoc.    
                            
                            LEAVE ContadorDoc.
                        END.
                END.
            ELSE
                DO:
                    ASSIGN crapdoc.flgdigit = FALSE
                           crapdoc.dtmvtolt = par_dtmvtolt.
    
                    LEAVE ContadorDoc.
                END.
        END. /* Fim do DO ContadorDoc */

        CREATE craplim.
        ASSIGN craplim.nrdconta    = par_nrdconta
               craplim.tpctrlim    = 1  
               craplim.cddlinha    = craplrt.cddlinha
               craplim.nrctrlim    = par_nrctrlim
               craplim.dtpropos    = par_dtmvtolt
               craplim.insitlim    = 1
               craplim.qtdiavig    = craplrt.qtdiavig
               craplim.cdoperad    = par_cdoperad
               craplim.dsencfin[1] = craplrt.dsencfin[1]
               craplim.dsencfin[2] = craplrt.dsencfin[2]
               craplim.dsencfin[3] = craplrt.dsencfin[3]
               craplim.cdmotcan    = 0
               craplim.vllimite    = par_vllimite
               craplim.inbaslim    = IF  par_vllimite > aux_vlsldcap  THEN
                                         2 
                                     ELSE  
                                         1
               craplim.flgimpnp    = par_flgimpnp
               craplim.nrgarope    = par_nrgarope
               craplim.nrinfcad    = par_nrinfcad 
               craplim.nrliquid    = par_nrliquid
               craplim.nrperger    = par_nrperger
               craplim.nrpatlvr    = par_nrpatlvr
               craplim.vltotsfn    = par_vltotsfn
               craplim.nrctaav1    = par_nrctaav1
               craplim.nrctaav2    = par_nrctaav2
               craplim.dsendav1[1] = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE 
                                         CAPS(par_ende1av1) + " " +
                                         STRING(par_nrender1)
               craplim.dsendav1[2] = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende2av1) + " - " + 
                                         CAPS(par_nmcidav1) + " - " +
                                         STRING(par_nrcepav1,"99999,999") +
                                         " - " + CAPS(par_cdufava1)
               craplim.dsendav2[1] = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende1av2) + " " +
                                         STRING(par_nrender2)
               craplim.dsendav2[2] = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende2av2) + " - " + 
                                         CAPS(par_nmcidav2) + " - " +
                                         STRING(par_nrcepav2,"99999,999") + 
                                         " - " + CAPS(par_cdufava2)
               craplim.nmdaval1    = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         par_nmdaval1
               craplim.nmdaval2    = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE    
                                         par_nmdaval2
               craplim.dscpfav1    = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         par_dsdocav1
               craplim.dscpfav2    = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         par_dsdocav2
               craplim.nmcjgav1    = par_nmdcjav1
               craplim.nmcjgav2    = par_nmdcjav2
               craplim.dscfcav1    = par_doccjav1
               craplim.dscfcav2    = par_doccjav2
               craplim.cdcooper    = par_cdcooper
               craplim.inconcje    = par_inconcje
               craplim.dtconbir    = par_dtconbir.
                                 
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                                         
        /* Faz a vinculaçao da garantia com a proposta */
        RUN STORED-PROCEDURE pc_vincula_cobertura_operacao
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT 0
                                            ,INPUT par_idcobope
                                            ,INPUT craplim.nrctrlim
                                            ,"").

        CLOSE STORED-PROC pc_vincula_cobertura_operacao
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic = pc_vincula_cobertura_operacao.pr_dscritic
                             WHEN pc_vincula_cobertura_operacao.pr_dscritic <> ?.

        IF  aux_dscritic <> "" THEN
            DO:
               
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                      
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
           
        ASSIGN craplim.idcobope = par_idcobope
               craplim.idcobefe = par_idcobope.
                                         
        RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT 
            SET h-b1wgen9999.              
              
        IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO b1wgen9999.".
                   
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
        
        RUN cria-tabelas-avalistas IN h-b1wgen9999 (INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT par_idorigem,
                                                    INPUT "LIMITE CRED.",
                                                    INPUT par_nrdconta,
                                                    INPUT par_dtmvtolt,
                                                    INPUT 3, /* Tipo Contrato */
                                                    INPUT par_nrctrlim,
                                                    INPUT par_cdagenci,
                                                    INPUT par_nrdcaixa,
                                                    /** 1o avalista **/
                                                    INPUT par_nrctaav1,
                                                    INPUT par_nmdaval1,
                                                    INPUT par_nrcpfav1,
                                                    INPUT par_tpdocav1,
                                                    INPUT par_dsdocav1,
                                                    INPUT par_nmdcjav1,
                                                    INPUT par_cpfcjav1, 
                                                    INPUT par_tdccjav1,
                                                    INPUT par_doccjav1,
                                                    INPUT par_ende1av1,
                                                    INPUT par_ende2av1,
                                                    INPUT par_nrfonav1,
                                                    INPUT par_emailav1,
                                                    INPUT par_nmcidav1,
                                                    INPUT par_cdufava1,
                                                    INPUT par_nrcepav1,
                                                    INPUT par_cdnacio1,
                                                    INPUT 0,
                                                    INPUT par_vlrenme1,
                                                    INPUT par_nrender1,
                                                    INPUT par_complen1,
                                                    INPUT par_nrcxaps1,
                                                    INPUT par_inpesso1,  /* inpessoa 1o avail */
                                                    INPUT par_dtnasct1,  /* dtnascto 1o avail */
                                                    INPUT par_vlrecjg1, /* par_vlrecjg1 */
                                                    /** 2o avalista **/
                                                    INPUT par_nrctaav2,
                                                    INPUT par_nmdaval2, 
                                                    INPUT par_nrcpfav2,
                                                    INPUT par_tpdocav2,
                                                    INPUT par_dsdocav2, 
                                                    INPUT par_nmdcjav2, 
                                                    INPUT par_cpfcjav2,
                                                    INPUT par_tdccjav2,
                                                    INPUT par_doccjav2,
                                                    INPUT par_ende1av2,
                                                    INPUT par_ende2av2,
                                                    INPUT par_nrfonav2,
                                                    INPUT par_emailav2, 
                                                    INPUT par_nmcidav2, 
                                                    INPUT par_cdufava2, 
                                                    INPUT par_nrcepav2,
                                                    INPUT par_cdnacio2,
                                                    INPUT 0,
                                                    INPUT par_vlrenme2,
                                                    INPUT par_nrender2,
                                                    INPUT par_complen2,
                                                    INPUT par_nrcxaps2,
                                                    INPUT par_inpesso2,  /* inpessoa 1o avail */
                                                    INPUT par_dtnasct2,  /* dtnascto 1o avail */
                                                    INPUT par_vlrecjg2, /* par_vlrecjg2 */
                                                    INPUT "",
                                                   OUTPUT TABLE tt-erro).
        
        DELETE PROCEDURE h-b1wgen9999.
        
        IF RETURN-VALUE = "NOK" THEN
        DO:
            ASSIGN aux_flgtrans = FALSE.
            UNDO TRANSACAO, LEAVE TRANSACAO.
        END.

        IF  par_nrctaav1 = 0 AND par_nmdaval1 <> ""  THEN
            DO:
                ASSIGN craplim.dscfcav1 = " "
                       craplim.dscpfav1 = TRIM(CAPS(par_tpdocav1)) + " " +
                                          TRIM(CAPS(par_dsdocav1)) + 
                                          " C.P.F. " + STRING(par_nrcpfav1).
                
                IF  par_cpfcjav1 > 0  THEN
                    DO:    
                        ASSIGN craplim.dscfcav1 = TRIM(CAPS(par_tdccjav1)) + 
                                                  " " +
                                                  TRIM(CAPS(par_doccjav1)) + 
                                                  " C.P.F. " +
                                                  STRING(par_cpfcjav1).
                    END.
            END.        

        IF  par_nrctaav2 = 0 AND par_nmdaval2 <> ""  THEN
            DO:
                ASSIGN craplim.dscfcav2 = " "
                       craplim.dscpfav2 = TRIM(CAPS(par_tpdocav2)) + " " +
                                          TRIM(CAPS(par_dsdocav2)) + 
                                          " C.P.F. " + STRING(par_nrcpfav2).
         
                IF  par_cpfcjav2 > 0  THEN
                    DO:    
                        ASSIGN craplim.dscfcav2 = TRIM(CAPS(par_tdccjav2)) + 
                                                  " " +
                                                  TRIM(CAPS(par_doccjav2)) + 
                                                  " C.P.F. " +
                                                  STRING(par_cpfcjav2).
                    END.
            END.    

        VALIDATE craplim.

        CREATE crapprp.
        ASSIGN crapprp.nrdconta    = par_nrdconta
               crapprp.nrctrato    = craplim.nrctrlim
               crapprp.tpctrato    = 1
               crapprp.vlalugue    = par_vlalugue
               crapprp.vloutras    = par_vloutras
               crapprp.vlsalari    = par_vlsalari
               crapprp.vlsalcon    = par_vlsalcon
               crapprp.dsobserv[1] = par_dsobserv
               crapprp.cdcooper    = par_cdcooper
               crapprp.dtmvtolt    = par_dtmvtolt.

        VALIDATE crapprp.

        /* Gravar as informacoes ds SCR para o titular, conjuge e avais */
        RUN sistema/generico/procedures/b1wgen0024.p 
            PERSISTENT SET h-b1wgen0024.

        RUN grava-proposta-scr IN h-b1wgen0024 (INPUT par_cdcooper,
                                                INPUT par_cdagenci,
                                                INPUT par_nrdcaixa,
                                                INPUT par_cdoperad,
                                                INPUT par_nmdatela,
                                                INPUT par_idorigem,
                                                INPUT par_dtmvtolt,
                                                INPUT par_nrdconta,
                                                INPUT 1, /* tpctrato */
                                                INPUT par_nrctrlim,
                                               OUTPUT TABLE tt-erro).


        DELETE PROCEDURE h-b1wgen0024.

        IF   RETURN-VALUE <> "OK"   THEN
             LEAVE.

        IF par_idorigem = 5 THEN
           DO:
              /* Verificar se a conta pertence ao grupo economico novo */	
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

              RUN STORED-PROCEDURE pc_obtem_mensagem_grp_econ_prg
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                    ,INPUT par_nrdconta
                                                    ,""
                                                    ,0
                                                    ,"").

              CLOSE STORED-PROC pc_obtem_mensagem_grp_econ_prg
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

              ASSIGN aux_cdcritic  = 0
                     aux_dscritic  = ""
                     aux_cdcritic  = INT(pc_obtem_mensagem_grp_econ_prg.pr_cdcritic) WHEN pc_obtem_mensagem_grp_econ_prg.pr_cdcritic <> ?
                     aux_dscritic  = pc_obtem_mensagem_grp_econ_prg.pr_dscritic WHEN pc_obtem_mensagem_grp_econ_prg.pr_dscritic <> ?
                     aux_mensagens = pc_obtem_mensagem_grp_econ_prg.pr_mensagens WHEN pc_obtem_mensagem_grp_econ_prg.pr_mensagens <> ?.
                              
              IF aux_cdcritic > 0 THEN
                 DO:
                     RUN gera_erro (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT 1,            /** Sequencia **/
                                    INPUT aux_cdcritic,
                                    INPUT-OUTPUT aux_dscritic).
                               
                     UNDO TRANSACAO, LEAVE TRANSACAO.
                 END.
              ELSE IF aux_dscritic <> ? AND aux_dscritic <> "" THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                    
                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
                            
              IF aux_mensagens <> ? AND aux_mensagens <> "" THEN
                 DO:
                     CREATE tt-msg-confirma.                        
                     ASSIGN tt-msg-confirma.inconfir = 4
                            tt-msg-confirma.dsmensag = aux_mensagens.
                 END.
           END.

        ASSIGN aux_flgtrans = TRUE.
        
    END. /** Fim do DO TRANSACTION - TRANSACAO **/

    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Erro na transacao. Nao foi " + 
                                          "possivel cadastrar novo limite.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.
                   
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

    IF   par_idorigem =  5   THEN
         DO.   
             /* Chamar apos o fechamento da transacao pois depende de valores   */
             /* anteriores no Oracle. Os erros aqui dentro sao retornados na    */
             /* tt-msg-confirma pois nao podem comprometer o resto da execucao  */
             RUN sistema/generico/procedures/b1wgen0191.p  
                 PERSISTENT SET h-b1wgen0191.
                               
             RUN Verifica_Consulta_Biro IN h-b1wgen0191
                                                  (INPUT par_cdcooper,
                                                   INPUT par_nrdconta,
                                                   INPUT 3, /* inprodut*/
                                                   INPUT par_nrctrlim,
                                                   INPUT par_cdoperad,
                                                   INPUT "I",
                                            INPUT-OUTPUT TABLE tt-msg-confirma,
                                                  OUTPUT aux_flmudfai).          
             DELETE PROCEDURE h-b1wgen0191.
          
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
        
        /** Numero de Contrato do Limite **/
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Contrato", /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
                                 INPUT "",
                                 INPUT TRIM(STRING(craplim.nrctrlim, "zzz,zzz,zz9"))).
         
        /** Valor do Limite **/
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Vl.Limite de Crédito", /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
                                 INPUT "",
                                 INPUT TRIM(STRING(craplim.vllimite, "zzz,zzz,zz9.99"))).
        
        /** Data Alteracao do Limite **/
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Data de Conatrataçao",  /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
                                 INPUT "",
                                 INPUT STRING(par_dtmvtolt, "99/99/9999")).
        
        /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
        /** Prazo de Vigencia **/
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Prazo de Vigencia (dias)",
                                 INPUT "",
                                 INPUT STRING(craplim.qtdiavig)).
        /* Fim Pj470 - SM2 */
        
        /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
        /** Encargos Financeiros **/
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Encargos Financeiros",
                                 INPUT "",
                                 INPUT STRING(craplim.dsencfin[1])).
        /* Fim Pj470 - SM2 */
        
        /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
        /** Periodicidade da Capitalizaçao **/
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Periodic.da Capitalizaçao",
                                 INPUT "",
                                 INPUT STRING(craplim.dsencfin[3])).
        /* Fim Pj470 - SM2 */
        
        /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
        /** Custo Efetivo Total (CET) **/
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
        RUN STORED-PROCEDURE pc_busca_cet_limite
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_nrctrlim,
                                            OUTPUT "",  /* DSFRASE */
                                            OUTPUT 0,   /* Codigo da crítica */
                                            OUTPUT ""). /* Descriçao da crítica */
        CLOSE STORED-PROC pc_busca_cet_limite
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
        ASSIGN aux_dsfrase  = ""
               aux_cdcritic = 0
               aux_dscritic = ""
               aux_dsfrase  = pc_busca_cet_limite.pr_dsfrase 
                              WHEN pc_busca_cet_limite.pr_dsfrase <> ?
               aux_cdcritic = pc_busca_cet_limite.pr_cdcritic 
                              WHEN pc_busca_cet_limite.pr_cdcritic <> ?
               aux_dscritic = pc_busca_cet_limite.pr_dscritic
                              WHEN pc_busca_cet_limite.pr_dscritic <> ?.
        IF aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
           aux_dsfrase  = "Erro ao buscar o CET".
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Custo Efetivo Total (CET)",
                                 INPUT "",
                                 INPUT STRING(aux_dsfrase)).
        /* Fim Pj470 - SM2 */
        
        /** Linha de Credito do Limite **/
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "cddlinha",
                                 INPUT "",
                                 INPUT TRIM(STRING(craplim.cddlinha, "zz9"))).
                                                
        /** Valor do Limite **/
        
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "vllimite",
                                 INPUT "",
                                 INPUT TRIM(STRING(craplim.vllimite, "zzz,zzz,zz9.99"))).
        
        /** Tipo da Conta **/
        
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "cdtipcta",
                                 INPUT "",
                                 INPUT TRIM(STRING(crapass.cdtipcta, "z9"))).
                                          
        /** Tipo do Limite **/
        
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "tplimcre",
                                 INPUT "",
                                 INPUT TRIM(STRING(craplim.inbaslim, "9"))).
                     
        /** Data Alteracao do Limite **/
        
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "dtultlcr",
                                 INPUT "",
                                 INPUT STRING(par_dtmvtolt, "99/99/9999")).
        
         /** Situacao do Limite **/
         RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                  INPUT "insitlim",
                                  INPUT "",
                                  INPUT "2").

    RETURN "OK".
        
END PROCEDURE.


/******************************************************************************/
/**     Procedure para carregar dados dos avalistas do limite de credito     **/
/******************************************************************************/
PROCEDURE obtem-dados-avais:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flpropos AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.        
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-dados-avais.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    
    EMPTY TEMP-TABLE tt-dados-avais.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Carregar dados dos avalistas do limite de credito".

    RUN obtem-registro-limite (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtmvtolt,
                               INPUT par_flpropos,
                              OUTPUT TABLE tt-erro).
                               
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
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
        
    IF  NOT AVAILABLE craplim  THEN
        DO:
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
        END.
        
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
        SET h-b1wgen9999.
        
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                   
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
        
    RUN lista_avalistas IN h-b1wgen9999 (INPUT par_cdcooper,  
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nmdatela,
                                         INPUT par_idorigem,
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT 3, /** Tipo do contrato **/
                                         INPUT craplim.nrctrlim,
                                         INPUT craplim.nrctaav1,
                                         INPUT craplim.nrctaav2,
                                        OUTPUT TABLE tt-dados-avais,
                                        OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen9999.
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_cdcritic = tt-erro.cdcritic
                       aux_dscritic = tt-erro.dscritic.
                   
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


/******************************************************************************/
/**     Procedure para carregar dados para impressos do limite de credito    **/
/******************************************************************************/
PROCEDURE impressoes-limite:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-dados-prp.
    DEF OUTPUT PARAM TABLE FOR tt-dados-ctr.
    DEF OUTPUT PARAM TABLE FOR tt-repres-ctr.
    DEF OUTPUT PARAM TABLE FOR tt-avais-ctr.
    DEF OUTPUT PARAM TABLE FOR tt-dados-rescisao.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-dados-prp.
    EMPTY TEMP-TABLE tt-dados-ctr.
    EMPTY TEMP-TABLE tt-repres-ctr.
    EMPTY TEMP-TABLE tt-avais-ctr.
    EMPTY TEMP-TABLE tt-dados-rescisao.
    EMPTY TEMP-TABLE tt-erro.
            
    IF  par_flgerlog  THEN
        DO:
            ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).
    
            IF  par_idimpres = 1  THEN
                aux_dstransa = "Carregar dados para impressao da proposta e " +
                               "contrato do limite de credito".
            ELSE
            IF  par_idimpres = 2  THEN
                aux_dstransa = "Carregar dados para impressao do contrato " +
                               "do limite credito".
            ELSE
            IF  par_idimpres = 3  THEN
                aux_dstransa = "Carregar dados para impressao da proposta " +
                               "do limite de credito".
            ELSE
            IF  par_idimpres = 4  THEN
                aux_dstransa = "Carregar dados para impressao da rescisao " +
                               "do limite de credito".
            ELSE
            IF  par_idimpres = 6  THEN
                aux_dstransa = "Carregar dados para impressao dos " +
                               "contratos cet".
            ELSE
                aux_dstransa = "Carregar dados para impressoes do limite de " +
                               "credito.".
        END.
    
    IF  NOT CAN-DO("1,2,3,4,6",STRING(par_idimpres))  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Tipo de impressao invalida.".
                   
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
                       
    RUN obtem-registro-limite (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtmvtolt,
                               INPUT FALSE,
                              OUTPUT TABLE tt-erro).
                               
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
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
     
    IF  par_idimpres = 1  THEN /** Impressao COMPLETA **/
        DO:
            RUN obtem-dados-contrato (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_idorigem,
                                      INPUT par_nrdconta,
                                      INPUT par_dtmvtolt,
                                      INPUT par_nrctrlim,
                                     OUTPUT TABLE tt-dados-ctr,
                                     OUTPUT TABLE tt-repres-ctr,
                                     OUTPUT TABLE tt-avais-ctr,
                                     OUTPUT TABLE tt-erro).    
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
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
                
            RUN obtem-dados-proposta (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_idorigem,
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_dtmvtopr,
                                      INPUT par_inproces,
                                      INPUT par_nrctrlim,
                                     OUTPUT TABLE tt-dados-prp,
                                     OUTPUT TABLE tt-erro).
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
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
    ELSE
    IF  par_idimpres = 2  THEN /** Impressao CONTRATO **/
        DO:
            RUN obtem-dados-contrato (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_idorigem,
                                      INPUT par_nrdconta,
                                      INPUT par_dtmvtolt,
                                      INPUT par_nrctrlim,
                                     OUTPUT TABLE tt-dados-ctr,
                                     OUTPUT TABLE tt-repres-ctr,
                                     OUTPUT TABLE tt-avais-ctr,
                                     OUTPUT TABLE tt-erro).    
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
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
    ELSE
    IF  par_idimpres = 3  THEN /** Impressao PROPOSTA **/
        DO:
            RUN obtem-dados-proposta (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_idorigem,
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_dtmvtopr,
                                      INPUT par_inproces,
                                      INPUT par_nrctrlim,
                                     OUTPUT TABLE tt-dados-prp,
                                     OUTPUT TABLE tt-erro).
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
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
    ELSE
    IF  par_idimpres = 4  THEN /** Impressao RESCISAO **/
        DO:
            RUN obtem-dados-rescisao (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nrdconta,
                                      INPUT par_dtmvtolt,
                                      INPUT par_nrctrlim,
                                     OUTPUT TABLE tt-dados-rescisao,
                                     OUTPUT TABLE tt-erro).
             
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
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
    ELSE
    IF  par_idimpres = 6  THEN /** Impressao do CET **/
        DO:
            
            RUN obtem-dados-contrato (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_idorigem,
                                      INPUT par_nrdconta,
                                      INPUT par_dtmvtolt,
                                      INPUT par_nrctrlim,
                                     OUTPUT TABLE tt-dados-ctr,
                                     OUTPUT TABLE tt-repres-ctr,
                                     OUTPUT TABLE tt-avais-ctr,
                                     OUTPUT TABLE tt-erro).    
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
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
/**           Procedure para gerar impressoes do limite de credito           **/
/******************************************************************************/
PROCEDURE gera-impressao-limite:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE  /** PAC Operador   **/   NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE  /** Nr. Caixa      **/   NO-UNDO.
    DEF  INPUT PARAM par_cdopecxa AS CHAR  /** Operador Caixa **/   NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgimpnp AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgemail AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.
    DEF VAR aux_restoobs AS INTE                                    NO-UNDO.
    DEF VAR aux_incontad AS INTE                                    NO-UNDO.
    DEF VAR aux_dsobserv AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmdoarqv AS CHAR                                    NO-UNDO.

    DEF VAR rel_cabobser AS CHAR                                    NO-UNDO.
    DEF VAR rel_dsqtdava AS CHAR                                    NO-UNDO.
    DEF VAR rel_dsobserv AS CHAR                                    NO-UNDO.

    DEF VAR rel_nrsequen AS INTE EXTENT 2                           NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0043 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0138 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_dsdrisgp AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlendivi AS DEC  FORMAT "zzz,zzz,zz9.99"            NO-UNDO.
    DEF VAR aux_nrdgrupo AS INTE                                    NO-UNDO.
    DEF VAR aux_gergrupo AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdrisco AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscetan1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscetan2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI INIT FALSE                         NO-UNDO.

    DEF VAR vr_xml                 AS LONGCHAR                      NO-UNDO.
    DEF VAR vr_inrisrat            AS CHAR                          NO-UNDO.
    DEF VAR vr_inponrat            AS INTEGER                       NO-UNDO.
    DEF VAR vr_innivrat            AS CHAR                          NO-UNDO.
    DEF VAR vr_insegrat            AS CHAR                          NO-UNDO.
    DEF VAR vr_vlr                 AS INTEGER                       NO-UNDO.
    DEF VAR vr_qtdreg              AS INTEGER                       NO-UNDO.
    DEF VAR vr_nrctro_out          AS INTEGER                       NO-UNDO.
    DEF VAR vr_tpctrato_out        AS INTEGER                       NO-UNDO.

    DEF VAR aux_habrat             AS CHAR                          NO-UNDO.

    FIND FIRST crapprm WHERE crapprm.nmsistem = 'CRED' AND
                             crapprm.cdacesso = 'HABILITA_RATING_NOVO' AND
                             crapprm.cdcooper = par_cdcooper
                             NO-LOCK NO-ERROR.

    ASSIGN aux_habrat = 'N'.
    IF AVAIL crapprm THEN DO:
      ASSIGN aux_habrat = crapprm.dsvlrprm.
    END.

    /** FORM's para impressao da PROPOSTA **/
    FORM "\022\024\033\120"     /** Reseta impressora **/
         tt-dados-prp.nmextcop           AT 20 FORMAT "x(50)" 
         SKIP(1)
         "PROPOSTA DE LIMITE DE CREDITO" AT 27 
         SKIP(1)
         "Numero da proposta:"           AT 52 
         tt-dados-prp.nrctrlim                 FORMAT "z,zzz,zz9"
         SKIP
         WITH NO-BOX COLUMN 1 NO-LABELS FRAME f_coop.

    FORM SKIP
         "DADOS DO ASSOCIADO"
         SKIP 
         "Conta/dv:"                  
         tt-dados-prp.nrdconta FORMAT "zzzz,zzz,9"
         "Matricula:"          AT 29  
         tt-dados-prp.nrmatric FORMAT "zzz,zz9"
         "PA"                  AT 50
         tt-dados-prp.nmresage FORMAT "x(22)"
         SKIP(1)
         "Nome do(s) titular(es):"    
         tt-dados-prp.nmprimtl FORMAT "x(50)"
         SKIP
         tt-dados-prp.nmsegntl AT 25 FORMAT "x(50)" 
         SKIP
         "CPF/CNPJ:"                  
         tt-dados-prp.nrcpfcgc FORMAT "x(18)"
         "Admissao:"           AT 61  
         tt-dados-prp.dtadmiss FORMAT "99/99/9999"
         SKIP
         "Empresa:"                   
         tt-dados-prp.dsempres FORMAT "x(25)"
         SKIP(1)
         "Telefone/Ramal:"            
         tt-dados-prp.nrdofone FORMAT "X(20)"
         SKIP(1)
         "Tipo de conta:"             
         tt-dados-prp.dstipcta FORMAT "x(20)"
         "Situacao da conta:"  AT 38  
         tt-dados-prp.dssitdct FORMAT "x(22)"
         SKIP(1)
         "RECIPROCIDADE"
         SKIP 
         "Saldo medio do trimestre:"  
         tt-dados-prp.vlsmdtri FORMAT "zzzzzz,zz9.99"
         "Capital:"            AT 41  
         tt-dados-prp.vlcaptal FORMAT "zzzzzz,zz9.99"
         "Plano:"              AT 64  
         tt-dados-prp.vlprepla FORMAT "zzz,zz9.99"
         SKIP(1)
         "Aplicacoes:"                
         tt-dados-prp.vlaplica FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "RENDA MENSAL"
         SKIP 
         "Salario:"                   
         tt-dados-prp.vlsalari FORMAT "zzz,zzz,zz9.99"
         "Outras rendas:"      AT 26  
         tt-dados-prp.vloutras FORMAT "zzz,zzz,zz9.99"
         SKIP
         "Salario Conjuge:"                   
         tt-dados-prp.vlsalcon FORMAT "zzz,zzz,zz9.99"
         "Outras rendas Conjuge:"      AT 33  
         tt-dados-prp.vlrencjg FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "Limite de credito atual:"   
         tt-dados-prp.vllimcre FORMAT "zzz,zzz,zz9.99"
         "Aluguel:"            AT 61  
         tt-dados-prp.vlalugue FORMAT "zzzz,zz9.99"
         SKIP(1)
         "Limite de cartao(es) de credito:"
         tt-dados-prp.vltotccr FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "DIVIDA"
         SKIP 
         "Saldo devedor de emprestimos:" 
         tt-dados-prp.vltotemp FORMAT "zzz,zzz,zz9.99"
         "Prestacoes:" AT 49 
         tt-dados-prp.vltotpre FORMAT "zzz,zzz,zz9.99"
         SKIP
         "TOTAL OP.CREDITO:"          
         tt-dados-prp.vlutiliz FORMAT "zzz,zzz,zz9.99"
         SKIP 
         "Limite de credito proposto:" 
         tt-dados-prp.vllimite FORMAT "zzz,zzz,zz9.99"
         rel_cabobser                             FORMAT "x(12)" 
         SKIP
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_dados_fisica.
         
    FORM SKIP
         "DADOS DO ASSOCIADO"
         SKIP 
         "Conta/dv:"                  
         tt-dados-prp.nrdconta FORMAT "zzzz,zzz,9"
         "Matricula:"          AT 29  
         tt-dados-prp.nrmatric FORMAT "zzz,zz9"
         "PA"                  AT 50
         tt-dados-prp.nmresage FORMAT "x(22)"
         SKIP(1)
         "Nome do(s) titular(es):"    
         tt-dados-prp.nmprimtl FORMAT "x(50)"
         SKIP
         tt-dados-prp.nmsegntl AT 25 FORMAT "x(50)" 
         SKIP
         "CPF/CNPJ:"                  
         tt-dados-prp.nrcpfcgc FORMAT "x(18)"
         "Admissao:"           AT 61  
         tt-dados-prp.dtadmiss FORMAT "99/99/9999"
         SKIP
         "Empresa:"                   
         tt-dados-prp.dsempres FORMAT "x(25)"
         "Inicio da Atividade:"           AT 50  
         tt-dados-prp.dtiniatv FORMAT "99/99/9999"
         SKIP
         "Ramo de Atividade:"
         tt-dados-prp.dsrmativ FORMAT "x(50)"
         SKIP(1)
         "Telefone/Ramal:"            
         tt-dados-prp.nrdofone FORMAT "X(20)"
         SKIP(1)
         "Tipo de conta:"             
         tt-dados-prp.dstipcta FORMAT "x(20)"
         "Situacao da conta:"  AT 38  
         tt-dados-prp.dssitdct FORMAT "x(22)"
         SKIP(1)
         "RECIPROCIDADE"
         SKIP 
         "Saldo medio do trimestre:"  
         tt-dados-prp.vlsmdtri FORMAT "zzzzzz,zz9.99"
         "Capital:"            AT 41  
         tt-dados-prp.vlcaptal FORMAT "zzzzzz,zz9.99"
         "Plano:"              AT 64  
         tt-dados-prp.vlprepla FORMAT "zzz,zz9.99"
         SKIP(1)
         "Aplicacoes:"                
         tt-dados-prp.vlaplica FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "FATURAMENTO"
         SKIP 
         "Faturamento Medio Mensal:"                   
         tt-dados-prp.vlfatmes FORMAT "zzz,zzz,zz9.99"
         SKIP
         "Concentracao Faturamento Unico Cliente:" 
         tt-dados-prp.perfatcl FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "Limite de credito atual:"   
         tt-dados-prp.vllimcre FORMAT "zzz,zzz,zz9.99"
         "Aluguel:"            AT 61  
         tt-dados-prp.vlalugue FORMAT "zzzz,zz9.99"
         SKIP(1)
         "Limite de cartao(es) de credito:"
         tt-dados-prp.vltotccr FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "DIVIDA"
         SKIP 
         "Saldo devedor de emprestimos:" 
         tt-dados-prp.vltotemp FORMAT "zzz,zzz,zz9.99"
         "Prestacoes:" AT 49 
         tt-dados-prp.vltotpre FORMAT "zzz,zzz,zz9.99"
         SKIP
         "TOTAL OP.CREDITO:"          
         tt-dados-prp.vlutiliz FORMAT "zzz,zzz,zz9.99"
         SKIP 
         "Limite de credito proposto:" 
         tt-dados-prp.vllimite FORMAT "zzz,zzz,zz9.99"
         rel_cabobser                             FORMAT "x(12)" 
         SKIP
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_dados_juridica.
       
    FORM rel_dsobserv FORMAT "x(76)"
         WITH DOWN NO-BOX NO-LABELS WIDTH 96 FRAME f_dados_2.

    FORM "\022\033\115\033\106AUTORIZO A CONSULTA DE MINHAS INFORMACOES CADASTRAIS"
         "NOS SERVICOS DE PROTECAO AO CREDITO" SKIP 
         "(SPC, SERASA, CADIN, ...) ALEM DO CADASTRO DA CENTRAL"
         "DE RISCO DO BANCO CENTRAL DO BRASIL."       
         SKIP
         "\024\022\033\120\0332\033x0"
         SKIP
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_dados_3. 

    FORM SKIP
         "APROVACAO"
         SKIP(1) 
         "____________________________________" AT  3
         "____________________________________" AT 45
         SKIP
         tt-dados-prp.nmoperad FORMAT "x(26)" AT 03
         tt-dados-prp.nmexcop1 FORMAT "x(36)" AT 45
         tt-dados-prp.nmexcop2 FORMAT "x(36)" AT 45
         SKIP 
         "____________________________________  " AT 3
         SKIP
         tt-dados-prp.nmprimtl AT 3 FORMAT "X(50)"
         SKIP
         "                                        "
         "\022\033\115\033\106"
         tt-dados-prp.nmcidade      FORMAT "X(13)" ", " 
         tt-dados-prp.dsemsprp      FORMAT "X(23)" "."  
         "\024\022\033\120\0332\033x0"
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_final.
    
    FORM "Risco da Proposta:"                                       AT 01
        SKIP(1)
        tt-ratings-novo.dsdopera LABEL "Operacao"         FORMAT "x(14)"      AT 01
        SKIP(1)
        tt-ratings-novo.nrctrrat LABEL "Contrato"         FORMAT "zz,zzz,zz9" AT 01
        tt-ratings-novo.inponrat LABEL "   Pontuacao"     FORMAT "99999"       
        tt-ratings-novo.inrisrat LABEL "   Nota"          FORMAT "x(2)"        /*ex. A*/
        tt-ratings-novo.innivrat LABEL "   Risco"         FORMAT "x(6)"        /*ex. Risco BAIXO*/
        SKIP(1)
	tt-ratings-novo.insegrat LABEL "Segmento"         FORMAT "x(23)"      
        WITH SIDE-LABEL WIDTH 120 FRAME f_rating_atual_novo.
        
    FORM "Risco da Proposta:"                                       AT 01
         SKIP 
         tt-ratings.dsdopera LABEL "Operacao"    FORMAT "x(15)"     AT 01
         tt-ratings.nrctrrat LABEL "Contrato"    FORMAT "z,zzz,zz9" AT 26 
         tt-ratings.indrisco LABEL "Risco"       FORMAT "x(2)"      AT 46 
         tt-ratings.nrnotrat LABEL "Nota"        FORMAT "zz9.99"    AT 56 
         tt-ratings.dsdrisco NO-LABEL            FORMAT "x(20)"     AT 70 
         WITH SIDE-LABEL WIDTH 120 FRAME f_rating_atual.
    
    FORM "Historico dos Ratings" AT 01
         WITH FRAME f_historico_rating_1.   
                                                                                   
    FORM tt-ratings.dsdopera LABEL "Operacao"       FORMAT "x(18)"   AT 01
         tt-ratings.nrctrrat LABEL "Contrato"       FORMAT "z,zzz,zz9"        
         tt-ratings.indrisco LABEL "Risco"          FORMAT "x(2)"           
         tt-ratings.nrnotrat LABEL "Nota"           FORMAT "zz9.99"         
         tt-ratings.vloperac LABEL "Valor Operacao" FORMAT "zzz,zzz,zz9.99"   
         tt-ratings.dsditrat LABEL "Situacao"       FORMAT "x(15)"
         WITH DOWN WIDTH 120 FRAME f_historico_rating_2.
    
    /** FORM's para impressao do CONTRATO - Pessoa Fisica **/
    FORM "\022\024\033\120"     /** Reseta impressora **/
         SKIP(1)
         "\033\017\033\016CONTRATO DE ABERTURA DE CREDITO EM CONTA CORRENTE\024\022"
         AT 12
         SKIP(1)
         "\033\017\033\016CONTRATO N.:\024\022" AT 05
         tt-dados-ctr.nrctrlim AT 24 FORMAT "z,999,999"
         SKIP(1)
         "\033\017\033\016CONDICOES ESPECIAIS\024\022" AT 30
         SKIP(1)
         WITH NO-BOX NO-LABELS FRAME f_cooperativa.

    FORM "\033\017\033\0161.  DA IDENTIFICACAO:\024\022"
         SKIP
         "\033\017\033\0161.1 COOPERATIVA: \024\022"
         tt-dados-ctr.nmextcop AT 27 FORMAT "x(50)"
         "     inscrita no CNPJ/MF sob o no"
         tt-dados-ctr.nrdocnpj AT 35 FORMAT "x(18)"
         ", estabelecida  a" 
         SKIP
         tt-dados-ctr.dsendcop AT 06 FORMAT "x(60)"
         SKIP(1)
         "\033\017\033\0161.2 COOPERADO(A): \024\022"
         tt-dados-ctr.nmprimtl AT 25 FORMAT "x(40)" ","
         tt-dados-ctr.cdagenci       FORMAT "zz9"         LABEL "PA"
         SKIP 
         tt-dados-ctr.nrdconta AT 06 FORMAT "zzzz,zzz,9"   LABEL "C/C"  ","
         tt-dados-ctr.nrdrgass       FORMAT "x(28)"  ","
         tt-dados-ctr.nrcpfcgc       FORMAT "x(19)"       NO-LABEL
         SKIP(1)   
         "\033\017\033\0162.  DO LIMITE DE CREDITO: \024\022"
         "Valor:"                            
         tt-dados-ctr.vllimite AT 40 FORMAT "zzz,zzz,zz9.99" 
         tt-dados-ctr.dsvlnpr1 AT 55 FORMAT "x(22)" SKIP
         tt-dados-ctr.dsvlnpr2 AT  6 FORMAT "x(70)" SKIP
         SKIP(1)     
         "\033\017\033\0163.  DOS ENCARGOS FINANCEIROS: \024\022"
         tt-dados-ctr.dsencfi1 AT 37 FORMAT "x(39)"
         tt-dados-ctr.dsencfi2 AT  6 FORMAT "x(70)" 
         tt-dados-ctr.dsencfi3 AT  6 FORMAT "x(70)"
         SKIP(1)     
         "\033\017\033\0163.1 Custo Efetivo Total (CET) da operacao:" SKIP 
         "   " aux_dscetan1 FORMAT "x(72)" SKIP 
         "   " aux_dscetan2 FORMAT "x(72)" SKIP
         "    de calculo."
         SKIP(1)
         "\033\017\033\0164.  DO PRAZO DE VIGENCIA: \024\022"
         tt-dados-ctr.qtdiavig  AT 34 FORMAT "z,zz9"
         "DIAS"            AT 41 
         SKIP(1)   
         WITH COLUMN 5 NO-BOX SIDE-LABELS NO-LABELS FRAME f_contrato.
         
    FORM "\033\017\033\0165.  DA DECLARACAO DAS PARTES:\033\106" 
         SKIP(1)
         "    O(A) COOPERADO(A) declara ter ciencia dos encargos e despesas incluidos" 
         SKIP
         "    na operacao que integram o CET,  expresso  na  forma de taxa percentual"
         SKIP
         "    anual  indicada  no  item  3.1 do  presente  contrato  e  item  4.1. da" 
         SKIP
         "    planilha demonstrativa de calculo, recebida no momento da  contratacao."
         SKIP(1) 
         "    Declaram as partes,  abaixo,  assinadas,  que  as  presentes  CONDICOES" 
         SKIP
         "    ESPECIAIS, passam a  integrar-se  as  CONDICOES  GERAIS  do Contrato de" 
         SKIP
         "    Abertura  de  Credito  em   Conta-Corrente,  cujas  condicoes  aceitam,"  
         SKIP
         "    outorgam e prometem cumprir."
         SKIP(1) 
         WITH NO-BOX COLUMN 5 FRAME f_fim.
    
    /** FORM's para impressao do CONTRATO - Pessoa Juridica **/
    FORM HEADER
         "\022\024\033\120"   
         SKIP(1)
         "PAGINA" AT 72
         PAGE-NUMBER(str_limcre) FORMAT "99"
         SKIP(1)
         "\033\017\033\016CONTRATO DE ABERTURA DE CREDITO EM CONTA CORRENTE\024\022"
         AT 12 SKIP
         "\033\017\033\016LIMITE EMPRESARIAL\024\022" 
         AT 30 SKIP(1)
         "\033\017\033\016CONTRATO N.:\024\022" AT 05
         tt-dados-ctr.nrctrlim AT 24 FORMAT "z,999,999"
         SKIP(3)
         WITH PAGE-TOP NO-BOX NO-LABELS FRAME f_contrato_juridica_cab.

    FORM SKIP
         tt-repres-ctr.nmrepres FORMAT "x(40)" SKIP "CPF:"  
         tt-repres-ctr.nrcpfrep FORMAT "x(14)" ", DOC.:"
         tt-repres-ctr.dsdocrep FORMAT "x(15)" "-"
         tt-repres-ctr.cdoedrep FORMAT "x(5)"
         WITH COLUMN 10 NO-BOX SIDE-LABELS NO-LABELS FRAME f_representantes.

    FORM "\033\017\033\016CONDICOES ESPECIAIS\024\022" AT 30
         SKIP(1)
         "\033\017\033\0161.  DA IDENTIFICACAO:\024\022"
         SKIP
         "\033\017\033\0161.1 COOPERATIVA: \024\022"
         tt-dados-ctr.nmextcop AT 27 FORMAT "x(50)"
         "     inscrita no CNPJ/MF sob o no"
         tt-dados-ctr.nrdocnpj AT 35 FORMAT "x(18)" ","
         tt-dados-ctr.cdagenci       FORMAT "zz9"        LABEL "PA" ","
         SKIP
         "     estabelecida  a" 
         tt-dados-ctr.dsendcop AT 06 FORMAT "x(60)"
         SKIP(1)
         "\033\017\033\0161.2 COOPERADO: \024\022"
         tt-dados-ctr.nmprimtl AT 25 FORMAT "x(50)"
         SKIP 
         tt-dados-ctr.nrcpfcgc AT 06 FORMAT "x(18)"      ","
         tt-dados-ctr.nrdconta       FORMAT "zzzz,zzz,9"  LABEL "C/C" 
         SKIP(1)   
         "\033\017\033\0161.3 ENDERECO: \024\022"
         tt-dados-ctr.endeass1       FORMAT "x(50)"
         SKIP
         tt-dados-ctr.endeass2 AT 18 FORMAT "x(40)"
         SKIP
         tt-dados-ctr.endeass3 AT 18 FORMAT "x(45)"
         SKIP(1)
         "\033\017\033\0161.4 DADOS DO(S) REPRESENTANTE(S) LEGAL(IS): \024\022"
         WITH COLUMN 5 NO-BOX SIDE-LABELS NO-LABELS FRAME f_contrato_juridica1.
         
    FORM SKIP(1)                                          
         "\033\017\033\0162.  DO LIMITE DE CREDITO: \024\022"
         "Valor:"
         tt-dados-ctr.vllimite AT 40 FORMAT "zzz,zzz,zz9.99" 
         tt-dados-ctr.dsvlnpr1 AT 55 FORMAT "x(22)" SKIP
         tt-dados-ctr.dsvlnpr2 AT  6 FORMAT "x(70)" SKIP
         SKIP(1)     
         WITH COLUMN 5 NO-BOX SIDE-LABELS NO-LABELS FRAME f_contrato_juridica2.
         
    FORM "\033\017\033\0163.  DOS ENCARGOS FINANCEIROS: \024\022"
         tt-dados-ctr.dsencfi1  AT 37 FORMAT "x(39)"
         tt-dados-ctr.dsencfi2  AT  6 FORMAT "x(70)" 
         tt-dados-ctr.dsencfi3  AT  6 FORMAT "x(70)"
         SKIP(1)     
         "\033\017\033\0163.1 Custo Efetivo Total (CET) da operacao:" SKIP 
         "   " aux_dscetan1 FORMAT "x(72)" SKIP 
         "   " aux_dscetan2 FORMAT "x(72)" SKIP
         "    de calculo."
         SKIP(1)
         WITH COLUMN 5 NO-BOX SIDE-LABELS NO-LABELS FRAME f_contrato_juridica3.
         
    FORM "\033\017\033\0164.  DO PRAZO DE VIGENCIA: \024\022"
         tt-dados-ctr.qtdiavig  AT 34 FORMAT "z,zz9"
         "DIAS"            AT 41 
         SKIP(1)   
         WITH COLUMN 5 NO-BOX SIDE-LABELS NO-LABELS FRAME f_contrato_juridica4.
    
    FORM "\033\017\033\0165.  DAS DECLARACOES DA COOPERADA:\024\022"
         "A"
         "Cooperada,"
         "na pessoa de dos seus"
         SKIP
         "     representantes legais, declara e/ou ratifica:"
         SKIP(1)
         WITH COLUMN 5 NO-BOX SIDE-LABELS NO-LABELS FRAME f_contrato_juridica5.
         
    FORM "a) Estar ciente e de pleno acordo com as disposicoes contidas nas"
         "Condicoes Gerais do Contrato de Abertura de Credito em Conta-Corrente"
         "que integram este contrato, para os devidos fins, formando um documento"
         "unico e indivisivel, cujas condicoes aceita, outorga e promete cumprir."
         SKIP(1)
         WITH COLUMN 5 NO-BOX SIDE-LABELS NO-LABELS FRAME f_contrato_juridica6.
    
    FORM "b) Que os subscritores desta, desde ja autorizam a Cooperativa a"
         "efetuar consultas cadastrais, tanto da Cooperada como dos seus"
         "Representantes Legais e do(s) Fiador(es), junto ao SPC, Serasa, SCR"
         "(Sistemas Central de Risco do Banco Central do Brasil), dentre outros,"
         "assim como enviar os seus dados aos orgaos publicos ou privados,"
         "administradores de bancos de dados."
         SKIP(1)
         WITH COLUMN 5 NO-BOX SIDE-LABELS NO-LABELS FRAME f_contrato_juridica7.
         
    FORM "c) Que autoriza o debito das respectivas tarifas e despesas decorrentes"
         "do presente contrato na Conta Corrente supra identificada."
         SKIP(1)
         WITH COLUMN 5 NO-BOX SIDE-LABELS NO-LABELS FRAME f_contrato_juridica8.

    FORM "d) O(A) COOPERADO(A) declara ter ciencia dos encargos e despesas incluidos"
         SKIP 
         "na operacao que integram o CET,  expresso  na  forma de taxa percentual"
         SKIP     
         "anual  indicada  no  item  3.1 do  presente  contrato  e  item  4.1. da"
         SKIP 
         "planilha demonstrativa de calculo, recebida no momento da  contratacao."
         SKIP(1)
         WITH COLUMN 5 NO-BOX SIDE-LABELS NO-LABELS FRAME f_contrato_juridica9.

    /** FORM's para impressao do CONTRATO - PJ e PF **/
    FORM "\022\033\115"
         tt-dados-ctr.dsemsctr FORMAT "X(40)"
         SKIP
         WITH COLUMN 5 NO-BOX SIDE-LABELS NO-LABELS FRAME f_data_emissao.
              
    FORM "\022\033\115"
         "________________________________________" AT  1    
         SKIP
         tt-dados-ctr.nmprimtl        FORMAT "x(50)"
         SKIP
         WITH NO-BOX COLUMN 7 NO-LABELS WIDTH 137 FRAME f_assina_cooper. 
             
    FORM "\022\033\115"
         "________________________________________" AT  1
         "________________________________________" AT 46     
         SKIP
         "Fiador" 
         rel_nrsequen[1] FORMAT "9"
         "Conjuge Fiador"                AT 46
         rel_nrsequen[2] FORMAT "9"
         SKIP
         tt-avais-ctr.nmdavali FORMAT "x(40)"
         tt-avais-ctr.nmconjug FORMAT "x(40)" AT 46
         SKIP
         tt-avais-ctr.cpfavali FORMAT "x(40)"
         tt-avais-ctr.nrcpfcjg FORMAT "x(40)" AT 46
         SKIP
         tt-avais-ctr.dsdocava FORMAT "x(40)"
         tt-avais-ctr.dsdoccjg FORMAT "x(40)" AT 46
         SKIP
         WITH NO-BOX COLUMN 7 NO-LABELS WIDTH 137 FRAME f_avais.
    
    FORM "\022\033\115"
         "________________________________________" AT  1
         "________________________________________" AT 46
         SKIP
         "TESTEMUNHA 1: __________________________"
         "TESTEMUNHA 2: __________________________" AT 46
         SKIP
         "CPF/MF:_________________________________"
         "CPF/MF:_________________________________" AT 46
         SKIP
         "CI:_____________________________________"
         "CI:_____________________________________" AT 46
         SKIP(1)
         WITH NO-BOX COLUMN 7 NO-LABELS WIDTH 137 FRAME f_assina_testemunha.
         
    FORM SPACE(60)
         "\033\105PARA USO DA DIGITALIZACAO\033\106"
         SKIP(1)
         tt-dados-prp.nrdconta FORMAT "zzzz,zzz,9" AT 58
         tt-dados-prp.nrctrlim FORMAT "z,zzz,zz9"  AT 74
         tt-dados-prp.tpregist FORMAT "zz9"        AT 84
         SKIP(2)
         WITH NO-BOX COLUMN 7 NO-LABELS WIDTH 137 FRAME f_digitaliza.

    FORM "\022\033\115"
         "________________________________________" AT  1
         "________________________________________" AT 46
         SKIP
         tt-dados-ctr.nmexcop1  AT 1  FORMAT "x(40)"
         tt-dados-ctr.nmoperad  AT 46 FORMAT "x(40)"
         SKIP
         tt-dados-ctr.nmexcop2  AT 1 FORMAT "x(40)"
         SKIP
         WITH NO-BOX COLUMN 7 NO-LABELS WIDTH 137 
                                        FRAME f_assina_cooperativa_operador.

    /** FORM's para impressao da RESCISAO **/
    FORM "\022\024\033\120"     /* Reseta impressora */
         SKIP(2)
         "\033\017\033\016" tt-dados-rescisao.nmextcop FORMAT "x(50)" AT 20
         "\024\022"
         SKIP(2)
         WITH NO-BOX NO-LABELS FRAME f_cooperativa2.

    FORM SKIP(3)
         "TERMO DE RESCISAO DE CONTRATO DE LIMITE DE CREDITO EM CONTA CORRENTE" 
         AT 6
         "===== == ======== == ======== == ====== == ======= == ===== ========" 
         AT 6
         SKIP(3)
         "Pelo presente termo, as partes ao final"
         "subscritas, tem entre si ajustado a"
         "rescisao   do  CONTRATO  DE "
         "ABERTURA  DE  CREDITO  EM  CONTA  CORRENTE  de"
         "nr."    tt-dados-rescisao.nrctrlim FORMAT "z,zzz,zz9"
         ", da CONTA/DV:"   tt-dados-rescisao.nrdconta FORMAT "zzzz,zzz,9"
         ", cujo limite e de R$" 
         tt-dados-rescisao.vllimite FORMAT "zzzz,zz9.99" "."
         SKIP(3)
         "O presente termo somente sera efetivo, tendo a completa solucao do"
         "contrato,"
         "apos o  ASSOCIADO  liquidar integralmente seu debito para"
         "com a COOPERATIVA,"                            
         "momento a partir do qual as partes dao-se plena,"
         "ampla e geral quitacao para"
         "nada mais reclamar sobre o mesmo."
         SKIP(3)
         tt-dados-rescisao.nmcidade FORMAT "X(13)"
         tt-dados-rescisao.cdufdcop FORMAT "X(4)"
         tt-dados-rescisao.dtmvtolt FORMAT "99/99/9999" "."
         SKIP(4)
         WITH NO-BOX COLUMN 5 NO-LABELS  FRAME f_termo.
        
    FORM "____________________________________" AT  1
         "____________________________________" 
         SKIP
         tt-dados-rescisao.nmoperad FORMAT "x(26)"
         tt-dados-rescisao.nmexcop1 FORMAT "x(36)" AT 38 SKIP
         tt-dados-rescisao.nmexcop2 FORMAT "x(36)" AT 38
         SKIP(3)
         "____________________________________" AT 1
         SKIP
         tt-dados-rescisao.nmprimtl FORMAT "X(50)"
         WITH NO-BOX COLUMN 5 NO-LABELS  FRAME f_termo_apr_ass_manual.

    /* Pj470 SM 1 - Ze Gracik - Mouts */
    FORM SKIP
         tt-dados-rescisao.dsfrass1 FORMAT "x(76)" AT 01 
         SKIP
         tt-dados-rescisao.dsfrass2 FORMAT "x(76)" AT 01 
         SKIP
         tt-dados-rescisao.dsfrass3 FORMAT "x(76)" AT 01 
         SKIP(2)
         tt-dados-rescisao.dsfrcop1 FORMAT "x(76)" AT 01 
         SKIP
         tt-dados-rescisao.dsfrcop2 FORMAT "x(76)" AT 01 
         WITH NO-BOX COLUMN 5 NO-LABELS  FRAME f_termo_apr_ass_eletronica.
    /* Fim Pj470 SM 1 */
              
    
    /** FORM's para impressao da NOTA PROMISSORIA **/
    FORM SKIP(1)
         "\022\024\033\120" /** Reseta impressora **/
         "\0330\033x0\033\017"
         "\033\016    NOTA PROMISSORIA VINCULADA"
         "\0332\033x0"
         SKIP
         "\0330\033x0\033\017"
         "\033\016     AO CONTRATO DE ABERTURA DE"
         "\022\024\033\120" /* reseta impressora */
         "\0332\033x0"
         "    Vencimento:" 
         tt-dados-ctr.ddmvtolt FORMAT "99" "de"
         tt-dados-ctr.dsmesref FORMAT "x(9)" "de"
         tt-dados-ctr.aamvtolt FORMAT "9999"
         SKIP
         "\0330\033x0\033\017"
         "\033\016     CREDITO EM CONTA CORRENTE"
         "\022\024\033\120" /* reseta impressora */
         SKIP(1)
         "NUMERO" AT 7 "\033\016" tt-dados-ctr.dsctrlim FORMAT "x(13)" "\024"
         tt-dados-ctr.dsdmoeda FORMAT "x(5)" "\033\016"
         tt-dados-ctr.vllimite FORMAT "zzz,zzz,zz9.99" "\033\016"
         SKIP
         "Ao(s)" AT 7 tt-dados-ctr.dsdtmvt1 FORMAT "x(68)" SKIP
         tt-dados-ctr.dsdtmvt2  AT 7 FORMAT "x(44)" 
         "pagarei por esta unica via de" SKIP
         "\033\016N O T A  P R O M I S S O R I A\024" AT 7 "a" 
         tt-dados-ctr.nmrescop FORMAT "x(11)" SKIP
         tt-dados-ctr.nmextcop  AT  7 FORMAT "x(50)"
         tt-dados-ctr.nrdocnpj  AT 58 FORMAT "x(23)"
         "ou a sua ordem a quantia de" AT 7
         tt-dados-ctr.dsvlnpr1  AT 35 FORMAT "x(46)" SKIP
         tt-dados-ctr.dsvlnpr2  AT  7 FORMAT "x(74)" SKIP
         "em moeda corrente deste pais." AT 7 SKIP(1)
         tt-dados-ctr.nmcidpac  AT  7 FORMAT "x(33)"
         tt-dados-ctr.dsemsctr  AT 40 FORMAT "X(40)"
         SKIP(1)
         tt-dados-ctr.nmprimtl  AT  7 FORMAT "x(50)"
         SKIP
         tt-dados-ctr.nrcpfcgc  AT 7  FORMAT "x(40)" 
         "______________________________" AT 50
         
         SKIP
         "Conta/dv:"  AT 7 tt-dados-ctr.nrdconta FORMAT "zzzz,zzz,9" 
         "Assinatura" AT 50
         SKIP
         "Endereco:"  AT 7 SKIP
         tt-dados-ctr.endeass1 AT 7 FORMAT "x(73)" SKIP
         tt-dados-ctr.endeass2 AT 7 FORMAT "x(40)" SKIP
         tt-dados-ctr.endeass3 AT 7 FORMAT "x(45)" SKIP(1)
         WITH NO-BOX NO-LABELS DOWN WIDTH 137 FRAME f_promissoria.
    
    FORM rel_dsqtdava AT 7 FORMAT "x(10)" 
         "Conjuge:"   AT 47
         SKIP(2)
         WITH NO-BOX NO-LABELS WIDTH 137 FRAME f_promiss_aval_cab.
         
    FORM "\022\033\115"
         "----------------------------------------" AT 11
         "----------------------------------------" AT 59
         tt-avais-ctr.nmdavali FORMAT "x(40)" AT 08
         tt-avais-ctr.nmconjug FORMAT "x(40)" AT 56
         SKIP
         tt-avais-ctr.cpfavali FORMAT "x(40)" AT 08
         tt-avais-ctr.nrcpfcjg FORMAT "x(40)" AT 56
         SKIP
         tt-avais-ctr.dsdocava FORMAT "x(40)" AT 08
         tt-avais-ctr.dsdoccjg FORMAT "x(40)" AT 56
         SKIP
         tt-avais-ctr.dsendav1 FORMAT "x(40)" AT 08
         SKIP
         tt-avais-ctr.dsendav2 FORMAT "x(40)" AT 08
         SKIP 
         tt-avais-ctr.dsendav3 FORMAT "x(40)" AT 08
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 137 FRAME f_promis_aval.
    
    FORM SKIP(5)
         WITH NO-BOX WIDTH 137 FRAME f_linhas.

    FORM "Grupo Economico:" AT 01
        SKIP(1)
        WITH FRAME f_grupo_1.
        
   FORM tt-grupo.cdagenci COLUMN-LABEL "PA"
        tt-grupo.nrctasoc COLUMN-LABEL "Conta"
        tt-grupo.vlendivi COLUMN-LABEL "Endividamento" FORMAT "zzz,zzz,zz9.99"
        tt-grupo.dsdrisco COLUMN-LABEL "Risco"
        WITH DOWN WIDTH 120 NO-BOX FRAME f_grupo.

   FORM SKIP(1) 
        aux_dsdrisco LABEL "Risco do Grupo"
        SKIP
        aux_vlendivi LABEL "Endividamento do Grupo"
        WITH NO-LABEL SIDE-LABEL WIDTH 120 NO-BOX FRAME f_grupo_2.

    EMPTY TEMP-TABLE tt-erro.

    IF  par_flgerlog  THEN
        DO:
            ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).

            IF  par_idimpres = 1  THEN
                aux_dstransa = "Gerar impressao da proposta e contrato do " +
                               "limite de credito".
            ELSE
            IF  par_idimpres = 2  THEN
                aux_dstransa = "Gerar impressao do contrato do limite de " +
                               "credito".
            ELSE
            IF  par_idimpres = 3  THEN
                aux_dstransa = "Gerar impressao da proposta do limite de " +
                               "credito".
            ELSE
            IF  par_idimpres = 4  THEN
                aux_dstransa = "Gerar impressao da rescisao do limite de " +
                               "credito".
            ELSE
            IF  par_idimpres = 6  THEN
                aux_dstransa = "Gerar impressao de demonstracao do cet".

        END.

    Gera_Impressao:
    DO ON ERROR UNDO, LEAVE:

       FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

       IF  NOT AVAILABLE crapcop  THEN
           DO:
               ASSIGN aux_cdcritic = 651
                      aux_dscritic = "".

               LEAVE Gera_Impressao.
           END.

       RUN impressoes-limite (INPUT par_cdcooper,
                              INPUT par_cdagecxa,
                              INPUT par_nrdcaixa,
                              INPUT par_cdopecxa,
                              INPUT par_nmdatela,
                              INPUT par_idorigem,
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT par_dtmvtolt,
                              INPUT par_dtmvtopr,
                              INPUT par_inproces,
                              INPUT par_idimpres,
                              INPUT par_nrctrlim,
                              INPUT FALSE,
                             OUTPUT TABLE tt-dados-prp,
                             OUTPUT TABLE tt-dados-ctr,
                             OUTPUT TABLE tt-repres-ctr,
                             OUTPUT TABLE tt-avais-ctr,
                             OUTPUT TABLE tt-dados-rescisao,
                             OUTPUT TABLE tt-erro).
    
       IF  RETURN-VALUE <> "OK"  THEN
           LEAVE Gera_Impressao.

       ASSIGN rel_nrsequen[1] = 0.
       
       FOR EACH tt-avais-ctr NO-LOCK:
           ASSIGN rel_nrsequen[1] = rel_nrsequen[1] + 1.
       END.
       
       ASSIGN rel_dsqtdava = IF  rel_nrsequen[1] > 1  THEN
                                 "Avalistas:"
                             ELSE
                                 "Avalista:".
       
       /* Se nao for impressao do cet gera arquivo normal */
       IF  par_idimpres <> 6 THEN
           DO:
               ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                                     par_dsiduser.
               
               UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
           
               ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
                      aux_nmarqimp = aux_nmarquiv + ".ex"
                      aux_nmarqpdf = aux_nmarquiv + ".pdf".
               
               OUTPUT STREAM str_limcre TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 65.
           
               /** Configura a impressora para 1/6" **/
               PUT STREAM str_limcre CONTROL "\0332\033x0\022" NULL.

           END.
      
       IF  par_idimpres = 6 THEN /** Demonstracao do CET **/
           DO:
               FIND FIRST tt-dados-ctr NO-LOCK NO-ERROR.
       
               IF  NOT AVAILABLE tt-dados-ctr  THEN
                   DO:
                       ASSIGN aux_cdcritic = 0
                              aux_dscritic = "Nao foi possivel gerar a impressao.".

                       LEAVE Gera_Impressao.
                   END.

               FIND craplrt WHERE craplrt.cdcooper = par_cdcooper AND
                                  craplrt.cddlinha = tt-dados-ctr.cddlinha
                                  NO-LOCK NO-ERROR.

               IF  NOT AVAIL craplrt THEN
                   RETURN "NOK".

               /* Chamar rorina de impressao do contrato do cet */
               RUN imprime_cet( INPUT par_cdcooper,
                                INPUT par_dtmvtolt,
                                INPUT "ATENDA",
                                INPUT INT(tt-dados-ctr.nrdconta),
                                INPUT INT(tt-dados-ctr.inpessoa),
                                INPUT 1, /* p-cdusolcr */
                                INPUT INT(tt-dados-ctr.cddlinha),
                                INPUT 1, /*1-Chq Esp./ 2-Desc Chq./ 3-Desc Tit*/
                                INPUT INT(tt-dados-ctr.nrctrlim),
                                INPUT (IF tt-dados-ctr.dtrenova <> ?      THEN
                                         DATE(tt-dados-ctr.dtrenova)
                                       ELSE IF tt-dados-ctr.dtinivig <> ? THEN
                                         DATE(tt-dados-ctr.dtinivig)
                                       ELSE par_dtmvtolt),
                                INPUT INT(tt-dados-ctr.qtdiavig), 
                                INPUT DEC(tt-dados-ctr.vllimite),
                                INPUT DEC(craplrt.txmensal),
                               OUTPUT aux_nmdoarqv, 
                               OUTPUT aux_dscritic ).

               IF  RETURN-VALUE <> "OK" THEN
                   LEAVE Gera_Impressao.
                     
               ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + 
                                         "/rl/" + aux_nmdoarqv
                      aux_nmarqimp = aux_nmarquiv + ".ex"  
                      aux_nmarqpdf = aux_nmarquiv + ".pdf". 

           END.
       ELSE
       IF  par_idimpres = 3  THEN /** Proposta **/
           DO:         
               FIND FIRST tt-dados-prp NO-LOCK NO-ERROR.
     
               IF  NOT AVAILABLE tt-dados-prp  THEN
                   DO:
                       ASSIGN aux_cdcritic = 0
                              aux_dscritic = "Nao foi possivel gerar a impressao.".
     
                       LEAVE Gera_Impressao.
                   END.
     
               /* somente ira mostar este form se houver registro na crapdoc */
               IF  tt-dados-prp.tpregist = 84 THEN 
                   DISPLAY STREAM str_limcre tt-dados-prp.nrdconta 
                                             tt-dados-prp.nrctrlim 
                                             tt-dados-prp.tpregist 
                                             WITH FRAME f_digitaliza.
     
               RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT 
                   SET h-b1wgen0043.
       
               IF  NOT VALID-HANDLE(h-b1wgen0043)  THEN
                   DO:
                       ASSIGN aux_cdcritic = 0
                              aux_dscritic = "Handle invalido para BO b1wgen0043.".
              
                       LEAVE Gera_Impressao.
                   END.

               RUN ratings-impressao IN h-b1wgen0043 (INPUT par_cdcooper,
                                                      INPUT 0, /** Todos PACS **/
                                                      INPUT par_cdopecxa,
                                                      INPUT par_idorigem, 
                                                      INPUT par_dtmvtolt,
                                                      INPUT par_dtmvtopr,
                                                      INPUT par_nrdconta,
                                                      INPUT par_nrctrlim,
                                                      INPUT 1, 
                                                      INPUT par_inproces,
                                                     OUTPUT TABLE tt-ratings).
              
               DELETE PROCEDURE h-b1wgen0043.

               IF  tt-dados-prp.dsobser1 <> ""  OR
                   tt-dados-prp.dsobser2 <> ""  OR
                   tt-dados-prp.dsobser3 <> ""  THEN
                   DO:
                       ASSIGN rel_cabobser = "OBSERVACOES:"
                              aux_dsobserv = tt-dados-prp.dsobser1 + " " +
                                             tt-dados-prp.dsobser2 + " " +
                                             tt-dados-prp.dsobser3.
                   END.
                 
               DISPLAY STREAM str_limcre
                       tt-dados-prp.nmextcop  tt-dados-prp.nrctrlim
                       WITH FRAME f_coop.
                    
               IF  tt-dados-prp.inpessoa > 1  THEN 
                   DO:
                      DISPLAY STREAM str_limcre
                               tt-dados-prp.nrdconta  tt-dados-prp.nrmatric
                               tt-dados-prp.nmresage  tt-dados-prp.nmprimtl
                               tt-dados-prp.dtadmiss  tt-dados-prp.nrcpfcgc
                               tt-dados-prp.nmsegntl  tt-dados-prp.dsempres
                               tt-dados-prp.dstipcta  tt-dados-prp.dssitdct
                               tt-dados-prp.vlsmdtri  tt-dados-prp.vlcaptal
                               tt-dados-prp.vlprepla  tt-dados-prp.vlaplica
                               tt-dados-prp.vlfatmes  tt-dados-prp.perfatcl
                               tt-dados-prp.vllimcre  tt-dados-prp.vlalugue
                               tt-dados-prp.vltotccr  tt-dados-prp.vltotemp
                               tt-dados-prp.vltotpre  tt-dados-prp.vlutiliz
                               tt-dados-prp.vllimite  tt-dados-prp.dtiniatv
                               tt-dados-prp.dsrmativ
                               rel_cabobser WITH FRAME f_dados_juridica.
                   END.
               ELSE
                   DO:
                      DISPLAY STREAM str_limcre
                       tt-dados-prp.nrdconta  tt-dados-prp.nrmatric
                       tt-dados-prp.nmresage  tt-dados-prp.nmprimtl
                       tt-dados-prp.dtadmiss  tt-dados-prp.nrcpfcgc
                       tt-dados-prp.nmsegntl  tt-dados-prp.dsempres
                       tt-dados-prp.dstipcta  tt-dados-prp.dssitdct
                       tt-dados-prp.vlsmdtri  tt-dados-prp.vlcaptal 
                       tt-dados-prp.vlprepla  tt-dados-prp.vlaplica 
                       tt-dados-prp.vlsalari  tt-dados-prp.vlsalcon 
                       tt-dados-prp.vloutras  tt-dados-prp.vllimcre
                       tt-dados-prp.vlalugue  tt-dados-prp.vltotccr
                       tt-dados-prp.vltotemp  tt-dados-prp.vltotpre
                       tt-dados-prp.vlutiliz  tt-dados-prp.vllimite
                       tt-dados-prp.vlrencjg
                       rel_cabobser WITH FRAME f_dados_fisica.
                   END.
               
               ASSIGN aux_restoobs = LENGTH(aux_dsobserv) MODULO 76
                      aux_incontad = 1.

               /* Se existe observacao. Dividir em linhas de 76 caracteres */
               /* (Para aparecer conforme foi digitado na tela) */
               IF   aux_dsobserv <> ""  THEN 
                    DO:
                        DO aux_contador = 1 TO LENGTH(aux_dsobserv):
               
                           IF   aux_contador MOD 76 = 0   THEN
                                DO:
                                    rel_dsobserv =
                                        SUBSTR(aux_dsobserv,aux_incontad,76).
               
                                    DISPLAY STREAM str_limcre
                                        rel_dsobserv WITH FRAME f_dados_2.
               
                                    DOWN WITH FRAME f_dados_2.
               
                                    ASSIGN aux_incontad = aux_incontad + 76.
                                END.
                        END.
               
                        IF   LENGTH(aux_dsobserv) > aux_restoobs   THEN
                             aux_incontad = LENGTH(aux_dsobserv) - aux_restoobs + 1.
                        ELSE
                             aux_incontad = 1.

                        ASSIGN rel_dsobserv =
                            SUBSTR(aux_dsobserv,aux_incontad,aux_restoobs).
                        
                        DISPLAY STREAM str_limcre
                            rel_dsobserv WITH FRAME f_dados_2.
                    END.
                
               VIEW STREAM str_limcre FRAME f_dados_3.
               
               /* SCR e consultas para o TITULAR */
               RUN imprime-scr-consultas (INPUT par_cdcooper,
                                          INPUT par_cdopecxa,
                                          INPUT par_nmdatela,
                                          INPUT par_idorigem,
                                          INPUT par_dtmvtolt,
                                          INPUT par_nrdconta,
                                          INPUT par_nrctrlim,
                                          INPUT crapass.inpessoa, 
                                          INPUT par_nrdconta,
                                          INPUT 0, /* CPF */
                                          INPUT 0, /* Indicador do aval */
                                         OUTPUT TABLE tt-erro).

               /* SCR para o conjuge */
               IF  (tt-dados-prp.nrcpfcjg <> 0    OR
                    tt-dados-prp.nrctacje <> 0)   AND 
                    tt-dados-prp.inconcje = 1     THEN
                   RUN imprime-scr-consultas (INPUT par_cdcooper,
                                              INPUT par_cdopecxa,
                                              INPUT par_nmdatela,
                                              INPUT par_idorigem,
                                              INPUT par_dtmvtolt,
                                              INPUT par_nrdconta,
                                              INPUT par_nrctrlim,
                                              INPUT 5, /* Conjuge */ 
                                              INPUT tt-dados-prp.nrctacje,
                                              INPUT tt-dados-prp.nrcpfcjg,
                                              INPUT 0, /* Indicador do aval */
                                             OUTPUT TABLE tt-erro).

               /* SCR e consultar para o aval 1 */
               IF   tt-dados-prp.nrctaav1 <> 0   OR
                    tt-dados-prp.nrcpfav1 <> 0   THEN
                    RUN imprime-scr-consultas (INPUT par_cdcooper,
                                               INPUT par_cdopecxa,
                                               INPUT par_nmdatela,
                                               INPUT par_idorigem,
                                               INPUT par_dtmvtolt,
                                               INPUT par_nrdconta,
                                               INPUT par_nrctrlim,
                                               INPUT tt-dados-prp.inpesso1,
                                               INPUT tt-dados-prp.nrctaav1,
                                               INPUT tt-dados-prp.nrcpfav1,
                                               INPUT 1, /* Indicador do aval */
                                              OUTPUT TABLE tt-erro).
                                            
               /* SCR e consultar para o aval 2 */
               IF   tt-dados-prp.nrctaav2 <> 0   OR
                    tt-dados-prp.nrcpfav2 <> 0   THEN
                    RUN imprime-scr-consultas (INPUT par_cdcooper,
                                               INPUT par_cdopecxa,
                                               INPUT par_nmdatela,
                                               INPUT par_idorigem,
                                               INPUT par_dtmvtolt,
                                               INPUT par_nrdconta,
                                               INPUT par_nrctrlim,
                                               INPUT tt-dados-prp.inpesso2, 
                                               INPUT tt-dados-prp.nrctaav2,
                                               INPUT tt-dados-prp.nrcpfav2,
                                               INPUT 2, /* Indicador do aval */
                                              OUTPUT TABLE tt-erro).
                                            

               DISPLAY STREAM str_limcre
                       tt-dados-prp.nmoperad  tt-dados-prp.nmexcop1
                       tt-dados-prp.nmexcop2  tt-dados-prp.nmprimtl
                       tt-dados-prp.nmcidade  tt-dados-prp.dsemsprp 
                       WITH FRAME f_final.
               
               /*RATING NOVO*/
               ASSIGN vr_inrisrat            = ""       
                      vr_inponrat            = 0
                      vr_innivrat            = ""
                      vr_insegrat            = ""
                      vr_vlr                 = 0
                      vr_qtdreg              = 0
                      vr_nrctro_out          = 0
                      vr_tpctrato_out        = 0.
                     
               ASSIGN aux_dscritic = "".
               ASSIGN aux_cdcritic = 0.
              
                EMPTY TEMP-TABLE tt-ratings-novo.
              
               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                          
               RUN STORED-PROCEDURE pc_busca_dados_rating_inclusao
                     aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper      /*COOPERATIVA */
                                                         ,INPUT par_nrdconta  /*CONTA  */
                                                         ,INPUT par_nrctrlim  /*NUM CONTRATO DA CONTA*/
                                                         ,INPUT 1                /*TIPO CONTRATO DA CONTA*/
                                                         ,OUTPUT "" /*pr_des_inrisco_rat_inc - Nivel de Rating da Inclusao da Proposta*/
                                                         ,OUTPUT 0  /*pr_inpontos_rat_inc    - Pontuacao do Rating retornada do Motor no momento da Inclusao*/
                                                         ,OUTPUT "" /*pr_innivel_rat_inc     - Nivel de Risco do Rating Inclusao (1-Baixo/2-Medio/3-Alto)*/
                                                         ,OUTPUT "" /*pr_insegmento_rat_inc   - qual Garantia foi utilizada para calculo Rating na Inclusao*/
                                                         ,OUTPUT 0                /*pr_vlr  crapepr.vlemprst*/
                                                         ,OUTPUT 0                /*pr_qtdreg QTDE REG.*/
                                                         ,OUTPUT 0                /*pr_nrctro_out CONTRATO DA CONTA*/
                                                         ,OUTPUT 0                /*pr_tpctrato_out TIPO CONTRATO DA CONTA*/
                                                         ,OUTPUT ""               /*Arquivo de retorno do XML*/
                                                         ,OUTPUT 0                /*pr_cdcritic  */
                                                         ,OUTPUT "").             /*Descricao da critica*/
                                                         
               CLOSE STORED-PROC pc_busca_dados_rating_inclusao
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                     
               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
              
               ASSIGN vr_xml = pc_busca_dados_rating_inclusao.pr_retxml_clob
                                WHEN pc_busca_dados_rating_inclusao.pr_retxml_clob <> ?.
               ASSIGN aux_cdcritic = pc_busca_dados_rating_inclusao.pr_cdcritic
                                WHEN pc_busca_dados_rating_inclusao.pr_cdcritic <> ?.
               ASSIGN aux_dscritic = pc_busca_dados_rating_inclusao.pr_dscritic
                                WHEN pc_busca_dados_rating_inclusao.pr_dscritic <> ?.
               ASSIGN vr_inrisrat = ''
                      vr_inrisrat = pc_busca_dados_rating_inclusao.pr_des_inrisco_rat_inc 
                                WHEN pc_busca_dados_rating_inclusao.pr_des_inrisco_rat_inc <> ? .
               ASSIGN vr_inponrat = pc_busca_dados_rating_inclusao.pr_inpontos_rat_inc 
                                WHEN pc_busca_dados_rating_inclusao.pr_inpontos_rat_inc <> ? .
               ASSIGN vr_innivrat = ''
                      vr_innivrat = pc_busca_dados_rating_inclusao.pr_innivel_rat_inc 
                                WHEN pc_busca_dados_rating_inclusao.pr_innivel_rat_inc <> ? .
               ASSIGN vr_insegrat = pc_busca_dados_rating_inclusao.pr_insegmento_rat_inc 
                                WHEN pc_busca_dados_rating_inclusao.pr_insegmento_rat_inc <> ? .
               ASSIGN vr_vlr = pc_busca_dados_rating_inclusao.pr_vlr 
                                WHEN pc_busca_dados_rating_inclusao.pr_vlr <> ? .
               ASSIGN vr_qtdreg = pc_busca_dados_rating_inclusao.pr_qtdreg 
                                WHEN pc_busca_dados_rating_inclusao.pr_qtdreg <> ? .
               ASSIGN vr_nrctro_out = pc_busca_dados_rating_inclusao.pr_nrctro_out 
                                WHEN pc_busca_dados_rating_inclusao.pr_nrctro_out<> ? .
               ASSIGN vr_tpctrato_out = pc_busca_dados_rating_inclusao.pr_tpctrato_out 
                               WHEN pc_busca_dados_rating_inclusao.pr_tpctrato_out <> ? .

               CREATE tt-ratings-novo. 
               ASSIGN tt-ratings-novo.nrctrrat = vr_nrctro_out
                      tt-ratings-novo.tpctrrat = vr_tpctrato_out
                      tt-ratings-novo.vloperac = vr_vlr
                      tt-ratings-novo.dsdopera = "Limite Credito"
                      tt-ratings-novo.innivrat = vr_innivrat   
                      tt-ratings-novo.inrisrat = vr_inrisrat  /*Nota Rating */
                      tt-ratings-novo.inponrat = vr_inponrat
                      tt-ratings-novo.insegrat = vr_insegrat.
                
               /* Nao imprimir risco da proposta na central */
               IF  par_cdcooper <> 3  THEN
                   DO:
                    FIND FIRST tt-ratings-novo WHERE 
                         tt-ratings-novo.tpctrrat = 1   AND
                         tt-ratings-novo.nrctrrat = par_nrctrlim NO-LOCK NO-ERROR.
                
                    IF   ((AVAIL tt-ratings-novo) AND
                          (tt-ratings-novo.inrisrat <> ?)) THEN
                    DO:
                         DISPLAY STREAM str_limcre 
                                 tt-ratings-novo.dsdopera
                                 tt-ratings-novo.nrctrrat
                                 tt-ratings-novo.inponrat
                                 tt-ratings-novo.inrisrat
                                 tt-ratings-novo.innivrat
                                 tt-ratings-novo.insegrat
                                 WITH FRAME f_rating_atual_novo.
                    END.
               END.
               IF  CAN-FIND(FIRST tt-ratings WHERE NOT 
                                 (tt-ratings.tpctrrat = 1              AND
                                  tt-ratings.nrctrrat = par_nrctrlim)) THEN
                   VIEW STREAM str_limcre FRAME f_historico_rating_1.
               
               /** Todos os outros ratings de operacoes ainda em aberto **/
               FOR EACH tt-ratings WHERE NOT 
                       (tt-ratings.tpctrrat = 1             AND
                        tt-ratings.nrctrrat = par_nrctrlim) NO-LOCK
                        BY tt-ratings.insitrat DESC
                           BY tt-ratings.nrnotrat DESC:
               
                   DISPLAY STREAM str_limcre 
                           tt-ratings.dsdopera  tt-ratings.nrctrrat
                           tt-ratings.indrisco  tt-ratings.nrnotrat
                           tt-ratings.vloperac  tt-ratings.dsditrat
                           WITH FRAME f_historico_rating_2.
               
                   DOWN WITH FRAME f_historico_rating_2.
               
               END.
               
               IF NOT VALID-HANDLE(h-b1wgen0138) THEN
                  RUN sistema/generico/procedures/b1wgen0138.p
                      PERSISTENT SET h-b1wgen0138.
                       
               IF DYNAMIC-FUNCTION("busca_grupo" IN h-b1wgen0138,
                                               INPUT par_cdcooper, 
                                               INPUT par_nrdconta, 
                                              OUTPUT aux_nrdgrupo,
                                              OUTPUT aux_gergrupo,
                                              OUTPUT aux_dsdrisgp) THEN
                   DO:          
                     /* Procedure responsavel para calcular o endividamento do grupo */
                        RUN calc_endivid_grupo IN h-b1wgen0138
                                                     (INPUT par_cdcooper,
                                                      INPUT par_cdagecxa,
                                                      INPUT par_nrdcaixa, 
                                                      INPUT par_cdopecxa, 
                                                      INPUT par_dtmvtolt, 
                                                      INPUT par_nmdatela, 
                                                      INPUT par_idorigem, 
                                                      INPUT aux_nrdgrupo, 
                                                      INPUT TRUE, /*Consulta por conta*/
                                                     OUTPUT aux_dsdrisco, 
                                                     OUTPUT aux_vlendivi,
                                                     OUTPUT TABLE tt-grupo, 
                                                     OUTPUT TABLE tt-erro).
                     
                        IF VALID-HANDLE(h-b1wgen0138) THEN
                           DELETE OBJECT h-b1wgen0138.  
                         
                        IF RETURN-VALUE <> "OK" THEN
                           LEAVE Gera_Impressao.
                    
                        IF TEMP-TABLE tt-grupo:HAS-RECORDS THEN
                           DO:
                              VIEW STREAM str_limcre FRAME f_grupo_1.
                    
                              FOR EACH tt-grupo NO-LOCK BY tt-grupo.cdagenci:
                              
                                  DISP STREAM str_limcre tt-grupo.cdagenci
                                                    tt-grupo.nrctasoc
                                                    tt-grupo.vlendivi
                                                    tt-grupo.dsdrisco
                                                    WITH FRAME f_grupo.
                              
                                  DOWN WITH FRAME f_grupo.
                              
                              END.                  
                              
                              DISP STREAM str_limcre aux_dsdrisco 
                                          aux_vlendivi
                                          WITH FRAME f_grupo_2.
                    
                           END.
                    
                     END.

               IF VALID-HANDLE(h-b1wgen0138) THEN
                  DELETE OBJECT h-b1wgen0138.

               PAGE STREAM str_limcre.
           END. 
       ELSE
       IF  par_idimpres = 1  OR   /** Completa **/
           par_idimpres = 2  THEN /** Contrato **/
           DO:
               FIND FIRST tt-dados-ctr NO-LOCK NO-ERROR.
      
               IF  NOT AVAILABLE tt-dados-ctr  THEN
                   DO:
                       ASSIGN aux_cdcritic = 0
                              aux_dscritic = "Nao foi possivel gerar a impressao.".
      
                       LEAVE Gera_Impressao.
                   END.
       
               RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
                   SET h-b1wgen9999.

               /*  calculo do cet por extenso ................................ */
               RUN valor-extenso IN h-b1wgen9999 
                                (INPUT tt-dados-ctr.txcetano, 
                                 INPUT 60, 
                                 INPUT 75, 
                                 INPUT "P",
                                 OUTPUT aux_dscetan1, 
                                 OUTPUT aux_dscetan2).
               
			   /* Ajuste em (14/09/2016) Aceitar uma dígito a mais no CET */
               ASSIGN aux_dscetan1 = STRING(tt-dados-ctr.txcetano,"zzz9.99") + 
                                     " % (" + LC(aux_dscetan1).
               
               IF   LENGTH(TRIM(aux_dscetan2)) = 0   THEN
                    ASSIGN aux_dscetan1 = aux_dscetan1 + ")" 
                           aux_dscetan2 = "ao ano; (" +
                                          STRING(tt-dados-ctr.txcetmes,"z9.99") +
                                          " % ao mes), " +
                                          "conforme planilha demonstrativa".
               ELSE
                    ASSIGN aux_dscetan1 = aux_dscetan1 
                           aux_dscetan2 = TRIM(LC(aux_dscetan2)) + ") ao ano; (" +
                                          STRING(tt-dados-ctr.txcetmes,"z9.99") +
                                          " % ao mes), " +
                                          "conforme planilha demonstrativa".

               IF  tt-dados-ctr.inpessoa > 1  THEN 
                   DO:
                       VIEW STREAM str_limcre FRAME f_contrato_juridica_cab.
                      
                       DISPLAY STREAM str_limcre
                               tt-dados-ctr.nmextcop  tt-dados-ctr.nrdocnpj
                               tt-dados-ctr.cdagenci  tt-dados-ctr.dsendcop
                               tt-dados-ctr.nmprimtl  tt-dados-ctr.nrcpfcgc 
                               tt-dados-ctr.nrdconta  tt-dados-ctr.endeass1
                               tt-dados-ctr.endeass2  tt-dados-ctr.endeass3
                               WITH FRAME f_contrato_juridica1.
                               
                       FOR EACH tt-repres-ctr NO-LOCK:
                       
                           DISPLAY STREAM str_limcre
                                   tt-repres-ctr.nmrepres  tt-repres-ctr.nrcpfrep
                                   tt-repres-ctr.dsdocrep  tt-repres-ctr.cdoedrep
                                   WITH FRAME f_representantes.
              
                           DOWN STREAM str_limcre WITH FRAME f_representantes.
              
                       END.
                    
                       DISPLAY STREAM str_limcre
                               tt-dados-ctr.vllimite  tt-dados-ctr.dsvlnpr1
                               tt-dados-ctr.dsvlnpr2
                               WITH FRAME f_contrato_juridica2.
                               
                       DISPLAY STREAM str_limcre
                               tt-dados-ctr.dsencfi1  tt-dados-ctr.dsencfi2
                               tt-dados-ctr.dsencfi3  aux_dscetan1 aux_dscetan2
                               WITH FRAME f_contrato_juridica3.
                               
                       DISPLAY STREAM str_limcre 
                               tt-dados-ctr.qtdiavig
                               WITH FRAME f_contrato_juridica4.
                               
                       VIEW STREAM str_limcre FRAME f_contrato_juridica5.
                       VIEW STREAM str_limcre FRAME f_contrato_juridica6.
                       VIEW STREAM str_limcre FRAME f_contrato_juridica7.
                       VIEW STREAM str_limcre FRAME f_contrato_juridica8. 
                       VIEW STREAM str_limcre FRAME f_contrato_juridica9.
                   END.
               ELSE
                   DO:
                       DISPLAY STREAM str_limcre 
                               tt-dados-ctr.nrctrlim 
                               WITH FRAME f_cooperativa.
                               
                       DISPLAY STREAM str_limcre        
                               tt-dados-ctr.nmextcop  tt-dados-ctr.nrdocnpj
                               tt-dados-ctr.dsendcop  tt-dados-ctr.nmprimtl
                               tt-dados-ctr.cdagenci  tt-dados-ctr.nrdconta
                               tt-dados-ctr.nrdrgass  tt-dados-ctr.nrcpfcgc
                               tt-dados-ctr.vllimite  tt-dados-ctr.dsvlnpr1
                               tt-dados-ctr.dsvlnpr2  tt-dados-ctr.dsencfi1
                               tt-dados-ctr.dsencfi2  tt-dados-ctr.dsencfi3
                               tt-dados-ctr.qtdiavig  aux_dscetan1 aux_dscetan2
                               WITH FRAME f_contrato.
                       
                       VIEW STREAM str_limcre FRAME f_fim.
                   END. 
                 
               DISPLAY STREAM str_limcre 
                              tt-dados-ctr.dsemsctr 
                              WITH FRAME f_data_emissao.
                    
               DISPLAY STREAM str_limcre
                       tt-dados-ctr.nmprimtl 
                       WITH FRAME f_assina_cooper. 
               
               ASSIGN rel_nrsequen = 0.
            
               FOR EACH tt-avais-ctr NO-LOCK:
               
                   ASSIGN rel_nrsequen[1] = rel_nrsequen[1] + 1
                          rel_nrsequen[2] = rel_nrsequen[1].
                  
                   DISP STREAM str_limcre 
                        rel_nrsequen
                        tt-avais-ctr.nmdavali  tt-avais-ctr.cpfavali 
                        tt-avais-ctr.dsdocava  tt-avais-ctr.nmconjug 
                        tt-avais-ctr.nrcpfcjg  tt-avais-ctr.dsdoccjg 
                        WITH FRAME f_avais.
                        
                   DOWN STREAM str_limcre WITH FRAME f_avais.    
               
               END.
               
               DISPLAY STREAM str_limcre tt-dados-ctr.nmexcop1
                                         tt-dados-ctr.nmoperad
                                         tt-dados-ctr.nmexcop2
                                         WITH FRAME f_assina_cooperativa_operador.
                       
               VIEW STREAM str_limcre FRAME f_assina_testemunha.
                              
                /*** GERAR CONTRATO DO CET ***/
               FIND craplrt WHERE craplrt.cdcooper = par_cdcooper AND
                                  craplrt.cddlinha = tt-dados-ctr.cddlinha
                                  NO-LOCK NO-ERROR.
               
               IF  NOT AVAIL craplrt THEN
                   RETURN "NOK".
               
               /* Chamar rorina de impressao do contrato do cet */
               RUN imprime_cet( INPUT par_cdcooper,
                                INPUT par_dtmvtolt,
                                INPUT "ATENDA",
                                INPUT int(tt-dados-ctr.nrdconta),
                                INPUT int(tt-dados-ctr.inpessoa),
                                INPUT 1, /* p-cdusolcr */
                                INPUT int(tt-dados-ctr.cddlinha),
                                INPUT 1, /*1-Chq Esp./ 2-Desc Chq./ 3-Desc Tit*/
                                INPUT int(tt-dados-ctr.nrctrlim),
                                INPUT (IF tt-dados-ctr.dtrenova <> ?      THEN
                                         DATE(tt-dados-ctr.dtrenova)
                                       ELSE IF tt-dados-ctr.dtinivig <> ? THEN
                                         DATE(tt-dados-ctr.dtinivig)
                                       ELSE par_dtmvtolt),
                                INPUT int(tt-dados-ctr.qtdiavig), 
                                INPUT dec(tt-dados-ctr.vllimite),
                                INPUT dec(craplrt.txmensal),
                               OUTPUT aux_nmdoarqv, 
                               OUTPUT aux_dscritic ).
              
            IF  RETURN-VALUE <> "OK" THEN
                LEAVE Gera_Impressao.

           END. 
       ELSE
       IF  par_idimpres = 4  THEN   /** Imprime Rescisao (Cancelamento) **/
           DO:
               FIND tt-dados-rescisao NO-LOCK NO-ERROR.
               
               IF  NOT AVAIL tt-dados-rescisao  THEN
                   DO:
                       ASSIGN aux_cdcritic = 0
                              aux_dscritic = "Nao foi possivel gerar a impressao.".
               
                       LEAVE Gera_Impressao.
                   END.
               
               DISPLAY STREAM str_limcre SKIP(2).
               
               DISPLAY STREAM str_limcre 
                       tt-dados-rescisao.nmextcop 
                       WITH FRAME f_cooperativa2.
               
               DISPLAY STREAM str_limcre
                       tt-dados-rescisao.nrctrlim  tt-dados-rescisao.nrdconta
                       tt-dados-rescisao.vllimite  tt-dados-rescisao.nmcidade
                       tt-dados-rescisao.cdufdcop  tt-dados-rescisao.dtmvtolt 
                       tt-dados-rescisao.nmoperad  tt-dados-rescisao.nmexcop1
                       tt-dados-rescisao.nmexcop2  tt-dados-rescisao.nmprimtl
                       WITH FRAME f_termo.

               /* Pj470 SM 1 - Ze Gracik - Mouts */
               IF   tt-dados-rescisao.dsfrass1 = "*" THEN
                    DISPLAY STREAM str_limcre
                                tt-dados-rescisao.nmoperad
                                tt-dados-rescisao.nmexcop1
                                tt-dados-rescisao.nmexcop2
                                tt-dados-rescisao.nmprimtl
                                WITH FRAME f_termo_apr_ass_manual.
               ELSE
                    DISPLAY STREAM str_limcre
                                tt-dados-rescisao.dsfrass1
                                tt-dados-rescisao.dsfrass2
                                tt-dados-rescisao.dsfrass3
                                tt-dados-rescisao.dsfrcop1
                                tt-dados-rescisao.dsfrcop2
                                WITH FRAME f_termo_apr_ass_eletronica.
               /* Fim Pj470 SM 1 */
           END. 
         
       IF  par_idimpres <> 6 THEN
           DO:
               /** Tratamento da impressao da nota promissoria **/        
               IF  par_flgimpnp  THEN
                   DO:
                       PAGE STREAM str_limcre.
               
                       PUT STREAM str_limcre CONTROL "\0330\033x0\033\022\033\120" NULL.
                       
                       DISPLAY STREAM str_limcre
                               tt-dados-ctr.ddmvtolt  tt-dados-ctr.dsmesref
                               tt-dados-ctr.aamvtolt  tt-dados-ctr.dsctrlim
                               tt-dados-ctr.dsdmoeda  tt-dados-ctr.vllimite
                               tt-dados-ctr.dsdtmvt1  tt-dados-ctr.dsdtmvt2
                               tt-dados-ctr.nmrescop  tt-dados-ctr.nmextcop 
                               tt-dados-ctr.nrdocnpj  tt-dados-ctr.dsvlnpr1
                               tt-dados-ctr.dsvlnpr2  tt-dados-ctr.nmcidpac
                               tt-dados-ctr.dsemsctr  tt-dados-ctr.nmprimtl
                               tt-dados-ctr.nrcpfcgc  tt-dados-ctr.nrdconta
                               tt-dados-ctr.endeass1  tt-dados-ctr.endeass2
                               tt-dados-ctr.endeass3
                               WITH FRAME f_promissoria.
            
                       DOWN STREAM str_limcre WITH FRAME f_promissoria.
                               
                       IF  rel_nrsequen[1] > 0  THEN
                           DISP STREAM str_limcre  rel_dsqtdava 
                                WITH FRAME f_promiss_aval_cab.
                       
                       FOR EACH tt-avais-ctr NO-LOCK:
                       
                           DISP STREAM str_limcre 
                                tt-avais-ctr.nmdavali  tt-avais-ctr.cpfavali
                                tt-avais-ctr.dsdocava  tt-avais-ctr.dsendav1
                                tt-avais-ctr.dsendav2  tt-avais-ctr.dsendav3
                                tt-avais-ctr.nmconjug  tt-avais-ctr.nrcpfcjg  
                                tt-avais-ctr.dsdoccjg
                                WITH FRAME f_promis_aval.
                       
                          DOWN STREAM str_limcre WITH FRAME f_promis_aval.
                       
                       END.
                       
                       VIEW STREAM str_limcre FRAME f_linhas.
                   END.
            
               OUTPUT STREAM str_limcre CLOSE.

               IF  par_idimpres = 1  OR   /** Completa **/
                   par_idimpres = 2  THEN /** Contrato **/
                   RUN junta_arquivos(INPUT crapcop.dsdircop,
                                      INPUT aux_nmarquiv + ".ex", /*contratos */
                                      INPUT "/usr/coop/" + crapcop.dsdircop + 
                                            "/rl/" + aux_nmdoarqv + ".ex", /* cet */
                                     INPUT par_dsiduser,
                                     INPUT tt-dados-ctr.inpessoa, 
                                     OUTPUT aux_nmarqimp,
                                     OUTPUT aux_nmarqpdf).

           END.

      IF  par_flgemail      OR    /** Enviar proposta via e-mail **/
          par_idorigem = 5  THEN  /** Ayllos Web **/
          DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "".
      
              DO WHILE TRUE:
      
                  RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                      SET h-b1wgen0024.
              
                  IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                      DO:
                          ASSIGN aux_dscritic = "Handle invalido para BO " +
                                                "b1wgen0024.".
                           LEAVE Gera_Impressao.
                      END.
                  
                  RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                          INPUT aux_nmarqpdf).
      
                  /** Copiar pdf para visualizacao no Ayllos WEB **/
                  IF  par_idorigem = 5  THEN
                      DO:
                          IF  SEARCH(aux_nmarqpdf) = ?  THEN
                              DO:
                                  ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                                        " a impressao.".
                                   LEAVE Gera_Impressao.                     
                              END.
                          
                          UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                             '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                             ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                             '/temp/" 2>/dev/null').
                      END.
    
                   /** Enviar proposta para o PAC Sede via e-mail **/
                   IF  par_flgemail  THEN
                       DO:
                           RUN executa-envio-email IN h-b1wgen0024 
                                                  (INPUT par_cdcooper, 
                                                   INPUT par_cdagecxa, 
                                                   INPUT par_nrdcaixa, 
                                                   INPUT par_cdopecxa, 
                                                   INPUT par_nmdatela, 
                                                   INPUT par_idorigem, 
                                                   INPUT par_dtmvtolt, 
                                                   INPUT 517, 
                                                   INPUT aux_nmarqimp, 
                                                   INPUT aux_nmarqpdf,
                                                   INPUT par_nrdconta, 
                                                   INPUT 1, 
                                                   INPUT par_nrctrlim, 
                                                  OUTPUT TABLE tt-erro).
                   
                           IF   RETURN-VALUE <> "OK"  THEN
                                LEAVE Gera_Impressao.

                       END.

                LEAVE.

              END. /** Fim do DO WHILE TRUE **/

              IF  VALID-HANDLE(h-b1wgen0024)  THEN
                  DELETE PROCEDURE h-b1wgen0024.
            
              IF  aux_dscritic <> ""  THEN
                  DO:
                      IF  aux_nmarquiv <> "" THEN
                          UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
                  
                      LEAVE Gera_Impressao.
                  END.
                  
              IF  par_idorigem = 5  THEN
                  DO:
                      IF  aux_nmarquiv <> "" THEN
                          UNIX SILENT VALUE ("rm " + aux_nmarquiv + " 2>/dev/null").
                  
                      /* Remover arquivo gerado do cet */
                      IF  aux_nmdoarqv <> "" THEN
                          UNIX SILENT VALUE ("rm " + "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                                             aux_nmdoarqv + " 2>/dev/null").
                  END.
              ELSE
                  UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null").
            
          END.                                                                      
                                                      
       ASSIGN par_nmarqimp = aux_nmarqimp
              par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

       ASSIGN aux_flgtrans = TRUE.

    END.

    IF   NOT aux_flgtrans   THEN /* Se deu erro */
         DO:
             IF   NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagecxa,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
                 
             IF par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdopecxa,
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
                            INPUT par_cdopecxa,
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


PROCEDURE imprime-scr-consultas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcon AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctacon AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcon AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_iddoaval AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_nmarquiv AS CHAR                                   NO-UNDO.
    DEF  VAR aux_dsdlinha AS CHAR                                   NO-UNDO. 
    DEF  VAR h-b1wgen0191 AS HANDLE                                 NO-UNDO.

    
    RUN sistema/generico/procedures/b1wgen0191.p
        PERSISTENT SET h-b1wgen0191.

    RUN Imprime_Dados_Proposta IN h-b1wgen0191 (INPUT par_cdcooper, 
                                                INPUT par_cdoperad,
                                                INPUT par_nmdatela,
                                                INPUT par_idorigem,
                                                INPUT par_dtmvtolt,
                                                INPUT par_nrdconta,
                                                INPUT 3, /* inprodut */
                                                INPUT par_nrctrato,
                                                INPUT par_cdtipcon,
                                                INPUT par_nrctacon,
                                                INPUT par_nrcpfcon,
                                                INPUT par_iddoaval,
                                               OUTPUT aux_nmarquiv,
                                               OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen0191.

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "OK".

    /* Importar o arquivo gerado e jogar no da proposta  */
    INPUT STREAM str_4 FROM VALUE (aux_nmarquiv) NO-ECHO.
                     
    /* Ler linha a linha e imprimir na proposta */
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        IF  LINE-COUNTER(str_limcre) + 1 > PAGE-SIZE(str_limcre)   THEN
        DO:
            PAGE STREAM str_limcre.
        END.

        IMPORT STREAM str_4 UNFORMATTED aux_dsdlinha.

        PUT STREAM str_limcre aux_dsdlinha FORMAT "x(137)" SKIP.

    END.

    INPUT STREAM str_4 CLOSE.
                                                           
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/**    Procedure para atualizar a observacao da proposta   **/
/******************************************************************************/
PROCEDURE altera-observacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsobserv AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_contador AS INTE                                   NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    

    DO WHILE TRUE:
    
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "".

        /* Lock da tabela crapprp */
        DO aux_contador = 1 TO 10:
  
           FIND crapprp WHERE crapprp.cdcooper = par_cdcooper   AND
                              crapprp.nrdconta = par_nrdconta   AND
                              crapprp.tpctrato = 1              AND
                              crapprp.nrctrato = par_nrctrlim 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF  NOT AVAIL crapprp   THEN
               IF   LOCKED crapprp   THEN
                    DO:
                        aux_cdcritic = 77.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE 
                    DO:
                        ASSIGN aux_cdcritic = 55.
                        LEAVE.
                    END.

           ASSIGN aux_cdcritic = 0
                  aux_dscritic = "".
           LEAVE.

        END.
   
        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> ""   THEN
             LEAVE.

        /* Atualizar a observacao do contrato */
        ASSIGN crapprp.dsobserv[1] = par_dsobserv.
        LEAVE.

    END.

    IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
    END.
    
    RETURN "OK".

END PROCEDURE.


/*............................ PROCEDURES INTERNAS ...........................*/


/******************************************************************************/
/**              Procedure para obter registro do limite atual               **/
/******************************************************************************/
PROCEDURE obtem-registro-limite:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flpropos AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR h-b1wgen0001 AS HANDLE                                  NO-UNDO.
    
    DEF VAR aux_insitlim AS INTE                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT 
        SET h-b1wgen0001.
        
    IF  VALID-HANDLE(h-b1wgen0001)  THEN
        DO:
            RUN ver_capital IN h-b1wgen0001 (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_cdagenci, 
                                             INPUT par_nrdcaixa,
                                             INPUT 0,
                                             INPUT par_dtmvtolt,
                                             INPUT "B1WGEN0019",
                                             INPUT 5, /** ORIGEM **/
                                            OUTPUT TABLE tt-erro).
     
            DELETE PROCEDURE h-b1wgen0001.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_cdcritic = tt-erro.cdcritic
                               aux_dscritic = tt-erro.dscritic.

                    RETURN "NOK".
                END.
        END.
    
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
                                   
            RETURN "NOK".
        END.

    IF  par_flpropos  THEN
        aux_insitlim = 1.
    ELSE
        DO:
            IF  crapass.vllimcre > 0  THEN
                aux_insitlim = 2.
            ELSE
                aux_insitlim = 3.
        END.
        
    FIND LAST craplim WHERE craplim.cdcooper = par_cdcooper AND
                            craplim.nrdconta = par_nrdconta AND
                            craplim.tpctrlim = 1            AND
                            craplim.insitlim = aux_insitlim 
                            NO-LOCK USE-INDEX craplim2 NO-ERROR.

    RETURN "OK".                          
    
END PROCEDURE.


/******************************************************************************/
/**              Procedure para atualizar cadastro do associado              **/
/******************************************************************************/
PROCEDURE atualiza-registro-associado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vllimite AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_inbaslim AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro. 

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqdig AS INTE                                    NO-UNDO.
    
    DEF BUFFER crabreq FOR crapreq.
    
    EMPTY TEMP-TABLE tt-erro.

    DO aux_contador = 1 TO 10:
        
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        ASSIGN aux_dscritic = "".
            
        IF  NOT AVAILABLE crapass  THEN
            DO:
                IF  LOCKED crapass  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Registro de associado esta " +
                                              "sendo alterado. Tente " +
                                              "novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    ASSIGN aux_cdcritic = 9
                           aux_dscritic = " ".
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
                               
            RETURN "NOK".
        END.
        
    IF  par_cdtipcta > 0  THEN
        DO:
            /** Altera tipo de conta nas requisicoes **/
            FOR EACH crabreq WHERE crabreq.cdcooper = par_cdcooper     AND 
                                   crabreq.cdagenci = crapass.cdagenci AND
                                   crabreq.nrdconta = par_nrdconta 
                                   NO-LOCK:
                
                DO aux_contador = 1 TO 10:                          
                    
                    FIND crapreq WHERE RECID(crapreq) = RECID(crabreq)
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    ASSIGN aux_dscritic = "".
                    
                    IF  NOT AVAILABLE crapreq  THEN
                        DO:
                            IF  LOCKED crapreq  THEN
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Registro de " +
                                                          "requisicao esta " +
                                                          "sendo alterado. " +
                                                          "Tente novamente.".
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Registro de requisicao" +
                                                      " nao encontrado.".
                        END.
                    ELSE
                        ASSIGN crapreq.cdtipcta = par_cdtipcta.
               
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
                               
                        RETURN "NOK".
                    END.
                    
            END. /** Fim do FOR EACH crabreq **/
            
            /** Gera registro de alteracao de conta **/
            DO aux_contador = 1 TO 10:

                FIND crapact WHERE crapact.cdcooper = par_cdcooper AND
                                   crapact.nrdconta = par_nrdconta AND
                                   crapact.dtalttct = par_dtmvtolt 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                ASSIGN aux_dscritic = "".
                
                IF  NOT AVAILABLE crapact  THEN
                    DO:
                        IF  LOCKED crapact  THEN
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Registro de alteracao " +
                                                      " de conta esta sendo " +
                                                      "alterado. Tente " +
                                                      "novamente.".
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE
                            DO:
                                CREATE crapact.
                                ASSIGN crapact.nrdconta = par_nrdconta
                                       crapact.dtalttct = par_dtmvtolt
                                       crapact.cdtctant = crapass.cdtipcta
                                       crapact.cdtctatu = par_cdtipcta
                                       crapact.cdcooper = par_cdcooper
                                       crapass.dtatipct = par_dtmvtolt.
                                VALIDATE crapact.
                            END.
                    END.
                ELSE
                    DO:
                        ASSIGN crapact.cdtctatu = par_cdtipcta.

                        IF  crapact.cdtctant = crapact.cdtctatu  THEN
                            DELETE crapact.
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
                               
                    RETURN "NOK".
                END.    
                
            DO aux_contador = 1 TO 10:
                
                FIND crapneg WHERE crapneg.cdcooper = par_cdcooper AND
                                   crapneg.nrdconta = par_nrdconta AND
                                   crapneg.dtiniest = par_dtmvtolt AND
                                   crapneg.cdhisest = 2
                                   USE-INDEX crapneg2 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                ASSIGN aux_dscritic = "".
                
                IF  NOT AVAILABLE crapneg   THEN
                    DO:
                        
                        IF  LOCKED crapneg  THEN
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Registro de controle " +
                                                      "esta sendo alterado. " +
                                                      "Tente novamente.".
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE
                            DO:
                                /* Busca a proxima sequencia */
                                RUN STORED-PROCEDURE pc_sequence_progress
                                aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPNEG"
                                                                    ,INPUT "NRSEQDIG"
                                                                    ,INPUT STRING(par_cdcooper) + ";"
                                                                         + STRING(par_nrdconta)
                                                                    ,INPUT "N"
                                                                    ,"").
                              
                                CLOSE STORED-PROC pc_sequence_progress
                                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                                        
                                ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
                                                      WHEN pc_sequence_progress.pr_sequence <> ?.

                                CREATE crapneg.
                                ASSIGN crapneg.cdhisest = 2
                                       crapneg.cdobserv = 0
                                       crapneg.dtiniest = par_dtmvtolt
                                       crapneg.nrdconta = par_nrdconta
                                       crapneg.nrdctabb = 0
                                       crapneg.nrdocmto = 0
                                       crapneg.nrseqdig = aux_nrseqdig
                                       crapneg.qtdiaest = 0
                                       crapneg.vlestour = 0
                                       crapneg.vllimcre = crapass.vllimcre
                                       crapneg.cdtctant = crapass.cdtipcta
                                       crapneg.cdtctatu = par_cdtipcta
                                       crapneg.dtfimest = ?
                                       crapneg.cdoperad = par_cdoperad
                                       crapneg.cdbanchq = 0
                                       crapneg.cdagechq = 0
                                       crapneg.nrctachq = 0
                                       crapneg.cdcooper = par_cdcooper.
                                VALIDATE crapneg.
                            END.
                    END.
                ELSE
                    DO:
                        ASSIGN crapneg.cdtctatu = par_cdtipcta.

                        IF  crapneg.cdtctant = crapneg.cdtctatu  THEN
                            DELETE crapneg.
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
                               
                    RETURN "NOK".
                END.
        END.
                        
    ASSIGN crapass.vllimcre = par_vllimite
           crapass.tplimcre = par_inbaslim              
           crapass.dtultlcr = par_dtmvtolt.
    
    IF par_cdtipcta > 0 THEN       
       ASSIGN crapass.cdtipcta = par_cdtipcta.
            
    VALIDATE crapass.
    
    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**    Procedure para carregar dados para impressao do contrato do limite    **/
/******************************************************************************/
PROCEDURE obtem-dados-contrato:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-dados-ctr.
    DEF OUTPUT PARAM TABLE FOR tt-repres-ctr.
    DEF OUTPUT PARAM TABLE FOR tt-avais-ctr.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_nmexcop1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmexcop2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsvllim1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsvllim2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsstring AS CHAR                                    NO-UNDO.
    DEF VAR aux_strfinal AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsendcop AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmcidpac AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsencfi1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsencfi2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsencfi3 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsencfi4 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdtmvt1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdtmvt2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsextens AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsbranco AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsvlnpr1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsvlnpr2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsmesref AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_contado1 AS INTE                                    NO-UNDO.
    DEF VAR aux_contado2 AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdifere AS INTE                                    NO-UNDO.
    DEF VAR aux_qtdfinal AS INTE                                    NO-UNDO.
    DEF VAR aux_tpregist AS INTE                                    NO-UNDO. 

    DEF VAR aux_txcetano AS DECI                                    NO-UNDO.
    DEF VAR aux_txcetmes AS DECI                                    NO-UNDO.
    DEF VAR aux_cdorgexp AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0052b AS HANDLE                                 NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    
    EMPTY TEMP-TABLE tt-dados-ctr.
    EMPTY TEMP-TABLE tt-repres-ctr.
    EMPTY TEMP-TABLE tt-avais-ctr.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsmesref = "Janeiro,Fevereiro,Marco,Abril,Maio,Junho,Julho," +
                          "Agosto,Setembro,Outubro,Novembro,Dezembro".
    
    DO WHILE TRUE:
    
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "".
    
        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE crapcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651.
                LEAVE.
            END.
                
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE crapass  THEN
            DO: 
                ASSIGN aux_cdcritic = 9.
                LEAVE.
            END.
            
        FIND craplim WHERE craplim.cdcooper = par_cdcooper AND
                           craplim.nrdconta = par_nrdconta AND
                           craplim.nrctrlim = par_nrctrlim AND
                           craplim.tpctrlim = 1            NO-LOCK NO-ERROR.
                       
        IF  NOT AVAILABLE craplim  THEN
            DO: 
                ASSIGN aux_cdcritic = 105.
                LEAVE.
            END.
                   
        FIND crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                           crapenc.nrdconta = par_nrdconta AND
                           crapenc.idseqttl = 1            AND
                           crapenc.cdseqinc = 1            NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapenc  THEN
            DO: 
                ASSIGN aux_dscritic = "10 - Endereco nao cadastrado.".
                LEAVE.
            END.
            
        FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                           crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.
                           
        IF  NOT AVAILABLE crapope  THEN
            DO: 
                ASSIGN aux_dscritic = "Operador nao cadastrado.".
                LEAVE.
            END.
                               
        LEAVE.
        
    END. /** Fim do DO WHILE TRUE **/
    
    IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.
        
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.    

       

    RUN valor-extenso IN h-b1wgen9999 (INPUT craplim.vllimite , 
                                       INPUT 20,
                                       INPUT 69,
                                       INPUT "M",
                                      OUTPUT aux_dsvllim1, 
                                      OUTPUT aux_dsvllim2).
          
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen9999.
            
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = aux_dsvllim1.
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".       
        END.

    IF  DAY(par_dtmvtolt) > 1  THEN
        DO:
            RUN valor-extenso IN h-b1wgen9999 (INPUT DAY(par_dtmvtolt), 
                                               INPUT 50,
                                               INPUT 50, 
                                               INPUT "I",
                                              OUTPUT aux_dsextens, 
                                              OUTPUT aux_dsbranco).

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    DELETE PROCEDURE h-b1wgen9999.
            
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = aux_dsextens.
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
            
                    RETURN "NOK".       
                END.
        
            ASSIGN aux_dsextens = aux_dsextens + " DIAS DO MES DE " +
                                  CAPS(ENTRY(MONTH(par_dtmvtolt),aux_dsmesref)) 
                                  + " DE ".  

            RUN valor-extenso IN h-b1wgen9999 (INPUT YEAR(par_dtmvtolt),
                                               INPUT 68 - LENGTH(aux_dsextens),
                                               INPUT 44, 
                                               INPUT "I",
                                              OUTPUT aux_dsdtmvt1, 
                                              OUTPUT aux_dsdtmvt2).

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    DELETE PROCEDURE h-b1wgen9999.
            
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = aux_dsdtmvt1.
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
            
                    RETURN "NOK".       
                END.

            ASSIGN aux_dsdtmvt1 = aux_dsextens + aux_dsdtmvt1
                   aux_dsdtmvt2 = aux_dsdtmvt2.
                   
            IF  par_idorigem = 5  THEN /** Ayllos WEB **/
                ASSIGN aux_dsdtmvt1 = aux_dsdtmvt1 + 
                                      FILL("*",78 - LENGTH(aux_dsdtmvt1))
                       aux_dsdtmvt2 = aux_dsdtmvt2 + 
                                      FILL("*",8 - LENGTH(aux_dsdtmvt2)).
            ELSE
                ASSIGN aux_dsdtmvt1 = aux_dsdtmvt1 + 
                                      FILL("*",68 - LENGTH(aux_dsdtmvt1))
                       aux_dsdtmvt2 = aux_dsdtmvt2 + 
                                      FILL("*",44 - LENGTH(aux_dsdtmvt2)).
        END.
    ELSE
        DO:            
            ASSIGN aux_dsextens = "PRIMEIRO DIA DO MES DE " +
                                  CAPS(ENTRY(MONTH(par_dtmvtolt),aux_dsmesref))
                                  + " DE ".

            RUN valor-extenso IN h-b1wgen9999 (INPUT YEAR(par_dtmvtolt),
                                               INPUT 68 - LENGTH(aux_dsextens),
                                               INPUT 44, 
                                               INPUT "I",
                                              OUTPUT aux_dsdtmvt1, 
                                              OUTPUT aux_dsdtmvt2).

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    DELETE PROCEDURE h-b1wgen9999.
            
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = aux_dsdtmvt1.
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
            
                    RETURN "NOK".       
                END.

            ASSIGN aux_dsdtmvt1 = aux_dsextens + aux_dsdtmvt1 
                   aux_dsdtmvt2 = aux_dsdtmvt2. 
                   
            IF  par_idorigem = 5  THEN /** Ayllos WEB **/
                ASSIGN aux_dsdtmvt1 = aux_dsdtmvt1 + 
                                      FILL("*",78 - LENGTH(aux_dsdtmvt1))
                       aux_dsdtmvt2 = aux_dsdtmvt2 + 
                                      FILL("*",8 - LENGTH(aux_dsdtmvt2)).
            ELSE
                ASSIGN aux_dsdtmvt1 = aux_dsdtmvt1 + 
                                      FILL("*",68 - LENGTH(aux_dsdtmvt1))
                       aux_dsdtmvt2 = aux_dsdtmvt2 + 
                                      FILL("*",44 - LENGTH(aux_dsdtmvt2)).
        END.

    RUN valor-extenso IN h-b1wgen9999 (INPUT craplim.vllimite,
                                       INPUT 22, /*45*/
                                       INPUT 73,
                                       INPUT "M",
                                      OUTPUT aux_dsvlnpr1,
                                      OUTPUT aux_dsvlnpr2).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen9999.
            
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = aux_dsvlnpr1.
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
           
            RETURN "NOK".       
        END.
                    
    RUN divide-nome-coop IN h-b1wgen9999 (INPUT crapcop.nmextcop,
                                         OUTPUT aux_nmexcop1,
                                         OUTPUT aux_nmexcop2).
        
    DELETE PROCEDURE h-b1wgen9999.

    /** Endereco da cooperativa **/
    ASSIGN aux_strfinal = ""
           aux_dsstring = crapcop.dsendcop
           aux_qtdfinal = LENGTH(crapcop.dsendcop).
        
    DO aux_contado1 = 1 TO LENGTH(aux_dsstring):

        ASSIGN aux_nrdifere = LENGTH(aux_dsstring) - aux_contado1.

        IF  SUBSTR(aux_dsstring,1,aux_nrdifere) = " "  THEN
            ASSIGN aux_qtdfinal = aux_qtdfinal - 1.
        ELSE   
            LEAVE. 
  
    END. /** Fim do DO ... TO **/     

    ASSIGN aux_strfinal = SUBSTR(aux_dsstring,1,aux_qtdfinal) + ", " + 
                          STRING(crapcop.nrendcop,"z,zz9") + ", ".

    DO aux_contado2 = 1 TO 2:

        ASSIGN aux_dsstring = IF  aux_contado2 = 1  THEN 
                                  crapcop.nmbairro
                              ELSE
                                  TRIM(crapcop.nmcidade)
               aux_qtdfinal = IF  aux_contado2 = 1  THEN 
                                  LENGTH(crapcop.nmbairro)
                              ELSE
                                  LENGTH(crapcop.nmcidade).
                            
        DO aux_contado1 = 1 TO LENGTH(aux_dsstring):

            ASSIGN aux_nrdifere = LENGTH(aux_dsstring) - aux_contado1.

            IF  SUBSTR(aux_dsstring,1,aux_nrdifere) = " "  THEN
                ASSIGN aux_qtdfinal = aux_qtdfinal - 1.
            ELSE   
                LEAVE. 
     
        END.      

        ASSIGN aux_strfinal = aux_strfinal + 
                              SUBSTR(aux_dsstring,1,aux_qtdfinal) + ", ".
      
    END. /** Fim do DO ... TO **/      

    ASSIGN aux_dsendcop = aux_strfinal + crapcop.cdufdcop + ".".
    

    /** Encargos **/  
    DO aux_contado1 = 1 TO NUM-ENTRIES(craplim.dsencfin[1]," "):

        ASSIGN aux_dsencfi4 = aux_dsencfi4 + " " + 
                              ENTRY(aux_contado1,craplim.dsencfin[1]," ").
      
        IF  LENGTH(aux_dsencfi4) > 39  THEN
            LEAVE.
      
      
    END. /** Fim do DO ... TO **/
                         
    IF  aux_contado1 <= NUM-ENTRIES(craplim.dsencfin[1]," ")  THEN
        ASSIGN aux_dsencfi2 = SUBSTR(craplim.dsencfin[1], 40, 
                                     LENGTH(craplim.dsencfin[1])).
      
    ASSIGN aux_dsencfi1 = TRIM(aux_dsencfi4)
           aux_dsencfi4 = "".

   
    IF (SUBSTR(craplim.dsencfin[1],50) = " " AND
        SUBSTR(craplim.dsencfin[2],50) = " " ) THEN
        ASSIGN aux_dsencfi2 = (aux_dsencfi2  + " " + craplim.dsencfin[2] + " " + 
                               craplim.dsencfin[3]).
    ELSE
       IF (SUBSTR(craplim.dsencfin[1],50) <> " " AND
           SUBSTR(craplim.dsencfin[2],50) <> " " ) THEN
           ASSIGN aux_dsencfi2 = (aux_dsencfi2  + craplim.dsencfin[2] + 
                                  craplim.dsencfin[3]).
       ELSE
          IF  SUBSTR(craplim.dsencfin[1],50) = " " THEN
              ASSIGN aux_dsencfi2 = (aux_dsencfi2  + " " + craplim.dsencfin[2] +  
                                     craplim.dsencfin[3]).
          ELSE
             IF  SUBSTR(craplim.dsencfin[2],50) = " " THEN
                 ASSIGN aux_dsencfi2 = (aux_dsencfi2  + craplim.dsencfin[2] + " " +
                                        craplim.dsencfin[3]).
     

   DO aux_contado1 = 1 TO NUM-ENTRIES(aux_dsencfi2," "):
        
        ASSIGN aux_dsencfi4 = aux_dsencfi4 + " " + 
                              ENTRY(aux_contado1,aux_dsencfi2," ").
         
        IF  LENGTH(aux_dsencfi4) > 70  THEN
            LEAVE.

        
    END. /** Fim do DO ... TO **/
   
    IF  aux_contado1 <= NUM-ENTRIES(aux_dsencfi2," ")  THEN
        ASSIGN aux_dsencfi3 = TRIM(SUBSTR(aux_dsencfi2, 71,
                                     LENGTH(aux_dsencfi2))).

    ASSIGN aux_dsencfi2 = TRIM(aux_dsencfi4). 

                
    FIND crapage WHERE crapage.cdcooper = par_cdcooper     AND
                       crapage.cdagenci = crapass.cdagenci 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapage  THEN
        ASSIGN aux_nmcidpac = "____________________".
    ELSE
        ASSIGN aux_nmcidpac = crapage.nmcidade.           

    /* Para pessoa juridica - faturamento unico cliente */
    FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper AND
                       crapjfn.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    FIND craplrt WHERE craplrt.cdcooper = par_cdcooper AND
                       craplrt.cddlinha = craplim.cddlinha
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL craplrt THEN
        RETURN "NOK".

    /* Chamar rorina para calculo do cet */
    RUN calcula_cet_limites( INPUT par_cdcooper,
                             INPUT par_dtmvtolt,
                             INPUT "atenda",
                             INPUT INT(par_nrdconta),
                             INPUT INT(crapass.inpessoa),
                             INPUT 1, /* p-cdusolcr */
                             INPUT INT(craplim.cddlinha),
                             INPUT 1, /*1-Chq Esp./ 2-Desc Chq./ 3-Desc Tit*/
                             INPUT INT(craplim.nrctrlim),
                             INPUT (IF craplim.dtrenova <> ? THEN
                                       craplim.dtrenova
                                    ELSE IF craplim.dtinivig <> ? THEN
                                       craplim.dtinivig
                                    ELSE par_dtmvtolt),
                             INPUT INT(craplim.qtdiavig),
                             INPUT DEC(craplim.vllimite),
                             INPUT DEC(craplrt.txmensal),
                            OUTPUT aux_txcetano, 
                            OUTPUT aux_txcetmes,
                            OUTPUT aux_dscritic ).
    
    IF  RETURN-VALUE <> "OK" THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    CREATE tt-dados-ctr.
    ASSIGN tt-dados-ctr.nmextcop = crapcop.nmextcop
           tt-dados-ctr.nmrescop = crapcop.nmrescop
           tt-dados-ctr.nmexcop1 = aux_nmexcop1
           tt-dados-ctr.nmexcop2 = aux_nmexcop2
           tt-dados-ctr.nrdocnpj = STRING(STRING(crapcop.nrdocnpj,
                                   "99999999999999"),"xx.xxx.xxx/xxxx-xx")
           tt-dados-ctr.dsendcop = aux_dsendcop
           tt-dados-ctr.nrdconta = crapass.nrdconta
           tt-dados-ctr.nmprimtl = crapass.nmprimtl
           tt-dados-ctr.inpessoa = crapass.inpessoa
           tt-dados-ctr.endeass1 = crapenc.dsendere + " " + 
                                   TRIM(STRING(crapenc.nrendere,"zzz,zzz"))
           tt-dados-ctr.endeass2 = TRIM(crapenc.nmbairro)
           tt-dados-ctr.endeass3 = STRING(crapenc.nrcepend,"99999,999") + 
                                   " - " + TRIM(crapenc.nmcidade) + "/" +
                                   crapenc.cdufende
           tt-dados-ctr.cdagenci = crapass.cdagenci
           tt-dados-ctr.nmcidpac = aux_nmcidpac
           tt-dados-ctr.nrctrlim = craplim.nrctrlim
           tt-dados-ctr.dsctrlim = TRIM(STRING(craplim.nrctrlim,"z,zzz,zz9")) + 
                                   "/001"
           tt-dados-ctr.vllimite = craplim.vllimite
           tt-dados-ctr.qtdiavig = craplim.qtdiavig
           tt-dados-ctr.dtinivig = craplim.dtinivig
           tt-dados-ctr.dtfimvig = craplim.dtfimvig
           tt-dados-ctr.dtrenova = craplim.dtrenova
           tt-dados-ctr.cddlinha = craplim.cddlinha
           tt-dados-ctr.dsencfi1 = aux_dsencfi1 
           tt-dados-ctr.dsencfi2 = aux_dsencfi2
           tt-dados-ctr.dsencfi3 = aux_dsencfi3
           tt-dados-ctr.dsvllim1 = aux_dsvllim1
           tt-dados-ctr.dsvllim2 = aux_dsvllim2
           tt-dados-ctr.dsemsctr = SUBSTR(crapage.nmcidade,1,15) + ", " +
                                   STRING(DAY(par_dtmvtolt),"99") + 
                                   " de " +
                                   ENTRY(MONTH(par_dtmvtolt),aux_dsmesref) +
                                   " de " +
                                   STRING(YEAR(par_dtmvtolt),"9999")
           tt-dados-ctr.nmoperad = "Operador: " + TRIM(crapope.nmoperad)
           tt-dados-ctr.ddmvtolt = DAY(par_dtmvtolt)
           tt-dados-ctr.aamvtolt = YEAR(par_dtmvtolt)
           tt-dados-ctr.dsdtmvt1 = aux_dsdtmvt1
           tt-dados-ctr.dsdtmvt2 = aux_dsdtmvt2
           tt-dados-ctr.dsvlnpr1 = aux_dsvlnpr1
           tt-dados-ctr.dsvlnpr2 = aux_dsvlnpr2
           tt-dados-ctr.dsmesref = ENTRY(MONTH(par_dtmvtolt),aux_dsmesref)
           tt-dados-ctr.dsdmoeda = "R$"
           tt-dados-ctr.txcetano = aux_txcetano
           tt-dados-ctr.txcetmes = aux_txcetmes
        
           /* Campos para o Rating */ 
           tt-dados-ctr.nrgarope = craplim.nrgarope
           tt-dados-ctr.nrinfcad = craplim.nrinfcad
           tt-dados-ctr.nrliquid = craplim.nrliquid
           tt-dados-ctr.nrpatlvr = craplim.nrpatlvr
           tt-dados-ctr.vltotsfn = craplim.vltotsfn
           tt-dados-ctr.perfatcl = crapjfn.perfatcl WHEN AVAILABLE crapjfn.

    IF  crapass.inpessoa > 1  THEN
        DO:
            ASSIGN tt-dados-ctr.nrcpfcgc = "CNPJ: " +
                                           STRING(STRING(crapass.nrcpfcgc,
                                                  "99999999999999"),
                                                  "xx.xxx.xxx/xxxx-xx").
                                     
            FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                                   crapavt.tpctrato = 6            AND
                                   crapavt.nrdconta = par_nrdconta NO-LOCK:
                                     
                CREATE tt-repres-ctr.
                ASSIGN tt-repres-ctr.nmrepres = crapavt.nmdavali
                       tt-repres-ctr.nrcpfrep = STRING(STRING(crapavt.nrcpfcgc,
                                                       "99999999999"),
                                                       "xxx.xxx.xxx-xx")
                       tt-repres-ctr.dsdocrep = crapavt.nrdocava.
                 
                ASSIGN tt-repres-ctr.cdoedrep = "".  
                IF crapavt.idorgexp <> 0 THEN 
                DO:
                  /* Retornar orgao expedidor */
                  IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                      RUN sistema/generico/procedures/b1wgen0052b.p 
                          PERSISTENT SET h-b1wgen0052b.
                  
                  RUN busca_org_expedidor IN h-b1wgen0052b 
                                   (INPUT crapavt.idorgexp,
                                    OUTPUT tt-repres-ctr.cdoedrep,
                                    OUTPUT aux_cdcritic, 
                                    OUTPUT aux_dscritic).

                  DELETE PROCEDURE h-b1wgen0052b. 
                  
                  IF  RETURN-VALUE = "NOK" THEN
                  DO:
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1,            /** Sequencia **/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).

                      RETURN "NOK".
                  END.
                END.
                           
                IF  crapavt.nrdctato <> 0  THEN
                    DO:
                        FIND crabass WHERE 
                             crabass.cdcooper = par_cdcooper     AND
                             crabass.nrdconta = crapavt.nrdctato 
                             NO-LOCK NO-ERROR.
                                 
                        IF  AVAILABLE crabass  THEN
                            ASSIGN tt-repres-ctr.nmrepres = crabass.nmprimtl
                                   tt-repres-ctr.nrcpfrep = STRING(STRING(
                                                            crabass.nrcpfcgc,
                                                            "99999999999"),
                                                            "xxx.xxx.xxx-xx")
                                   tt-repres-ctr.dsdocrep = crabass.nrdocptl.
                            
                            ASSIGN tt-repres-ctr.cdoedrep = "".       
                            IF crabass.idorgexp <> 0 THEN
                            DO:
                              /* Retornar orgao expedidor */
                              IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                                  RUN sistema/generico/procedures/b1wgen0052b.p 
                                      PERSISTENT SET h-b1wgen0052b.
                              
                              RUN busca_org_expedidor IN h-b1wgen0052b 
                                                 (INPUT crabass.idorgexp,
                                                  OUTPUT tt-repres-ctr.cdoedrep,
                                                  OUTPUT aux_cdcritic, 
                                                  OUTPUT aux_dscritic).

                              DELETE PROCEDURE h-b1wgen0052b. 
                              
                              IF  RETURN-VALUE = "NOK" THEN
                              DO:
                                  RUN gera_erro (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT 1,            /** Sequencia **/
                                                 INPUT aux_cdcritic,
                                                 INPUT-OUTPUT aux_dscritic).

                                  RETURN "NOK".
                              END.      
                      END.
                    END.
                
            END. /** Fim do FOR EACH crapavt **/
        END.
    ELSE
        DO:
        
            ASSIGN aux_cdorgexp = "".
            IF crapass.idorgexp <> 0 THEN 
            DO:
            
              /* Retornar orgao expedidor */
              IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                  RUN sistema/generico/procedures/b1wgen0052b.p 
                     PERSISTENT SET h-b1wgen0052b.

              RUN busca_org_expedidor IN h-b1wgen0052b 
                                 (INPUT crapass.idorgexp,
                                  OUTPUT aux_cdorgexp,
                                  OUTPUT aux_cdcritic, 
                                  OUTPUT aux_dscritic).

              DELETE PROCEDURE h-b1wgen0052b. 
              
              IF  RETURN-VALUE = "NOK" THEN
              DO:
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).

                  RETURN "NOK".
              END.    
            END.

            ASSIGN tt-dados-ctr.nrcpfcgc = "CPF: " +
                                           STRING(STRING(crapass.nrcpfcgc,
                                                  "99999999999"),
                                                  "xxx.xxx.xxx-xx")
                   tt-dados-ctr.nrdrgass = TRIM(STRING(crapass.tpdocptl,
                                                       "xx")) + " " + 
                                           TRIM(STRING(crapass.nrdocptl,
                                                       "x(15)")) + " - " +
                                           TRIM(STRING(aux_cdorgexp,
                                                       "xxxxx")) + "/" +   
                                           TRIM(STRING(crapass.cdufdptl,"xx")).
        END.   

    IF  craplim.nrctaav1 <> 0  THEN
        DO:                    
            CREATE tt-avais-ctr.
            
            FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                               crapass.nrdconta = craplim.nrctaav1 
                               NO-LOCK NO-ERROR.
                                       
            IF  AVAILABLE crapass  THEN
                DO:
                    ASSIGN tt-avais-ctr.nmdavali = crapass.nmprimtl
                           tt-avais-ctr.dsdocava = crapass.tpdocptl + ": " +
                                                   crapass.nrdocptl.
                                                  
                    IF  crapass.inpessoa = 1  THEN
                        DO:
                            ASSIGN tt-avais-ctr.cpfavali = "CPF: " +
                                                           STRING(STRING(
                                                           crapass.nrcpfcgc,
                                                           "99999999999"),
                                                           "xxx.xxx.xxx-xx").
                                  
                            FIND crapcje WHERE 
                                 crapcje.cdcooper = par_cdcooper     AND
                                 crapcje.nrdconta = crapass.nrdconta AND
                                 crapcje.idseqttl = 1               
                                 NO-LOCK NO-ERROR.
                                
                            IF  AVAILABLE crapcje  THEN
                                DO:
                                    /* Verificar se existe o numero da conta do conjuge */
                                    IF crapcje.nrctacje > 0 THEN
                                        DO:
                                            /* Busca as informações do titular da conta */
                                            FIND crapttl WHERE crapttl.cdcooper = crapcje.cdcooper
                                                            AND crapttl.nrdconta = crapcje.nrctacje
                                                            AND crapttl.idseqttl = 1
                                                         NO-LOCK NO-ERROR.
        
                                            IF  AVAILABLE crapttl  THEN
                                                 ASSIGN tt-avais-ctr.nmconjug = crapttl.nmextttl
                                                        tt-avais-ctr.nrcpfcjg = "CPF: " +
                                                                 STRING(STRING(crapttl.nrcpfcgc,
                                                                 "99999999999"),"xxx.xxx.xxx-xx")
                                                        tt-avais-ctr.dsdoccjg = crapttl.tpdocttl +
                                                                    ": " + TRIM(crapttl.nrdocttl).
                                        END.
                                    ELSE
                                        ASSIGN tt-avais-ctr.nmconjug = crapcje.nmconjug
                                               tt-avais-ctr.nrcpfcjg = "CPF: " +
                                                        STRING(STRING(crapcje.nrcpfcjg,
                                                        "99999999999"),"xxx.xxx.xxx-xx")
                                               tt-avais-ctr.dsdoccjg = crapcje.tpdoccje + 
                                                           ": " + TRIM(crapcje.nrdoccje). 
                                END.
                            ELSE
                                ASSIGN tt-avais-ctr.nmconjug = FILL("_",40)
                                       tt-avais-ctr.nrcpfcjg = "CPF: " +
                                                               FILL("_",35)
                                       tt-avais-ctr.dsdoccjg = "CI: " + 
                                                               FILL("_",36).
                        END.                          
                    ELSE
                        ASSIGN tt-avais-ctr.cpfavali = "CNPJ: " +
                                                       STRING(STRING(
                                                       crapass.nrcpfcgc,
                                                       "99999999999999"),
                                                       "xx.xxx.xxx/xxxx-xx")
                               tt-avais-ctr.nmconjug = FILL("_",40)
                               tt-avais-ctr.nrcpfcjg = "CNPJ: " + FILL("_",34)
                               tt-avais-ctr.dsdoccjg = "CI: " + FILL("_",36). 
                                                      
                    FIND crapenc WHERE crapenc.cdcooper = par_cdcooper     AND
                                       crapenc.nrdconta = crapass.nrdconta AND
                                       crapenc.idseqttl = 1                AND
                                       crapenc.cdseqinc = 1 
                                       NO-LOCK NO-ERROR.
                           
                    IF  AVAILABLE crapenc  THEN
                        ASSIGN tt-avais-ctr.dsendav1 = 
                                       SUBSTR(crapenc.dsendere,1,32) + " " +
                                       TRIM(STRING(crapenc.nrendere,"zzz,zzz"))
                               tt-avais-ctr.dsendav2 = TRIM(crapenc.nmbairro)
                               tt-avais-ctr.dsendav3 = 
                                  STRING(crapenc.nrcepend,"99999,999") + " - " +
                                  TRIM(crapenc.nmcidade) + "/" + 
                                  crapenc.cdufende.   
                    ELSE
                        ASSIGN tt-avais-ctr.dsendav1 = ""
                               tt-avais-ctr.dsendav2 = ""
                               tt-avais-ctr.dsendav3 = "".
                END.                          
            ELSE
                ASSIGN tt-avais-ctr.nmdavali = "*** NAO CADASTRADO ***"
                       tt-avais-ctr.cpfavali = "CPF: " + FILL("_",35)
                       tt-avais-ctr.dsdocava = "CI: " + FILL("_",36)
                       tt-avais-ctr.nmconjug = FILL("_",40)
                       tt-avais-ctr.nrcpfcjg = "CPF: " + FILL("_",35)
                       tt-avais-ctr.dsdoccjg = "CI: " + FILL("_",36)
                       tt-avais-ctr.dsendav1 = FILL("_",40)
                       tt-avais-ctr.dsendav2 = FILL("_",40)
                       tt-avais-ctr.dsendav3 = FILL("_",40).
        END.
        
    IF  craplim.nrctaav2 <> 0  THEN
        DO:
            CREATE tt-avais-ctr.
            
            FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                               crapass.nrdconta = craplim.nrctaav2 
                               NO-LOCK NO-ERROR.
                                       
            IF  AVAILABLE crapass  THEN
                DO:
                    ASSIGN tt-avais-ctr.nmdavali = crapass.nmprimtl
                           tt-avais-ctr.dsdocava = crapass.tpdocptl + ": " +
                                                   crapass.nrdocptl.
                                                  
                    IF  crapass.inpessoa = 1  THEN
                        DO:
                            ASSIGN tt-avais-ctr.cpfavali = "CPF: " +
                                                           STRING(STRING(
                                                           crapass.nrcpfcgc,
                                                           "99999999999"),
                                                           "xxx.xxx.xxx-xx").
                                  
                            FIND crapcje WHERE 
                                 crapcje.cdcooper = par_cdcooper     AND
                                 crapcje.nrdconta = crapass.nrdconta AND
                                 crapcje.idseqttl = 1               
                                 NO-LOCK NO-ERROR.
                                
                            IF  AVAILABLE crapcje  THEN
                                DO:
                                    /* Verificar se existe o numero da conta do conjuge */
                                    IF crapcje.nrctacje > 0 THEN
                                        DO:
                                            /* Busca as informações do titular da conta */
                                            FIND crapttl WHERE crapttl.cdcooper = crapcje.cdcooper
                                                            AND crapttl.nrdconta = crapcje.nrctacje
                                                            AND crapttl.idseqttl = 1
                                                         NO-LOCK NO-ERROR.
        
                                            IF  AVAILABLE crapttl  THEN
                                                 ASSIGN tt-avais-ctr.nmconjug = crapttl.nmextttl
                                                        tt-avais-ctr.nrcpfcjg = "CPF: " +
                                                                 STRING(STRING(crapttl.nrcpfcgc,
                                                                 "99999999999"),"xxx.xxx.xxx-xx")
                                                        tt-avais-ctr.dsdoccjg = crapttl.tpdocttl +
                                                                    ": " + TRIM(crapttl.nrdocttl).
                                        END.
                                    ELSE
                                        ASSIGN tt-avais-ctr.nmconjug = crapcje.nmconjug
                                               tt-avais-ctr.nrcpfcjg = "CPF: " +
                                                        STRING(STRING(crapcje.nrcpfcjg,
                                                        "99999999999"),"xxx.xxx.xxx-xx")
                                               tt-avais-ctr.dsdoccjg = crapcje.tpdoccje + 
                                                           ": " + TRIM(crapcje.nrdoccje). 
                                END.
                            ELSE
                                ASSIGN tt-avais-ctr.nmconjug = FILL("_",40)
                                       tt-avais-ctr.nrcpfcjg = "CPF: " + 
                                                               FILL("_",35)
                                       tt-avais-ctr.dsdoccjg = "CI: " + 
                                                               FILL("_",36).
                        END.                          
                    ELSE
                        ASSIGN tt-avais-ctr.cpfavali = "CNPJ: " + 
                                                       STRING(STRING(
                                                       crapass.nrcpfcgc,
                                                       "99999999999999"),
                                                       "xx.xxx.xxx/xxxx-xx")
                               tt-avais-ctr.nmconjug = FILL("_",40)
                               tt-avais-ctr.nrcpfcjg = "CNPJ: " + FILL("_",34)
                               tt-avais-ctr.dsdoccjg = "CI: " + FILL("_",36). 
                                                      
                    FIND crapenc WHERE crapenc.cdcooper = par_cdcooper     AND
                                       crapenc.nrdconta = crapass.nrdconta AND
                                       crapenc.idseqttl = 1                AND
                                       crapenc.cdseqinc = 1 
                                       NO-LOCK NO-ERROR.
                           
                    IF  AVAILABLE crapenc  THEN
                        ASSIGN tt-avais-ctr.dsendav1 = 
                                       SUBSTR(crapenc.dsendere,1,32) + " " +
                                       TRIM(STRING(crapenc.nrendere,"zzz,zzz"))
                               tt-avais-ctr.dsendav2 = TRIM(crapenc.nmbairro)
                               tt-avais-ctr.dsendav3 = 
                                  STRING(crapenc.nrcepend,"99999,999") + " - " +
                                  TRIM(crapenc.nmcidade) + "/" + 
                                  crapenc.cdufende.
                    ELSE
                        ASSIGN tt-avais-ctr.dsendav1 = ""
                               tt-avais-ctr.dsendav2 = ""
                               tt-avais-ctr.dsendav3 = "".
                END.                          
            ELSE
                ASSIGN tt-avais-ctr.nmdavali = "*** NAO CADASTRADO ***"
                       tt-avais-ctr.cpfavali = "CPF: " + FILL("_",35)
                       tt-avais-ctr.dsdocava = "CI: " + FILL("_",36)
                       tt-avais-ctr.nmconjug = FILL("_",40)
                       tt-avais-ctr.nrcpfcjg = "CPF: " + FILL("_",35)
                       tt-avais-ctr.dsdoccjg = "CI: " + FILL("_",36)
                       tt-avais-ctr.dsendav1 = FILL("_",40)
                       tt-avais-ctr.dsendav2 = FILL("_",40)
                       tt-avais-ctr.dsendav3 = FILL("_",40).
        END.
    
    FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper     AND
                           crapavt.nrdconta = par_nrdconta     AND
                           crapavt.nrctremp = craplim.nrctrlim AND
                           crapavt.tpctrato = 3                NO-LOCK:
        
        CREATE tt-avais-ctr.
        ASSIGN tt-avais-ctr.nmdavali = crapavt.nmdavali
               tt-avais-ctr.cpfavali = "CPF: " + STRING(STRING(crapavt.nrcpfcgc,
                                       "99999999999"),"xxx.xxx.xxx-xx")
               tt-avais-ctr.dsdocava = crapavt.tpdocava + ": " + 
                                       crapavt.nrdocava
               tt-avais-ctr.dsendav1 = IF  crapavt.nrendere > 0  THEN
                                           SUBSTR(crapavt.dsendres[1],1,32) + 
                                           " " + TRIM(STRING(crapavt.nrendere,
                                                             "zzz,zz9"))
                                       ELSE
                                           crapavt.dsendres[1]
               tt-avais-ctr.dsendav2 = crapavt.dsendres[2]
               tt-avais-ctr.dsendav3 = STRING(crapavt.nrcepend,"99999,999") + 
                                       " - " + crapavt.nmcidade + "/" +
                                       crapavt.cdufresd.       

        IF  crapavt.nmconjug <> ""  THEN
            ASSIGN tt-avais-ctr.nmconjug = crapavt.nmconjug.
        ELSE 
            ASSIGN tt-avais-ctr.nmconjug = FILL("_",40).
               
        IF  crapavt.nrcpfcjg <> 0  THEN    
            ASSIGN tt-avais-ctr.nrcpfcjg = "CPF: " +
                                           STRING(STRING(crapavt.nrcpfcjg,
                                           "99999999999"),"xxx.xxx.xxx-xx").
        ELSE       
            ASSIGN tt-avais-ctr.nrcpfcjg = "CPF: " + FILL("_",35).
                   
        IF  crapavt.tpdoccjg <> "" AND crapavt.nrdoccjg <> ""  THEN    
            ASSIGN tt-avais-ctr.dsdoccjg = crapavt.tpdoccjg + ": " +
                                           crapavt.nrdoccjg.
        ELSE  
            ASSIGN tt-avais-ctr.dsdoccjg = "CI: " + FILL("_",36).

    END. /** Fim do FOR EACH crapavt **/

    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**    Procedure para carregar dados para impressao da proposta do limite    **/
/******************************************************************************/
PROCEDURE obtem-dados-proposta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-dados-prp.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
        
    DEF VAR aux_nmexcop1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmexcop2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmresage AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsempres AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstipcta AS CHAR                                    NO-UNDO.
    DEF VAR aux_dssitdct AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdofone AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmoperad AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsmesref AS CHAR                                    NO-UNDO.

    DEF VAR aux_qtprecal AS DECI                                    NO-UNDO.
    DEF VAR aux_vlutiliz AS DECI                                    NO-UNDO.
    DEF VAR aux_vlsldrdc AS DECI                                    NO-UNDO.
    DEF VAR aux_vltotppr AS DECI DECIMALS 8                         NO-UNDO.
    DEF VAR aux_vlsmdtri AS DECI                                    NO-UNDO.
    DEF VAR aux_vlcaptal AS DECI                                    NO-UNDO.
    DEF VAR aux_vlprepla AS DECI                                    NO-UNDO.
    DEF VAR aux_vltotccr AS DECI                                    NO-UNDO.
    DEF VAR aux_vltotemp AS DECI                                    NO-UNDO.
    DEF VAR aux_vltotpre AS DECI                                    NO-UNDO.
    DEF VAR aux_cdempres AS INT                                     NO-UNDO.
    DEF VAR aux_flgativo AS LOG                                     NO-UNDO.
    DEF VAR aux_nrctrhcj AS INT                                     NO-UNDO.
    DEF VAR aux_flgliber AS LOG                                     NO-UNDO.
    DEF VAR aux_tpregist AS INTE                                    NO-UNDO.
    DEF VAR aux_flpropos AS LOGI                                    NO-UNDO.
    DEF VAR aux_nrcpfcjg AS DECI                                    NO-UNDO.
    DEF VAR aux_nrctacje AS INTE                                    NO-UNDO.
    DEF VAR aux_nmsegntl AS CHAR                                    NO-UNDO.
    /* PRJ 438 - Sprint 7 */
    DEF VAR aux_dsrmativ AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtiniatv AS DATE                                    NO-UNDO.
    DEF VAR aux_vlfatmes AS DECI                                    NO-UNDO.
    DEF VAR aux_perfatcl AS DECI                                    NO-UNDO.

    DEF VAR h-b1wgen0001 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0002 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0004 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0006 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0021 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0028 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0081 AS HANDLE                                  NO-UNDO.    

    DEF VAR aux_vlsldrgt AS DEC                                     NO-UNDO.
    DEF VAR aux_vlsldtot AS DEC                                     NO-UNDO.
    DEF VAR aux_vlsldapl AS DEC                                     NO-UNDO.
    
    DEF VAR aux_dtassele AS DATE                                    NO-UNDO. /* Data assinatura eletronica */
    DEF VAR aux_dsvlrprm AS CHAR                                    NO-UNDO. /* Data de corte */
    
    /* PRJ 438 - Sprint 13*/
    DEF VAR aux_vlrencjg AS DECI                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-dados-prp.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsmesref = "Janeiro,Fevereiro,Marco,Abril,Maio,Junho," +
                          "Julho,Agosto,Setembro,Outubro,Novembro,Dezembro".
        
    DO WHILE TRUE:
    
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "".
    
        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE crapcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651.
                LEAVE.
            END.
                
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE crapass  THEN
            DO: 
                ASSIGN aux_cdcritic = 9.
                LEAVE.
            END.
            
        FIND crapprp WHERE crapprp.cdcooper = par_cdcooper AND
                           crapprp.nrdconta = par_nrdconta AND
                           crapprp.nrctrato = par_nrctrlim AND
                           crapprp.tpctrato = 1            NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE crapprp  THEN
            DO:
                ASSIGN aux_dscritic = "Proposta de limite de credito nao " +
                                      "cadastrada.".
                LEAVE.
            END.

        IF  crapass.inpessoa = 1   THEN
            DO:
                 FIND crapcje WHERE crapcje.cdcooper = par_cdcooper   AND
                                    crapcje.nrdconta = par_nrdconta   AND
                                    crapcje.idseqttl = 1
                                    NO-LOCK NO-ERROR.
                 
                 IF   AVAIL crapcje   THEN
                      ASSIGN aux_nrcpfcjg = crapcje.nrcpfcjg
                             aux_nrctacje = crapcje.nrctacje.
            END.
                        
        FIND FIRST crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                                 crapdoc.nrdconta = par_nrdconta AND
                                 crapdoc.tpdocmto = 19
                                 NO-LOCK NO-ERROR.

        IF  AVAIL crapdoc THEN
            FIND FIRST craptab WHERE 
                       craptab.cdcooper = crapcop.cdcooper  AND         
                       craptab.nmsistem = "CRED"            AND         
                       craptab.tptabela = "GENERI"          AND         
                       craptab.cdempres = 00                AND         
                       craptab.cdacesso = "DIGITALIZA"      AND
                       craptab.tpregist = crapdoc.tpdocmto /* 84 - Lim cred */
                       NO-LOCK NO-ERROR.

            IF  AVAIL craptab THEN
                ASSIGN aux_tpregist = INTE(ENTRY(3,craptab.dstextab,";")).
            ELSE
                ASSIGN aux_tpregist = 0.

        FIND craplim WHERE craplim.cdcooper = par_cdcooper AND
                           craplim.nrdconta = par_nrdconta AND
                           craplim.nrctrlim = par_nrctrlim AND
                           craplim.tpctrlim = 1            NO-LOCK NO-ERROR.
                       
        IF  NOT AVAILABLE craplim  THEN
            DO: 
                ASSIGN aux_cdcritic = 105.
                LEAVE.
            END.
                   
        LEAVE.
        
    END. /** Fim do DO WHILE TRUE **/
    
    IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
        SET h-b1wgen9999.
        
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.
        
    RUN saldo_utiliza IN h-b1wgen9999 (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT par_cdoperad,
                                       INPUT par_nmdatela,
                                       INPUT par_idorigem,
                                       INPUT par_nrdconta,
                                       INPUT par_idseqttl,
                                       INPUT par_dtmvtolt,
                                       INPUT par_dtmvtopr,
                                       INPUT "",
                                       INPUT par_inproces,
                                       INPUT FALSE, /*Consulta por cpf*/
                                      OUTPUT aux_vlutiliz,
                                      OUTPUT TABLE tt-erro).
                                      
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen9999.
            RETURN "NOK".           
        END.           

    RUN divide-nome-coop IN h-b1wgen9999 (INPUT crapcop.nmextcop,
                                         OUTPUT aux_nmexcop1,
                                         OUTPUT aux_nmexcop2).
        
    DELETE PROCEDURE h-b1wgen9999.

    RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT
        SET h-b1wgen0001.
        
    IF  NOT VALID-HANDLE(h-b1wgen0001)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0001.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.

    RUN obtem-cabecalho IN h-b1wgen0001 (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nrdconta,
                                         INPUT "",
                                         INPUT par_dtmvtolt,
                                         INPUT par_dtmvtolt,
                                         INPUT par_idorigem,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-cabec).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen0001.
            RETURN "NOK".
        END.

    RUN carrega_medias IN h-b1wgen0001 (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nrdconta,
                                        INPUT par_dtmvtolt,
                                        INPUT par_idorigem,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT FALSE, /** NAO GERAR LOG **/
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-medias,
                                       OUTPUT TABLE tt-comp_medias).

    DELETE PROCEDURE h-b1wgen0001.
        
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
    
    FIND FIRST tt-cabec NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-cabec  THEN
        ASSIGN aux_dstipcta = tt-cabec.dstipcta
               aux_dssitdct = tt-cabec.dssitdct
               aux_nrdofone = tt-cabec.nrramfon.
        
    FIND FIRST tt-comp_medias NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-comp_medias  THEN
        ASSIGN aux_vlsmdtri = tt-comp_medias.vlsmdtri.

    RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT
        SET h-b1wgen0002.
        
    IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0002.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.

    RUN saldo-devedor-epr IN h-b1wgen0002 (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT par_nrdconta,
                                           INPUT par_idseqttl,
                                           INPUT par_dtmvtolt,
                                           INPUT par_dtmvtopr,
                                           INPUT 0, /** NR. CONTRATO **/
                                           INPUT "B1WGEN0019",
                                           INPUT par_inproces,
                                           INPUT FALSE, /** NAO GERAR LOG **/
                                          OUTPUT aux_vltotemp,
                                          OUTPUT aux_vltotpre,
                                          OUTPUT aux_qtprecal,
                                          OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0002.
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
        
    RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT
        SET h-b1wgen0021.
        
    IF  NOT VALID-HANDLE(h-b1wgen0021)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0021.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.

    RUN obtem_dados_capital IN h-b1wgen0021 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT par_dtmvtolt,
                                             INPUT FALSE, /** NAO GERAR LOG **/
                                            OUTPUT TABLE tt-dados-capital,
                                            OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0021.
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".    
        
    FIND FIRST tt-dados-capital NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-dados-capital  THEN
        ASSIGN aux_vlcaptal = tt-dados-capital.vlcaptal
               aux_vlprepla = tt-dados-capital.vlprepla.
               

    /* NOVOS PRODUTOS DE CAPTACAO */
        /** Saldo das aplicacoes **/
        RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT
                SET h-b1wgen0081.        
   
        IF  VALID-HANDLE(h-b1wgen0081)  THEN
                DO:
                        ASSIGN aux_vlsldtot = 0.

                        
                        RUN obtem-dados-aplicacoes IN h-b1wgen0081
                                                                          (INPUT par_cdcooper,
                                                                           INPUT par_cdagenci,
                                                                           INPUT 1,
                                                                           INPUT 1,
                                                                           INPUT par_nmdatela,
                                                                           INPUT 1,
                                                                           INPUT par_nrdconta,
                                                                           INPUT 1,
                                                                           INPUT 0,
                                                                           INPUT par_nmdatela,
                                                                           INPUT FALSE,
                                                                           INPUT ?,
                                                                           INPUT ?,
                                                                           OUTPUT aux_vlsldrdc,
                                                                           OUTPUT TABLE tt-saldo-rdca,
                                                                           OUTPUT TABLE tt-erro).
                
                        IF  RETURN-VALUE = "NOK"  THEN
                                DO:
                                        DELETE PROCEDURE h-b1wgen0081.
                                        
                                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                 
                                        IF  AVAILABLE tt-erro  THEN
                                                MESSAGE tt-erro.dscritic.
                                        ELSE
                                                MESSAGE "Erro nos dados das aplicacoes.".
                
                                        NEXT.
                                END.

                        DELETE PROCEDURE h-b1wgen0081.
                END.
         
           DO TRANSACTION ON ERROR UNDO, RETRY:
                 /*Busca Saldo Novas Aplicacoes*/
                 
                 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
                  RUN STORED-PROCEDURE pc_busca_saldo_aplicacoes
                        aux_handproc = PROC-HANDLE NO-ERROR
                                                                        (INPUT par_cdcooper, /* Código da Cooperativa */
                                                                         INPUT '1',            /* Código do Operador */
                                                                         INPUT par_nmdatela, /* Nome da Tela */
                                                                         INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                                                         INPUT par_nrdconta, /* Número da Conta */
                                                                         INPUT 1,            /* Titular da Conta */
                                                                         INPUT 0,            /* Número da Aplicação / Parâmetro Opcional */
                                                                         INPUT par_dtmvtolt, /* Data de Movimento */
                                                                         INPUT 0,            /* Código do Produto */
                                                                         INPUT 1,            /* Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas) */
                                                                         INPUT 0,            /* Identificador de Log (0 – Não / 1 – Sim) */
                                                                        OUTPUT 0,            /* Saldo Total da Aplicação */
                                                                        OUTPUT 0,            /* Saldo Total para Resgate */
                                                                        OUTPUT 0,            /* Código da crítica */
                                                                        OUTPUT "").          /* Descrição da crítica */
                  
                  CLOSE STORED-PROC pc_busca_saldo_aplicacoes
                                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                  
                  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                  ASSIGN aux_cdcritic = 0
                                 aux_dscritic = ""
                                 aux_vlsldtot = 0
                                 aux_vlsldrgt = 0
                                 aux_cdcritic = pc_busca_saldo_aplicacoes.pr_cdcritic 
                                                                 WHEN pc_busca_saldo_aplicacoes.pr_cdcritic <> ?
                                 aux_dscritic = pc_busca_saldo_aplicacoes.pr_dscritic
                                                                 WHEN pc_busca_saldo_aplicacoes.pr_dscritic <> ?
                                 aux_vlsldtot = pc_busca_saldo_aplicacoes.pr_vlsldtot
                                                                 WHEN pc_busca_saldo_aplicacoes.pr_vlsldtot <> ?
                                 aux_vlsldrgt = pc_busca_saldo_aplicacoes.pr_vlsldrgt
                                                                 WHEN pc_busca_saldo_aplicacoes.pr_vlsldrgt <> ?.

                  IF aux_cdcritic <> 0   OR
                         aux_dscritic <> ""  THEN
                         DO:
                                 IF aux_dscritic = "" THEN
                                        DO:
                                           FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                                                                  NO-LOCK NO-ERROR.
                
                                           IF AVAIL crapcri THEN
                                                  ASSIGN aux_dscritic = crapcri.dscritic.
                
                                        END.
                
                                 CREATE tt-erro.
                
                                 ASSIGN tt-erro.cdcritic = aux_cdcritic
                                                tt-erro.dscritic = aux_dscritic.
                  
                                 RETURN "NOK".
                                                                
                         END.

         ASSIGN aux_vlsldrdc = aux_vlsldrdc + aux_vlsldrgt.
         END.
         /*Fim Busca Saldo Novas Aplicacoes*/
     

    RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT
        SET h-b1wgen0006.
        
    IF  NOT VALID-HANDLE(h-b1wgen0006)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0006.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.
                         
    RUN consulta-poupanca IN h-b1wgen0006 (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT par_nrdconta,
                                           INPUT par_idseqttl,
                                           INPUT 0,
                                           INPUT par_dtmvtolt,
                                           INPUT par_dtmvtopr,
                                           INPUT par_inproces,
                                           INPUT par_nmdatela,
                                           INPUT FALSE, 
                                          OUTPUT aux_vltotppr,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-dados-rpp). 
                           
    DELETE PROCEDURE h-b1wgen0006.
            
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT
        SET h-b1wgen0028.
        
    IF  NOT VALID-HANDLE(h-b1wgen0028)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0028.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.

    RUN lista_cartoes IN h-b1wgen0028 (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT par_cdoperad,
                                       INPUT par_nrdconta,
                                       INPUT par_idorigem,
                                       INPUT par_idseqttl,
                                       INPUT par_nmdatela,
                                       INPUT FALSE, /** NAO GERAR LOG **/
                                       OUTPUT aux_flgativo,
                                       OUTPUT aux_nrctrhcj,
                                       OUTPUT aux_flgliber,
                                       OUTPUT aux_dtassele,
                                       OUTPUT aux_dsvlrprm,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-cartoes,
                                      OUTPUT TABLE tt-lim_total). 
              
    DELETE PROCEDURE h-b1wgen0028.
            
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    FIND FIRST tt-lim_total NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-lim_total  THEN
        ASSIGN aux_vltotccr = tt-lim_total.vltotccr.
            
    FIND crapope WHERE crapope.cdcooper = par_cdcooper     AND
                       crapope.cdoperad = craplim.cdoperad NO-LOCK NO-ERROR.
                           
    IF  AVAILABLE crapope  THEN
        ASSIGN aux_nmoperad = crapope.nmoperad.
    ELSE
        ASSIGN aux_nmoperad = craplim.cdoperad + " - NAO CADASTRADO".
        
    FIND crapage WHERE crapage.cdcooper = par_cdcooper     AND
                       crapage.cdagenci = crapass.cdagenci NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapage  THEN
        ASSIGN aux_nmresage = TRIM(STRING(crapass.cdagenci,"zz9")) + 
                              " - NAO CADASTRADO".
    ELSE
        ASSIGN aux_nmresage = TRIM(STRING(crapass.cdagenci,"zz9")) + " - " + 
                              crapage.nmresage.

    ASSIGN aux_cdempres = 0.
    
    IF  crapass.inpessoa = 1  THEN
        DO:
            FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta AND
                               crapttl.idseqttl = 1            NO-LOCK NO-ERROR.
        
            IF   AVAILABLE crapttl  THEN
                 ASSIGN aux_nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,
                                       "99999999999"),"xxx.xxx.xxx-xx")
                        aux_cdempres = crapttl.cdempres.

            FOR FIRST crapttl FIELDS(nmextttl) 
                              WHERE crapttl.cdcooper = par_cdcooper AND
                                    crapttl.nrdconta = par_nrdconta AND
                                    crapttl.idseqttl = 2
                                    NO-LOCK:

              ASSIGN aux_nmsegntl = crapttl.nmextttl.

        END.
        
        END.
    ELSE
        DO:
            FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                               crapjur.nrdconta = par_nrdconta
                               NO-LOCK NO-ERROR.

            IF   AVAIL crapjur  THEN
                DO:
                    ASSIGN aux_cdempres = crapjur.cdempres
                        /* PRJ 438 - Sprint 7 */
                        aux_dtiniatv = crapjur.dtiniatv
                        aux_vlfatmes = crapjur.vlfatano / 12.
                        
                    /* PRJ 438 - Sprint 7 */    
                    IF   crapjur.cdrmativ <> 0   AND
                         crapjur.cdseteco <> 0   THEN
                       DO:
                            FIND gnrativ WHERE 
                                         gnrativ.cdseteco = crapjur.cdseteco AND
                                         gnrativ.cdrmativ = crapjur.cdrmativ
                                         NO-LOCK NO-ERROR.

                            ASSIGN aux_dsrmativ = IF   AVAILABLE gnrativ THEN 
                                                                STRING(gnrativ.cdrmativ) + " - " + gnrativ.nmrmativ
                                                           ELSE 
                                                                "".
                       END.            
                         
                END.
                
            /* PRJ 438 - Sprint 7 */    
            FIND FIRST crapjfn WHERE crapjfn.cdcooper = par_cdcooper  AND
                                     crapjfn.nrdconta = par_nrdconta
                               NO-LOCK NO-ERROR.

            IF   AVAIL crapjfn  THEN
                    ASSIGN aux_perfatcl = crapjfn.perfatcl.
                 
            ASSIGN aux_nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,
                                  "99999999999999"),"xx.xxx.xxx/xxxx-xx").
        END.
        

    /*PRJ 438 - Sprint 13 */
    ASSIGN aux_vlrencjg = 0 .    
    FIND FIRST crapttl WHERE crapttl.cdcooper = par_cdcooper  AND
                             crapttl.nrdconta = crapcje.nrctacje
                       NO-LOCK NO-ERROR.
                               
    IF   AVAIL crapttl  THEN
            ASSIGN aux_vlrencjg = crapttl.vldrendi[1] + crapttl.vldrendi[2] + crapttl.vldrendi[3] + crapttl.vldrendi[4] + crapttl.vldrendi[5] + crapttl.vldrendi[6] .
            
    /*PRJ 438 - Sprint 13 */
    
    
    FIND crapemp WHERE crapemp.cdcooper = par_cdcooper     AND
                       crapemp.cdempres = aux_cdempres NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapemp  THEN
        DO:
            ASSIGN aux_cdcritic = 40  /* Empresa nao cadastrada */ 
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.
    ELSE
        ASSIGN aux_dsempres = TRIM(STRING(aux_cdempres,"zzzz9")) + " - " + 
                              crapemp.nmresemp.
                              
    ASSIGN aux_flpropos = (craplim.insitlim = 1).

    RUN obtem-dados-avais (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_nmdatela,
                           INPUT par_idorigem,
                           INPUT par_nrdconta,
                           INPUT aux_flpropos,
                           INPUT par_idseqttl,
                           INPUT par_dtmvtolt,
                           INPUT TRUE, /** LOG **/
                          OUTPUT TABLE tt-dados-avais,
                          OUTPUT TABLE tt-erro).
    
    FIND craplim WHERE craplim.cdcooper = par_cdcooper AND
                       craplim.nrdconta = par_nrdconta AND
                       craplim.nrctrlim = par_nrctrlim AND
                       craplim.tpctrlim = 1            NO-LOCK NO-ERROR.

    CREATE tt-dados-prp.
    ASSIGN tt-dados-prp.nmextcop = crapcop.nmextcop 
           tt-dados-prp.nmexcop1 = aux_nmexcop1    
           tt-dados-prp.nmexcop2 = aux_nmexcop2
           tt-dados-prp.nmcidade = crapcop.nmcidade
           tt-dados-prp.nrdconta = crapass.nrdconta  
           tt-dados-prp.nrmatric = crapass.nrmatric
           tt-dados-prp.nrcpfcgc = aux_nrcpfcgc
           tt-dados-prp.nmprimtl = crapass.nmprimtl  
           tt-dados-prp.nmsegntl = aux_nmsegntl
           tt-dados-prp.dtadmiss = crapass.dtadmiss
           tt-dados-prp.nmresage = aux_nmresage
           tt-dados-prp.dsempres = aux_dsempres      
           tt-dados-prp.nrdofone = aux_nrdofone
           tt-dados-prp.dstipcta = aux_dstipcta      
           tt-dados-prp.dssitdct = aux_dssitdct          
           tt-dados-prp.nrctrlim = craplim.nrctrlim
           tt-dados-prp.vllimite = craplim.vllimite
           tt-dados-prp.nrctaav1 = craplim.nrctaav1
           tt-dados-prp.nrctaav2 = craplim.nrctaav2
           tt-dados-prp.vllimcre = crapass.vllimcre
           tt-dados-prp.vlsalari = crapprp.vlsalari
           tt-dados-prp.vlsalcon = crapprp.vlsalcon  
           tt-dados-prp.vloutras = crapprp.vloutras
           tt-dados-prp.vlalugue = crapprp.vlalugue
           tt-dados-prp.dsobser1 = crapprp.dsobserv[1]
           tt-dados-prp.dsobser2 = crapprp.dsobserv[2]   
           tt-dados-prp.dsobser3 = crapprp.dsobserv[3]
           tt-dados-prp.vlutiliz = aux_vlutiliz  
           tt-dados-prp.vlsmdtri = aux_vlsmdtri
           tt-dados-prp.vltotemp = aux_vltotemp
           tt-dados-prp.vltotpre = aux_vltotpre
           tt-dados-prp.vlcaptal = aux_vlcaptal  
           tt-dados-prp.vlprepla = aux_vlprepla
           tt-dados-prp.vlaplica = aux_vlsldrdc + aux_vltotppr  
           tt-dados-prp.vltotccr = aux_vltotccr
           tt-dados-prp.nmoperad = "Operador: " + TRIM(aux_nmoperad)
           tt-dados-prp.dsemsprp = STRING(DAY(par_dtmvtolt),"99") + 
                                   " de " +
                                   ENTRY(MONTH(par_dtmvtolt),aux_dsmesref) + 
                                   " de " +
                                   STRING(YEAR(par_dtmvtolt),"9999")
           /* Campo para digitalizacao */
           tt-dados-prp.tpregist = aux_tpregist
           tt-dados-prp.nrcpfcjg = aux_nrcpfcjg
           tt-dados-prp.nrctacje = aux_nrctacje
           tt-dados-prp.inconcje = craplim.inconcje
           tt-dados-prp.idcobope = craplim.idcobope
           tt-dados-prp.inpessoa = crapass.inpessoa
           /* PRJ 438 - Sprint 7 */
           tt-dados-prp.dtiniatv = aux_dtiniatv
           tt-dados-prp.dsrmativ = aux_dsrmativ
           tt-dados-prp.vlfatmes = aux_vlfatmes
           tt-dados-prp.perfatcl = aux_perfatcl
           /* PRJ 438 - Sprint 13*/
           tt-dados-prp.vlrencjg = aux_vlrencjg.

    /* Salvar os CPF/CNPJ dos avais e o tipo de pessoa */
    FOR EACH tt-dados-avais NO-LOCK.

        IF   tt-dados-prp.nrcpfav1 = 0   THEN
             ASSIGN tt-dados-prp.nrcpfav1 = tt-dados-avais.nrcpfcgc
                    tt-dados-prp.inpesso1 = tt-dados-avais.inpessoa.
        ELSE
             ASSIGN tt-dados-prp.nrcpfav2 = tt-dados-avais.nrcpfcgc
                    tt-dados-prp.inpesso2 = tt-dados-avais.inpessoa.

    END.

    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**    Procedure para carregar dados para impressao da rescisao do limite    **/
/******************************************************************************/
PROCEDURE obtem-dados-rescisao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-dados-rescisao.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmexcop1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmexcop2 AS CHAR                                    NO-UNDO.
    /* Pj470 SM 1 - Ze Gracik - Mouts */
    DEF VAR aux_dscoperd AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscopert AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsfrsass AS CHAR    EXTENT 4                        NO-UNDO.
    DEF VAR aux_dsfrscop AS CHAR    EXTENT 4                        NO-UNDO.
    /* Fim Pj470 SM 1 */    
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    
    EMPTY TEMP-TABLE tt-dados-rescisao.
    EMPTY TEMP-TABLE tt-erro.
    
    DO WHILE TRUE:
    
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "".
    
        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE crapcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651.
                LEAVE.
            END.
                
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE crapass  THEN
            DO: 
                ASSIGN aux_cdcritic = 9.
                LEAVE.
            END.

        FIND craplim WHERE craplim.cdcooper = par_cdcooper AND
                           craplim.nrdconta = par_nrdconta AND
                           craplim.nrctrlim = par_nrctrlim AND
                           craplim.tpctrlim = 1            NO-LOCK NO-ERROR.
                       
        IF  NOT AVAILABLE craplim  THEN
            DO: 
                ASSIGN aux_cdcritic = 105.
                LEAVE.
            END.
                   
        FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                           crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.
                           
        IF  NOT AVAILABLE crapope  THEN
            DO: 
                ASSIGN aux_dscritic = "Operador nao cadastrado.".
                LEAVE.
            END.
                               
        LEAVE.
        
    END. /** Fim do DO WHILE TRUE **/
    
    IF  aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.

    IF  craplim.insitlim <> 3  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "O contrato de limite de credito " + 
                                   "nao esta cancelado.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.

    ASSIGN aux_dscoperd = ""
           aux_dscopert = "".

    /* Pj470 SM 1 - Ze Gracik - Mouts */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_ver_protocolo
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapcop.cdcooper
                                            ,INPUT crapass.nrdconta
                                            ,INPUT craplim.nrctrlim
                                            ,INPUT 25
                                           ,OUTPUT ""
                                           ,OUTPUT "").
                                            
    CLOSE STORED-PROC pc_ver_protocolo
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                                        
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_dscoperd = pc_ver_protocolo.pr_dsfrase_cooperado
           aux_dscopert = pc_ver_protocolo.pr_dsfrase_cooperativa.
    /* Fim Pj 470 SM 1 */

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
        SET h-b1wgen9999.
        
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.
        
    RUN divide-nome-coop IN h-b1wgen9999 (INPUT crapcop.nmextcop,
                                         OUTPUT aux_nmexcop1,
                                         OUTPUT aux_nmexcop2).
        
    RUN quebra-str IN h-b1wgen9999 (INPUT aux_dscoperd,
                                    INPUT 76, INPUT 76,
                                    INPUT 76, INPUT 76,
                                   OUTPUT aux_dsfrsass[1],
                                   OUTPUT aux_dsfrsass[2],
                                   OUTPUT aux_dsfrsass[3],
                                   OUTPUT aux_dsfrsass[4]).
                                   
    RUN quebra-str IN h-b1wgen9999 (INPUT aux_dscopert,
                                    INPUT 76, INPUT 76,
                                    INPUT 76, INPUT 76,
                                   OUTPUT aux_dsfrscop[1],
                                   OUTPUT aux_dsfrscop[2],
                                   OUTPUT aux_dsfrscop[3],
                                   OUTPUT aux_dsfrscop[4]).
        
    DELETE PROCEDURE h-b1wgen9999.
        
    CREATE tt-dados-rescisao.
    ASSIGN tt-dados-rescisao.nmextcop = crapcop.nmextcop
           tt-dados-rescisao.nmcidade = crapcop.nmcidade
           tt-dados-rescisao.cdufdcop = crapcop.cdufdcop
           tt-dados-rescisao.nrdconta = crapass.nrdconta
           tt-dados-rescisao.nmprimtl = crapass.nmprimtl
           tt-dados-rescisao.nrctrlim = craplim.nrctrlim           
           tt-dados-rescisao.vllimite = craplim.vllimite
           tt-dados-rescisao.dtmvtolt = par_dtmvtolt     
           tt-dados-rescisao.nmexcop1 = aux_nmexcop1  
           tt-dados-rescisao.nmexcop2 = aux_nmexcop2
           tt-dados-rescisao.nmoperad = "Operador: " + TRIM(crapope.nmoperad).
    
    /* Pj470 SM 1 - Ze Gracik - Mouts */
    IF   aux_dscoperd = "*" THEN
         ASSIGN tt-dados-rescisao.dsfrass1 = "*"
                tt-dados-rescisao.dsfrass2 = ""
                tt-dados-rescisao.dsfrass3 = ""
                tt-dados-rescisao.dsfrcop1 = ""
                tt-dados-rescisao.dsfrcop2 = "".
    ELSE
         ASSIGN tt-dados-rescisao.dsfrass1 = aux_dsfrsass[1]
                tt-dados-rescisao.dsfrass2 = aux_dsfrsass[2]
                tt-dados-rescisao.dsfrass3 = aux_dsfrsass[3]
                tt-dados-rescisao.dsfrcop1 = aux_dsfrscop[1]
                tt-dados-rescisao.dsfrcop2 = aux_dsfrscop[2].
    
    /* Fim Pj 470 SM 1 */
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE imprime_cet:
    
    DEF INPUT PARAM p-cdcooper AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtmvtolt AS DATE                                 NO-UNDO.
    DEF INPUT PARAM p-cdprogra AS CHAR                                 NO-UNDO.
    DEF INPUT PARAM p-nrdconta AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-inpessoa AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-cdusolcr AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-cdlcremp AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-tpctrlim AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-nrctrlim AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtinivig AS DATE                                 NO-UNDO.
    DEF INPUT PARAM p-qtdiavig AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-vlemprst AS DECI                                 NO-UNDO.
    DEF INPUT PARAM p-txmensal AS DECI                                 NO-UNDO.

    DEF OUTPUT PARAM par_nmdoarqv AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                              NO-UNDO.

    DEF VAR aux_dscritic AS CHAR NO-UNDO.
    DEF VAR aux_cdcritic AS INTE NO-UNDO.    

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_imprime_limites_cet 
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT p-cdcooper, /* Cooperativa */
                          INPUT p-dtmvtolt, /* Data Movimento */
                          INPUT p-cdprogra, /* Programa chamador */
                          INPUT p-nrdconta, /* Conta/dv          */
                          INPUT p-inpessoa, /* Indicativo de pessoa */
                          INPUT p-cdusolcr, /* Codigo de uso da linha de credito */
                          INPUT p-cdlcremp, /* Linha de credio */
                          INPUT p-tpctrlim, /* Tipo da operacao  */
                          INPUT p-nrctrlim, /* Contrato          */
                          INPUT p-dtinivig, /* Data liberacao  */
                          INPUT p-qtdiavig, /* Dias de vigencia */                                     
                          INPUT p-vlemprst, /* Valor emprestado */
                          INPUT p-txmensal, /* Taxa mensal/craplrt.txmensal */
                          INPUT 0,          /* 0 - false pr_flretxml*/
                         OUTPUT "", 
                         OUTPUT "", 
                         OUTPUT 0,
                         OUTPUT "").

    CLOSE STORED-PROC pc_imprime_limites_cet 
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_nmdoarqv = ""
           par_nmdoarqv = pc_imprime_limites_cet.pr_nmarqimp
                          WHEN pc_imprime_limites_cet.pr_nmarqimp <> ? 
           aux_cdcritic = pc_imprime_limites_cet.pr_cdcritic 
                          WHEN pc_imprime_limites_cet.pr_cdcritic <> ?
           aux_dscritic = pc_imprime_limites_cet.pr_dscritic 
                          WHEN pc_imprime_limites_cet.pr_dscritic <> ?.
        
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:                                    
            ASSIGN par_dscritic = aux_dscritic.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE junta_arquivos:

    DEF  INPUT PARAM par_dsdircop AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR FORMAT "x(75)"               NO-UNDO.
    DEF  INPUT PARAM par_nmarqcet AS CHAR FORMAT "x(75)"               NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                              NO-UNDO.

    DEF OUTPUT PARAM par_nmarquiv AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                              NO-UNDO.

    DEF VAR aux_dsarqimp AS CHAR NO-UNDO.
    DEF VAR aux_setlinha AS CHAR NO-UNDO.
    DEF VAR aux_time AS CHAR     NO-UNDO.

    ASSIGN aux_time = STRING(TIME) + par_dsiduser
           par_nmarquiv = "/usr/coop/" + par_dsdircop + "/rl/" + aux_time + ".ex"
           par_nmarqpdf = "/usr/coop/" + par_dsdircop + "/rl/" + aux_time + ".pdf".

    IF  par_inpessoa <> 1  THEN
        OUTPUT STREAM str_3 TO VALUE(par_nmarquiv) PAGED PAGE-SIZE 250.
    ELSE
        OUTPUT STREAM str_3 TO VALUE(par_nmarquiv) PAGED PAGE-SIZE 65.  
    
    /* para contrato e completa */
    INPUT STREAM str_1
          THROUGH VALUE( "ls " + par_nmarqimp + " 2> /dev/null") NO-ECHO.

    DO  WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

         SET STREAM str_1 par_nmarqimp.

         INPUT STREAM str_2 FROM VALUE(par_nmarqimp) NO-ECHO.

         DO  WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

             IMPORT STREAM str_2 UNFORMATTED aux_setlinha.
             
             /* Verificar se o primeiro caracter é uma quebra de pagina
                e assim forçar a quebra, pois sem a utilizacao do comando
                page stream o contador de linhas nao é zerado gerando 
                quebra de pagina no momento errado SD344244 */
             IF asc(substr(aux_setlinha,1,1)) = 12 THEN
             DO:
               PAGE STREAM str_3.
               aux_setlinha = substr(aux_setlinha,2).
             END.

             PUT STREAM str_3 aux_setlinha FORMAT "x(130)" SKIP.

             IF  par_inpessoa <> 1 THEN
                DO:
                     IF  LINE-COUNTER(str_3) >= 150 THEN
                         PUT STREAM str_3 CHR(2).  /* inicio do texto chr(2)*/
                END.
            ELSE
                DO: 
                    IF  LINE-COUNTER(str_3) >= 65 THEN
                        PUT STREAM str_3 CHR(2).  /* inicio do texto chr(2)*/
                END.                                                         
         END.    

         
         INPUT STREAM str_2 CLOSE.
         
    END.

    PAGE STREAM str_3.
    PUT STREAM str_3 CHR(2).  /* inicio do texto chr(2)*/ 

    INPUT STREAM str_1 CLOSE.
                    
    /* para o cet */
    INPUT STREAM str_1
          THROUGH VALUE( "ls " + par_nmarqcet + " 2> /dev/null") NO-ECHO.

    DO  WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

         SET STREAM str_1 par_nmarqcet.

         INPUT STREAM str_2 FROM VALUE(par_nmarqcet) NO-ECHO.

         DO  WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

             IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

             PUT STREAM str_3 aux_setlinha FORMAT "x(100)" SKIP.
             
         END.

         INPUT STREAM str_2 CLOSE.
    END.

    INPUT STREAM str_1 CLOSE.

    OUTPUT STREAM str_3 CLOSE.
END.

PROCEDURE calcula_cet_limites:
    
    DEF INPUT PARAM p-cdcooper AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtmvtolt AS DATE                                 NO-UNDO.
    DEF INPUT PARAM p-cdprogra AS CHAR                                 NO-UNDO.
    DEF INPUT PARAM p-nrdconta AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-inpessoa AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-cdusolcr AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-cdlcremp AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-tpctrlim AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-nrctrlim AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtinivig AS DATE                                 NO-UNDO.
    DEF INPUT PARAM p-qtdiavig AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-vlemprst AS DECI                                 NO-UNDO.
    DEF INPUT PARAM p-txmensal AS DECI                                 NO-UNDO.

    DEF OUTPUT PARAM par_txcetano AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM par_txcetmes AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                              NO-UNDO.

    DEF VAR aux_dscritic AS CHAR NO-UNDO.
    DEF VAR aux_cdcritic AS INTE NO-UNDO.    

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_calculo_cet_limites
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT p-cdcooper, /* Cooperativa */
                          INPUT p-dtmvtolt, /* Data Movimento */
                          INPUT p-cdprogra, /* Programa chamador */
                          INPUT p-nrdconta, /* Conta/dv          */
                          INPUT p-inpessoa, /* Indicativo de pessoa */
                          INPUT p-cdusolcr, /* Codigo de uso da linha de credito */
                          INPUT p-cdlcremp, /* Linha de credio */
                          INPUT p-tpctrlim, /* Tipo da operacao  */
                          INPUT p-nrctrlim, /* Contrato          */
                          INPUT p-dtinivig, /* Data liberacao  */
                          INPUT p-qtdiavig, /* Dias de vigencia */                                     
                          INPUT p-vlemprst, /* Valor emprestado */
                          INPUT p-txmensal, /* Taxa mensal/craplrt.txmensal */
                         OUTPUT 0, 
                         OUTPUT 0, 
                         OUTPUT 0,
                         OUTPUT "").

    CLOSE STORED-PROC pc_calculo_cet_limites
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_txcetano = 0
           par_txcetmes = 0
           par_txcetano = pc_calculo_cet_limites.pr_txcetano
                          WHEN pc_calculo_cet_limites.pr_txcetano <> ? 
           par_txcetmes = pc_calculo_cet_limites.pr_txcetmes
                          WHEN pc_calculo_cet_limites.pr_txcetmes <> ? 
           aux_cdcritic = pc_calculo_cet_limites.pr_cdcritic 
                          WHEN pc_calculo_cet_limites.pr_cdcritic <> ?
           aux_dscritic = pc_calculo_cet_limites.pr_dscritic 
                          WHEN pc_calculo_cet_limites.pr_dscritic <> ?.
        
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:                                    
            ASSIGN par_dscritic = aux_dscritic.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE renovar_limite_credito_manual:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Renovar Limite de Credito Manual".
    
    /* Buscar dados do cooperado */
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF NOT AVAIL(crapass)  THEN
    DO:
        ASSIGN aux_cdcritic = 9
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic). 

        IF par_flgerlog  THEN
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
    
    FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper    AND
                             craplim.nrdconta = par_nrdconta    AND
                             craplim.tpctrlim = 1               AND
                             craplim.nrctrlim = par_nrctrlim
                             NO-LOCK NO-ERROR.

    IF  NOT AVAIL craplim THEN
    DO:
        ASSIGN aux_cdcritic = 484
               aux_dscritic = " ".
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic). 
    
        RETURN "NOK".  
    END.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_renovar_limite_cred_manual
        aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT par_cdcooper, /* Código da Cooperativa */
                      INPUT par_cdoperad, /* Código do Operador */
                      INPUT par_nmdatela, /* Nome da Tela */
                      INPUT par_idorigem, /* Origem */
                      INPUT par_nrdconta, /* Número da Conta */
                      INPUT par_idseqttl, /* Titular da Conta */
                      INPUT par_dtmvtolt, /* Data de Movimento */
                      INPUT par_nrctrlim, /* Contrato */
                      OUTPUT 0,           /* Código da crítica */
                      OUTPUT "").         /* Descrição da crítica */
   
    CLOSE STORED-PROC pc_renovar_limite_cred_manual
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
   
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
   
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_renovar_limite_cred_manual.pr_cdcritic
                           WHEN pc_renovar_limite_cred_manual.pr_cdcritic <> ?
           aux_dscritic = pc_renovar_limite_cred_manual.pr_dscritic
                           WHEN pc_renovar_limite_cred_manual.pr_dscritic <> ?.

    IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
       DO:
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
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

/******************************************************************************/
/**           Procedure para validar proposta de limite de credito           **/
/******************************************************************************/
PROCEDURE validar-alteracao-limite:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inconfir AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vllimite AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgimpnp AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cddlinha AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_inconfi2 AS INTE                           NO-UNDO.
        
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-grupo.
    
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0138 AS HANDLE                                  NO-UNDO. 
    DEF VAR h-b1wgen0110 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_flgerros AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.
    
    DEF VAR aux_vlmaxleg AS DECI                                    NO-UNDO.
    DEF VAR aux_vlmaxutl AS DECI                                    NO-UNDO.
    DEF VAR aux_vlutiliz AS DECI                                    NO-UNDO.
    DEF VAR aux_vlcalcul AS DECI                                    NO-UNDO.
    DEF VAR aux_vllimite AS DECI                                    NO-UNDO.
    
    DEF VAR aux_dsmensag AS CHAR                                    NO-UNDO.

    DEF VAR aux_dsdrisco AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdgrupo AS INTE                                    NO-UNDO.
    DEF VAR aux_gergrupo AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdrisgp AS CHAR                                    NO-UNDO.
    DEF VAR aux_pertengp AS LOGI                                    NO-UNDO.
    DEF VAR aux_dsoperac AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-grupo.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validar novo limite de credito".

    /* Buscar dados do cooperado */
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF NOT AVAIL(crapass)  THEN
       DO:
           ASSIGN aux_cdcritic = 9
                  aux_dscritic = "".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           IF par_flgerlog  THEN
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
    
    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p
           PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    ASSIGN aux_dsoperac = "Tentativa de alterar/incluir limite de credito "   +
                          "na conta " + STRING(crapass.nrdconta,"zzzz,zzz,9") +
                          " - CPF/CNPJ "                                      +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),
                                     "xx.xxx.xxx/xxxx-xx")).


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
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT 8, /*cdoperac*/
                                      INPUT aux_dsoperac,
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

          IF par_flgerlog  THEN
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


    RUN obtem-registro-limite (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtmvtolt,
                               INPUT FALSE,
                              OUTPUT TABLE tt-erro).
                               
    IF  RETURN-VALUE = "NOK"  THEN
        DO:   
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
                
    ASSIGN aux_inpessoa = IF  crapass.inpessoa = 1  THEN
                              1
                          ELSE
                              2
           aux_vllimite = IF  AVAILABLE craplim  THEN
                              craplim.vllimite
                          ELSE
                              0.
    
    /* Validacao de linha nao cadastrada */
    FIND craplrt WHERE craplrt.cdcooper = par_cdcooper   AND
                       craplrt.cddlinha = par_cddlinha   
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craplrt  THEN
        DO:
            ASSIGN aux_cdcritic = 363
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

    /* Validacao de linha ativa / liberada */
    IF   craplrt.flgstlcr = NO  THEN
         DO:
            ASSIGN aux_cdcritic = 470
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

    /* Validacao de tipo de linha de acordo com o tipo de pessoa da conta */
    IF   craplrt.tpdlinha <> aux_inpessoa  THEN
         DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Tipo de linha selecionado nao corresponde " +
                                  "ao tipo de pessoa da conta.".

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
           
    IF NOT VALID-HANDLE(h-b1wgen0138) THEN
       RUN sistema/generico/procedures/b1wgen0138.p
           PERSISTENT SET h-b1wgen0138.
    
    ASSIGN aux_pertengp =  DYNAMIC-FUNCTION("busca_grupo" IN h-b1wgen0138,
                                                       INPUT par_cdcooper, 
                                                       INPUT par_nrdconta, 
                                                      OUTPUT aux_nrdgrupo,
                                                      OUTPUT aux_gergrupo, 
                                                      OUTPUT aux_dsdrisgp).

    IF par_inconfi2 = 30  AND aux_gergrupo <> "" THEN
        DO:
           IF VALID-HANDLE(h-b1wgen0138) THEN
              DELETE OBJECT h-b1wgen0138.
        
           CREATE tt-msg-confirma.

           ASSIGN tt-msg-confirma.inconfir = par_inconfi2 + 1
                  tt-msg-confirma.dsmensag = aux_gergrupo + "Confirma?".

           RETURN "OK".
                  
        END.

    IF aux_pertengp THEN
       DO: 
          /* Procedure responsavel para calcular o endividamento do grupo */
           RUN calc_endivid_grupo IN h-b1wgen0138
                                    (INPUT par_cdcooper,
                                     INPUT par_cdagenci, 
                                     INPUT par_nrdcaixa, 
                                     INPUT par_cdoperad, 
                                     INPUT par_dtmvtolt, 
                                     INPUT par_nmdatela, 
                                     INPUT par_idorigem, 
                                     INPUT aux_nrdgrupo, 
                                     INPUT TRUE, /*Consulta por conta*/
                                    OUTPUT aux_dsdrisco, 
                                    OUTPUT aux_vlutiliz,
                                    OUTPUT TABLE tt-grupo, 
                                    OUTPUT TABLE tt-erro).

           IF VALID-HANDLE(h-b1wgen0138) THEN
              DELETE OBJECT h-b1wgen0138.
           
           IF RETURN-VALUE <> "OK"   THEN
              RETURN "NOK". 
    

       END. 
    ELSE    /*nao e do grupo*/
       DO:
           IF VALID-HANDLE(h-b1wgen0138) THEN
              DELETE OBJECT h-b1wgen0138.

           IF NOT VALID-HANDLE(h-b1wgen9999) THEN
              RUN sistema/generico/procedures/b1wgen9999.p 
                  PERSISTENT SET h-b1wgen9999.
               
           IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
               DO:
                   ASSIGN aux_cdcritic = 0
                          aux_dscritic = "Handle invalido para BO b1wgen9999.".
                          
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
               
           RUN saldo_utiliza IN h-b1wgen9999 (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT par_nmdatela,
                                              INPUT par_idorigem,
                                              INPUT par_nrdconta,
                                              INPUT par_idseqttl,
                                              INPUT par_dtmvtolt,
                                              INPUT par_dtmvtopr,
                                              INPUT "",
                                              INPUT par_inproces,
                                              INPUT FALSE, /*Consulta por cpf*/
                                             OUTPUT aux_vlutiliz,
                                             OUTPUT TABLE tt-erro).
                                             
           IF VALID-HANDLE(h-b1wgen9999) THEN
              DELETE OBJECT h-b1wgen9999.

           IF  RETURN-VALUE = "NOK"  THEN
               DO:
                   FIND FIRST tt-erro NO-LOCK NO-ERROR.
                           
                   IF  AVAILABLE tt-erro  THEN
                       ASSIGN aux_cdcritic = tt-erro.cdcritic
                              aux_dscritic = tt-erro.dscritic.
          
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

    ASSIGN aux_vlmaxleg = 0
           aux_vlmaxutl = 0.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR. 

    IF  AVAILABLE crapcop  THEN
        ASSIGN aux_vlmaxleg = crapcop.vlmaxleg
               aux_vlmaxutl = crapcop.vlmaxutl.
                       
    IF  par_inconfir = 1  THEN
        DO:
            ASSIGN aux_flgerros = TRUE.

            DO WHILE TRUE:
    
                IF  par_vllimite <= 0  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Valor do limite deve ser maior" +
                                              " que zero.".
                        LEAVE.
                    END.
        
                IF  NOT CAN-FIND(craplim WHERE craplim.cdcooper = par_cdcooper  AND
                                               craplim.nrdconta = par_nrdconta  AND
                                               craplim.tpctrlim = 1             AND
                                               craplim.nrctrlim = par_nrctrlim 
                                               USE-INDEX craplim1)              THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Numero de contrato inexistente.".                        LEAVE.
                    END.

                IF  par_nrctrlim = 0  THEN
                    DO:
                        ASSIGN aux_cdcritic = 361
                               aux_dscritic = "".
                        LEAVE.
                    END.

                IF  par_vllimite > craplrt.vllimmax  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Valor acima do permitido. " +
                                              "Maximo de " + 
                                              TRIM(STRING(craplrt.vllimmax,
                                                          "zzz,zzz,zz9.99")).
                        LEAVE.
                    END.
                    
                IF  NOT par_flgimpnp  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Indicador de impressao de " +
                                              "nota promissoria invalido.".
                        LEAVE.                      
                    END.

                ASSIGN aux_flgerros = FALSE.

                LEAVE.
    
            END. /** Fim do DO WHILE TRUE **/

            IF  aux_flgerros  THEN
                DO:
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

            ASSIGN par_inconfir = par_inconfir + 1.

        END.                

    ASSIGN aux_vlcalcul = aux_vlutiliz + par_vllimite - crapass.vllimcre.
            
    IF par_inconfir = 2  THEN
       DO:
          IF aux_vlmaxutl > 0  THEN
             DO: 
                IF aux_vlcalcul > aux_vlmaxleg  THEN
                   DO: 
                      ASSIGN aux_dsmensag = "Vlr(Legal) Excedido(Utiliz. "
                                            + TRIM(STRING(aux_vlutiliz,
                                                        "zzz,zzz,zz9.99")) +
                                            " Excedido " +
                                            TRIM(STRING((aux_vlcalcul - 
                                            aux_vlmaxleg),"zzz,zzz,zz9.99")) + 
                                            ") ". 
                             
                      CREATE tt-msg-confirma.

                      ASSIGN tt-msg-confirma.inconfir = par_inconfir + 1.
                             tt-msg-confirma.dsmensag = aux_dsmensag.


                      ASSIGN aux_cdcritic = 79
                             aux_dscritic = "". 
                
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1,            /** Sequencia **/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).
                                       
                      IF par_flgerlog  THEN
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
                
                IF aux_vlcalcul > aux_vlmaxutl  THEN
                   DO:
                       ASSIGN aux_dsmensag = "Vlr(Utl) Excedido(Utiliz. " +
                              TRIM(STRING(aux_vlutiliz,"zzz,zzz,zz9.99")) +
                              " Excedido " +
                              TRIM(STRING((aux_vlcalcul - aux_vlmaxutl),
                                          "zzz,zzz,zz9.99")) +
                              "). Confirma?".
                              
                       CREATE tt-msg-confirma.

                       ASSIGN tt-msg-confirma.inconfir = par_inconfir
                              tt-msg-confirma.dsmensag = aux_dsmensag.

                       RETURN "OK".

                   END.

             END.

          ASSIGN par_inconfir = par_inconfir + 1.

       END.

    RETURN "OK".
    
END PROCEDURE.

/******************************************************************************/
/**          Procedure para cadastrar proposta de limite de credito          **/
/******************************************************************************/
PROCEDURE alterar-novo-limite:

    /*** Parametros Gerais ***/
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inconfir AS INTE                           NO-UNDO.
    /*** Dados do Novo Limite */
    DEF  INPUT PARAM par_vllimite AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgimpnp AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cddlinha AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlsalari AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlsalcon AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vloutras AS DECI                           NO-UNDO.
    /* Campos Rating */
    DEF  INPUT PARAM par_nrgarope AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinfcad AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrliquid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrpatlvr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrperger AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vltotsfn AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_perfatcl AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlalugue AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsobserv AS CHAR                           NO-UNDO.
    /** ------------------- Parametros do 1 avalista ------------------- **/
    DEF  INPUT PARAM par_nrctaav1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdaval1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdocav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdcjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tdccjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_doccjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende2av1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrfonav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_emailav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufava1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepav1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrender1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complen1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaps1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlrenme1 AS DECI                           NO-UNDO.
    /* PRJ 438 Sprint 7 */
	  DEF  INPUT PARAM par_vlrecjg1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacio1 AS INTE                           NO-UNDO.
	  DEF  INPUT PARAM par_inpesso1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasct1 AS DATE                           NO-UNDO.
    /** ------------------- Parametros do 2 avalista ------------------- **/
    DEF  INPUT PARAM par_nrctaav2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdaval2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdocav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdcjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tdccjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_doccjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende2av2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrfonav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_emailav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufava2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepav2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrender2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complen2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaps2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlrenme2 AS DECI                           NO-UNDO.
    /* PRJ 438 Sprint 7 */
	  DEF  INPUT PARAM par_vlrecjg2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacio2 AS INTE                           NO-UNDO.
	  DEF  INPUT PARAM par_inpesso2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasct2 AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inconcje AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtconbir AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idcobope AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-msg-confirma.
    DEF OUTPUT PARAM par_flmudfai AS CHAR                           NO-UNDO.

    DEF VAR h-b1wgen0021 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0043 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0191 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    
    DEF VAR aux_vlsldcap AS DECI                                    NO-UNDO.
    
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_dsfrase  AS CHAR                                    NO-UNDO. /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-craplim.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           /* Caso seja efetuada alguma alteracao na descricao deste log,
              devera ser tratado o relatorio de "demonstrativo produtos por
              colaborador" da tela CONGPR. (Fabricio - 04/05/2012) */
           aux_dstransa = "Alterar novo limite de credito".

    RUN obtem-registro-limite (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_nrdconta,
                               INPUT par_idseqttl,
                               INPUT par_dtmvtolt,
                               INPUT FALSE,
                              OUTPUT TABLE tt-erro).
                               
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
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
        
    ASSIGN aux_inpessoa = IF  crapass.inpessoa = 1  THEN
                              1
                          ELSE
                              2.

    FIND craplrt WHERE craplrt.cdcooper = par_cdcooper   AND
                       craplrt.cddlinha = par_cddlinha   NO-LOCK NO-ERROR.

    RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT
        SET h-b1wgen0021.
        
    IF  NOT VALID-HANDLE(h-b1wgen0021)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0021.".
                   
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

    RUN obtem-saldo-cotas IN h-b1wgen0021 (INPUT par_cdcooper,  
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT par_nrdconta,
                                           INPUT par_idseqttl,
                                          OUTPUT TABLE tt-saldo-cotas,
                                          OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0021.
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_cdcritic = tt-erro.cdcritic
                       aux_dscritic = tt-erro.dscritic.
                   
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

    FIND FIRST tt-saldo-cotas NO-LOCK NO-ERROR.
    
    ASSIGN aux_flgtrans = FALSE
           aux_vlsldcap = tt-saldo-cotas.vlsldcap.

    TRANSACAO:
    DO  TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:     
                                       
        IF   crapass.inpessoa > 1   THEN
             DO:
                 DO aux_contador = 1 TO 10:

                    FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper   AND
                                       crapjfn.nrdconta = par_nrdconta  
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF   NOT AVAILABLE crapjfn   THEN
                         DO:
                             IF   LOCKED crapjfn  THEN
                                  DO:
                                      aux_cdcritic = 77.
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT.
                                  END.
                             
                              CREATE crapjfn.
                              ASSIGN crapjfn.cdcooper = par_cdcooper
                                     crapjfn.nrdconta = par_nrdconta.

                         END.

                    ASSIGN crapjfn.perfatcl = par_perfatcl
                           aux_cdcritic     = 0.

                    VALIDATE crapjfn.

                    LEAVE.

                 END.  /* Fim DO .. TO */

                 IF   aux_cdcritic <>  0   THEN
                      DO:
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1,            /** Sequencia **/
                                         INPUT aux_cdcritic,
                                         INPUT-OUTPUT aux_dscritic).
     
                          UNDO TRANSACAO, LEAVE TRANSACAO.
                      END.
             END.
         
        /* cria registros na crapdoc de 19 - Contratos de limite de credito */
        ContadorDoc: DO aux_contador = 1 TO 10:
            
            FIND FIRST crapdoc WHERE 
                       crapdoc.cdcooper = par_cdcooper AND
                       crapdoc.nrdconta = par_nrdconta AND
                       crapdoc.tpdocmto = 19           AND
                       crapdoc.dtmvtolt = par_dtmvtolt AND
                       crapdoc.idseqttl = par_idseqttl 
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
            IF  NOT AVAILABLE crapdoc THEN
                DO:
                    IF  LOCKED(crapdoc) THEN
                        DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                    ASSIGN aux_cdcritic = 341.
                                    LEAVE ContadorDoc.
                                END.
                            ELSE 
                                DO: 
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT ContadorDoc.
                                END.
                        END.
                    ELSE
                        DO:
                            CREATE crapdoc.
                            ASSIGN crapdoc.cdcooper = par_cdcooper
                                   crapdoc.nrdconta = par_nrdconta
                                   crapdoc.flgdigit = FALSE
                                   crapdoc.dtmvtolt = par_dtmvtolt
                                   crapdoc.tpdocmto = 19
                                   crapdoc.idseqttl = par_idseqttl.
                            VALIDATE crapdoc.    
                            
                            LEAVE ContadorDoc.
                        END.
                END.
            ELSE
                DO:
                    ASSIGN crapdoc.flgdigit = FALSE
                           crapdoc.dtmvtolt = par_dtmvtolt.
    
                    LEAVE ContadorDoc.
                END.
        END. /* Fim do DO ContadorDoc */

        FIND craplim WHERE craplim.cdcooper = par_cdcooper AND
                           craplim.nrdconta = par_nrdconta AND
                           craplim.tpctrlim = 1            AND
                           craplim.nrctrlim = par_nrctrlim 
                           EXCLUSIVE-LOCK NO-ERROR.
        
        IF  NOT AVAIL(craplim) THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Nao foi possivel alterar proposta.".
                   
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
        
        CREATE tt-craplim.
        BUFFER-COPY craplim TO tt-craplim.
                    
        ASSIGN craplim.cddlinha    = craplrt.cddlinha
               craplim.dtpropos    = par_dtmvtolt
               craplim.insitlim    = 1
               craplim.qtdiavig    = craplrt.qtdiavig
               craplim.cdoperad    = par_cdoperad
               craplim.dsencfin[1] = craplrt.dsencfin[1]
               craplim.dsencfin[2] = craplrt.dsencfin[2]
               craplim.dsencfin[3] = craplrt.dsencfin[3]
               craplim.cdmotcan    = 0
               craplim.vllimite    = par_vllimite
               craplim.inbaslim    = IF  par_vllimite > aux_vlsldcap  THEN
                                         2 
                                     ELSE  
                                         1
               craplim.flgimpnp    = par_flgimpnp
               craplim.nrgarope    = par_nrgarope
               craplim.nrinfcad    = par_nrinfcad 
               craplim.nrliquid    = par_nrliquid
               craplim.nrperger    = par_nrperger
               craplim.nrpatlvr    = par_nrpatlvr
               craplim.vltotsfn    = par_vltotsfn
               craplim.nrctaav1    = par_nrctaav1
               craplim.nrctaav2    = par_nrctaav2
               craplim.dsendav1[1] = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE 
                                         CAPS(par_ende1av1) + " " +
                                         STRING(par_nrender1)
               craplim.dsendav1[2] = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende2av1) + " - " + 
                                         CAPS(par_nmcidav1) + " - " +
                                         STRING(par_nrcepav1,"99999,999") +
                                         " - " + CAPS(par_cdufava1)
               craplim.dsendav2[1] = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende1av2) + " " +
                                         STRING(par_nrender2)
               craplim.dsendav2[2] = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende2av2) + " - " + 
                                         CAPS(par_nmcidav2) + " - " +
                                         STRING(par_nrcepav2,"99999,999") + 
                                         " - " + CAPS(par_cdufava2)
               craplim.nmdaval1    = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         par_nmdaval1
               craplim.nmdaval2    = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE    
                                         par_nmdaval2
               craplim.dscpfav1    = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         par_dsdocav1
               craplim.dscpfav2    = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         par_dsdocav2
               craplim.nmcjgav1    = par_nmdcjav1
               craplim.nmcjgav2    = par_nmdcjav2
               craplim.dscfcav1    = par_doccjav1
               craplim.dscfcav2    = par_doccjav2
               craplim.inconcje    = par_inconcje
               craplim.dtconbir    = par_dtconbir.
                                 
        IF par_idcobope <> craplim.idcobope THEN
           DO:
         
               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

               /* Faz a vinculaçao da garantia com a proposta */
               RUN STORED-PROCEDURE pc_vincula_cobertura_operacao
               aux_handproc = PROC-HANDLE NO-ERROR (INPUT craplim.idcobope
                                                   ,INPUT par_idcobope
                                                   ,INPUT craplim.nrctrlim
                                                   ,"").

               CLOSE STORED-PROC pc_vincula_cobertura_operacao
               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

               ASSIGN aux_dscritic = pc_vincula_cobertura_operacao.pr_dscritic
                                     WHEN pc_vincula_cobertura_operacao.pr_dscritic <> ?.

               IF  aux_dscritic <> "" THEN
                   DO:
                       
                       RUN gera_erro (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT 1,            /** Sequencia **/
                                      INPUT aux_cdcritic,
                                      INPUT-OUTPUT aux_dscritic).
                                         
                       UNDO TRANSACAO, LEAVE TRANSACAO.
                 END.
                   END.
                   
               ASSIGN craplim.idcobope = par_idcobope
                      craplim.idcobefe = par_idcobope.
                                         
        RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT 
            SET h-b1wgen9999.              
              
        IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO b1wgen9999.".
                   
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
        
        RUN atualiza_tabela_avalistas IN h-b1wgen9999 (INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT par_idorigem,
                                                    INPUT "LIMITE CRED.",
                                                    INPUT par_nrdconta,
                                                    INPUT par_dtmvtolt,
                                                    INPUT 3, /* Tipo Contrato */
                                                    INPUT par_nrctrlim,
                                                    INPUT par_cdagenci,
                                                    INPUT par_nrdcaixa,
                                                    /** 1o avalista **/
                                                    INPUT par_nrctaav1,
                                                    INPUT par_nmdaval1,
                                                    INPUT par_nrcpfav1,
                                                    INPUT par_tpdocav1,
                                                    INPUT par_dsdocav1,
                                                    INPUT par_nmdcjav1,
                                                    INPUT par_cpfcjav1, 
                                                    INPUT par_tdccjav1,
                                                    INPUT par_doccjav1,
                                                    INPUT par_ende1av1,
                                                    INPUT par_ende2av1,
                                                    INPUT par_nrfonav1,
                                                    INPUT par_emailav1,
                                                    INPUT par_nmcidav1,
                                                    INPUT par_cdufava1,
                                                    INPUT par_nrcepav1,
                                                    INPUT par_cdnacio1,
                                                    INPUT 0,
                                                    INPUT par_vlrenme1,
                                                    INPUT par_nrender1,
                                                    INPUT par_complen1,
                                                    INPUT par_nrcxaps1,
                                                    INPUT par_inpesso1,
                                                    INPUT par_dtnasct1,
                                                    INPUT par_vlrecjg1,
                                                    /** 2o avalista **/
                                                    INPUT par_nrctaav2,
                                                    INPUT par_nmdaval2, 
                                                    INPUT par_nrcpfav2,
                                                    INPUT par_tpdocav2,
                                                    INPUT par_dsdocav2, 
                                                    INPUT par_nmdcjav2, 
                                                    INPUT par_cpfcjav2,
                                                    INPUT par_tdccjav2,
                                                    INPUT par_doccjav2,
                                                    INPUT par_ende1av2,
                                                    INPUT par_ende2av2,
                                                    INPUT par_nrfonav2,
                                                    INPUT par_emailav2, 
                                                    INPUT par_nmcidav2, 
                                                    INPUT par_cdufava2, 
                                                    INPUT par_nrcepav2,
                                                    INPUT par_cdnacio2,
                                                    INPUT 0,
                                                    INPUT par_vlrenme2,
                                                    INPUT par_nrender2,
                                                    INPUT par_complen2,
                                                    INPUT par_nrcxaps2,
                                                    INPUT par_inpesso2,
                                                    INPUT par_dtnasct2,
                                                    INPUT par_vlrecjg2,
                                                    INPUT "").
        
        DELETE PROCEDURE h-b1wgen9999.
        
        IF RETURN-VALUE = "NOK" THEN
        DO:
            ASSIGN aux_flgtrans = FALSE.
            UNDO TRANSACAO, LEAVE TRANSACAO.
        END.

        IF  par_nrctaav1 = 0 AND par_nmdaval1 <> ""  THEN
            DO:
                ASSIGN craplim.dscfcav1 = " "
                       craplim.dscpfav1 = TRIM(CAPS(par_tpdocav1)) + " " +
                                          TRIM(CAPS(par_dsdocav1)) + 
                                          " C.P.F. " + STRING(par_nrcpfav1).
                
                IF  par_cpfcjav1 > 0  THEN
                    DO:    
                        ASSIGN craplim.dscfcav1 = TRIM(CAPS(par_tdccjav1)) + 
                                                  " " +
                                                  TRIM(CAPS(par_doccjav1)) + 
                                                  " C.P.F. " +
                                                  STRING(par_cpfcjav1).
                    END.
            END.        

        IF  par_nrctaav2 = 0 AND par_nmdaval2 <> ""  THEN
            DO:
                ASSIGN craplim.dscfcav2 = " "
                       craplim.dscpfav2 = TRIM(CAPS(par_tpdocav2)) + " " +
                                          TRIM(CAPS(par_dsdocav2)) + 
                                          " C.P.F. " + STRING(par_nrcpfav2).
         
                IF  par_cpfcjav2 > 0  THEN
                    DO:    
                        ASSIGN craplim.dscfcav2 = TRIM(CAPS(par_tdccjav2)) + 
                                                  " " +
                                                  TRIM(CAPS(par_doccjav2)) + 
                                                  " C.P.F. " +
                                                  STRING(par_cpfcjav2).
                    END.
            END.    

        VALIDATE craplim.

        FIND crapprp WHERE crapprp.cdcooper = par_cdcooper
                       AND crapprp.nrdconta = par_nrdconta
                       AND crapprp.nrctrato = craplim.nrctrlim
                       AND crapprp.tpctrato = 1
                       EXCLUSIVE-LOCK NO-ERROR.

        IF  NOT AVAIL(crapprp) THEN
            DO:
                ASSIGN aux_flgtrans = FALSE.
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        /* CREATE crapprp. */
        ASSIGN crapprp.nrdconta    = par_nrdconta
               crapprp.nrctrato    = craplim.nrctrlim
               crapprp.tpctrato    = 1
               crapprp.vlalugue    = par_vlalugue
               crapprp.vloutras    = par_vloutras
               crapprp.vlsalari    = par_vlsalari
               crapprp.vlsalcon    = par_vlsalcon
               crapprp.dsobserv[1] = par_dsobserv
               crapprp.cdcooper    = par_cdcooper
               crapprp.dtmvtolt    = par_dtmvtolt.

        VALIDATE crapprp.

        /* Gravar as informacoes ds SCR para o titular, conjuge e avais */
        RUN sistema/generico/procedures/b1wgen0024.p 
            PERSISTENT SET h-b1wgen0024.

        RUN grava-proposta-scr IN h-b1wgen0024 (INPUT par_cdcooper,
                                                INPUT par_cdagenci,
                                                INPUT par_nrdcaixa,
                                                INPUT par_cdoperad,
                                                INPUT par_nmdatela,
                                                INPUT par_idorigem,
                                                INPUT par_dtmvtolt,
                                                INPUT par_nrdconta,
                                                INPUT 1, /* tpctrato */
                                                INPUT par_nrctrlim,
                                               OUTPUT TABLE tt-erro).


        DELETE PROCEDURE h-b1wgen0024.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
            
        /* Efetuar a chamada da rotina Oracle, para limpar as informacoes do rating -P450 Rating */
        /* procedure alterar-novo-limite */
        RUN STORED-PROCEDURE pc_grava_rating_operacao
          aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT par_cdcooper
                            ,INPUT par_nrdconta
                            ,INPUT 1            /* Tipo Contrato */
                            ,INPUT par_nrctrlim
                            ,INPUT ?
                            ,INPUT ?             /* null para pr_ntrataut */
                            ,INPUT par_dtmvtolt  /* pr_dtrating */
                            ,INPUT 0             /* pr_strating => 0 -- Nao Enviado */
                            ,INPUT 0             /* pr_orrating =>  */
                            ,INPUT par_cdoperad
                            ,INPUT ?             /* null para pr_dtrataut */
                            ,INPUT ?             /* null pr_innivel_rating */
                            ,INPUT ?
                            ,INPUT ?             /* pr_inpontos_rating     */
                            ,INPUT ?             /* pr_insegmento_rating   */
                            ,INPUT ?             /* pr_inrisco_rat_inc     */
                            ,INPUT ?             /* pr_innivel_rat_inc     */
                            ,INPUT ?             /* pr_inpontos_rat_inc    */
                            ,INPUT ?             /* pr_insegmento_rat_inc  */
                            ,INPUT ?             /* pr_efetivacao_rating   */
                            ,INPUT par_cdoperad  /* pr_cdoperad*/
                            ,INPUT par_dtmvtolt
                            ,INPUT par_vllimite
                            ,INPUT ? /*sugerido*/
                            ,INPUT "" /*Justif*/
                            ,INPUT ?
                            ,OUTPUT 0            /* pr_cdcritic */
                            ,OUTPUT "").         /* pr_dscritic */  


            /* Fechar o procedimento para buscarmos o resultado */ 
            CLOSE STORED-PROC pc_grava_rating_operacao
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

            ASSIGN aux_cdcritic  = 0
                   aux_dscritic  = ""
                   aux_cdcritic = pc_grava_rating_operacao.pr_cdcritic
                                     WHEN pc_grava_rating_operacao.pr_cdcritic <> ?
                   aux_dscritic = pc_grava_rating_operacao.pr_dscritic
                                     WHEN pc_grava_rating_operacao.pr_dscritic <> ?.
            IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
              DO:
                ASSIGN aux_flgtrans = FALSE.                
                UNDO TRANSACAO, LEAVE TRANSACAO.
              END.

        IF   RETURN-VALUE <> "OK"   THEN
             LEAVE.

        ASSIGN aux_flgtrans = TRUE.
        
    END. /** Fim do DO TRANSACTION - TRANSACAO **/

    IF   par_idorigem =  5   THEN
         DO.   
             /* Chamar apos o fechamento da transacao pois depende de valores   */
             /* anteriores no Oracle. Os erros aqui dentro sao retornados na    */
             /* tt-msg-confirma pois nao podem comprometer o resto da execucao  */
             RUN sistema/generico/procedures/b1wgen0191.p  
                 PERSISTENT SET h-b1wgen0191.
                               
             RUN Verifica_Consulta_Biro IN h-b1wgen0191
                                                  (INPUT par_cdcooper,
                                                   INPUT par_nrdconta,
                                                   INPUT 3, /* inprodut*/
                                                   INPUT par_nrctrlim,
                                                   INPUT par_cdoperad,
                                                   INPUT "A",
                                            INPUT-OUTPUT TABLE tt-msg-confirma,
                                                  OUTPUT par_flmudfai).          
             DELETE PROCEDURE h-b1wgen0191.
          
         END.

    /** Verifica se transacao foi executada com sucesso **/
    IF  NOT aux_flgtrans  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Erro na transacao. Nao foi " + 
                                          "possivel alterar limite.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.
                   
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
        DO:
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
            
            /** Numero de Contrato do Limite **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Contrato", /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
                                     INPUT tt-craplim.nrctrlim,
                                     INPUT TRIM(STRING(craplim.nrctrlim, "zzz,zzz,zz9"))).
             
            /** Valor do Limite **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Vl.Limite de Crédito", /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
                                     INPUT TRIM(STRING(tt-craplim.vllimite, "zzz,zzz,zz9.99")),
                                     INPUT TRIM(STRING(craplim.vllimite, "zzz,zzz,zz9.99"))).
        
            /** Data Alteracao do Limite **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Data de Alteraçao",  /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
                                     INPUT "",
                                     INPUT STRING(par_dtmvtolt, "99/99/9999")).
        
            /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
            /** Prazo de Vigencia **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Prazo de Vigencia (dias)",
                                     INPUT STRING(tt-craplim.qtdiavig),
                                     INPUT STRING(craplim.qtdiavig)).
            /* Fim Pj470 - SM2 */
        
            /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
            /** Encargos Financeiros **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Encargos Financeiros",
                                     INPUT STRING(tt-craplim.dsencfin[1]),
                                     INPUT STRING(craplim.dsencfin[1])).
            /* Fim Pj470 - SM2 */
        
            /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
            /** Periodicidade da Capitalizaçao **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Periodic.da Capitalizaçao",
                                     INPUT STRING(tt-craplim.dsencfin[3]),
                                     INPUT STRING(craplim.dsencfin[3])).
            /* Fim Pj470 - SM2 */
        
            /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
            /** Custo Efetivo Total (CET) **/
            { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
            RUN STORED-PROCEDURE pc_busca_cet_limite
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                 INPUT par_nrdconta,
                                                 INPUT par_nrctrlim,
                                                OUTPUT "",  /* DSFRASE */
                                                OUTPUT 0,   /* Codigo da crítica */
                                                OUTPUT ""). /* Descriçao da crítica */
            CLOSE STORED-PROC pc_busca_cet_limite
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
            ASSIGN aux_dsfrase  = ""
                   aux_cdcritic = 0
                   aux_dscritic = ""
                   aux_dsfrase  = pc_busca_cet_limite.pr_dsfrase 
                                  WHEN pc_busca_cet_limite.pr_dsfrase <> ?
                   aux_cdcritic = pc_busca_cet_limite.pr_cdcritic 
                                  WHEN pc_busca_cet_limite.pr_cdcritic <> ?
                   aux_dscritic = pc_busca_cet_limite.pr_dscritic
                                  WHEN pc_busca_cet_limite.pr_dscritic <> ?.
            IF aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
               aux_dsfrase  = "Erro ao buscar o CET".
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Custo Efetivo Total (CET)",
                                     INPUT "",
                                     INPUT STRING(aux_dsfrase)).
            /* Fim Pj470 - SM2 */
             
            /** Linha de Credito do Limite **/
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "cddlinha",
                                     INPUT tt-craplim.cddlinha,
                                     INPUT TRIM(STRING(craplim.cddlinha, "zz9"))).
                                                    
          
            /** Tipo do Limite **/
            
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "tplimcre",
                                     INPUT tt-craplim.inbaslim,
                                     INPUT TRIM(STRING(craplim.inbaslim, "9"))).
                         
        END.
        

             

    RETURN "OK".
        
END PROCEDURE.

PROCEDURE busca-dados-avalistas:

    DEF INPUT PARAM par_cdcooper    LIKE    crapcop.cdcooper            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    LIKE    crapdat.dtmvtolt            NO-UNDO.
    DEF INPUT PARAM par_cdoperad    LIKE    crapope.cdoperad            NO-UNDO.
    DEF INPUT PARAM par_nmdatela    LIKE    craptel.nmdatela            NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE    crapass.nrdconta            NO-UNDO.
    DEF INPUT PARAM par_nrctrlim    LIKE    craplim.nrctrlim            NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-dados-avais.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen0028            AS      HANDLE                      NO-UNDO.

    DEF VAR lim_nmdavali            AS      CHAR                        NO-UNDO.
    DEF VAR lim_nrcpfcgc            AS      DECI                        NO-UNDO.
    DEF VAR lim_tpdocavl            AS      CHAR                        NO-UNDO.
    DEF VAR lim_dscpfavl            AS      CHAR                        NO-UNDO.
    DEF VAR lim_nmdcjavl            AS      CHAR                        NO-UNDO.
    DEF VAR lim_nrcpfccg            AS      DECI                        NO-UNDO.
    DEF VAR lim_tpdoccjl            AS      CHAR                        NO-UNDO.
    DEF VAR lim_dscfcavl            AS      CHAR                        NO-UNDO.
    DEF VAR lim_dsendavl            AS      CHAR    EXTENT 2            NO-UNDO.
    DEF VAR lim_nmcidade            AS      CHAR                        NO-UNDO.
    DEF VAR lim_cdufresd            AS      CHAR                        NO-UNDO.
    DEF VAR lim_nrcepend            AS      INTE                        NO-UNDO.
    DEF VAR lim_nrendere            AS      INTE                        NO-UNDO.
    DEF VAR lim_complend            AS      CHAR                        NO-UNDO.
    DEF VAR lim_nrcxapst            AS      INTE                        NO-UNDO.
    
    FIND craplim WHERE craplim.cdcooper = par_cdcooper
                   AND craplim.nrdconta = par_nrdconta
                   AND craplim.tpctrlim = 1
                   AND craplim.nrctrlim = par_nrctrlim
                   NO-LOCK NO-ERROR.

    IF  AVAIL(craplim) THEN
        DO:
        
            RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.

                IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                   DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Handle invalido para BO "
                                              + "b1wgen9999.".
                        LEAVE.
                        END.
                    
                RUN lista_avalistas IN h-b1wgen9999
                                              ( INPUT  par_cdcooper,
                                                INPUT  0,
                                                INPUT  0,
                                                INPUT  par_cdoperad,
                                                INPUT  par_nmdatela,
                                                INPUT  1,
                                                INPUT par_nrdconta,
                                                INPUT  1,
                                                INPUT 3,
                                                INPUT par_nrctrlim,
                                                INPUT  craplim.nrctaav1,
                                                INPUT craplim.nrctaav2,
                                                OUTPUT TABLE tt-dados-avais,
                                                OUTPUT TABLE tt-erro). 

                DELETE PROCEDURE h-b1wgen9999.

                IF  RETURN-VALUE <> "OK"  THEN
                        RETURN "NOK".
        
        END. 

    RETURN "OK".
END PROCEDURE.

/***************************************************************************
 Procedure para alterar o numero da proposta de limite de crédito.
 Opcao de Alterar na rotina Descontos da tela ATENDA. 
***************************************************************************/
PROCEDURE altera-numero-proposta-limite:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrant AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR     aux_contador     AS INTE                           NO-UNDO.
    DEF  VAR     aux_dsoperac     AS CHAR                           NO-UNDO.
    DEF  VAR     aux_nrctrlim     AS INTE                           NO-UNDO.
    DEF  VAR     h-b1wgen0110     AS HANDLE                         NO-UNDO.
    DEF  VAR     aux_habrat       AS CHAR                           NO-UNDO. /* P450 - Rating */

    DEF  BUFFER  crabavt          FOR crapavt.
    DEF  BUFFER  crabavl          FOR crapavl.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alterar o numero da proposta de limite de credito".

    IF  par_nrctrlim <= 0 THEN
        DO:
            ASSIGN aux_dscritic = "Numero da proposta deve ser diferente de zero.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass THEN
        DO:
            ASSIGN aux_cdcritic = 9.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
       END.

    IF  NOT VALID-HANDLE(h-b1wgen0110) THEN
        RUN sistema/generico/procedures/b1wgen0110.p PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    ASSIGN aux_dsoperac = "Tentativa de alterar o numero da proposta "  +
                          "de limite de credito na conta " +
                          STRING(crapass.nrdconta,"zzzz,zzz,9")            +
                          " - CPF/CNPJ "                                   +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),"xx.xxx.xxx/xxxx-xx")).

    /*Verifica se o associado esta no cadastro restritivo*/
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
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT 11, /*cdoperac*/
                                      INPUT aux_dsoperac,
                                      OUTPUT TABLE tt-erro).

    IF VALID-HANDLE(h-b1wgen0110) THEN
       DELETE PROCEDURE(h-b1wgen0110).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
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

            RETURN "NOK".
        END.

    DO TRANSACTION WHILE TRUE:

        /* Verifica se ja existe contrato com o numero informado */
        FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper    AND
                                 craplim.nrdconta = par_nrdconta    AND
                                 craplim.tpctrlim = 1 /* Chq Esp */ AND
                                 craplim.nrctrlim = par_nrctrlim
                                 NO-LOCK NO-ERROR.

        IF   AVAIL craplim   THEN
             DO:
                 aux_dscritic =
                     "Numero da proposta de limite de credito ja existente.".
                 LEAVE.
             END.

        /* Encontra contrato atual */
        FIND craplim WHERE craplim.cdcooper =  par_cdcooper    AND
                           craplim.nrdconta =  par_nrdconta    AND
                           craplim.tpctrlim =  1 /* Chq Esp */ AND
                           craplim.nrctrlim =  par_nrctrant     
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL craplim   THEN
             DO:
                aux_dscritic = "Proposta de limite nao existente.".
                LEAVE.
             END.

        /* Verifica se o contrato atual ja foi efetivado. */
        IF   craplim.insitlim <> 1   THEN
             DO:
                aux_dscritic = "Proposta de limite ja efetivada.".
                LEAVE.
             END.

        FIND FIRST crapprp WHERE crapprp.cdcooper = par_cdcooper    AND
                                 crapprp.nrdconta = par_nrdconta    AND
                                 crapprp.nrctrato = par_nrctrlim    AND
                                 crapprp.tpctrato = 1 /* Chq Esp */
                                 NO-LOCK NO-ERROR.

        IF   AVAIL crapprp   THEN
             DO:
                aux_dscritic =
                     "Numero de proposta de limite ja existente.".
                 LEAVE.
             END.


        DO aux_contador = 1 TO 10:

            FIND craplim WHERE craplim.cdcooper =  par_cdcooper     AND
                               craplim.nrdconta =  par_nrdconta     AND
                               craplim.tpctrlim =  1 /* Chq Esp */  AND
                               craplim.nrctrlim =  par_nrctrant 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAIL craplim  THEN
                IF  LOCKED craplim THEN
                    DO:
                        aux_cdcritic = 341.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        aux_cdcritic = 535.
                        LEAVE.
                    END.

            aux_cdcritic = 0.
            LEAVE.

        END. /* DO TO */

        IF  aux_cdcritic <> 0 OR
            aux_dscritic <> ""  THEN
            UNDO, LEAVE.

        /* Mudar o numero do contrato */
        ASSIGN aux_nrctrlim     = craplim.nrctrlim
               craplim.nrctrlim = par_nrctrlim.

        /* Faz a vinculaçao da garantia com a proposta */
        RUN STORED-PROCEDURE pc_vincula_cobertura_operacao
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT 0
                                            ,INPUT craplim.idcobope
                                            ,INPUT craplim.nrctrlim
                                            ,"").

        CLOSE STORED-PROC pc_vincula_cobertura_operacao
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic = pc_vincula_cobertura_operacao.pr_dscritic
                             WHEN pc_vincula_cobertura_operacao.pr_dscritic <> ?.

        IF  aux_dscritic <> "" THEN
            UNDO, LEAVE.

        /* Avalistas terceiros, intervenientes anuentes */
        FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper      AND
                               crapavt.tpctrato = 3 /* Chq Esp */   AND
                               crapavt.nrdconta = par_nrdconta      AND
                               crapavt.nrctremp = par_nrctrant      NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabavt WHERE crabavt.cdcooper = crapavt.cdcooper   AND
                                   crabavt.nrdconta = crapavt.nrdconta   AND
                                   crabavt.tpctrato = crapavt.tpctrato   AND
                                   crabavt.nrctremp = crapavt.nrctremp   AND
                                   crabavt.nrcpfcgc = crapavt.nrcpfcgc
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL crabavt  THEN
                    IF  LOCKED crabavt THEN
                        DO:
                            aux_cdcritic = 77.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            aux_cdcritic = 869.
                            LEAVE.
                        END.

                aux_cdcritic = 0.
                LEAVE.
            END. /* TO DO */

            IF  aux_cdcritic <> 0   THEN
                LEAVE.

            /* Atualizar numero contrato */
            ASSIGN crabavt.nrctremp = par_nrctrlim.

        END.

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.

        /* Avalistas cooperados */
        FOR EACH crapavl WHERE crapavl.cdcooper = par_cdcooper      AND
                               crapavl.nrctaavd = par_nrdconta      AND
                               crapavl.nrctravd = par_nrctrant      AND
                               crapavl.tpctrato = 3 /* Chq Esp */   NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabavl WHERE crabavl.cdcooper = crapavl.cdcooper   AND
                                   crabavl.nrdconta = crapavl.nrdconta   AND
                                   crabavl.nrctravd = crapavl.nrctravd   AND
                                   crabavl.tpctrato = crapavl.tpctrato
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL crabavl  THEN
                    IF  LOCKED crabavl THEN
                        DO:
                            aux_cdcritic = 77.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            aux_cdcritic = 869.
                            LEAVE.
                        END.

                aux_cdcritic = 0.
                LEAVE.
            END. /* TO DO */

            IF   aux_cdcritic <> 0   THEN
                 LEAVE.

            /* Mudar o numero do contrato */
            ASSIGN crabavl.nrctravd = par_nrctrlim.
        END.

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.

        /* Proposta */
        DO aux_contador = 1 TO 10:

            FIND crapprp WHERE crapprp.cdcooper = par_cdcooper     AND
                               crapprp.nrdconta = par_nrdconta     AND
                               crapprp.tpctrato = 1 /* Chq Esp */  AND
                               crapprp.nrctrato = par_nrctrant
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            IF  NOT AVAIL crapprp  THEN
                IF  LOCKED crapprp THEN
                    DO:
                        aux_cdcritic = 341.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        aux_cdcritic = 535.
                        LEAVE.
                    END.

            aux_cdcritic = 0.
            LEAVE.
        END. /* TO DO */

        IF  aux_cdcritic <> 0   THEN
            UNDO, LEAVE.

        FIND FIRST crapprm WHERE crapprm.nmsistem = 'CRED' AND
                                 crapprm.cdacesso = 'HABILITA_RATING_NOVO' AND
                                 crapprm.cdcooper = par_cdcooper
                                 NO-LOCK NO-ERROR.

        ASSIGN aux_habrat = 'N'.
        IF AVAIL crapprm THEN DO:
          ASSIGN aux_habrat = crapprm.dsvlrprm.
        END.

        /* Habilita novo rating */
        IF aux_habrat = 'S' AND par_cdcooper <> 3 THEN DO:

          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
          /* Efetuar a chamada da rotina Oracle, altera contrato no rating -P450 Rating */
          RUN STORED-PROCEDURE pc_atualiza_contrato_rating
            aux_handproc = PROC-HANDLE NO-ERROR
                              (INPUT par_cdcooper
                              ,INPUT par_nrdconta
                              ,INPUT 1            /* Limiti de credito*/
                              ,INPUT crapprp.nrctrato
                              ,INPUT par_nrctrlim
                              ,OUTPUT 0            /* pr_cdcritic */
                              ,OUTPUT "").         /* pr_dscritic */  


            /* Fechar o procedimento para buscarmos o resultado */ 
            CLOSE STORED-PROC pc_atualiza_contrato_rating
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

            ASSIGN aux_cdcritic  = 0
                   aux_dscritic  = ""
                   aux_cdcritic = pc_atualiza_contrato_rating.pr_cdcritic
                                     WHEN pc_atualiza_contrato_rating.pr_cdcritic <> ?
                   aux_dscritic = pc_atualiza_contrato_rating.pr_dscritic
                                     WHEN pc_atualiza_contrato_rating.pr_dscritic <> ?.
            IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
              DO:
                UNDO, LEAVE.
              END.
        END.
        /* Habilita novo rating */

        /* Novo numero de contrato */
        ASSIGN crapprp.nrctrato = par_nrctrlim.

        LEAVE.

    END. /* Fim TRANSACTION , tratamento criticas */

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
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

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN
        DO:
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

            IF  aux_nrctrlim <> par_nrctrlim THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "nrctrlim",
                                         INPUT aux_nrctrlim,
                                         INPUT par_nrctrlim).
        END.
        
    RETURN "OK".

END PROCEDURE.
/* .......................................................................... */
