/******************************************************************************
             ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
            
  +-------------------------------------+--------------------------------------+
  | Rotina Progress                     | Rotina Oracle PLSQL                  |
  +-------------------------------------+--------------------------------------+
  | b1wgen0115.p                        | TELA_ADITIV                          |
  | Gera_Impressao_nova                 | TELA_ADITIV.pc_gera_impressao_aditiv |
  | Trata_Assinatura                    | TELA_ADITIV.pc_Trata_Assinatura      |
  | Trata_Dados_Assinatura              | TELA_ADITIV.pc_Trata_Dados_Assinatura|
  | Busca_Dados                         | TELA_ADITIV.pc_busca_dados_aditiv    |  
  +-------------------------------------+--------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0115.p
    Autor   : Gabriel Capoia (DB1)
    Data    : Setembro/2011                     Ultima atualizacao: 01/11/2017

    Objetivo  : Tranformacao BO tela ADITIV

    Alteracoes: 18/02/2000 -  Nao permitir alterar a data de débito para
                              empréstimos Price Pre-fixado. (Irlan )

                18/09/2012 - Novos parametros DATA na chamada da procedure
                             obtem-dados-aplicacoes (Guilherme/Supero).

                06/05/2013 - Adicionada área de uso da Digitalizaçao (Lucas).

                15/08/2013 - Incluido a chamada da procedure
                             "atualiza_data_manutencao_garantia" dentro da
                             procedure "grava_dados" (James).

                28/10/2013 - Incluido parametro do nr do aditivo do frame
                             da impressao (Jean Michel).

                31/10/2013 - Incluido flgdigit = YES para aditivos do tipo
                             7 e 8, feito esta alteraçao p/ nao aparecer
                             no relatório do batimento (Jean Michel).

                07/11/2013 - Projeto GRAVAMES - Atualizacao Bens
                             (Guilherme/SUPERO)

                11/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)

                16/12/2013 - Alterado forms f_assinatura_avalistas,
                             f_tipo2_parte1 e f_tipo3_parte1 de "CPF/CGC" para
                             "CPF/CNPJ". (Reinert)

                26/02/2014 - Remocao do comentario do tratamento do GRAVAMES
                           - Permitir NrRenava, UfdPlaca e NrdPlaca em branco
                             quando 5 - Substituicao de Veiculo
                           - Novos parametros na Grava_Dados
                           - Gravar campos novos nrcpfcgc crapbpr
                             (Guilherme/SUPERO)

                22/05/2014 - GRAVAMES: Alteracao das procedures
                             - grava_dados
                             - busca_dados
                             - gera_impressao
                             para gravar, buscar e imprimir o cpf e nome do
                             avalista, quando Subst. de Veiculos (tipo 5)
                             (Guilherme/SUPERO)

                30/05/2014 - Alterado a busca do estado civil da crapass para
                             crapttl (Douglas - Chamado 131253)

                22/07/2014 - Ajustes da criacao do registro da tabela crapbpr
                             em proc. Grava_Dados, verificando o proximo indice
                             do tipo 99 a ser criado.
                             Adicionado limpeza da tt-erro em proc. Grava_Dados
                             (Jorge/Gielow) - SD 177100

                30/07/2014 - Adicionado replace de caracteres que possam dar
                             erro na monstagem da string do bem.
                            (Jorge/Gielow) - SD 183551

                14/10/2014 - Processar rotinas Gravames apenas quando a coop
                             estiver liberada e apos data de liberacao desta
                             (Guilherme/SUPERO)

                22/10/2014 - Para os contratos acima de 22/10/2014 nao deve-se
                             imprimir os aditivos (Projeto Contratos)
                             (Andrino-RKAM).

                04/11/2014 - Alteraçao da mensagem com critica 77 substituindo
                             pela b1wgen9999.p procedure acha-lock, que
                             identifica qual o usuario que esta prendendo a
                             transaçao. (Vanessa)

                07/11/2014 - Termos aditivos. (Jonata-RKAM).

                12/11/2014 - Ajuste na data de corte para liberacao do GRAVAMES
                             para Viacredi a partir de 18/11/2014.
                             Tambem ajustada as condicoes de data de corte para
                             comprender o dia do corte tambem (>=)
                             (Marcos-Supero)

                21/11/2014 - Retirada do tratamento da critica 77 (Vanessa)
                15/12/2014 - Adicionado tratamento para novos produtos de
                             captacao. (Reinert)

                23/12/2014 - Liberacao rotinas Gravames para todas as Coops
                             (Guilherme/SUPERO)

                05/01/2015 - Ajuste format numero contrato/bordero na area
                             de 'USO DA DIGITALIZACAO'; adequacao ao format
                             pre-definido para nao ocorrer divergencia ao
                             pesquisar no SmartShare.
                             (Chamado 181988) - (Fabricio)

                12/01/2015 - Remocao de linhas no momento de imprimir o
                             aditivo na procedure 'gera_impressao_antiga'.
                             As assinaturas das testemunhas estavam
                             quebrando para a 2 pagina. (Jaison - SD: 240683)

                26/01/2015 - Alterado o formato do campo nrctremp para 8
                             caracters (Kelvin - 233714)

                26/03/2015 - Alteracao data de liberacao Gravames demais coops
                             Tratamento para no Grava_Dados para gravar o
                             dschassi sempre maiusculo
                             Nao permitir excluir/substituir bem que esteja
                             "Em Processamento" no Gravames
                             (Guilherme/SUPERO)

               25/05/2015 - Adicionar campos cdagenci,cdoperad no create da 
                            tabela crapadt (Lucas Ranghetti #288277)
                            
               02/06/2015 - Projeto 209 Revisao Contratos,
                            Alteracoes nos modelos de impressao de 
                            aditivos de contrato (Tiago Castro - RKAM)
                            
               01/12/2015 - Incluir busca do pa de trabalho na procedure 
                            Grava_dados na gravacao dos aditivos 
                            (Lucas Ranghetti #366888 )
                            
               03/08/2016 - Alterar rotina Gera_Impressao para chamar versao convertida 
                            oracle. PRJ314 - Indexacao centralizada (Odirlei-AMcom)
                            
               19/04/2017 - Alteraçao DSNACION pelo campo CDNACION.
                            PRJ339 - CRM (Odirlei-AMcom)

               01/11/2017 - Ajustes conforme inclusao do campo tipo de contrato.
                            (Jaison/Marcos Martini - PRJ404)

............................................................................*/

/*............................. DEFINICOES .................................*/

{ sistema/generico/includes/b1wgen0115tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0168tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF VAR aux_nrsequex AS INTE                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                        NO-UNDO.
DEF VAR par_loginusr AS CHAR                                        NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                        NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                        NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                        NO-UNDO.
DEF VAR par_numipusr AS CHAR                                        NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                      NO-UNDO.


DEF VAR aux_dsaditiv AS CHAR    FORMAT "x(36)"  EXTENT 8
           INIT ["1- Alteracao Data do Debito",
                 "2- Aplicacao Vinculada",
                 "3- Aplicacao Vinculada Terceiro",
                 "4- Inclusao de Fiador/Avalista",
                 "5- Substituicao de Veiculo",
                 "6- Interveniente Garantidor Veiculo",
                 "7- Sub-rogacao - C/ Nota Promissoria",
                 "8- Sub-rogacao - S/ Nota Promissoria"]            NO-UNDO.

/* Variáveis utilizadas para receber clob da rotina no oracle */
DEF VAR xDoc          AS HANDLE   NO-UNDO.
DEF VAR xRoot         AS HANDLE   NO-UNDO.
DEF VAR xRoot2        AS HANDLE   NO-UNDO.
DEF VAR xRoot3        AS HANDLE   NO-UNDO.
DEF VAR xRoot4        AS HANDLE   NO-UNDO.
DEF VAR xField        AS HANDLE   NO-UNDO.
DEF VAR xField2       AS HANDLE   NO-UNDO.
DEF VAR xField3       AS HANDLE   NO-UNDO.
DEF VAR xText         AS HANDLE   NO-UNDO.
DEF VAR xText2        AS HANDLE   NO-UNDO.
DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO.
DEF VAR aux_cont      AS INTEGER  NO-UNDO.
DEF VAR aux_cont2     AS INTEGER  NO-UNDO.
DEF VAR aux_cont3     AS INTEGER  NO-UNDO.
DEF VAR aux_cont4     AS INTEGER  NO-UNDO.
DEF VAR aux_cont5     AS INTEGER  NO-UNDO.
DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO.
DEF VAR xml_req       AS LONGCHAR NO-UNDO.

FUNCTION f_datapossivel RETURNS DATE PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_dtmvtolt AS DATE,
      INPUT par_nrdconta AS INTEGER,
      INPUT par_nrctremp AS INTEGER,
     OUTPUT par_cdcritic AS INTEGER ) FORWARD.

FUNCTION f_pagou_no_mes RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_nrdconta AS INTEGER,
      INPUT par_nrctremp AS INTEGER,
      INPUT par_dtultdma AS DATE,
      INPUT par_vlpreemp AS DECIMAL ) FORWARD.

/*................................ PROCEDURES ..............................*/

/* ------------------------------------------------------------------------ */
/*                EFETUA A BUSCA DOS DADOS DO ASSOCIADO                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolx AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nraditiv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdaditiv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpaplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctagar AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagin AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-aditiv.
    DEF OUTPUT PARAM TABLE FOR tt-aplicacoes.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-aditiv.
    EMPTY TEMP-TABLE tt-aplicacoes.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_returnvl = "OK".

    /* Inicializando objetos para leitura do XML */
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */
    CREATE X-NODEREF  xRoot3.  /* Vai conter a tag aplicacao em diante */
    CREATE X-NODEREF  xRoot4.  /* Vai conter a tag aplicacao em diante */
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */
    CREATE X-NODEREF  xField2. /* Vai conter os campos dentro da tag INF */
    CREATE X-NODEREF  xField3. /* Vai conter os campos dentro da tag INF */
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */
    CREATE X-NODEREF  xText2.  /* Vai conter o texto que existe dentro da tag xField */

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada a rotina Oracle */
    RUN STORED-PROCEDURE pc_busca_dados_aditiv_prog
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                        ,INPUT par_cdagenci
                                        ,INPUT par_nrdcaixa
                                        ,INPUT par_cdoperad
                                        ,INPUT par_nmdatela
                                        ,INPUT par_idorigem
                                        ,INPUT STRING(par_dtmvtolt,"99/99/9999")
                                        ,INPUT STRING(par_dtmvtopr,"99/99/9999")
                                        ,INPUT par_inproces
                                        ,INPUT par_cddopcao
                                        ,INPUT par_nrdconta
                                        ,INPUT par_nrctremp
                                        ,INPUT STRING(par_dtmvtolx,"99/99/9999")
                                        ,INPUT par_nraditiv
                                        ,INPUT par_cdaditiv
                                        ,INPUT par_tpaplica
                                        ,INPUT par_nrctagar
                                        ,INPUT par_tpctrato
                                        ,INPUT INT(par_flgpagin)
                                        ,INPUT par_nrregist
                                        ,INPUT par_nriniseq
                                        ,INPUT INT(par_flgerlog)
                                        ,OUTPUT 0     /* pr_qtregist */
                                        ,OUTPUT ?     /* pr_clob_xml */
                                        ,OUTPUT 0     /* pr_cdcritic */
                                        ,OUTPUT "").  /* pr_dscritic */

    /* Fechar o procedimento para buscarmos o resultado */
    CLOSE STORED-PROC pc_busca_dados_aditiv_prog
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    /* Busca possíveis erros */
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_busca_dados_aditiv_prog.pr_cdcritic
                          WHEN pc_busca_dados_aditiv_prog.pr_cdcritic <> ?
           aux_dscritic = pc_busca_dados_aditiv_prog.pr_dscritic
                          WHEN pc_busca_dados_aditiv_prog.pr_dscritic <> ?.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK"
                   aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                   aux_dstransa = "Busca Aditivo Contratual.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog AND par_nrdconta > 0  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
        END.
    ELSE
        DO:
            /* Buscar o XML na tabela de retorno da procedure Progress */
            ASSIGN xml_req      = pc_busca_dados_aditiv_prog.pr_clob_xml
                   par_qtregist = pc_busca_dados_aditiv_prog.pr_qtregist.

            /* Efetuar a leitura do XML*/
            SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1.
            PUT-STRING(ponteiro_xml,1) = xml_req.

            xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE).
            xDoc:GET-DOCUMENT-ELEMENT(xRoot).

            DO  aux_cont = 1 TO xRoot:NUM-CHILDREN:

                xRoot:GET-CHILD(xRoot2,aux_cont).

                IF xRoot2:SUBTYPE <> "ELEMENT"   THEN
                   NEXT.

                DO  aux_cont2 = 1 TO xRoot2:NUM-CHILDREN:
                  
                  xRoot2:GET-CHILD(xRoot3,aux_cont2).

                  IF xRoot3:SUBTYPE <> "ELEMENT" THEN
                     NEXT.
                      
                  IF xRoot2:NAME = "aditivos" THEN                      
                    CREATE tt-aditiv.
                  ELSE
                    CREATE tt-aplicacoes.
                    
                  DO  aux_cont3 = 1 TO xRoot3:NUM-CHILDREN:

                    xRoot3:GET-CHILD(xField,aux_cont3).

                    IF xField:SUBTYPE <> "ELEMENT" THEN
                       NEXT.

                    IF xField:NUM-CHILDREN = 0   THEN
                       NEXT.
                                 
                    xField:GET-CHILD(xText,1).
                    
                    /* Se for tag de aditivos */
                    IF xRoot2:NAME = "aditivos" THEN
                       DO:
                          ASSIGN tt-aditiv.nrdconta = INTE(xText:NODE-VALUE) WHEN xField:NAME = "nrdconta"
                                 tt-aditiv.nrctremp = INTE(xText:NODE-VALUE) WHEN xField:NAME = "nrctremp"
                                 tt-aditiv.nraditiv = INTE(xText:NODE-VALUE) WHEN xField:NAME = "nraditiv"
                                 tt-aditiv.cdaditiv = INTE(xText:NODE-VALUE) WHEN xField:NAME = "cdaditiv"
                                 tt-aditiv.dsaditiv = xText:NODE-VALUE WHEN xField:NAME = "dsaditiv"
                                 tt-aditiv.dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt"
                                 tt-aditiv.nrctagar = INTE(xText:NODE-VALUE) WHEN xField:NAME = "nrctagar"
                                 tt-aditiv.nrcpfgar = DECI(xText:NODE-VALUE) WHEN xField:NAME = "nrcpfgar"
                                 tt-aditiv.nrdocgar = xText:NODE-VALUE WHEN xField:NAME = "nrdocgar"
                                 tt-aditiv.nmdgaran = xText:NODE-VALUE WHEN xField:NAME = "nmdgaran"
                                 tt-aditiv.flgpagto = LOGICAL(INTE(xText:NODE-VALUE)) WHEN xField:NAME = "flgpagto"
                                 tt-aditiv.dtdpagto = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtdpagto"
                                 tt-aditiv.dsbemfin = xText:NODE-VALUE WHEN xField:NAME = "dsbemfin"
                                 tt-aditiv.dschassi = xText:NODE-VALUE WHEN xField:NAME = "dschassi"
                                 tt-aditiv.nrdplaca = xText:NODE-VALUE WHEN xField:NAME = "nrdplaca"
                                 tt-aditiv.dscorbem = xText:NODE-VALUE WHEN xField:NAME = "dscorbem"
                                 tt-aditiv.nranobem = INTE(xText:NODE-VALUE) WHEN xField:NAME = "nranobem"
                                 tt-aditiv.nrmodbem = INTE(xText:NODE-VALUE) WHEN xField:NAME = "nrmodbem"
                                 tt-aditiv.nrrenava = INTE(xText:NODE-VALUE) WHEN xField:NAME = "nrrenava"
                                 tt-aditiv.tpchassi = INTE(xText:NODE-VALUE) WHEN xField:NAME = "tpchassi"
                                 tt-aditiv.ufdplaca = xText:NODE-VALUE WHEN xField:NAME = "ufdplaca"
                                 tt-aditiv.uflicenc = xText:NODE-VALUE WHEN xField:NAME = "uflicenc"
                                 tt-aditiv.nmdavali = xText:NODE-VALUE WHEN xField:NAME = "nmdavali"
                                 tt-aditiv.tpdescto = INTE(xText:NODE-VALUE) WHEN xField:NAME = "tpdescto"
                                 tt-aditiv.dscpfavl = xText:NODE-VALUE WHEN xField:NAME = "dscpfavl"
                                 tt-aditiv.nrcpfcgc = DECI(xText:NODE-VALUE) WHEN xField:NAME = "nrcpfcgc"
                                 tt-aditiv.nrsequen = INTE(xText:NODE-VALUE) WHEN xField:NAME = "nrsequen"
                                 tt-aditiv.idseqbem = INTE(xText:NODE-VALUE) WHEN xField:NAME = "idseqbem".

                          IF xField:NAME = "promissorias" THEN
                             DO:
                                DO  aux_cont4 = 1 TO xField:NUM-CHILDREN:

                                  xField:GET-CHILD(xField2,aux_cont4).

                                  IF xField2:SUBTYPE <> "ELEMENT" THEN
                                      NEXT.

                                  IF xField2:NUM-CHILDREN = 0 THEN
                                      NEXT.

                                  DO  aux_cont5 = 1 TO xField2:NUM-CHILDREN:
                                  
                                    xField2:GET-CHILD(xField3,aux_cont5).

                                    IF xField3:SUBTYPE <> "ELEMENT" THEN
                                        NEXT.

                                    IF xField3:NUM-CHILDREN = 0 THEN
                                        NEXT.
                                  
                                    xField3:GET-CHILD(xText2,1).
                                  
                                    ASSIGN aux_nrsequex = INTE(xText2:NODE-VALUE) WHEN xField3:NAME = "nrseqpro"
                                           tt-aditiv.nrpromis[aux_nrsequex] = xText2:NODE-VALUE WHEN xField3:NAME = "nrpromis"
                                           tt-aditiv.vlpromis[aux_nrsequex] = DECI(xText2:NODE-VALUE) WHEN xField3:NAME = "vlpromis".
                                  END.
                                  
                                END.
                             END.
                       END.
                    ELSE
                       DO:
                          ASSIGN tt-aplicacoes.nraplica = INTE(xText:NODE-VALUE) WHEN xField:NAME = "nraplica"
                                 tt-aplicacoes.dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt"
                                 tt-aplicacoes.dshistor = xText:NODE-VALUE WHEN xField:NAME = "dshistor"
                                 tt-aplicacoes.vlaplica = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlaplica"
                                 tt-aplicacoes.nrdocmto = xText:NODE-VALUE WHEN xField:NAME = "nrdocmto"
                                 tt-aplicacoes.dtvencto = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtvencto"
                                 tt-aplicacoes.vlsldapl = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsldapl"
                                 tt-aplicacoes.sldresga = DECI(xText:NODE-VALUE) WHEN xField:NAME = "sldresga".
                       END.
                  END.

                END.

            END.

            SET-SIZE(ponteiro_xml) = 0.

            DELETE OBJECT xDoc.
            DELETE OBJECT xRoot.
            DELETE OBJECT xRoot2.
            DELETE OBJECT xRoot3.
            DELETE OBJECT xRoot4.
            DELETE OBJECT xField.
            DELETE OBJECT xField2.
            DELETE OBJECT xField3.
            DELETE OBJECT xText.
            DELETE OBJECT xText2.
        END.

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Dados */

/* ------------------------------------------------------------------------- */
/*                  Efetua a Validaçao dos dados informados                  */
/* ------------------------------------------------------------------------- */
PROCEDURE Valida_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdaditiv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagto AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctagar AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfgar AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsbemfin AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrrenava AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpchassi AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dschassi AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdplaca AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ufdplaca AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dscorbem AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nranobem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrmodbem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_uflicenc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc LIKE crapbpr.nrcpfbem             NO-UNDO.
    DEF  INPUT PARAM par_nmdgaran AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocgar AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlpromis AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-aplicacoes.

    DEF OUTPUT PARAM aux_nmdgaran AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_flgaplic AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR pro_dtcalcul AS DATE                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    DEF BUFFER crabass FOR crapass.

    ASSIGN aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida Aditivos Contratuais de Operacoes de Credito"
           aux_cdcritic = 0
           aux_flgaplic = NO
           aux_returnvl = "NOK"
           aux_nmdgaran = par_nmdgaran.

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        IF  CAN-DO("I,E",par_cddopcao) AND
            par_tpctrato = 90          THEN
            DO:
                CASE par_cdaditiv:

                    WHEN 1 THEN
                        DO:
                            IF  CAN-FIND(FIRST crapepr WHERE
                                               crapepr.cdcooper = par_cdcooper AND
                                               crapepr.nrdconta = par_nrdconta AND
                                               crapepr.nrctremp = par_nrctremp AND
                                               crapepr.tpemprst = 1) THEN
                                DO:
                                    ASSIGN aux_dscritic = "Operacao invalida para " +
                                                           "esse tipo de contrato.".
                                    LEAVE Valida.
                                END.

                            IF  par_dtdpagto = ? OR
                                par_dtdpagto <= par_dtmvtolt THEN
                                DO:
                                    ASSIGN aux_cdcritic = 13.
                                    LEAVE Valida.
                                END.

                            ASSIGN pro_dtcalcul = f_datapossivel
                                                    ( INPUT par_cdcooper,
                                                      INPUT par_dtmvtolt,
                                                      INPUT par_nrdconta,
                                                      INPUT par_nrctremp,
                                                     OUTPUT aux_cdcritic).

                            IF  aux_cdcritic <> 0 THEN
                                LEAVE Valida.

                            IF  par_dtdpagto > pro_dtcalcul THEN
                                DO:
                                    ASSIGN aux_dscritic = "Este contrato " +
                                                          "nao permite data" +
                                                          " de pagamento" +
                                                          " superior a " +
                                                          STRING(pro_dtcalcul,
                                                          "99/99/9999") + "!".
                                    LEAVE Valida.
                                END.

                            IF  DAY(par_dtdpagto) > 28 AND
                                par_flgpagto      = FALSE  THEN
                                DO:
                                    ASSIGN aux_dscritic = "Dia do pagamento " +
                                                    "deve ser menor que '29'.".
                                    LEAVE Valida.
                                END.
                        END. /* par_cdaditiv = 1 */
                    WHEN 2 THEN
                        DO:
                            FOR EACH tt-aplicacoes:

                                IF  tt-aplicacoes.tpaplica = 1 THEN
                                    DO:
                                        IF NOT CAN-FIND(FIRST craprpp WHERE
                                                      craprpp.cdcooper =
                                                               par_cdcooper AND
                                                      craprpp.nrdconta =
                                                               par_nrdconta AND
                                                      craprpp.nrctrrpp =
                                                   tt-aplicacoes.nraplica) THEN
                                            DO:
                                                ASSIGN aux_cdcritic = 426.
                                                LEAVE Valida.
                                            END.
                                        ELSE
                                            ASSIGN aux_flgaplic = YES.
                                    END.
                                ELSE
                                    DO:
                                        IF  NOT CAN-FIND(FIRST craprda WHERE
                                                           craprda.cdcooper = par_cdcooper            AND
                                                           craprda.nrdconta = par_nrdconta            AND
                                                           craprda.tpaplica = tt-aplicacoes.tpaplica  AND
                                                           craprda.nraplica = tt-aplicacoes.nraplica) AND
                                            NOT CAN-FIND(FIRST craprac WHERE
                                                           craprac.cdcooper = par_cdcooper AND
                                                           craprac.nrdconta = par_nrdconta AND
                                                           craprac.nraplica = tt-aplicacoes.nraplica) THEN
                                            DO:
                                                ASSIGN aux_cdcritic = 426.
                                                LEAVE Valida.
                                            END.
                                        ELSE
                                            ASSIGN aux_flgaplic = YES.

                                    END.

                            END. /*FOR EACH tt-aplicacoes:*/

                        END. /* par_cdaditiv = 2 */
                    WHEN 3 THEN
                        DO:
                            IF  par_nrctagar = par_nrdconta THEN
                                DO:
                                    ASSIGN aux_cdcritic = 121.
                                    LEAVE Valida.
                                END.

                            IF  NOT CAN-FIND(crapass WHERE
                                             crapass.cdcooper = par_cdcooper AND
                                             crapass.nrdconta = par_nrctagar)
                                THEN
                                DO:
                                    ASSIGN aux_cdcritic = 9.
                                    LEAVE Valida.
                                END.

                            FOR EACH tt-aplicacoes:
                                IF  tt-aplicacoes.tpaplica = 1 THEN
                                    DO:
                                        IF NOT CAN-FIND(FIRST craprpp WHERE
                                                      craprpp.cdcooper =
                                                               par_cdcooper AND
                                                      craprpp.nrdconta =
                                                               par_nrctagar AND
                                                      craprpp.nrctrrpp =
                                                   tt-aplicacoes.nraplica) THEN
                                            DO:
                                                ASSIGN aux_cdcritic = 426.
                                                LEAVE Valida.
                                            END.
                                        ELSE
                                            ASSIGN aux_flgaplic = YES.
                                    END.
                                ELSE
                                    DO:
                                        IF  NOT CAN-FIND(FIRST craprda WHERE
                                                           craprda.cdcooper =
                                                               par_cdcooper AND
                                                           craprda.nrdconta =
                                                               par_nrctagar AND
                                                           craprda.tpaplica =
                                                     tt-aplicacoes.tpaplica AND
                                                           craprda.nraplica =
                                                     tt-aplicacoes.nraplica) AND
                                            NOT CAN-FIND(FIRST craprac WHERE
                                                           craprac.cdcooper =
                                                               par_cdcooper AND
                                                           craprac.nrdconta =
                                                               par_nrctagar AND
                                                           craprac.nraplica =
                                                     tt-aplicacoes.nraplica) THEN
                                            DO:
                                                ASSIGN aux_cdcritic = 426.
                                                LEAVE Valida.
                                            END.
                                        ELSE
                                            ASSIGN aux_flgaplic = YES.

                                    END.

                            END. /*FOR EACH tt-aplicacoes:*/

                        END. /* par_cdaditiv = 3 */
                    WHEN 5 THEN
                        DO:
                            IF  par_dsbemfin = ""                      OR
                                NOT CAN-DO("1,2",STRING(par_tpchassi)) OR
                                par_dschassi = ""                      OR
                                par_dscorbem = ""                      OR
                                par_nranobem = 0                       OR
                                par_nrmodbem = 0                       OR
                                par_uflicenc = "" /* Retirado (Gravames) OR
                                par_nrrenava = 0                       OR
                                par_nrdplaca = ""                      OR
                                par_ufdplaca = ""              */        THEN DO:

                                ASSIGN aux_cdcritic = 375.
                                LEAVE Valida.
                            END.

                            /** GRAVAMES - Ou preenche os 3 ou nao preenche nenhum **/
                            IF  NOT (par_nrdplaca = "" AND
                                     par_ufdplaca = "" AND
                                     par_nrrenava = 0)
                            AND NOT (par_nrdplaca <> "" AND
                                     par_ufdplaca <> "" AND
                                     par_nrrenava <> 0) THEN DO:

                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = " UF, Placa e Renavam - " +
                                                      "Preencha os 3 ou nenhum deles!".
                                LEAVE Valida.
                            END.

                            IF  par_nrcpfcgc <> 0 THEN DO:

                                FIND FIRST crapavt
                                     WHERE crapavt.cdcooper = par_cdcooper
                                       AND crapavt.tpctrato = 9
                                       AND crapavt.nrdconta = par_nrdconta
                                       AND crapavt.nrctremp = par_nrctremp
                                       AND crapavt.nrcpfcgc = par_nrcpfcgc
                                   NO-LOCK NO-ERROR.

                                IF  NOT AVAIL crapavt THEN DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = " CPF Invalido! " +
                                                          " Verifique Avalistas da Proposta.".
                                    LEAVE Valida.
                                END.
                            END.

                        END. /* par_cdaditiv = 5 */
                    WHEN 6 THEN
                        DO:
                            IF  par_nmdgaran = ""                      OR
                                par_nrcpfgar = 0                       OR
                                par_nrdocgar = ""                      OR
                                par_dsbemfin = ""                      OR
                                par_nrrenava = 0                      OR
                                NOT CAN-DO("1,2",STRING(par_tpchassi)) OR
                                par_dschassi = ""                      OR
                                par_nrdplaca = ""                      OR
                                par_ufdplaca = ""                      OR
                                par_dscorbem = ""                      OR
                                par_nranobem = 0                       OR
                                par_nrmodbem = 0                       OR
                                par_uflicenc = ""                      THEN
                                DO:
                                    ASSIGN aux_cdcritic = 375.
                                    LEAVE Valida.
                                END.
                        END. /* par_cdaditiv = 6 */
                    WHEN 7 THEN
                        DO WHILE TRUE:
                            /* Verifica se  CPF informado e igual a
                            um dos avalistas */
                            FIND crawepr WHERE
                                 crawepr.cdcooper = par_cdcooper AND
                                 crawepr.nrdconta = par_nrdconta AND
                                 crawepr.nrctremp = par_nrctremp
                                 NO-LOCK NO-ERROR.

                            IF  AVAIL crawepr THEN
                                DO:
                                    /* verifica o 1o avalista */
                                    IF  crawepr.nrctaav1 > 0 OR
                                        crawepr.nmdaval1 <> "" THEN
                                        DO:
                                            /* avalista com conta */
                                            IF  crawepr.nrctaav1 > 0 THEN
                                                DO:
                                                    FIND crapass WHERE
                                                         crapass.cdcooper =
                                                               par_cdcooper AND
                                                         crapass.nrdconta =
                                                         crawepr.nrctaav1   AND
                                                         crapass.nrcpfcgc =
                                                                   par_nrcpfgar
                                                        NO-LOCK NO-ERROR.

                                                    IF  AVAIL crapass THEN
                                                        DO:
                                                            ASSIGN
                                                                 aux_nmdgaran =
                                                              crapass.nmprimtl.
                                                            LEAVE. /*avalista OK*/
                                                        END.

                                                END.
                                            ELSE /* avalista terceiro */
                                                DO:
                                                    FIND crapavt WHERE
                                                        crapavt.cdcooper =
                                                               par_cdcooper AND
                                                        crapavt.nrdconta =
                                                           crawepr.nrdconta AND
                                                        crapavt.nrctremp =
                                                           crawepr.nrctremp AND
                                                        crapavt.nrcpfcgc =
                                                                   par_nrcpfgar
                                                        NO-LOCK NO-ERROR.

                                                    IF  AVAIL crapavt THEN
                                                        DO:
                                                            ASSIGN
                                                                 aux_nmdgaran =
                                                              crapavt.nmdavali.
                                                            LEAVE. /*avalista OK*/
                                                        END.
                                                END.
                                        END.

                                    /* verifica o 2o avalista */
                                    IF  crawepr.nrctaav2 > 0   OR
                                        crawepr.nmdaval2 <> "" THEN
                                        DO:
                                            /* avalista com conta */
                                            IF  crawepr.nrctaav2 > 0 THEN
                                                DO:
                                                    FIND crapass WHERE
                                                        crapass.cdcooper =
                                                               par_cdcooper AND
                                                        crapass.nrdconta =
                                                           crawepr.nrctaav2 AND
                                                        crapass.nrcpfcgc =
                                                                   par_nrcpfgar
                                                        NO-LOCK NO-ERROR.

                                                    IF  AVAIL crapass THEN
                                                        DO:
                                                            ASSIGN
                                                                 aux_nmdgaran =
                                                              crapass.nmprimtl.
                                                            LEAVE. /*avalista OK*/
                                                        END.
                                                END.
                                            ELSE /* avalista terceiro */
                                                DO:
                                                    FIND crapavt WHERE
                                                        crapavt.cdcooper =
                                                               par_cdcooper AND
                                                        crapavt.nrdconta =
                                                           crawepr.nrdconta AND
                                                        crapavt.nrctremp =
                                                           crawepr.nrctremp AND
                                                        crapavt.nrcpfcgc =
                                                                   par_nrcpfgar
                                                        NO-LOCK NO-ERROR.

                                                    IF  AVAIL crapavt THEN
                                                        DO:
                                                            ASSIGN
                                                                 aux_nmdgaran =
                                                              crapavt.nmdavali.
                                                            LEAVE. /*avalista OK*/
                                                        END.
                                                END.
                                        END.

                                    FIND crapepr WHERE
                                        crapepr.cdcooper = par_cdcooper AND
                                        crapepr.nrdconta = par_nrdconta AND
                                        crapepr.nrctremp = par_nrctremp
                                        NO-LOCK NO-ERROR.

                                    IF  AVAIL crapepr THEN
                                        DO:
                                            IF  crapepr.nrctaav1 > 0 THEN
                                                DO:
                                                    FIND crapass WHERE
                                                        crapass.cdcooper =
                                                               par_cdcooper AND
                                                        crapass.nrdconta =
                                                           crapepr.nrctaav1 AND
                                                        crapass.nrcpfcgc =
                                                                  par_nrcpfgar
                                                        NO-LOCK NO-ERROR.

                                                    IF  AVAIL crapass THEN
                                                        DO:
                                                            ASSIGN
                                                                 aux_nmdgaran =
                                                              crapass.nmprimtl.
                                                            LEAVE. /*avalista OK*/
                                                        END.
                                                END.

                                            IF  crapepr.nrctaav2 > 0 THEN
                                                DO:
                                                    FIND crapass WHERE
                                                        crapass.cdcooper =
                                                               par_cdcooper AND
                                                        crapass.nrdconta =
                                                           crapepr.nrctaav2 AND
                                                        crapass.nrcpfcgc =
                                                                  par_nrcpfgar
                                                        NO-LOCK NO-ERROR.

                                                    IF  AVAIL crapass THEN
                                                        DO:
                                                            ASSIGN
                                                                 aux_nmdgaran =
                                                              crapass.nmprimtl.
                                                            LEAVE. /*avalista OK*/
                                                        END.
                                                END.
                                        END.

                                    ASSIGN aux_cdcritic = 839.
                                    LEAVE Valida.

                                END. /* FIM DO WHILE TRUE */
                        END. /* par_cdaditiv = 7 */
                    WHEN 8 THEN
                        DO WHILE TRUE:
                            IF  par_vlpromis = 0 THEN
                                DO:
                                    ASSIGN aux_cdcritic = 375.
                                    LEAVE Valida.
                                END.

                            /* Verifica se  CPF informado e igual a
                            um dos avalistas */
                            FIND crawepr WHERE
                                 crawepr.cdcooper = par_cdcooper AND
                                 crawepr.nrdconta = par_nrdconta AND
                                 crawepr.nrctremp = par_nrctremp
                                 NO-LOCK NO-ERROR.

                            IF  AVAIL crawepr THEN
                                DO:
                                    /* verifica o 1o avalista */
                                    IF  crawepr.nrctaav1 > 0 OR
                                        crawepr.nmdaval1 <> "" THEN
                                        DO:
                                            /* avalista com conta */
                                            IF  crawepr.nrctaav1 > 0 THEN
                                                DO:
                                                    FIND crapass WHERE
                                                         crapass.cdcooper =
                                                               par_cdcooper AND
                                                         crapass.nrdconta =
                                                         crawepr.nrctaav1   AND
                                                         crapass.nrcpfcgc =
                                                                   par_nrcpfgar
                                                        NO-LOCK NO-ERROR.

                                                    IF  AVAIL crapass THEN
                                                        DO:
                                                            ASSIGN
                                                                 aux_nmdgaran =
                                                              crapass.nmprimtl.
                                                            LEAVE. /*avalista OK*/
                                                        END.

                                                END.
                                            ELSE /* avalista terceiro */
                                                DO:
                                                    FIND crapavt WHERE
                                                        crapavt.cdcooper =
                                                               par_cdcooper AND
                                                        crapavt.nrdconta =
                                                           crawepr.nrdconta AND
                                                        crapavt.nrctremp =
                                                           crawepr.nrctremp AND
                                                        crapavt.nrcpfcgc =
                                                                   par_nrcpfgar
                                                        NO-LOCK NO-ERROR.

                                                    IF  AVAIL crapavt THEN
                                                        DO:
                                                            ASSIGN
                                                                 aux_nmdgaran =
                                                              crapavt.nmdavali.
                                                            LEAVE. /*avalista OK*/
                                                        END.
                                                END.
                                        END.

                                    /* verifica o 2o avalista */
                                    IF  crawepr.nrctaav2 > 0   OR
                                        crawepr.nmdaval2 <> "" THEN
                                        DO:
                                            /* avalista com conta */
                                            IF  crawepr.nrctaav2 > 0 THEN
                                                DO:
                                                    FIND crapass WHERE
                                                        crapass.cdcooper =
                                                               par_cdcooper AND
                                                        crapass.nrdconta =
                                                           crawepr.nrctaav2 AND
                                                        crapass.nrcpfcgc =
                                                                   par_nrcpfgar
                                                        NO-LOCK NO-ERROR.

                                                    IF  AVAIL crapass THEN
                                                        DO:
                                                            ASSIGN
                                                                 aux_nmdgaran =
                                                              crapass.nmprimtl.
                                                            LEAVE. /*avalista OK*/
                                                        END.
                                                END.
                                            ELSE /* avalista terceiro */
                                                DO:
                                                    FIND crapavt WHERE
                                                        crapavt.cdcooper =
                                                               par_cdcooper AND
                                                        crapavt.nrdconta =
                                                           crawepr.nrdconta AND
                                                        crapavt.nrctremp =
                                                           crawepr.nrctremp AND
                                                        crapavt.nrcpfcgc =
                                                                   par_nrcpfgar
                                                        NO-LOCK NO-ERROR.

                                                    IF  AVAIL crapavt THEN
                                                        DO:
                                                            ASSIGN
                                                                 aux_nmdgaran =
                                                              crapavt.nmdavali.
                                                            LEAVE. /*avalista OK*/
                                                        END.
                                                END.
                                        END.

                                    FIND crapepr WHERE
                                        crapepr.cdcooper = par_cdcooper AND
                                        crapepr.nrdconta = par_nrdconta AND
                                        crapepr.nrctremp = par_nrctremp
                                        NO-LOCK NO-ERROR.

                                    IF  AVAIL crapepr THEN
                                        DO:
                                            IF  crapepr.nrctaav1 > 0 THEN
                                                DO:
                                                    FIND crapass WHERE
                                                        crapass.cdcooper =
                                                               par_cdcooper AND
                                                        crapass.nrdconta =
                                                           crapepr.nrctaav1 AND
                                                        crapass.nrcpfcgc =
                                                                  par_nrcpfgar
                                                        NO-LOCK NO-ERROR.

                                                    IF  AVAIL crapass THEN
                                                        DO:
                                                            ASSIGN
                                                                 aux_nmdgaran =
                                                              crapass.nmprimtl.
                                                            LEAVE. /*avalista OK*/
                                                        END.
                                                END.

                                            IF  crapepr.nrctaav2 > 0 THEN
                                                DO:
                                                    FIND crapass WHERE
                                                        crapass.cdcooper =
                                                               par_cdcooper AND
                                                        crapass.nrdconta =
                                                           crapepr.nrctaav2 AND
                                                        crapass.nrcpfcgc =
                                                                  par_nrcpfgar
                                                        NO-LOCK NO-ERROR.

                                                    IF  AVAIL crapass THEN
                                                        DO:
                                                            ASSIGN
                                                                 aux_nmdgaran =
                                                              crapass.nmprimtl.
                                                            LEAVE. /*avalista OK*/
                                                        END.
                                                END.
                                        END.

                                    ASSIGN aux_cdcritic = 839.
                                    LEAVE Valida.

                                END.

                        END. /* par_cdaditiv = 8 */
                END CASE.

            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Valida.

    END. /* Valida */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

        END.

    RETURN aux_returnvl.

