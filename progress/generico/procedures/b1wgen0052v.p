/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0052v.p                  
    Autor(a): Jose Luis Marchezoni (DB1)
    Data    : Junho/2010                      Ultima atualizacao: 06/08/2019
  
    Dados referentes ao programa:
  
    Objetivo  : BO com regras de negocio refente a tela MATRIC.
                Baseado em fontes/matric.p.
                Rotinas de Validacao de Dados
                
  
    Alteracoes: 21/10/2010 - Bloquear geracao de nova matricula se o CPF ja
                             estiver cadastrado - Tarefa 35233 (David).
                             
                24/11/2010 - Voltar versao da alteracao acima (David).
                
                24/01/2011 - Ajuste na validacao do tipo de pessoa (David).
    
                27/01/2011 - Criado procedure para verificar se ha Produto ou
                             Servico Ativo vinculado ao cooperado (Jorge).
                      
                18/02/2011 - Adicionado criterio de validacao do
                             Digito Verificador, validando ou nao, conforme
                             a empresa. (Jorge)
                
                24/02/2011 - Alterado condicao de entrada de validacao de data
                             e motivo de demissao em Criticas_Alteracao. (Jorge)
                
                21/03/2011 - Alterada a procedure ValidaNome (Henrique).
                
                25/03/2011 - Adicionado verificacao de produto/servico DDA 
                             (sacado eletronico) em procedure 
                             Produtos_Servicos_Ativos. (Jorge) 
                             
                18/04/2011 - Incluida validaçao para CEP na valida_dados.
                             (André - DB1)           
                             
                17/05/2011 - Alteraçao na validacao criada para o DDA no dia
                             25/03/2011 (David).
                             
                06/06/2011 - Comentar critica 342 referente ao tamanho dos
                             nomes dos titutales (David).
                             
                27/10/2011 - Tratamento seguro renovado (Diego).
                
                05/12/2011 - Validado na procedure Valida_Jur, se existe
                             convenio PAMCARD ativo para caso de demissao
                             do cooperado. (Fabricio)
                             
                08/02/2012 - Validado na procedure Produtos_Servicos_Ativos, se existe
                             convenio PAMCARD ativo para caso de demissao
                             do cooperado. (Adriano)       
                             
                13/04/2012 - Incluido na procedure Produtos_Servicos_Ativos 
                             a validacao para Procuradores e Responsavel Legal
                             (Adriano).
                 
                26/04/2012 - Alteracao na procedure Valida_Inicio_Inclusao para                             
                             tratamento de criacao de novas contas nos PAC que
                             serao migrados para Viacredi Alto Vale.
                             (David Kruger).
                             
                15/06/2012 - Ajustes referente ao projeto GP - Socios Menores
                            (Adriano).
                            
                28/08/2012 - Incluir alertas da Viacredi AltoVale (Gabriel).           
                
                10/12/2012 - Incluido restricao de Pac migrado alto vale
                             (David Kruger).
                             
                08/08/2013 - Incluida validacao do campo cdufnatu. (Reinert)
                
                13/08/2013 - Incluido restricao de Pac migrado da Acredi para 
                             Viacredi. (Carlos).
                             
                01/10/2013 - Retirada a validaçao: "Se foi tirada a data de 
                             demissao, verifica se ha conta salario ativa para
                             o CPF" em Criticas_Alteracao (Carlos)
                             
                02/10/2013 - Retirada da procedure Valida_Fis a validacao 
                             par_dtmvtolt - par_dtnasctl > 38716 para permitir
                             qualquer data de nascimento passada (Carlos)
                
                12/11/2013 - Nova forma de chamar as agencias, de PAC agora 
                             a escrita será PA (Guilherme Gielow)
                
                10/01/2014 - Corrigida mensagem de usuario eliminado
                             demonstrando cpf e nro conta (Tiago).
                             
                26/02/2014 - Nao permitir digitacao do caracter " no nome do
                             cooperado (David).
                             
                14/07/2014 - Verificar propostas de cartao de crédito em aberto
                             (Lucas Lunelli - Projeto Cartoes Bancoob)
                             
                15/07/2014 - Retirada da Validaçao para inclusao de  matrícula para 
                            cooperada que possui conta CTASAL ativa.(Vanessa Klein - SD175963)
                
                30/07/2014 - Incluido restricao faixa de contas, migrado Concredi
                             (Daniel - Chamado  184333).
							 
                12/08/2014 - Adicionado tratamento para a craprac. (Reinert)			 
                             
                25/08/2014 - Incluido restricao faixa de contas, migrado Credimilsul
                             (Daniel - Chamado  190663).
                             
                30/10/2014 - Incluso bloqueio de criacao de novas contas nas cooperativas
                            Credimilsul e Concredi (Daniel - Chamado - 217482)
                            
                18/11/2014 - Removido bloqueio de criacao de novas contas na
                             SCRCRED com faixa de valores entre 700000 - 730000.
                             (Reinert)
                                                           			             
                02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                             Cedente por Beneficiário e  Sacado por Pagador 
                             Chamado 229313 (Jean Reddiga - RKAM).
                             
                28/01/2015 - Retirado logica de validacao na inclusao do registro
                             Chamado SD-204406 - (Andre Santos - SUPERO)
                           
                27/04/2015 - Retirado o comentário que foi feito na validaçao 
                             das cotas. (Douglas - Chamado 269526)
                                                          
                10/07/2015 - Projeto reformulacao Cadastral (Gabriel-RKAM).
                
                05/10/2015 - Adicionado nova opçao "J" para alteraçao apenas do cpf/cnpj e 
                             removido a possibilidade de alteraçao pela opçao "X", conforme 
                             solicitado no chamado 321572 (Kelvin). 
                             
                14/01/2016 - (Chamado 375823) Incluido na validacao de conjuge a conta 
                             (Tiago Castro - RKAM).
                             
                21/01/2016 - Para a opcao "X" (Alteracao do Nome) nao deve mais
                             validar as criticas de inclusao
                             (Douglas - Chamado 369449)

				29/11/2016 - Incluso bloqueio de criacao de novas contas na cooperativa
                             Transulcred (Daniel)

				25/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
					
			    11/06/2017 - Ajuste para validar processo de demissao
							 Jonata - RKAM (P364).   

                17/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                           PRJ339 - CRM (Odirlei-AMcom)               

                31/07/2017 - Alterado leitura da CRAPNAT pela CRAPMUN.
                             PRJ339 - CRM (Odirlei-AMcom)        
				
				17/08/2017- Ajuste na tela matric onde a opcao "X", "J" e pessoa juridica
							nao estava funcionando devido a alteracao do campo IDORGEXP. (Kelvins)

                28/08/2017 - Alterado tipos de documento para utilizarem CI, CN, 
							 CH, RE, PP E CT. (PRJ339 - Reinert)
							 
				29/09/2017 - Ajuste na tela matric para que apenas chame a funcao identifica_org_expedidor
							 quando for pessoa fisica na inclusao ou alteracao. (PRJ339 - Kelvin).

               14/11/2017 - Corrigido consulta do produtos impeditivos para desligamento (Jonata - RKAM P364).

			   21/11/2017 - Retirado validacao de convenio CDC (Jonata - RKAM P364).

			   22/11/2017 - Incluido verificao de cartao de credito (Jonata - RKAM p364).

			   01/12/2017 - Retirado verificacao de DDA (Jonata - RKAM P364).

			   23/01/2018 - Buscar valor do cheque descontado (Jonata - RKAM SD 826663).
			    
			   16/07/2019 - Valida_dados P437 Nao validar o campo matricula (par_nrcadast) Jackson Barcellos - AMcom

               06/08/2019 - Corrigido cursor que retorna os cartoes magneticos ativos por cooperado. 
			                Realizada inclusao da condicao 'tpcarcta  <> 9', para que nao sejam considerados
							os cartoes magneticos de operadores na validacao (INC0016814 - Jackson).

........................................................................*/


/*............................... DEFINICOES ................................*/

{ sistema/generico/includes/b1wgen0003tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0052tt.i }
{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0082tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/b1wgen0009tt.i }



DEF VAR aux_contador AS INTE                                        NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                        NO-UNDO.
DEF VAR aux_tpctrato1 AS LOGICAL NO-UNDO.
DEF VAR aux_tpctrato2 AS LOGICAL NO-UNDO.
DEF VAR aux_tpctrato3 AS LOGICAL NO-UNDO.
DEF VAR aux_tpctrato4 AS LOGICAL NO-UNDO.
DEF VAR aux_tpctrato8 AS LOGICAL NO-UNDO.
DEF VAR h-b1wgen0060 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0052b AS HANDLE                                     NO-UNDO.

FUNCTION ConverteCpfCnpj RETURNS DECIMAL PRIVATE
  ( INPUT par_nrcpfcgc AS CHARACTER )  FORWARD.

FUNCTION ValidaCpfCnpj RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_nrcpfcgc AS CHARACTER ) FORWARD.

FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER) FORWARD.

FUNCTION ValidaNome RETURNS LOGICAL PRIVATE
    ( INPUT  par_nomedttl AS CHARACTER,
      INPUT  par_inpessoa AS INTE,
      OUTPUT par_cdcritic AS INTEGER,
      OUTPUT par_dscritic AS CHARACTER )  FORWARD.

FUNCTION ValidaUF RETURNS LOGICAL PRIVATE
    ( INPUT par_cdunidfe AS CHARACTER )  FORWARD.

/* Pre-Processador para controle de erros 'Progress' */
&SCOPED-DEFINE GET-MSG ERROR-STATUS:GET-MESSAGE(1)

/*........................... PROCEDURES EXTERNAS ...........................*/


