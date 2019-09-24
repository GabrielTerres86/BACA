/*..............................................................................

    Programa  : sistema/generico/procedures/b1wgen0137.p
    Autor     : Guilherme
    Data      : Abril/2012                      Ultima Atualizacao: 09/09/2019
    
    Dados referentes ao programa:

    Objetivo  : Digitalizacao de documentos Selbetti
                BO para comunicacao com o aplicativo SmartShare.
                Regras para a integraçao do SmartShare com o Ayllos.

    Alteracoes: 20/06/2012 - Quebrar relatorio por pagina de acordo com o PAC
                             (Guilherme).
                             
                29/06/2012 - Incluído e ordenado coluna PAC em "CONTRATOS 
                             DIGITALIZADOS NAO ENCONTRADOS", informaçao recebida
                             do xml, nó "CdPac" (Guilherme Maba).
                             
                16/07/2012 - Alterar permissao do LOG para 666, pois quando
                             rodado na cron a permissao está como ROOT 
                             (Guilherme).
                             
                29/01/2013 - Acerto no batimento das inconsistencias
                             Selbetti->Cecred (Guilherme).
                             
                19/02/2013 - Incluir nova procedure para validacao de 
                             documentos (Gabriel). 
                             
                04/04/2013 - Feito controle de LOCK na procedure 
                             efetua_batimento_ged (Daniele).  
                             
                12/04/2013 - Disponibilizar o arquivo crrl620 no diretorio
                             /micros/cooperativa (David Kruger).        
                             
                07/05/2013 - Adicionado tratamento para Contratos de 
                             emprestimo/financiamento (Lucas).
                
                23/05/2013 - 64760 No batimento do GED, alterar automaticamente 
                             a data para o primeiro dia do mes anterior.
                             Exemplo, no dia 02/05/2013, quando rodar o 
                             batimento, alterar a data anterior para 01/04/2013
                             65207 Retirada a segunda parte de batimento:
                             "CONTRATOS DIGITALIZADOS NAO ENCONTRADOS"
                             do relatório crrl620 (Contratos que estao no 
                             software Smartshare e n existem no Ayllos) (Carlos)
                 
                 14/06/2013 - Alteraçao funçao enviar__completo para
                              nova versao (Jean Michel).
                              
                 09/07/2013 - Adicionado parametro na procedure 'efetua_batimento_ged'
                              para identificar origem da chamada (Lucas).

                 26/07/2013 - Incluído laço de data na busca das operacoes para
                              Indice. Incluído parametro na busca do b-crapepr
                              para usar indice (Douglas).  
                 
                 13/08/2013 - Alteraçao de layout p/ inclusao de novos tipos de
                              documentos nao digitalizados (Jean Michel).
                              
                 01/10/2013 - Alteraçao da procedure traz_situacao_documento, ajuste
                              feito na parte de validaçao de contratos e borderos
                              (Jean Michel).
                              
                 04/10/2013 - Alteraçao da procedure efetua_batimento_ged, incluido
                              novos tipos de documentos (Jean Michel).
                              
                 31/10/2013 - Alteraçao da procedure efetua_batimento_ged, divisao do
                              relatorio de batimento em cadastro e credito (Jean Michel).
                              
                 28/11/2013 - Alteraçao da procedure efetua_batimento_ged, inclusao
                              do parametro de retorno par_nmarqcre (Jean Michel).
                              
                 29/11/2013 - Alteraçao da procedure efetua_batimento_ged, alteracao
                              do parametro de data de entrada de emprestimos, incluido
                              consulta na crawepr e alteracao na leitura da crapadt p/
                              melhor performance (Jean Michel).
                              
                 03/12/2013 - Alteraçao da procedure efetua_batimento_ged, ajuste na
                              quebra de pagina por PA no relatorio do batimento
                              (Jean Michel).
                              
                 23/01/2014 - Alteraçao da procedure efetua_batimento_ged, segregaçao
                              de datas para os relatórios de crédito e cadastro (Jean Michel).
                              
                 03/02/2014 - Ajustes no layout do frame f_contr_2 (Lucas R.)
                 
                 06/02/2014 - Incluir BY tt-contr_ndigi.dtlibera no batimento
                              de credito, substituido o repeat por DO
                              (Lucas R.)
                              
                 07/02/2014 - Ajustes para melhorar performace das procedures 
                              efetua_batimento_ged_cadastro e 
                              efetua_batimento_ged_credito (Lucas R.)
                              
                 14/02/2014 - Incluir FIND da crapass na procedure
                              efetua_batimento_ged_cadastro (Lucas R.)
                              
                 19/02/2014 - Incluir crapadt.dtmvtolt <= par_datafina
                              na procedure efetua_batimento_ged_credito 
                              (Lucas R.)
                
                 24/02/2014 - Ajustar BY da temp-table tt-contr_ndigi (Lucas R)
                 
                 25/02/2014 - Incluir quebra de relatorio por PA, para cada PA
                              gerar um arquivo na procedure efetua_batimento_ged_credito 
                              (Lucas R.)
                              
                 06/03/2014 - Incluir nova procedure efetua_batimento_ged_matricula
                              para gerar relatorio das matriculas com pendencias
                              (Lucas R.)
                              
                 17/03/2014 - Incluir Tratamento para gerar PDF somente quando
                              tipo de relatorio for batch (Lucas R.)
                              
                 20/03/2014 - Incluir Tratamento para imprimir Limite de Credito
                              na procedure efetua_batimento_ged_credito (Lucas R)
                              
                 24/03/2014 - Incluir tratamento para mostrar impressao dos
                              contratos de limite de titulo na procedure 
                              efetua_batimento_ged_credito  (Lucas R.)
                              
                 26/05/2014 - Incluir FIND crapass para validar se conta esta
                              demitida - Softdesk 161315 (Lucas R.) 
                              
                 11/06/2014 - Retirado validacao de limite de cheque, titulo,
                              credito na procedure efetua_batimento_ged_credito
                              Softdesk - 165122 (Lucas R.)
                              
                 08/07/2014 - Relatorio de pendencias para a tela PRCGED
                              (Chamado 143037) (Jonata-RKAM).
                              
                 22/07/2014 - Quando for gerar os relatorios crrl620 pela
                              tela PRCGED, sera gerado com extensao .txt para
                              diferenciar de quando for pelo crps620.
                              Ao termino de cada relatorio de batimento de
                              credito por PA, copiar os mesmos para o diretorio
                              /salvar da cooperativa; caso contrario o processo
                              de limpeza do /rl executado antes do processo
                              noturno ira eliminar os mesmos. 
                              (Chamado 173350) - (Fabricio)
                              
                 07/08/2014 - Removido verificao por valor minimo para gerar
                              pendencia de borderos de cheques/titulos, bem
                              como limites de desconto de cheques/titulos.
                              (Chamado 179013) - (Fabricio)
                              
                 20/08/2014 - Criar arquivo da Opcao R da PRCGED no caminho
                             /micros/<COOPERATIVA>.(Chamado 143037) 
                             (Jonata-RKAM)     
                             
                 26/08/2014 - Incluir o numero do bordero nos descontos
                              do relatorio da opcao R da PRCGED 
                              (Chamado 143037) (Jonata-RKAM).    
                              
                 27/08/2014 - Incluir o campo vlcompcr no relatorio da opcao
                              R da PRCGED (Chamado 143037) (Jonata-RKAM).
                              
                 09/09/2014 - Ajuses na procedure traz_situacao_documento
                              (SD 193485 - Lucas R.)
                              
                 17/09/2014 - Chamado 157924 (Jonata-RKAM).   
                 
                 30/09/2014 - Unificar documentos de identificao e CPF. 
                              Chamado 146840 (Jonata-RKAM).            
                              
                 30/10/2014 - Ajustes para tratar as diferencas que ocorriam
                              entre o relatorio gerado atraves da opcao 'R' da
                              PRCGED e a opcao 'B' da mesma tela (ou 620).
                              (Chamado 201847) - (Fabricio)
                              
                 27/11/2014 - Otimizacao leitura de tabelas envolvidas na
                              geracao do relatorio de pendencias - opcao 'R'.
                              (Fabricio)
                              
                02/03/2015 - (Chamado 252147) Retirar pendencias geradas nos 
                             relatórios: 266, 620, 285  quanto as operaçoes 
                             de crédito liberadas devido aos Termos de Cessao 
                             de Crédito (Cartao Bancoob) (Tiago Castro - RKAM).
                 
                24/03/2015 - Alterar procedure efetua_batimento_ged_matricula
                             para buscar operador da crapalt. (Lucas R. #211037).
                           - Adicionado leitura da tabela crapcdb para os
                             borderos de cheque. (Lucas R. #219252).
                           - Incluir condicao na procedure que efetua batimento
                             de cadastro, aux_tpdocmto verificar tipo de documento
                             quando verifica o se documento foi digitalizado 
                             (Lucas R. #194262 )
                           - Aumentado format do campo nrdcontr do form f_contr
                             e f_contr_3 na procedure efetua_batimento_ged_credito
                             (Lucas R. #259877)
                           - Incluir validacao para Desprezar os contratos de 
                             limite de credito do dia, pois ainda nao foram 
                             digitalizados(Lucas Ranghetti #267931)
                
                05/05/2015 - Alterado os campos crapbdt.insitbdt para 3 e o 
                             campo crapcdb.insitchq para 0 (Lucas Ranghetti #281792)
                           - Adicionado verificacao do tpdocmto = 8 na procedure
                             dos cadastros (Lucas Ranghetti #281769 )
                             
                25/05/2015 - Incluir verificacao para os documentos 1 e 2 na procedure
                             efetua_batimento_ged_cadastro, pois foram unificados.
                           - Adicionado idseqttl na criacao da temp-table dos
                             cadastros (Lucas Ranghetti #287169)
                             
                09/06/2015 - Ajustar leitura da tabela crapcdb para buscar cheques
                             do bordero com insitchq = 2 e dtlibera > dtmvtolt.
                             (Lucas Ranghetti #294478 )              
                             
                17/06/2015 - Incluir linha 850 no NOT CAN-DO do cdlcremp 
                             (Lucas Ranghetti/Oscar).
                           - Incluir nova procedure retorna_docs_liberados
                             referente ao projeto de melhoria 70 
                             (Lucas Ranghetti #281595).
                                                                         
                22/06/2015 - Ajustado leitura dos borderos de desconto de
                             cheques na procedure efetua_batimento_ged_credito,
                             de acordo com regra estabelecida na b1wgen0009
                             (tela ATENDA). (Chamado 294478) - (Fabricio)
                             
                30/07/2015 - Criada procedure 'efetua_batimento_ged_termos'
                             criando um novo tipo de relatorio - Projeto 158 (Lombardi)
                             
                06/08/2015 - Incluir parametro table tt-documentos na procedure 
                             lista-documentos-digitalizados para melhorar performace 
                             e tambem nao ler a craptab duas vezes.
                           - Quebrar busca da lista-documentos-digitalizados, para 
                             buscar registros via SOAP de 3 em 3 meses(Lucas Ranghetti/Fabricio)
                             
                 13/11/2015 - Incluir tratamento para nao buscar documentos digitalizados do
                              tipo 95, entre 01/01/2014 e 06/03/2014 (Lucas Ranghetti #342958)
                            - Ajustar relatorio de batimento cadastro para nao gerar linhas em
                              branco (Lucas Ranghetti #331404 )
                            - Ajustado rotina retorna_docs_liberados para buscar os
                              valores de todos borderos de cheque e titulo (Lucas Ranghetti #359066)
                            - Retirado trecho de codigo em que verifica se tem registro na
                              crapalt para matriculas - nao alterar a data de pendencia de 
                              matricula quando houver alteracao na conta(crapalt) 
                              (Lucas Ranghetti #342958)
                              
                 25/11/2015 - No for each da tt-documentos-digitalizados na procedure
                              do batimento do cadastro, adicionado dtpublic nas 
                              condicoes do for (Lucas Ranghetti #360518)
                              
                 24/12/2015 - Adicionado na procedure traz_situacao_documento
                              a validacao para considerar numeros de contratos
                              com 10 posicoes (considerando pontuacoes).
                              (Chamado 376924) - (Fabricio)
                              
                 05/01/2016 - #350828 Incluido o documento 126 (pessoa exposta politicamente) no 
                              procedimento efetua_batimento_ged_termos (Carlos)
             
                 05/01/2016 - Removido condicao na leitura de validacao do
                              contrato de limite de credito onde filtrava apenas
                              por contratos ativos; 
                              procedure traz_situacao_documento.
                              (Chamado 374121) - (Fabricio)
                              
                 09/03/2016 - Retirar chamadas da rotina de batimento do credito para viacredi 
                              (Lucas Ranghetti #394316 )
                              
                 16/03/2016 - Incluir validacao para nao gerar no relatorio de cadastro 
                              para pessoa juridica tipos(1,2,5) (Lucas Ranghetti #391492)
                10/03/2016 - Alterar codigo do PEP de 126(homol) para 124(Prod) 
                           - Alterar rotina do PEP para buscar os documentos digitalizados
                             da forma correta. (Lucas Ranghetti/Gielow)
 
                10/03/2016 - Alterar codigo do PEP de 126(homol) para 124(Prod) 
                           - Alterar rotina do PEP para buscar os documentos digitalizados
                             da forma correta. (Lucas Ranghetti/Gielow)
                             
                12/04/2016 - Alterado colunas no relatorio 620_termos,
                             separado relatorio por PA -> Tipo -> registros  
                             na procedure,  efetua_batimento_ged_termos (Lucas Ranghetti #410302)
                             
                27/05/2016 - Na procedure retorna_docs_liberados nos Aditivos,
                             incluir leitura da crapepr como "FIRST" da crapadt,
                             pois so devemos listar aditivos com epmrestimos liberados
                             (Lucas Ranghetti #450354)

                07/06/2016 - Adicionado tratamento para pacote de tarifas na geracao
                             de documentos nao digitalizados. PRJ218/2 (Reinert).

                16/06/2016 - Na procedure efetua_batimento_ged_termos, ajustado a
                             descricao do LABEL do Operador que estava "OPEERADOR"
                             (Lucas Ranghetti #467779)   
                             
                26/08/2016 - Retirado verificacao do inliquid = 0 na procedure 
                             efetua_batimento_ged_gredito (Lucas Ranghetti #501523)
                             
                31/08/2016 - Alterar busca da agencia para buscar a agencia do operador
                             na procedure efetua_batimento_termos para o tpdocmto 37 - PEP
                             (Lucas Ranghetti #491441)
                             
                20/09/2016 - Adicionar filtro de data para o 620_termos (Lucas Ranghetti #480384/#469603)      
                
                14/10/2016 - Descontinuar batimento do 620_credito para todas as cooperativas 
                             (Lucas Ranghetti #510032)

	            25/10/2016 - Inserido LICENCAS SOCIO AMBIENTAIS no digidoc 
				             Melhoria 310 (Tiago/Thiago).

			    11/11/2016 - Alterado titulo relatorio de Lic. Soc.Ambiental
				             para Lic. Soc.Ambientais M310(Tiago/Thiago).
                
                09/06/2017 - Ajuste na rotina retorna_docs_liberados para nao gerar pendencia 
                             para borderos efetuados no IB e com valor menor ou igual a 5 mil.
                             PRJ300 - Desconto de Cheques (Lombardi/Daniel)
                     
			    11/08/2017 - Incluído o número do cpf ou cnpj na tabela crapdoc.
                             Projeto 339 - CRM. (Lombardi)
                     
                31/10/2017 - Ajuste na retirada da mascara do CPF/CNPJ na procedure
                             requisicao-lista-documentos. Projeto 339 - CRM. (Lombardi)
                     
                31/10/2017 - Passagem do tpctrato. (Jaison/Marcos Martini - PRJ404)
                     
                22/11/2017 - Em alguns documentos não virá mais nrdconta
                             Tratado consultas e updates. Projeto 339 - CRM. (Lombardi)
                     
                11/12/2017 - Ajuste lentidao no programa crps620, CRM - 339 digidoc (Oscar).    
                     
                     
                21/05/2018 - sctask0014409 Batimento de termos desativado temporariamente 
                             na opção todos (Carlos).
                20/04/2018 - Incluir novos documentos para batime1nto de digitalizaçao.
                             Projeto 414 - Regulatório FATCA/CRS (Marcelo Telles Coelho - Mouts).

				26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

                06/06/2018 - SCTASK0016914 Na rotina efetua_batimento_ged_cadastro quando,
                             chamada pelo crps620, verifica os documentos digitalizados do
                             dia apenas (Carlos)
							 
				06/08/2018 - Adicionando novos documentos (132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 167, 168, 169). (RITM0021012 - Kelvin)

                11/06/2018 - No cursor crapbdt filtrar data de liberação que não seja null

                16/10/2018 - sctask0016914 Reativado o batimento dos termos, porém quando chamado pelo crps620, verifica apenas os termos digitalizados
                             no dia (Carlos)

				08/01/2019 - Inclusao do documento 207 (Andrey Formigari - Mouts)

			    08/01/2019 - Incluso tratativa para não gerar pendencia de emprestimos do novo CDC (Daniel).
				
				08/01/2019 - Incluso tratativa para não gerar pendencia de borderos inclusos no IB com
				             valor inferior ao parametro de assinatura (Daniel).				  
				  
                09/09/2019 - P438 - Inclusao da origem 10 (MOBILE) no filtro dos cursores de emprestimos
                            (Douglas Pagel/AMcom)
				  

.............................................................................*/


/*................................ DEFINICOES ...............................*/

{ sistema/generico/includes/b1wgen0137tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i } 

DEF STREAM str_1.
DEF STREAM str_2.

DEF VAR i             AS INTE                                         NO-UNDO.
DEF VAR j             AS INTE                                         NO-UNDO.
                                                                   
DEF VAR aux_cdcritic  AS INTE                                         NO-UNDO.

DEF VAR aux_dscritic  AS CHAR                                         NO-UNDO.
DEF VAR aux_dsderror  AS CHAR                                         NO-UNDO.
DEF VAR aux_dsreturn  AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqlog  AS CHAR                                         NO-UNDO.
DEF VAR aux_msgenvio  AS CHAR                                         NO-UNDO.
DEF VAR aux_msgreceb  AS CHAR                                         NO-UNDO.

DEF VAR rel_dsagenci  AS CHAR                                         NO-UNDO.

DEF VAR aux_cdacesso  AS CHAR                                         NO-UNDO.
DEF VAR aux_valordig  AS DEC                                          NO-UNDO.

DEF VAR aux_dataorig  AS DATE                                         NO-UNDO.

DEF BUFFER b-crapbdt  FOR crapbdt.
DEF BUFFER b-crapepr  FOR crapepr.
DEF BUFFER b-crapbdc  FOR crapbdc.
DEF BUFFER b-craplim  FOR craplim.
DEF BUFFER b-crapdoc  FOR crapdoc.
DEF BUFFER b-crapadt  FOR crapadt.

/** Retorno XML **/
DEF VAR aux_nrdconta  AS INTE                                         NO-UNDO.
DEF VAR aux_nrctrato  AS INTE                                         NO-UNDO.
DEF VAR aux_nrborder  AS INTE                                         NO-UNDO.
DEF VAR aux_cdcooper  AS INTE                                         NO-UNDO.
DEF VAR aux_cdagenci  AS INTE                                         NO-UNDO.
DEF VAR aux_tpdocmto  AS INTE                                         NO-UNDO.
DEF VAR aux_nraditiv  AS INTE                                         NO-UNDO.
DEF VAR aux_dtpublic  AS DATE                                         NO-UNDO.
DEF VAR aux_nrcpfcgc  AS DECI                                         NO-UNDO.

/* Controle de data */
DEFINE VAR aux_dtinidoc AS DATE                                       NO-UNDO.
DEFINE VAR aux_dtfimdoc AS DATE                                       NO-UNDO.

/** Objetos Mensagem XML-SOAP **/
DEF VAR hXmlSoap      AS HANDLE                                       NO-UNDO.
DEF VAR hXmlEnvelope  AS HANDLE                                       NO-UNDO.
DEF VAR hXmlHeader    AS HANDLE                                       NO-UNDO.
DEF VAR hXmlBody      AS HANDLE                                       NO-UNDO.
DEF VAR hXmlAutentic  AS HANDLE                                       NO-UNDO.
DEF VAR hXmlMetodo    AS HANDLE                                       NO-UNDO.
DEF VAR hXmlRootSoap  AS HANDLE                                       NO-UNDO.
DEF VAR hXmlNode1Soap AS HANDLE                                       NO-UNDO.
DEF VAR hXmlNode2Soap AS HANDLE                                       NO-UNDO.
DEF VAR hXmlTagSoap   AS HANDLE                                       NO-UNDO.
DEF VAR hXmlTextSoap  AS HANDLE                                       NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                          NO-UNDO.
DEF VAR par_loginusr AS CHAR                                          NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                          NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                          NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                          NO-UNDO.
DEF VAR par_numipusr AS CHAR                                          NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                        NO-UNDO.

/*................................. FUNCTIONS ...............................*/


FUNCTION cria-tag RETURNS LOGICAL (INPUT par_dsnomtag AS CHAR,
                                   INPUT par_dsvaltag AS CHAR,
                                   INPUT par_dstpdado AS CHAR,
                                   INPUT par_handnode AS HANDLE):

    hXmlSoap:CREATE-NODE(hXmlTagSoap,par_dsnomtag,"ELEMENT").
    par_handnode:APPEND-CHILD(hXmlTagSoap).

    hXmlSoap:CREATE-NODE(hXmlTextSoap,"","TEXT").
    hXmlTagSoap:APPEND-CHILD(hXmlTextSoap).
    hXmlTextSoap:NODE-VALUE = par_dsvaltag.

    RETURN TRUE.            

END FUNCTION.

/*............................ PROCEDURES EXTERNAS ..........................*/

/*****************************************************************************/
/**  Procedure que controla o batimento das informacoes e envio para coop   **/
/*****************************************************************************/
PROCEDURE efetua_batimento_ged:
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_datainic AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_datafina AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_emailbat AS CHAR        NO-UNDO.
    DEFINE INPUT  PARAMETER par_inchamad AS INTE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_tipopcao AS INTE        NO-UNDO.

    DEFINE OUTPUT PARAMETER par_nmarqcad AS CHAR        NO-UNDO.
    DEFINE OUTPUT PARAMETER par_nmarqcre AS CHAR        NO-UNDO.
    DEFINE OUTPUT PARAMETER par_nmarqmat AS CHAR        NO-UNDO.
    DEFINE OUTPUT PARAMETER par_nmarqter AS CHAR        NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR tt-erro.
   
    DEF VAR aux_dtcadini AS DATE                        NO-UNDO.
    DEF VAR aux_dtcreini AS DATE                        NO-UNDO.
    DEF VAR aux_dtcadfim AS DATE                        NO-UNDO.
    DEF VAR aux_dtcrefim AS DATE                        NO-UNDO.
    DEF VAR aux_dtterini AS DATE                        NO-UNDO.
    DEF VAR aux_dtterfim AS DATE                        NO-UNDO.
    DEF VAR aux_contador AS INTE                        NO-UNDO.
    DEF VAR aux_dtvalida AS DATE                        NO-UNDO.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsderror = ""
           aux_dsreturn = "NOK".
    
    /* VERIFICA SE A COOPERATIVA EXISTE */
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651.
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 1,
                           INPUT 1,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 13.
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 1,
                           INPUT 1,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

    /* NAO RODAR EM FINAIS DE SEMANA E FERIADOS */
    IF  CAN-DO("1,7",STRING(WEEKDAY(TODAY)))   OR
        CAN-FIND(crapfer WHERE crapfer.cdcooper = crapcop.cdcooper AND
                               crapfer.dtferiad = TODAY) THEN
        RETURN "OK".
   
    
    /* VERIFICA SE OCORREU ALGUM ERRO */
    IF  aux_cdcritic <> 0 THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 1,
                           INPUT 1,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

    /* VERIFICA SE TROCOU O MES */
    IF MONTH(crapdat.dtmvtolt) <> MONTH(crapdat.dtmvtoan) THEN
        DO TRANSACTION:
            DO aux_contador = 1 TO 10: 
            
                FIND craptab WHERE
                    craptab.cdcooper = crapcop.cdcooper AND
                    craptab.nmsistem = "CRED"           AND
                    craptab.tptabela = "GENERI"         AND
                    craptab.cdempres = 00               AND
                    craptab.cdacesso = "DIGITACOOP"     AND
                    craptab.tpregist = 0 EXCLUSIVE-LOCK NO-ERROR.
                
                IF NOT AVAIL craptab THEN
                    IF LOCKED craptab THEN
                        DO:
                            aux_cdcritic = 77.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            aux_cdcritic = 55.
                            LEAVE.
                        END.
                
                aux_cdcritic = 0.
                LEAVE.
            END.
            
            IF aux_cdcritic <> 0 THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 1,
                                   INPUT 1,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
        
                    RETURN "NOK".
                END.
        END.
    
    /* VERIFICA SE A CHAMADA FOI ATRAVES DE CRPS OU TELA */
    IF par_inchamad = 0 THEN /* CRPS */
        DO:
            /* CONSULTA CRAPTAB PARA CONSULTAR DATAS P/ O INICIO DO BATIMENTO */
            FIND craptab WHERE  craptab.cdcooper = crapcop.cdcooper AND
                                craptab.nmsistem = "CRED"           AND
                                craptab.tptabela = "GENERI"         AND
                                craptab.cdempres = 00               AND
                                craptab.cdacesso = "DIGITACOOP"     AND
                                craptab.tpregist = 0  NO-LOCK NO-ERROR.
        
            /* SE EXISTE REGISTROS, CONSULTA DATAS DE CADASTRO E CREDITO P/ GERAR O RELATORIO */
            IF  AVAIL craptab  THEN
                DO:
                    ASSIGN aux_dtcadini = DATE(ENTRY(2,craptab.dstextab,";"))
                           aux_dtcreini = DATE(ENTRY(3,craptab.dstextab,";"))
                           aux_dtterini = DATE(ENTRY(4,craptab.dstextab,";"))
                           aux_dtcadfim = TODAY
                           aux_dtcrefim = TODAY
                           aux_dtterfim = TODAY.
                END.

            /* Batimento dos termos via crps fixado */
            ASSIGN aux_dtterini = TODAY.

        END.
    ELSE /* TELA */
        ASSIGN aux_dtcadini = par_datainic
               aux_dtcreini = par_datainic
               aux_dtterini = par_datainic
               aux_dtcadfim = par_datafina
               aux_dtcrefim = par_datafina               
               aux_dtterfim = par_datafina.
    
    /* VERIFICA QUAL BATIMENTO DEVE SER REALIZADO */
    IF  par_tipopcao = 0 THEN /** TODOS **/
        DO:
            RUN efetua_batimento_ged_cadastro(INPUT crapcop.cdcooper,
                                              INPUT aux_dtcadini,
                                              INPUT aux_dtcadfim,
                                              INPUT par_inchamad,
                                              INPUT par_emailbat,
                                             OUTPUT par_nmarqcad,
                                             OUTPUT TABLE tt-erro).

            IF  RETURN-VALUE <> "OK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                    IF  AVAIL tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        DO:
                            ASSIGN aux_dscritic = "Erro ao listar documentos digitalizados no Smartshare.".
                            
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT 1,
                                           INPUT 1,
                                           INPUT 1, /* SEQUENCIA */
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                        END.
            
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - " + "crps620" + "' --> '"  + " b1wgen00137 " +
                                      aux_dscritic + " >> /usr/coop/cecred/log/proc_batch.log").
                    RETURN "NOK".
                END. 

            RUN efetua_batimento_ged_matricula(INPUT crapcop.cdcooper,
                                               INPUT aux_dtcadini,
                                               INPUT aux_dtcadfim,
                                               INPUT par_inchamad,
                                               INPUT par_emailbat,
                                              OUTPUT par_nmarqmat,
                                              OUTPUT TABLE tt-erro).
            
            IF  RETURN-VALUE <> "OK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                    IF  AVAIL tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        DO:
                            ASSIGN aux_dscritic = "Erro ao listar documentos digitalizados no Smartshare.".
                            
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT 1,
                                           INPUT 1,
                                           INPUT 1, /* SEQUENCIA */
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                        END.
            
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - " + "crps620" + "' --> '"  + " b1wgen00137 " +
                                      aux_dscritic + " >> /usr/coop/cecred/log/proc_batch.log").
                    RETURN "NOK".
                END. 

            /* Tela prcged */
            IF  par_inchamad = 1 THEN 
                DO:
            RUN efetua_batimento_ged_credito(INPUT crapcop.cdcooper,
                                             INPUT aux_dtcreini,
                                             INPUT aux_dtcrefim,
                                             INPUT par_inchamad,
                                             INPUT par_emailbat,
                                            OUTPUT par_nmarqcre,
                                            OUTPUT TABLE tt-erro).

            IF  RETURN-VALUE <> "OK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                    IF  AVAIL tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        DO:
                            ASSIGN aux_dscritic = "Erro ao listar documentos digitalizados no Smartshare.".
                            
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT 1,
                                           INPUT 1,
                                           INPUT 1, /* SEQUENCIA */
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                        END.
            
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - " + "crps620" + "' --> '"  + " b1wgen00137 " +
                                      aux_dscritic + " >> /usr/coop/cecred/log/proc_batch.log").
                    RETURN "NOK".
                END. 
            END. /* tela prcged */

             RUN efetua_batimento_ged_termos(INPUT crapcop.cdcooper,
                                             INPUT aux_dtterini,
                                             INPUT aux_dtterfim,
                                             INPUT par_inchamad,
                                             INPUT par_emailbat,
                                            OUTPUT par_nmarqter,
                                            OUTPUT TABLE tt-erro).

            IF  RETURN-VALUE <> "OK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                    IF  AVAIL tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        DO:
                            ASSIGN aux_dscritic = "Erro ao listar documentos digitalizados no Smartshare.".
                            
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT 1,
                                           INPUT 1,
                                           INPUT 1, /* SEQUENCIA */
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                        END.
            
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - " + "crps620" + "' --> '"  + " b1wgen00137 " +
                                      aux_dscritic + " >> /usr/coop/cecred/log/proc_batch.log").
                    RETURN "NOK".
                END. 

        END. /* Batimento par_tipopcao = 0 (TODOS) */
    ELSE IF  par_tipopcao = 1 THEN /* CADASTRO */
        DO:
            
            RUN efetua_batimento_ged_cadastro(INPUT crapcop.cdcooper,
                                              INPUT aux_dtcadini,
                                              INPUT aux_dtcadfim,
                                              INPUT par_inchamad,
                                              INPUT par_emailbat,
                                             OUTPUT par_nmarqcad,
                                             OUTPUT TABLE tt-erro).
            
            IF  RETURN-VALUE <> "OK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                    IF  AVAIL tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        DO:
                            ASSIGN aux_dscritic = "Erro ao listar documentos digitalizados no Smartshare.".
                            
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT 1,
                                           INPUT 1,
                                           INPUT 1, /* SEQUENCIA */
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                        END.
            
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - " + "crps620" + "' --> '"  + " b1wgen00137 " +
                                      aux_dscritic + " >> /usr/coop/cecred/log/proc_batch.log").
                    RETURN "NOK".
                END. 
        END.
    ELSE IF par_tipopcao = 2 THEN /* CREDITO */
        DO: 
            /* Tela prcged */
            IF  par_inchamad = 1 THEN 
                DO:
            RUN efetua_batimento_ged_credito(INPUT crapcop.cdcooper,
                                             INPUT aux_dtcreini,
                                             INPUT aux_dtcrefim,
                                             INPUT par_inchamad,
                                             INPUT par_emailbat,
                                            OUTPUT par_nmarqcre,
                                            OUTPUT TABLE tt-erro).

            IF  RETURN-VALUE <> "OK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                    IF  AVAIL tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        DO:
                            ASSIGN aux_dscritic = "Erro ao listar documentos digitalizados no Smartshare.".
                            
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT 1,
                                           INPUT 1,
                                           INPUT 1, /* SEQUENCIA */
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                        END.
            
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - " + "crps620" + "' --> '"  + " b1wgen00137 " +
                                      aux_dscritic + " >> /usr/coop/cecred/log/proc_batch.log").
                    RETURN "NOK".
                END. 
        END.
        END.
    ELSE
    IF  par_tipopcao = 3 THEN /* MATRICULA */
        DO:
            RUN efetua_batimento_ged_matricula(INPUT crapcop.cdcooper,
                                               INPUT aux_dtcadini,
                                               INPUT aux_dtcadfim,
                                               INPUT par_inchamad,
                                               INPUT par_emailbat,
                                              OUTPUT par_nmarqmat,
                                              OUTPUT TABLE tt-erro).

            IF  RETURN-VALUE <> "OK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                    IF  AVAIL tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        DO:
                            ASSIGN aux_dscritic = "Erro ao listar documentos digitalizados no Smartshare.".
                            
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT 1,
                                           INPUT 1,
                                           INPUT 1, /* SEQUENCIA */
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                        END.
            
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - " + "crps620" + "' --> '"  + " b1wgen00137 " +
                                      aux_dscritic + " >> /usr/coop/cecred/log/proc_batch.log").
                    RETURN "NOK".
                END. 
        END.
    ELSE IF  par_tipopcao = 4 THEN /* TERMO */
        DO:
            RUN efetua_batimento_ged_termos(INPUT crapcop.cdcooper,
                                            INPUT aux_dtterini,
                                            INPUT aux_dtterfim,
                                            INPUT par_inchamad,
                                            INPUT par_emailbat,
                                           OUTPUT par_nmarqter,
                                           OUTPUT TABLE tt-erro).
            
            IF  RETURN-VALUE <> "OK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                    IF  AVAIL tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        DO:
                            ASSIGN aux_dscritic = "Erro ao listar documentos digitalizados no Smartshare.".
                            
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT 1,
                                           INPUT 1,
                                           INPUT 1, /* SEQUENCIA */
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                        END.
            
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - " + "crps620" + "' --> '"  + " b1wgen00137 " +
                                      aux_dscritic + " >> /usr/coop/cecred/log/proc_batch.log").
                    RETURN "NOK".
                END.
        END.
    
    RETURN "OK".

