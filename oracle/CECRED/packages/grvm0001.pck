CREATE OR REPLACE PACKAGE CECRED.GRVM0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: GRVM0001                        Antiga: b1wgen0171.p
  --  Autor   : Douglas Pagel
  --  Data    : Dezembro/2013                     Ultima Atualizacao: 11/10/2016
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
  
  -- Atualiza os dados conforme o cdorigem para geração de arquivos cyber
  PROCEDURE pc_solicita_baixa_automatica(pr_cdcooper IN crapbpr.cdcooper%type -- Código da Cooperativa
                                     ,pr_nrdconta IN crapbpr.nrdconta%type -- Numero da conta do associado
                                     ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Numero do contrato
                                     ,pr_dtmvtolt IN DATE                  -- Data de movimento para baixa
                                     ,pr_des_reto OUT VARCHAR2             -- Retorno OK ou NOK do procedimento
                                     ,pr_tab_erro OUT gene0001.typ_tab_erro-- Retorno de erros em PlTable
                                     ,pr_cdcritic OUT PLS_INTEGER          -- Código de erro gerado em excecao
                                     ,pr_dscritic OUT VARCHAR2);         -- Descricao de erro gerado em excecao

  /* Geração dos arquivos do GRAVAMES */
  PROCEDURE pc_gravames_geracao_arquivo(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa conectada
                                       ,pr_cdcoptel  IN crapcop.cdcooper%TYPE -- Opção selecionada na tela
                                       ,pr_tparquiv  IN VARCHAR2              -- Tipo do arquivo selecionado na tela
                                       ,pr_dtmvtolt  IN DATE                  -- Data atual
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE -- Cod Critica de erro
                                       ,pr_dscritic OUT VARCHAR2);            -- Des Critica de erro

  /* Procedure para desfazer a solicitação de baixa automatica */
  PROCEDURE pc_desfazer_baixa_automatica(pr_cdcooper IN crapbpr.cdcooper%TYPE       -- Cód. cooperativa
                                        ,pr_nrdconta IN crapbpr.nrdconta%TYPE       -- Nr. da conta
                                        ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE       -- Nr. contrato
                                        ,pr_des_reto OUT VARCHAR2                   -- Descrição de retorno OK/NOK
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro);    -- Retorno de erros em PlTable

  PROCEDURE pc_gravames_processa_retorno(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa conectada
                                        ,pr_cdcoptel  IN crapcop.cdcooper%TYPE -- Opção selecionada na tela
                                        ,pr_cdoperad  IN crapope.cdoperad%TYPE -- Código do operador
                                        ,pr_tparquiv  IN VARCHAR2              -- Tipo do arquivo selecionado na tela
                                        ,pr_dtmvtolt  IN DATE                  -- Data atual
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE -- Cod Critica de erro
                                        ,pr_dscritic OUT VARCHAR2) ;           -- Des Critica de erro
  
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
  
  PROCEDURE pc_gravames_baixa_manual(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                    ,pr_cddopcao IN VARCHAR2              --Opção
                                    ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                    ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE --Tipo do contrato
                                    ,pr_idseqbem IN crapbpr.idseqbem%TYPE --Identificador do bem
                                    ,pr_nrgravam IN crapbpr.nrgravam%TYPE --Número do gravam
                                    ,pr_dsjstbxa IN crapbpr.dsjstbxa%TYPE -- Justificativa da baixa
                                    ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
  
  PROCEDURE pc_gravames_cancelar(pr_nrdconta in crapass.nrdconta%type, --Número da conta
                                 pr_cddopcao in varchar2,              --Opção
                                 pr_nrctrpro in crawepr.nrctremp%type, --Número do contrato 
                                 pr_idseqbem in crapbpr.idseqbem%type, --Identificador do bem
                                 pr_tpctrpro in crapbpr.tpctrpro%type, --Tipo do contrato
                                 pr_tpcancel in integer,               --Tipo de cancelamento
                                 pr_cdopeapr in varchar2,              --Operador da aprovação
                                 pr_dsjuscnc in crapbpr.dsjuscnc%type,  -- Justificativa
                                 pr_xmllog   in varchar2,              --XML com informações de LOG
                                 pr_cdcritic out pls_integer,          --Código da crítica
                                 pr_dscritic out varchar2,             --Descrição da crítica
                                 pr_retxml   in out nocopy xmltype,    --Arquivo de retorno do XML
                                 pr_nmdcampo out varchar2,             --Nome do Campo
                                 pr_des_erro out varchar2);            --Saida OK/NOK

  PROCEDURE pc_gravames_inclusao_manual(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                       ,pr_cddopcao IN VARCHAR2              --Opção
                                       ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                       ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE --Tipo do contrato
                                       ,pr_idseqbem IN crapbpr.idseqbem%TYPE --Identificador do bem
                                       ,pr_nrgravam IN crapbpr.nrgravam%TYPE --Número do gravam
                                       ,pr_dtmvttel IN VARCHAR2              --Data do registro
                                       ,pr_dsjustif IN crapbpr.dsjstbxa%TYPE --Justificativa da inclusão
                                       ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
                                       
  -- Alertar gravames sem efetivação por email                                                                                                       
  procedure pc_alerta_gravam_sem_efetiva;
                                 
  -- Buscar Situação Gravames do Bem repassado
  PROCEDURE pc_situac_gravame_bem(pr_cdcooper in crapbpr.cdcooper%TYPE
                                 ,pr_nrdconta in crapbpr.nrdconta%TYPE
                                 ,pr_nrctrpro in crapbpr.nrctrpro%TYPE
                                 ,pr_idseqbem in crapbpr.idseqbem%TYPE
                                 ,pr_dssituac OUT VARCHAR2
                                 ,pr_dscritic OUT VARCHAR2);
                                                             
PROCEDURE pc_valida_alienacao_fiduciaria (pr_cdcooper IN crapcop.cdcooper%type   -- Código da cooperativa
                                         ,pr_nrdconta IN crapass.nrdconta%type   -- Numero da conta do associado
                                         ,pr_nrctrpro IN PLS_INTEGER             -- Numero do contrato
                                         ,pr_des_reto OUT varchar2               -- Retorno Ok ou NOK do procedimento
                                         ,pr_dscritic OUT VARCHAR2               -- Retorno da descricao da critica do erro
                                         ,pr_tab_erro OUT gene0001.typ_tab_erro  -- Retorno da PlTable de erros
                                         );
                                                                                                                                                      
PROCEDURE pc_registrar_gravames(pr_cdcooper IN crapcop.cdcooper%TYPE -- Numero da cooperativa
                               ,pr_nrdconta IN crapcop.nrdconta%TYPE -- Numero da conta do associado
                               ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Numero do contrato                               
--                               ,pr_dtmvtolt IN DATE                  -- Data de movimento para baixa
                               ,pr_cddopcao IN VARCHAR2              -- V-VALIDAR / E-EFETIVAR
                               ,pr_flgresta IN PLS_INTEGER
                               ,pr_stprogra OUT PLS_INTEGER
                               ,pr_infimsol OUT PLS_INTEGER
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                               ,pr_dscritic OUT VARCHAR2);

PROCEDURE pc_valida_bens_alienados(pr_cdcooper IN crapcop.cdcooper%type   -- Código da cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%type   -- Numero da conta do associado
                                  ,pr_nrctrpro IN PLS_INTEGER             -- Numero do contrato
                                  ,pr_cdopcao  IN varchar2                -- 
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro  -- Retorno da PlTable de erros
                                  );
                                  
PROCEDURE  pc_valida_situacao_gravames ( pr_cdcooper IN crapbpr.cdcooper%TYPE       -- Cód. cooperativa
                                        ,pr_nrdconta IN crapbpr.nrdconta%TYPE       -- Nr. da conta
                                        ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE       -- Nr. contrato
                                        ,pr_idseqbem IN crapbpr.idseqbem%TYPE       -- Sequencial do bem
                                        ,pr_cdsitgrv OUT INTEGER                    -- Retorna situação do gravames 
                                        ,pr_dscrigrv OUT VARCHAR2                   -- Retorna critica de processamento do gravames
                                        ,pr_cdcritic OUT INTEGER                    -- Codigo de critica de sistema
                                        ,pr_dscritic OUT VARCHAR2                   -- Descrição da critica de sistema
                                        );      

  -- Função simples comparativa de codigos de retorno de gravames para definir se houve sucesso ou não
  FUNCTION fn_flag_sucesso_gravame(pr_dtretgrv crapgrv.dtretgrv%TYPE  -- Retorno GRavames
                                  ,pr_cdretlot crapgrv.cdretlot%TYPE  -- Retorno Lote
                                  ,pr_cdretgrv crapgrv.cdretgrv%TYPE  -- Retorno Gravame
                                  ,pr_cdretctr crapgrv.cdretctr%TYPE) -- Retorno Contrato
                                  RETURN VARCHAR2;                  
                                                                                                                                                      
END GRVM0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.GRVM0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: GRVM0001                        Antiga: b1wgen0171.p
  --  Autor   : Douglas Pagel
  --  Data    : Dezembro/2013                     Ultima Atualizacao: 29/05/2017
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
  ---------------------------------------------------------------------------------------------------------------
  
  -- Cursor para verificar se ha algum BEM alienável
  CURSOR cr_crapbpr (pr_cdcooper crapbpr.cdcooper%type
                    ,pr_nrdconta crapbpr.nrdconta%type
                    ,pr_nrctrpro crapbpr.nrctrpro%type) IS
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
  
  -- Valida se é alienação fiduciaria
  PROCEDURE pc_valida_alienacao_fiduciaria (pr_cdcooper IN crapcop.cdcooper%type   -- Código da cooperativa
                                           ,pr_nrdconta IN crapass.nrdconta%type   -- Numero da conta do associado
                                           ,pr_nrctrpro IN PLS_INTEGER             -- Numero do contrato
                                           ,pr_des_reto OUT varchar2               -- Retorno Ok ou NOK do procedimento
                                           ,pr_dscritic OUT VARCHAR2               -- Retorno da descricao da critica do erro
                                           ,pr_tab_erro OUT gene0001.typ_tab_erro  -- Retorno da PlTable de erros
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
      SELECT cdcooper
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%rowtype;

    --Cursor para validar associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%type) IS
      SELECT nrdconta
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;

    -- Cursor para verificar a proposta
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%type
                      ,pr_nrdconta crawepr.nrdconta%type
                      ,pr_nrctrpro crawepr.nrctremp%type) IS
      SELECT crawepr.cdcooper,
             crawepr.nrdconta,
             crawepr.nrctremp,
             crawepr.cdlcremp
        FROM crawepr
       WHERE crawepr.cdcooper = pr_cdcooper
         AND crawepr.nrdconta = pr_nrdconta
         AND crawepr.nrctremp = pr_nrctrpro;
    rw_crawepr cr_crawepr%rowtype;

    -- Cursor para validar a linha de credito da alienacao
    CURSOR cr_craplcr (pr_cdcooper craplcr.cdcooper%type
                      ,pr_cdlcremp craplcr.cdlcremp%type) IS
      SELECT cdcooper
        FROM craplcr
       WHERE craplcr.cdcooper = pr_cdcooper
         AND craplcr.cdlcremp = pr_cdlcremp
         AND craplcr.tpctrato = 2;
    rw_craplcr cr_craplcr%rowtype;

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

      OPEN cr_crapass (pr_cdcooper,
                       pr_nrdconta);
      FETCH cr_crapass
        INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        pr_des_reto := 'NOK';
        vr_cdcritic := 9;                 --009 - Associado nao cadastrado.
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

      -- Verifica a linha de credito
      OPEN cr_craplcr(rw_crawepr.cdcooper,
                      rw_crawepr.cdlcremp);
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
      OPEN cr_crapbpr(rw_crawepr.cdcooper,
                      rw_crawepr.nrdconta,
                      rw_crawepr.nrctremp);
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

      CLOSE cr_crawepr;
      -- Se não ocorreram criticas anteriores, retorna OK e volta para o programa chamador
      pr_des_reto := 'OK';
      RETURN;

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
    vr_tab_erro gene0001.typ_tab_erro;

    -- Código do programa
	  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';

  BEGIN
/*
    -- Irlan: Funcao bloqueada temporariamente, apenas COOPs 1, 4, 7
    IF  pr_cdcooper <> 1       --> 1 - VIACREDI
    AND pr_cdcooper <> 4       --> 4 - CONCREDI
    AND pr_cdcooper <> 7  THEN --> 7 - CREDCREA
        pr_des_reto := 'OK';
        RETURN;
    END IF;
*/

	  --Incluir nome do módulo logado - Chamado 660394
   GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_solicita_baixa_automatica');

    -- Valida se eh alienacao fiduciaria
    pc_valida_alienacao_fiduciaria( pr_cdcooper => pr_cdcooper   -- Código da cooperativa
                                   ,pr_nrdconta => pr_nrdconta   -- Numero da conta do associado
                                   ,pr_nrctrpro => pr_nrctrpro   -- Numero do contrato
                                   ,pr_des_reto => vr_des_reto   -- Retorno Ok ou NOK do procedimento
                                   ,pr_dscritic => vr_dscritic   -- Retorno da descricao da critica do erro
                                   ,pr_tab_erro => vr_tab_erro);  -- Retorno de PlTable com erros
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

      -- Se foi feito baixa manual
      IF rw_crapbpr.tpdbaixa = 'M' THEN
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
     Data    : Agosto/2013                     Ultima atualizacao:  22/09/2016

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
         full outer join crapepr epr on (epr.cdcooper = bpr.cdcooper and epr.nrdconta = bpr.nrdconta and epr.nrctremp = bpr.nrctrpro)
         WHERE bpr.cdcooper = DECODE(pr_cdcoptel,0,bpr.cdcooper,pr_cdcoptel)
           AND bpr.flgalien   = 1 -- Sim
           AND wpr.cdcooper   = bpr.cdcooper
           AND wpr.nrdconta   = bpr.nrdconta
           AND wpr.nrctremp   = bpr.nrctrpro
           AND wpr.insitapr IN(1,3) -- Aprovados
           AND cop.cdcooper   = bpr.cdcooper
           AND ass.cdcooper   = bpr.cdcooper
           AND ass.nrdconta   = bpr.nrdconta
           AND (  -- Bloco INCLUSAO
                     (pr_tparquiv IN ('INCLUSAO','TODAS')
                 AND  bpr.tpctrpro   = 90
                 AND  wpr.flgokgrv   = 1
                 AND  bpr.flgbaixa   = 0      -- APENAS NÃO BAIXADOS
                 AND  nvl(epr.inliquid,0) = 0 -- APENAS NÃO LIQUIDADO, CASO NULO TRATAR COMO "0 - NÃO LIQUIDADO"
                 AND  bpr.flginclu   = 1      -- INCLUSAO SOLICITADA
                 AND  bpr.cdsitgrv in (0,3)   -- NAO ENVIADO ou PROCES.COM ERRO
                 AND  bpr.tpinclus   = 'A')   -- AUTOMATICA

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

      -- Busca das informações dos avalistas
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

        -- Se o bem eh do próprio associado
        IF rw_bpr.nrcpfbem = rw_bpr.nrcpfcgc OR rw_bpr.nrcpfbem = 0 THEN
          -- Usamos o nome e cpf do associado
          vr_nmprimtl := rw_bpr.nmprimtl;
          vr_nrcpfbem := rw_bpr.nrcpfcgc;
        ELSE
          -- Buscaremos as informações do cadastro de avalistas
          OPEN cr_crapavt(pr_cdcooper => rw_bpr.cdcooper
                         ,pr_nrdconta => rw_bpr.nrdconta
                         ,pr_nrctremp => rw_bpr.nrctremp
                         ,pr_nrcpfcgc => rw_bpr.nrcpfbem);
          FETCH cr_crapavt
            INTO vr_nmprimtl
                ,vr_nrcpfbem;
          -- Se não encontrou
          IF cr_crapavt%NOTFOUND THEN
            -- Usamos o nome e cpf do associado
            vr_nmprimtl := rw_bpr.nmprimtl;
            vr_nrcpfbem := rw_bpr.nrcpfcgc;
          END IF;
          --
          CLOSE cr_crapavt;
        END IF;
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
        IF vr_tparquiv = 'BAIXA'AND rw_bpr.ufplnovo <> ' ' AND rw_bpr.nrplnovo <> ' ' AND rw_bpr.nrrenovo > 0 THEN
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
      
      pc_valida_alienacao_fiduciaria (pr_cdcooper => pr_cdcooper  -- Código da cooperativa
                                     ,pr_nrdconta => pr_nrdconta  -- Numero da conta do associado
                                     ,pr_nrctrpro => pr_nrctrpro  -- Numero do contrato
                                     ,pr_des_reto => pr_des_reto  -- Retorno Ok ou NOK do procedimento
                                     ,pr_dscritic => vr_dscritic  -- Retorno da descricao da critica do erro
                                     ,pr_tab_erro => pr_tab_erro);-- Retorno da PlTable de erros
          
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

  PROCEDURE pc_busca_valida_contrato(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --Data de movimento
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                    ,pr_cddopcao IN VARCHAR2              --Opção
                                    ,pr_cdagesel IN crapage.cdagenci%TYPE --Agencia 
                                    ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE --Número do contrato
                                    ,pr_flgfirst IN INTEGER               --Validar
                                    ,pr_nrregist IN INTEGER               -- Número de registros
                                    ,pr_nriniseq IN INTEGER               -- Número sequencial 
                                    ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_valida_contrato                            antiga: b1wgen0171.gravames_busca_valida_contrato
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 19/10/2018
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca contratos
    
    --   Alteracoes: 29/05/2017 - Padronização das mensagens para a tabela tbgen_prglog,
    --                          - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
    --                          - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
    --                          - Incluir nome do módulo logado em variável
    --                            (Ana - Envolti) - SD: 660356 e 660394
    --
    --               19/10/2018 - P442 - Troca de checagem fixa por funcão para garantir se bem é alienável (Marcos-Envolti)
    -------------------------------------------------------------------------------------------------------------*/                               
  
    CURSOR cr_propostas(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
    SELECT crawepr.nrctremp
      FROM crawepr
          ,craplcr
          ,crapbpr
     WHERE crawepr.cdcooper = pr_cdcooper
       AND crawepr.nrdconta = pr_nrdconta
       AND craplcr.cdcooper = crawepr.cdcooper
       AND craplcr.cdlcremp = crawepr.cdlcremp
       AND craplcr.tpctrato = 2
       AND crapbpr.cdcooper = crawepr.cdcooper
       AND crapbpr.nrdconta = crawepr.nrdconta
       AND crapbpr.tpctrpro = 90
       AND crapbpr.nrctrpro = crawepr.nrctremp
       AND crapbpr.flgalien = 1
       AND grvm0001.fn_valida_categoria_alienavel(crapbpr.dscatbem) = 'S'
     GROUP BY crawepr.nrctremp;                     
                       
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
    
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Variaveis Locais   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';      
    vr_nrregist  INTEGER; 
    vr_qtregist  INTEGER := 0; 
    vr_contador  INTEGER := 0; 
    vr_qtctrpr   INTEGER := 0; 
        
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';
    
  BEGIN
    vr_nrregist := pr_nrregist;
    
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_busca_valida_contrato');
    
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
       
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><Propostas>');     
                           
    --Busca as propostas
    FOR rw_propostas IN cr_propostas(pr_cdcooper => vr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta) LOOP
    
      --Incrementar contador
      vr_qtregist:= nvl(vr_qtregist,0) + 1;
              
      -- controles da paginacao 
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

        --Proximo
        CONTINUE;  
                  
      END IF; 
              
      IF vr_nrregist >= 1 THEN   
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<proposta>'||                                                                                                        
                                                       '  <nrctremp>' || rw_propostas.nrctremp ||'</nrctremp>'||
                                                     '</proposta>');
        
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;
           
      END IF;         
          
      vr_contador := vr_contador + 1; 
    
    END LOOP;

    IF vr_qtctrpr = 0 THEN
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Associado sem Emprestimos tipo Alienacao Fiduciaria!';
      
      RAISE vr_exc_erro;
          
    END IF;
        
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</Propostas></Root>'
                           ,pr_fecha_xml      => TRUE);
     
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);
       
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
               
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Root'             --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
                             
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite); 
    
   
    IF pr_nrctrpro <> 0 THEN
      
      pc_valida_alienacao_fiduciaria (pr_cdcooper => vr_cdcooper  -- Código da cooperativa
                                     ,pr_nrdconta => pr_nrdconta  -- Numero da conta do associado
                                     ,pr_nrctrpro => pr_nrctrpro  -- Numero do contrato
                                     ,pr_des_reto => vr_des_reto  -- Retorno Ok ou NOK do procedimento
                                     ,pr_dscritic => vr_dscritic  -- Retorno da descricao da critica do erro
                                     ,pr_tab_erro => vr_tab_erro  -- Retorno da PlTable de erros
                                     );
      --Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possui erro
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSIF trim(vr_dscritic) IS NULL THEN 
          vr_cdcritic:= 0;
          vr_dscritic:= 'Nao foi possivel validar alienacao feduciaria.';
        END IF;
        
        --Levantar Excecao  
        RAISE vr_exc_erro;
        
        --Incluir nome do módulo logado - Chamado 660394
        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_busca_valida_contrato');

      END IF; 
      
    ELSE
      
      IF pr_flgfirst = 0 THEN
        
        vr_cdcritic := 0;
        vr_dscritic := 'Numero da Proposta de Emprestimo deve ser informada!';
        
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ERRO: ' || vr_cdcritic || ' - ' ||'"' || vr_dscritic || '"' ||
                                                    ',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Dtmvtolt:'||pr_dtmvtolt||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Nrdconta:'||pr_nrdconta||
                                                    ',Cddopcao:'||pr_cddopcao||',Cdagesel:'||pr_cdagesel);
        RAISE vr_exc_erro;
      
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

        --Inclusão dos parâmetros apenas na exception, para não mostrar na tela - Chamado 660356
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- Mensagem
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ALERTA: ' ||pr_dscritic ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Dtmvtolt:'||pr_dtmvtolt||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Nrdconta:'||pr_nrdconta||
                                                    ',Cddopcao:'||pr_cddopcao||',Cdagesel:'||pr_cdagesel);

    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_valida_contrato --> '|| SQLERRM;
        
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
                                                    ',Cdcooper:'||vr_cdcooper||',Dtmvtolt:'||pr_dtmvtolt||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Nrdconta:'||pr_nrdconta||
                                                    ',Cddopcao:'||pr_cddopcao||',Cdagesel:'||pr_cdagesel);

      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
   
  END pc_busca_valida_contrato;  

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
    
    vr_tab_erro gene0001.typ_tab_erro;
        
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';
  
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
                                   ,pr_dscritic => vr_dscritic  -- Retorno da descricao da critica do erro
                                   ,pr_tab_erro => vr_tab_erro  -- Retorno da PlTable de erros
                                   );
    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
        
      --Se possui erro
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSIF trim(vr_dscritic) IS NULL THEN 
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel validar alienacao feduciaria.';
      END IF;
        
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
                                  pr_nmdcampo => 'dschassi', 
                                  pr_dsdadant => TO_CHAR(rw_crapbpr.dschassi), 
                                  pr_dsdadatu => TO_CHAR(pr_dschassi));
      
      END IF;
      
      IF (TRIM(rw_crapbpr.ufdplaca) <> TRIM(pr_ufdplaca) AND
          TRIM(rw_crapbpr.ufplnovo) IS NULL)             OR
         (TRIM(rw_crapbpr.ufplnovo) <> TRIM(pr_ufdplaca) AND
          TRIM(rw_crapbpr.ufplnovo) IS NOT NULL)         THEN
      
        IF trim(rw_crapbpr.ufplnovo) IS NULL THEN
          
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                    pr_nmdcampo => 'ufdplaca', 
                                    pr_dsdadant => TO_CHAR(rw_crapbpr.ufdplaca), 
                                    pr_dsdadatu => TO_CHAR(pr_ufdplaca));
                                  
        ELSE
          
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                    pr_nmdcampo => 'ufdplaca', 
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
                                    pr_nmdcampo => 'nrdplaca', 
                                    pr_dsdadant => TO_CHAR(rw_crapbpr.nrdplaca), 
                                    pr_dsdadatu => TO_CHAR(pr_nrdplaca));
                                  
        ELSE
          
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                    pr_nmdcampo => 'nrdplaca', 
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
                                    pr_nmdcampo => 'nrrenava', 
                                    pr_dsdadant => TO_CHAR(rw_crapbpr.nrrenava), 
                                    pr_dsdadatu => TO_CHAR(pr_nrrenava));
                                  
        ELSE
          
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                    pr_nmdcampo => 'nrrenava', 
                                    pr_dsdadant => TO_CHAR(rw_crapbpr.nrrenovo), 
                                    pr_dsdadatu => TO_CHAR(pr_nrrenava));
                                  
        END IF;
        
      
      END IF;
      
      IF rw_crapbpr.nranobem <> pr_nranobem THEN
      
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nranobem', 
                                  pr_dsdadant => TO_CHAR(rw_crapbpr.nranobem), 
                                  pr_dsdadatu => TO_CHAR(pr_nranobem));  
      
      END IF;
      
      
      IF rw_crapbpr.nrmodbem <> pr_nrmodbem THEN
        
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrmodbem', 
                                  pr_dsdadant => TO_CHAR(rw_crapbpr.nrrenovo), 
                                  pr_dsdadatu => TO_CHAR(rw_crapbpr.nrmodbem));
      
      END IF;
      
      IF pr_cdsitgrv IS NOT NULL THEN
      
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'situacao', 
                                  pr_dsdadant => CASE rw_crapbpr.cdsitgrv
                                                   WHEN 0 THEN '0 – Nao enviado'
                                                   WHEN 1 THEN '1 – Em processamento'
                                                   WHEN 2 THEN '2 – Alienacao'
                                                   WHEN 3 THEN '3 – Processado com Critica'
                                                   WHEN 4 THEN '4 – Baixado'
                                                   WHEN 5 THEN '5 – Cancelado'
                                                 END, 
                                  pr_dsdadatu => CASE pr_cdsitgrv
                                                   WHEN 0 THEN '0 – Nao enviado'
                                                   WHEN 1 THEN '1 – Em processamento'
                                                   WHEN 2 THEN '2 – Alienacao'
                                                   WHEN 3 THEN '3 – Processado com Critica'
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

  PROCEDURE pc_gravames_cancelar(pr_nrdconta in crapass.nrdconta%type, --Número da conta
                                 pr_cddopcao in varchar2,              --Opção
                                 pr_nrctrpro in crawepr.nrctremp%type, --Número do contrato 
                                 pr_idseqbem in crapbpr.idseqbem%type, --Identificador do bem
                                 pr_tpctrpro in crapbpr.tpctrpro%type, --Tipo do contrato
                                 pr_tpcancel in integer,               --Tipo de cancelamento
                                 pr_cdopeapr in varchar2,              --Operador da aprovação
                                 pr_dsjuscnc in crapbpr.dsjuscnc%type,  -- Justificativa
                                 pr_xmllog   in varchar2,              --XML com informações de LOG
                                 pr_cdcritic out pls_integer,          --Código da crítica
                                 pr_dscritic out varchar2,             --Descrição da crítica
                                 pr_retxml   in out nocopy xmltype,    --Arquivo de retorno do XML
                                 pr_nmdcampo out varchar2,             --Nome do Campo
                                 pr_des_erro out varchar2) IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravames_cancelar                            antiga: b1wgen0171.gravames_cancelar
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 29/05/2017
    
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
                27/09/2018 - Inclusão de parâmetro para a justificativa para o cancelamento (Daniel - Envolti)
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
    
    vr_tab_erro gene0001.typ_tab_erro;
        
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';

    -- Operador do cancelamento
    cursor cr_crapope is
      select nmoperad
        from crapope
       where cdcooper = vr_cdcooper
         and cdoperad = pr_cdopeapr;

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
                                   ,pr_dscritic => vr_dscritic  -- Retorno da descricao da critica do erro
                                   ,pr_tab_erro => vr_tab_erro  -- Retorno da PlTable de erros
                                   );

    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
        
      --Se possui erro
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSIF trim(vr_dscritic) IS NULL THEN 
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel validar alienacao feduciaria.';
      END IF;
        
      --Levantar Excecao  
      RAISE vr_exc_erro;
        
    END IF; 
      
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_cancelar');

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
    
    IF rw_crapbpr.cdsitgrv = 1 THEN
           
      vr_cdcritic:= 0;
      vr_dscritic:= 'Cancelamento nao efetuado! Em processamento CETIP.';
          
      --Levantar Excecao  
      RAISE vr_exc_erro;        
           
    END IF;  
      
    IF (rw_crapdat.dtmvtolt - rw_crapbpr.dtatugrv) > 30 THEN
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Prazo para cancelamento ultrapassado.';
          
      --Levantar Excecao  
      RAISE vr_exc_erro; 
    
    END IF;
    
    IF pr_tpcancel NOT IN (1,2) THEN
          
      vr_cdcritic:= 0;
      vr_dscritic:= 'Tipo de cancelamento invalido.';
          
      --Levantar Excecao  
      RAISE vr_exc_erro;       
    
    END IF;
    
    BEGIN
        
      UPDATE crapbpr
         SET crapbpr.tpcancel = 'M', --decode(pr_tpcancel,1,'A',2,'M'),
             crapbpr.flcancel = 1,
             crapbpr.dtcancel = rw_crapdat.dtmvtolt,
             crapbpr.cdsitgrv = 5, --decode(pr_tpcancel,2,5,crapbpr.cdsitgrv),
             crapbpr.dsjuscnc = pr_dsjuscnc
      WHERE ROWID = rw_crapbpr.rowid_bpr;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel alterar o bem.';
          
        --Levantar Excecao  
        RAISE vr_exc_erro; 
    END;
    -- 
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
                              pr_nmdcampo => 'dtcancel', 
                              pr_dsdadant => TO_CHAR(rw_crapbpr.dtcancel), 
                              pr_dsdadatu => TO_CHAR(rw_crapdat.dtmvtolt)); 
                                
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'cdsitgrv', 
                              pr_dsdadant => TO_CHAR(rw_crapbpr.cdsitgrv), 
                              pr_dsdadatu => CASE pr_tpcancel
                                                 WHEN 2 THEN '5'
                                                 ELSE TO_CHAR(rw_crapbpr.cdsitgrv)
                                             END);                                    

    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'Justificativa', 
                              pr_dsdadant => null, 
                              pr_dsdadatu => pr_dsjuscnc); 
                                
    if pr_cdopeapr is not null then
      -- Busca nome do operador
      open cr_crapope;
        fetch cr_crapope into vr_nmopeapr;
        if cr_crapope%found then
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'nmopeapr',
                                    pr_dsdadant => null,
                                    pr_dsdadatu => pr_cdopeapr||' - '||vr_nmopeapr);
        else
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'nmopeapr',
                                    pr_dsdadant => null,
                                    pr_dsdadatu => pr_cdopeapr);
        end if;
      close cr_crapope;
    end if;
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
    
    vr_tab_erro gene0001.typ_tab_erro;
        
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';

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
                                   ,pr_dscritic => vr_dscritic  -- Retorno da descricao da critica do erro
                                   ,pr_tab_erro => vr_tab_erro  -- Retorno da PlTable de erros
                                   );

    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
        
      --Se possui erro
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSIF trim(vr_dscritic) IS NULL THEN 
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel validar alienacao feduciaria.';
      END IF;
        
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

  PROCEDURE pc_gravames_baixa_manual(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                    ,pr_cddopcao IN VARCHAR2              --Opção
                                    ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                    ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE --Tipo do contrato
                                    ,pr_idseqbem IN crapbpr.idseqbem%TYPE --Identificador do bem
                                    ,pr_nrgravam IN crapbpr.nrgravam%TYPE --Número do gravam
                                    ,pr_dsjstbxa IN crapbpr.dsjstbxa%TYPE -- Justificativa da baixa
                                    ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*-------------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravames_baixa_manual                            antiga: b1wgen0171.gravames_baixa_manual
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
    -----------------------------------------------------------------------------------------------------------------*/                               
  
    -- Cursor para encontrar o bem
    CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE                     
                     ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE
                     ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE                     
                     ,pr_idseqbem IN crapbpr.idseqbem%TYPE) IS
    SELECT crapbpr.flblqjud
          ,crapbpr.cdsitgrv
          ,crapbpr.dsjstbxa
          ,crapbpr.dtdbaixa
          ,ROWID rowid_bpr                 
      FROM crapbpr
     WHERE crapbpr.cdcooper = pr_cdcooper
       AND crapbpr.nrdconta = pr_nrdconta
       AND crapbpr.tpctrpro = pr_tpctrpro
       AND crapbpr.nrctrpro = pr_nrctrpro
       AND crapbpr.idseqbem = pr_idseqbem
       AND crapbpr.flgalien = 1;
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
    
    vr_tab_erro gene0001.typ_tab_erro;
        
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
  BEGIN
    vr_dstransa := 'Baixa Manual do bem no gravames';

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
    
    pc_valida_alienacao_fiduciaria (pr_cdcooper => vr_cdcooper  -- Código da cooperativa
                                   ,pr_nrdconta => pr_nrdconta  -- Numero da conta do associado
                                   ,pr_nrctrpro => pr_nrctrpro  -- Numero do contrato
                                   ,pr_des_reto => vr_des_reto  -- Retorno Ok ou NOK do procedimento
                                   ,pr_dscritic => vr_dscritic  -- Retorno da descricao da critica do erro
                                   ,pr_tab_erro => vr_tab_erro  -- Retorno da PlTable de erros
                                   );

    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
        
      --Se possui erro
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSIF trim(vr_dscritic) IS NULL THEN 
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel validar alienacao fiduciaria.';
      END IF;
        
      --Levantar Excecao  
      RAISE vr_exc_erro;
        
    END IF; 
    
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_baixa_automatica');
    
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
      
    IF rw_crapbpr.cdsitgrv <> 0 AND
       rw_crapbpr.cdsitgrv <> 2 AND
       rw_crapbpr.cdsitgrv <> 3 THEN
         
      vr_cdcritic:= 0;
      vr_dscritic:= 'Situacao do Bem invalida! Gravame nao OK!';
      
      --Levantar Excecao  
      RAISE vr_exc_erro;   
    END IF;
      
    BEGIN
      UPDATE crapbpr
         SET crapbpr.cdsitgrv = 4 -- Baixado
            ,crapbpr.flgbaixa = 1
            ,crapbpr.flginclu = 0
            ,crapbpr.dtdbaixa = rw_crapdat.dtmvtolt
            ,crapbpr.dsjstbxa = pr_dsjstbxa
            ,crapbpr.tpdbaixa = 'M' --Manual              
      WHERE ROWID = rw_crapbpr.rowid_bpr;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel alterar o bem.';
        --Levantar Excecao  
        RAISE vr_exc_erro; 
    END;
    -- 
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
                              pr_nmdcampo => 'dtdbaixa', 
                              pr_dsdadant => to_char(rw_crapbpr.dtdbaixa), 
                              pr_dsdadatu => to_char(rw_crapdat.dtmvtolt)); 
             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'pr_dsjstbxa', 
                              pr_dsdadant => rw_crapbpr.dsjstbxa, 
                              pr_dsdadatu => pr_dsjstbxa); 

    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'cdsitgrv', 
                              pr_dsdadant => to_char(rw_crapbpr.cdsitgrv), 
                              pr_dsdadatu => '4');                               
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
                       
        
  END pc_gravames_baixa_manual;  

  
  PROCEDURE pc_gravames_inclusao_manual(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                       ,pr_cddopcao IN VARCHAR2              --Opção
                                       ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                       ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE --Tipo do contrato
                                       ,pr_idseqbem IN crapbpr.idseqbem%TYPE --Identificador do bem
                                       ,pr_nrgravam IN crapbpr.nrgravam%TYPE --Número do gravam
                                       ,pr_dtmvttel IN VARCHAR2              --Data do registro
                                       ,pr_dsjustif IN crapbpr.dsjstbxa%TYPE --Justificativa da inclusão
                                       ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravames_inclusao_manual                            antiga: b1wgen0171.gravames_inclusao_manual
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
                             
                10/10/2018 - P442 - Novo parâmetro de tipo da inclusão (Marcos-Envolti)             
                             
    -------------------------------------------------------------------------------------------------------------*/                               
  
    -- Cursor para encontrar o bem
    CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE                     
                     ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE
                     ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE                     
                     ,pr_idseqbem IN crapbpr.idseqbem%TYPE) IS
    SELECT crapbpr.flblqjud
          ,crapbpr.tpinclus
          ,crapbpr.cdsitgrv
          ,crapbpr.dtdinclu
          ,crapbpr.dsjstinc
          ,crapbpr.nrgravam
          ,crapbpr.dtatugrv
          ,ROWID rowid_bpr                 
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
    
    vr_tab_erro gene0001.typ_tab_erro;
        
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
  BEGIN
    vr_dstransa := 'Inclusão Manual do bem no gravames';

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
    
    IF TRIM(pr_dsjustif) IS NULL THEN
      
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
                                   ,pr_dscritic => vr_dscritic  -- Retorno da descricao da critica do erro
                                   ,pr_tab_erro => vr_tab_erro  -- Retorno da PlTable de erros
                                   );
    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
        
      --Se possui erro
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSIF trim(vr_dscritic) IS NULL THEN 
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel validar alienacao feduciaria.';
      END IF;
        
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
    
    IF rw_crapbpr.tpinclus = 'A' THEN
    
      vr_dsmensag := ' via arquivo.';  
    
    ELSE
      
      vr_dsmensag := ' de forma manual.';
    
    END IF; 
    
    IF rw_crapbpr.cdsitgrv <> 0 AND rw_crapbpr.cdsitgrv <> 3 THEN  
      
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
    
    BEGIN
        
      UPDATE crapbpr
         SET crapbpr.flginclu = 1
            ,crapbpr.dtdinclu = rw_crapdat.dtmvtolt
            ,crapbpr.dsjstinc = pr_dsjustif
            ,crapbpr.tpinclus = 'M'
            ,crapbpr.cdsitgrv = 2 --Alienacao OK
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
    
    BEGIN
        
      UPDATE crawepr
         SET crawepr.flgokgrv = 1       
      WHERE ROWID = rw_crawepr.rowid_epr;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel alterar a proposta.';
          
        --Levantar Excecao  
        RAISE vr_exc_erro; 
    END;
    -- 
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
                              pr_nmdcampo => 'nrgravam', 
                              pr_dsdadant => to_char(rw_crapbpr.nrgravam), 
                              pr_dsdadatu => to_char(pr_nrgravam));
             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'Data Atualização', 
                              pr_dsdadant => to_char(rw_crapbpr.dtatugrv), 
                              pr_dsdadatu => to_char(vr_dtmvttel));
                              
               
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
        
  END pc_gravames_inclusao_manual;  

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
     Data    : Maio/2016                     Ultima atualizacao: 29/05/2017

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
         and bpr.cdsitgrv <> 0
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
  