/* ------------------------------------------------------------------------ */
/*                        REALIZA A VALIDACAO DOS DADOS                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Dados :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagepac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcadass AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmsegntl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtcnscpf AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitcpf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoedptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufdptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtemdptl AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmmaettl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmpaittl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasctl AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsexotl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnatura AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufnatu AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdestcvl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmconjug AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcadast AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdocpttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmfansia AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_natjurid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniatv AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdseteco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrmativ AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdddtfc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelefo AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_inmatric AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdemiss AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdmotdem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inhabmen AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dthabmen AS DATE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_msgretor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-alertas.
    DEF OUTPUT PARAM TABLE FOR tt-prod_serv_ativos.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR hb1wgen0052b AS HANDLE                                  NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.
    DEF VAR aux_idorgexp AS INTE                                    NO-UNDO.
    
    ASSIGN par_dscritic = ""
           par_cdcritic = 0
           aux_returnvl = "NOK"
           aux_inpessoa = par_inpessoa.

    EMPTY TEMP-TABLE tt-alertas.
    EMPTY TEMP-TABLE tt-prod_serv_ativos.

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        /* Nome Titular */ 
        IF  NOT ValidaNome( INPUT par_nmprimtl, 
                            INPUT par_inpessoa,
                           OUTPUT par_cdcritic,
                           OUTPUT par_dscritic ) THEN
            DO:
               ASSIGN par_nmdcampo = "nmprimtl".
               LEAVE Valida.
            END.

        IF  par_nmprimtl = "" THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "nmprimtl"
                   par_cdcritic = 16.
               LEAVE Valida.
            END.

        /* Nome Fantasia - mantem a sequencia de validacao original */
        IF  par_inpessoa > 1 AND par_nmfansia = "" AND
            CAN-DO("I,A",par_cddopcao) THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "nmfansia"
                   par_cdcritic = 375.
               LEAVE Valida.
            END.
        
        /* C.P.F. ou C.N.P.J. */
        IF  NOT ValidaCpfCnpj(par_cdcooper,par_nrcpfcgc) THEN
            DO:
               ASSIGN
                   par_nmdcampo = "nrcpfcgc"
                   par_cdcritic = 27.

               LEAVE Valida.
            END.
        
        /* verificar se o tipo de pessoa confere c/ o cpf/cnpj */
        IF  ((aux_inpessoa  = 3             AND
            par_inpessoa = 1)               OR
            (aux_inpessoa <> 3              AND 
            aux_inpessoa <> par_inpessoa))  AND 
            CAN-DO("I,X,J",par_cddopcao)      THEN
            DO: 
               IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
                   RUN sistema/generico/procedures/b1wgen0060.p 
                       PERSISTENT SET h-b1wgen0060.

               ASSIGN 
                   par_nmdcampo = "nrcpfcgc"
                   par_dscritic = DYNAMIC-FUNCTION("BuscaCritica" IN
                                                    h-b1wgen0060, INPUT 27)
                   par_dscritic = par_dscritic + 
                                  (IF par_idorigem = 1 THEN "|" ELSE "<br>") + 
                                  DYNAMIC-FUNCTION("BuscaCritica" IN
                                                   h-b1wgen0060, INPUT 436).

               LEAVE Valida.
            END.

        /* realiza a verificacao dos dados */
        IF  NOT VALID-HANDLE(hb1wgen0052b) THEN
            RUN sistema/generico/procedures/b1wgen0052b.p
                PERSISTENT SET hb1wgen0052b.

        /* realiza a mesma verificacao feita na busca dos dados */
        RUN Verifica_Dados IN hb1wgen0052b
            (  INPUT par_cdcooper,
               INPUT par_nrdconta,
               INPUT par_cddopcao,
               INPUT par_idorigem,
              OUTPUT par_cdcritic,
              OUTPUT par_dscritic ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
               LEAVE Valida.
            END.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Valida.
        
        
        IF par_inpessoa = 1    AND
           (par_cddopcao = "I" OR
		   par_cddopcao = "A") THEN
           DO:
              /* Identificar orgao expedidor */
              IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                  RUN sistema/generico/procedures/b1wgen0052b.p 
                      PERSISTENT SET h-b1wgen0052b.

              ASSIGN aux_idorgexp = 0.
              RUN identifica_org_expedidor IN h-b1wgen0052b 
                                 ( INPUT par_cdoedptl,
                                  OUTPUT aux_idorgexp,
                                  OUTPUT par_cdcritic, 
                                  OUTPUT par_dscritic).

              DELETE PROCEDURE h-b1wgen0052b.   
              
              IF  RETURN-VALUE = "NOK" THEN
              DO:
                  LEAVE Valida.
              END.
              
           END.


        /* validacao especifica por operacao */
        CASE par_cddopcao:
            WHEN "J" THEN DO:

                /* Procura propostas de Cartao de Crédito ativas */
                FOR EACH crapttl WHERE crapttl.cdcooper = par_cdcooper
                                   AND crapttl.nrdconta = par_nrdconta NO-LOCK,
                   FIRST crawcrd WHERE crawcrd.cdcooper = crapttl.cdcooper
                                   AND crawcrd.nrdconta = crapttl.nrdconta
                                   AND crawcrd.nrcpftit = crapttl.nrcpfcgc
                                   AND (crawcrd.cdadmcrd >= 10
                                   AND  crawcrd.cdadmcrd <= 80) NO-LOCK:
                END.
    
                IF  AVAIL crawcrd THEN
                    DO:
                        ASSIGN par_nmdcampo = "nrcpfcgc".
                        CREATE tt-alertas.
                        ASSIGN tt-alertas.cdalerta = par_cdcritic
                               tt-alertas.dsalerta = "Titular possui cartoes Bancoob. " +
                                                     "Verificar situacao no SipagNET.".
                               tt-alertas.tpalerta = "N".
                    END.
            END.
            WHEN "I" OR WHEN "A" THEN DO:
                
                CASE par_inpessoa:
                    WHEN 1 THEN DO:
                        
                        RUN Valida_Fis
                            ( INPUT par_cdcooper,
                              INPUT par_nrdconta,
                              INPUT par_cddopcao,
                              INPUT par_nmprimtl,
                              INPUT par_dtmvtolt,
                              INPUT par_dtcadass,
                              INPUT par_nrcpfcgc,
                              INPUT par_dtcnscpf,
                              INPUT par_tpdocptl,
                              INPUT par_nrdocptl,
                              INPUT par_cdoedptl,
                              INPUT par_cdufdptl,
                              INPUT par_dtemdptl,
                              INPUT par_nmmaettl,
                              INPUT par_nmpaittl,
                              INPUT par_dtnasctl,
                              INPUT par_cdsexotl,
                              INPUT par_tpnacion,
                              INPUT par_cdnacion,
                              INPUT par_dsnatura,
                              INPUT par_cdufnatu,
                              INPUT par_cdestcvl,
                              INPUT par_nmconjug,
                              INPUT par_nrcepend,
                              INPUT par_dsendere,
                              INPUT par_nmbairro,
                              INPUT par_nmcidade,
                              INPUT par_cdufende,
                              INPUT par_cdempres,
                              INPUT par_nrcadast,
                              INPUT par_cdocpttl,
                              INPUT par_inhabmen,
                              INPUT par_dthabmen,
                             OUTPUT par_nmdcampo,
                             OUTPUT par_cdcritic,
                             OUTPUT par_dscritic ) NO-ERROR.

                        IF  ERROR-STATUS:ERROR THEN
                            DO:
                               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                               LEAVE Valida.
                            END.

                        IF  RETURN-VALUE <> "OK" THEN
                            LEAVE Valida.

                    END.
                    WHEN 2 OR WHEN 3 THEN DO:
                        
                        RUN Valida_Jur
                            ( INPUT par_cdcooper,
                              INPUT par_nmfansia,
                              INPUT par_natjurid,
                              INPUT par_dtiniatv,
                              INPUT par_cdseteco,
                              INPUT par_cdrmativ,
                              INPUT par_nrdddtfc,
                              INPUT par_nrtelefo,
                              INPUT par_nrcepend,
                              INPUT par_dsendere,
                              INPUT par_nmbairro,
                              INPUT par_nmcidade,
                              INPUT par_cdufende,
                             OUTPUT par_nmdcampo,
                             OUTPUT par_cdcritic,
                             OUTPUT par_dscritic ) NO-ERROR.

                        IF  ERROR-STATUS:ERROR THEN
                            DO:
                               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                               LEAVE Valida.
                            END.

                        IF  RETURN-VALUE <> "OK" THEN
                            LEAVE Valida.

                    END.
                    OTHERWISE DO:
                        /* Tp.Natureza */
                        ASSIGN par_nmdcampo = "inpessoa"
                               par_cdcritic = 436.
                        LEAVE Valida.

                    END.
                END CASE.
                
                /* roda a verificacao de produtos ou servicos ativos 
                   em caso de demisso */
                IF par_cddopcao = "A" AND 
                   par_dtdemiss <> ?  AND 
                   par_cdmotdem <> 0  THEN
                DO: 
                    RUN Produtos_Servicos_Ativos
                        ( INPUT par_cdcooper,
                          INPUT par_dtdemiss,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT par_flgerlog,
                          INPUT par_dtmvtolt,
                          
                         OUTPUT par_cdcritic,
                         OUTPUT par_dscritic,
                         OUTPUT TABLE tt-prod_serv_ativos
                        ) NO-ERROR.
                    IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       LEAVE Valida.
                    END.
        
                    IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
                        LEAVE Valida.
               
                END.
            END.
        END CASE.

        /* Realiza criticas dos dados informados */
        RUN Criticas
            ( INPUT par_cdcooper,
              INPUT par_nrdconta,
              INPUT par_cddopcao,
              INPUT par_dtmvtolt,
              INPUT par_inpessoa,
              INPUT par_inmatric,
              INPUT par_cdagepac,
              INPUT par_nrcpfcgc,
              INPUT par_nmprimtl,
              INPUT IF par_inpessoa = 1 THEN par_dtnasctl ELSE par_dtiniatv,
              INPUT par_nmmaettl,
              INPUT par_dtdemiss,
              INPUT par_cdmotdem,
              INPUT par_dtcnscpf,
              INPUT par_cdsitcpf,
             OUTPUT par_msgretor,
             OUTPUT par_nmdcampo,
             OUTPUT par_cdcritic,
             OUTPUT par_dscritic,
             OUTPUT TABLE tt-alertas ) NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
               LEAVE Valida.
            END.

        IF RETURN-VALUE <> "OK" THEN
            LEAVE Valida.
        
        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
                PERSISTENT SET h-b1wgen0060.

        /* mensagem de confirmacao - 078 - Confirma a operacao? (S/N) */
        IF  par_msgretor <> "" AND par_idorigem <> 1 THEN
            ASSIGN par_msgretor = par_msgretor + "<br>" + 
                                  DYNAMIC-FUNCTION("BuscaCritica" IN 
                                                   h-b1wgen0060,78).
        ELSE
            IF  NOT par_msgretor BEGINS("ATENCAO!!! Esta sendo criada ") THEN
                ASSIGN par_msgretor = par_msgretor + 
                                      DYNAMIC-FUNCTION("BuscaCritica" IN 
                                                       h-b1wgen0060,78).
        
        ASSIGN aux_returnvl = "OK".

        LEAVE Valida.

    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  VALID-HANDLE(hb1wgen0052b) THEN
        DELETE OBJECT hb1wgen0052b.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Valida_Dados */

/* ------------------------------------------------------------------------ */
/*                VALIDA INICIO DO PROCEDIMENTO PARA INCLUSAO               */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Inicio_Inclusao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagepac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_dsagepac AS CHAR                                    NO-UNDO.
   
    IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
        RUN sistema/generico/procedures/b1wgen0060.p 
            PERSISTENT SET h-b1wgen0060.

    ASSIGN par_cdcritic = 0
           par_dscritic = "".

    DO WHILE TRUE:

        /* Validar informacoes da conta somente no Caracter */
        /* Pois na web ela e' gerada automaticamente */
        IF   par_idorigem = 1   THEN
             DO:
                 IF  NOT ValidaDigFun(INPUT par_cdcooper,
                                      INPUT 0,
                                      INPUT 0,
                                      INPUT par_nrdconta)  THEN
                     DO:
                         ASSIGN par_nmdcampo = "nrdconta"
                                par_cdcritic = 8.
                         LEAVE.
                     END.                   
             END.

        IF  ( /*Concredi*/
            par_cdcooper  = 4                     AND
            par_dtmvtolt >= DATE("14/11/2014") )  THEN
            DO:    
                ASSIGN par_dscritic = "Operacao Invalida! " +
                                       "Incorporacao de Cooperativa!".
                       par_nmdcampo = "nrdconta".
                LEAVE.

           END.
    
        IF  ( /*Credimilsul*/
            par_cdcooper  = 15                 AND
            par_dtmvtolt >= DATE("11/11/2014") )
            THEN
            DO:    
                ASSIGN par_dscritic = "Operacao Invalida! " +
                                       "Incorporacao de Cooperativa!".
                       par_nmdcampo = "nrdconta".
                LEAVE.
            END.

        IF  ( /*Transulcred*/
            par_cdcooper  = 17                 AND
            par_dtmvtolt >= DATE("12/12/2016") )
            THEN
            DO:    
                ASSIGN par_dscritic = "Operacao Invalida! " +
                                       "Incorporacao de Cooperativa!".
                       par_nmdcampo = "nrdconta".
                LEAVE.
            END.

        IF  NOT DYNAMIC-FUNCTION("BuscaPac" IN h-b1wgen0060,
                                            INPUT par_cdcooper,
                                            INPUT par_cdagepac,
                                            INPUT "nmresage",
                                           OUTPUT aux_dsagepac,
                                           OUTPUT par_dscritic) THEN
            DO:
                ASSIGN par_nmdcampo = "cdagenci".
                LEAVE.
            END.

        IF par_cdcooper = 1   AND
          (par_cdagepac = 07  OR
           par_cdagepac = 33  OR
           par_cdagepac = 38  OR
           par_cdagepac = 60  OR
           par_cdagepac = 62  OR
           par_cdagepac = 66) THEN
           DO:
               ASSIGN par_nmdcampo = "cdagenci"
                      par_cdcritic = 0
                      par_dscritic = "PA nao permitido. Motivo: " + 
                                     "Transferencia de PA".
                
                LEAVE.
           END.

        /*******************************************************/
        /** Bloqueio PAC 5 da Creditextil, para transferencia **/
        /** de PAC. Remover critica em Janeiro/2011.          **/
        /*******************************************************/
        IF  par_cdcooper = 2 AND par_cdagepac = 5  THEN
            DO:
                ASSIGN par_dscritic = "Opcao nao permitida. Transferencia " +
                                      "do PA!"
                       par_nmdcampo = "cdagenci".
                LEAVE.
            END.
        
        IF  NOT CAN-DO("1,2",STRING(par_inpessoa))  THEN
            DO:
                ASSIGN par_cdcritic = 436
                       par_nmdcampo = "inpessoa".
                LEAVE.
            END.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  VALID-HANDLE(h-b1wgen0060)  THEN
        DELETE OBJECT h-b1wgen0060.

    IF  par_cdcritic > 0 OR par_dscritic <> ""  THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE. /* Valida_Inicio_Inclusao */

/* ------------------------------------------------------------------------ */
/*                   VALIDA O PARCELAMENTO DE CAPITAL                       */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Parcelamento :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdebito AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_qtparcel AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlparcel AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM par_msgretor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-parccap.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlparsub AS DECI                                    NO-UNDO.
    DEF VAR aux_qtparcap AS INTE                                    NO-UNDO.
    DEF VAR aux_dtultdia AS DATE                                    NO-UNDO.
    DEF VAR aux_vlparcel AS DECI                                    NO-UNDO.
    DEF VAR aux_vldsobra AS DECI                                    NO-UNDO.
    DEF VAR aux_dtdebito AS DATE                                    NO-UNDO.
    DEF VAR aux_contareg AS INTE                                    NO-UNDO.
    DEF VAR h-b1wgen0008 AS HANDLE                                  NO-UNDO.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    Parcelamento: DO ON ERROR UNDO Parcelamento, LEAVE Parcelamento:

        FOR FIRST crapmat FIELDS(vlcapsub vlcapini qtparcap)
                          WHERE crapmat.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crapmat THEN
            DO:
               ASSIGN par_cdcritic = 71.
               LEAVE Parcelamento.
            END.

        ASSIGN 
            aux_vlparsub = (IF crapmat.vlcapsub <> crapmat.vlcapini
                            THEN crapmat.vlcapsub - crapmat.vlcapini
                            ELSE crapmat.vlcapsub)
            aux_qtparcap = crapmat.qtparcap
            aux_dtultdia = ((DATE(MONTH(par_dtmvtolt),28,
                                   YEAR(par_dtmvtolt)) + 4) -
                                    DAY(DATE(MONTH(par_dtmvtolt),28,
                                             YEAR(par_dtmvtolt)) + 4)) + 1
            aux_dtultdia = ((DATE(MONTH(aux_dtultdia),28,
                                   YEAR(aux_dtultdia)) + 4) -
                                    DAY(DATE(MONTH(aux_dtultdia),28,
                                             YEAR(aux_dtultdia)) + 4)).

        DO WHILE TRUE:       

           IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtultdia)))             OR
               CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                                      crapfer.dtferiad = aux_dtultdia) THEN
               DO:
                  ASSIGN aux_dtultdia = aux_dtultdia - 1.
                  NEXT.
               END.
               
           LEAVE.
               
        END.  /*  Fim do DO .. TO  */

        /* inicio das validacoes */
        IF  par_dtdebito < par_dtmvtolt OR
            par_dtdebito = ?            OR
            par_dtdebito > aux_dtultdia THEN
            DO:
               ASSIGN par_dscritic = "13 - Data errada. Deve ser entre " + 
                                     STRING(par_dtmvtolt,"99/99/9999") + 
                                     " e " +
                                     STRING(aux_dtultdia,"99/99/9999") + ".".
               LEAVE Parcelamento.
            END.

        IF  par_vlparcel < aux_vlparsub THEN
            DO:
               ASSIGN par_dscritic = "269 - Valor errado. Deve ser no minimo" +
                                     " R$ " + 
                                     TRIM(STRING(aux_vlparsub,"zzz,zz9.99"))  +
                                     ".".
               LEAVE Parcelamento.
            END.

        IF  par_qtparcel > aux_qtparcap OR par_qtparcel = 0 THEN
            DO:
               ASSIGN par_dscritic = "26 - Quantidade errada. Maximo de " +
                                     TRIM(STRING(aux_qtparcap,"z9"))  +
                                     " parcelas.".
               LEAVE Parcelamento.
            END.

        EMPTY TEMP-TABLE tt-parccap.
        
        ASSIGN 
            aux_vlparcel = TRUNCATE(par_vlparcel / par_qtparcel,2).
            aux_vldsobra = par_vlparcel - (aux_vlparcel * par_qtparcel).

        IF  NOT VALID-HANDLE(h-b1wgen0008) THEN
            RUN sistema/generico/procedures/b1wgen0008.p
                PERSISTENT SET h-b1wgen0008.

        DO aux_contador = 1 TO par_qtparcel:
        
           IF  aux_contador = 1 THEN 
               ASSIGN aux_dtdebito = par_dtdebito.
           ELSE
               RUN calcdata IN h-b1wgen0008
                   ( INPUT par_cdcooper,
                     INPUT 0,
                     INPUT 0,
                     INPUT "",
                     INPUT par_dtdebito,
                     INPUT aux_contador - 1,
                     INPUT "M",
                     INPUT 0,
                    OUTPUT aux_dtdebito,
                    OUTPUT TABLE tt-erro ).

           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  ASSIGN par_dscritic = tt-erro.dscritic.
                  EMPTY TEMP-TABLE tt-erro.
                  UNDO Parcelamento, LEAVE Parcelamento.
               END.

           IF  aux_contador > 0 AND aux_contador < 4  THEN
               ASSIGN aux_contareg = 1.
           ELSE
           IF  aux_contador > 3 AND aux_contador < 7  THEN
               ASSIGN aux_contareg = 2.
           ELSE
           IF  aux_contador > 6 AND aux_contador < 10 THEN
               ASSIGN aux_contareg = 3.
           ELSE
           IF  aux_contador > 9 AND aux_contador < 13 THEN
               ASSIGN aux_contareg = 4.

           IF  aux_contador = par_qtparcel THEN
               ASSIGN aux_vlparcel = aux_vlparcel + aux_vldsobra.

           CREATE tt-parccap.
           ASSIGN 
               tt-parccap.dtrefere = aux_dtdebito
               tt-parccap.vlparcel = aux_vlparcel
               tt-parccap.nrseqdig = aux_contador.

        END.  /*  Fim do DO .. TO  */

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
                PERSISTENT SET h-b1wgen0060.

        /* mensagem de confirmacao - 078 - Confirma a operacao? (S/N) */
        ASSIGN
            par_msgretor = DYNAMIC-FUNCTION("BuscaCritica" IN h-b1wgen0060,78).

        ASSIGN aux_returnvl = "OK".

        LEAVE Parcelamento.
    END.

    IF  VALID-HANDLE(h-b1wgen0008) THEN
        DELETE OBJECT h-b1wgen0008.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Valida_Parcelamento */