END PROCEDURE.

/** GERA RELATORIO COM PENDENCIAS DE DOCUMENTOS DE MATRICULA **/
PROCEDURE efetua_batimento_ged_matricula:

    DEFINE INPUT PARAMETER par_cdcooper AS INTEGER                     NO-UNDO.
    DEFINE INPUT PARAMETER par_datainic AS DATE                        NO-UNDO.
    DEFINE INPUT PARAMETER par_datafina AS DATE                        NO-UNDO.
    DEFINE INPUT PARAMETER par_inchamad AS INTEGER                     NO-UNDO.
    DEFINE INPUT PARAMETER par_emailbat AS CHAR                        NO-UNDO.
    DEFINE OUTPUT PARAMETER par_nmarqmat AS CHAR                       NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEF        VAR tot_nrmatric AS INT     FORMAT "zz9"                NO-UNDO.
    DEF        VAR aux_flgfirst AS LOGICAL                             NO-UNDO.
    DEF        VAR aux_nmoperad AS CHAR    FORMAT "x(30)"              NO-UNDO.
    DEF        VAR par_dtmvtolt AS DATE INIT TODAY                     NO-UNDO.

    DEF        VAR aux_nmarqmat AS CHAR                                NO-UNDO.
    DEF        VAR aux_nmarqica AS CHAR                                NO-UNDO.
    DEF        VAR aux_data     AS DATE                                NO-UNDO.
    DEF        VAR aux_nmarqpca AS CHAR                                NO-UNDO.
    
    DEF        VAR h-b1wgen0011 AS HANDLE                              NO-UNDO.
    DEF        VAR h-b1wgen0024 AS HANDLE                              NO-UNDO.

    FORM "DOCUMENTOS NAO DIGITALIZADOS - MATRICULAS" AT 32
         SKIP(2)
         WITH WIDTH 132 NO-BOX NO-LABEL SIDE-LABELS FRAME f_dados_cab.
    
    FORM tt-documentos-matric.cdagenci AT 01 LABEL "PA "
         tt-documentos-matric.nrmatric AT 05 LABEL "MATRICULA"
         tt-documentos-matric.nrdconta AT 15 LABEL "CONTA/DV"
         tt-documentos-matric.inpessoa AT 26 LABEL "TIPO"
         tt-documentos-matric.nmprimtl AT 31 LABEL "NOME"
         tt-documentos-matric.dtmvtolt AT 72 LABEL "DATA"
         aux_nmoperad                  AT 83 LABEL "OPERADOR"
         WITH CENTERED NO-BOX DOWN WIDTH 132 FRAME f_dados_matric.

    EMPTY TEMP-TABLE tt-documentos-matric.
    
   DO  aux_data = par_datainic TO par_datafina:
       
       /*** Leitura de documentos nao digitaliados ***/
       FOR EACH crapdoc FIELDS(cdcooper nrdconta dtmvtolt nrcpfcgc)  WHERE 
                               crapdoc.cdcooper = par_cdcooper AND
                               crapdoc.dtmvtolt = aux_data     AND
                               crapdoc.tpdocmto = 8            AND
                               crapdoc.flgdigit = FALSE
                              USE-INDEX crapdoc3 NO-LOCK:

           FIND crapass WHERE crapass.cdcooper = crapdoc.cdcooper AND
                              crapass.nrdconta = crapdoc.nrdconta
                              NO-LOCK NO-ERROR.

           IF  NOT AVAIL crapass THEN 
               NEXT.

           IF  crapass.dtdemiss <> ? THEN
               NEXT.

           FIND FIRST crapneg  WHERE 
                               crapneg.cdcooper = crapdoc.cdcooper AND
                               crapneg.dtiniest = aux_data         AND
                               crapneg.nrdconta = crapdoc.nrdconta AND
                               crapneg.cdhisest = 0 
                               USE-INDEX crapneg6 NO-LOCK NO-ERROR.

           IF  AVAIL crapneg THEN
               DO:
                   CREATE tt-documentos-matric.
                   ASSIGN tt-documentos-matric.cdagenci = crapass.cdagenci
                          tt-documentos-matric.nrmatric = crapass.nrmatric
                          tt-documentos-matric.nrdconta = crapass.nrdconta
                          tt-documentos-matric.inpessoa = IF crapass.inpessoa = 1 THEN
                                                             " PF"
                                                          ELSE " PJ"
                          tt-documentos-matric.nmprimtl = crapass.nmprimtl
                          tt-documentos-matric.dtmvtolt = crapdoc.dtmvtolt
                          tt-documentos-matric.cdoperad = STRING(crapneg.cdoperad)
                          tt-documentos-matric.nrcpfcgc = STRING(crapdoc.nrcpfcgc).
                END.
       END. /* Fim do FOR crapdoc */

   END. /* Fim do DO  aux_data */

   /* Comentado este trecho do codigo em virtude do chamado 342958
   /* Verificar se tem alguma alteracao */
   FOR EACH tt-documentos-matric EXCLUSIVE-LOCK:

       FIND FIRST crapalt WHERE crapalt.cdcooper = par_cdcooper                  AND
                                crapalt.nrdconta = tt-documentos-matric.nrdconta 
                                NO-LOCK NO-ERROR.

       IF  AVAIL crapalt THEN
           ASSIGN tt-documentos-matric.dtmvtolt = crapalt.dtaltera
                  tt-documentos-matric.cdoperad = STRING(crapalt.cdoperad).
       ELSE
           NEXT.

   END.
   */

   FIND FIRST tt-documentos-matric NO-LOCK NO-ERROR.

   IF  NOT AVAIL tt-documentos-matric THEN
       NEXT.

   { sistema/generico/includes/b1cabrelvar.i }

   IF   par_inchamad = 0   THEN /* crps */
        DO:         
            FOR EACH tt-documentos-matric NO-LOCK  
                     BREAK BY tt-documentos-matric.cdagenci         
                           BY tt-documentos-matric.nrmatric         
                           BY tt-documentos-matric.nrdconta:        
                                                                                          
                IF  FIRST-OF (tt-documentos-matric.cdagenci)   THEN
                    DO: 
                        FIND crapage WHERE 
                             crapage.cdcooper = par_cdcooper   AND
                             crapage.cdagenci = tt-documentos-matric.cdagenci 
                              NO-LOCK NO-ERROR.
                    
                        rel_dsagenci = "PA: " + 
                                       STRING(tt-documentos-matric.cdagenci,"zzz9") + " - ".
            
                        IF  AVAIL crapage THEN
                            rel_dsagenci = rel_dsagenci + crapage.nmresage.
                        ELSE
                            rel_dsagenci = rel_dsagenci + "*** PA NAO CADASTRADO ***".
                        
                        ASSIGN aux_nmarqmat = "/usr/coop/" + crapcop.dsdircop + 
                                              "/rl/" + "crrl620_matric_" + 
                                              STRING(tt-documentos-matric.cdagenci,"999") +
                                              ".lst". 
                        
                        OUTPUT STREAM str_1 TO VALUE (aux_nmarqmat) PAGED PAGE-SIZE 80.                                            

                        DISP STREAM str_1 WITH FRAME f_dados_cab.
                    END.

                IF  tt-documentos-matric.cdoperad <> "" THEN                             
                    DO:                                                                  
                        FIND crapope WHERE                                               
                                     crapope.cdcooper = par_cdcooper              AND    
                                     crapope.cdoperad = tt-documentos-matric.cdoperad    
                                     NO-LOCK NO-ERROR.                                   
                                                                                         
                        IF  NOT AVAILABLE crapope THEN                                   
                            ASSIGN aux_nmoperad = "".                                    
                        ELSE                                                             
                            ASSIGN aux_nmoperad = crapope.nmoperad.                      
                    END.                                                                 
                ELSE                                                                     
                    ASSIGN aux_nmoperad = "".                                            
                                                                                      
                IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN                        
                    PAGE STREAM str_1.    

                DISPLAY STREAM str_1 tt-documentos-matric.cdagenci
                                     tt-documentos-matric.nrmatric
                                     tt-documentos-matric.nrdconta
                                     tt-documentos-matric.inpessoa
                                     tt-documentos-matric.nmprimtl
                                     tt-documentos-matric.dtmvtolt
                                     aux_nmoperad                 
                                     WITH FRAME f_dados_matric.   
                                                                   
                DOWN STREAM str_1 WITH FRAME f_dados_matric.       
            
                IF   LAST-OF(tt-documentos-matric.cdagenci)   THEN
                     DO:
                         OUTPUT STREAM str_1 CLOSE.

                         UNIX SILENT VALUE("cp " + aux_nmarqmat + 
                                           " /usr/coop/" +
                                           crapcop.dsdircop + "/salvar").
                     END.

            END.

        END.

    /**********************************************************************/
    /******************** RELATORIO DE TODOS OS PAs ***********************/
    /**********************************************************************/

   /* GERAR RELATORIO DE NAO DIGITALIZADO PARA ENVIAR PARA COOPERATIVA 
       (PARAMETRO NA TAB093) */
   
   IF par_inchamad = 1 THEN /* TELA */
       ASSIGN aux_nmarqmat = "crrl620_matric_999.txt".
   ELSE
       ASSIGN aux_nmarqmat = "crrl620_matric_999.lst".

   ASSIGN par_nmarqmat = "/usr/coop/" + crapcop.dsdircop + 
                          "/rl/" + aux_nmarqmat
           
           aux_nmarqica = "/micros/" + crapcop.dsdircop + "/crrl620_matric_" + 
                          STRING(YEAR(par_datafina), "9999") + "-" +
                          STRING(MONTH(par_datafina), "99") +  "-" +
                          STRING(DAY(par_datafina), "99") + "-" + 
                          STRING(TIME) + ".txt".
   
   OUTPUT STREAM str_1 TO VALUE (par_nmarqmat) PAGED PAGE-SIZE 84.

   { sistema/generico/includes/b1cabrel132.i "11" "620" }
     
   DISP STREAM str_1 WITH FRAME f_dados_cab.

   FOR  EACH tt-documentos-matric NO-LOCK 
                                  BREAK BY tt-documentos-matric.cdagenci
                                        BY tt-documentos-matric.nrmatric
                                        BY tt-documentos-matric.nrdconta:
        
        IF  tt-documentos-matric.cdoperad <> "" THEN
            DO:
                FIND crapope WHERE 
                             crapope.cdcooper = par_cdcooper              AND
                             crapope.cdoperad = tt-documentos-matric.cdoperad 
                             NO-LOCK NO-ERROR.
               
                IF  NOT AVAILABLE crapope THEN
                    ASSIGN aux_nmoperad = "".
                ELSE
                    ASSIGN aux_nmoperad = crapope.nmoperad.
            END.
        ELSE 
            ASSIGN aux_nmoperad = "".

        IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
            PAGE STREAM str_1.

        DISPLAY STREAM str_1  tt-documentos-matric.cdagenci
                              tt-documentos-matric.nrmatric
                              tt-documentos-matric.nrdconta
                              tt-documentos-matric.inpessoa
                              tt-documentos-matric.nmprimtl
                              tt-documentos-matric.dtmvtolt
                              aux_nmoperad
                              WITH FRAME f_dados_matric.

        DOWN STREAM str_1 WITH FRAME f_dados_matric.

   END. /* Fim do for  each tt-documentos-matric */

   OUTPUT STREAM str_1 CLOSE.

    IF  par_inchamad = 1  THEN /* Tela */
        DO:
            FIND craprel WHERE craprel.cdcooper = par_cdcooper AND
                               craprel.cdrelato = 620 
                               EXCLUSIVE-LOCK NO-ERROR.
     
            IF  AVAIL craprel   THEN
                ASSIGN craprel.ingerpdf = 2. /* Nao gera PDF */

            UNIX SILENT VALUE("cp " + par_nmarqmat + " /usr/coop/" + 
                        crapcop.dsdircop + "/converte/crrl620_matric_999.txt").
           
            /* Envia o arquivo gerado por email */
            RUN sistema/generico/procedures/b1wgen0011.p 
                PERSISTENT SET h-b1wgen0011.
            
            RUN enviar_email_completo IN h-b1wgen0011 
                                     (INPUT crapcop.cdcooper,
                                      INPUT "b1wgen00137",
                                      INPUT "AILOS<ailos@ailos.coop.br>",
                                      INPUT par_emailbat,
                                      INPUT "Rel.620 - RELACAO DE DOCUMENTOS"+
                                            " DE MATRICULAS NAO DIGITALIZADOS",
                                      INPUT "",
                                      INPUT "crrl620_matric_999.txt",
                                      INPUT "\nSegue anexo o Relatorio crrl620 " +
                                            "da Cooperativa " + crapcop.nmrescop,
                                      INPUT TRUE).

            DELETE PROCEDURE h-b1wgen0011.
        END.
    ELSE
        DO: 
            /* copia relatorio para "/usr/coop/COOPERATIVA/rlnsv/ARQ.lst"  */
            UNIX SILENT VALUE("cp " + par_nmarqmat + " /usr/coop/" + 
                              crapcop.dsdircop + 
                              "/rlnsv/" + aux_nmarqmat).

            FIND craptab WHERE  craptab.cdcooper = crapcop.cdcooper AND
                                craptab.nmsistem = "CRED"           AND
                                craptab.tptabela = "GENERI"         AND
                                craptab.cdempres = 00               AND
                                craptab.cdacesso = "DIGITEMAIL"     AND
                                craptab.tpregist = 0  NO-LOCK NO-ERROR.
    
            IF  AVAIL craptab  THEN
                DO:
                    FIND craprel WHERE craprel.cdcooper = par_cdcooper AND
                                       craprel.cdrelato = 620 
                                       EXCLUSIVE-LOCK NO-ERROR.
     
                    IF  AVAIL craprel   THEN 
                        ASSIGN craprel.ingerpdf = 1. /* Gera PDF */
                    
                    IF (SUBSTRING(craptab.dstextab, 1, 1) = "S") THEN 
                        DO:
                            ASSIGN aux_nmarqpca = "/usr/coop/" + 
                                   crapcop.dsdircop + 
                                   "/converte/crrl620_matric_999.pdf".
                
                            RUN sistema/generico/procedures/b1wgen0024.p 
                                PERSISTENT SET h-b1wgen0024.
                
                            RUN gera-pdf-impressao IN h-b1wgen0024 
                                                  (INPUT par_nmarqmat,
                                                   INPUT aux_nmarqpca).
                           
                            DELETE PROCEDURE h-b1wgen0024.
                            
                            /* Envia o arquivo gerado por email */
                            RUN sistema/generico/procedures/b1wgen0011.p 
                                PERSISTENT SET h-b1wgen0011.
                            
                            RUN enviar_email_completo IN h-b1wgen0011 
                               (INPUT crapcop.cdcooper,
                                INPUT "b1wgen00137",
                                INPUT "AILOS<ailos@ailos.coop.br>",
                                INPUT ENTRY(3,craptab.dstextab,";"),
                                INPUT "Rel.620 - RELACAO DE DOCUMENTOS"+
                                      " DE MATRICULAS NAO DIGITALIZADOS",
                                INPUT "",
                                INPUT "crrl620_matric_999.pdf",
                                INPUT "\nSegue anexo o Relatorio crrl620 " +
                                      "da Cooperativa " + crapcop.nmrescop,
                                INPUT TRUE).
                
                            DELETE PROCEDURE h-b1wgen0011.
                            
                        END.
                END.
            ELSE
                DO:
                    
                    ASSIGN aux_dscritic = "Nao foi possivel encontrar" + 
                                          " parametros em DIGITEMAIL.".
            
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - " + "crps620" + "' --> '" + " b1wgen00137 " +
                                      aux_dscritic + " >> /usr/coop/cecred/log/proc_batch.log").
                    RETURN "NOK".
                END.
        END.
 
    RETURN "OK". 

END.

