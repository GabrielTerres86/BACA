CREATE OR REPLACE PACKAGE CECRED.GRVM0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: GRVM0001                        Antiga: b1wgen0171.p
  --  Autor   : Douglas Pagel
  --  Data    : Dezembro/2013                     Ultima Atualizacao: 17/01/2019
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package referente GRAVAMES
  --
  --  Alteracoes: 04/12/2013 - Conversao Progress para oracle (Douglas).
  --
  --              17/07/2014 - Liberacao da solicita_baixa_automatica apenas para CONCREDI (Guilherme/SUPERO)
  --
  --              29/08/2014 - Liberacao da solicita_baixa_automatica para CREDELESC (Guilherme/SUPERO)
  --
  --              05/12/2014 - Mudança no indice da GRV, inclusão do dschassi (Guilherme/SUPERO)
  --
  --              30/12/2014 - Liberação para as demais cooperativas(Guilherme/SUPERO)
  --
  --              05/03/2015 - Incluido UPPER e TRIM no dschassi (Guilherme/SUPERO)
  --
  --              31/03/2015 - Alterado para fazer Insert/Update na GRV antes da
  --                           geracao do arquivo. Geracao do arquivo faz "commit"
  --                           internamente (Guilherme/SUPERO)
  --              02/04/2015 - (Chamado 271753) - Não enviar baixas de bens ao Gravames quando 
  --                           o contrato está em prejuízo (Tiago Castro - RKAM).
  --
  --              10/05/2016 - Ajuste decorrente a conversao da tela GRAVAM
  --                           (Andrei - RKAM).
  --  
  --              11/10/2016 - M172 - Ajuste no formato do telefone para novo digito 9. 
  --                           (Ricardo Linhares) 
  -- 
  --              17/05/2017 - SD660300 - Ajuste nos parâmetros dos logs referente
  --						   ao GRAVAM. (Andrey Formigari - Mouts)
  --
  --              24/05/2017 - pc_gravames_baixa_manual - Ajuste mensagens: neste rotina são todas consideradas tpocorrencia = 4,
  --                         - Substituição do termo "ERRO" por "ALERTA",
  --                         - Padronização das mensagens para a tabela tbgen_prglog,
  --                         - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
  --                           (Ana - Envolti) - SD: 660319
  --
  --              29/05/2017 - pc_gravames_baixa_manual - Alteração para não apresentar os parâmetros nas mensagens exibidas em tela.
  --                         - Apresentar apenas nas exceptions (e na gravação da tabela TBGEN_PRGLOG)
  --                           (Ana - Envolti) - SD: 660319
  --
  --              29/05/2017 - Alteração das demais rotinas da pck:
  --                         - Ajuste das mensagens: neste caso são todas consideradas tpocorrencia = 4,
  --                         - Substituição do termo "ERRO" por "ALERTA",
  --                         - Padronização das mensagens para a tabela tbgen_prglog,
  --                         - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
  --                         - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
  --                           (Ana - Envolti) - SD: 660356 e 660394
  --              23/02/2018 - Alterado a rotina pc_gravames_geracao_arquivo:  Foi alterado cursor cr_crapbpr, 
  --                           incluido uma validação do inliquid = 0.
  --						   Alterado rotina pc_gravames_baixa_manual: ao atualizar a crapbpr setar flginclu = 0
  --					       Alterado rotina pc_gravames_processa_retorno: ao atualizar a crapbpr setar flginclu = 0
  --
  --              14/03/2018 - Alteracao para enviar a placa do veiculo sempre em maiusculo
  --                           Alcemir Jr (Mouts) - Chamado 858848
  --
  --              14/03/2018 - Correcao no cursor cr_crapbpr, que estava considerando o parametro com ele 
  --                           mesmo ao inves de comparar com o campo da tabela
  --                           Everton Souza (Mouts) - Chamado 859015
  --
  --              24/04/2018 - Incluído rotina PC_REGISTRAR_GRAVAMES, convertido com progress b1wgen0171.p
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Registro com informações de COoperativa e Associado para dados de alienação
  TYPE typ_reg_dados IS RECORD(/* Cooperativa */
                               nmrescop crapcop.nmrescop%TYPE  -- Nome Resumido Coop
                              ,nrdocnpj crapcop.nrdocnpj%TYPE  -- Numero CNPJ Coop
                              ,cdloggrv crapcop.cdloggrv%TYPE  -- Codigo Login Gravame
                              ,cdfingrv crapcop.cdfingrv%TYPE  -- Codigo financeiro cliente
                              ,cdsubgrv crapcop.cdsubgrv%TYPE  -- SubCodigo financeiro cliente
                              /* Emitente COoperado */
                              ,nrcpfemi crapass.nrcpfcgc%TYPE  -- CPF do Emitente
                              ,nmprimtl crapass.nmprimtl%TYPE  -- Nome emitente
                              ,cdcidcli crapmun.cdcidade%TYPE  -- Municipio do Cliente
                              ,nrdddass VARCHAR2(10)           -- DDD do Telefone do Cliente
                              ,nrtelass VARCHAR2(10)           -- Telefone do Cliente
                              ,dsendere crapenc.dsendere%TYPE  -- Endereço Cliente
                              ,nrendere crapenc.nrendere%TYPE  -- Numero Cliente
                              ,nmbairro crapenc.nmbairro%TYPE  -- Bairro Cliente
                              ,cdufende crapenc.cdufende%TYPE  -- UF Cliente
                              ,nrcepend crapenc.nrcepend%TYPE  -- CETP Cliente
                              /* Credor Cooperativa */
                              ,nrdddenc VARCHAR2(10)           -- DDD do Telefone do Credor
                              ,nrtelenc VARCHAR2(10)           -- Telefone do Credor
                              ,dsendcre crapenc.dsendere%TYPE  -- Endereço Credor
                              ,nrendcre crapenc.nrendere%TYPE  -- Numero Credor
                              ,nmbaicre crapenc.nmbairro%TYPE  -- Bairro Credor
                              ,cdufecre crapenc.cdufende%TYPE  -- UF Credor
                              ,nrcepcre crapenc.nrcepend%TYPE  -- CETP Credor
                              ,cdcidcre crapmun.cdcidade%TYPE  -- Municipio do Credor
                              /* Operacao de Credito */
                              ,permulta NUMBER(8,2)            -- Percentual de Multa
                              ,dtlibera crawepr.dtlibera%TYPE  -- Data liberação
                              ,dtmvtolt crawepr.dtmvtolt%TYPE  -- Data digitação
                              ,qtpreemp crawepr.qtpreemp%TYPE  -- Quantidade parcelas
                              ,txmensal crawepr.txmensal%TYPE  -- Taxa mensal
                              ,vlemprst crawepr.vlemprst%TYPE  -- Valor Empréstimo
                              ,dtdpagto crawepr.dtmvtolt%TYPE  -- Data da primeira parcela
                              ,cdfinemp crawepr.cdfinemp%TYPE  -- Finalidade da Operação
                              ,dtvencto crawepr.dtmvtolt%TYPE  -- Data da ultima parcela
                              ,tpemprst crawepr.tpemprst%TYPE  -- Tipo Emprestimo
                              ,vtctrliq gene0002.typ_split);   -- Lista de contratos liquidados pela proposta);
                              
  
  -- Definicação de tipo e tabela para o arquivo do GRAVAMES
  -- Antigo tt-dados-arquivos
  TYPE typ_reg_dados_arquivo IS
    RECORD (rowidbpr ROWID
           ,tparquiv VARCHAR2(12)
           ,cdoperac NUMBER
           ,cdcooper INTEGER
           ,nrdconta crapbpr.nrdconta%TYPE
           ,tpctrpro crapbpr.tpctrpro%TYPE
           ,nrctrpro crapbpr.nrctrpro%TYPE
           ,idseqbem crapbpr.idseqbem%TYPE

           ,cdfingrv crapcop.cdfingrv%TYPE
           ,cdsubgrv crapcop.cdsubgrv%TYPE
           ,cdloggrv crapcop.cdloggrv%TYPE
           ,nrseqlot INTEGER                /* Nr sequen Lote */
           ,nrseqreg INTEGER                /* Nr sequen Registro */
           ,dtmvtolt DATE                   /* Data atual Sistema  */
           ,hrmvtolt INTEGER                /* Hora atual */
           ,nmrescop crapcop.nmrescop%TYPE  /* Nome Cooperativa */

           ,dschassi crapbpr.dschassi%TYPE  /* Chassi do veículo        */
           ,tpchassi crapbpr.tpchassi%TYPE  /* Informaçao de remarcaçao */
           ,uflicenc crapbpr.uflicenc%TYPE  /* UF de licenciamento      */
           ,ufdplaca crapbpr.ufdplaca%TYPE  /* UF da placa              */
           ,nrdplaca crapbpr.nrdplaca%TYPE  /* Placa do veículo         */
           ,nrrenava crapbpr.nrrenava%TYPE  /* RENAVAM do veículo       */
           ,nranobem crapbpr.nranobem%TYPE  /* Ano de fabricaçao        */
           ,nrmodbem crapbpr.nrmodbem%TYPE  /* Ano do modelo            */
           ,nrctremp crawepr.nrctremp%TYPE  /* Número da operaçao       */
           ,dtoperad crawepr.dtmvtolt%TYPE  /* Data da Operacao         */
           ,nrcpfbem crapbpr.nrcpfbem%TYPE  /* CPF/CNPJ do cliente      */
           ,nmprimtl crapass.nmprimtl%TYPE  /* Nome do cliente          */
           ,qtpreemp crawepr.qtpreemp%TYPE  /* Quantidade de meses      */

           ,dscatbem crapbpr.dscatbem%TYPE  /* Categoria do veículo     */
           ,dstipbem crapbpr.dstipbem%TYPE  /* Tipo bem                 */
           ,dsmarbem crapbpr.dsmarbem%TYPE  /* UF de licenciamento      */
           ,dsbemfin crapbpr.dsbemfin%TYPE  /* Bem financiado           */
                                            
           ,vlemprst crawepr.vlemprst%TYPE  /*  Valor principal da oper.     */
           ,vlpreemp crawepr.vlpreemp%TYPE  /*  Valor da parcela             */
           ,dtdpagto crawepr.dtdpagto%TYPE  /*  Data de vencto prim. parc.   */
           ,dtvencto DATE                   /*  Data de vencto ult. parc.    */
           ,nmcidade crapage.nmcidade%TYPE  /*  Cidade da liberaçao da oper. */
           ,cdufdcop crapage.cdufdcop%TYPE  /*  UF da liberaçao da oper      */

           ,dsendcop crapcop.dsendcop%TYPE  /* Nome do logradouro         */
           ,nrendcop crapcop.nrendcop%TYPE  /* Número do imóvel           */
           ,dscomple crapcop.dscomple%TYPE  /* Complemento do imóvel      */
           ,nmbaienc crapcop.nmbairro%TYPE  /* Bairro do imóvel           */
           ,cdcidenc crapmun.cdcidade%TYPE  /* Código do município        */
           ,cdufdenc crapcop.cdufdcop%TYPE  /* UF do imóvel               */
           ,nrcepenc crapcop.nrcepend%TYPE  /* CEP do imóvel              */
           ,nrdddenc VARCHAR2(10)           /* DDD do telefone            */
           ,nrtelenc crapcop.nrtelvoz%TYPE  /* DDD Número do telefone     */

           ,dsendere crapenc.dsendere%TYPE  /* Nome do logradouro    */
           ,nrendere crapenc.nrendere%TYPE  /* Número do imóvel      */
           ,complend crapenc.complend%TYPE  /* Complemento do imóvel */
           ,nmbairro crapenc.nmbairro%TYPE  /* Bairro do imóvel      */
           ,cdcidade crapmun.cdcidade%TYPE  /* Código do município   */
           ,cdufende crapenc.cdufende%TYPE  /* UF do imóvel          */
           ,nrcepend crapenc.nrcepend%TYPE  /* CEP do imóvel         */
           ,nrdddass VARCHAR2(10)           /* DDD do telefone       */
           ,nrtelass VARCHAR2(10)           /* Número do telefone    */

           ,inpessoa crapass.inpessoa%TYPE
           ,nrcpfcgc crapass.nrcpfcgc%TYPE);
  TYPE typ_tab_dados_arquivo IS
    TABLE OF typ_reg_dados_arquivo
      INDEX BY VARCHAR2(20); -- Chave composta por Cooper(5)+TpArquivo(1)+Sequencia(14)

  -- Função para validar se categoria do bem enviado é alienável
  FUNCTION fn_valida_categoria_alienavel(pr_dscatbem IN crapbpr.dscatbem%TYPE) RETURN VARCHAR2;
  
  -- Tem como objetivo retornar S caso esteja habilitado o envio de Gravames Online 
  FUNCTION fn_tem_gravame_online(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN VARCHAR2;

  /* Overload para chamada do Ayllos Web */
  PROCEDURE pc_tem_gravame_online_web(pr_xmllog   IN  VARCHAR2                    -- XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER                 -- Código da crítica
                                     ,pr_dscritic OUT VARCHAR2                    -- Descrição da crítica
                                     ,pr_retxml   IN  OUT NOCOPY XMLType          -- Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2                    -- Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);                  -- Erros do processo

  /* Overload para chamada do Progress */
  PROCEDURE pc_tem_gravame_online_progress(pr_cdcooper IN crapcop.cdcooper%TYPE -- Cooperativa desejada
                                          ,pr_flonline OUT VARCHAR2);

  -- Procedimento para montagem das informações de configuração da Conexão Gravames B3
  PROCEDURE pc_config_gravame_b3(pr_cdcooper IN crapbpr.cdcooper%TYPE -- Cod. Cooperativa
                                /* Saida */
                                ,pr_xmldesal OUT VARCHAR2 -- XML da configuração de alienação
                                ,pr_dscritic OUT VARCHAR2 -- Descrição de critica encontrada
                                );
  
  /* Retorno dos horário de envio do Lote Online */
  PROCEDURE pc_horarios_lote_online(pr_cdcooper IN crapcop.cdcooper%TYPE -- Cooperativa desejada
                                   ,pr_hrenvi01 OUT varchar2             -- Horário 1º Envio do dia
                                   ,pr_hrenvi02 OUT varchar2             -- Horário 2º Envio do dia
                                   ,pr_hrenvi03 OUT varchar2             -- Horário 3º Envio do dia
                                   ,pr_dscritic OUT VARCHAR2             -- Descrição da crítica
                                   );
  
  -- Função simples comparativa de codigos de retorno de gravames para definir se houve sucesso ou não
  FUNCTION fn_flag_sucesso_gravame(pr_nrseqlot crapgrv.nrseqlot%TYPE  -- Lote
                                  ,pr_dtretgrv crapgrv.dtretgrv%TYPE  -- Retorno GRavames
                                  ,pr_cdretlot crapgrv.cdretlot%TYPE  -- Retorno Lote
                                  ,pr_cdretgrv crapgrv.cdretgrv%TYPE  -- Retorno Gravame
                                  ,pr_cdretctr crapgrv.cdretctr%TYPE  -- Retorno Contrato
                                  ,pr_dscritic crapgrv.dscritic%TYPE) -- Critica generica comunicacao
                                  RETURN VARCHAR2;    
  
  -- Valida se é alienação fiduciaria
  PROCEDURE pc_valida_alienacao_fiduciaria (pr_cdcooper   IN crapcop.cdcooper%type  -- Código da cooperativa
                                           ,pr_nrdconta   IN crapass.nrdconta%type  -- Numero da conta do associado
                                           ,pr_nrctrpro   IN PLS_INTEGER            -- Numero do contrato
                                           ,pr_flgcompl   IN VARCHAR2 DEFAULT 'N'   -- Flag S/N de busca completa das informações do Associado
                                           ,pr_des_reto  OUT VARCHAR2               -- Retorno Ok ou NOK do procedimento
                                           ,pr_vet_dados OUT typ_reg_dados          -- Registro com dados necessários para conexão B3
                                           ,pr_dscritic  OUT VARCHAR2               -- Retorno da descricao da critica do erro
                                           ) ;
  
  -- Valida se é alienação fiduciaria (chamada via Progress
  PROCEDURE pc_valida_alienacao_fiduc_prog(pr_cdcooper   IN crapcop.cdcooper%type  -- Código da cooperativa
                                          ,pr_nrdconta   IN crapass.nrdconta%type  -- Numero da conta do associado
                                          ,pr_nrctrpro   IN PLS_INTEGER            -- Numero do contrato
                                          ,pr_des_reto  OUT VARCHAR2               -- Retorno Ok ou NOK do procedimento
                                          ,pr_cdcritic  OUT NUMBER                 -- Retorno de codigo de critica do erro
                                          ,pr_dscritic  OUT VARCHAR2               -- Retorno da descricao da critica do erro
                                          );
                                           
  -- Validação se todos bens ou contrato está alienado
  PROCEDURE pc_valida_bens_alienados(pr_cdcooper IN crapcop.cdcooper%type   -- Código da cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%type   -- Numero da conta do associado
                                    ,pr_nrctrpro IN crapepr.nrctremp%TYPE   -- Numero do contrato
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  -- Codigo Critica de saida
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE  -- Descricao critica de saida
                                    );
  
  -- Validar situação Gravames                                 
  PROCEDURE  pc_valida_situacao_gravames ( pr_cdcooper IN crapbpr.cdcooper%TYPE       -- Cód. cooperativa
                                        ,pr_nrdconta IN crapbpr.nrdconta%TYPE       -- Nr. da conta
                                        ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE       -- Nr. contrato
                                          ,pr_idseqbem IN crapbpr.idseqbem%TYPE       -- Sequencial do bem
                                          ,pr_cdsitgrv OUT INTEGER                    -- Retorna situação do gravames 
                                          ,pr_dscrigrv OUT VARCHAR2                   -- Retorna critica de processamento do gravames
                                          ,pr_cdcritic OUT INTEGER                    -- Codigo de critica de sistema
                                          ,pr_dscritic OUT VARCHAR2                   -- Descrição da critica de sistema
                                          );                                                

  -- Gravação das informações de comunicação e atualização da situação do Gravames
  procedure pc_grava_aciona_gravame(pr_cdcooper IN crapbpr.cdcooper%type -- Cód. cooperativa
                                   ,pr_nrdconta IN crapbpr.nrdconta%type -- Nr. da conta
                                   ,pr_tpctrato IN crapbpr.tpctrpro%type -- Tp. contrato
                                   ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Nr. contrato
                                   ,pr_idseqbem IN crapbpr.idseqbem%type -- Sequencial do bem
                                   ,pr_cdoperac IN crapgrv.cdoperac%type -- Tipo da Operação
                                     
                                   ,pr_dschassi IN crapbpr.dschassi%type -- Chassi do veículo
                                   ,pr_dscatbem IN crapbpr.dscatbem%type -- Categoria do bem financiado (ex. automovel, casa, maquina, etc).
                                   ,pr_dstipbem IN crapbpr.dstipbem%type -- Descricao do tipo do bem
                                   ,pr_dsmarbem IN crapbpr.dsmarbem%type -- Marca do Bem (Somente para Auto, Moto e Caminhao)
                                   ,pr_dsbemfin IN crapbpr.dsbemfin%type -- Descricao do bem a ser financiado.
                                   ,pr_nrcpfbem IN crapbpr.nrcpfbem%type -- CPF/CNPJ do Proprietario do Bem
                                   ,pr_tpchassi IN crapbpr.tpchassi%type -- Tipo de chassi do veiculo (1-Remarcado, 2-Normal)
                                   ,pr_uflicenc IN crapbpr.uflicenc%type -- UF (ESTADO) do licenciamento do veiculo.
                                   ,pr_nranobem IN crapbpr.nranobem%type -- Ano do bem financiado.
                                   ,pr_nrmodbem IN crapbpr.nrmodbem%type -- Modelo do bem financiado.
                                   ,pr_ufdplaca IN crapbpr.ufdplaca%type -- Unidade da Federacao (ESTADO) da placa do veiculo.
                                   ,pr_nrdplaca IN crapbpr.nrdplaca%type -- Numero da placa do bem financiado.
                                   ,pr_nrrenava IN crapbpr.nrrenava%type -- Numero do RENAVAN do veiculo.
                                     
                                   ,pr_dtenvgrv IN crapgrv.dtenvgrv%type  -- Data envio GRAVAME
                                   ,pr_dtretgrv IN crapgrv.dtretgrv%type  -- Data retorno GRAVAME      
                                   ,pr_cdretgrv IN crapgrv.cdretgrv%TYPE  -- Codigo retorno Gravame
                                   ,pr_cdretctr IN crapgrv.cdretctr%TYPE  -- Codigo retorno Contrato
                                   ,pr_nrgravam IN crapbpr.nrgravam%TYPE  -- Numero gravame gerado                                   
                                   ,pr_idregist IN crapgrv.idregist%TYPE  -- Numero do GRAVAME/Registro gerado
                                   ,pr_dtregist IN crapgrv.dtregist%TYPE  -- Data do GRAVAME/Registro gerado
                                   ,pr_dserrcom IN crapgrv.dscritic%TYPE  -- Descricao de critica encontrada durante processo de comunicacao.
                                   ,pr_flsituac IN varchar2               -- Indica se deve atualizar situação (S ou N)
                                   ,pr_dsretreq IN CLOB DEFAULT NULL -- CLOB que contem o retorno da requisição no SOA
                                   ,pr_cdoperad IN VARCHAR2 DEFAULT NULL  -- Usuário para registro de LOG
                                   ,pr_idorigem IN NUMBER   DEFAULT NULL  -- Origem para o log
                                   
                                   ,pr_dscritic OUT VARCHAR2);           -- Critica encontrada durante execução desta rotina
  
  -- Gravação de acionamento partindo do AyllosWeb / SOA
  PROCEDURE pc_grava_aciona_gravame_web(pr_nrdconta IN crapbpr.nrdconta%type -- Nr. da conta
                                       ,pr_tpctrato IN crapbpr.tpctrpro%type -- Tp. contrato
                                       ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Nr. contrato
                                       ,pr_idseqbem IN crapbpr.idseqbem%type -- Sequencial do bem
                                       ,pr_cdoperac IN crapgrv.cdoperac%type -- Tipo da Operação
                                         
                                       ,pr_dschassi IN crapbpr.dschassi%type -- Chassi do veículo
                                       ,pr_dscatbem IN crapbpr.dscatbem%type -- Categoria do bem financiado (ex. automovel, casa, maquina, etc).
                                       ,pr_dstipbem IN crapbpr.dstipbem%type -- Descricao do tipo do bem
                                       ,pr_dsmarbem IN crapbpr.dsmarbem%type -- Marca do Bem (Somente para Auto, Moto e Caminhao)
                                       ,pr_dsbemfin IN crapbpr.dsbemfin%type -- Descricao do bem a ser financiado.
                                       ,pr_nrcpfbem IN crapbpr.nrcpfbem%type -- CPF/CNPJ do Proprietario do Bem
                                       ,pr_tpchassi IN crapbpr.tpchassi%type -- Tipo de chassi do veiculo (1-Remarcado, 2-Normal)
                                       ,pr_uflicenc IN crapbpr.uflicenc%type -- UF (ESTADO) do licenciamento do veiculo.
                                       ,pr_nranobem IN crapbpr.nranobem%type -- Ano do bem financiado.
                                       ,pr_nrmodbem IN VARCHAR2              -- Modelo do bem financiado.
                                       ,pr_ufdplaca IN crapbpr.ufdplaca%type -- Unidade da Federacao (ESTADO) da placa do veiculo.
                                       ,pr_nrdplaca IN crapbpr.nrdplaca%type -- Numero da placa do bem financiado.
                                       ,pr_nrrenava IN crapbpr.nrrenava%type -- Numero do RENAVAN do veiculo.
                                         
                                       ,pr_dtenvgrv IN VARCHAR2               -- Data envio GRAVAME
                                       ,pr_dtretgrv IN VARCHAR2               -- Data retorno GRAVAME      
                                       ,pr_chttpsoa IN VARCHAR2               -- HTTP Code da request
                                       ,pr_dsmsgsoa IN VARCHAR2               -- Tah MSG SOA
                                       ,pr_nrcodsoa IN VARCHAR2               -- Tag Code SOA
                                       ,pr_cdtypsoa IN VARCHAR2               -- Tag Type SOA
                                       ,pr_cdlegsoa IN VARCHAR2               -- Tag LegacyCode SOA

                                       ,pr_nrgravam IN crapbpr.nrgravam%TYPE  -- Numero gravame gerado                                   
                                       ,pr_idregist IN crapgrv.idregist%TYPE  -- Numero do GRAVAME/Registro gerado
                                       ,pr_dtregist IN VARCHAR2               -- Data do GRAVAME/Registro gerado
                                       ,pr_flsituac IN varchar2               -- Indica se deve atualizar situação (S ou N)
  
                                       -- Mensageria
                                       ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK

  /* Geração dos arquivos do GRAVAMES */
  PROCEDURE pc_gravames_geracao_arquivo(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa conectada
                                       ,pr_cdcoptel  IN crapcop.cdcooper%TYPE -- Opção selecionada na tela
                                       ,pr_tparquiv  IN VARCHAR2              -- Tipo do arquivo selecionado na tela
                                       ,pr_dtmvtolt  IN DATE                  -- Data atual
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE -- Cod Critica de erro
                                       ,pr_dscritic OUT VARCHAR2);            -- Des Critica de erro 
                                       
 /* Procesamento retorno Arquivos Gravames */ 
  PROCEDURE pc_gravames_processa_retorno(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa conectada
                                        ,pr_cdcoptel  IN crapcop.cdcooper%TYPE -- Opção selecionada na tela
                                        ,pr_cdoperad  IN crapope.cdoperad%TYPE -- Código do operador
                                        ,pr_tparquiv  IN VARCHAR2              -- Tipo do arquivo selecionado na tela
                                        ,pr_dtmvtolt  IN DATE                  -- Data atual
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE -- Cod Critica de erro
                                        ,pr_dscritic OUT VARCHAR2) ;           -- Des Critica de erro
  
  /* Geração de arquivo XML com as informações pendentes de envio */
  PROCEDURE pc_gravames_geracao_xml(pr_cdcooper IN crapcop.cdcooper%TYPE  -- Cooperativa conectada
                                   ,pr_tparquiv IN VARCHAR2               -- Tipo do arquivo (Todas, Inclusao, Baixa ou Cancelamento)
                                   ,pr_nrregist IN NUMBER                 -- Quantidade de registros
                                   ,pr_nriniseq IN NUMBER                 -- Registro inicial
                                   ,pr_retxml   OUT XMLType               -- Arquivo de retorno do XML
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE -- Cod Critica de erro
                                   ,pr_dscritic OUT VARCHAR2);            -- Des Critica de erro 
 
  -- Atualiza os dados conforme o cdorigem para geração de arquivos cyber
  PROCEDURE pc_solicita_baixa_automatica(pr_cdcooper IN crapbpr.cdcooper%type -- Código da Cooperativa
                                     ,pr_nrdconta IN crapbpr.nrdconta%type -- Numero da conta do associado
                                     ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Numero do contrato
                                     ,pr_dtmvtolt IN DATE                  -- Data de movimento para baixa
                                     ,pr_des_reto OUT VARCHAR2             -- Retorno OK ou NOK do procedimento
                                     ,pr_tab_erro OUT gene0001.typ_tab_erro-- Retorno de erros em PlTable
                                     ,pr_cdcritic OUT PLS_INTEGER          -- Código de erro gerado em excecao
                                     ,pr_dscritic OUT VARCHAR2);         -- Descricao de erro gerado em excecao

  /* Procedure para desfazer a solicitação de baixa automatica */
  PROCEDURE pc_desfazer_baixa_automatica(pr_cdcooper IN crapbpr.cdcooper%TYPE       -- Cód. cooperativa
                                        ,pr_nrdconta IN crapbpr.nrdconta%TYPE       -- Nr. da conta
                                        ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE       -- Nr. contrato
                                        ,pr_des_reto OUT VARCHAR2                   -- Descrição de retorno OK/NOK
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro);    -- Retorno de erros em PlTable
  /* Alteração Gravames */
  PROCEDURE pc_alterar_gravame(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                              ,pr_cddopcao IN VARCHAR2              --Opção
                              ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato                               
                              ,pr_idseqbem IN crapbpr.idseqbem%TYPE --Identificador do bem
                              ,pr_dscatbem IN crapbpr.dscatbem%TYPE --Categoria do bem
                              ,pr_dschassi IN crapbpr.dschassi%TYPE --Chassi do bem
                              ,pr_ufdplaca IN crapbpr.ufdplaca%TYPE --UF da placa
                              ,pr_nrdplaca IN crapbpr.nrdplaca%TYPE --Número da placa
                              ,pr_nrrenava IN crapbpr.nrrenava%TYPE --RENAVAN
                              ,pr_nranobem IN crapbpr.nranobem%TYPE --Ano do bem
                              ,pr_nrmodbem IN crapbpr.nrmodbem%TYPE --Modelo do bem
                              ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE --Tipo do contrato
                              ,pr_cdsitgrv IN crapbpr.cdsitgrv%TYPE --Situação do Gravame
                              ,pr_dsaltsit IN VARCHAR2              --Descrição do motivo da alteração da situação do Gravame
                              ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                              ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
                            
  /* Solicitar bloqueio / liberação judicial via tela */                         
  PROCEDURE pc_gravames_blqjud(pr_nrdconta in crapass.nrdconta%type, --Número da conta
                               pr_cddopcao in varchar2,              --Opção
                               pr_nrctrpro in crawepr.nrctremp%type, --Número do contrato 
                               pr_tpctrpro in crapbpr.tpctrpro%type, --Tipo do contrato 
                               pr_idseqbem in crapbpr.idseqbem%type, --Identificador do bem
                               pr_dschassi in crapbpr.dschassi%type, --Chassi do bem
                               pr_ufdplaca in crapbpr.ufdplaca%type, --UF da placa
                               pr_nrdplaca in crapbpr.nrdplaca%type, --Número da placa
                               pr_nrrenava in crapbpr.nrrenava%type, --RENAVAN
                               pr_dsjustif in crapbpr.dsjusjud%type, -- Justificativa
                               pr_flblqjud in crapbpr.flblqjud%type, -- BLoqueio judicial
                               pr_xmllog   in varchar2,              --XML com informações de LOG
                               pr_cdcritic out pls_integer,          --Código da crítica
                               pr_dscritic out varchar2,             --Descrição da crítica
                               pr_retxml   in out nocopy xmltype,    --Arquivo de retorno do XML
                               pr_nmdcampo out varchar2,             --Nome do Campo
                               pr_des_erro out varchar2);            --Saida OK/NOK
  
  /* Solicitar Baixa via tela */
  PROCEDURE pc_gravames_baixar(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                    ,pr_cddopcao IN VARCHAR2              --Opção
                                    ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                    ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE --Tipo do contrato
                                    ,pr_idseqbem IN crapbpr.idseqbem%TYPE --Identificador do bem
                              ,pr_tpdbaixa IN crapbpr.tpdbaixa%TYPE -- TIpo da Baixa
                                    ,pr_nrgravam IN crapbpr.nrgravam%TYPE --Número do gravam
                              ,pr_cdopeapr in VARCHAR2              --Operador da aprovação
                                    ,pr_dsjstbxa IN crapbpr.dsjstbxa%TYPE -- Justificativa da baixa
                                    ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
  
  /* Solicitar Cancelamento via tela */
  PROCEDURE pc_gravames_cancelar(pr_nrdconta in crapass.nrdconta%TYPE --Número da conta
                                ,pr_cddopcao in VARCHAR2              --Opção
                                ,pr_nrctrpro in crawepr.nrctremp%TYPE --Número do contrato 
                                ,pr_idseqbem in crapbpr.idseqbem%TYPE --Identificador do bem
                                ,pr_tpctrpro in crapbpr.tpctrpro%TYPE --Tipo do contrato
                                ,pr_tpcancel in crapbpr.tpcancel%TYPE --Tipo de cancelamento
                                ,pr_cdopeapr in VARCHAR2              --Operador da aprovação
                                ,pr_dsjuscnc in crapbpr.dsjuscnc%TYPE -- Justificativa
                                ,pr_xmllog   in VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic out PLS_INTEGER          --Código da crítica
                                ,pr_dscritic out VARCHAR2             --Descrição da crítica
                                ,pr_retxml   in out nocopy xmltype    --Arquivo de retorno do XML
                                ,pr_nmdcampo out VARCHAR2             --Nome do Campo
                                ,pr_des_erro out VARCHAR2);           --Saida OK/NOK

  /* Validar a inclusão manual */
  PROCEDURE pc_gravames_valida_inclusao(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                       ,pr_cddopcao IN VARCHAR2              --Opção
                                       ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                       ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE --Tipo do contrato
                                       ,pr_idseqbem IN crapbpr.idseqbem%TYPE --Identificador do bem
                                       ,pr_tpinclus IN crapbpr.tpinclus%TYPE --Tipo da Inclusão 
                                       ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK

  /* Solicitar inclusão de Gravames */
  PROCEDURE pc_gravames_inclusao(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                       ,pr_cddopcao IN VARCHAR2              --Opção
                                       ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                       ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE --Tipo do contrato
                                       ,pr_idseqbem IN crapbpr.idseqbem%TYPE --Identificador do bem
                                       ,pr_nrgravam IN crapbpr.nrgravam%TYPE --Número do gravam
                                       ,pr_dtmvttel IN VARCHAR2              --Data do registro
                                ,pr_dsjustif IN crapbpr.dsjstbxa%TYPE --Justificativa da inclusão
                                ,pr_tpinclus IN crapbpr.tpinclus%TYPE --Tipo da Inclusão 
                                ,pr_cdopeapr IN crapope.cdoperad%TYPE --Operador da aprovação
                                       ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
                                       
  -- Preparar XML para alienação de bem novo e desalienação de bem substituído
  procedure pc_prepara_alienacao_aditiv(pr_cdcooper IN crapcop.cdcooper%TYPE -- Cooperativa
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE -- Conta
                                       ,pr_nrctremp IN crawepr.nrctremp%TYPE -- Contrato
                                       ,pr_cdoperad IN crapbpr.cdoperad%TYPE -- Operador
                                       ,pr_idseqbem IN crapbpr.idseqbem%TYPE -- Bem a substituir
                                       ,pr_tpchassi IN crapbpr.tpchassi%TYPE -- Tipo Chassi
                                       ,pr_dschassi IN crapbpr.dschassi%TYPE -- Chassi
                                       ,pr_ufdplaca IN crapbpr.ufdplaca%TYPE -- UF Placa
                                       ,pr_nrdplaca IN crapbpr.nrdplaca%TYPE -- Placa
                                       ,pr_nrrenava IN crapbpr.nrrenava%TYPE -- Renavam 
                                       ,pr_uflicenc IN crapbpr.uflicenc%TYPE -- UF Licenciamento
                                       ,pr_nranobem IN crapbpr.nranobem%TYPE -- Ano fabricacao
                                       ,pr_nrmodbem IN crapbpr.nrmodbem%TYPE -- Ano Modelo
                                       ,pr_nrcpfbem IN crapbpr.nrcpfbem%TYPE -- CPF Interveniente
                                       ,pr_nmdavali IN crapavt.nmdavali%TYPE -- Nome Interveniente
                                       ,pr_dsxmlali OUT VARCHAR2             -- XML de saida para alienação/desalienação
                                       ,pr_dscritic OUT VARCHAR2);           -- Critica de saida
                                 
  -- Preparar XML para alienação de bens em Alienação e Desalienação (Refin)
  procedure pc_prepara_alienacao_atenda(pr_nrdconta IN crapass.nrdconta%TYPE -- Conta
                                       ,pr_nrctremp IN crawepr.nrctremp%TYPE -- Contrato
                                       -- Mensageria
                                       ,pr_xmllog   IN VARCHAR2              -- XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          -- Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             -- Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    -- Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             -- Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);           -- Saida OK/NOK
                                                             
  -- Alertar gravames sem efetivação por email                                                                                                       
  procedure pc_alerta_gravam_sem_efetiva;
                                                                                                                                                      
  -- Buscar Situação Gravames do Bem repassado
  PROCEDURE pc_situac_gravame_bem(pr_cdcooper in crapbpr.cdcooper%TYPE
                                 ,pr_nrdconta in crapbpr.nrdconta%TYPE
                                 ,pr_nrctrpro in crapbpr.nrctrpro%TYPE
                                 ,pr_idseqbem in crapbpr.idseqbem%TYPE
                                 ,pr_dssituac OUT VARCHAR2
                                 ,pr_dscritic OUT VARCHAR2);

  -- Efetar o registro do Gravames                                 
  PROCEDURE pc_registrar_gravames(pr_cdcooper IN crapcop.cdcooper%TYPE -- Numero da cooperativa
                                 ,pr_nrdconta IN crapcop.nrdconta%TYPE -- Numero da conta do associado
                                 ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Numero do contrato                               
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                 ,pr_dscritic OUT VARCHAR2);

  -- Efetuar o registro de Baixa de Refin 
  PROCEDURE pc_registrar_baixa_refin(pr_cdcooper IN crapcop.cdcooper%TYPE -- Numero da cooperativa
                                    ,pr_nrdconta IN crapcop.nrdconta%TYPE -- Numero da conta do associado
                                    ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Numero do contrato                               
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                    ,pr_dscritic OUT VARCHAR2);

  -- Efetuar o registro do Gravames somente CDC 
  PROCEDURE pc_busca_xml_gravame_CDC(pr_cdcooper IN crapcop.cdcooper%TYPE         -- Numero da cooperativa
                                    ,pr_nrdconta IN crapcop.nrdconta%TYPE         -- Numero da conta do associado
                                    ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE         -- Numero do contrato                               
                                    ,pr_nrcpfven IN tbepr_cdc_vendedor.nrcpf%TYPE -- CPF do Vendedor
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE         -- Codigo do Operador
                                    ,pr_dsxmlali OUT XmlType                      -- XML de saida para alienação/desalienação
                                    ,pr_dscritic OUT VARCHAR2);                   -- Descricao de saida
                                                                                                                                                      
END GRVM0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.GRVM0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: GRVM0001                        Antiga: b1wgen0171.p
  --  Autor   : Douglas Pagel
  --  Data    : Dezembro/2013                     Ultima Atualizacao: 17/01/2019
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package referente a GRAVAMES
  --
  --  Alteracoes: 04/12/2013 - Conversao Progress para oracle (Douglas).
  --
  --              08/04/2016 -  Ajuste na pc_gravames_geracao_arquivo para formatar
  --                            o número de telefone caso venha vazio, e também
  --                            foi tirado os caracteres especiais do nome da cidade
  --                            e do nome do bairro conforme solicitado no chamado
  --                            430323. (Kelvin) 
  --
  --              10/05/2016 - Ajuste decorrente a conversao da tela GRAVAM
  --                           (Andrei - RKAM).
  --
  --              14/07/2016 - AjusteS realizados:
  --							            - Criado função para validar os caracteres do chassi e reliazado a chamada
  --						                na rotina de alteração dos gravames;
  --							            - Realizado validação da data de referencia e tratado o lote passado para consulta
  --							              na rotina de consulta dos gravames
  --						               (Adnrei - RKAM).
  --
  --              28/07/2016 - Ajustes realizados:
  --						               -> Na rotina de importação dos arquivos de retorno para tratar corretamente
  --                              as informações coletadas do arquivo;
  --						               -> Ajuste para retirar validação que verifica se contrato
  --                              esta em prejuízo;
  --                            (Adriano - SD  495514)                          
  --
  --              05/08/2016 - Ajuste para efetuar commit/rollback
  --						              (Adriano)
  --
  --              22/09/2016 - Ajuste para utilizar upper ao manipular a informação do chassi
  --                           pois em alguns casos ele foi gravado em minusculo e outros em maisculo
  --                           (Adriano - SD 527336)
  --
  --              11/10/2016 - M172 - Ajuste no formato do telefone para novo digito 9. 
  --                           (Ricardo Linhares)  
  --
  --              24/05/2017 - pc_gravames_baixa_manual - Ajuste mensagens: neste rotina são todas consideradas tpocorrencia = 4,
  --                         - Substituição do termo "ERRO" por "ALERTA",
  --                         - Padronização das mensagens para a tabela tbgen_prglog,
  --                         - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
  --                           (Ana - Envolti) - SD: 660319
  --
  --              29/05/2017 - pc_gravames_baixa_manual - Alteração para não apresentar os parâmetros nas mensagens exibidas em tela.
  --                         - Apresentar apenas nas exceptions (e na gravação da tabela TBGEN_PRGLOG)
  --                           (Ana - Envolti) - SD: 660319
  --
  --              29/05/2017 - Alteração das demais rotinas da pck:
  --                         - Ajuste das mensagens: neste caso são todas consideradas tpocorrencia = 4,
  --                         - Substituição do termo "ERRO" por "ALERTA",
  --                         - Padronização das mensagens para a tabela tbgen_prglog,
  --                         - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
  --                         - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
  --                           (Ana - Envolti) - SD: 660356 e 660394
  --
  --             18/12/2017 - Inclusão da procedure pc_consulta_situacao_cdc, Prj. 402 (Jean Michel)
  --
  --             22/02/2018 - Inclusão de Logs nas procedures pc_gravames_baixa_manual, pc_gravames_cancelar, pc_gravames_inclusao_manual
  --
  --             17/01/2019 - Tratamento de dados do endereco do cooperado com valores nulos
  --                          (Andre - MoutS) - PRB0040537
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Constantes
  vr_urialien CONSTANT VARCHAR2(100) := gene0001.fn_param_sistema('CRED',0,'URI_ALIENA_GRAVAME');
  vr_tpaliena CONSTANT VARCHAR2(100) := gene0001.fn_param_sistema('CRED',0,'GRAVAME_TIP_OPERA_ALIENA');
  vr_uricancl CONSTANT VARCHAR2(100) := gene0001.fn_param_sistema('CRED',0,'URI_CANCELA_GRAVAME');
  vr_tpcancel CONSTANT VARCHAR2(100) := gene0001.fn_param_sistema('CRED',0,'GRAVAME_TIP_OPERA_CANCEL');
  vr_uribaixa CONSTANT VARCHAR2(100) := gene0001.fn_param_sistema('CRED',0,'URI_BAIXA_GRAVAME');
  vr_tipbaixa CONSTANT VARCHAR2(100) := gene0001.fn_param_sistema('CRED',0,'GRAVAME_TIP_OPERA_BAIXA');
  vr_uriconsl CONSTANT VARCHAR2(100) := gene0001.fn_param_sistema('CRED',0,'URI_CONSULTA_GRAVAME');
  
  -- Cursor para verificar se ha algum BEM alienável
  CURSOR cr_crapbpr (pr_cdcooper crapbpr.cdcooper%type
                    ,pr_nrdconta crapbpr.nrdconta%type
                    ,pr_nrctrpro crapbpr.nrctrpro%TYPE
                    ,pr_flgmaqui VARCHAR2 DEFAULT 'N') IS
    SELECT crapbpr.tpdbaixa,
           crapbpr.rowid,
           crapbpr.cdsitgrv
      FROM crapbpr
     WHERE crapbpr.cdcooper = pr_cdcooper
       AND crapbpr.nrdconta = pr_nrdconta
       AND crapbpr.tpctrpro = 90
       AND crapbpr.nrctrpro = pr_nrctrpro
       AND crapbpr.flgalien = 1
       AND grvm0001.fn_valida_categoria_alienavel(crapbpr.dscatbem) = 'S';
  rw_crapbpr cr_crapbpr%rowtype;  
  
  -- Nome do Operador
  cursor cr_crapope(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_cdoperad crapope.cdoperad%TYPE) is
    SELECT ope.nmoperad
          ,age.nmcidade
          ,age.cdufdcop
      FROM crapope ope
          ,crapage age
     WHERE ope.cdcooper = age.cdcooper
       AND ope.cdagenci = age.cdagenci
       AND ope.cdcooper = pr_cdcooper
       and ope.cdoperad = pr_cdoperad;
  rw_crapope cr_crapope%ROWTYPE;       
  
  -- BUsca de endereco do cliente
  CURSOR cr_crapenc(pr_cdcooper crapenc.cdcooper%TYPE
                   ,pr_nrdconta crapenc.nrdconta%TYPE
                   ,pr_inpessoa crapass.inpessoa%TYPE) IS
    SELECT nvl(enc.dsendere, ' ') dsendere
          ,nvl(enc.nrendere, 0) nrendere
		  ,nvl(enc.complend, ' ') complend
		  ,nvl(enc.nmbairro, ' ') nmbairro
		  ,nvl(enc.cdufende, ' ') cdufende
		  ,nvl(enc.nrcepend, 0) nrcepend
		  ,nvl(enc.nmcidade, ' ') nmcidade
      FROM crapenc enc
    WHERE enc.cdcooper = pr_cdcooper
      AND enc.nrdconta = pr_nrdconta
      AND (  -- Para PF
             (    pr_inpessoa = 1
              AND enc.idseqttl = 1 /* Sempre do primeiro titular */
              AND enc.tpendass = 10)
           OR
             -- Para PJ
             (    pr_inpessoa = 2
              AND enc.idseqttl = 1 /* Sempre do primeiro titular */
              AND enc.cdseqinc = 1
              AND enc.tpendass = 9)
           );
  rw_enc cr_crapenc%ROWTYPE;

  -- Telefone do associado
  CURSOR cr_craptfc(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_nrdconta crawepr.nrdconta%TYPE) IS
    SELECT tfc.nrdddtfc
          ,tfc.nrtelefo
      FROM craptfc tfc
     WHERE tfc.cdcooper = pr_cdcooper
       AND tfc.nrdconta = pr_nrdconta
       AND tfc.idseqttl = 1 /* Sempre primeiro titular */
     ORDER BY tfc.tptelefo
             ,tfc.nrtelefo;  
             
  -- Função para validar se categoria do bem enviado é alienável
  FUNCTION fn_valida_categoria_alienavel(pr_dscatbem IN crapbpr.dscatbem%TYPE) RETURN VARCHAR2 IS
  /* ............................................................................

    Programa: fn_valida_categoria_alienavel  
    Autor   : Marcos Martini (Envolti)
    Data    : Outubro/2018                   Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Tratar categoria enviada e devolver positivo caso seja 
                uma das categorias alienáveis:
                 - AUTOMOVEL
                 - MOTO
                 - CAMINHAO
                 - OUTROS VEICULOS
    Alteracoes: 
  ............................................................................ */   
  BEGIN
    IF TRIM(upper(pr_dscatbem)) IN('AUTOMOVEL','MOTO','CAMINHAO','OUTROS VEICULOS') THEN
      RETURN 'S';
    ELSE
      RETURN 'N';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END fn_valida_categoria_alienavel;
  
  -- Tem como objetivo retornar S caso esteja habilitado o envio de Gravames Online 
  FUNCTION fn_tem_gravame_online(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN VARCHAR2 IS
  BEGIN                                          
  /* .........................................................................
    
    Programa : fn_tem_gravame_online
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Marcos Martini - Envolti
    Data     : Outubro/2018                    Ultima atualizacao: --/--/----
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Tem como objetivo retornar S caso esteja habilitado o envio de Gravames Online 
    Alteração : 
        
  ..........................................................................*/
    BEGIN 
      
      -- Checar parâmetro do sistema e retornar
      RETURN gene0001.fn_param_sistema('CRED',pr_cdcooper,'GRAVAM_TIPO_COMUNICACAO');
      
    EXCEPTION     
      WHEN OTHERS THEN
        RETURN 'N';
    END;
  END fn_tem_gravame_online;  
  
  /* Overload para chamada do Ayllos Web */
  PROCEDURE pc_tem_gravame_online_web(pr_xmllog   IN  VARCHAR2                    -- XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER                 -- Código da crítica
                                     ,pr_dscritic OUT VARCHAR2                    -- Descrição da crítica
                                     ,pr_retxml   IN  OUT NOCOPY XMLType          -- Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2                    -- Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS                -- Erros do processo
  BEGIN                                          
  /* .........................................................................
    
    Programa : pc_tem_gravame_online_web
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : GRVM
    Autor    : Marcos Martini
    Data     : Outubro/2018                    Ultima atualizacao: --/--/----
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Tem como objetivo retornar S caso esteja habilitado o envio de Gravames Online .
                É chamada pelo AyllosWeb
    Alteração : 
        
  ..........................................................................*/
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic VARCHAR2(10000)       := NULL;

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
    
    BEGIN 
      
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
        
    -- Retorna OK para cadastro efetuado com sucesso
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><grvonline>'|| fn_tem_gravame_online(vr_cdcooper) || '</grvonline></Root>');   

    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;        
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>'); 
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel verificar parametro GRAVAM_TIPO_COMUNICACAO: '||SQLERRM;
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>'); 
      
    END;
  END pc_tem_gravame_online_web; 
  
  /* Overload para chamada do Progress */
  PROCEDURE pc_tem_gravame_online_progress(pr_cdcooper IN crapcop.cdcooper%TYPE -- Cooperativa desejada
                                          ,pr_flonline OUT VARCHAR2) IS
  BEGIN                                          
  /* .........................................................................
    
    Programa : pc_tem_gravame_online_progress
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : GRVM
    Autor    : Marcos Martini
    Data     : Outubro/2018                    Ultima atualizacao: --/--/----
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Tem como objetivo retornar S caso esteja habilitado o envio de Gravames Online .
                É chamada pelo Progress
    Alteração : 
        
  ..........................................................................*/
    BEGIN 
        
      pr_flonline := fn_tem_gravame_online(pr_cdcooper);
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_flonline := 'N';
      END;
  END pc_tem_gravame_online_progress; 
  
  -- Procedimento para montagem das informações de configuração da Conexão Gravames B3
  PROCEDURE pc_config_gravame_b3(pr_cdcooper IN crapbpr.cdcooper%TYPE -- Cod. Cooperativa
                                /* Saida */
                                ,pr_xmldesal OUT VARCHAR2 -- XML da configuração de alienação
                                ,pr_dscritic OUT VARCHAR2 -- Descrição de critica encontrada
                                ) IS
  /* ............................................................................

    Programa: pc_config_gravame_b3                           
    Autor   : Marcos Martini (Envolti)
    Data    : Outubro/2018                   Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Gerar XML Configuração Gravame B3

    Alteracoes: 
  ............................................................................ */   
    
    -- Cursor para validacao da cooperativa conectada
    CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%type) IS
      SELECT nmrescop
            ,nrdocnpj
            ,cdloggrv
            ,cdfingrv
            ,cdsubgrv
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%rowtype;    
  BEGIN
    
    -- Verifica cooperativa
    OPEN cr_crapcop (pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;
    IF cr_crapcop%NOTFOUND THEN
      pr_dscritic := gene0001.fn_busca_critica(794);
      CLOSE cr_crapcop;
      RETURN;
    END IF;
    CLOSE cr_crapcop;   
  
    -- Escrever no arquivo XML a raiz da listagem do bem
    pr_xmldesal := '<sistemaNacionalGravames>'
                   ||'<identificadorAgenteFinanceiro>'||gene0001.fn_param_sistema('CRED',pr_cdcooper,'ID_AGENTE_FINANC_GRAVAME')||'</identificadorAgenteFinanceiro>'
                   ||'<descricaoAgenteFinanceiro>'||rw_crapcop.nmrescop||'</descricaoAgenteFinanceiro>'
                   ||'<CNPJAgenteFinanceiro>'||rw_crapcop.nrdocnpj||'</CNPJAgenteFinanceiro>'
                   ||'<loginAgenteFinanceiro>'||rw_crapcop.cdloggrv||'</loginAgenteFinanceiro>'
                   ||'<codigoAgenteFinanceiro>'||rw_crapcop.cdfingrv||'</codigoAgenteFinanceiro>'
                   ||'<subCodigoAgenteFinanceiro>'||rw_crapcop.cdsubgrv||'</subCodigoAgenteFinanceiro>'
                 ||'</sistemaNacionalGravames>';
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na montagem de informacoes para Configuração -> '||SQLERRM;
  END pc_config_gravame_b3;  
  
  
  /* Retorno dos horário de envio do Lote Online */
  PROCEDURE pc_horarios_lote_online(pr_cdcooper IN crapcop.cdcooper%TYPE -- Cooperativa desejada
                                   ,pr_hrenvi01 OUT varchar2             -- Horário 1º Envio do dia
                                   ,pr_hrenvi02 OUT varchar2             -- Horário 2º Envio do dia
                                   ,pr_hrenvi03 OUT varchar2             -- Horário 3º Envio do dia
                                   ,pr_dscritic OUT VARCHAR2             -- Descrição da crítica
                                   ) IS                
  BEGIN                                          
  /* .........................................................................
    
    Programa : pc_horarios_lote_online
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : GRVM
    Autor    : Marcos Martini
    Data     : Outubro/2018                    Ultima atualizacao: --/--/----
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Tem como objetivo retornar os horários para envio dos lotes pendentes
    Alteração : 
        
  ..........................................................................*/
    BEGIN
      -- Retornar os três horários
      pr_hrenvi01 := gene0001.fn_param_sistema('CRED',pr_cdcooper,'GRAVAM_HRENVIO_01');
      pr_hrenvi02 := gene0001.fn_param_sistema('CRED',pr_cdcooper,'GRAVAM_HRENVIO_02');
      pr_hrenvi03 := gene0001.fn_param_sistema('CRED',pr_cdcooper,'GRAVAM_HRENVIO_03');
    END;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel retornar parametros de horarios de envio: '||SQLERRM;
  END pc_horarios_lote_online; 
  
  
  -- Função simples comparativa de codigos de retorno de gravames para definir se houve sucesso ou não
  FUNCTION fn_flag_sucesso_gravame(pr_nrseqlot crapgrv.nrseqlot%TYPE  -- Lote
                                  ,pr_dtretgrv crapgrv.dtretgrv%TYPE  -- Retorno GRavames
                                  ,pr_cdretlot crapgrv.cdretlot%TYPE  -- Retorno Lote
                                  ,pr_cdretgrv crapgrv.cdretgrv%TYPE  -- Retorno Gravame
                                  ,pr_cdretctr crapgrv.cdretctr%TYPE  -- Retorno Contrato
                                  ,pr_dscritic crapgrv.dscritic%TYPE) -- Critica generica comunicacao
                                  RETURN VARCHAR2 IS
  BEGIN
    -- Para envio de lote
    IF pr_nrseqlot <> 0 THEN
      -- Se não houve retorno ainda 
      IF pr_dtretgrv IS NULL THEN
        -- Volta vazio
        RETURN ' ';
      ELSE
        -- Validação de sucesso nos lotes, contrato e grv
        IF pr_cdretlot = 0 
        AND pr_cdretgrv IN(0,30,300)
        AND pr_cdretctr IN(0,90,900) THEN
          RETURN 'S';
        ELSE
          RETURN 'N';  
        END IF;  
      END IF;  
    ELSE
      -- Envio online
      IF trim(pr_dscritic) IS NULL 
      AND pr_cdretgrv IN(0,30,300)
      AND pr_cdretctr IN(0,100,900) THEN
        RETURN 'S';
      ELSE
        RETURN 'N';  
      END IF;  
    END IF;  
  END;                                  
  
  /* Funcao para validacao dos caracteres */
  FUNCTION fn_valida_caracteres (pr_flgnumer IN BOOLEAN,  -- Validar Numeros?
                                 pr_flgletra IN BOOLEAN,  -- Validar Letras?
                                 pr_listaesp IN VARCHAR2, -- Lista de Caracteres Validos
                                 pr_listainv IN VARCHAR2, -- Lista de Caracteres Invalidos
                                 pr_dsvalida IN VARCHAR2  -- Texto para ser validado
                                ) RETURN BOOLEAN IS       -- ERRO -> TRUE
  /* ............................................................................

    Programa: fn_valida_caracteres                           antiga:includes/verifica_caracter.i
    Autor   : Andrei
    Data    : Julho/2016                   Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Processar validacoes de caracteres em campos digitaveis

    Parametros : pr_flgnumer : Validar lista de numeros ?
                 pr_flgletra : Validar lista de letras  ?
                 pr_listaesp : Lista de caracteres validados.
                 pr_listainv : Lista de caracteres invaldidos
                 pr_validar  : Campo a ser validado.

    Alteracoes: 
  ............................................................................ */   
    vr_dsvalida VARCHAR2(30000);
      
    vr_numeros  VARCHAR2(10) := '0123456789';
    vr_letras   VARCHAR2(49) := 'QWERTYUIOPASDFGHJKLZXCVBNM';
    vr_validar  VARCHAR2(30000);
    vr_caracter VARCHAR2(1);
      
    TYPE typ_tab_char IS TABLE OF VARCHAR2(1) INDEX BY VARCHAR2(1);
    vr_tab_char typ_tab_char;
    
    TYPE typ_tab_char_invalido IS TABLE OF VARCHAR2(1) INDEX BY VARCHAR2(1);
    vr_tab_char_invalido typ_tab_char_invalido;
            
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';
  
  BEGIN
 	  --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.fn_valida_caracteres');
      
    vr_dsvalida := REPLACE(UPPER(pr_dsvalida),' ','');
    
    -- Caso nao tenha campos a validar retorna OK
    IF TRIM(vr_dsvalida) IS NULL THEN
      RETURN FALSE;
    END IF;
    
    -- Numeros
    IF pr_flgnumer THEN
      -- Todos os caracteres devem ser numeros
      vr_validar:= vr_validar || vr_numeros;
    END IF;

    -- Letras 
    IF pr_flgletra THEN
      -- Todos os caracteres devem ser numeros
      vr_validar:= vr_validar || vr_letras;
    END IF;
      
    -- Lista Caracteres Aceitos
    IF TRIM(pr_listaesp) IS NOT NULL THEN
      vr_validar:= vr_validar || pr_listaesp;
    END IF;

    FOR vr_pos IN 1..length(vr_validar) LOOP
      vr_caracter:= SUBSTR(vr_validar,vr_pos,1);
      vr_tab_char(vr_caracter) := vr_caracter;
    END LOOP;
    
    FOR vr_pos IN 1..length(pr_listainv) LOOP
      vr_caracter:= SUBSTR(pr_listainv,vr_pos,1);
      vr_tab_char_invalido(vr_caracter) := vr_caracter;
    END LOOP;
    
    FOR vr_pos IN 1..length(vr_dsvalida) LOOP
      vr_caracter:= SUBSTR(vr_dsvalida,vr_pos,1);
      IF NOT vr_tab_char.exists(vr_caracter)       OR
         vr_tab_char_invalido.exists(vr_caracter)  THEN
        RETURN TRUE;
      END IF;
    END LOOP;

    RETURN FALSE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END fn_valida_caracteres;
  
  /* Funcao para validacao dos caracteres */
  FUNCTION fn_des_tpchassi (pr_tpchassi crapbpr .tpchassi%TYPE) RETURN VARCHAR2 IS       -- ERRO -> TRUE
  BEGIN
    IF pr_tpchassi = 1 THEN
      RETURN 'true';
    ELSE
      RETURN 'false';
    END IF;
  END;
  
  /* Procedimento para busca do emitente (Inverveniente, se houver) */
  PROCEDURE pc_busca_emitente(pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE
                             ,pr_nrctremp IN crapepr.nrctremp%TYPE
                             ,pr_nrcpfbem IN crapass.nrcpfcgc%TYPE
                             ,pr_nrcpfemi IN OUT crapass.nrcpfcgc%TYPE
                             ,pr_nmprimtl IN OUT crapass.nmprimtl%TYPE) IS
  /* ............................................................................

    Programa: pc_busca_emitente
    Autor   : Marcos Martini (Envolti)
    Data    : Julho/2016                   Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Buscar interveniente garantidor, caso tenha sido informado


    Alteracoes: 
  ............................................................................ */     
    -- Busca das informações do Inverveniente Garantidor
    CURSOR cr_crapavt(pr_cdcooper crapavt.cdcooper%TYPE
                     ,pr_nrdconta crapavt.nrdconta%TYPE
                     ,pr_nrctremp crapavt.nrctremp%TYPE
                     ,pr_nrcpfcgc crapavt.nrcpfcgc%TYPE) IS
      SELECT avt.nmdavali
            ,avt.nrcpfcgc
        FROM crapavt avt
       WHERE avt.cdcooper = pr_cdcooper
         AND avt.tpctrato = 9
         AND avt.nrdconta = pr_nrdconta
         AND avt.nrctremp = pr_nrctremp
         AND avt.nrcpfcgc = pr_nrcpfcgc;  
  BEGIN
    -- Se o bem não for do associado
    IF pr_nrcpfbem > 0 AND pr_nrcpfbem != pr_nrcpfemi THEN
      -- Buscaremos as informações do cadastro de avalistas
      OPEN cr_crapavt(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp
                     ,pr_nrcpfcgc => pr_nrcpfbem);
      FETCH cr_crapavt
        INTO pr_nmprimtl,pr_nrcpfemi;
      CLOSE cr_crapavt;
    END IF;    
  END pc_busca_emitente;                           
  

  -- Valida se é alienação fiduciaria
  PROCEDURE pc_valida_alienacao_fiduciaria (pr_cdcooper   IN crapcop.cdcooper%type  -- Código da cooperativa
                                           ,pr_nrdconta   IN crapass.nrdconta%type  -- Numero da conta do associado
                                           ,pr_nrctrpro   IN PLS_INTEGER            -- Numero do contrato
                                           ,pr_flgcompl   IN VARCHAR2 DEFAULT 'N'   -- Flag S/N de busca completa das informações do Associado
                                           ,pr_des_reto  OUT VARCHAR2               -- Retorno Ok ou NOK do procedimento
                                           ,pr_vet_dados OUT typ_reg_dados          -- Registro com dados necessários para conexão B3
                                           ,pr_dscritic  OUT VARCHAR2               -- Retorno da descricao da critica do erro
                                           ) IS
  -- ..........................................................................
    --
    --  Programa : pc_valida_alienacao_fiduciaria            Antigo: b1wgen0171.p/valida_eh_alienacao_fiduciaria

    --  Sistema  : Rotinas genericas para GRAVAMES
    --  Sigla    : GRVM
    --  Autor    : Douglas Pagel
    --  Data     : Dezembro/2013.                   Ultima atualizacao: 29/05/2017
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Retorna OK caso o contrato seja de alienacao fiduciaria
    --
    --   Alteracoes: 04/12/2013 - Conversao Progress para Oracle (Douglas Pagel). 
    --
    --               28/07/2016 - Ajuste para retirar validação que verifica se contrato
    --                            esta em prejuízo
    --                            (Adriano - SD  495514)                         
    --
    --              29/05/2017 - Padronização das mensagens para a tabela tbgen_prglog,
    --                         - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
    --                         - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
    --                         - Incluir nome do módulo logado em variável
    --                         - Substituição da chamada da rotina gene0001.pc_gera_erro pela btch0001.pc_gera_log_batch
    --                         - Retorno do erro para o parâmetro pr_dscritic 
    --                         - Inclusão exception tratada vr_exc_erro
    --                         - Substituída rotina gene0001.pc_gera_erro por raise vr_exec_erro
    --                           (Ana - Envolti) - SD: 660356 e 660394
    -- .............................................................................
    -- CURSORES

    -- Cursor para validacao da cooperativa conectada
    CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%type) IS
        SELECT nmrescop
              ,nrdocnpj
              ,cdloggrv
              ,cdfingrv
              ,cdsubgrv
              ,nrtelvoz
              ,cdufdcop
              ,nmcidade
              ,nmbairro
              ,dsendcop
              ,nrendcop
              ,nrcepend
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%rowtype;

    --Cursor para validar associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%type) IS
      SELECT nrdconta
              ,nrcpfcgc
              ,nmprimtl
              ,inpessoa
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;

    -- Cursor para verificar a proposta
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%type
                      ,pr_nrdconta crawepr.nrdconta%type
                      ,pr_nrctrpro crawepr.nrctremp%type) IS
        SELECT wpr.cdlcremp
              ,wpr.dtlibera
              ,wpr.dtmvtolt
              ,wpr.qtpreemp
              ,decode(wpr.txmensal,0,lcr.txmensal,wpr.txmensal) txmensal
              ,wpr.vlemprst
              ,wpr.dtdpagto
              ,wpr.cdfinemp
              ,wpr.tpemprst
              ,to_char(wpr.nrctrliq##1) || ',' || to_char(wpr.nrctrliq##2) || ',' ||
               to_char(wpr.nrctrliq##3) || ',' || to_char(wpr.nrctrliq##4) || ',' ||
               to_char(wpr.nrctrliq##5) || ',' || to_char(wpr.nrctrliq##6) || ',' ||
               to_char(wpr.nrctrliq##7) || ',' || to_char(wpr.nrctrliq##8) || ',' ||
               to_char(wpr.nrctrliq##9) || ',' || to_char(wpr.nrctrliq##10) dsliquid
          FROM crawepr wpr
              ,craplcr lcr
         WHERE wpr.cdcooper = lcr.cdcooper
           AND wpr.cdlcremp = lcr.cdlcremp
           AND wpr.cdcooper = pr_cdcooper
           AND wpr.nrdconta = pr_nrdconta
           AND wpr.nrctremp = pr_nrctrpro;
    rw_crawepr cr_crawepr%rowtype;

    -- Cursor para validar a linha de credito da alienacao
    CURSOR cr_craplcr (pr_cdcooper craplcr.cdcooper%type
                      ,pr_cdlcremp craplcr.cdlcremp%type) IS
      SELECT cdcooper
              ,flgcobmu
        FROM craplcr
       WHERE craplcr.cdcooper = pr_cdcooper
         AND craplcr.cdlcremp = pr_cdlcremp
         AND craplcr.tpctrato = 2;
    rw_craplcr cr_craplcr%rowtype;

      -- Busca de dados do municipio
      CURSOR cr_crapmun(pr_cdestado crapmun.cdestado%TYPE
                       ,pr_dscidade crapmun.dscidade%TYPE) IS
        SELECT mun.cdcidade
          FROM crapmun mun
        WHERE upper(mun.cdestado) = pr_cdestado
          AND upper(mun.dscidade) = pr_dscidade; 
      
    -- VARIÁVEIS
    vr_cdcritic PLS_INTEGER := 0; -- Variavel interna para erros
    vr_dscritic varchar2(4000) := ''; -- Variavel interna para erros

    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 

    -- Código do programa
	  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';

    BEGIN
  	  --Incluir nome do módulo logado - Chamado 660394
	    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_valida_alienacao_fiduciaria');

      -- Verifica cooperativa
      OPEN cr_crapcop (pr_cdcooper);
      FETCH cr_crapcop
        INTO rw_crapcop;
      IF cr_crapcop%NOTFOUND THEN
        pr_des_reto := 'NOK';
        vr_cdcritic := 794;
        CLOSE cr_crapcop;
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapcop;

      -- Verifica associado
      IF pr_nrdconta = 0 THEN
        pr_des_reto := 'NOK';
        vr_cdcritic := 0;
        vr_dscritic := 'Informar o numero da Conta';
        RAISE vr_exc_erro;
      END IF;
      -- Busca seu cadastro
      OPEN cr_crapass (pr_cdcooper,
                       pr_nrdconta);
      FETCH cr_crapass
        INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        pr_des_reto := 'NOK';
        vr_cdcritic := 9;                 
        CLOSE cr_crapass;
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapass;

      -- Verifica a proposta
      OPEN cr_crawepr(pr_cdcooper, pr_nrdconta, pr_nrctrpro);
      FETCH cr_crawepr
        INTO rw_crawepr;
      IF cr_crawepr%NOTFOUND THEN
        vr_cdcritic := 356;
        vr_dscritic := '';
        pr_des_reto := 'NOK';
        CLOSE cr_crawepr;
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crawepr;

      -- Verifica a linha de credito
      OPEN cr_craplcr(pr_cdcooper,rw_crawepr.cdlcremp);
      FETCH cr_craplcr
        INTO rw_craplcr;
      IF cr_craplcr%NOTFOUND THEN
        vr_cdcritic := 0;
        vr_dscritic := ' Linha de Credito invalida para essa operacao! ';
        pr_des_reto := 'NOK';
        CLOSE cr_craplcr;
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_craplcr;
      
      -- Verifica se ha algum BEM alienável
      OPEN cr_crapbpr(pr_cdcooper
                     ,pr_nrdconta
                     ,pr_nrctrpro);
      FETCH cr_crapbpr
        INTO rw_crapbpr;
      IF cr_crapbpr%NOTFOUND THEN
        vr_cdcritic := 0;
        vr_dscritic := ' Proposta sem Bem valido ou Bem nao encontado! ';
        pr_des_reto := 'NOK';
        CLOSE cr_crapbpr;
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapbpr;

      -- Devolver informações necessárias para alienação a B3
      pr_vet_dados.nmrescop := rw_crapcop.nmrescop;
      pr_vet_dados.nrdocnpj := rw_crapcop.nrdocnpj;
      pr_vet_dados.cdloggrv := rw_crapcop.cdloggrv;
      pr_vet_dados.cdfingrv := rw_crapcop.cdfingrv;
      pr_vet_dados.cdsubgrv := rw_crapcop.cdsubgrv;
      pr_vet_dados.nrcpfemi := rw_crapass.nrcpfcgc;
      pr_vet_dados.nmprimtl := rw_crapass.nmprimtl;
      pr_vet_dados.dtlibera := rw_crawepr.dtlibera;
      pr_vet_dados.dtmvtolt := rw_crawepr.dtmvtolt;
      pr_vet_dados.qtpreemp := rw_crawepr.qtpreemp;
      pr_vet_dados.txmensal := rw_crawepr.txmensal;
      pr_vet_dados.vlemprst := rw_crawepr.vlemprst;
      pr_vet_dados.dtdpagto := rw_crawepr.dtdpagto;
      pr_vet_dados.cdfinemp := rw_crawepr.cdfinemp;
      pr_vet_dados.tpemprst := rw_crawepr.tpemprst;

      -- Se solicitado para buscar informações completas do cooperado e Coop
      IF pr_flgcompl = 'S' THEN
        
        -- Separar DDD do Credor
        pr_vet_dados.nrdddenc := '0' || TRIM(REPLACE(gene0002.fn_busca_entrada(1,rw_crapcop.nrtelvoz,')'),'(',''));
        -- Separar Telefone do Credor
        pr_vet_dados.nrtelenc := TRIM(REPLACE(gene0002.fn_busca_entrada(2,rw_crapcop.nrtelvoz,')'),'-',''));
        
        -- Buscar municipio do credor
        pr_vet_dados.cdcidcre := NULL;
        OPEN cr_crapmun(pr_cdestado => rw_crapcop.cdufdcop
                       ,pr_dscidade => rw_crapcop.nmcidade);
        FETCH cr_crapmun
         INTO pr_vet_dados.cdcidcre;
        CLOSE cr_crapmun; 
        -- Usar Blumenau caso não encontrado
        pr_vet_dados.cdcidcre := nvl(pr_vet_dados.cdcidcre,8047);
        -- Preencher dados do credot
        pr_vet_dados.dsendcre := GENE0007.fn_caract_acento(rw_crapcop.dsendcop,1); -- Logradouro Emitente
        pr_vet_dados.nrendcre := rw_crapcop.nrendcop; -- Numero Emitente
        pr_vet_dados.nmbaicre := GENE0007.fn_caract_acento(rw_crapcop.nmbairro,1); -- Nome Bairro Emitente
        pr_vet_dados.cdufecre := rw_crapcop.cdufdcop; -- UF Emitente
        pr_vet_dados.nrcepcre := rw_crapcop.nrcepend; -- CEP Emitente 
      
      
        -- BUscar o endereço do cliente
        rw_enc := NULL;
        OPEN cr_crapenc(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_inpessoa => rw_crapass.inpessoa);
        FETCH cr_crapenc
         INTO rw_enc;
        CLOSE cr_crapenc;

        -- Buscar municipio do cliente
        pr_vet_dados.cdcidcli := NULL;
        OPEN cr_crapmun(pr_cdestado => rw_enc.cdufende
                       ,pr_dscidade => rw_enc.nmcidade);
        FETCH cr_crapmun
         INTO pr_vet_dados.cdcidcli;
        CLOSE cr_crapmun; 
        -- Usar Blumenau caso não encontrado
        pr_vet_dados.cdcidcli := nvl(pr_vet_dados.cdcidcli,8047);
        pr_vet_dados.dsendere := GENE0007.fn_caract_acento(rw_enc.dsendere,1); -- Logradouro Emitente
        pr_vet_dados.nrendere := rw_enc.nrendere; -- Numero Emitente
        pr_vet_dados.nmbairro := GENE0007.fn_caract_acento(rw_enc.nmbairro,1); -- Nome Bairro Emitente
        pr_vet_dados.cdufende := rw_enc.cdufende; -- UF Emitente
        pr_vet_dados.nrcepend := rw_enc.nrcepend; -- CEP Emitente

        -- Telefone do cliente
        pr_vet_dados.nrdddass := NULL;
        pr_vet_dados.nrtelass := NULL;
        FOR rw_tfc IN cr_craptfc(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP
          -- Formatar a informação
          pr_vet_dados.nrdddass := to_char(nvl(rw_tfc.nrdddtfc,0),'fm000');
          pr_vet_dados.nrtelass := to_char(nvl(rw_tfc.nrtelefo,0),'fm900000000');
          -- Sair quando encontrar
          EXIT WHEN (pr_vet_dados.nrdddass <> ' ' AND pr_vet_dados.nrtelass <> ' ');
        END LOOP;
          
        IF TRIM(pr_vet_dados.nrdddass) IS NULL THEN
          pr_vet_dados.nrdddass := to_char(0,'fm000');
        END IF;
          
        IF TRIM(pr_vet_dados.nrtelass) IS NULL THEN
          pr_vet_dados.nrtelass := to_char(0,'fm900000000');
        END IF;     
        
        -- Se linha cobra Multa
        IF rw_craplcr.flgcobmu = 1 THEN
          -- Busca o percentual de multa se ainda não buscado
          pr_vet_dados.permulta := gene0002.fn_char_para_number(  
                                              substr(tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                                                               ,pr_nmsistem => 'CRED'
                                                                               ,pr_tptabela => 'USUARI'
                                                                               ,pr_cdempres => 11
                                                                               ,pr_cdacesso => 'PAREMPCTL'
                                                                               ,pr_tpregist => 1),1,5));
        ELSE
          pr_vet_dados.permulta := 0;
        END IF;
        
        -- Calcular data do ultimo vencimento considerando
        -- a data do primeiro pagamento e quantidade de parcelas
        pr_vet_dados.dtvencto := add_months(pr_vet_dados.dtdpagto,pr_vet_dados.qtpreemp-1);
        
        -- Se há contratos a liquidar
        IF rw_crawepr.dsliquid <> '0,0,0,0,0,0,0,0,0,0' THEN
          pr_vet_dados.vtctrliq := gene0002.fn_quebra_string(rw_crawepr.dsliquid, ',');
        END IF;
         
      END IF;
      
      -- Se não ocorreram criticas anteriores, retorna OK e volta para o programa chamador
      pr_des_reto := 'OK';

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Erro
        --pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;

        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descrição
          pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        --Inclusão dos parâmetros apenas na exception, para não mostrar na tela
        --Padronização - Chamado 660394
        --Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- Mensagem
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                      'ALERTA: '|| pr_dscritic ||
                                                      ',Cdcooper:'||pr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                      ',Nrctrpro:'||pr_nrctrpro);

      WHEN OTHERS THEN
        pr_dscritic := 'Erro nao tratado na grvm0001.pc_valida_alienacao_fiduciaria --> '|| SQLERRM;
        pr_des_reto := 'NOK';

        --Inclusão gravação erro nas tabelas 
        --Padronização - Chamado 660394
        --Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                      'ERRO: ' || pr_dscritic  ||
                                                      ',Cdcooper:'||pr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                      ',Nrctrpro:'||pr_nrctrpro);

        --Inclusão na tabela de erros Oracle
        CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper
                                     ,pr_compleme => pr_dscritic );


        RETURN;
    END; --  pc_valida_alienacao_fiduciaria

  -- Valida se é alienação fiduciaria (chamada via Progress
  PROCEDURE pc_valida_alienacao_fiduc_prog(pr_cdcooper   IN crapcop.cdcooper%type  -- Código da cooperativa
                                          ,pr_nrdconta   IN crapass.nrdconta%type  -- Numero da conta do associado
                                          ,pr_nrctrpro   IN PLS_INTEGER            -- Numero do contrato
                                          ,pr_des_reto  OUT VARCHAR2               -- Retorno Ok ou NOK do procedimento
                                          ,pr_cdcritic  OUT NUMBER                 -- Retorno de codigo de critica do erro
                                          ,pr_dscritic  OUT VARCHAR2               -- Retorno da descricao da critica do erro
                                          ) IS
    -- ..........................................................................
    --
    --  Programa : pc_valida_alienacao_fiduc_prog           

    --  Sistema  : Rotinas genericas para GRAVAMES
    --  Sigla    : GRVM
    --  Autor    : Marcos Martini (Envolti)
    --  Data     : Outubro/2018.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Retorna OK caso o contrato seja de alienacao fiduciaria
    --
    --   Alteracoes: 
    -- .............................................................................
      
      -- Temporaria
      vr_vet_dados typ_reg_dados;

    BEGIN
      -- Direcionar para a chamada completa
      pc_valida_alienacao_fiduciaria(pr_cdcooper  => pr_cdcooper
                                    ,pr_nrdconta  => pr_nrdconta
                                    ,pr_nrctrpro  => pr_nrctrpro
                                    ,pr_des_reto  => pr_des_reto
                                    ,pr_vet_dados => vr_vet_dados
                                    ,pr_dscritic  => pr_dscritic);
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro nao tratado na grvm0001.pc_valida_alienacao_fiduciaria --> '|| SQLERRM;
        pr_des_reto := 'NOK';
        --Inclusão na tabela de erros Oracle
        CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper
                                     ,pr_compleme => pr_dscritic );
  END;                                         

  -- Validação se todos bens ou contrato está alienado
  PROCEDURE pc_valida_bens_alienados(pr_cdcooper IN crapcop.cdcooper%type   -- Código da cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%type   -- Numero da conta do associado
                                    ,pr_nrctrpro IN crapepr.nrctremp%TYPE   -- Numero do contrato
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  -- Codigo Critica de saida
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE  -- Descricao critica de saida
                                    ) as

     /* .............................................................................

         Programa: pc_valida_bens_alienados           (Antigo b1wgen0171.p - valida_bens_alienados)
         Sistema : Conta-Corrente - Cooperativa de Credito
         Sigla   : CRED
         Autor   : 
         Data    :                            Ultima atualizacao: 22/06/2018

         Dados referentes ao programa:

         Frequencia: Sempre que for chamado.
         Objetivo  : Rotina responsavel em validar bens alienados

         Alteracoes: 22/06/2018 - Conversao Progress -> Oracle. (Renato Cordeiro/Odirlei AMcom)
          
                     24/10/2018 - P442 - Remoção da pr_tab_erro para reaproveitar no Progress (Marcos-Envolti)
                    
      ............................................................................. */
      
           
    -- Busca sobre data de inclusão do contrato --
    CURSOR cr_crawepr(pr_cdcooper IN crapcop.cdcooper%TYPE -- Numero da cooperativa
                     ,pr_nrdconta IN crapcop.nrdconta%TYPE -- Numero da conta do associado
                     ,pr_nrctrpro IN crapbpr.nrctrpro%type) IS -- Numero do contrato
      SELECT crawepr.flgokgrv
        FROM crawepr
       WHERE crawepr.cdcooper = pr_cdcooper
         AND crawepr.nrdconta = pr_nrdconta
         AND crawepr.nrctremp = pr_nrctrpro;
    rw_crawepr cr_crawepr%ROWTYPE;
    
    -- Buscar bens alienáveis não alienados ainda
    CURSOR cr_crapbpr (pr_cdcooper IN crapcop.cdcooper%TYPE -- Numero da cooperativa
                      ,pr_nrdconta IN crapcop.nrdconta%TYPE -- Numero da conta do associado
                      ,pr_nrctrpro IN crapbpr.nrctrpro%type) IS -- Numero do contrato
      SELECT a.cdsitgrv
            ,a.dschassi
            ,decode(trim(a.dsmarbem),NULL,NULL,a.dsmarbem||'-')||a.dsbemfin dsbemfim
        FROM crapbpr a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.tpctrpro = 90
         AND a.nrctrpro = pr_nrctrpro
         AND a.flgalien = 1
         AND grvm0001.fn_valida_categoria_alienavel(a.dscatbem) = 'S'
         AND a.cdsitgrv <> 2; -- Desconsiderar os já alienados
                
    -- Código do programa
    vr_cdprogra crapprg.cdprogra%TYPE;
    -- Erro para parar a cadeia
    vr_exc_saida exception;
    -- Erro sem parar a cadeia
    vr_exc_fimprg exception;

    vr_des_reto varchar2(2000);
    
    -- Vetor com dados auxiliares para alienação B3
    vr_vet_dados typ_reg_dados;

  BEGIN
    -- Código do programa
    vr_cdprogra := 'GRAVAM';    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'pc_valida_bens_alienados'
                              ,pr_action => 'pc_valida_bens_alienados');
    /* Validar basica de alienação */
    pc_valida_alienacao_fiduciaria(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctrpro => pr_nrctrpro,
                                   pr_des_reto => vr_des_reto,
                                   pr_vet_dados => vr_vet_dados, -- Vetor com dados para auxiliar alienação
                                   pr_dscritic => pr_dscritic);
    /** OBS: Sempre retornara OK pois a chamada da valida_bens_alienados
           vem da "EFETIVAR" (LANCTRI e BO00084), nesses casos nao pode
           impedir de seguir para demais contratos. **/
    -- Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
      pr_dscritic := NULL;
      raise vr_exc_fimprg; -- Sai do programa        
    END IF;  
      
    -- Retornar dados do contrato (removido validação de existencia pois já eh feito na pc_valida_alienacao_fiduciaria)
    open cr_crawepr(pr_cdcooper,pr_nrdconta,pr_nrctrpro) ;
    fetch cr_crawepr into rw_crawepr;
    CLOSE cr_crawepr;
    -- Se gravame não tem flag de OK e Gravames Online não está habilitado ainda
    if (rw_crawepr.flgokgrv = 0) AND fn_tem_gravame_online(pr_cdcooper) = 'N'THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Opcao Registro de Gravames, na tela ATENDA nao efetuada! Verifique.';
      RAISE vr_exc_saida;
    end if;    
    
    -- varrer os bens alienáveis da proposta
    for rw_crapbpr in cr_crapbpr (pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctrpro => pr_nrctrpro) LOOP   
       
      IF rw_crapbpr.cdsitgrv = 0 then
        pr_dscritic := 'Registro Gravame nao enviado.';
      elsif rw_crapbpr.cdsitgrv = 1 then
        pr_dscritic := 'Registro Gravame sem retorno.';
      elsif rw_crapbpr.cdsitgrv = 3 then
        pr_dscritic := 'Registro Gravame com problemas de processamento.';
      elsif rw_crapbpr.cdsitgrv = 4 then
        pr_dscritic := 'Bem baixado.';
      elsif rw_crapbpr.cdsitgrv = 5 then
        pr_dscritic := 'Bem cancelado.';
      end if;
      -- Se houve critica
      if pr_dscritic is not null then
        -- Adicionar dados do bem
        pr_dscritic := 'Veiculo '||rw_crapbpr.dsbemfim||' com pendencia Gravame: '
                    || pr_dscritic||' Verifique.';
        -- Disparar exceção
        RAISE vr_exc_saida;
      end if;
    END LOOP;

  EXCEPTION
    WHEN vr_exc_fimprg THEN
      NULL;
    WHEN vr_exc_saida THEN
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Mensagem
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '||                                                   
                                                    ',Cdcooper:'||pr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Nrctrpro:'||pr_nrctrpro ||
                                                    'ERRO: '|| pr_cdcritic ||' - '|| pr_dscritic ||
                                                    '[valida_bens_alienados]');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao validar bens alienados: '||SQLERRM;
      --Inclusão dos parâmetros apenas na exception, para não mostrar na tela
      --Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Mensagem
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '||                                                   
                                                    ',Cdcooper:'||pr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Nrctrpro:'||pr_nrctrpro ||
                                                    'ERRO: '|| pr_cdcritic ||' - '|| pr_dscritic ||
                                                    '[valida_bens_alienados]');
      ROLLBACK;
  end pc_valida_bens_alienados;

  -- Validar situacao gravames
  PROCEDURE  pc_valida_situacao_gravames ( pr_cdcooper IN crapbpr.cdcooper%TYPE       -- Cód. cooperativa
                                          ,pr_nrdconta IN crapbpr.nrdconta%TYPE       -- Nr. da conta
                                          ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE       -- Nr. contrato
                                          ,pr_idseqbem IN crapbpr.idseqbem%TYPE       -- Sequencial do bem
                                          ,pr_cdsitgrv OUT INTEGER                    -- Retorna situação do gravames 
                                          ,pr_dscrigrv OUT VARCHAR2                   -- Retorna critica de processamento do gravames
                                          ,pr_cdcritic OUT INTEGER                    -- Codigo de critica de sistema
                                          ,pr_dscritic OUT VARCHAR2                   -- Descrição da critica de sistema
                                          ) IS
   /* ..........................................................................
    
      Programa :  pc_valida_situacao_gravames

      Sistema  : Rotinas genericas para GRAVAMES
      Sigla    : GRVM
      Autor    : Odirlei Busana - AMcom
      Data     : Julhi/2018.                   Ultima atualizacao: 08/10/2018
    
      Dados referentes ao programa:
    
       Objetivo  : Rotina para validar situação do GRAVAMES
    
       Alteracoes: 08/10/2018 - P442 - Remocao de parametro de situacao Gravames (Marcos-Envolti)
       
    ............................................................................. */
       
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_tparquiv VARCHAR2(10);
    vr_dssituac VARCHAR2(300);
      
    -- Tratamento de erros
    vr_exc_saida EXCEPTION; 
    vr_exc_erro  EXCEPTION; 
    
    -- CURSORES
    CURSOR cr_crapbpr (pr_cdcooper IN crapcop.cdcooper%TYPE      -- Numero da cooperativa
                      ,pr_nrdconta IN crapcop.nrdconta%TYPE      -- Numero da conta do associado
                      ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE      -- Numero do contrato
                      ,pr_idseqbem IN crapbpr.nrctrpro%TYPE ) IS -- Sequencial do bem
                      
      SELECT a.cdsitgrv,
             a.cdcooper,
             a.nrdconta,
             a.tpctrpro,
             a.nrctrpro,
             a.idseqbem,
             a.dsjstinc,
             a.dsjstbxa,
             a.dsjuscnc
        FROM crapbpr a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.tpctrpro = 90
         AND a.nrctrpro = pr_nrctrpro
         AND a.idseqbem = pr_idseqbem
         AND a.flgalien = 1
         AND grvm0001.fn_valida_categoria_alienavel(a.dscatbem) = 'S';
    
    rw_crapbpr cr_crapbpr%ROWTYPE; 
    
    --> Buscar ultimo retorno
    CURSOR cr_crapgrv(pr_cdcooper crapgrv.cdcooper%TYPE,
                      pr_nrdconta crapgrv.nrdconta%TYPE,
                      pr_tpctrpro crapgrv.tpctrpro%TYPE,
                      pr_nrctrpro crapgrv.nrctrpro%TYPE,
                      pr_idseqbem crapgrv.idseqbem%TYPE) IS
      SELECT grv.cdoperac,
             grv.cdretlot,
             grv.cdretgrv,
             grv.cdretctr
        FROM crapgrv grv
       WHERE grv.cdcooper = pr_cdcooper
         AND grv.nrdconta = pr_nrdconta
         AND grv.tpctrpro = pr_tpctrpro
         AND grv.nrctrpro = pr_nrctrpro
         AND grv.idseqbem = pr_idseqbem
       ORDER BY nrseqlot DESC;
    rw_crapgrv cr_crapgrv%ROWTYPE;
    
    CURSOR cr_craprto(pr_cdoperac IN craprto.cdoperac%TYPE
                     ,pr_nrtabela IN craprto.nrtabela%TYPE
                     ,pr_cdretorn IN craprto.cdretorn%TYPE) IS
      SELECT craprto.cdretorn
            ,craprto.dsretorn
        FROM craprto
       WHERE craprto.cdprodut = 1 --Produto gravames
         AND craprto.cdoperac = pr_cdoperac
         AND craprto.nrtabela = pr_nrtabela
         AND craprto.cdretorn = pr_cdretorn;
    rw_craprto cr_craprto%ROWTYPE;
     
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';

  BEGIN
    --Incluir nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_valida_situacao_gravames');
    
    --> buscar dados do bem alienado 
    OPEN cr_crapbpr (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrctrpro => pr_nrctrpro
                    ,pr_idseqbem => pr_idseqbem);
    FETCH cr_crapbpr INTO rw_crapbpr;
    IF cr_crapbpr%NOTFOUND THEN
      CLOSE cr_crapbpr;
      RAISE vr_exc_saida; -- sair sem erro
      
    ELSE
      CLOSE cr_crapbpr;      
    END IF;
    
    pr_cdsitgrv := rw_crapbpr.cdsitgrv;
    
    IF pr_cdsitgrv = 3 THEN
     
      --> Buscar ultimo retorno
      OPEN cr_crapgrv( pr_cdcooper => rw_crapbpr.cdcooper,
                       pr_nrdconta => rw_crapbpr.nrdconta,
                       pr_tpctrpro => rw_crapbpr.tpctrpro,
                       pr_nrctrpro => rw_crapbpr.nrctrpro,
                       pr_idseqbem => rw_crapbpr.idseqbem);
      FETCH cr_crapgrv INTO rw_crapgrv;
      CLOSE cr_crapgrv;
       
      CASE rw_crapgrv.cdoperac
        WHEN 1 THEN vr_tparquiv := 'I';          
        WHEN 2 THEN vr_tparquiv := 'C';
        --> *** Para retornos, foi utilizada a letra "Q" e nao letra "B" ***
        WHEN 3 THEN  vr_tparquiv := 'Q';
        ELSE vr_tparquiv := NULL ;        
      END CASE;
      
      vr_dssituac := '';
      
      /** Exibir todos os retornos com erros **/
      IF rw_crapgrv.cdretlot <> 0 THEN
        
        OPEN cr_craprto(pr_cdoperac => vr_tparquiv
                       ,pr_nrtabela => 1
                       ,pr_cdretorn => rw_crapgrv.cdretlot);
        
        FETCH cr_craprto INTO rw_craprto;
        
        IF cr_craprto%NOTFOUND THEN
          vr_dssituac := TRIM(to_char(rw_crapgrv.cdretlot,'999')) || ' - SITUACAO NAO CADASTRADA';
        ELSE
          vr_dssituac := TRIM(to_char(rw_craprto.cdretorn,'999')) || ' - ' || rw_craprto.dsretorn;
        END IF;
        
        --Fecha o cursor
        CLOSE cr_craprto;
               
      ELSIF rw_crapgrv.cdretlot = 0  AND
        (rw_crapgrv.cdretgrv <> 0 AND
         rw_crapgrv.cdretgrv <> 30) THEN
        
        OPEN cr_craprto(pr_cdoperac => vr_tparquiv
                       ,pr_nrtabela => 2
                       ,pr_cdretorn => rw_crapgrv.cdretgrv);
        
        FETCH cr_craprto INTO rw_craprto;
        
        IF cr_craprto%NOTFOUND THEN
          vr_dssituac := TRIM(to_char(rw_crapgrv.cdretlot,'999')) || ' - SITUACAO NAO CADASTRADA';
        ELSE
          vr_dssituac := TRIM(to_char(rw_craprto.cdretorn,'999')) || ' - ' || rw_craprto.dsretorn;
        END IF;
        
        --Fecha o cursor
        CLOSE cr_craprto;               
               
      ELSIF rw_crapgrv.cdretlot = 0  AND
        (rw_crapgrv.cdretctr <> 0 AND
         rw_crapgrv.cdretctr <> 90) THEN
        
        OPEN cr_craprto(pr_cdoperac => vr_tparquiv
                       ,pr_nrtabela => 3
                       ,pr_cdretorn => rw_crapgrv.cdretctr);
        
        FETCH cr_craprto INTO rw_craprto;
        
        IF cr_craprto%NOTFOUND THEN
          vr_dssituac := TRIM(to_char(rw_crapgrv.cdretlot,'999')) || ' - SITUACAO NAO CADASTRADA';
        ELSE
          vr_dssituac := TRIM(to_char(rw_craprto.cdretorn,'999')) || ' - ' || rw_craprto.dsretorn;
        END IF;
        
        --Fecha o cursor
        CLOSE cr_craprto;               
      END IF;
      pr_dscrigrv := vr_dssituac; 
     
    END IF;
    
       
  EXCEPTION   
    WHEN vr_exc_saida THEN
      NULL;     
    -- Críticas tratadas
    WHEN vr_exc_erro THEN
    
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);      
      END IF;
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    -- Críticas nao tratadas
    WHEN OTHERS THEN                                      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na rotina GRVM0001.pc_valida_situacao_gravames -> '||SQLERRM;        
      
      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_compleme => pr_dscritic );      
      
  END pc_valida_situacao_gravames;

    
  -- Procedimento para montagem das informações do Bem a Alienar no Formato XML
  PROCEDURE pc_gera_xml_alienacao(pr_cdcooper IN crapbpr.cdcooper%TYPE -- Cod. Cooperativa
                                 ,pr_nrdconta IN crapbpr.nrdconta%type -- Nr. da conta
                                 ,pr_tpctrato IN crapbpr.tpctrpro%type -- Tp. contrato
                                 ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Nr. contrato
                                 ,pr_idseqbem IN crapbpr.idseqbem%type -- Sequencial do bem
                                 ,pr_flaborta IN VARCHAR2              -- Flag S/N se a operação aborta outras na sequencia em caso de erro
                                 ,pr_flgobrig IN VARCHAR2              -- Flag S/N se a operação é obrigatória para prosseguir para próximo fluxo
                                 /* SistemaNacionalGravames */
                                 ,pr_uflicenc in crapbpr.uflicenc%type -- UF de Licenciamento
                                 ,pr_tpaliena in varchar2              -- Tipo da Alienação
                                 ,pr_dtlibera in crawepr.dtlibera%type -- Data da Liberação
                                 /* ObjetoContratoCredito */
                                 ,pr_dschassi IN crapbpr.dschassi%TYPE -- Chassi
                                 ,pr_tpchassi IN crapbpr.tpchassi%TYPE -- Tipo Chassi
                                 ,pr_ufdplaca IN crapbpr.ufdplaca%TYPE -- UF
                                 ,pr_nrdplaca IN crapbpr.nrdplaca%TYPE -- PLaca
                                 ,pr_nrrenava IN crapbpr.nrrenava%TYPE -- Renavam
                                 ,pr_nranobem IN crapbpr.nranobem%TYPE -- Ano Fabricacao
                                 ,pr_nrmodbem IN crapbpr.nrmodbem%TYPE -- Ano modelo
                                 /* propostaContratoCredito */
                                 ,pr_nrctremp in crawepr.nrctremp%type -- Contrato
                                 ,pr_dtmvtolt in crawepr.dtmvtolt%type -- Data digitação
                                 ,pr_qtpreemp in crawepr.qtpreemp%type -- Quantidade parcelas
                                 ,pr_permulta in craplcr.txmensal%type -- Percentual de Multa
                                 ,pr_txmensal in craplcr.txmensal%type -- Taxa mensal
                                 ,pr_tpemprst IN crapepr.tpemprst%TYPE -- Tipo Emprestimo
                                 ,pr_vlemprst in crawepr.vlemprst%type -- Valor Empréstimo
                                 ,pr_dtdpagto in crawepr.dtdpagto%type -- Data da primeira parcela
                                 ,pr_dtpagfim in crawepr.dtdpagto%type -- Data da ultima parcela
                                 /* Emitente */
                                 ,pr_nrcpfemi IN crapass.nrcpfcgc%TYPE -- CPF/CNPJ Emitente
                                 ,pr_nmemiten IN crapass.nmprimtl%TYPE -- Nome/Razão Social Emitente
                                 ,pr_dsendere IN crapenc.dsendere%TYPE -- Logradouro Emitente
                                 ,pr_nrendere IN crapenc.nrendere%TYPE -- Numero Emitente
                                 ,pr_nmbairro IN crapenc.nmbairro%TYPE -- Nome Bairro Emitente
                                 ,pr_cdufende IN crapenc.cdufende%TYPE -- UF Emitente
                                 ,pr_nrcepend IN crapenc.nrcepend%TYPE -- CEP Emitente
                                 ,pr_cdcidade IN crapmun.cdcidade%TYPE -- Municipio do Cliente
                                 ,pr_nrdddtfc IN craptfc.nrdddtfc%TYPE -- DDD Emitente
                                 ,pr_nrtelefo IN craptfc.nrtelefo%TYPE -- Telefone Emitente
                                  /* Credor */
                                 ,pr_nmcddopa IN crapage.nmcidade%TYPE -- Nome da cidade do PA
                                 ,pr_cdufdopa IN crapage.cdufdcop%TYPE -- UF do PA
                                 ,pr_inpescre IN crapass.inpessoa%TYPE -- Tipo pessoa Credor
                                 ,pr_nrcpfcre IN crapass.nrcpfcgc%TYPE -- CPF/CNPJ Credor
                                 ,pr_dsendcre IN crapenc.dsendere%TYPE -- Logradouro Credor
                                 ,pr_nrendcre IN crapenc.nrendere%TYPE -- Numero Credor
                                 ,pr_nmbaicre IN crapenc.nmbairro%TYPE -- Nome Bairro Credor
                                 ,pr_cdufecre IN crapenc.cdufende%TYPE -- UF Credor
                                 ,pr_nrcepcre IN crapenc.nrcepend%TYPE -- CEP Credor
                                 ,pr_cdcidcre IN crapmun.cdcidade%TYPE -- Municipio do Credor
                                 ,pr_nrdddcre IN craptfc.nrdddtfc%TYPE -- DDD Credor
                                 ,pr_nrtelcre IN craptfc.nrtelefo%TYPE -- Telefone Credor
                                 /* Dados do Vendedor */
                                 ,pr_nrcpfven IN crapass.nrcpfcgc%TYPE -- CPF/CNPJ Vendedor
                                 /* Recebedor do pagamento */
                                 ,pr_inpesrec IN crapass.inpessoa%TYPE -- Tipo Pessoa Vendedor
                                 ,pr_nrcpfrec IN crapass.nrcpfcgc%TYPE -- CPF/CNPJ Vendedor
                                 /* Saida */
                                 ,pr_xmlalien OUT VARCHAR2 -- XML da alienação
                                 ,pr_dscritic OUT VARCHAR2 -- Descrição de critica encontrada
                                 ) IS
  /* ............................................................................

    Programa: pc_gera_xml_alienacao                           
    Autor   : Marcos Martini (Envolti)
    Data    : Outubro/2018                   Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Gerar XML Alienação dos dados enviados

    Alteracoes: 
  ............................................................................ */   
  
    -- Trasnformacao do numero endereço
    vr_dsendere VARCHAR2(100);
    vr_dsendcre VARCHAR2(100);
    vr_dstpempt VARCHAR2(20);
  BEGIN
    
    -- Tratar S/N
    IF nvl(pr_nrendere,0) <> 0 THEN
      vr_dsendere := '<numeroLogradouro>'||pr_nrendere||'</numeroLogradouro>';
    END IF;
    IF nvl(pr_nrendcre,0) <> 0 THEN
      vr_dsendcre := '<numeroLogradouro>'||pr_nrendcre||'</numeroLogradouro>';
    END IF;
  
    -- Escrever no arquivo XML a raiz da listagem do bem
    pr_xmlalien := '<gravame '
                || 'iduriservico="'||vr_urialien||'" '
                || 'cdoperac="1" ' 
                || 'cdcooper="'||pr_cdcooper||'" '
                || 'nrdconta="'||pr_nrdconta||'" '
                || 'tpctrato="'||pr_tpctrato||'" '
                || 'nrctremp="'||pr_nrctrpro||'" '
                || 'idseqbem="'||pr_idseqbem||'" '
                || 'flaborta="'||pr_flaborta||'" flgobrig="'||pr_flgobrig||'">';
                          
    -- Enviar a Cooperativa
    pr_xmlalien := pr_xmlalien 
                ||'<cooperativa><codigo>'||pr_cdcooper||'</codigo></cooperativa>';
    
    -- Enviar informações do SistemaNacionalGravames
    pr_xmlalien := pr_xmlalien 
                ||'<sistemaNacionalGravames>'
                  ||'<tipoInteracao><codigo>'||vr_tpaliena||'</codigo></tipoInteracao>'      
                  ||'<UFRegistro>'||pr_uflicenc||'</UFRegistro>'
                  ||'<tipoRegistro><codigo>'||pr_tpaliena||'</codigo></tipoRegistro>'
                  ||'<dataInteracao>'||to_char(nvl(pr_dtlibera,SYSDATE),'YYYY-MM-DD"T"hh24:mi:ss')||'</dataInteracao>'
                ||'</sistemaNacionalGravames>';
    
    -- Enviar informações do ObjetoContratoCredito
    pr_xmlalien := pr_xmlalien 
                ||'<objetoContratoCredito>'
                  ||'<veiculoChassi>'||pr_dschassi||'</veiculoChassi>'
                  ||'<veiculoChassiRemarcado>'||fn_des_tpchassi(pr_tpchassi)||'</veiculoChassiRemarcado>'
                  ||'<veiculoPlacaUF>'||nvl(pr_ufdplaca,' ')||'</veiculoPlacaUF>'
                  ||'<veiculoPlaca>'||nvl(pr_nrdplaca,' ')||'</veiculoPlaca>'
                  ||'<veiculoRenavam>'||pr_nrrenava||'</veiculoRenavam>'
                  ||'<anoFabricacao>'||pr_nranobem||'</anoFabricacao>'
                  ||'<anoModelo>'||pr_nrmodbem||'</anoModelo>'
                ||'</objetoContratoCredito>';                          
    
    -- Traduzir tp emprestimos
    IF pr_tpemprst = 0 THEN
      vr_dstpempt := 'TR';
    ELSIF pr_tpemprst = 1 THEN
      vr_dstpempt := 'PREFIXADO';
    ELSE
      vr_dstpempt := 'POSFIXADO';
    END IF;
    
    -- Enviar informações do propostaContratoCredito
    pr_xmlalien := pr_xmlalien 
                ||'<propostaContratoCredito>'
                ||'<numeroContrato>'||pr_nrctremp||'</numeroContrato>'
                ||'<data>'||to_char(pr_dtmvtolt,'YYYY-MM-DD')||'</data>'
                ||'<quantidadeParcelas>'||pr_qtpreemp||'</quantidadeParcelas>'
                ||'<multa>'||pr_permulta||'</multa>'
                ||'<valorJurosMoratorios>'||pr_txmensal||'</valorJurosMoratorios>'
                ||'<tipoCalculoJuros><descricao>'||vr_dstpempt||'</descricao></tipoCalculoJuros>'
                ||'<valor>'||pr_vlemprst||'</valor>'
                ||'<dataPrimeiraParcela>'||to_char(pr_dtdpagto,'YYYY-MM-DD')||'</dataPrimeiraParcela>'
                ||'<dataUltimaParcela>'||to_char(pr_dtpagfim,'YYYY-MM-DD')||'</dataUltimaParcela>';

    -- Enviar informações do emitente
    pr_xmlalien := pr_xmlalien 
                ||'<emitente>'
                ||'<identificadorReceitaFederal>'||pr_nrcpfemi||'</identificadorReceitaFederal>'
                ||'<razaoSocialOuNome>'||pr_nmemiten||'</razaoSocialOuNome>'
                  ||'<pessoaContatoEndereco>'
                    ||'<tipoENomeLogradouro>'||pr_dsendere||'</tipoENomeLogradouro>'
                    ||vr_dsendere
                    ||'<nomeBairro>'||pr_nmbairro||'</nomeBairro>'
                    ||'<UF>'||pr_cdufende||'</UF>'
                    ||'<CEP>'||pr_nrcepend||'</CEP>'
                  ||'</pessoaContatoEndereco>'
                  ||'<cidade><codigoMunicipioCETIP>'||pr_cdcidade||'</codigoMunicipioCETIP></cidade>'
                  ||'<pessoaContatoTelefone>'
                    ||'<DDD>'||pr_nrdddtfc||'</DDD>'
                    ||'<numero>'||pr_nrtelefo||'</numero>'
                  ||'</pessoaContatoTelefone>'
                ||'</emitente>'; 
                            
    -- Enviar as informações do Credor
    pr_xmlalien := pr_xmlalien 
                ||'<credor>'
                ||'<contaCorrente><postoAtendimento>'
                  ||'<cidade><descricao>'||pr_nmcddopa||'</descricao></cidade>'
                  ||'<paisSubDivisao><sigla>'||pr_cdufdopa||'</sigla></paisSubDivisao>'
                ||'</postoAtendimento></contaCorrente>'
                ||'<tipo><codigo>'||pr_inpescre||'</codigo></tipo>'
                ||'<identificadorReceitaFederal>'||pr_nrcpfcre||'</identificadorReceitaFederal>'
                ||'<pessoaContatoEndereco>'
                    ||'<tipoENomeLogradouro>'||pr_dsendcre||'</tipoENomeLogradouro>'
                    ||vr_dsendcre
                    ||'<nomeBairro>'||pr_nmbaicre||'</nomeBairro>'
                    ||'<UF>'||pr_cdufecre||'</UF>'
                    ||'<CEP>'||pr_nrcepcre||'</CEP>'
                  ||'</pessoaContatoEndereco>'
                  ||'<cidade><codigoMunicipioCETIP>'||pr_cdcidcre||'</codigoMunicipioCETIP></cidade>'
                  ||'<pessoaContatoTelefone>'
                    ||'<DDD>'||pr_nrdddcre||'</DDD>'
                    ||'<numero>'||pr_nrtelcre||'</numero>'
                  ||'</pessoaContatoTelefone>'
                ||'</credor>';     
    
    -- Encerrar objeto  propostaContratoCredito                       
    pr_xmlalien := pr_xmlalien 
                ||'</propostaContratoCredito>';     
    
    -- Enviar as informações do Vendedor
    --IF nvl(pr_nrcpfven,0) <> 0 THEN
      pr_xmlalien := pr_xmlalien 
                  ||'<representanteVendas>'
                     ||'<identificadorReceitaFederal>'||pr_nrcpfven||'</identificadorReceitaFederal>'
                  ||'</representanteVendas>';
    --END IF;              
    
    -- Enviar as informações do Recebedor
    --IF nvl(pr_inpesrec,0) <> 0 THEN
      pr_xmlalien := pr_xmlalien 
                  ||'<estabelecimentoComercial>'
                     ||'<lojista>'
                        ||'<tipo><codigo>'||pr_inpesrec||'</codigo></tipo>'
                        ||'<identificadorReceitaFederal>'||pr_nrcpfrec||'</identificadorReceitaFederal>'
                     ||'</lojista>'
                  ||'</estabelecimentoComercial>';
    --END IF;
      
    -- Finalizar o XML
    pr_xmlalien := pr_xmlalien 
                ||'</gravame>';
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na montagem de informacoes para Alienacao -> '||SQLERRM;
  END pc_gera_xml_alienacao;
  
  -- Procedimento para montagem das informações do Bem a Consultar a Alienar no Formato XML
  PROCEDURE pc_gera_xml_desalienacao(pr_cdcooper IN crapbpr.cdcooper%TYPE -- Cod. Cooperativa
                                    ,pr_nrdconta IN crapbpr.nrdconta%type -- Nr. da conta
                                    ,pr_tpctrato IN crapbpr.tpctrpro%type -- Tp. contrato
                                    ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Nr. contrato
                                    ,pr_idseqbem IN crapbpr.idseqbem%type -- Sequencial do bem
                                    ,pr_tpdesali IN VARCHAR2              -- Tipo [C]ancelamento ou [B]aixa
                                    ,pr_flaborta IN VARCHAR2              -- Flag S/N se a operação aborta outras na sequencia em caso de erro
                                    ,pr_flgobrig IN VARCHAR2              -- Flag S/N se a operação é obrigatória para prosseguir para próximo fluxo
                                    /* SistemaNacionalGravames */
                                    ,pr_uflicenc IN crapbpr.ufdplaca%TYPE -- UF                                 
                                    /* ObjetoContratoCredito */
                                    ,pr_dschassi IN crapbpr.dschassi%TYPE -- Chassi
                                    ,pr_tpchassi IN crapbpr.tpchassi%TYPE -- Tipo Chassi
                                    ,pr_nrrenava IN crapbpr.nrrenava%TYPE -- Renavam
                                    /* Emitente */
                                    ,pr_nrcpfemi IN crapass.nrcpfcgc%TYPE -- CPF/CNPJ Emitente                                 
                                    /* Saida */
                                    ,pr_xmldesal OUT VARCHAR2 -- XML do Cancelamento de alienação
                                    ,pr_dscritic OUT VARCHAR2 -- Descrição de critica encontrada
                                    ) IS
  /* ............................................................................

    Programa: pc_gera_xml_desalienacao                           
    Autor   : Marcos Martini (Envolti)
    Data    : Outubro/2018                   Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Gerar XML Cancelamento/Baixa Alienação dos dados enviados

    Alteracoes: 
  ............................................................................ */   
    -- Variaveis genéricas
    vr_cdoperac NUMBER;
    vr_uriservc VARCHAR2(100);
    vr_tpservic VARCHAR2(100);    
    
  BEGIN
    
    -- Setar serviço e tipo conforme tipo desalienação
    IF pr_tpdesali = 'C' THEN
      vr_cdoperac := 2;
      vr_uriservc := vr_uricancl;
      vr_tpservic := vr_tpcancel;
    ELSE
      vr_cdoperac := 3;      
      vr_uriservc := vr_uribaixa;
      vr_tpservic := vr_tipbaixa;
    END IF;
  
    -- Escrever no arquivo XML a raiz da listagem do bem
    pr_xmldesal := pr_xmldesal 
                ||'<gravame '
                || 'iduriservico="'||vr_uriservc||'" '
                || 'cdoperac="'||vr_cdoperac||'" ' 
                || 'cdcooper="'||pr_cdcooper||'" '
                || 'nrdconta="'||pr_nrdconta||'" '
                || 'tpctrato="'||pr_tpctrato||'" '
                || 'nrctremp="'||pr_nrctrpro||'" '
                || 'idseqbem="'||pr_idseqbem||'" '
                || 'flaborta="'||pr_flaborta||'" flgobrig="'||pr_flgobrig||'">';
                          
    -- Enviar a Cooperativa
    pr_xmldesal := pr_xmldesal 
                ||'<cooperativa><codigo>'||pr_cdcooper||'</codigo></cooperativa>';
    
    -- Enviar informações do SistemaNacionalGravames
    pr_xmldesal := pr_xmldesal 
                ||'<sistemaNacionalGravames>'
                  ||'<tipoInteracao><codigo>'||vr_tpservic||'</codigo></tipoInteracao>'                            
                  ||'<UFRegistro>'||pr_uflicenc||'</UFRegistro>'
                ||'</sistemaNacionalGravames>';
    
    -- Enviar informações do ObjetoContratoCredito
    pr_xmldesal := pr_xmldesal 
                ||'<objetoContratoCredito>'
                  ||'<veiculoChassi>'||pr_dschassi||'</veiculoChassi>'
                  ||'<veiculoChassiRemarcado>'||fn_des_tpchassi(pr_tpchassi)||'</veiculoChassiRemarcado>'                            
                  ||'<veiculoRenavam>'||pr_nrrenava||'</veiculoRenavam>'
                ||'</objetoContratoCredito>';
                          
    -- Enviar informações do emitente
    pr_xmldesal := pr_xmldesal 
                ||'<propostaContratoCredito><emitente>'
                   ||'<identificadorReceitaFederal>'||pr_nrcpfemi||'</identificadorReceitaFederal>'
                ||'</emitente></propostaContratoCredito>';   
                              
    -- Finalizar o XML
    pr_xmldesal := pr_xmldesal 
                ||'</gravame>';
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na montagem de informacoes para Desalienação -> '||SQLERRM;
  END pc_gera_xml_desalienacao;  
  
  -- Procedimento para montagem das informações do Bem a Consultar a Alienar no Formato XML
  PROCEDURE pc_gera_xml_cons_alienac(pr_cdcooper IN crapbpr.cdcooper%TYPE -- Cod. Cooperativa
                                    ,pr_nrdconta IN crapbpr.nrdconta%type -- Nr. da conta
                                    ,pr_tpctrato IN crapbpr.tpctrpro%type -- Tp. contrato
                                    ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Nr. contrato
                                    ,pr_idseqbem IN crapbpr.idseqbem%type -- Sequencial do bem
                                    /* SistemaNacionalGravames */
                                    ,pr_uflicenc IN crapbpr.ufdplaca%TYPE -- UF                                 
                                    /* ObjetoContratoCredito */
                                    ,pr_dschassi IN crapbpr.dschassi%TYPE -- Chassi
                                    ,pr_tpchassi IN crapbpr.tpchassi%TYPE -- Tipo Chassi
                                    /* Saida */
                                    ,pr_xmlconsu OUT VARCHAR2 -- XML da Consulta de alienação
                                    ,pr_dscritic OUT VARCHAR2 -- Descrição de critica encontrada
                                    ) IS
  /* ............................................................................

    Programa: pc_gera_xml_cons_alienac                           
    Autor   : Marcos Martini (Envolti)
    Data    : Outubro/2018                   Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Gerar XML Consulta Alienação do Contrato

    Alteracoes: 
  ............................................................................ */   

  BEGIN
    -- Escrever no arquivo XML a raiz da listagem do bem
    pr_xmlconsu := '<gravame '
                || 'iduriservico="'||vr_uriconsl||'" '
                || 'cdoperac="4" ' 
                || 'cdcooper="'||pr_cdcooper||'" '
                || 'nrdconta="'||pr_nrdconta||'" '
                || 'tpctrato="'||pr_tpctrato||'" '
                || 'nrctremp="'||pr_nrctrpro||'" '
                || 'idseqbem="'||pr_idseqbem||'" '
                || 'idpriori="5" flgobrig="N">';

    -- Enviar a Cooperativa
    pr_xmlconsu := pr_xmlconsu 
                ||'<cooperativa><codigo>'||pr_cdcooper||'</codigo></cooperativa>';
    
    -- Enviar informações do SistemaNacionalGravames
    pr_xmlconsu := pr_xmlconsu 
                ||'<sistemaNacionalGravames>'
                  ||'<UFRegistro>'||pr_uflicenc||'</UFRegistro>'
                ||'</sistemaNacionalGravames>';
                          
    -- Enviar informações do ObjetoContratoCredito
    pr_xmlconsu := pr_xmlconsu 
                ||'<objetoContratoCredito>'
                  ||'<veiculoChassi>'||pr_dschassi||'</veiculoChassi>'
                  ||'<veiculoChassiRemarcado>'||fn_des_tpchassi(pr_tpchassi)||'</veiculoChassiRemarcado>'
                ||'</objetoContratoCredito>';
    
    -- Finalizar o XML
    pr_xmlconsu := pr_xmlconsu 
                ||'</gravame>';
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na montagem de informacoes para Consulta de Alienacao -> '||SQLERRM;
  END pc_gera_xml_cons_alienac;   
  
  -- Gravação das informações de comunicação e atualização da situação do Gravames
  procedure pc_grava_aciona_gravame(pr_cdcooper IN crapbpr.cdcooper%type -- Cód. cooperativa
                                   ,pr_nrdconta IN crapbpr.nrdconta%type -- Nr. da conta
                                   ,pr_tpctrato IN crapbpr.tpctrpro%type -- Tp. contrato
                                   ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Nr. contrato
                                   ,pr_idseqbem IN crapbpr.idseqbem%type -- Sequencial do bem
                                   ,pr_cdoperac IN crapgrv.cdoperac%type -- Tipo da Operação
                                     
                                   ,pr_dschassi IN crapbpr.dschassi%type -- Chassi do veículo
                                   ,pr_dscatbem IN crapbpr.dscatbem%type -- Categoria do bem financiado (ex. automovel, casa, maquina, etc).
                                   ,pr_dstipbem IN crapbpr.dstipbem%type -- Descricao do tipo do bem
                                   ,pr_dsmarbem IN crapbpr.dsmarbem%type -- Marca do Bem (Somente para Auto, Moto e Caminhao)
                                   ,pr_dsbemfin IN crapbpr.dsbemfin%type -- Descricao do bem a ser financiado.
                                   ,pr_nrcpfbem IN crapbpr.nrcpfbem%type -- CPF/CNPJ do Proprietario do Bem
                                   ,pr_tpchassi IN crapbpr.tpchassi%type -- Tipo de chassi do veiculo (1-Remarcado, 2-Normal)
                                   ,pr_uflicenc IN crapbpr.uflicenc%type -- UF (ESTADO) do licenciamento do veiculo.
                                   ,pr_nranobem IN crapbpr.nranobem%type -- Ano do bem financiado.
                                   ,pr_nrmodbem IN crapbpr.nrmodbem%type -- Modelo do bem financiado.
                                   ,pr_ufdplaca IN crapbpr.ufdplaca%type -- Unidade da Federacao (ESTADO) da placa do veiculo.
                                   ,pr_nrdplaca IN crapbpr.nrdplaca%type -- Numero da placa do bem financiado.
                                   ,pr_nrrenava IN crapbpr.nrrenava%type -- Numero do RENAVAN do veiculo.
                                     
                                   ,pr_dtenvgrv IN crapgrv.dtenvgrv%type  -- Data envio GRAVAME
                                   ,pr_dtretgrv IN crapgrv.dtretgrv%type  -- Data retorno GRAVAME      
                                   ,pr_cdretgrv IN crapgrv.cdretgrv%TYPE  -- Codigo retorno Gravame
                                   ,pr_cdretctr IN crapgrv.cdretctr%TYPE  -- Codigo retorno Contrato
                                   ,pr_nrgravam IN crapbpr.nrgravam%TYPE  -- Numero gravame gerado                                   
                                   ,pr_idregist IN crapgrv.idregist%TYPE  -- Numero do GRAVAME/Registro gerado
                                   ,pr_dtregist IN crapgrv.dtregist%TYPE  -- Data do GRAVAME/Registro gerado
                                   ,pr_dserrcom IN crapgrv.dscritic%TYPE  -- Descricao de critica encontrada durante processo de comunicacao.
                                   ,pr_flsituac IN varchar2               -- Indica se deve atualizar situação (S ou N)
                                   ,pr_dsretreq IN CLOB DEFAULT NULL      -- CLOB que contem o retorno da requisição no SOA
                                   ,pr_cdoperad IN VARCHAR2 DEFAULT NULL  -- Usuário para registro de LOG
                                   ,pr_idorigem IN NUMBER   DEFAULT NULL  -- Origem para o log
                                   
                                   ,pr_dscritic OUT VARCHAR2) IS         -- Critica encontrada durante execução desta rotina
                                   
      PRAGMA AUTONOMOUS_TRANSACTION;
    -- ..........................................................................
    --
    --  Programa : pc_grava_aciona_gravame            

    --  Sistema  : Rotinas genericas para GRAVAME
    --  Sigla    : GRVM
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2018                    Ultima Atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --  Objetivo  : Gravação das informações de comunicação e atualização da situação do Gravames
    --
    --  Alteracoes: 
    --         18/06/2019 - Inclusão dos logs para inclusão automatica no gravames (Renato - Supero - P422.1)
    --   

    -- Tratamento de saida
    vr_dscritic VARCHAR2(4000);
    vr_excsaida EXCEPTION;
    -- Campos temporarios
    vr_dtatugrv DATE;
    vr_dschassi crapbpr.dschassi%TYPE;
    vr_dscatbem crapbpr.dscatbem%TYPE;
    vr_dstipbem crapbpr.dstipbem%type;
    vr_dsmarbem crapbpr.dsmarbem%type;
    vr_dsbemfin crapbpr.dsbemfin%type;
    vr_nrcpfbem crapbpr.nrcpfbem%type;
    vr_tpchassi crapbpr.tpchassi%type;
    vr_uflicenc crapbpr.uflicenc%type;
    vr_nranobem crapbpr.nranobem%type;
    vr_nrmodbem crapbpr.nrmodbem%type;
    vr_ufdplaca crapbpr.ufdplaca%type;
    vr_nrdplaca crapbpr.nrdplaca%type;
    vr_nrrenava crapbpr.nrrenava%TYPE;

    -- Buscar dados do bem
    CURSOR cr_crapbpr IS
      SELECT dschassi
            ,dscatbem
            ,dstipbem
            ,dsmarbem
            ,dsbemfin
            ,nrcpfbem
            ,tpchassi
            ,uflicenc
            ,nranobem
            ,nrmodbem
            ,ufdplaca
            ,nrdplaca
            ,nrrenava
			,bpr.cdsitgrv
            ,bpr.nrgravam
            ,bpr.dtatugrv
        FROM crapbpr bpr
       WHERE bpr.cdcooper = pr_cdcooper
         AND bpr.nrdconta = pr_nrdconta
         AND bpr.nrctrpro = pr_nrctrpro
         AND bpr.tpctrpro = pr_tpctrato
         AND bpr.idseqbem = pr_idseqbem;
    rw_crapbpr cr_crapbpr%ROWTYPE;
    
    vr_nrdrowid   VARCHAR2(50);
    
  begin
	  --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => 'GRVM0001', pr_action => 'GRVM0001.pc_grava_aciona_gravame');

    -- Caso tenha sido solicitado a gravação da situação
    IF pr_flsituac = 'S' THEN
      -- Em caso de sucesso em ambos
      IF (pr_cdretgrv = 30 AND pr_cdretctr = 100) 
      -- Sucesso GRV - nada CTR  
      OR (pr_cdretgrv = 30 AND pr_cdretctr = 0) 
      -- Nada GRV - Sucesso CTR
      OR (pr_cdretgrv = 0 AND pr_cdretctr = 100) THEN 

        -- Data de atualização, caso venha zerada, receberá sysdate
        IF pr_dtregist IS NULL THEN              
          vr_dtatugrv := SYSDATE;
        ELSE
          vr_dtatugrv := pr_dtregist;
    END IF;

        -- Conforme o tipo da operação                
        IF pr_cdoperac IN (1,4) THEN
          -- Numero do GRAVAME é obrigatório
          IF pr_nrgravam IS NULL THEN
            vr_dscritic := 'Identificador do Gravame obrigatorio para operacoes de Inclusao com Sucesso!';
            RAISE vr_excsaida;
          END IF;
          -- Data de atualização, caso venha zerada, receberá sysdate
          IF pr_dtregist IS NULL THEN              
            vr_dtatugrv := SYSDATE;
          ELSE
            vr_dtatugrv := pr_dtregist;
          END IF;  
          
          -- Buscar dados atuais antes da atualização para log
          OPEN  cr_crapbpr;
          FETCH cr_crapbpr INTO rw_crapbpr;
          CLOSE cr_crapbpr;
          
          -- Buscar a data do sistema
          OPEN  btch0001.cr_crapdat(pr_cdcooper);
          FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
          CLOSE btch0001.cr_crapdat;
          
          -- Atualizar situação
          BEGIN
            UPDATE crapbpr bpr
               SET bpr.cdsitgrv = 2   -- Alienado OK
                  ,bpr.tpinclus = 'A' -- Automatico   
                  ,bpr.dtatugrv = vr_dtatugrv
                  ,bpr.nrgravam = pr_nrgravam
                  ,bpr.flgalfid = 1 -- Alienado
                  ,bpr.flginclu = 0 -- Baixa da pendencia de inclusão
                  ,bpr.dsjstinc = NULL -- Limpar alguma justificativa manual anterior
             WHERE bpr.cdcooper = pr_cdcooper
               AND bpr.nrdconta = pr_nrdconta
               AND bpr.tpctrpro = pr_tpctrato
               AND bpr.nrctrpro = pr_nrctrpro
               AND bpr.idseqbem = pr_idseqbem;
          EXCEPTION
            WHEN OTHERS THEN
               vr_dscritic := 'Erro ao atualizar o registro de bens da prospota [crapbpr] -> '||SQLERRM;
               RAISE vr_excsaida;
          END;       
          -- Setar no Contrato que o GRAVAMES está OK caso não haja outro bem não alieanado
          BEGIN        
            UPDATE crawepr wpr
               SET wpr.flgokgrv = 1       
             WHERE wpr.cdcooper = pr_cdcooper
               AND wpr.nrdconta = pr_nrdconta
               AND wpr.nrctremp = pr_nrctrpro
               AND NOT EXISTS(SELECT 1
                                FROM crapbpr bpr
                               WHERE bpr.cdcooper = wpr.cdcooper
                                 AND bpr.nrdconta = wpr.nrdconta
                                 AND bpr.nrctrpro = wpr.nrctremp
                                 AND bpr.tpctrpro = 90
                                 AND bpr.flgalien = 1
                                 AND bpr.cdsitgrv <> 2);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic:= 'Nao foi possivel alterar a proposta[crawepr] para Gravame OK:'||SQLERRM;
              -- Levantar Excecao  
              RAISE vr_excsaida; 
          END;  
          
          -- Geração de LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad 
                              ,pr_dscritic => ''         
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                              ,pr_dstransa => 'Inclusao automatica do bem no gravames'
                              ,pr_dttransa => TRUNC(btch0001.rw_crapdat.dtmvtolt)
                              ,pr_flgtrans => 1
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => 'GRVM0001'
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                    pr_nmdcampo => 'Situacao', 
                                    pr_dsdadant => to_char(rw_crapbpr.cdsitgrv), 
                                    pr_dsdadatu => '2');

          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                    pr_nmdcampo => 'Nr.Gravam', 
                                    pr_dsdadant => to_char(rw_crapbpr.nrgravam), 
                                    pr_dsdadatu => to_char(pr_nrgravam));
                   
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                    pr_nmdcampo => 'Data Atualização', 
                                    pr_dsdadant => to_char(rw_crapbpr.dtatugrv), 
                                    pr_dsdadatu => to_char(vr_dtatugrv));
                          
        -- Baixa   
        ELSIF pr_cdoperac = 3 THEN
          BEGIN
            UPDATE crapbpr bpr
               SET bpr.cdsitgrv = 4   -- Baixado OK
                  ,bpr.tpdbaixa = 'A' -- Automatico   
                  ,bpr.dtdbaixa = vr_dtatugrv 
                  ,bpr.flgbaixa = 0   -- Baixa da pendente de baixa
                  ,bpr.flcancel = 0   -- Baixa de possivel pendencia de Cancelamento
                  ,bpr.flginclu = 0   -- Baixa da pendencia de inclusao                  
                  ,bpr.dsjstbxa = NULL -- Limpar alguma justificativa manual anterior
                  ,bpr.dsjuscnc = NULL -- Limpar alguma justificativa manual anterior
             WHERE bpr.cdcooper = pr_cdcooper
               AND bpr.nrdconta = pr_nrdconta
               AND bpr.tpctrpro = pr_tpctrato
               AND bpr.nrctrpro = pr_nrctrpro
               AND bpr.idseqbem = pr_idseqbem;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar o registro de bens da prospota [crapbpr] -> '||SQLERRM;
              RAISE vr_excsaida;
          END; 
        -- Cancelamento                
        ELSIF pr_cdoperac = 2 THEN
          BEGIN
            UPDATE crapbpr bpr
               SET bpr.cdsitgrv = 5           -- Cancelado OK
                  ,bpr.tpcancel = 'A'         -- Automático                  
                  ,bpr.dtcancel = vr_dtatugrv -- Data do cancelamento
                  ,bpr.flcancel = 0           -- Baixa da pendencia de cancelamento
                  ,bpr.flginclu = 0           -- Baixa da pendencia de inclusão
                  ,bpr.dsjstbxa = NULL -- Limpar alguma justificativa manual e anterior
                  ,bpr.dsjuscnc = NULL -- Limpar alguma justificativa manual anterior                  
             WHERE bpr.cdcooper = pr_cdcooper
               AND bpr.nrdconta = pr_nrdconta
               AND bpr.tpctrpro = pr_tpctrato
               AND bpr.nrctrpro = pr_nrctrpro
               AND bpr.idseqbem = pr_idseqbem;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar o registro de bens da prospota [crapbpr] -> '||SQLERRM;                                      
              RAISE vr_excsaida;
          END;       
        END IF;      
      ELSE
        -- Erro na alienação
        BEGIN                          
          UPDATE crapbpr bpr
             SET bpr.cdsitgrv = 3 --Retorno com erro
           WHERE bpr.cdcooper = pr_cdcooper
             AND bpr.nrdconta = pr_nrdconta
             AND bpr.tpctrpro = pr_tpctrato
             AND bpr.nrctrpro = pr_nrctrpro
             AND bpr.idseqbem = pr_idseqbem;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar o registro de bens da prospota [crapbpr] -> '||SQLERRM; 
            RAISE vr_excsaida;
        END; 
      END IF;
    END IF;  

    -- Buscar dados do bem
    IF pr_idseqbem > 0 THEN
      OPEN cr_crapbpr;
      FETCH cr_crapbpr
        INTO rw_crapbpr;
      CLOSE cr_crapbpr;

      -- Usar primordialmente dos parâmetros, se não tiver, usa da tabela
      vr_dschassi := nvl(pr_dschassi,rw_crapbpr.dschassi);
      vr_dscatbem := nvl(pr_dscatbem,rw_crapbpr.dscatbem);
      vr_dstipbem := nvl(pr_dstipbem,rw_crapbpr.dstipbem);
      vr_dsmarbem := nvl(pr_dsmarbem,rw_crapbpr.dsmarbem);
      vr_dsbemfin := nvl(pr_dsbemfin,rw_crapbpr.dsbemfin);
      vr_nrcpfbem := nvl(pr_nrcpfbem,rw_crapbpr.nrcpfbem);
      vr_tpchassi := nvl(pr_tpchassi,rw_crapbpr.tpchassi);
      vr_uflicenc := nvl(pr_uflicenc,rw_crapbpr.uflicenc);
      vr_nranobem := nvl(pr_nranobem,rw_crapbpr.nranobem);
      vr_nrmodbem := nvl(pr_nrmodbem,rw_crapbpr.nrmodbem);
      vr_ufdplaca := nvl(pr_ufdplaca,rw_crapbpr.ufdplaca);
      vr_nrdplaca := nvl(pr_nrdplaca,rw_crapbpr.nrdplaca);
      vr_nrrenava := nvl(pr_nrrenava,rw_crapbpr.nrrenava);
    ELSE
      -- Usar dos parâmetros
      vr_dschassi := pr_dschassi;
      vr_dscatbem := pr_dscatbem;
      vr_dstipbem := pr_dstipbem;
      vr_dsmarbem := pr_dsmarbem;
      vr_dsbemfin := pr_dsbemfin;
      vr_nrcpfbem := nvl(pr_nrcpfbem,0);
      vr_tpchassi := pr_tpchassi;
      vr_uflicenc := pr_uflicenc;
      vr_nranobem := pr_nranobem;
      vr_nrmodbem := pr_nrmodbem;
      vr_ufdplaca := NVL(pr_ufdplaca,' ');
      vr_nrdplaca := NVL(pr_nrdplaca,' ');
      vr_nrrenava := pr_nrrenava;
      END IF;

    -- GRavação da tabela de histórico, feito independente de sucesso ou não 
      BEGIN
      --
      INSERT INTO crapgrv
                 (cdcooper
                 ,nrdconta
                 ,tpctrpro
                 ,nrctrpro
                 ,dschassi
                 ,idseqbem
                 ,idregist
                 ,dtregist
                 ,cdoperac
                 ,cdretlot
                 ,cdretgrv
                 ,cdretctr
                 ,dtenvgrv
                 ,dtretgrv
                 ,dscatbem
                 ,dstipbem
                 ,dsmarbem
                 ,dsbemfin
                 ,nrcpfbem
                 ,tpchassi
                 ,uflicenc
                 ,nranobem
                 ,nrmodbem
                 ,ufdplaca
                 ,nrdplaca
                 ,nrrenava
                 ,dscritic)
           VALUES(pr_cdcooper   --cdcooper
                 ,pr_nrdconta   --nrdconta
                 ,pr_tpctrato   --tpctrpro
                 ,pr_nrctrpro   --nrctrpro
                 ,Vr_dschassi   --dschassi
                 ,pr_idseqbem   --idseqbem
                 ,nvl(pr_idregist,0)   --idregist
                 ,pr_dtregist   --dtregist
                 ,pr_cdoperac   --cdoperac
                 ,0             --cdretlot
                 ,pr_cdretgrv   --cdretgrv 
                 ,pr_cdretctr   --cdretctr
                 ,pr_dtenvgrv   --dtenvgrv
                 ,pr_dtretgrv   --dtretgrv  
                 ,vr_dscatbem   --dscatbem
                 ,vr_dstipbem   --dstipbem
                 ,vr_dsmarbem   --dsmarbem
                 ,vr_dsbemfin   --dsbemfin
                 ,vr_nrcpfbem   --nrcpfbem
                 ,vr_tpchassi   --tpchassi
                 ,vr_uflicenc   --uflicenc
                 ,vr_nranobem   --nranobem
                 ,vr_nrmodbem   --nrmodbem
                 ,vr_ufdplaca   --ufdplaca
                 ,vr_nrdplaca   --nrdplaca
                 ,vr_nrrenava   --nrrenava
                 ,NVL(gene0007.fn_caract_acento(pr_dserrcom),' ') --dscritic
                 );
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao criar o registro de gravame [crapgrv] -> '||SQLERRM;                                      
        RAISE vr_excsaida;
      END;

    -- GRavar informações pendentes
    COMMIT;

  EXCEPTION
    WHEN vr_excsaida THEN
      -- Propagar critica
      pr_dscritic:= vr_dscritic;
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Mensagem
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - GRVM0001 --> '|| 
                                                    'ALERTA: '|| pr_dscritic ||
                                                    ',Cdcooper:'||pr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Nrctrpro:'||pr_nrctrpro);
      -- Desfazer
      ROLLBACK;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado na grvm0001.pc_grava_aciona_gravame --> '|| SQLERRM;

        --Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - GRVM0001 --> '|| 
                                                      'ERRO: ' || pr_dscritic  ||
                                                      ',Cdcooper:'||pr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Nrctrpro:'||pr_nrctrpro);
        --Inclusão na tabela de erros Oracle
        CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper
                                     ,pr_compleme => pr_dscritic );
      -- Desfazer
      ROLLBACK;                                   
  END pc_grava_aciona_gravame;
  
  PROCEDURE pc_grava_aciona_gravame_web(pr_nrdconta IN crapbpr.nrdconta%type -- Nr. da conta
                                       ,pr_tpctrato IN crapbpr.tpctrpro%type -- Tp. contrato
                                       ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Nr. contrato
                                       ,pr_idseqbem IN crapbpr.idseqbem%type -- Sequencial do bem
                                       ,pr_cdoperac IN crapgrv.cdoperac%type -- Tipo da Operação
                                         
                                       ,pr_dschassi IN crapbpr.dschassi%type -- Chassi do veículo
                                       ,pr_dscatbem IN crapbpr.dscatbem%type -- Categoria do bem financiado (ex. automovel, casa, maquina, etc).
                                       ,pr_dstipbem IN crapbpr.dstipbem%type -- Descricao do tipo do bem
                                       ,pr_dsmarbem IN crapbpr.dsmarbem%type -- Marca do Bem (Somente para Auto, Moto e Caminhao)
                                       ,pr_dsbemfin IN crapbpr.dsbemfin%type -- Descricao do bem a ser financiado.
                                       ,pr_nrcpfbem IN crapbpr.nrcpfbem%type -- CPF/CNPJ do Proprietario do Bem
                                       ,pr_tpchassi IN crapbpr.tpchassi%type -- Tipo de chassi do veiculo (1-Remarcado, 2-Normal)
                                       ,pr_uflicenc IN crapbpr.uflicenc%type -- UF (ESTADO) do licenciamento do veiculo.
                                       ,pr_nranobem IN crapbpr.nranobem%type -- Ano do bem financiado.
                                       ,pr_nrmodbem IN VARCHAR2              -- Modelo do bem financiado.
                                       ,pr_ufdplaca IN crapbpr.ufdplaca%type -- Unidade da Federacao (ESTADO) da placa do veiculo.
                                       ,pr_nrdplaca IN crapbpr.nrdplaca%type -- Numero da placa do bem financiado.
                                       ,pr_nrrenava IN crapbpr.nrrenava%type -- Numero do RENAVAN do veiculo.                                         
                       
                                       ,pr_dtenvgrv IN VARCHAR2               -- Data envio GRAVAME
                                       ,pr_dtretgrv IN VARCHAR2               -- Data retorno GRAVAME
                                       ,pr_chttpsoa IN VARCHAR2               -- HTTP Code da request
                                       ,pr_dsmsgsoa IN VARCHAR2               -- Tah MSG SOA
                                       ,pr_nrcodsoa IN VARCHAR2               -- Tag Code SOA
                                       ,pr_cdtypsoa IN VARCHAR2               -- Tag Type SOA
                                       ,pr_cdlegsoa IN VARCHAR2               -- Tag LegacyCode SOA

                                       ,pr_nrgravam IN crapbpr.nrgravam%TYPE  -- Numero gravame gerado                                   
                                       ,pr_idregist IN crapgrv.idregist%TYPE  -- Numero do GRAVAME/Registro gerado
                                       ,pr_dtregist IN VARCHAR2               -- Data do GRAVAME/Registro gerado
                                       ,pr_flsituac IN varchar2               -- Indica se deve atualizar situação (S ou N)
  
                                       -- Mensageria
                                       ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2) IS         --Saida OK/NOK
                            
  -- ..........................................................................
    --
    --  Programa : pc_grava_aciona_gravame_web          

    --  Sistema  : Rotinas genericas para GRAVAME
    --  Sigla    : GRVM
    --  Autor    : Marcos Martini
    --  Data     : Outubro/2018                    Ultima Atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --  Objetivo  : Gravação das informações de comunicação e atualização da situação do Gravames
    --
    --  Alteracoes: 
    --                            
                     
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);    
    
    -- Separação retornos SOA
    vr_cdretgrv crapgrv.cdretgrv%TYPE;
    vr_cdretctr crapgrv.cdretctr%TYPE;
    vr_dserrcom crapgrv.dscritic%TYPE;
    
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';
    
  BEGIN
    
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_grava_aciona_gravame_web');
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
    
    -- Inicializar as variáveis :
    vr_dserrcom := '';
    vr_cdretgrv := 0;
    vr_cdretctr := 0;
    
    -- Se sucesso
    IF pr_chttpsoa = '200' THEN
      vr_cdretgrv := 30;
      -- Se é operação de inclusão
      IF pr_cdoperac = 1 THEN
        vr_cdretctr := 100;
      -- Se é operação de Consulta
      ELSIF pr_cdoperac = 4 THEN
        -- Testar se houve alienação
        IF nvl(pr_nrgravam,0) = 0 OR pr_flsituac = 'N' THEN
          -- Iremos usar um código que indica que houve erro na consulta
          -- para não confundir o operador 
          vr_cdretgrv := 500;
        END IF;
      END IF;
    ELSE
      -- Houve erro 
      vr_dserrcom := pr_cdtypsoa||pr_nrcodsoa||'-'||pr_dsmsgsoa;
      IF vr_dserrcom = '-' THEN
        vr_dserrcom := 'Erro nao tratado - nao recebido mensagem de erro corretamente pelo Aimaro';
      END IF;
      -- Tratamento conforme tipo erro (Em bloco para em caso de erro, não parar o processo)
      BEGIN
        IF pr_cdtypsoa = 'B' THEN
          -- Se “code” retornado do SOA = 2003 Então
          IF pr_nrcodsoa = '2003' THEN
            vr_cdretctr := pr_cdlegsoa;
          ELSE  
            -- Tratar “LegacyCode” retorno do SOA:
            IF instr(pr_cdlegsoa,'|') > 0 THEN
              -- GRV é a primeira posiçaõ e CTR a segunda
              vr_cdretgrv := gene0002.fn_busca_entrada(1,pr_cdlegsoa,'|');
              vr_cdretctr := gene0002.fn_busca_entrada(2,pr_cdlegsoa,'|');
            ELSE
              -- Existirá apenas GRV
              vr_cdretgrv := pr_cdlegsoa;
            END IF;  
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dserrcom := vr_dserrcom || ' + Erro no tratamento do legacyCode: '||pr_cdlegsoa;
      END;  
    END IF;
       
    -- Direcionar para a chamada da rotina de gravação
    pc_grava_aciona_gravame(pr_cdcooper => vr_cdcooper -- Cód. cooperativa
                           ,pr_nrdconta => pr_nrdconta -- Nr. da conta
                           ,pr_tpctrato => pr_tpctrato -- Tp. contrato
                           ,pr_nrctrpro => pr_nrctrpro -- Nr. contrato
                           ,pr_idseqbem => pr_idseqbem -- Sequencial do bem
                           ,pr_cdoperac => pr_cdoperac -- Tipo da Operação 
                                                       
                           ,pr_dschassi => pr_dschassi -- Chassi do veículo
                           ,pr_dscatbem => pr_dscatbem -- Categoria do bem financiado (ex. automovel, casa, maquina, etc).
                           ,pr_dstipbem => pr_dstipbem -- Descricao do tipo do bem
                           ,pr_dsmarbem => pr_dsmarbem -- Marca do Bem (Somente para Auto, Moto e Caminhao)
                           ,pr_dsbemfin => pr_dsbemfin -- Descricao do bem a ser financiado.
                           ,pr_nrcpfbem => pr_nrcpfbem -- CPF/CNPJ do Proprietario do Bem
                           ,pr_tpchassi => pr_tpchassi -- Tipo de chassi do veiculo (1-Remarcado, 2-Normal)
                           ,pr_uflicenc => pr_uflicenc -- UF (ESTADO) do licenciamento do veiculo.
                           ,pr_nranobem => pr_nranobem -- Ano do bem financiado.
                           ,pr_nrmodbem => substr(pr_nrmodbem,1,4) -- Modelo do bem financiado.
                           ,pr_ufdplaca => pr_ufdplaca -- Unidade da Federacao (ESTADO) da placa do veiculo.
                           ,pr_nrdplaca => pr_nrdplaca -- Numero da placa do bem financiado.
                           ,pr_nrrenava => pr_nrrenava -- Numero do RENAVAN do veiculo.
                           
                           ,pr_cdretgrv => vr_cdretgrv -- Codigo retorno Gravame
                           ,pr_cdretctr => vr_cdretctr -- Codigo retorno Contrato
                           ,pr_nrgravam => pr_nrgravam -- Numero Gravame                           
                           ,pr_dtenvgrv => TO_DATE(pr_dtenvgrv,'DD/MM/RRRR HH24:MI:SS') -- Data envio GRAVAME
                           ,pr_dtretgrv => TO_DATE(pr_dtretgrv,'DD/MM/RRRR HH24:MI:SS') -- Data retorno GRAVAME      
                           ,pr_idregist => nvl(pr_idregist,0) -- Numero do GRAVAME/Registro gerado
                           ,pr_dtregist => TO_DATE(pr_dtregist,'DD/MM/RRRR HH24:MI:SS') -- Data do GRAVAME/Registro gerado   
                           ,pr_dserrcom => vr_dserrcom -- Descricao de critica encontrada durante processo de comunicacao.
                           ,pr_flsituac => pr_flsituac -- Indica se deve atualizar situação (S ou N)
                           ,pr_cdoperad => vr_cdoperad -- Operador
                           ,pr_idorigem => vr_idorigem -- Origem
                           
                           ,pr_dscritic => vr_dscritic);          -- Critica encontrada durante execução desta rotina);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
                        
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            

        --Inclusão dos parâmetros apenas na exception, para não mostrar na tela - Chamado 660356
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- Mensagem
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ALERTA: ' ||pr_dscritic ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Dtmvtolt:'||trunc(pr_dtenvgrv)||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Nrdconta:'||pr_nrdconta);

    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_grava_aciona_gravame_web --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
      --Inclusão dos parâmetros apenas na exception, para não mostrar na tela
      --Padronização - Chamado 660394
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ERRO: ' || pr_dscritic  ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Dtmvtolt:'||trunc(pr_dtenvgrv)||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Nrdconta:'||pr_nrdconta);

      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
   
  END pc_grava_aciona_gravame_web;  
  
  
  /* Manutenção do arquivo de Baixa ou Cancelamento do GRAVAMES */
  PROCEDURE pc_gravames_gerac_arqs_bxa_cnc(pr_flgfirst        IN BOOLEAN                       --> Flag de primeiro registro
                                          ,pr_fllastof        IN BOOLEAN                       --> Flag de ultimo registro
                                          ,pr_reg_dado_arquiv IN typ_reg_dados_arquivo         --> Registro com as informações atuais
                                          ,pr_clobaux         IN OUT NOCOPY VARCHAR2           --> Varchar2 de Buffer para o arquivo
                                          ,pr_clobarq         IN OUT NOCOPY CLOB               --> CLOB para as informações do arquivo
                                          ,pr_nrseqreg        IN OUT NUMBER                    --> Sequncial das informações
                                          ,pr_cdcooper        IN crapcob.cdcooper%type         --> Codigo da cooperativa
                                          ,pr_dscritic         OUT VARCHAR2) IS                 --> Saida de erro
  /* .............................................................................
     Programa: pc_gravames_gerac_arqs_bxa_cnc          Antigos: b1wgen0171.p/gravames_geracao_arquivo_baixa e gravames_geracao_arquivo_cancelamento
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Guilherme/SUPERO
     Data    : Agosto/2013                     Ultima atualizacao:  29/05/2017

     Dados referentes ao programa:

     Frequencia:  Diario (on-line)
     Objetivo  : Gerar arquivos GRAVAMES - Baixa e Cancelamento

     Alteracoes: 05/11/2014 - Conversão Progress para Oracle (Marcos-Supero)
     
                 29/05/2017 - Padronização das mensagens para a tabela tbgen_prglog,
                            - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
                            - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
                            - Incluir nome do módulo logado em variável
                            - Inclusão do parâmetro pr_cdcooper para não gravar 0 na gera_log_batch
                              (Ana - Envolti) - SD: 660356 e 660394
    ............................................................................. */
  BEGIN
    DECLARE
      vr_set_linha VARCHAR2(32767); --> Auxiliar para montagem da linha

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';

    BEGIN
	    --Incluir nome do módulo logado - Chamado 660394
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_gerac_arqs_bxa_cnc');

      -- Para o primeiro registro
      IF pr_flgfirst THEN
        -- Inicializar contador registros
        pr_nrseqreg := 1;
        -- ****** HEADER CONTROLE ARQUIVO  *******
        -- Header conforme o codigo da financeira do gravames da coop
        IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
        ELSE
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
        END IF;
        -- Restante do Header
        vr_set_linha := vr_set_linha
                     || '000        00000000000000HEADER DE CONTROLE   '
                     || rpad(' ',34,' ')
                     || rpad(' ',3,' ')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                     || rpad(' ',14,' ')
                     || '*'
                     || chr(10); --Quebra
        -- Envio ao clob
        gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);
        -- ****** HEADER ENVIO LOTE        *******
        -- Header conforme o codigo da financeira do gravames da coop
        IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
        ELSE
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
        END IF;
        -- Restante das informações
        vr_set_linha := vr_set_linha
                     || to_char(pr_reg_dado_arquiv.cdsubgrv,'fm000')
                     || rpad(substr(pr_reg_dado_arquiv.cdloggrv,1,8),8,' ')
                     || to_char(pr_reg_dado_arquiv.nrseqlot,'fm0000000')
                     || to_char(pr_nrseqreg,'fm000000')
                     || '0'
                     || RPAD(SUBSTR('HEADER ' || pr_reg_dado_arquiv.nmrescop,1,21),21,' ')
                     || RPAD(' ',34,' ')
                     || RPAD(' ',3,' ')
                     || RPAD(' ',8,' ')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                     || to_char(to_date(pr_reg_dado_arquiv.hrmvtolt,'sssss'),'hh24miss')
                     || '*'
                     || chr(10); -- Quebra
        -- Envio ao clob
        gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);
      END IF;
      -- Incrementar sequencia
      pr_nrseqreg := pr_nrseqreg + 1;
      -- ****** DETALHE ENVIO LOTE       *******
      -- Detalhe conforme o codigo da financeira do gravames da coop
      IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
        vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
      ELSE
        vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
      END IF;
      -- Restante das informações
      vr_set_linha := vr_set_linha
                   || to_char(pr_reg_dado_arquiv.cdsubgrv,'fm000')
                   || rpad(substr(pr_reg_dado_arquiv.cdloggrv,1,8),8,' ')
                   || to_char(pr_reg_dado_arquiv.nrseqlot,'fm0000000')
                   || to_char(pr_nrseqreg,'fm000000')
                   || '0'
                   || rpad(substr(pr_reg_dado_arquiv.dschassi,1,21),21,' ')
                   || substr(to_char(pr_reg_dado_arquiv.nrrenava,'fm000000000000'),2,11)
                   || rpad(substr(pr_reg_dado_arquiv.nrdplaca,1,7),7,' ')
                   || rpad(substr(pr_reg_dado_arquiv.uflicenc,1,2),2,' ')
                   || to_char(pr_reg_dado_arquiv.nrcpfbem,'fm00000000000000')
                   || RPAD(' ',3,' ')
                   || RPAD(' ',8,' ')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                   || to_char(to_date(pr_reg_dado_arquiv.hrmvtolt,'sssss'),'hh24miss')
                   || '*'
                   || chr(10); -- Quebra
      -- Envio ao clob
      gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);

      -- Para o ultimo registro do arquivo
      IF pr_fllastof THEN
        -- ****** TRAILLER ENVIO LOTE       *******
        pr_nrseqreg := pr_nrseqreg + 1;
        -- Trailler conforme o codigo da financeira do gravames da coop
        IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
        ELSE
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
        END IF;
        -- Restante das informações
        vr_set_linha := vr_set_linha
                     || to_char(pr_reg_dado_arquiv.cdsubgrv,'fm000')
                     || rpad(substr(pr_reg_dado_arquiv.cdloggrv,1,8),8,' ')
                     || to_char(pr_reg_dado_arquiv.nrseqlot,'fm0000000')
                     || to_char(pr_nrseqreg,'fm000000')
                     || '0'
                     || RPAD(SUBSTR('TRAILLER ' || pr_reg_dado_arquiv.nmrescop,1,21),21,' ')
                     || TO_CHAR(pr_nrseqreg,'fm000000000') -- Qtde detalhes + Head e Trail do Lote
                     || RPAD(' ',25,' ')
                     || RPAD(' ',3,' ')
                     || RPAD(' ',8,' ')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                     || to_char(to_date(pr_reg_dado_arquiv.hrmvtolt,'sssss'),'hh24miss')
                     || '*'
                     || chr(10); -- Quebra
        -- Envio ao clob
        gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);

        -- ****** TRAILLER CONTROLE ARQUIVO *******
        -- Trailler conforme o codigo da financeira do gravames da coop
        IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
        ELSE
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
        END IF;
        -- Restante do Header
        vr_set_linha := vr_set_linha
                     || '999'
                     || '99999999'
                     || '9999999'
                     || '999999'
                     || '0'
                     || 'TRAILLER DE CONTROLE '
                     || to_char(pr_nrseqreg+2,'fm000000000') -- Qtde detalhes + Head e Trail do Lote + Head e Trail do Controle geral
                     || rpad(' ',25,' ')
                     || rpad(' ',3,' ')
                     || rpad(' ',22,' ')
                     || '*'
                     || chr(10); --Quebra
        -- Envio ao clob
        gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na rotina GRVM0001.pc_gravames_gerac_arq_baixa -> '||SQLERRM;

        --Padronização - Chamado 660394
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                      'ERRO: ' || pr_dscritic);

        --Inclusão na tabela de erros Oracle
        CECRED.pc_internal_exception( pr_compleme => pr_dscritic );

    END;
  END pc_gravames_gerac_arqs_bxa_cnc;

  /* Manutenção do arquivo de Inclusão do GRAVAMES */
  PROCEDURE pc_gravames_gerac_arq_inclus(pr_flgfirst        IN BOOLEAN                       --> Flag de primeiro registro
                                        ,pr_fllastof        IN BOOLEAN                       --> Flag de ultimo registro
                                        ,pr_reg_dado_arquiv IN typ_reg_dados_arquivo         --> Registro com as informações atuais
                                        ,pr_clobaux         IN OUT NOCOPY VARCHAR2           --> Varchar2 de Buffer para o arquivo
                                        ,pr_clobarq         IN OUT NOCOPY CLOB               --> CLOB para as informações do arquivo
                                        ,pr_nrseqreg        IN OUT NUMBER                    --> Sequncial das informações
                                        ,pr_cdcooper        IN crapcob.cdcooper%type         --> Codigo da cooperativa
                                        ,pr_dscritic         OUT VARCHAR2) IS                 --> Saida de erro
  /* .............................................................................
     Programa: pc_gravames_gerac_arq_inclus          Antigo: b1wgen0171.p/gravames_geracao_arquivo_inclusao
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Guilherme/SUPERO
     Data    : Agosto/2013                     Ultima atualizacao:  29/05/2017

     Dados referentes ao programa:

     Frequencia:  Diario (on-line)
     Objetivo  : Gerar arquivos GRAVAMES - Inclusão

     Alteracoes: 05/11/2014 - Conversão Progress para Oracle (Marcos-Supero)

                 28/11/2016 - Complemento do endereço da cooperativa nulo gera problema com layout
                              na Credicomin. Incluído NVL na geração do registro (SD#563418 - AJFink).

                 29/05/2017 - Padronização das mensagens para a tabela tbgen_prglog,
                            - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
                            - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
                            - Incluir nome do módulo logado em variável
                            - Inclusão do parâmetro pr_cdcooper para não gravar 0 na gera_log_batch
                              (Ana - Envolti) - SD: 660356 e 660394
    ............................................................................. */
  BEGIN
    DECLARE
      vr_set_linha VARCHAR2(32767); --> Auxiliar para montagem da linha

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';

    BEGIN
	    --Incluir nome do módulo logado - Chamado 660394
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_gerac_arq_inclus');

      -- Para o primeiro registro
      IF pr_flgfirst THEN
        -- Inicializar contador
        pr_nrseqreg := 1;
        -- ****** HEADER CONTROLE ARQUIVO  *******
        -- Header conforme o codigo da financeira do gravames da coop
        IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
        ELSE
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
        END IF;
        -- Restante do Header
        vr_set_linha := vr_set_linha
                     || '000        00000000000000HEADER DE CONTROLE   '
                     || rpad(' ',624,' ')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                     || rpad(' ',14,' ')
                     || '*'
                     || chr(10); --Quebra
        -- Envio ao clob
        gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);
        -- ****** HEADER ENVIO LOTE        *******
        -- Header conforme o codigo da financeira do gravames da coop
        IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
        ELSE
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
        END IF;
        -- Restante das informações
        vr_set_linha := vr_set_linha
                     || to_char(pr_reg_dado_arquiv.cdsubgrv,'fm000')
                     || rpad(substr(pr_reg_dado_arquiv.cdloggrv,1,8),8,' ')
                     || to_char(pr_reg_dado_arquiv.nrseqlot,'fm0000000')
                     || to_char(pr_nrseqreg,'fm000000')
                     || '0'
                     || RPAD(SUBSTR('HEADER ' || pr_reg_dado_arquiv.nmrescop,1,21),21,' ')
                     || RPAD(' ',632,' ')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                     || to_char(to_date(pr_reg_dado_arquiv.hrmvtolt,'sssss'),'hh24miss')
                     || '*'
                     || chr(10); -- Quebra
        -- Envio ao clob
        gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);
      END IF;
      -- Incrementar sequencia
      pr_nrseqreg := pr_nrseqreg + 1;
      -- ****** DETALHE ENVIO LOTE       *******
      -- Detalhe conforme o codigo da financeira do gravames da coop
      IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
        vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
      ELSE
        vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
      END IF;
      -- Restante das informações
      vr_set_linha := vr_set_linha
                   || to_char(pr_reg_dado_arquiv.cdsubgrv,'fm000')
                   || rpad(substr(pr_reg_dado_arquiv.cdloggrv,1,8),8,' ')
                   || to_char(pr_reg_dado_arquiv.nrseqlot,'fm0000000')
                   || to_char(pr_nrseqreg,'fm000000')
                   || '0'
                   || rpad(substr(pr_reg_dado_arquiv.dschassi,1,21),21,' ')
                   || substr(pr_reg_dado_arquiv.tpchassi,1,1)
                   || rpad(substr(pr_reg_dado_arquiv.uflicenc,1,2),2,' ')
                   || rpad(substr(pr_reg_dado_arquiv.ufdplaca,1,2),2,' ')
                   || rpad(substr(pr_reg_dado_arquiv.nrdplaca,1,7),7,' ')
                   ||substr(to_char(pr_reg_dado_arquiv.nrrenava,'fm000000000000'),2,11)
                   || to_char(pr_reg_dado_arquiv.nranobem,'fm0000')
                   || to_char(pr_reg_dado_arquiv.nrmodbem,'fm0000')
                   || to_char(pr_reg_dado_arquiv.nrctremp,'fm00000000000000000000')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                   || '03'
                   || to_char(pr_reg_dado_arquiv.nrcpfbem,'fm00000000000000')
                   || rpad(substr(pr_reg_dado_arquiv.nmprimtl,1,40),40,' ')
                   || to_char(pr_reg_dado_arquiv.qtpreemp,'fm000')
                   || rpad(' ',11,' '); -- Sem Quebra pois as linhas abaixo são continuação
      -- Envio ao clob
      gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);

      -- ****** DADOS COMPLEMENTARES     *******
      vr_set_linha := rpad(' ',6,' ')
                   || rpad('0',6,'0')
                   || rpad('0',6,'0')
                   || rpad('0',6,'0')
                   || rpad('0',9,'0')
                   || rpad('0',9,'0')
                   || 'NAO'
                   || 'NAO'
                   || to_char(pr_reg_dado_arquiv.vlemprst,'fm000000000')
                   || to_char(pr_reg_dado_arquiv.vlpreemp,'fm000000000')
                   || to_char(pr_reg_dado_arquiv.dtdpagto,'yyyy')
                   || to_char(pr_reg_dado_arquiv.dtdpagto,'mm')
                   || to_char(pr_reg_dado_arquiv.dtdpagto,'dd')
                   || to_char(pr_reg_dado_arquiv.dtvencto,'yyyy')
                   || to_char(pr_reg_dado_arquiv.dtvencto,'mm')
                   || to_char(pr_reg_dado_arquiv.dtvencto,'dd')
                   || rpad(substr(pr_reg_dado_arquiv.nmcidade,1,25),25,' ')
                   || rpad(substr(pr_reg_dado_arquiv.cdufdcop,1,2),2,' ')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                   || 'PRE-FIXADO'
                   || rpad(' ',65,' ')
                   || rpad('0',6,'0')
                   || rpad('0',9,'0')
                   || 'NAO'
                   || rpad(' ',50,' ')
                   || 'NAO'
                   || rpad('0',9,'0'); -- Sem quebra
      -- Envio ao clob
      gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);

      --****** DADOS CREDOR             *******
      vr_set_linha := rpad(substr(nvl(pr_reg_dado_arquiv.dsendcop,' '),1,30),30,' ')
                   || to_char(nvl(pr_reg_dado_arquiv.nrendcop,0),'fm00000')
                   || rpad(substr(nvl(pr_reg_dado_arquiv.dscomple,' '),1,20),20,' ') --SD#563418
                   || rpad(substr(nvl(pr_reg_dado_arquiv.nmbaienc,' '),1,20),20,' ')
                   || to_char(nvl(pr_reg_dado_arquiv.cdcidenc,0),'fm0000')
                   || rpad(substr(nvl(pr_reg_dado_arquiv.cdufdenc,' '),1,2),2,' ')
                   || to_char(nvl(pr_reg_dado_arquiv.nrcepenc,0),'fm00000000')
                   || rpad(substr(nvl(pr_reg_dado_arquiv.nrdddenc,' '),1,3),3,' ')
                   || rpad(substr(nvl(pr_reg_dado_arquiv.nrtelenc,' '),1,9),9,' '); -- Sem quebra
      -- Envio ao clob
      gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);

      -- ****** DADOS CLIENTE            *******
      vr_set_linha := rpad(substr(pr_reg_dado_arquiv.dsendere,1,30),30,' ')
                   || to_char(pr_reg_dado_arquiv.nrendere,'fm00000')
                   || rpad(substr(pr_reg_dado_arquiv.complend,1,20),20,' ')
                   || rpad(substr(pr_reg_dado_arquiv.nmbairro,1,20),20,' ')
                   || to_char(pr_reg_dado_arquiv.cdcidade,'fm0000')
                   || rpad(substr(pr_reg_dado_arquiv.cdufende,1,2),2,' ')
                   || to_char(pr_reg_dado_arquiv.nrcepend,'fm00000000')
                   || rpad(substr(pr_reg_dado_arquiv.nrdddass,1,3),3,' ')
                   || rpad(substr(pr_reg_dado_arquiv.nrtelass,1,9),9,' '); -- Sem quebra
      -- Envio ao clob
      gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);

      -- ****** DADOS OPERACAO           *******
      vr_set_linha := rpad('0',14,'0')
                   || rpad(substr(pr_reg_dado_arquiv.inpessoa,1,1),1,' ')
                   || to_char(pr_reg_dado_arquiv.nrcpfcgc,'fm00000000000000')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                   || to_char(to_date(pr_reg_dado_arquiv.hrmvtolt,'sssss'),'hh24miss')
                   || '*'
                   || chr(10); -- Agora com quebra pois terminados o detalhe
      -- Envio ao clob
      gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);


      -- Para o ultimo registro do arquivo
      IF pr_fllastof THEN
        -- ****** TRAILLER ENVIO LOTE       *******
        pr_nrseqreg := pr_nrseqreg + 1;
        -- Trailler conforme o codigo da financeira do gravames da coop
        IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
        ELSE
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
        END IF;
        -- Restante das informações
        vr_set_linha := vr_set_linha
                     || to_char(pr_reg_dado_arquiv.cdsubgrv,'fm000')
                     || rpad(substr(pr_reg_dado_arquiv.cdloggrv,1,8),8,' ')
                     || to_char(pr_reg_dado_arquiv.nrseqlot,'fm0000000')
                     || to_char(pr_nrseqreg,'fm000000')
                     || '0'
                     || RPAD(SUBSTR('TRAILLER ' || pr_reg_dado_arquiv.nmrescop,1,21),21,' ')
                     || TO_CHAR(pr_nrseqreg,'fm000000000')  -- Qtde detalhes + Head e Trail do Lote
                     || RPAD(' ',623,' ')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                     || to_char(to_date(pr_reg_dado_arquiv.hrmvtolt,'sssss'),'hh24miss')
                     || '*'
                     || chr(10); -- Quebra
        -- Envio ao clob
        gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);

        -- ****** TRAILLER CONTROLE ARQUIVO *******
        -- Trailler conforme o codigo da financeira do gravames da coop
        IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
        ELSE
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
        END IF;
        -- Restante do Header
        vr_set_linha := vr_set_linha
                     || '9999999999999999999999990'
                     || 'TRAILLER DE CONTROLE '
                     || to_char(pr_nrseqreg+2,'fm000000000') -- Qtde de detalhes + Head e Trail do Lote + Head e Trail do COntrole geral
                     || rpad(' ',637,' ')
                     || '*'
                     || chr(10); --Quebra
        -- Envio ao clob
        gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na rotina GRVM0001.pc_gravames_gerac_arq_inclus -> '||SQLERRM;

        --Padronização - Chamado 660394
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                      'ERRO: ' || pr_dscritic );

        --Inclusão na tabela de erros Oracle
        CECRED.pc_internal_exception( pr_compleme => pr_dscritic );

    END;
  END pc_gravames_gerac_arq_inclus;

  /* Geração dos arquivos do GRAVAMES */
  PROCEDURE pc_gravames_geracao_arquivo(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa conectada
                                       ,pr_cdcoptel  IN crapcop.cdcooper%TYPE -- Opção selecionada na tela
                                       ,pr_tparquiv  IN VARCHAR2              -- Tipo do arquivo selecionado na tela
                                       ,pr_dtmvtolt  IN DATE                  -- Data atual
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE -- Cod Critica de erro
                                       ,pr_dscritic OUT VARCHAR2) IS          -- Des Critica de erro
  BEGIN
    /* .............................................................................
     Programa: pc_gravames_geracao_arquivo          Antigo: b1wgen0171.p/gravames_geracao_arquivo
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Guilherme/SUPERO
     Data    : Agosto/2013                     Ultima atualizacao:  09/04/2019

     Dados referentes ao programa:

     Frequencia:  Diario (on-line)
     Objetivo  : Gerar arquivos GRAVAMES

     Alteracoes: 04/11/2014 - Conversão Progress para Oracle (Marcos-Supero)

                 05/12/2014 - Mudança no indice da GRV, inclusão do dschassi (Guilherme/SUPERO)

                 22/12/2014 - Inclusao do LOWER no cdoperad da CRAWEPR e CRAPOPE,
                              problema em localizar a chave (Guilherme/SUPERO)

                 23/12/2014 - Inclusão de testes logo após a inserção/atualização
                              da CRAPGRV para evitarmos o problema que vem ocorrendo
                              do bem ser processado e não gravarmos a GRV.
                              Também mudei a forma de tratamento dos erros, incluindo
                              raise com rollback ao invés do return. (Marcos-Supero)

                 30/12/2014 - Liberação para as demais cooperativas(Guilherme/SUPERO)

                 13/02/2015 - Adicionado condicao para nao enviar registros bloqueados
                              judicialmente quando tiver flblqjud = 1 em casos de
                              Baixa ou Cancelamento. (Jorge/Gielow) - SD 241854

                 05/03/2015 - Incluido UPPER e TRIM no dschassi (Guilherme/SUPERO)

                 31/03/2015 - Alterado para fazer Insert/Update na GRV antes da
                              geracao do arquivo. Geracao do arquivo faz "commit"
                              internamente (Guilherme/SUPERO)

                 22/05/2015 - Substituir os caracteres especiais nos campos
                              dsendere e complend. (Jaison/Thiago - SD: 286623)

                 29/09/2015 - Ajuste para que só entre na inclusão quando o flag
                              de baixa estiver igual a 0 (FALSE), conforme pedido
                              no chamado 319024.(Kelvin/Gielow)
                              
                 04/01/2016 - Ajuste na leitura da tabela CRAPGRV para utilizar UPPER nos campos VARCHAR
                              pois será incluido o UPPER no indice desta tabela - SD 375854
                             (Adriano).                                
                             
                 11/01/2016 - Ajuste na leitura da tabela CRAPGRV para utilizar UPPER nos campos VARCHAR
                              pois será incluido o UPPER no indice desta tabela - SD 375854
                             (Adriano).                                            
                             
                 08/04/2016 -  Ajuste na pc_gravames_geracao_arquivo para formatar
                               o número de telefone caso venha vazio, e também
                               foi tirado os caracteres especiais do nome da cidade
                               e do nome do bairro conforme solicitado no chamado
                               430323. (Kelvin) 
                               
                 14/07/2016 - Ajuste para retornar corretamente o erro quando houver uma exceção
                              (Andrei - RKAM).               
                               
				         22/09/2016 - Ajuste para utilizar upper ao manipular a informação do chassi
                              pois em alguns casos ele foi gravado em minusculo e outros em maisculo
                              (Adriano - SD 527336)
             
                 29/05/2017 - Padronização das mensagens para a tabela tbgen_prglog,
                            - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
                            - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
                            - Incluir nome do módulo logado em variável
                            - Inclusão do parâmetro pr_cdcooper na chamada das rotinas gerac_arq_inlcus 
                              e gerac_arqs_bxa_cnc, para não gravar 0 na gera_log_batch
                              (Ana - Envolti) - SD: 660356 / 660394 / 664309
                              
                 23/10/2018 - P442 - Ignorar cooperativas com Gravames Online (Marcos-Envolti)
                              
				 09/04/2019 - Ajustar query para filtrar veiculos ao exportar lote (Petter - Envolti)
    ............................................................................. */
    DECLARE

      -- Cursor para validacao da cooperativa conectada
      CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%type) IS
        SELECT cdcooper
          FROM crapcop
         WHERE crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%rowtype;

      -- Buscar todas as informações de alienação e bens
      CURSOR cr_crapbpr IS
        SELECT bpr.rowid
              ,cop.cdcooper
              ,cop.nmrescop
              ,cop.nrtelvoz
              ,cop.nmcidade
              ,cop.cdufdcop
              ,cop.cdfingrv
              ,cop.cdsubgrv
              ,cop.cdloggrv
              ,cop.dsendcop
              ,cop.nrendcop
              ,cop.dscomple
              ,cop.nmbairro
              ,cop.nrcepend
              ,ass.nrdconta
              ,ass.nmprimtl
              ,ass.inpessoa
              ,wpr.nrctremp
              ,wpr.flgokgrv
              ,wpr.dtdpagto
              ,wpr.qtpreemp
              ,wpr.dtmvtolt
              ,wpr.vlemprst
              ,wpr.vlpreemp
              ,LOWER(wpr.cdoperad) cdoperad
              ,bpr.flginclu
              ,bpr.cdsitgrv
              ,bpr.tpinclus
              ,bpr.flcancel
              ,bpr.tpcancel
              ,bpr.tpctrpro
              ,bpr.flgbaixa
              ,bpr.tpdbaixa
              ,bpr.nrcpfbem
              ,bpr.nrctrpro
              ,bpr.idseqbem
              ,UPPER(TRIM(bpr.dschassi)) dschassi
              ,bpr.tpchassi
              ,UPPER(bpr.uflicenc) uflicenc
              ,bpr.nranobem
              ,bpr.nrmodbem
              ,bpr.ufplnovo
              ,bpr.nrplnovo
              ,bpr.nrrenovo
              ,bpr.ufdplaca
              ,bpr.nrdplaca
              ,bpr.nrrenava
              ,ass.nrcpfcgc
              ,epr.inliquid 
              ,bpr.dscatbem
              ,bpr.dstipbem
              ,bpr.dsmarbem
              ,bpr.dsbemfin
              ,ROW_NUMBER ()
                  OVER (PARTITION BY cop.cdcooper ORDER BY cop.cdcooper) nrseqcop
          FROM crapass ass
              ,crapcop cop
              ,crawepr wpr
              ,crapbpr bpr
         FULL OUTER  JOIN crapepr epr on (epr.cdcooper = bpr.cdcooper AND epr.nrdconta = bpr.nrdconta AND epr.nrctremp = bpr.nrctrpro)
         WHERE bpr.cdcooper = DECODE(pr_cdcoptel,0,bpr.cdcooper,pr_cdcoptel)
           AND bpr.flgalien   = 1 -- Sim
           AND wpr.cdcooper   = bpr.cdcooper
           AND wpr.nrdconta   = bpr.nrdconta
           AND wpr.nrctremp   = bpr.nrctrpro
           AND wpr.insitapr IN(1,3) -- Aprovados
           AND cop.cdcooper   = bpr.cdcooper
           AND ass.cdcooper   = bpr.cdcooper
           AND ass.nrdconta   = bpr.nrdconta
           -- Validar somente tipos de veículos válidos para GRAVAME
           AND bpr.dscatbem IN('AUTOMOVEL', 'MOTO', 'CAMINHAO', 'OUTROS VEICULOS')
           -- Bloquear tipos de chassi inválido
           AND (bpr.tpchassi IS NOT NULL OR bpr.tpchassi != 0)
           -- Somente Coops com Gravames Online desativado
           AND grvm0001.fn_tem_gravame_online(cop.cdcooper) = 'N'
           AND ((pr_tparquiv IN ('INCLUSAO','TODAS') -- Bloco INCLUSAO
                     AND  bpr.tpctrpro   = 90
                     AND  wpr.flgokgrv   = 1
                     AND  bpr.flgbaixa   = 0      -- APENAS NÃO BAIXADOS
                     AND  nvl(epr.inliquid,0) = 0 -- APENAS NÃO LIQUIDADO, CASO NULO TRATAR COMO "0 - NÃO LIQUIDADO"
                     AND  bpr.flginclu   = 1      -- INCLUSAO SOLICITADA
                     AND  bpr.cdsitgrv in (0,3)   -- NAO ENVIADO ou PROCES.COM ERRO
                     AND  bpr.tpinclus   = 'A')   -- AUTOMATICA
                 OR (pr_tparquiv IN('BAIXA','TODAS') -- Bloco BAIXA --
                     AND  bpr.tpctrpro   in(90,99)  -- Tbm Para BENS excluidos na ADITIV
                     AND  bpr.flgbaixa   = 1        -- BAIXA SOLICITADA
                     AND  bpr.cdsitgrv  <> 1        -- Nao enviado
                     AND  bpr.tpdbaixa   = 'A'      -- Automatica
                     AND  bpr.flblqjud  <> 1)       -- Nao bloqueado judicial
                 OR (pr_tparquiv IN('CANCELAMENTO','TODAS') -- Bloco CANCELAMENTO --
                     AND  bpr.tpctrpro   = 90
                     AND  bpr.flcancel   = 1    -- CANCELAMENTO SOLICITADO
                     AND  bpr.tpcancel   = 'A'  -- Automatica
                     AND  bpr.cdsitgrv  <> 1    -- Nao enviado
                     AND  bpr.flblqjud  <> 1)); -- Nao bloqueado judicial

      -- Busca de todas as agências por operador
      CURSOR cr_crapope IS
        SELECT ope.cdcooper
              ,LOWER(ope.cdoperad) cdoperad
              ,age.nmcidade
              ,age.cdufdcop
          FROM crapope ope
              ,crapage age
         WHERE ope.cdcooper = age.cdcooper
           AND ope.cdagenci = age.cdagenci;

      -- Busca de todos os municipios
      CURSOR cr_crapmun IS
        SELECT cdcidade
              ,dscidade
              ,cdestado
          FROM crapmun;

      -- BUsca de endereco do cliente
      CURSOR cr_crapenc(pr_cdcooper crapenc.cdcooper%TYPE
                       ,pr_nrdconta crapenc.nrdconta%TYPE
                       ,pr_inpessoa crapass.inpessoa%TYPE) IS
        SELECT enc.dsendere
              ,enc.nrendere
              ,enc.complend
              ,enc.nmbairro
              ,enc.cdufende
              ,enc.nrcepend
              ,enc.nmcidade
          FROM crapenc enc
        WHERE enc.cdcooper = pr_cdcooper
          AND enc.nrdconta = pr_nrdconta
          AND (  -- Para PF
                 (    pr_inpessoa = 1
                  AND enc.idseqttl = 1 /* Sempre do primeiro titular */
                  AND enc.tpendass = 10)
               OR
                 -- Para PJ
                 (    pr_inpessoa = 2
                  AND enc.idseqttl = 1 /* Sempre do primeiro titular */
                  AND enc.cdseqinc = 1
                  AND enc.tpendass = 9)
               );
      rw_enc cr_crapenc%ROWTYPE;

      -- Telefone do associado
      CURSOR cr_craptfc(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrdconta crawepr.nrdconta%TYPE) IS
        SELECT tfc.nrdddtfc
              ,tfc.nrtelefo
          FROM craptfc tfc
         WHERE tfc.cdcooper = pr_cdcooper
           AND tfc.nrdconta = pr_nrdconta
           AND tfc.idseqttl = 1 /* Sempre primeiro titular */
         ORDER BY tfc.tptelefo
                 ,tfc.nrtelefo;

      -- Localiza Nr Sequencia LOTE
      CURSOR cr_crapsqg(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT ROWID
              ,nrseqqui
              ,nrseqinc
              ,nrseqcan
          FROM crapsqg
         WHERE cdcooper = pr_cdcooper;
      rw_crapsqg cr_crapsqg%ROWTYPE;

      -- Busca do GRV para atualização
      CURSOR cr_crapgrv (pr_cdcooper crapgrv.cdcooper%TYPE
                        ,pr_nrdconta crapgrv.nrdconta%TYPE
                        ,pr_tpctrpro crapgrv.tpctrpro%TYPE
                        ,pr_nrctrpro crapgrv.nrctrpro%TYPE
                        ,pr_dschassi crapgrv.dschassi%TYPE
                        ,pr_nrseqlot crapgrv.nrseqlot%TYPE
                        ,pr_cdoperac crapgrv.cdoperac%TYPE) IS
        SELECT ROWID
          FROM crapgrv
         WHERE crapgrv.cdcooper = pr_cdcooper
           AND crapgrv.nrdconta = pr_nrdconta
           AND crapgrv.tpctrpro = pr_tpctrpro
           AND crapgrv.nrctrpro = pr_nrctrpro
           AND UPPER(crapgrv.dschassi) = UPPER(pr_dschassi)
           AND crapgrv.nrseqlot = pr_nrseqlot
           AND crapgrv.cdoperac = pr_cdoperac;
      vr_rowid_grv ROWID;

      -- Tipo e tabela para armazenar as cidades e ufs
      -- dos operadores observando a agencia do mesmo
      TYPE typ_reg_endere_ageope IS
        RECORD (nmcidade crapage.nmcidade%TYPE
               ,cdufdcop crapage.cdufdcop%TYPE);
      TYPE typ_tab_endere_ageope IS
        TABLE OF typ_reg_endere_ageope
          INDEX BY VARCHAR2(15);
      vr_tab_endere_ageope typ_tab_endere_ageope;

      -- Tabela para armazenar o codigo do municipio conforme descrição
      TYPE typ_tab_munici IS
        TABLE OF crapmun.cdcidade%TYPE
          INDEX BY VARCHAR2(52); -- Cdestado(2)+Dscidade(50)
      vr_tab_munici typ_tab_munici;

      -- Tabela para contagem dos registros cfme cada tipo de arquivo
      TYPE typ_tab_qtregarq IS
        TABLE OF PLS_INTEGER
          INDEX BY PLS_INTEGER;
      vr_tab_qtregarq typ_tab_qtregarq;

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';

      --Variável para complementar msg erro na exception
      vr_dsparam VARCHAR2(1000);
      
      -- Variaveis auxiliares
      vr_tab_dados_arquivo typ_tab_dados_arquivo; -- Tabela com as informações do arquivo
      vr_dsdchave VARCHAR2(20);          -- Chave da tabela composta por Cooper(5)+TpArquivo(1)+Sequencia(14)

      vr_tparquiv VARCHAR2(12);          -- Descricao da operação
      vr_cdoperac PLS_INTEGER;           -- Codigo da operação
      vr_nrseqreg PLS_INTEGER;           -- Sequenciador do registro na cooperativa
      vr_nmprimtl crapass.nmprimtl%TYPE; -- Nome do proprietario do bem
      vr_nrcpfbem crapass.nrcpfcgc%TYPE; -- Cpf do proprietário do bem
      vr_dtvencto DATE;                  -- Data do ultimo vencimento
      vr_nrdddenc VARCHAR2(10);          -- DDD do Telefone do Credor
      vr_nrtelenc VARCHAR2(10);          -- Telefone do Credor
      vr_cdcidcre crapmun.cdcidade%TYPE; -- Municipio do Credor
      vr_cdcidcli crapmun.cdcidade%TYPE; -- Municipio do Cliente
      vr_nrdddass VARCHAR2(10);          -- DDD do Telefone do Cliente
      vr_nrtelass VARCHAR2(10);          -- Telefone do Cliente

      vr_flgfirst BOOLEAN;               -- Flag de primeiro registro da quebra
      vr_fllastof BOOLEAN;               -- Flag do ultimo registro da quebra
      vr_nrseqlot NUMBER;                -- Numero do Lote

      vr_clobarq CLOB;                   -- CLOB para armazenamento das informações do arquivo
      vr_clobaux VARCHAR2(32767);        -- Var auxiliar para montagem do arquivo
      vr_nmdireto VARCHAR2(100);         -- Diretorio para geração dos arquivos
      vr_nmarquiv VARCHAR2(100);         -- Var para o nome dos arquivos

      vr_exc_erro EXCEPTION;             -- Tratamento de exceção

    BEGIN
	    --Incluir nome do módulo logado - Chamado 660394
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_geracao_arquivo');

      -- Validar existencia da cooperativa informada
      IF pr_cdcoptel <> 0 THEN
        
        OPEN cr_crapcop(pr_cdcoptel);
        FETCH cr_crapcop
         INTO rw_crapcop;
        -- Gerar critica 794 se nao encontrar
        IF cr_crapcop%NOTFOUND THEN
          CLOSE cr_crapcop;
          pr_cdcritic := 794;
          -- Sair
          RETURN;
        ELSE
          CLOSE cr_crapcop;
          -- Continuaremos
        END IF;
        
        -- Validar se Coop tem Gravames Online
        IF fn_tem_gravame_online(pr_cdcoptel) = 'S' THEN
          -- Não prosseguimos pois a Cooperativa não usa mais envio em lote
          pr_cdcritic := 0;
          pr_dscritic := 'Cooperativa com comunicacao GRAVAMES Online - Envio por Lote nao permitido!';
          RAISE vr_exc_erro;          
      END IF;

        
      END IF;

      -- Validar opção informada
      IF pr_tparquiv NOT IN('TODAS','INCLUSAO','BAIXA','CANCELAMENTO') THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Tipo invalido para Geracao do Arquivo! ';
        RAISE vr_exc_erro;
      END IF;

      -- Busca de todas as agências por operador
      FOR rw_ope IN cr_crapope LOOP
        -- Armazenar armazenar as cidades e ufs
        -- dos operadores observando a agencia do mesmo
        vr_tab_endere_ageope(lpad(rw_ope.cdcooper,5,'0')||rpad(rw_ope.cdoperad,10,' ')).nmcidade := rw_ope.nmcidade;
        vr_tab_endere_ageope(lpad(rw_ope.cdcooper,5,'0')||rpad(rw_ope.cdoperad,10,' ')).cdufdcop := rw_ope.cdufdcop;
      END LOOP;

      -- Busca de todos os municipios
      FOR rw_mun IN cr_crapmun LOOP
        -- Adicionar a tabela o codigo pela chave UF + DsCidade
        vr_tab_munici(rpad(rw_mun.cdestado,2,' ')||rpad(rw_mun.dscidade,50,' ')) := rw_mun.cdcidade;
      END LOOP;

      -- Inicializar a pltable de contagem
      FOR vr_ind IN 1..3 LOOP
        vr_tab_qtregarq(vr_ind) := 0;
      END LOOP;

      -- Buscar o parâmetro de sistema que contém o diretório dos arquivos do GRAVAMES
      vr_nmdireto := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'DS_PATH_GRAVAMES');

      -- Buscar todas as informações de alienação e bens
      FOR rw_bpr IN cr_crapbpr LOOP
        
        --Guarda variáveis para complementar msg erro na exception
        vr_dsparam := 'Nrdconta:'||rw_bpr.nrdconta||',Nrctremp:'||rw_bpr.nrctremp||
                      'Nrcpfcgc:'||rw_bpr.nrcpfbem||',Inpessoa:'||rw_bpr.inpessoa;

        -- Quando escolhido todas, temos que avaliar o registro atual pra definir sua operação
        IF pr_tparquiv = 'TODAS' THEN
          -- Inclusão
          IF rw_bpr.flgokgrv = 1 AND rw_bpr.flginclu = 1 AND rw_bpr.cdsitgrv in(0,3) AND rw_bpr.tpinclus = 'A' AND 
             rw_bpr.flgbaixa = 0 AND nvl(rw_bpr.inliquid,0) = 0 THEN --Adicionado a alteração rw_bpr.flgbaixa = 0 pedido pelo análista Gielow
            vr_tparquiv := 'INCLUSAO';
          -- Cancelamento
          ELSIF rw_bpr.flcancel = 1 AND rw_bpr.tpcancel = 'A' AND rw_bpr.tpctrpro IN(90,99) THEN
            vr_tparquiv := 'CANCELAMENTO';
          -- Baixa
          ELSIF rw_bpr.flgbaixa = 1 AND rw_bpr.tpdbaixa = 'A' THEN
            vr_tparquiv := 'BAIXA';
          END IF;
        ELSE
          -- Usar a opção escolhida na tela
          vr_tparquiv := pr_tparquiv;
        END IF;

        -- Buscar o codigo da operação
        CASE vr_tparquiv
          WHEN 'BAIXA'        THEN
            vr_cdoperac := 3;
          WHEN 'CANCELAMENTO' THEN
            vr_cdoperac := 2;
          WHEN 'INCLUSAO'     THEN
            vr_cdoperac := 1;
          ELSE
            vr_cdoperac := 0;
        END CASE;
        -- Incrementar os contadores por operação
        vr_tab_qtregarq(vr_cdoperac) := vr_tab_qtregarq(vr_cdoperac) + 1;

        -- Para o primeiro registro da Cooperativa
        IF rw_bpr.nrseqcop = 1 THEN
          -- Inicia sequencia por cooperativa
          vr_nrseqreg := 0;
        END IF;

        -- Incrementar Contador de Registros
        vr_nrseqreg := vr_nrseqreg + 1;

        -- Default é as informações do cooperado
          vr_nmprimtl := rw_bpr.nmprimtl;
          vr_nrcpfbem := rw_bpr.nrcpfcgc;

        /* Procedimento para busca do emitente (Inverveniente, se houver) */
        pc_busca_emitente(pr_cdcooper => rw_bpr.cdcooper
                         ,pr_nrdconta => rw_bpr.nrdconta
                         ,pr_nrctremp => rw_bpr.nrctremp
                         ,pr_nrcpfbem => rw_bpr.nrcpfbem
                         ,pr_nrcpfemi => vr_nrcpfbem
                         ,pr_nmprimtl => vr_nmprimtl);
                         
        -- Calcular data do ultimo vencimento considerando
        -- a data do primeiro pagamento e quantidade de parcelas
        vr_dtvencto := add_months(rw_bpr.dtdpagto,rw_bpr.qtpreemp-1);

        -- Separar DDD do Credor
        vr_nrdddenc := '0' || TRIM(REPLACE(gene0002.fn_busca_entrada(1,rw_bpr.nrtelvoz,')'),'(',''));
        -- Separar Telefone do Credor
        vr_nrtelenc := TRIM(REPLACE(gene0002.fn_busca_entrada(2,rw_bpr.nrtelvoz,')'),'-',''));

        -- Buscar municipio do credor
        IF vr_tab_munici.exists(rpad(rw_bpr.cdufdcop,2,' ')||rpad(rw_bpr.nmcidade,50,' ')) THEN
          -- Usamos o código encontrado
          vr_cdcidcre := vr_tab_munici(rpad(rw_bpr.cdufdcop,2,' ')||rpad(rw_bpr.nmcidade,50,' '));
        ELSE
          -- Usamos Codigo de BLUMENAU-SC
          vr_cdcidcre := 8047;
        END IF;

        -- BUscar o endereço do cliente
        rw_enc := NULL;
        OPEN cr_crapenc(pr_cdcooper => rw_bpr.cdcooper
                       ,pr_nrdconta => rw_bpr.nrdconta
                       ,pr_inpessoa => rw_bpr.inpessoa);
        FETCH cr_crapenc
         INTO rw_enc;
        CLOSE cr_crapenc;

        -- Buscar municipio do cliente
        IF vr_tab_munici.exists(rpad(rw_enc.cdufende,2,' ')||rpad(rw_enc.nmcidade,50,' ')) THEN
          -- Usamos o código encontrado
          vr_cdcidcli := vr_tab_munici(rpad(rw_enc.cdufende,2,' ')||rpad(rw_enc.nmcidade,50,' '));
        ELSE
          -- Usamos Codigo de BLUMENAU-SC
          vr_cdcidcli := 8047;
        END IF;

        -- Telefone do cliente
        vr_nrdddass := NULL;
        vr_nrtelass := NULL;
        FOR rw_tfc IN cr_craptfc(pr_cdcooper => rw_bpr.cdcooper
                                ,pr_nrdconta => rw_bpr.nrdconta) LOOP
          -- Formatar a informação
          vr_nrdddass := to_char(nvl(rw_tfc.nrdddtfc,0),'fm000');
          vr_nrtelass := to_char(nvl(rw_tfc.nrtelefo,0),'fm900000000');
          -- Sair quando encontrar
          EXIT WHEN (vr_nrdddass <> ' ' AND vr_nrtelass <> ' ');
        END LOOP;
        
        IF TRIM(vr_nrdddass) IS NULL THEN
          vr_nrdddass := to_char(0,'fm000');
        END IF;
        
        IF TRIM(vr_nrtelass) IS NULL THEN
          vr_nrtelass := to_char(0,'fm900000000');
        END IF;
          
        -- Montagem da chave para a tabela por Cooper(5)+TpArquivo(1)+Sequencia(14)
        vr_dsdchave := LPAD(rw_bpr.cdcooper,5,'0')
                    || vr_cdoperac
                    || LPAD(vr_tab_qtregarq(vr_cdoperac),14,'0');

        -- Enfim, criaremos os registros na tabela
        vr_tab_dados_arquivo(vr_dsdchave).rowidbpr := rw_bpr.rowid;
        vr_tab_dados_arquivo(vr_dsdchave).cdcooper := rw_bpr.cdcooper;
        vr_tab_dados_arquivo(vr_dsdchave).tparquiv := vr_tparquiv;
        vr_tab_dados_arquivo(vr_dsdchave).cdoperac := vr_cdoperac;
        vr_tab_dados_arquivo(vr_dsdchave).cdfingrv := rw_bpr.cdfingrv;
        vr_tab_dados_arquivo(vr_dsdchave).cdsubgrv := rw_bpr.cdsubgrv;
        vr_tab_dados_arquivo(vr_dsdchave).cdloggrv := rw_bpr.cdloggrv;

        vr_tab_dados_arquivo(vr_dsdchave).nrdconta := rw_bpr.nrdconta;
        vr_tab_dados_arquivo(vr_dsdchave).tpctrpro := rw_bpr.tpctrpro;
        vr_tab_dados_arquivo(vr_dsdchave).nrctrpro := rw_bpr.nrctrpro;
        vr_tab_dados_arquivo(vr_dsdchave).idseqbem := rw_bpr.idseqbem;

        vr_tab_dados_arquivo(vr_dsdchave).nrseqreg := vr_nrseqreg;
        vr_tab_dados_arquivo(vr_dsdchave).dtmvtolt := pr_dtmvtolt;
        vr_tab_dados_arquivo(vr_dsdchave).hrmvtolt := to_char(SYSDATE,'sssss');
        vr_tab_dados_arquivo(vr_dsdchave).nmrescop := rw_bpr.nmrescop;
        vr_tab_dados_arquivo(vr_dsdchave).dschassi := rw_bpr.dschassi;
        vr_tab_dados_arquivo(vr_dsdchave).tpchassi := rw_bpr.tpchassi;
        vr_tab_dados_arquivo(vr_dsdchave).uflicenc := rw_bpr.uflicenc;
        vr_tab_dados_arquivo(vr_dsdchave).nranobem := rw_bpr.nranobem;
        vr_tab_dados_arquivo(vr_dsdchave).nrmodbem := rw_bpr.nrmodbem;
        vr_tab_dados_arquivo(vr_dsdchave).nrctremp := rw_bpr.nrctremp;
        vr_tab_dados_arquivo(vr_dsdchave).dtoperad := rw_bpr.dtmvtolt;
        vr_tab_dados_arquivo(vr_dsdchave).nrcpfbem := vr_nrcpfbem;
        vr_tab_dados_arquivo(vr_dsdchave).nmprimtl := vr_nmprimtl;
        vr_tab_dados_arquivo(vr_dsdchave).qtpreemp := rw_bpr.qtpreemp;
        vr_tab_dados_arquivo(vr_dsdchave).vlemprst := rw_bpr.vlemprst * 100;
        vr_tab_dados_arquivo(vr_dsdchave).vlpreemp := rw_bpr.vlpreemp * 100;
        vr_tab_dados_arquivo(vr_dsdchave).dtdpagto := rw_bpr.dtdpagto;
        vr_tab_dados_arquivo(vr_dsdchave).dtvencto := vr_dtvencto;

        vr_tab_dados_arquivo(vr_dsdchave).nmcidade := GENE0007.fn_caract_acento(
                                                               pr_texto => vr_tab_endere_ageope(lpad(rw_bpr.cdcooper,5,'0')||rpad(rw_bpr.cdoperad,10,' ')).nmcidade, 
                                                               pr_insubsti => 1);
        vr_tab_dados_arquivo(vr_dsdchave).cdufdcop := vr_tab_endere_ageope(lpad(rw_bpr.cdcooper,5,'0')||rpad(rw_bpr.cdoperad,10,' ')).cdufdcop;

        /* DADOS CREDOR */
        vr_tab_dados_arquivo(vr_dsdchave).dsendcop := rw_bpr.dsendcop;
        vr_tab_dados_arquivo(vr_dsdchave).nrendcop := rw_bpr.nrendcop;
        vr_tab_dados_arquivo(vr_dsdchave).dscomple := rw_bpr.dscomple;
        vr_tab_dados_arquivo(vr_dsdchave).nmbaienc := rw_bpr.nmbairro;
        vr_tab_dados_arquivo(vr_dsdchave).cdcidenc := vr_cdcidcre;
        vr_tab_dados_arquivo(vr_dsdchave).cdufdenc := rw_bpr.cdufdcop;
        vr_tab_dados_arquivo(vr_dsdchave).nrcepenc := rw_bpr.nrcepend;
        vr_tab_dados_arquivo(vr_dsdchave).nrdddenc := vr_nrdddenc;
        vr_tab_dados_arquivo(vr_dsdchave).nrtelenc := vr_nrtelenc;
        /* DADOS CLIENTE */
        vr_tab_dados_arquivo(vr_dsdchave).dsendere := GENE0007.fn_caract_acento(
                                                               pr_texto => rw_enc.dsendere, 
                                                               pr_insubsti => 1);
        vr_tab_dados_arquivo(vr_dsdchave).complend := GENE0007.fn_caract_acento(
                                                               pr_texto => rw_enc.complend, 
                                                               pr_insubsti => 1);
        vr_tab_dados_arquivo(vr_dsdchave).nrendere := rw_enc.nrendere;
        vr_tab_dados_arquivo(vr_dsdchave).nmbairro := GENE0007.fn_caract_acento(
                                                               pr_texto => rw_enc.nmbairro, 
                                                               pr_insubsti => 1);
        vr_tab_dados_arquivo(vr_dsdchave).cdcidade := vr_cdcidcli;
        vr_tab_dados_arquivo(vr_dsdchave).cdufende := rw_enc.cdufende;
        vr_tab_dados_arquivo(vr_dsdchave).nrcepend := rw_enc.nrcepend;
        vr_tab_dados_arquivo(vr_dsdchave).nrdddass := vr_nrdddass;
        vr_tab_dados_arquivo(vr_dsdchave).nrtelass := vr_nrtelass;
        vr_tab_dados_arquivo(vr_dsdchave).nrcpfcgc := rw_bpr.nrcpfcgc;
        IF rw_bpr.inpessoa = 1 THEN
          vr_tab_dados_arquivo(vr_dsdchave).inpessoa := 1;
        ELSE
          vr_tab_dados_arquivo(vr_dsdchave).inpessoa := 2;
        END IF;

        -- Para baixa com mudança no veiculo
        IF vr_tparquiv = 'BAIXA' AND rw_bpr.ufplnovo <> ' ' AND rw_bpr.nrplnovo <> ' ' AND rw_bpr.nrrenovo > 0 THEN
          vr_tab_dados_arquivo(vr_dsdchave).ufdplaca := rw_bpr.ufplnovo;
          vr_tab_dados_arquivo(vr_dsdchave).nrdplaca := rw_bpr.nrplnovo;
          vr_tab_dados_arquivo(vr_dsdchave).nrrenava := rw_bpr.nrrenovo;
        ELSE
          vr_tab_dados_arquivo(vr_dsdchave).ufdplaca := rw_bpr.ufdplaca;
          vr_tab_dados_arquivo(vr_dsdchave).nrdplaca := rw_bpr.nrdplaca;
          vr_tab_dados_arquivo(vr_dsdchave).nrrenava := rw_bpr.nrrenava;
        END IF;

        -- Histórico
        vr_tab_dados_arquivo(vr_dsdchave).dscatbem := nvl(rw_bpr.dscatbem,' ');
        vr_tab_dados_arquivo(vr_dsdchave).dstipbem := nvl(rw_bpr.dstipbem,' ');
        vr_tab_dados_arquivo(vr_dsdchave).dsmarbem := nvl(rw_bpr.dsmarbem,' ');
        vr_tab_dados_arquivo(vr_dsdchave).dsbemfin := nvl(rw_bpr.dsbemfin,' ');

        -- ATUALIZAR A SITUACAO DO BEM DO GRAVAMES
        BEGIN
          UPDATE crapbpr
             SET cdsitgrv = 1. /* Enviado */
           WHERE ROWID = rw_bpr.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Ao atualizar CRAPBPR -> '||SQLERRM;
            RAISE vr_exc_erro;
        END;

      END LOOP;
      -- Se não gerou nenhuma informação
      IF vr_tab_dados_arquivo.count = 0 THEN
        pr_dscritic := 'Dados nao encontrados! Arquivo nao gerado! ';
        RAISE vr_exc_erro;
      END IF;

      ------- Geração dos arquivos --------
      -- Pela chave, os registros estão ordenados
      --  por Cooperativa + Tipo do Arquivo
      vr_dsdchave := vr_tab_dados_arquivo.first;
      WHILE vr_dsdchave IS NOT NULL LOOP
        -- Para o primeiro registro do vetor
        -- OU
        -- Se mudou a Cooperativa
        IF vr_dsdchave = vr_tab_dados_arquivo.first
        OR vr_tab_dados_arquivo(vr_dsdchave).cdcooper <> vr_tab_dados_arquivo(vr_tab_dados_arquivo.prior(vr_dsdchave)).cdcooper THEN
          -- Localiza Nr Sequencia LOTE
          OPEN cr_crapsqg(pr_cdcooper => vr_tab_dados_arquivo(vr_dsdchave).cdcooper);
          FETCH cr_crapsqg
           INTO rw_crapsqg;
          -- Se não encontrou
          IF cr_crapsqg%NOTFOUND THEN
            CLOSE cr_crapsqg;
            -- Criaremos o registro na tabela
            BEGIN
              INSERT
                INTO crapsqg(cdcooper
                            ,nrseqqui
                            ,nrseqcan
                            ,nrseqinc)
                      VALUES(vr_tab_dados_arquivo(vr_dsdchave).cdcooper
                            ,0
                            ,0
                            ,0)
                    RETURNING ROWID
                             ,nrseqqui
                             ,nrseqcan
                             ,nrseqinc
                         INTO rw_crapsqg.ROWID
                             ,rw_crapsqg.nrseqqui
                             ,rw_crapsqg.nrseqcan
                             ,rw_crapsqg.nrseqinc;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Ao criar CRAPSQG -> '||SQLERRM;
                RAISE vr_exc_erro;
            END;
          ELSE
            CLOSE cr_crapsqg;
          END IF;
        END IF;
        -- Para o primeiro registro do vetor
        -- OU
        -- Se mudou a Cooperativa
        -- Se mudou o Tipo de Arquivo
        IF vr_dsdchave = vr_tab_dados_arquivo.first
        OR vr_tab_dados_arquivo(vr_dsdchave).cdcooper <> vr_tab_dados_arquivo(vr_tab_dados_arquivo.prior(vr_dsdchave)).cdcooper
        OR vr_tab_dados_arquivo(vr_dsdchave).tparquiv <> vr_tab_dados_arquivo(vr_tab_dados_arquivo.prior(vr_dsdchave)).tparquiv THEN
          -- Incrementar e Guardar a sequencia do Lote
          CASE vr_tab_dados_arquivo(vr_dsdchave).tparquiv
            WHEN 'BAIXA'        THEN
              -- Incrementar a sequencia
              rw_crapsqg.nrseqqui := rw_crapsqg.nrseqqui + 1;
              -- Guardar na variavel genérica
              vr_nrseqlot := rw_crapsqg.nrseqqui;
            WHEN 'CANCELAMENTO' THEN
              -- Incrementar a sequencia
              rw_crapsqg.nrseqcan := rw_crapsqg.nrseqcan + 1;
              -- Guardar na variavel genérica
              vr_nrseqlot := rw_crapsqg.nrseqcan;
            WHEN 'INCLUSAO'     THEN
              -- Incrementar a sequencia
              rw_crapsqg.nrseqinc := rw_crapsqg.nrseqinc + 1;
              -- Guardar na variavel genérica
              vr_nrseqlot := rw_crapsqg.nrseqinc;
            ELSE
              vr_nrseqlot := 0;
          END CASE;
          -- Atualizar a flag de primeiro registro
          vr_flgfirst := TRUE;
          -- Preparar o CLOB para armazenar as infos do arquivo
          dbms_lob.createtemporary(vr_clobarq, TRUE, dbms_lob.CALL);
          dbms_lob.open(vr_clobarq, dbms_lob.lob_readwrite);
        ELSE
          -- Não é o primeiro registro do tipo de arquivo
          vr_flgfirst := FALSE;
        END IF;

        -- No ultimo registro do vetor
        -- OU
        -- No ultimo registro da Cooper
        -- No ultimo registro do tipo do arquivo
        IF vr_dsdchave = vr_tab_dados_arquivo.last
        OR vr_tab_dados_arquivo(vr_dsdchave).cdcooper <> vr_tab_dados_arquivo(vr_tab_dados_arquivo.next(vr_dsdchave)).cdcooper
        OR vr_tab_dados_arquivo(vr_dsdchave).tparquiv <> vr_tab_dados_arquivo(vr_tab_dados_arquivo.next(vr_dsdchave)).tparquiv THEN
          -- Atualizar a flag de ultimo registro do tipo de arquivo
          vr_fllastof := TRUE;
        ELSE
          -- Não é o ultimo
          vr_fllastof := FALSE;
        END IF;

        -- No ultimo registro do vetor
        -- OU
        -- No ultimo registro da Cooper
        IF vr_dsdchave = vr_tab_dados_arquivo.last
        OR vr_tab_dados_arquivo(vr_dsdchave).cdcooper <> vr_tab_dados_arquivo(vr_tab_dados_arquivo.next(vr_dsdchave)).cdcooper THEN
          -- Atualizaremos a tabela de sequenciamento
          BEGIN
            UPDATE crapsqg
               SET crapsqg.nrseqqui = rw_crapsqg.nrseqqui
                  ,crapsqg.nrseqcan = rw_crapsqg.nrseqcan
                  ,crapsqg.nrseqinc = rw_crapsqg.nrseqinc
             WHERE ROWID = rw_crapsqg.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Ao atualizar CRAPSQG -> '||SQLERRM;
              RAISE vr_exc_erro;
          END;
        END IF;

        -- Atualiza o nr do lote
        vr_tab_dados_arquivo(vr_dsdchave).nrseqlot := vr_nrseqlot;

        -- Chamar rotina responsável conforme cada tipo de arquivo
        IF vr_tab_dados_arquivo(vr_dsdchave).tparquiv IN('BAIXA','CANCELAMENTO') THEN
          pc_gravames_gerac_arqs_bxa_cnc(pr_flgfirst        => vr_flgfirst                       --> Flag de primeiro registro
                                        ,pr_fllastof        => vr_fllastof                       --> Flag de ultimo registro
                                        ,pr_reg_dado_arquiv => vr_tab_dados_arquivo(vr_dsdchave) --> Registro com as informações atuais
                                        ,pr_clobaux         => vr_clobaux                        --> Varchar2 de Buffer para o arquivo
                                        ,pr_clobarq         => vr_clobarq                        --> CLOB para as informações do arquivo
                                        ,pr_nrseqreg        => vr_nrseqreg                       --> Quantidade total
                                        ,pr_cdcooper        => pr_cdcooper                       --> Codigo da cooperativa
                                        ,pr_dscritic        => pr_dscritic);                     --> Saida de erro
        ELSIF vr_tab_dados_arquivo(vr_dsdchave).tparquiv = 'INCLUSAO' THEN
          pc_gravames_gerac_arq_inclus(pr_flgfirst        => vr_flgfirst                       --> Flag de primeiro registro
                                      ,pr_fllastof        => vr_fllastof                       --> Flag de ultimo registro
                                      ,pr_reg_dado_arquiv => vr_tab_dados_arquivo(vr_dsdchave) --> Registro com as informações atuais
                                      ,pr_clobaux         => vr_clobaux                        --> Varchar2 de Buffer para o arquivo
                                      ,pr_clobarq         => vr_clobarq                        --> CLOB para as informações do arquivo
                                      ,pr_nrseqreg        => vr_nrseqreg                       --> Quantidade total
                                      ,pr_cdcooper        => pr_cdcooper                       --> Codigo da cooperativa
                                      ,pr_dscritic        => pr_dscritic);                     --> Saida de erro
        END IF;
        -- Sair se houve erro
        IF pr_dscritic IS NOT NULL THEN
          -- Concatenar descrição comum
          pr_dscritic := 'Ao chamar rotina especifica de '||vr_tab_dados_arquivo(vr_dsdchave).tparquiv||' -> '||pr_dscritic;
          -- Sair
          RAISE vr_exc_erro;
        END IF;

        -- Buscar o GRV para atualização
        OPEN cr_crapgrv (pr_cdcooper => vr_tab_dados_arquivo(vr_dsdchave).cdcooper
                        ,pr_nrdconta => vr_tab_dados_arquivo(vr_dsdchave).nrdconta
                        ,pr_tpctrpro => vr_tab_dados_arquivo(vr_dsdchave).tpctrpro
                        ,pr_nrctrpro => vr_tab_dados_arquivo(vr_dsdchave).nrctrpro
                        ,pr_dschassi => vr_tab_dados_arquivo(vr_dsdchave).dschassi
                        ,pr_nrseqlot => vr_tab_dados_arquivo(vr_dsdchave).nrseqlot
                        ,pr_cdoperac => vr_tab_dados_arquivo(vr_dsdchave).cdoperac);
        FETCH cr_crapgrv
         INTO vr_rowid_grv;
        -- Criar bloco para facilitar o tratamento de exceção
        DECLARE
          vr_dsoperac VARCHAR2(20);
        BEGIN
          -- Se não encontrou
          IF cr_crapgrv%NOTFOUND THEN
            -- Devemos criar
            vr_dsoperac := 'inserir';
            --
            INSERT INTO crapgrv
                       (cdcooper
                       ,nrdconta
                       ,tpctrpro
                       ,nrctrpro
                       ,dschassi
                       ,idseqbem
                       ,nrseqlot
                       ,cdoperac
                       ,nrseqreg
                       ,cdretlot
                       ,cdretgrv
                       ,cdretctr
                       ,dtenvgrv
                       ,dtretgrv
                       ,dscatbem
                       ,dstipbem
                       ,dsmarbem
                       ,dsbemfin
                       ,nrcpfbem
                       ,tpchassi
                       ,uflicenc
                       ,nranobem
                       ,nrmodbem
                       ,ufdplaca
                       ,nrdplaca
                       ,nrrenava)
                 VALUES(vr_tab_dados_arquivo(vr_dsdchave).cdcooper           --cdcooper
                       ,vr_tab_dados_arquivo(vr_dsdchave).nrdconta           --nrdconta
                       ,vr_tab_dados_arquivo(vr_dsdchave).tpctrpro           --tpctrpro
                       ,vr_tab_dados_arquivo(vr_dsdchave).nrctrpro           --nrctrpro
                       ,UPPER(vr_tab_dados_arquivo(vr_dsdchave).dschassi)    --dschassi
                       ,vr_tab_dados_arquivo(vr_dsdchave).idseqbem           --idseqbem
                       ,vr_tab_dados_arquivo(vr_dsdchave).nrseqlot           --nrseqlot
                       ,vr_tab_dados_arquivo(vr_dsdchave).cdoperac           --cdoperac
                       ,vr_nrseqreg                                          --nrseqreg
                       ,0                                                    --cdretlot
                       ,0                                                    --cdretgrv
                       ,0                                                    --cdretctr
                       ,sysdate                                              --dtenvgrv
                       ,NULL                                                 --dtretgrv
                       ,vr_tab_dados_arquivo(vr_dsdchave).dscatbem           --dscatbem
                       ,vr_tab_dados_arquivo(vr_dsdchave).dstipbem           --dstipbem
                       ,vr_tab_dados_arquivo(vr_dsdchave).dsmarbem           --dsmarbem
                       ,vr_tab_dados_arquivo(vr_dsdchave).dsbemfin           --dsbemfin
                       ,vr_tab_dados_arquivo(vr_dsdchave).nrcpfbem           --nrcpfbem
                       ,vr_tab_dados_arquivo(vr_dsdchave).tpchassi           --tpchassi
                       ,vr_tab_dados_arquivo(vr_dsdchave).uflicenc           --uflicenc
                       ,vr_tab_dados_arquivo(vr_dsdchave).nranobem           --nranobem
                       ,vr_tab_dados_arquivo(vr_dsdchave).nrmodbem           --nrmodbem
                       ,vr_tab_dados_arquivo(vr_dsdchave).ufdplaca           --ufdplaca
                       ,vr_tab_dados_arquivo(vr_dsdchave).nrdplaca           --nrdplaca
                       ,vr_tab_dados_arquivo(vr_dsdchave).nrrenava)          --nrrenava
              RETURNING ROWID
                   INTO vr_rowid_grv;
            -- Validar possível erro no insert
            IF vr_rowid_grv IS NULL THEN
              CLOSE cr_crapgrv;
              pr_dscritic := 'Nao houve insercao da CRAPGRV [Conta/Ctrato] -> '||vr_tab_dados_arquivo(vr_dsdchave).nrdconta||'/'||vr_tab_dados_arquivo(vr_dsdchave).nrctrpro;
              RAISE vr_exc_erro;
            END IF;
          ELSE
            -- Atualizaremos
            vr_dsoperac := 'atualizar';
            --
            UPDATE crapgrv
               SET nrseqreg = vr_nrseqreg
                  ,cdretlot = 0
                  ,cdretgrv = 0
                  ,cdretctr = 0
                  ,dtenvgrv = sysdate
                  ,dtretgrv = NULL
             WHERE ROWID = vr_rowid_grv;
            -- Validar possível erro no update
            IF SQL%NOTFOUND THEN
              CLOSE cr_crapgrv;
              pr_dscritic := 'Nao houve atualizacao da CRAPGRV [Conta/Ctrato/Rowid] -> '||vr_tab_dados_arquivo(vr_dsdchave).nrdconta||'/'||vr_tab_dados_arquivo(vr_dsdchave).nrctrpro||vr_rowid_grv;
              RAISE vr_exc_erro;
            END IF;
          END IF;
        EXCEPTION
          WHEN vr_exc_erro THEN
            RAISE vr_exc_erro;
          WHEN OTHERS THEN
            CLOSE cr_crapgrv;
            pr_dscritic := 'Ao '||vr_dsoperac||' CRAPGRV -> '||SQLERRM;
            RAISE vr_exc_erro;
        END;
        --
        CLOSE cr_crapgrv;

        -- No ultimo registro do arquivo
        IF vr_fllastof  THEN
          -- Faz o -1 pois quando gravar a GRV, ja passou pelo TRAILLER e
          --    somou +1, deixando divergente a sequencia **/
          vr_nrseqreg := vr_nrseqreg - 1;
          -- Efetuar a chamada final da pc_escreve_xml pra descarregar
          -- o buffer varchar2 dentro da variavel clob
          gene0002.pc_escreve_xml(pr_xml            => vr_clobarq
                                 ,pr_texto_completo => vr_clobaux
                                 ,pr_texto_novo     => ''
                                 ,pr_fecha_xml      => TRUE);
          -- Montagem do nome do arquivo (OPERACAO_COOP_NUMLOTE_AAAAMMDD.txt)
          vr_nmarquiv := substr(vr_tab_dados_arquivo(vr_dsdchave).tparquiv,1,1)
                      ||'_'
                      || to_char(vr_tab_dados_arquivo(vr_dsdchave).cdcooper,'fm000')
                      ||'_'
                      || to_char(vr_tab_dados_arquivo(vr_dsdchave).nrseqlot,'fm000000')
                      ||'_'
                      || to_char(vr_tab_dados_arquivo(vr_dsdchave).dtmvtolt,'yyyy')
                      || to_char(vr_tab_dados_arquivo(vr_dsdchave).dtmvtolt,'mm')
                      || to_char(vr_tab_dados_arquivo(vr_dsdchave).dtmvtolt,'dd')
                      || '.txt';
          -- Submeter a geração do arquivo txt puro até então apenas em memória
          gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
                                             ,pr_cdprogra  => 'GRAVAM'                      --> Programa chamador
                                             ,pr_dtmvtolt  => pr_dtmvtolt                   --> Data do movimento atual
                                             ,pr_dsxml     => vr_clobarq                    --> Arquivo XML de dados
                                             ,pr_cdrelato  => '0'                           --> Código do relatório
                                             ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarquiv --> Arquivo final com o path
                                             ,pr_flg_gerar => 'S'                           --> Geraçao na hora
                                             ,pr_des_erro  => pr_dscritic);                 --> Saída com erro

          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_clobarq);
          dbms_lob.freetemporary(vr_clobarq);
          -- Sair se houve erro
          IF pr_dscritic IS NOT NULL THEN
            -- Concatenar descrição comum
            pr_dscritic := 'Ao gerar o arquivo '||vr_nmarquiv||' -> '||pr_dscritic;
            -- Sair
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Buscar o próximo registro
        vr_dsdchave := vr_tab_dados_arquivo.next(vr_dsdchave);
      END LOOP; -- Fim geração dos arquivos
      -- Fim da rotina, efetuamos gravação das informações alteradas
      COMMIT;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Desfazer alterações
        ROLLBACK;
        -- Se foi retornado apenas código
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descrição
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
        
        -- Incrementar a mensagem de erro
        pr_dscritic := replace(pr_dscritic,'"','''');
        
        --Inclusão dos parâmetros apenas na exception, para não mostrar na tela - Chamado 660356
        --Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- Mensagem
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                      'ALERTA: '|| pr_dscritic ||
                                                      ',Cdcooper:'||pr_cdcooper||',Cdcoptel:'||pr_cdcoptel||
                                                      ',Tparquiv:'||pr_tparquiv||',Dtmvtolt:'||pr_dtmvtolt||
                                                      ','||vr_dsparam);
        
      WHEN OTHERS THEN
        -- Desfazer alterações
        ROLLBACK;
        -- Retornar erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro GRVM0001.pc_gravames_geracao_arquivo -> '||replace(SQLERRM,'"','''');

        --Padronização - Chamado 660394
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                      'ERRO: ' || pr_dscritic  ||
                                                      ',Cdcooper:'||pr_cdcooper||',Cdcoptel:'||pr_cdcoptel||
                                                      ',Tparquiv:'||pr_tparquiv||',Dtmvtolt:'||pr_dtmvtolt||
                                                      ','||vr_dsparam);

        --Inclusão na tabela de erros Oracle
        CECRED.pc_internal_exception( pr_compleme => pr_dscritic );

    END;
  END pc_gravames_geracao_arquivo;
  
  /*   Importacao arquivo RETORNO  */
  PROCEDURE pc_gravames_processa_retorno(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa conectada
                                        ,pr_cdcoptel  IN crapcop.cdcooper%TYPE -- Opção selecionada na tela
                                        ,pr_cdoperad  IN crapope.cdoperad%TYPE -- Código do operador
                                        ,pr_tparquiv  IN VARCHAR2              -- Tipo do arquivo selecionado na tela
                                        ,pr_dtmvtolt  IN DATE                  -- Data atual
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE -- Cod Critica de erro
                                        ,pr_dscritic OUT VARCHAR2) IS          -- Des Critica de erro
  BEGIN
    /* .............................................................................
     Programa: pc_gravames_processamento_retorno          Antigo: b1wgen0171.p/gravames_processamento_retorno
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Andrei/RKAM
     Data    : Maio/2016                     Ultima atualizacao: 23/10/2018

     Dados referentes ao programa:

     Frequencia:  Diario (on-line)
     Objetivo  :  Importacao arquivo RETORNO

     Alteracoes: 14/07/2016 - Ajuste para devolver corretamente as criticas quando houver um exceção
                              (Andrei - RKAM).
                              
                 28/07/2016 - Ajuste na rotina de importação dos arquivos de retorno para tratar corretamente
                              as informações coletadas do arquivo
                              (Adriano).

                 05/08/2016 - Ajuste para efetuar commit/rollback e corrigir updates sendo realizados
                              de forma errada
                              Ajuste para utilizar informações da pltable para encontrar o registro de 
                              bens do gravame
                              (Adriano)
                              
                 22/09/2016 - Ajuste para utilizar upper ao manipular a informação do chassi
                              pois em alguns casos ele foi gravado em minusculo e outros em maisculo
                              (Adriano - SD 527336)                              
                              
                 29/05/2017 - Ajuste das mensagens: neste caso são todas consideradas tpocorrencia = 4,
                            - Substituição do termo "ERRO" por "ALERTA",
                            - Padronização das mensagens para a tabela tbgen_prglog,
                            - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
                            - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
                            - Incluir nome do módulo logado em variável
                              (Ana - Envolti) - SD: 660356 e 660394           
                              
    ............................................................................. */
    DECLARE
       
      -- Cursor para validacao da cooperativa conectada
      CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%type) IS
      SELECT crapcop.cdcooper
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%rowtype;
      
      -- Cursor para validacao da cooperativa conectada
      CURSOR cr_crapcop_fin (pr_cdfingrv crapcop.cdfingrv%type) IS
      SELECT crapcop.cdcooper
            ,crapcop.cdfingrv
        FROM crapcop
       WHERE crapcop.cdfingrv = pr_cdfingrv;
      rw_crapcop_fin cr_crapcop_fin%rowtype;
    
      CURSOR cr_gravames(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrseqlot IN crapgrv.nrseqlot%TYPE
                        ,pr_cdoperac IN crapgrv.cdoperac%TYPE) IS
      SELECT crapgrv.rowid rowid_grv
            ,crapbpr.rowid rowid_bpr
       FROM crapbpr
           ,crapgrv
      WHERE crapgrv.cdcooper = pr_cdcooper
        AND crapgrv.nrseqlot = pr_nrseqlot
        AND crapgrv.cdoperac = pr_cdoperac
        AND crapbpr.cdcooper = crapgrv.cdcooper
        AND crapbpr.nrdconta = crapgrv.nrdconta
        AND crapbpr.tpctrpro = crapgrv.tpctrpro
        AND crapbpr.nrctrpro = crapgrv.nrctrpro
        AND TRIM(UPPER(crapbpr.dschassi)) = TRIM(UPPER(crapgrv.dschassi))
        AND crapbpr.flgalien = 1;
      
      CURSOR cr_crapgrv_bulk(pr_cdcooper IN crapgrv.cdcooper%TYPE) IS
      SELECT crapgrv.cdcooper
            ,crapgrv.nrdconta
            ,crapgrv.tpctrpro
            ,crapgrv.nrctrpro
            ,crapgrv.dschassi
            ,crapgrv.nrseqlot
            ,crapgrv.cdoperac
            ,crapgrv.rowid rowid_grv
       FROM crapgrv
       WHERE (pr_cdcooper = 0 OR crapgrv.cdcooper = pr_cdcooper);
      
      CURSOR cr_crapbpr(pr_cdcooper IN crapbpr.cdcooper%TYPE
                       ,pr_nrdconta IN crapbpr.nrdconta%TYPE
                       ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE
                       ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE
                       ,pr_dschassi IN crapbpr.dschassi%TYPE)IS
      SELECT crapbpr.rowid rowid_bpr
        FROM crapbpr
       WHERE crapbpr.cdcooper = pr_cdcooper
         AND crapbpr.nrdconta = pr_nrdconta
         AND crapbpr.tpctrpro = pr_tpctrpro
         AND crapbpr.nrctrpro = pr_nrctrpro
         AND TRIM(UPPER(crapbpr.dschassi)) = TRIM(UPPER(pr_dschassi))
         AND crapbpr.flgalien = 1;
      rw_crapbpr cr_crapbpr%ROWTYPE;
      
      TYPE typ_rec_crapgrv IS TABLE OF cr_crapgrv_bulk%ROWTYPE
         INDEX BY PLS_INTEGER;
      vr_tab_crapgrv_carga typ_rec_crapgrv;

      TYPE typ_tab_crapgrv IS TABLE OF cr_crapgrv_bulk%ROWTYPE
         INDEX BY VARCHAR2(70); 
      vr_tab_crapgrv typ_tab_crapgrv;
      
      --Tabela para receber arquivos lidos no unix
      vr_tab_crawarq TYP_SIMPLESTRINGARRAY:= TYP_SIMPLESTRINGARRAY();
    
      vr_cdcritic PLS_INTEGER := 0; -- Variavel interna para erros
      vr_dscritic varchar2(4000) := ''; -- Variavel interna para erros

      vr_nrseqreg PLS_INTEGER;           -- Sequenciador do registro na cooperativa
      vr_nmarqdir VARCHAR2(200);         -- Nome do diretorio
      vr_nmarqsav VARCHAR2(200);         -- Nome do diretorio
      vr_nmarqret VARCHAR2(100);         -- Nome do arquivo
      vr_cdcooper INTEGER;               -- Código da cooperativa
      vr_qtsubstr INTEGER;                
      vr_cdoperac INTEGER;               -- Operação
      vr_cdretlot INTEGER;               -- Código de retorno Ar. (HEADER)
      vr_nmtiparq VARCHAR2(100);         -- Tipo do arquivo
      vr_cdfingrv crapcop.cdfingrv%TYPE; -- Código da finalidade do gravame  
      vr_nmarquiv VARCHAR2(100);         -- Var para o nome dos arquivos
      vr_input_file  UTL_FILE.FILE_TYPE;
      vr_crapcop  BOOLEAN;
      vr_setlinha VARCHAR2(700);
      vr_nrseqlot INTEGER;               -- Número sequencial do lote
      vr_exc_erro EXCEPTION;             -- Tratamento de exceção
      vr_proximo_arq EXCEPTION;             -- Tratamento de exceção
      vr_cdretgrv INTEGER;                 --Código de retorno gravames (Det)
      vr_cdretctr INTEGER ;                  --Código de retorno do contrato (Det)
      vr_dschassi crapbpr.dschassi%TYPE; -- Número do chassi
      vr_nrgravam crapbpr.nrgravam%TYPE; -- Número do gravame
      vr_dtatugrv crapbpr.dtatugrv%TYPE; -- Data de registro do gravame 
      vr_comando   VARCHAR2(2000);
      vr_typ_saida VARCHAR2(100);
      vr_index_gravames VARCHAR2(70);
      
      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';

    BEGIN
	    --Incluir nome do módulo logado - Chamado 660394
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_processa_retorno');
      
      -- Validar opção informada
      IF pr_tparquiv NOT IN('TODAS','INCLUSAO','BAIXA','CANCELAMENTO') THEN
        
        vr_cdcritic := 0;
        vr_dscritic := ' Tipo invalido para Geracao do Arquivo! ';
        
        RAISE vr_exc_erro;
        
      END IF;
      
      --Buscar Diretorio Micros da CECRED
      vr_nmarqdir:= gene0001.fn_diretorio (pr_tpdireto => 'M' --> Usr/micros
                                          ,pr_cdcooper => 3
                                          ,pr_nmsubdir => 'gravames/retorno');
                                          
      --Buscar Diretorio Salvar da CECRED
      vr_nmarqsav:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/salvar/');                                          
                                        
      -- Validar existencia da cooperativa informada
      IF nvl(pr_cdcoptel,0) <> 0 THEN
        
        OPEN cr_crapcop(pr_cdcoptel);
        
        FETCH cr_crapcop INTO rw_crapcop;
        
        -- Gerar critica 794 se nao encontrar
        IF cr_crapcop%NOTFOUND THEN
          
          CLOSE cr_crapcop;
          
          vr_cdcritic := 794;
          -- Sair
          RAISE vr_exc_erro;
        
        ELSE
        
          CLOSE cr_crapcop;
          
        END IF;
        
        CASE pr_tparquiv
          WHEN 'BAIXA' THEN
            vr_nmarqret := 'RET_B_' || TRIM(to_char(rw_crapcop.cdcooper,'000')) || '_%.txt'; 
          WHEN 'CANCELAMENTO' THEN
            vr_nmarqret := 'RET_C_' || TRIM(to_char(rw_crapcop.cdcooper,'000')) || '_%.txt';             
          WHEN 'INCLUSAO' THEN
            vr_nmarqret := 'RET_I_' || TRIM(to_char(rw_crapcop.cdcooper,'000')) || '_%.txt'; 
          ELSE
            vr_nmarqret := 'RET_%_' || TRIM(to_char(rw_crapcop.cdcooper,'000')) || '_%.txt';   
          
        END CASE;
       
      /*** NAO SELECIONOU COOPERATIVA NA TELA (TODAS) **/
      ELSE
         
        CASE pr_tparquiv
          WHEN 'BAIXA' THEN
            vr_nmarqret := 'RET_B_%_%.txt'; 
          WHEN 'CANCELAMENTO' THEN
            vr_nmarqret := 'RET_C_%_%.txt';             
          WHEN 'INCLUSAO' THEN
            vr_nmarqret := 'RET_I_%_%.txt'; 
          ELSE
            vr_nmarqret := 'RET_%.txt';   
          
        END CASE;      
      
      END IF;
      
      -- Carregar PL Table com dados da tabela CRAWEPR
      OPEN cr_crapgrv_bulk(pr_cdcooper => nvl(pr_cdcoptel,0));
      LOOP
        FETCH cr_crapgrv_bulk BULK COLLECT INTO vr_tab_crapgrv_carga /* LIMIT 100000*/;
        EXIT WHEN vr_tab_crapgrv_carga.COUNT = 0;

        FOR idx IN vr_tab_crapgrv_carga.first..vr_tab_crapgrv_carga.last LOOP
          
          --Montar indice para tabela memoria
          vr_index_gravames:= lpad(vr_tab_crapgrv_carga(idx).cdcooper, 15, '0') ||
                              lpad(vr_tab_crapgrv_carga(idx).nrseqlot, 15, '0') ||
                              LPad(vr_tab_crapgrv_carga(idx).cdoperac, 15, '0') ||
                              lpad(UPPER(vr_tab_crapgrv_carga(idx).dschassi), 25, '0');
                              
          vr_tab_crapgrv(vr_index_gravames).cdcooper  := vr_tab_crapgrv_carga(idx).cdcooper;
          vr_tab_crapgrv(vr_index_gravames).nrdconta  := vr_tab_crapgrv_carga(idx).nrdconta;
          vr_tab_crapgrv(vr_index_gravames).tpctrpro  := vr_tab_crapgrv_carga(idx).tpctrpro;
          vr_tab_crapgrv(vr_index_gravames).nrctrpro  := vr_tab_crapgrv_carga(idx).nrctrpro;
          vr_tab_crapgrv(vr_index_gravames).dschassi  := UPPER(vr_tab_crapgrv_carga(idx).dschassi);
          vr_tab_crapgrv(vr_index_gravames).rowid_grv := vr_tab_crapgrv_carga(idx).rowid_grv;
          
        END LOOP;

      END LOOP;
      
      CLOSE cr_crapgrv_bulk;
      
      vr_tab_crapgrv_carga.delete; -- limpa dados do bulk ja armazenado em outra pl table
       
      --Buscar a lista de arquivos do diretorio
      gene0001.pc_lista_arquivos(pr_lista_arquivo => vr_tab_crawarq
                                ,pr_path          => vr_nmarqdir
                                ,pr_pesq          => vr_nmarqret);

      IF vr_tab_crawarq.COUNT() = 0 THEN
      
        --Nao possui arquivos para processar
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foram encontrados arquivos de retorno com parametros informados!';
        
        --Levantar Excecao sem erros
        RAISE vr_exc_erro;          
      END IF;
      
      /* EFETUA A LEITURA DE CADA ARQUIVO  */
      FOR idx IN 1..vr_tab_crawarq.COUNT() LOOP
        
        /** PEGA LETRA PARA IDENTIFICAR O TIPO DO ARQUIVO -> RET*  **/
        vr_nmtiparq := SUBSTR(vr_tab_crawarq(idx),instr(vr_tab_crawarq(idx),'/')+5,1);
        vr_nmarquiv := vr_nmarqdir || '/' || vr_tab_crawarq(idx);
        
        -- Abrir o arquivo para testá-lo
        gene0001.pc_abre_arquivo (pr_nmcaminh => vr_nmarquiv    --> Diretório do arquivo
                                 ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                 ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                 ,pr_des_erro => vr_dscritic);  --> Descricao do erro
          
        -- Se retornou erro
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
      END IF;
            
        -- Laco para leitura de linhas do arquivo
        BEGIN 
          LOOP
            -- Carrega handle do arquivo
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido
            
            vr_setlinha:= replace(replace(vr_setlinha,chr(10),''),chr(13),'');
            
            IF vr_setlinha LIKE '%HEADER DE CONTROLE%' THEN
              
              continue;
            
            --Header de lote
            ELSIF vr_setlinha LIKE '%HEADER%' THEN
              
              /** Tenta encontrar cdfingrv com 4 posicoes **/ 
              vr_cdfingrv := to_number(TRIM(SUBSTR(vr_setlinha,1,4)));
                  
              OPEN cr_crapcop_fin(pr_cdfingrv => vr_cdfingrv);
              
              FETCH cr_crapcop_fin INTO rw_crapcop_fin;
            
              --Se Encontrou
              vr_crapcop:= cr_crapcop_fin%FOUND;
    
              --Fechar Cursor
              CLOSE cr_crapcop_fin;
      
              IF vr_cdfingrv = 0 OR
                 NOT vr_crapcop  THEN 
    
                BEGIN 
                  /** Se eh zero ou nao achou, pode ser 15 posicoes **/
                  vr_cdfingrv := to_number(TRIM(SUBSTR(vr_setlinha,1,15)));
    EXCEPTION        
                  WHEN OTHERS THEN
                    /* Se deu erro, provavelmente pegou o substr com
                     caracteres dentro, significa que era com 4 carac.
                     mas nao achou crapcop que veio no arquivo  */
                    vr_cdcritic := 0;
                    vr_dscritic := 'ERRO na integracao do arquivo ' || vr_tab_crawarq(idx) || ' !';

                    --Padronização - Chamado 660394
                    -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                              ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                                  'ERRO: '|| vr_dscritic ||',Cdoperad:'||pr_cdoperad||
                                                                  ',Cdcooper:'||vr_cdcooper||',Dtmvtolt:'||pr_dtmvtolt||
                                                                  ',Cdcoptel:'||pr_cdcoptel||',Tparquiv:'||pr_tparquiv);

                    --Inclusão na tabela de erros Oracle
                    CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
                                                                                                                      
                    RAISE vr_proximo_arq;
                                     
                END;
                
                /** Se nao deu erro na atribuicao, pesquisa com 15pos.
                  Pq NO-ERROR? Pode ocorrer que nao encontre a COOP
                  com 4 caracteres pelo fato de realmente nao existir,
                  e ao tentar com 15, pode pegar as proximas colunas,
                  e nessa pode ocorrer de ter um caracter string no
                  conteudo.  */
                OPEN cr_crapcop_fin(pr_cdfingrv => vr_cdfingrv);
              
                FETCH cr_crapcop_fin INTO rw_crapcop_fin;
                
                IF cr_crapcop_fin%NOTFOUND THEN
                  
                  --Fechar Cursor
                  CLOSE cr_crapcop_fin;

        vr_cdcritic := 0;
                  vr_dscritic := 'ERRO na integracao do arquivo ' || vr_tab_crawarq(idx) || ' ! [COOP/15]';

        --Padronização - Chamado 660394
                  -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                                'ERRO: '|| vr_dscritic ||',Cdoperad:'||pr_cdoperad||
                                                                ',Cdcooper:'||vr_cdcooper||',Dtmvtolt:'||pr_dtmvtolt||
                                                                ',Cdcoptel:'||pr_cdcoptel||',Tparquiv:'||pr_tparquiv);
                     
                  
                  RAISE vr_proximo_arq;
                  
                ELSE

                  --Fechar Cursor
                  CLOSE cr_crapcop_fin;

                  /** Achou crapcop com 15 caracteres
                      11 eh a diferenca de 15 com 4, usado
                      para reposicionar os campos e colunas
                      nos substr's **/
                  vr_qtsubstr := 11;                

                END IF; 

              ELSE
                            
               /** Encontrou crapcop com 4 caracteres (cdfingrv) **/
                vr_qtsubstr := 0;
    
              END IF;
    
              vr_cdcooper := rw_crapcop_fin.cdcooper;          
    
              /*** A partir desse ponto, os SUBSTR serao tratados dinamicamente,
               somando a posicao inicial a variavel aux_qtsubstr por conta do
               tratamento de 4 ou 15 caracteres para o campo cdfingrv  ******/
              vr_nrseqlot := to_number(nvl(TRIM(SUBSTR(vr_setlinha,16 + vr_qtsubstr,7)),0));
    
              /*** Pega o Codigo de Retorno do Lote **/
              CASE vr_nmtiparq
                WHEN 'B'  THEN
                  vr_cdoperac := 3;
                  vr_cdretlot := to_number(nvl(trim(SUBSTR(vr_setlinha,85 + vr_qtsubstr,03)),0));
                WHEN 'C'  THEN 
                  vr_cdoperac := 2;
                  vr_cdretlot := to_number(nvl(trim(SUBSTR(vr_setlinha,85 + vr_qtsubstr,03)),0));
                WHEN 'I'  THEN 
                  vr_cdoperac := 1;
                  vr_cdretlot := to_number(nvl(trim(SUBSTR(vr_setlinha,60 + vr_qtsubstr,03)),0));
              END CASE;
  
              /** Se houve retorno com erro no HEADER do LOTE **/
              IF vr_cdretlot <> 0 THEN 
                       
                /** Atualiza todos GRV e BENS do LOTE com o Retorno **/
                FOR rw_gravames IN cr_gravames(pr_cdcooper => vr_cdcooper
                                              ,pr_nrseqlot => vr_nrseqlot
                                              ,pr_cdoperac => vr_cdoperac) LOOP

                  BEGIN
    
                    UPDATE crapgrv
                      SET  crapgrv.cdretlot = vr_cdretlot
                          ,crapgrv.cdretgrv = 0
                          ,crapgrv.cdretctr = 0
                          ,crapgrv.dtretgrv = sysdate
                     WHERE rowid = rw_gravames.rowid_grv;                
    
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_cdcritic := 0;
                      vr_dscritic := 'ERRO ao atualizar a tabela crapgrv na integracao do arquivo ' || vr_tab_crawarq(idx) || '.';
        
                      RAISE vr_proximo_arq;  
  
                  END;
    
                  /** Atualiza todos GRV e BENS do LOTE com o Retorno **/
  BEGIN
                    
                    UPDATE crapbpr 
                      SET  crapbpr.cdsitgrv = 3 /** Retorno com Erro */                      
                     WHERE rowid = rw_gravames.rowid_bpr;
                  
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_cdcritic := 0;
                      vr_dscritic := 'ERRO ao atualizar a tabela crapbpr na integracao do arquivo ' || vr_tab_crawarq(idx) || '.';
                      
                      RAISE vr_proximo_arq;     
                      
                  END;
    
                END LOOP;
    
                RAISE vr_proximo_arq;    

    END IF;    
       
            ELSIF NOT vr_setlinha LIKE '%HEADER%'   AND 
                  NOT vr_setlinha LIKE '%TRAILLER%' THEN 
        
              vr_nrseqlot := to_number(nvl(TRIM(SUBSTR(vr_setlinha,16 + vr_qtsubstr,7)),0));
              vr_nrseqreg := to_number(nvl(TRIM(SUBSTR(vr_setlinha,23 + vr_qtsubstr,6)),0));
                           
              IF vr_nmtiparq = 'I' THEN
    
                vr_cdretgrv := to_number(nvl(TRIM(SUBSTR(vr_setlinha,30 + vr_qtsubstr,3)),0));
                vr_cdretctr := to_number(nvl(TRIM(SUBSTR(vr_setlinha,33 + vr_qtsubstr,3)),0));
                vr_dschassi := TRIM(SUBSTR(vr_setlinha,36 + vr_qtsubstr,21));
              
              ELSE

                vr_cdretgrv := to_number(nvl(TRIM(SUBSTR(vr_setlinha,85 + vr_qtsubstr,3)),0));
                vr_cdretctr := 0;
                vr_dschassi := TRIM(SUBSTR(vr_setlinha,30 + vr_qtsubstr,21)); 
                  
      END IF; 
              
              --Montar indice para tabela memoria
              vr_index_gravames:= lpad(vr_cdcooper, 15, '0') ||
                                  lpad(vr_nrseqlot, 15, '0') ||
                                  LPad(vr_cdoperac, 15, '0') ||
                                  lpad(UPPER(vr_dschassi), 25, '0');
        
              IF vr_tab_crapgrv.exists(vr_index_gravames) THEN
           
                OPEN cr_crapbpr(pr_cdcooper => vr_tab_crapgrv(vr_index_gravames).cdcooper
                               ,pr_nrdconta => vr_tab_crapgrv(vr_index_gravames).nrdconta
                               ,pr_tpctrpro => vr_tab_crapgrv(vr_index_gravames).tpctrpro
                               ,pr_nrctrpro => vr_tab_crapgrv(vr_index_gravames).nrctrpro
                               ,pr_dschassi => vr_tab_crapgrv(vr_index_gravames).dschassi);
          
                FETCH cr_crapbpr INTO rw_crapbpr;                
    
                IF cr_crapbpr%FOUND THEN

                  CLOSE cr_crapbpr;
      
                  IF (vr_cdretgrv = 30  AND
                      vr_cdretctr = 90) OR /*Sucesso em ambos*/
                     (vr_cdretgrv = 30  AND
                      vr_cdretctr = 0 ) OR /*Sucesso GRV - nada CTR*/
                     (vr_cdretgrv = 0   AND
                      vr_cdretctr = 90) THEN /*Nada GRV - Sucesso CTR*/
      
                    IF vr_nmtiparq = 'I' THEN
          
                      vr_nrgravam := to_number(TRIM(SUBSTR(vr_setlinha,62 + vr_qtsubstr,8)));   
        
                      /** Validar se data veio Zerada **/
                      IF to_number(nvl(TRIM(SUBSTR(vr_setlinha,74 + vr_qtsubstr,2)),0)) = 0 OR
                         to_number(nvl(TRIM(SUBSTR(vr_setlinha,76 + vr_qtsubstr,2)),0)) = 0 OR
                         to_number(nvl(TRIM(SUBSTR(vr_setlinha,70 + vr_qtsubstr,4)),0)) = 0 THEN       
     
                        vr_dtatugrv := pr_dtmvtolt;
       
                      ELSE
               
                        vr_dtatugrv := to_date(TRIM(SUBSTR(vr_setlinha,76 + vr_qtsubstr,2)) || '/' || TRIM(SUBSTR(vr_setlinha,74 + vr_qtsubstr,2)) || '/' || 
                                       TRIM(SUBSTR(vr_setlinha,70 + vr_qtsubstr,4))  ,'DD/MM/RRRR');
                               
                        BEGIN
                             
                          UPDATE crapbpr
                             SET crapbpr.dtatugrv = vr_dtatugrv
                                ,crapbpr.nrgravam = vr_nrgravam
                                ,crapbpr.flgalfid = 1
                                ,crapbpr.flginclu = 0
                                ,crapbpr.cdsitgrv = 2 --Alienado OK
                          WHERE ROWID = rw_crapbpr.rowid_bpr;
    
                        EXCEPTION
                          WHEN OTHERS THEN
                             vr_cdcritic := 0;
                             vr_dscritic := 'Erro ao atualizar o registro de bens da prospota [crapbpr] -> '||SQLERRM;
   
                             --Padronização - Chamado 660394
                             -- Gera log
                             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                                       ,pr_nmarqlog     => 'gravam.log'
                                                       ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                                           ' - '||vr_cdprogra||' --> '|| 
                                                                           'ERRO: '|| vr_dscritic ||',Cdoperad:'||pr_cdoperad||
                                                                           ',Cdcooper:'||vr_cdcooper||',Dtmvtolt:'||pr_dtmvtolt||
                                                                           ',Cdcoptel:'||pr_cdcoptel||',Tparquiv:'||pr_tparquiv);
      
                             --Inclusão na tabela de erros Oracle
                             CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
                        END;       
        
        END IF;
        
                    ELSIF vr_nmtiparq = 'B' THEN
                      
                      BEGIN
                          
                        UPDATE crapbpr
                           SET crapbpr.flgbaixa = 0
                              ,crapbpr.cdsitgrv = 4 --Baixado OK
                              ,crapbpr.flginclu = 0
                        WHERE ROWID = rw_crapbpr.rowid_bpr;
                        
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_cdcritic := 0;
                          vr_dscritic := 'Erro ao atualizar o registro de bens da prospota [crapbpr] -> '||SQLERRM;
                  
                          --Padronização - Chamado 660394
                          -- Gera log
                          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                                    ,pr_nmarqlog     => 'gravam.log'
                                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                                        ' - '||vr_cdprogra||' --> '|| 
                                                                        'ERRO: '|| vr_dscritic ||',Cdoperad:'||pr_cdoperad||
                                                                        ',Cdcooper:'||vr_cdcooper||',Dtmvtolt:'||pr_dtmvtolt||
                                                                        ',Cdcoptel:'||pr_cdcoptel||',Tparquiv:'||pr_tparquiv);
        
                          --Inclusão na tabela de erros Oracle
                          CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
                      END;       

                    ELSIF vr_nmtiparq = 'C' THEN
      
                      BEGIN
      
                        UPDATE crapbpr
                           SET crapbpr.flcancel = 0
                              ,crapbpr.cdsitgrv = 5 --Cancelado OK
                              ,crapbpr.flginclu = 0
                        WHERE ROWID = rw_crapbpr.rowid_bpr;
        
                      EXCEPTION
                        WHEN OTHERS THEN
        vr_cdcritic := 0;
                          vr_dscritic := 'Erro ao atualizar o registro de bens da prospota [crapbpr] -> '||SQLERRM;                                      
        
                          --Padronização - Chamado 660394
        -- Gera log
                          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                                        'ERRO: '|| vr_dscritic ||',Cdoperad:'||pr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Dtmvtolt:'||pr_dtmvtolt||
                                                                        ',Cdcoptel:'||pr_cdcoptel||',Tparquiv:'||pr_tparquiv);
      
                          --Inclusão na tabela de erros Oracle
                          CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
                      END;       
      
    END IF;
                        
                    BEGIN
    
                      UPDATE crapgrv
                         SET crapgrv.dtretgrv = sysdate
                            ,crapgrv.cdretlot = 0  /* Sucesso no lote */
                            ,crapgrv.cdretgrv = vr_cdretgrv
                            ,crapgrv.cdretctr = vr_cdretctr
                      WHERE ROWID = vr_tab_crapgrv(vr_index_gravames).rowid_grv;
                        
  EXCEPTION
                      WHEN OTHERS THEN
                        vr_cdcritic := 0;
                        vr_dscritic := 'Erro ao atualizar o registro de gravame [crapgrv] -> '||SQLERRM;                                      
      
                        --Padronização - Chamado 660394
                        -- Gera log
                        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                                  ,pr_nmarqlog     => 'gravam.log'
                                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                                      ' - '||vr_cdprogra||' --> '|| 
                                                                      'ERRO: '|| vr_dscritic ||',Cdoperad:'||pr_cdoperad||
                                                                      ',Cdcooper:'||vr_cdcooper||',Dtmvtolt:'||pr_dtmvtolt||
                                                                      ',Cdcoptel:'||pr_cdcoptel||',Tparquiv:'||pr_tparquiv);
      
                        --Inclusão na tabela de erros Oracle
                        CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
        
                    END;                     

                  ELSE
                    
                    BEGIN
                          
                      UPDATE crapbpr
                         SET crapbpr.cdsitgrv = 3 --Retorno com erro
                      WHERE ROWID = rw_crapbpr.rowid_bpr;
                        
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_cdcritic := 0;
                        vr_dscritic := 'Erro ao atualizar o registro de bens da prospota [crapbpr] -> '||SQLERRM; 
                  
                        --Padronização - Chamado 660394
        -- Gera log
                        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                                      'ERRO: '|| vr_dscritic ||',Cdoperad:'||pr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Dtmvtolt:'||pr_dtmvtolt||
                                                                      ',Cdcoptel:'||pr_cdcoptel||',Tparquiv:'||pr_tparquiv);

                        --Inclusão na tabela de erros Oracle
                        CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
      
                    END; 
           
                    BEGIN
        
                      UPDATE crapgrv
                         SET crapgrv.dtretgrv = sysdate
                            ,crapgrv.cdretlot = 0  /* Sucesso no lote */
                            ,crapgrv.cdretgrv = vr_cdretgrv
                            ,crapgrv.cdretctr = vr_cdretctr
                      WHERE ROWID = vr_tab_crapgrv(vr_index_gravames).rowid_grv;
    
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_cdcritic := 0;
                        vr_dscritic := 'Erro ao atualizar o registro de gravame [crapgrv] -> '||SQLERRM;                                      
                  
      --Padronização - Chamado 660394
      -- Gera log
                        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                                      'ERRO: '|| vr_dscritic ||',Cdoperad:'||pr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Dtmvtolt:'||pr_dtmvtolt||
                                                                      ',Cdcoptel:'||pr_cdcoptel||',Tparquiv:'||pr_tparquiv);

      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
   
                    END;    

                  END IF; 
                  
                ELSE
                 
                  CLOSE cr_crapbpr;   
                  
                  vr_cdcritic := 0;
                  vr_dscritic := ' Registro tipo ' || vr_nmtiparq     ||
                                 ' Coop:' || to_char(vr_cdcooper,'00') ||
                                 ' Lote:' || to_char(vr_nrseqlot)      ||
                                 ' Chassi: ' || vr_dschassi           ||
                                 ' nao Integrado! [BPR]';                                      
                    
                  --Padronização - Chamado 660394
                  -- Gera log
                  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_nmarqlog     => 'gravam.log'
                                            ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                                ' - '||vr_cdprogra||' --> '|| 
                                                                'ERRO: '|| vr_dscritic ||',Cdoperad:'||pr_cdoperad||
                                                                ',Cdcooper:'||vr_cdcooper||',Dtmvtolt:'||pr_dtmvtolt||
                                                                ',Cdcoptel:'||pr_cdcoptel||',Tparquiv:'||pr_tparquiv);
                    
                  
                END IF;
                
              ELSE
               
                vr_cdcritic := 0;
                vr_dscritic := ' Registro tipo ' || vr_nmtiparq     ||
                               ' Coop:' || to_char(vr_cdcooper,'00') ||
                               ' Lote:' || to_char(vr_nrseqlot)      ||
                               ' Chassi: ' || vr_dschassi           ||
                               ' nao Integrado! [GRV]';                                      
                  
                --Padronização - Chamado 660394
                -- Gera log
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_nmarqlog     => 'gravam.log'
                                          ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                              ' - '||vr_cdprogra||' --> '|| 
                                                              'ERRO: '|| vr_dscritic ||',Cdoperad:'||pr_cdoperad||
                                                              ',Cdcooper:'||vr_cdcooper||',Dtmvtolt:'||pr_dtmvtolt||
                                                              ',Cdcoptel:'||pr_cdcoptel||',Tparquiv:'||pr_tparquiv);
                  
              END IF;
              
            END IF;
                    
          END LOOP;
        EXCEPTION
          WHEN no_data_found THEN
            -- Acabou a leitura
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
            NULL;
          WHEN vr_proximo_arq THEN
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
            continue;
            
        END;  
        
        /** Copia o arquivo processado  **/
        -- Comando para mover arquivo
        vr_comando:= 'cp '||vr_nmarqdir||'/' || vr_tab_crawarq(idx) || ' ' || vr_nmarqdir||'/processado/ 2> /dev/null';
                      
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
                                            
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
                        
          --Monta mensagem de critica
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando||' - '||vr_dscritic;
                        
          -- retornando ao programa chamador
          RAISE vr_exc_erro;
                        
        END IF;
        
        /** Move o arquivo processado  **/
        -- Comando para mover arquivo
        vr_comando:= 'mv '||vr_nmarqdir||'/' || vr_tab_crawarq(idx) || ' ' || vr_nmarqsav||' 2> /dev/null';
                      
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
                                            
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
                        
          --Monta mensagem de critica
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando||' - '||vr_dscritic;
                        
          -- retornando ao programa chamador
          RAISE vr_exc_erro;
                        
        END IF;
              
        --Commit das alterações para cada arquivo
        COMMIT;
                  
      END LOOP;  
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        
        -- Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;

        --Inclusão dos parâmetros apenas na exception, para não mostrar na tela
        --Padronização - Chamado 660394
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- Mensagem
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                      'ERRO: '|| pr_dscritic ||',Cdoperad:'||pr_cdoperad||
                                                      ',Cdcooper:'||vr_cdcooper||',Dtmvtolt:'||pr_dtmvtolt||
                                                      ',Cdcoptel:'||pr_cdcoptel||',Tparquiv:'||pr_tparquiv);

    ROLLBACK;
        
      WHEN OTHERS THEN
        
        -- Retornar erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro GRVM0001.pc_gravames_processa_retorno -> '||SQLERRM;

        --Padronização - Chamado 660394
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                      'ERRO: '|| pr_dscritic ||',Cdoperad:'||pr_cdoperad||
                                                      ',Cdcooper:'||vr_cdcooper||',Dtmvtolt:'||pr_dtmvtolt||
                                                      ',Cdcoptel:'||pr_cdcoptel||',Tparquiv:'||pr_tparquiv);

        --Inclusão na tabela de erros Oracle
        CECRED.pc_internal_exception( pr_compleme => pr_dscritic );

    ROLLBACK;

    END;
  END pc_gravames_processa_retorno;
  
  /* Geração de arquivo XML com as informações pendentes de envio */
  PROCEDURE pc_gravames_geracao_xml(pr_cdcooper IN crapcop.cdcooper%TYPE  -- Cooperativa conectada
                                   ,pr_tparquiv IN VARCHAR2               -- Tipo do arquivo (Todas, Inclusao, Baixa ou Cancelamento)
                                   ,pr_nrregist IN NUMBER                 -- Quantidade de registros
                                   ,pr_nriniseq IN NUMBER                 -- Registro inicial
                                   ,pr_retxml   OUT XMLType               -- Arquivo de retorno do XML
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE -- Cod Critica de erro
                                   ,pr_dscritic OUT VARCHAR2) IS          -- Des Critica de erro
  BEGIN
    /* .............................................................................
     Programa: pc_gravames_geracao_xml          
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Marcos/Envolti
     Data    : Outubro/2018                     Ultima atualizacao:  

     Dados referentes ao programa:

     Frequencia:  Diario (on-line)
     Objetivo  : Gerar mensagens XML dos GRAVAME pendentes

     Alteracoes: 
     
    ............................................................................. */
    DECLARE

      -- Cursor para validacao da cooperativa conectada
      CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%type) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nrtelvoz
              ,cop.nmcidade
              ,cop.cdufdcop
              ,cop.cdfingrv
              ,cop.cdsubgrv
              ,cop.cdloggrv
              ,cop.dsendcop
              ,cop.nrendcop
              ,cop.dscomple
              ,cop.nmbairro
              ,cop.nrcepend
              ,cop.nrdocnpj
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_cop cr_crapcop%rowtype;

      -- Buscar todas as informações de alienação e bens
      CURSOR cr_crapbpr IS
        SELECT /*+ PARALLEL(bpr 20) */
               bpr.rowid
              ,ass.nrdconta
              ,ass.nmprimtl
              ,decode(ass.inpessoa,3,2,ass.inpessoa) inpessoa
              ,wpr.nrctremp
              ,wpr.flgokgrv
              ,wpr.dtdpagto
              ,wpr.qtpreemp
              ,wpr.dtmvtolt
              ,wpr.vlemprst
              ,wpr.vlpreemp
              ,wpr.dtlibera
              ,wpr.txmensal
              ,LOWER(wpr.cdoperad) cdoperad
              ,bpr.flginclu
              ,bpr.cdsitgrv
              ,bpr.tpinclus
              ,bpr.flcancel
              ,bpr.tpcancel
              ,bpr.tpctrpro
              ,bpr.flgbaixa
              ,bpr.tpdbaixa
              ,bpr.nrcpfbem
              ,bpr.nrctrpro
              ,bpr.idseqbem
              ,UPPER(TRIM(bpr.dschassi)) dschassi
              ,bpr.tpchassi
              ,UPPER(bpr.uflicenc) uflicenc
              ,bpr.nranobem
              ,bpr.nrmodbem
              ,bpr.ufplnovo
              ,bpr.nrplnovo
              ,bpr.nrrenovo
              ,bpr.ufdplaca
              ,bpr.nrdplaca
              ,bpr.nrrenava
              ,ass.nrcpfcgc
              ,epr.tpemprst
              ,epr.inliquid 
              ,lcr.flgcobmu
              ,fin.tpfinali
              ,wpr.cdfinemp
          FROM crapass ass
              ,crawepr wpr
              ,craplcr lcr
              ,crapfin fin 
              ,crapbpr bpr
         full outer join crapepr epr on (epr.cdcooper = bpr.cdcooper and epr.nrdconta = bpr.nrdconta and epr.nrctremp = bpr.nrctrpro)
         WHERE bpr.cdcooper = pr_cdcooper
           AND bpr.flgalien   = 1 -- Sim
           AND wpr.cdcooper   = bpr.cdcooper
           AND wpr.nrdconta   = bpr.nrdconta
           AND wpr.nrctremp   = bpr.nrctrpro
           AND wpr.insitapr IN(1,3) -- Aprovados
           AND wpr.cdcooper   = lcr.cdcooper
           AND wpr.cdlcremp   = lcr.cdlcremp
           AND wpr.cdcooper   = fin.cdcooper
           AND wpr.cdfinemp   = fin.cdfinemp
           AND ass.cdcooper   = bpr.cdcooper
           AND ass.nrdconta   = bpr.nrdconta
           AND (  -- Bloco INCLUSAO ou Consulta
                 ( pr_tparquiv IN ('INCLUSAO','CONSULTA','TODAS')
                 AND  bpr.tpctrpro   = 90
                 AND  bpr.flgbaixa   = 0      -- Não baixados
                 AND  bpr.flcancel   = 0      -- Não cancelados
                 AND  nvl(epr.inliquid,0) = 0 -- APENAS NÃO LIQUIDADO, CASO NULO TRATAR COMO "0 - NÃO LIQUIDADO"
                 AND  bpr.flginclu   = 1      -- INCLUSAO SOLICITADA
                 AND ( -- Inclusão Automática com situação Nao Enviada ou Proces. com Erro e Somente Portabilidade
                       (pr_tparquiv IN ('INCLUSAO','TODAS') AND bpr.cdsitgrv in (0,3) AND bpr.tpinclus = 'A' AND empr0001.fn_tipo_finalidade(pr_cdcooper,wpr.cdfinemp) = 2)
                      OR
                       -- OU, Inclusão manual com situação Alienado      
                       (pr_tparquiv IN ('CONSULTA','TODAS') AND bpr.cdsitgrv = 2 AND bpr.tpinclus = 'M')
                     )
                  )   
                  -- Bloco BAIXA --
                  OR (pr_tparquiv IN('BAIXA','TODAS')
                 AND  bpr.tpctrpro   in(90,99)  -- Tbm Para BENS excluidos na ADITIV
                 AND  bpr.flgbaixa   = 1        -- BAIXA SOLICITADA
                 AND  bpr.cdsitgrv  <> 1        -- Nao enviado
                 AND  bpr.tpdbaixa   = 'A'      -- Automatica
                 AND  bpr.flblqjud  <> 1)       -- Nao bloqueado judicial

                 -- Bloco CANCELAMENTO --
                  OR (pr_tparquiv IN('CANCELAMENTO','TODAS')
                 AND  bpr.tpctrpro   = 90
                 AND  bpr.flcancel   = 1    -- CANCELAMENTO SOLICITADO
                 AND  bpr.tpcancel   = 'A'  -- Automatica
                 AND  bpr.cdsitgrv  <> 1    -- Nao enviado
                 AND  bpr.flblqjud  <> 1)   -- Nao bloqueado judicial

               );

      -- Busca de todas as agências por operador
      CURSOR cr_crapope IS
        SELECT ope.cdcooper
              ,LOWER(ope.cdoperad) cdoperad
              ,age.nmcidade
              ,age.cdufdcop
          FROM crapope ope
              ,crapage age
         WHERE ope.cdcooper = age.cdcooper
           AND ope.cdagenci = age.cdagenci;

      -- Busca de todos os municipios
      CURSOR cr_crapmun IS
        SELECT cdcidade
              ,dscidade
              ,cdestado
          FROM crapmun;
      
      -- Busca CNPJ lojista
      CURSOR cr_craploj(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE
                       ,pr_nrctremp crawepr.nrctremp%TYPE) IS
        SELECT tve.nrcpf
          FROM tbepr_cdc_emprestimo tce 
              ,tbepr_cdc_vendedor   tve               
         WHERE tce.cdcooper = pr_cdcooper
           AND tce.nrdconta = pr_nrdconta
           AND tce.nrctremp = pr_nrctremp
           AND tce.idvendedor = tve.idvendedor;
      
      -- Tipo e tabela para armazenar as cidades e ufs
      -- dos operadores observando a agencia do mesmo
      TYPE typ_reg_endere_ageope IS
        RECORD (nmcidade crapage.nmcidade%TYPE
               ,cdufdcop crapage.cdufdcop%TYPE);
      TYPE typ_tab_endere_ageope IS
        TABLE OF typ_reg_endere_ageope
          INDEX BY VARCHAR2(15);
      vr_tab_endere_ageope typ_tab_endere_ageope;

      -- Tabela para armazenar o codigo do municipio conforme descrição
      TYPE typ_tab_munici IS
        TABLE OF crapmun.cdcidade%TYPE
          INDEX BY VARCHAR2(52); -- Cdestado(2)+Dscidade(50)
      vr_tab_munici typ_tab_munici;

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';

      --Variável para complementar msg erro na exception
      vr_dsparam VARCHAR2(1000);
      
      vr_tparquiv VARCHAR2(12);          -- Descricao da operação
      vr_cdoperac PLS_INTEGER;           -- Codigo da operação
      vr_nmprimtl crapass.nmprimtl%TYPE; -- Nome do proprietario do bem
      vr_nrcpfbem crapass.nrcpfcgc%TYPE; -- Cpf do proprietário do bem
      vr_nrcpfven crapass.nrcpfcgc%TYPE; -- CPF do vendedor (Lojista)
      vr_dtvencto DATE;                  -- Data do ultimo vencimento
      vr_nrdddenc VARCHAR2(10);          -- DDD do Telefone do Credor
      vr_nrtelenc VARCHAR2(10);          -- Telefone do Credor
      vr_cdcidcre crapmun.cdcidade%TYPE; -- Municipio do Credor
      vr_cdcidcli crapmun.cdcidade%TYPE; -- Municipio do Cliente
      vr_nrdddass VARCHAR2(10);          -- DDD do Telefone do Cliente
      vr_nrtelass VARCHAR2(10);          -- Telefone do Cliente
      vr_prmulbs  NUMBER(5,2);           -- Percentual Multa Manter Valor
      vr_prmulta  NUMBER(5,2);           -- Percentual Multa
      
      vr_clobxml CLOB;                   -- CLOB para armazenamento das informações do arquivo
      vr_clobaux VARCHAR2(32767);        -- Var auxiliar para montagem do arquivo
      vr_xmltemp VARCHAR2(32767);        -- Var auxiliar para montagem do arquivo

      vr_exc_erro EXCEPTION;             -- Tratamento de exceção

      -- Navegação
      vr_contador INTEGER := 0; -- Contador p/ posicao no XML
  

    BEGIN
	    --Incluir nome do módulo logado - Chamado 660394
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_geracao_xml');

      -- Validar existencia da cooperativa informada
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_cop;
      -- Gerar critica 794 se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        pr_cdcritic := 794;
        -- Sair
        RETURN;
      ELSE
        CLOSE cr_crapcop;
        -- Continuaremos
      END IF;
      
      -- Validar se a Cooperativa tem comunicação Gravames Online
      IF fn_tem_gravame_online(pr_cdcooper) = 'N' THEN
        -- Não prosseguimos pois a Cooperativa usa mais envio em lote
        pr_cdcritic := 0;
        pr_dscritic := 'Cooperativa com comunicacao GRAVAMES Lote - Envio Online nao permitido!';
        RAISE vr_exc_erro; 
      END IF;

      -- Validar opção informada
      IF pr_tparquiv NOT IN('TODAS','CONSULTA','INCLUSAO','BAIXA','CANCELAMENTO') THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Tipo invalido para Geracao do Arquivo! ';
        RAISE vr_exc_erro;
      END IF;
      
      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

      -- Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_clobaux
                             ,'<?xml version="1.0" encoding="UTF-8"?><Root><gravameB3>');
                                  
      -- Buscar todas as informações de alienação e bens
      FOR rw_bpr IN cr_crapbpr LOOP
        
        -- Contagem de registros
        vr_contador := vr_contador + 1;
      
        -- Tratar paginação
        IF pr_nrregist > 0 AND ((vr_contador >= pr_nriniseq) AND (vr_contador < (pr_nriniseq + pr_nrregist))) THEN
        
          --Guarda variáveis para complementar msg erro na exception
          vr_dsparam := 'Nrdconta:'||rw_bpr.nrdconta||',Nrctremp:'||rw_bpr.nrctremp||
                        'Nrcpfcgc:'||rw_bpr.nrcpfbem||',Inpessoa:'||rw_bpr.inpessoa;

          -- Quando escolhido todas, temos que avaliar o registro atual pra definir sua operação
          IF pr_tparquiv = 'TODAS' THEN
            -- Inclusão
            IF rw_bpr.flginclu = 1 AND rw_bpr.flgbaixa = 0 AND rw_bpr.flcancel = 0  AND rw_bpr.cdsitgrv in(0,3) AND rw_bpr.tpinclus = 'A' THEN
              vr_tparquiv := 'INCLUSAO';
            -- Consulta
            ELSIF rw_bpr.flginclu = 1 AND rw_bpr.flgbaixa = 0 AND rw_bpr.flcancel = 0  AND rw_bpr.cdsitgrv = 2 AND rw_bpr.tpinclus = 'M' THEN
              vr_tparquiv := 'CONSULTA';
            -- Cancelamento
            ELSIF rw_bpr.flcancel = 1 AND rw_bpr.tpcancel = 'A' THEN
              vr_tparquiv := 'CANCELAMENTO';
            -- Baixa
            ELSIF rw_bpr.flgbaixa = 1 AND rw_bpr.tpdbaixa = 'A' AND rw_bpr.tpctrpro IN(90,99) THEN
              vr_tparquiv := 'BAIXA';
            END IF;
          ELSE
            -- Usar a opção escolhida na tela
            vr_tparquiv := pr_tparquiv;
          END IF;

          -- Buscar o codigo da operação
          CASE vr_tparquiv
            WHEN 'BAIXA'        THEN
              vr_cdoperac := 3;
            WHEN 'CANCELAMENTO' THEN
              vr_cdoperac := 2;
            WHEN 'CONSULTA' THEN
              vr_cdoperac := 4;
            WHEN 'INCLUSAO'     THEN
              vr_cdoperac := 1;
            ELSE
              vr_cdoperac := 0;
          END CASE;

          -- Default é as informações do cooperado
          vr_nmprimtl := rw_bpr.nmprimtl;
          vr_nrcpfbem := rw_bpr.nrcpfcgc;
          
          IF vr_nrcpfbem <> 0 THEN
          
            /* Procedimento para busca do emitente (Inverveniente, se houver) */
            pc_busca_emitente(pr_cdcooper => rw_cop.cdcooper
                             ,pr_nrdconta => rw_bpr.nrdconta
                             ,pr_nrctremp => rw_bpr.nrctremp
                             ,pr_nrcpfbem => rw_bpr.nrcpfbem
                             ,pr_nrcpfemi => vr_nrcpfbem
                             ,pr_nmprimtl => vr_nmprimtl);
          
          END IF;
          
          -- Somente para inclusão
          IF vr_cdoperac = 1 THEN
            
            -- Carregar as tabelas de memória caso já não tenha sido feito
            IF vr_tab_endere_ageope.count() = 0 THEN
              -- Busca de todas as agências por operador
              FOR rw_ope IN cr_crapope LOOP
                -- Armazenar armazenar as cidades e ufs
                -- dos operadores observando a agencia do mesmo
                vr_tab_endere_ageope(lpad(rw_ope.cdcooper,5,'0')||rpad(rw_ope.cdoperad,10,' ')).nmcidade := rw_ope.nmcidade;
                vr_tab_endere_ageope(lpad(rw_ope.cdcooper,5,'0')||rpad(rw_ope.cdoperad,10,' ')).cdufdcop := rw_ope.cdufdcop;
              END LOOP;
            END IF;
            IF vr_tab_munici.count() = 0 THEN
              -- Busca de todos os municipios
              FOR rw_mun IN cr_crapmun LOOP
                -- Adicionar a tabela o codigo pela chave UF + DsCidade
                vr_tab_munici(rpad(rw_mun.cdestado,2,' ')||rpad(rw_mun.dscidade,50,' ')) := rw_mun.cdcidade;
              END LOOP;
            END IF;
          
            -- Calcular data do ultimo vencimento considerando
            -- a data do primeiro pagamento e quantidade de parcelas
            vr_dtvencto := add_months(rw_bpr.dtdpagto,rw_bpr.qtpreemp-1);

            -- Se linha cobra Multa
            IF rw_bpr.flgcobmu = 1 THEN
              -- Busca o percentual de multa se ainda não buscado
              IF vr_prmulbs IS NULL THEN
                vr_prmulbs := gene0002.fn_char_para_number(  
                                      substr(tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                                                       ,pr_nmsistem => 'CRED'
                                                                       ,pr_tptabela => 'USUARI'
                                                                       ,pr_cdempres => 11
                                                                       ,pr_cdacesso => 'PAREMPCTL'
                                                                       ,pr_tpregist => 1),1,5));
              END IF;
              -- Copiar
              vr_prmulta := vr_prmulbs;
            ELSE
              vr_prmulta := 0;
            END IF;

            -- Separar DDD do Credor
            vr_nrdddenc := '0' || TRIM(REPLACE(gene0002.fn_busca_entrada(1,rw_cop.nrtelvoz,')'),'(',''));
            -- Separar Telefone do Credor
            vr_nrtelenc := TRIM(REPLACE(gene0002.fn_busca_entrada(2,rw_cop.nrtelvoz,')'),'-',''));

            -- Buscar municipio do credor
            IF vr_tab_munici.exists(rpad(rw_cop.cdufdcop,2,' ')||rpad(rw_cop.nmcidade,50,' ')) THEN
              -- Usamos o código encontrado
              vr_cdcidcre := vr_tab_munici(rpad(rw_cop.cdufdcop,2,' ')||rpad(rw_cop.nmcidade,50,' '));
            ELSE
              -- Usamos Codigo de BLUMENAU-SC
              vr_cdcidcre := 8047;
            END IF;

            -- BUscar o endereço do cliente
            rw_enc := NULL;
            OPEN cr_crapenc(pr_cdcooper => rw_cop.cdcooper
                           ,pr_nrdconta => rw_bpr.nrdconta
                           ,pr_inpessoa => rw_bpr.inpessoa);
            FETCH cr_crapenc
             INTO rw_enc;
            CLOSE cr_crapenc;

            -- Buscar municipio do cliente
            IF vr_tab_munici.exists(rpad(rw_enc.cdufende,2,' ')||rpad(rw_enc.nmcidade,50,' ')) THEN
              -- Usamos o código encontrado
              vr_cdcidcli := vr_tab_munici(rpad(rw_enc.cdufende,2,' ')||rpad(rw_enc.nmcidade,50,' '));
            ELSE
              -- Usamos Codigo de BLUMENAU-SC
              vr_cdcidcli := 8047;
            END IF;

            -- Telefone do cliente
            vr_nrdddass := NULL;
            vr_nrtelass := NULL;
            FOR rw_tfc IN cr_craptfc(pr_cdcooper => rw_cop.cdcooper
                                    ,pr_nrdconta => rw_bpr.nrdconta) LOOP
              -- Formatar a informação
              vr_nrdddass := to_char(nvl(rw_tfc.nrdddtfc,0),'fm000');
              vr_nrtelass := to_char(nvl(rw_tfc.nrtelefo,0),'fm900000000');
              -- Sair quando encontrar
              EXIT WHEN (vr_nrdddass <> ' ' AND vr_nrtelass <> ' ');
            END LOOP;
            
            IF TRIM(vr_nrdddass) IS NULL THEN
              vr_nrdddass := to_char(0,'fm000');
            END IF;
            
            IF TRIM(vr_nrtelass) IS NULL THEN
              vr_nrtelass := to_char(0,'fm900000000');
            END IF;
          END IF;
          
          -- Adicionar ao XML as informações da operação atual conforme o tipo da operação
          IF vr_cdoperac IN(2,3) THEN
            -- Somente na Baixa com o Renavam novo, caso preenchido, utilizaremos ele
            IF vr_cdoperac = 3 AND rw_bpr.nrrenovo <> 0 THEN
              rw_bpr.nrrenava := rw_bpr.nrrenovo;
            END IF;
            -- Baixa ou cancelamento
            pc_gera_xml_desalienacao(pr_cdcooper => rw_cop.cdcooper -- Cod. Cooperativa
                                    ,pr_nrdconta => rw_bpr.nrdconta -- Nr. da conta
                                    ,pr_tpctrato => rw_bpr.tpctrpro -- Tp. contrato
                                    ,pr_nrctrpro => rw_bpr.nrctrpro -- Nr. contrato
                                    ,pr_idseqbem => rw_bpr.idseqbem -- Sequencial do bem
                                    ,pr_tpdesali => substr(vr_tparquiv,1,1) -- Tipo [C]ancelamento ou [B]aixa
                                    ,pr_flaborta => 'N'             -- Flag S/N se a operação aborta outras na sequencia em caso de erro
                                    ,pr_flgobrig => 'N'             -- Flag S/N se a operação é obrigatória para prosseguir para próximo fluxo
                                     /* SistemaNacionalGravames */
                                    ,pr_uflicenc => rw_bpr.uflicenc     -- UF                                 
                                    /* ObjetoContratoCredito */
                                    ,pr_dschassi => rw_bpr.dschassi     -- Chassi
                                    ,pr_tpchassi => rw_bpr.tpchassi     -- Tipo Chassi
                                    ,pr_nrrenava => rw_bpr.nrrenava     -- Renavam
                                    /* Emitente */
                                    ,pr_nrcpfemi => vr_nrcpfbem         -- CPF/CNPJ Emitente                                 
                                    /* Saida */
                                    ,pr_xmldesal => vr_xmltemp          -- XML do Cancelamento de alienação
                                    ,pr_dscritic => pr_dscritic);       -- Descrição de critica encontrada
          ELSIF vr_cdoperac = 4 THEN
            -- Consulta situação
            pc_gera_xml_cons_alienac(pr_cdcooper => rw_cop.cdcooper -- Cod. Cooperativa
                                    ,pr_nrdconta => rw_bpr.nrdconta -- Nr. da conta
                                    ,pr_tpctrato => rw_bpr.tpctrpro -- Tp. contrato
                                    ,pr_nrctrpro => rw_bpr.nrctrpro -- Nr. contrato
                                    ,pr_idseqbem => rw_bpr.idseqbem -- Sequencial do bem
                                     -- SistemaNacionalGravames 
                                    ,pr_uflicenc => rw_bpr.uflicenc     -- UF                               
                                    -- ObjetoContratoCredito 
                                    ,pr_dschassi => rw_bpr.dschassi -- Chassi
                                    ,pr_tpchassi => rw_bpr.tpchassi -- Tipo Chassi
                                    -- Saida 
                                    ,pr_xmlconsu => vr_xmltemp    -- XML da Consulta de alienação
                                    ,pr_dscritic => pr_dscritic); -- Descrição de critica encontrada
          ELSE
            -- Verificar se é uma inclusão CDC que ficou no lote
            IF rw_bpr.tpfinali = 3 AND rw_bpr.cdfinemp = 59 THEN
              -- Buscar CNPJ lojista
              OPEN cr_craploj(rw_cop.cdcooper
                             ,rw_bpr.nrdconta
                             ,rw_bpr.nrctrpro);
              FETCH cr_craploj
               INTO vr_nrcpfven;
              CLOSE cr_craploj;
            ELSE
              -- Não há
              vr_nrcpfven := 0;
            END IF;        
          
            -- Inclusão
            pc_gera_xml_alienacao(pr_cdcooper => rw_cop.cdcooper -- Cod. Cooperativa
                                 ,pr_nrdconta => rw_bpr.nrdconta -- Nr. da conta
                                 ,pr_tpctrato => rw_bpr.tpctrpro -- Tp. contrato
                                 ,pr_nrctrpro => rw_bpr.nrctrpro -- Nr. contrato
                                 ,pr_idseqbem => rw_bpr.idseqbem -- Sequencial do bem
                                 ,pr_flaborta => 'N'             -- Flag S/N se a operação aborta outras na sequencia em caso de erro
                                 ,pr_flgobrig => 'N'             -- Flag S/N se a operação é obrigatória para prosseguir para próximo fluxo
                                 /* SistemaNacionalGravames */
                                 ,pr_uflicenc => rw_bpr.uflicenc -- UF de Licenciamento
                                 ,pr_tpaliena => '03'            -- Tipo da Alienação
                                 ,pr_dtlibera => rw_bpr.dtlibera -- Data da Liberação
                                 /* ObjetoContratoCredito */
                                 ,pr_dschassi => rw_bpr.dschassi -- Chassi
                                 ,pr_tpchassi => rw_bpr.tpchassi -- Tipo Chassi
                                 ,pr_ufdplaca => rw_bpr.ufdplaca -- UF
                                 ,pr_nrdplaca => rw_bpr.nrdplaca -- PLaca
                                 ,pr_nrrenava => rw_bpr.nrrenava -- Renavam
                                 ,pr_nranobem => rw_bpr.nranobem -- Ano Fabricacao
                                 ,pr_nrmodbem => rw_bpr.nrmodbem -- Ano modelo                               
                                 /* propostaContratoCredito */
                                 ,pr_nrctremp => rw_bpr.nrctremp -- Contrato
                                 ,pr_dtmvtolt => rw_bpr.dtmvtolt -- Data digitação
                                 ,pr_qtpreemp => rw_bpr.qtpreemp -- Quantidade parcelas
                                 ,pr_permulta => vr_prmulta      -- Percentual de Multa
                                 ,pr_txmensal => rw_bpr.txmensal -- Taxa mensal
                                 ,pr_tpemprst => rw_bpr.tpemprst -- Tipo Emprestimo
                                 ,pr_vlemprst => rw_bpr.vlemprst -- Valor Empréstimo
                                 ,pr_dtdpagto => rw_bpr.dtdpagto -- Data da primeira parcela
                                 ,pr_dtpagfim => vr_dtvencto     -- Data da ultima parcela
                                 /* Emitente */
                                 ,pr_nrcpfemi => vr_nrcpfbem     -- CPF/CNPJ Emitente
                                 ,pr_nmemiten => vr_nmprimtl     -- Nome/Razão Social Emitente
                                 ,pr_dsendere => GENE0007.fn_caract_acento(rw_enc.dsendere,1) -- Logradouro Emitente
                                 ,pr_nrendere => rw_enc.nrendere -- Numero Emitente
                                 ,pr_nmbairro => GENE0007.fn_caract_acento(rw_enc.nmbairro,1) -- Nome Bairro Emitente
                                 ,pr_cdufende => rw_enc.cdufende -- UF Emitente
                                 ,pr_cdcidade => vr_cdcidcli     -- Cidade
                                 ,pr_nrcepend => rw_enc.nrcepend -- CEP Emitente
                                 ,pr_nrdddtfc => vr_nrdddass     -- DDD Emitente
                                 ,pr_nrtelefo => vr_nrtelass     -- Telefone Emitente
                                  /* Credor Eh a Coop */
                                 ,pr_nmcddopa => GENE0007.fn_caract_acento(vr_tab_endere_ageope(lpad(rw_cop.cdcooper,5,'0')||rpad(rw_bpr.cdoperad,10,' ')).nmcidade,1) -- Nome da cidade do PA
                                 ,pr_cdufdopa => vr_tab_endere_ageope(lpad(rw_cop.cdcooper,5,'0')||rpad(rw_bpr.cdoperad,10,' ')).cdufdcop -- UF do PA
                                 ,pr_inpescre => 2                -- Tipo pessoa Credor
                                 ,pr_nrcpfcre => rw_cop.nrdocnpj  -- CPF/CNPJ Credor
                                 ,pr_dsendcre => GENE0007.fn_caract_acento(rw_cop.dsendcop,1) -- Logradouro Credor
                                 ,pr_nrendcre => rw_cop.nrendcop  -- Numero Credor
                                 ,pr_nmbaicre => GENE0007.fn_caract_acento(rw_cop.nmbairro,1) -- Nome Bairro Credor
                                 ,pr_cdufecre => rw_cop.cdufdcop  -- UF Credor
                                 ,pr_cdcidcre => vr_cdcidcre      -- Cidade Credor
                                 ,pr_nrcepcre => rw_cop.nrcepend  -- CEP Credor
                                 ,pr_nrdddcre => vr_nrdddenc      -- DDD Credor
                                 ,pr_nrtelcre => vr_nrtelenc      -- Telefone Credor
                                 /* Dados do Vendedor */
                                 ,pr_nrcpfven => vr_nrcpfven      -- CPF/CNPJ Vendedor
                                 /* Recebedor do pagamento */
                                 ,pr_inpesrec => 2                -- Tipo Pessoa Vendedor
                                 ,pr_nrcpfrec => rw_cop.nrdocnpj  -- CPF/CNPJ Vendedor
                                 /* Saida */
                                 ,pr_xmlalien => vr_xmltemp    -- XML da alienação
                                 ,pr_dscritic => pr_dscritic); -- Descrição de critica encontrada

          END IF;        
          -- Testar saida com erro
          IF pr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;        
          
          -- Adicionar ao CLOB
          gene0002.pc_escreve_xml(vr_clobxml
                                 ,vr_clobaux
                                 ,vr_xmltemp);     

        END IF;
        
      END LOOP;
      
      -- Ao final, finalizar o XML
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_clobaux
                             ,'</gravameB3></Root>'
                             ,TRUE);      
      -- E converter o CLOB para o XMLType de retorno
      pr_retxml := xmltype.createXML(vr_clobxml);
      --Fechar Clob e Liberar Memoria  
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);  
      
      -- Fim da rotina, efetuamos gravação das informações alteradas
      COMMIT;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Desfazer alterações
        ROLLBACK;
        -- Se foi retornado apenas código
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descrição
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
        
        -- Incrementar a mensagem de erro
        pr_dscritic := pr_dscritic;
        
        --Inclusão dos parâmetros apenas na exception, para não mostrar na tela - Chamado 660356
        --Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- Mensagem
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                      'ALERTA: '|| pr_dscritic ||
                                                      ',Cdcooper:'||pr_cdcooper||',Tparquiv:'||pr_tparquiv||
                                                      ','||vr_dsparam);
        
      WHEN OTHERS THEN
        -- Desfazer alterações
        ROLLBACK;
        -- Retornar erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro GRVM0001.pc_gravames_geracao_arquivo -> '||SQLERRM;

        --Padronização - Chamado 660394
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                      'ERRO: ' || pr_dscritic  ||
                                                      ',Cdcooper:'||pr_cdcooper||',Tparquiv:'||pr_tparquiv||
                                                      ','||vr_dsparam);

        --Inclusão na tabela de erros Oracle
        CECRED.pc_internal_exception( pr_compleme => pr_dscritic );

    END;
  END pc_gravames_geracao_xml;
  
/* Atualizar bens da proposta para tipo de baixa = 'A'. */
  PROCEDURE pc_solicita_baixa_automatica(pr_cdcooper IN crapbpr.cdcooper%type -- Código da Cooperativa
                                        ,pr_nrdconta IN crapbpr.nrdconta%type -- Numero da conta do associado
                                        ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Numero do contrato
                                        ,pr_dtmvtolt IN DATE                  -- Data de movimento para baixa
                                        ,pr_des_reto OUT VARCHAR2             -- Retorno OK ou NOK do procedimento
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro-- Retorno de erros em PlTable
                                        ,pr_cdcritic OUT PLS_INTEGER          -- Código de erro gerado em excecao
                                        ,pr_dscritic OUT VARCHAR2) IS         -- Descricao de erro gerado em excecao

    -- ..........................................................................
    --
    --  Programa : pc_solicita_baixa_automatica            Antigo: b1wgen0171.p/solicita_baixa_automatica

    --  Sistema  : Rotinas genericas para GRAVAMES
    --  Sigla    : GRVM
    --  Autor    : Douglas Pagel
    --  Data    : Dezembro/2013                     Ultima Atualizacao: 29/05/2017
    --
    --  Dados referentes ao programa:
    --
    --  Objetivo  : Package referente GRAVAMES
    --
    --  Alteracoes: 04/12/2013 - Conversao Progress para oracle (Douglas).
    --
    --              17/07/2014 - Liberacao da solicita_baixa_automatica apenas para
    --                           CONCREDI (Guilherme/SUPERO)
    --
    --              29/08/2014 - Liberacao da solicita_baixa_automatica para CREDELESC
    --                           (Guilherme/SUPERO)
    --
    --              13/10/2014 - Liberacao da solicita_baixa_automatica para VIACREDI
    --                           (Guilherme/SUPERO)
    --
    --              30/12/2014 - Liberação para as demais cooperativas(Guilherme/SUPERO)
    --
    --              02/04/2015 - (Chamado 271753) - Não enviar baixas de bens ao Gravames quando 
    --                           o contrato está em prejuízo (Tiago Castro - RKAM).
    -- 
    --              29/05/2017 - Padronização das mensagens para a tabela tbgen_prglog,
    --                         - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
    --                         - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
    --                         - Incluir nome do módulo logado em variável
    --                           (Ana - Envolti) - SD: 660356 e 660394
    -- .............................................................................

    -- VARIÁVEIS
    -- Variaveis locais para retorno de erro
    vr_des_reto varchar2(4000);
    vr_dscritic VARCHAR2(4000);
    vr_vet_dados typ_reg_dados;

    -- Código do programa
	  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';

  BEGIN

	  --Incluir nome do módulo logado - Chamado 660394
   GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_solicita_baixa_automatica');

    -- Valida se eh alienacao fiduciaria
    pc_valida_alienacao_fiduciaria( pr_cdcooper => pr_cdcooper   -- Código da cooperativa
                                   ,pr_nrdconta => pr_nrdconta   -- Numero da conta do associado
                                   ,pr_nrctrpro => pr_nrctrpro   -- Numero do contrato
                                   ,pr_des_reto => vr_des_reto   -- Retorno Ok ou NOK do procedimento
                                   ,pr_vet_dados => vr_vet_dados -- Vetor com dados para auxiliar alienação
                                   ,pr_dscritic => vr_dscritic); -- Retorno da descricao da critica do erro
    /** OBS: Sempre retornara OK pois a chamada da solicita_baixa_automatica
             nos CRPS171,CRPS078,CRPS120_1,B1WGEN0136, nesses casos nao pode
             impedir de seguir para demais contratos. **/

    IF vr_des_reto <> 'OK' THEN
      pr_des_reto := 'OK'; -- PASSA ok para o parametro de retorno
      RETURN; -- Retorna para o programa chamador.
    END IF;

    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_solicita_baixa_automatica');

    -- Para cada bem da proposta
    OPEN cr_crapbpr(pr_cdcooper,
                    pr_nrdconta,
                    pr_nrctrpro);
    LOOP
      FETCH cr_crapbpr
        INTO rw_crapbpr;
      EXIT WHEN cr_crapbpr%NOTFOUND;

      -- Se a situação do bem já eh baixado ou jah foi feito baixa manual 
      IF rw_crapbpr.cdsitgrv = 4 OR rw_crapbpr.tpdbaixa = 'M' THEN
        -- Passa para proximo bem
        CONTINUE;
      END IF;

      -- Atualiza registro para baixa automatica
      BEGIN
        UPDATE crapbpr
           SET crapbpr.flgbaixa = 1,
               crapbpr.dtdbaixa = pr_dtmvtolt,
               crapbpr.tpdbaixa = 'A'
         WHERE crapbpr.rowid = rw_crapbpr.rowid;

      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao atualizar registro na crapbpr: ' || sqlerrm;
          CLOSE cr_crapbpr;
          return;
      END;
    END LOOP;
    CLOSE cr_crapbpr;
    pr_des_reto := 'OK';

    RETURN;

  EXCEPTION
      WHEN others THEN

        -- Gerar erro
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na pc_solicita_baixa_automatica --> '|| SQLERRM;

        --Inclusão gravação erro nas tabelas 
        --Padronização - Chamado 660394
        --Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                      'ERRO: ' || pr_dscritic  ||
                                                      ',Cdcooper:'||pr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                      ',Nrctrpro:'||pr_nrctrpro||',Dtmvtolt:'||pr_dtmvtolt);

        --Inclusão na tabela de erros Oracle
        CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper
                                     ,pr_compleme => pr_dscritic );
                       
        RETURN;
  END; -- pc_solicita_baixa_automatica;  
  
  PROCEDURE pc_desfazer_baixa_automatica(pr_cdcooper IN crapbpr.cdcooper%TYPE       -- Cód. cooperativa
                                        ,pr_nrdconta IN crapbpr.nrdconta%TYPE       -- Nr. da conta
                                        ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE       -- Nr. contrato
                                        ,pr_des_reto OUT VARCHAR2                   -- Descrição de retorno OK/NOK
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro)IS   -- Retorno de erros em PlTable
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_desfazer_solicitacao_baixa_automatica      Antigo: b1wgen0171.p/desfazer_solicitacao_baixa_automatica

    --  Sistema  : Rotinas genericas para GRAVAMES
    --  Sigla    : GRVM
    --  Autor    : Lucas Reinert
    --  Data     : Agosto/2015.                   Ultima atualizacao: 29/05/2017
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Desfazer a solicitação de baixa automatica  do gravames
    --
    --   Alteracoes: 29/05/2017 - Padronização das mensagens para a tabela tbgen_prglog,
    --                          - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
    --                          - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
    --                          - Incluir nome do módulo logado em variável
    --                            (Ana - Envolti) - SD: 660356 e 660394
    -- .............................................................................
    DECLARE
       
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_nrsequen INTEGER;
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;   
    
      -- CURSORES
      -- Cursor para a tabela de emprestrimos      
      CURSOR cr_crapepr IS
        SELECT 1
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctrpro;
      rw_crapepr cr_crapepr%ROWTYPE;
      
      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';
      
      -- Vetor com dados auxiliares para alienação B3
      vr_vet_dados typ_reg_dados;
    

    BEGIN
	    --Incluir nome do módulo logado - Chamado 660394
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_desfazer_baixa_automatica');

      -- Verifica se existe contrato de emprestimo
      OPEN cr_crapepr;
      FETCH cr_crapepr INTO rw_crapepr;
      
      -- Se não existir gera crítica
      IF cr_crapepr%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_crapepr;
        -- Gera crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Contrato de emprestimo nao encontrado.';        
        vr_nrsequen := 1;        
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
      
      -- Validar alienação
      pc_valida_alienacao_fiduciaria (pr_cdcooper => pr_cdcooper  -- Código da cooperativa
                                     ,pr_nrdconta => pr_nrdconta  -- Numero da conta do associado
                                     ,pr_nrctrpro => pr_nrctrpro  -- Numero do contrato
                                     ,pr_des_reto => pr_des_reto  -- Retorno Ok ou NOK do procedimento
                                     ,pr_vet_dados => vr_vet_dados -- Vetor com dados para auxiliar alienação
                                     ,pr_dscritic => vr_dscritic); -- Retorno da descricao da critica do erro
          
      -- Se a procedure não retornou corretamente
      IF pr_des_reto <> 'OK' THEN
        -- Levanta crítica
        RAISE vr_exc_saida;
      END IF;
            
      --Incluir nome do módulo logado - Chamado 660394
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_desfazer_baixa_automatica');
            
      -- Atualiza a tabela de bens para desfazer a baixa
      UPDATE crapbpr bpr
         SET bpr.flgbaixa = 0,
             bpr.dtdbaixa = NULL,
             bpr.tpdbaixa = ''
       WHERE bpr.cdcooper = pr_cdcooper
         AND bpr.nrdconta = pr_nrdconta
         AND bpr.nrctrpro = pr_nrctrpro
         AND bpr.tpctrpro IN (90,99)
         AND bpr.flgbaixa = 1
         AND bpr.tpdbaixa = 'A'
         AND bpr.flblqjud <> 1;      
    
      -- Retorno OK
      pr_des_reto := 'OK';
      
      -- Commita alterações
      COMMIT;
    
    EXCEPTION        
      -- Críticas tratadas
      WHEN vr_exc_saida THEN
        pr_des_reto := 'NOK';
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => vr_nrsequen
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        --Inclusão dos parâmetros apenas na exception, para não mostrar na tela
        --Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- Mensagem
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                      'ALERTA: '|| vr_dscritic ||
                                                      ',Cdcooper:'||pr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                      ',Nrctrpro:'||pr_nrctrpro);

        ROLLBACK;
      -- Críticas nao tratadas
      WHEN OTHERS THEN                                      
        vr_cdcritic := 0;
        vr_dscritic := 'Erro na rotina GRVM0001.pc_desfazer_solicitacao_baixa_automatica -> '||SQLERRM;        
        vr_nrsequen := 1;        
        pr_des_reto := 'NOK';
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => vr_nrsequen
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
                             

        --Inclusão dos parâmetros apenas na exception, para não mostrar na tela
        --Padronização - Chamado 660394
        --Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                      'ERRO: '|| vr_dscritic ||
                                                      ',Cdcooper:'||pr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                      ',Nrctrpro:'||pr_nrctrpro);

        --Inclusão na tabela de erros Oracle
        CECRED.pc_internal_exception( pr_compleme => vr_dscritic );

        ROLLBACK;

    END;
  END pc_desfazer_baixa_automatica;  

  PROCEDURE pc_alterar_gravame(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                              ,pr_cddopcao IN VARCHAR2              --Opção
                              ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                              ,pr_idseqbem IN crapbpr.idseqbem%TYPE --Identificador do bem
                              ,pr_dscatbem IN crapbpr.dscatbem%TYPE --Categoria do bem
                              ,pr_dschassi IN crapbpr.dschassi%TYPE --Chassi do bem
                              ,pr_ufdplaca IN crapbpr.ufdplaca%TYPE --UF da placa
                              ,pr_nrdplaca IN crapbpr.nrdplaca%TYPE --Número da placa
                              ,pr_nrrenava IN crapbpr.nrrenava%TYPE --RENAVAN
                              ,pr_nranobem IN crapbpr.nranobem%TYPE --Ano do bem
                              ,pr_nrmodbem IN crapbpr.nrmodbem%TYPE --Modelo do bem
                              ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE --Tipo do contrato
                              ,pr_cdsitgrv IN crapbpr.cdsitgrv%TYPE --Situação do Gravame
                              ,pr_dsaltsit IN VARCHAR2              --Descrição do motivo da alteração da situação do Gravame
                              ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                              ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_alterar_gravame                            antiga: b1wgen0171.gravames_alterar
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 19/10/2018
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realizar a alteração do gravame
    
    Alterações : 14/07/2016 - Ajuste para utilziar rotina de validação dos caracteres do chassi
							 (Andrei - RKAM).

                 19/08/2016 - Inclusão de novos campos "pr_cdsitgrv" e "pr_dsaltsit " para 
                              alteração do GRAVAMES. Projeto 369(Lombardi).

     			       22/09/2016 - Ajuste para utilizar upper ao manipular a informação do chassi
                              pois em alguns casos ele foi gravado em minusculo e outros em maisculo
                             (Adriano - SD 527336)

                 29/05/2017 - Ajuste das mensagens: neste caso são todas consideradas tpocorrencia = 4,
                            - Substituição do termo "ERRO" por "ALERTA",
                            - Padronização das mensagens para a tabela tbgen_prglog,
                            - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
                            - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
                            - Incluir nome do módulo logado em variável
                              (Ana - Envolti) - SD: 660356 e 660394

                 08/08/2018 - Ajuste no campo nrdplaca para formatar os caracteres para
                              caracteres maiusculos na opcao de alteracao de gravame. 
                              Chamado PRB0040116 (Gabriel - Mouts).
                              
                 19/10/2018 - P442 - Troca de checagem fixa por funcão para garantir se bem é alienável (Marcos-Envolti)

    -------------------------------------------------------------------------------------------------------------*/                               
  
    -- Cursor para encontrar o bem
    CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE
                     ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE
                     ,pr_idseqbem IN crapbpr.idseqbem%TYPE) IS
    SELECT crapbpr.nrgravam
          ,crapbpr.idseqbem
          ,crapbpr.dsbemfin
          ,crapbpr.vlmerbem
          ,crapbpr.tpchassi
          ,crapbpr.nrdplaca
          ,crapbpr.nranobem
          ,crapbpr.nrcpfbem
          ,UPPER(crapbpr.uflicenc) uflicenc
          ,crapbpr.dscatbem
          ,crapbpr.dscorbem
          ,crapbpr.dschassi
          ,crapbpr.ufdplaca
          ,crapbpr.nrrenava
          ,crapbpr.nrmodbem
          ,crapbpr.ufplnovo
          ,crapbpr.nrplnovo
          ,crapbpr.nrrenovo
          ,crapbpr.dtatugrv
          ,crapbpr.flblqjud
          ,crapbpr.cdsitgrv  
          ,crapbpr.tpinclus
          ,ROWID rowid_bpr                 
      FROM crapbpr
     WHERE crapbpr.cdcooper = pr_cdcooper
       AND crapbpr.nrdconta = pr_nrdconta
       AND crapbpr.tpctrpro = pr_tpctrpro
       AND crapbpr.nrctrpro = pr_nrctrpro
       AND crapbpr.idseqbem = pr_idseqbem
       AND crapbpr.flgalien = 1;
    rw_crapbpr cr_crapbpr%ROWTYPE;
      
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto varchar2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_nrdrowid ROWID;
    
    --Variaveis Locais   
    vr_dstransa VARCHAR2(100);
    
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';
  
    -- Vetor com dados auxiliares para alienação B3
    vr_vet_dados typ_reg_dados;
    
  
  BEGIN
    vr_dstransa := 'Alterar o valor do gravames';
    
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_alterar_gravame');
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
       
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    -- Validar campos 
    IF pr_cdsitgrv IS NOT NULL AND pr_dsaltsit IS NULL THEN
      vr_cdcritic:= 0;
      vr_dscritic := 'Situacao foi alterada. Sera necessario informar MOTIVO';
      pr_nmdcampo := 'dsaltsit';
      
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    -- Validar campos
    IF pr_cdsitgrv = 1 THEN
      vr_cdcritic:= 0;
      vr_dscritic := 'Situação não pode ser alterada para \"Em processamento\".';
      pr_nmdcampo := 'cdsitgrv';
      
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    pc_valida_alienacao_fiduciaria (pr_cdcooper => vr_cdcooper  -- Código da cooperativa
                                   ,pr_nrdconta => pr_nrdconta  -- Numero da conta do associado
                                   ,pr_nrctrpro => pr_nrctrpro  -- Numero do contrato
                                   ,pr_des_reto => vr_des_reto  -- Retorno Ok ou NOK do procedimento
                                   ,pr_vet_dados => vr_vet_dados -- Vetor com dados para auxiliar alienação
                                   ,pr_dscritic => vr_dscritic  -- Retorno da descricao da critica do erro
                                   );
    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
      --Levantar Excecao  
      RAISE vr_exc_erro;
    END IF; 
      
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_alterar_gravame');
      
    IF trim(pr_dschassi) IS NULL THEN
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Numero do chassi nao informado.';
      pr_nmdcampo := 'dschassi';
      
      --Levantar Excecao  
      RAISE vr_exc_erro;
      
    END IF;
    
    IF fn_valida_caracteres (pr_flgnumer => TRUE 
                            ,pr_flgletra => TRUE
                            ,pr_listaesp => ''
                            ,pr_listainv => 'QIO'
                            ,pr_dsvalida => pr_dschassi) THEN
     
      vr_cdcritic:= 0;
      vr_dscritic:= 'Numero do chassi nao invalido.';
      pr_nmdcampo := 'dschassi';
      
      --Levantar Excecao  
      RAISE vr_exc_erro;
                              
    END IF;
    
    --Retorna o módulo que está executando
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_alterar_gravame');

    IF trim(pr_nrdplaca) IS NULL THEN
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Numero da placa nao informado.';
      pr_nmdcampo := 'nrdplaca';
      
      --Levantar Excecao  
      RAISE vr_exc_erro;
    
    END IF;
    
    IF trim(pr_ufdplaca) IS NULL THEN
     
      vr_cdcritic:= 0;
      vr_dscritic:= 'UF da placa nao informado';
      pr_nmdcampo := 'ufdplaca';
      
      --Levantar Excecao  
      RAISE vr_exc_erro; 
    
    END IF;
    
    IF trim(pr_nrrenava) IS NULL THEN
     
      vr_cdcritic:= 0;
      vr_dscritic:= 'RENAVAN nao informado';
      pr_nmdcampo := 'nrrenava';
      
      --Levantar Excecao  
      RAISE vr_exc_erro; 
    
    END IF;
    
    IF trim(pr_dscatbem) IN('MOTO','AUTOMOVEL') AND 
       length(trim(pr_dschassi)) < 17           THEN
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Numero do chassi incompleto, verifique.';
      pr_nmdcampo := 'dschassi';
      
      --Levantar Excecao  
      RAISE vr_exc_erro;
    
    ELSIF grvm0001.fn_valida_categoria_alienavel(pr_dscatbem) = 'S' AND 
          length(trim(pr_dschassi)) > 17                      THEN
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Numero do chassi maior que o tamanho maximo.';
      pr_nmdcampo := 'dschassi';
      
      --Levantar Excecao  
      RAISE vr_exc_erro;
            
    END IF;
    
    OPEN cr_crapbpr(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_tpctrpro => pr_tpctrpro
                   ,pr_nrctrpro => pr_nrctrpro
                   ,pr_idseqbem => pr_idseqbem);
    
    FETCH cr_crapbpr INTO rw_crapbpr;
    
    IF cr_crapbpr%NOTFOUND THEN
    
      CLOSE cr_crapbpr;
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro do bem nao encontrado.';
      
      --Levantar Excecao  
      RAISE vr_exc_erro;   
    
    ELSE
      
      CLOSE cr_crapbpr;
    
      IF rw_crapbpr.cdsitgrv = 1 AND 
         rw_crapbpr.cdsitgrv <> pr_cdsitgrv THEN
        vr_cdcritic:= 0;
        vr_dscritic := 'Situação não pode ser alterada.';
        pr_nmdcampo := 'cdsitgrv';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;  
      
    
      /* Apenas poder alterar chassi quando 
         status for 0 ("nao enviado") ou 3 (Processado com critica)  
         Ou se o tipo da inclusao for igual a M (Manual) com situação 
         diferente de 1 (Em processamento) e 3 (Processado com critica).*/
      IF TRIM(UPPER(rw_crapbpr.dschassi)) <> TRIM(UPPER(pr_dschassi)) AND
       ((rw_crapbpr.tpinclus <> 'M'                     AND
         rw_crapbpr.cdsitgrv <> 0                       AND
         rw_crapbpr.cdsitgrv <> 3)                      OR
        (rw_crapbpr.tpinclus = 'M'                      AND
        (rw_crapbpr.cdsitgrv = 1                        OR
         rw_crapbpr.cdsitgrv = 3)))                     THEN
         
        vr_cdcritic:= 0;
        vr_dscritic:= 'Alteracao de chassi nao permitida.';
            
        --Levantar Excecao  
        RAISE vr_exc_erro;        
                   
      END IF;  
      
      BEGIN
        
        UPDATE crapbpr
           SET crapbpr.flgalter = 1
              ,crapbpr.dtaltera = rw_crapdat.dtmvtolt
              ,crapbpr.tpaltera = 'M'
              ,crapbpr.dschassi = UPPER(pr_dschassi)
              ,crapbpr.ufplnovo = UPPER(pr_ufdplaca)
              ,crapbpr.nrplnovo = UPPER(pr_nrdplaca)
              ,crapbpr.nrrenovo = pr_nrrenava
              ,crapbpr.nranobem = pr_nranobem
              ,crapbpr.nrmodbem = pr_nrmodbem              
              ,crapbpr.cdsitgrv = nvl(pr_cdsitgrv, cdsitgrv)
        WHERE ROWID = rw_crapbpr.rowid_bpr;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Nao foi possivel alterar o bem.';
          
          --Levantar Excecao  
          RAISE vr_exc_erro; 
      END;
    
      vr_dstransa := vr_dstransa || ' ' || rw_crapbpr.dsbemfin || rw_crapbpr.dscorbem;
      
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad 
                          ,pr_dscritic => ''         
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => rw_crapdat.dtmvtolt
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    
      IF TRIM(UPPER(pr_dschassi)) <> TRIM(UPPER(rw_crapbpr.dschassi)) THEN
      
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'Chassi', 
                                  pr_dsdadant => TO_CHAR(rw_crapbpr.dschassi), 
                                  pr_dsdadatu => TO_CHAR(pr_dschassi));
      
      END IF;
      
      IF (TRIM(rw_crapbpr.ufdplaca) <> TRIM(pr_ufdplaca) AND
          TRIM(rw_crapbpr.ufplnovo) IS NULL)             OR
         (TRIM(rw_crapbpr.ufplnovo) <> TRIM(pr_ufdplaca) AND
          TRIM(rw_crapbpr.ufplnovo) IS NOT NULL)         THEN
      
        IF trim(rw_crapbpr.ufplnovo) IS NULL THEN
          
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                    pr_nmdcampo => 'UF Placa', 
                                    pr_dsdadant => TO_CHAR(rw_crapbpr.ufdplaca), 
                                    pr_dsdadatu => TO_CHAR(pr_ufdplaca));
                                  
        ELSE
          
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                    pr_nmdcampo => 'UF Placa', 
                                    pr_dsdadant => TO_CHAR(rw_crapbpr.ufplnovo), 
                                    pr_dsdadatu => TO_CHAR(pr_ufdplaca));
                                  
        END IF;
        
      
      END IF;
      
      IF (TRIM(rw_crapbpr.nrdplaca) <> TRIM(pr_nrdplaca) AND
          TRIM(rw_crapbpr.nrplnovo) IS NULL)             OR
         (TRIM(rw_crapbpr.nrplnovo) <> TRIM(pr_nrdplaca) AND
          TRIM(rw_crapbpr.nrplnovo) IS NOT NULL)         THEN
      
        IF trim(rw_crapbpr.nrplnovo) IS NULL THEN
          
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                    pr_nmdcampo => 'Placa', 
                                    pr_dsdadant => TO_CHAR(rw_crapbpr.nrdplaca), 
                                    pr_dsdadatu => TO_CHAR(pr_nrdplaca));
                                  
        ELSE
          
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                    pr_nmdcampo => 'Plaa', 
                                    pr_dsdadant => TO_CHAR(rw_crapbpr.nrplnovo), 
                                    pr_dsdadatu => TO_CHAR(pr_nrdplaca));
                                  
        END IF;
        
      
      END IF;
      
      IF (rw_crapbpr.nrrenava <> pr_nrrenava AND
          rw_crapbpr.nrrenovo = 0)           OR
         (rw_crapbpr.nrrenovo <> pr_nrrenava AND
          rw_crapbpr.nrrenovo <>0)           THEN
      
        IF rw_crapbpr.nrrenovo = 0 THEN
          
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                    pr_nmdcampo => 'Renavam', 
                                    pr_dsdadant => TO_CHAR(rw_crapbpr.nrrenava), 
                                    pr_dsdadatu => TO_CHAR(pr_nrrenava));
                                  
        ELSE
          
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                    pr_nmdcampo => 'Renavam', 
                                    pr_dsdadant => TO_CHAR(rw_crapbpr.nrrenovo), 
                                    pr_dsdadatu => TO_CHAR(pr_nrrenava));
                                  
        END IF;
        
      
      END IF;
      
      IF rw_crapbpr.nranobem <> pr_nranobem THEN
      
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'Ano Fab.', 
                                  pr_dsdadant => TO_CHAR(rw_crapbpr.nranobem), 
                                  pr_dsdadatu => TO_CHAR(pr_nranobem));  
      
      END IF;
      
      
      IF rw_crapbpr.nrmodbem <> pr_nrmodbem THEN
        
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'Ano Mod.', 
                                  pr_dsdadant => TO_CHAR(rw_crapbpr.nrmodbem), 
                                  pr_dsdadatu => TO_CHAR(pr_nrmodbem));
      
      END IF;
      
      IF pr_cdsitgrv IS NOT NULL THEN
      
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'Situacao', 
                                  pr_dsdadant => CASE rw_crapbpr.cdsitgrv
                                                   WHEN 0 THEN '0 – Nao enviado'
                                                   WHEN 1 THEN '1 – Em processamento'
                                                   WHEN 2 THEN '2 – Alienacao'
                                                   WHEN 3 THEN '3 – Processado c/ Critica'
                                                   WHEN 4 THEN '4 – Baixado'
                                                   WHEN 5 THEN '5 – Cancelado'
                                                 END, 
                                  pr_dsdadatu => CASE pr_cdsitgrv
                                                   WHEN 0 THEN '0 – Nao enviado'
                                                   WHEN 1 THEN '1 – Em processamento'
                                                   WHEN 2 THEN '2 – Alienacao'
                                                   WHEN 3 THEN '3 – Processado c/ Critica'
                                                   WHEN 4 THEN '4 – Baixado'
                                                   WHEN 5 THEN '5 – Cancelado'
                                                 END);
      
    END IF;
    
      IF pr_dsaltsit IS NOT NULL THEN
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'MOTIVO ALT SITUACAO', 
                                  pr_dsdadant => '', 
                                  pr_dsdadatu => pr_dsaltsit);
      END IF;
    
    END IF;
               
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
                                     
      --Padronização - Chamado 660394
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Mensagem
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ERRO: '|| pr_dscritic ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Tpctrpro:'||pr_tpctrpro||
                                                    ',Idseqbem:'||pr_idseqbem||',Cddopcao:'||pr_cddopcao);
                                           
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_alterar_gravame --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      
      --Padronização - Chamado 660394
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ERRO: ' || pr_dscritic  ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Tpctrpro:'||pr_tpctrpro||
                                                    ',Idseqbem:'||pr_idseqbem||',Cdsitgrv:'||rw_crapbpr.cdsitgrv);

      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
        
  END pc_alterar_gravame;  

  /* Solicitar Cancelamento */
  PROCEDURE pc_gravames_cancelar(pr_nrdconta in crapass.nrdconta%TYPE --Número da conta
                                ,pr_cddopcao in VARCHAR2              --Opção
                                ,pr_nrctrpro in crawepr.nrctremp%TYPE --Número do contrato 
                                ,pr_idseqbem in crapbpr.idseqbem%TYPE --Identificador do bem
                                ,pr_tpctrpro in crapbpr.tpctrpro%TYPE --Tipo do contrato
                                ,pr_tpcancel in crapbpr.tpcancel%TYPE --Tipo de cancelamento
                                ,pr_cdopeapr in VARCHAR2              --Operador da aprovação
                                ,pr_dsjuscnc in crapbpr.dsjuscnc%TYPE -- Justificativa
                                ,pr_xmllog   in VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic out PLS_INTEGER          --Código da crítica
                                ,pr_dscritic out VARCHAR2             --Descrição da crítica
                                ,pr_retxml   in out nocopy xmltype    --Arquivo de retorno do XML
                                ,pr_nmdcampo out VARCHAR2             --Nome do Campo
                                ,pr_des_erro out varchar2) IS         --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravames_cancelar                            antiga: b1wgen0171.gravames_cancelar
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 13/10/2018
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realizar o cancelamento de gravames
    
    Alteracoes: 29/05/2017 - Ajuste das mensagens: neste caso são todas consideradas tpocorrencia = 4,
                           - Substituição do termo "ERRO" por "ALERTA",
                           - Padronização das mensagens para a tabela tbgen_prglog,
                           - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
                           - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
                           - Incluir nome do módulo logado em variável
                             (Ana - Envolti) - SD: 660356 e 660394
    
                25/09/2018 - Inclusão de parâmetro para o código do operador de aprovação. Salvar um registro no 
                             log com o nome do coordenador que aprovou o cancelamento.
                             
                27/09/2018 - P442 - Inclusão de parâmetro para a justificativa para o cancelamento (Daniel - Envolti)
                
                13/10/2018 - P442 - Retorno de dados para cancelamento de alienação na B3 quando Gravames
                             Online estiver habilitado - Marcos-Envolti
                
    -------------------------------------------------------------------------------------------------------------*/                               
  
    -- Cursor para encontrar o bem
    CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE
                     ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE
                     ,pr_idseqbem IN crapbpr.idseqbem%TYPE) IS
    SELECT crapbpr.nrgravam
          ,crapbpr.idseqbem
          ,crapbpr.dsbemfin
          ,crapbpr.vlmerbem
          ,crapbpr.tpchassi
          ,crapbpr.nrdplaca
          ,crapbpr.nranobem
          ,crapbpr.nrcpfbem
          ,UPPER(crapbpr.uflicenc) uflicenc
          ,crapbpr.dscatbem
          ,crapbpr.dscorbem
          ,crapbpr.dschassi
          ,crapbpr.ufdplaca
          ,crapbpr.nrrenava
          ,crapbpr.nrmodbem
          ,crapbpr.ufplnovo
          ,crapbpr.nrplnovo
          ,crapbpr.nrrenovo
          ,crapbpr.dtatugrv
          ,crapbpr.flblqjud
          ,crapbpr.cdsitgrv  
		  ,crapbpr.dtcancel
          ,crapbpr.dsmarbem
          ,crapbpr.dstipbem
          ,ROWID rowid_bpr                 
      FROM crapbpr
     WHERE crapbpr.cdcooper = pr_cdcooper
       AND crapbpr.nrdconta = pr_nrdconta
       AND crapbpr.tpctrpro = pr_tpctrpro
       AND crapbpr.nrctrpro = pr_nrctrpro
       AND crapbpr.idseqbem = pr_idseqbem
       AND crapbpr.flgalien = 1;
    rw_crapbpr cr_crapbpr%ROWTYPE;
      
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto varchar2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais  
    vr_dstransa VARCHAR2(100);
    vr_nrdrowid ROWID;
    vr_nmopeapr crapope.nmoperad%type;
    
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';

         
    -- XML de Envio das Informações
    vr_xmltemp VARCHAR2(32767);
    
    -- Vetor com dados auxiliares para alienação B3
    vr_vet_dados typ_reg_dados;
    
    
  BEGIN
    vr_dstransa := 'Cancelamento do bem no gravames';

    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_cancelar');
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
       
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    pc_valida_alienacao_fiduciaria (pr_cdcooper => vr_cdcooper  -- Código da cooperativa
                                   ,pr_nrdconta => pr_nrdconta  -- Numero da conta do associado
                                   ,pr_nrctrpro => pr_nrctrpro  -- Numero do contrato
                                   ,pr_des_reto => vr_des_reto  -- Retorno Ok ou NOK do procedimento
                                   ,pr_vet_dados => vr_vet_dados -- Vetor com dados para auxiliar alienação
                                   ,pr_dscritic => vr_dscritic  -- Retorno da descricao da critica do erro
                                   );

    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
      --Levantar Excecao  
      RAISE vr_exc_erro;
    END IF; 
      
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_cancelar');

    -- Buscar informações do bem alienado
    OPEN cr_crapbpr(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_tpctrpro => pr_tpctrpro
                   ,pr_nrctrpro => pr_nrctrpro
                   ,pr_idseqbem => pr_idseqbem);
    FETCH cr_crapbpr INTO rw_crapbpr;
    IF cr_crapbpr%NOTFOUND THEN
      CLOSE cr_crapbpr;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro do bem nao encontrado.';
      --Levantar Excecao  
      RAISE vr_exc_erro;   
    ELSE
      CLOSE cr_crapbpr;
    END IF;
    
    -- Em processamento não pode ser cancelada    
    IF rw_crapbpr.cdsitgrv = 1 THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Cancelamento nao efetuado! Em processamento CETIP.';
      --Levantar Excecao  
      RAISE vr_exc_erro;        
    END IF;  
      
    -- Validar o prazo máximo para cancelamento      
    IF (rw_crapdat.dtmvtolt - rw_crapbpr.dtatugrv) > 30 THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Prazo para cancelamento ultrapassado.';
      --Levantar Excecao  
      RAISE vr_exc_erro; 
    END IF;
    
    -- Validar o tipo do cancelamento    
    IF pr_tpcancel NOT IN ('A','M') THEN          
      vr_cdcritic:= 0;
      vr_dscritic:= 'Tipo de cancelamento invalido.';
      --Levantar Excecao  
      RAISE vr_exc_erro;       
    END IF;
    
    -- Atualizar a situação do Gravames quando manual
    IF pr_tpcancel = 'M' THEN
    BEGIN
      UPDATE crapbpr
           SET crapbpr.tpcancel = pr_tpcancel
              ,crapbpr.flcancel = 1
              ,crapbpr.flginclu = 0              
              ,crapbpr.dtcancel = rw_crapdat.dtmvtolt
              ,crapbpr.cdsitgrv = 5
              ,crapbpr.dsjuscnc = pr_dsjuscnc
              ,crapbpr.dsjstbxa = NULL -- Limpar alguma justificativa de baixa manual anterior
      WHERE ROWID = rw_crapbpr.rowid_bpr;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel alterar o bem.';
          
        --Levantar Excecao  
        RAISE vr_exc_erro; 
    END;
    END IF;  
    
    -- GEração de LOG 
    gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad 
                        ,pr_dscritic => ''         
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => rw_crapdat.dtmvtolt
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => vr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'Data Cancel.', 
                              pr_dsdadant => TO_CHAR(rw_crapbpr.dtcancel), 
                              pr_dsdadatu => TO_CHAR(rw_crapdat.dtmvtolt)); 
                                
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'Situação', 
                              pr_dsdadant => TO_CHAR(rw_crapbpr.cdsitgrv), 
                              pr_dsdadatu => CASE pr_tpcancel
                                                 WHEN 'M' THEN '5'
                                                 ELSE TO_CHAR(rw_crapbpr.cdsitgrv)
                                             END);                                    

    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'Justificativa', 
                              pr_dsdadant => null, 
                              pr_dsdadatu => pr_dsjuscnc); 

    -- Incluir operador                           
    if pr_cdopeapr is not null then
      -- Busca nome do operador
      open cr_crapope(vr_cdcooper,pr_cdopeapr);
        fetch cr_crapope into rw_crapope;
        if cr_crapope%found then
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Aprovador',
                                    pr_dsdadant => null,
                                    pr_dsdadatu => pr_cdopeapr||' - '||rw_crapope.nmoperad);
        else
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Cod.Aprovador',
                                    pr_dsdadant => null,
                                    pr_dsdadatu => pr_cdopeapr);
        end if;
      close cr_crapope;
    end if;
    
    -- Caso Gravames ONLINE e foi solicitado Cancelamento AUtomático
    IF pr_tpcancel = 'A' AND fn_tem_gravame_online(pr_cdcooper => vr_cdcooper) = 'S' THEN
      
      /* Procedimento para busca do emitente (Inverveniente, se houver) */
      pc_busca_emitente(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctrpro
                       ,pr_nrcpfbem => rw_crapbpr.nrcpfbem
                       ,pr_nrcpfemi => vr_vet_dados.nrcpfemi
                       ,pr_nmprimtl => vr_vet_dados.nmprimtl);    
    
      -- Chamar rotina para geraçaõ do XML de desalienação
      pc_gera_xml_desalienacao(pr_cdcooper => vr_cdcooper -- Cod. Cooperativa
                              ,pr_nrdconta => pr_nrdconta -- Nr. da conta
                              ,pr_tpctrato => pr_tpctrpro -- Tp. contrato
                              ,pr_nrctrpro => pr_nrctrpro -- Nr. contrato
                              ,pr_idseqbem => pr_idseqbem -- Sequencial do bem
                              ,pr_tpdesali => 'C'         -- Tipo [C]ancelamento ou [B]aixa
                              ,pr_flaborta => 'N'         -- Flag S/N se a operação aborta outras na sequencia em caso de erro
                              ,pr_flgobrig => 'N'         -- Flag S/N se a operação é obrigatória para prosseguir para próximo fluxo
                               /* SistemaNacionalGravames */
                              ,pr_uflicenc => rw_crapbpr.uflicenc   -- UF                                 
                              /* ObjetoContratoCredito */
                              ,pr_dschassi => rw_crapbpr.dschassi   -- Chassi
                              ,pr_tpchassi => rw_crapbpr.tpchassi   -- Tipo Chassi
                              ,pr_nrrenava => rw_crapbpr.nrrenava   -- Renavam
                              /* Emitente */
                              ,pr_nrcpfemi => vr_vet_dados.nrcpfemi -- CPF/CNPJ Emitente                                 
                              /* Saida */
                              ,pr_xmldesal => vr_xmltemp    -- XML do Cancelamento de alienação
                              ,pr_dscritic => vr_dscritic); -- Descrição de critica encontrada
      -- Em caso de erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Se houve retorno no CLOB
      IF LENGTH(vr_xmltemp) > 0 THEN
        -- Adicionaremos ao retorno o XML montado para consulta de alienação
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><gravameB3>'||vr_xmltemp||'</gravameB3></Root>'); 
        
      END IF;
      
    ELSIF pr_tpcancel = 'M' THEN
      -- Se baixa manual, gerar GRV com 300 e 900
      BEGIN
        INSERT INTO crapgrv
                   (cdcooper
                   ,nrdconta
                   ,tpctrpro
                   ,nrctrpro
                   ,dschassi
                   ,idseqbem
                   ,nrseqlot
                   ,cdoperac
                   ,nrseqreg
                   ,cdretlot
                   ,cdretgrv
                   ,cdretctr
                   ,dtenvgrv
                   ,dtretgrv
                   ,dscatbem
                   ,dstipbem
                   ,dsmarbem
                   ,dsbemfin
                   ,nrcpfbem
                   ,tpchassi
                   ,uflicenc
                   ,nranobem
                   ,nrmodbem
                   ,ufdplaca
                   ,nrdplaca
                   ,nrrenava)
             VALUES(vr_cdcooper           --cdcooper
                   ,pr_nrdconta           --nrdconta
                   ,pr_tpctrpro           --tpctrpro
                   ,pr_nrctrpro           --nrctrpro
                   ,rw_crapbpr.dschassi   --dschassi
                   ,pr_idseqbem           --idseqbem
                   ,0                     --nrseqlot
                   ,2                     --cdoperac
                   ,0                     --nrseqreg
                   ,0                     --cdretlot
                   ,300                   --cdretgrv
                   ,0                     --cdretctr
                   ,SYSDATE               --dtenvgrv
                   ,SYSDATE               --dtretgrv
                   ,rw_crapbpr.dscatbem   --dscatbem
                   ,rw_crapbpr.dstipbem   --dstipbem
                   ,rw_crapbpr.dsmarbem   --dsmarbem
                   ,rw_crapbpr.dsbemfin   --dsbemfin
                   ,rw_crapbpr.nrcpfbem   --nrcpfbem
                   ,rw_crapbpr.tpchassi   --tpchassi
                   ,rw_crapbpr.uflicenc   --uflicenc
                   ,rw_crapbpr.nranobem   --nranobem
                   ,rw_crapbpr.nrmodbem   --nrmodbem
                   ,rw_crapbpr.ufdplaca   --ufdplaca
                   ,rw_crapbpr.nrdplaca   --nrdplaca
                   ,rw_crapbpr.nrrenava); --nrrenava
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir histórico Gravames: '||SQLERRM;
          RAISE vr_exc_erro;
      END;    
    
    END IF;
    
    --        
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
                                     
      --Padronização - Chamado 660394
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Mensagem
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ALERTA: '|| pr_dscritic ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Tpctrpro:'||pr_tpctrpro||
                                                    ',Idseqbem:'||pr_idseqbem||',Cddopcao:'||pr_cddopcao);
                                           
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gravames_cancelar --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      
      --Padronização - Chamado 660394
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ERRO: ' || pr_dscritic  ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Tpctrpro:'||pr_tpctrpro||
                                                    ',Idseqbem:'||pr_idseqbem||',Cdsitgrv:'||rw_crapbpr.cdsitgrv);

      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
        
  END pc_gravames_cancelar;  

  /* Bloquear ou liberar bloqueio judicial */
  PROCEDURE pc_gravames_blqjud(pr_nrdconta in crapass.nrdconta%type, --Número da conta
                               pr_cddopcao in varchar2,              --Opção
                               pr_nrctrpro in crawepr.nrctremp%type, --Número do contrato 
                               pr_tpctrpro in crapbpr.tpctrpro%type, --Tipo do contrato 
                               pr_idseqbem in crapbpr.idseqbem%type, --Identificador do bem
                               pr_dschassi in crapbpr.dschassi%type, --Chassi do bem
                               pr_ufdplaca in crapbpr.ufdplaca%type, --UF da placa
                               pr_nrdplaca in crapbpr.nrdplaca%type, --Número da placa
                               pr_nrrenava in crapbpr.nrrenava%type, --RENAVAN
                               pr_dsjustif in crapbpr.dsjusjud%type, -- Justificativa
                               pr_flblqjud in crapbpr.flblqjud%type, -- BLoqueio judicial
                               pr_xmllog   in varchar2,              --XML com informações de LOG
                               pr_cdcritic out pls_integer,          --Código da crítica
                               pr_dscritic out varchar2,             --Descrição da crítica
                               pr_retxml   in out nocopy xmltype,    --Arquivo de retorno do XML
                               pr_nmdcampo out varchar2,             --Nome do Campo
                               pr_des_erro out varchar2) IS          --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravames_blqjud                            antiga: b1wgen0171.gravames_blqjud
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 19/10/2018
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realizar o bloqueio judicial do gravame
    
    Alteracoes: 29/05/2017 - Ajuste das mensagens: neste caso são todas consideradas tpocorrencia = 4,
                           - Substituição do termo "ERRO" por "ALERTA",
                           - Padronização das mensagens para a tabela tbgen_prglog,
                           - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
                           - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
                           - Incluir nome do módulo logado em variável
                             (Ana - Envolti) - SD: 660356 e 660394
                
                27/09/2018 - Inclusão de parâmetro para a justificativa para o cancelamento (Daniel - Envolti)
                
                19/10/2018 - P442 - Troca de checagem fixa por funcão para garantir se bem é alienável (Marcos-Envolti)
    -------------------------------------------------------------------------------------------------------------*/                               
  
    -- Cursor para encontrar o bem
    CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE                     
                     ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE
                     ,pr_tpctrpro IN crapbpr.nrctrpro%TYPE
                     ,pr_idseqbem IN crapbpr.idseqbem%TYPE) IS
    SELECT crapbpr.flblqjud
          ,ROWID rowid_bpr                 
      FROM crapbpr
     WHERE crapbpr.cdcooper = pr_cdcooper
       AND crapbpr.nrdconta = pr_nrdconta
       AND crapbpr.tpctrpro = pr_tpctrpro
       AND crapbpr.nrctrpro = pr_nrctrpro
       AND crapbpr.idseqbem = pr_idseqbem
       AND crapbpr.flgalien = 1
       AND grvm0001.fn_valida_categoria_alienavel(crapbpr.dscatbem) = 'S';
    rw_crapbpr cr_crapbpr%ROWTYPE;
      
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto varchar2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_nrdrowid ROWID;
    
    --Variaveis Locais   
    vr_dstransa VARCHAR2(100);
    
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';

    -- Vetor com dados auxiliares para alienação B3
    vr_vet_dados typ_reg_dados;
    

  BEGIN
    IF pr_flblqjud = 1 THEN
      vr_dstransa := 'Bloqueio judicial do bem no gravames';
    ELSE
      vr_dstransa := 'Liberacao judicial do bem no gravames';
    END IF;  
    
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_blqjud');
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
       
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    pc_valida_alienacao_fiduciaria (pr_cdcooper => vr_cdcooper  -- Código da cooperativa
                                   ,pr_nrdconta => pr_nrdconta  -- Numero da conta do associado
                                   ,pr_nrctrpro => pr_nrctrpro  -- Numero do contrato
                                   ,pr_des_reto => vr_des_reto  -- Retorno Ok ou NOK do procedimento
                                   ,pr_vet_dados => vr_vet_dados -- Vetor com dados para auxiliar alienação
                                   ,pr_dscritic => vr_dscritic  -- Retorno da descricao da critica do erro
                                   );

    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
      --Levantar Excecao  
      RAISE vr_exc_erro;
    END IF; 
      
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_blqjud');
      
    IF TRIM(pr_dschassi) IS NULL OR 
       TRIM(pr_nrdplaca) IS NULL OR
       TRIM(pr_ufdplaca) IS NULL OR
       pr_nrrenava = 0           THEN
     
      vr_cdcritic:= 0;
      vr_dscritic:= 'Chassi, UF, Nr. da Placa e Renavam sao obrigatorios!';
      
      --Levantar Excecao  
      RAISE vr_exc_erro;  
    
    END IF;
    
    OPEN cr_crapbpr(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrctrpro => pr_nrctrpro
                   ,pr_tpctrpro => pr_tpctrpro
                   ,pr_idseqbem => pr_idseqbem);
    
    FETCH cr_crapbpr INTO rw_crapbpr;
    
    IF cr_crapbpr%NOTFOUND THEN
    
      CLOSE cr_crapbpr;
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro do bem nao encontrado.';
      
      --Levantar Excecao  
      RAISE vr_exc_erro;   
    
    ELSE
      
      CLOSE cr_crapbpr;
    
      IF pr_cddopcao = 'J'                 AND 
         pr_flblqjud = rw_crapbpr.flblqjud THEN
       
        vr_cdcritic:= 0;
        vr_dscritic:= 'Bloqueio do bem ja registrado.';
        
        --Levantar Excecao  
        RAISE vr_exc_erro;  
      
      END IF;
      
      IF pr_cddopcao = 'L'                 AND 
         pr_flblqjud = rw_crapbpr.flblqjud THEN
       
        vr_cdcritic:= 0;
        vr_dscritic:= 'Liberacao do bem ja registrada.';
        
        --Levantar Excecao  
        RAISE vr_exc_erro;  
      
      END IF;

      BEGIN
        
        UPDATE crapbpr
           SET crapbpr.flblqjud = pr_flblqjud,
               crapbpr.dsjusjud = pr_dsjustif
        WHERE ROWID = rw_crapbpr.rowid_bpr;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Nao foi possivel alterar o bem.';
          
          --Levantar Excecao  
          RAISE vr_exc_erro; 
      END;
    
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad 
                          ,pr_dscritic => ''         
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => rw_crapdat.dtmvtolt
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                pr_nmdcampo => 'Justificativa', 
                                pr_dsdadant => null,
                                pr_dsdadatu => pr_dsjustif);
      
    END IF;
             
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
                                     
      --Padronização - Chamado 660394
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Mensagem
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ALERTA: '|| pr_dscritic ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Tpctrpro:'||pr_tpctrpro||
                                                    ',Idseqbem:'||pr_idseqbem||',Cddopcao:'||pr_cddopcao);
                                           
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gravames_blqjud --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      --Padronização - Chamado 660394
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ERRO: ' || pr_dscritic  ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Tpctrpro:'||pr_tpctrpro||
                                                    ',Idseqbem:'||pr_idseqbem||',Cddopcao:'||pr_cddopcao);

      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
        
  END pc_gravames_blqjud;  

  /* Solicitar Baixa via tela */
  PROCEDURE pc_gravames_baixar(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                    ,pr_cddopcao IN VARCHAR2              --Opção
                                    ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                    ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE --Tipo do contrato
                                    ,pr_idseqbem IN crapbpr.idseqbem%TYPE --Identificador do bem
                              ,pr_tpdbaixa IN crapbpr.tpdbaixa%TYPE -- TIpo da Baixa
                                    ,pr_nrgravam IN crapbpr.nrgravam%TYPE --Número do gravam
                              ,pr_cdopeapr in VARCHAR2              --Operador da aprovação
                                    ,pr_dsjstbxa IN crapbpr.dsjstbxa%TYPE -- Justificativa da baixa
                                    ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*-------------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravames_baixar                            antiga: b1wgen0171.gravames_baixa_manual
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 29/05/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realizar a baixa manual do gravame
    
    Alteracoes: 24/05/2017 - Ajuste das mensagens: neste caso são todas consideradas tpocorrencia = 4,
                           - Substituição do termo "ERRO" por "ALERTA",
                           - Padronização das mensagens para a tabela tbgen_prglog,
                           - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
                           (Ana - Envolti) - SD: 660319

                29/05/2017 - Alteração para não apresentar os parâmetros nas mensagens exibidas em tela.
                           - Apresentar apenas nas exceptions (e na gravação da tabela TBGEN_PRGLOG)
                           (Ana - Envolti) - SD: 660319
                           
                16/10/2018 - P442 - Rename da rotina, devolução dados para desalienação online e parametros
                             para baixar na hora ou não (Marcos-Envolti)
                
    -----------------------------------------------------------------------------------------------------------------*/                               
  
    -- Cursor para encontrar o bem
    CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE                     
                     ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE
                     ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE                     
                     ,pr_idseqbem IN crapbpr.idseqbem%TYPE) IS
    SELECT bpr.flblqjud
          ,bpr.cdsitgrv
          ,bpr.dsjstbxa
          ,bpr.dtdbaixa
          ,bpr.dschassi
          ,bpr.tpchassi
          ,upper(bpr.uflicenc) uflicenc
          ,bpr.dscatbem
          ,bpr.dstipbem
          ,bpr.dsmarbem
          ,bpr.dsbemfin
          ,bpr.nrcpfbem
          ,bpr.nranobem
          ,bpr.nrmodbem
          ,decode(bpr.ufplnovo,' ',bpr.ufdplaca,bpr.ufplnovo) ufdplaca
          ,decode(bpr.nrplnovo,' ',bpr.nrdplaca,bpr.nrplnovo) nrdplaca
          ,decode(bpr.nrrenovo,0,bpr.nrrenava,bpr.nrrenovo) nrrenava
          ,ROWID rowid_bpr                 
      FROM crapbpr bpr
     WHERE bpr.cdcooper = pr_cdcooper
       AND bpr.nrdconta = pr_nrdconta
       AND bpr.tpctrpro = pr_tpctrpro
       AND bpr.nrctrpro = pr_nrctrpro
       AND bpr.idseqbem = pr_idseqbem
       AND bpr.flgalien = 1;
    rw_crapbpr cr_crapbpr%ROWTYPE;
    
    --Cursor para encotrato o contrato de empréstimo 
    CURSOR cr_crapepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE)IS
    SELECT crapepr.nrctremp
      FROM crapepr
     WHERE crapepr.cdcooper = pr_cdcooper
       AND crapepr.nrdconta = pr_nrdconta
       AND crapepr.nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;
      
    -- Código do programa
	  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto varchar2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais   
    vr_dstransa VARCHAR2(100);  
    vr_nrdrowid ROWID; 
    
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
    -- Vetor com dados auxiliares para alienação B3
    vr_vet_dados typ_reg_dados;
         
    -- XML de Envio das Informações
    vr_xmltemp VARCHAR2(32767);
    
  
  BEGIN
    vr_dstransa := 'Baixa do bem no gravames';

    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_baixa_manual');
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
       
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    -- Validar a alienação
    pc_valida_alienacao_fiduciaria (pr_cdcooper => vr_cdcooper  -- Código da cooperativa
                                   ,pr_nrdconta => pr_nrdconta  -- Numero da conta do associado
                                   ,pr_nrctrpro => pr_nrctrpro  -- Numero do contrato
                                   ,pr_des_reto => vr_des_reto  -- Retorno Ok ou NOK do procedimento
                                   ,pr_vet_dados => vr_vet_dados -- Vetor com dados para auxiliar alienação
                                   ,pr_dscritic => vr_dscritic  -- Retorno da descricao da critica do erro
                                   );

    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
      --Levantar Excecao  
      RAISE vr_exc_erro;
    END IF; 
    
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_baixa_automatica');
    
    -- Validar o Bem
    OPEN cr_crapbpr(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrctrpro => pr_nrctrpro
                   ,pr_tpctrpro => pr_tpctrpro
                   ,pr_idseqbem => pr_idseqbem);
    FETCH cr_crapbpr INTO rw_crapbpr;
    IF cr_crapbpr%NOTFOUND THEN
      CLOSE cr_crapbpr;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro do bem nao encontrado.';
      --Levantar Excecao  
      RAISE vr_exc_erro;   
    ELSE
      CLOSE cr_crapbpr;
    END IF;
    
    -- Validar proposta    
    OPEN cr_crapepr(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrctremp => pr_nrctrpro);
    FETCH cr_crapepr INTO rw_crapepr;
    IF cr_crapepr%NOTFOUND     AND 
       rw_crapbpr.cdsitgrv = 0 THEN
      --Fechar Cursor
      CLOSE cr_crapepr;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Situacao do Bem invalida! Gravame nao OK!';
      --Levantar Excecao  
      RAISE vr_exc_erro;  
    ELSE
      --Fechar Cursor
      CLOSE cr_crapepr;     
    END IF;
      
    -- Baixa permitida apenas quando alienado
    IF rw_crapbpr.cdsitgrv <> 0 AND
       rw_crapbpr.cdsitgrv <> 2 AND
       rw_crapbpr.cdsitgrv <> 3 THEN
         
      vr_cdcritic:= 0;
      vr_dscritic:= 'Situacao do Bem invalida! Gravame nao OK!';
      
      --Levantar Excecao  
      RAISE vr_exc_erro;   
    END IF;
      
    -- Validar o tipo de baixa    
    IF pr_tpdbaixa NOT IN ('A','M') THEN          
      vr_cdcritic:= 0;
      vr_dscritic:= 'Tipo de baixa invalida.';          
      --Levantar Excecao  
      RAISE vr_exc_erro;
    END IF;  
    
    -- Atualizar o contrato quando envio Manual
    IF pr_tpdbaixa = 'M' THEN
    BEGIN
      UPDATE crapbpr
           SET crapbpr.cdsitgrv = 4
            ,crapbpr.flgbaixa = 1
            ,crapbpr.flginclu = 0
            ,crapbpr.dtdbaixa = rw_crapdat.dtmvtolt
            ,crapbpr.dsjstbxa = pr_dsjstbxa
              ,crapbpr.tpdbaixa = pr_tpdbaixa    
              ,crapbpr.dsjuscnc = NULL -- Limpar alguma justificativa de cancelamento manual anterior
      WHERE ROWID = rw_crapbpr.rowid_bpr;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel alterar o bem.';
        --Levantar Excecao  
        RAISE vr_exc_erro; 
    END;
    END IF;  
    
    -- Gerar LOG
    gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad 
                        ,pr_dscritic => ''         
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => rw_crapdat.dtmvtolt
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => vr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'Data Baixa', 
                              pr_dsdadant => to_char(rw_crapbpr.dtdbaixa), 
                              pr_dsdadatu => to_char(rw_crapdat.dtmvtolt)); 
             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'Justificativa', 
                              pr_dsdadant => rw_crapbpr.dsjstbxa, 
                              pr_dsdadatu => pr_dsjstbxa); 

    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'Situação', 
                              pr_dsdadant => to_char(rw_crapbpr.cdsitgrv), 
                              pr_dsdadatu => '4');                               
                              
    -- Incluir operador                           
    if pr_cdopeapr is not null then
      -- Busca nome do operador
      open cr_crapope(vr_cdcooper,pr_cdopeapr);
        fetch cr_crapope into rw_crapope;
        if cr_crapope%found then
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Aprovador',
                                    pr_dsdadant => null,
                                    pr_dsdadatu => pr_cdopeapr||' - '||rw_crapope.nmoperad);
        else
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Cod.Aprovador',
                                    pr_dsdadant => null,
                                    pr_dsdadatu => pr_cdopeapr);
        end if;
      close cr_crapope;
    end if;                                                          
    
    -- CAso Gravames ONLINE e foi solicitado Baixa AUtomático
    IF pr_tpdbaixa = 'A' AND fn_tem_gravame_online(pr_cdcooper => vr_cdcooper) = 'S' THEN

      /* Procedimento para busca do emitente (Inverveniente, se houver) */
      pc_busca_emitente(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctrpro
                       ,pr_nrcpfbem => rw_crapbpr.nrcpfbem
                       ,pr_nrcpfemi => vr_vet_dados.nrcpfemi
                       ,pr_nmprimtl => vr_vet_dados.nmprimtl);  
      
      -- Chamar rotina para geraçaõ do XML de desalienação
      pc_gera_xml_desalienacao(pr_cdcooper => vr_cdcooper -- Cod. Cooperativa
                              ,pr_nrdconta => pr_nrdconta -- Nr. da conta
                              ,pr_tpctrato => pr_tpctrpro -- Tp. contrato
                              ,pr_nrctrpro => pr_nrctrpro -- Nr. contrato
                              ,pr_idseqbem => pr_idseqbem -- Sequencial do bem
                              ,pr_tpdesali => 'B'         -- Tipo [C]ancelamento ou [B]aixa
                              ,pr_flaborta => 'N'         -- Flag S/N se a operação aborta outras na sequencia em caso de erro
                              ,pr_flgobrig => 'N'         -- Flag S/N se a operação é obrigatória para prosseguir para próximo fluxo
                               /* SistemaNacionalGravames */
                              ,pr_uflicenc => rw_crapbpr.uflicenc   -- UF                                 
                              /* ObjetoContratoCredito */
                              ,pr_dschassi => rw_crapbpr.dschassi   -- Chassi
                              ,pr_tpchassi => rw_crapbpr.tpchassi   -- Tipo Chassi
                              ,pr_nrrenava => rw_crapbpr.nrrenava   -- Renavam
                              /* Emitente */
                              ,pr_nrcpfemi => vr_vet_dados.nrcpfemi -- CPF/CNPJ Emitente                                 
                              /* Saida */
                              ,pr_xmldesal => vr_xmltemp    -- XML do Cancelamento de alienação
                              ,pr_dscritic => vr_dscritic); -- Descrição de critica encontrada
      -- Em caso de erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Se houve retorno no CLOB
      IF LENGTH(vr_xmltemp) > 0 THEN
        -- Adicionaremos ao retorno o XML montado para consulta de alienação
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><gravameB3>'||vr_xmltemp||'</gravameB3></Root>'); 
        
      END IF;
    
    ELSIF pr_tpdbaixa = 'M' THEN
      -- Se baixa manual, gerar GRV com 300 e 900
      BEGIN
        INSERT INTO crapgrv
                   (cdcooper
                   ,nrdconta
                   ,tpctrpro
                   ,nrctrpro
                   ,dschassi
                   ,idseqbem
                   ,nrseqlot
                   ,cdoperac
                   ,nrseqreg
                   ,cdretlot
                   ,cdretgrv
                   ,cdretctr
                   ,dtenvgrv
                   ,dtretgrv
                   ,dscatbem
                   ,dstipbem
                   ,dsmarbem
                   ,dsbemfin
                   ,nrcpfbem
                   ,tpchassi
                   ,uflicenc
                   ,nranobem
                   ,nrmodbem
                   ,ufdplaca
                   ,nrdplaca
                   ,nrrenava)
             VALUES(vr_cdcooper           --cdcooper
                   ,pr_nrdconta           --nrdconta
                   ,pr_tpctrpro           --tpctrpro
                   ,pr_nrctrpro           --nrctrpro
                   ,rw_crapbpr.dschassi   --dschassi
                   ,pr_idseqbem           --idseqbem
                   ,0                     --nrseqlot
                   ,3                     --cdoperac
                   ,0                     --nrseqreg
                   ,0                     --cdretlot
                   ,300                   --cdretgrv
                   ,0                     --cdretctr
                   ,SYSDATE               --dtenvgrv
                   ,SYSDATE               --dtretgrv
                   ,rw_crapbpr.dscatbem   --dscatbem
                   ,rw_crapbpr.dstipbem   --dstipbem
                   ,rw_crapbpr.dsmarbem   --dsmarbem
                   ,rw_crapbpr.dsbemfin   --dsbemfin
                   ,rw_crapbpr.nrcpfbem   --nrcpfbem
                   ,rw_crapbpr.tpchassi   --tpchassi
                   ,rw_crapbpr.uflicenc   --uflicenc
                   ,rw_crapbpr.nranobem   --nranobem
                   ,rw_crapbpr.nrmodbem   --nrmodbem
                   ,rw_crapbpr.ufdplaca   --ufdplaca
                   ,rw_crapbpr.nrdplaca   --nrdplaca
                   ,rw_crapbpr.nrrenava); --nrrenava
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir histórico Gravames: '||SQLERRM;
          RAISE vr_exc_erro;
      END;    
    
    END IF;
    
    --              
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
                                     
      --Inclusão dos parâmetros apenas na exception, para não mostrar na tela - Chamado 660356
      --Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Mensagem
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ALERTA: '|| pr_dscritic ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Tpctrpro:'||pr_tpctrpro||
                                                    ',Idseqbem:'||pr_idseqbem||',Cdsitgrv:'||rw_crapbpr.cdsitgrv);
                                           
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gravames_baixa_manual --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      
      --Padronização - Chamado 660394
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ERRO: ' || pr_dscritic  ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Tpctrpro:'||pr_tpctrpro||
                                                    ',Idseqbem:'||pr_idseqbem||',Cdsitgrv:'||rw_crapbpr.cdsitgrv);

      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
                       
        
  END pc_gravames_baixar;  

  /* Validar a inclusão manual */
  PROCEDURE pc_gravames_valida_inclusao(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                       ,pr_cddopcao IN VARCHAR2              --Opção
                                       ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                       ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE --Tipo do contrato
                                       ,pr_idseqbem IN crapbpr.idseqbem%TYPE --Identificador do bem
                                       ,pr_tpinclus IN crapbpr.tpinclus%TYPE --Tipo da Inclusão 
                                       ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravames_valida_inclusao                            antiga: b1wgen0171.gravames_inclusao_manual
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 29/05/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realizar a validação de permissão para inclusao do gravame
                 Também retornamos informações necessárias para uma possível consulta
                 Online na B3 da situação do GRAVAME
    
    Alteracoes: 
                             
    -------------------------------------------------------------------------------------------------------------*/                               
  
    -- Retorno validação
    vr_des_reto varchar2(4000);
    -- Vetor com dados auxiliares para alienação B3
    vr_vet_dados typ_reg_dados;
        
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    -- Cursor para encontrar o bem
    CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE                     
                     ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE
                     ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE                     
                     ,pr_idseqbem IN crapbpr.idseqbem%TYPE) IS
    SELECT crapbpr.cdsitgrv
          ,crapbpr.dschassi
          ,crapbpr.tpchassi  
          ,crapbpr.uflicenc 
          ,crapbpr.dscatbem
          ,crapbpr.dstipbem
          ,crapbpr.dsmarbem
          ,crapbpr.dsbemfin
          ,crapbpr.nrcpfbem
          ,crapbpr.nranobem
          ,crapbpr.nrmodbem
          ,decode(crapbpr.ufplnovo,' ',crapbpr.ufdplaca,crapbpr.ufplnovo) ufdplaca
          ,decode(crapbpr.nrplnovo,' ',crapbpr.nrdplaca,crapbpr.nrplnovo) nrdplaca
          ,decode(crapbpr.nrrenovo,0,crapbpr.nrrenava,crapbpr.nrrenovo) nrrenava                 
      FROM crapbpr
     WHERE crapbpr.cdcooper = pr_cdcooper
       AND crapbpr.nrdconta = pr_nrdconta
       AND crapbpr.tpctrpro = pr_tpctrpro
       AND crapbpr.nrctrpro = pr_nrctrpro
       AND crapbpr.idseqbem = pr_idseqbem
       AND crapbpr.flgalien = 1;
    rw_crapbpr cr_crapbpr%ROWTYPE;
    
    -- Cursor para verificar a proposta
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%type
                      ,pr_nrdconta crawepr.nrdconta%type
                      ,pr_nrctrpro crawepr.nrctremp%type) IS
    SELECT crawepr.cdcooper
          ,crawepr.nrdconta
          ,crawepr.nrctremp
          ,crawepr.cdlcremp
          ,crawepr.insitapr 
          ,crawepr.rowid rowid_epr
      FROM crawepr
     WHERE crawepr.cdcooper = pr_cdcooper
       AND crawepr.nrdconta = pr_nrdconta
       AND crawepr.nrctremp = pr_nrctrpro;
    rw_crawepr cr_crawepr%ROWTYPE;
    
    -- Código do programa
	  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';
   
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dsmensag VARCHAR2(100);
    
    -- Temporario para interveniente
    vr_nmprimtl crapass.nmprimtl%TYPE; -- Nome do proprietario do bem
    vr_nrcpfbem crapass.nrcpfcgc%TYPE; -- Cpf do proprietário do bem    
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
    -- XML
    vr_dsxmltemp VARCHAR2(32767);

  BEGIN
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_valida_inclusao');
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
       
    -- Validar alienação
    pc_valida_alienacao_fiduciaria (pr_cdcooper => vr_cdcooper  -- Código da cooperativa
                                   ,pr_nrdconta => pr_nrdconta  -- Numero da conta do associado
                                   ,pr_nrctrpro => pr_nrctrpro  -- Numero do contrato
                                   ,pr_flgcompl => 'S'          -- Trazer todos os dados
                                   ,pr_des_reto => vr_des_reto  -- Retorno Ok ou NOK do procedimento
                                   ,pr_vet_dados => vr_vet_dados -- Vetor com dados para auxiliar alienação
                                   ,pr_dscritic => vr_dscritic  -- Retorno da descricao da critica do erro
                                   );
    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
      --Levantar Excecao  
      RAISE vr_exc_erro; 
    END IF;
    
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    -- Buscar os dados do Bem em Alienação Manual
    OPEN cr_crapbpr(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrctrpro => pr_nrctrpro
                   ,pr_tpctrpro => pr_tpctrpro
                   ,pr_idseqbem => pr_idseqbem);
    FETCH cr_crapbpr INTO rw_crapbpr;
    IF cr_crapbpr%NOTFOUND THEN
      CLOSE cr_crapbpr;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro do bem nao encontrado.';
      --Levantar Excecao  
      RAISE vr_exc_erro;   
    ELSE
      CLOSE cr_crapbpr;
    END IF;
     
    -- Verifica a proposta
    OPEN cr_crawepr(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrctrpro => pr_nrctrpro);
    FETCH cr_crawepr INTO rw_crawepr;
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      vr_cdcritic := gene0001.fn_busca_critica(356);
      vr_dscritic := '';      
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crawepr;
    END IF;
    
    -- Somente prosseguir para propostas aprovadas
    IF rw_crawepr.insitapr <> 1 THEN
      vr_dscritic := 'A proposta deve estar aprovada.'; 
      RAISE vr_exc_erro;
    END IF; 
    
    -- Somente prosseguir em determinadas situações
    IF rw_crapbpr.cdsitgrv <> 0 AND rw_crapbpr.cdsitgrv <> 3 THEN  
      vr_cdcritic := 0;
      -- Em processamento
      IF rw_crapbpr.cdsitgrv = 1 THEN
        vr_dscritic := 'Contrato sendo processado via arquivo. Verifique!';
      -- Alienado
      ELSIF rw_crapbpr.cdsitgrv = 2 THEN
        vr_dscritic := 'Contrato ja foi alienado' || vr_dsmensag || ' Verifique!'; 
      ELSE
        -- Situação inválida
        vr_dscritic := 'Situacao invalida! (Sit:' || rw_crapbpr.cdsitgrv || '). Verifique!'; 
      END IF; 
      RAISE vr_exc_erro;
    END IF;
    
    -- Caso o GRAVAMES online esteja ativo
    IF fn_tem_gravame_online(vr_cdcooper) = 'S' THEN
    
      -- PAra alienação automática
      IF pr_tpinclus = 'A' THEN
        -- Buscar operador
        OPEN cr_crapope(vr_cdcooper,vr_cdoperad);
        FETCH cr_crapope INTO rw_crapope;
        CLOSE cr_crapope;
        -- Default é as informações do cooperado
        vr_nmprimtl := vr_vet_dados.nmprimtl;
        vr_nrcpfbem := vr_vet_dados.nrcpfemi;
        /* Procedimento para busca do emitente (Inverveniente, se houver) */
        pc_busca_emitente(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrctremp => pr_nrctrpro
                         ,pr_nrcpfbem => rw_crapbpr.nrcpfbem
                         ,pr_nrcpfemi => vr_nrcpfbem
                         ,pr_nmprimtl => vr_nmprimtl);            
        -- Gerar o XML de alienação
        pc_gera_xml_alienacao(pr_cdcooper => vr_cdcooper -- Cod. Cooperativa
                             ,pr_nrdconta => pr_nrdconta -- Nr. da conta
                             ,pr_tpctrato => 90          -- Tp. contrato
                             ,pr_nrctrpro => pr_nrctrpro -- Nr. contrato
                             ,pr_idseqbem => pr_idseqbem -- Sequencial do bem
                             ,pr_flaborta => 'S'             -- Flag S/N se a operação aborta outras na sequencia em caso de erro
                             ,pr_flgobrig => 'S'             -- Flag S/N se a operação é obrigatória para prosseguir para próximo fluxo
                             /* SistemaNacionalGravames */
                             ,pr_uflicenc => rw_crapbpr.uflicenc -- UF de Licenciamento
                             ,pr_tpaliena => '03'            -- Tipo da Alienação
                             ,pr_dtlibera => vr_vet_dados.dtlibera -- Data da Liberação
                             /* ObjetoContratoCredito */
                             ,pr_dschassi => rw_crapbpr.dschassi -- Chassi
                             ,pr_tpchassi => rw_crapbpr.tpchassi -- Tipo Chassi
                             ,pr_ufdplaca => rw_crapbpr.ufdplaca -- UF
                             ,pr_nrdplaca => rw_crapbpr.nrdplaca -- PLaca
                             ,pr_nrrenava => rw_crapbpr.nrrenava -- Renavam
                             ,pr_nranobem => rw_crapbpr.nranobem -- Ano Fabricacao
                             ,pr_nrmodbem => rw_crapbpr.nrmodbem -- Ano modelo                               
                             /* propostaContratoCredito */
                             ,pr_nrctremp => pr_nrctrpro           -- Contrato
                             ,pr_dtmvtolt => vr_vet_dados.dtmvtolt -- Data digitação
                             ,pr_qtpreemp => vr_vet_dados.qtpreemp -- Quantidade parcelas
                             ,pr_permulta => vr_vet_dados.permulta -- Percentual de Multa
                             ,pr_txmensal => vr_vet_dados.txmensal -- Taxa mensal
                             ,pr_vlemprst => vr_vet_dados.vlemprst -- Valor Empréstimo
                             ,pr_tpemprst => vr_vet_dados.tpemprst -- Tipo Emprestimo
                             ,pr_dtdpagto => vr_vet_dados.dtdpagto -- Data da primeira parcela
                             ,pr_dtpagfim => vr_vet_dados.dtvencto -- Data da ultima parcela
                             /* Emitente */
                             ,pr_nrcpfemi => vr_nrcpfbem           -- CPF/CNPJ Emitente
                             ,pr_nmemiten => vr_nmprimtl           -- Nome/Razão Social Emitente
                             ,pr_dsendere => vr_vet_dados.dsendere -- Logradouro Emitente
                             ,pr_nrendere => vr_vet_dados.nrendere -- Numero Emitente
                             ,pr_nmbairro => vr_vet_dados.nmbairro -- Nome Bairro Emitente
                             ,pr_cdufende => vr_vet_dados.cdufende -- UF Emitente
                             ,pr_nrcepend => vr_vet_dados.nrcepend -- CEP Emitente
                             ,pr_cdcidade => vr_vet_dados.cdcidcli -- Cidade
                             ,pr_nrdddtfc => vr_vet_dados.nrdddass -- DDD Emitente
                             ,pr_nrtelefo => vr_vet_dados.nrtelass -- Telefone Emitente
                              /* Credor Eh a Coop */
                             ,pr_nmcddopa => GENE0007.fn_caract_acento(rw_crapope.nmcidade,1) -- Nome da cidade do PA
                             ,pr_cdufdopa => rw_crapope.cdufdcop    -- UF do PA
                             ,pr_inpescre => 2                      -- Tipo pessoa Credor
                             ,pr_nrcpfcre => vr_vet_dados.nrdocnpj  -- CPF/CNPJ Credor
                             ,pr_dsendcre => GENE0007.fn_caract_acento(vr_vet_dados.dsendcre) -- Logradouro Credor
                             ,pr_nrendcre => vr_vet_dados.nrendcre -- Numero Credor
                             ,pr_nmbaicre => GENE0007.fn_caract_acento(vr_vet_dados.nmbaicre,1) -- Nome Bairro Credor
                             ,pr_cdufecre => vr_vet_dados.cdufecre -- UF Credor
                             ,pr_cdcidcre => vr_vet_dados.cdcidcre     -- Cidade Credor
                             ,pr_nrcepcre => vr_vet_dados.nrcepcre -- CEP Credor
                             ,pr_nrdddcre => vr_vet_dados.nrdddenc  -- DDD Credor
                             ,pr_nrtelcre => vr_vet_dados.nrtelenc  -- Telefone Credor
                             /* Dados do Vendedor */
                             ,pr_nrcpfven => 0 /*crapass.nrcpfcgc*/ -- CPF/CNPJ Vendedor
                             /* Recebedor do pagamento */
                             ,pr_inpesrec => 2                      -- Tipo Pessoa Recebedor (Cooperativa)
                             ,pr_nrcpfrec => vr_vet_dados.nrdocnpj  -- CPF/CNPJ Vendedor
                             /* Saida */
                             ,pr_xmlalien => vr_dsxmltemp  -- XML da alienação
                             ,pr_dscritic => vr_dscritic); -- Descrição de critica encontrada
        
      ELSE
        -- Acionaremos a rotina que irá gerar um XML com os dados do Bem para Consulta de Situação na B3  
        pc_gera_xml_cons_alienac(pr_cdcooper => vr_cdcooper -- Cod. Cooperativa
                                ,pr_nrdconta => pr_nrdconta -- Nr. da conta
                                ,pr_tpctrato => pr_tpctrpro -- Tp. contrato
                                ,pr_nrctrpro => pr_nrctrpro -- Nr. contrato
                                ,pr_idseqbem => pr_idseqbem -- Sequencial do bem
                                 /* SistemaNacionalGravames */
                                ,pr_uflicenc => rw_crapbpr.uflicenc     -- UF                                 
                                /* ObjetoContratoCredito */
                                ,pr_dschassi => rw_crapbpr.dschassi -- Chassi
                                ,pr_tpchassi => rw_crapbpr.tpchassi -- Tipo Chassi
                                /* Saida */
                                ,pr_xmlconsu => vr_dsxmltemp  -- XML da Consulta de alienação
                                ,pr_dscritic => vr_dscritic); -- Descrição de critica encontrada
      END IF;
          
      -- Em caso de erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro; 
      END IF;
        
      -- Adicionaremos ao retorno o XML montado para consulta de alienação
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><gravameB3>'||vr_dsxmltemp||'</gravameB3></Root>'); 
          
    -- Se não tem GRavames Online e está tentando fazer uma inclusão automática
    ELSIF pr_tpinclus = 'A' THEN
      -- Gerar erro
      vr_dscritic := 'Nao e possivel alienar automaticamente, o processo on-line nao esta ativado';
        RAISE vr_exc_erro; 
             
    END IF;
    --              
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
                                     
      --Inclusão dos parâmetros apenas na exception, para não mostrar na tela - Chamado 660356
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Mensagem
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ALERTA: '|| pr_dscritic ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Tpctrpro:'||pr_tpctrpro||
                                                    ',Idseqbem:'||pr_idseqbem||',Cdsitgrv:'||rw_crapbpr.cdsitgrv);
                                           
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gravames_inclusao_manual --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      
      -- Gera log
      --Inclusão dos parâmetros apenas na exception, para não mostrar na tela
      --Padronização - Chamado 660394
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ERRO: ' || pr_dscritic  ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Tpctrpro:'||pr_tpctrpro||
                                                    ',Idseqbem:'||pr_idseqbem||',Cdsitgrv:'||rw_crapbpr.cdsitgrv);

      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
        
  END pc_gravames_valida_inclusao;

  /* Solicitar inclusão de Gravames */
  PROCEDURE pc_gravames_inclusao(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                ,pr_cddopcao IN VARCHAR2              --Opção
                                ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE --Tipo do contrato
                                ,pr_idseqbem IN crapbpr.idseqbem%TYPE --Identificador do bem
                                ,pr_nrgravam IN crapbpr.nrgravam%TYPE --Número do gravam
                                ,pr_dtmvttel IN VARCHAR2              --Data do registro
                                ,pr_dsjustif IN crapbpr.dsjstbxa%TYPE --Justificativa da inclusão
                                ,pr_tpinclus IN crapbpr.tpinclus%TYPE --Tipo da Inclusão 
                                ,pr_cdopeapr IN crapope.cdoperad%TYPE --Operador da aprovação
                                ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravames_inclusao                            antiga: b1wgen0171.gravames_inclusao_manual
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 29/05/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realizar a inclusao manual do gravame
    
    Alteracoes: 29/05/2017 - Ajuste das mensagens: neste caso são todas consideradas tpocorrencia = 4,
                           - Substituição do termo "ERRO" por "ALERTA",
                           - Padronização das mensagens para a tabela tbgen_prglog,
                           - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
                           - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
                           - Incluir nome do módulo logado em variável
                             (Ana - Envolti) - SD: 660356 e 660394
                             
                16/10/2018 - P442 - Rename da rotina, devolução dados para desalienação online e parametros
                             para baixar na hora ou não (Marcos-Envolti)          
                             
    -------------------------------------------------------------------------------------------------------------*/                               
  
    -- Cursor para encontrar o bem
    CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE                     
                     ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE
                     ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE                     
                     ,pr_idseqbem IN crapbpr.idseqbem%TYPE) IS
    SELECT bpr.flblqjud
          ,bpr.tpinclus
          ,bpr.cdsitgrv
          ,bpr.dtdinclu
          ,bpr.dsjstinc
          ,bpr.nrgravam
          ,bpr.dtatugrv
          ,bpr.dschassi
          ,bpr.dscatbem
          ,bpr.dstipbem
          ,bpr.dsmarbem
          ,bpr.dsbemfin
          ,bpr.nrcpfbem
          ,bpr.tpchassi
          ,bpr.uflicenc
          ,bpr.nranobem
          ,bpr.nrmodbem
          ,bpr.ufdplaca
          ,bpr.nrdplaca
          ,bpr.nrrenava
          ,ROWID rowid_bpr                 
      FROM crapbpr bpr
     WHERE bpr.cdcooper = pr_cdcooper
       AND bpr.nrdconta = pr_nrdconta
       AND bpr.tpctrpro = pr_tpctrpro
       AND bpr.nrctrpro = pr_nrctrpro
       AND bpr.idseqbem = pr_idseqbem
       AND bpr.flgalien = 1;
    rw_crapbpr cr_crapbpr%ROWTYPE;
    
    -- Cursor para verificar a proposta
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%type
                      ,pr_nrdconta crawepr.nrdconta%type
                      ,pr_nrctrpro crawepr.nrctremp%type) IS
    SELECT crawepr.cdcooper
          ,crawepr.nrdconta
          ,crawepr.nrctremp
          ,crawepr.cdlcremp
          ,crawepr.rowid rowid_epr
      FROM crawepr
     WHERE crawepr.cdcooper = pr_cdcooper
       AND crawepr.nrdconta = pr_nrdconta
       AND crawepr.nrctremp = pr_nrctrpro;
    rw_crawepr cr_crawepr%rowtype;
    
    -- Código do programa
	  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';
   
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto varchar2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dsmensag VARCHAR2(100);
    vr_dtmvttel DATE;
    
    --Variaveis Locais   
    vr_dstransa VARCHAR2(100);  
    vr_nrdrowid ROWID;
        
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    
    -- Vetor com dados auxiliares para alienação B3
    vr_vet_dados typ_reg_dados;
    
  
  BEGIN
    vr_dstransa := 'Inclusão do bem no gravames';

    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_inclusao_manual');
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
       
    BEGIN                                                  
      --Pega a data do registro
      vr_dtmvttel := to_date(pr_dtmvttel,'DD/MM/RRRR'); 
                      
    EXCEPTION
      WHEN OTHERS THEN
          
        --Monta mensagem de critica
        vr_dscritic := 'Data do registro invalida.';
        pr_nmdcampo := 'dtmvttel';
          
        --Gera exceção
        RAISE vr_exc_erro;
    END;
    
    IF TRIM(pr_dsjustif) IS NULL AND pr_tpinclus != 'A'  THEN
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Justificativa deve ser informada!';
      pr_nmdcampo := 'dsjustif';
      
      --Levantar Excecao  
      RAISE vr_exc_erro; 

    END IF;
    
    IF pr_nrgravam = 0 THEN
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Numero do Registro deve ser informado!';
      pr_nmdcampo := 'nrgravam';
      
      --Levantar Excecao  
      RAISE vr_exc_erro;  
    
    END IF;   
    
    
    -- Validar o tipo de Inclusão    
    IF pr_tpinclus NOT IN ('A','MC','M') THEN          
      vr_cdcritic:= 0;
      vr_dscritic:= 'Tipo de inclusão invalida.';          
      --Levantar Excecao  
      RAISE vr_exc_erro;
    END IF;
    
    
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);      
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;      
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    pc_valida_alienacao_fiduciaria (pr_cdcooper => vr_cdcooper  -- Código da cooperativa
                                   ,pr_nrdconta => pr_nrdconta  -- Numero da conta do associado
                                   ,pr_nrctrpro => pr_nrctrpro  -- Numero do contrato
                                   ,pr_des_reto => vr_des_reto  -- Retorno Ok ou NOK do procedimento
                                   ,pr_vet_dados => vr_vet_dados -- Vetor com dados para auxiliar alienação
                                   ,pr_dscritic => vr_dscritic  -- Retorno da descricao da critica do erro
                                   );
    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
      --Levantar Excecao  
      RAISE vr_exc_erro;
    END IF; 
    
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_inclusao_manual');
    
    OPEN cr_crapbpr(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrctrpro => pr_nrctrpro
                   ,pr_tpctrpro => pr_tpctrpro
                   ,pr_idseqbem => pr_idseqbem);    
    FETCH cr_crapbpr INTO rw_crapbpr;    
    IF cr_crapbpr%NOTFOUND THEN    
      CLOSE cr_crapbpr;      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro do bem nao encontrado.';      
      --Levantar Excecao  
      RAISE vr_exc_erro;      
    ELSE      
      CLOSE cr_crapbpr;    
    END IF;
     
    -- Verifica a proposta
    OPEN cr_crawepr(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrctrpro => pr_nrctrpro);    
    FETCH cr_crawepr INTO rw_crawepr;    
    IF cr_crawepr%NOTFOUND THEN      
      CLOSE cr_crawepr;      
      vr_cdcritic := gene0001.fn_busca_critica(356);
      vr_dscritic := '';      
      RAISE vr_exc_erro;    
    ELSE      
      CLOSE cr_crawepr;        
    END IF;
    
    -- Incrementar mensagem de erro (se encontrado)    
    IF rw_crapbpr.tpinclus = 'A' THEN    
      vr_dsmensag := ' automatica.';      
    ELSE      
      vr_dsmensag := ' de forma manual.';    
    END IF; 
    
    -- Inclusão só permitira se situação <> Não enviada e Processado com critica
    IF rw_crapbpr.cdsitgrv NOT in(0,3) AND pr_tpinclus = 'M' THEN  
      
      vr_cdcritic := 0;      
      IF rw_crapbpr.cdsitgrv = 1 THEN        
        vr_dscritic := 'Contrato sendo processado via arquivo. Verifique!';      
      ELSIF rw_crapbpr.cdsitgrv = 2 THEN        
        vr_dscritic := 'Contrato ja foi alienado' || vr_dsmensag || ' Verifique!';       
      ELSE        
        vr_dscritic := 'Situacao invalida! (Sit:' || rw_crapbpr.cdsitgrv || '). Verifique!';       
      END IF;
      RAISE vr_exc_erro;    
    END IF;
    
    -- Quando requisição Manual
    IF pr_tpinclus = 'M' THEN 
      BEGIN
        UPDATE crapbpr
           SET crapbpr.flginclu = decode(pr_cdopeapr,null,0,1) -- Se veio operador, é pq não consegui consultar, então mantém a pendência 
              ,crapbpr.dtdinclu = rw_crapdat.dtmvtolt
              ,crapbpr.dsjstinc = pr_dsjustif
              ,crapbpr.tpinclus = pr_tpinclus                                
              ,crapbpr.cdsitgrv = 2 
              ,crapbpr.nrgravam = pr_nrgravam
              ,crapbpr.dtatugrv = vr_dtmvttel
              ,crapbpr.flgalfid = 1
        WHERE ROWID = rw_crapbpr.rowid_bpr;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Nao foi possivel alterar o bem.';
            
          --Levantar Excecao  
          RAISE vr_exc_erro; 
      END;
    END IF;
    
    -- Setar no Contrato que o GRAVAMES está OK caso não haja outro bem não alieando
    BEGIN        
      UPDATE crawepr wpr
         SET wpr.flgokgrv = 1       
      WHERE ROWID = rw_crawepr.rowid_epr
         AND NOT EXISTS(SELECT 1
                          FROM crapbpr bpr
                         WHERE bpr.cdcooper = wpr.cdcooper
                           AND bpr.nrdconta = wpr.nrdconta
                           AND bpr.nrctrpro = wpr.nrctremp
                           AND bpr.tpctrpro = 90
                           AND bpr.flgalien = 1
                           AND bpr.cdsitgrv <> 2);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel alterar a proposta.';
          
        --Levantar Excecao  
        RAISE vr_exc_erro; 
    END;
    
    -- Geração de LOG
    gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad 
                        ,pr_dscritic => ''         
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => rw_crapdat.dtmvtolt
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => vr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'Data Inclusao', 
                              pr_dsdadant => to_char(rw_crapbpr.dtdinclu), 
                              pr_dsdadatu => to_char(rw_crapdat.dtmvtolt)); 

    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'Justificativa', 
                              pr_dsdadant => rw_crapbpr.dsjstinc, 
                              pr_dsdadatu => pr_dsjustif); 

    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'Situacao', 
                              pr_dsdadant => to_char(rw_crapbpr.cdsitgrv), 
                              pr_dsdadatu => '2');

    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'Nr.Gravam', 
                              pr_dsdadant => to_char(rw_crapbpr.nrgravam), 
                              pr_dsdadatu => to_char(pr_nrgravam));
             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'Data Atualização', 
                              pr_dsdadant => to_char(rw_crapbpr.dtatugrv), 
                              pr_dsdadatu => to_char(vr_dtmvttel));
                              
    -- Incluir operador                           
    if pr_cdopeapr is not null then
      -- Busca nome do operador
      open cr_crapope(vr_cdcooper,pr_cdopeapr);
        fetch cr_crapope into rw_crapope;
        if cr_crapope%found then
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Aprovador',
                                    pr_dsdadant => null,
                                    pr_dsdadatu => pr_cdopeapr||' - '||rw_crapope.nmoperad);
        else
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Cod.Aprovador',
                                    pr_dsdadant => null,
                                    pr_dsdadatu => pr_cdopeapr);
        end if;
      close cr_crapope;
    end if;      
    
    -- Se inclusão manual, gerar GRV com 300 e 900
    IF pr_tpinclus = 'M' THEN
      BEGIN
        INSERT INTO crapgrv
                   (cdcooper
                   ,nrdconta
                   ,tpctrpro
                   ,nrctrpro
                   ,dschassi
                   ,idseqbem
                   ,nrseqlot
                   ,cdoperac
                   ,nrseqreg
                   ,cdretlot
                   ,cdretgrv
                   ,cdretctr
                   ,dtenvgrv
                   ,dtretgrv
                   ,dscatbem
                   ,dstipbem
                   ,dsmarbem
                   ,dsbemfin
                   ,nrcpfbem
                   ,tpchassi
                   ,uflicenc
                   ,nranobem
                   ,nrmodbem
                   ,ufdplaca
                   ,nrdplaca
                   ,nrrenava)
             VALUES(vr_cdcooper           --cdcooper
                   ,pr_nrdconta           --nrdconta
                   ,pr_tpctrpro           --tpctrpro
                   ,pr_nrctrpro           --nrctrpro
                   ,rw_crapbpr.dschassi   --dschassi
                   ,pr_idseqbem           --idseqbem
                   ,0                     --nrseqlot
                   ,1                     --cdoperac
                   ,0                     --nrseqreg
                   ,0                     --cdretlot
                   ,300                   --cdretgrv
                   ,900                   --cdretctr
                   ,SYSDATE               --dtenvgrv
                   ,SYSDATE               --dtretgrv
                   ,rw_crapbpr.dscatbem   --dscatbem
                   ,rw_crapbpr.dstipbem   --dstipbem
                   ,rw_crapbpr.dsmarbem   --dsmarbem
                   ,rw_crapbpr.dsbemfin   --dsbemfin
                   ,rw_crapbpr.nrcpfbem   --nrcpfbem
                   ,rw_crapbpr.tpchassi   --tpchassi
                   ,rw_crapbpr.uflicenc   --uflicenc
                   ,rw_crapbpr.nranobem   --nranobem
                   ,rw_crapbpr.nrmodbem   --nrmodbem
                   ,rw_crapbpr.ufdplaca   --ufdplaca
                   ,rw_crapbpr.nrdplaca   --nrdplaca
                   ,rw_crapbpr.nrrenava); --nrrenava
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir histórico Gravames: '||SQLERRM;
          RAISE vr_exc_erro;
      END;    
    END IF;
                              
    --              
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
                                     
      --Inclusão dos parâmetros apenas na exception, para não mostrar na tela - Chamado 660356
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Mensagem
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ALERTA: '|| pr_dscritic ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Tpctrpro:'||pr_tpctrpro||
                                                    ',Idseqbem:'||pr_idseqbem||',Cdsitgrv:'||rw_crapbpr.cdsitgrv);
                                           
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gravames_inclusao_manual --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      
      -- Gera log
      --Inclusão dos parâmetros apenas na exception, para não mostrar na tela
      --Padronização - Chamado 660394
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ERRO: ' || pr_dscritic  ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Tpctrpro:'||pr_tpctrpro||
                                                    ',Idseqbem:'||pr_idseqbem||',Cdsitgrv:'||rw_crapbpr.cdsitgrv);

      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
        
  END pc_gravames_inclusao;  

  -- Preparar XML para alienação de bem novo e desalienação de bem substituído
  procedure pc_prepara_alienacao_aditiv(pr_cdcooper IN crapcop.cdcooper%TYPE -- Cooperativa
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE -- Conta
                                       ,pr_nrctremp IN crawepr.nrctremp%TYPE -- Contrato
                                       ,pr_cdoperad IN crapbpr.cdoperad%TYPE -- Operador
                                       ,pr_idseqbem IN crapbpr.idseqbem%TYPE -- Bem a substituir
                                       ,pr_tpchassi IN crapbpr.tpchassi%TYPE -- Tipo Chassi
                                       ,pr_dschassi IN crapbpr.dschassi%TYPE -- Chassi
                                       ,pr_ufdplaca IN crapbpr.ufdplaca%TYPE -- UF Placa
                                       ,pr_nrdplaca IN crapbpr.nrdplaca%TYPE -- Placa
                                       ,pr_nrrenava IN crapbpr.nrrenava%TYPE -- Renavam 
                                       ,pr_uflicenc IN crapbpr.uflicenc%TYPE -- UF Licenciamento
                                       ,pr_nranobem IN crapbpr.nranobem%TYPE -- Ano fabricacao
                                       ,pr_nrmodbem IN crapbpr.nrmodbem%TYPE -- Ano Modelo
                                       ,pr_nrcpfbem IN crapbpr.nrcpfbem%TYPE -- CPF Interveniente
                                       ,pr_nmdavali IN crapavt.nmdavali%TYPE -- Nome Interveniente
                                       ,pr_dsxmlali OUT VARCHAR2             -- XML de saida para alienação/desalienação
                                       ,pr_dscritic OUT VARCHAR2) is         -- Critica de saida
    /* .............................................................................
    
        Programa: pc_prepara_alienacao_aditiv
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Marcos Martini (Envolti)
        Data    : Outubro/2018.                    Ultima atualizacao:
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina responsavel em preparar XML para alienação de bem novo e desalienação de bem substituído
    
        Observacao: -----
    
        Alteracoes: 

    ..............................................................................*/    

    
    -- Buscar os dados do bem a substituir
    cursor cr_crapbpr2 is
      select bpr.dschassi
            ,bpr.tpchassi
            ,upper(bpr.uflicenc) uflicenc
            ,bpr.dscatbem
            ,bpr.dstipbem
            ,bpr.dsmarbem
            ,bpr.dsbemfin
            ,bpr.nrcpfbem
            ,bpr.nranobem
            ,bpr.nrmodbem
            ,decode(bpr.ufplnovo,' ',bpr.ufdplaca,bpr.ufplnovo) ufdplaca
            ,decode(bpr.nrplnovo,' ',bpr.nrdplaca,bpr.nrplnovo) nrdplaca
            ,decode(bpr.nrrenovo,0,bpr.nrrenava,bpr.nrrenovo) nrrenava
            ,fin.tpfinali
            ,wpr.cdfinemp
        from crapbpr bpr
            ,crawepr wpr
            ,crapfin fin
       where bpr.cdcooper = wpr.cdcooper
         AND bpr.nrdconta = wpr.nrdconta
         AND bpr.nrctrpro = wpr.nrctremp
         AND wpr.cdcooper = fin.cdcooper
         AND wpr.cdfinemp = fin.cdfinemp
         AND bpr.cdcooper = pr_cdcooper
         and bpr.nrdconta = pr_nrdconta
         and bpr.tpctrpro = 90
         and bpr.nrctrpro = pr_nrctremp
         and bpr.idseqbem = pr_idseqbem;
    rw_bpr cr_crapbpr2%rowtype;
    
    -- Buscar nome de cooperado pelo CPF
    CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
      SELECT nmprimtl
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrcpfcgc = pr_nrcpfcgc;
         
    -- Busca CNPJ lojista
    CURSOR cr_craploj(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE
                     ,pr_nrctremp crawepr.nrctremp%TYPE) IS
      SELECT tve.nrcpf
        FROM tbepr_cdc_emprestimo tce 
            ,tbepr_cdc_vendedor   tve               
       WHERE tce.cdcooper = pr_cdcooper
         AND tce.nrdconta = pr_nrdconta
         AND tce.nrctremp = pr_nrctremp
         AND tce.idvendedor = tve.idvendedor;
      
    
    -- Erros
    vr_des_reto     VARCHAR2(3);
    vr_dscritic     varchar2(4000) := null;
    vr_exc_erro     exception;
    
    -- Vetor com dados auxiliares para alienação B3
    vr_vet_dados typ_reg_dados;
    
    -- Interveniente
    vr_nmprimtl crapass.nmprimtl%TYPE; -- Nome do proprietario do bem
    vr_nrcpfbem crapass.nrcpfcgc%TYPE; -- Cpf do proprietário do bem    
             
    -- Lojista
    vr_nrcpfven crapass.nrcpfcgc%TYPE; -- Cpf do proprietário do bem    
    
    -- XML de Envio das Informações
    vr_xmlalien VARCHAR2(32767);
    vr_xmldesal VARCHAR2(32767);
    
  BEGIN
    
    -- Buscar dados do bem substituido
    open cr_crapbpr2;
    fetch cr_crapbpr2 into rw_bpr;
    if cr_crapbpr2%notfound then
      vr_dscritic := 'Bem selecionado para substituicao nao cadastrado!';
      close cr_crapbpr2;
      raise vr_exc_erro;
    END IF;  
    CLOSE cr_crapbpr2;
        
    -- Validar a alienação para buscar informações necessárias ao envio
    pc_valida_alienacao_fiduciaria (pr_cdcooper => pr_cdcooper  -- Código da cooperativa
                                   ,pr_nrdconta => pr_nrdconta  -- Numero da conta do associado
                                   ,pr_nrctrpro => pr_nrctremp  -- Numero do contrato
                                   ,pr_flgcompl => 'S'          -- Flag busca completa
                                   ,pr_des_reto => vr_des_reto  -- Retorno Ok ou NOK do procedimento
                                   ,pr_vet_dados => vr_vet_dados -- Vetor com dados para auxiliar alienação
                                   ,pr_dscritic => vr_dscritic); -- Retorno da descricao da critica do erro
    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
      --Levantar Excecao  
      RAISE vr_exc_erro;
    END IF;   
    
    -- Buscar operador
    OPEN cr_crapope(pr_cdcooper,pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    CLOSE cr_crapope;
    
    -- Default é as informações do cooperado
    vr_nmprimtl := vr_vet_dados.nmprimtl;
    vr_nrcpfbem := vr_vet_dados.nrcpfemi;
    
    -- Somente neste ponto, a busca do interveniente é diferenciada, pq não temos na base ainda
    IF pr_nrcpfbem <> 0 AND pr_nrcpfbem <> vr_nrcpfbem THEN
      -- Usar os valores preenchidos em tela
      vr_nrcpfbem := pr_nrcpfbem;
      -- Se não veio nome, é pq é um CPF de cooperado, então buscaremos pela ass
      IF trim(pr_nmdavali) IS NULL THEN
        -- Buscar
        OPEN cr_crapass(pr_cdcooper,vr_nrcpfbem);
        FETCH cr_crapass
         INTO vr_nmprimtl;
        CLOSE cr_crapass;
      ELSE
        -- Usaremos o passado
        vr_nmprimtl := pr_nmdavali;
      END IF;
    END IF;
    
    -- Verificar se é uma inclusão CDC que ficou no lote
    IF rw_bpr.tpfinali = 3 AND rw_bpr.cdfinemp = 59 THEN
      -- Buscar CNPJ lojista
      OPEN cr_craploj(pr_cdcooper
                     ,pr_nrdconta
                     ,pr_nrctremp);
      FETCH cr_craploj
       INTO vr_nrcpfven;
      CLOSE cr_craploj;
    ELSE
      -- Não há
      vr_nrcpfven := 0;
    END IF;        
    
    
    -- Inclusão
    pc_gera_xml_alienacao(pr_cdcooper => pr_cdcooper -- Cod. Cooperativa
                         ,pr_nrdconta => pr_nrdconta -- Nr. da conta
                         ,pr_tpctrato => 90          -- Tp. contrato
                         ,pr_nrctrpro => pr_nrctremp -- Nr. contrato
                         ,pr_idseqbem => 0           -- Sequencial do bem
                         ,pr_flaborta => 'S'         -- Flag S/N se a operação aborta outras na sequencia em caso de erro
                         ,pr_flgobrig => 'S'         -- Flag S/N se a operação é obrigatória para prosseguir para próximo fluxo
                         /* SistemaNacionalGravames */
                         ,pr_uflicenc => pr_uflicenc     -- UF de Licenciamento
                         ,pr_tpaliena => '03'            -- Tipo da Alienação
                         ,pr_dtlibera => vr_vet_dados.dtlibera -- Data da Liberação
                         /* ObjetoContratoCredito */
                         ,pr_dschassi => pr_dschassi -- Chassi
                         ,pr_tpchassi => pr_tpchassi -- Tipo Chassi
                         ,pr_ufdplaca => pr_ufdplaca -- UF
                         ,pr_nrdplaca => pr_nrdplaca -- PLaca
                         ,pr_nrrenava => pr_nrrenava -- Renavam
                         ,pr_nranobem => pr_nranobem -- Ano Fabricacao
                         ,pr_nrmodbem => pr_nrmodbem -- Ano modelo                               
                         /* propostaContratoCredito */
                         ,pr_nrctremp => pr_nrctremp           -- Contrato
                         ,pr_dtmvtolt => vr_vet_dados.dtmvtolt -- Data digitação
                         ,pr_qtpreemp => vr_vet_dados.qtpreemp -- Quantidade parcelas
                         ,pr_permulta => vr_vet_dados.permulta -- Percentual de Multa
                         ,pr_txmensal => vr_vet_dados.txmensal -- Taxa mensal
                         ,pr_tpemprst => vr_vet_dados.tpemprst -- Tipo Emprestimo
                         ,pr_vlemprst => vr_vet_dados.vlemprst -- Valor Empréstimo
                         ,pr_dtdpagto => vr_vet_dados.dtdpagto -- Data da primeira parcela
                         ,pr_dtpagfim => vr_vet_dados.dtvencto     -- Data da ultima parcela
                         /* Emitente */
                         ,pr_nrcpfemi => vr_nrcpfbem           -- CPF/CNPJ Emitente
                         ,pr_nmemiten => vr_nmprimtl           -- Nome/Razão Social Emitente
                         ,pr_dsendere => vr_vet_dados.dsendere -- Logradouro Emitente
                         ,pr_nrendere => vr_vet_dados.nrendere -- Numero Emitente
                         ,pr_nmbairro => vr_vet_dados.nmbairro -- Nome Bairro Emitente
                         ,pr_cdufende => vr_vet_dados.cdufende -- UF Emitente
                         ,pr_nrcepend => vr_vet_dados.nrcepend -- CEP Emitente
                         ,pr_cdcidade => vr_vet_dados.cdcidcli -- Cidade
                         ,pr_nrdddtfc => vr_vet_dados.nrdddass -- DDD Emitente
                         ,pr_nrtelefo => vr_vet_dados.nrtelass -- Telefone Emitente
                          /* Credor Eh a Coop */
                         ,pr_nmcddopa => GENE0007.fn_caract_acento(rw_crapope.nmcidade,1) -- Nome da cidade do PA
                         ,pr_cdufdopa => rw_crapope.cdufdcop    -- UF do PA
                         ,pr_inpescre => 2                      -- Tipo pessoa Credor
                         ,pr_nrcpfcre => vr_vet_dados.nrdocnpj  -- CPF/CNPJ Credor
                         ,pr_dsendcre => GENE0007.fn_caract_acento(vr_vet_dados.dsendcre) -- Logradouro Credor
                         ,pr_nrendcre => vr_vet_dados.nrendcre -- Numero Credor
                         ,pr_nmbaicre => GENE0007.fn_caract_acento(vr_vet_dados.nmbaicre,1) -- Nome Bairro Credor
                         ,pr_cdufecre => vr_vet_dados.cdufecre -- UF Credor
                         ,pr_cdcidcre => vr_vet_dados.cdcidcre     -- Cidade Credor
                         ,pr_nrcepcre => vr_vet_dados.nrcepcre -- CEP Credor
                         ,pr_nrdddcre => vr_vet_dados.nrdddenc  -- DDD Credor
                         ,pr_nrtelcre => vr_vet_dados.nrtelenc  -- Telefone Credor
                         /* Dados do Vendedor */
                         ,pr_nrcpfven => vr_nrcpfven            -- CPF/CNPJ Vendedor (Só há em CDC)
                         /* Recebedor do pagamento */
                         ,pr_inpesrec => 2                      -- Tipo Pessoa Vendedor
                         ,pr_nrcpfrec => vr_vet_dados.nrdocnpj  -- CPF/CNPJ Vendedor
                         /* Saida */
                         ,pr_xmlalien => vr_xmlalien   -- XML da alienação
                         ,pr_dscritic => pr_dscritic); -- Descrição de critica encontrada
    -- Em caso de erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    /* Procedimento para busca do emitente (Inverveniente, se houver) */
    pc_busca_emitente(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp
                     ,pr_nrcpfbem => rw_bpr.nrcpfbem
                     ,pr_nrcpfemi => vr_vet_dados.nrcpfemi
                     ,pr_nmprimtl => vr_vet_dados.nmprimtl);       
    
    -- Montagem das informações para desalienação do bem anterior
    pc_gera_xml_desalienacao(pr_cdcooper => pr_cdcooper -- Cod. Cooperativa
                            ,pr_nrdconta => pr_nrdconta -- Nr. da conta
                            ,pr_tpctrato => 90          -- Tp. contrato
                            ,pr_nrctrpro => pr_nrctremp -- Nr. contrato
                            ,pr_idseqbem => pr_idseqbem -- Sequencial do bem
                            ,pr_tpdesali => 'B'         -- Tipo [C]ancelamento ou [B]aixa
                            ,pr_flaborta => 'N'         -- Flag S/N se a operação aborta outras na sequencia em caso de erro
                            ,pr_flgobrig => 'N'         -- Flag S/N se a operação é obrigatória para prosseguir para próximo fluxo
                             /* SistemaNacionalGravames */
                            ,pr_uflicenc => rw_bpr.uflicenc       -- UF                                 
                            /* ObjetoContratoCredito */
                            ,pr_dschassi => rw_bpr.dschassi       -- Chassi
                            ,pr_tpchassi => rw_bpr.tpchassi       -- Tipo Chassi
                            ,pr_nrrenava => rw_bpr.nrrenava       -- Renavam
                            /* Emitente */
                            ,pr_nrcpfemi => vr_vet_dados.nrcpfemi -- CPF/CNPJ Emitente                                 
                            /* Saida */
                            ,pr_xmldesal => vr_xmldesal           -- XML do Cancelamento de alienação
                            ,pr_dscritic => vr_dscritic);         -- Descrição de critica encontrada
    -- Em caso de erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Devolver na variavel de saida as informações para desalieção e alienação em um XML só
    pr_dsxmlali := '<gravameB3>'
                || vr_xmlalien
                || vr_xmldesal
                || '</gravameB3>';
    
  exception
    when vr_exc_erro then
      -- Devolver critica
      pr_dscritic := vr_dscritic;
    when others then
      pr_dscritic := 'Erro nao tratado na rotina GRVM0001.pc_prepara_alienacao_aditiv: ' || SQLERRM; 
  END pc_prepara_alienacao_aditiv;
  
  -- Preparar XML para alienação de bens em Alienação e Desalienação (Refin)
  procedure pc_prepara_alienacao_atenda(pr_nrdconta IN crapass.nrdconta%TYPE -- Conta
                                       ,pr_nrctremp IN crawepr.nrctremp%TYPE -- Contrato
                                       -- Mensageria
                                       ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
    /* .............................................................................
    
        Programa: pc_prepara_alienacao_atenda
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Marcos Martini (Envolti)
        Data    : Outubro/2018.                    Ultima atualizacao:
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina responsavel em preparar XML para alienação de bens em nova proposta
    
        Observacao: -----
    
        Alteracoes: 

    ..............................................................................*/    
    
    -- Código do programa
	  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';
   
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Erros
    vr_des_reto     VARCHAR2(3);
    vr_cdcritic     number;
    vr_dscritic     varchar2(4000) := null;
    vr_exc_erro     exception;
    
    -- Temporario para interveniente
    vr_nmprimtl crapass.nmprimtl%TYPE; -- Nome do proprietario do bem
    vr_nrcpfbem crapass.nrcpfcgc%TYPE; -- Cpf do proprietário do bem    
    
    vr_vet_dados typ_reg_dados;        -- Vetor com dados auxiliares para alienação B3
    
    -- Mensagem padrão para efetivação
    vr_dsmensag VARCHAR2(1000) := gene0007.fn_convert_db_web('Deseja confirmar a efetivacao da proposta?');
    
    -- Varchar2 temporário
    vr_dsxmltemp VARCHAR2(32767);
    
    -- Temporárias para o CLOB
    vr_clobxml CLOB;                   -- CLOB para armazenamento das informações do arquivo
    vr_clobaux VARCHAR2(32767);        -- Var auxiliar para montagem do arquivo
    
    
    -- Cursor para validar a linha de credito da alienacao
    CURSOR cr_craplcr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
      SELECT craplcr.tpctrato
        FROM craplcr
            ,crawepr 
       WHERE crawepr.cdcooper = craplcr.cdcooper
         AND crawepr.cdlcremp = craplcr.cdlcremp
         AND crawepr.cdcooper = pr_cdcooper
         AND crawepr.nrdconta = pr_nrdconta
         AND crawepr.nrctremp = pr_nrctremp;
    rw_craplcr cr_craplcr%rowtype;
    
    -- Buscar bens de contrato enviado
    cursor cr_crapbpr(pr_cdcooper crapepr.cdcooper%TYPE
                     ,pr_nrctremp crapepr.nrctremp%TYPE
                     ,pr_flgalfid crapbpr.flgalfid%TYPE) is
      SELECT ROWID
            ,bpr.nrctrpro
            ,bpr.idseqbem
            ,bpr.dschassi
            ,bpr.tpchassi
            ,bpr.cdsitgrv
            ,upper(bpr.uflicenc) uflicenc
            ,bpr.dscatbem
            ,bpr.dstipbem
            ,bpr.dsmarbem
            ,bpr.dsbemfin
            ,bpr.nrcpfbem
            ,bpr.nranobem
            ,bpr.nrmodbem
            ,decode(bpr.ufplnovo,' ',bpr.ufdplaca,bpr.ufplnovo) ufdplaca
            ,decode(bpr.nrplnovo,' ',bpr.nrdplaca,bpr.nrplnovo) nrdplaca
            ,decode(bpr.nrrenovo,0,bpr.nrrenava,bpr.nrrenovo) nrrenava
        from crapbpr bpr
       where bpr.cdcooper = pr_cdcooper
         and bpr.nrdconta = pr_nrdconta
         and bpr.tpctrpro = 90
         and bpr.nrctrpro = pr_nrctremp
         AND bpr.flgalien = 1 -- Somente alienados 
         AND bpr.flgalfid = pr_flgalfid
         AND fn_valida_categoria_alienavel(bpr.dscatbem) = 'S';
    
    -- Cursor para testar se o Chassi enviado está na lista de bens alienáveis do contrato em efetivação
    CURSOR cr_bprrefin(pr_cdcooper crapepr.cdcooper%TYPE
                      ,pr_dschassi crapbpr.dschassi%TYPE) IS
      SELECT 1
        FROM crapbpr bpr
       WHERE bpr.cdcooper = pr_cdcooper
         AND bpr.nrdconta = pr_nrdconta
         AND bpr.tpctrpro = 90
         AND bpr.nrctrpro = pr_nrctremp
         AND bpr.flgalien = 1
         AND bpr.dschassi = pr_dschassi
         AND fn_valida_categoria_alienavel(bpr.dscatbem) = 'S';
    vr_tem_refin NUMBER(1);
    vr_flaborta VARCHAR2(1);
    vr_flgobrig VARCHAR2(1);
    
    -- Criar tabela de memória para armazenar os diferentes tipos de XML, onde:
    -- 1 - Desalienações de Mesmo Veículo
    -- 2 - Desalienações de Veículos Diferentes
    -- 3 - Alienações de Mesmos Veículos
    -- 4 - Alienações de Novos Veículos
    TYPE typ_tab_xml IS
      TABLE OF VARCHAR2(32767) INDEX BY VARCHAR2(35);
    vr_tab_xml_01 typ_tab_xml;
    vr_tab_xml_02 typ_tab_xml;
    vr_tab_xml_03 typ_tab_xml;
    vr_tab_xml_04 typ_tab_xml;
    vr_idx_xml VARCHAR2(35);
    
  BEGIN

    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
    
	  --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_prepara_alienacao_atenda');

    -- Inicializar as informações do XML de dados
    dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_clobxml,dbms_lob.lob_readwrite);

    -- Escrever no arquivo XML
    gene0002.pc_escreve_xml(vr_clobxml
                           ,vr_clobaux
                           ,'<?xml version="1.0" encoding="UTF-8"?><Root>');
    
    
    -- Verifica a linha de credito
    OPEN cr_craplcr(vr_cdcooper,pr_nrdconta,pr_nrctremp);
    FETCH cr_craplcr
     INTO rw_craplcr;
    CLOSE cr_craplcr;
    IF rw_craplcr.tpctrato = 2 THEN
      
      -- Valida se eh alienacao fiduciaria
      pc_valida_alienacao_fiduciaria( pr_cdcooper => vr_cdcooper   -- Código da cooperativa
                                     ,pr_nrdconta => pr_nrdconta   -- Numero da conta do associado
                                     ,pr_nrctrpro => pr_nrctremp   -- Numero do contrato
                                     ,pr_flgcompl => 'S'           -- Busca completa
                                     ,pr_des_reto => vr_des_reto   -- Retorno Ok ou NOK do procedimento
                                     ,pr_vet_dados => vr_vet_dados -- Vetor com dados para auxiliar alienação
                                     ,pr_dscritic => vr_dscritic); -- Retorno da descricao da critica do erro
      /** OBS: Sempre retornara OK pois a chamada da valida_bens_alienados
              vem da "EFETIVAR" (LANCTRI e BO00084), nesses casos nao pode
              impedir de seguir para demais contratos. **/
      -- Se ocorreu erro
      vr_dscritic := NULL;

      -- Caso houver Gravames Online e sem Portabilidade
      IF grvm0001.fn_tem_gravame_online(vr_cdcooper) = 'S' and empr0001.fn_tipo_finalidade(vr_cdcooper,vr_vet_dados.cdfinemp) <> 2 THEN
      
        -- Buscar operador
        OPEN cr_crapope(vr_cdcooper,vr_cdoperad);
        FETCH cr_crapope INTO rw_crapope;
        CLOSE cr_crapope;
        
        -- Verificar lista de contratos a liquidar
        IF vr_vet_dados.vtctrliq is not NULL AND vr_vet_dados.vtctrliq.count() > 0 THEN
          -- Varrer todos os contratos a liquidar
          FOR idx IN vr_vet_dados.vtctrliq.first..vr_vet_dados.vtctrliq.last LOOP
            -- Se tem contrato
            IF vr_vet_dados.vtctrliq(idx) <> '0' THEN
              -- Buscar bens alienados dos contratos liquidados
              FOR rw_bpr IN cr_crapbpr(vr_cdcooper,vr_vet_dados.vtctrliq(idx),1) LOOP
                -- Para cada bem encontrado, vamos checar suas situações
                -- e somente solicitar baixa caso a situação seja:
                -- 0 - Nao enviados
                -- 2 - Alienado
                -- 3 - Processado com critica
                IF rw_bpr.cdsitgrv IN(0,2,3) THEN
                  -- Default é as informações do cooperado
                  vr_nmprimtl := vr_vet_dados.nmprimtl;
                  vr_nrcpfbem := vr_vet_dados.nrcpfemi;
                  /* Procedimento para busca do emitente (Inverveniente, se houver) */
                  pc_busca_emitente(pr_cdcooper => vr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctremp => vr_vet_dados.vtctrliq(idx)
                                   ,pr_nrcpfbem => rw_bpr.nrcpfbem
                                   ,pr_nrcpfemi => vr_nrcpfbem
                                   ,pr_nmprimtl => vr_nmprimtl); 
                  -- Cursor para testar se o Chassi enviado está na lista de bens alienáveis do contrato em efetivação
                  vr_tem_refin := 0;
                  OPEN cr_bprrefin(vr_cdcooper,rw_bpr.dschassi);
                  FETCH cr_bprrefin
                   INTO vr_tem_refin;
                  CLOSE cr_bprrefin; 
                  -- Se tem refin do mesmo chassi
                  IF vr_tem_refin = 1 THEN
                    -- É obrigatório e Abortamos em caso de erro 
                    vr_flaborta := 'S';
                    vr_flgobrig := 'S';
                  ELSE
                    -- Não é obrigatório e não Abortamos em caso de erro 
                    vr_flaborta := 'N';
                    vr_flgobrig := 'N';
                  END IF;
                  -- Montagem das informações para desalienação do bem anterior
                  pc_gera_xml_desalienacao(pr_cdcooper => vr_cdcooper     -- Cod. Cooperativa
                                          ,pr_nrdconta => pr_nrdconta     -- Nr. da conta
                                          ,pr_tpctrato => 90              -- Tp. contrato
                                          ,pr_nrctrpro => rw_bpr.nrctrpro -- Nr. contrato
                                          ,pr_idseqbem => rw_bpr.idseqbem -- Sequencial do bem
                                          ,pr_tpdesali => 'B'             -- Tipo [C]ancelamento ou [B]aixa
                                          ,pr_flaborta => vr_flaborta     -- Flag S/N se a operação aborta outras na sequencia em caso de erro
                                          ,pr_flgobrig => vr_flgobrig     -- Flag S/N se a desalienação é obrigatória para prosseguir                                     
                                           /* SistemaNacionalGravames */
                                          ,pr_uflicenc => rw_bpr.uflicenc       -- UF                                 
                                          /* ObjetoContratoCredito */
                                          ,pr_dschassi => rw_bpr.dschassi       -- Chassi
                                          ,pr_tpchassi => rw_bpr.tpchassi       -- Tipo Chassi
                                          ,pr_nrrenava => rw_bpr.nrrenava       -- Renavam
                                          /* Emitente */
                                          ,pr_nrcpfemi => vr_nrcpfbem           -- CPF/CNPJ Emitente                                 
                                          /* Saida */
                                          ,pr_xmldesal => vr_dsxmltemp          -- XML do Cancelamento de alienação
                                          ,pr_dscritic => vr_dscritic);         -- Descrição de critica encontrada
                  -- Em caso de erro
                  IF vr_dscritic IS NOT NULL THEN
                    RAISE vr_exc_erro;
                  END IF;
                  
                  -- Caso seja refin
                  IF vr_tem_refin = 1 THEN
                    -- Enviar para a lista 01 - Desalienações de Mesmos Veículos
                    vr_tab_xml_01(rw_bpr.dschassi) := vr_dsxmltemp;
                  ELSE
                    -- Enviar para a lista 02 - Desalienações de Veículos Diferentes
                    vr_tab_xml_02(rw_bpr.dschassi) := vr_dsxmltemp;
                  END IF;
                END IF;
              END LOOP;
            END IF;
          END LOOP;
        END IF;
        
        -- Tratar mensagem de desalienação de mesmo veículo
        IF vr_tab_xml_01.count() = 1 THEN
          vr_dsmensag := gene0007.fn_convert_web_db('O veiculo antigo sera automaticamente baixado do contrato antigo e alienado no novo contrato. Foi verificado se este veiculo nao possui restricoes para alienacao?');    
        ELSIF vr_tab_xml_01.count() > 1 THEN
          vr_dsmensag := gene0007.fn_convert_web_db('Os veiculos antigos serao automaticamente baixados do contrato antigo e alienado no novo contrato. Foi verificado se estes veiculos não possuem restricoes para alienacao?');    
        END IF;  
        
        -- Buscar todos os bens do emprestimos em efetivação
        FOR rw_bpr IN cr_crapbpr(vr_cdcooper,pr_nrctremp,0) LOOP
          -- Para cada bem encontrado, vamos checar suas situações
          -- e somente solicitar alienação caso a situação seja:
          -- 0 - Nao enviados
          -- 1 - Em processamento
          -- 3 - Processado com critica
          IF rw_bpr.cdsitgrv IN(0,1,3) THEN
            -- Default é as informações do cooperado
            vr_nmprimtl := vr_vet_dados.nmprimtl;
            vr_nrcpfbem := vr_vet_dados.nrcpfemi;
            /* Procedimento para busca do emitente (Inverveniente, se houver) */
            pc_busca_emitente(pr_cdcooper => vr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctremp => pr_nrctremp
                             ,pr_nrcpfbem => rw_bpr.nrcpfbem
                             ,pr_nrcpfemi => vr_nrcpfbem
                             ,pr_nmprimtl => vr_nmprimtl);            
            -- Inclusão
            pc_gera_xml_alienacao(pr_cdcooper => vr_cdcooper -- Cod. Cooperativa
                                 ,pr_nrdconta => pr_nrdconta -- Nr. da conta
                                 ,pr_tpctrato => 90          -- Tp. contrato
                                 ,pr_nrctrpro => pr_nrctremp -- Nr. contrato
                                 ,pr_idseqbem => rw_bpr.idseqbem -- Sequencial do bem
                                 ,pr_flaborta => 'N'             -- Flag S/N se a operação aborta outras na sequencia em caso de erro
                                 ,pr_flgobrig => 'S'             -- Flag S/N se a operação é obrigatória para prosseguir para próximo fluxo
                                 /* SistemaNacionalGravames */
                                 ,pr_uflicenc => rw_bpr.uflicenc -- UF de Licenciamento
                                 ,pr_tpaliena => '03'            -- Tipo da Alienação
                                 ,pr_dtlibera => vr_vet_dados.dtlibera -- Data da Liberação
                                 /* ObjetoContratoCredito */
                                 ,pr_dschassi => rw_bpr.dschassi -- Chassi
                                 ,pr_tpchassi => rw_bpr.tpchassi -- Tipo Chassi
                                 ,pr_ufdplaca => rw_bpr.ufdplaca -- UF
                                 ,pr_nrdplaca => rw_bpr.nrdplaca -- PLaca
                                 ,pr_nrrenava => rw_bpr.nrrenava -- Renavam
                                 ,pr_nranobem => rw_bpr.nranobem -- Ano Fabricacao
                                 ,pr_nrmodbem => rw_bpr.nrmodbem -- Ano modelo                               
                                 /* propostaContratoCredito */
                                 ,pr_nrctremp => pr_nrctremp           -- Contrato
                                 ,pr_dtmvtolt => vr_vet_dados.dtmvtolt -- Data digitação
                                 ,pr_qtpreemp => vr_vet_dados.qtpreemp -- Quantidade parcelas
                                 ,pr_permulta => vr_vet_dados.permulta -- Percentual de Multa
                                 ,pr_txmensal => vr_vet_dados.txmensal -- Taxa mensal
                                 ,pr_vlemprst => vr_vet_dados.vlemprst -- Valor Empréstimo
                                 ,pr_tpemprst => vr_vet_dados.tpemprst -- Tipo Emprestimo
                                 ,pr_dtdpagto => vr_vet_dados.dtdpagto -- Data da primeira parcela
                                 ,pr_dtpagfim => vr_vet_dados.dtvencto -- Data da ultima parcela
                                 /* Emitente */
                                 ,pr_nrcpfemi => vr_nrcpfbem           -- CPF/CNPJ Emitente
                                 ,pr_nmemiten => vr_nmprimtl           -- Nome/Razão Social Emitente
                                 ,pr_dsendere => vr_vet_dados.dsendere -- Logradouro Emitente
                                 ,pr_nrendere => vr_vet_dados.nrendere -- Numero Emitente
                                 ,pr_nmbairro => vr_vet_dados.nmbairro -- Nome Bairro Emitente
                                 ,pr_cdufende => vr_vet_dados.cdufende -- UF Emitente
                                 ,pr_nrcepend => vr_vet_dados.nrcepend -- CEP Emitente
                                 ,pr_cdcidade => vr_vet_dados.cdcidcli -- Cidade
                                 ,pr_nrdddtfc => vr_vet_dados.nrdddass -- DDD Emitente
                                 ,pr_nrtelefo => vr_vet_dados.nrtelass -- Telefone Emitente
                                  /* Credor Eh a Coop */
                                 ,pr_nmcddopa => GENE0007.fn_caract_acento(rw_crapope.nmcidade,1) -- Nome da cidade do PA
                                 ,pr_cdufdopa => rw_crapope.cdufdcop    -- UF do PA
                                 ,pr_inpescre => 2                      -- Tipo pessoa Credor
                                 ,pr_nrcpfcre => vr_vet_dados.nrdocnpj  -- CPF/CNPJ Credor
                                 ,pr_dsendcre => GENE0007.fn_caract_acento(vr_vet_dados.dsendcre) -- Logradouro Credor
                                 ,pr_nrendcre => vr_vet_dados.nrendcre -- Numero Credor
                                 ,pr_nmbaicre => GENE0007.fn_caract_acento(vr_vet_dados.nmbaicre,1) -- Nome Bairro Credor
                                 ,pr_cdufecre => vr_vet_dados.cdufecre -- UF Credor
                                 ,pr_cdcidcre => vr_vet_dados.cdcidcre     -- Cidade Credor
                                 ,pr_nrcepcre => vr_vet_dados.nrcepcre -- CEP Credor
                                 ,pr_nrdddcre => vr_vet_dados.nrdddenc  -- DDD Credor
                                 ,pr_nrtelcre => vr_vet_dados.nrtelenc  -- Telefone Credor
                                 /* Dados do Vendedor */
                                 ,pr_nrcpfven => 0 /*crapass.nrcpfcgc*/ -- CPF/CNPJ Vendedor
                                 /* Recebedor do pagamento */
                                 ,pr_inpesrec => 2                      -- Tipo Pessoa Recebedor (Cooperativa)
                                 ,pr_nrcpfrec => vr_vet_dados.nrdocnpj  -- CPF/CNPJ Vendedor
                                 /* Saida */
                                 ,pr_xmlalien => vr_dsxmltemp  -- XML da alienação
                                 ,pr_dscritic => vr_dscritic); -- Descrição de critica encontrada
            -- Em caso de erro
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;       
            
            -- Caso o veículo em alienação já existe em contrato refinanciado
            IF vr_tab_xml_01.exists(rw_bpr.dschassi) THEN
              -- Enviar na lista de Alienações de Mesmos Veículos
              vr_tab_xml_03(rw_bpr.dschassi) := vr_dsxmltemp;
            ELSE
              -- Enviar na lista de Alienações de Novos Veículos
              vr_tab_xml_04(rw_bpr.dschassi) := vr_dsxmltemp;                        
            END IF;
                 
          ELSE
            -- Se encontramos algum bem com situação Em processamento, Baixado ou Cancelado
            IF rw_bpr.cdsitgrv IN(1,4,5) THEN
              -- Gerar critica
              vr_dscritic := 'Chassi '||rw_bpr.dschassi||' com situacao invalida! Nao sera possivel efetivar a proposta!';
              RAISE vr_exc_erro;
            END IF;
          END IF;                         
        END LOOP;
        
        -- Adicionar ao XML a tag raiz as mensagens, aprovação e raiz das alienações
        gene0002.pc_escreve_xml(vr_clobxml
                               ,vr_clobaux
                               , '<mensagem>'||vr_dsmensag||'</mensagem>');
        
        -- Primeiro vamos alienar somente os veículos novos
        IF vr_tab_xml_04.count() > 0 THEN
          -- Enviar grupo Alienações Novas
          gene0002.pc_escreve_xml(vr_clobxml
                                 ,vr_clobaux
                                 ,'<gravameB3 nomgrupo="Alienacao de novos veiculos" flgobrig="S">');
          vr_idx_xml := vr_tab_xml_04.first;
          LOOP
            EXIT WHEN vr_idx_xml IS NULL;
            -- Enviar o mesmo ao CLOB
            gene0002.pc_escreve_xml(vr_clobxml
                                     ,vr_clobaux
                                     ,vr_tab_xml_04(vr_idx_xml)); 
            -- Buscar o próximo
            vr_idx_xml := vr_tab_xml_04.next(vr_idx_xml);
          END LOOP;
          -- Finalizar grupo Alienações Novas
          gene0002.pc_escreve_xml(vr_clobxml
                                 ,vr_clobaux
                                 ,'</gravameB3>');
        END IF;  
        
        -- Depois vamos enviar desalienações de mesmos veículos
        IF vr_tab_xml_01.count() > 0 THEN
          -- Enviar grupo Alienações Novas
          gene0002.pc_escreve_xml(vr_clobxml
                                 ,vr_clobaux
                                 ,'<gravameB3 nomgrupo="Baixa de veiculos refinanciados" flgobrig="S">');
          vr_idx_xml := vr_tab_xml_01.first;
          LOOP
            EXIT WHEN vr_idx_xml IS NULL;
            -- Enviar o mesmo ao CLOB
            gene0002.pc_escreve_xml(vr_clobxml
                                     ,vr_clobaux
                                     ,vr_tab_xml_01(vr_idx_xml)); 
            -- Buscar o próximo
            vr_idx_xml := vr_tab_xml_01.next(vr_idx_xml);
          END LOOP;
          -- Finalizar grupo Desalienações mesmos veículos
          gene0002.pc_escreve_xml(vr_clobxml
                                 ,vr_clobaux
                                 ,'</gravameB3>');
        END IF;             
        
        -- Depois vamos alienar mesmos veículos
        IF vr_tab_xml_03.count() > 0 THEN
          -- Enviar grupo Alienações Novas
          gene0002.pc_escreve_xml(vr_clobxml
                                 ,vr_clobaux
                                 ,'<gravameB3 nomgrupo="Alienacao de veiculos refianciados" flgobrig="S">');
          vr_idx_xml := vr_tab_xml_03.first;
          LOOP
            EXIT WHEN vr_idx_xml IS NULL;
            -- Enviar o mesmo ao CLOB
            gene0002.pc_escreve_xml(vr_clobxml
                                     ,vr_clobaux
                                     ,vr_tab_xml_03(vr_idx_xml)); 
            -- Buscar o próximo
            vr_idx_xml := vr_tab_xml_03.next(vr_idx_xml);
          END LOOP;
          -- Finalizar grupo Alienações Refin
          gene0002.pc_escreve_xml(vr_clobxml
                                 ,vr_clobaux
                                 ,'</gravameB3>');
        END IF;    
         
        -- Por fim, vamos baixar veículos diferentes
        IF vr_tab_xml_02.count() > 0 THEN
          -- Enviar grupo Alienações Novas
          gene0002.pc_escreve_xml(vr_clobxml
                                 ,vr_clobaux
                                 ,'<gravameB3 nomgrupo="Baixa de veiculos antigos" flgobrig="S">');
          vr_idx_xml := vr_tab_xml_02.first;
          LOOP
            EXIT WHEN vr_idx_xml IS NULL;
            -- Enviar o mesmo ao CLOB
            gene0002.pc_escreve_xml(vr_clobxml
                                     ,vr_clobaux
                                     ,vr_tab_xml_02(vr_idx_xml)); 
            -- Buscar o próximo
            vr_idx_xml := vr_tab_xml_02.next(vr_idx_xml);
          END LOOP;
          -- Finalizar grupo Desalienações 
          gene0002.pc_escreve_xml(vr_clobxml
                                 ,vr_clobaux
                                 ,'</gravameB3>');
        END IF;               
                      
      END IF; 
    END IF;
    
    -- Finalizar o XML
    gene0002.pc_escreve_xml(vr_clobxml
                           ,vr_clobaux
                           ,'</Root>'
                           ,TRUE);      
    -- E converter o CLOB para o XMLType de retorno
    pr_retxml := xmltype.createXML(vr_clobxml);
    --Fechar Clob e Liberar Memoria  
    dbms_lob.close(vr_clobxml);
    dbms_lob.freetemporary(vr_clobxml);  

    -- Retorno  
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
                                     
      --Inclusão dos parâmetros apenas na exception, para não mostrar na tela - Chamado 660356
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Mensagem
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ALERTA: '|| pr_dscritic ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||',Nrctrpro:'||pr_nrctremp);
      -- Desfazer alterações
      ROLLBACK;                                     
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_prepara_alienacao_atenda --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      
      -- Gera log
      --Inclusão dos parâmetros apenas na exception, para não mostrar na tela
      --Padronização - Chamado 660394
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ERRO: ' || pr_dscritic  ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||',Nrctrpro:'||pr_nrctremp);

      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
      -- Desfazer alterações
      ROLLBACK;
  END pc_prepara_alienacao_atenda;
    
  
  procedure pc_alerta_gravam_sem_efetiva is
  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_alerta_gravam_sem_efetiva
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Daniel - Envolti
    Data     : Setembro/2018                         Ultima atualizacao: 18/09/2018
    
     Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Gerar e enviar e-mail informando que existem propostas com veículos alienados não efetivadas.

    Alterações : xx/xx/xxxx - 
                              
    -------------------------------------------------------------------------------------------------------------*/    

    vr_idprglog   number;
                              
    -- Busca cooperativas, data de movimento e parâmetros
    cursor cr_crapcop is
      select cop.cdcooper,
             cop.nmrescop,
             dat.dtmvtolt,
             gene0001.fn_param_sistema('CRED', cop.cdcooper, 'GRAVAM_DIA_AVISO_NAO_EFT') qtdias,
             gene0001.fn_param_sistema('CRED', cop.cdcooper, 'GRAVAM_MAIL_AVIS_NAO_EFT') dsmail
        from crapcop cop,
             crapdat dat
       where dat.cdcooper = cop.cdcooper;
                              
    -- Busca propostas aprovadas mas não efetivadas, e que tenham gravames
    cursor cr_crawepr (pr_cdcooper in crawepr.cdcooper%type,
                       pr_dtmvtolt in crawepr.dtaprova%type,
                       pr_qtdias in number) is
      select epr.nrdconta,
             epr.nrctremp,
             epr.vlemprst,
             bpr.dtatugrv,
             pr_dtmvtolt - bpr.dtatugrv nrdias,
             bpr.vlmerbem,
             decode(bpr.dsmarbem,
                    null, bpr.dsbemfin,
                    bpr.dsmarbem||'/'||bpr.dsbemfin) dsbemfin,
             bpr.idseqbem
        from crawepr epr,
             crapbpr bpr
       where epr.cdcooper = pr_cdcooper
         and not exists (select 1
                           from crapepr epr2
                          where epr2.cdcooper = epr.cdcooper
                            and epr2.nrdconta = epr.nrdconta
                            and epr2.nrctremp = epr.nrctremp)
         and bpr.cdcooper = epr.cdcooper
         and bpr.nrdconta = epr.nrdconta
         and bpr.nrctrpro = epr.nrctremp
         and bpr.flgalien = 1
         and bpr.flgalfid = 1
         and bpr.flginclu = 0
         and bpr.cdsitgrv = 2
         and bpr.dtatugrv < pr_dtmvtolt - pr_qtdias
       order by bpr.dtatugrv,
                bpr.nrdconta,
                bpr.nrctrpro;
    vr_cdcooper       crapcop.cdcooper%type;
    --Variaveis de E-mail
    vr_email_assunto  varchar2(300);
    vr_email_corpo    varchar2(32767);
    -- Guardar HMTL texto
    vr_dsarqanx       varchar2(500);
    vr_dsdirarq       constant varchar2(30) := gene0001.fn_diretorio('C',1,'arq'); -- Diretório temporário para arquivos
    vr_dshmtl         clob;
    vr_dshmtl_aux     varchar2(32767);
    -- Variaveis de Erro
    vr_dscritic       varchar2(4000);
    -- Variaveis Exceção
    vr_exc_erro       exception;
  begin
    for r_crapcop in cr_crapcop loop
      if r_crapcop.qtdias is null or
         r_crapcop.dsmail is null then
        continue;
      end if;
      --
      vr_cdcooper := r_crapcop.cdcooper;
      vr_dshmtl_aux := null;
      -- Monta o cabeçalho do email
      vr_email_assunto := 'Propostas com veículos alienados e não efetivadas - ' || vr_cdcooper;
      vr_email_corpo := 'Verifique o arquivo em anexo para o detalhamento das propostas com veículos alienados e não efetivadas.<br><br>'||
                        'Obs.: O prazo para cancelamento (desistência) da alienação é de 30 dias corridos. Após este prazo, o cancelamento no Detran poderá ser realizado somente via documentação (cópias autenticadas com assinatura do cooperado) enviada à B3 em Florianópolis.';
      -- Montar o início da tabela (Num clob para evitar estouro)
      dbms_lob.createtemporary(vr_dshmtl, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_dshmtl,dbms_lob.lob_readwrite);
      gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >');
      gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<table border="1" style="width:1000px; margin: 10px auto; font-family: Tahoma,sans-serif; font-size: 12px; color: #686868;" >');
      -- Montando header
      gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<thead align="center" style="background-color: #DCDCDC;">' ||
                                                        '<td width="100px">' ||
                                                          '<b>Conta</b>' ||
                                                        '</td>' ||
                                                        '<td width="100px">' ||
                                                          '<b>Contrato</b>' ||
                                                        '</td>' ||
                                                        '<td width="120px">' ||
                                                          '<b>Valor Proposta</b>' ||
                                                        '</td>' ||
                                                        '<td width="120px">' ||
                                                          '<b>Data Alienação</b>' ||
                                                        '</td>' ||
                                                        '<td width="80px">' ||
                                                          '<b>Dias</b>' ||
                                                        '</td>' ||
                                                        '<td width="120px">' ||
                                                          '<b>Valor Bem</b>' ||
                                                        '</td>' ||
                                                        '<td width="250px">' ||
                                                          '<b>Descrição Bem</b>' ||
                                                        '</td>' ||
                                                      '</thead>' ||
                                                      '<tbody align="center" style="background-color: #F0F0F0;">');
      vr_dsarqanx := null;
      for r_crawepr in cr_crawepr (vr_cdcooper,
                                   r_crapcop.dtmvtolt,
                                   r_crapcop.qtdias) loop
        -- Inclui a proposta no arquivo
        vr_dsarqanx := r_crapcop.nmrescop||'_'||to_char(r_crapcop.dtmvtolt, 'ddmmyyyy')||'.html';
        gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<tr>' ||
                                                          '<td>' ||
                                                            gene0002.fn_mask_conta(r_crawepr.nrdconta) ||
                                                          '</td>' ||
                                                          '<td>' ||
                                                            r_crawepr.nrctremp ||
                                                          '</td>' ||
                                                          '<td>' ||
                                                            'R$ ' || to_char(r_crawepr.vlemprst, 'fm9g999g999g999g999g990d00') ||
                                                          '</td>' ||
                                                          '<td>' ||
                                                            to_char(r_crawepr.dtatugrv, 'dd/mm/yyyy') ||
                                                          '</td>' ||
                                                          '<td>' ||
                                                            r_crawepr.nrdias ||
                                                          '</td>' ||
                                                          '<td>' ||
                                                            'R$ ' || to_char(r_crawepr.vlmerbem, 'fm9g999g999g999g999g990d00') ||
                                                          '</td>' ||
                                                          '<td>' ||
                                                            r_crawepr.dsbemfin ||
                                                          '</td>' ||
                                                        '</tr>');
      end loop;
      -- Somente se encontrou alguma proposta
      if vr_dsarqanx is not null then
        -- Encerrar o texto e o clob
        gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'</tbody></table>');
        gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'',true);
        -- Gerar o arquivo na pasta converte
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_dshmtl,
                                      pr_caminho  => vr_dsdirarq,
                                      pr_arquivo  => vr_dsarqanx,
                                      pr_des_erro => vr_dscritic);
        -- Envia o e-mail
        gene0003.pc_solicita_email(pr_cdcooper        => vr_cdcooper,
                                   pr_cdprogra        => 'GRVM0001',
                                   pr_des_destino     => r_crapcop.dsmail,
                                   pr_des_assunto     => vr_email_assunto,
                                   pr_des_corpo       => vr_email_corpo,
                                   pr_des_anexo       => vr_dsdirarq||'/'||vr_dsarqanx,
                                   pr_flg_remove_anex => 'S',  --> Remover os anexos passados
                                   pr_flg_remete_coop => 'S',  --> Se o envio sera do e-mail da Cooperativa
                                   pr_flg_enviar      => 'S',  --> Enviar o e-mail na hora
                                   pr_des_erro        => vr_dscritic);
        if vr_dscritic is not null  then
          vr_dscritic := to_char(sysdate,'dd/mm/rrrr hh24:mi:ss') || ' - GRVM0001 --> Erro na rotina pc_alerta_gravam_sem_efetiva: ' || vr_dscritic;
          raise vr_exc_erro;
        end if;
      end if;
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_dshmtl);
      dbms_lob.freetemporary(vr_dshmtl);
    end loop;
    -- Efetua Commit
    commit;
  exception
    when vr_exc_erro then
      -- Desfazer a operacao
      rollback;
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_dshmtl);
      dbms_lob.freetemporary(vr_dshmtl);
      -- envia ao LOG o problema ocorrido
      cecred.pc_log_programa(pr_dstiplog => 'O',
                             pr_cdprograma => 'GRVM0001',
                             pr_cdcooper => vr_cdcooper,
                             pr_tpexecucao => 0,
                             pr_tpocorrencia => 1,
                             pr_dsmensagem => vr_dscritic,
                             pr_idprglog => vr_idprglog);
    when others then
      -- Desfazer a operacao
      rollback;
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_dshmtl);
      dbms_lob.freetemporary(vr_dshmtl);

      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper);

      -- envia ao LOG o problema ocorrido
      cecred.pc_log_programa(pr_dstiplog => 'O',
                             pr_cdprograma => 'GRVM0001',
                             pr_cdcooper => vr_cdcooper,
                             pr_tpexecucao => 0,
                             pr_tpocorrencia => 1,
                             pr_dsmensagem => to_char(sysdate,'dd/mm/rrrr hh24:mi:ss') || ' - GRVM0001 --> Erro na rotina pc_alerta_gravam_sem_efetiva: ' || sqlerrm,
                             pr_idprglog => vr_idprglog);
      
  end;
        
  -- Buscar Situação Gravames do Bem repassado
  PROCEDURE pc_situac_gravame_bem(pr_cdcooper in crapbpr.cdcooper%TYPE
                                 ,pr_nrdconta in crapbpr.nrdconta%TYPE
                                 ,pr_nrctrpro in crapbpr.nrctrpro%TYPE
                                 ,pr_idseqbem in crapbpr.idseqbem%TYPE
                                 ,pr_dssituac OUT VARCHAR2
                                 ,pr_dscritic OUT VARCHAR2) IS 
    /*---------------------------------------------------------------------------------------------------------------
      
    Programa : pc_situac_gravame_bem             
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Marcos Martini - Envolti
    Data     : Setembro/2018                           Ultima atualizacao:  
    
    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Função para buscar situação gravames bem enviado
      
    Alterações :  
      
  ---------------------------------------------------------------------------------------------------------------*/                                    
    cursor cr_crapbpr is
      select bpr.cdsitgrv
            ,bpr.dsjstinc
            ,bpr.dsjstbxa
            ,bpr.dsjuscnc
        from crapbpr bpr
       where bpr.cdcooper = pr_cdcooper
         and bpr.nrdconta = pr_nrdconta
         and bpr.tpctrpro IN(90,99) -- Pode ser bem ativo ou substituido
         and bpr.nrctrpro = pr_nrctrpro
         and bpr.idseqbem = pr_idseqbem;
    rw_crapbpr cr_crapbpr%ROWTYPE;
    BEGIN
    -- Busca do bem
    open cr_crapbpr;
    fetch cr_crapbpr into rw_crapbpr;
    close cr_crapbpr;
    -- 
    IF rw_crapbpr.cdsitgrv = 0 THEN
      pr_dssituac := 'Nao enviado';
    ELSIF rw_crapbpr.cdsitgrv = 1 THEN
      pr_dssituac := 'Em processamento';
    ELSIF rw_crapbpr.cdsitgrv =  2 THEN
      pr_dssituac := 'Alienacao';
    ELSIF rw_crapbpr.cdsitgrv =  3 THEN
      pr_dssituac := 'Processado c/ Critica';
    ELSIF rw_crapbpr.cdsitgrv =  4 THEN
      pr_dssituac := 'Baixado';
    ELSIF rw_crapbpr.cdsitgrv =  5 THEN
      pr_dssituac := 'Cancelado';
    ELSE 
      pr_dssituac := 'Nao enviado';  
      END IF;
    -- Removido, conforme solicitação do Télvio
    -- Se já houve Inclusão, Baixa ou Cancelamento manual
    /*IF trim(rw_crapbpr.dsjstinc) IS NOT NULL OR trim(rw_crapbpr.dsjstbxa) IS NOT NULL OR trim(rw_crapbpr.dsjuscnc) IS NOT NULL THEN
      -- Incluir * que indica que houve interação Manual no contrato
      pr_dssituac := pr_dssituac || ' ***';
    END IF;*/
  exception
    when others then
      pr_dscritic := 'Erro na busca da situacao Gravame - '||SQLERRM;  
  END;  
        
          
  -- Efetuar o registro do Gravames
  PROCEDURE pc_registrar_gravames(pr_cdcooper IN crapcop.cdcooper%TYPE -- Numero da cooperativa
                                 ,pr_nrdconta IN crapcop.nrdconta%TYPE -- Numero da conta do associado
                                 ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Numero do contrato                               
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                 ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
  /* .............................................................................
        
   Procedure: pc_registrar_gravames             Antigo: fontes/b1wgen0171.p - registrar_gravames
   Sistema : Conta-Corrente - Cooperativa de Crédito
   Sigla   : CRED
   Autor   : Renato Raul Cordeiro (AMcom)
   Data    : Abril/2018.                     Ultima atualização: 19/10/2018
          
   --HISTÓRICO ORACLE--
          23/04/2018 - Migrado rotina/fonte progress para oracle.
                       Renato Raul Cordeiro (AMcom)
       
          19/10/2018 - P442 - Troca de checagem fixa por funcão para garantir se bem é alienável (Marcos-Envolti)
         
  ............................................................................... */
          
    DECLARE
      
      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Erro para parar a cadeia
      vr_exc_saida exception;
      
      -------------- Cursores específicos ----------------

      -- Busca sobre data de inclusão do contrato --
      CURSOR cr_crawepr IS
        SELECT crawepr.flgokgrv
              ,crawepr.rowid
          FROM crawepr
         WHERE crawepr.cdcooper = pr_cdcooper
           AND crawepr.nrdconta = pr_nrdconta
           AND crawepr.nrctremp = pr_nrctrpro;
      rw_crawepr cr_crawepr%ROWTYPE;
          
      -------------- Variáveis e Tipos -------------------
                              
      vr_cdcritic crapcri.cdcritic%TYPE; --> Código da crítica
      vr_dscritic     VARCHAR2(2000);    --> Descrição da crítica
          
      -- Variaveis locais para retorno de erro
      vr_des_reto varchar2(4000);

      -- Vetor com dados auxiliares para alienação B3
      vr_vet_dados typ_reg_dados;
      
      
    BEGIN
       
      -- Código do programa
      vr_cdprogra := 'GRVM0001';
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pr_registrar_gravames'
                                ,pr_action => null);
                                
      -- Valida se eh alienacao fiduciaria
      pc_valida_alienacao_fiduciaria( pr_cdcooper => pr_cdcooper   -- Código da cooperativa
                                     ,pr_nrdconta => pr_nrdconta   -- Numero da conta do associado
                                     ,pr_nrctrpro => pr_nrctrpro   -- Numero do contrato
                                     ,pr_des_reto => vr_des_reto   -- Retorno Ok ou NOK do procedimento
                                     ,pr_vet_dados => vr_vet_dados -- Vetor com dados para auxiliar alienação
                                     ,pr_dscritic => vr_dscritic); -- Retorno da descricao da critica do erro
      /** OBS: Sempre retornara OK pois a chamada da solicita_baixa_automatica
               nos CRPS171,CRPS078,CRPS120_1,B1WGEN0136, nesses casos nao pode
               impedir de seguir para demais contratos. **/
       
      IF vr_des_reto <> 'OK' THEN
        vr_cdcritic := 0;
         -- Não é necessário atribuir a variável vr_dscritic porque já retorna da procedure 
         -- chamada imediatamente acima
         RAISE vr_exc_saida;
      END IF;   
      
      /** Apenas retornar dados do contrato, a validação de existencia já eh feita acima **/
      open cr_crawepr;
      fetch cr_crawepr into rw_crawepr;
      CLOSE cr_crawepr;

      -- Caso Gravames Online
      IF grvm0001.fn_tem_gravame_online(pr_cdcooper) = 'S' THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Cooperativa com comunicacao GRAVAMES Online - Opcao desativada!';
        RAISE vr_exc_saida;
        END IF;
        
      -- Checar se já não está OK
      if nvl(rw_crawepr.flgokgrv,0) = 1 then
         vr_cdcritic := 0;
         vr_dscritic := ' Proposta ja OK para envio ao GRAVAMES! ';
         RAISE vr_exc_saida;
      end if;
              
      -- Setar GRV OK na tabela da proposta
      begin
        update crawepr set flgokgrv = 1 where rowid = rw_crawepr.rowid;
      exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := substr(' Erro atualização crawepr:'||SQLERRM,1,2000);
          RAISE vr_exc_saida;
      end;
                           
      -- Marcar todos os bens não alienados como pendentes de Gravames
      begin
        update crapbpr a
           set a.flginclu = 1,
               a.cdsitgrv = 0,
               a.tpinclus = 'A'
         where a.cdcooper = pr_cdcooper
           and a.nrdconta = pr_nrdconta
           and a.tpctrpro = 90
           and a.nrctrpro = pr_nrctrpro
           and a.flgalien = 1
           AND a.cdsitgrv <> 2
           and grvm0001.fn_valida_categoria_alienavel(a.dscatbem) = 'S';
      exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := substr(' Erro atualização crapbpr:'||SQLERRM,1,2000);
          RAISE vr_exc_saida;
      end;
                
                EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
                    
        -- Enviar ao log
                    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro
                                              ,pr_nmarqlog     => 'gravam.log'
                                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                                  ' - '||vr_cdprogra||' --> '|| 
                                                      'ERRO [registrar_gravames]: '|| pr_cdcritic || ' - ' || pr_dscritic ||
                                                      ',Cdcooper:'||pr_cdcooper||',Nrdconta:'||pr_nrdconta||',Nrctrpro:'||pr_nrctrpro);
                  
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
                  
        -- Enviar ao log
                  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 3 -- Erro nao tratado
                                            ,pr_nmarqlog     => 'gravam.log'
                                            ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                                ' - '||vr_cdprogra||' --> '|| 
                                                      'ERRO [registrar_gravames]: '|| pr_cdcritic || ' - ' || pr_dscritic ||
                                                      ',Cdcooper:'||pr_cdcooper||',Nrdconta:'||pr_nrdconta||',Nrctrpro:'||pr_nrctrpro);        
                  
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_registrar_gravames;
                  
  -- Efetuar o registro de Baixa de Refin 
  PROCEDURE pc_registrar_baixa_refin(pr_cdcooper IN crapcop.cdcooper%TYPE -- Numero da cooperativa
                                    ,pr_nrdconta IN crapcop.nrdconta%TYPE -- Numero da conta do associado
                                    ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Numero do contrato                               
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                    ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
  /* .............................................................................
                  
   Procedure: pc_registrar_baixa_refin             
   Sistema : Conta-Corrente - Cooperativa de Crédito
   Sigla   : CRED
   Autor   : Marcos Martini (Envolti)
   Data    : Outubro/2018.                     Ultima atualização: 
                  
   Alterações
                  
  ............................................................................... */
                
    DECLARE
                
      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Erro para parar a cadeia
      vr_exc_saida exception;
                              
      -------------- Cursores específicos ----------------
          
      -------------- Variáveis e Tipos -------------------
          
      vr_cdcritic crapcri.cdcritic%TYPE; --> Código da crítica
      vr_dscritic     VARCHAR2(2000);    --> Descrição da crítica

      -- Variaveis locais para retorno de erro
      vr_des_reto varchar2(4000);
              
      -- Vetor com dados auxiliares para alienação B3
      vr_vet_dados typ_reg_dados;
                
                                     
                  BEGIN
                    
      -- Código do programa
      vr_cdprogra := 'GRVM0001';
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_registrar_baixa_refin'
                                ,pr_action => null);
                                       
      -- Valida se eh alienacao fiduciaria
      pc_valida_alienacao_fiduciaria( pr_cdcooper => pr_cdcooper   -- Código da cooperativa
                                     ,pr_nrdconta => pr_nrdconta   -- Numero da conta do associado
                                     ,pr_nrctrpro => pr_nrctrpro   -- Numero do contrato
                                     ,pr_flgcompl => 'S'           -- Trará contratos de Refin
                                     ,pr_des_reto => vr_des_reto   -- Retorno Ok ou NOK do procedimento
                                     ,pr_vet_dados => vr_vet_dados -- Vetor com dados para auxiliar alienação
                                     ,pr_dscritic => vr_dscritic); -- Retorno da descricao da critica do erro
      /** OBS: Sempre retornara OK pois a chamada da solicita_baixa_automatica
               nos CRPS171,CRPS078,CRPS120_1,B1WGEN0136, nesses casos nao pode
               impedir de seguir para demais contratos. **/
      IF vr_des_reto <> 'OK' THEN
                      vr_cdcritic := 0;
         -- Não é necessário atribuir a variável vr_dscritic porque já retorna da procedure 
         -- chamada imediatamente acima
         RAISE vr_exc_saida;
      END IF;
                  
      -- Verificar lista de contratos a liquidar
      IF vr_vet_dados.vtctrliq is not NULL AND vr_vet_dados.vtctrliq.count() > 0 THEN
        -- Varrer todos os contratos a liquidar
        FOR idx IN vr_vet_dados.vtctrliq.first..vr_vet_dados.vtctrliq.last LOOP
          -- Se tem contrato
          IF vr_vet_dados.vtctrliq(idx) <> '0' THEN
            -- Marcar todos os bens não alienados como pendentes de Gravames
            -- Isso é necessário pois a efetivação continua mesmo se houve erros
            -- nas baixas por Refinanciamento, e estas deverão ir no processo de lotes após
            begin
              update crapbpr a
                 set a.flgbaixa = 1
                    ,a.dtdbaixa = trunc(SYSDATE)
                    ,a.tpdbaixa = 'A'
               where a.cdcooper = pr_cdcooper
                 and a.nrdconta = pr_nrdconta
                 and a.tpctrpro = 90
                 and a.nrctrpro = vr_vet_dados.vtctrliq(idx)
                 and a.flgalien = 1
                 AND a.cdsitgrv NOT IN(4,5)
                 and grvm0001.fn_valida_categoria_alienavel(a.dscatbem) = 'S';
            exception
              when others then
                      vr_cdcritic := 0;
                vr_dscritic := substr(' Erro atualização crapbpr:'||SQLERRM,1,2000);
                RAISE vr_exc_saida;
            end;
          END IF;
                END LOOP;
              END IF;
              
                        EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
                  
        -- Enviar ao log
                             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro
                                                       ,pr_nmarqlog     => 'gravam.log'
                                                       ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                                           ' - '||vr_cdprogra||' --> '|| 
                                                      'ERRO [registrar_baixa_refin]: '|| pr_cdcritic || ' - ' || pr_dscritic ||
                                                      ',Cdcooper:'||pr_cdcooper||',Nrdconta:'||pr_nrdconta||',Nrctrpro:'||pr_nrctrpro);
                        
        -- Efetuar rollback
        ROLLBACK;
                        WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
                  
        -- Enviar ao log
                          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 3 -- Erro nao tratado
                                                    ,pr_nmarqlog     => 'gravam.log'
                                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                                        ' - '||vr_cdprogra||' --> '|| 
                                                      'ERRO [registrar_gravames]: '|| pr_cdcritic || ' - ' || pr_dscritic ||
                                                      ',Cdcooper:'||pr_cdcooper||',Nrdconta:'||pr_nrdconta||',Nrctrpro:'||pr_nrctrpro);        

        -- Efetuar rollback
        ROLLBACK;
                      END;       
  END pc_registrar_baixa_refin;
                    
  -- Montar o XML para registro do Gravames somente CDC 
  PROCEDURE pc_busca_xml_gravame_CDC(pr_cdcooper IN crapcop.cdcooper%TYPE         -- Numero da cooperativa
                                    ,pr_nrdconta IN crapcop.nrdconta%TYPE         -- Numero da conta do associado
                                    ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE         -- Numero do contrato                               
                                    ,pr_nrcpfven IN tbepr_cdc_vendedor.nrcpf%TYPE -- CPF do Vendedor
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE         -- Codigo do Operador
                                    ,pr_dsxmlali OUT XmlType                      -- XML de saida para alienação/desalienação
                                    ,pr_dscritic OUT VARCHAR2)                    -- Descricao de saida
                                     IS
                      BEGIN
  /* .............................................................................
                    
   Procedure: pc_busca_xml_gravame_CDC            
   Sistema : Conta-Corrente - Cooperativa de Crédito
   Sigla   : CRED
   Autor   : Marcos Martini (Envolti)
   Data    : Outubro/2018.                     Ultima atualização: 
                    
     Alterações 
                          
  ............................................................................... */
                        
    DECLARE
                  
      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Erro para parar a cadeia
      vr_exc_saida exception;

      -------------- Cursores específicos ----------------

      -- Buscar bens de contrato enviado
      cursor cr_crapbpr(pr_cdcooper crapepr.cdcooper%TYPE
                       ,pr_nrctremp crapepr.nrctremp%TYPE) is
        SELECT ROWID
              ,bpr.nrctrpro
              ,bpr.idseqbem
              ,bpr.dschassi
              ,bpr.tpchassi
              ,bpr.cdsitgrv
              ,upper(bpr.uflicenc) uflicenc
              ,bpr.dscatbem
              ,bpr.dstipbem
              ,bpr.dsmarbem
              ,bpr.dsbemfin
              ,bpr.nrcpfbem
              ,bpr.nranobem
              ,bpr.nrmodbem
              ,bpr.ufdplaca
              ,bpr.nrdplaca
              ,bpr.nrrenava
          from crapbpr bpr
         where bpr.cdcooper = pr_cdcooper
           and bpr.nrdconta = pr_nrdconta
           and bpr.tpctrpro = 90
           and bpr.nrctrpro = pr_nrctremp
           AND bpr.flgalien = 1; -- Somente alienados 
                  
      -------------- Variáveis e Tipos -------------------
                    
      vr_cdcritic crapcri.cdcritic%TYPE; --> Código da crítica
      vr_dscritic     VARCHAR2(2000);    --> Descrição da crítica
                          
      -- Variaveis locais para retorno de erro
      vr_des_reto varchar2(4000);
                        
      -- Vetor com dados auxiliares para alienação B3
      vr_vet_dados typ_reg_dados;
                  
      -- Varchar2 temporário
      vr_dsxmltemp VARCHAR2(32767);

      -- Temporárias para o CLOB
      vr_clobxml CLOB;                   -- CLOB para armazenamento das informações do arquivo
      vr_clobaux VARCHAR2(32767);        -- Var auxiliar para montagem do arquivo

      -- Temporario para interveniente
      vr_nmprimtl crapass.nmprimtl%TYPE; -- Nome do proprietario do bem
      vr_nrcpfbem crapass.nrcpfcgc%TYPE; -- Cpf do proprietário do bem    
                      
                    BEGIN
                          
      -- Código do programa
      vr_cdprogra := 'GRVM0001';
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pr_registrar_gravames_CDC'
                                ,pr_action => null);
                         
      -- Valida se eh alienacao fiduciaria
      pc_valida_alienacao_fiduciaria( pr_cdcooper => pr_cdcooper   -- Código da cooperativa
                                     ,pr_nrdconta => pr_nrdconta   -- Numero da conta do associado
                                     ,pr_nrctrpro => pr_nrctrpro   -- Numero do contrato
                                     ,pr_des_reto => vr_des_reto   -- Retorno Ok ou NOK do procedimento
                                     ,pr_flgcompl => 'S'           -- Busca completa
                                     ,pr_vet_dados => vr_vet_dados -- Vetor com dados para auxiliar alienação
                                     ,pr_dscritic => vr_dscritic); -- Retorno da descricao da critica do erro
      IF vr_des_reto <> 'OK' THEN
        RAISE vr_exc_saida;
                  END IF; 
                  
      --Incluir nome do módulo logado - Chamado 660394
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_prepara_alienacao_atenda');
                  
      -- Inicializar as informações do XML de dados
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml,dbms_lob.lob_readwrite);
                    
      -- Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_clobaux
                             ,'<?xml version="1.0" encoding="UTF-8"?><Root><gravameB3>');
                    
      -- Buscar operador
      OPEN cr_crapope(pr_cdcooper,pr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      CLOSE cr_crapope;
                  
      -- Buscar todos os bens do emprestimos em efetivação
      FOR rw_bpr IN cr_crapbpr(pr_cdcooper,pr_nrctrpro) LOOP
        -- Para cada bem encontrado, vamos checar suas situações
        -- e somente solicitar alienação caso a situação seja:
        -- 0 - Nao enviados
        -- 3 - Processado com critica
        IF rw_bpr.cdsitgrv IN(0,2,3) THEN
          -- Default é as informações do cooperado
          vr_nmprimtl := vr_vet_dados.nmprimtl;
          vr_nrcpfbem := vr_vet_dados.nrcpfemi;
          /* Procedimento para busca do emitente (Inverveniente, se houver) */
          pc_busca_emitente(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctrpro
                           ,pr_nrcpfbem => rw_bpr.nrcpfbem
                           ,pr_nrcpfemi => vr_nrcpfbem
                           ,pr_nmprimtl => vr_nmprimtl);            
          -- Inclusão
          pc_gera_xml_alienacao(pr_cdcooper => pr_cdcooper -- Cod. Cooperativa
                               ,pr_nrdconta => pr_nrdconta -- Nr. da conta
                               ,pr_tpctrato => 90          -- Tp. contrato
                               ,pr_nrctrpro => pr_nrctrpro -- Nr. contrato
                               ,pr_idseqbem => rw_bpr.idseqbem -- Sequencial do bem
                               ,pr_flaborta => 'N'             -- Flag S/N se a operação aborta outras na sequencia em caso de erro
                               ,pr_flgobrig => 'S'             -- Flag S/N se a operação é obrigatória para prosseguir para próximo fluxo
                               /* SistemaNacionalGravames */
                               ,pr_uflicenc => rw_bpr.uflicenc -- UF de Licenciamento
                               ,pr_tpaliena => '03'            -- Tipo da Alienação
                               ,pr_dtlibera => vr_vet_dados.dtlibera -- Data da Liberação
                               /* ObjetoContratoCredito */
                               ,pr_dschassi => rw_bpr.dschassi -- Chassi
                               ,pr_tpchassi => rw_bpr.tpchassi -- Tipo Chassi
                               ,pr_ufdplaca => rw_bpr.ufdplaca -- UF
                               ,pr_nrdplaca => rw_bpr.nrdplaca -- PLaca
                               ,pr_nrrenava => rw_bpr.nrrenava -- Renavam
                               ,pr_nranobem => rw_bpr.nranobem -- Ano Fabricacao
                               ,pr_nrmodbem => rw_bpr.nrmodbem -- Ano modelo                               
                               /* propostaContratoCredito */
                               ,pr_nrctremp => pr_nrctrpro           -- Contrato
                               ,pr_dtmvtolt => vr_vet_dados.dtmvtolt -- Data digitação
                               ,pr_qtpreemp => vr_vet_dados.qtpreemp -- Quantidade parcelas
                               ,pr_permulta => vr_vet_dados.permulta -- Percentual de Multa
                               ,pr_txmensal => vr_vet_dados.txmensal -- Taxa mensal
                               ,pr_vlemprst => vr_vet_dados.vlemprst -- Valor Empréstimo
                               ,pr_tpemprst => vr_vet_dados.tpemprst -- Tipo Emprestimo
                               ,pr_dtdpagto => vr_vet_dados.dtdpagto -- Data da primeira parcela
                               ,pr_dtpagfim => vr_vet_dados.dtvencto -- Data da ultima parcela
                               /* Emitente */
                               ,pr_nrcpfemi => vr_nrcpfbem           -- CPF/CNPJ Emitente
                               ,pr_nmemiten => vr_nmprimtl           -- Nome/Razão Social Emitente
                               ,pr_dsendere => vr_vet_dados.dsendere -- Logradouro Emitente
                               ,pr_nrendere => vr_vet_dados.nrendere -- Numero Emitente
                               ,pr_nmbairro => vr_vet_dados.nmbairro -- Nome Bairro Emitente
                               ,pr_cdufende => vr_vet_dados.cdufende -- UF Emitente
                               ,pr_nrcepend => vr_vet_dados.nrcepend -- CEP Emitente
                               ,pr_cdcidade => vr_vet_dados.cdcidcli -- Cidade
                               ,pr_nrdddtfc => vr_vet_dados.nrdddass -- DDD Emitente
                               ,pr_nrtelefo => vr_vet_dados.nrtelass -- Telefone Emitente
                                /* Credor Eh a Coop */
                               ,pr_nmcddopa => GENE0007.fn_caract_acento(rw_crapope.nmcidade,1) -- Nome da cidade do PA
                               ,pr_cdufdopa => rw_crapope.cdufdcop    -- UF do PA
                               ,pr_inpescre => 2                      -- Tipo pessoa Credor
                               ,pr_nrcpfcre => vr_vet_dados.nrdocnpj  -- CPF/CNPJ Credor
                               ,pr_dsendcre => GENE0007.fn_caract_acento(vr_vet_dados.dsendcre) -- Logradouro Credor
                               ,pr_nrendcre => vr_vet_dados.nrendcre -- Numero Credor
                               ,pr_nmbaicre => GENE0007.fn_caract_acento(vr_vet_dados.nmbaicre,1) -- Nome Bairro Credor
                               ,pr_cdufecre => vr_vet_dados.cdufecre  -- UF Credor
                               ,pr_cdcidcre => vr_vet_dados.cdcidcre  -- Cidade Credor
                               ,pr_nrcepcre => vr_vet_dados.nrcepcre  -- CEP Credor
                               ,pr_nrdddcre => vr_vet_dados.nrdddenc  -- DDD Credor
                               ,pr_nrtelcre => vr_vet_dados.nrtelenc  -- Telefone Credor
                               /* Dados do Vendedor */
                               ,pr_nrcpfven => pr_nrcpfven            -- CPF/CNPJ Vendedor
                               /* Recebedor do pagamento */
                               ,pr_inpesrec => 2                      -- Tipo Pessoa Vendedor
                               ,pr_nrcpfrec => vr_vet_dados.nrdocnpj  -- CPF/CNPJ Vendedor
                               /* Saida */
                               ,pr_xmlalien => vr_dsxmltemp  -- XML da alienação
                               ,pr_dscritic => vr_dscritic); -- Descrição de critica encontrada
          -- Em caso de erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
                END IF;
                
          -- Enviar o mesmo ao CLOB
          gene0002.pc_escreve_xml(vr_clobxml
                                 ,vr_clobaux
                                 ,vr_dsxmltemp); 
              
            END IF;
          END LOOP;
                        
      -- Finalizar grupo Alienações Novas
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_clobaux
                             ,'</gravameB3>');
              
      -- Finalizar o XML
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_clobaux
                             ,'</Root>'
                             ,TRUE);      
      -- E converter o CLOB para o XMLType de retorno
      pr_dsxmlali := XmlType.createXML(vr_clobxml);
                  
      --Fechar Clob e Liberar Memoria  
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml); 
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_dscritic := vr_dscritic;

        -- Enviar ao log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                      'ERRO [registrar_gravame_CDC]: '|| pr_dscritic ||
                                                      ',Cdcooper:'||pr_cdcooper||',Nrdconta:'||pr_nrdconta||',Nrctrpro:'||pr_nrctrpro);

        -- Efetuar rollback
		ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_dscritic := sqlerrm;

        -- Enviar ao log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 3 -- Erro nao tratado
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                      'ERRO [pc_busca_xml_gravame_CDC]: '|| pr_dscritic ||
                                                      ',Cdcooper:'||pr_cdcooper||',Nrdconta:'||pr_nrdconta||',Nrctrpro:'||pr_nrctrpro);        

        -- Efetuar rollback
		ROLLBACK;
    END;
  END pc_busca_xml_gravame_CDC;

  
END GRVM0001;
/