/* ------------------------------------------------------------------------ */
/*                 REALIZA A VALIDACAO DOS PROCURADORES                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Procurador :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-crapavt.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdeanos AS INT                                     NO-UNDO.
    DEF VAR aux_nrdmeses AS INT                                     NO-UNDO.
    DEF VAR aux_dsdidade AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_idorgexp AS INT                                     NO-UNDO.

    DEF BUFFER btt-crapavt FOR tt-crapavt.

    &SCOPED-DEFINE CPF-AVT STRING(STRING(tt-crapavt.nrcpfcgc,"99999999999"),"999.999.999-99")

    ASSIGN par_dscritic = ""
           par_cdcritic = 0
           aux_returnvl = "NOK".

    Procurador: DO ON ERROR UNDO Procurador, LEAVE Procurador:

        FOR EACH tt-crapavt WHERE tt-crapavt.deletado = NO AND
                                  tt-crapavt.cddopcao <> "C"
            ON ERROR UNDO Procurador, RETURN "NOK":

            IF  tt-crapavt.cddopcao = "E" THEN
                NEXT.

            IF NOT VALID-HANDLE(h-b1wgen9999) THEN
               RUN sistema/generico/procedures/b1wgen9999.p 
                   PERSISTENT SET h-b1wgen9999.
          
            RUN idade IN h-b1wgen9999
                 ( INPUT tt-crapavt.dtnascto,
                   INPUT par_dtmvtolt,
                  OUTPUT aux_nrdeanos,
                  OUTPUT aux_nrdmeses,
                  OUTPUT aux_dsdidade ).
          
            DELETE PROCEDURE h-b1wgen9999.

            /* Realiza checagem do CPF */
            IF  NOT ValidaCpfCnpj(par_cdcooper,
                                  STRING(tt-crapavt.nrcpfcgc)) THEN
                DO:
                   ASSIGN par_nmdcampo = "nrcpfcgc"
                          par_cdcritic = 27.

                   LEAVE Procurador.

                END.

            /* variavel alimentada no ValidaCpfCnpj(), somente pessoa fisica */
            IF  aux_inpessoa <> 1 THEN
                DO:
                   ASSIGN par_nmdcampo = "nrcpfcgc"
                          par_cdcritic = 833.

                   LEAVE Procurador.

                END.

            IF  CAN-FIND(FIRST crapavt WHERE                     
                         crapavt.cdcooper = par_cdcooper         AND
                         crapavt.tpctrato = 6 /* jur */          AND
                         crapavt.nrdconta = par_nrdconta         AND
                         crapavt.nrctremp = 0                    AND
                         crapavt.nrcpfcgc = tt-crapavt.nrcpfcgc  AND
                         ROWID(crapavt)  <> tt-crapavt.rowidavt) AND 
                tt-crapavt.cddopcao <> "A"                       THEN
                DO:                         
                   /* procura por um registro que esteje deletado apenas 
                      na memoria */
                   IF  NOT CAN-FIND(FIRST btt-crapavt WHERE
                                    btt-crapavt.nrcpfcgc = tt-crapavt.nrcpfcgc
                                    AND btt-crapavt.deletado = YES) THEN
                   DO:
                      ASSIGN par_dscritic = "Procurador com CPF " + {&CPF-AVT} 
                                          + " ja cadastrado para o associado.".

                      LEAVE Procurador.

                   END.
                END.

            IF  CAN-FIND(FIRST btt-crapavt WHERE
                         btt-crapavt.nrcpfcgc = tt-crapavt.nrcpfcgc     AND
                         btt-crapavt.deletado = NO                      AND
                         (ROWID(btt-crapavt)   <> ROWID(tt-crapavt)     OR
                          btt-crapavt.rowidavt <> tt-crapavt.rowidavt)) AND 
                tt-crapavt.cddopcao <> "A"                              THEN
                DO:
                   
                   ASSIGN par_dscritic = " Ja existe Procurador cadastrado " +
                                         "com o CPF " + {&CPF-AVT}.
                   LEAVE Procurador.

                END.

            /* Data de vigencia */
            IF tt-crapavt.dtvalida <= par_dtmvtolt OR 
               tt-crapavt.dtvalida = ?             THEN
               DO:
                  ASSIGN par_nmdcampo = "dtvalida"         
                         par_dscritic = "Data da vigencia do Procurador CPF " + 
                                        {&CPF-AVT} + " incorreta.".

                  LEAVE Procurador.

               END.

            /* Cargo */
            IF NOT CAN-DO("SOCIO/PROPRIETARIO,DIRETOR/ADMINISTRADOR,PROCURADOR," +
                          "SOCIO COTISTA,SOCIO ADMINISTRADOR,SINDICO,"           + 
                          "TESOUREIRO,ADMINISTRADOR",
                          tt-crapavt.dsproftl) THEN
               DO:
                  ASSIGN par_nmdcampo = "dsproftl"         
                         par_dscritic = "Cargo do Procurador CPF " + 
                                        {&CPF-AVT} + " invalido.".
                  LEAVE Procurador.

               END.

            /* para associado os demais dados nao precisam ser revistos */
            IF tt-crapavt.nrdctato <> 0 THEN
               NEXT.

            /* Nome do Avalista */
            IF tt-crapavt.nmdavali = "" THEN
               DO:
                  ASSIGN par_nmdcampo = "nmdavali"
                         par_dscritic = "O nome do Procurador com CPF " + 
                                        {&CPF-AVT} + " deve ser informado.".

                  LEAVE Procurador.

               END.

            /* Tipo do documento */
            IF NOT CAN-DO("CI,CN,CH,RE,PP,CT",tt-crapavt.tpdocava) THEN  
               DO:                                      
                  ASSIGN par_nmdcampo = "tpdocava"         
                         par_dscritic = "O tipo de documento do Procurador " +
                                        "CPF " + {&CPF-AVT} + " nao e valido.".

                  LEAVE Procurador.

               END.

            /* Numero do documento */
            IF tt-crapavt.nrdocava = "" THEN  
               DO:                                      
                  ASSIGN par_nmdcampo = "nrdocava"         
                         par_dscritic = "O numero do documento do Procurador " +
                                        "CPF " + {&CPF-AVT} + " deve ser " +
                                        "preenchido.".

                  LEAVE Procurador.

               END.

            /* Numero do documento */
            IF tt-crapavt.cdoeddoc = "" THEN  
               DO:                                      
                  ASSIGN par_nmdcampo = "cdoeddoc"         
                         par_dscritic = "O orgao emissor do Procurador " +
                                        "CPF " + {&CPF-AVT} + " deve ser " +
                                        "preenchido.".

                  LEAVE Procurador.

               END.

            /* Identificar orgao expedidor */
            IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                RUN sistema/generico/procedures/b1wgen0052b.p 
                    PERSISTENT SET h-b1wgen0052b.

            ASSIGN aux_idorgexp = 0.
            RUN identifica_org_expedidor IN h-b1wgen0052b 
                               ( INPUT tt-crapavt.cdoeddoc,
                                OUTPUT aux_idorgexp,
                                OUTPUT par_cdcritic, 
                                OUTPUT par_dscritic).

            DELETE PROCEDURE h-b1wgen0052b.   

            IF  RETURN-VALUE = "NOK" THEN
            DO:
                LEAVE Procurador.
            END.   

            /* Unidade da Federacao do documento */
            IF NOT ValidaUf(tt-crapavt.cdufddoc) THEN
               DO:
                  ASSIGN par_nmdcampo = "cdufddoc"         
                         par_dscritic = "Unidade da Federacao do documento do " +
                                        "Procurador CPF " + {&CPF-AVT} + 
                                        " invalida.".

                  LEAVE Procurador.

               END.

            /* Data de emissao do documento */
            IF tt-crapavt.dtemddoc = ? THEN
               DO:
                  ASSIGN par_nmdcampo = "dtemddoc"         
                         par_dscritic = "Data da emissao do documento do " + 
                                        "Procurador CPF " + {&CPF-AVT} + 
                                        " deve ser informada.".

                  LEAVE Procurador.

               END.

            ERROR-STATUS:ERROR = FALSE.

            DATE(tt-crapavt.dtemddoc) NO-ERROR.

            IF ERROR-STATUS:ERROR THEN
               DO:
                  ASSIGN par_nmdcampo = "dtemddoc"         
                         par_dscritic = "Data da emissao do documento do " + 
                                        "Procurador CPF " + {&CPF-AVT} + 
                                        " possui formato invalido.".

                  LEAVE Procurador.

               END.

            /* Data de emissao do documento */
            IF (tt-crapavt.dtemddoc > par_dtmvtolt)          OR
               (par_dtmvtolt - tt-crapavt.dtemddoc >= 38716) THEN
               DO:
                  ASSIGN par_nmdcampo = "dtemddoc"         
                         par_dscritic = "Data da emissao do documento do " + 
                                        "Procurador CPF " + {&CPF-AVT} + 
                                        " incorreta.".

                  LEAVE Procurador.

               END.

        END. /* FOR EACH tt-crapavt  */

        IF NOT CAN-FIND(FIRST tt-crapavt WHERE
                                         tt-crapavt.deletado = NO    AND
                                         tt-crapavt.cddopcao <> "E") AND 
           NOT CAN-FIND(FIRST crapepa WHERE
                         crapepa.cdcooper = par_cdcooper             AND
                         crapepa.nrdconta = par_nrdconta)            THEN
           DO:
               FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                                  crapjur.nrdconta = par_nrdconta 
                                  NO-LOCK NO-ERROR.

               IF AVAIL crapjur THEN
                  DO:
                     FIND gncdntj WHERE gncdntj.cdnatjur = crapjur.natjurid AND
                                        gncdntj.flgprsoc = TRUE 
                                        NO-LOCK NO-ERROR.

                     IF AVAIL gncdntj THEN
                        DO: 
                           ASSIGN par_dscritic = "Deve existir pelo menos um " +
                                                 "representante/procurador!".

                           LEAVE Procurador.
                        
                        END.

                  END.

           END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Procurador.

    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Valida_Procurador */

