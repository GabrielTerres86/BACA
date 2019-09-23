CREATE OR REPLACE PACKAGE CECRED.COBR0007 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COBR0007
  --  Sistema  : Procedimentos gerais para execucao de inetrucoes de baixa
  --  Sigla    : CRED
  --  Autor    : Douglas Quisinski 
  --  Data     : Janeiro/2016                     Ultima atualizacao: 09/09/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para instruçoes bancárias - Cob. Registrada 
  --
  --  Alteracoes:
  --
  --    02/02/2018 - Alterações referente ao PRJ352 - Nova solução de protesto
  -- 
  --    16/02/2018 - Ref. História KE00726701-36 - Inclusão de Filtro e Parâmetro por Tipo de Pessoa na TAB052
  --                (Gustavo Sene - GFT)    
  --    24/05/2019 - Configurado campo que enviava null na pc_inst_protestar. 
  --                 (Daniel Lombardi - Mout'S)
  --    25/06/2019 - Ajuste para não permitir baixar titulos em borderos que tenham saldo (Daniel - Ailos)
  --    
  --    09/09/2019 - Ajuste para permitir efetuar protesto de titulos descontados. (Daniel - Ailos)
  ---------------------------------------------------------------------------------------------------------------

  -- Validar se o título está no serasa
  FUNCTION fn_flserasa (pr_flserasa crapcob.flserasa%TYPE, 
                        pr_qtdianeg crapcob.qtdianeg%TYPE,
                        pr_inserasa crapcob.inserasa%TYPE,
												pr_dtvencto crapcob.dtvencto%TYPE,
												pr_dtmvtolt crapdat.dtmvtolt%TYPE) RETURN BOOLEAN;
                        
  -- Procedure para gerar o protesto do titulo
  PROCEDURE pc_inst_protestar (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                              ,pr_nrdconta IN crapcob.nrdconta%TYPE   --> Numero da Conta
                              ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE   --> Numero Convenio
                              ,pr_nrdocmto IN crapcob.nrdocmto%TYPE   --> Numero Documento
                              ,pr_cdocorre IN NUMBER                  --> Codigo da ocorrencia
                              ,pr_cdtpinsc IN crapcob.cdtpinsc%TYPE   --> Tipo Inscricao
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   --> Data pagamento
                              ,pr_cdoperad IN crapope.cdoperad%TYPE   --> Operador
                              ,pr_nrremass IN INTEGER                 --> Numero da Remessa
                              ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                              ,pr_cdcritic OUT INTEGER                --> Codigo da Critica
                              ,pr_dscritic OUT VARCHAR2);             --> Descricao da critica

  -- Procedure para baixar o titulo
  PROCEDURE pc_inst_pedido_baixa_titulo(pr_idregcob            IN ROWID                   --Rowid da Cobranca
                                       ,pr_cdocorre            IN NUMBER                  --Codigo Ocorrencia
                                       ,pr_dtmvtolt            IN crapdat.dtmvtolt%TYPE   --Data pagamento
                                       ,pr_cdoperad            IN crapope.cdoperad%TYPE   --Operador
                                       ,pr_nrremass            IN INTEGER                 --Numero da Remessa
                                       ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                       ,pr_cdcritic            OUT INTEGER                --Codigo da Critica
                                       ,pr_dscritic            OUT VARCHAR2               --Descricao da critica
                                       );
                                       
  -- Procedure para baixar o titulo
  PROCEDURE pc_inst_pedido_baixa (pr_idregcob  IN ROWID                   --> Rowid da Cobranca
                                 ,pr_cdocorre  IN NUMBER                  --> Codigo Ocorrencia
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE   --> Data pagamento
                                 ,pr_cdoperad  IN crapope.cdoperad%TYPE   --> Operador
                                 ,pr_nrremass  IN INTEGER                 --> Numero da Remessa
                                 ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                 ,pr_cdcritic  OUT INTEGER                --> Codigo da Critica
                                 ,pr_dscritic  OUT VARCHAR2);             --> Descricao da critica

  -- Procedure para baixar o titulo progress -- Demetrius
  PROCEDURE pc_inst_pedido_baixa_prg (pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                                     ,pr_nrdconta  IN crapcob.nrdconta%TYPE   --> Numero da Conta
                                     ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE   --> Numero Convenio
                                     ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE   --> Numero Documento
                                     ,pr_cdocorre  IN NUMBER                  --> Codigo Ocorrencia
                                     ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE   --> Data pagamento
                                     ,pr_cdoperad  IN crapope.cdoperad%TYPE   --> Operador
                                     ,pr_nrremass  IN INTEGER                 --> Numero da Remessa
                                     ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                     ,pr_cdcritic  OUT INTEGER                --> Codigo da Critica
                                     ,pr_dscritic  OUT VARCHAR2);             --> Descricao da critica

  -- Procedure para gerar o protesto do titulo
  PROCEDURE pc_inst_pedido_baixa_decurso (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                                         ,pr_nrdconta IN crapcob.nrdconta%TYPE   --> Numero da Conta
                                         ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE   --> Numero Convenio
                                         ,pr_nrdocmto IN crapcob.nrdocmto%TYPE   --> Numero Documento
                                         ,pr_cdocorre IN NUMBER                  --> Codigo da ocorrencia
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   --> Data pagamento
                                         ,pr_cdoperad IN crapope.cdoperad%TYPE   --> Operador
                                         ,pr_nrremass IN INTEGER                 --> Numero da Remessa
                                         ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                         ,pr_cdcritic OUT INTEGER                --> Codigo da Critica
                                         ,pr_dscritic OUT VARCHAR2);             --> Descricao da critica

  -- Procedure para sustar a baixa de Titulo
  PROCEDURE pc_inst_sustar_baixar (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                                  ,pr_nrdconta IN crapcob.nrdconta%TYPE   --> Numero da Conta
                                  ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE   --> Numero Convenio
                                  ,pr_nrdocmto IN crapcob.nrdocmto%TYPE   --> Numero Documento
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   --> Data pagamento
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE   --> Operador
                                  ,pr_nrremass IN INTEGER                 --> Numero Remessa
                                  ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                  ,pr_cdcritic OUT INTEGER                --> Codigo da Critica
                                  ,pr_dscritic OUT VARCHAR2);             --> Descricao da critica

  -- Procedure para Conceder Abatimento
  PROCEDURE pc_inst_conc_abatimento (pr_cdcooper  IN crapcop.cdcooper%TYPE, --> Codigo da cooperativa
                                     pr_nrdconta  IN crapass.nrdconta%TYPE, --> Numero da conta do cooperado
                                     pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE, --> Numero do Convenio
                                     pr_nrdocmto  IN crapcob.nrdocmto%TYPE, --> Numero do documento
                                     pr_cdocorre  IN INTEGER,               --> Codigo da Ocorrencia
                                     pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE, --> Data de Movimentacao
                                     pr_cdoperad  IN crapope.cdoperad%TYPE, --> Codigo do Operador
                                     pr_vlabatim  IN crapcob.vlabatim%TYPE, --> Valor de Abatimento
                                     pr_nrremass  IN crapcob.nrremass%TYPE, --> Numero da Remessa
                                     pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada,
                                     pr_cdcritic OUT INTEGER,               --> Codigo da Critica
                                     pr_dscritic OUT VARCHAR2);             --> Descricao da critica

  -- Procedure para Cancelar Abatimento
  PROCEDURE pc_inst_canc_abatimento (pr_cdcooper  IN crapcop.cdcooper%TYPE, --> Codigo da cooperativa
                                     pr_nrdconta  IN crapass.nrdconta%TYPE, --> Numero da conta do cooperado
                                     pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE, --> Numero do Convenio
                                     pr_nrdocmto  IN crapcob.nrdocmto%TYPE, --> Numero do documento
                                     pr_cdocorre  IN INTEGER,               --> Codigo da Ocorrencia
                                     pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE, --> Data de Movimentacao
                                     pr_cdoperad  IN crapope.cdoperad%TYPE, --> Codigo do Operador
                                     pr_nrremass  IN crapcob.nrremass%TYPE, --> Numero da Remessa
                                     pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada,
                                     pr_cdcritic OUT INTEGER,               --> Codigo da Critica
                                     pr_dscritic OUT VARCHAR2);             --> Descricao da critica

  -- Procedure para Alteracao do Vencimento
  PROCEDURE pc_inst_alt_vencto (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                               ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                               ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                               ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                               ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                               ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                               ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                               ,pr_dtvencto  IN crapcob.dtvencto%TYPE --> Data de vencimento
                               ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                               ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                               ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                               ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

  -- Procedure para Conceder Desconto
  PROCEDURE pc_inst_conc_desconto (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                  ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                  ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                  ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                  ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                  ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                  ,pr_vldescto  IN crapcob.vldescto%TYPE --> Valor do Desconto
                                  ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                  ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                  ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                  ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

  -- Procedure para Cancelar Desconto
  PROCEDURE pc_inst_canc_desconto (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                  ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                  ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                  ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                  ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                  ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                  ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                  ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                  ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                  ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

  -- Procedure para Protestar
  PROCEDURE pc_inst_protestar_arq_rem_085 (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                          ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                          ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                          ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                          ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                          ,pr_qtdiaprt  IN INTEGER               --> Quantidade de Dias de Protesto
                                          ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                          ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                          ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                          ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                          ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                          ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

  -- Procedure para Sustar Protesto e Manter o Titulo
  PROCEDURE pc_inst_sustar_manter (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                  ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                  ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                  ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                  ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                  ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                  ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                  ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                  ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                  ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

  -- Procedure para Cancelar o Protesto
  PROCEDURE pc_inst_cancel_protesto (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                    ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                    ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                    ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                    ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                    ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                    ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                    ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                    ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

  -- Procedure para alterar a quantidade de dias para protesto
  PROCEDURE pc_inst_aut_protesto(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                ,pr_qtdiaprt  IN crapcob.qtdiaprt%TYPE --> Quantidade de dias para protesto
                                ,pr_dtvencto  IN crapcob.dtvencto%TYPE --> Data de vencimento
                                ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                );
  -- Procedure para excluir Protesto com Carta de Anuência Eletrônica
 PROCEDURE pc_exc_prtst_anuencia_eletr(pr_cdcooper            IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                       ,pr_nrdconta            IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                       ,pr_nrcnvcob            IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                       ,pr_nrdocmto            IN crapcob.nrdocmto%TYPE --> Numero do documento
                                       ,pr_cdocorre            IN INTEGER               --> Codigo da Ocorrencia
                                       ,pr_dtmvtolt            IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                       ,pr_cdoperad            IN crapope.cdoperad%TYPE --> Codigo do Operador
                                       ,pr_nrremass            IN crapcob.nrremass%TYPE --> Numero da Remessa
                                       ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                       ,pr_cdcritic            OUT INTEGER              --> Codigo da Critica
                                       ,pr_dscritic            OUT VARCHAR2             --> Descricao da critica
                                       );
  
  -- Procedure para Alterar tipo de emissao CEE
  PROCEDURE pc_inst_alt_tipo_emissao_cee (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                         ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                         ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                         ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                         ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                         ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                         ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                         ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                         ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                         ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

  -- Procedure para Alterar Dados do Sacado - Especifico para Arquivo Remessa 085
  PROCEDURE pc_inst_alt_dados_arq_rem_085 (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                          ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                          ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                          ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                          ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                          -- Dados do Sacado
                                          ,pr_nrinssac  IN crapsab.nrinssac%TYPE --> Inscricao do Sacado
                                          ,pr_dsendsac  IN crapsab.dsendsac%TYPE --> Endereco do Sacado
                                          ,pr_nmbaisac  IN crapsab.nmbaisac%TYPE --> Bairro do Sacado
                                          ,pr_nrcepsac  IN crapsab.nrcepsac%TYPE --> CEP do Sacado
                                          ,pr_nmcidsac  IN crapsab.nmcidsac%TYPE --> Cidade do Sacado
                                          ,pr_cdufsaca  IN crapsab.cdufsaca%TYPE --> UF do Sacado
                                          -- Outros dados
                                          ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                          ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                          ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                          ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                          ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                          ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

  -- Procedure para Cancelar o envio de SMS
  PROCEDURE pc_inst_canc_sms (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                             ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                             ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                             ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                             ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                             ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                             ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                             ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                             ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

  -- Procedure para o envio de SMS
  PROCEDURE pc_inst_envio_sms (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                              ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                              ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                              ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                              ,pr_inavisms  IN PLS_INTEGER           --> Tipo de SMS 1 dia antes do vencimento
                              ,pr_nrcelsac  IN crapsab.nrcelsac%TYPE --> Celular do sacado
                              ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                              ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                              ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

  -- Procedure para exportar boletos emitidos
  PROCEDURE pc_exporta_boletos_emitidos(pr_cdcooper crapcob.cdcooper%TYPE --> Codigo da cooperativa
                                       ,pr_nrdconta crapcob.nrdconta%TYPE --> Nro da conta cooperado
                                       ,pr_dtmvtini crapcob.dtmvtolt%TYPE --> Data de inicio da emissao
                                       ,pr_dtmvtfim crapcob.dtmvtolt%TYPE --> Data de fim da emissao
                                       ,pr_incobran crapcob.incobran%TYPE --> Situacao da cobranca
                                       ,pr_nmdsacad VARCHAR2 --> Nome do sacado/pagador
                                       ,pr_nmarqexp OUT VARCHAR2 --> Caminho e nome do arquivo a ser exportado
                                       ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                       );

END COBR0007;
/
CREATE OR REPLACE PACKAGE BODY CECRED.COBR0007 IS

  /*-------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COBR0007
  --  Sistema  : Procedimentos gerais para execucao de instrucoes de baixa
  --  Sigla    : CRED
  --  Autor    : Douglas Quisinski
  --  Data     : Janeiro/2016                     Ultima atualizacao: 26/06/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para instruçoes bancárias - Cob. Registrada 
  --
  --  Alteracoes: 19/05/2016 - Incluido upper em cmapos de index utilizados em cursores (Andrei - RKAM).
  --
  --              08/11/2016 - Considerar periodo de carencia parametrizado na regra de bloqueio de baixa
  --                          de titulos descontados
  --                          Heitor (Mouts) - Chamado 527557
  --
  --              06/02/2017 - Projeto 319 - Envio de SMS para boletos de cobranca (Andrino - Mout's)
  --
  --              25/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
  --			               crapass, crapttl, crapjur 
  --						  (Adriano - P339).
  --
  --              12/05/2017 - Segunda fase da melhoria 342 (Kelvin).
  --
  --              23/06/2017 - Na rotina pc_inst_alt_dados_arq_rem_085 foi alterado para fechar o cursor correto
  --                           pois estava ocasionando erro (Tiago/Rodrigo #698180)
  --
  --              09/04/2019 - Incluso tratativa para permitir protestar titulos descontados e vencidos apos carencia
  --                           (Daniel - Ailos) 
  ---------------------------------------------------------------------------------------------------------------
  
  04/10/2017 - #751605 Alteradas as rotinas "pc_inst_canc_sms" e "pc_inst_envio_sms". Na de cancelamento, 
               removida a chamada da rotina de validação "pc_efetua_val_recusa_padrao" pois não faz sentido 
               validar a situação do boleto para este caso. Na rotina que habilita o envio, removida a rotina de 
               validação e feita verificação da situação do boleto. Caso a situação for diferente de "ABERTO" não
               habilitar SMS e não retornar como um erro, seguir o fluxo normal. (Carlos)

  02/02/2018 - Alterações referente ao PRJ352 - Nova solução de protesto

  07/11/2018 - Ajuste de mensagem para usuario final
               (Envolti - Belli - INC0026760)
    
  12/02/2019 - Teste Revitalização
               (Belli - Envolti - REQ0035813)
               
  27/02/2019 - Regra deve considerar o sinal de igual para criticar o valor de abatimento
               (Envolti - Belli - INC0032975)            

  13/05/2019 - inc0012700 Tratamento na rotina pc_inst_cancel_protesto_85 para não permitir cancelar as instruções
               de protesto que estão sem confirmação de protesto (Carlos)

  20/05/2019 - inc0011296 Na rotina pc_inst_protestar, corrigida a validação de existência de negativação e 
               centralizada a regra na function fn_flserasa (Carlos)
  
  
  24/06/2019 - INC0013457 Na rotina pc_inst_cancel_protesto_85, feito o controle de envio de registro de 
               desbloqueio do boleto para a CIP, para que não seja enviada mais de uma instrução por vez (Carlos)
  
  20/05/2019 - PRB0041685(INC0013353) corrigida nas procedures abaixo a validação da existência de negativação (Roberto Holz  -  Mout´s)
                    pc_inst_cancel_protesto_85
                    pc_inst_cancel_protesto_bb
                    pc_inst_aut_protesto 

  18/06/2019 - Alteração de código de motivo. Alcemir Jr./Roberto Holz  -  Mout´s(PRB0041653).   
	
	06/09/2019 - INC0015371 - Ajuste na função fn_flserasa para validar corretamente os títulos passiveis de negativação e 
	                          considerar a data para negativação automatica - Augusto (Supero).

  -------------------------------------------------------------------------------------------------------------*/
  --Ch 839539
  vr_cdprogra      tbgen_prglog.cdprograma%type := 'COBR0007';
  
  ------------------------------- CURSORES ---------------------------------    
  -- Busca as informações da cooperativa conectada
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.cdcooper
          ,cop.dsdircop
          ,cop.cdbcoctl
          ,cop.cdagectl
          ,cop.nmrescop
          ,cop.vlinimon
          ,cop.vllmonip
          ,cop.nmextcop
          ,cop.flgofatr
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  
  --Selecionar Cobrancas
  CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%type
                    ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                    ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                    ,pr_nrdconta IN crapcob.nrdconta%type
                    ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                    ,pr_nrdocmto IN crapcob.nrdocmto%type) IS
    SELECT cob.cdbandoc
          ,cob.cdcooper
          ,cob.nrdconta
          ,cob.nrdctabb
          ,cob.nrcnvcob
          ,cob.nrdocmto
          ,cob.incobran
          ,cob.insitcrt
          ,cob.vldpagto
          ,cob.nrnosnum
          ,cob.dsdoccop
          ,cob.dtvencto
          ,cob.vltitulo
          ,cob.flgregis
          ,cob.flgcbdda
          ,cob.insitpro
          ,cob.dtdbaixa
          ,cob.vldescto
          ,cob.vlabatim
          ,cob.flgdprot
          ,cob.idopeleg
          ,cob.qtdiaprt
          ,cob.cddespec
          ,cob.nrinssac
          ,cob.dtmvtolt
          ,cob.dsdinstr
          ,cob.inemiten
          ,cob.inemiexp
          ,cob.inserasa
          ,cob.inavisms
          ,cob.insmsant
          ,cob.insmsvct
          ,cob.insmspos
          ,cob.flserasa
          ,cob.qtdianeg
          ,cob.vlminimo
          ,cob.inpagdiv
          ,cob.cdmensag
          ,cob.cdufsaca
          ,cob.dtbloque
          ,cob.insrvprt
          ,cob.dtsitcrt
          ,cob.rowid
     FROM crapcob cob
    WHERE cob.cdcooper = pr_cdcooper
      AND cob.cdbandoc = pr_cdbandoc
      AND cob.nrdctabb = pr_nrdctabb
      AND cob.nrdconta = pr_nrdconta
      AND cob.nrcnvcob = pr_nrcnvcob
      AND cob.nrdocmto = pr_nrdocmto
    ORDER BY cob.progress_recid ASC;

  --Selecionar Cobranca
  CURSOR cr_crapcob2 (pr_cdcooper IN crapcob.cdcooper%TYPE
                     ,pr_nrdconta IN crapcob.nrdconta%type
                     ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                     ,pr_nrdocmto IN crapcob.nrdocmto%type) IS
    SELECT cob.insmsant
          ,cob.insmsvct
          ,cob.insmspos
          ,cob.inavisms
          ,cob.incobran
          ,cob.nrinssac
          ,cob.cdbandoc
          ,cob.nrdctabb
          ,cob.rowid
      FROM crapcob cob
          ,crapcco cco
     WHERE cob.cdcooper = pr_cdcooper
       AND cob.nrdconta = pr_nrdconta
       AND cob.nrcnvcob = pr_nrcnvcob
       AND cob.nrdocmto = pr_nrdocmto
       AND cco.cdcooper = cob.cdcooper
       AND cco.nrconven = cob.nrcnvcob
       AND cob.cdbandoc = cco.cddbanco
       AND cob.nrdctabb = cco.nrdctabb;

  --Selecionar registro cobranca
  CURSOR cr_crapcob_id (pr_rowid IN ROWID) IS
    SELECT cob.cdcooper
          ,cob.nrdconta
          ,cob.cdbandoc
          ,cob.nrdctabb
          ,cob.nrcnvcob
          ,cob.nrdocmto
          ,cob.flgregis
          ,cob.flgcbdda
          ,cob.insitpro
          ,cob.nrnosnum
          ,cob.vltitulo
          ,cob.incobran
          ,cob.dtvencto
          ,cob.dsdoccop
          ,cob.vlabatim
          ,cob.vldescto
          ,cob.flgdprot
          ,cob.idopeleg
          ,cob.insitcrt
          ,cob.cdagepag
          ,cob.cdbanpag
          ,cob.cdtitprt
          ,cob.dtdbaixa
          ,cob.nrctremp
          ,cob.insrvprt
          ,cob.rowid
     FROM crapcob cob
    WHERE cob.ROWID = pr_rowid;

  -- Busca dos dados do associado
  CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.nrdconta
          ,ass.nmprimtl
          ,ass.vllimcre
          ,ass.nrcpfcgc
          ,ass.inpessoa
          ,ass.cdcooper
          ,ass.cdagenci
          ,ass.nrctacns
          ,ass.idastcjt
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;

  --Selecionar Informacoes Sacado
  CURSOR cr_crapsab (pr_cdcooper IN crapsab.cdcooper%type
                    ,pr_nrdconta IN crapsab.nrdconta%type
                    ,pr_nrinssac IN crapsab.nrinssac%type) IS
    SELECT sab.nmdsacad
          ,sab.cdtpinsc
          ,sab.nrinssac
          ,sab.nmcidsac
          ,sab.cdufsaca
          ,sab.nrcepsac -- CEP do Pagador para buscar depois na instrucao de protesto
      FROM crapsab sab
     WHERE sab.cdcooper = pr_cdcooper
       AND sab.nrdconta = pr_nrdconta
       AND sab.nrinssac = pr_nrinssac;

  -- Selecionar controle retorno titulos bancarios
  CURSOR cr_crapcre (pr_cdcooper IN crapcre.cdcooper%type
                    ,pr_nrcnvcob IN crapcre.nrcnvcob%type
                    ,pr_dtmvtolt IN crapcre.dtmvtolt%type
                    ,pr_intipmvt IN crapcre.intipmvt%type) IS
    SELECT cre.nrremret
          ,cre.dtaltera
      FROM crapcre cre
     WHERE cre.cdcooper = pr_cdcooper
       AND cre.nrcnvcob = pr_nrcnvcob
       AND cre.dtmvtolt = pr_dtmvtolt
       AND cre.intipmvt = pr_intipmvt
     ORDER BY cre.progress_recid DESC;

  --Selecionar remessas
  CURSOR cr_craprem (pr_cdcooper IN craprem.cdcooper%type
                    ,pr_nrcnvcob IN craprem.nrcnvcob%type
                    ,pr_nrdconta IN craprem.nrdconta%type
                    ,pr_nrdocmto IN craprem.nrdocmto%type
                    ,pr_cdocorre IN craprem.cdocorre%type
                    ,pr_dtaltera IN craprem.dtaltera%type) IS
    SELECT rem.dtaltera
          ,rem.cdcooper
          ,rem.cdocorre
          ,rem.nrdconta
          ,rem.nrdocmto
          ,rem.nrcnvcob
          ,rem.dtdprorr
          ,rem.vlabatim
          ,rem.rowid
      FROM craprem rem
     WHERE rem.cdcooper = pr_cdcooper
       AND rem.nrcnvcob = pr_nrcnvcob
       AND rem.nrdconta = pr_nrdconta
       AND rem.nrdocmto = pr_nrdocmto
       AND rem.cdocorre = pr_cdocorre
       AND rem.dtaltera = pr_dtaltera
     ORDER BY rem.progress_recid DESC;
     
  -- Parâmetros do cadastro de cobrança
  CURSOR cr_crapcco(pr_cdcooper IN crapcob.cdcooper%type
                   ,pr_nrconven IN crapcco.nrconven%TYPE) IS
    SELECT cco.cddbanco
          ,cco.nrdctabb
          ,cco.flgregis
          ,cco.dsorgarq
          ,cco.insrvprt
      FROM crapcco cco
     WHERE cco.cdcooper = pr_cdcooper
       AND cco.nrconven = pr_nrconven;
       
  --Selecionar Retornos
  CURSOR cr_crapret (pr_cdcooper IN crapret.cdcooper%type
                    ,pr_nrdconta IN crapret.nrdconta%type
                    ,pr_nrcnvcob IN crapret.nrcnvcob%type
                    ,pr_nrdocmto IN crapret.nrdocmto%type
                    ,pr_cdocorre IN crapret.cdocorre%type) IS
    SELECT ret.cdcooper
      FROM crapret ret
     WHERE ret.cdcooper = pr_cdcooper
       AND ret.nrdconta = pr_nrdconta
       AND ret.nrcnvcob = pr_nrcnvcob
       AND ret.nrdocmto = pr_nrdocmto
       AND ret.cdocorre = pr_cdocorre
    ORDER BY ret.progress_recid ASC;

  FUNCTION fn_flserasa (pr_flserasa crapcob.flserasa%TYPE, 
                        pr_qtdianeg crapcob.qtdianeg%TYPE,
                        pr_inserasa crapcob.inserasa%TYPE,
												pr_dtvencto crapcob.dtvencto%TYPE,
												pr_dtmvtolt crapdat.dtmvtolt%TYPE) RETURN BOOLEAN IS 
  /* ............................................................................

    Programa: fn_flserasa
    Autor   : Carlos Henrique Weinhold
    Data    : Maio/2019
    Objetivo  : Validar se o título está no serasa
  ............................................................................ */   
           
  BEGIN
                                                                     
	  -- Se estiver em processo de negativação ou negativado
    IF pr_inserasa <> 0 THEN
			RETURN TRUE;
		END IF;

    -- Se possuir negativação automatica e...
		-- A data de vencimento + quantidade de dias para negativação for menor ou igual a data atual
		-- O título ainda pode ser enviado ao Serasa
		IF pr_flserasa = 1 AND pr_qtdianeg > 0 AND (pr_dtvencto + pr_qtdianeg) <= trunc(pr_dtmvtolt) THEN
			RETURN TRUE;
		END IF;

    -- Caso contrario não está no Serasa
		RETURN FALSE;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END fn_flserasa;

  ------------------------------ PROCEDURES --------------------------------    
  --> Grava informações para resolver erro de programa/ sistema
  PROCEDURE pc_gera_log(pr_cdcooper      IN PLS_INTEGER           --> Cooperativa
                       ,pr_dstiplog      IN VARCHAR2              --> Tipo Log
                       ,pr_dscritic      IN VARCHAR2 DEFAULT NULL --> Descricao da critica
                       ,pr_cdcriticidade IN tbgen_prglog_ocorrencia.cdcriticidade%type DEFAULT 0
                       ,pr_cdmensagem    IN tbgen_prglog_ocorrencia.cdmensagem%type DEFAULT 0
                       ,pr_ind_tipo_log  IN tbgen_prglog_ocorrencia.tpocorrencia%type DEFAULT 2
                       ,pr_nmarqlog      IN tbgen_prglog.nmarqlog%type DEFAULT NULL
                       ,pr_tpexecucao    IN tbgen_prglog.tpexecucao%type DEFAULT 1 -- cadeia - 12/02/2019 - REQ0035813
                       ) IS
    -----------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_log
    --  Sistema  : Rotina para gravar logs em tabelas
    --  Sigla    : CRED
    --  Autor    : Ana Lúcia E. Volles - Envolti
    --  Data     : Janeiro/2018           Ultima atualizacao: 24/08/2018
    --  Chamado  : 788828
    --
    -- Dados referentes ao programa:
    -- Frequencia: Rotina executada em qualquer frequencia.
    -- Objetivo  : Controla gravação de log em tabelas.
    --
    -- Alteracoes:  
    --             
    ------------------------------------------------------------------------------------------------------------   
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
    --
  BEGIN         
    --> Controlar geração de log de execução dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => NVL(pr_dstiplog,'E'), 
                           pr_cdcooper      => pr_cdcooper, 
                           pr_tpocorrencia  => pr_ind_tipo_log, 
                           pr_cdprograma    => vr_cdprogra, 
                           pr_tpexecucao    => pr_tpexecucao, -- 12/02/2019 - REQ0035813
                           pr_cdcriticidade => pr_cdcriticidade,
                           pr_cdmensagem    => pr_cdmensagem,    
                           pr_dsmensagem    => pr_dscritic,               
                           pr_idprglog      => vr_idprglog,
                           pr_nmarqlog      => pr_nmarqlog);
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
  END pc_gera_log;

  -- Procedure responsavel pela validacao do horario de cobranca 
  PROCEDURE pc_verifica_horario_cobranca (pr_cdcooper IN crapcob.cdcooper%type --> Codigo Cooperativa
                                         ,pr_des_erro OUT VARCHAR2             --> Indicador Sucesso/Erro
                                         ,pr_cdcritic OUT INTEGER              --> Codigo Erro
                                         ,pr_dscritic OUT VARCHAR2) IS         --> Descricao Erro
    -- ...........................................................................................
    --
    --  Programa : pc_verifica_horario_cobranca           Antigo: b1wgen0088.p/verifica-horario-cobranca
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Novembro/2013.                   Ultima atualizacao: 24/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure responsavel pela validacao do horario de cobranca
    --
    --   Alteracoes: 11/01/2016 - Procedure movida da package PAGA0001 para COBR0007 
    --                            (Douglas - Importacao de Arquivos CNAB)
    --
    --               26/12/2017 - Ajuste na mensagem para informar que a instrução só pode ser
    --                            executada em dia útil (Douglas - Chamado 820998)
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Efetua log na rotina chamadora
    --                            Ajuste registro de logs com mensagens corretas
    --                            (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................
    
  BEGIN
    DECLARE
      --Variaveis Locais
      --Tabela de Limites
      vr_tab_limite INET0001.typ_tab_limite;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      --Ch REQ0011728
      --Parametro guardado na rotina chamadora
    BEGIN
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_verifica_horario_cobranca');

      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      pr_des_erro:= 'OK';

      --Limpar Tabela Memoria de Limites
      vr_tab_limite.DELETE;

      --Verificar Horario Operacao
      INET0001.pc_horario_operacao (pr_cdcooper => pr_cdcooper     --Codigo Cooperativa
                                   ,pr_cdagenci => 90 -- internetbanking  --Agencia do Associado
                                   ,pr_tpoperac => 3               --Tipo de Operacao (0=todos)
                                   ,pr_inpessoa => 0               --Tipo de Pessoa
                                   ,pr_idagenda   => 0             --Tipo de agendamento
                                   ,pr_cdtiptra   => 0             --Tipo de transferencia
                                   ,pr_tab_limite => vr_tab_limite --Tabelas de retorno de horarios limite
                                   ,pr_cdcritic => vr_cdcritic     --Codigo do erro
                                   ,pr_dscritic => vr_dscritic);   --Descricao do erro
                                   
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_verifica_horario_cobranca');
      --Se retornou Limite
      IF vr_tab_limite.COUNT > 0 THEN
        -- dentro do limite de horario = 2
        IF vr_tab_limite(vr_tab_limite.FIRST).idesthor = 2 THEN
          RETURN;
        END IF;
        --Montar Mensagem Critica
        vr_cdcritic := 1292;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                       vr_tab_limite(vr_tab_limite.FIRST).hrinipag ||' até '||
                       vr_tab_limite(vr_tab_limite.FIRST).hrfimpag ||'.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        pr_des_erro:= 'NOK';
        --Log efetuado na rotina chamadora
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_verifica_horario_cobranca. '||sqlerrm;
        pr_des_erro:= 'NOK';
        --Log efetuado na rotina chamadora
    END;
  END pc_verifica_horario_cobranca;

  -- Procedure para verificar entrada confirmada
  PROCEDURE pc_verifica_ent_confirmada (pr_idregcob  IN ROWID           --> Rowid da Cobranca
                                       ,pr_des_erro  OUT VARCHAR2       --> Indicador Sucesso/Erro
                                       ,pr_cdcritic  OUT INTEGER        --> Codigo Erro
                                       ,pr_dscritic  OUT VARCHAR2) IS   --> Descricao Erro
    -- ...........................................................................................
    --
    --  Programa : pc_verifica_ent_confirmada           Antigo: b1wgen0088.p/verifica-ent-confirmada
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Novembro/2013.                   Ultima atualizacao: 24/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure responsavel para verificar entrada confirmada
    --
    --   Alteracoes: 11/01/2016 - Procedure movida da package PAGA0001 para COBR0007 
    --                            (Douglas - Importacao de Arquivos CNAB)
    -- 
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            Inclusão vr_cdcritic no retorno da msg 1293
    --                            Efetua log na rotina chamadora
    --                            (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................
  BEGIN
    DECLARE
      -- Registro de Retorno
      rw_crapret    COBR0007.cr_crapret%ROWTYPE;
      -- Registro de Cobranca
      rw_crapcob_id COBR0007.cr_crapcob_id%ROWTYPE;
      --Variaveis Locais
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      --Ch REQ0011728
      vr_dsparame      VARCHAR2(4000);
    BEGIN
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_verifica_ent_confirmada');
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      pr_des_erro:= 'OK';

      vr_dsparame := ' - pr_idregcob:'||pr_idregcob;

      -- verificar se titulo BB tem confirmacao de entrada
      --Selecionar registro cobranca
      OPEN cr_crapcob_id (pr_rowid => pr_idregcob);
      --Posicionar no proximo registro
      FETCH cr_crapcob_id INTO rw_crapcob_id;
      --Se encontrar
      IF cr_crapcob_id%FOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcob_id;
        --Selecionar Retorno
        OPEN cr_crapret (pr_cdcooper => rw_crapcob_id.cdcooper
                        ,pr_nrdconta => rw_crapcob_id.nrdconta
                        ,pr_nrcnvcob => rw_crapcob_id.nrcnvcob
                        ,pr_nrdocmto => rw_crapcob_id.nrdocmto
                        ,pr_cdocorre => 2); -- Entrada Confirmada 
        --Proximo Registro
        FETCH cr_crapret INTO rw_crapret;
        --Se nao encontrou
        IF cr_crapret%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapret;
          --Inclusão vr_cdcritic
          vr_cdcritic := 1293;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  --Titulo sem confirmacao de registro pelo Banco do Brasil
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapret;
      END IF;
      --Fechar Cursor
      IF cr_crapcob_id%ISOPEN THEN
        CLOSE cr_crapcob_id;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic||vr_dsparame;
        pr_des_erro:= 'NOK';

        --Grava log na rotina chamadora - Ch REQ0011728
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => rw_crapcob_id.cdcooper);

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_verifica_ent_confirmada. '||sqlerrm||vr_dsparame;
        pr_des_erro:= 'NOK';

        --Grava log na rotina chamadora - Ch REQ0011728
    END;
  END pc_verifica_ent_confirmada;

  -- Procedure responsavel em efetuar validacao padrao dos motivos de recusa 
  PROCEDURE pc_efetua_val_recusa_padrao (pr_cdcooper IN crapcop.cdcooper%TYPE   --Codigo Cooperativa
                                        ,pr_nrdconta IN crapcob.nrdconta%TYPE   --Numero da Conta
                                        ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE   --Numero Convenio
                                        ,pr_nrdocmto IN crapcob.nrdocmto%TYPE   --Numero Documento
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   --Data Movimento
                                        ,pr_cdoperad IN crapope.cdoperad%TYPE   --Operador
                                        ,pr_cdinstru IN VARCHAR2                --Codigo Instrucao
                                        ,pr_nrremass IN INTEGER                 --Numero da Remessa
                                        ,pr_rw_crapcob OUT cr_crapcob%ROWTYPE   --Registro de Cobranca de Recusa
                                        ,pr_cdcritic OUT INTEGER                --Codigo da Critica
                                        ,pr_dscritic OUT VARCHAR2) IS           --Descricao critica
    -- ...........................................................................................
    --
    --  Programa : pc_efetua_val_recusa_padrao           Antigo: b1wgen0088.p/efetua-validacao-recusa-padrao
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Novembro/2013.                   Ultima atualizacao: 24/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure responsavel em efetuar validacao padrao dos motivos de recusa
    --
    --   Alterações:
    --          20/01/2014 - Ajuste processo leitura crapcob para ganho de performace ( Renato - Supero )
    --
    --          27/06/2014 - Faltou verificar se o título é do Banco do Brasil (001) antes de verificar
    --                       se existe registro de ent_confirmada. (Rafael)
    --
    --          02/01/2015 - Ajustado para não gerar critica de titulo descontado caso a situação seja 0 e
    --                       que ja esteja vencido. SD237726 (Odirlei-AMcom)
    --
    --          11/01/2016 - Procedure movida da package PAGA0001 para COBR0007 
    --                       (Douglas - Importacao de Arquivos CNAB)
    --
    --          27/10/2017 - Não validar Desconto de Titulo no envio de SMS
  	--						 (Andrey Formigari - Mouts) SD: 740630
    --
    --          06/04/2018 - Ajustes para atender ao PRJ352
    --
    --          16/02/2018 - Ref. História KE00726701-36 - Inclusão de Filtro e Parâmetro por Tipo de Pessoa na TAB052
    --                      (Gustavo Sene - GFT)    
    --
    --          06/06/2018 - Validar se o titulo esta negativado, caso esteja não deixar alterar a data de vencimento (Chamado 844126).
    --                      (Alcemir Mout's).   
    --
	  --          17/09/2018 - Remover os titulos que estão em borderôs rejeitados e titulos não aprovados (Vitor S. Assanuma - GFT) 
    --
    --          24/08/2018 - Revitalização
    --                       Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                       Inclusão pc_set_modulo
    --                       Ajuste registro de logs com mensagens corretas
    --                       Aqui pode ser setado vr_cdcritic pq a validação é efetuada em algumas rotinas 
    --                       como pc_inst_protestar, pc_inst_cancel_protesto_85, pc_inst_pedido_baixa_titulo, etc
    --                       e lá já valida vr_cdcritic <> 0
    --                       Efetua log na rotina chamadora
    --                       (Ana - Envolti - Ch. REQ0011728)
    --
    -- ...........................................................................................

  BEGIN
    DECLARE
      --Registro da Cooperativa
      rw_crapcop COBR0007.cr_crapcop%ROWTYPE;
      --Registro de Cobranca
      rw_crapcob COBR0007.cr_crapcob%ROWTYPE;
      --Dados do Associado
      rw_crapass COBR0007.cr_crapass%ROWTYPE;      
      
      --Selecionar informacoes dos titulos do bordero
      CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%type
                        ,pr_nrdconta IN craptdb.nrdconta%type
                        ,pr_cdbandoc IN craptdb.cdbandoc%type
                        ,pr_nrdctabb IN craptdb.nrdctabb%type
                        ,pr_nrcnvcob IN craptdb.nrcnvcob%type
                        ,pr_nrdocmto IN craptdb.nrdocmto%type) IS
        SELECT tdb.dtvencto
              ,tdb.insittit
              ,bdt.flverbor
              ,tdb.vlsldtit
          FROM craptdb tdb
          INNER JOIN crapbdt bdt ON tdb.cdcooper = bdt.cdcooper AND tdb.nrborder = bdt.nrborder
         WHERE tdb.cdcooper = pr_cdcooper
           AND tdb.nrdconta = pr_nrdconta
           AND tdb.cdbandoc = pr_cdbandoc
           AND tdb.nrdctabb = pr_nrdctabb
           AND tdb.nrcnvcob = pr_nrcnvcob
           AND tdb.nrdocmto = pr_nrdocmto
           AND tdb.insitapr <> 2 -- Titulo não aprovado
           AND bdt.insitbdt <> 5; -- Bordero não pode estar Rejeitado
      rw_craptdb cr_craptdb%ROWTYPE;

      rw_crapcco COBR0007.cr_crapcco%ROWTYPE;

	    -- verificar negativação serasa
      CURSOR cr_tbcobran_his_neg_serasa (pr_cdcooper IN craptdb.cdcooper%type
                        ,pr_nrdconta IN craptdb.nrdconta%type
                        ,pr_nrdctabb IN craptdb.nrdctabb%type
                        ,pr_nrcnvcob IN craptdb.nrcnvcob%type
                        ,pr_nrdocmto IN craptdb.nrdocmto%type) IS
      
           select max(thns.inserasa) inserasa 
             from  tbcobran_his_neg_serasa thns 
            where thns.cdcooper=pr_cdcooper and
                  thns.nrdconta=pr_nrdconta and
                  thns.nrdocmto=pr_nrdocmto and
                  thns.nrsequencia=(select max(thns1.nrsequencia)
                                      from tbcobran_his_neg_serasa thns1 
                                     where thns1.cdcooper=thns.cdcooper and
                                           thns1.nrdconta=thns.nrdconta and
                                           thns1.nrdocmto=thns.nrdocmto);
      rw_tbcobran_his_neg_serasa cr_tbcobran_his_neg_serasa%ROWTYPE;


	  CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE           --> Cooperativa
                       ,pr_cdacesso IN craptab.cdacesso%TYPE) IS       --> Texto de parâmetros
        SELECT to_number(substr(tab.dstextab,instr(tab.dstextab,';',1,31)+1,3))
          FROM craptab tab
         WHERE tab.cdcooper = pr_cdcooper
           AND upper(tab.nmsistem) = 'CRED'
           AND upper(tab.tptabela) = 'USUARI'
           AND tab.cdempres = 11
           AND upper(tab.cdacesso) = pr_cdacesso
           AND tab.tpregist = 0;

      --Variaveis de erro
      vr_des_erro VARCHAR2(3);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
	    -- 
      vr_cdacesso varchar2(20);
      vr_dtcalcul date;
      vr_qtdiacar number(3);
      --Ch REQ0011728
      vr_dsparame      VARCHAR2(4000);
    BEGIN
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_efetua_val_recusa_padrao');
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Concatenado apenas o pr_cdinstru, os demais parametros são concatenados
      --na vr_dsparam das rotinas chamadoras
      vr_dsparame := ' - pr_cdinstru:'||pr_cdinstru;

      -- Procedure responsavel em efetuar validacao padrao dos motivos de recusa:
      --  04 - Codigo de Movimento Nao Permitido para Carteira
      --  40 - Titulo com Ordem de Protesto Emitida
      --  60 - Movimento para Titulo Nao Cadastrado
      --  A5 - Registro Rejeitado e Titulo ja Liquidado
      --Selecionar registro cobranca
      --Verificar cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      -- Buscar parâmetros do cadastro de cobrança
      OPEN  cr_crapcco(pr_cdcooper => pr_cdcooper
                      ,pr_nrconven => pr_nrcnvcob);
      FETCH cr_crapcco INTO rw_crapcco;
      -- Se não encontrar registro
      IF cr_crapcco%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcco;
        vr_cdcritic := 1179;  --Registro de cobranca nao encontrado
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcco;

      --Selecionar Cobrancas
      IF cr_crapcob%ISOPEN THEN
        CLOSE cr_crapcob;
      END IF;
      OPEN cr_crapcob(pr_cdcooper => pr_cdcooper
                     ,pr_cdbandoc => rw_crapcco.cddbanco
                     ,pr_nrdctabb => rw_crapcco.nrdctabb
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrcnvcob => pr_nrcnvcob
                     ,pr_nrdocmto => pr_nrdocmto);
      --Posicionar no proximo registro
      FETCH cr_crapcob INTO rw_crapcob;
      --Retornar dados Cursor para Parametro
      pr_rw_crapcob:= rw_crapcob;
      --Se encontrar
      IF cr_crapcob%FOUND THEN
	    --------- Validar Serasa ----------
        IF pr_cdinstru in ('06','09') THEN
           OPEN cr_tbcobran_his_neg_serasa(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdctabb => rw_crapcco.nrdctabb
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrcnvcob => pr_nrcnvcob
                                          ,pr_nrdocmto => pr_nrdocmto);
           --Posicionar no proximo registro
           FETCH cr_tbcobran_his_neg_serasa INTO rw_tbcobran_his_neg_serasa;
           CLOSE cr_tbcobran_his_neg_serasa;
           --1=Pendente Envio, 2=Solicitacao enviada, 3=Pendente Cancelamento, 4=Pendente Envio Cancel, 5-Negativada, 6=Recusada Serasa 7=Acao Judicial. 
           IF rw_tbcobran_his_neg_serasa.inserasa  in (1,2,3,4,5,6,7) THEN
              vr_cdcritic := 79;  --Operação não efetuada. O Titulo tem pendências no serasa
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' O Titulo tem pendências no serasa.';

              RAISE vr_exc_erro;
           END IF;
        END IF;
        ------------------- Validacao Horarios -------------------
        IF pr_cdinstru = '02' THEN  
          -- Titulos BB possuem horario limite de comando da instrucao,
          -- exceto para o operador "1"
          IF pr_cdoperad <> '1' THEN
            IF rw_crapcob.cdbandoc = 001 THEN
              --Verificar Horario Cobranca
              COBR0007.pc_verifica_horario_cobranca (pr_cdcooper => rw_crapcob.cdcooper
                                                    ,pr_des_erro => vr_des_erro
                                                    ,pr_cdcritic => vr_cdcritic
                                                    ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
              -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
              GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_efetua_val_recusa_padrao');
              --Se retornou erro na validacao
              IF vr_des_erro = 'NOK' THEN
                -- Preparar Lote de Retorno Cooperado
                COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                                   ,pr_cdocorre => 26  -- Instrucao Rejeitada  --Codigo Ocorrencia
                                                   ,pr_cdmotivo => NULL -- 'Pedido de Protesto Nao Permitido para o Titulo'  --Codigo Motivo
                                                   ,pr_vltarifa => 0
                                                   ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                                   ,pr_cdagectl => rw_crapcop.cdagectl
                                                   ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                                   ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                                   ,pr_nrremass => pr_nrremass --Numero Remessa
                                                   ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                                   ,pr_dscritic => vr_dscritic); --Descricao Critica
                --Se Ocorreu erro
                IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;
                -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
                GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_efetua_val_recusa_padrao');
                --Retornar Erro
                RAISE vr_exc_erro;
              END IF;
            END IF;
          END IF;
        ELSE
          IF pr_cdinstru = '09' THEN -- Protestar 
						-- Só valida horário se não for instrução de protesto pelo IEPTB
						IF rw_crapcco.insrvprt <> 1 THEN	
              -- Instrucao de protesto possui horario limite de comando da instrucao
              -- exceto para o operador "1" 
              IF pr_cdoperad <> '1' THEN
                --Verificar Horario Cobranca
                COBR0007.pc_verifica_horario_cobranca (pr_cdcooper => rw_crapcob.cdcooper
                                                      ,pr_des_erro => vr_des_erro
                                                      ,pr_cdcritic => vr_cdcritic
                                                      ,pr_dscritic => vr_dscritic);
                --Se ocorreu erro
                IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;
                -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
                GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_efetua_val_recusa_padrao');
                --Se retornou erro na validacao
                IF vr_des_erro = 'NOK' THEN
                  -- Preparar Lote de Retorno Cooperado
                  COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                                     ,pr_cdocorre => 26  -- Instrucao Rejeitada  --Codigo Ocorrencia
                                                     ,pr_cdmotivo => NULL -- 'Pedido de Protesto Nao Permitido para o Titulo'  --Codigo Motivo
                                                     ,pr_vltarifa => 0
                                                     ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                                     ,pr_cdagectl => rw_crapcop.cdagectl
                                                     ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                                     ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                                     ,pr_nrremass => pr_nrremass --Numero Remessa
                                                     ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                                     ,pr_dscritic => vr_dscritic); --Descricao Critica
                  --Se Ocorreu erro
                  IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                  END IF;
                  -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
                  GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_efetua_val_recusa_padrao');
                  --Retornar Erro
                  RAISE vr_exc_erro;
                END IF;
              END IF;
							--
						END IF;
          ELSE -- "04", "05", "06", "07", "08", "11", "41" 
            -- Titulos BB possuem horario limite de comando da instrucao
            IF rw_crapcob.cdbandoc = 001 THEN
              --Verificar Horario Cobranca
              COBR0007.pc_verifica_horario_cobranca (pr_cdcooper => rw_crapcob.cdcooper
                                                    ,pr_des_erro => vr_des_erro
                                                    ,pr_cdcritic => vr_cdcritic
                                                    ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
              -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
              GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_efetua_val_recusa_padrao');
              --Se retornou erro na validacao
              IF vr_des_erro = 'NOK' THEN
                -- Preparar Lote de Retorno Cooperado 
                COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                                   ,pr_cdocorre => 26  -- Instrucao Rejeitada --Codigo Ocorrencia
                                                   ,pr_cdmotivo => NULL -- 'Pedido de Protesto Nao Permitido para o Titulo' --Codigo Motivo
                                                   ,pr_vltarifa => 0
                                                   ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                                   ,pr_cdagectl => rw_crapcop.cdagectl
                                                   ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                                   ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                                   ,pr_nrremass => pr_nrremass --Numero Remessa
                                                   ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                                   ,pr_dscritic => vr_dscritic); --Descricao Critica
                --Se Ocorreu erro
                IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;
                -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
                GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_efetua_val_recusa_padrao');
                --Retornar Erro
                RAISE vr_exc_erro;
              END IF;
            END IF;
          END IF;
        END IF;
        ----------------------------------------------------
        ----------- Validacao Entrada Confirmada -----------
        IF pr_cdinstru <> '02' THEN
          -- Nao efetua validacao no caso de Pedido de Baixa
          -- Verificar se Titulo BB tem Confirmacao de Entrada 
           IF rw_crapcob.cdbandoc = 001 THEN
              COBR0007.pc_verifica_ent_confirmada (pr_idregcob => rw_crapcob.rowid --Rowid da Cobranca
                                                  ,pr_des_erro => vr_des_erro      --Indicador Erro
                                                  ,pr_cdcritic => vr_cdcritic      --Codigo Erro
                                                  ,pr_dscritic => vr_dscritic);    --Descricao Erro
              --Se Ocorreu erro
              IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
              -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
              GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_efetua_val_recusa_padrao');
              --Se retornou erro na validacao
              IF vr_des_erro = 'NOK' THEN
                -- Preparar Lote de Retorno Cooperado
                COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                                   ,pr_cdocorre => 26  -- Instrucao Rejeitada --Codigo Ocorrencia
                                                   ,pr_cdmotivo => NULL -- 'Pedido de Protesto Nao Permitido para o Titulo' --Codigo Motivo
                                                   ,pr_vltarifa => 0
                                                   ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                                   ,pr_cdagectl => rw_crapcop.cdagectl
                                                   ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                                   ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                                   ,pr_nrremass => pr_nrremass --Numero Remessa
                                                   ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                                   ,pr_dscritic => vr_dscritic); --Descricao Critica
                --Se Ocorreu erro
                IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;
                -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
                GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_efetua_val_recusa_padrao');
                --Retornar Erro
                RAISE vr_exc_erro;
              END IF;
           END IF;
        END IF;
        -------------------------------------------------

        open  cr_crapass(pr_cdcooper => rw_crapcob.cdcooper
                        ,pr_nrdconta => rw_crapcob.nrdconta);
        fetch cr_crapass into rw_crapass;
        if    cr_crapass%notfound then
              vr_cdcritic := 9;  --Associado nao cadastrado
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              close cr_crapass;
              raise vr_exc_erro;
        end   if;
        close cr_crapass;
        if    rw_crapass.inpessoa = 1 then -- Pessoa Física
              if    rw_crapcob.flgregis = 1 then -- Cobrança Com Registro
                    vr_cdacesso := 'LIMDESCTITCRPF';
              elsif rw_crapcob.flgregis = 0 then -- Cobrança Sem Registro
                    vr_cdacesso := 'LIMDESCTITPF';
              end if;
        elsif rw_crapass.inpessoa = 2 then -- Pessoa Jurídica
              if    rw_crapcob.flgregis = 1 then -- Cobrança Com Registro
                    vr_cdacesso := 'LIMDESCTITCRPJ';
              elsif rw_crapcob.flgregis = 0 then -- Cobrança Sem Registro
                    vr_cdacesso := 'LIMDESCTITPJ';
              end if;
        end   if;

        open cr_craptab(rw_crapcob.cdcooper,vr_cdacesso);
        fetch cr_craptab into vr_qtdiacar;
        if cr_craptab%notfound then
          vr_qtdiacar := 0;
        end if;
        close cr_craptab;
        -- Selecionar titulos do bordero
        OPEN cr_craptdb (pr_cdcooper => rw_crapcob.cdcooper
                        ,pr_nrdconta => rw_crapcob.nrdconta
                        ,pr_cdbandoc => rw_crapcob.cdbandoc
                        ,pr_nrdctabb => rw_crapcob.nrdctabb
                        ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                        ,pr_nrdocmto => rw_crapcob.nrdocmto);
        --Posicionar no proximo registro
        FETCH cr_craptdb INTO rw_craptdb;
        --Se encontrar
        IF cr_craptdb%FOUND THEN
          vr_dtcalcul := rw_craptdb.dtvencto + vr_qtdiacar + 1;
          vr_dtcalcul := gene0005.fn_valida_dia_util(rw_crapcob.cdcooper,vr_dtcalcul,'P',TRUE,FALSE);
          
          IF pr_cdinstru NOT IN ('95','09') THEN -- NÃO VALIDAR INSTRUCAO 95 ENVIO SMS E 09 PROTESTO

            -- e a situação é em estudo e não esta vencido
            IF ((rw_craptdb.insittit = 0 AND vr_dtcalcul >= pr_dtmvtolt) OR
              (rw_craptdb.insittit = 4 AND vr_dtcalcul >= pr_dtmvtolt AND rw_craptdb.flverbor = 0) OR
              (rw_craptdb.insittit = 4 AND rw_craptdb.vlsldtit > 0 AND rw_craptdb.flverbor = 1) )  THEN -- LIBERADO

              --Fechar Cursor
              CLOSE cr_craptdb;
              -- Preparar Lote de Retorno Cooperado
              COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                                 ,pr_cdocorre => 26  -- Instrucao Rejeitada   --Codigo Ocorrencia
                                                 ,pr_cdmotivo => '04' -- 'Pedido de Protesto Nao Permitido para o Titulo'  --Codigo Motivo
                                                 ,pr_vltarifa => 0
                                                 ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                                 ,pr_cdagectl => rw_crapcop.cdagectl
                                                 ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                                 ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                                 ,pr_nrremass => pr_nrremass --Numero Remessa
                                                 ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                                 ,pr_dscritic => vr_dscritic); --Descricao Critica
              --Se Ocorreu erro
              IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
              -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
              GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_efetua_val_recusa_padrao');
              --mensagem erro
              --Não existia o vr_cdcritic nesse caso, porem, setando vr_cdcritic segue a mesma
              --regra do retorno de uma chama de rotina, por exemplo
              --REQ0011728 - inclusao vr_cdcritic
              vr_cdcritic := 1294;  --Instrucao Rejeitada - Titulo descontado
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;
        --Fechar Cursor
        IF cr_craptdb%ISOPEN THEN
          CLOSE cr_craptdb;
        END IF;
      ELSE
        -- Preparar Lote de Retorno Cooperado
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada --Codigo Ocorrencia
                                           ,pr_cdmotivo => '04' -- 'Pedido de Protesto Nao Permitido para o Titulo' --Codigo Motivo
                                           ,pr_vltarifa => 0
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                           ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                           ,pr_nrremass => pr_nrremass --Numero Remessa
                                           ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                           ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_efetua_val_recusa_padrao');
        --mensagem erro
        --Não existia o vr_cdcritic nesse caso, porem, setando vr_cdcritic segue a mesma
        --regra do retorno de uma chama de rotina, por exemplo
        --REQ0011728 - inclusao vr_cdcritic
        vr_cdcritic := 1179;  --Registro de cobranca nao encontrado 
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_crapcob%ISOPEN THEN
        CLOSE cr_crapcob;
      END IF;

      --Indicador Cobranca
      CASE rw_crapcob.incobran
        WHEN 3 THEN
           IF  rw_crapcob.insitcrt <> 5 THEN
            -- Preparar Lote de Retorno Cooperado
            COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                               ,pr_cdocorre => 26  -- Instrucao Rejeitada --Codigo Ocorrencia
                                               ,pr_cdmotivo => '04' -- 'Pedido de Protesto Nao Permitido para o Titulo' --Codigo Motivo
                                               ,pr_vltarifa => 0
                                               ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                               ,pr_cdagectl => rw_crapcop.cdagectl
                                               ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                               ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                               ,pr_nrremass => pr_nrremass --Numero Remessa
                                               ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                               ,pr_dscritic => vr_dscritic); --Descricao Critica
            --Se Ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_efetua_val_recusa_padrao');
            --Montar mensagem erro
            --Ch 839539
            vr_cdcritic := 1186;  --Instrucao Rejeitada - Boleto Baixado
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            RAISE vr_exc_erro;
          ELSE
            IF NOT(rw_crapcob.cdbandoc = 85 AND pr_cdinstru = 81 AND rw_crapcob.insrvprt = 1) THEN
              -- Preparar Lote de Retorno Cooperado
              COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                                 ,pr_cdocorre => 26  -- Instrucao Rejeitada --Codigo Ocorrencia
                                                 ,pr_cdmotivo => '40' -- 'Titulo com Ordem de Protesto Emitida' --Codigo Motivo
                                                 ,pr_vltarifa => 0
                                                 ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                                 ,pr_cdagectl => rw_crapcop.cdagectl
                                                 ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                                 ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                                 ,pr_nrremass => pr_nrremass --Numero Remessa
                                                 ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                                 ,pr_dscritic => vr_dscritic); --Descricao Critica
              --Se Ocorreu erro
              IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
              -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
              GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_efetua_val_recusa_padrao');
              --Montar mensagem erro
              --Não existia o vr_cdcritic nesse caso, porem, setando vr_cdcritic segue a mesma
              --regra do retorno de uma chama de rotina, por exemplo
              --REQ0011728 - inclusao vr_cdcritic
              vr_cdcritic := 1295;  --Instrucao Rejeitada - Boleto Protestado 
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              RAISE vr_exc_erro;
      			  --
            END IF;
      			--
          END IF;
        WHEN 5 THEN
          IF rw_crapcob.vldpagto > 0 THEN
            -- Preparar Lote de Retorno Cooperado
            COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                               ,pr_cdocorre => 26  -- Instrucao Rejeitada --Codigo Ocorrencia
                                               ,pr_cdmotivo => 'A5' -- 'Titulo com Ordem de Protesto Emitida' --Codigo Motivo
                                               ,pr_vltarifa => 0
                                               ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                               ,pr_cdagectl => rw_crapcop.cdagectl
                                               ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                               ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                               ,pr_nrremass => pr_nrremass --Numero Remessa
                                               ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                               ,pr_dscritic => vr_dscritic); --Descricao Critica
            --Se Ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_efetua_val_recusa_padrao');
            --Montar mensagem erro
            --Não existia o vr_cdcritic nesse caso, porem, setando vr_cdcritic segue a mesma
            --regra do retorno de uma chama de rotina, por exemplo
            --REQ0011728 - inclusao vr_cdcritic
            vr_cdcritic := 1296;  --Instrucao Rejeitada - Boleto liquidado  
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
            RAISE vr_exc_erro;
          END IF;
        ELSE NULL;
      END CASE;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic := vr_dscritic||vr_dsparame;
        --O log é efetuado nas rotinas chamadoras desta

      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_efetua_val_recusa_padrao. '||sqlerrm||vr_dsparame;
        --O log é efetuado nas rotinas chamadoras desta
    END;
  END pc_efetua_val_recusa_padrao;

  -- Procedure para Eliminar a Remessa
  PROCEDURE pc_elimina_remessa (pr_cdcooper IN crapcpr.cdcooper%type --Codigo Cooperativa
                               ,pr_nrdconta IN crapcpr.nrdconta%type --Numero da Conta
                               ,pr_nrcnvcob IN crapcpr.nrcnvcob%type --Numero Convenio
                               ,pr_nrdocmto IN crapcpr.nrdocmto%type --Numero Documento
                               ,pr_cdocorre IN NUMBER                --Ocorrencia
                               ,pr_dtmvtolt IN DATE                  --Data Movimentacao
                               ,pr_des_erro OUT VARCHAR2             --Indicador Erro
                               ,pr_cdcritic OUT INTEGER             --Codigo Critica
                               ,pr_dscritic OUT VARCHAR2) IS        --Descricao Critica
    -- ...........................................................................................
    --
    --  Programa : pc_elimina_remessa           Antigo: b1wgen0088.p/pi-elimina-remessa
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Novembro/2013.                   Ultima atualizacao: 24/08/2018

    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para eliminar remessa
    --
    --   Alteracao : 11/01/2016 - Procedure movida da package PAGA0001 para COBR0007 
    --                            (Douglas - Importacao de Arquivos CNAB)
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            Efetua log na rotina chamadora
    --                            (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................
  BEGIN
    DECLARE
      --Selecionar remessas
      CURSOR cr_craprem (pr_cdcooper IN craprem.cdcooper%type
                        ,pr_nrcnvcob IN craprem.nrcnvcob%type
                        ,pr_nrdconta IN craprem.nrdconta%type
                        ,pr_nrdocmto IN craprem.nrdocmto%type
                        ,pr_cdocorre IN craprem.cdocorre%type
                        ,pr_dtaltera IN craprem.dtaltera%type) IS
        SELECT rem.dtaltera
              ,rem.cdcooper
              ,rem.cdocorre
              ,rem.nrdconta
              ,rem.nrdocmto
              ,rem.nrcnvcob
              ,rem.dtdprorr
              ,rem.rowid
          FROM craprem rem
         WHERE rem.cdcooper = pr_cdcooper
           AND rem.nrcnvcob = pr_nrcnvcob
           AND rem.nrdconta = pr_nrdconta
           AND rem.nrdocmto = pr_nrdocmto
           AND rem.cdocorre = pr_cdocorre
           AND rem.dtaltera = pr_dtaltera
         ORDER BY rem.progress_recid ASC;
      rw_craprem cr_craprem%ROWTYPE;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      --Ch REQ0011728
      vr_dsparame      VARCHAR2(4000);
    BEGIN
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_elimina_remessa');
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      pr_des_erro:= 'OK';

      vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                    ||', pr_nrdconta:'||pr_nrdconta
                    ||', pr_nrcnvcob:'||pr_nrcnvcob
                    ||', pr_nrdocmto:'||pr_nrdocmto 
                    ||', pr_cdocorre:'||pr_cdocorre
                    ||', pr_dtmvtolt:'||pr_dtmvtolt;

      --Consultar Remessa
      OPEN cr_craprem (pr_cdcooper => pr_cdcooper
                      ,pr_nrcnvcob => pr_nrcnvcob
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrdocmto => pr_nrdocmto
                      ,pr_cdocorre => pr_cdocorre
                      ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou, exclui registro
       IF cr_craprem%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem;
        BEGIN
          DELETE FROM craprem
          WHERE craprem.rowid = rw_craprem.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

            vr_cdcritic := 1037;  --Erro ao excluir remessa
            vr_dscritic := gene0001.fn_busca_critica(1037)||'craprem:'||
                          ' com rowid:'||rw_craprem.rowid||
                          '. '||sqlerrm;
            RAISE vr_exc_erro;
        END;
      ELSE
        pr_des_erro:= 'NOK';
        pr_dscritic := gene0001.fn_busca_critica(1397); -- Problemas na exclusao da Remessa

      END IF;
      --Fechar Cursor
      IF cr_craprem%ISOPEN THEN
        CLOSE cr_craprem;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic||vr_dsparame;
        pr_des_erro:= 'NOK';

        --Grava log nas rotinas chamadoras -- tabela de log - Ch REQ0011728
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_elimina_remessa. '||sqlerrm||vr_dsparame;
        pr_des_erro:= 'NOK';

        --Grava log nas rotinas chamadoras -- tabela de log - Ch REQ0011728
    END;
  END pc_elimina_remessa;

  -- Procedure para verificar Existencia de Instrucao
  PROCEDURE pc_verif_existencia_instruc (pr_idregcob  IN ROWID          --ROWID da Cobranca
                                        ,pr_cdoperad  IN VARCHAR2       --Codigo Operador
                                        ,pr_dtmvtolt  IN DATE           --Data Movimento
                                        ,pr_cdcritic  OUT INTEGER       --Codigo Critica
                                        ,pr_dscritic  OUT VARCHAR2) IS  --Descricao Critica
    -- ...........................................................................................
    --
    --  Programa : pc_verif_existencia_instruc           Antigo: b1wgen0088.p/verifica-existencia-instrucao
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Novembro/2013.                   Ultima atualizacao: 24/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para verificar Existencia de Instrucao
    --
    --   Alteracao : 11/01/2016 - Procedure movida da package PAGA0001 para COBR0007 
    --                            (Douglas - Importacao de Arquivos CNAB)
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................

  BEGIN
    DECLARE
      --Selecionar remessas
      CURSOR cr_craprem (pr_cdcooper IN craprem.cdcooper%type
                        ,pr_nrcnvcob IN craprem.nrcnvcob%type
                        ,pr_nrdconta IN craprem.nrdconta%type
                        ,pr_nrdocmto IN craprem.nrdocmto%type
                        ,pr_dtaltera IN craprem.dtaltera%type) IS
        SELECT rem.dtaltera
              ,rem.cdcooper
              ,rem.cdocorre
              ,rem.nrdconta
              ,rem.nrdocmto
              ,rem.nrcnvcob
              ,rem.dtdprorr
          FROM craprem rem
         WHERE rem.cdcooper = pr_cdcooper
           AND rem.nrcnvcob = pr_nrcnvcob
           AND rem.nrdconta = pr_nrdconta
           AND rem.nrdocmto = pr_nrdocmto
           AND rem.cdocorre IN (4,5,6)
           AND rem.dtaltera = pr_dtaltera;
           
      --Selecionar Ocorrencias
      CURSOR cr_crapoco (pr_cdcooper IN crapoco.cdcooper%type
                        ,pr_cddbanco IN crapoco.cddbanco%type
                        ,pr_cdocorre IN crapoco.cdocorre%type
                        ,pr_tpocorre IN crapoco.tpocorre%type) IS
        SELECT oco.dsocorre
          FROM crapoco oco
         WHERE oco.cdcooper = pr_cdcooper
           AND oco.cddbanco = pr_cddbanco
           AND oco.cdocorre = pr_cdocorre
           AND oco.tpocorre = pr_tpocorre
         ORDER BY oco.progress_recid ASC;
      rw_crapoco cr_crapoco%ROWTYPE;
      
      --Selecionar Prorrogacoes Bloqueto
      CURSOR cr_crapcpr (pr_cdcooper IN crapcpr.cdcooper%type
                        ,pr_nrdconta IN crapcpr.nrdconta%type
                        ,pr_nrdocmto IN crapcpr.nrdocmto%type
                        ,pr_nrcnvcob IN crapcpr.nrcnvcob%type
                        ,pr_dtvctonv IN crapcpr.dtvctonv%type) IS
        SELECT cpr.dtvctori
          FROM crapcpr cpr
         WHERE cpr.cdcooper = pr_cdcooper
           AND cpr.nrdconta = pr_nrdconta
           AND cpr.nrdocmto = pr_nrdocmto
           AND cpr.nrcnvcob = pr_nrcnvcob
           AND cpr.dtvctonv = pr_dtvctonv
         ORDER BY cpr.progress_recid DESC;
      rw_crapcpr cr_crapcpr%ROWTYPE;
      
      -- Registro de Cobranca
      rw_crapcob_id cr_crapcob_id%ROWTYPE;
      
      --Variaveis Locais
      vr_dsmotivo VARCHAR2(100);
      --Variaveis de erro
      vr_des_erro VARCHAR2(4000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      --Ch REQ0011728
      vr_dsparame      VARCHAR2(4000);
    BEGIN
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_verif_existencia_instruc');

      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      vr_dsparame := ' - pr_idregcob:'||pr_idregcob
                    ||', pr_cdoperad:'||pr_cdoperad
                    ||', pr_dtmvtolt:'||pr_dtmvtolt;
                    
      --Selecionar registro cobranca
      OPEN cr_crapcob_id (pr_rowid => pr_idregcob);
      --Posicionar no proximo registro
      FETCH cr_crapcob_id INTO rw_crapcob_id;
      --Se nao encontrar
      IF cr_crapcob_id%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcob_id;
        --Ch 839539
        vr_cdcritic := 1179;  --Cobranca nao encontrada
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_crapcob_id%ISOPEN THEN
        CLOSE cr_crapcob_id;
      END IF;

      --Selecionar Remessas
      FOR rw_craprem IN cr_craprem (pr_cdcooper => rw_crapcob_id.cdcooper
                                   ,pr_nrcnvcob => rw_crapcob_id.nrcnvcob
                                   ,pr_nrdconta => rw_crapcob_id.nrdconta
                                   ,pr_nrdocmto => rw_crapcob_id.nrdocmto
                                   ,pr_dtaltera => pr_dtmvtolt) LOOP
        --Selecionar Ocorrencias
        OPEN cr_crapoco (pr_cdcooper => rw_craprem.cdcooper
                        ,pr_cddbanco => 1 -- Apenas quando Bco 1
                        ,pr_cdocorre => rw_craprem.cdocorre
                        ,pr_tpocorre => 1);
        FETCH cr_crapoco INTO rw_crapoco;
        --Fechar Cursor
        CLOSE cr_crapoco;
        --Exclusao Abatimento
        IF rw_craprem.cdocorre = 4 THEN
          -- Excluiu abatimento, Zera abatimento
          BEGIN
            UPDATE crapcob SET crapcob.vlabatim = 0
            WHERE crapcob.rowid = pr_idregcob;
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception (pr_cdcooper => 0);

              vr_cdcritic := 1035;  --Erro ao atualizar cobranca
              vr_dscritic := gene0001.fn_busca_critica(1035)||'crapcob:'||
                            ' vlabatim:0'||
                            ' com rowid:'||pr_idregcob||
                            '. '||sqlerrm;
          END;
        ELSIF rw_craprem.cdocorre = 6 THEN -- Excluiu Prorrogacao
          -- Cadastro Prorrogacao Bloquetos
          OPEN cr_crapcpr (pr_cdcooper => rw_craprem.cdcooper
                          ,pr_nrdconta => rw_craprem.nrdconta
                          ,pr_nrdocmto => rw_craprem.nrdocmto
                          ,pr_nrcnvcob => rw_craprem.nrcnvcob
                          ,pr_dtvctonv => rw_craprem.dtdprorr);
          FETCH cr_crapcpr INTO rw_crapcpr;
          --Se Encontrou
          IF cr_crapcpr%FOUND THEN
            --Fechar Cursor
            CLOSE cr_crapcpr;
            --Atualizar Cobranca
            BEGIN
              UPDATE crapcob SET crapcob.dtvencto = rw_crapcpr.dtvctori
              WHERE crapcob.rowid = pr_idregcob;
            EXCEPTION
              WHEN OTHERS THEN
                CECRED.pc_internal_exception (pr_cdcooper => 0);

                vr_cdcritic := 1035;  --Erro ao atualizar cobranca
                vr_dscritic := gene0001.fn_busca_critica(1035)||'crapcob:'||
                               ' dtvencto:'||rw_crapcpr.dtvctori||
                               ' com rowid:'||pr_idregcob||
                               '. '||sqlerrm;
            END;
          END IF;
          --Fechar Cursor
          IF cr_crapcpr%ISOPEN THEN
            CLOSE cr_crapcpr;
          END IF;
        END IF;
        --- AQUI LOG de Processo 
        vr_dsmotivo:= 'Exclusao Instrucao '||rw_crapoco.dsocorre;
        --Cria log cobranca
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => pr_idregcob   --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                     ,pr_dsmensag => vr_dsmotivo   --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro   --Indicador erro
                                     ,pr_dscritic => vr_dscritic); --Descricao erro
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_verif_existencia_instruc');
        -- Exclui o Instrucao de Remessa
        COBR0007.pc_elimina_remessa (pr_cdcooper => rw_craprem.cdcooper  --Codigo Cooperativa
                                    ,pr_nrdconta => rw_craprem.nrdconta  --Numero da Conta
                                    ,pr_nrcnvcob => rw_craprem.nrcnvcob  --Numero Convenio
                                    ,pr_nrdocmto => rw_craprem.nrdocmto  --Numero Documento
                                    ,pr_cdocorre => rw_craprem.cdocorre  --Ocorrencia
                                    ,pr_dtmvtolt => rw_craprem.dtaltera  --Data Movimentacao
                                    ,pr_des_erro => vr_des_erro          --Indicador Erro
                                    ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                    ,pr_dscritic => vr_dscritic);        --Descricao Critica
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF; 
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_verif_existencia_instruc');
      END LOOP;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;

        --Grava tabela de log - Ch REQ0011728
        pc_gera_log(pr_cdcooper      => rw_crapcob_id.cdcooper,   
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic||vr_dsparame,
                    pr_cdcriticidade => 1,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 1);

        -- Complemento para INC0026760
        -- Se chegar erro não tratado de outras chamadas desta procedure joga para 1124
        IF pr_cdcritic = 9999 THEN
          pr_cdcritic := 1224; -- Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;            
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => rw_crapcob_id.cdcooper);   

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_verif_existencia_instruc. '||sqlerrm||vr_dsparame;

        --Grava tabela de log - Ch REQ0011728
        pc_gera_log(pr_cdcooper      => rw_crapcob_id.cdcooper,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 2,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 2);

        pr_cdcritic := 1224; --complemento para INC0026760
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic); --complemento para INC0026760
    END;
  END pc_verif_existencia_instruc;

  -- Procedure para enviar titulo para protesto
  PROCEDURE pc_enviar_titulo_protesto (pr_idregcob IN ROWID                 --ROWID da cobranca
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --Data Movimento
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE --Codigo Operador
                                      ,pr_cdcritic OUT INTEGER              --Codigo Critica
                                      ,pr_dscritic OUT VARCHAR2) IS         --Descricao Critica
    -- ...........................................................................................
    --
    --  Programa : pc_enviar_titulo_protesto           Antigo: b1wgen0088.p/enviar-tit-protesto
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Novembro/2013.                   Ultima atualizacao: 24/08/201812/12/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia : Sempre que for chamado
    --   Objetivo   : Procedure para enviar titulo para protesto
    --
    --   Alterações : 24/06/2014 - Utilização da fn_sequence para a gravação na crapcob
    --                             conforme solicitação do Rafael Cechet (Marcos-Supero)
    --
    --                01/07/2014 - Alteração da fn_sequence para a gravação na crapcob.
    --                             Faltou ';' ao concatenar os campos da sequence feito
    --                             pelo Marcos na versão anterior. (Rafael)
    --
    --                12/12/2016 - Adicionar LOOP para buscar o numero do convenio de protesto
    --                             (Douglas - Chamado 564039)
    --
    --                24/08/2018 - Revitalização
    --                             Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                             Inclusão pc_set_modulo
    --                             Ajuste registro de logs com mensagens corretas
    --                             Aqui pode ser setado vr_cdcritic pq a validação é efetuada apenas
    --                             na rotina pc_inst_protestar e lá já valida vr_cdcritic <> 0
    --                             Efetua log na rotina chamadora
    --                             (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................
  BEGIN
    DECLARE
      --Selecionar Informacoes de Cobranca pelo rowid
      CURSOR cr_crapcob (pr_rowid IN ROWID) IS
        SELECT cob.*
              ,cob.rowid
          FROM crapcob cob
         WHERE cob.rowid = pr_rowid;
      rw_bcrapcob     cr_crapcob%ROWTYPE;
      rw_crapcob_novo cr_crapcob%ROWTYPE;
      
      --Selecionar Cadastro Cobranca
      CURSOR cr_crapcco (pr_cdcooper IN crapcco.cdcooper%type
                        ,pr_cddbanco IN crapcco.cddbanco%type
                        ,pr_flgregis IN crapcco.flgregis%type
                        ,pr_flgativo IN crapcco.flgativo%type
                        ,pr_dsorgarq IN crapcco.dsorgarq%type) IS
        SELECT cco.nrconven
              ,cco.nrdctabb
              ,cco.cddbanco
              ,cco.cdcartei
          FROM crapcco cco
         WHERE cco.cdcooper = pr_cdcooper
           AND cco.cddbanco = pr_cddbanco
           AND cco.flgregis = pr_flgregis
           AND cco.flgativo = pr_flgativo
           AND cco.dsorgarq = pr_dsorgarq
         ORDER BY cco.progress_recid ASC;
      rw_crapcco cr_crapcco%ROWTYPE;
      
      --Selecionar Ultimo Controle Cobranca
      CURSOR cr_crapceb (pr_cdcooper IN crapceb.cdcooper%type
                        ,pr_nrdconta IN crapceb.nrdconta%type
                        ,pr_nrconven IN crapceb.nrconven%type) IS
        SELECT ceb.inarqcbr
              ,ceb.nrdconta
              ,ceb.cddemail
              ,ceb.nrcnvceb
          FROM crapceb ceb
         WHERE ceb.cdcooper = pr_cdcooper
           AND ceb.nrdconta = pr_nrdconta
           AND ceb.nrconven = pr_nrconven
         ORDER BY ceb.progress_recid DESC;
      rw_crapceb cr_crapceb%ROWTYPE;

      --Selecionar Ultimo Convenio de Protesto para Cobranca
      CURSOR cr_crapceb_protesto (pr_cdcooper IN crapceb.cdcooper%type
                                 ,pr_nrconven IN crapceb.nrconven%type
                                 ,pr_nrcnvceb IN crapceb.nrcnvceb%type) IS
        SELECT ceb.nrcnvceb
          FROM crapceb ceb
         WHERE ceb.cdcooper = pr_cdcooper
           AND ceb.nrconven = pr_nrconven
           AND ceb.nrcnvceb = pr_nrcnvceb;
      rw_crapceb_protesto cr_crapceb_protesto%ROWTYPE;
      
      --Variaveis Locais
      vr_nrremret INTEGER;
      vr_nrseqreg INTEGER;
      vr_nrdocmto INTEGER;
      vr_nrcnvceb INTEGER := 0;
      vr_qtdregdda INTEGER;
      vr_dsmotivo VARCHAR2(100);
      vr_rowid_ret ROWID;
      -- Controle do convenio CEB que deve ser gerado
      vr_ultnrceb INTEGER := 0;
      vr_nrcnvceb_max CONSTANT INTEGER := 9999;
      
      --Tabelas de Memoria de Remessa
      vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
      vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
      rw_crapcop         COBR0007.cr_crapcop%ROWTYPE;
      rw_crapass         COBR0007.cr_crapass%ROWTYPE;
      --Variaveis de erro
      vr_des_erro     VARCHAR2(4000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      --Ch REQ0011728
      vr_exc_others    EXCEPTION;
      vr_dsparame      VARCHAR2(4000);
    BEGIN
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_enviar_titulo_protesto');

      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      vr_dsparame := ' - pr_idregcob:'||pr_idregcob;

      --
      --REQ0011728 - Substituída a validação por rowid - não cai em NO_DATA_FOUND
      BEGIN
      --Selecionar registro cobranca
      OPEN cr_crapcob (pr_rowid => pr_idregcob);
      --Posicionar no proximo registro
      FETCH cr_crapcob INTO rw_bcrapcob;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          --Mensagem Erro
          vr_cdcritic := 1179; -- 'Registro de Cobranca nao encontrado.';
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        --Fechar Cursor
        CLOSE cr_crapcob;
        --Levantar Excecao
        RAISE vr_exc_erro;
        WHEN OTHERS THEN
          IF SQLCODE = -01410 THEN -- ORA-01410: ROWID inválido
            --Mensagem Erro
            vr_cdcritic := 1179; -- 'Registro de Cobranca nao encontrado.';
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            --Fechar Cursor
            CLOSE cr_crapcob;   
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            -- Quando erro de programa gravar tabela especifica de log
            CECRED.pc_internal_exception (pr_cdcooper => 0);      
            -- Efetuar retorno do erro não tratado
            vr_cdcritic := 1036;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                           vr_dsparame || '. ' || sqlerrm; 
            --Fechar Cursor
            CLOSE cr_crapcob;   
            --Levantar Excecao  
            RAISE vr_exc_others;    
      END IF;
      END;
      --

      --Verificar cooperativa
      OPEN cr_crapcop(pr_cdcooper => rw_bcrapcob.cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      -- Buscar banco correspondente 
      OPEN cr_crapcco (pr_cdcooper => rw_bcrapcob.cdcooper
                      ,pr_cddbanco => 1
                      ,pr_flgregis => 1
                      ,pr_flgativo => 1
                      ,pr_dsorgarq => 'PROTESTO');
      --Proximo registro
      FETCH cr_crapcco INTO rw_crapcco;
      --Se nao encontrou
      IF cr_crapcco%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcco;
        vr_cdcritic := 563;  --Convenio nao cadastrado ou invalido
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcco;
      --Se Cobranca DDA e banco centralizador
      IF rw_bcrapcob.flgcbdda = 1 AND
         rw_bcrapcob.cdbandoc = rw_crapcop.cdbcoctl THEN
        -- Executa procedimentos do DDA-JD 
        DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_bcrapcob.rowid      --ROWID da Cobranca
                                         ,pr_tpoperad => 'B'                     --Tipo Operacao
                                         ,pr_tpdbaixa => '3'                     --Tipo de Baixa
                                         ,pr_dtvencto => rw_bcrapcob.dtvencto    --Data Vencimento
                                         ,pr_vldescto => rw_bcrapcob.vldescto    --Valor Desconto
                                         ,pr_vlabatim => rw_bcrapcob.vlabatim    --Valor Abatimento
                                         ,pr_flgdprot => rw_bcrapcob.flgdprot    --Flag Protesto
                                         ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa
                                         ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela memoria retorno DDA
                                         ,pr_cdcritic        => vr_cdcritic           --Codigo Critica
                                         ,pr_dscritic        => vr_dscritic);         --Descricao Critica
        --Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_enviar_titulo_protesto');
      END IF;
      -- Gerar novo titulo usando a fn_sequence 
      vr_nrdocmto := fn_sequence(pr_nmtabela => 'CRAPCOB'
                                ,pr_nmdcampo => 'NRDOCMTO'
                                ,pr_dsdchave => rw_bcrapcob.cdcooper || ';'
                                             || rw_bcrapcob.nrdconta || ';'
                                             || rw_crapcco.nrconven || ';'
                                             || rw_crapcco.nrdctabb || ';'
                                             || rw_crapcco.cddbanco);

      -- Procura convenio CEB do cooperado 
      --Selecionar cadastro emissao bloquetos
      OPEN cr_crapceb (pr_cdcooper => rw_bcrapcob.cdcooper
                      ,pr_nrdconta => rw_bcrapcob.nrdconta
                      ,pr_nrconven => rw_crapcco.nrconven);
      FETCH cr_crapceb INTO rw_crapceb;
      --Verificar se encontrou
      IF cr_crapceb%FOUND THEN
        vr_nrcnvceb:= rw_crapceb.nrcnvceb;
      ELSE
        --Fechar Cursor
        CLOSE cr_crapceb;
        IF NVL(vr_nrcnvceb, 0) = 0 THEN
          -- Loop para encontrar numero valido de convenio de protesto
          FOR i IN 1..vr_nrcnvceb_max LOOP
            OPEN cr_crapceb_protesto(pr_cdcooper => rw_bcrapcob.cdcooper
                                    ,pr_nrconven => rw_crapcco.nrconven
                                    ,pr_nrcnvceb => i);
            FETCH cr_crapceb_protesto INTO rw_crapceb_protesto;
            IF cr_crapceb_protesto%NOTFOUND THEN
              -- Fecha cursor
              CLOSE cr_crapceb_protesto;
              vr_nrcnvceb := i;
              -- Terminar LOOP
              EXIT;
            END IF;
            -- Fecha cursor
            CLOSE cr_crapceb_protesto;
            vr_ultnrceb := i;
          END LOOP;
        END IF;
        -- Verificar se é o ultimo convenio de protesto
        IF vr_ultnrceb = vr_nrcnvceb_max THEN
          -- Deixar mensagem de erro no log do boleto quando Protesto for por arquivo
          vr_dsmotivo:= 'Erro: numero CEB excedeu o limite de ' || 
                        to_char(vr_nrcnvceb_max) ||
                        '. Instrucao de protesto cancelada.';

          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => pr_idregcob   --ROWID da Cobranca
                                       ,pr_cdoperad => pr_cdoperad   --Operador
                                       ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                       ,pr_dsmensag => vr_dsmotivo   --Descricao Mensagem
                                       ,pr_des_erro => vr_des_erro   --Indicador erro
                                       ,pr_dscritic => vr_dscritic); --Descricao erro
                    
          vr_cdcritic:= 0;
          vr_dscritic:= vr_dsmotivo;
                        
          --Levantar Excecao
          RAISE vr_exc_erro;  
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_enviar_titulo_protesto'); 
        --Inserir Cadastro Emissao Bloqueto
        BEGIN
          INSERT INTO crapceb
            (crapceb.cdcooper
            ,crapceb.nrdconta
            ,crapceb.nrconven
            ,crapceb.nrcnvceb
            ,crapceb.dtcadast
            ,crapceb.cdoperad
            ,crapceb.inarqcbr
            ,crapceb.cddemail
            ,crapceb.flgcruni
            ,crapceb.insitceb)
          VALUES
            (rw_bcrapcob.cdcooper
            ,rw_bcrapcob.nrdconta
            ,rw_crapcco.nrconven
            ,vr_nrcnvceb
            ,pr_dtmvtolt
            ,'1'
            ,0
            ,0
            ,0
            ,1);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 1034;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapceb:'||
            ' cdcooper:'||rw_bcrapcob.cdcooper||
            ', nrdconta:'||rw_bcrapcob.nrdconta||
            ', nrconven:'||rw_crapcco.nrconven||
            ', nrcnvceb:'||vr_nrcnvceb||
            ', dtcadast:'||pr_dtmvtolt||
            ', cdoperad:1'||
            ', inarqcbr:0'||
            ', cddemail:0'||
            ', flgcruni:0'||
            ', insitceb:1'||
            '. '||sqlerrm;

            --Gravar tabela especifica de log - 30/01/2018 - Ch REQ0011728
            CECRED.pc_internal_exception (pr_cdcooper => rw_bcrapcob.cdcooper);
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END IF;
      --Fechar Cursor
      IF cr_crapceb%ISOPEN THEN
        CLOSE cr_crapceb;
      END IF;

      --Encontrar ultimo registro tabela
      vr_qtdregdda:= vr_tab_remessa_dda.count;

      --Verificar Conta Associado
      OPEN cr_crapass(pr_cdcooper => rw_bcrapcob.cdcooper
                     ,pr_nrdconta => rw_bcrapcob.nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      --Se nao encontrou associado
      IF cr_crapass%NOTFOUND THEN
        vr_cdcritic := 9;  --Associado nao cadastrado
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        --Fechar Cursor
        CLOSE cr_crapass;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;

      --Se tem remesssa dda na tabela
      IF vr_qtdregdda > 0 THEN
        rw_bcrapcob.idopeleg:= vr_tab_remessa_dda(vr_tab_remessa_dda.LAST).idopeleg;
      END IF;
      -- Baixar Titulo original 
      rw_bcrapcob.dtdbaixa:= pr_dtmvtolt;
      rw_bcrapcob.incobran:= 3; -- Baixado 
      rw_bcrapcob.insitcrt:= 1; -- C/ Instr. de Protesto
      rw_bcrapcob.cdagepag:= rw_crapcop.cdagectl;
      rw_bcrapcob.cdbanpag:= rw_crapcop.cdbcoctl;
      rw_bcrapcob.cdtitprt:= gene0002.fn_mask(rw_bcrapcob.cdcooper,'999')|| ';'||
                             gene0002.fn_mask(rw_bcrapcob.nrdconta,'99999999')|| ';'||
                             gene0002.fn_mask(rw_crapcco.nrconven,'99999999')|| ';'||
                             gene0002.fn_mask(vr_nrdocmto,'999999999');

      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_enviar_titulo_protesto'); 
      --------------------------------------------------------------------------------------------
      -- Renato Darosci - Supero - 15/07/2014
      -- Retirada do savepoint e alteração na lógica.
      --   O savepoint não pode ser utilizado desta forma, pois
      --   causa erro no processo, devido ao acesso via gateway
      --   para a transação do JDDA.
      --   Devido essa deficiencia o savepoint será retirado,
      --   será realizado a tentativa de insert antes da atualização
      --   da crapcob. Em caso de erro no update, o registro criado
      --   será apagado. Dessa forma eliminamos a necessidade do
      --   savepoint e mantemos os controles do programa.
      --
      --    ### ATENÇÃO: Não incluir SAVEPOINT nesta rotina. ###
      --
      --    --Atualizar titulo Cobranca Atual
      --    SAVEPOINT protestar;
      --
      --------------------------------------------------------------------------------------------
      --Inserir Cobranca
      BEGIN
        INSERT INTO crapcob
          (dtmvtolt
          ,incobran
          ,nrdconta
          ,nrdctabb
          ,cdbandoc
          ,nrdocmto
          ,dtretcob
          ,nrcnvcob
          ,cdoperad
          ,hrtransa --10
          ,cdcooper
          ,indpagto
          ,dtdpagto
          ,vldpagto
          ,vltitulo
          ,dsinform
          ,dsdinstr
          ,dtvencto
          ,cdcartei
          ,cddespec --20
          ,cdtpinsc
          ,nmdsacad
          ,dsendsac
          ,nmbaisac
          ,nrcepsac
          ,nmcidsac
          ,cdufsaca
          ,cdtpinav
          ,cdimpcob
          ,flgimpre --30
          ,nrinsava
          ,nrinssac
          ,nmdavali
          ,nrdoccop
          ,vldescto
          ,cdmensag
          ,dsdoccop
          ,idseqttl
          ,dtelimin
          ,dtdbaixa --40
          ,vlabatim
          ,vltarifa
          ,cdagepag
          ,cdbanpag
          ,dtdocmto
          ,nrctasac
          ,nrctremp
          ,nrnosnum
          ,insitcrt
          ,dtsitcrt --50
          ,nrseqtit
          ,flgdprot
          ,qtdiaprt
          ,indiaprt
          ,vljurdia
          ,vlrmulta
          ,flgaceit
          ,dsusoemp
          ,flgregis
          ,dtlimdsc --60
          ,inemiten
          ,tpjurmor
          ,vloutcre
          ,tpdmulta
          ,vloutdeb
          ,flgcbdda
          ,vlmulpag
          ,vljurpag
          ,idtitleg
          ,idopeleg --70
          ,insitpro
          ,nrremass
          ,cdtitprt
          ,dcmc7chq)
        VALUES
          (rw_bcrapcob.dtmvtolt
          ,0
          ,rw_bcrapcob.nrdconta
          ,rw_crapcco.nrdctabb
          ,rw_crapcco.cddbanco
          ,vr_nrdocmto
          ,rw_bcrapcob.dtretcob
          ,rw_crapcco.nrconven
          ,rw_bcrapcob.cdoperad
          ,rw_bcrapcob.hrtransa --10
          ,rw_bcrapcob.cdcooper
          ,rw_bcrapcob.indpagto
          ,rw_bcrapcob.dtdpagto
          ,rw_bcrapcob.vldpagto
          ,rw_bcrapcob.vltitulo
          ,rw_bcrapcob.dsinform
          ,rw_bcrapcob.dsdinstr
          ,rw_bcrapcob.dtvencto
          ,rw_crapcco.cdcartei
          ,rw_bcrapcob.cddespec --20
          ,rw_bcrapcob.cdtpinsc
          ,rw_bcrapcob.nmdsacad
          ,rw_bcrapcob.dsendsac
          ,rw_bcrapcob.nmbaisac
          ,rw_bcrapcob.nrcepsac
          ,rw_bcrapcob.nmcidsac
          ,rw_bcrapcob.cdufsaca
          ,rw_crapass.inpessoa
          ,3
          ,1                    --30
          ,rw_crapass.nrcpfcgc
          ,rw_bcrapcob.nrinssac
          ,rw_crapass.nmprimtl
          ,rw_bcrapcob.nrdoccop
          ,nvl(rw_bcrapcob.vldescto,0) + nvl(rw_bcrapcob.vlabatim,0)
          ,rw_bcrapcob.cdmensag
          ,rw_bcrapcob.dsdoccop
          ,rw_bcrapcob.idseqttl
          ,rw_bcrapcob.dtelimin
          ,NULL                 --40
          ,rw_bcrapcob.vlabatim
          ,rw_bcrapcob.vltarifa
          ,rw_crapcop.cdagectl
          ,rw_crapcop.cdbcoctl
          ,rw_bcrapcob.dtdocmto
          ,rw_bcrapcob.nrctasac
          ,rw_bcrapcob.nrctremp
          ,GENE0002.fn_mask(rw_crapcco.nrconven,'9999999')||
           GENE0002.fn_mask(vr_nrcnvceb,'9999')||
           GENE0002.fn_mask(vr_nrdocmto,'999999')
          ,1
          ,rw_bcrapcob.dtsitcrt --50
          ,rw_bcrapcob.nrseqtit
          ,1
          ,6
          ,2
          ,rw_bcrapcob.vljurdia
          ,rw_bcrapcob.vlrmulta
          ,0
          ,rw_bcrapcob.dsusoemp
          ,1
          ,rw_bcrapcob.dtlimdsc --60
          ,1
          ,rw_bcrapcob.tpjurmor
          ,rw_bcrapcob.vloutcre
          ,rw_bcrapcob.tpdmulta
          ,rw_bcrapcob.vloutdeb
          ,0
          ,rw_bcrapcob.vlmulpag
          ,rw_bcrapcob.vljurpag
          ,rw_bcrapcob.idtitleg
          ,rw_bcrapcob.idopeleg --70
          ,0
          ,rw_bcrapcob.nrremass
          ,gene0002.fn_mask(rw_bcrapcob.cdcooper,'999')|| ';'||
           gene0002.fn_mask(rw_bcrapcob.nrdconta,'99999999')|| ';'||
           gene0002.fn_mask(rw_bcrapcob.nrcnvcob,'99999999')|| ';'||
           gene0002.fn_mask(rw_bcrapcob.nrdocmto,'999999999')
          ,rw_bcrapcob.dcmc7chq)
        RETURNING crapcob.cdcooper
                 ,crapcob.nrcnvcob
                 ,crapcob.nrdocmto
                 ,crapcob.rowid
        INTO rw_crapcob_novo.cdcooper
            ,rw_crapcob_novo.nrcnvcob
            ,rw_crapcob_novo.nrdocmto
            ,rw_crapcob_novo.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          -- Renato - Supero - 15/07/2014 - Retirado conforme justificativa acima
          -- ROLLBACK TO prostestar;
          ---------------
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_enviar_titulo_protesto'); 

          vr_cdcritic := 1034; 
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
          ' dtmvtolt:'||rw_bcrapcob.dtmvtolt||
          ', incobran:0'||
          ', nrdconta:'||rw_bcrapcob.nrdconta||
          ', nrdctabb:'||rw_crapcco.nrdctabb||
          ', cdbandoc:'||rw_crapcco.cddbanco||
          ', nrdocmto:'||vr_nrdocmto||
          ', dtretcob:'||rw_bcrapcob.dtretcob||
          ', nrcnvcob:'||rw_crapcco.nrconven||
          ', cdoperad:'||rw_bcrapcob.cdoperad||
          ', hrtransa:'||rw_bcrapcob.hrtransa||
          ', cdcooper:'||rw_bcrapcob.cdcooper||
          ', indpagto:'||rw_bcrapcob.indpagto||
          ', dtdpagto:'||rw_bcrapcob.dtdpagto||
          ', vldpagto:'||rw_bcrapcob.vldpagto||
          ', vltitulo:'||rw_bcrapcob.vltitulo||
          ', dsinform:'||rw_bcrapcob.dsinform||
          ', dsdinstr:'||rw_bcrapcob.dsdinstr||
          ', dtvencto:'||rw_bcrapcob.dtvencto||
          ', cdcartei:'||rw_crapcco.cdcartei||
          ', cddespec:'||rw_bcrapcob.cddespec||
          ', cdtpinsc:'||rw_bcrapcob.cdtpinsc||
          ', nmdsacad:'||rw_bcrapcob.nmdsacad||
          ', dsendsac:'||rw_bcrapcob.dsendsac||
          ', nmbaisac:'||rw_bcrapcob.nmbaisac||
          ', nrcepsac:'||rw_bcrapcob.nrcepsac||
          ', nmcidsac:'||rw_bcrapcob.nmcidsac||
          ', cdufsaca:'||rw_bcrapcob.cdufsaca||
          ', cdtpinav:'||rw_crapass.inpessoa||
          ', cdimpcob:3'||
          ', flgimpre:1'||
          ', nrinsava:'||rw_crapass.nrcpfcgc||
          ', nrinssac:'||rw_bcrapcob.nrinssac||
          ', nmdavali:'||rw_crapass.nmprimtl||
          ', nrdoccop:'||rw_bcrapcob.nrdoccop||
          ', vldescto:'||nvl(rw_bcrapcob.vldescto,0)||' + '||nvl(rw_bcrapcob.vlabatim,0)||
          ', cdmensag:'||rw_bcrapcob.cdmensag||
          ', dsdoccop:'||rw_bcrapcob.dsdoccop||
          ', idseqttl:'||rw_bcrapcob.idseqttl||
          ', dtelimin:'||rw_bcrapcob.dtelimin||
          ', dtdbaixa:NULL'||                 
          ', vlabatim:'||rw_bcrapcob.vlabatim||
          ', vltarifa:'||rw_bcrapcob.vltarifa||
          ', cdagepag:'||rw_crapcop.cdagectl||
          ', cdbanpag:'||rw_crapcop.cdbcoctl||
          ', dtdocmto:'||rw_bcrapcob.dtdocmto||
          ', nrctasac:'||rw_bcrapcob.nrctasac||
          ', nrctremp:'||rw_bcrapcob.nrctremp||
          ', nrnosnum:'||GENE0002.fn_mask(rw_crapcco.nrconven,'9999999')
                         ||GENE0002.fn_mask(vr_nrcnvceb,'9999')
                         ||GENE0002.fn_mask(vr_nrdocmto,'999999')||
          ', insitcrt:'||1||
          ', dtsitcrt:'||rw_bcrapcob.dtsitcrt||
          ', nrseqtit:'||rw_bcrapcob.nrseqtit||
          ', flgdprot:1'||
          ', qtdiaprt:6'||
          ', indiaprt:2'||
          ', vljurdia:'||rw_bcrapcob.vljurdia||
          ', vlrmulta:'||rw_bcrapcob.vlrmulta||
          ', flgaceit:0'||
          ', dsusoemp:'||rw_bcrapcob.dsusoemp||
          ', flgregis:1'||
          ', dtlimdsc:'||rw_bcrapcob.dtlimdsc||
          ', inemiten:1'||
          ', tpjurmor:'||rw_bcrapcob.tpjurmor||
          ', vloutcre:'||rw_bcrapcob.vloutcre||
          ', tpdmulta:'||rw_bcrapcob.tpdmulta||
          ', vloutdeb:'||rw_bcrapcob.vloutdeb||
          ', flgcbdda:0'||
          ', vlmulpag:'||rw_bcrapcob.vlmulpag||
          ', vljurpag:'||rw_bcrapcob.vljurpag||
          ', idtitleg:'||rw_bcrapcob.idtitleg||
          ', idopeleg:'||rw_bcrapcob.idopeleg||
          ', insitpro:0'||
          ', nrremass:'||rw_bcrapcob.nrremass||
          ', cdtitprt:'||gene0002.fn_mask(rw_bcrapcob.cdcooper,'999')
                         || ';'||gene0002.fn_mask (rw_bcrapcob.nrdconta, '99999999')
                         || ';'||gene0002.fn_mask (rw_bcrapcob.nrcnvcob, '99999999')
                         || ';'||gene0002.fn_mask (rw_bcrapcob.nrdocmto, '999999999')||
          ', dcmc7chq:'||rw_bcrapcob.dcmc7chq||
          '. '||sqlerrm;

          --Gravar tabela especifica de log - 30/01/2018 - Ch REQ0011728
          CECRED.pc_internal_exception (pr_cdcooper => rw_bcrapcob.cdcooper);
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_enviar_titulo_protesto'); 

      BEGIN
        UPDATE crapcob SET idopeleg = rw_bcrapcob.idopeleg
                          ,dtdbaixa = rw_bcrapcob.dtdbaixa
                          ,incobran = rw_bcrapcob.incobran -- Baixado 
                          ,insitcrt = rw_bcrapcob.insitcrt -- C/ Instr. de Protesto 
                          ,cdagepag = rw_bcrapcob.cdagepag
                          ,cdbanpag = rw_bcrapcob.cdbanpag
                          ,cdtitprt = rw_bcrapcob.cdtitprt
        WHERE crapcob.rowid = pr_idregcob;  -- Rowid parametro
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception (pr_cdcooper => 0);

          vr_cdcritic := 1035; 
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                        ' idopeleg:'||rw_bcrapcob.idopeleg||
                        ', dtdbaixa:'||rw_bcrapcob.dtdbaixa||
                        ', incobran:'||rw_bcrapcob.incobran||
                        ', insitcrt:'||rw_bcrapcob.insitcrt||
                        ', cdagepag:'||rw_bcrapcob.cdagepag||
                        ', cdbanpag:'||rw_bcrapcob.cdbanpag||
                        ', cdtitprt:'||rw_bcrapcob.cdtitprt||
                        ' com rowid:'||pr_idregcob||
                        '. '||sqlerrm;
          BEGIN
            -- Excluir o novo registro criado
            DELETE crapcob
             WHERE crapcob.rowid = rw_crapcob_novo.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception (pr_cdcooper => 0);

              vr_cdcritic := 1037;
              vr_dscritic := vr_dscritic||CHR(10)||  
                              gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                            ' com rowid:'||rw_crapcob_novo.rowid||
                            '. '||sqlerrm;
          END;

          --Levantar Excecao
          RAISE vr_exc_erro;
      END;

      -- gerar pedido de remessa
      PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob_novo.cdcooper --Codigo Cooperativa
                                     ,pr_nrcnvcob => rw_crapcob_novo.nrcnvcob --Numero Convenio
                                     ,pr_dtmvtolt => pr_dtmvtolt         --Data movimento
                                     ,pr_cdoperad => pr_cdoperad         --Codigo Operador
									 ,pr_idregcob => rw_crapcob_novo.rowid  --ROWID da cobranca
                                     ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                     ,pr_rowid_ret => vr_rowid_ret       --ROWID Remessa Retorno
                                     ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                     ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                     ,pr_dscritic => vr_dscritic);       --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_enviar_titulo_protesto'); 
      --Incrementar Sequencial
      vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;
      --Criar tabela Remessa
      PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob_novo.rowid     --ROWID da cobranca
                                   ,pr_nrremret => vr_nrremret          --Numero Remessa
                                   ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                   ,pr_cdocorre => 1                    --Codigo Ocorrencia
                                   ,pr_cdmotivo => NULL                 --Codigo Motivo
                                   ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                   ,pr_vlabatim => 0                    --Valor Abatimento
                                   ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                   ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);        --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_enviar_titulo_protesto'); 
      ---- LOG de Processo Titulo Novo ----
      vr_dsmotivo:= 'Tit Ant: Conv '|| (rw_bcrapcob.nrcnvcob) ||
                    ' Docto '|| rw_bcrapcob.nrdocmto;

      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob_novo.rowid   --ROWID da Cobranca
                                   ,pr_cdoperad => pr_cdoperad   --Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                   ,pr_dsmensag => vr_dsmotivo   --Descricao Mensagem
                                   ,pr_des_erro => vr_des_erro   --Indicador erro
                                   ,pr_dscritic => vr_dscritic); --Descricao erro
      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_enviar_titulo_protesto'); 
      ---- LOG de Processo ----
      vr_dsmotivo:= 'Baixado p/ enviar Protesto';
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_bcrapcob.rowid   --ROWID da Cobranca
                                   ,pr_cdoperad => pr_cdoperad   --Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                   ,pr_dsmensag => vr_dsmotivo   --Descricao Mensagem
                                   ,pr_des_erro => vr_des_erro   --Indicador erro
                                   ,pr_dscritic => vr_dscritic); --Descricao erro
      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_enviar_titulo_protesto'); 
      ---- LOG de Processo Titulo Anterior ----
      vr_dsmotivo:= 'Tit Novo: Conv '|| rw_crapcob_novo.nrcnvcob||
                    ' Docto '|| rw_crapcob_novo.nrdocmto;
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => pr_idregcob   --ROWID da Cobranca
                                   ,pr_cdoperad => pr_cdoperad   --Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                   ,pr_dsmensag => vr_dsmotivo   --Descricao Mensagem
                                   ,pr_des_erro => vr_des_erro   --Indicador erro
                                   ,pr_dscritic => vr_dscritic); --Descricao erro
      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic||vr_dsparame;

        --Grava tabela de log na rotina chamadora - Ch REQ0011728
      WHEN vr_exc_others THEN --REQ0011728
        CECRED.pc_internal_exception (pr_cdcooper => rw_bcrapcob.cdcooper);

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_enviar_titulo_protesto. '||sqlerrm||vr_dsparame;

        --Grava tabela de log na rotina chamadora - Ch REQ0011728
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => rw_bcrapcob.cdcooper);

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_enviar_titulo_protesto. '||sqlerrm||vr_dsparame;

        --Grava tabela de log na rotina chamadora - Ch REQ0011728
    END;
  END pc_enviar_titulo_protesto;

  -- Criar registro de prorrogacao
  PROCEDURE pc_cria_tab_prorrogacao (pr_rw_crapcob IN cr_crapcob%ROWTYPE --> Rowtype da Cobranca
                                    ,pr_dtvctonv   IN DATE               --> Data de Vencimento Nova
                                    ,pr_dtvctori   IN DATE               --> Data de Vencimento Original
                                    ,pr_flgconfi   IN INTEGER            --> Confirmacao da prorrogacao de vencimento
                                    ,pr_cdoperad   IN VARCHAR2           --> Operador
                                    ,pr_dtmvtolt   IN DATE               --> Data de movimento
                                    ,pr_cdcritic  OUT INTEGER            --> Codigo da Critica
                                    ,pr_dscritic  OUT VARCHAR2 ) IS      --> Descricao da Critica
    -- ...........................................................................................
    --
    --  Programa : pc_cria_tab_prorrogacao          Antigo: b1wgen0088.p/cria-tab-prorrogacao
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Douglas Quisinski
    --  Data     : Janeiro/2016                     Ultima atualizacao: 24/08/201822/01/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Criar o registro de Prorrogacao
    --
    --   Alteracao : 22/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            Efetua log na rotina chamadora
    --                            (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
  BEGIN
    -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_cria_tab_prorrogacao'); 
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
  
    BEGIN
      INSERT INTO crapcpr
            (cdcooper,
             nrcnvcob,
             nrdconta,
             nrdocmto,
             dtvctonv,
             dtvctori,
             flgconfi,
             cdoperad,
             dtaltera,
             hrtransa)
     VALUES (pr_rw_crapcob.cdcooper,
             pr_rw_crapcob.nrcnvcob,
             pr_rw_crapcob.nrdconta,
             pr_rw_crapcob.nrdocmto,
             pr_dtvctonv,
             pr_dtvctori,
             pr_flgconfi,
             pr_cdoperad,
             pr_dtmvtolt,
             gene0002.fn_busca_time);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 1034;  --Erro ao atualizar cobranca   
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcpr:'||
        ' cdcooper:'||pr_rw_crapcob.cdcooper||
        ', nrcnvcob: '||pr_rw_crapcob.nrcnvcob||
        ', nrdconta:'||pr_rw_crapcob.nrdconta||
        ', nrdocmto:'||pr_rw_crapcob.nrdocmto||
        ', dtvctonv:'||pr_dtvctonv||
        ', dtvctori:'||pr_dtvctori||
        ', flgconfi:'||pr_flgconfi||
        ', cdoperad:'||pr_cdoperad||
        ', dtaltera:'||pr_dtmvtolt||
        ', hrtransa:'||gene0002.fn_busca_time||
        '. '||sqlerrm;

      --Gravar tabela especifica de log - 30/01/2018 - Ch REQ0011728
      CECRED.pc_internal_exception (pr_cdcooper => pr_rw_crapcob.cdcooper);

      --Como nesse caso se ocorrer erro, a rotina não vai fazer raise, 
      --será gravado log para conhecimento aqui, sem parar a execução do programa
      --Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_rw_crapcob.cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => vr_dscritic,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(vr_cdcritic,0),
                  pr_ind_tipo_log  => 1);

    END;
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic||vr_dsparame;
      
      --Log efetuado na rotina chamadora - Ch REQ0011728
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_rw_crapcob.cdcooper);

      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_cria_tab_prorrogacao. '||sqlerrm||vr_dsparame;

      --Log efetuado na rotina chamadora - Ch REQ0011728
  END pc_cria_tab_prorrogacao;

  -- Procedure para Protestar Titulo Migrado
  PROCEDURE pc_inst_titulo_migrado (pr_idregcob   IN cr_crapcob%ROWTYPE    --Rowtype da Cobranca
                                   ,pr_dsdinstr   IN VARCHAR2              --Descricao da Instrucao
                                   ,pr_dtaltvct   IN DATE                  --Data Alteracao Vencimento
                                   ,pr_vlaltabt   IN NUMBER                --Valor Alterado Abatimento
                                   ,pr_nrdctabb   IN crapcco.nrdctabb%TYPE --Numero da Conta BB
                                   ,pr_cdcritic   OUT INTEGER              --Codigo da Critica
                                   ,pr_dscritic   OUT VARCHAR2) IS         --Descricao critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_titulo_migrado           Antigo: b1wgen0088.p/inst-titulo-migrado
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Novembro/2013.                   Ultima atualizacao: 24/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Protestar Titulo Migrado
    --
    --   Alterações: 20/01/2014 - Ajuste migracao Acredi->Viacredi. ( Renato - Supero )
    --
    --               11/01/2016 - Procedure movida da package PAGA0001 para COBR0007 
    --                            (Douglas - Importacao de Arquivos CNAB)
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            Efetua log na rotina chamadora
    --                            (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................

  BEGIN
    DECLARE
      --Variaveis Locais
      vr_conteudo VARCHAR2(4000);
      vr_des_assunto VARCHAR2(1000);
      vr_email_dest VARCHAR2(1000);
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      --Ch REQ0011728
      vr_dsparame      VARCHAR2(4000);
    BEGIN
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_titulo_migrado'); 

      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      vr_dsparame := ' - pr_dsdinstr:'||pr_dsdinstr
                    ||', pr_dtaltvct:'||pr_dtaltvct
                    ||', pr_vlaltabt:'||pr_vlaltabt
                    ||', pr_nrdctabb:'||pr_nrdctabb;
                    
      --Montar Conteudo Email
      vr_conteudo:= 'Favor proceder com a instrucao de '|| pr_dsdinstr ||
                    ' no Gerenciador Financeiro para o titulo abaixo: <BR><BR>';
      --Se a conta estiver preenchida
      IF pr_nrdctabb IS NOT NULL THEN
        vr_conteudo:= vr_conteudo ||'Conta BB: '||gene0002.fn_mask_conta(pr_nrdctabb)||'<br>';
      END IF;
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_titulo_migrado'); 
      --Continuar montagem do conteudo
      vr_conteudo:= vr_conteudo || 'Conta/DV    : '|| gene0002.fn_mask_conta(pr_idregcob.nrdconta) || '<BR>'||
                                   'Nosso numero: '|| pr_idregcob.nrnosnum || '<BR>'||
                                   'Documento   : '|| pr_idregcob.dsdoccop || '<BR>'||
                                   'Vencimento  : '|| TO_CHAR(pr_idregcob.dtvencto,'DD/MM/YYYY')|| '<BR>'||
                                   'Valor       : '|| gene0002.fn_mask(pr_idregcob.vltitulo,'zzz,zzz,zz9.99')|| '<BR><BR>';
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_titulo_migrado'); 
      --Se a data alteracao estiver preenchida
      IF pr_dtaltvct IS NOT NULL THEN
        vr_conteudo:= vr_conteudo || '<BR>'||'Novo vencimento : '||TO_CHAR(pr_dtaltvct,'DD/MM/YYYY')|| '<BR><BR>';
      END IF;
      --Se valor maior zero
      IF pr_vlaltabt > 0 THEN
        vr_conteudo:= vr_conteudo || '<BR>'||'Abatimento : '||gene0002.fn_mask(pr_vlaltabt,'zzz,zzz,zz9.99')|| '<BR><BR>';
      END IF;
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_titulo_migrado'); 
      --Montar Assunto
      vr_des_assunto:= 'Solicitacao de instrucao de '|| pr_dsdinstr;
      --Email Destino
      vr_email_dest:= gene0001.fn_param_sistema('CRED',pr_idregcob.cdcooper,'INST_TIT_MIGRADO');
      --Se nao encontrou destinatario para as cooperativas 1 ou 16
      -- O programa progress não envia e-mail para as demais cooperativas
      IF vr_email_dest IS NULL AND pr_idregcob.cdcooper IN (1,16) THEN
        vr_dscritic := gene0001.fn_busca_critica(1297);  --Email de destino para titulo migrado nao encontrado
        RAISE vr_exc_erro;
      ELSE
        --Enviar Email
        gene0003.pc_solicita_email(pr_cdcooper        => pr_idregcob.cdcooper
                                  ,pr_cdprogra        => 'b1wgen0088'
                                  ,pr_des_destino     => vr_email_dest
                                  ,pr_des_assunto     => vr_des_assunto
                                  ,pr_des_corpo       => vr_conteudo
                                  ,pr_des_anexo       => NULL
                                  ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N' --> Se o envio será do e-mail da Cooperativa
                                  ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                  ,pr_flg_log_batch   => 'N' --> Incluir inf. no log
                                  ,pr_des_erro        => vr_dscritic);
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_titulo_migrado'); 
        -- Apenas sai da rotina
        RETURN;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;

        --Log efetuado na rotina chamadora - Ch REQ0011728
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_idregcob.cdcooper); 

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_titulo_migrado. '||sqlerrm;

        --Log efetuado na rotina chamadora - Ch REQ0011728
    END;
  END pc_inst_titulo_migrado;

  -- Procedure para gerar o protesto do titulo
  PROCEDURE pc_inst_protestar (pr_cdcooper IN crapcop.cdcooper%TYPE   --Codigo Cooperativa
                              ,pr_nrdconta IN crapcob.nrdconta%TYPE   --Numero da Conta
                              ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE   --Numero Convenio
                              ,pr_nrdocmto IN crapcob.nrdocmto%TYPE   --Numero Documento
                              ,pr_cdocorre IN NUMBER                  --Codigo da ocorrencia
                              ,pr_cdtpinsc IN crapcob.cdtpinsc%TYPE   --Tipo Inscricao
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   --Data pagamento
                              ,pr_cdoperad IN crapope.cdoperad%TYPE   --Operador
                              ,pr_nrremass IN INTEGER                 --Numero da Remessa
                              ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                              ,pr_cdcritic OUT INTEGER                --Codigo da Critica
                              ,pr_dscritic OUT VARCHAR2) IS           --Descricao da critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_protestar           Antigo: b1wgen0088.p/inst-protestar
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Novembro/2013.                   Ultima atualizacao: 06/03/2019
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para gerar protesto dos titulos
    --
    --   Alterações
    --
    --        04/12/2014 - De acordo com a circula 3.656 do Banco Central,substituir
    --                     nomenclaturas Cedente por Beneficiário e  Sacado por Pagador
    --                      Chamado 229313 (Jean Reddiga - RKAM).
    --
    --        11/01/2016 - Procedure movida da package PAGA0001 para COBR0007 
    --                     (Douglas - Importacao de Arquivos CNAB)
    --							
    --        19/05/2016 - Incluido upper em cmapos de index utilizados em cursores (Andrei - RKAM).
    --
    --        27/09/2017 - Adicionar validação para não permitir Protestar um Titulo que já
    --                     tenha sido negativado no Serasa (Douglas - Chamado 754911)
    --
    --        24/08/2018 - Revitalização
    --                     Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                     Inclusão pc_set_modulo
    --                     Ajuste registro de logs com mensagens corretas
    --                     (Ana - Envolti - Ch. REQ0011728)
    --
    --        14/01/2019 - Enviar instrucao de bloqueio do boleto para a CIP. (Cechet)
    --
    --        06/03/2019 - Retornar erro caso o endereço não for encontrado na base de CEPs. (Cechet)
    -- ...........................................................................................
  BEGIN
    DECLARE
      --Cursores Locais
      /*Rafael Ferreira (Mouts) - INC0022229
      Conforme informado por Deise Carina Tonn da area de Negócio, esta validação não é mais necessária
      pois agora Todas as cidades podem ter protesto*/
      --Selecionar Pracas nao executantes Protesto
      /*CURSOR cr_crappnp (pr_nmextcid IN crappnp.nmextcid%type
                        ,pr_cduflogr IN crappnp.cduflogr%type) IS
        SELECT pnp.nmextcid
          FROM crappnp pnp
         WHERE UPPER(pnp.nmextcid) = UPPER(pr_nmextcid)
           AND UPPER(pnp.cduflogr) = UPPER(pr_cduflogr);
      rw_crappnp cr_crappnp%ROWTYPE;*/
      
      -- verificar se o CEP existe nos correios
      CURSOR cr_cep (pr_nrceplog IN crapdne.nrceplog%TYPE) IS
        SELECT nrceplog 
          FROM crapdne dne
         WHERE dne.nrceplog = pr_nrceplog
           AND dne.idoricad = 1; -- somente CEP dos correios;
      rw_cep cr_cep%ROWTYPE;
      
      --Variaveis Locais
      vr_index_lat VARCHAR2(60);
      vr_nrremret  INTEGER;
      vr_nrseqreg  INTEGER;
      vr_dtmvtolt  DATE; -- data de envio para protesto
      
      rw_crapcob_ret COBR0007.cr_crapcob%ROWTYPE;
      rw_crapcop     COBR0007.cr_crapcop%ROWTYPE;
      rw_crapass     COBR0007.cr_crapass%ROWTYPE;
      rw_crapsab     COBR0007.cr_crapsab%ROWTYPE;
      rw_crapcre     COBR0007.cr_crapcre%ROWTYPE;
      rw_craprem     COBR0007.cr_craprem%ROWTYPE;
      rw_crapcco     COBR0007.cr_crapcco%ROWTYPE;
      
      vr_rowid_ret ROWID;
      --Variaveis de erro
      vr_des_erro VARCHAR2(4000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      vr_cdmotivo VARCHAR2(10);
      --Ch REQ0011728
      vr_dsparame      VARCHAR2(4000);
      
      vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
      vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;      
      
      PROCEDURE pc_nao_efetuar_protesto IS
        PRAGMA AUTONOMOUS_TRANSACTION;      
    BEGIN
        -- se a instrução de protesto for automatica        
        -- sistema deverá cancelar a instrução automática de protesto e retornar um erro
        IF pr_cdoperad = '1' THEN             
          -- 
          -- atualizar boleto, cancelando a inst autom de protesto
          BEGIN
            UPDATE crapcob SET crapcob.flgdprot = 0,
                               crapcob.qtdiaprt = 0,
                               crapcob.dsdinstr = ' ',
                               crapcob.insrvprt = 0,
                               crapcob.dtbloque = NULL,
                               crapcob.insitcrt = 0,
                               crapcob.dtsitcrt = NULL
            WHERE crapcob.rowid = rw_crapcob_ret.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

              vr_cdcritic := 1035;  --Erro ao atualizar crapcob 
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                             ' flgdprot:0'||
                             ', qtdiaprt:0'||
                             ', dsdinstr:NULL'||
                             ', insrvprt:0'||
                             ', dtbloque:NULL'||
                             ', insitcrt:0'||
                             ', dtsitcrt:NULL'||
                             ' com rowid:'||rw_crapcob_ret.rowid||
                             '. '||sqlerrm;
              RAISE vr_exc_erro;
          END;

          --Cria log cobranca
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob_ret.rowid   --ROWID da Cobranca
                                       ,pr_cdoperad => pr_cdoperad   --Operador
                                       ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                       ,pr_dsmensag => 'CEP do pagador incorreto. Instr Automatica de Protesto cancelada.'   --Descricao Mensagem
                                       ,pr_des_erro => vr_des_erro   --Indicador erro
                                       ,pr_dscritic => vr_dscritic); --Descricao erro
          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;

          --                       
        ELSE -- se foi o cooperado ou o operador que comandou o protesto
          --
          --Cria log cobranca
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob_ret.rowid   --ROWID da Cobranca
                                       ,pr_cdoperad => pr_cdoperad   --Operador
                                       ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                       ,pr_dsmensag => 'CEP do pagador incorreto. Instr de Protesto nao efetuada.'   --Descricao Mensagem
                                       ,pr_des_erro => vr_des_erro   --Indicador erro
                                       ,pr_dscritic => vr_dscritic); --Descricao erro
          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;            
          --                       
        END IF;
          
        --Prepara retorno cooperado
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                           ,pr_cdocorre => 26  -- Instrucao Rejeitada --Codigo Ocorrencia
                                           ,pr_cdmotivo => 'NP' -- 'Boleto nao protesto devido ao CEP do pagador incorreto' --Codigo Motivo
                                           ,pr_vltarifa => 0
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                           ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                           ,pr_nrremass => pr_nrremass --Numero Remessa
                                           ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                           ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;                      
          
        -- autonomous transaction
        COMMIT;        
      END;
                 
    BEGIN
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar');

      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                    ||', pr_nrdconta:'||pr_nrdconta
                    ||', pr_nrcnvcob:'||pr_nrcnvcob
                    ||', pr_nrdocmto:'||pr_nrdocmto
                    ||', pr_cdocorre:'||pr_cdocorre
                    ||', pr_cdtpinsc:'||pr_cdtpinsc
                    ||', pr_dtmvtolt:'||pr_dtmvtolt
                    ||', pr_cdoperad:'||pr_cdoperad
                    ||', pr_nrremass:'||pr_nrremass;

      --Verificar cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      -- Processo de Validacao Recusas Padrao 
      COBR0007.pc_efetua_val_recusa_padrao (pr_cdcooper => pr_cdcooper    --Codigo Cooperativa
                                           ,pr_nrdconta => pr_nrdconta    --Numero da Conta
                                           ,pr_nrcnvcob => pr_nrcnvcob    --Numero Convenio
                                           ,pr_nrdocmto => pr_nrdocmto    --Numero Documento
                                           ,pr_dtmvtolt => pr_dtmvtolt    --Data Movimento
                                           ,pr_cdoperad => pr_cdoperad    --Codigo Operador
                                           ,pr_cdinstru => '09' -- Protestar --Codigo Instrucao
                                           ,pr_nrremass => pr_nrremass    --Numero da Remessa
                                           ,pr_rw_crapcob => rw_crapcob_ret --Registro de Cobranca de Recusa
                                           ,pr_cdcritic => vr_cdcritic    --Codigo Critica
                                           ,pr_dscritic => vr_dscritic);  --Descricao critica

      --Se ocorrer Erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar');

      IF rw_crapcob_ret.cdbandoc  = 85 AND
         rw_crapcob_ret.flgregis  = 1 AND
         rw_crapcob_ret.flgcbdda  = 1 AND
         rw_crapcob_ret.insitpro <= 2 THEN
         --Não existia o vr_cdcritic nesse caso, porem, setando vr_cdcritic segue a mesma
         --regra do retorno de uma chama de rotina, por exemplo, COBR0007.pc_efetua_val_recusa_padrao
         --REQ0011728 - inclusao vr_cdcritic
         vr_cdcritic := 1180;
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Titulo em processo de registro. Favor aguardar
        --Retornar
        RAISE vr_exc_erro;
      END IF;
      ------ VALIDACOES PARA RECUSAR ------

      --- Verificar se possui SERASA --- 
      IF COBR0007.fn_flserasa(rw_crapcob_ret.flserasa,
                              rw_crapcob_ret.qtdianeg,
                              rw_crapcob_ret.inserasa,
															rw_crapcob_ret.dtvencto,
															pr_dtmvtolt) THEN
        -- Verificar situacao no Serasa
        --Não existia o vr_cdcritic nesse caso, porem, setando vr_cdcritic segue a mesma
        --regra do retorno de uma chama de rotina, por exemplo, COBR0007.pc_efetua_val_recusa_padrao
        --REQ0011728 - inclusao vr_cdcritic
        vr_cdcritic := 1298;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Titulo nao pode ser protestado

        IF rw_crapcob_ret.inserasa IN (1,2) THEN -- 1-Pendente de envio, 2-Solicitacao Enviada
          vr_dscritic := vr_dscritic || ' - Solicitacao de inclusao enviada a Serasa.';
        ELSIF rw_crapcob_ret.inserasa IN (3,4) THEN -- 3-Pendente de envio Cancel, 2-Solicitacao Cancel Enviada
          vr_dscritic := vr_dscritic || ' - Solicitacao de cancelamento enviada a Serasa.';      
        ELSIF rw_crapcob_ret.inserasa = 5 THEN -- Negativado
          vr_dscritic := vr_dscritic || ' - Boleto ja negativado na Serasa.';
        ELSIF rw_crapcob_ret.inserasa = 7 THEN -- Acao Judicial
          vr_dscritic := vr_dscritic || ' - Boleto ja negativado na Serasa (Acao Judicial).';
        ELSE 
          vr_dscritic := vr_dscritic || ' - Titulo possui instrucao de negativacao Serasa';
        END IF;
        --Retornar
        RAISE vr_exc_erro;
      END IF;

      --- Titulo ainda nao venceu ---
      IF rw_crapcob_ret.dtvencto >= SYSDATE THEN
        --Prepara retorno cooperado
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                           ,pr_cdocorre => 26  -- Instrucao Rejeitada  --Codigo Ocorrencia
                                           ,pr_cdmotivo => '39' -- 'Pedido de Protesto Nao Permitido para o Titulo'  --Codigo Motivo
                                           ,pr_vltarifa => 0
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                           ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                           ,pr_nrremass => pr_nrremass --Numero Remessa
                                           ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                           ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar');
        --Não existia o vr_cdcritic nesse caso, porem, setando vr_cdcritic segue a mesma
        --regra do retorno de uma chama de rotina, por exemplo, COBR0007.pc_efetua_val_recusa_padrao
        --REQ0011728 - inclusao vr_cdcritic
        --comentado por enquanto vr_cdcritic := 1299;
        vr_dscritic := gene0001.fn_busca_critica(1299); --Boleto a Vencer - Protesto nao efetuado
        --Retornar
        RAISE vr_exc_erro;
      END IF;

      --- Titulo nao ultrapassou data Instrucao Automatica de Protesto ---
      IF  rw_crapcob_ret.flgdprot = 1 AND
        ((rw_crapcob_ret.dtvencto + rw_crapcob_ret.qtdiaprt) > SYSDATE) THEN
        --Prepara retorno cooperado
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                           ,pr_cdocorre => 26  -- Instrucao Rejeitada --Codigo Ocorrencia
                                           ,pr_cdmotivo => '39' -- 'Pedido de Protesto Nao Permitido para o Titulo' --Codigo Motivo
                                           ,pr_vltarifa => 0
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                           ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                           ,pr_nrremass => pr_nrremass --Numero Remessa
                                           ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                           ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar');
        --Não existia o vr_cdcritic nesse caso, porem, setando vr_cdcritic segue a mesma
        --regra do retorno de uma chama de rotina, por exemplo, COBR0007.pc_efetua_val_recusa_padrao
        --REQ0011728 - inclusao vr_cdcritic
        --comentado por enquanto vr_cdcritic := 1300;
        vr_dscritic := gene0001.fn_busca_critica(1300); --Boleto nao ultrapassou data de Instr. Autom. de Protesto - Protesto nao efetuado
        --Retornar
        RAISE vr_exc_erro;
      END IF;

      -- Titulos com Remessa a Cartorio ou Em Cartorio 
      CASE rw_crapcob_ret.insitcrt
        WHEN 1 THEN
         --Não existia o vr_cdcritic nesse caso, porem, setando vr_cdcritic segue a mesma
         --regra do retorno de uma chama de rotina, por exemplo, COBR0007.pc_efetua_val_recusa_padrao
         --REQ0011728 - inclusao vr_cdcritic
          vr_cdcritic := 1301; 
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Boleto c/ instrucao de protesto - Aguarde confirmacao do cartorio - Protesto nao efetuado
          RAISE vr_exc_erro;
        WHEN 2 THEN
          vr_cdcritic := 1302; 
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Boleto enviado a cartorio - Aguarde confirmacao do cartorio - Protesto nao efetuado
          RAISE vr_exc_erro;
        WHEN 3 THEN
          vr_cdcritic := 1303;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Boleto em Cartorio - Protesto nao efetuado
          RAISE vr_exc_erro;
        ELSE NULL;
      END CASE;

      --Verificar Conta Associado
      OPEN cr_crapass(pr_cdcooper => rw_crapcob_ret.cdcooper
                     ,pr_nrdconta => rw_crapcob_ret.nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      --Se nao encontrou associado
      IF cr_crapass%NOTFOUND THEN
        vr_cdcritic := 9;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Associado nao cadastrado
        --Fechar Cursor
        CLOSE cr_crapass;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;

      -- Se pessoa for fisica, nao protestar 
      IF rw_crapass.inpessoa = 1 THEN
        --Prepara retorno cooperado
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                           ,pr_cdocorre => 26  -- Instrucao Rejeitada  --Codigo Ocorrencia
                                           ,pr_cdmotivo => '39' -- 'Pedido de Protesto Nao Permitido para o Titulo' --Codigo Motivo
                                           ,pr_vltarifa => 0
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                           ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                           ,pr_nrremass => pr_nrremass --Numero Remessa
                                           ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                           ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar');
        --Não existia o vr_cdcritic nesse caso, porem, setando vr_cdcritic segue a mesma
        --regra do retorno de uma chama de rotina, por exemplo, COBR0007.pc_efetua_val_recusa_padrao
        --REQ0011728 - inclusao vr_cdcritic
        --comentado por enquanto -- vr_cdcritic := 1304;
        vr_dscritic := gene0001.fn_busca_critica(1304); --Instrucao nao permitida para Pessoa Fisica
        --Retornar
        RAISE vr_exc_erro;
      END IF;
      -- Verifica se ja existe Instrucao de "Protestar" 
      OPEN cr_crapcre (pr_cdcooper => pr_cdcooper
                      ,pr_nrcnvcob => pr_nrcnvcob
                      ,pr_dtmvtolt => pr_dtmvtolt
                      ,pr_intipmvt => 1);
      --Proximo registro
      FETCH cr_crapcre INTO rw_crapcre;

      --Se Encontrou
      IF cr_crapcre%FOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcre;
        --Selecionar remessa
        OPEN cr_craprem (pr_cdcooper => rw_crapcob_ret.cdcooper
                        ,pr_nrcnvcob => rw_crapcob_ret.nrcnvcob
                        ,pr_nrdconta => rw_crapcob_ret.nrdconta
                        ,pr_nrdocmto => rw_crapcob_ret.nrdocmto
                        ,pr_cdocorre => 9
                        ,pr_dtaltera => pr_dtmvtolt);
        FETCH cr_craprem INTO rw_craprem;
        --Se Encontrou
        IF cr_craprem%FOUND THEN
          --Fechar Cursor
          CLOSE cr_craprem;
          --Não existia o vr_cdcritic nesse caso, porem, setando vr_cdcritic segue a mesma
          --regra do retorno de uma chama de rotina, por exemplo, COBR0007.pc_efetua_val_recusa_padrao
          --REQ0011728 - inclusao vr_cdcritic
          vr_cdcritic := 1305; 
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Instrucao de Protesto ja efetuada - Protesto nao efetuado
          --Retornar
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        IF cr_craprem%ISOPEN THEN
          CLOSE cr_craprem;
        END IF;
      END IF;
      --Fechar Cursor
      IF cr_crapcre%ISOPEN THEN
        CLOSE cr_crapcre;
      END IF;
      -- Validar parametro de tela 
      IF rw_crapcob_ret.cddespec NOT IN (1,2) THEN
        --Prepara retorno cooperado
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                           ,pr_cdocorre => 26  -- Instrucao Rejeitada --Codigo Ocorrencia
                                           ,pr_cdmotivo => '39' -- 'Pedido de Protesto Nao Permitido para o Titulo' --Codigo Motivo
                                           ,pr_vltarifa => 0
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                           ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                           ,pr_nrremass => pr_nrremass --Numero Remessa
                                           ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                           ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar');
        --Não existia o vr_cdcritic nesse caso, porem, setando vr_cdcritic segue a mesma
        --regra do retorno de uma chama de rotina, por exemplo, COBR0007.pc_efetua_val_recusa_padrao
        --REQ0011728 - inclusao vr_cdcritic
        --comentado por enquanto -- vr_cdcritic := 1306;
        vr_dscritic := gene0001.fn_busca_critica(1306); --Especie Docto diferente de DM e DS - Protesto nao efetuado
        --Retornar
        RAISE vr_exc_erro;
      END IF;
      ---- Validacao para nao executante de protesto ----
      OPEN cr_crapsab (pr_cdcooper => rw_crapcob_ret.cdcooper
                      ,pr_nrdconta => rw_crapcob_ret.nrdconta
                      ,pr_nrinssac => rw_crapcob_ret.nrinssac);
      --Posicionar primeiro registro
      FETCH cr_crapsab INTO rw_crapsab;
      --Se nao encontrou
      IF cr_crapsab%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapsab;
        --Não existia o vr_cdcritic nesse caso, porem, setando vr_cdcritic segue a mesma
        --regra do retorno de uma chama de rotina, por exemplo, COBR0007.pc_efetua_val_recusa_padrao
        --REQ0011728 - inclusao vr_cdcritic
        vr_cdcritic := 1187;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Pagador nao encontrado
        --Retornar
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapsab;
      
      --Selecionar cadastro convenio
      OPEN cr_crapcco (pr_cdcooper => rw_crapcob_ret.cdcooper
                      ,pr_nrconven => rw_crapcob_ret.nrcnvcob);
      --Proximo registro
      FETCH cr_crapcco INTO rw_crapcco;
      CLOSE cr_crapcco;      
      
      /*Rafael Ferreira (Mouts) - INC0022229
      Conforme informado por Deise Carina Tonn da area de Negócio, esta validação não é mais necessária
      pois agora Todas as cidades podem ter protesto*/
      /*IF rw_crapcco.insrvprt = 2 THEN -- BB
      --Selecionar pracas nao executantes de processo
      OPEN cr_crappnp (pr_nmextcid => rw_crapsab.nmcidsac
                      ,pr_cduflogr => rw_crapsab.cdufsaca);
      --Posicionar no proximo registro
      FETCH cr_crappnp INTO rw_crappnp;
      --Se encontrar
      IF cr_crappnp%FOUND THEN
        --Fechar Cursor
        CLOSE cr_crappnp;
        --Prepara retorno cooperado
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                           ,pr_cdocorre => 26  -- Instrucao Rejeitada --Codigo Ocorrencia
                                           ,pr_cdmotivo => '39' -- 'Pedido de Protesto Nao Permitido para o Titulo' --Codigo Motivo
                                           ,pr_vltarifa => 0
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                           ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                           ,pr_nrremass => pr_nrremass --Numero Remessa
                                           ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                           ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar');
        --Não existia o vr_cdcritic nesse caso, porem, setando vr_cdcritic segue a mesma
        --regra do retorno de uma chama de rotina, por exemplo, COBR0007.pc_efetua_val_recusa_padrao
        --REQ0011728 - inclusao vr_cdcritic
        --comentado por enquanto -- vr_cdcritic := 1307; 
        vr_dscritic := gene0001.fn_busca_critica(1307); --Praca nao executante de protesto - Instrucao nao efetuada
        --Retornar
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_crappnp%ISOPEN THEN
        CLOSE cr_crappnp;
      END IF;
      END IF;*/
      
      IF rw_crapcco.insrvprt = 1 THEN -- Serviço de Protesto IEPTB
        
        -- Verificar se o CEP existe nos correios
        OPEN cr_cep (pr_nrceplog => rw_crapsab.nrcepsac);
        FETCH cr_cep INTO rw_cep;
        CLOSE cr_cep;
        
        -- se o CEP não existir, retornar erro
        IF rw_cep.nrceplog IS NULL THEN

          -- rotina autonomous transaction
          pc_nao_efetuar_protesto;          
                    
          -- Inclui nome do modulo logado 
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar');
          vr_cdcritic := 1463;
          vr_dscritic := gene0001.fn_busca_critica(1463); -- CEP do pagador incorreto. Favor atualizar o endereço do pagador e comandar novamente.
          --Retornar
          RAISE vr_exc_erro;          
        END IF;
        
      END IF;
      
      -- tratamento para titulos migrados 
      IF rw_crapcob_ret.flgregis = 1 AND rw_crapcob_ret.cdbandoc = 001 THEN
        --Selecionar cadastro convenio
        OPEN cr_crapcco (pr_cdcooper => rw_crapcob_ret.cdcooper
                        ,pr_nrconven => rw_crapcob_ret.nrcnvcob);
        --Proximo registro
        FETCH cr_crapcco INTO rw_crapcco;
        --Se encontrou
        IF cr_crapcco%FOUND AND rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
          --Fechar Cursor
          CLOSE cr_crapcco;
          --Protesta titulo Migrado
          COBR0007.pc_inst_titulo_migrado (pr_idregcob => rw_crapcob_ret --Rowtype da Cobranca
                                          ,pr_dsdinstr => 'Protesto' --Descricao da Instrucao
                                          ,pr_dtaltvct => NULL       --Data Alteracao Vencimento
                                          ,pr_vlaltabt => 0          --Valor Alterado Abatimento
                                          ,pr_nrdctabb => rw_crapcco.nrdctabb --Numero da Conta BB
                                          ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                          ,pr_dscritic => vr_dscritic); --Descricao Critica
          --Se Ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar');
          --Não existia o vr_cdcritic nesse caso, porem, setando vr_cdcritic segue a mesma
          --regra do retorno de uma chama de rotina, por exemplo, COBR0007.pc_efetua_val_recusa_padrao
          --REQ0011728 - inclusao vr_cdcritic
          --comentado por enquanto -- vr_cdcritic := 1308; 
          vr_dscritic := gene0001.fn_busca_critica(1308); --Solicitacao de protesto de titulo migrado. Aguarde confirmacao no proximo dia util
          --Retornar
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        IF cr_crapcco%ISOPEN THEN
          CLOSE cr_crapcco;
        END IF;
      END IF;

      ----- FIM - VALIDACOES PARA RECUSAR -----
      IF rw_crapcob_ret.cdbandoc = 1 THEN
        ---- LOG de Processo ----
        --Cria log cobranca
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob_ret.rowid   --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                     ,pr_dsmensag => 'Protestar'   --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro   --Indicador erro
                                     ,pr_dscritic => vr_dscritic); --Descricao erro
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar');
        --Preparar remessa banco
        PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob_ret.cdcooper --Cooperativa
                                       ,pr_nrcnvcob => rw_crapcob_ret.nrcnvcob --Numero Convenio
                                       ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                       ,pr_cdoperad => pr_cdoperad --Codigo Operador
									   ,pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                       ,pr_nrremret => vr_nrremret --Numero Remessa
                                       ,pr_rowid_ret => vr_rowid_ret --ROWID Remessa Retorno
                                       ,pr_nrseqreg => vr_nrseqreg --Numero Sequencial registro
                                       ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                       ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar');
        --Incrementar sequencial
        vr_nrseqreg:= Nvl(vr_nrseqreg,0) + 1;
        --Criar tabela Remessa
        PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                     ,pr_nrremret => vr_nrremret          --Numero Remessa
                                     ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                     ,pr_cdocorre => pr_cdocorre          --Codigo Ocorrencia
                                     ,pr_cdmotivo => NULL                 --Codigo Motivo
                                     ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                     ,pr_vlabatim => 0                    --Valor Abatimento
                                     ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                     ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                     ,pr_dscritic => vr_dscritic);        --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar');
      ELSIF rw_crapcob_ret.cdbandoc = 85 THEN
        -- Verifica qual serviço de protesto está sendo utilizado
        OPEN cr_crapcco (pr_cdcooper => rw_crapcob_ret.cdcooper
                        ,pr_nrconven => rw_crapcob_ret.nrcnvcob);
        --Proximo registro
        FETCH cr_crapcco INTO rw_crapcco;
        CLOSE cr_crapcco;
        
        IF rw_crapcco.insrvprt = 2 THEN -- BB
        --Criar tabela Remessa
        COBR0007.pc_enviar_titulo_protesto (pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                           ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                           ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                           ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                           ,pr_dscritic => vr_dscritic);        --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar');
          --
        ELSIF rw_crapcco.insrvprt = 1 THEN -- IEPTB

          -- utilizar a data do movimento específica para protesto          
          vr_dtmvtolt := cobr0011.fn_busca_dtmvtolt(pr_cdcooper => pr_cdcooper);          
          
          -- Preparar remessa banco
          PAGA0001.pc_prep_remessa_banco(pr_cdcooper => rw_crapcob_ret.cdcooper --Cooperativa
                                        ,pr_nrcnvcob => rw_crapcob_ret.nrcnvcob --Numero Convenio
                                        ,pr_dtmvtolt => vr_dtmvtolt  --Data Movimento
                                        ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                        ,pr_idregcob => '0'
                                        ,pr_nrremret => vr_nrremret --Numero Remessa
                                        ,pr_rowid_ret => vr_rowid_ret --ROWID Remessa Retorno
                                        ,pr_nrseqreg => vr_nrseqreg --Numero Sequencial registro
                                        ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                        ,pr_dscritic => vr_dscritic --Descricao Critica
                                        );
          -- Se Ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levantar Excecao
            RAISE vr_exc_erro;
            --
          END IF;
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar');
          --Incrementar sequencial
          vr_nrseqreg:= Nvl(vr_nrseqreg,0) + 1;
          --Criar tabela Remessa
          PAGA0001.pc_cria_tab_remessa(pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                      ,pr_nrremret => vr_nrremret          --Numero Remessa
                                      ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                      ,pr_cdocorre => pr_cdocorre          --Codigo Ocorrencia
                                      ,pr_cdmotivo => NULL                 --Codigo Motivo
                                      ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                      ,pr_vlabatim => 0                    --Valor Abatimento
                                      ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                      ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                      ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                      ,pr_dscritic => vr_dscritic          --Descricao Critica
                                      );
          --Se Ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
            --
          END IF;
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar');
          --
          BEGIN                      
            --
            UPDATE crapcob
               SET crapcob.insitcrt = 1 -- Com instrução de protesto
                  ,crapcob.dtbloque = pr_dtmvtolt
                  ,crapcob.dtsitcrt = pr_dtmvtolt
                  ,crapcob.insrvprt = rw_crapcco.insrvprt
             WHERE crapcob.rowid = rw_crapcob_ret.rowid;
             
            --Cria log cobranca
            PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob_ret.rowid   --ROWID da Cobranca
                                         ,pr_cdoperad => pr_cdoperad   --Operador
                                         ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                         ,pr_dsmensag => 'Confirmacao Receb Instr de Protesto'   --Descricao Mensagem
                                         ,pr_des_erro => vr_des_erro   --Indicador erro
                                         ,pr_dscritic => vr_dscritic); --Descricao erro
            --Se ocorreu erro
            IF vr_des_erro = 'NOK' THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;

            IF rw_crapcco.insrvprt = 1 THEN -- IEPTB
              --
              IF vr_dtmvtolt <> trunc(SYSDATE) THEN
                --Cria log cobranca
                PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob_ret.rowid   --ROWID da Cobranca
                                             ,pr_cdoperad => pr_cdoperad   --Operador
                                             ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                             ,pr_dsmensag => 'Instr de Protesto agendada para ' || to_char(vr_dtmvtolt,'DD/MM/RRRR')   --Descricao Mensagem
                                             ,pr_des_erro => vr_des_erro   --Indicador erro
                                             ,pr_dscritic => vr_dscritic); --Descricao erro
                --Se ocorreu erro
                IF vr_des_erro = 'NOK' THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
            END IF;
                --                 
              END IF;
              --
            END IF;

            -- enviar instrucao de bloqueio do boleto pra CIP            
            DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob_ret.rowid      --ROWID da Cobranca
                                             ,pr_tpoperad => 'A'                        --Tipo Operacao
                                             ,pr_tpdbaixa => ' '                        --Tipo de Baixa
                                             ,pr_dtvencto => rw_crapcob_ret.dtvencto    --Data Vencimento
                                             ,pr_vldescto => rw_crapcob_ret.vldescto    --Valor Desconto
                                             ,pr_vlabatim => rw_crapcob_ret.vlabatim    --Valor Abatimento
                                             ,pr_flgdprot => rw_crapcob_ret.flgdprot    --Flag Protesto
                                             ,pr_tab_remessa_dda => vr_tab_remessa_dda  --tabela remessa
                                             ,pr_tab_retorno_dda => vr_tab_retorno_dda  --Tabela memoria retorno DDA
                                             ,pr_cdcritic        => vr_cdcritic           --Codigo Critica
                                             ,pr_dscritic        => vr_dscritic);         --Descricao Critica
            --Se ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            
            -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar');
            --
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

              vr_cdcritic := 1035;  --Erro ao atualizar status na crapcob
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                             ' insitcrt:1'||
                             ', dtbloque:'||pr_dtmvtolt||
                             ', dtsitcrt:'||pr_dtmvtolt||
                             ', insrvprt:'||rw_crapcco.insrvprt||
                             ' com rowid:'||rw_crapcob_ret.rowid||
                             '. '||sqlerrm;
          END;
          --
        END IF;
        
        IF pr_cdoperad = '1' THEN
          vr_cdmotivo := 'H2'; -- confirmação do protesto automático;
        ELSE
          vr_cdmotivo := 'H1'; -- confirmação de solicitacao de protesto pelo cooperado;
        END IF;          
        
        --Prepara retorno cooperado
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                           ,pr_cdocorre => 19                   --Codigo Ocorrencia
                                           ,pr_cdmotivo => vr_cdmotivo          --Codigo Motivo
                                           ,pr_vltarifa => 0                    --Valor Tarifa
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl  --Banco centralizador
                                           ,pr_cdagectl => rw_crapcop.cdagectl  --Agencia Centralizadora
                                           ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                           ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                           ,pr_nrremass => pr_nrremass          --Numero Remessa
                                           ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                           ,pr_dscritic => vr_dscritic);        --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar');
      END IF;
      
        --Montar Indice para lancamento tarifa
        vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                       lpad(pr_nrdconta,10,'0')||
                       lpad(pr_nrcnvcob,10,'0')||
                       lpad(19,10,'0')||
                       lpad('0',10,'0')||
                       lpad(pr_tab_lat_consolidada.Count+1,10,'0');
        -- Gerar registro Tarifa 
        pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
        pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
        pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
        pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
        pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
        pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 19;    -- 19 - Confirma Recebimento Instrucao de Protesto
      pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= vr_cdmotivo; 
        pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob_ret.vltitulo;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;

        --Grava tabela de log - Ch REQ0011728
        pc_gera_log(pr_cdcooper      => pr_cdcooper,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic||vr_dsparame,
                    pr_cdcriticidade => 1,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 1);
        -- Ajuste mensagem - 12/02/2019 - REQ0035813
        IF nvl(pr_cdcritic,0) IN ( 1197, 9999, 1034, 1035, 1036, 1037 ) THEN
          pr_cdcritic := 1224;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        ELSIF nvl(pr_cdcritic,0) = 0 AND
              SUBSTR(pr_dscritic, 1, 7 ) IN ( '1197 - ', '9999 - ', '1034 - ', '1035 - ', '1036 - ', '1037 - ' ) THEN
          pr_cdcritic := 1224;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_protestar. '||sqlerrm||vr_dsparame;

        --Grava tabela de log - Ch REQ0011728
        pc_gera_log(pr_cdcooper      => pr_cdcooper,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 2,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 2);

        pr_cdcritic := 1224; -- Ajuste mensagem - 12/02/2019 - REQ0035813
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END;
  END pc_inst_protestar;

  -- Procedure para retornar os dias úteis para o cancelamento
	PROCEDURE pc_calc_dias_cancel(pr_cdcooper IN  NUMBER
		                           ,pr_dtsitcrt IN  DATE
		                           ,pr_qtdias   IN  NUMBER
															 ,pr_dtlmtcnl OUT DATE
															 ,pr_dscritic OUT VARCHAR2
		                           ) IS
    --
		vr_x INTEGER;
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);
		--
	BEGIN
    -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_calc_dias_cancel');

    vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                  ||', pd_dtsitcrt:'||pr_dtsitcrt
                  ||', pr_qtdias:'||pr_qtdias;

		--
		pr_dtlmtcnl := pr_dtsitcrt;
		--
		FOR vr_x IN 1..pr_qtdias LOOP 
			pr_dtlmtcnl := pr_dtlmtcnl + 1;
	    
			pr_dtlmtcnl := cecred.gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
																											 ,pr_dtmvtolt  => pr_dtlmtcnl
																											 ,pr_tipo      => 'P'
																											 ,pr_feriado   => TRUE
																											 ,pr_excultdia => FALSE
																											 );
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_calc_dias_cancel');
		END LOOP;
		--
	EXCEPTION
		WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

      pr_dscritic := gene0001.fn_busca_critica(9999)||'COBR0007.pc_calc_dias_cancel. '||sqlerrm||vr_dsparame;
	END pc_calc_dias_cancel;

  -- Procedure para Cancelar o Protesto 085
  PROCEDURE pc_inst_cancel_protesto_85(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                      ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                      ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                      ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                      ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                      ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                      ,pr_idgerbai  IN NUMBER                --> Indica se deve gerar baixa ou não (0-Não, 1-Sim)
                                      ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                      ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ) IS
    -- ...........................................................................................
    --
    --  Programa : pc_inst_cancel_protesto_85
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Supero
    --  Data     : Fevereiro/2018                     Ultima atualizacao: 14/01/2019
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Cancelar o Protesto dos títulos do banco 085
    --
    --   Alteracao : 24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            Comentadas variáveis não utilizados
    --                            Em um momento não estava logando o retorno da cobr0006.pc_prep_retorno_cooper_90
    --                            Agora vai logar, mas sem parar a execução do programa
    --                            (Ana - Envolti - Ch. REQ0011728)
    --
    --   14/01/2019 - Enviar registro de desbloqueio do boleto para a CIP. (Cechet)
    --
    --   26/06/2019 - Parametros na chamada da procedure pc_inst_pedido_baixa_titulo estão com
    --                cdocorre e cdoperad com informações erradas. (INC0017772 - AJFink)
    --
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_cdcritic2  PLS_INTEGER;
    vr_dscritic2  VARCHAR2(4000);
    vr_des_erro   VARCHAR2(3);
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);

    --Controle de envio de registro de desbloqueio do boleto para a CIP
    vr_flgdesbl   BOOLEAN := FALSE;

    ------------------------------- CURSORES ---------------------------------    
    --Selecionar remessas
    CURSOR cr_craprem2 (pr_cdcooper IN craprem.cdcooper%type
                       ,pr_nrcnvcob IN craprem.nrcnvcob%type
                       ,pr_nrdconta IN craprem.nrdconta%type
                       ,pr_nrdocmto IN craprem.nrdocmto%type
--                       ,pr_cdmotivo IN craprem.cdmotivo%type
                       ,pr_cdocorre IN craprem.cdocorre%type
                       ,pr_dtaltera IN craprem.dtaltera%type) IS
      SELECT rem.dtaltera
            ,rem.cdcooper
            ,rem.cdocorre
            ,rem.nrdconta
            ,rem.nrdocmto
            ,rem.nrcnvcob
            ,rem.dtdprorr
            ,rem.vlabatim
            ,rem.rowid
        FROM craprem rem
       WHERE rem.cdcooper = pr_cdcooper
         AND rem.nrcnvcob = pr_nrcnvcob
         AND rem.nrdconta = pr_nrdconta
         AND rem.nrdocmto = pr_nrdocmto
--         AND rem.cdmotivo = pr_cdmotivo
         AND rem.cdocorre = pr_cdocorre
         AND rem.dtaltera = pr_dtaltera
       ORDER BY rem.progress_recid DESC;
    -- Registro de Remessa
    rw_craprem2   cr_craprem2%ROWTYPE;

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    -- Registro da Cooperativa
    rw_crapcop    COBR0007.cr_crapcop%ROWTYPE;
    -- Registro de Cobrança
    rw_crapcob    COBR0007.cr_crapcob%ROWTYPE;

    -- Variáveis comentadas por não serem utilizadas
/*
    -- Registro de Remessa
    rw_craprem    COBR0007.cr_craprem%ROWTYPE;
    -- Registro de retorno
    rw_crapret    COBR0007.cr_crapret%ROWTYPE;
    -- Registro de Cadastro de Cobranca
    rw_crapcco    COBR0007.cr_crapcco%ROWTYPE;
    vr_cdmotivo     crapret.cdmotivo%TYPE;

*/
    -- Registro de controle retorno titulos bancarios
    rw_crapcre    COBR0007.cr_crapcre%ROWTYPE;
    -- Registro de Data
    rw_crapdat    BTCH0001.cr_crapdat%ROWTYPE;

    --Tabelas de Memoria de Remessa
    vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
    vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
    
    vr_nrremret     INTEGER;
    vr_nrseqreg     INTEGER;
    vr_rowid_ret    ROWID;
    vr_index_lat    VARCHAR2(60);
    vr_dtmvtolt     DATE; -- data de envio para protesto

    -- Identificar se o boleto possui Negativacao Serasa
    vr_is_serasa    BOOLEAN;
    
    vr_qtdiacan     NUMBER;
    vr_cdocorre     craprem.cdocorre%TYPE;
    vr_dtmvtaux     DATE;
		vr_dtlmtcnl     DATE;
    vr_idlogerr     VARCHAR2(1) := 'S';

  BEGIN
    -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');

    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                  ||', pr_nrdconta:'||pr_nrdconta
                  ||', pr_nrcnvcob:'||pr_nrcnvcob
                  ||', pr_nrdocmto:'||pr_nrdocmto
                  ||', pr_cdocorre:'||pr_cdocorre
                  ||', pr_dtmvtolt:'||pr_dtmvtolt
                  ||', pr_cdoperad:'||pr_cdoperad
                  ||', pr_nrremass:'||pr_nrremass
                  ||', pr_idgerbai:'||pr_idgerbai;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
      
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;
    
    -- Buscar a data
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;    

    -- Processo de Validacao Recusas Padrao
    COBR0007.pc_efetua_val_recusa_padrao(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                        ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                        ,pr_nrcnvcob => pr_nrcnvcob   --> Numero Convenio
                                        ,pr_nrdocmto => pr_nrdocmto   --> Numero Documento
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Data Movimento
                                        ,pr_cdoperad => pr_cdoperad   --> Operador
                                        ,pr_cdinstru => '41'          --> Codigo Instrucao
                                        ,pr_nrremass => pr_nrremass   --> Numero da Remessa
                                        ,pr_rw_crapcob => rw_crapcob  --> Registro de Cobranca de Recusa
                                        ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                        ,pr_dscritic => vr_dscritic); --> Descricao da Critica
    
    --Se ocorrer Erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');

    IF rw_crapcob.cdbandoc = 085 AND
       rw_crapcob.flgregis = 1   AND 
       rw_crapcob.flgcbdda = 1   AND 
       rw_crapcob.insitpro <= 2  THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XA' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');

      -- Recusar a instrucao
      vr_cdcritic := 1180;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) --Titulo em processo de registro. Favor aguardar
                     ||' cdbandoc:'||rw_crapcob.cdbandoc
                     ||', flgregis:'||rw_crapcob.flgregis
                     ||', flgcbdda:'||rw_crapcob.flgcbdda
                     ||', insitpro:'||rw_crapcob.insitpro;
                     
      RAISE vr_exc_erro;
    END IF;

    -- Verificamos se o boleto possui Negativacao no Serasa
/*
    IF rw_crapcob.flserasa = 1 AND 
       rw_crapcob.qtdianeg > 0 THEN
*/       
    -- alterado if para utilizar a função fn_flserasa 
    -- PRB0041685  Roberto Holz - Mout´s / Alcemir Jr.  20/05/2019 
    IF COBR0007.fn_flserasa(rw_crapcob.flserasa,
														rw_crapcob.qtdianeg,
														rw_crapcob.inserasa,
														rw_crapcob.dtvencto,
														pr_dtmvtolt) THEN       
      -- Sera tratado como Negativacao Serasa
      vr_is_serasa := TRUE;
    ELSE 
      -- Sera tratado como Protesto
      vr_is_serasa := FALSE;
    END IF;

    -----  VALIDACOES PARA RECUSAR  -----
    -- Verificamos se o boleto possui Negativacao no Serasa
    IF vr_is_serasa THEN 
      -- Verificacoes para recusar Instrucao de Negativacao do Serasa
      IF rw_crapdat.dtmvtolt >= (rw_crapcob.dtvencto + rw_crapcob.qtdianeg) THEN
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'S1' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');

        -- Recusar a instrucao
        -- corrigido código de crítica, estava erroneamente 1180. (Roberto Holz - Mout´s 27/05/2019)
        vr_cdcritic := 1309;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) --Excedido prazo cancelamento da instrucao automatica de negativacao! Canc instr negativacao nao efetuado
                       ||' dtmvtolt:'||rw_crapdat.dtmvtolt
                       ||', dtvencto:'||rw_crapcob.dtvencto
                       ||', qtdianeg:'||rw_crapcob.qtdianeg;
        RAISE vr_exc_erro;        
      END IF;

      /* Verificar se foi enviado ao Serasa */
      IF  rw_crapcob.inserasa <> 0 THEN
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'S1' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');

        -- Recusar a instrucao
        -- corrigido código de crítica, estava erroneamente 1180. (Roberto Holz - Mout´s 27/05/2019)
        vr_cdcritic := 1310;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) --Titulo ja enviado para Negativacao! Canc instr negativacao nao efetuado
                       ||' inserasa:'||rw_crapcob.inserasa;
        RAISE vr_exc_erro;        
      END IF;
                
    ELSE -- Fim das validacoes de negativacao Serasa

      -- verificar se existe instrucao de sustacao caso o titulo
      -- tenha sido enviado pra cartorio (2) ou já em cartorio (3)
      IF rw_crapcob.insitcrt IN (2,3) THEN
        -- Verifica se ja existe lote de remessa do convenio
        IF rw_crapcob.insitcrt = 2 THEN -- se já foi enviado, verificar no dia seguinte
          vr_dtmvtaux := rw_crapdat.dtmvtopr;
        ELSE
          vr_dtmvtaux := pr_dtmvtolt;
        END IF;
        
        -- se já está em cartório, verificar se há instrução no dia
        OPEN cr_crapcre (pr_cdcooper => rw_crapcob.cdcooper
                        ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                        ,pr_dtmvtolt => vr_dtmvtaux
                        ,pr_intipmvt => 1);
        --Proximo registro
        FETCH cr_crapcre INTO rw_crapcre;              
        --Se Encontrou
        IF cr_crapcre%FOUND THEN
          --Fechar Cursor
          CLOSE cr_crapcre;			
          
          IF pr_idgerbai = 0 THEN
            vr_cdocorre := 11; -- sustar e manter
          ELSE
            vr_cdocorre := 10; -- sustar e baixar
          END IF;
          
          -- Verifica se ja existe Instrucao de "Sustar e baixar ou Sustar e manter"
          OPEN cr_craprem2 (pr_cdcooper => rw_crapcob.cdcooper
                           ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                           ,pr_nrdconta => rw_crapcob.nrdconta
                           ,pr_nrdocmto => rw_crapcob.nrdocmto
                           ,pr_cdocorre => vr_cdocorre
--                           ,pr_cdmotivo => NULL
                           ,pr_dtaltera => vr_dtmvtaux);
          FETCH cr_craprem2 INTO rw_craprem2;
          --Se Encontrou
          IF cr_craprem2%FOUND THEN
            --Fechar Cursor
            CLOSE cr_craprem2;
            -- Preparar Lote de Retorno Cooperado 
            COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                               ,pr_cdocorre => 26   -- Codigo Ocorrencia
                                               ,pr_cdmotivo => 'A7' -- Motivo
                                               ,pr_vltarifa => 0    -- valor da Tarifa
                                               ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                               ,pr_cdagectl => rw_crapcop.cdagectl
                                               ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                               ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                               ,pr_nrremass => pr_nrremass --Numero Remessa
                                               ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                               ,pr_dscritic => vr_dscritic); --Descricao Critica
            --Se Ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
            vr_cdcritic := 1311; 
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Instrucao de Cancelamento Protesto ja efetuada - Cancelamento Protesto nao efetuado
            --Retornar
            RAISE vr_exc_erro;
          END IF;
          --Fechar Cursor
          IF cr_craprem2%ISOPEN THEN
            CLOSE cr_craprem2;
          END IF;
        END IF;
      END IF;
      
      --Fechar Cursor
      IF cr_crapcre%ISOPEN THEN
        CLOSE cr_crapcre;
      END IF;    

      CASE rw_crapcob.insitcrt
        
        WHEN 0 THEN -- sem movimentacao cartoraria
          -- Titulo sem Instrucao Automatica de Protesto
          IF rw_crapcob.flgdprot = 0 AND rw_crapcob.qtdiaprt = 0 THEN
            -- Titulo ja se encontra na situacao Pretendida
            -- Gerar o retorno para o cooperado 
            COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                               ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                               ,pr_cdmotivo => 'A7' -- Motivo
                                               ,pr_vltarifa => 0    -- Valor da Tarifa  
                                               ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                               ,pr_cdagectl => rw_crapcop.cdagectl
                                               ,pr_dtmvtolt => pr_dtmvtolt
                                               ,pr_cdoperad => pr_cdoperad
                                               ,pr_nrremass => pr_nrremass
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
            -- Verifica se ocorreu erro durante a execucao
            IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');

            -- Recusar a instrucao
            vr_cdcritic := 1312;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Boleto sem Instrucao Automatica de Protesto - Cancelamento Protesto nao efetuado
            RAISE vr_exc_erro;
          END IF;
          
          -- Gerar o retorno para o cooperado 
          -- Cancelamento da instrucao automatica de protesto
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                             ,pr_cdocorre => 20   -- Confirmacao de inst de cancel de protesto
                                             ,pr_cdmotivo => 'C2' -- Canc da inst autom de protesto
                                             ,pr_vltarifa => 0    -- Valor da Tarifa  
                                             ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                             ,pr_cdagectl => rw_crapcop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_nrremass => pr_nrremass
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
          -- Verifica se ocorreu erro durante a execucao
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
          
          --Montar Indice para lancamento tarifa
          vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                         lpad(pr_nrdconta,10,'0')||
                         lpad(pr_nrcnvcob,10,'0')||
                         lpad(19,10,'0')||
                         lpad('0',10,'0')||
                         lpad(pr_tab_lat_consolidada.Count+1,10,'0');
          -- Gerar registro Tarifa 
          pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
          pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
          pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
          pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
          pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
          pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 20;    -- Confirmacao de cancelamento de protesto
          pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= 'C2';  -- cancelamento da inst autom de protesto
          pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;                                
          
          -- LOG de processo
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid  --ROWID da Cobranca
                                       ,pr_cdoperad => pr_cdoperad   --Operador
                                       ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                       ,pr_dsmensag => 'Cancelamento da Instr Automatica de Protesto' --Descricao Mensagem
                                       ,pr_des_erro => vr_des_erro   --Indicador erro
                                       ,pr_dscritic => vr_dscritic); --Descricao erro                              
          --Aqui não gravava log do erro de retorno da PAGA0001.
          --Agora vai logar, porém, sem parar a execução do programa
          --CH REQ0031757
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            pc_gera_log(pr_cdcooper      => pr_cdcooper,
                        pr_dstiplog      => 'E',
                        pr_dscritic      => vr_dscritic||vr_dsparame,
                        pr_cdcriticidade => 1,
                        pr_cdmensagem    => 0,
                        pr_ind_tipo_log  => 1);
          END IF;
          
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');

					-- Deve gerar baixa
					IF pr_idgerbai = 1 THEN
						--
						cobr0007.pc_inst_pedido_baixa_titulo(pr_idregcob            => rw_crapcob.rowid
                                                ,pr_cdocorre            => 2 -- Baixa  --INC0017772
																								,pr_dtmvtolt            => pr_dtmvtolt
                                                ,pr_cdoperad            => pr_cdoperad --INC0017772
																								,pr_nrremass            => pr_nrremass
																								,pr_tab_lat_consolidada => pr_tab_lat_consolidada
																								,pr_cdcritic            => vr_cdcritic
																								,pr_dscritic            => vr_dscritic
																								);
						 -- Verifica se ocorreu erro durante a execucao
						IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              vr_idlogerr := 'N';
							RAISE vr_exc_erro;
						END IF;
            -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
						--
					END IF;
					--
				WHEN 1 THEN -- c/ confirmacao de inst de protesto

          BEGIN            
            -- excluir inst de protestar
            DELETE FROM craprem
                  WHERE craprem.cdcooper = rw_crapcob.cdcooper
                    AND craprem.nrcnvcob = rw_crapcob.nrcnvcob
                    AND craprem.nrdconta = rw_crapcob.nrdconta
                    AND craprem.nrdocmto = rw_crapcob.nrdocmto
                    AND craprem.cdocorre = 9; -- Confirmar a ocorrência -- Revisar            
          EXCEPTION
            WHEN OTHERS THEN          
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

              vr_cdcritic := 1037;  --Erro ao excluir protesto de remessa
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'craprem:'||
                            'com cdcooper:'||rw_crapcob.cdcooper||
                            ', nrcnvcob:'||rw_crapcob.nrcnvcob||
                            ', nrdconta:'||rw_crapcob.nrdconta||
                            ', nrdocmto:'||rw_crapcob.nrdocmto||
                            ', cdocorre:9'||
                            '. '||sqlerrm;

              RAISE vr_exc_erro;                    
          END;        
          
          -- Gerar o retorno para o cooperado 
          -- Cancelamento do envio do titulo para protesto
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                             ,pr_cdocorre => 20   -- Confirmacao da inst de cancel de protesto
                                             ,pr_cdmotivo => 'E1' -- cancelamento do envio de protesto
                                             ,pr_vltarifa => 0    -- Valor da Tarifa  
                                             ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                             ,pr_cdagectl => rw_crapcop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_nrremass => pr_nrremass
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
          -- Verifica se ocorreu erro durante a execucao
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
          
          --Montar Indice para lancamento tarifa
          vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                         lpad(pr_nrdconta,10,'0')||
                         lpad(pr_nrcnvcob,10,'0')||
                         lpad(19,10,'0')||
                         lpad('0',10,'0')||
                         lpad(pr_tab_lat_consolidada.Count+1,10,'0');
          -- Gerar registro Tarifa 
          pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
          pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
          pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
          pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
          pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
          pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 20;    -- Confirmacao do cancel de protesto
          pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= 'E1';  -- Envio do cancelamento de protesto
          pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;                                      
          
          -- Deve gerar baixa
					IF pr_idgerbai = 1 THEN
						--
						cobr0007.pc_inst_pedido_baixa_titulo(pr_idregcob            => rw_crapcob.rowid
                                                ,pr_cdocorre            => 2 -- Baixa  --INC0017772
																								,pr_dtmvtolt            => pr_dtmvtolt
                                                ,pr_cdoperad            => pr_cdoperad --INC0017772
																								,pr_nrremass            => pr_nrremass
																								,pr_tab_lat_consolidada => pr_tab_lat_consolidada
																								,pr_cdcritic            => vr_cdcritic
																								,pr_dscritic            => vr_dscritic
																								);
						 -- Verifica se ocorreu erro durante a execucao
						IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
							RAISE vr_exc_erro;
						END IF;
            -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
						--
					END IF;
					--
				WHEN 2 THEN -- titulo enviado a cartorio          

          IF rw_crapcob.insrvprt = 1 THEN -- 0 nenhum; 1 ieptb; 2 bb
            vr_cdcritic := 1464;
            vr_dscritic := 'Título pendente de confirmação no cartório, tente no próximo dia útil.';
            RAISE vr_exc_erro;
          END IF;  

          -- utilizar a data do movimento específica para protesto          
          vr_dtmvtolt := cobr0011.fn_busca_dtmvtolt(pr_cdcooper => pr_cdcooper);          

          -- Registra Instrucao Alter Dados / Protesto
          -- gerar solicitacao de sustar protesto no dia seguinte
          PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                         ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                         ,pr_dtmvtolt => vr_dtmvtolt         --Data movimento
                                         ,pr_cdoperad => pr_cdoperad         --Codigo Operador
										                     ,pr_idregcob => '0'
                                         ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                         ,pr_rowid_ret => vr_rowid_ret       --ROWID Remessa Retorno
                                         ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                         ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                         ,pr_dscritic => vr_dscritic);       --Descricao Critica
          --Se ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');

          IF pr_idgerbai = 0 THEN
            vr_cdocorre := 11; -- sustar e manter
          ELSE
            vr_cdocorre := 10; -- sustar e baixar
          END IF;
          --Incrementar Sequencial
          vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;
          -- Criar tabela Remessa
          -- Sustar e Manter ou baixar
          PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                       ,pr_nrremret => vr_nrremret          --Numero Remessa
                                       ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                       ,pr_cdocorre => vr_cdocorre          --Codigo Ocorrencia
                                       ,pr_cdmotivo => NULL                 --Codigo Motivo
                                       ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                       ,pr_vlabatim => 0                    --Valor Abatimento
                                       ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                       ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                       ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);        --Descricao Critica
          --Se ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;                    
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
          
          -- Gerar o retorno para o cooperado 
          -- Cancelamento do envio do titulo para protesto
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                             ,pr_cdocorre => 20   -- Confirmacao de pedido de cancel de protesto
                                             ,pr_cdmotivo => 'E1' -- cancelamento do envio de protesto
                                             ,pr_vltarifa => 0    -- Valor da Tarifa  
                                             ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                             ,pr_cdagectl => rw_crapcop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_nrremass => pr_nrremass
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
          -- Verifica se ocorreu erro durante a execucao
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
          
          --Montar Indice para lancamento tarifa
          vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                         lpad(pr_nrdconta,10,'0')||
                         lpad(pr_nrcnvcob,10,'0')||
                         lpad(19,10,'0')||
                         lpad('0',10,'0')||
                         lpad(pr_tab_lat_consolidada.Count+1,10,'0');
          -- Gerar registro Tarifa 
          pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
          pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
          pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
          pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
          pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
          pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 20;    -- Confirmacao do cancel de protesto
          pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= 'E1';  -- Envio do cancelamento de protesto
          pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;                            
          
          -- LOG de processo
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid  --ROWID da Cobranca
                                       ,pr_cdoperad => pr_cdoperad   --Operador
                                       ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                       ,pr_dsmensag => 'Pedido de cancelamento de Protesto' --Descricao Mensagem
                                       ,pr_des_erro => vr_des_erro   --Indicador erro
                                       ,pr_dscritic => vr_dscritic); --Descricao erro                    

          --Aqui não gravava log do erro de retorno da PAGA0001.
          --Agora vai logar, porém, sem parar a execução do programa
          --CH REQ0031757
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            pc_gera_log(pr_cdcooper      => pr_cdcooper,
                        pr_dstiplog      => 'E',
                        pr_dscritic      => vr_dscritic||vr_dsparame,
                        pr_cdcriticidade => 1,
                        pr_cdmensagem    => 0,
                        pr_ind_tipo_log  => 1);
          END IF;

          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
                    
        WHEN 3 THEN -- titulo com entrada em cartorio

          -- Verifica o prazo de cancelamento do protesto no cartório
          BEGIN
            --
            SELECT qtdias_cancelamento
              INTO vr_qtdiacan
              FROM tbcobran_param_protesto
             WHERE cdcooper = rw_crapcob.cdcooper;
            --
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

              vr_cdcritic := 1036;  --Erro ao buscar a qtd de dias limite de cancelamento
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'tbcobran_param_protesto '||
                            ' com cdcooper:'||rw_crapcob.cdcooper||
                            '. '||sqlerrm;

              RAISE vr_exc_erro;
          END;
          -- Calcula o prazo limite para cancelamento
					pc_calc_dias_cancel(pr_cdcooper => rw_crapcob.cdcooper -- IN
														 ,pr_dtsitcrt => rw_crapcob.dtsitcrt -- IN
														 ,pr_qtdias   => vr_qtdiacan         -- IN
														 ,pr_dtlmtcnl => vr_dtlmtcnl         -- OUT
														 ,pr_dscritic => vr_dscritic         -- OUT
														 );
					-- Verifica se ocorreu erro durante a execucao
					IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
						RAISE vr_exc_erro;
					END IF;
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
          --
          IF pr_dtmvtolt > vr_dtlmtcnl THEN
            -- Gerar o retorno para o cooperado 
            COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                               ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                               ,pr_cdmotivo => 'XM' -- Motivo -- Revisar
                                               ,pr_vltarifa => 0    -- Valor da Tarifa  
                                               ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                               ,pr_cdagectl => rw_crapcop.cdagectl
                                               ,pr_dtmvtolt => pr_dtmvtolt
                                               ,pr_cdoperad => pr_cdoperad
                                               ,pr_nrremass => pr_nrremass
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
            -- Verifica se ocorreu erro durante a execucao
            IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');

            -- Recusar a instrucao
            vr_dscritic := gene0001.fn_busca_critica(1313); --Prazo de cancelamento do protesto excedido - Cancelamento Protesto nao efetuado
            RAISE vr_exc_erro;
            --
          END IF;
        
          -- utilizar a data do movimento específica para protesto          
          vr_dtmvtolt := cobr0011.fn_busca_dtmvtolt(pr_cdcooper => pr_cdcooper);
        
          -- Registra Instrucao Alter Dados / Protesto
          -- gerar solicitacao de sustar protesto no dia seguinte
          PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                         ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                         ,pr_dtmvtolt => vr_dtmvtolt         --Data movimento
                                         ,pr_cdoperad => pr_cdoperad         --Codigo Operador
										                     ,pr_idregcob => '0'
                                         ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                         ,pr_rowid_ret => vr_rowid_ret       --ROWID Remessa Retorno
                                         ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                         ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                         ,pr_dscritic => vr_dscritic);       --Descricao Critica
          --Se ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');

          IF pr_idgerbai = 0 THEN
            vr_cdocorre := 11; -- sustar e manter
          ELSE
            vr_cdocorre := 10; -- sustar e baixar
						-- LOG de processo
						PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid  --ROWID da Cobranca
																				 ,pr_cdoperad => pr_cdoperad   --Operador
																				 ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
																				 ,pr_dsmensag => 'Instrução de Baixa - Aguardando cancelamento do Protesto' --Descricao Mensagem
																				 ,pr_des_erro => vr_des_erro   --Indicador erro
																				 ,pr_dscritic => vr_dscritic); --Descricao erro

            --Aqui não gravava log do erro de retorno da PAGA0001.
            --Agora vai logar, porém, sem parar a execução do programa
            --CH REQ0031757
            IF TRIM(vr_dscritic) IS NOT NULL THEN
              pc_gera_log(pr_cdcooper      => pr_cdcooper,
                          pr_dstiplog      => 'E',
                          pr_dscritic      => vr_dscritic||vr_dsparame,
                          pr_cdcriticidade => 1,
                          pr_cdmensagem    => 0,
                          pr_ind_tipo_log  => 1);
            END IF;

            -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
					  --
          END IF;
          --Incrementar Sequencial
          vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;
          -- Criar tabela Remessa
          -- Sustar e Manter ou baixar
          PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                       ,pr_nrremret => vr_nrremret          --Numero Remessa
                                       ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                       ,pr_cdocorre => vr_cdocorre          --Codigo Ocorrencia
                                       ,pr_cdmotivo => NULL                 --Codigo Motivo
                                       ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                       ,pr_vlabatim => 0                    --Valor Abatimento
                                       ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                       ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                       ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);        --Descricao Critica
          --Se ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
          
          -- Gerar o retorno para o cooperado 
          -- Cancelamento do envio do titulo para protesto
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                             ,pr_cdocorre => 20   -- Confirmacao de pedido de cancel de protesto
                                             ,pr_cdmotivo => 'E1' -- cancelamento do envio de protesto
                                             ,pr_vltarifa => 0    -- Valor da Tarifa  
                                             ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                             ,pr_cdagectl => rw_crapcop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_nrremass => pr_nrremass
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
          -- Verifica se ocorreu erro durante a execucao
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
          
          --Montar Indice para lancamento tarifa
          vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                         lpad(pr_nrdconta,10,'0')||
                         lpad(pr_nrcnvcob,10,'0')||
                         lpad(19,10,'0')||
                         lpad('0',10,'0')||
                         lpad(pr_tab_lat_consolidada.Count+1,10,'0');
          -- Gerar registro Tarifa 
          pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
          pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
          pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
          pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
          pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
          pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 20;    -- Confirmacao do cancel de protesto
          pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= 'E1';  -- Envio do cancelamento de protesto
          pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;                            
          
          -- LOG de processo
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid  --ROWID da Cobranca
                                       ,pr_cdoperad => pr_cdoperad   --Operador
                                       ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                       ,pr_dsmensag => 'Pedido de cancelamento de Protesto' --Descricao Mensagem
                                       ,pr_des_erro => vr_des_erro   --Indicador erro
                                       ,pr_dscritic => vr_dscritic); --Descricao erro

          --Aqui não gravava log do erro de retorno da PAGA0001.
          --Agora vai logar, porém, sem parar a execução do programa
          --CH REQ0031757
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            pc_gera_log(pr_cdcooper      => pr_cdcooper,
                        pr_dstiplog      => 'E',
                        pr_dscritic      => vr_dscritic||vr_dsparame,
                        pr_cdcriticidade => 1,
                        pr_cdmensagem    => 0,
                        pr_ind_tipo_log  => 1);
          END IF;
          
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
          
        WHEN 4 THEN -- titulo sustado

          -- Gerar o retorno para o cooperado 
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                             ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                             ,pr_cdmotivo => 'A7' -- Motivo
                                             ,pr_vltarifa => 0    -- Valor da Tarifa  
                                             ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                             ,pr_cdagectl => rw_crapcop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_nrremass => pr_nrremass
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
          -- Verifica se ocorreu erro durante a execucao
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
          
          -- Recusar a instrucao
          vr_cdcritic := 1314; 
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Boleto Sustado - Cancelamento Protesto nao efetuado
          RAISE vr_exc_erro;
					
					-- Deve gerar baixa
					IF pr_idgerbai = 1 THEN
						--
						cobr0007.pc_inst_pedido_baixa_titulo(pr_idregcob            => rw_crapcob.rowid
                                                ,pr_cdocorre            => 2 -- Baixa  --INC0017772
																								,pr_dtmvtolt            => pr_dtmvtolt
                                                ,pr_cdoperad            => pr_cdoperad --INC0017772
																								,pr_nrremass            => pr_nrremass
																								,pr_tab_lat_consolidada => pr_tab_lat_consolidada
																								,pr_cdcritic            => vr_cdcritic
																								,pr_dscritic            => vr_dscritic
																								);
						 -- Verifica se ocorreu erro durante a execucao
						IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
							RAISE vr_exc_erro;
						END IF;
            -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
						--
					END IF;

        WHEN 5 THEN -- titulo protestado

          -- Gerar o retorno para o cooperado 
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                             ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                             ,pr_cdmotivo => 'XP' -- Motivo
                                             ,pr_vltarifa => 0    -- Valor da Tarifa  
                                             ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                             ,pr_cdagectl => rw_crapcop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_nrremass => pr_nrremass
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
          -- Verifica se ocorreu erro durante a execucao
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
          
          -- Recusar a instrucao
          vr_cdcritic := 1315;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Boleto Protestado - Cancelamento Protesto nao efetuado
          RAISE vr_exc_erro;

      END CASE;        
      
    END IF; -- bloco se eh Serasa ou Protesto

    -- Verificar se nao eh Serasa
    IF NOT vr_is_serasa THEN 
      -- As informacoes de DDA e Titulos Migrados 
      -- sao apenas para Protesto
      IF rw_crapcob.flgcbdda = 1 AND
         rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN
        -- Executa procedimentos do DDA-JD 
        DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob.rowid         --ROWID da Cobranca
                                         ,pr_tpoperad  => 'A'                      --Tipo Operacao
                                         ,pr_tpdbaixa  => ' '                      --Tipo de Baixa
                                         ,pr_dtvencto  => rw_crapcob.dtvencto      --Data Vencimento
                                         ,pr_vldescto  => rw_crapcob.vldescto      --Valor Desconto
                                         ,pr_vlabatim  => rw_crapcob.vlabatim      --Valor Abatimento
                                         ,pr_flgdprot  => 0                        --Flag Protesto
                                         ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa
                                         ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela memoria retorno DDA
                                         ,pr_cdcritic  => vr_cdcritic2             --Codigo Critica
                                         ,pr_dscritic  => vr_dscritic2);           --Descricao Critica
        --Se ocorreu erro
        IF NVL(vr_cdcritic2,0) <> 0 OR TRIM(vr_dscritic2) IS NOT NULL THEN
          -- Gerar o retorno para o cooperado 
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                             ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                             ,pr_cdmotivo => 'XC' -- Motivo
                                             ,pr_vltarifa => 0    -- Valor da Tarifa  
                                             ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                             ,pr_cdagectl => rw_crapcop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_nrremass => pr_nrremass
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);

          --Aqui não logava o erro de retorno da cobr0006.pc_prep_retorno_cooper_90 e além disso, queimava 
          --as variáveis. Agora vai logar também erro da COBR0006, mas sem parar a execução
          -- Ch REQ0011728 daqui
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Se ocorreu erro
            pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                        pr_dstiplog      => 'E',
                        pr_dscritic      => vr_dscritic||vr_dsparame,
                        pr_cdcriticidade => 1,
                        pr_cdmensagem    => nvl(vr_cdcritic,0),
                        pr_ind_tipo_log  => 1);
          END IF;
          --Ch REQ0011728 até aqui
            
          vr_cdcritic := vr_cdcritic2;
          vr_dscritic := vr_dscritic2;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        
        -- Marcar como enviado o registro de desbloqueio do boleto para a CIP
        vr_flgdesbl := TRUE;
        
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
      END IF;
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
    END IF;

    --Se tem remesssa dda na tabela
    IF vr_tab_remessa_dda.COUNT > 0 THEN
      rw_crapcob.idopeleg:= vr_tab_remessa_dda(vr_tab_remessa_dda.LAST).idopeleg;
    END IF;

    IF vr_is_serasa THEN
      -- removido regra da negativacao serasa
      rw_crapcob.flserasa := 0;
      rw_crapcob.qtdianeg := 0;

      --Atualizar Cobranca
      BEGIN
        UPDATE crapcob SET crapcob.flserasa = rw_crapcob.flserasa,
                           crapcob.qtdianeg = rw_crapcob.qtdianeg
        WHERE crapcob.rowid = rw_crapcob.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

          vr_cdcritic := 1035;  --Erro ao atualizar crapcob (SERASA)
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                         ' flserasa:'||rw_crapcob.flserasa||
                         ', qtdianeg:'||rw_crapcob.qtdianeg||
                         ' com rowid:'||rw_crapcob.rowid||
                         '. '||sqlerrm;

          RAISE vr_exc_erro;
      END;

      -- LOG de processo
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid  --ROWID da Cobranca
                                   ,pr_cdoperad => pr_cdoperad   --Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                   ,pr_dsmensag => 'Cancel. Instrucao Negativacao' -- Descricao Mensagem
                                   ,pr_des_erro => vr_des_erro   --Indicador erro
                                   ,pr_dscritic => vr_dscritic); --Descricao erro
      --Se Ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Valida cdcritic e não tem esse retorno da paga0001 - manter assim
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
      
      IF rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN 
        -- Gerar o retorno para o cooperado 
        -- 94 - Confirmacao de Cancelamento Negativacao Serasa
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 94   -- Confirmacao de Cancelamento Negativacao Serasa
                                           ,pr_cdmotivo => 'S4' -- Motivo 
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
    
        --Montar Indice para lancamento tarifa
        vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                       lpad(pr_nrdconta,10,'0')||
                       lpad(pr_nrcnvcob,10,'0')||
                       lpad(19,10,'0')||
                       lpad('0',10,'0')||
                       lpad(pr_tab_lat_consolidada.Count+1,10,'0');
        -- Gerar registro Tarifa 
        pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
        pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
        pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
        pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
        pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
        pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 94;    -- 94 - Confirmacao de Cancelamento Negativacao Serasa
        pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= 'S4';  -- Motivo
        pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;
      END IF; -- FIM do IF cdbandoc = 85
      
      -- Fim das alteracoes do Serasa
    ELSE
      
      IF rw_crapcob.insitcrt IN (0,1) THEN
        -- atualizar status do boleto
        rw_crapcob.flgdprot := 0;
        rw_crapcob.qtdiaprt := 0;
        --
        IF rw_crapcob.insrvprt <> 1 THEN
          --
          rw_crapcob.insrvprt := 0;
          --
        END IF;
        --
        rw_crapcob.dtbloque := NULL;
        rw_crapcob.dsdinstr := REPLACE(rw_crapcob.dsdinstr, 
                                       '** Servico de protesto sera efetuado pelo Banco do Brasil **', '');
        --Atualizar Cobranca
        BEGIN
          UPDATE crapcob SET crapcob.flgdprot = rw_crapcob.flgdprot,
                             crapcob.qtdiaprt = rw_crapcob.qtdiaprt,
                             crapcob.dsdinstr = rw_crapcob.dsdinstr,
                             crapcob.idopeleg = rw_crapcob.idopeleg,
                             crapcob.insrvprt = rw_crapcob.insrvprt,
                             crapcob.dtbloque = rw_crapcob.dtbloque,
                             crapcob.insitcrt = 0,
                             crapcob.dtsitcrt = NULL
          WHERE crapcob.rowid = rw_crapcob.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

            vr_cdcritic := 1035;  --Erro ao atualizar crapcob 
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                           ' flgdprot:'||rw_crapcob.flgdprot||
                           ', qtdiaprt:'||rw_crapcob.qtdiaprt||
                           ', dsdinstr:'||rw_crapcob.dsdinstr||
                           ', idopeleg:'||rw_crapcob.idopeleg||
                           ', insrvprt:'||rw_crapcob.insrvprt||
                           ', dtbloque:'||rw_crapcob.dtbloque||
                           ', insitcrt:0'||
                           ', dtsitcrt:NULL'||
                           ' com rowid:'||rw_crapcob.rowid||
                           '. '||sqlerrm;
            RAISE vr_exc_erro;
        END;
        
        -- Se ainda não enviou registro de desbloqueio do boleto para a CIP
        IF vr_flgdesbl = FALSE THEN
        
        -- enviar registro de desbloqueio do boleto para a CIP            
        DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob.rowid      --ROWID da Cobranca
                                         ,pr_tpoperad => 'A'                        --Tipo Operacao
                                         ,pr_tpdbaixa => ' '                        --Tipo de Baixa
                                         ,pr_dtvencto => rw_crapcob.dtvencto    --Data Vencimento
                                         ,pr_vldescto => rw_crapcob.vldescto    --Valor Desconto
                                         ,pr_vlabatim => rw_crapcob.vlabatim    --Valor Abatimento
                                         ,pr_flgdprot => rw_crapcob.flgdprot    --Flag Protesto
                                         ,pr_tab_remessa_dda => vr_tab_remessa_dda  --tabela remessa
                                         ,pr_tab_retorno_dda => vr_tab_retorno_dda  --Tabela memoria retorno DDA
                                         ,pr_cdcritic        => vr_cdcritic           --Codigo Critica
                                         ,pr_dscritic        => vr_dscritic);         --Descricao Critica
        --Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        
        END IF;
        
        -- LOG de processo
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid  --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                     ,pr_dsmensag => 'Cancel. Instrucao Protesto' --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro   --Indicador erro
                                     ,pr_dscritic => vr_dscritic); --Descricao erro
        --Se Ocorreu erro
        --Valida cdcritic e não tem esse retorno da paga0001 - manter assim
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 30/08/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_prote_85');
          
      END IF;                
    --
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      --Grava tabela de log - Ch REQ0011728
      IF vr_idlogerr <> 'N' THEN
        pc_gera_log(pr_cdcooper      => pr_cdcooper,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic||vr_dsparame,
                    pr_cdcriticidade => 1,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 1);
      END IF;
      
      -- Complemento para INC0026760
      -- Se chegar erro não tratado de outras chamadas desta procedure joga para 1124
      IF pr_cdcritic = 9999 THEN
        pr_cdcritic := 1224; -- Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;            
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_cancel_protesto_85. '||sqlerrm||vr_dsparame;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

      pr_cdcritic := 1224; --complemento para INC0026760
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic); --complemento para INC0026760
  END pc_inst_cancel_protesto_85;

  -- Procedure para baixar o titulo
  PROCEDURE pc_inst_pedido_baixa_titulo(pr_idregcob            IN ROWID                   --Rowid da Cobranca
                                 ,pr_cdocorre  IN NUMBER                  --Codigo Ocorrencia
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE   --Data pagamento
                                 ,pr_cdoperad  IN crapope.cdoperad%TYPE   --Operador
                                 ,pr_nrremass  IN INTEGER                 --Numero da Remessa
                                 ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                 ,pr_cdcritic  OUT INTEGER                --Codigo da Critica
                                 ,pr_dscritic  OUT VARCHAR2               --Descricao da critica
                                       ) IS
    -- ...........................................................................................
    --
    --  Programa : pc_inst_pedido_baixa           Antigo: b1wgen0088.p/inst-pedido-baixa
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Novembro/2013.                   Ultima atualizacao: 24/08/201821/02/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Baixar o Titulo
    --
    --   Alteracao : 11/01/2016 - Procedure movida da package PAGA0001 para COBR0007 
    --                            (Douglas - Importacao de Arquivos CNAB)
    --
    --               20/02/2018 - Ajustes mensagens incorretas
    --                            Para erros ocorridos nas intruções, logar na CRAPCOL
    --                            Inclusão raise nos erros de insert/update/delete
    --                            Ajuste erro cursor aberto
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            (Ana - Envolti - Ch. 839539)
    --
    --               09/05/2018 - Alterações referente ao PRJ352 - Nova solução de protesto
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................
  BEGIN
    DECLARE
      --Selecionar Remessas
      CURSOR cr_craprem2 (pr_cdcooper IN craprem.cdcooper%type
                         ,pr_nrcnvcob IN craprem.nrcnvcob%type
                         ,pr_nrdconta IN craprem.nrdconta%type
                         ,pr_nrdocmto IN craprem.nrdocmto%type
                         ,pr_nrremret IN craprem.nrremret%type
                         ,pr_cdocorre IN craprem.cdocorre%type) IS
        SELECT rem.dtaltera
              ,rem.rowid
          FROM craprem rem
         WHERE rem.cdcooper = pr_cdcooper
           AND rem.nrcnvcob = pr_nrcnvcob
           AND rem.nrdconta = pr_nrdconta
           AND rem.nrdocmto = pr_nrdocmto
           AND rem.nrremret = pr_nrremret
           AND rem.cdocorre = pr_cdocorre
        ORDER BY rem.progress_recid DESC;
      rw_craprem2 cr_craprem2%ROWTYPE;
        
      --Tabelas de Memoria DDA
      vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
      vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
      --Rowtype de retorno da cobranca
      rw_crapcob_ret COBR0007.cr_crapcob%ROWTYPE;
      --Registro da Cobranca
      rw_crapcob_id  COBR0007.cr_crapcob_id%ROWTYPE;
      --Registro da Cooperativa
      rw_crapcop     COBR0007.cr_crapcop%ROWTYPE;
      --Registro de Controle de retorno de titulos bancarios
      rw_crapcre     COBR0007.cr_crapcre%ROWTYPE;
      --Registro de Remessa
      rw_craprem     COBR0007.cr_craprem%ROWTYPE;
      --Registro de cadastro de cobranca
      rw_crapcco     COBR0007.cr_crapcco%ROWTYPE;
      
      --Variaveis Locais
      vr_index_lat VARCHAR2(60);
      vr_nrremret  INTEGER;
      vr_nrseqreg  INTEGER;
      vr_cdmotivo  VARCHAR2(2);
      vr_dsmotivo  VARCHAR2(100);
      vr_rowid_ret ROWID;
      --Variaveis de erro
      vr_cdcritic  INTEGER;
      vr_cdcritic2 INTEGER;
      vr_des_erro  VARCHAR2(3);
      vr_dscritic  VARCHAR2(4000);
      vr_dscritic2 VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro    EXCEPTION;
      vr_exc_proximo EXCEPTION;
      --Ch REQ0011728
      vr_dsparame      VARCHAR2(4000);
    BEGIN
      -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 

      --Inicializa variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      
      vr_dsparame := ' pr_idregcob:'||pr_idregcob
                    ||', pr_cdocorre:'||pr_cdocorre
                    ||', pr_dtmvtolt:'||pr_dtmvtolt
                    ||', pr_cdoperad:'||pr_cdoperad
                    ||', pr_nrremass:'||pr_nrremass;
        
      --Selecionar registro cobranca
      OPEN cr_crapcob_id (pr_rowid => pr_idregcob);
      --Posicionar no proximo registro
      FETCH cr_crapcob_id INTO rw_crapcob_id;
      --Se nao encontrar
      IF cr_crapcob_id%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcob_id;

        --Mensagem Critica
        vr_cdcritic := 1179;  --Registro de cobranca nao encontrado
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Registro de cobranca nao encontrado
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcob_id;
      
      --Verificar cooperativa
      OPEN cr_crapcop(pr_cdcooper => rw_crapcob_id.cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;

      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;

        vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_crapcop%ISOPEN THEN
      CLOSE cr_crapcop;
      END IF;
      -- Processo de Validacao Recusas Padrao
      COBR0007.pc_efetua_val_recusa_padrao (pr_cdcooper => rw_crapcob_id.cdcooper --Codigo Cooperativa
                                           ,pr_nrdconta => rw_crapcob_id.nrdconta --Numero da Conta
                                           ,pr_nrcnvcob => rw_crapcob_id.nrcnvcob --Numero Convenio
                                           ,pr_nrdocmto => rw_crapcob_id.nrdocmto --Numero Documento
                                           ,pr_dtmvtolt => pr_dtmvtolt            --Data Movimento
                                           ,pr_cdoperad => pr_cdoperad            --Codigo Operador
                                           ,pr_cdinstru => '02'                   --Codigo Instrucao
                                           ,pr_nrremass => pr_nrremass            --Numero da Remessa
                                           ,pr_rw_crapcob => rw_crapcob_ret       --Registro de Cobranca de Recusa
                                           ,pr_cdcritic => vr_cdcritic            --Codigo Critica
                                           ,pr_dscritic => vr_dscritic);          --Descricao critica

      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo');

      --Verificar titulo em processo registro
      IF rw_crapcob_ret.cdbandoc = 085 AND rw_crapcob_ret.flgregis = 1  AND
         rw_crapcob_ret.flgcbdda = 1   AND rw_crapcob_ret.insitpro <= 2 THEN

        -- Preparar Lote de Retorno Cooperado
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                           ,pr_cdocorre => 26  -- Instrucao Rejeitada --Codigo Ocorrencia
                                           ,pr_cdmotivo => 'XA' -- Motivo
                                           ,pr_vltarifa => 0
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                           ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                           ,pr_nrremass => pr_nrremass --Numero Remessa
                                           ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                           ,pr_dscritic => vr_dscritic); --Descricao Critica

        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 
        
        vr_cdcritic := 1180;  --Titulo em processo de registro. Favor aguardar.
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        --Retornar
        RAISE vr_exc_erro;
      END IF;

      ----- VALIDACOES PARA RECUSAR -----
      IF rw_crapcob_ret.incobran = 3 THEN
        IF rw_crapcob_ret.insitcrt <> 5 AND rw_crapcob_ret.dtdbaixa IS NOT NULL THEN
          -- Preparar Lote de Retorno Cooperado 
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                             ,pr_cdocorre => 26  -- Instrucao Rejeitada  --Codigo Ocorrencia
                                             ,pr_cdmotivo => 'A7' -- 'Titulo ja se encontra na situacaoo Pretendida ' --Codigo Motivo
                                             ,pr_vltarifa => 0
                                             ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                             ,pr_cdagectl => rw_crapcop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                             ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                             ,pr_nrremass => pr_nrremass --Numero Remessa
                                             ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                             ,pr_dscritic => vr_dscritic); --Descricao Critica

          --Se Ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;

          -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 
          
          vr_cdcritic := 1181;  --Boleto Baixado - Baixa nao efetuada!
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          --Retornar
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Verifica se ja existe Pedido de Baixa 
      OPEN cr_crapcre (pr_cdcooper => rw_crapcob_id.cdcooper
                      ,pr_nrcnvcob => rw_crapcob_id.nrcnvcob
                      ,pr_dtmvtolt => pr_dtmvtolt
                      ,pr_intipmvt => 1);

      --Proximo registro
      FETCH cr_crapcre INTO rw_crapcre;

      --Se Encontrou
      IF cr_crapcre%FOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcre;

        --Selecionar remessa
        OPEN cr_craprem (pr_cdcooper => rw_crapcob_ret.cdcooper
                        ,pr_nrcnvcob => rw_crapcob_ret.nrcnvcob
                        ,pr_nrdconta => rw_crapcob_ret.nrdconta
                        ,pr_nrdocmto => rw_crapcob_ret.nrdocmto
                        ,pr_cdocorre => 2
                        ,pr_dtaltera => pr_dtmvtolt);

        FETCH cr_craprem INTO rw_craprem;

        --Se Encontrou
        IF cr_craprem%FOUND THEN
          --Fechar Cursor
          CLOSE cr_craprem;

          -- Preparar Lote de Retorno Cooperado 
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                             ,pr_cdocorre => 26  -- Instrucao Rejeitada --Codigo Ocorrencia
                                             ,pr_cdmotivo => 'XB' --Codigo Motivo
                                             ,pr_vltarifa => 0 --Valor da tarifa
                                             ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                             ,pr_cdagectl => rw_crapcop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                             ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                             ,pr_nrremass => pr_nrremass --Numero Remessa
                                             ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                             ,pr_dscritic => vr_dscritic); --Descricao Critica

          --Se Ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;

          -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 

          vr_cdcritic := 1182;  --Pedido de Baixa ja efetuado - Baixa nao efetuada!
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

          --Retornar
          RAISE vr_exc_erro;
        END IF;

        --Fechar Cursor
        IF cr_craprem%ISOPEN THEN
          CLOSE cr_craprem;
        END IF;
      END IF;

      --Fechar Cursor
      IF cr_crapcre%ISOPEN THEN
        CLOSE cr_crapcre;
      END IF;

      ----- FIM - VALIDACOES PARA RECUSAR -----

      IF rw_crapcob_ret.flgcbdda = 1 AND
        rw_crapcob_ret.cdbandoc = rw_crapcop.cdbcoctl THEN
        -- Executa procedimentos do DDA-JD 
        DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob_ret.rowid --ROWID da Cobranca
                                         ,pr_tpoperad => 'B'                   --Tipo Operacao
                                         ,pr_tpdbaixa => '2'                   --Tipo de Baixa
                                         ,pr_dtvencto => rw_crapcob_ret.dtvencto   --Data Vencimento
                                         ,pr_vldescto => rw_crapcob_ret.vldescto   --Valor Desconto
                                         ,pr_vlabatim => rw_crapcob_ret.vlabatim   --Valor Abatimento
                                         ,pr_flgdprot => rw_crapcob_ret.flgdprot   --Flag Protesto
                                         ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa DDA
                                         ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela retorno DDA
                                         ,pr_cdcritic => vr_cdcritic2           --Codigo Critica
                                         ,pr_dscritic => vr_dscritic2);         --Descricao Critica

        --Se ocorreu erro
        IF NVL(vr_cdcritic2,0) <> 0 OR TRIM(vr_dscritic2) IS NOT NULL THEN

          -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 

          -- Preparar Lote de Retorno Cooperado
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                             ,pr_cdocorre => 26  -- Instrucao Rejeitada  --Codigo Ocorrencia
                                             ,pr_cdmotivo => 'XC' -- Codigo Motivo
                                             ,pr_vltarifa => 0     --Valor da tarifa
                                             ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                             ,pr_cdagectl => rw_crapcop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                             ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                             ,pr_nrremass => pr_nrremass --Numero Remessa
                                             ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                             ,pr_dscritic => vr_dscritic); --Descricao Critica

          --Grava tabela de log para acompanhamento - Ch 839539
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            pc_gera_log(pr_cdcooper      => rw_crapcob_id.cdcooper,
                        pr_dstiplog      => 'E',
                        pr_dscritic      => vr_dscritic,
                        pr_cdcriticidade => 0,
                        pr_cdmensagem    => nvl(vr_cdcritic,0),
                        pr_ind_tipo_log  => 4);
          END IF;

          --Grava log de erro da chamada pc_procedimentos_dda_jd
          vr_cdcritic := vr_cdcritic2;
          vr_dscritic := vr_dscritic2;
          --Levantar Excecao
          RAISE vr_exc_erro;

        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 

      -- tratamento para titulos migrados
      IF rw_crapcob_ret.flgregis = 1 AND rw_crapcob_ret.cdbandoc = 001 THEN

        --Selecionar cadastro convenio
        OPEN cr_crapcco (pr_cdcooper => rw_crapcob_ret.cdcooper
                        ,pr_nrconven => rw_crapcob_ret.nrcnvcob);
        --Proximo registro
        FETCH cr_crapcco INTO rw_crapcco;

        --Se encontrou
        IF cr_crapcco%FOUND AND rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
          --Fechar Cursor
          CLOSE cr_crapcco;

          --Protesta titulo Migrado
          COBR0007.pc_inst_titulo_migrado (pr_idregcob => rw_crapcob_ret      --Rowtype da Cobranca
                                          ,pr_dsdinstr => 'Baixa'             --Descricao da Instrucao
                                          ,pr_dtaltvct => NULL                --Data Alteracao Vencimento
                                          ,pr_vlaltabt => 0                   --Valor Alterado Abatimento
                                          ,pr_nrdctabb => rw_crapcco.nrdctabb --Numero da Conta BB
                                          ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                          ,pr_dscritic => vr_dscritic);       --Descricao Critica

          --Se Ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 

          vr_cdcritic := 1183;  --Solicitacao de baixa de titulo migrado. Aguarde confirmacao no proximo dia util.
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          --Retornar
          RAISE vr_exc_erro;
        END IF;

        --Fechar Cursor
        IF cr_crapcco%ISOPEN THEN
          CLOSE cr_crapcco;
        END IF;
      END IF;

      --Se tem remesssa dda na tabela
      IF vr_tab_remessa_dda.COUNT > 0 THEN
        rw_crapcob_ret.idopeleg:= vr_tab_remessa_dda(vr_tab_remessa_dda.LAST).idopeleg;
        --Atualizar Cobranca
        BEGIN
          UPDATE crapcob 
          SET    crapcob.idopeleg = rw_crapcob_ret.idopeleg
          WHERE  crapcob.rowid    = rw_crapcob_ret.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            --Gravar tabela especifica de log - 20/02/2018 - Ch 839539
            CECRED.pc_internal_exception (pr_cdcooper => 0);

            vr_cdcritic:= 1035;
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||'crapcob: '||
                         'idopeleg:'||rw_crapcob_ret.idopeleg||
                          'com rowid:'||rw_crapcob_ret.rowid||
                          '. '||sqlerrm;

            RAISE vr_exc_erro;
        END;
      END IF;

      --- Verifica se ja existe instr. Abat. / Canc. Abat. / Alt. Vencto ---
      COBR0007.pc_verif_existencia_instruc (pr_idregcob  => rw_crapcob_ret.rowid --ROWID da Cobranca
                                           ,pr_cdoperad  => pr_cdoperad      --Codigo Operador
                                           ,pr_dtmvtolt  => pr_dtmvtolt      --Data Movimento
                                           ,pr_cdcritic  => vr_cdcritic2      --Codigo Critica
                                           ,pr_dscritic  => vr_dscritic2);    --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic2,0) <> 0 OR TRIM(vr_dscritic2) IS NOT NULL THEN
        -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 

        -- Preparar Lote de Retorno Cooperado
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                           ,pr_cdocorre => 26  -- Instrucao Rejeitada --Codigo Ocorrencia
                                           ,pr_cdmotivo => 'XD' -- Codigo Motivo
                                           ,pr_vltarifa => 0
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                           ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                           ,pr_nrremass => pr_nrremass --Numero Remessa
                                           ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                           ,pr_dscritic => vr_dscritic); --Descricao Critica

        --Grava tabela de log para acompanhamento - Ch 839539
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          pc_gera_log(pr_cdcooper      => rw_crapcob_id.cdcooper,
                      pr_dstiplog      => 'E',
                      pr_dscritic      => vr_dscritic,
                      pr_cdcriticidade => 0,
                      pr_cdmensagem    => nvl(vr_cdcritic,0),
                      pr_ind_tipo_log  => 4);
        END IF;

        --Grava log de erro da chamada pc_verif_existencia_instruc
        vr_cdcritic:= vr_cdcritic2;
        vr_dscritic:= vr_dscritic2;

        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 

      IF pr_cdoperad = '996' THEN
        IF pr_nrremass <> 0 THEN
          vr_cdmotivo:= '10'; -- 10 - Comandada Cliente Arquivo 
        ELSE
          vr_cdmotivo:= '11'; -- 11 - Comandada Cliente On-line
        END IF;
      ELSE
        vr_cdmotivo:= '09'; -- 09 - Comandada Banco
      END IF;

       --Se for Banco do Brasil
       IF  rw_crapcob_ret.cdbandoc = 1 THEN

        -- gerar pedido de remessa 
        PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob_ret.cdcooper --Codigo Cooperativa
                                       ,pr_nrcnvcob => rw_crapcob_ret.nrcnvcob --Numero Convenio
                                       ,pr_dtmvtolt => pr_dtmvtolt         --Data movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                       ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                       ,pr_rowid_ret => vr_rowid_ret       --ROWID Remessa Retorno
                                       ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica

        --Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 

        -- Verifica se ja existe Remessa de titulo no dia
        OPEN cr_craprem2 (pr_cdcooper => rw_crapcob_ret.cdcooper
                         ,pr_nrcnvcob => rw_crapcob_ret.nrcnvcob
                         ,pr_nrdconta => rw_crapcob_ret.nrdconta
                         ,pr_nrdocmto => rw_crapcob_ret.nrdocmto
                         ,pr_nrremret => vr_nrremret
                         ,pr_cdocorre => 1);

        FETCH cr_craprem2 INTO rw_craprem2;
        --Se encontrou
        IF cr_craprem2%FOUND THEN
          --Fechar Cursor
          CLOSE cr_craprem2;

          -- Criar Log Cobranca 
          vr_dsmotivo:= 'Titulo excluido da Remessa BB';
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob_ret.rowid   --ROWID da Cobranca
                                       ,pr_cdoperad => pr_cdoperad   --Operador
                                       ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                       ,pr_dsmensag => vr_dsmotivo   --Descricao Mensagem
                                       ,pr_des_erro => vr_des_erro   --Indicador erro
                                       ,pr_dscritic => vr_dscritic); --Descricao erro

          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 

          -- excluir titulo da remessa BB
          BEGIN
            DELETE craprem 
            WHERE  craprem.rowid = rw_craprem2.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              --Gravar tabela especifica de log - 20/02/2018 - Ch 839539
              CECRED.pc_internal_exception (pr_cdcooper => 0);

              vr_cdcritic:= 1037;
              vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||'craprem '||
                            'com rowid:'||rw_craprem2.rowid||sqlerrm;

              RAISE vr_exc_erro;
          END;

          -- tornar o titulo baixado
          BEGIN
            UPDATE crapcob 
            SET    crapcob.incobran = 3
                              ,crapcob.dtdbaixa = pr_dtmvtolt
            WHERE  crapcob.rowid = rw_crapcob_ret.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              --Gravar tabela especifica de log - 20/02/2018 - Ch 839539
              CECRED.pc_internal_exception (pr_cdcooper => 0);

              vr_cdcritic := 1035;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob: '||
                             'incobran:3, dtdbaixa:'||pr_dtmvtolt||
                             'com rowid:'||rw_crapcob_ret.rowid||
                             '. '||sqlerrm;

              RAISE vr_exc_erro;
          END;
        ELSE
          --Fechar Cursor
          CLOSE cr_craprem2;

          -- verificar se titulo BB tem confirmacao de entrada
          IF rw_crapcob_ret.cdbandoc = 001 THEN

            COBR0007.pc_verifica_ent_confirmada (pr_idregcob => rw_crapcob_ret.rowid --Rowid da Cobranca
                                                ,pr_des_erro => vr_des_erro      --Indicador Erro
                                                ,pr_cdcritic => vr_cdcritic      --Codigo Erro
                                                ,pr_dscritic => vr_dscritic);    --Descricao Erro

            --Se Ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 

            --Criar a Remessa
            IF rw_crapcob_ret.incobran = 0 AND
               rw_crapcob_ret.dtvencto < pr_dtmvtolt AND
               rw_crapcob_ret.insitcrt IN (1,2,3) THEN

              --Incrementar quantidade registro
              vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;

              --Criar tabela Remessa
              PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob_ret.rowid     --ROWID da cobranca
                                           ,pr_nrremret => vr_nrremret          --Numero Remessa
                                           ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                           ,pr_cdocorre => 10 -- Sustar e Baixar  --Codigo Ocorrencia
                                           ,pr_cdmotivo => NULL                 --Codigo Motivo
                                           ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                           ,pr_vlabatim => 0                    --Valor Abatimento
                                           ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                           ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                           ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                           ,pr_dscritic => vr_dscritic);        --Descricao Critica

              --Se ocorreu erro
              IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
              -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
              GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 
            END IF;

            --Incrementar quantidade registro
            vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;

            --Criar tabela Remessa
            PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob_ret.rowid     --ROWID da cobranca
                                         ,pr_nrremret => vr_nrremret          --Numero Remessa
                                         ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                         ,pr_cdocorre => pr_cdocorre          --Codigo Ocorrencia
                                         ,pr_cdmotivo => NULL                 --Codigo Motivo
                                         ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                         ,pr_vlabatim => 0                    --Valor Abatimento
                                         ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                         ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                         ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                         ,pr_dscritic => vr_dscritic);        --Descricao Critica

            --Se ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 

          END IF;
        END IF; -- FIM do IF se existe remessa BB

        --Fechar Cursor
        IF cr_craprem2%ISOPEN THEN
          CLOSE cr_craprem2;
        END IF;

        -- Verifica se existe Instr de Protesto no dia 
        OPEN cr_craprem2 (pr_cdcooper => rw_crapcob_ret.cdcooper
                         ,pr_nrcnvcob => rw_crapcob_ret.nrcnvcob
                         ,pr_nrdconta => rw_crapcob_ret.nrdconta
                         ,pr_nrdocmto => rw_crapcob_ret.nrdocmto
                         ,pr_nrremret => vr_nrremret
                         ,pr_cdocorre => 9);

        FETCH cr_craprem2 INTO rw_craprem2;

        --Se Encontrou Remessa
        IF cr_craprem2%FOUND THEN

          --Fechar Cursor
          CLOSE cr_craprem2;

          -- Criar Log Cobranca 
          vr_dsmotivo:= 'Instr de Protesto excluido da Remessa BB';
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob_ret.rowid   --ROWID da Cobranca
                                       ,pr_cdoperad => pr_cdoperad   --Operador
                                       ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                       ,pr_dsmensag => vr_dsmotivo   --Descricao Mensagem
                                       ,pr_des_erro => vr_des_erro   --Indicador erro
                                       ,pr_dscritic => vr_dscritic); --Descricao erro

          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 

          -- excluir titulo da remessa BB 
          BEGIN
            DELETE craprem 
            WHERE  craprem.rowid = rw_craprem2.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              --Gravar tabela especifica de log - 20/02/2018 - Ch 839539
              CECRED.pc_internal_exception (pr_cdcooper => 0);

              vr_cdcritic:= 1037;
              vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||'craprem '||
                            'com rowid:'||rw_craprem2.rowid||sqlerrm;

              RAISE vr_exc_erro;
          END;

          --Incrementar quantidade registro
          vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;

          --Criar tabela Remessa
          PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob_ret.rowid     --ROWID da cobranca
                                       ,pr_nrremret => vr_nrremret          --Numero Remessa
                                       ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                       ,pr_cdocorre => 10                   --Codigo Ocorrencia
                                       ,pr_cdmotivo => NULL                 --Codigo Motivo
                                       ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                       ,pr_vlabatim => 0                    --Valor Abatimento
                                       ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                       ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                       ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);        --Descricao Critica

          --Se ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 

          --Incrementar quantidade registro
          vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;

          --Criar tabela Remessa
          PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob_ret.rowid     --ROWID da cobranca
                                       ,pr_nrremret => vr_nrremret          --Numero Remessa
                                       ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                       ,pr_cdocorre => pr_cdocorre          --Codigo Ocorrencia
                                       ,pr_cdmotivo => NULL                 --Codigo Motivo
                                       ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                       ,pr_vlabatim => 0                    --Valor Abatimento
                                       ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                       ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                       ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);        --Descricao Critica

          --Se ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 

        END IF;

        --Fechar Cursor
        IF cr_craprem2%ISOPEN THEN
          CLOSE cr_craprem2;
        END IF;

      ELSE -- FIM do IF cdbandoc = 1
        IF rw_crapcob_ret.cdbandoc = rw_crapcop.cdbcoctl THEN

          BEGIN
            UPDATE crapcob 
            SET    crapcob.incobran = 3
                  ,crapcob.dtdbaixa = pr_dtmvtolt
            WHERE  crapcob.rowid = rw_crapcob_ret.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              --Gravar tabela especifica de log - 20/02/2018 - Ch 839539
              CECRED.pc_internal_exception (pr_cdcooper => 0);

              vr_cdcritic:= 1035;
              vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||'crapcob: '||
                           'incobran:3, dtdbaixa:'||pr_dtmvtolt||
                            'com rowid:'||rw_crapcob_ret.rowid||
                            '. '||sqlerrm;

              RAISE vr_exc_erro;
          END;

          IF rw_crapcob_ret.inemiten = 3           AND 
             rw_crapcob_ret.dtmvtolt = pr_dtmvtolt AND 
             rw_crapcob_ret.inemiexp = 1           THEN

            -- Criar Log Cobranca
            vr_dsmotivo:= 'Inst Baixa - sem informacao de retorno';
            PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob_ret.rowid   --ROWID da Cobranca
                          ,pr_cdoperad => pr_cdoperad   --Operador
                          ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                          ,pr_dsmensag => vr_dsmotivo   --Descricao Mensagem
                          ,pr_des_erro => vr_des_erro   --Indicador erro
                          ,pr_dscritic => vr_dscritic); --Descricao erro
            --Se ocorreu erro
            IF vr_des_erro = 'NOK' THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 
      		
          ELSE
            -- Preparar Lote de Retorno Cooperado
            COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                 ,pr_cdocorre => 9  -- Baixa --Codigo Ocorrencia
                                 ,pr_cdmotivo => vr_cdmotivo -- Codigo Motivo
                                 ,pr_vltarifa => 0
                                 ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                 ,pr_cdagectl => rw_crapcop.cdagectl
                                 ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                 ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                 ,pr_nrremass => pr_nrremass --Numero Remessa
                                 ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                 ,pr_dscritic => vr_dscritic); --Descricao Critica
            --Se ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 

          END IF;
        END IF; -- FIM do IF cdbandoc = 85
      END IF;
      -- Criar Log Cobranca
      vr_dsmotivo:= 'Instrucao de Baixa';
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob_ret.rowid   --ROWID da Cobranca
                                   ,pr_cdoperad => pr_cdoperad   --Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                   ,pr_dsmensag => vr_dsmotivo   --Descricao Mensagem
                                   ,pr_des_erro => vr_des_erro   --Indicador erro
                                   ,pr_dscritic => vr_dscritic); --Descricao erro

      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 

	  IF rw_crapcob_ret.inemiten = 3           AND 
 	  	 rw_crapcob_ret.dtmvtolt = pr_dtmvtolt AND 
	   	 rw_crapcob_ret.inemiexp = 1           THEN

	    -- Criar Log Cobranca
	    vr_dsmotivo:= 'Titulo excluido da remessa a PG';
	    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob_ret.rowid   --ROWID da Cobranca
                                   ,pr_cdoperad => pr_cdoperad   --Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                   ,pr_dsmensag => vr_dsmotivo   --Descricao Mensagem
                                   ,pr_des_erro => vr_des_erro   --Indicador erro
                                   ,pr_dscritic => vr_dscritic); --Descricao erro
	    --Se ocorreu erro
	    IF vr_des_erro = 'NOK' THEN
	   	  --Levantar Excecao
		    RAISE vr_exc_erro;
	    END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 
	  END IF;

    --Criar tabela consolidada
    IF rw_crapcob_ret.cdbandoc = 85 THEN

	    /* nao gerar tarifa de baixa qdo boleto Cooperativa/EE
           e nao transmitido para a PG */
	    IF rw_crapcob_ret.inemiten = 3           AND 
 		     rw_crapcob_ret.dtmvtolt = pr_dtmvtolt AND 
	 	     rw_crapcob_ret.inemiexp = 1           THEN

		    -- Criar Log Cobranca
	      vr_dsmotivo:= 'Titulo excluido da remessa a PG';
	      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob_ret.rowid   --ROWID da Cobranca
		   	      					             ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                     ,pr_dsmensag => vr_dsmotivo   --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro   --Indicador erro
                                     ,pr_dscritic => vr_dscritic); --Descricao erro
                                     
	      --Se ocorreu erro
	      IF vr_des_erro = 'NOK' THEN
	   	    --Levantar Excecao
		      RAISE vr_exc_erro;
	      END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 

	    ELSE

        --Montar Indice para lancamento tarifa
        vr_index_lat:= lpad(rw_crapcob_id.cdcooper,10,'0')||
                       lpad(rw_crapcob_id.nrdconta,10,'0')||
                       lpad(rw_crapcob_id.nrcnvcob,10,'0')||
                       lpad(9,10,'0')||
                       lpad(vr_cdmotivo,10,'0')||
                       lpad(pr_tab_lat_consolidada.Count+1,10,'0');

        pr_tab_lat_consolidada(vr_index_lat).cdcooper:= rw_crapcob_id.cdcooper;
        pr_tab_lat_consolidada(vr_index_lat).nrdconta:= rw_crapcob_id.nrdconta;
        pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= rw_crapcob_id.nrdocmto;
        pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= rw_crapcob_id.nrcnvcob;
        pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
        pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 09;      -- 09 - Baixa
        pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= vr_cdmotivo;   -- Motivo
        pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob_ret.vltitulo;
        
		  END IF;
    END IF;
      
    IF rw_crapcob_ret.inserasa <> 0 AND
	     rw_crapcob_ret.inserasa <> 3 AND
	     rw_crapcob_ret.inserasa <> 4 AND
	     rw_crapcob_ret.inserasa <> 6 THEN
	 
	    SSPC0002.pc_cancelar_neg_serasa(pr_cdcooper => rw_crapcob_id.cdcooper  --> Codigo da cooperativa
                                     ,pr_nrcnvcob => rw_crapcob_id.nrcnvcob  --> Numero do convenio de cobranca. 
                                     ,pr_nrdconta => rw_crapcob_id.nrdconta  --> Numero da conta/dv do associado.
                                     ,pr_nrdocmto => rw_crapcob_id.nrdocmto  --> Numero do documento(boleto) 
                                     ,pr_nrremass => pr_nrremass  --> Numero da Remessa
                                     ,pr_cdoperad => pr_cdoperad  --> Codigo do operador
                                     ,pr_cdcritic => vr_cdcritic  --> Código da crítica
                                     ,pr_dscritic => vr_dscritic);--> Descrição da crítica

       -- Verificar se ocorreu erro durante a execucao da instrucao
       IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_erro;
       END IF;
       -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo'); 
  	END IF;  
      
    -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        --Ch 839539 - gravar na CRAPCOL para visualizar em tela
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob_ret.rowid   --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                     ,pr_dsmensag => pr_dscritic   --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro   --Indicador erro
                                     ,pr_dscritic => vr_dscritic); --Descricao erro

        -- Inclui nome do modulo logado - 21/02/2018 - Ch 839539
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_titulo');
        --Grava tabela de log - Ch 788828
        pc_gera_log(pr_cdcooper      => nvl(rw_crapcob_id.cdcooper,3),
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic||vr_dsparame,
                    pr_cdcriticidade => 1,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 1);

        -- Complemento para INC0026760
        -- Se chegar erro não tratado de outras chamadas desta procedure joga para 1124
        IF pr_cdcritic = 9999 THEN
          pr_cdcritic := 1224; -- Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;            

      WHEN OTHERS THEN
        --Gravar tabela especifica de log - 20/02/2018 - Ch 839539
        CECRED.pc_internal_exception (pr_cdcooper => nvl(rw_crapcob_id.cdcooper,3));

        -- Montar descrição de erro não tratado
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_pedido_baixa_titulo. '||sqlerrm||vr_dsparame;

        --Grava tabela de log - Ch 788828
        pc_gera_log(pr_cdcooper      => nvl(rw_crapcob_id.cdcooper,3),
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 2,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 2);

        pr_cdcritic := 1224; --complemento para INC0026760
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic); --complemento para INC0026760
    END;
  END pc_inst_pedido_baixa_titulo; 

  -- Procedure para baixar o titulo
  PROCEDURE pc_inst_pedido_baixa (pr_idregcob  IN ROWID                   --Rowid da Cobranca
                                 ,pr_cdocorre  IN NUMBER                  --Codigo Ocorrencia
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE   --Data pagamento
                                 ,pr_cdoperad  IN crapope.cdoperad%TYPE   --Operador
                                 ,pr_nrremass  IN INTEGER                 --Numero da Remessa
                                 ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                 ,pr_cdcritic  OUT INTEGER                --Codigo da Critica
                                 ,pr_dscritic  OUT VARCHAR2) IS           --Descricao da critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_pedido_baixa           Antigo: b1wgen0088.p/inst-pedido-baixa
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Novembro/2013.                   Ultima atualizacao: 24/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Baixar o Titulo
    --
    --   Alteracao : 11/01/2016 - Procedure movida da package PAGA0001 para COBR0007 
    --                            (Douglas - Importacao de Arquivos CNAB)
    --
    --               09/02/2018 - Alterações referente ao PRJ352 - Nova solução de protesto
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            Comentado cursor cd_craprem2 e variáveis não utilizados
    --                            (Ana - Envolti - Ch. REQ0011728)
    --
    --               12/02/2019 - Teste Revitalização
    --                            (Belli - Envolti - Ch. REQ0035813)     
    -- ...........................................................................................
  BEGIN
    DECLARE
/*      --Selecionar Remessas
      CURSOR cr_craprem2 (pr_cdcooper IN craprem.cdcooper%type
                         ,pr_nrcnvcob IN craprem.nrcnvcob%type
                         ,pr_nrdconta IN craprem.nrdconta%type
                         ,pr_nrdocmto IN craprem.nrdocmto%type
                         ,pr_nrremret IN craprem.nrremret%type
                         ,pr_cdocorre IN craprem.cdocorre%type) IS
        SELECT rem.dtaltera
              ,rem.rowid
          FROM craprem rem
         WHERE rem.cdcooper = pr_cdcooper
           AND rem.nrcnvcob = pr_nrcnvcob
           AND rem.nrdconta = pr_nrdconta
           AND rem.nrdocmto = pr_nrdocmto
           AND rem.nrremret = pr_nrremret
           AND rem.cdocorre = pr_cdocorre
        ORDER BY rem.progress_recid DESC;
*/        
    -- Variáveis comentadas por não serem utilizadas
/*
      --Tabelas de Memoria DDA
      vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
      vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
      --Rowtype de retorno da cobranca
      rw_crapcob_ret COBR0007.cr_crapcob%ROWTYPE;
      --Registro de Controle de retorno de titulos bancarios
      rw_crapcre     COBR0007.cr_crapcre%ROWTYPE;
      --Registro de Remessa
      rw_craprem     COBR0007.cr_craprem%ROWTYPE;
      --Registro de cadastro de cobranca
      rw_crapcco     COBR0007.cr_crapcco%ROWTYPE;
      --Variaveis Locais
      vr_index_lat VARCHAR2(60);
      vr_nrremret  INTEGER;
      vr_nrseqreg  INTEGER;
      vr_cdmotivo  VARCHAR2(2);
      vr_dsmotivo  VARCHAR2(100);
      vr_rowid_ret ROWID;
      vr_cdcritic2 INTEGER;
      vr_dscritic2 VARCHAR2(4000);
      vr_des_erro  VARCHAR2(3);
*/

      --Registro da Cobranca
      rw_crapcob_id  COBR0007.cr_crapcob_id%ROWTYPE;
      --Registro da Cooperativa
      rw_crapcop     COBR0007.cr_crapcop%ROWTYPE;
      
      --Variaveis de erro
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro    EXCEPTION;
      vr_exc_proximo EXCEPTION;
      --Ch REQ0011728
      vr_dsparame      VARCHAR2(4000);
    BEGIN
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa');

      --Inicializa variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      
      vr_dsparame := ' pr_cdocorre:'||pr_cdocorre
                    ||', pr_dtmvtolt:'||pr_dtmvtolt
                    ||', pr_cdoperad:'||pr_cdoperad
                    ||', pr_nrremass:'||pr_nrremass;
      
      --Selecionar registro cobranca
      OPEN cr_crapcob_id (pr_rowid => pr_idregcob);

      --Posicionar no proximo registro
      FETCH cr_crapcob_id INTO rw_crapcob_id;

      --Se nao encontrar
      IF cr_crapcob_id%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcob_id;

        --Mensagem Critica
        vr_dscritic := gene0001.fn_busca_critica(1179); --Registro de cobranca nao encontrado
        --Levantar Excecao
        RAISE vr_exc_erro;

      END IF;

      --Fechar Cursor
      CLOSE cr_crapcob_id;
      
      --Verificar cooperativa
      OPEN cr_crapcop(pr_cdcooper => rw_crapcob_id.cdcooper);

      FETCH cr_crapcop INTO rw_crapcop;

      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;

        vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      IF rw_crapcob_id.cdbandoc = 085 THEN -- Cecred
        --
        -- insitcrt = 1 => solicitado pedido de protesto
        -- insitcrt = 2 => remetido ao cartorio
        -- insitcrt = 3 => entrada em cartorio
				IF rw_crapcob_id.insrvprt = 1 AND rw_crapcob_id.insitcrt IN(1, 2, 3) THEN -- IEPTB
					--
					pc_inst_cancel_protesto_85(pr_cdcooper            => rw_crapcob_id.cdcooper
																		,pr_nrdconta            => rw_crapcob_id.nrdconta
																		,pr_nrcnvcob            => rw_crapcob_id.nrcnvcob
																		,pr_nrdocmto            => rw_crapcob_id.nrdocmto
																		,pr_cdocorre            => pr_cdocorre
																		,pr_dtmvtolt            => pr_dtmvtolt
																		,pr_cdoperad            => pr_cdoperad
																		,pr_nrremass            => pr_nrremass
																		,pr_idgerbai            => 1 -- Indica se deve gerar baixa ou não (0-Não, 1-Sim)
																		,pr_tab_lat_consolidada => pr_tab_lat_consolidada
																		,pr_cdcritic            => pr_cdcritic
																		,pr_dscritic            => pr_dscritic);
					--
				ELSE 
					--
					pc_inst_pedido_baixa_titulo(pr_idregcob            => pr_idregcob
																		 ,pr_cdocorre            => pr_cdocorre
																		 ,pr_dtmvtolt            => pr_dtmvtolt
																		 ,pr_cdoperad            => pr_cdoperad
																		 ,pr_nrremass            => pr_nrremass
																		 ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
																		 ,pr_cdcritic            => pr_cdcritic
																		 ,pr_dscritic            => pr_dscritic);
					--
				END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa');
        --
      ELSIF rw_crapcob_id.cdbandoc = 001 THEN -- BB
        --
        pc_inst_pedido_baixa_titulo(pr_idregcob            => pr_idregcob
                                   ,pr_cdocorre            => pr_cdocorre
                                   ,pr_dtmvtolt            => pr_dtmvtolt
                                   ,pr_cdoperad            => pr_cdoperad
                                   ,pr_nrremass            => pr_nrremass
                                   ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                   ,pr_cdcritic            => pr_cdcritic
                                   ,pr_dscritic            => pr_dscritic
                                   );
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa');
        --
      ELSE
        --
        pr_dscritic := gene0001.fn_busca_critica(1316)|| rw_crapcob_id.cdbandoc; --Erro cdbandoc || rw_crapcob_id.cdbandoc || nao tratado
        RAISE vr_exc_erro;
        --
      END IF;
      --
                          
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;

        --Grava tabela de log - Ch REQ0011728
        pc_gera_log(pr_cdcooper      => nvl(rw_crapcob_id.cdcooper,3),
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic||vr_dsparame,
                    pr_cdcriticidade => 1,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 1);
        -- Ajuste mensagem - 12/02/2019 - REQ0035813
        IF nvl(pr_cdcritic,0) IN ( 1197, 9999, 1034, 1035, 1036, 1037 ) THEN
          pr_cdcritic := 1224;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        ELSIF nvl(pr_cdcritic,0) = 0 AND
              SUBSTR(pr_dscritic, 1, 7 ) IN ( '1197 - ', '9999 - ', '1034 - ', '1035 - ', '1036 - ', '1037 - ' ) THEN
          pr_cdcritic := 1224;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => rw_crapcob_id.cdcooper);  

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_pedido_baixa. '||sqlerrm||vr_dsparame;

        --Grava tabela de log - Ch REQ0011728
        pc_gera_log(pr_cdcooper      => rw_crapcob_id.cdcooper,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 2,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 2);

        pr_cdcritic := 1224; -- Ajuste mensagem - 12/02/2019 - REQ0035813
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END;

  END pc_inst_pedido_baixa;

  PROCEDURE pc_inst_pedido_baixa_prg (pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                                     ,pr_nrdconta  IN crapcob.nrdconta%TYPE   --> Numero da Conta
                                     ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE   --> Numero Convenio
                                     ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE   --> Numero Documento
                                     ,pr_cdocorre  IN NUMBER                  --> Codigo Ocorrencia
                                     ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE   --> Data pagamento
                                     ,pr_cdoperad  IN crapope.cdoperad%TYPE   --> Operador
                                     ,pr_nrremass  IN INTEGER                 --> Numero da Remessa
                                     ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                     ,pr_cdcritic  OUT INTEGER                --> Codigo da Critica
                                     ,pr_dscritic  OUT VARCHAR2)IS             --> Descricao da critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_pedido_baixa_prg          
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : 
    --  Data     :                                    Ultima atualizacao: 12/02/2019
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: 
    --   Objetivo  : 
    --
    --   Alterações: 24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            (Ana - Envolti - Ch. REQ0011728)
    --
    --               12/02/2019 - Rotina não mais utilizada
    --                            (Belli - Envolti - Ch. REQ0035813)
    -- ...........................................................................................
  BEGIN
     DECLARE
      --Selecionar informacoes Cobranca
      CURSOR cr_crapcob  (pr_cdcooper IN crapcob.cdcooper%TYPE
                         ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                         ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                         ,pr_nrdconta IN crapcob.nrdconta%type
                         ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                         ,pr_nrdocmto IN crapcob.nrdocmto%type) IS
        SELECT cob.rowid
              ,cob.cdbandoc
              ,cob.nrdctabb
          FROM crapcob cob
         WHERE cob.cdcooper = pr_cdcooper
           AND cob.cdbandoc = pr_cdbandoc
           AND cob.nrdctabb = pr_nrdctabb
           AND cob.nrdconta = pr_nrdconta
           AND cob.nrcnvcob = pr_nrcnvcob
           AND cob.nrdocmto = pr_nrdocmto
         ORDER BY cob.progress_recid ASC;

      rw_crapcob cr_crapcob%ROWTYPE;

      --Registro de Cadastro de Cobranca
      rw_crapcco COBR0007.cr_crapcco%ROWTYPE;

      --Tabelas de Memoria de Remessa
      rw_crapcop         COBR0007.cr_crapcop%ROWTYPE;

      --Variaveis de erro
--      vr_des_erro VARCHAR2(4000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      --Ch REQ0011728
      vr_dsparame      VARCHAR2(4000);

   BEGIN
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_prg');
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                    ||', pr_nrdconta:'||pr_nrdconta
                    ||', pr_nrcnvcob:'||pr_nrcnvcob
                    ||', pr_nrdocmto:'||pr_nrdocmto
                    ||', pr_cdocorre:'||pr_cdocorre
                    ||', pr_dtmvtolt:'||pr_dtmvtolt
                    ||', pr_cdoperad:'||pr_cdoperad
                    ||', pr_nrremass:'||pr_nrremass;

      --Verificar cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
        vr_dscritic := gene0001.fn_busca_critica(vr_dscritic);  
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      -- Buscar parâmetros do cadastro de cobrança
      OPEN  cr_crapcco(pr_cdcooper => pr_cdcooper
                      ,pr_nrconven => pr_nrcnvcob);
      FETCH cr_crapcco INTO rw_crapcco;
      -- Se não encontrar registro
      IF cr_crapcco%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcco;
        vr_dscritic := gene0001.fn_busca_critica(1179); --Registro de cobranca nao encontrado
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcco;

      OPEN cr_crapcob (pr_cdcooper => pr_cdcooper
                      ,pr_cdbandoc => rw_crapcco.cddbanco
                      ,pr_nrdctabb => rw_crapcco.nrdctabb
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrcnvcob => pr_nrcnvcob
                      ,pr_nrdocmto => pr_nrdocmto);
      --Posicionar no proximo registro
      FETCH cr_crapcob INTO rw_crapcob;
      --Se nao encontrar
      IF cr_crapcob%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcob;
        --Mensagem Critica
        vr_dscritic := gene0001.fn_busca_critica(1179); --Registro de cobranca nao encontrado
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcob;

      COBR0007.pc_inst_pedido_baixa (pr_idregcob => rw_crapcob.rowid
                                    ,pr_cdocorre => 1
                                    ,pr_dtmvtolt => pr_dtmvtolt
                                    ,pr_cdoperad => pr_cdoperad
                                    ,pr_nrremass => pr_nrremass
                                    ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                    ,pr_cdcritic => pr_cdcritic
                                    ,pr_dscritic => pr_dscritic);
        --Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_prg');

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic||vr_dsparame;

        --Grava tabela de log - Ch REQ0011728
        pc_gera_log(pr_cdcooper      => pr_cdcooper,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 1,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 1);
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_pedido_baixa_prg. '||sqlerrm||vr_dsparame;

        --Grava tabela de log - Ch REQ0011728
        pc_gera_log(pr_cdcooper      => pr_cdcooper,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 2,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 2);
    END;
  END pc_inst_pedido_baixa_prg;
 
  -- Procedure para gerar protesto do titulo por decurso
  PROCEDURE pc_inst_pedido_baixa_decurso (pr_cdcooper IN crapcop.cdcooper%TYPE   --Codigo Cooperativa
                                         ,pr_nrdconta IN crapcob.nrdconta%TYPE   --Numero da Conta
                                         ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE   --Numero Convenio
                                         ,pr_nrdocmto IN crapcob.nrdocmto%TYPE   --Numero Documento
                                         ,pr_cdocorre IN NUMBER                  --Codigo da ocorrencia
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   --Data pagamento
                                         ,pr_cdoperad IN crapope.cdoperad%TYPE   --Operador
                                         ,pr_nrremass IN INTEGER                 --Numero da Remessa
                                         ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                         ,pr_cdcritic OUT INTEGER                --Codigo da Critica
                                         ,pr_dscritic OUT VARCHAR2) IS           --Descricao da critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_pedido_baixa_decurso           Antigo: b1wgen0088.p/inst-pedido-baixa-decurso
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Novembro/2013.                   Ultima atualizacao: 24/08/201821/08/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para efetuar a baixa do titulo por decurso de prazo
    --
    --   Alterações:
    --          20/01/2014 - Ajuste processo leitura crapcob para ganho de performace ( Renato - Supero )
    --
    --          11/01/2016 - Procedure movida da package PAGA0001 para COBR0007 
    --                       (Douglas - Importacao de Arquivos CNAB)
    --
    --          31/07/2017 - Fixado valor '5' para baixa por decurso de prazo na CIP. (Rafael)
    --
    --          03/08/2017 - Fixado valor '4' para baixa por decurso de prazo na CIP.
    --                       A JD está utilizando códigos diferentes da CIP para baixa. (Rafael)
    --
    --          21/08/2017 - Conforme conversado com o Victor/Cobrança, será fixado valor '2' 
    --                       para baixa por decurso de prazo na CIP. (Rafael)    
    --
    --          24/08/2018 - Revitalização
    --                       Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                       Inclusão pc_set_modulo
    --                       Ajuste registro de logs com mensagens corretas
    --                       (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................
  BEGIN
    DECLARE
      --Selecionar informacoes Cobranca
      CURSOR cr_crapcob  (pr_cdcooper IN crapcob.cdcooper%TYPE
                         ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                         ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                         ,pr_nrdconta IN crapcob.nrdconta%type
                         ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                         ,pr_nrdocmto IN crapcob.nrdocmto%type) IS
        SELECT cob.insitcrt
              ,cob.incobran
              ,cob.cdcooper
              ,cob.nrcnvcob
              ,cob.nrdconta
              ,cob.nrdocmto
              ,cob.flgcbdda
              ,cob.cdbandoc
              ,cob.dtvencto
              ,cob.vldescto
              ,cob.vlabatim
              ,cob.flgdprot
              ,cob.idopeleg
              ,cob.vltitulo
              ,cob.rowid
          FROM crapcob cob
         WHERE cob.cdcooper = pr_cdcooper
           AND cob.cdbandoc = pr_cdbandoc
           AND cob.nrdctabb = pr_nrdctabb
           AND cob.nrdconta = pr_nrdconta
           AND cob.nrcnvcob = pr_nrcnvcob
           AND cob.nrdocmto = pr_nrdocmto
         ORDER BY cob.progress_recid ASC;
      rw_crapcob cr_crapcob%ROWTYPE;

      -- Registro de Controle de titulos bancarios
      rw_crapcre COBR0007.cr_crapcre%ROWTYPE;
      -- Registro de Remessa
      rw_craprem COBR0007.cr_craprem%ROWTYPE;
      -- registro de Cadastro de Cobranca
      rw_crapcco COBR0007.cr_crapcco%ROWTYPE;

      --Variaveis Locais
      vr_index_lat VARCHAR2(60);
      vr_nrremret  INTEGER;
      vr_nrseqreg  INTEGER;
      vr_qtdregdda INTEGER;
      vr_dsmotivo  VARCHAR2(100);
      vr_rowid_ret ROWID;
      --Tabelas de Memoria de Remessa
      vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
      vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
      rw_crapcop         COBR0007.cr_crapcop%ROWTYPE;

      --Variaveis de erro
      vr_des_erro VARCHAR2(4000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      --Ch REQ0011728
      vr_dsparame      VARCHAR2(4000);

    BEGIN
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_decurso');
      
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                    ||', pr_nrdconta:'||pr_nrdconta
                    ||', pr_nrcnvcob:'||pr_nrcnvcob
                    ||', pr_nrdocmto:'||pr_nrdocmto
                    ||', pr_cdocorre:'||pr_cdocorre
                    ||', pr_dtmvtolt:'||pr_dtmvtolt
                    ||', pr_cdoperad:'||pr_cdoperad
                    ||', pr_nrremass:'||pr_nrremass;

      --Verificar cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
        vr_dscritic := gene0001.fn_busca_critica(vr_dscritic);  
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      -- Buscar parâmetros do cadastro de cobrança
      OPEN  cr_crapcco(pr_cdcooper => pr_cdcooper
                      ,pr_nrconven => pr_nrcnvcob);
      FETCH cr_crapcco INTO rw_crapcco;
      -- Se não encontrar registro
      IF cr_crapcco%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcco;
        vr_cdcritic := 1179;
        vr_dscritic := gene0001.fn_busca_critica(1179); --Registro de cobranca nao encontrado
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcco;

      --Selecionar registro cobranca
      OPEN cr_crapcob (pr_cdcooper => pr_cdcooper
                      ,pr_cdbandoc => rw_crapcco.cddbanco
                      ,pr_nrdctabb => rw_crapcco.nrdctabb
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrcnvcob => pr_nrcnvcob
                      ,pr_nrdocmto => pr_nrdocmto);
      --Posicionar no proximo registro
      FETCH cr_crapcob INTO rw_crapcob;
      --Se nao encontrar
      IF cr_crapcob%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcob;
        --Mensagem Critica
        vr_dscritic := gene0001.fn_busca_critica(1179);  --Registro de cobranca nao encontrado
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcob;

      ----- VALIDACOES PARA RECUSAR -----
      CASE rw_crapcob.incobran
        WHEN 3 THEN
          IF rw_crapcob.insitcrt <> 5 THEN
            vr_dscritic := gene0001.fn_busca_critica(1181);  --Boleto Baixado - Baixa nao efetuada
          ELSE
            vr_dscritic := gene0001.fn_busca_critica(1317);  --Boleto Protestado - Baixa nao efetuada
          END IF;
          --Levantar Excecao
          RAISE vr_exc_erro;
        WHEN 5 THEN
          vr_dscritic := gene0001.fn_busca_critica(1318);  --Boleto Liquidado - Baixa nao efetuada
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE NULL;
      END CASE;
      -- Verifica se ja existe Pedido de Baixa
      OPEN cr_crapcre (pr_cdcooper => pr_cdcooper
                      ,pr_nrcnvcob => pr_nrcnvcob
                      ,pr_dtmvtolt => pr_dtmvtolt
                      ,pr_intipmvt => 1);
      --Posicionar no proximo registro
      FETCH cr_crapcre INTO rw_crapcre;
      --Se encontrar
      IF cr_crapcre%FOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcre;
        --Selecionar remessa
        OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                        ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                        ,pr_nrdconta => rw_crapcob.nrdconta
                        ,pr_nrdocmto => rw_crapcob.nrdocmto
                        ,pr_cdocorre => 2
                        ,pr_dtaltera => pr_dtmvtolt);
        FETCH cr_craprem INTO rw_craprem;
        --Se Encontrou
        IF cr_craprem%FOUND THEN
          --Fechar Cursor
          CLOSE cr_craprem;
          --Mensagem Erro
          vr_dscritic := gene0001.fn_busca_critica(1182);  --Pedido de Baixa ja efetuado - Baixa nao efetuada
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_craprem;
      END IF;
      --Fechar Cursor
      IF cr_crapcre%ISOPEN THEN
        CLOSE cr_crapcre;
      END IF;
      ----- FIM - VALIDACOES PARA RECUSAR -----
      --Se Cobranca DDA e banco centralizador
      IF rw_crapcob.flgcbdda = 1 AND
         rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl THEN
        -- Executa procedimentos do DDA-JD
        DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob.rowid         --ROWID da Cobranca
                                         ,pr_tpoperad => 'B'                       --Tipo Operacao
                                         ,pr_tpdbaixa => '2'                       --Baixa por decurso de prazo na CIP
                                         ,pr_dtvencto => rw_crapcob.dtvencto       --Data Vencimento
                                         ,pr_vldescto => rw_crapcob.vldescto       --Valor Desconto
                                         ,pr_vlabatim => rw_crapcob.vlabatim       --Valor Abatimento
                                         ,pr_flgdprot => rw_crapcob.flgdprot       --Flag Protesto
                                         ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa
                                         ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela memoria retorno DDA
                                         ,pr_cdcritic => vr_cdcritic               --Codigo Critica
                                         ,pr_dscritic => vr_dscritic);             --Descricao Critica
        --Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_decurso');
      END IF;

      BEGIN
        --Criar Savepoint
        --SAVEPOINT save_trans;
        --Encontrar ultimo registro tabela
        vr_qtdregdda:= vr_tab_remessa_dda.count;
        --Se tem remesssa dda na tabela
        IF vr_qtdregdda > 0 THEN
          rw_crapcob.idopeleg:= vr_tab_remessa_dda(vr_tab_remessa_dda.LAST).idopeleg;
          --Atualizar Cobranca
          BEGIN
            UPDATE crapcob SET crapcob.idopeleg = rw_crapcob.idopeleg
            WHERE crapcob.rowid = rw_crapcob.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

              vr_cdcritic := 1035;  --Erro ao atualizar crapcob 
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                             ' idopeleg:'||rw_crapcob.idopeleg||
                             ' com rowid:'||rw_crapcob.rowid||
                             '. '||sqlerrm;
              RAISE vr_exc_erro;
          END;
        END IF;

        --- Verifica se ja existe instr. Abat. / Canc. Abat. / Alt. Vencto ---
        COBR0007.pc_verif_existencia_instruc (pr_idregcob  => rw_crapcob.rowid --ROWID da Cobranca
                                             ,pr_cdoperad  => pr_cdoperad      --Codigo Operador
                                             ,pr_dtmvtolt  => pr_dtmvtolt      --Data Movimento
                                             ,pr_cdcritic  => vr_cdcritic      --Codigo Critica
                                             ,pr_dscritic  => vr_dscritic);    --Descricao Critica
        --Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_decurso');
        --Se for Banco Brasil
        IF rw_crapcob.cdbandoc = 1 THEN
          -- gerar pedido de remessa
          PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                         ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                         ,pr_dtmvtolt => pr_dtmvtolt         --Data movimento
                                         ,pr_cdoperad => pr_cdoperad         --Codigo Operador
                                         ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                         ,pr_rowid_ret => vr_rowid_ret       --ROWID Remessa Retorno
                                         ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                         ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                         ,pr_dscritic => vr_dscritic);       --Descricao Critica
          --Se ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_decurso');
          --
          IF rw_crapcob.incobran = 0           AND
             rw_crapcob.dtvencto < pr_dtmvtolt AND
             rw_crapcob.insitcrt IN (2,3) THEN
            --Incrementar Sequencial
            vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;
            --Criar tabela Remessa
            PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                         ,pr_nrremret => vr_nrremret          --Numero Remessa
                                         ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                         ,pr_cdocorre => 10 -- Sustar e Baixar --Codigo Ocorrencia
                                         ,pr_cdmotivo => NULL                 --Codigo Motivo
                                         ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                         ,pr_vlabatim => 0                    --Valor Abatimento
                                         ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                         ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                         ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                         ,pr_dscritic => vr_dscritic);        --Descricao Critica
            --Se ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_decurso');
          END IF;
          --Incrementar Sequencial
          vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;
          --Criar tabela Remessa
          PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                       ,pr_nrremret => vr_nrremret          --Numero Remessa
                                       ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                       ,pr_cdocorre => pr_cdocorre          --Codigo Ocorrencia
                                       ,pr_cdmotivo => NULL                 --Codigo Motivo
                                       ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                       ,pr_vlabatim => 0                    --Valor Abatimento
                                       ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                       ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                       ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);        --Descricao Critica
          --Se ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_decurso');
        ELSIF rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl THEN
          --Atualizar Cobranca
          BEGIN
            UPDATE crapcob SET crapcob.incobran = 3
                              ,crapcob.dtdbaixa = pr_dtmvtolt
            WHERE crapcob.rowid = rw_crapcob.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

              vr_cdcritic := 1035;  --Erro ao atualizar crapcob 
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                             ' incobran:3'||
                             ', dtdbaixa:'||pr_dtmvtolt||
                             ' com rowid:'||rw_crapcob.rowid||
                             '. '||sqlerrm;
              RAISE vr_exc_erro;
          END;
          -- Preparar Lote de Retorno Cooperado
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                             ,pr_cdocorre => 09  -- Baixa --Codigo Ocorrencia
                                             ,pr_cdmotivo => '13' -- Decurso Prazo --Codigo Motivo
                                             ,pr_vltarifa => 0
                                             ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                             ,pr_cdagectl => rw_crapcop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                             ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                             ,pr_nrremass => pr_nrremass --Numero Remessa
                                             ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                             ,pr_dscritic => vr_dscritic); --Descricao Critica
          --Se Ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_decurso');
        END IF;

        --Montar Motivo
        vr_dsmotivo:= 'Boleto baixado automaticamente por decurso de prazo - ' || (pr_dtmvtolt - rw_crapcob.dtvencto) || ' dias apos o vencimento';
        --Cria log cobranca
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                     ,pr_dsmensag => vr_dsmotivo   --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro   --Indicador erro
                                     ,pr_dscritic => vr_dscritic); --Descricao erro

        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_pedido_baixa_decurso');

        IF rw_crapcob.cdbandoc = 85 THEN
          --Montar Indice para tabela memoria
          vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                         lpad(pr_nrdconta,10,'0')||
                         lpad(pr_nrcnvcob,10,'0')||
                         lpad(9,10,'0')||
                         lpad('13',10,'0')||
                         lpad(pr_tab_lat_consolidada.count+1,10,'0');
          -- Gerar registro Tarifa
          pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
          pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
          pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
          pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
          pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
          pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 9; -- 09 - Baixa
          pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= '13';  -- 13 - Decurso Prazo
          pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;
        END IF;
      EXCEPTION
        WHEN vr_exc_erro THEN
          --Desfazer
          --ROLLBACK TO save_trans;
          RAISE vr_exc_erro;
      END;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic||vr_dsparame;

        --Grava tabela de log - Ch REQ0011728
        pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 1,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 1);
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_pedido_baixa_decurso. '||sqlerrm||vr_dsparame;

        --Grava tabela de log - Ch REQ0011728
        pc_gera_log(pr_cdcooper      => pr_cdcooper,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 2,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 2);
    END;
  END pc_inst_pedido_baixa_decurso;

  -- Procedure para Sustar Protesto e Baixar Titulo
  PROCEDURE pc_inst_sustar_baixar (pr_cdcooper IN crapcop.cdcooper%TYPE   --Codigo Cooperativa
                                  ,pr_nrdconta IN crapcob.nrdconta%TYPE   --Numero da Conta
                                  ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE   --Numero Convenio
                                  ,pr_nrdocmto IN crapcob.nrdocmto%TYPE   --Numero Documento
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   --Data pagamento
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE   --Operador
                                  ,pr_nrremass IN INTEGER                 --Numero Remessa
                                  ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                  ,pr_cdcritic OUT INTEGER                --Codigo da Critica
                                  ,pr_dscritic OUT VARCHAR2) IS           --Descricao da critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_sustar_baixar           Antigo: b1wgen0088.p/inst-sustar-baixar
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Novembro/2013.                   Ultima atualizacao: 24/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Sustar Protesto e Baixar Titulo
    --
    --   Alterações:
    --          20/01/2014 - Ajuste processo leitura crapcob para ganho de performace ( Renato - Supero )
    --
    --          11/01/2016 - Procedure movida da package PAGA0001 para COBR0007 
    --                       (Douglas - Importacao de Arquivos CNAB)
    --
    --          24/08/2018 - Revitalização
    --                       Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                       Inclusão pc_set_modulo
    --                       Ajuste registro de logs com mensagens corretas
    --                       (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................

  BEGIN
    DECLARE
            --Selecionar informacoes Cobranca
      CURSOR cr_crapcob  (pr_cdcooper IN crapcob.cdcooper%type
                         ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                         ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                         ,pr_nrdconta IN crapcob.nrdconta%type
                         ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                         ,pr_nrdocmto IN crapcob.nrdocmto%type) IS
        SELECT cob.insitcrt
              ,cob.incobran
              ,cob.cdcooper
              ,cob.nrcnvcob
              ,cob.nrdconta
              ,cob.nrdocmto
              ,cob.flgcbdda
              ,cob.cdbandoc
              ,cob.dtvencto
              ,cob.vldescto
              ,cob.vlabatim
              ,cob.flgdprot
              ,cob.idopeleg
              ,cob.vltitulo
              ,cob.rowid
          FROM crapcob cob
         WHERE cob.cdcooper = pr_cdcooper
           AND cob.cdbandoc = pr_cdbandoc
           AND cob.nrdctabb = pr_nrdctabb
           AND cob.nrdconta = pr_nrdconta
           AND cob.nrcnvcob = pr_nrcnvcob
           AND cob.nrdocmto = pr_nrdocmto
         ORDER BY cob.progress_recid ASC;
      rw_crapcob cr_crapcob%ROWTYPE;

      rw_crapcco COBR0007.cr_crapcco%ROWTYPE;

      --Variaveis de erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro    EXCEPTION;
      vr_exc_proximo EXCEPTION;
      --Ch REQ0011728
      vr_dsparame      VARCHAR2(4000);
    BEGIN
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_baixar');
      --Inicializa variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                    ||', pr_nrdconta:'||pr_nrdconta
                    ||', pr_nrcnvcob:'||pr_nrcnvcob
                    ||', pr_nrdocmto:'||pr_nrdocmto
                    ||', pr_dtmvtolt:'||pr_dtmvtolt
                    ||', pr_cdoperad:'||pr_cdoperad
                    ||', pr_nrremass:'||pr_nrremass;

      -- Buscar parâmetros do cadastro de cobrança
      OPEN  cr_crapcco(pr_cdcooper => pr_cdcooper
                      ,pr_nrconven => pr_nrcnvcob);
      FETCH cr_crapcco INTO rw_crapcco;
      -- Se não encontrar registro
      IF cr_crapcco%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcco;
        vr_cdcritic := 1179;
        vr_dscritic := gene0001.fn_busca_critica(1179); --Registro de cobranca nao encontrado
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcco;

      --Selecionar registro cobranca
      OPEN cr_crapcob (pr_cdcooper => pr_cdcooper
                      ,pr_cdbandoc => rw_crapcco.cddbanco
                      ,pr_nrdctabb => rw_crapcco.nrdctabb
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrcnvcob => pr_nrcnvcob
                      ,pr_nrdocmto => pr_nrdocmto);
      --Posicionar no proximo registro
      FETCH cr_crapcob INTO rw_crapcob;
      --Se nao encontrar
      IF cr_crapcob%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcob;
        --Mensagem Critica
        vr_dscritic := gene0001.fn_busca_critica(1179);  --Registro de cobranca nao encontrado
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcob;

      --Solicitar Baixa do Titulo
      COBR0007.pc_inst_pedido_baixa (pr_idregcob  => rw_crapcob.rowid   --Rowid Cobranca
                                    ,pr_cdocorre  => 2                     --Codigo Ocorrencia
                                    ,pr_dtmvtolt  => pr_dtmvtolt           --Data pagamento
                                    ,pr_cdoperad  => pr_cdoperad           --Operador
                                    ,pr_nrremass  => pr_nrremass           --Numero da Remessa
                                    ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                    ,pr_cdcritic  => vr_cdcritic           --Codigo da Critica
                                    ,pr_dscritic  => vr_dscritic);         --Descricao da critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_baixar');
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic||vr_dsparame;

        --Grava tabela de log - Ch REQ0011728
        pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 1,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 1);
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        -- Erro
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_sustar_baixar. '||sqlerrm;

        --Grava tabela de log - Ch REQ0011728
        pc_gera_log(pr_cdcooper      => pr_cdcooper,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic||vr_dsparame,
                    pr_cdcriticidade => 2,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 2);
    END;
  END pc_inst_sustar_baixar;

  -- Procedure para Conceder Abatimento
  PROCEDURE pc_inst_conc_abatimento (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                    ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                    ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                    ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                    ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                    ,pr_vlabatim  IN crapcob.vlabatim%TYPE --> Valor de Abatimento
                                    ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                    ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                    ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                    ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_conc_abatimento          Antigo: b1wgen0088.p/inst-conc-abatimento
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Douglas Quisinski
    --  Data     : Janeiro/2016                     Ultima atualizacao: 27/02/2019
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Conceder Abatimento
    --
    --   Alteracao : 12/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            (Ana - Envolti - Ch. REQ0011728)
    --
    --               12/02/2019 - Teste Revitalização
    --                            (Belli - Envolti - Ch. REQ0035813)
    --           
    --               27/02/2019 - Regra deve considerar o sinal de igual para criticar o valor de abatimento
    --                           (Envolti - Belli - INC0032975)    
    --
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_des_erro   VARCHAR2(3);
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_cdcritic2  PLS_INTEGER;
    vr_dscritic2  VARCHAR2(4000);
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_vltitabr   NUMBER(25,2);
    -- Registro da Cooperativa
    rw_crapcop    COBR0007.cr_crapcop%ROWTYPE;
    -- Registro de Cobrança
    rw_crapcob    COBR0007.cr_crapcob%ROWTYPE;
    -- Registro de Remessa
    rw_craprem    COBR0007.cr_craprem%ROWTYPE;
    -- Registro de controle retorno titulos bancarios
    rw_crapcre    COBR0007.cr_crapcre%ROWTYPE;
    -- Registro de cadastro de cobranca
    rw_crapcco    COBR0007.cr_crapcco%ROWTYPE;
    --Tabelas de Memoria de Remessa
    vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
    vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
    
    vr_nrremret   INTEGER; --Numero Remessa
    vr_rowid_ret  ROWID;   --ROWID Remessa Retorno
    vr_nrseqreg   INTEGER; --Numero Sequencial registro
    vr_index_lat  VARCHAR2(60);

  BEGIN
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                  ||', pr_nrdconta:'||pr_nrdconta
                  ||', pr_nrcnvcob:'||pr_nrcnvcob
                  ||', pr_nrdocmto:'||pr_nrdocmto
                  ||', pr_cdocorre:'||pr_cdocorre
                  ||', pr_dtmvtolt:'||pr_dtmvtolt
                  ||', pr_cdoperad:'||pr_cdoperad
                  ||', pr_vlabatim:'||pr_vlabatim
                  ||', pr_nrremass:'||pr_nrremass;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;
    
    -- Processo de Validacao Recusas Padrao
    COBR0007.pc_efetua_val_recusa_padrao(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                        ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                        ,pr_nrcnvcob => pr_nrcnvcob   --> Numero Convenio
                                        ,pr_nrdocmto => pr_nrdocmto   --> Numero Documento
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Data Movimento
                                        ,pr_cdoperad => pr_cdoperad   --> Operador
                                        ,pr_cdinstru => '04'          --> Codigo Instrucao
                                        ,pr_nrremass => pr_nrremass   --> Numero da Remessa
                                        ,pr_rw_crapcob => rw_crapcob  --> Registro de Cobranca de Recusa
                                        ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                        ,pr_dscritic => vr_dscritic); --> Descricao da Critica
    
    --Se ocorrer Erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');

    IF rw_crapcob.cdbandoc = 085  AND
       rw_crapcob.flgregis = 1    AND 
       rw_crapcob.flgcbdda = 1    AND 
       rw_crapcob.insitpro <= 2   THEN
      -- Gerar o retorno para o cooperado 
       COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XA' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1180);  --Titulo em processo de registro. Favor aguarda
      RAISE vr_exc_erro;
    END IF;
    
    ---- VALIDACOES PARA RECUSAR ----
    -- Verifica se ja existe Pedido de Baixa
    OPEN cr_crapcre (pr_cdcooper => pr_cdcooper
                    ,pr_nrcnvcob => pr_nrcnvcob
                    ,pr_dtmvtolt => pr_dtmvtolt
                    ,pr_intipmvt => 1);
    --Proximo registro
    FETCH cr_crapcre INTO rw_crapcre;
    --Se Encontrou
    IF cr_crapcre%FOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcre;
      --Selecionar remessa
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_cdocorre => 2
                      ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem;
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XB' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');
        
        -- Recusar a instrucao
        vr_dscritic := gene0001.fn_busca_critica(1319);  --Pedido de Baixa ja efetuado - Abatimento nao efetuado
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_craprem%ISOPEN THEN
        CLOSE cr_craprem;
      END IF;
    END IF;
    --Fechar Cursor
    IF cr_crapcre%ISOPEN THEN
      CLOSE cr_crapcre;
    END IF;

    -- Verificar o indicador da situacao cartoraria
    IF rw_crapcob.insitcrt = 1 THEN
      -- 1 = C/Inst Protesto
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XE' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1320);  --Boleto c/ Remessa a Cartorio - Abatimento nao efetuado

      RAISE vr_exc_erro;
    ELSIF rw_crapcob.insitcrt = 3 THEN
      -- 3 = Em Cartorio
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XF' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1321);  --Boleto em Cartorio - Abatimento nao efetuado
      RAISE vr_exc_erro;
    END IF;
    
    -- Calcular o valor com os abatimentos 
    vr_vltitabr := rw_crapcob.vltitulo - rw_crapcob.vldescto - rw_crapcob.vlabatim;
    IF  pr_vlabatim >= vr_vltitabr THEN -- Regra deve considerar o sinal de igual - 27/02/2019 - INC0032975
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => '34' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1322);  --Valor de Abatimento superior ao Valor do Boleto - Abatimento nao efetuado
      RAISE vr_exc_erro;
    END IF;

    vr_vltitabr := rw_crapcob.vltitulo - rw_crapcob.vldescto - pr_vlabatim;
    --> Verificar se valor do titulo ficará menor que o valor minimo
    IF rw_crapcob.inpagdiv = 1 AND 
       rw_crapcob.vlminimo > vr_vltitabr THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => '34' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1323);  --Valor de Abatimento maior que o permitido devido ao Valor minimo boleto - Abatimento nao efetuado
      RAISE vr_exc_erro;
    END IF;

    -- Nao permitir conceder abatimento de titulo no convenio de protesto
    IF rw_crapcob.cdbandoc <> rw_crapcop.cdbcoctl THEN
      OPEN cr_crapcco(pr_cdcooper => rw_crapcob.cdcooper,
                      pr_nrconven => rw_crapcob.nrcnvcob);
      FETCH cr_crapcco INTO rw_crapcco;
      IF cr_crapcco%FOUND THEN
        CLOSE cr_crapcco;
        IF rw_crapcco.dsorgarq = 'PROTESTO' THEN
          -- Gerar o retorno para o cooperado 
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                             ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                             ,pr_cdmotivo => 'XG' -- Motivo
                                             ,pr_vltarifa => 0    -- Valor da Tarifa  
                                             ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                             ,pr_cdagectl => rw_crapcop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_nrremass => pr_nrremass
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
          -- Verifica se ocorreu erro durante a execucao
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');
          
          -- Recusar a instrucao
          vr_dscritic := gene0001.fn_busca_critica(1324);  --Nao e permitido conceder abatimento de boleto no convenio protesto - Abatimento nao efetuado
          RAISE vr_exc_erro;
        END IF;
    ELSE
      CLOSE cr_crapcco;
    END IF;    
    END IF;    
    ---- FIM - VALIDACOES PARA RECUSAR ----
    
    IF rw_crapcob.flgcbdda = 1 AND
       rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN
      -- Executa procedimentos do DDA-JD 
      DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob.rowid         --ROWID da Cobranca
                                       ,pr_tpoperad  => 'A'                      --Tipo Operacao
                                       ,pr_tpdbaixa  => ' '                      --Tipo de Baixa
                                       ,pr_dtvencto  => rw_crapcob.dtvencto      --Data Vencimento
                                       ,pr_vldescto  => rw_crapcob.vldescto      --Valor Desconto
                                       ,pr_vlabatim  => pr_vlabatim              --Valor Abatimento
                                       ,pr_flgdprot  => rw_crapcob.flgdprot      --Flag Protesto
                                       ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa
                                       ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela memoria retorno DDA
                                       ,pr_cdcritic        => vr_cdcritic2       --Codigo Critica
                                       ,pr_dscritic        => vr_dscritic2);     --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic2,0) <> 0 OR TRIM(vr_dscritic2) IS NOT NULL THEN
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XC' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
          
        vr_cdcritic := vr_cdcritic2;
        vr_dscritic := vr_dscritic2;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');
    
    -- tratamento para titulos migrados
    IF rw_crapcob.flgregis = 1    AND
       rw_crapcob.cdbandoc = 001  THEN
      -- Realizar a pesquisa dos Parâmetros do cadastro de cobrança
      OPEN cr_crapcco (pr_cdcooper => rw_crapcob.cdcooper,
                       pr_nrconven => rw_crapcob.nrcnvcob);
      FETCH cr_crapcco INTO rw_crapcco;
      IF cr_crapcco%FOUND AND rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
        --Fechar Cursor
        CLOSE cr_crapcco;
        --Protesta titulo Migrado
        COBR0007.pc_inst_titulo_migrado (pr_idregcob => rw_crapcob     --Rowtype da Cobranca
                                        ,pr_dsdinstr => 'Abatimento'   --Descricao da Instrucao
                                        ,pr_dtaltvct => NULL           --Data Alteracao Vencimento
                                        ,pr_vlaltabt => pr_vlabatim    --Valor Alterado Abatimento
                                        ,pr_nrdctabb => rw_crapcco.nrdctabb --Numero da Conta BB
                                        ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                        ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');
        -- Recusar a instrucao
        vr_dscritic := gene0001.fn_busca_critica(1325);  --Solicitacao de abatimento de titulo migrado. Aguarde confirmacao no proximo dia util
        RAISE vr_exc_erro;
      ELSE 
        CLOSE cr_crapcco;
      END IF;
    END IF;
    
    -- Atualizar o valor de abatimento
    rw_crapcob.vlabatim := pr_vlabatim;
    
    --Se tem remesssa dda na tabela
    IF vr_tab_remessa_dda.COUNT > 0 THEN
      rw_crapcob.idopeleg:= vr_tab_remessa_dda(vr_tab_remessa_dda.LAST).idopeleg;
    END IF;

    --Atualizar Cobranca
    BEGIN
      UPDATE crapcob SET crapcob.vlabatim = rw_crapcob.vlabatim,
                         crapcob.idopeleg = rw_crapcob.idopeleg
      WHERE crapcob.rowid = rw_crapcob.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        vr_cdcritic := 1035;  --Erro ao atualizar crapcob 
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                       ' vlabatim:'||rw_crapcob.vlabatim||
                       ', idopeleg:'||rw_crapcob.idopeleg||
                       ' com rowid:'||rw_crapcob.rowid||
                       '. '||sqlerrm;
        RAISE vr_exc_erro;
    END;

    IF rw_crapcob.cdbandoc = 1 THEN
      -- Verifica se ha instr. de Canc. Abatim. no dia e elimina
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_cdocorre => 5
                      ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        -- LOG de Processo
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                     ,pr_dsmensag => 'Exclusao Instrucao ' ||
                                                     'Cancelamento de Abatimento' --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro   --Indicador erro
                                     ,pr_dscritic => vr_dscritic); --Descricao erro
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');

        -- Exclui o Instrucao de Remessa
        COBR0007.pc_elimina_remessa (pr_cdcooper => rw_craprem.cdcooper  --Codigo Cooperativa
                                    ,pr_nrdconta => rw_craprem.nrdconta  --Numero da Conta
                                    ,pr_nrcnvcob => rw_craprem.nrcnvcob  --Numero Convenio
                                    ,pr_nrdocmto => rw_craprem.nrdocmto  --Numero Documento
                                    ,pr_cdocorre => rw_craprem.cdocorre  --Ocorrencia
                                    ,pr_dtmvtolt => rw_craprem.dtaltera  --Data Movimentacao
                                    ,pr_des_erro => vr_des_erro          --Indicador Erro
                                    ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                    ,pr_dscritic => vr_dscritic);        --Descricao Critica
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');
      ELSE 
        CLOSE cr_craprem;
      END IF;
      
      -- Verifica se ja existe Instr.Conc.Abatimento e substitui
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_cdocorre => pr_cdocorre
                      ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        -- LOG de Processo
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                     ,pr_dsmensag => 'Exclusao Instr.Conc.Abatimento ' ||
                                                     'Vlr: R$ ' || 
                                                     TRIM(to_char(rw_craprem.vlabatim,'9g999g990d00')) --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro   --Indicador erro
                                     ,pr_dscritic => vr_dscritic); --Descricao erro
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');

        -- Exclui o Instrucao de Remessa
        COBR0007.pc_elimina_remessa (pr_cdcooper => rw_craprem.cdcooper  --Codigo Cooperativa
                                    ,pr_nrdconta => rw_craprem.nrdconta  --Numero da Conta
                                    ,pr_nrcnvcob => rw_craprem.nrcnvcob  --Numero Convenio
                                    ,pr_nrdocmto => rw_craprem.nrdocmto  --Numero Documento
                                    ,pr_cdocorre => rw_craprem.cdocorre  --Ocorrencia
                                    ,pr_dtmvtolt => rw_craprem.dtaltera  --Data Movimentacao
                                    ,pr_des_erro => vr_des_erro          --Indicador Erro
                                    ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                    ,pr_dscritic => vr_dscritic);        --Descricao Critica
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');

      ELSE 
        CLOSE cr_craprem;
      END IF;

      --Preparar remessa banco
      PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Cooperativa
                                     ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                     ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                     ,pr_cdoperad => pr_cdoperad --Codigo Operador
									 ,pr_idregcob => rw_crapcob.rowid
                                     ,pr_nrremret => vr_nrremret --Numero Remessa
                                     ,pr_rowid_ret => vr_rowid_ret --ROWID Remessa Retorno
                                     ,pr_nrseqreg => vr_nrseqreg --Numero Sequencial registro
                                     ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                     ,pr_dscritic => vr_dscritic); --Descricao Critica
      --Se Ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');
      --Incrementar sequencial
      vr_nrseqreg:= Nvl(vr_nrseqreg,0) + 1;
      --Criar tabela Remessa
      PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                   ,pr_nrremret => vr_nrremret      --Numero Remessa
                                   ,pr_nrseqreg => vr_nrseqreg      --Numero Sequencial
                                   ,pr_cdocorre => pr_cdocorre      --Codigo Ocorrencia
                                   ,pr_cdmotivo => NULL             --Codigo Motivo
                                   ,pr_dtdprorr => NULL             --Data Prorrogacao
                                   ,pr_vlabatim => pr_vlabatim      --Valor Abatimento
                                   ,pr_cdoperad => pr_cdoperad      --Codigo Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt      --Data Movimento
                                   ,pr_cdcritic => vr_cdcritic      --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);    --Descricao Critica
      --Se Ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');
      -- FIM do IF cdbandoc = 1
    ELSE 
      IF rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl THEN 
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 12   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => NULL -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');
      END IF; -- FIM do IF cdbandoc = 85
    END IF;

    -- LOG de Processo
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                 ,pr_cdoperad => pr_cdoperad   --Operador
                                 ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                 ,pr_dsmensag => 'Concessao de Abatimento no valor de R$ ' || 
                                                 TRIM(to_char(pr_vlabatim,'9g999g990d00')) --Descricao Mensagem
                                 ,pr_des_erro => vr_des_erro   --Indicador erro
                                 ,pr_dscritic => vr_dscritic); --Descricao erro
    --Se ocorreu erro
    IF vr_des_erro = 'NOK' THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_abatimento');

    IF rw_crapcob.cdbandoc = 85 THEN
      -- Gerar registro Tarifa
      vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                     lpad(pr_nrdconta,10,'0')||
                     lpad(pr_nrcnvcob,10,'0')||
                     lpad(19,10,'0')||
                     lpad('0',10,'0')||
                     lpad(pr_tab_lat_consolidada.COUNT+1,10,'0');
      -- Gerar registro Tarifa 
      pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
      pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
      pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
      pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
      pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
      pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 12;    -- 12 - Conf. Receb. Instr. Abatimento
      pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= NULL;  -- Motivo
      pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    
        --Grava tabela de log - Ch REQ0011728
        pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic||vr_dsparame,
                    pr_cdcriticidade => 1,
                    pr_cdmensagem    => nvl(pr_cdcritic,0),
                    pr_ind_tipo_log  => 1);
      -- Ajuste mensagem - 12/02/2019 - REQ0035813
      IF nvl(pr_cdcritic,0) IN ( 1197, 9999, 1034, 1035, 1036, 1037 ) THEN
        pr_cdcritic := 1224;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      ELSIF nvl(pr_cdcritic,0) = 0 AND
            SUBSTR(pr_dscritic, 1, 7 ) IN ( '1197 - ', '9999 - ', '1034 - ', '1035 - ', '1036 - ', '1037 - ' ) THEN
        pr_cdcritic := 1224;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_conc_abatimento. '||sqlerrm||vr_dsparame;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

      pr_cdcritic := 1224; -- Ajuste mensagem - 12/02/2019 - REQ0035813
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
  END pc_inst_conc_abatimento;

  -- Procedure para Cancelar Abatimento
  PROCEDURE pc_inst_canc_abatimento (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                    ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                    ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                    ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                    ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                    ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                    ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                    ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                    ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_canc_abatimento          Antigo: b1wgen0088.p/inst-canc-abatimento
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Douglas Quisinski
    --  Data     : Janeiro/2016                     Ultima atualizacao: 12/02/2019
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Cancelar Abatimento
    --
    --   Alteracao : 12/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            (Ana - Envolti - Ch. REQ0011728)
    --
    --               12/02/2019 - Teste Revitalização
    --                            (Belli - Envolti - Ch. REQ0035813)     
    --                            
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_cdcritic2  PLS_INTEGER;
    vr_dscritic2  VARCHAR2(4000);
    vr_des_erro   VARCHAR2(3);
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    -- Registro da Cooperativa
    rw_crapcop    COBR0007.cr_crapcop%ROWTYPE;
    -- Registro de Cobrança
    rw_crapcob    COBR0007.cr_crapcob%ROWTYPE;
    -- Registro de Remessa
    rw_craprem    COBR0007.cr_craprem%ROWTYPE;
    -- Registro de controle retorno titulos bancarios
    rw_crapcre    COBR0007.cr_crapcre%ROWTYPE;
    -- Registro de cadastro de cobranca
    rw_crapcco    COBR0007.cr_crapcco%ROWTYPE;

    --Tabelas de Memoria de Remessa
    vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
    vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
    
    vr_index_lat  VARCHAR2(60);
    --Variaveis Locais
    vr_nrremret INTEGER;
    vr_nrseqreg INTEGER;
    vr_rowid_ret ROWID;

  BEGIN
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                  ||', pr_nrdconta:'||pr_nrdconta
                  ||', pr_nrcnvcob:'||pr_nrcnvcob
                  ||', pr_nrdocmto:'||pr_nrdocmto
                  ||', pr_cdocorre:'||pr_cdocorre
                  ||', pr_dtmvtolt:'||pr_dtmvtolt
                  ||', pr_cdoperad:'||pr_cdoperad
                  ||', pr_nrremass:'||pr_nrremass;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;
    
    -- Processo de Validacao Recusas Padrao
    COBR0007.pc_efetua_val_recusa_padrao(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                        ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                        ,pr_nrcnvcob => pr_nrcnvcob   --> Numero Convenio
                                        ,pr_nrdocmto => pr_nrdocmto   --> Numero Documento
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Data Movimento
                                        ,pr_cdoperad => pr_cdoperad   --> Operador
                                        ,pr_cdinstru => '05'          --> Codigo Instrucao
                                        ,pr_nrremass => pr_nrremass   --> Numero da Remessa
                                        ,pr_rw_crapcob => rw_crapcob  --> Registro de Cobranca de Recusa
                                        ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                        ,pr_dscritic => vr_dscritic); --> Descricao da Critica
    
    --Se ocorrer Erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');
    
    IF rw_crapcob.cdbandoc = 085 AND
       rw_crapcob.flgregis = 1   AND 
       rw_crapcob.flgcbdda = 1   AND 
       rw_crapcob.insitpro <= 2  THEN
      -- Gerar o retorno para o cooperado 
       COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XA' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1180);  --Titulo em processo de registro. Favor aguardar
      RAISE vr_exc_erro;
    END IF;
    
    -----  VALIDACOES PARA RECUSAR  -----
    IF rw_crapcob.insitcrt = 1 THEN
      -- Gerar o retorno para o cooperado 
       COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XE' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1326);  --Boleto com Remessa a Cartorio - Cancelamento Abatimento nao efetuado
      RAISE vr_exc_erro;
    ELSIF rw_crapcob.insitcrt = 3 THEN
      -- Gerar o retorno para o cooperado 
       COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XF' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');

      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1327);  --Boleto em Cartorio - Cancelamento Abatimento nao efetuado
      RAISE vr_exc_erro;
    END IF;
    
    -- Verifica se ja existe Pedido de Baixa
    OPEN cr_crapcre (pr_cdcooper => pr_cdcooper
                    ,pr_nrcnvcob => pr_nrcnvcob
                    ,pr_dtmvtolt => pr_dtmvtolt
                    ,pr_intipmvt => 1);
    --Proximo registro
    FETCH cr_crapcre INTO rw_crapcre;
    --Se Encontrou
    IF cr_crapcre%FOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcre;
      --Selecionar remessa
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_cdocorre => 2
                      ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem;
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XB' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');
        
        -- Recusar a instrucao
        vr_dscritic := gene0001.fn_busca_critica(1328);  --Pedido de Baixa ja efetuado - Cancelamento Abatimento nao efetuado!';
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_craprem%ISOPEN THEN
        CLOSE cr_craprem;
      END IF;
    END IF;
    --Fechar Cursor
    IF cr_crapcre%ISOPEN THEN
      CLOSE cr_crapcre;
    END IF;

    IF rw_crapcob.vlabatim = 0 THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'A7' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');

      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1329);  --Boleto sem Valor de Abatimento - Cancelamento Abatimento nao efetuado
      RAISE vr_exc_erro;
    END IF;
    ----- FIM - VALIDACOES PARA RECUSAR -----

    IF rw_crapcob.flgcbdda = 1 AND
       rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN 
      -- Executa procedimentos do DDA-JD 
      DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob.rowid         --ROWID da Cobranca
                                       ,pr_tpoperad  => 'A'                      --Tipo Operacao
                                       ,pr_tpdbaixa  => ' '                      --Tipo de Baixa
                                       ,pr_dtvencto  => rw_crapcob.dtvencto      --Data Vencimento
                                       ,pr_vldescto  => rw_crapcob.vldescto      --Valor Desconto
                                       ,pr_vlabatim  => 0                        --Valor Abatimento
                                       ,pr_flgdprot  => rw_crapcob.flgdprot      --Flag Protesto
                                       ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa
                                       ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela memoria retorno DDA
                                       ,pr_cdcritic        => vr_cdcritic2       --Codigo Critica
                                       ,pr_dscritic        => vr_dscritic2);     --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic2,0) <> 0 OR TRIM(vr_dscritic2) IS NOT NULL THEN
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XC' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
          
        vr_cdcritic := vr_cdcritic2;
        vr_dscritic := vr_dscritic2;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');

    -- Tratamento para titulos migrado
    IF rw_crapcob.flgregis = 1 AND rw_crapcob.cdbandoc = 001 THEN
      --Selecionar cadastro convenio
      OPEN cr_crapcco (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrconven => rw_crapcob.nrcnvcob);
      --Proximo registro
      FETCH cr_crapcco INTO rw_crapcco;
        --Se encontrou
        IF cr_crapcco%FOUND AND rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
          --Fechar Cursor
          CLOSE cr_crapcco;
          --Protesta titulo Migrado
          COBR0007.pc_inst_titulo_migrado (pr_idregcob => rw_crapcob --Rowtype da Cobranca
                                          ,pr_dsdinstr => 'Cancelamento de abatimento' --Descricao da Instrucao
                                          ,pr_dtaltvct => NULL       --Data Alteracao Vencimento
                                          ,pr_vlaltabt => 0          --Valor Alterado Abatimento
                                          ,pr_nrdctabb => rw_crapcco.nrdctabb --Numero da Conta BB
                                          ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                          ,pr_dscritic => vr_dscritic); --Descricao Critica
          --Se Ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');
          
          -- Gerar o retorno para o cooperado 
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                             ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                             ,pr_cdmotivo => 'XH' -- Motivo
                                             ,pr_vltarifa => 0    -- Valor da Tarifa  
                                             ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                             ,pr_cdagectl => rw_crapcop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_nrremass => pr_nrremass
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
          -- Verifica se ocorreu erro durante a execucao
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');

          vr_dscritic := gene0001.fn_busca_critica(1330);  --Solicitacao de cancelamento de abatimento de titulo migrado. Aguarde confirmacao no proximo dia util
          --Retornar
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        IF cr_crapcco%ISOPEN THEN
          CLOSE cr_crapcco;
        END IF;
      END IF;
       
      --Se tem remesssa dda na tabela
      IF vr_tab_remessa_dda.COUNT > 0 THEN
        rw_crapcob.idopeleg:= vr_tab_remessa_dda(vr_tab_remessa_dda.LAST).idopeleg;
      END IF;

      -- Cancela o abatimento concedido anteriormente
      IF rw_crapcob.vlabatim > 0 THEN
        rw_crapcob.vlabatim := 0;
      END IF;
      
      --Atualizar Cobranca
      BEGIN
        UPDATE crapcob SET crapcob.vlabatim = rw_crapcob.vlabatim,
                           crapcob.idopeleg = rw_crapcob.idopeleg
        WHERE crapcob.rowid = rw_crapcob.rowid;

      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

          vr_cdcritic := 1035;  --Erro ao atualizar crapcob 
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                         ' vlabatim:'||rw_crapcob.vlabatim||
                         ', idopeleg:'||rw_crapcob.idopeleg||
                         ' com rowid:'||rw_crapcob.rowid||
                         '. '||sqlerrm;
          RAISE vr_exc_erro;
      END;

      IF rw_crapcob.cdbandoc = 1 THEN 
        -- Verifica se tem instrucao de abatimento e exclui
        OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                        ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                        ,pr_nrdconta => rw_crapcob.nrdconta
                        ,pr_nrdocmto => rw_crapcob.nrdocmto
                        ,pr_cdocorre => 4
                        ,pr_dtaltera => pr_dtmvtolt);
        FETCH cr_craprem INTO rw_craprem;
        --Se Encontrou
        IF cr_craprem%FOUND THEN
          CLOSE cr_craprem;
          -- LOG de Processo
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                       ,pr_cdoperad => pr_cdoperad   --Operador
                                       ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                       ,pr_dsmensag => 'Exclusao Instrucao  ' ||
                                                       'Concessao de Abatimento'   --Descricao Mensagem
                                       ,pr_des_erro => vr_des_erro   --Indicador erro
                                       ,pr_dscritic => vr_dscritic); --Descricao erro
          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');

          -- Exclui o Instrucao de Remessa que ja existe
          COBR0007.pc_elimina_remessa (pr_cdcooper => rw_craprem.cdcooper  --Codigo Cooperativa
                                      ,pr_nrdconta => rw_craprem.nrdconta  --Numero da Conta
                                      ,pr_nrcnvcob => rw_craprem.nrcnvcob  --Numero Convenio
                                      ,pr_nrdocmto => rw_craprem.nrdocmto  --Numero Documento
                                      ,pr_cdocorre => rw_craprem.cdocorre  --Ocorrencia
                                      ,pr_dtmvtolt => rw_craprem.dtaltera  --Data Movimentacao
                                      ,pr_des_erro => vr_des_erro          --Indicador Erro
                                      ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                      ,pr_dscritic => vr_dscritic);        --Descricao Critica
          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');
        END IF;
        
        -- Fechar o crusor da remessa
        IF cr_craprem%ISOPEN THEN
          CLOSE cr_craprem;
        END IF;
                        
        -- Verifica se ja existe Instr.Canc.Abatimento e substitui
        OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                        ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                        ,pr_nrdconta => rw_crapcob.nrdconta
                        ,pr_nrdocmto => rw_crapcob.nrdocmto
                        ,pr_cdocorre => pr_cdocorre
                        ,pr_dtaltera => pr_dtmvtolt);
        FETCH cr_craprem INTO rw_craprem;
        --Se Encontrou
        IF cr_craprem%FOUND THEN
          CLOSE cr_craprem;
          -- LOG de Processo
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                       ,pr_cdoperad => pr_cdoperad   --Operador
                                       ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                       ,pr_dsmensag => 'Exclusao Instrucao ' ||
                                                       'Cancelamento de Abatimento'   --Descricao Mensagem
                                       ,pr_des_erro => vr_des_erro   --Indicador erro
                                       ,pr_dscritic => vr_dscritic); --Descricao erro
          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');

          -- Exclui o Instrucao de Remessa que ja existe
          COBR0007.pc_elimina_remessa (pr_cdcooper => rw_craprem.cdcooper  --Codigo Cooperativa
                                      ,pr_nrdconta => rw_craprem.nrdconta  --Numero da Conta
                                      ,pr_nrcnvcob => rw_craprem.nrcnvcob  --Numero Convenio
                                      ,pr_nrdocmto => rw_craprem.nrdocmto  --Numero Documento
                                      ,pr_cdocorre => rw_craprem.cdocorre  --Ocorrencia
                                      ,pr_dtmvtolt => rw_craprem.dtaltera  --Data Movimentacao
                                      ,pr_des_erro => vr_des_erro          --Indicador Erro
                                      ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                      ,pr_dscritic => vr_dscritic);        --Descricao Critica
          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');
        END IF;
        
        -- Fechar o crusor da remessa
        IF cr_craprem%ISOPEN THEN
          CLOSE cr_craprem;
        END IF;
        
        -- gerar pedido de remessa
        PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                       ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                       ,pr_dtmvtolt => pr_dtmvtolt         --Data movimento
                                       ,pr_cdoperad => pr_cdoperad         --Codigo Operador
									   ,pr_idregcob => rw_crapcob.rowid
                                       ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                       ,pr_rowid_ret => vr_rowid_ret       --ROWID Remessa Retorno
                                       ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
        --Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');
        --Incrementar Sequencial
        vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;
        --Criar tabela Remessa
        PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                     ,pr_nrremret => vr_nrremret          --Numero Remessa
                                     ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                     ,pr_cdocorre => pr_cdocorre          --Codigo Ocorrencia --> 5 - Canc. Abamtimento
                                     ,pr_cdmotivo => NULL                 --Codigo Motivo
                                     ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                     ,pr_vlabatim => 0                    --Valor Abatimento
                                     ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                     ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                     ,pr_dscritic => vr_dscritic);        --Descricao Critica
        --Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');
      ELSE
        IF rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl THEN 
          -- Gerar o retorno para o cooperado 
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                             ,pr_cdocorre => 13   -- Confirmacao Recebimento Instrucao de Cancelamento Abatimento
                                             ,pr_cdmotivo => NULL -- Motivo
                                             ,pr_vltarifa => 0    -- Valor da Tarifa  
                                             ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                             ,pr_cdagectl => rw_crapcop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_nrremass => pr_nrremass
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
          -- Verifica se ocorreu erro durante a execucao
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');
        -- FIM do IF cdbandoc = 85
        END IF;
      END IF;

      -- LOG de Processo
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                   ,pr_cdoperad => pr_cdoperad   --Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                   ,pr_dsmensag => 'Cancelamento de abatimento'   --Descricao Mensagem
                                   ,pr_des_erro => vr_des_erro   --Indicador erro
                                   ,pr_dscritic => vr_dscritic); --Descricao erro
      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_abatimento');

      IF rw_crapcob.cdbandoc = 85 THEN
        --Montar Indice para lancamento tarifa
        vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                       lpad(pr_nrdconta,10,'0')||
                       lpad(pr_nrcnvcob,10,'0')||
                       lpad(19,10,'0')||
                       lpad('0',10,'0')||
                       lpad(pr_tab_lat_consolidada.Count+1,10,'0');
        -- Gerar registro Tarifa 
        pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
        pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
        pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
        pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
        pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
        pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 13;    -- 13 - Confirmacao Recebimento Instrucao de Cancelamento Abatimento
        pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= NULL;  -- Motivo
        pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;
      END IF;                  

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic||vr_dsparame;
      
      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);
      -- Ajuste mensagem - 12/02/2019 - REQ0035813
      IF nvl(pr_cdcritic,0) IN ( 1197, 9999, 1034, 1035, 1036, 1037 ) THEN
        pr_cdcritic := 1224;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      ELSIF nvl(pr_cdcritic,0) = 0 AND
            SUBSTR(pr_dscritic, 1, 7 ) IN ( '1197 - ', '9999 - ', '1034 - ', '1035 - ', '1036 - ', '1037 - ' ) THEN
        pr_cdcritic := 1224;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_canc_abatimento. '||sqlerrm||vr_dsparame;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

      pr_cdcritic := 1224; -- Ajuste mensagem - 12/02/2019 - REQ0035813
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
  END pc_inst_canc_abatimento;

  -- Procedure para Alteracao do Vencimento
  PROCEDURE pc_inst_alt_vencto (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                               ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                               ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                               ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                               ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                               ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                               ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                               ,pr_dtvencto  IN crapcob.dtvencto%TYPE --> Data de vencimento
                               ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                               ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                               ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                               ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_alt_vencto               Antigo: b1wgen0088.p/inst-alt-vencto
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Douglas Quisinski
    --  Data     : Janeiro/2016                     Ultima atualizacao: 24/08/201819/01/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Alterar o vencimento
    --
    --   Alteracao : 19/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            Em um momento não estava logando o retorno da cobr0006.pc_prep_retorno_cooper_90
    --                            Agora vai logar, mas sem parar a execução do programa
    --                            (Ana - Envolti - Ch. REQ0011728 / REQ0031757)
	--
	--               01/10/2018 - Removida validacao quando data de vencto for menor que vencto atual
    --                            Andre Clemer (Supero)
	--
    --               07/11/2018 - Ajuste de mensagem para usuario final
    --                            (Belli - Envolti - Ch. INC0026760)
    --
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_cdcritic2  PLS_INTEGER;
    vr_dscritic2  VARCHAR2(4000);
    vr_des_erro   VARCHAR2(3);
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    -- Registro da Cooperativa
    rw_crapcop    COBR0007.cr_crapcop%ROWTYPE;
    -- Registro de Cobrança
    rw_crapcob    COBR0007.cr_crapcob%ROWTYPE;
    -- Registro de Remessa
    rw_craprem    COBR0007.cr_craprem%ROWTYPE;
    -- Registro de controle retorno titulos bancarios
    rw_crapcre    COBR0007.cr_crapcre%ROWTYPE;
    -- Registro de cadastro de cobranca
    rw_crapcco    COBR0007.cr_crapcco%ROWTYPE;

    --Tabelas de Memoria de Remessa
    vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
    vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
    
    vr_dtvencto_old DATE;
    vr_nrremret     INTEGER;
    vr_nrseqreg     INTEGER;
    vr_rowid_ret    ROWID;
    vr_index_lat    VARCHAR2(60);

  BEGIN
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                  ||', pr_nrdconta:'||pr_nrdconta
                  ||', pr_nrcnvcob:'||pr_nrcnvcob
                  ||', pr_nrdocmto:'||pr_nrdocmto
                  ||', pr_cdocorre:'||pr_cdocorre
                  ||', pr_dtmvtolt:'||pr_dtmvtolt
                  ||', pr_cdoperad:'||pr_cdoperad
                  ||', pr_dtvencto:'||pr_dtvencto
                  ||', pr_nrremass:'||pr_nrremass;

    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;

    -- Processo de Validacao Recusas Padrao
    COBR0007.pc_efetua_val_recusa_padrao(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                        ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                        ,pr_nrcnvcob => pr_nrcnvcob   --> Numero Convenio
                                        ,pr_nrdocmto => pr_nrdocmto   --> Numero Documento
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Data Movimento
                                        ,pr_cdoperad => pr_cdoperad   --> Operador
                                        ,pr_cdinstru => '06'          --> Codigo Instrucao
                                        ,pr_nrremass => pr_nrremass   --> Numero da Remessa
                                        ,pr_rw_crapcob => rw_crapcob  --> Registro de Cobranca de Recusa
                                        ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                        ,pr_dscritic => vr_dscritic); --> Descricao da Critica
    
    --Se ocorrer Erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');
    
    IF rw_crapcob.cdbandoc = 085 AND
       rw_crapcob.flgregis = 1   AND 
       rw_crapcob.flgcbdda = 1   AND 
       rw_crapcob.insitpro <= 2  THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XA' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');

      -- Recusar a instrucao
      --Inclusão vr_cdcritic
      vr_cdcritic := 1180;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  --Titulo em processo de registro. Favor aguardar
      RAISE vr_exc_erro;
    END IF;

    -----  VALIDACOES PARA RECUSAR  -----
    -- Verifica se ja existe Pedido de Baixa
    OPEN cr_crapcre (pr_cdcooper => pr_cdcooper
                    ,pr_nrcnvcob => pr_nrcnvcob
                    ,pr_dtmvtolt => pr_dtmvtolt
                    ,pr_intipmvt => 1);
    --Proximo registro
    FETCH cr_crapcre INTO rw_crapcre;
    --Se Encontrou
    IF cr_crapcre%FOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcre;
      --Selecionar remessa
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_cdocorre => 2
                      ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem;
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XB' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');
        
        -- Recusar a instrucao
        --Inclusao vr_cdcritic
        vr_cdcritic := 1331;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  --Pedido de Baixa ja efetuado - Alteracao Vencto nao efetuada
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_craprem%ISOPEN THEN
        CLOSE cr_craprem;
      END IF;
    END IF;
    --Fechar Cursor
    IF cr_crapcre%ISOPEN THEN
      CLOSE cr_crapcre;
    END IF;

    /*
     * REMOVIDA VALIDAÇÃO PJ341 - Reciprocidade (Quickwins)
     *
    **/
    /*
    IF pr_dtvencto <= rw_crapcob.dtvencto THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => '16' -- Motivo -- Data de vencimento invalida
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');

      -- Recusar a instrucao
      --Inclusao vr_cdcritic
      vr_cdcritic := 1332;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                     ||pr_dtvencto||' <= '||rw_crapcob.dtvencto;  --Data Vencimento inferior ao atual - Alteracao Vencto nao efetuada
      RAISE vr_exc_erro;
    END IF;
    */

    --  AQUI - Rever que valor sera esse "120" 
    IF (pr_dtvencto - rw_crapcob.dtvencto) > 120 THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => '18' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');

      -- Recusar a instrucao
      vr_cdcritic := 1333;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                     ||(pr_dtvencto - rw_crapcob.dtvencto)||' > 120 dias';  --Prazo de vencimento superior ao permitido
      RAISE vr_exc_erro;
    END IF;

    -- nao permitir alterar vencto de titulo no convenio de protesto
    IF rw_crapcob.cdbandoc <> rw_crapcop.cdbcoctl THEN
      --Selecionar cadastro convenio
      OPEN cr_crapcco (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrconven => rw_crapcob.nrcnvcob);
      FETCH cr_crapcco INTO rw_crapcco;
      IF cr_crapcco%FOUND AND rw_crapcco.dsorgarq = 'PROTESTO' THEN
        CLOSE cr_crapcco;
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XG' -- Motivo 
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');

        -- Recusar a instrucao
        --Inclusao vr_cdcritic
        vr_cdcritic := 1334;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  --Nao e permitido alterar vencimento do boleto no convenio protesto - Alteracao Vencto nao efetuada
        RAISE vr_exc_erro;
      END IF;
    END IF;
    IF cr_crapcco%ISOPEN THEN
      CLOSE cr_crapcco;
    END IF;
    -- Data de Vencimento Anterior a  Data de Emissao
    IF pr_dtvencto < rw_crapcob.dtmvtolt THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => '17' -- Motivo 
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');

      -- Recusar a instrucao
      --Inclusao vr_cdcritic
      vr_cdcritic := 1335;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                     ||pr_dtvencto||' < '||rw_crapcob.dtmvtolt;  --Data Vencto anterior a Data de Emissao - Alteracao Vencimento nao efetuada
      RAISE vr_exc_erro;
    END IF;

    IF rw_crapcob.incobran = 0  AND   -- 0 - Em Aberto
       rw_crapcob.insitcrt <> 0 THEN  -- Qualquer situaçao diferente de zero
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XI' -- Motivo 
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');

      -- Recusar a instrucao
      --Inclusao vr_cdcritic
      vr_cdcritic := 1336;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  --Titulo com movimentacao cartoraria - Alteracao Vencimento nao efetuada
      RAISE vr_exc_erro;
    END IF;
    ------ FIM - VALIDACOES PARA RECUSAR ------

    IF rw_crapcob.flgcbdda = 1 AND
        rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN
      -- Executa procedimentos do DDA-JD 
      DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob.rowid         --ROWID da Cobranca
                                       ,pr_tpoperad  => 'A'                      --Tipo Operacao
                                       ,pr_tpdbaixa  => ' '                      --Tipo de Baixa
                                       ,pr_dtvencto  => pr_dtvencto              --Data Vencimento
                                       ,pr_vldescto  => rw_crapcob.vldescto      --Valor Desconto
                                       ,pr_vlabatim  => rw_crapcob.vlabatim      --Valor Abatimento
                                       ,pr_flgdprot  => rw_crapcob.flgdprot      --Flag Protesto
                                       ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa
                                       ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela memoria retorno DDA
                                       ,pr_cdcritic  => vr_cdcritic2             --Codigo Critica
                                       ,pr_dscritic  => vr_dscritic2);           --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic2,0) <> 0 OR TRIM(vr_dscritic2) IS NOT NULL THEN
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');

        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XC' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        --Aqui não logava o erro de retorno da cobr0006.pc_prep_retorno_cooper_90 e além disso, queimava 
        --as variáveis. Agora vai logar também erro da COBR0006, mas sem parar a execução
        -- Ch REQ0011728 daqui
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Se ocorreu erro
          pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                      pr_dstiplog      => 'E',
                      pr_dscritic      => vr_dscritic||vr_dsparame,
                      pr_cdcriticidade => 1,
                      pr_cdmensagem    => nvl(vr_cdcritic,0),
                      pr_ind_tipo_log  => 1);
        END IF;
        --Ch REQ0011728 até aqui
          
        vr_cdcritic := vr_cdcritic2;
        vr_dscritic := vr_dscritic2;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');

    -- tratamento para titulos migrados 
    IF rw_crapcob.flgregis = 1 AND rw_crapcob.cdbandoc = 001 THEN
      --Selecionar cadastro convenio
      OPEN cr_crapcco (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrconven => rw_crapcob.nrcnvcob);
      --Proximo registro
      FETCH cr_crapcco INTO rw_crapcco;
      --Se encontrou
      IF cr_crapcco%FOUND AND rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
        --Fechar Cursor
        CLOSE cr_crapcco;
        --Protesta titulo Migrado
        COBR0007.pc_inst_titulo_migrado (pr_idregcob => rw_crapcob --Rowtype da Cobranca
                                        ,pr_dsdinstr => 'Alteracao de Vencimento' --Descricao da Instrucao
                                        ,pr_dtaltvct => pr_dtvencto --Data Alteracao Vencimento
                                        ,pr_vlaltabt => 0          --Valor Alterado Abatimento
                                        ,pr_nrdctabb => rw_crapcco.nrdctabb --Numero da Conta BB
                                        ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                        ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');
        vr_cdcritic := 1183;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  --Solicitacao de baixa de titulo migrado. Aguarde confirmacao no proximo dia util
        --Retornar
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_crapcco%ISOPEN THEN
        CLOSE cr_crapcco;
      END IF;
    END IF;
    
    -- Altera Dt. Vencimento conforme parametro de tela passado
    vr_dtvencto_old     := rw_crapcob.dtvencto;
    rw_crapcob.dtvencto := pr_dtvencto;
    
    --Se tem remesssa dda na tabela
    IF vr_tab_remessa_dda.COUNT > 0 THEN
      rw_crapcob.idopeleg:= vr_tab_remessa_dda(vr_tab_remessa_dda.LAST).idopeleg;
    END IF;

    --Atualizar Cobranca
    BEGIN
      UPDATE crapcob SET crapcob.dtvencto = rw_crapcob.dtvencto,
                         crapcob.idopeleg = rw_crapcob.idopeleg
      WHERE crapcob.rowid = rw_crapcob.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        vr_cdcritic := 1035;  --Erro ao atualizar crapcob
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                       ' dtvencto:'||rw_crapcob.dtvencto||
                       ', idopeleg:'||rw_crapcob.idopeleg||
                       ' com rowid:'||rw_crapcob.rowid||
                       '. '||sqlerrm;
        RAISE vr_exc_erro;
    END;

    IF rw_crapcob.cdbandoc = 1 THEN
      -- Verifica se ja existe Instrucao de Alteracao de Vencimento
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_cdocorre => pr_cdocorre
                      ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
       IF cr_craprem%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem;
        --Cria log cobranca
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid  --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                     ,pr_dsmensag => 'Exclusao Instr.Alt.Vencto. Data:' ||
                                                     to_char(rw_craprem.dtdprorr,'dd/mm/RRRR') --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro   --Indicador erro
                                     ,pr_dscritic => vr_dscritic); --Descricao erro
        --OBS: nao valida vr_des_erro -> manter assim
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');

        -- Exclui o Instrucao de Remessa que ja existe
        -- e criar uma nova com o novo Abatimento
        COBR0007.pc_elimina_remessa (pr_cdcooper => rw_craprem.cdcooper  --Codigo Cooperativa
                                    ,pr_nrdconta => rw_craprem.nrdconta  --Numero da Conta
                                    ,pr_nrcnvcob => rw_craprem.nrcnvcob  --Numero Convenio
                                    ,pr_nrdocmto => rw_craprem.nrdocmto  --Numero Documento
                                    ,pr_cdocorre => rw_craprem.cdocorre  --Ocorrencia
                                    ,pr_dtmvtolt => rw_craprem.dtaltera  --Data Movimentacao
                                    ,pr_des_erro => vr_des_erro          --Indicador Erro
                                    ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                    ,pr_dscritic => vr_dscritic);        --Descricao Critica
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');
        
      END IF;
      --Fechar Cursor
      IF cr_craprem%ISOPEN THEN
        CLOSE cr_craprem;
      END IF;

      -- gerar pedido de remessa
      PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                     ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                     ,pr_dtmvtolt => pr_dtmvtolt         --Data movimento
                                     ,pr_cdoperad => pr_cdoperad         --Codigo Operador
																		 ,pr_idregcob => rw_crapcob.rowid
                                     ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                     ,pr_rowid_ret => vr_rowid_ret       --ROWID Remessa Retorno
                                     ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                     ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                     ,pr_dscritic => vr_dscritic);       --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');

      IF rw_crapcob.insitcrt = 1 OR
         rw_crapcob.insitcrt = 3 OR
         rw_crapcob.dtvencto <= pr_dtmvtolt THEN

        --Incrementar Sequencial
        vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;
        --Criar tabela Remessa
        -- Sustar Manter Carteira
        PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                     ,pr_nrremret => vr_nrremret          --Numero Remessa
                                     ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                     ,pr_cdocorre => 11                   --Codigo Ocorrencia
                                     ,pr_cdmotivo => NULL                 --Codigo Motivo
                                     ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                     ,pr_vlabatim => 0                    --Valor Abatimento
                                     ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                     ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                     ,pr_dscritic => vr_dscritic);        --Descricao Critica
        --Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');
      END IF;

      --Incrementar Sequencial
      vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;
      -- Criar tabela Remessa
      -- Alteracao Vencimento
      PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                   ,pr_nrremret => vr_nrremret          --Numero Remessa
                                   ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                   ,pr_cdocorre => pr_cdocorre          --Codigo Ocorrencia
                                   ,pr_cdmotivo => NULL                 --Codigo Motivo
                                   ,pr_dtdprorr => pr_dtvencto          --Data Prorrogacao
                                   ,pr_vlabatim => 0                    --Valor Abatimento
                                   ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                   ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);        --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');
      
    ELSE 
      
      IF rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN 
        -- Gerar o retorno para o cooperado 
        -- Confirmacao Recebimento Instrucao Alteracao de Vencimento
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 14   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => NULL -- Motivo 
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');
      END IF;
    END IF;

    -- Gera registro de Prorrogacao - FlgConfi = FALSE 
    COBR0007.pc_cria_tab_prorrogacao (pr_rw_crapcob => rw_crapcob      --> Rowtype da Cobranca
                                     ,pr_dtvctonv   => pr_dtvencto     --> Data de Vencimento Nova
                                     ,pr_dtvctori   => vr_dtvencto_old --> Data de Vencimento Original
                                     ,pr_flgconfi   => 0 -- FALSE      --> Confirmacao da prorrogacao de vencimento
                                     ,pr_cdoperad   => pr_cdoperad     --> Operador
                                     ,pr_dtmvtolt   => pr_dtmvtolt     --> Data de movimento
                                     ,pr_cdcritic   => vr_cdcritic     --> Codigo da Critica
                                     ,pr_dscritic   => vr_dscritic);   --> Descricao da Critica
    -- Verifica se ocorreu erro durante a execucao
    IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');
    
    ---- LOG de Processo ----
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                 ,pr_cdoperad => pr_cdoperad      --Operador
                                 ,pr_dtmvtolt => pr_dtmvtolt      --Data movimento
                                 ,pr_dsmensag => 'Alteracao de vencimento de ' || 
                                                 to_char(vr_dtvencto_old,'dd/mm/yyyy') ||
                                                 ' para ' ||
                                                 to_char(pr_dtvencto,'dd/mm/yyyy')  --Descricao Mensagem
                                 ,pr_des_erro => vr_des_erro      --Indicador erro
                                 ,pr_dscritic => vr_dscritic);    --Descricao erro
    --Se ocorreu erro
    IF vr_des_erro = 'NOK' THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_vencto');
    
    IF rw_crapcob.cdbandoc = 85 THEN
      --Montar Indice para lancamento tarifa
      vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                     lpad(pr_nrdconta,10,'0')||
                     lpad(pr_nrcnvcob,10,'0')||
                     lpad(19,10,'0')||
                     lpad('0',10,'0')||
                     lpad(pr_tab_lat_consolidada.Count+1,10,'0');
      -- Gerar registro Tarifa 
      pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
      pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
      pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
      pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
      pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
      pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 14;    -- 14 - Confirmacao Recebimento Instrucao Alteracao de Vencimento
      pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= NULL;  -- Motivo
      pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic; -- Ajuste msg usuario final - 07/11/2018 - INC0026760
      
      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => vr_dscritic||vr_dsparame,-- Ajuste msg usuario final - 07/11/2018 - INC0026760
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);
      -- Ajuste msg usuario final - 07/11/2018 - INC0026760
      -- Se chegar erro não tratado de outras chamadas desta procedure joga para 1124
      IF pr_cdcritic = 9999 THEN
        pr_cdcritic := 1224; -- Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;            
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_alt_vencto. '||sqlerrm||vr_dsparame;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);
      pr_cdcritic := 1224; -- Ajuste msg usuario final - 07/11/2018 - INC0026760
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic); -- Ajuste msg usuario final - 07/11/2018 - INC0026760

  END pc_inst_alt_vencto;
  
  -- Procedure para Conceder Desconto
  PROCEDURE pc_inst_conc_desconto (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                  ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                  ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                  ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                  ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                  ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                  ,pr_vldescto  IN crapcob.vldescto%TYPE --> Valor do Desconto
                                  ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                  ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                  ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                  ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_conc_desconto            Antigo: b1wgen0088.p/inst-conc-desconto
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Douglas Quisinski
    --  Data     : Janeiro/2016                     Ultima atualizacao: 12/02/2019
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Alterar o vencimento
    --
    --   Alteracao : 22/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --
    --               12/07/2017 - Ajustes para atualizar crapcob.cdmensag. PRJ340(Odirlei-AMcom)
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            (Ana - Envolti - Ch. REQ0011728)
    --
    --               12/02/2019 - Teste Revitalização
    --                            (Belli - Envolti - Ch. REQ0035813)    
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_cdcritic2  PLS_INTEGER;
    vr_dscritic2  VARCHAR2(4000);
    vr_des_erro   VARCHAR2(3);
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    -- Registro da Cooperativa
    rw_crapcop    COBR0007.cr_crapcop%ROWTYPE;
    -- Registro de Cobrança
    rw_crapcob    COBR0007.cr_crapcob%ROWTYPE;
    -- Registro de Remessa
    rw_craprem    COBR0007.cr_craprem%ROWTYPE;
    -- Registro de controle retorno titulos bancarios
    rw_crapcre    COBR0007.cr_crapcre%ROWTYPE;
    -- Registro de cadastro de cobranca
    rw_crapcco    COBR0007.cr_crapcco%ROWTYPE;

    --Tabelas de Memoria de Remessa
    vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
    vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
    
    vr_vltitabr     crapcob.vldescto%TYPE;
    vr_nrremret     INTEGER;
    vr_nrseqreg     INTEGER;
    vr_rowid_ret    ROWID;
    vr_index_lat    VARCHAR2(60);

  BEGIN
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                  ||', pr_nrdconta:'||pr_nrdconta
                  ||', pr_nrcnvcob:'||pr_nrcnvcob
                  ||', pr_nrdocmto:'||pr_nrdocmto
                  ||', pr_cdocorre:'||pr_cdocorre
                  ||', pr_dtmvtolt:'||pr_dtmvtolt
                  ||', pr_cdoperad:'||pr_cdoperad
                  ||', pr_vldescto:'||pr_vldescto
                  ||', pr_nrremass:'||pr_nrremass;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;

    -- Processo de Validacao Recusas Padrao
    COBR0007.pc_efetua_val_recusa_padrao(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                        ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                        ,pr_nrcnvcob => pr_nrcnvcob   --> Numero Convenio
                                        ,pr_nrdocmto => pr_nrdocmto   --> Numero Documento
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Data Movimento
                                        ,pr_cdoperad => pr_cdoperad   --> Operador
                                        ,pr_cdinstru => '07'          --> Codigo Instrucao
                                        ,pr_nrremass => pr_nrremass   --> Numero da Remessa
                                        ,pr_rw_crapcob => rw_crapcob  --> Registro de Cobranca de Recusa
                                        ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                        ,pr_dscritic => vr_dscritic); --> Descricao da Critica
    
    --Se ocorrer Erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');
    
    IF rw_crapcob.cdbandoc = 085 AND
       rw_crapcob.flgregis = 1   AND 
       rw_crapcob.flgcbdda = 1   AND 
       rw_crapcob.insitpro <= 2  THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XA' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');

      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1180);  --Titulo em processo de registro. Favor aguardar
      RAISE vr_exc_erro;
    END IF;

    -----  VALIDACOES PARA RECUSAR  -----
    -- Verifica se ja existe Pedido de Baixa
    OPEN cr_crapcre (pr_cdcooper => pr_cdcooper
                    ,pr_nrcnvcob => pr_nrcnvcob
                    ,pr_dtmvtolt => pr_dtmvtolt
                    ,pr_intipmvt => 1);
    --Proximo registro
    FETCH cr_crapcre INTO rw_crapcre;
    --Se Encontrou
    IF cr_crapcre%FOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcre;
      --Selecionar remessa
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_cdocorre => 2
                      ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem;
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XB' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');
        
        -- Recusar a instrucao
        vr_dscritic := gene0001.fn_busca_critica(1337);  --Pedido de Baixa ja efetuado - Desconto nao efetuado
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_craprem%ISOPEN THEN
        CLOSE cr_craprem;
      END IF;
    END IF;
    --Fechar Cursor
    IF cr_crapcre%ISOPEN THEN
      CLOSE cr_crapcre;
    END IF;

    -- Verificar o indicador da situacao cartoraria
    IF rw_crapcob.insitcrt = 1 THEN
      -- 1 = C/Inst Protesto
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XE' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1338);  --Boleto com Remessa a Cartorio - Desconto nao efetuado
      RAISE vr_exc_erro;
    ELSIF rw_crapcob.insitcrt = 3 THEN
      -- 3 = Em Cartorio
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XF' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1339);  --Boleto em Cartorio - Desconto nao efetuado
      RAISE vr_exc_erro;
    END IF;
    
    vr_vltitabr := rw_crapcob.vltitulo - rw_crapcob.vldescto - rw_crapcob.vlabatim;
    IF  pr_vldescto > vr_vltitabr THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => '29' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1340);  --Valor de Desconto superior ao Valor do Boleto - Desconto nao efetuado
      RAISE vr_exc_erro;
    END IF;
    
    vr_vltitabr := rw_crapcob.vltitulo - pr_vldescto - rw_crapcob.vlabatim;
    --> Verificar se valor do titulo ficará menor que o valor minimo
    IF rw_crapcob.inpagdiv = 1 AND 
       rw_crapcob.vlminimo > vr_vltitabr THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => '29' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1341);  --Valor de Desconto maior que o permitido devido ao Valor minimo boleto - Desconto nao efetuado
      RAISE vr_exc_erro;
    END IF;
    
    -- nao permitir conceder abatimento de titulo no convenio de protesto
    IF rw_crapcob.cdbandoc <> rw_crapcop.cdbcoctl THEN
      --Selecionar cadastro convenio
      OPEN cr_crapcco (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrconven => rw_crapcob.nrcnvcob);
      FETCH cr_crapcco INTO rw_crapcco;
      IF cr_crapcco%FOUND AND rw_crapcco.dsorgarq = 'PROTESTO' THEN
        CLOSE cr_crapcco;
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XG' -- Motivo 
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');

        -- Recusar a instrucao
        vr_dscritic := gene0001.fn_busca_critica(1342);  --Nao e permitido conceder desconto de boleto no convenio protesto - Desconto nao efetuado
        RAISE vr_exc_erro;
      END IF;
    END IF;
    IF cr_crapcco%ISOPEN THEN
      CLOSE cr_crapcco;
    END IF;
    ------ FIM - VALIDACOES PARA RECUSAR ------
    
    IF rw_crapcob.flgcbdda = 1 AND
       rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN
      -- Executa procedimentos do DDA-JD 
      DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob.rowid         --ROWID da Cobranca
                                       ,pr_tpoperad  => 'A'                      --Tipo Operacao
                                       ,pr_tpdbaixa  => ' '                      --Tipo de Baixa
                                       ,pr_dtvencto  => rw_crapcob.dtvencto      --Data Vencimento
                                       ,pr_vldescto  => pr_vldescto              --Valor Desconto
                                       ,pr_vlabatim  => rw_crapcob.vlabatim      --Valor Abatimento
                                       ,pr_flgdprot  => rw_crapcob.flgdprot      --Flag Protesto
                                       ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa
                                       ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela memoria retorno DDA
                                       ,pr_cdcritic  => vr_cdcritic2             --Codigo Critica
                                       ,pr_dscritic  => vr_dscritic2);           --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic2,0) <> 0 OR TRIM(vr_dscritic2) IS NOT NULL THEN
        -- Inclui nome do modulo logado - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XC' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
          
        vr_cdcritic := vr_cdcritic2;
        vr_dscritic := vr_dscritic2;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');

    -- tratamento para titulos migrados 
    IF rw_crapcob.flgregis = 1 AND rw_crapcob.cdbandoc = 001 THEN
      --Selecionar cadastro convenio
      OPEN cr_crapcco (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrconven => rw_crapcob.nrcnvcob);
      --Proximo registro
      FETCH cr_crapcco INTO rw_crapcco;
      --Se encontrou
      IF cr_crapcco%FOUND AND rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
        --Fechar Cursor
        CLOSE cr_crapcco;
        --Protesta titulo Migrado
        COBR0007.pc_inst_titulo_migrado (pr_idregcob => rw_crapcob  --Rowtype da Cobranca
                                        ,pr_dsdinstr => 'Desconto'  --Descricao da Instrucao
                                        ,pr_dtaltvct => NULL        --Data Alteracao Vencimento
                                        ,pr_vlaltabt => pr_vldescto --Valor Alterado Abatimento
                                        ,pr_nrdctabb => rw_crapcco.nrdctabb --Numero da Conta BB
                                        ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                        ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');

        vr_cdcritic := 1183;  --Solicitacao de baixa de titulo migrado. Aguarde confirmacao no proximo dia util.

        --Retornar
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_crapcco%ISOPEN THEN
        CLOSE cr_crapcco;
      END IF;
    END IF;

    rw_crapcob.vldescto := pr_vldescto;
    --Se tem remesssa dda na tabela
    IF vr_tab_remessa_dda.COUNT > 0 THEN
      rw_crapcob.idopeleg:= vr_tab_remessa_dda(vr_tab_remessa_dda.LAST).idopeleg;
    END IF;

    --> Se possuir Desconto
    IF rw_crapcob.vldescto > 0 THEN
      --> Marcar cdmensag
      rw_crapcob.cdmensag := 1;
    END IF;    

    --Atualizar Cobranca
    BEGIN
      UPDATE crapcob SET crapcob.vldescto = rw_crapcob.vldescto,
                         crapcob.cdmensag = rw_crapcob.cdmensag,
                         crapcob.idopeleg = rw_crapcob.idopeleg
      WHERE crapcob.rowid = rw_crapcob.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        vr_cdcritic := 1035;  --Erro ao atualizar crapcob
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                       ' vldescto:'||rw_crapcob.vldescto||
                       ', cdmensag:'||rw_crapcob.cdmensag||
                       ', idopeleg:'||rw_crapcob.idopeleg||
                       ' com rowid:'||rw_crapcob.rowid||
                       '. '||sqlerrm;
        RAISE vr_exc_erro;
    END;

    IF rw_crapcob.cdbandoc = 1 THEN
      -- Verifica se ja existe Instrucao de Alteracao de Vencimento 
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_cdocorre => 8
                      ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem;
        --Cria log cobranca
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid  --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                     ,pr_dsmensag => 'Exclusao Instrucao ' ||
                                                     'Cancelamento de Desconto' --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro   --Indicador erro
                                     ,pr_dscritic => vr_dscritic); --Descricao erro
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');
        
        --- Exclui o Instrucao de Remessa que ja existe ---
        COBR0007.pc_elimina_remessa (pr_cdcooper => rw_craprem.cdcooper  --Codigo Cooperativa
                                    ,pr_nrdconta => rw_craprem.nrdconta  --Numero da Conta
                                    ,pr_nrcnvcob => rw_craprem.nrcnvcob  --Numero Convenio
                                    ,pr_nrdocmto => rw_craprem.nrdocmto  --Numero Documento
                                    ,pr_cdocorre => rw_craprem.cdocorre  --Ocorrencia
                                    ,pr_dtmvtolt => rw_craprem.dtaltera  --Data Movimentacao
                                    ,pr_des_erro => vr_des_erro          --Indicador Erro
                                    ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                    ,pr_dscritic => vr_dscritic);        --Descricao Critica
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');
        
      END IF;
      --Fechar Cursor
      IF cr_craprem%ISOPEN THEN
        CLOSE cr_craprem;
      END IF;

      -- Verifica se ja existe Instr.Conc.Desconto e substitui
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_cdocorre => pr_cdocorre
                      ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem;
        --Cria log cobranca
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid  --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                     ,pr_dsmensag => 'Exclusao Instr.Conc.Desconto ' ||
                                                     'Vlr: R$ ' || 
                                                     TRIM(to_char(rw_craprem.vlabatim,'9g999g990d00')) --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro   --Indicador erro
                                     ,pr_dscritic => vr_dscritic); --Descricao erro
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');
        
        --- Exclui o Instrucao de Remessa que ja existe ---
        COBR0007.pc_elimina_remessa (pr_cdcooper => rw_craprem.cdcooper  --Codigo Cooperativa
                                    ,pr_nrdconta => rw_craprem.nrdconta  --Numero da Conta
                                    ,pr_nrcnvcob => rw_craprem.nrcnvcob  --Numero Convenio
                                    ,pr_nrdocmto => rw_craprem.nrdocmto  --Numero Documento
                                    ,pr_cdocorre => rw_craprem.cdocorre  --Ocorrencia
                                    ,pr_dtmvtolt => rw_craprem.dtaltera  --Data Movimentacao
                                    ,pr_des_erro => vr_des_erro          --Indicador Erro
                                    ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                    ,pr_dscritic => vr_dscritic);        --Descricao Critica
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');
        
      END IF;
      --Fechar Cursor
      IF cr_craprem%ISOPEN THEN
        CLOSE cr_craprem;
      END IF;

      -- gerar pedido de remessa
      PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                     ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                     ,pr_dtmvtolt => pr_dtmvtolt         --Data movimento
                                     ,pr_cdoperad => pr_cdoperad         --Codigo Operador
																		 ,pr_idregcob => rw_crapcob.rowid
                                     ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                     ,pr_rowid_ret => vr_rowid_ret       --ROWID Remessa Retorno
                                     ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                     ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                     ,pr_dscritic => vr_dscritic);       --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');

      --Incrementar Sequencial
      vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;
      -- Criar tabela Remessa
      -- Alteracao Vencimento
      PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                   ,pr_nrremret => vr_nrremret          --Numero Remessa
                                   ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                   ,pr_cdocorre => pr_cdocorre          --Codigo Ocorrencia
                                   ,pr_cdmotivo => NULL                 --Codigo Motivo
                                   ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                   ,pr_vlabatim => pr_vldescto          --Valor Abatimento
                                   ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                   ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);        --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');
      -- FIM do IF cdbandoc = 1
    ELSE 
     
      IF rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN 
        -- Gerar o retorno para o cooperado 
        -- Conf. Receb. Instr. Desconto 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 7    -- Instrucao Rejeitada
                                           ,pr_cdmotivo => NULL -- Motivo 
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');
      END IF;
    END IF;

    ---- LOG de Processo ----
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                 ,pr_cdoperad => pr_cdoperad      --Operador
                                 ,pr_dtmvtolt => pr_dtmvtolt      --Data movimento
                                 ,pr_dsmensag => 'Concessao de desconto no valor de R$ ' ||
                                                 TRIM(to_char(pr_vldescto,'9g999g990d00')) -- Descricao Mensagem
                                 ,pr_des_erro => vr_des_erro      --Indicador erro
                                 ,pr_dscritic => vr_dscritic);    --Descricao erro
    --Se ocorreu erro
    IF vr_des_erro = 'NOK' THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_conc_desconto');

    IF rw_crapcob.cdbandoc = 85 THEN
      --Montar Indice para lancamento tarifa
      vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                     lpad(pr_nrdconta,10,'0')||
                     lpad(pr_nrcnvcob,10,'0')||
                     lpad(19,10,'0')||
                     lpad('0',10,'0')||
                     lpad(pr_tab_lat_consolidada.Count+1,10,'0');
      -- Gerar registro Tarifa 
      pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
      pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
      pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
      pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
      pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
      pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 07;    -- 07 - Conf. Receb. Instr. Desconto
      pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= NULL;  -- Motivo
      pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic||vr_dsparame,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);
      -- Ajuste mensagem - 12/02/2019 - REQ0035813
      IF nvl(pr_cdcritic,0) IN ( 1197, 9999, 1034, 1035, 1036, 1037 ) THEN
        pr_cdcritic := 1224;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      ELSIF nvl(pr_cdcritic,0) = 0 AND
            SUBSTR(pr_dscritic, 1, 7 ) IN ( '1197 - ', '9999 - ', '1034 - ', '1035 - ', '1036 - ', '1037 - ' ) THEN
        pr_cdcritic := 1224;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_conc_desconto. '||sqlerrm||vr_dsparame;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

      pr_cdcritic := 1224; -- Ajuste mensagem - 12/02/2019 - REQ0035813
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
  END pc_inst_conc_desconto;
  
  -- Procedure para Cancelar Desconto
  PROCEDURE pc_inst_canc_desconto (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                  ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                  ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                  ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                  ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                  ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                  ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                  ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                  ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                  ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_canc_desconto            Antigo: b1wgen0088.p/inst-canc-desconto
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Douglas Quisinski
    --  Data     : Janeiro/2016                     Ultima atualizacao: 12/02/2019
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Cancelar Desconto
    --
    --   Alteracao : 22/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --
    --               12/07/2017 - Ajustes para atualizar crapcob.cdmensag. PRJ340(Odirlei-AMcom)
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            (Ana - Envolti - Ch. REQ0011728)
    --
    --               12/02/2019 - Teste Revitalização
    --                            (Belli - Envolti - Ch. REQ0035813)     
    --                            
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_cdcritic2  PLS_INTEGER;
    vr_dscritic2  VARCHAR2(4000);
    vr_des_erro   VARCHAR2(3);
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    -- Registro da Cooperativa
    rw_crapcop    COBR0007.cr_crapcop%ROWTYPE;
    -- Registro de Cobrança
    rw_crapcob    COBR0007.cr_crapcob%ROWTYPE;
    -- Registro de Remessa
    rw_craprem    COBR0007.cr_craprem%ROWTYPE;
    -- Registro de controle retorno titulos bancarios
    rw_crapcre    COBR0007.cr_crapcre%ROWTYPE;
    -- Registro de cadastro de cobranca
    rw_crapcco    COBR0007.cr_crapcco%ROWTYPE;

    --Tabelas de Memoria de Remessa
    vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
    vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
    
    vr_nrremret     INTEGER;
    vr_nrseqreg     INTEGER;
    vr_rowid_ret    ROWID;
    vr_index_lat    VARCHAR2(60);

  BEGIN
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                  ||', pr_nrdconta:'||pr_nrdconta
                  ||', pr_nrcnvcob:'||pr_nrcnvcob
                  ||', pr_nrdocmto:'||pr_nrdocmto
                  ||', pr_cdocorre:'||pr_cdocorre
                  ||', pr_dtmvtolt:'||pr_dtmvtolt
                  ||', pr_cdoperad:'||pr_cdoperad
                  ||', pr_nrremass:'||pr_nrremass;
               
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;

    -- Processo de Validacao Recusas Padrao
    COBR0007.pc_efetua_val_recusa_padrao(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                        ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                        ,pr_nrcnvcob => pr_nrcnvcob   --> Numero Convenio
                                        ,pr_nrdocmto => pr_nrdocmto   --> Numero Documento
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Data Movimento
                                        ,pr_cdoperad => pr_cdoperad   --> Operador
                                        ,pr_cdinstru => '08'          --> Codigo Instrucao
                                        ,pr_nrremass => pr_nrremass   --> Numero da Remessa
                                        ,pr_rw_crapcob => rw_crapcob  --> Registro de Cobranca de Recusa
                                        ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                        ,pr_dscritic => vr_dscritic); --> Descricao da Critica
    
    --Se ocorrer Erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');

    IF rw_crapcob.cdbandoc = 085 AND
       rw_crapcob.flgregis = 1   AND 
       rw_crapcob.flgcbdda = 1   AND 
       rw_crapcob.insitpro <= 2  THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XA' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');

      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1180);  --Titulo em processo de registro. Favor aguardar
      RAISE vr_exc_erro;
    END IF;

    -----  VALIDACOES PARA RECUSAR  -----
    -- Verificar o indicador da situacao cartoraria
    IF rw_crapcob.insitcrt = 1 THEN
      -- 1 = C/Inst Protesto
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XE' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1343);  --Boleto com Remessa a Cartorio - Cancelamento Desconto nao efetuado
      RAISE vr_exc_erro;
    ELSIF rw_crapcob.insitcrt = 3 THEN
      -- 3 = Em Cartorio
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XF' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1344);  --Boleto Em Cartorio - Cancelamento Desconto nao efetuado
      RAISE vr_exc_erro;
    END IF;

    -- Verifica se ja existe Pedido de Baixa 
    OPEN cr_crapcre (pr_cdcooper => pr_cdcooper
                    ,pr_nrcnvcob => pr_nrcnvcob
                    ,pr_dtmvtolt => pr_dtmvtolt
                    ,pr_intipmvt => 1);
    --Proximo registro
    FETCH cr_crapcre INTO rw_crapcre;
    --Se Encontrou
    IF cr_crapcre%FOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcre;
      --Selecionar remessa
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_cdocorre => 2
                      ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem;
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XB' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');
        
        -- Recusar a instrucao
        vr_dscritic := gene0001.fn_busca_critica(1345);  --Pedido de Baixa ja efetuado - Canc. Desconto nao efetuado
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_craprem%ISOPEN THEN
        CLOSE cr_craprem;
      END IF;
    END IF;
    --Fechar Cursor
    IF cr_crapcre%ISOPEN THEN
      CLOSE cr_crapcre;
    END IF;

    -- Validar se existe valor de desconto
    IF rw_crapcob.vldescto = 0 THEN
      -- Gerar o retorno para o cooperado 
      -- Titulo ja se encontra na situacao Pretendida
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'A7' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');

      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1346);  --Boleto sem Valor de Desconto - Cancelamento Desconto nao efetuado
      RAISE vr_exc_erro;
    END IF;
    ------ FIM - VALIDACOES PARA RECUSAR ------

    IF rw_crapcob.flgcbdda = 1 AND
       rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN
      -- Executa procedimentos do DDA-JD 
      DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob.rowid         --ROWID da Cobranca
                                       ,pr_tpoperad  => 'A'                      --Tipo Operacao
                                       ,pr_tpdbaixa  => ' '                      --Tipo de Baixa
                                       ,pr_dtvencto  => rw_crapcob.dtvencto      --Data Vencimento
                                       ,pr_vldescto  => 0                        --Valor Desconto
                                       ,pr_vlabatim  => rw_crapcob.vlabatim      --Valor Abatimento
                                       ,pr_flgdprot  => rw_crapcob.flgdprot      --Flag Protesto
                                       ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa
                                       ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela memoria retorno DDA
                                       ,pr_cdcritic  => vr_cdcritic2             --Codigo Critica
                                       ,pr_dscritic  => vr_dscritic2);           --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic2,0) <> 0 OR TRIM(vr_dscritic2) IS NOT NULL THEN
        -- Inclui nome do modulo logado - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XC' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
          
        vr_cdcritic := vr_cdcritic2;
        vr_dscritic := vr_dscritic2;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');

    -- tratamento para titulos migrados 
    IF rw_crapcob.flgregis = 1 AND rw_crapcob.cdbandoc = 001 THEN
      --Selecionar cadastro convenio
      OPEN cr_crapcco (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrconven => rw_crapcob.nrcnvcob);
      --Proximo registro
      FETCH cr_crapcco INTO rw_crapcco;
      --Se encontrou
      IF cr_crapcco%FOUND AND rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
        --Fechar Cursor
        CLOSE cr_crapcco;
        --Protesta titulo Migrado
        COBR0007.pc_inst_titulo_migrado (pr_idregcob => rw_crapcob --Rowtype da Cobranca
                                        ,pr_dsdinstr => 'Cancelamento de desconto' --Descricao da Instrucao
                                        ,pr_dtaltvct => NULL       --Data Alteracao Vencimento
                                        ,pr_vlaltabt => 0          --Valor Alterado Abatimento
                                        ,pr_nrdctabb => rw_crapcco.nrdctabb --Numero da Conta BB
                                        ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                        ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');

        vr_dscritic := gene0001.fn_busca_critica(1347);  --Solicitacao de cancelamento de desconto de titulo migrado. Aguarde confirmacao no proximo dia util
        --Retornar
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_crapcco%ISOPEN THEN
        CLOSE cr_crapcco;
      END IF;
    END IF;

    -- Cancela o abatimento concedido anteriormente
    rw_crapcob.vldescto := 0;
    
    --Se tem remesssa dda na tabela
    IF vr_tab_remessa_dda.COUNT > 0 THEN
      rw_crapcob.idopeleg:= vr_tab_remessa_dda(vr_tab_remessa_dda.LAST).idopeleg;
    END IF;

    --Atualizar Cobranca
    BEGIN
      UPDATE crapcob SET crapcob.vldescto = rw_crapcob.vldescto,
                         crapcob.cdmensag = 0, --> marcar como não possui desconto
                         crapcob.idopeleg = rw_crapcob.idopeleg
      WHERE crapcob.rowid = rw_crapcob.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        vr_cdcritic := 1035;  --Erro ao atualizar crapcob
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                       ' vldescto:'||rw_crapcob.vldescto||
                       ', cdmensag:0'||
                       ', idopeleg:'||rw_crapcob.idopeleg||
                       ' com rowid:'||rw_crapcob.rowid||
                       '. '||sqlerrm;
        RAISE vr_exc_erro;
    END;

    IF rw_crapcob.cdbandoc = 1 THEN
      -- Verifica se ja existe Instrucao de Alteracao de Vencimento 
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_cdocorre => 7
                      ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem;
        --Cria log cobranca
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid  --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                     ,pr_dsmensag => 'Exclusao Instrucao ' ||
                                                     'Concessao de Desconto' --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro   --Indicador erro
                                     ,pr_dscritic => vr_dscritic); --Descricao erro
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');
        
        -- Exclui o Instrucao de Remessa que ja existe
        -- e criar uma nova com o novo Abatimento
        COBR0007.pc_elimina_remessa (pr_cdcooper => rw_craprem.cdcooper  --Codigo Cooperativa
                                    ,pr_nrdconta => rw_craprem.nrdconta  --Numero da Conta
                                    ,pr_nrcnvcob => rw_craprem.nrcnvcob  --Numero Convenio
                                    ,pr_nrdocmto => rw_craprem.nrdocmto  --Numero Documento
                                    ,pr_cdocorre => rw_craprem.cdocorre  --Ocorrencia
                                    ,pr_dtmvtolt => rw_craprem.dtaltera  --Data Movimentacao
                                    ,pr_des_erro => vr_des_erro          --Indicador Erro
                                    ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                    ,pr_dscritic => vr_dscritic);        --Descricao Critica
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');
        
      END IF;
      --Fechar Cursor
      IF cr_craprem%ISOPEN THEN
        CLOSE cr_craprem;
      END IF;
            
      -- Verifica se ja existe Instrucao de Alteracao de Vencimento 
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_cdocorre => pr_cdocorre
                      ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem;
        --Cria log cobranca
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid  --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                     ,pr_dsmensag => 'Exclusao Instrucao ' ||
                                                     'Cancelamento de Desconto' --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro   --Indicador erro
                                     ,pr_dscritic => vr_dscritic); --Descricao erro
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');
        
        -- Exclui o Instrucao de Remessa que ja existe
        -- e criar uma nova com o novo Abatimento
        COBR0007.pc_elimina_remessa (pr_cdcooper => rw_craprem.cdcooper  --Codigo Cooperativa
                                    ,pr_nrdconta => rw_craprem.nrdconta  --Numero da Conta
                                    ,pr_nrcnvcob => rw_craprem.nrcnvcob  --Numero Convenio
                                    ,pr_nrdocmto => rw_craprem.nrdocmto  --Numero Documento
                                    ,pr_cdocorre => rw_craprem.cdocorre  --Ocorrencia
                                    ,pr_dtmvtolt => rw_craprem.dtaltera  --Data Movimentacao
                                    ,pr_des_erro => vr_des_erro          --Indicador Erro
                                    ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                    ,pr_dscritic => vr_dscritic);        --Descricao Critica
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');
        
      END IF;
      --Fechar Cursor
      IF cr_craprem%ISOPEN THEN
        CLOSE cr_craprem;
      END IF;

      -- gerar pedido de remessa
      PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                     ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                     ,pr_dtmvtolt => pr_dtmvtolt         --Data movimento
                                     ,pr_cdoperad => pr_cdoperad         --Codigo Operador
																		 ,pr_idregcob => rw_crapcob.rowid
                                     ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                     ,pr_rowid_ret => vr_rowid_ret       --ROWID Remessa Retorno
                                     ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                     ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                     ,pr_dscritic => vr_dscritic);       --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');

      --Incrementar Sequencial
      vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;
      -- Criar tabela Remessa
      -- Alteracao Vencimento
      PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                   ,pr_nrremret => vr_nrremret          --Numero Remessa
                                   ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                   ,pr_cdocorre => pr_cdocorre          --Codigo Ocorrencia
                                   ,pr_cdmotivo => NULL                 --Codigo Motivo
                                   ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                   ,pr_vlabatim => 0                    --Valor Abatimento
                                   ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                   ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);        --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');
      -- FIM do IF cdbandoc = 1
    ELSE 
      
      IF rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN 
        -- Gerar o retorno para o cooperado 
        -- Confirmacao do Recebimento do Cancelamento do Desconto
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 8    -- Instrucao Rejeitada
                                           ,pr_cdmotivo => NULL -- Motivo 
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');
      END IF;
    END IF;

    ---- LOG de Processo ----
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                 ,pr_cdoperad => pr_cdoperad      --Operador
                                 ,pr_dtmvtolt => pr_dtmvtolt      --Data movimento
                                 ,pr_dsmensag => 'Cancelamento de desconto'               --Descricao Mensagem
                                 ,pr_des_erro => vr_des_erro      --Indicador erro
                                 ,pr_dscritic => vr_dscritic);    --Descricao erro
    --Se ocorreu erro
    IF vr_des_erro = 'NOK' THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_desconto');
    
    IF rw_crapcob.cdbandoc = 85 THEN
      --Montar Indice para lancamento tarifa
      vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                     lpad(pr_nrdconta,10,'0')||
                     lpad(pr_nrcnvcob,10,'0')||
                     lpad(19,10,'0')||
                     lpad('0',10,'0')||
                     lpad(pr_tab_lat_consolidada.Count+1,10,'0');
      -- Gerar registro Tarifa 
      pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
      pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
      pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
      pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
      pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
      pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 08;    -- 08 - Confirmacao do Recebimento do Cancelamento do Desconto
      pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= NULL;  -- Motivo
      pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic||vr_dsparame,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);
      -- Ajuste mensagem - 12/02/2019 - REQ0035813
      IF nvl(pr_cdcritic,0) IN ( 1197, 9999, 1034, 1035, 1036, 1037 ) THEN
        pr_cdcritic := 1224;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      ELSIF nvl(pr_cdcritic,0) = 0 AND
            SUBSTR(pr_dscritic, 1, 7 ) IN ( '1197 - ', '9999 - ', '1034 - ', '1035 - ', '1036 - ', '1037 - ' ) THEN
        pr_cdcritic := 1224;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_canc_desconto. '||sqlerrm||vr_dsparame;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

      pr_cdcritic := 1224; -- Ajuste mensagem - 12/02/2019 - REQ0035813
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
  END pc_inst_canc_desconto;

  -- Procedure para Protestar
  PROCEDURE pc_inst_protestar_arq_rem_085 (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                          ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                          ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                          ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                          ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                          ,pr_qtdiaprt  IN INTEGER               --> Quantidade de Dias de Protesto
                                          ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                          ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                          ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                          ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                          ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                          ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_protestar_arq_rem_085    Antigo: b1wgen0088.p/inst-protestar-arq-rem-085
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Douglas Quisinski
    --  Data     : Janeiro/2016                     Ultima atualizacao: 24/08/201819/05/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para realizar o Protesto
    --
    --   Alteracao : 22/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --				   
    --               19/05/2016 - Incluido upper em cmapos de index utilizados em cursores (Andrei - RKAM).
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    
    CURSOR cr_crapass (pr_cdcooper  IN crapass.cdcooper%TYPE
                      ,pr_nrdconta  IN crapass.nrdconta%TYPE ) IS
      SELECT ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    /*Rafael Ferreira (Mouts) - INC0022229
      Conforme informado por Deise Carina Tonn da area de Negócio, esta validação não é mais necessária
      pois agora Todas as cidades podem ter protesto*/
    --Selecionar Pracas nao executantes Protesto
    /*CURSOR cr_crappnp (pr_nmextcid IN crappnp.nmextcid%type
                      ,pr_cduflogr IN crappnp.cduflogr%type) IS
      SELECT pnp.nmextcid
        FROM crappnp pnp
       WHERE UPPER(pnp.nmextcid) = UPPER(pr_nmextcid)
         AND UPPER(pnp.cduflogr) = UPPER(pr_cduflogr);
    rw_crappnp cr_crappnp%ROWTYPE;*/

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    -- Registro da Cooperativa
    rw_crapcop    COBR0007.cr_crapcop%ROWTYPE;
    -- Registro de Cobrança
    rw_crapcob    COBR0007.cr_crapcob%ROWTYPE;
    -- Registro de Remessa
    rw_craprem    COBR0007.cr_craprem%ROWTYPE;
    -- Registro de controle retorno titulos bancarios
    rw_crapcre    COBR0007.cr_crapcre%ROWTYPE;
    -- Registro do Sacado
    rw_crapsab    COBR0007.cr_crapsab%ROWTYPE;

    vr_index_lat  VARCHAR2(60);

  BEGIN
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar_arq_rem_085');
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                  ||', pr_nrdconta:'||pr_nrdconta
                  ||', pr_nrcnvcob:'||pr_nrcnvcob
                  ||', pr_nrdocmto:'||pr_nrdocmto
                  ||', pr_cdocorre:'||pr_cdocorre
                  ||', pr_qtdiaprt:'||pr_qtdiaprt
                  ||', pr_dtmvtolt:'||pr_dtmvtolt
                  ||', pr_cdoperad:'||pr_cdoperad
                  ||', pr_nrremass:'||pr_nrremass;

    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;

    -- Processo de Validacao Recusas Padrao
    COBR0007.pc_efetua_val_recusa_padrao(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                        ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                        ,pr_nrcnvcob => pr_nrcnvcob   --> Numero Convenio
                                        ,pr_nrdocmto => pr_nrdocmto   --> Numero Documento
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Data Movimento
                                        ,pr_cdoperad => pr_cdoperad   --> Operador
                                        ,pr_cdinstru => '09'          --> Codigo Instrucao
                                        ,pr_nrremass => pr_nrremass   --> Numero da Remessa
                                        ,pr_rw_crapcob => rw_crapcob  --> Registro de Cobranca de Recusa
                                        ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                        ,pr_dscritic => vr_dscritic); --> Descricao da Critica
    
    --Se ocorrer Erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar_arq_rem_085');

    IF rw_crapcob.cdbandoc = 085 AND
       rw_crapcob.flgregis = 1   AND 
       rw_crapcob.flgcbdda = 1   AND 
       rw_crapcob.insitpro <= 2  THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XA' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar_arq_rem_085');

      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1180);  --Titulo em processo de registro. Favor aguardar
      RAISE vr_exc_erro;
    END IF;

    ------ VALIDACOES PARA RECUSAR ------
    --- Titulo ainda nao venceu ---
    IF rw_crapcob.dtvencto >= TRUNC(SYSDATE) THEN
      -- Gerar o retorno para o cooperado 
      -- Pedido de Protesto Nao Permitido para o Titulo
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => '39' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar_arq_rem_085');

      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1299);  --Boleto a Vencer - Protesto nao efetuado
      RAISE vr_exc_erro;
    END IF;

    --- Titulo nao ultrapassou data Instrucao Automatica de Protesto
    IF rw_crapcob.flgdprot = 1 AND
        ((rw_crapcob.dtvencto + rw_crapcob.qtdiaprt) > TRUNC(SYSDATE)) THEN
      -- Gerar o retorno para o cooperado 
      -- Pedido de Protesto Nao Permitido para o Titulo
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => '39' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar_arq_rem_085');

      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1300);  --Boleto nao ultrapassou data de Instr. Autom. de Protesto - Protesto nao efetuado
      RAISE vr_exc_erro;
    END IF;
    
    -- Verificar o indicador da situacao cartoraria
    IF rw_crapcob.insitcrt = 1 THEN
      -- 1 = C/Inst Protesto
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => '40' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar_arq_rem_085');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1388);  --Boleto com instrucao de protesto - Aguarde confirmacao do Banco do Brasil - Protesto nao efetuado
      RAISE vr_exc_erro;
    ELSIF rw_crapcob.insitcrt = 2 THEN
      -- 2 = Rem Cartorio
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XJ' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar_arq_rem_085');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1389);  --Boleto com instrucao de sustacao - Aguarde confirmacao do Banco do Brasil - Protesto nao efetuado
      RAISE vr_exc_erro;
    ELSIF rw_crapcob.insitcrt = 3 THEN
      -- 3 = Em Cartorio
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XF' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar_arq_rem_085');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1303);  --Boleto Em Cartorio - Protesto nao efetuado
      RAISE vr_exc_erro;
    END IF;
    
    -- Pesquisar a conta do associado
    OPEN cr_crapass(pr_cdcooper => rw_crapcob.cdcooper
                   ,pr_nrdconta => rw_crapcob.nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := NULL;
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;
    
    -- Se pessoa for fisica, nao protestar
    IF rw_crapass.inpessoa = 1 THEN
      -- Gerar o retorno para o cooperado 
      -- Pedido de Protesto Nao Permitido para o Titulo
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => '39' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar_arq_rem_085');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1304);  --Instrucao nao permitida para Pessoa Fisica
      RAISE vr_exc_erro;
    END IF;

    -- Verifica se ja existe Instrucao de "Protestar"
    OPEN cr_crapcre (pr_cdcooper => pr_cdcooper
                    ,pr_nrcnvcob => pr_nrcnvcob
                    ,pr_dtmvtolt => pr_dtmvtolt
                    ,pr_intipmvt => 1);
    --Proximo registro
    FETCH cr_crapcre INTO rw_crapcre;
    --Se Encontrou
    IF cr_crapcre%FOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcre;
      --Selecionar remessa
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_cdocorre => 9
                      ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem;
        -- Pedido de Protesto Nao Permitido para o Titulo
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => '40' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar_arq_rem_085');
      
        -- Recusar a instrucao
        vr_dscritic := gene0001.fn_busca_critica(1305);  --Instrucao de Protesto ja efetuada - Protesto nao efetuado
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_craprem%ISOPEN THEN
        CLOSE cr_craprem;
      END IF;
    END IF;
    --Fechar Cursor
    IF cr_crapcre%ISOPEN THEN
      CLOSE cr_crapcre;
    END IF;
    
    -- Validar parametro de tela 
    IF rw_crapcob.cddespec NOT IN (1,2) THEN
      --Prepara retorno cooperado
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => '39' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      --Se Ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar_arq_rem_085');

      vr_dscritic := gene0001.fn_busca_critica(1306);  --Especie Docto diferente de DM e DS - Protesto nao efetuado!';
      --Retornar
      RAISE vr_exc_erro;
    END IF;
    
    ---- Validacao para nao executante de protesto ----
    OPEN cr_crapsab (pr_cdcooper => rw_crapcob.cdcooper
                    ,pr_nrdconta => rw_crapcob.nrdconta
                    ,pr_nrinssac => rw_crapcob.nrinssac);
    --Posicionar primeiro registro
    FETCH cr_crapsab INTO rw_crapsab;
    --Se nao encontrou
    IF cr_crapsab%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapsab;
      --Prepara retorno cooperado
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => NULL -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      --SAIR
      RAISE vr_exc_erro;
    ELSE
      --Fechar Cursor
      CLOSE cr_crapsab;
    END IF;  
      
    /*Rafael Ferreira (Mouts) - INC0022229
      Conforme informado por Deise Carina Tonn da area de Negócio, esta validação não é mais necessária
      pois agora Todas as cidades podem ter protesto*/
    --Selecionar pracas nao executantes de processo
   /* OPEN cr_crappnp (pr_nmextcid => rw_crapsab.nmcidsac
                    ,pr_cduflogr => rw_crapsab.cdufsaca);
    --Posicionar no proximo registro
    FETCH cr_crappnp INTO rw_crappnp;
    --Se encontrar
    IF cr_crappnp%FOUND THEN
      --Fechar Cursor
      CLOSE cr_crappnp;
      --Prepara retorno cooperado
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => '39' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      --Se Ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar_arq_rem_085');

      vr_dscritic := gene0001.fn_busca_critica(1307);  --Praca nao executante de protesto – Instrucao nao efetuada
      --Retornar
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    IF cr_crappnp%ISOPEN THEN
      CLOSE cr_crappnp;
    END IF;*/
    ------ FIM - VALIDACOES PARA RECUSAR ------

    IF rw_crapcob.cdbandoc = 85 THEN
      rw_crapcob.flgdprot:= 1;
      rw_crapcob.qtdiaprt:= pr_qtdiaprt;
      
      --Atualizar Cobranca
      BEGIN
        UPDATE crapcob SET crapcob.flgdprot = rw_crapcob.flgdprot,
                           crapcob.qtdiaprt = rw_crapcob.qtdiaprt
        WHERE crapcob.rowid = rw_crapcob.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

          vr_cdcritic := 1035;  --Erro ao atualizar crapcob
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                         ' flgdprot:'||rw_crapcob.flgdprot||
                         ', qtdiaprt:'||rw_crapcob.qtdiaprt||
                         ' com rowid:'||rw_crapcob.rowid||
                         '. '||sqlerrm;
          RAISE vr_exc_erro;
      END;

      -- Prepara retorno cooperado
      -- Confirmacao Recebimento Instrucao de Protesto
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 19   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => NULL -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      --Se Ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_protestar_arq_rem_085');

    END IF; -- FIM do IF cdbandoc = 85

    --Montar Indice para lancamento tarifa
    vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                   lpad(pr_nrdconta,10,'0')||
                   lpad(pr_nrcnvcob,10,'0')||
                   lpad(19,10,'0')||
                   lpad('0',10,'0')||
                   lpad(pr_tab_lat_consolidada.Count+1,10,'0');
    -- Gerar registro Tarifa 
    pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
    pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
    pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
    pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
    pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
    pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 19;    -- 19 -  Confirmacao Recebimento Instrucao de Protesto
    pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= NULL;  -- Motivo
    pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic||vr_dsparame;
      
      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_protestar_arq_rem_085. '||sqlerrm||vr_dsparame;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);
  END pc_inst_protestar_arq_rem_085;
  
  -- Procedure para Sustar Protesto e Manter o Titulo
  PROCEDURE pc_inst_sustar_manter (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                  ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                  ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                  ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                  ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                  ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                  ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                  ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                  ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                  ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_sustar_manter            Antigo: b1wgen0088.p/inst-sustar-manter
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Douglas Quisinski
    --  Data     : Janeiro/2016                     Ultima atualizacao: 12/02/2019
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Sustar Protesto e Manter Titulo
    --
    --   Alteracao : 22/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --
    --               08/02/2018 - Alterações referente ao PRJ352 - Nova solução de protesto
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            (Ana - Envolti - Ch. REQ0011728)
    --
    --               12/02/2019 - Teste Revitalização
    --                            (Belli - Envolti - Ch. REQ0035813)     
    --                            
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_des_erro   VARCHAR2(3);
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    
    -- Movimento da Remessa de Titulo
    CURSOR cr_craprem (pr_cdcooper IN craprem.cdcooper%TYPE
                      ,pr_nrcnvcob IN craprem.nrcnvcob%TYPE
                      ,pr_nrdconta IN craprem.nrdconta%TYPE
                      ,pr_nrdocmto IN craprem.nrdocmto%TYPE
                      ,pr_nrremret IN craprem.nrremret%TYPE
                      ,pr_cdocorre IN craprem.cdocorre%TYPE) IS
      SELECT rem.cdcooper
        FROM craprem rem
       WHERE rem.cdcooper = pr_cdcooper
         AND rem.nrdconta = pr_nrdconta
         AND rem.nrcnvcob = pr_nrcnvcob
         AND rem.nrdocmto = pr_nrdocmto
         AND rem.nrremret = pr_nrremret
         AND rem.cdocorre = pr_cdocorre
      ORDER BY rem.progress_recid ASC;
    rw_craprem cr_craprem%ROWTYPE;

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    -- Registro da Cooperativa
    rw_crapcop    COBR0007.cr_crapcop%ROWTYPE;
    -- Registro de Cobrança
    rw_crapcob    COBR0007.cr_crapcob%ROWTYPE;
    -- Registro de controle retorno titulos bancarios
    rw_crapcre    COBR0007.cr_crapcre%ROWTYPE;
    -- Registro de cadastro de cobranca
    rw_crapcco    COBR0007.cr_crapcco%ROWTYPE;
    -- Registro de retorno
    rw_crapret    COBR0007.cr_crapret%ROWTYPE;

    vr_nrremret     INTEGER;
    vr_nrseqreg     INTEGER;
    vr_rowid_ret    ROWID;
    vr_index_lat    VARCHAR2(60);
    vr_qtdiacan     tbcobran_param_protesto.qtdias_cancelamento%TYPE;

  BEGIN
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_manter');
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                  ||', pr_nrdconta:'||pr_nrdconta
                  ||', pr_nrcnvcob:'||pr_nrcnvcob
                  ||', pr_nrdocmto:'||pr_nrdocmto
                  ||', pr_cdocorre:'||pr_cdocorre
                  ||', pr_dtmvtolt:'||pr_dtmvtolt
                  ||', pr_cdoperad:'||pr_cdoperad
                  ||', pr_nrremass:'||pr_nrremass;

    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;

    -- Processo de Validacao Recusas Padrao
    COBR0007.pc_efetua_val_recusa_padrao(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                        ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                        ,pr_nrcnvcob => pr_nrcnvcob   --> Numero Convenio
                                        ,pr_nrdocmto => pr_nrdocmto   --> Numero Documento
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Data Movimento
                                        ,pr_cdoperad => pr_cdoperad   --> Operador
                                        ,pr_cdinstru => '11'          --> Codigo Instrucao
                                        ,pr_nrremass => pr_nrremass   --> Numero da Remessa
                                        ,pr_rw_crapcob => rw_crapcob  --> Registro de Cobranca de Recusa
                                        ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                        ,pr_dscritic => vr_dscritic); --> Descricao da Critica
    
    --Se ocorrer Erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_manter');

    IF rw_crapcob.cdbandoc = 085 AND
       rw_crapcob.flgregis = 1   AND 
       rw_crapcob.flgcbdda = 1   AND 
       rw_crapcob.insitpro <= 2  THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XA' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_manter');

      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1180);  --Titulo em processo de registro. Favor aguardar
      RAISE vr_exc_erro;
    END IF;

    -----  VALIDACOES PARA RECUSAR  -----
    IF rw_crapcob.incobran = 0 AND
       rw_crapcob.insitcrt = 2 THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XJ' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_manter');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1348);  --Boleto com instrucao de sustacao - Aguarde sustacao do Banco do Brasil - Instr. Sustar nao efetuada!';
      RAISE vr_exc_erro;
    END IF;
    
    IF rw_crapcob.incobran = 0 AND
       rw_crapcob.insitcrt = 4 THEN
      -- Titulo ja se encontra na situacao Pretendida
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'A7' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_manter');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1349);  --Boleto sustado - Instr. Sustar nao efetuada
      RAISE vr_exc_erro;
    END IF;

    -- Titulo ainda nao venceu
    IF  rw_crapcob.dtvencto >= pr_dtmvtolt THEN
      -- Pedido de Cancelamento/Sustacao para Titulos sem Instrucao de Protesto
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => '41' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_manter');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1350);  --Boleto a Vencer - Instr. Sustar nao efetuado
      RAISE vr_exc_erro;
    END IF;
    
    -- Apenas para BB
    IF(rw_crapcob.cdbandoc = 1) THEN
    	--
      IF rw_crapcob.incobran = 0 AND
         rw_crapcob.insitcrt = 2 THEN
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XJ' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_manter');
        
        -- Recusar a instrucao
        vr_dscritic := gene0001.fn_busca_critica(1348);  --Boleto com instrucao de sustacao - Aguarde sustacao do Banco do Brasil - Instr. Sustar nao efetuada!';
        RAISE vr_exc_erro;
      END IF;
    -- Titulos sem confirmacao Instrucao de Protesto
    OPEN cr_crapret (pr_cdcooper => rw_crapcob.cdcooper
                    ,pr_nrdconta => rw_crapcob.nrdconta
                    ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                    ,pr_nrdocmto => rw_crapcob.nrdocmto
                    ,pr_cdocorre => 19);
    --Proximo Registro
    FETCH cr_crapret INTO rw_crapret;
    --Se nao encontrou
    IF cr_crapret%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapret;
      -- Gerar o retorno para o cooperado 
      -- Pedido de Cancelamento/Sustacao para Titulos sem Instrucao de Protesto
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => '41' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_manter');

      -- Recusar a instrucao
        vr_dscritic := gene0001.fn_busca_critica(1352);  --Boleto sem Confirmação Instrução Protesto - Instrucao Sustar nao efetuada
      RAISE vr_exc_erro;
    ELSE 
      -- Fechar o cursor
      CLOSE cr_crapret;  
    END IF;
      --
    END IF;

    -- Verifica se ja existe Pedido de Baixa 
    OPEN cr_crapcre (pr_cdcooper => pr_cdcooper
                    ,pr_nrcnvcob => pr_nrcnvcob
                    ,pr_dtmvtolt => pr_dtmvtolt
                    ,pr_intipmvt => 1);
    --Proximo registro
    FETCH cr_crapcre INTO rw_crapcre;
    --Se Encontrou
    IF cr_crapcre%FOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcre;
      -- Verifica se titulo esta "indo" ao BB
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_nrremret => rw_crapcre.nrremret
                      ,pr_cdocorre => 1);
      --Proximo registro
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem;
        --Selecionar cadastro convenio
        OPEN cr_crapcco (pr_cdcooper => rw_crapcob.cdcooper
                        ,pr_nrconven => rw_crapcob.nrcnvcob);
        FETCH cr_crapcco INTO rw_crapcco;
        IF cr_crapcco%FOUND AND rw_crapcco.dsorgarq = 'PROTESTO' THEN
          CLOSE cr_crapcco;
          -- Gerar o retorno para o cooperado 
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                             ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                             ,pr_cdmotivo => 'XK' -- Motivo 
                                             ,pr_vltarifa => 0    -- Valor da Tarifa  
                                             ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                             ,pr_cdagectl => rw_crapcop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_nrremass => pr_nrremass
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
          -- Verifica se ocorreu erro durante a execucao
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_manter');

          -- Recusar a instrucao
          vr_dscritic := gene0001.fn_busca_critica(1353);  --Boleto sera enviado ao convenio protesto Banco do Brasil - Instrucao Sustar nao efetuada
          RAISE vr_exc_erro;
        END IF;
      END IF;
      
      IF cr_craprem%ISOPEN THEN
        --Fechar Cursor
        CLOSE cr_craprem;
      END IF;
      
      -- Verifica se ja existe Instrucao de "Protestar"
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_nrremret => rw_crapcre.nrremret
                      ,pr_cdocorre => 9);
      --Proximo registro
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem;
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => '40' -- Motivo 
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_manter');

        -- Recusar a instrucao
        vr_dscritic := gene0001.fn_busca_critica(1354);  --Ja existe Instrucao de Protesto - Instrucao Sustar nao efetuada
        RAISE vr_exc_erro;
      END IF;
      
      IF cr_craprem%ISOPEN THEN
        --Fechar Cursor
        CLOSE cr_craprem;
      END IF;
      
      -- Verifica se ja existe Instrucao de "Sustar e Manter"
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_nrremret => rw_crapcre.nrremret
                      ,pr_cdocorre => pr_cdocorre);
      --Proximo registro
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem;
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XL' -- Motivo 
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_manter');

        -- Recusar a instrucao
        vr_dscritic := gene0001.fn_busca_critica(1355);  --Ja existe Instrucao de Sustar/Manter - Instrucao Sustar nao efetuada
        RAISE vr_exc_erro;
      END IF;
      
      IF cr_craprem%ISOPEN THEN
        --Fechar Cursor
        CLOSE cr_craprem;
      END IF;
      
    END IF;
    --Fechar Cursor
    IF cr_crapcre%ISOPEN THEN
      CLOSE cr_crapcre;
    END IF;

    IF rw_crapcob.cdbandoc = 85 THEN 
      
    /*
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XM' -- Motivo 
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Recusar a instrucao
      vr_dscritic := 'Boleto do Banco 085 - Instr. Sustar nao efetuada!';*/
      
      -- Verifica o prazo de cancelamento do protesto no cartório
      IF rw_crapcob.insitcrt = 3 THEN
        --
        BEGIN
          --
          SELECT qtdias_cancelamento
            INTO vr_qtdiacan
            FROM tbcobran_param_protesto
           WHERE cdcooper = rw_crapcob.cdcooper;
          --
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

            vr_cdcritic := 1036;  --Erro ao buscar a qtd de dias limite de cancelamento
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'tbcobran_param_protesto '||
                          ' com cdcooper:'||rw_crapcob.cdcooper||
                          '. '||sqlerrm;
      RAISE vr_exc_erro;
        END;
        --
        IF pr_dtmvtolt > (rw_crapcob.dtsitcrt + vr_qtdiacan) THEN
          -- Gerar o retorno para o cooperado 
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                             ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                             ,pr_cdmotivo => 'XM' -- Motivo -- Revisar
                                             ,pr_vltarifa => 0    -- Valor da Tarifa  
                                             ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                             ,pr_cdagectl => rw_crapcop.cdagectl
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_nrremass => pr_nrremass
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
          -- Verifica se ocorreu erro durante a execucao
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_manter');

          -- Recusar a instrucao
          vr_dscritic := gene0001.fn_busca_critica(1356);  --Prazo de cancelamento do protesto excedido - Instrucao Sustar nao efetuada
      RAISE vr_exc_erro;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    
    -- tratamento para titulos migrados 
    IF rw_crapcob.flgregis = 1 AND rw_crapcob.cdbandoc = 001 THEN
      --Selecionar cadastro convenio
      OPEN cr_crapcco (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrconven => rw_crapcob.nrcnvcob);
      --Proximo registro
      FETCH cr_crapcco INTO rw_crapcco;
      --Se encontrou
      IF cr_crapcco%FOUND AND rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
        --Fechar Cursor
        CLOSE cr_crapcco;
        --Protesta titulo Migrado
        COBR0007.pc_inst_titulo_migrado (pr_idregcob => rw_crapcob --Rowtype da Cobranca
                                        ,pr_dsdinstr => 'Sustacao' --Descricao da Instrucao
                                        ,pr_dtaltvct => NULL       --Data Alteracao Vencimento
                                        ,pr_vlaltabt => 0          --Valor Alterado Abatimento
                                        ,pr_nrdctabb => rw_crapcco.nrdctabb --Numero da Conta BB
                                        ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                        ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_manter');

        vr_dscritic := gene0001.fn_busca_critica(1357);  --Solicitacao de sustacao de titulo migrado. Aguarde confirmacao no proximo dia util
        --Retornar
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_crapcco%ISOPEN THEN
        CLOSE cr_crapcco;
      END IF;
    END IF;
    ----- FIM - VALIDACOES PARA RECUSAR -----

    ---- LOG de Processo ----
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid  --ROWID da Cobranca
                                 ,pr_cdoperad => pr_cdoperad       --Operador
                                 ,pr_dtmvtolt => pr_dtmvtolt       --Data movimento
                                 ,pr_dsmensag => 'Sustar e Manter' --Descricao Mensagem
                                 ,pr_des_erro => vr_des_erro       --Indicador erro
                                 ,pr_dscritic => vr_dscritic);     --Descricao erro
    --Se ocorreu erro
    IF vr_des_erro = 'NOK' THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_manter');

    IF rw_crapcob.cdbandoc IN (1,85) THEN
      -- Libera o boleto
      IF rw_crapcob.cdbandoc = 85 THEN
        --
        rw_crapcob.dtbloque := NULL;
        --
        BEGIN
          --
          UPDATE crapcob
             SET crapcob.dtbloque = NULL
           WHERE crapcob.rowid = rw_crapcob.rowid;
          --
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

            vr_cdcritic := 1035;  --Erro ao atualizar crapcob
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                           ' dtbloque:NULL'||
                           ' com rowid:'||rw_crapcob.rowid||
                           '. '||sqlerrm;
            RAISE vr_exc_erro;
        END;
        --
        IF rw_crapcob.insitcrt = 0 AND rw_crapcob.flgdprot = 1 THEN
          --
          rw_crapcob.qtdiaprt := 0;
          rw_crapcob.flgdprot := 0;
          rw_crapcob.insrvprt := 0;
          --
        END IF;
        --
      END IF;
      -- Registra Instrucao de Sustar e Manter
      PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                     ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                     ,pr_dtmvtolt => pr_dtmvtolt         --Data movimento
                                     ,pr_cdoperad => pr_cdoperad         --Codigo Operador
																		 ,pr_idregcob => rw_crapcob.rowid
                                     ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                     ,pr_rowid_ret => vr_rowid_ret       --ROWID Remessa Retorno
                                     ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                     ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                     ,pr_dscritic => vr_dscritic);       --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_manter');

      --Incrementar Sequencial
      vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;
      --Criar tabela Remessa
      PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                   ,pr_nrremret => vr_nrremret          --Numero Remessa
                                   ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                   ,pr_cdocorre => pr_cdocorre          --Codigo Ocorrencia
                                   ,pr_cdmotivo => NULL                 --Codigo Motivo
                                   ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                   ,pr_vlabatim => 0                    --Valor Abatimento
                                   ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                   ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);        --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_sustar_manter');
    
    IF rw_crapcob.cdbandoc = 85 THEN
      --Montar Indice para lancamento tarifa
      vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                     lpad(pr_nrdconta,10,'0')||
                     lpad(pr_nrcnvcob,10,'0')||
                     lpad(19,10,'0')||
                     lpad('0',10,'0')||
                     lpad(pr_tab_lat_consolidada.Count+1,10,'0');
      -- Gerar registro Tarifa 
      pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
      pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
      pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
      pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
      pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
      pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 20;    -- 20 - Confirmacao de Sustacao ou Cancelamento Protesto
      pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= NULL;  -- Motivo
      pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic||vr_dsparame,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);
      -- Ajuste mensagem - 12/02/2019 - REQ0035813
      IF nvl(pr_cdcritic,0) IN ( 1197, 9999, 1034, 1035, 1036, 1037 ) THEN
        pr_cdcritic := 1224;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      ELSIF nvl(pr_cdcritic,0) = 0 AND
            SUBSTR(pr_dscritic, 1, 7 ) IN ( '1197 - ', '9999 - ', '1034 - ', '1035 - ', '1036 - ', '1037 - ' ) THEN
        pr_cdcritic := 1224;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_sustar_manter. '||sqlerrm||vr_dsparame;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

      pr_cdcritic := 1224; -- Ajuste mensagem - 12/02/2019 - REQ0035813
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
  END pc_inst_sustar_manter;
  
  -- Procedure para Cancelar o Protesto BB
  PROCEDURE pc_inst_cancel_protesto_bb(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                    ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                    ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                    ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                    ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                    ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                    ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                    ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ) IS
    -- ...........................................................................................
    --
    --  Programa : pc_inst_cancel_protesto          Antigo: b1wgen0088.p/inst-cancel-protesto
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Douglas Quisinski
    --  Data     : Janeiro/2016                     Ultima atualizacao: 24/08/201829/09/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Alterar o vencimento
    --
    --   Alteracao : 25/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --
    --               20/05/2017 - Ajustado parametro flgdprot para 0 quando enviar informacao a CIP
    --                            de um titulo DDA ao cancelar protesto (P340 - NPC - Rafael)
    --
    --               09/06/2017 - Ajustar para tratar as negativacoes do serasa (Douglas - Melhoria 271.2)
    --
    --               08/02/2018 - Alterações referente ao PRJ352 - Nova solução de protesto
    --
    --               29/09/2017 - Ajustado com UPPER para remover a mensagem "** SERVICO DE PROTESTO 
    --                            SERA EFETUADO PELO BANCO DO BRASIL **" quando cancelar a 
    --                            instrução de protesto (Douglas - Chamado 754911)
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_cdcritic2  PLS_INTEGER;
    vr_dscritic2  VARCHAR2(4000);
    vr_des_erro   VARCHAR2(3);
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    
    --Selecionar remessas
    CURSOR cr_craprem2 (pr_cdcooper IN craprem.cdcooper%type
                       ,pr_nrcnvcob IN craprem.nrcnvcob%type
                       ,pr_nrdconta IN craprem.nrdconta%type
                       ,pr_nrdocmto IN craprem.nrdocmto%type
                       ,pr_cdmotivo IN craprem.cdmotivo%type
                       ,pr_cdocorre IN craprem.cdocorre%type
                       ,pr_dtaltera IN craprem.dtaltera%type) IS
      SELECT rem.dtaltera
            ,rem.cdcooper
            ,rem.cdocorre
            ,rem.nrdconta
            ,rem.nrdocmto
            ,rem.nrcnvcob
            ,rem.dtdprorr
            ,rem.vlabatim
            ,rem.rowid
        FROM craprem rem
       WHERE rem.cdcooper = pr_cdcooper
         AND rem.nrcnvcob = pr_nrcnvcob
         AND rem.nrdconta = pr_nrdconta
         AND rem.nrdocmto = pr_nrdocmto
         AND rem.cdmotivo = pr_cdmotivo
         AND rem.cdocorre = pr_cdocorre
         AND rem.dtaltera = pr_dtaltera
       ORDER BY rem.progress_recid DESC;
    -- Registro de Remessa
    rw_craprem2   cr_craprem2%ROWTYPE;

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    -- Registro da Cooperativa
    rw_crapcop    COBR0007.cr_crapcop%ROWTYPE;
    -- Registro de Cobrança
    rw_crapcob    COBR0007.cr_crapcob%ROWTYPE;
    -- Registro de Remessa
    rw_craprem    COBR0007.cr_craprem%ROWTYPE;
    -- Registro de controle retorno titulos bancarios
    rw_crapcre    COBR0007.cr_crapcre%ROWTYPE;
    -- Registro de retorno
    rw_crapret    COBR0007.cr_crapret%ROWTYPE;
    -- Registro de Cadastro de Cobranca
    rw_crapcco    COBR0007.cr_crapcco%ROWTYPE;
    -- Registro de Data
    rw_crapdat    BTCH0001.cr_crapdat%ROWTYPE;

    --Tabelas de Memoria de Remessa
    vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
    vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
    
    vr_nrremret     INTEGER;
    vr_nrseqreg     INTEGER;
    vr_rowid_ret    ROWID;
    vr_index_lat    VARCHAR2(60);

    -- Identificar se o boleto possui Negativacao Serasa
    vr_is_serasa    BOOLEAN;

  BEGIN
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                  ||', pr_nrdconta:'||pr_nrdconta
                  ||', pr_nrcnvcob:'||pr_nrcnvcob
                  ||', pr_nrdocmto:'||pr_nrdocmto
                  ||', pr_cdocorre:'||pr_cdocorre
                  ||', pr_dtmvtolt:'||pr_dtmvtolt
                  ||', pr_cdoperad:'||pr_cdoperad
                  ||', pr_nrremass:'||pr_nrremass;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;

    -- Processo de Validacao Recusas Padrao
    COBR0007.pc_efetua_val_recusa_padrao(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                        ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                        ,pr_nrcnvcob => pr_nrcnvcob   --> Numero Convenio
                                        ,pr_nrdocmto => pr_nrdocmto   --> Numero Documento
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Data Movimento
                                        ,pr_cdoperad => pr_cdoperad   --> Operador
                                        ,pr_cdinstru => '41'          --> Codigo Instrucao
                                        ,pr_nrremass => pr_nrremass   --> Numero da Remessa
                                        ,pr_rw_crapcob => rw_crapcob  --> Registro de Cobranca de Recusa
                                        ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                        ,pr_dscritic => vr_dscritic); --> Descricao da Critica
    
    --Se ocorrer Erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');
    
    IF rw_crapcob.cdbandoc = 085 AND
       rw_crapcob.flgregis = 1   AND 
       rw_crapcob.flgcbdda = 1   AND 
       rw_crapcob.insitpro <= 2  THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XA' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');

      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1180);  --Titulo em processo de registro. Favor aguardar.
      RAISE vr_exc_erro;
    END IF;

    -- Verificamos se o boleto possui Negativacao no Serasa
/*    
    IF rw_crapcob.flserasa = 1 AND 
       rw_crapcob.qtdianeg > 0 THEN
*/
    -- alterado if para utilizar a função fn_flserasa 
    -- PRB0041685  Roberto Holz - Mout´s / Alcemir Jr. 20/05/2019
    IF COBR0007.fn_flserasa(rw_crapcob.flserasa,
														rw_crapcob.qtdianeg,
														rw_crapcob.inserasa,
														rw_crapcob.dtvencto,
														pr_dtmvtolt) THEN       
      -- Sera tratado como Negativacao Serasa
      vr_is_serasa := TRUE;
    ELSE 
      -- Sera tratado como Protesto
      vr_is_serasa := FALSE;
    END IF;

    -----  VALIDACOES PARA RECUSAR  -----
    -- Verificamos se o boleto possui Negativacao no Serasa
    IF vr_is_serasa THEN 
      -- Buscar a data
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;
      
      -- Verificacoes para recusar Instrucao de Negativacao do Serasa
      IF rw_crapdat.dtmvtolt >= (rw_crapcob.dtvencto + rw_crapcob.qtdianeg) THEN
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'S1' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');

        -- Recusar a instrucao
        vr_dscritic := gene0001.fn_busca_critica(1309);  --Excedido prazo cancelamento da instrucao automatica de negativacao! Cancelamento instrucao negativacao nao efetuado
        RAISE vr_exc_erro;        
      END IF;
      
      /* Verificar se foi enviado ao Serasa */
      IF  rw_crapcob.inserasa <> 0 THEN
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'S1' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');

        -- Recusar a instrucao
        vr_dscritic := gene0001.fn_busca_critica(1310);  --Titulo ja enviado para Negativacao! Cancelamento instrucao negativacao nao efetuado.
        RAISE vr_exc_erro;        
      END IF;
                
    ELSE -- Fim das validacoes de negativacao Serasa

    -- Titulos sem confirmacao Instrucao de Protesto
    OPEN cr_crapret (pr_cdcooper => rw_crapcob.cdcooper
                    ,pr_nrdconta => rw_crapcob.nrdconta
                    ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                    ,pr_nrdocmto => rw_crapcob.nrdocmto
                    ,pr_cdocorre => 19);
    --Proximo Registro
    FETCH cr_crapret INTO rw_crapret;
    --Se nao encontrou
    IF cr_crapret%FOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapret;
      -- Gerar o retorno para o cooperado 
      -- Pedido de Cancelamento/Sustacao para Titulos sem Instrucao de Protesto
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => '41' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');

      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1358);  --Boleto sem Confirmacao Instrucao Protesto - Cancelamento Protesto nao efetuado
      RAISE vr_exc_erro;
    ELSE 
      -- Fechar o cursor
      CLOSE cr_crapret;  
    END IF;
    
    -- Titulo sem Instrucao Automatica de Protesto
    IF rw_crapcob.flgdprot = 0 THEN
      -- Titulo ja se encontra na situacao Pretendida
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'A7' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');

      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1312); --Boleto sem Instrucao Automatica de Protesto - Cancelamento Protesto nao efetuado
      RAISE vr_exc_erro;
    END IF;
    
    -- Verificar o indicador da situacao cartoraria
    IF rw_crapcob.insitcrt = 1 THEN
      -- 1 = C/Inst Protesto
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => '40' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1359); --Boleto com instrucao de protesto - Cancelamento Protesto nao efetuado
      RAISE vr_exc_erro;
    ELSIF rw_crapcob.insitcrt = 2 THEN
      -- 2 = Rem Cartorio
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XJ' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1360); --Boleto com instrucao de sustacao - Aguarde sustacao do Banco do Brasil - Canc. Protesto nao efetuado
      RAISE vr_exc_erro;
    ELSIF rw_crapcob.insitcrt = 3 THEN
      -- 3 = Em Cartorio
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XF' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');
      
      -- Recusar a instrucao
      vr_dscritic := gene0001.fn_busca_critica(1361); --Boleto em Cartorio - Cancelamento Protesto nao efetuado
      RAISE vr_exc_erro;
    ELSIF rw_crapcob.insitcrt = 4 THEN
      -- 4 = Sustado
      IF rw_crapcob.incobran = 0 THEN -- Em Aberto
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'A7' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');
        
        -- Recusar a instrucao
        vr_dscritic := gene0001.fn_busca_critica(1314); --Boleto Sustado - Cancelamento Protesto nao efetuado!';
        RAISE vr_exc_erro;
      END IF;
    END IF;
    
    -- nao permitir cancelamento de protesto no convenio de protesto
    IF rw_crapcob.cdbandoc <> rw_crapcop.cdbcoctl THEN
      --Selecionar cadastro convenio
      OPEN cr_crapcco (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrconven => rw_crapcob.nrcnvcob);
      FETCH cr_crapcco INTO rw_crapcco;
      IF cr_crapcco%FOUND AND rw_crapcco.dsorgarq = 'PROTESTO' THEN
        CLOSE cr_crapcco;
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XG' -- Motivo 
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');

        -- Recusar a instrucao
        vr_dscritic := gene0001.fn_busca_critica(1362); --Nao e permitido cancelar instrucao de protesto do boleto no convenio protesto - Canc. Protesto nao efetuado
        RAISE vr_exc_erro;
      END IF;
    END IF;
    IF cr_crapcco%ISOPEN THEN
      CLOSE cr_crapcco;
    END IF;
    
    -- Verifica se ja existe Pedido de Baixa 
    OPEN cr_crapcre (pr_cdcooper => rw_crapcob.cdcooper
                    ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                    ,pr_dtmvtolt => pr_dtmvtolt
                    ,pr_intipmvt => 1);
    --Proximo registro
    FETCH cr_crapcre INTO rw_crapcre;
    --Se Encontrou
    IF cr_crapcre%FOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcre;
      --Selecionar remessa
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_cdocorre => 9
                      ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem;
        -- Preparar Lote de Retorno Cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                           ,pr_cdocorre => 26   -- Codigo Ocorrencia
                                           ,pr_cdmotivo => '40' -- Motivo
                                           ,pr_vltarifa => 0    -- valor da Tarifa
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                           ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                           ,pr_nrremass => pr_nrremass --Numero Remessa
                                           ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                           ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');

        vr_dscritic := gene0001.fn_busca_critica(1363); --Instrucao de Protesto ja efetuada - Cancelamento Protesto nao efetuado
        --Retornar
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_craprem%ISOPEN THEN
        CLOSE cr_craprem;
      END IF;
      
      -- Verifica se ja existe Instrucao de "Cancelar Protesto"
      OPEN cr_craprem2 (pr_cdcooper => rw_crapcob.cdcooper
                       ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                       ,pr_nrdconta => rw_crapcob.nrdconta
                       ,pr_nrdocmto => rw_crapcob.nrdocmto
                       ,pr_cdocorre => 31
                       ,pr_cdmotivo => '9'
                       ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem2 INTO rw_craprem2;
      --Se Encontrou
      IF cr_craprem2%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem2;
        -- Preparar Lote de Retorno Cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                           ,pr_cdocorre => 26   -- Codigo Ocorrencia
                                           ,pr_cdmotivo => 'A7' -- Motivo
                                           ,pr_vltarifa => 0    -- valor da Tarifa
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                           ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                           ,pr_nrremass => pr_nrremass --Numero Remessa
                                           ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                           ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');

        vr_dscritic := gene0001.fn_busca_critica(1311); --Instrucao de Cancelamento Protesto ja efetuada - Cancelamento Protesto nao efetuado
        --Retornar
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_craprem2%ISOPEN THEN
        CLOSE cr_craprem2;
      END IF;
    END IF;
    --Fechar Cursor
    IF cr_crapcre%ISOPEN THEN
      CLOSE cr_crapcre;
    END IF;
    END IF;
    ------ FIM - VALIDACOES PARA RECUSAR ------

    -- Verificar se nao eh Serasa
    IF NOT vr_is_serasa THEN 
      -- As informacoes de DDA e Titulos Migrados 
      -- sao apenas para Protesto
    IF rw_crapcob.flgcbdda = 1 AND
       rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN
      -- Executa procedimentos do DDA-JD 
      DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob.rowid         --ROWID da Cobranca
                                       ,pr_tpoperad  => 'A'                      --Tipo Operacao
                                       ,pr_tpdbaixa  => ' '                      --Tipo de Baixa
                                       ,pr_dtvencto  => rw_crapcob.dtvencto      --Data Vencimento
                                       ,pr_vldescto  => rw_crapcob.vldescto      --Valor Desconto
                                       ,pr_vlabatim  => rw_crapcob.vlabatim      --Valor Abatimento
                                       ,pr_flgdprot  => 0                        --Flag Protesto
                                       ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa
                                       ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela memoria retorno DDA
                                       ,pr_cdcritic  => vr_cdcritic2             --Codigo Critica
                                       ,pr_dscritic  => vr_dscritic2);           --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic2,0) <> 0 OR TRIM(vr_dscritic2) IS NOT NULL THEN
        -- Inclui nome do modulo logado - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XC' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
          
        vr_cdcritic := vr_cdcritic2;
        vr_dscritic := vr_dscritic2;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');

    -- tratamento para titulos migrados 
    IF rw_crapcob.flgregis = 1 AND rw_crapcob.cdbandoc = 001 THEN
      --Selecionar cadastro convenio
      OPEN cr_crapcco (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrconven => rw_crapcob.nrcnvcob);
      --Proximo registro
      FETCH cr_crapcco INTO rw_crapcco;
      --Se encontrou
      IF cr_crapcco%FOUND AND rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
        --Fechar Cursor
        CLOSE cr_crapcco;
        --Protesta titulo Migrado
        COBR0007.pc_inst_titulo_migrado (pr_idregcob => rw_crapcob --Rowtype da Cobranca
                                        ,pr_dsdinstr => 'Cancelamento de Protesto' --Descricao da Instrucao
                                        ,pr_dtaltvct => NULL       --Data Alteracao Vencimento
                                        ,pr_vlaltabt => 0          --Valor Alterado Abatimento
                                        ,pr_nrdctabb => rw_crapcco.nrdctabb --Numero da Conta BB
                                        ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                        ,pr_dscritic => vr_dscritic); --Descricao Critica
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');

        vr_dscritic := gene0001.fn_busca_critica(1364); --Solicitacao de cancelamento de protesto de titulo migrado. Aguarde confirmacao no proximo dia util
        --Retornar
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_crapcco%ISOPEN THEN
        CLOSE cr_crapcco;
      END IF;
    END IF;
    END IF;

    --Se tem remesssa dda na tabela
    IF vr_tab_remessa_dda.COUNT > 0 THEN
      rw_crapcob.idopeleg:= vr_tab_remessa_dda(vr_tab_remessa_dda.LAST).idopeleg;
    END IF;
    
    IF vr_is_serasa THEN
      -- removido regra da negativacao serasa
      rw_crapcob.flserasa := 0;
      rw_crapcob.qtdianeg := 0;
      
      --Atualizar Cobranca
      BEGIN
        UPDATE crapcob SET crapcob.flserasa = rw_crapcob.flserasa,
                           crapcob.qtdianeg = rw_crapcob.qtdianeg
        WHERE crapcob.rowid = rw_crapcob.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

          vr_cdcritic := 1035;  --Erro ao atualizar crapcob (SERASA)
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                         ' flserasa:'||rw_crapcob.flserasa||
                         ', qtdianeg:'||rw_crapcob.qtdianeg||
                         ' com rowid:'||rw_crapcob.rowid||
                         '. '||sqlerrm;
          RAISE vr_exc_erro;
      END;

      -- LOG de processo
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid  --ROWID da Cobranca
                                   ,pr_cdoperad => pr_cdoperad   --Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                   ,pr_dsmensag => 'Cancel. Instrucao Negativacao' -- Descricao Mensagem
                                   ,pr_des_erro => vr_des_erro   --Indicador erro
                                   ,pr_dscritic => vr_dscritic); --Descricao erro
      --Se Ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');
      
      IF rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN 
        -- Gerar o retorno para o cooperado 
        -- 94 - Confirmacao de Cancelamento Negativacao Serasa
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 94   -- Confirmacao de Cancelamento Negativacao Serasa
                                           ,pr_cdmotivo => 'S4' -- Motivo 
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');
    
        --Montar Indice para lancamento tarifa
        vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                       lpad(pr_nrdconta,10,'0')||
                       lpad(pr_nrcnvcob,10,'0')||
                       lpad(19,10,'0')||
                       lpad('0',10,'0')||
                       lpad(pr_tab_lat_consolidada.Count+1,10,'0');
        -- Gerar registro Tarifa 
        pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
        pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
        pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
        pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
        pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
        pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 94;    -- 94 - Confirmacao de Cancelamento Negativacao Serasa
        pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= 'S4';  -- Motivo
        pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;
      END IF; -- FIM do IF cdbandoc = 85
      
      -- Fim das alteracoes do Serasa
    ELSE
    -- removido regra da canc de protesto 
    -- permitir boleto de qualquer IF (Rafael)
    rw_crapcob.flgdprot := 0;
    rw_crapcob.qtdiaprt := 0;
    rw_crapcob.dsdinstr := NVL(TRIM(REPLACE(UPPER(rw_crapcob.dsdinstr), 
                                            UPPER('** Servico de protesto sera efetuado pelo Banco do Brasil **'), '')), ' ');
    --Atualizar Cobranca
    BEGIN
      UPDATE crapcob SET crapcob.flgdprot = rw_crapcob.flgdprot,
                         crapcob.qtdiaprt = rw_crapcob.qtdiaprt,
                         crapcob.dsdinstr = rw_crapcob.dsdinstr,
                         crapcob.idopeleg = rw_crapcob.idopeleg
      WHERE crapcob.rowid = rw_crapcob.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        vr_cdcritic := 1035;  --Erro ao atualizar crapcob
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                       ' flgdprot:'||rw_crapcob.flgdprot||
                       ', qtdiaprt:'||rw_crapcob.qtdiaprt||
                       ', dsdinstr:'||rw_crapcob.dsdinstr||
                       ', idopeleg:'||rw_crapcob.idopeleg||
                       ' com rowid:'||rw_crapcob.rowid||
                       '. '||sqlerrm;
        RAISE vr_exc_erro;
    END;

    -- LOG de processo
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid  --ROWID da Cobranca
                                 ,pr_cdoperad => pr_cdoperad   --Operador
                                 ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                 ,pr_dsmensag => 'Cancel. Instrucao Protesto' --Descricao Mensagem
                                 ,pr_des_erro => vr_des_erro   --Indicador erro
                                 ,pr_dscritic => vr_dscritic); --Descricao erro
    --Se Ocorreu erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');

    IF rw_crapcob.cdbandoc = 1 THEN
      -- Registra Instrucao Alter Dados / Protesto
      -- gerar pedido de remessa
      PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                     ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                     ,pr_dtmvtolt => pr_dtmvtolt         --Data movimento
                                     ,pr_cdoperad => pr_cdoperad         --Codigo Operador
																		 ,pr_idregcob => rw_crapcob.rowid
                                     ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                     ,pr_rowid_ret => vr_rowid_ret       --ROWID Remessa Retorno
                                     ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                     ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                     ,pr_dscritic => vr_dscritic);       --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');

      --Incrementar Sequencial
      vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;
      --Criar tabela Remessa
      -- 31. Alteracao de Dados
      --  9. Protestar 
      PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                   ,pr_nrremret => vr_nrremret          --Numero Remessa
                                   ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                   ,pr_cdocorre => 31                   --Codigo Ocorrencia
                                   ,pr_cdmotivo => '9'                  --Codigo Motivo
                                   ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                   ,pr_vlabatim => 0                    --Valor Abatimento
                                   ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                   ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);        --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');

      --Incrementar Sequencial
      vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;
      -- Criar tabela Remessa
      -- 11. Sustar e Manter
      PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                   ,pr_nrremret => vr_nrremret          --Numero Remessa
                                   ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                   ,pr_cdocorre => 11                   --Codigo Ocorrencia
                                   ,pr_cdmotivo => NULL                 --Codigo Motivo
                                   ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                   ,pr_vlabatim => 0                    --Valor Abatimento
                                   ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                   ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);        --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');
      
    ELSE 
      
      IF rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN 
        -- Gerar o retorno para o cooperado 
        -- 20 - Confirmacao de Sustacao ou Cancelamento Protesto
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 20   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => NULL -- Motivo 
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto_bb');
        
        --Montar Indice para lancamento tarifa
        vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                       lpad(pr_nrdconta,10,'0')||
                       lpad(pr_nrcnvcob,10,'0')||
                       lpad(19,10,'0')||
                       lpad('0',10,'0')||
                       lpad(pr_tab_lat_consolidada.Count+1,10,'0');
        -- Gerar registro Tarifa 
        pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
        pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
        pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
        pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
        pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
        pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 20;    -- 20 - Confirmacao de Sustacao ou Cancelamento Protesto
        pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= NULL;  -- Motivo
        pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;
      END IF;
    END IF;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic||vr_dsparame,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);

      -- Complemento para INC0026760
      -- Se chegar erro não tratado de outras chamadas desta procedure joga para 1124
      IF pr_cdcritic = 9999 THEN
        pr_cdcritic := 1224; -- Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;            
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_cancel_protesto_bb. '||sqlerrm||vr_dsparame;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

      pr_cdcritic := 1224; --complemento para INC0026760
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic); --complemento para INC0026760
  END pc_inst_cancel_protesto_bb;
  
  -- Procedure para Cancelar o Protesto
  PROCEDURE pc_inst_cancel_protesto (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                    ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                    ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                    ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                    ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                    ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                    ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                    ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                    ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_cancel_protesto          Antigo: b1wgen0088.p/inst-cancel-protesto
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Douglas Quisinski
    --  Data     : Janeiro/2016                     Ultima atualizacao: 24/08/201808/02/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Alterar o vencimento
    --
    --   Alteracao : 25/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --
    --               20/05/2017 - Ajustado parametro flgdprot para 0 quando enviar informacao a CIP
    --                            de um titulo DDA ao cancelar protesto (P340 - NPC - Rafael)
    --
    --               09/06/2017 - Ajustar para tratar as negativacoes do serasa (Douglas - Melhoria 271.2)
    --
    --               29/09/2017 - Ajustado com UPPER para remover a mensagem "** SERVICO DE PROTESTO 
    --                            SERA EFETUADO PELO BANCO DO BRASIL **" quando cancelar a 
    --                            instrução de protesto (Douglas - Chamado 754911)
    --
    --               08/02/2018 - Alterações referente ao PRJ352 - Nova solução de protesto
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    -- Registro da Cooperativa
    rw_crapcop    COBR0007.cr_crapcop%ROWTYPE;
    -- Registro de Cobrança
    rw_crapcob    COBR0007.cr_crapcob%ROWTYPE;
    --
    rw_crapcco    COBR0007.cr_crapcco%ROWTYPE;
  BEGIN
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto');
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                  ||', pr_nrdconta:'||pr_nrdconta
                  ||', pr_nrcnvcob:'||pr_nrcnvcob
                  ||', pr_nrdocmto:'||pr_nrdocmto
                  ||', pr_cdocorre:'||pr_cdocorre
                  ||', pr_dtmvtolt:'||pr_dtmvtolt
                  ||', pr_cdoperad:'||pr_cdoperad
                  ||', pr_nrremass:'||pr_nrremass;

    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;

    -- Buscar parâmetros do cadastro de cobrança
    OPEN  cr_crapcco(pr_cdcooper => pr_cdcooper
                    ,pr_nrconven => pr_nrcnvcob);
    FETCH cr_crapcco INTO rw_crapcco;
    -- Se não encontrar registro
    IF cr_crapcco%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcco;
--      vr_cdcritic:= 0;
--      vr_dscritic:= 'Convenio de cobranca nao encontrado.';
        vr_cdcritic := 1179;
        vr_dscritic := gene0001.fn_busca_critica(1179); --Registro de cobranca nao encontrado
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcco;

    --Selecionar Cobrancas
    IF cr_crapcob%ISOPEN THEN
      CLOSE cr_crapcob;
    END IF;
      
    OPEN cr_crapcob(pr_cdcooper => pr_cdcooper
                   ,pr_cdbandoc => rw_crapcco.cddbanco
                   ,pr_nrdctabb => rw_crapcco.nrdctabb
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrcnvcob => pr_nrcnvcob
                   ,pr_nrdocmto => pr_nrdocmto);
    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    CLOSE cr_crapcob;
		--

    IF rw_crapcob.inserasa <> 0 THEN
			--
			SSPC0002.pc_cancelar_neg_serasa(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
																		 ,pr_nrcnvcob => pr_nrcnvcob --> Numero do convenio de cobranca. 
																		 ,pr_nrdconta => pr_nrdconta --> Numero da conta/dv do associado.
																		 ,pr_nrdocmto => pr_nrdocmto --> Numero do documento(boleto) 
																		 ,pr_nrremass => pr_nrremass --> Numero da Remessa
																		 ,pr_cdoperad => pr_cdoperad --> Codigo do operador
																		 ,pr_cdcritic => vr_cdcritic --> Código da crítica
																		 ,pr_dscritic => vr_dscritic --> Descrição da crítica
																		 );
			--
		ELSE
			--
    IF rw_crapcob.cdbandoc = 085 THEN

      pc_inst_cancel_protesto_85(pr_cdcooper            => pr_cdcooper
                                ,pr_nrdconta            => pr_nrdconta
                                ,pr_nrcnvcob            => pr_nrcnvcob
                                ,pr_nrdocmto            => pr_nrdocmto
                                ,pr_cdocorre            => pr_cdocorre
                                ,pr_dtmvtolt            => pr_dtmvtolt
                                ,pr_cdoperad            => pr_cdoperad
                                ,pr_nrremass            => pr_nrremass
                                ,pr_idgerbai            => 0 -- Indica se deve gerar baixa ou não (0-Não, 1-Sim)
                                ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
                                ,pr_cdcritic            => pr_cdcritic
                                ,pr_dscritic            => pr_dscritic
                                );
      --
    ELSIF rw_crapcob.cdbandoc = 001 THEN
      --
			IF rw_crapcob.insitcrt = 0 THEN
			  --
				pc_inst_cancel_protesto_bb(pr_cdcooper            => pr_cdcooper
																	,pr_nrdconta            => pr_nrdconta
																	,pr_nrcnvcob            => pr_nrcnvcob
																	,pr_nrdocmto            => pr_nrdocmto
																	,pr_cdocorre            => 41 -- pr_cdocorre
																	,pr_dtmvtolt            => pr_dtmvtolt
																	,pr_cdoperad            => pr_cdoperad
																	,pr_nrremass            => pr_nrremass
																	,pr_tab_lat_consolidada => pr_tab_lat_consolidada
																	,pr_cdcritic            => pr_cdcritic
																	,pr_dscritic            => pr_dscritic
																	);
        --
			ELSE
				--
				pc_inst_sustar_manter(pr_cdcooper            => pr_cdcooper
														 ,pr_nrdconta            => pr_nrdconta
														 ,pr_nrcnvcob            => pr_nrcnvcob
														 ,pr_nrdocmto            => pr_nrdocmto
														 ,pr_cdocorre            => 11 -- pr_cdocorre
														 ,pr_dtmvtolt            => pr_dtmvtolt
														 ,pr_cdoperad            => pr_cdoperad
														 ,pr_nrremass            => pr_nrremass
														 ,pr_tab_lat_consolidada => pr_tab_lat_consolidada
														 ,pr_cdcritic            => pr_cdcritic
														 ,pr_dscritic            => pr_dscritic
														 );
				--
			END IF;
			--
    ELSE 
      --
--      pr_dscritic:= 'Banco ' || to_char(rw_crapcob.cdbandoc) || ' nao tratado!';
      pr_dscritic := gene0001.fn_busca_critica(1316)|| rw_crapcob.cdbandoc; --Erro cdbandoc || rw_crapcob_id.cdbandoc || nao tratado

      RAISE vr_exc_erro;
      --
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_cancel_protesto');
    --
		END IF;
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic||vr_dsparame,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);
      -- Ajuste mensagem - 12/02/2019 - REQ0035813
      IF nvl(pr_cdcritic,0) IN ( 1197, 9999, 1034, 1035, 1036, 1037 ) THEN
        pr_cdcritic := 1224; -- Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      ELSIF nvl(pr_cdcritic,0) = 0 AND
            SUBSTR(pr_dscritic, 1, 7 ) IN ( '1197 - ', '9999 - ', '1034 - ', '1035 - ', '1036 - ', '1037 - ' ) THEN
        pr_cdcritic := 1224;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;            
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_cancel_protesto. '||sqlerrm||vr_dsparame;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

      pr_cdcritic := 1224; --complemento para INC0026760
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic); --complemento para INC0026760
  END pc_inst_cancel_protesto;

  -- Procedure para alterar a quantidade de dias para protesto
  PROCEDURE pc_inst_aut_protesto(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                ,pr_qtdiaprt  IN crapcob.qtdiaprt%TYPE --> Quantidade de dias para protesto
                                ,pr_dtvencto  IN crapcob.dtvencto%TYPE --> Data de vencimento
                                ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                ) IS
    -- ...........................................................................................
    --
    --  Programa : pc_inst_aut_protesto
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Supero
    --  Data     : Fevereiro/2018                     Ultima atualizacao: 24/08/201802/02/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para alterar a quantidade de dias para protesto
    --
    --   Alteracao : 24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Comentadas variáveis não utilizadas
    --                            Ajuste registro de logs com mensagens corretas
    --                            Em um momento não estava logando o retorno da cobr0006.pc_prep_retorno_cooper_90
    --                            Agora vai logar, mas sem parar a execução do programa
    --                            (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_cdcritic2  PLS_INTEGER;
    vr_dscritic2  VARCHAR2(4000);
    vr_des_erro   VARCHAR2(3);
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    -- Registro da Cooperativa
    rw_crapcop    COBR0007.cr_crapcop%ROWTYPE;
    -- Registro de Cobrança
    rw_crapcob    COBR0007.cr_crapcob%ROWTYPE;
    -- Variáveis comentadas por não serem utilizadas
/*
    -- Registro de Remessa
    rw_craprem     COBR0007.cr_craprem%ROWTYPE;
    -- Registro de controle retorno titulos bancarios
    rw_crapcre     COBR0007.cr_crapcre%ROWTYPE;
    -- Registro de cadastro de cobranca
    rw_crapcco     COBR0007.cr_crapcco%ROWTYPE;
    vr_qtdiaprt_old crapcob.qtdiaprt%TYPE;
    vr_nrremret     INTEGER;
    vr_nrseqreg     INTEGER;
    vr_rowid_ret    ROWID;
*/
    --Tabelas de Memoria de Remessa
    vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
    vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
    
    vr_index_lat    VARCHAR2(60);
    --
    vr_qtlimmip     crapceb.qtlimmip%TYPE;
    vr_qtlimaxp     crapceb.qtlimaxp%TYPE;
    vr_insrvprt     crapceb.insrvprt%TYPE;
    vr_flprotes     crapceb.flprotes%TYPE;
    --
  BEGIN
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_aut_protesto');
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                  ||', pr_nrdconta:'||pr_nrdconta
                  ||', pr_nrcnvcob:'||pr_nrcnvcob
                  ||', pr_nrdocmto:'||pr_nrdocmto
                  ||', pr_cdocorre:'||pr_cdocorre
                  ||', pr_dtmvtolt:'||pr_dtmvtolt
                  ||', pr_cdoperad:'||pr_cdoperad
                  ||', pr_qtdiaprt:'||pr_qtdiaprt
                  ||', pr_dtvencto:'||pr_dtvencto
                  ||', pr_nrremass:'||pr_nrremass;

    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;
    
    -- Processo de Validacao Recusas Padrao
    COBR0007.pc_efetua_val_recusa_padrao(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                        ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                        ,pr_nrcnvcob => pr_nrcnvcob   --> Numero Convenio
                                        ,pr_nrdocmto => pr_nrdocmto   --> Numero Documento
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Data Movimento
                                        ,pr_cdoperad => pr_cdoperad   --> Operador
                                        ,pr_cdinstru => '80'          --> Codigo Instrucao
                                        ,pr_nrremass => pr_nrremass   --> Numero da Remessa
                                        ,pr_rw_crapcob => rw_crapcob  --> Registro de Cobranca de Recusa
                                        ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                        ,pr_dscritic => vr_dscritic); --> Descricao da Critica
    
    --Se ocorrer Erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_aut_protesto');
    
    IF rw_crapcob.cdbandoc = 085 AND
       rw_crapcob.flgregis = 1   AND 
       rw_crapcob.flgcbdda = 1   AND 
       rw_crapcob.insitpro <= 2  THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XA' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Recusar a instrucao
      vr_cdcritic := 1180;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  --Titulo em processo de registro. Favor aguardar.
      RAISE vr_exc_erro;
    END IF;
    
     IF rw_crapcob.flgdprot = 1 AND rw_crapcob.qtdiaprt > 0 THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'A7' -- Titulo já possui instrucao
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_aut_protesto');

      -- Recusar a instrucao
      vr_cdcritic := 1365;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Titulo ja possui instrucao automatica de protesto - Instrucao nao efetuada!';
      RAISE vr_exc_erro;      
    END IF;

	IF rw_crapcob.cdbandoc = 085 AND
       rw_crapcob.cddespec = 2 /*DS*/ THEN
             
      tela_parprt.pc_validar_dsnegufds_parprt(pr_cdcooper => pr_cdcooper,
                                              pr_cdufsaca => rw_crapcob.cdufsaca,
                                              pr_des_erro => vr_des_erro,	
                                              pr_dscritic => vr_dscritic);
        
      IF (vr_des_erro <> 'OK') THEN
        --Espécie de título inválida para carteira
        vr_cdcritic := 05;
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -----  VALIDACOES PARA RECUSAR  -----
    IF rw_crapcob.incobran = 0  AND   -- 0 - Em Aberto
       rw_crapcob.insitcrt NOT IN (0, 4) THEN  -- Qualquer situação diferente de zero ou quatro
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XI' -- Motivo 
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_aut_protesto');

      -- Recusar a instrucao
      vr_cdcritic := 1366;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Titulo com movimentacao cartoraria - Inst. Auto. Protesto não efetuada!';
      RAISE vr_exc_erro;
    END IF;
    -- Verifica se a quantidade de dias está dentro do mínimo e máximo parametrizados na CRAPCEB
    vr_dscritic := NULL;
    --
    BEGIN
      --
      -- 1) consultar limite minimo e maximo de prazo de cancelamento do cooperado
			BEGIN
				--
				SELECT crapceb.qtlimmip
							,crapceb.qtlimaxp
							,crapceb.flprotes
							,crapcco.insrvprt
					INTO vr_qtlimmip
							,vr_qtlimaxp
							,vr_flprotes
							,vr_insrvprt
					FROM crapceb
							,crapcco
				 WHERE crapceb.cdcooper = crapcco.cdcooper
					 AND crapceb.nrconven = crapcco.nrconven
					 AND crapceb.cdcooper = pr_cdcooper
					 AND crapceb.nrdconta = pr_nrdconta
					 AND crapceb.nrconven = pr_nrcnvcob;
		  EXCEPTION
				WHEN no_data_found THEN
					NULL;
				WHEN OTHERS THEN
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

          vr_cdcritic := 1036;  --Erro ao buscar a parametrização dos dias min e max de limite para protesto
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapceb e crapcco'||
                        ' com cdcooper:'||pr_cdcooper||
                        ', nrdconta:'||pr_nrdconta||
                        ', nrconven:'||pr_nrcnvcob||
                        '. '||sqlerrm;
					RAISE vr_exc_erro;
			END;       
         
      -- 2) se o cooperado não possuir os limites, então consultar os limites da cooperativa
      IF vr_qtlimmip = 0 AND 
         vr_qtlimaxp = 0 THEN
         
         tela_parprt.pc_consulta_periodo_parprt(pr_cdcooper => pr_cdcooper
                                               ,pr_qtlimitemin_tolerancia => vr_qtlimmip
                                               ,pr_qtlimitemax_tolerancia => vr_qtlimaxp
                                               ,pr_des_erro => vr_des_erro
                                               ,pr_dscritic => vr_dscritic2);
                                               
         -- se a cooperativa não possuir os limites, então utilizar os limites
         -- já utilizados nos convênios de cobrança BB
         IF vr_qtlimmip = 0 AND
            vr_qtlimaxp = 0 THEN
            vr_qtlimmip := 5;
            vr_qtlimaxp := 15;
         END IF;
      END IF; 
      --
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        --Erro ao buscar a parametrização dos dias min e max de limite para protesto
        vr_cdcritic := 1291;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' '||sqlerrm;
    END;
    --
    IF vr_dscritic IS NULL THEN
      --
      IF pr_qtdiaprt < vr_qtlimmip OR
         pr_qtdiaprt > vr_qtlimaxp THEN
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'H3' -- Motivo -- revisar
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_aut_protesto');

        -- Recusar a instrucao
        vr_cdcritic := 1367;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                       ||' '||pr_qtdiaprt||' dias.'; --Quantidade de dias para protesto fora dos limites parametrizados - Alteracao nao efetuada
        RAISE vr_exc_erro;
        --
      END IF;
      --
    ELSE
      --
      RAISE vr_exc_erro;
      --
    END IF;

		-- Verificar se o prazo é válido
    IF (rw_crapcob.dtvencto + pr_qtdiaprt) <= pr_dtmvtolt THEN
			-- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'H4' -- Motivo -- revisar
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_aut_protesto');

        -- Recusar a instrucao
        vr_cdcritic := 1368;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                       ||(pr_dtmvtolt - (rw_crapcob.dtvencto + pr_qtdiaprt)); --Prazo de tolerancia invalido, minimo de ' || (pr_dtmvtolt - (rw_crapcob.dtvencto + pr_qtdiaprt)) || ' dias - Alteracao nao efetuada
        RAISE vr_exc_erro;
			--
		END IF;
    
    -- se o cooperado não estiver habilitado para protestar, criticar
    IF nvl(vr_flprotes,0) = 0 THEN
        
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'H6' -- Motivo -- revisar
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;      
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_aut_protesto');
        
      -- Recusar a instrucao
      vr_cdcritic := 1369;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Servico de protesto nao habilitado. Favor entrar em contato com seu PA.
      RAISE vr_exc_erro;       
        
    END IF;
  /*  
		-- Verificar se já possui serviço do SERASA
    IF rw_crapcob.flserasa = 1 OR rw_crapcob.qtdianeg > 0 OR rw_crapcob.inserasa > 0 THEN
  */
    -- alterado if para utilizar a função fn_flserasa 
    -- PRB0041685  Roberto Holz - Mout´s  20/05/2019
    -- Verificar se já possui serviço do SERASA
    IF COBR0007.fn_flserasa(rw_crapcob.flserasa,
														rw_crapcob.qtdianeg,
														rw_crapcob.inserasa,
														rw_crapcob.dtvencto,
														pr_dtmvtolt) THEN    
			-- Gerar o retorno para o cooperado 
			COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.rowid
																				,pr_cdocorre => 26   -- Instrucao Rejeitada
																				,pr_cdmotivo => '39' -- Motivo
																				,pr_vltarifa => 0    -- Valor da Tarifa  
																				,pr_cdbcoctl => rw_crapcop.cdbcoctl
																				,pr_cdagectl => rw_crapcop.cdagectl
																				,pr_dtmvtolt => pr_dtmvtolt
																				,pr_cdoperad => pr_cdoperad
																				,pr_nrremass => pr_nrremass
																				,pr_cdcritic => vr_cdcritic
																				,pr_dscritic => vr_dscritic
																				);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_aut_protesto');

        -- Recusar a instrucao
        vr_cdcritic := 1370;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Boleto com instrução de negativação
        RAISE vr_exc_erro;
			--
    END IF;
    
    ------ FIM - VALIDACOES PARA RECUSAR ------
    IF rw_crapcob.flgcbdda = 1 AND
       rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN
      -- Executa procedimentos do DDA-JD 
      DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob.rowid         --ROWID da Cobranca
                                       ,pr_tpoperad  => 'A'                      --Tipo Operacao
                                       ,pr_tpdbaixa  => ' '                      --Tipo de Baixa
                                       ,pr_dtvencto  => pr_dtvencto              --Data Vencimento
                                       ,pr_vldescto  => rw_crapcob.vldescto      --Valor Desconto
                                       ,pr_vlabatim  => rw_crapcob.vlabatim      --Valor Abatimento
                                       ,pr_flgdprot  => rw_crapcob.flgdprot      --Flag Protesto
                                       ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa
                                       ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela memoria retorno DDA
                                       ,pr_cdcritic  => vr_cdcritic2             --Codigo Critica
                                       ,pr_dscritic  => vr_dscritic2);           --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic2,0) <> 0 OR TRIM(vr_dscritic2) IS NOT NULL THEN
        -- Inclui nome do modulo logado - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_aut_protesto');
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XC' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

        --Aqui não logava o erro de retorno da cobr0006.pc_prep_retorno_cooper_90 e além disso, queimava 
        --as variáveis. Agora vai logar também erro da COBR0006, mas sem parar a execução
        -- Ch REQ0011728 daqui
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Se ocorreu erro
          pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                      pr_dstiplog      => 'E',
                      pr_dscritic      => vr_dscritic||vr_dsparame,
                      pr_cdcriticidade => 1,
                      pr_cdmensagem    => nvl(vr_cdcritic,0),
                      pr_ind_tipo_log  => 1);
        END IF;
        --Ch REQ0011728 até aqui
          
        vr_cdcritic := vr_cdcritic2;
        vr_dscritic := vr_dscritic2;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_aut_protesto');

    -- Altera quantidade de dias conforme parametro de tela passado
--nao é usado    vr_qtdiaprt_old     := rw_crapcob.qtdiaprt;
    rw_crapcob.qtdiaprt := pr_qtdiaprt;
    rw_crapcob.flgdprot := 1;
    rw_crapcob.insrvprt := vr_insrvprt;
    
    --Se tem remesssa dda na tabela
    IF vr_tab_remessa_dda.COUNT > 0 THEN
      rw_crapcob.idopeleg:= vr_tab_remessa_dda(vr_tab_remessa_dda.LAST).idopeleg;
    END IF;

    --Atualizar Cobranca
    BEGIN
      UPDATE crapcob SET crapcob.qtdiaprt = rw_crapcob.qtdiaprt,
                         crapcob.idopeleg = rw_crapcob.idopeleg,
                         crapcob.flgdprot = rw_crapcob.flgdprot,
                         crapcob.insrvprt = rw_crapcob.insrvprt
      WHERE crapcob.rowid = rw_crapcob.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        vr_cdcritic := 1035;  --Erro ao atualizar crapcob
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                       ' qtdiaprt:'||rw_crapcob.qtdiaprt||
                       ', idopeleg:'||rw_crapcob.idopeleg||
                       ', flgdprot:'||rw_crapcob.flgdprot||
                       ', insrvprt:'||rw_crapcob.insrvprt||
                       ' com rowid:'||rw_crapcob.rowid||
                       '. '||sqlerrm;
        RAISE vr_exc_erro;
    END;
    
    -- LOG de processo
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid  --ROWID da Cobranca
                                 ,pr_cdoperad => pr_cdoperad   --Operador
                                 ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                 ,pr_dsmensag => 'Inclusao de inst autom de Protesto: ' || to_char(pr_qtdiaprt) || ' dias'
                                 ,pr_des_erro => vr_des_erro   --Indicador erro
                                 ,pr_dscritic => vr_dscritic); --Descricao erro    
                                 
    IF rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN 
      -- Gerar o retorno para o cooperado 
      -- Confirmacao Recebimento Instrucao Alteracao de Vencimento
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 97 -- inst autom de protesto
                                         ,pr_cdmotivo => NULL -- Motivo 
                                         ,pr_vltarifa => 0 -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_aut_protesto');
    
    IF rw_crapcob.cdbandoc = 85 THEN
      --Montar Indice para lancamento tarifa
      vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                     lpad(pr_nrdconta,10,'0')||
                     lpad(pr_nrcnvcob,10,'0')||
                     lpad(19,10,'0')||
                     lpad('0',10,'0')||
                     lpad(pr_tab_lat_consolidada.Count+1,10,'0');
      -- Gerar registro Tarifa 
      pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
      pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
      pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
      pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
      pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
      pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 97; -- instr autom de protesto
      pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= NULL;  -- Motivo
      pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;
      --
    END IF;
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic||vr_dsparame;
      
      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_aut_protesto. '||sqlerrm||vr_dsparame;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);
    --
  END pc_inst_aut_protesto;

  -- Procedure para excluir Protesto com Carta de Anuência Eletrônica
  PROCEDURE pc_exc_prtst_anuencia_eletr(pr_cdcooper            IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                       ,pr_nrdconta            IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                       ,pr_nrcnvcob            IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                       ,pr_nrdocmto            IN crapcob.nrdocmto%TYPE --> Numero do documento
                                       ,pr_cdocorre            IN INTEGER               --> Codigo da Ocorrencia
                                       ,pr_dtmvtolt            IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                       ,pr_cdoperad            IN crapope.cdoperad%TYPE --> Codigo do Operador
                                       ,pr_nrremass            IN crapcob.nrremass%TYPE --> Numero da Remessa
                                       ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                       ,pr_cdcritic            OUT INTEGER              --> Codigo da Critica
                                       ,pr_dscritic            OUT VARCHAR2             --> Descricao da critica
                                       ) IS
    -- ...........................................................................................
    --
    --  Programa : pc_exc_prtst_anuencia_eletr
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Supero
    --  Data     : Fevereiro/2018                     Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para excluir Protesto com Carta de Anuência Eletrônica
    --
    --   Alteracao : 24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            Comentado cursor cr_craprem2 e variáveis não utilizados
    --                            (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_des_erro   VARCHAR2(3);
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);
    vr_dtmvtolt   DATE; -- data de envio para protesto    

    ------------------------------- CURSORES ---------------------------------    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    -- Registro da Cooperativa
    rw_crapcop    COBR0007.cr_crapcop%ROWTYPE;
    -- Registro de Cobrança
    rw_crapcob    COBR0007.cr_crapcob%ROWTYPE;
    -- Variáveis comentadas por não serem utilizadas
/*
    vr_cdcritic2  PLS_INTEGER;
    vr_dscritic2  VARCHAR2(4000);
    vr_is_serasa  BOOLEAN;
*/
    
    vr_nrremret     INTEGER;
    vr_nrseqreg     INTEGER;
    vr_rowid_ret    ROWID;
    vr_index_lat    VARCHAR2(60);
		
		vr_cdufsaca     crapsab.cdufsaca%TYPE;

    -- Identificar se o boleto possui Negativacao Serasa
    vr_idpercar     NUMBER;

  BEGIN
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_exc_prtst_anuencia_eletr');
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                  ||', pr_nrdconta:'||pr_nrdconta
                  ||', pr_nrcnvcob:'||pr_nrcnvcob
                  ||', pr_nrdocmto:'||pr_nrdocmto
                  ||', pr_cdocorre:'||pr_cdocorre
                  ||', pr_dtmvtolt:'||pr_dtmvtolt
                  ||', pr_cdoperad:'||pr_cdoperad
                  ||', pr_nrremass:'||pr_nrremass;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;

    -- Processo de Validacao Recusas Padrao
    COBR0007.pc_efetua_val_recusa_padrao(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                        ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                        ,pr_nrcnvcob => pr_nrcnvcob   --> Numero Convenio
                                        ,pr_nrdocmto => pr_nrdocmto   --> Numero Documento
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Data Movimento
                                        ,pr_cdoperad => pr_cdoperad   --> Operador
                                        ,pr_cdinstru => '81'          --> Codigo Instrucao
                                        ,pr_nrremass => pr_nrremass   --> Numero da Remessa
                                        ,pr_rw_crapcob => rw_crapcob  --> Registro de Cobranca de Recusa
                                        ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                        ,pr_dscritic => vr_dscritic); --> Descricao da Critica
    
    --Se ocorrer Erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_exc_prtst_anuencia_eletr');
    
    IF rw_crapcob.cdbandoc = 085 AND
       rw_crapcob.flgregis = 1   AND 
       rw_crapcob.flgcbdda = 1   AND 
       rw_crapcob.insitpro <= 2  THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XA' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_exc_prtst_anuencia_eletr');

      -- Recusar a instrucao
      vr_cdcritic := 1180;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  --Titulo em processo de registro. Favor aguardar.
      RAISE vr_exc_erro;
    END IF;

    -- Busca o estado do sacado
    BEGIN
      --
      SELECT crapsab.cdufsaca
        INTO vr_cdufsaca
        FROM crapcob
            ,crapsab
       WHERE crapcob.cdcooper = crapsab.cdcooper
         AND crapcob.nrdconta = crapsab.nrdconta
         AND crapcob.nrinssac = crapsab.nrinssac
         AND crapcob.cdcooper = rw_crapcob.cdcooper
         AND crapcob.nrdconta = rw_crapcob.nrdconta
         AND crapcob.nrdocmto = rw_crapcob.nrdocmto
         AND crapcob.nrcnvcob = rw_crapcob.nrcnvcob;
      --
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        vr_cdcritic := 1036;  --Erro ao buscar o estado do sacado
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcco e crapsab'||
                      ' com cdcooper:'||rw_crapcob.cdcooper||
                      ', nrdconta:'||rw_crapcob.nrdconta||
                      ', nrdocmto:'||rw_crapcob.nrdocmto||
                      ', nrconven:'||rw_crapcob.nrcnvcob||
                      '. '||sqlerrm;

        RAISE vr_exc_erro;
      --
    END;
    -- Verifica se o estado permite carta de anuência eletrônica
    BEGIN
      --
      SELECT NVL(INSTR(dsuf,vr_cdufsaca),0)
        INTO vr_idpercar
        FROM tbcobran_param_protesto tpp
       WHERE tpp.cdcooper = rw_crapcob.cdcooper;
      --
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        vr_cdcritic := 1036;  --Erro ao buscar a parametrizacao de UFs que permitem carta de anuencia eletronica
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'tbcobran_param_protesto'||
                      ' com cdcooper:'||rw_crapcob.cdcooper||
                      '. '||sqlerrm;
    END;

    -- Verifica se encontrou o estado na lista de estados com permissão de emissão de carta de anuência eletrônica
    IF vr_idpercar = 0 THEN
      -- Preparar Lote de Retorno Cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                         ,pr_cdocorre => 26   -- Codigo Ocorrencia
                                         ,pr_cdmotivo => '40' -- Motivo
                                         ,pr_vltarifa => 0    -- valor da Tarifa
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                         ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                         ,pr_nrremass => pr_nrremass --Numero Remessa
                                         ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                         ,pr_dscritic => vr_dscritic); --Descricao Critica
      --Se Ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_exc_prtst_anuencia_eletr');

      vr_cdcritic := 1371;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --UF nao permite carta de anuencia eletronica - Cancelamento Protesto nao efetuado
      --Retornar
      RAISE vr_exc_erro;
      --
    END IF;
      
    -- Verifica se já existe exclusao de protesto emitida para o boleto
    vr_idpercar := 0;
    --
    BEGIN
      --
      SELECT COUNT(1)
        INTO vr_idpercar
        FROM crapret
       WHERE crapret.cdcooper = rw_crapcob.cdcooper
         AND crapret.nrcnvcob = rw_crapcob.nrcnvcob
         AND crapret.nrdconta = rw_crapcob.nrdconta
         AND crapret.nrdocmto = rw_crapcob.nrdocmto
         AND crapret.cdocorre = 98 -- exclusão de protesto
         AND crapret.cdmotivo = 'F1'; -- exclusão enviada ao cartório
      --
    EXCEPTION
      WHEN no_data_found THEN
        vr_idpercar := 0;
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        vr_cdcritic := 1036;  --Erro ao verificar se ja existe carta de anuencia eletronica emitida para o boleto
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'tbcobran_param_protesto '||
                      ' com cdcooper:'||rw_crapcob.cdcooper||
                      ', nrcnvcob:'||rw_crapcob.nrcnvcob||
                      ', nrdconta:'||rw_crapcob.nrdconta||
                      ', nrdocmto:'||rw_crapcob.nrdocmto||
                      ', cdocorre:98'||
                      ', cdmotivo:F1'||
                      '. '||sqlerrm;
    END;
    -- Verifica se encontrou lançamento de carta de anuência eletrônica
    IF vr_idpercar > 0 THEN
      -- Preparar Lote de Retorno Cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid --ROWID da cobranca
                                         ,pr_cdocorre => 26   -- Codigo Ocorrencia
                                         ,pr_cdmotivo => '40' -- Motivo
                                         ,pr_vltarifa => 0    -- valor da Tarifa
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                         ,pr_cdoperad => pr_cdoperad --Codigo Operador
                                         ,pr_nrremass => pr_nrremass --Numero Remessa
                                         ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                         ,pr_dscritic => vr_dscritic); --Descricao Critica
      --Se Ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_exc_prtst_anuencia_eletr');

      vr_cdcritic := 1372;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Carta de anuencia eletronica ja emitida - Exclusao de Protesto nao efetuado
      --Retornar
      RAISE vr_exc_erro;
      --
    END IF;
    
    -- Atualizar a situação do protesto
    rw_crapcob.insitcrt := 6; -- Protesto Anulado com Carta de Anuencia

    --Atualizar Cobranca
    BEGIN
      UPDATE crapcob SET crapcob.insitcrt = rw_crapcob.insitcrt
                        ,crapcob.dtsitcrt = pr_dtmvtolt
      WHERE crapcob.rowid = rw_crapcob.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => 0);

        vr_cdcritic := 1035;  --Erro ao atualizar cobranca
        vr_dscritic := gene0001.fn_busca_critica(1035)||'crapcob:'||
                            ' insitcrt: 6'||
                            ' com rowid:'||rw_crapcob.rowid||
                            '. '||sqlerrm;
        RAISE vr_exc_erro;
    END;
    
    
    -- LOG de processo
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid  --ROWID da Cobranca
                                 ,pr_cdoperad => pr_cdoperad   --Operador
                                 ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                 ,pr_dsmensag => 'Solicitacao de Exclusao de Protesto' -- Descricao Mensagem
                                 ,pr_des_erro => vr_des_erro   --Indicador erro
                                 ,pr_dscritic => vr_dscritic); --Descricao erro

    -- utilizar a data do movimento específica para protesto          
    vr_dtmvtolt := cobr0011.fn_busca_dtmvtolt(pr_cdcooper => pr_cdcooper);          

    -- Registra Instrucao Alter Dados / Protesto
    -- gerar pedido de remessa
    PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                   ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                   ,pr_dtmvtolt => vr_dtmvtolt         --Data movimento
                                   ,pr_cdoperad => pr_cdoperad         --Codigo Operador
								                   ,pr_idregcob => '0'
                                   ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                   ,pr_rowid_ret => vr_rowid_ret       --ROWID Remessa Retorno
                                   ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                   ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se ocorreu erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_exc_prtst_anuencia_eletr');

    --Incrementar Sequencial
    vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;
    --Criar tabela Remessa
    -- 81. Exclsuao de protesto com carta de anuencia eletronica
    PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                 ,pr_nrremret => vr_nrremret          --Numero Remessa
                                 ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                 ,pr_cdocorre => 81                   --Codigo Ocorrencia
                                 ,pr_cdmotivo => NULL                 --Codigo Motivo
                                 ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                 ,pr_vlabatim => 0                    --Valor Abatimento
                                 ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                 ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                 ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                 ,pr_dscritic => vr_dscritic);        --Descricao Critica
    --Se ocorreu erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_exc_prtst_anuencia_eletr');

    -- Gerar o retorno para o cooperado 
    -- 98 - exclusao de protesto com carta de anuencia eletronica
    COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                       ,pr_cdocorre => 98   -- Instrucao Rejeitada
                                       ,pr_cdmotivo => 'F1'
                                       ,pr_vltarifa => 0    -- Valor da Tarifa  
                                       ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                       ,pr_cdagectl => rw_crapcop.cdagectl
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nrremass => pr_nrremass
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
    -- Verifica se ocorreu erro durante a execucao
    IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_exc_prtst_anuencia_eletr');
    
    --Montar Indice para lancamento tarifa
    vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                   lpad(pr_nrdconta,10,'0')||
                   lpad(pr_nrcnvcob,10,'0')||
                   lpad(19,10,'0')||
                   lpad('0',10,'0')||
                   lpad(pr_tab_lat_consolidada.Count+1,10,'0');
    -- Gerar registro Tarifa 
    pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
    pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
    pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
    pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
    pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
    pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 98;    -- 94 - Confirmacao de Cancelamento Negativacao Serasa
    pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= 'F1';  -- Motivo
    pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;    
        
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic||vr_dsparame,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);

      -- Complemento para INC0026760
      -- Se chegar erro não tratado de outras chamadas desta procedure joga para 1124
      IF pr_cdcritic = 9999 THEN
        pr_cdcritic := 1224; -- Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;            
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_exc_prtst_anuencia_eletr. '||sqlerrm||vr_dsparame;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

      pr_cdcritic := 1224; --complemento para INC0026760
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic); --complemento para INC0026760
  END pc_exc_prtst_anuencia_eletr;

  -- Procedure para Alterar tipo de emissao CEE
  PROCEDURE pc_inst_alt_tipo_emissao_cee (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                         ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                         ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                         ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                         ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                         ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                         ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                         ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                         ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                         ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_alt_tipo_emissao_cee     Antigo: b1wgen0088.p/inst-alt-tipo-emissao-cee
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Douglas Quisinski
    --  Data     : Janeiro/2016                     Ultima atualizacao: 24/08/201825/01/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Alterar tipo de emissao CEE
    --
    --   Alteracao : 25/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_des_erro   VARCHAR2(3);
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    
    -- selecionar cadastro de emissao de bloquetos
    CURSOR cr_crapceb (pr_cdcooper IN crapceb.cdcooper%TYPE,
                       pr_nrdconta IN crapceb.nrdconta%TYPE,
                       pr_nrconven IN crapceb.nrconven%TYPE) IS
      SELECT ceb.flceeexp
        FROM crapceb ceb
       WHERE ceb.cdcooper = pr_cdcooper 
         AND ceb.nrdconta = pr_nrdconta 
         AND ceb.nrconven = pr_nrconven;
    rw_crapceb cr_crapceb%ROWTYPE;
    ---------------------------- ESTRUTURAS DE REGISTRO ----------------------
    
    ------------------------------- VARIAVEIS --------------------------------
    -- Registro da Cooperativa
    rw_crapcop    COBR0007.cr_crapcop%ROWTYPE;
    -- Registro de Cobrança
    rw_crapcob    COBR0007.cr_crapcob%ROWTYPE;
    -- Registro de Remessa
    rw_craprem    COBR0007.cr_craprem%ROWTYPE;
    -- Registro de controle retorno titulos bancarios
    rw_crapcre    COBR0007.cr_crapcre%ROWTYPE;

    vr_index_lat    VARCHAR2(60);

  BEGIN
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_tipo_emissao_cee');
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                  ||', pr_nrdconta:'||pr_nrdconta
                  ||', pr_nrcnvcob:'||pr_nrcnvcob
                  ||', pr_nrdocmto:'||pr_nrdocmto
                  ||', pr_cdocorre:'||pr_cdocorre
                  ||', pr_dtmvtolt:'||pr_dtmvtolt
                  ||', pr_cdoperad:'||pr_cdoperad
                  ||', pr_nrremass:'||pr_nrremass;

    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;

    -- Processo de Validacao Recusas Padrao
    -- 90 - Alterar tipo de emissao CEE
    COBR0007.pc_efetua_val_recusa_padrao(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                        ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                        ,pr_nrcnvcob => pr_nrcnvcob   --> Numero Convenio
                                        ,pr_nrdocmto => pr_nrdocmto   --> Numero Documento
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Data Movimento
                                        ,pr_cdoperad => pr_cdoperad   --> Operador
                                        ,pr_cdinstru => '90'          --> Codigo Instrucao
                                        ,pr_nrremass => pr_nrremass   --> Numero da Remessa
                                        ,pr_rw_crapcob => rw_crapcob  --> Registro de Cobranca de Recusa
                                        ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                        ,pr_dscritic => vr_dscritic); --> Descricao da Critica
    --Se ocorrer Erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_tipo_emissao_cee');
    
    IF rw_crapcob.cdbandoc = 1  THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XT' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_tipo_emissao_cee');

      -- Recusar a instrucao
      vr_cdcritic := 1373;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Nao permitido alterar tipo de emissao de boletos do Banco do Brasil. Instrucao nao realizada
      RAISE vr_exc_erro;
    END IF;

    -- Verificar se boleto já está na situaçao pretendida
    IF rw_crapcob.inemiten = 3  THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'A7' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_tipo_emissao_cee');

      -- Recusar a instrucao
      vr_cdcritic := 1374;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Boleto ja é Cooperativa - Emite e Expede – Alteracao nao efetuada
      RAISE vr_exc_erro;
    END IF;

    -- verificar se o cooperado possui modalidade Cooperativa/EE habilitada
    OPEN cr_crapceb (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrconven => pr_nrcnvcob);
    FETCH cr_crapceb INTO rw_crapceb;
    IF  cr_crapceb%FOUND AND rw_crapceb.flceeexp = 0 THEN 
      -- Fecha cursor
      CLOSE cr_crapceb;
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XU' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_tipo_emissao_cee');

      -- Recusar a instrucao
      vr_cdcritic := 1375;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Cooperado nao possui modalidade de emissao Cooperativa/EE habilitada – Alteracao nao efetuada
      RAISE vr_exc_erro;
    END IF;
    IF cr_crapceb%ISOPEN THEN
      -- Fecha cursor
      CLOSE cr_crapceb;
    END IF;

    IF rw_crapcob.cdbandoc = 085 AND
       rw_crapcob.flgregis = 1   AND 
       rw_crapcob.flgcbdda = 1   AND 
       rw_crapcob.insitpro <= 2  THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XA' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_tipo_emissao_cee');

      -- Recusar a instrucao
      vr_cdcritic := 1180;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  --Titulo em processo de registro. Favor aguardar.
      RAISE vr_exc_erro;
    END IF;

    -----  VALIDACOES PARA RECUSAR  -----
    -- Verifica se ja existe alt de tipo de emissao
    OPEN cr_crapcre (pr_cdcooper => pr_cdcooper
                    ,pr_nrcnvcob => pr_nrcnvcob
                    ,pr_dtmvtolt => pr_dtmvtolt
                    ,pr_intipmvt => 1);
    --Proximo registro
    FETCH cr_crapcre INTO rw_crapcre;
    --Se Encontrou
    IF cr_crapcre%FOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcre;
      --Selecionar remessa
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_cdocorre => 90
                      ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craprem;
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XR' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_tipo_emissao_cee');
        
        -- Recusar a instrucao
        vr_cdcritic := 1376;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Alteracao de tipo de emissao ja efetuado - Instrucao nao efetuada
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_craprem%ISOPEN THEN
        CLOSE cr_craprem;
      END IF;
    END IF;
    --Fechar Cursor
    IF cr_crapcre%ISOPEN THEN
      CLOSE cr_crapcre;
    END IF;
    ------ FIM - VALIDACOES PARA RECUSAR ------

    IF rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN 
      rw_crapcob.inemiten := 3;
      rw_crapcob.inemiexp := 1; -- Pendente de Envio 

      --Atualizar Cobranca
      BEGIN
        UPDATE crapcob SET crapcob.inemiten = rw_crapcob.inemiten,
                           crapcob.inemiexp = rw_crapcob.inemiexp
        WHERE crapcob.rowid = rw_crapcob.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

          vr_cdcritic := 1035;  --Erro ao atualizar crapcob
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                         ' inemiten:'||rw_crapcob.inemiten||
                         ', inemiexp:'||rw_crapcob.inemiexp||
                         ' com rowid:'||rw_crapcob.rowid||
                         '. '||sqlerrm;
          RAISE vr_exc_erro;
      END;

      -- Alteracao Emissao CCE
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 90   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => NULL -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_tipo_emissao_cee');

    ---- LOG de Processo ----
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                 ,pr_cdoperad => pr_cdoperad      --Operador
                                 ,pr_dtmvtolt => pr_dtmvtolt      --Data movimento
                                 ,pr_dsmensag => 'Inst Alt de Emissao CEE' --Descricao Mensagem
                                 ,pr_des_erro => vr_des_erro      --Indicador erro
                                 ,pr_dscritic => vr_dscritic);    --Descricao erro
    --Se ocorreu erro
    IF vr_des_erro = 'NOK' THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_tipo_emissao_cee');

    ---- LOG de Processo ----
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                 ,pr_cdoperad => pr_cdoperad      --Operador
                                 ,pr_dtmvtolt => pr_dtmvtolt      --Data movimento
                                 ,pr_dsmensag => 'Titulo a enviar a PG' --Descricao Mensagem
                                 ,pr_des_erro => vr_des_erro      --Indicador erro
                                 ,pr_dscritic => vr_dscritic);    --Descricao erro
    --Se ocorreu erro
    IF vr_des_erro = 'NOK' THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_tipo_emissao_cee');

    IF rw_crapcob.cdbandoc = 85 THEN
      --Montar Indice para lancamento tarifa
      vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                     lpad(pr_nrdconta,10,'0')||
                     lpad(pr_nrcnvcob,10,'0')||
                     lpad(19,10,'0')||
                     lpad('0',10,'0')||
                     lpad(pr_tab_lat_consolidada.Count+1,10,'0');
      -- Gerar registro Tarifa 
      pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
      pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
      pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
      pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
      pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
      pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 90;    -- 90 - Inst Alt emissao CEE
      pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= NULL;  -- Motivo
      pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic||vr_dsparame,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);

      -- Complemento para INC0026760
      -- Se chegar erro não tratado de outras chamadas desta procedure joga para 1124
      IF pr_cdcritic = 9999 THEN
        pr_cdcritic := 1224; -- Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;            
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_alt_tipo_emissao_cee. '||sqlerrm||vr_dsparame;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

      pr_cdcritic := 1224; --complemento para INC0026760
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic); --complemento para INC0026760
  END pc_inst_alt_tipo_emissao_cee;

  -- Procedure para Alterar Dados do Sacado - Especifico para Arquivo Remessa 085
  PROCEDURE pc_inst_alt_dados_arq_rem_085 (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                          ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                          ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                                          ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                                          ,pr_cdocorre  IN INTEGER               --> Codigo da Ocorrencia
                                          -- Dados do Sacado
                                          ,pr_nrinssac  IN crapsab.nrinssac%TYPE --> Inscricao do Sacado
                                          ,pr_dsendsac  IN crapsab.dsendsac%TYPE --> Endereco do Sacado
                                          ,pr_nmbaisac  IN crapsab.nmbaisac%TYPE --> Bairro do Sacado
                                          ,pr_nrcepsac  IN crapsab.nrcepsac%TYPE --> CEP do Sacado
                                          ,pr_nmcidsac  IN crapsab.nmcidsac%TYPE --> Cidade do Sacado
                                          ,pr_cdufsaca  IN crapsab.cdufsaca%TYPE --> UF do Sacado
                                          -- Outros dados
                                          ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                                          ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                          ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                                          ,pr_tab_lat_consolidada IN OUT PAGA0001.typ_tab_lat_consolidada
                                          ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                                          ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_alt_dados_arq_rem_085    Antigo: b1wgen0088.p/inst-alt-outros-dados-arq-rem-085
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Douglas Quisinski
    --  Data     : Janeiro/2016                     Ultima atualizacao: 24/08/201823/06/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Alterar Dados do Sacado - Especifico para Arquivo Remessa 085
    --
    --   Alteracao : 25/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --
    --               23/06/2017 - Alterado para fechar o cursor cr_crapcre ao inves do cr_crapcco
    --                            pois ocasionava erro no programa porque fechava um cursor que nao
    --                            estava aberto no momento (Tiago/Rodrigo #698180)
    --
    --               24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            Em um momento não estava logando o retorno da cobr0006.pc_prep_retorno_cooper_90
    --                            Agora vai logar, mas sem parar a execução do programa
    --                            (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_cdcritic2  PLS_INTEGER;
    vr_dscritic2  VARCHAR2(4000);
    vr_des_erro   VARCHAR2(3);
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------
    CURSOR cr_crapsab (pr_cdcooper IN crapsab.cdcooper%TYPE,
                       pr_nrdconta IN crapsab.nrdconta%TYPE,
                       pr_nrinssac IN crapsab.nrinssac%TYPE) IS
      SELECT sab.rowid
            ,sab.dsendsac
            ,sab.nrendsac
            ,sab.nmbaisac
            ,sab.nrcepsac
            ,sab.nmcidsac
            ,sab.cdufsaca
        FROM crapsab sab
       WHERE sab.cdcooper = pr_cdcooper
         AND sab.nrdconta = pr_nrdconta
         AND sab.nrinssac = pr_nrinssac;
    rw_crapsab cr_crapsab%ROWTYPE;

    ---------------------------- ESTRUTURAS DE REGISTRO ----------------------
    
    ------------------------------- VARIAVEIS --------------------------------
    -- Registro da Cooperativa
    rw_crapcop    COBR0007.cr_crapcop%ROWTYPE;
    -- Registro de Cobrança
    rw_crapcob    COBR0007.cr_crapcob%ROWTYPE;
    -- Registro de Remessa
    rw_craprem    COBR0007.cr_craprem%ROWTYPE;
    -- Registro de controle retorno titulos bancarios
    rw_crapcre    COBR0007.cr_crapcre%ROWTYPE;
    -- Registro de parametros Cobranca
    rw_crapcco    COBR0007.cr_crapcco%ROWTYPE;

    --Tabelas de Memoria de Remessa
    vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
    vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
    
    vr_nrendsac     crapsab.nrendsac%TYPE;
    vr_nrremret     INTEGER;
    vr_nrseqreg     INTEGER;
    vr_rowid_ret    ROWID;
    vr_index_lat    VARCHAR2(60);

  BEGIN
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_dados_arq_rem_085');

    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                  ||', pr_nrdconta:'||pr_nrdconta
                  ||', pr_nrcnvcob:'||pr_nrcnvcob
                  ||', pr_nrdocmto:'||pr_nrdocmto
                  ||', pr_cdocorre:'||pr_cdocorre
                  ||', pr_nrinssac:'||pr_nrinssac
                  ||', pr_dsendsac:'||pr_dsendsac
                  ||', pr_nmbaisac:'||pr_nmbaisac
                  ||', pr_nrcepsac:'||pr_nrcepsac
                  ||', pr_nmcidsac:'||pr_nmcidsac
                  ||', pr_cdufsaca:'||pr_cdufsaca
                  ||', pr_dtmvtolt:'||pr_dtmvtolt
                  ||', pr_cdoperad:'||pr_cdoperad
                  ||', pr_nrremass:'||pr_nrremass;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;

    --Selecionar cadastro convenio
    OPEN cr_crapcco (pr_cdcooper => pr_cdcooper
                    ,pr_nrconven => pr_nrcnvcob);
    --Proximo registro
    FETCH cr_crapcco INTO rw_crapcco;
    IF cr_crapcco%NOTFOUND THEN
      -- Fechar cursor
      CLOSE cr_crapcco;
      vr_cdcritic := 1179; 
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Registro de cobranca nao encontrado
      --Levantar Excecao
      RAISE vr_exc_erro;
    ELSE
      -- Fechar cursor
      CLOSE cr_crapcco;
    END IF;

    -- Buscar informacoes da cobranca
    OPEN cr_crapcob(pr_cdcooper => pr_cdcooper
                   ,pr_cdbandoc => rw_crapcco.cddbanco
                   ,pr_nrdctabb => rw_crapcco.nrdctabb
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrcnvcob => pr_nrcnvcob
                   ,pr_nrdocmto => pr_nrdocmto);
    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    --Se encontrar
    IF cr_crapcob%NOTFOUND THEN
      -- Fecha cursor 
      CLOSE cr_crapcob;
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XQ' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_dados_arq_rem_085');

      -- Recusar a instrucao
      vr_cdcritic := 1179; 
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Registro de cobranca nao encontrado
      RAISE vr_exc_erro;
    ELSE
      -- Fechar cursor
      CLOSE cr_crapcob;
    END IF;
    
    IF rw_crapcob.cdbandoc = 085 AND
       rw_crapcob.flgregis = 1   AND 
       rw_crapcob.flgcbdda = 1   AND 
       rw_crapcob.insitpro <= 2  THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XA' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_dados_arq_rem_085');

      -- Recusar a instrucao
      vr_cdcritic := 1180; 
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  --Titulo em processo de registro. Favor aguardar.
      RAISE vr_exc_erro;
    END IF;

    -----  VALIDACOES PARA RECUSAR  -----
    IF rw_crapcob.incobran = 3 THEN 
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XP' -- Motivo 
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_dados_arq_rem_085');

      -- Recusar a instrucao
      IF rw_crapcob.insitcrt <> 5 THEN
        vr_cdcritic := 1377; 
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  --Boleto Baixado - Alteracao nao efetuada
      ELSE
        vr_cdcritic := 1378; 
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  --Boleto Protestado - Alteracao nao efetuada
      END IF;
      RAISE vr_exc_erro;
    ELSIF rw_crapcob.incobran = 5 THEN 
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'A5' -- Motivo 
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_dados_arq_rem_085');

      -- Recusar a instrucao
      vr_cdcritic := 1379; 
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  --Boleto Liquidado - Alteracao nao efetuada
      RAISE vr_exc_erro;
    END IF;
    
    -- Verificar o indicador da situacao cartoraria
    IF rw_crapcob.insitcrt = 1 THEN
      -- 1 = C/Inst Protesto
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XE' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_dados_arq_rem_085');
      
      -- Recusar a instrucao
      vr_cdcritic := 1380; 
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  --Boleto com Remessa a Cartorio - Alteracao nao efetuada
      RAISE vr_exc_erro;
    ELSIF rw_crapcob.insitcrt = 3 THEN
      -- 3 = Em Cartorio
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XF' -- Motivo
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_dados_arq_rem_085');
      
      -- Recusar a instrucao
      vr_cdcritic := 1381; 
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  --Boleto Em Cartorio - Alteracao nao efetuada
      RAISE vr_exc_erro;
    END IF;
    
    -- Verifica se ja existe Pedido de Baixa 
    OPEN cr_crapcre (pr_cdcooper => pr_cdcooper
                    ,pr_nrcnvcob => pr_nrcnvcob
                    ,pr_dtmvtolt => pr_dtmvtolt
                    ,pr_intipmvt => 1);
    --Proximo registro
    FETCH cr_crapcre INTO rw_crapcre;
    --Se Encontrou
    IF cr_crapcre%FOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcre;
      --Selecionar remessa
      OPEN cr_craprem (pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrdocmto => rw_crapcob.nrdocmto
                      ,pr_cdocorre => 31
                      ,pr_dtaltera => pr_dtmvtolt);
      FETCH cr_craprem INTO rw_craprem;
      --Se Encontrou
      IF cr_craprem%FOUND THEN
        -- Fechar cursor
        CLOSE cr_craprem;
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XR' -- Motivo 
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_dados_arq_rem_085');

        -- Recusar a instrucao
        vr_cdcritic := 1382; 
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  --Alteracao ja efetuada
        RAISE vr_exc_erro;
      ELSE 
        --Fechar Cursor
        CLOSE cr_craprem;
      END IF;
    ELSE 
      -- Fechar cursor
      CLOSE cr_crapcre;
    END IF;
    ------ FIM - VALIDACOES PARA RECUSAR ------

    IF rw_crapcob.flgcbdda = 1 AND
       rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN
      -- Executa procedimentos do DDA-JD 
      DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob.rowid         --ROWID da Cobranca
                                       ,pr_tpoperad  => 'A'                      --Tipo Operacao
                                       ,pr_tpdbaixa  => ' '                      --Tipo de Baixa
                                       ,pr_dtvencto  => rw_crapcob.dtvencto      --Data Vencimento
                                       ,pr_vldescto  => rw_crapcob.vldescto      --Valor Desconto
                                       ,pr_vlabatim  => rw_crapcob.vlabatim      --Valor Abatimento
                                       ,pr_flgdprot  => rw_crapcob.flgdprot      --Flag Protesto
                                       ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa
                                       ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela memoria retorno DDA
                                       ,pr_cdcritic  => vr_cdcritic2             --Codigo Critica
                                       ,pr_dscritic  => vr_dscritic2);           --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic2,0) <> 0 OR TRIM(vr_dscritic2) IS NOT NULL THEN
        -- Inclui nome do modulo logado - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_dados_arq_rem_085');
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                           ,pr_cdmotivo => 'XC' -- Motivo
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

        --Aqui não logava o erro de retorno da cobr0006.pc_prep_retorno_cooper_90 e além disso, queimava 
        --as variáveis. Agora vai logar também erro da COBR0006, mas sem parar a execução
        -- Ch REQ0011728 daqui
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Se ocorreu erro
          pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                      pr_dstiplog      => 'E',
                      pr_dscritic      => vr_dscritic||vr_dsparame,
                      pr_cdcriticidade => 1,
                      pr_cdmensagem    => nvl(vr_cdcritic,0),
                      pr_ind_tipo_log  => 1);
        END IF;
        --Ch REQ0011728 até aqui

        vr_cdcritic := vr_cdcritic2;
        vr_dscritic := vr_dscritic2;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_dados_arq_rem_085');

    -- Buscar as informacoes do sacado
    OPEN cr_crapsab (pr_cdcooper => pr_cdcooper 
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrinssac => pr_nrinssac);
    FETCH cr_crapsab INTO rw_crapsab;
    -- Verifica se Sacado possui registro
    IF cr_crapsab%NOTFOUND THEN
      -- Fecha o crusos
      CLOSE cr_crapsab;
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 26   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'XS' -- Motivo 
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_dados_arq_rem_085');

      -- Recusar a instrucao
      vr_cdcritic := 1383; 
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  --Solicitacao de alteracao de dados nao efetuada. Pagador nao encontrado
      RAISE vr_exc_erro;
    ELSE 
      -- Fecha o crusos
      CLOSE cr_crapsab;
    END IF;

    IF rw_crapsab.dsendsac <> pr_dsendsac THEN
      vr_nrendsac := 0;
    ELSE 
      vr_nrendsac := rw_crapsab.nrendsac;
    END IF;

    --Atualizar Sacado
    BEGIN
      UPDATE crapsab SET crapsab.dsendsac = pr_dsendsac,
                         crapsab.nrendsac = vr_nrendsac,
                         crapsab.nmbaisac = pr_nmbaisac,
                         crapsab.nrcepsac = pr_nrcepsac,
                         crapsab.nmcidsac = pr_nmcidsac,
                         crapsab.cdufsaca = pr_cdufsaca
      WHERE crapsab.rowid = rw_crapsab.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        vr_cdcritic := 1035;  --Erro ao atualizar crapsab
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapsab:'||
                       ' dsendsac:'||pr_dsendsac||
                       ', nrendsac:'||vr_nrendsac||
                       ', nmbaisac:'||pr_nmbaisac||
                       ', nrcepsac:'||pr_nrcepsac||
                       ', nmcidsac:'||pr_nmcidsac||
                       ', cdufsaca:'||pr_cdufsaca||
                       ' com rowid:'||rw_crapsab.rowid||
                       '. '||sqlerrm;
        RAISE vr_exc_erro;
    END;
    --Se tem remesssa dda na tabela
    IF vr_tab_remessa_dda.COUNT > 0 THEN
      rw_crapcob.idopeleg:= vr_tab_remessa_dda(vr_tab_remessa_dda.LAST).idopeleg;

      --Atualizar Cobranca
      BEGIN
        UPDATE crapcob SET crapcob.idopeleg = rw_crapcob.idopeleg
        WHERE crapcob.rowid = rw_crapcob.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

          vr_cdcritic := 1035;  --Erro ao atualizar crapcob
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapsab:'||
                         ' idopeleg:'||rw_crapcob.idopeleg||
                         ' com rowid:'||rw_crapcob.rowid||
                         '. '||sqlerrm;
          RAISE vr_exc_erro;
      END;
    END IF;

    IF rw_crapcob.cdbandoc = 1 THEN
      -- gerar pedido de remessa
      PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                     ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                     ,pr_dtmvtolt => pr_dtmvtolt         --Data movimento
                                     ,pr_cdoperad => pr_cdoperad         --Codigo Operador
																		 ,pr_idregcob => rw_crapcob.rowid
                                     ,pr_nrremret => vr_nrremret         --Numero Remessa Retorno
                                     ,pr_rowid_ret => vr_rowid_ret       --ROWID Remessa Retorno
                                     ,pr_nrseqreg => vr_nrseqreg         --Numero Sequencial
                                     ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                     ,pr_dscritic => vr_dscritic);       --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_dados_arq_rem_085');

      --Incrementar Sequencial
      vr_nrseqreg:= nvl(vr_nrseqreg,0) + 1;
      -- Criar tabela Remessa
      -- Alteracao Vencimento
      PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw_crapcob.rowid     --ROWID da cobranca
                                   ,pr_nrremret => vr_nrremret          --Numero Remessa
                                   ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                                   ,pr_cdocorre => pr_cdocorre          --Codigo Ocorrencia
                                   ,pr_cdmotivo => NULL                 --Codigo Motivo
                                   ,pr_dtdprorr => NULL                 --Data Prorrogacao
                                   ,pr_vlabatim => 0                    --Valor Abatimento
                                   ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt          --Data Movimento
                                   ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);        --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_dados_arq_rem_085');
      
    ELSE 
      
      IF rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl  THEN 
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                           ,pr_cdocorre => 27   -- Conf. Alteracao de Outros Dados
                                           ,pr_cdmotivo => NULL -- Motivo 
                                           ,pr_vltarifa => 0    -- Valor da Tarifa  
                                           ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                           ,pr_cdagectl => rw_crapcop.cdagectl
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrremass => pr_nrremass
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_dados_arq_rem_085');
      END IF;
    END IF;
    
    ---- LOG de Processo ----
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                 ,pr_cdoperad => pr_cdoperad      --Operador
                                 ,pr_dtmvtolt => pr_dtmvtolt      --Data movimento
                                 ,pr_dsmensag => 'Alteracao de dados do Pagador' --Descricao Mensagem
                                 ,pr_des_erro => vr_des_erro      --Indicador erro
                                 ,pr_dscritic => vr_dscritic);    --Descricao erro
    --Se ocorreu erro
    IF vr_des_erro = 'NOK' THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_alt_dados_arq_rem_085');
    
    IF rw_crapcob.cdbandoc = 85 THEN
      --Montar Indice para lancamento tarifa
      vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                     lpad(pr_nrdconta,10,'0')||
                     lpad(pr_nrcnvcob,10,'0')||
                     lpad(19,10,'0')||
                     lpad('0',10,'0')||
                     lpad(pr_tab_lat_consolidada.Count+1,10,'0');
      -- Gerar registro Tarifa 
      pr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
      pr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
      pr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
      pr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
      pr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
      pr_tab_lat_consolidada(vr_index_lat).cdocorre:= 27;    -- 27 - Conf. Alt. Outros Dados
      pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= NULL;  -- Motivo
      pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic||vr_dsparame,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);

      -- Complemento para INC0026760
      -- Se chegar erro não tratado de outras chamadas desta procedure joga para 1124
      IF pr_cdcritic = 9999 THEN
        pr_cdcritic := 1224; -- Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;            
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_alt_dados_arq_rem_085. '||sqlerrm||vr_dsparame;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

      pr_cdcritic := 1224; --complemento para INC0026760
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic); --complemento para INC0026760
  END pc_inst_alt_dados_arq_rem_085;


  -- Procedure para Cancelar o envio de SMS
  PROCEDURE pc_inst_canc_sms (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                             ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                             ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                             ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                             ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                             ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                             ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                             ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                             ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_canc_sms          Antigo: 
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Andrino Carlos de Souza Junior
    --  Data     : Setembro/2016                     Ultima atualizacao: 24/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para cancelar envio de SMS
    --
    --   Alteracao : 24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    
    CURSOR cr_sms IS
      SELECT 1
        FROM tbcobran_sms
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrcnvcob = pr_nrcnvcob
         AND nrdocmto = pr_nrdocmto;
     rw_sms cr_sms%ROWTYPE;
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    -- Registro de Cobrança
    rw_crapcob    COBR0007.cr_crapcob2%ROWTYPE;
    rw_crapcop    COBR0007.cr_crapcop%ROWTYPE;

  BEGIN
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_sms');

    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;   
          
    vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                  ||', pr_nrdconta:'||pr_nrdconta
                  ||', pr_nrcnvcob:'||pr_nrcnvcob
                  ||', pr_nrdocmto:'||pr_nrdocmto
                  ||', pr_dtmvtolt:'||pr_dtmvtolt
                  ||', pr_cdoperad:'||pr_cdoperad
                  ||', pr_nrremass:'||pr_nrremass;
          
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;
    
    -- Verificar cobrança
    OPEN cr_crapcob2(pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta,
                     pr_nrcnvcob => pr_nrcnvcob,
                     pr_nrdocmto => pr_nrdocmto);
    FETCH cr_crapcob2 INTO rw_crapcob;

    IF cr_crapcob2%NOTFOUND THEN
      CLOSE cr_crapcob2;
      vr_cdcritic := 1179;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Registro de cobranca nao encontrado
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob2;
    
    -- Se a flag de envio de sms 1 dia antes do vencimento estiver pendente, 
    -- altera para nao enviar
    IF rw_crapcob.insmsant = 1 THEN
      rw_crapcob.insmsant := 0;
    END IF;
    
    -- Se a flag de envio de sms no vencimento estiver pendente, 
    -- altera para nao enviar
    IF rw_crapcob.insmsvct = 1 THEN
      rw_crapcob.insmsvct := 0;
    END IF;

    -- Se a flag de envio de sms 1 dia apos ao vencimento estiver pendente, 
    -- altera para nao enviar
    IF rw_crapcob.insmspos = 1 THEN
      rw_crapcob.insmspos := 0;
    END IF;
    
    -- Se todas as flags de envio de SMS estiverem para nao enviar, alterar o indicador principal
    IF rw_crapcob.insmsant = 0 AND
       rw_crapcob.insmsvct = 0 AND
       rw_crapcob.insmspos = 0 THEN
      -- verifica se existe envio eventual. Se existir, nao pode alterar o indicador
      OPEN cr_sms;
      FETCH cr_sms INTO rw_sms;
      IF cr_sms%NOTFOUND THEN
        rw_crapcob.inavisms := 0;
      END IF;
      CLOSE cr_sms;
    END IF;
    
    -- Gerar o retorno para o cooperado 
    COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.rowid
                                      ,pr_cdocorre => 96   -- Cancelamento de SMS
                                      ,pr_cdmotivo => 'S1' -- Solicitado cancelamento
                                      ,pr_vltarifa => 0    -- Valor da Tarifa  
                                      ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                      ,pr_cdagectl => rw_crapcop.cdagectl
                                      ,pr_dtmvtolt => pr_dtmvtolt
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_nrremass => pr_nrremass
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
    -- Verifica se ocorreu erro durante a execucao
    IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_canc_sms');

    -- Atualiza o indicador de SMS
    BEGIN
      UPDATE crapcob 
         SET crapcob.inavisms = rw_crapcob.inavisms,
             crapcob.insmsant = rw_crapcob.insmsant,
             crapcob.insmsvct = rw_crapcob.insmsvct,
             crapcob.insmspos = rw_crapcob.insmspos
       WHERE crapcob.rowid    = rw_crapcob.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        vr_cdcritic := 1035;  --Erro ao atualizar crapcob
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                       ' inavisms:'||rw_crapcob.inavisms||
                       ', insmsant:'||rw_crapcob.insmsant||
                       ', insmsvct:'||rw_crapcob.insmsvct||
                       ', insmspos:'||rw_crapcob.insmspos||
                       ' com rowid:'||rw_crapcob.rowid||
                       '. '||sqlerrm;
        RAISE vr_exc_erro;
    END;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => nvl(pr_cdcooper,3),
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic||vr_dsparame,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);

      -- Complemento para INC0026760
      -- Se chegar erro não tratado de outras chamadas desta procedure joga para 1124
      IF pr_cdcritic = 9999 THEN
        pr_cdcritic := 1224; -- Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;            
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper);

      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_canc_sms. '||sqlerrm||vr_dsparame;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

      pr_cdcritic := 1224; --complemento para INC0026760
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic); --complemento para INC0026760
  END pc_inst_canc_sms;

  -- Procedure para o envio de SMS
  PROCEDURE pc_inst_envio_sms (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                              ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do Convenio
                              ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimentacao
                              ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do Operador
                              ,pr_inavisms  IN PLS_INTEGER           --> Tipo de SMS 1 dia antes do vencimento
                              ,pr_nrcelsac  IN crapsab.nrcelsac%TYPE --> Celular do sacado
                              ,pr_nrremass  IN crapcob.nrremass%TYPE --> Numero da Remessa
                              ,pr_cdcritic OUT INTEGER               --> Codigo da Critica
                              ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
    -- ...........................................................................................
    --
    --  Programa : pc_inst_envio_sms          Antigo: 
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Andrino Carlos de Souza Junior
    --  Data     : Setembro/2016                     Ultima atualizacao: 24/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para cancelar envio de SMS
    --
    --   Alteracao : 24/08/2018 - Revitalização
    --                            Susbtituição de algumas mensagens por cadastro na CRAPCRI
    --                            Inclusão pc_set_modulo
    --                            Ajuste registro de logs com mensagens corretas
    --                            (Ana - Envolti - Ch. REQ0011728)
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_exc_saida  EXCEPTION;
    
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    --Ch REQ0011728
    vr_dsparame      VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    
    -- Cursor para verificar se a conta esta configurada para envio de SMS
    CURSOR cr_config IS
      SELECT 1
        FROM tbcobran_sms_contrato a
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND dhcancela IS NULL;
    rw_config cr_config%ROWTYPE;

    -- Cursor para verificar se a cooperativa esta parametrizada para envia linha digitavel         
    CURSOR cr_param IS
      SELECT 1
        FROM crapcop --tbcobran_param_sms Andrino
       WHERE cdcooper = pr_cdcooper;
--         AND fllinha_digitavel = 1; Andrino
    rw_param cr_param%ROWTYPE;

    -- Cursor para buscar o celular do sacado
    CURSOR cr_crapsab(pr_nrinssac crapsab.nrinssac%TYPE) IS
      SELECT nrcelsac
        FROM crapsab
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrinssac = pr_nrinssac;
    rw_crapsab cr_crapsab%ROWTYPE;
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
    rw_crapcop    COBR0007.cr_crapcop%ROWTYPE;

    -- Registro de Cobrança
    rw_crapcob    COBR0007.cr_crapcob2%ROWTYPE;

  BEGIN
    -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_envio_sms');

    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;   

    vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                  ||', pr_nrdconta:'||pr_nrdconta
                  ||', pr_nrcnvcob:'||pr_nrcnvcob
                  ||', pr_nrdocmto:'||pr_nrdocmto
                  ||', pr_dtmvtolt:'||pr_dtmvtolt
                  ||', pr_cdoperad:'||pr_cdoperad
                  ||', pr_inavisms:'||pr_inavisms
                  ||', pr_nrcelsac:'||pr_nrcelsac
                  ||', pr_nrremass:'||pr_nrremass;

    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 1070;  --Registro de cooperativa nao encontrado
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;
    
    -- Verificar cobrança
    OPEN cr_crapcob2(pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta,
                     pr_nrcnvcob => pr_nrcnvcob,
                     pr_nrdocmto => pr_nrdocmto);
    FETCH cr_crapcob2 INTO rw_crapcob;

    IF cr_crapcob2%NOTFOUND THEN
      CLOSE cr_crapcob2;
      vr_cdcritic := 1179;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Registro de cobranca nao encontrado
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob2;    
    -- Caso a situação for diferente de "ABERTO" não habilitar SMS e não retornar como um erro 
    -- (seguir o fluxo normal)
    IF rw_crapcob.incobran <> 0 THEN
      RAISE vr_exc_saida;
    END IF;
    -- Verifica se a conta possui permissao de envio de SMS
    OPEN cr_config;
    FETCH cr_config INTO rw_config;
    IF cr_config%NOTFOUND THEN
      -- Gerar o retorno para o cooperado 
      COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.rowid
                                        ,pr_cdocorre => 37   -- Instrucao Rejeitada
                                        ,pr_cdmotivo => 'B8' -- Motivo
                                        ,pr_vltarifa => 0    -- Valor da Tarifa  
                                        ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                        ,pr_cdagectl => rw_crapcop.cdagectl
                                        ,pr_dtmvtolt => pr_dtmvtolt
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_nrremass => pr_nrremass
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_envio_sms');
      
      -- Recusar a instrucao
      CLOSE cr_config;
      --REQ0011728
      vr_cdcritic := 1384;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Conta nao parametrizada para envio de SMS
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_config;

    -- Verifica se a instrucao foi feita apos as 19 horas
    IF to_char(SYSDATE,'HH24') >= 19 THEN
      -- Gerar o retorno para o cooperado 
       COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.rowid
                                         ,pr_cdocorre => 37   -- Instrucao Rejeitada
                                         ,pr_cdmotivo => 'B5' -- Horario excedido
                                         ,pr_vltarifa => 0    -- Valor da Tarifa  
                                         ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                         ,pr_cdagectl => rw_crapcop.cdagectl
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrremass => pr_nrremass
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro durante a execucao
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_envio_sms');
      
      -- Recusar a instrucao
      --REQ0011728
      vr_cdcritic := 1385;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Instrucao nao pode ser efetuada apos as 19 horas
      RAISE vr_exc_erro;
    END IF;

      
    -- Se o indicador de linha digitavel for diferente do previsto, nao faz nada
    IF pr_inavisms NOT IN (1,2) THEN
      RAISE vr_exc_erro;
    END IF;

    -- Se o numero do celular do sacado for maior que zeros, atualiza no sacado
    IF substr(pr_nrcelsac,3,9) > 69999999 THEN
      BEGIN
        UPDATE crapsab a
           SET a.nrcelsac = pr_nrcelsac
         WHERE a.cdcooper = pr_cdcooper
           AND a.nrdconta = pr_nrdconta
           AND a.nrinssac = rw_crapcob.nrinssac;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

            vr_cdcritic := 1035;  --Erro ao atualizar crapsab
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapsab:'||
                           ' nrcelsac:'||pr_nrcelsac||
                           ' com cdcooper:'||pr_cdcooper||
                           ', nrdconta:'||pr_nrdconta||
                           ', nrinssac:'||rw_crapcob.nrinssac||
                           '. '||sqlerrm;
            RAISE vr_exc_erro;
      END;
    ELSE -- Busca o celular do sacado
      OPEN cr_crapsab(rw_crapcob.nrinssac);
      FETCH cr_crapsab INTO rw_crapsab;
      CLOSE cr_crapsab;
      
      -- Verifica se nao existe celular para o sacado
      IF substr(rw_crapsab.nrcelsac,3,9) < 69999999 THEN
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.rowid
                                          ,pr_cdocorre => 37   -- Instrucao Rejeitada
                                          ,pr_cdmotivo => 'B7' -- Andrino ver Motivo
                                          ,pr_vltarifa => 0    -- Valor da Tarifa  
                                          ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                          ,pr_cdagectl => rw_crapcop.cdagectl
                                          ,pr_dtmvtolt => pr_dtmvtolt
                                          ,pr_cdoperad => pr_cdoperad
                                          ,pr_nrremass => pr_nrremass
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_envio_sms');
          
        -- Recusar a instrucao
        --REQ0011728
        vr_cdcritic := 1386;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Celular do sacado nao encontrado. Favor efetuar o cadastro
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -- Se o indcador de linha digitavel na CRAPCOB for 0 (nao foi enviado nada), altera o indicador
    IF rw_crapcob.inavisms = 0 THEN
      -- Se o indicador for para enviar a linha digital, verifica se a cooperativa permite
      IF pr_inavisms = 1 THEN
        -- Verifica se a cooperativa esta parametrizada para enviar linha digitavel
        OPEN cr_param;
        FETCH cr_param INTO rw_param;
        IF cr_param%NOTFOUND THEN
          -- Gerar o retorno para o cooperado 
          COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.rowid
                                            ,pr_cdocorre => 37   -- Instrucao Rejeitada
                                            ,pr_cdmotivo => 'B6' -- Andrino ver Motivo
                                            ,pr_vltarifa => 0    -- Valor da Tarifa  
                                            ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                            ,pr_cdagectl => rw_crapcop.cdagectl
                                            ,pr_dtmvtolt => pr_dtmvtolt
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_nrremass => pr_nrremass
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
          -- Verifica se ocorreu erro durante a execucao
          IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Inclui nome do modulo logado - 21/02/2018 - REQ0011728
          GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_inst_envio_sms');
          
          -- Recusar a instrucao
          CLOSE cr_param;
          vr_cdcritic := 1387;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); --Cooperativa nao permite envio de linha digitavel no SMS
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_param;
      END IF;

      -- Altera o indicador de linha digitavel do boleto
      BEGIN
        UPDATE crapcob 
           SET crapcob.inavisms = pr_inavisms
         WHERE crapcob.rowid    = rw_crapcob.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

          vr_cdcritic := 1035;  --Erro ao atualizar crapsab
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'crapcob:'||
                         ' inavisms:'||pr_inavisms||
                         ' com rowid:'||rw_crapcob.rowid||
                         '. '||sqlerrm;
          RAISE vr_exc_erro;
      END;
    END IF;
        
    -- Insere na tebal de envios de SMS como eventual
    BEGIN
      INSERT INTO tbcobran_sms
        (cdcooper,
         nrdconta,
         nrcnvcob,
         nrdocmto,
         nrdctabb,
         cdbandoc,
         dhgeracao,
         invencimento,
         instatus_sms)
       VALUES
        (pr_cdcooper,
         pr_nrdconta,
         pr_nrcnvcob,
         pr_nrdocmto,
         rw_crapcob.nrdctabb,
         rw_crapcob.cdbandoc,
         SYSDATE,
         4,
         1);
    EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        vr_cdcritic := 1034;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'tbcobran_sms:'||
        ' cdcooper:'||pr_cdcooper||
        ', nrdconta:'||pr_nrdconta||
        ', nrcnvcob:'||pr_nrcnvcob||
        ', nrdocmto:'||pr_nrdocmto||
        ', nrdctabb:'||rw_crapcob.nrdctabb||
        ', cdbandoc:'||rw_crapcob.cdbandoc||
        ', dhgeracao:'||sysdate||
        ', invencimento:4'||
        ', instatus_sms:1'||
        '. '||sqlerrm;

        RAISE vr_exc_erro;
    END;
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := 0;
      pr_dscritic := '';

    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic||vr_dsparame,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 1);

      -- Complemento para INC0026760
      -- Se chegar erro não tratado de outras chamadas desta procedure joga para 1124
      IF pr_cdcritic = 9999 THEN
        pr_cdcritic := 1224; -- Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;            
      
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper);

      -- Erro
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'COBR0007.pc_inst_envio_sms. '||sqlerrm||vr_dsparame;

      --Grava tabela de log - Ch REQ0011728
      pc_gera_log(pr_cdcooper      => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(pr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

      pr_cdcritic := 1224; --complemento para INC0026760
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic); --complemento para INC0026760

  END pc_inst_envio_sms;

  PROCEDURE pc_exporta_boletos_emitidos(pr_cdcooper crapcob.cdcooper%TYPE --> Codigo da cooperativa
                                         ,pr_nrdconta crapcob.nrdconta%TYPE --> Nro da conta cooperado
                                         ,pr_dtmvtini crapcob.dtmvtolt%TYPE --> Data de inicio da emissao
                                         ,pr_dtmvtfim crapcob.dtmvtolt%TYPE --> Data de fim da emissao
                                         ,pr_incobran crapcob.incobran%TYPE --> Situacao da cobranca
                                         ,pr_nmdsacad VARCHAR2 --> Nome do sacado/pagador
                                         ,pr_nmarqexp OUT VARCHAR2 --> Caminho e nome do arquivo a ser exportado
                                         ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                          ) IS
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_exporta_boletos_emitidos
        Sistema : Ayllos Web
        Autor   : Andre Clemer - Supero
        Data    : Outubro/2018                 Ultima atualizacao: 12/02/2019
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para buscar parametrizacao de Negativacao Serasa.
        
        Alteracoes:
    
        Alteracao : 12/02/2019 - Revitalização
                                 Susbtituição de algumas mensagens por cadastro na CRAPCRI
                                 Inclusão pc_set_modulo
                                 Ajuste registro de logs com mensagens corretas
                                (Belli - Envolti - Ch. REQ0035813)         
        
        ..............................................................................*/
        DECLARE
        
            -- Variavel de criticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
        
            -- Tratamento de erros
            vr_exc_saida EXCEPTION;
        
            -- Cria o registro de data
            ---rw_crapdat btch0001.cr_crapdat%ROWTYPE; -- Excluido cursor - 12/02/2019 - REQ0035813
        
            -- Variaveis internas
            vr_dsarquiv       CLOB := NULL;
            vr_texto_completo CLOB := NULL;
            vr_caminho_arq    VARCHAR2(300);
            vr_nmarqind       VARCHAR2(100);
            
            -- Variaveis de Log e Modulo - 12/02/2019 - REQ0035813
            vr_dsparame VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
            vr_cdrotpri VARCHAR2  (100); -- Rotina principal
            vr_nmrotpro VARCHAR2  (100) := 'pc_exporta_boletos_emitidos'; -- Procedure principal
        
            ---------------------------- CURSORES -----------------------------------
            -- Buscar registros crapcob
            CURSOR cr_crapcob(pr_cdcooper crapcob.cdcooper%TYPE
                             ,pr_nrdconta crapcob.nrdconta%TYPE
                             ,pr_dtmvtini crapcob.dtmvtolt%TYPE
                             ,pr_dtmvtfim crapcob.dtmvtolt%TYPE
                             ,pr_incobran crapcob.incobran%TYPE
                             ,pr_nmdsacad VARCHAR2) IS
                SELECT crapcob.nrdconta
                      ,crapcob.nrcnvcob
                      ,crapcco.dsorgarq -- 01. Convênio (Internet ou Software)
                      ,crapsab.nmdsacad -- 02. Pagador - Nome
                      ,crapass.nrcpfcgc -- 03. Pagador - CPF/CNPJ
                      ,crapsab.nmcidsac -- 02. Pagador - Cidade
                      ,crapsab.cdufsaca -- 02. Pagador - UF
                      ,crapsab.dsendsac -- 02. Pagador - Endereço
                      ,crapsab.nmbaisac -- 02. Pagador - Bairro
                      ,crapsab.nrinssac -- 02. Pagador - Nro Inscricao
                      ,crapcob.dtmvtolt -- 04. Data emissão 
                      ,crapcob.dtvencto -- 05. Data vencimento
                      ,crapcob.nrdocmto -- 06. Número do documento
                      ,crapcob.nrnosnum -- 07. Número do boleto
                      ,crapcob.vltitulo -- 08. Valor do boleto
                      ,crapcob.vldpagto -- 09. Valor Pago
                      ,crapcob.incobran
                      ,crapcob.flgdprot -- 10. Protesto ou Negativação
                      ,crapcob.qtdiaprt -- Quantidade de dias para protesto
                      ,crapcob.flserasa -- 10. Protesto ou Negativação
                      ,crapcob.qtdianeg -- Quantidade de dias para negativacao
                      ,crapcob.insmsant -- Indicador SMS dia anterior ao vencto
                      ,crapcob.insmsvct -- Indicador SMS no vencto
                      ,crapcob.insmspos -- Indicador SMS apos vencto
                      ,crapcob.insitcrt -- 16. Situação do boleto
                -- ,crapcob.dtmvtolt -- 17. Data do movimento
                  FROM crapcob
                      ,crapceb
                      ,crapass
                      ,crapsab
                      ,crapcco
                      ,tbcobran_retorno_ieptb ret
                 WHERE crapceb.cdcooper = crapcob.cdcooper
                   AND crapceb.nrdconta = crapcob.nrdconta
                   AND crapceb.nrconven = crapcob.nrcnvcob
                      
                   AND crapsab.cdcooper = crapcob.cdcooper
                   AND crapsab.nrdconta = crapcob.nrdconta
                   AND crapsab.nrinssac = crapcob.nrinssac
                      
                   AND crapass.cdcooper = crapcob.cdcooper
                   AND crapass.nrdconta = crapcob.nrdconta
                      
                   AND crapcco.cdcooper = crapcob.cdcooper
                   AND crapcco.nrconven = crapcob.nrcnvcob
                   AND crapcco.cddbanco = crapcob.cdbandoc
                      
                   AND ret.cdcooper(+) = crapcob.cdcooper
                   AND ret.nrdconta(+) = crapcob.nrdconta
                   AND ret.nrcnvcob(+) = crapcob.nrcnvcob
                   AND ret.nrdocmto(+) = crapcob.nrdocmto
                      
                      -- filtro por cooperativa
                   AND (crapcob.cdcooper = pr_cdcooper OR pr_cdcooper IS NULL)
                      -- filtro por numero da conta
                   AND (crapcob.nrdconta = pr_nrdconta OR pr_nrdconta IS NULL)
                      -- filtro por data de emissao
                   AND (crapcob.dtmvtolt BETWEEN nvl(to_date(pr_dtmvtini, 'DD/MM/RRRR'), '01/01/1900') AND
                       nvl(to_date(pr_dtmvtfim, 'DD/MM/RRRR'), trunc(SYSDATE)))
                      -- filtro por situacao
                   AND (crapcob.incobran = pr_incobran OR pr_incobran IS NULL)
                      -- filtro por nome do sacado/pagador
                   AND (upper(crapsab.nmdsacad) LIKE '%' || upper(pr_nmdsacad) || '%' OR pr_nmdsacad IS NULL)
                      
                   AND rownum < 2;
            rw_crapcob cr_crapcob%ROWTYPE;
        
            --------------------------- SUBROTINAS INTERNAS --------------------------
            -- Subrotina para escrever texto na variável CLOB do XML
            PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                                    ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
            BEGIN
                gene0002.pc_escreve_xml(vr_dsarquiv, vr_texto_completo, pr_des_dados, pr_fecha_xml);
                -- Retorna módulo e ação logado
                GENE0001.pc_set_modulo(pr_module => vr_cdrotpri, pr_action => NULL);
            END;
        
        BEGIN          
          -- Posiciona procedure - 12/02/2019 - REQ0035813
          vr_cdrotpri := vr_cdprogra||'.'||vr_nmrotpro;
          -- Inclusão do módulo e ação logado
          GENE0001.pc_set_modulo(pr_module => vr_cdrotpri, pr_action => NULL);
          -- Posiciona parâmetros para geração de Log
          vr_dsparame := 'pr_cdcooper:'   || pr_cdcooper ||
                         ', pr_nrdconta:' || pr_nrdconta ||
                         ', pr_dtmvtini:' || pr_dtmvtini ||
                         ', pr_dtmvtfim:' || pr_dtmvtfim ||
                         ', pr_incobran:' || pr_incobran ||
                         ', pr_nmdsacad:' || pr_nmdsacad;
        
            -- Abre o cursor de data
            --OPEN btch0001.cr_crapdat(pr_cdcooper); - Excluido cursor - 12/02/2019 - REQ0035813
            --FETCH btch0001.cr_crapdat
            --    INTO rw_crapdat;
            --CLOSE btch0001.cr_crapdat;
        
            -- Inicializar o CLOB
            dbms_lob.createtemporary(vr_dsarquiv, TRUE);
            dbms_lob.open(vr_dsarquiv, dbms_lob.lob_readwrite);
        
            -- Cabecalho
            pc_escreve_xml('Conta;Nro.Convenio;Origem;Nome Sacado;CPF/CNPJ;Cidade;UF;Endereco;Bairro;' ||
                           'Nro Inscricao;Data Emissao;Data Vencto;Nro Documento;Nosso Nro;Vlr Titulo;' ||
                           'Vlr Pago;Ind. Cobran.;Prot. Aut.;Qtd. Prot.;Neg. Serasa;Qtd. Neg.;' ||
                           'SMS Ant. Vencto;SMS Vencto;SMS Pos Vencto;Situacao');
        
            -- Montar linhas
            FOR rw_crapcob IN cr_crapcob(pr_cdcooper
                                        ,pr_nrdconta
                                        ,pr_dtmvtini
                                        ,pr_dtmvtfim
                                        ,pr_incobran
                                        ,pr_nmdsacad) LOOP
                pc_escreve_xml(chr(10));
                pc_escreve_xml(rw_crapcob.nrdconta || ';');
                pc_escreve_xml(rw_crapcob.nrcnvcob || ';');
                pc_escreve_xml(rw_crapcob.dsorgarq || ';');
                pc_escreve_xml(rw_crapcob.nmdsacad || ';');
                pc_escreve_xml(rw_crapcob.nrcpfcgc || ';');
                pc_escreve_xml(rw_crapcob.nmcidsac || ';');
                pc_escreve_xml(rw_crapcob.cdufsaca || ';');
                pc_escreve_xml(rw_crapcob.dsendsac || ';');
                pc_escreve_xml(rw_crapcob.nmbaisac || ';');
                pc_escreve_xml(rw_crapcob.nrinssac || ';');
                pc_escreve_xml(rw_crapcob.dtmvtolt || ';');
                pc_escreve_xml(rw_crapcob.dtvencto || ';');
                pc_escreve_xml(rw_crapcob.nrdocmto || ';');
                pc_escreve_xml(rw_crapcob.nrnosnum || ';');
                pc_escreve_xml(rw_crapcob.vltitulo || ';');
                pc_escreve_xml(rw_crapcob.vldpagto || ';');
                pc_escreve_xml(rw_crapcob.incobran || ';');
                pc_escreve_xml(rw_crapcob.flgdprot || ';');
                pc_escreve_xml(rw_crapcob.qtdiaprt || ';');
                pc_escreve_xml(rw_crapcob.flserasa || ';');
                pc_escreve_xml(rw_crapcob.qtdianeg || ';');
                pc_escreve_xml(rw_crapcob.insmsant || ';');
                pc_escreve_xml(rw_crapcob.insmsvct || ';');
                pc_escreve_xml(rw_crapcob.insmspos || ';');
                pc_escreve_xml(rw_crapcob.insitcrt || chr(10));
            END LOOP;
        
            IF cr_crapcob%ISOPEN THEN
                CLOSE cr_crapcob;
            END IF;
        
            -- Finaliza documento
            pc_escreve_xml('', TRUE);
        
            -- Busca o diretorio da cooperativa conectada
            vr_caminho_arq := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                   ,pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsubdir => 'arq');
            -- Retorna módulo e ação logado
            GENE0001.pc_set_modulo(pr_module => vr_cdrotpri, pr_action => NULL);
        
            vr_nmarqind := 'exporta_boletos.csv';
        
            -- Escreve o clob no arquivo físico
            gene0002.pc_clob_para_arquivo(pr_clob     => vr_dsarquiv
                                         ,pr_caminho  => vr_caminho_arq
                                         ,pr_arquivo  => vr_nmarqind
                                         ,pr_des_erro => vr_dscritic);        
            --Se ocorreu erro
            IF vr_dscritic IS NOT NULL THEN
              vr_cdcritic := 0; -- Erro ao gerar o arquivo
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
            -- Retorna módulo e ação logado
            GENE0001.pc_set_modulo(pr_module => vr_cdrotpri, pr_action => NULL);
        
            -- Liberando a memória alocada pro CLOB
            dbms_lob.close(vr_dsarquiv);
            dbms_lob.freetemporary(vr_dsarquiv);
        
            pr_nmarqexp := vr_caminho_arq || '/' || vr_nmarqind;
        
            --> Garantir que o arquivo foi gerado
            IF gene0001.fn_exis_arquivo(pr_caminho => pr_nmarqexp) = FALSE THEN
              vr_cdcritic := 1050; -- Erro ao gerar o arquivo
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
            
            -- Limpa módulo e ação logado
            GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
        
        EXCEPTION
            WHEN vr_exc_saida THEN
              -- Efetuar retorno do erro não tratado
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                                      ,pr_dscritic => vr_dscritic) ||
                             ' '  || vr_nmrotpro || 
                             '. ' || vr_dsparame;
              -- Grava informações para resolver erro de programa/ sistema
              COBR0007.pc_gera_log(pr_cdcooper      => pr_cdcooper -- Cooperativa
                                  ,pr_dstiplog      => 'E'
                                  ,pr_dscritic      => pr_dscritic -- Descricao da critica
                                  ,pr_cdmensagem    => pr_cdcritic 
                                  ,pr_tpexecucao    => 3 -- Tipo de execucao: 0-Outro, 1-Batch, 2-Job, 3-Online
                                  );
              -- Efetuar retorno do erro não tratado
              pr_cdcritic := 1224; -- Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
            
              ROLLBACK;
            
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
              -- Efetuar retorno do erro não tratado
              pr_cdcritic := 9999;
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                             ' '  || vr_nmrotpro || 
                             ' '  || SQLERRM     ||
                             '. ' || vr_dsparame;                       
              -- Grava informações para resolver erro de programa/ sistema
              COBR0007.pc_gera_log(pr_cdcooper      => pr_cdcooper -- Cooperativa
                                  ,pr_dstiplog      => 'E'
                                  ,pr_dscritic      => pr_dscritic -- Descricao da critica
                                  ,pr_cdmensagem    => pr_cdcritic 
                                  ,pr_tpexecucao    => 3 -- Tipo de execucao: 0-Outro, 1-Batch, 2-Job, 3-Online
                                  );
              -- Efetuar retorno do erro não tratado
              pr_cdcritic := 1224; -- Nao foi possivel efetuar o procedimento. Tente novamente ou contacte seu PA
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
                
              ROLLBACK;
        END;
    
    END pc_exporta_boletos_emitidos;

END COBR0007;
/