/* GERA RELATORIO COM PENDENCIAS DE DOCUMENTOS DE CADASTRO NAO DIGITALIZADOS */
PROCEDURE efetua_batimento_ged_cadastro:
    
    DEFINE INPUT PARAMETER par_cdcooper AS INTEGER      NO-UNDO.
    DEFINE INPUT PARAMETER par_datainic AS DATE         NO-UNDO.
    DEFINE INPUT PARAMETER par_datafina AS DATE         NO-UNDO.
    DEFINE INPUT PARAMETER par_inchamad AS INTEGER      NO-UNDO.
    DEFINE INPUT PARAMETER par_emailbat AS CHAR         NO-UNDO.
    DEFINE OUTPUT PARAMETER par_nmarqcad AS CHAR        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEF VAR aux_idseqite AS INT                         NO-UNDO.
    DEF VAR aux_contdocs AS INT                         NO-UNDO.
    DEF VAR aux_conttabs AS INT                         NO-UNDO.
    DEF VAR aux_nmarquca AS CHAR                        NO-UNDO.
    DEF VAR aux_nmarqcad AS CHAR                        NO-UNDO.
    DEF VAR aux_nmarqica AS CHAR                        NO-UNDO.
    DEF VAR aux_totcontr AS INT                         NO-UNDO.
    DEF VAR aux_titrelat AS CHAR                        NO-UNDO.
    DEF VAR aux_nmarqpca AS CHAR                        NO-UNDO.
    DEF VAR aux_contagen AS INT  INIT 0                 NO-UNDO.
    DEF VAR par_dtmvtolt AS DATE INIT TODAY             NO-UNDO.
    
    DEF VAR aux_data     AS DATE                        NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                      NO-UNDO.
    DEF VAR h-b1wgen0011 AS HANDLE                      NO-UNDO.
    DEF BUFFER b-tt-contr_ndigi_cadastro  FOR tt-contr_ndigi_cadastro.

    FORM "DOCUMENTOS NAO DIGITALIZADOS" AT 20
         "-"                         AT 48
         "*****************  U R G E N T E  *****************" AT 51
         WITH WIDTH 234 NO-BOX NO-LABEL SIDE-LABELS FRAME f_urgnt.

    FORM rel_dsagenci AT   1 FORMAT "x(100)" NO-LABEL
         WITH WIDTH 234 NO-BOX NO-LABEL SIDE-LABELS FRAME f_pac.
   
    FORM SKIP(1)
         aux_titrelat AT 58 FORMAT "x(45)" 
         SKIP(2)
         "PROCURADOR / TITULAR"     AT 83 
        "-------------------------------------------------------------------------"
         AT 58
         WITH WIDTH 234 NO-BOX NO-LABEL SIDE-LABELS CENTERED FRAME f_dados_contr_2.
   
    FORM tt-contr_ndigi_cadastro.nrdconta  FORMAT "zzzz,zz9,9" COLUMN-LABEL "Conta/DV"
         tt-contr_ndigi_cadastro.tppessoa  FORMAT "x(4)"       COLUMN-LABEL "Tipo"
         tt-contr_ndigi_cadastro.tpdocreg  FORMAT "x(15)"      COLUMN-LABEL "Doc. Ident - PF"
         tt-contr_ndigi_cadastro.tpdoccen  FORMAT "x(15)"      COLUMN-LABEL "   Comp. End   "
         tt-contr_ndigi_cadastro.tpdoccec  FORMAT "x(14)"      COLUMN-LABEL "  Est. Civil  "
         tt-contr_ndigi_cadastro.tpdoccre  FORMAT "x(14)"      COLUMN-LABEL "  Comp. Rend  "
         tt-contr_ndigi_cadastro.tpdoccas  FORMAT "x(14)"      COLUMN-LABEL "  Cta. Assin. "
         tt-contr_ndigi_cadastro.tpdocfca  FORMAT "x(14)"      COLUMN-LABEL " Ficha Cadas. "
         tt-contr_ndigi_cadastro.tpdocdip  FORMAT "x(18)"      COLUMN-LABEL "Doc. Ident. - Proc"
         tt-contr_ndigi_cadastro.tpdocctc  FORMAT "x(14)"      COLUMN-LABEL "  Cta. CNPJ   "
         tt-contr_ndigi_cadastro.tpdocidp  FORMAT "x(15)"      COLUMN-LABEL "Doc. Ident - PJ"
         tt-contr_ndigi_cadastro.tpdocdfi  FORMAT "x(14)"      COLUMN-LABEL " Demons. Finan"
		 tt-contr_ndigi_cadastro.tpdoclic  FORMAT "x(18)"      COLUMN-LABEL "Lic. Socioambientais"
         tt-contr_ndigi_cadastro.idseqttl  FORMAT "99"         COLUMN-LABEL "   Titular   "
         tt-contr_ndigi_cadastro.dtmvtolt  FORMAT "99/99/9999" COLUMN-LABEL "    Data    "
         WITH DOWN WIDTH 234 CENTERED FRAME f_contr_2.

    FORM aux_totcontr LABEL "Quantidade Total"
         WITH DOWN NO-LABEL WIDTH 234 SIDE-LABELS FRAME f_tot_ctr.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-documento-digitalizado.
    EMPTY TEMP-TABLE tt-documentos.

    /* ALIMENTA A TABELA DE PARAMETROS */
    FOR EACH craptab FIELDS(dstextab tpregist)                 WHERE
                           craptab.cdcooper = crapcop.cdcooper AND         
                           craptab.nmsistem = "CRED"           AND         
                           craptab.tptabela = "GENERI"         AND         
                           craptab.cdempres = 00               AND         
                           craptab.cdacesso = "DIGITALIZA"
                           NO-LOCK:
                IF CAN-DO("90,91,92,93,94,95,96,97,98,99,100,101,103,107,131,132,133,134,135,136,137,138,139,140,141,145,146,147,148,149,150,151,152,159,162,163,167,168,169,171,172,173,174,175,176,177", ENTRY(3,craptab.dstextab,";")) THEN
            DO:
                CREATE tt-documentos.
                ASSIGN tt-documentos.vldparam = DECI(ENTRY(2,craptab.dstextab,";"))
                       tt-documentos.nmoperac = ENTRY(1,craptab.dstextab,";")
                       tt-documentos.tpdocmto = INTE(ENTRY(3,craptab.dstextab,";"))
                       tt-documentos.idseqite = craptab.tpregist.
            END.

    END.

    /* Chamado pelo CRPS, pegar digitalizados apenas do dia */
    IF par_inchamad = 0 THEN
    DO:
      ASSIGN aux_dtinidoc = TODAY
             aux_dtfimdoc = TODAY.
    END.
    ELSE
    DO:
      /* Adicionar intervalo de data, 2 em 2 meses */
    ASSIGN aux_dtinidoc = par_datainic
           aux_dtfimdoc = ADD-INTERVAL(aux_dtinidoc,02,'months').
    END.
        
    periodo:
    DO  WHILE TRUE:

       /* CONSULTAR NO SMARTSHARE (SELBETTI) OS DOCUMENTOS QUE ESTAO DIGITALIZADOS */
       RUN lista-documentos-digitalizados(INPUT crapcop.cdcooper,
                                          INPUT aux_dtinidoc, /* DATA DE CONSULTA DE IMAGENS */
                                          INPUT aux_dtfimdoc,
                                          INPUT TABLE tt-documentos,
                                         OUTPUT TABLE tt-documento-digitalizado,
                                         OUTPUT TABLE tt-erro).   
           

          /* EM CASO DE ERRO, GERA LOG E PARTE PARA PROXIMA COOPERATIVA */
          IF RETURN-VALUE <> "OK"  THEN
              DO: 
              
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.
          
                  IF  AVAIL tt-erro  THEN
                      ASSIGN aux_dscritic = tt-erro.dscritic.
                  ELSE
                      DO:
                          ASSIGN aux_dscritic = "Erro ao listar documentos digitalizados no Smartshare.".
                          
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT 1,
                                         INPUT 1,
                                         INPUT 1, /* SEQUENCIA */
                                         INPUT aux_cdcritic,
                                         INPUT-OUTPUT aux_dscritic).
                      END.
          
                  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                    " - " + "crps620" + "' --> '"  + " b1wgen00137 " +
                                    aux_dscritic + " >> /usr/coop/cecred/log/proc_batch.log").
                  RETURN "NOK".
              END.                                     
                     
           IF  aux_dtfimdoc >= par_datafina THEN 
               LEAVE periodo.  
               
           /* Adicionar intervalo de data, 3 em 3 meses */
           ASSIGN aux_dtinidoc = ADD-INTERVAL(aux_dtfimdoc,01,'days')               
                  aux_dtfimdoc = ADD-INTERVAL(aux_dtinidoc,02,'months').
                  
           IF  aux_dtfimdoc >= TODAY THEN
               aux_dtfimdoc = TODAY.

    END. /* end do while */

        /* UTILIZADO LACO NA DATA PARA MELHORAR PERFORMANCE NAS LEITURAS */
        DO aux_data = par_datainic TO par_datafina:
            
            /* ZERAR VARIAVEIS DE CONTROLE DE PARAMETROS */ 
            
            DO aux_contdocs = 1 TO 63:
                
                ASSIGN aux_tpdocmto = 0.
    
                CASE aux_contdocs:
                    WHEN 1 THEN
                        ASSIGN aux_conttabs = 6. /* CPF - CADASTRO DE PESSOAS FISICAS*/
                    WHEN 2 THEN
                        ASSIGN aux_conttabs = 7. /*CARTEIRA IDENTIFICACAO*/
                    WHEN 3 THEN
                        ASSIGN aux_conttabs = 8. /*COMPROVANTE DE ENDERECO*/
                    WHEN 4 THEN
                        ASSIGN aux_conttabs = 9. /*COMPROVANTE DE ESTADO CIVIL*/
                    WHEN 5 THEN
                        ASSIGN aux_conttabs = 10. /*COMPROVANTE DE RENDA*/
                    WHEN 6 THEN
                        ASSIGN aux_conttabs = 11. /*CARTAO DE ASSINATURA*/
                    WHEN 7 THEN
                        ASSIGN aux_conttabs = 12. /*FICHA CADASTRAL*/
                    WHEN 8 THEN
                        ASSIGN aux_conttabs = 13. /*MATRICULA*/
                    WHEN 9 THEN
                        ASSIGN aux_conttabs = 14. /*DOCUMENTO DE IDENTIFICACAO - PROC*/
                    WHEN 10 THEN
                        ASSIGN aux_conttabs = 15. /*CARTAO DE CNPJ*/
                    WHEN 11 THEN
                        ASSIGN aux_conttabs = 16. /*DOCUMENTO DE IDENTIFICACAO - PJ*/
                    WHEN 12 THEN
                        ASSIGN aux_conttabs = 17. /*DEMONSTRATIVO FINANCEIRO*/
                    WHEN 22 THEN
                        ASSIGN aux_conttabs = 22. /*DOCUMENTO CÔNJUGE*/
                    WHEN 26 THEN
                        ASSIGN aux_conttabs = 26. /*DECLARACAO DE IMUNIDADE TRIBUTARIA*/
                    WHEN 40 THEN 
                        ASSIGN aux_conttabs = 40. /*LICENCAS SOCIO AMBIENTAIS*/
                    WHEN 45 THEN
                        ASSIGN aux_conttabs = 45. /*CONTRATO ABERTURA DE CONTA PF*/
                    WHEN 46 THEN
                        ASSIGN aux_conttabs = 46. /*CONTRATO ABERTURA DE CONTA PJ*/
                    WHEN 47 THEN
                        ASSIGN aux_conttabs = 47. /*PROCURAÇAO PF*/
                    WHEN 48 THEN
                        ASSIGN aux_conttabs = 48. /*PROCURAÇAO PJ*/
                    WHEN 49 THEN
                        ASSIGN aux_conttabs = 49. /*DOCUMENTOS PROCURADORES PJ*/
                    WHEN 50 THEN
                        ASSIGN aux_conttabs = 50. /*DOCUMENTOS PROCURADORES PF*/
                    WHEN 51 THEN
                        ASSIGN aux_conttabs = 51. /*DOCUMENTOS RESPONSAVEL LEGAL*/
                    WHEN 52 THEN
                        ASSIGN aux_conttabs = 52. /*DOCUMENTO SÓCIOS/ADMINISTRADORES*/ 
                    WHEN 54 THEN
                        ASSIGN aux_conttabs = 54. /*FICHA CADASTRAL*/
                    WHEN 55 THEN
                        ASSIGN aux_conttabs = 55. /*DECLARACAO DO SIMPLES NACIONAL*/
                    WHEN 56 THEN
                        ASSIGN aux_conttabs = 56. /*DECLARAÇAO PESSOA JURÍDICA COOPERATIVA*/
                    WHEN 58 THEN
                        ASSIGN aux_conttabs = 58. /*TERMO DE ALTERACAO DE TITULARIDADE*/
                    WHEN 59 THEN
                        ASSIGN aux_conttabs = 59. /*DOCUMENTO DE EMANCIPACAO*/
                    
                    WHEN 60 THEN
                        ASSIGN aux_conttabs = 60. /*DECLARAÇÃO DE OBRIGAÇÃO FISCAL NO EXTERIOR*//*-- Projeto 414 - Marcelo Telles Coelho - Mouts*/
                    WHEN 61 THEN
                        ASSIGN aux_conttabs = 61. /*DOCUMENTO NIF*//*-- Projeto 414 - Marcelo Telles Coelho - Mouts*/
                    WHEN 62 THEN
                        ASSIGN aux_conttabs = 62. /*DECLARAÇÃO DE OBRIGAÇÃO FISCAL NO EXTERIOR - SÓCIO*//*-- Projeto 414 - Marcelo Telles Coelho - Mouts*/
                    WHEN 63 THEN
                        ASSIGN aux_conttabs = 63. /*DOCUMENTO NIF - SÓCIO*//*-- Projeto 414 - Marcelo Telles Coelho - Mouts*/
					
					WHEN 65 THEN
                        ASSIGN aux_conttabs = 65. /*Comprovante de Renda - Admissão de Cooperados*/
					WHEN 66 THEN
                        ASSIGN aux_conttabs = 66. /*Comprovante de Endereço - Admissão de Cooperados*/
					WHEN 67 THEN
						ASSIGN aux_conttabs = 67. /*Documento de Identificação - Admissão de Cooperados*/
					WHEN 68 THEN
						ASSIGN aux_conttabs = 68. /*Comprovante de Estado Civil - Admissão de Cooperados*/
					WHEN 69 THEN
						ASSIGN aux_conttabs = 69. /*Documentos do Cônjugue - Admissão de Cooperados*/ 
					WHEN 70 THEN
						ASSIGN aux_conttabs = 70. /*Documentos de Procuradores - Admissão de Cooperados*/
					WHEN 71 THEN
						ASSIGN aux_conttabs = 71. /*Cartão de Assinatura - Admissão de Cooperados*/	 
					WHEN 72 THEN
						ASSIGN aux_conttabs = 72. /*Matrícula - Admissão de Cooperados*/
					WHEN 73 THEN
						ASSIGN aux_conttabs = 73. /*Ficha Cadastral - Admissão de Cooperados*/
					WHEN 74 THEN
						ASSIGN aux_conttabs = 74. /*Ficha de Pré-cadastro - Admissão de Cooperados*/
					WHEN 75 THEN
						ASSIGN aux_conttabs = 75. /*Demonstrativo Financeiro - Admissão de Cooperados*/
					WHEN 76 THEN
						ASSIGN aux_conttabs = 76. /*Cartão de CNPJ - Admissão de Cooperados*/
					WHEN 77 THEN
						ASSIGN aux_conttabs = 77. /*Documentos Sócios / Administradores - Admissão de Cooperados  */
						
                    OTHERWISE
                        NEXT.
                END CASE.
               
                /* Obs: As matriculas tpdocmto = 8, nao sera necessario gerar neste relatorio
                        os documentos pendentes de matriculas, pois somente iram baixar */

                FOR FIRST tt-documentos FIELDS(tpdocmto) WHERE tt-documentos.idseqite = aux_conttabs 
                                         NO-LOCK : END.
                
                IF  AVAIL tt-documentos  THEN
                    ASSIGN aux_tpdocmto = tt-documentos.tpdocmto.
                    
                /*Leitura de documentos nao digitaliados*/
                FOR EACH crapdoc FIELDS(cdcooper nrdconta tpdocmto dtmvtolt idseqttl nrcpfcgc)
                                 WHERE crapdoc.cdcooper = crapcop.cdcooper AND
                                       crapdoc.dtmvtolt = aux_data         AND
                                       crapdoc.tpdocmto = aux_contdocs     AND
                                       crapdoc.flgdigit = FALSE            AND
                                       crapdoc.tpbxapen = 0
                                       USE-INDEX crapdoc3 NO-LOCK:

                    /* Se cooperado estiver demitidos nao gera no relatorio */
                    FOR FIRST crapass FIELDS(inpessoa cdagenci dtdemiss) WHERE 
                               crapass.cdcooper = crapdoc.cdcooper AND
                               crapass.nrdconta = crapdoc.nrdconta NO-LOCK: END.

                   IF  NOT AVAIL crapass THEN 
                       NEXT.

                    IF  crapass.dtdemiss <> ? THEN
                        NEXT.
                 
                        
                    /* Verifica os documentos de cpf e rg  se foram digitalizados*/
                    IF  CAN-DO("1,2",STRING(crapdoc.tpdocmto)) THEN
                            FOR FIRST tt-documento-digitalizado FIELDS(cdcooper) WHERE
                                   tt-documento-digitalizado.cdcooper = crapdoc.cdcooper      AND
                                   tt-documento-digitalizado.nrdconta = crapdoc.nrdconta      AND
                                   CAN-DO("90,91",STRING(tt-documento-digitalizado.tpdocmto)) AND
                                       tt-documento-digitalizado.dtpublic >= crapdoc.dtmvtolt     
                                   USE-INDEX tt-documento-digitalizado3
                                       NO-LOCK: END.
                   ELSE /* Verifica se o contrato foi digitalizado */                                    
                            FOR FIRST tt-documento-digitalizado FIELDS(cdcooper) WHERE
                                   tt-documento-digitalizado.cdcooper = crapdoc.cdcooper AND
                                   tt-documento-digitalizado.nrdconta = crapdoc.nrdconta AND
                                   tt-documento-digitalizado.tpdocmto = aux_tpdocmto     AND
                                       tt-documento-digitalizado.dtpublic >= crapdoc.dtmvtolt 
                                   USE-INDEX tt-documento-digitalizado3 
                                       NO-LOCK: END.
                  
                                   
                  IF  NOT AVAIL tt-documento-digitalizado  THEN
                      DO:                            
                        
                        /* Verifica os documentos de cpf e rg  se foram digitalizados*/
                        IF  CAN-DO("1,2",STRING(crapdoc.tpdocmto)) THEN
                                FOR FIRST tt-documento-digitalizado FIELDS(cdcooper) WHERE
                                       tt-documento-digitalizado.cdcooper = crapdoc.cdcooper      AND
                                       CAN-DO("90,91",STRING(tt-documento-digitalizado.tpdocmto)) AND
                                           tt-documento-digitalizado.dtpublic >= crapdoc.dtmvtolt     AND
                                           tt-documento-digitalizado.nrcpfcgc = crapdoc.nrcpfcgc
                                           USE-INDEX tt-documento-digitalizado4
                                           NO-LOCK: END.
                    ELSE /* Verifica se o contrato foi digitalizado */                                    
                                FOR FIRST tt-documento-digitalizado FIELDS(cdcooper) WHERE
                                   tt-documento-digitalizado.cdcooper = crapdoc.cdcooper AND
                                   tt-documento-digitalizado.tpdocmto = aux_tpdocmto     AND
                                           tt-documento-digitalizado.dtpublic >= crapdoc.dtmvtolt AND
                                           tt-documento-digitalizado.nrcpfcgc = crapdoc.nrcpfcgc
                                           USE-INDEX tt-documento-digitalizado4
                                           NO-LOCK: END.
                      END.
                 
                  IF  NOT AVAIL tt-documento-digitalizado  THEN
                      DO:           
                         /* Verifica os documentos de cpf e rg  se foram digitalizados*/
                            IF  CAN-DO("1,2",STRING(crapdoc.tpdocmto)) THEN
                              FOR FIRST tt-documento-digitalizado FIELDS(cdcooper) WHERE
                                           tt-documento-digitalizado.cdcooper = crapdoc.cdcooper      AND
                                         tt-documento-digitalizado.nrdconta = crapdoc.nrdconta      AND
                                           CAN-DO("90,91",STRING(tt-documento-digitalizado.tpdocmto)) AND
                                           tt-documento-digitalizado.dtpublic >= crapdoc.dtmvtolt     AND
                                           tt-documento-digitalizado.nrcpfcgc = crapdoc.nrcpfcgc
                                         USE-INDEX tt-documento-digitalizado5
                                         NO-LOCK: END.
                            ELSE /* Verifica se o contrato foi digitalizado */                                    
                              FOR FIRST tt-documento-digitalizado FIELDS(cdcooper) WHERE
                                           tt-documento-digitalizado.cdcooper = crapdoc.cdcooper AND
                                         tt-documento-digitalizado.nrdconta = crapdoc.nrdconta AND
                                           tt-documento-digitalizado.tpdocmto = aux_tpdocmto     AND
                                           tt-documento-digitalizado.dtpublic >= crapdoc.dtmvtolt AND
                                           tt-documento-digitalizado.nrcpfcgc = crapdoc.nrcpfcgc
                                         USE-INDEX tt-documento-digitalizado5 
                                         NO-LOCK: END.

                      END.


                    /* Caso encontrar o contrato digitalizado, altera flag e vai para o proximo */
                    IF  AVAIL tt-documento-digitalizado  THEN
                        DO: 
                        
                            /*Verifica se documento foi digitalizado*/
                            FIND FIRST b-crapdoc WHERE RECID(b-crapdoc) = RECID(crapdoc) EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                            
                            /*Caso encontre o arquivo digitalizado, altera flag do registro no banco*/
                            IF  AVAIL(b-crapdoc)  THEN
                            DO:
                                ASSIGN b-crapdoc.flgdigit = TRUE
                                       b-crapdoc.tpbxapen = 4 /* Baixa por digitalizaçao */
                                       b-crapdoc.dtbxapen = TODAY 
                                       b-crapdoc.cdopebxa = "1".
                                       
                                RELEASE b-crapdoc NO-ERROR.
                            END.

                            NEXT.
                                
                        END.                                              
                    ELSE
                        DO:
                             /* Nao deve gerar matriculas no relatório */
                             IF  crapdoc.tpdocmto = 8 THEN
                                 NEXT.
                             
                             /* Para nao gerar linha em branco no relatorio */
                             IF  (crapdoc.tpdocmto = 4 AND crapass.inpessoa <> 1)   OR /* Somente pessoa fisica */
                                 (crapdoc.tpdocmto = 12 AND crapass.inpessoa = 1)   OR /* Somente pessoa juridica */
                                 (crapdoc.tpdocmto = 1 AND crapass.inpessoa <> 1)   OR /* Somente pessoa fisica */
                                 (crapdoc.tpdocmto = 2 AND crapass.inpessoa <> 1)   OR /* Somente pessoa fisica */
                                 (crapdoc.tpdocmto = 5 AND crapass.inpessoa <> 1)   OR /* Somente pessoa fisica */
								 (crapdoc.tpdocmto = 40 AND crapass.inpessoa = 1)  THEN  /* Somente pessoa juridica */
                                 NEXT.

                             FIND tt-contr_ndigi_cadastro WHERE tt-contr_ndigi_cadastro.cdcooper = crapdoc.cdcooper AND
                                                                tt-contr_ndigi_cadastro.nrdconta = crapdoc.nrdconta AND
                                                                tt-contr_ndigi_cadastro.idseqttl = crapdoc.idseqttl AND
                                                                tt-contr_ndigi_cadastro.dtmvtolt = crapdoc.dtmvtolt AND
                                                                tt-contr_ndigi_cadastro.nrcpfcgc = crapdoc.nrcpfcgc
                                                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                             IF NOT AVAIL tt-contr_ndigi_cadastro THEN
                                DO: 

                                    /* Criar registro para listar no relatorio */
                                    CREATE tt-contr_ndigi_cadastro.
                                    ASSIGN tt-contr_ndigi_cadastro.cdcooper = crapdoc.cdcooper
                                           tt-contr_ndigi_cadastro.nrdconta = crapdoc.nrdconta
                                           tt-contr_ndigi_cadastro.dtmvtolt = crapdoc.dtmvtolt
                                           tt-contr_ndigi_cadastro.idseqttl = crapdoc.idseqttl
                                           tt-contr_ndigi_cadastro.idseqite = aux_tpdocmto
                                           tt-contr_ndigi_cadastro.nrcpfcgc = crapdoc.nrcpfcgc.
            
                                    CASE crapdoc.tpdocmto:
                                        WHEN 1 THEN
                                            ASSIGN tt-contr_ndigi_cadastro.tpdocreg = "      X". /*CPF*/
                                        WHEN 2 THEN
                                            ASSIGN tt-contr_ndigi_cadastro.tpdocreg = "      X". /*CARTEIRA IDENTIFICACAO*/
                                        WHEN 3 THEN
                                            ASSIGN tt-contr_ndigi_cadastro.tpdoccen = "      X". /*COMPROVANTE DE ENDERECO*/
                                        WHEN 4 THEN
                                            IF crapass.inpessoa = 1 THEN ASSIGN tt-contr_ndigi_cadastro.tpdoccec = "     X". /*COMPROVANTE DE ESTADO CIVIL*/
                                        WHEN 5 THEN
                                            ASSIGN tt-contr_ndigi_cadastro.tpdoccre = "     X". /*COMPROVANTE DE RENDA*/
                                        WHEN 6 THEN
                                            ASSIGN tt-contr_ndigi_cadastro.tpdoccas = "     X". /*CARTAO DE ASSINATURA*/
                                        WHEN 7 THEN
                                            ASSIGN tt-contr_ndigi_cadastro.tpdocfca = "     X". /*FICHA CADASTRAL*/
                                        WHEN 9 THEN
                                            ASSIGN tt-contr_ndigi_cadastro.tpdocdip = "         X". /*DOCUMENTO DE IDENTIFICACAO - PROC*/
                                        WHEN 10 THEN
                                            ASSIGN tt-contr_ndigi_cadastro.tpdocctc = "      X". /*CARTAO DE CNPJ*/
                                        WHEN 11 THEN
                                            ASSIGN tt-contr_ndigi_cadastro.tpdocidp = "       X". /*DOCUMENTO DE IDENTIFICACAO - PJ*/
                                        WHEN 12 THEN 
                                            IF crapass.inpessoa <> 1 THEN ASSIGN tt-contr_ndigi_cadastro.tpdocdfi = "      X". /*DEMONSTRATIVO FINANCEIRO*/
                                        WHEN 40 THEN 
										    IF crapass.inpessoa <> 1 THEN ASSIGN tt-contr_ndigi_cadastro.tpdoclic = "        X". /*LICENSAS*/
                                        WHEN 45 THEN
                                            ASSIGN tt-contr_ndigi_cadastro.tpdocidp = " X". /*CONTRATO ABERTURA DE CONTA PF*/
                                        WHEN 46 THEN
                                            IF crapass.inpessoa <> 1 THEN ASSIGN tt-contr_ndigi_cadastro.tpdocdfi = "      X". /*CONTRATO ABERTURA DE CONTA PJ*/
                                        WHEN 47 THEN
                                            ASSIGN tt-contr_ndigi_cadastro.tpdocidp = " X". /*PROCURAÇAO PF*/
                                        WHEN 48 THEN
                                            IF crapass.inpessoa <> 1 THEN ASSIGN tt-contr_ndigi_cadastro.tpdocdfi = "      X". /*PROCURAÇAO PJ*/
                                        WHEN 49 THEN
                                            IF crapass.inpessoa <> 1 THEN ASSIGN tt-contr_ndigi_cadastro.tpdocdfi = "      X". /*DOCUMENTOS PROCURADORES PJ*/
                                        WHEN 50 THEN
                                            ASSIGN tt-contr_ndigi_cadastro.tpdocidp = "      X". /*DOCUMENTOS PROCURADORES PF*/
                                        WHEN 51 THEN
                                            ASSIGN tt-contr_ndigi_cadastro.tpdocidp = "      X". /*DOCUMENTOS RESPONSAVEL LEGAL*/
                                        WHEN 52 THEN
                                            IF crapass.inpessoa <> 1 THEN ASSIGN tt-contr_ndigi_cadastro.tpdocdfi = "      X". /*DOCUMENTO SÓCIOS/ADMINISTRADORES*/
                                    END CASE.
                                    
                                    IF  crapass.inpessoa = 1 THEN
                                        ASSIGN tt-contr_ndigi_cadastro.cdagenci = crapass.cdagenci
                                               tt-contr_ndigi_cadastro.tppessoa = "PF".
                                    ELSE
                                        ASSIGN tt-contr_ndigi_cadastro.cdagenci = crapass.cdagenci
                                               tt-contr_ndigi_cadastro.tppessoa = "PJ".
                                    
                                END.
                            ELSE
                                CASE crapdoc.tpdocmto:
                                    WHEN 1 THEN
                                        ASSIGN tt-contr_ndigi_cadastro.tpdocreg = "      X". /*CPF*/
                                    WHEN 2 THEN
                                        ASSIGN tt-contr_ndigi_cadastro.tpdocreg = "      X". /*CARTEIRA IDENTIFICACAO*/
                                    WHEN 3 THEN
                                        ASSIGN tt-contr_ndigi_cadastro.tpdoccen = "      X". /*COMPROVANTE DE ENDERECO*/
                                    WHEN 4 THEN
                                        IF crapass.inpessoa = 1 THEN ASSIGN tt-contr_ndigi_cadastro.tpdoccec = "     X". /*COMPROVANTE DE ESTADO CIVIL*/
                                    WHEN 5 THEN
                                        ASSIGN tt-contr_ndigi_cadastro.tpdoccre = "     X". /*COMPROVANTE DE RENDA*/
                                    WHEN 6 THEN
                                        ASSIGN tt-contr_ndigi_cadastro.tpdoccas = "     X". /*CARTAO DE ASSINATURA*/
                                    WHEN 7 THEN
                                        ASSIGN tt-contr_ndigi_cadastro.tpdocfca = "     X". /*FICHA CADASTRAL*/
                                    WHEN 9 THEN
                                        ASSIGN tt-contr_ndigi_cadastro.tpdocdip = "         X". /*DOCUMENTO DE IDENTIFICACAO - PROC*/
                                    WHEN 10 THEN
                                        ASSIGN tt-contr_ndigi_cadastro.tpdocctc = "      X". /*CARTAO DE CNPJ*/
                                    WHEN 11 THEN
                                        ASSIGN tt-contr_ndigi_cadastro.tpdocidp = "       X". /*DOCUMENTO DE IDENTIFICACAO - PJ*/
                                    WHEN 12 THEN
                                        IF crapass.inpessoa <> 1 THEN ASSIGN tt-contr_ndigi_cadastro.tpdocdfi = "      X". /*DEMONSTRATIVO FINANCEIRO*/
                                    WHEN 40 THEN
                                        IF crapass.inpessoa <> 1 THEN ASSIGN tt-contr_ndigi_cadastro.tpdoclic = "        X". /*LICENSA*/
                                    WHEN 45 THEN
                                        ASSIGN tt-contr_ndigi_cadastro.tpdocidp = " X". /*CONTRATO ABERTURA DE CONTA PF*/
                                    WHEN 46 THEN
                                        IF crapass.inpessoa <> 1 THEN ASSIGN tt-contr_ndigi_cadastro.tpdocdfi = "      X". /*CONTRATO ABERTURA DE CONTA PJ*/
                                    WHEN 47 THEN
                                        ASSIGN tt-contr_ndigi_cadastro.tpdocidp = " X". /*PROCURAÇAO PF*/
                                    WHEN 48 THEN
                                        IF crapass.inpessoa <> 1 THEN ASSIGN tt-contr_ndigi_cadastro.tpdocdfi = "      X". /*PROCURAÇAO PJ*/
                                    WHEN 49 THEN
                                        IF crapass.inpessoa <> 1 THEN ASSIGN tt-contr_ndigi_cadastro.tpdocdfi = "      X". /*DOCUMENTOS PROCURADORES PJ*/
                                    WHEN 50 THEN
                                        ASSIGN tt-contr_ndigi_cadastro.tpdocidp = "      X". /*DOCUMENTOS PROCURADORES PF*/
                                    WHEN 51 THEN
                                        ASSIGN tt-contr_ndigi_cadastro.tpdocidp = "      X". /*DOCUMENTOS RESPONSAVEL LEGAL*/
                                    WHEN 52 THEN
                                        IF crapass.inpessoa <> 1 THEN ASSIGN tt-contr_ndigi_cadastro.tpdocdfi = "      X". /*DOCUMENTO SÓCIOS/ADMINISTRADORES*/
                                END CASE.
                        END.
                END.
            END.
        END. /* FIM do DO aux_data */

    FIND FIRST tt-contr_ndigi_cadastro WHERE 
               tt-contr_ndigi_cadastro.cdcooper = par_cdcooper
               NO-LOCK NO-ERROR.

    IF  NOT AVAIL tt-contr_ndigi_cadastro THEN
        NEXT.

    { sistema/generico/includes/b1cabrelvar.i }

    IF   par_inchamad = 0   THEN /* crps */
         DO:
             FOR EACH tt-contr_ndigi_cadastro WHERE 
                      tt-contr_ndigi_cadastro.cdcooper = crapcop.cdcooper                                                                                                              
                      NO-LOCK USE-INDEX tt-contr_ndigi_cadastro1                                                                                                             
                              BREAK BY tt-contr_ndigi_cadastro.cdcooper                                                                                                              
                                    BY tt-contr_ndigi_cadastro.cdagenci                                                                                                              
                                    BY tt-contr_ndigi_cadastro.nrdconta:                                                                                                             
                                                                                                                                                                                                    
                 /* QUEBRA POR AGENCIA */                                                                                                                                                           
                 IF  FIRST-OF (tt-contr_ndigi_cadastro.cdagenci) THEN                                                                                                                               
                     DO:                                                                                                                                                                            
                         FIND crapage WHERE 
                              crapage.cdcooper = tt-contr_ndigi_cadastro.cdcooper AND
                              crapage.cdagenci = tt-contr_ndigi_cadastro.cdagenci
                              NO-LOCK NO-ERROR.

                         rel_dsagenci = "PA: " + STRING(tt-contr_ndigi_cadastro.cdagenci,"zzz9") + " - ".                                                                                           
                                                                                                                                                                                                    
                         IF AVAIL crapage THEN                                                                                                                                                      
                              rel_dsagenci = rel_dsagenci + crapage.nmresage.                                                                                                                       
                         ELSE                                                                                                                                                                       
                              rel_dsagenci = rel_dsagenci + "*** PA NAO CADASTRADO ***".                                                                                                            
                 
                         ASSIGN aux_nmarqcad = "/usr/coop/" + crapcop.dsdircop +                        
                                               "/rl/" + "crrl620_cadastro_" +                               
                                               STRING(tt-contr_ndigi_cadastro.cdagenci,"999") + ".lst".      
                                                                                                   
                         OUTPUT STREAM str_1 TO VALUE (aux_nmarqcad) PAGED PAGE-SIZE 80.           
   
                         { sistema/generico/includes/b1cabrel132.i "11" "620" }                    
                                                                                                 
                         VIEW STREAM str_1 FRAME f_urgnt.
                         DISPLAY STREAM str_1 SKIP.
                         DISPLAY STREAM str_1 rel_dsagenci WITH FRAME f_pac.
                         DISPLAY STREAM str_1 SKIP.    

                         ASSIGN aux_totcontr = 0.

                     END.

                 DISPLAY STREAM str_1 tt-contr_ndigi_cadastro.nrdconta
                                      tt-contr_ndigi_cadastro.tppessoa
                                      tt-contr_ndigi_cadastro.tpdocreg
                                      tt-contr_ndigi_cadastro.tpdoccen
                                      tt-contr_ndigi_cadastro.tpdoccec
                                      tt-contr_ndigi_cadastro.tpdoccre
                                      tt-contr_ndigi_cadastro.tpdoccas
                                      tt-contr_ndigi_cadastro.tpdocfca
                                      tt-contr_ndigi_cadastro.tpdocdip
                                      tt-contr_ndigi_cadastro.tpdocctc
                                      tt-contr_ndigi_cadastro.tpdocdfi
                                      tt-contr_ndigi_cadastro.tpdocidp
									  tt-contr_ndigi_cadastro.tpdoclic
                                      tt-contr_ndigi_cadastro.idseqttl 
                                      tt-contr_ndigi_cadastro.dtmvtolt 
                                      WITH FRAME f_contr_2.

                 DOWN WITH FRAME f_contr_2.
                
                 ASSIGN aux_totcontr = aux_totcontr + 1.
                 
                 /* ULTIMO DOCUMENTO DESTE TIPO DE DOCUMENTO */
                 IF   LAST-OF (tt-contr_ndigi_cadastro.cdagenci) THEN
                      DO:
                           DISPLAY STREAM str_1 aux_totcontr
                                          WITH FRAME f_tot_ctr.

                           OUTPUT STREAM str_1 CLOSE.

                           UNIX SILENT VALUE("cp " + aux_nmarqcad + 
                                             " /usr/coop/" +
                                             crapcop.dsdircop + "/salvar").
                      END.
                
             END.

         END.

    /********************************************************************/
    /****************** RELATORIO DE TODOS OS PAs ***********************/
    /********************************************************************/

    /* GERAR RELATORIO DE NAO DIGITALIZADO PARA ENVIAR PARA COOPERATIVA (PARAMETRO NA TAB093) */
    IF par_inchamad = 1 THEN /* TELA */
        ASSIGN aux_nmarquca = "crrl620_cadastro_999.txt".
    ELSE
        ASSIGN aux_nmarquca = "crrl620_cadastro_999.lst".

    ASSIGN aux_nmarqcad = "/usr/coop/" + crapcop.dsdircop + 
                          "/rl/" + aux_nmarquca
          
           par_nmarqcad = aux_nmarqcad
           
           aux_nmarqica = "/micros/" + crapcop.dsdircop + "/crrl620_cadastro" + 
                          STRING(YEAR(par_datafina), "9999") + "-" +
                          STRING(MONTH(par_datafina), "99") +  "-" +
                          STRING(DAY(par_datafina), "99") + "-" + 
                          STRING(TIME) + ".txt"
           aux_contagen = 0.
   
    OUTPUT STREAM str_1 TO VALUE (aux_nmarqcad) PAGED PAGE-SIZE 62.

   { sistema/generico/includes/b1cabrel234.i "11" "620" }
     
    DISP STREAM str_1 SKIP.
     
    FOR EACH tt-contr_ndigi_cadastro WHERE tt-contr_ndigi_cadastro.cdcooper = crapcop.cdcooper
                                    NO-LOCK USE-INDEX tt-contr_ndigi_cadastro1
                                    BREAK BY tt-contr_ndigi_cadastro.cdcooper
                                          BY tt-contr_ndigi_cadastro.cdagenci
                                          BY tt-contr_ndigi_cadastro.nrdconta.
        
        /* QUEBRA POR AGENCIA */
        IF  FIRST-OF (tt-contr_ndigi_cadastro.cdagenci) THEN
            DO:
                FIND crapage WHERE crapage.cdcooper = tt-contr_ndigi_cadastro.cdcooper AND
                                   crapage.cdagenci = tt-contr_ndigi_cadastro.cdagenci NO-LOCK NO-ERROR.
                
                rel_dsagenci = "PA: " + STRING(tt-contr_ndigi_cadastro.cdagenci,"zzz9") + " - ".
        
                IF AVAIL crapage THEN
                     rel_dsagenci = rel_dsagenci + crapage.nmresage.
                ELSE
                     rel_dsagenci = rel_dsagenci + "*** PA NAO CADASTRADO ***".
                IF aux_contagen <> 0 THEN
                    PAGE STREAM str_1.

                VIEW STREAM str_1 FRAME f_urgnt.
                DISPLAY STREAM str_1 SKIP.
                DISPLAY STREAM str_1 rel_dsagenci WITH FRAME f_pac.
                DISPLAY STREAM str_1 SKIP.

                ASSIGN aux_contagen = 1    
                       aux_totcontr = 0.
            END.
        
        DISPLAY STREAM str_1 tt-contr_ndigi_cadastro.nrdconta
                             tt-contr_ndigi_cadastro.tppessoa
                             tt-contr_ndigi_cadastro.tpdocreg
                             tt-contr_ndigi_cadastro.tpdoccen
                             tt-contr_ndigi_cadastro.tpdoccec
                             tt-contr_ndigi_cadastro.tpdoccre
                             tt-contr_ndigi_cadastro.tpdoccas
                             tt-contr_ndigi_cadastro.tpdocfca
                             tt-contr_ndigi_cadastro.tpdocdip
                             tt-contr_ndigi_cadastro.tpdocctc
                             tt-contr_ndigi_cadastro.tpdocdfi
                             tt-contr_ndigi_cadastro.tpdocidp
							 tt-contr_ndigi_cadastro.tpdoclic
                             tt-contr_ndigi_cadastro.idseqttl 
                             tt-contr_ndigi_cadastro.dtmvtolt 
                             WITH FRAME f_contr_2.

        DOWN WITH FRAME f_contr_2.

        ASSIGN aux_totcontr = aux_totcontr + 1.
        
        /* ULTIMO DOCUMENTO DESTE TIPO DE DOCUMENTO */
        IF LAST-OF (tt-contr_ndigi_cadastro.cdagenci) THEN
           DISPLAY STREAM str_1 aux_totcontr WITH FRAME f_tot_ctr.

    END.
    
    OUTPUT STREAM str_1 CLOSE.

    IF par_inchamad = 1  THEN /* Tela */
        DO:
            UNIX SILENT VALUE("cp " + aux_nmarqcad + " /usr/coop/" + 
                              crapcop.dsdircop + "/converte/crrl620_cadastro_999.txt").
           
            FIND craprel WHERE craprel.cdcooper = par_cdcooper AND
                               craprel.cdrelato = 620 
                               EXCLUSIVE-LOCK NO-ERROR.
     
            IF  AVAIL craprel   THEN 
                ASSIGN craprel.ingerpdf = 2. /*Nao gera PDF */

            /* Envia o arquivo gerado por email */
            RUN sistema/generico/procedures/b1wgen0011.p 
                PERSISTENT SET h-b1wgen0011.
            
            RUN enviar_email_completo IN h-b1wgen0011 (INPUT crapcop.cdcooper,
                                                       INPUT "b1wgen00137",
                                                       INPUT "AILOS<ailos@ailos.coop.br>",
                                                       INPUT par_emailbat,
                                                       INPUT "Rel.620 - RELACAO DE DOCUMENTOS"+
                                                             " DE CADASTROS NAO DIGITALIZADOS",
                                                       INPUT "",
                                                       INPUT "crrl620_cadastro_999.txt",
                                                       INPUT "\nSegue anexo o Relatorio crrl620 " +
                                                             "da Cooperativa " + crapcop.nmrescop,
                                                       INPUT TRUE).

            DELETE PROCEDURE h-b1wgen0011.
        END.
    ELSE
        DO:
            /* copia relatorio para "/usr/coop/COOPERATIVA/rlnsv/ARQ.lst"    */
            UNIX SILENT VALUE("cp " + aux_nmarqcad + " /usr/coop/" + crapcop.dsdircop + 
                              "/rlnsv/" + aux_nmarquca).

            FIND craptab WHERE  craptab.cdcooper = crapcop.cdcooper AND
                                craptab.nmsistem = "CRED"           AND
                                craptab.tptabela = "GENERI"         AND
                                craptab.cdempres = 00               AND
                                craptab.cdacesso = "DIGITEMAIL"     AND
                                craptab.tpregist = 0  NO-LOCK NO-ERROR.
    
            IF AVAIL craptab  THEN
                DO:
                    FIND craprel WHERE craprel.cdcooper = par_cdcooper AND
                                       craprel.cdrelato = 620 
                                       EXCLUSIVE-LOCK NO-ERROR.
     
                    IF  AVAIL craprel   THEN 
                        ASSIGN craprel.ingerpdf = 1. /* Gera PDF */
                    
                    IF (SUBSTRING(craptab.dstextab, 1, 1) = "S") THEN 
                        DO:
                            ASSIGN aux_nmarqpca = "/usr/coop/" + 
                                                  crapcop.dsdircop + 
                                                  "/converte/crrl620_cadastro_999.pdf".
                
                            RUN sistema/generico/procedures/b1wgen0024.p 
                                PERSISTENT SET h-b1wgen0024.
                
                            RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqcad,
                                                                    INPUT aux_nmarqpca).
                           
                            DELETE PROCEDURE h-b1wgen0024.
                            
                            /* Envia o arquivo gerado por email */
                            RUN sistema/generico/procedures/b1wgen0011.p 
                                PERSISTENT SET h-b1wgen0011.
                            
                            RUN enviar_email_completo IN h-b1wgen0011 (INPUT crapcop.cdcooper,
                                                                       INPUT "b1wgen00137",
                                                                       INPUT "AILOS<ailos@ailos.coop.br>",
                                                                       INPUT ENTRY(3,craptab.dstextab,";"),
                                                                       INPUT "Rel.620 - RELACAO DE DOCUMENTOS"+
                                                                             " DE CADASTROS NAO DIGITALIZADOS",
                                                                       INPUT "",
                                                                       INPUT "crrl620_cadastro_999.pdf",
                                                                       INPUT "\nSegue anexo o Relatorio crrl620 " +
                                                                             "da Cooperativa " + crapcop.nmrescop,
                                                                       INPUT TRUE).
                
                            DELETE PROCEDURE h-b1wgen0011.
                            
                        END.
                END.
            ELSE
                DO:
                    
                    ASSIGN aux_dscritic = "Nao foi possivel encontrar parametros em DIGITEMAIL.".
            
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - " + "crps620" + "' --> '" + " b1wgen00137 " +
                                      aux_dscritic + " >> /usr/coop/cecred/log/proc_batch.log").
                    RETURN "NOK".
                END.
        END.

    RETURN "OK".

END PROCEDURE.