END PROCEDURE. /* Valida_Dados */

/* ------------------------------------------------------------------------- */
/*                 REALIZA A GRAVACAO DOS DADOS DA TELA ADITIV               */
/* ------------------------------------------------------------------------- */
PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdaditiv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraditiv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idgaropc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagto AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgaplic AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrctagar AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsbemfin AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dschassi AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdplaca AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dscorbem AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nranobem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrmodbem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrrenava AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpchassi AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_ufdplaca AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_uflicenc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc LIKE crapbpr.nrcpfbem             NO-UNDO.
    DEF  INPUT PARAM par_idseqbem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfgar AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocgar AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdgaran AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrpromis AS CHAR EXTENT 10                 NO-UNDO.
    DEF  INPUT PARAM par_vlpromis AS DECI EXTENT 10                 NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-aplicacoes.

    DEF OUTPUT PARAM aux_uladitiv AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_vltotpag AS DECI                                    NO-UNDO.
    DEF VAR pro_dtcalcul AS DATE                                    NO-UNDO.
    DEF VAR pro_qtmesdec AS INTE                                    NO-UNDO.
    DEF VAR aux_dtultdma AS DATE                                    NO-UNDO.
    DEF VAR aux_nrsequen AS INTE                                    NO-UNDO.
    DEF VAR aux_tpregist AS INTE                                    NO-UNDO.
    DEF VAR aux_idseqbem AS INTE                                    NO-UNDO.
    DEF VAR aux_idseqbe2 AS INTE                                    NO-UNDO.
    DEF VAR aux_despreza AS LOGI                                    NO-UNDO.
    DEF VAR aux_nrctagar AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcpfgar AS DECI                                    NO-UNDO.
    DEF VAR aux_vlpromis AS DECI                                    NO-UNDO.
    DEF VAR aux_nrcpfcgc LIKE crapbpr.nrcpfbem                      NO-UNDO.
    DEF VAR aux_nmdavali AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsrelbem AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdagenci AS INTE                                    NO-UNDO.

    DEF VAR aux_flsitgrv AS LOGICAL                                 NO-UNDO.
    
    DEF VAR aux_idgaropc_old AS INTE                                NO-UNDO.

    DEF VAR h-b1wgen0168 AS HANDLE                                  NO-UNDO.
    DEF BUFFER crabbpr FOR crapbpr.

    ASSIGN aux_nrctagar = 0
           aux_nrsequex = 0
           aux_nrdrowid = ?
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_uladitiv = par_nraditiv
           par_dschassi = CAPS(par_dschassi).

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper  NO-LOCK: END.

        IF  AVAIL crapdat THEN
            ASSIGN aux_dtultdma = crapdat.dtmvtolt - DAY(crapdat.dtmvtolt).

        /* Buscar pa de trabalho do operador */
        FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper AND
                                 crapope.cdoperad = par_cdoperad
                                 NO-LOCK NO-ERROR.
    
        IF  NOT AVAIL crapope THEN
            aux_cdagenci = 0.
        ELSE
            aux_cdagenci = crapope.cdpactra.

        IF  par_cddopcao = "I" THEN
            DO:

                ASSIGN aux_dstransa = "Incluir aditivo contratual de emprestimo.".

                CASE par_cdaditiv:

                    WHEN 1 THEN
                        DO:
                            RUN obtem_nro_aditivo
                                ( INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT par_nrctremp,
                                  INPUT par_tpctrato,
                                 OUTPUT aux_uladitiv,
                                 OUTPUT aux_cdcritic).

                            IF  aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            CREATE crapadt.
                            ASSIGN crapadt.nrdconta = par_nrdconta
                                   crapadt.nrctremp = par_nrctremp
                                   crapadt.nraditiv = aux_uladitiv
                                   crapadt.cdaditiv = 1
                                   crapadt.tpctrato = par_tpctrato
                                   crapadt.dtmvtolt = par_dtmvtolt
                                   crapadt.cdcooper = par_cdcooper
                                   crapadt.cdagenci = aux_cdagenci
                                   crapadt.cdoperad = par_cdoperad
                                   crapadt.flgdigit = NO.
                            VALIDATE crapadt.

                            CREATE crapadi.
                            ASSIGN crapadi.nrdconta = par_nrdconta
                                   crapadi.nrctremp = par_nrctremp
                                   crapadi.nraditiv = aux_uladitiv
                                   crapadi.tpctrato = par_tpctrato
                                   crapadi.nrsequen = 1
                                   crapadi.flgpagto = par_flgpagto
                                   crapadi.dtdpagto = par_dtdpagto
                                   crapadi.cdcooper = par_cdcooper.
                            VALIDATE crapadi.

                            Contador: DO aux_contador = 1 TO 10:

                                FIND crawepr WHERE
                                     crawepr.cdcooper = par_cdcooper AND
                                     crawepr.nrdconta = par_nrdconta AND
                                     crawepr.nrctremp = par_nrctremp
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                IF  NOT AVAIL crawepr THEN
                                    DO:
                                        IF  LOCKED crawepr   THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 77.
                                                        LEAVE Contador.
                                                    END.
                                                ELSE
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT Contador.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 356.
                                                LEAVE Contador.
                                            END.
                                    END.
                                ELSE
                                    LEAVE Contador.

                            END. /* Contador */

                            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            Contador: DO aux_contador = 1 TO 10:

                                FIND crapepr WHERE
                                     crapepr.cdcooper = par_cdcooper AND
                                     crapepr.nrdconta = par_nrdconta AND
                                     crapepr.nrctremp = par_nrctremp
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                IF  NOT AVAIL crapepr THEN
                                    DO:
                                        IF  LOCKED crapepr   THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 77.
                                                        LEAVE Contador.
                                                    END.
                                                ELSE
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT Contador.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 356.
                                                LEAVE Contador.
                                            END.
                                    END.
                                ELSE
                                    LEAVE Contador.

                            END. /* Contador */

                            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            IF  crapepr.flgpagto AND NOT par_flgpagto THEN
                                DO:
                                    FOR EACH crapavs WHERE
                                             crapavs.cdcooper =
                                                               par_cdcooper AND
                                             crapavs.nrdconta =
                                                           crapepr.nrdconta AND
                                             crapavs.nrdocmto =
                                                           crapepr.nrctremp AND
                                             crapavs.cdhistor = 108         AND
                                             crapavs.tpdaviso = 1           AND
                                             crapavs.insitavs = 0
                                             EXCLUSIVE-LOCK:
                                        ASSIGN crapavs.insitavs = 1.
                                    END.
                                END.

                            RUN verifica_prestacoes_pagas
                                ( INPUT par_cdcooper,
                                  INPUT crapepr.nrdconta,
                                  INPUT crapepr.nrctremp,
                                 OUTPUT aux_vltotpag).

                            IF  aux_vltotpag = 0 THEN
                                DO:
                                    ASSIGN pro_dtcalcul = par_dtdpagto
                                           pro_qtmesdec = 1.

                                    DO WHILE pro_dtcalcul > aux_dtultdma:

                                        ASSIGN pro_qtmesdec = pro_qtmesdec - 1
                                               pro_dtcalcul = pro_dtcalcul -
                                                             DAY(pro_dtcalcul).
                                    END.

                                    ASSIGN crapepr.qtmesdec = pro_qtmesdec
                                           crawepr.dtvencto = par_dtdpagto.

                                END.

                            ASSIGN crawepr.flgpagto = par_flgpagto
                                   crawepr.dtdpagto = par_dtdpagto
                                   crapepr.flgpagto = par_flgpagto
                                   crapepr.dtdpagto = par_dtdpagto.

                            /* Log */
                            RUN Gera_Log (INPUT  par_cdcooper,
                                          INPUT  par_cdoperad,
                                          INPUT  par_nmdatela,
                                          INPUT  par_dtmvtolt,
                                          INPUT  par_cddopcao,
                                          INPUT  par_nrdconta,
                                          INPUT  par_nrctremp,
                                          INPUT  aux_uladitiv,
                                          INPUT  par_cdaditiv,
                                          INPUT  par_flgpagto,
                                          INPUT  par_dtdpagto,
                                          INPUT  0, /* nrctagar */
                                          INPUT  0, /* tpaplica */
                                          INPUT  0, /* nraplica */
                                          INPUT  par_dsbemfin,
                                          INPUT  par_nrrenava,
                                          INPUT  par_tpchassi,
                                          INPUT  par_dschassi,
                                          INPUT  par_nrdplaca,
                                          INPUT  par_ufdplaca,
                                          INPUT  par_dscorbem,
                                          INPUT  par_nranobem,
                                          INPUT  par_nrmodbem,
                                          INPUT  par_uflicenc,
                                          INPUT  "", /* nmdgaran */
                                          INPUT  0,  /* nrcpfgar */
                                          INPUT  "", /* nrdocgar */
                                          INPUT  "", /* nrpromis */
                                          INPUT  0,  /* vlpromis */
                                          INPUT  0,  /* tpproapl */
                                          INPUT  par_tpctrato,
                                          INPUT  0). /* idgaropc */

                        END. /* par_cdaditiv = 1 */
                    WHEN 2 THEN
                        DO:

                            RUN obtem_nro_aditivo
                                ( INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT par_nrctremp,
                                  INPUT par_tpctrato,
                                 OUTPUT aux_uladitiv,
                                 OUTPUT aux_cdcritic).

                            IF  aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            IF  par_flgaplic THEN
                                DO:
                                    CREATE crapadt.
                                    ASSIGN crapadt.nrdconta = par_nrdconta
                                           crapadt.nrctremp = par_nrctremp
                                           crapadt.nraditiv = aux_uladitiv
                                           crapadt.cdaditiv = 2
                                           crapadt.tpctrato = par_tpctrato
                                           crapadt.dtmvtolt = par_dtmvtolt
                                           crapadt.cdcooper = par_cdcooper
                                           crapadt.cdagenci = aux_cdagenci
                                           crapadt.cdoperad = par_cdoperad
                                           crapadt.flgdigit = NO
                                           aux_nrsequen = 1.
                                    VALIDATE crapadt.
                                END.

                            /* criacao das tabelas para todas as aplicacoes */
                            FOR EACH tt-aplicacoes:

                                CREATE crapadi.
                                ASSIGN crapadi.nrdconta = par_nrdconta
                                       crapadi.nrctremp = par_nrctremp
                                       crapadi.nraditiv = aux_uladitiv
                                       crapadi.tpctrato = par_tpctrato
                                       crapadi.nrsequen = aux_nrsequen
                                       crapadi.tpaplica = tt-aplicacoes.tpaplica
                                       crapadi.nraplica = tt-aplicacoes.nraplica
                                       crapadi.cdcooper = par_cdcooper
                                       crapadi.tpproapl = tt-aplicacoes.tpproapl
                                       aux_nrsequen = aux_nrsequen + 1.
                                VALIDATE crapadi.

                                /* Log */
                                RUN Gera_Log (INPUT  par_cdcooper,
                                              INPUT  par_cdoperad,
                                              INPUT  par_nmdatela,
                                              INPUT  par_dtmvtolt,
                                              INPUT  par_cddopcao,
                                              INPUT  par_nrdconta,
                                              INPUT  par_nrctremp,
                                              INPUT  aux_uladitiv,
                                              INPUT  par_cdaditiv,
                                              INPUT  par_flgpagto,
                                              INPUT  par_dtdpagto,
                                              INPUT  0, /* nrctagar */
                                              INPUT  tt-aplicacoes.tpaplica,
                                              INPUT  tt-aplicacoes.nraplica,
                                              INPUT  par_dsbemfin,
                                              INPUT  par_nrrenava,
                                              INPUT  par_tpchassi,
                                              INPUT  par_dschassi,
                                              INPUT  par_nrdplaca,
                                              INPUT  par_ufdplaca,
                                              INPUT  par_dscorbem,
                                              INPUT  par_nranobem,
                                              INPUT  par_nrmodbem,
                                              INPUT  par_uflicenc,
                                              INPUT  "", /* nmdgaran */
                                              INPUT  0,  /* nrcpfgar */
                                              INPUT  "", /* nrdocgar */
                                              INPUT  "", /* nrpromis */
                                              INPUT  0,  /* vlpromis */
                                              INPUT tt-aplicacoes.tpproapl,
                                              INPUT  par_tpctrato,
                                              INPUT  0). /* idgaropc */

                                IF  tt-aplicacoes.tpproapl = 1 THEN
                                    DO:

                                        FIND craprac WHERE craprac.cdcooper = par_cdcooper           AND
                                                           craprac.nrdconta = par_nrdconta           AND
                                                           craprac.nraplica = tt-aplicacoes.nraplica AND
                                                           craprac.idblqrgt = 0
                                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                        IF AVAIL craprac THEN
                                            ASSIGN craprac.idblqrgt = 2.

                                    END.
                                ELSE
                                    DO:
                                        /* verifica se a aplicacao ja esta bloqueada */
                                        FIND FIRST craptab WHERE
                                                   craptab.cdcooper = par_cdcooper AND
                                                   craptab.nmsistem = "CRED"       AND
                                                   craptab.tptabela = "BLQRGT"     AND
                                                   craptab.cdempres = 00           AND
                                                   craptab.cdacesso =
                                                                  STRING(par_nrdconta,
                                                                     "9999999999") AND
                                                     SUBSTRING(craptab.dstextab,1,7) =
                                                         STRING(tt-aplicacoes.nraplica,
                                                                             "9999999")
                                                          NO-LOCK NO-ERROR NO-WAIT.

                                        /* BLOQUEIA a aplicacao se ainda nao esta
                                        bloqueada */
                                        IF  NOT AVAILABLE craptab THEN
                                            DO:
                                                FIND LAST craptab WHERE
                                                          craptab.cdcooper =
                                                                       par_cdcooper AND
                                                          craptab.nmsistem = "CRED" AND
                                                          craptab.tptabela =
                                                                           "BLQRGT" AND
                                                          craptab.cdempres = 00     AND
                                                          craptab.cdacesso =
                                                                   STRING(par_nrdconta,
                                                                          "9999999999")
                                                              NO-LOCK NO-ERROR NO-WAIT.

                                                IF  NOT AVAILABLE craptab THEN
                                                    ASSIGN aux_tpregist = 1.
                                                ELSE
                                                    ASSIGN aux_tpregist =
                                                           craptab.tpregist + 1.

                                                CREATE craptab.
                                                ASSIGN craptab.nmsistem ="CRED"
                                                       craptab.tptabela = "BLQRGT"
                                                       craptab.cdempres = 00
                                                       craptab.cdacesso =
                                                                  STRING(par_nrdconta,
                                                                         "9999999999")
                                                       craptab.tpregist = aux_tpregist
                                                       craptab.dstextab =
                                                        STRING(tt-aplicacoes.nraplica,
                                                                            "9999999")
                                                       /* caracter de controle "A" */
                                                SUBSTRING(craptab.dstextab,10,1) = "A"
                                                      craptab.cdcooper = par_cdcooper.
                                                VALIDATE craptab.

                                            END.

                                        RELEASE craptab.
                                    END.

                            END. /* FOR EACH tt-aplicacoes */

                        END. /* par_cdaditiv = 2 */
                    WHEN 3 THEN
                        DO:
                            RUN obtem_nro_aditivo
                                ( INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT par_nrctremp,
                                  INPUT par_tpctrato,
                                 OUTPUT aux_uladitiv,
                                 OUTPUT aux_cdcritic).

                            IF  aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            IF  par_flgaplic THEN
                                DO:
                                    CREATE crapadt.
                                    ASSIGN crapadt.nrdconta = par_nrdconta
                                           crapadt.nrctremp = par_nrctremp
                                           crapadt.nraditiv = aux_uladitiv
                                           crapadt.cdaditiv = 3
                                           crapadt.tpctrato = par_tpctrato
                                           crapadt.dtmvtolt = par_dtmvtolt
                                           crapadt.nrctagar = par_nrctagar
                                           crapadt.cdcooper = par_cdcooper
                                           crapadt.cdagenci = aux_cdagenci
                                           crapadt.cdoperad = par_cdoperad
                                           crapadt.flgdigit = NO
                                           aux_nrsequen = 1.
                                    VALIDATE crapadt.

                                END. /* par_flgaplic */

                            /* criacao das tabelas para todas as aplicacoes */
                            FOR EACH tt-aplicacoes:

                                CREATE crapadi.
                                ASSIGN crapadi.nrdconta = par_nrdconta
                                       crapadi.nrctremp = par_nrctremp
                                       crapadi.nraditiv = aux_uladitiv
                                       crapadi.tpctrato = par_tpctrato
                                       crapadi.nrsequen = aux_nrsequen
                                       crapadi.tpaplica = tt-aplicacoes.tpaplica
                                       crapadi.nraplica = tt-aplicacoes.nraplica
                                       crapadi.cdcooper = par_cdcooper
                                       crapadi.tpproapl = tt-aplicacoes.tpproapl
                                       aux_nrsequen = aux_nrsequen + 1.
                                VALIDATE crapadi.

                                /* Log */
                                RUN Gera_Log (INPUT  par_cdcooper,
                                              INPUT  par_cdoperad,
                                              INPUT  par_nmdatela,
                                              INPUT  par_dtmvtolt,
                                              INPUT  par_cddopcao,
                                              INPUT  par_nrdconta,
                                              INPUT  par_nrctremp,
                                              INPUT  aux_uladitiv,
                                              INPUT  par_cdaditiv,
                                              INPUT  par_flgpagto,
                                              INPUT  par_dtdpagto,
                                              INPUT  par_nrctagar,
                                              INPUT  tt-aplicacoes.tpaplica,
                                              INPUT  tt-aplicacoes.nraplica,
                                              INPUT  par_dsbemfin,
                                              INPUT  par_nrrenava,
                                              INPUT  par_tpchassi,
                                              INPUT  par_dschassi,
                                              INPUT  par_nrdplaca,
                                              INPUT  par_ufdplaca,
                                              INPUT  par_dscorbem,
                                              INPUT  par_nranobem,
                                              INPUT  par_nrmodbem,
                                              INPUT  par_uflicenc,
                                              INPUT  "", /* nmdgaran */
                                              INPUT  0,  /* nrcpfgar */
                                              INPUT  "", /* nrdocgar */
                                              INPUT  "", /* nrpromis */
                                              INPUT  0,  /* vlpromis */
                                              INPUT  tt-aplicacoes.tpproapl,
                                              INPUT  par_tpctrato,
                                              INPUT  0). /* idgaropc */

                                IF  tt-aplicacoes.tpproapl = 2 THEN
                                    DO:
                                        /* verifica se a aplicacao ja esta bloqueada */
                                        FIND FIRST craptab WHERE
                                                   craptab.cdcooper = par_cdcooper AND
                                                   craptab.nmsistem = "CRED"       AND
                                                   craptab.tptabela = "BLQRGT"     AND
                                                   craptab.cdempres = 00           AND
                                                   craptab.cdacesso =
                                                                  STRING(par_nrctagar,
                                                                     "9999999999") AND
                                                     SUBSTRING(craptab.dstextab,1,7) =
                                                         STRING(tt-aplicacoes.nraplica,
                                                                             "9999999")
                                                          NO-LOCK NO-ERROR NO-WAIT.

                                        /* BLOQUEIA a aplicacao se ainda nao esta
                                        bloqueada */
                                        IF  NOT AVAILABLE craptab THEN
                                            DO:
                                                FIND LAST craptab WHERE
                                                          craptab.cdcooper =
                                                                       par_cdcooper AND
                                                          craptab.nmsistem = "CRED" AND
                                                          craptab.tptabela =
                                                                           "BLQRGT" AND
                                                          craptab.cdempres = 00     AND
                                                          craptab.cdacesso =
                                                                   STRING(par_nrctagar,
                                                                          "9999999999")
                                                              NO-LOCK NO-ERROR NO-WAIT.

                                                IF  NOT AVAILABLE craptab THEN
                                                    ASSIGN aux_tpregist = 1.
                                                ELSE
                                                    ASSIGN aux_tpregist =
                                                           craptab.tpregist + 1.

                                                CREATE craptab.
                                                ASSIGN craptab.nmsistem ="CRED"
                                                       craptab.tptabela = "BLQRGT"
                                                       craptab.cdempres = 00
                                                       craptab.cdacesso =
                                                                  STRING(par_nrctagar,
                                                                         "9999999999")
                                                       craptab.tpregist = aux_tpregist
                                                       craptab.dstextab =
                                                        STRING(tt-aplicacoes.nraplica,
                                                                            "9999999")
                                                       /* caracter de controle "A" */
                                                SUBSTRING(craptab.dstextab,10,1) = "A"
                                                      craptab.cdcooper = par_cdcooper.
                                                VALIDATE craptab.

                                            END.

                                        RELEASE craptab.
                                    END.
                                ELSE
                                    DO:

                                        FIND craprac WHERE craprac.cdcooper = par_cdcooper           AND
                                                           craprac.nrdconta = par_nrctagar           AND
                                                           craprac.nraplica = tt-aplicacoes.nraplica AND
                                                           craprac.idblqrgt = 0
                                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                        IF AVAIL craprac THEN
                                            ASSIGN craprac.idblqrgt = 2.

                                END.

                            END. /* FOR EACH tt-aplicacoes */

                        END. /* par_cdaditiv = 3 */
                    WHEN 5 THEN  /** Substituicao Veiculo - Opcao I - Tipo 5 **/
                        DO:
                            RUN obtem_nro_aditivo
                                ( INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT par_nrctremp,
                                  INPUT par_tpctrato,
                                 OUTPUT aux_uladitiv,
                                 OUTPUT aux_cdcritic).

                            IF  aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            Contador: DO aux_contador = 1 TO 10:

                                FIND crawepr WHERE
                                     crawepr.cdcooper = par_cdcooper AND
                                     crawepr.nrdconta = par_nrdconta AND
                                     crawepr.nrctremp = par_nrctremp
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                IF  NOT AVAIL crawepr THEN
                                    DO:
                                        IF  LOCKED crawepr   THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 77.
                                                        LEAVE Contador.
                                                    END.
                                                ELSE
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT Contador.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 356.
                                                LEAVE Contador.
                                            END.
                                    END.
                                ELSE
                                    LEAVE Contador.

                            END. /* Contador */

                            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            CREATE crapadt.
                            ASSIGN crapadt.nrdconta = par_nrdconta
                                   crapadt.nrctremp = par_nrctremp
                                   crapadt.nraditiv = aux_uladitiv
                                   crapadt.cdaditiv = 5
                                   crapadt.tpctrato = par_tpctrato
                                   crapadt.dtmvtolt = par_dtmvtolt
                                   crapadt.cdcooper = par_cdcooper
                                   crapadt.cdagenci = aux_cdagenci
                                   crapadt.cdoperad = par_cdoperad
                                   crapadt.flgdigit = NO.
                            VALIDATE crapadt.

                            CREATE crapadi.
                            ASSIGN crapadi.nrdconta = par_nrdconta
                                   crapadi.nrctremp = par_nrctremp
                                   crapadi.nraditiv = aux_uladitiv
                                   crapadi.tpctrato = par_tpctrato
                                   crapadi.nrsequen = 1
                                   crapadi.dsbemfin = par_dsbemfin
                                   crapadi.dschassi = par_dschassi
                                   crapadi.nrdplaca = par_nrdplaca
                                   crapadi.dscorbem = par_dscorbem
                                   crapadi.nranobem = par_nranobem
                                   crapadi.nrmodbem = par_nrmodbem
                                   crapadi.nrrenava = par_nrrenava
                                   crapadi.tpchassi = par_tpchassi
                                   crapadi.ufdplaca = par_ufdplaca
                                   crapadi.uflicenc = par_uflicenc
                                   crapadi.cdcooper = par_cdcooper.



                            /*** GRAVAMES - Apenas quando tipo 5 ***/

                            /* Verificar o CPF da conta do contrato */
                            FIND FIRST crapass
                                 WHERE crapass.cdcooper = par_cdcooper
                                   AND crapass.nrdconta = par_nrdconta
                                NO-LOCK NO-ERROR.

                            IF  AVAIL crapass THEN
                                ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc
                                       aux_nmdavali = crapass.nmprimtl.

                            IF  par_nrcpfcgc <> 0
                            AND par_nrcpfcgc <> aux_nrcpfcgc THEN DO:
                                /** Localiza Nome do Titular CPF */
                                FIND FIRST crapass
                                     WHERE crapass.cdcooper = par_cdcooper
                                       AND crapass.nrcpfcgc = par_nrcpfcgc
                                    NO-LOCK NO-ERROR.
                                IF  AVAIL crapass THEN
                                    ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc
                                           aux_nmdavali = crapass.nmprimtl.
                                ELSE DO:
                                    /* Se nao encontrou ASS, busca Avalistas */
                                    FIND FIRST crapavt
                                         WHERE crapavt.cdcooper = par_cdcooper
                                           AND crapavt.nrcpfcgc = par_nrcpfcgc
                                       NO-LOCK NO-ERROR.

                                    IF  AVAIL crapavt THEN DO:
                                        ASSIGN aux_nrcpfcgc = crapavt.nrcpfcgc
                                               aux_nmdavali = crapavt.nmdavali.
                                    END.
                                END.
                            END.
                            ELSE
                                ASSIGN aux_nrcpfcgc = 0 /** Se 0 ou titular, nao guarda cpf */
                                       aux_nmdavali = crapass.nmprimtl.

                            ASSIGN crapadi.nrcpfcgc = aux_nrcpfcgc
                                   crapadi.nmdavali = aux_nmdavali.
                            /** GRAVAMES - Fim busca CPF/Nome para Aditiv */

                            VALIDATE crapadi.

                            IF  par_idseqbem > 0 THEN DO:
                                Contador:
                                DO aux_contador = 1 TO 10:
                                    FIND crapbpr
                                      WHERE crapbpr.cdcooper = par_cdcooper
                                        AND crapbpr.nrdconta = par_nrdconta
                                        AND crapbpr.tpctrpro = 90
                                        AND crapbpr.nrctrpro = par_nrctremp
                                        AND crapbpr.idseqbem = par_idseqbem
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                    IF  NOT AVAIL crapbpr THEN DO:
                                        IF  LOCKED crapbpr   THEN DO:
                                            IF  aux_contador = 10 THEN DO:
                                                ASSIGN
                                                 aux_cdcritic = 77.
                                                LEAVE Contador.
                                            END.
                                            ELSE DO:
                                                PAUSE 1 NO-MESSAGE.
                                                NEXT Contador.
                                            END.
                                        END.
                                        ELSE DO:
                                            ASSIGN aux_cdcritic = 55.
                                            LEAVE Contador.
                                        END.
                                    END.
                                    ELSE
                                        LEAVE Contador.
                                END. /* Contador */

                                /*** GRAVAMES ***/
                                /* Se BEM estiver "EM PROCESSAMENTO" nao deixa seguir */
                                IF  AVAIL crapbpr
                                AND crapbpr.cdsitgrv = 1 THEN
                                    ASSIGN aux_dscritic =
                                           " Bem em Processamento Gravames! " +
                                           " Operacao nao efetuada!".
                                IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                    UNDO Grava, LEAVE Grava.


                                IF  AVAIL crapbpr THEN DO:
                                    ASSIGN aux_dstransa = "Excluir aditivo"
                                             + " contratual de emprestimo.".

                                    /* Log */
                                    RUN Gera_Log (INPUT  par_cdcooper,
                                                  INPUT  par_cdoperad,
                                                  INPUT  par_nmdatela,
                                                  INPUT  par_dtmvtolt,
                                                  INPUT  par_cddopcao,
                                                  INPUT  par_nrdconta,
                                                  INPUT  par_nrctremp,
                                                  INPUT  aux_uladitiv,
                                                  INPUT  par_cdaditiv,
                                                  INPUT  par_flgpagto,
                                                  INPUT  par_dtdpagto,
                                                  INPUT  0, /* nrctagar */
                                                  INPUT  0, /* tpaplica */
                                                  INPUT  0, /* nraplica */
                                                  INPUT  crapbpr.dsbemfin,
                                                  INPUT  crapbpr.nrrenava,
                                                  INPUT  crapbpr.tpchassi,
                                                  INPUT  crapbpr.dschassi,
                                                  INPUT  crapbpr.nrdplaca,
                                                  INPUT  crapbpr.ufdplaca,
                                                  INPUT  crapbpr.dscorbem,
                                                  INPUT  crapbpr.nranobem,
                                                  INPUT  crapbpr.nrmodbem,
                                                  INPUT  crapbpr.uflicenc,
                                                  INPUT  "", /* nmdgaran */
                                                  INPUT  0,  /* nrcpfgar */
                                                  INPUT  "", /* nrdocgar */
                                                  INPUT  "", /* nrpromis */
                                                  INPUT  0,  /* vlpromis */
                                                  INPUT  0,
                                                  INPUT  par_tpctrato,
                                                  INPUT  0). /* idgaropc */
                                END.

                                /** GRAVAMES - Copia BEM para tipo 99 **/
                                IF  (par_cdcooper = 1 AND
                                     par_dtmvtolt >= 11/18/2014)
                                OR  (par_cdcooper = 4 AND
                                     par_dtmvtolt >= 07/23/2014)
                                OR  (par_cdcooper = 7 AND
                                     par_dtmvtolt >= 10/06/2014)
                                OR  (NOT CAN-DO("1,4,7",
                                         STRING(par_cdcooper)) AND
                                     par_dtmvtolt >= 02/26/2015) THEN DO:

                                    FIND LAST crabbpr
                                        WHERE crabbpr.cdcooper = par_cdcooper
                                          AND crabbpr.nrdconta = par_nrdconta
                                          AND crabbpr.tpctrpro = 99
                                          AND crabbpr.nrctrpro = par_nrctremp
                                          NO-LOCK NO-ERROR.

                                    IF  AVAIL crabbpr THEN
                                        ASSIGN aux_idseqbe2 = crabbpr.idseqbem + 1.
                                    ELSE
                                        ASSIGN aux_idseqbe2 = 1.

                                    CREATE crabbpr.
                                    BUFFER-COPY crapbpr
                                         EXCEPT crapbpr.tpctrpro
                                                crapbpr.idseqbem
                                             TO crabbpr.
                                    ASSIGN crabbpr.tpctrpro = 99
                                           crabbpr.flgbaixa = TRUE
                                           crabbpr.dtdbaixa = par_dtmvtolt
                                           crabbpr.tpdbaixa = "A"
                                           crabbpr.flginclu = FALSE
                                           crabbpr.flcancel = FALSE
                                           crabbpr.idseqbem = aux_idseqbe2.
                                END.
                                /** GRAVAMES - Copia BEM para tipo 99 **/

                                DELETE crapbpr.
                                VALIDATE crabbpr.

                            END. /* IF  par_idseqbem > 0 */

                            /* Pegar sequencia do bem alienado */
                            FIND LAST crapbpr WHERE
                                      crapbpr.cdcooper = par_cdcooper AND
                                      crapbpr.nrdconta = par_nrdconta AND
                                      crapbpr.tpctrpro = 90           AND
                                      crapbpr.nrctrpro = par_nrctremp
                                      NO-LOCK NO-ERROR.

                            IF  NOT AVAIL crapbpr THEN
                                ASSIGN aux_idseqbem = 1.
                            ELSE
                                ASSIGN aux_idseqbem = crapbpr.idseqbem + 1.

                            ASSIGN aux_dsrelbem = REPLACE(par_dsbemfin,";",",").
                            ASSIGN aux_dsrelbem = REPLACE(aux_dsrelbem,"|","-").

                            CREATE crapbpr.
                            ASSIGN crapbpr.cdcooper = par_cdcooper
                                   crapbpr.nrdconta = par_nrdconta
                                   crapbpr.tpctrpro = 90
                                   crapbpr.nrctrpro = par_nrctremp
                                   crapbpr.flgalien = TRUE
                                   crapbpr.idseqbem = aux_idseqbem
                                   crapbpr.dtmvtolt = par_dtmvtolt
                                   crapbpr.cdoperad = par_cdoperad
                                   crapbpr.dscatbem = "AUTOMOVEL"
                                   crapbpr.dsbemfin = aux_dsrelbem
                                   crapbpr.dschassi = par_dschassi
                                   crapbpr.nrdplaca = par_nrdplaca
                                   crapbpr.dscorbem = par_dscorbem
                                   crapbpr.nranobem = par_nranobem
                                   crapbpr.nrmodbem = par_nrmodbem
                                   crapbpr.nrrenava = par_nrrenava
                                   crapbpr.tpchassi = par_tpchassi
                                   crapbpr.ufdplaca = par_ufdplaca
                                   crapbpr.uflicenc = par_uflicenc
                                   crapbpr.nrcpfbem = par_nrcpfcgc.

                            /** GRAVAMES ***/
                            IF  (par_cdcooper = 1 AND
                                 par_dtmvtolt >= 11/18/2014)
                            OR  (par_cdcooper = 4 AND
                                 par_dtmvtolt >= 07/23/2014)
                            OR  (par_cdcooper = 7 AND
                                 par_dtmvtolt >= 10/06/2014)
                            OR  (NOT CAN-DO("1,4,7",STRING(par_cdcooper)) AND
                                 par_dtmvtolt >= 02/26/2015) THEN DO:
                                ASSIGN crapbpr.flginclu = TRUE
                                       crapbpr.cdsitgrv = 0
                                       crapbpr.tpinclus = "A"
                                       crawepr.flgokgrv = TRUE.
                            END.

                            VALIDATE crapbpr.

                            ASSIGN  aux_nrdrowid = ?
                                    aux_dstransa = "Incluir aditivo contratual"
                                                 + " de emprestimo.".

                            /* Log */
                            RUN Gera_Log (INPUT  par_cdcooper,
                                          INPUT  par_cdoperad,
                                          INPUT  par_nmdatela,
                                          INPUT  par_dtmvtolt,
                                          INPUT  par_cddopcao,
                                          INPUT  par_nrdconta,
                                          INPUT  par_nrctremp,
                                          INPUT  aux_uladitiv,
                                          INPUT  par_cdaditiv,
                                          INPUT  par_flgpagto,
                                          INPUT  par_dtdpagto,
                                          INPUT  0, /* nrctagar */
                                          INPUT  0, /* tpaplica */
                                          INPUT  0, /* nraplica */
                                          INPUT  crapbpr.dsbemfin,
                                          INPUT  crapbpr.nrrenava,
                                          INPUT  crapbpr.tpchassi,
                                          INPUT  crapbpr.dschassi,
                                          INPUT  crapbpr.nrdplaca,
                                          INPUT  crapbpr.ufdplaca,
                                          INPUT  crapbpr.dscorbem,
                                          INPUT  crapbpr.nranobem,
                                          INPUT  crapbpr.nrmodbem,
                                          INPUT  crapbpr.uflicenc,
                                          INPUT  "", /* nmdgaran */
                                          INPUT  0,  /* nrcpfgar */
                                          INPUT  "", /* nrdocgar */
                                          INPUT  "", /* nrpromis */
                                          INPUT  0,  /* vlpromis */
                                          INPUT  0,
                                          INPUT  par_tpctrato,
                                          INPUT  0). /* idgaropc */
                        END. /* par_cdaditiv = 5 */

                    WHEN 6 THEN
                        DO:
                            RUN obtem_nro_aditivo
                                ( INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT par_nrctremp,
                                  INPUT par_tpctrato,
                                 OUTPUT aux_uladitiv,
                                 OUTPUT aux_cdcritic).

                            IF  aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            Contador: DO aux_contador = 1 TO 10:

                                FIND crawepr WHERE
                                     crawepr.cdcooper = par_cdcooper AND
                                     crawepr.nrdconta = par_nrdconta AND
                                     crawepr.nrctremp = par_nrctremp
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                IF  NOT AVAIL crawepr THEN
                                    DO:
                                        IF  LOCKED crawepr   THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 77.
                                                        LEAVE Contador.
                                                    END.
                                                ELSE
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT Contador.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 356.
                                                LEAVE Contador.
                                            END.
                                    END.
                                ELSE
                                    LEAVE Contador.

                            END. /* Contador */

                            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            CREATE crapadt.
                            ASSIGN crapadt.nrdconta = par_nrdconta
                                   crapadt.nrctremp = par_nrctremp
                                   crapadt.nraditiv = aux_uladitiv
                                   crapadt.cdaditiv = 6
                                   crapadt.tpctrato = par_tpctrato
                                   crapadt.dtmvtolt = par_dtmvtolt
                                   crapadt.nrcpfgar = par_nrcpfgar
                                   crapadt.nrdocgar = par_nrdocgar
                                   crapadt.nmdgaran = par_nmdgaran
                                   crapadt.cdcooper = par_cdcooper
                                   crapadt.cdagenci = aux_cdagenci
                                   crapadt.cdoperad = par_cdoperad
                                   crapadt.flgdigit = NO.
                            VALIDATE crapadt.

                            CREATE crapadi.
                            ASSIGN crapadi.nrdconta = par_nrdconta
                                   crapadi.nrctremp = par_nrctremp
                                   crapadi.nraditiv = aux_uladitiv
                                   crapadi.tpctrato = par_tpctrato
                                   crapadi.nrsequen = 1
                                   crapadi.dsbemfin = par_dsbemfin
                                   crapadi.dschassi = par_dschassi
                                   crapadi.nrdplaca = par_nrdplaca
                                   crapadi.dscorbem = par_dscorbem
                                   crapadi.nranobem = par_nranobem
                                   crapadi.nrmodbem = par_nrmodbem
                                   crapadi.nrrenava = par_nrrenava
                                   crapadi.tpchassi = par_tpchassi
                                   crapadi.ufdplaca = par_ufdplaca
                                   crapadi.uflicenc = par_uflicenc
                                   crapadi.cdcooper = par_cdcooper.
                            VALIDATE crapadi.

                            /* Log */
                            RUN Gera_Log (INPUT  par_cdcooper,
                                          INPUT  par_cdoperad,
                                          INPUT  par_nmdatela,
                                          INPUT  par_dtmvtolt,
                                          INPUT  par_cddopcao,
                                          INPUT  par_nrdconta,
                                          INPUT  par_nrctremp,
                                          INPUT  aux_uladitiv,
                                          INPUT  par_cdaditiv,
                                          INPUT  par_flgpagto,
                                          INPUT  par_dtdpagto,
                                          INPUT  0, /* nrctagar */
                                          INPUT  0, /* tpaplica */
                                          INPUT  0, /* nraplica */
                                          INPUT  par_dsbemfin,
                                          INPUT  par_nrrenava,
                                          INPUT  par_tpchassi,
                                          INPUT  par_dschassi,
                                          INPUT  par_nrdplaca,
                                          INPUT  par_ufdplaca,
                                          INPUT  par_dscorbem,
                                          INPUT  par_nranobem,
                                          INPUT  par_nrmodbem,
                                          INPUT  par_uflicenc,
                                          INPUT  par_nmdgaran,
                                          INPUT  par_nrcpfgar,
                                          INPUT  par_nrdocgar,
                                          INPUT  "", /* nrpromis */
                                          INPUT  0,  /* vlpromis */
                                          INPUT  0,  /* tpproapl */
                                          INPUT  par_tpctrato,
                                          INPUT  0). /* idgaropc */

                        END. /* par_cdaditiv = 6 */
                    WHEN 7 THEN
                        DO:
                            RUN obtem_nro_aditivo
                                ( INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT par_nrctremp,
                                  INPUT par_tpctrato,
                                 OUTPUT aux_uladitiv,
                                 OUTPUT aux_cdcritic).

                            IF  aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            Contador: DO aux_contador = 1 TO 10:

                                FIND crapepr WHERE
                                     crapepr.cdcooper = par_cdcooper AND
                                     crapepr.nrdconta = par_nrdconta AND
                                     crapepr.nrctremp = par_nrctremp
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                IF  NOT AVAIL crapepr THEN
                                    DO:
                                        IF  LOCKED crapepr THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 77.
                                                        LEAVE Contador.
                                                    END.
                                                ELSE
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT Contador.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 356.
                                                LEAVE Contador.
                                            END.
                                    END.
                                ELSE
                                    LEAVE Contador.

                            END. /* Contador */

                            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            Contador: DO aux_contador = 1 TO 10:
                                IF  par_nrpromis[aux_contador] <> "" AND
                                    par_vlpromis[aux_contador] > 0   THEN
                                    DO:
                                        CREATE crapadt.
                                        ASSIGN crapadt.nrdconta = par_nrdconta
                                               crapadt.nrctremp = par_nrctremp
                                               crapadt.nraditiv = aux_uladitiv
                                               crapadt.cdaditiv = 7
                                               crapadt.tpctrato = par_tpctrato
                                               crapadt.dtmvtolt = par_dtmvtolt
                                               crapadt.cdcooper = par_cdcooper
                                               crapadt.cdagenci = aux_cdagenci
                                               crapadt.cdoperad = par_cdoperad
                                               crapadt.flgdigit = YES.
                                        VALIDATE crapadt.
                                        LEAVE Contador.
                                    END.

                                IF  aux_contador = 10 THEN
                                    LEAVE Grava.
                            END.

                            ASSIGN aux_nrsequen = 1.

                            Contador: DO aux_contador = 1 TO 10:

                                IF  par_nrpromis[aux_contador] <> "" AND
                                    par_vlpromis[aux_contador] > 0   THEN
                                    DO:
                                        CREATE crapadi.
                                        ASSIGN crapadi.nrdconta = par_nrdconta
                                               crapadi.nrctremp = par_nrctremp
                                               crapadi.nraditiv = aux_uladitiv
                                               crapadi.tpctrato = par_tpctrato
                                               crapadi.nrsequen = aux_nrsequen
                                               crapadi.nrcpfcgc = par_nrcpfgar
                                               crapadi.nmdavali = par_nmdgaran
                                               crapadi.nrpromis =
                                                    par_nrpromis[aux_contador]
                                               crapadi.vlpromis = par_vlpromis[aux_contador]
                                               crapadi.cdcooper = par_cdcooper
                                               aux_nrsequen = aux_nrsequen + 1.
                                        VALIDATE crapadi.

                                        /* Log */
                                        RUN Gera_Log (INPUT  par_cdcooper,
                                                      INPUT  par_cdoperad,
                                                      INPUT  par_nmdatela,
                                                      INPUT  par_dtmvtolt,
                                                      INPUT  par_cddopcao,
                                                      INPUT  par_nrdconta,
                                                      INPUT  par_nrctremp,
                                                      INPUT  aux_uladitiv,
                                                      INPUT  par_cdaditiv,
                                                      INPUT  par_flgpagto,
                                                      INPUT  par_dtdpagto,
                                                      INPUT  0, /* nrctagar */
                                                      INPUT  0, /* tpaplica */
                                                      INPUT  0, /* nraplica */
                                                      INPUT  par_dsbemfin,
                                                      INPUT  par_nrrenava,
                                                      INPUT  par_tpchassi,
                                                      INPUT  par_dschassi,
                                                      INPUT  par_nrdplaca,
                                                      INPUT  par_ufdplaca,
                                                      INPUT  par_dscorbem,
                                                      INPUT  par_nranobem,
                                                      INPUT  par_nrmodbem,
                                                      INPUT  par_uflicenc,
                                                      INPUT  "", /* nmdgaran */
                                                      INPUT  par_nrcpfgar,
                                                      INPUT  "", /* nrdocgar */
                                                      INPUT  par_nrpromis[aux_contador],
                                                      INPUT  par_vlpromis[aux_contador],
                                                      INPUT  0, /* tpproapl */
                                                      INPUT  par_tpctrato,
                                                      INPUT  0). /* idgaropc */

                                    END.
                            END.


                        END. /* par_cdaditiv = 7 */
                    WHEN 8 THEN
                        DO:
                            RUN obtem_nro_aditivo
                                ( INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT par_nrctremp,
                                  INPUT par_tpctrato,
                                 OUTPUT aux_uladitiv,
                                 OUTPUT aux_cdcritic).

                            IF  aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            Contador: DO aux_contador = 1 TO 10:

                                FIND crapepr WHERE
                                     crapepr.cdcooper = par_cdcooper AND
                                     crapepr.nrdconta = par_nrdconta AND
                                     crapepr.nrctremp = par_nrctremp
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                IF  NOT AVAIL crapepr THEN
                                    DO:
                                        IF  LOCKED crapepr   THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 77.
                                                        LEAVE Contador.
                                                    END.
                                                ELSE
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT Contador.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 356.
                                                LEAVE Contador.
                                            END.
                                    END.
                                ELSE
                                    LEAVE Contador.

                            END. /* Contador */

                            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            CREATE crapadt.
                            ASSIGN crapadt.nrdconta = par_nrdconta
                                   crapadt.nrctremp = par_nrctremp
                                   crapadt.nraditiv = aux_uladitiv
                                   crapadt.cdaditiv = 8
                                   crapadt.tpctrato = par_tpctrato
                                   crapadt.dtmvtolt = par_dtmvtolt
                                   crapadt.cdcooper = par_cdcooper
                                   crapadt.cdagenci = aux_cdagenci
                                   crapadt.cdoperad = par_cdoperad
                                   crapadt.flgdigit = YES.
                            VALIDATE crapadt.

                            CREATE crapadi.
                            ASSIGN crapadi.nrdconta = par_nrdconta
                                   crapadi.nrctremp = par_nrctremp
                                   crapadi.nraditiv = aux_uladitiv
                                   crapadi.tpctrato = par_tpctrato
                                   crapadi.nrsequen = 1
                                   crapadi.nrcpfcgc = par_nrcpfgar
                                   crapadi.nmdavali = par_nmdgaran
                                   crapadi.vlpromis = par_vlpromis[1]
                                   crapadi.cdcooper = par_cdcooper.
                            VALIDATE crapadi.

                            /* Log */
                            RUN Gera_Log (INPUT  par_cdcooper,
                                          INPUT  par_cdoperad,
                                          INPUT  par_nmdatela,
                                          INPUT  par_dtmvtolt,
                                          INPUT  par_cddopcao,
                                          INPUT  par_nrdconta,
                                          INPUT  par_nrctremp,
                                          INPUT  aux_uladitiv,
                                          INPUT  par_cdaditiv,
                                          INPUT  par_flgpagto,
                                          INPUT  par_dtdpagto,
                                          INPUT  0, /* nrctagar */
                                          INPUT  0, /* tpaplica */
                                          INPUT  0, /* nraplica */
                                          INPUT  par_dsbemfin,
                                          INPUT  par_nrrenava,
                                          INPUT  par_tpchassi,
                                          INPUT  par_dschassi,
                                          INPUT  par_nrdplaca,
                                          INPUT  par_ufdplaca,
                                          INPUT  par_dscorbem,
                                          INPUT  par_nranobem,
                                          INPUT  par_nrmodbem,
                                          INPUT  par_uflicenc,
                                          INPUT  "", /* nmdgaran */
                                          INPUT  par_nrcpfgar,
                                          INPUT  "", /* nrdocgar */
                                          INPUT  "", /* nrpromis */
                                          INPUT  par_vlpromis[1],
                                          INPUT  0,  /* tpproapl */
                                          INPUT  par_tpctrato,
                                          INPUT  0). /* idgaropc */


                        END. /* par_cdaditiv = 8 */

                    WHEN 9 THEN
                        DO:
                            FIND FIRST crapadt WHERE
                                       crapadt.cdcooper = par_cdcooper AND
                                       crapadt.tpctrato = par_tpctrato AND
                                       crapadt.nrdconta = par_nrdconta AND
                                       crapadt.nrctremp = par_nrctremp AND
                                       crapadt.cdaditiv = 9
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                            IF  AVAIL crapadt  THEN
                                DO:
                                    ASSIGN crapadt.dtmvtolt = par_dtmvtolt 
                                           crapadt.cdagenci = aux_cdagenci 
                                           crapadt.cdoperad = par_cdoperad 
                                           crapadt.flgdigit = NO
                                           aux_uladitiv     = crapadt.nraditiv.
                                END.
                            ELSE
                                DO:
                                    RUN obtem_nro_aditivo
                                        ( INPUT par_cdcooper,
                                          INPUT par_nrdconta,
                                          INPUT par_nrctremp,
                                          INPUT par_tpctrato,
                                         OUTPUT aux_uladitiv,
                                         OUTPUT aux_cdcritic).

                                    IF  aux_cdcritic <> 0 THEN
                                        UNDO Grava, LEAVE Grava.

                                    CREATE crapadt.
                                    ASSIGN crapadt.nrdconta = par_nrdconta
                                           crapadt.nrctremp = par_nrctremp
                                           crapadt.nraditiv = aux_uladitiv
                                           crapadt.cdaditiv = 9
                                           crapadt.tpctrato = par_tpctrato
                                           crapadt.dtmvtolt = par_dtmvtolt
                                           crapadt.cdcooper = par_cdcooper
                                           crapadt.cdagenci = aux_cdagenci
                                           crapadt.cdoperad = par_cdoperad
                                           crapadt.flgdigit = NO.
                                    VALIDATE crapadt.
                                END.

                            /* Atualizar na proposta o ID da cobertura gravada conforme o tipo de contrato */
                            IF  par_tpctrato = 90 THEN
                                DO:
                                   FIND FIRST crawepr WHERE
                                              crawepr.cdcooper = par_cdcooper AND
                                              crawepr.nrdconta = par_nrdconta AND
                                              crawepr.nrctremp = par_nrctremp
                                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                   IF  AVAIL crawepr THEN
                                       DO:
                                           ASSIGN aux_idgaropc_old = crawepr.idcobope
                                                  crawepr.idcobope = par_idgaropc.
                                       END.
                                END.
                            ELSE
                                DO:
                                   FIND FIRST craplim WHERE
                                              craplim.cdcooper = par_cdcooper AND
                                              craplim.nrdconta = par_nrdconta AND
                                              craplim.nrctrlim = par_nrctremp AND
                                              craplim.tpctrlim = par_tpctrato
                                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                   IF  AVAIL craplim THEN
                                       DO:
                                           ASSIGN aux_idgaropc_old = craplim.idcobope
                                                  craplim.idcobope = par_idgaropc.
                                       END.
                                END.

                            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                            /* Efetuar a chamada a rotina Oracle */
                            RUN STORED-PROCEDURE pc_vincula_cobertura_operacao
                            aux_handproc = PROC-HANDLE NO-ERROR (INPUT aux_idgaropc_old /* pr_idcobertura_anterior */
                                                                ,INPUT par_idgaropc     /* pr_idcobertura_nova */
                                                                ,INPUT par_nrctremp     /* pr_nrcontrato */
                                                                ,OUTPUT "").            /* pr_dscritic */

                            /* Fechar o procedimento para buscarmos o resultado */
                            CLOSE STORED-PROC pc_vincula_cobertura_operacao
                                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                            /* Busca possiveis erros */
                            ASSIGN aux_dscritic = ""
                                   aux_dscritic = pc_vincula_cobertura_operacao.pr_dscritic
                                                  WHEN pc_vincula_cobertura_operacao.pr_dscritic <> ?.

                            IF  aux_dscritic <> "" THEN
                                UNDO Grava, LEAVE Grava.

                            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                            /* Efetuar a chamada a rotina Oracle */
                            RUN STORED-PROCEDURE pc_bloq_desbloq_cob_operacao
                            aux_handproc = PROC-HANDLE NO-ERROR (INPUT "ADITIV"     /* pr_nmdatela */
                                                                ,INPUT par_idgaropc /* pr_idcobertura */
                                                                ,INPUT "B"          /* pr_inbloq_desbloq */
                                                                ,INPUT par_cdoperad /* pr_cdoperador */
                                                                ,INPUT ""           /* pr_cdcoordenador_desbloq */
                                                                ,INPUT 0            /* pr_vldesbloq */
                                                                ,INPUT "S"          /* pr_flgerar_log */
                                                                ,OUTPUT "").        /* pr_dscritic */

                            /* Fechar o procedimento para buscarmos o resultado */
                            CLOSE STORED-PROC pc_bloq_desbloq_cob_operacao
                                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                            /* Busca possiveis erros */
                            ASSIGN aux_dscritic = ""
                                   aux_dscritic = pc_bloq_desbloq_cob_operacao.pr_dscritic
                                                  WHEN pc_bloq_desbloq_cob_operacao.pr_dscritic <> ?.

                            IF  aux_dscritic <> "" THEN
                                UNDO Grava, LEAVE Grava.

                            /* Log */
                            RUN Gera_Log (INPUT  par_cdcooper,
                                          INPUT  par_cdoperad,
                                          INPUT  par_nmdatela,
                                          INPUT  par_dtmvtolt,
                                          INPUT  par_cddopcao,
                                          INPUT  par_nrdconta,
                                          INPUT  par_nrctremp,
                                          INPUT  aux_uladitiv,
                                          INPUT  par_cdaditiv,
                                          INPUT  par_flgpagto,
                                          INPUT  par_dtdpagto,
                                          INPUT  0, /* nrctagar */
                                          INPUT  0, /* tpaplica */
                                          INPUT  0, /* nraplica */
                                          INPUT  par_dsbemfin,
                                          INPUT  par_nrrenava,
                                          INPUT  par_tpchassi,
                                          INPUT  par_dschassi,
                                          INPUT  par_nrdplaca,
                                          INPUT  par_ufdplaca,
                                          INPUT  par_dscorbem,
                                          INPUT  par_nranobem,
                                          INPUT  par_nrmodbem,
                                          INPUT  par_uflicenc,
                                          INPUT  "", /* nmdgaran */
                                          INPUT  0,  /* nrcpfgar */
                                          INPUT  "", /* nrdocgar */
                                          INPUT  "", /* nrpromis */
                                          INPUT  0,  /* vlpromis */
                                          INPUT  0,  /* tpproapl */
                                          INPUT  par_tpctrato,
                                          INPUT  par_idgaropc).


                        END. /* par_cdaditiv = 9 */

                END CASE.

            END. /* IF  par_cddopcao = "I" */
        ELSE
        IF  par_cddopcao = "E" THEN
            DO:

                ASSIGN aux_dstransa = "Excluir aditivo contratual de " +
                                      "emprestimo.".
                CASE par_cdaditiv:
                    WHEN 2 THEN
                        DO:
                            Contador: DO aux_contador = 1 TO 10:

                                FIND crapadt WHERE
                                     crapadt.cdcooper = par_cdcooper AND
                                     crapadt.nrdconta = par_nrdconta AND
                                     crapadt.nrctremp = par_nrctremp AND
                                     crapadt.nraditiv = par_nraditiv
                                     EXCLUSIVE-LOCK NO-ERROR.

                                IF  NOT AVAIL crapadt THEN
                                    DO:
                                        IF  LOCKED crapadt   THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 77.
                                                        LEAVE Contador.
                                                    END.
                                                ELSE
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT Contador.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 55.
                                                LEAVE Contador.
                                            END.
                                    END.
                                ELSE
                                    LEAVE Contador.
                            END. /* Contador */

                            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            DELETE crapadt.

                            FOR EACH crapadi WHERE
                                     crapadi.cdcooper = par_cdcooper AND
                                     crapadi.nrdconta = par_nrdconta AND
                                     crapadi.nrctremp = par_nrctremp AND
                                     crapadi.nraditiv = par_nraditiv
                                     EXCLUSIVE-LOCK:


                                IF  crapadi.tpproapl = 2 THEN
                                    DO:
                                        /* DESBLOQUEIA todas as aplicacoes dessa conta
                                           e contrato que foram bloqueadas pela tela
                                           ADITIV */
                                        FIND craptab WHERE
                                             craptab.cdcooper = par_cdcooper        AND
                                             craptab.nmsistem = "CRED"              AND
                                             craptab.tptabela = "BLQRGT"            AND
                                             craptab.cdempres = 00                  AND
                                             craptab.cdacesso = STRING(crapadi.nrdconta
                                                                    ,"9999999999")  AND
                                             SUBSTRING(craptab.dstextab,1,7) =
                                                 STRING(crapadi.nraplica,"9999999") AND
                                             SUBSTRING(craptab.dstextab,10,1) = "A"
                                             EXCLUSIVE-LOCK NO-ERROR.

                                        IF  AVAIL craptab THEN
                                            DELETE craptab.
                                    END.
                                ELSE
                                    DO:

                                        FIND craprac WHERE
                                             craprac.cdcooper = par_cdcooper     AND
                                             craprac.nrdconta = crapadi.nrdconta AND
                                             craprac.nraplica = crapadi.nraplica AND
                                             craprac.idblqrgt = 2 EXCLUSIVE-LOCK NO-ERROR.

                                        IF  AVAIL craprac THEN
                                            ASSIGN craprac.idblqrgt = 0.
                                    END.

                                /* Log */
                                RUN Gera_Log (INPUT  par_cdcooper,
                                              INPUT  par_cdoperad,
                                              INPUT  par_nmdatela,
                                              INPUT  par_dtmvtolt,
                                              INPUT  par_cddopcao,
                                              INPUT  par_nrdconta,
                                              INPUT  par_nrctremp,
                                              INPUT  par_nraditiv,
                                              INPUT  par_cdaditiv,
                                              INPUT  NO, /* flgpagto */
                                              INPUT  ?, /* dtdpagto */
                                              INPUT  0, /* nrctagar */
                                              INPUT  crapadi.tpaplica,
                                              INPUT  crapadi.nraplica,
                                              INPUT  "", /* dsbemfin */
                                              INPUT  0,  /* nrrenava */
                                              INPUT  0,  /* tpchassi */
                                              INPUT  "", /* dschassi */
                                              INPUT  "", /* nrdplaca */
                                              INPUT  "", /* ufdplaca */
                                              INPUT  "", /* dscorbem */
                                              INPUT  0,  /* nranobem */
                                              INPUT  0,  /* nrmodbem */
                                              INPUT  "", /* uflicenc */
                                              INPUT  "", /* nmdgaran */
                                              INPUT  0,  /* nrcpfgar */
                                              INPUT  "", /* nrdocgar */
                                              INPUT  "", /* nrpromis */
                                              INPUT  0,  /* vlpromis */
                                              INPUT  crapadi.tpproapl,
                                              INPUT  par_tpctrato,
                                              INPUT  0). /* idgaropc */

                                DELETE crapadi.

                            END. /* FOR EACH crapadi */

                        END. /* par_cdaditiv = 2 */
                    WHEN 3 THEN
                        DO:
                            Contador: DO aux_contador = 1 TO 10:

                                FIND crapadt WHERE
                                     crapadt.cdcooper = par_cdcooper AND
                                     crapadt.nrdconta = par_nrdconta AND
                                     crapadt.nrctremp = par_nrctremp AND
                                     crapadt.nraditiv = par_nraditiv
                                     EXCLUSIVE-LOCK NO-ERROR.

                                IF  NOT AVAIL crapadt THEN
                                    DO:
                                        IF  LOCKED crapadt   THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 77.
                                                        LEAVE Contador.
                                                    END.
                                                ELSE
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT Contador.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 55.
                                                LEAVE Contador.
                                            END.
                                    END.
                                ELSE
                                    DO:
                                       ASSIGN aux_nrctagar = crapadt.nrctagar.
                                       LEAVE Contador.
                                    END.

                            END. /* Contador */

                            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            FOR EACH crapadi WHERE
                                     crapadi.cdcooper = par_cdcooper AND
                                     crapadi.nrdconta = par_nrdconta AND
                                     crapadi.nrctremp = par_nrctremp AND
                                     crapadi.nraditiv = par_nraditiv
                                     EXCLUSIVE-LOCK:

                                IF  crapadi.tpproapl = 2 THEN
                                    DO:
                                        /* DESBLOQUEIA todas as aplicacoes do
                                           interveniente garantidor que foram
                                           bloqueadas pela tela ADITIV */

                                        FIND craptab WHERE
                                             craptab.cdcooper = par_cdcooper        AND
                                             craptab.nmsistem = "CRED"              AND
                                             craptab.tptabela = "BLQRGT"            AND
                                             craptab.cdempres = 00                  AND
                                             craptab.cdacesso = STRING(par_nrctagar,
                                                                      "9999999999") AND
                                             SUBSTRING(craptab.dstextab,1,7) =
                                                 STRING(crapadi.nraplica,"9999999") AND
                                             SUBSTRING(craptab.dstextab,10,1) = "A"
                                             EXCLUSIVE-LOCK NO-ERROR.

                                        IF  AVAIL craptab THEN
                                            DELETE craptab.
                                    END.
                                ELSE
                                    DO:
                                        FIND craprac WHERE
                                             craprac.cdcooper = par_cdcooper        AND
                                             craprac.nrdconta = par_nrctagar        AND
                                             craprac.nraplica = crapadi.nraplica    AND
                                             craprac.idblqrgt = 2 EXCLUSIVE-LOCK NO-ERROR.

                                        IF  AVAIL craprac THEN
                                            ASSIGN craprac.idblqrgt = 0.
                                    END.


                                /* Log */
                                RUN Gera_Log (INPUT  par_cdcooper,
                                              INPUT  par_cdoperad,
                                              INPUT  par_nmdatela,
                                              INPUT  par_dtmvtolt,
                                              INPUT  par_cddopcao,
                                              INPUT  par_nrdconta,
                                              INPUT  par_nrctremp,
                                              INPUT  par_nraditiv,
                                              INPUT  par_cdaditiv,
                                              INPUT  NO, /* flgpagto */
                                              INPUT  ?, /* dtdpagto */
                                              INPUT  aux_nrctagar,
                                              INPUT  crapadi.tpaplica,
                                              INPUT  crapadi.nraplica,
                                              INPUT  "", /* dsbemfin */
                                              INPUT  0,  /* nrrenava */
                                              INPUT  0,  /* tpchassi */
                                              INPUT  "", /* dschassi */
                                              INPUT  "", /* nrdplaca */
                                              INPUT  "", /* ufdplaca */
                                              INPUT  "", /* dscorbem */
                                              INPUT  0,  /* nranobem */
                                              INPUT  0,  /* nrmodbem */
                                              INPUT  "", /* uflicenc */
                                              INPUT  "", /* nmdgaran */
                                              INPUT  0,  /* nrcpfgar */
                                              INPUT  "", /* nrdocgar */
                                              INPUT  "", /* nrpromis */
                                              INPUT  0,  /* vlpromis */
                                              INPUT  crapadi.tpproapl,
                                              INPUT  par_tpctrato,
                                              INPUT  0). /* idgaropc */

                                DELETE crapadi.

                            END. /* FOR EACH crapadi */

                            DELETE crapadt.

                        END. /* par_cdaditiv = 3 */
                    WHEN 5 THEN  /** Exclusao do Bem - Opcao "E" - Tipo 5 **/
                        DO:
                            Contador: DO aux_contador = 1 TO 10:

                                FIND crapadt WHERE
                                     crapadt.cdcooper = par_cdcooper AND
                                     crapadt.nrdconta = par_nrdconta AND
                                     crapadt.nrctremp = par_nrctremp AND
                                     crapadt.nraditiv = par_nraditiv
                                     EXCLUSIVE-LOCK NO-ERROR.

                                IF  NOT AVAIL crapadt THEN
                                    DO:
                                        IF  LOCKED crapadt   THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 77.
                                                        LEAVE Contador.
                                                    END.
                                                ELSE
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT Contador.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 55.
                                                LEAVE Contador.
                                            END.
                                    END.
                                ELSE
                                    LEAVE Contador.
                            END. /* Contador */

                            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            Contador: DO aux_contador = 1 TO 10:

                                FIND crapadi WHERE
                                     crapadi.cdcooper = par_cdcooper AND
                                     crapadi.nrdconta = par_nrdconta AND
                                     crapadi.nrctremp = par_nrctremp AND
                                     crapadi.nraditiv = par_nraditiv
                                     EXCLUSIVE-LOCK NO-ERROR.

                                IF  NOT AVAIL crapadi THEN
                                    DO:
                                        IF  LOCKED crapadi   THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 77.
                                                        LEAVE Contador.
                                                    END.
                                                ELSE
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT Contador.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 55.
                                                LEAVE Contador.
                                            END.
                                    END.
                                ELSE
                                    LEAVE Contador.
                            END. /* Contador */

                            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            /* Bens alienados */
                            Bens: FOR EACH crapbpr WHERE
                                     crapbpr.cdcooper = par_cdcooper AND
                                     crapbpr.nrdconta = par_nrdconta AND
                                     crapbpr.tpctrpro = 90           AND
                                     crapbpr.nrctrpro = par_nrctremp AND
                                     crapbpr.flgalien = TRUE
                                     EXCLUSIVE-LOCK:

                                IF  crapbpr.dscatbem = "AUTOMOVEL"  AND
                                    crapbpr.dsbemfin = par_dsbemfin AND
                                    crapbpr.dschassi = par_dschassi AND
                                    crapbpr.nrdplaca = par_nrdplaca AND
                                    crapbpr.dscorbem = par_dscorbem AND
                                    crapbpr.nranobem = par_nranobem AND
                                    crapbpr.nrmodbem = par_nrmodbem AND
                                    crapbpr.nrrenava = par_nrrenava AND
                                    crapbpr.tpchassi = par_tpchassi AND
                                    crapbpr.ufdplaca = par_ufdplaca AND
                                    crapbpr.uflicenc = par_uflicenc THEN
                                    DO:


                                    /*** GRAVAMES ***/
                                    /* Se BEM estiver "EM PROCESSAMENTO" nao deixa seguir */
                                    IF  crapbpr.cdsitgrv = 1 THEN DO:
                                        ASSIGN aux_dscritic =
                                            " Bem em Processamento Gravames! " +
                                            " Operacao nao efetuada!".
                                        UNDO Grava, LEAVE Grava.
                                    END.

                                    /* Log */
                                    RUN Gera_Log (INPUT  par_cdcooper,
                                                  INPUT  par_cdoperad,
                                                  INPUT  par_nmdatela,
                                                  INPUT  par_dtmvtolt,
                                                  INPUT  par_cddopcao,
                                                  INPUT  par_nrdconta,
                                                  INPUT  par_nrctremp,
                                                  INPUT  par_nraditiv,
                                                  INPUT  par_cdaditiv,
                                                  INPUT  NO, /* flgpagto */
                                                  INPUT  ?, /* dtdpagto */
                                                  INPUT  0,  /* nrctagar */
                                                  INPUT  0,  /* tpaplica */
                                                  INPUT  0,  /* nraplica */
                                                  INPUT  crapbpr.dsbemfin,
                                                  INPUT  crapbpr.nrrenava,
                                                  INPUT  crapbpr.tpchassi,
                                                  INPUT  crapbpr.dschassi,
                                                  INPUT  crapbpr.nrdplaca,
                                                  INPUT  crapbpr.ufdplaca,
                                                  INPUT  crapbpr.dscorbem,
                                                  INPUT  crapbpr.nranobem,
                                                  INPUT  crapbpr.nrmodbem,
                                                  INPUT  crapbpr.uflicenc,
                                                  INPUT  "", /* nmdgaran */
                                                  INPUT  0,  /* nrcpfgar */
                                                  INPUT  "", /* nrdocgar */
                                                  INPUT  "", /* nrpromis */
                                                  INPUT  0,  /* vlpromis */
                                                  INPUT  0,  /* tpproapl */
                                                  INPUT  par_tpctrato,
                                                  INPUT  0). /* idgaropc */

                                        /* GRAVAMES - Copia BEM para tipo 99 */
                                        IF  (par_cdcooper = 1 AND
                                             par_dtmvtolt >= 11/18/2014)
                                        OR  (par_cdcooper = 4 AND
                                             par_dtmvtolt >= 07/23/2014)
                                        OR  (par_cdcooper = 7 AND
                                             par_dtmvtolt >= 10/06/2014)
                                        OR  (NOT CAN-DO("1,4,7",
                                                 STRING(par_cdcooper)) AND
                                             par_dtmvtolt >= 02/26/2015) THEN DO:
                                            FIND LAST crabbpr
                                                WHERE crabbpr.cdcooper = par_cdcooper
                                                  AND crabbpr.nrdconta = par_nrdconta
                                                  AND crabbpr.tpctrpro = 99
                                                  AND crabbpr.nrctrpro = par_nrctremp
                                                  NO-LOCK NO-ERROR.

                                            IF  AVAIL crabbpr THEN
                                                ASSIGN aux_idseqbe2 = crabbpr.idseqbem + 1.
                                            ELSE
                                                ASSIGN aux_idseqbe2 = 1.

                                            CREATE crabbpr.
                                            BUFFER-COPY crapbpr
                                                 EXCEPT crapbpr.tpctrpro
                                                        crapbpr.idseqbem
                                                     TO crabbpr.
                                            ASSIGN crabbpr.tpctrpro = 99
                                                   crabbpr.flgbaixa = TRUE
                                                   crabbpr.dtdbaixa = par_dtmvtolt
                                                   crabbpr.tpdbaixa = "A"
                                                   crabbpr.flginclu = FALSE
                                                   crabbpr.flcancel = FALSE
                                                   crabbpr.idseqbem = aux_idseqbe2.
                                        END.
                                        /** GRAVAMES - Copia BEM para tipo 99 **/

                                        DELETE crapbpr.
                                        VALIDATE crabbpr.

                                        LEAVE Bens.
                                END. /** END do IF da BPR **/

                            END. /* Fim Bens */

                            DELETE crapadt.
                            DELETE crapadi.

                        END. /* par_cdaditiv = 5 */
                    WHEN 6 THEN
                        DO:
                            Contador: DO aux_contador = 1 TO 10:

                                FIND crapadt WHERE
                                     crapadt.cdcooper = par_cdcooper AND
                                     crapadt.nrdconta = par_nrdconta AND
                                     crapadt.nrctremp = par_nrctremp AND
                                     crapadt.nraditiv = par_nraditiv
                                     EXCLUSIVE-LOCK NO-ERROR.

                                IF  NOT AVAIL crapadt THEN
                                    DO:
                                        IF  LOCKED crapadt   THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 77.
                                                        LEAVE Contador.
                                                    END.
                                                ELSE
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT Contador.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 55.
                                                LEAVE Contador.
                                            END.
                                    END.
                                ELSE
                                    LEAVE Contador.
                            END. /* Contador */

                            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            Contador: DO aux_contador = 1 TO 10:

                                FIND crapadi WHERE
                                     crapadi.cdcooper = par_cdcooper AND
                                     crapadi.nrdconta = par_nrdconta AND
                                     crapadi.nrctremp = par_nrctremp AND
                                     crapadi.nraditiv = par_nraditiv
                                     EXCLUSIVE-LOCK NO-ERROR.

                                IF  NOT AVAIL crapadi THEN
                                    DO:
                                        IF  LOCKED crapadi   THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 77.
                                                        LEAVE Contador.
                                                    END.
                                                ELSE
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT Contador.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 55.
                                                LEAVE Contador.
                                            END.
                                    END.
                                ELSE
                                    LEAVE Contador.
                            END. /* Contador */

                            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            IF  AVAIL crapadi THEN
                                DO:
                                    /* Log */
                                    RUN Gera_Log (INPUT  par_cdcooper,
                                                  INPUT  par_cdoperad,
                                                  INPUT  par_nmdatela,
                                                  INPUT  par_dtmvtolt,
                                                  INPUT  par_cddopcao,
                                                  INPUT  par_nrdconta,
                                                  INPUT  par_nrctremp,
                                                  INPUT  par_nraditiv,
                                                  INPUT  par_cdaditiv,
                                                  INPUT  NO, /* flgpagto */
                                                  INPUT  ?, /* dtdpagto */
                                                  INPUT  0,  /* nrctagar */
                                                  INPUT  0,  /* tpaplica */
                                                  INPUT  0,  /* nraplica */
                                                  INPUT  crapadi.dsbemfin,
                                                  INPUT  crapadi.nrrenava,
                                                  INPUT  crapadi.tpchassi,
                                                  INPUT  crapadi.dschassi,
                                                  INPUT  crapadi.nrdplaca,
                                                  INPUT  crapadi.ufdplaca,
                                                  INPUT  crapadi.dscorbem,
                                                  INPUT  crapadi.nranobem,
                                                  INPUT  crapadi.nrmodbem,
                                                  INPUT  crapadi.uflicenc,
                                                  INPUT  crapadt.nmdgaran,
                                                  INPUT  crapadt.nrcpfgar,
                                                  INPUT  crapadt.nrdocgar,
                                                  INPUT  "", /* nrpromis */
                                                  INPUT  0,  /* vlpromis */
                                                  INPUT  0,  /* tpproapl */
                                                  INPUT  par_tpctrato,
                                                  INPUT  0). /* idgaropc */
                                END.

                            DELETE crapadt.
                            DELETE crapadi.

                        END. /* par_cdaditiv = 6 */

                    WHEN 7 THEN
                        DO:
                            Contador: DO aux_contador = 1 TO 10:

                                FIND crawepr WHERE
                                     crawepr.cdcooper = par_cdcooper AND
                                     crawepr.nrdconta = par_nrdconta AND
                                     crawepr.nrctremp = par_nrctremp
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                IF  NOT AVAIL crawepr THEN
                                    DO:
                                        IF  LOCKED crawepr   THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 77.
                                                        LEAVE Contador.
                                                    END.
                                                ELSE
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT Contador.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 356.
                                                LEAVE Contador.
                                            END.
                                    END.
                                ELSE
                                    LEAVE Contador.

                            END. /* Contador */

                            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            Contador: DO aux_contador = 1 TO 10:

                                FIND crapadt WHERE
                                     crapadt.cdcooper = par_cdcooper AND
                                     crapadt.nrdconta = par_nrdconta AND
                                     crapadt.nrctremp = par_nrctremp AND
                                     crapadt.nraditiv = par_nraditiv
                                     EXCLUSIVE-LOCK NO-ERROR.

                                IF  NOT AVAIL crapadt THEN
                                    DO:
                                        IF  LOCKED crapadt   THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 77.
                                                        LEAVE Contador.
                                                    END.
                                                ELSE
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT Contador.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 55.
                                                LEAVE Contador.
                                            END.
                                    END.
                                ELSE
                                    LEAVE Contador.

                            END. /* Contador */

                            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            ASSIGN aux_nrcpfgar = crapadt.nrcpfgar.

                            FOR EACH crapadi WHERE
                                     crapadi.cdcooper = par_cdcooper AND
                                     crapadi.nrdconta = par_nrdconta AND
                                     crapadi.nrctremp = par_nrctremp AND
                                     crapadi.nraditiv = par_nraditiv
                                     EXCLUSIVE-LOCK:

                                    /* Log */
                                    RUN Gera_Log (INPUT  par_cdcooper,
                                                  INPUT  par_cdoperad,
                                                  INPUT  par_nmdatela,
                                                  INPUT  par_dtmvtolt,
                                                  INPUT  par_cddopcao,
                                                  INPUT  par_nrdconta,
                                                  INPUT  par_nrctremp,
                                                  INPUT  par_nraditiv,
                                                  INPUT  par_cdaditiv,
                                                  INPUT  NO, /* flgpagto */
                                                  INPUT  ?, /* dtdpagto */
                                                  INPUT  0,  /* nrctagar */
                                                  INPUT  0,  /* tpaplica */
                                                  INPUT  0,  /* nraplica */
                                                  INPUT  "", /* dsbemfin */
                                                  INPUT  0,  /* nrrenava */
                                                  INPUT  0,  /* tpchassi */
                                                  INPUT  "", /* dschassi */
                                                  INPUT  "", /* nrdplaca */
                                                  INPUT  "", /* ufdplaca */
                                                  INPUT  "", /* dscorbem */
                                                  INPUT  0,  /* nranobem */
                                                  INPUT  0,  /* nrmodbem */
                                                  INPUT  "", /* uflicenc */
                                                  INPUT  "", /* nmdgaran */
                                                  INPUT  par_nrcpfgar,
                                                  INPUT  "", /* nrdocgar */
                                                  INPUT  crapadi.nrpromis,
                                                  INPUT  crapadi.vlpromis,
                                                  INPUT  0,  /* tpproapl */
                                                  INPUT  par_tpctrato,
                                                  INPUT  0). /* idgaropc */

                                DELETE crapadi.
                            END.

                            IF  AVAIL crapadt THEN
                                DELETE crapadt.

                        END. /* par_cdaditiv = 7 */
                    WHEN 8 THEN
                        DO:
                            Contador: DO aux_contador = 1 TO 10:

                                FIND crapadt WHERE
                                     crapadt.cdcooper = par_cdcooper AND
                                     crapadt.nrdconta = par_nrdconta AND
                                     crapadt.nrctremp = par_nrctremp AND
                                     crapadt.nraditiv = par_nraditiv
                                     EXCLUSIVE-LOCK NO-ERROR.

                                IF  NOT AVAIL crapadt THEN
                                    DO:
                                        IF  LOCKED crapadt   THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 77.
                                                        LEAVE Contador.
                                                    END.
                                                ELSE
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT Contador.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 55.
                                                LEAVE Contador.
                                            END.
                                    END.
                                ELSE
                                    DO:
                                        LEAVE Contador.
                                    END.
                            END. /* Contador */

                            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            Contador: DO aux_contador = 1 TO 10:

                                FIND crapadi WHERE
                                     crapadi.cdcooper = par_cdcooper AND
                                     crapadi.nrdconta = par_nrdconta AND
                                     crapadi.nrctremp = par_nrctremp AND
                                     crapadi.nraditiv = par_nraditiv
                                     EXCLUSIVE-LOCK NO-ERROR.

                                IF  NOT AVAIL crapadi THEN
                                    DO:
                                        IF  LOCKED crapadi   THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 77.
                                                        LEAVE Contador.
                                                    END.
                                                ELSE
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT Contador.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 55.
                                                LEAVE Contador.
                                            END.
                                    END.
                                ELSE
                                    DO:
                                        ASSIGN aux_vlpromis = crapadi.vlpromis.
                                        LEAVE Contador.
                                    END.

                            END. /* Contador */

                            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            Contador: DO aux_contador = 1 TO 10:

                                FIND crawepr WHERE
                                     crawepr.cdcooper = par_cdcooper AND
                                     crawepr.nrdconta = par_nrdconta AND
                                     crawepr.nrctremp = par_nrctremp
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                IF  NOT AVAIL crawepr THEN
                                    DO:
                                        IF  LOCKED crawepr   THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 77.
                                                        LEAVE Contador.
                                                    END.
                                                ELSE
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT Contador.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                ASSIGN aux_cdcritic = 356.
                                                LEAVE Contador.
                                            END.
                                    END.
                                ELSE
                                    LEAVE Contador.

                            END. /* Contador */

                            IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                                UNDO Grava, LEAVE Grava.

                            /* Log */
                            RUN Gera_Log (INPUT  par_cdcooper,
                                          INPUT  par_cdoperad,
                                          INPUT  par_nmdatela,
                                          INPUT  par_dtmvtolt,
                                          INPUT  par_cddopcao,
                                          INPUT  par_nrdconta,
                                          INPUT  par_nrctremp,
                                          INPUT  par_nraditiv,
                                          INPUT  par_cdaditiv,
                                          INPUT  NO, /* flgpagto */
                                          INPUT  ?, /* dtdpagto */
                                          INPUT  0,  /* nrctagar */
                                          INPUT  0,  /* tpaplica */
                                          INPUT  0,  /* nraplica */
                                          INPUT  "", /* dsbemfin */
                                          INPUT  0,  /* nrrenava */
                                          INPUT  0,  /* tpchassi */
                                          INPUT  "", /* dschassi */
                                          INPUT  "", /* nrdplaca */
                                          INPUT  "", /* ufdplaca */
                                          INPUT  "", /* dscorbem */
                                          INPUT  0,  /* nranobem */
                                          INPUT  0,  /* nrmodbem */
                                          INPUT  "", /* uflicenc */
                                          INPUT  "", /* nmdgaran */
                                          INPUT  par_nrcpfgar,
                                          INPUT  "", /* nrdocgar */
                                          INPUT  "", /* nrpromis */
                                          INPUT  aux_vlpromis,
                                          INPUT  0,  /* tpproapl */
                                          INPUT  par_tpctrato,
                                          INPUT  0). /* idgaropc */

                            DELETE crapadt.
                            DELETE crapadi.

                        END. /* par_cdaditiv = 8 */
                END CASE.

            END. /* IF  par_cddopcao = "E" */
        ELSE
        IF  par_cddopcao = "X" THEN
            DO:

                ASSIGN aux_dstransa = "Excluir bem alienado do " +
                                      "aditivo contratual de emprestimo.".

                Contador: DO aux_contador = 1 TO 10:
                    FIND crapbpr WHERE
                         crapbpr.cdcooper = par_cdcooper AND
                         crapbpr.nrdconta = par_nrdconta AND
                         crapbpr.tpctrpro = 90           AND
                         crapbpr.nrctrpro = par_nrctremp AND
                         crapbpr.idseqbem = par_idseqbem
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAIL crapbpr THEN
                        DO:
                            IF  LOCKED crapbpr   THEN
                                DO:
                                    IF  aux_contador = 10 THEN
                                        DO:
                                            ASSIGN
                                             aux_cdcritic = 77.
                                            LEAVE Contador.
                                        END.
                                    ELSE
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT Contador.
                                        END.
                                END.
                            ELSE
                                DO:
                                    ASSIGN aux_cdcritic = 55.
                                    LEAVE Contador.
                                END.
                        END.
                    ELSE
                        LEAVE Contador.

                END. /* Contador */

                IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
                    UNDO Grava, LEAVE Grava.

                IF  AVAIL crapbpr THEN
                    DO:
                        /* Log */
                        RUN Gera_Log (INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  par_nmdatela,
                                      INPUT  par_dtmvtolt,
                                      INPUT  par_cddopcao,
                                      INPUT  par_nrdconta,
                                      INPUT  par_nrctremp,
                                      INPUT  par_nraditiv,
                                      INPUT  par_cdaditiv,
                                      INPUT  NO, /* flgpagto */
                                      INPUT  ?,  /* dtdpagto */
                                      INPUT  0,  /* nrctagar */
                                      INPUT  0,  /* tpaplica */
                                      INPUT  0,  /* nraplica */
                                      INPUT  crapbpr.dsbemfin,
                                      INPUT  crapbpr.nrrenava,
                                      INPUT  crapbpr.tpchassi,
                                      INPUT  crapbpr.dschassi,
                                      INPUT  crapbpr.nrdplaca,
                                      INPUT  crapbpr.ufdplaca,
                                      INPUT  crapbpr.dscorbem,
                                      INPUT  crapbpr.nranobem,
                                      INPUT  crapbpr.nrmodbem,
                                      INPUT  crapbpr.uflicenc,
                                      INPUT  "", /* nmdgaran */
                                      INPUT  0,  /* nrcpfgar */
                                      INPUT  "", /* nrdocgar */
                                      INPUT  "", /* nrpromis */
                                      INPUT  0,  /* vlpromis */
                                      INPUT  0,  /* tpproapl */
                                      INPUT  par_tpctrato,
                                      INPUT  0). /* idgaropc */
                    END.


                /** GRAVAMES - Copia BEM para tipo 99 **/
                IF  (par_cdcooper = 1 AND
                     par_dtmvtolt >= 11/18/2014)
                OR  (par_cdcooper = 4 AND
                     par_dtmvtolt >= 07/23/2014)
                OR  (par_cdcooper = 7 AND
                     par_dtmvtolt >= 10/06/2014)
                OR  (NOT CAN-DO("1,4,7",STRING(par_cdcooper)) AND
                     par_dtmvtolt >= 02/26/2015) THEN DO:
                    FIND LAST crabbpr
                        WHERE crabbpr.cdcooper = par_cdcooper
                          AND crabbpr.nrdconta = par_nrdconta
                          AND crabbpr.tpctrpro = 99
                          AND crabbpr.nrctrpro = par_nrctremp
                          NO-LOCK NO-ERROR.

                    IF  AVAIL crabbpr THEN
                        ASSIGN aux_idseqbe2 = crabbpr.idseqbem + 1.
                    ELSE
                        ASSIGN aux_idseqbe2 = 1.

                    CREATE crabbpr.
                    BUFFER-COPY crapbpr
                         EXCEPT crapbpr.tpctrpro
                                crapbpr.idseqbem
                             TO crabbpr.
                    ASSIGN crabbpr.tpctrpro = 99
                           crabbpr.flgbaixa = TRUE
                           crabbpr.dtdbaixa = par_dtmvtolt
                           crabbpr.tpdbaixa = "A"
                           crabbpr.flginclu = FALSE
                           crabbpr.flcancel = FALSE
                           crabbpr.idseqbem = aux_idseqbe2.
                END.
                /** GRAVAMES - Copia BEM para tipo 99 **/

                DELETE crapbpr.
                VALIDATE crabbpr.

            END. /* IF  par_cddopcao = "X" */


        IF CAN-DO("I,E,X",par_cddopcao) THEN
           DO:
               /* INICIO - Atualizar os dados da tabela crapcyb (CYBER) */
               IF NOT VALID-HANDLE(h-b1wgen0168) THEN
                  RUN sistema/generico/procedures/b1wgen0168.p
                      PERSISTENT SET h-b1wgen0168.

               EMPTY TEMP-TABLE tt-crapcyb.

               CREATE tt-crapcyb.
               ASSIGN tt-crapcyb.cdcooper = par_cdcooper
                      tt-crapcyb.cdorigem = 3
                      tt-crapcyb.nrdconta = par_nrdconta
                      tt-crapcyb.nrctremp = par_nrctremp
                      tt-crapcyb.dtmangar = par_dtmvtolt.

               RUN atualiza_data_manutencao_garantia
                   IN h-b1wgen0168(INPUT TABLE tt-crapcyb,
                                   OUTPUT aux_cdcritic,
                                   OUTPUT aux_dscritic).

               IF VALID-HANDLE(h-b1wgen0168) THEN
                  DELETE PROCEDURE(h-b1wgen0168).

               IF RETURN-VALUE <> "OK" THEN
                  UNDO Grava, LEAVE Grava.
               /* FIM - Atualizar os dados da tabela crapcyb */
           END.

        LEAVE Grava.

    END. /* Grava */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT NO,
                                        INPUT 1, /** idseqttl **/
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).

                END.
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".


    RETURN aux_returnvl.

