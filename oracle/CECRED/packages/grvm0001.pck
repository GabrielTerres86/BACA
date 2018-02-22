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

           ,vlemprst crawepr.vlemprst%TYPE  /*  Valor principal da oper.           */
           ,vlpreemp crawepr.vlpreemp%TYPE  /*  Valor da parcela                   */
           ,dtdpagto crawepr.dtdpagto%TYPE  /*  Data de vencto prim. parc.   */
           ,dtvencto DATE                   /*  Data de vencto ult. parc.           */
           ,nmcidade crapage.nmcidade%TYPE  /*  Cidade da liberaçao da oper. */
           ,cdufdcop crapage.cdufdcop%TYPE  /*  UF da liberaçao da oper           */

           ,dsendcop crapcop.dsendcop%TYPE  /* Nome do logradouro           */
           ,nrendcop crapcop.nrendcop%TYPE  /* Número do imóvel           */
           ,dscomple crapcop.dscomple%TYPE  /* Complemento do imóvel */
           ,nmbaienc crapcop.nmbairro%TYPE  /* Bairro do imóvel           */
           ,cdcidenc crapmun.cdcidade%TYPE  /* Código do município   */
           ,cdufdenc crapcop.cdufdcop%TYPE  /* UF do imóvel               */
           ,nrcepenc crapcop.nrcepend%TYPE  /* CEP do imóvel               */
           ,nrdddenc VARCHAR2(10)           /* DDD do telefone        */
           ,nrtelenc crapcop.nrtelvoz%TYPE  /* DDD Número do telefone        */

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

  -- Cursor para verificar se ha algum BEM tipo AUTOMOVEL/MOTO/CAMINHAO
  CURSOR cr_crapbpr (pr_cdcooper crapbpr.cdcooper%type
                    ,pr_nrdconta crapbpr.nrdconta%type
                    ,pr_nrctrpro crapbpr.nrctrpro%type) IS
    SELECT crapbpr.tpdbaixa,
           crapbpr.rowid
      FROM crapbpr
     WHERE crapbpr.cdcooper = pr_cdcooper
       AND crapbpr.nrdconta = pr_nrdconta
       AND crapbpr.tpctrpro = 90
       AND crapbpr.nrctrpro = pr_nrctrpro
       AND crapbpr.flgalien = 1
       AND (crapbpr.dscatbem LIKE '%AUTOMOVEL%'
        OR  crapbpr.dscatbem LIKE '%MOTO%'
        OR  crapbpr.dscatbem LIKE '%CAMINHAO%');
  rw_crapbpr cr_crapbpr%rowtype;
  
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

  PROCEDURE pc_gravames_consultar_bens(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                      ,pr_cddopcao IN VARCHAR2              --Opção
                                      ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                      ,pr_nrgravam IN crapbpr.nrgravam%TYPE --Número do gravame
                                      ,pr_nrregist IN INTEGER               -- Número de registros
                                      ,pr_nriniseq IN INTEGER               -- Número sequencial 
                                      ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
                              
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
                            
  PROCEDURE pc_gravames_blqjud(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                              ,pr_cddopcao IN VARCHAR2              --Opção
                              ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                              ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE --Tipo do contrato
                              ,pr_idseqbem IN crapbpr.idseqbem%TYPE --Identificador do bem
                              ,pr_dschassi IN crapbpr.dschassi%TYPE --Chassi do bem
                              ,pr_ufdplaca IN crapbpr.ufdplaca%TYPE --UF da placa
                              ,pr_nrdplaca IN crapbpr.nrdplaca%TYPE --Número da placa
                              ,pr_nrrenava IN crapbpr.nrrenava%TYPE --RENAVAN
                              ,pr_flblqjud IN crapbpr.flblqjud%TYPE -- BLoqueio judicial
                              ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                              ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
  
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
  
  PROCEDURE pc_gravames_cancelar(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                ,pr_cddopcao IN VARCHAR2              --Opção
                                ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                ,pr_idseqbem IN crapbpr.idseqbem%TYPE --Identificador do bem
                                ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE --Tipo do contrato
                                ,pr_tpcancel IN INTEGER              --Tipo de cancelamento
                                ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_gravames_inclusao_manual(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                       ,pr_cddopcao IN VARCHAR2              --Opção
                                       ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                       ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE --Tipo do contrato
                                       ,pr_idseqbem IN crapbpr.idseqbem%TYPE --Identificador do bem
                                       ,pr_nrgravam IN crapbpr.nrgravam%TYPE --Número do gravam
                                       ,pr_dtmvttel IN VARCHAR2              --Data do registro
                                       ,pr_dsjustif IN crapbpr.dsjstbxa%TYPE -- Justificativa da inclusão
                                       ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
                                       
 PROCEDURE pc_gravames_historico(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                 ,pr_cddopcao IN VARCHAR2              --Opção
                                 ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                 ,pr_cdcoptel IN crapcop.cdcooper%TYPE --Cooperativa selecionada      
                                 ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
                                 
  PROCEDURE pc_gravames_imp_relatorio(pr_cddopcao IN VARCHAR2              --Opção
                                     ,pr_tparquiv IN VARCHAR2              --Tipo do arquivo 
                                     ,pr_cdcoptel IN crapcop.cdcooper%TYPE --Cooperativa selecionada      
                                     ,pr_nrseqlot IN crapgrv.nrseqlot%TYPE --Numero do lote
                                     ,pr_dtrefere IN VARCHAR2              --Data de referencia
                                     ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
                                                             
                                                                                                                                                      
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
      
      -- Verifica se ha algum BEM tipo AUTOMOVEL/MOTO/CAMINHAO
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
          pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);END IF;

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
              ,bpr.uflicenc
              ,bpr.nranobem
              ,bpr.nrmodbem
              ,bpr.ufplnovo
              ,bpr.nrplnovo
              ,bpr.nrrenovo
              ,bpr.ufdplaca
              ,bpr.nrdplaca
              ,bpr.nrrenava
              ,ass.nrcpfcgc

              ,ROW_NUMBER ()
                  OVER (PARTITION BY cop.cdcooper ORDER BY cop.cdcooper) nrseqcop

          FROM crapass ass
              ,crapcop cop
              ,crawepr wpr
              ,crapbpr bpr

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
                 AND  bpr.flginclu   = 1     -- INCLUSAO SOLICITADA
                 AND  bpr.cdsitgrv in(0,3)   -- NAO ENVIADO ou PROCES.COM ERRO
                 AND  bpr.tpinclus   = 'A')  -- AUTOMATICA

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
             rw_bpr.flgbaixa = 0 THEN --Adicionado a alteração rw_bpr.flgbaixa = 0 pedido pelo análista Gielow
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
                       ,dtretgrv)
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
                       ,vr_tab_dados_arquivo(vr_dsdchave).dtmvtolt           --dtenvgrv
                       ,NULL)                                                --dtretgrv
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
                  ,dtenvgrv = vr_tab_dados_arquivo(vr_dsdchave).dtmvtolt
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
        pr_dscritic := pr_dscritic;
        
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
        pr_dscritic := 'Erro GRVM0001.pc_gravames_geracao_arquivo -> '||SQLERRM;

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
    Data     : Maio/2016                         Ultima atualizacao: 29/05/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca contratos
    
    --   Alteracoes: 29/05/2017 - Padronização das mensagens para a tabela tbgen_prglog,
    --                          - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
    --                          - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
    --                          - Incluir nome do módulo logado em variável
    --                            (Ana - Envolti) - SD: 660356 e 660394
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
       AND (crapbpr.dscatbem LIKE '%AUTOMOVEL%' OR
            crapbpr.dscatbem LIKE '%MOTO%'      OR
            crapbpr.dscatbem LIKE '%CAMINHAO%')
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

  -- Prj. 402
  PROCEDURE pc_consulta_situacao_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE      -- Código da Cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE      -- Número da conta
                                    ,pr_nrctrpro IN crawepr.nrctremp%TYPE      -- Número do contrato 
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE     -- Código da crítica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE) IS -- Descrição da crítica
                                      
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_consulta_situacao_cdc                            
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jean Michel
    Data     : 15/12/2017                          Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca contratos
    
    --   Alteracoes: 
    --               
    -------------------------------------------------------------------------------------------------------------*/                               
    
    --Cursor para encotrato o contrato de empréstimo 
    CURSOR cr_crawepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE)IS
    SELECT cop.flintcdc
          ,cdc.inintegra_cont
          ,fin.tpfinali
      FROM crapcop cop
          ,crawepr epr
          ,tbepr_cdc_parametro cdc
          ,crapfin fin
     WHERE epr.cdcooper = pr_cdcooper
       AND epr.nrdconta = pr_nrdconta
       AND epr.nrctremp = pr_nrctremp
       AND epr.cdcooper = cop.cdcooper
       AND cop.cdcooper = cdc.cdcooper
       AND cdc.cdcooper = fin.cdcooper
       AND fin.cdfinemp = epr.cdfinemp;

    rw_crawepr cr_crawepr%ROWTYPE;                      
                     
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
    
  BEGIN
    
      OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctrpro);
                     
      FETCH cr_crawepr INTO rw_crawepr;
              
      IF cr_crawepr%FOUND THEN
        CLOSE cr_crawepr; 

        IF rw_crawepr.tpfinali = 3 AND rw_crawepr.flintcdc = 1 AND rw_crawepr.inintegra_cont = 0 THEN
          vr_dscritic := 'Ação não permitida, cooperativa possui integração CDC habilitada! Esta ação deve ser realizada junto ao Autorizador CDC.';
          RAISE vr_exc_erro;
        END IF;

      ELSE
        CLOSE cr_crawepr;
        vr_dscritic := 'Registro de contrato não encontrado.';
        RAISE vr_exc_erro;
      END IF;

  EXCEPTION    
    WHEN vr_exc_erro THEN

      IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); -- Buscar a descrição
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN   
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta_situacao_cdc: '|| SQLERRM;
    
  END pc_consulta_situacao_cdc;
  -- Prj. 402

  PROCEDURE pc_gravames_consultar_bens(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                      ,pr_cddopcao IN VARCHAR2              --Opção
                                      ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                      ,pr_nrgravam IN crapbpr.nrgravam%TYPE --Número do gravame
                                      ,pr_nrregist IN INTEGER               -- Número de registros
                                      ,pr_nriniseq IN INTEGER               -- Número sequencial 
                                      ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravames_consultar_bens                            antiga: b1wgen0171.gravames_consultar_bens
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 29/05/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca contratos
    
    --   Alteracoes: 29/05/2017 - Padronização das mensagens para a tabela tbgen_prglog,
    --                          - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
    --                          - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
    --                          - Incluir nome do módulo logado em variável
    --                            (Ana - Envolti) - SD: 660356 e 660394
    -------------------------------------------------------------------------------------------------------------*/                               
  
    --Cursor para encontrar os bens
    CURSOR cr_propostas(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE
                       ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE)IS
    SELECT crawepr.nrctremp
          ,crapbpr.nrgravam
          ,crapbpr.idseqbem
          ,crapbpr.dsbemfin
          ,crapbpr.vlmerbem
          ,crapbpr.tpchassi
          ,crapbpr.nrdplaca
          ,crapbpr.nranobem
          ,crawepr.vlemprst
          ,crapbpr.nrcpfbem
          ,crapbpr.uflicenc
          ,crapbpr.dscatbem
          ,crapbpr.dscorbem
          ,crapbpr.dschassi
          ,crapbpr.ufdplaca
          ,crapbpr.nrrenava
          ,crapbpr.nrmodbem
          ,crawepr.dtmvtolt
          ,crapbpr.ufplnovo
          ,crapbpr.nrplnovo
          ,crapbpr.nrrenovo
          ,crapbpr.dtatugrv
          ,crapbpr.flblqjud
          ,crapbpr.cdsitgrv
          ,crapbpr.tpctrpro
          ,crapbpr.dsjstbxa
          ,crapbpr.dsjstinc
          ,crapbpr.tpinclus
          ,ROW_NUMBER() OVER(PARTITION BY crawepr.cdcooper, crawepr.nrdconta, crawepr.nrctremp
                               ORDER BY crawepr.cdcooper, crawepr.nrdconta, crawepr.nrctremp) nrseq_bem
      FROM crawepr
          ,craplcr
          ,crapbpr
     WHERE crawepr.cdcooper = pr_cdcooper
       AND crawepr.nrdconta = pr_nrdconta
       AND crawepr.nrctremp = pr_nrctrpro
       AND craplcr.cdcooper = crawepr.cdcooper
       AND craplcr.cdlcremp = crawepr.cdlcremp
       AND craplcr.tpctrato = 2
       AND crapbpr.cdcooper = crawepr.cdcooper
       AND crapbpr.nrdconta = crawepr.nrdconta
       AND crapbpr.tpctrpro = pr_tpctrpro
       AND crapbpr.nrctrpro = crawepr.nrctremp
       AND crapbpr.flgalien = 1
       AND (crapbpr.dscatbem LIKE '%AUTOMOVEL%' OR
            crapbpr.dscatbem LIKE '%MOTO%'      OR
            crapbpr.dscatbem LIKE '%CAMINHAO%');
    
    -- Cursor para encontrar o bem
    CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE
                     ,pr_nrgravam IN crapbpr.nrgravam%TYPE) IS
    SELECT crawepr.nrctremp
          ,crapbpr.nrgravam
          ,crapbpr.idseqbem
          ,crapbpr.dsbemfin
          ,crapbpr.vlmerbem
          ,crapbpr.tpchassi
          ,crapbpr.nrdplaca
          ,crapbpr.nranobem
          ,crawepr.vlemprst
          ,crapbpr.nrcpfbem
          ,crapbpr.uflicenc
          ,crapbpr.dscatbem
          ,crapbpr.dscorbem
          ,crapbpr.dschassi
          ,crapbpr.ufdplaca
          ,crapbpr.nrrenava
          ,crapbpr.nrmodbem
          ,crawepr.dtmvtolt
          ,crapbpr.ufplnovo
          ,crapbpr.nrplnovo
          ,crapbpr.nrrenovo
          ,crapbpr.dtatugrv
          ,crapbpr.flblqjud
          ,crapbpr.cdsitgrv  
          ,crapbpr.tpctrpro
          ,crapbpr.dsjstinc
          ,crapbpr.dsjstbxa      
          ,crapbpr.tpinclus      
          ,ROW_NUMBER() OVER(PARTITION BY crawepr.cdcooper, crawepr.nrdconta, crawepr.nrctremp
                               ORDER BY crawepr.cdcooper, crawepr.nrdconta, crawepr.nrctremp) nrseq_bem
      FROM crapbpr
          ,crawepr
     WHERE crapbpr.cdcooper = pr_cdcooper
       AND crapbpr.nrdconta = pr_nrdconta
       AND crapbpr.tpctrpro = 90
       AND crapbpr.nrgravam = pr_nrgravam
       AND crapbpr.flgalien = 1
       AND (crapbpr.dscatbem LIKE '%AUTOMOVEL%' OR
            crapbpr.dscatbem LIKE '%MOTO%'      OR
            crapbpr.dscatbem LIKE '%CAMINHAO%')
       AND crawepr.cdcooper = crapbpr.cdcooper
       AND crawepr.nrdconta = crapbpr.nrdconta
       AND crawepr.nrctremp = crapbpr.nrctrpro;
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
    vr_nrdplaca crapbpr.nrplnovo%TYPE;
    vr_ufdplaca crapbpr.ufplnovo%TYPE;
    vr_nrrenava crapbpr.nrrenovo%TYPE;
    vr_stsnrcal BOOLEAN;
    vr_inpessoa INTEGER;
    vr_dscpfbem VARCHAR2(30);
    vr_dsjustif crapbpr.dsjstinc%TYPE;
    vr_tpjustif INTEGER := 0;
    vr_tpctrpro crapbpr.tpctrpro%TYPE;
    
    --Variaveis Locais   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';      
    vr_nrregist INTEGER; 
    vr_qtregist INTEGER := 0; 
    vr_contador INTEGER := 0;  
    vr_crapepr  VARCHAR2(50);
    
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';
    
  BEGIN
    vr_nrregist := pr_nrregist;
  
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_consultar_bens');
    
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
       
    /**/
    pc_consulta_situacao_cdc(pr_cdcooper => vr_cdcooper  -- Código da Cooperativa
                            ,pr_nrdconta => pr_nrdconta  -- Número da conta
                            ,pr_nrctrpro => pr_nrctrpro  -- Número do contrato 
                            ,pr_cdcritic => vr_cdcritic  -- Código da crítica
                            ,pr_dscritic => vr_dscritic); -- Descrição do Erro

    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    /**/

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
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_consultar_bens');
      
    IF pr_cddopcao = 'A' OR 
       pr_cddopcao = 'S' THEN
      
      OPEN cr_crapepr(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctrpro);
                     
      FETCH cr_crapepr INTO rw_crapepr;
              
      IF cr_crapepr%FOUND THEN
        
        vr_crapepr := 'possuictr="1"'; 
        
      ELSE
      
        vr_crapepr := 'possuictr="0"'; 
          
      END IF;
      
      --Fechar Cursor
      CLOSE cr_crapepr;
        
    END IF;
    
    IF pr_cddopcao = 'S' THEN
    
      vr_tpctrpro := 99;
      
    ELSE
      
      vr_tpctrpro := 90;
      
    END IF;
    
    
    IF pr_nrgravam = 0 THEN
      
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
          
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><Bens ' || vr_crapepr || '>');     
            
      --Busca as propostas
      FOR rw_propostas IN cr_propostas(pr_cdcooper => vr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctrpro => pr_nrctrpro
                                      ,pr_tpctrpro => vr_tpctrpro) LOOP
      
        --Incrementar contador
        vr_qtregist:= nvl(vr_qtregist,0) + 1;
                
        -- controles da paginacao 
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

          --Proximo
          CONTINUE;  
                    
        END IF; 
                
        IF vr_nrregist >= 1 THEN   
          
          -- 09.3Q Valida Numero de Inscricao
          gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => rw_propostas.nrcpfbem, 
                                      pr_stsnrcal => vr_stsnrcal, 
                                      pr_inpessoa => vr_inpessoa);
                                      
          vr_dscpfbem := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_propostas.nrcpfbem
                                                  ,pr_inpessoa => vr_inpessoa);
         
          
          IF trim(rw_propostas.ufplnovo) IS NOT NULL AND
             trim(rw_propostas.nrplnovo) IS NOT NULL AND
             rw_propostas.nrrenovo > 0               THEN
             
            vr_nrdplaca := rw_propostas.nrplnovo;
            vr_ufdplaca := rw_propostas.ufplnovo;
            vr_nrrenava := rw_propostas.nrrenovo;
            
          ELSE
            
            vr_nrdplaca := rw_propostas.nrdplaca; 
            vr_ufdplaca := rw_propostas.ufdplaca;
            vr_nrrenava := rw_propostas.nrrenava;  
            
          END IF;
          
          IF rw_propostas.cdsitgrv = 2 THEN             
          
            vr_tpjustif := 1;
            vr_dsjustif := nvl(TRIM(rw_propostas.dsjstinc),' ');  
            
          ELSIF rw_propostas.cdsitgrv = 4 THEN
            
            vr_tpjustif := 2;
            vr_dsjustif := nvl(TRIM(rw_propostas.dsjstbxa),' ');
          
          END IF;
          
          -- Carrega os dados           
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<ben>'||                                                                                                        
                                                         '  <nrseqbem>' || rw_propostas.nrseq_bem ||'</nrseqbem>'||
                                                         '  <idseqbem>' || rw_propostas.idseqbem ||'</idseqbem>'||
                                                         '  <dsseqbem>' || rw_propostas.nrseq_bem || 'º Bem' ||'</dsseqbem>'||
                                                         '  <nrgravam>' || rw_propostas.nrgravam ||'</nrgravam>'||
                                                         '  <tpctrpro>' || rw_propostas.tpctrpro ||'</tpctrpro>'||
                                                         '  <dsbemfin>' || rw_propostas.dsbemfin ||'</dsbemfin>'||
                                                         '  <vlmerbem>' || to_char(rw_propostas.vlmerbem,'fm99999g999g990d00') ||'</vlmerbem>'||
                                                         '  <tpchassi>' || rw_propostas.tpchassi ||'</tpchassi>'||
                                                         '  <nranobem>' || rw_propostas.nranobem ||'</nranobem>'||
                                                         '  <dscpfbem>' || vr_dscpfbem ||'</dscpfbem>'||
                                                         '  <uflicenc>' || rw_propostas.uflicenc ||'</uflicenc>'||
                                                         '  <dscatbem>' || rw_propostas.dscatbem ||'</dscatbem>'||
                                                         '  <dscorbem>' || rw_propostas.dscorbem ||'</dscorbem>'||
                                                         '  <dschassi>' || rw_propostas.dschassi ||'</dschassi>'||
                                                         '  <nrmodbem>' || rw_propostas.nrmodbem ||'</nrmodbem>'||
                                                         '  <cdsitgrv>' || rw_propostas.cdsitgrv ||'</cdsitgrv>'||
                                                         '  <nrdplaca>' || vr_nrdplaca ||'</nrdplaca>'|| 
                                                         '  <ufdplaca>' || vr_ufdplaca ||'</ufdplaca>'|| 
                                                         '  <nrrenava>' || vr_nrrenava ||'</nrrenava>'|| 
                                                         '  <vlctrgrv>' || to_char(rw_propostas.vlemprst,'fm99999g999g990d00') ||'</vlctrgrv>'|| 
                                                         '  <dtoperac>' || to_char(rw_propostas.dtmvtolt,'DD/MM/RRRR') ||'</dtoperac>'|| 
                                                         '  <dtmvtolt>' || to_char(rw_propostas.dtatugrv,'DD/MM/RRRR') ||'</dtmvtolt>'||    
                                                         '  <dsjustif>' || vr_dsjustif ||'</dsjustif>'||        
                                                         '  <tpjustif>' || vr_tpjustif ||'</tpjustif>'||                                                                                                                                                                      
                                                         '  <dsblqjud>' || (CASE rw_propostas.flblqjud
                                                                              WHEN 1 THEN
                                                                                'SIM'
                                                                              ELSE
                                                                                'NAO'
                                                                            END ) ||'</dsblqjud>'||                                                                                                                                                                                                                            
                                                         '  <dssitgrv>' || (CASE rw_propostas.cdsitgrv
                                                                              WHEN 0 THEN
                                                                                'Nao enviado'
                                                                              WHEN 1 THEN
                                                                                'Em processamento'
                                                                              WHEN 2 THEN
                                                                                'Alienacao'
                                                                              WHEN 3 THEN
                                                                                'Processado com Critica'
                                                                              WHEN 4 THEN
                                                                                'Baixado'
                                                                              WHEN 5 THEN
                                                                                'Cancelado'
                                                                            END ) ||'</dssitgrv>'||                   
                                                         '  <tpinclus>' || rw_propostas.tpinclus ||'</tpinclus>'|| 
                                                       '</ben>');
          
          --Diminuir registros
          vr_nrregist:= nvl(vr_nrregist,0) - 1;
             
        END IF;         
            
        vr_contador := vr_contador + 1; 
      
      END LOOP;
           
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Bens></Root>'
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
      
    ELSE
      
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
          
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><Bens ' || vr_crapepr || '>');
                             
      --Busca as propostas
      FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => vr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctrpro => pr_nrctrpro
                                  ,pr_nrgravam => pr_nrgravam) LOOP
      
        --Incrementar contador
        vr_qtregist:= nvl(vr_qtregist,0) + 1;
                
        -- controles da paginacao 
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

          --Proximo
          CONTINUE;  
                    
        END IF; 
                
        IF vr_nrregist >= 1 THEN   
         
          IF trim(rw_crapbpr.ufplnovo) IS NOT NULL AND
             trim(rw_crapbpr.nrplnovo) IS NOT NULL AND
             rw_crapbpr.nrrenovo > 0               THEN
             
            vr_nrdplaca := rw_crapbpr.nrplnovo;
            vr_ufdplaca := rw_crapbpr.ufplnovo;
            vr_nrrenava := rw_crapbpr.nrrenovo;
            
          ELSE
            
            vr_nrdplaca := rw_crapbpr.nrdplaca; 
            vr_ufdplaca := rw_crapbpr.ufdplaca;
            vr_nrrenava := rw_crapbpr.nrrenava;  
            
          END IF;
          
          IF rw_crapbpr.cdsitgrv = 2 THEN             
          
            vr_tpjustif := 1;
            vr_dsjustif := nvl(TRIM(rw_crapbpr.dsjstinc),' ');  
            
          ELSIF rw_crapbpr.cdsitgrv = 4 THEN
            
            vr_tpjustif := 2;
            vr_dsjustif := nvl(TRIM(rw_crapbpr.dsjstbxa),' ');
          
          END IF;
            
          -- Carrega os dados           
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<ben>'||                                                                                                        
                                                         '  <nrseqbem>' || rw_crapbpr.nrseq_bem || '</nrseqbem>'||
                                                         '  <idseqbem>' || rw_crapbpr.idseqbem ||'</idseqbem>'||
                                                         '  <dsseqbem>' || rw_crapbpr.nrseq_bem || 'º Bem' ||'</dsseqbem>'||
                                                         '  <nrgravam>' || rw_crapbpr.nrgravam ||'</nrgravam>'||
                                                         '  <tpctrpro>' || rw_crapbpr.tpctrpro ||'</tpctrpro>'||
                                                         '  <dsbemfin>' || rw_crapbpr.dsbemfin ||'</dsbemfin>'||
                                                         '  <vlmerbem>' || to_char(rw_crapbpr.vlmerbem,'fm99999g999g990d00')  ||'</vlmerbem>'||
                                                         '  <tpchassi>' || rw_crapbpr.tpchassi ||'</tpchassi>'||
                                                         '  <nranobem>' || rw_crapbpr.nranobem ||'</nranobem>'||
                                                         '  <uflicenc>' || rw_crapbpr.uflicenc ||'</uflicenc>'||
                                                         '  <dscatbem>' || rw_crapbpr.dscatbem ||'</dscatbem>'||
                                                         '  <dscorbem>' || rw_crapbpr.dscorbem ||'</dscorbem>'||
                                                         '  <dschassi>' || rw_crapbpr.dschassi ||'</dschassi>'||
                                                         '  <nrmodbem>' || rw_crapbpr.nrmodbem ||'</nrmodbem>'||
                                                         '  <cdsitgrv>' || rw_crapbpr.cdsitgrv ||'</cdsitgrv>'||
                                                         '  <nrdplaca>' || vr_nrdplaca ||'</nrdplaca>'|| 
                                                         '  <ufdplaca>' || vr_ufdplaca ||'</ufdplaca>'|| 
                                                         '  <nrrenava>' || vr_nrrenava ||'</nrrenava>'|| 
                                                         '  <vlctrgrv>' || to_char(rw_crapbpr.vlemprst,'fm99999g999g990d00') ||'</vlctrgrv>'||                                                          
                                                         '  <dtoperac>' || to_char(rw_crapbpr.dtmvtolt,'DD/MM/RRRR') ||'</dtoperac>'|| 
                                                         '  <dtmvtolt>' || to_char(rw_crapbpr.dtatugrv,'DD/MM/RRRR') ||'</dtmvtolt>'||  
                                                         '  <dsjustif>' || vr_dsjustif ||'</dsjustif>'||    
                                                         '  <tpjustif>' || vr_tpjustif ||'</tpjustif>'||                                                                                                                                                                     
                                                         '  <dsblqjud>' || (CASE rw_crapbpr.flblqjud
                                                                              WHEN 1 THEN
                                                                                'SIM'
                                                                              ELSE
                                                                                'NAO'
                                                                            END ) ||'</dsblqjud>'||                                                                                                                                                                                                                            
                                                         '  <dssitgrv>' || (CASE rw_crapbpr.cdsitgrv
                                                                              WHEN 0 THEN
                                                                                'Nao enviado'
                                                                              WHEN 1 THEN
                                                                                'Em processamento'
                                                                              WHEN 2 THEN
                                                                                'Alienacao'
                                                                              WHEN 3 THEN
                                                                                'Processado com Critica'
                                                                              WHEN 4 THEN
                                                                                'Baixado'
                                                                              WHEN 5 THEN
                                                                                'Cancelado'
                                                                            END ) ||'</dssitgrv>'||                   
                                                         '  <tpinclus>' || rw_crapbpr.tpinclus ||'</tpinclus>'|| 
                                                       '</ben>');
            
          --Diminuir registros
          vr_nrregist:= nvl(vr_nrregist,0) - 1;
           
        END IF;         
            
        vr_contador := vr_contador + 1; 
      
      END LOOP;               
      
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Bens></Root>'
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
      --Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Mensagem
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ALERTA: '|| pr_dscritic ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Cddopcao:'||pr_cddopcao||',Nrctrpro:'||pr_nrctrpro||
                                                    ',Nrgravam:'||pr_nrgravam||',Nrregist:'||pr_nrregist||
                                                    ',Nriniseq:'||pr_nriniseq);

    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gravames_consultar_bens --> '|| SQLERRM;
        
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
                                                    'ERRO: '|| pr_dscritic ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Cddopcao:'||pr_cddopcao||',Nrctrpro:'||pr_nrctrpro||
                                                    ',Nrgravam:'||pr_nrgravam||',Nrregist:'||pr_nrregist||
                                                    ',Nriniseq:'||pr_nriniseq);

      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
    
  END pc_gravames_consultar_bens;  

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
    Data     : Maio/2016                         Ultima atualizacao: 29/05/2017
    
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
          ,crapbpr.uflicenc
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
    
    ELSIF trim(pr_dscatbem) IN('MOTO','AUTOMOVEL','CAMINHAO') AND 
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
              ,crapbpr.ufplnovo = pr_ufdplaca
              ,crapbpr.nrplnovo = pr_nrdplaca
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

  PROCEDURE pc_gravames_cancelar(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                ,pr_cddopcao IN VARCHAR2              --Opção
                                ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                ,pr_idseqbem IN crapbpr.idseqbem%TYPE --Identificador do bem
                                ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE --Tipo do contrato
                                ,pr_tpcancel IN INTEGER               --Tipo de cancelamento
                                ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
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
          ,crapbpr.uflicenc
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
    
    vr_tab_erro gene0001.typ_tab_erro;
        
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';

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
         SET crapbpr.tpcancel = decode(pr_tpcancel,1,'A',2,'M')
            ,crapbpr.flcancel = 1
            ,crapbpr.dtcancel = rw_crapdat.dtmvtolt
            ,crapbpr.cdsitgrv = decode(pr_tpcancel,2,5,crapbpr.cdsitgrv)
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

  PROCEDURE pc_gravames_blqjud(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                              ,pr_cddopcao IN VARCHAR2              --Opção
                              ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                              ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE --Tipo do contrato 
                              ,pr_idseqbem IN crapbpr.idseqbem%TYPE --Identificador do bem
                              ,pr_dschassi IN crapbpr.dschassi%TYPE --Chassi do bem
                              ,pr_ufdplaca IN crapbpr.ufdplaca%TYPE --UF da placa
                              ,pr_nrdplaca IN crapbpr.nrdplaca%TYPE --Número da placa
                              ,pr_nrrenava IN crapbpr.nrrenava%TYPE --RENAVAN
                              ,pr_flblqjud IN crapbpr.flblqjud%TYPE -- BLoqueio judicial
                              ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                              ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravames_blqjud                            antiga: b1wgen0171.gravames_blqjud
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 29/05/2017
    
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
       AND (crapbpr.dscatbem LIKE '%AUTOMOVEL%' OR
            crapbpr.dscatbem LIKE '%MOTO%'      OR
            crapbpr.dscatbem LIKE '%CAMINHAO%');
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
    vr_dstransa := 'Bloqueio ou Liberacao judicial do bem no gravames';
    
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
           SET crapbpr.flblqjud = pr_flblqjud              
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
                                pr_nmdcampo => 'flblqjud', 
                                pr_dsdadant => TO_CHAR(rw_crapbpr.flblqjud), 
                                pr_dsdadatu => TO_CHAR(pr_flblqjud));
      
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
                                       ,pr_dsjustif IN crapbpr.dsjstbxa%TYPE -- Justificativa da inclusão
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
                              pr_nmdcampo => 'dtdinclu', 
                              pr_dsdadant => to_char(rw_crapbpr.dtdinclu), 
                              pr_dsdadatu => to_char(rw_crapdat.dtmvtolt)); 

    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'pr_dsjustif', 
                              pr_dsdadant => rw_crapbpr.dsjstinc, 
                              pr_dsdadatu => pr_dsjustif); 

    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'cdsitgrv', 
                              pr_dsdadant => to_char(rw_crapbpr.cdsitgrv), 
                              pr_dsdadatu => '2');

    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'nrgravam', 
                              pr_dsdadant => to_char(rw_crapbpr.nrgravam), 
                              pr_dsdadatu => to_char(pr_nrgravam));
                              
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'dtatugrv', 
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

  PROCEDURE pc_gravames_historico(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                 ,pr_cddopcao IN VARCHAR2              --Opção
                                 ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                 ,pr_cdcoptel IN crapcop.cdcooper%TYPE --Cooperativa selecionada      
                                 ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravames_historico                           antiga: b1wgen0171.gravames_historico
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 29/05/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realizar a geração do relatório de históricos
    
    Alterações : 14/07/2016 - Ajuste para ler a crapdat e enviar corretamente para a rotina
                              de geração do relatório
                              (Andrei - RKAM).

                 29/05/2017 - Ajuste das mensagens: neste caso são todas consideradas tpocorrencia = 4,
                           - Substituição do termo "ERRO" por "ALERTA",
                           - Padronização das mensagens para a tabela tbgen_prglog,
                           - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
                           - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
                           - Incluir nome do módulo logado em variável
                             (Ana - Envolti) - SD: 660356 e 660394
    -------------------------------------------------------------------------------------------------------------*/                               
  
    -- Cursor para encontrar o bem
    CURSOR cr_crapgrv(pr_cdcooper IN crapgrv.cdcooper%TYPE
                     ,pr_nrdconta IN crapgrv.nrdconta%TYPE                     
                     ,pr_nrctrpro IN crapgrv.nrctrpro%TYPE) IS
    SELECT decode(crapgrv.cdoperac,1,'INCLUSAO',2,'CANCELAMENTO',3,'BAIXA') dsoperac               
          ,crapgrv.nrdconta
          ,crapgrv.dtenvgrv
          ,crapgrv.dschassi
          ,crapgrv.nrctrpro
          ,crapgrv.nrseqlot
          ,crapgrv.dtretgrv
      FROM crapgrv
     WHERE crapgrv.cdcooper = pr_cdcooper
       AND crapgrv.nrdconta = pr_nrdconta
       AND (pr_nrctrpro = 0 OR crapgrv.nrctrpro = pr_nrctrpro)
       ORDER BY crapgrv.nrctrpro DESC
               ,crapgrv.dtenvgrv DESC
               ,crapgrv.nrseqlot DESC;
    rw_crapgrv cr_crapgrv%ROWTYPE;
    
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
    vr_comando     VARCHAR2(1000);
    vr_typ_saida   VARCHAR2(3);
    
    --Variaveis Locais   
    vr_nmdireto    VARCHAR2(100);
    vr_dstexto     VARCHAR2(32700);      
    vr_clobxml     CLOB;       
    vr_des_reto    VARCHAR2(3);      
    vr_nmarqpdf    VARCHAR2(1000);
    vr_nmarquiv    VARCHAR2(1000);
    
    vr_tab_erro gene0001.typ_tab_erro;
        
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';
  
  BEGIN
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_historico');
    
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
       
    --Buscar Diretorio Padrao da Cooperativa
    vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                        ,pr_cdcooper => vr_cdcooper
                                        ,pr_nmsubdir => 'rl');
                                       
    --Nome do Arquivo
    vr_nmarquiv:= vr_nmdireto||'/'||'crrl721' || dbms_random.string('X',20) || '.lst';
      
    --Nome do Arquivo PDF
    vr_nmarqpdf:= REPLACE(vr_nmarquiv,'.lst','.pdf');
      
    -- Inicializar as informações do XML de dados para o relatório
    dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

    --Escrever no arquivo XML
    gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                             '<?xml version="1.0" encoding="UTF-8"?>' || 
                                '<crrl721><Gravames>');
                                          
    FOR rw_crapgrv IN cr_crapgrv(pr_cdcooper => pr_cdcoptel
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctrpro => pr_nrctrpro) LOOP
                                
      --Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                                 '<gravame>' ||
                                    '<nrdconta>' || TRIM(gene0002.fn_mask(rw_crapgrv.nrdconta,'zzzz.zzz.z')) || '</nrdconta>' ||
                                    '<nrctrpro>' || TO_CHAR(rw_crapgrv.nrctrpro,'fm99G999G990') || '</nrctrpro>' ||
                                    '<dsoperac>' || rw_crapgrv.dsoperac || '</dsoperac>' ||                                           
                                    '<nrseqlot>' || LPAD(rw_crapgrv.nrseqlot, 7, '0') || '</nrseqlot>' ||
                                    '<dtenvgrv>' || TO_CHAR(rw_crapgrv.dtenvgrv,'dd/mm/RRRR') || '</dtenvgrv>' ||
                                    '<dtretgrv>' || TO_CHAR(rw_crapgrv.dtretgrv,'dd/mm/RRRR') || '</dtretgrv>' ||
                                    '<dschassi>' || rw_crapgrv.dschassi || '</dschassi>' ||
                                 '</gravame>');                            
                                
    END LOOP;           
          
    --Finaliza TAG Relatorio
    gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</Gravames></crrl721>',TRUE); 
   
    -- Gera relatório crrl657
    gene0002.pc_solicita_relato(pr_cdcooper    => vr_cdcooper    --> Cooperativa conectada
                                 ,pr_cdprogra  => 'RATING'--vr_nmdatela         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => 'crrl721/Gravames/gravame'          --> Nó base do XML para leitura dos dados                                  
                                 ,pr_dsjasper  => 'gravam_historico.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nmarqpdf         --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                  --> Colunas do relatorio
                                 ,pr_flg_gerar => 'S'                 --> Geraçao na hora
                                 ,pr_cdrelato  => '721'               --> Códigod do relatório
                                 ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p) 
                                 ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                   --> Número de cópias
                                 ,pr_sqcabrel  => 1                   --> Qual a seq do cabrel                                                                          
                                 ,pr_des_erro  => vr_dscritic);       --> Saída com erro
        
    --Se ocorreu erro no relatorio
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF; 
        
    --Fechar Clob e Liberar Memoria  
    dbms_lob.close(vr_clobxml);
    dbms_lob.freetemporary(vr_clobxml);  
      
     --Efetuar Copia do PDF
    gene0002.pc_efetua_copia_pdf (pr_cdcooper => vr_cdcooper     --> Cooperativa conectada
                                 ,pr_cdagenci => vr_cdagenci     --> Codigo da agencia para erros
                                 ,pr_nrdcaixa => vr_nrdcaixa     --> Codigo do caixa para erros
                                 ,pr_nmarqpdf => vr_nmarqpdf     --> Arquivo PDF  a ser gerado                                 
                                 ,pr_des_reto => vr_des_reto     --> Saída com erro
                                 ,pr_tab_erro => vr_tab_erro);   --> tabela de erros 
                                   
    --Se ocorreu erro
    IF vr_des_reto = 'NOK' THEN
        
      --Se possui erro
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel efetuar a copia do relatorio.';
      END IF;
        
      --Levantar Excecao  
      RAISE vr_exc_erro;
        
    END IF; 
        
    --Se Existir arquivo pdf  
    IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmarqpdf) THEN
        
      --Remover arquivo
      vr_comando:= 'rm '||vr_nmarqpdf||' 2>/dev/null';
        
      --Executar o comando no unix
      GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => vr_comando
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_dscritic);
                          
      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
          
        --Monta mensagem de critica
        vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
          
        -- retornando ao programa chamador
        RAISE vr_exc_erro;
          
      END IF;
        
    END IF;
        
    --Se ocorreu erro
    IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN                                   
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    --Retornar nome arquivo impressao e pdf
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
            
    -- Insere atributo na tag Dados com o valor total de agendamentos
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Dados'             --> Nome da TAG XML
                             ,pr_atrib => 'nmarquiv'          --> Nome do atributo
                             ,pr_atval => substr(vr_nmarqpdf,instr(vr_nmarqpdf,'/',-1)+1)         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros 
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
                                                    ',Nrctrpro:'||pr_nrctrpro||',Cdcoptel:'||pr_cdcoptel||
                                                    ',Cddopcao:'||pr_cddopcao);
                 
                                           
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gravames_historico --> '|| SQLERRM;
        
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
                                                    'ERRO: '|| pr_dscritic ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Nrctrpro:'||pr_nrctrpro||',Cdcoptel:'||pr_cdcoptel||
                                                    ',Cddopcao:'||pr_cddopcao);

      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
        
  END pc_gravames_historico;  

  PROCEDURE pc_gravames_imp_relatorio(pr_cddopcao IN VARCHAR2              --Opção
                                     ,pr_tparquiv IN VARCHAR2              --Tipo do arquivo 
                                     ,pr_cdcoptel IN crapcop.cdcooper%TYPE --Cooperativa selecionada      
                                     ,pr_nrseqlot IN crapgrv.nrseqlot%TYPE --Numero do lote
                                     ,pr_dtrefere IN VARCHAR2              --Data de referencia
                                     ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravames_imp_relatorio                           antiga: b1wgen0171.gravames_impressao_relatorio
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 29/05/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realizar a geração do relatório de processamento de GRAVAMES
    
    Alterações : 14/07/2016 - Ajuste para validar a data nula e tratar corretamento
						                  o lote a ser enviado para consulta
							                (Andrei - RKAM).

        				 22/09/2016 - Ajuste para utilizar upper ao manipular a informação do chassi
                              pois em alguns casos ele foi gravado em minusculo e outros em maisculo
                              (Adriano - SD 527336)

                 29/05/2017 - Ajuste das mensagens: neste caso são todas consideradas tpocorrencia = 4,
                            - Substituição do termo "ERRO" por "ALERTA",
                            - Padronização das mensagens para a tabela tbgen_prglog,
                            - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
                            - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
                            - Incluir nome do módulo logado em variável
                            - Setar nome módulo no início do programa
                              (Ana - Envolti) - SD: 660356 e 660394
    -------------------------------------------------------------------------------------------------------------*/                               
  
    -- Cursor para validacao da cooperativa conectada
    CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%type) IS
    SELECT cdcooper
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%rowtype;
    
    -- Cursor para encontrar o bem
    CURSOR cr_crapgrv_sem_retorno(pr_cdcooper IN crapgrv.cdcooper%TYPE
                                 ,pr_dtenvgrv IN crapgrv.dtenvgrv%TYPE                     
                                 ,pr_cdoperac IN crapgrv.cdoperac%TYPE
                                 ,pr_nrseqlot IN crapgrv.nrseqlot%TYPE) IS
    SELECT crapgrv.cdcooper
          ,crapgrv.cdoperac
          ,crapgrv.nrdconta
          ,crapgrv.dtenvgrv
          ,crapgrv.dschassi
          ,crapgrv.nrctrpro
          ,crapgrv.tpctrpro
          ,crapgrv.nrseqlot
          ,crapgrv.dtretgrv
          ,crapass.cdagenci
          ,crapass.inpessoa
      FROM crapgrv
          ,crapass
     WHERE ((crapgrv.cdcooper = pr_cdcooper AND pr_cdcooper <> 0)
        OR  pr_cdcooper = 0)
       AND (crapgrv.cdoperac = pr_cdoperac OR
            pr_cdoperac = 0)
       AND (crapgrv.nrseqlot = pr_nrseqlot OR
            pr_nrseqlot = 0)
       AND  crapgrv.dtretgrv IS NULL     /** Que NAO tiveram retorno **/
       AND  crapgrv.dtenvgrv = pr_dtenvgrv
       AND  crapass.cdcooper = crapgrv.cdcooper
       AND  crapass.nrdconta = crapgrv.nrdconta
       ORDER BY crapgrv.cdcooper 
               ,crapgrv.cdoperac 
               ,crapgrv.nrseqlot
               ,crapgrv.nrdconta
               ,crapgrv.nrctrpro
               ,crapgrv.idseqbem ;
    
    -- Cursor para encontrar o bem
    CURSOR cr_crapgrv_sucesso(pr_cdcooper IN crapgrv.cdcooper%TYPE
                             ,pr_dtenvgrv IN crapgrv.dtenvgrv%TYPE                     
                             ,pr_cdoperac IN crapgrv.cdoperac%TYPE
                             ,pr_nrseqlot IN crapgrv.nrseqlot%TYPE) IS
    SELECT crapgrv.cdcooper
          ,crapgrv.cdoperac
          ,crapgrv.nrdconta
          ,crapgrv.dtenvgrv
          ,crapgrv.dschassi
          ,crapgrv.nrctrpro
          ,crapgrv.tpctrpro
          ,crapgrv.nrseqlot
          ,crapgrv.dtretgrv
          ,crapass.cdagenci
          ,crapass.inpessoa          
      FROM crapgrv
          ,crapass
     WHERE ((crapgrv.cdcooper = pr_cdcoptel AND pr_cdcoptel <> 0)
        OR pr_cdcoptel = 0)
       AND (crapgrv.cdoperac = pr_cdoperac 
        OR pr_cdoperac = 0)
       AND (crapgrv.nrseqlot = pr_nrseqlot
        OR pr_nrseqlot = 0)
       AND  crapgrv.cdretlot = 0     /** Sucesso no LOTE */
       AND (crapgrv.cdretgrv = 0 OR crapgrv.cdretgrv = 30)
       AND (crapgrv.cdretctr = 0 OR crapgrv.cdretctr = 90)
       AND  crapgrv.dtretgrv IS NOT NULL    /** Que tiveram retorno **/
       AND  crapgrv.dtenvgrv = pr_dtenvgrv
       AND  crapass.cdcooper = crapgrv.cdcooper
       AND  crapass.nrdconta = crapgrv.nrdconta
       ORDER BY crapgrv.cdcooper 
               ,crapgrv.cdoperac 
               ,crapgrv.nrseqlot
               ,crapgrv.nrdconta
               ,crapgrv.nrctrpro
               ,crapgrv.idseqbem ;
    
    -- Cursor para encontrar o bem
    CURSOR cr_crapgrv_erro(pr_cdcooper IN crapgrv.cdcooper%TYPE
                          ,pr_dtenvgrv IN crapgrv.dtenvgrv%TYPE                     
                          ,pr_cdoperac IN crapgrv.cdoperac%TYPE
                          ,pr_nrseqlot IN crapgrv.nrseqlot%TYPE) IS
    SELECT crapgrv.cdcooper 
          ,crapgrv.cdoperac
          ,crapgrv.nrdconta
          ,crapgrv.dtenvgrv
          ,crapgrv.dschassi
          ,crapgrv.nrctrpro
          ,crapgrv.nrseqlot
          ,crapgrv.dtretgrv
          ,crapgrv.tpctrpro
          ,crapgrv.cdretlot
          ,crapgrv.cdretgrv
          ,crapgrv.cdretctr
          ,crapass.cdagenci
          ,crapass.inpessoa          
      FROM crapgrv
          ,crapass
     WHERE ((crapgrv.cdcooper = pr_cdcoptel AND pr_cdcoptel <> 0)
        OR  pr_cdcoptel = 0)
       AND (crapgrv.cdoperac = pr_cdoperac 
        OR  pr_cdoperac = 0)
       AND (crapgrv.nrseqlot = pr_nrseqlot 
        OR  pr_nrseqlot = 0)
       AND (crapgrv.cdretlot <> 0  OR /** Algum retorno com erro **/
           (crapgrv.cdretgrv <> 0  AND crapgrv.cdretgrv <> 30) OR
           (crapgrv.cdretctr <> 0  AND crapgrv.cdretctr <> 90) )
       AND  crapgrv.dtretgrv IS NOT NULL     /** Que tiveram retorno **/
       AND  crapgrv.dtenvgrv = pr_dtenvgrv
       AND  crapass.cdcooper = crapgrv.cdcooper
       AND  crapass.nrdconta = crapgrv.nrdconta
       ORDER BY crapgrv.cdcooper 
               ,crapgrv.cdoperac 
               ,crapgrv.nrseqlot
               ,crapgrv.nrdconta
               ,crapgrv.nrctrpro
               ,crapgrv.idseqbem ;
               
    -- Cursor para encontrar o bem
    CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE
                     ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE
                     ,pr_dschassi IN crapbpr.dschassi%TYPE) IS
    SELECT crapbpr.cdcooper
          ,crapbpr.nrdconta
          ,crapbpr.tpctrpro
          ,crapbpr.nrctrpro
          ,crapbpr.dschassi   
          ,crapbpr.nrcpfbem 
          ,crapbpr.dsbemfin   
          ,crapbpr.nrgravam         
      FROM crapbpr
     WHERE crapbpr.cdcooper = pr_cdcooper
       AND crapbpr.nrdconta = pr_nrdconta
       AND crapbpr.tpctrpro = pr_tpctrpro
       AND crapbpr.nrctrpro = pr_nrctrpro
       AND crapbpr.flgalien = 1
       AND TRIM(UPPER(pr_dschassi)) = UPPER(pr_dschassi);
    rw_crapbpr cr_crapbpr%ROWTYPE;           
               
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
    vr_comando     VARCHAR2(1000);
    vr_typ_saida   VARCHAR2(3);
        
    --Variaveis Locais   
    vr_nmdireto    VARCHAR2(100);
    vr_dstexto     VARCHAR2(32700);      
    vr_clobxml     CLOB;       
    vr_des_reto    VARCHAR2(3);      
    vr_nmarqpdf    VARCHAR2(1000);
    vr_nmarquiv    VARCHAR2(1000);
    vr_dtrefere    DATE;
    vr_cdoperac    INTEGER;
    vr_qtreglot    INTEGER :=0;
    vr_qtsemret    INTEGER :=0;
    vr_qtdregok    INTEGER :=0; 
    vr_qtregnok    INTEGER :=0;
    vr_dsoperac    VARCHAR2(20);
    vr_tparquiv    VARCHAR2(1);
    vr_dssituac    VARCHAR2(400);
    
    vr_tab_erro gene0001.typ_tab_erro;
        
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';
  
  BEGIN
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_imp_relatorio');
    
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
    
    -- Validar existencia da cooperativa informada
    IF pr_cdcoptel <> 0 THEN
      
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
        -- Continuaremos
      END IF;
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
    
    IF pr_dtrefere IS NULL THEN
      
      --Monta mensagem de critica
      vr_dscritic := 'Data de referencia invalida.';
      pr_nmdcampo := 'dtrefere';
          
      --Gera exceção
      RAISE vr_exc_erro;
        
    END IF;
    
    BEGIN                                                  
      --Realiza a conversao da data
      vr_dtrefere := to_date(pr_dtrefere,'DD/MM/RRRR'); 
                      
    EXCEPTION
      WHEN OTHERS THEN
          
        --Monta mensagem de critica
        vr_dscritic := 'Data de referencia invalida.';
        pr_nmdcampo := 'dtrefere';
          
        --Gera exceção
        RAISE vr_exc_erro;

    END;
    
    -- Validar opção informada
    IF pr_tparquiv NOT IN('TODAS','INCLUSAO','BAIXA','CANCELAMENTO') THEN
      vr_cdcritic := 0;
      vr_dscritic := ' Tipo invalido para Geracao do Arquivo! ';
      RAISE vr_exc_erro;
    END IF; 
    
    -- Buscar o codigo da operação
    CASE pr_tparquiv
      WHEN 'BAIXA'        THEN
        vr_cdoperac := 3;
      WHEN 'CANCELAMENTO' THEN
        vr_cdoperac := 2;
      WHEN 'INCLUSAO'     THEN
        vr_cdoperac := 1;
      ELSE
        vr_cdoperac := 0;
    END CASE;
       
    --Buscar Diretorio Padrao da Cooperativa
    vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                        ,pr_cdcooper => vr_cdcooper
                                        ,pr_nmsubdir => 'rl');
                                       
    --Nome do Arquivo
    vr_nmarquiv:= vr_nmdireto||'/'||'crrl670' || dbms_random.string('X',20) || '.lst';
      
    --Nome do Arquivo PDF
    vr_nmarqpdf:= REPLACE(vr_nmarquiv,'.lst','.pdf');
      
    -- Inicializar as informações do XML de dados para o relatório
    dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

    --Escrever no arquivo XML
    gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                             '<?xml version="1.0" encoding="UTF-8"?>' || 
                                '<crrl670><gravames><situacao titulo="GRAVAMES SEM RETORNO">');
                                    
    FOR rw_crapgrv_sem_retorno IN cr_crapgrv_sem_retorno(pr_cdcooper => pr_cdcoptel
                                                        ,pr_dtenvgrv => vr_dtrefere
                                                        ,pr_cdoperac => vr_cdoperac
                                                        ,pr_nrseqlot => nvl(pr_nrseqlot,0)) LOOP
       
      vr_qtreglot := vr_qtreglot + 1;
      vr_qtsemret := vr_qtsemret + 1;
      
      OPEN cr_crapbpr(pr_cdcooper => rw_crapgrv_sem_retorno.cdcooper
                     ,pr_nrdconta => rw_crapgrv_sem_retorno.nrdconta
                     ,pr_tpctrpro => rw_crapgrv_sem_retorno.tpctrpro
                     ,pr_nrctrpro => rw_crapgrv_sem_retorno.nrctrpro
                     ,pr_dschassi => TRIM(rw_crapgrv_sem_retorno.dschassi));
                  
      FETCH cr_crapbpr INTO rw_crapbpr;
      
      IF cr_crapbpr%NOTFOUND THEN
        
        --Padronização - Chamado 660394
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                     ' - '||vr_cdprogra||' --> '|| 
                                                     'ERRO: Erro na localizacao do Bem [' || 
                                                     'Cop:' || to_char(rw_crapgrv_sem_retorno.cdcooper) || 
                                                     'Cta:' || to_char(rw_crapgrv_sem_retorno.nrdconta) || 
                                                     'Tip:' || to_char(rw_crapgrv_sem_retorno.tpctrpro) || 
                                                     'Ctr:' || to_char(rw_crapgrv_sem_retorno.nrctrpro) || 
                                                     'Chassi:' || to_char(rw_crapgrv_sem_retorno.dschassi)||'][BPR_1]');  
      END IF;                  
      
      --Fechar o cursor
      CLOSE cr_crapbpr;   
      
      CASE rw_crapgrv_sem_retorno.cdoperac
        WHEN 1 THEN
          vr_dsoperac := 'INCLUSAO';
          vr_tparquiv := 'I';
        WHEN 2 THEN
          vr_dsoperac := 'CANCELAMENTO';
          vr_tparquiv := 'C';
        
        WHEN 3 THEN
          vr_dsoperac := 'BAIXA';
          vr_tparquiv := 'B';
        
      END CASE;
      
      --Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                                 '<registro>' ||
                                    '<dsoperac>' || vr_dsoperac || '</dsoperac>' ||
                                    '<cdcooper>' || TRIM(TO_CHAR(rw_crapgrv_sem_retorno.cdcooper,'000')) || '</cdcooper>' ||
                                    '<nrseqlot>' || TRIM(TO_CHAR(rw_crapgrv_sem_retorno.nrseqlot,'0000000')) || '</nrseqlot>' ||
                                    '<nrdconta>' || TRIM(gene0002.fn_mask(rw_crapgrv_sem_retorno.nrdconta,'zzzz.zzz.z'))  || '</nrdconta>' ||
                                    '<nrcpfcgc>' || TRIM(gene0002.fn_mask(rw_crapbpr.nrcpfbem,'zzz99999999999')) || '</nrcpfcgc>' ||
                                    '<cdagenci>' || TRIM(TO_CHAR(rw_crapgrv_sem_retorno.cdagenci,'000')) || '</cdagenci>' ||
                                    '<nrctrpro>' || TO_CHAR(rw_crapgrv_sem_retorno.nrctrpro,'fm99G999G990') || '</nrctrpro>' ||
                                    '<dtenvgrv>' || TO_CHAR(rw_crapgrv_sem_retorno.dtenvgrv,'dd/mm/RRRR') || '</dtenvgrv>' ||
                                    '<dtretgrv>' || TO_CHAR(rw_crapgrv_sem_retorno.dtretgrv,'dd/mm/RRRR') || '</dtretgrv>' ||
                                    '<dsbemfin>' || rw_crapbpr.dsbemfin || '</dsbemfin>' ||
                                    '<dssituac>' || 'SEM ARQUIVO DE RETORNO - GRAVAMES' || '</dssituac>' ||
                                 '</registro>');                            
                                
    END LOOP;           
          
    --Escrever no arquivo XML
    gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</situacao><situacao titulo="GRAVAMES IMPORTADOS COM SUCESSO">');
    
    FOR rw_crapgrv_sucesso IN cr_crapgrv_sucesso(pr_cdcooper => pr_cdcoptel
                                                ,pr_dtenvgrv => vr_dtrefere
                                                ,pr_cdoperac => vr_cdoperac
                                                ,pr_nrseqlot => nvl(pr_nrseqlot,0)) LOOP
       
      vr_qtreglot := vr_qtreglot + 1;
      vr_qtdregok := vr_qtdregok + 1;
      
      OPEN cr_crapbpr(pr_cdcooper => rw_crapgrv_sucesso.cdcooper
                     ,pr_nrdconta => rw_crapgrv_sucesso.nrdconta
                     ,pr_tpctrpro => rw_crapgrv_sucesso.tpctrpro
                     ,pr_nrctrpro => rw_crapgrv_sucesso.nrctrpro
                     ,pr_dschassi => TRIM(rw_crapgrv_sucesso.dschassi));
                  
      FETCH cr_crapbpr INTO rw_crapbpr;
      
      IF cr_crapbpr%NOTFOUND THEN
        
        --Padronização - Chamado 660394
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                      'ERRO: Erro na localizacao do Bem [' ||
                                                      'Cop:' || to_char(rw_crapgrv_sucesso.cdcooper) || 
                                                      'Cta:' || to_char(rw_crapgrv_sucesso.nrdconta) || 
                                                      'Tip:' || to_char(rw_crapgrv_sucesso.tpctrpro) || 
                                                      'Ctr:' || to_char(rw_crapgrv_sucesso.nrctrpro) || 
                                                      'Chassi:' || to_char(rw_crapgrv_sucesso.dschassi)||'][BPR_2]');  
          
      END IF;                   
      
      --Fechar o cursor
      CLOSE cr_crapbpr;   
      
      CASE rw_crapgrv_sucesso.cdoperac
        WHEN 1 THEN
          vr_dsoperac := 'INCLUSAO';
          vr_tparquiv := 'I';
          
        WHEN 2 THEN
          vr_dsoperac := 'CANCELAMENTO';
          vr_tparquiv := 'C';
          
        WHEN 3 THEN
          vr_dsoperac := 'BAIXA';
          vr_tparquiv := 'B';
          
      END CASE;
      
      vr_dssituac := vr_dsoperac || ' - SUCESSO! Nr. Registro: ' || trim(to_char(rw_crapbpr.nrgravam)); 
      
      --Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                                 '<registro>' ||
                                    '<dsoperac>' || vr_dsoperac || '</dsoperac>' ||
                                    '<cdcooper>' || TRIM(TO_CHAR(rw_crapgrv_sucesso.cdcooper,'000')) || '</cdcooper>' ||
                                    '<nrseqlot>' || TRIM(TO_CHAR(rw_crapgrv_sucesso.nrseqlot,'0000000')) || '</nrseqlot>' ||
                                    '<nrdconta>' || TRIM(gene0002.fn_mask(rw_crapgrv_sucesso.nrdconta,'zzzz.zzz.z'))  || '</nrdconta>' ||
                                    '<nrcpfcgc>' || TRIM(gene0002.fn_mask(rw_crapbpr.nrcpfbem,'zzz99999999999')) || '</nrcpfcgc>' ||
                                    '<cdagenci>' || TRIM(TO_CHAR(rw_crapgrv_sucesso.cdagenci,'000')) || '</cdagenci>' ||
                                    '<nrctrpro>' || TO_CHAR(rw_crapgrv_sucesso.nrctrpro,'fm99G999G990') || '</nrctrpro>' ||
                                    '<dtenvgrv>' || TO_CHAR(rw_crapgrv_sucesso.dtenvgrv,'dd/mm/RRRR') || '</dtenvgrv>' ||
                                    '<dtretgrv>' || TO_CHAR(rw_crapgrv_sucesso.dtretgrv,'dd/mm/RRRR') || '</dtretgrv>' ||
                                    '<dsbemfin>' || rw_crapbpr.dsbemfin || '</dsbemfin>' ||
                                    '<dssituac>' || vr_dsoperac || ' - SUCESSO! Nr. Registro: ' || rw_crapbpr.nrgravam || '</dssituac>' ||
                                 '</registro>');                            
                                
    END LOOP;           
    
    --Escrever no arquivo XML
    gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</situacao><situacao titulo="GRAVAMES IMPORTADOS COM ERROS">');
     
    
    FOR rw_crapgrv_erro IN cr_crapgrv_erro(pr_cdcooper => pr_cdcoptel
                                          ,pr_dtenvgrv => vr_dtrefere
                                          ,pr_cdoperac => vr_cdoperac
                                          ,pr_nrseqlot => nvl(pr_nrseqlot,0)) LOOP
       
      vr_qtreglot := vr_qtreglot + 1;
      vr_qtregnok := vr_qtregnok + 1;
      
      OPEN cr_crapbpr(pr_cdcooper => rw_crapgrv_erro.cdcooper
                     ,pr_nrdconta => rw_crapgrv_erro.nrdconta
                     ,pr_tpctrpro => rw_crapgrv_erro.tpctrpro
                     ,pr_nrctrpro => rw_crapgrv_erro.nrctrpro
                     ,pr_dschassi => TRIM(rw_crapgrv_erro.dschassi));
                  
      FETCH cr_crapbpr INTO rw_crapbpr;
      
      IF cr_crapbpr%NOTFOUND THEN
        
        --Padronização - Chamado 660394
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra||' --> '|| 
                                                      'ERRO: Erro na localizacao do Bem [' ||
                                                      'Cop:' || to_char(rw_crapgrv_erro.cdcooper) || 
                                                      'Cta:' || to_char(rw_crapgrv_erro.nrdconta) || 
                                                      'Tip:' || to_char(rw_crapgrv_erro.tpctrpro) || 
                                                      'Ctr:' || to_char(rw_crapgrv_erro.nrctrpro) || 
                                                      'Chassi:' || to_char(rw_crapgrv_erro.dschassi)||'][BPR_3]');          
      END IF;                  
      
      --Fechar o cursor
      CLOSE cr_crapbpr;   
      
      CASE rw_crapgrv_erro.cdoperac
        WHEN 1 THEN
          vr_dsoperac := 'INCLUSAO';
          vr_tparquiv := 'I';
          
        WHEN 2 THEN
          vr_dsoperac := 'CANCELAMENTO';
          vr_tparquiv := 'C';
          
        WHEN 3 THEN
          vr_dsoperac := 'BAIXA';
           /*** Para retornos, foi utilizada a letra "Q" e nao letra "B" ********/
          vr_tparquiv := 'Q';
          
      END CASE;
      
      vr_dssituac := '';
      
      /** Exibir todos os retornos com erros **/
      IF rw_crapgrv_erro.cdretlot <> 0 THEN
        
        OPEN cr_craprto(pr_cdoperac => vr_tparquiv
                       ,pr_nrtabela => 1
                       ,pr_cdretorn => rw_crapgrv_erro.cdretlot);
        
        FETCH cr_craprto INTO rw_craprto;
        
        IF cr_craprto%NOTFOUND THEN
          vr_dssituac := 'LOT: ' || trim(to_char(rw_crapgrv_erro.cdretlot,'999')) || ' - SITUACAO NAO CADASTRADA';
        ELSE
          vr_dssituac := 'LOT: ' || trim(to_char(rw_craprto.cdretorn,'999')) || ' - ' || rw_craprto.dsretorn;
        END IF;
        
        --Fecha o cursor
        CLOSE cr_craprto;
               
      END IF;
      
      IF rw_crapgrv_erro.cdretlot = 0  AND
        (rw_crapgrv_erro.cdretgrv <> 0 AND
         rw_crapgrv_erro.cdretgrv <> 30) THEN
        
        OPEN cr_craprto(pr_cdoperac => vr_tparquiv
                       ,pr_nrtabela => 2
                       ,pr_cdretorn => rw_crapgrv_erro.cdretgrv);
        
        FETCH cr_craprto INTO rw_craprto;
        
        IF trim(vr_dssituac) IS NOT null THEN
          vr_dssituac := vr_dssituac || ' / ';  
        END IF;
                
        IF cr_craprto%NOTFOUND THEN
          vr_dssituac := vr_dssituac || 'GRV: ' || trim(to_char(rw_crapgrv_erro.cdretgrv,'999')) || ' - SITUACAO NAO CADASTRADA';
        ELSE
          IF rw_crapgrv_erro.cdretctr <> 0 AND 
             rw_crapgrv_erro.cdretctr <> 90 THEN
            vr_dssituac := vr_dssituac || 'GRV: ' || trim(to_char(rw_craprto.cdretorn,'999')) || ' - ' || trim(substr(rw_craprto.dsretorn,1,40));
          ELSE
            vr_dssituac := vr_dssituac || 'GRV: ' || trim(to_char(rw_craprto.cdretorn,'999')) || ' - ' || rw_craprto.dsretorn;
          END IF;
          
        END IF;
        
        --Fecha o cursor
        CLOSE cr_craprto;
               
      END IF;
      
      IF rw_crapgrv_erro.cdretlot = 0  AND
        (rw_crapgrv_erro.cdretctr <> 0 AND
         rw_crapgrv_erro.cdretctr <> 90) THEN
        
        OPEN cr_craprto(pr_cdoperac => vr_tparquiv
                       ,pr_nrtabela => 3
                       ,pr_cdretorn => rw_crapgrv_erro.cdretctr);
        
        FETCH cr_craprto INTO rw_craprto;
        
        IF trim(vr_dssituac) IS NOT null THEN
          vr_dssituac := vr_dssituac || ' / ';  
        END IF;
                
        IF cr_craprto%NOTFOUND THEN
          vr_dssituac := vr_dssituac || 'CTR: ' || trim(to_char(rw_crapgrv_erro.cdretctr,'999')) || ' - SITUACAO NAO CADASTRADA';
        ELSE
          IF rw_crapgrv_erro.cdretgrv <> 0 AND 
             rw_crapgrv_erro.cdretgrv <> 30 THEN
            vr_dssituac := vr_dssituac || 'CTR: ' || trim(to_char(rw_craprto.cdretorn,'999')) || ' - ' || trim(substr(rw_craprto.dsretorn,1,40));
          ELSE
            vr_dssituac := vr_dssituac || 'CTR: ' || trim(to_char(rw_craprto.cdretorn,'999')) || ' - ' || rw_craprto.dsretorn;
          END IF;
          
        END IF;
        
        --Fecha o cursor
        CLOSE cr_craprto;
               
      END IF;
     
      --Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                                 '<registro>' ||
                                    '<dsoperac>' || vr_dsoperac || '</dsoperac>' ||
                                    '<cdcooper>' || TRIM(TO_CHAR(rw_crapgrv_erro.cdcooper,'000')) || '</cdcooper>' ||
                                    '<nrseqlot>' || TRIM(TO_CHAR(rw_crapgrv_erro.nrseqlot,'0000000')) || '</nrseqlot>' ||
                                    '<nrdconta>' || TRIM(gene0002.fn_mask(rw_crapgrv_erro.nrdconta,'zzzz.zzz.z'))  || '</nrdconta>' ||
                                    '<nrcpfcgc>' || TRIM(gene0002.fn_mask(rw_crapbpr.nrcpfbem,'zzz99999999999')) || '</nrcpfcgc>' ||
                                    '<cdagenci>' || TRIM(TO_CHAR(rw_crapgrv_erro.cdagenci,'000')) || '</cdagenci>' ||
                                    '<nrctrpro>' || TO_CHAR(rw_crapgrv_erro.nrctrpro,'fm99G999G990') || '</nrctrpro>' ||
                                    '<dtenvgrv>' || TO_CHAR(rw_crapgrv_erro.dtenvgrv,'dd/mm/RRRR') || '</dtenvgrv>' ||
                                    '<dtretgrv>' || TO_CHAR(rw_crapgrv_erro.dtretgrv,'dd/mm/RRRR') || '</dtretgrv>' ||
                                    '<dsbemfin>' || rw_crapbpr.dsbemfin || '</dsbemfin>' ||
                                    '<dssituac>' || vr_dssituac || '</dssituac>' ||
                                 '</registro>');                            
                                
    END LOOP;           
          
    --Escrever no arquivo XML
    gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</situacao>' ||
                                                  ' </gravames>' ||
                                                  '<sumario>' ||
                                                     '<qtreglot>' || vr_qtreglot || '</qtreglot>' ||
                                                     '<qtsemret>' || vr_qtsemret || '</qtsemret>' ||
                                                     '<qtdregok>' || vr_qtdregok || '</qtdregok>' ||
                                                     '<qtregnok>' || vr_qtregnok || '</qtregnok>' ||
                                                  '</sumario>');
    
    
    --Finaliza TAG Relatorio
    gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</crrl670>',TRUE); 
   
    -- Gera relatório crrl657
    gene0002.pc_solicita_relato(pr_cdcooper    => vr_cdcooper    --> Cooperativa conectada
                                 ,pr_cdprogra  => 'GRAVAM'--vr_nmdatela         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl670/gravames/situacao/registro' --> Nó base do XML para leitura dos dados                                  
                                 ,pr_dsjasper  => 'crrl670.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nmarqpdf         --> Arquivo final com o path
                                 ,pr_qtcoluna  => 234                  --> Colunas do relatorio
                                 ,pr_flg_gerar => 'S'                 --> Geraçao na hora
                                 ,pr_cdrelato  => '670'               --> Códigod do relatório
                                 ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p) 
                                 ,pr_nmformul  => '234col'            --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                   --> Número de cópias
                                 ,pr_sqcabrel  => 1                   --> Qual a seq do cabrel                                                                          
                                 ,pr_des_erro  => vr_dscritic);       --> Saída com erro

    --Se ocorreu erro no relatorio
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF; 

    --Fechar Clob e Liberar Memoria  
    dbms_lob.close(vr_clobxml);
    dbms_lob.freetemporary(vr_clobxml);  
      
     --Efetuar Copia do PDF
    gene0002.pc_efetua_copia_pdf (pr_cdcooper => vr_cdcooper     --> Cooperativa conectada
                                 ,pr_cdagenci => vr_cdagenci     --> Codigo da agencia para erros
                                 ,pr_nrdcaixa => vr_nrdcaixa     --> Codigo do caixa para erros
                                 ,pr_nmarqpdf => vr_nmarqpdf     --> Arquivo PDF  a ser gerado                                 
                                 ,pr_des_reto => vr_des_reto     --> Saída com erro
                                 ,pr_tab_erro => vr_tab_erro);   --> tabela de erros 
                                   
    --Se ocorreu erro
    IF vr_des_reto = 'NOK' THEN
        
      --Se possui erro
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel efetuar a copia do relatorio.';
      END IF;
        
      --Levantar Excecao  
      RAISE vr_exc_erro;
        
    END IF; 

        
    --Se Existir arquivo pdf  
    IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmarqpdf) THEN
        
      --Remover arquivo
      vr_comando:= 'rm '||vr_nmarqpdf||' 2>/dev/null';
        
      --Executar o comando no unix
      GENE0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => vr_comando
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_dscritic);
                          
      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
          
        --Monta mensagem de critica
        vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
          
        -- retornando ao programa chamador
        RAISE vr_exc_erro;
          
      END IF;
        
    END IF;
        
    --Se ocorreu erro
    IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN                                   
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    --Retornar nome arquivo impressao e pdf
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
            
    -- Insere atributo na tag Dados com o valor total de agendamentos
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Dados'             --> Nome da TAG XML
                             ,pr_atrib => 'nmarquiv'          --> Nome do atributo
                             ,pr_atval => substr(vr_nmarqpdf,instr(vr_nmarqpdf,'/',-1)+1)         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros 
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
                                                    'ALERTA: '|| pr_dscritic ||
                                                    ',Cdcooper:'||vr_cdcooper||',Dtrefere:'||pr_dtrefere||
                                                    ',Cdcoptel:'||pr_cdcoptel||',Nrseqlot:'||pr_nrseqlot||
                                                    ',Tparquiv:'||pr_tparquiv||',Cddopcao:'||pr_cddopcao);
                 
                                           
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gravames_imp_relatorio --> '|| SQLERRM;
        
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
                                                    'ERRO: '|| pr_dscritic ||
                                                    ',Cdcooper:'||vr_cdcooper||',Dtrefere:'||pr_dtrefere||
                                                    ',Cdcoptel:'||pr_cdcoptel||',Nrseqlot:'||pr_nrseqlot||
                                                    ',Tparquiv:'||pr_tparquiv||',Cddopcao:'||pr_cddopcao);

      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
        
  END pc_gravames_imp_relatorio;  

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
        
      CURSOR cr_crapgrv(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrseqlot IN crapgrv.nrseqlot%TYPE
                       ,pr_cdoperac IN crapgrv.cdoperac%TYPE
                       ,pr_dschassi IN crapgrv.dschassi%TYPE) IS
      SELECT crapgrv.rowid rowid_grv
            ,crapgrv.cdcooper
            ,crapgrv.nrdconta
            ,crapgrv.tpctrpro
            ,crapgrv.nrctrpro
            ,crapgrv.dschassi
       FROM crapgrv
      WHERE crapgrv.cdcooper = pr_cdcooper
        AND crapgrv.nrseqlot = pr_nrseqlot
        AND crapgrv.cdoperac = pr_cdoperac
        AND TRIM(UPPER(crapgrv.dschassi)) = UPPER(pr_dschassi);
      rw_crapgrv cr_crapgrv%ROWTYPE;
      
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
			vr_dsplsql  VARCHAR2(4000);
			vr_jobname  VARCHAR2(30);

    
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
                          ,crapgrv.dtretgrv = pr_dtmvtolt
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
                         SET crapgrv.dtretgrv = pr_dtmvtolt
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
                         SET crapgrv.dtretgrv = pr_dtmvtolt
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
              
				-- Montar o bloco PLSQL que sera executado,
				-- ou seja, executaremos a geracao dos dados
				-- para a agencia atual atraves de Job no banco
				vr_dsplsql := 'DECLARE' || chr(13)
									 || '  vr_cdcritic NUMBER;' || chr(13)
									 || '  vr_dscritic VARCHAR2(4000);' || chr(13)
									 || 'BEGIN' || chr(13)
									 || '  GRVM0001.pc_envia_retorno_gravames('|| to_char(vr_cdcooper) ||
		                                 ','|| to_char(pr_dtmvtolt) ||
																		 ','|| to_char(vr_nrseqlot) ||
																		 ',vr_cdcritic ,vr_dscritic);' || chr(13)
									 || 'END;';

				-- Montar o prefixo do codigo do programa para o jobname
				vr_jobname := 'grv_proc_ret_' || to_char(vr_nrseqlot) || '$';

				-- Faz a chamada ao programa paralelo atraves de JOB
				GENE0001.pc_submit_job(pr_cdcooper  => pr_cdcooper  --> Codigo da cooperativa
															,pr_cdprogra  => vr_cdprogra  --> Codigo do programa
															,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
															,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
															,pr_interva   => NULL         --> Sem intervalo de execucao da fila, ou seja, apenas 1 vez
															,pr_jobname   => vr_jobname   --> Nome randomico criado
															,pr_des_erro  => vr_dscritic);
				-- Se houve erro
				IF trim(vr_dscritic) IS NOT NULL THEN
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
  

END GRVM0001;
/