/* GERA RELATORIO COM PENDENCIAS DE DOCUMENTOS DE CREDITO NAO DIGITALIZADOS */
PROCEDURE efetua_batimento_ged_credito:
   
    DEFINE INPUT PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT PARAMETER par_datainic AS DATE        NO-UNDO.
    DEFINE INPUT PARAMETER par_datafina AS DATE        NO-UNDO.
    DEFINE INPUT PARAMETER par_inchamad AS INTEGER     NO-UNDO.
    DEFINE INPUT PARAMETER par_emailbat AS CHAR        NO-UNDO.
    DEFINE OUTPUT PARAMETER par_nmarqcre AS CHAR       NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEF VAR aux_vllimite AS DECI                        NO-UNDO.
    DEF VAR aux_vlctrato AS DECI                        NO-UNDO.
    DEF VAR aux_idseqite AS INT                         NO-UNDO.
    DEF VAR aux_cdagenci AS INTE                        NO-UNDO.
    DEF VAR aux_cdbanchq AS INTE                        NO-UNDO.
    DEF VAR aux_nrdolote AS INTE                        NO-UNDO.
    DEF VAR aux_nmarqucr AS CHAR                        NO-UNDO.
    DEF VAR aux_nmarqcre AS CHAR                        NO-UNDO.
    DEF VAR aux_nmarqicr AS CHAR                        NO-UNDO.
    DEF VAR aux_totcontr AS INT                         NO-UNDO.
    DEF VAR aux_titrelat AS CHAR                        NO-UNDO.
    DEF VAR aux_nmarqpcr AS CHAR                        NO-UNDO.
    DEF VAR aux_contagen AS INT                         NO-UNDO.
    DEF VAR par_dtmvtolt  AS DATE INIT TODAY            NO-UNDO.
    
    DEF VAR rel_cdagenci AS INTE                        NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                        NO-UNDO.
    DEF VAR aux_data     AS DATE                        NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                      NO-UNDO.
    DEF VAR h-b1wgen0011 AS HANDLE                      NO-UNDO.

    DEF BUFFER b-tt-contr_ndigi  FOR tt-contr_ndigi.
    
    FORM "DOCUMENTOS NAO DIGITALIZADOS" AT 20
         "-"                         AT 48
         "*****************  U R G E N T E  *****************" AT 51
         WITH WIDTH 132 NO-BOX NO-LABEL SIDE-LABELS FRAME f_urgnt.

    FORM rel_dsagenci AT   1 FORMAT "x(100)" NO-LABEL
         WITH WIDTH 132 NO-BOX NO-LABEL SIDE-LABELS FRAME f_pac.

    FORM SKIP(1)
         aux_titrelat AT 58 FORMAT "x(45)" 
         SKIP(2)
         "DADOS DO CONTRATO/BORDERO"     AT 83 
         "-------------------------------------------------------------------------"
         AT 58
         WITH WIDTH 132 NO-BOX NO-LABEL SIDE-LABELS CENTERED FRAME f_dados_contr.
    

    FORM tt-contr_ndigi.nrdconta AT 01  FORMAT "zzzz,zz9,9"         LABEL "Conta/DV"
         tt-contr_ndigi.dtmvtolt AT 17  FORMAT "99/99/9999"         LABEL "Data Proposta"
         tt-contr_ndigi.dtlibera AT 32  FORMAT "99/99/9999"         LABEL "Data Liberacao"
         tt-contr_ndigi.cdagenci AT 58  FORMAT "zz9"                LABEL "PA"
         tt-contr_ndigi.cdbanchq AT 69  FORMAT "999"                LABEL "B/CX"
         tt-contr_ndigi.nrdolote AT 80  FORMAT "zzz,zz9"            LABEL "Lote"
         tt-contr_ndigi.nrdcontr AT 95  FORMAT "zzz,zzz,zz9"        LABEL "Nro.Ctr./Bor."
         tt-contr_ndigi.vldodesc AT 113 FORMAT "zzz,zzz,zzz,zz9.99" LABEL "Valor"
         WITH DOWN NO-LABEL WIDTH 132 FRAME f_contr.

    FORM tt-contr_ndigi.nrdconta AT 01  FORMAT "zzzz,zz9,9"         LABEL "Conta/DV"
         tt-contr_ndigi.dtmvtolt AT 17  FORMAT "99/99/9999"         LABEL "Data Proposta"
         tt-contr_ndigi.dtlibera AT 32  FORMAT "99/99/9999"         LABEL "Data Liberacao"
         tt-contr_ndigi.cdagenci AT 58  FORMAT "zz9"                LABEL "PA"
         tt-contr_ndigi.cdbanchq AT 64  FORMAT "999"                LABEL "B/CX"
         tt-contr_ndigi.nrdolote AT 71  FORMAT "zzz,zz9"            LABEL "Lote"
         tt-contr_ndigi.nrdcontr AT 81  FORMAT "zzz,zzz,zz9"        LABEL "Nro.Ctr./Bor."
         tt-contr_ndigi.nraditiv AT 97  FORMAT "99"                 LABEL "Nro. Aditivo"
         tt-contr_ndigi.vldodesc AT 113 FORMAT "zzz,zzz,zzz,zz9.99" LABEL "Valor"
         WITH DOWN NO-LABEL WIDTH 132 FRAME f_contr_3.

    FORM aux_totcontr LABEL "Quantidade Total"
         WITH DOWN NO-LABEL WIDTH 132 SIDE-LABELS FRAME f_tot_ctr.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-documento-digitalizado.
    EMPTY TEMP-TABLE tt-documentos.

    /* ALIMENTA A TABELA DE PARAMETROS */
    FOR EACH craptab FIELDS(dstextab tpregist)                  WHERE 
                           craptab.cdcooper = par_cdcooper  AND         
                           craptab.nmsistem = "CRED"            AND         
                           craptab.tptabela = "GENERI"          AND         
                           craptab.cdempres = 00                AND         
                           craptab.cdacesso = "DIGITALIZA"
                           NO-LOCK:

        IF CAN-DO("57,84,85,86,87,88,89,102",ENTRY(3,craptab.dstextab,";")) THEN
            DO:
                CREATE tt-documentos.
                ASSIGN tt-documentos.vldparam = DECI(ENTRY(4,craptab.dstextab,";"))
                       tt-documentos.nmoperac = ENTRY(1,craptab.dstextab,";")
                       tt-documentos.tpdocmto = INTE(ENTRY(3,craptab.dstextab,";"))
                       tt-documentos.idseqite = craptab.tpregist.
            END.

    END.
    
    /* Adicionar intervalo de data, 3 em 3 meses */
    ASSIGN aux_dtinidoc = par_datainic
           aux_dtfimdoc = ADD-INTERVAL(aux_dtinidoc,02,'months').
        
    periodo:
    DO  WHILE TRUE:

       /* CONSULTAR NO SMARTSHARE (SELBETTI) OS DOCUMENTOS QUE ESTAO DIGITALIZADOS */
       RUN lista-documentos-digitalizados(INPUT crapcop.cdcooper,
                                          INPUT aux_dtinidoc, /* DATA DE CONSULTA DE IMAGENS */
                                          INPUT aux_dtfimdoc,
                                          INPUT TABLE tt-documentos,
                                         OUTPUT TABLE tt-documento-digitalizado,
                                         OUTPUT TABLE tt-erro).   
           

        /* EM CASO DE ERRO, GERA LOG E PARTE PARA PROXIMA COOPERATIVA */
        IF RETURN-VALUE <> "OK"  THEN
            DO: 
            
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                IF  AVAIL tt-erro  THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                ELSE
                    DO:
                        ASSIGN aux_dscritic = "Erro ao listar documentos digitalizados no Smartshare.".
                        
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 1,
                                       INPUT 1,
                                       INPUT 1, /* SEQUENCIA */
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                    END.
        
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - " + "crps620" + "' --> '"  + " b1wgen00137 " +
                                  aux_dscritic + " >> /usr/coop/cecred/log/proc_batch.log").
                RETURN "NOK".
            END.                                     
                   
         IF  aux_dtfimdoc >= par_datafina THEN 
             LEAVE periodo.  
             
         /* Adicionar intervalo de data, 3 em 3 meses */
         ASSIGN aux_dtinidoc = ADD-INTERVAL(aux_dtfimdoc,01,'days')               
                aux_dtfimdoc = ADD-INTERVAL(aux_dtinidoc,03,'months').
                
         IF  aux_dtfimdoc >= TODAY THEN
             aux_dtfimdoc = TODAY.
    END.
        
    
    /* UTILIZADO LACO NA DATA PARA MELHORAR PERFORMANCE NAS LEITURAS */
    DO  aux_data = par_datainic TO par_datafina:

        /*ADITIVOS - TIPO DE DOCUMENTO: 18*/
        ASSIGN aux_tpdocmto = 0.

        /* Buscar valor parametrizado para digitalizacao de Aditivos */
        FIND tt-documentos WHERE 
             tt-documentos.idseqite = 18 NO-LOCK NO-ERROR.

        IF  AVAIL tt-documentos  THEN
            ASSIGN aux_tpdocmto = tt-documentos.tpdocmto.
        
        FOR EACH crapadt FIELDS(cdcooper nrdconta nrctremp nraditiv dtmvtolt)
                         WHERE crapadt.cdcooper = par_cdcooper AND
                               crapadt.flgdigit = NO               AND
                               crapadt.dtmvtolt = aux_data         AND
                               crapadt.tpctrato = 90 /* Emprestimo/Financiamento */
                               NO-LOCK:
            
            /* Se cooperado estiver demitidos nao gera no relatorio */
            FIND FIRST crapass WHERE 
                       crapass.cdcooper = crapadt.cdcooper AND
                       crapass.nrdconta = crapadt.nrdconta NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapass THEN 
                NEXT.

            IF  crapass.dtdemiss <> ? THEN
                NEXT.
            /*Busca empréstimo relacionado com os aditivos encontrados acima*/
            FOR FIRST crapepr FIELDS(cdcooper nrdconta nrctremp cdagenci 
                                     cdbccxlt nrdolote vlemprst )
                               WHERE crapepr.cdcooper = crapadt.cdcooper AND
                                     crapepr.nrdconta = crapadt.nrdconta AND
                                     crapepr.nrctremp = crapadt.nrctremp AND
                                     NOT CAN-DO("100,800,850,900,6901,6902,6903,6904,6905",
                                               STRING(crapepr.cdlcremp)) NO-LOCK:

                /* Verifica se o contrato foi digitalizado */
                FIND FIRST tt-documento-digitalizado WHERE
                           tt-documento-digitalizado.cdcooper = crapepr.cdcooper AND
                           tt-documento-digitalizado.nrdconta = crapepr.nrdconta AND
                           tt-documento-digitalizado.nrctrato = crapepr.nrctremp AND
                           tt-documento-digitalizado.nraditiv = crapadt.nraditiv AND
                           tt-documento-digitalizado.tpdocmto = aux_tpdocmto
                           NO-LOCK NO-ERROR NO-WAIT.

                /*Verifica se registro existe*/
                IF  AVAIL tt-documento-digitalizado  THEN
                    DO:
                        /*Verifica se documento foi digitalizado*/
                        FIND FIRST b-crapadt WHERE b-crapadt.cdcooper = crapepr.cdcooper AND        
                                                   b-crapadt.nrctremp = crapepr.nrctremp AND
                                                   b-crapadt.nrdconta = crapepr.nrdconta AND
                                                   b-crapadt.nraditiv = crapadt.nraditiv AND
                                                   b-crapadt.tpctrato = crapadt.tpctrato
                                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        /*Caso encontre o arquivo digitalizado, altera flag do registro no banco*/
                        IF  AVAIL b-crapadt THEN
                            ASSIGN b-crapadt.flgdigit = TRUE.

                        NEXT.

                    END.
                ELSE
                    DO:
                        IF  crapadt.dtmvtolt <= crapdat.dtmvtoan  THEN
                            DO:
                                /*Verifica se documento digitalizado é diferente de Sub-rogacao - 
                                  C/ ou S/ Nota Promissoria (Esse tipo de Aditivos nao devem
                                    aparecer no relatório do batimento) */
                                IF crapadt.nraditiv <> 8 AND crapadt.nraditiv <> 7 THEN
                                    DO:
                                        /* Criar registro para listar no relatorio */
                                        CREATE tt-contr_ndigi.
                                        ASSIGN tt-contr_ndigi.cdcooper = crapepr.cdcooper
                                               tt-contr_ndigi.nrdconta = crapepr.nrdconta
                                               tt-contr_ndigi.dtlibera = crapadt.dtmvtolt
                                               tt-contr_ndigi.dtmvtolt = crapadt.dtmvtolt
                                               tt-contr_ndigi.cdagenci = crapepr.cdagenci
                                               tt-contr_ndigi.cdbanchq = crapepr.cdbccxlt
                                               tt-contr_ndigi.nrdolote = crapepr.nrdolote
                                               tt-contr_ndigi.nrdcontr = crapepr.nrctremp
                                               tt-contr_ndigi.vldodesc = crapepr.vlemprst 
                                               tt-contr_ndigi.tpctrdig = 18
                                               tt-contr_ndigi.idseqite = aux_tpdocmto
                                               tt-contr_ndigi.nraditiv = crapadt.nraditiv.

                                    END.
                            END.
                    END.
            END.
        END. /*FIM ADITIVOS*/
    
        /* ZERAR VARIAVEIS DE CONTROLE DE PARAMETROS */ 
        ASSIGN aux_vllimite = 0
               aux_vlctrato = 0
               aux_tpdocmto = 0.
        
        /* Buscar valor parametrizado para digitalizacao de Bordero de desconto de Cheque - TAB093 */
        FIND tt-documentos WHERE 
             tt-documentos.idseqite = 2 NO-LOCK NO-ERROR.
    
        IF  AVAIL tt-documentos  THEN
            ASSIGN aux_vllimite = tt-documentos.vldparam
                   aux_tpdocmto = tt-documentos.tpdocmto.
       
        /* Contr. Bordero de Cheques */
        /*************************** IMPORTANTE ********************************
           *  A regra abaixo definida para (nao) apresentacao dos borderos de  *
           *  desconto de cheques segue a mesma regra definida na b1wgen0009 - *
           *  busca_borderos, utilizada na tela ATENDA; com excecao do         *
           *  indicador de borderos liberados apenas para esta BO              *
        ***********************************************************************/

        FOR EACH crapbdc WHERE crapbdc.cdcooper = par_cdcooper AND
                               crapbdc.insitbdc = 3            AND /* 3 - liberado */
                               crapbdc.dtlibbdc = aux_data    /* Data de Liberacao */
                               NO-LOCK,
            FIRST craplot WHERE craplot.cdcooper = crapbdc.cdcooper AND
                                craplot.dtmvtolt = crapbdc.dtmvtolt AND
                                craplot.cdagenci = crapbdc.cdagenci AND
                                craplot.cdbccxlt = crapbdc.cdbccxlt AND
                                craplot.nrdolote = crapbdc.nrdolote NO-LOCK:

            IF (crapbdc.dtlibbdc < crapdat.dtmvtolt - 90) THEN
            DO:
                IF  crapbdc.nrdconta <> 85448  THEN
                DO:
                    FIND FIRST crapcdb WHERE crapcdb.cdcooper = crapbdc.cdcooper AND
                                             crapcdb.nrdconta = crapbdc.nrdconta AND
                                             crapcdb.nrborder = crapbdc.nrborder AND
                                             crapcdb.dtlibera > crapdat.dtmvtolt
                                             NO-LOCK NO-ERROR.

                    IF NOT AVAIL crapcdb THEN
                        NEXT.
                END.
            END.
            
            /* Se cooperado estiver demitidos nao gera no relatorio */
            FIND FIRST crapass WHERE 
                       crapass.cdcooper = crapbdc.cdcooper AND
                       crapass.nrdconta = crapbdc.nrdconta NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapass THEN 
                NEXT.

            IF  crapass.dtdemiss <> ? THEN
                NEXT.
            
            /* Verifica se o contrato foi digitalizado */
            FIND FIRST tt-documento-digitalizado WHERE
                       tt-documento-digitalizado.cdcooper = crapbdc.cdcooper AND
                       tt-documento-digitalizado.nrdconta = crapbdc.nrdconta AND
                       tt-documento-digitalizado.nrborder = crapbdc.nrborder AND
                       tt-documento-digitalizado.tpdocmto = aux_tpdocmto
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
            /* Caso encontrar o bordero digitalizado, altera flag e vai proximo */
            IF  AVAIL tt-documento-digitalizado  THEN
                DO:
                    FIND b-crapbdc WHERE b-crapbdc.cdcooper = crapbdc.cdcooper AND         
                                         b-crapbdc.nrborder = crapbdc.nrborder 
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                    IF  AVAIL (b-crapbdc)  THEN
                        ASSIGN b-crapbdc.flgdigit = TRUE.
                    NEXT.
        
                END. 
            
            IF  NOT crapbdc.flgdigit  THEN
                /* Desprezar do dia, pois ainda nao foram digitalizados */
                IF  crapbdc.dtlibbdc <= crapdat.dtmvtoan  THEN
                    DO:
                        /* Criar registro para listar no relatorio */
                        CREATE tt-contr_ndigi.
                        ASSIGN tt-contr_ndigi.cdcooper = crapbdc.cdcooper
                               tt-contr_ndigi.nrdconta = crapbdc.nrdconta
                               tt-contr_ndigi.dtmvtolt = crapbdc.dtmvtolt
                               tt-contr_ndigi.dtlibera = crapbdc.dtlibbdc
                               tt-contr_ndigi.cdagenci = crapbdc.cdagenci
                               tt-contr_ndigi.cdbanchq = crapbdc.cdbccxlt
                               tt-contr_ndigi.nrdolote = crapbdc.nrdolote
                               tt-contr_ndigi.nrdcontr = crapbdc.nrborder
                               tt-contr_ndigi.vldodesc = craplot.vlcompcr
                               tt-contr_ndigi.idseqite = aux_tpdocmto
                               tt-contr_ndigi.tpctrdig = 2.
                    END.
        END. 
        
        /* Zerar variaveis de controle de parametros */ 
        ASSIGN aux_vllimite = 0
               aux_vlctrato = 0
               aux_tpdocmto = 0.
        
        /* Buscar valor parametrizado para digitalizacao de Bordero de desconto de Titulo - TAB093 */
        FIND tt-documentos WHERE 
             tt-documentos.idseqite = 4 NO-LOCK NO-ERROR.
    
        IF  AVAIL tt-documentos  THEN
            ASSIGN aux_vllimite = tt-documentos.vldparam
                   aux_tpdocmto = tt-documentos.tpdocmto.
        
        /* Contr. Bordero de Titulos */
        FOR EACH crapbdt WHERE   crapbdt.cdcooper = par_cdcooper   AND
                                 crapbdt.insitbdt = 3              AND
                                 crapbdt.dtlibbdt = aux_data /* Data de Liberacao */
                                 NO-LOCK,  
             FIRST craplot WHERE craplot.cdcooper = crapbdt.cdcooper   AND
                                 craplot.dtmvtolt = crapbdt.dtmvtolt   AND
                                 craplot.cdagenci = crapbdt.cdagenci   AND
                                 craplot.cdbccxlt = crapbdt.cdbccxlt   AND
                                 craplot.nrdolote = crapbdt.nrdolote   NO-LOCK:
            
            /* So traz cooperados que nao estao demitidos */
            FIND crapass WHERE crapass.cdcooper = crapbdt.cdcooper AND
                               crapass.nrdconta = crapbdt.nrdconta 
                               NO-LOCK NO-ERROR.
    
            IF  NOT AVAIL crapass THEN 
                NEXT.

            IF  crapass.dtdemiss <> ? THEN
                NEXT.
            
            /* Verifica se o contrato foi digitalizado */
            FIND FIRST tt-documento-digitalizado WHERE
                       tt-documento-digitalizado.cdcooper = crapbdt.cdcooper AND
                       tt-documento-digitalizado.nrdconta = crapbdt.nrdconta AND
                       tt-documento-digitalizado.nrborder = crapbdt.nrborder AND
                       tt-documento-digitalizado.tpdocmto = aux_tpdocmto
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
            /* Caso encontrar o bordero digitalizado, altera flag e vai para o proximo */
            IF  AVAIL tt-documento-digitalizado  THEN
                DO:
                    FIND b-crapbdt WHERE b-crapbdt.cdcooper = crapbdt.cdcooper AND        
                                         b-crapbdt.nrborder = crapbdt.nrborder 
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                    IF  AVAILABLE(b-crapbdt)  THEN
                        ASSIGN b-crapbdt.flgdigit = TRUE.
                    NEXT.
                    
                END.
            
            IF  NOT crapbdt.flgdigit  THEN
                /* Desprezar do dia, pois ainda nao foram digitalizados */
                IF  crapbdt.dtlibbdt <= crapdat.dtmvtoan  THEN
                    DO:
                        /* Criar registro para listar no relatorio */
                        CREATE tt-contr_ndigi.
                        ASSIGN tt-contr_ndigi.cdcooper = crapbdt.cdcooper
                               tt-contr_ndigi.nrdconta = crapbdt.nrdconta
                               tt-contr_ndigi.dtmvtolt = crapbdt.dtmvtolt
                               tt-contr_ndigi.dtlibera = crapbdt.dtlibbdt
                               tt-contr_ndigi.cdagenci = crapbdt.cdagenci
                               tt-contr_ndigi.cdbanchq = crapbdt.cdbccxlt
                               tt-contr_ndigi.nrdolote = crapbdt.nrdolote
                               tt-contr_ndigi.nrdcontr = crapbdt.nrborder
                               tt-contr_ndigi.vldodesc = craplot.vlcompcr 
                               tt-contr_ndigi.idseqite = aux_tpdocmto
                               tt-contr_ndigi.tpctrdig = 4.
                    END.
                    
        END. 
    
        /* Zerar variaveis de controle de parametros */ 
        ASSIGN aux_vllimite = 0
               aux_vlctrato = 0 
               aux_tpdocmto = 0.
        
        /* Limite de Cheque/Titulos */
        FOR EACH craplim WHERE craplim.cdcooper = par_cdcooper   AND
                               craplim.insitlim =  2             AND
                               craplim.tpctrlim <> 1             AND /* Nao trazer Cheque Especial */ 
                               craplim.dtinivig = aux_data /* Data de Liberacao */
                               NO-LOCK: 

            /* So traz cooperados que nao estao demitidos */
            FIND crapass WHERE crapass.cdcooper = craplim.cdcooper AND
                               crapass.nrdconta = craplim.nrdconta 
                               NO-LOCK NO-ERROR.
    
            IF  NOT AVAIL crapass THEN 
                NEXT.

            IF  crapass.dtdemiss <> ? THEN
                NEXT.

            /* 86 - Limite de desconto de cheque 
               85 - Limite de desconto de titulo */

            /* Buscar valor parametrizado para digitalizacao de Limites (Dsc Tit e Dsc Chq) - TAB093 */
            FIND FIRST tt-documentos WHERE 
                 tt-documentos.idseqite = 1 OR
                 tt-documentos.idseqite = 3 NO-LOCK NO-ERROR.
            
            IF  AVAIL tt-documentos  THEN 
                ASSIGN aux_tpdocmto = IF  craplim.tpctrlim = 2 THEN 86
                                      ELSE 85
                       aux_vllimite = tt-documentos.vldparam.
            ELSE
                ASSIGN aux_vllimite = 0
                       aux_tpdocmto = 0.
            
            /* Verifica se o contrato foi digitalizado */
            FIND FIRST tt-documento-digitalizado WHERE
                       tt-documento-digitalizado.cdcooper = craplim.cdcooper AND
                       tt-documento-digitalizado.nrdconta = craplim.nrdconta AND
                       tt-documento-digitalizado.nrctrato = craplim.nrctrlim AND
                       tt-documento-digitalizado.tpdocmto = aux_tpdocmto
                       EXCLUSIVE-LOCK NO-ERROR.
            
            /* Caso encontrar o bordero digitalizado, altera flag e vai proximo */
            IF  AVAIL tt-documento-digitalizado  THEN
                DO:
                    FIND b-craplim WHERE b-craplim.cdcooper = craplim.cdcooper AND        
                                         b-craplim.nrdconta = craplim.nrdconta AND
                                         b-craplim.tpctrlim = craplim.tpctrlim AND
                                         b-craplim.nrctrlim = craplim.nrctrlim
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                    IF  AVAIL (b-craplim)  THEN
                        ASSIGN b-craplim.flgdigit = TRUE.
                    NEXT.
                END. 
            
            IF  NOT craplim.flgdigit  THEN 
                /* Desprezar do dia, pois ainda nao foram digitalizados */
                IF  craplim.dtinivig <= crapdat.dtmvtoan  THEN
                DO: 
                    FIND crapcdc WHERE crapcdc.cdcooper = craplim.cdcooper AND 
                                       crapcdc.nrdconta = craplim.nrdconta AND 
                                       crapcdc.nrctrlim = craplim.nrctrlim AND
                                       crapcdc.tpctrlim = craplim.tpctrlim
                                       NO-LOCK NO-ERROR.
        
                    IF  AVAIL crapcdc  THEN
                        ASSIGN aux_cdagenci = crapcdc.cdagenci
                               aux_cdbanchq = crapcdc.cdbccxlt
                               aux_nrdolote = crapcdc.nrdolote.
                    ELSE
                        ASSIGN aux_cdagenci = 0
                               aux_cdbanchq = 0
                               aux_nrdolote = 0.
        
                    /* Criar registro para listar no relatorio */
                    CREATE tt-contr_ndigi.
                    ASSIGN tt-contr_ndigi.cdcooper = craplim.cdcooper
                           tt-contr_ndigi.nrdconta = craplim.nrdconta
                           tt-contr_ndigi.dtmvtolt = craplim.dtpropos
                           tt-contr_ndigi.dtlibera = craplim.dtinivig
                           tt-contr_ndigi.cdagenci = aux_cdagenci
                           tt-contr_ndigi.cdbanchq = aux_cdbanchq
                           tt-contr_ndigi.nrdolote = aux_nrdolote 
                           tt-contr_ndigi.nrdcontr = craplim.nrctrlim
                           tt-contr_ndigi.vldodesc = craplim.vllimite
                           tt-contr_ndigi.idseqite = aux_tpdocmto
                           tt-contr_ndigi.tpctrdig = IF craplim.tpctrlim = 2      THEN 1
                                                     ELSE IF craplim.tpctrlim = 3 THEN 3
                                                     ELSE 0. 
                END.
        END. /* Fim do for each craplim */
        
        /* Limite de Credito */
        FOR EACH craplim WHERE craplim.cdcooper = par_cdcooper AND
                               craplim.insitlim = 2                AND
                               craplim.tpctrlim = 1                AND  
                               craplim.dtinivig = aux_data /* Data de Liberacao */
                               NO-LOCK: 
           
            /* So traz cooperados que nao estao demitidos */
            FIND crapass WHERE crapass.cdcooper = craplim.cdcooper AND
                               crapass.nrdconta = craplim.nrdconta 
                               NO-LOCK NO-ERROR.
    
            IF  NOT AVAIL crapass THEN 
                NEXT.

            IF  crapass.dtdemiss <> ? THEN
                NEXT.

            /* Buscar valor parametrizado para digitalizacao de Limites (Lim de credito) - TAB093 */
            FIND tt-documentos WHERE tt-documentos.idseqite = 19 
                               NO-LOCK NO-ERROR.
            
            IF  AVAIL tt-documentos  THEN
                ASSIGN aux_vllimite = tt-documentos.vldparam
                       aux_tpdocmto = tt-documentos.tpdocmto.
            ELSE
                ASSIGN aux_vllimite = 0
                       aux_tpdocmto = 0.

            /* Verifica se o contrato ja foi digitalizado */
            FIND FIRST tt-documento-digitalizado WHERE
                       tt-documento-digitalizado.cdcooper = craplim.cdcooper AND
                       tt-documento-digitalizado.nrdconta = craplim.nrdconta AND
                       tt-documento-digitalizado.nrctrato = craplim.nrctrlim AND
                       tt-documento-digitalizado.tpdocmto = aux_tpdocmto
                       EXCLUSIVE-LOCK NO-ERROR.
            
            /* Caso encontrar o bordero digitalizado, altera flag e vai proximo */
            IF  AVAIL tt-documento-digitalizado  THEN
                DO:  
                    FIND b-craplim WHERE b-craplim.cdcooper = craplim.cdcooper AND        
                                         b-craplim.nrdconta = craplim.nrdconta AND
                                         b-craplim.tpctrlim = craplim.tpctrlim AND
                                         b-craplim.nrctrlim = craplim.nrctrlim
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                    IF  AVAIL (b-craplim)  THEN
                        ASSIGN b-craplim.flgdigit = TRUE.
                    NEXT.
                END. 
            
            /* Se nao foi digitalizado  */
            IF  NOT craplim.flgdigit  THEN  
                DO:  
                    /* Desprezar do dia, pois ainda nao foram digitalizados */
                    IF  craplim.dtinivig <= crapdat.dtmvtoan  THEN
                        DO:
                            /* Criar registro para listar no relatorio */
                            CREATE tt-contr_ndigi.
                            ASSIGN tt-contr_ndigi.cdcooper = craplim.cdcooper
                                   tt-contr_ndigi.nrdconta = craplim.nrdconta
                                   tt-contr_ndigi.dtmvtolt = craplim.dtpropos
                                   tt-contr_ndigi.dtlibera = craplim.dtinivig
                                   tt-contr_ndigi.cdagenci = crapass.cdagenci
                                   tt-contr_ndigi.cdbanchq = 0
                                   tt-contr_ndigi.nrdolote = 0
                                   tt-contr_ndigi.nrdcontr = craplim.nrctrlim
                                   tt-contr_ndigi.vldodesc = craplim.vllimite
                                   tt-contr_ndigi.idseqite = aux_tpdocmto
                                   tt-contr_ndigi.tpctrdig = 1.
                        END.
                END.
        END. /* Fim do for each craplim */     

        /* Zerar variaveis de controle de parametros */ 
        ASSIGN aux_tpdocmto = 0.
    
        /* Buscar valor parametrizado para digitalizacao de Contrt. 
           emprestimo/financiamento - TAB093 */
        FIND tt-documentos WHERE 
             tt-documentos.idseqite = 5 NO-LOCK NO-ERROR.
    
        IF  AVAIL tt-documentos  THEN
            ASSIGN aux_tpdocmto = tt-documentos.tpdocmto.
        
        /* Emprestimo - Data de Liberacao */
        FOR EACH crapepr WHERE crapepr.cdcooper = par_cdcooper   AND
                               crapepr.dtmvtolt = aux_data       AND
                     NOT CAN-DO("3,4,10", STRING(crapepr.cdorigem)) AND
                     NOT CAN-DO("100,800,850,900,6901,6902,6903,6904,6905", 
                                STRING(crapepr.cdlcremp)) 
                     NO-LOCK:
    
            /* So traz cooperados que nao estao demitidos */
            FIND crapass WHERE crapass.cdcooper = crapepr.cdcooper AND
                               crapass.nrdconta = crapepr.nrdconta 
                               NO-LOCK NO-ERROR.
    
            IF  NOT AVAIL crapass THEN 
                NEXT.

            IF  crapass.dtdemiss <> ? THEN
                NEXT.

            /* Verifica se o contrato foi digitalizado */
            FIND FIRST tt-documento-digitalizado WHERE
                       tt-documento-digitalizado.cdcooper = crapepr.cdcooper AND
                       tt-documento-digitalizado.nrdconta = crapepr.nrdconta AND
                       tt-documento-digitalizado.nrctrato = crapepr.nrctremp AND
                       tt-documento-digitalizado.tpdocmto = aux_tpdocmto
                       NO-LOCK NO-ERROR NO-WAIT.
    
            /* Caso encontrar o contrato digitalizado, altera flag e vai para o proximo */
            IF AVAIL tt-documento-digitalizado  THEN
                DO:
                    FIND b-crapepr WHERE b-crapepr.cdcooper = crapepr.cdcooper AND        
                                         b-crapepr.nrctremp = crapepr.nrctremp AND
                                         b-crapepr.nrdconta = crapepr.nrdconta
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                    IF  AVAILABLE(b-crapepr)  THEN
                        ASSIGN b-crapepr.flgdigit = TRUE.
                    NEXT.
        
                END.
    
            IF  NOT crapepr.flgdigit  THEN
                /* Desprezar do dia, pois ainda nao foram digitalizados */
                IF  crapepr.dtmvtolt <= crapdat.dtmvtoan  THEN
                    DO:
                        FIND crawepr WHERE crawepr.cdcooper = crapepr.cdcooper AND        
                                           crawepr.nrctremp = crapepr.nrctremp AND
                                           crawepr.nrdconta = crapepr.nrdconta 
                                           NO-LOCK NO-ERROR NO-WAIT.
                    
                        IF  AVAIL crawepr THEN
                            DO:
                                /* Criar registro para listar no relatorio */
                                CREATE tt-contr_ndigi.
                                ASSIGN tt-contr_ndigi.cdcooper = crapepr.cdcooper
                                       tt-contr_ndigi.nrdconta = crapepr.nrdconta
                                       tt-contr_ndigi.dtlibera = crapepr.dtmvtolt
                                       tt-contr_ndigi.dtmvtolt = crawepr.dtmvtolt
                                       tt-contr_ndigi.cdagenci = crapepr.cdagenci
                                       tt-contr_ndigi.cdbanchq = crapepr.cdbccxlt
                                       tt-contr_ndigi.nrdolote = crapepr.nrdolote
                                       tt-contr_ndigi.nrdcontr = crapepr.nrctremp
                                       tt-contr_ndigi.vldodesc = crapepr.vlemprst 
                                       tt-contr_ndigi.tpctrdig = 5
                                       tt-contr_ndigi.idseqite = aux_tpdocmto.
                            END.
                         ELSE
                             DO:
                                /* Criar registro para listar no relatorio */
                                CREATE tt-contr_ndigi.
                                ASSIGN tt-contr_ndigi.cdcooper = crapepr.cdcooper
                                       tt-contr_ndigi.nrdconta = crapepr.nrdconta
                                       tt-contr_ndigi.dtlibera = crapepr.dtmvtolt
                                       tt-contr_ndigi.dtmvtolt = crapepr.dtmvtolt
                                       tt-contr_ndigi.cdagenci = crapepr.cdagenci
                                       tt-contr_ndigi.cdbanchq = crapepr.cdbccxlt
                                       tt-contr_ndigi.nrdolote = crapepr.nrdolote
                                       tt-contr_ndigi.nrdcontr = crapepr.nrctremp
                                       tt-contr_ndigi.vldodesc = crapepr.vlemprst 
                                       tt-contr_ndigi.tpctrdig = 5
                                       tt-contr_ndigi.idseqite = aux_tpdocmto.               
                             END.
                    END.
        END. /* Fim do FOR EACH crpepr */
    END. /* Fim do DO aux_data */

    /* Verificar se existe registro para gerar no relatorio. */
    FIND FIRST tt-contr_ndigi WHERE tt-contr_ndigi.cdcooper = par_cdcooper
                              NO-LOCK NO-ERROR.

    IF  NOT AVAIL tt-contr_ndigi THEN
        NEXT.

    IF par_inchamad = 0 THEN /* crps */
    DO:
        { sistema/generico/includes/b1cabrelvar.i }
    
        FOR EACH tt-contr_ndigi WHERE tt-contr_ndigi.cdcooper = par_cdcooper
                                NO-LOCK USE-INDEX tt-contr_ndigi1
                                BREAK BY tt-contr_ndigi.cdcooper
                                      BY tt-contr_ndigi.cdagenci
                                      BY tt-contr_ndigi.idseqite
                                      BY tt-contr_ndigi.dtlibera
                                      BY tt-contr_ndigi.nrdconta.
            
            /* QUEBRA DE AGENCIA */
            IF  FIRST-OF (tt-contr_ndigi.cdagenci) THEN
                DO:
                
                    FIND FIRST crapage WHERE crapage.cdcooper = tt-contr_ndigi.cdcooper AND
                                             crapage.cdagenci = tt-contr_ndigi.cdagenci 
                                             NO-LOCK NO-ERROR.
                    
                    rel_dsagenci = "PA: " + STRING(tt-contr_ndigi.cdagenci,"zzz9") + " - ".
            
                    IF  AVAIL crapage THEN
                        rel_dsagenci = rel_dsagenci + crapage.nmresage.
                    ELSE
                        rel_dsagenci = rel_dsagenci + "*** PA NAO CADASTRADO ***".
                    
                    ASSIGN aux_nmarqimp = "/usr/coop/" + crapcop.dsdircop + 
                                          "/rl/" + "crrl620_credito_" + 
                                          STRING(tt-contr_ndigi.cdagenci,"999") + ".lst" 
                           aux_contagen = 0. 
                    
                    OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED PAGE-SIZE 80. 
                        
                    { sistema/generico/includes/b1cabrel132.i "11" "620" }
    
                    FIND FIRST b-tt-contr_ndigi WHERE 
                               b-tt-contr_ndigi.cdcooper = par_cdcooper    AND
                               b-tt-contr_ndigi.cdagenci = tt-contr_ndigi.cdagenci
                               NO-LOCK NO-ERROR.
    
                    IF  AVAILABLE b-tt-contr_ndigi THEN
                        DO:
                            VIEW STREAM str_1 FRAME f_urgnt.
                            DISPLAY STREAM str_1 SKIP.
                            DISPLAY STREAM str_1 rel_dsagenci WITH FRAME f_pac.
                            DISPLAY STREAM str_1 SKIP.
                        END. 
                    
                END.
            
            /* NA QUEBRA DE TIPO DE DOCUMENTO */
            IF  FIRST-OF (tt-contr_ndigi.idseqite) THEN
                DO: 
                    ASSIGN aux_totcontr = 0
                           aux_titrelat = "".
                    
                    FIND tt-documentos WHERE 
                         tt-documentos.tpdocmto = tt-contr_ndigi.idseqite 
                         NO-LOCK NO-ERROR.
                    
                    IF  AVAIL tt-documentos THEN
                        ASSIGN aux_titrelat = tt-documentos.nmoperac.
                    ELSE
                        ASSIGN aux_titrelat = "*** TITULO NAO ENCONTRADO ***".
                    
                   DISPLAY STREAM str_1 aux_titrelat WITH FRAME f_dados_contr.
        
                END. 
            
            IF  tt-contr_ndigi.idseqite <= 89 THEN
                DO:
                    DISPLAY STREAM str_1 tt-contr_ndigi.nrdconta
                                         tt-contr_ndigi.dtmvtolt
                                         tt-contr_ndigi.dtlibera
                                         tt-contr_ndigi.cdagenci
                                         tt-contr_ndigi.cdbanchq
                                         tt-contr_ndigi.nrdolote
                                         tt-contr_ndigi.nrdcontr
                                         tt-contr_ndigi.vldodesc
                                         WITH FRAME f_contr.
    
                    DOWN WITH FRAME f_contr.
                END.
            ELSE
                DO:
                    DISPLAY STREAM str_1 tt-contr_ndigi.nrdconta
                                         tt-contr_ndigi.dtmvtolt
                                         tt-contr_ndigi.dtlibera
                                         tt-contr_ndigi.cdagenci
                                         tt-contr_ndigi.cdbanchq
                                         tt-contr_ndigi.nrdolote
                                         tt-contr_ndigi.nrdcontr
                                         tt-contr_ndigi.nraditiv
                                         tt-contr_ndigi.vldodesc
                                         WITH FRAME f_contr_3.
    
                    DOWN WITH FRAME f_contr_3.
                END.
    
            ASSIGN aux_totcontr = aux_totcontr + 1.
    
            /* ULTIMO DOCUMENTO DESTE TIPO DE DOCUMENTO */
            IF  LAST-OF (tt-contr_ndigi.idseqite) THEN
                DISPLAY STREAM str_1 aux_totcontr WITH FRAME f_tot_ctr.

            IF LAST-OF(tt-contr_ndigi.cdagenci) THEN
            DO:
                OUTPUT STREAM str_1 CLOSE.

                UNIX SILENT VALUE("cp " + aux_nmarqimp + " /usr/coop/" +
                              crapcop.dsdircop + "/salvar").
            END.
                
        END. 
    END.

    /*********************************************************************************/
    /******************************* RELATORIO DE TODOS OS PAs ***********************/
    /*********************************************************************************/
    
    /* GERAR RELATORIO DE NAO DIGITALIZADO PARA ENVIAR PARA COOPERATIVA (PARAMETRO NA TAB093) */
    IF par_inchamad = 1 THEN /* TELA */
        ASSIGN aux_nmarqucr = "crrl620_credito_" + "999" + ".txt".
    ELSE
        ASSIGN aux_nmarqucr = "crrl620_credito_" + "999" + ".lst".

    ASSIGN aux_nmarqcre = "/usr/coop/" + crapcop.dsdircop + 
                          "/rl/" + aux_nmarqucr

           par_nmarqcre = aux_nmarqcre
           
           aux_nmarqicr = "/micros/" + crapcop.dsdircop + "/crrl620_credito_999" + 
                          STRING(YEAR(par_datafina), "9999") + "-" +
                          STRING(MONTH(par_datafina), "99") +  "-" +
                          STRING(DAY(par_datafina), "99") + "-" + 
                          STRING(TIME) + ".txt"
           aux_contagen = 0.
    
    OUTPUT STREAM str_2 TO VALUE (aux_nmarqcre) PAGED PAGE-SIZE 80.
    
    { sistema/generico/includes/b1cabrel132_2.i "11" "620" }

    DISP STREAM str_2 SKIP.

    FOR EACH tt-contr_ndigi WHERE tt-contr_ndigi.cdcooper = par_cdcooper
                            NO-LOCK USE-INDEX tt-contr_ndigi1
                            BREAK BY tt-contr_ndigi.cdcooper
                                  BY tt-contr_ndigi.cdagenci
                                  BY tt-contr_ndigi.idseqite
                                  BY tt-contr_ndigi.dtlibera
                                  BY tt-contr_ndigi.nrdconta.
        
        /* QUEBRA DE AGENCIA */
        IF  FIRST-OF (tt-contr_ndigi.cdagenci) THEN
            DO:
            
                FIND crapage WHERE crapage.cdcooper = tt-contr_ndigi.cdcooper AND
                                   crapage.cdagenci = tt-contr_ndigi.cdagenci 
                                   NO-LOCK NO-ERROR.
                
                rel_dsagenci = "PA: " + STRING(tt-contr_ndigi.cdagenci,"zzz9") + " - ".
        
                IF  AVAIL crapage THEN
                    rel_dsagenci = rel_dsagenci + crapage.nmresage.
                ELSE
                    rel_dsagenci = rel_dsagenci + "*** PA NAO CADASTRADO ***".
                
                FIND FIRST b-tt-contr_ndigi WHERE 
                           b-tt-contr_ndigi.cdcooper = par_cdcooper    AND
                           b-tt-contr_ndigi.cdagenci = tt-contr_ndigi.cdagenci  
                           NO-LOCK NO-ERROR.

                IF  AVAILABLE b-tt-contr_ndigi THEN
                    DO:
                        IF aux_contagen <> 0 THEN
                            PAGE STREAM str_2. 
                            
                        VIEW STREAM str_2 FRAME f_urgnt.
                        DISPLAY STREAM str_2 SKIP.
                        DISPLAY STREAM str_2 rel_dsagenci WITH FRAME f_pac.
                        DISPLAY STREAM str_2 SKIP.
                        ASSIGN aux_contagen = 1.
                    END.
                
            END.
        
        /* NA QUEBRA DE TIPO DE DOCUMENTO */
        IF  FIRST-OF (tt-contr_ndigi.idseqite) THEN
            DO: 
                ASSIGN aux_totcontr = 0
                       aux_titrelat = "".
                
                FIND tt-documentos WHERE 
                     tt-documentos.tpdocmto = tt-contr_ndigi.idseqite 
                     NO-LOCK NO-ERROR.
                
                IF  AVAIL tt-documentos THEN
                    ASSIGN aux_titrelat = tt-documentos.nmoperac.
                ELSE
                    ASSIGN aux_titrelat = "*** TITULO NAO ENCONTRADO ***".
                
               DISPLAY STREAM str_2 aux_titrelat WITH FRAME f_dados_contr.
    
            END. 
        
        IF  tt-contr_ndigi.idseqite <= 89 THEN
            DO:
                DISPLAY STREAM str_2 tt-contr_ndigi.nrdconta
                                     tt-contr_ndigi.dtmvtolt
                                     tt-contr_ndigi.dtlibera
                                     tt-contr_ndigi.cdagenci
                                     tt-contr_ndigi.cdbanchq
                                     tt-contr_ndigi.nrdolote
                                     tt-contr_ndigi.nrdcontr
                                     tt-contr_ndigi.vldodesc
                                     WITH FRAME f_contr.

                DOWN WITH FRAME f_contr.
            END.
        ELSE
            DO:
                DISPLAY STREAM str_2 tt-contr_ndigi.nrdconta
                                     tt-contr_ndigi.dtmvtolt
                                     tt-contr_ndigi.dtlibera
                                     tt-contr_ndigi.cdagenci
                                     tt-contr_ndigi.cdbanchq
                                     tt-contr_ndigi.nrdolote
                                     tt-contr_ndigi.nrdcontr
                                     tt-contr_ndigi.nraditiv
                                     tt-contr_ndigi.vldodesc
                                     WITH FRAME f_contr_3.

                DOWN WITH FRAME f_contr_3.
            END.

        ASSIGN aux_totcontr = aux_totcontr + 1.

        /* ULTIMO DOCUMENTO DESTE TIPO DE DOCUMENTO */
        IF  LAST-OF (tt-contr_ndigi.idseqite) THEN
            DISPLAY STREAM str_2 aux_totcontr WITH FRAME f_tot_ctr.

    END.
    
    OUTPUT STREAM str_2 CLOSE.
    
    IF  par_inchamad = 1 THEN /* Tela */
        DO:
            UNIX SILENT VALUE("cp " + aux_nmarqcre + " /usr/coop/" + crapcop.dsdircop + 
                              "/converte/crrl620_credito_999.txt").
            
            FIND craprel WHERE craprel.cdcooper = par_cdcooper AND
                               craprel.cdrelato = 620 
                               EXCLUSIVE-LOCK NO-ERROR.
     
            IF  AVAIL craprel   THEN 
                ASSIGN craprel.ingerpdf = 2. /*Nao gera PDF */

            /* Envia o arquivo gerado por email */
            RUN sistema/generico/procedures/b1wgen0011.p 
                PERSISTENT SET h-b1wgen0011.
      
            RUN enviar_email_completo IN h-b1wgen0011 (INPUT par_cdcooper,
                                                       INPUT "b1wgen00137",
                                                       INPUT "AILOS<ailos@ailos.coop.br>",
                                                       INPUT par_emailbat,
                                                       INPUT "Rel.620 - RELACAO DE DOCUMENTOS"+
                                                             " DE CREDITO NAO DIGITALIZADOS",
                                                       INPUT "",
                                                       INPUT "crrl620_credito_999.txt",
                                                       INPUT "\nSegue anexo o Relatorio crrl620 " +
                                                             "da Cooperativa " + crapcop.nmrescop,
                                                       INPUT TRUE).

            DELETE PROCEDURE h-b1wgen0011.
        END.
    ELSE
        DO:  
            /* copia relatorio para "/usr/coop/COOPERATIVA/rlnsv/ARQ.lst"    */
            UNIX SILENT VALUE("cp " + aux_nmarqcre + " /usr/coop/" + crapcop.dsdircop + 
                              "/rlnsv/" + aux_nmarqucr).
            
            FIND craptab WHERE  craptab.cdcooper = par_cdcooper AND
                                craptab.nmsistem = "CRED"           AND
                                craptab.tptabela = "GENERI"         AND
                                craptab.cdempres = 00               AND
                                craptab.cdacesso = "DIGITEMAIL"     AND
                                craptab.tpregist = 0  NO-LOCK NO-ERROR.
    
            IF  AVAIL craptab  THEN
                DO:
                    
                    FIND craprel WHERE craprel.cdcooper = par_cdcooper AND
                                       craprel.cdrelato = 620 
                                       EXCLUSIVE-LOCK NO-ERROR.
     
                    IF  AVAIL craprel   THEN 
                        ASSIGN craprel.ingerpdf = 1. /* Gera PDF */

                    IF (SUBSTRING(craptab.dstextab, 1, 1) = "S") THEN 
                        DO:
                            ASSIGN aux_nmarqpcr = "/usr/coop/" + crapcop.dsdircop + 
                                                  "/converte/crrl620_credito_999.pdf".
                
                            RUN sistema/generico/procedures/b1wgen0024.p 
                                PERSISTENT SET h-b1wgen0024.
                
                            RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqcre,
                                                                    INPUT aux_nmarqpcr).
                            DELETE PROCEDURE h-b1wgen0024.
                            
                            /* Envia o arquivo gerado por email */
                            RUN sistema/generico/procedures/b1wgen0011.p 
                                PERSISTENT SET h-b1wgen0011.
                            
                            RUN enviar_email_completo IN h-b1wgen0011 (INPUT par_cdcooper,
                                                                       INPUT "b1wgen00137",
                                                                       INPUT "AILOS<ailos@ailos.coop.br>",
                                                                       INPUT ENTRY(3,craptab.dstextab,";"),
                                                                       INPUT "Rel.620 - RELACAO DE DOCUMENTOS"+
                                                                             " DE CREDITO NAO DIGITALIZADOS",
                                                                       INPUT "",
                                                                       INPUT "crrl620_credito_999.pdf",
                                                                       INPUT "\nSegue anexo o Relatorio crrl620 " +
                                                                             "da Cooperativa " + crapcop.nmrescop,
                                                                       INPUT TRUE).
                
                            DELETE PROCEDURE h-b1wgen0011.
                            
                        END.
                END.
            ELSE
                DO:
                    
                    ASSIGN aux_dscritic = "Nao foi possivel encontrar parametros em DIGITEMAIL.".
            
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - " + "crps620" + "' --> '" + " b1wgen00137 " +
                                      aux_dscritic + " >> /usr/coop/cecred/log/proc_batch.log").
                    RETURN "NOK".
                END.
        END.                  
    
    RETURN "OK".