END PROCEDURE. /* Grava_Dados */

PROCEDURE Gera_Impressao:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR   FORMAT "x(10)"            NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_cdaditiv AS INTE   FORMAT "9"                NO-UNDO.
    DEF  INPUT PARAM par_nraditiv AS INTE   FORMAT "99"               NO-UNDO.
    DEF  INPUT PARAM par_nrctremp LIKE crapadt.nrctremp               NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE crapadi.nrdconta               NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                             NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                            NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                            NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.


    DEF VAR aux_qtregstr AS INTE                                      NO-UNDO.
    DEF VAR aux_nmendter AS CHAR    FORMAT "x(20)"                    NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crapcop   THEN
            DO:
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.
            
        /* Proposta de emprestimo */
        FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                           crawepr.nrdconta = par_nrdconta   AND
                           crawepr.nrctremp = par_nrctremp
                           NO-LOCK NO-ERROR.
                           
        IF  crawepr.dtmvtolt >= 10/22/2014    THEN
          DO:
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

            RUN STORED-PROCEDURE pc_gera_impressao_aditiv 
                aux_handproc = PROC-HANDLE NO-ERROR
                                 (INPUT par_cdcooper  /* pr_cdcooper --> Codigo da cooperativa */           
                                 ,INPUT par_cdagenci  /* pr_cdagenci --> Codigo da agencia */
                                 ,INPUT par_nrdcaixa  /* pr_nrdcaixa --> Numero do caixa  */
                                 ,INPUT par_idorigem  /* pr_idorigem --> Origem  */
                                 ,INPUT par_nmdatela  /* pr_nmdatela --> Nome da tela */
                                 ,INPUT par_nmdatela  /* pr_cdprogra --> Codigo do programa */
                                 ,INPUT par_cdoperad  /* pr_cdoperad --> Codigo do operador */
                                 ,INPUT par_dsiduser  /* pr_dsiduser --> id do usuario */
                                 ,INPUT par_cdaditiv  /* pr_cdaditiv --> Codigo do aditivo */
                                 ,INPUT par_nraditiv  /* pr_nraditiv --> Numero do aditivo */
                                 ,INPUT par_nrctremp  /* pr_nrctremp --> Numero do contrato */
                                 ,INPUT par_nrdconta  /* pr_nrdconta --> Numero da conta */
                                 ,INPUT par_dtmvtolt  /* pr_dtmvtolt --> Data de movimento */
                                 ,INPUT par_dtmvtopr  /* pr_dtmvtopr --> Data do prox. movimento */
                                 ,INPUT par_inproces  /* pr_inproces --> Indicador de processo */
                                 ,INPUT par_tpctrato  /* pr_tpctrato --> Tipo do Contrato do Aditivo */
                                 
                                 ,OUTPUT  "" /* pr_nmarqpdf --> Retornar quantidad de registros */
                                 ,OUTPUT  0  /* pr_cdcritic --> Código da crítica */
                                 ,OUTPUT  "" /*  pr_dscritic --> Descriçao da crítica */
                                 ).

            CLOSE STORED-PROC pc_gera_impressao_aditiv 
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
            
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = ""
                   aux_nmarqpdf = ""
                   aux_nmarqpdf = pc_gera_impressao_aditiv.pr_nmarqpdf 
                                  WHEN pc_gera_impressao_aditiv.pr_nmarqpdf <> ?
                   aux_cdcritic = pc_gera_impressao_aditiv.pr_cdcritic 
                                  WHEN pc_gera_impressao_aditiv.pr_cdcritic <> ?
                   aux_dscritic = pc_gera_impressao_aditiv.pr_dscritic 
                                  WHEN pc_gera_impressao_aditiv.pr_dscritic <> ?.                    
          END.
        
        ELSE 
        DO: 

        ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                              par_dsiduser.

        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").

        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        RUN Busca_Dados ( INPUT par_cdcooper,
                          INPUT 0,
                          INPUT 0,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT par_dtmvtolt,
                          INPUT par_dtmvtopr,
                          INPUT par_inproces,
                          INPUT "C", /*cddopcao*/
                          INPUT par_nrdconta,
                          INPUT par_nrctremp,
                          INPUT ?,
                          INPUT par_nraditiv,
                          INPUT par_cdaditiv,
                          INPUT 0,
                          INPUT 0,
                          INPUT par_tpctrato,
                          INPUT FALSE,
                          INPUT 0,
                          INPUT 0,
                          INPUT FALSE,
                         OUTPUT aux_qtregstr,
                         OUTPUT TABLE tt-aditiv,
                         OUTPUT TABLE tt-aplicacoes,
                         OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Imprime.

          

        IF   crawepr.dtmvtolt >= 10/22/2014    THEN
             RUN gera_impressao_nova (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_nrdconta,
                                      INPUT par_nrctremp,
                                      INPUT par_cdaditiv,
                                      INPUT par_nraditiv,
                                      INPUT par_cdoperad,
                                      INPUT par_idorigem,
                                      INPUT par_dtmvtolt,
                                      INPUT TABLE tt-aditiv).
        ELSE
             RUN gera_impressao_antiga (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_nrdconta,
                                        INPUT par_nrctremp,
                                        INPUT par_cdaditiv,
                                        INPUT par_nraditiv,
                                        INPUT par_cdoperad,
                                        INPUT par_idorigem,
                                        INPUT par_dtmvtolt,
                                        INPUT TABLE tt-aditiv).

        OUTPUT STREAM str_1 CLOSE.

        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE Imprime.
                    END.

                RUN envia-arquivo-web IN h-b1wgen0024
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT aux_nmarqimp,
                     OUTPUT aux_nmarqpdf,
                     OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0024)  THEN
                    DELETE PROCEDURE h-b1wgen0024.

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
            END.
        END. /* Fim IF crawepr THEN*/      
    END.

    IF  VALID-HANDLE(h-b1wgen9999)  THEN
        DELETE PROCEDURE h-b1wgen9999.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE.