/* ------------------------------------------------------------------------ */
/*                    CALCULA O PARCELAMENTO DE CAPITAL                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Calcula_Parcelamento :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM par_qtparcel AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_vlparcel AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    Parcelamento: DO ON ERROR UNDO Parcelamento, LEAVE Parcelamento:

        FOR FIRST crapcop FIELDS(nrdocnpj)
                          WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crapcop THEN
            DO:
               ASSIGN par_cdcritic = 651.
               LEAVE Parcelamento.
            END.

        IF  crapcop.nrdocnpj = par_nrcpfcgc THEN
            DO:
               ASSIGN aux_returnvl = "OK".
               LEAVE Parcelamento.
            END.

        FOR FIRST crapmat FIELDS(vlcapsub vlcapini qtparcap)
                          WHERE crapmat.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crapmat THEN
            DO:
               ASSIGN par_cdcritic = 71.
               LEAVE Parcelamento.
            END.

        ASSIGN 
            par_vlparcel = (IF crapmat.vlcapsub <> crapmat.vlcapini
                            THEN crapmat.vlcapsub - crapmat.vlcapini
                            ELSE crapmat.vlcapsub)
            par_qtparcel = crapmat.qtparcap.

        ASSIGN aux_returnvl = "OK".

        LEAVE Parcelamento.
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.
        
END PROCEDURE. /* Calcula_Parcelamento */

/*........................ PROCEDURES INTERNAS/PRIVADAS ....................*/

/* ------------------------------------------------------------------------ */
/*                     VERIFICA PRODUTOS/SERVICOS ATIVOS                    */
/* ------------------------------------------------------------------------ */

