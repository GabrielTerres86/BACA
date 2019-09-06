CREATE OR REPLACE PACKAGE CECRED.EMPR0017 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0017
  --  Sistema  : Rotinas focando nos parametros de segmento de emprestimo
  --  Sigla    : EMPR
  --  Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  --  Data     : Dez/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Fornecer Parametros para configurar segmentos de crédito
  --
  --
  --			23/07/2019 - Removido filtro de data passado via sessão, criado parametro de data
  --                                 na busca_simulacoes. (P438 Douglas Pagel / AMcom)
  --
  --
  ---------------------------------------------------------------------------------------------------------------

  TYPE typ_dados_contrato_ccb IS RECORD
         (nrdconta NUMBER(10),   -- num conta
          nrctremp NUMBER(10),   -- num contrato
          nmextcop VARCHAR2(50), -- nome coop
          nrdocnpj NUMBER(25),   -- cnpj coop
          dsendcop VARCHAR2(40), -- endereco
          nrendcop NUMBER(10), --numero
          nrcepend NUMBER(10), --cep
          nmcidade VARCHAR2(25), -- cidade
          nmpessoa VARCHAR2(25), -- nome contratante
          nrcpfcgc NUMBER(15) -- cpf/cnpj contratante
          );

  --/
  FUNCTION fn_get_cr_crapdat(pr_cdcooper IN crapcop.cdcooper%TYPE) 
    RETURN BTCH0001.cr_crapdat%ROWTYPE;
  --
  --/
  PROCEDURE pc_valida_horario_ib(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                 pr_des_reto OUT VARCHAR,
                                 pr_dscritic OUT VARCHAR2);
          

  PROCEDURE insere_tag(pr_xml      IN OUT NOCOPY XMLType  --> XML que receberá a nova TAG
                      ,pr_tag_pai  IN VARCHAR2            --> TAG que receberá a nova TAG
                      ,pr_posicao  IN PLS_INTEGER         --> Posição da tag na lista
                      ,pr_tag_nova IN VARCHAR2            --> String com a nova TAG
                      ,pr_tag_cont IN VARCHAR2            --> Conteúdo da nova TAG
                      ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_consulta_param_segmentos (pr_cdcooper crapcop.cdcooper%TYPE
       /*consulta_parametros_segmento*/ ,pr_idsegmento NUMBER
                                        ,pr_tppessoa NUMBER
                                        ,pr_retorno OUT XMLType
                                        ,pr_des_reto OUT VARCHAR
                                         );

  /* Imprime o demonstrativo do contrato de emprestimo (Modelo CCB) */
  PROCEDURE pc_gera_demonst_contrato(pr_cdcooper  IN crawepr.cdcooper%TYPE --> Código da Cooperativa
                                    ,pr_nrdconta  IN crawepr.nrdconta%TYPE --> numero da conta
                                    ,pr_nrctremp  IN crawepr.nrctremp%TYPE --> numero do contrato
                                    ,pr_flgarantia IN NUMBER                --> indica se garantia(1) ou nao(0)
                                    ,pr_des_reto  OUT VARCHAR2
                                    ,pr_xml       OUT xmltype) ;


  PROCEDURE pc_calcula_simulacao( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                 ,pr_cdorigem IN INTEGER  --> Codigo da origem do canal
                                 ,pr_cdoperad IN VARCHAR2  --> Codigo do operador
                                 ,pr_nrcpfope IN VARCHAR2 --> numero do CPF do operador
                                 ,pr_nripuser IN VARCHAR2 --> IP de acesso do cooperado
                                 ,pr_iddispos IN VARCHAR2 --> ID do dispositivo móvel
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código de PA do canal de atendimento – Valor '90' para Internet
                                 ,pr_nrdcaixa IN INTEGER  --> Código de caixa do canal de atendimento – Valor fixo '900' para Internet
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta do Cooperado
                                 ,pr_idseqttl IN INTEGER --> Titularidade do Cooperado
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do Movimento
                                 ,pr_flgerlog IN NUMBER --> Flag de Geração de Log (O campo não deve ser exposto no barramento e deverá assumir o valor “true” como default.
                                 ,pr_cddopcao IN VARCHAR --> Identificador da Operação (SOA deve manter o valor “I” como default e não expor o campo ao consumidor do operador.
                                 ,pr_cdlcremp IN INTEGER --> Id identificador da Linha de crédito da Simulação
                                 ,pr_vlemprst IN NUMBER --> Valor do Empréstimo
                                  --,pr_qtsimula IN INTEGER --> Quantidade de Simulações
                                 ,pr_tp_simulacao IN INTEGER --> (1-Padrão, 2-Unica, 3-Máxima)
                                 ,pr_qtparc   IN INTEGER --> quantidade de parcelas
                                 ,pr_dtlibera IN DATE default null-->
                                 ,pr_dtdpagto IN DATE --> Data de Pagamento
                                 --,pr_cdfinemp IN INTEGER --> Código Finalidade do Empréstimo
                                 ,pr_idfiniof IN INTEGER --> Financia IOF (1=Sim e 0 Não)
                                 ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                 ,pr_flggrava IN NUMBER DEFAULT 0 --> Flag para definir se deve ser salva a simulação (1=Sim e 0 Não)
                                 ,pr_idsegmento tbepr_segmento.idsegmento%TYPE --> Id identificador do Segmento da Simulação
                                 ,pr_idpessoa IN INTEGER  --> ID identificador do cadastro da pessoa referente ao cooperado da simulação
                                 ,pr_nrseq_email IN INTEGER --> ID de e-mail cooperado (Informado na Simulação – Conta On-line)
                                 ,pr_nrseq_telefone IN INTEGER  --> ID de Telefone do cooperado (Informado na Simulação – Conta On-line)
                                 ,pr_idsubsegmento  IN tbepr_subsegmento.idsubsegmento%TYPE --> Id identificador do SubSegmento da Simulação
                                 ,pr_idmarca IN NUMBER DEFAULT NULL --> identificador da marca na tabela fipe
                                 ,pr_dsmarca IN VARCHAR2 DEFAULT NULL --> descricao da marca na tabela fipe
                                 ,pr_idmodelo IN NUMBER DEFAULT NULL --> identificador do modelo na tabela fipe
                                 ,pr_dsmodelo IN VARCHAR2 DEFAULT NULL --> descricao do modelo na tabela fipe
                                 ,pr_dsano_modelo IN VARCHAR2 DEFAULT NULL --> ano/modelo do bem
                                 ,pr_dscatbem IN VARCHAR2 DEFAULT NULL --> descrico da categoria do bem
                                 ,pr_cdfipe IN VARCHAR2 DEFAULT NULL --> codigo fipe
                                 ,pr_vlfipe IN NUMBER DEFAULT NULL --> valor fipe
                                 ,pr_vlbem IN NUMBER DEFAULT NULL --> valor declarado do bem
                                 ,pr_retorno OUT xmltype --> XML de retorno das simulações
                                 );

  --/ procedure para consulta de simulacoes
  PROCEDURE pc_consulta_simulacoes(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                  ,pr_cdorigem IN INTEGER   -- Identificador do CANAL de origem da Consulta – Valor fixo '3' para Internet
                                  ,pr_cdoperad IN VARCHAR2   -- codigo do operador
                                  ,pr_nrcpfope IN VARCHAR2  -- Número do CPF do operador do InternetBank
                                  ,pr_nripuser IN VARCHAR2  -- IP de acesso do cooperado
                                  ,pr_iddispos IN VARCHAR2  -- ID do dispositivo móvel
                                  ,pr_cdagenci IN crapass.cdagenci%TYPE  -- Código de PA do canal de atendimento – Valor '90' para Internet
                                  ,pr_nrdcaixa IN INTEGER     -- Código de caixa do canal de atendimento – Valor fixo '900' para Internet
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE     -- Número da Conta do Cooperado
                                  ,pr_idseqttl IN INTEGER                   -- Titularidade do Cooperado
                                  ,pr_dtmvtolt_ini IN crapdat.dtmvtolt%TYPE -- Data de início para pesquisa
                                  ,pr_dtmvtolt_fim IN crapdat.dtmvtolt%TYPE -- Data fim para pesquisa
                                  ,pr_flgerlog IN NUMBER  --  Flag de Geração de Log (O campo não deve ser exposto no barramento e deverá assumir o valor “true” como default.
                                  ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                  ,pr_idsegmento IN tbepr_segmento.idsegmento%TYPE --> Id identificador do Segmento da Simulação
                                  ,pr_retorno OUT xmltype  --> retorno do tipo xml
                                  );

  --/ procedure para consulta de simulacao
  PROCEDURE pc_consulta_simulacao(pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo da cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE -- Número da Conta do Cooperado
                                 ,pr_cdorigem IN INTEGER -- Identificador do CANAL de origem da Consulta – Valor fixo '3' para Internet
                                 ,pr_cdoperad IN VARCHAR2 -- codigo do operador
                                 ,pr_nrcpfope IN VARCHAR2 -- Número do CPF do operador do InternetBank
                                 ,pr_nripuser IN VARCHAR2 --  IP de acesso do cooperado
                                 ,pr_iddispos IN VARCHAR2 -- ID do dispositivo móvel
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE  -- Código de PA do canal de atendimento – Valor '90' para Internet
                                 ,pr_nrdcaixa IN INTEGER -- Código de caixa do canal de atendimento – Valor fixo '900' para Internet
                                 ,pr_nrsimula IN crapsim.nrsimula%TYPE
                                 ,pr_flgerlog IN NUMBER -- Flag de Geração de Log (O campo não deve ser exposto no barramento e deverá assumir o valor “true” como default.
                                 ,pr_des_reto OUT VARCHAR  -- Retorno OK / NOK
                                 ,pr_retorno OUT xmltype -- retorno do tipo xml
                                 );

  --/ procedure para consulta de propostas
  PROCEDURE pc_consulta_propostas(pr_cdcooper IN crapcop.cdcooper%TYPE              --  Código da Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE              --  Número da Conta do Cooperado
                                 ,pr_idseqttl IN INTEGER                            --  Titularidade do Cooperado
                                 ,pr_cdoperad IN VARCHAR2                            --  codigo do operador
                                 ,pr_nrcpfope IN VARCHAR2                           --  Número do CPF do operador do InternetBank
                                 ,pr_nripuser IN VARCHAR2                           --  IP de acesso do cooperado
                                 ,pr_iddispos IN VARCHAR2                           --  ID do dispositivo móvel
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE              --  Código de PA do canal de atendimento – Valor '90' para Internet
                                 ,pr_nrdcaixa IN NUMBER                             --  Código de caixa do canal de atendimento – Valor fixo '900' para Internet
                                 ,pr_dtmvtolt_ini IN crapdat.dtmvtolt%TYPE          --  Data de início para pesquisa
                                 ,pr_dtmvtolt_fim IN crapdat.dtmvtolt%TYPE          --  Data de fim para pesquisa
                                 ,pr_situacao IN NUMBER DEFAULT NULL                --  Situação da Proposta (0 – Em Análise,1 – Aprovado,2 – Concluído,3 – Expirado,4 – Cancelado)
                                 ,pr_cdorigem crawepr.cdorigem%TYPE                 --  Identificador do CANAL de origem da Consulta – Valor fixo '3' para Internet
                                 ,pr_flgerlog IN NUMBER                             --  Flag de Geração de Log (O campo não deve ser exposto no barramento e deverá assumir o valor “true” como default.
                                 ,pr_des_reto OUT VARCHAR                           --> Retorno OK / NOK
                                 ,pr_idsegmento IN tbepr_segmento .idsegmento%TYPE  --> Id identificador do Segmento da Simulação
                                 ,pr_retorno OUT xmltype                            --> retorno do tipo xml
                                 );

  --/ procedure para consulta de proposta
  PROCEDURE pc_consulta_proposta(pr_cdcooper IN  crapcop.cdcooper%TYPE -- Código da Cooperativa
                                ,pr_nrdconta IN  crapass.nrdconta%TYPE -- Número da Conta do Cooperado
                                ,pr_cdoperad IN  VARCHAR2               -- Operador a qual a proposta deve ser vinculada – Valor '996' para Internet
                                ,pr_nrcpfope IN  VARCHAR2              -- Número do CPF do operador do InternetBank
                                ,pr_nripuser IN  VARCHAR2              -- IP de acesso do cooperado
                                ,pr_iddispos IN  VARCHAR2              -- ID do dispositivo móvel
                                ,pr_cdagenci IN  crapass.cdagenci%TYPE -- Código de PA do canal de atendimento – Valor '90' para Internet
                                ,pr_nrdcaixa IN  INTEGER               -- Código de caixa do canal de atendimento – Valor fixo '900' para Internet
                                ,pr_nrctremp IN  crawepr.nrctremp%TYPE -- Número do Contrato de Empréstimo
                                ,pr_flgerlog IN  NUMBER                -- Flag de Geração de Log (O campo não deve ser exposto no barramento e deverá assumir o valor “true” como default
                                ,pr_des_reto OUT VARCHAR               --> Retorno OK / NOK
                                ,pr_retorno  OUT XMLTYPE
                                );

  FUNCTION fn_retorna_telefone(pr_idpessoa tbcadast_pessoa.idpessoa%TYPE
                              ,pr_nrseq_telefone tbcadast_pessoa_telefone.nrseq_telefone%TYPE)
      RETURN VARCHAR2 ;

  FUNCTION fn_retorna_email(pr_idpessoa IN tbcadast_pessoa.idpessoa%TYPE
                           ,pr_nrseq_email tbcadast_pessoa_email.nrseq_email%TYPE)
                           RETURN VARCHAR2;


  --/ procedure gerar proposta de emprestimo
  PROCEDURE pc_gera_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_nrdconta IN crapass.nrdconta%TYPE
                            ,pr_cdorigem IN crawepr.cdorigem%TYPE
                            ,pr_cdoperad IN crawepr.cdoperad%TYPE --> Codigo do operador
                            ,pr_nrcpfope IN VARCHAR2
                            ,pr_nripuser IN VARCHAR2
                            ,pr_iddispos IN VARCHAR2
                            ,pr_cdagenci IN crapass.cdagenci%TYPE
                            ,pr_nrdcaixa IN INTEGER
                            ,pr_nrsimula IN crapsim.nrsimula%TYPE
                            ,pr_flgerlog IN NUMBER
                            ,pr_des_reto OUT VARCHAR  --> Retorno OK / NOK
                            ,pr_retorno  OUT xmltype);

  PROCEDURE pc_grava_proposta(pr_cdcooper IN crawepr.cdcooper%TYPE               --> Codigo da cooperativa
                             ,pr_nrdconta IN crawepr.nrdconta%TYPE              --> Conta do Associado
                             ,pr_cdorigem crawepr.cdorigem%TYPE
                             ,pr_nrctremp IN crawepr.nrctremp%TYPE Default 0    --> Número da proposta
                             ,pr_vlfinanciado IN crawepr.vlemprst%TYPE  --> Valor financiado
                             ,pr_vlsolicitado IN crawepr.vlemprst%TYPE  --> Valor financiado
                             ,pr_qtparcelas     IN crawepr.qtpreemp%TYPE  --> Quantidade de parcelas
                             ,pr_vlparcela      IN crawepr.vlpreemp%TYPE  --> Valor de cada parcela
                             ,pr_pecet_operacao IN crawepr.percetop%TYPE  --> Custo efetivo total (CET) da operacao ao ano
                             ,pr_cdoperad           IN crawepr.cdoperad%TYPE  --> Codigo do operador
                             ,pr_inrisco_calculado  IN NUMBER Default null --> Nivel de risco calculado
                             ,pr_inrisco_proposta   IN NUMBER Default null --> Nivel de risco da proposta
                             ,pr_dtvencto_operacao  IN DATE Default null --> Data de vencimento da operacao
                             ,pr_dtdpagto           IN DATE DEFAULT NULL --> Data de vencimento da primeira parcela
                             ,pr_vlsaldo_devedor    IN crawepr.vlemprst%TYPE Default null --> Valor de Saldo Devedor do Contrato.
                             ,pr_vltarifa           IN NUMBER Default null --> Valor da tarifa.
                             ,pr_vliofcontrato      IN NUMBER Default null --> Valor do IOF na efetivação do contrato.
                             ,pr_insitctr           IN crawepr.insitapr%TYPE  --> Situacoes do contrato 1-Proposta, 2-Contrato , 3-Liquidada e 4-Excluida
                             ,pr_nrprotocolo        IN VARCHAR2 Default null --> Protocolo da IBRATAN
                             ,pr_cdlcremp           IN crawepr.cdlcremp%TYPE
                             ,pr_dtvencto           IN DATE
                             ,pr_cdagenci           IN crawepr.cdagenci%TYPE
                             ,pr_cdfinemp           IN crapsim.cdfinemp%TYPE
                             ,pr_nrsimula           IN crapsim.nrsimula%TYPE
                             ,pr_dtlibera           IN crapsim.dtlibera%TYPE
                             ,pr_idfiniof           IN crapsim.idfiniof%TYPE
                              ----------------- > OUT < ----------------------
                             ,pr_cdcritic OUT INTEGER                                             --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2                                            --> Descrição da crítica
                              );

   PROCEDURE pc_busca_nrcontrato(pr_cdcooper     IN crawepr.cdcooper%TYPE        --> Codigo da cooperativa
                                ,pr_nrdconta     IN crawepr.nrdconta%TYPE        --> Conta do Associado
                                 ----------------- > OUT < ----------------------
                                ,pr_nrctremp     OUT crawepr.nrctremp%TYPE  --> Número do Contrato
                                ,pr_cdcritic     OUT INTEGER                                       --> Código da crítica
                                ,pr_dscritic     OUT VARCHAR2                                      --> Descrição da crítica
                                 );

  PROCEDURE pc_solicita_contratacao(pr_cdcooper  IN crapcop.cdcooper%TYPE       --Codigo Cooperativa                                                                                            
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE       --Numero da Conta do Associado
                                   ,pr_nrctremp  IN INTEGER                     --Numero Contrato Emprestimo
                                   ,pr_cdoperad IN VARCHAR2
                                   ,pr_nrcpfope IN VARCHAR2
                                   ,pr_nripuser IN VARCHAR2
                                   ,pr_iddispos IN VARCHAR2
                                   ,pr_cdagenci IN crapass.cdagenci%TYPE
                                   ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE     --> Numero do caixa
                                   ,pr_cdorigem IN crawepr.cdorigem%TYPE
                                   -->> SAIDA
                                   ,pr_des_reto OUT VARCHAR  --> Retorno OK / NOK
                                   ,pr_retorno OUT xmltype);
                                   
  PROCEDURE pc_solicita_contrata_PROG(pr_cdcooper  IN crapcop.cdcooper%TYPE       --Codigo Cooperativa                                                                                            
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE       --Numero da Conta do Associado                               
                                     ,pr_nrctremp  IN INTEGER                     --Numero Contrato Emprestimo
                                     ,pr_cdoperad IN VARCHAR2
                                     ,pr_nrcpfope IN VARCHAR2 
                                     ,pr_nripuser IN VARCHAR2 
                                     ,pr_iddispos IN VARCHAR2 
                                     ,pr_cdagenci IN crapass.cdagenci%TYPE 
                                     ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE     --> Numero do caixa
                                     ,pr_cdorigem IN crawepr.cdorigem%TYPE
                                     -->> SAIDA                                  
                                     ,pr_des_reto OUT VARCHAR  --> Retorno OK / NOK
                                     ,pr_retorno OUT CLOB);                                   

  -- Cria notificações
  PROCEDURE pc_cria_notificacao(pr_cdcooper IN crawepr.cdcooper%TYPE            --> Codigo da cooperativa
                               ,pr_nrdconta IN crawepr.nrdconta%TYPE            --> Conta do Associado
                               ,pr_nrctremp IN crawepr.nrctremp%TYPE            --> Número da proposta
                               ,pr_tporigem IN NUMBER DEFAULT 0 --  (0) motor - (1) esteira - (2) efetivacao
                               ,pr_des_reto OUT VARCHAR  --> Retorno OK / NOK
                               );

  FUNCTION get_dssituacao(pr_situacao INTEGER) RETURN VARCHAR2;

  --/ Procedure para validar transacoes pendentes 
  PROCEDURE pc_solicita_contratacao_ib(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                      ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código de PA do canal de atendimento – Valor '90' para Internet
                                      ,pr_nrdcaixa IN INTEGER  --> Código de caixa do canal de atendimento – Valor fixo '900' para Internet
                                      ,pr_cdoperad IN VARCHAR2  --> Codigo do operador
                                      ,pr_nripuser IN VARCHAR2 --> IP de acesso do cooperado
                                      ,pr_iddispos IN VARCHAR2 --> ID do dispositivo móvel
                                      ,pr_nmdatela IN VARCHAR2 --> Codigo do operador
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta do Cooperado
                                      ,pr_idseqttl IN INTEGER --> Titularidade do Cooperado 
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do Movimento
                                      ,pr_nrcpfope IN VARCHAR2 --> numero do CPF do operador
                                      ,pr_cdorigem IN INTEGER  --> Codigo da origem do canal
                                      ,pr_cdcoptfn IN INTEGER
                                      ,pr_cdagetfn IN INTEGER
                                      ,pr_nrterfin IN INTEGER 
                                      ,pr_nrctremp IN NUMBER
                                      ,pr_des_reto OUT VARCHAR  --> Retorno OK / NOK 
                                      ,pr_dscritic OUT VARCHAR2
                                      ,pr_idastcjt OUT INTEGER
                                      ,pr_qtminast OUT NUMBER
                                       );

  --/ Procedure para validar transacoes pendentes 
  PROCEDURE pc_assinatura_contrato(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código de PA do canal de atendimento – Valor '90' para Internet                                  
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta do Cooperado
                                  ,pr_idseqttl IN INTEGER --> Titularidade do Cooperado 
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do Movimento
                                  ,pr_cdorigem IN INTEGER  --> Codigo da origem do canal
                                  ,pr_nrctremp IN NUMBER   --> numero o contrato de emprestimo
                                  ,pr_tpassinatura IN NUMBER --> tipo de assinatura (1 socio/2 - cooperativa)                                  
                                  ,pr_des_reto OUT VARCHAR  --> Retorno OK / NOK 
                                  ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_verifica_linha_segmento(pr_cdcooper  IN crawepr.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_cdlcremp  IN INTEGER               --> Id identificador da Linha de crédito
                                      ,pr_cdfinemp  IN INTEGER               --> Id identificador da Finalidade de crédito
                                      ,pr_flgativo OUT INTEGER               --> [0 - NAO ATIVO] / [1 - ATIVO]
                                      ,pr_cdcritic OUT INTEGER               --> Código de críticia
                                      ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica
       
  PROCEDURE pc_inclui_proposta_esteira(pr_cdcooper IN crapcop.cdcooper%TYPE
                                      ,pr_cdagenci IN crapass.cdagenci%TYPE 
                                      ,pr_cdoperad IN crawepr.cdoperad%TYPE --> Codigo do operador                                                             
                                      ,pr_cdorigem IN crawepr.cdorigem%TYPE            
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE 
                                      ,pr_nrctremp IN crawepr.nrctremp%TYPE
                                      ,pr_dtmvtolt IN DATE
                                      ,pr_des_reto OUT VARCHAR2 
                                       ) ;
 
  PROCEDURE pc_start_motor(pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE 
                          ,pr_nrctremp IN crawepr.nrctremp%TYPE
                          ,pr_job_reenvio IN NUMBER DEFAULT 0);
  
  PROCEDURE pc_aciona_motor(pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_nrdconta IN crapass.nrdconta%TYPE 
                           ,pr_nrctremp IN crawepr.nrctremp%TYPE
                           ,pr_timestamp IN TIMESTAMP WITH TIME ZONE DEFAULT NULL
                           ,pr_job_reenvio IN BOOLEAN DEFAULT FALSE);

  PROCEDURE pc_email_esteira(pr_cdcooper IN NUMBER,
                             pr_nrdconta IN NUMBER,
                             pr_nrctremp IN NUMBER);

       
END EMPR0017;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0017 AS
  --
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0017
  --  Sistema  : CREDITO
  --  Sigla    : EMPR
  --  Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  --  Data     : Dez/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Rotinas focando no processo de simulação/contratação de emprestimo
  --
  -- Alterações:
  --
  --            16/07/2019 - PRJ 438 - Alterado rotinas pc_start_motor, pc_aciona_motor para controle de reenvio de analise pelo JOB
  --                         Rafael Rocha (AmCom)

  --
  --            04/09/2019 - Adicionaro efetivacao Rating na efetivacao da proposta 
  --                         na pc_solicita_contratacao (Luiz Otávio Olinger Momm - AMCOM)
  --
  ---------------------------------------------------------------------------------------------------------------
  --
  -- variáveis globais
  vg_xml_retorno xmltype;
  vtexto VARCHAR2(32000);
  vr_exc_erro EXCEPTION;
  vr_rowid    ROWID;
  --
  FUNCTION fn_get_cr_crapdat(pr_cdcooper IN crapcop.cdcooper%TYPE) 
    RETURN BTCH0001.cr_crapdat%ROWTYPE IS
  --/
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
  
  BEGIN
    --/
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
    --/
    RETURN rw_crapdat;
    
  EXCEPTION WHEN OTHERS
    THEN
      RETURN rw_crapdat;
  END fn_get_cr_crapdat;

  --> Funcao para formatar o numero em decimal conforme padrao da SOA
  FUNCTION fn_decimal_soa (pr_numero IN number) RETURN VARCHAR2 is
  BEGIN
    RETURN to_char(pr_numero,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''');
  END fn_decimal_soa;
  --
  --> Funcao para formatar data hora conforme padrao da SOA
  FUNCTION fn_Data_soa (pr_data IN DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN to_char(pr_data,'DD/MM/RRRR');
  END fn_Data_soa;
  --
  -- Verifica se a linha de crédito está vinculada a um subsegmento com garantia
  FUNCTION fn_tem_garantia(pr_cdcooper crapcop.cdcooper%TYPE, pr_cdlcremp craplcr.cdlcremp%TYPE) RETURN BOOLEAN IS
    vr_count NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO vr_count
      FROM tbepr_subsegmento sub
     WHERE sub.cdcooper = pr_cdcooper
       AND sub.cdlinha_credito = pr_cdlcremp
       AND sub.flggarantia = 1;
    RETURN ( vr_count > 0 );
  END fn_tem_garantia;
  --/   
  PROCEDURE pc_valida_horario_ib(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                 pr_des_reto OUT VARCHAR,
                                 pr_dscritic OUT VARCHAR2) IS
  --/
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_valida_horario_ib
  --  Sistema  : CREDITO
  --  Sigla    : EMPR
  --  Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  --  Data     : Março/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Validar horario de operações pelo canal INTERNET
  --             
  ---------------------------------------------------------------------------------------------------------------														
  --
   vr_hhcpaini    VARCHAR2(5); -- HH:MM
   vr_hhcpafim    VARCHAR2(5); -- HH:MM   
   --Tipo de registro do tipo data
   rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
   vr_exc_erro EXCEPTION;
   vr_dscritic VARCHAR2(4000);
   --
   --
   PROCEDURE pc_set_horario_disp(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                 pr_hhcpaini IN OUT VARCHAR2,
                                 pr_hhcpafim IN OUT VARCHAR2) IS
   --
   vr_dstextab    craptab.dstextab%TYPE;  
   --
   BEGIN
    --/
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'HRCTRPREAPROV'
                                             ,pr_tpregist => 90);
    --/    
    pr_hhcpaini := gene0002.fn_converte_time_data(gene0002.fn_busca_entrada(1,vr_dstextab,' '));
    pr_hhcpafim := gene0002.fn_converte_time_data(gene0002.fn_busca_entrada(2,vr_dstextab,' '));

   END pc_set_horario_disp;     
   --
   --/
   FUNCTION fn_valida_horario(pr_hhcpaini IN VARCHAR2,pr_hhcpafim IN VARCHAR2) RETURN BOOLEAN IS
   --
   vr_hrmin_sysdate  TIMESTAMP;
   vr_hrmin_ini      TIMESTAMP;
   vr_hrmin_fim      TIMESTAMP;
   --
   --/
   BEGIN
    --
    --/   
    SELECT TO_DATE(TO_CHAR(SYSDATE,'HH24:MI'),'HH24:MI') 
      INTO vr_hrmin_sysdate
      FROM dual;
    --/
    SELECT TO_DATE(pr_hhcpaini,'HH24:MI')
      INTO vr_hrmin_ini
      FROM dual; 
    --/
    SELECT TO_DATE(pr_hhcpafim,'HH24:MI')
      INTO vr_hrmin_fim
      FROM dual;
    --/  
    RETURN ( vr_hrmin_sysdate BETWEEN vr_hrmin_ini AND vr_hrmin_fim );
     
   EXCEPTION WHEN OTHERS
     THEN
      RETURN TRUE;
   END fn_valida_horario;
   --
   --/
  BEGIN
    --/
    pr_des_reto :='OK';
    pr_dscritic := NULL;
    --
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Montar mensagem de critica
        CLOSE BTCH0001.cr_crapdat;
        pr_des_reto :='NOK';
        vr_dscritic := 'Cooperativa invalida.';
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
    END IF;
    --/
    pc_set_horario_disp(pr_cdcooper,vr_hhcpaini,vr_hhcpafim);
    --  
    --/
    IF ( vr_hhcpaini IS NULL OR vr_hhcpafim IS NULL )
      THEN
        pr_des_reto :='NOK';
        vr_dscritic := 'Parametros de Horario nao cadastrado.';
        RAISE vr_exc_erro;
    END IF;
    --
    --/    
    IF NOT ( fn_valida_horario(vr_hhcpaini,vr_hhcpafim) )
      THEN
        pr_des_reto :='NOK';
        vr_dscritic := 'Operacao permitida das '||vr_hhcpaini||' as '||vr_hhcpafim;
        RAISE vr_exc_erro;
    END IF;
    --/  
  EXCEPTION 
    WHEN vr_exc_erro
      THEN
        pr_des_reto :='NOK';
        pr_dscritic := vr_dscritic;
    WHEN OTHERS
      THEN
        pr_des_reto :='NOK';
        pr_dscritic := 'Erro nao esperado na empr0017.pc_valida_horario_ib '||SQLERRM;
  END pc_valida_horario_ib;
  
  --/ 
  FUNCTION get_dscritic(pr_cdcritic crapcri.cdcritic%TYPE) RETURN VARCHAR2 IS   
   --/   
   BEGIN

    RETURN nvl(gene0001.fn_busca_critica(pr_cdcritic),NULL);

   EXCEPTION WHEN OTHERS
     THEN
       RETURN NULL; 
  END get_dscritic;
  --
  --/
  PROCEDURE monta_textofim_html(pr_site IN VARCHAR2,
                                pr_tel_ouvid IN VARCHAR2,
                                pr_tel_ura IN VARCHAR2,
                                pr_nm_contratante IN VARCHAR2,
                                pr_nm_coop IN VARCHAR2,
                                pr_cdcooper IN tbepr_assinaturas_contrato.cdcooper%TYPE,
                                pr_nrdconta IN tbepr_assinaturas_contrato.nrdconta%TYPE,
                                pr_nrctremp IN tbepr_assinaturas_contrato.nrctremp%TYPE
                                 ) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : monta_textofim_html
  --  Sistema  : CREDITO
  --  Sigla    : EMPR
  --  Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  --  Data     : Dez/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Rotina focando no apoio a formatação do documento CCB NO JASPER crrl772_contrato_ccb
  --
  -- Alterações: 08/08/2019 - Ajuste no número de telefone para Tele Atendimento e Ouvidoria e 
  --                          incluido site por parametro na clausula 18. (Douglas Pagel / AMcom) 
  --
  ---------------------------------------------------------------------------------------------------------------
  --/  
  c_dia CONSTANT VARCHAR2(12) := to_char(SYSDATE,'dd/mm/yyyy');
  c_hora_min CONSTANT VARCHAR2(12) := to_char(SYSDATE,'hh24:mi:ss');
  --/
  BEGIN
      vtexto := '<html>
                <body>';

      vtexto := vtexto|| '<b>2.  Promessa de Pagamento</b> – Por meio do presente <b>CONTRATO DE EMPR&Eacute;STIMO/FINANCIAMENTO AO COOPERADO</b>, doravante denominado simplesmente <b>Contrato</b>, firmado de forma física ou eletrônica (atrav&eacute;s de todos os Canais de Autoatendimento disponibilizados pela <b>Cooperativa</b>, mediante utiliza&ccedil;&atilde;o de senha num&eacute;rica e letras de seguran&ccedil;a), a <b>Cooperativa</b> concede o presente empr&eacute;stimo, solicitado e contratado pelo(a) <b>Contratante</b>, nas condi&ccedil;ões estabelecidas no item 1 e nos respectivos subitens das Condi&ccedil;ões Específicas previstas deste <b>Contrato</b>.';
      vtexto := vtexto||'<br>'||'
      <b>2.1</b>  O(A) <b>Contratante</b>, promete pagar em moeda corrente nacional, à <b>Cooperativa</b> ou à sua ordem, a dívida em dinheiro, certa, líquida e exigível correspondente ao valor total emprestado, indicado no subitem 1.3. das Condi&ccedil;ões Específicas da <b>Contrato</b>, acrescido de todos os encargos pactuados no decorrer deste instrumento contratual.';
      vtexto := vtexto||'<br>'||'
      <b>3.  </b><u><b>Empr&eacute;stimo</b></u> - O cr&eacute;dito ora solicitado pelo <b>Contratante</b> e concedido pela <b>Cooperativa</b> &eacute; um empr&eacute;stimo em dinheiro, com pagamento em parcelas, na quantidade e valor contratados pelo <b>Contratante</b>.';
      vtexto := vtexto||'<br>'||'
      <b>3.1</b>  O(A) <b>Contratante</b> reconhece que todos os atos praticados mediante aposi&ccedil;&atilde;o de senha num&eacute;rica e letras de seguran&ccedil;a, ser&atilde;o registrados e arquivados em meios magn&eacute;ticos, sendo reconhecidos, para todos os fins de direito, como assinatura digital, como válidos, verdadeiros e processados por meios seguros e constituir&atilde;o meio eficaz e prova inequívoca de concordância com o empr&eacute;stimo ora realizado.';
      vtexto := vtexto||'<br>'||'
      <b>4.</b>  <u><b>Valor Contratado</b></u> - A <b>Cooperativa</b> entregará ao <b>Contratante</b> o valor indicado nas Condi&ccedil;ões Específicas acima, mediante cr&eacute;dito na conta corrente indicada no subitem 1.1, que o(a) mesmo(a), na qualidade de associado(a), mant&eacute;m junto à <b>Cooperativa</b>.';
      vtexto := vtexto||'<br>'||'
      <b>4.1</b>  O(A) <b>Contratante</b> autoriza, desde já, que o cr&eacute;dito acima mencionado, poderá ser utilizado pela <b>Cooperativa</b> para liquida&ccedil;&atilde;o de eventuais saldos devedores de outras obriga&ccedil;ões financeiras vinculadas a conta corrente indicada no item 1.1 ou assumidas perante terceiros na condi&ccedil;&atilde;o de devedor solidário.';
      vtexto := vtexto||'<br>'||'
      <b>5.</b>  <u><b>Pagamento</b></u> - O <b>Contratante</b> deverá pagar a <b>Cooperativa</b> o valor total contratado, sendo que o referido valor será acrescido dos juros remuneratórios, capitalizados mensalmente à taxa estipulada neste <b>Contrato</b>.  Al&eacute;m dos encargos previstos ser&atilde;o devidas eventuais taxas de servi&ccedil;os, na forma do estabelecido nas normas regulamentares da <b>Credora/Cooperativa</b>.';
      vtexto := vtexto||'<br>'||'
      <b>5.1</b>  O valor de cada parcela foi calculado com base na Tabela Price, sistema de amortiza&ccedil;&atilde;o de dívida, em que o percentual de principal e o percentual de juros de cada parcela variam no decorrer do tempo, de modo a manter-se constante o valor de cada parcela.';
      vtexto := vtexto||'<br>'||'
      <b>5.2</b>  A cada mês, nas datas indicadas neste <b>Contrato</b>, ocorrerá o d&eacute;bito na conta corrente do(a) <b>Contratante</b> indicada no item 1.1, do valor correspondente à parcela mensal devida, acrescida dos respectivos encargos fixos, bem como, dos valores decorrentes de atrasos/mora, se for o caso, IOF, tarifas e demais despesas previstas.';
      vtexto := vtexto||'<br>'||'
      <b>5.3</b>  Sempre que o dia do vencimento da parcela n&atilde;o ocorrer em dia útil, será prorrogado para o dia útil seguinte.';
      vtexto := vtexto||'<br>'||'
      <b>5.4</b> Na data do pagamento da parcela, o(a) <b>Contratante</b> obriga-se a manter, na conta indicada para pagamento, saldo disponível e suficiente para suportar os d&eacute;bitos ora autorizados, sendo que a insuficiência de saldo configurará atraso no pagamento e incidência dos encargos moratórios.';
      vtexto := vtexto||'<br>'||'
      <b>5.5</b>  Em caso de atraso no pagamento via d&eacute;bito em conta, no intuito de evitar o acúmulo de encargos de atraso, a <b>Cooperativa</b> verificará diariamente a existência de saldos e, a partir do momento em que a conta do(a) <b>Contratante</b> apresentar saldo disponível, independentemente do valor, realizará o d&eacute;bito, total ou parcial, do valor do saldo devedor da parcela, acrescido dos encargos moratórios conforme previsto neste <b>Contrato</b>, at&eacute; o limite disponível na conta, inclusive, utilizando do limite de cr&eacute;dito, se contratado.';
      vtexto := vtexto||'<br>'||'
      <b>5.6</b>  Na hipótese de n&atilde;o haver saldo suficiente na conta corrente para quitar todas as despesas referidas nesta cláusula, a <b>Cooperativa</b>, conforme previsto no artigo 368 e seguintes do Código Civil Brasileiro, poderá realizar o d&eacute;bito dos respectivos valores em qualquer outra conta de titularidade do(a) <b>Contratante</b> ou ainda, poderá utilizar o valor correspondente às suas aplica&ccedil;ões financeiras, inclusive poupan&ccedil;a programada, para liquida&ccedil;&atilde;o, total ou parcial, do saldo devedor deste <b>Contrato</b>, nos termos do item <b>Garantia Pessoal </b>deste <b>Contrato</b>, sem qualquer necessidade de comunica&ccedil;&atilde;o pr&eacute;via.';
      vtexto := vtexto||'<br>'||'
      <b>5.7</b>  Qualquer resgate ou saque de valores das aplica&ccedil;ões, inclusive poupan&ccedil;a programada, indicadas neste item será creditado na conta escolhida para pagamento, ocasionando amortiza&ccedil;&atilde;o ou liquida&ccedil;&atilde;o do saldo devedor dessa conta.';
      vtexto := vtexto||'<br>'||'
      <b>5.8</b>  Caso n&atilde;o seja verificado o pagamento na data do vencimento, o(a) <b>Contratante</b> estará em atraso e a <b>Cooperativa</b> poderá comunicar o fato à SERASA, ao SPC e a qualquer outro órg&atilde;o encarregado de cadastrar atraso de pagamento e descumprimento de obriga&ccedil;&atilde;o contratual.';
      vtexto := vtexto||'<br>'||'
      <b>5.9</b>  A <b>Cooperativa</b> poderá, a seu crit&eacute;rio, disponibilizar ao <b>Contratante</b> a possibilidade do pagamento das parcelas vencidas e n&atilde;o pagas via boleto bancário. Nesta hipótese, o referido título será emitido pelo Posto de Atendimento mediante solicita&ccedil;&atilde;o do(s) <b>Contratante</b>, ou diretamente via conta online disponível no site da <b>Cooperativa</b>.';
      vtexto := vtexto||'<br>'||'
      <b>5.10</b>   O <b>Contratante</b> pagará Tarifa de Cadastro e o Imposto sobre Opera&ccedil;ões Financeiras (IOF) conforme legisla&ccedil;&atilde;o e tabela de tarifas vigente na <b>Cooperativa</b>, os quais ser&atilde;o financiados e acrescidos ao valor das parcelas.';
      vtexto := vtexto||'<br>'||'
      <b>6.</b> <u><b> Responsabilidade Socioambiental </b></u> – O(A) <b>Contratante</b> declara conhecer a Política de Responsabilidade Socioambiental do Sistema Ailos e cumprir o disposto na legisla&ccedil;&atilde;o referente à Política Nacional do Meio Ambiente, n&atilde;o destinando os recursos decorrentes deste <b>Contrato</b> a quaisquer finalidades e/ou projetos que possam causar danos ambientais e/ou sociais, adotando durante o prazo de vigência deste <b>Contrato</b>, medidas e a&ccedil;ões destinadas a evitar ou corrigir danos causados ao Meio Ambiente, seguran&ccedil;a e medicina do trabalho, mantendo ainda, em situa&ccedil;&atilde;o regular suas obriga&ccedil;ões junto aos órg&atilde;os do meio ambiente.';
      vtexto := vtexto||'<br>'||'
      <b>7.</b> <u><b> Vencimento antecipado  </b></u> - A <b>Cooperativa</b> poderá considerar antecipadamente vencido este <b>Contrato</b> e exigir, de imediato, o pagamento do saldo devedor, se o(a) <b>Contratante</b>:';
      vtexto := vtexto||'<br>'||'
      <b>a)</b>  N&atilde;o cumprir com qualquer das suas obriga&ccedil;ões previstas neste <b>Contrato</b>; ';
      vtexto := vtexto||'<br>'||'
      b)  N&atilde;o realizar o pagamento, na data de vencimento pactuada, de 02 (duas) presta&ccedil;ões mensais consecutivas ou alternadas, independentemente de qualquer notifica&ccedil;&atilde;o judicial ou extrajudicial;';
      vtexto := vtexto||'<br>'||'
      c)  Vier a falecer;';
      vtexto := vtexto||'<br>'||'
      d)  Desenvolver atividades que importem em incentivo à prostitui&ccedil;&atilde;o, que utilizem m&atilde;o de obra infantil, que tenham mantido seus trabalhadores em condi&ccedil;ões análogas à escravid&atilde;o ou crime contra o meio ambiente, salvo se efetuada repara&ccedil;&atilde;o imposta ou quando eventualmente estiver sendo cumprida a pena imposta ao(à) <b>Contratante</b>;';
      vtexto := vtexto||'<br>'||'
      e)   Descumprir qualquer das disposi&ccedil;ões constantes na Política de Responsabilidade Socioambiental do Sistema Ailos.';
      vtexto := vtexto||'<br>'||'
      8.  <b><u> Atraso no Pagamento e Multa </b></u> – Caso ocorra vencimento antecipado ou atraso no pagamento da parcela mensal, ser&atilde;o devidos os juros remuneratórios do período, acrescidos dos respectivos juros moratórios e multa moratória nos percentuais informados nos subitens 1.11. incidentes sobre o valor em atraso e 1.12., incidentes sobre o valor total da parcela vencida e n&atilde;o paga.';
      vtexto := vtexto||'<br>'||'
      8.1  Para fins de cobran&ccedil;a dos juros moratórios e da multa, fica estabelecido o prazo de tolerância previsto no item 1.13, contados da data do vencimento da parcela mensal n&atilde;o paga. Decorrido o prazo indicado, incidir&atilde;o sobre o referido valor os juros moratórios e multa, retroativos a data de vencimento da parcela, sem prejuízo dos demais encargos contratualmente previstos.';
      vtexto := vtexto||'<br>'||'
      8.2  Caso seja necessário realizar a cobran&ccedil;a judicial ou administrativa de quaisquer valores em atraso, o <b>Contratante</b> deverá pagar todas as despesas desta cobran&ccedil;a, incluindo custos de postagem de carta de cobran&ccedil;a, cobran&ccedil;a telefônica, inclus&atilde;o de dados nos cadastros de prote&ccedil;&atilde;o ao cr&eacute;dito, custas e honorários advocatícios. O <b>Contratante</b> tamb&eacute;m poderá reembolsar-se de todos os custos que tiver com a cobran&ccedil;a de qualquer obriga&ccedil;&atilde;o da <b>Cooperativa</b>.';
      vtexto := vtexto||'<br>'||'
      8.3  O recebimento, pela <b>Cooperativa</b>, de determinada parcela n&atilde;o significará quita&ccedil;&atilde;o das anteriores.';
      vtexto := vtexto||'<br>'||'
      9.  <b><u> Liquida&ccedil;&atilde;o Antecipada  </b></u>– O(A) <b>Contratante</b> poderá realizar a liquida&ccedil;&atilde;o antecipada parcial ou total desta opera&ccedil;&atilde;o de cr&eacute;dito, mediante comparecimento a qualquer momento, em um dos Postos de Atendimento da <b>Cooperativa</b> ou diretamente via conta online disponível no site da <b>Cooperativa</b>.';
      vtexto := vtexto||'<br>'||'
      9.1  O(A) <b>Contratante</b> somente poderá realizar a liquida&ccedil;&atilde;o antecipada parcial da opera&ccedil;&atilde;o de cr&eacute;dito, caso a opera&ccedil;&atilde;o de cr&eacute;dito esteja com a situa&ccedil;&atilde;o regular.';
      vtexto := vtexto||'<br>'||'
      9.2  Na hipótese de liquida&ccedil;&atilde;o total ou parcial da opera&ccedil;&atilde;o de cr&eacute;dito contratada, a amortiza&ccedil;&atilde;o do saldo devedor ocorrerá sucessivamente, a crit&eacute;rio do(a) <b>Contratante</b>, em ordem decrescente ou crescente. Na primeira possibilitará a diminui&ccedil;&atilde;o do prazo de pagamento do empr&eacute;stimo e a redu&ccedil;&atilde;o proporcional dos juros pactuados neste <b>Contrato</b> aos dias da antecipa&ccedil;&atilde;o, enquanto a segunda, possibilitará apenas a redu&ccedil;&atilde;o proporcional dos juros pactuados neste <b>Contrato</b> aos dias da antecipa&ccedil;&atilde;o.';
      vtexto := vtexto||'<br>'||'
      10.  <b><u> Garantia Pessoal  </b></u> – Para evitar o acúmulo de encargos, o(a) <b>Contratante</b> dá à <b>Cooperativa</b>, em cess&atilde;o fiduciária, todos os direitos sobre suas aplica&ccedil;ões financeiras e poupan&ccedil;a programada mantidas nesta <b>Cooperativa</b>, al&eacute;m de suas quotas-parte subscritas, atuais e futuras.';
      vtexto := vtexto||'<br>'||'
      10.1  As aplica&ccedil;ões financeiras e poupan&ccedil;a programada atuais cedidas em garantia s&atilde;o aquelas consolidadas em extrato disponível nesta data e as futuras integrar&atilde;o automaticamente esta garantia assim que realizadas, servindo o respectivo extrato para identificá-las e aperfei&ccedil;oar esta cess&atilde;o fiduciária.';
      vtexto := vtexto||'<br>'||'
      10.2  . At&eacute; o cumprimento integral das obriga&ccedil;ões assumidas pelo(a) <b>Contratante</b> decorrentes deste <b>Contrato</b>, as posses direta e indireta das aplica&ccedil;ões e quotas-parte, cujos direitos s&atilde;o cedidos em garantia, ser&atilde;o detidas pela <b>Cooperativa</b>. ';
      vtexto := vtexto||'<br>'||'
      10.3   Na hipótese de atraso no pagamento ou de vencimento antecipado deste <b>Contrato</b>, a <b>Cooperativa</b> poderá excutir extrajudicialmente a garantia, resgatando o saldo das aplica&ccedil;ões, poupan&ccedil;as e/ou das quotas-partes ou negociando-as, podendo praticar todos os atos necessários a essa finalidade.';
      vtexto := vtexto||'<br>'||'
      10.4   A <b>Cooperativa</b> utilizará o produto da negocia&ccedil;&atilde;o ou do resgate das aplica&ccedil;ões financeiras e quotas-parte para amortizar ou liquidar o saldo devedor em atraso, bem como para se ressarcir das respectivas despesas incorridas. O valor excedente correspondente às aplica&ccedil;ões, se houver, será entregue ao(a) <b>Contratante</b>, acompanhado de demonstrativo da excuss&atilde;o realizada.';
      vtexto := vtexto||'<br>'||'
      10.5   O(A) <b>Contratante</b> permanece responsável pelas obriga&ccedil;ões fiscais relativas às referidas aplica&ccedil;ões financeiras, poupan&ccedil;a programada e/ou quotas-partes.';
      vtexto := vtexto||'<br>'||'
      11.  <b><u> Libera&ccedil;&atilde;o de informa&ccedil;ões ao Banco Central do Brasil e demais autoriza&ccedil;ões para consultas  </b></u> – O(A) <b>Contratante</b> autoriza a <b>Cooperativa</b> e as sociedades pertencentes ao Sistema Ailos, a qualquer tempo, mesmo após a extin&ccedil;&atilde;o do <b>Contrato</b>, a fornecer ao BACEN, para integrar o SCR, informa&ccedil;ões sobre o montante de suas dívidas a vencer e vencidas, inclusive as em atraso e as opera&ccedil;ões baixadas com prejuízo, bem como o valor das coobriga&ccedil;ões assumidas e das garantias prestadas por eles. Autorizam ainda, a consulta das informa&ccedil;ões constantes no SCR e nos servi&ccedil;os de prote&ccedil;&atilde;o ao cr&eacute;dito (SPC, SERASA, entre outros) sobre eventuais informa&ccedil;ões a seu respeito nele existentes.';
      vtexto := vtexto||'<br>'||'
      11.1  A finalidade do SCR &eacute; prover o BACEN de informa&ccedil;ões sobre opera&ccedil;ões de cr&eacute;dito para fins de supervis&atilde;o do risco de cr&eacute;dito e intercâmbio de informa&ccedil;ões entre institui&ccedil;ões financeiras. A consulta ao SCR pela <b>Cooperativa</b> depende desta pr&eacute;via autoriza&ccedil;&atilde;o, pelo que o(a) <b>Contratante</b> declara que eventual consulta anterior, para fins desta contrata&ccedil;&atilde;o, contou com a sua pr&eacute;via autoriza&ccedil;&atilde;o, ainda que verbal.';
      vtexto := vtexto||'<br>'||'
      11.2   O(A) <b>Contratante</b> poderá acessar, a qualquer tempo, os seus dados mantidos no SCR pelos meios colocados à disposi&ccedil;&atilde;o pelo BACEN. Em caso de divergência nos dados do SCR fornecidos pela <b>Cooperativa</b>, o(a) <b>Contratante</b> poderá pedir a corre&ccedil;&atilde;o, exclus&atilde;o ou registro de anota&ccedil;&atilde;o complementar dos mesmos, inclusive de medidas judiciais, mediante solicita&ccedil;&atilde;o escrita e fundamentada a <b>Cooperativa</b>.';
      vtexto := vtexto||'<br>'||'
      <b>12.</b>  <b><u>  Custo Efetivo Total (CET) </b></u> – O(A) <b>Contratante</b> declara ter ciência dos encargos e despesas incluídos na opera&ccedil;&atilde;o que integram o CET, expresso na forma de taxa percentual anual indicada no item 1.16 e item 4.1 da planilha demonstrativa de cálculo, recebida no momento da contrata&ccedil;&atilde;o. A <b>Cooperativa</b> informou ao(à) <b>Contratante</b> o CET na data da contrata&ccedil;&atilde;o, à taxa indicada nas condi&ccedil;ões específicas da contrata&ccedil;&atilde;o. Sempre que necessário, poderá o(a) <b>Contratante</b> solicitar novo cálculo/extrato do CET do empr&eacute;stimo.';
      vtexto := vtexto||'<br>'||'
      13.  <b><u> Seguro Prote&ccedil;&atilde;o de Cr&eacute;dito </b></u> - Em caso de contrata&ccedil;&atilde;o do Seguro Prote&ccedil;&atilde;o de Cr&eacute;dito, o(a) <b>Contratante</b> autoriza a <b>Cooperativa</b> a repassar o valor do respectivo prêmio à Seguradora indicada na apólice para sua integral quita&ccedil;&atilde;o, e fica ciente que o valor da indeniza&ccedil;&atilde;o do seguro, em caso de eventual sinistro coberto, será destinado para amortizar ou liquidar o saldo devedor do empr&eacute;stimo. Para efeito de aplica&ccedil;&atilde;o do art. 766 do Código Civil, o(a) <b>Contratante</b> declara que n&atilde;o tem conhecimento de ser portador de quaisquer das doen&ccedil;as ou lesões relevantes que exijam tratamento m&eacute;dico e que n&atilde;o está afastado de suas atividades habituais por motivo de saúde.';
      vtexto := vtexto||'<br>'||'
      14.  <b><u> Tolerância  </b></u> - A tolerância de uma das partes quanto ao descumprimento de qualquer obriga&ccedil;&atilde;o pela outra parte n&atilde;o significará renúncia ao direito de exigir o cumprimento da obriga&ccedil;&atilde;o, nem perd&atilde;o, nem altera&ccedil;&atilde;o do que foi aqui contratado.';
      vtexto := vtexto||'<br>'||'
      15.  <b><u> Vínculo Cooperativo </b></u> – As partes declaram que este instrumento está vinculado às disposi&ccedil;ões legais cooperativistas vigentes no momento da contrata&ccedil;&atilde;o, ao Estatuto Social da <b>Cooperativa</b> e demais delibera&ccedil;ões assembleares desta, e do seu Conselho de Administra&ccedil;&atilde;o, os quais o <b>Contratante</b> está obrigado por ter livre e espontaneamente aderido ao quadro social da <b>Cooperativa</b>, e cujo teor ratifica, reconhecendo na opera&ccedil;&atilde;o contratada a celebra&ccedil;&atilde;o de um Ato Cooperativo previsto no artigo 79 da Lei Federal núm. 5.764/71, o que afasta qualquer caracteriza&ccedil;&atilde;o de mercantilidade da presente <b>Contrato</b>.';
      vtexto := vtexto||'<br>'||'
      16.  <b><u> Altera&ccedil;&atilde;o Contratual e/ou Regras do Contrato </b></u> - Quaisquer altera&ccedil;ões que incluam, excluam ou modifiquem as presentes cláusulas ou que venha alterar as regras deste <b>Contrato</b> ficar&atilde;o disponíveis ao(à) <b>Contratante</b> via website '||pr_site ||' ou nos canais de autoatendimento disponibilizados pela <b>Cooperativa</b>. As referidas altera&ccedil;ões aplicar-se-&atilde;o para todos os contratos e todas as prorroga&ccedil;ões que se fizerem após a data da publica&ccedil;&atilde;o. N&atilde;o havendo concordância com as altera&ccedil;ões promovidas, o <b>Contratante</b> deverá comunicar em at&eacute; 15 (quinze) dias da publica&ccedil;&atilde;o.';
      vtexto := vtexto||'<br>'||'
      17.  <b><u> Envio de SMS e correspondência eletrônica  </b></u>- No intuito de manter o(a) <b>Contratante</b> informado sobre este empr&eacute;stimo e sobre outros produtos, servi&ccedil;os, ofertas ou informa&ccedil;ões de seu interesse, fica autorizado o envio de SMS e e-mails pela <b>Cooperativa</b>. O(A) <b>Contratante</b> poderá cancelar essa autoriza&ccedil;&atilde;o, mediante solicita&ccedil;&atilde;o à Central de Atendimento da <b>Cooperativa</b>.';
      vtexto := vtexto||'<br>'||'
      18.  <b><u> Solu&ccedil;&atilde;o amigável de conflitos  </b></u> - Para a solu&ccedil;&atilde;o amigável de eventuais conflitos relacionados a este <b>Contrato</b>, o(a) <b>Contratante</b> poderá dirigir seu pedido ou reclama&ccedil;&atilde;o ao Posto de Atendimento responsável pela sua conta corrente. Está ainda à sua disposi&ccedil;&atilde;o o tele atendimento ('|| pr_tel_ura ||'), e o website '||pr_site ||' Se n&atilde;o for solucionado o conflito, o(a) <b>Contratante</b> poderá recorrer à Ouvidoria ('||pr_tel_ouvid||'), em dias úteis, 08h00min às 17h00min).';
      vtexto := vtexto||'<br>'||'
      19.  <b><u> Declara&ccedil;&atilde;o de Leitura  </b></u> – O(A) <b>Contratante</b> ao assinar o presente <b>Contrato</b>, declara que a leu previamente e que n&atilde;o possuí nenhuma dúvida com rela&ccedil;&atilde;o a quaisquer de suas cláusulas.';
      vtexto := vtexto||'<br>'||'
      20.  <b><u> Foro  </b></u> - As partes, em comum acordo, elegem o foro da Comarca de domicílio do(a) <b>Contratante</b>, com exclus&atilde;o de qualquer outro, por mais privilegiado que seja para dirimir quaisquer questões resultantes do presente <b>Contrato</b>. ';
      vtexto := vtexto||'<br><br><br>';
      --
      --/
      FOR rw_ass IN
       ( SELECT upper(ass.nmassinatura) AS nmassinatura,
                ass.dtassinatura,
                ass.hrassinatura,
                ass.idassinatura
           FROM tbepr_assinaturas_contrato ass, 
                crapepr epr
          WHERE ass.cdcooper = pr_cdcooper
            AND ass.nrdconta = pr_nrdconta
            AND ass.nrctremp = pr_nrctremp
            AND ass.cdcooper = epr.cdcooper
            AND ass.nrdconta = epr.nrdconta
            AND ass.nrctremp = epr.nrctremp
            AND ass.tpassinatura = 1 -- associado
            AND ass.idassinatura = (SELECT MAX(idassinatura) 
                                       from tbepr_assinaturas_contrato ass2
                                      WHERE ass.cdcooper = ass2.cdcooper
                                        AND ass.nrdconta = ass2.nrdconta
                                        AND ass.nrctremp = ass2.nrctremp
                                        AND ass.tpassinatura = ass2.tpassinatura 
                                        AND ass.nrcpfcgc = ass2.nrcpfcgc)
          ORDER BY ass.idassinatura
        )
      LOOP
       vtexto := vtexto||'<br>'||'<br>'||
       'Assinado eletronicamente pelo <b>CONTRATANTE '||rw_ass.nmassinatura||' </b>, no dia '||to_char(rw_ass.dtassinatura,'DD/MM/RRRR')||', às '||rw_ass.hrassinatura ||', mediante aposi&ccedil;&atilde;o de senha num&eacute;rica e letras de seguran&ccedil;a.';
      END LOOP;
      --
      --/
      FOR rw_ass IN
       ( SELECT upper(ass.nmassinatura) AS nmassinatura,
                ass.dtassinatura,
                ass.hrassinatura
           FROM tbepr_assinaturas_contrato ass, 
                crapepr epr
          WHERE ass.cdcooper = pr_cdcooper
            AND ass.nrdconta = pr_nrdconta
            AND ass.nrctremp = pr_nrctremp
            AND ass.cdcooper = epr.cdcooper
            AND ass.nrdconta = epr.nrdconta
            AND ass.nrctremp = epr.nrctremp
            AND ass.tpassinatura = 2 -- cooperativa
        )
      LOOP
       vtexto := vtexto||'<br>'||'<br>'||
       'Assinado eletronicamente pela <b> '||rw_ass.nmassinatura ||'</b>, no dia '||to_char(rw_ass.dtassinatura,'DD/MM/RRRR')||', às '||rw_ass.hrassinatura
       ||', mediante liberação do crédito na conta corrente acima. ';
     END LOOP;
      
      vtexto := vtexto||'
       </body>
      </html>';

      vtexto := REPLACE(vtexto,'á','&aacute;');	
      vtexto := REPLACE(vtexto,'Á','&Aacute;');
      vtexto := REPLACE(vtexto,'ã','&atilde;');
      vtexto := REPLACE(vtexto,'Ã','&Atilde;');
      vtexto := REPLACE(vtexto,'â','&acirc;');
      vtexto := REPLACE(vtexto,'Â','&Acirc;');
      vtexto := REPLACE(vtexto,'à','&agrave;');
      vtexto := REPLACE(vtexto,'À','&Agrave;');
      vtexto := REPLACE(vtexto,'é','&eacute;');
      vtexto := REPLACE(vtexto,'É','&Eacute;');
      vtexto := REPLACE(vtexto,'ê','&ecirc;');
      vtexto := REPLACE(vtexto,'Ê','&Ecirc;');
      vtexto := REPLACE(vtexto,'í','&iacute;');
      vtexto := REPLACE(vtexto,'Í','&Iacute;');
      vtexto := REPLACE(vtexto,'ó','&oacute;');
      vtexto := REPLACE(vtexto,'Ó','&Oacute;');
      vtexto := REPLACE(vtexto,'õ','&otilde;');
      vtexto := REPLACE(vtexto,'Õ','&Otilde;');
      vtexto := REPLACE(vtexto,'ô','&ocirc;');
      vtexto := REPLACE(vtexto,'Ô','&Ocirc;');
      vtexto := REPLACE(vtexto,'ú','&uacute;');
      vtexto := REPLACE(vtexto,'Ú','&Uacute;');
      vtexto := REPLACE(vtexto,'ç','&ccedil;');
      vtexto := REPLACE(vtexto,'Ç','&Ccedil;');
      vtexto := REPLACE(vtexto,'–','&ndash;');

  END monta_textofim_html;

  --/ procedure generica para inserir as tags no xml montado
  PROCEDURE insere_tag(pr_xml      IN OUT NOCOPY XMLType  --> XML que receberá a nova TAG
                      ,pr_tag_pai  IN VARCHAR2            --> TAG que receberá a nova TAG
                      ,pr_posicao  IN PLS_INTEGER         --> Posição da tag na lista
                      ,pr_tag_nova IN VARCHAR2            --> String com a nova TAG
                      ,pr_tag_cont IN VARCHAR2            --> Conteúdo da nova TAG
                      ,pr_des_erro OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : insere_tag
  --  Sistema  : CREDITO
  --  Sigla    : EMPR
  --  Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  --  Data     : Dez/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Rotina generica focando no apoio a criação dos XMl's
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN

      GENE0007.pc_insere_tag(pr_xml => pr_xml,
                             pr_tag_pai => pr_tag_pai,
                             pr_posicao => pr_posicao,
                             pr_tag_nova => pr_tag_nova,
                             pr_tag_cont => pr_tag_cont,
                             pr_des_erro => pr_des_erro);

  EXCEPTION
    WHEN OTHERS THEN
       pr_des_erro := 'Erro pc_insere_tag: ' || SQLERRM;
  END insere_tag;

  --/ monta o xml patindo pelo segmento da cooperativa quando informado no parametro.
  --/ monta o xml patindo pelos segmentos da cooperativa, quando não informado o segmento no parametro.
  PROCEDURE monta_xml_segmento(pr_cdcooper crapcop.cdcooper%TYPE
                              ,pr_idsegmento tbepr_segmento.idsegmento%TYPE
                              ,pr_tppessoa IN NUMBER
                              ,pr_retorno OUT XMLType
                              ,pr_dscritic OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  -- Programa : monta_xml_segmento
  -- Sistema  : CREDITO
  -- Sigla    : EMPR
  -- Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  -- Data     : Dez/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Rotina focando na montagem do xml de retorno, tornando o fonte principal mais legível
  --
  ---------------------------------------------------------------------------------------------------------------

   vr_contador_seg NUMBER := 0;
   vr_contador_sub NUMBER := 0;
   vr_cont_pess NUMBER := 0;
   vr_cont_canais NUMBER := 0;

   --/  busca as informacoes do segmento
   CURSOR cr_segmento(pc_cdcooper crapcop.cdcooper%TYPE,
                      pc_idsegmento tbepr_segmento.idsegmento%TYPE,
                      pc_tppessoa IN NUMBER) IS
     SELECT ts.cdcooper AS cod_cooperativa
           ,ts.idsegmento AS cod_segmento
           ,ts.dssegmento AS nome_segmento
           ,ts.qtsimulacoes_padrao
           ,ts.nrvariacao_parc AS variacao_parc
           ,ts.nrmax_proposta AS limite_max_proposta
           ,ts.nrintervalo_proposta AS intervalo_proposta
           ,ts.dssegmento_detalhada AS descricao_segmento
       FROM cecred.tbepr_segmento ts
      WHERE ts.cdcooper = pc_cdcooper
        AND ts.idsegmento = nvl(pc_idsegmento,ts.idsegmento)
        AND EXISTS (SELECT 1
                      FROM tbepr_segmento_tppessoa_perm tp
                     WHERE tp.cdcooper = pc_cdcooper
                       AND tp.idsegmento = ts.idsegmento
                       AND tp.tppessoa = pc_tppessoa )
        ORDER BY 1,2;

   --/  busca as informacoes dos subsegmento
   CURSOR cr_subsegmentos(pr_cdcooper crapcop.cdcooper%TYPE, pr_idsegmento NUMBER) IS
      SELECT tss.cdcooper AS cod_cooperativa
            ,tss.idsubsegmento AS codigo_subsegmento
            ,tss.dssubsegmento AS nome_subsegmento
            ,tss.cdlinha_credito AS codigo_linha_credito
            ,lin_cred.dslcremp AS desc_linha_credito
            ,tss.flggarantia AS garantia
            ,tss.tpgarantia AS tipo_garantia
            ,decode(tss.tpgarantia,0,'Novo',1,'USado') desc_tipo_garantia
            ,lin_cred.NRFIMPRE quantidade_max_parcelas
            ,lin_cred.qtcarenc
            ,tss.pemax_autorizado AS percent_max_autorizado
            ,tss.vlmax_proposta AS valor_max_proposta
            ,tss.peexcedente AS percent_excedente
        FROM tbepr_subsegmento tss , craplcr lin_cred
       WHERE tss.cdcooper = pr_cdcooper
         AND tss.idsegmento = pr_idsegmento
         AND tss.cdlinha_credito = lin_cred.cdlcremp
         AND tss.cdcooper = lin_cred.cdcooper
         ORDER BY 1,2;

   --/  busca as informacoes de permissoes do segmento por tipo de pessoa
   CURSOR cr_permissoes_pessoa(pc_cdcooper crapcop.cdcooper%TYPE, pc_idsegmento NUMBER) IS
      SELECT tp_pes.tppessoa tp_pessoa
        FROM tbepr_segmento_tppessoa_perm tp_pes
       WHERE tp_pes.cdcooper = pc_cdcooper
         AND tp_pes.idsegmento = pc_idsegmento;

   --/  busca as informacoes de permissoes do segmento por canais de entrada
   CURSOR cr_permissoes_canais(pr_cdcooper crapcop.cdcooper%TYPE, pr_idsegmento NUMBER) IS
      SELECT tce.cdcanal,
             tce.nmcanal,
             cns.tppermissao,
             decode(cns.tppermissao,0,'Indisponível',1,'Simulação',2,'Contratação') desc_tppermissao,
             cns.vlmax_autorizado vlr_max_autorizado
        FROM tbepr_segmento_canais_perm cns, tbgen_canal_entrada tce
       WHERE cns.cdcooper = pr_cdcooper
         AND cns.idsegmento = pr_idsegmento
         AND cns.cdcanal = tce.cdcanal;

  BEGIN

    pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Segmentos/>');

    --/ segmentos
    vr_contador_seg := 0;
    vr_contador_sub := 0;
    FOR rw_segmento IN cr_segmento(pr_cdcooper,pr_idsegmento,pr_tppessoa) LOOP
      -- Loop sobre a tabela de segmentos
       -- Insere o nó principal
        -- Insere os detalhes
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmentos'
                  ,pr_posicao  => 0
                  ,pr_tag_nova => 'Segmento'
                  ,pr_tag_cont => NULL
                  ,pr_des_erro => pr_dscritic);

        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  => vr_contador_seg
                  ,pr_tag_nova => 'codigo_cooperativa'
                  ,pr_tag_cont => rw_segmento.cod_cooperativa
                  ,pr_des_erro => pr_dscritic);

        -- Codigo do Segmento
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  => vr_contador_seg
                  ,pr_tag_nova => 'codigo_segmento'
                  ,pr_tag_cont => rw_segmento.cod_segmento
                  ,pr_des_erro => pr_dscritic);
        -- Nome do Segmento
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  => vr_contador_seg
                  ,pr_tag_nova => 'nome_segmento'
                  ,pr_tag_cont => rw_segmento.nome_segmento
                  ,pr_des_erro => pr_dscritic);

        -- Quantidade de Parcelas Padrao
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  => vr_contador_seg
                  ,pr_tag_nova => 'quantidade_padrao_simulacoes'
                  ,pr_tag_cont => rw_segmento.qtsimulacoes_padrao
                  ,pr_des_erro => pr_dscritic);
        -- Variação de Parcelas
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  => vr_contador_seg
                  ,pr_tag_nova => 'variacao_parcelas'
                  ,pr_tag_cont => rw_segmento.variacao_parc
                  ,pr_des_erro => pr_dscritic);
        -- Limite Maximo Proposta
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  => vr_contador_seg
                  ,pr_tag_nova => 'limite_maximo_proposta'
                  ,pr_tag_cont => rw_segmento.limite_max_proposta
                  ,pr_des_erro => pr_dscritic);
       -- Intervalo Tempo Proposta
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  => vr_contador_seg
                  ,pr_tag_nova => 'intervalo_tempo_proposta'
                  ,pr_tag_cont => rw_segmento.limite_max_proposta
                  ,pr_des_erro => pr_dscritic);

        -- Descrição detalhada do Segmento
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  => vr_contador_seg
                  ,pr_tag_nova => 'descricao_segmento'
                  ,pr_tag_cont => rw_segmento.descricao_segmento
                  ,pr_des_erro => pr_dscritic);

        --/ Subsegmentos
        --vr_contador_sub := 0;

        -- Insere os detalhes
        insere_tag(pr_xml      => pr_retorno
                  ,pr_tag_pai  => 'Segmento'
                  ,pr_posicao  =>  vr_contador_seg
                  ,pr_tag_nova => 'Subsegmentos'
                  ,pr_tag_cont => NULL
                  ,pr_des_erro => pr_dscritic);

         FOR rw_subsegmento IN cr_subsegmentos(rw_segmento.cod_cooperativa,rw_segmento.cod_segmento) LOOP
         -- Insere o nó principal
         -- Insere os detalhes
         -- Codigo do subSegmento
         --
                 insere_tag(pr_xml      => pr_retorno
                           ,pr_tag_pai  => 'Subsegmentos'
                           ,pr_posicao  =>  vr_contador_seg
                           ,pr_tag_nova => 'Subsegmento'
                           ,pr_tag_cont => NULL
                           ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'codigo_subsegmento'
                            ,pr_tag_cont => rw_subsegmento.codigo_subsegmento
                            ,pr_des_erro => pr_dscritic);

              -- Nome do subSegmento
                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'nome_subsegmento'
                            ,pr_tag_cont => rw_subsegmento.nome_subsegmento
                            ,pr_des_erro => pr_dscritic);

              -- Quantidade de Parcelas Padrao
                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'codigo_linha_credito'
                            ,pr_tag_cont => rw_subsegmento.codigo_linha_credito
                            ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'descrição_linha_credito'
                            ,pr_tag_cont => rw_subsegmento.desc_linha_credito
                            ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'codigo_finalidade_credito'
                            ,pr_tag_cont => 54
                            ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'garantia'
                            ,pr_tag_cont => rw_subsegmento.garantia
                            ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'tipo_garantia'
                            ,pr_tag_cont => rw_subsegmento.tipo_garantia
                            ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'desc_tipo_garantia'
                            ,pr_tag_cont => rw_subsegmento.desc_tipo_garantia
                            ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'quantidade_maxima_parcelas'
                            ,pr_tag_cont => rw_subsegmento.quantidade_max_parcelas
                            ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'qtcarenc'
                            ,pr_tag_cont => rw_subsegmento.qtcarenc
                            ,pr_des_erro => pr_dscritic);
                            
                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'DiaLimiteDataVencimento'
                            ,pr_tag_cont => 27
                            ,pr_des_erro => pr_dscritic);
                            
                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'percentual_maximo_autorizado'
                            ,pr_tag_cont => rw_subsegmento.percent_max_autorizado
                            ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'valor_maximo_proposta'
                            ,pr_tag_cont => fn_decimal_soa(rw_subsegmento.valor_max_proposta)
                            ,pr_des_erro => pr_dscritic);

                  insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador_sub
                            ,pr_tag_nova => 'percentual_excedente'
                            ,pr_tag_cont => rw_subsegmento.percent_excedente
                            ,pr_des_erro => pr_dscritic);

                 vr_contador_sub := vr_contador_sub + 1;

         END LOOP rw_subsegmento;

         --/ Permissao tipo pessoa
         insere_tag(pr_xml      => pr_retorno
                   ,pr_tag_pai  => 'Segmento'
                   ,pr_posicao  =>  vr_contador_seg
                   ,pr_tag_nova => 'Permissoes'
                   ,pr_tag_cont => NULL
                   ,pr_des_erro => pr_dscritic);

         FOR rw_perm_pessoa IN cr_permissoes_pessoa(rw_segmento.cod_cooperativa,rw_segmento.cod_segmento) LOOP

            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'Permissoes'
                      ,pr_posicao  => vr_contador_seg
                      ,pr_tag_nova => 'permissao_tipo_pessoa'
                      ,pr_tag_cont => NULL
                      ,pr_des_erro => pr_dscritic);

            insere_tag(pr_xml      => pr_retorno
                      ,pr_tag_pai  => 'permissao_tipo_pessoa'
                      ,pr_posicao  => vr_cont_pess
                      ,pr_tag_nova => 'codigo_tipo_pessoa'
                      ,pr_tag_cont => rw_perm_pessoa.tp_pessoa
                      ,pr_des_erro => pr_dscritic);

            vr_cont_pess := vr_cont_pess + 1;

         END LOOP rw_perm_pessoa;

         --/ Permissao canais
         insere_tag(pr_xml      => pr_retorno
                   ,pr_tag_pai  => 'Permissoes'
                   ,pr_posicao  => vr_contador_seg
                   ,pr_tag_nova => 'Canais'
                   ,pr_tag_cont => NULL
                   ,pr_des_erro => pr_dscritic);

         FOR vr_cont_perm_canais IN cr_permissoes_canais(rw_segmento.cod_cooperativa,rw_segmento.cod_segmento) LOOP

              insere_tag(pr_xml      => pr_retorno
                        ,pr_tag_pai  => 'Canais'
                        ,pr_posicao  =>  vr_contador_seg
                        ,pr_tag_nova => 'canal'
                        ,pr_tag_cont => NULL
                        ,pr_des_erro => pr_dscritic);

              insere_tag(pr_xml      => pr_retorno
                        ,pr_tag_pai  => 'canal'
                        ,pr_posicao  => vr_cont_canais
                        ,pr_tag_nova => 'codigo_canal'
                        ,pr_tag_cont => vr_cont_perm_canais.cdcanal
                        ,pr_des_erro => pr_dscritic);

              insere_tag(pr_xml      => pr_retorno
                        ,pr_tag_pai  => 'canal'
                        ,pr_posicao  => vr_cont_canais
                        ,pr_tag_nova => 'descricao_canal'
                        ,pr_tag_cont => vr_cont_perm_canais.nmcanal
                        ,pr_des_erro => pr_dscritic);

              insere_tag(pr_xml      => pr_retorno
                        ,pr_tag_pai  => 'canal'
                        ,pr_posicao  => vr_cont_canais
                        ,pr_tag_nova => 'tipo_permissao'
                        ,pr_tag_cont => vr_cont_perm_canais.tppermissao
                        ,pr_des_erro => pr_dscritic);

              insere_tag(pr_xml      => pr_retorno
                        ,pr_tag_pai  => 'canal'
                        ,pr_posicao  => vr_cont_canais
                        ,pr_tag_nova => 'desc_tipo_permissao'
                        ,pr_tag_cont => vr_cont_perm_canais.desc_tppermissao
                        ,pr_des_erro => pr_dscritic);

              insere_tag(pr_xml      => pr_retorno
                        ,pr_tag_pai  => 'canal'
                        ,pr_posicao  => vr_cont_canais
                        ,pr_tag_nova => 'valor_max_autorizado'
                        ,pr_tag_cont => fn_decimal_soa(vr_cont_perm_canais.vlr_max_autorizado)
                        ,pr_des_erro => pr_dscritic);

          vr_cont_canais := vr_cont_canais + 1;

         END LOOP rw_perm_pessoa;

        vr_contador_seg := vr_contador_seg + 1;

     END LOOP rw_segmento;

     -- Se não encontrou nenhum registro
     IF vr_contador_seg = 0 THEN
       -- Gerar crítica
       pr_dscritic   := 'Não encontrado segmento cadastrado com os parâmetros informados!';
     END IF;

   END monta_xml_segmento;

  --/ consulta_parametros_segmento
  --/ busca os dados de segmentos por cooperativa e retorna-os em formato xml
  PROCEDURE pc_consulta_param_segmentos (pr_cdcooper crapcop.cdcooper%TYPE
       /*consulta_parametros_segmento*/ ,pr_idsegmento NUMBER
                                        ,pr_tppessoa NUMBER
                                        ,pr_retorno OUT XMLType
                                        ,pr_des_reto OUT VARCHAR
                                         ) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : consulta_parametros_segmento
  --  Sistema  : CREDITO
  --  Sigla    : EMPR
  --  Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  --  Data     : Dez/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Fornecer Parametros para configurar segmentos de crédito
  --
  ---------------------------------------------------------------------------------------------------------------

  vr_exc_erro EXCEPTION;
  vr_dscritic VARCHAR2(4000);
  vr_xml      xmltype;
  vr_dscritic_param VARCHAR2(4000);
  vr_exc_param EXCEPTION;

    FUNCTION valida_param RETURN BOOLEAN IS
    BEGIN
     --/
     vr_dscritic_param := 'Verifique os Parametros Informados!';
     --/
     RETURN ( NOT(pr_cdcooper IS NULL) AND NOT(pr_tppessoa IS NULL) );

    END valida_param;

  BEGIN

    vr_xml := NULL;

    IF NOT(valida_param) THEN

       RAISE vr_exc_param;

    END IF;
    --return;

    --/
   monta_xml_segmento(pr_cdcooper,
                      pr_idsegmento,
                      pr_tppessoa,
                      vr_xml,
                      vr_dscritic);
    --/
   IF NOT (vr_dscritic IS NULL) THEN

      RAISE vr_exc_erro;

   END IF;

   pr_des_reto    := 'OK';
   pr_retorno     := vr_xml;

  EXCEPTION
    WHEN vr_exc_param THEN
      pr_des_reto := 'NOK';
      pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || vr_dscritic_param ||
                                      '</Erro></Root>');

    WHEN vr_exc_erro THEN
      pr_des_reto := 'NOK';
      pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || vr_dscritic ||
                                      '</Erro></Root>');
    WHEN OTHERS THEN
      pr_des_reto := 'NOK';
      vg_xml_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || 'Erro não tratado na consulta_parametros_segmento: ' || SQLERRM ||
                                      '</Erro></Root>');
  END pc_consulta_param_segmentos;

  /* Imprime o demonstrativo do contrato de emprestimo (Modelo CCB) */
  PROCEDURE pc_gera_demonst_contrato(pr_cdcooper  IN crawepr.cdcooper%TYPE --> Código da Cooperativa
                                    ,pr_nrdconta  IN crawepr.nrdconta%TYPE --> numero da conta
                                    ,pr_nrctremp  IN crawepr.nrctremp%TYPE --> numero do contrato
                                    ,pr_flgarantia IN NUMBER                --> indica se garantia(1) ou nao(0)
                                    ,pr_des_reto  OUT VARCHAR2             --> OK OU NOK
                                    ,pr_xml       OUT xmltype) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gera_demonst_contrato
  --  Sistema  : CREDITO
  --  Sigla    : EMPR
  --  Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  --  Data     : Dez/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Gerar o arquivo PDF do contrato CCB
  --
  -- Alterações: 23/07/2019 - Ajuste na composição do valor do IOF e do valor emprestado. (Douglas Pagel / AMcom) 
  --
  --             08/08/2019 - Ajuste no número de telefone para Tele Atendimento e Ouvidoria. (Douglas Pagel / AMcom) 
  --
  ---------------------------------------------------------------------------------------------------------------
  --
  --
  -- Changeset 30030
  --
  -- caminho e nome do arquivo a ser gerado
  vr_nmdireto VARCHAR(150);
  vr_nmrquivo VARCHAR2(100);

  vr_retorno_xml xmltype;
  -- caminho e nome do arquivo a ser consultado
  vr_endereco VARCHAR(150);
  vr_arqnome  VARCHAR2(100);
  vr_nom_direto   VARCHAR2(200);

  vr_nmarqimp  VARCHAR2(100);
  vr_nmarqpdf  VARCHAR2(100);

  vr_clob  CLOB;
  
  vr_cdagenci crawepr.cdagenci%TYPE;

  vr_exc_erro EXCEPTION;
  vr_dscritic VARCHAR2(10000);
  vr_dsretorno VARCHAR2(10000);

  vr_dssrvarq VARCHAR2(200);
  vr_dsdirarq VARCHAR2(200);
  vr_prmulta        number(7,2);  --> Percentual de multa  

  -- Tabela de erros
  vr_tab_erro GENE0001.typ_tab_erro;
  --
  vr_xml xmltype;
  --
  -- Busca dos dados da cooperativa
  --
  PROCEDURE monta_xml_contrato_ccb(pr_cdcooper  IN crawepr.cdcooper%TYPE --> Código da Cooperativa
                                  ,pr_nrdconta  IN crawepr.nrdconta%TYPE --> numero da conta
                                  ,pr_nrctremp  IN crawepr.nrctremp%TYPE --> numero do contrato
                                  ,pr_retorno   OUT XMLType
                                  ,pr_des_reto  OUT VARCHAR2
                                  ,pr_dscritic OUT VARCHAR2) IS
  --
  vr_dscritic VARCHAR2(10000);
  vr_exc_erro EXCEPTION;
  vr_contador NUMBER := 0;
  vr_vlpreemp NUMBER := 0;
  vr_vliofepr NUMBER;
  vr_vliofpri NUMBER;
  vr_vliofadi NUMBER;
  vr_vlpreclc NUMBER;
  vr_flgimune pls_integer;
  vr_vlemprestado NUMBER;
  --
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmextcop
          ,cop.nmrescop
          ,cop.nrdocnpj
          ,cop.dsendcop
          ,cop.dsendcop||', n. '||cop.nrendcop||', '||cop.nmbairro endereco_coop
          ,cop.nrendcop
          ,cop.nmbairro
          ,cop.nrcepend
          ,cop.nmcidade
          ,cop.cdufdcop
          ,cop.nrtelura
          ,cop.nrtelouv
          ,cop.dsendweb
          ,cop.dsdircop
          ,cop.nrtelvoz
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  --
  rw_crapcop cr_crapcop%ROWTYPE; -- armazena informacoes do cursor cr_crapcop
  --
  -- busca dados do associado
  CURSOR cr_crapass(pr_cdcooper  IN crawepr.cdcooper%TYPE --> Código da Cooperativa
                   ,pr_nrdconta  IN crawepr.nrdconta%TYPE) IS
  SELECT crapass.nmprimtl nm_contratante,
         DECODE(crapass.inpessoa,1,'CPF','CNPJ'),
         gene0002.fn_mask_cpf_cnpj(crapass.nrcpfcgc, crapass.inpessoa) cpfcnpj,
         crapenc.dsendere endereco,
         crapenc.nrendere numero,
         crapenc.nmbairro bairro,
         crapenc.nmcidade cidade,
         crapenc.cdufende  uf,
         gene0002.fn_mask_cep(crapenc.nrcepend) cep,
         crapass.cdnacion,
         gnetcvl.rsestcvl estado_civil,
         crapass_2.cdagenci,
         crapass.inpessoa
   FROM  crapass crapass_2, -- Dados do conjuge
         crapcje,
         gnetcvl,
         crapttl,
         crapenc,
         crapass
   WHERE crapass.cdcooper = pr_cdcooper
     AND crapass.nrdconta = pr_nrdconta
     AND crapass.inpessoa = 1
  --    AND crapass.nrcpfcgc = pr_nrcpfbem
     AND crapenc.cdcooper (+) = crapass.cdcooper
     AND crapenc.nrdconta (+) = crapass.nrdconta
     AND crapenc.idseqttl (+) = 1
     AND crapenc.tpendass (+) = decode(crapass.inpessoa,1,10,9)
     AND crapttl.cdcooper (+) = crapass.cdcooper
     AND crapttl.nrdconta (+) = crapass.nrdconta
     AND crapttl.idseqttl (+) = 1
     AND gnetcvl.cdestcvl (+) = crapttl.cdestcvl
     AND crapcje.cdcooper (+) = crapttl.cdcooper
     AND crapcje.nrdconta (+) = crapttl.nrdconta
     AND crapcje.idseqttl (+) = crapttl.idseqttl
     AND crapass_2.cdcooper (+) = nvl(crapcje.cdcooper,0)
     AND crapass_2.nrdconta (+) = crapcje.nrctacje
  UNION
  SELECT crapass.nmprimtl nm_contratante,
         DECODE(crapass.inpessoa,1,'CPF','CNPJ'),
         gene0002.fn_mask_cpf_cnpj(crapass.nrcpfcgc, crapass.inpessoa) cpfcnpj,
         crapenc.dsendere endereco,
         crapenc.nrendere numero,
         crapenc.nmbairro bairro,
         crapenc.nmcidade cidade,
         crapenc.cdufende  uf,
         gene0002.fn_mask_cep(crapenc.nrcepend) cep,
         crapass.cdnacion,
         '-' AS estado_civil,
         crapass.cdagenci,
         crapass.inpessoa
   FROM  crapjur jur,
         crapenc,
         crapass
   WHERE crapass.cdcooper = pr_cdcooper
     AND crapass.nrdconta = pr_nrdconta
     AND crapass.inpessoa = 2
--    AND crapass.nrcpfcgc = pr_nrcpfbem
     AND crapenc.cdcooper (+) = crapass.cdcooper
     AND crapenc.nrdconta (+) = crapass.nrdconta
     AND crapenc.idseqttl (+) = 1
     AND crapenc.tpendass (+) = decode(crapass.inpessoa,1,10,9)
     AND jur.cdcooper (+) = crapass.cdcooper
     AND jur.nrdconta (+) = crapass.nrdconta;
  rw_crapass cr_crapass%ROWTYPE; --armazena informacoes do cursor cr_crapass

  CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da Cooperativa
                   ,pr_nrdconta IN crawepr.nrdconta%TYPE
                   ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
   SELECT con.nrctremp num_contrato,
          con.nrdconta,
          con.dtmvtolt dt_emissao,
          con.vlemprst  vlr_emprest,
          con.txmensal,
          round((con.txmensal * 12),2) txanual,
          con.vlpreemp vlr_prestacao,
          con.cdcooper,
          con.nrctremp,
          con.dtmvtolt,
          con.cdlcremp,
          con.cdfinemp,
          con.qtpreemp,
          con.vlpreemp,
          con.dtlibera,
          con.tpemprst,
          con.dtcarenc,
          con.dtdpagto,
          con.idfiniof,
          con.nrsimula,
          con.cdorigem,
          con.cdagenci
     FROM crawepr con
    WHERE con.nrctremp = pr_nrctremp
      AND con.cdcooper = pr_cdcooper
      AND con.nrdconta = pr_nrdconta;
  rw_crawepr cr_crawepr%ROWTYPE; --armazena informacoes do cursor cr_crawepr

  -- buscar valor da primeira parcela pos
  CURSOR cr_crappep(pr_cdcooper  IN crawepr.cdcooper%TYPE --> Código da Cooperativa
                   ,pr_nrdconta  IN crawepr.nrdconta%TYPE --> numero da conta
                   ,pr_nrctremp  IN crawepr.nrctremp%TYPE --> numero do contrato
                   ) IS
    SELECT pep.vlparepr,
           pep.dtvencto,
           MAX(pep.dtvencto) OVER() ultima_parcela,
           MIN(pep.dtvencto) OVER() primeira_parcela,
           to_char(pep.dtvencto,'dd') dia_vencto,
           epr.qttolatr prazo_tolerancia,
           nvl(epr.percetop,0) percetop,
           epr.qtpreemp
      FROM crappep pep,
           crawepr epr
     WHERE pep.cdcooper = epr.cdcooper
       AND pep.nrdconta = epr.nrdconta
       AND pep.nrctremp = epr.nrctremp
       AND pep.cdcooper = pr_cdcooper
       AND pep.nrdconta = pr_nrdconta
       AND pep.nrctremp = pr_nrctremp
       AND pep.dtvencto >= epr.dtdpagto
       ORDER BY pep.dtvencto ASC;
  rw_crappep cr_crappep%ROWTYPE;

  -- Busca a Nacionalidade
  CURSOR cr_crapnac(pr_cdnacion IN crapnac.cdnacion%TYPE) IS
   SELECT crapnac.dsnacion
     FROM crapnac
    WHERE crapnac.cdnacion = pr_cdnacion;
  rw_crapnac cr_crapnac%ROWTYPE;--armazena informacoes do cursor cr_crapnac

  -- Busca a linha de credito
  CURSOR cr_craplcr(pr_cdlcremp craplcr.cdlcremp%TYPE) IS
   SELECT clin.dslcremp desc_lin_credito
         ,clin.nrfimpre qtd_parc
         ,clin.txpresta
         ,clin.perjurmo
         ,clin.flgcobmu
     FROM craplcr clin
    WHERE clin.cdlcremp = pr_cdlcremp
      AND clin.cdcooper = pr_cdcooper;
  rw_craplcr cr_craplcr%ROWTYPE;--armazena informacoes do cursor cr_craplcr

  CURSOR cr_crapage(pr_cdagenci crapage.cdagenci%TYPE) IS
    SELECT upper(age.nmcidade||'-'||age.CDUFDCOP) AS nmcidade,           
           age.dstelsit tel_site
      FROM crapage age
     WHERE age.cdagenci = pr_cdagenci
       AND age.cdcooper = pr_cdcooper;
  rw_crapage cr_crapage%ROWTYPE;--armazena informacoes do cursor cr_crapage

  CURSOR cr_crapass1(pr_cdcooper crapass.cdcooper%TYPE
                    ,pr_nrdconta crapass.nrdconta%TYPE
                    )  IS
    SELECT cdagenci
      FROM crapass
     WHERE nrdconta = pr_nrdconta
       AND cdcooper = pr_cdcooper;
    rw_crapass1 cr_crapass1%ROWTYPE;
    
  CURSOR cr_crapsim(pr_cdcooper IN crawepr.cdcooper%TYPE
                   ,pr_nrdconta IN crawepr.nrdconta%TYPE
                   ,pr_nrsimula IN crapsim.nrsimula%TYPE) IS
    SELECT *
      FROM crapsim sim
     WHERE sim.cdcooper = pr_cdcooper
       AND sim.nrdconta = pr_nrdconta
       AND sim.nrsimula = pr_nrsimula
       AND sim.cdorigem = 3;
    rw_crapsim cr_crapsim%ROWTYPE;
    
    
  FUNCTION fn_simulacao_vinculada(pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da Cooperativa
                                 ,pr_nrdconta IN crawepr.nrdconta%TYPE
                                 ,pr_nrsimula IN crapsim.nrsimula%TYPE DEFAULT 0) RETURN BOOLEAN IS    
   vr_count NUMBER;
  --/
  BEGIN
    
    SELECT COUNT(*)
      INTO vr_count
      FROM crapsim sim
     WHERE sim.cdcooper = pr_cdcooper
       AND sim.nrdconta = pr_nrdconta
       AND sim.nrsimula = pr_nrsimula
       AND sim.cdorigem = 3;
     
     RETURN vr_count > 0;
  --/      
  END fn_simulacao_vinculada;

  FUNCTION fn_get_local_emiss(pr_cdcooper IN crawepr.cdcooper%TYPE) RETURN VARCHAR2 IS
   vr_local_emiss VARCHAR2(50);
  BEGIN
    SELECT upper(cop.nmcidade||'-'||cop.cdufdcop)
      INTO vr_local_emiss
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
     
   RETURN vr_local_emiss;
   --/
  EXCEPTION WHEN OTHERS
    THEN
      RETURN ' ';
  END fn_get_local_emiss;

  BEGIN

    vr_contador := 0;

    OPEN cr_crapcop(pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
     IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        vr_dscritic := 'Cooperativa não localizada!';
        RAISE vr_exc_erro;
     END IF;
    CLOSE cr_crapcop;

     OPEN cr_crawepr(pr_cdcooper
                    ,pr_nrdconta
                    ,pr_nrctremp);
     FETCH cr_crawepr INTO rw_crawepr;
     IF cr_crawepr%NOTFOUND THEN
       CLOSE cr_crawepr;
       vr_dscritic := 'Contrato não localizado!';
       RAISE vr_exc_erro;
     END IF;
     CLOSE cr_crawepr;
     --
     -- Se não tem simulação vinculada a proposta ou nao é origem 3 (IB), não permite gerar o CCB
     IF NOT fn_simulacao_vinculada(rw_crawepr.cdcooper,rw_crawepr.nrdconta,nvl(rw_crawepr.nrsimula,0))
       OR rw_crawepr.cdorigem <> 3 THEN
        vr_dscritic := 'Impressão não disponível para este tipo de contrato!';
       RAISE vr_exc_erro;
     END IF;

     OPEN cr_crapsim(rw_crawepr.cdcooper,rw_crawepr.nrdconta,rw_crawepr.nrsimula);
     FETCH cr_crapsim INTO rw_crapsim;
     CLOSE cr_crapsim;
     
     OPEN cr_crapass(pr_cdcooper,pr_nrdconta);
     FETCH cr_crapass INTO rw_crapass;
     CLOSE cr_crapass;
     
    vr_vlemprestado := rw_crawepr.vlr_emprest;
     
    vr_vliofepr := 0;
     
     tiof0001.pc_calcula_iof_epr(pr_cdcooper => rw_crawepr.cdcooper,
                                 pr_nrdconta => rw_crawepr.nrdconta,
                                 pr_nrctremp => rw_crawepr.nrctremp,
                                 pr_dtmvtolt => rw_crawepr.dtmvtolt,
                                 pr_inpessoa => rw_crapass.inpessoa,
                                 pr_cdlcremp => rw_crawepr.cdlcremp,
                                 pr_cdfinemp => rw_crawepr.cdfinemp,
                                 pr_qtpreemp => rw_crawepr.qtpreemp,
                                 pr_vlpreemp => rw_crawepr.vlpreemp,
                                 pr_vlemprst => rw_crawepr.vlr_emprest,
                                 pr_dtdpagto => rw_crawepr.dtdpagto,
                                 pr_dtlibera => rw_crawepr.dtlibera,
                                 pr_tpemprst => rw_crawepr.tpemprst,
                                 pr_dtcarenc => rw_crawepr.dtcarenc,
                                 pr_qtdias_carencia => 0,
                                 pr_dscatbem => '',
                                 pr_idfiniof => rw_crawepr.idfiniof,
                                 pr_dsctrliq => '',
                                 pr_vlpreclc => vr_vlpreclc,
                                 pr_valoriof => vr_vliofepr,
                                 pr_vliofpri => vr_vliofpri,
                                 pr_vliofadi => vr_vliofadi,
                                 pr_flgimune => vr_flgimune,
                                 pr_dscritic => vr_dscritic);
                                 
     IF vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_erro;  
     END IF;
     
     IF NVL(rw_crawepr.idfiniof,0) = 1 THEN
       vr_vlemprestado := nvl(rw_crawepr.vlr_emprest,0) + nvl(vr_vliofepr,0) + nvl(rw_crapsim.vlrtarif,0);
     END IF;
     
     --
     OPEN cr_crapass1(pr_cdcooper,pr_nrdconta);
     FETCH cr_crapass1 INTO rw_crapass1;
     CLOSE cr_crapass1;     

     OPEN cr_crapnac(rw_crapass.cdnacion);
     FETCH cr_crapnac INTO rw_crapnac;
     CLOSE cr_crapnac;

     OPEN cr_craplcr(rw_crawepr.cdlcremp);
     FETCH cr_craplcr INTO rw_craplcr;
     CLOSE cr_craplcr;
     
      IF rw_craplcr.flgcobmu = 1 THEN
        -- Busca o percentual de multa
        vr_prmulta := gene0002.fn_char_para_number(substr(tabe0001.fn_busca_dstextab( pr_cdcooper => 3
                                                                                     ,pr_nmsistem => 'CRED'
                                                                                     ,pr_tptabela => 'USUARI'
                                                                                     ,pr_cdempres => 11
                                                                                     ,pr_cdacesso => 'PAREMPCTL'
                                                                                     ,pr_tpregist => 1),1,5));
      ELSE
        vr_prmulta := 0;

      END IF;


     OPEN cr_crappep(pr_cdcooper,pr_nrdconta,pr_nrctremp);
     FETCH cr_crappep INTO rw_crappep;
      IF cr_crappep%NOTFOUND THEN
       CLOSE cr_crappep;
        vr_dscritic := 'Parcela de emprestimo nao encontrada.';
       RAISE vr_exc_erro;
      END IF;
     CLOSE cr_crappep;

     OPEN cr_crapage(rw_crapass1.cdagenci);
     FETCH cr_crapage INTO rw_crapage;
     CLOSE cr_crapage;

     vr_cdagenci := rw_crawepr.cdagenci; 
     
      pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><contrato/>');

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'contrato'
                ,pr_posicao  => 0
                ,pr_tag_nova => 'dados'
                ,pr_tag_cont => NULL
                ,pr_des_erro => pr_dscritic);

      -- dados da cooperativa inicio
      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'nome_cooperativa'
                ,pr_tag_cont => rw_crapcop.nmextcop
                              ||' sociedade cooperativa de credito, inscrita no CNPJ sob numero '||gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)
                              ||' estabelecida na '||rw_crapcop.endereco_coop||', CEP. '||gene0002.fn_mask_cep(rw_crapcop.nrcepend)
                              ||' cidade de '||rw_crapcop.nmcidade||' - '||rw_crapcop.cdufdcop
                ,pr_des_erro => pr_dscritic);

      /*insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'cpfcnpj_coop'
                ,pr_tag_cont => 'Sociedade cooperativa de credito, inscrita no CNPJ sob numero '||gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'endereco_coop'
                ,pr_tag_cont => 'estabelecida na '||rw_crapcop.endereco_coop||', CEP. '||rw_crapcop.nrcepend
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'cep_coop'
                ,pr_tag_cont => rw_crapcop.nrcepend
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'cidade_coop'
                ,pr_tag_cont => 'Cidade de '||rw_crapcop.nmcidade||' - '||rw_crapcop.cdufdcop
                ,pr_des_erro => pr_dscritic);*/
      --/ dados da cooperativa fim

      -- dados do contratante inicio
      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'num_contrato'
                ,pr_tag_cont => gene0002.fn_mask_contrato(pr_nrcontrato => rw_crawepr.num_contrato)
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'nome_contratante'
                ,pr_tag_cont => rw_crapass.nm_contratante
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'linha_1'
                ,pr_tag_cont => rw_crapass.nm_contratante|| CASE WHEN rw_crapass.inpessoa = 1 THEN ', nacionaliade '||rw_crapnac.dsnacion||', '||rw_crapass.estado_civil ELSE '' END
                                ||', inscrito(a) no CPF/CNPJ sob n. '||rw_crapass.cpfcnpj
                                ||' com sede/residencia na '||rw_crapass.endereco||', n. '||rw_crapass.numero||', '
                                ||' bairro '||rw_crapass.bairro||', cidade de '||rw_crapass.cidade||', CEP '||rw_crapass.cep
                ,pr_des_erro => pr_dscritic);

     /* insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'linha_2'
                ,pr_tag_cont => 'com sede/residencia na Rua '||rw_crapass.endereco||', n. '||rw_crapass.numero||', '
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'linha_3'
                ,pr_tag_cont => 'bairro '||rw_crapass.bairro||', cidade de '||rw_crapass.cidade||', CEP '||rw_crapass.cep
                ,pr_des_erro => pr_dscritic);*/


      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'nacion_contratante'
                ,pr_tag_cont => rw_crapnac.dsnacion
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'estado_civil'
                ,pr_tag_cont => rw_crapass.estado_civil
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'cpfcnpj_contratante'
                ,pr_tag_cont => rw_crapass.cpfcnpj
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'endereco_contratante'
                ,pr_tag_cont => rw_crapass.endereco
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'nr_ender_contratante'
                ,pr_tag_cont => rw_crapass.numero
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'bairro_contratante'
                ,pr_tag_cont => rw_crapass.bairro
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'cidade_contratante'
                ,pr_tag_cont => rw_crapass.cidade
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'cep_contratante'
                ,pr_tag_cont => rw_crapass.cep
                ,pr_des_erro => pr_dscritic);
      --/ dados do contratante fim

      --/ dados do emprestimo inicio
      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'PA'
                ,pr_tag_cont => rw_crapass1.cdagenci
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'nrdconta'
                ,pr_tag_cont => gene0002.fn_mask_conta(pr_nrdconta => rw_crawepr.nrdconta)
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'data_emissao'
                ,pr_tag_cont => fn_data_soa(rw_crawepr.dt_emissao)
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'valor_emprestado'
                ,pr_tag_cont => fn_decimal_soa(nvl(vr_vlemprestado,0)) 
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'taxa_mensal'
                ,pr_tag_cont => fn_decimal_soa(rw_crawepr.txmensal)||' %'
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'taxa_anual'
                ,pr_tag_cont => fn_decimal_soa(rw_crawepr.txanual)||' %'
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'desc_linha_credito'
                ,pr_tag_cont => rw_craplcr.desc_lin_credito
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'qtd_parcelas'
                ,pr_tag_cont => rw_crappep.qtpreemp
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'valor_parcelas'
                ,pr_tag_cont => 'R$ '||TO_CHAR(rw_crawepr.vlr_prestacao,'FM999G999G999D90')
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'dia_vencto_parcelas'
                ,pr_tag_cont => rw_crappep.dia_vencto
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'vencto_primeira_parcela'
                ,pr_tag_cont => fn_data_soa(rw_crappep.primeira_parcela)
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'vencto_ultima_parcela'
                ,pr_tag_cont => fn_data_soa(rw_crappep.ultima_parcela)
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'tx_juros_mora'
                ,pr_tag_cont => TO_CHAR(rw_craplcr.perjurmo,'FM990D90')||'% ao mes sobre o valor em atraso'
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'percent_multa_parcela'
                ,pr_tag_cont => fn_decimal_soa(vr_prmulta)||' %' -- to_char(rw_craplcr.txpresta,'FM990D90')
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'tolerancia_mora_multa'
                ,pr_tag_cont => rw_crappep.prazo_tolerancia
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'local_emissao'
                ,pr_tag_cont => fn_get_local_emiss(rw_crawepr.cdcooper)
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'local_pagamento'
                ,pr_tag_cont => fn_get_local_emiss(rw_crawepr.cdcooper)
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'CET'
                ,pr_tag_cont => to_char(rw_crappep.percetop,'FM999G999G999D90')||' %'
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'website_coop'
                ,pr_tag_cont => rw_crapcop.dsendweb
                ,pr_des_erro => pr_dscritic);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'tel_ouvidoria'
                ,pr_tag_cont => rw_crapage.tel_site
                ,pr_des_erro => pr_dscritic);

      monta_textofim_html(rw_crapcop.dsendweb,
                          rw_crapcop.nrtelouv,
                          nvl(rw_crapcop.nrtelura, rw_crapcop.nrtelvoz),
                          rw_crapass.nm_contratante,
                          rw_crapcop.nmextcop,
                          rw_crawepr.cdcooper,
                          rw_crawepr.nrdconta,
                          rw_crawepr.num_contrato);

      insere_tag(pr_xml      => pr_retorno
                ,pr_tag_pai  => 'dados'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'texto_final'
                ,pr_tag_cont => vtexto
                ,pr_des_erro => pr_dscritic);

      pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN

     pr_dscritic := vr_dscritic;
     pr_des_reto := 'NOK';

    WHEN OTHERS THEN

     pr_dscritic := 'Erro nao tratado na montagem do xml do contrato: '||SQLERRM;
     pr_des_reto := 'NOK';

  END monta_xml_contrato_ccb;

  FUNCTION fn_existe_contrato(pr_cdcooper  IN crawepr.cdcooper%TYPE --> Código da Cooperativa
                             ,pr_nrdconta  IN crawepr.nrdconta%TYPE --> numero da conta
                             ,pr_nrctremp  IN crawepr.nrctremp%TYPE)--> numero do contrato 
    RETURN BOOLEAN IS
                             
  vexiste NUMBER;
  BEGIN
     
    SELECT COUNT(*)
      INTO vexiste
      FROM crapepr epr      
     WHERE epr.cdcooper = pr_cdcooper
       AND epr.nrdconta = pr_nrdconta
       AND epr.nrctremp = pr_nrctremp;
       
    RETURN ( vexiste > 0 );
  
  EXCEPTION WHEN OTHERS
    THEN
       RETURN FALSE;
         
  END fn_existe_contrato;
  
  BEGIN
   --
   --/
/*   IF NOT ( fn_existe_contrato(pr_cdcooper,pr_nrdconta,pr_nrctremp) )
     THEN
       vr_dscritic := 'Informacao de contrato nao localizada!';
       RAISE vr_exc_erro;
   END IF;
*/  --
   -- Busca do diretório base da cooperativa para a geração de relatórios
   vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                       ,pr_cdcooper => pr_cdcooper --> Cooperativa
                                       ,pr_nmsubdir => '/rl');     --> Utilizaremos o rl
   --
   monta_xml_contrato_ccb(pr_cdcooper
                         ,pr_nrdconta
                         ,pr_nrctremp
                         ,vr_xml
                         ,vr_dsretorno
                         ,vr_dscritic);
   --
   vr_clob := NULL;
   dbms_lob.createtemporary(vr_clob, TRUE);
   dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
   --/
   IF ( vr_clob IS NOT NULL ) AND ( vr_dscritic IS NULL ) THEN

     vr_clob := vr_xml.getClobVal;

   ELSE
     vr_dscritic := nvl(vr_dscritic,'problema na montagem do contrato');
     RAISE vr_exc_erro;

   END IF;
   --
   -- Efetuar solicitação de geração de relatório
   --
   vr_nom_direto:= vr_nmdireto; -- '/usr/coop/'||rw_crapcop.dsdircop||'/rl';

   -- Definir nome do relatorio
   vr_nmarqimp := 'contrato_ccb_'||pr_nrctremp||'.ex';
   vr_nmarqpdf := '218'||'_'||trim(gene0002.fn_mask_contrato(pr_nrctremp))
                       ||'_'||trim(replace(gene0002.fn_mask_conta(pr_nrdconta),'-','.'))
                       ||'_'||pr_cdcooper||'_'||vr_cdagenci||'_'||'1'||'.pdf';
   --
   -- Solicitar geração do relatorio
   /*gene0002.pc_solicita_relato( pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                               ,pr_cdprogra  => 'ATENDA' --> Programa chamador
                               ,pr_dtmvtolt  => SYSDATE --> Data do movimento atual
                               ,pr_dsxml     => vr_clob --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/contrato/dados' --> Nó base do XML para leitura dos dados
                               ,pr_dsjasper  => 'crrl772_contrato_ccb.jasper' --> Arquivo de layout do iReport
                               ,pr_dsparams  => null --> Sem parâmetros
                               ,pr_dsarqsaid => vr_nom_direto || '/' || vr_nmarqimp --> Arquivo final com o path
                               ,pr_cdrelato  => 772 -- verificar script de insert na craprel (Rafael em 19/12/2018)
                               ,pr_qtcoluna  => 80 --> 80 colunas
                               ,pr_flg_gerar => 'S' --> Geraçao na hora
                               ,pr_flg_impri => 'N' --> Chamar a impressão (Imprim.p)
                               ,pr_nmformul  => ' ' --> Nome do formulário para impressão
                               ,pr_nrcopias  => 1 --> Número de cópias
                               ,pr_sqcabrel  => 1 --> Qual a seq do cabrel
                               ,pr_nrvergrl  => 1 -- CHAMANDO TIBICO
                               ,pr_des_erro  => vr_dscritic); --> Saída com erro
    -- Tratar erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      raise vr_exc_erro;
    END IF;*/

   gene0002.pc_solicita_relato( pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                               ,pr_cdprogra  => 'ATENDA' --> Programa chamador
                               ,pr_dtmvtolt  => SYSDATE --> Data do movimento atual
                               ,pr_dsxml     => vr_clob --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/contrato/dados' --> Nó base do XML para leitura dos dados
                               ,pr_dsjasper  => 'crrl772_contrato_ccb.jasper' --> Arquivo de layout do iReport
                               ,pr_dsparams  => null --> Sem parâmetros
                               ,pr_dsarqsaid => vr_nom_direto || '/' || vr_nmarqpdf --> Arquivo final com o path
                               ,pr_cdrelato  => 772 -- verificar script de insert na craprel (Rafael em 19/12/2018)
                               ,pr_qtcoluna  => 80 --> 80 colunas
                               ,pr_flg_gerar => 'S' --> Geraçao na hora
                               ,pr_flg_impri => 'N' --> Chamar a impressão (Imprim.p)
                               ,pr_nmformul  => ' ' --> Nome do formulário para impressão
                               ,pr_nrcopias  => 1 --> Número de cópias
                               ,pr_sqcabrel  => 1 --> Qual a seq do cabrel
                               ,pr_nrvergrl  => 1 -- CHAMANDO TIBICO
                               ,pr_des_erro  => vr_dscritic); --> Saída com erro

    -- Tratar erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      raise vr_exc_erro;
    END IF;

      gene0002.pc_copia_arq_para_download(pr_cdcooper => pr_cdcooper,
                                          pr_dsdirecp => vr_nom_direto||'/',
                                          pr_nmarqucp => vr_nmarqpdf,
                                          pr_flgcopia => 1,
                                          pr_dssrvarq => vr_dssrvarq,
                                          pr_dsdirarq => vr_dsdirarq,
                                          pr_des_erro => vr_dscritic);


    -- Liberando a memória alocada pro CLOB
    IF dbms_lob.isopen(vr_clob) = 1 THEN
      dbms_lob.close(vr_clob);
      dbms_lob.freetemporary(vr_clob);
    END IF;


    vr_nmarqimp := vr_nom_direto || '/' || vr_nmarqimp;
    --vr_nmarqpdf := vr_nom_direto || '/' || vr_nmarqpdf;

    vr_retorno_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><retorno/>');

    insere_tag(pr_xml      => vr_retorno_xml
              ,pr_tag_pai  => 'retorno'
              ,pr_posicao  => 0
              ,pr_tag_nova => 'nmarqpdf'
              ,pr_tag_cont => vr_nmarqpdf
              ,pr_des_erro => vr_dscritic);

    insere_tag(pr_xml      => vr_retorno_xml
              ,pr_tag_pai  => 'retorno'
              ,pr_posicao  => 0
              ,pr_tag_nova => 'dssrvarq'
              ,pr_tag_cont => vr_dssrvarq
              ,pr_des_erro => vr_dscritic);

    insere_tag(pr_xml      => vr_retorno_xml
              ,pr_tag_pai  => 'retorno'
              ,pr_posicao  => 0
              ,pr_tag_nova => 'dsdirarq'
              ,pr_tag_cont => substr(vr_dsdirarq,2)
              ,pr_des_erro => vr_dscritic);


    pr_xml := vr_retorno_xml;
    pr_des_reto := 'OK';
   --
 EXCEPTION
  WHEN vr_exc_erro THEN
    pr_des_reto := 'NOK';
    pr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' ||vr_dscritic ||
                                      '</Erro></Root>');
  WHEN OTHERS THEN
    pr_des_reto := 'NOK';
    vr_dscritic := 'Erro nao tratado na pc_gera_demonst_contrato:'||SQLERRM;
    pr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || vr_dscritic ||
                                      '</Erro></Root>');
  END;

  PROCEDURE pc_calcula_simulacao( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                 ,pr_cdorigem IN INTEGER  --> Codigo da origem do canal
                                 ,pr_cdoperad IN VARCHAR2 --> Codigo do operador
                                 ,pr_nrcpfope IN VARCHAR2 --> numero do CPF do operador
                                 ,pr_nripuser IN VARCHAR2 --> IP de acesso do cooperado
                                 ,pr_iddispos IN VARCHAR2 --> ID do dispositivo móvel
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código de PA do canal de atendimento – Valor '90' para Internet
                                 ,pr_nrdcaixa IN INTEGER  --> Código de caixa do canal de atendimento – Valor fixo '900' para Internet
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta do Cooperado
                                 ,pr_idseqttl IN INTEGER --> Titularidade do Cooperado
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do Movimento
                                 ,pr_flgerlog IN NUMBER --> ( 0=false/1=verdadeiro ) - Flag de Geração de Log (O campo não deve ser exposto no barramento e deverá assumir o valor “true” como default.
                                 ,pr_cddopcao IN VARCHAR --> Identificador da Operação (SOA deve manter o valor “I” como default e não expor o campo ao consumidor do operador.
                                 ,pr_cdlcremp IN INTEGER --> Id identificador da Linha de crédito da Simulação
                                 ,pr_vlemprst IN NUMBER --> Valor do Empréstimo
                                  --,pr_qtsimula IN INTEGER --> Quantidade de Simulações
                                 ,pr_tp_simulacao IN INTEGER --> (1-Padrão, 2-Unica, 3-Máxima)
                                 ,pr_qtparc   IN INTEGER --> quantidade de parcelas
                                 ,pr_dtlibera IN DATE default null -->
                                 ,pr_dtdpagto IN DATE --> Data de Pagamento
                                 --,pr_cdfinemp IN INTEGER --> Código Finalidade do Empréstimo
                                 ,pr_idfiniof IN INTEGER --> Financia IOF (1=Sim e 0 Não)
                                 ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                 ,pr_flggrava IN NUMBER DEFAULT 0 --> Flag para definir se deve ser salva a simulação (1=Sim e 0 Não)
                                 ,pr_idsegmento tbepr_segmento.idsegmento%TYPE --> Id identificador do Segmento da Simulação
                                 ,pr_idpessoa IN INTEGER  --> ID identificador do cadastro da pessoa referente ao cooperado da simulação
                                 ,pr_nrseq_email IN INTEGER --> ID de e-mail cooperado (Informado na Simulação – Conta On-line)
                                 ,pr_nrseq_telefone IN INTEGER  --> ID de Telefone do cooperado (Informado na Simulação – Conta On-line)
                                 ,pr_idsubsegmento  IN tbepr_subsegmento.idsubsegmento%TYPE --> Id identificador do SubSegmento da Simulação
                                 ,pr_idmarca IN NUMBER DEFAULT NULL --> identificador da marca na tabela fipe
                                 ,pr_dsmarca IN VARCHAR2 DEFAULT NULL --> descricao da marca na tabela fipe
                                 ,pr_idmodelo IN NUMBER DEFAULT NULL --> identificador do modelo na tabela fipe
                                 ,pr_dsmodelo IN VARCHAR2 DEFAULT NULL --> descricao do modelo na tabela fipe
                                 ,pr_dsano_modelo IN VARCHAR2 DEFAULT NULL --> ano/modelo do bem
                                 ,pr_dscatbem IN VARCHAR2 DEFAULT NULL --> descrico da categoria do bem
                                 ,pr_cdfipe IN VARCHAR2 DEFAULT NULL --> codigo fipe
                                 ,pr_vlfipe IN NUMBER DEFAULT NULL --> valor fipe
                                 ,pr_vlbem IN NUMBER DEFAULT NULL --> valor declarado do bem
                                 ,pr_retorno OUT xmltype --> XML de retorno das simulações
                                 ) IS
  --
  ---------------------------------------------------------------------------------------------------------------
  --
  -- Programa : pc_calcula_simulacao
  -- Sistema  : CREDITO
  -- Sigla    : EMPR
  -- Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  -- Data     : Dez/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Rotina focando no calculo da simulação de crédito - Ex.: 12x, 24x, 36x
  -- conforme parametrizado nos segmentos
  ---------------------------------------------------------------------------------------------------------------
  --
  --
  vr_retorno xmltype;
  vr_reg_crapsim empr0018.typ_reg_crapsim;
  vr_tab_crapsim empr0018.typ_tab_crapsim;
  vr_txcetano NUMBER;
  vidx PLS_INTEGER;
  vidx2 PLS_INTEGER;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(4000);
  vr_qtdmax_parc NUMBER(3);
  vr_variacao_parc NUMBER(3);
  vr_qtd_parc NUMBER(3);
  vr_qtd_simulacoes NUMBER(3);
  vr_tab_erro gene0001.typ_tab_erro;
  vr_qtsimulada INTEGER := 0;
  vr_nrgravad INTEGER;
  vr_qtsimulacao INTEGER;
  vr_cdfinemp INTEGER;
  vr_dtlibera date;
  vr_dtmvtolt DATE;

  --Tipo de registro do tipo data
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  FUNCTION gravou_simulacao(pr_reg_crapsim IN empr0018.typ_reg_crapsim) RETURN BOOLEAN IS
      vr_existe NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO vr_existe
        FROM crapsim sim
       WHERE sim.cdcooper=pr_reg_crapsim.cdcooper
         AND sim.nrdconta=pr_reg_crapsim.nrdconta
         AND sim.nrsimula=pr_reg_crapsim.nrsimula;
       
       RETURN ( vr_existe > 0 );  
  END gravou_simulacao;
  --  
  --/
  FUNCTION fn_valida_valores RETURN BOOLEAN IS
  --
  vr_percent_solicit NUMBER(25,2);
  --/
   FUNCTION get_row_sub RETURN tbepr_subsegmento%ROWTYPE IS
    vr_rw_subsegmento tbepr_subsegmento%ROWTYPE;
    BEGIN
      --/
      SELECT *
        INTO vr_rw_subsegmento
        FROM tbepr_subsegmento sub
       WHERE sub.cdcooper = pr_cdcooper
         AND sub.idsegmento = pr_idsegmento
         AND sub.idsubsegmento = pr_idsubsegmento;
       
      RETURN vr_rw_subsegmento;     
   END get_row_sub;
  --/
  BEGIN
   
     IF pr_vlemprst > pr_vlbem
       THEN
         vr_percent_solicit := ROUND((((pr_vlemprst / pr_vlbem)*100)-100),2);
         IF vr_percent_solicit > get_row_sub().pemax_autorizado
           THEN
             vr_dscritic := '% de Financiamento não autorizado';
             RETURN FALSE;
         END IF;
     END IF;    
            
     IF pr_vlbem > pr_vlfipe
       THEN
         vr_percent_solicit := ROUND((((pr_vlbem / pr_vlfipe)*100)-100),2);
         IF vr_percent_solicit > get_row_sub().peexcedente
           THEN
             vr_dscritic := 'O valor do bem excedeu o Valor Permitido!';
             RETURN FALSE;
         END IF;
     END IF; 
     
     RETURN TRUE;   
         
  END fn_valida_valores;
  --  
  --/
  FUNCTION valida_param RETURN BOOLEAN IS
    BEGIN
     --/
     IF ( pr_cdcooper IS NULL)
      THEN
        vr_dscritic := 'Cooperativa não cadastrada';
        RETURN FALSE;
     END IF;
     --/
     IF ( pr_cdorigem IS NULL)
      THEN
        vr_dscritic := 'origem não cadastrada';
        RETURN FALSE;
     END IF;
     --/
     IF ( pr_cdoperad IS NULL )
       THEN
        vr_dscritic := 'Codigo do operador não cadastrado';
        RETURN FALSE;
     END IF;

     IF pr_idsegmento IS NULL OR pr_idsubsegmento IS NULL
       THEN
        vr_dscritic := 'segmento não cadastrado';
        RETURN FALSE;
     END IF;
     --/
     IF pr_cdagenci IS NULL
       THEN
        vr_dscritic := 'Código PA não cadastrado';
        RETURN FALSE;
     END IF;
     --/
     IF pr_nrdcaixa IS NULL
       THEN
        vr_dscritic := 'Código de caixa do canal não cadastrado';
        RETURN FALSE;
     END IF;
     --/
     IF pr_nrdcaixa IS NULL
       THEN
        vr_dscritic := 'Código de caixa do canal não cadastrado';
        RETURN FALSE;
     END IF;
     --/
     IF pr_nrdconta IS NULL
       THEN
        vr_dscritic := 'Número da Conta não cadastrado';
        RETURN FALSE;
     END IF;
     --/
     RETURN TRUE;

  END valida_param;
  --
  --/ monta o xml para retorno
  --
   PROCEDURE monta_xml_retorno IS
    vr_contador NUMBER;
    --
    FUNCTION fn_retorna_segmento RETURN tbepr_segmento.dssegmento%TYPE IS
      CURSOR cr_segmento(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_idsegmento IN tbepr_segmento.idsegmento%TYPE) IS
       SELECT seg.dssegmento
         FROM tbepr_segmento seg
        WHERE seg.cdcooper = pr_cdcooper
          AND seg.idsegmento = pr_idsegmento;
    --
    rw_segmento cr_segmento%ROWTYPE;
    --
    BEGIN
     --
     OPEN cr_segmento(pr_cdcooper,pr_idsegmento);
      FETCH cr_segmento INTO rw_segmento;
     CLOSE cr_segmento;
     --
     RETURN rw_segmento.dssegmento;
     --
    END fn_retorna_segmento;
    --/
    BEGIN
     --/
     vr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Simulacoes/>');
     vr_contador := 0;
     --/
     FOR vidx2 IN vr_tab_crapsim.first..vr_tab_crapsim.count LOOP
     --
        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Simulacoes'
                  ,pr_posicao  => 0
                  ,pr_tag_nova => 'simulacao'
                  ,pr_tag_cont => NULL
                  ,pr_des_erro => vr_dscritic);

         IF  pr_flggrava = 1 AND gravou_simulacao(vr_reg_crapsim) THEN
         --/
         insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'nrsimula'
                  ,pr_tag_cont => vr_tab_crapsim(vidx2).nrsimula
                  ,pr_des_erro => vr_dscritic);
         END IF;
        --/
        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'Data_simulacao' -- Data da Simulação
                  ,pr_tag_cont => fn_data_soa(trunc(SYSDATE))
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'validade_simulacao' -- Validade da Simulação
                  ,pr_tag_cont => fn_data_soa(vr_tab_crapsim(vidx2).dtvalidade)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'Segmento'  -- Segmento
                  ,pr_tag_cont => fn_retorna_segmento()
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'valor_solicitado' -- Valor Solicitado (R$)
                  ,pr_tag_cont => fn_decimal_soa(vr_tab_crapsim(vidx2).vlemprst)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'valor_emprestimo' -- Valor do Empréstimo (R$)
                  ,pr_tag_cont => fn_decimal_soa(vr_tab_crapsim(vidx2).vlemprst + vr_tab_crapsim(vidx2).vliofepr + vr_tab_crapsim(vidx2).vlrtarif)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'numero_parcelas' -- Número de Parcelas
                  ,pr_tag_cont => vr_tab_crapsim(vidx2).qtparepr
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'valor_parcela' -- Valor da Parcela (R$)
                  ,pr_tag_cont => fn_decimal_soa(vr_tab_crapsim(vidx2).vlparepr)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'taxa_juros' -- Taxa de Juros
                  ,pr_tag_cont => fn_decimal_soa(vr_tab_crapsim(vidx2).txmensal)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao' -- CET
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'cet'
                  ,pr_tag_cont => fn_decimal_soa(vr_tab_crapsim(vidx2).percetop)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'IOF'        -- IOF (R$)
                  ,pr_tag_cont => fn_decimal_soa(vr_tab_crapsim(vidx2).vliofepr)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'tarifa' -- TARIFA (R$)
                  ,pr_tag_cont => fn_decimal_soa(vr_tab_crapsim(vidx2).vlrtarif)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'vencimento_primeira_parcela' -- Vencimento da 1ª Parcela
                  ,pr_tag_cont => to_char(vr_tab_crapsim(vidx2).dtdpagto,'dd/mm/yyyy')
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'idpessoa' --idpessoa
                  ,pr_tag_cont => pr_idpessoa
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'nrseq_email' -- nrseq_email
                  ,pr_tag_cont => nvl(vr_tab_crapsim(vidx2).nrseq_email,pr_nrseq_email)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'email_para_retorno' -- email_para_retorno
                  ,pr_tag_cont => fn_retorna_email(pr_idpessoa,pr_nrseq_email)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'nrseq_telefone' -- nrseq_telefone
                  ,pr_tag_cont => nvl(vr_tab_crapsim(vidx2).nrseq_telefone,pr_nrseq_telefone)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'telefone'   --  Telefone
                  ,pr_tag_cont => fn_retorna_telefone(pr_idpessoa,vr_tab_crapsim(vidx2).nrseq_telefone)
                  ,pr_des_erro => vr_dscritic);
      --
      vr_contador := vr_contador+1;
      --
      IF NOT(vr_dscritic IS NULL) THEN
         pr_des_reto :=  'NOK';
         vr_dscritic := 'Erro na montagem do XML';
         RAISE vr_exc_erro;
      END IF;
     --
     END LOOP;
    --/
    END monta_xml_retorno;

   PROCEDURE popula_tmp_crapsim(pr_reg_crapsim empr0018.typ_reg_crapsim) IS
    BEGIN
      --/
      IF NOT(pr_reg_crapsim.cdcooper IS NULL) THEN
         vidx := vr_tab_crapsim.count+1;
         vr_tab_crapsim(vidx) := pr_reg_crapsim;
         vr_qtsimulada := vr_qtsimulada+1;
      END IF;
      --/
    END popula_tmp_crapsim;

   FUNCTION fn_qtdmax_parcela RETURN NUMBER IS
      CURSOR cr_craplcr(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdlcremp IN crapsim.cdlcremp%TYPE) IS
       SELECT nrfimpre
         FROM craplcr
        WHERE cdcooper = pr_cdcooper
          AND cdlcremp = pr_cdlcremp;

     rw_craplcr  cr_craplcr%ROWTYPE;

    BEGIN

     OPEN cr_craplcr(pr_cdcooper,pr_cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
     CLOSE cr_craplcr;

     RETURN rw_craplcr.nrfimpre;

    END fn_qtdmax_parcela;

   FUNCTION fn_variacao_segmento RETURN NUMBER IS
     CURSOR cr_segmento(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_idsegmento IN tbepr_segmento.idsegmento%TYPE) IS
      SELECT nrvariacao_parc
        FROM tbepr_segmento
       WHERE cdcooper = pr_cdcooper
         AND idsegmento = pr_idsegmento ;

     rw_segmento cr_segmento%ROWTYPE;
    --/
    BEGIN

      OPEN cr_segmento(pr_cdcooper,pr_idsegmento);
      FETCH cr_segmento INTO rw_segmento;
      CLOSE cr_segmento;

      RETURN rw_segmento.nrvariacao_parc;

    END fn_variacao_segmento;

   PROCEDURE inicializa IS
    BEGIN
      vr_qtdmax_parc     := fn_qtdmax_parcela();
      vr_variacao_parc   := fn_variacao_segmento();
      vr_qtd_parc        := vr_variacao_parc;
      vr_qtd_simulacoes  := 0;
      vr_qtsimulada      := 0;
      vr_tab_crapsim.delete;
    END inicializa;

   FUNCTION fn_existe_simulacao RETURN BOOLEAN IS
    BEGIN
      RETURN ( vr_tab_crapsim.count > 0 );
   END fn_existe_simulacao;

   /*PROCEDURE vincula_bem_na_simulacao(pr_reg_crapsim IN empr0018.typ_reg_crapsim) IS
    --
    vr_nrseqbem  tbepr_simulacao_bem.nrseqbem%TYPE;
    --
    --/ funcao para buscar o proximo sequencial disponivel para tbepr_simulacao_bem.nrseqbem
    FUNCTION get_nrseqbem(pr_cdcooper IN tbepr_simulacao_bem.cdcooper%TYPE
                         ,pr_nrdconta IN tbepr_simulacao_bem.nrdconta%TYPE
                         ,pr_nrsimula IN tbepr_simulacao_bem.nrsimula%TYPE )
    RETURN tbepr_simulacao_bem.nrseqbem%TYPE IS
    --
    vr_retorno  tbepr_simulacao_bem.nrseqbem%TYPE;
    --
    BEGIN
       SELECT nvl(MAX(nrseqbem),0) + 1
         INTO vr_retorno
         FROM tbepr_simulacao_bem sm
        WHERE cdcooper = pr_cdcooper
          AND nrdconta = pr_nrdconta
          AND nrsimula = pr_nrsimula;

      RETURN vr_retorno;
    EXCEPTION WHEN OTHERS
      THEN
        RETURN NULL;
    END get_nrseqbem;

    FUNCTION valida_campos RETURN BOOLEAN IS
    BEGIN
      RETURN ( NOT ( pr_idmarca IS NULL) AND
               NOT ( pr_dsmarca IS NULL) AND
               NOT ( pr_idmodelo IS NULL) AND
               NOT ( pr_dsmodelo IS NULL) AND
               NOT ( pr_dsano_modelo IS NULL) AND
               NOT ( pr_dscatbem IS NULL) AND
               NOT ( pr_cdfipe IS NULL) AND
               NOT ( pr_vlfipe IS NULL) AND
               NOT ( pr_vlbem IS NULL)
              );

    END valida_campos;

   BEGIN

    --/
    vr_nrseqbem := get_nrseqbem(pr_reg_crapsim.cdcooper,pr_reg_crapsim.nrdconta,pr_reg_crapsim.nrsimula);

    IF NOT valida_campos
      THEN

       vr_dscritic := 'É obrigatório Informar dados do bem para simulação';
       RAISE vr_exc_erro;

    END IF;

    IF ( vr_nrseqbem IS NULL )
      THEN

       vr_dscritic := 'Erro ao buscar sequencial para tabela tbepr_simulacao_bem ';
       RAISE vr_exc_erro;

    END IF;

    --/
    INSERT INTO tbepr_simulacao_bem
                    (cdcooper
                    ,nrdconta
                    ,nrsimula
                    ,nrseqbem
                    ,idmarca
                    ,dsmarca
                    ,idmodelo
                    ,dsmodelo
                    ,dsano_modelo
                    ,dscatbem
                    ,cdfipe
                    ,vlfipe
                    ,vlbem)
            VALUES (pr_reg_crapsim.cdcooper
                   ,pr_reg_crapsim.nrdconta
                   ,pr_reg_crapsim.nrsimula
                   ,vr_nrseqbem
                   ,pr_idmarca
                   ,pr_dsmarca
                   ,pr_idmodelo
                   ,pr_dsmodelo
                   ,pr_dsano_modelo
                   ,pr_dscatbem
                   ,pr_cdfipe
                   ,pr_vlfipe
                   ,pr_vlbem);

    END vincula_bem_na_simulacao;
*/
   FUNCTION existe_garantia RETURN BOOLEAN IS
   vr_flggarantia NUMBER;
   --/
   BEGIN
   --/
     SELECT COUNT(*) garantia
       INTO vr_flggarantia
       FROM tbepr_subsegmento sub
      WHERE sub.cdcooper = pr_cdcooper
        AND sub.idsegmento = pr_idsegmento
        AND sub.idsubsegmento = pr_idsubsegmento
        AND sub.flggarantia = 1; -- forma de identificar se o subsegmento possui garantia
   --/
    RETURN ( vr_flggarantia > 0 );
   --/
   END existe_garantia;
   --
   --/   
   FUNCTION get_qtpadrao_segmento RETURN INTEGER IS
   vr_retorno INTEGER;
   BEGIN

      SELECT round(seg.qtsimulacoes_padrao)
        INTO vr_retorno
        FROM TBEPR_SEGMENTO SEG
       WHERE seg.cdcooper = pr_cdcooper
         AND seg.idsegmento = pr_idsegmento;
    RETURN vr_retorno;

   EXCEPTION
      WHEN zero_divide
        THEN
          vr_dscritic := 'erro no calculo da quantidade padrao de simulacao';
          RAISE vr_exc_erro;

   END get_qtpadrao_segmento;

   PROCEDURE exec_simulacao_padrao IS

   BEGIN

    WHILE vr_qtd_parc <= vr_qtdmax_parc LOOP

     empr0018.pc_grava_simulacao( pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_nmdatela => 'ATENDA'
                                 ,pr_cdorigem => pr_cdorigem
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_dtmvtolt => vr_dtmvtolt
                                 ,pr_flgerlog => sys.diutil.int_to_bool(pr_flgerlog)
                                 ,pr_cddopcao => pr_cddopcao
                                 ,pr_nrsimula => NULL
                                 ,pr_cdlcremp => pr_cdlcremp
                                 ,pr_vlemprst => pr_vlemprst
                                 ,pr_qtparepr => vr_qtd_parc
                                 ,pr_dtlibera => vr_dtlibera
                                 ,pr_dtdpagto => pr_dtdpagto
                                 ,pr_percetop => 1
                                 ,pr_cdfinemp => vr_cdfinemp
                                 ,pr_idfiniof => pr_idfiniof
                                 ,pr_nrgravad => vr_nrgravad
                                 ,pr_txcetano => vr_txcetano
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_des_erro => vr_des_erro
                                 ,pr_des_reto => pr_des_reto
                                 ,pr_tab_erro => vr_tab_erro
                                 ,pr_retorno  => vr_reg_crapsim
                                 ,pr_flggrava => pr_flggrava
                                 ,pr_idpessoa => pr_idpessoa
                                 ,pr_nrseq_email => pr_nrseq_email
                                 ,pr_nrseq_telefone => pr_nrseq_telefone
                                 ,pr_idsegmento => pr_idsegmento
                                 ,pr_tpemprst => 1
                                 ,pr_idcarenc => 0
                                 ,pr_dtcarenc => NULL);
        --
        IF nvl(pr_des_reto,'NOK') != 'OK'
          THEN
            vr_dscritic := vr_des_erro;
            RAISE vr_exc_erro;
        END IF;
        --
        /*IF gravou_simulacao(vr_reg_crapsim) AND existe_garantia() 
          THEN
            vincula_bem_na_simulacao(vr_reg_crapsim);
        END IF;*/
        --
        popula_tmp_crapsim(vr_reg_crapsim);
        --
        IF vr_qtsimulada >= get_qtpadrao_segmento()
          THEN
            EXIT;
        END IF;
        --
        vr_qtd_parc := vr_qtd_parc + vr_variacao_parc;
        --
     END LOOP;

   END exec_simulacao_padrao;

   PROCEDURE exec_simulacao_unica IS
   BEGIN

     IF pr_qtparc > fn_qtdmax_parcela
       THEN
         vr_dscritic := 'Quantidade máxima de parcelas ultrapassada';
         RAISE vr_exc_erro;
     END IF;
     --/
     empr0018.pc_grava_simulacao( pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_nmdatela => 'ATENDA'
                                 ,pr_cdorigem => pr_cdorigem
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_dtmvtolt => vr_dtmvtolt
                                 ,pr_flgerlog => sys.diutil.int_to_bool(pr_flgerlog)
                                 ,pr_cddopcao => pr_cddopcao
                                 ,pr_nrsimula => NULL
                                 ,pr_cdlcremp => pr_cdlcremp
                                 ,pr_vlemprst => pr_vlemprst
                                 ,pr_qtparepr => pr_qtparc
                                 ,pr_dtlibera => vr_dtlibera
                                 ,pr_dtdpagto => pr_dtdpagto
                                 ,pr_percetop => 1
                                 ,pr_cdfinemp => vr_cdfinemp
                                 ,pr_idfiniof => pr_idfiniof
                                 ,pr_nrgravad => vr_nrgravad
                                 ,pr_txcetano => vr_txcetano
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_des_erro => vr_des_erro
                                 ,pr_des_reto => pr_des_reto
                                 ,pr_tab_erro => vr_tab_erro
                                 ,pr_retorno  => vr_reg_crapsim
                                 ,pr_flggrava => pr_flggrava
                                 ,pr_idpessoa => pr_idpessoa
                                 ,pr_nrseq_email =>  pr_nrseq_email
                                 ,pr_nrseq_telefone => pr_nrseq_telefone
                                 ,pr_idsegmento => pr_idsegmento
                                 ,pr_tpemprst => 1
                                 ,pr_idcarenc => 0
                                 ,pr_dtcarenc => NULL
                                 );
        --
        IF NVL(pr_des_reto,'NOK') != 'OK'
          THEN
            vr_dscritic := vr_des_erro;
            RAISE vr_exc_erro;
        END IF;
        --
       /* IF gravou_simulacao(vr_reg_crapsim) AND existe_garantia() 
          THEN
            vincula_bem_na_simulacao(vr_reg_crapsim);
        END IF;*/
        --
        popula_tmp_crapsim(vr_reg_crapsim);

   END exec_simulacao_unica;

   PROCEDURE exec_simulacao_maxima IS
   vr_qtd INTEGER := 1;
   BEGIN

    WHILE vr_qtd <= fn_qtdmax_parcela LOOP

     empr0018.pc_grava_simulacao( pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_nmdatela => 'ATENDA'
                                 ,pr_cdorigem => pr_cdorigem
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_dtmvtolt => vr_dtmvtolt
                                 ,pr_flgerlog => sys.diutil.int_to_bool(pr_flgerlog)
                                 ,pr_cddopcao => pr_cddopcao
                                 ,pr_nrsimula => NULL
                                 ,pr_cdlcremp => pr_cdlcremp
                                 ,pr_vlemprst => pr_vlemprst
                                 ,pr_qtparepr => vr_qtd
                                 ,pr_dtlibera => vr_dtlibera
                                 ,pr_dtdpagto => pr_dtdpagto
                                 ,pr_percetop => 1
                                 ,pr_cdfinemp => vr_cdfinemp
                                 ,pr_idfiniof => pr_idfiniof
                                 ,pr_nrgravad => vr_nrgravad
                                 ,pr_txcetano => vr_txcetano
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_des_erro => vr_des_erro
                                 ,pr_des_reto => pr_des_reto
                                 ,pr_tab_erro => vr_tab_erro
                                 ,pr_retorno  => vr_reg_crapsim
                                 ,pr_flggrava => pr_flggrava
                                 ,pr_idpessoa => pr_idpessoa
                                 ,pr_nrseq_email =>  pr_nrseq_email
                                 ,pr_nrseq_telefone => pr_nrseq_telefone
                                 ,pr_idsegmento => pr_idsegmento 
                                 ,pr_tpemprst => 1
                                 ,pr_idcarenc => 0
                                 ,pr_dtcarenc => NULL                                 
                                 );
        --
        IF NVL(pr_des_reto,'NOK') != 'OK'
          THEN
            vr_dscritic := vr_des_erro;
            RAISE vr_exc_erro;
        END IF;
        --
      /*  IF gravou_simulacao(vr_reg_crapsim) AND existe_garantia() 
          THEN
            vincula_bem_na_simulacao(vr_reg_crapsim);
        END IF;*/
        --
        popula_tmp_crapsim(vr_reg_crapsim);
        --
        IF vr_qtsimulada >= vr_qtsimulacao
          THEN
            EXIT;
        END IF;
        --
        vr_qtd := vr_qtd + 1;

     END LOOP;

   END exec_simulacao_maxima;

   FUNCTION get_cdfinemp RETURN INTEGER IS
   vr_cdfinalidade INTEGER;
   BEGIN
      SELECT sub.cdfinalidade
       INTO vr_cdfinalidade
       FROM tbepr_subsegmento sub
      WHERE sub.cdcooper = pr_cdcooper
        AND sub.idsegmento = pr_idsegmento
        AND sub.idsubsegmento = pr_idsubsegmento;
   --/
    RETURN vr_cdfinalidade;

   END get_cdfinemp;
   --
   --/
   PROCEDURE valida_valor_proposta(pr_cdcooper IN NUMBER,
                                   pr_idsegmento IN NUMBER,
                                   pr_idsubsegmento IN NUMBER,
                                   pr_vlemprst IN NUMBER ) IS
   CURSOR cr_subsegmento(pr_cdcooper IN NUMBER, pr_idsegmento IN NUMBER, pr_idsubsegmento IN NUMBER) IS
    SELECT vlmax_proposta
      FROM tbepr_subsegmento
     WHERE cdcooper = pr_cdcooper
       AND idsegmento = pr_idsegmento
       AND idsubsegmento = pr_idsubsegmento;
   --/
   rw_subsegmento cr_subsegmento%ROWTYPE;
   --
   BEGIN
   --/
   OPEN cr_subsegmento(pr_cdcooper,pr_idsegmento,pr_idsubsegmento);
    FETCH cr_subsegmento INTO rw_subsegmento;
   CLOSE cr_subsegmento;
    IF rw_subsegmento.vlmax_proposta < pr_vlemprst
     THEN
       vr_dscritic := 'Valor de proposta excedido!';
       RAISE vr_exc_erro;
    END IF;
     --/
   END valida_valor_proposta;
   --/
   BEGIN
    --
    --/  
    IF NOT valida_param
     THEN
       RAISE vr_exc_erro;
    END IF;
    --
    --/
    IF NOT ( fn_valida_valores() ) THEN
      RAISE vr_exc_erro;
    END IF;
    --
    --/
    inicializa();

       
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    if pr_dtlibera is null then
      
      vr_dtlibera := rw_crapdat.dtmvtolt;
    else
      vr_dtlibera := pr_dtlibera;
    end if;
    
    vr_dtmvtolt := rw_crapdat.dtmvtolt;
    
    --/
    --
    vr_cdfinemp := get_cdfinemp();
    --
    -- vr_qtsimulacao := NULL; -- rafael verificar
    --
    IF pr_tp_simulacao = 1    -- 1 - Padrão
      THEN                    -- Realizar uma unica simulação seguindo os parâmetros de variação na tabela de segmento

        exec_simulacao_padrao();

    ELSIF pr_tp_simulacao = 2 -- 2 - Unica
      THEN                    -- Realizar uma unica simulação utilizando a Quantidade de Parcelas Enviada, respeitando a quantidade máxima de parcelas (Linha de crédito)

        exec_simulacao_unica();

    ELSIF pr_tp_simulacao = 3 -- 3 - Máxima
      THEN                    -- Realizar as simulações (Numero de Simulações = Numero máximo de Parcelas) com a variação de 1
                              -- Remover o campo quantidade de simulações
        exec_simulacao_maxima();

    END IF;
    --
    IF NOT fn_existe_simulacao
      THEN
       --
       vr_dscritic := 'Nao foi possível calcular simulacao! - '||vr_des_erro ;
       RAISE vr_exc_erro;
       --
    END IF;
    --
    monta_xml_retorno();
    --
    pr_retorno := vr_retorno;
    --
    pr_des_reto := 'OK';
    --
   EXCEPTION
     WHEN vr_exc_erro
       THEN

        --> Buscar critica
        IF nvl(vr_cdcritic,0) > 0 AND
          TRIM(vr_dscritic) IS NULL THEN
          -- Busca descricao
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_des_reto := 'NOK';
        pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' ||vr_dscritic||
                                        '</Erro></Root>');
     WHEN OTHERS
       THEN
        pr_des_reto := 'NOK';
        vr_dscritic := 'Erro na rotina EMPR0017.pc_calcula_simulacao ' ||sqlerrm;
        pr_retorno  := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' ||'Nao foi possível calcular simulacao! '||vr_dscritic||
                                         '</Erro></Root>');
   END pc_calcula_simulacao;

  --/ procedure pc_consulta_simulacoes
  PROCEDURE pc_consulta_simulacoes(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                  ,pr_cdorigem IN INTEGER   -- Identificador do CANAL de origem da Consulta – Valor fixo '3' para Internet
                                  ,pr_cdoperad IN VARCHAR2  -- codigo do operador
                                  ,pr_nrcpfope IN VARCHAR2  -- Número do CPF do operador do InternetBank
                                  ,pr_nripuser IN VARCHAR2  -- IP de acesso do cooperado
                                  ,pr_iddispos IN VARCHAR2  -- ID do dispositivo móvel
                                  ,pr_cdagenci IN crapass.cdagenci%TYPE  -- Código de PA do canal de atendimento – Valor '90' para Internet
                                  ,pr_nrdcaixa IN INTEGER   -- Código de caixa do canal de atendimento – Valor fixo '900' para Internet
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE -- Número da Conta do Cooperado
                                  ,pr_idseqttl IN INTEGER   -- Titularidade do Cooperado
                                  ,pr_dtmvtolt_ini IN crapdat.dtmvtolt%TYPE -- Data de início para pesquisa
                                  ,pr_dtmvtolt_fim IN crapdat.dtmvtolt%TYPE -- Data fim para pesquisa
                                  ,pr_flgerlog IN NUMBER  -- Flag de Geração de Log (O campo não deve ser exposto no barramento e deverá assumir o valor “true” como default.
                                  ,pr_des_reto OUT VARCHAR -- Retorno OK / NOK
                                  ,pr_idsegmento IN tbepr_segmento.idsegmento%TYPE --> Id identificador do Segmento da Simulação
                                  ,pr_retorno OUT xmltype  --> retorno do tipo xml
                                  ) IS
  --
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gera_demonst_contrato
  --  Sistema  : CREDITO
  --  Sigla    : EMPR
  --  Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  --  Data     : Dez/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Rotina focando na busca dos dados de simulações já realizadas
  --
  ---------------------------------------------------------------------------------------------------------------
  --
  --
  vr_tab_erro gene0001.typ_tab_erro;
  vr_dtmvtolt crapdat.dtmvtolt%TYPE;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_retorno xmltype;
  vr_reg_crapsim empr0018.typ_reg_sim;
  vr_tab_crapsim empr0018.typ_tab_sim;
  vidx PLS_INTEGER;
  vr_dscritic VARCHAR2(1000);
  vr_des_erro VARCHAR2(4000);
  vr_dtmvtolt_ini DATE;
  vr_dtmvtolt_fim DATE;
  rw_crapdat BTCH0001.rw_crapdat%TYPE;
  --
  --
  PROCEDURE monta_xml_retorno IS
  vr_contador NUMBER;
  --
  FUNCTION fn_retorna_segmento(pr_idseg IN tbepr_segmento.idsegmento%TYPE) RETURN tbepr_segmento.dssegmento%TYPE IS
    CURSOR cr_segmento(pr_cdcooper IN crapcop.cdcooper%TYPE,
                       pr_idsegmento IN tbepr_segmento.idsegmento%TYPE) IS
     SELECT seg.dssegmento
       FROM tbepr_segmento seg
      WHERE seg.cdcooper = pr_cdcooper
        AND seg.idsegmento = pr_idseg;
  --
  rw_segmento cr_segmento%ROWTYPE;
  --
  BEGIN
    OPEN cr_segmento(pr_cdcooper,pr_idsegmento);
    FETCH cr_segmento INTO rw_segmento;
    CLOSE cr_segmento;

    RETURN rw_segmento.dssegmento;

  END fn_retorna_segmento;

  BEGIN
   --/
   vr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Simulacoes/>');
   vr_contador := 0;
   --/
   FOR vidx IN vr_tab_crapsim.first..vr_tab_crapsim.count LOOP
     IF (pr_idsegmento is null OR pr_idsegmento = vr_tab_crapsim(vidx).idsegmento) THEN
    /* Data/Hora da Simulação
       Segmento
       Quantidade de Parcelas
       Valor da Parcela
       Valor do Solicitado */

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'Simulacoes'
                ,pr_posicao  => 0
                ,pr_tag_nova => 'simulacao'
                ,pr_tag_cont => NULL
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'simulacao'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'cdcooper' -- codigo da cooperativa
                ,pr_tag_cont => vr_tab_crapsim(vidx).cdcooper
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'simulacao'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'nrdconta' -- numero da conta
                ,pr_tag_cont => vr_tab_crapsim(vidx).nrdconta
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'simulacao'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'nrsimula' -- numero da Simulação
                ,pr_tag_cont => vr_tab_crapsim(vidx).nrsimula
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'simulacao'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'Data_simulacao' -- Data da Simulação
                ,pr_tag_cont => fn_data_soa(vr_tab_crapsim(vidx).dtmvtolt)
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'simulacao'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'Segmento'  -- Segmento
                  ,pr_tag_cont => fn_retorna_segmento(vr_tab_crapsim(vidx).idsegmento)
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'simulacao'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'numero_parcelas' -- Quantidade de Parcelas
                ,pr_tag_cont => vr_tab_crapsim(vidx).qtparepr
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'simulacao'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'valor_parcela' -- Valor da Parcela
                ,pr_tag_cont => fn_decimal_soa(vr_tab_crapsim(vidx).vlparepr)
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'simulacao'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'valor_solicitado' -- Valor Solicitado (R$)
                ,pr_tag_cont => fn_decimal_soa(vr_tab_crapsim(vidx).vlemprst)
                ,pr_des_erro => vr_dscritic);
    --
    vr_contador := vr_contador+1;
    --
    IF NOT(vr_dscritic IS NULL) THEN
       pr_des_reto :=  'NOK';
       RAISE vr_exc_erro;
    END IF;
    END IF;
   --
   END LOOP;
   --/
  END monta_xml_retorno;

  --/ valida se temp table foi alimentada com dados de simulacao
  FUNCTION fn_existe_simulacao RETURN BOOLEAN IS
  BEGIN

    RETURN ( vr_tab_crapsim.count > 0 );

  END fn_existe_simulacao;
  --
  --
  BEGIN
    
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  -- Se não encontrar
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    -- Montar mensagem de critica
    vr_cdcritic:= 1;
    CLOSE BTCH0001.cr_crapdat;
    RAISE vr_exc_erro;
  ELSE
    -- Apenas fechar o cursor
    CLOSE BTCH0001.cr_crapdat;
  END IF;
  --
  --/ aqui setamos as variaveis globais para filtro de data dentro da empr0018   
  vr_dtmvtolt_ini := rw_crapdat.dtmvtolt - nvl(GENE0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_DIAS_EXIBE_PROP_IB'), 0);
  vr_dtmvtolt_fim := rw_crapdat.dtmvtolt;
  --/ Pegando a data inicial para filtro, limitando pelos dias parametrizados
  vr_dtmvtolt_ini := GREATEST(vr_dtmvtolt_ini,pr_dtmvtolt_ini);
  --/ Pegando a data final para filtro, limitando pelos dias parametrizados
  vr_dtmvtolt_fim := GREATEST(vr_dtmvtolt_ini,pr_dtmvtolt_fim);   
  --/
  empr0018.pc_busca_simulacoes(pr_cdcooper => pr_cdcooper,
                               pr_cdagenci => pr_cdagenci,
                               pr_nrdcaixa => pr_nrdcaixa,
                               pr_cdoperad => pr_cdoperad,
                               pr_nmdatela => 'ATENDA',
                               pr_cdorigem => pr_cdorigem,
                               pr_nrdconta => pr_nrdconta,
                               pr_idseqttl => pr_idseqttl,
                               pr_dtmvtolt => vr_dtmvtolt,
                               pr_flgerlog => sys.diutil.int_to_bool(pr_flgerlog),
                               pr_datainic => vr_dtmvtolt_ini,
                               pr_datafina => vr_dtmvtolt_fim,
                               pr_tcrapsim => vr_tab_crapsim,
                               pr_cdcritic => vr_cdcritic,
                               pr_des_erro => vr_des_erro,
                               pr_des_reto => pr_des_reto,
                               pr_tab_erro => vr_tab_erro );

   IF NVL(pr_des_reto,'NOK') != 'OK' THEN

     vr_dscritic := vr_des_erro;
     RAISE vr_exc_erro;

   END IF;

   --
   IF NOT( fn_existe_simulacao ) THEN

     vr_dscritic := 'Nao encontrado dados de simulacao';
     RAISE vr_exc_erro;

   END IF;
   --
   monta_xml_retorno();
   --
   pr_retorno := vr_retorno;
   --
   pr_des_reto := 'OK';
   --
  EXCEPTION
   WHEN vr_exc_erro THEN

     pr_des_reto := 'NOK';
     pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' ||vr_dscritic||
                                      '</Erro></Root>');
   WHEN OTHERS THEN

     pr_des_reto := 'NOK';
     pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' ||'ERRO NAO TRATADO NA pc_consulta_simulacoes: '||SQLERRM||
                                      '</Erro></Root>');
   END pc_consulta_simulacoes;

  --/ procedure para consulta de simulacao
  PROCEDURE pc_consulta_simulacao(pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo da cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE -- Número da Conta do Cooperado
                                 ,pr_cdorigem IN INTEGER -- Identificador do CANAL de origem da Consulta – Valor fixo '3' para Internet
                                 ,pr_cdoperad IN VARCHAR2-- codigo do operador
                                 ,pr_nrcpfope IN VARCHAR2 -- Número do CPF do operador do InternetBank
                                 ,pr_nripuser IN VARCHAR2 --  IP de acesso do cooperado
                                 ,pr_iddispos IN VARCHAR2 -- ID do dispositivo móvel
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE  -- Código de PA do canal de atendimento – Valor '90' para Internet
                                 ,pr_nrdcaixa IN INTEGER -- Código de caixa do canal de atendimento – Valor fixo '900' para Internet
                                 ,pr_nrsimula IN crapsim.nrsimula%TYPE
                                 ,pr_flgerlog IN NUMBER -- Flag de Geração de Log (O campo não deve ser exposto no barramento e deverá assumir o valor “true” como default.
                                 ,pr_des_reto OUT VARCHAR  -- Retorno OK / NOK
                                 ,pr_retorno OUT xmltype -- retorno do tipo xml
                                  ) IS
  --
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gera_demonst_contrato
  --  Sistema  : CREDITO
  --  Sigla    : EMPR
  --  Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  --  Data     : Dez/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Rotina focando na busca dos dados da simulação realizada
  --
  ---------------------------------------------------------------------------------------------------------------
  --
  --
  vr_tab_erro gene0001.typ_tab_erro;
  vr_dtmvtolt crapdat.dtmvtolt%TYPE;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_retorno xmltype;
  vidx PLS_INTEGER;
  vr_dscritic VARCHAR2(1000);
  vr_des_erro VARCHAR2(4000);
  --
   CURSOR cr_simulacao(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapsim.nrdconta%TYPE
                      ,pr_nrsimula IN crapsim.nrsimula%TYPE ) IS
     SELECT *
       FROM crapsim sim
      WHERE sim.cdcooper = pr_cdcooper
        AND sim.nrdconta = pr_nrdconta
        AND sim.nrsimula = pr_nrsimula;
    --
    rw_crapsim cr_simulacao%ROWTYPE;
    --
    PROCEDURE pc_busca_simulacao IS

    BEGIN

      OPEN cr_simulacao(pr_cdcooper
                       ,pr_nrdconta
                       ,pr_nrsimula);
       FETCH cr_simulacao INTO rw_crapsim;
      CLOSE cr_simulacao;

    END pc_busca_simulacao;
    --
    --
    PROCEDURE monta_xml_retorno IS
    vr_contador NUMBER;
    vr_contador_bens NUMBER;
    --
    FUNCTION fn_retorna_segmento(pr_segmento tbepr_segmento.idsegmento%TYPE) RETURN tbepr_segmento.dssegmento%TYPE IS

      CURSOR cr_segmento(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_segmento IN tbepr_segmento.idsegmento%TYPE) IS
       SELECT seg.dssegmento dssegmento
         FROM tbepr_segmento seg
        WHERE seg.cdcooper = pr_cdcooper
          AND seg.idsegmento = pr_segmento;
    --
    rw_segmento cr_segmento%ROWTYPE;
    --
    BEGIN

      OPEN cr_segmento(pr_cdcooper
                      ,pr_segmento);
      FETCH cr_segmento INTO rw_segmento;
      CLOSE cr_segmento;

      RETURN rw_segmento.dssegmento;

    END fn_retorna_segmento;

    FUNCTION existe_bem_vinculado(pr_crapsim IN cr_simulacao%ROWTYPE) RETURN BOOLEAN IS
    vcount NUMBER;
    BEGIN

      SELECT COUNT(*)
        INTO vcount
        FROM tbepr_simulacao_bem
       WHERE cdcooper = pr_crapsim.cdcooper
         AND nrdconta = pr_crapsim.nrdconta
         AND nrsimula = pr_crapsim.nrsimula;

      RETURN ( vcount > 0 );

    END existe_bem_vinculado;
        
    BEGIN
     --/
     vr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Simulacoes/>');
     vr_contador := 0;
     vr_contador_bens := 0;
     --/
     --
        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Simulacoes'
                  ,pr_posicao  => 0
                  ,pr_tag_nova => 'simulacao'
                  ,pr_tag_cont => NULL
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'Data_simulacao' -- Data/Hora da Simulação
                  ,pr_tag_cont => fn_Data_SOA(rw_crapsim.dtmvtolt)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'validade_simulacao' -- Validade da Simulação
                  ,pr_tag_cont => fn_Data_SOA(rw_crapsim.dtvalidade) -- verificar
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'Segmento'  -- Segmento
                  ,pr_tag_cont => fn_retorna_segmento(rw_crapsim.idsegmento)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'valor_solicitado' -- Valor Solicitado (R$)
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.vlemprst)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'valor_emprestimo' -- Valor do Empréstimo (R$)
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.vlemprst + rw_crapsim.vliofepr + rw_crapsim.vlrtarif)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'numero_parcelas' -- Número de Parcelas
                  ,pr_tag_cont => rw_crapsim.qtparepr
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'valor_parcela' -- Valor da Parcela (R$)
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.vlparepr)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'taxa_juros' -- Taxa de Juros
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.txmensal)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao' -- CET
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'cet'
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.percetop)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'IOF'        -- IOF (R$)
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.vliofepr)
                  ,pr_des_erro => vr_dscritic);
        --
        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'tarifa' -- TARIFA (R$)
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.vlrtarif)
                  ,pr_des_erro => vr_dscritic);
        --
        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'vencimento_primeira_parcela' -- Vencimento da 1ª Parcela
                  ,pr_tag_cont => fn_Data_SOA(rw_crapsim.dtdpagto)
                  ,pr_des_erro => vr_dscritic);
        --
        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'idpessoa' -- idpessoa
                  ,pr_tag_cont => rw_crapsim.idpessoa
                  ,pr_des_erro => vr_dscritic);
        --
        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'nrseq_email' -- nrseq_email
                  ,pr_tag_cont => rw_crapsim.nrseq_email
                  ,pr_des_erro => vr_dscritic);
        --
        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'email_para_retorno' -- email_para_retorno
                  ,pr_tag_cont => fn_retorna_email(rw_crapsim.idpessoa,rw_crapsim.nrseq_email)
                  ,pr_des_erro => vr_dscritic);
        --
        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'nrseq_telefone' -- nrseq_telefone
                  ,pr_tag_cont => rw_crapsim.nrseq_telefone
                  ,pr_des_erro => vr_dscritic);
        --
        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'telefone'   --  Telefone
                  ,pr_tag_cont => fn_retorna_telefone(rw_crapsim.idpessoa,rw_crapsim.nrseq_telefone)
                  ,pr_des_erro => vr_dscritic);
         --
         --/
         IF existe_bem_vinculado(rw_crapsim)
           THEN
            --
            insere_tag(pr_xml      => vr_retorno
                      ,pr_tag_pai  => 'simulacao'
                      ,pr_posicao  => vr_contador
                      ,pr_tag_nova => 'bens'   --  Telefone
                      ,pr_tag_cont => NULL
                      ,pr_des_erro => vr_dscritic);
             --
             FOR rw_bens IN
                 ( SELECT cdcooper,
                          nrdconta,
                          nrsimula,
                          nrseqbem,
                          idmarca,
                          dsmarca,
                          idmodelo,
                          dsmodelo,
                          dsano_modelo,
                          dscatbem,
                          cdfipe,
                          vlfipe,
                          vlbem
                     FROM tbepr_simulacao_bem
                    WHERE cdcooper = rw_crapsim.cdcooper
                      AND nrdconta = rw_crapsim.nrdconta
                      AND nrsimula = rw_crapsim.nrsimula )
              LOOP
                --
                insere_tag(pr_xml      => vr_retorno
                          ,pr_tag_pai  => 'bens'
                          ,pr_posicao  => vr_contador
                          ,pr_tag_nova => 'bem'   --  Telefone
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

                insere_tag(pr_xml      => vr_retorno
                          ,pr_tag_pai  => 'bem'
                          ,pr_posicao  => vr_contador_bens
                          ,pr_tag_nova => 'valor_veículo'   --  Telefone
                          ,pr_tag_cont => rw_bens.vlbem
                          ,pr_des_erro => vr_dscritic);

                insere_tag(pr_xml      => vr_retorno
                          ,pr_tag_pai  => 'bem'
                          ,pr_posicao  => vr_contador_bens
                          ,pr_tag_nova => 'valor_fipe_veiculo'   --  Telefone
                          ,pr_tag_cont => rw_bens.vlfipe
                          ,pr_des_erro => vr_dscritic);

                insere_tag(pr_xml      => vr_retorno
                          ,pr_tag_pai  => 'bem'
                          ,pr_posicao  => vr_contador_bens
                          ,pr_tag_nova => 'id_marca'   --  Telefone
                          ,pr_tag_cont => rw_bens.idmarca
                          ,pr_des_erro => vr_dscritic);

                insere_tag(pr_xml      => vr_retorno
                          ,pr_tag_pai  => 'bem'
                          ,pr_posicao  => vr_contador_bens
                          ,pr_tag_nova => 'descricao_marca'   --  Telefone
                          ,pr_tag_cont => rw_bens.dsmarca
                          ,pr_des_erro => vr_dscritic);

                insere_tag(pr_xml      => vr_retorno
                          ,pr_tag_pai  => 'bem'
                          ,pr_posicao  => vr_contador_bens
                          ,pr_tag_nova => 'id_modelo'   --  Telefone
                          ,pr_tag_cont => rw_bens.idmodelo
                          ,pr_des_erro => vr_dscritic);

                insere_tag(pr_xml      => vr_retorno
                          ,pr_tag_pai  => 'bem'
                          ,pr_posicao  => vr_contador_bens
                          ,pr_tag_nova => 'descricao_modelo'   --  Telefone
                          ,pr_tag_cont => rw_bens.dsmodelo
                          ,pr_des_erro => vr_dscritic);

                insere_tag(pr_xml      => vr_retorno
                          ,pr_tag_pai  => 'bem'
                          ,pr_posicao  => vr_contador_bens
                          ,pr_tag_nova => 'ano_modelo'   --  Telefone
                          ,pr_tag_cont => rw_bens.dsano_modelo
                          ,pr_des_erro => vr_dscritic);
                --
               vr_contador_bens := vr_contador_bens+1;
             --
             END LOOP;
         END IF;
      --
      vr_contador := vr_contador+1;
      --
      IF NOT(vr_dscritic IS NULL) THEN
         pr_des_reto :=  'NOK';
         RAISE vr_exc_erro;
      END IF;
     --
     --/
    END monta_xml_retorno;

    --/ valida se variavel de registro foi alimentada com dados de simulacao
    FUNCTION fn_existe_simulacao RETURN BOOLEAN IS
    BEGIN

      RETURN ( NOT( rw_crapsim.nrsimula IS NULL )  );

    END fn_existe_simulacao;
    --
    --
    BEGIN
    --
    pc_busca_simulacao();
    --
    IF NOT( fn_existe_simulacao ) THEN

       vr_dscritic := 'Nao encontrado dados de simulacao';
       RAISE vr_exc_erro;

    END IF;
    --
    monta_xml_retorno();
    --
    pr_retorno := vr_retorno;
    --
    pr_des_reto := 'OK';
    --
  EXCEPTION
   WHEN vr_exc_erro THEN
     --
     pr_des_reto := 'NOK';
     pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' ||vr_dscritic||
                                      '</Erro></Root>');
   WHEN OTHERS THEN
     --
     pr_des_reto := 'NOK';
     pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' ||'ERRO NAO TRATADO NA pc_consulta_simulacao: '||SQLERRM||
                                      '</Erro></Root>');
  END pc_consulta_simulacao;

  --/ procedure para consulta de propostas
  PROCEDURE pc_consulta_propostas(pr_cdcooper IN crapcop.cdcooper%TYPE              --  Código da Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE              --  Número da Conta do Cooperado
                                 ,pr_idseqttl IN INTEGER                            --  Titularidade do Cooperado
                                 ,pr_cdoperad IN VARCHAR2                           --  codigo do operador
                                 ,pr_nrcpfope IN VARCHAR2                           --  Número do CPF do operador do InternetBank
                                 ,pr_nripuser IN VARCHAR2                           --  IP de acesso do cooperado
                                 ,pr_iddispos IN VARCHAR2                           --  ID do dispositivo móvel
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE              --  Código de PA do canal de atendimento – Valor '90' para Internet
                                 ,pr_nrdcaixa IN NUMBER                             --  Código de caixa do canal de atendimento – Valor fixo '900' para Internet
                                 ,pr_dtmvtolt_ini IN crapdat.dtmvtolt%TYPE          --  Data de início para pesquisa
                                 ,pr_dtmvtolt_fim IN crapdat.dtmvtolt%TYPE          --  Data de fim para pesquisa
                                 ,pr_situacao IN NUMBER DEFAULT NULL                --  Situação da Proposta (0 – Em Análise,1 – Aprovado,2 – Concluído,3 – Expirado,4 – Cancelado)
                                 ,pr_cdorigem crawepr.cdorigem%TYPE                 --  Identificador do CANAL de origem da Consulta – Valor fixo '3' para Internet
                                 ,pr_flgerlog IN NUMBER                             --  Flag de Geração de Log (O campo não deve ser exposto no barramento e deverá assumir o valor “true” como default.
                                 ,pr_des_reto OUT VARCHAR                           --> Retorno OK / NOK
                                 ,pr_idsegmento IN tbepr_segmento .idsegmento%TYPE  --> Id identificador do Segmento da Simulação
                                 ,pr_retorno OUT xmltype                            --> retorno do tipo xml
                                 ) IS
  --
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_consulta_propostas
  --  Sistema  : CREDITO
  --  Sigla    : EMPR
  --  Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  --  Data     : Dez/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Rotina focando na busca dos dados das propostas realizadas
  --
  ---------------------------------------------------------------------------------------------------------------
  --
  --
  -- *** legenda para o parametro pr_situacao ****
  -- ================================================================================================
  --                                                                                                  *
  --  Código Situação ||   Descrição Situação ||  Situação (insitest) ||    Decisão (insitapr)        *
  --  0                ||  Em Análise         ||                      ||    0, 5 ou 6                 *
  --  1                ||  Aprovado           ||                     ||     1                        *
  --  2                ||  Concluído           ||                     ||     2 ou 3 ou 4 ou 6          *
  --  3                ||  Expirado           ||  4 ou 5              ||                              *
  --  4                ||  Cancelado           ||  6                  ||                              *
  -- ================================================================================================
  --
  vr_tab_erro gene0001.typ_tab_erro;
  vr_dtmvtolt crapdat.dtmvtolt%TYPE;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_retorno xmltype;
  vr_reg_crawepr empr0018.typ_reg_crawepr;
  vr_tab_crawepr empr0018.typ_tab_crawepr;

  vidx PLS_INTEGER;
  vr_dscritic VARCHAR2(1000);
  vr_des_erro VARCHAR2(4000);
  --
  --
  CURSOR cr_crawepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN crawepr.nrdconta%TYPE
                   ,pr_cdorigem IN crawepr.cdorigem%TYPE
                   ,pr_dtmvtolt_ini IN DATE
                   ,pr_dtmvtolt_fim IN DATE
                   ,pr_situacao IN NUMBER
                    ) IS
   SELECT nrdconta,
          nrctremp,
          vlemprst,
          qtpreemp,
          vlpreemp,
          cdlcremp,
          cdfinemp,
          qtdialib,
          dsobserv,
          nrctrliq##1,
          nrctrliq##2,
          nrctrliq##3,
          nrctrliq##4,
          nrctrliq##5,
          nrctrliq##6,
          nrctrliq##7,
          nrctrliq##8,
          nrctrliq##9,
          nrctrliq##10,
          wepr.dtmvtolt,
          flgimppr,
          txminima,
          txbaspre,
          txdiaria,
          flgimpnp,
          cdcomite,
          nmchefia,
          nrctaav1,
          nrctaav2,
          dsendav1##1,
          dsendav1##2,
          dsendav2##1,
          dsendav2##2,
          nmdaval1,
          nmdaval2,
          dscpfav1,
          dscpfav2,
          dtvencto,
          cdoperad,
          flgpagto,
          dtdpagto,
          qtpromis,
          dscfcav1,
          dscfcav2,
          nmcjgav1,
          nmcjgav2,
          dsnivris,
          dsnivcal,
          tpdescto,
          wepr.cdcooper,
          dtaprova,
          insitapr,
          cdopeapr,
          hraprova,
          percetop,
          dsoperac,
          dtaltniv,
          idquapro,
          dsobscmt,
          dtaltpro,
          tpemprst,
          txmensal,
          dtlibera,
          flgokgrv,
          wepr.progress_recid,
          qttolatr,
          cdorigem,
          nrconbir,
          inconcje,
          nrseqrrq,
          nrseqpac,
          insitest,
          dtenvest,
          hrenvest,
          cdagenci,
          hrinclus,
          dtdscore,
          dsdscore,
          cdopeste,
          flgaprvc,
          dtenefes,
          dtrefatu,
          dsprotoc,
          dtenvmot,
          hrenvmot,
          idcarenc,
          dtcarenc,
          tpatuidx,
          cddindex,
          txjurvar,
          nrliquid,
          dsnivori,
          idfiniof,
          idcobope,
          idcobefe,
          inliquid_operac_atraso,
          vlempori,
          vlpreori,
          dsratori,
          cdopealt,
          dtexpira,
          flgpreap,
          flgdocdg,
          dtanulac,
          dtulteml
     FROM crawepr wepr
         ,crapdat dat
    WHERE wepr.cdcooper = pr_cdcooper
      AND wepr.nrdconta = pr_nrdconta
      AND wepr.dtmvtolt BETWEEN pr_dtmvtolt_ini AND pr_dtmvtolt_fim
      AND ( (
            ( pr_situacao = 0 AND wepr.insitapr IN (0,5,6) ) -- '0-Em estudo/5-Derivar/6-Erro'
            OR
            ( pr_situacao = 1 AND wepr.insitapr IN (1) AND wepr.insitest = 3 ) OR -- 1-Aprovado
            ( pr_situacao = 2 AND wepr.insitapr IN (2,3,4) ) -- 2-Nao aprovado/3-Restricao/4-Refazer/
            )
            OR
            (
            ( pr_situacao = 3 AND wepr.insitest IN (4,5) ) -- Situacao da proposta na Esteira 4 ou 5-Expirado
            OR
            ( pr_situacao = 4 AND wepr.insitest IN (6) ) -- Situacao da proposta na Esteira 6-cancelado
            )
            OR
            ( pr_situacao IS NULL )
          )
      AND nvl(wepr.nrsimula,0) > 0
      AND wepr.cdorigem = pr_cdorigem 
      AND wepr.dtrefatu >= ( dat.dtmvtolt - nvl(gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_DIAS_EXIBE_PROP_IB'), 0) )
      AND NOT EXISTS ( SELECT 1
                         FROM crapepr epr
                        WHERE epr.cdcooper = wepr.cdcooper
                          AND epr.nrdconta = wepr.nrdconta
                          AND epr.nrctremp = wepr.nrctremp )
      AND wepr.cdcooper = dat.cdcooper
      ORDER BY wepr.nrctremp;
  rw_crawepr  cr_crawepr%ROWTYPE;
  --
  --
  PROCEDURE monta_xml_retorno IS
  vr_contador NUMBER;
  --
  FUNCTION fn_retorna_segmento(pr_nrctremp crawepr.nrctremp%TYPE) RETURN tbepr_segmento.dssegmento%TYPE IS

    CURSOR cr_segmento(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS

       SELECT seg.dssegmento dssegmento
         FROM tbepr_segmento seg
             ,crawepr wpr
             ,crapsim sim
        WHERE wpr.cdcooper = pr_cdcooper
          AND wpr.nrdconta = pr_nrdconta
          AND wpr.nrctremp = pr_nrctremp
          AND sim.cdcooper = wpr.cdcooper
          AND sim.nrdconta = wpr.nrdconta
          AND sim.nrsimula = wpr.nrsimula
          AND seg.cdcooper = sim.cdcooper
          AND seg.idsegmento = sim.idsegmento;
    --
  rw_segmento cr_segmento%ROWTYPE;
    --
  BEGIN

    OPEN cr_segmento(pr_cdcooper
                      ,pr_nrdconta
                      ,pr_nrctremp);
    FETCH cr_segmento INTO rw_segmento;
    CLOSE cr_segmento;

    RETURN rw_segmento.dssegmento;

  END fn_retorna_segmento;
  
  FUNCTION fn_retornar_Situacao(insitapr NUMBER, insitest number) RETURN NUMBER IS
  BEGIN
    RETURN CASE 
      WHEN insitest = 6 THEN 4 
      WHEN insitest IN (4,5) THEN 3
      WHEN insitapr in (0,5,6) THEN 0       
      WHEN insitapr = 1 THEN 1
      WHEN insitapr IN (2,3,4) THEN 2      
      WHEN insitest = 6 THEN 4 
    END;  
  END fn_retornar_Situacao; 

  BEGIN
   --/
   vr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Propostas/>');
   vr_contador := 0;
   --/
   FOR vidx IN vr_tab_crawepr.first..vr_tab_crawepr.count LOOP

    /* Data/Hora da Simulação
       Segmento
       Quantidade de Parcelas
       Valor da Parcela
       Valor do Solicitado */

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'Propostas'
                ,pr_posicao  => 0
                ,pr_tag_nova => 'proposta'
                ,pr_tag_cont => NULL
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'proposta'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'cdcooper' -- codigo da cooperativa
                ,pr_tag_cont => vr_tab_crawepr(vidx).cdcooper
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'proposta'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'nrdconta' -- numero da conta
                ,pr_tag_cont => vr_tab_crawepr(vidx).nrdconta
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'proposta'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'nrctremp' -- numero da proposta
                ,pr_tag_cont => vr_tab_crawepr(vidx).nrctremp
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'proposta'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'Data_proposta' -- Data da Proposta
                ,pr_tag_cont => fn_data_soa(vr_tab_crawepr(vidx).dtmvtolt)
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'proposta'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'Segmento'  -- Segmento
                ,pr_tag_cont => fn_retorna_segmento(vr_tab_crawepr(vidx).nrctremp)
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'proposta'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'numero_parcelas' -- Quantidade de Parcelas
                ,pr_tag_cont => vr_tab_crawepr(vidx).qtpreemp
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'proposta'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'valor_parcela' -- Valor da Parcela
                ,pr_tag_cont => fn_decimal_soa(vr_tab_crawepr(vidx).vlpreemp)
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'proposta'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'valor_solicitado' -- Valor Solicitado (R$)
                ,pr_tag_cont => fn_decimal_soa(vr_tab_crawepr(vidx).vlempori)
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'proposta'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'valor_emprestimo' -- valor_emprestimo
                ,pr_tag_cont => fn_decimal_soa(vr_tab_crawepr(vidx).vlemprst)
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'proposta'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'cod_situacao'    -- cod_situacao
                ,pr_tag_cont => fn_retornar_Situacao(vr_tab_crawepr(vidx).insitapr, vr_tab_crawepr(vidx).insitest)
                ,pr_des_erro => vr_dscritic);

      insere_tag(pr_xml      => vr_retorno
                ,pr_tag_pai  => 'proposta'
                ,pr_posicao  => vr_contador
                ,pr_tag_nova => 'situacao'        -- situacao
                ,pr_tag_cont => get_dssituacao(fn_retornar_Situacao(vr_tab_crawepr(vidx).insitapr, vr_tab_crawepr(vidx).insitest))
                ,pr_des_erro => vr_dscritic);
    --
    vr_contador := vr_contador+1;
    --
    IF NOT(vr_dscritic IS NULL) THEN
       pr_des_reto :=  'NOK';
       RAISE vr_exc_erro;
    END IF;
   --
   END LOOP;
   --/
  END monta_xml_retorno;

  --/ valida se temp table foi alimentada com dados de simulacao
  FUNCTION fn_existe_proposta RETURN BOOLEAN IS
  BEGIN

    RETURN ( vr_tab_crawepr.count > 0 );

  END fn_existe_proposta;
  --
  PROCEDURE pc_busca_propostas IS
  vidx PLS_INTEGER;
  BEGIN

     FOR rw_crawepr IN cr_crawepr (pr_cdcooper
                                  ,pr_nrdconta
                                  ,pr_cdorigem
                                  ,pr_dtmvtolt_ini
                                  ,pr_dtmvtolt_fim
                                  ,pr_situacao
                                   ) LOOP

         vidx := vr_tab_crawepr.count+1;
         vr_tab_crawepr(vidx) := rw_crawepr;

     END LOOP;

  END pc_busca_propostas;

  --
  BEGIN

   pc_busca_propostas();

   --
   IF NOT( fn_existe_proposta ) THEN

     vr_dscritic := 'Nao encontrado dados de proposta';
     RAISE vr_exc_erro;

   END IF;
   --
   monta_xml_retorno();
   --
   pr_retorno := vr_retorno;
   --
   pr_des_reto := 'OK';
   --
  EXCEPTION
   WHEN vr_exc_erro THEN
     --
     pr_des_reto := 'NOK';
     pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' ||vr_dscritic||
                                      '</Erro></Root>');
   WHEN OTHERS THEN
     --
     pr_des_reto := 'NOK';
     pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' ||'ERRO NAO TRATADO NA pc_consulta_propostas: '||SQLERRM||
                                      '</Erro></Root>');
   END pc_consulta_propostas;

  --/ procedure para consulta de proposta
  PROCEDURE pc_consulta_proposta(pr_cdcooper IN  crapcop.cdcooper%TYPE -- Código da Cooperativa
                                ,pr_nrdconta IN  crapass.nrdconta%TYPE -- Número da Conta do Cooperado
                                ,pr_cdoperad IN  VARCHAR2              -- Operador a qual a proposta deve ser vinculada – Valor '996' para Internet
                                ,pr_nrcpfope IN  VARCHAR2              -- Número do CPF do operador do InternetBank
                                ,pr_nripuser IN  VARCHAR2              -- IP de acesso do cooperado
                                ,pr_iddispos IN  VARCHAR2              -- ID do dispositivo móvel
                                ,pr_cdagenci IN  crapass.cdagenci%TYPE -- Código de PA do canal de atendimento – Valor '90' para Internet
                                ,pr_nrdcaixa IN  INTEGER               -- Código de caixa do canal de atendimento – Valor fixo '900' para Internet
                                ,pr_nrctremp IN  crawepr.nrctremp%TYPE -- Número do Contrato de Empréstimo
                                ,pr_flgerlog IN  NUMBER                -- Flag de Geração de Log (O campo não deve ser exposto no barramento e deverá assumir o valor “true” como default
                                ,pr_des_reto OUT VARCHAR               --> Retorno OK / NOK
                                ,pr_retorno  OUT XMLTYPE
                                ) IS
  --
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_consulta_proposta
  --  Sistema  : CREDITO
  --  Sigla    : EMPR
  --  Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  --  Data     : Dez/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Rotina focando na busca dos dados da proposta realizada
  --
  -- Alterações: 26/06/2019 - ( Rafael Rocha Santos - p438 - Task 23000) AmCom 
  --
  -- Alterações: 05/07/2019 - Ajuste no retorno do valor do IOF da proposta.
  --                          (P438 - Douglas Pagel / AMcom).
  --
  --             10/07/2019 - Ajuste na composição da data de validade da proposta
  --                          (P438 - Douglas Pagel / AMcom)
  --
  --
  ---------------------------------------------------------------------------------------------------------------
  --
  --
  --
    vr_tab_erro gene0001.typ_tab_erro;
    vr_dtmvtolt crapdat.dtmvtolt%TYPE;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_retorno  xmltype;
    vidx        PLS_INTEGER;
    vr_dscritic VARCHAR2(1000);
    vr_bloq     NUMBER(1);
    --/ 
    vr_qtdibaut    INTEGER :=0;
    vr_qtdibapl    INTEGER :=0;
    vr_qtdibsem    INTEGER :=0; 
    vr_dstextab    craptab.dstextab%TYPE;
    vr_dtvalidade  crawepr.dtexpira%TYPE;
    vr_prazo_efetiva NUMBER(10);
    vr_vlemprestado NUMBER;
    vr_vlsolicitado NUMBER;
    vr_vliofepr     NUMBER;
    vr_vliofpri     NUMBER;
    vr_vliofadi     NUMBER;
     vr_vlpreclc    NUMBER;
    vr_flgimune     pls_integer;
    --
    --
    CURSOR cr_crawepr(pr_cdcooper IN crapcop.cdcooper%TYPE -- Código da Cooperativa
                     ,pr_nrdconta IN crawepr.nrdconta%TYPE
                     ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
     SELECT epr.nrdconta,
            epr.nrctremp,
            epr.vlemprst,
            epr.qtpreemp,
            epr.vlpreemp,
            epr.cdlcremp,
            epr.cdfinemp,
            epr.qtdialib,
            epr.dsobserv,
            epr.dtmvtolt,
            epr.flgimppr,
            epr.txminima,
            epr.txbaspre,
            epr.txdiaria,
            epr.flgimpnp,
            epr.cdcomite,
            epr.nmchefia,
            epr.nrctaav1,
            epr.nrctaav2,
            epr.nmdaval1,
            epr.nmdaval2,
            epr.dscpfav1,
            epr.dscpfav2,
            epr.dtvencto,
            epr.cdoperad,
            epr.flgpagto,
            epr.dtdpagto,
            epr.qtpromis,
            epr.dscfcav1,
            epr.dscfcav2,
            epr.nmcjgav1,
            epr.nmcjgav2,
            epr.dsnivris,
            epr.dsnivcal,
            epr.tpdescto,
            epr.cdcooper,
            epr.dtaprova,
            epr.insitapr,
            epr.cdopeapr,
            epr.hraprova,
            epr.percetop,
            epr.dsoperac,
            epr.dtaltniv,
            epr.idquapro,
            epr.dsobscmt,
            epr.dtaltpro,
            epr.tpemprst,
            epr.txmensal,
            epr.dtlibera,
            epr.flgokgrv,
            epr.progress_recid,
            epr.qttolatr,
            epr.cdorigem,
            epr.nrconbir,
            epr.inconcje,
            epr.nrseqrrq,
            epr.nrseqpac,
            epr.insitest,
            epr.dtenvest,
            epr.hrenvest,
            epr.cdagenci,
            epr.hrinclus,
            epr.dtdscore,
            epr.dsdscore,
            epr.cdopeste,
            epr.flgaprvc,
            epr.dtenefes,
            epr.dtrefatu,
            epr.dsprotoc,
            epr.dtenvmot,
            epr.hrenvmot,
            epr.idcarenc,
            epr.dtcarenc,
            epr.tpatuidx,
            epr.cddindex,
            epr.txjurvar,
            epr.nrliquid,
            epr.dsnivori,
            epr.idfiniof,
            epr.idcobope,
            epr.idcobefe,
            epr.inliquid_operac_atraso,
            epr.vlempori,
            epr.vlpreori,
            epr.dsratori,
            epr.cdopealt,
            epr.dtexpira,
            epr.flgpreap,
            epr.flgdocdg,
            epr.dtanulac,
            epr.dtulteml,
            CASE
              WHEN epr.insitest IN (4,5)  THEN

                  3  -- Expirado
                   
              WHEN epr.insitapr IN (0,5,6) THEN

                  0  -- Em Análise

              WHEN epr.insitapr IN (1) AND epr.insitest = 3 THEN

                  1  -- Aprovado

              WHEN epr.insitapr IN (2,3,4) THEN
                  2  -- Concluído

              WHEN epr.insitest IN (6)  THEN

                  4  -- Cancelado

            END cod_situacao,

            CASE
              
            WHEN epr.insitest IN (4,5)  THEN

                  'Expirado'
                  
            WHEN epr.insitapr IN (0,5,6) THEN

                  'Em Análise'

            WHEN epr.insitapr IN (1) AND epr.insitest = 3 THEN

                  'Aprovado'

            WHEN epr.insitapr IN (2,3,4) THEN

                  'Concluído'

            WHEN epr.insitest IN (6)  THEN

                  'Cancelado'

            END situacao,
            nrsimula,
            ass.inpessoa
       FROM crawepr epr
           ,crapass ass
      WHERE epr.cdcooper = pr_cdcooper
        AND epr.nrdconta = pr_nrdconta
        AND epr.nrctremp = pr_nrctremp
        AND NOT EXISTS ( SELECT 1
                           FROM crapepr con
                          WHERE con.cdcooper = epr.cdcooper
                            AND con.nrdconta = epr.nrdconta
                            AND con.nrctremp = epr.nrctremp )
        AND ass.cdcooper = epr.cdcooper
        AND ass.nrdconta = epr.nrdconta
        ORDER BY epr.nrctremp;
    --
    rw_crawepr  cr_crawepr%ROWTYPE;
    --
    CURSOR cr_crapsim(pr_nrsimula crapsim.nrsimula%TYPE) IS
     SELECT cdcooper,
            nrdconta,
            nrsimula,
            vlemprst,
            qtparepr,
            vlparepr,
            txmensal,
            txdiaria,
            cdlcremp,
            dtdpagto,
            vliofepr,
            vlrtarif,
            vllibera,
            dtmvtolt,
            hrtransa,
            cdoperad,
            dtlibera,
            vlajuepr,
            percetop,
            progress_recid,
            cdfinemp,
            idfiniof,
            vliofcpl,
            vliofadc,
            dtvalidade,
            idsegmento,
            cdorigem,
            idpessoa,
            nrseq_telefone,
            nrseq_email
       FROM crapsim
      WHERE cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta
        AND nrsimula = pr_nrsimula;
    --/
    rw_crapsim cr_crapsim%ROWTYPE;
    --/
    --
    PROCEDURE pc_busca_proposta IS
    --
    BEGIN

      OPEN cr_crawepr(pr_cdcooper
                     ,pr_nrdconta
                     ,pr_nrctremp);
       FETCH cr_crawepr INTO rw_crawepr;
      CLOSE cr_crawepr;

    END pc_busca_proposta;
    --
    PROCEDURE pc_busca_simulacao(pr_nrsimula crapsim.nrsimula%TYPE) IS
    --
    BEGIN

      OPEN cr_crapsim(pr_nrsimula);
      FETCH cr_crapsim INTO rw_crapsim;
      CLOSE cr_crapsim;

    END pc_busca_simulacao;

    --
    PROCEDURE monta_xml_retorno IS
    vr_contador NUMBER;
    --
    FUNCTION fn_retorna_segmento(pr_segmento tbepr_segmento.idsegmento%TYPE) RETURN tbepr_segmento.dssegmento%TYPE IS

      CURSOR cr_segmento(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_segmento IN tbepr_segmento.idsegmento%TYPE) IS
       SELECT seg.dssegmento dssegmento
         FROM tbepr_segmento seg
        WHERE seg.cdcooper = pr_cdcooper
          AND seg.idsegmento = pr_segmento;
    --
    rw_segmento cr_segmento%ROWTYPE;
    --
    BEGIN

      OPEN cr_segmento(pr_cdcooper
                      ,pr_segmento);
      FETCH cr_segmento INTO rw_segmento;
      CLOSE cr_segmento;

      RETURN rw_segmento.dssegmento;

    END fn_retorna_segmento;

    BEGIN
      --/
      vr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Propostas/>');
      vr_contador := 0;
      
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PAREMPREST'
                                               ,pr_tpregist => 01);
     --/   
     vr_qtdibaut := NVL(TRIM(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,93,3))),0);  -- automóvel
     vr_qtdibapl := NVL(TRIM(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,97,3))),0);  -- aplicação oriunda conta online
     vr_qtdibsem := NVL(TRIM(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,101,3))),0); -- sem garantia oriunda conta online
     --

     IF fn_tem_garantia(rw_crawepr.cdcooper, rw_crawepr.cdlcremp) THEN
       vr_prazo_efetiva := vr_qtdibaut;
     ELSE
       vr_prazo_efetiva := vr_qtdibsem;
     END IF;  
     
     IF rw_crawepr.insitapr = 1 THEN
       vr_dtvalidade := rw_crawepr.dtaprova + vr_prazo_efetiva;
     ELSE
       vr_dtvalidade := NULL;
     END IF; 
     
     vr_vlemprestado := 0;
     vr_vlsolicitado := 0;
     
     vr_vlsolicitado := rw_crawepr.vlemprst;
     vr_vlemprestado := rw_crawepr.vlemprst;
     
     vr_vliofepr := 0;
     
     tiof0001.pc_calcula_iof_epr(pr_cdcooper => rw_crawepr.cdcooper,
                                 pr_nrdconta => rw_crawepr.nrdconta,
                                 pr_nrctremp => rw_crawepr.nrctremp,
                                 pr_dtmvtolt => rw_crawepr.dtmvtolt,
                                 pr_inpessoa => rw_crawepr.inpessoa,
                                 pr_cdlcremp => rw_crawepr.cdlcremp,
                                 pr_cdfinemp => rw_crawepr.cdfinemp,
                                 pr_qtpreemp => rw_crawepr.qtpreemp,
                                 pr_vlpreemp => rw_crawepr.vlpreemp,
                                 pr_vlemprst => rw_crawepr.vlemprst,
                                 pr_dtdpagto => rw_crawepr.dtdpagto,
                                 pr_dtlibera => rw_crawepr.dtlibera,
                                 pr_tpemprst => rw_crawepr.tpemprst,
                                 pr_dtcarenc => rw_crawepr.dtcarenc,
                                 pr_qtdias_carencia => 0,
                                 pr_dscatbem => '',
                                 pr_idfiniof => rw_crawepr.idfiniof,
                                 pr_dsctrliq => '',
                                 pr_vlpreclc => vr_vlpreclc,
                                 pr_valoriof => vr_vliofepr,
                                 pr_vliofpri => vr_vliofpri,
                                 pr_vliofadi => vr_vliofadi,
                                 pr_flgimune => vr_flgimune,
                                 pr_dscritic => vr_dscritic);
                                 
     IF vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_erro;  
     END IF;
     
     IF NVL(rw_crawepr.idfiniof,0) = 1 THEN
       vr_vlemprestado := vr_vlsolicitado + nvl(vr_vliofepr,0) + nvl(rw_crapsim.vlrtarif,0);
     END IF;
     
     --/
     ------------------------------
     --  Data/Hora da Proposta
     --  Validade da Proposta
     --  Segmento
     --  Valor Solicitado (R$)
     --  Valor do Empréstimo (R$)
     --  Número de Parcelas
     --  Valor da Parcela (R$)
     --  Taxa de Juros
     --  CET
     --  IOF (R$)
     --  TARIFA (R$)
     --  Dia de Vencimento da Parcela
     --  Vencimento da 1ª Parcela
     --  E-mail para retorno
     --  Telefone
     --  Situação
     --  Retorno da Análise (Mesa de Crédito) VALIDAR     */
     --
        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Propostas'
                  ,pr_posicao  => 0
                  ,pr_tag_nova => 'Proposta'
                  ,pr_tag_cont => NULL
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'Data_proposta' -- Data/Hora da proposta
                  ,pr_tag_cont => fn_data_soa(rw_crawepr.dtmvtolt)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'nrctremp' 
                  ,pr_tag_cont => rw_crawepr.nrctremp
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'validade_proposta' -- Validade da proposta
                  ,pr_tag_cont => fn_data_soa(nvl(vr_dtvalidade,sysdate))
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'Segmento'  -- Segmento
                  ,pr_tag_cont => fn_retorna_segmento(rw_crapsim.idsegmento)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'valor_solicitado' -- Valor Solicitado (R$)
                  ,pr_tag_cont => fn_decimal_soa(vr_vlsolicitado)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'valor_emprestimo' -- Valor do Empréstimo (R$)
                  ,pr_tag_cont => fn_decimal_soa(vr_vlemprestado)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'numero_parcelas' -- Número de Parcelas
                  ,pr_tag_cont => rw_crawepr.qtpreemp
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'valor_parcela' -- Valor da Parcela (R$)
                  ,pr_tag_cont => fn_decimal_soa(rw_crawepr.vlpreemp)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'taxa_juros' -- Taxa de Juros
                  ,pr_tag_cont => fn_decimal_soa(rw_crawepr.txmensal)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta' -- CET
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'cet'
                  ,pr_tag_cont => fn_decimal_soa(rw_crawepr.percetop)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'IOF'        -- IOF (R$)
                  ,pr_tag_cont => fn_decimal_soa(vr_vliofepr) ---  verificar
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'tarifa' -- TARIFA (R$)
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.vlrtarif) -- verificar
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'vencimento_primeira_parcela' -- Vencimento da 1ª Parcela
                  ,pr_tag_cont => to_char(rw_crawepr.dtdpagto,'dd/mm/yyyy')
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'idpessoa' -- idpessoa
                  ,pr_tag_cont => rw_crapsim.idpessoa
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'nrseq_email' -- E-mail para retorno
                  ,pr_tag_cont => rw_crapsim.nrseq_email
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'email_para_retorno' -- E-mail para retorno
                  ,pr_tag_cont => fn_retorna_email(rw_crapsim.idpessoa,rw_crapsim.nrseq_email)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'nrseq_telefone' -- E-mail para retorno
                  ,pr_tag_cont => rw_crapsim.nrseq_email
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'telefone'   --  Telefone
                  ,pr_tag_cont => fn_retorna_telefone(rw_crapsim.idpessoa,rw_crapsim.nrseq_telefone)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'cod_situacao'  -- cod_situacao
                  ,pr_tag_cont => rw_crawepr.cod_situacao
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'situacao'  -- situacao
                  ,pr_tag_cont => rw_crawepr.situacao
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Proposta'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'codigo_segmento'  -- situacao
                  ,pr_tag_cont => rw_crapsim.idsegmento
                  ,pr_des_erro => vr_dscritic);

      --
      vr_contador := vr_contador+1;
      --
      IF NOT(vr_dscritic IS NULL) THEN
         pr_des_reto :=  'NOK';
         RAISE vr_exc_erro;
      END IF;
     --
     --/
    END monta_xml_retorno;

    --/ valida se variavel de registro foi alimentada com dados de simulacao
    FUNCTION fn_existe_proposta RETURN BOOLEAN IS
    BEGIN

      RETURN ( NOT( rw_crawepr.nrctremp IS NULL )  );

    END fn_existe_proposta;
    --
    --
    PROCEDURE pc_atualiza_proposta(pr_rw_crawepr IN cr_crawepr%ROWTYPE) IS      
    --
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    vr_rowid ROWID;
    vr_idprglog   tbgen_prglog.idprglog%TYPE := 0;
    --/
    BEGIN
      --/  
      rw_crapdat := fn_get_cr_crapdat(pr_cdcooper);
      --/
      -- ajustar a data do emprestimo para efetivar
      empr0012.pc_crps751 (pr_cdcooper => pr_rw_crawepr.cdcooper
                          ,pr_nrdconta => pr_rw_crawepr.nrdconta
                          ,pr_nrctremp => pr_rw_crawepr.nrctremp
                          ,pr_cdagenci => pr_rw_crawepr.cdagenci
                          ,pr_cdoperad => pr_rw_crawepr.cdoperad
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                          ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);
        -- Tratamento de erro de retorno
        IF vr_dscritic IS NOT NULL THEN
          -- Gera Log
          cecred.pc_log_programa(pr_dstiplog      => 'E', 
                                 pr_cdprograma    => 'PC_CONSULTA_PROPOSTA',
                                 pr_cdcooper      => pr_cdcooper, 
                                 pr_tpexecucao    => 0, -- Outros
                                 pr_tpocorrencia  => 1, -- erro tratado
                                 pr_cdcriticidade => 1, -- media
                                 pr_cdmensagem    => nvl(vr_cdcritic,0),
                                 pr_dsmensagem    => vr_dscritic,
                                 pr_flgsucesso    => 0,
                                 pr_idprglog      => vr_idprglog);
        END IF;

       COMMIT; 
       
    END pc_atualiza_proposta;
    --/    
    BEGIN

    --/ busca dados da proposta
    pc_busca_proposta();
    --
    --/ critica caso nao encontre dados da proposta
    IF NOT( fn_existe_proposta ) THEN

       vr_dscritic := 'Nao encontrado dados de proposta';
       RAISE vr_exc_erro;

    END IF;
    --
    --/
    IF fn_get_cr_crapdat(pr_cdcooper).dtmvtolt > rw_crawepr.dtlibera
      AND rw_crawepr.insitapr = 1 AND rw_crawepr.insitest = 3 THEN
      --/ p438 - Task 23000
      pc_atualiza_proposta(rw_crawepr);
      pc_busca_proposta();      
    END IF;
    --
    --/ busca dados da simulacao
    pc_busca_simulacao(rw_crawepr.nrsimula);

    --/ monta o xml de retorno
    monta_xml_retorno();

    --/ passando o xml para o parametro out
    pr_retorno := vr_retorno;
    --
    pr_des_reto := 'OK';
    --
  EXCEPTION
   WHEN vr_exc_erro THEN
     --
     pr_des_reto := 'NOK';
     pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' ||vr_dscritic||
                                      '</Erro></Root>');
   WHEN OTHERS THEN
     --/
     CECRED.PC_INTERNAL_EXCEPTION(pr_cdcooper => pr_cdcooper);
     vr_cdcritic := 9999;-- Erro nao tratado
     vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'pc_consulta_proposta'||'.'||sqlerrm||'.';
     --/ Log de erro de execucao
     GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_dscritic => vr_dscritic
                         ,pr_dsorigem => gene0001.vr_vet_des_origens(nvl(rw_crawepr.cdorigem,3))
                         ,pr_dstransa => 'PC_CONSULTA_PROPOSTA'
                         ,pr_dttransa => TRUNC(SYSDATE)
                         ,pr_flgtrans => 1
                         ,pr_hrtransa => GENE0002.fn_busca_time
                         ,pr_idseqttl => 0
                         ,pr_nmdatela => 'AUTOEMP'
                         ,pr_nrdconta => rw_crawepr.nrdconta
                         ,pr_nrdrowid => vr_rowid);
     --/
     pr_des_reto := 'NOK';
     pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' ||GENE0001.fn_busca_critica(1224)||
                                      '</Erro></Root>');
  END pc_consulta_proposta;

  --/ funcao para retornar o telefone atualizado do associado
  FUNCTION fn_retorna_telefone(pr_idpessoa tbcadast_pessoa.idpessoa%TYPE
                              ,pr_nrseq_telefone tbcadast_pessoa_telefone.nrseq_telefone%TYPE)
      RETURN VARCHAR2 IS
      -- Buscar dados do telefone
      CURSOR cr_telefone(pr_idpessoa tbcadast_pessoa.idpessoa%TYPE
                        ,pr_nrseq_telefone tbcadast_pessoa_telefone.nrseq_telefone%TYPE) IS
        SELECT pt.nrddd||pt.nrtelefone AS telefone
          FROM tbcadast_pessoa_telefone PT
         WHERE PT.idpessoa = pr_idpessoa
           AND PT.nrseq_telefone  = pr_nrseq_telefone;
      --/
      rw_telefone cr_telefone%ROWTYPE;

    BEGIN
     
      OPEN cr_telefone(pr_idpessoa => pr_idpessoa
                      ,pr_nrseq_telefone => pr_nrseq_telefone  );
       FETCH cr_telefone INTO rw_telefone;
      CLOSE cr_telefone;

      RETURN to_char(rw_telefone.telefone);

   END fn_retorna_telefone;
  --
  --/ funcao para retornar o email atualizado do associado
  FUNCTION fn_retorna_email(pr_idpessoa IN tbcadast_pessoa.idpessoa%TYPE
                           ,pr_nrseq_email tbcadast_pessoa_email.nrseq_email%TYPE)
                           RETURN VARCHAR2 IS
      -- Buscar dados do telefone
      CURSOR cr_email(pr_idpessoa tbcadast_pessoa.idpessoa%TYPE
                     ,pr_nrseq_email tbcadast_pessoa_email.nrseq_email%TYPE) IS
        SELECT tpe.dsemail
          FROM tbcadast_pessoa_email tpe
         WHERE tpe.idpessoa = pr_idpessoa
           AND tpe.nrseq_email = pr_nrseq_email;
           
      rw_email cr_email%ROWTYPE;

    BEGIN

      OPEN cr_email(pr_idpessoa => pr_idpessoa
                   ,pr_nrseq_email => pr_nrseq_email);
       FETCH cr_email INTO rw_email;
      CLOSE cr_email;

      RETURN nvl(rw_email.dsemail,' ');

    END fn_retorna_email;

  --/ procedure gerar proposta de emprestimo
  PROCEDURE pc_gera_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_nrdconta IN crapass.nrdconta%TYPE
                            ,pr_cdorigem IN crawepr.cdorigem%TYPE
                            ,pr_cdoperad IN crawepr.cdoperad%TYPE --> Codigo do operador
                            ,pr_nrcpfope IN VARCHAR2
                            ,pr_nripuser IN VARCHAR2
                            ,pr_iddispos IN VARCHAR2
                            ,pr_cdagenci IN crapass.cdagenci%TYPE
                            ,pr_nrdcaixa IN INTEGER
                            ,pr_nrsimula IN crapsim.nrsimula%TYPE
                            ,pr_flgerlog IN NUMBER
                            ,pr_des_reto OUT VARCHAR  --> Retorno OK / NOK
                            ,pr_retorno  OUT xmltype) IS
  --
  /*.................................................................................
  programa: pc_gera_proposta
    autor   : Rafaael (AmCom)
    data    : Dez/2019

  dados referentes ao programa:

  frequencia: sempre que for chamado.
  objetivo  : procedure para gerar propostas de emprestimo, gravando nas estruturas necessárias.
  
  Alterações: 22/07/2019 - Inclusão da validação da data de validade da simulação. (Douglas Pagel / AMcom).
    ................................................................................. */
    --
    vr_tab_erro gene0001.typ_tab_erro;
    vr_dtmvtolt crapdat.dtmvtolt%TYPE;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_retorno xmltype;
    vidx PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_nrctremp  crawepr.nrctremp%TYPE;
    vr_tab_parc_epr empr0018.typ_tab_parc_epr;
    vr_des_erro VARCHAR2(4000);
    vr_des_reto VARCHAR2(30);
    vr_qtd_diacar INTEGER;
    vr_flggrava BOOLEAN := TRUE;
    vr_des_reto_est VARCHAR2(30);   
    vr_vlfinanciado NUMBER; 
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    --
    --/ Buscar informações da simulacao
    CURSOR cr_crapsim(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrsimula IN crapsim.nrsimula%TYPE) IS
     SELECT *
       FROM crapsim sim
      WHERE sim.cdcooper = pr_cdcooper
        AND sim.nrdconta = pr_nrdconta
        AND sim.nrsimula = pr_nrsimula
        AND NOT EXISTS (SELECT 1
                          FROM crawepr wpr
                         WHERE wpr.cdcooper = sim.cdcooper
                           AND wpr.nrdconta = sim.nrdconta
                           AND wpr.nrsimula = sim.nrsimula );
    --
    rw_crapsim cr_crapsim%ROWTYPE;
    --
    PROCEDURE pc_busca_simulacao IS

    BEGIN

      OPEN cr_crapsim(pr_cdcooper,pr_nrdconta,pr_nrsimula);
       FETCH cr_crapsim INTO rw_crapsim;
      CLOSE cr_crapsim;

    END pc_busca_simulacao;
    --
    PROCEDURE monta_xml_retorno IS
    vr_contador NUMBER;
    --
    BEGIN
     --/
     vr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Simulacoes/>');
     vr_contador := 0;
     --/
     --
        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'Simulacoes'
                  ,pr_posicao  => 0
                  ,pr_tag_nova => 'simulacao'
                  ,pr_tag_cont => NULL
                  ,pr_des_erro => vr_dscritic);


        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'cdcooper' -- cdcooper
                  ,pr_tag_cont => rw_crapsim.cdcooper
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'nrdconta' -- nrdconta
                  ,pr_tag_cont => rw_crapsim.nrdconta
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'nrsimula' -- nrsimula
                  ,pr_tag_cont => rw_crapsim.nrsimula
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'vlemprst' -- vlemprst
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.vlemprst)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'qtparepr' -- qtparepr
                  ,pr_tag_cont => rw_crapsim.qtparepr
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'vlparepr' -- vlparepr
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.vlparepr)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'txmensal' -- txmensal
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.txmensal)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'txdiaria' -- txdiaria
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.txdiaria)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'cdlcremp' -- cdlcremp
                  ,pr_tag_cont => rw_crapsim.cdlcremp
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'dtdpagto' -- dtdpagto
                  ,pr_tag_cont => fn_data_soa(rw_crapsim.dtdpagto)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'vliofepr' -- vliofepr
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.vliofepr)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'vlrtarif' -- vlrtarif
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.vlrtarif)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'vllibera' -- vllibera
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.vllibera)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'dtmvtolt' -- dtmvtolt
                  ,pr_tag_cont => fn_data_soa(rw_crapsim.dtmvtolt)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'hrtransa' -- hrtransa
                  ,pr_tag_cont => rw_crapsim.hrtransa
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'cdoperad' -- cdoperad
                  ,pr_tag_cont => rw_crapsim.cdoperad
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'dtlibera' -- dtlibera
                  ,pr_tag_cont => fn_data_soa(rw_crapsim.dtlibera)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'vlajuepr' -- vlajuepr
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.vlajuepr)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'percetop' -- percetop
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.percetop)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'progress_recid' -- progress_recid
                  ,pr_tag_cont => rw_crapsim.progress_recid
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'cdfinemp' -- cdfinemp
                  ,pr_tag_cont => rw_crapsim.cdfinemp
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'idfiniof' -- idfiniof
                  ,pr_tag_cont => rw_crapsim.idfiniof
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'vliofcpl' -- vliofcpl
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.vliofcpl)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'vliofadc' -- vliofadc
                  ,pr_tag_cont => fn_decimal_soa(rw_crapsim.vliofadc)
                  ,pr_des_erro => vr_dscritic);

      /*  insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'tpemprst' -- tpemprst
                  ,pr_tag_cont => rw_crapsim.tpemprst
                  ,pr_des_erro => vr_dscritic);*/

  /*      insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'idcarenc' -- idcarenc
                  ,pr_tag_cont => vr_reg_crapsim.idcarenc
                  ,pr_des_erro => vr_dscritic);*/

/*        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'vlprecar' -- vlprecar
                  ,pr_tag_cont => rw_crapsim.vlprecar
                  ,pr_des_erro => vr_dscritic);*/

      /*  insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'dtcarenc' -- dtcarenc
                  ,pr_tag_cont => rw_crapsim.dtcarenc
                  ,pr_des_erro => vr_dscritic);
*/
        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'dtvalidade' -- dtvalidade
                  ,pr_tag_cont => fn_data_soa(rw_crapsim.dtvalidade)
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'nrseq_email' -- dsemail
                  ,pr_tag_cont => rw_crapsim.nrseq_email
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'nrseq_telefone' -- nrseq_telefone
                  ,pr_tag_cont => rw_crapsim.nrseq_telefone
                  ,pr_des_erro => vr_dscritic);

        insere_tag(pr_xml      => vr_retorno
                  ,pr_tag_pai  => 'simulacao'
                  ,pr_posicao  => vr_contador
                  ,pr_tag_nova => 'idsegmento' -- idsegmento
                  ,pr_tag_cont => rw_crapsim.idsegmento
                  ,pr_des_erro => vr_dscritic);

      --
      vr_contador := vr_contador+1;
      --
      IF NOT(vr_dscritic IS NULL) THEN
         pr_des_reto :=  'NOK';
         RAISE vr_exc_erro;
      END IF;
     --
     --/
    END monta_xml_retorno;
    --
    --/
    FUNCTION fn_existe_simulacao RETURN BOOLEAN IS
    BEGIN

      RETURN ( NOT( rw_crapsim.nrsimula IS NULL )  );

    END fn_existe_simulacao;
    --
    --
    /*PROCEDURE pc_email_esteira(pr_cdcooper IN NUMBER,
                               pr_nrdconta IN NUMBER,
                               pr_nrctremp IN NUMBER,
                               pr_dscritic IN OUT VARCHAR2) IS
    --
    --/ Esta subrotina nao deverá abortar a operação caso dê algum tipo de erro
    --
    vr_cdprogra CONSTANT VARCHAR2(80) := 'PC_GERA_PROPOSTA';
    vr_conteudo VARCHAR2(4000);
    vr_email_dest VARCHAR2(4000); 
    vr_dscritic crapcri.dscritic%TYPE;   
    --/
    FUNCTION fn_get_email_pa(pr_cdcoooper IN NUMBER,                              
                              pr_nrdconta IN NUMBER) RETURN VARCHAR2 IS
      vr_email crapage.dsdemail%TYPE;
      BEGIN
        SELECT g.dsdemail 
          INTO vr_email
          FROM crapass a,
               crapage g
         WHERE a.cdcooper = g.cdcooper
           AND a.cdagenci = g.cdagenci
           AND a.cdcooper = pr_cdcoooper
           AND a.nrdconta = pr_nrdconta;

      RETURN vr_email;     
      EXCEPTION WHEN OTHERS
      THEN 
        RETURN NULL; 
    END fn_get_email_pa;
    --/   
    BEGIN
      --
      --/ aqui ele busca o e-mail do PA, caso nao encontre no cadastro, busca o que estiver parametrizado
      vr_email_dest := nvl(fn_get_email_pa(pr_cdcooper,pr_nrdconta),
                           gene0001.fn_param_sistema('CRED',pr_cdcooper,'ERRO_EMAIL_ESTEIRA'));
      --
      -- Gravar conteudo do email, controle com substr para não estourar campo texto
      vr_conteudo := substr('Ocorreu erro no envio da proposta  '||pr_nrctremp||' da conta  '||pr_nrdconta||', originada na conta online.'
                          ||'Para o cooperado receber um retorno da analise a proposta deverá ser enviada novamente.'
                          ||'Acesse  o Aimaro> Atenda> Empréstimos e faça o envio da proposta.',1,4000);
      --
      --/      
      IF NOT ( vr_email_dest IS NULL )
        THEN
      
        gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                  ,pr_cdprogra        => vr_cdprogra
                                  ,pr_des_destino     => vr_email_dest
                                  ,pr_des_assunto     => 'Falha no envio de proposta para o Motor de Credito'
                                  ,pr_des_corpo       => vr_conteudo
                                  ,pr_des_anexo       => NULL
                                  ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                  ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dscritic);
                                  
      END IF;                                  
      --                            
      --/
      IF TRIM(vr_dscritic) IS NULL THEN
        COMMIT;
      END IF;
      
    EXCEPTION WHEN OTHERS    
      THEN
        NULL;
    END pc_email_esteira;
*/    --
    --/
    /*PROCEDURE pc_inclui_proposta_esteira(pr_cdcooper IN crapcop.cdcooper%TYPE
                                        ,pr_cdagenci IN crapass.cdagenci%TYPE 
                                        ,pr_cdoperad IN crawepr.cdoperad%TYPE --> Codigo do operador                                                             
                                        ,pr_cdorigem IN crawepr.cdorigem%TYPE            
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE 
                                        ,pr_nrctremp IN crawepr.nrctremp%TYPE
                                        ,pr_dtmvtolt IN DATE 
                                        ,pr_des_reto IN OUT VARCHAR2
                                        ) IS
      vr_dsmensag VARCHAR2(500);
      vr_cdcritic_esteira crapcri.cdcritic%TYPE;
      vr_dscritic_esteira VARCHAR2(4000); 
      vr_aux_log_rowid ROWID;
      vr_qtsegundos NUMBER;
      --
      FUNCTION fn_getsegundos RETURN NUMBER IS
      BEGIN
        RETURN to_number(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                   pr_cdcooper => 0,
                                                   pr_cdacesso => 'ANALISE_AUTO_QTSEGUNDOS'));
      EXCEPTION WHEN OTHERS
        THEN
          RETURN NULL;
      END fn_getsegundos;
    
    BEGIN
    --/
      pr_des_reto := 'OK';
      --/      
      vr_qtsegundos := NVL(fn_getsegundos(),10);
      
      este0001.pc_setqtsegund(vr_qtsegundos);
      --/
      este0001.pc_incluir_proposta_est(pr_cdcooper => pr_cdcooper,
                                       pr_cdagenci => pr_cdagenci,
                                       pr_cdoperad => pr_cdoperad,
                                       pr_cdorigem => pr_cdorigem,
                                       pr_nrdconta => pr_nrdconta,
                                       pr_nrctremp => vr_nrctremp,
                                       pr_dtmvtolt => rw_crapsim.dtmvtolt,
                                       pr_nmarquiv => NULL,
                                       pr_dsmensag => vr_dsmensag,
                                       pr_cdcritic => vr_cdcritic_esteira,
                                       pr_dscritic => vr_dscritic_esteira);
     --
     --/
     
     --Geração de LOG
     GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper 
                        , pr_cdoperad => pr_cdoperad
                        , pr_dscritic => vr_dscritic_esteira
                        , pr_dsorigem => gene0001.vr_vet_des_origens(pr_cdorigem)
                        , pr_dstransa => 'Envio de proposta para analise'
                        , pr_dttransa => TRUNC(SYSDATE)
                        , pr_flgtrans => 1 
                        , pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS'))
                        , pr_idseqttl => 0
                        , pr_nmdatela => ''
                        , pr_nrdconta => pr_nrdconta
                        , pr_nrdrowid => vr_aux_log_rowid); 
                          
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Simulacao'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => rw_crapsim.nrsimula);
                                 
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Proposta'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => vr_nrctremp);      
                                 
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Retorno'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => vr_dsmensag);                                     
                                 
     IF vr_cdcritic_esteira <> 0 OR  NOT ( TRIM(vr_dscritic_esteira) IS NULL )
       THEN
         pr_des_reto := 'NOK';
     END IF;    
    --
    --
    END pc_inclui_proposta_esteira;
*/    --
    --
    FUNCTION fn_libera_gravacao(pr_cdcooper IN crapcop.cdcooper%TYPE
                               ,pr_nrdconta IN crapass.nrdconta%TYPE
                               ,pr_nrsimula IN crapsim.nrsimula%TYPE
                               ,pr_cdorigem IN crawepr.cdorigem%TYPE)
     --/
     RETURN BOOLEAN IS
     vtot_propostas NUMBER;
     rw_seg tbepr_segmento%ROWTYPE;
     --
     --/
     FUNCTION tot_propostas_intervalo(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                      pr_nrdconta IN crapass.nrdconta%TYPE,
                                      pr_cdorigem IN crawepr.cdorigem%TYPE,
                                      pr_rw_segmento IN tbepr_segmento%ROWTYPE) RETURN NUMBER IS
     --/
     vr_propostas_intervalo NUMBER :=0;
     vr_hrsssss NUMBER;
     vr_dias NUMBER;
     --/
     --/
     BEGIN
     --
      FOR rw_count IN
        (SELECT round( 
                (to_date(to_char(sysdate, 'dd/mm/yyyy hh24:mi'),'dd/mm/yyyy hh24:mi') 
                 -
                 to_date(to_char(trunc(wpr.dtinclus),'dd/mm/yyyy')||' '||to_char(to_date(wpr.hrinclus,'sssss'),'hh24:mi'),'dd/mm/yyyy hh24:mi')
                 ) * 24) total_horas,
                 wpr.dtinclus,
                 wpr.hrinclus
            FROM crawepr wpr 
           WHERE wpr.cdcooper=pr_cdcooper 
             AND wpr.nrdconta=pr_nrdconta 
             AND wpr.hrinclus IS NOT NULL
             AND wpr.dtinclus IS NOT NULL
             AND wpr.dtinclus >= trunc(SYSDATE)- pr_rw_segmento.nrintervalo_proposta/24
           )
       LOOP
          IF rw_count.total_horas <= pr_rw_segmento.nrintervalo_proposta
            THEN
              vr_propostas_intervalo := vr_propostas_intervalo+1;
          END IF;    
       END LOOP;      
       
       RETURN vr_propostas_intervalo;
       
     EXCEPTION WHEN OTHERS
       THEN RETURN 0;
     END tot_propostas_intervalo;
     --
     --/
     FUNCTION fn_get_idsegmento(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                pr_nrdconta IN crapass.nrdconta%TYPE,
                                pr_nrsimula IN crapsim.nrsimula%TYPE )
      RETURN crapsim.idsegmento%TYPE IS
      --/
      vr_idsegmento crapsim.idsegmento%TYPE;
      vr_nrmax_proposta tbepr_segmento.nrmax_proposta%TYPE;
      vr_nrintervalo_proposta tbepr_segmento.nrintervalo_proposta%TYPE;
      --
      --/
     BEGIN
      --/       
      SELECT sim.idsegmento
        INTO vr_idsegmento
        FROM crapsim sim
       WHERE sim.nrsimula = pr_nrsimula
         AND sim.cdcooper = pr_cdcooper
         AND sim.nrdconta = pr_nrdconta;
         RETURN nvl(vr_idsegmento,NULL);
      EXCEPTION WHEN OTHERS
        THEN
          RETURN NULL;
      END fn_get_idsegmento;
     --
     --/      
     FUNCTION fn_getrow_segmento(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                 pr_idsegmento crapsim.idsegmento%TYPE) 
       RETURN tbepr_segmento%ROWTYPE IS
       --/
       rw_segmento tbepr_segmento%ROWTYPE;
       --/
       CURSOR cr_tbepr_segmento(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                pr_idsegmento crapsim.idsegmento%TYPE) IS
       SELECT *
         FROM tbepr_segmento 
        WHERE cdcooper = pr_cdcooper
          AND idsegmento = pr_idsegmento;
       --/
      BEGIN
        
       OPEN cr_tbepr_segmento(pr_cdcooper,pr_idsegmento);
       FETCH cr_tbepr_segmento INTO rw_segmento;
       CLOSE cr_tbepr_segmento;
       
       RETURN rw_segmento;
       
      END fn_getrow_segmento;
     --
     --/      
    BEGIN
     --/      
     rw_seg := fn_getrow_segmento(pr_cdcooper,
                                  fn_get_idsegmento(pr_cdcooper,pr_nrdconta,pr_nrsimula)
                                  );
     --
     --/      
     RETURN ( rw_seg.nrmax_proposta > tot_propostas_intervalo(pr_cdcooper,
                                                              pr_nrdconta,
                                                              pr_cdorigem,
                                                              rw_seg) );
    --
    --/      
    END fn_libera_gravacao;
    --
    --/
   BEGIN
    --
    --/
    IF NOT ( fn_libera_gravacao(pr_cdcooper
                               ,pr_nrdconta
                               ,pr_nrsimula
                               ,pr_cdorigem) )
      THEN
        vr_dscritic := 'Quantidade de envio de propostas excedida!';
        RAISE vr_exc_erro;
    END IF;
    --
    --/
    IF pr_cdorigem = 3
      THEN
        --/
        pc_valida_horario_ib(pr_cdcooper,vr_des_reto,vr_dscritic);
        --
        --/
        IF nvl(vr_des_reto,'NOK') != 'OK'
           THEN         
             RAISE vr_exc_erro;
        END IF;
    END IF;
    --
    --/
    pc_busca_simulacao();
    --
    --
    IF NOT( fn_existe_simulacao ) THEN

       vr_dscritic := 'Nao encontrado dados de simulacao';
       RAISE vr_exc_erro;

    END IF;
    --
    pc_busca_nrcontrato(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_nrctremp => vr_nrctremp,
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic);
    --
    IF ( vr_nrctremp IS NULL ) THEN

       vr_dscritic := 'Problema ao gerar numero de proposta';
       RAISE vr_exc_erro;

    END IF;
    --
    --    
    -- Leitura do calendário da cooperativa
    OPEN btch0001 .cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic :='Nao encontrado calendario da cooperativa';
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    --/
    IF trunc(rw_crapsim.dtdpagto) <= trunc(rw_crapdat.dtmvtolt)
      THEN
        vr_dscritic := 'Sua proposta está com data de primeiro pagamento para '||fn_Data_soa(rw_crapsim.dtdpagto)||', por este motivo você deve realizar uma nova simulação.';
        RAISE vr_exc_erro;
    END IF;
    --    
    -- Verifica se a simulação está dentro do prazo de validade
    IF trunc(rw_crapdat.dtmvtolt) > trunc(rw_crapsim.dtvalidade) THEN
        vr_dscritic := 'Essa simulação ultrapassou a data de validade! Realize uma nova simulação e envie para análise.';
        RAISE vr_exc_erro;
    END IF;
    
    IF nvl(rw_crapsim.idfiniof,0) = 1 THEN
      vr_vlfinanciado := nvl(rw_crapsim.vlemprst,0) + nvl(rw_crapsim.vliofepr,0) + nvl(rw_crapsim.vlrtarif,0);
    ELSE 
      vr_vlfinanciado := rw_crapsim.vlemprst;
    END IF;
    
    pc_grava_proposta(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_cdorigem => pr_cdorigem,
                      pr_nrctremp => vr_nrctremp,
                      pr_vlfinanciado => vr_vlfinanciado,
                      pr_vlsolicitado => rw_crapsim.vlemprst,
                      pr_qtparcelas => rw_crapsim.qtparepr,
                      pr_vlparcela => rw_crapsim.vlparepr,
                      pr_pecet_operacao => rw_crapsim.percetop,
                      pr_cdoperad => pr_cdoperad,
                      pr_inrisco_calculado => 0,
                      pr_inrisco_proposta => 0,
                      pr_dtvencto_operacao => rw_crapsim.dtvalidade,
                      pr_dtdpagto => rw_crapsim.dtdpagto,
                      pr_vlsaldo_devedor => 0,
                      pr_vltarifa => rw_crapsim.vlrtarif,
                      pr_vliofcontrato => rw_crapsim.vliofepr,
                      pr_insitctr => 1, -- situacao=1(proposta)
                      pr_nrprotocolo => NULL,
                      pr_cdlcremp => rw_crapsim.cdlcremp,
                      pr_dtvencto => rw_crapsim.dtdpagto ,
                      pr_cdagenci => pr_cdagenci,
                      pr_cdfinemp => rw_crapsim.cdfinemp,
                      pr_nrsimula => pr_nrsimula,
                      pr_dtlibera => rw_crapsim.dtlibera,
                      pr_idfiniof => rw_crapsim.idfiniof,
                      pr_cdcritic => vr_cdcritic ,
                      pr_dscritic => vr_dscritic );
    --/
    IF NOT ( vr_dscritic IS NULL )
      THEN
        RAISE vr_exc_erro;
    END IF;
    
    COMMIT;
    --
    --/
           empr0018.pc_calcula_emprestimo(pr_cdcooper => pr_cdcooper,
                                          pr_cdagenci => pr_cdagenci,
                                          pr_nrdcaixa => pr_nrdcaixa,
                                          pr_cdoperad => rw_crapsim.cdoperad,
                                          pr_nmdatela => 'ATENDA',
                                          pr_cdorigem => pr_cdorigem,
                                          pr_nrdconta => rw_crapsim.nrdconta,
                                          pr_idseqttl => 1, -- titular
                                          pr_flgerlog => sys.diutil.int_to_bool(pr_flgerlog),
                                          pr_nrctremp => vr_nrctremp,
                                          pr_cdlcremp => rw_crapsim.cdlcremp,
                                          pr_cdfinemp => rw_crapsim.cdfinemp,
                                          pr_vlemprst => rw_crapsim.vlemprst,
                                          pr_qtparepr => rw_crapsim.qtparepr,
                                          pr_dtmvtolt => rw_crapsim.dtmvtolt,
                                          pr_dtdpagto => rw_crapsim.dtdpagto,
                                          pr_flggrava => vr_flggrava,
                                          pr_dtlibera => rw_crapsim.dtlibera,
                                          pr_idfiniof => rw_crapsim.idfiniof,
                                          pr_qtdiacar => vr_qtd_diacar,
                                          pr_vlajuepr => rw_crapsim.vlajuepr,
                                          pr_txdiaria => rw_crapsim.txdiaria,
                                          pr_txmensal => rw_crapsim.txmensal,
                                          pr_tparcepr => vr_tab_parc_epr,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_des_erro => vr_des_erro,
                                          pr_des_reto => vr_des_reto,
                                          pr_tab_erro => vr_tab_erro);
    --
    IF NVL(vr_des_reto,'NOK') != 'OK'
      THEN
        vr_dscritic := vr_des_erro;
        RAISE vr_exc_erro;
    END IF;
    --
    --/    
     pc_aciona_motor(pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta 
                    ,pr_nrctremp => vr_nrctremp);
    --/    
    /*    pc_inclui_proposta_esteira(pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => pr_cdagenci
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_cdorigem => pr_cdorigem
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrctremp => vr_nrctremp
                              ,pr_dtmvtolt => rw_crapsim.dtmvtolt
                              ,pr_des_reto => vr_des_reto_est);
     
    --
    --/
    IF NOT ( vr_des_reto_est = 'OK' )
      THEN
        --
        --/ Avisa que a proposta ficou presa na esteira
        pc_email_esteira(pr_cdcooper,pr_nrdconta,vr_nrctremp,vr_des_reto);

    END IF;
    */ 
    --
    --/
    monta_xml_retorno();
    --
    --
    pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><retorno/>');
    --
    insere_tag(pr_xml      => pr_retorno
              ,pr_tag_pai  => 'retorno'
              ,pr_posicao  => 0
              ,pr_tag_nova => 'nrctremp'
              ,pr_tag_cont => vr_nrctremp
              ,pr_des_erro => vr_dscritic);
    --
    insere_tag(pr_xml      => pr_retorno
              ,pr_tag_pai  => 'retorno'
              ,pr_posicao  => 0
              ,pr_tag_nova => 'nrdconta'
              ,pr_tag_cont => pr_nrdconta
              ,pr_des_erro => vr_dscritic);

    insere_tag(pr_xml      => pr_retorno
              ,pr_tag_pai  => 'retorno'
              ,pr_posicao  => 0
              ,pr_tag_nova => 'cdcooper'
              ,pr_tag_cont => pr_cdcooper
              ,pr_des_erro => vr_dscritic);
    --
    --/    
    pr_des_reto := 'OK';
    
    commit;
    --
  EXCEPTION
   WHEN vr_exc_erro THEN
     --
     pr_des_reto := 'NOK';
     pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' ||vr_dscritic||
                                      '</Erro></Root>');
   WHEN OTHERS THEN
     --
     pr_des_reto := 'NOK';
     pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' ||'ERRO NAO TRATADO NA pc_gera_proposta: '||SQLERRM||
                                      '</Erro></Root>');
  END pc_gera_proposta;

  PROCEDURE pc_grava_proposta(pr_cdcooper IN crawepr.cdcooper%TYPE               --> Codigo da cooperativa
                             ,pr_nrdconta IN crawepr.nrdconta%TYPE              --> Conta do Associado
                             ,pr_cdorigem IN crawepr.cdorigem%TYPE
                             ,pr_nrctremp IN crawepr.nrctremp%TYPE Default 0    --> Número da proposta
                             ,pr_vlfinanciado IN crawepr.vlemprst%TYPE  --> Valor financiado
                             ,pr_vlsolicitado IN crawepr.vlemprst%TYPE  --> Valor financiado
                             ,pr_qtparcelas     IN crawepr.qtpreemp%TYPE  --> Quantidade de parcelas
                             ,pr_vlparcela      IN crawepr.vlpreemp%TYPE  --> Valor de cada parcela
                             ,pr_pecet_operacao IN crawepr.percetop%TYPE  --> Custo efetivo total (CET) da operacao ao ano
                             ,pr_cdoperad           IN crawepr.cdoperad%TYPE  --> Codigo do operador
                             ,pr_inrisco_calculado  IN NUMBER Default null --> Nivel de risco calculado
                             ,pr_inrisco_proposta   IN NUMBER Default null --> Nivel de risco da proposta
                             ,pr_dtvencto_operacao  IN DATE Default null --> Data de vencimento da operacao
                             ,pr_dtdpagto           IN DATE DEFAULT NULL --> Data de vencimento da primeira parcela
                             ,pr_vlsaldo_devedor    IN crawepr.vlemprst%TYPE Default null --> Valor de Saldo Devedor do Contrato.
                             ,pr_vltarifa           IN NUMBER Default null --> Valor da tarifa.
                             ,pr_vliofcontrato      IN NUMBER Default null --> Valor do IOF na efetivação do contrato.
                             ,pr_insitctr           IN crawepr.insitapr%TYPE  --> Situacoes do contrato 1-Proposta, 2-Contrato , 3-Liquidada e 4-Excluida
                             ,pr_nrprotocolo        IN VARCHAR2 Default null --> Protocolo da IBRATAN
                             ,pr_cdlcremp           IN crawepr.cdlcremp%TYPE
                             ,pr_dtvencto           IN DATE
                             ,pr_cdagenci           IN crawepr.cdagenci%TYPE
                             ,pr_cdfinemp           IN crapsim.cdfinemp%TYPE
                             ,pr_nrsimula           IN crapsim.nrsimula%TYPE
                             ,pr_dtlibera           IN crapsim.dtlibera%TYPE
                             ,pr_idfiniof           IN crapsim.idfiniof%TYPE
                              ----------------- > OUT < ----------------------
                             ,pr_cdcritic OUT INTEGER                                             --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2                                            --> Descrição da crítica
                              ) IS
   /* .............................................................................
         programa: pc_grava_proposta
         autor   : AmCom
         data    : Janeiro/2019

         dados referentes ao programa:

         frequencia: sempre que for chamado.
         objetivo  : procedure para gravar propostas de emprestimo

         Alterações: 28/05/2019 - P438 Incluída busca da dados adicionais para gravar na crapprp. (Douglas Pagel / AMcom)

                     02/08/2019 - Inclusão da validação da Linha de Crédito e ajuste no valor do campo crawepr.tpdescto
                                  (Douglas Pagel / AMcom). 

                     16/08/2019 - P450 - Na chamada da pc_obtem_emprestimo_risco, incluir pr_nrctremp
                                  (Elton / AMcom). 
      ............................................................................. */

    CURSOR cr_contrato(pr_cdcooper IN crawepr.cdcooper%TYPE
                      ,pr_nrdconta IN crawepr.nrdconta%TYPE
                      ,pr_nrctremp IN crawepr.nrctremp%TYPE DEFAULT 0) IS
    SELECT t.*
          ,t.rowid
      FROM cecred.crawepr t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta
       AND t.nrctremp = pr_nrctremp;
    rw_contrato cr_contrato%ROWTYPE;
    
    -- Busca dados da linha de crédito
    CURSOR cr_craplcr(pr_cdcooper IN crawepr.cdcooper%TYPE
                     ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT l.tpdescto
        FROM craplcr l
       WHERE l.cdcooper = pr_cdcooper
         AND l.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;
    
    CURSOR cr_crapttl IS
    SELECT * 
      FROM crapttl 
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND idseqttl = 1;
    rw_crapttl cr_crapttl%ROWTYPE;
    
     -- Monta o registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Variáveis para tratamento dos Hashs
    vr_hash_novo     dbms_obfuscation_toolkit.varchar2_checksum;
    vr_str_campos_hash varchar2(4000);

    vr_rowid UROWID;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_dsnivris VARCHAR(4000);

    vr_tab_central_risco RISC0001.typ_reg_central_risco;
    vr_tab_erro gene0001.typ_tab_erro;

   BEGIN
    vr_hash_novo := null;
    vr_cdcritic := null;
    vr_dscritic := '';

    -- Busca a data corrente para a cooperativa.
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    -- Valida a linha de crédito
    OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                   ,pr_cdlcremp => pr_cdlcremp);
    FETCH cr_craplcr INTO rw_craplcr;
    
    IF cr_craplcr%NOTFOUND THEN
      CLOSE cr_craplcr;
      vr_cdcritic := 363;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplcr;
    END IF;
    
    --Busca Risco do emprestimo
    RATI0002.pc_obtem_emprestimo_risco(
                      pr_cdcooper => pr_cdcooper, 
                      pr_cdagenci => 996, 
                      pr_nrdcaixa => 900, 
                      pr_cdoperad => 90, 
                      pr_nrdconta => pr_nrdconta, 
                      pr_idseqttl => 1, 
                      pr_idorigem => pr_cdorigem, 
                      pr_nmdatela => '', 
                      pr_flgerlog => 'N', 
                      pr_cdfinemp => pr_cdfinemp, 
                      pr_cdlcremp => pr_cdlcremp, 
                      pr_dsctrliq => '', 
                      pr_nrctremp => pr_nrctremp, -- P450
                      pr_nivrisco => vr_dsnivris,
                      pr_dscritic => vr_dscritic, 
                      pr_cdcritic => vr_cdcritic);
                      
    if nvl(vr_dscritic,'OK') <> 'OK' or nvl(vr_cdcritic,0) <> 0 then
      raise vr_exc_erro;
    end if;

    --Busca dados do titular
    OPEN cr_crapttl;
    FETCH cr_crapttl INTO rw_crapttl;
    CLOSE cr_crapttl;
    
    --Busca dados de risco da conta
    RISC0001.pc_obtem_valores_central_risco(pr_cdcooper           => pr_cdcooper          --> Codigo Cooperativa
                                           ,pr_cdagenci           => 90                   --> Codigo Agencia
                                           ,pr_nrdcaixa           => 996                  --> Numero Caixa
                                           ,pr_nrdconta           => pr_nrdconta          --> Numero da Conta
                                           ,pr_nrcpfcgc           => '0'                  --> CPF/CGC do associado
                                           ,pr_tab_central_risco  => vr_tab_central_risco --> Informações da Central de Risco
                                           ,pr_tab_erro           => vr_tab_erro          --> Tabela Erro
                                           ,pr_des_reto           => vr_dscritic);        --> Retorno OK/NOK

    
    -- Verificar se o Contrato que está sendo passado existe ou se é um contrato novo.
    OPEN cr_contrato(pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrctremp => pr_nrctremp);
    FETCH cr_contrato INTO rw_contrato;
    
    IF cr_contrato%NOTFOUND THEN
      -- Se é Um contrato Novo, vai Inserir ele na ccecred.crawepr.
      CLOSE cr_contrato;

      INSERT INTO cecred.crawepr
        (cdcooper
        ,nrdconta
        ,nrctremp
        ,dtmvtolt
        ,vlemprst
--        ,vlempori
        ,qtpreemp
        ,vlpreemp
        ,percetop
        ,cdoperad
 --       ,inrisco_calculado
 --       ,inrisco_proposta
 --       ,dtvencto_operacao
 --       ,vlsaldo_devedor
 --       ,vltarifa
 --       ,vliofcontrato
 --       ,insitctr
        ,flgpreap
        ,flgdocdg
        ,tpemprst
        ,tpdescto
        ,cdlcremp
        ,flgpagto
        ,cdfinemp
        ,dtdpagto
        ,cdorigem
        ,dtvencto
        ,cdagenci
        ,nrsimula
        ,dtlibera
        ,idfiniof
        ,nmdaval1
        ,nmdaval2
        ,dsnivori
        ,flgimppr
        )
      VALUES
        (pr_cdcooper
        ,pr_nrdconta
        ,pr_nrctremp
        ,rw_crapdat.dtmvtolt
        ,pr_vlsolicitado--pr_vlfinanciado
--        ,pr_vlsolicitado
        ,pr_qtparcelas
        ,pr_vlparcela
        ,pr_pecet_operacao
        ,pr_cdoperad
--      ,pr_inrisco_calculado
--      ,pr_inrisco_proposta
--      ,pr_dtvencto_operacao
--      ,pr_vlsaldo_devedor
--      ,pr_vltarifa
--      ,pr_vliofcontrato
--      ,pr_insitctr
        ,0
        ,0
        ,1
        ,rw_craplcr.tpdescto
        ,pr_cdlcremp
        ,0
        ,pr_cdfinemp
        ,pr_dtdpagto
        ,pr_cdorigem
        ,pr_dtvencto
        ,pr_cdagenci
        ,pr_nrsimula
        ,pr_dtlibera
        ,pr_idfiniof
        ,' '
        ,' '
        ,nvl(vr_dsnivris,'0')
        ,1);

      INSERT INTO cecred.crapprp
        (cdcooper
        ,nrdconta
        ,nrctrato
        ,tpctrato
        ,dtmvtolt
        ,vlsalari
        ,dtdrisco
        ,qtifoper
        ,qtopescr
        ,vlrpreju
        ,vlopescr
        ,vltotsfn)
      VALUES
        (pr_cdcooper
        ,pr_nrdconta
        ,pr_nrctremp
        ,90
        ,rw_crapdat.dtmvtolt
        ,nvl(rw_crapttl.vlsalari,0)
        ,vr_tab_central_risco.dtdrisco
        ,nvl(vr_tab_central_risco.qtifoper, 0)
        ,nvl(vr_tab_central_risco.qtopescr,0)
        ,nvl(vr_tab_central_risco.vlrpreju,0) 
        ,nvl(vr_tab_central_risco.vlopescr,0)
        ,nvl(vr_tab_central_risco.vltotsfn,0) );

       /* -- Obtem a chave Hash do Registro que acabou de ser inserido.
        pc_obtem_chave_hash(pr_rowid_tabela => vr_rowid
                           ,pr_owner_tabela => 'CECRED'
                           ,pr_nome_tabela => 'CRAPPRP'
                           ,pr_campos_nao_hash => '''CDCOOPER'',''NRDCONTA'',''NRCTREMP'',''NRCONTRATOEXT'',''VLCHAVENST'',''DTMOVIMENTO'',''VLHASHCONTRATO'''
                           ,pr_str_campos_hash => vr_str_campos_hash
                           ,pr_chave_hash => vr_hash_novo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);

        IF (nvl(vr_cdcritic,0) <> 0 OR  vr_dscritic IS NOT NULL) THEN
          raise vr_exc_erro;
        END IF;

        -- altera o registro que acabou de ser inserido gerando seu código Hash.
        UPDATE cecred.tbepr_consignado_contrato t
           SET t.vlhashcontrato     = vr_hash_novo
         WHERE t.ROWID = vr_rowid; */
    ELSE

      -- Verifico se o contrato é válido (Se o Contrato já estiver 4-Cancelado ou 3-Liquidado)
      -- retorno critica e não faço update e nem gero histórico.
      IF rw_contrato.insitest = 0 THEN
        vr_cdcritic := 0; -- Nao enviado
        raise vr_exc_erro;
      ELSIF rw_contrato.insitest = 4 THEN
        vr_cdcritic := 0; -- Expirada
        raise vr_exc_erro;
      END IF;

      -- Contrato já existente, realizo update retornando o ROWID, e calculo o hash novamente dinamicamente.
      CLOSE cr_contrato;
      --02.Fazer update no registro atual com o que chegou por parametro do SOA.
/*      UPDATE cecred.tbepr_consignado_contrato t
         SET t.vlfinanciado      = decode(pr_vlfinanciado,null,t.vlfinanciado,pr_vlfinanciado)
            ,t.qtparcelas        = decode(pr_qtparcelas,null,t.qtparcelas,pr_qtparcelas)
            ,t.vlparcela         = decode(pr_vlparcela,null,t.vlparcela,pr_vlparcela)
            ,t.pecet_operacao    = decode(pr_pecet_operacao,null,t.pecet_operacao,pr_pecet_operacao)
            ,t.cdoperad          = decode(pr_cdoperad,null,t.cdoperad,pr_cdoperad)
            ,t.inrisco_calculado = decode(pr_inrisco_calculado,null,t.inrisco_calculado,pr_inrisco_calculado)
            ,t.inrisco_proposta  = decode(pr_inrisco_proposta,null,t.inrisco_proposta,pr_inrisco_proposta)
            ,t.dtvencto_operacao = decode(pr_dtvencto_operacao,null,t.dtvencto_operacao,pr_dtvencto_operacao)
            ,t.vlsaldo_devedor   = decode(pr_vlsaldo_devedor,null,t.vlsaldo_devedor,pr_vlsaldo_devedor)
            ,t.vltarifa          = decode(pr_vltarifa,null,t.vltarifa,pr_vltarifa)
            ,t.vliofcontrato     = decode(pr_vliofcontrato,null,t.vliofcontrato,pr_vliofcontrato)
            ,t.insitctr          = decode(pr_insitctr,null,t.insitctr,pr_insitctr)
       WHERE t.ROWID = rw_contrato.ROWID;
*/
  UPDATE crawepr wpr
    SET wpr.insitest = pr_insitctr, -->  1 – Enviada para Analise
      wpr.dtenvmot = trunc(SYSDATE),
      wpr.hrenvmot = to_char(SYSDATE,'sssss'),
      wpr.cdopeste = pr_cdoperad,
      wpr.dsprotoc = nvl(pr_nrprotocolo,' '),
                   wpr.insitapr = 0,
                   wpr.cdopeapr = NULL,
                   wpr.dtaprova = NULL,
                   wpr.hraprova = 0
       WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp;

     /* --03.Como o hash não se altera, eu calculo novamente o hash após o update, para buscar o novo hash.
      pc_obtem_chave_hash(pr_rowid_tabela => rw_contrato.ROWID
                         ,pr_owner_tabela => 'CECRED'
                         ,pr_nome_tabela => 'TBEPR_CONSIGNADO_CONTRATO'
                         ,pr_campos_nao_hash => '''CDCOOPER'',''NRDCONTA'',''NRCTREMP'',''NRCONTRATOEXT'',''VLCHAVENST'',''DTMOVIMENTO'',''VLHASHCONTRATO'''
                         ,pr_str_campos_hash => vr_str_campos_hash
                         ,pr_chave_hash => vr_hash_novo
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

      IF (nvl(vr_cdcritic,0) <> 0 OR  vr_dscritic IS NOT NULL) THEN
        raise vr_exc_erro;
      END IF; */

      -- gravo o hash para o registro alterado.
    /*  UPDATE cecred.tbepr_consignado_contrato t
         SET t.vlhashcontrato     = vr_hash_novo
       WHERE t.ROWID = rw_contrato.ROWID;*/

      --SE HOUVE ALTERAÇÃO NO REGISTRO, GERAR HISTÓRICO E UPDATE.
      /*IF vr_hash_novo <> rw_contrato.vlhashcontrato THEN
        -- 01.Gerando o Historico.
        INSERT INTO cecred.tbepr_cons_contrato_hist
           (idcontrato_cons
           ,vlfinanciado
           ,qtparcelas
           ,vlparcela
           ,pecet_operacao
           ,cdoperad
           ,inrisco_calculado
           ,inrisco_proposta
           ,dtvencto_operacao
           ,vlsaldo_devedor
           ,vltarifa
           ,vliofcontrato
           ,insitctr
           ,dtalteracao
           ,hralteracao)
        VALUES
           (rw_contratoconsignado.idcontrato_cons
           ,rw_contratoconsignado.vlfinanciado
           ,rw_contratoconsignado.qtparcelas
           ,rw_contratoconsignado.vlparcela
           ,rw_contratoconsignado.pecet_operacao
           ,rw_contratoconsignado.cdoperad
           ,rw_contratoconsignado.inrisco_calculado
           ,rw_contratoconsignado.inrisco_proposta
           ,rw_contratoconsignado.dtvencto_operacao
           ,rw_contratoconsignado.vlsaldo_devedor
           ,rw_contratoconsignado.vltarifa
           ,rw_contratoconsignado.vliofcontrato
           ,rw_contratoconsignado.insitctr
           ,to_date(SYSDATE,'dd/mm/RRRR')
           ,to_char(SYSDATE,'SSSSS'));
      END IF;
*/          END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
    /* busca valores de critica predefinidos */
    IF NVL(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
      /* busca a descriçao da crítica baseado no código */
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
  WHEN OTHERS THEN
    /* quando nao possuir uma crítica predefina para um codigo de retorno, estabele um texto genérico para o erro. */
    pr_cdcritic := 0;
    pr_dscritic := 'erro geral na rotina EMPR0017.pc_grava_proposta: ' || sqlerrm;

  END pc_grava_proposta;

  PROCEDURE pc_busca_nrcontrato(pr_cdcooper     IN crawepr.cdcooper%TYPE        --> Codigo da cooperativa
                               ,pr_nrdconta     IN crawepr.nrdconta%TYPE        --> Conta do Associado
                                ----------------- > OUT < ----------------------
                               ,pr_nrctremp     OUT crawepr.nrctremp%TYPE  --> Número do Contrato
                               ,pr_cdcritic     OUT INTEGER                                       --> Código da crítica
                               ,pr_dscritic     OUT VARCHAR2                                      --> Descrição da crítica
                                ) IS
    /*.............................................................................
         programa: pc_busca_nrcontrato
         sigla   : cred
         autor   : Amcom
         data    : Janeiro/2019                      ultima atualizacao:

         dados referentes ao programa:

         frequencia: sempre que for chamado.
         objetivo  : procedure para buscar o número de contratto que possa ser utilizado

         alteracoes:
    ............................................................................. */

    /* Descrição e código da critica */
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --
    FUNCTION fn_nrctremp_em_uso(pr_cdcooper IN crawepr.cdcooper%TYPE
                               ,pr_nrdconta IN crawepr.nrdconta%TYPE
                               ,pr_nrctremp IN crawepr.nrctremp%TYPE) RETURN BOOLEAN IS
     vr_count NUMBER;
    BEGIN
       vr_count := 0;

       SELECT count(*) + vr_count
         INTO vr_count
         FROM crawepr 
    WHERE cdcooper = pr_cdcooper
          AND nrdconta = pr_nrdconta
          AND nrctremp = pr_nrctremp;

        SELECT count(*) + vr_count
          INTO vr_count
          FROM crapepr 
    WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;

        SELECT COUNT(*) + vr_count
          INTO vr_count
          FROM crapmcr 
    WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrcontra = pr_nrctremp;

        RETURN ( vr_count > 0 );

     END fn_nrctremp_em_uso;

    PROCEDURE pc_new_sequence(pr_nrctremp OUT NUMBER) IS
      vr_sequence VARCHAR2(4000);
  BEGIN
      --/
      pc_sequence_progress(pr_nmtabela => 'CRAPMAT', 
                           pr_nmdcampo => 'NRCTREMP', 
                           pr_dsdchave => 1, 
                           pr_flgdecre => 'N', 
                           pr_sequence => vr_sequence);

      IF nvl(vr_sequence,'0') = '0' THEN 
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao buscar sequence na tabela CRAPMAT.';
          RAISE vr_exc_erro;
    END IF;

      pr_nrctremp := to_number(vr_sequence);

    END pc_new_sequence;

  BEGIN

    vr_cdcritic := NULL;
    vr_dscritic := '';
    --/ busca proximo sequencial
    pc_new_sequence(pr_nrctremp);

    --/ verifica se numero retornado está em uso
    WHILE fn_nrctremp_em_uso(pr_cdcooper,pr_nrdconta,pr_nrctremp) LOOP

      pc_new_sequence(pr_nrctremp);

    END LOOP;

  EXCEPTION
    WHEN vr_exc_erro THEN
    /* busca valores de critica predefinidos */
    IF NVL(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
      /* busca a descriçao da crítica baseado no código */
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
  WHEN OTHERS THEN
    /* quando nao possuir uma crítica predefina para um codigo de retorno, estabele um texto genérico para o erro. */
    pr_cdcritic := 0;
    pr_dscritic := 'erro geral na rotina EMPR0017.pc_busca_nrcontrato: ' || sqlerrm;
    /*  fecha a procedure */
  END pc_busca_nrcontrato;

  PROCEDURE pc_solicita_contratacao(pr_cdcooper  IN crapcop.cdcooper%TYPE       --Codigo Cooperativa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE       --Numero da Conta do Associado
                                   ,pr_nrctremp  IN INTEGER                     --Numero Contrato Emprestimo
                                   ,pr_cdoperad IN VARCHAR2
                                   ,pr_nrcpfope IN VARCHAR2
                                   ,pr_nripuser IN VARCHAR2
                                   ,pr_iddispos IN VARCHAR2
                                   ,pr_cdagenci IN crapass.cdagenci%TYPE
                                   ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE     --> Numero do caixa
                                   ,pr_cdorigem IN crawepr.cdorigem%TYPE
                                    -->> SAIDA
                                   ,pr_des_reto OUT VARCHAR  --> Retorno OK / NOK
                                   ,pr_retorno OUT xmltype) IS
   --
   /* .............................................................................
       programa: pc_solicita_contratacao
       autor   : AmCom
       data    : Janeiro/2019

       dados referentes ao programa:

       frequencia: sempre que for chamado.
       objetivo  : procedure para efetivar propostas de emprestimo
       alterações:
                   04/09/2019 - Adicionaro efetivacao Rating na efetivacao da proposta 
                                na pc_solicita_contratacao (Luiz Otávio Olinger Momm - AMCOM)

      ............................................................................. */
   --
   rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
   -- Exceções
   vr_exc_saida EXCEPTION;
   --Variaveis
   vr_dstransa VARCHAR2(60);
   vr_dsorigem VARCHAR2(40);
   vr_aux_log_rowid ROWID;

   -- Tratamento de erros
   vr_cdcritic crapcri.cdcritic%TYPE;
   vr_dscritic crapcri.dscritic%TYPE;
   vr_des_reto VARCHAR2(50);
   vr_retorno XMLTYPE;

   -- Variaveis gerais
   vr_cdprogra     crapprg.cdprogra%TYPE := 'ATENDA';
   vr_data_inicial crapdat.dtmvtolt%type;
   vr_data_fim     crapdat.dtmvtolt%type;
   vr_prazo_efetiva NUMBER;
   vr_flaliena      INTEGER;
   vr_tab_ratings  rati0001.typ_tab_ratings;
   vr_mensagem     VARCHAR2(32000);
   vr_qtdibaut    INTEGER :=0;
   vr_qtdibapl    INTEGER :=0;
   vr_qtdibsem    INTEGER :=0;
   vr_dstextab    craptab.dstextab%TYPE;
   vr_retxml      xmltype; 
   vr_nmarqpdf    VARCHAR2(100);  
   vr_nmdirpdf    VARCHAR2(200);
   vr_rowid       ROWID;
   vr_habrat       VARCHAR2(1) := 'N';    -- P450 - Paramentro para Habilitar Novo Ratin (S/N)
   vr_strating     NUMBER;                -- P450
   vr_flgrating    NUMBER;                -- P450
   vr_vlendivid    craplim.vllimite%TYPE; -- P450 - Valor do Endividamento do Cooperado
   vr_vllimrating  craplim.vllimite%TYPE; -- P450 - Valor do Parametro Rating (Limite) TAB056

   --
   --
   CURSOR cr_crawepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_nrdconta IN crawepr.nrdconta%TYPE
                    ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
     SELECT epr.cdoperad,
            epr.cdagenci,
            epr.cdorigem,
            epr.cdcooper,
            epr.nrdconta,
            epr.nrctremp,
            epr.dtlibera,
            epr.dtdpagto,
            epr.insitapr,
            epr.insitest,
            epr.dtinclus,
            epr.cdfinemp,
            epr.dtaprova,
            epr.cdlcremp
       FROM crawepr epr
      WHERE cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta
        AND nrctremp = pr_nrctremp;
   --
   rw_crawepr cr_crawepr%ROWTYPE;
   --
   --/ cursor de associados
   CURSOR cr_crapass IS
    SELECT *
      FROM crapass craps
     WHERE craps.cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;
   --
   rw_crapass cr_crapass%ROWTYPE;
   --
   --/ cursor de emprestimos
   CURSOR cr_crapepr IS
     SELECT *
       FROM crapepr epr
      WHERE epr.nrdconta = pr_nrdconta
        AND epr.nrctremp = pr_nrctremp;
   --
   rw_crapepr cr_crapepr%ROWTYPE;
   --
   --
   CURSOR cr_crapope(pr_cdcooper crapope.cdcooper%type, pr_cdoperad crapope.cdoperad%TYPE) IS
     SELECT *
        FROM crapope
       WHERE cdcooper = pr_cdcooper
         AND upper(cdoperad) = upper(pr_cdoperad);
   --
   --
   rw_crapope cr_crapope%ROWTYPE;
   --
   --
   FUNCTION exist_transacao_pend_ativa(pr_cdcooper IN NUMBER, pr_nrdconta IN NUMBER, pr_nrctremp IN NUMBER ) RETURN BOOLEAN IS
   --
   vcount NUMBER;
   --/
   BEGIN
     --/
     SELECT COUNT(*)
       INTO vcount
       FROM tbgen_trans_pend pnd,
            tbepr_trans_pend_efet_proposta pndef 
      WHERE pnd.idsituacao_transacao IN (1, -- Pendente
                                         2, -- Aprovada
                                         5  -- Parcialmente Aprovada
                                         )       
        AND pnd.cdtransacao_pendente = pndef.cdtransacao_pendente
        AND pndef.cdcooper = pr_cdcooper
        AND pndef.nrdconta = pr_nrdconta
        AND pndef.nrctremp = pr_nrctremp;
   
    RETURN vcount > 0; 
   END exist_transacao_pend_ativa;
   --
   --
   BEGIN
     
    vr_dsorigem := gene0001.vr_vet_des_origens(pr_cdorigem);
    vr_dstransa := 'Solicitacao de contratacao.';                           
     
    --
    -- Leitura do calendário da cooperativa
    OPEN btch0001 .cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic :='Nao encontrado calendario da cooperativa';
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    OPEN cr_crawepr(pr_cdcooper
                   ,pr_nrdconta
                   ,pr_nrctremp);
     FETCH cr_crawepr INTO rw_crawepr;
      IF cr_crawepr%NOTFOUND THEN
        vr_dscritic :='Contrato ' ||pr_nrctremp||' da conta ' ||pr_nrdconta||' da cooperativa ' ||pr_cdcooper||' nao localizado ou fora do periodo de efetivacao';
        RAISE vr_exc_saida;
      END IF;
    CLOSE cr_crawepr;

    IF ( rw_crawepr.insitapr <> 1 OR rw_crawepr.insitest <> 3 ) THEN
       vr_dscritic := 'Situação da proposta não permite efetivação!';
       RAISE vr_exc_saida;
    END IF;    

    IF trunc(rw_crawepr.dtdpagto) <= trunc(rw_crapdat.dtmvtolt)
      THEN
        vr_dscritic := 'Sua proposta está com data de primeiro pagamento para '||fn_Data_soa(rw_crawepr.dtdpagto)||', por este motivo você deve realizar uma nova simulação.';
        RAISE vr_exc_saida;
    END IF;
    --
    OPEN cr_crapass;
     FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_dscritic :='Dados de Associado nao localizado';
        RAISE vr_exc_saida;
      END IF;
    CLOSE cr_crapass;
    --/
    /*IF exist_transacao_pend_ativa(pr_cdcooper,pr_nrdconta,pr_nrctremp)
       THEN
         vr_dscritic := 'Ja existe pendencia gerada para esta proprosta';
         RAISE vr_exc_saida;         
    END IF;*/
    --
    --
    OPEN cr_crapepr;
     FETCH cr_crapepr INTO rw_crapepr;
    CLOSE cr_crapepr;
    --
    --
    OPEN cr_crapope(pr_cdcooper,rw_crawepr.cdoperad);
     FETCH cr_crapope INTO rw_crapope;
    CLOSE cr_crapope;
    --    
    -- Chamar para atualizar a data
    IF rw_crapdat.dtmvtolt > rw_crawepr.dtlibera THEN
      --
      -- ajustar a data do emprestimo para efetivar
      empr0012.pc_crps751 (pr_cdcooper => rw_crawepr.cdcooper
                          ,pr_nrdconta => rw_crawepr.nrdconta
                          ,pr_nrctremp => rw_crawepr.nrctremp
                          ,pr_cdagenci => rw_crawepr.cdagenci
                          ,pr_cdoperad => rw_crawepr.cdoperad
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
  	                      ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);

      -- Tratamento de erro de retorno
      IF vr_dscritic IS NOT NULL THEN
        -- Gera Log
        GENE0001.pc_gera_log(pr_cdcooper => rw_crawepr.cdcooper
                            ,pr_cdoperad => rw_crawepr.cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => 'EFTEMP'
                            ,pr_dstransa => 'Recalculo de emprestimo.'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => 0
                            ,pr_nmdatela => 'AUTOEMP'
                            ,pr_nrdconta => rw_crawepr.nrdconta
                            ,pr_nrdrowid => vr_rowid
                            ); 
        RAISE vr_exc_saida;
      end if;
    END IF; 
    
    --/ grava efetivacao da proposta
    --

    -- P450 SPT13 - alteracao para habilitar rating novo
    vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                           pr_cdcooper => rw_crawepr.cdcooper,
                                           pr_cdacesso => 'HABILITA_RATING_NOVO');

    IF (rw_crawepr.cdcooper <> 3 AND vr_habrat = 'S') THEN
          
       /* Validar Status rating */
       RATI0003.pc_busca_status_rating(pr_cdcooper  => rw_crawepr.cdcooper
                                      ,pr_nrdconta  => rw_crawepr.nrdconta
                                      ,pr_nrctrato  => rw_crawepr.nrctremp
                                      ,pr_tpctrato  => 90
                                      ,pr_strating  => vr_strating
                                      ,pr_flgrating => vr_flgrating
                                      ,pr_cdcritic  => vr_cdcritic
                                      ,pr_dscritic  => vr_dscritic);

       IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
       END IF;
       -- Buscar Valor Endividamento e Valor Limite Rating (TAB056)
       RATI0003.pc_busca_endivid_param(pr_cdcooper => rw_crawepr.cdcooper
                                      ,pr_nrdconta => rw_crawepr.nrdconta
                                      ,pr_vlendivi => vr_vlendivid
                                      ,pr_vlrating => vr_vllimrating
                                      ,pr_dscritic => vr_dscritic);
       IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
       END IF;

       -- Status do rating inválido
       IF vr_flgrating = 0 THEN
         vr_dscritic := 'Contrato não pode ser efetivado porque não há Rating válido.';
         RAISE vr_exc_saida;

       ELSE -- Status do rating válido

         -- Se Endividamento + Contrato atual > Parametro Rating (TAB056
         IF (vr_vlendivid  > vr_vllimrating) THEN

           -- Gravar o Rating da operação, efetivando-o
           rati0003.pc_grava_rating_operacao(pr_cdcooper          => rw_crawepr.cdcooper
                                            ,pr_nrdconta          => rw_crawepr.nrdconta
                                            ,pr_nrctrato          => rw_crawepr.nrctremp
                                            ,pr_tpctrato          => 90
                                            ,pr_dtrating          => rw_crapdat.dtmvtolt
                                            ,pr_strating          => 4
                                            ,pr_cdoprrat          => rw_crawepr.cdoperad
                                            ,pr_nrcpfcnpj_base    => rw_crapass.nrcpfcnpj_base
                                            --Variáveis para gravar o histórico
                                            ,pr_cdoperad          => rw_crawepr.cdoperad
                                            ,pr_dtmvtolt          => rw_crapdat.dtmvtolt
                                            ,pr_justificativa     => 'Efetivado através do Internet Banking'
                                            --Variáveis de crítica
                                            ,pr_cdcritic          => vr_cdcritic
                                            ,pr_dscritic          => vr_dscritic);

           IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_saida;
           END IF;
         END IF;
       END IF;
     END IF;
     -- P450 SPT13 - alteracao para habilitar rating novo
    
     empr0014.pc_grava_efetivacao_proposta(pr_cdcooper => rw_crawepr.cdcooper,
                                           pr_cdagenci => rw_crawepr.cdagenci,
                                           pr_nrdcaixa => NULL,
                                           pr_cdoperad => rw_crawepr.cdoperad,
                                           pr_nmdatela => vr_cdprogra,
                                           pr_idorigem => rw_crawepr.cdorigem,
                                           pr_nrdconta => rw_crawepr.nrdconta,
                                           pr_idseqttl => 1,
                                           pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                           pr_flgerlog => 0,
                                           pr_nrctremp => rw_crawepr.nrctremp,
                                           pr_dtdpagto => rw_crawepr.dtdpagto,
                                           pr_dtmvtopr => rw_crapdat.dtmvtopr,
                                           pr_inproces => rw_crapdat.inproces,
                                           pr_nrcpfope => NULL,
                                           pr_tab_ratings => vr_tab_ratings,
                                           pr_mensagem => vr_mensagem,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
     --
     IF nvl(vr_dscritic,'OK') != 'OK' THEN
     --
       RAISE vr_exc_saida;
     --
     END IF;
     --
     --
        empr0016.pc_credito_online_pp(pr_cdcooper => rw_crawepr.cdcooper,
                                      pr_nrdconta => rw_crawepr.nrdconta,
                                      pr_nrctremp => rw_crawepr.nrctremp,
                                      pr_cdprogra => 'ATENDA',
                                      pr_inpessoa => rw_crapass.inpessoa,
                                      pr_cdagenci => rw_crawepr.cdagenci,
                                      pr_nrdcaixa => pr_nrdcaixa,
                                      pr_cdpactra => rw_crapope.cdpactra,
                                      pr_cdoperad => rw_crawepr.cdoperad,
                                      pr_vltottar => rw_crapepr.vltarifa,
                                      pr_vltariof => rw_crapepr.vltariof,
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);
     --
     IF nvl(vr_dscritic,'OK') != 'OK' THEN
     --
       vr_dscritic := 'Erro na credito_online_pp '||vr_dscritic;
       RAISE vr_exc_saida;
     --
     END IF;
     --
     pc_cria_notificacao(pr_cdcooper => rw_crawepr.cdcooper,
                         pr_nrdconta => rw_crawepr.nrdconta,
                         pr_nrctremp => rw_crawepr.nrctremp,
                         pr_tporigem => 2, 
                         pr_des_reto => vr_des_reto);
                         
     IF nvl(vr_des_reto,'OK') != 'OK' THEN
     --
       vr_dscritic := 'Erro ao criar notificação';
       RAISE vr_exc_saida;
     --
     END IF;
      
      empr0017.pc_assinatura_contrato(pr_cdcooper => rw_crawepr.cdcooper,
                                      pr_cdagenci => rw_crawepr.cdagenci,
                         pr_nrdconta => rw_crawepr.nrdconta,
                                      pr_idseqttl => 0, -- aqui sempre será cooperativa assinando
                                      pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                      pr_cdorigem => rw_crawepr.cdorigem,
                         pr_nrctremp => rw_crawepr.nrctremp,
                                      pr_tpassinatura => 2, -- aqui sempre será cooperativa assinando
                                      pr_des_reto => vr_des_reto,
                                      pr_dscritic => vr_dscritic);
                                      
     IF nvl(vr_des_reto,'NOK') != 'OK' THEN
       RAISE vr_exc_saida;
     END IF;                                      

      --Gera o CCB com as assinaturas para envio ao FTP do SmartShare                                 
      pc_gera_demonst_contrato(pr_cdcooper => pr_cdcooper
                             , pr_nrdconta => pr_nrdconta
                             , pr_nrctremp => pr_nrctremp
                             , pr_flgarantia => 1
                             , pr_des_reto => vr_des_reto 
                             , pr_xml => vr_retxml);  
                               
      IF nvl(vr_des_reto,'OK') != 'OK' THEN
        vr_dscritic := nvl(vr_retxml.extract('/Root/Erro/text()').getstringval(), 'Erro ao gerar contrato');
        RAISE vr_exc_saida;
      END IF;                                                                 
        
      --Busca o arquivo do contrato gerado para enviar ao FTP
      vr_nmarqpdf := vr_retxml.extract('/retorno/nmarqpdf/text()').getstringval();
      vr_nmdirpdf := vr_retxml.extract('/retorno/dsdirarq/text()').getstringval();
        
      IF nvl(vr_nmarqpdf,'') = '' OR nvl(vr_nmdirpdf,'') = '' THEN
        vr_dscritic := 'Erro ao recuperar o contrato gerado.';
        RAISE vr_exc_saida;  
      ELSE
        gene0002.pc_transf_arq_smartshare(pr_nmdiretorio => vr_nmdirpdf
                                        , pr_nmarquiv    => vr_nmarqpdf 
                                        , pr_cdcooper    => pr_cdcooper
                                        , pr_des_reto    => vr_des_reto
                                        , pr_dscritic    => vr_dscritic);
                                          
--        IF nvl(vr_des_reto,'NOK') != 'OK' THEN
--          vr_dscritic := 'Erro ao enviar o CCB para o FTP: '||vr_dscritic;
--          RAISE vr_exc_saida;
--        END IF;
--DESCOMENTAR CRITICA ACIMA AO ENVIAR PARA HOMOL/PROD                                    
      END IF; 
    
     --
     --
     pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><retorno/>');
     --
     --
     insere_tag(pr_xml      => pr_retorno
               ,pr_tag_pai  => 'retorno'
               ,pr_posicao  => 0
               ,pr_tag_nova => 'Numero_Contrato'
               ,pr_tag_cont => pr_nrctremp
               ,pr_des_erro => vr_dscritic);

     insere_tag(pr_xml      => pr_retorno
               ,pr_tag_pai  => 'retorno'
               ,pr_posicao  => 0
               ,pr_tag_nova => 'Conta'
               ,pr_tag_cont => pr_nrdconta
               ,pr_des_erro => vr_dscritic);

     insere_tag(pr_xml      => pr_retorno
               ,pr_tag_pai  => 'retorno'
               ,pr_posicao  => 0
               ,pr_tag_nova => 'Cooperativa'
               ,pr_tag_cont => pr_cdcooper
               ,pr_des_erro => vr_dscritic);

     pr_des_reto := 'OK';
     --
   EXCEPTION
     WHEN vr_exc_saida THEN
              
       GENE0001.pc_gera_log( pr_cdcooper => pr_cdcooper 
                           , pr_cdoperad => pr_cdoperad
                           , pr_dscritic => vr_dscritic
                           , pr_dsorigem => vr_dsorigem
                           , pr_dstransa => vr_dstransa
                           , pr_dttransa => TRUNC(SYSDATE)
                           , pr_flgtrans => 0 
                           , pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS'))
                           , pr_idseqttl => 1
                           , pr_nmdatela => 'INTERNET'
                           , pr_nrdconta => pr_nrdconta
                           , pr_nrdrowid => vr_aux_log_rowid);
       
     
       --/
       pr_des_reto := 'NOK';
       pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || vr_dscritic ||
                                        '</Erro></Root>');
     WHEN OTHERS THEN
       --/
       pr_des_reto := 'NOK';
       vr_dscritic := 'Erro nao esperado na empr0017.pc_solicita_contratacao: '||substr(SQLERRM,1,300);
       pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' ||vr_dscritic||
                                        '</Erro></Root>');
                                        
       GENE0001.pc_gera_log( pr_cdcooper => pr_cdcooper 
                           , pr_cdoperad => pr_cdoperad
                           , pr_dscritic => vr_dscritic
                           , pr_dsorigem => vr_dsorigem
                           , pr_dstransa => vr_dstransa
                           , pr_dttransa => TRUNC(SYSDATE)
                           , pr_flgtrans => 0 
                           , pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS'))
                           , pr_idseqttl => 1
                           , pr_nmdatela => 'INTERNET'
                           , pr_nrdconta => pr_nrdconta
                           , pr_nrdrowid => vr_aux_log_rowid);                                        

   END pc_solicita_contratacao;
  
  PROCEDURE pc_solicita_contrata_PROG(pr_cdcooper  IN crapcop.cdcooper%TYPE       --Codigo Cooperativa                                                                                            
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE       --Numero da Conta do Associado                               
                                     ,pr_nrctremp  IN INTEGER                     --Numero Contrato Emprestimo
                                     ,pr_cdoperad IN VARCHAR2
                                     ,pr_nrcpfope IN VARCHAR2 
                                     ,pr_nripuser IN VARCHAR2 
                                     ,pr_iddispos IN VARCHAR2 
                                     ,pr_cdagenci IN crapass.cdagenci%TYPE 
                                     ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE     --> Numero do caixa
                                     ,pr_cdorigem IN crawepr.cdorigem%TYPE
                                     -->> SAIDA                                  
                                     ,pr_des_reto OUT VARCHAR  --> Retorno OK / NOK
                                     ,pr_retorno OUT CLOB) IS
  

    vr_xmlret xmltype; 
  BEGIN
    --/
    empr0017.pc_solicita_contratacao(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrctremp => pr_nrctremp
                                    ,pr_cdoperad => pr_cdoperad
                                    ,pr_nrcpfope => pr_nrcpfope
                                    ,pr_nripuser => pr_nripuser
                                    ,pr_iddispos => pr_iddispos
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_cdorigem => pr_cdorigem
                                    ,pr_des_reto => pr_des_reto 
                                    ,pr_retorno =>  vr_xmlret); 
                                                     
    pr_retorno := vr_xmlret.getClobVal();                                   
      
  END pc_solicita_contrata_PROG;                                     
  
  -- Cria notificações
  PROCEDURE pc_cria_notificacao(pr_cdcooper IN crawepr.cdcooper%TYPE      --> Codigo da cooperativa
                               ,pr_nrdconta IN crawepr.nrdconta%TYPE      --> Conta do Associado
                               ,pr_nrctremp IN crawepr.nrctremp%TYPE      --> Número da proposta
                               ,pr_tporigem IN NUMBER DEFAULT 0 --  (0) motor - (1) esteira - (2) efetivacao
                               ,pr_des_reto OUT VARCHAR  --> Retorno OK / NOK
                               ) IS

  /*.............................................................................
     programa: pc_cria_notificacao
     autor   : Rafael (AmCom)
     data    : Janeiro/2018

     dados referentes ao programa:

     frequencia: sempre que for chamado.
     objetivo  : procedure para gerar as notificações de emprestimo necessárias na conta online

    ..............................................................................*/
    --
    -----------> CURSORES <-----------
    --> buscar dados da cooper
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    --> Buscar nome do associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;

    --> Buscar nome do titular
    CURSOR cr_crapttl(pr_cdcooper crapttl.cdcooper%TYPE,
                      pr_nrdconta crapttl.nrdconta%TYPE,
                      pr_idseqttl crapttl.idseqttl%TYPE) IS
      SELECT ttl.nmextttl
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = pr_idseqttl;

    --Selecionar titulares com senhas ativas
    CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%type
                      ,pr_nrdconta IN crapsnh.nrdconta%TYPE) IS
      SELECT crapsnh.nrcpfcgc
            ,crapsnh.cdcooper
            ,crapsnh.nrdconta
            ,crapsnh.idseqttl
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND crapsnh.cdsitsnh = 1
         AND crapsnh.tpdsenha = 1;
    rw_crapsnh cr_crapsnh%ROWTYPE;

    CURSOR cr_crawepr(pr_cdcooper IN crapsnh.cdcooper%TYPE
                     ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                     ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
     SELECT epr.insitapr, epr.vlemprst
       FROM crawepr epr
      WHERE epr.nrdconta = pr_nrdconta
        AND epr.nrctremp = pr_nrctremp
        AND epr.cdcooper = pr_cdcooper;

    rw_crawepr  cr_crawepr%ROWTYPE;

    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_dscritic VARCHAR2(4000);
    vr_exc_saida EXCEPTION;
    --/
    -- Objetos para armazenar as variáveis da notificação
    --
    vr_variaveis_notif NOTI0001.typ_variaveis_notif;
    vr_notif_origem    tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE;
    vr_notif_motivo    tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE;
    vr_dsdassun crapmsg.dsdassun%TYPE;
    vr_cdtipmsg tbgen_tipo_mensagem.cdtipo_mensagem%TYPE;
    vr_nmprimtl crapass.nmprimtl%TYPE := NULL;
    vr_vldinami VARCHAR2(1000);
    vr_dsdmensg crapmsg.dsdmensg%TYPE;
    vr_dsdplchv crapmsg.dsdplchv%TYPE;
    vr_processou BOOLEAN := FALSE;
    vr_des_reto  VARCHAR(10);  --> Retorno OK / NOK
    --/
    vr_cdorigem_mensagem tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE;
    vr_cdmotivo_mensagem tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE;
    --/
    PROCEDURE configura_envio_notificacao(pr_des_reto IN OUT VARCHAR2) IS
    vr_achou BOOLEAN;
    
    BEGIN
    --/
     pr_des_reto := 'OK';
     vr_variaveis_notif('#nomecompleto') := vr_nmprimtl;
     vr_variaveis_notif('#valor')        := fn_decimal_soa(rw_crawepr.vlemprst);
     --
     -- aprovacao(0-em estudo/1-aprovado/2-nao aprovado/3-restricao/4-refazer/5-derivar/6-erro)
     --
     vr_notif_origem := 8;
     --
      IF pr_tporigem IN (0,1) -- (0) motor - (1) esteira
       THEN

         CASE
           WHEN rw_crawepr.insitapr = 1
             THEN
               vr_notif_motivo := 8;  -- Notificação de Proposta Aprovada

           WHEN rw_crawepr.insitapr = 2
             THEN
               vr_notif_motivo := 9;  -- Notificação de Proposta Reprovada
           ELSE
               pr_des_reto := 'NOK';
         END CASE;

      ELSIF pr_tporigem = 2  -- (2) efetivacao
        THEN

         vr_notif_motivo := 10;  -- Notificação de Proposta Creditada em Conta

      END IF;
     --
    END configura_envio_notificacao;

  BEGIN

    FOR rw_crapsnh IN cr_crapsnh (pr_cdcooper  => pr_cdcooper
                                 ,pr_nrdconta  => pr_nrdconta) LOOP
     --/
     OPEN cr_crapass(pr_cdcooper
                    ,pr_nrdconta) ;
      FETCH cr_crapass
     INTO vr_nmprimtl;

     IF cr_crapass%NOTFOUND
      THEN
       CLOSE cr_crapass;
         vr_dscritic  := 'Dados do associado nao localizado';
         RAISE vr_exc_saida;
     END IF;
     --
     CLOSE cr_crapass;

     --/
     OPEN cr_crawepr(pr_cdcooper
                    ,pr_nrdconta
                    ,pr_nrctremp);
     FETCH cr_crawepr INTO rw_crawepr;

     IF cr_crawepr%NOTFOUND
       THEN
        CLOSE cr_crawepr;
        vr_dscritic  := 'Dados de Contrato nao localizado';
        RAISE vr_exc_saida;
     END IF;

     CLOSE cr_crawepr;

     --/ configurar as variaveis para o envio de notificacao
     configura_envio_notificacao(vr_des_reto);
     --
     IF vr_des_reto = 'OK'
       THEN
     --/ cria_notificacao
     noti0001.pc_cria_notificacao(pr_cdorigem_mensagem => vr_notif_origem
                                 ,pr_cdmotivo_mensagem => vr_notif_motivo
                                 ,pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_idseqttl => rw_crapsnh.idseqttl
                                 ,pr_variaveis => vr_variaveis_notif);
       vr_processou := TRUE;                                     
     END IF;                                     
                                     
   --
   END LOOP;
   --
   IF NOT vr_processou
      THEN
        --
        RAISE vr_exc_saida;
        --
   END IF;
   --
   pr_des_reto := 'OK';
   --
  EXCEPTION

    WHEN vr_exc_saida THEN
     --/
     pr_des_reto := 'NOK';

    WHEN OTHERS THEN
     --/
     pr_des_reto := 'NOK';

  END pc_cria_notificacao;

  FUNCTION get_dssituacao(pr_situacao INTEGER) RETURN VARCHAR2 IS
  /* ..................................................................................
   --
   programa: get_dssituacao
   autor   : AmCom
   data    : Janeiro/2018

   dados referentes ao programa:

   frequencia: sempre que for chamado.
   objetivo  : função para auxiliar no "de: para:" da situação da proposta de emprestimo
   --
   ..................................................................................*/

    BEGIN

      CASE
        WHEN pr_situacao = 0 THEN

           RETURN 'Em Analise';

        WHEN pr_situacao = 1 THEN

           RETURN 'Aprovado';

        WHEN pr_situacao = 2 THEN

           RETURN 'Concluido';

        WHEN pr_situacao = 3 THEN

           RETURN 'Expirado';

        WHEN pr_situacao = 4 THEN

           RETURN 'Cancelado';

        ELSE

           RETURN '';

      END CASE;

   END get_dssituacao;

  --/ Procedure para validar transacoes pendentes 
  PROCEDURE pc_solicita_contratacao_ib(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                      ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código de PA do canal de atendimento – Valor '90' para Internet
                                      ,pr_nrdcaixa IN INTEGER  --> Código de caixa do canal de atendimento – Valor fixo '900' para Internet
                                      ,pr_cdoperad IN VARCHAR2 --> Codigo do operador
                                      ,pr_nripuser IN VARCHAR2 --> IP de acesso do cooperado
                                      ,pr_iddispos IN VARCHAR2 --> ID do dispositivo móvel
                                      ,pr_nmdatela IN VARCHAR2 --> Codigo do operador
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta do Cooperado
                                      ,pr_idseqttl IN INTEGER --> Titularidade do Cooperado 
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do Movimento
                                      ,pr_nrcpfope IN VARCHAR2 --> numero do CPF do operador
                                      ,pr_cdorigem IN INTEGER  --> Codigo da origem do canal
                                      ,pr_cdcoptfn IN INTEGER
                                      ,pr_cdagetfn IN INTEGER
                                      ,pr_nrterfin IN INTEGER 
                                      ,pr_nrctremp IN NUMBER
                                      ,pr_des_reto OUT VARCHAR  --> Retorno OK / NOK 
                                      ,pr_dscritic OUT VARCHAR2
                                      ,pr_idastcjt OUT INTEGER
                                      ,pr_qtminast OUT NUMBER
                                       ) IS
   --
   /* ...................................................................................
     
     Programa: pc_solicita_contratacao_ib / referencia de validacoes = InternetBank100.p
     Sistema : Internet - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Rafael R. Santos (AmCom)
     Data    : Fevereiro/2019.
     --
     Dados referentes ao programa:
     Frequencia: Sempre que for chamado (On-Line)
     --
     Objetivo  : Gravar os dados do emprestimo/financiamento
   --
    ....................................................................................*/
   --
   --
   vr_flvldrep NUMBER(1);
   vr_cdcritic INTEGER;
   vr_dscritic VARCHAR2(3000);
   vr_aux_nrctremp crawepr.nrctremp%TYPE;
   vr_idastcjt INTEGER;
   vr_nrcpfcgc crapass.nrcpfcgc%TYPE;
   vr_nmprimtl VARCHAR2(200);
   vr_flcartma INTEGER;
   vr_dstransa VARCHAR2(200);
   vr_nrdrowid ROWID;
   vr_qtminast NUMBER := 0;
   vr_exc_erro EXCEPTION;
   vr_retorno XMLTYPE;
   vr_des_reto VARCHAR2(30);
   vr_gerou_pend BOOLEAN := FALSE;
   --
   vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
   vr_tab_bens CADA0001.typ_tab_bens;          --Tabela bens
   vr_tab_erro GENE0001.typ_tab_erro;          --Tabela Erro
   --/
   CURSOR cr_crawepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_nrdconta IN crawepr.nrdconta%TYPE
                    ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
     SELECT epr.cdoperad,
            epr.cdagenci,
            epr.cdorigem,
            epr.cdcooper,
            epr.nrdconta,
            epr.nrctremp,
            epr.dtlibera,
            epr.dtdpagto,
            epr.insitapr,
            epr.insitest
       FROM crawepr epr
      WHERE cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta
        AND nrctremp = pr_nrctremp;
   --
   rw_crawepr cr_crawepr%ROWTYPE;  
   --
   --/
   FUNCTION get_dscritic(pr_cdcritic crapcri.cdcritic%TYPE) RETURN VARCHAR2 IS   
    CURSOR cr_crapcri(pr_cdcritic crapcri.cdcritic%TYPE) IS
     SELECT dscritic
       FROM crapcri
      WHERE cdcritic = pr_cdcritic
        AND cdcritic > 0;
     rw_crapcri cr_crapcri%ROWTYPE;                               
   --/   
   BEGIN
     OPEN cr_crapcri(pr_cdcritic);
      FETCH cr_crapcri INTO rw_crapcri;
     CLOSE cr_crapcri;

    RETURN NVL(TRIM(rw_crapcri.dscritic),NULL);
   EXCEPTION WHEN OTHERS
     THEN
       RETURN NULL; 
   END get_dscritic;
   --
   FUNCTION exist_transacao_pend_ativa(pr_cdcooper IN NUMBER, pr_nrdconta IN NUMBER, pr_nrctremp IN NUMBER ) RETURN BOOLEAN IS
   --
   vcount NUMBER;
   --/
   BEGIN
     --/
     SELECT COUNT(*)
       INTO vcount
       FROM tbgen_trans_pend pnd,
            tbepr_trans_pend_efet_proposta pndef 
      WHERE pnd.idsituacao_transacao IN (1, -- Pendente
                                         2, -- Aprovada
                                         5  -- Parcialmente Aprovada
                                         )       
        AND pnd.cdtransacao_pendente = pndef.cdtransacao_pendente
        AND pndef.cdcooper = pr_cdcooper
        AND pndef.nrdconta = pr_nrdconta
        AND pndef.nrctremp = pr_nrctremp;
   
    RETURN vcount > 0; 
   END exist_transacao_pend_ativa;
   --/
   FUNCTION exist_contrato(pr_cdcooper IN NUMBER, pr_nrdconta IN NUMBER, pr_nrctremp IN NUMBER ) RETURN BOOLEAN IS
   --
   vcount NUMBER;
   --/
   BEGIN
     --/
     SELECT COUNT(*)
       INTO vcount
       FROM crapepr con   
      WHERE con.cdcooper = pr_cdcooper
        AND con.nrdconta = pr_nrdconta
        AND con.nrctremp = pr_nrctremp;
    --/
    RETURN vcount > 0; 
   END exist_contrato;

   FUNCTION get_row_crapass(pr_cdcooper IN NUMBER, pr_nrdconta IN NUMBER) RETURN crapass%ROWTYPE IS
    CURSOR cr_crapass(pr_cdcooper IN NUMBER, pr_nrdconta IN NUMBER) IS
      SELECT *
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper 
         AND ass.nrdconta = pr_nrdconta;
    --/
    rw_crapass cr_crapass%ROWTYPE;

   BEGIN
     --/
     OPEN cr_crapass(pr_cdcooper,pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
     CLOSE cr_crapass;
          
     --/
     RETURN rw_crapass;
   
   END get_row_crapass;
   --/
  BEGIN
   --/
   gene0001.pc_gera_craplog(pr_cdcooper => pr_cdcooper, 
                            pr_nrdconta => pr_nrdconta, 
                            pr_cdoperad => 'teste', 
                            pr_dstransa => 'pc_solicita_contratacao_ib', 
                            pr_cdprogra => 'empr0017');
   
   IF pr_cdorigem = 3
     THEN
       --/
       empr0017.pc_valida_horario_ib(pr_cdcooper,vr_des_reto,vr_dscritic);
   END IF;    
   --
   --/
   IF NVL(vr_des_reto,'NOK') != 'OK'
       THEN
         RAISE vr_exc_erro;
   END IF;
   --/   
   OPEN cr_crawepr(pr_cdcooper
                  ,pr_nrdconta
                  ,pr_nrctremp);
   FETCH cr_crawepr INTO rw_crawepr;
    IF cr_crawepr%NOTFOUND THEN
       vr_dscritic :='Contrato ' ||pr_nrctremp||' da conta ' ||pr_nrdconta||' da cooperativa ' ||pr_cdcooper||' nao localizado ou fora do periodo de efetivacao';        RAISE vr_exc_erro;
    END IF;
   CLOSE cr_crawepr;
   --/
   IF ( rw_crawepr.insitapr <> 1 OR rw_crawepr.insitest <> 3 ) THEN
       vr_dscritic := 'Situacao da proposta nao permite efetivacao!';
       RAISE vr_exc_erro;
   END IF;    
   --
   --/
   vr_dstransa := 'Gravar os dados do Emprestimo/Financiamento';
   --
   -- { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
   --
   IF NVL(pr_nrcpfope,0) > 0
     THEN
       vr_flvldrep := 0;
   ELSE
       vr_flvldrep := 1;   
   END IF;   
   --
   --/
   IF exist_transacao_pend_ativa(pr_cdcooper,pr_nrdconta,pr_nrctremp)
     THEN
       vr_dscritic := 'Ja existe pendencia gerada para esta proposta';
       RAISE vr_exc_erro;
       
   END IF;
   --
    IF exist_contrato(pr_cdcooper,pr_nrdconta,pr_nrctremp)
     THEN
       vr_dscritic := 'Ja existe contrato gerado para esta proposta';
       RAISE vr_exc_erro;
    END IF;
    --/
    vr_qtminast := get_row_crapass(pr_cdcooper,pr_nrdconta).qtminast;
    --/
    inet0002.pc_valid_repre_legal_trans(pr_cdcooper => pr_cdcooper,
                                        pr_nrdconta => pr_nrdconta,
                                        pr_idseqttl => pr_idseqttl,
                                        pr_flvldrep => vr_flvldrep,
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic);
    --/
    IF vr_cdcritic <> 0 OR  NOT ( vr_dscritic IS NULL )
      THEN
        --/
        vr_dscritic := COALESCE(get_dscritic(vr_cdcritic),vr_dscritic,'Nao foi possivel validar o Representante Legal.');
        RAISE vr_exc_erro;
    END IF;
    --
    --/
    inet0002.pc_verifica_rep_assinatura(pr_cdcooper => pr_cdcooper,
                                        pr_nrdconta => pr_nrdconta, 
                                        pr_idseqttl => pr_idseqttl, 
                                        pr_cdorigem => pr_cdorigem, 
                                        pr_idastcjt => vr_idastcjt, 
                                        pr_nrcpfcgc => vr_nrcpfcgc, 
                                        pr_nmprimtl => vr_nmprimtl, 
                                        pr_flcartma => vr_flcartma, 
                                        pr_cdcritic => vr_cdcritic, 
                                        pr_dscritic => vr_dscritic);
    --
    --/
    IF vr_cdcritic <> 0 OR  NOT ( vr_dscritic IS NULL )
      THEN
        --/
        vr_dscritic := COALESCE(get_dscritic(vr_cdcritic),vr_dscritic,'Nao foi possivel validar o Representante Legal.');
        RAISE vr_exc_erro;
    END IF;
    --
    --/    
    pr_idastcjt := vr_idastcjt;
    pr_qtminast := vr_qtminast;
    -- 
    --/ 
    empr0017.pc_assinatura_contrato(pr_cdcooper => pr_cdcooper, 
                                    pr_cdagenci => pr_cdagenci, 
                                    pr_nrdconta => pr_nrdconta, 
                                    pr_idseqttl => pr_idseqttl, 
                                    pr_dtmvtolt => pr_dtmvtolt, 
                                    pr_cdorigem => pr_cdorigem, 
                                    pr_nrctremp => pr_nrctremp,
                                    pr_tpassinatura => 1, -- associado
                                    pr_des_reto => vr_des_reto, 
                                    pr_dscritic => vr_dscritic);

    IF NOT ( vr_des_reto = 'OK' )
      THEN
        --/
        vr_dscritic := NVL(vr_dscritic,'Nao foi possivel criar transacao pendente de emprestimo/financiamento.');
        RAISE vr_exc_erro;
    END IF;
    --
    --/
    /* Se a conta for exgir assinatura multipla */
    IF vr_idastcjt = 1 
      THEN 
       --/
       inet0002.pc_cria_trans_pend_efet_prop(pr_cdagenci => pr_cdagenci
                                            ,pr_nrdcaixa => pr_nrdcaixa
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_nmdatela => pr_nmdatela
                                            ,pr_idorigem => pr_cdorigem
                                            ,pr_idseqttl => pr_idseqttl                                            
                                            ,pr_nrcpfope => 0
                                            ,pr_nrcpfrep => vr_nrcpfcgc
                                            ,pr_cdcoptfn => pr_cdcoptfn
                                            ,pr_cdagetfn => pr_cdagetfn
                                            ,pr_nrterfin => pr_nrterfin
                                            ,pr_dtmvtolt => pr_dtmvtolt
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_idastcjt => vr_idastcjt
                                            ,pr_nrctremp => pr_nrctremp
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
    --
    IF vr_cdcritic <> 0 OR  NOT ( vr_dscritic IS NULL )
      THEN
        --/
        vr_dscritic := COALESCE(get_dscritic(vr_cdcritic),vr_dscritic,'Nao foi possivel criar transacao pendente de emprestimo/financiamento.');
        RAISE vr_exc_erro;
    END IF;
    --/    
    vr_gerou_pend := TRUE;    
    vr_dscritic := 'Empréstimo/financiamento registrado com sucesso. '||
          chr(13)||'Aguardando aprovação da operação pelos'||
          chr(13)||'demais responsáveis.';
      --GOTO ponto_salvo;
    END IF;
    --
    --
    IF NOT vr_gerou_pend
      THEN
        pc_solicita_contratacao(pr_cdcooper => pr_cdcooper, 
                                pr_nrdconta => pr_nrdconta, 
                                pr_nrctremp => pr_nrctremp, 
                                pr_cdoperad => pr_cdoperad, 
                                pr_nrcpfope => pr_nrcpfope, 
                                pr_nripuser => pr_nripuser, 
                                pr_iddispos => pr_iddispos, 
                                pr_cdagenci => pr_cdagenci, 
                                pr_nrdcaixa => pr_nrdcaixa, 
                                pr_cdorigem => pr_cdorigem, 
                                pr_des_reto => pr_des_reto, 
                                pr_retorno =>  vr_retorno);
        --/
        IF nvl(pr_des_reto,'NOK') != 'OK'
          THEN
            vr_dscritic := replace(replace(vr_retorno.extract('/Root/Erro').getstringval(),'<Erro>'),'</Erro>');
            RAISE vr_exc_erro;
        END IF;
        --
        vr_dscritic := vr_retorno.extract('/retorno/Numero_Contrato').getstringval();  
        -- verificar retorno
    END IF;
    --
    --/
    IF vr_gerou_pend THEN
      pr_dscritic := vr_dscritic;   
    END IF;
    pr_des_reto := 'OK';
    --
  EXCEPTION 
    WHEN vr_exc_erro
     THEN
      pr_dscritic := vr_dscritic;
      pr_des_reto :=  'NOK'  ;

    WHEN OTHERS
      THEN

      pr_dscritic := 'Erro nao esperado na pc_solicita_contratacao_ib - '||SQLERRM;
      pr_des_reto :=  'NOK'  ;
        
  END pc_solicita_contratacao_ib;

  --/ Procedure para assinaturas do contrato de emprestimo
  PROCEDURE pc_assinatura_contrato(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código de PA do canal de atendimento – Valor '90' para Internet                                  
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta do Cooperado
                                  ,pr_idseqttl IN INTEGER --> Titularidade do Cooperado 
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do Movimento
                                  ,pr_cdorigem IN INTEGER  --> Codigo da origem do canal
                                  ,pr_nrctremp IN NUMBER   --> numero o contrato de emprestimo
                                  ,pr_tpassinatura IN NUMBER --> tipo de assinatura (1 socio/2 - cooperativa)                                  
                                  ,pr_des_reto OUT VARCHAR  --> Retorno OK / NOK 
                                  ,pr_dscritic OUT VARCHAR2) IS
  --
   --
   /* ...................................................................................
     
     Programa: pc_assinatura_contrato
     Sistema : Internet - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Rafael R. Santos (AmCom)
     Data    : Fevereiro/2019.
     --
     Dados referentes ao programa:
     Frequencia: Sempre que for chamado (On-Line)
     --
     Objetivo  : Gravar os dados de assinatura para o contrato de emprestimo/financiamento
   --
    ....................................................................................*/
  --
  --/
  vr_dtassinatura DATE;
  vr_hrassinatura VARCHAR2(10);
  vr_nmassinatura tbepr_assinaturas_contrato.nmassinatura%TYPE;
  vr_nrcpfcgc crapsnh.nrcpfcgc%TYPE;
  vr_row_pessoa tbcadast_pessoa%ROWTYPE;
  vr_dscritic VARCHAR2(4000);
  vr_aux_log_rowid rowid;
  rw_crapcop crapcop%ROWTYPE;
  --
  --/
  CURSOR cr_crawepr(pr_cdcooper IN crapcop.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE,
                    pr_nrctremp IN NUMBER) IS
    SELECT dtmvtolt,
           cdagenci,
           cdcooper,
           nrdconta,
           nrctremp,
           cdfinemp,
           cdlcremp           
      FROM crawepr epr
     WHERE epr.cdcooper = pr_cdcooper
       AND epr.nrdconta = pr_nrdconta
       AND epr.nrctremp = pr_nrctremp;
  --
  CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE) IS
   SELECT * 
     FROM crapass 
    WHERE cdcooper = pr_cdcooper
      AND nrdconta = pr_nrdconta;
   --/
   rw_crapass cr_crapass%ROWTYPE;
  --
  FUNCTION fn_get_nrcpfcgc(pr_cdcooper IN crapcop.cdcooper%TYPE,
                           pr_nrdconta IN crapass.nrdconta%TYPE,
                           pr_idseqttl IN INTEGER,
                           pr_inpessoa IN crapass.inpessoa%TYPE) RETURN crapsnh.nrcpfcgc%TYPE IS
  --/
   vr_nrcpfcgc crapsnh.nrcpfcgc%TYPE;
  --
   CURSOR cr_crapsnh(pr_cdcooper IN crapcop.cdcooper%TYPE,
                     pr_nrdconta IN crapass.nrdconta%TYPE,
                     pr_idseqttl IN INTEGER ) IS
     SELECT *
       FROM crapsnh snh
      WHERE snh.cdcooper = pr_cdcooper
        AND snh.nrdconta = pr_nrdconta
        AND snh.idseqttl = pr_idseqttl
        AND snh.tpdsenha = 1;
   rw_crapsnh cr_crapsnh%ROWTYPE;
   --
   CURSOR cr_crapttl IS
    SELECT * 
      FROM crapttl ttl
     WHERE ttl.cdcooper = pr_cdcooper
       AND ttl.nrdconta = pr_nrdconta
       AND ttl.idseqttl = pr_idseqttl;
   --/
   rw_crapttl  cr_crapttl%ROWTYPE;
   --
   --/
   CURSOR cr_crapavt(pr_cdcooper IN crapcop.cdcooper%TYPE,
                     pr_nrdconta IN crapass.nrdconta%TYPE,
                     pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE) IS
    SELECT crapavt.nrcpfcgc
      FROM crapavt 
     WHERE crapavt.cdcooper = pr_cdcooper
       AND crapavt.nrdconta = pr_nrdconta
       AND crapavt.nrcpfcgc = pr_nrcpfcgc
       AND crapavt.tpctrato = 6 /* Jur */;
   --
   rw_crapavt cr_crapavt%ROWTYPE;
   --
   --/
   BEGIN
    --
    --/ 
    IF pr_inpessoa = 1 THEN
      --/
      OPEN cr_crapttl;
      FETCH cr_crapttl INTO rw_crapttl;
      CLOSE cr_crapttl;
      vr_nrcpfcgc := rw_crapttl.nrcpfcgc;
    
    ELSIF pr_inpessoa = 2 THEN
      --/
      OPEN cr_crapsnh(pr_cdcooper,pr_nrdconta,pr_idseqttl);
      FETCH cr_crapsnh INTO rw_crapsnh;
      CLOSE cr_crapsnh;
      vr_nrcpfcgc :=  nvl(rw_crapsnh.nrcpfcgc,0);
       IF vr_nrcpfcgc = 0 THEN
         OPEN cr_crapass(rw_crapsnh.cdcooper,
                         rw_crapsnh.nrdconta);
         FETCH cr_crapass INTO rw_crapass;
         CLOSE cr_crapass;
         vr_nrcpfcgc := rw_crapass.nrcpfcgc;
       END IF;
    END IF;
    
    RETURN NVL(vr_nrcpfcgc,NULL);
    --/
   EXCEPTION WHEN OTHERS
     THEN
       RETURN NULL; 
   END fn_get_nrcpfcgc;        
  --
  --/
  FUNCTION fn_getrow_pessoa(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE) RETURN tbcadast_pessoa%ROWTYPE IS
   CURSOR cr_pessoa(pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT * 
      FROM tbcadast_pessoa psoa
     WHERE psoa.nrcpfcgc = pr_nrcpfcgc;
   --/   
   rw_pessoa   cr_pessoa%ROWTYPE;
   --/   
  BEGIN
    OPEN cr_pessoa(pr_nrcpfcgc);
    FETCH cr_pessoa INTO rw_pessoa;
    CLOSE cr_pessoa;
    
    RETURN rw_pessoa;
  EXCEPTION WHEN OTHERS 
    THEN
      RETURN NULL;
  END fn_getrow_pessoa;
  --  
  FUNCTION fn_get_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN crapcop%ROWTYPE IS 
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT * 
      FROM crapcop 
     WHERE cdcooper = pr_cdcooper;
    rw_crapcop  cr_crapcop%ROWTYPE;
  BEGIN
    OPEN cr_crapcop(pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    CLOSE cr_crapcop;
    
    RETURN rw_crapcop;
  END fn_get_crapcop;   
  --
  --/  
  BEGIN
   --
   --/
   vr_dtassinatura := SYSDATE;
   vr_hrassinatura := to_char(SYSDATE,'hh24:mi');
   --
   --/
   OPEN cr_crapass(pr_cdcooper,pr_nrdconta);
   FETCH cr_crapass INTO rw_crapass;
   CLOSE cr_crapass;
   --   
   IF pr_tpassinatura <> 2
     THEN
       vr_nrcpfcgc := fn_get_nrcpfcgc(pr_cdcooper,pr_nrdconta,pr_idseqttl,rw_crapass.inpessoa);
     --/
     IF ( vr_nrcpfcgc IS NULL )
       THEN
         --/
         vr_dscritic := 'Dados invalidos (1)';
         RAISE vr_exc_erro;
     END IF;
   --/
   vr_row_pessoa := fn_getrow_pessoa( vr_nrcpfcgc );
   vr_nmassinatura := vr_row_pessoa.nmpessoa;
   --
   --/
     IF nvl(vr_row_pessoa.idpessoa,0) = 0
       THEN
         --/
         vr_dscritic := 'Dados invalidos (2)';
         RAISE vr_exc_erro;
     END IF;
   
   ELSIF pr_tpassinatura = 2
     THEN
       
      rw_crapcop := fn_get_crapcop(pr_cdcooper);
      vr_nmassinatura := rw_crapcop.nmextcop;
   END IF; 
   --
   --/
   FOR rw_crawepr IN cr_crawepr(pr_cdcooper,pr_nrdconta,pr_nrctremp)
     LOOP
       BEGIN
        --/
        INSERT INTO tbepr_assinaturas_contrato
                     (cdcooper,
                      nrdconta,
                      nrctremp,
                      idseqttl,
                      tpassinatura,
                      nrcpfcgc,
                      dtassinatura,
                      hrassinatura,
                      nmassinatura)
                     VALUES    
                     (rw_crawepr.cdcooper,
                      rw_crawepr.nrdconta,
                      rw_crawepr.nrctremp,
                      pr_idseqttl,
                      pr_tpassinatura,
                      vr_row_pessoa.nrcpfcgc,
                      vr_dtassinatura,
                      vr_hrassinatura,
                      vr_nmassinatura    
                      );
       --/
       EXCEPTION WHEN OTHERS
         THEN
            vr_dscritic := 'Erro assinatura '||SQLERRM;
            RAISE vr_exc_erro;
       END;
       
       --Geração de LOG
       GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper 
                          , pr_cdoperad => 1
                          , pr_dscritic => pr_dscritic
                          , pr_dsorigem => gene0001.vr_vet_des_origens(pr_cdorigem)
                          , pr_dstransa => 'Assinatura digital da proposta ' || rw_crawepr.nrctremp
                          , pr_dttransa => trunc(vr_dtassinatura)
                          , pr_flgtrans => 1 
                          , pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS'))
                          , pr_idseqttl => pr_idseqttl
                          , pr_nmdatela => ''
                          , pr_nrdconta => pr_nrdconta
                          , pr_nrdrowid => vr_aux_log_rowid); 
                            
       GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                   ,pr_nmdcampo => 'Tipo Assinatura'
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => CASE WHEN pr_tpassinatura = 1 THEN 'Socio' ELSE 'Cooperativa' END); 
       
       GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                   ,pr_nmdcampo => 'Hora'
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => vr_hrassinatura);
       
       GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                   ,pr_nmdcampo => 'Nome'
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => vr_nmassinatura);
                                   
       GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                   ,pr_nmdcampo => 'Proposta'
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => rw_crawepr.nrctremp);
       
   END LOOP;
  --
  --/
  pr_des_reto := 'OK';
  
  EXCEPTION 
    WHEN vr_exc_erro
     THEN
      --/
      pr_dscritic := vr_dscritic;
      pr_des_reto := 'NOK';

    WHEN OTHERS
      THEN
      --/
      pr_dscritic := 'Erro nao eperado na pc_assinatura_contrato - '||SQLERRM;
      pr_des_reto := 'NOK';

  END pc_assinatura_contrato;                                      
  PROCEDURE pc_verifica_linha_segmento(pr_cdcooper  IN crawepr.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_cdlcremp  IN INTEGER               --> Id identificador da Linha de crédito
                                      ,pr_cdfinemp  IN INTEGER               --> Id identificador da Finalidade de crédito
                                      ,pr_flgativo OUT INTEGER               --> [0 - NAO ATIVO] / [1 - ATIVO]
                                      ,pr_cdcritic OUT INTEGER               --> Código de críticia
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
                                      
  --CURSOR PARA SUBSEGMENTOS
  CURSOR cr_subsegmento IS
    SELECT * 
      FROM tbepr_subsegmento s
     WHERE s.cdcooper = pr_cdcooper
       AND ( (s.cdlinha_credito = pr_cdlcremp) OR (s.cdfinalidade = pr_cdfinemp) );
    rw_subsegmento cr_subsegmento%ROWTYPE;       
       
  BEGIN
    
    pr_flgativo := 0;
    
    OPEN cr_subsegmento;
    FETCH cr_subsegmento INTO rw_subsegmento;
    
    IF cr_subsegmento%FOUND THEN 
      pr_flgativo := 1;
    END IF;
    
    CLOSE cr_subsegmento;
      
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro não tratado na EMPR0017.pc_verifica_linha_segmento ' || SQLERRM; 
      
    
  END; 

  PROCEDURE pc_inclui_proposta_esteira(pr_cdcooper IN crapcop.cdcooper%TYPE
                                      ,pr_cdagenci IN crapass.cdagenci%TYPE 
                                      ,pr_cdoperad IN crawepr.cdoperad%TYPE --> Codigo do operador                                                             
                                      ,pr_cdorigem IN crawepr.cdorigem%TYPE            
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE 
                                      ,pr_nrctremp IN crawepr.nrctremp%TYPE
                                      ,pr_dtmvtolt IN DATE
                                      ,pr_des_reto OUT VARCHAR2 
                                       ) IS
    --/
    vr_dsmensag VARCHAR2(32767);
    vr_cdcritic_esteira crapcri.cdcritic%TYPE;
    vr_dscritic_esteira VARCHAR2(4000); 
    vr_aux_log_rowid ROWID;
    vr_qtsegundos NUMBER;
    --
    CURSOR cr_crawepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
      SELECT *
        FROM crawepr wpr
       WHERE wpr.cdcooper = pr_cdcooper
         AND wpr.nrdconta = pr_nrdconta
         AND wpr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;
    --/      
    FUNCTION fn_getsegundos RETURN NUMBER IS
      BEGIN
        RETURN to_number(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                   pr_cdcooper => 0,
                                                   pr_cdacesso => 'ANALISE_AUTO_QTSEGUNDOS'));
      EXCEPTION WHEN OTHERS
        THEN
          RETURN NULL;
    END fn_getsegundos;
  
    BEGIN
    --/
      pr_des_reto := 'OK';
      --/      
      vr_qtsegundos := NVL(fn_getsegundos(),10);
      --
      -- este0001.pc_setqtsegund(vr_qtsegundos);
      OPEN cr_crawepr(pr_cdcooper,pr_nrdconta,pr_nrctremp);
      FETCH cr_crawepr INTO rw_crawepr;
       IF cr_crawepr%FOUND THEN
         CLOSE cr_crawepr;
        --/
        este0001.pc_incluir_proposta_est(pr_cdcooper => pr_cdcooper,
                                         pr_cdagenci => pr_cdagenci,
                                         pr_cdoperad => pr_cdoperad,
                                         pr_cdorigem => pr_cdorigem,
                                         pr_nrdconta => pr_nrdconta,
                                         pr_nrctremp => pr_nrctremp,
                                         pr_dtmvtolt => pr_dtmvtolt,
                                         pr_nmarquiv => NULL,
                                         pr_dsmensag => vr_dsmensag,
                                         pr_cdcritic => vr_cdcritic_esteira,
                                         pr_dscritic => vr_dscritic_esteira);
       ELSE
         CLOSE cr_crawepr;
       END IF;                                         
     --
     --/     
     --Geração de LOG
     GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper 
                        , pr_cdoperad => pr_cdoperad
                        , pr_dscritic => vr_dscritic_esteira
                        , pr_dsorigem => gene0001.vr_vet_des_origens(pr_cdorigem)
                        , pr_dstransa => 'Envio de proposta para analise'
                        , pr_dttransa => TRUNC(SYSDATE)
                        , pr_flgtrans => 1 
                        , pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS'))
                        , pr_idseqttl => 0
                        , pr_nmdatela => ''
                        , pr_nrdconta => pr_nrdconta
                        , pr_nrdrowid => vr_aux_log_rowid); 
                          
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Simulacao'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => nvl(to_char(rw_crawepr.nrsimula),' '));
                                 
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Proposta'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => nvl(rw_crawepr.nrctremp,pr_nrctremp));      
                                 
     GENE0001.pc_gera_log_item(pr_nrdrowid => vr_aux_log_rowid
                                 ,pr_nmdcampo => 'Retorno'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => vr_dsmensag);                                     
                                 
     IF vr_cdcritic_esteira <> 0 OR  NOT ( TRIM(vr_dscritic_esteira) IS NULL )
       THEN
         pr_des_reto := 'NOK';
     END IF;    
    --
    --
    END pc_inclui_proposta_esteira;

  PROCEDURE pc_start_motor(pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE 
                          ,pr_nrctremp IN crawepr.nrctremp%TYPE
                          ,pr_job_reenvio IN NUMBER DEFAULT 0) IS
    CURSOR cr_crawepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
      SELECT wpr.*,
             ass.cdagenci cdagenci_ass
        FROM crawepr wpr,
             crapass ass
       WHERE ass.cdcooper = wpr.cdcooper
         AND ass.nrdconta = wpr.nrdconta  
         AND wpr.cdcooper = pr_cdcooper
         AND wpr.nrdconta = pr_nrdconta
         AND wpr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;
    
    CURSOR cr_reenvio (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE 
                      ,pr_nrctremp IN crawepr.nrctremp%TYPE ) IS
      SELECT r.cdagenci, r.cdoperad
        FROM tbepr_reenvio_analise r
       WHERE r.cdcooper = pr_cdcooper
         AND r.nrdconta = pr_nrdconta
         AND r.nrctremp = pr_nrctremp
       ORDER BY r.idreenvio desc;
    rw_reenvio cr_reenvio%ROWTYPE;
       
    vr_des_reto VARCHAR2(10);
    
    vr_cdagenci tbepr_reenvio_analise.cdagenci%TYPE;
    vr_cdoperad tbepr_reenvio_analise.cdoperad%TYPE;

  BEGIN
 
       OPEN cr_crawepr(pr_cdcooper,pr_nrdconta,pr_nrctremp);
      FETCH cr_crawepr INTO rw_crawepr;
       IF cr_crawepr%FOUND THEN
         CLOSE cr_crawepr;
         --/
       IF pr_job_reenvio > 0 THEN
          este0001.pc_set_job_reenvioanalise();
         
         -- Busca o reenvio agendado para usar o mesmo operador
         -- e pa na ultima consulta da proposta
         OPEN cr_reenvio(pr_cdcooper,pr_nrdconta,pr_nrctremp);
         FETCH cr_reenvio INTO rw_reenvio;
         IF cr_reenvio%FOUND THEN
           CLOSE cr_reenvio;
           vr_cdagenci := nvl(rw_reenvio.cdagenci,0);
           vr_cdoperad := nvl(rw_reenvio.cdoperad,'');  
         ELSE
           CLOSE cr_reenvio;
         END IF;
       END IF; 
       
       IF nvl(vr_cdagenci,0) = 0 THEN
         vr_cdagenci := rw_crawepr.cdagenci_ass;
       END IF;
       
       IF vr_cdoperad = '' or vr_cdoperad is null THEN
         vr_cdoperad := rw_crawepr.cdoperad;
       END IF;

         pc_inclui_proposta_esteira(pr_cdcooper => rw_crawepr.cdcooper
                                 ,pr_cdagenci => vr_cdagenci 
                                 ,pr_cdoperad => vr_cdoperad
                                   ,pr_cdorigem => rw_crawepr.cdorigem
                                   ,pr_nrdconta => rw_crawepr.nrdconta
                                   ,pr_nrctremp => rw_crawepr.nrctremp
                                   ,pr_dtmvtolt => rw_crawepr.dtmvtolt
                                   ,pr_des_reto => vr_des_reto);
         --/
       /* IF vr_des_reto = 'NOK' 
           THEN
             --/
             pc_email_esteira(pr_cdcooper => rw_crawepr.cdcooper,
                              pr_nrdconta => rw_crawepr.nrdconta,
                              pr_nrctremp => rw_crawepr.nrctremp);
         END IF;*/
       --/
       ELSE
         CLOSE cr_crawepr; 
       END IF;
  END pc_start_motor;
  --/    
  PROCEDURE pc_aciona_motor(pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_nrdconta IN crapass.nrdconta%TYPE 
                           ,pr_nrctremp IN crawepr.nrctremp%TYPE
                           ,pr_timestamp IN TIMESTAMP WITH TIME ZONE DEFAULT NULL
                           ,pr_job_reenvio IN BOOLEAN DEFAULT FALSE) IS
   --/
   CURSOR cr_verifica_job(pr_jobname   IN VARCHAR2
                         ,pr_cdcooper  IN crapass.cdcooper%TYPE
                         ,pr_nrdconta  IN crapass.nrdconta%TYPE
                         ,pr_nrctremp  IN NUMBER
                          ) IS
      SELECT DISTINCT 1
        FROM dba_scheduler_jobs
       WHERE owner         = 'CECRED'
         AND job_name   LIKE '%'||pr_jobname||'%'
         AND JOB_ACTION LIKE '%pr_cdcooper => '||pr_cdcooper||'%'
         AND JOB_ACTION LIKE '%pr_nrdconta => '||pr_nrdconta||'%'
         AND JOB_ACTION LIKE '%pr_nrctremp => '||pr_nrctremp||'%';
   
    rw_verifica_job cr_verifica_job%ROWTYPE;
    --
    -- Bloco PLSQL para chamar a execução paralela do pc_crps414
    vr_dsplsql VARCHAR2(4000);
    -- Job name dos processos criados
    vr_jobname VARCHAR2(100);
   vr_timestamp TIMESTAMP;
    vr_dscritic crapcri.dscritic%TYPE;
   ct_next_min  CONSTANT TIMESTAMP WITH TIME ZONE := (SYSDATE + 1/1440);
   --
   PROCEDURE pc_atualiza_qtd_reenvio(pr_cdcooper  IN crapass.cdcooper%TYPE
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE
                                   ,pr_nrctremp  IN NUMBER) IS
    --/
    vr_existe_agendamento NUMBER;
    --/
    BEGIN
     --/
     SELECT COUNT(*)
       INTO vr_existe_agendamento
       FROM tbepr_reenvio_analise ra
      WHERE ra.cdcooper = pr_cdcooper
        AND ra.nrdconta = pr_nrdconta
        AND ra.nrctremp = pr_nrctremp;
     --/
     IF vr_existe_agendamento > 0 THEN
       UPDATE crawepr w
          SET w.qttentreenv = NVL(w.qttentreenv,0) + 1
        WHERE w.cdcooper = pr_cdcooper
          AND w.nrdconta = pr_nrdconta
          AND w.nrctremp = pr_nrctremp;
     END IF;
     --/
   EXCEPTION WHEN OTHERS THEN
      NULL;
   END pc_atualiza_qtd_reenvio;
   --/
   --/ Atualiza situação do agendamento de reenvio automatico para analise quando existir
   PROCEDURE pc_atualiza_agendamento(pr_cdcooper  IN crawepr.cdcooper%TYPE
                                    ,pr_nrdconta  IN crawepr.nrdconta%TYPE
                                    ,pr_nrctremp  IN crawepr.nrctremp%TYPE ) IS
    BEGIN
      --/
      FOR rw_agend IN ( SELECT *
                          FROM tbepr_reenvio_analise tra
                         WHERE tra.cdcooper = pr_cdcooper
                           AND tra.nrdconta = pr_nrdconta
                           AND tra.nrctremp = pr_nrctremp
                           AND trunc(tra.dtagernv) = trunc(sysdate) )
      LOOP
       --/
       UPDATE tbepr_reenvio_analise r
          SET r.insitrnv = 3 -- Em execucao
        WHERE r.cdcooper = rw_agend.cdcooper
          AND r.nrdconta = rw_agend.nrdconta
          AND r.nrctremp = rw_agend.nrctremp;
      END LOOP;
      --/
   END pc_atualiza_agendamento;
   --
   --/
   BEGIN
     --/
     pc_atualiza_qtd_reenvio(pr_cdcooper,pr_nrdconta,pr_nrctremp);
     pc_atualiza_agendamento(pr_cdcooper,pr_nrdconta,pr_nrctremp);
     COMMIT;
     --       
     --/ se nao chegar valor pelo parametro, programa para o proximo minuto.
     vr_timestamp := nvl(pr_timestamp,ct_next_min);

      -- Montar o prefixo do código do programa para o jobname
      vr_jobname := 'JBEPR_START_MOTOR_$';
     OPEN cr_verifica_job (pr_jobname   => 'JBEPR_START_MOTOR_'
                           ,pr_cdcooper  => pr_cdcooper
                           ,pr_nrdconta  => pr_nrdconta
                           ,pr_nrctremp  => pr_nrctremp);
      FETCH cr_verifica_job
       INTO rw_verifica_job;
      IF cr_verifica_job%NOTFOUND THEN
        CLOSE cr_verifica_job;
            -- Acionar rotina para derivação automatica em  paralelo
        vr_dsplsql := 'BEGIN'||chr(13)
                       || '  EMPR0017.pc_start_motor(pr_cdcooper => '||pr_cdcooper ||chr(13)
                       || '                         ,pr_nrdconta => '||pr_nrdconta ||chr(13)
                       || '                         ,pr_nrctremp => '||pr_nrctremp||chr(13);
        IF pr_job_reenvio THEN
          vr_dsplsql := vr_dsplsql || '                         ,pr_job_reenvio => '||'1'||chr(13);
        END IF;
         vr_dsplsql := vr_dsplsql || '                          );'||chr(13)
                       || 'END;';
        -- Faz a chamada ao programa paralelo atraves de JOB
        gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper  --> Código da cooperativa
                              ,pr_cdprogra  => 'JBEPR_START_MOTOR' --> Código do programa
                              ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                              ,pr_dthrexe   => vr_timestamp -- SYSDATE  + 1/1440 --> Executar após 1 minuto
                              ,pr_interva   => null         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                              ,pr_jobname   => vr_jobname   --> Nome randomico criado
                              ,pr_des_erro  => vr_dscritic);
        -- Testar saida com erro
        IF vr_dscritic IS NOT NULL THEN
          -- Adicionar ao LOG e continuar o processo
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                     pr_ind_tipo_log => 2,
                                     pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                     || ' - JBEPR_START_MOTOR --> Erro ao gerar dados para analise de credito. '
                                                     || ', erro: '||vr_dscritic,
                                     pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                                  pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
          --/
        END IF;
        
      ELSE
        CLOSE cr_verifica_job;
      END IF;
   EXCEPTION WHEN OTHERS THEN
           pc_email_esteira(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrctremp => pr_nrctremp);                                                                                  

    END pc_aciona_motor;    
  --/
   PROCEDURE pc_email_esteira(pr_cdcooper IN NUMBER,
                              pr_nrdconta IN NUMBER,
                              pr_nrctremp IN NUMBER) IS
    --
    --/ Esta subrotina nao deverá abortar a operação caso dê algum tipo de erro
    --
    vr_cdprogra CONSTANT VARCHAR2(80) := 'PC_GERA_PROPOSTA';
    vr_conteudo VARCHAR2(4000);
    vr_email_dest VARCHAR2(4000); 
    vr_dscritic crapcri.dscritic%TYPE;   
    --/
    FUNCTION fn_get_email_pa(pr_cdcoooper IN NUMBER,                              
                              pr_nrdconta IN NUMBER) RETURN VARCHAR2 IS
      vr_email crapage.dsdemail%TYPE;
      BEGIN
        SELECT g.dsdemail 
          INTO vr_email
          FROM crapass a,
               crapage g
         WHERE a.cdcooper = g.cdcooper
           AND a.cdagenci = g.cdagenci
           AND a.cdcooper = pr_cdcoooper
           AND a.nrdconta = pr_nrdconta;

      RETURN vr_email;     
      EXCEPTION WHEN OTHERS
      THEN 
        RETURN NULL; 
    END fn_get_email_pa;
    --/   
    BEGIN
      --
      --/ aqui ele busca o e-mail que estiver parametrizadodo  caso nao encontre no cadastro busca do PA, 
      vr_email_dest := nvl(gene0001.fn_param_sistema('CRED',pr_cdcooper,'ERRO_EMAIL_ESTEIRA')
                          ,fn_get_email_pa(pr_cdcooper,pr_nrdconta));
      --
      -- Gravar conteudo do email, controle com substr para não estourar campo texto
      vr_conteudo := substr('Ocorreu erro no envio da proposta'||chr(32)||trim(gene0002.fn_mask_contrato(pr_nrcontrato => pr_nrctremp))||' da conta'||chr(32)||trim(gene0002.fn_mask_conta(pr_nrdconta => pr_nrdconta))||', originada na conta online.'
                       ||chr(10)||'Para o cooperado receber um retorno da analise a proposta deverá ser enviada novamente.'
                       ||chr(10)||'Acesse  o Aimaro> Atenda> Empréstimos e faça o envio da proposta.',1,4000);
      --
      --/      
      IF NOT ( vr_email_dest IS NULL )
        THEN
      
        gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                  ,pr_cdprogra        => vr_cdprogra
                                  ,pr_des_destino     => vr_email_dest
                                  ,pr_des_assunto     => 'Falha no envio de proposta para o Motor de Credito'
                                  ,pr_des_corpo       => vr_conteudo
                                  ,pr_des_anexo       => NULL
                                  ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                  ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dscritic);
                                  
      END IF;                                  
      --                            
      --/
      IF TRIM(vr_dscritic) IS NULL THEN
        COMMIT;
      END IF;
      
    EXCEPTION WHEN OTHERS    
      THEN
        NULL;
    END pc_email_esteira;


END empr0017;
/