PROCEDURE gera_impressao_nova:

    DEF INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdaditiv AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nraditiv AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT PARAM TABLE FOR tt-aditiv.

    DEF VAR aux_tpdocged AS INTE                                      NO-UNDO.
    DEF VAR aux_totpromi AS DECIMAL  FORMAT "zzzz,zz9.99"             NO-UNDO.
    DEF VAR aux_nraditiv AS INTE                                      NO-UNDO.
    DEF VAR aux_tpchassi AS CHAR     FORMAT "x(15)"                   NO-UNDO.
    DEF VAR aux_dtmvtolt LIKE crapadt.dtmvtolt                        NO-UNDO.
    DEF VAR aux_dscomand AS CHAR                                      NO-UNDO.
    DEF VAR aux_flgescra AS LOGICAL                                   NO-UNDO.
    DEF VAR aux_contador AS INT                                       NO-UNDO.
    DEF VAR aux_nmcidade LIKE crapenc.nmcidade                        NO-UNDO.
    DEF VAR aux_cdufende LIKE crapenc.cdufende                        NO-UNDO.
    DEF VAR aux_qtdaplin AS INT                                       NO-UNDO.
    DEF VAR aux_nrcpfcgc LIKE crapass.nrcpfcgc                        NO-UNDO.
    DEF VAR aux_cpfprop  AS char     FORMAT "x(60)"                   NO-UNDO.

    DEF VAR rel_nrdconta AS INTE                                      NO-UNDO.
    DEF VAR rel_nrctremp AS DECI                                      NO-UNDO.
    DEF VAR rel_nmoperad AS CHAR     FORMAT "x(17)"                   NO-UNDO.
    DEF VAR rel_nrcpfgar AS CHAR     FORMAT "x(18)"                   NO-UNDO.
    DEF VAR rel_nrcpfcgc AS CHAR     FORMAT "x(18)"                   NO-UNDO.
    DEF VAR rel_dscpfavl AS CHAR     FORMAT "x(18)"                   NO-UNDO.
    DEF VAR rel_dsaplica AS CHAR     FORMAT "x(24)"                   NO-UNDO.
    DEF VAR rel_nmcidade AS CHAR     FORMAT "x(70)"                   NO-UNDO.
    DEF VAR rel_nmprimtl AS CHAR     FORMAT "x(30)" EXTENT 2          NO-UNDO.
    DEF VAR rel_nmrescop AS CHAR     FORMAT "x(30)" EXTENT 2          NO-UNDO.
    DEF VAR rel_dsddmvto AS CHAR     FORMAT "x(30)" EXTENT 2          NO-UNDO.
    DEF VAR rel_vlpromis AS CHAR     FORMAT "x(72)" EXTENT 2          NO-UNDO.
    DEF VAR rel_ddmvtolt AS INT      FORMAT "99"                      NO-UNDO.
    DEF VAR rel_aamvtolt AS INT      FORMAT "9999"                    NO-UNDO.
    DEF VAR rel_mmmvtolt AS CHAR     FORMAT "x(17)"  EXTENT 12
                                    INIT["de Janeiro de" ,"de Fevereiro de",
                                         "de Marco de"   ,"de Abril de"    ,
                                         "de Maio de"    ,"de Junho de"    ,
                                         "de Julho de"   ,"de Agosto de"   ,
                                         "de Setembro de","de Outubro de"  ,
                                         "de Novembro de","de Dezembro de"]
                                                                      NO-UNDO.
    DEF VAR rel_nmmesref AS CHAR    FORMAT "x(014)"                   NO-UNDO.


    DEF VAR h-b1wgen9999 AS HANDLE                                    NO-UNDO.
    DEF VAR aux_contpar  AS INTEGER                                   NO-UNDO.
    DEF VAR aux_param    AS CHAR                                      NO-UNDO.
    DEF VAR aux_cdc      AS CHAR                                      NO-UNDO.
    DEF VAR aux_linhacre AS CHAR                                      NO-UNDO.


    /* Inicio */
    FORM "PARA USO DA DIGITALIZACAO"                                    AT 57
         SKIP(1)
         rel_nrdconta                    NO-LABEL FORMAT "zzzz,zzz,9"   AT 57
         rel_nrctremp                    NO-LABEL FORMAT "zz,zzz,zz9"    AT 72
         aux_tpdocged                    NO-LABEL FORMAT "zz9"          AT 84
         SKIP(1)
         "ADITIVO:  "                                                   AT 57
         aux_nraditiv                    NO-LABEL FORMAT "zz9"
         WITH  WIDTH 96 COLUMN 9 FRAME f_uso_digitalizacao.

    FORM SKIP
         "\033\016\033\105   TERMO ADITIVO A CEDULA DE CREDITO BANCARIO/" AT 10
         "CONTRATO DE CREDITO\022\024\033\120\033\106"
         SKIP
         "\033\016\033\105SIMPLIFICADO N. "                               AT 10
         par_nrctremp ", EMITIDA / PACTUADO EM" aux_dtmvtolt
         ",\022\024\033\120\033\106"
         SKIP
         "\033\016\033\105POR"                                            AT 10
         crapass.nmprimtl
         "\022\024\033\120\033\106"
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_inicio_car.

    FORM SKIP
         "TERMO ADITIVO A CEDULA DE CREDITO BANCARIO CONTRATO DE CREDITO" AT 10
         SKIP
         "SIMPLIFICADO N. "                                               AT 10
         par_nrctremp ", EMITIDA / PACTUADO EM " aux_dtmvtolt
         SKIP
         "POR"                                                            AT 10
         crapass.nmprimtl
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_inicio_web.
         
    FORM SKIP
         "\033\016\033\105   TERMO ADITIVO A CEDULA DE CREDITO BANCARIO - " AT 10
         "CREDITO DIRETO\022\024\033\120\033\106"
         SKIP
         "\033\016\033\105AO COOPERADO (CDC) N. "                           AT 10
         par_nrctremp ", EMITIDA EM" aux_dtmvtolt
         ",\022\024\033\120\033\106"
         SKIP
         "\033\016\033\105POR"                                              AT 10
         crapass.nmprimtl
         "\022\024\033\120\033\106"
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_inicio_cdc.
   
    
    FORM SKIP
         "Por este instrumento particular, de um lado"
         "\033\105" rel_nmprimtl[1] FORMAT "x(38)" "," "\033\106"
         SKIP
         "e de outro lado, a\033\105" rel_nmrescop[1] FORMAT "x(64)" ","
         "\033\106"
         SKIP
         "todos  ja  devidamente  qualificados  na  Cedula  de  Credito"
         "Bancario / Contrato  de"
         SKIP
         "Credito  Simplificado  supramencionado(a), tem, entre si,"
         "ajustado o  presente  Termo"
         SKIP
         "Aditivo a Cedula de Credito  Bancario/Contrato de Credito "
         "Simplificado n." par_nraditiv
         SKIP
         "emitida/pactuado em " aux_dtmvtolt " pelo(a) Cooperado(a)"
         "\033\105" rel_nmprimtl[2] FORMAT "x(38)" "," "\033\106"
         SKIP
         "titular da conta n. " par_nrdconta ", nas seguintes clausulas e"
         "condicoes:"
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_inicio_2.
    
    /* CDC */     
    FORM SKIP
         "Por este instrumento particular, de um lado"
         "\033\105" rel_nmprimtl[1] FORMAT "x(38)" "," "\033\106"
         SKIP
         "e de outro lado, a\033\105" rel_nmrescop[1] FORMAT "x(64)" ","
         "\033\106"
         SKIP
         "todos  ja  devidamente  qualificados  na  Cedula de Credito"
         "Bancario / Credito Direto"
         SKIP
         "ao Cooperado  supramencionada, tem, entre si,"
         "ajustado  o  presente  Termo Aditivo  a"
         SKIP
         "Cedula de Credito  Bancario n." par_nraditiv
         SKIP
         "emitida em " aux_dtmvtolt " pelo(a) Cooperado(a)"
         "\033\105" rel_nmprimtl[2] FORMAT "x(38)" "," "\033\106"
         SKIP
         "titular da conta n. " par_nrdconta ", nas seguintes clausulas e"
         "condicoes:"
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_inicio_2_cdc.

    /* tipo 1 */
    FORM SKIP
         "\033\105CLAUSULA PRIMEIRA\033\106 - "
         "Alteracao  da  data  de  pagamento,  prevista  no  item  1.9. da"
         SKIP
         "Cedula  de  Credito  Bancario  ou  item  4.3.  do  Termo  de  Adesao"
         "ao  Contrato  de"
         SKIP
         "Credito  Simplificado,  que  passa  a  vigorar  com  a  seguinte"
         "redacao:  debito  em"
         SKIP
         "conta  corrente  sempre  no dia" rel_ddmvtolt FORMAT "99"
         rel_dsddmvto[1]
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_1_cla_1.

    FORM SKIP
         "\033\105CLAUSULA SEGUNDA\033\106 - "
         "Alteracao da  data  de  vencimento  da  primeira  parcela/debito,"
         SKIP
         "prevista  no  item 1.10.  da  Cedula  de  Credito  Bancario  ou  item"
         "  4.4. do Termo"
         SKIP
         "de Adesao ao Contrato de Credito Simplificado, que passa a ser"
         tt-aditiv.dtdpagto FORMAT "99/99/9999" "."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_1_cla_2.

    FORM SKIP
         "\033\105CLAUSULA TERCEIRA\033\106"
         "-  Em   funcao   da   alteracao   da   data   do   vencimento  fica"
         SKIP
         "automaticamente prorrogado o prazo de vigencia e o numero de"
         "prestacoes estabelecidas"
         SKIP
         "no  item 1.7.  da  Cedula  de Credito Bancario ou item 4.2.  do"
         "Termo  de  Adesao  ao"
         SKIP
         "Contrato de Credito  Simplificado, gerando  saldo  remanescente"
         "a ser  liquidado pelo"
         SKIP
         "Emitente/Cooperado(a) e Devedores Solidarios."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_1_cla_3.

    FORM SKIP
         "\033\105CLAUSULA QUARTA\033\106"
         "- Ficam ratificadas  todas as  demais  condicoes da Cedula de Credito"
         SKIP
         "Bancario/Contrato  de  Credito  Simplificado  ora  aditado (a),  em"
         "tudo  o  que  nao"
         SKIP
         "expressamente modificado no presente termo."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_cla_4.
         
    /*CDC clausula 4 generica */
    FORM SKIP
         "\033\105CLAUSULA QUARTA\033\106"
         "- Ficam ratificadas  todas as  demais  condicoes da Cedula de Credito"
         SKIP
         "Bancario/Contrato  de  Credito  Simplificado  ora  aditado (a),  em"
         "tudo  o  que  nao"
         SKIP
         "expressamente modificado no presente."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_cla_4_cdc.

    /* tipo 2 */
    FORM SKIP
         "\033\105CLAUSULA PRIMEIRA\033\106"
         "- O Emitente/Cooperado(a) compromete-se a manter em aplicacao (oes)"
         SKIP
         "financeiras  perante  esta  Cooperativa de"
         "Credito, valor  que  somado  ao saldo  das"
         SKIP
         "cotas de capital do mesmo,  atinjam no minimo o  equivalente"         
         " ao saldo  da  divida em"
         SKIP
         "dinheiro,   certa,  liquida  e  exigivel  emprestado"
         " na  Cedula de Credito Bancario/"
         SKIP
         "Contrato de Credito Simplificado n. " par_nrctremp
         ", ate a sua total liquidacao." 
         SKIP
         
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_2_cla_1.
    
    /* Tipo 2 CDC clausula 1 */
    FORM SKIP
         "\033\105CLAUSULA PRIMEIRA\033\106"
         "- O Emitente/Cooperado(a) compromete-se a manter em  aplicacao (oes)"
         SKIP
         "financeiras  perante  esta  Cooperativa de"
         "Credito, valor  que  somado  ao  saldo  das"
         SKIP
         "cotas de capital do mesmo,  atinjam no minimo o  equivalente"         
         " ao saldo  da  divida  em"
         SKIP
         "dinheiro,   certa,  liquida  e  exigivel  emprestado"
         " na  Cedula  de  Credito Bancario" 
         SKIP
         "n. " par_nrctremp ", ate a sua total liquidacao." 
         SKIP
         
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_2_cla_1_cdc.

    FORM SKIP
         "\033\105CLAUSULA SEGUNDA\033\106"
         "- A(s) aplicacao(oes) com o(s) numero(s)"
         "\033\105" rel_dsaplica "\033\106,"
         SKIP
         "mantida (s)   pelo  Emitente / Cooperado (a)  junto  a  Cooperativa,"
         "tornar-se-a (ao)"
         SKIP
         "aplicacao(oes)  vinculada(s)  ate  que  se  cumpram  todas as"
         "obrigacoes assumidas na"
         SKIP
         "Cedula de Credito Bancario/Contrato de Credito Simplificado original."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_2_cla_2.
         
    /* CDC tipo 2 clausula 2 */
    
    FORM SKIP
         "\033\105CLAUSULA SEGUNDA\033\106"
         "- A(s) aplicacao(oes) com o(s) numero(s)"
         "\033\105" rel_dsaplica "\033\106,"
         SKIP
         "mantida (s)   pelo  Emitente / Cooperado (a)  junto  a  Cooperativa,"
         "tornar-se-a (ao)"
         SKIP
         "aplicacao(oes)  vinculada(s)  ate  que  se  cumpram  todas as"
         "obrigacoes assumidas na"
         SKIP
         "Cedula de Credito Bancario original."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_2_cla_2_cdc.

    FORM SKIP
         "\033\105CLAUSULA TERCEIRA\033\106"
         "- O  nao  cumprimento  das  obrigacoes assumidas no  presente termo"
         SKIP
         "aditivo e na Cedula de Credito Bancario / Contrato de Credito"
         "Simplificado principal,"
         SKIP
         "bem com o inadimplemento de 02 (duas) prestacoes mensais consecutivas"
         "ou  alternadas,"
         SKIP
         "independentemente  de qualquer  notificacao  judicial ou "
         "extrajudicial, implicara no"
         SKIP
         "vencimento antecipado de todo o saldo devedor do "
         "emprestimo / financiamento servindo"
         SKIP
         "a(s) referida(s) aplicacao(oes)  vinculada(s) para a "
         "imediata  liquidacao  do  saldo"
         SKIP
         "devedor."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_2_cla_3.
         
   /* CDC tipo 2 clausula 3 */
   
   FORM SKIP
         "\033\105CLAUSULA TERCEIRA\033\106"
         "- O  nao  cumprimento  das  obrigacoes assumidas no  presente termo"
         SKIP
         "aditivo e na Cedula de Credito Bancario  principal, bem  com o  inadimplemento de  02"
         SKIP
         "(duas) prestacoes mensais consecutivas  ou alternadas, independentemente  de qualquer"
         SKIP
         "notificacao  judicial ou extrajudicial, implicara  no  vencimento antecipado  de todo"
         SKIP
         "o saldo devedor do  emprestimo/financiamento  servindo a(s) referida(s) aplicacao(oes)"
         SKIP
         "vinculada(s) para a imediata  liquidacao  do  saldo devedor."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_2_cla_3_cdc.

    FORM SKIP
         "\033\105CLAUSULA QUARTA\033\106"
         "- Caso a(s) aplicacao(oes)  venham a ser utilizada(s) para liquidacao"
         SKIP
         "do saldo devedor do emprestimo/financiamento, a(s) mesma(s) poderao"
         "ser movimentada(s)"
         SKIP
         "livremente  pela  Cooperativa, a qualquer tempo, independente de"
         " notificacao judicial "
         SKIP
         "ou  extrajudicial."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_2_cla_4.

    /* CDC tipo 2 clausula 4 */
    
    FORM SKIP
         "\033\105CLAUSULA QUARTA\033\106"
         "- Caso a(s) aplicacao(oes)  venham a ser utilizada(s) para liquidacao"
         SKIP
         "do saldo devedor do emprestimo/financiamento, a(s) mesma(s) poderao"
         "ser movimentada(s)"
         SKIP
         "livremente  pela  Cooperativa, a qualquer tempo, independente de"
         " notificacao judicial "
         SKIP
         "ou  extrajudicial."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_2_cla_4_cdc.
    
    FORM SKIP
         "\033\105CLAUSULA QUINTA\033\106"
         "- A(s) aplicacao(oes) acima enumarada(s),  podera(ao) ser liberada(s)"
         SKIP
         "parcialmente,  e  se  possivel,  a  medida  que  o   saldo  devedor  do "
         " emprestimo/"
         SKIP 
         "financiamento for sendo liquidado."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_2_cla_5.
         
    /* CDC tipo 2 clausula 5 */ 
    
    FORM SKIP
         "\033\105CLAUSULA QUINTA\033\106"
         "- A(s) aplicacao(oes) acima enumarada(s),  podera(ao) ser liberada(s)"
         SKIP
         "parcialmente,  e  se  possivel,  a  medida  que  o   saldo  devedor  do "
         " emprestimo/"
         SKIP 
         "financiamento for sendo liquidado."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_2_cla_5_cdc.

    FORM SKIP
         "\033\105CLAUSULA SEXTA\033\106"
         "- Ficam  ratificadas  todas as  demais  condicoes da Cedula de Credito"
         SKIP
         "Bancario/Contrato  de  Credito  Simplificado  ora  aditado (a),  em"
         "tudo  o  que  nao"
         SKIP
         "expressamente modificado no presente termo."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_2_cla_6.
         
    /*CDC tipo 2 clausula 6 */
    FORM SKIP
         "\033\105CLAUSULA SEXTA\033\106"
         "- Ficam  ratificadas  todas as  demais  condicoes da Cedula de Credito"
         SKIP
         "Bancario  ora  aditada,  em tudo  o  que  nao  expressamente  modificado  no"
         "presente"
         SKIP 
         "termo."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_2_cla_6_cdc.
    

    /* tipo 3 */
    FORM SKIP
         "\033\105CLAUSULA PRIMEIRA\033\106"
         "- Para garantir o cumprimento das obrigacoes assumidas na Cedula de"
         SKIP
         "Credito  Bancario/Contrato  de  Credito Simplificado  ora aditado(a),"
         "comparece  como"
         SKIP
         "Interveniente Garantidor(a)"   rel_nmprimtl[1] FORMAT "x(43)"
         ", inscrito no"
         SKIP
         "CPF/CNPJ sob o n." rel_nrcpfgar
         ", titular da conta corrente"     rel_nrdconta FORMAT "zzzz,zzz,9"
         ", mantida"
         SKIP
         "perante esta Cooperativa."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_3_cla_1.
         
    /* CDC tipo 3 clausula 1 */
    FORM SKIP
         "\033\105CLAUSULA PRIMEIRA\033\106"
         "- Para garantir o cumprimento das obrigacoes assumidas na Cedula de"
         SKIP
         "Credito   Bancario   ora  aditado(a),  comparece   como  Interveniente  Garantidor(a)"   
         SKIP 
         rel_nmprimtl[1] FORMAT "x(43)"
         " ,  inscrito  no  CPF/CNPJ   sob   o   n."
         SKIP
         rel_nrcpfgar
         ", titular da  conta  corrente"     rel_nrdconta FORMAT "zzzz,zzz,9"
         ", mantida  perante  esta"
         SKIP
         "Cooperativa."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_3_cla_1_cdc.
    

    FORM SKIP
         "\033\105CLAUSULA SEGUNDA\033\106"
         "-  O(A) Interveniente  Garantidor(a)  compromete-se  a   manter   em"
         SKIP
         "aplicacao(oes) financeiras perante esta Cooperativa de Credito, valor"
         "que  somado  ao"
         SKIP
         "saldo das cotas de capital do mesmo,  atinjam  no  minimo"
         "o  equivalente ao  saldo da"
         SKIP
         "divida em  dinheiro, certa,  liquida  e  exigivel  emprestado"
         "na  Cedula  de  Credito"
         SKIP
         "Bancario/Contrato de Credito Simplificado, ate a sua total"
         "liquidacao."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_3_cla_2.
         
    /* CDC tipo 3 clausula 2 */
    FORM SKIP
         "\033\105CLAUSULA SEGUNDA\033\106"
         "-  O(A) Interveniente  Garantidor(a)  compromete-se  a   manter   em"
         SKIP
         "aplicacao(oes) financeiras perante esta Cooperativa de Credito, valor"
         "que  somado  ao"
         SKIP
         "saldo das cotas de capital do mesmo,  atinjam  no  minimo"
         "o  equivalente ao  saldo da"
         SKIP
         "divida em  dinheiro, certa,  liquida  e  exigivel  emprestado"
         "na  Cedula  de  Credito"
         SKIP
         "Bancario, ate a sua total"
         "liquidacao."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_3_cla_2_cdc.
    

    FORM SKIP
         "\033\105CLAUSULA TERCEIRA\033\106"
         "- A(s)        aplicacao(oes)        com        o(s)       numero(s)"
         SKIP
         rel_dsaplica FORMAT "x(50)" ", mantida (s)  pelo  Interveniente"
         SKIP
         "Garantidor(a)  junto a  Cooperativa, tornar-se-a(ao) aplicacao(oes)"
         "vinculada(s)  ate"
         SKIP
         "que se cumpram  todas as obrigacoes assumidas na Cedula de Credito"
         " Bancario/Contrato"
         SKIP
         "de Credito Simplificado original."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_3_cla_3.
         
    /*CDC tipo 3 clausula 3*/
    FORM SKIP
         "\033\105CLAUSULA TERCEIRA\033\106"
         "- A(s)        aplicacao(oes)        com        o(s)       numero(s)"
         SKIP
         rel_dsaplica FORMAT "x(50)" ", mantida (s)  pelo  Interveniente"
         SKIP
         "Garantidor(a)  junto a  Cooperativa, tornar-se-a(ao) aplicacao(oes)"
         "vinculada(s)  ate"
         SKIP
         "que se cumpram todas as obrigacoes assumidas na Cedula de Credito"
         " Bancario original."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_3_cla_3_cdc.

    FORM SKIP
         "\033\105CLAUSULA QUARTA\033\106"
         "- O  nao  cumprimento  das  obrigacoes  assumidas  no  presente termo"
         SKIP
         "aditivo e na Cedula de Credito Bancario / Contrato de Credito"
         "Simplificado principal,"
         SKIP
         "bem com o inadimplemento de 02 (duas) prestacoes mensais consecutivas"
         "ou  alternadas,"
         SKIP
         "independentemente  de qualquer  notificacao  judicial ou "
         "extrajudicial, implicara no"
         SKIP
         "vencimento antecipado de todo o saldo devedor do "
         "emprestimo / financiamento servindo"
         SKIP
         "a(s) referida(s) aplicacao(oes)  vinculada(s) para a "
         "imediata  liquidacao  do  saldo"
         SKIP
         "devedor."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_3_cla_4.
         
    /*CDC tipo 3 clausula 4*/
    FORM SKIP
         "\033\105CLAUSULA QUARTA\033\106"
         "- O  nao  cumprimento  das  obrigacoes  assumidas  no  presente termo"
         SKIP
         "aditivo e na Cedula de Credito Bancario principal,  bem  com  o  inadimplemento de 02"
         SKIP
         "(duas) prestacoes mensais consecutivas ou  alternadas,  independentemente de qualquer"
         SKIP
         "notificacao  judicial ou extrajudicial, implicara no vencimento  antecipado de todo o"
         SKIP
         "saldo devedor do emprestimo / financiamento, servindo a(s) referida(s) aplicacao(oes)"
         SKIP
         "vinculada(s) para a imediata  liquidacao do  saldo devedor."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_3_cla_4_cdc.

    FORM SKIP
         "\033\105CLAUSULA QUINTA\033\106"
         "- Caso a(s) aplicacao(oes)  venham a ser utilizada(s) para liquidacao"
         SKIP
         "do saldo devedor do emprestimo/financiamento, a(s) mesma(s) poderao"
         "ser movimentada(s)"
         SKIP
         "livremente  pela  Cooperativa,  a qualquer  tempo, sem  qualquer"
         "notificacao judicial"
         SKIP
         "ou  extrajudicial,  independentemente  de  notificacao judicial"
         "ou extrajudicial."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_3_cla_5.

    /*CDC tipo 3 clausula 5*/
    FORM SKIP
         "\033\105CLAUSULA QUINTA\033\106"
         "- Caso a(s) aplicacao(oes)  venham a ser utilizada(s) para liquidacao"
         SKIP
         "do saldo devedor do emprestimo/financiamento, a(s) mesma(s) poderao"
         "ser movimentada(s)"
         SKIP
         "livremente  pela  Cooperativa,  a qualquer  tempo, independentemente"
         " de  notificacao"
         SKIP
         "judicial ou extrajudicial."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_3_cla_5_cdc.
    
    FORM SKIP
         "\033\105CLAUSULA SEXTA\033\106"
         "- A(s) aplicacao(oes) acima  enumarada(s),  podera(ao) ser liberada(s)"
         SKIP
         "parcialmente, e se possivel a medida que o saldo  devedor do"
         "emprestimo/financiamento"
         SKIP
         "for sendo liquidado."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_3_cla_6.
         
    /*CDC tipo 3 clausula 6*/     
    FORM SKIP
         "\033\105CLAUSULA SEXTA\033\106"
         "- A(s) aplicacao(oes) acima  enumarada(s),  podera(ao) ser liberada(s)"
         SKIP
         "parcialmente, e se possivel a medida que o saldo  devedor do"
         "emprestimo/financiamento"
         SKIP
         "for sendo liquidado."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_3_cla_6_cdc.

    FORM SKIP
         "\033\105CLAUSULA SETIMA\033\106"
         "- Ficam ratificadas  todas as  demais  condicoes da Cedula de Credito"
         SKIP
         "Bancario/Contrato  de  Credito  Simplificado  ora  aditado (a),  em"
         "tudo o que nao"
         SKIP
         "expressamente modificado no presente termo."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_3_cla_7.
         
    /*CDC tipo 3 clausula 7*/
    FORM SKIP
         "\033\105CLAUSULA SETIMA\033\106"
         "- Ficam ratificadas  todas as  demais  condicoes da Cedula de Credito"
         SKIP
         "Bancario ora aditada, em tudo o  que  nao expressamente modificado"
         "no presente termo."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_3_cla_7_cdc.

    /* Tipo 4 */
    FORM SKIP
         "\033\105CLAUSULA PRIMEIRA\033\106"
         "- Para garantir o cumprimento  das obrigacoes assumidas  na  Cedula"
         SKIP
         "de Credito  Bancario/Contrato de  Credito Simplificado ora aditado(a),"
         "comparece como"
         SKIP
         "Devedor  Solidario/Fiador " rel_nmprimtl[1] FORMAT "x(40)"
         ",  inscrito    no"
         SKIP
         "CPF/CNPJ sob n. "  rel_dscpfavl  ", titular da conta conta corrente n. "
          rel_nrdconta
         SKIP
         ", mantida perante esta Cooperativa."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_4_cla_1.

    /*CDC Tipo 4 clausula 1*/
    FORM SKIP
         "\033\105CLAUSULA PRIMEIRA\033\106"
         "- Para garantir o cumprimento  das obrigacoes assumidas  na  Cedula"
         SKIP
         "de  Credito   Bancario   ora   aditada,   comparece   como  Devedor(a)   Solidario(a)"
         SKIP
         rel_nmprimtl[1] FORMAT "x(40)"
         ",     inscrito      no      CPF/CNPJ     sob"
         SKIP
         "n. " rel_dscpfavl  ", titular da conta conta corrente n. "
         rel_nrdconta " ,    mantida"
         SKIP
         "perante esta Cooperativa."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_4_cla_1_cdc.
    
    FORM SKIP
         "\033\105CLAUSULA SEGUNDA\033\106"
         "- O Devedor Solidario/Fiador declara-se solidariamente  responsaveis"
         SKIP
         "com o(a)  Emitente/Cooperado  pela  integral  e  pontual liquidacao de "
         "todas as suas"
         SKIP
         "obrigacoes, principais e acessorias, decorrentes deste ajuste, nos"
         "termos dos artigos"
         SKIP
         "275 e seguintes do Codigo Civil Brasileiro, renunciando expressamente, "
         "os beneficios"
         SKIP 
         "de ordem que trata o artigo 827, em conformidade com o  artigo 282, incisos "
         " I e II,"
         SKIP
         "todos tambem do Codigo Civil Brasileiro."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_4_cla_2.
         
    /*CDC tipo 4 clausula 2*/
    FORM SKIP
         "\033\105CLAUSULA SEGUNDA\033\106"
         "-O(A) Devedor(a) Solidario(a) declara-se solidariamente responsaveis"
         SKIP
         "com o(a)  Emitente/Cooperado  pela  integral  e  pontual liquidacao de "
         "todas as suas"
         SKIP
         "obrigacoes, principais e acessorias, decorrentes deste ajuste, nos"
         "termos dos artigos"
         SKIP
         "275 e seguintes do Codigo Civil Brasileiro, renunciando expressamente, "
         "os beneficios"
         SKIP 
         "de ordem que trata o artigo 827, em conformidade com o  artigo 282, incisos "
         " I e II,"
         SKIP
         "todos tambem do Codigo Civil Brasileiro."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_4_cla_2_cdc.
         
    FORM SKIP
         "\033\105CLAUSULA TERCEIRA\033\106"
         "- O Devedor Solidario, ao assinar  o presente termo aditivo declara"
         SKIP
         "ter  lido previamente  e ter  conhecimento  das  Condicoes Especificas"
         "da  Cedula  de"
         SKIP
         "Credito Bancario/Termo de Adesao ao contrato de Credito Simplificado"
         "original(naria),"
         SKIP
         "cujas disposicoes se aplicam completamente a este instrumento, com as"
         "quais  concorda"
         SKIP
         "incondicionalmente, ratificando-as integralmente neste ato, nao"
         "possuindo duvidas com"
         SKIP
         "relacao a quaisquer de suas clausulas."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_4_cla_3.
         
    /*CDC tipo 4 clausula 3*/
    FORM SKIP
         "\033\105CLAUSULA TERCEIRA\033\106"
         "- O(A) Devedor(a) Solidario(a), ao assinar  o presente termo aditivo declara ter lido"
         SKIP
         "previamente  e  ter  conhecimento  das  Condicoes Especificas da  Cedula  de  Credito"
         SKIP
         "Bancario  original,  cujas  disposicoes  se  aplicam completamente a este instrumento,"
         SKIP
         "com  as  quais  concorda  incondicionalmente, ratificando-as  integralmente neste ato,"
         SKIP
         "nao possuindo duvidas com relacao a quaisquer de suas clausulas."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_4_cla_3_cdc.
    

    FORM SKIP
         "______________________________"
         SKIP
         "Interveniente garantidor"
         WITH NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 6 FRAME f_assinaturas_5.

    /* tipo 5 */
    FORM SKIP
         "\033\105CLAUSULA PRIMEIRA\033\106"
         "- Alteracao/Substituicao do bem deixado em garantia  com  alienacao"
         SKIP
         "fiduciaria na Cedula de Credito Bancario / Contrato de Credito"
         "Simplificado original,"
         SKIP
         "que passa a ser:"
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_5_cla_1.
         
    /*CDC tipo 5 clausula 1*/
    FORM SKIP
         "\033\105CLAUSULA PRIMEIRA\033\106"
         "- Alteracao/Substituicao do bem deixado em garantia  com  alienacao"
         SKIP
         "fiduciaria na Cedula de Credito Bancario original, que passa a ser:"
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_5_cla_1_cdc.
         

    FORM SKIP
         "AUTOMOVEL     :"                                AT 01
         "\033\105" tt-aditiv.dsbemfin                    AT 19 "\033\106"
         SKIP
         "RENAVAN       :"                                AT 01
         "\033\105" tt-aditiv.nrrenava                    AT 19 "\033\106"
         SKIP
         "TIPO CHASSI   :"                                AT 01
         "\033\105" aux_tpchassi                          AT 19 "\033\106"
         SKIP
         "PLACA         :"                                AT 01
         "\033\105" tt-aditiv.nrdplaca                    AT 19 "\033\106"
         SKIP
         "UF PLACA      :"                                AT 01
         "\033\105" tt-aditiv.ufdplaca                    AT 19 "\033\106"
         SKIP
         "COR           :"                                AT 01
         "\033\105" tt-aditiv.dscorbem                    AT 19 "\033\106"
         SKIP
         "ANO           :"                                AT 01
         "\033\105" tt-aditiv.nranobem                    AT 19 "\033\106"
         SKIP
         "MODELO        :"                                AT 01
         "\033\105" tt-aditiv.nrmodbem                    AT 19 "\033\106"
         SKIP
         "UF LICENCI.   :"                                AT 01
         "\033\105" tt-aditiv.uflicenc                    AT 19 "\033\106"
         SKIP
         "NOME DO PROPRIETARIO  :"                        AT 01
         tt-aditiv.nmdavali                               AT 25  
         SKIP
         aux_cpfprop                                      AT 01
         WITH NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_5_cla_1_2.

    FORM SKIP
         "\033\105CLAUSULA SEGUNDA\033\106"
         "- Ficam ratificadas todas as  demais  condicoes da Cedula de Credito"
         SKIP
         "Bancario/Contrato  de  Credito  Simplificado  ora  aditado (a),  em"
         "tudo  o  que  nao"
         SKIP
         "expressamente modificado no presente termo."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_5_cla_2.
    
    /*CDC tipo 5 clausula 2*/
    FORM SKIP
         "\033\105CLAUSULA SEGUNDA\033\106"
         "- Ficam ratificadas todas as  demais  condicoes da Cedula de Credito"
         SKIP
         "Bancario ora  aditado (a),  em tudo  o  que  nao"
         SKIP
         "expressamente modificado no presente termo."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo_5_cla_2.

    FORM SKIP
         "           E por estarem, assim, justos e contratados, assinam"
         "o presente instrumento"
         SKIP
         "em 02 (duas) vias de igual teor e forma, para um so efeito."
         WITH  NO-LABELS WIDTH 96 COLUMN 6 FRAME f_fim_cla.

    FORM SKIP
         rel_nmcidade NO-LABEL
         SKIP(1)
         "______________________________"
         "______________________________"    AT 44
         SKIP
         "Emitente/Cooperado(a)"
         "Cooperativa"                       AT 44
         WITH SIDE-LABELS WIDTH 96 COLUMN 6 FRAME f_assinaturas_1.

    FORM SKIP
         "Devedores Solidarios/Fiadores"
         "Conjuges dos Devedores Solidarios/Fiadores" AT 44
         WITH SIDE-LABELS WIDTH 96 COLUMN 6 FRAME f_assinaturas_2.

    FORM SKIP
         "Testemunhas:"
         "Testemunhas:"                      AT 44
         SKIP(1)
         "1)____________________________"
         "2)____________________________"    AT 44
         WITH SIDE-LABELS WIDTH 96 COLUMN 6 FRAME f_assinaturas_4.

    /* tipo 7  e tipo 8 */
    FORM SKIP
         "\033\016\033\105TERMO DE SUB-ROGACAO\022\024\033\120\033\106" AT 09
         SKIP(1)
         "        Declaramos   para   os   devidos  fins  de   direito,  que "
         " recebemos  de \033\105"
         SKIP
         tt-aditiv.nmdgaran FORMAT "x(48)" "\033\106,"
         "inscrito   no  CPF   sob  o  n. "
         SKIP
         rel_nrcpfgar       FORMAT "x(14)" ", o valor de R$" aux_totpromi "("
         rel_vlpromis[1]    FORMAT "x(37)"
         SKIP
         rel_vlpromis[2]    FORMAT "x(54)"
         "),   relativo  a   quitacao"
         SKIP
         "parcial  (saldo devedor)  da  Cedula   de  Credito Bancario/Contrato "
         " de  Credito"
         SKIP
         "Simplificado     n. " par_nrctremp ",  emitida  em   "
         aux_dtmvtolt "   pelo   Cooperado(a)"
         SKIP
         rel_nmprimtl[1]    FORMAT "x(35)" ", inscrito no CPF sob o n. "
         rel_nrcpfcgc
         SKIP
         "titular da conta" rel_nrdconta FORMAT "zzzz,zzz,9"
          ", na qual aquele constava como Devedor Solidario."
         WITH NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 12 FRAME f_declaramos.

    FORM "         Diante     do     pagamento,     transferimos     por     "
         "   endosso   a \033\105"
         SKIP
         tt-aditiv.nmdgaran FORMAT "x(48)" "\033\106"
         " a(s)   nota(s)   promissoria(s)"
         SKIP
         "descritas abaixo:"
         SKIP
         WITH NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 12 FRAME f_transferimos.

    FORM "Numero " AT 10
         tt-aditiv.nrpromis[aux_contador] FORMAT "x(6)"
         "no valor de R$"
         tt-aditiv.vlpromis[aux_contador] FORMAT "z,zzz,zz9.99"
         SKIP
         WITH DOWN NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 12 FRAME f_numeros.

    FORM "         Dessa forma,  sub-rogamos  e transferimos  expressamente, "
         "nos termos  do"
         SKIP
         "artigo 346 e seguintes combinado com o  artigo 286 e seguintes, "
         "todos  do  Codigo"
         SKIP
         "Civil    Brasileiro    (lei  10.406,    de    10    de   janeiro   de   2002)  "
         " a\033\105"
         SKIP
         tt-aditiv.nmdgaran
         "\033\106, todos os direitos, acoes, privilegios e"
         SKIP
         "garantias  que  possuimos  na  Cedula  de  Credito  Bancario/Contrato"
         " de  Credito"
         SKIP
         "Simplificado antes descrita e  caracterizada, em  relacao  ao valor "
         "especificado,"
         SKIP
         "contra o Emitente/Cooperado(a) \033\105"
         crapass.nmprimtl FORMAT "x(48)" "\033\106."
         WITH  NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 12 FRAME f_dessaforma.

    FORM SKIP(1)
         rel_nmcidade NO-LABEL
         SKIP(1)
         "______________________________"
         SKIP
         crapcop.nmextcop
         WITH NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 12 FRAME f_assinaturas_6.


    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:

        FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                           craptab.nmsistem = "CRED"         AND
                           craptab.tptabela = "GENERI"       AND
                           craptab.cdempres = 00             AND
                           craptab.cdacesso = "DIGITALIZA"   AND
                           craptab.tpregist = 18    /* Aditivo Emprestimo/Financiamento (GED) */
                           NO-LOCK NO-ERROR NO-WAIT.

        IF  AVAIL craptab THEN
            ASSIGN aux_tpdocged = INT(ENTRY(3,craptab.dstextab,";"))
                   aux_nraditiv = par_nraditiv.

        FIND FIRST tt-aditiv NO-ERROR.

        /* Pegar o nome do associado */
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        /* Proposta de emprestimo */
        FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                           crawepr.nrdconta = par_nrdconta   AND
                           crawepr.nrctremp = par_nrctremp
                           NO-LOCK NO-ERROR.

        ASSIGN rel_nmprimtl[1] = crapass.nmprimtl + " " +
                                 FILL("*",38 - LENGTH(crapass.nmprimtl))
               rel_nmrescop[1] = crapcop.nmextcop + " " +
                                 FILL("*",65 - LENGTH(crapcop.nmextcop))
               rel_nmprimtl[2] = rel_nmprimtl[1].

        FOR FIRST crapope FIELDS(cdoperad nmoperad)
                          WHERE crapope.cdcooper = par_cdcooper     AND
                                crapope.cdoperad = par_cdoperad
                                NO-LOCK:
        END.

        IF  NOT AVAILABLE crapope THEN
            ASSIGN rel_nmoperad = "NAO ENCONTRADO!".
        ELSE
            ASSIGN rel_nmoperad = TRIM(crapope.nmoperad).

        IF   crapass.inpessoa = 1 THEN
             ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                           "99999999999")
                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                           "    xxx.xxx.xxx-xx").
        ELSE
             ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                          "99999999999999")
                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                          "xx.xxx.xxx/xxxx-xx").

        IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
            RUN sistema/generico/procedures/b1wgen9999.p
                PERSISTENT SET h-b1wgen9999.

        RUN valor-extenso IN h-b1wgen9999( INPUT DAY(tt-aditiv.dtdpagto),
                                           INPUT 14,
                                           INPUT 0,
                                           INPUT "I",
                                           OUTPUT rel_dsddmvto[1],
                                           OUTPUT rel_dsddmvto[2]).

        DELETE PROCEDURE h-b1wgen9999.

        /* data do emprestimo */
        ASSIGN rel_ddmvtolt    = DAY(aux_dtmvtolt)
               rel_aamvtolt    = YEAR(aux_dtmvtolt)
               rel_dsddmvto[1] = "(" + TRIM(rel_dsddmvto[1]) + ")" +
                                 " de cada mes."
               rel_nrdconta    = par_nrdconta
               rel_nrctremp    = par_nrctremp.

        DISPLAY STREAM str_1 rel_nrdconta
                             rel_nrctremp
                             aux_tpdocged
                             aux_nraditiv
                             WITH FRAME f_uso_digitalizacao.

        /* Verifica se linha credito do aditivo de contrado eh do tipoCDC - Castro */ 
        aux_param = "CDC;CREDITO DIRETO AO COOPERADO;CREDITO DIRETO AO CONSUMIDOR".        
        DO aux_contpar = 1 TO NUM-ENTRIES(TRIM(aux_param),";"):
          aux_linhacre = ENTRY(aux_contpar, aux_param , ";" ).
          FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND 
                             craplcr.cdlcremp = crawepr.cdlcremp NO-LOCK NO-ERROR.
          
          IF craplcr.dslcremp matches aux_linhacre + "*" then
          DO:  
            aux_cdc = "S".
            LEAVE.
          END.
          else
            aux_cdc = "N".  
        END.
        IF   par_cdaditiv < 7   THEN
             DO:
                 IF   par_idorigem = 1   THEN
                 DO:
                  IF aux_cdc = "S" THEN
                    DISPLAY STREAM str_1 par_nrctremp
                                           aux_dtmvtolt
                                           crapass.nmprimtl
                                           WITH FRAME f_inicio_cdc.
                  ELSE 
                      DISPLAY STREAM str_1 par_nrctremp
                                           aux_dtmvtolt
                                           crapass.nmprimtl
                                           WITH FRAME f_inicio_car.
                 END.
                 ELSE
                      DISPLAY STREAM str_1 par_nrctremp
                                           aux_dtmvtolt
                                           crapass.nmprimtl
                                           WITH FRAME f_inicio_web.

                 IF aux_cdc = "S" THEN
                  DISPLAY STREAM str_1 rel_nmprimtl[1] rel_nmrescop[1]
                                        par_nraditiv    aux_dtmvtolt
                                        rel_nmprimtl[2] par_nrdconta
                                        WITH FRAME f_inicio_2_cdc.
                 ELSE 
                   DISPLAY STREAM str_1 rel_nmprimtl[1] rel_nmrescop[1]
                                        par_nraditiv    aux_dtmvtolt
                                        rel_nmprimtl[2] par_nrdconta
                                        WITH FRAME f_inicio_2.

                 ASSIGN rel_ddmvtolt = DAY(tt-aditiv.dtdpagto).

             END.
        ELSE
             DO:
                 ASSIGN  rel_nrcpfgar = STRING(tt-aditiv.nrcpfgar,"99999999999")
                         rel_nrcpfgar = STRING(rel_nrcpfgar,
                                                          "    xxx.xxx.xxx-xx").

                 IF   par_cdaditiv = 7 THEN
                      ASSIGN aux_totpromi = tt-aditiv.vlpromis[1] +
                                            tt-aditiv.vlpromis[2] +
                                            tt-aditiv.vlpromis[3] +
                                            tt-aditiv.vlpromis[4] +
                                            tt-aditiv.vlpromis[5] +
                                            tt-aditiv.vlpromis[6] +
                                            tt-aditiv.vlpromis[7] +
                                            tt-aditiv.vlpromis[8] +
                                            tt-aditiv.vlpromis[9] +
                                            tt-aditiv.vlpromis[10].
                 ELSE
                      ASSIGN aux_totpromi = tt-aditiv.vlpromis[1].

                 IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                     RUN sistema/generico/procedures/b1wgen9999.p
                         PERSISTENT SET h-b1wgen9999.

                 RUN valor-extenso IN h-b1wgen9999 (INPUT aux_totpromi,
                                                    INPUT 37,
                                                    INPUT 54,
                                                    INPUT "M",
                                                    OUTPUT rel_vlpromis[1],
                                                    OUTPUT rel_vlpromis[2]).

                 DELETE PROCEDURE h-b1wgen9999.

                 ASSIGN tt-aditiv.nmdgaran = tt-aditiv.nmdgaran + " " +
                                             FILL("*",
                                                  48 - LENGTH(tt-aditiv.nmdgaran)).

                 DISPLAY STREAM str_1 tt-aditiv.nmdgaran
                                      rel_nrcpfgar
                                      aux_totpromi
                                      rel_vlpromis[1]
                                      rel_vlpromis[2]
                                      par_nrctremp
                                      aux_dtmvtolt
                                      rel_nmprimtl[1]
                                      rel_nrcpfcgc
                                      rel_nrdconta
                                      WITH FRAME f_declaramos.

             END.        
        
        CASE par_cdaditiv:

            WHEN 1 THEN DO:

                DISPLAY STREAM str_1 rel_ddmvtolt
                                     rel_dsddmvto[1]
                                     WITH FRAME f_tipo_1_cla_1.

                DISPLAY STREAM str_1 tt-aditiv.dtdpagto
                                     WITH FRAME f_tipo_1_cla_2.

                DISPLAY STREAM str_1 WITH FRAME f_tipo_1_cla_3.

                DISPLAY STREAM str_1 WITH FRAME f_cla_4.

            END. /* par_cdaditiv = 1 */

            WHEN 2 THEN DO:
                IF aux_cdc = "S" then
                  DISPLAY STREAM str_1 par_nrctremp 
                                       WITH FRAME f_tipo_2_cla_1_cdc.
                else
                  DISPLAY STREAM str_1 par_nrctremp 
                                       WITH FRAME f_tipo_2_cla_1.

                ASSIGN rel_dsaplica = "".

                /* Concatenar as aplicacoes */
                FOR EACH tt-aplicacoes:

                    IF   rel_dsaplica <> ""   THEN
                         ASSIGN rel_dsaplica = rel_dsaplica + ",".

                    ASSIGN rel_dsaplica = rel_dsaplica +
                            TRIM(STRING(tt-aplicacoes.nraplica,"zzz,zz9")).

                END.

                ASSIGN rel_dsaplica = rel_dsaplica + " " +
                                      FILL("*",24 - LENGTH(rel_dsaplica)).

                IF aux_cdc = "S" THEN
                DO:
                  DISPLAY STREAM str_1 rel_dsaplica
                                       WITH FRAME f_tipo_2_cla_2_cdc.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_2_cla_3_cdc.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_2_cla_4_cdc.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_2_cla_5_cdc.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_2_cla_6_cdc.
                END.
                ELSE 
                DO:
                  DISPLAY STREAM str_1 rel_dsaplica
                                       WITH FRAME f_tipo_2_cla_2.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_2_cla_3.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_2_cla_4.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_2_cla_5.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_2_cla_6.
                END.
            END. /* par_cdaditiv = 2 */

            WHEN 3 THEN DO:

                /* dados do interveniente garantidor */
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = tt-aditiv.nrctagar
                                   NO-LOCK NO-ERROR.

                IF  AVAIL crapass THEN
                    DO:
                        ASSIGN rel_nrdconta    = crapass.nrdconta
                               rel_nmprimtl[1] = crapass.nmprimtl + " " +
                                                 FILL("*",
                                                      43 - LENGTH(crapass.nmprimtl)).

                        IF  crapass.inpessoa = 1 THEN
                            ASSIGN  rel_nrcpfgar = STRING(crapass.nrcpfcgc,
                                                                "99999999999")
                                    rel_nrcpfgar = TRIM(STRING(rel_nrcpfgar,
                                                        "    xxx.xxx.xxx-xx")).
                        ELSE
                            ASSIGN  rel_nrcpfgar = STRING(crapass.nrcpfcgc,
                                                             "99999999999999")
                                    rel_nrcpfgar = TRIM(STRING(rel_nrcpfgar,
                                                         "xx.xxx.xxx/xxxx-xx")).
                     END.

                /* para "posicionar" no associado do contrato */
                FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                   crapass.nrdconta = par_nrdconta
                                   NO-LOCK NO-ERROR.

                IF aux_cdc = "S" THEN
                DO:
                  DISPLAY STREAM str_1 rel_nmprimtl[1]
                                       rel_nrcpfgar
                                       rel_nrdconta WITH FRAME f_tipo_3_cla_1_cdc.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_3_cla_2_cdc.
                END.
                ELSE
                DO:
                  DISPLAY STREAM str_1 rel_nmprimtl[1]
                                       rel_nrcpfgar
                                       rel_nrdconta WITH FRAME f_tipo_3_cla_1.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_3_cla_2.
                END.
                ASSIGN rel_dsaplica = "".

                /* Concatenar as aplicacoes */
                FOR EACH tt-aplicacoes:

                    IF   rel_dsaplica <> ""   THEN
                         ASSIGN rel_dsaplica = rel_dsaplica + ",".

                    ASSIGN rel_dsaplica = rel_dsaplica +
                            TRIM(STRING(tt-aplicacoes.nraplica,"zzz,zz9")).

                END.

                ASSIGN rel_dsaplica = rel_dsaplica + " " +
                                      FILL("*",48 - LENGTH(rel_dsaplica)).
                IF aux_cdc = "S" THEN
                DO:
                  DISPLAY STREAM str_1 rel_dsaplica
                                       WITH FRAME f_tipo_3_cla_3_cdc.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_3_cla_4_cdc.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_3_cla_5_cdc.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_3_cla_6_cdc.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_3_cla_7_cdc.
                END.
                ELSE
                DO:
                  DISPLAY STREAM str_1 rel_dsaplica
                                       WITH FRAME f_tipo_3_cla_3.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_3_cla_4.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_3_cla_5.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_3_cla_6.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_3_cla_7.
                END.
            END. /* par_cdaditiv = 3 */

            WHEN 4 THEN DO:

                FIND crapadi WHERE crapadi.cdcooper = par_cdcooper AND
                                   crapadi.nrdconta = par_nrdconta AND
                                   crapadi.nrctremp = par_nrctremp AND
                                   crapadi.nraditiv = par_nraditiv AND
                                   crapadi.nrsequen = 1            AND
                                   crapadi.tpctrato = 90
                                   NO-LOCK NO-ERROR.

                ASSIGN rel_nmprimtl[1] = crapadi.nmdavali + " " +
                                         FILL("*",39 - LENGTH(crapadi.nmdavali))
                       rel_dscpfavl    = STRING(crapadi.nrcpfcgc,"99999999999")
                       rel_dscpfavl    = STRING(rel_dscpfavl,"    xxx.xxx.xxx-xx")
                       rel_nrdconta    = IF   crawepr.nmdaval1 = crapadi.nmdavali   THEN
                                              crawepr.nrctaav1
                                         ELSE
                                         IF   crawepr.nmdaval2 = crapadi.nmdavali    THEN
                                              crawepr.nrctaav2
                                         ELSE
                                              0.
                IF aux_cdc = "S" THEN
                DO:
                  DISPLAY STREAM str_1 rel_nmprimtl[1]
                                       rel_dscpfavl
                                       rel_nrdconta
                                       WITH FRAME f_tipo_4_cla_1_cdc.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_4_cla_2_cdc.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_4_cla_3_cdc.

                  DISPLAY STREAM str_1 WITH FRAME f_cla_4_cdc.
                END.
                ELSE
                DO:
                  DISPLAY STREAM str_1 rel_nmprimtl[1]
                                       rel_dscpfavl
                                       rel_nrdconta
                                       WITH FRAME f_tipo_4_cla_1.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_4_cla_2.

                  DISPLAY STREAM str_1 WITH FRAME f_tipo_4_cla_3.

                  DISPLAY STREAM str_1 WITH FRAME f_cla_4.
                END.

            END. /* par_cdaditiv = 4 */

            WHEN 5 THEN DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                   crapass.nrdconta = par_nrdconta
                                   NO-LOCK NO-ERROR.
                ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc.
                IF aux_cdc = "S" THEN
                  DISPLAY STREAM str_1 WITH FRAME f_tipo_5_cla_1_cdc.
                else
                  DISPLAY STREAM str_1 WITH FRAME f_tipo_5_cla_1.

                IF  tt-aditiv.tpchassi = 1 THEN
                    ASSIGN aux_tpchassi = "1 - Remarcado".
                ELSE
                    ASSIGN aux_tpchassi = "2 - Normal".
                IF tt-aditiv.nrcpfcgc > 0 AND 
                   aux_nrcpfcgc <> tt-aditiv.nrcpfcgc THEN 
                  ASSIGN aux_cpfprop = "CPF/CNPJ PROPRIETARIO : " + STRING(tt-aditiv.nrcpfcgc).
                DISPLAY STREAM str_1 tt-aditiv.dsbemfin 
                                     tt-aditiv.nrdplaca tt-aditiv.dscorbem
                                     tt-aditiv.nranobem tt-aditiv.nrmodbem
                                     tt-aditiv.nrrenava aux_tpchassi
                                     tt-aditiv.ufdplaca tt-aditiv.uflicenc
                                     tt-aditiv.nmdavali aux_cpfprop
                                     WITH FRAME  f_tipo_5_cla_1_2.
                IF aux_cdc = "S" THEN
                  DISPLAY STREAM str_1 WITH FRAME f_tipo_5_cla_2_cdc.
                else
                  DISPLAY STREAM str_1 WITH FRAME f_tipo_5_cla_2.

            END. /* par_cdaditiv = 5 */

            WHEN 7 THEN DO:

                DISPLAY STREAM str_1 tt-aditiv.nmdgaran
                                     WITH FRAME f_transferimos.

                DO aux_contador = 1 TO 10:

                    IF  tt-aditiv.vlpromis[aux_contador] > 0 THEN
                        DO:
                            DISPLAY STREAM str_1
                                           tt-aditiv.nrpromis[aux_contador]
                                           tt-aditiv.vlpromis[aux_contador]
                                           WITH FRAME f_numeros.

                            DOWN WITH FRAME f_numeros.

                        END.

                END. /* Fim DO TO */

            END. /* par_cdaditiv = 7 */

        END CASE.

        IF   par_cdaditiv < 7   THEN
             DO:
                /* Cidade e data atual */
                ASSIGN rel_nmcidade    = crapcop.nmcidade + ", "             +
                                         STRING(DAY(par_dtmvtolt)) + " "     +
                                         rel_mmmvtolt[MONTH(par_dtmvtolt)]   +
                                         " " + STRING(YEAR(par_dtmvtolt))    +
                                         ".".

                DISPLAY STREAM str_1 WITH FRAME f_fim_cla.

                DISPLAY STREAM str_1 rel_nmcidade
                                     WITH FRAME f_assinaturas_1.

                IF   CAN-DO("3",STRING(par_cdaditiv))  THEN
                     DISPLAY STREAM str_1 WITH FRAME f_assinaturas_5.
                ELSE 
                  /* Imprimir assinatura interveniente e mostrar CPF/CNPJ proprietario 
                     se cfp da conta for diferente do proprietario */ 
                  IF par_cdaditiv = 5       AND 
                     tt-aditiv.nrcpfcgc > 0 AND 
                     aux_nrcpfcgc <> tt-aditiv.nrcpfcgc THEN 
                      DISPLAY STREAM str_1 WITH FRAME f_assinaturas_5.
                     

                /* Se tem avalistas, mostrar o titulo das assinaturas */
                IF   crawepr.nmdaval1 <> ""   THEN
                      DISPLAY STREAM str_1 WITH FRAME f_assinaturas_2.

                /* Dados do avalista 1 e conjuge */
                IF   crawepr.nrctaav1 <> 0    OR
                     crawepr.nmdaval1 <> ""   THEN
                     DO:
                         RUN Trata_Assinatura (INPUT par_cdcooper,
                                               INPUT par_nrdconta,
                                               INPUT par_nrctremp,
                                               INPUT crawepr.nrctaav1,
                                               INPUT crawepr.nmdaval1,
                                               INPUT 1,
                                               INPUT par_cdaditiv).

                     END.

                /* Dados do avalista 2 e conjuge */
                IF   crawepr.nrctaav2 <> 0    OR
                     crawepr.nmdaval2 <> ""   THEN
                     DO:
                         RUN Trata_Assinatura (INPUT par_cdcooper,
                                               INPUT par_nrdconta,
                                               INPUT par_nrctremp,
                                               INPUT crawepr.nrctaav2,
                                               INPUT crawepr.nmdaval2,
                                               INPUT 2,
                                               INPUT par_cdaditiv).
                     END.

                DISPLAY STREAM str_1 WITH FRAME f_assinaturas_4.

             END.
        ELSE
             DO:
                 DISPLAY STREAM str_1 tt-aditiv.nmdgaran
                                      crapass.nmprimtl
                                      WITH FRAME f_dessaforma.

                 ASSIGN rel_nmcidade = crapcop.nmcidade + ", "             +
                                       STRING(DAY(par_dtmvtolt)) + " "     +
                                       rel_mmmvtolt[MONTH(par_dtmvtolt)]   +
                                       " " + STRING(YEAR(par_dtmvtolt))    +
                                       ".".

                 DISPLAY STREAM str_1 rel_nmcidade
                                      crapcop.nmextcop
                                      WITH FRAME f_assinaturas_6.
             END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/

    IF  VALID-HANDLE(h-b1wgen9999)  THEN
        DELETE PROCEDURE h-b1wgen9999.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END. /* Gera_Impressao */