PROCEDURE Produtos_Servicos_Ativos:
    
    /* entrada e saida */
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdemiss AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-prod_serv_ativos.

    /* variaveis auxiliares */
    DEF VAR aux_tpctrlim LIKE craplim.tpctrlim                      NO-UNDO.
    DEF VAR aux_dtanoasb AS INTEGER                                 NO-UNDO. 
    DEF VAR aux_dtanopgd AS INTEGER                                 NO-UNDO.
    DEF VAR aux_nmctrato AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdseqcia AS INTE                                    NO-UNDO.
    DEF VAR aux_existere AS CHAR                                    NO-UNDO.
    DEF VAR aux_des_erro AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstrans1 AS CHAR                                    NO-UNDO.
	DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
	DEF VAR aux_qttotage AS INTE                                    NO-UNDO.
	DEF VAR aux_dsdmesag AS CHAR                                    NO-UNDO.
	DEF VAR aux_vlresapl AS DECIMAL INIT 0                          NO-UNDO.
	DEF VAR aux_vlsrdrpp AS DECIMAL INIT 0                          NO-UNDO.
	DEF VAR aux_vlborder AS DECIMAL INIT 0                          NO-UNDO.

    DEF VAR h-b1wgen0003 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0009 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0001 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0082 AS HANDLE                                  NO-UNDO.
	DEF VAR h-b1wgen0081 AS HANDLE                                  NO-UNDO.
	DEF VAR h-b1wgen0006 AS HANDLE                                  NO-UNDO.


    /* inicializando e zerando */
    ASSIGN  aux_cdseqcia = 0
            aux_tpctrlim = 0
            aux_nmctrato = ""
            par_dscritic = ""
            par_cdcritic = 0
            aux_returnvl = "NOK".

    EMPTY TEMP-TABLE tt-prod_serv_ativos.

    Produtos_Servicos_Ativos: 
        DO WHILE TRUE ON ERROR UNDO Produtos_Servicos_Ativos, 
        LEAVE Produtos_Servicos_Ativos:

        /*----------------------   VERIFICACOES -----------------------------*/

    
        /********************* Limite de Credito *****************************/
        IF CAN-FIND(FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                                        craplim.nrdconta = par_nrdconta AND
                                        craplim.tpctrlim = 1            AND
                                        craplim.insitlim = 2        NO-LOCK)
        THEN DO:
            ASSIGN aux_cdseqcia = aux_cdseqcia + 1.
            CREATE tt-prod_serv_ativos.
            ASSIGN tt-prod_serv_ativos.cdseqcia = aux_cdseqcia
                   tt-prod_serv_ativos.nmproser = "Limite de Credito".
        END.
    
        /********************** Plano de Cotas *******************************/
        IF CAN-FIND(FIRST crappla WHERE crappla.cdcooper = par_cdcooper AND
                                        crappla.nrdconta = par_nrdconta AND
                                        crappla.cdsitpla = 1        NO-LOCK)
        THEN DO:
            ASSIGN aux_cdseqcia = aux_cdseqcia + 1.
            CREATE tt-prod_serv_ativos.
            ASSIGN tt-prod_serv_ativos.cdseqcia = aux_cdseqcia
                   tt-prod_serv_ativos.nmproser = "Plano de Cotas".
        END.

        /********************** Poupanca Programada **************************/
        IF CAN-FIND(FIRST craprpp WHERE craprpp.cdcooper = par_cdcooper AND
                                        craprpp.nrdconta = par_nrdconta AND
                                        craprpp.cdsitrpp = 1        NO-LOCK)
        THEN DO:
            ASSIGN aux_cdseqcia = aux_cdseqcia + 1.
            CREATE tt-prod_serv_ativos.
            ASSIGN tt-prod_serv_ativos.cdseqcia = aux_cdseqcia
                   tt-prod_serv_ativos.nmproser = "Aplicacao Programada".
        END.
    
		/*Cartao de credito*/
		IF CAN-FIND(FIRST crawcrd WHERE crawcrd.cdcooper = par_cdcooper
								   AND crawcrd.nrdconta = par_nrdconta
								   AND (crawcrd.insitcrd = 4 
									OR  crawcrd.insitcrd = 3
									OR  crawcrd.insitcrd = 7)
									NO-LOCK) THEN
		DO:
		    ASSIGN aux_cdseqcia = aux_cdseqcia + 1.
            CREATE tt-prod_serv_ativos.
            ASSIGN tt-prod_serv_ativos.cdseqcia = aux_cdseqcia
                   tt-prod_serv_ativos.nmproser = "Cartao de credito".
		END.

		/* Buscar data do proximo dia util*/
		FOR FIRST crapdat FIELDS(dtmvtopr inproces)
						  WHERE crapdat.cdcooper = par_cdcooper
						  NO-LOCK:
		END.

		RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT SET h-b1wgen0006.      
    
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
											   INPUT crapdat.dtmvtopr,
											   INPUT crapdat.inproces,
											   INPUT par_nmdatela,
											   INPUT FALSE,
											  OUTPUT aux_vlsrdrpp,
											  OUTPUT TABLE tt-erro,
											  OUTPUT TABLE tt-dados-rpp).
                                          
		DELETE PROCEDURE h-b1wgen0006.

		IF aux_vlsrdrpp > 0 THEN
		   DO:
		        ASSIGN aux_cdseqcia = aux_cdseqcia + 1.
				CREATE tt-prod_serv_ativos.
				ASSIGN tt-prod_serv_ativos.cdseqcia = aux_cdseqcia
					   tt-prod_serv_ativos.nmproser = "Resgate da Aplicacao Programada".

		   END.

		
        /***************** Bordero *********************/
        RUN sistema/generico/procedures/b1wgen0009.p PERSISTENT SET h-b1wgen0009.    
    
	    /* Chamado 826663 - buscar valor do cheque descontado
        RUN busca_borderos IN h-b1wgen0009 (INPUT par_cdcooper,
                                            INPUT par_nrdconta,
                                            INPUT par_dtmvtolt,
                                            INPUT FALSE,
                                           OUTPUT TABLE tt-bordero_chq).
          
	    */
		
	    RUN busca_dados_dscchq IN h-b1wgen0009 (INPUT par_cdcooper,
                                                INPUT par_cdagenci,
                                                INPUT par_nrdcaixa,
                                                INPUT par_cdoperad,
                                                INPUT par_dtmvtolt,
                                                INPUT par_nrdconta,
                                                INPUT par_idseqttl,
                                                INPUT par_idorigem,
                                                INPUT par_nmdatela,
                                                INPUT FALSE, /* LOG*/
                                               OUTPUT TABLE tt-erro, 
                                               OUTPUT TABLE tt-desconto_cheques).
                    
        DELETE PROCEDURE h-b1wgen0009.
    
        FOR EACH tt-desconto_cheques NO-LOCK:
		
          ASSIGN aux_vlborder = aux_vlborder + tt-desconto_cheques.vldscchq.
		  
        END.

	    IF aux_vlborder > 0 THEN
        DO:
            ASSIGN aux_cdseqcia = aux_cdseqcia + 1.
            CREATE tt-prod_serv_ativos.
            ASSIGN tt-prod_serv_ativos.nmproser = "Borderos".
        END.	 
		   
        /***************** Limite de Desconto de Cheques *********************/
        IF CAN-FIND(FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                                        craplim.nrdconta = par_nrdconta AND
                                        craplim.tpctrlim = 2            AND
                                        craplim.insitlim = 2        NO-LOCK)
        THEN DO:
            ASSIGN aux_cdseqcia = aux_cdseqcia + 1.
            CREATE tt-prod_serv_ativos.
            ASSIGN tt-prod_serv_ativos.cdseqcia = aux_cdseqcia
                tt-prod_serv_ativos.nmproser = "Limite de Desconto de Cheques".
        END. 
    
        /****************** Limite de Desconto de Titulos ********************/
        IF CAN-FIND(FIRST craplim WHERE craplim.cdcooper = par_cdcooper  AND
                                         craplim.nrdconta = par_nrdconta AND
                                         craplim.tpctrlim = 3            AND
                                         craplim.insitlim = 2        NO-LOCK)
        THEN DO:
            ASSIGN aux_cdseqcia = aux_cdseqcia + 1.
            CREATE tt-prod_serv_ativos.
            ASSIGN tt-prod_serv_ativos.cdseqcia = aux_cdseqcia
                tt-prod_serv_ativos.nmproser = "Limite de Desconto de Titulos".
        END.


        /******************** Cartao Magnetico *******************************/
        IF CAN-FIND(FIRST crapcrm WHERE crapcrm.cdcooper  = par_cdcooper AND
                                        crapcrm.nrdconta  = par_nrdconta AND
                                        crapcrm.cdsitcar  = 2            AND
										crapcrm.tpcarcta  <> 9           AND
                                        crapcrm.dtvalcar >= par_dtmvtolt 
                                        NO-LOCK)
        THEN DO:
            ASSIGN aux_cdseqcia = aux_cdseqcia + 1.
            CREATE tt-prod_serv_ativos.
            ASSIGN tt-prod_serv_ativos.cdseqcia = aux_cdseqcia
                   tt-prod_serv_ativos.nmproser = "Cartao Magnetico".
        END.

		

		/* Buscar quantidade de folhas de cheque em uso */
		FOR EACH crapfdc FIELDS(cdcooper nrdconta cdbanchq cdagechq nrctachq nrcheque) 
						  WHERE crapfdc.cdcooper = par_cdcooper 
							AND crapfdc.nrdconta = par_nrdconta
							AND crapfdc.incheque = 0 
							AND crapfdc.dtliqchq = ? 
							AND crapfdc.dtemschq <> ? 
							AND crapfdc.dtretchq <> ?
								NO-LOCK:
								
			FIND FIRST crapneg WHERE crapneg.cdcooper = crapfdc.cdcooper AND
								     crapneg.nrdconta = crapfdc.nrdconta AND
									 crapneg.cdbanchq = crapfdc.cdbanchq AND
									 crapneg.cdagechq = crapfdc.cdagechq AND
									 crapneg.nrctachq = crapfdc.nrctachq AND
									 crapneg.cdhisest = 1 				AND
									 INT(SUBSTR(STRING(crapneg.nrdocmto,"9999999"),1,6))  = crapfdc.nrcheque 
									 NO-LOCK NO-ERROR.
								
			IF NOT AVAIL crapneg THEN
			   DO:
            ASSIGN aux_cdseqcia = aux_cdseqcia + 1.
            CREATE tt-prod_serv_ativos.
            ASSIGN tt-prod_serv_ativos.cdseqcia = aux_cdseqcia
                   tt-prod_serv_ativos.nmproser = "Cheque".
			      LEAVE.
        END. 

		END.
		
		

        /************************ Emprestimo *********************************/
        IF CAN-FIND(FIRST crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                                        crapepr.nrdconta = par_nrdconta AND
                                        crapepr.inliquid = 0        NO-LOCK)
        THEN DO:
            ASSIGN aux_cdseqcia = aux_cdseqcia + 1.
            CREATE tt-prod_serv_ativos.
            ASSIGN tt-prod_serv_ativos.cdseqcia = aux_cdseqcia
                   tt-prod_serv_ativos.nmproser = "Emprestimo".
        END. 

		RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.

		RUN obtem-dados-aplicacoes IN h-b1wgen0081 (INPUT par_cdcooper,
													INPUT par_cdagenci,
													INPUT par_nrdcaixa,
													INPUT par_cdoperad,
													INPUT par_nmdatela,
													INPUT par_idorigem,
													INPUT par_nrdconta,
													INPUT par_idseqttl,
													INPUT 0,
													INPUT par_nmdatela,                                                 
													INPUT 0,
													INPUT ?,
													INPUT ?,
												   OUTPUT aux_vlresapl,
												   OUTPUT TABLE tt-saldo-rdca,
												   OUTPUT TABLE tt-erro).
        
		DELETE PROCEDURE h-b1wgen0081.
        
		IF aux_vlresapl > 0 THEN
        DO:
                    ASSIGN aux_cdseqcia = aux_cdseqcia + 1.
                    CREATE tt-prod_serv_ativos.
                    ASSIGN tt-prod_serv_ativos.cdseqcia = aux_cdseqcia
					   tt-prod_serv_ativos.nmproser = "Aplicacao".
                END.
    
        /***************************** Convenio ******************************/
        IF CAN-FIND(FIRST crapatr WHERE crapatr.cdcooper = par_cdcooper AND
                                        crapatr.nrdconta = par_nrdconta AND
                                        crapatr.dtfimatr = ?        NO-LOCK)
        THEN DO:
            ASSIGN aux_cdseqcia = aux_cdseqcia + 1.
            CREATE tt-prod_serv_ativos.
            ASSIGN tt-prod_serv_ativos.cdseqcia = aux_cdseqcia
                   tt-prod_serv_ativos.nmproser = "Convenio".
        END.

        
        /*********************** Lancamento Futuro ***************************/
        RUN sistema/generico/procedures/b1wgen0003.p 
            PERSISTENT SET h-b1wgen0003.
			
        RUN consulta-lancamento IN 
            h-b1wgen0003 (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nrdconta,
                          INPUT par_idorigem,
                          INPUT par_idseqttl,
                          INPUT par_nmdatela,
                          INPUT par_flgerlog,
                         OUTPUT TABLE tt-totais-futuros,
                         OUTPUT TABLE tt-erro,
                         OUTPUT TABLE tt-lancamento_futuro).

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro.
                ASSIGN par_cdcritic = tt-erro.cdcritic.
            END.

        DELETE PROCEDURE h-b1wgen0003.
        IF  CAN-FIND(FIRST tt-lancamento_futuro NO-LOCK)  
        THEN DO:
            ASSIGN aux_cdseqcia = aux_cdseqcia + 1.
            CREATE tt-prod_serv_ativos.
            ASSIGN tt-prod_serv_ativos.cdseqcia = aux_cdseqcia
                   tt-prod_serv_ativos.nmproser = "Lancamentos Futuros".    
        END.


		RUN sistema/generico/procedures/b1wgen0082.p PERSISTENT SET h-b1wgen0082.

		RUN carrega-convenios-ceb IN h-b1wgen0082 (INPUT par_cdcooper,
												   INPUT par_cdagenci,
												   INPUT par_nrdcaixa,
												   INPUT par_cdoperad,
												   INPUT par_nmdatela,
												   INPUT par_idorigem,
												   INPUT par_nrdconta,
												   INPUT par_idseqttl,
												   INPUT par_dtmvtolt,
												   INPUT FALSE,
												  OUTPUT aux_dsdmesag,
												  OUTPUT TABLE tt-cadastro-bloqueto,
												  OUTPUT TABLE tt-crapcco,
												  OUTPUT TABLE tt-titulares,
												  OUTPUT TABLE tt-emails-titular).
       
		DELETE PROCEDURE h-b1wgen0082.
    
		/* Projeto 364 - Andrey - INICIO */
		FOR FIRST tt-cadastro-bloqueto WHERE tt-cadastro-bloqueto.insitceb = 1 NO-LOCK:
                ASSIGN aux_cdseqcia = aux_cdseqcia + 1.
                CREATE tt-prod_serv_ativos.
                ASSIGN tt-prod_serv_ativos.cdseqcia = aux_cdseqcia
                       tt-prod_serv_ativos.nmproser = "Cobranca".
                LEAVE.
            END.
             

        /********************** PAMCARD  *********************************/
        IF par_dtdemiss <> ? THEN
        DO:
            IF CAN-FIND(FIRST crappam WHERE crappam.cdcooper = par_cdcooper AND
                                            crappam.nrdconta = par_nrdconta AND
                                            crappam.flgpamca = TRUE) THEN
               DO:
                  ASSIGN aux_cdseqcia = aux_cdseqcia + 1.
                  CREATE tt-prod_serv_ativos.
                  ASSIGN tt-prod_serv_ativos.cdseqcia = aux_cdseqcia
                         tt-prod_serv_ativos.nmproser = "PAMCARD".

                        /*
                   ASSIGN par_dscritic = "Convenio PAMCARD esta ativo."
                          par_nmdcampo = "flgpamca".*/
             
               END.
        
           END.

		
		/* Verificar se conta possui conta ITG ativa */
		FOR FIRST crapass WHERE crapass.cdcooper = par_cdcooper
							AND crapass.nrdconta = par_nrdconta
							AND crapass.flgctitg = 2 NO-LOCK:
               ASSIGN aux_cdseqcia = aux_cdseqcia + 1.
               CREATE tt-prod_serv_ativos.
               ASSIGN tt-prod_serv_ativos.cdseqcia = aux_cdseqcia
		  		   tt-prod_serv_ativos.nmproser = "Conta ITG.".
           END.

        /********************* Convenio cdc *****************************/ 
        IF CAN-FIND(FIRST crapcdr WHERE crapcdr.cdcooper = par_cdcooper 
                                    AND crapcdr.nrdconta = par_nrdconta 
                                    AND crapcdr.flgconve = TRUE) THEN
        DO: 
          ASSIGN aux_cdseqcia = aux_cdseqcia + 1. 
          CREATE tt-prod_serv_ativos. 
          ASSIGN tt-prod_serv_ativos.cdseqcia = aux_cdseqcia 
                 tt-prod_serv_ativos.nmproser = "Convenio CDC".
        END.

        LEAVE Produtos_Servicos_Ativos.
		
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".
    ELSE
  	  ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* Produtos Servicos Ativos */



