CREATE OR REPLACE PACKAGE CECRED.COBR0007 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COBR0007
  --  Sistema  : Procedimentos gerais para execucao de inetrucoes de baixa
  --  Sigla    : CRED
  --  Autor    : Douglas Quisinski
  --  Data     : Janeiro/2016                     Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para instruçőes bancárias - Cob. Registrada 
  --
  --  Alteracoes:
  ---------------------------------------------------------------------------------------------------------------
    
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

END COBR0007;
/
CREATE OR REPLACE PACKAGE BODY CECRED.COBR0007 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COBR0007
  --  Sistema  : Procedimentos gerais para execucao de instrucoes de baixa
  --  Sigla    : CRED
  --  Autor    : Douglas Quisinski
  --  Data     : Janeiro/2016                     Ultima atualizacao: 23/06/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para instruçőes bancárias - Cob. Registrada 
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
  ---------------------------------------------------------------------------------------------------------------
  
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
          ,cob.rowid
     FROM crapcob cob
    WHERE cob.cdcooper = pr_cdcooper
      AND cob.cdbandoc = pr_cdbandoc
      AND cob.nrdctabb = pr_nrdctabb
      AND cob.nrdconta = pr_nrdconta
      AND cob.nrcnvcob = pr_nrcnvcob
      AND cob.nrdocmto = pr_nrdocmto
    ORDER BY cob.progress_recid ASC;

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

  ------------------------------ PROCEDURES --------------------------------    
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
    --  Data     : Novembro/2013.                   Ultima atualizacao: 11/01/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure responsavel pela validacao do horario de cobranca
    --
    --   Alteracoes: 11/01/2016 - Procedure movida da package PAGA0001 para COBR0007 
    --                            (Douglas - Importacao de Arquivos CNAB)
    --
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
    BEGIN
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
      --Se retornou Limite
      IF vr_tab_limite.COUNT > 0 THEN
        -- dentro do limite de horario = 2
        IF vr_tab_limite(vr_tab_limite.FIRST).idesthor = 2 THEN
          RETURN;
        END IF;
        --Montar Mensagem Critica
        vr_dscritic:= 'Este tipo de instrucao eh permitido apenas no horario: '||
                       vr_tab_limite(vr_tab_limite.FIRST).hrinipag ||' ate '||
                       vr_tab_limite(vr_tab_limite.FIRST).hrfimpag ||'.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        pr_des_erro:= 'NOK';
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina COBR0007.pc_verifica_horario_cobranca. '||sqlerrm;
        pr_des_erro:= 'NOK';
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
    --  Data     : Novembro/2013.                   Ultima atualizacao: 11/01/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure responsavel para verificar entrada confirmada
    --
    --   Alteracoes: 11/01/2016 - Procedure movida da package PAGA0001 para COBR0007 
    --                            (Douglas - Importacao de Arquivos CNAB)
    -- 
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
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      pr_des_erro:= 'OK';
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
          vr_dscritic:= 'Titulo sem confirmacao de registro pelo Banco do Brasil.';
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
        pr_dscritic:= vr_dscritic;
        pr_des_erro:= 'NOK';
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina COBR0007.pc_verifica_ent_confirmada. '||sqlerrm;
        pr_des_erro:= 'NOK';
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
    --  Data     : Novembro/2013.                   Ultima atualizacao: 11/01/2016
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
    -- ...........................................................................................

  BEGIN
    DECLARE
      --Registro da Cooperativa
      rw_crapcop COBR0007.cr_crapcop%ROWTYPE;
      --Registro de Cobranca
      rw_crapcob COBR0007.cr_crapcob%ROWTYPE;
      
      --Selecionar informacoes dos titulos do bordero
      CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%type
                        ,pr_nrdconta IN craptdb.nrdconta%type
                        ,pr_cdbandoc IN craptdb.cdbandoc%type
                        ,pr_nrdctabb IN craptdb.nrdctabb%type
                        ,pr_nrcnvcob IN craptdb.nrcnvcob%type
                        ,pr_nrdocmto IN craptdb.nrdocmto%type) IS
        SELECT tdb.dtvencto
              ,tdb.insittit
          FROM craptdb tdb
         WHERE tdb.cdcooper = pr_cdcooper
           AND tdb.nrdconta = pr_nrdconta
           AND tdb.cdbandoc = pr_cdbandoc
           AND tdb.nrdctabb = pr_nrdctabb
           AND tdb.nrcnvcob = pr_nrcnvcob
           AND tdb.nrdocmto = pr_nrdocmto;
      rw_craptdb cr_craptdb%ROWTYPE;

      rw_crapcco COBR0007.cr_crapcco%ROWTYPE;

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
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
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
        vr_cdcritic:= 0;
        vr_dscritic:= 'Registro de cooperativa nao encontrado.';
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
        vr_cdcritic:= 0;
        vr_dscritic:= 'Registro de cobranca nao encontrado.';
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
                --Retornar Erro
                RAISE vr_exc_erro;
              END IF;
            END IF;
          END IF;
        ELSE
          IF pr_cdinstru = '09' THEN -- Protestar 
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
                --Retornar Erro
                RAISE vr_exc_erro;
              END IF;
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
                --Retornar Erro
                RAISE vr_exc_erro;
              END IF;
            END IF;
        END IF;
        -------------------------------------------------
        IF (rw_crapcob.flgregis = 1) THEN
          vr_cdacesso := 'LIMDESCTITCR';
        ELSE
          vr_cdacesso := 'LIMDESCTIT';
        END IF;

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
          
          -- e a situação é em estudo e não esta vencido
          IF ((rw_craptdb.insittit = 0 AND vr_dtcalcul >= pr_dtmvtolt) OR
            rw_craptdb.insittit = 4)  THEN -- LIBERADO

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
          --mensagem erro
          vr_dscritic:= 'Instrucao Rejeitada - Titulo descontado!';
          --Levantar Excecao
          RAISE vr_exc_erro;
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
        --mensagem erro
        vr_dscritic:= 'Registro de cobranca nao encontrado!';
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
            --Montar mensagem erro
            vr_dscritic:= 'Instrucao Rejeitada - Boleto Baixado!';
            RAISE vr_exc_erro;
          ELSE
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
            --Montar mensagem erro
            vr_dscritic:= 'Instrucao Rejeitada - Boleto Protestado!';
            RAISE vr_exc_erro;
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
            --Montar mensagem erro
            vr_dscritic:= 'Instrucao Rejeitada - Boleto Liquidado!';
            RAISE vr_exc_erro;
          END IF;
        ELSE NULL;
      END CASE;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina COBR0007.pc_efetua_val_recusa_padrao. '||sqlerrm;
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
    --  Data     : Novembro/2013.                   Ultima atualizacao: 11/01/2016

    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para eliminar remessa
    --
    --   Alteracao : 11/01/2016 - Procedure movida da package PAGA0001 para COBR0007 
    --                            (Douglas - Importacao de Arquivos CNAB)
    --
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
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      pr_des_erro:= 'OK';
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
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao excluir remessa. '||sqlerrm;
            RAISE vr_exc_erro;
        END;
      ELSE
        pr_dscritic:= 'Problemas na exclusao da Remessa';
        pr_des_erro:= 'NOK';
      END IF;
      --Fechar Cursor
      IF cr_craprem%ISOPEN THEN
        CLOSE cr_craprem;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        pr_des_erro:= 'NOK';
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina COBR0007.pc_elimina_remessa. '||sqlerrm;
        pr_des_erro:= 'NOK';
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
    --  Data     : Novembro/2013.                   Ultima atualizacao: 11/01/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para verificar Existencia de Instrucao
    --
    --   Alteracao : 11/01/2016 - Procedure movida da package PAGA0001 para COBR0007 
    --                            (Douglas - Importacao de Arquivos CNAB)
    --
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
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Selecionar registro cobranca
      OPEN cr_crapcob_id (pr_rowid => pr_idregcob);
      --Posicionar no proximo registro
      FETCH cr_crapcob_id INTO rw_crapcob_id;
      --Se nao encontrar
      IF cr_crapcob_id%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcob_id;
        vr_dscritic:= 'Cobranca nao encontrada.';
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
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar cobranca. '||sqlerrm;
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
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar cobranca. '||sqlerrm;
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
      END LOOP;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina COBR0007.pc_verif_existencia_instruc. '||sqlerrm;
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
    --  Data     : Novembro/2013.                   Ultima atualizacao: 12/12/2016
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
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Selecionar registro cobranca
      OPEN cr_crapcob (pr_rowid => pr_idregcob);
      --Posicionar no proximo registro
      FETCH cr_crapcob INTO rw_bcrapcob;
      --Se nao encontrar
      IF cr_crapcob%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcob;
        --Mensagem Critica
        vr_dscritic:= 'Registro de cobranca nao encontrado';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcob;

      --Verificar cooperativa
      OPEN cr_crapcop(pr_cdcooper => rw_bcrapcob.cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 0;
        vr_dscritic:= 'Registro de cooperativa nao encontrado.';
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
        vr_dscritic:= 'Convenio nao cadastrado ou invalido.';
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
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao inserir na crapceb. '||sqlerrm;
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
        vr_cdcritic:= 0;
        vr_dscritic:= 'Associado nao cadastrado.';
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
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao inserir na crapcob. '||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;

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
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar crapcob. '||sqlerrm;

          BEGIN
            -- Excluir o novo registro criado
            DELETE crapcob
             WHERE crapcob.rowid = rw_crapcob_novo.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := vr_dscritic||chr(10)||'Erro ao excluir crapcob. '||sqlerrm;
          END;

          --Levantar Excecao
          RAISE vr_exc_erro;
      END;

      -- gerar pedido de remessa
      PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob_novo.cdcooper --Codigo Cooperativa
                                     ,pr_nrcnvcob => rw_crapcob_novo.nrcnvcob --Numero Convenio
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
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina COBR0007.pc_enviar_titulo_protesto. '||sqlerrm;
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
    --  Data     : Janeiro/2016                     Ultima atualizacao: 22/01/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Criar o registro de Prorrogacao
    --
    --   Alteracao : 22/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    ------------------------------- VARIAVEIS -------------------------------
  BEGIN
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
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro ao atualizar cobranca. '||sqlerrm;
    END;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
      
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina COBR0007.pc_cria_tab_prorrogacao. '||sqlerrm;
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
    --  Data     : Novembro/2013.                   Ultima atualizacao: 11/01/2016
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
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Montar Conteudo Email
      vr_conteudo:= 'Favor proceder com a instrucao de '|| pr_dsdinstr ||
                    ' no Gerenciador Financeiro para o titulo abaixo: <BR><BR>';
      --Se a conta estiver preenchida
      IF pr_nrdctabb IS NOT NULL THEN
        vr_conteudo:= vr_conteudo ||'Conta BB: '||gene0002.fn_mask_conta(pr_nrdctabb)||'<br>';
      END IF;
      --Continuar montagem do conteudo
      vr_conteudo:= vr_conteudo || 'Conta/DV    : '|| gene0002.fn_mask_conta(pr_idregcob.nrdconta) || '<BR>'||
                                   'Nosso numero: '|| pr_idregcob.nrnosnum || '<BR>'||
                                   'Documento   : '|| pr_idregcob.dsdoccop || '<BR>'||
                                   'Vencimento  : '|| TO_CHAR(pr_idregcob.dtvencto,'DD/MM/YYYY')|| '<BR>'||
                                   'Valor       : '|| gene0002.fn_mask(pr_idregcob.vltitulo,'zzz,zzz,zz9.99')|| '<BR><BR>';
      --Se a data alteracao estiver preenchida
      IF pr_dtaltvct IS NOT NULL THEN
        vr_conteudo:= vr_conteudo || '<BR>'||'Novo vencimento : '||TO_CHAR(pr_dtaltvct,'DD/MM/YYYY')|| '<BR><BR>';
      END IF;
      --Se valor maior zero
      IF pr_vlaltabt > 0 THEN
        vr_conteudo:= vr_conteudo || '<BR>'||'Abatimento : '||gene0002.fn_mask(pr_vlaltabt,'zzz,zzz,zz9.99')|| '<BR><BR>';
      END IF;
      --Montar Assunto
      vr_des_assunto:= 'Solicitacao de instrucao de '|| pr_dsdinstr;
      --Email Destino
      vr_email_dest:= gene0001.fn_param_sistema('CRED',pr_idregcob.cdcooper,'INST_TIT_MIGRADO');
      --Se nao encontrou destinatario para as cooperativas 1 ou 16
      -- O programa progress não envia e-mail para as demais cooperativas
      IF vr_email_dest IS NULL AND pr_idregcob.cdcooper IN (1,16) THEN
        vr_dscritic:= 'Email de destino para titulo migrado nao encontrado.';
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
        -- Apenas sai da rotina
        RETURN;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_titulo_migrado. '||sqlerrm;
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
    --  Data     : Novembro/2013.                   Ultima atualizacao: 19/05/2016
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
    -- ...........................................................................................
  BEGIN
    DECLARE
      --Cursores Locais
      --Selecionar Pracas nao executantes Protesto
      CURSOR cr_crappnp (pr_nmextcid IN crappnp.nmextcid%type
                        ,pr_cduflogr IN crappnp.cduflogr%type) IS
        SELECT pnp.nmextcid
          FROM crappnp pnp
         WHERE UPPER(pnp.nmextcid) = UPPER(pr_nmextcid)
           AND UPPER(pnp.cduflogr) = UPPER(pr_cduflogr);
      rw_crappnp cr_crappnp%ROWTYPE;
      
      --Variaveis Locais
      vr_index_lat VARCHAR2(60);
      vr_nrremret  INTEGER;
      vr_nrseqreg  INTEGER;
      
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
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Verificar cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 0;
        vr_dscritic:= 'Registro de cooperativa nao encontrado.';
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

      IF rw_crapcob_ret.cdbandoc  = 85 AND
         rw_crapcob_ret.flgregis  = 1 AND
         rw_crapcob_ret.flgcbdda  = 1 AND
         rw_crapcob_ret.insitpro <= 2 THEN
        vr_dscritic:= 'Titulo em processo de registro. Favor aguardar';
        --Retornar
        RAISE vr_exc_erro;
      END IF;
      ------ VALIDACOES PARA RECUSAR ------

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
        vr_dscritic:= 'Boleto a Vencer - Protesto nao efetuado!';
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
        vr_dscritic:= 'Boleto nao ultrapassou data de Instr. Autom. de Protesto - Protesto nao efetuado!';
        --Retornar
        RAISE vr_exc_erro;
      END IF;
      -- Titulos com Remessa a Cartorio ou Em Cartorio 
      CASE rw_crapcob_ret.insitcrt
        WHEN 1 THEN
          vr_dscritic:= 'Boleto c/ instrucao de protesto - Aguarde confirmacao do Banco do Brasil - Protesto nao efetuado!';
          RAISE vr_exc_erro;
        WHEN 2 THEN
          vr_dscritic:= 'Boleto c/ instrucao de sustacao - Aguarde confirmacao do Banco do Brasil - Protesto nao efetuado!';
          RAISE vr_exc_erro;
        WHEN 3 THEN
          vr_dscritic:= 'Boleto Em Cartorio - Protesto nao efetuado!';
          RAISE vr_exc_erro;
        ELSE NULL;
      END CASE;
      --Verificar Conta Associado
      OPEN cr_crapass(pr_cdcooper => rw_crapcob_ret.cdcooper
                     ,pr_nrdconta => rw_crapcob_ret.nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      --Se nao encontrou associado
      IF cr_crapass%NOTFOUND THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Associado nao cadastrado.';
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
        vr_dscritic:= 'Instrucao nao permitida para Pessoa Fisica';
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
          vr_dscritic:= 'Instrucao de Protesto ja efetuada - Protesto nao efetuado!';
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
        vr_dscritic:= 'Especie Docto diferente de DM e DS - Protesto nao efetuado!';
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
        vr_dscritic:= 'Pagador nao encontrado.';
        --Retornar
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapsab;
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
        vr_dscritic:= 'Praca nao executante de protesto - Instrucao nao efetuada';
        --Retornar
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      IF cr_crappnp%ISOPEN THEN
        CLOSE cr_crappnp;
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
          vr_dscritic:= 'Solicitacao de protesto de titulo migrado. Aguarde confirmacao no proximo dia util.';
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
        --Preparar remessa banco
        PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob_ret.cdcooper --Cooperativa
                                       ,pr_nrcnvcob => rw_crapcob_ret.nrcnvcob --Numero Convenio
                                       ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                       ,pr_cdoperad => pr_cdoperad --Codigo Operador
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
      ELSIF rw_crapcob_ret.cdbandoc = 85 THEN
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
        --Prepara retorno cooperado
        COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob_ret.rowid --ROWID da cobranca
                                           ,pr_cdocorre => 19                   --Codigo Ocorrencia
                                           ,pr_cdmotivo => NULL                 --Codigo Motivo
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
      END IF;
      -- Nao efetuar a cobranca da tarifa quando for processo automatico de protesto via crps
      IF rw_crapcob_ret.cdbandoc = 85 AND pr_cdoperad <> '1' THEN
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
        pr_tab_lat_consolidada(vr_index_lat).cdmotivo:= NULL;  -- Motivo
        pr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob_ret.vltitulo;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_protestar. '||sqlerrm;
    END;
  END pc_inst_protestar;

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
    --  Data     : Novembro/2013.                   Ultima atualizacao: 11/01/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Baixar o Titulo
    --
    --   Alteracao : 11/01/2016 - Procedure movida da package PAGA0001 para COBR0007 
    --                            (Douglas - Importacao de Arquivos CNAB)
    --
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
    BEGIN
      --Inicializa variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      
      --Selecionar registro cobranca
      OPEN cr_crapcob_id (pr_rowid => pr_idregcob);

      --Posicionar no proximo registro
      FETCH cr_crapcob_id INTO rw_crapcob_id;

      --Se nao encontrar
      IF cr_crapcob_id%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcob_id;

        --Mensagem Critica
        vr_dscritic:= 'Registro de cobranca nao encontrado';
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

        vr_cdcritic:= 0;
        vr_dscritic:= 'Registro de cooperativa nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;

      END IF;

      --Fechar Cursor
      CLOSE cr_crapcop;

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
         vr_dscritic:= 'Titulo em processo de registro. Favor aguardar';
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
           vr_dscritic:= 'Boleto Baixado - Baixa nao efetuada!';
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

          vr_dscritic:= 'Pedido de Baixa ja efetuado - Baixa nao efetuada!';
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

          --Buscar Ultima Mensagem erro
          vr_cdcritic:= vr_cdcritic2;
          vr_dscritic:= vr_dscritic2;
          --Levantar Excecao
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

          vr_dscritic:= 'Solicitacao de baixa de titulo migrado. Aguarde confirmacao no proximo dia util.';
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
          UPDATE crapcob SET crapcob.idopeleg = rw_crapcob_ret.idopeleg
          WHERE crapcob.rowid = rw_crapcob_ret.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar crapcob. '||sqlerrm;
        END;
      END IF;

      --- Verifica se ja existe instr. Abat. / Canc. Abat. / Alt. Vencto ---
      COBR0007.pc_verif_existencia_instruc (pr_idregcob  => rw_crapcob_ret.rowid --ROWID da Cobranca
                                           ,pr_cdoperad  => pr_cdoperad      --Codigo Operador
                                           ,pr_dtmvtolt  => pr_dtmvtolt      --Data Movimento
                                           ,pr_cdcritic  => vr_cdcritic      --Codigo Critica
                                           ,pr_dscritic  => vr_dscritic);    --Descricao Critica

      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN

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

        --Buscar Ultima Mensagem erro
        vr_cdcritic:= vr_cdcritic2;
        vr_dscritic:= vr_dscritic2;

        --Levantar Excecao
        RAISE vr_exc_erro;

      END IF;

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

          -- excluir titulo da remessa BB
          BEGIN
            DELETE craprem WHERE craprem.rowid = rw_craprem2.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao excluir craprem. '||sqlerrm;
          END;

          -- tornar o titulo baixado
          BEGIN
            UPDATE crapcob SET crapcob.incobran = 3
                              ,crapcob.dtdbaixa = pr_dtmvtolt
            WHERE crapcob.rowid = rw_crapcob_ret.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao excluir craprem. '||sqlerrm;
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

          -- excluir titulo da remessa BB 
          BEGIN
            DELETE craprem WHERE craprem.rowid = rw_craprem2.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao excluir craprem. '||sqlerrm;
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

        END IF;

        --Fechar Cursor
        IF cr_craprem2%ISOPEN THEN
          CLOSE cr_craprem2;
        END IF;

      ELSE -- FIM do IF cdbandoc = 1

        IF rw_crapcob_ret.cdbandoc = rw_crapcop.cdbcoctl THEN

          BEGIN
            UPDATE crapcob SET crapcob.incobran = 3
                              ,crapcob.dtdbaixa = pr_dtmvtolt
            WHERE crapcob.rowid = rw_crapcob_ret.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar cobranca. '||sqlerrm;
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
			  
  	END IF;  
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_pedido_baixa. '||sqlerrm;
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
      vr_des_erro VARCHAR2(4000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;

   BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Verificar cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 0;
        vr_dscritic:= 'Registro de cooperativa nao encontrado.';
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
        vr_cdcritic:= 0;
        vr_dscritic:= 'Registro de cobranca nao encontrado.';
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
        vr_dscritic:= 'Registro de cobranca nao encontrado';
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

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_pedido_baixa_prg. '||sqlerrm;
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
    --  Data     : Novembro/2013.                   Ultima atualizacao: 21/08/2017
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

    BEGIN
      
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Verificar cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 0;
        vr_dscritic:= 'Registro de cooperativa nao encontrado.';
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
        vr_cdcritic:= 0;
        vr_dscritic:= 'Registro de cobranca nao encontrado.';
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
        vr_dscritic:= 'Registro de cobranca nao encontrado';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcob;

      ----- VALIDACOES PARA RECUSAR -----
      CASE rw_crapcob.incobran
        WHEN 3 THEN
          IF rw_crapcob.insitcrt <> 5 THEN
            vr_dscritic:= 'Boleto Baixado - Baixa nao efetuada!';
          ELSE
            vr_dscritic:= 'Boleto Protestado - Baixa nao efetuada!';
          END IF;
          --Levantar Excecao
          RAISE vr_exc_erro;
        WHEN 5 THEN
          vr_dscritic:= 'Boleto Liquidado - Baixa nao efetuada!';
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
          vr_dscritic:= 'Pedido de Baixa ja efetuado - Baixa nao efetuada!';
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
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar crapcob. '||sqlerrm;
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
        ELSIF rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl THEN
          --Atualizar Cobranca
          BEGIN
            UPDATE crapcob SET crapcob.incobran = 3
                              ,crapcob.dtdbaixa = pr_dtmvtolt
            WHERE crapcob.rowid = rw_crapcob.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar crapcob. '||sqlerrm;
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
        END IF;

        --Montar Motivo
        vr_dsmotivo:= 'Instrucao de Baixa - Decurso Prazo';
        --Cria log cobranca
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                     ,pr_dsmensag => vr_dsmotivo   --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro   --Indicador erro
                                     ,pr_dscritic => vr_dscritic); --Descricao erro

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
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_pedido_baixa_decurso. '||sqlerrm;
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
    --  Data     : Novembro/2013.                   Ultima atualizacao: 11/01/2016
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
    BEGIN
      --Inicializa variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      -- Buscar parâmetros do cadastro de cobrança
      OPEN  cr_crapcco(pr_cdcooper => pr_cdcooper
                      ,pr_nrconven => pr_nrcnvcob);
      FETCH cr_crapcco INTO rw_crapcco;
      -- Se não encontrar registro
      IF cr_crapcco%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcco;
        vr_cdcritic:= 0;
        vr_dscritic:= 'Registro de cobranca nao encontrado.';
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
        vr_dscritic:= 'Registro de cobranca nao encontrado';
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
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_sustar_baixar. '||sqlerrm;
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
    --  Data     : Janeiro/2016                     Ultima atualizacao: 12/01/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Conceder Abatimento
    --
    --   Alteracao : 12/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
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
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro de cooperativa nao encontrado.';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Titulo em processo de registro. Favor aguardar';
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
        
        -- Recusar a instrucao
        vr_dscritic := 'Pedido de Baixa ja efetuado - Abatimento nao efetuado!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto c/ Remessa a Cartorio - Abatimento nao efetuado!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto Em Cartorio - Abatimento nao efetuado!';
      RAISE vr_exc_erro;
    END IF;
    
    -- Calcular o valor com os abatimentos 
    vr_vltitabr := rw_crapcob.vltitulo - rw_crapcob.vldescto - rw_crapcob.vlabatim;
    IF  pr_vlabatim > vr_vltitabr THEN
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Valor de Abatimento superior ao Valor do Boleto - ' ||
                     'Abatimento nao efetuado!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Valor de Abatimento maior que o permitido devido ao Valor minimo boleto - ' ||
                     'Abatimento nao efetuado!';
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
          
          -- Recusar a instrucao
          vr_dscritic := 'Nao e permitido conceder abatimento de boleto no ' ||
                         'convenio protesto - Abatimento nao efetuado!';
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
        -- Recusar a instrucao
        vr_dscritic := 'Solicitacao de abatimento de titulo migrado. ' ||
                       'Aguarde confirmacao no proximo dia util.';
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
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro ao atualizar crapcob. ' || SQLERRM;
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

      ELSE 
        CLOSE cr_craprem;
      END IF;

      --Preparar remessa banco
      PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw_crapcob.cdcooper --Cooperativa
                                     ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenio
                                     ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                     ,pr_cdoperad => pr_cdoperad --Codigo Operador
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
      END IF; -- FIM do IF cdbandoc = 85
    END IF;

    -- LOG de Processo
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                 ,pr_cdoperad => pr_cdoperad   --Operador
                                 ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                 ,pr_dsmensag => 'Concessao de Abatimento Vlr: R$ ' || 
                                                 TRIM(to_char(pr_vlabatim,'9g999g990d00')) --Descricao Mensagem
                                 ,pr_des_erro => vr_des_erro   --Indicador erro
                                 ,pr_dscritic => vr_dscritic); --Descricao erro
    --Se ocorreu erro
    IF vr_des_erro = 'NOK' THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

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
    
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_conc_abatimento. '||sqlerrm;
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
    --  Data     : Janeiro/2016                     Ultima atualizacao: 12/01/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Cancelar Abatimento
    --
    --   Alteracao : 12/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
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
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro de cooperativa nao encontrado.';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Titulo em processo de registro. Favor aguardar';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto c/ Remessa a Cartorio - Canc. Abatim. nao efetuado!';
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

      -- Recusar a instrucao
      vr_dscritic := 'Boleto Em Cartorio - Canc. Abatim. nao efetuado!';
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
        
        -- Recusar a instrucao
        vr_dscritic := 'Pedido de Baixa ja efetuado - Canc. Abatim. nao efetuado!';
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

      -- Recusar a instrucao
      vr_dscritic := 'Boleto sem Valor de Abatimento - Canc. Abatim. nao efetuado!';
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
                                          ,pr_dsdinstr => 'Cancelamento de Abatimento' --Descricao da Instrucao
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

          vr_dscritic:= 'Solicitacao de cancelamento de abatimento de titulo migrado. ' ||
                        'Aguarde confirmacao no proximo dia util.';
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
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar crapcob. ' || SQLERRM;
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
        -- FIM do IF cdbandoc = 85
        END IF;
      END IF;

      -- LOG de Processo
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                   ,pr_cdoperad => pr_cdoperad   --Operador
                                   ,pr_dtmvtolt => pr_dtmvtolt   --Data movimento
                                   ,pr_dsmensag => 'Cancelamento de Abatimento'   --Descricao Mensagem
                                   ,pr_des_erro => vr_des_erro   --Indicador erro
                                   ,pr_dscritic => vr_dscritic); --Descricao erro
      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

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
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_canc_abatimento. ' || SQLERRM;
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
    --  Data     : Janeiro/2016                     Ultima atualizacao: 19/01/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Alterar o vencimento
    --
    --   Alteracao : 19/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
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
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro de cooperativa nao encontrado.';
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
      vr_dscritic := 'Titulo em processo de registro. Favor aguardar';
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
        
        -- Recusar a instrucao
        vr_dscritic := 'Pedido de Baixa ja efetuado - Alteracao Vencto nao efetuada!';
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

      -- Recusar a instrucao
      vr_dscritic := 'Data Vencto inferior ao atual - Alteracao Vencto nao efetuada!';
      RAISE vr_exc_erro;
    END IF;

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

      -- Recusar a instrucao
      vr_dscritic := 'Prazo de vencimento superior ao permitido!';
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

        -- Recusar a instrucao
        vr_dscritic := 'Nao e permitido alterar vencimento do boleto no convenio protesto' ||
                       ' - Alteracao Vencto nao efetuada!';
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

      -- Recusar a instrucao
      vr_dscritic := 'Data Vencto anterior a Data de Emissao' ||
                     ' - Alteracao Vencto nao efetuada!';
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

      -- Recusar a instrucao
      vr_dscritic := 'Titulo com movimentacao cartoraria' ||
                     ' - Alteracao Vencto nao efetuada!';
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
        vr_dscritic:= 'Solicitacao de baixa de titulo migrado. Aguarde confirmacao no proximo dia util.';
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
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro ao atualizar crapcob. ' || SQLERRM;
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
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        
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
    
    ---- LOG de Processo ----
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                 ,pr_cdoperad => pr_cdoperad      --Operador
                                 ,pr_dtmvtolt => pr_dtmvtolt      --Data movimento
                                 ,pr_dsmensag => 'Alter. Vencto. De ' || 
                                                 to_char(vr_dtvencto_old,'dd/mm/yy') ||
                                                 ' para ' ||
                                                 to_char(pr_dtvencto,'dd/mm/yy')  --Descricao Mensagem
                                 ,pr_des_erro => vr_des_erro      --Indicador erro
                                 ,pr_dscritic => vr_dscritic);    --Descricao erro
    --Se ocorreu erro
    IF vr_des_erro = 'NOK' THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
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
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_alt_vencto. '||sqlerrm;
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
    --  Data     : Janeiro/2016                     Ultima atualizacao: 12/07/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Alterar o vencimento
    --
    --   Alteracao : 22/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --
    --               12/07/2017 - Ajustes para atualizar crapcob.cdmensag. PRJ340(Odirlei-AMcom)
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_cdcritic2  PLS_INTEGER;
    vr_dscritic2  VARCHAR2(4000);
    vr_des_erro   VARCHAR2(3);

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
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro de cooperativa nao encontrado.';
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
      vr_dscritic := 'Titulo em processo de registro. Favor aguardar';
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
        
        -- Recusar a instrucao
        vr_dscritic := 'Pedido de Baixa ja efetuado - Desconto nao efetuado!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto c/ Remessa a Cartorio - Desconto nao efetuado!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto Em Cartorio - Desconto nao efetuado!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Valor de Desconto superior ao Valor do Boleto - Desconto nao efetuado!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Valor de Desconto maior que o permitido devido ao Valor minimo boleto - ' ||
                     'Desconto nao efetuado!';
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

        -- Recusar a instrucao
        vr_dscritic := 'Nao e permitido conceder desconto de boleto no convenio protesto' ||
                       ' - Desconto nao efetuado!';
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
        vr_dscritic:= 'Solicitacao de baixa de titulo migrado. Aguarde confirmacao no proximo dia util.';
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
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro ao atualizar crapcob. ' || SQLERRM;
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
      END IF;
    END IF;

    ---- LOG de Processo ----
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                 ,pr_cdoperad => pr_cdoperad      --Operador
                                 ,pr_dtmvtolt => pr_dtmvtolt      --Data movimento
                                 ,pr_dsmensag => 'Concessao de Desconto Vlr: R$ ' ||
                                                 TRIM(to_char(pr_vldescto,'9g999g990d00')) -- Descricao Mensagem
                                 ,pr_des_erro => vr_des_erro      --Indicador erro
                                 ,pr_dscritic => vr_dscritic);    --Descricao erro
    --Se ocorreu erro
    IF vr_des_erro = 'NOK' THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

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
      
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_conc_desconto. '||sqlerrm;
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
    --  Data     : Janeiro/2016                     Ultima atualizacao: 12/07/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Cancelar Desconto
    --
    --   Alteracao : 22/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --
    --               12/07/2017 - Ajustes para atualizar crapcob.cdmensag. PRJ340(Odirlei-AMcom)
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_cdcritic2  PLS_INTEGER;
    vr_dscritic2  VARCHAR2(4000);
    vr_des_erro   VARCHAR2(3);

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
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro de cooperativa nao encontrado.';
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
      vr_dscritic := 'Titulo em processo de registro. Favor aguardar';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto c/ Remessa a Cartorio - Canc. Desconto nao efetuado!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto Em Cartorio - Canc. Desconto nao efetuado!';
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
        
        -- Recusar a instrucao
        vr_dscritic := 'Pedido de Baixa ja efetuado - Canc. Desconto nao efetuado!';
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

      -- Recusar a instrucao
      vr_dscritic := 'Boleto sem Valor de Desconto - Canc. Desconto nao efetuado!';
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
                                        ,pr_dsdinstr => 'Cancelamento de Desconto' --Descricao da Instrucao
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
        vr_dscritic:= 'Solicitacao de cancelamento de desconto de titulo migrado. ' ||
                      'Aguarde confirmacao no proximo dia util.';
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
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro ao atualizar crapcob. ' || SQLERRM;
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
      END IF;
    END IF;

    ---- LOG de Processo ----
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                 ,pr_cdoperad => pr_cdoperad      --Operador
                                 ,pr_dtmvtolt => pr_dtmvtolt      --Data movimento
                                 ,pr_dsmensag => 'Cancelamento de Desconto'               --Descricao Mensagem
                                 ,pr_des_erro => vr_des_erro      --Indicador erro
                                 ,pr_dscritic => vr_dscritic);    --Descricao erro
    --Se ocorreu erro
    IF vr_des_erro = 'NOK' THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
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
      
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_canc_desconto. '||sqlerrm;
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
    --  Data     : Janeiro/2016                     Ultima atualizacao: 19/05/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para realizar o Protesto
    --
    --   Alteracao : 22/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --				   
    --               19/05/2016 - Incluido upper em cmapos de index utilizados em cursores (Andrei - RKAM).
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------    
    CURSOR cr_crapass (pr_cdcooper  IN crapass.cdcooper%TYPE
                      ,pr_nrdconta  IN crapass.nrdconta%TYPE ) IS
      SELECT ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --Selecionar Pracas nao executantes Protesto
    CURSOR cr_crappnp (pr_nmextcid IN crappnp.nmextcid%type
                      ,pr_cduflogr IN crappnp.cduflogr%type) IS
      SELECT pnp.nmextcid
        FROM crappnp pnp
       WHERE UPPER(pnp.nmextcid) = UPPER(pr_nmextcid)
         AND UPPER(pnp.cduflogr) = UPPER(pr_cduflogr);
    rw_crappnp cr_crappnp%ROWTYPE;

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
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro de cooperativa nao encontrado.';
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
      vr_dscritic := 'Titulo em processo de registro. Favor aguardar';
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

      -- Recusar a instrucao
      vr_dscritic := 'Boleto a Vencer - Protesto nao efetuado!';
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

      -- Recusar a instrucao
      vr_dscritic := 'Boleto nao ultrapassou data de Instr. Autom. de Protesto - Protesto nao efetuado!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto c/ instrucao de protesto - ' ||
                     'Aguarde confirmacao do Banco do Brasil - ' ||
                     'Protesto nao efetuado!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto c/ instrucao de sustacao - ' ||
                     'Aguarde confirmacao do Banco do Brasil - ' || 
                     'Protesto nao efetuado!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto Em Cartorio - Protesto nao efetuado!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Instrucao nao permitida para Pessoa Fisica';
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
      
        -- Recusar a instrucao
        vr_dscritic := 'Instrucao de Protesto ja efetuada - Protesto nao efetuado!';
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
      vr_dscritic:= 'Especie Docto diferente de DM e DS - Protesto nao efetuado!';
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
      vr_dscritic:= 'Praca nao executante de protesto – Instrucao nao efetuada';
      --Retornar
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    IF cr_crappnp%ISOPEN THEN
      CLOSE cr_crappnp;
    END IF;
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
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar crapcob. ' || SQLERRM;
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
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_protestar_arq_rem_085. '||sqlerrm;
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
    --  Data     : Janeiro/2016                     Ultima atualizacao: 22/01/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Sustar Protesto e Manter Titulo
    --
    --   Alteracao : 22/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_des_erro   VARCHAR2(3);

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

  BEGIN
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro de cooperativa nao encontrado.';
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
      vr_dscritic := 'Titulo em processo de registro. Favor aguardar';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto c/ instr. de sustacao - ' || 
                     'Aguarde sustacao do Banco do Brasil - ' || 
                     'Instr. Sustar nao efetuada!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto sustado - Instr. Sustar nao efetuada!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto a Vencer - Instr. Sustar nao efetuada!';
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

      -- Recusar a instrucao
      vr_dscritic := 'Boleto sem Conf Inst. Protesto  - Instr. Sustar nao efetuada!';
      RAISE vr_exc_erro;
    ELSE 
      -- Fechar o cursor
      CLOSE cr_crapret;  
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

          -- Recusar a instrucao
          vr_dscritic := 'Boleto sera enviado ao convenio protesto Banco do Brasil - ' ||
                         'Instr. Sustar nao efetuada!';
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

        -- Recusar a instrucao
        vr_dscritic := 'Ja existe Instrucao de Protesto - Instr. Sustar nao efetuada!';
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

        -- Recusar a instrucao
        vr_dscritic := 'Ja existe Instrucao de Sustar/Manter - Instr. Sustar nao efetuada!';
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
      vr_dscritic := 'Boleto do Banco 085 - Instr. Sustar nao efetuada!';
      RAISE vr_exc_erro;
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
        vr_dscritic:= 'Solicitacao de sustacao de titulo migrado. Aguarde confirmacao no proximo dia util.';
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

    IF rw_crapcob.cdbandoc = 1 THEN
      -- Registra Instrucao de Sustar e Manter
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
    
    -- Conforme conversado com o Rafael Cechet
    -- Nao existe a instrucao de sustar e manter para os boletos do banco 85
    -- tanto que se o boleto for do banco 85 ele tem a isntrucao rejeitada
    -- por isso esse trecho de fonte sera comentado
    /*
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
    */
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_sustar_manter. '||sqlerrm;
  END pc_inst_sustar_manter;
  
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
    --  Data     : Janeiro/2016                     Ultima atualizacao: 20/05/2017
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
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_cdcritic2  PLS_INTEGER;
    vr_dscritic2  VARCHAR2(4000);
    vr_des_erro   VARCHAR2(3);

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
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro de cooperativa nao encontrado.';
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
      vr_dscritic := 'Titulo em processo de registro. Favor aguardar';
      RAISE vr_exc_erro;
    END IF;

    -- Verificamos se o boleto possui Negativacao no Serasa
    IF rw_crapcob.flserasa = 1 AND 
       rw_crapcob.qtdianeg > 0 THEN
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

        -- Recusar a instrucao
        vr_dscritic := 'Excedido prazo cancelamento da instrucao automatica de negativacao! Canc instr negativacao nao efetuado!';
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

        -- Recusar a instrucao
        vr_dscritic := 'Titulo ja enviado para Negativacao! Canc instr negativacao nao efetuado!';
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

      -- Recusar a instrucao
      vr_dscritic := 'Boleto sem Conf Inst. Protesto  - Canc. Protesto nao efetuado!';
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

      -- Recusar a instrucao
      vr_dscritic := 'Boleto sem Instr. Automatica de Protesto - Canc. Protesto nao efetuado!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto c/ instr. de protesto - Canc. Protesto nao efetuado!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto c/ instr. de sustacao - ' ||
                     'Aguarde sustacao do Banco do Brasil - ' ||
                     'Canc. Protesto nao efetuado!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto Em Cartorio - Canc. Protesto nao efetuado!';
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
        
        -- Recusar a instrucao
        vr_dscritic := 'Boleto Sustado - Canc. Protesto nao efetuado!';
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

        -- Recusar a instrucao
        vr_dscritic := 'Nao e permitido cancelar instr. de protesto do boleto no convenio protesto - ' ||
                       'Canc. Protesto nao efetuado!';
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
        vr_dscritic:= 'Instrucao de Protesto ja efetuada - Canc. Protesto nao efetuado!';
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
        vr_dscritic:= 'Instrucao de Canc. Protesto ja efetuada - Canc. Protesto nao efetuado!';
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
        vr_dscritic:= 'Solicitacao de cancelamento de protesto de titulo migrado. ' ||
                      'Aguarde confirmacao no proximo dia util.';
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
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar crapcob.(SERASA) ' || SQLERRM;
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
    rw_crapcob.dsdinstr := REPLACE(rw_crapcob.dsdinstr, 
                                   '** Servico de protesto sera efetuado pelo Banco do Brasil **', '');
    --Atualizar Cobranca
    BEGIN
      UPDATE crapcob SET crapcob.flgdprot = rw_crapcob.flgdprot,
                         crapcob.qtdiaprt = rw_crapcob.qtdiaprt,
                         crapcob.dsdinstr = rw_crapcob.dsdinstr,
                         crapcob.idopeleg = rw_crapcob.idopeleg
      WHERE crapcob.rowid = rw_crapcob.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro ao atualizar crapcob. ' || SQLERRM;
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

    IF rw_crapcob.cdbandoc = 1 THEN
      -- Registra Instrucao Alter Dados / Protesto
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
      
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_cancel_protesto. '||sqlerrm;
  END pc_inst_cancel_protesto;
  
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
    --  Data     : Janeiro/2016                     Ultima atualizacao: 25/01/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Alterar tipo de emissao CEE
    --
    --   Alteracao : 25/01/2016 - Coversao Progress -> Oracle (Douglas - Importacao de Arquivos CNAB)
    --
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_des_erro   VARCHAR2(3);

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
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro de cooperativa nao encontrado.';
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

      -- Recusar a instrucao
      vr_dscritic := 'Nao permitido alterar tipo de emissao de boletos do Banco do Brasil. Instrucao nao realizada.';
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

      -- Recusar a instrucao
      vr_dscritic := 'Boleto ja e Cooperativa Emite e Expede – Alteracao nao efetuada';
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

      -- Recusar a instrucao
      vr_dscritic := 'Cooperado nao possui modalidade de emissao Cooperativa/EE habilitada – Alteracao nao efetuada';
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

      -- Recusar a instrucao
      vr_dscritic := 'Titulo em processo de registro. Favor aguardar';
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
        
        -- Recusar a instrucao
        vr_dscritic := 'Alteracao de tipo de emissao ja efetuado - Instrucao nao efetuada!';
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
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar crapcob. ' || SQLERRM;
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
      
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_alt_tipo_emissao_cee. '||sqlerrm;
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
    --  Data     : Janeiro/2016                     Ultima atualizacao: 23/06/2017
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
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_cdcritic2  PLS_INTEGER;
    vr_dscritic2  VARCHAR2(4000);
    vr_des_erro   VARCHAR2(3);

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
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro de cooperativa nao encontrado.';
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
      vr_dscritic:= 'Registro de cobranca nao encontrado';
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

      -- Recusar a instrucao
      vr_dscritic := 'Registro de cobranca nao encontrado';
      RAISE vr_exc_erro;
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

      -- Recusar a instrucao
      vr_dscritic := 'Titulo em processo de registro. Favor aguardar';
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

      -- Recusar a instrucao
      IF rw_crapcob.insitcrt <> 5 THEN
        vr_dscritic := 'Boleto Baixado - Alteracao nao efetuada!';
      ELSE
        vr_dscritic := 'Boleto Protestado - Alteracao nao efetuada!';
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

      -- Recusar a instrucao
      vr_dscritic := 'Boleto Liquidado - Alteracao nao efetuada!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto c/ Remessa a Cartorio - Alteracao nao efetuado!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Boleto Em Cartorio - Alteracao nao efetuado!';
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

        -- Recusar a instrucao
        vr_dscritic := 'Alteracao ja efetuada!';
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

      -- Recusar a instrucao
      vr_dscritic := 'Solicitacao de alteracao de dados nao efetuada. Pagador nao encontrado.';
      RAISE vr_exc_erro;
    ELSE 
      -- Fecha o crusos
      CLOSE cr_crapsab;
    END IF;

    IF rw_crapsab.dsendsac <> pr_dsendsac THEN
      vr_nrendsac:= 0;
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
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro ao atualizar crapsab. ' || SQLERRM;
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
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar crapcob. ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;

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
      
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_alt_dados_arq_rem_085. '||sqlerrm;
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
    --  Data     : Setembro/2016                     Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para cancelar envio de SMS
    --
    --   Alteracao : 
    --
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

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
    rw_crapcob    COBR0007.cr_crapcob%ROWTYPE;
    rw_crapcop    COBR0007.cr_crapcop%ROWTYPE;

  BEGIN
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;   
          
    -- Processo de Validacao Recusas Padrao
    COBR0007.pc_efetua_val_recusa_padrao(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                        ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                        ,pr_nrcnvcob => pr_nrcnvcob   --> Numero Convenio
                                        ,pr_nrdocmto => pr_nrdocmto   --> Numero Documento
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Data Movimento
                                        ,pr_cdoperad => pr_cdoperad   --> Operador
                                        ,pr_cdinstru => '95'          --> Codigo Instrucao
                                        ,pr_nrremass => pr_nrremass   --> Numero da Remessa
                                        ,pr_rw_crapcob => rw_crapcob  --> Registro de Cobranca de Recusa
                                        ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                        ,pr_dscritic => vr_dscritic); --> Descricao da Critica
    
    --Se ocorrer Erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro de cooperativa nao encontrado.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;
    
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
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro ao atualizar crapcob. ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_canc_sms. ' || SQLERRM;
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
    --  Programa : pc_inst_canc_sms          Antigo: 
    --  Sistema  : Cred
    --  Sigla    : COBR0007
    --  Autor    : Andrino Carlos de Souza Junior
    --  Data     : Setembro/2016                     Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para cancelar envio de SMS
    --
    --   Alteracao : 
    --
    -- ...........................................................................................
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

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
    rw_crapcob    COBR0007.cr_crapcob%ROWTYPE;

  BEGIN
    --Inicializa variaveis erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;   

    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro de cooperativa nao encontrado.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;
    
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
      
      -- Recusar a instrucao
      CLOSE cr_config;
      vr_dscritic := 'Conta nao parametrizada para envio de SMS!';
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
      
      -- Recusar a instrucao
      vr_dscritic := 'Instrucao nao pode ser efetuada apos as 19 horas';
      RAISE vr_exc_erro;
    END IF;
      
    -- Processo de Validacao Recusas Padrao
    COBR0007.pc_efetua_val_recusa_padrao(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                        ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                        ,pr_nrcnvcob => pr_nrcnvcob   --> Numero Convenio
                                        ,pr_nrdocmto => pr_nrdocmto   --> Numero Documento
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Data Movimento
                                        ,pr_cdoperad => pr_cdoperad   --> Operador
                                        ,pr_cdinstru => '95'          --> Codigo Instrucao
                                        ,pr_nrremass => pr_nrremass   --> Numero da Remessa
                                        ,pr_rw_crapcob => rw_crapcob  --> Registro de Cobranca de Recusa
                                        ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                        ,pr_dscritic => vr_dscritic); --> Descricao da Critica
    
    --Se ocorrer Erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Levantar Excecao
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
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar crapsab. ' || SQLERRM;
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
          
        -- Recusar a instrucao
        vr_dscritic := 'Celular do sacado nao encontrado. Favor efetuar o cadastro!';
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
          
          -- Recusar a instrucao
          CLOSE cr_param;
          vr_dscritic := 'Cooperativa nao permite envio de linha digitavel no SMS!';
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
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar crapcob. ' || SQLERRM;
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
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro ao atualizar crapsab. ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina COBR0007.pc_inst_envio_sms. ' || SQLERRM;
  END pc_inst_envio_sms;

END COBR0007;
/