PROCEDURE gera_impressao_antiga:

    DEF INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdaditiv AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_nraditiv AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT PARAM TABLE FOR tt-aditiv.

    DEF VAR aux_qtregstr AS INTE                                      NO-UNDO.
    DEF VAR aux_tpdocged AS INTE                                      NO-UNDO.
    DEF VAR aux_totpromi AS DECIMAL  FORMAT "zzz,zzz,zz9.99"          NO-UNDO.
    DEF VAR aux_nraditiv AS INTE                                      NO-UNDO.
    DEF VAR aux_tpchassi AS CHAR     FORMAT "x(15)"                   NO-UNDO.
    DEF VAR rel_nmoperad AS CHAR     FORMAT "x(17)"                   NO-UNDO.
    DEF VAR aux_nmprimtl LIKE crapass.nmprimtl                        NO-UNDO.
    DEF VAR aux_dtmvtolt LIKE crapadt.dtmvtolt                        NO-UNDO.
    DEF VAR aux_qtpalavr AS INT                                       NO-UNDO.
    DEF VAR aux_qtcontpa AS INT                                       NO-UNDO.
    DEF VAR aux_nrcpfavl AS DECI     FORMAT "99999999999999"          NO-UNDO.

    DEF VAR rel_nrdconta AS DECI                                      NO-UNDO.
    DEF VAR rel_nrctremp AS DECI                                      NO-UNDO.
    DEF VAR rel_nmprimtl AS CHAR     FORMAT "x(50)"                   NO-UNDO.    DEF VAR rel_nrcpfgar  AS CHAR    FORMAT "x(18)"                     NO-UNDO.
    DEF VAR rel_nrcpfcgc AS CHAR     FORMAT "x(18)"                   NO-UNDO.
    DEF VAR rel_nmrescop AS CHAR     FORMAT "x(30)" EXTENT 2          NO-UNDO.
    DEF VAR rel_dsddmvto AS CHAR     FORMAT "x(15)" EXTENT 2          NO-UNDO.

    DEF VAR rel_nmdavali AS CHAR     FORMAT "x(40)"                   NO-UNDO.

    DEF VAR rel_dscpfavl AS CHAR     FORMAT "x(18)"                   NO-UNDO.
    DEF VAR rel_vlpromis AS CHAR     FORMAT "x(72)" EXTENT 2          NO-UNDO.
    DEF VAR rel_ddmvtolt AS INT      FORMAT "99"                      NO-UNDO.
    DEF VAR rel_aamvtolt AS INT      FORMAT "9999"                    NO-UNDO.
    DEF VAR rel_mmmvtolt AS CHAR     FORMAT "x(17)"  EXTENT 12
                                 INIT["de  Janeiro  de","de Fevereiro de",
                                     "de   Marco   de","de   Abril   de",
                                     "de   Maio    de","de   Junho   de",
                                     "de   Julho   de","de   Agosto  de",
                                     "de  Setembro de","de  Outubro  de",
                                     "de  Novembro de","de  Dezembro de"]
                                                                      NO-UNDO.

    DEF VAR rel_nmmesref AS CHAR    FORMAT "x(014)"                   NO-UNDO.
    DEF VAR aux_flgescra AS LOGICAL                                   NO-UNDO.
    DEF VAR aux_contador AS INT                                       NO-UNDO.
    DEF VAR aux_nmcidade LIKE crapenc.nmcidade                        NO-UNDO.
    DEF VAR aux_cdufende LIKE crapenc.cdufende                        NO-UNDO.
    DEF VAR aux_qtdaplin AS INT                                       NO-UNDO.
    DEF VAR aux_nrctaavl AS INTE FORMAT "zzzz,zzz,9"                  NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                    NO-UNDO.


    FORM "PARA USO DA DIGITALIZACAO"                                     AT  72
          SKIP(1)
          rel_nrdconta                    NO-LABEL FORMAT "zzzz,zzz,9"   AT  72
          rel_nrctremp                    NO-LABEL FORMAT "zz,zzz,zz9"    AT  86
          aux_tpdocged                    NO-LABEL FORMAT "zz9"          AT  98
          SKIP(1)
          "ADITIVO:  " AT 72 aux_nraditiv NO-LABEL FORMAT "zz9"
          WITH NO-BOX WIDTH 132 COLUMN 9 FRAME f_uso_digitalizacao.

    /* tipo 1 */
    FORM "\022\024\033\120"     /* Reseta impressora */
         SKIP(3)
         "\033\016\033\105ADITIVO CONTRATUAL"  AT 20
         "\022\024\033\120\033\106"     /* Reseta impressora */
         SKIP(3)
         "Pelo presente aditivo contratual, o  contrato  de  Emprestimo/Financiamento"
         SKIP(1)
         "no."
         "\033\105" par_nrctremp           AT  7 "\033\106"
         "." SKIP(1)
         "Firmado por "
         "\033\105" aux_nmprimtl           "\033\106"
         ","
         "C/C:"
         "\033\105" par_nrdconta           "\033\106"
         SKIP(1)
         "e   pela   "
         "\033\105" crapcop.nmextcop
         SKIP(1)
         "\033\106em\033\105"
         rel_ddmvtolt
         rel_mmmvtolt[MONTH(aux_dtmvtolt)]
         rel_aamvtolt "\033\106"
         ","
         " vigorara  com  a  seguinte  redacao:"
         WITH NO-BOX NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo1_parte1.

    FORM "As demais clausulas e condicoes permanecem inalteradas."
         SKIP(4)
         crapcop.nmcidade FORMAT "x(13)"
         ","                               AT 14
         rel_ddmvtolt
         rel_mmmvtolt[MONTH(par_dtmvtolt)]
         rel_aamvtolt
         "."
         SKIP(4)
         "______________________________"
         SKIP
         crapass.nmprimtl
         SKIP(4)
         "______________________________"
         "______________________________"  AT 44
         SKIP
         "Fiador"
         "Fiador"                          AT 44
         SKIP(4)
         "______________________________"
         "______________________________"  AT 44
         SKIP
         "Testemunha"
         "Testemunha"                      AT 44
         SKIP(4)
         "______________________________"
         "______________________________"  AT 44
         SKIP
         par_cdoperad
         "-"
         rel_nmoperad
         rel_nmrescop[1]                   AT 44
         SKIP
         rel_nmrescop[2]                   AT 44
         WITH NO-BOX NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo1_parte2.

    /* tipo 2 */
    FORM "\022\024\033\120"     /* Reseta impressora */
         SKIP(1)
         "\033\016\033\105ADITIVO CONTRATUAL"  AT 20
         "\022\024\033\120"     /* Reseta impressora */
         par_nraditiv AT 63
         SKIP(1)
         "\033\016APLICACAO VINCULADA"  AT 18 "\033\106"
         SKIP(3)
         "O contrato de emprestimo n."
         "\033\105" par_nrctremp            AT 31 "\033\106"
         "firmado em\033\105"                   AT 43
         rel_ddmvtolt
         rel_mmmvtolt[MONTH(aux_dtmvtolt)]
         rel_aamvtolt
         ","                                    AT 81
         SKIP
         "\033\106entre\033\105"
         crapcop.nmextcop
         "\033\106e o(a)"                       AT 74
         SKIP
         "associado(a)\033\105"
         crapass.nmprimtl     FORMAT "x(38)"            /*002*/
         "\033\106,C/C"                         AT 61
         "\033\105" par_nrdconta            AT 70
         "\033\106,"
         SKIP
         "CPF/CNPJ"
         "\033\105" rel_nrcpfgar "\033\106"
         "vigorara   com   as   seguintes    clausulas" AT 36
         SKIP
         "adicionais no item 06 do contrato original:"
         SKIP(1)
         "6.1 - O associado compromete-se a manter em aplicacoes (deposito sob"
         "aviso"                            AT 71
         SKIP
         "ou a prazo fixo) junto a Cooperativa, valor que somado ao saldo  das"
         "cotas"                            AT 71
         SKIP
         "de capital do mesmo, atinjam no minimo o equivalente ao  saldo  do"
         "presente"                             AT 68
         SKIP
         "emprestimo, ate a sua liquidacao total."
         WITH NO-BOX NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo2_parte1.

    FORM SKIP(1)
         "6.3 - O nao cumprimento das obrigacoes assumidas no presente"
         "aditivo  e  do"                      AT 62
         SKIP
         "contrato principal, bem  como  o inadimplento de 2(duas) presta"
         "coes mensais"                              AT 64
         SKIP
         "consecutivas  ou  3(tres)  alternadas  do  emprestimo   objeto "
         "do  presente"                              AT 64
         SKIP
         "contrato, implica  no  vencimento  antecipado  de todo o saldo "
         " devedor  do"                              AT 64
         SKIP
         "emprestimo , servindo  os  referidos  depositos vinculados para"
         " a  imediata"                              AT 64
         SKIP
         "liquidacao do saldo devedor."

         SKIP(1)
         "6.4 - Caso os depositos venham a ser utilizados para a liquidacao do"
         "saldo"                                AT 71
         SKIP
         "devedor do emprestimo, os mesmos poderao ser movimentados"
         "livremente  pela"                     AT 60
         SKIP
         "Cooperativa, a qualquer tempo e sem a  necessidade  de  qualquer"
         "aviso  ou"                            AT 67
         SKIP
         "notificacao de qualquer  das  partes,  independentemente  de  qual  seja"
         "a"                                    AT 75
         SKIP
         "modalidade do deposito, exceto deposito a vista."
         SKIP(1)
         "6.5 - Os depositos acima enumerados, poderao  ser  liberados"
         "parcialmente,"                        AT 63
         SKIP
         "a medida que o saldo devedor do emprestimo for sendo liquidado e desde"
         "que"                                  AT 73
         SKIP
         "se cumpram as demais carencias  e  condicoes  inerentes  aos  depositos"
         "em"                                   AT 74
         SKIP
         "questao."
         SKIP(1)
         "6.6 - As demais clausulas e condicoes avencadas  no  contrato"
         "principal  e"                         AT 64
         SKIP
         "seus aditivos permanecem inalteradas."
         SKIP(1)
         crapcop.nmcidade FORMAT "x(13)"
         ","                                    AT 14
         rel_ddmvtolt
         rel_mmmvtolt[MONTH(par_dtmvtolt)]
         rel_aamvtolt
         "."
         SKIP(2)
         "______________________________"
         SKIP
         crapass.nmprimtl
         SKIP(2)
         "______________________________"
         "______________________________"       AT 46
         SKIP
         "Fiador"
         "Fiador"                               AT 46
         SKIP(2)
         "______________________________"
         "______________________________"       AT 46
         SKIP
         "Testemunha"
         "Testemunha"                           AT 46
         SKIP(1)
         "______________________________"
         "______________________________"       AT 46
         SKIP
         par_cdoperad
         "-"
         rel_nmoperad
         rel_nmrescop[1]                        AT 46
         SKIP
         rel_nmrescop[2]                        AT 46
         WITH NO-BOX NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo2_parte2.

    /* tipo 5 */
    FORM "\022\024\033\120" /* Reseta impressora */
         SKIP(2)
         "\033\016\033\105ADITIVO CONTRATUAL"  AT 20
         "\022\024\033\120"     /* Reseta impressora */
         par_nraditiv AT 63
         SKIP(1)
         "\033\016SUBSTITUICAO DE VEICULO"     AT 15 "\033\106"
         SKIP(3)
         "Pelo presente aditivo contratual que tem por finalidade  a  substituicao"
         "do"                                  AT 74
         SKIP(1)

         "bem dado em garantia no contrato de financiamento com alineacao"
         "fiduciaria"                          AT 66
         SKIP(1)

         "n."
         "\033\105" par_nrctremp           AT  7 "\033\106"
         "firmado por \033\105 "         AT 24
         crapass.nmprimtl
         SKIP(1)

         "\033\106CPF/CNPJ  \033\105"
         rel_nrcpfcgc
         "\033\106conta corrente\033\105"      AT 36
         crapass.nrdconta
         "\033\106e pela\033\105"              AT 68
         SKIP(1)
         crapcop.nmextcop
         SKIP(1)

         "\033\106em\033\105"
         rel_ddmvtolt
         rel_mmmvtolt[MONTH(aux_dtmvtolt)]
         rel_aamvtolt
         "\033\106, vigorara com a seguinte redacao:" AT 34
         SKIP(2)

         "1) Item 04 da Introducao - Bem(ns) Financiado(s)/Garantia:"
         SKIP(1)
         "AUTOMOVEL     :"                              AT 10
         "\033\105" tt-aditiv.dsbemfin                    AT 30 "\033\106"
         SKIP
         "RENAVAN       :"                              AT 10
         "\033\105" tt-aditiv.nrrenava                    AT 30 "\033\106"
         SKIP
         "TIPO CHASSI   :"                              AT 10
         "\033\105" aux_tpchassi                        AT 30 "\033\106"
         SKIP
         "CHASSI        :"                              AT 10
         "\033\105" tt-aditiv.dschassi                    AT 30 "\033\106"
         SKIP
         "PLACA         :"                              AT 10
         "\033\105" tt-aditiv.nrdplaca                    AT 30 "\033\106"
         SKIP
         "UF PLACA      :"                              AT 10
         "\033\105" tt-aditiv.ufdplaca                    AT 30 "\033\106"
         SKIP
         "COR           :"                              AT 10
         "\033\105" tt-aditiv.dscorbem                    AT 30 "\033\106"
         SKIP
         "ANO           :"                              AT 10
         "\033\105" tt-aditiv.nranobem                    AT 30 "\033\106"
         SKIP
         "MODELO        :"                              AT 10
         "\033\105" tt-aditiv.nrmodbem                    AT 30 "\033\106"
         SKIP
         "UF LICENCI.   :"                              AT 10
         "\033\105" tt-aditiv.uflicenc                    AT 30 "\033\106"
         "CPF/CNPJ PROPR:"                              AT 10
         "\033\105" tt-aditiv.nrcpfcgc                    AT 30 "\033\106"
         "\033\105" tt-aditiv.nmdavali  FORMAT "x(35)"    AT 51 "\033\106"
         WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo5_parte1.

    FORM SKIP(2)
         "As demais clausulas e condicoes permanecem inalteradas."
         SKIP(3)
         crapcop.nmcidade FORMAT "x(13)"
         ","                                    AT 14
         rel_ddmvtolt
         rel_mmmvtolt[MONTH(par_dtmvtolt)]
         rel_aamvtolt
         "."
         SKIP(3)
         "______________________________"
         SKIP
         crapass.nmprimtl
         SKIP(3)
         "______________________________"
         "______________________________"       AT 46
         SKIP
         "Testemunha"
         "Testemunha"                           AT 46
         SKIP(3)
         "______________________________"
         "______________________________"       AT 46
         SKIP
         par_cdoperad
         "-"
         rel_nmoperad
         rel_nmrescop[1]                        AT 46
         SKIP
         rel_nmrescop[2]                        AT 46
         WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo5_parte2.

    /* tipo 3 */
    FORM SKIP(1)
         "\022\024\033\120"     /* Reseta impressora */
         "\033\016\033\105ADITIVO CONTRATUAL"  AT 20
         "\022\024\033\120"     /* Reseta impressora */
         par_nraditiv AT 63
         SKIP(1)
         "\033\016APLICACAO VINCULADA TERCEIRO" AT 9 "\033\106"
         SKIP(2)
         "O contrato de emprestimo n."
         "\033\105" par_nrctremp            AT 31 "\033\106"
         "firmado em\033\105"                   AT 43
         rel_ddmvtolt
         rel_mmmvtolt[MONTH(aux_dtmvtolt)]
         rel_aamvtolt
         ","                                    AT 81
         SKIP
         "\033\106entre\033\105"
         crapcop.nmextcop
         "\033\106e o(a)"                       AT 74
         SKIP
         "associado(a)\033\105"
         crapass.nmprimtl     FORMAT "x(38)"    /*002*/
         "\033\106,C/C"                         AT 61
         "\033\105" par_nrdconta            AT 70
         "\033\106,"
         SKIP
         "CPF/CNPJ"
         "\033\105" rel_nrcpfcgc "\033\106"
         "\033\106,tera como interveniente  garantidor  a  Conta"  AT 34
         SKIP
         "Corrente\033\105"
         tt-aditiv.nrctagar                     AT 11
         "\033\106de\033\105"                   AT 23
         rel_nmprimtl                           AT 32
         "\033\106,"                            AT 81
         SKIP
         "CPF/CNPJ\033\105"
         rel_nrcpfgar
         "\033\106, sendo que o contrato original vigorara com as"      AT 31
         SKIP
         "seguintes clausulas adicionais no item 6:"
         SKIP(1)
         "6.1 - O(A) INTERVENIENTE GARANTIDOR(A) compromete-se a manter em"
         "aplicacoes"                           AT 66
         SKIP
         "(depositos sob aviso ou a prazo fixo) junto a Cooperativa, valor que"
         "somado"                               AT 70
         SKIP
         "ao saldo das cotas de capital do mesmo, atinjam no minimo o  equivalente"
         "ao"                                   AT 74
         SKIP
         "saldo devedor do presente emprestimo, ate a sua liquidacao total."
         WITH NO-BOX NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo3_parte1.

    FORM SKIP(1)
         "6.3 - O nao cumprimento das obrigacoes assumidas no presente"
         "aditivo  e  do"                      AT 62
         SKIP

         "contrato principal, bem  como  o inadimplento de 2(duas) presta"
         "coes mensais"                              AT 64
         SKIP
         "consecutivas  ou  3(tres)  alternadas  do  emprestimo   objeto "
         "do  presente"                              AT 64
         SKIP
         "contrato, implica  no  vencimento  antecipado  de todo o saldo "
         " devedor  do"                              AT 64
         SKIP
         "emprestimo , servindo  os  referidos depositos vinculados para "
         " a  imediata"                              AT 64
         SKIP
         "liquidacao do saldo devedor."

         SKIP(1)
         "6.4 - Caso os depositos venham a ser utilizados para a liquidacao do"
         "saldo"                                AT 71
         SKIP
         "devedor do emprestimo, os mesmos poderao ser movimentados"
         "livremente  pela"                     AT 60
         SKIP
         "Cooperativa, a qualquer tempo e sem a  necessidade  de  qualquer"
         "aviso  ou"                            AT 67
         SKIP
         "notificacao de qualquer  das  partes,  independentemente  de  qual  seja"
         "a"                                    AT 75
         SKIP
         "modalidade do deposito, exceto deposito a vista."
         SKIP(1)
         "6.5 - Os depositos acima enumerados, poderao  ser  liberados"
         "parcialmente,"                        AT 63
         SKIP
         "a medida que o saldo devedor do emprestimo for sendo liquidado e desde"
         "que"                                  AT 73
         SKIP
         "se cumpram as demais carencias  e  condicoes  inerentes  aos  depositos"
         "em"                                   AT 74
         SKIP
         "questao."
         SKIP(1)
         "6.6 - As demais clausulas e condicoes avencadas  no  contrato"
         "principal  e"                         AT 64
         SKIP
         "seus aditivos permanecem inalteradas."
         SKIP(1)
         crapcop.nmcidade FORMAT "x(13)"
         ","                                    AT 14
         rel_ddmvtolt
         rel_mmmvtolt[MONTH(par_dtmvtolt)]
         rel_aamvtolt
         "."
         SKIP(2)
         "______________________________"
         SKIP
         crapass.nmprimtl
         SKIP(2)
         "______________________________"
         SKIP
         "Interveniente Garantidor"
         SKIP(2)
         "______________________________"
         "______________________________"       AT 46
         SKIP
         "Fiador"
         "Fiador"                               AT 46
         SKIP(2)
         "______________________________"
         "______________________________"       AT 46
         SKIP
         "Testemunha"
         "Testemunha"                           AT 46
         SKIP(1)
         "______________________________"
         "______________________________"       AT 46
         SKIP
         par_cdoperad
         "-"
         rel_nmoperad
         rel_nmrescop[1]                        AT 46
         SKIP
         rel_nmrescop[2]                        AT 46
         WITH NO-BOX NO-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo3_parte2.

    FORM "\022\024\033\120"     /* Reseta impressora */
         SKIP(1)
         "\033\016\033\105ADITIVO CONTRATUAL"  AT 20
         "\022\024\033\120"     /* Reseta impressora */
         par_nraditiv AT 63
         SKIP(1)
         "\033\016INCLUSAO DE FIADOR/AVALISTA"  AT 10 "\033\106"
         SKIP(4)
         "No contrato de emprestimo n."
         "\033\105" crapepr.nrctremp                 AT 32   "\033\106"
         "firmado em"                                AT 44
         "\033\105" crapepr.dtmvtolt                 AT 59   "\033\106"
         ",tendo como"                               AT 73
         SKIP(1)
         "partes de um lado a:\033\105"
         SKIP(1)
         crapcop.nmextcop
         "\033\106,CNPJ\033\105"
         crapcop.nrdocnpj
         "\033\106"
         SKIP(1)
         "e de outro o(a) Sr(a).:\033\105"
         SKIP(1)
         crapass.nmprimtl
         "\033\106Conta\033\105"
         crapepr.nrdconta
         "      ,"
         SKIP(1)
         "\033\106CPF/CNPJ\033\105"
         rel_nrcpfcgc
         "\033\106 comparece  como  interveniente  garantidor  na"
         SKIP(1)
         "condicao  de fiador/avalista o(a) Sr(a).:\033\105"
         SKIP(1)
         rel_nmdavali "\033\106"
         " ,       CPF\033\105"
         rel_dscpfavl
         "\033\106."
         SKIP(1)
         "Para garantir o cumprimento das obrigacoes assumidas, no referido"
         "contrato"                                  AT 68
         SKIP(1)
         "comparece igualmente o FIADOR nominado, INTERVENIENTE  GARANTIDOR,"
         "o  qual"                                   AT 69
         SKIP(1)
         "expressamente declara que responsabiliza-se solidariamente, como"
         "principal"                                 AT 67
         SKIP(1)
         "pagador, pelo cumprimento de todas as obrigacoes assumidas  pelo"
         "COOPERADO"                                 AT 67
          SKIP(1)
         "no contrato citado, renunciando expressamente, os beneficios de  ordem"
         "que"                                       AT 73
         SKIP(1)
         "trata o art.827, em conformidade com  o  art.828,  incisos  I  e  II,"
         "e  o"                                      AT 72
         SKIP(1)
         "art.838, do Codigo Civil Brasileiro (lei n.10.406, de 10/01/2002)."
         SKIP(1)
         "Como garantia adicional o  interveniente  garantidor  subscreve  tambem"
         "as"                                        AT 74
         SKIP(1)
         "notas promissorias correspondentes  as  obrigacoes  assumidas  no"
         "contrato"                                  AT 68
         SKIP(1)
         "principal de emprestimo pessoal."
         SKIP(3)
         "As demais clausulas e condicoes continuam inalteradas."
         WITH NO-BOX NO-LABELS WIDTH 96 COLUMN 6 FRAME f_termo_avalistas.

     FORM SKIP(4)
         crapcop.nmcidade FORMAT "x(13)"
         crapcop.cdufdcop
         ","
         rel_ddmvtolt
         rel_mmmvtolt[MONTH(par_dtmvtolt)]
         rel_aamvtolt
         "."
         SKIP(3)
         "______________________________"
         SKIP
         crapass.nmprimtl
         SKIP(2)
         "______________________________"
         SKIP
         "Interveniente Garantidor"
         SKIP(2)
         "______________________________"
         "______________________________"  AT 46
         SKIP
         "Fiador"
         "Fiador"                          AT 46
         SKIP(2)
         "______________________________"
         "______________________________"  AT 46
         SKIP
         "Testemunha"
         "Testemunha"                      AT 46
         SKIP(2)
         "______________________________"
         "______________________________"  AT 46
         SKIP
         par_cdoperad
         "-"
         rel_nmoperad
         rel_nmrescop[1]                   AT 46
         SKIP
         rel_nmrescop[2]                   AT 46
         WITH NO-BOX NO-LABELS WIDTH 96 COLUMN 6 FRAME f_assinatura_avalistas.

    /* tipo 6 */
    FORM "\022\024\033\120" /* Reseta impressora */
         SKIP(1)
         "\033\016\033\105ADITIVO CONTRATUAL"  AT 20
         "\022\024\033\120"     /* Reseta impressora */
         par_nraditiv AT 63
         SKIP(1)
         "\033\016INTERVENIENTE GARANTIDOR VEICULO"  AT  6 "\033\106"
         SKIP(2)
         "O presente aditivo contratual ao contrato de  financiamento  com"
         "alienacao"                                 AT 67
         SKIP
         "fiduciaria    n.\033\105"
         par_nrctremp                            AT  21
         "\033\106,     firmado     em\033\105     "
         aux_dtmvtolt   FORMAT "99/99/9999"
         "\033\106     entre\033\105"
         SKIP
         crapcop.nmextcop
         "\033\106  e pelo(a)"
         "associado(a)\033\105"
         SKIP
         crapass.nmprimtl
         "\033\106, portador(a) da  celula"
         SKIP
         "de identidade\033\105  "
         crapass.nrdocptl
         "\033\106   e  do   CPF/CNPJ\033\105   "
         rel_nrcpfcgc
         ","
         SKIP
         crapnac.dsnacion
         ","
         gnetcvl.rsestcvl
         "\033\106, residente  e domiciliado(a)  na  cidade de\033\105"
         SKIP
         aux_nmcidade FORMAT "x(25)"
         aux_cdufende
         "\033\106, associado(a) a cooperativa  pela  matricula\033\105 "
         SKIP
         crapass.nrmatric
         "\033\106 e conta corrente\033\105"
         crapass.nrdconta "\033\106,"
         "comparece   com    o   interveniente"
         SKIP
         "garantidor  no  item   02   da   introducao   do   contrato,   o(a)"
         "Sr(a).\033\105"                            AT 70
         SKIP
         tt-aditiv.nmdgaran         FORMAT "x(40)"
         "\033\106  CPF/CNPJ\033\105   "
         rel_nrcpfgar
         "\033\106,"
         SKIP
         "portador(a) da celula de  identidade\033\105 "
         tt-aditiv.nrdocgar
         "\033\106,  que  vigorara  com  os"
         SKIP
         "seguintes termos:"
         SKIP(1)
         "2.1 - O(A) INTERVENIENTE GARANTIDOR(A) da em garantia a  presente"
         "operacao"                                  AT 68
         SKIP
         "de credito, com alienacao fiduciaria, nos termos do artigo 66 e"
         "paragrafos"                                AT 66
         SKIP
         "da Lei n. 4.728  de  14  de  Julho  de  1965,  regulado  pelo  disposto"
         "no"                                        AT 74
         SKIP
         "Decreto-Lei n. 911, de 01 de Outubro de 1969, e demais  disposicoes"
         "legais"                                    AT 70
         SKIP
         "aplicaveis,  o(s)  bem(ns)  adiante  descrito(s),   de   sua"
         "propriedade,"                              AT 64
         SKIP
         "comprometendo-se  a  mante-los  em  perfeito  estado   de   conservacao"
         "e"                                         AT 75
         SKIP
         "funcionamento, ate a liquidacao total  do  saldo  devedor  ora"
         "contratado:"                               AT 65
         SKIP(1)
         "AUTOMOVEL  :"                              AT 13
         "\033\105" tt-aditiv.dsbemfin                 AT 30 "\033\106"
         SKIP
         "RENAVAN    :"                              AT 13
         "\033\105" tt-aditiv.nrrenava                 AT 30 "\033\106"
         SKIP
         "TIPO CHASSI:"                              AT 13
         "\033\105" aux_tpchassi                     AT 30 "\033\106"
         SKIP
         "CHASSI     :"                              AT 13
         "\033\105" tt-aditiv.dschassi                 AT 30 "\033\106"
         SKIP
         "PLACA      :"                              AT 13
         "\033\105" tt-aditiv.nrdplaca                 AT 30 "\033\106"
         SKIP
         "UF PLACA   :"                              AT 13
         "\033\105" tt-aditiv.ufdplaca                 AT 30 "\033\106"
         SKIP
         "COR        :"                              AT 13
         "\033\105" tt-aditiv.dscorbem                 AT 30 "\033\106"
         SKIP
         "ANO        :"                              AT 13
         "\033\105" tt-aditiv.nranobem                 AT 30 "\033\106"
         SKIP
         "MODELO     :"                              AT 13
         "\033\105" tt-aditiv.nrmodbem                 AT 30 "\033\106"
         SKIP
         "UF LICENCI.:"                              AT 13
         "\033\105" tt-aditiv.uflicenc                 AT 30 "\033\106"
         SKIP(1)
         "2.2 - O nao cumprimento das obrigacoes assumidas no presente"
         "aditivo  e  do"                            AT 62
         SKIP

         "contrato principal, bem  como  o inadimplento de 2(duas) presta"
         "coes mensais"                              AT 64
         SKIP
         "consecutivas  ou  3(tres)  alternadas  do  emprestimo   objeto "
         "do  presente"                              AT 64
         SKIP
         "contrato, implica  no  vencimento  antecipado  de todo o saldo "
         " devedor  do"                              AT 64
         SKIP
         "emprestimo , servindo  os  referidos  bens  como  objeto  para "
         " a  imediata"                              AT 64
         SKIP
         "liquidacao do saldo devedor."
         SKIP(1)
         "2.3 - As partes aqui contratantes ratificam as demais clausulas e"
         "condicoes"                                 AT 67
         SKIP
         "avencadas no contrato principal e seus aditivos."
         SKIP(2)
         WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo6_parte1.

    FORM crapcop.nmcidade FORMAT "x(13)"
         ","                                         AT 14
         rel_ddmvtolt
         rel_mmmvtolt[MONTH(par_dtmvtolt)]
         rel_aamvtolt
         "."
         SKIP(2)
         "______________________________"
         SKIP
         crapass.nmprimtl
         SKIP(2)
         "______________________________"
         SKIP
         "Interveniente Garantidor"
         SKIP(1)
         "______________________________"
         "______________________________"            AT 46
         SKIP
         "Testemunha"
         "Testemunha"                                AT 46
         SKIP(1)
         "______________________________"
         "______________________________"            AT 46
         SKIP
         par_cdoperad
         "-"
         rel_nmoperad
         rel_nmrescop[1]                             AT 46
         SKIP
         rel_nmrescop[2]                             AT 46
         WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 6 FRAME f_tipo6_parte2.

        /* tipo 7 */
    FORM "\0332\022\024\033\120" /* Reseta impressora */
         SKIP(6)
         "\033\016\033\105TERMO DE SUB-ROGACAO"  AT 8
         "\022\024\033\120"     /* Reseta impressora */
         "\033\106"
         par_nraditiv AT 45
         SKIP(3)
         "Declaramos para os devidos fins de direito, que recebemos"
         SKIP
         "do(a) Sr(a).\033\105"
         tt-aditiv.nmdgaran
         "\033\106  ,"
         SKIP
         "portador(a)  do  CPF\033\105 "
         rel_nrcpfgar
         " \033\106,  o  valor  de\033\105"
         SKIP
         "R$"
         aux_totpromi
         "("
         rel_vlpromis[1] FORMAT "x(37)"
         SKIP
         rel_vlpromis[2] FORMAT "x(54)"
         ")\033\106,"
         SKIP
         "relativo ao pagamento parcial (saldo devedor) do contrato"
         SKIP
         "de emprestimo n.\033\105"
         par_nrctremp
         ",\033\106firmado em\033\105"
         rel_ddmvtolt
         rel_mmmvtolt[MONTH(aux_dtmvtolt)]
         SKIP
         rel_aamvtolt
         "\033\106entre\033\105"
         crapcop.nmextcop                   FORMAT "x(45)"
         SKIP
         "\033\106CNPJ\033\105"
         crapcop.nrdocnpj
         "\033\106, e\033\105"
         SKIP
         crapass.nmprimtl                 FORMAT "x(39)"  /*003*/
         "\033\106,conta\033\105"
         crapass.nrdconta
         SKIP
         "\033\106(devedor     principal),     portador(a)      do      CPF\033\105"
         SKIP
         WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 12 FRAME f_tipo7_parte1.

    FORM "Dessa forma,\033\105 sub-rogamos e transferimos"
         "expressamente\033\106,nos"
         SKIP
         "termos do artigo 346 e seguintes, combinado com o  artigo"
         SKIP
         "286 e seguintes, todos do Codigo Civil (Lei 10.406, de 10"
         SKIP
         "de janeiro de 2002) ao(a) Sr(a).\033\105"
         SKIP
         tt-aditiv.nmdgaran
         "\033\106,  anteriormente"
         SKIP
         "qualificado(a), todos os direitos,  acoes  privilegios  e"
         SKIP
         "garantias que possuimos  no  contrato  antes  descrito  e"
         SKIP
         "caracterizado, em relacao ao valor  especificado,  contra"
         SKIP
         "o(a) devedor(a) principal,\033\105"
         SKIP
         crapass.nmprimtl
         "\033\106."
         SKIP(3)
         WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 12 FRAME f_tipo7_parte4.

    FORM crapcop.nmcidade FORMAT "x(13)"
         ","                                         AT 14
         rel_ddmvtolt
         rel_mmmvtolt[MONTH(par_dtmvtolt)]
         rel_aamvtolt
         "."
         SKIP(4)
         "______________________________"
         SKIP
         rel_nmrescop[1]
         SKIP
         rel_nmrescop[2]
         WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 12 FRAME f_tipo7_parte5.


    /* tipo 8 */
    FORM "\0332\022\024\033\120" /* Reseta impressora */
         SKIP(6)
         "\033\016\033\105TERMO DE SUB-ROGACAO"  AT 8
         "\022\024\033\120"     /* Reseta impressora */
         "\033\106"
         par_nraditiv AT 45
         SKIP(3)
         "Declaramos para os devidos fins de direito, que recebemos"
         SKIP
         "do(a) Sr(a).\033\105"
         tt-aditiv.nmdgaran
         "\033\106  ,"
         SKIP
         "portador(a)  do  CPF\033\105 "
         rel_nrcpfgar
         " \033\106,  o  valor  de\033\105"
         SKIP
         "R$"
         tt-aditiv.vlpromis[1]
         "("
         rel_vlpromis[1] FORMAT "x(37)"
         SKIP
         rel_vlpromis[2] FORMAT "x(54)"
         ")\033\106,"
         SKIP
         "relativo ao pagamento parcial (saldo devedor) do contrato"
         SKIP
         "de emprestimo n.\033\105"
         par_nrctremp
         ",\033\106firmado em\033\105"
         rel_ddmvtolt
         rel_mmmvtolt[MONTH(aux_dtmvtolt)]
         SKIP
         rel_aamvtolt
         "\033\106entre\033\105"
         crapcop.nmextcop                   FORMAT "x(45)"
         SKIP
         "\033\106CNPJ\033\105"
         crapcop.nrdocnpj
         "\033\106, e\033\105"
         SKIP
         crapass.nmprimtl                 FORMAT "x(39)"    /*003*/
         "\033\106,conta\033\105"
         crapass.nrdconta
         SKIP
         "\033\106(devedor     principal),     portador(a)      do      CPF\033\105"
         SKIP
         WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 12 FRAME f_tipo8_parte1.

    FORM rel_nrcpfcgc
         "\033\106valor esse relativo a quitacao parcial"
         SKIP
         "do referido contrato,no qual constava como fiador(a) o(a)"
         SKIP
         "mesmo(a) Sr(a).\033\105"
         tt-aditiv.nmdgaran               FORMAT "x(39)"
         "\033\106,"
         SKIP
         "antes qualificado(a)."
         SKIP(1)
         "Dessa forma,\033\105 sub-rogamos e transferimos"
         "expressamente\033\106,nos"
         SKIP
         "termos do artigo 346 e seguintes, combinado com o  artigo"
         SKIP
         "286 e seguintes, todos do Codigo Civil (Lei 10.406, de 10"
         SKIP
         "de janeiro de 2002) ao(a) Sr(a).\033\105"
         SKIP
         WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 12 FRAME f_tipo8_parte2.

    FORM tt-aditiv.nmdgaran
         "\033\106,  anteriormente"
         SKIP
         "qualificado(a), todos os direitos,  acoes  privilegios  e"
         SKIP
         "garantias que possuimos  no  contrato  antes  descrito  e"
         SKIP
         "caracterizado, em relacao ao valor  especificado,  contra"
         SKIP
         "o(a) devedor(a) principal,\033\105"
         SKIP
         crapass.nmprimtl
         "\033\106."
         SKIP(3)
         WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 12 FRAME f_tipo8_parte3.

    FORM crapcop.nmcidade FORMAT "x(13)"
         ","                                         AT 14
         rel_ddmvtolt
         rel_mmmvtolt[MONTH(par_dtmvtolt)]
         rel_aamvtolt
         "."
         SKIP(4)
         "______________________________"
         SKIP
         rel_nmrescop[1]
         SKIP
         rel_nmrescop[2]
         WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 96 COLUMN 12 FRAME f_tipo8_parte4.





    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:

        FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                           craptab.nmsistem = "CRED"         AND
                           craptab.tptabela = "GENERI"       AND
                           craptab.cdempres = 00             AND
                           craptab.cdacesso = "DIGITALIZA"   AND
                           craptab.tpregist = 18    /* Aditivo Emprestimo/Financiamento (GED) */
                           NO-LOCK NO-ERROR NO-WAIT.

        IF  AVAIL craptab THEN
            ASSIGN aux_tpdocged = INT(ENTRY(3,craptab.dstextab,";"))
                   aux_nraditiv = par_nraditiv.

        FIND FIRST tt-aditiv NO-ERROR.

         /* para pegar a data do contrato */
        FIND crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                           crapepr.nrdconta = par_nrdconta AND
                           crapepr.nrctremp = par_nrctremp NO-LOCK NO-ERROR.

        IF  AVAIL crapepr THEN
            ASSIGN aux_dtmvtolt = crapepr.dtmvtolt.

        /* pegar o nome do associado */
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  AVAILABLE crapass THEN
            ASSIGN aux_nmprimtl = crapass.nmprimtl.

        /*   Divide o crapcop.nmextcop em duas variaveis  */
        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(crapcop.nmextcop)," ") / 2
               rel_nmrescop = "".

        FOR FIRST crapope FIELDS(cdoperad nmoperad)
                          WHERE crapope.cdcooper = par_cdcooper     AND
                                crapope.cdoperad = par_cdoperad
                                NO-LOCK:
        END.

        IF  NOT AVAILABLE crapope THEN
            ASSIGN rel_nmoperad = "NAO ENCONTRADO!".
        ELSE
            ASSIGN rel_nmoperad = TRIM(crapope.nmoperad).

        DO aux_qtcontpa = 1 TO NUM-ENTRIES(TRIM(crapcop.nmextcop)," "):

            IF  aux_qtcontpa <= aux_qtpalavr THEN
                ASSIGN rel_nmrescop[1] = rel_nmrescop[1] +
                                                (IF TRIM(rel_nmrescop[1]) = ""
                                                           THEN "" ELSE " ") +
                                                ENTRY(aux_qtcontpa,
                                                        crapcop.nmextcop," ").
            ELSE
                ASSIGN rel_nmrescop[2] = rel_nmrescop[2] +
                                                (IF TRIM(rel_nmrescop[2]) = ""
                                                           THEN "" ELSE " ") +
                                     ENTRY(aux_qtcontpa,crapcop.nmextcop," ").
        END.  /*  Fim DO .. TO  */

        ASSIGN rel_nmrescop[1] = FILL(" ",20 - INT(LENGTH(rel_nmrescop[1]) / 2))
                                                        + rel_nmrescop[1]
               rel_nmrescop[2] = FILL(" ",20 - INT(LENGTH(rel_nmrescop[2]) / 2))
                                                        + rel_nmrescop[2]
               rel_nmrescop[1] = TRIM(rel_nmrescop[1]," ")
               rel_nmrescop[2] = TRIM(rel_nmrescop[2]," ").

        CASE par_cdaditiv:

            WHEN 1 THEN DO:

                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta
                                   NO-LOCK NO-ERROR.

                IF  AVAIL crapass THEN
                    DO:
                        IF  crapass.inpessoa = 1 THEN
                            ASSIGN  rel_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                                                "99999999999")
                                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                                        "    xxx.xxx.xxx-xx").
                        ELSE
                            ASSIGN  rel_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                                             "99999999999999")
                                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                                        "xx.xxx.xxx/xxxx-xx").
                    END.

                IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                    RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.

                IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                    DO:
                        ASSIGN aux_dscritic =
                                         "Handle invalido para BO b1wgen9999.".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        RETURN "NOK".
                    END.

                RUN valor-extenso IN h-b1wgen9999( INPUT DAY(tt-aditiv.dtdpagto),
                                                   INPUT 14,
                                                   INPUT 0,
                                                   INPUT "I",
                                                   OUTPUT rel_dsddmvto[1],
                                                   OUTPUT rel_dsddmvto[2]).

                DELETE PROCEDURE h-b1wgen9999.

                /* data do emprestimo */
                ASSIGN rel_ddmvtolt = DAY(aux_dtmvtolt)
                       rel_aamvtolt = YEAR(aux_dtmvtolt)
                       rel_dsddmvto[1] = TRIM(rel_dsddmvto[1]) + ")"
                       rel_nrdconta = par_nrdconta
                       rel_nrctremp = par_nrctremp.

                DISPLAY STREAM str_1
                        rel_nrdconta
                        rel_nrctremp
                        aux_tpdocged
                        aux_nraditiv
                        WITH FRAME f_uso_digitalizacao.

                DISPLAY STREAM str_1
                    par_nrctremp  aux_nmprimtl
                    par_nrdconta  crapcop.nmextcop  rel_ddmvtolt
                    rel_mmmvtolt[MONTH(aux_dtmvtolt)]
                    rel_aamvtolt WITH FRAME f_tipo1_parte1.

                PUT STREAM str_1 SKIP(3)
                    "     1) Item   5.3   da   Folha   de    Rosto    -    "
                    "\033\105FORMA    DE    PAGAMENTO :" SKIP(1)
                    "     DEBITO  EM  "  tt-aditiv.flgpagto
                    " SEMPRE NO DIA "
                    DAY(tt-aditiv.dtdpagto) FORMAT "99"   " ("
                    rel_dsddmvto[1]
                    " DE  CADA  MES." SKIP(1)
                    "     INICIANDO A PARTIR DE "
                    tt-aditiv.dtdpagto  ".\033\106"
                    SKIP(3).

                PUT STREAM str_1
                    "     2) Em  funcao  da  alteracao  da  data  do  debito,"
                    "  fica   automaticamente" SKIP(1)
                    "     prorrogado o prazo de vigencia e o numero de"
                    "  prestacoes  estabelecidos  no" SKIP(1)
                    "     item 5 da Folha de Rosto do referido contrato,"
                    " gerando  saldo  remanescente" SKIP(1)
                    "     a ser liquidado pelo cooperado."
                    SKIP(4).

                /* data atual */
                ASSIGN rel_ddmvtolt = DAY(par_dtmvtolt)
                       rel_aamvtolt = YEAR(par_dtmvtolt).

                DISPLAY STREAM str_1
                    crapcop.nmcidade   rel_ddmvtolt     rel_aamvtolt
                    rel_mmmvtolt[MONTH(par_dtmvtolt)]
                    rel_nmrescop[1]    rel_nmrescop[2]
                    par_cdoperad       rel_nmoperad
                    crapass.nmprimtl
                    WITH FRAME f_tipo1_parte2.

            END. /* par_cdaditiv = 1 */

            WHEN 2 THEN DO:

                FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                                   NO-LOCK NO-ERROR.

                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta
                                   NO-LOCK NO-ERROR.

                IF  AVAIL crapass THEN
                    DO:
                        IF  crapass.inpessoa = 1 THEN
                            ASSIGN  rel_nrcpfgar = STRING(crapass.nrcpfcgc,
                                                                 "99999999999")
                                    rel_nrcpfgar = STRING(rel_nrcpfgar,
                                                         "    xxx.xxx.xxx-xx").
                        ELSE
                            ASSIGN  rel_nrcpfgar = STRING(crapass.nrcpfcgc,
                                                              "99999999999999")
                                    rel_nrcpfgar = STRING(rel_nrcpfgar,
                                                         "xx.xxx.xxx/xxxx-xx").
                    END.

                /* data do emprestimo */
                ASSIGN rel_ddmvtolt = DAY(aux_dtmvtolt)
                       rel_aamvtolt = YEAR(aux_dtmvtolt)
                       rel_nrdconta = par_nrdconta
                       rel_nrctremp = par_nrctremp.

                DISPLAY STREAM str_1
                        rel_nrdconta
                        rel_nrctremp
                        aux_tpdocged
                        aux_nraditiv
                        WITH FRAME f_uso_digitalizacao.

                DISPLAY STREAM str_1
                         par_nraditiv crapcop.nmextcop  crapass.nmprimtl
                         par_nrdconta rel_nrcpfgar      par_nrctremp
                         rel_ddmvtolt     rel_mmmvtolt[MONTH(aux_dtmvtolt)]
                         rel_aamvtolt     WITH FRAME f_tipo2_parte1.

                PUT STREAM str_1 SKIP(2)
                    "     6.2 - Os depositos remunerados,  a  prazo"
                    "  fixo  ou  sob  aviso,  com  o(s)" SKIP
                    "     numero(s):".

                /* impressao das aplicacoes */
                PUT STREAM str_1 "\033\105" SKIP.

                ASSIGN aux_qtdaplin = 0.

                FOR EACH tt-aplicacoes:

                    ASSIGN aux_qtdaplin = aux_qtdaplin + 1.

                    IF  aux_qtdaplin = 1 THEN
                        PUT STREAM str_1 tt-aplicacoes.nraplica AT 20.
                    IF  aux_qtdaplin = 2 THEN
                        PUT STREAM str_1 tt-aplicacoes.nraplica AT 35.
                    IF  aux_qtdaplin = 3 THEN
                        PUT STREAM str_1 tt-aplicacoes.nraplica AT 50.
                    IF  aux_qtdaplin = 4 THEN
                        DO:
                            PUT STREAM str_1 tt-aplicacoes.nraplica AT 65 SKIP.
                            ASSIGN aux_qtdaplin = 0.
                        END.

                END.

                PUT STREAM str_1 "\033\106".

                PUT STREAM str_1 SKIP(1)
                    "     mantidos pelo associado junto  a  Cooperativa,  "
                    "exceto  deposito  a  vista,"
                    SKIP
                    "     tornar-se-ao  depositos  vinculados  ate  que  se  "
                    "cumpram  as   obrigacoes"
                    SKIP
                    "     assumidas no presente contrato.".

                /* data atual */
                ASSIGN rel_ddmvtolt = DAY(par_dtmvtolt)
                       rel_aamvtolt = YEAR(par_dtmvtolt).

                DISPLAY STREAM str_1
                    crapcop.nmcidade  rel_ddmvtolt      rel_aamvtolt
                    rel_nmrescop[1]   rel_nmrescop[2]
                    rel_mmmvtolt[MONTH(par_dtmvtolt)]
                    par_cdoperad      rel_nmoperad crapass.nmprimtl
                    WITH FRAME f_tipo2_parte2.

            END. /* par_cdaditiv = 2 */

            WHEN 3 THEN DO:

                /* data do emprestimo */
                ASSIGN rel_ddmvtolt = DAY(aux_dtmvtolt)
                       rel_aamvtolt = YEAR(aux_dtmvtolt).

                /* dados do interveniente garantidor */
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = tt-aditiv.nrctagar
                                   NO-LOCK NO-ERROR.

                IF  AVAIL crapass THEN
                    DO:
                        ASSIGN  rel_nmprimtl = crapass.nmprimtl.

                        IF  crapass.inpessoa = 1 THEN
                            ASSIGN  rel_nrcpfgar = STRING(crapass.nrcpfcgc,
                                                                "99999999999")
                                    rel_nrcpfgar = STRING(rel_nrcpfgar,
                                                        "    xxx.xxx.xxx-xx").
                        ELSE
                            ASSIGN  rel_nrcpfgar = STRING(crapass.nrcpfcgc,
                                                             "99999999999999")
                                    rel_nrcpfgar = STRING(rel_nrcpfgar,
                                                         "xx.xxx.xxx/xxxx-xx").
                     END.

                /* para "posicionar" no associado do contrato */
                FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                   crapass.nrdconta = par_nrdconta
                                   NO-LOCK NO-ERROR.

                IF  AVAILABLE crapass   THEN
                    DO:
                        IF  crapass.inpessoa = 1 THEN
                            ASSIGN  rel_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                                                "99999999999")
                                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                                        "    xxx.xxx.xxx-xx").
                        ELSE
                            ASSIGN  rel_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                                             "99999999999999")
                                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                                        "xx.xxx.xxx/xxxx-xx").
                    END.

                ASSIGN rel_nrdconta = par_nrdconta
                       rel_nrctremp = par_nrctremp.

                DISPLAY STREAM str_1
                        rel_nrdconta
                        rel_nrctremp
                        aux_tpdocged
                        aux_nraditiv
                        WITH FRAME f_uso_digitalizacao.

                DISPLAY STREAM str_1
                    par_nraditiv     par_nrctremp     rel_ddmvtolt
                    rel_mmmvtolt[MONTH(aux_dtmvtolt)]     rel_aamvtolt
                    crapcop.nmextcop     crapass.nmprimtl     par_nrdconta
                    rel_nrcpfcgc     tt-aditiv.nrctagar     rel_nmprimtl
                    rel_nrcpfgar
                    WITH FRAME f_tipo3_parte1.

                PUT STREAM str_1 SKIP(2)
                    "     6.2 - Os depositos remunerados,  a  prazo"
                    "  fixo  ou  sob  aviso,  com  o(s)" SKIP
                    "     numero(s):".

                /* impressao das aplicacoes */
                PUT STREAM str_1 "\033\105" SKIP.

                ASSIGN aux_qtdaplin = 0.

                FOR EACH tt-aplicacoes:

                    ASSIGN aux_qtdaplin = aux_qtdaplin + 1.

                    IF  aux_qtdaplin = 1 THEN
                        PUT STREAM str_1 tt-aplicacoes.nraplica AT 20.
                    IF  aux_qtdaplin = 2 THEN
                        PUT STREAM str_1 tt-aplicacoes.nraplica AT 35.
                    IF  aux_qtdaplin = 3 THEN
                        PUT STREAM str_1 tt-aplicacoes.nraplica AT 50.
                    IF  aux_qtdaplin = 4 THEN
                        DO:
                            PUT STREAM str_1 tt-aplicacoes.nraplica AT 65 SKIP.
                            ASSIGN aux_qtdaplin = 0.
                        END.

                END.

                PUT STREAM str_1 "\033\106".

                PUT STREAM str_1 SKIP(1)
                    "     mantidos pelo(a) INTERVENIENTE GARANTIDOR(A) junto"
                    " a   Cooperativa, "
                    " exceto"
                    SKIP
                    "     deposito a vista, tornar-se-ao depositos vinculados"
                    "ate que  se  cumpram  as"
                    SKIP
                    "     obrigacoes assumidas no presente contrato.".

                /* data do atual */
                ASSIGN rel_ddmvtolt = DAY(par_dtmvtolt)
                       rel_aamvtolt = YEAR(par_dtmvtolt).

                DISPLAY STREAM str_1
                    crapcop.nmcidade rel_ddmvtolt
                    rel_aamvtolt rel_nmrescop[1]
                    rel_nmrescop[2] rel_mmmvtolt[MONTH(par_dtmvtolt)]
                    par_cdoperad  rel_nmoperad crapass.nmprimtl
                    WITH FRAME f_tipo3_parte2.

            END. /* par_cdaditiv = 3 */

            WHEN 4  THEN DO:

                FIND crapadi WHERE crapadi.cdcooper = par_cdcooper AND
                                   crapadi.nrdconta = par_nrdconta AND
                                   crapadi.nrctremp = par_nrctremp AND
                                   crapadi.nraditiv = par_nraditiv AND
                                   crapadi.nrsequen = 1            AND
                                   crapadi.tpctrato = 90
                                   NO-LOCK NO-ERROR.

                ASSIGN aux_nrcpfavl = crapadi.nrcpfcgc
                       rel_nmdavali = crapadi.nmdavali
                       aux_nrctaavl = 0.  /* nao sera usada a conta do avalista */

                ASSIGN rel_dscpfavl = STRING(aux_nrcpfavl,"99999999999")
                       rel_dscpfavl = STRING(rel_dscpfavl,"    xxx.xxx.xxx-xx").

                FIND crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                                   crapepr.nrdconta = par_nrdconta AND
                                   crapepr.nrctremp = par_nrctremp NO-LOCK NO-ERROR.

                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

                ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                       rel_nrcpfcgc = STRING(rel_nrcpfcgc,"    xxx.xxx.xxx-xx").

                /*   Divide o crapcop.nmextcop em duas variaveis  */
                ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(crapcop.nmextcop)," ") / 2
                       rel_nmrescop = "".

                DO aux_qtcontpa = 1 TO NUM-ENTRIES(TRIM(crapcop.nmextcop)," "):
                    IF  aux_qtcontpa <= aux_qtpalavr THEN
                        ASSIGN rel_nmrescop[1] = rel_nmrescop[1] +
                                                (IF TRIM(rel_nmrescop[1]) = "" THEN ""
                                                 ELSE " ") +
                                                 ENTRY(aux_qtcontpa,crapcop.nmextcop
                                                                                ," ").
                    ELSE
                        ASSIGN rel_nmrescop[2] = rel_nmrescop[2] +
                                                 (IF TRIM(rel_nmrescop[2]) = "" THEN ""
                                                  ELSE " ") +
                                                  ENTRY(aux_qtcontpa,crapcop.nmextcop
                                                                                 ," ").
                END.  /*  Fim DO .. TO  */

                ASSIGN rel_nmrescop[1] = FILL(" ",20 - INT(LENGTH(rel_nmrescop[1]) / 2))
                                             + rel_nmrescop[1]
                       rel_nmrescop[2] = FILL(" ",20 - INT(LENGTH(rel_nmrescop[2]) / 2))
                                             + rel_nmrescop[2]
                       rel_nmrescop[1] = TRIM(rel_nmrescop[1]," ")
                       rel_nmrescop[2] = TRIM(rel_nmrescop[2]," ")
                       rel_ddmvtolt = DAY(par_dtmvtolt)
                       rel_aamvtolt = YEAR(par_dtmvtolt).

                 ASSIGN rel_nrdconta = crapepr.nrdconta
                        rel_nrctremp = crapepr.nrctremp.

                 DISPLAY STREAM str_1
                         rel_nrdconta
                         rel_nrctremp
                         aux_tpdocged
                         WITH FRAME f_uso_digitalizacao.

                DISPLAY STREAM str_1
                        crapepr.nrctremp crapepr.dtmvtolt crapcop.nmextcop
                        crapcop.nrdocnpj crapass.nmprimtl crapepr.nrdconta
                        rel_nrcpfcgc     rel_nmdavali     rel_dscpfavl
                        par_nraditiv
                        WITH FRAME f_termo_avalistas.

                DISPLAY STREAM str_1
                    crapcop.nmcidade   crapcop.cdufdcop    rel_ddmvtolt
                    rel_aamvtolt       rel_mmmvtolt[MONTH(par_dtmvtolt)]
                    crapass.nmprimtl   rel_nmrescop[1]     rel_nmrescop[2]
                    par_cdoperad       rel_nmoperad
                    WITH FRAME f_assinatura_avalistas.

            END.

            WHEN 5 THEN DO:

                FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                                   NO-LOCK NO-ERROR.

                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta
                                   NO-LOCK NO-ERROR.

                IF  AVAIL crapass THEN
                    DO:
                        IF  crapass.inpessoa = 1 THEN
                            ASSIGN  rel_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                                                "99999999999")
                                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                                        "    xxx.xxx.xxx-xx").
                        ELSE
                            ASSIGN  rel_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                                             "99999999999999")
                                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                                         "xx.xxx.xxx/xxxx-xx").
                    END.

                /* data do emprestimo */
                ASSIGN rel_ddmvtolt = DAY(aux_dtmvtolt)
                       rel_aamvtolt = YEAR(aux_dtmvtolt).

                /* colocar a descricao do tipo do chassis */
                IF  tt-aditiv.tpchassi = 1 THEN
                    ASSIGN aux_tpchassi = "1 - Remarcado".
                ELSE
                    ASSIGN aux_tpchassi = "2 - Normal".

                ASSIGN rel_nrdconta = crapass.nrdconta
                       rel_nrctremp = par_nrctremp.

                DISPLAY STREAM str_1
                        rel_nrdconta
                        rel_nrctremp
                        aux_tpdocged
                        aux_nraditiv
                        WITH FRAME f_uso_digitalizacao.

                DISPLAY STREAM str_1
                    par_nraditiv       par_nrctremp       rel_ddmvtolt
                    rel_mmmvtolt[MONTH(aux_dtmvtolt)]     rel_aamvtolt
                    crapcop.nmextcop   crapass.nmprimtl   rel_nrcpfcgc
                    crapass.nrdconta   tt-aditiv.dsbemfin tt-aditiv.dschassi
                    tt-aditiv.nrdplaca tt-aditiv.dscorbem tt-aditiv.nranobem
                    tt-aditiv.nrmodbem tt-aditiv.nrrenava aux_tpchassi
                    tt-aditiv.ufdplaca tt-aditiv.uflicenc
                    tt-aditiv.nrcpfcgc tt-aditiv.nmdavali
                    WITH FRAME f_tipo5_parte1.

                /* data atual */
                ASSIGN rel_ddmvtolt = DAY(par_dtmvtolt)
                       rel_aamvtolt = YEAR(par_dtmvtolt).

                DISPLAY STREAM str_1
                    crapcop.nmcidade    rel_ddmvtolt
                    rel_mmmvtolt[MONTH(par_dtmvtolt)] rel_aamvtolt
                    rel_nmrescop[1]     rel_nmrescop[2]
                    par_cdoperad        rel_nmoperad
                    crapass.nmprimtl
                    WITH FRAME f_tipo5_parte2.

            END. /* par_cdaditiv = 5 */

            WHEN 6 THEN DO:

                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta
                                   NO-LOCK NO-ERROR.

                IF  AVAIL crapass THEN
                    DO:
                        IF  crapass.inpessoa = 1 THEN
                            ASSIGN  rel_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                                                "99999999999")
                                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                                        "    xxx.xxx.xxx-xx").
                        ELSE
                            ASSIGN  rel_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                                            "99999999999999")
                                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                                        "xx.xxx.xxx/xxxx-xx").
                    END.

                /* CPF do interveniente garantidor */
                ASSIGN rel_nrcpfgar = TRIM(STRING(tt-aditiv.nrcpfgar)).

                IF  LENGTH(rel_nrcpfgaR) <= 11 THEN
                    ASSIGN rel_nrcpfgar = STRING(tt-aditiv.nrcpfgar,"99999999999")
                           rel_nrcpfgar = STRING(rel_nrcpfgar,
                                                         "    xxx.xxx.xxx-xx").
                ELSE
                    ASSIGN rel_nrcpfgar = STRING(tt-aditiv.nrcpfgar,
                                                            "99999999999999")
                           rel_nrcpfgar = STRING(rel_nrcpfgar,
                                                         "xx.xxx.xxx/xxxx-xx").

                /* data atual */
                ASSIGN rel_ddmvtolt = DAY(par_dtmvtolt)
                       rel_aamvtolt = YEAR(par_dtmvtolt).

                /* colocar a descricao do tipo do chassis */
                IF  tt-aditiv.tpchassi = 1 THEN
                    ASSIGN aux_tpchassi = "1 - Remarcado".
                ELSE
                    ASSIGN aux_tpchassi = "2 - Normal".

                FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                                         crapenc.nrdconta = par_nrdconta
                                         NO-LOCK NO-ERROR.

                ASSIGN  aux_nmcidade = crapenc.nmcidade
                        aux_cdufende = crapenc.cdufende.


                FIND FIRST crapttl WHERE crapttl.cdcooper = crapass.cdcooper
                                     AND crapttl.nrdconta = crapass.nrdconta
                                     AND crapttl.idseqttl = 1
                                   NO-LOCK.

                IF AVAIL crapttl THEN
                    FIND gnetcvl WHERE gnetcvl.cdestcvl = crapttl.cdestcvl NO-LOCK.

                /* Buscar nacionalidade */
                FIND FIRST crapnac
                     WHERE crapnac.cdnacion = crapass.cdnacion
                     NO-LOCK NO-ERROR.
                
                ASSIGN rel_nrdconta = par_nrdconta
                       rel_nrctremp = par_nrctremp.

                DISPLAY STREAM str_1
                        rel_nrdconta
                        rel_nrctremp
                        aux_tpdocged
                        aux_nraditiv
                        WITH FRAME f_uso_digitalizacao.

                DISPLAY STREAM str_1
                    par_nraditiv  par_nrctremp  aux_dtmvtolt
                    crapcop.nmextcop  crapass.nmprimtl  crapass.nrdocptl
                    rel_nrcpfcgc      
                    crapnac.dsnacion WHEN AVAIL crapnac
                    gnetcvl.rsestcvl WHEN AVAIL gnetcvl
                    aux_nmcidade aux_cdufende crapass.nrmatric
                    crapass.nrdconta   tt-aditiv.nmdgaran rel_nrcpfgar
                    tt-aditiv.nrdocgar tt-aditiv.dsbemfin tt-aditiv.nrrenava
                    aux_tpchassi       tt-aditiv.dschassi tt-aditiv.nrdplaca
                    tt-aditiv.ufdplaca tt-aditiv.dscorbem tt-aditiv.nranobem
                    tt-aditiv.nrmodbem tt-aditiv.uflicenc
                    WITH FRAME f_tipo6_parte1.

                DISPLAY STREAM str_1
                    crapcop.nmcidade
                    rel_ddmvtolt      rel_mmmvtolt[MONTH(par_dtmvtolt)]
                    rel_aamvtolt      rel_nmrescop[1]   rel_nmrescop[2]
                    par_cdoperad      rel_nmoperad      crapass.nmprimtl
                    WITH FRAME f_tipo6_parte2.

            END. /* par_cdaditiv = 6 */

            WHEN 7 THEN DO:

                FIND crapass WHERE crapass.cdcooper = par_cdcooper      AND
                                   crapass.nrdconta = par_nrdconta
                                   NO-LOCK NO-ERROR.

                IF  AVAIL crapass THEN
                    DO:
                        IF  crapass.inpessoa = 1 THEN
                            ASSIGN  rel_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                                                 "99999999999")
                                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                                         "    xxx.xxx.xxx-xx").
                        ELSE
                            ASSIGN  rel_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                                              "99999999999999")
                                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                                         "xx.xxx.xxx/xxxx-xx").
                    END.

                /* CPF do interveniente garantidor */
                ASSIGN  rel_nrcpfgar = STRING(tt-aditiv.nrcpfgar,"99999999999")
                        rel_nrcpfgar = STRING(rel_nrcpfgar,
                                                         "    xxx.xxx.xxx-xx").

                /* data do emprestimo */
                ASSIGN rel_ddmvtolt = DAY(aux_dtmvtolt)
                       rel_aamvtolt = YEAR(aux_dtmvtolt)
                       aux_totpromi = tt-aditiv.vlpromis[1] +
                                      tt-aditiv.vlpromis[2] +
                                      tt-aditiv.vlpromis[3] +
                                      tt-aditiv.vlpromis[4] +
                                      tt-aditiv.vlpromis[5] +
                                      tt-aditiv.vlpromis[6] +
                                      tt-aditiv.vlpromis[7] +
                                      tt-aditiv.vlpromis[8] +
                                      tt-aditiv.vlpromis[9] +
                                      tt-aditiv.vlpromis[10].

                IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                    RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.

                IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                    DO:
                        ASSIGN aux_dscritic =
                                         "Handle invalido para BO b1wgen9999.".
                        LEAVE Imprime.
                    END.

                RUN valor-extenso IN h-b1wgen9999 (INPUT aux_totpromi,
                                                   INPUT 37,
                                                   INPUT 54,
                                                   INPUT "M",
                                                   OUTPUT rel_vlpromis[1],
                                                   OUTPUT rel_vlpromis[2]).

                DELETE PROCEDURE h-b1wgen9999.

                DISPLAY STREAM str_1
                    par_nraditiv tt-aditiv.nmdgaran     rel_nrcpfgar
                    aux_totpromi rel_vlpromis[1]      rel_vlpromis[2]
                    par_nrctremp     crapcop.nmextcop     crapcop.nrdocnpj
                    crapass.nmprimtl     crapass.nrdconta
                    rel_ddmvtolt         rel_mmmvtolt[MONTH(aux_dtmvtolt)]
                    rel_aamvtolt WITH FRAME f_tipo7_parte1.

                /* data atual */
                ASSIGN rel_ddmvtolt = DAY(par_dtmvtolt)
                       rel_aamvtolt = YEAR(par_dtmvtolt).

                /*- parte das notas promissorias -*/
                PUT STREAM str_1
                    rel_nrcpfcgc                                AT 12
                    ",\033\106  e   transferimos   por   endosso   a\033\105"
                    SKIP
                    tt-aditiv.nmdgaran                          AT 12
                    "\033\106   a(s)   nota(s)"
                    SKIP
                    "promissoria(s):"                           AT 12
                    SKIP.

                DO aux_contador = 1 TO 10:

                    IF  tt-aditiv.vlpromis[aux_contador] > 0 THEN
                        DO:
                            PUT STREAM str_1
                                "\033\106numero\033\105 "  AT 12
                                tt-aditiv.nrpromis[aux_contador]
                                "\033\106 no valor de R$\033\105 "
                                tt-aditiv.vlpromis[aux_contador]
                                SKIP.
                        END.
                END. /* Fim DO TO */

                PUT STREAM str_1
                    SKIP
                   "\033\106valor  esse  relativo  a  quitacao  parcial" AT 12
                    " do   referido"
                    SKIP
                    "contrato, no qual constava como  fiador(a)  o(a)"  AT 12
                    " mesmo(a)"
                    SKIP
                    "Sr(a).\033\105  "                                  AT 12
                    tt-aditiv.nmdgaran
                    " \033\106,  antes"
                    SKIP
                    "qualificado(a)."                                   AT 12
                    SKIP(1).

                DISPLAY STREAM str_1
                        tt-aditiv.nmdgaran     crapass.nmprimtl
                        WITH FRAME f_tipo7_parte4.

                DISPLAY STREAM str_1
                        crapcop.nmcidade
                        rel_ddmvtolt     rel_mmmvtolt[MONTH(par_dtmvtolt)]
                        rel_aamvtolt     rel_nmrescop[1]      rel_nmrescop[2]
                        WITH FRAME f_tipo7_parte5.

            END. /* par_cdaditiv = 7 */

            WHEN 8 THEN DO:

                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta
                                   NO-LOCK NO-ERROR.

                IF  AVAIL crapass THEN
                    DO:
                        IF  crapass.inpessoa = 1 THEN
                            ASSIGN  rel_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                                                 "99999999999")
                                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                                         "    xxx.xxx.xxx-xx").
                        ELSE
                            ASSIGN  rel_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                                              "99999999999999")
                                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                                         "xx.xxx.xxx/xxxx-xx").
                    END.

                /* CPF do interveniente garantidor */
                ASSIGN  rel_nrcpfgar = STRING(tt-aditiv.nrcpfgar,"99999999999")
                        rel_nrcpfgar = STRING(rel_nrcpfgar,
                                                         "    xxx.xxx.xxx-xx").

                /* data do emprestimo */
                ASSIGN rel_ddmvtolt = DAY(aux_dtmvtolt)
                       rel_aamvtolt = YEAR(aux_dtmvtolt).

                IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                    RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.

                IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                    DO:
                        ASSIGN aux_dscritic =
                                         "Handle invalido para BO b1wgen9999.".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        RETURN "NOK".
                    END.

                RUN valor-extenso IN h-b1wgen9999 (INPUT tt-aditiv.vlpromis[1],
                                                   INPUT 37,
                                                   INPUT 54,
                                                   INPUT "M",
                                                   OUTPUT rel_vlpromis[1],
                                                   OUTPUT rel_vlpromis[2]).

                DELETE PROCEDURE h-b1wgen9999.

                DISPLAY STREAM str_1
                    par_nraditiv     tt-aditiv.nmdgaran     rel_nrcpfgar
                    tt-aditiv.vlpromis[1]  rel_vlpromis[1]  rel_vlpromis[2]
                    par_nrctremp     crapcop.nmextcop     crapcop.nrdocnpj
                    crapass.nmprimtl     crapass.nrdconta
                    rel_ddmvtolt         rel_mmmvtolt[MONTH(aux_dtmvtolt)]
                    rel_aamvtolt WITH FRAME f_tipo8_parte1.

                /* data atual */
                ASSIGN rel_ddmvtolt = DAY(par_dtmvtolt)
                       rel_aamvtolt = YEAR(par_dtmvtolt).

                DISPLAY STREAM str_1
                        tt-aditiv.nmdgaran rel_nrcpfcgc
                        WITH FRAME f_tipo8_parte2.

                DISPLAY STREAM str_1
                        tt-aditiv.nmdgaran crapass.nmprimtl
                        WITH FRAME f_tipo8_parte3.

                DISPLAY STREAM str_1
                    crapcop.nmcidade
                    rel_ddmvtolt     rel_mmmvtolt[MONTH(par_dtmvtolt)]
                    rel_aamvtolt     rel_nmrescop[1]      rel_nmrescop[2]
                    WITH FRAME f_tipo8_parte4.

            END. /* par_cdaditiv = 8 */

        END CASE.

    END.

    IF  VALID-HANDLE(h-b1wgen9999)  THEN
        DELETE PROCEDURE h-b1wgen9999.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Trata_Assinatura:

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrctaava AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nmdavali AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_iddoaval AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdaditiv AS INTE                               NO-UNDO.

    DEF VAR rel_linhatra AS CHAR FORMAT "x(25)"                        NO-UNDO.
    DEF VAR rel_nmdevsol AS CHAR FORMAT "x(35)"                        NO-UNDO.
    DEF VAR rel_dscpfcgc AS CHAR FORMAT "x(90)"                        NO-UNDO.
    DEF VAR rel_dsendere AS CHAR FORMAT "x(90)"                        NO-UNDO.
    DEF VAR rel_dstelefo AS CHAR FORMAT "x(90)"                        NO-UNDO.


    /* Dados do avalista */
    RUN Trata_Dados_Assinatura (INPUT par_cdcooper,
                                INPUT par_nrdconta,
                                INPUT par_nrctremp,
                                INPUT par_nrctaava,
                                INPUT par_nrctaava,
                                INPUT par_nmdavali,
                                INPUT par_iddoaval,
                                INPUT 1,
                                INPUT-OUTPUT rel_linhatra,
                                INPUT-OUTPUT rel_nmdevsol,
                                INPUT-OUTPUT rel_dscpfcgc,
                                INPUT-OUTPUT rel_dsendere,
                                INPUT-OUTPUT rel_dstelefo).

    /* Achar conjuge do avalista */
    FIND crapcje WHERE crapcje.cdcooper = par_cdcooper   AND
                       crapcje.nrdconta = par_nrctaava   AND
                       crapcje.idseqttl = 1
                       NO-LOCK NO-ERROR.

    ASSIGN rel_linhatra = rel_linhatra +
                          FILL(" ",43 - LENGTH(rel_linhatra))
           rel_nmdevsol = SUBSTR(rel_nmdevsol +
                          FILL(" ",43 - LENGTH(rel_nmdevsol)),1,42) + " "
           rel_dscpfcgc = rel_dscpfcgc +
                          FILL(" ",43 - LENGTH(rel_dscpfcgc))
           rel_dsendere = SUBSTR(rel_dsendere +
                          FILL(" ",43 - LENGTH(rel_dsendere)),1,42) + " "
           rel_dstelefo = rel_dstelefo +
                          FILL(" ",43 - LENGTH(rel_dstelefo)).

    IF   AVAIL crapcje   THEN
         DO:
              /* Dados do conjuge */
              RUN Trata_Dados_Assinatura (INPUT par_cdcooper,
                                          INPUT par_nrdconta,
                                          INPUT par_nrctremp,
                                          INPUT crapcje.nrctacje,
                                          INPUT par_nrctaava,
                                          INPUT "",
                                          INPUT par_iddoaval,
                                          INPUT 2,
                                          INPUT-OUTPUT rel_linhatra,
                                          INPUT-OUTPUT rel_nmdevsol,
                                          INPUT-OUTPUT rel_dscpfcgc,
                                          INPUT-OUTPUT rel_dsendere,
                                          INPUT-OUTPUT rel_dstelefo).

         END.

    PUT STREAM str_1 SKIP(2)
                     rel_linhatra FORMAT "x(90)" AT 06
                     rel_nmdevsol FORMAT "x(90)" AT 06.

    IF   par_cdaditiv = 4   THEN
         PUT STREAM str_1 rel_dscpfcgc FORMAT "x(90)" AT 06
                          rel_dsendere FORMAT "x(90)" AT 06
                          rel_dstelefo FORMAT "x(90)" AT 06.

    RETURN "OK".