/* ------------------------------------------------------------------------ */
/*                     REALIZA A CRITICA DOS DADOS                          */
/*     { criticas_dados_matrici.i } e { criticas_dados_matrica.i }          */
/* ------------------------------------------------------------------------ */
PROCEDURE Criticas PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inmatric AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagepac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasctl AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmmaettl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtdemiss AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdmotdem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcnscpf AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitcpf AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_msgretor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-alertas.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsagepac AS CHAR                                    NO-UNDO.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    Criticas: DO ON ERROR UNDO Criticas, LEAVE Criticas:

        IF  par_cddopcao = "D" THEN
            DO:
               ASSIGN aux_returnvl = "OK".
               LEAVE Criticas.
            END.

        /* Agencia - PAC */
        IF  NOT CAN-FIND(crapage WHERE
                         crapage.cdcooper = par_cdcooper AND
                         crapage.cdagenci = par_cdagepac) THEN
            DO:
               ASSIGN
                   par_nmdcampo = "cdagenci"
                   par_cdcritic = 15.
               LEAVE Criticas.
            END.

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p
                PERSISTENT SET h-b1wgen0060.

        /* fontes/valida_situacao_pac.p */
        IF  NOT DYNAMIC-FUNCTION("BuscaPac" IN h-b1wgen0060,
                                 INPUT par_cdcooper,
                                 INPUT par_cdagepac,
                                 INPUT "nmresage",
                                OUTPUT aux_dsagepac,
                                OUTPUT par_dscritic) THEN
            DO:
                ASSIGN
                   par_nmdcampo = "cdagenci".
                LEAVE Criticas.
            END.
        
        /* Situacao - CPF */
        IF  par_dtcnscpf <> ?                     AND 
           (par_cdsitcpf < 1 OR par_cdsitcpf > 5) THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "cdsitcpf"
                   par_cdcritic = 444.
               LEAVE Criticas.
            END.

        CASE par_cddopcao:
            /* Validar as criticas de Inclusao
              quando Incluir ("I") ou alterar o CPF/CNPJ ("J") */
            WHEN "I" OR WHEN "J" THEN DO:
                RUN Criticas_Inclusao 
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_cddopcao,
                      INPUT par_inpessoa,
                      INPUT par_inmatric,
                      INPUT par_cdagepac,
                      INPUT par_nrcpfcgc,
                      INPUT par_nmprimtl,
                      INPUT par_dtnasctl,
                      INPUT par_nmmaettl,
                      INPUT par_dtdemiss,
                     OUTPUT par_msgretor,
                     OUTPUT par_nmdcampo,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic,
                     OUTPUT TABLE tt-alertas ) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       LEAVE Criticas.
                    END.

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Criticas.
            END.
            WHEN "A" THEN DO:
                RUN Criticas_Alteracao 
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_inpessoa,
                      INPUT par_dtmvtolt,
                      INPUT par_cdagepac,
                      INPUT par_dtdemiss,
                      INPUT par_cdmotdem,
                     OUTPUT par_nmdcampo,
                     OUTPUT par_cdcritic,
                     OUTPUT par_dscritic,
                     OUTPUT TABLE tt-alertas ) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = par_dscritic + {&GET-MSG}.
                       LEAVE Criticas.
                    END.

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Criticas.
            END.
        END CASE.

        ASSIGN aux_returnvl = "OK".

        LEAVE Criticas.
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Criticas */

/* ------------------------------------------------------------------------ */
/*        REALIZA A CRITICA DOS DADOS  { criticas_dados_matrica.i }         */
/* ------------------------------------------------------------------------ */
PROCEDURE Criticas_Alteracao PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagepac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdemiss AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdmotdem AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-alertas.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsagepac AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsmotdem AS CHAR                                    NO-UNDO.

    DEF BUFFER crabass FOR crapass.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    CriticasA: DO ON ERROR UNDO CriticasA, LEAVE CriticasA:

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
                PERSISTENT SET h-b1wgen0060.

        /* fontes/valida_situacao_pac.p */
        IF  NOT DYNAMIC-FUNCTION("BuscaPac" IN h-b1wgen0060,
                                 INPUT par_cdcooper,
                                 INPUT par_cdagepac,
                                 INPUT "nmresage",
                                OUTPUT aux_dsagepac,
                                OUTPUT par_dscritic) THEN 
            LEAVE CriticasA.

        FOR FIRST crabass FIELDS(dtdemiss nrcpfcgc)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "nrcpfcgc"
                   par_cdcritic = 9.

               LEAVE CriticasA.
            END.

        /* consistencias em caso de demissao */
        IF  ((par_dtdemiss <> ?) OR (par_cdmotdem <> 0)) THEN
            DO:
               IF  par_dtdemiss <> crabass.dtdemiss THEN
                   DO:
                      IF  par_dtdemiss >= DATE(MONTH(par_dtmvtolt),01,
                                               YEAR(par_dtmvtolt)) AND
                          par_dtdemiss <= par_dtmvtolt THEN
                          ASSIGN par_cdcritic = 0.
                      ELSE
                          DO:
                             ASSIGN 
                                 par_nmdcampo = "dtdemiss"
                                 par_cdcritic = 13.
                             LEAVE CriticasA.
                          END.
                   END.

               IF  par_cdmotdem = 0 THEN
                   DO:
                       ASSIGN 
                          par_nmdcampo = "cdmotdem"
                          par_dscritic = "Motivo da demissao deve ser " + 
                                         "informado.".
                      LEAVE CriticasA.
                   END.
               ELSE
                   DO:
				      
                      IF par_dtdemiss = ? THEN
                      DO:
                          ASSIGN par_nmdcampo = "dtdemiss"
                                 par_dscritic = "Data de demissao deve ser "+
                                                "informado".
                          LEAVE CriticasA.
                      END.

                   END.


               /* buscar motivo demissão  */
               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                            
                /* Efetuar a chamada a rotina Oracle */ 
                RUN STORED-PROCEDURE prc_busca_motivo_demissao
                aux_handproc = PROC-HANDLE NO-ERROR 
                  ( INPUT par_cdcooper      /* pr_cdcooper --> Codigo da cooperativa */
                   ,INPUT par_cdmotdem      /* pr_cdmotdem --> Código Motivo Demissao */
                   /* --------- OUT --------- */
                   ,OUTPUT ""           /* pr_dsmotdem --> Descriçao Motivo Demissao */
                   ,OUTPUT 0            /* pr_cdcritic --> Codigo da critica)   */
                   ,OUTPUT "" ).        /* pr_des_erro --> Descriçao da critica).  */
                                        
                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC prc_busca_motivo_demissao
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                            
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                ASSIGN aux_dsmotdem = prc_busca_motivo_demissao.pr_dsmotdem
                                 WHEN prc_busca_motivo_demissao.pr_dsmotdem <> ?.   
                ASSIGN par_dscritic = prc_busca_motivo_demissao.pr_des_erro
                                 WHEN prc_busca_motivo_demissao.pr_des_erro <> ?.  

               IF  par_dscritic <> "" THEN
                   DO:
                      ASSIGN par_nmdcampo = "cdmotdem".
                      LEAVE CriticasA.
                   END.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE CriticasA.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Criticas_Alteracao */

/* ------------------------------------------------------------------------ */
/*        REALIZA A CRITICA DOS DADOS  { criticas_dados_matrici.i }         */
/* ------------------------------------------------------------------------ */
PROCEDURE Criticas_Inclusao PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inmatric AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagepac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasctl AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmmaettl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtdemiss AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_msgretor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-alertas.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsalerta AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfcgc AS DECI                                    NO-UNDO.
    DEF VAR aux_nrctaass AS INTE                                    NO-UNDO.
    DEF VAR aux_sqalerta AS INTE                                    NO-UNDO.
    DEF VAR aux_dtdemsoc AS DATE                                    NO-UNDO.
     
    DEF VAR h-b1wgen0031 AS HANDLE                                  NO-UNDO.

    DEF BUFFER crabass FOR crapass.

    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    CriticasI: DO ON ERROR UNDO CriticasI, LEAVE CriticasI:
        
        /* C.P.F. ou C.N.P.J. */
        IF  NOT ValidaCpfCnpj(par_cdcooper,par_nrcpfcgc) THEN
            DO:
               ASSIGN
                   par_nmdcampo = "nrcpfcgc"
                   par_cdcritic = 27.
               LEAVE CriticasI.
            END.
        ELSE
            ASSIGN aux_nrcpfcgc = ConverteCpfCnpj(INPUT par_nrcpfcgc).

        FOR FIRST crapcop FIELDS(nrdocnpj)
                          WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crapcop THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "nrcpfcgc"
                   par_cdcritic = 651.
               LEAVE CriticasI.
            END.

        /*  Verifica se eh uma conta administrativa  .................... */
        IF  (crapcop.nrdocnpj = aux_nrcpfcgc) AND par_cddopcao = "I" THEN
            ASSIGN 
               par_inpessoa = 3
               par_msgretor = "ATENCAO!!! Esta sendo criada uma conta " + 
                              "administrativa!".

        IF  NOT(par_inpessoa <> 3 AND par_inmatric <> 2) THEN
            DO:
               ASSIGN aux_returnvl = "OK".
               LEAVE CriticasI.
            END.

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
                PERSISTENT SET h-b1wgen0060.

        ASSIGN par_cdcritic = 0
               par_dscritic = ""
               aux_nrctaass = 0
               aux_dtdemsoc = ?.

        /* Testa se ha associados com mesmo cpf */  
        CpfCnpj: 
        FOR EACH crabass FIELDS(cdcooper cdsitdtl nrdconta dtdemiss)
                         WHERE crabass.cdcooper =  par_cdcooper AND
                               crabass.nrcpfcgc =  aux_nrcpfcgc AND
                               crabass.inmatric =  1            AND
                               crabass.nrdconta <> par_nrdconta NO-LOCK:

            IF  crabass.cdsitdtl > 4 AND crabass.cdsitdtl < 9 THEN
                DO:
                   ASSIGN 
                       par_nmdcampo = "nrcpfcgc"
                       par_cdcritic = 621
                       aux_nrctaass = crabass.nrdconta
                       aux_dtdemsoc = ?.
                   LEAVE CpfCnpj.
                END.

            /* Essa regra de negocio foi removida porque foi
            considerada desnecessaria para atualizacao do 
            cadastro */

            /* Conforme solicitaçao do Chamado 269526 esta
               validaçao deve ser executada */

           /* Solicitado pela Sarah retirar essa validacao */


            /* cria o alerta */
            IF  aux_dtdemsoc = ? OR crabass.dtdemiss > aux_dtdemsoc THEN
                ASSIGN 
                    par_nmdcampo = "nrcpfcgc"
                    aux_dtdemsoc = crabass.dtdemiss
                    aux_nrctaass = crabass.nrdconta
                    par_cdcritic = 741.

        END.  /*  Fim do FOR EACH CpfCnpj */

        IF  par_cdcritic = 741 THEN
            DO: 
               ASSIGN 
                   par_nmdcampo = "nrcpfcgc"
                   aux_dsalerta = DYNAMIC-FUNCTION("BuscaCritica" IN 
                                                   h-b1wgen0060,par_cdcritic).

               IF  aux_dtdemsoc = ? THEN
                   ASSIGN aux_dsalerta = aux_dsalerta + " " +  
                                         TRIM(STRING(aux_nrctaass,
                                                     "zzzz,zz9,9")).
               ELSE 
                   ASSIGN aux_dsalerta = aux_dsalerta + " " + 
                                         TRIM(STRING(aux_nrctaass,
                                                     "zzzz,zz9,9")) +
                                         " saida em " + 
                                         STRING(aux_dtdemsoc,"99/99/9999"). 

               FIND FIRST tt-alertas WHERE tt-alertas.dsalerta = aux_dsalerta
                                           NO-ERROR.

               IF  NOT AVAILABLE tt-alertas THEN 
                   DO:
                      CREATE tt-alertas.
                      ASSIGN 
                          tt-alertas.cdalerta = aux_sqalerta
                          tt-alertas.dsalerta = aux_dsalerta
                          aux_sqalerta        = aux_sqalerta + 1
                          par_cdcritic        = 0.
                   END.
            END.
        ELSE
        IF  par_cdcritic > 0 THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "nrcpfcgc"
                   par_dscritic = DYNAMIC-FUNCTION("BuscaCritica" IN 
                                                    h-b1wgen0060,par_cdcritic) 
                                  + " " + 
                                  TRIM(STRING(aux_nrctaass,"zzzz,zz9,9"))
                   par_cdcritic = 0.
    
               LEAVE CriticasI. 
            END.

        ASSIGN par_cdcritic = 0.

        /* Testa se ha demitidos com mesmo cpf - alerta */
        FOR FIRST crapdem FIELDS(nrdconta nrcpfcgc)
                          WHERE crapdem.cdcooper = par_cdcooper AND
                                crapdem.nrcpfcgc = aux_nrcpfcgc NO-LOCK:

            ASSIGN par_nmdcampo = "nrcpfcgc".

            CREATE tt-alertas.
            ASSIGN 
                tt-alertas.cdalerta = aux_sqalerta
                tt-alertas.dsalerta = DYNAMIC-FUNCTION("BuscaCritica" IN 
                                                       h-b1wgen0060,618) +
                STRING(STRING(crapdem.nrcpfcgc,"99999999999"),"999.999.999-99") +
                                      " CONTA "                        +
                                      STRING(crapdem.nrdconta,"zzzz,zz9,9")
                aux_sqalerta        = aux_sqalerta + 1.
        END.

        IF   par_cdcooper = 16   THEN /* Se Viacredi Alto Vale */
             DO:
                 RUN sistema/generico/procedures/b1wgen0031.p
                     PERSISTENT SET h-b1wgen0031.

                 RUN Criticas_AltoVale IN h-b1wgen0031 
                                       (INPUT par_cdcooper,
                                        INPUT aux_nrcpfcgc,
                                        INPUT-OUTPUT aux_sqalerta,
                                        INPUT-OUTPUT TABLE tt-alertas).

                 DELETE PROCEDURE h-b1wgen0031.

             END.

        ASSIGN aux_returnvl = "OK".

        LEAVE CriticasI.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Criticas_Inclusao */