PROCEDURE pc_registrar_gravames(pr_cdcooper IN crapcop.cdcooper%TYPE -- Numero da cooperativa
                               ,pr_nrdconta IN crapcop.nrdconta%TYPE -- Numero da conta do associado
                               ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Numero do contrato                               
                        --       ,pr_dtmvtolt IN DATE                  -- Data de movimento para baixa
                               ,pr_cddopcao IN VARCHAR2              -- V-VALIDAR / E-EFETIVAR
                               ,pr_flgresta IN PLS_INTEGER
                               ,pr_stprogra OUT PLS_INTEGER
                               ,pr_infimsol OUT PLS_INTEGER
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                               ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
  /* .............................................................................

   Procedure: pc_registrar_gravames             Antigo: fontes/b1wgen0171.p
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
      -- Erro sem parar a cadeia
      vr_exc_fimprg exception;

      -------------- Cursores específicos ----------------

      -- Busca sobre data de inclusão do contrato --
      CURSOR cr_crawepr(pr_cdcooper IN crapcop.cdcooper%TYPE -- Numero da cooperativa
                       ,pr_nrdconta IN crapcop.nrdconta%TYPE -- Numero da conta do associado
                       ,pr_nrctrpro IN crapbpr.nrctrpro%type) IS -- Numero do contrato
        SELECT crawepr.*, crawepr.rowid
        FROM crawepr
        WHERE crawepr.cdcooper  = pr_cdcooper
          AND crawepr.nrdconta  = pr_nrdconta
          AND crawepr.nrctremp  = pr_nrctrpro;
      rw_crawepr cr_crawepr%ROWTYPE;

      -------------- Variáveis e Tipos -------------------

      vr_cdcritic crapcri.cdcritic%TYPE; --> Código da crítica
      vr_dscritic     VARCHAR2(2000);    --> Descrição da crítica
      
      -- Variaveis locais para retorno de erro
      vr_des_reto varchar2(4000);
      vr_tab_erro gene0001.typ_tab_erro;

      -- Variáveis de trabalho
      vr_cdcooper crawepr.cdcooper%TYPE;
      vr_nrdconta crawepr.nrdconta%TYPE;
      vr_nrctremp crawepr.nrctremp%TYPE;
      vr_rowid    rowid;

    BEGIN

      -- Código do programa
      vr_cdprogra := 'GRVM0001';
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pr_registrar_gravames'
                                ,pr_action => null);

      /** Validar Data de Inclusao do Contrato **/
      open cr_crawepr(pr_cdcooper,pr_nrdconta,pr_nrctrpro) ;
      fetch cr_crawepr into rw_crawepr;
      if cr_crawepr%NOTFOUND then
        CLOSE cr_crawepr;
        -- Montar mensagem de crítica
        vr_cdcritic := 356;
        RAISE vr_exc_saida;
      else
        if rw_crawepr.cdcooper = 1             and rw_crawepr.dtmvtolt < to_date('18112014','ddmmyyyy') or
           rw_crawepr.cdcooper = 4             and rw_crawepr.dtmvtolt < to_date('23072014','ddmmyyyy') or
           rw_crawepr.cdcooper = 7             and rw_crawepr.dtmvtolt < to_date('06102014','ddmmyyyy') or
           (rw_crawepr.cdcooper not in (1,4,7) and rw_crawepr.dtmvtolt < to_date('26022015','ddmmyyyy')) then
           vr_cdcritic := 0;
           vr_dscritic := ' Operacao bloqueada![Data Contrato] ';
           RAISE vr_exc_saida;
        end if;
        if nvl(rw_crawepr.flgokgrv,0) = 1 then
           vr_cdcritic := 0;
           vr_dscritic := ' Proposta ja OK para envio ao GRAVAMES! ';
           RAISE vr_exc_saida;
        end if;
        
        -- salva variaveis para usar no LOOP final
        vr_cdcooper := rw_crawepr.cdcooper;
        vr_nrdconta := rw_crawepr.nrdconta;
        vr_nrctremp := rw_crawepr.nrctremp;
        vr_rowid    := rw_crawepr.rowid;
      end if;
        
    -- Valida se eh alienacao fiduciaria
    pc_valida_alienacao_fiduciaria( pr_cdcooper => pr_cdcooper   -- Código da cooperativa
                                   ,pr_nrdconta => pr_nrdconta   -- Numero da conta do associado
                                   ,pr_nrctrpro => pr_nrctrpro   -- Numero do contrato
                                   ,pr_des_reto => vr_des_reto   -- Retorno Ok ou NOK do procedimento
                                   ,pr_dscritic => vr_dscritic   -- Retorno da descricao da critica do erro
                                   ,pr_tab_erro => vr_tab_erro);  -- Retorno de PlTable com erros
    /** OBS: Sempre retornara OK pois a chamada da solicita_baixa_automatica
             nos CRPS171,CRPS078,CRPS120_1,B1WGEN0136, nesses casos nao pode
             impedir de seguir para demais contratos. **/

    IF vr_des_reto <> 'OK' THEN
       vr_cdcritic := 0;
       -- Não é necessário atribuir a variável vr_dscritic porque já retorna da procedure 
       -- chamada imediatamente acima
       RAISE vr_exc_saida;
    END IF;

    if rw_crapbpr.cdsitgrv <> 0 then
       vr_cdcritic := 0;
       vr_dscritic := ' Situacao do Gravame invalida! ';
       RAISE vr_exc_saida;
    end if;
      
    -- No fonte Progress tinha neste ponto o comando: IF  crawepr.flgokgrv = TRUE THEN DO:
    -- Coloquei este if na leitura que já existia da crawepr, com a mesma consistencia.
    
    begin
       update crawepr set flgokgrv = 1 where rowid = vr_rowid;
    exception
       when others then
          vr_cdcritic := 0;
          vr_dscritic := substr(' Erro atualização crawepr:'||SQLERRM,1,2000);
          RAISE vr_exc_saida;
    end;

    begin
       update crapbpr a
       set a.flginclu = 1,
           a.cdsitgrv = 0,
           a.tpinclus = 'A'
       where a.cdcooper = vr_cdcooper
         and a.nrdconta = vr_nrdconta
         and a.tpctrpro = 90
         and a.nrctrpro = vr_nrctremp
         and a.flgalien = 1
         and grvm0001.fn_valida_categoria_alienavel(a.dscatbem) = 'S';
    exception
       when others then
          vr_cdcritic := 0;
          vr_dscritic := substr(' Erro atualização crapbpr:'||SQLERRM,1,2000);
          RAISE vr_exc_saida;
    end;

   EXCEPTION

    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Se foi gerada critica para envio ao log
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
      END IF;
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit pois gravaremos o que foi processo até então
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
   END;

END pc_registrar_gravames;
  
PROCEDURE pc_valida_bens_alienados(pr_cdcooper IN crapcop.cdcooper%type   -- Código da cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%type   -- Numero da conta do associado
                                  ,pr_nrctrpro IN PLS_INTEGER             -- Numero do contrato
                                  ,pr_cdopcao  IN varchar2                -- 
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro  -- Retorno da PlTable de erros
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
                  
    ............................................................................. */
    
         
  -- Busca sobre data de inclusão do contrato --
  CURSOR cr_crawepr(pr_cdcooper IN crapcop.cdcooper%TYPE -- Numero da cooperativa
                   ,pr_nrdconta IN crapcop.nrdconta%TYPE -- Numero da conta do associado
                   ,pr_nrctrpro IN crapbpr.nrctrpro%type) IS -- Numero do contrato
    SELECT crawepr.*
          ,crawepr.rowid
      FROM crawepr
     WHERE crawepr.cdcooper = pr_cdcooper
       AND crawepr.nrdconta = pr_nrdconta
       AND crawepr.nrctremp = pr_nrctrpro;
  rw_crawepr cr_crawepr%ROWTYPE;
  
  CURSOR cr_crapbpr (pr_cdcooper IN crapcop.cdcooper%TYPE -- Numero da cooperativa
                    ,pr_nrdconta IN crapcop.nrdconta%TYPE -- Numero da conta do associado
                    ,pr_nrctrpro IN crapbpr.nrctrpro%type) IS -- Numero do contrato
    SELECT a.cdsitgrv
      FROM crapbpr a
     WHERE a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta
       AND a.tpctrpro = 90
       AND a.nrctrpro = pr_nrctrpro
       AND a.flgalien = 1
       AND ((a.dscatbem LIKE '%AUTOMOVEL%') OR 
            (a.dscatbem LIKE '%MOTO%') OR
            (a.dscatbem LIKE '%CAMIMNHAO%'));
              
  -- Código do programa
  vr_cdprogra crapprg.cdprogra%TYPE;
  -- Erro para parar a cadeia
  vr_exc_saida exception;
  -- Erro sem parar a cadeia
  vr_exc_fimprg exception;

  vr_des_reto varchar2(2000);

begin

  -- Código do programa
  vr_cdprogra := 'GRAVAM';
  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'pc_valida_bens_alienados'
                            ,pr_action => 'pc_valida_bens_alienados');

  open cr_crawepr(pr_cdcooper,pr_nrdconta,pr_nrctrpro) ;
  fetch cr_crawepr into rw_crawepr;
  if cr_crawepr%NOTFOUND then
    -- Montar mensagem de crítica
    pr_cdcritic := 356;
    pr_dscritic := null;
    CLOSE cr_crawepr;
    RAISE vr_exc_saida;
  ELSIF rw_crawepr.cdcooper = 1             and rw_crawepr.dtmvtolt < to_date('18112014','ddmmyyyy') or
        rw_crawepr.cdcooper = 4             and rw_crawepr.dtmvtolt < to_date('23072014','ddmmyyyy') or
        rw_crawepr.cdcooper = 7             and rw_crawepr.dtmvtolt < to_date('06102014','ddmmyyyy') or
       (rw_crawepr.cdcooper not in (1,4,7) and rw_crawepr.dtmvtolt < to_date('26022015','ddmmyyyy')) then
    CLOSE cr_crawepr;
    raise vr_exc_fimprg; -- Sai do programa
  end if;
  CLOSE cr_crawepr;

  pc_valida_alienacao_fiduciaria(pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_nrctrpro => pr_nrctrpro,
                                 pr_des_reto => vr_des_reto,
                                 pr_dscritic => pr_dscritic,
                                 pr_tab_erro => pr_tab_erro);
  /** OBS: Sempre retornara OK pois a chamada da valida_bens_alienados
         vem da "EFETIVAR" (LANCTRI e BO00084), nesses casos nao pode
         impedir de seguir para demais contratos. **/
  --Se ocorreu erro
  IF vr_des_reto <> 'OK' THEN
    raise vr_exc_fimprg; -- Sai do programa        
  END IF;
  
  if (rw_crawepr.flgokgrv = 0) then
    pr_cdcritic := 0;
    pr_dscritic := 'Opcao Registro de Gravames, na tela ATENDA nao efetuada! Verifique.';
    RAISE vr_exc_saida;
  end if;
  
  pr_cdcritic := null;
  pr_dscritic := null;
  for rw_crapbpr in cr_crapbpr ( pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctrpro => pr_nrctrpro) LOOP   
     
    pr_dscritic := NULL;
    IF rw_crapbpr.cdsitgrv = 2 THEN --> 2 - ALIENADO
     continue;
    ELSIF rw_crapbpr.cdsitgrv = 0 then
      pr_dscritic := 'Arquivo Gravame nao enviado. Verifique';
    elsif rw_crapbpr.cdsitgrv = 1 then
      pr_dscritic := 'Falta retorno arquivo Gravames. Verifique.';
    elsif rw_crapbpr.cdsitgrv = 3 then
      pr_dscritic := 'Arquivo Gravames com problemas de processamento. Verifique.';
    elsif rw_crapbpr.cdsitgrv = 4 then
      pr_dscritic := 'Bem baixado.';
    elsif rw_crapbpr.cdsitgrv = 5 then
      pr_dscritic := 'Bem cancelado.';
    end if;
     
    if pr_dscritic is not null then
      -- somente precisa do RAISE porque a descrição já foi preenchida no cursor
      -- imediatamente anterior e o código foi inicializado com ZERO
      RAISE vr_exc_saida;
    end if;
     
  END LOOP;
  

exception
  WHEN vr_exc_saida THEN
    gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                         ,pr_cdagenci => 0
                         ,pr_nrdcaixa => 0
                         ,pr_nrsequen => 0
                         ,pr_cdcritic => pr_cdcritic
                         ,pr_dscritic => pr_dscritic
                         ,pr_tab_erro => pr_tab_erro);

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
  when vr_exc_fimprg then
    pr_cdcritic := null;
    pr_dscritic := null;
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Erro ao validar bens alienados';

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
         AND ((a.dscatbem LIKE '%AUTOMOVEL%') OR 
              (a.dscatbem LIKE '%MOTO%') OR
              (a.dscatbem LIKE '%CAMIMNHAO%'));
    
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

    -- Função simples comparativa de codigos de retorno de gravames para definir se houve sucesso ou não
  FUNCTION fn_flag_sucesso_gravame(pr_dtretgrv crapgrv.dtretgrv%TYPE  -- Retorno GRavames
                                  ,pr_cdretlot crapgrv.cdretlot%TYPE  -- Retorno Lote
                                  ,pr_cdretgrv crapgrv.cdretgrv%TYPE  -- Retorno Gravame
                                  ,pr_cdretctr crapgrv.cdretctr%TYPE) -- Retorno Contrato
                                  RETURN VARCHAR2 IS
  BEGIN
    -- Se não houve retorno ainda 
    IF pr_dtretgrv IS NULL THEN
      -- Volta vazio
      RETURN ' ';
    ELSE
      -- Validação de sucesso nos lotes, contrato e grv
      IF pr_cdretlot = 0 
      AND pr_cdretgrv IN(0,30)
      AND pr_cdretctr IN(0,90) THEN
        RETURN 'S';
      ELSE
        RETURN 'N';  
      END IF;  
    END IF;  
  END;                                

  
END GRVM0001;
/