END PROCEDURE.


PROCEDURE Trata_Dados_Assinatura:

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrctacon AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrctaava AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nmdavali AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_iddoaval AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_tpdconsu AS INTE                               NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_linhatra AS CHAR FORMAT "x(25)"         NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_nmdevsol AS CHAR FORMAT "x(35)"         NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_dscpfcgc AS CHAR FORMAT "x(90)"         NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_dsendere AS CHAR FORMAT "x(90)"         NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_dstelefo AS CHAR FORMAT "x(90)"         NO-UNDO.

    DEF VAR rel_nmdevsol         AS CHAR                               NO-UNDO.
    DEF VAR rel_dscpfcgc         AS CHAR                               NO-UNDO.
    DEF VAR rel_dsendere         AS CHAR                               NO-UNDO.
    DEF VAR rel_dstelefo         AS CHAR                               NO-UNDO.
    DEF VAR rel_inpessoa         AS INTE                               NO-UNDO.

    IF   par_nrctacon <> 0  THEN /* Dados do cooperado*/
         DO:
             /* Achar o registro de cooperado do avalista */
             FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                crapass.nrdconta = par_nrctacon
                                NO-LOCK NO-ERROR.

             IF   NOT AVAIL crapass   THEN
                  RETURN "NOK".

             /* Achar endereco do avalista */
             FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper     AND
                                      crapenc.nrdconta = par_nrctacon     AND
                                      crapenc.idseqttl = 1
                                      NO-LOCK NO-ERROR.

             IF   NOT AVAIL crapenc   THEN
                  RETURN "NOK".

             /* Telefone do avalista */
             FIND FIRST craptfc WHERE craptfc.cdcooper = par_cdcooper   AND
                                      craptfc.nrdconta = par_nrctacon   AND
                                      craptfc.idseqttl = 1
                                      NO-LOCK NO-ERROR.

             IF   NOT AVAIL craptfc   THEN
                  RETURN "NOK".

             ASSIGN rel_inpessoa = crapass.inpessoa
                    rel_nmdevsol = crapass.nmprimtl
                    rel_dscpfcgc = STRING(crapass.nrcpfcgc)
                    rel_dsendere = crapenc.dsendere + " "   +
                                   STRING(crapenc.nrendere) + ", " +
                                   crapenc.nmcidade
                    rel_dstelefo = "(" + STRING(craptfc.nrdddtfc) + ") " +
                                   STRING(craptfc.nrtelefo).

         END.
    ELSE      /* Avalista terceiro ou Conjuge terceiro */
         DO:
             IF   par_tpdconsu = 1   THEN /* Avalista */
                  DO:
                      FIND crapavt WHERE crapavt.cdcooper = par_cdcooper   AND
                                         crapavt.tpctrato = 1              AND
                                         crapavt.nrdconta = par_nrdconta   AND
                                         crapavt.nrctremp = par_nrctremp   AND
                                         crapavt.nmdavali = par_nmdavali
                                         NO-LOCK NO-ERROR.

                      IF   AVAIL crapavt   THEN
                           ASSIGN rel_inpessoa = crapavt.inpessoa
                                  rel_nmdevsol = crapavt.nmdavali
                                  rel_dscpfcgc = STRING(crapavt.nrcpfcgc)
                                  rel_dsendere = crapavt.dsendres[1] + " "   +
                                                 STRING(crapavt.nrendere)
                                                 + ", " +
                                                 crapavt.nmcidade
                                  rel_dstelefo = STRING(crapavt.nrfonres).

                  END.
             ELSE                         /* Conjuge do Avalista */
                  DO:
                     FIND crapcje WHERE crapcje.cdcooper = par_cdcooper   AND
                                        crapcje.nrdconta = par_nrctaava   AND
                                        crapcje.idseqttl = 1
                                        NO-LOCK NO-ERROR.

                     IF   AVAIL crapcje   THEN
                           ASSIGN rel_inpessoa = 1
                                  rel_nmdevsol = crapcje.nmconjug
                                  rel_dscpfcgc = STRING(crapcje.nrcpfcjg)
                                  rel_dsendere = crapcje.dsendcom
                                  rel_dstelefo = STRING(crapcje.nrfonemp).

                     IF   rel_dsendere = ""   THEN
                          DO:
                              /* Achar endereco do avalista */
                              FIND FIRST crapenc WHERE
                                         crapenc.cdcooper = par_cdcooper     AND
                                         crapenc.nrdconta = par_nrctaava     AND
                                         crapenc.idseqttl = 1
                                         NO-LOCK NO-ERROR.

                              IF   AVAIL crapenc   THEN
                                   rel_dsendere = crapenc.dsendere + " "   +
                                                  STRING(crapenc.nrendere) + ", " +
                                                  crapenc.nmcidade.
                          END.

                     IF   rel_dstelefo = ""   THEN
                          DO:
                              /* Telefone do avalista */
                              FIND FIRST craptfc WHERE
                                         craptfc.cdcooper = par_cdcooper   AND
                                         craptfc.nrdconta = par_nrctaava   AND
                                         craptfc.idseqttl = 1
                                         NO-LOCK NO-ERROR.

                              IF   AVAIL craptfc THEN
                                   rel_dstelefo = "(" + STRING(craptfc.nrdddtfc) + ") " +
                                                  STRING(craptfc.nrtelefo).
                           END.

                  END.
         END.

    /* Assinatura, nome, Endereco , telefone e CPF */
    ASSIGN par_linhatra = par_linhatra + STRING(par_iddoaval) + ")" +
                          FILL("_",28)
           par_nmdevsol = par_nmdevsol + "Nome: "     + rel_nmdevsol
           par_dsendere = par_dsendere + "Endereco: " + rel_dsendere
           par_dstelefo = par_dstelefo + "Telefone: " + rel_dstelefo.

    IF   rel_inpessoa = 1 THEN
         ASSIGN rel_dscpfcgc = STRING(DECI(rel_dscpfcgc),"99999999999")
                par_dscpfcgc = par_dscpfcgc + "CPF: "  +
                               STRING(rel_dscpfcgc,"xxx.xxx.xxx-xx").
    ELSE
         ASSIGN rel_dscpfcgc = STRING(DECI(rel_dscpfcgc),"99999999999999")
                par_dscpfcgc = par_dscpfcgc + "CNPJ: " +
                               STRING(rel_dscpfcgc,"xx.xxx.xxx/xxxx-xx").

    RETURN "OK".