END PROCEDURE.


/* GERA RELATORIO COM PENDENCIAS DE DOCUMENTOS DE CADASTRO NAO DIGITALIZADOS */
PROCEDURE efetua_batimento_ged_termos:
    
    DEFINE INPUT PARAMETER par_cdcooper AS INTEGER      NO-UNDO.
    DEFINE INPUT PARAMETER par_datainic AS DATE         NO-UNDO.
    DEFINE INPUT PARAMETER par_datafina AS DATE         NO-UNDO.
    DEFINE INPUT PARAMETER par_inchamad AS INTEGER      NO-UNDO.
    DEFINE INPUT PARAMETER par_emailbat AS CHAR         NO-UNDO.
    DEFINE OUTPUT PARAMETER par_nmarqter AS CHAR        NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    
    DEF VAR aux_idseqite AS INT                         NO-UNDO.
    DEF VAR aux_contdocs AS INT                         NO-UNDO.
    DEF VAR aux_conttabs AS INT                         NO-UNDO.
    DEF VAR aux_nmarqute AS CHAR                        NO-UNDO.
    DEF VAR aux_nmarqter AS CHAR                        NO-UNDO.
    DEF VAR aux_nmarqite AS CHAR                        NO-UNDO.
    DEF VAR aux_tottermo AS INT                         NO-UNDO.
    DEF VAR aux_titrelat AS CHAR                        NO-UNDO.
    DEF VAR aux_nmarqpte AS CHAR                        NO-UNDO.
    DEF VAR aux_contagen AS INT  INIT 0                 NO-UNDO.
    DEF VAR par_dtmvtolt AS DATE INIT TODAY             NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                        NO-UNDO.
    DEF VAR aux_data     AS DATE                        NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                      NO-UNDO.
    DEF VAR h-b1wgen0011 AS HANDLE                      NO-UNDO.
    DEF BUFFER b-crapemp FOR crapemp.
    DEF BUFFER b-tt-documentos-termo FOR tt-documentos-termo.

    FORM "DOCUMENTOS NAO DIGITALIZADOS - TERMOS" AT 14
         SKIP
         WITH WIDTH 234 NO-BOX NO-LABEL SIDE-LABELS FRAME f_urgnt.

    FORM rel_dsagenci AT   1 FORMAT "x(100)" NO-LABEL
         WITH WIDTH 132 NO-BOX NO-LABEL SIDE-LABELS FRAME f_pac.
   
    FORM SKIP(1)
         aux_titrelat AT 58 FORMAT "x(45)" 
         SKIP(2)         
         WITH WIDTH 132 NO-BOX NO-LABEL SIDE-LABELS CENTERED FRAME f_dados_contr.     
   
    FORM tt-documentos-termo.cdagenci  FORMAT "999"        COLUMN-LABEL "PA"
         tt-documentos-termo.nrdconta  FORMAT "zzzz,zzz,9" COLUMN-LABEL "CONTA/DV"
         tt-documentos-termo.dsempres  FORMAT "x(23)"      COLUMN-LABEL "TITULAR"
         tt-documentos-termo.dstpterm  FORMAT "x(13)"      COLUMN-LABEL "TIPO DE DOCTO"
         tt-documentos-termo.dtincalt  FORMAT "99/99/9999" COLUMN-LABEL "DATA INC."
         tt-documentos-termo.cdoperad  FORMAT "x(15)"      COLUMN-LABEL "OPERADOR"
         tt-documentos-termo.nmcontat  FORMAT "x(40)"      COLUMN-LABEL "CONTATO DA EMPRESA/COOPERADO"
         WITH DOWN WIDTH 132 CENTERED FRAME f_contr_2.

    FORM aux_tottermo LABEL "Quantidade Total"
         WITH DOWN NO-LABEL WIDTH 132 SIDE-LABELS FRAME f_tot_ter.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-documento-digitalizado.
    EMPTY TEMP-TABLE tt-documentos.


    /* ALIMENTA A TABELA DE PARAMETROS */
    FOR EACH craptab FIELDS(dstextab tpregist)                 WHERE
                           craptab.cdcooper = crapcop.cdcooper AND         
                           craptab.nmsistem = "CRED"           AND         
                           craptab.tptabela = "GENERI"         AND         
                           craptab.cdempres = 00               AND         
                           craptab.cdacesso = "DIGITALIZA"
                           NO-LOCK:

        IF  CAN-DO("108,109,124,125,126,127,162,163", ENTRY(3,craptab.dstextab,";")) THEN DO:

            CREATE tt-documentos.
            ASSIGN tt-documentos.vldparam = DECI(ENTRY(2,craptab.dstextab,";"))
                   tt-documentos.nmoperac = ENTRY(1,craptab.dstextab,";")
                   tt-documentos.tpdocmto = INTE(ENTRY(3,craptab.dstextab,";"))
                   tt-documentos.idseqite = craptab.tpregist.
        END.

    END.


    /* Chamado pelo CRPS, pegar docs digitalizados apenas do dia */
    IF par_inchamad = 0 THEN
    DO:
      ASSIGN aux_dtinidoc = TODAY
             aux_dtfimdoc = TODAY.
    END.
    ELSE
    DO:
      /* Adicionar intervalo de data, 2 em 2 meses */
    ASSIGN aux_dtinidoc = par_datainic
           aux_dtfimdoc = ADD-INTERVAL(aux_dtinidoc,02,'months').
    END.
        
    periodo:
    DO  WHILE TRUE:

        /*  CONSULTAR NO SMARTSHARE (SELBETTI) OS DOCUMENTOS
            QUE ESTAO DIGITALIZADOS */
        RUN lista-documentos-digitalizados(INPUT crapcop.cdcooper,
                                           INPUT aux_dtinidoc, /* DATA DE CONSULTA DE IMAGENS */
                                           INPUT aux_dtfimdoc,
                                           INPUT TABLE tt-documentos,
                                          OUTPUT TABLE tt-documento-digitalizado,
                                          OUTPUT TABLE tt-erro).   

        /* EM CASO DE ERRO, GERA LOG E PARTE PARA PROXIMA COOPERATIVA */
        IF RETURN-VALUE <> "OK"  THEN DO:
            
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
            IF  AVAIL tt-erro  THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE DO:
                ASSIGN aux_dscritic = "Erro ao listar documentos digitalizados no Smartshare.".
                        
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 1,
                               INPUT 1,
                               INPUT 1, /* SEQUENCIA */
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
            END.

            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + "crps620" + "' --> '"  + " b1wgen00137 " +
                   aux_dscritic + " >> /usr/coop/cecred/log/proc_batch.log").
            RETURN "NOK".
        END. /** FIM DO IF RETURN-VALUE **/
                   
        IF  aux_dtfimdoc >= par_datafina THEN 
            LEAVE periodo.  
             
         /* Adicionar intervalo de data, 3 em 3 meses */
         ASSIGN aux_dtinidoc = ADD-INTERVAL(aux_dtfimdoc,01,'days')
                aux_dtfimdoc = ADD-INTERVAL(aux_dtinidoc,03,'months').
                
         IF  aux_dtfimdoc >= TODAY THEN
             aux_dtfimdoc = TODAY.
    END. /** DO WHILE TRUE */
                              
    /*TIPO DE DOCUMENTO: 20 Termo Adesao*/
    ASSIGN aux_tpdocmto = 0
           aux_conttabs = 20.

    /* Buscar valor parametrizado para digitalizacao de Termo de adesao */
    FIND tt-documentos WHERE 
         tt-documentos.idseqite = aux_conttabs NO-LOCK NO-ERROR.

    IF  AVAIL tt-documentos  THEN
        ASSIGN aux_tpdocmto = tt-documentos.tpdocmto.

    DO  aux_data = par_datainic TO par_datafina:    

    FOR EACH crapemp FIELDS(cdcooper cdempres nrdconta nmresemp 
                                nmcontat cdoperad dtinccan)
                     WHERE crapemp.cdcooper = par_cdcooper AND
                           crapemp.flgpgtib = TRUE         AND
                           crapemp.flgdgfib = FALSE        AND 
                           crapemp.dtinccan = aux_data NO-LOCK:
        
        /* Se cooperado estiver demitidos nao gera no relatorio */
        FIND FIRST crapass WHERE 
                   crapass.cdcooper = crapemp.cdcooper AND
                   crapass.nrdconta = crapemp.nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapass THEN 
            NEXT.

        IF  crapass.dtdemiss <> ? THEN
            NEXT.
        
        /* Verifica se o contrato foi digitalizado */
        FIND FIRST tt-documento-digitalizado WHERE
                   tt-documento-digitalizado.cdcooper = crapemp.cdcooper AND
                   tt-documento-digitalizado.nrdconta = crapemp.nrdconta AND
                   tt-documento-digitalizado.tpdocmto = aux_tpdocmto     AND
                   tt-documento-digitalizado.dtpublic >= crapemp.dtinccan
                   NO-LOCK NO-ERROR NO-WAIT.

        /*Verifica se registro existe*/
        IF  AVAIL tt-documento-digitalizado  THEN DO:
            /*Verifica se documento foi digitalizado*/
            FIND FIRST b-crapemp
                 WHERE b-crapemp.cdcooper = crapemp.cdcooper
                   AND b-crapemp.nrdconta = crapemp.nrdconta 
             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            /*Caso encontre o arquivo digitalizado, altera flag do registro no banco*/
            IF  AVAIL b-crapemp THEN
                ASSIGN b-crapemp.flgdgfib = TRUE.

            NEXT.

        END.
        ELSE DO:
            FIND FIRST tt-documentos-termo
                 WHERE tt-documentos-termo.cdcooper = crapemp.cdcooper
                   AND tt-documentos-termo.cdagenci = crapass.cdagenci
                   AND tt-documentos-termo.nrdconta = crapemp.nrdconta
                   AND tt-documentos-termo.dstpterm = "ADESAO"
               NO-LOCK NO-ERROR.

            IF  NOT AVAIL tt-documentos-termo  THEN DO:
                /* Criar registro para listar no relatorio */
                CREATE tt-documentos-termo.
                ASSIGN tt-documentos-termo.cdcooper = crapemp.cdcooper
                       tt-documentos-termo.cdagenci = crapass.cdagenci 
                       tt-documentos-termo.dstpterm = "ADESAO"
                       tt-documentos-termo.dsempres = 
                            STRING(crapemp.cdempres,"9999") + " – " +
                                   crapemp.nmresemp
                       tt-documentos-termo.nrdconta = crapemp.nrdconta
                       tt-documentos-termo.nmcontat = crapemp.nmcontat
                       tt-documentos-termo.dtincalt = crapemp.dtinccan
                       tt-documentos-termo.cdoperad = crapemp.cdoperad
                       tt-documentos-termo.idseqite = aux_conttabs. /* Adesao */
            END.
            END.
        END.
    END.

    /*TIPO DE DOCUMENTO: 21 Termo Cancelamento*/
    ASSIGN aux_tpdocmto = 0
           aux_conttabs = 21.

    /* Buscar valor parametrizado p/ digitalizacao de Termos de cancelamento */
    FIND tt-documentos WHERE 
         tt-documentos.idseqite = aux_conttabs NO-LOCK NO-ERROR.

    IF  AVAIL tt-documentos  THEN
        ASSIGN aux_tpdocmto = tt-documentos.tpdocmto.

    DO  aux_data = par_datainic TO par_datafina:    
        
    FOR EACH crapemp FIELDS(cdcooper cdempres nrdconta nmresemp 
                                nmcontat cdoperad dtinccan)
                     WHERE crapemp.cdcooper = par_cdcooper AND
                           crapemp.flgpgtib = FALSE        AND
                           crapemp.flgdgfib = FALSE        AND
                           crapemp.dtultufp <> ?           AND 
                           crapemp.dtinccan = aux_data NO-LOCK:

        /* Se cooperado estiver demitidos nao gera no relatorio */
        FIND FIRST crapass WHERE 
                   crapass.cdcooper = crapemp.cdcooper AND
                   crapass.nrdconta = crapemp.nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapass THEN 
            NEXT.

        IF  crapass.dtdemiss <> ? THEN
            NEXT.

        /* Verifica se o contrato foi digitalizado */
        FIND FIRST tt-documento-digitalizado WHERE
                   tt-documento-digitalizado.cdcooper = crapemp.cdcooper AND
                   tt-documento-digitalizado.nrdconta = crapemp.nrdconta AND
                   tt-documento-digitalizado.tpdocmto = aux_tpdocmto     AND
                   tt-documento-digitalizado.dtpublic >= crapemp.dtinccan
                   NO-LOCK NO-ERROR NO-WAIT.


        /*Verifica se registro existe*/
        IF  AVAIL tt-documento-digitalizado  THEN DO:
            /*Verifica se documento foi digitalizado*/
            FIND FIRST b-crapemp
                 WHERE b-crapemp.cdcooper = crapemp.cdcooper
                   AND b-crapemp.nrdconta = crapemp.nrdconta
             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            /*Caso encontre o arquivo digitalizado, altera flag do registro no banco*/
            IF  AVAIL b-crapemp THEN
                ASSIGN b-crapemp.flgdgfib = TRUE.

            NEXT.

        END.
        ELSE DO:
            FIND FIRST tt-documentos-termo
                 WHERE tt-documentos-termo.cdcooper = crapemp.cdcooper
                   AND tt-documentos-termo.cdagenci = crapass.cdagenci
                   AND tt-documentos-termo.nrdconta = crapemp.nrdconta
                   AND tt-documentos-termo.dstpterm = "CANCELAMENTO"
               NO-LOCK NO-ERROR.

            /*Verifica se registro existe*/
            IF  NOT AVAIL tt-documentos-termo  THEN DO:
                /* Criar registro para listar no relatorio */
                CREATE tt-documentos-termo.
                ASSIGN tt-documentos-termo.cdcooper = crapemp.cdcooper
                       tt-documentos-termo.cdagenci = crapass.cdagenci 
                       tt-documentos-termo.dstpterm = "CANCELAMENTO"
                       tt-documentos-termo.dsempres = 
                            STRING(crapemp.cdempres, "9999") + " – " +
                                   crapemp.nmresemp
                       tt-documentos-termo.nrdconta = crapemp.nrdconta
                       tt-documentos-termo.nmcontat = crapemp.nmcontat
                       tt-documentos-termo.dtincalt = crapemp.dtinccan
                       tt-documentos-termo.cdoperad = crapemp.cdoperad 
                       tt-documentos-termo.idseqite = aux_conttabs. /* Cancelamento */
            END.
            END.
        END.
    END.

    /* TIPO DE DOCUMENTO: 37 Termo PEP - pessoa exposta politicamente */
    ASSIGN aux_tpdocmto = 0
           aux_conttabs = 37.

    /* Buscar valor parametrizado p/ digitalizacao de declaracao pep */
    FIND tt-documentos WHERE 
         tt-documentos.idseqite = aux_conttabs NO-LOCK NO-ERROR.

    IF  AVAIL tt-documentos  THEN
        ASSIGN aux_tpdocmto = tt-documentos.tpdocmto.

   
    
    DO  aux_data = par_datainic TO par_datafina:

    FOR EACH crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                           crapdoc.dtmvtolt = aux_data     AND
                           crapdoc.tpdocmto = aux_conttabs AND
                           crapdoc.flgdigit = FALSE        AND
                           crapdoc.tpbxapen = 0
                           NO-LOCK:
                               
        /* Se cooperado estiver demitido nao gera no relatorio */
        FIND FIRST crapass WHERE 
                   crapass.cdcooper = crapdoc.cdcooper AND
                   crapass.nrdconta = crapdoc.nrdconta NO-LOCK NO-ERROR.
            
        IF  NOT AVAIL crapass THEN 
            NEXT.
            
        IF  crapass.dtdemiss <> ? THEN
            NEXT.

        /* Verifica se a declaracao de pep foi digitalizada */
        FIND FIRST tt-documento-digitalizado WHERE
                   tt-documento-digitalizado.cdcooper = crapdoc.cdcooper AND
                   tt-documento-digitalizado.nrdconta = crapdoc.nrdconta AND
                       tt-documento-digitalizado.nrcpfcgc = crapdoc.nrcpfcgc AND
                       tt-documento-digitalizado.tpdocmto = aux_tpdocmto     AND
                       tt-documento-digitalizado.dtpublic >= crapdoc.dtmvtolt
                       NO-LOCK NO-ERROR NO-WAIT.
					        
                       
        IF NOT AVAIL tt-documento-digitalizado  THEN
           DO:
        /* Verifica se a declaracao de pep foi digitalizada */
        FIND FIRST tt-documento-digitalizado WHERE
                   tt-documento-digitalizado.cdcooper = crapdoc.cdcooper AND
                   tt-documento-digitalizado.nrdconta = crapdoc.nrdconta AND
                       tt-documento-digitalizado.tpdocmto = aux_tpdocmto     AND
                       tt-documento-digitalizado.dtpublic >= crapdoc.dtmvtolt
                   NO-LOCK NO-ERROR NO-WAIT.
                       
           END.

       IF NOT AVAIL tt-documento-digitalizado  THEN
          DO:
            /* Verifica se a declaracao de pep foi digitalizada */
            FIND FIRST tt-documento-digitalizado WHERE
                       tt-documento-digitalizado.cdcooper = crapdoc.cdcooper AND
                       tt-documento-digitalizado.nrcpfcgc = crapdoc.nrcpfcgc AND
                       tt-documento-digitalizado.tpdocmto = aux_tpdocmto     AND
                       tt-documento-digitalizado.dtpublic >= crapdoc.dtmvtolt
                   NO-LOCK NO-ERROR NO-WAIT.
          END.

        /*Verifica se registro existe*/
        IF  AVAIL tt-documento-digitalizado  THEN DO:
            /*Verifica se documento foi digitalizado*/
            FIND FIRST b-crapdoc
                 WHERE b-crapdoc.cdcooper = crapdoc.cdcooper
                   AND b-crapdoc.dtmvtolt = crapdoc.dtmvtolt
                       AND b-crapdoc.tpdocmto = crapdoc.tpdocmto
                           AND b-crapdoc.nrdconta = crapdoc.nrdconta
                           AND b-crapdoc.idseqttl = crapdoc.idseqttl
             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            /*Caso encontre o arquivo digitalizado, altera flag do registro no banco*/
            IF  AVAIL b-crapdoc THEN
                ASSIGN b-crapdoc.flgdigit = TRUE
                       b-crapdoc.tpbxapen = 4 /* Baixa por digitalizaçao */
                       b-crapdoc.dtbxapen = TODAY 
                       b-crapdoc.cdopebxa = "1".
                       
            NEXT.

        END.
        ELSE DO:
            FIND FIRST tt-documentos-termo
                 WHERE tt-documentos-termo.cdcooper = crapdoc.cdcooper
                   AND tt-documentos-termo.cdagenci = crapass.cdagenci
                   AND tt-documentos-termo.nrdconta = crapdoc.nrdconta
                   AND tt-documentos-termo.dstpterm = "DECLARACAOPEP"
               NO-LOCK NO-ERROR.

            /*Verifica se registro existe*/
            IF  NOT AVAIL tt-documentos-termo  THEN DO:
                         
                        /* Buscar agencia em que o operador trabalha */
                        FIND FIRST crapope WHERE crapope.cdcooper = crapdoc.cdcooper
                                             AND crapope.cdoperad = crapdoc.cdoperad
                                             NO-LOCK NO-ERROR.
                         
                /* Criar registro para listar no relatorio */
                CREATE tt-documentos-termo.
                ASSIGN tt-documentos-termo.cdcooper = crapdoc.cdcooper
                           tt-documentos-termo.cdagenci = crapope.cdpactra WHEN AVAILABLE crapope 
                       tt-documentos-termo.dstpterm = "DECLARACAOPEP"
                           tt-documentos-termo.dsempres = crapass.nmprimtl
                       tt-documentos-termo.nrdconta = crapdoc.nrdconta
                           tt-documentos-termo.nmcontat = " "
                           tt-documentos-termo.dtincalt = crapdoc.dtmvtolt
                           tt-documentos-termo.cdoperad = crapdoc.cdoperad 
                           tt-documentos-termo.idseqite = aux_conttabs. /* Declaracao PEP */
                           
            END.
        END.
    END. /* fim for each crapdoc */
    END.
    /* fim tipo de documento 37 */

    /* TIPO DE DOCUMENTO: 55 Termo Declaracao Simples Nacional */
    ASSIGN aux_tpdocmto = 0
           aux_conttabs = 55.
    /* Buscar valor parametrizado p/ digitalizacao de declaracao pep */
    FIND tt-documentos WHERE 
         tt-documentos.idseqite = aux_conttabs NO-LOCK NO-ERROR.
    IF  AVAIL tt-documentos  THEN
        ASSIGN aux_tpdocmto = tt-documentos.tpdocmto.
    DO  aux_data = par_datainic TO par_datafina:
    FOR EACH crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                           crapdoc.dtmvtolt = aux_data     AND
                           crapdoc.tpdocmto = aux_conttabs AND
                           crapdoc.flgdigit = FALSE        AND
                           crapdoc.tpbxapen = 0
                           NO-LOCK:
        /* Se cooperado estiver demitido nao gera no relatorio */
        FIND FIRST crapass WHERE 
                   crapass.cdcooper = crapdoc.cdcooper AND
                   crapass.nrdconta = crapdoc.nrdconta NO-LOCK NO-ERROR.
        IF  NOT AVAIL crapass THEN 
            NEXT.
        IF  crapass.dtdemiss <> ? THEN
            NEXT.
        /* Verifica se a declaracao de pep foi digitalizada */
        FIND FIRST tt-documento-digitalizado WHERE
                   tt-documento-digitalizado.cdcooper = crapdoc.cdcooper AND
                   tt-documento-digitalizado.nrdconta = crapdoc.nrdconta AND
                       tt-documento-digitalizado.tpdocmto = aux_tpdocmto     AND
                       tt-documento-digitalizado.dtpublic >= crapdoc.dtmvtolt
                   NO-LOCK NO-ERROR NO-WAIT.
        /*Verifica se registro existe*/
        IF  AVAIL tt-documento-digitalizado  THEN DO:
            /*Verifica se documento foi digitalizado*/
            FIND FIRST b-crapdoc
                 WHERE b-crapdoc.cdcooper = crapdoc.cdcooper
                   AND b-crapdoc.dtmvtolt = crapdoc.dtmvtolt
                       AND b-crapdoc.tpdocmto = crapdoc.tpdocmto
                           AND b-crapdoc.nrdconta = crapdoc.nrdconta
                           AND b-crapdoc.idseqttl = crapdoc.idseqttl
             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            /*Caso encontre o arquivo digitalizado, altera flag do registro no banco*/
            IF  AVAIL b-crapdoc THEN
                ASSIGN b-crapdoc.flgdigit = TRUE
                       b-crapdoc.tpbxapen = 4 /* Baixa por digitalizaçao */
                       b-crapdoc.dtbxapen = TODAY 
                       b-crapdoc.cdopebxa = "1".
                       
            NEXT.
        END.
        ELSE DO:
            FIND FIRST tt-documentos-termo
                 WHERE tt-documentos-termo.cdcooper = crapdoc.cdcooper
                   AND tt-documentos-termo.nrdconta = crapdoc.nrdconta
                   AND tt-documentos-termo.dstpterm = "SIMPLESNACIONAL"
               NO-LOCK NO-ERROR.
            /*Verifica se registro existe*/
            IF  NOT AVAIL tt-documentos-termo  THEN DO:
                        /* Buscar agencia em que o operador trabalha */
                        FIND FIRST crapope WHERE crapope.cdcooper = crapdoc.cdcooper
                                             AND crapope.cdoperad = crapdoc.cdoperad
                                             NO-LOCK NO-ERROR.
                /* Criar registro para listar no relatorio */
                CREATE tt-documentos-termo.
                ASSIGN tt-documentos-termo.cdcooper = crapdoc.cdcooper
                           tt-documentos-termo.cdagenci = crapope.cdpactra WHEN AVAILABLE crapope 
                       tt-documentos-termo.dstpterm = "SIMPLESNACIONAL"
                           tt-documentos-termo.dsempres = crapass.nmprimtl
                       tt-documentos-termo.nrdconta = crapdoc.nrdconta
                           tt-documentos-termo.nmcontat = " "
                           tt-documentos-termo.dtincalt = crapdoc.dtmvtolt
                           tt-documentos-termo.cdoperad = crapdoc.cdoperad 
                           tt-documentos-termo.idseqite = aux_conttabs. /* Declaracao Simples Nacional */
            END.
        END.
    END. /* fim for each crapdoc */
    END.
    /* fim tipo de documento 55 */
	  /* TIPO DE DOCUMENTO: 56 Declaracao Pessoa Juridica Cooperativa */
    ASSIGN aux_tpdocmto = 0
           aux_conttabs = 56.
    /* Buscar valor parametrizado p/ digitalizacao de declaracao PJ Cooperativa */
    FIND tt-documentos WHERE 
         tt-documentos.idseqite = aux_conttabs NO-LOCK NO-ERROR.
    IF  AVAIL tt-documentos  THEN
        ASSIGN aux_tpdocmto = tt-documentos.tpdocmto.
    DO  aux_data = par_datainic TO par_datafina:
    FOR EACH crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                           crapdoc.dtmvtolt = aux_data     AND
                           crapdoc.tpdocmto = aux_conttabs AND
                           crapdoc.flgdigit = FALSE        AND
                           crapdoc.tpbxapen = 0
                           NO-LOCK:
        /* Se cooperado estiver demitido nao gera no relatorio */
        FIND FIRST crapass WHERE 
                   crapass.cdcooper = crapdoc.cdcooper AND
                   crapass.nrdconta = crapdoc.nrdconta NO-LOCK NO-ERROR.
        IF  NOT AVAIL crapass THEN 
            NEXT.
        IF  crapass.dtdemiss <> ? THEN
            NEXT.
        /* Verifica se a declaracao de pep foi digitalizada */
        FIND FIRST tt-documento-digitalizado WHERE
                   tt-documento-digitalizado.cdcooper = crapdoc.cdcooper AND
                   tt-documento-digitalizado.nrdconta = crapdoc.nrdconta AND
                       tt-documento-digitalizado.tpdocmto = aux_tpdocmto     AND
                       tt-documento-digitalizado.dtpublic >= crapdoc.dtmvtolt
                   NO-LOCK NO-ERROR NO-WAIT.
        /*Verifica se registro existe*/
        IF  AVAIL tt-documento-digitalizado  THEN DO:
            /*Verifica se documento foi digitalizado*/
            FIND FIRST b-crapdoc
                 WHERE b-crapdoc.cdcooper = crapdoc.cdcooper
                   AND b-crapdoc.dtmvtolt = crapdoc.dtmvtolt
                       AND b-crapdoc.tpdocmto = crapdoc.tpdocmto
                           AND b-crapdoc.nrdconta = crapdoc.nrdconta
                           AND b-crapdoc.idseqttl = crapdoc.idseqttl
             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            /*Caso encontre o arquivo digitalizado, altera flag do registro no banco*/
            IF  AVAIL b-crapdoc THEN
                ASSIGN b-crapdoc.flgdigit = TRUE
                       b-crapdoc.tpbxapen = 4 /* Baixa por digitalizaçao */
                       b-crapdoc.dtbxapen = TODAY 
                       b-crapdoc.cdopebxa = "1".
                       
            NEXT.
        END.
        ELSE DO:
            FIND FIRST tt-documentos-termo
                 WHERE tt-documentos-termo.cdcooper = crapdoc.cdcooper
                   AND tt-documentos-termo.nrdconta = crapdoc.nrdconta
                   AND tt-documentos-termo.dstpterm = "PJCOOPERATIVA"
               NO-LOCK NO-ERROR.
            /*Verifica se registro existe*/
            IF  NOT AVAIL tt-documentos-termo  THEN DO:
                        /* Buscar agencia em que o operador trabalha */
                        FIND FIRST crapope WHERE crapope.cdcooper = crapdoc.cdcooper
                                             AND crapope.cdoperad = crapdoc.cdoperad
                                             NO-LOCK NO-ERROR.
                /* Criar registro para listar no relatorio */
                CREATE tt-documentos-termo.
                ASSIGN tt-documentos-termo.cdcooper = crapdoc.cdcooper
                           tt-documentos-termo.cdagenci = crapope.cdpactra WHEN AVAILABLE crapope 
                       tt-documentos-termo.dstpterm = "PJCOOPERATIVA"
                           tt-documentos-termo.dsempres = crapass.nmprimtl
                       tt-documentos-termo.nrdconta = crapdoc.nrdconta
                           tt-documentos-termo.nmcontat = " "
                           tt-documentos-termo.dtincalt = crapdoc.dtmvtolt
                           tt-documentos-termo.cdoperad = crapdoc.cdoperad 
                           tt-documentos-termo.idseqite = aux_conttabs. /* Declaracao Pessoa Juridica Cooperativa */
            END.
        END.
    END. /* fim for each crapdoc */
    END.
    /* fim tipo de documento 56 */
    /*TIPO DE DOCUMENTO: 39 Termo Adesao*/
    ASSIGN aux_tpdocmto = 0
           aux_conttabs = 39.
    
    /* Buscar valor parametrizado para digitalizacao de Termo de adesao */
    FIND tt-documentos WHERE 
         tt-documentos.idseqite = aux_conttabs NO-LOCK NO-ERROR.
    
    IF  AVAIL tt-documentos  THEN
        ASSIGN aux_tpdocmto = tt-documentos.tpdocmto.

    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xRoot3        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont2     AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.

    /* Leitura do XML de novas aplicacoes */
    
   /* Inicializando objetos para leitura do XML */ 
   CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
   CREATE X-NODEREF  xRoot.   /* Vai conter a tag root em diante */ 
   CREATE X-NODEREF  xRoot2.  /* Vai conter a tag adesao/cancelamento em diante */ 
   CREATE X-NODEREF  xRoot3.  /* Vai conter a tag pacote em diante */ 
   CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
   CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

   /* Efetuar a chamada a rotina Oracle  */
   RUN STORED-PROCEDURE pc_busca_pacote_tarifas_ged
       aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                           OUTPUT ?,            /* XML com informaçoes de LOG */
                                           OUTPUT 0,            /* Código da crítica */
                                           OUTPUT "").          /* Descriçao da crítica */

   /* Fechar o procedimento para buscarmos o resultado */ 
  CLOSE STORED-PROC pc_busca_pacote_tarifas_ged
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
   
   /* Busca possíveis erros */ 
   ASSIGN aux_cdcritic = 0
          aux_dscritic = ""
          aux_cdcritic = pc_busca_pacote_tarifas_ged.pr_cdcritic 
                         WHEN pc_busca_pacote_tarifas_ged.pr_cdcritic <> ?
          aux_dscritic = pc_busca_pacote_tarifas_ged.pr_dscritic 
                         WHEN pc_busca_pacote_tarifas_ged.pr_dscritic <> ?.

   IF aux_cdcritic <> 0 OR
      aux_dscritic <> "" THEN
    DO:
        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = aux_cdcritic
               tt-erro.dscritic = aux_dscritic.
        
        RETURN "NOK".
        
     END.
   

   EMPTY TEMP-TABLE tt-tarif-contas-pacote.

   /*Leitura do XML de retorno da proc e criacao dos registros na tt-saldo-rdca
    para visualizacao dos registros na tela */
    
   /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_busca_pacote_tarifas_ged.pr_clobxmlc. 
        
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
       
    IF ponteiro_xml <> ? THEN
        DO:
            xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
            xDoc:GET-DOCUMENT-ELEMENT(xRoot).
        
            DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
        
                xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
        
                IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                 NEXT. 
                
                DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                    
                    xRoot2:GET-CHILD(xRoot3,aux_cont).
                        
                    IF xRoot3:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 

                    IF xRoot3:NUM-CHILDREN > 0 THEN
                        CREATE tt-tarif-contas-pacote.

                    DO aux_cont2 = 1 TO xRoot3:NUM-CHILDREN:
                    
                        xRoot3:GET-CHILD(xField,aux_cont2).
    
                        IF xField:SUBTYPE <> "ELEMENT" THEN 
                            NEXT. 
                        
                        xField:GET-CHILD(xText,1).
                       
                        ASSIGN tt-tarif-contas-pacote.nrdconta =  INT(xText:NODE-VALUE) WHEN xField:NAME = "nrdconta"
                               tt-tarif-contas-pacote.dtadesao = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtadesao"
                               tt-tarif-contas-pacote.cdopeade =      xText:NODE-VALUE  WHEN xField:NAME = "cdoperador_adesao"
                               tt-tarif-contas-pacote.dtcancel = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtcancelamento"
                               tt-tarif-contas-pacote.cdopecan =      xText:NODE-VALUE  WHEN xField:NAME = "cdoperador_cancela".
                    END.

                END. 
                
            END.
        
            SET-SIZE(ponteiro_xml) = 0. 
        END.

    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
    
    DO  aux_data = par_datainic TO par_datafina:
    
    FOR EACH tt-tarif-contas-pacote FIELDS(nrdconta dtadesao cdoperador_adesao)
                             WHERE tt-tarif-contas-pacote.dtcancel  = ?            
                               AND tt-tarif-contas-pacote.dtadesao = aux_data NO-LOCK:

        /* Se cooperado estiver demitidos nao gera no relatorio */
        FIND FIRST crapass WHERE 
                   crapass.cdcooper = par_cdcooper AND
                   crapass.nrdconta = tt-tarif-contas-pacote.nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapass THEN 
            NEXT.

        IF  crapass.dtdemiss <> ? THEN
            NEXT.
            
        /* Verifica se o contrato foi digitalizado */
        FIND FIRST tt-documento-digitalizado WHERE
                   tt-documento-digitalizado.cdcooper  = par_cdcooper AND
                   tt-documento-digitalizado.nrdconta  = tt-tarif-contas-pacote.nrdconta AND
                   tt-documento-digitalizado.tpdocmto  = aux_tpdocmto                   AND
                   tt-documento-digitalizado.dtpublic >= tt-tarif-contas-pacote.dtadesao
                   NO-LOCK NO-ERROR NO-WAIT.

        /*Verifica se registro existe*/
        IF AVAIL tt-documento-digitalizado  THEN DO:
            
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

            /* Efetuar a chamada a rotina Oracle  */
            RUN STORED-PROCEDURE pc_atualiza_digito_pacote
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                                     INPUT tt-tarif-contas-pacote.nrdconta, /* Nr. da conta */
                                                     INPUT 1,            /* Adesao*/
                                                    OUTPUT 0,            /* Código da crítica */
                                                    OUTPUT "").          /* Descriçao da crítica */

            /* Fechar o procedimento para buscarmos o resultado */ 
            CLOSE STORED-PROC pc_atualiza_digito_pacote
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

            NEXT.
          END.
        ELSE DO:

            FIND FIRST tt-documentos-termo
                 WHERE tt-documentos-termo.cdcooper = par_cdcooper
                   AND tt-documentos-termo.cdagenci = crapass.cdagenci
                   AND tt-documentos-termo.nrdconta = tt-tarif-contas-pacote.nrdconta
                   AND tt-documentos-termo.dstpterm = "ADESAO"
                   AND tt-documentos-termo.nmcontat = ""
                   AND tt-documentos-termo.dsempres = crapass.nmprimtl
                   AND tt-documentos-termo.idseqite = 39
                   AND tt-documentos-termo.dtincalt = tt-tarif-contas-pacote.dtadesao
               NO-LOCK NO-ERROR.

            IF  NOT AVAIL tt-documentos-termo  THEN DO:
                /* Criar registro para listar no relatorio */
                CREATE tt-documentos-termo.
                ASSIGN tt-documentos-termo.cdcooper = par_cdcooper
                       tt-documentos-termo.cdagenci = crapass.cdagenci 
                       tt-documentos-termo.dstpterm = "ADESAO"
                       tt-documentos-termo.dsempres = crapass.nmprimtl /* Titular */
                       tt-documentos-termo.nrdconta = tt-tarif-contas-pacote.nrdconta
                       tt-documentos-termo.nmcontat = ""
                       tt-documentos-termo.dtincalt = tt-tarif-contas-pacote.dtadesao
                       tt-documentos-termo.cdoperad = tt-tarif-contas-pacote.cdopeade
                       tt-documentos-termo.idseqite = aux_conttabs. /* Adesao */
            END.
            END.
        END.
    END.
    /* fim tipo de documento 39 */
    
    /*TIPO DE DOCUMENTO: 38 Termo Cancelamento*/
    ASSIGN aux_tpdocmto = 0
           aux_conttabs = 38.

    /* Buscar valor parametrizado p/ digitalizacao de Termos de cancelamento */
    FIND tt-documentos WHERE 
         tt-documentos.idseqite = aux_conttabs NO-LOCK NO-ERROR.

    IF  AVAIL tt-documentos  THEN
        ASSIGN aux_tpdocmto = tt-documentos.tpdocmto.

    DO  aux_data = par_datainic TO par_datafina:
    
    FOR EACH tt-tarif-contas-pacote FIELDS(cdcooper nrdconta dtcancelamento cdoperador_cancela)
                             WHERE tt-tarif-contas-pacote.dtcancel  <> ?           
                               AND tt-tarif-contas-pacote.dtcancel = aux_data NO-LOCK:

        /* Se cooperado estiver demitidos nao gera no relatorio */
        FIND FIRST crapass WHERE 
                   crapass.cdcooper = par_cdcooper AND
                   crapass.nrdconta = tt-tarif-contas-pacote.nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapass THEN 
            NEXT.

        IF  crapass.dtdemiss <> ? THEN
            NEXT.

        /* Verifica se o contrato foi digitalizado */
        FIND FIRST tt-documento-digitalizado WHERE
                   tt-documento-digitalizado.cdcooper  = par_cdcooper AND
                   tt-documento-digitalizado.nrdconta  = tt-tarif-contas-pacote.nrdconta AND
                   tt-documento-digitalizado.tpdocmto  = aux_tpdocmto                   AND
                   tt-documento-digitalizado.dtpublic >= tt-tarif-contas-pacote.dtcancel
                   NO-LOCK NO-ERROR NO-WAIT.

        /*Verifica se registro existe*/
        IF AVAIL tt-documento-digitalizado  THEN DO:
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

            /* Efetuar a chamada a rotina Oracle  */
            RUN STORED-PROCEDURE pc_atualiza_digito_pacote
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                                     INPUT tt-tarif-contas-pacote.nrdconta, /* Nr. da conta */
                                                     INPUT 2,            /* Cancelamento */
                                                    OUTPUT 0,            /* Código da crítica */
                                                    OUTPUT "").          /* Descriçao da crítica */

            /* Fechar o procedimento para buscarmos o resultado */ 
            CLOSE STORED-PROC pc_atualiza_digito_pacote
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

            NEXT.
          END.
        ELSE DO:
            FIND FIRST tt-documentos-termo
                 WHERE tt-documentos-termo.cdcooper = par_cdcooper
                   AND tt-documentos-termo.cdagenci = crapass.cdagenci
                   AND tt-documentos-termo.nrdconta = tt-tarif-contas-pacote.nrdconta
                   AND tt-documentos-termo.dstpterm = "CANCELAMENTO"
                   AND tt-documentos-termo.nmcontat = ""
                   AND tt-documentos-termo.dsempres = crapass.nmprimtl
                   AND tt-documentos-termo.idseqite = 38
                   AND tt-documentos-termo.dtincalt = tt-tarif-contas-pacote.dtcancel
               NO-LOCK NO-ERROR.

            IF  NOT AVAIL tt-documentos-termo  THEN DO:
                /* Criar registro para listar no relatorio */
                CREATE tt-documentos-termo.
                ASSIGN tt-documentos-termo.cdcooper = par_cdcooper
                       tt-documentos-termo.cdagenci = crapass.cdagenci 
                       tt-documentos-termo.dstpterm = "CANCELAMENTO"
                       tt-documentos-termo.dsempres = crapass.nmprimtl /* Titular */
                       tt-documentos-termo.nrdconta = tt-tarif-contas-pacote.nrdconta
                       tt-documentos-termo.nmcontat = ""
                       tt-documentos-termo.dtincalt = tt-tarif-contas-pacote.dtcancel
                       tt-documentos-termo.cdoperad = tt-tarif-contas-pacote.cdopecan
                       tt-documentos-termo.idseqite = aux_conttabs. /* Cancelamento */
            END.
            END.
        END.
    /* fim tipo de documento 38 */
    
    END. /* do aux_data */
    
    
    /* Verificar se existe registro para gerar no relatorio. */
    FIND FIRST tt-documentos-termo 
         WHERE tt-documentos-termo.cdcooper = par_cdcooper
       NO-LOCK NO-ERROR.

    IF  NOT AVAIL tt-documentos-termo THEN
        NEXT.

    IF  par_inchamad = 0 THEN /* crps */ DO:

        { sistema/generico/includes/b1cabrelvar.i }
        
        FOR EACH tt-documentos-termo NO-LOCK
           WHERE tt-documentos-termo.cdcooper = par_cdcooper
           BREAK BY tt-documentos-termo.cdcooper
                 BY tt-documentos-termo.cdagenci
                 BY tt-documentos-termo.idseqite
                 BY tt-documentos-termo.nrdconta.

            /* QUEBRA DE AGENCIA */
            IF  FIRST-OF (tt-documentos-termo.cdagenci) THEN 
                DO:                            
                FIND FIRST crapage 
                     WHERE crapage.cdcooper = tt-documentos-termo.cdcooper
                       AND crapage.cdagenci = tt-documentos-termo.cdagenci 
                   NO-LOCK NO-ERROR.
                        
                rel_dsagenci = "PA: " + 
                     STRING(tt-documentos-termo.cdagenci,"zzz9") + " - ".
                
                IF  AVAIL crapage THEN
                    rel_dsagenci = rel_dsagenci + crapage.nmresage.
                ELSE
                    rel_dsagenci = rel_dsagenci + "*** PA NAO CADASTRADO ***".

                    
                ASSIGN aux_nmarqimp = "/usr/coop/" + crapcop.dsdircop + 
                                      "/rl/" + "crrl620_termo_" + 
                           STRING(tt-documentos-termo.cdagenci,"999") + ".lst"
                       aux_contagen = 0
                       aux_tottermo = 0. 
                    
                OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp)
                           PAGED PAGE-SIZE 80. 
                        
                { sistema/generico/includes/b1cabrel132.i "11" "620" }
    
                 FIND FIRST b-tt-documentos-termo
                      WHERE b-tt-documentos-termo.cdcooper = par_cdcooper    
                            AND b-tt-documentos-termo.cdagenci = tt-documentos-termo.cdagenci
                    NO-LOCK NO-ERROR.
    
                    IF  AVAILABLE b-tt-documentos-termo THEN
                        DO:
                            VIEW STREAM str_1 FRAME f_urgnt.
                            DISPLAY STREAM str_1 SKIP.
                            DISPLAY STREAM str_1 rel_dsagenci WITH FRAME f_pac.
                            DISPLAY STREAM str_1 SKIP.
                        END. 
                END.
        
            /* NA QUEBRA DE TIPO DE DOCUMENTO */
            IF  FIRST-OF (tt-documentos-termo.idseqite) THEN
                DO: 
                    ASSIGN aux_tottermo = 0
                           aux_titrelat = "".
                    
                    FIND tt-documentos WHERE 
                         tt-documentos.idseqite = tt-documentos-termo.idseqite 
                         NO-LOCK NO-ERROR.
                    
                    IF  AVAIL tt-documentos THEN
                        ASSIGN aux_titrelat = tt-documentos.nmoperac.
                    ELSE
                        ASSIGN aux_titrelat = "*** TITULO NAO ENCONTRADO ***".
                    
                   DISPLAY STREAM str_1 aux_titrelat WITH FRAME f_dados_contr.
        
            END.
        
            DISPLAY STREAM str_1 tt-documentos-termo.cdagenci
                                 tt-documentos-termo.nrdconta
                                 tt-documentos-termo.dsempres
                                 tt-documentos-termo.dstpterm
                                 tt-documentos-termo.dtincalt
                                 tt-documentos-termo.cdoperad
                                 tt-documentos-termo.nmcontat
                      WITH FRAME f_contr_2.
        
            DOWN WITH FRAME f_contr_2.
                
            ASSIGN aux_tottermo = aux_tottermo + 1.
        
            /* ULTIMO DOCUMENTO DESTE TIPO DE DOCUMENTO */
            IF  LAST-OF (tt-documentos-termo.idseqite) THEN
                DISPLAY STREAM str_1 aux_tottermo WITH FRAME f_tot_ter.

            IF  LAST-OF(tt-documentos-termo.cdagenci) THEN
                DO:
                OUTPUT STREAM str_1 CLOSE.
    
                UNIX SILENT VALUE("cp " + aux_nmarqimp + " /usr/coop/" +
                                  crapcop.dsdircop + "/salvar").
            END.
                    
        END.  /** END do FOR EACH */
    END.