/* ------------------------------------------------------------------------ */
/*             REALIZA A VALIDACAO DOS DADOS DA PESSOA FISICA               */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Fis PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcadass AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtcnscpf AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoedptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufdptl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtemdptl AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmmaettl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmpaittl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasctl AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsexotl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnatura AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufnatu AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdestcvl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmconjug AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcadast AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdocpttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inhabmen AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dthabmen AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdeanos AS INT                                     NO-UNDO.
    DEF VAR aux_nrdmeses AS INT                                     NO-UNDO.
    DEF VAR aux_dsdidade AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.


    ASSIGN par_dscritic = ""
           par_cdcritic = 0
           aux_returnvl = "NOK".

    ValidaFis: DO ON ERROR UNDO ValidaFis, LEAVE ValidaFis:
        
        /* Consulta - CPF */
        IF  par_cddopcao = "I" THEN
            DO:
               IF  par_dtcnscpf <> par_dtmvtolt AND
                   par_dtcnscpf <> ? THEN 
                   DO:
                      ASSIGN par_nmdcampo = "dtcnscpf"
                             par_cdcritic = 13.
                      LEAVE ValidaFis.
                   END.
            END.
        ELSE
        IF  par_cddopcao = "A" THEN
            DO:
               IF  par_dtcnscpf > par_dtmvtolt OR 
                   par_dtcnscpf < par_dtcadass OR 
                   par_dtcnscpf = ? THEN 
                   DO:
                      ASSIGN  par_nmdcampo = "dtcnscpf"
                              par_cdcritic = 13.
                      LEAVE ValidaFis.
                   END.
            END.

        /* Documento - tipo */
        IF  LOOKUP(par_tpdocptl,"CI,CN,CH,RE,PP,CT") = 0 THEN
            DO:
               ASSIGN par_nmdcampo = "tpdocptl"
                      par_cdcritic = 21.
               LEAVE ValidaFis.
            END.

        /* Documento - numero */
        IF  par_nrdocptl = "" THEN
            DO:
               ASSIGN par_nmdcampo = "nrdocptl"
                      par_cdcritic = 22.
               LEAVE ValidaFis.
            END.

        /* Org.Emi. */
        IF  par_cdoedptl = "" THEN
            DO:
               ASSIGN par_nmdcampo = "cdoedptl"
                      par_cdcritic = 375.
               LEAVE ValidaFis.
            END.

        /* U.F. - emissao do documento */
        IF  NOT ValidaUF(par_cdufdptl) THEN
            DO:
               ASSIGN par_nmdcampo = "cdufdptl"
                      par_cdcritic = 33.
               LEAVE ValidaFis.
            END.

        /* Mae - Pai */
        IF  (CAPS(par_nmmaettl) = CAPS(par_nmpaittl)) OR par_nmmaettl = "" THEN
            DO:
               ASSIGN par_nmdcampo = "nmmaettl"
                      par_cdcritic = 30.
               LEAVE ValidaFis.
            END.

        /* Data Nascimento */
        IF  par_dtnasctl = ?              OR 
            par_dtnasctl >= par_dtmvtolt  THEN
            DO:
               ASSIGN par_nmdcampo = "dtnasctl"
                      par_cdcritic = 13.
               LEAVE ValidaFis.
            END.

        /* Data Emi. */
        IF  par_dtemdptl < par_dtnasctl THEN 
            DO:
               ASSIGN par_nmdcampo = "dtemdptl"
                      par_cdcritic = 13.
               LEAVE ValidaFis.
            END.
        ELSE
            IF  par_dtemdptl = ? THEN
                DO:
                   ASSIGN par_nmdcampo = "dtemdptl"
                          par_cdcritic = 13.
                   LEAVE ValidaFis.
                END.

        /* Sexo */
        IF  NOT CAN-DO("1,2",STRING(par_cdsexotl,"9")) THEN
            DO:
               ASSIGN par_nmdcampo = "cdsexotl"
                      par_cdcritic = 86.
               LEAVE ValidaFis.
            END.

        /* Tipo Nacionalidade */
        IF  NOT CAN-FIND(gntpnac WHERE gntpnac.tpnacion = par_tpnacion) THEN
            DO:
               ASSIGN par_nmdcampo = "tpnacion"
                      par_dscritic = "Tipo de nacionalidade nao cadastrada.".
               LEAVE ValidaFis.
            END.

        /* Nacionalidade */
        IF  NOT CAN-FIND(crapnac WHERE crapnac.cdnacion = par_cdnacion) THEN
            DO:
               ASSIGN par_nmdcampo = "cdnacion"
                      par_cdcritic = 28.
               LEAVE ValidaFis.
            END.

        IF  NOT ValidaUF(par_cdufnatu) THEN
            DO:
               ASSIGN par_nmdcampo = "cdufnatu"
                      par_cdcritic = 33.
               LEAVE ValidaFis.
            END.

        IF   par_cdufnatu <> "EX" THEN
             DO:
        
                 /* Natural De */                        
                 FIND FIRST crapmun WHERE crapmun.dscidade = par_dsnatura AND 
                                          crapmun.cdestado = par_cdufnatu 
                                          NO-LOCK NO-ERROR.
             
                 IF   NOT AVAIL crapmun   THEN
                      DO:
                          ASSIGN par_nmdcampo = "cdufnatu"
                                 par_dscritic = " Naturalidade nao cadastrada ou " + 
                                                "U.F. nao corresponde a cidade informada.".
                          LEAVE ValidaFis.
                      END.
             END.
             
        /* Habilitacao - Responsab. Legal */
        IF par_inhabmen > 2 THEN
           DO:
              ASSIGN par_nmdcampo = "inhabmen"
                     par_dscritic = "Responsab. Legal invalida.".

              LEAVE ValidaFis.
           END.
        
        /* Habilitacao - Responsab. Legal */
        IF par_inhabmen = 1 AND par_dthabmen = ? THEN
           DO:
              ASSIGN par_nmdcampo = "dthabmen"
                     par_dscritic = "E necessario preencher a data da " +
                                    "emancipacao".
              LEAVE ValidaFis.
           END.
    

        IF NOT VALID-HANDLE(h-b1wgen9999) THEN
           RUN sistema/generico/procedures/b1wgen9999.p
               PERSISTENT SET h-b1wgen9999.

        /* validar pela procedure generica do b1wgen9999.p */
        RUN idade IN h-b1wgen9999 ( INPUT par_dtnasctl,
                                    INPUT par_dtmvtolt,
                                    OUTPUT aux_nrdeanos,
                                    OUTPUT aux_nrdmeses,
                                    OUTPUT aux_dsdidade ).

        IF VALID-HANDLE(h-b1wgen9999) THEN
           DELETE PROCEDURE(h-b1wgen9999).

        IF par_inhabmen = 0   AND
           par_cdestcvl <> 1  AND
           par_cdestcvl <> 12 AND 
           aux_nrdeanos < 18  THEN
           DO:
              IF par_dthabmen = ? THEN
                 DO:
                    ASSIGN par_nmdcampo = "dthabmen"
                           par_dscritic = "Estado Civil obriga ser " + 
                                          "Emancipado.".

                    LEAVE ValidaFis.

                 END.

           END.
        ELSE
           /* Habilitacao - Responsab. Legal */
           IF par_inhabmen <> 1 AND par_dthabmen <> ? THEN
              DO: 
                 ASSIGN par_nmdcampo = "dthabmen"
                        par_dscritic = "Data da emancipacao nao pode " + 
                                       "ser preenchida.".

                 LEAVE ValidaFis.

              END.
        
        /* Habilitacao - Responsab. Legal */
        IF par_dthabmen < par_dtnasctl THEN
           DO:
              ASSIGN par_nmdcampo = "dthabmen"
                     par_dscritic = "Data da emancipacao menor que a data " + 
                                    "de nascimento.".

              LEAVE ValidaFis.

           END.

        IF par_dthabmen > par_dtmvtolt THEN
           DO:
              ASSIGN par_nmdcampo = "dthabmen"
                     par_dscritic = "Data da emancipacao maior que a data " + 
                                    "atual.".

              LEAVE ValidaFis.
               
           END.

        /* Estado Civil */
        IF  NOT CAN-FIND(gnetcvl WHERE gnetcvl.cdestcvl = par_cdestcvl) THEN 
            DO:
               ASSIGN par_nmdcampo = "cdestcvl"
                      par_cdcritic = 35.
               LEAVE ValidaFis.
            END.

        /* Conjuge */
        IF  NOT CAN-DO("1,5,6,7",STRING(par_cdestcvl)) AND 
            par_nmconjug = "" THEN
            DO:
               /* Buscar conta do conjuge, caso exista*/
               FOR FIRST crapcje FIELDS(nrctacje)
                                 WHERE crapcje.cdcooper = par_cdcooper AND
                                       crapcje.nrdconta = par_nrdconta AND
                                       crapcje.idseqttl = 1       
                                       NO-LOCK:
               END.
               IF  AVAILABLE crapcje THEN  /*Veficicacao para casos do conjuge ser um cooperado*/
               DO:
                IF crapcje.nrctacje = 0 AND  par_nmconjug = ""  THEN
                DO:
                  ASSIGN par_nmdcampo = "nmconjug"
                         par_cdcritic = 38.
                  LEAVE ValidaFis.
                END.
               END.
               ELSE
               DO:
                ASSIGN par_nmdcampo = "nmconjug"
                       par_cdcritic = 38.
                LEAVE ValidaFis.
               END.
            END.

            
        /* CEP */
        IF  par_nrcepend = 0 THEN
            DO:
               ASSIGN par_nmdcampo = "nrcepend"
                      par_cdcritic = 34.
               LEAVE ValidaFis.
            END.
        ELSE
        IF  NOT CAN-FIND(FIRST crapdne 
                         WHERE crapdne.nrceplog = par_nrcepend)  THEN
            DO:
                ASSIGN par_nmdcampo = "nrcepend"
                       par_dscritic = "CEP nao cadastrado.".
                LEAVE ValidaFis.
            END.

        /* End.Residencial */
        IF  par_dsendere = "" THEN
            DO:
               ASSIGN par_nmdcampo = "dsendere"
                      par_cdcritic = 31.
               LEAVE ValidaFis.
            END.

        /* Bairro */
        IF  par_nmbairro = "" THEN
            DO:
               ASSIGN par_nmdcampo = "nmbairro"
                      par_cdcritic = 47.
               LEAVE ValidaFis.
            END.

        /* Cidade */
        IF  par_nmcidade = "" THEN
            DO:
               ASSIGN par_nmdcampo = "nmcidade"
                      par_cdcritic = 32.
               LEAVE ValidaFis.
            END.

        /* unidade da federacao - endereco */
        IF  NOT ValidaUF(par_cdufende) THEN
            DO:
               ASSIGN par_nmdcampo = "cdufende"
                      par_cdcritic = 33.
               LEAVE ValidaFis.
            END.

        IF  NOT CAN-FIND(FIRST crapdne
                         WHERE crapdne.nrceplog = par_nrcepend  
                           AND (TRIM(par_dsendere) MATCHES 
                               ("*" + TRIM(crapdne.nmextlog) + "*")
                            OR TRIM(par_dsendere) MATCHES
                               ("*" + TRIM(crapdne.nmreslog) + "*"))) THEN
            DO:
                ASSIGN par_dscritic = "Endereco nao pertence ao CEP."
                       par_nmdcampo = "nrcepend".
                LEAVE ValidaFis.
            END.

        /* Empresa */
        IF  NOT CAN-FIND(crapemp WHERE crapemp.cdcooper = par_cdcooper AND
                                       crapemp.cdempres = par_cdempres) THEN
            DO:
               ASSIGN par_nmdcampo = "cdempres"
                      par_cdcritic = 40.
               LEAVE ValidaFis.
            END.
		/*P437 Nao validar o campo matricula (par_nrcadast) removida validaçao DV*/

        /* Ocupacao */
        IF  NOT CAN-FIND(gncdocp WHERE gncdocp.cdocupa = par_cdocpttl) THEN
            DO:
               ASSIGN par_nmdcampo = "cdocpttl"
                      par_dscritic = "Codigo de ocupacao nao cadastrado.".
               LEAVE ValidaFis.
            END.

        /* Retirado no SD175963 - Verifica se ja existe o numero da conta como conta salario */
        /*IF  par_cddopcao = "I" AND CAN-FIND(crapccs WHERE 
                     crapccs.cdcooper = par_cdcooper                  AND
                     crapccs.nrcpfcgc = ConverteCpfCnpj(par_nrcpfcgc) AND
                     crapccs.cdsitcta = 1 /* Ativa */)                THEN
            DO:
               ASSIGN par_nmdcampo = "nrcpfcgc"
                      par_dscritic = "CPF possui conta salario ativa.".
               LEAVE ValidaFis.
            END.*/

        ASSIGN aux_returnvl = "OK".

        LEAVE ValidaFis.
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Valida_Fis */