END PROCEDURE.

/*............................. PROCEDURES INTERNAS .........................*/

PROCEDURE Gera_Log:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraditiv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdaditiv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgpagto AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtdpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctagar AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpaplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsbemfin AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrrenava AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpchassi AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dschassi AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdplaca AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ufdplaca AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dscorbem AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nranobem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrmodbem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_uflicenc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdgaran AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfgar AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocgar AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrpromis AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlpromis AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpproapl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idgaropc AS INTE                           NO-UNDO.

    DEF  VAR par_dsgpagto AS CHAR                                   NO-UNDO.


    /* Log */
    IF  aux_nrdrowid = ? THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT YES,
                            INPUT 1, /** idseqttl **/
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    ASSIGN aux_nrsequex = aux_nrsequex + 1.

    IF  par_cddopcao = "I" THEN
        /* Item - dtmvtolt */
        RUN proc_gerar_log_item
            ( INPUT aux_nrdrowid,
              INPUT "dtmvtolt" + STRING(aux_nrsequex),
              INPUT STRING(par_dtmvtolt),
              INPUT "").

    /* Item - nrdconta */
    RUN proc_gerar_log_item
        ( INPUT aux_nrdrowid,
          INPUT "nrdconta" + (IF par_cddopcao <> "X" THEN
                              STRING(aux_nrsequex) ELSE ""),
          INPUT STRING(par_nrdconta),
          INPUT "").

    /* Item - tpctrato */
    RUN proc_gerar_log_item
        ( INPUT aux_nrdrowid,
          INPUT "tpctrato",
          INPUT STRING(par_tpctrato) + (IF par_tpctrato = 1 THEN "Lim. Cred"
                                   ELSE IF par_tpctrato = 2 THEN "Lim. Dsc. Chq."
                                   ELSE IF par_tpctrato = 3 THEN "Lim. Dsc. Tit."
                                   ELSE "Emp.Fin."),
          INPUT "").

    /* Item - nrctremp */
    RUN proc_gerar_log_item
        ( INPUT aux_nrdrowid,
          INPUT "nrctremp" + (IF par_cddopcao <> "X" THEN
                              STRING(aux_nrsequex) ELSE ""),
          INPUT STRING(par_nrctremp),
          INPUT "").

    /* Opcao X nao tem esses itens */
    IF  par_cddopcao <> "X" THEN
        DO:
            /* Item - nraditiv */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nraditiv" + STRING(aux_nrsequex),
                  INPUT STRING(par_nraditiv),
                  INPUT "").

            /* Item - cdaditiv */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "cdaditiv" + STRING(aux_nrsequex),
                  INPUT STRING(par_cdaditiv),
                  INPUT "").
        END.

    /* Item cdaditiv  1 */
    IF  par_cdaditiv = 1 THEN
        DO:

            /* */
            IF  par_flgpagto THEN
                ASSIGN par_dsgpagto = "Folha de Pagto".
            ELSE
                ASSIGN par_dsgpagto = "Conta Corrente".


            /* Item - flgpagto */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "flgpagto" + STRING(aux_nrsequex),
                  INPUT STRING(par_dsgpagto),
                  INPUT "").

            /* Item - dtdpagto */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "dtdpagto" + STRING(aux_nrsequex),
                  INPUT STRING(par_dtdpagto),
                  INPUT "").
        END.

    /* Item cdaditiv  2 e 3 */
    IF  par_cdaditiv = 2 OR par_cdaditiv = 3 THEN
        DO:

            /* Item cdaditiv  3 */
            IF  par_cdaditiv = 3 THEN
                DO:
                    /* Item - nrctagar */
                    RUN proc_gerar_log_item
                        ( INPUT aux_nrdrowid,
                          INPUT "nrctagar" + STRING(aux_nrsequex),
                          INPUT STRING(par_nrctagar),
                          INPUT "").

                END.

            /* Item - tpaplica */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "tpaplica" + STRING(aux_nrsequex),
                  INPUT STRING(par_tpaplica),
                  INPUT "").

            /* Item - nraplica */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "nraplica" + STRING(aux_nrsequex),
                  INPUT STRING(par_nraplica),
                  INPUT "").

            /* Item - tpproapl */
            RUN proc_gerar_log_item
                ( INPUT aux_nrdrowid,
                  INPUT "tpproapl" + STRING(aux_nrsequex),
                  INPUT STRING(par_tpproapl),
                  INPUT "").

        END.

    /* Item - cdaditiv 5 */
   IF   par_cdaditiv = 5 OR par_cdaditiv = 6 THEN
        DO:
            /* Item - cdaditiv 6 */
           IF   par_cdaditiv = 6 THEN
                DO:
                   /* Item - nmdgaran */
                   RUN proc_gerar_log_item
                       ( INPUT aux_nrdrowid,
                         INPUT "nmdgaran" + STRING(aux_nrsequex),
                         INPUT STRING(par_nmdgaran),
                         INPUT "").

                   /* Item - nrcpfgar */
                   RUN proc_gerar_log_item
                       ( INPUT aux_nrdrowid,
                         INPUT "nrcpfgar" + STRING(aux_nrsequex),
                         INPUT STRING(par_nrcpfgar),
                         INPUT "").

                   /* Item - nrdocgar */
                   RUN proc_gerar_log_item
                       ( INPUT aux_nrdrowid,
                         INPUT "nrdocgar" + STRING(aux_nrsequex),
                         INPUT STRING(par_nrdocgar),
                         INPUT "").

                END.

           /* Item - dsbemfin */
           RUN proc_gerar_log_item
               ( INPUT aux_nrdrowid,
                 INPUT "dsbemfin" + (IF par_cddopcao <> "X" THEN
                                     STRING(aux_nrsequex) ELSE ""),
                 INPUT STRING(par_dsbemfin),
                 INPUT "").

           /* Item - nrrenava */
           RUN proc_gerar_log_item
               ( INPUT aux_nrdrowid,
                 INPUT "nrrenava" + (IF par_cddopcao <> "X" THEN
                                     STRING(aux_nrsequex) ELSE ""),
                 INPUT STRING(par_nrrenava),
                 INPUT "").

           /* Item - tpchassi */
           RUN proc_gerar_log_item
               ( INPUT aux_nrdrowid,
                 INPUT "tpchassi" + (IF par_cddopcao <> "X" THEN
                                     STRING(aux_nrsequex) ELSE ""),
                 INPUT STRING(par_tpchassi),
                 INPUT "").

           /* Item - dschassi */
           RUN proc_gerar_log_item
               ( INPUT aux_nrdrowid,
                 INPUT "dschassi" + (IF par_cddopcao <> "X" THEN
                                     STRING(aux_nrsequex) ELSE ""),
                 INPUT STRING(par_dschassi),
                 INPUT "").

           /* Item - nrdplaca */
           RUN proc_gerar_log_item
               ( INPUT aux_nrdrowid,
                 INPUT "nrdplaca" + (IF par_cddopcao <> "X" THEN
                                     STRING(aux_nrsequex) ELSE ""),
                 INPUT STRING(par_nrdplaca),
                 INPUT "").

           /* Item - ufdplaca */
           RUN proc_gerar_log_item
               ( INPUT aux_nrdrowid,
                 INPUT "ufdplaca" + (IF par_cddopcao <> "X" THEN
                                     STRING(aux_nrsequex) ELSE ""),
                 INPUT STRING(par_ufdplaca),
                 INPUT "").

           /* Item - dscorbem */
           RUN proc_gerar_log_item
               ( INPUT aux_nrdrowid,
                 INPUT "dscorbem" + (IF par_cddopcao <> "X" THEN
                                     STRING(aux_nrsequex) ELSE ""),
                 INPUT STRING(par_dscorbem),
                 INPUT "").

           /* Item - nranobem */
           RUN proc_gerar_log_item
               ( INPUT aux_nrdrowid,
                 INPUT "nranobem" + (IF par_cddopcao <> "X" THEN
                                     STRING(aux_nrsequex) ELSE ""),
                 INPUT STRING(par_nranobem),
                 INPUT "").

           /* Item - nrmodbem */
           RUN proc_gerar_log_item
               ( INPUT aux_nrdrowid,
                 INPUT "nrmodbem" + (IF par_cddopcao <> "X" THEN
                                     STRING(aux_nrsequex) ELSE ""),
                 INPUT STRING(par_nrmodbem),
                 INPUT "").

           /* Item - uflicenc */
           RUN proc_gerar_log_item
               ( INPUT aux_nrdrowid,
                 INPUT "uflicenc" + (IF par_cddopcao <> "X" THEN
                                     STRING(aux_nrsequex) ELSE ""),
                 INPUT STRING(par_uflicenc),
                 INPUT "").
        END.

    /* Item - cdaditiv 7 */
   IF   par_cdaditiv = 7 THEN
        DO:

           /* Item - nrcpfcgc */
           RUN proc_gerar_log_item
               ( INPUT aux_nrdrowid,
                 INPUT "nrcpfcgc" + STRING(aux_nrsequex),
                 INPUT STRING(par_nrcpfgar),
                 INPUT "").

           /* Item - nrpromis */
           RUN proc_gerar_log_item
               ( INPUT aux_nrdrowid,
                 INPUT "nrpromis" + STRING(aux_nrsequex),
                 INPUT STRING(par_nrpromis),
                 INPUT "").

           /* Item - vlpromis */
           RUN proc_gerar_log_item
               ( INPUT aux_nrdrowid,
                 INPUT "vlpromis" + STRING(aux_nrsequex),
                 INPUT STRING(par_vlpromis),
                 INPUT "").

        END.

    /* Item - cdaditiv 8 */
   IF   par_cdaditiv = 8 THEN
        DO:

           /* Item - nrcpfcgc */
           RUN proc_gerar_log_item
               ( INPUT aux_nrdrowid,
                 INPUT "nrcpfcgc" + STRING(aux_nrsequex),
                 INPUT STRING(par_nrcpfgar),
                 INPUT "").

           /* Item - vlpromis */
           RUN proc_gerar_log_item
               ( INPUT aux_nrdrowid,
                 INPUT "vlpromis" + STRING(aux_nrsequex),
                 INPUT STRING(par_vlpromis),
                 INPUT "").

        END.

    /* Item - cdaditiv 9 */
   IF   par_cdaditiv = 9 THEN
        DO:

           /* Se possui garantia para operacao de credito */
           IF   par_idgaropc > 0 THEN
                DO:
                   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                   /* Efetuar a chamada a rotina Oracle */
                   RUN STORED-PROCEDURE pc_busca_cobert_garopc_prog
                   aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_idgaropc
                                                       ,OUTPUT 0     /* pr_inresaut */
                                                       ,OUTPUT 0     /* pr_permingr */
                                                       ,OUTPUT 0     /* pr_inaplpro */
                                                       ,OUTPUT 0     /* pr_inpoupro */
                                                       ,OUTPUT 0     /* pr_nrctater */
                                                       ,OUTPUT 0     /* pr_inaplter */
                                                       ,OUTPUT 0     /* pr_inpouter */
                                                       ,OUTPUT 0     /* pr_cdcritic */
                                                       ,OUTPUT "").  /* pr_dscritic */

                   /* Fechar o procedimento para buscarmos o resultado */
                   CLOSE STORED-PROC pc_busca_cobert_garopc_prog
                         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                   /* Busca possíveis erros */
                   ASSIGN aux_cdcritic = 0
                          aux_dscritic = ""
                          aux_cdcritic = pc_busca_cobert_garopc_prog.pr_cdcritic
                                         WHEN pc_busca_cobert_garopc_prog.pr_cdcritic <> ?
                          aux_dscritic = pc_busca_cobert_garopc_prog.pr_dscritic
                                         WHEN pc_busca_cobert_garopc_prog.pr_dscritic <> ?.

                   IF  aux_dscritic = "" AND aux_cdcritic = 0 THEN
                       DO:
                          /* Item – resgate_automatico */
                          RUN proc_gerar_log_item
                              ( INPUT aux_nrdrowid,
                                INPUT "ResgateAutomatico",
                                INPUT (IF pc_busca_cobert_garopc_prog.pr_inresaut = 0 THEN "Nao" Else "Sim"),
                                INPUT "").

                          /* Item – perminimo */
                          RUN proc_gerar_log_item
                              ( INPUT aux_nrdrowid,
                                INPUT "Percentual Cobertura Minima",
                                INPUT STRING(pc_busca_cobert_garopc_prog.pr_permingr),
                                INPUT "").

                          /* Item – Aplicaçao Propria */
                          RUN proc_gerar_log_item
                              ( INPUT aux_nrdrowid,
                                INPUT "Aplicacao Propria",
                                INPUT (IF pc_busca_cobert_garopc_prog.pr_inaplpro = 0 THEN "Nao" Else "Sim"),
                                INPUT "").

                          /* Item – Poupanca Propria */
                          RUN proc_gerar_log_item
                              ( INPUT aux_nrdrowid,
                                INPUT "Poupanca Propria",
                                INPUT (IF pc_busca_cobert_garopc_prog.pr_inpoupro = 0 THEN "Nao" Else "Sim"),
                                INPUT "").

                          /* Se possuir conta terceiro */
                          IF  pc_busca_cobert_garopc_prog.pr_nrctater > 0 THEN
                              DO:
                                 /* Item – Conta Terceiro */
                                 RUN proc_gerar_log_item
                                     ( INPUT aux_nrdrowid,
                                       INPUT "Conta Terceiro",
                                       INPUT STRING(pc_busca_cobert_garopc_prog.pr_nrctater),
                                       INPUT "").

                                 /* Item – Aplicacao Terceiro */
                                 RUN proc_gerar_log_item
                                     ( INPUT aux_nrdrowid,
                                       INPUT "Aplicacao Terceiro",
                                       INPUT (IF pc_busca_cobert_garopc_prog.pr_inaplter = 0 THEN "Nao" Else "Sim"),
                                       INPUT "").

                                 /* Item – Poupanca Terceiro */
                                 RUN proc_gerar_log_item
                                     ( INPUT aux_nrdrowid,
                                       INPUT "Poupanca Terceiro",
                                       INPUT (IF pc_busca_cobert_garopc_prog.pr_inpouter = 0 THEN "Nao" Else "Sim"),
                                       INPUT "").
                              END.
                       END.

                END.

        END.