/*****************************************************************************/
/*************************** RELATORIO DE TODOS OS PAs ***********************/
/*****************************************************************************/
    
    /* GERAR RELATORIO DE NAO DIGITALIZADO PARA ENVIAR
       PARA COOPERATIVA (PARAMETRO NA TAB093) */

    IF  par_inchamad = 1 THEN /* TELA */
        ASSIGN aux_nmarqute = "crrl620_termo_" + "999" + ".txt".
    ELSE
        ASSIGN aux_nmarqute = "crrl620_termo_" + "999" + ".lst".

    ASSIGN aux_nmarqter = "/usr/coop/" + crapcop.dsdircop + 
                          "/rl/" + aux_nmarqute

           par_nmarqter = aux_nmarqter
           
           aux_nmarqite = "/micros/" + crapcop.dsdircop + 
                          "/crrl620_termo_999" + 
                          STRING(YEAR(par_datafina), "9999") + "-" +
                          STRING(MONTH(par_datafina), "99") +  "-" +
                          STRING(DAY(par_datafina), "99") + "-" + 
                          STRING(TIME) + ".txt"
           aux_contagen = 0
           aux_tottermo = 0.
    
    OUTPUT STREAM str_2 TO VALUE (aux_nmarqter) PAGED PAGE-SIZE 80.
    
    { sistema/generico/includes/b1cabrel132_2.i "11" "620" }

    DISP STREAM str_2 SKIP.

    FOR EACH tt-documentos-termo NO-LOCK
       WHERE tt-documentos-termo.cdcooper = par_cdcooper
           BREAK BY tt-documentos-termo.cdcooper
          BY tt-documentos-termo.cdagenci
                 BY tt-documentos-termo.idseqite
          BY tt-documentos-termo.nrdconta:

        /* QUEBRA DE AGENCIA */
        IF  FIRST-OF (tt-documentos-termo.cdagenci) THEN
            DO:            
                FIND crapage WHERE crapage.cdcooper = tt-documentos-termo.cdcooper AND
                                   crapage.cdagenci = tt-documentos-termo.cdagenci 
                                   NO-LOCK NO-ERROR.

                rel_dsagenci = "PA: " + STRING(tt-documentos-termo.cdagenci,"zzz9") + " - ".
        
                IF  AVAIL crapage THEN
                    rel_dsagenci = rel_dsagenci + crapage.nmresage.
                ELSE
                    rel_dsagenci = rel_dsagenci + "*** PA NAO CADASTRADO ***".
                
                FIND FIRST b-tt-documentos-termo WHERE 
                           b-tt-documentos-termo.cdcooper = par_cdcooper    AND
                           b-tt-documentos-termo.cdagenci = tt-documentos-termo.cdagenci  
                           NO-LOCK NO-ERROR.

                IF  AVAILABLE b-tt-documentos-termo THEN
                    DO:
                        IF aux_contagen <> 0 THEN
            PAGE STREAM str_2.

                        VIEW STREAM str_2 FRAME f_urgnt.
                        DISPLAY STREAM str_2 SKIP.
                        DISPLAY STREAM str_2 rel_dsagenci WITH FRAME f_pac.
                        DISPLAY STREAM str_2 SKIP.
                        ASSIGN aux_contagen = 1.
                    END.                
            END.

        /* NA QUEBRA DE TIPO DE DOCUMENTO */
        IF  FIRST-OF (tt-documentos-termo.idseqite) THEN
            DO: 
                ASSIGN aux_tottermo = 0
                       aux_titrelat = "".
                
                FIND tt-documentos WHERE 
                     tt-documentos.idseqite = tt-documentos-termo.idseqite 
                     NO-LOCK NO-ERROR.
                
                IF  AVAIL tt-documentos THEN
                    ASSIGN aux_titrelat = tt-documentos.nmoperac.
                ELSE
                    ASSIGN aux_titrelat = "*** TITULO NAO ENCONTRADO ***".
                
               DISPLAY STREAM str_2 aux_titrelat WITH FRAME f_dados_contr.
    
            END.     

        DISPLAY STREAM str_2 tt-documentos-termo.cdagenci
                             tt-documentos-termo.nrdconta
                             tt-documentos-termo.dsempres
                             tt-documentos-termo.dstpterm
                             tt-documentos-termo.dtincalt
                             tt-documentos-termo.cdoperad
                             tt-documentos-termo.nmcontat
                             WITH FRAME f_contr_2.       

        DOWN WITH FRAME f_contr_2.

        ASSIGN aux_tottermo = aux_tottermo + 1.
       
        /* ULTIMO DOCUMENTO DESTE TIPO DE DOCUMENTO */
        IF  LAST-OF (tt-documentos-termo.idseqite) THEN
            DISPLAY STREAM str_2 aux_tottermo WITH FRAME f_tot_ter.        
       
    END.

    OUTPUT STREAM str_2 CLOSE.
    
    IF  par_inchamad = 1 THEN /* Tela */ DO:

        UNIX SILENT VALUE("cp " + aux_nmarqter + " /usr/coop/" + 
                          crapcop.dsdircop + 
                          "/converte/crrl620_termo_999.txt").
            
        FIND craprel WHERE craprel.cdcooper = par_cdcooper AND
                           craprel.cdrelato = 620 
                 EXCLUSIVE-LOCK NO-ERROR.
     
            IF  AVAIL craprel   THEN 
                ASSIGN craprel.ingerpdf = 2. /*Nao gera PDF */

            /* Envia o arquivo gerado por email */
            RUN sistema/generico/procedures/b1wgen0011.p 
                PERSISTENT SET h-b1wgen0011.
      
            RUN enviar_email_completo IN h-b1wgen0011 (INPUT par_cdcooper,
                                                       INPUT "b1wgen00137",
                                                       INPUT "AILOS<ailos@ailos.coop.br>",
                                                       INPUT par_emailbat,
                                                       INPUT "Rel.620 - TERMOS DE FOLHA PAGTO NAO DIGITALIZADOS",
                                                       INPUT "",
                                                       INPUT "crrl620_termo_999.txt",
                                                       INPUT "\nSegue anexo o Relatorio crrl620 " +
                                                             "da Cooperativa " + crapcop.nmrescop,
                                                       INPUT TRUE).

            DELETE PROCEDURE h-b1wgen0011.
        END.
    ELSE
        DO:  
            /* copia relatorio para "/usr/coop/COOPERATIVA/rlnsv/ARQ.lst"    */
            UNIX SILENT VALUE("cp " + aux_nmarqter + " /usr/coop/" +
                              crapcop.dsdircop + "/rlnsv/" + aux_nmarqute).

            FIND craptab WHERE  craptab.cdcooper = par_cdcooper AND
                                craptab.nmsistem = "CRED"       AND
                                craptab.tptabela = "GENERI"     AND
                                craptab.cdempres = 00           AND
                                craptab.cdacesso = "DIGITEMAIL" AND
                                craptab.tpregist = 0  NO-LOCK NO-ERROR.
    
            IF  AVAIL craptab  THEN
                DO:
                    
                    FIND craprel WHERE craprel.cdcooper = par_cdcooper AND
                                       craprel.cdrelato = 620 
                                       EXCLUSIVE-LOCK NO-ERROR.
     
                    IF  AVAIL craprel   THEN 
                        ASSIGN craprel.ingerpdf = 1. /* Gera PDF */

                    IF (SUBSTRING(craptab.dstextab, 1, 1) = "S") THEN 
                        DO:
                            ASSIGN aux_nmarqpte = "/usr/coop/" + 
                                        crapcop.dsdircop + 
                                        "/converte/crrl620_termo_999.pdf".
                
                            RUN sistema/generico/procedures/b1wgen0024.p 
                                PERSISTENT SET h-b1wgen0024.
                
                            RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqter,
                                                                    INPUT aux_nmarqpte).
                            DELETE PROCEDURE h-b1wgen0024.
                            
                            /* Envia o arquivo gerado por email */
                            RUN sistema/generico/procedures/b1wgen0011.p 
                                PERSISTENT SET h-b1wgen0011.
                            
                            RUN enviar_email_completo IN h-b1wgen0011 (INPUT par_cdcooper,
                                                                       INPUT "b1wgen00137",
                                                                       INPUT "AILOS<ailos@ailos.coop.br>",
                                                                       INPUT ENTRY(3,craptab.dstextab,";"),
                                                                       INPUT "Rel.620 - TERMOS DE FOLHA PAGTO NÃO DIGITALIZADOS",
                                                                       INPUT "",
                                                                       INPUT "crrl620_termo_999.pdf",
                                                                       INPUT "\nSegue anexo o Relatorio crrl620 " +
                                                                             "da Cooperativa " + crapcop.nmrescop,
                                                                       INPUT TRUE).
                
                            DELETE PROCEDURE h-b1wgen0011.
                            
                        END.
                END.
            ELSE
                DO:
                    
                    ASSIGN aux_dscritic = "Nao foi possivel encontrar parametros em DIGITEMAIL.".
            
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - " + "crps620" + "' --> '" + " b1wgen00137 " +
                                      aux_dscritic + " >> /usr/coop/cecred/log/proc_batch.log").
                    RETURN "NOK".
                END.
        END.                  
    

    RETURN "OK".

END PROCEDURE.