/* ------------------------------------------------------------------------ */
/*            REALIZA A VALIDACAO DOS DADOS DA PESSOA JURIDICA              */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Jur PRIVATE :

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmfansia AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_natjurid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniatv AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdseteco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrmativ AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdddtfc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtelefo AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    
    ASSIGN
        par_dscritic = ""
        par_cdcritic = 0
        aux_returnvl = "NOK".

    ValidaJur: DO ON ERROR UNDO ValidaJur, LEAVE ValidaJur:

        /* Nome Fantasia */
        IF  par_nmfansia = "" THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "nmfansia"
                   par_cdcritic = 375.
               LEAVE ValidaJur.
            END.

        /* Natureza Juridica */
        IF  NOT CAN-FIND(gncdntj WHERE gncdntj.cdnatjur = par_natjurid) THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "natjurid"
                   par_dscritic = "Natureza Juridica nao cadastrada.".
               LEAVE ValidaJur.
            END.

        /* Inicio Atividade */
        IF  par_dtiniatv > TODAY OR par_dtiniatv = ? THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "dtiniatv"
                   par_cdcritic = 13.
               LEAVE ValidaJur.
            END.

        /* Setor Economico */
        IF  NOT CAN-FIND(craptab WHERE craptab.cdcooper = par_cdcooper   AND
                                       craptab.nmsistem = "CRED"         AND
                                       craptab.tptabela = "GENERI"       AND
                                       craptab.cdempres = 0              AND
                                       craptab.cdacesso = "SETORECONO"   AND
                                       craptab.tpregist = par_cdseteco) THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "cdseteco"
                   par_dscritic = "Setor economico nao encontrado.".
               LEAVE ValidaJur.
            END.

        /* Ramo */
        IF  NOT CAN-FIND(gnrativ WHERE gnrativ.cdseteco = par_cdseteco AND
                                       gnrativ.cdrmativ = par_cdrmativ) THEN
            DO:
               ASSIGN
                   par_nmdcampo = "cdrmativ"
                   par_dscritic = "Ramo de atividade nao encontrado.".
               LEAVE ValidaJur.
            END.

        /* DDD */
        IF  par_nrdddtfc = 0 THEN
            DO:
               ASSIGN
                   par_nmdcampo = "nrdddtfc"
                   par_dscritic = "DDD deve ser preenchido.".
               LEAVE ValidaJur.
            END.

        /* Telefone */
        IF  par_nrtelefo = 0 THEN
            DO:
               ASSIGN
                   par_nmdcampo = "nrtelefo"
                   par_cdcritic = 45.
               LEAVE ValidaJur.
            END.

        /* CEP */
        IF  par_nrcepend = 0 THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "nrcepend"
                   par_cdcritic = 34.
               LEAVE ValidaJur.
            END.
        ELSE
        IF  NOT CAN-FIND(FIRST crapdne 
                         WHERE crapdne.nrceplog = par_nrcepend)  THEN
            DO:
                ASSIGN
                    par_nmdcampo = "nrcepend"
                    par_dscritic = "CEP nao cadastrado.".
                LEAVE ValidaJur.
            END.

        /* End.Residencial */
        IF  par_dsendere = "" THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "dsendere"
                   par_cdcritic = 31.
               LEAVE ValidaJur.
            END.

        /* Bairro */
        IF  par_nmbairro = "" THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "nmbairro"
                   par_cdcritic = 47.
               LEAVE ValidaJur.
            END.

        /* Cidade */
        IF  par_nmcidade = "" THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "nmcidade"
                   par_cdcritic = 32.
               LEAVE ValidaJur.
            END.

        /* unidade da federacao - endereco */
        IF  NOT ValidaUF(par_cdufende) THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "cdufende"
                   par_cdcritic = 33.
               LEAVE ValidaJur.
            END.

        IF  NOT CAN-FIND(FIRST crapdne
                         WHERE crapdne.nrceplog = par_nrcepend  
                           AND (TRIM(par_dsendere) MATCHES 
                               ("*" + TRIM(crapdne.nmextlog) + "*")
                            OR TRIM(par_dsendere) MATCHES
                               ("*" + TRIM(crapdne.nmreslog) + "*"))) THEN
            DO:
                ASSIGN 
                    par_dscritic = "Endereco nao pertence ao CEP."
                    par_nmdcampo = "nrcepend".
                LEAVE ValidaJur.
            END.
        
        

        ASSIGN aux_returnvl = "OK".

        LEAVE ValidaJur.
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE. /* Valida_Jur */

/*........................... FUNCOES INTERNAS/PRIVADAS .....................*/

FUNCTION ConverteCpfCnpj RETURNS DECIMAL PRIVATE
  ( INPUT par_nrcpfcgc AS CHARACTER ) :
/*-----------------------------------------------------------------------------
  Objetivo:  Converter o Cpf ou Cnpj de string para decimal
     Notas:  
-----------------------------------------------------------------------------*/

  RETURN DEC(REPLACE(REPLACE(REPLACE(par_nrcpfcgc,".",""),"-",""),"/","")).

END FUNCTION.

FUNCTION ValidaCpfCnpj RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_nrcpfcgc AS CHARACTER ):
/*-----------------------------------------------------------------------------
  Objetivo:  Valida o Cpf ou Cnpj
     Notas:  
-----------------------------------------------------------------------------*/

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_stsnrcal AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE aux_nrcpfcgc AS CHARACTER   NO-UNDO.

    DEFINE BUFFER crabcop FOR crapcop.

    ASSIGN 
        aux_inpessoa = 0
        aux_nrcpfcgc = REPLACE(REPLACE(REPLACE(par_nrcpfcgc,
                                               ".",""),"/",""),"-","").

    /* Se houve erro na conversao para DEC, faz a critica */
    DEC(aux_nrcpfcgc) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN
         RETURN FALSE.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    RUN valida-cpf-cnpj IN h-b1wgen9999 
        ( INPUT aux_nrcpfcgc,
         OUTPUT aux_stsnrcal,
         OUTPUT aux_inpessoa ).

    DELETE OBJECT h-b1wgen9999.

    /* verifica se e conta administrativa */
    IF  aux_inpessoa > 1 THEN
        IF  CAN-FIND(FIRST crabcop
                     WHERE crabcop.cdcooper = par_cdcooper
                       AND crabcop.nrdocnpj = DEC(aux_nrcpfcgc)) THEN
            ASSIGN aux_inpessoa = 3.

    RETURN aux_stsnrcal.

END FUNCTION.

FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER):
/*-----------------------------------------------------------------------------
  Objetivo:  Valida o digito verificador
     Notas:  
-----------------------------------------------------------------------------*/

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_nrdconta AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE aux_vlresult AS LOGICAL     NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    ASSIGN 
        aux_nrdconta = par_nrdconta
        aux_vlresult = TRUE.


    RUN dig_fun IN h-b1wgen9999 
    ( INPUT STRING(par_cdcooper),
      INPUT par_cdagenci,
      INPUT par_nrdcaixa,
      INPUT-OUTPUT aux_nrdconta,
     OUTPUT TABLE tt-erro ).

    EMPTY TEMP-TABLE tt-erro.
    DELETE OBJECT h-b1wgen9999.

    /* verifica se o digito foi informado corretamente */
    IF  RETURN-VALUE <> "OK" THEN
        ASSIGN aux_vlresult = FALSE.

    FIND FIRST tt-erro NO-ERROR.

    IF  AVAILABLE tt-erro THEN
        ASSIGN aux_vlresult = FALSE.

    IF  aux_nrdconta <> par_nrdconta THEN
        ASSIGN aux_vlresult = FALSE.

   RETURN aux_vlresult.
        
END FUNCTION.

FUNCTION ValidaNome RETURNS LOGICAL PRIVATE
    ( INPUT  par_nomedttl AS CHARACTER,
      INPUT  par_inpessoa  AS INTE,
      OUTPUT par_cdcritic AS INTEGER,
      OUTPUT par_dscritic AS CHARACTER ) :
/*-----------------------------------------------------------------------------
  Objetivo:  Valida o nome - caracteres invalidos
     Notas:  
-----------------------------------------------------------------------------*/

    DEF VAR aux_listachr AS CHAR            NO-UNDO.
    DEF VAR aux_listanum AS CHAR            NO-UNDO.
    DEF VAR aux_nrextent AS HANDLE EXTENT   NO-UNDO.
    DEF VAR aux_nrextnum AS HANDLE EXTENT   NO-UNDO.

    /* Verificacoes para o nome */
    ASSIGN aux_listachr = "=,%,&,#,+,?,',','.',/,;,[,],!,@,$,(,),*,|,\,:,<,>," +
                          "~{,~},~," + '",'
           aux_listanum = "0,1,2,3,4,5,6,7,8,9".
    
    EXTENT(aux_nrextent) = NUM-ENTRIES(aux_listachr).

    DO aux_contador = 1 TO EXTENT(aux_nrextent):
        IF  INDEX(par_nomedttl,ENTRY(aux_contador,aux_listachr)) <> 0 THEN
            DO:
               ASSIGN par_dscritic = "O Caracter " + TRIM(ENTRY(aux_contador,
                                                                aux_listachr))
                                     + " nao e permitido! " + 
                                     "Caracteres invalidos: " + 
                                     "=%&#+?',./;][!@$()*|\:<>{}" + '"'.
               RETURN FALSE.
            END.
    END.

    IF  par_inpessoa = 1 THEN
        DO:
           
            EXTENT(aux_nrextnum) = NUM-ENTRIES(aux_listanum).
            
            DO aux_contador = 1 TO EXTENT(aux_nrextnum):
                IF  INDEX(par_nomedttl,ENTRY(aux_contador,aux_listanum)) <> 0 THEN
                    DO:
                        ASSIGN par_dscritic = "Nao sao permitidos numeros no nome" +
                                              " do titular".
                        RETURN FALSE.
                    END.
            END.
        END.

    RETURN TRUE.

END FUNCTION.


FUNCTION ValidaUF RETURNS LOGICAL PRIVATE
    ( INPUT par_cdunidfe AS CHARACTER ) :
/*-----------------------------------------------------------------------------
  Objetivo:  Valida a Unidade da Federacao
     Notas:  
-----------------------------------------------------------------------------*/

    RETURN CAN-DO("RS,SC,PR,SP,RJ,ES,MG,MS,MT,GO,DF,BA,PE,PA,PI,MA,RO,RR," +
                  "AC,AM,TO,AM,CE,SE,AL,RN,PB,AP,EX",par_cdunidfe).

END FUNCTION.