END PROCEDURE.



PROCEDURE obtem_nro_aditivo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM aux_uladitiv AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    ASSIGN aux_uladitiv = 0
           par_cdcritic = 0.

    DO aux_contador = 1 TO 10:

        FIND LAST crapadt WHERE crapadt.cdcooper = par_cdcooper AND
                                crapadt.nrdconta = par_nrdconta AND
                                crapadt.nrctremp = par_nrctremp AND
                                crapadt.tpctrato = par_tpctrato
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapadt THEN
            IF  LOCKED crapadt THEN
                DO:
                    ASSIGN par_cdcritic = 77.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
            ELSE         /* se nao existe reg. na tabela */
                DO:
                    ASSIGN aux_uladitiv = 1.
                    LEAVE.
                END.
        ELSE
            ASSIGN aux_uladitiv = crapadt.nraditiv + 1.

        ASSIGN par_cdcritic = 0.

        LEAVE.
    END.  /*  Fim do DO .. TO  */

    RETURN.

END PROCEDURE. /* obtem_nro_aditivo */

PROCEDURE verifica_prestacoes_pagas.

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_vltotpag AS DECI                           NO-UNDO.

   ASSIGN par_vltotpag = 0.

   /* Contabiliza todos os valores lancados para o emprestimo */

   FOR EACH craplem WHERE craplem.cdcooper = par_cdcooper AND
                          craplem.nrdconta = par_nrdconta AND
                          craplem.nrctremp = par_nrctremp NO-LOCK:

       IF   craplem.cdhistor = 91  OR   /* Pagto LANDPV          */
            craplem.cdhistor = 92  OR   /* Empr.Consig.Caixa On_line */
            craplem.cdhistor = 93  OR   /* Emprestimo Consignado */
            craplem.cdhistor = 95  OR   /* Pagto crps120         */
            craplem.cdhistor = 393 OR   /* Pagto Avalista        */
            craplem.cdhistor = 353 THEN /* Transf. Cotas         */
            ASSIGN par_vltotpag = par_vltotpag + craplem.vllanmto.
       ELSE
       IF   craplem.cdhistor = 88  OR
            craplem.cdhistor = 507 THEN /*Est.Transf.Cot*/
            ASSIGN par_vltotpag = par_vltotpag - craplem.vllanmto.
   END.

   RETURN "OK".

END. /* verifica_prestacoes_pagas */

PROCEDURE busca_aplicacoes_car.

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nraplica AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.

    /* Variaveis retornadas da procedure pc_busca_aplicacoes_car */
    DEF VAR aux_nraplica   AS INTE                                  NO-UNDO.
    DEF VAR aux_idtippro   AS INTE                                  NO-UNDO.
    DEF VAR aux_cdprodut   AS INTE                                  NO-UNDO.
    DEF VAR aux_nmprodut   AS CHAR                                  NO-UNDO.
    DEF VAR aux_dsnomenc   AS CHAR                                  NO-UNDO.
    DEF VAR aux_nmdindex   AS CHAR                                  NO-UNDO.
    DEF VAR aux_vlaplica   AS DECI                                  NO-UNDO.
    DEF VAR aux_vlsldtot   AS DECI                                  NO-UNDO.
    DEF VAR aux_vlsldrgt   AS DECI                                  NO-UNDO.
    DEF VAR aux_vlrdirrf   AS DECI                                  NO-UNDO.
    DEF VAR aux_percirrf   AS DECI                                  NO-UNDO.
    DEF VAR aux_dtmvtolt   AS CHAR                                  NO-UNDO.
    DEF VAR aux_dtvencto   AS CHAR                                  NO-UNDO.
    DEF VAR aux_qtdiacar   AS INTE                                  NO-UNDO.
    DEF VAR aux_qtdiaapl   AS INTE                                  NO-UNDO.
    DEF VAR aux_txaplica   AS DECI                                  NO-UNDO.
    DEF VAR aux_idblqrgt   AS INTE                                  NO-UNDO.
    DEF VAR aux_dsblqrgt   AS CHAR                                  NO-UNDO.
    DEF VAR aux_dsresgat   AS CHAR                                  NO-UNDO.
    DEF VAR aux_dtresgat   AS CHAR                                  NO-UNDO.
    DEF VAR aux_cdoperad   AS CHAR                                  NO-UNDO.
    DEF VAR aux_nmoperad   AS CHAR                                  NO-UNDO.
    DEF VAR aux_idtxfixa   AS INTE                                  NO-UNDO.

    /********NOVA CONSULTA APLICACOOES*********/
    /** Saldo das aplicacoes **/

    /* Inicializando objetos para leitura do XML */
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada a rotina Oracle */
    RUN STORED-PROCEDURE pc_busca_aplicacoes_car
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper     /* Código da Cooperativa*/
                                        ,INPUT par_cdoperad     /* Código do Operador*/
                                        ,INPUT par_nmdatela     /* Nome da Tela*/
                                        ,INPUT 1                /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA*/
                                        ,INPUT par_nrdconta     /* Número da Conta*/
                                        ,INPUT par_idseqttl     /* Titular da Conta*/
                                        ,INPUT par_nraplica     /* Número da Aplicaçao - Parâmetro Opcional*/
                                        ,INPUT 0                /* Código do Produto – Parâmetro Opcional */
                                        ,INPUT par_dtmvtolt     /* Data de Movimento*/
                                        ,INPUT 0                /* Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas) */
                                        ,INPUT 0                /* Identificador de Log (0 – Nao / 1 – Sim) */
                                        ,OUTPUT ?               /* XML */
                                        ,OUTPUT 0               /* Código da crítica */
                                        ,OUTPUT "").            /* Descriçao da crítica */

    /* Fechar o procedimento para buscarmos o resultado */
    CLOSE STORED-PROC pc_busca_aplicacoes_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    /* Busca possíveis erros */
    ASSIGN aux_cdcritic = 0
          aux_dscritic = ""
          aux_cdcritic = pc_busca_aplicacoes_car.pr_cdcritic
                         WHEN pc_busca_aplicacoes_car.pr_cdcritic <> ?
          aux_dscritic = pc_busca_aplicacoes_car.pr_dscritic
                         WHEN pc_busca_aplicacoes_car.pr_dscritic <> ?.

    /* Buscar o XML na tabela de retorno da procedure Progress */
    ASSIGN xml_req = pc_busca_aplicacoes_car.pr_clobxmlc.

    /*IF  xml_req = ? THEN
        LEAVE Busca.
      */
    /* Efetuar a leitura do XML*/
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1.
    PUT-STRING(ponteiro_xml,1) = xml_req.

    xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE).
    xDoc:GET-DOCUMENT-ELEMENT(xRoot).

    DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN:

        xRoot:GET-CHILD(xRoot2,aux_cont_raiz).

        IF xRoot2:SUBTYPE <> "ELEMENT"   THEN
         NEXT.

        ASSIGN aux_nraplica = 0
               aux_idtippro = 0
               aux_cdprodut = 0
               aux_nmprodut = ""
               aux_dsnomenc = ""
               aux_nmdindex = ""
               aux_vlaplica = 0
               aux_vlsldtot = 0
               aux_vlsldrgt = 0
               aux_vlrdirrf = 0
               aux_percirrf = 0
               aux_dtmvtolt = ""
               aux_dtvencto = ""
               aux_qtdiacar = 0
               aux_txaplica = 0
               aux_idblqrgt = 0
               aux_dsblqrgt = ""
               aux_dsresgat = ""
               aux_dtresgat = ""
               aux_cdoperad = ""
               aux_nmoperad = ""
               aux_idtxfixa = 0
               aux_qtdiaapl = 0.

        DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:

            xRoot2:GET-CHILD(xField,aux_cont).

            IF xField:SUBTYPE <> "ELEMENT" THEN
                NEXT.

            xField:GET-CHILD(xText,1).

            ASSIGN aux_nraplica = INT (xText:NODE-VALUE) WHEN xField:NAME = "nraplica"
                   aux_idtippro = INT (xText:NODE-VALUE) WHEN xField:NAME = "idtippro"
                   aux_cdprodut = INT (xText:NODE-VALUE) WHEN xField:NAME = "cdprodut"
                   aux_nmprodut = xText:NODE-VALUE WHEN xField:NAME = "nmprodut"
                   aux_dsnomenc = xText:NODE-VALUE WHEN xField:NAME = "dsnomenc"
                   aux_nmdindex = xText:NODE-VALUE WHEN xField:NAME = "nmdindex"
                   aux_vlaplica = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlaplica"
                   aux_vlsldtot = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsldtot"
                   aux_vlsldrgt = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsldrgt"
                   aux_vlrdirrf = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlrdirrf"
                   aux_percirrf = DECI(xText:NODE-VALUE) WHEN xField:NAME = "percirrf"
                   aux_dtmvtolt = xText:NODE-VALUE WHEN xField:NAME = "dtmvtolt"
                   aux_dtvencto = xText:NODE-VALUE WHEN xField:NAME = "dtvencto"
                   aux_qtdiacar = INT (xText:NODE-VALUE) WHEN xField:NAME = "qtdiacar"
                   aux_txaplica = DECI(xText:NODE-VALUE) WHEN xField:NAME = "txaplica"
                   aux_idblqrgt = INT (xText:NODE-VALUE) WHEN xField:NAME = "idblqrgt"
                   aux_dsblqrgt = xText:NODE-VALUE WHEN xField:NAME = "dsblqrgt"
                   aux_dsresgat = xText:NODE-VALUE WHEN xField:NAME = "dsresgat"
                   aux_dtresgat = xText:NODE-VALUE WHEN xField:NAME = "dtresgat"
                   aux_cdoperad = xText:NODE-VALUE WHEN xField:NAME = "cdoperad"
                   aux_nmoperad = xText:NODE-VALUE WHEN xField:NAME = "nmoperad"
                   aux_idtxfixa = INT (xText:NODE-VALUE) WHEN xField:NAME = "idtxfixa"
                   aux_qtdiaapl = INT (xText:NODE-VALUE) WHEN xField:NAME = "qtdiauti".

        END.

        IF  xRoot2:NUM-CHILDREN > 0 THEN
            DO:
                IF  par_cddopcao = "I" THEN
                    IF aux_idblqrgt > 0 THEN
                        NEXT.

                CREATE  tt-saldo-rdca.
                ASSIGN  tt-saldo-rdca.dsaplica = aux_dsnomenc
                        tt-saldo-rdca.vlsdrdad = aux_vlsldrgt
                        tt-saldo-rdca.vllanmto = aux_vlsldtot
                        tt-saldo-rdca.vlaplica = aux_vlaplica
                        tt-saldo-rdca.dtvencto = DATE(aux_dtvencto)
                        tt-saldo-rdca.indebcre = aux_dsblqrgt
                        tt-saldo-rdca.cdoperad = aux_cdoperad
                        tt-saldo-rdca.sldresga = aux_vlsldrgt
                        tt-saldo-rdca.qtdiaapl = aux_qtdiaapl
                        tt-saldo-rdca.qtdiauti = aux_qtdiacar
                        tt-saldo-rdca.txaplmax = STRING(aux_txaplica)
                        tt-saldo-rdca.txaplmin = STRING(aux_txaplica)
                        tt-saldo-rdca.tpaplrdc = aux_idtippro
                        tt-saldo-rdca.tpaplica = IF aux_idtippro = 1 THEN 7 ELSE 8
                        tt-saldo-rdca.dtmvtolt = DATE(aux_dtmvtolt)
                        tt-saldo-rdca.nrdocmto = STRING(aux_nraplica, "zz,zz9")
                        tt-saldo-rdca.nraplica = aux_nraplica
                        tt-saldo-rdca.idtipapl = "N"
                        tt-saldo-rdca.dshistor = aux_dsnomenc.
            END.

    END.

    SET-SIZE(ponteiro_xml) = 0.

    DELETE OBJECT xDoc.
    DELETE OBJECT xRoot.
    DELETE OBJECT xRoot2.
    DELETE OBJECT xField.
    DELETE OBJECT xText.

END PROCEDURE.


/*.............................. PROCEDURES (FIM) ...........................*/


/*................................ FUNCTIONS ................................*/

FUNCTION f_datapossivel RETURNS DATE PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_dtmvtolt AS DATE,
      INPUT par_nrdconta AS INTEGER,
      INPUT par_nrctremp AS INTEGER,
     OUTPUT par_cdcritic AS INTEGER ):
/*-----------------------------------------------------------------------------
  Objetivo:
     Notas:
-----------------------------------------------------------------------------*/

    DEF VAR fun_dtcalcul AS DATE                                    NO-UNDO.
    DEF VAR aux_dtultdia AS DATE                                    NO-UNDO.
    DEF VAR aux_dtultdma AS DATE                                    NO-UNDO.
    DEF VAR aux_vltotpag AS DECI                                    NO-UNDO.
    DEF VAR h-b1wgen0008 AS HANDLE                                  NO-UNDO.

    FOR FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper  NO-LOCK: END.

    IF  AVAIL crapdat THEN
        ASSIGN aux_dtultdma = crapdat.dtmvtolt - DAY(crapdat.dtmvtolt).

    ASSIGN aux_dtultdia = ((DATE(MONTH(par_dtmvtolt),28,YEAR(par_dtmvtolt))
               + 4)- DAY(DATE(MONTH(par_dtmvtolt),28,YEAR(par_dtmvtolt)) + 4)).

    FOR FIRST crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                            crapepr.nrdconta = par_nrdconta AND
                            crapepr.nrctremp = par_nrctremp NO-LOCK: END.

    IF  AVAIL crapepr THEN
        DO:
            RUN verifica_prestacoes_pagas
                ( INPUT par_cdcooper,
                  INPUT crapepr.nrdconta,
                  INPUT crapepr.nrctremp,
                 OUTPUT aux_vltotpag).

            IF  aux_vltotpag = 0 THEN
                ASSIGN fun_dtcalcul = aux_dtultdia + 365.
            ELSE
            IF  crapepr.flgpagto THEN
                DO:
                    IF  f_pagou_no_mes( INPUT par_cdcooper,
                                        INPUT crapepr.nrdconta,
                                        INPUT crapepr.nrctremp,
                                        INPUT aux_dtultdma,
                                        INPUT crapepr.vlpreemp ) OR
                        crapepr.cdempres = 4            THEN
                        DO:
                            ASSIGN fun_dtcalcul = (aux_dtultdia + 35)
                                   fun_dtcalcul = fun_dtcalcul -
                                                  DAY(fun_dtcalcul).
                        END.
                    ELSE
                        DO:
                            FOR LAST crapavs WHERE
                                     crapavs.cdcooper = par_cdcooper      AND
                                     crapavs.nrdconta = crapepr.nrdconta  AND
                                     crapavs.nrdocmto = crapepr.nrctremp  AND
                                     crapavs.tpdaviso = 1                 AND
                                     crapavs.cdhistor = 108               AND
                                     crapavs.insitavs = 1   NO-LOCK: END.

                            IF  AVAIL crapavs THEN
                                DO:
                                    IF  crapavs.dtrefere <= aux_dtultdma   THEN
                                        ASSIGN fun_dtcalcul = aux_dtultdia.
                                   ELSE
                                        ASSIGN fun_dtcalcul = crapavs.dtrefere.
                                END.
                           ELSE
                                ASSIGN fun_dtcalcul = aux_dtultdia.

                        END.   /* ELSE IF f_pagou_no_mes ..... */
               END.
            ELSE    /* IF crapepr.flgpagto... */
                DO:
                    IF  NOT VALID-HANDLE(h-b1wgen0008) THEN
                        RUN sistema/generico/procedures/b1wgen0008.p
                            PERSISTENT SET h-b1wgen0008.

                    RUN calcdata IN h-b1wgen0008
                          ( INPUT par_cdcooper,
                            INPUT 0,
                            INPUT 0,
                            INPUT "",
                            INPUT crapepr.dtdpagto,
                            INPUT 1,
                            INPUT "M",
                            INPUT 0,
                           OUTPUT fun_dtcalcul,
                           OUTPUT TABLE tt-erro ).

                    IF  VALID-HANDLE(h-b1wgen0008) THEN
                        DELETE OBJECT h-b1wgen0008.

                    FIND FIRST tt-erro NO-ERROR.

                    IF  AVAILABLE tt-erro THEN
                        DO:
                            ASSIGN par_cdcritic = tt-erro.cdcritic.
                            EMPTY TEMP-TABLE tt-erro.
                            RETURN fun_dtcalcul.
                        END.

                   ASSIGN fun_dtcalcul = fun_dtcalcul - DAY(fun_dtcalcul).

               END.  /* IF not crapepr.flgpagto... */

       END. /* if available crapepr ... */
  ELSE
      ASSIGN par_cdcritic = 356.

  RETURN fun_dtcalcul.

END.

FUNCTION f_pagou_no_mes RETURN LOGICAL
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_nrdconta AS INTEGER,
      INPUT par_nrctremp AS INTEGER,
      INPUT par_dtultdma AS DATE,
      INPUT par_vlpreemp AS DECIMAL ):
/*-----------------------------------------------------------------------------
  Objetivo: Funcao utilizada para verificar se o cooperado efetuou pagamentos
           com valor equivalente a uma parcela do emprestimo no mes.
     Notas:
-----------------------------------------------------------------------------*/

  DEFINE VARIABLE fun_vlpagmes AS DECIMAL                      NO-UNDO.

  FOR EACH craplem WHERE craplem.cdcooper = par_cdcooper      AND
                         craplem.nrdconta = par_nrdconta      AND
                         craplem.nrctremp = par_nrctremp      AND
                         craplem.dtmvtolt > par_dtultdma
                         NO-LOCK:

      IF   craplem.cdhistor = 91    OR    /* Pagto LANDPV  */
           craplem.cdhistor = 95    OR    /* Pagto crps120 */
           craplem.cdhistor = 92    OR    /* Consig. Caixa */
           craplem.cdhistor = 93    OR    /* Consig. Arq */
           craplem.cdhistor = 393   OR    /* Pagto Avalista */
           craplem.cdhistor = 353   THEN  /* Transf. Cotas */
           ASSIGN fun_vlpagmes = fun_vlpagmes + craplem.vllanmto.
      ELSE
           ASSIGN fun_vlpagmes = fun_vlpagmes - craplem.vllanmto.
  END.

  RETURN (fun_vlpagmes >= par_vlpreemp).

END.