PROCEDURE traz_situacao_documento:

    DEF  INPUT PARAM par_cdcooper AS INTE                 NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS CHAR                 NO-UNDO.
    DEF  INPUT PARAM par_tpdocmto AS INTE                 NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS CHAR                 NO-UNDO.
    DEF  INPUT PARAM par_nrborder AS CHAR                 NO-UNDO.
    DEF  INPUT PARAM par_nraditiv AS INTE                 NO-UNDO.
    DEF  INPUT PARAM par_desdekey AS CHAR                 NO-UNDO.

    DEF OUTPUT PARAM par_cdstatus AS INTE                 NO-UNDO.
    
    /* Novo trecho de codigo */
    DEF VAR aux_strconta AS INT NO-UNDO.
    DEF VAR aux_strctrat AS INT NO-UNDO.
    DEF VAR aux_strborde AS INT NO-UNDO.
    
    ASSIGN par_cdstatus = 2
           aux_strconta = LENGTH(par_nrdconta)
           aux_strctrat = LENGTH(par_nrctrato)
           aux_strborde = LENGTH(par_nrborder).
    
    /* VERIFICA SE CONTA FOI ENVIADO NO FORMATO CORRETO */
    CASE aux_strconta:
        WHEN 1 THEN
            ASSIGN par_cdstatus = 0.
        WHEN 2 THEN
            ASSIGN par_cdstatus = 0.
        WHEN 3 THEN
            DO:
                IF INDEX(par_nrdconta,".",1) <> 2 THEN
                    ASSIGN par_cdstatus = 0.
            END.
        WHEN 4 THEN
            DO:
                IF INDEX(par_nrdconta,".",1) <> 3 THEN 
                    ASSIGN par_cdstatus = 0.
            END.
        WHEN 5 THEN
            DO:
                IF INDEX(par_nrdconta,".",1) <> 4 THEN
                    ASSIGN par_cdstatus = 0.
            END.
        WHEN 6 THEN
            ASSIGN par_cdstatus = 0.
        WHEN 7 THEN
            DO:
               IF INDEX(par_nrdconta,".",1) <> 2 OR INDEX(par_nrdconta,".",INDEX(par_nrdconta,".",1) + 1) <> 6 THEN
                    ASSIGN par_cdstatus = 0.
           END.
        WHEN 8 THEN
            DO:
               IF INDEX(par_nrdconta,".",1) <> 3 OR INDEX(par_nrdconta,".",INDEX(par_nrdconta,".",1) + 1) <> 7 THEN
                   ASSIGN par_cdstatus = 0.
           END.
        WHEN 9 THEN
            DO:
               IF INDEX(par_nrdconta,".",1) <> 4 OR INDEX(par_nrdconta,".",INDEX(par_nrdconta,".",1) + 1) <> 8 THEN
               DO:
                    ASSIGN par_cdstatus = 0.
               END.
                
           END.
        WHEN 10 THEN
            DO:
               IF INDEX(par_nrdconta,".",1) <> 5 OR INDEX(par_nrdconta,".",INDEX(par_nrdconta,".",1) + 1) <> 9 THEN
                   ASSIGN par_cdstatus = 0.
           END.
        OTHERWISE DO:
            ASSIGN par_cdstatus = 0.
        END.
    END CASE.
   
    /* VERIFICA SE CONTRATO FOI ENVIADO NO FORMATO CORRETO */
    IF par_cdstatus <> 0 AND aux_strctrat <> 0 THEN
        DO:
            CASE aux_strctrat:
                WHEN 1 THEN
                    DO:
                        INT(par_nrctrato) NO-ERROR.

                        IF  ERROR-STATUS:ERROR THEN
                        DO:
                            ASSIGN par_cdstatus = 0.
                        END.
                    END.
                WHEN 2 THEN
                    DO:
                        INT(par_nrctrato) NO-ERROR.

                        IF  ERROR-STATUS:ERROR THEN
                        DO:
                            ASSIGN par_cdstatus = 0.
                        END.
                    END.
                WHEN 3 THEN
                    DO:
                        INT(par_nrctrato) NO-ERROR.
                        
                        IF ERROR-STATUS:ERROR THEN
                            DO:
                                ASSIGN par_cdstatus = 0.
                            END.
                    END.    
                WHEN 4 THEN
                    ASSIGN par_cdstatus = 0.
                WHEN 5 THEN
                    DO:
                        IF INDEX(par_nrctrato,".",1) <> 2 THEN
                            ASSIGN par_cdstatus = 0. 
                    END.
                WHEN 6 THEN
                    DO:
                        IF INDEX(par_nrctrato,".",1) <> 3 THEN
                            ASSIGN par_cdstatus = 0. 
                    END.
                WHEN 7 THEN
                    DO:
                        IF INDEX(par_nrctrato,".",1) <> 4 THEN
                            ASSIGN par_cdstatus = 0. 
                    END.
                WHEN 8 THEN
                    ASSIGN par_cdstatus = 0.
                WHEN 9 THEN
                    DO:
                        IF INDEX(par_nrctrato,".",1) <> 2 OR INDEX(par_nrctrato,".", INDEX(par_nrctrato,".",1) + 1) <> 6 THEN
                            ASSIGN par_cdstatus = 0. 
                    END.
                WHEN 10 THEN
                    DO:
                        IF INDEX(par_nrctrato,".",1) <> 3 OR INDEX(par_nrctrato,".", INDEX(par_nrctrato,".",1) + 1) <> 7 THEN
                            ASSIGN par_cdstatus = 0. 
                    END.
                OTHERWISE DO:
                    ASSIGN par_cdstatus = 0.
                END.
            END CASE.
        END.
    
    /* VERIFICA SE BORDERO FOI ENVIADO NO FORMATO CORRETO */
    IF par_cdstatus <> 0 AND aux_strborde <> 0 THEN
        DO:
        
            CASE aux_strborde:
                WHEN 1 THEN
                    DO:
                        INT(par_nrborder) NO-ERROR.

                        IF  ERROR-STATUS:ERROR THEN
                        DO:
                            ASSIGN par_cdstatus = 0.
                        END.
                    END.
                WHEN 2 THEN
                    DO:
                        INT(par_nrborder) NO-ERROR.

                        IF  ERROR-STATUS:ERROR THEN
                        DO:
                            ASSIGN par_cdstatus = 0.
                        END.
                    END.
                WHEN 3 THEN
                    DO:
                        INT(par_nrborder) NO-ERROR.

                        IF  ERROR-STATUS:ERROR THEN
                        DO:
                            ASSIGN par_cdstatus = 0.
                        END.
                    END.
                WHEN 4 THEN
                    ASSIGN par_cdstatus = 0.
                WHEN 5 THEN
                    DO:
                        IF INDEX(par_nrborder,".",1) <> 2 THEN
                            ASSIGN par_cdstatus = 0. 
                    END.
                WHEN 6 THEN
                    DO:
                        IF INDEX(par_nrborder,".",1) <> 3 THEN
                            ASSIGN par_cdstatus = 0. 
                    END.
                WHEN 7 THEN
                    DO:
                        IF INDEX(par_nrborder,".",1) <> 4 THEN
                            ASSIGN par_cdstatus = 0. 
                    END.
                WHEN 8 THEN
                    ASSIGN par_cdstatus = 0.
                WHEN 9 THEN
                    DO:
                        IF INDEX(par_nrborder,".",1) <> 2 OR INDEX(par_nrborder,".", INDEX(par_nrborder,".",1) + 1) <> 6 THEN
                            ASSIGN par_cdstatus = 0. 
                    END.
                OTHERWISE DO:
                    ASSIGN par_cdstatus = 0. 
                END.
            END CASE.
        END.
    /* Fim novo trecho de codigo */
    
    IF par_cdstatus <> 0 THEN
        DO:
        
            IF   par_desdekey <> "PhT5slpZtyRBN21"   THEN
                 DO:
                     ASSIGN par_cdstatus = 0.
                 END.
            ELSE
            IF   par_tpdocmto = 86   THEN /* CONTRATO DE LIMITE DE DESCONTO DE CHEQUE */
                 DO:
                     FIND craplim WHERE craplim.cdcooper = par_cdcooper         AND
                                        craplim.nrdconta = INT(par_nrdconta)    AND
                                        craplim.tpctrlim = 2                    AND
                                        craplim.nrctrlim = INT(par_nrctrato)  
                                        NO-LOCK NO-ERROR.
                                                                                                                
                     ASSIGN par_cdstatus = IF  AVAIL craplim THEN 1 ELSE 0.
                 END.
            ELSE
            IF   par_tpdocmto = 87   THEN /* BORDERO DE DESCONTO DE CHEQUE */
                 DO:
                     FIND crapbdc WHERE crapbdc.cdcooper = par_cdcooper         AND
                                        crapbdc.nrdconta = INT(par_nrdconta)    AND
                                        crapbdc.nrborder = INT(par_nrborder)
                                        NO-LOCK NO-ERROR.
        
                     ASSIGN par_cdstatus = IF  AVAIL crapbdc THEN 1 ELSE 0.
               END.
            ELSE
            IF   par_tpdocmto = 85   THEN /* CONTRATO DE LIMITE DE DESCONTO DE TITULO */
                 DO:
                     FIND craplim WHERE craplim.cdcooper = par_cdcooper         AND
                                        craplim.nrdconta = INT(par_nrdconta)    AND
                                        craplim.tpctrlim = 3                    AND
                                        craplim.nrctrlim = INT(par_nrctrato)  
                                        NO-LOCK NO-ERROR.
           
                     ASSIGN par_cdstatus = IF  AVAIL craplim THEN 1 ELSE 0.       
                 END.
            ELSE
            IF   par_tpdocmto = 88   THEN /* BORDERO DE DESCONTO DE TITULO */
                 DO:
                     FIND crapbdt WHERE crapbdt.cdcooper = par_cdcooper         AND
                                        crapbdt.nrborder = INT(par_nrborder)    AND
                                        crapbdt.nrdconta = INT(par_nrdconta)
                                        NO-LOCK NO-ERROR.
             
                     ASSIGN par_cdstatus = IF  AVAIL crapbdt THEN 1 ELSE 0.
                 END.
            ELSE
            IF   par_tpdocmto = 89    THEN /* CONTRATO DE EMPRESTIMO/FINANCIAMENTO */
                 DO:
                    FIND crapepr WHERE crapepr.cdcooper = par_cdcooper   AND
                                        crapepr.nrdconta = INT(par_nrdconta)   AND
                                        crapepr.nrctremp = INT(par_nrctrato)
                                        NO-LOCK NO-ERROR.
             
                     ASSIGN par_cdstatus = IF  AVAIL crapepr THEN 1 ELSE 0.
    
                 END.
            ELSE
            IF   par_tpdocmto = 102    THEN /* ADITIVO DE CONTRATO DE EMPRESTIMO */
                 DO:
                   
                    FIND crapadt WHERE crapadt.cdcooper = INT(par_cdcooper) AND
                                       crapadt.nrdconta = INT(par_nrdconta) AND
                                       crapadt.nrctremp = INT(par_nrctrato) AND
                                       crapadt.nraditiv = INT(par_nraditiv) AND
                                       crapadt.tpctrato = 90 /* Emprestimo/Financiamento */
                                       NO-LOCK NO-ERROR.
             
                     ASSIGN par_cdstatus = IF AVAIL crapadt THEN 1 ELSE 0.
    
                 END.
            ELSE
            IF  par_tpdocmto = 84 THEN /* CONTRATO LIMITE DE CREDITO */
                DO:
                    FIND craplim WHERE craplim.cdcooper = INT(par_cdcooper) AND
                                       craplim.nrdconta = INT(par_nrdconta) AND
                                       craplim.nrctrlim = INT(par_nrctrato) AND
                                       craplim.tpctrlim = 1                    
                                       NO-LOCK NO-ERROR.
    
                    ASSIGN par_cdstatus = IF AVAIL craplim THEN 1 ELSE 0.       
    
                END.
            ELSE 
                ASSIGN par_cdstatus = 0. /* Tipo invalido */
        END.
     
    RETURN "OK".

END PROCEDURE.


PROCEDURE gera_dados_pendencias: 

    DEF INPUT  PARAM par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_dtinicio AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_dtdfinal AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_dsdemail AS CHAR                        NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_data AS DATE NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-documento-digitalizado.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:

        DO aux_data = par_dtinicio TO par_dtdfinal:

            /* Documentos de contratos de emprestimos ativos do cooperado */
            FOR EACH crapepr WHERE crapepr.cdcooper = par_cdcooper      AND
                                   crapepr.inliquid = 0                 AND
                                   crapepr.flgdigit = NO                AND
                                   crapepr.dtmvtolt = aux_data          AND
                            NOT CAN-DO("3,4,10", STRING(crapepr.cdorigem)) AND
                            NOT CAN-DO("100,800,850,900,6901,6902,6903,6904,6905", 
                                       STRING(crapepr.cdlcremp)) 
                            NO-LOCK,
               
                FIRST crawepr WHERE crawepr.cdcooper = crapepr.cdcooper AND
                                    crawepr.nrdconta = crapepr.nrdconta AND
                                    crawepr.nrctremp = crapepr.nrctremp NO-LOCK:

                FIND FIRST crapass WHERE crapass.cdcooper = crapepr.cdcooper AND
                                         crapass.nrdconta = crapepr.nrdconta 
                                         NO-LOCK NO-ERROR.

                IF NOT AVAIL crapass THEN 
                    NEXT.

                IF crapass.dtdemiss <> ? THEN
                    NEXT.

                CREATE tt-documento-digitalizado.
                ASSIGN tt-documento-digitalizado.cdcooper = crapepr.cdcooper
                       tt-documento-digitalizado.cdagenci = crapepr.cdagenci
                       tt-documento-digitalizado.tpdocmto = 89
                       tt-documento-digitalizado.nrdconta = crapepr.nrdconta
                       tt-documento-digitalizado.nrctrato = crapepr.nrctremp
                       tt-documento-digitalizado.dtmvtolt = crawepr.dtmvtolt
                       tt-documento-digitalizado.dtlibera = crapepr.dtmvtolt
                       tt-documento-digitalizado.nrdolote = crapepr.nrdolote
                       tt-documento-digitalizado.cdbccxlt = crapepr.cdbccxlt
                       tt-documento-digitalizado.vllanmto = crapepr.vlemprst.

            END.

            /* Ler os aditivos dos contratos de emprestimos  */
            FOR EACH crapadt FIELDS(cdcooper nrdconta nrctremp nraditiv dtmvtolt)
                                WHERE crapadt.cdcooper = par_cdcooper AND
                                      crapadt.flgdigit = NO           AND
                                      crapadt.dtmvtolt = aux_data     AND
                                      crapadt.tpctrato = 90 /* Emprestimo/Financiamento */
                                      NO-LOCK,
                FIRST crapepr WHERE crapepr.cdcooper = crapadt.cdcooper AND
                                    crapepr.nrdconta = crapadt.nrdconta AND
                                    crapepr.nrctremp = crapadt.nrctremp AND
                                    crapepr.inliquid = 0                AND
                                    NOT CAN-DO("100,800,850,900,6901,6902,6903,6904,6905", 
                                              STRING(crapepr.cdlcremp)) NO-LOCK:

                FIND FIRST crapass WHERE crapass.cdcooper = crapadt.cdcooper AND
                                         crapass.nrdconta = crapadt.nrdconta 
                                         NO-LOCK NO-ERROR.

                IF NOT AVAIL crapass THEN 
                    NEXT.

                IF crapass.dtdemiss <> ? THEN
                    NEXT.

                CREATE tt-documento-digitalizado.
                ASSIGN tt-documento-digitalizado.cdcooper = crapadt.cdcooper
                       tt-documento-digitalizado.cdagenci = crapepr.cdagenci
                       tt-documento-digitalizado.tpdocmto = 102
                       tt-documento-digitalizado.nrdconta = crapadt.nrdconta
                       tt-documento-digitalizado.nrctrato = crapadt.nrctremp
                       tt-documento-digitalizado.dtmvtolt = crapadt.dtmvtolt
                       tt-documento-digitalizado.dtlibera = crapadt.dtmvtolt
                       tt-documento-digitalizado.nrdolote = crapepr.nrdolote
                       tt-documento-digitalizado.cdbccxlt = crapepr.cdbccxlt
                       tt-documento-digitalizado.nraditiv = crapadt.nraditiv
                       tt-documento-digitalizado.vllanmto = crapepr.vlemprst.

            END.

            /* Contr. Bordero de Cheques */
        /*************************** IMPORTANTE ********************************
           *  A regra abaixo definida para (nao) apresentacao dos borderos de  *
           *  desconto de cheques segue a mesma regra definida na b1wgen0009 - *
           *  busca_borderos, utilizada na tela ATENDA; com excecao do         *
           *  indicador de borderos liberados apenas para esta BO              *
        ***********************************************************************/
            FOR EACH crapbdc WHERE crapbdc.cdcooper = par_cdcooper     AND
                                   crapbdc.insitbdc = 3                AND
                                   crapbdc.flgdigit = FALSE            AND
                                   crapbdc.dtlibbdc = aux_data         NO-LOCK:

                IF (crapbdc.dtlibbdc < par_dtmvtolt - 90) THEN
                DO:
                    IF  crapbdc.nrdconta <> 85448  THEN
                    DO:
                        FIND FIRST crapcdb WHERE crapcdb.cdcooper = crapbdc.cdcooper AND
                                                 crapcdb.nrdconta = crapbdc.nrdconta AND
                                                 crapcdb.nrborder = crapbdc.nrborder AND
                                                 crapcdb.dtlibera > par_dtmvtolt
                                                 NO-LOCK NO-ERROR.

                        IF NOT AVAIL crapcdb THEN
                            NEXT.
                    END.
                END.

                FIND FIRST crapass WHERE crapass.cdcooper = crapbdc.cdcooper AND
                                         crapass.nrdconta = crapbdc.nrdconta 
                                         NO-LOCK NO-ERROR.

                IF NOT AVAIL crapass THEN 
                    NEXT.

                IF crapass.dtdemiss <> ? THEN
                    NEXT.

                FIND FIRST craplot WHERE craplot.cdcooper = crapbdc.cdcooper AND
                                         craplot.dtmvtolt = crapbdc.dtmvtolt AND
                                         craplot.cdagenci = crapbdc.cdagenci AND
                                         craplot.cdbccxlt = crapbdc.cdbccxlt AND
                                         craplot.nrdolote = crapbdc.nrdolote 
                                         NO-LOCK NO-ERROR.

                CREATE tt-documento-digitalizado.
                ASSIGN tt-documento-digitalizado.cdcooper = crapbdc.cdcooper
                       tt-documento-digitalizado.cdagenci = crapbdc.cdagenci
                       tt-documento-digitalizado.tpdocmto = 87
                       tt-documento-digitalizado.nrdconta = crapbdc.nrdconta
                       tt-documento-digitalizado.nrctrato = crapbdc.nrctrlim
                       tt-documento-digitalizado.nrborder = crapbdc.nrborder
                       tt-documento-digitalizado.dtmvtolt = crapbdc.dtmvtolt
                       tt-documento-digitalizado.dtlibera = crapbdc.dtlibbdc
                       tt-documento-digitalizado.nrdolote = crapbdc.nrdolote
                       tt-documento-digitalizado.cdbccxlt = crapbdc.cdbccxlt
                       tt-documento-digitalizado.vllanmto = craplot.vlcompcr
                                                            WHEN AVAIL craplot.

            END.

            /* Contr. Bordero de Titulos */
            FOR EACH crapbdt WHERE crapbdt.cdcooper = par_cdcooper     AND
                                   crapbdt.insitbdt = 3                AND
                                   crapbdt.flgdigit = FALSE            AND
                                   crapbdt.dtlibbdt = aux_data         NO-LOCK:

                FIND FIRST crapass WHERE crapass.cdcooper = crapbdt.cdcooper AND
                                         crapass.nrdconta = crapbdt.nrdconta 
                                         NO-LOCK NO-ERROR.

                IF NOT AVAIL crapass THEN 
                    NEXT.

                IF crapass.dtdemiss <> ? THEN
                    NEXT.

                FIND FIRST craplot WHERE craplot.cdcooper = crapbdt.cdcooper AND
                                         craplot.dtmvtolt = crapbdt.dtmvtolt AND
                                         craplot.cdagenci = crapbdt.cdagenci AND
                                         craplot.cdbccxlt = crapbdt.cdbccxlt AND
                                         craplot.nrdolote = crapbdt.nrdolote 
                                         NO-LOCK NO-ERROR.

                CREATE tt-documento-digitalizado.
                ASSIGN tt-documento-digitalizado.cdcooper = crapbdt.cdcooper
                       tt-documento-digitalizado.cdagenci = crapbdt.cdagenci
                       tt-documento-digitalizado.tpdocmto = 88
                       tt-documento-digitalizado.nrdconta = crapbdt.nrdconta
                       tt-documento-digitalizado.nrctrato = crapbdt.nrctrlim
                       tt-documento-digitalizado.nrborder = crapbdt.nrborder
                       tt-documento-digitalizado.dtmvtolt = crapbdt.dtmvtolt
                       tt-documento-digitalizado.dtlibera = crapbdt.dtlibbdt
                       tt-documento-digitalizado.nrdolote = crapbdt.nrdolote
                       tt-documento-digitalizado.cdbccxlt = crapbdt.cdbccxlt
                       tt-documento-digitalizado.vllanmto = craplot.vlcompcr 
                                                            WHEN AVAIL craplot.

            END.
            
            /* Contratos de limites de cheques,titulos e especial ativos */
            FOR EACH craplim WHERE craplim.cdcooper = par_cdcooper AND
                                   craplim.insitlim = 2            AND
                                   craplim.flgdigit = NO           AND
                                   craplim.dtinivig = aux_data     NO-LOCK:

                FIND FIRST crapass WHERE crapass.cdcooper = craplim.cdcooper AND
                                         crapass.nrdconta = craplim.nrdconta 
                                         NO-LOCK NO-ERROR.

                IF NOT AVAIL crapass THEN 
                    NEXT.

                IF crapass.dtdemiss <> ? THEN
                    NEXT.

                FIND crapcdc WHERE crapcdc.cdcooper = craplim.cdcooper AND 
                                   crapcdc.nrdconta = craplim.nrdconta AND 
                                   crapcdc.nrctrlim = craplim.nrctrlim AND
                                   crapcdc.tpctrlim = craplim.tpctrlim
                                   NO-LOCK NO-ERROR.

                CREATE tt-documento-digitalizado.
                ASSIGN tt-documento-digitalizado.cdcooper = craplim.cdcooper
                       tt-documento-digitalizado.cdagenci = IF AVAIL crapcdc then
                                                                crapcdc.cdagenci
                                                            ELSE
                                                                crapass.cdagenci
                       tt-documento-digitalizado.tpdocmto = IF   craplim.tpctrlim = 1   THEN
                                                                 84
                                                            ELSE 
                                                            IF   craplim.tpctrlim = 2   THEN
                                                                 86 
                                                            ELSE
                                                                 85
                       tt-documento-digitalizado.nrdconta = craplim.nrdconta
                       tt-documento-digitalizado.nrctrato = craplim.nrctrlim

                       tt-documento-digitalizado.dtmvtolt = craplim.dtpropos
                       tt-documento-digitalizado.dtlibera = craplim.dtinivig
                       tt-documento-digitalizado.vllanmto = craplim.vllimite.

                IF   AVAIL crapcdc  THEN
                     ASSIGN tt-documento-digitalizado.nrdolote = crapcdc.nrdolote
                            tt-documento-digitalizado.cdbccxlt = crapcdc.cdbccxlt.
            END.
        END. /* fim DO .. TO */
      
        RUN gera-relatorio-pendencias (INPUT par_cdcooper,
                                       INPUT par_dsdemail,
                                       INPUT TABLE tt-documento-digitalizado).

        LEAVE.

    END.

    RETURN "OK".

END PROCEDURE.


/*............................ PROCEDURES INTERNAS ..........................*/

/*****************************************************************************/
/** Procedure para gerar o relatorio na opcao R da Prcged                   **/
/****************************************************************************/
PROCEDURE gera-relatorio-pendencias:   

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dsdemail AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-documento-digitalizado.
    
        
    DEF  VAR aux_nmarquiv AS CHAR                                      NO-UNDO.
    DEF  VAR aux_qtpenden AS INTE EXTENT 102                           NO-UNDO.
    DEF  VAR aux_qttotpen AS INTE EXTENT 102                           NO-UNDO.
    DEF  VAR aux_contador AS INTE                                      NO-UNDO.
    DEF  VAR h-b1wgen0011 AS HANDLE                                    NO-UNDO.


    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop +
                          "/rel_prcged_" + STRING(TIME) + ".csv".
   
    OUTPUT STREAM str_1 TO VALUE (aux_nmarquiv) PAGED PAGE-SIZE 84.

    /* Listar as pendencias */
    FOR EACH tt-documento-digitalizado   
             NO-LOCK BREAK BY tt-documento-digitalizado.cdagenci
                              BY tt-documento-digitalizado.nrdconta
                                 BY tt-documento-digitalizado.tpdocmto
                                    BY tt-documento-digitalizado.nrctrato:

        IF  FIRST-OF (tt-documento-digitalizado.cdagenci)   THEN
            DO: 
                PUT STREAM str_1 UNFORMATTED 
              "Conta/DV;Data Proposta;Data liberacao;PA;B/CX;Lote;" 
              "Nro.Ctr;Bordero;Nro.Aditivo;Valor;Cod/Tipo"
                 SKIP.
            END.

        PUT STREAM str_1 
                   tt-documento-digitalizado.nrdconta FORMAT ("zzzz,zzz,9") ";"
                   tt-documento-digitalizado.dtmvtolt FORMAT "99/99/9999"   ";"
                   tt-documento-digitalizado.dtlibera FORMAT "99/99/9999"   ";"
                   tt-documento-digitalizado.cdagenci ";" 
                   tt-documento-digitalizado.cdbccxlt ";"
                   tt-documento-digitalizado.nrdolote ";"
                   tt-documento-digitalizado.nrctrato ";"
                   tt-documento-digitalizado.nrborder ";"
                   tt-documento-digitalizado.nraditiv ";"
                   tt-documento-digitalizado.vllanmto ";"
                   tt-documento-digitalizado.tpdocmto ";"
                   SKIP.

        /* Contabilizar os tipos de pendencias  */
        ASSIGN aux_qtpenden[tt-documento-digitalizado.tpdocmto] = 
                  aux_qtpenden[tt-documento-digitalizado.tpdocmto] + 1
            
               aux_qtpenden[99] = aux_qtpenden[99] + 1.

        IF   LAST-OF (tt-documento-digitalizado.cdagenci) THEN
             DO:
                 PUT STREAM str_1 UNFORMATTED
                      SKIP(1)
                 "TIPO DE DOCUMENTO/DESCRICAO;  QTDADE PENDENCIA; COD/TIPO"
                      SKIP(1).

                 PUT STREAM str_1 UNFORMATTED
                      "ADITIVO DE CONTRATO DE EMPRESTIMO;"
                      aux_qtpenden[102]
                      ";102"
                      SKIP
                      "CONTRATO DE EMPRESTIMO/FINANCIAMENTO;"
                      aux_qtpenden[89]
                      ";89"
                      SKIP
                       
                      "CONTRATO DE LIMITE DE DESCONTO DE CHEQUE;"
                      aux_qtpenden[86]
                      ";86"
                      SKIP
                      "CONTRATO DE LIMITE DE DESCONTO DE TITULO;"
                      aux_qtpenden[85]
                      ";85"
                      SKIP
                      "CONTRATO DE LIMITE DE CREDITO;"
                      aux_qtpenden[84]
                      ";84"
                      SKIP
                      "BORDERO DE DESCONTO DE CHEQUE;"
                      aux_qtpenden[87]
                      ";87"
                      SKIP
                      "BORDERO DE DESCONTO DE TITULO;"
                      aux_qtpenden[88]
                      ";88"
                      SKIP
                      "TOTAL DE PENDENCIAS PA " 
                      STRING(tt-documento-digitalizado.cdagenci,"zzz") ";"
                      aux_qtpenden[99]
                      SKIP(1). 

                 /* Totalizador da cooperativa*/
                 DO aux_contador = 1 TO 102:
                     ASSIGN aux_qttotpen[aux_contador] = 
                       aux_qttotpen[aux_contador] + aux_qtpenden[aux_contador].
                 END.

                 /* limpar as pendencias */
                 ASSIGN aux_qtpenden = 0.

             END.
    END.

    /* Totalizador da cooperativa */
    PUT STREAM str_1 UNFORMATTED
                 "TIPO DE DOCUMENTO/DESCRICAO;  QTDADE PENDENCIA; COD/TIPO"
                 SKIP(1).

    PUT STREAM str_1 UNFORMATTED
          "ADITIVO DE CONTRATO DE EMPRESTIMO;"
          aux_qttotpen[102]
          ";102"
          SKIP
          "CONTRATO DE EMPRESTIMO/FINANCIAMENTO;"
          aux_qttotpen[89]
          ";89"
          SKIP
          
          "CONTRATO DE LIMITE DE DESCONTO DE CHEQUE;"
          aux_qttotpen[86]
          ";86"
          SKIP
          "CONTRATO DE LIMITE DE DESCONTO DE TITULO;"
          aux_qttotpen[85]
          ";85"
          SKIP
          "CONTRATO DE LIMITE DE CREDITO;"
          aux_qttotpen[84]
          ";84"
          SKIP
          "BORDERO DE DESCONTO DE CHEQUE;"
          aux_qttotpen[87]
          ";87"
          SKIP
          "BORDERO DE DESCONTO DE TITULO;"
          aux_qttotpen[88]
          ";88"
          
          SKIP
          "TOTAL DE PENDENCIAS DOS PAS; " 
          aux_qttotpen[99]
          SKIP(1).

    OUTPUT STREAM str_1 CLOSE.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    UNIX SILENT VALUE("cp " + aux_nmarquiv + " /usr/coop/" + 
                      crapcop.dsdircop + "/converte/prcged.csv").
           
    /* Envia o arquivo gerado por email */
    RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET h-b1wgen0011.
            
    RUN enviar_email_completo IN h-b1wgen0011 
                                     (INPUT crapcop.cdcooper,
                                      INPUT "b1wgen00137",
                                      INPUT "AILOS<ailos@ailos.coop.br>",
                                      INPUT par_dsdemail,
                                      INPUT "Pendencias - PRCGED",
                                      INPUT "",
                                      INPUT "prcged.csv",
                                      INPUT "\nSegue anexo o Relatorio",
                                      INPUT TRUE).

    DELETE PROCEDURE h-b1wgen0011.

    RETURN "OK".

END PROCEDURE.

PROCEDURE retorna_docs_liberados:

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dtlibera AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_tpdocmto AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_key      AS CHAR                               NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-documentos-liberados.

    DEF VAR aux_flgok AS LOG                                           NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                       NO-UNDO.

    DEF VAR aux_vlchqtot AS DECI                                       NO-UNDO.
    DEF VAR aux_vltittot AS DECI                                       NO-UNDO.
    DEF VAR aux_idexiste AS DECI                                       NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-documentos-liberados.

    /************************************************************
     * Documentos a utilizar ate o momento nesta procedure      *
     ************************************************************
     
     84 - Cadastro de limite de credito
     85 - Limite de desconto de titulos
     86 - Limite de desconto de cheques
     87 - Contrato de bordero de cheques
     88 - Contrato de bordero de tutulos
     89 - Contrato de emprestimo/financiamento
     102 - Aditivo de contrato de emprestimo
     207 - Contratos Procap
     
    *************************************************************/

    /* o programa inicia ok */
    ASSIGN aux_flgok = TRUE.    

    DO  WHILE TRUE:

        /* Validar a chave de acesso e tipos de documentos */
        IF  par_key <> "Ck3tBzyhxp8dWzq" OR 
            NOT CAN-DO("84,85,86,87,88,89,102,207",STRING(par_tpdocmto)) THEN
            DO:
                aux_flgok = FALSE.
                LEAVE.
            END.

        /* Verificar se cooperativa existe */
        FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper 
                                 NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapcop THEN
            DO:
                aux_flgok = FALSE.
                LEAVE.
            END.

		/* Documentos de contratos de Procap do cooperado */
		IF par_tpdocmto = 207 THEN 
			DO: 
				FOR EACH craplct WHERE craplct.cdcooper = par_cdcooper AND
									   craplct.dtmvtolt = par_dtlibera AND
									   craplct.cdhistor = 930 		   AND
									   craplct.dtlibera = ?
									   NO-LOCK:

					CREATE tt-documentos-liberados.
					ASSIGN tt-documentos-liberados.tpdocmto = 207
						   tt-documentos-liberados.nrdconta = craplct.nrdconta
						   tt-documentos-liberados.cdcooper = craplct.cdcooper
						   tt-documentos-liberados.cdagenci = craplct.cdagenci
						   tt-documentos-liberados.nrctrato = craplct.nrdocmto
						   tt-documentos-liberados.nrborder = 0
						   tt-documentos-liberados.nraditiv = 0
						   tt-documentos-liberados.dtlibera = craplct.dtmvtolt
						   tt-documentos-liberados.vllanmto = craplct.vllanmto.
				END.
			END.

        /* Documentos de contratos de emprestimos ativos do cooperado */
        IF  par_tpdocmto = 89 THEN                                      
            DO:    
                FOR EACH crapepr WHERE crapepr.cdcooper = par_cdcooper      AND
                                       crapepr.dtmvtolt = par_dtlibera      AND
                                NOT CAN-DO("3,4,10", STRING(crapepr.cdorigem)) AND
                                NOT CAN-DO("100,800,850,900,6901,6902,6903,6904,6905", 
                                           STRING(crapepr.cdlcremp)) 
                                NO-LOCK:
        
                    /* Nao deve gerar pendencia para emprestimos efetuados no novo CDC */
                    IF crapepr.cdopeori = 'AUTOCDC' THEN
                        NEXT. 
        
                    CREATE tt-documentos-liberados.
                    ASSIGN tt-documentos-liberados.tpdocmto = 89
                           tt-documentos-liberados.nrdconta = crapepr.nrdconta
                           tt-documentos-liberados.cdcooper = crapepr.cdcooper
                           tt-documentos-liberados.cdagenci = crapepr.cdagenci
                           tt-documentos-liberados.nrctrato = crapepr.nrctremp
                           tt-documentos-liberados.nrborder = 0
                           tt-documentos-liberados.nraditiv = 0
                           tt-documentos-liberados.dtlibera = crapepr.dtmvtolt
                           tt-documentos-liberados.vllanmto = crapepr.vlemprst.
                END.
            END.

        /* Ler os aditivos dos contratos de emprestimos  */
        IF  par_tpdocmto = 102 THEN
            DO:
                FOR EACH crapadt FIELDS(cdcooper nrdconta nrctremp nraditiv 
                                        dtmvtolt cdagenci)
                                  WHERE crapadt.cdcooper = par_cdcooper AND
                                        crapadt.dtmvtolt = par_dtlibera AND
                                        crapadt.tpctrato = 90 /* Emprestimo/Financiamento */
                                        NO-LOCK,
                    FIRST crapepr WHERE crapepr.cdcooper = crapadt.cdcooper AND
                                        crapepr.nrdconta = crapadt.nrdconta AND
                                        crapepr.nrctremp = crapadt.nrctremp AND
                                        NOT CAN-DO("100,800,850,900,6901,6902,6903,6904,6905",
                                                  STRING(crapepr.cdlcremp)) NO-LOCK:
        
                    CREATE tt-documentos-liberados.
                    ASSIGN tt-documentos-liberados.tpdocmto = 102
                           tt-documentos-liberados.nrdconta = crapadt.nrdconta
                           tt-documentos-liberados.cdcooper = crapadt.cdcooper
                           tt-documentos-liberados.cdagenci = crapadt.cdagenci
                           tt-documentos-liberados.nrctrato = crapadt.nrctremp
                           tt-documentos-liberados.nrborder = 0
                           tt-documentos-liberados.nraditiv = crapadt.nraditiv
                           tt-documentos-liberados.dtlibera = crapadt.dtmvtolt
                           tt-documentos-liberados.vllanmto = crapepr.vlemprst.
                END.
            END.

        /* Contrato Bordero de Cheques */
        IF  par_tpdocmto = 87 THEN
            DO:
                FOR EACH crapbdc WHERE crapbdc.cdcooper = par_cdcooper     AND
                                       crapbdc.insitbdc = 3                AND
                                       crapbdc.dtlibbdc = par_dtlibera     NO-LOCK:

                    aux_vlchqtot = 0.

                    FOR EACH crapcdb WHERE crapcdb.cdcooper = crapbdc.cdcooper AND
                                           crapcdb.nrdconta = crapbdc.nrdconta AND
                                           crapcdb.nrborder = crapbdc.nrborder 
                                           NO-LOCK:

                        aux_vlchqtot = aux_vlchqtot + crapcdb.vlcheque.
                    END.
                    
                    /* Nao deve gerar pendencia para borderos efetuados no IB e com valor menor ou igual a 5 mil */
                    IF crapbdc.cdoperad = '996' AND aux_vlchqtot <= 5000 THEN
                        NEXT. 

                    CREATE tt-documentos-liberados.
                    ASSIGN tt-documentos-liberados.tpdocmto = 87
                           tt-documentos-liberados.nrdconta = crapbdc.nrdconta
                           tt-documentos-liberados.cdcooper = crapbdc.cdcooper
                           tt-documentos-liberados.cdagenci = crapbdc.cdagenci
                           tt-documentos-liberados.nrctrato = crapbdc.nrctrlim
                           tt-documentos-liberados.nrborder = crapbdc.nrborder
                           tt-documentos-liberados.nraditiv = 0
                           tt-documentos-liberados.dtlibera = crapbdc.dtlibbdc
                           tt-documentos-liberados.vllanmto = aux_vlchqtot.
        
                END.
            END.
            
        /* Contrato Bordero de Titulos */
        IF  par_tpdocmto = 88 THEN
            DO:
                FOR EACH crapbdt WHERE crapbdt.cdcooper = par_cdcooper     AND
                                       crapbdt.dtlibbdt = par_dtlibera     NO-LOCK:

                    aux_vltittot = 0.

                    FOR EACH craptdb WHERE craptdb.cdcooper = crapbdt.cdcooper AND  
                                           craptdb.nrdconta = crapbdt.nrdconta AND 
										   craptdb.dtlibbdt <> ?               AND
                                           craptdb.nrborder = crapbdt.nrborder NO-LOCK:
                        
                        aux_vltittot = aux_vltittot + craptdb.vltitulo.

                    END.
					
					aux_valordig = 0.
					
					FIND crapass WHERE crapass.cdcooper = par_cdcooper    AND
									   crapass.nrdconta = crapbdt.nrdconta
									   NO-LOCK NO-ERROR.
									   
					IF AVAIL crapass THEN
					DO:
					
						IF crapass.inpessoa = 1 THEN /* Fisica */
							aux_cdacesso = "LIMDESCTITCRPF".
						ELSE
							aux_cdacesso = "LIMDESCTITCRPJ".
		  
						FIND craptab WHERE craptab.cdcooper = par_cdcooper    AND
										   craptab.nmsistem = "CRED"          AND
										   craptab.tptabela = "USUARI"        AND
										   craptab.cdempres = 11              AND
										   craptab.cdacesso = aux_cdacesso    AND
										   craptab.tpregist = 0 NO-LOCK NO-ERROR.

						IF  AVAIL craptab THEN
						   aux_valordig = DEC(ENTRY(39,craptab.dstextab,";")).						   

					END.
					
					/* Nao deve gerar pendencia para borderos efetuados no IB e com valor menor ou igual a parametro */
                    IF crapbdt.cdoperad = '996' AND aux_vltittot <= aux_valordig THEN
                        NEXT.
        
                    CREATE tt-documentos-liberados.
                    ASSIGN tt-documentos-liberados.tpdocmto = 88
                           tt-documentos-liberados.nrdconta = crapbdt.nrdconta
                           tt-documentos-liberados.cdcooper = crapbdt.cdcooper
                           tt-documentos-liberados.cdagenci = crapbdt.cdagenci
                           tt-documentos-liberados.nrctrato = crapbdt.nrctrlim
                           tt-documentos-liberados.nrborder = crapbdt.nrborder
                           tt-documentos-liberados.nraditiv = 0
                           tt-documentos-liberados.dtlibera = crapbdt.dtlibbdt
                           tt-documentos-liberados.vllanmto = aux_vltittot.
        
                END.
            END.
            
        /* Cadastro de limite de credito */
        IF  par_tpdocmto = 84 THEN
            DO:
                FOR EACH craplim WHERE craplim.cdcooper = par_cdcooper AND
                                       craplim.dtinivig = par_dtlibera AND
                                       craplim.tpctrlim = 1            AND
                                       craplim.insitlim = 2           
                                       NO-LOCK:
                            
                    FIND FIRST crapope WHERE crapope.cdcooper = craplim.cdcooper AND
                                             crapope.cdoperad = craplim.cdopelib
                                             NO-LOCK NO-ERROR.             
                                

                    /* Projeto 470 - Marcelo Telles Coelho */
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                    RUN STORED-PROCEDURE pc_ver_protocolo_ctd aux_handproc = PROC-HANDLE NO-ERROR
                                                     (INPUT craplim.cdcooper
                                                     ,INPUT craplim.nrdconta
                                                     ,INPUT 29
                                                     ,INPUT craplim.dtinivig
                                                     ,INPUT ?
                                                     ,INPUT craplim.nrctrlim
                                                     ,OUTPUT 0
                                                     ,OUTPUT "").
                    CLOSE STORED-PROC pc_ver_protocolo_ctd 
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
                     
                    ASSIGN aux_idexiste = 0
                           aux_dscritic = ""
                           aux_idexiste = pc_ver_protocolo_ctd.pr_idexiste
                           aux_dscritic = pc_ver_protocolo_ctd.pr_dscritic
                    WHEN pc_ver_protocolo_ctd.pr_dscritic <> ?.
                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                    
                    IF aux_idexiste = 0 THEN
                      DO:
                    /* Fim Projeto 470 */
                    CREATE tt-documentos-liberados.
                    ASSIGN tt-documentos-liberados.tpdocmto = 84
                           tt-documentos-liberados.nrdconta = craplim.nrdconta
                           tt-documentos-liberados.cdcooper = craplim.cdcooper
                           tt-documentos-liberados.cdagenci = crapope.cdpactra 
                                                                WHEN AVAIL crapope
                           tt-documentos-liberados.nrctrato = craplim.nrctrlim
                           tt-documentos-liberados.nrborder = 0
                           tt-documentos-liberados.nraditiv = 0
                           tt-documentos-liberados.dtlibera = craplim.dtinivig
                           tt-documentos-liberados.vllanmto = craplim.vllimite.
                      END. /* Projeto 470 */
                    
                END.
            END.

        /* Limite desconto de cheques */
        IF  par_tpdocmto = 86 THEN
            DO:
                FOR EACH crapcdc WHERE crapcdc.cdcooper = par_cdcooper AND
                                       crapcdc.dtmvtolt = par_dtlibera 
                                       NO-LOCK,
                    FIRST craplot WHERE craplot.cdcooper = crapcdc.cdcooper
                                    AND craplot.dtmvtolt = crapcdc.dtmvtolt
                                    AND craplot.cdagenci = crapcdc.cdagenci
                                    AND craplot.cdbccxlt = crapcdc.cdbccxlt
                                    AND craplot.nrdolote = crapcdc.nrdolote
                                    AND craplot.tplotmov = 27
                                    NO-LOCK:

                    /* Projeto 470 - Marcelo Telles Coelho */
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                    RUN STORED-PROCEDURE pc_ver_protocolo_ctd aux_handproc = PROC-HANDLE NO-ERROR
                                                     (INPUT crapcdc.cdcooper
                                                     ,INPUT crapcdc.nrdconta
                                                     ,INPUT 27
                                                     ,INPUT crapcdc.dtmvtolt
                                                     ,INPUT ?
                                                     ,INPUT crapcdc.nrctrlim
                                                     ,OUTPUT 0
                                                     ,OUTPUT "").
                    CLOSE STORED-PROC pc_ver_protocolo_ctd 
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
                     
                    ASSIGN aux_idexiste = 0
                           aux_dscritic = ""
                           aux_idexiste = pc_ver_protocolo_ctd.pr_idexiste
                           aux_dscritic = pc_ver_protocolo_ctd.pr_dscritic
                    WHEN pc_ver_protocolo_ctd.pr_dscritic <> ?.
                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                    
                    IF aux_idexiste = 0 THEN
                      DO:
                    /* Fim Projeto 470 */

                    CREATE tt-documentos-liberados.
                    ASSIGN tt-documentos-liberados.tpdocmto = 86
                           tt-documentos-liberados.nrdconta = crapcdc.nrdconta
                           tt-documentos-liberados.cdcooper = crapcdc.cdcooper
                           tt-documentos-liberados.cdagenci = crapcdc.cdagenci
                           tt-documentos-liberados.nrctrato = crapcdc.nrctrlim
                           tt-documentos-liberados.nrborder = 0
                           tt-documentos-liberados.nraditiv = 0
                           tt-documentos-liberados.dtlibera = crapcdc.dtmvtolt
                           tt-documentos-liberados.vllanmto = crapcdc.vllimite.
                      END. /* Projeto 470 */
        
                END.
            END.

        /* Limite desconto de titulos */
        IF  par_tpdocmto = 85 THEN
            DO:
                FOR EACH crapcdc WHERE crapcdc.cdcooper = par_cdcooper AND
                                       crapcdc.dtmvtolt = par_dtlibera 
                                       NO-LOCK,
                    FIRST craplot WHERE craplot.cdcooper = crapcdc.cdcooper
                                    AND craplot.dtmvtolt = crapcdc.dtmvtolt
                                    AND craplot.cdagenci = crapcdc.cdagenci
                                    AND craplot.cdbccxlt = crapcdc.cdbccxlt
                                    AND craplot.nrdolote = crapcdc.nrdolote
                                    AND craplot.tplotmov = 35
                                    NO-LOCK:

                    /* Projeto 470 - Marcelo Telles Coelho */
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                    RUN STORED-PROCEDURE pc_ver_protocolo_ctd aux_handproc = PROC-HANDLE NO-ERROR
                                                     (INPUT crapcdc.cdcooper
                                                     ,INPUT crapcdc.nrdconta
                                                     ,INPUT 28
                                                     ,INPUT crapcdc.dtmvtolt
                                                     ,INPUT ?
                                                     ,INPUT crapcdc.nrctrlim
                                                     ,OUTPUT 0
                                                     ,OUTPUT "").
                    CLOSE STORED-PROC pc_ver_protocolo_ctd 
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
                     
                    ASSIGN aux_idexiste = 0
                           aux_dscritic = ""
                           aux_idexiste = pc_ver_protocolo_ctd.pr_idexiste
                           aux_dscritic = pc_ver_protocolo_ctd.pr_dscritic
                    WHEN pc_ver_protocolo_ctd.pr_dscritic <> ?.
                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                    
                    IF aux_idexiste = 0 THEN
                      DO:
                    /* Fim Projeto 470 */
                      
                    CREATE tt-documentos-liberados.
                    ASSIGN tt-documentos-liberados.tpdocmto = 85
                           tt-documentos-liberados.nrdconta = crapcdc.nrdconta
                           tt-documentos-liberados.cdcooper = crapcdc.cdcooper
                           tt-documentos-liberados.cdagenci = crapcdc.cdagenci
                           tt-documentos-liberados.nrctrato = crapcdc.nrctrlim
                           tt-documentos-liberados.nrborder = 0
                           tt-documentos-liberados.nraditiv = 0
                           tt-documentos-liberados.dtlibera = crapcdc.dtmvtolt
                           tt-documentos-liberados.vllanmto = crapcdc.vllimite.
                      END. /* Projeto 470 */
        
                END.
            END.
        LEAVE. 
    END. /* Fim do DO WHILE */

    /* Verificar se foi criado algum registro */
    FIND FIRST tt-documentos-liberados NO-LOCK NO-ERROR.

    IF  NOT AVAIL tt-documentos-liberados THEN
        ASSIGN aux_flgok = FALSE.

    /* Caso haja algum erro no decorrer do programa */
    IF  NOT aux_flgok THEN
        DO:
            CREATE tt-documentos-liberados.
            ASSIGN tt-documentos-liberados.tpdocmto = 0
                   tt-documentos-liberados.nrdconta = 0
                   tt-documentos-liberados.cdcooper = 0
                   tt-documentos-liberados.cdagenci = 0
                   tt-documentos-liberados.nrctrato = 0
                   tt-documentos-liberados.nrborder = 0
                   tt-documentos-liberados.nraditiv = 0
                   tt-documentos-liberados.dtlibera = par_dtlibera
                   tt-documentos-liberados.vllanmto = 0.
        END.

    /*  Lucas Ranghetti
    aux_nmarquiv = "docs_liberados_" + STRING(DAY(par_dtlibera),"99") +
                   STRING(MONTH(par_dtlibera),"99") + STRING(YEAR(par_dtlibera),"9999") +
                   "_" + STRING(par_tpdocmto) + "_" + STRING(par_cdcooper,"99") + ".csv".

    /* Gerar relatorio csv temporario */         
    OUTPUT TO VALUE ("/usr/coop/sistema/equipe/ranghetti/GED/" +
                     "Melhoria_70/" + aux_nmarquiv).

    PUT UNFORMATTED "TipoDocumento;Conta;Cooperativa;PA;Contrato;" +
                     "Bordero;Aditivo;DataLiberacao;Valor" SKIP.

    FOR EACH tt-documentos-liberados NO-LOCK:

        PUT  tt-documentos-liberados.tpdocmto ";"
             tt-documentos-liberados.nrdconta ";"
             tt-documentos-liberados.cdcooper ";"
             tt-documentos-liberados.cdagenci ";"
             tt-documentos-liberados.nrctrato ";"
             tt-documentos-liberados.nrborder ";"
             tt-documentos-liberados.nraditiv ";"
             tt-documentos-liberados.dtlibera FORMAT "99/99/9999" ";"
             tt-documentos-liberados.vllanmto FORMAT "zzzzzzzzzz9.99" ";"
             SKIP.

    END.
    
    OUTPUT CLOSE.
    */

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************/
/**      Procedure para consultar lista de titulos do sacado eletronico     **/
/*****************************************************************************/
PROCEDURE lista-documentos-digitalizados PRIVATE:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtvalida AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtafinal AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER TABLE FOR tt-documentos.                                                                    
                                                                
    DEF OUTPUT PARAM TABLE FOR tt-documento-digitalizado.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE VARIABLE aux_tpdocmto AS DECIMAL     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsderror = ""
           aux_dsreturn = "NOK".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 1,
                           INPUT 1,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.

    ASSIGN aux_nmarqlog = "/usr/coop/" + crapcop.dsdircop + "/log/" +
                          "Smartshare_LogErros_" + STRING(aux_datdodia,"99999999") + 
                          ".log".
           
    DO WHILE TRUE:

        IF  RETURN-VALUE = "NOK"  THEN
            LEAVE.

        ASSIGN aux_dsreturn = "OK".

        /* Somente devera fazer requisicao dos documentos da tabela parametrisada */             
        FOR EACH tt-documentos NO-LOCK:

            ASSIGN aux_tpdocmto = tt-documentos.tpdocmto
                   aux_msgenvio = "/usr/coop/" + crapcop.dsdircop + "/arq/" +
                                  "SOAP.MESSAGE.ENVIO." + 
                                  "COOP" + STRING(par_cdcooper,"99") + "." +
                                  STRING(TODAY,"99999999") + 
                                  STRING(TIME,"99999") +
                                  SUBSTRING(STRING(NOW),21,3)
                   aux_msgreceb = "/usr/coop/" + crapcop.dsdircop + "/arq/" +
                                  "SOAP.MESSAGE.RECEBIMENTO." + 
                                  "COOP" + STRING(par_cdcooper,"99") + "." +
                                  STRING(TODAY,"99999999") + 
                                  STRING(TIME,"99999") +
                                  SUBSTRING(STRING(NOW),21,3).
            
            /* Caso o documento seja Cartao assinatura e as datas estejam entre janeiro e 06/03/2014 
               nao devera buscar os documentos digitalizados, pois estoura memoria (Out of memory) */
            IF  par_cdcooper = 1           AND
                aux_tpdocmto = 95          AND
                par_dtvalida > 01/01/2014  AND
                par_dtafinal <= 03/06/2014 THEN
                NEXT.

            IF  aux_tpdocmto > 0  THEN
                /* Efetua requisicao no WebService e alimenta a tabela com os dados */
                RUN requisicao-lista-documentos (INPUT par_cdcooper,
                                                 INPUT par_dtvalida,
                                                 INPUT par_dtafinal,
                                                 INPUT aux_tpdocmto,  /* Tipo de Documento */
                                                 INPUT aux_nmarqlog). 
        END.
        
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  aux_dsreturn = "NOK"  THEN
    DO: 
       
        IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
            ASSIGN aux_dscritic = "Falha na requisicao Smartshare.".
               
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 1,
                       INPUT 1,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        UNIX SILENT VALUE('echo "' + (STRING(aux_datdodia,"99/99/9999") + " " +
                                      STRING(TIME,"HH:MM:SS")  + " --> " +
                                      "Lista documentos digitalizados | " +
                                      aux_dscritic) + '" >> ' + aux_nmarqlog).
    END.

    RETURN aux_dsreturn.

END PROCEDURE.

PROCEDURE cria-objetos-soap PRIVATE:

    RUN elimina-objetos-soap.

    CREATE X-DOCUMENT hXmlSoap.
    CREATE X-NODEREF  hXmlEnvelope.
    CREATE X-NODEREF  hXmlHeader.
    CREATE X-NODEREF  hXmlBody.
    CREATE X-NODEREF  hXmlAutentic.
    CREATE X-NODEREF  hXmlMetodo.
    CREATE X-NODEREF  hXmlRootSoap.
    CREATE X-NODEREF  hXmlNode1Soap.
    CREATE X-NODEREF  hXmlNode2Soap.
    CREATE X-NODEREF  hXmlTagSoap.
    CREATE X-NODEREF  hXmlTextSoap.

    RETURN "OK".

END PROCEDURE.

PROCEDURE elimina-objetos-soap PRIVATE:

    IF  VALID-HANDLE(hXmlTextSoap)   THEN
        DELETE OBJECT hXmlTextSoap.

    IF  VALID-HANDLE(hXmlTagSoap)    THEN
        DELETE OBJECT hXmlTagSoap.

    IF  VALID-HANDLE(hXmlMetodo)     THEN
        DELETE OBJECT hXmlMetodo.

    IF  VALID-HANDLE(hXmlRootSoap)   THEN
        DELETE OBJECT hXmlRootSoap.

    IF  VALID-HANDLE(hXmlNode1Soap)  THEN
        DELETE OBJECT hXmlNode1Soap.

    IF  VALID-HANDLE(hXmlNode2Soap)  THEN
        DELETE OBJECT hXmlNode2Soap.

    IF  VALID-HANDLE(hXmlAutentic)   THEN
        DELETE OBJECT hXmlAutentic.

    IF  VALID-HANDLE(hXmlBody)       THEN
        DELETE OBJECT hXmlBody.

    IF  VALID-HANDLE(hXmlHeader)     THEN
        DELETE OBJECT hXmlHeader.

    IF  VALID-HANDLE(hXmlEnvelope)   THEN
        DELETE OBJECT hXmlEnvelope.

    IF  VALID-HANDLE(hXmlSoap)       THEN
        DELETE OBJECT hXmlSoap.

    RETURN "OK".

END PROCEDURE.


PROCEDURE gera-cabecalho-soap PRIVATE:

    DEF  INPUT PARAM par_idservic AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmmetodo AS CHAR                           NO-UNDO.

    DEF VAR aux_nmservic AS CHAR                                    NO-UNDO.

    CASE par_idservic:
        WHEN 1 THEN aux_nmservic = "WsDocumento".
    END CASE.

    RUN cria-objetos-soap.

    /** Criacao do Envelope SOAP **/
    hXmlSoap:CREATE-NODE(hXmlEnvelope,"soap:Envelope","ELEMENT").
    hXmlEnvelope:SET-ATTRIBUTE("xmlns:xsi",
                               "http://www.w3.org/2001/XMLSchema-instance").
    hXmlEnvelope:SET-ATTRIBUTE("xmlns:xsd",
                               "http://www.w3.org/2001/XMLSchema").
    hXmlEnvelope:SET-ATTRIBUTE("xmlns:soap",
                               "http://schemas.xmlsoap.org/soap/envelope/").
    hXmlSoap:APPEND-CHILD(hXmlEnvelope).

    /** Criacao do SOAP BODY **/
    hXmlSoap:CREATE-NODE(hXmlBody,"soap:Body","ELEMENT").
    hXmlEnvelope:APPEND-CHILD(hXmlBody).

    /** Criacao do Node de Metodo e Parametros **/
    hXmlSoap:CREATE-NODE(hXmlMetodo,par_nmmetodo,"ELEMENT").
    hXmlMetodo:SET-ATTRIBUTE("xmlns",
                             "http://selbetti.com.br/").
    hXmlBody:APPEND-CHILD(hXmlMetodo).

    RETURN "OK".

END PROCEDURE.


PROCEDURE efetua-requisicao-soap PRIVATE:

    DEF  INPUT PARAM par_idservic AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmmetodo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqlog AS CHAR                           NO-UNDO.

    hXmlSoap:SAVE("FILE",aux_msgenvio).

    UNIX SILENT VALUE("cat " + aux_msgenvio + " | /usr/local/cecred/bin/" +
                      "SendSoapSmartshare.pl " + 
                      "--servico='" + STRING(par_idservic) + "' " +
                      "--metodo='" + par_nmmetodo + "' > " + aux_msgreceb + 
                      " 2>>" + par_nmarqlog).

    IF  par_nmarqlog <> ""  THEN
        UNIX SILENT VALUE("chmod 666 " + par_nmarqlog + " 2>/dev/null").

    ASSIGN aux_dsderror = "".

    /** Cria novamente os handles para leitura do soap retornado **/
    RUN cria-objetos-soap.

    DO WHILE TRUE:
           
        /** Valida SOAP retornado pelo WebService **/        
        hXmlSoap:LOAD("FILE",aux_msgreceb,FALSE) NO-ERROR.
    
        IF  ERROR-STATUS:NUM-MESSAGES > 0  THEN
            DO:
                ASSIGN aux_dsderror = "Resposta SOAP invalida. XML WebService.".
                LEAVE.
            END. 
    
        hXmlSoap:GET-DOCUMENT-ELEMENT(hXmlEnvelope) NO-ERROR.
    
        IF  ERROR-STATUS:NUM-MESSAGES > 0             OR 
            hXmlEnvelope:NAME <> "soap:Envelope"  THEN
            DO:
                ASSIGN aux_dsderror = "Resposta SOAP invalida. Envelope.".
                LEAVE.
            END.
    
        hXmlEnvelope:GET-CHILD(hXmlBody,1) NO-ERROR.
    
        IF  ERROR-STATUS:NUM-MESSAGES > 0      OR 
            hXmlBody:NAME <> "soap:Body"  THEN
            DO:
                ASSIGN aux_dsderror = "Resposta SOAP invalida. Body.".
                LEAVE.
            END. 
    
        hXmlBody:GET-CHILD(hXmlMetodo,1) NO-ERROR.
    
        IF  ERROR-STATUS:NUM-MESSAGES > 0    THEN
            DO:
                ASSIGN aux_dsderror = "Resposta SOAP invalida. Result.".
                LEAVE.
            END.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  aux_dsderror <> ""  THEN
        DO: 
            RUN elimina-arquivos-requisicao.

            ASSIGN aux_dscritic = "Falha na execucao do metodo Smartshare" +
                                  (IF  aux_dsderror <> ""  THEN
                                       " Erro: " + aux_dsderror 
                                   ELSE
                                       "") 
                   aux_dsreturn = "NOK".

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE obtem-fault-packet PRIVATE:

    /* Parametro que serve para ignorar certos erros */
    DEF  INPUT PARAM par_dsderror AS CHAR                           NO-UNDO.

    ASSIGN aux_dsderror = "".
    
    /** Verifica se foi retornado um fault packet (Erro) **/
    IF  hXmlMetodo:NAME = "erroCritica"  THEN
        DO: 
            DO i = 1 TO hXmlMetodo:NUM-CHILDREN:
    
                hXmlMetodo:GET-CHILD(hXmlTagSoap,i).

                ASSIGN aux_dsderror = hXmlTagSoap:NODE-VALUE.

            END. /** Fim do DO ... TO **/
            


            ASSIGN aux_dscritic = "Falha na execucao do metodo" +
                                  (IF  aux_dsderror <> ""  THEN
                                       " Erro: " + aux_dsderror
                                   ELSE
                                       "") + 
                                   "."
                   aux_dsreturn = "NOK".

            RUN elimina-arquivos-requisicao.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE elimina-arquivos-requisicao PRIVATE:

    RUN elimina-objetos-soap.
                         
    UNIX SILENT VALUE("rm " + aux_msgenvio + " 2>/dev/null").
    
    UNIX SILENT VALUE("rm " + aux_msgreceb + " 2>/dev/null").

    RETURN "OK".

END PROCEDURE.


PROCEDURE requisicao-lista-documentos PRIVATE:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvalida AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtafinal AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocmto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqlog AS CHAR                           NO-UNDO.

    DEFINE VARIABLE xml_node AS CHARACTER   NO-UNDO.

    
    RUN gera-cabecalho-soap (INPUT 1, INPUT "ListarDocumentoPublicado").
    
    /** Parametros do Metodo **/
    cria-tag (INPUT "pCdCooperativa", INPUT STRING(par_cdcooper),
          INPUT "string", INPUT hXmlMetodo).

    cria-tag (INPUT "pCdTipoDocumento", INPUT STRING(par_tpdocmto),
              INPUT "string", INPUT hXmlMetodo).

    cria-tag (INPUT "pDtInicial", INPUT STRING(par_dtvalida),
              INPUT "string", INPUT hXmlMetodo).

    cria-tag (INPUT "pDtFinal", INPUT STRING(par_dtafinal),
              INPUT "string", INPUT hXmlMetodo).

    cria-tag (INPUT "pKey", INPUT "SBOyFb5NFFNuAmyp0p4B", 
              INPUT "int", INPUT hXmlMetodo).
    
    RUN efetua-requisicao-soap (INPUT 1,INPUT "ListarDocumentoPublicado", INPUT par_nmarqlog).
    
    

    IF  RETURN-VALUE = "NOK"  THEN
    DO:
        
        ASSIGN aux_dsreturn = "NOK".
        RETURN "NOK".
    END.

    RUN obtem-fault-packet (INPUT "").
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN aux_dsreturn.
    ELSE
        DO:
            hXmlMetodo:GET-CHILD(hXmlTagSoap,1).

            IF  hXmlTagSoap:NAME <> "ListarDocumentoPublicadoResult"  THEN
                DO:
                    RUN elimina-arquivos-requisicao.

                    ASSIGN aux_dscritic = "Resposta SOAP invalida (Result)."
                           aux_dsreturn = "NOK".
                    
                    RETURN "NOK".
                END.
            
            ASSIGN aux_dsreturn = "OK".

            /** Obtem retorno do metodo **/
            hXmlTagSoap:GET-CHILD(hXmlTextSoap,1) NO-ERROR.

            /* Despreza TAG vazia */
            IF  ERROR-STATUS:ERROR             OR 
                ERROR-STATUS:NUM-MESSAGES > 0  THEN
                .
            ELSE
            /* Varre as TAGs de documentos */
            DO i = 1 TO hXmlTagSoap:NUM-CHILDREN:

                /* Captura a TAG do documento */
                hXmlTagSoap:GET-CHILD(hXmlTextSoap,i) NO-ERROR.

                /* Zera os dados anteriores */
                ASSIGN aux_cdcooper = 0
                       aux_cdagenci = 0
                       aux_tpdocmto = 0
                       aux_nrdconta = 0
                       aux_nrctrato = 0
                       aux_nrborder = 0
                       aux_nraditiv = 0
                       aux_dtpublic = ?
                       aux_nrcpfcgc = 0.

                /* Varre as TAGs de dados dos documentos */
                DO j = 1 TO hXmlTextSoap:NUM-CHILDREN:

                    /* Caputra a TAG dos dados do documento */
                    hXmlTextSoap:GET-CHILD(hXmlNode1Soap,j) NO-ERROR.
                    
                    /* Despreza TAG vazias */
                    IF  ERROR-STATUS:ERROR             OR 
                        ERROR-STATUS:NUM-MESSAGES > 0  THEN
                        NEXT.
                    
                    /* Caputra o conteudo da TAG dos dados do documento */
                    hXmlNode1Soap:GET-CHILD(hXmlNode2Soap,1) NO-ERROR.

                    /* Despreza TAG vazias */
                    IF  ERROR-STATUS:ERROR             OR 
                        ERROR-STATUS:NUM-MESSAGES > 0  THEN
                        NEXT.
                    
                    /* TAG que possui os dados de Tipo de Documento */
                    IF  hXmlNode1Soap:NAME = "CdTipoDocumento"  THEN
                    DO:
                        ASSIGN aux_tpdocmto = INTE(REPLACE(REPLACE(hXmlNode2Soap:NODE-VALUE,".",""),"-","")) NO-ERROR.
                    END.
                    ELSE
                    /* TAG que possui os dados de Cod Cooperativa */
                    IF  hXmlNode1Soap:NAME = "CdCooperativa"  THEN
                    DO:
                        ASSIGN aux_cdcooper = INTE(REPLACE(REPLACE(hXmlNode2Soap:NODE-VALUE,".",""),"-","")) NO-ERROR.
                    END.
                    /* TAG que possui os dados do Pac */
                    IF  hXmlNode1Soap:NAME = "CdPac"  THEN
                    DO:
                        ASSIGN aux_cdagenci = INTE(REPLACE(REPLACE(hXmlNode2Soap:NODE-VALUE,".",""),"-","")) NO-ERROR.
                    END.
                    ELSE
                    /* TAG que possui os dados de numero da Conta */
                    IF  hXmlNode1Soap:NAME = "NrConta"  THEN
                    DO:
                        ASSIGN aux_nrdconta = INTE(REPLACE(REPLACE(hXmlNode2Soap:NODE-VALUE,".",""),"-","")) NO-ERROR.
                    END.
                    ELSE
                    /* TAG que possui os dados de numero do Contrato */
                    IF  hXmlNode1Soap:NAME = "NrContrato"  THEN
                    DO:
                        ASSIGN aux_nrctrato = INTE(REPLACE(REPLACE(hXmlNode2Soap:NODE-VALUE,".",""),"-","")) NO-ERROR.
                    END.
                    ELSE
                    /* TAG que possui os dados de numero do Bordero */
                    IF  hXmlNode1Soap:NAME = "NrBordero"  THEN
                    DO:
                        ASSIGN aux_nrborder = INTE(REPLACE(REPLACE(hXmlNode2Soap:NODE-VALUE,".",""),"-","")) NO-ERROR.
                    END.
                    ELSE
                    /* TAG que possui os dados de numero do Aditivo */
                    IF  hXmlNode1Soap:NAME = "NrAditivo"  THEN
                    DO:
                        ASSIGN aux_nraditiv = INTE(REPLACE(REPLACE(hXmlNode2Soap:NODE-VALUE,".",""),"-","")) NO-ERROR.
                    END.
                    ELSE
                    /* TAG que possui os dados de Data da publicacao */
                    IF  hXmlNode1Soap:NAME = "DtPublicacao"  THEN
                    DO:
                        ASSIGN aux_dtpublic = DATE(SUBSTR(TRIM(hXmlNode2Soap:NODE-VALUE),9,2) + "/" +
                                                   SUBSTR(TRIM(hXmlNode2Soap:NODE-VALUE),6,2) + "/" +
                                                   SUBSTR(TRIM(hXmlNode2Soap:NODE-VALUE),1,4) + "/")
                                              NO-ERROR.
                    END.
                    ELSE
                    IF hXmlNode1Soap:NAME = "NrCpfCnpj" THEN
                    DO:
                        ASSIGN aux_nrcpfcgc = DEC(REPLACE(REPLACE(REPLACE(hXmlNode2Soap:NODE-VALUE,".",""),"-",""), "/", "")) NO-ERROR.
                    END.
                END.

                CREATE tt-documento-digitalizado.
                ASSIGN tt-documento-digitalizado.cdcooper = aux_cdcooper
                       tt-documento-digitalizado.cdagenci = aux_cdagenci
                       tt-documento-digitalizado.tpdocmto = aux_tpdocmto
                       tt-documento-digitalizado.nrdconta = aux_nrdconta
                       tt-documento-digitalizado.nrctrato = aux_nrctrato
                       tt-documento-digitalizado.nrborder = aux_nrborder
                       tt-documento-digitalizado.nraditiv = aux_nraditiv
                       tt-documento-digitalizado.dtpublic = aux_dtpublic
                       tt-documento-digitalizado.nrcpfcgc = aux_nrcpfcgc.

            END.

        END.
        
    RUN elimina-arquivos-requisicao.
    
    ASSIGN aux_dsreturn = "OK".
    RETURN "OK".

END PROCEDURE.

PROCEDURE  gera_pend_digitalizacao:
  DEF INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
  DEF INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
  DEF INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
  DEF INPUT PARAM par_nrcpfcgc AS DEC                            NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
  DEF INPUT PARAM par_lstpdoct AS CHAR                           NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
  DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
  DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    RUN gera_pend_digitalizacao_seqdoc
                      ( INPUT par_cdcooper,
                        INPUT par_nrdconta,
                        INPUT par_idseqttl,
                        INPUT par_nrcpfcgc,
                        INPUT par_dtmvtolt,
                        INPUT par_lstpdoct,
                        INPUT par_cdoperad,
                        INPUT 0, /* par_nrseqdoc */
                       OUTPUT par_cdcritic,
                       OUTPUT par_cdcritic).

   IF par_cdcritic <> 0 OR
      par_dscritic <> "" THEN
   DO:
     RETURN "NOK".   
   END.
      

END PROCEDURE. 

PROCEDURE  gera_pend_digitalizacao_seqdoc:
  DEF INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
  DEF INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
  DEF INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
  DEF INPUT PARAM par_nrcpfcgc AS DEC                            NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
  DEF INPUT PARAM par_lstpdoct AS CHAR                           NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
  DEF INPUT PARAM par_nrseqdoc AS INTE                           NO-UNDO.
  
  DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
  DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

    /* Efetuar a chamada a rotina Oracle  */
    RUN STORED-PROCEDURE pc_gera_pend_digitalizacao
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,   /* pr_cdcooper */
                                             INPUT par_nrdconta,   /* pr_nrdconta */
                                             INPUT par_idseqttl,   /* pr_idseqttl */
                                             INPUT par_nrcpfcgc,   /* pr_nrcpfcgc */
                                             INPUT par_dtmvtolt,   /* pr_dtmvtolt */
                                             INPUT par_lstpdoct,   /* pr_lstpdoct lista de Tipo do documento separados por ; */
                                             INPUT par_cdoperad,   /* pr_cdoperad */            
                                             INPUT par_nrseqdoc,   /* pr_nrseqdoc */
                                            OUTPUT 0,              /* Código da crítica */
                                            OUTPUT "").            /* Descriçao da crítica */

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_gera_pend_digitalizacao
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
    
    /* Busca possíveis erros */ 
    ASSIGN par_cdcritic = 0
           par_dscritic = ""
           par_cdcritic = pc_gera_pend_digitalizacao.pr_cdcritic 
                          WHEN pc_gera_pend_digitalizacao.pr_cdcritic <> ?
           par_dscritic = pc_gera_pend_digitalizacao.pr_dscritic 
                          WHEN pc_gera_pend_digitalizacao.pr_dscritic <> ?.

   IF par_cdcritic <> 0 OR
      par_dscritic <> "" THEN
   DO:
     RETURN "NOK".   
   END.
      

END PROCEDURE.

/*...........................................................................*/


