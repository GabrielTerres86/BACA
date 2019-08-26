CREATE OR REPLACE PACKAGE CECRED.FOLH0001 AS
 
/*..............................................................................

   Programa: FOLH0001                        Antigo: Não há
   Sistema : Cred
   Sigla   : CRED
   Autor   : Renato Darosci - Supero
   Data    : Maio/2015                      Ultima atualizacao: 05/07/2018

   Dados referentes ao programa:

   Frequencia: -------------------
   Objetivo  : Centralizar as rotinas referente ao Serviço Folha de Pagamento

   Alteracoes: 07/06/2016 - Melhoria 195 folha de pagamento (Tiago/Thiago)
  
               05/07/2018 - Inclusao das tags de cdtarifa e cdfaixav no XML de saída
                            da procedure: pc_consulta_arq_folha_ib e da função: fn_cdtarifa_cdfaixav,
                            Prj.363 (Jean Michel).           
  
..............................................................................*/

  /* Procedure responsável por retornar a hora, em formato texto, do inicio e fim do horário de transações  */
  PROCEDURE pc_hrtransfer_internet(pr_cdcooper    IN craptab.cdcooper%TYPE
                                  ,pr_hrtrfini   OUT VARCHAR2     -- Formato de retorno HH24:MI
                                  ,pr_hrtrffim   OUT VARCHAR2);   -- Formato de retorno HH24:MI

  /* Função para validar se a hora informada está no range do inicio e fim do horário de 
  transações e retorna os dois valores de hora inicio e fim */
  FUNCTION fn_valida_hrtransfer(pr_cdcooper    IN craptab.cdcooper%TYPE
                               ,pr_hrvalida    IN DATE DEFAULT SYSDATE -- Critica
                               ,pr_hrtrfini   OUT VARCHAR2
                               ,pr_hrtrffim   OUT VARCHAR2) RETURN BOOLEAN;

  /* Função para validar se a hora informada está no range do inicio e fim do horário de transações */
  FUNCTION fn_valida_hrtransfer(pr_cdcooper    IN craptab.cdcooper%TYPE
                               ,pr_hrvalida    IN DATE DEFAULT SYSDATE) RETURN BOOLEAN;
                               
  -- Função para optimizar a busca do valor da tarifa de Folha conforme opção Debito
  FUNCTION fn_valor_tarifa_folha(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta
                                ,pr_cdcontar IN crapcfp.cdcontar%TYPE --> Convênio
                                ,pr_idopdebi IN crappfp.idopdebi%TYPE --> Opção Debito (D0, D-1 e D-2)
                                ,pr_vllanmto IN crappfp.vllctpag%TYPE --> Valor do lançamento
                                ,pr_cdprogra IN crapprg.cdprogra%TYPE DEFAULT 'FOLH0001') --> Programa chamador
                                RETURN NUMBER;

  -- Função para optimizar a busca do histórico da tarifa de Folha conforme opção Debito
  FUNCTION fn_histor_tarifa_folha(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                 ,pr_cdcontar IN crapcfp.cdcontar%TYPE --> Convênio 
                                 ,pr_idopdebi IN crappfp.idopdebi%TYPE --> Opção Debito (D0, D-1 e D-2)
                                 ,pr_vllanmto IN crappfp.vllctpag%TYPE --> Valor do lançamento
                                 ,pr_cdprogra IN crapprg.cdprogra%TYPE DEFAULT 'FOLH0001') --> Programa chamador
                                 RETURN craphis.cdhistor%TYPE;
  
  -- Função para retornar código de tarifa e faixa da tarifa
  FUNCTION fn_cdtarifa_cdfaixav(pr_cdocorre IN craptar.cdocorre%TYPE --> Contem o codigo da ocorrencia.
                               )RETURN VARCHAR2;
  
  -- Função para centralizar a montagem do nome do operador ou preposto para log
  FUNCTION fn_nmoperad_log(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                          ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta conectada
                          ,pr_nrcpfope IN crapopi.nrcpfope%TYPE) RETURN VARCHAR2;

  -- Função para traduzir o código de opção debito para texto
  FUNCTION fn_nmopdebi_log(pr_idopdebi IN crappfp.idopdebi%TYPE) RETURN VARCHAR2;
  
  -- Função para traduzir a origem de salário
  FUNCTION fn_dsorigem_log(pr_cdcooper IN crapofp.cdcooper%TYPE
                          ,pr_cdorigem IN crapofp.cdorigem%TYPE) RETURN VARCHAR2;

  -- Função para centralizar a montagem do nome do operador ou preposto para log
  FUNCTION fn_tpconta_log(pr_idtpconta IN craplfp.idtpcont%TYPE) RETURN VARCHAR2;                        
                                 
  /* Procedure de Reprovacao automatica de estouros fora do horario */
  PROCEDURE pc_reprov_estouro_horario(pr_cdcooper IN crapcop.cdcooper%TYPE);
 
  /* Procedure para realizar o alerta e/ou cancelamento automático de empresas sem uso */
  PROCEDURE pc_aviso_cancel_emp_sem_uso(pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_nmrescop IN crapcop.nmrescop%TYPE);  
    
  /* Aprova automaticamente os estouros com regularização do saldo */
  PROCEDURE pc_aprova_estouros_automatico (pr_cdcooper IN crapcop.cdcooper%TYPE
                                          ,pr_rw_crapdat IN BTCH0001.CR_CRAPDAT%ROWTYPE);
  
  /* Alerta créditos pendentes após portabilidade */
  PROCEDURE pc_alerta_creditos_pendentes (pr_cdcooper IN crapcop.cdcooper%TYPE
                                         ,pr_rw_crapdat IN BTCH0001.CR_CRAPDAT%ROWTYPE);
  
  /* Alerta transferências pendentes de retorno do SPB  */
  PROCEDURE pc_alerta_transf_penden_spb (pr_cdcooper IN crapcop.cdcooper%TYPE
                                        ,pr_rw_crapdat IN BTCH0001.CR_CRAPDAT%ROWTYPE);

  /* Busca todos os pagamentos já creditados e com pendência de estorno. */
  PROCEDURE pc_concili_estornos_pendentes (pr_cdcooper IN crapcop.cdcooper%TYPE
                                          ,pr_rw_crapdat IN BTCH0001.CR_CRAPDAT%ROWTYPE);
  
  /* Realiza o Processamento de débitos dos pagamentos aprovados */
  PROCEDURE pc_debito_pagto_aprovados (pr_cdcooper IN craptab.cdcooper%TYPE
                                      ,pr_rw_crapdat IN BTCH0001.CR_CRAPDAT%ROWTYPE);

  /* Procedure para realizar processamento de credito dos pagamentos aprovados */
/*  PROCEDURE pc_credito_pagto_aprovados(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                      ,pr_rw_crapdat IN BTCH0001.cr_crapdat%ROWTYPE);*/

  /* Procedure para realizar processamento de credito dos pagamentos aprovados da cooperativa */                                      
  PROCEDURE pc_cr_pagto_aprovados_coop(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                      ,pr_rw_crapdat IN BTCH0001.cr_crapdat%ROWTYPE);

  /* Procedure para realizar processamento de credito dos pagamentos aprovados de portabilidade */                                      
  PROCEDURE pc_cr_pagto_aprovados_ctasal(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                        ,pr_rw_crapdat IN BTCH0001.cr_crapdat%ROWTYPE);                                                                              

  /* Busca todos os pagamentos já creditados mas não tarifados ainda para tarifar */
  PROCEDURE pc_cobra_tarifas_pendentes (pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_rw_crapdat IN BTCH0001.CR_CRAPDAT%ROWTYPE);

  /* Lançar tarifas folha direto na conta */
  PROCEDURE pc_cria_tarifa_folha(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                ,pr_nrdconta  IN crapass.nrdconta%TYPE
                                ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                ,pr_flgestor  IN NUMBER -- Se é estorno ou nao
                                ,pr_indrowid  IN VARCHAR2
                                ,pr_dscritic OUT VARCHAR2);

  /* Devolver TECs com rejeição e que não foram reprocessadas no mesmo dia.
     ou foram recusadas pelas Instituições Financeiras */
  PROCEDURE pc_estorno_automati_rejeicoes (pr_cdcooper IN crapcop.cdcooper%TYPE
                                          ,pr_rw_crapdat IN BTCH0001.CR_CRAPDAT%ROWTYPE);
	
  /* Procedure para realizar processamento de credito dos pagamentos aprovados */
  PROCEDURE pc_atualiza_xml_comprov_liquid(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                          ,pr_rw_crapdat IN BTCH0001.cr_crapdat%ROWTYPE);
  
  /* Esta rotina é acionada diretamente pelo Job */
  PROCEDURE pc_processo_controlador;
  
  -- Validar a combinação Conta + CPF
  PROCEDURE pc_valida_lancto_folha(pr_cdcooper  IN     crapass.cdcooper%TYPE --> Cooperativa
                                  ,pr_nrdconta  IN     crapass.nrdconta%TYPE --> Conta
                                  ,pr_nrcpfcgc  IN     crapass.nrcpfcgc%TYPE --> CPF
                                  ,pr_dtcredit  IN     DATE                  --> Data Credito
                                  ,pr_idtpcont  IN OUT VARCHAR2              --> Tipo (C-Conta ou T-CTASAL)
                                  ,pr_nmprimtl     OUT VARCHAR2              --> Nome 
                                  ,pr_dsalerta     OUT VARCHAR2              --> Retornar alertas de validação
                                  ,pr_dscritic     OUT VARCHAR2);            --> Retornar erros da rotina
  
  /* Rotina para a validação do arquivo de folha - Através do AyllosWeb */
  PROCEDURE pc_valida_arq_folha_web(pr_nrdconta   IN NUMBER              --> Número da conta 
                                   ,pr_dsarquiv   IN VARCHAR2            --> Informações do arquivo
                                   ,pr_dsdireto   IN VARCHAR2            --> Informações do diretório do arquivo 
                                   ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);
  
  /* Rotina para a validação do arquivo de folha - Através do IB */
  PROCEDURE pc_valida_arq_folha_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                  ,pr_idorigem  IN NUMBER
                                  ,pr_nrdconta  IN NUMBER
                                  ,pr_dsarquiv  IN VARCHAR2
                                  ,pr_dsdireto  IN VARCHAR2
                                  ,pr_dssessao  IN VARCHAR2 -- Passar NULL quando origem for diferente de 3 - Internet Banking
                                  ,pr_dtcredit  IN VARCHAR2
                                  ,pr_iddspscp  IN NUMBER                                  
                                  ,pr_dscritic  OUT VARCHAR2
                                  ,pr_retxml    OUT CLOB);
  
  /* Rotina para a validação do arquivo de folha - Através do AyllosWeb */
  PROCEDURE pc_valida_arq_compr_web(pr_nrdconta   IN NUMBER              --> Número da conta 
                                   ,pr_dsarquiv   IN VARCHAR2            --> Informações do arquivo
                                   ,pr_dsdireto   IN VARCHAR2            --> Informações do diretório do arquivo 
                                   ,pr_nrseqpag   IN NUMBER              --> Número da sequencia do pagamento selecionado em tela
                                   ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);
 
 /* Rotina para a validação do arquivo de comprovantes de folha */
  PROCEDURE pc_valida_arq_compr_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                  ,pr_idorigem  IN NUMBER
                                  ,pr_nrdconta  IN NUMBER
                                  ,pr_nrseqpag  IN NUMBER
                                  ,pr_dsarquiv  IN VARCHAR2
                                  ,pr_dsdireto  IN VARCHAR2
                                  ,pr_iddspscp  IN NUMBER                                  
                                  ,pr_dscritic  OUT VARCHAR2
                                  ,pr_retxml    OUT CLOB);          --> Erros do processo
  
  /* Rotina para gravar os dados do arquivo  */
  PROCEDURE pc_gravar_arq_folha_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta  IN NUMBER
                                  ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE
                                  ,pr_dsrowpfp  IN VARCHAR2
                                  ,pr_idopdebi  IN NUMBER
                                  ,pr_dtcredit  IN DATE
                                  ,pr_dtdebito  IN DATE
                                  ,pr_vltararp  IN NUMBER
                                  ,pr_nmarquiv  IN VARCHAR2
                                  ,pr_dscritic  OUT VARCHAR2
                                  ,pr_retxml    OUT CLOB);
  
  -- Procedure para atualizar as informações da tela de envio de comprovantes do IB
  PROCEDURE pc_insere_compr_folha(pr_cdcooper IN craplfp.cdcooper%TYPE --> Cooperativa conectada
                                 ,pr_cdempres IN craplfp.cdempres%TYPE --> Empresa conectada
                                 ,pr_nrcpfope IN crapopi.nrcpfope%TYPE --> CPF do operador conectado
                                 ,pr_nrseqpag IN craplfp.nrseqpag%TYPE --> Sequencia do pagamento selecionado
                                 ,pr_dtrefere IN craplfp.dtrefenv%TYPE --> Data de referência
                                 ,pr_dsarquiv IN VARCHAR2              --> Nome do arquivo com os comprovantes
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Erros do processo
                                 ,pr_dscritic OUT VARCHAR2);           --> Erros do processo
  
  /* Rotina para gravar os dados do arquivo  */
  PROCEDURE pc_consulta_arq_folha_ib(pr_dsrowpfp  IN VARCHAR2
                                    ,pr_dscritic  OUT VARCHAR2
                                    ,pr_retxml    OUT CLOB);
  
  /* Verifica se recebe salario */ 
  PROCEDURE pc_busca_sit_salario(pr_nrdconta IN crapass.nrdconta%TYPE
                                ,pr_xmllog   IN VARCHAR2             --> XML com informac?es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER         --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2            --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2            --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);    
                                
  PROCEDURE pc_busca_rendas_aut(pr_nrdconta IN crapass.nrdconta%TYPE                               
                               ,pr_xmllog   IN VARCHAR2             --> XML com informac?es de LOG
                               ,pr_cdcritic OUT PLS_INTEGER         --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2            --> Descricao da critica
                               ,pr_retxml   IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2            --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);
                               
  PROCEDURE pc_inserir_lanaut(pr_cdcooper IN  tbfolha_lanaut.cdcooper%TYPE
                             ,pr_nrdconta IN  tbfolha_lanaut.nrdconta%TYPE
                             ,pr_dtmvtolt IN  tbfolha_lanaut.dtmvtolt%TYPE
                             ,pr_cdhistor IN  tbfolha_lanaut.cdhistor%TYPE
                             ,pr_vlrenda  IN  tbfolha_lanaut.vlrenda%TYPE
                             ,pr_cdagenci IN  tbfolha_lanaut.cdagenci%TYPE                             
                             ,pr_cdbccxlt IN  tbfolha_lanaut.cdbccxlt%TYPE
                             ,pr_nrdolote IN  tbfolha_lanaut.nrdolote%TYPE
                             ,pr_nrseqdig IN  tbfolha_lanaut.nrseqdig%TYPE
                             ,pr_dscritic OUT crapcri.dscritic%TYPE);
                             
  PROCEDURE pc_excluir_lanaut(pr_cdcooper IN  tbfolha_lanaut.cdcooper%TYPE                                   
                             ,pr_dtmvtolt IN  tbfolha_lanaut.dtmvtolt%TYPE
                             ,pr_cdagenci IN  tbfolha_lanaut.cdagenci%TYPE
                             ,pr_nrdconta IN  tbfolha_lanaut.nrdconta%TYPE
							 ,pr_cdhistor IN  tbfolha_lanaut.cdhistor%TYPE
                             ,pr_cdbccxlt IN  tbfolha_lanaut.cdbccxlt%TYPE
                             ,pr_nrdolote IN  tbfolha_lanaut.nrdolote%TYPE
                             ,pr_nrseqdig IN  tbfolha_lanaut.nrseqdig%TYPE
                             ,pr_dscritic OUT crapcri.dscritic%TYPE);  
                             
  PROCEDURE pc_excluir_lanaut_dia(pr_cdcooper IN  tbfolha_lanaut.cdcooper%TYPE                                   
                                 ,pr_dtmvtolt IN  tbfolha_lanaut.dtmvtolt%TYPE
                                 ,pr_cdhistor IN  tbfolha_lanaut.cdhistor%TYPE
                                 ,pr_dscritic OUT crapcri.dscritic%TYPE);                                                        
  
  FUNCTION fn_valida_hrportabil(pr_cdcooper    IN craptab.cdcooper%TYPE
                               ,pr_hrvalida    IN DATE DEFAULT SYSDATE) RETURN BOOLEAN;
END FOLH0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.FOLH0001 AS

  /*..............................................................................

   Programa: FOLH0001                        Antigo: Nao ha
   Sistema : Ayllos
   Sigla   : CRED
   Autor   : Renato Darosci - Supero
   Data    : Maio/2015                      Ultima atualizacao: 20/08/2018

   Dados referentes ao programa:

   Frequencia: -------------------
   Objetivo  : Centralizar as rotinas referente ao Serviço Folha de Pagamento

   Alteracoes: 15/02/2016 - Inclusao do parametro conta na chamada da
                            TARI0001.pc_carrega_dados_tarifa_cobr. (Jaison/Marcos)
                            
               07/06/2016 - Melhoria 195 folha de pagamento (Tiago/Thiago).
               
               20/09/2016 - #523941 Criação de log de controle de início, erros e fim de execução
                            do job pc_processo_controlador (Carlos)
               
               12/05/2017 - Segunda fase da melhoria 342 (Kelvin).
               
               24/08/2017 - Fechar cursor cr_crapofp caso ele ja esteja aberto
                            na procedure pc_valida_arq_folha_ib (Lucas Ranghetti #729039)

               29/09/2017 - Correção para não processar o débito e crédito quando folha
                            na situação 6 - Transação Pendente. Proj. 397
                            Rafael (Mouts)

               07/11/2017 - #756218 Na rotina pc_processo_controlador, melhorado o tratamento de
                            erros, retirando logs que não acrescentavam detalhe algum e cadastro
                            de mensagem de log (prglog_ocorrencia) em duplicidade (Carlos)
					
               18/06/2018 - sctask0012758 Na rotina pc_busca_sit_salario, melhoria do cursor cr_lanaut;
                            rotina pc_busca_rendas_aut, melhoria do cursor cr_tbfolha_lanaut e ajustes de 
                            performance no xml (Carlos)

               05/07/2018 - Inclusao das tags de cdtarifa e cdfaixav no XML de saída
                            da procedure: pc_consulta_arq_folha_ib e da função: fn_cdtarifa_cdfaixav,
                            Prj.363 (Jean Michel).             


              29/05/2018  - Lançamento de Credito e Debito utilizando LANC0001 - Rangel Decker AMcom
                          - pc_debito_pagto_aprovados
                          - pc_cr_pagto_aprovados_coop

              06/08/2019 - Permitir inclusao de folha CTASAL apenas antes do horario
                           parametrisado na PAGFOL "Portabilidade (Pgto no dia):"
                           RITM0032122 - Lucas Ranghetti   

              20/08/2019 - Verificar se conta esta bloqueada judicialmente 
                           (Lucas Ranghetti - RITM0034650)
  ..............................................................................*/

  --Busca LCS com mesmo num de documento
  CURSOR cr_craplcs_nrdoc (pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                          ,pr_nrdconta IN craplcs.nrdconta%TYPE
                          ,pr_cdhisdev IN VARCHAR2
                          ,pr_nrdocmto IN craplcs.nrdocmto%TYPE) IS
    SELECT 1
      FROM craplcs
     WHERE craplcs.cdcooper = pr_cdcooper
       AND craplcs.dtmvtolt = pr_dtmvtolt
       AND craplcs.nrdconta = pr_nrdconta -- CRAPLCS.NRDCONTA (LCS LOOP)
       AND craplcs.cdhistor = pr_cdhisdev -- VR_CDHISDEV
       AND craplcs.nrdocmto = pr_nrdocmto; -- CRAPLCS.NRDOCMTO (LCS LOOP)
  
  vr_exis_lcs NUMBER;
  vr_idprglog NUMBER;

  vr_rcraplot   LANC0001.cr_craplot%ROWTYPE; 
  vr_incrineg   INTEGER;      --> Indicador de crítica de negócio para uso com a "pc_gerar_lancamento_conta"
  vr_tab_retorno    LANC0001.typ_reg_retorno;


  /* Procedure responsável por retornar a hora, em formato texto, do inicio e fim do horário de transações  */
  PROCEDURE pc_hrtransfer_internet(pr_cdcooper    IN craptab.cdcooper%TYPE
                                  ,pr_hrtrfini   OUT VARCHAR2     -- Formato de retorno HH24:MI
                                  ,pr_hrtrffim   OUT VARCHAR2) IS -- Formato de retorno HH24:MI
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_hrtransfer_internet                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Renato Darosci - SUPERO
  --  Data     : Maio/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Procedure para retornar a hora de início e fim para transações
  --
  ---------------------------------------------------------------------------------------------------------------

    -- Buscar a informação da CRAPTAB
    CURSOR cr_craptab IS
      SELECT to_char(to_date(SUBSTR(dstextab,9,5),'sssss'),'hh24:mi') hrtrfini
           , to_char(to_date(SUBSTR(dstextab,3,5),'sssss'),'hh24:mi') hrtrffim
        FROM craptab
       WHERE cdcooper        = pr_cdcooper
         AND UPPER(nmsistem) = 'CRED'
         AND UPPER(tptabela) = 'GENERI'
         AND cdempres        = 00
         AND UPPER(cdacesso) = 'HRTRANSFER'
         AND tpregist        = 90; --> Internet

  BEGIN
    -- Busca as informações da CRAPTAB
    OPEN  cr_craptab;
    FETCH cr_craptab INTO pr_hrtrfini
                        , pr_hrtrffim;

    -- Caso não encontre registros
    IF cr_craptab%NOTFOUND THEN
      -- Garante que retornará NULL
      pr_hrtrfini := NULL;
      pr_hrtrffim := NULL;
    END IF;

    -- Fecha o cursor
    CLOSE cr_craptab;

  END pc_hrtransfer_internet;

  /* Função para validar se a hora informada está no range do inicio e fim do horário de
  transações e retorna os dois valores de hora inicio e fim */
  FUNCTION fn_valida_hrtransfer(pr_cdcooper    IN craptab.cdcooper%TYPE
                               ,pr_hrvalida    IN DATE DEFAULT SYSDATE -- Critica
                               ,pr_hrtrfini   OUT VARCHAR2
                               ,pr_hrtrffim   OUT VARCHAR2) RETURN BOOLEAN IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_valida_hrtransfer                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Renato Darosci - SUPERO
  --  Data     : Maio/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Função para validar se a hora está dentro do range de horario de transações, retornando
  --             a hora inicio e fim do parametro.
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN

    -- Busca as horas de inicio e fim para a cooperativa
    pc_hrtransfer_internet(pr_cdcooper,pr_hrtrfini,pr_hrtrffim);

    -- Se não possuir horário limite, não limita
    IF pr_hrtrfini IS NULL OR pr_hrtrffim IS NULL THEN
      RETURN TRUE;
    END IF;

    -- Verifica se a hora informada está no intervalo
    IF to_date(to_char(pr_hrvalida,'HH24:MI'),'HH24:MI')
      BETWEEN to_date(pr_hrtrfini,'HH24:MI') AND to_date(pr_hrtrffim,'HH24:MI') THEN
      RETURN TRUE;
    END IF;

    -- Se não estiver dentro do range, retorna falso
    RETURN FALSE;

  END;

  /* Função para validar se a hora informada está no range do inicio e fim do horário de transações */
  FUNCTION fn_valida_hrtransfer(pr_cdcooper    IN craptab.cdcooper%TYPE
                               ,pr_hrvalida    IN DATE DEFAULT SYSDATE) RETURN BOOLEAN IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_valida_hrtransfer                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Renato Darosci - SUPERO
  --  Data     : Maio/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Função para validar se a hora está dentro do range de horario de transações
  --
  --  *** SOBRECARGA DO MÉTODO - FN_VALIDA_HRTRANSFER
  ---------------------------------------------------------------------------------------------------------------
    -- VARIÁVEIS
    vr_hrinicio   VARCHAR2(5);
    vr_hrfinal   VARCHAR2(5);

  BEGIN

    -- Retorna a validação da hora
    RETURN fn_valida_hrtransfer(pr_cdcooper
                               ,pr_hrvalida
                               ,vr_hrinicio
                               ,vr_hrfinal);

  END;

  -- Função para optimizar a busca do valor da tarifa de Folha conforme opção Debito
  FUNCTION fn_valor_tarifa_folha(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta
                                ,pr_cdcontar IN crapcfp.cdcontar%TYPE --> Convênio
                                ,pr_idopdebi IN crappfp.idopdebi%TYPE --> Opção Debito (D0, D-1 e D-2)
                                ,pr_vllanmto IN crappfp.vllctpag%TYPE --> Valor do lançamento
                                ,pr_cdprogra IN crapprg.cdprogra%TYPE DEFAULT 'FOLH0001') --> Programa chamador
                                RETURN NUMBER IS
  BEGIN
    DECLARE
      -- Saida de erro
      vr_cdcritic NUMBER;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro EXCEPTION;
      -- Retorno da rotina de tarifas
      vr_cdhistor INTEGER;
      vr_cdhisest INTEGER;
      vr_vltarifa NUMBER;
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;
      vr_cdfvlcop INTEGER;
    BEGIN

      -- Buscamos os valores da tarifa vigente no sistema de tarifação (CADTAR)
      TARI0001.pc_carrega_dados_tarifa_cobr(pr_cdcooper => pr_cdcooper     --Codigo Cooperativa
                                           ,pr_nrdconta => pr_nrdconta     --Numero Conta
                                           ,pr_nrconven => pr_cdcontar     --Numero Convenio
                                           ,pr_dsincide => 'FOLHA'         --Descricao Incidencia
                                           ,pr_cdocorre => pr_idopdebi     --Codigo Ocorrencia
                                           ,pr_cdmotivo => NULL            --Codigo Motivo
                                           ,pr_inpessoa => 2               --Tipo Pessoa(PJ)
                                           ,pr_vllanmto => pr_vllanmto     --Valor Lancamento
                                           ,pr_cdprogra => pr_cdprogra     --Nome Programa
                                           ,pr_flaputar => 0               --Nao apurar
                                           ,pr_cdhistor => vr_cdhistor     --Codigo Historico
                                           ,pr_cdhisest => vr_cdhisest     --Historico Estorno
                                           ,pr_vltarifa => vr_vltarifa     --Valor Tarifa
                                           ,pr_dtdivulg => vr_dtdivulg     --Data Divulgacao
                                           ,pr_dtvigenc => vr_dtvigenc     --Data Vigencia
                                           ,pr_cdfvlcop => vr_cdfvlcop
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
      --Se ocorrer erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Se chegarmos neste ponto, retornaremos o valor encontrado
      RETURN vr_vltarifa;
    EXCEPTION
      WHEN vr_exc_erro THEN

        -- Enviar detalhamento do erro ao LOG
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                             , pr_cdprograma => 'FOLH0001' 
                             , pr_cdcooper => pr_cdcooper
                             , pr_tpexecucao => 0
                             , pr_tpocorrencia => 1 
                             , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro na rotina fn_valor_tarifa_folha. Detalhes: TARIFA DE SERVICO – CONVENIO ' || pr_cdcontar || ' – NAO PODE SER BUSCADA - ' || vr_dscritic) 
                             , pr_idprglog => vr_idprglog);                             
        -- Retornar -1
        RETURN -1;
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      
        -- Enviar detalhamento do erro ao LOG
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                             , pr_cdprograma => 'FOLH0001' 
                             , pr_cdcooper => pr_cdcooper
                             , pr_tpexecucao => 0
                             , pr_tpocorrencia => 1 
                             , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro na rotina fn_valor_tarifa_folha. Detalhes: TARIFA DE SERVICO – CONVENIO ' || pr_cdcontar || ' – NAO PODE SER BUSCADA - ' || SQLERRM) 
                             , pr_idprglog => vr_idprglog);
                
        -- Retornar -1
        RETURN -1;
    END;
  END fn_valor_tarifa_folha;

  -- Função para optimizar a busca do histórico da tarifa de Folha conforme opção Debito
  FUNCTION fn_histor_tarifa_folha(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                 ,pr_cdcontar IN crapcfp.cdcontar%TYPE --> Convênio
                                 ,pr_idopdebi IN crappfp.idopdebi%TYPE --> Opção Debito (D0, D-1 e D-2)
                                 ,pr_vllanmto IN crappfp.vllctpag%TYPE --> Valor do lançamento
                                 ,pr_cdprogra IN crapprg.cdprogra%TYPE DEFAULT 'FOLH0001') --> Programa chamador
                                 RETURN craphis.cdhistor%TYPE IS
  BEGIN
    DECLARE
      -- Saida de erro
      vr_cdcritic NUMBER;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro EXCEPTION;
      -- Retorno da rotina de tarifas
      vr_cdhistor INTEGER;
      vr_cdhisest INTEGER;
      vr_vltarifa NUMBER;
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;
      vr_cdfvlcop INTEGER;
    BEGIN
      -- Buscamos os valores da tarifa vigente no sistema de tarifação (CADTAR)
      TARI0001.pc_carrega_dados_tarifa_cobr(pr_cdcooper => pr_cdcooper     --Codigo Cooperativa
                                           ,pr_nrdconta => 0               --Numero Conta
                                           ,pr_nrconven => pr_cdcontar     --Numero Convenio
                                           ,pr_dsincide => 'FOLHA'         --Descricao Incidencia
                                           ,pr_cdocorre => pr_idopdebi     --Codigo Ocorrencia
                                           ,pr_cdmotivo => NULL            --Codigo Motivo
                                           ,pr_inpessoa => 2               --Tipo Pessoa(PJ)
                                           ,pr_vllanmto => pr_vllanmto     --Valor Lancamento
                                           ,pr_flaputar => 0               -- Nao apurar 
                                           ,pr_cdprogra => pr_cdprogra     --Nome Programa
                                           ,pr_cdhistor => vr_cdhistor     --Codigo Historico
                                           ,pr_cdhisest => vr_cdhisest     --Historico Estorno
                                           ,pr_vltarifa => vr_vltarifa     --Valor Tarifa
                                           ,pr_dtdivulg => vr_dtdivulg     --Data Divulgacao
                                           ,pr_dtvigenc => vr_dtvigenc     --Data Vigencia
                                           ,pr_cdfvlcop => vr_cdfvlcop
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
      --Se ocorrer erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Se chegarmos neste ponto, retornaremos o valor encontrado
      RETURN vr_cdhistor;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Enviar detalhamento do erro ao LOG
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                             , pr_cdprograma => 'FOLH0001' 
                             , pr_cdcooper => pr_cdcooper
                             , pr_tpexecucao => 0
                             , pr_tpocorrencia => 1 
                             , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro na rotina fn_histor_tarifa_folha. Detalhes: TARIFA DE SERVICO – CONVENIO ' || pr_cdcontar || ' – NAO PODE SER BUSCADA - ' || vr_dscritic)
                             , pr_idprglog => vr_idprglog);
        
        -- Retornar zero
        RETURN -1;
      WHEN OTHERS THEN
        
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        
        -- Enviar detalhamento do erro ao LOG
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                             , pr_cdprograma => 'FOLH0001' 
                             , pr_cdcooper => pr_cdcooper
                             , pr_tpexecucao => 0
                             , pr_tpocorrencia => 1 
                             , pr_dsmensagem => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro na rotina fn_histor_tarifa_folha. Detalhes: TARIFA DE SERVICO – CONVENIO ' || pr_cdcontar || ' – NAO PODE SER BUSCADA - ' || SQLERRM)
                             , pr_idprglog => vr_idprglog);
        -- Retornar zero
        RETURN -1;
    END;
  END fn_histor_tarifa_folha;

  -- Função para centralizar a montagem do nome do operador ou preposto para log
  FUNCTION fn_nmoperad_log(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                          ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta conectada
                          ,pr_nrcpfope IN crapopi.nrcpfope%TYPE) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      -- Nome do operador
      CURSOR cr_crapopi IS
        SELECT opi.nmoperad
          FROM crapopi opi
         WHERE opi.cdcooper = pr_cdcooper
           AND opi.nrdconta = pr_nrdconta
           AND opi.nrcpfope = pr_nrcpfope;
      vr_nmoperad crapopi.nmoperad%TYPE;
    BEGIN
      -- Para o preposto
      IF pr_nrcpfope = 0 THEN
        RETURN 'Preposto';
      ELSE
        -- Buscar nome do operador
        OPEN cr_crapopi;
        FETCH cr_crapopi
         INTO vr_nmoperad;
        CLOSE cr_crapopi;
        -- Se não encontrarmos
        IF vr_nmoperad IS NULL THEN
          RETURN 'Operador desconhecido.';
        ELSE
          RETURN vr_nmoperad;
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        
        -- Retornar erro
        RETURN 'Operador desconhecido.';
    END;
  END fn_nmoperad_log;

  -- Função para centralizar a montagem do nome do operador ou preposto para log
  FUNCTION fn_tpconta_log(pr_idtpconta IN craplfp.idtpcont%TYPE) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF pr_idtpconta = 'C' THEN
        RETURN 'Associado';
      ELSE
        RETURN 'CTASAL';
      END IF;
    END;
  END fn_tpconta_log;
  
  -- Função para traduzir o código de opção debito para texto
  FUNCTION fn_nmopdebi_log(pr_idopdebi IN crappfp.idopdebi%TYPE) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF pr_idopdebi = 0 THEN
        RETURN 'D0';
      ELSIF pr_idopdebi = 1 THEN
        RETURN 'D-1';
      ELSE
        RETURN 'D-2';
      END IF;
    END;
  END fn_nmopdebi_log;      
  
  -- Função para traduzir a origem de salário
  FUNCTION fn_dsorigem_log(pr_cdcooper IN crapofp.cdcooper%TYPE
                          ,pr_cdorigem IN crapofp.cdorigem%TYPE) RETURN VARCHAR2 IS
    CURSOR cr_ofp IS
      SELECT dsorigem
        FROM crapofp
       WHERE cdcooper = pr_cdcooper
         AND cdorigem = pr_cdorigem;
    vr_dsorigem crapofp.dsorigem%TYPE;     
  BEGIN
    BEGIN
      OPEN cr_ofp;
      FETCH cr_ofp
       INTO vr_dsorigem;
      CLOSE cr_ofp; 
      RETURN nvl(vr_dsorigem,'Indefinida');
    END;
  END fn_dsorigem_log;


  FUNCTION fn_verifica_hist_lanaut(pr_cdcooper IN crapcop.cdcooper%TYPE
                                  ,pr_cdhistor IN VARCHAR2 ) RETURN BOOLEAN IS                                  
                        
    vr_dsconteu VARCHAR2(4000);          
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_des_erro VARCHAR2(10);
    vr_tab_erro gene0001.typ_tab_erro;
                                      
  BEGIN
    
    tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                          ,pr_cdbattar => 'HSTPARTICIPALRA'
                                          ,pr_dsconteu => vr_dsconteu
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic
                                          ,pr_des_erro => vr_des_erro
                                          ,pr_tab_erro => vr_tab_erro);
                                          
    IF vr_des_erro = 'NOK' THEN
       RETURN FALSE;
    END IF;                                        
  
    IF gene0002.fn_existe_valor(pr_base  => vr_dsconteu
                               ,pr_busca => LPAD(pr_cdhistor,4,'0')
                               ,pr_delimite => ',') <> 'S' THEN
       RETURN FALSE;                        
    END IF;  
    
    RETURN TRUE;
  END fn_verifica_hist_lanaut;

  FUNCTION fn_verifica_hist_folha(pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_cdhistor IN VARCHAR2 ) RETURN BOOLEAN IS                                  
                        
    vr_dsconteu VARCHAR2(4000);          
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_des_erro VARCHAR2(10);
    vr_tab_erro gene0001.typ_tab_erro;
                                      
  BEGIN
    
    tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                          ,pr_cdbattar => 'HSTPARTICIPAFOL'
                                          ,pr_dsconteu => vr_dsconteu
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic
                                          ,pr_des_erro => vr_des_erro
                                          ,pr_tab_erro => vr_tab_erro);
                                          
    IF vr_des_erro = 'NOK' THEN
       RETURN FALSE;
    END IF;                                        
  
    IF gene0002.fn_existe_valor(pr_base  => vr_dsconteu
                               ,pr_busca => LPAD(pr_cdhistor,4,'0')
                               ,pr_delimite => ',') <> 'S' THEN
       RETURN FALSE;                        
    END IF;  
    
    RETURN TRUE;
  END fn_verifica_hist_folha;

  -- Função para retornar código de tarifa e faixa da tarifa
  FUNCTION fn_cdtarifa_cdfaixav(pr_cdocorre IN craptar.cdocorre%TYPE --> Contem o codigo da ocorrencia.
                               )RETURN VARCHAR2 IS                                
  
    CURSOR cr_craptar IS
      SELECT craptar.cdtarifa || ',' || crapfvl.cdfaixav
        FROM craptar
            ,crapfvl
       WHERE craptar.cdtarifa = crapfvl.cdtarifa
         AND craptar.cdinctar = (SELECT crapint.cdinctar FROM crapint WHERE UPPER(crapint.dsinctar) LIKE UPPER('FOLHA'||'%'))
         AND craptar.cdocorre = pr_cdocorre
         AND craptar.inpessoa = 2;
     
    vr_dstarfai VARCHAR2(20) := '';                        
  BEGIN
    OPEN cr_craptar;
    FETCH cr_craptar INTO vr_dstarfai;
    
    RETURN vr_dstarfai;
  END fn_cdtarifa_cdfaixav;

  
  /* Procedure de Reprovacao automatica de estouros fora do horario */
  PROCEDURE pc_reprov_estouro_horario(pr_cdcooper IN crapcop.cdcooper%TYPE)  IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_reprov_estouro_horario                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Maio/2015.                   Ultima atualizacao: 25/01/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para realizar a reprovação automática de estouros fora do horário
  -- Alterações
  --            25/01/2016 - Melhorias nas mensagens de log (Marcos-Supero)
  --
  ---------------------------------------------------------------------------------------------------------------

    -- Busca email da empresa
    CURSOR cr_crapemp(pr_cdcooper crapemp.cdcooper%TYPE
                     ,pr_cdempres crapemp.cdempres%TYPE) IS
      SELECT emp.dsdemail
        FROM crapemp emp
       WHERE emp.cdempres = pr_cdempres
         AND emp.cdcooper = pr_cdcooper         ;

    -- Busca todos os pagamentos com solicitacao pendentes.
    CURSOR cr_crappfp(p_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT emp.cdempres
            ,SUM(pfp.vllctpag) vllctpag
        FROM crapcfp cfp
            ,crapass ass
            ,crapemp emp
            ,crappfp pfp
       WHERE pfp.cdcooper = p_cdcooper
         AND pfp.idsitapr = 2 --> Em estouro
         AND pfp.cdcooper = emp.cdcooper
         AND pfp.cdempres = emp.cdempres
         AND emp.flgpgtib = 1
         AND emp.cdcooper = ass.cdcooper
         AND emp.nrdconta = ass.nrdconta
         AND cfp.cdcooper = emp.cdcooper
         AND cfp.cdcontar = emp.cdcontar
       GROUP BY emp.cdempres;

    -- Variaveis
    vr_horlimit   crapprm.dsvlrprm%TYPE;
    vr_dsdemail   crapemp.dsdemail%TYPE;
    vr_assunto    VARCHAR2(500);
    vr_conteudo   VARCHAR2(4000);

    -- Variaveis de Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis Excecao
    vr_exc_erro EXCEPTION;


  BEGIN
    -- Inicializar variaveis retorno
    vr_conteudo := NULL;
    vr_assunto  := 'Folha de Pagamento - Estouro Reprovado';

    -- Busca o horario limite para analise de estouros em folha
    vr_horlimit := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_cdacesso => 'FOLHAIB_HOR_LIM_ANA_EST');

    -- Se nao atingiu o horario, proximo registro
    IF TO_CHAR(SYSDATE,'hh24:mi') < NVL(vr_horlimit,'23:59') THEN
      RETURN;
    END IF;

    -- Reprova todos as folhas de pagto.
    FOR rw_crappfp IN cr_crappfp(pr_cdcooper) LOOP
      BEGIN
        -- Atualiza o registro
        UPDATE crappfp pfp
           SET pfp.idsitapr = 3   --> Reprovado
              ,pfp.cdopeest = '1' --> Usuario Padrao
              ,pfp.dsjusest = 'Solicitacao de estouro expirada pois o horario maximo para liberacao e as '||vr_horlimit
          WHERE pfp.cdcooper = pr_cdcooper
            AND pfp.idsitapr = 2 --> Em estouro
            AND pfp.cdempres = rw_crappfp.cdempres;

        -- Busca e-mail da cooperativa
        OPEN cr_crapemp(pr_cdcooper, rw_crappfp.cdempres);
        FETCH cr_crapemp INTO vr_dsdemail;

        IF cr_crapemp%NOTFOUND THEN
          CLOSE cr_crapemp;
          -- Gera critica
          vr_cdcritic := 0;
          vr_dscritic := 'E-mail do empresa '||rw_crappfp.cdempres||' nao cadastrado.';
          RAISE vr_exc_erro;
        END IF;

        CLOSE cr_crapemp;

        -- Conteudo do email
        vr_conteudo := 'Informamos que o estouro de sua conta no valor de R$ '||TO_CHAR(rw_crappfp.vllctpag, 'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.')||
                       ' foi reprovado por não haver tempo hábil para a análise no seu Posto de Atendimento. <br><br>'||
                       'Lembramos que você poderá aprová-los novamente, mas deverá ter saldo e/ou limite de crédito '||
                       'suficiente em sua conta corrente.<br /><br />'||
                       'Atenciosamente,<br />'||
                       'Sistema AILOS';

        -- Enviar Email de para o departamento de contabilidade comunicando sobre a gerac?o do arquivo
        gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                  ,pr_cdprogra        => 'FOLH0001'
                                  ,pr_des_destino     => vr_dsdemail
                                  ,pr_des_assunto     => vr_assunto
                                  ,pr_des_corpo       => vr_conteudo
                                  ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                  ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                  ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dscritic);

        -- Se houver erros
        IF vr_dscritic IS NOT NULL THEN
          -- Gera critica
          vr_cdcritic := 0;
          vr_dscritic := 'Empresa '||rw_crappfp.cdempres||'. Erro: '||vr_dscritic;
          RAISE vr_exc_erro;
        END IF;
      EXCEPTION
        WHEN vr_exc_erro THEN
          RAISE vr_exc_erro;
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          
          vr_dscritic := 'Empresa '||rw_crappfp.cdempres||'. Erro: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      -- Para cada empresa
      COMMIT;
    END LOOP;
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer a operacao
      ROLLBACK;
      -- envia ao LOG o problema ocorrido
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                             , pr_cdprograma => 'FOLH0001' 
                             , pr_cdcooper => pr_cdcooper
                             , pr_tpexecucao => 0
                             , pr_tpocorrencia => 1 
                             , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro na rotina pc_reprov_estouro_horario. Detalhes: Estouro fora horario - ' || vr_dscritic
                             , pr_idprglog => vr_idprglog);

    WHEN OTHERS THEN
      ROLLBACK;
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      -- efetuar o raise
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                             , pr_cdprograma => 'FOLH0001' 
                             , pr_cdcooper => pr_cdcooper
                             , pr_tpexecucao => 0
                             , pr_tpocorrencia => 1 
                             , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro na rotina pc_reprov_estouro_horario. Detalhes: Estouro fora horario - ' || SQLERRM
                             , pr_idprglog => vr_idprglog);
      
  END pc_reprov_estouro_horario;


  /* Procedure para realizar o alerta e/ou cancelamento automático de empresas sem uso */
  PROCEDURE pc_aviso_cancel_emp_sem_uso(pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_nmrescop IN crapcop.nmrescop%TYPE) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_aviso_cancel_emp_sem_uso             Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Renato Darosci - SUPERO
  --  Data     : Maio/2015.                   Ultima atualizacao: 25/01/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para realizar o alerta e/ou cancelamento automático de empresas sem uso
  -- Alterações:
  --             25/01/2016 - Melhorias nas mensagens de log de erro (Marcos-Supero)
  --
  --             23/03/2017 - Ajuste para poder habilitar folha para empresas com
  --                          movimento de pagamento maior que 12 meses, conforme solicitado
  --                          no chamado 628488 (Kelvin)
  ---------------------------------------------------------------------------------------------------------------

    -- Busca email da empresa
    CURSOR cr_crapemp(pr_cdcooper crapemp.cdcooper%TYPE) IS
      SELECT emp.cdempres
           , emp.dsdemail
           , emp.nrdconta
           , emp.dtultufp -- data do ultimo credito do produto folha
           , emp.dtavsufp -- data do ultimo alerta da falta de uso do produto folha
           , emp.flgpgtib
           , emp.dtinccan
           , ROWID  dsdrowid
        FROM crapemp emp
       WHERE emp.cdcooper = pr_cdcooper
         AND emp.flgpgtib = 1;

    -- Variaveis
    vr_qtmescan   crapprm.dsvlrprm%TYPE;
    vr_qtultpag   NUMBER;
    vr_dsmensag   VARCHAR2(4000);
    vr_qtultlib   NUMBER;

    -- Variaveis de Erro
    vr_cdcritic   crapcri.cdcritic%TYPE;
    vr_dscritic   VARCHAR2(4000);
    vr_tab_erro   GENE0001.typ_tab_erro;

    -- Variaveis Excecao
    vr_exc_erro EXCEPTION;

    -- Objetos para armazenar as variáveis da notificação
    vr_variaveis_notif NOTI0001.typ_variaveis_notif;
    vr_notif_origem   tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE := 8;
    vr_notif_motivo   tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE := 2;      

  BEGIN

    -- Busca a quantidade de meses sem uso para cancelamento
    vr_qtmescan := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_cdacesso => 'FOLHAIB_QTD_MES_CANCELA');

    -- Buscar e percorrer todas as empresas da cooperativa atual
    FOR rw_crapemp IN cr_crapemp(pr_cdcooper) LOOP
      BEGIN
        -- Define a quantidade de meses entre a data do ultimo lançamento e a atual
        vr_qtultpag := trunc(MONTHS_BETWEEN(SYSDATE,NVL(rw_crapemp.dtultufp, SYSDATE)));

        --Define a quantidade de meses entre a data de cancelamento ou liberação da folha e a atual
        vr_qtultlib := trunc(MONTHS_BETWEEN(SYSDATE,NVL(rw_crapemp.dtinccan, SYSDATE)));

        /* 1 - Se a quantidade de meses é igual ou superior a de cancelamento
           2 - se a quantidade de meses da ultima data de liberação da folha
           é maior ou igual a data parametrizada para cancelamento.
           3 - Se a folha está liberada*/
        IF vr_qtultpag >= vr_qtmescan AND            
           vr_qtultlib >= vr_qtmescan AND 
           rw_crapemp.flgpgtib = 1 THEN

          BEGIN
            -- Atualizar o flag de acesso ao folha para não liberado
            UPDATE crapemp
               SET flgpgtib = 0 -- Não liberado
                  ,dtinccan = TRUNC(SYSDATE)
             WHERE ROWID    = rw_crapemp.dsdrowid;
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
              vr_dscritic := 'Erro ao atualizar FLGPGTIB. '||SQLERRM;
              RAISE vr_exc_erro;
          END;

          -- Se há email cadastrado
          IF TRIM(rw_crapemp.dsdemail) IS NOT NULL THEN
            -- Enviar e-mail informando o cancelamento do produto.
            vr_dsmensag := 'Seu acesso ao uso do Serviço Folha de Pagamento foi cancelado. Motivo: falta '||
                           'de utilização nos últimos '||to_Char(vr_qtmescan)||' meses.<br>'||
                           'Entre em contato com seu Posto de Atendimento e solicite novamente a adesão ao serviço. <br><br>'||
                           'Atenciosamente, <br>'||
                           'Sistema AILOS';

            -- Enviar Email comunicando o cancelamento do produto
            gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                      ,pr_cdprogra        => 'FOLH0001'
                                      ,pr_des_destino     => TRIM(rw_crapemp.dsdemail)
                                      ,pr_des_assunto     => 'Folha de Pagamento - Cancelamento do Serviço'
                                      ,pr_des_corpo       => vr_dsmensag
                                      ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                      ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                      ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                      ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                      ,pr_des_erro        => vr_dscritic);

            -- Se houver erros
            IF vr_dscritic IS NOT NULL THEN
              -- Gera critica
              vr_cdcritic := 0;
              RAISE vr_exc_erro;
            END IF;
          END IF;

          -- Adicionar mensagem nas anotações da atenda
          CADA0001.pc_grava_dados(pr_cdcooper => pr_cdcooper
                                 ,pr_cdoperad => '1' -- Operador principal - super-usuario
                                 ,pr_cdagenci => 0
                                 ,pr_nrdcaixa => 0
                                 ,pr_nmdatela => 'FOLH0001'
                                 ,pr_idorigem => 1 -- Ayllos
                                 ,pr_nrdconta => rw_crapemp.nrdconta
                                 ,pr_nrseqdig => 0
                                 ,pr_dsobserv => 'Acesso ao Serviço Folha IB revogado em '||to_char(SYSDATE,'dd/mm/yyyy')||
                                                 ' devido à falta de uso do serviço há mais de '||to_Char(vr_qtmescan)||' meses.'
                                 ,pr_flgprior => 0 -- Não prioritária
                                 ,pr_cddopcao => 'I' -- Inclusão
                                 ,pr_dtmvtolt => SYSDATE
                                 ,pr_flgerlog => TRUE
                                 ,pr_tab_erro => vr_tab_erro
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

          -- Se houver erros
          IF vr_dscritic IS NOT NULL THEN
            -- Gera critica
            vr_cdcritic := 0;
            RAISE vr_exc_erro;
          END IF;

        ELSIF vr_qtultpag >= (vr_qtmescan - 2) THEN -- Verifica a quantidade de meses para o aviso de cancelamento

          -- Verificar se a data da última mensagem de aviso enviada foi a mais de quinze dias
          IF (trunc(SYSDATE) - trunc(rw_crapemp.dtavsufp)) > 15 OR rw_crapemp.dtavsufp IS NULL THEN

            -- Definir o texto da mensagem
            vr_dsmensag := '<br>O serviço Folha de Pagamento será suspenso em breve caso não haja sua utilização. '||
                           'Volte a utilizar o Folha de Pagamento e aproveite as vantagens e facilidades que '||
                           'ele proporciona para sua empresa. ';

            -- Adicionar mensagem
            GENE0003.pc_gerar_mensagem(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => rw_crapemp.nrdconta
                                      ,pr_idseqttl => 1  --> Primeiro titular
                                      ,pr_cdprogra => 'FOLH0001'
                                      ,pr_inpriori => 0  --> Não prioritária
                                      ,pr_dsdmensg => vr_dsmensag
                                      ,pr_dsdassun => 'Cancelamento Serviço Folha'
                                      ,pr_dsdremet => pr_nmrescop
                                      ,pr_dsdplchv => 'FolhaPagto'
                                      ,pr_cdoperad => '1' -- Operador principal - super-usuario
                                      ,pr_cdcadmsg => '0'
                                      ,pr_dscritic => vr_dscritic);

            -- Se houver erros
            IF vr_dscritic IS NOT NULL THEN
              -- Gera critica
              vr_cdcritic := 0;
              RAISE vr_exc_erro;
            END IF;
            -- Cria uma notificação
            noti0001.pc_cria_notificacao(pr_cdorigem_mensagem => vr_notif_origem
                                        ,pr_cdmotivo_mensagem => vr_notif_motivo
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => rw_crapemp.nrdconta
                                        ,pr_idseqttl => 1 -- Primeiro titular
                                        ,pr_variaveis => vr_variaveis_notif);
            --
            BEGIN
              -- Atualizar a data do ultimo aviso, para que não ocorram novas mensagens nos próximos 15 dias
              UPDATE crapemp
                 SET dtavsufp = SYSDATE
               WHERE ROWID    = rw_crapemp.dsdrowid;
            EXCEPTION
              WHEN OTHERS THEN
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                vr_dscritic := 'Erro ao atualizar DTAVSUFP. '||SQLERRM;
                RAISE vr_exc_erro;
            END;
          END IF;

        END IF;
        -- Efetua Commit
        COMMIT;
      EXCEPTION
        WHEN vr_exc_erro THEN
          vr_dscritic := '- Empresa '||rw_crapemp.cdempres||'. Erro: '||vr_dscritic;
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          vr_dscritic := '- Empresa '||rw_crapemp.cdempres||'. Erro: '||SQLERRM;
      END;
    END LOOP; -- cr_crapemp


  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer a operacao
      ROLLBACK;
      -- envia ao LOG o problema ocorrido
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'FOLH0001' 
                           , pr_cdcooper => pr_cdcooper
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro na rotina pc_aviso_cancel_emp_sem_uso. Detalhes: Cancelamento sem uso - ' || vr_dscritic
                           , pr_idprglog => vr_idprglog);
      
    WHEN OTHERS THEN
      -- Desfazer a operacao
      ROLLBACK;
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      
      -- envia ao LOG o problema ocorrido
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'FOLH0001' 
                           , pr_cdcooper => pr_cdcooper
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro na rotina pc_aviso_cancel_emp_sem_uso. Detalhes: Cancelamento sem uso - ' || vr_dscritic
                           , pr_idprglog => vr_idprglog);      
      
  END pc_aviso_cancel_emp_sem_uso;

  /* Aprova automaticamente os estouros com regularização do saldo */
  PROCEDURE pc_aprova_estouros_automatico (pr_cdcooper IN crapcop.cdcooper%TYPE
                                          ,pr_rw_crapdat IN BTCH0001.CR_CRAPDAT%ROWTYPE) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_aprova_estouros_automatico             Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Lucas Afonso Lombardi Moreira
  --  Data     : Julho/2015.                   Ultima atualizacao: 30/10/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Checar os saldos das empresas que haviam solicitado o estouro
  --             de conta, e em caso de regularização do saldo, os pagamentos
  --             são automaticamente aprovados
  -- Alterações
  --             04/11/2015 - Troca do tipo da variavel decimal para number, pois o saldo
  --                          estava sendo truncado - Marcos(Supero)
  --
  --             07/07/2016 - Mudança nos parâmetros da chamada de saldo para melhora
  --                          de performance - Marcos(Supero)
  --
  --             30/10/2017 - Somando os pagamentos aprovados e nao debitados na verificação
  --                          de estouro, conforme solicitado no chamado 707298 (Kelvin).
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Busca empresas que possuem pagamentos com débito pendente e estouro solicitado
  CURSOR cr_crapemp (pr_cdcooper IN crapemp.cdcooper%TYPE) IS
    SELECT emp.cdempres
          ,emp.nrdconta
          ,emp.dsdemail
          ,ass.vllimcre
          ,sum(lfp.vllancto) vllancto
      FROM crappfp pfp
          ,crapemp emp
          ,craplfp lfp
          ,crapass ass
     WHERE pfp.cdcooper = pr_cdcooper
       AND pfp.cdcooper = emp.cdcooper
       AND pfp.cdempres = emp.cdempres
       AND lfp.cdcooper = pfp.cdcooper
       AND lfp.cdempres = pfp.cdempres
       AND lfp.nrseqpag = pfp.nrseqpag
       AND ass.cdcooper = pfp.cdcooper
       AND ass.nrdconta = emp.nrdconta
       AND pfp.idsitapr = 2 --> Estouro solicitado
       AND pfp.flsitdeb = 0 --> Ainda nao debitado
     GROUP BY emp.cdempres
             ,emp.nrdconta
             ,emp.dsdemail
             ,trunc(pfp.dtsolest)
             ,ass.vllimcre;

  -- Busca empresas que possuem pagamentos com débitos pendentes
  CURSOR cr_crapemp_debito_pendente(pr_cdcooper IN crapemp.cdcooper%TYPE
                                   ,pr_cdempres IN crapemp.cdempres%TYPE) IS
    SELECT SUM(lfp.vllancto) vllancto
      FROM crappfp pfp
          ,crapemp emp
          ,craplfp lfp
          ,crapass ass
     WHERE pfp.cdcooper = pr_cdcooper
       AND pfp.cdcooper = emp.cdcooper
       AND pfp.cdempres = emp.cdempres
       AND lfp.cdcooper = pfp.cdcooper
       AND lfp.cdempres = pfp.cdempres
       AND lfp.nrseqpag = pfp.nrseqpag
       AND ass.cdcooper = pfp.cdcooper
       AND ass.nrdconta = emp.nrdconta
       AND pfp.idsitapr = 5 --> Aprovados
       AND pfp.flsitdeb = 0 --> Ainda nao debitado
       AND pfp.cdempres = pr_cdempres
     GROUP BY emp.cdempres
             ,emp.nrdconta
             ,emp.dsdemail
             ,trunc(pfp.dtsolest)
             ,ass.vllimcre;

  rw_crapemp_debito_pendente cr_crapemp_debito_pendente%ROWTYPE;
  
  -- Variaveis
  vr_tab_saldo  EXTR0001.typ_tab_saldos;
  vr_saldo      NUMBER;
  vr_des_erro   VARCHAR2(3);
  vr_vllancto    NUMBER;

  --Variaveis de E-mail
  vr_email_assunto VARCHAR(300);
  vr_email_destino VARCHAR(300);
  vr_email_corpo   VARCHAR(1000);

  -- Variaveis de Erro
  vr_dscritic   VARCHAR2(4000);
  vr_tab_erro   GENE0001.typ_tab_erro;

  -- Variaveis Excecao
  vr_exc_erro EXCEPTION;

  BEGIN
    -- Busca pelas empresas que possuem pagamentos com débito pendente e estouro solicitado
    FOR rw_crapemp IN cr_crapemp(pr_cdcooper => pr_cdcooper) LOOP
      BEGIN
        -- obtencao do saldo da conta sem o dia fechado
        extr0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                   ,pr_rw_crapdat => pr_rw_crapdat --> Rowtype da crapdat da coop
                                   ,pr_cdagenci   => 0
                                   ,pr_nrdcaixa   => 0
                                   ,pr_cdoperad   => 1
                                   ,pr_nrdconta   => rw_crapemp.nrdconta
                                   ,pr_vllimcre   => rw_crapemp.vllimcre
                                   ,pr_flgcrass   => FALSE --> Não carregar a crapass inteira
                                   ,pr_tipo_busca => 'A' --> Busca da SDA do dia anterior
                                   ,pr_dtrefere   => pr_rw_crapdat.dtmvtolt
                                   ,pr_des_reto   => vr_des_erro
                                   ,pr_tab_sald   => vr_tab_saldo
                                   ,pr_tab_erro   => vr_tab_erro);
        IF vr_des_erro <> 'OK' THEN
          vr_dscritic := ' – ERRO NAO TRATADO AO VERIFICAR SALDO' || ' - ' || vr_tab_erro(0).dscritic;
          RAISE vr_exc_erro;
        END IF;
        
        vr_saldo := (vr_tab_saldo(0).vlsddisp + vr_tab_saldo(0).vllimcre);

        --Busca também os pagamentos aprovados para somar
        OPEN cr_crapemp_debito_pendente(pr_cdcooper => pr_cdcooper
                                       ,pr_cdempres => rw_crapemp.cdempres);
          FETCH cr_crapemp_debito_pendente 
           INTO rw_crapemp_debito_pendente;
        CLOSE cr_crapemp_debito_pendente;          
        
        --Soma vllancto dos estourados + vllancto aprovados
        vr_vllancto := rw_crapemp.vllancto + nvl(rw_crapemp_debito_pendente.vllancto,0);
        
        -- Se houver saldo
        IF vr_saldo >= vr_vllancto THEN
          -- Atualiza os pagamentos para aprovados
          BEGIN
            UPDATE crappfp
               SET idsitapr = 5 -- Aprovado
             WHERE cdcooper = pr_cdcooper
               AND cdempres = rw_crapemp.cdempres
               AND idsitapr = 2 --> Estouro solicitado
               AND flsitdeb = 0; --> Ainda nao debitado
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              vr_dscritic := ' – ERRO NAO TRATADO AO APROVAR PGTOS SEM SALDO - ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
          -- Prepara e-mail
          vr_email_assunto := 'Folha de Pagamento – Debito aprovado';
          vr_email_destino := rw_crapemp.dsdemail;
          vr_email_corpo   := 'Devido a regularização do saldo em sua conta, ' ||
                              'haverá nova tentativa de débito da Folha de Pagamento em alguns minutos, '||
                              'não sendo mais necessário o estouro de sua Conta.<br>' ||
                              'Obs: O débito ocorrerá se o horário limite for respeitado, do contrário '||
                              'o mesmo ocorrerá somente no próximo dia útil.'||
                              '<br>'||
                              '<br>'||
                              '<br>'||
                              'Atenciosamente,' ||
                              '<br>'||
                              'Sistema AILOS.';

          -- Enviar Email para o departamento de contabilidade comunicando sobre
          -- a geracao do arquivo
          gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => 'FOLH0001'
                                    ,pr_des_destino     => vr_email_destino
                                    ,pr_des_assunto     => vr_email_assunto
                                    ,pr_des_corpo       => vr_email_corpo
                                    ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                    ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                    ,pr_flg_remete_coop => 'S' --> Se o envio sera do e-mail da Cooperativa
                                    ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                    ,pr_des_erro        => vr_dscritic);
          IF vr_dscritic IS NOT NULL  THEN
            vr_dscritic := ' ERRO NAO TRATADO AO ENVIAR EMAIL - ' || vr_dscritic;
            RAISE vr_exc_erro;
          END IF;
        END IF;
        -- Commit a cada empresa
        COMMIT;
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Desfazer a operacao
          ROLLBACK;
          -- envia ao LOG o problema ocorrido
          vr_dscritic := '- Empresa '||rw_crapemp.cdempres||' - '||vr_dscritic;
        WHEN OTHERS THEN
          -- Desfazer a operacao
          ROLLBACK;
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          
          -- efetuar o raise
          vr_dscritic := '- Empresa '||rw_crapemp.cdempres||' - '||SQLERRM;
      END;
    END LOOP;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer a operacao
      ROLLBACK;
      -- envia ao LOG o problema ocorrido
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'FOLH0001' 
                           , pr_cdcooper => pr_cdcooper
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro na rotina pc_aprova_estouros_automatico. Detalhes: APROVACAO DE ESTOURO - ' || vr_dscritic
                           , pr_idprglog => vr_idprglog);      
     
    WHEN OTHERS THEN
      -- Desfazer a operacao
      ROLLBACK;
      
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      
      -- envia ao LOG o problema ocorrido
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'FOLH0001' 
                           , pr_cdcooper => pr_cdcooper
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro na rotina pc_aprova_estouros_automatico. Detalhes: APROVACAO DE ESTOURO - ' || SQLERRM
                           , pr_idprglog => vr_idprglog);
                             
  END pc_aprova_estouros_automatico;

  /* Alerta créditos pendentes após portabilidade */
  PROCEDURE pc_alerta_creditos_pendentes (pr_cdcooper IN crapcop.cdcooper%TYPE
                                         ,pr_rw_crapdat IN BTCH0001.CR_CRAPDAT%ROWTYPE) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_alerta_creditos_pendentes             Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Lucas Afonso Lombardi Moreira
  --  Data     : Julho/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Alerta a central de folha de pagamento se houverem pagamentos
  --             pendentes de crédito e o horário limite da portabilidade foi atingido.
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Busca empresas que possuem pagamentos com débito pendente e estouro solicitado
  CURSOR cr_crapemp (pr_cdcooper IN crapemp.cdcooper%TYPE
                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT emp.cdempres
          ,emp.nmresemp
          ,trunc(pfp.dtmvtolt) dtmvtolt
          ,pfp.dthordeb
          ,SUM(pfp.vllctpag) vllctpag
          ,SUM(pfp.qtlctpag * pfp.vltarapr) vltotpag
          ,pfp.dsobscre
      FROM crappfp pfp
          ,crapemp emp
      WHERE pfp.cdcooper = pr_cdcooper
       AND pfp.dtcredit <= pr_dtmvtolt
       AND emp.cdcooper = pfp.cdcooper
       AND emp.cdempres = pfp.cdempres
       AND pfp.flsitdeb = 1 --> Já debitados
       AND pfp.flsitcre = 0 --> Ainda nao creditados
      GROUP BY emp.cdempres
             ,emp.nmresemp
             ,trunc(pfp.dtmvtolt)
             ,pfp.dthordeb
             ,pfp.dsobscre;

  --Variaveis de E-mail
  vr_email_assunto VARCHAR2(300);
  vr_email_destino VARCHAR2(300);
  vr_email_corpo   VARCHAR2(32767);
  vr_lista         VARCHAR2(4000);
  vr_contagem      INTEGER;

  -- Variaveis de Erro
  vr_dscritic   VARCHAR2(4000);

  -- Variaveis Excecao
  vr_exc_erro EXCEPTION;

  BEGIN

    vr_email_destino := gene0001.fn_param_sistema('CRED', pr_cdcooper,'FOLHAIB_EMAIL_ALERT_PROC');
    vr_email_assunto := 'Folha de Pagamento - Horário Portabilidade expirado com pagamentos pendentes ' || pr_cdcooper;
    vr_email_corpo   := 'O horário limite da portabilidade foi atingido e ainda temos ' ||
                        'pagamentos pendentes de crédito para a data da hoje. Abaixo ' ||
                        'trazemos uma listagem dos mesmos. Lembramos que para que haja os ' ||
                        'créditos, este horário deve ser flexibilizado na tela PARFOL para ' ||
                        'a cooperativa. ' ||
                        '<br>' ||
                        '<br>' ||
                        '<table>' ||
                          '<thead align="center" style="background-color: #DCDCDC;">' ||
                            '<td width="200px">' ||
                              '<b>Empresa</b>' ||
                            '</td>' ||
                            '<td width="100px">' ||
                              '<b>Dt.Agto</b>' ||
                            '</td>' ||
                            '<td width="100px">' ||
                              '<b>Dt.Debito</b>' ||
                            '</td>' ||
                            '<td width="120px">' ||
                              '<b>Total</b>' ||
                            '</td>' ||
                            '<td width="100px">' ||
                              '<b>Tarifa</b>' ||
                            '</td>' ||
                            '<td width="250px">' ||
                              '<b>Erro em crédito anterior</b>' ||
                            '</td>' ||
                          '</thead>' ||
                          '<tbody align="center" style="background-color: #F0F0F0;">';

    vr_contagem := 0;

    -- Busca pelas empresas que possuem pagamentos com débito pendente e estouro solicitado
    FOR rw_crapemp IN cr_crapemp(pr_cdcooper => pr_cdcooper,
                                 pr_dtmvtolt => pr_rw_crapdat.dtmvtolt) LOOP
      vr_lista :=  vr_lista ||
                  '<tr>' ||
                    '<td>' ||
                      to_char(vr_contagem, '00') || ' - ' || rw_crapemp.nmresemp ||
                    '</td>' ||
                    '<td>' ||
                      to_char(rw_crapemp.dtmvtolt,'DD/MM') ||
                    '</td>' ||
                    '<td>' ||
                      to_char(rw_crapemp.dthordeb,'DD/MM') ||
                    '</td>' ||
                    '<td>' ||
                      'R$ ' || to_char(rw_crapemp.vllctpag,'fm9g999g999g999g999g990d00') ||
                    '</td>' ||
                    '<td>' ||
                      to_char(rw_crapemp.vltotpag,'fm9g999g999g999g999g990d00') ||
                    '</td>' ||
                    '<td>' ||
                      rw_crapemp.dsobscre ||
                    '</td>' ||
                  '</tr>';

      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'FOLH0001' 
                           , pr_cdcooper => pr_cdcooper
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_alerta_creditos_pendentes. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' – NO VALOR TOTAL DE R$ ' || to_char(rw_crapemp.vllctpag,'fm9g999g999g999g999g990d00') || ' NÃO SERA EFETUADO DEVIDO HORARIO PORTABILIDADE'
                           , pr_idprglog => vr_idprglog);

      vr_contagem := vr_contagem + 1;
    END LOOP;
    -- Somente se encontrou algum pagamento
    IF length(vr_lista) > 0 THEN

      vr_lista := vr_lista || '</tbody></table>';
      -- Envia e-mail para a central de folha de pagamento
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'FOLH0001'
                                ,pr_des_destino     => vr_email_destino
                                ,pr_des_assunto     => vr_email_assunto
                                ,pr_des_corpo       => vr_email_corpo || vr_lista
                                ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'S' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      IF vr_dscritic IS NOT NULL  THEN
        vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro na rotina pc_alerta_creditos_pendentes. Detalhes: PROBLEMA AO SOLICITAR EMAIL CRED PENDEN - ' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;

      -- Efetua Commit
      COMMIT;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer a operacao
      ROLLBACK;
      -- envia ao LOG o problema ocorrido
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'FOLH0001' 
                           , pr_cdcooper => pr_cdcooper
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem => vr_dscritic
                           , pr_idprglog => vr_idprglog);
     
    WHEN OTHERS THEN
      -- Desfazer a operacao
      ROLLBACK;
      
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      
      -- envia ao LOG o problema ocorrido
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'FOLH0001' 
                           , pr_cdcooper => pr_cdcooper
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro na rotina pc_alerta_creditos_pendentes. Detalhes: CREDITO DE FOLHA - ' || vr_dscritic
                           , pr_idprglog => vr_idprglog);
      
  END pc_alerta_creditos_pendentes;

  /* Alerta transferências pendentes de retorno do SPB  */
  PROCEDURE pc_alerta_transf_penden_spb (pr_cdcooper IN crapcop.cdcooper%TYPE
                                        ,pr_rw_crapdat IN BTCH0001.CR_CRAPDAT%ROWTYPE) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_alerta_transf_penden_spb             Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Marcos Martini
  --  Data     : Setembro/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Alerta a central de folha de pagamento e Financeiro se houverem pagamentos
  --             pendentes de retorno do SPB
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Busca transferências pendentes
  CURSOR cr_transfer IS
    SELECT emp.cdempres
          ,emp.nmresemp
          ,ass.cdagenci
          ,trunc(pfp.dtmvtolt) dtmvtolt
          ,pfp.dthorcre
          ,gene0002.fn_mask_conta(lfp.nrdconta) nrdconta
          ,ccs.nmfuncio
          ,lfp.vllancto
          ,ccs.cdbantrf
          ,ccs.cdagetrf
          ,trunc(ccs.nrctatrf)||decode(trim(ccs.nrdigtrf),NULL,'','-'||ccs.nrdigtrf) nrctatrf
      FROM crapccs ccs
          ,craplfp lfp
          ,crappfp pfp
          ,crapemp emp
          ,crapass ass
      WHERE pfp.cdcooper = lfp.cdcooper
        AND pfp.cdempres = lfp.cdempres
        AND pfp.nrseqpag = lfp.nrseqpag
        AND emp.cdcooper = pfp.cdcooper
        AND emp.cdempres = pfp.cdempres
        AND lfp.cdcooper = ccs.cdcooper
        AND lfp.nrdconta = ccs.nrdconta
        AND lfp.nrcpfemp = ccs.nrcpfcgc
        AND emp.cdcooper = ass.cdcooper
        AND emp.nrdconta = ass.nrdconta
        AND pfp.cdcooper = pr_cdcooper
        AND trunc(pfp.dthorcre) <= pr_rw_crapdat.dtmvtolt
        AND lfp.idtpcont = 'T' --> CTASAL
        AND lfp.idsitlct = 'L' --> Ainda pendente de retorno
        AND pfp.flsitcre = 1   --> Já creditados
      ORDER BY emp.cdempres
              ,emp.nmresemp
              ,trunc(pfp.dtmvtolt)
              ,pfp.dthorcre
              ,lfp.nrdconta;


  --Variaveis de E-mail
  vr_email_assunto VARCHAR2(300);
  vr_email_destino VARCHAR2(300);
  vr_email_corpo   VARCHAR2(32767);
  vr_lista         VARCHAR2(4000);

  -- Variaveis de Erro
  vr_dscritic   VARCHAR2(4000);

  -- Variaveis Excecao
  vr_exc_erro EXCEPTION;

  BEGIN

    vr_email_destino := gene0001.fn_param_sistema('CRED', pr_cdcooper,'FOLHAIB_EMAIL_ALERT_PROC')||','||gene0001.fn_param_sistema('CRED', pr_cdcooper,'FOLHAIB_EMAIL_ALERT_FIN');


    vr_email_assunto := 'Folha de Pagamento - Pagtos sem Retorno SPB - Coop ' || pr_cdcooper;
    vr_email_corpo   := 'O horário limite de retorno do SPB foi atingido e ainda temos ' ||
                        'pagamentos pendentes de retorno com crédito até a data de hoje. Abaixo ' ||
                        'trazemos uma listagem dos mesmos. Solicitamos que a situação seja alinhada  ' ||
                        ' com a TI para que os mesmos sejam Estornados ou marcados como Transmitidos. '||
                        '<br>' ||
                        '<br>' ||
                        '<table>' ||
                          '<thead align="center" style="background-color: #DCDCDC;">' ||
                            '<td width="200px">' ||'<b>Empresa</b>' ||'</td>' ||
                            '<td width="30px">' ||'<b>PA</b>' ||'</td>' ||
                            '<td width="60px">' ||'<b>Dt.Agto</b>' ||'</td>' ||
                            '<td width="60px">' ||'<b>Dt.Cred.</b>' ||'</td>' ||
                            '<td width="200px">' ||'<b>Empregado</b>' ||'</td>' ||
                            '<td width="80px">' ||'<b>Valor</b>' ||'</td>' ||
                            '<td width="80px">' ||'<b>Bco.Trf.</b>' ||'</td>' ||
                            '<td width="80px">' ||'<b>Age.Trf.</b>' ||'</td>' ||
                            '<td width="80px">' ||'<b>Cta.Trf.</b>' ||'</td>' ||
                          '</thead>' ||
                          '<tbody align="center" style="background-color: #F0F0F0;">';

    -- Busca pelos lançamentos pendentes de transferências
    FOR rw_transfer IN cr_transfer LOOP
      vr_lista :=  vr_lista ||
                  '<tr>' ||
                    '<td align="left">' || rw_transfer.cdempres||'-'||rw_transfer.nmresemp|| '</td>' ||
                    '<td>' || rw_transfer.cdagenci ||'</td>' ||
                    '<td>' ||to_char(rw_transfer.dtmvtolt,'DD/MM') ||'</td>' ||
                    '<td>' ||to_char(rw_transfer.dthorcre,'DD/MM HH24:MI') ||'</td>' ||
                    '<td align="left">' ||rw_transfer.nrdconta||'-'||rw_transfer.nmfuncio ||'</td>' ||
                    '<td align="right">' ||to_char(rw_transfer.vllancto,'fm9g999g999g999g999g990d00') ||'</td>' ||
                    '<td align="right">' ||rw_transfer.cdbantrf ||'</td>' ||
                    '<td align="right">' ||rw_transfer.cdagetrf ||'</td>' ||
                    '<td align="right">' ||rw_transfer.nrctatrf ||'</td>' ||
                  '</tr>';

      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'FOLH0001' 
                           , pr_cdcooper => pr_cdcooper
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Errotratado na rotina pc_alerta_transf_penden_spb. Detalhes: CREDITO DE FOLHA CTASAL – EMP ' || rw_transfer.cdempres || ' - CTA '||rw_transfer.nrdconta||' – NO VALOR TOTAL DE R$ ' || to_char(rw_transfer.vllancto,'fm9g999g999g999g999g990d00') || ' NAO OBTEVE RETORNO DO SPB!'
                           , pr_idprglog => vr_idprglog);     

    END LOOP;
    -- Somente se encontrou algum pagamento
    IF length(vr_lista) > 0 THEN

      vr_lista := vr_lista || '</tbody></table>';

      gene0002.pc_clob_para_arquivo(pr_clob => vr_email_corpo || vr_lista
                                   ,pr_caminho => '/micros/cecred/marcos'
                                   ,pr_arquivo => 'email.html'
                                   ,pr_des_erro => vr_dscritic);


      -- Envia e-mail para a central de folha de pagamento
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'FOLH0001'
                                ,pr_des_destino     => vr_email_destino
                                ,pr_des_assunto     => vr_email_assunto
                                ,pr_des_corpo       => vr_email_corpo || vr_lista
                                ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'S' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      IF vr_dscritic IS NOT NULL  THEN
        vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro na rotina pc_alerta_transf_penden_spb. Detalhes: AVISO TRANSF. CTASAL PENDEN - ERRO NO EMAIL - ' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;

      -- Efetua Commit
      COMMIT;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer a operacao
      ROLLBACK;
      -- envia ao LOG o problema ocorrido
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'FOLH0001' 
                           , pr_cdcooper => pr_cdcooper
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem => vr_dscritic
                           , pr_idprglog => vr_idprglog);
        
    WHEN OTHERS THEN
      -- Desfazer a operacao
      ROLLBACK;
      
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      
      -- envia ao LOG o problema ocorrido
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'FOLH0001' 
                           , pr_cdcooper => pr_cdcooper
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro na rotina pc_alerta_transf_penden_spb. Detalhes: AVISO TRANSF. CTASAL PENDEN - ERRO NO EMAIL - ' || SQLERRM
                           , pr_idprglog => vr_idprglog);
       
  END pc_alerta_transf_penden_spb;


  /* Busca todos os pagamentos já creditados e com pendência de estorno. */
  PROCEDURE pc_concili_estornos_pendentes (pr_cdcooper IN crapcop.cdcooper%TYPE
                                          ,pr_rw_crapdat IN BTCH0001.CR_CRAPDAT%ROWTYPE) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_concili_estornos_pendentes             Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Lucas Afonso Lombardi Moreira
  --  Data     : Julho/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Busca todos os pagamentos já creditados e com pendência de estorno.
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Busca empresas que possuem pagamentos com débito pendente e estouro solicitado
  CURSOR cr_crapemp (pr_cdcooper IN crapemp.cdcooper%TYPE
                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT emp.cdempres
          ,emp.nrdconta
          ,emp.idtpempr
          ,emp.dsdemail
          ,pfp.nrseqpag
          ,sum(lfp.vllancto) OVER(PARTITION BY emp.cdempres) vllancto
          ,row_number() OVER(PARTITION BY emp.cdempres ORDER BY emp.cdempres) emp_sequenci
          ,COUNT(1) OVER (PARTITION BY emp.cdempres) emp_totalreg
          ,lfp.ROWID lfp_rowid
          ,pfp.ROWID pfp_rowid
      FROM crapemp emp
          ,crappfp pfp
          ,craplfp lfp
     WHERE pfp.cdcooper = pr_cdcooper
       AND pfp.dtcredit <= pr_dtmvtolt
       AND emp.cdcooper = pfp.cdcooper
       AND emp.cdempres = pfp.cdempres
       AND lfp.cdcooper = pfp.cdcooper
       AND lfp.cdempres = pfp.cdempres
       AND lfp.nrseqpag = pfp.nrseqpag
       AND pfp.flsitcre = 1 --> Já creditados
       AND lfp.idsitlct = 'E'
       AND (lfp.idtpcont = 'C'
        OR NOT EXISTS(SELECT 1
                        FROM craplcs lcs
                       WHERE lcs.cdcooper = lfp.cdcooper
                         AND lcs.nrridlfp = lfp.progress_recid
               ))
     ORDER BY emp.cdempres;

  -- Busca numero do lote
  CURSOR cr_craptab (pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_cdempres IN crapemp.cdempres%TYPE) IS
  SELECT to_number(dstextab) nrdolote
    FROM craptab
   WHERE craptab.cdcooper = pr_cdcooper
     AND upper(craptab.nmsistem) = 'CRED'
     AND upper(craptab.tptabela) = 'GENERI'
     AND upper(craptab.cdacesso) = 'NUMLOTEFOL'
     AND craptab.cdempres = 0
     AND craptab.tpregist = pr_cdempres;
  rw_craptab cr_craptab%ROWTYPE;

  -- Buscar Lote
  CURSOR cr_craplot (pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                    ,pr_nrdolote IN craptab.dstextab%TYPE) IS
    SELECT nrseqdig,
           qtinfoln,
           qtcompln,
           vlinfodb,
           vlcompdb,
           ROWID
       FROM craplot
      WHERE craplot.cdcooper = pr_cdcooper
        AND craplot.dtmvtolt = pr_dtmvtolt
        AND craplot.cdagenci = 1
        AND craplot.cdbccxlt = 100
        AND craplot.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;

  -- Variaveis
  vr_cdhisest VARCHAR2(400);

  --Variaveis de E-mail
  vr_hasfound      BOOLEAN;

  -- Variaveis de Erro
  vr_dscritic   VARCHAR2(4000);

  -- Variaveis Excecao
  vr_exc_erro EXCEPTION;

  BEGIN
    -- Busca pelas empresas que possuem pagamentos com débito pendente e estouro solicitado
    FOR rw_crapemp IN cr_crapemp(pr_cdcooper => pr_cdcooper,
                                 pr_dtmvtolt => pr_rw_crapdat.dtmvtolt) LOOP
      BEGIN
        -- Atualiza lançamentos do pagamento de folha
        BEGIN
          UPDATE craplfp
             SET idsitlct  = 'D'
           WHERE ROWID = rw_crapemp.lfp_rowid
             AND idsitlct = 'E';
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);            
            vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_concili_estornos_pendentes. Detalhes: ESTORNO DO PAGAMENTO – EMP ' || rw_crapemp.cdempres || ' – CONTA ' || rw_crapemp.vllancto || ' – DEVOLUCAO DE CREDITOS COM PROBLEMA, TOTAL DE R$ ' || to_char(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00') || ' - ' || SQLERRM;
            RAISE vr_exc_erro;
        END;

        -- Se for a ultima folha da empresa
        IF rw_crapemp.emp_sequenci = rw_crapemp.emp_totalreg THEN

          IF rw_crapemp.idtpempr = 'C' THEN
            vr_cdhisest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'FOLHAIB_HIS_ESTOR_COOP');
          ELSE
            vr_cdhisest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'FOLHAIB_HIS_ESTOR_EMPR');
          END IF;

          -- Busca o numero do lote
          OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                         ,pr_cdempres => rw_crapemp.cdempres);
          FETCH cr_craptab INTO rw_craptab;
          vr_hasfound := cr_craptab%FOUND;
          CLOSE cr_craptab;

          -- Verificar se existe informacao, e gerar erro caso nao exista
          IF NOT vr_hasfound THEN
            vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_concili_estornos_pendentes. Detalhes: ESTORNO DO PAGAMENTO – EMP ' || rw_crapemp.cdempres || ' – CONTA ' || rw_crapemp.vllancto || ' – DEVOLUCAO DE CREDITOS COM PROBLEMA, TOTAL DE R$ ' || to_char(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00') || ': ' || 'NAO ENCONTROU NUMERO DO LOTE.';
            RAISE vr_exc_erro;
          END IF;

          -- Busca Lote
          OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                         ,pr_nrdolote => rw_craptab.nrdolote);
          FETCH cr_craplot INTO rw_craplot;
          vr_hasfound := cr_craplot%FOUND;
          CLOSE cr_craplot;

          -- Se não existir
          IF NOT vr_hasfound THEN
            BEGIN
              -- Cria Lote
              INSERT INTO craplot (cdcooper
                                  ,dtmvtolt
                                  ,cdagenci
                                  ,cdbccxlt
                                  ,nrdolote
                                  ,tplotmov
                                  ,qtcompln
                                  ,vlinfocr
                                  ,vlcompcr
                                  ,nrseqdig)
                            VALUES(pr_cdcooper
                                  ,pr_rw_crapdat.dtmvtolt
                                  ,1           -- cdagenci
                                  ,100         -- cdbccxlt
                                  ,rw_craptab.nrdolote
                                  ,1
                                  ,1
                                  ,rw_crapemp.vllancto
                                  ,rw_crapemp.vllancto
                                  ,1)
                         RETURNING nrseqdig
                              INTO rw_craplot.nrseqdig;
            EXCEPTION
              WHEN OTHERS THEN
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado rotina pc_concili_estornos_pendentes. Detalhes: ESTORNO DO PAGAMENTO – EMP ' || rw_crapemp.cdempres || ' – CONTA ' || rw_crapemp.vllancto || ' – DEVOLUCAO DE CREDITOS COM PROBLEMA, TOTAL DE R$ ' || to_char(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00') || ' - ' || SQLERRM;
                RAISE vr_exc_erro;
            END;
          ELSE -- Se Existir
            BEGIN
              -- Atualiza Lote
              UPDATE craplot
                 SET qtcompln = qtcompln + 1
                   , vlinfocr = vlinfocr + rw_crapemp.vllancto
                   , vlcompcr = vlcompcr + rw_crapemp.vllancto
                   , nrseqdig = nrseqdig + 1
               WHERE craplot.cdcooper = pr_cdcooper
                 AND craplot.dtmvtolt = pr_rw_crapdat.dtmvtolt
                 AND craplot.cdagenci = 1
                 AND craplot.cdbccxlt = 100
                 AND craplot.nrdolote = rw_craptab.nrdolote
           RETURNING nrseqdig
                INTO rw_craplot.nrseqdig;
            EXCEPTION
              WHEN OTHERS THEN
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_concili_estornos_pendentes. Detalhes: ESTORNO DO PAGAMENTO – EMP ' || rw_crapemp.cdempres || ' – CONTA ' || rw_crapemp.vllancto || ' – DEVOLUCAO DE CREDITOS COM PROBLEMA, TOTAL DE R$ ' || to_char(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00') ||' - ' || SQLERRM;
                RAISE vr_exc_erro;
            END;
          END IF;
          -- Cria o lancamento
          BEGIN
            INSERT INTO craplcm (dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,nrdconta
                                ,nrdctabb
                                ,nrdctitg
                                ,nrdocmto
                                ,cdhistor
                                ,vllanmto
                                ,nrseqdig
                                ,cdcooper)
                         VALUES(pr_rw_crapdat.dtmvtolt
                               ,1
                               ,100
                               ,rw_craptab.nrdolote
                               ,rw_crapemp.nrdconta
                               ,rw_crapemp.nrdconta
                               ,gene0002.fn_mask(rw_crapemp.nrdconta,'99999999') -- nrdctitg
                               ,rw_craplot.nrseqdig -- atualizado da LOTE acima
                               ,vr_cdhisest
                               ,rw_crapemp.vllancto -- Valor dos lançamentos com erro
                               ,rw_craplot.nrseqdig -- atualizado da LOTE acima
                               ,pr_cdcooper);
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_concili_estornos_pendentes. Detalhes: ESTORNO DO PAGAMENTO – EMP ' || rw_crapemp.cdempres || ' – CONTA ' || rw_crapemp.nrdconta || ' – DEVOLUCAO DE CREDITOS COM PROBLEMA, TOTAL DE R$ ' || to_char(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00') ||' - ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
          -- Enviar e-mail informando para a empresa da devolução
          gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => 'FOLH0001'
                                    ,pr_des_destino     => TRIM(rw_crapemp.dsdemail)
                                    ,pr_des_assunto     => 'Folha de Pagamento - Estorno de Débito'
                                    ,pr_des_corpo       => 'Olá,<br> Houve(ram) problema(s) com o(s) lançamentos de folha de pagamento agendados em sua Conta-Online. <br>'||
                                                           'Com isso, efetuamos o estorno no valor total de R$ '||TO_CHAR(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')|| '.<br>'||
                                                           'Para maiores detalhes dos problemas ocorridos, favor verificar sua Conta-Online ou acionar seu Posto de Atendimento. <br><br> ' ||
                                                           'Atenciosamente,<br>Sistema AILOS.'
                                    ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                    ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                    ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                    ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                    ,pr_des_erro        => vr_dscritic);
          -- envia ao LOG
          CECRED.pc_log_programa(pr_dstiplog => 'O'
                               , pr_cdprograma => 'FOLH0001' 
                               , pr_cdcooper => pr_cdcooper
                               , pr_tpexecucao => 0
                               , pr_tpocorrencia => 1 
                               , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Rotina pc_concili_estornos_pendentes. Detalhes: DEVOLUÇÃO TOTAL DE R$ ' || to_char(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00') || ' EFETUADA COM SUCESSO.'
                               , pr_idprglog => vr_idprglog);

          --Efetua COMMIT
          COMMIT;
        END IF;
      EXCEPTION
        WHEN vr_exc_erro THEN
           -- Desfazer a operacao
          ROLLBACK;
          -- envia ao LOG o problema ocorrido
          CECRED.pc_log_programa(pr_dstiplog => 'O'
                               , pr_cdprograma => 'FOLH0001' 
                               , pr_cdcooper => pr_cdcooper
                               , pr_tpexecucao => 0
                               , pr_tpocorrencia => 1 
                               , pr_dsmensagem => vr_dscritic
                               , pr_idprglog => vr_idprglog);
          
        WHEN OTHERS THEN
          -- Desfazer a operacao
          ROLLBACK;
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- envia ao LOG o problema ocorrido
          CECRED.pc_log_programa(pr_dstiplog => 'O'
                               , pr_cdprograma => 'FOLH0001' 
                               , pr_cdcooper => pr_cdcooper
                               , pr_tpexecucao => 0
                               , pr_tpocorrencia => 1 
                               , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_concili_estornos_pendentes. Detalhes: ESTORNO DO PAGAMENTO – EMP ' || rw_crapemp.cdempres || ' – CONTA ' || rw_crapemp.vllancto || ' – DEVOLUCAO DE CREDITOS COM PROBLEMA, TOTAL DE R$ ' || to_char(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00') || ' - ' || SQLERRM
                               , pr_idprglog => vr_idprglog);          
      END;
    END LOOP;
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer a operacao
      ROLLBACK;
      -- envia ao LOG o problema ocorrido
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'FOLH0001' 
                           , pr_cdcooper => pr_cdcooper
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem => vr_dscritic
                           , pr_idprglog => vr_idprglog);
        
    WHEN OTHERS THEN
      -- Desfazer a operacao
      ROLLBACK;
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      -- envia ao LOG o problema ocorrido
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'FOLH0001' 
                           , pr_cdcooper => pr_cdcooper
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_concili_estornos_pendentes. Detalhes: ESTORNO DO PAGAMENTO ' || ' - ' || SQLERRM
                           , pr_idprglog => vr_idprglog); 
    
  END pc_concili_estornos_pendentes;

  -- Realiza o Processamento de débitos dos pagamentos aprovados
  PROCEDURE pc_debito_pagto_aprovados (pr_cdcooper IN craptab.cdcooper%TYPE
                                      ,pr_rw_crapdat IN BTCH0001.CR_CRAPDAT%ROWTYPE) IS

    /* .............................................................................

      Programa: pc_debito_pagto_aprovados
      Sistema : Rotina chamada via job
      Sigla   : CRED
      Autor   : Vanessa Klein
      Data    : Julho/2015.                  Ultima atualizacao: 10/10/2017

      Dados referentes ao programa:

      Frequencia: 5 em 5 minutos

      Objetivo  : Realiza o Processamento de débitos dos pagamentos aprovados pelas empresas

      Observacao: -----

      Alteracoes: 23/11/2015 - Ajustado para reprovar de forma automatica os pagamentos
                               com DTDEBITO anterior a dois dias. (Andre Santos - SUPERO)

                  22/12/2015 - Removida a trava para retornar os débitos com problema
                               somente de 2 em 2 horas (Marcos-Supero)

                  25/01/2016 - Melhorias nos tratamentos de exceção e envio ao log
                               a cada tentativa de debito (Marcos-Supero)

                  27/01/2016 - Incluir controle de lançamentos sem crédito (Marcos-Supero)

                  07/07/2016 - Mudança nos parâmetros da chamada de saldo para melhora
                               de performance - Marcos(Supero)
                               
                  10/10/2017 - Adicionar NVL na soma do campo vllctpag.
                               (Chamado 754474) - (Fabricio)
                               
                  29/05/2018 -  Processamento de débitos dos pagamentos aprovados pelas empresas utilizando
                                LANC0001  Rangel Decker  AMcom
    ..............................................................................*/

    -- Buscar o email da agencia vinclulada a conta da empresa
    CURSOR cr_crapage(pr_cdcooper crapemp.cdcooper%TYPE,
                      pr_cdagenci crapage.cdagenci%TYPE) IS
      SELECT dsdemail
        FROM crapage
       WHERE cdcooper = pr_cdcooper
         AND cdagenci = pr_cdagenci;

    -- Busca empresas que possuem pagamentos com débito pendente
    CURSOR cr_crapemp(pr_cdcooper crapemp.cdcooper%TYPE,
                      pr_dtmvtolt crapdat.dtmvtolt%TYPE,
                      pr_dtmvtoan crapdat.dtmvtoan%TYPE) IS
      SELECT emp.cdempres
            ,emp.nrdconta
            ,emp.dsdemail
            ,ass.nmprimtl
            ,ass.cdagenci
            ,ass.vllimcre
            ,ass.dtelimin
            ,ass.cdsitdtl
            ,pfp.idsitapr
            ,SUM(lfp.vllancto) vllancto
            ,MAX(pfp.dthordeb) dthordeb
            ,DECODE(pfp.dtdebito,pr_dtmvtolt,'N',pr_dtmvtoan,'N','S') flpgtexp
            ,ass.cdsitdct
            ,ass.dtdemiss
      FROM crappfp pfp
          ,crapemp emp
          ,craplfp lfp
          ,crapass ass
     WHERE pfp.cdcooper = pr_cdcooper
       AND pfp.dtdebito <= pr_dtmvtolt
       AND pfp.cdcooper = emp.cdcooper
       AND pfp.cdempres = emp.cdempres
       AND pfp.cdcooper = lfp.cdcooper
       AND pfp.cdempres = lfp.cdempres
       AND pfp.nrseqpag = lfp.nrseqpag
       AND pfp.cdcooper = ass.cdcooper
       AND emp.nrdconta = ass.nrdconta
       AND pfp.idsitapr > 3 --> Aprovados
       AND pfp.idsitapr <> 6 -- Transação pendente
       AND pfp.flsitdeb = 0 --> Ainda nao debitado
     GROUP BY emp.cdempres
             ,emp.nrdconta
             ,emp.dsdemail
             ,ass.nmprimtl
             ,ass.cdagenci
             ,ass.vllimcre
             ,ass.dtelimin
             ,ass.cdsitdtl
             ,pfp.idsitapr
             ,DECODE(pfp.dtdebito,pr_dtmvtolt,'N',pr_dtmvtoan,'N','S')
             ,ass.cdsitdct
             ,ass.dtdemiss;
      rw_crapemp cr_crapemp%ROWTYPE;

      -- Busca o lote da empresa na craptab
     CURSOR cr_craptab(pr_cdcooper crapemp.cdcooper%TYPE,
                       pr_cdempres crapemp.cdempres%TYPE) IS
        SELECT to_number(dstextab) nrdolote
          FROM craptab
         WHERE craptab.cdcooper = pr_cdcooper
         AND upper(craptab.nmsistem) = 'CRED'
         AND upper(craptab.tptabela) = 'GENERI'
         AND craptab.cdempres = 0
         AND upper(craptab.cdacesso) = 'NUMLOTEFOL'
         AND craptab.tpregist = pr_cdempres;
     rw_craptab cr_craptab%ROWTYPE;

     --Verifica se já existe o lote criado
     CURSOR cr_craplot(pr_cdcooper crapemp.cdcooper%TYPE,
                       pr_dtmvtolt crapdat.dtmvtolt%TYPE,
                       pr_nrdolote craplot.nrdolote%TYPE) IS
        SELECT nrseqdig,
               qtinfoln,
               qtcompln,
               vlinfodb,
               vlcompdb,
               ROWID
          FROM craplot
         WHERE craplot.cdcooper = pr_cdcooper
           AND craplot.dtmvtolt = pr_dtmvtolt
           AND craplot.cdagenci = 1
           AND craplot.cdbccxlt = 100
           AND craplot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;

     --Pagamentos aprovados ainda não debitados por histórico
     CURSOR cr_crappfp(pr_cdcooper crapemp.cdcooper%TYPE,
                    pr_dtmvtolt crapdat.dtmvtolt%TYPE,
                    pr_cdempres crapemp.cdempres%TYPE,
                    pr_idsitapr crappfp.idsitapr%TYPE) IS
        SELECT decode(emp.idtpempr,'C',ofp.cdhsdbcp,ofp.cdhisdeb) cdhisdeb
               ,SUM(lfp.vllancto) vllancto
          FROM crappfp pfp
              ,crapemp emp
              ,craplfp lfp
              ,crapofp ofp
         WHERE pfp.cdcooper = pr_cdcooper
           AND pfp.dtdebito <= pr_dtmvtolt
           AND pfp.cdempres = pr_cdempres
           AND pfp.cdcooper = emp.cdcooper
           AND pfp.cdempres = emp.cdempres
           AND pfp.cdcooper = lfp.cdcooper
           AND pfp.cdempres = lfp.cdempres
           AND pfp.nrseqpag = lfp.nrseqpag
           AND lfp.cdcooper = ofp.cdcooper
           AND lfp.cdorigem = ofp.cdorigem
           AND pfp.idsitapr = pr_idsitapr --> Aprovados
           AND pfp.flsitdeb = 0 --> Ainda nao debitado
         GROUP BY decode(emp.idtpempr,'C',ofp.cdhsdbcp,ofp.cdhisdeb);
        rw_crappfp cr_crappfp%ROWTYPE;

      -- Variaveis
      vr_dsmensag   VARCHAR2(4000);
      vr_email_dest VARCHAR2(1000);
      vr_vlsldisp   craplfp.vllancto%TYPE;
      vr_errhisto   craplft.cdhistor%TYPE;
      vr_nrseqdig   craplot.nrseqdig%TYPE;
      vr_qtcompln   craplot.qtcompln%TYPE;
      vr_qtinfoln   craplot.qtinfoln%TYPE;
      vr_vlcompdb   craplot.vlcompdb%TYPE;
      vr_vlinfodb   craplot.vlinfodb%TYPE;

      -- Variaveis de Erro
      vr_cdcritic   crapcri.cdcritic%TYPE DEFAULT NULL;
      vr_dscritic   VARCHAR2(4000) DEFAULT NULL;
      vr_tab_erro   GENE0001.typ_tab_erro;
      vr_des_erro  VARCHAR2(4000);
      vr_tab_sald EXTR0001.typ_tab_saldos;

      -- Variaveis Excecao
      vr_exc_erro EXCEPTION;

      BEGIN

        -- Efetuar atualização da CAPA dos PAgamentos pendentes de debito e
        -- que estejam com valores divergentes dos lançamentos
        BEGIN
          UPDATE crappfp pfp
             SET pfp.vllctpag = (SELECT NVL(SUM(nvl(lfp.vllancto,0)),0)
                                   FROM craplfp lfp
                                 WHERE lfp.cdcooper = pfp.cdcooper
                                   AND lfp.cdempres = pfp.cdempres
                                   AND lfp.nrseqpag = pfp.nrseqpag)
                ,pfp.qtlctpag = (SELECT COUNT(1)
                                   FROM craplfp lfp
                                 WHERE lfp.cdcooper = pfp.cdcooper
                                   AND lfp.cdempres = pfp.cdempres
                                   AND lfp.nrseqpag = pfp.nrseqpag
                                   AND lfp.vllancto > 0)
                ,pfp.qtregpag = (select count(1)
                                   from craplfp lfp
                                  where lfp.cdcooper = pfp.cdcooper
                                    and lfp.cdempres = pfp.cdempres
                                    and lfp.nrseqpag = pfp.nrseqpag)
           WHERE pfp.cdcooper = pr_cdcooper
             AND pfp.flsitdeb = 0 --> Ainda não debitados
             AND (   pfp.vllctpag != (SELECT SUM(nvl(lfp.vllancto,0))
                                        FROM craplfp lfp
                                       WHERE lfp.cdcooper = pfp.cdcooper
                                         AND lfp.cdempres = pfp.cdempres
                                         AND lfp.nrseqpag = pfp.nrseqpag)
                  OR pfp.qtlctpag != (SELECT COUNT(1)
                                        FROM craplfp lfp
                                       WHERE lfp.cdcooper = pfp.cdcooper
                                         AND lfp.cdempres = pfp.cdempres
                                         AND lfp.nrseqpag = pfp.nrseqpag
                                         AND lfp.vllancto > 0)
                  OR pfp.qtregpag != (SELECT COUNT(1)
                                        FROM craplfp lfp
                                       WHERE lfp.cdcooper = pfp.cdcooper
                                         AND lfp.cdempres = pfp.cdempres
                                         AND lfp.nrseqpag = pfp.nrseqpag));
          -- Gravar
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            vr_cdcritic := 9999;
            vr_dscritic := 'Erro ao atualizar CAPAS de Pagamentos Divergentes: '||SQLERRM;
            -- Executa a exceção
            RAISE vr_exc_erro;
        END;

        -- Percorre as empresas
        FOR rw_crapemp IN cr_crapemp(pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                                     pr_dtmvtoan => pr_rw_crapdat.dtmvtoan) LOOP

          BEGIN
            --Verifica se a empresa ainda tenha conta ativa na cooperativa ou esta em prejuízo, caso sim, reprova o pagamento
            IF rw_crapemp.dtelimin IS NOT NULL OR
               rw_crapemp.cdsitdtl IN (7,8)    OR
               (rw_crapemp.cdsitdct IN (4) OR rw_crapemp.dtdemiss IS NOT NULL) THEN
              BEGIN
                UPDATE crappfp
                   SET idsitapr = 3  --Reprovado
                      ,cdopeest = 1  --Super Usuario
                      ,dsjusest = 'Pagamento reprovado pois a conta vinculada a empresa esta em prejuízo ou demitida da Cooperativa!'
                 WHERE cdcooper = pr_cdcooper
                   AND cdempres = rw_crapemp.cdempres
                   AND idsitapr > 3  --> Aprovados
                   AND flsitdeb = 0; --> Ainda nao debitado
              EXCEPTION
                WHEN OTHERS THEN
                  CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                  
                  vr_cdcritic := 9999;
                  vr_dscritic := 'Erro ao atualizar o registro na CRAPPFP: '||SQLERRM;
                  RAISE vr_exc_erro;
              END;

              -- Enviar e-mail informando a reprovação.
              vr_dsmensag := 'Olá, o cooperado '|| TO_CHAR(gene0002.fn_mask_conta(rw_crapemp.nrdconta)) ||' - '||TO_CHAR(rw_crapemp.nmprimtl)     ||
                             ' possui pagamento de folha com debito agendado para a data atual e sua conta está demitida' ||
                             ' junto a Cooperativa. Todos os pagamentos pendentes foram automaticamente reprovados, e os' ||
                             ' agendamentos não mais ocorrerão.<br><br>' ||
                             'Atenciosamente, <br>'||
                             'Sistema AILOS';

              --Traz o email da Central
              vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'FOLHAIB_EMAIL_ALERT_PROC');

              -- Enviar Email comunicando o cancelamento do produto
              gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                        ,pr_cdprogra        => 'FOLH0001'
                                        ,pr_des_destino     => TRIM(vr_email_dest)
                                        ,pr_des_assunto     => 'Folha de Pagamento - Empresa demitida com pagamento de folha agendada'
                                        ,pr_des_corpo       => vr_dsmensag
                                        ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                        ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                        ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                        ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                        ,pr_des_erro        => vr_dscritic);

              -- Envio centralizado de log de erro
              CECRED.pc_log_programa(pr_dstiplog => 'O'
                                   , pr_cdprograma => 'FOLH0001' 
                                   , pr_cdcooper => pr_cdcooper
                                   , pr_tpexecucao => 0
                                   , pr_tpocorrencia => 2 
                                   , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_debito_pagto_aprovados. Detalhes: DEBITO DE FOLHA – EMP '||TO_CHAR(rw_crapemp.cdempres) ||' – CONTA '|| TO_CHAR(gene0002.fn_mask_conta(rw_crapemp.nrdconta)) || ' NO VALOR DE R$ ' || TO_CHAR(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS=,.') || ' NÃO EFETUADO DEVIDO DESASSOCIACAO DA EMPRESA COOPERADA'
                                   , pr_idprglog => vr_idprglog);
              
            -- Verifica se o pagamento expirou (DTDEBITO anterior ao DTMVTOAN)
            ELSIF rw_crapemp.flpgtexp = 'S' THEN

              BEGIN
                UPDATE crappfp pfp
                   SET pfp.idsitapr = 3   --> Reprovado
                      ,pfp.cdopeest = '1' --> Super Usuario
                      ,pfp.dsjusest = 'Pagamento reprovado pois a empresa ficou sem saldo durante dois dias!'
                 WHERE pfp.cdcooper = pr_cdcooper
                   AND pfp.cdempres = rw_crapemp.cdempres
                   AND pfp.idsitapr > 3 --> Aprovados
                   AND pfp.flsitdeb = 0 --> Ainda nao debitado
                   AND pfp.dtdebito < pr_rw_crapdat.dtmvtoan; --> Data prevista anterior ha dois dias
              EXCEPTION
                WHEN OTHERS THEN
                  CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                  vr_cdcritic := 9999;
                  vr_dscritic := 'Erro ao atualizar o registro na CRAPPFP: '||SQLERRM;
                  RAISE vr_exc_erro;
              END;

              -- Conteudo do e-mail informando para a empresa a falta de saldo.
              vr_dsmensag := 'Olá,<br> Você agendou o debito de folha de pagamento ha mais de dois dias, porém '
                          || 'sua conta não possui saldo suficiente para a operação. Solicitamos que regularize '
                          || 'a situação, do contrário o crédito em folha de seus empregados não ocorrerá na '
                          || 'data programada. <br><br>'
                          || 'Detalhes da operação: <br>'
                          || 'Valor total do pagamento: R$ '||
              TO_CHAR(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')|| '<br>'
                          || 'Saldo em conta: R$ '||
              TO_CHAR(vr_vlsldisp, 'FM999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')|| '<br>'
                           || 'Limite de Credito: R$ '||
              TO_CHAR(rw_crapemp.vllimcre, 'FM999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')|| '<br>'
                           || 'Saldo + Limite: R$ '||
              TO_CHAR(vr_vlsldisp + rw_crapemp.vllimcre, 'FM999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')
                           || '<br><br>'
                           || 'Você poderá solicitar o estouro de conta desde que cancele estes pagamentos '
                           || 'e aprove-os novamente em sua Conta-On-Line. <br>'
                           || 'Lembramos que toda solicitação de estouro dependerá de análise / aprovação de '
                           || 'seu Posto de Atendimento. <br><br> '
                           || 'Atenciosamente,<br>Sistema AILOS.';

              -- Enviar e-mail informando para a empresa a falta de saldo.
              gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                        ,pr_cdprogra        => 'FOLH0001'
                                        ,pr_des_destino     => TRIM(rw_crapemp.dsdemail)
                                        ,pr_des_assunto     => 'Folha de Pagamento - Falta de saldo para debito'
                                        ,pr_des_corpo       => vr_dsmensag
                                        ,pr_des_anexo       => NULL --> Nao envia anexo
                                        ,pr_flg_remove_anex => 'N'  --> Remover os anexos passados
                                        ,pr_flg_remete_coop => 'N'  --> Se o envio sera do e-mail da Cooperativa
                                        ,pr_flg_enviar      => 'N'  --> Enviar o e-mail na hora
                                        ,pr_des_erro        => vr_dscritic);
              -- Se retornou erro
              IF vr_dscritic IS NOT NULL  THEN
                vr_dscritic := (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': REPROVACAO FOLHA PAGAMENTO - ERRO NO EMAIL - ' || vr_dscritic);
                RAISE vr_exc_erro;
              END IF;

              -- Enviar e-mail informando a reprovacao para o PA.
              vr_dsmensag := 'Olá, o cooperado '|| TO_CHAR(gene0002.fn_mask_conta(rw_crapemp.nrdconta))
                          ||' - '||TO_CHAR(rw_crapemp.nmprimtl)
                          ||' possui pagamento de folha com debito agendado e esta sem saldo ha mais de'
                          ||' dois dias. Todos os pagamentos pendentes e com data prevista de debito'
                          ||' anterior a ' || TO_CHAR(pr_rw_crapdat.dtmvtoan,'DD/MM/YY') ||' foram'
                          ||' automaticamente reprovados, e os agendamentos não mais ocorrerão.<br><br>'
                          ||'Atenciosamente, <br> Sistema AILOS';

              -- Buscando o email do PA
              OPEN cr_crapage(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => rw_crapemp.cdagenci);
              FETCH cr_crapage INTO vr_email_dest;
              CLOSE cr_crapage;

              -- Utilizaremos o email da Central se o PA nao possuir
              IF TRIM(vr_email_dest) IS NULL THEN
                vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'FOLHAIB_EMAIL_ALERT_PROC');
              END IF;

              -- Enviar e-mail informando ao PA nao que a empresa nao possui saldo em conta
              gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                        ,pr_cdprogra        => 'FOLH0001'
                                        ,pr_des_destino     => TRIM(vr_email_dest)
                                        ,pr_des_assunto     => 'Folha de Pagamento - Empresa sem saldo ha mais de dois dias'
                                        ,pr_des_corpo       => vr_dsmensag
                                        ,pr_des_anexo       => NULL --> nao envia anexo
                                        ,pr_flg_remove_anex => 'N'  --> Remover os anexos passados
                                        ,pr_flg_remete_coop => 'N'  --> Se o envio sera do e-mail da Cooperativa
                                        ,pr_flg_enviar      => 'N'  --> Enviar o e-mail na hora
                                        ,pr_des_erro        => vr_dscritic);
              -- Se retornou erro
              IF vr_dscritic IS NOT NULL  THEN
                 vr_dscritic := (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': REPROVACAO FOLHA PAGAMENTO - ERRO NO EMAIL - ' || vr_dscritic);
                 RAISE vr_exc_erro;
              END IF;

              -- Envio centralizado de log de erro
              CECRED.pc_log_programa(pr_dstiplog => 'O'
                                   , pr_cdprograma => 'FOLH0001' 
                                   , pr_cdcooper => pr_cdcooper
                                   , pr_tpexecucao => 0
                                   , pr_tpocorrencia => 2 
                                   , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_debito_pagto_aprovados. Detalhes: DEBITO DE FOLHA – EMP '||TO_CHAR(rw_crapemp.cdempres) ||' – CONTA ' || TO_CHAR(gene0002.fn_mask_conta(rw_crapemp.nrdconta)) || ' NO VALOR DE R$ ' ||  TO_CHAR(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS=,.') ||' NAO EFETUADO DEVIDO FALTA DE SALDO HA MAIS DE DOIS DIAS'
                                   , pr_idprglog => vr_idprglog);
              
            ELSE

              IF rw_crapemp.idsitapr != 4 THEN
                -- obtencao do saldo da conta sem o dia fechado
                extr0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper,
                                            pr_rw_crapdat => pr_rw_crapdat, --> Rowtype da crapdat da coop
                                            pr_cdagenci   => 0,
                                            pr_nrdcaixa   => 0,
                                            pr_cdoperad   => 1,
                                            pr_nrdconta   => rw_crapemp.nrdconta,
                                            pr_vllimcre   => rw_crapemp.vllimcre,
                                                    pr_flgcrass   => FALSE, --> Não carregar a crapass inteira
                                                    pr_tipo_busca => 'A', --> Busca da SDA do dia anterior
                                            pr_dtrefere   => pr_rw_crapdat.dtmvtolt,
                                            pr_des_reto   => vr_des_erro,
                                            pr_tab_sald   => vr_tab_sald,
                                            pr_tab_erro   => vr_tab_erro);
                -- Verifica se retornou erro durante a execução
                IF vr_des_erro <> 'OK' THEN
                  IF vr_tab_erro.COUNT > 0 THEN
                    -- Se existir erro adiciona na crítica
                    vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                    vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                    -- Limpar a tabela de erro, pois a exceção vai criar um novo registro
                    vr_tab_erro.DELETE;
                  ELSE
                    vr_cdcritic := 9999;
                    vr_dscritic := 'Erro em obter saldo dia.';
                  END IF;
                  -- Executa a exceção
                  RAISE vr_exc_erro;
                END IF;

                vr_vlsldisp := (vr_tab_sald(vr_tab_sald.FIRST).vlsddisp + vr_tab_sald(vr_tab_sald.FIRST).vllimcre);
              END IF;

              -- Verifica se a conta possui saldo disponivel para a operação
              IF rw_crapemp.vllancto > vr_vlsldisp AND rw_crapemp.idsitapr != 4 THEN

                -- Envio do e-mail da falta de saldo apenas uma única vez
                IF rw_crapemp.dthordeb  IS NULL THEN

                  -- Conteudo do e-mail informando para a empresa a falta de saldo.
                  vr_dsmensag := 'Olá,<br> Você agendou o debito de folha de pagamento para a data de hoje, porém sua conta '       ||
                                 'não possui saldo suficiente para a operação. Solicitamos que regularize a situação,  '        ||
                                 'do contrário o crédito em folha de seus empregados não ocorrerá na data programada. <br><br>' ||
                                 'Detalhes da operação: <br>' ||
                                 'Valor total do pagamento: R$ '||TO_CHAR(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')|| '<br>'||
                                 'Saldo em conta: R$ '||TO_CHAR(vr_tab_sald(vr_tab_sald.FIRST).vlsddisp, 'FM999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')|| '<br>'||
                                 'Limite de Credito: R$ '||TO_CHAR(vr_tab_sald(vr_tab_sald.FIRST).vllimcre, 'FM999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')|| '<br>'||
                                 'Saldo + Limite: R$ '||TO_CHAR(vr_vlsldisp, 'FM999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')|| '<br><br>'||
                                 'Você poderá solicitar o estouro de conta desde que cancele estes pagamentos e aprove-os novamente em sua Conta-On-Line. <br>' ||
                                 'Lembramos que toda solicitação de estouro dependerá de análise / aprovação de seu Posto de Atendimento. <br><br> ' ||
                                 'Atenciosamente,<br>Sistema AILOS.';

                   -- Enviar e-mail informando para a empresa a falta de saldo.
                   gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                             ,pr_cdprogra        => 'FOLH0001'
                                             ,pr_des_destino     => TRIM(rw_crapemp.dsdemail)
                                             ,pr_des_assunto     => 'Folha de Pagamento - Falta de saldo para debito'
                                             ,pr_des_corpo       => vr_dsmensag
                                             ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                             ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                             ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                             ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                             ,pr_des_erro        => vr_dscritic);

                   -- Conteudo do e-mail informando para o PA e a Central a falta de saldo.
                   vr_dsmensag := 'Olá, o cooperado '|| TO_CHAR(gene0002.fn_mask_conta(rw_crapemp.nrdconta)) ||' - '||TO_CHAR(rw_crapemp.nmprimtl) ||
                                  ' possui pagamento de folha com debito agendado para a data atual e não possui saldo em conta:<br> '  ||
                                  'Conta: '|| TO_CHAR(gene0002.fn_mask_conta(rw_crapemp.nrdconta)) ||' <br>' ||
                                  'Valor total do pagamento: R$ '||TO_CHAR(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')|| '<br>'||
                                  'Saldo em conta: R$ '||TO_CHAR(vr_tab_sald(vr_tab_sald.FIRST).vlsddisp, 'FM999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')|| '<br>'||
                                  'Limite de Credito: R$ '||TO_CHAR(vr_tab_sald(vr_tab_sald.FIRST).vllimcre, 'FM999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')|| '<br>'||
                                  'Saldo + Limite: R$ '||TO_CHAR(vr_vlsldisp, 'FM999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')|| '<br><br>'||
                                  'O cooperado foi avisado via e-mail para cobrir o saldo em conta, ou solicitar estouro da mesma, e o '||
                                  'sistema efetuara novas tentativas de debito durante o dia de hoje';

                   -- Buscando o email do PA
                   OPEN cr_crapage(pr_cdcooper => pr_cdcooper,
                                   pr_cdagenci => rw_crapemp.cdagenci);
                   FETCH cr_crapage INTO vr_email_dest;
                   CLOSE cr_crapage;

                   -- Utilizaremos o email da Central se o PA nao possuir
                   IF TRIM(vr_email_dest) IS NULL THEN
                     vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'FOLHAIB_EMAIL_ALERT_PROC');
                   END IF;

                   -- Enviar Email informando para o PA e a Central a falta de saldo
                   gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                             ,pr_cdprogra        => 'FOLH0001'
                                             ,pr_des_destino     => TRIM(vr_email_dest)
                                             ,pr_des_assunto     => 'Folha de Pagamento - Empresa sem saldo para pagamentos das folhas'
                                             ,pr_des_corpo       => vr_dsmensag
                                             ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                             ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                             ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                             ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                             ,pr_des_erro        => vr_dscritic);

                END IF;

                -- Envio centralizado de log de erro
                CECRED.pc_log_programa(pr_dstiplog => 'O'
                                     , pr_cdprograma => 'FOLH0001' 
                                     , pr_cdcooper => pr_cdcooper
                                     , pr_tpexecucao => 0
                                     , pr_tpocorrencia => 2 
                                     , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_debito_pagto_aprovados. Detalhes: DEBITO DE FOLHA – EMP '||TO_CHAR(rw_crapemp.cdempres) ||' – CONTA '|| TO_CHAR(gene0002.fn_mask_conta(rw_crapemp.nrdconta)) || ' NO VALOR DE R$ '|| TO_CHAR(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS=,.') ||' NÃO EFETUADO DEVIDO A FALTA DE SALDO EM CONTA'
                                     , pr_idprglog => vr_idprglog);                

                BEGIN
                   UPDATE crappfp
                   SET dthordeb = SYSDATE
                      ,dsobsdeb = 'Pagamento não efetuado por falta de saldo em conta.'
                 WHERE cdcooper = pr_cdcooper
                   AND cdempres = rw_crapemp.cdempres
                   AND dtdebito <= pr_rw_crapdat.dtmvtolt
                   AND idsitapr = 5  --> Aprovados
                   AND flsitdeb = 0; --> Ainda nao debitado

                EXCEPTION
                   WHEN OTHERS THEN
                      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                      vr_cdcritic := 9999;
                      vr_dscritic := 'Erro ao atualizar o registro na CRAPPFP: '||SQLERRM;
                      -- Executa a exceção
                      RAISE vr_exc_erro;
                END;
              ELSE --Caso tenha saldo busca o lote e faz o lançamento
                OPEN cr_craptab(pr_cdcooper => pr_cdcooper,
                                pr_cdempres => rw_crapemp.cdempres);
                FETCH cr_craptab INTO rw_craptab;

                OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                                pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                                pr_nrdolote => rw_craptab.nrdolote);
                FETCH cr_craplot INTO rw_craplot;

                --Se não achou o lote cria o mesmo
                IF cr_craplot%NOTFOUND THEN
                  BEGIN
                     LANC0001.pc_incluir_lote(pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                                              ,pr_cdagenci => 1
                                              ,pr_cdbccxlt => 100
                                              ,pr_nrdolote => rw_craptab.nrdolote
                                              ,pr_rw_craplot => vr_rcraplot
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);


                      rw_craplot.rowid    := vr_rcraplot.rowid;
                      rw_craplot.nrseqdig := vr_rcraplot.nrseqdig;
                      rw_craplot.qtcompln := vr_rcraplot.qtcompln;
                      rw_craplot.qtinfoln := vr_rcraplot.qtinfoln;
                      rw_craplot.vlcompdb := vr_rcraplot.vlcompdb;
                      rw_craplot.vlinfodb := vr_rcraplot.vlinfodb;

                      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                         RAISE vr_exc_erro;
                       END IF;

                  EXCEPTION
                    WHEN OTHERS THEN
                      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                      vr_cdcritic := 9999;
                      vr_dscritic := 'Erro ao inserir craplot: '||SQLERRM;
                      -- fecha cursor de lote e da tab
                      CLOSE cr_craplot;
                      CLOSE cr_craptab;
                      -- Executa a exceção
                      RAISE vr_exc_erro;
                  END;
                END IF;

                vr_nrseqdig := rw_craplot.nrseqdig;
                vr_qtcompln := rw_craplot.qtcompln;
                vr_qtinfoln := rw_craplot.qtinfoln;
                vr_vlcompdb := rw_craplot.vlcompdb;
                vr_vlinfodb := rw_craplot.vlinfodb;

                -- fecha cursor de lote e da tab
                CLOSE cr_craplot;
                CLOSE cr_craptab;

                FOR rw_crappfp IN cr_crappfp(pr_cdcooper => pr_cdcooper,
                                             pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                                             pr_cdempres => rw_crapemp.cdempres,
                                             pr_idsitapr => rw_crapemp.idsitapr) LOOP

                  -- Atualiza a capa do lote
                  vr_nrseqdig := vr_nrseqdig + 1;
                  vr_qtcompln := vr_qtcompln + 1;
                  vr_qtinfoln := vr_qtinfoln + 1;
                  vr_vlcompdb := vr_vlcompdb + rw_crappfp.vllancto;
                  vr_vlinfodb := vr_vlinfodb + rw_crappfp.vllancto;
                  vr_errhisto := rw_crappfp.cdhisdeb;

                  BEGIN
                    UPDATE craplot
                       -- se o numero for maior que o ja existente atualiza
                       SET nrseqdig = vr_nrseqdig,
                           qtcompln = vr_qtcompln,
                           qtinfoln = vr_qtinfoln,
                           vlcompdb = vr_vlcompdb,
                           vlinfodb = vr_vlinfodb
                     WHERE ROWID = rw_craplot.rowid;
                  EXCEPTION
                    WHEN OTHERS THEN
                      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                      vr_cdcritic := 9999;
                      vr_dscritic := 'Erro ao atualizar craplot: '||SQLERRM;
                      -- Executa a exceção
                      RAISE vr_exc_erro;
                  END;

                  -- Inserir lançamento
                  BEGIN

                   LANC0001.pc_gerar_lancamento_conta( pr_dtmvtolt =>pr_rw_crapdat.dtmvtolt
                                                      ,pr_cdagenci =>1
                                                      ,pr_cdbccxlt =>100
                                                      ,pr_nrdolote =>rw_craptab.nrdolote
                                                      ,pr_nrdconta =>rw_crapemp.nrdconta
                                                      ,pr_nrdctabb =>rw_crapemp.nrdconta
                                                      ,pr_nrdctitg =>gene0002.fn_mask(rw_crapemp.nrdconta,'99999999') -- nrdctitg
                                                      ,pr_nrdocmto =>vr_nrseqdig
                                                      ,pr_cdhistor =>rw_crappfp.cdhisdeb
                                                      ,pr_vllanmto =>rw_crappfp.vllancto
                                                      ,pr_nrseqdig =>vr_nrseqdig
                                                      ,pr_cdcooper =>pr_cdcooper
                                                       -- OUTPUT --
                                                      ,pr_tab_retorno => vr_tab_retorno
                                                      ,pr_incrineg => vr_incrineg
                                                      ,pr_cdcritic => vr_cdcritic
                                                      ,pr_dscritic => vr_dscritic);

                    IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                      RAISE vr_exc_erro;
                    END IF;

                  EXCEPTION
                    WHEN OTHERS THEN
                      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                      vr_errhisto := rw_crappfp.cdhisdeb;
                      vr_cdcritic := 9999;
                      vr_dscritic := 'Erro ao inserir craplcm: ' || rw_crapemp.nrdconta || SQLERRM;
                      -- Executa a exceção
                      RAISE vr_exc_erro;
                  END;
                END LOOP;
                --Atualiza a crappfp commita e grava no log.
                BEGIN
                  UPDATE crappfp
                     SET crappfp.dthordeb = sysdate,
                         crappfp.flsitdeb = 1,  --Debitado
                         crappfp.dsobsdeb = NULL
                   WHERE cdcooper = pr_cdcooper
                     AND cdempres = rw_crapemp.cdempres
                     AND dtdebito <= pr_rw_crapdat.dtmvtolt
                     AND idsitapr = rw_crapemp.idsitapr  --> Aprovados
                     AND flsitdeb = 0; --> Ainda nao debitado
                 EXCEPTION
                   WHEN OTHERS THEN
                     CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                     vr_cdcritic := 9999;
                     vr_dscritic := 'Erro ao atualizar o registro na CRAPPFP: '||SQLERRM;
                     -- Executa a exceção
                     RAISE vr_exc_erro;
                END;
                -- Grava no log
                CECRED.pc_log_programa(pr_dstiplog => 'O'
                                     , pr_cdprograma => 'FOLH0001' 
                                     , pr_cdcooper => pr_cdcooper
                                     , pr_tpexecucao => 0
                                     , pr_tpocorrencia => 2 
                                     , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Rotina pc_debito_pagto_aprovados. Detalhes: DEBITO DE FOLHA – EMP '||TO_CHAR(rw_crapemp.cdempres) ||' – CONTA '|| TO_CHAR(gene0002.fn_mask_conta(rw_crapemp.nrdconta)) || ' NO VALOR DE R$ '|| TO_CHAR(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS=,.') ||' EFETUADO COM SUCESSO!'
                                     , pr_idprglog => vr_idprglog);

              END IF;
            END IF;
            --Commita as informações
            COMMIT;

          EXCEPTION
            WHEN vr_exc_erro THEN
              -- Desfazer a operacao
              ROLLBACK;
              BEGIN
                UPDATE crappfp
                   SET crappfp.dthordeb = SYSDATE,
                       crappfp.dsobsdeb = 'Erro no debito em conta '|| vr_dscritic
                 WHERE cdcooper = pr_cdcooper
                   AND cdempres = rw_crapemp.cdempres
                   AND dtdebito <= pr_rw_crapdat.dtmvtolt
                   AND idsitapr = rw_crapemp.idsitapr  --> Aprovados
                   AND flsitdeb = 0; --> Ainda nao debitado

             EXCEPTION
               WHEN OTHERS THEN
                 CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                 ROLLBACK;
                 vr_cdcritic := 9999;
                 vr_dscritic := 'Erro ao atualizar o registro na CRAPPFP: '||SQLERRM;
             END;
             --Mensagem do email informando o erro
             vr_dsmensag := 'Houve erro inesperado no sistema e o debito no valor de '|| TO_CHAR(rw_crapemp.vllancto, 'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS=,.') ||', para o histórico ' || vr_errhisto ||
                            ', não ocorreu. Abaixo trazemos o erro retornado durante a operação: <br> '|| vr_dscritic ||
                            '<br>Lembramos que o sistema continuará tentando efetuar este debito durante todo o dia de hoje, ou até que o pagamento seja '||
                            'cancelado pela empresa';

             vr_email_dest :=  gene0001.fn_param_sistema('CRED',pr_cdcooper,'FOLHAIB_EMAIL_ALERT_PROC');

             -- Enviar Email informando para a Central
             gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                       ,pr_cdprogra        => 'FOLH0001'
                                       ,pr_des_destino     => TRIM(vr_email_dest)
                                       ,pr_des_assunto     => 'Folha de Pagamento - Problema com o débito – Empresa '|| TO_CHAR(rw_crapemp.nmprimtl)
                                       ,pr_des_corpo       => vr_dsmensag
                                       ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                       ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                       ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                       ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                       ,pr_des_erro        => vr_dscritic);

             --commita o envio de email
             COMMIT;

             -- Grava no log o erro
             CECRED.pc_log_programa(pr_dstiplog => 'O'
                                 , pr_cdprograma => 'FOLH0001' 
                                 , pr_cdcooper => pr_cdcooper
                                 , pr_tpexecucao => 0
                                 , pr_tpocorrencia => 2 
                                 , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_debito_pagto_aprovados. Detalhes: DEBITO DE FOLHA – EMP '||TO_CHAR(rw_crapemp.cdempres) ||' – CONTA '|| TO_CHAR(gene0002.fn_mask_conta(rw_crapemp.nrdconta)) || ' NO VALOR DE R$ '|| TO_CHAR(rw_crapemp.vllancto, 'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS=,.') || ' - ' || vr_dscritic 
                                 , pr_idprglog => vr_idprglog);
             
           WHEN OTHERS THEN
             -- Desfazer a operacao
             ROLLBACK;
             CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
             -- Grava no log o erro
             CECRED.pc_log_programa(pr_dstiplog => 'O'
                                 , pr_cdprograma => 'FOLH0001' 
                                 , pr_cdcooper => pr_cdcooper
                                 , pr_tpexecucao => 0
                                 , pr_tpocorrencia => 2 
                                 , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_debito_pagto_aprovados. Detalhes: DEBITO DE FOLHA – EMP '||TO_CHAR(rw_crapemp.cdempres) ||' – CONTA '|| TO_CHAR(gene0002.fn_mask_conta(rw_crapemp.nrdconta)) || ' NO VALOR DE R$ '|| TO_CHAR(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS=,. ') || ' - ' || SQLERRM 
                                 , pr_idprglog => vr_idprglog);             
         END;
       END LOOP;
     END pc_debito_pagto_aprovados;


  /* Procedure para realizar processamento de credito dos pagamentos aprovados */
  /*PROCEDURE pc_credito_pagto_aprovados(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                      ,pr_rw_crapdat IN BTCH0001.cr_crapdat%ROWTYPE) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_credito_pagto_aprovados             Antigo:
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Jaison
  --  Data     : Julho/2015.                   Ultima atualizacao: 23/05/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para realizar processamento de credito dos pagamentos aprovados
  -- Alterações
  --             12/11/2015 - Migracao da tarifação do sistema da CONFOL para CADTAR,
  --                          com isso removi a cobrança da tarifa deste ponto, deixando
  --                          apenas na pc_cobra_tarifas_pendentes (Marcos-Supero)
  --
  --             07/12/2015 - Ajustado para validar se o pagamento caso seja do tipo convencional,
  --                          verificar se a empresa resolveu gravar o salario ou nao.
  --                          (Andre Santos - SUPERO)
  --
  --             25/01/2016 - Ajuste nas mensagens de erro (Marcos-Supero)
  --
  --             27/01/2016 - Incluir controle de lançamentos sem crédito (Marcos-Supero)
  --             
  --             01/03/2016 - Ajustes para evitar dup_val_on_index em pagamentos ctasal
  --                          para a mesma conta no mesmo dia (Marcos-Supero)
  -- 
  -- 
  --             22/04/2016 - Inclusao de NVL para evitar que o LCM seja criado sem conta 
  --                          (Marcos - Supero)
  --
  --             23/05/2016 - Ajuste para gravar tab EXECDEBEMP com crapemp.dtlimdeb caso
  --                          dia da dtmvtopr for anterior ao dia limite para debitos. 
  --                          (Jaison/Marcos - Supero)
  --
  ---------------------------------------------------------------------------------------------------------------

    -- Busca os dados do lote
    CURSOR cr_craplot(pr_cdcooper craplot.cdcooper%TYPE,
                      pr_dtmvtolt craplot.dtmvtolt%TYPE,
                      pr_nrdolote craplot.nrdolote%TYPE) IS
        SELECT nrdolote
              ,nrseqdig
              ,qtinfoln
              ,qtcompln
              ,vlinfodb
              ,vlcompdb
              ,vlinfocr
              ,vlcompcr
              ,ROWID
          FROM craplot
         WHERE craplot.cdcooper = pr_cdcooper
           AND craplot.dtmvtolt = pr_dtmvtolt
           AND craplot.cdagenci = 1
           AND craplot.cdbccxlt = 100
           AND craplot.nrdolote = pr_nrdolote;
    rw_craplot     cr_craplot%ROWTYPE;
    rw_craplot_tec cr_craplot%ROWTYPE;
    rw_craplot_fol cr_craplot%ROWTYPE;
    rw_craplot_emp cr_craplot%ROWTYPE;
    rw_craplot_cot cr_craplot%ROWTYPE;

    -- Busca as empresas com pagamentos pendentes
    CURSOR cr_crapemp(pr_cdcooper crapemp.cdcooper%TYPE,
                      pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
        SELECT emp.cdempres
              ,emp.nmresemp
              ,emp.idtpempr
              ,emp.nrdconta
              ,emp.dtlimdeb
              ,ass.vllimcre
              ,SUM(lfp.vllancto) vllancto
          FROM crappfp pfp
              ,crapemp emp
              ,craplfp lfp
              ,crapass ass
         WHERE pfp.cdcooper  = pr_cdcooper
           AND pfp.dtcredit <= pr_dtmvtolt
           AND pfp.cdcooper  = emp.cdcooper
           AND pfp.cdempres  = emp.cdempres
           AND pfp.cdcooper  = lfp.cdcooper
           AND pfp.cdempres  = lfp.cdempres
           AND pfp.nrseqpag  = lfp.nrseqpag
           AND pfp.idsitapr  > 3 --> Aprovados
           AND pfp.flsitdeb  = 1 --> Ja debitados
           AND pfp.flsitcre  = 0 --> Ainda nao creditados
           AND ass.cdcooper  = emp.cdcooper
           AND ass.nrdconta  = emp.nrdconta
         GROUP BY emp.cdempres
                 ,emp.nmresemp
                 ,emp.idtpempr
                 ,emp.nrdconta
                 ,emp.dtlimdeb
                 ,ass.vllimcre;

    -- Busca o numero do Lote
    CURSOR cr_craptab_lot(pr_cdcooper craptab.cdcooper%TYPE,
                          pr_cdacesso craptab.cdacesso%TYPE,
                          pr_tpregist craptab.tpregist%TYPE) IS
         SELECT TO_NUMBER(dstextab)
           FROM craptab
          WHERE craptab.cdcooper        = pr_cdcooper
            AND UPPER(craptab.nmsistem) = 'CRED'
            AND UPPER(craptab.tptabela) = 'GENERI'
            AND craptab.cdempres        = 0
            AND UPPER(craptab.cdacesso) = pr_cdacesso
            AND craptab.tpregist        = pr_tpregist;

    -- Busca os pagamentos pendentes
    CURSOR cr_craplfp(pr_cdcooper crappfp.cdcooper%TYPE,
                      pr_dtmvtolt crapdat.dtmvtolt%TYPE,
                      pr_cdempres crappfp.cdempres%TYPE,
                      pr_idtpempr crapemp.idtpempr%TYPE) IS
        SELECT pfp.nrseqpag
              ,pfp.idtppagt
              ,pfp.flgrvsal
              ,pfp.qtlctpag
              ,pfp.ROWID pfp_rowid
              ,LAST_DAY(ADD_MONTHS(pfp.dtcredit, -1)) dtmacred -- Ultimo dia do mes anterior ao credito
              ,DECODE(pr_idtpempr,'C',ofp.cdhscrcp,ofp.cdhiscre) cdhiscre
              ,ofp.fldebfol
              ,lfp.nrseqlfp
              ,lfp.idtpcont
              ,lfp.nrdconta
              ,lfp.nrcpfemp
              ,lfp.vllancto
              ,lfp.ROWID
              ,lfp.progress_recid

              ,ROW_NUMBER() OVER (PARTITION BY lfp.cdempres ORDER BY lfp.cdempres) AS numempre
              ,COUNT(1) OVER (PARTITION BY lfp.cdempres) qtempres

              ,ROW_NUMBER() OVER (PARTITION BY lfp.cdempres,ofp.fldebfol,lfp.nrdconta ORDER BY lfp.cdempres,ofp.fldebfol,lfp.nrdconta,DECODE(pr_idtpempr,'C',ofp.cdhscrcp,ofp.cdhiscre)) AS numdebfol
              ,COUNT(1) OVER (PARTITION BY lfp.cdempres,ofp.fldebfol,lfp.nrdconta) qtdebfol

          FROM crappfp pfp
              ,craplfp lfp
              ,crapofp ofp
         WHERE pfp.cdcooper  = pr_cdcooper
           AND pfp.dtcredit <= pr_dtmvtolt
           AND pfp.cdempres  = pr_cdempres
           AND pfp.cdcooper  = lfp.cdcooper
           AND pfp.cdempres  = lfp.cdempres
           AND pfp.nrseqpag  = lfp.nrseqpag
           AND lfp.cdcooper  = ofp.cdcooper
           AND lfp.cdorigem  = ofp.cdorigem
           AND pfp.flsitdeb  = 1   --> Ja debitados
           AND pfp.flsitcre  = 0   --> Ainda nao creditados
           AND lfp.idsitlct NOT IN('E','C') --> Desconsiderar os com erros ou creditados
           AND nvl(lfp.dsobslct,' ') <> 'Transf. solicitada, aguardar transmissão' -- Desconsiderar tbm CTASAL solicitado, pois sua situação persiste em L e somente a Obs pode ser eusada
           AND lfp.vllancto  > 0
      ORDER BY lfp.cdempres
              ,ofp.fldebfol
              ,lfp.nrdconta
              ,DECODE(pr_idtpempr,'C',ofp.cdhscrcp,ofp.cdhiscre);

    -- Busca a conta do cooperado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT CASE
                 WHEN ass.cdsitdtl IN (2,4,6,8) THEN nvl(trf.nrsconta,ass.nrdconta)
                 ELSE ass.nrdconta
               END
          FROM crapass ass
              ,craptrf trf
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta
           AND trf.cdcooper(+) = ass.cdcooper
           AND trf.nrdconta(+) = ass.nrdconta
           AND trf.tptransa(+) = 1
           AND trf.insittrs(+) = 2;

    -- Busca os avisos de debitos de emprestimo/cotas com debito em folha
    CURSOR cr_crapavs(pr_cdcooper crapavs.cdcooper%TYPE,
                      pr_nrdconta crapavs.nrdconta%TYPE,
                      pr_dtrefere crapavs.dtrefere%TYPE) IS
        SELECT crapavs.*
              ,crapavs.rowid
          FROM crapavs
         WHERE crapavs.cdcooper = pr_cdcooper
           AND crapavs.nrdconta = pr_nrdconta
           AND crapavs.tpdaviso = 1
           AND crapavs.cdhistor IN (108,127)
           AND crapavs.dtrefere = pr_dtrefere
           AND crapavs.insitavs = 0
      ORDER BY crapavs.cdhistor;

    -- Busca os pagamentos da empresa creditados e com lancamentos pendentes de envio ao SPB
    CURSOR cr_lancspb(pr_cdcooper crappfp.cdcooper%TYPE,
                      pr_cdempres crappfp.cdempres%TYPE) IS
        SELECT 1
          FROM craplcs lcs
              ,craplfp lfp
              ,crappfp pfp
         WHERE pfp.cdcooper = pr_cdcooper
           AND pfp.cdempres = pr_cdempres
           AND pfp.cdcooper = lfp.cdcooper
           AND pfp.cdempres = lfp.cdempres
           AND pfp.nrseqpag = lfp.nrseqpag
           AND lcs.cdcooper = lfp.cdcooper
           AND lcs.nrdconta = lfp.nrdconta
           AND lcs.nrridlfp = lfp.progress_recid
           AND lfp.idsitlct = 'L' --> Ainda nao transmitido
           AND lcs.flgenvio = 0;  --> Nao enviado
    rw_lancspb cr_lancspb%ROWTYPE;

    -- Lancamentos dos funcionarios que transferem o salario para outra IF
    CURSOR cr_avs_fol(pr_cdcooper crapavs.cdcooper%TYPE,
                      pr_cdempres crapavs.cdempres%TYPE,
                      pr_dtrefere crapavs.dtrefere%TYPE) IS
        SELECT crapavs.nrdconta
          FROM crapavs
         WHERE crapavs.cdcooper = pr_cdcooper
           AND crapavs.cdempres = pr_cdempres
           AND crapavs.dtrefere = pr_dtrefere
           AND crapavs.tpdaviso = 1 --> Folha
           AND crapavs.insitavs = 0 --> Nao debitado
           AND crapavs.cdhistor IN (108,127)

           -- Ja garantimos que nao exista CRAPFOL para evitar DUP_VAL_ON_INDEX
           AND NOT EXISTS(SELECT 1
                            FROM crapfol
                           WHERE crapfol.cdcooper = crapavs.cdcooper
                             AND crapfol.cdempres = crapavs.cdempres
                             AND crapfol.dtrefere = crapavs.dtrefere
                             AND crapfol.nrdconta = crapavs.nrdconta)

      GROUP BY crapavs.nrdconta;

    -- Tabelas
    TYPE typ_tab_crappfp IS
      TABLE OF crappfp.qtlctpag%TYPE
      INDEX BY VARCHAR2(25);

    TYPE typ_reg_craplfp IS
      RECORD (vllancto craplfp.vllancto%TYPE);

    TYPE typ_tab_craplfp IS
      TABLE OF typ_reg_craplfp
      INDEX BY PLS_INTEGER;

    -- Variaveis da PLTABLE
    vr_tab_crappfp typ_tab_crappfp;
    vr_tab_craplfp typ_tab_craplfp;

    -- Variaveis
    vr_cdhistor   craplcm.cdhistor%TYPE;
    vr_nrdocmto   craplcs.nrdocmto%TYPE;
    vr_cdhistec   crapprm.dsvlrprm%TYPE;
    vr_lote_tec   crapprm.dsvlrprm%TYPE;
    vr_lote_nro   craplot.nrdolote%TYPE;
    vr_dstextab   craptab.dstextab%TYPE;
    vr_nmprimtl   crapass.nmprimtl%TYPE;
    vr_nrdconta   crapass.nrdconta%TYPE;
    vr_flsittar   crappfp.flsittar%TYPE;
    vr_dsobstar   crappfp.dsobstar%TYPE;
    vr_idsitlct   craplfp.idsitlct%TYPE;
    vr_dsobslct   craplfp.dsobslct%TYPE;
    vr_vlsalliq   craplfp.vllancto%TYPE;
    vr_vldebtot   craplfp.vllancto%TYPE;
    vr_tot_debcot craplfp.vllancto%TYPE;
    vr_tot_debemp craplfp.vllancto%TYPE;
    vr_tot_lanc   craplfp.vllancto%TYPE;
    vr_tottarif   craplfp.vllancto%TYPE;
    vr_vlsddisp   crapsda.vlsddisp%TYPE;
    vr_vldoipmf   NUMBER;
    vr_inusatab   BOOLEAN;
    vr_blnfound   BOOLEAN;
    vr_blnerror   BOOLEAN;
    vr_blctasal   BOOLEAN := FALSE;
    vr_lotechav   VARCHAR2(10);
    vr_emailds1   VARCHAR2(1000);
    vr_emailds2   VARCHAR2(1000);
    vr_dsmensag   VARCHAR2(4000);
    vr_chave      VARCHAR2(25);
    vr_dtexecde   DATE;

    -- Variaveis de Erro
    vr_cdcritic   crapcri.cdcritic%TYPE;
    vr_dscritic   VARCHAR2(4000);
    vr_dsalerta   VARCHAR2(4000);

    -- Variaveis Excecao
    vr_exc_erro   EXCEPTION;

  BEGIN

    -- Destinatarios responsaveis pelos avisos
    vr_emailds1 :=  GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_cdacesso => 'FOLHAIB_EMAIL_ALERT_PROC');

    -- Leitura do indicador de uso da tabela de taxa de juros
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'TAXATABELA'
                                             ,pr_tpregist => 0);
    IF vr_dstextab IS NULL THEN
      vr_inusatab := FALSE;
    ELSE
      IF SUBSTR(vr_dstextab,1,1) = '0' THEN
          vr_inusatab := FALSE;
      ELSE
        vr_inusatab := TRUE;
      END IF;
    END IF;

    -- Busca o numero de lote para gravacao
    vr_lote_tec := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_cdacesso => 'FOLHAIB_NRLOTE_CTASAL');

    -- Efetua a busca do lote TEC
    OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                    pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                    pr_nrdolote => vr_lote_tec);
    FETCH cr_craplot INTO rw_craplot_tec;
    -- Alimenta a booleana se achou ou nao
    vr_blnfound := cr_craplot%FOUND;
    -- Fecha cursor
    CLOSE cr_craplot;

    -- Se nao achou faz a criacao do lote TEC
    IF NOT vr_blnfound THEN
      BEGIN
        INSERT INTO craplot
                   (cdcooper
                   ,dtmvtolt
                   ,cdagenci
                   ,cdbccxlt
                   ,nrdolote
                   ,tplotmov)
             VALUES(pr_cdcooper
                   ,pr_rw_crapdat.dtmvtolt
                   ,1           -- cdagenci
                   ,100         -- cdbccxlt
                   ,vr_lote_tec
                   ,1)
          RETURNING craplot.rowid INTO rw_craplot_tec.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := '060 - Lote inexistente.';

          -- Envia o erro para o LOG
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 3 -- Erro nao tratado
                                    ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': ' || vr_dscritic
                                    ,pr_nmarqlog     => 'FOLHIB');

          -- Mensagem informando o erro
          vr_dsmensag := 'Houve erro inesperado na inclusão do lote CTASAL. ' ||
                         'Abaixo trazemos o erro retornado durante a operação: <br> ' ||
                         vr_dscritic;

          -- Solicita envio do email
          GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => 'FOLH0001'
                                    ,pr_des_destino     => TRIM(vr_emailds1)
                                    ,pr_des_assunto     => 'Folha de Pagamento - Problema com o crédito – CTASAL'
                                    ,pr_des_corpo       => vr_dsmensag
                                    ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                    ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                    ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                    ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                    ,pr_des_erro        => vr_dscritic);
          RAISE vr_exc_erro;
      END;

      COMMIT; -- Salva o lote TEC
    END IF;

    -- Busca o historico de credito parametrizado para TECs salario
    vr_cdhistec := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_cdacesso => 'FOLHAIB_HIS_CRE_TECSAL');

    -- Percorre todas as empresas da cooperativa atual
    FOR rw_crapemp IN cr_crapemp(pr_cdcooper => pr_cdcooper,
                                 pr_dtmvtolt => pr_rw_crapdat.dtmvtolt) LOOP

      BEGIN
        -- Adicionamos no LOG o inicio do pagamento
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- Processo Normal
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': CREDITO DE FOLHA – EMP ' ||
                                                      rw_crapemp.cdempres || ' – INICIANDO CREDITO DOS EMPREGADOS – VALOR TOTAL PREVISTO DE R$ ' ||
                                                      TO_CHAR(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.')
                                  ,pr_nmarqlog     => 'FOLHIB');

        -- Inicializa as variaveis
        vr_blnerror    := FALSE;
        rw_craplot_fol := NULL;
        rw_craplot_emp := NULL;
        rw_craplot_cot := NULL;

        -- Lotes de Folha/Emprestimo/Cotas
        FOR vr_index IN 1..3 LOOP

          -- Chave de acesso
          CASE vr_index
            WHEN 1 THEN vr_lotechav := 'NUMLOTEFOL';
            WHEN 2 THEN vr_lotechav := 'NUMLOTEEMP';
            WHEN 3 THEN vr_lotechav := 'NUMLOTECOT';
          END CASE;

          -- Efetua a busca do codigo do lote FOL/EMP/COT
          OPEN cr_craptab_lot(pr_cdcooper => pr_cdcooper,
                              pr_cdacesso => vr_lotechav,
                              pr_tpregist => rw_crapemp.cdempres);
          FETCH cr_craptab_lot INTO vr_lote_nro;
          -- Alimenta a booleana se achou ou nao
          vr_blnfound := cr_craptab_lot%FOUND;
          -- Fecha cursor
          CLOSE cr_craptab_lot;

          -- Se nao achou
          IF NOT vr_blnfound THEN
            vr_blnerror := TRUE;
            EXIT; -- Sai do loop 1..3
          END IF;

          -- Busca o lote FOL/EMP/COT
          OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                          pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                          pr_nrdolote => vr_lote_nro);
          FETCH cr_craplot INTO rw_craplot;
          -- Alimenta a booleana se achou ou nao
          vr_blnfound := cr_craplot%FOUND;
          -- Fecha cursor
          CLOSE cr_craplot;

          -- Se nao achou faz a criacao do lote FOL/EMP/COT
          IF NOT vr_blnfound THEN
            BEGIN
              INSERT INTO craplot
                         (cdcooper
                         ,dtmvtolt
                         ,cdagenci
                         ,cdbccxlt
                         ,nrdolote
                         ,tplotmov)
                   VALUES(pr_cdcooper
                         ,pr_rw_crapdat.dtmvtolt
                         ,1           -- cdagenci
                         ,100         -- cdbccxlt
                         ,vr_lote_nro
                         ,1)
                RETURNING craplot.rowid INTO rw_craplot.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_blnerror := TRUE;
                EXIT; -- Sai do loop 1..3
            END;

          END IF;

          -- Carrega os lotes e cursores
          CASE vr_index
            WHEN 1 THEN
              rw_craplot_fol := rw_craplot;
              rw_craplot_fol.nrdolote := vr_lote_nro;
            WHEN 2 THEN
              rw_craplot_emp := rw_craplot;
              rw_craplot_emp.nrdolote := vr_lote_nro;
            WHEN 3 THEN
              rw_craplot_cot := rw_craplot;
              rw_craplot_cot.nrdolote := vr_lote_nro;
          END CASE;

        END LOOP; -- Fim do loop 1..3 dos lotes

        -- Caso tenha ocorrido erro na inclusao do lote vai para a proxima empresa e desfaz as acoes
        IF vr_blnerror THEN

          -- Mensagem de Critica
          vr_dscritic := '060 - Lote inexistente.';

          -- Envia o erro para o LOG
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': ' || vr_dscritic
                                    ,pr_nmarqlog     => 'FOLHIB');

          -- Mensagem informando o erro
          vr_dsmensag := 'Houve erro inesperado na busca do numero do lote ('|| vr_lotechav ||') ' ||
                         'para a empresa ' || rw_crapemp.cdempres || ' - ' || rw_crapemp.nmresemp || '. ' ||
                         'Abaixo trazemos o erro retornado durante a operação: <br> ' || vr_dscritic;

          -- Solicita envio do email
          GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => 'FOLH0001'
                                    ,pr_des_destino     => TRIM(vr_emailds1)
                                    ,pr_des_assunto     => 'Folha de Pagamento - Problema com o crédito – Empresa ' || rw_crapemp.cdempres || ' - ' || rw_crapemp.nmresemp
                                    ,pr_des_corpo       => vr_dsmensag
                                    ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                    ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                    ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                    ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                    ,pr_des_erro        => vr_dscritic);
          ROLLBACK;
          CONTINUE; -- Move para a proxima empresa
        END IF;

        COMMIT; -- Salva os lotes FOL/EMP/COT

        -- Limpa as PLTABLES
        vr_tab_crappfp.DELETE;
        vr_tab_craplfp.DELETE;

        -- Listagem dos pagamentos pendentes
        FOR rw_craplfp IN cr_craplfp(pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                                     pr_cdempres => rw_crapemp.cdempres,
                                     pr_idtpempr => rw_crapemp.idtpempr) LOOP
          -- Verificar a situacao de cada conta, pois algum empregado pode ter encerrado sua conta
          -- ou efetuado alguma alteracao em seu cadastro que impeca o credito
          pc_valida_lancto_folha(pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => rw_craplfp.nrdconta,
                                 pr_nrcpfcgc => rw_craplfp.nrcpfemp,
                                 pr_idtpcont => rw_craplfp.idtpcont,
                                 pr_nmprimtl => vr_nmprimtl,
                                 pr_dsalerta => vr_dsalerta,
                                 pr_dscritic => vr_dscritic);
          -- Caso tenha retornado alguma critica
          IF vr_dsalerta IS NOT NULL OR
             vr_dscritic IS NOT NULL THEN
            BEGIN
              -- Atualiza com erro
              UPDATE craplfp
                 SET idsitlct = 'E'
                    ,dsobslct = NVL(vr_dsalerta,vr_dscritic)
               WHERE ROWID = rw_craplfp.rowid;
            END;

            -- Adicionamos no LOG o aviso de problema
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': CREDITO DE FOLHA – EMP ' ||
                                                          rw_crapemp.cdempres || ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(rw_craplfp.nrdconta)) || ' NO VALOR DE R$ ' ||
                                                          TO_CHAR(rw_craplfp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') ||
                                                          ' NÃO SERA EFETUADO, MOTIVO: '||NVL(vr_dsalerta,vr_dscritic)
                                      ,pr_nmarqlog     => 'FOLHIB');
            CONTINUE;
          END IF;

          -- Caso seja Associado Cecred
          IF rw_craplfp.idtpcont = 'C' THEN

            -- Busca a conta do associado
            OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => rw_craplfp.nrdconta);
            FETCH cr_crapass INTO vr_nrdconta;
            -- Fecha cursor
            CLOSE cr_crapass;

            -- Inicializa as variaveis
            vr_idsitlct := 'C';
            vr_dsobslct := NULL;
            vr_blnerror := FALSE;

            BEGIN
              -- Atualiza a CRAPLOT_FOL
              UPDATE craplot
                 SET qtinfoln = qtinfoln + 1
                    ,vlinfocr = vlinfocr + rw_craplfp.vllancto
                    ,qtcompln = qtcompln + 1
                    ,vlcompcr = vlcompcr + rw_craplfp.vllancto
                    ,nrseqdig = nrseqdig + 1
               WHERE ROWID = rw_craplot_fol.rowid
               RETURNING craplot.nrseqdig INTO rw_craplot_fol.nrseqdig;

              -- Inserir lancamento
              INSERT INTO craplcm
                         (dtmvtolt
                         ,cdagenci
                         ,cdbccxlt
                         ,nrdolote
                         ,nrdconta
                         ,nrdctabb
                         ,nrdctitg
                         ,nrdocmto
                         ,cdhistor
                         ,vllanmto
                         ,nrseqdig
                         ,cdcooper)
                   VALUES(pr_rw_crapdat.dtmvtolt
                         ,1
                         ,100
                         ,rw_craplot_fol.nrdolote
                         ,vr_nrdconta
                         ,vr_nrdconta
                         ,GENE0002.fn_mask(vr_nrdconta,'99999999') -- nrdctitg
                         ,rw_craplfp.nrseqpag||to_char(rw_craplfp.nrseqlfp,'fm00000')
                         ,rw_craplfp.cdhiscre
                         ,rw_craplfp.vllancto
                         ,rw_craplot_fol.nrseqdig
                         ,pr_cdcooper);
                         
              pc_inserir_lanaut(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => vr_nrdconta
                               ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                               ,pr_cdhistor => rw_craplfp.cdhiscre
                               ,pr_vlrenda  => rw_craplfp.vllancto
                               ,pr_cdagenci => 1
                               ,pr_cdbccxlt => 100
                               ,pr_nrdolote => rw_craplot_fol.nrdolote
                               ,pr_nrseqdig => rw_craplot_fol.nrseqdig
                               ,pr_dscritic => vr_dscritic);
                               
              IF  vr_dscritic IS NOT NULL THEN
                  vr_idsitlct := 'E';
                  vr_dsobslct := 'Problema encontrado no crédito ao empregado: '||SQLERRM;
                  vr_blnerror := TRUE;
                  ROLLBACK;

                  -- Envia o erro para o LOG
                  BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': ' ||
                                                                'CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres ||
                                                                ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(vr_nrdconta)) || ' –  CREDITO ' ||
                                                                rw_craplfp.cdhiscre || ' NO VALOR DE R$ ' ||
                                                                TO_CHAR(rw_craplfp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') ||
                                                                ' NÃO EFETUADO: ' || SQLERRM
                                            ,pr_nmarqlog     => 'FOLHIB');                 
              END IF;              
                         
            EXCEPTION
              WHEN OTHERS THEN
                vr_idsitlct := 'E';
                vr_dsobslct := 'Problema encontrado no crédito ao empregado: '||SQLERRM;
                vr_blnerror := TRUE;
                ROLLBACK;

                -- Envia o erro para o LOG
                BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': ' ||
                                                              'CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres ||
                                                              ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(vr_nrdconta)) || ' –  CREDITO ' ||
                                                              rw_craplfp.cdhiscre || ' NO VALOR DE R$ ' ||
                                                              TO_CHAR(rw_craplfp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') ||
                                                              ' NÃO EFETUADO: ' || SQLERRM
                                          ,pr_nmarqlog     => 'FOLHIB');
            END;

            BEGIN
              -- Atualiza com sucesso ou erro
              UPDATE craplfp
                 SET idsitlct = vr_idsitlct
                    ,dsobslct = vr_dsobslct
               WHERE ROWID = rw_craplfp.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_blnerror := TRUE;
            END;

            -- Salva o lancamento de credito na conta e atualiza a situacao
            COMMIT;

            -- Caso seja o primeiro registro reseta o total de credito
            IF rw_craplfp.numdebfol = 1 THEN
              vr_vlsalliq := 0;
            END IF;

            -- Se NAO ocorreu erro na inclusao da LCM ou atualizacao da LOT/LFP
            IF NOT vr_blnerror THEN
              -- Adicionamos no LOG o sucesso ocorrido no pagamento
              BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 1 -- Processo Normal
                                        ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': CREDITO DE FOLHA – EMP ' ||
                                                            rw_crapemp.cdempres || ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(vr_nrdconta)) || ' – CREDITO ' ||
                                                            rw_craplfp.cdhiscre || ' NO VALOR DE R$ ' ||
                                                            TO_CHAR(rw_craplfp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.')
                                        ,pr_nmarqlog     => 'FOLHIB');
            END IF;

            -- Caso tenha desconto em folha
            IF rw_craplfp.fldebfol = 1 THEN

              -- Se NAO ocorreu erro na inclusao da LCM ou atualizacao da LOT/LFP
              IF NOT vr_blnerror THEN
                -- Soma o lancamento
                vr_vlsalliq := vr_vlsalliq + rw_craplfp.vllancto;
              END IF;

              -- Caso seja o ultimo registro e tenha salario liquido
              IF rw_craplfp.numdebfol = rw_craplfp.qtdebfol AND vr_vlsalliq > 0 THEN
                vr_blnerror := FALSE;

                BEGIN
                  -- Atualiza o endividamento
                  UPDATE crapass
                     SET dtedvmto = rw_craplfp.dtmacred
                        ,vledvmto = APLI0001.fn_round((vr_vlsalliq * 1.15) * 0.30,2)
                   WHERE cdcooper = pr_cdcooper
                     AND nrdconta = rw_craplfp.nrdconta;

                  -- Insere ou atualiza o controle dos cheques salarios
                  INSERT INTO crapfol
                             (cdcooper
                             ,cdempres
                             ,nrdconta
                             ,dtrefere
                             ,vllanmto)
                       VALUES(pr_cdcooper
                             ,rw_crapemp.cdempres
                             ,vr_nrdconta
                             ,pr_rw_crapdat.dtultdia
                             ,vr_vlsalliq);
                EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                    -- Se ja existir atualizar valor
                    UPDATE crapfol
                       SET crapfol.vllanmto = vr_vlsalliq
                     WHERE crapfol.cdcooper = pr_cdcooper
                       AND crapfol.cdempres = rw_crapemp.cdempres
                       AND crapfol.nrdconta = vr_nrdconta
                       AND crapfol.dtrefere = pr_rw_crapdat.dtultdia;

                  WHEN OTHERS THEN
                    vr_blnerror := TRUE;
                    vr_dscritic := SQLERRM;
                END;

                -- Se ocorreu erro na inclusao/atualizacao da FOL ou atualizacao da ASS
                IF vr_blnerror THEN
                  -- Envia o erro para o LOG porem continua o processo
                  BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': ' ||
                                                                'CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres ||
                                                                ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(vr_nrdconta)) || ' – NO VALOR DE R$ ' ||
                                                                TO_CHAR(vr_vlsalliq,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') ||
                                                                ': Problema encontrado -> '||vr_dscritic
                                            ,pr_nmarqlog     => 'FOLHIB');
                END IF;

                -- Inicializa as variaveis
                vr_tot_debemp := 0;
                vr_tot_debcot := 0;

                -- Listagem dos pagamentos pendentes
                FOR rw_crapavs IN cr_crapavs(pr_cdcooper => pr_cdcooper,
                                             pr_nrdconta => rw_craplfp.nrdconta,
                                             pr_dtrefere => rw_craplfp.dtmacred) LOOP

                  -- Somente se possuir salario liquido
                  IF vr_vlsalliq > 0 THEN
                    vr_blnerror := FALSE;

                    -- Aviso de Emprestimo
                    IF rw_crapavs.cdhistor = 108 THEN

                      -- Chama a rotina PC_CRPS120_1
                      pc_crps120_1(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => 'FOLH0001'
                                  ,pr_cdoperad => '1'
                                  ,pr_crapdat  => pr_rw_crapdat
                                  ,pr_nrdconta => rw_craplfp.nrdconta
                                  ,pr_nrctremp => rw_crapavs.nrdocmto --> Nr do emprestimo
                                  ,pr_nrdolote => rw_craplot_emp.nrdolote
                                  ,pr_inusatab => vr_inusatab         --> Indicador se utilizar a tabela de juros
                                  ,pr_vldaviso => rw_crapavs.vllanmto - rw_crapavs.vldebito --> Valor de aviso
                                  ,pr_vlsalliq => vr_vlsalliq         --> Valor de saldo liquido
                                  ,pr_dtintegr => pr_rw_crapdat.dtmvtolt --> Data de integracao
                                  ,pr_cdhistor => 95                  --> Cod do historico
                                  -- OUT
                                  ,pr_insitavs => rw_crapavs.insitavs --> Retorna situacao do aviso
                                  ,pr_vldebito => vr_vldebtot         --> Retorna do valor de debito
                                  ,pr_vlestdif => rw_crapavs.vlestdif --> Ret vlr estouro ou diferenca
                                  ,pr_flgproce => rw_crapavs.flgproce --> Ret indicativo de processamento
                                  ,pr_cdcritic => vr_cdcritic         --> Critica encontrada
                                  ,pr_dscritic => vr_dscritic);       --> Texto de erro/critica encontrada

                      -- Se retornar critica
                      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                        vr_blnerror := TRUE;
                      ELSE
                        -- Acumular o valor lancado para unificar a criacao da CRAPLCM
                        vr_tot_debemp := NVL(vr_tot_debemp,0) + NVL(vr_vldebtot,0);
                        -- Decrementar do valor liquido a prestacao paga
                        vr_vlsalliq := NVL(vr_vlsalliq,0) - NVL(vr_vldebtot,0);
                      END IF;

                      BEGIN
                        -- Atualiza Aviso
                        UPDATE crapavs
                           SET crapavs.insitavs = rw_crapavs.insitavs,
                               crapavs.vlestdif = rw_crapavs.vlestdif,
                               crapavs.flgproce = rw_crapavs.flgproce,
                               crapavs.vldebito = rw_crapavs.vldebito + NVL(vr_vldebtot,0)
                         WHERE ROWID = rw_crapavs.rowid;
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_blnerror := TRUE;
                          vr_dscritic := SQLERRM;
                      END;

                      -- Se ocorreu erro na PC_CRPS120_1 ou atualizacao da AVS
                      IF vr_blnerror THEN
                        -- Envia o erro para o LOG porem continua o processo
                        BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                                  ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': ' ||
                                                                      'CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres ||
                                                                      ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(vr_nrdconta)) || ' – AVISO NO VALOR DE R$ ' ||
                                                                      TO_CHAR(vr_vldebtot,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') ||
                                                                      ': Erro -> ' || vr_cdcritic || ' - ' || vr_dscritic
                                                  ,pr_nmarqlog     => 'FOLHIB');
                      END IF;

                    -- Aviso de Plano de Cotas
                    ELSIF rw_crapavs.cdhistor = 127 THEN

                      -- Chama a rotina PC_CRPS120_2
                      pc_crps120_2(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => 'FOLH0001'
                                  ,pr_crapdat  => pr_rw_crapdat
                                  ,pr_nrdconta => rw_craplfp.nrdconta
                                  ,pr_nrdolote => rw_craplot_cot.nrdolote
                                  ,pr_vldaviso => rw_crapavs.vllanmto --> Valor do aviso
                                  ,pr_vlsalliq => vr_vlsalliq         --> Valor do saldo liquido
                                  ,pr_dtintegr => pr_rw_crapdat.dtmvtolt --> Data de integracao
                                  ,pr_cdhistor => 75                  --> Cod do historico
                                  -- OUT
                                  ,pr_insitavs => rw_crapavs.insitavs --> Retorna indicador do aviso
                                  ,pr_vldebito => rw_crapavs.vldebito --> Retorno do valor debito
                                  ,pr_vlestdif => rw_crapavs.vlestdif --> retorna valor de estorno/diferença
                                  ,pr_vldoipmf => vr_vldoipmf         --> Valor do CPMF (Não mais utilizado)
                                  ,pr_flgproce => rw_crapavs.flgproce --> retorno indicativo de processamento
                                  ,pr_cdcritic => vr_cdcritic         --> Critica encontrada
                                  ,pr_dscritic => vr_dscritic);       --> Texto de erro/critica encontrada

                      -- Se retornar critica
                      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                        vr_blnerror := TRUE;
                      ELSE
                        -- Acumular o valor lancado para unificar a criacao da CRAPLCM
                        vr_tot_debcot := NVL(vr_tot_debcot,0) + NVL(rw_crapavs.vldebito,0);
                        -- Decrementar do valor liquido a prestacao paga
                        vr_vlsalliq := NVL(vr_vlsalliq,0) - NVL(rw_crapavs.vldebito,0);
                      END IF;

                      BEGIN
                        -- Atualiza Aviso
                        UPDATE crapavs
                           SET crapavs.insitavs = rw_crapavs.insitavs,
                               crapavs.vlestdif = rw_crapavs.vlestdif,
                               crapavs.flgproce = rw_crapavs.flgproce,
                               crapavs.vldebito = NVL(rw_crapavs.vldebito,0)
                         WHERE ROWID = rw_crapavs.rowid;
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_blnerror := TRUE;
                          vr_dscritic := SQLERRM;
                      END;

                      -- Se ocorreu erro na PC_CRPS120_2 ou atualizacao da AVS
                      IF vr_blnerror THEN
                        -- Envia o erro para o LOG porem continua o processo
                        BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                                  ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': ' ||
                                                                      'CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres ||
                                                                      ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(vr_nrdconta)) || ' – AVISO NO VALOR DE R$ ' ||
                                                                      TO_CHAR(rw_crapavs.vldebito,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') ||
                                                                      ': Erro - ' || vr_dscritic
                                                  ,pr_nmarqlog     => 'FOLHIB');
                      END IF;

                    END IF; -- Avisos EMP/COT

                    -- Se nao houve debito
                    IF rw_crapavs.vldebito = 0 AND rw_crapavs.insitavs = 0 THEN
                      -- Atualizar valor de estouro/diferenca aviso de debito
                      BEGIN
                       UPDATE crapavs
                          SET crapavs.vlestdif = crapavs.vllanmto * -1
                        WHERE ROWID = rw_crapavs.rowid;
                      END;
                    END IF;

                  ELSE
                    EXIT; -- Sai do loop cr_crapavs
                  END IF; -- vr_vlsalliq > 0

                END LOOP; -- cr_crapavs

                -- Se houve lancamento de AVS
                IF vr_tot_debcot > 0 OR vr_tot_debemp > 0 THEN

                  FOR vr_index IN 1..2 LOOP

                    -- Seta as variaveis
                    CASE vr_index
                      WHEN 1 THEN -- Cotas
                        vr_cdhistor := 127;
                        vr_tot_lanc := vr_tot_debcot;
                        rw_craplot  := rw_craplot_cot;
                      WHEN 2 THEN -- Emprestimos
                        vr_cdhistor := 108;
                        vr_tot_lanc := vr_tot_debemp;
                        rw_craplot  := rw_craplot_emp;
                    END CASE;

                    -- Executa somente se existir valor
                    IF vr_tot_lanc > 0 THEN

                      BEGIN
                        -- Atualiza a CRAPLOT
                        UPDATE craplot
                           SET qtinfoln = qtinfoln + 1
                              ,vlinfodb = vlinfodb + vr_tot_lanc
                              ,qtcompln = qtcompln + 1
                              ,vlcompdb = vlcompdb + vr_tot_lanc
                              ,nrseqdig = nrseqdig + 1
                         WHERE ROWID = rw_craplot.rowid
                         RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;

                        -- Inserir lancamento
                        INSERT INTO craplcm
                                   (dtmvtolt
                                   ,cdagenci
                                   ,cdbccxlt
                                   ,nrdolote
                                   ,nrdconta
                                   ,nrdctabb
                                   ,nrdctitg
                                   ,nrdocmto
                                   ,cdhistor
                                   ,vllanmto
                                   ,nrseqdig
                                   ,cdcooper)
                             VALUES(pr_rw_crapdat.dtmvtolt
                                   ,1
                                   ,100
                                   ,rw_craplot.nrdolote
                                   ,vr_nrdconta
                                   ,vr_nrdconta
                                   ,GENE0002.fn_mask(vr_nrdconta,'99999999') -- nrdctitg
                                   ,rw_craplot.nrseqdig
                                   ,vr_cdhistor
                                   ,vr_tot_lanc
                                   ,rw_craplot.nrseqdig
                                   ,pr_cdcooper);
                      EXCEPTION
                        WHEN OTHERS THEN
                          -- Envia o erro para o LOG
                          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                                    ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': ' ||
                                                                        'CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres ||
                                                                        ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(vr_nrdconta)) || ' –  DEBITO ' ||
                                                                        vr_cdhistor || ' NO VALOR DE R$ ' ||
                                                                        TO_CHAR(vr_tot_lanc,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') ||
                                                                        ' NÃO EFETUADO: ' || SQLERRM
                                                    ,pr_nmarqlog     => 'FOLHIB');
                      END;

                    END IF; -- tot_lanc > 0

                  END LOOP; -- Fim do loop 1..2

                END IF; -- tot_debcot OR tot_debemp > 0

              END IF; -- numdebfol = qtdebfol

              COMMIT; -- Salva a FOL, ASS, AVS e o Debito

            END IF; -- fldebfol = 1

          -- Funcionarios CTASAL (idtpcont = 'T')
          ELSE

            -- Busca próximo número de documento não utilizado
            vr_nrdocmto := rw_craplfp.nrseqpag||to_char(rw_craplfp.nrseqlfp,'fm00000');
            vr_exis_lcs := 0;
            LOOP 
              -- Verifica se existe craplcs com memso numero de documento
              OPEN cr_craplcs_nrdoc (pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                                    ,pr_nrdconta => rw_craplfp.nrdconta
                                    ,pr_cdhisdev => vr_cdhistec
                                    ,pr_nrdocmto => vr_nrdocmto);
              FETCH cr_craplcs_nrdoc 
               INTO vr_exis_lcs;
              -- Sair quando não tiver encontrado
              EXIT WHEN cr_craplcs_nrdoc%NOTFOUND;
              -- Fechamos o CURSOR pois ele será reaberto no próximo LOOP
              CLOSE cr_craplcs_nrdoc;
              -- Se persite no loop é pq existe, então adicionamos o numero documento
              vr_nrdocmto := vr_nrdocmto + 1000000000;
            END LOOP;  
            -- Fechar cursor
            IF cr_craplcs_nrdoc%ISOPEN THEN
              CLOSE cr_craplcs_nrdoc;
            END IF;
            
            -- Inicializa a variavel
            vr_blnerror := FALSE;

            BEGIN
              -- Inserir lancamento
              INSERT INTO craplcs
                         (cdcooper
                         ,cdopecrd
                         ,dtmvtolt
                         ,nrdconta
                         ,nrdocmto
                         ,vllanmto
                         ,cdhistor
                         ,nrdolote
                         ,cdbccxlt
                         ,cdagenci
                         ,flgenvio
                         ,dttransf
                         ,hrtransf
                         ,nrridlfp)
                   VALUES(pr_cdcooper
                         ,1     -- super-usuario
                         ,pr_rw_crapdat.dtmvtolt
                         ,rw_craplfp.nrdconta
                         ,vr_nrdocmto
                         ,rw_craplfp.vllancto
                         ,vr_cdhistec
                         ,rw_craplot_tec.nrdolote
                         ,100   -- cdbccxlt
                         ,1     -- cdagenci
                         ,0     -- falso flgenvio
                         ,NULL  -- dttransf
                         ,0     -- hrtransf
                         ,rw_craplfp.progress_recid); -- Recid do pagamento para busca da empresa em possiveis estornos
            EXCEPTION
              WHEN OTHERS THEN
                vr_blnerror := TRUE;
                vr_dscritic := SQLERRM;
                -- Atualiza com sucesso ou erro
                UPDATE craplfp
                   SET idsitlct = 'E'
                      ,dsobslct = 'Problema encontrado -> '||vr_dscritic
                 WHERE ROWID = rw_craplfp.rowid;
            END;

            -- Se ocorreu erro na inclusao da LCS ou atualizacao da LFP
            IF vr_blnerror THEN
              -- Envia o erro para o LOG porem continua o processo
              BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': ' ||
                                                            'CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres ||
                                                            ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(rw_craplfp.nrdconta)) || ' – TRANSFERENCIA ' ||
                                                            vr_cdhistec || ' NO VALOR DE R$ ' ||
                                                            TO_CHAR(rw_craplfp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') ||
                                                            ' NÃO EFETUADA: ' || vr_dscritic
                                        ,pr_nmarqlog     => 'FOLHIB');
            ELSE
              -- Marca como possui CTASAL
              vr_blctasal := TRUE;

              BEGIN
                -- Atualiza a CRAPLOT_TEC (CTASAL)
                UPDATE craplot
                   SET qtinfoln = qtinfoln + 1
                      ,vlinfocr = vlinfocr + rw_craplfp.vllancto
                      ,qtcompln = qtcompln + 1
                      ,vlcompcr = vlcompcr + rw_craplfp.vllancto
                      ,nrseqdig = nrseqdig + 1
                 WHERE ROWID = rw_craplot_tec.rowid;
              END;

              BEGIN
                -- Atualiza solicitação da trasferência
                UPDATE craplfp
                   SET dsobslct = 'Transf. solicitada, aguardar transmissão'
                 WHERE ROWID = rw_craplfp.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_blnerror := TRUE;
              END;

              -- Adicionamos no LOG o sucesso ocorrido na transferencia do pagamento
              BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 1 -- Processo Normal
                                        ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': CREDITO DE FOLHA – EMP ' ||
                                                            rw_crapemp.cdempres || ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(rw_craplfp.nrdconta)) || ' – TRANSFERENCIA ' ||
                                                            vr_cdhistec || ' NO VALOR DE R$ ' ||
                                                            TO_CHAR(rw_craplfp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') ||
                                                            ' SOLICITADA COM SUCESSO – AGUARDAR TRANSMISSAO'
                                        ,pr_nmarqlog     => 'FOLHIB');

            END IF;

          END IF; -- idtpcont = 'C' ou 'T'

          -- Carrega os dados na PLTABLE
          vr_tab_crappfp(rw_craplfp.pfp_rowid) := rw_craplfp.qtlctpag;

          -- Caso seja do tipo Convencional
          IF rw_craplfp.idtppagt = 'C' THEN
            --Se a empresa escolheu gravar o salario
            IF rw_craplfp.flgrvsal = 1 THEN
              --Atualizaremos o salário com este lançamento
              vr_tab_craplfp(rw_craplfp.nrdconta).vllancto := rw_craplfp.vllancto;
            ELSE
             --Iremos apagar o histórico de salário
             vr_tab_craplfp(rw_craplfp.nrdconta).vllancto := 0;
            END IF;
          END IF;

          -- Caso seja ultimo registro da empresa
          IF rw_craplfp.numempre = rw_craplfp.qtempres THEN

            -- Caso seja debito em folha
            IF rw_craplfp.fldebfol = 1 THEN

              vr_dtexecde := pr_rw_crapdat.dtmvtopr;

              -- Se o dia da dtmvtopr for anterior ao dia limite para debitos
              IF TO_CHAR(vr_dtexecde,'DD') <= rw_crapemp.dtlimdeb THEN
                vr_dtexecde := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                          ,pr_dtmvtolt => TO_DATE(TO_CHAR(rw_crapemp.dtlimdeb,'fm00') || '/' || 
                                                                                  TO_CHAR(pr_rw_crapdat.dtmvtopr,'MM/RRRR'), 
                                                                                  'DD/MM/RRRR'));
              END IF;

              BEGIN
                -- Inserir registro de controle na craptab
                INSERT INTO craptab
                           (nmsistem
                           ,tptabela
                           ,cdempres
                           ,cdacesso
                           ,tpregist
                           ,cdcooper
                           ,dstextab)
                     VALUES('CRED'              -- nmsistem
                           ,'USUARI'            -- tptabela
                           ,rw_crapemp.cdempres -- cdempres
                           ,'EXECDEBEMP'        -- cdacesso
                           ,0                   -- tpregist
                           ,pr_cdcooper         -- cdcooper
                           ,TO_CHAR(rw_craplfp.dtmacred,'DD/MM/RRRR') || ' ' ||
                            TO_CHAR(vr_dtexecde,'DD/MM/RRRR') || ' 0' ); -- dstextab
              EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                  -- Se ja existe deve alterar
                  BEGIN
                    UPDATE craptab
                       SET craptab.dstextab = TO_CHAR(rw_craplfp.dtmacred,'DD/MM/RRRR') || ' ' ||
                                              TO_CHAR(vr_dtexecde,'DD/MM/RRRR') || ' 0'
                     WHERE craptab.cdcooper        = pr_cdcooper
                       AND UPPER(craptab.nmsistem) = 'CRED'
                       AND UPPER(craptab.tptabela) = 'USUARI'
                       AND craptab.cdempres        = rw_crapemp.cdempres
                       AND UPPER(craptab.cdacesso) = 'EXECDEBEMP'
                       AND craptab.tpregist        = 0;
                  END;
              END;

              -- Busca os avisos de debito que tenham ficado pendentes para gerar a CRAPFOL zerada
              FOR rw_avs_fol IN cr_avs_fol(pr_cdcooper => pr_cdcooper,
                                           pr_cdempres => rw_crapemp.cdempres,
                                           pr_dtrefere => rw_craplfp.dtmacred) LOOP
                BEGIN
                  INSERT INTO crapfol
                             (cdcooper
                             ,cdempres
                             ,dtrefere
                             ,nrdconta)
                       VALUES(pr_cdcooper
                             ,rw_crapemp.cdempres
                             ,rw_craplfp.dtmacred
                             ,rw_avs_fol.nrdconta); --> Conta encontrada na AVS
                END;
              END LOOP; -- cr_avs_fol

            END IF; -- fldebfol = 1

            -- Inicializa as avariaveis
            vr_vlsddisp := 0;
            vr_tottarif := 0;
            vr_flsittar := 1;
            vr_dsobstar := NULL;

            -- Percorre a lista de pagamentos
            vr_chave := vr_tab_crappfp.FIRST;
            WHILE vr_chave IS NOT NULL LOOP
              BEGIN
                UPDATE crappfp
                   SET -- Atualiza os pagamentos que foram processados
                       dthorcre = SYSDATE,
                       flsitcre = 1, --> Creditado
                       dsobscre = NULL
                 WHERE ROWID = vr_chave;
              END;
              vr_chave := vr_tab_crappfp.NEXT(vr_chave);
            END LOOP;

            BEGIN
              -- Atualizar a data da ultima utilizacao do produto
              UPDATE crapemp
                 SET crapemp.dtultufp = SYSDATE
               WHERE crapemp.cdcooper = pr_cdcooper
                 AND crapemp.cdempres = rw_crapemp.cdempres;
            END;

            -- Percorre a lista de lancamentos
            vr_chave := vr_tab_craplfp.FIRST;
            WHILE vr_chave IS NOT NULL LOOP
              BEGIN
                -- Atualizar com o ultimo valor liquido pago
                UPDATE crapefp
                   SET vlultsal = vr_tab_craplfp(vr_chave).vllancto
                 WHERE cdcooper = pr_cdcooper
                   AND cdempres = rw_crapemp.cdempres
                   AND nrdconta = vr_chave;
              END;
              vr_chave := vr_tab_craplfp.NEXT(vr_chave);
            END LOOP;

            BEGIN
              -- Atualizar a CRAPTAB
              UPDATE craptab
                 SET craptab.dstextab        = SUBSTR(craptab.dstextab, 1, 13) || '1'
               WHERE craptab.cdcooper        = pr_cdcooper
                 AND UPPER(craptab.nmsistem) = 'CRED'
                 AND UPPER(craptab.tptabela) = 'GENERI'
                 AND craptab.cdempres        = 0
                 AND UPPER(craptab.cdacesso) = 'DIADOPAGTO'
                 AND craptab.tpregist        = rw_crapemp.cdempres;
            END;

            -- Lotes de Folha/Emprestimo/Cotas
            FOR vr_index IN 1..3 LOOP

              -- Carrega os lotes
              CASE vr_index
                WHEN 1 THEN vr_lote_nro := rw_craplot_fol.nrdolote;
                WHEN 2 THEN vr_lote_nro := rw_craplot_emp.nrdolote;
                WHEN 3 THEN vr_lote_nro := rw_craplot_cot.nrdolote;
              END CASE;

              -- Busca o lote FOL/EMP/COT
              OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                              pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                              pr_nrdolote => vr_lote_nro);
              FETCH cr_craplot INTO rw_craplot;
              CLOSE cr_craplot;

              -- Caso os valores de credito/debito estejam zerados
              IF rw_craplot.vlinfodb = 0 AND
                 rw_craplot.vlcompdb = 0 AND
                 rw_craplot.vlinfocr = 0 AND
                 rw_craplot.vlcompcr = 0 THEN
                BEGIN
                  -- Remove o lote zerado
                  DELETE FROM craplot WHERE ROWID = rw_craplot.rowid;
                END;
              END IF;

            END LOOP; -- Fim do loop 1..3 dos lotes

            -- Efetua Commit
            COMMIT;

            -- Caso possua CTASAL
            IF vr_blctasal THEN

              -- Verifica lancamentos pendentes de envio ao SPB
              OPEN cr_lancspb(pr_cdcooper => pr_cdcooper,
                              pr_cdempres => rw_crapemp.cdempres);
              FETCH cr_lancspb INTO rw_lancspb;
              vr_blnfound := cr_lancspb%FOUND;
              CLOSE cr_lancspb;

              -- Se encontrou lancamentos pendentes
              IF vr_blnfound THEN

                -- Chama a rotina PC_TRFSAL_OPCAO_B
                SSPB0001.pc_trfsal_opcao_b(pr_cdcooper => pr_cdcooper
                                          ,pr_cdagenci => 0
                                          ,pr_nrdcaixa => 1
                                          ,pr_cdoperad => 1
                                          ,pr_cdempres => rw_crapemp.cdempres
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);

                -- Se retornar critica
                IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN

                  -- Envia o erro para o LOG
                  BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': ' ||
                                                                'CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres ||
                                                                ' – CONTA ' || rw_crapemp.nrdconta || ' –  ERRO NAO TRATADO COM AS TECS SALARIO: ' ||
                                                                vr_cdcritic || '-' || vr_dscritic
                                            ,pr_nmarqlog     => 'FOLHIB');

                  -- Destinatarios responsaveis pelos avisos
                  vr_emailds2 :=  GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                           ,pr_cdcooper => pr_cdcooper
                                                           ,pr_cdacesso => 'FOLHAIB_EMAIL_ALERT_FIN');

                  -- Mensagem informando o erro
                  vr_dsmensag := 'Houveram erros inesperados no sistema e as transferências TEC salário ' ||
                                 'da empresa não puderam ser efetuadas automaticamente. Abaixo trazemos o ' ||
                                 'erro ocorrido:<br>' || vr_cdcritic || '-' || vr_dscritic || '<br><br>' ||
                                 'Lembramos que estes pagamentos continuam pendentes de processamento e ' ||
                                 'sugerimos que os mesmos sejam gerados pela tela TRFSAL, opção B.';

                  -- Solicita envio do email
                  GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                            ,pr_cdprogra        => 'FOLH0001'
                                            ,pr_des_destino     => TRIM(vr_emailds2)
                                            ,pr_des_assunto     => 'Folha de Pagamento - Problema com as TECs – Empresa ' || rw_crapemp.cdempres || ' - ' || rw_crapemp.nmresemp
                                            ,pr_des_corpo       => vr_dsmensag
                                            ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                            ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                            ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                            ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                            ,pr_des_erro        => vr_dscritic);

                END IF; -- vr_cdcritic / vr_dscritic

              END IF; -- vr_blnfound

              -- Reseta a variavel
              vr_blctasal := FALSE;

              COMMIT;

            END IF; -- vr_blctasal

          END IF; -- numempre = qtempres

        END LOOP; -- cr_craplfp

        -- Após processar todos os pagamentos da empresa, iremos atualizar
        -- aqueles pagamentos em que só restaram lançamentos de erro, e devido
        -- a isso o mesmo não é processado e ficaria pendente

        BEGIN
          UPDATE crappfp pfp
             SET pfp.dthorcre = SYSDATE
                ,pfp.flsitcre = 1 --> Creditado
           WHERE pfp.cdcooper = pr_cdcooper
             AND pfp.cdempres = rw_crapemp.cdempres
             AND pfp.flsitdeb = 1 -- Já debitado
             AND pfp.flsitcre = 0 -- Com crédito pendente
             -- Não exista nenhum lançamento pendente
             AND NOT EXISTS(SELECT 1
                              FROM craplfp lfp
                             WHERE pfp.cdcooper = lfp.cdcooper
                               AND pfp.cdempres = lfp.cdempres
                               AND pfp.nrseqpag = lfp.nrseqpag
                               AND lfp.idsitlct = 'L'
                               AND lfp.vllancto > 0);
        END;

        -- Atualizar todos os lançamentos sem crédito pois eles estão pendentes devido ao vllancto = 0
        BEGIN
          UPDATE craplfp lfp
             SET lfp.idsitlct = 'C'
                ,lfp.dsobslct = 'Lançamento sem crédito - apenas para emissão do comprovante'
           WHERE lfp.cdcooper = pr_cdcooper
             AND lfp.cdempres = rw_crapemp.cdempres
             AND lfp.idsitlct = 'L' -- Ainda pendentes
             AND lfp.vllancto = 0 -- Somente aqueles sem crédito
             -- E o pagamento tenha sido creditado
             AND EXISTS (SELECT 1
                           FROM crappfp pfp
                          WHERE pfp.cdcooper = lfp.cdcooper
                            AND pfp.cdempres = lfp.cdempres
                            AND pfp.nrseqpag = lfp.nrseqpag
                            AND pfp.flsitcre = 1);
        END;

        -- Adicionamos no LOG o encerramento do processo de credito desta empresa
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- Processo Normal
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': CREDITO DE FOLHA – EMP ' ||
                                                      rw_crapemp.cdempres || ' – ENCERRAMENTO DO PROCESSO DE CREDITO'
                                  ,pr_nmarqlog     => 'FOLHIB');
        -- Gravação final
        COMMIT;
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Desfazemos alterações até o momento adicionamos ao
          -- log da empresa o erro tratado
          ROLLBACK;
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 1 -- Processo Normal
                                    ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': CREDITO DE FOLHA – EMP ' ||
                                                        rw_crapemp.cdempres || ' – ERRO NO PROCESSO --> '||vr_dscritic
                                  ,pr_nmarqlog     => 'FOLHIB');
        WHEN OTHERS THEN
          -- Desfazemos alterações até o momento adicionamos ao
          -- log da empresa o erro não tratado
          ROLLBACK;
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 1 -- Processo Normal
                                    ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': CREDITO DE FOLHA – EMP ' ||
                                                        rw_crapemp.cdempres || ' – ERRO NO PROCESSO --> '||SQLERRM
                                    ,pr_nmarqlog     => 'FOLHIB');
      END;
    END LOOP; -- cr_crapemp

    -- Busca o lote TEC (Global para a Cooperativa)
    OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                    pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                    pr_nrdolote => rw_craplot_tec.nrdolote);
    FETCH cr_craplot INTO rw_craplot_tec;
    CLOSE cr_craplot;

    -- Caso os valores de credito/debito estejam zerados
    IF rw_craplot_tec.vlinfodb = 0 AND
       rw_craplot_tec.vlcompdb = 0 AND
       rw_craplot_tec.vlinfocr = 0 AND
       rw_craplot_tec.vlcompcr = 0 THEN
      BEGIN
        -- Remove o lote zerado
        DELETE FROM craplot WHERE ROWID = rw_craplot_tec.rowid;
      END;
    END IF;

    -- Efetua Commit
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer a operacao
      ROLLBACK;
      -- efetuar o raise
      raise_application_error(-25001, 'Erro FOLH0001.PC_CREDITO_PAGTO_APROVADOS: '||vr_dscritic);
    WHEN OTHERS THEN
      -- Desfazer a operacao
      ROLLBACK;
      -- efetuar o raise
      raise_application_error(-25000, 'Erro FOLH0001.PC_CREDITO_PAGTO_APROVADOS: '||vr_dscritic);
  END pc_credito_pagto_aprovados;*/
  
  /* Procedure para realizar processamento de credito dos pagamentos aprovados de contas da cooperativa */
  PROCEDURE pc_cr_pagto_aprovados_coop(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                      ,pr_rw_crapdat IN BTCH0001.cr_crapdat%ROWTYPE) IS
  ---------------------------------------------------------------------------------------------------------------
  ---------------------------ROTINA CRIADA A PARTIR DA PROCEDURE pc_cr_pagto_aprovados----------------------------
  --
  --  Programa : pc_cr_pagto_aprovados_coop             Antigo: 
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Kelvin
  --  Data     : Janeiro/2017.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para realizar processamento de credito dos pagamentos aprovados
  --             de contas da cooperativa
  -- Alterações
  --             12/11/2015 - Migracao da tarifação do sistema da CONFOL para CADTAR,
  --                          com isso removi a cobrança da tarifa deste ponto, deixando
  --                          apenas na pc_cobra_tarifas_pendentes (Marcos-Supero)
  --
  --             07/12/2015 - Ajustado para validar se o pagamento caso seja do tipo convencional,
  --                          verificar se a empresa resolveu gravar o salario ou nao.
  --                          (Andre Santos - SUPERO)
  --
  --             25/01/2016 - Ajuste nas mensagens de erro (Marcos-Supero)
  --
  --             27/01/2016 - Incluir controle de lançamentos sem crédito (Marcos-Supero)
  --             
  --             01/03/2016 - Ajustes para evitar dup_val_on_index em pagamentos ctasal
  --                          para a mesma conta no mesmo dia (Marcos-Supero)
  -- 
  -- 
  --             22/04/2016 - Inclusao de NVL para evitar que o LCM seja criado sem conta 
  --                          (Marcos - Supero)
  --
  --             23/05/2016 - Ajuste para gravar tab EXECDEBEMP com crapemp.dtlimdeb caso
  --                          dia da dtmvtopr for anterior ao dia limite para debitos. 
  --                          (Jaison/Marcos - Supero)
  --
  --            29/05/2018 -  Processamento de credito dos pagamentos aprovados de contas da cooperativa utilizando
  --                          LANC0001  Rangel Decker  AMcom
  --
  ---------------------------------------------------------------------------------------------------------------

    -- Busca os dados do lote
    CURSOR cr_craplot(pr_cdcooper craplot.cdcooper%TYPE,
                      pr_dtmvtolt craplot.dtmvtolt%TYPE,
                      pr_nrdolote craplot.nrdolote%TYPE) IS
        SELECT nrdolote
              ,nrseqdig
              ,qtinfoln
              ,qtcompln
              ,vlinfodb
              ,vlcompdb
              ,vlinfocr
              ,vlcompcr
              ,ROWID
          FROM craplot
         WHERE craplot.cdcooper = pr_cdcooper
           AND craplot.dtmvtolt = pr_dtmvtolt
           AND craplot.cdagenci = 1
           AND craplot.cdbccxlt = 100
           AND craplot.nrdolote = pr_nrdolote;
    rw_craplot     cr_craplot%ROWTYPE;
    rw_craplot_tec cr_craplot%ROWTYPE;
    rw_craplot_fol cr_craplot%ROWTYPE;
    rw_craplot_emp cr_craplot%ROWTYPE;
    rw_craplot_cot cr_craplot%ROWTYPE;

    -- Busca as empresas com pagamentos pendentes
    CURSOR cr_crapemp(pr_cdcooper crapemp.cdcooper%TYPE,
                      pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
        SELECT emp.cdempres
              ,emp.nmresemp
              ,emp.idtpempr
              ,emp.nrdconta
              ,emp.dtlimdeb
              ,ass.vllimcre
              ,SUM(lfp.vllancto) vllancto
          FROM crappfp pfp
              ,crapemp emp
              ,craplfp lfp
              ,crapass ass
         WHERE pfp.cdcooper  = pr_cdcooper
           AND pfp.dtcredit <= pr_dtmvtolt
           AND pfp.cdcooper  = emp.cdcooper
           AND pfp.cdempres  = emp.cdempres
           AND pfp.cdcooper  = lfp.cdcooper
           AND pfp.cdempres  = lfp.cdempres
           AND pfp.nrseqpag  = lfp.nrseqpag           
           AND ass.cdcooper  = emp.cdcooper
           AND ass.nrdconta  = emp.nrdconta
           AND pfp.idsitapr  > 3 --> Aprovados
           AND pfp.idsitapr  <> 6 --> Transação Pendente
           AND pfp.flsitdeb  = 1 --> Ja debitados
           AND pfp.flsitcre  = 0 --> Ainda nao creditados
           AND lfp.idtpcont  = 'C'
         GROUP BY emp.cdempres
                 ,emp.nmresemp
                 ,emp.idtpempr
                 ,emp.nrdconta
                 ,emp.dtlimdeb
                 ,ass.vllimcre;

    -- Busca o numero do Lote
    CURSOR cr_craptab_lot(pr_cdcooper craptab.cdcooper%TYPE,
                          pr_cdacesso craptab.cdacesso%TYPE,
                          pr_tpregist craptab.tpregist%TYPE) IS
         SELECT TO_NUMBER(dstextab)
           FROM craptab
          WHERE craptab.cdcooper        = pr_cdcooper
            AND UPPER(craptab.nmsistem) = 'CRED'
            AND UPPER(craptab.tptabela) = 'GENERI'
            AND craptab.cdempres        = 0
            AND UPPER(craptab.cdacesso) = pr_cdacesso
            AND craptab.tpregist        = pr_tpregist;

    -- Busca os pagamentos pendentes
    CURSOR cr_craplfp(pr_cdcooper crappfp.cdcooper%TYPE,
                      pr_dtmvtolt crapdat.dtmvtolt%TYPE,
                      pr_cdempres crappfp.cdempres%TYPE,
                      pr_idtpempr crapemp.idtpempr%TYPE) IS
        SELECT pfp.nrseqpag
              ,pfp.idtppagt
              ,pfp.flgrvsal
              ,pfp.qtlctpag
              ,pfp.ROWID pfp_rowid
              ,LAST_DAY(ADD_MONTHS(pfp.dtcredit, -1)) dtmacred -- Ultimo dia do mes anterior ao credito
              ,DECODE(pr_idtpempr,'C',ofp.cdhscrcp,ofp.cdhiscre) cdhiscre
              ,ofp.fldebfol
              ,lfp.nrseqlfp
              ,lfp.idtpcont
              ,lfp.nrdconta
              ,lfp.nrcpfemp
              ,lfp.vllancto
              ,lfp.ROWID
              ,lfp.progress_recid

              ,ROW_NUMBER() OVER (PARTITION BY lfp.cdempres ORDER BY lfp.cdempres) AS numempre
              ,COUNT(1) OVER (PARTITION BY lfp.cdempres) qtempres

              ,ROW_NUMBER() OVER (PARTITION BY lfp.cdempres,ofp.fldebfol,lfp.nrdconta ORDER BY lfp.cdempres,ofp.fldebfol,lfp.nrdconta,DECODE(pr_idtpempr,'C',ofp.cdhscrcp,ofp.cdhiscre)) AS numdebfol
              ,COUNT(1) OVER (PARTITION BY lfp.cdempres,ofp.fldebfol,lfp.nrdconta) qtdebfol
              ,lfp.cdcooper
              ,lfp.cdempres              
          FROM crappfp pfp
              ,craplfp lfp
              ,crapofp ofp
         WHERE pfp.cdcooper  = pr_cdcooper
           AND pfp.dtcredit <= pr_dtmvtolt
           AND pfp.cdempres  = pr_cdempres
           AND pfp.cdcooper  = lfp.cdcooper
           AND pfp.cdempres  = lfp.cdempres
           AND pfp.nrseqpag  = lfp.nrseqpag
           AND lfp.cdcooper  = ofp.cdcooper
           AND lfp.cdorigem  = ofp.cdorigem
           AND pfp.flsitdeb  = 1   --> Ja debitados
           AND pfp.flsitcre  = 0   --> Ainda nao creditados
           AND lfp.idsitlct NOT IN('E','C') --> Desconsiderar os com erros ou creditados
           AND nvl(lfp.dsobslct,' ') <> 'Transf. solicitada, aguardar transmissão' -- Desconsiderar tbm CTASAL solicitado, pois sua situação persiste em L e somente a Obs pode ser eusada
           AND lfp.vllancto  > 0
           AND lfp.idtpcont  = 'C'
      ORDER BY lfp.cdempres
              ,ofp.fldebfol
              ,lfp.nrdconta
              ,DECODE(pr_idtpempr,'C',ofp.cdhscrcp,ofp.cdhiscre);

    -- Busca a conta do cooperado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT CASE
                 WHEN ass.cdsitdtl IN (2,4,6,8) THEN nvl(trf.nrsconta,ass.nrdconta)
                 ELSE ass.nrdconta
               END
          FROM crapass ass
              ,craptrf trf
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta
           AND trf.cdcooper(+) = ass.cdcooper
           AND trf.nrdconta(+) = ass.nrdconta
           AND trf.tptransa(+) = 1
           AND trf.insittrs(+) = 2;

    -- Busca os avisos de debitos de emprestimo/cotas com debito em folha
    CURSOR cr_crapavs(pr_cdcooper crapavs.cdcooper%TYPE,
                      pr_nrdconta crapavs.nrdconta%TYPE,
                      pr_dtrefere crapavs.dtrefere%TYPE) IS
        SELECT crapavs.*
              ,crapavs.rowid
          FROM crapavs
         WHERE crapavs.cdcooper = pr_cdcooper
           AND crapavs.nrdconta = pr_nrdconta
           AND crapavs.tpdaviso = 1
           AND crapavs.cdhistor IN (108,127)
           AND crapavs.dtrefere = pr_dtrefere
           AND crapavs.insitavs = 0
      ORDER BY crapavs.cdhistor;

    -- Lancamentos dos funcionarios que transferem o salario para outra IF
    CURSOR cr_avs_fol(pr_cdcooper crapavs.cdcooper%TYPE,
                      pr_cdempres crapavs.cdempres%TYPE,
                      pr_dtrefere crapavs.dtrefere%TYPE) IS
        SELECT crapavs.nrdconta
          FROM crapavs
         WHERE crapavs.cdcooper = pr_cdcooper
           AND crapavs.cdempres = pr_cdempres
           AND crapavs.dtrefere = pr_dtrefere
           AND crapavs.tpdaviso = 1 --> Folha
           AND crapavs.insitavs = 0 --> Nao debitado
           AND crapavs.cdhistor IN (108,127)

           -- Ja garantimos que nao exista CRAPFOL para evitar DUP_VAL_ON_INDEX
           AND NOT EXISTS(SELECT 1
                            FROM crapfol
                           WHERE crapfol.cdcooper = crapavs.cdcooper
                             AND crapfol.cdempres = crapavs.cdempres
                             AND crapfol.dtrefere = crapavs.dtrefere
                             AND crapfol.nrdconta = crapavs.nrdconta)

      GROUP BY crapavs.nrdconta;
    
    --Retorna se existe contas ctasal no lote de pagamento  
    CURSOR cr_verifica_ctasal(pr_rowid ROWID) IS
      SELECT 1 
        FROM crappfp pfp
            ,craplfp lfp
       WHERE lfp.cdcooper = pfp.cdcooper  
         AND lfp.cdempres = pfp.cdempres
         AND lfp.nrseqpag = pfp.nrseqpag
         AND lfp.idtpcont = 'T'                  
         AND pfp.rowid = pr_rowid;
    
    -- Tabelas
    TYPE typ_tab_crappfp IS
      TABLE OF crappfp.qtlctpag%TYPE
      INDEX BY VARCHAR2(25);

    TYPE typ_reg_craplfp IS
      RECORD (vllancto craplfp.vllancto%TYPE);

    TYPE typ_tab_craplfp IS
      TABLE OF typ_reg_craplfp
      INDEX BY PLS_INTEGER;

    -- Variaveis da PLTABLE
    vr_tab_crappfp typ_tab_crappfp;
    vr_tab_craplfp typ_tab_craplfp;

    -- Variaveis
    vr_cdhistor   craplcm.cdhistor%TYPE;    
    vr_lote_tec   crapprm.dsvlrprm%TYPE;
    vr_lote_nro   craplot.nrdolote%TYPE;
    vr_dstextab   craptab.dstextab%TYPE;
    vr_nmprimtl   crapass.nmprimtl%TYPE;
    vr_nrdconta   crapass.nrdconta%TYPE;
    vr_flsittar   crappfp.flsittar%TYPE;
    vr_dsobstar   crappfp.dsobstar%TYPE;
    vr_idsitlct   craplfp.idsitlct%TYPE;
    vr_dsobslct   craplfp.dsobslct%TYPE;
    vr_vlsalliq   craplfp.vllancto%TYPE;
    vr_vldebtot   craplfp.vllancto%TYPE;
    vr_tot_debcot craplfp.vllancto%TYPE;
    vr_tot_debemp craplfp.vllancto%TYPE;
    vr_tot_lanc   craplfp.vllancto%TYPE;
    vr_tottarif   craplfp.vllancto%TYPE;
    vr_vlsddisp   crapsda.vlsddisp%TYPE;
    vr_vldoipmf   NUMBER;
    vr_inusatab   BOOLEAN;
    vr_blnfound   BOOLEAN;
    vr_blnerror   BOOLEAN;
    vr_lotechav   VARCHAR2(10);
    vr_emailds1   VARCHAR2(1000);
    vr_dsmensag   VARCHAR2(4000);
    vr_chave      VARCHAR2(25);
    vr_dtexecde   DATE;
    vr_idtipcon   NUMBER;
    vr_idportab   BOOLEAN; -- Indica que o cooperado tem portabilidade ativa
    vr_idprtrlz   NUMBER;  -- Indica que portabilidade foi realizada

    -- Variaveis de Erro
    vr_cdcritic   crapcri.cdcritic%TYPE;
    vr_dscritic   VARCHAR2(4000);
    vr_dsalerta   VARCHAR2(4000);

    -- Variaveis Excecao
    vr_exc_erro   EXCEPTION;

  BEGIN
    --Inicializacao de variaveis
    vr_idtipcon := NULL;
    
    -- Destinatarios responsaveis pelos avisos
    vr_emailds1 :=  GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_cdacesso => 'FOLHAIB_EMAIL_ALERT_PROC');

    -- Leitura do indicador de uso da tabela de taxa de juros
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'TAXATABELA'
                                             ,pr_tpregist => 0);
    IF vr_dstextab IS NULL THEN
      vr_inusatab := FALSE;
    ELSE
      IF SUBSTR(vr_dstextab,1,1) = '0' THEN
          vr_inusatab := FALSE;
      ELSE
        vr_inusatab := TRUE;
      END IF;
    END IF;

    -- Busca o numero de lote para gravacao
    vr_lote_tec := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_cdacesso => 'FOLHAIB_NRLOTE_CTASAL');

    -- Efetua a busca do lote TEC
    OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                    pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                    pr_nrdolote => vr_lote_tec);
    FETCH cr_craplot INTO rw_craplot_tec;
    -- Alimenta a booleana se achou ou nao
    vr_blnfound := cr_craplot%FOUND;
    -- Fecha cursor
    CLOSE cr_craplot;

    -- Se nao achou faz a criacao do lote TEC
    IF NOT vr_blnfound THEN
      BEGIN
       LANC0001.pc_incluir_lote(pr_cdcooper => pr_cdcooper
                               ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                               ,pr_cdagenci => 1
                               ,pr_cdbccxlt => 100
                               ,pr_nrdolote => vr_lote_tec
                               ,pr_rw_craplot => vr_rcraplot
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               );

       rw_craplot_tec.rowid := vr_rcraplot.rowid;

      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
       END IF;

      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          
          vr_dscritic := '060 - Lote inexistente.';

          -- Envia o erro para o LOG
          CECRED.pc_log_programa(pr_dstiplog => 'O'
                                 , pr_cdprograma => 'FOLH0001' 
                                 , pr_cdcooper => pr_cdcooper
                                 , pr_tpexecucao => 0
                                 , pr_tpocorrencia => 3 
                                 , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro não tratado na rotina pc_cr_pagto_aprovados_coop. Detalhes: ' || ' - ' || vr_dscritic
                                 , pr_idprglog => vr_idprglog);
          
          -- Mensagem informando o erro
          vr_dsmensag := 'Houve erro inesperado na inclusão do lote CTASAL. ' ||
                         'Abaixo trazemos o erro retornado durante a operação: <br> ' ||
                         vr_dscritic;

          -- Solicita envio do email
          GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => 'FOLH0001'
                                    ,pr_des_destino     => TRIM(vr_emailds1)
                                    ,pr_des_assunto     => 'Folha de Pagamento - Problema com o crédito – CTASAL'
                                    ,pr_des_corpo       => vr_dsmensag
                                    ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                    ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                    ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                    ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                    ,pr_des_erro        => vr_dscritic);
          RAISE vr_exc_erro;
      END;

      COMMIT; -- Salva o lote TEC
    END IF;

    -- Percorre todas as empresas da cooperativa atual
    FOR rw_crapemp IN cr_crapemp(pr_cdcooper => pr_cdcooper,
                                 pr_dtmvtolt => pr_rw_crapdat.dtmvtolt) LOOP

      BEGIN
        -- Adicionamos no LOG o inicio do pagamento
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                             , pr_cdprograma => 'FOLH0001' 
                             , pr_cdcooper => pr_cdcooper
                             , pr_tpexecucao => 0
                             , pr_tpocorrencia => 1 
                             , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Rotina pc_cr_pagto_aprovados_coop. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' – INICIANDO CREDITO DOS EMPREGADOS – VALOR TOTAL PREVISTO DE R$ ' || TO_CHAR(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.')
                             , pr_idprglog => vr_idprglog);        

        -- Inicializa as variaveis
        vr_blnerror    := FALSE;
        rw_craplot_fol := NULL;
        rw_craplot_emp := NULL;
        rw_craplot_cot := NULL;

        -- Lotes de Folha/Emprestimo/Cotas
        FOR vr_index IN 1..3 LOOP

          -- Chave de acesso
          CASE vr_index
            WHEN 1 THEN vr_lotechav := 'NUMLOTEFOL';
            WHEN 2 THEN vr_lotechav := 'NUMLOTEEMP';
            WHEN 3 THEN vr_lotechav := 'NUMLOTECOT';
          END CASE;

          -- Efetua a busca do codigo do lote FOL/EMP/COT
          OPEN cr_craptab_lot(pr_cdcooper => pr_cdcooper,
                              pr_cdacesso => vr_lotechav,
                              pr_tpregist => rw_crapemp.cdempres);
          FETCH cr_craptab_lot INTO vr_lote_nro;
          -- Alimenta a booleana se achou ou nao
          vr_blnfound := cr_craptab_lot%FOUND;
          -- Fecha cursor
          CLOSE cr_craptab_lot;

          -- Se nao achou
          IF NOT vr_blnfound THEN
            vr_blnerror := TRUE;
            EXIT; -- Sai do loop 1..3
          END IF;

          -- Busca o lote FOL/EMP/COT
          OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                          pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                          pr_nrdolote => vr_lote_nro);
          FETCH cr_craplot INTO rw_craplot;
          -- Alimenta a booleana se achou ou nao
          vr_blnfound := cr_craplot%FOUND;
          -- Fecha cursor
          CLOSE cr_craplot;

          -- Se nao achou faz a criacao do lote FOL/EMP/COT
          IF NOT vr_blnfound THEN
            BEGIN
             LANC0001.pc_incluir_lote(pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                                     ,pr_cdagenci => 1
                                     ,pr_cdbccxlt => 100
                                     ,pr_nrdolote => vr_lote_nro
                                     ,pr_tplotmov =>1
                                     ,pr_rw_craplot => vr_rcraplot
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);

              rw_craplot.rowid:= vr_rcraplot.rowid;

               IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                 RAISE vr_exc_erro;
              END IF;


            EXCEPTION
              WHEN OTHERS THEN
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                vr_blnerror := TRUE;
                EXIT; -- Sai do loop 1..3
            END;

          END IF;

          -- Carrega os lotes e cursores
          CASE vr_index
            WHEN 1 THEN
              rw_craplot_fol := rw_craplot;
              rw_craplot_fol.nrdolote := vr_lote_nro;
            WHEN 2 THEN
              rw_craplot_emp := rw_craplot;
              rw_craplot_emp.nrdolote := vr_lote_nro;
            WHEN 3 THEN
              rw_craplot_cot := rw_craplot;
              rw_craplot_cot.nrdolote := vr_lote_nro;
          END CASE;

        END LOOP; -- Fim do loop 1..3 dos lotes

        -- Caso tenha ocorrido erro na inclusao do lote vai para a proxima empresa e desfaz as acoes
        IF vr_blnerror THEN

          -- Mensagem de Critica
          vr_dscritic := '060 - Lote inexistente.';

          -- Envia o erro para o LOG
          CECRED.pc_log_programa(pr_dstiplog => 'O'
                               , pr_cdprograma => 'FOLH0001' 
                               , pr_cdcooper => pr_cdcooper
                               , pr_tpexecucao => 0
                               , pr_tpocorrencia => 2 
                               , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro não tratado na rotina pc_cr_pagto_aprovados_coop. Detalhes: ' || vr_dscritic
                               , pr_idprglog => vr_idprglog);      

          -- Mensagem informando o erro
          vr_dsmensag := 'Houve erro inesperado na busca do numero do lote ('|| vr_lotechav ||') ' ||
                         'para a empresa ' || rw_crapemp.cdempres || ' - ' || rw_crapemp.nmresemp || '. ' ||
                         'Abaixo trazemos o erro retornado durante a operação: <br> ' || vr_dscritic;

          -- Solicita envio do email
          GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => 'FOLH0001'
                                    ,pr_des_destino     => TRIM(vr_emailds1)
                                    ,pr_des_assunto     => 'Folha de Pagamento - Problema com o crédito – Empresa ' || rw_crapemp.cdempres || ' - ' || rw_crapemp.nmresemp
                                    ,pr_des_corpo       => vr_dsmensag
                                    ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                    ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                    ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                    ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                    ,pr_des_erro        => vr_dscritic);
          ROLLBACK;
          CONTINUE; -- Move para a proxima empresa
        END IF;

        COMMIT; -- Salva os lotes FOL/EMP/COT

        -- Limpa as PLTABLES
        vr_tab_crappfp.DELETE;
        vr_tab_craplfp.DELETE;

        -- Listagem dos pagamentos pendentes
        FOR rw_craplfp IN cr_craplfp(pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                                     pr_cdempres => rw_crapemp.cdempres,
                                     pr_idtpempr => rw_crapemp.idtpempr) LOOP
          
          vr_idtipcon := NULL;
          
          -- Verificar a situacao de cada conta, pois algum empregado pode ter encerrado sua conta
          -- ou efetuado alguma alteracao em seu cadastro que impeca o credito
          pc_valida_lancto_folha(pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => rw_craplfp.nrdconta,
                                 pr_nrcpfcgc => rw_craplfp.nrcpfemp,
                                 pr_dtcredit => null,                                 
                                 pr_idtpcont => rw_craplfp.idtpcont,
                                 pr_nmprimtl => vr_nmprimtl,
                                 pr_dsalerta => vr_dsalerta,
                                 pr_dscritic => vr_dscritic);
          -- Caso tenha retornado alguma critica
          IF vr_dsalerta IS NOT NULL OR
             vr_dscritic IS NOT NULL THEN
            BEGIN
              -- Atualiza com erro
              UPDATE craplfp
                 SET idsitlct = 'E'
                    ,dsobslct = NVL(vr_dsalerta,vr_dscritic)
               WHERE ROWID = rw_craplfp.rowid;
            END;

            -- Adicionamos no LOG o aviso de problema
            CECRED.pc_log_programa(pr_dstiplog => 'O'
                                 , pr_cdprograma => 'FOLH0001' 
                                 , pr_cdcooper => pr_cdcooper
                                 , pr_tpexecucao => 0
                                 , pr_tpocorrencia => 2 
                                 , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_cr_pagto_aprovados_coop. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(rw_craplfp.nrdconta)) || ' NO VALOR DE R$ ' || TO_CHAR(rw_craplfp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') || ' NÃO SERA EFETUADO, MOTIVO: '||NVL(vr_dsalerta,vr_dscritic)
                                 , pr_idprglog => vr_idprglog);
           
            CONTINUE;
          END IF;

          -- Busca a conta do associado
          OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => rw_craplfp.nrdconta);
          FETCH cr_crapass INTO vr_nrdconta;
          -- Fecha cursor
          CLOSE cr_crapass;

          -- Verfica se o cooperado tem portabilidade de salãrio vigente
          BEGIN
            vr_idportab := PCPS0001.fn_verifica_portabilidade(pr_cdcooper => pr_cdcooper
                                                             ,pr_nrdconta => vr_nrdconta);
          EXCEPTION 
            WHEN OTHERS THEN
              -- Em caso de erro não para o processo e mantem o valor na conta do cooperado
              vr_idportab := FALSE;
          END;
          
          -- Se indicar que a conta possui portabilidade
          IF vr_idportab THEN
            -- Esta alteração possivelmente causará impactos, principalmente no relatório de rendimentos.
            -- Tentei alinhar com os analistas Ailos e as areas envolvidas que não deveria ser alterado
            -- o processo de entrada do valor na conta do cooperado, porém não consegui convence-los, pois
            -- alegaram que querem tratar de forma diferente esses valores movimentados e que fazem parte
            -- do fluxo de portabilidade de salário (Renato Darosci - Supero - 23/02/2019)
            vr_cdhistor := 2943; -- CREDITO SALARIO - CONTA SALARIO
          ELSE
            -- Utiliza o parametro correto da configuração da folha de pagamento
            vr_cdhistor := rw_craplfp.cdhiscre;
          END IF;
          
          -- Inicializa as variaveis
          vr_idsitlct := 'C';
          vr_dsobslct := NULL;
          vr_blnerror := FALSE;

          BEGIN
            -- Atualiza a CRAPLOT_FOL
            UPDATE craplot
               SET qtinfoln = qtinfoln + 1
                  ,vlinfocr = vlinfocr + rw_craplfp.vllancto
                  ,qtcompln = qtcompln + 1
                  ,vlcompcr = vlcompcr + rw_craplfp.vllancto
                  ,nrseqdig = nrseqdig + 1
             WHERE ROWID = rw_craplot_fol.rowid
             RETURNING craplot.nrseqdig INTO rw_craplot_fol.nrseqdig;

            -- Inserir lancamento
             LANC0001.pc_gerar_lancamento_conta(pr_cdcooper =>pr_cdcooper
                                               ,pr_dtmvtolt =>pr_rw_crapdat.dtmvtolt
                                               ,pr_cdagenci => 1
                                               ,pr_cdbccxlt => 100
                                               ,pr_nrdolote => rw_craplot_fol.nrdolote
                                               ,pr_nrdconta => vr_nrdconta
                                               ,pr_nrdocmto => rw_craplfp.cdempres || rw_craplfp.nrseqpag || to_char(rw_craplfp.nrseqlfp,'fm00000')
                                               ,pr_vllanmto => rw_craplfp.vllancto
                                               ,pr_cdhistor => vr_cdhistor -- rw_craplfp.cdhiscre (Renato - Supero - 23/02/2019)
                                               ,pr_nrseqdig => rw_craplot_fol.nrseqdig
                                               ,pr_nrdctabb => vr_nrdconta
                                               ,pr_nrdctitg => GENE0002.fn_mask(vr_nrdconta,'99999999') -- nrdctitg
                                               -- OUTPUT --
                                              ,pr_tab_retorno => vr_tab_retorno
                                              ,pr_incrineg => vr_incrineg
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);

              IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                 RAISE vr_exc_erro;
              END IF;
                         
            pc_inserir_lanaut(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => vr_nrdconta
                             ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                             ,pr_cdhistor => vr_cdhistor -- rw_craplfp.cdhiscre (Renato - Supero - 23/02/2019)
                             ,pr_vlrenda  => rw_craplfp.vllancto
                             ,pr_cdagenci => 1
                             ,pr_cdbccxlt => 100
                             ,pr_nrdolote => rw_craplot_fol.nrdolote
                             ,pr_nrseqdig => rw_craplot_fol.nrseqdig
                             ,pr_dscritic => vr_dscritic);
                               
            IF  vr_dscritic IS NOT NULL THEN
                vr_idsitlct := 'E';
                vr_dsobslct := 'Problema encontrado no crédito ao empregado: '||SQLERRM;
                vr_blnerror := TRUE;
                ROLLBACK;

                -- Envia o erro para o LOG
                CECRED.pc_log_programa(pr_dstiplog => 'O'
                                     , pr_cdprograma => 'FOLH0001' 
                                     , pr_cdcooper => pr_cdcooper
                                     , pr_tpexecucao => 0
                                     , pr_tpocorrencia => 2 
                                     , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_cr_pagto_aprovados_coop. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(vr_nrdconta)) || ' –  CREDITO ' || vr_cdhistor || ' NO VALOR DE R$ ' || TO_CHAR(rw_craplfp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') || ' NÃO EFETUADO: ' || SQLERRM
                                     , pr_idprglog => vr_idprglog);                
            END IF;              
                         
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              vr_idsitlct := 'E';
              vr_dsobslct := 'Problema encontrado no crédito ao empregado: '||SQLERRM;
              vr_blnerror := TRUE;
              ROLLBACK;

              -- Envia o erro para o LOG
              CECRED.pc_log_programa(pr_dstiplog => 'O'
                                   , pr_cdprograma => 'FOLH0001' 
                                   , pr_cdcooper => pr_cdcooper
                                   , pr_tpexecucao => 0
                                   , pr_tpocorrencia => 2 
                                   , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_cr_pagto_aprovados_coop. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(vr_nrdconta)) || ' –  CREDITO ' || vr_cdhistor || ' NO VALOR DE R$ ' || TO_CHAR(rw_craplfp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') || ' NÃO EFETUADO: ' || SQLERRM
                                   , pr_idprglog => vr_idprglog);
              
          END;

          BEGIN
            -- Atualiza com sucesso ou erro
            UPDATE craplfp
               SET idsitlct = vr_idsitlct
                  ,dsobslct = vr_dsobslct
             WHERE ROWID = rw_craplfp.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              vr_blnerror := TRUE;
          END;

          -- Salva o lancamento de credito na conta e atualiza a situacao
          COMMIT;

          -- Define o indentificador de transferencia de portabilidade como não realizo
          vr_idprtrlz := 0;
          
          -- Se a conta possui portabilidade ativa
          IF vr_idportab THEN
            -- Realizar a transferencia de valor ou agendar para o dia seguinte (Rotina Pragma)
            PCPS0001.pc_transf_salario_portab(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => vr_nrdconta
                                             ,pr_nrridlfp => rw_craplfp.progress_recid  -- ID da CRAPLFP
                                             ,pr_vltransf => rw_craplfp.vllancto
                                             ,pr_idportab => vr_idprtrlz
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
            
            -- Não vai validar as mensagens de erro, pois se ocorreu erro já
            -- registrou log no arquivo da portabilidade e na VERLOG
            vr_cdcritic := NULL;
            vr_dscritic := NULL;
                                  
          END IF;
          
          -- Caso seja o primeiro registro reseta o total de credito
          IF rw_craplfp.numdebfol = 1 THEN
            vr_vlsalliq := 0;
          END IF;

          -- Se NAO ocorreu erro na inclusao da LCM ou atualizacao da LOT/LFP
          IF NOT vr_blnerror THEN
            -- Adicionamos no LOG o sucesso ocorrido no pagamento
            CECRED.pc_log_programa(pr_dstiplog => 'O'
                                 , pr_cdprograma => 'FOLH0001' 
                                 , pr_cdcooper => pr_cdcooper
                                 , pr_tpexecucao => 0
                                 , pr_tpocorrencia => 1 
                                 , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Rotina pc_cr_pagto_aprovados_coop. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(vr_nrdconta)) || ' – CREDITO ' ||vr_cdhistor || ' NO VALOR DE R$ ' || TO_CHAR(rw_craplfp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.')
                                 , pr_idprglog => vr_idprglog);           
          END IF;

          -- Caso tenha desconto em folha
          -- E: não tenha realizado uma portabilidade do salário, pois a area
          -- de negócio definiu que Conta Salário não terá débitos (Renato - Supero - 23/02/2019)
          IF rw_craplfp.fldebfol = 1 AND NVL(vr_idprtrlz,0) = 0 THEN

            -- Se NAO ocorreu erro na inclusao da LCM ou atualizacao da LOT/LFP
            IF NOT vr_blnerror THEN
              -- Soma o lancamento
              vr_vlsalliq := vr_vlsalliq + rw_craplfp.vllancto;
            END IF;

            -- Caso seja o ultimo registro e tenha salario liquido
            IF rw_craplfp.numdebfol = rw_craplfp.qtdebfol AND vr_vlsalliq > 0 THEN
              vr_blnerror := FALSE;

              BEGIN
                -- Atualiza o endividamento
                UPDATE crapass
                   SET dtedvmto = rw_craplfp.dtmacred
                      ,vledvmto = APLI0001.fn_round((vr_vlsalliq * 1.15) * 0.30,2)
                 WHERE cdcooper = pr_cdcooper
                   AND nrdconta = rw_craplfp.nrdconta;

                -- Insere ou atualiza o controle dos cheques salarios
                INSERT INTO crapfol
                           (cdcooper
                           ,cdempres
                           ,nrdconta
                           ,dtrefere
                           ,vllanmto)
                     VALUES(pr_cdcooper
                           ,rw_crapemp.cdempres
                           ,vr_nrdconta
                           ,pr_rw_crapdat.dtultdia
                           ,vr_vlsalliq);
              EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                  -- Se ja existir atualizar valor
                  UPDATE crapfol
                     SET crapfol.vllanmto = vr_vlsalliq
                   WHERE crapfol.cdcooper = pr_cdcooper
                     AND crapfol.cdempres = rw_crapemp.cdempres
                     AND crapfol.nrdconta = vr_nrdconta
                     AND crapfol.dtrefere = pr_rw_crapdat.dtultdia;

                WHEN OTHERS THEN
                  CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                  vr_blnerror := TRUE;
                  vr_dscritic := SQLERRM;
              END;

              -- Se ocorreu erro na inclusao/atualizacao da FOL ou atualizacao da ASS
              IF vr_blnerror THEN
                -- Envia o erro para o LOG porem continua o processo
                CECRED.pc_log_programa(pr_dstiplog => 'O'
                                     , pr_cdprograma => 'FOLH0001' 
                                     , pr_cdcooper => pr_cdcooper
                                     , pr_tpexecucao => 0
                                     , pr_tpocorrencia => 2 
                                     , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_cr_pagto_aprovados_coop. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(vr_nrdconta)) || ' – NO VALOR DE R$ ' || TO_CHAR(vr_vlsalliq,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') || ' - ' || vr_dscritic
                                     , pr_idprglog => vr_idprglog);

              END IF;

              -- Inicializa as variaveis
              vr_tot_debemp := 0;
              vr_tot_debcot := 0;

              -- Listagem dos pagamentos pendentes
              FOR rw_crapavs IN cr_crapavs(pr_cdcooper => pr_cdcooper,
                                           pr_nrdconta => rw_craplfp.nrdconta,
                                           pr_dtrefere => rw_craplfp.dtmacred) LOOP

                -- Somente se possuir salario liquido
                IF vr_vlsalliq > 0 THEN
                  vr_blnerror := FALSE;

                  -- Aviso de Emprestimo
                  IF rw_crapavs.cdhistor = 108 THEN

                    -- Chama a rotina PC_CRPS120_1
                    pc_crps120_1(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => 'FOLH0001'
                                ,pr_cdoperad => '1'
                                ,pr_crapdat  => pr_rw_crapdat
                                ,pr_nrdconta => rw_craplfp.nrdconta
                                ,pr_nrctremp => rw_crapavs.nrdocmto --> Nr do emprestimo
                                ,pr_nrdolote => rw_craplot_emp.nrdolote
                                ,pr_inusatab => vr_inusatab         --> Indicador se utilizar a tabela de juros
                                ,pr_vldaviso => rw_crapavs.vllanmto - rw_crapavs.vldebito --> Valor de aviso
                                ,pr_vlsalliq => vr_vlsalliq         --> Valor de saldo liquido
                                ,pr_dtintegr => pr_rw_crapdat.dtmvtolt --> Data de integracao
                                ,pr_cdhistor => 95                  --> Cod do historico
                                -- OUT
                                ,pr_insitavs => rw_crapavs.insitavs --> Retorna situacao do aviso
                                ,pr_vldebito => vr_vldebtot         --> Retorna do valor de debito
                                ,pr_vlestdif => rw_crapavs.vlestdif --> Ret vlr estouro ou diferenca
                                ,pr_flgproce => rw_crapavs.flgproce --> Ret indicativo de processamento
                                ,pr_cdcritic => vr_cdcritic         --> Critica encontrada
                                ,pr_dscritic => vr_dscritic);       --> Texto de erro/critica encontrada

                    -- Se retornar critica
                    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                      vr_blnerror := TRUE;
                    ELSE
                      -- Acumular o valor lancado para unificar a criacao da CRAPLCM
                      vr_tot_debemp := NVL(vr_tot_debemp,0) + NVL(vr_vldebtot,0);
                      -- Decrementar do valor liquido a prestacao paga
                      vr_vlsalliq := NVL(vr_vlsalliq,0) - NVL(vr_vldebtot,0);
                    END IF;

                    BEGIN
                      -- Atualiza Aviso
                      UPDATE crapavs
                         SET crapavs.insitavs = rw_crapavs.insitavs,
                             crapavs.vlestdif = rw_crapavs.vlestdif,
                             crapavs.flgproce = rw_crapavs.flgproce,
                             crapavs.vldebito = rw_crapavs.vldebito + NVL(vr_vldebtot,0)
                       WHERE ROWID = rw_crapavs.rowid;
                    EXCEPTION
                      WHEN OTHERS THEN
                        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                        vr_blnerror := TRUE;
                        vr_dscritic := SQLERRM;
                    END;

                    -- Se ocorreu erro na PC_CRPS120_1 ou atualizacao da AVS
                    IF vr_blnerror THEN
                      -- Envia o erro para o LOG porem continua o processo
                      CECRED.pc_log_programa(pr_dstiplog => 'O'
                                           , pr_cdprograma => 'FOLH0001' 
                                           , pr_cdcooper => pr_cdcooper
                                           , pr_tpexecucao => 0
                                           , pr_tpocorrencia => 2 
                                           , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_cr_pagto_aprovados_coop. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(vr_nrdconta)) || ' – AVISO NO VALOR DE R$ ' || TO_CHAR(vr_vldebtot,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,. ')  || vr_cdcritic || ' - ' || vr_dscritic
                                           , pr_idprglog => vr_idprglog);
                      
                    END IF;

                  -- Aviso de Plano de Cotas
                  ELSIF rw_crapavs.cdhistor = 127 THEN

                    -- Chama a rotina PC_CRPS120_2
                    pc_crps120_2(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => 'FOLH0001'
                                ,pr_crapdat  => pr_rw_crapdat
                                ,pr_nrdconta => rw_craplfp.nrdconta
                                ,pr_nrdolote => rw_craplot_cot.nrdolote
                                ,pr_vldaviso => rw_crapavs.vllanmto --> Valor do aviso
                                ,pr_vlsalliq => vr_vlsalliq         --> Valor do saldo liquido
                                ,pr_dtintegr => pr_rw_crapdat.dtmvtolt --> Data de integracao
                                ,pr_cdhistor => 75                  --> Cod do historico
                                -- OUT
                                ,pr_insitavs => rw_crapavs.insitavs --> Retorna indicador do aviso
                                ,pr_vldebito => rw_crapavs.vldebito --> Retorno do valor debito
                                ,pr_vlestdif => rw_crapavs.vlestdif --> retorna valor de estorno/diferença
                                ,pr_vldoipmf => vr_vldoipmf         --> Valor do CPMF (Não mais utilizado)
                                ,pr_flgproce => rw_crapavs.flgproce --> retorno indicativo de processamento
                                ,pr_cdcritic => vr_cdcritic         --> Critica encontrada
                                ,pr_dscritic => vr_dscritic);       --> Texto de erro/critica encontrada

                    -- Se retornar critica
                    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                      vr_blnerror := TRUE;
                    ELSE
                      -- Acumular o valor lancado para unificar a criacao da CRAPLCM
                      vr_tot_debcot := NVL(vr_tot_debcot,0) + NVL(rw_crapavs.vldebito,0);
                      -- Decrementar do valor liquido a prestacao paga
                      vr_vlsalliq := NVL(vr_vlsalliq,0) - NVL(rw_crapavs.vldebito,0);
                    END IF;

                    BEGIN
                      -- Atualiza Aviso
                      UPDATE crapavs
                         SET crapavs.insitavs = rw_crapavs.insitavs,
                             crapavs.vlestdif = rw_crapavs.vlestdif,
                             crapavs.flgproce = rw_crapavs.flgproce,
                             crapavs.vldebito = NVL(rw_crapavs.vldebito,0)
                       WHERE ROWID = rw_crapavs.rowid;
                    EXCEPTION
                      WHEN OTHERS THEN
                        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                        vr_blnerror := TRUE;
                        vr_dscritic := SQLERRM;
                    END;

                    -- Se ocorreu erro na PC_CRPS120_2 ou atualizacao da AVS
                    IF vr_blnerror THEN
                      -- Envia o erro para o LOG porem continua o processo
                      CECRED.pc_log_programa(pr_dstiplog => 'O'
                                           , pr_cdprograma => 'FOLH0001' 
                                           , pr_cdcooper => pr_cdcooper
                                           , pr_tpexecucao => 0
                                           , pr_tpocorrencia => 2 
                                           , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_cr_pagto_aprovados_coop. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(vr_nrdconta)) || ' – AVISO NO VALOR DE R$ ' || TO_CHAR(rw_crapavs.vldebito,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,. ')  || ' - ' || vr_dscritic
                                           , pr_idprglog => vr_idprglog);
                      
                    END IF;

                  END IF; -- Avisos EMP/COT

                  -- Se nao houve debito
                  IF rw_crapavs.vldebito = 0 AND rw_crapavs.insitavs = 0 THEN
                    -- Atualizar valor de estouro/diferenca aviso de debito
                    BEGIN
                     UPDATE crapavs
                        SET crapavs.vlestdif = crapavs.vllanmto * -1
                      WHERE ROWID = rw_crapavs.rowid;
                    END;
                  END IF;

                ELSE
                  EXIT; -- Sai do loop cr_crapavs
                END IF; -- vr_vlsalliq > 0

              END LOOP; -- cr_crapavs

              -- Se houve lancamento de AVS
              IF vr_tot_debcot > 0 OR vr_tot_debemp > 0 THEN

                FOR vr_index IN 1..2 LOOP

                  -- Seta as variaveis
                  CASE vr_index
                    WHEN 1 THEN -- Cotas
                      vr_cdhistor := 127;
                      vr_tot_lanc := vr_tot_debcot;
                      rw_craplot  := rw_craplot_cot;
                    WHEN 2 THEN -- Emprestimos
                      vr_cdhistor := 108;
                      vr_tot_lanc := vr_tot_debemp;
                      rw_craplot  := rw_craplot_emp;
                  END CASE;

                  -- Executa somente se existir valor
                  IF vr_tot_lanc > 0 THEN

                    BEGIN
                      -- Atualiza a CRAPLOT
                      UPDATE craplot
                         SET qtinfoln = qtinfoln + 1
                            ,vlinfodb = vlinfodb + vr_tot_lanc
                            ,qtcompln = qtcompln + 1
                            ,vlcompdb = vlcompdb + vr_tot_lanc
                            ,nrseqdig = nrseqdig + 1
                       WHERE ROWID = rw_craplot.rowid
                       RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;

                      -- Inserir lancamento
                      LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt =>pr_rw_crapdat.dtmvtolt
                                                         ,pr_cdagenci => 1
                                                         ,pr_cdbccxlt => 100
                                                         ,pr_nrdolote => rw_craplot.nrdolote
                                                         ,pr_nrdconta => vr_nrdconta
                                                         ,pr_nrdctabb => vr_nrdconta
                                                         ,pr_nrdctitg =>GENE0002.fn_mask(vr_nrdconta,'99999999') -- nrdctitg
                                                         ,pr_nrdocmto => rw_craplot.nrseqdig
                                                         ,pr_cdhistor => vr_cdhistor
                                                         ,pr_vllanmto => vr_tot_lanc
                                                         ,pr_nrseqdig => rw_craplot.nrseqdig
                                                         ,pr_cdcooper => pr_cdcooper

                                                        -- OUTPUT --
                                                         ,pr_tab_retorno => vr_tab_retorno
                                                         ,pr_incrineg => vr_incrineg
                                                         ,pr_cdcritic => vr_cdcritic
                                                         ,pr_dscritic => vr_dscritic);

                     IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                         RAISE vr_exc_erro;
                     END IF;

                    EXCEPTION
                      WHEN OTHERS THEN
                        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                        -- Envia o erro para o LOG
                        CECRED.pc_log_programa(pr_dstiplog => 'O'
                                             , pr_cdprograma => 'FOLH0001' 
                                             , pr_cdcooper => pr_cdcooper
                                             , pr_tpexecucao => 0
                                             , pr_tpocorrencia => 2 
                                             , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_cr_pagto_aprovados_coop. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(vr_nrdconta)) || ' –  DEBITO ' || vr_cdhistor || ' NO VALOR DE R$ ' || TO_CHAR(vr_tot_lanc,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') || ' NÃO EFETUADO: ' || SQLERRM
                                             , pr_idprglog => vr_idprglog);
                        
                    END;

                  END IF; -- tot_lanc > 0

                END LOOP; -- Fim do loop 1..2

              END IF; -- tot_debcot OR tot_debemp > 0

            END IF; -- numdebfol = qtdebfol

            COMMIT; -- Salva a FOL, ASS, AVS e o Debito

          END IF; -- fldebfol = 1

          -- Carrega os dados na PLTABLE
          vr_tab_crappfp(rw_craplfp.pfp_rowid) := rw_craplfp.qtlctpag;

          -- Caso seja do tipo Convencional
          IF rw_craplfp.idtppagt = 'C' THEN
            --Se a empresa escolheu gravar o salario
            IF rw_craplfp.flgrvsal = 1 THEN
              --Atualizaremos o salário com este lançamento
              vr_tab_craplfp(rw_craplfp.nrdconta).vllancto := rw_craplfp.vllancto;
            ELSE
             --Iremos apagar o histórico de salário
             vr_tab_craplfp(rw_craplfp.nrdconta).vllancto := 0;
            END IF;
          END IF;

          -- Caso seja ultimo registro da empresa
          IF rw_craplfp.numempre = rw_craplfp.qtempres THEN

            -- Caso seja debito em folha
            IF rw_craplfp.fldebfol = 1 THEN

              vr_dtexecde := pr_rw_crapdat.dtmvtopr;

              -- Se o dia da dtmvtopr for anterior ao dia limite para debitos
              IF TO_CHAR(vr_dtexecde,'DD') <= rw_crapemp.dtlimdeb THEN
                vr_dtexecde := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                          ,pr_dtmvtolt => TO_DATE(TO_CHAR(rw_crapemp.dtlimdeb,'fm00') || '/' || 
                                                                                  TO_CHAR(pr_rw_crapdat.dtmvtopr,'MM/RRRR'), 
                                                                                  'DD/MM/RRRR'));
              END IF;

              BEGIN
                -- Inserir registro de controle na craptab
                INSERT INTO craptab
                           (nmsistem
                           ,tptabela
                           ,cdempres
                           ,cdacesso
                           ,tpregist
                           ,cdcooper
                           ,dstextab)
                     VALUES('CRED'              -- nmsistem
                           ,'USUARI'            -- tptabela
                           ,rw_crapemp.cdempres -- cdempres
                           ,'EXECDEBEMP'        -- cdacesso
                           ,0                   -- tpregist
                           ,pr_cdcooper         -- cdcooper
                           ,TO_CHAR(rw_craplfp.dtmacred,'DD/MM/RRRR') || ' ' ||
                            TO_CHAR(vr_dtexecde,'DD/MM/RRRR') || ' 0' ); -- dstextab
              EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                  -- Se ja existe deve alterar
                  BEGIN
                    UPDATE craptab
                       SET craptab.dstextab = TO_CHAR(rw_craplfp.dtmacred,'DD/MM/RRRR') || ' ' ||
                                              TO_CHAR(vr_dtexecde,'DD/MM/RRRR') || ' 0'
                     WHERE craptab.cdcooper        = pr_cdcooper
                       AND UPPER(craptab.nmsistem) = 'CRED'
                       AND UPPER(craptab.tptabela) = 'USUARI'
                       AND craptab.cdempres        = rw_crapemp.cdempres
                       AND UPPER(craptab.cdacesso) = 'EXECDEBEMP'
                       AND craptab.tpregist        = 0;
                  END;
              END;

              -- Busca os avisos de debito que tenham ficado pendentes para gerar a CRAPFOL zerada
              FOR rw_avs_fol IN cr_avs_fol(pr_cdcooper => pr_cdcooper,
                                           pr_cdempres => rw_crapemp.cdempres,
                                           pr_dtrefere => rw_craplfp.dtmacred) LOOP
                BEGIN
                  INSERT INTO crapfol
                             (cdcooper
                             ,cdempres
                             ,dtrefere
                             ,nrdconta)
                       VALUES(pr_cdcooper
                             ,rw_crapemp.cdempres
                             ,rw_craplfp.dtmacred
                             ,rw_avs_fol.nrdconta); --> Conta encontrada na AVS
                END;
              END LOOP; -- cr_avs_fol

            END IF; -- fldebfol = 1

            -- Inicializa as avariaveis
            vr_vlsddisp := 0;
            vr_tottarif := 0;
            vr_flsittar := 1;
            vr_dsobstar := NULL;
            
            -- Percorre a lista de pagamentos
            vr_chave := vr_tab_crappfp.FIRST;
            WHILE vr_chave IS NOT NULL LOOP
              BEGIN
                
                vr_idtipcon := NULL;
                
                OPEN cr_verifica_ctasal(vr_chave);
                  FETCH cr_verifica_ctasal
                   INTO vr_idtipcon;
                CLOSE cr_verifica_ctasal;  
              
                IF vr_idtipcon IS NULL THEN                
                  UPDATE crappfp
                     SET -- Atualiza os pagamentos que foram processados
                         dthorcre = SYSDATE,
                         flsitcre = 1, --> Creditado
                         dsobscre = NULL
                   WHERE ROWID = vr_chave;
                ELSE
                  UPDATE crappfp
                     SET -- Atualiza os pagamentos que foram processados
                         dthorcre = SYSDATE,
                         flsitcre = 2, --> Cred. Parcial
                         dsobscre = NULL
                   WHERE ROWID = vr_chave;
                END IF;
              END;
              vr_chave := vr_tab_crappfp.NEXT(vr_chave);
            END LOOP;

            BEGIN
              -- Atualizar a data da ultima utilizacao do produto
              UPDATE crapemp
                 SET crapemp.dtultufp = SYSDATE
               WHERE crapemp.cdcooper = pr_cdcooper
                 AND crapemp.cdempres = rw_crapemp.cdempres;
            END;

            -- Percorre a lista de lancamentos
            vr_chave := vr_tab_craplfp.FIRST;
            WHILE vr_chave IS NOT NULL LOOP
              BEGIN
                -- Atualizar com o ultimo valor liquido pago
                UPDATE crapefp
                   SET vlultsal = vr_tab_craplfp(vr_chave).vllancto
                 WHERE cdcooper = pr_cdcooper
                   AND cdempres = rw_crapemp.cdempres
                   AND nrdconta = vr_chave;
              END;
              vr_chave := vr_tab_craplfp.NEXT(vr_chave);
            END LOOP;

            BEGIN
              -- Atualizar a CRAPTAB
              UPDATE craptab
                 SET craptab.dstextab        = SUBSTR(craptab.dstextab, 1, 13) || '1'
               WHERE craptab.cdcooper        = pr_cdcooper
                 AND UPPER(craptab.nmsistem) = 'CRED'
                 AND UPPER(craptab.tptabela) = 'GENERI'
                 AND craptab.cdempres        = 0
                 AND UPPER(craptab.cdacesso) = 'DIADOPAGTO'
                 AND craptab.tpregist        = rw_crapemp.cdempres;
            END;

            -- Lotes de Folha/Emprestimo/Cotas
            FOR vr_index IN 1..3 LOOP

              -- Carrega os lotes
              CASE vr_index
                WHEN 1 THEN vr_lote_nro := rw_craplot_fol.nrdolote;
                WHEN 2 THEN vr_lote_nro := rw_craplot_emp.nrdolote;
                WHEN 3 THEN vr_lote_nro := rw_craplot_cot.nrdolote;
              END CASE;

              -- Busca o lote FOL/EMP/COT
              OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                              pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                              pr_nrdolote => vr_lote_nro);
              FETCH cr_craplot INTO rw_craplot;
              CLOSE cr_craplot;

              -- Caso os valores de credito/debito estejam zerados
              IF rw_craplot.vlinfodb = 0 AND
                 rw_craplot.vlcompdb = 0 AND
                 rw_craplot.vlinfocr = 0 AND
                 rw_craplot.vlcompcr = 0 THEN
                BEGIN
                  -- Remove o lote zerado
                  DELETE FROM craplot WHERE ROWID = rw_craplot.rowid;
                END;
              END IF;

            END LOOP; -- Fim do loop 1..3 dos lotes

            -- Efetua Commit
            COMMIT;

          END IF; -- numempre = qtempres

        END LOOP; -- cr_craplfp

        -- Após processar todos os pagamentos da empresa, iremos atualizar
        -- aqueles pagamentos em que só restaram lançamentos de erro, e devido
        -- a isso o mesmo não é processado e ficaria pendente

        BEGIN
          UPDATE crappfp pfp
             SET pfp.dthorcre = SYSDATE
                ,pfp.flsitcre = 1 --> Creditado
           WHERE pfp.cdcooper = pr_cdcooper
             AND pfp.cdempres = rw_crapemp.cdempres
             AND pfp.flsitdeb = 1 -- Já debitado
             AND pfp.flsitcre = 0 -- Com crédito pendente
             -- Não exista nenhum lançamento pendente
             AND NOT EXISTS(SELECT 1
                              FROM craplfp lfp
                             WHERE pfp.cdcooper = lfp.cdcooper
                               AND pfp.cdempres = lfp.cdempres
                               AND pfp.nrseqpag = lfp.nrseqpag
                               AND lfp.idsitlct = 'L'
                               AND lfp.vllancto > 0);
        END;

        -- Atualizar todos os lançamentos sem crédito pois eles estão pendentes devido ao vllancto = 0
        BEGIN
          UPDATE craplfp lfp
             SET lfp.idsitlct = 'C'
                ,lfp.dsobslct = 'Lançamento sem crédito - apenas para emissão do comprovante'
           WHERE lfp.cdcooper = pr_cdcooper
             AND lfp.cdempres = rw_crapemp.cdempres
             AND lfp.idsitlct = 'L' -- Ainda pendentes
             AND lfp.vllancto = 0 -- Somente aqueles sem crédito
             -- E o pagamento tenha sido creditado
             AND EXISTS (SELECT 1
                           FROM crappfp pfp
                          WHERE pfp.cdcooper = lfp.cdcooper
                            AND pfp.cdempres = lfp.cdempres
                            AND pfp.nrseqpag = lfp.nrseqpag
                            AND pfp.flsitcre = 1);
        END;

        -- Adicionamos no LOG o encerramento do processo de credito desta empresa
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                             , pr_cdprograma => 'FOLH0001' 
                             , pr_cdcooper => pr_cdcooper
                             , pr_tpexecucao => 0
                             , pr_tpocorrencia => 1 
                             , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Rotina pc_cr_pagto_aprovados_coop. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' – ENCERRAMENTO DO PROCESSO DE CREDITO'
                             , pr_idprglog => vr_idprglog);
        
        -- Gravação final
        COMMIT;
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Desfazemos alterações até o momento adicionamos ao
          -- log da empresa o erro tratado
          ROLLBACK;
          CECRED.pc_log_programa(pr_dstiplog => 'O'
                               , pr_cdprograma => 'FOLH0001' 
                               , pr_cdcooper => pr_cdcooper
                               , pr_tpexecucao => 0
                               , pr_tpocorrencia => 1 
                               , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_cr_pagto_aprovados_coop. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' ' || vr_dscritic
                               , pr_idprglog => vr_idprglog);
          
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- Desfazemos alterações até o momento adicionamos ao
          -- log da empresa o erro não tratado
          ROLLBACK;
          CECRED.pc_log_programa(pr_dstiplog => 'O'
                               , pr_cdprograma => 'FOLH0001' 
                               , pr_cdcooper => pr_cdcooper
                               , pr_tpexecucao => 0
                               , pr_tpocorrencia => 1 
                               , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_cr_pagto_aprovados_coop. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' ' || SQLERRM
                               , pr_idprglog => vr_idprglog);

      END;
    END LOOP; -- cr_crapemp

    -- Busca o lote TEC (Global para a Cooperativa)
    OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                    pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                    pr_nrdolote => rw_craplot_tec.nrdolote);
    FETCH cr_craplot INTO rw_craplot_tec;
    CLOSE cr_craplot;

    -- Caso os valores de credito/debito estejam zerados
    IF rw_craplot_tec.vlinfodb = 0 AND
       rw_craplot_tec.vlcompdb = 0 AND
       rw_craplot_tec.vlinfocr = 0 AND
       rw_craplot_tec.vlcompcr = 0 THEN
      BEGIN
        -- Remove o lote zerado
        DELETE FROM craplot WHERE ROWID = rw_craplot_tec.rowid;
      END;
    END IF;

    -- Efetua Commit
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer a operacao
      ROLLBACK;
      -- efetuar o raise
      raise_application_error(-25001, 'Erro FOLH0001.PC_CREDITO_PAGTO_APROVADOS: '||vr_dscritic);
    WHEN OTHERS THEN
      -- Desfazer a operacao
      ROLLBACK;
      
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      
      -- efetuar o raise
      raise_application_error(-25000, 'Erro FOLH0001.PC_CREDITO_PAGTO_APROVADOS: '||vr_dscritic);
  END pc_cr_pagto_aprovados_coop;
  
  /* Procedure para realizar processamento de credito dos pagamentos aprovados */
  PROCEDURE pc_cr_pagto_aprovados_ctasal(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                        ,pr_rw_crapdat IN BTCH0001.cr_crapdat%ROWTYPE) IS
  ---------------------------------------------------------------------------------------------------------------
  ---------------------------ROTINA CRIADA A PARTIR DA PROCEDURE pc_cr_pagto_aprovados----------------------------
  --  Programa : pc_credito_pagto_aprovados_ctasal             Antigo:
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Kelvin
  --  Data     : Janeiro/2017.                   Ultima atualizacao:27/02/2018 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para realizar processamento de credito dos pagamentos aprovados de portabilidade
  -- Alterações
  --             12/11/2015 - Migracao da tarifação do sistema da CONFOL para CADTAR,
  --                          com isso removi a cobrança da tarifa deste ponto, deixando
  --                          apenas na pc_cobra_tarifas_pendentes (Marcos-Supero)
  --
  --             07/12/2015 - Ajustado para validar se o pagamento caso seja do tipo convencional,
  --                          verificar se a empresa resolveu gravar o salario ou nao.
  --                          (Andre Santos - SUPERO)
  --
  --             25/01/2016 - Ajuste nas mensagens de erro (Marcos-Supero)
  --
  --             27/01/2016 - Incluir controle de lançamentos sem crédito (Marcos-Supero)
  --             
  --             01/03/2016 - Ajustes para evitar dup_val_on_index em pagamentos ctasal
  --                          para a mesma conta no mesmo dia (Marcos-Supero)
  -- 
  -- 
  --             22/04/2016 - Inclusao de NVL para evitar que o LCM seja criado sem conta 
  --                          (Marcos - Supero)
  --
  --             23/05/2016 - Ajuste para gravar tab EXECDEBEMP com crapemp.dtlimdeb caso
  --                          dia da dtmvtopr for anterior ao dia limite para debitos. 
  --                          (Jaison/Marcos - Supero)
  --
  --             27/02/2018 - Ajuste para que a central receba e-mail caso aconteca
  --                          problemas nos pagamentos para outras instituincoes financeiras
  --                          e tambem alterado o conteudo, conforme solicitado no chamado
  --                          845975. (Kelvin)
  ---------------------------------------------------------------------------------------------------------------

    -- Busca os dados do lote
    CURSOR cr_craplot(pr_cdcooper craplot.cdcooper%TYPE,
                      pr_dtmvtolt craplot.dtmvtolt%TYPE,
                      pr_nrdolote craplot.nrdolote%TYPE) IS
        SELECT nrdolote
              ,nrseqdig
              ,qtinfoln
              ,qtcompln
              ,vlinfodb
              ,vlcompdb
              ,vlinfocr
              ,vlcompcr
              ,ROWID
          FROM craplot
         WHERE craplot.cdcooper = pr_cdcooper
           AND craplot.dtmvtolt = pr_dtmvtolt
           AND craplot.cdagenci = 1
           AND craplot.cdbccxlt = 100
           AND craplot.nrdolote = pr_nrdolote;
    rw_craplot     cr_craplot%ROWTYPE;
    rw_craplot_tec cr_craplot%ROWTYPE;
    rw_craplot_fol cr_craplot%ROWTYPE;
    rw_craplot_emp cr_craplot%ROWTYPE;
    rw_craplot_cot cr_craplot%ROWTYPE;

    -- Busca as empresas com pagamentos pendentes
    CURSOR cr_crapemp(pr_cdcooper crapemp.cdcooper%TYPE,
                      pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
        SELECT emp.cdempres
              ,emp.nmresemp
              ,emp.idtpempr
              ,emp.nrdconta
              ,emp.dtlimdeb
              ,ass.vllimcre
              ,SUM(lfp.vllancto) vllancto
          FROM crappfp pfp
              ,crapemp emp
              ,craplfp lfp
              ,crapass ass
         WHERE pfp.cdcooper  = pr_cdcooper
           AND pfp.dtcredit <= pr_dtmvtolt
           AND pfp.cdcooper  = emp.cdcooper
           AND pfp.cdempres  = emp.cdempres
           AND pfp.cdcooper  = lfp.cdcooper
           AND pfp.cdempres  = lfp.cdempres
           AND pfp.nrseqpag  = lfp.nrseqpag
           AND ass.cdcooper  = emp.cdcooper
           AND ass.nrdconta  = emp.nrdconta
           AND pfp.idsitapr  > 3 --> Aprovados
           AND pfp.idsitapr  <> 6 --> Transação Pendente
           AND pfp.flsitdeb  = 1 --> Ja debitados
           AND pfp.flsitcre  IN (0,2) --> Ainda nao creditados           
           AND lfp.idtpcont  = 'T'
         GROUP BY emp.cdempres
                 ,emp.nmresemp
                 ,emp.idtpempr
                 ,emp.nrdconta
                 ,emp.dtlimdeb
                 ,ass.vllimcre;

    -- Busca o numero do Lote
    CURSOR cr_craptab_lot(pr_cdcooper craptab.cdcooper%TYPE,
                          pr_cdacesso craptab.cdacesso%TYPE,
                          pr_tpregist craptab.tpregist%TYPE) IS
         SELECT TO_NUMBER(dstextab)
           FROM craptab
          WHERE craptab.cdcooper        = pr_cdcooper
            AND UPPER(craptab.nmsistem) = 'CRED'
            AND UPPER(craptab.tptabela) = 'GENERI'
            AND craptab.cdempres        = 0
            AND UPPER(craptab.cdacesso) = pr_cdacesso
            AND craptab.tpregist        = pr_tpregist;

    -- Busca os pagamentos pendentes
    CURSOR cr_craplfp(pr_cdcooper crappfp.cdcooper%TYPE,
                      pr_dtmvtolt crapdat.dtmvtolt%TYPE,
                      pr_cdempres crappfp.cdempres%TYPE,
                      pr_idtpempr crapemp.idtpempr%TYPE) IS
        SELECT pfp.nrseqpag
              ,pfp.idtppagt
              ,pfp.flgrvsal
              ,pfp.qtlctpag
              ,pfp.ROWID pfp_rowid
              ,LAST_DAY(ADD_MONTHS(pfp.dtcredit, -1)) dtmacred -- Ultimo dia do mes anterior ao credito
              ,DECODE(pr_idtpempr,'C',ofp.cdhscrcp,ofp.cdhiscre) cdhiscre
              ,ofp.fldebfol
              ,lfp.nrseqlfp
              ,lfp.idtpcont
              ,lfp.nrdconta
              ,lfp.nrcpfemp
              ,lfp.vllancto
              ,lfp.ROWID
              ,lfp.progress_recid

              ,ROW_NUMBER() OVER (PARTITION BY lfp.cdempres ORDER BY lfp.cdempres) AS numempre
              ,COUNT(1) OVER (PARTITION BY lfp.cdempres) qtempres

              ,ROW_NUMBER() OVER (PARTITION BY lfp.cdempres,ofp.fldebfol,lfp.nrdconta ORDER BY lfp.cdempres,ofp.fldebfol,lfp.nrdconta,DECODE(pr_idtpempr,'C',ofp.cdhscrcp,ofp.cdhiscre)) AS numdebfol
              ,COUNT(1) OVER (PARTITION BY lfp.cdempres,ofp.fldebfol,lfp.nrdconta) qtdebfol

          FROM crappfp pfp
              ,craplfp lfp
              ,crapofp ofp
         WHERE pfp.cdcooper  = pr_cdcooper
           AND pfp.dtcredit <= pr_dtmvtolt
           AND pfp.cdempres  = pr_cdempres
           AND pfp.cdcooper  = lfp.cdcooper
           AND pfp.cdempres  = lfp.cdempres
           AND pfp.nrseqpag  = lfp.nrseqpag
           AND lfp.cdcooper  = ofp.cdcooper
           AND lfp.cdorigem  = ofp.cdorigem
           AND pfp.flsitdeb  = 1   --> Ja debitados
           AND pfp.flsitcre  IN (0,2)   --> Ainda nao creditados
           AND lfp.idsitlct NOT IN('E','C') --> Desconsiderar os com erros ou creditados
           AND nvl(lfp.dsobslct,' ') <> 'Transf. solicitada, aguardar transmissão' -- Desconsiderar tbm CTASAL solicitado, pois sua situação persiste em L e somente a Obs pode ser eusada
           AND lfp.vllancto  > 0
           AND lfp.idtpcont  = 'T'
      ORDER BY lfp.cdempres
              ,ofp.fldebfol
              ,lfp.nrdconta
              ,DECODE(pr_idtpempr,'C',ofp.cdhscrcp,ofp.cdhiscre);

    -- Busca a conta do cooperado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT CASE
                 WHEN ass.cdsitdtl IN (2,4,6,8) THEN nvl(trf.nrsconta,ass.nrdconta)
                 ELSE ass.nrdconta
               END
          FROM crapass ass
              ,craptrf trf
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta
           AND trf.cdcooper(+) = ass.cdcooper
           AND trf.nrdconta(+) = ass.nrdconta
           AND trf.tptransa(+) = 1
           AND trf.insittrs(+) = 2;

    -- Busca os avisos de debitos de emprestimo/cotas com debito em folha
    CURSOR cr_crapavs(pr_cdcooper crapavs.cdcooper%TYPE,
                      pr_nrdconta crapavs.nrdconta%TYPE,
                      pr_dtrefere crapavs.dtrefere%TYPE) IS
        SELECT crapavs.*
              ,crapavs.rowid
          FROM crapavs
         WHERE crapavs.cdcooper = pr_cdcooper
           AND crapavs.nrdconta = pr_nrdconta
           AND crapavs.tpdaviso = 1
           AND crapavs.cdhistor IN (108,127)
           AND crapavs.dtrefere = pr_dtrefere
           AND crapavs.insitavs = 0
      ORDER BY crapavs.cdhistor;

    -- Busca os pagamentos da empresa creditados e com lancamentos pendentes de envio ao SPB
    CURSOR cr_lancspb(pr_cdcooper crappfp.cdcooper%TYPE,
                      pr_cdempres crappfp.cdempres%TYPE) IS
        SELECT 1
          FROM craplcs lcs
              ,craplfp lfp
              ,crappfp pfp
         WHERE pfp.cdcooper = pr_cdcooper
           AND pfp.cdempres = pr_cdempres
           AND pfp.cdcooper = lfp.cdcooper
           AND pfp.cdempres = lfp.cdempres
           AND pfp.nrseqpag = lfp.nrseqpag
           AND lcs.cdcooper = lfp.cdcooper
           AND lcs.nrdconta = lfp.nrdconta
           AND lcs.nrridlfp = lfp.progress_recid
           AND lfp.idsitlct = 'L' --> Ainda nao transmitido
           AND lcs.flgenvio = 0;  --> Nao enviado
    rw_lancspb cr_lancspb%ROWTYPE;

    -- Lancamentos dos funcionarios que transferem o salario para outra IF
    CURSOR cr_avs_fol(pr_cdcooper crapavs.cdcooper%TYPE,
                      pr_cdempres crapavs.cdempres%TYPE,
                      pr_dtrefere crapavs.dtrefere%TYPE) IS
        SELECT crapavs.nrdconta
          FROM crapavs
         WHERE crapavs.cdcooper = pr_cdcooper
           AND crapavs.cdempres = pr_cdempres
           AND crapavs.dtrefere = pr_dtrefere
           AND crapavs.tpdaviso = 1 --> Folha
           AND crapavs.insitavs = 0 --> Nao debitado
           AND crapavs.cdhistor IN (108,127)

           -- Ja garantimos que nao exista CRAPFOL para evitar DUP_VAL_ON_INDEX
           AND NOT EXISTS(SELECT 1
                            FROM crapfol
                           WHERE crapfol.cdcooper = crapavs.cdcooper
                             AND crapfol.cdempres = crapavs.cdempres
                             AND crapfol.dtrefere = crapavs.dtrefere
                             AND crapfol.nrdconta = crapavs.nrdconta)

      GROUP BY crapavs.nrdconta;

    -- Tabelas
    TYPE typ_tab_crappfp IS
      TABLE OF crappfp.qtlctpag%TYPE
      INDEX BY VARCHAR2(25);

    TYPE typ_reg_craplfp IS
      RECORD (vllancto craplfp.vllancto%TYPE);

    TYPE typ_tab_craplfp IS
      TABLE OF typ_reg_craplfp
      INDEX BY PLS_INTEGER;

    -- Variaveis da PLTABLE
    vr_tab_crappfp typ_tab_crappfp;
    vr_tab_craplfp typ_tab_craplfp;

    -- Variaveis
    vr_cdhistor   craplcm.cdhistor%TYPE;
    vr_nrdocmto   craplcs.nrdocmto%TYPE;
    vr_cdhistec   crapprm.dsvlrprm%TYPE;
    vr_lote_tec   crapprm.dsvlrprm%TYPE;
    vr_lote_nro   craplot.nrdolote%TYPE;
    vr_dstextab   craptab.dstextab%TYPE;
    vr_nmprimtl   crapass.nmprimtl%TYPE;
    vr_nrdconta   crapass.nrdconta%TYPE;
    vr_flsittar   crappfp.flsittar%TYPE;
    vr_dsobstar   crappfp.dsobstar%TYPE;
    vr_idsitlct   craplfp.idsitlct%TYPE;
    vr_dsobslct   craplfp.dsobslct%TYPE;
    vr_vlsalliq   craplfp.vllancto%TYPE;
    vr_vldebtot   craplfp.vllancto%TYPE;
    vr_tot_debcot craplfp.vllancto%TYPE;
    vr_tot_debemp craplfp.vllancto%TYPE;
    vr_tot_lanc   craplfp.vllancto%TYPE;
    vr_tottarif   craplfp.vllancto%TYPE;
    vr_vlsddisp   crapsda.vlsddisp%TYPE;
    vr_vldoipmf   NUMBER;
    vr_inusatab   BOOLEAN;
    vr_blnfound   BOOLEAN;
    vr_blnerror   BOOLEAN;
    vr_blctasal   BOOLEAN := FALSE;
    vr_lotechav   VARCHAR2(10);
    vr_emailds1   VARCHAR2(1000);
    vr_emailds2   VARCHAR2(1000);
    vr_dsmensag   VARCHAR2(4000);
    vr_chave      VARCHAR2(25);
    vr_dtexecde   DATE;

    -- Variaveis de Erro
    vr_cdcritic   crapcri.cdcritic%TYPE;
    vr_dscritic   VARCHAR2(4000);
    vr_dsalerta   VARCHAR2(4000);

    -- Variaveis Excecao
    vr_exc_erro   EXCEPTION;

  BEGIN

    -- Destinatarios responsaveis pelos avisos
    vr_emailds1 :=  GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_cdacesso => 'FOLHAIB_EMAIL_ALERT_PROC');

    -- Leitura do indicador de uso da tabela de taxa de juros
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'TAXATABELA'
                                             ,pr_tpregist => 0);
    IF vr_dstextab IS NULL THEN
      vr_inusatab := FALSE;
    ELSE
      IF SUBSTR(vr_dstextab,1,1) = '0' THEN
          vr_inusatab := FALSE;
      ELSE
        vr_inusatab := TRUE;
      END IF;
    END IF;

    -- Busca o numero de lote para gravacao
    vr_lote_tec := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_cdacesso => 'FOLHAIB_NRLOTE_CTASAL');

    -- Efetua a busca do lote TEC
    OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                    pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                    pr_nrdolote => vr_lote_tec);
    FETCH cr_craplot INTO rw_craplot_tec;
    -- Alimenta a booleana se achou ou nao
    vr_blnfound := cr_craplot%FOUND;
    -- Fecha cursor
    CLOSE cr_craplot;

    -- Se nao achou faz a criacao do lote TEC
    IF NOT vr_blnfound THEN
      BEGIN
        INSERT INTO craplot
                   (cdcooper
                   ,dtmvtolt
                   ,cdagenci
                   ,cdbccxlt
                   ,nrdolote
                   ,tplotmov)
             VALUES(pr_cdcooper
                   ,pr_rw_crapdat.dtmvtolt
                   ,1           -- cdagenci
                   ,100         -- cdbccxlt
                   ,vr_lote_tec
                   ,1)
          RETURNING craplot.rowid INTO rw_craplot_tec.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
        
          vr_dscritic := '060 - Lote inexistente.';

          -- Envia o erro para o LOG
          CECRED.pc_log_programa(pr_dstiplog => 'O'
                               , pr_cdprograma => 'FOLH0001' 
                               , pr_cdcooper => pr_cdcooper
                               , pr_tpexecucao => 0
                               , pr_tpocorrencia => 3 
                               , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_cr_pagto_aprovados_ctasal. Detalhes: ' || vr_dscritic
                               , pr_idprglog => vr_idprglog);          

          -- Mensagem informando o erro
          vr_dsmensag := 'Houve erro inesperado na inclusão do lote CTASAL. ' ||
                         'Abaixo trazemos o erro retornado durante a operação: <br> ' ||
                         vr_dscritic;

          -- Solicita envio do email
          GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => 'FOLH0001'
                                    ,pr_des_destino     => TRIM(vr_emailds1)
                                    ,pr_des_assunto     => 'Folha de Pagamento - Problema com o crédito – CTASAL'
                                    ,pr_des_corpo       => vr_dsmensag
                                    ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                    ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                    ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                    ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                    ,pr_des_erro        => vr_dscritic);
          RAISE vr_exc_erro;
      END;

      COMMIT; -- Salva o lote TEC
    END IF;

    -- Busca o historico de credito parametrizado para TECs salario
    vr_cdhistec := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_cdacesso => 'FOLHAIB_HIS_CRE_TECSAL');

    -- Percorre todas as empresas da cooperativa atual
    FOR rw_crapemp IN cr_crapemp(pr_cdcooper => pr_cdcooper,
                                 pr_dtmvtolt => pr_rw_crapdat.dtmvtolt) LOOP

      BEGIN
        -- Adicionamos no LOG o inicio do pagamento
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                             , pr_cdprograma => 'FOLH0001' 
                             , pr_cdcooper => pr_cdcooper
                             , pr_tpexecucao => 0
                             , pr_tpocorrencia => 1 
                             , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Rotina pc_cr_pagto_aprovados_ctasal. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' – INICIANDO CREDITO DOS EMPREGADOS – VALOR TOTAL PREVISTO DE R$ ' || TO_CHAR(rw_crapemp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.')
                             , pr_idprglog => vr_idprglog);        

        -- Inicializa as variaveis
        vr_blnerror    := FALSE;
        rw_craplot_fol := NULL;
        rw_craplot_emp := NULL;
        rw_craplot_cot := NULL;

        -- Lotes de Folha/Emprestimo/Cotas
        FOR vr_index IN 1..3 LOOP

          -- Chave de acesso
          CASE vr_index
            WHEN 1 THEN vr_lotechav := 'NUMLOTEFOL';
            WHEN 2 THEN vr_lotechav := 'NUMLOTEEMP';
            WHEN 3 THEN vr_lotechav := 'NUMLOTECOT';
          END CASE;

          -- Efetua a busca do codigo do lote FOL/EMP/COT
          OPEN cr_craptab_lot(pr_cdcooper => pr_cdcooper,
                              pr_cdacesso => vr_lotechav,
                              pr_tpregist => rw_crapemp.cdempres);
          FETCH cr_craptab_lot INTO vr_lote_nro;
          -- Alimenta a booleana se achou ou nao
          vr_blnfound := cr_craptab_lot%FOUND;
          -- Fecha cursor
          CLOSE cr_craptab_lot;

          -- Se nao achou
          IF NOT vr_blnfound THEN
            vr_blnerror := TRUE;
            EXIT; -- Sai do loop 1..3
          END IF;

          -- Busca o lote FOL/EMP/COT
          OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                          pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                          pr_nrdolote => vr_lote_nro);
          FETCH cr_craplot INTO rw_craplot;
          -- Alimenta a booleana se achou ou nao
          vr_blnfound := cr_craplot%FOUND;
          -- Fecha cursor
          CLOSE cr_craplot;

          -- Se nao achou faz a criacao do lote FOL/EMP/COT
          IF NOT vr_blnfound THEN
            BEGIN
              INSERT INTO craplot
                         (cdcooper
                         ,dtmvtolt
                         ,cdagenci
                         ,cdbccxlt
                         ,nrdolote
                         ,tplotmov)
                   VALUES(pr_cdcooper
                         ,pr_rw_crapdat.dtmvtolt
                         ,1           -- cdagenci
                         ,100         -- cdbccxlt
                         ,vr_lote_nro
                         ,1)
                RETURNING craplot.rowid INTO rw_craplot.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                vr_blnerror := TRUE;
                EXIT; -- Sai do loop 1..3
            END;

          END IF;

          -- Carrega os lotes e cursores
          CASE vr_index
            WHEN 1 THEN
              rw_craplot_fol := rw_craplot;
              rw_craplot_fol.nrdolote := vr_lote_nro;
            WHEN 2 THEN
              rw_craplot_emp := rw_craplot;
              rw_craplot_emp.nrdolote := vr_lote_nro;
            WHEN 3 THEN
              rw_craplot_cot := rw_craplot;
              rw_craplot_cot.nrdolote := vr_lote_nro;
          END CASE;

        END LOOP; -- Fim do loop 1..3 dos lotes

        -- Caso tenha ocorrido erro na inclusao do lote vai para a proxima empresa e desfaz as acoes
        IF vr_blnerror THEN

          -- Mensagem de Critica
          vr_dscritic := '060 - Lote inexistente.';

          -- Envia o erro para o LOG
          CECRED.pc_log_programa(pr_dstiplog => 'O'
                               , pr_cdprograma => 'FOLH0001' 
                               , pr_cdcooper => pr_cdcooper
                               , pr_tpexecucao => 0
                               , pr_tpocorrencia => 2 
                               , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_cr_pagto_aprovados_ctasal. Detalhes: ' || vr_dscritic
                               , pr_idprglog => vr_idprglog);
          
          -- Mensagem informando o erro
          vr_dsmensag := 'Houve erro inesperado na busca do numero do lote ('|| vr_lotechav ||') ' ||
                         'para a empresa ' || rw_crapemp.cdempres || ' - ' || rw_crapemp.nmresemp || '. ' ||
                         'Abaixo trazemos o erro retornado durante a operação: <br> ' || vr_dscritic;

          -- Solicita envio do email
          GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => 'FOLH0001'
                                    ,pr_des_destino     => TRIM(vr_emailds1)
                                    ,pr_des_assunto     => 'Folha de Pagamento - Problema com o crédito – Empresa ' || rw_crapemp.cdempres || ' - ' || rw_crapemp.nmresemp
                                    ,pr_des_corpo       => vr_dsmensag
                                    ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                    ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                    ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                    ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                    ,pr_des_erro        => vr_dscritic);
          ROLLBACK;
          CONTINUE; -- Move para a proxima empresa
        END IF;

        COMMIT; -- Salva os lotes FOL/EMP/COT

        -- Limpa as PLTABLES
        vr_tab_crappfp.DELETE;
        vr_tab_craplfp.DELETE;

        -- Listagem dos pagamentos pendentes
        FOR rw_craplfp IN cr_craplfp(pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                                     pr_cdempres => rw_crapemp.cdempres,
                                     pr_idtpempr => rw_crapemp.idtpempr) LOOP
          -- Verificar a situacao de cada conta, pois algum empregado pode ter encerrado sua conta
          -- ou efetuado alguma alteracao em seu cadastro que impeca o credito
          pc_valida_lancto_folha(pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => rw_craplfp.nrdconta,
                                 pr_nrcpfcgc => rw_craplfp.nrcpfemp,
                                 pr_dtcredit => null,                                 
                                 pr_idtpcont => rw_craplfp.idtpcont,
                                 pr_nmprimtl => vr_nmprimtl,
                                 pr_dsalerta => vr_dsalerta,
                                 pr_dscritic => vr_dscritic);
          -- Caso tenha retornado alguma critica
          IF vr_dsalerta IS NOT NULL OR
             vr_dscritic IS NOT NULL THEN
            BEGIN
              -- Atualiza com erro
              UPDATE craplfp
                 SET idsitlct = 'E'
                    ,dsobslct = NVL(vr_dsalerta,vr_dscritic)
               WHERE ROWID = rw_craplfp.rowid;
            END;

            CECRED.pc_log_programa(pr_dstiplog => 'O'
                                 , pr_cdprograma => 'FOLH0001' 
                                 , pr_cdcooper => pr_cdcooper
                                 , pr_tpexecucao => 0
                                 , pr_tpocorrencia => 2 
                                 , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_cr_pagto_aprovados_ctasal. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(rw_craplfp.nrdconta)) || ' NO VALOR DE R$ ' || TO_CHAR(rw_craplfp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') || ' NÃO SERA EFETUADO, MOTIVO: '||NVL(vr_dsalerta,vr_dscritic)
                                 , pr_idprglog => vr_idprglog);
            
            CONTINUE;
          END IF;

          -- Busca próximo número de documento não utilizado
          vr_nrdocmto := rw_craplfp.nrseqpag||to_char(rw_craplfp.nrseqlfp,'fm00000');
          vr_exis_lcs := 0;
          LOOP 
            -- Verifica se existe craplcs com memso numero de documento
            OPEN cr_craplcs_nrdoc (pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                                  ,pr_nrdconta => rw_craplfp.nrdconta
                                  ,pr_cdhisdev => vr_cdhistec
                                  ,pr_nrdocmto => vr_nrdocmto);
            FETCH cr_craplcs_nrdoc 
             INTO vr_exis_lcs;
            -- Sair quando não tiver encontrado
            EXIT WHEN cr_craplcs_nrdoc%NOTFOUND;
            -- Fechamos o CURSOR pois ele será reaberto no próximo LOOP
            CLOSE cr_craplcs_nrdoc;
            -- Se persite no loop é pq existe, então adicionamos o numero documento
            vr_nrdocmto := vr_nrdocmto + 1000000000;
          END LOOP;  
          -- Fechar cursor
          IF cr_craplcs_nrdoc%ISOPEN THEN
            CLOSE cr_craplcs_nrdoc;
          END IF;
            
          -- Inicializa a variavel
          vr_blnerror := FALSE;

          BEGIN
            -- Inserir lancamento
            INSERT INTO craplcs
                       (cdcooper
                       ,cdopecrd
                       ,dtmvtolt
                       ,nrdconta
                       ,nrdocmto
                       ,vllanmto
                       ,cdhistor
                       ,nrdolote
                       ,cdbccxlt
                       ,cdagenci
                       ,flgenvio
                       ,dttransf
                       ,hrtransf
                       ,nrridlfp)
                 VALUES(pr_cdcooper
                       ,1     -- super-usuario
                       ,pr_rw_crapdat.dtmvtolt
                       ,rw_craplfp.nrdconta
                       ,vr_nrdocmto
                       ,rw_craplfp.vllancto
                       ,vr_cdhistec
                       ,rw_craplot_tec.nrdolote
                       ,100   -- cdbccxlt
                       ,1     -- cdagenci
                       ,0     -- falso flgenvio
                       ,NULL  -- dttransf
                       ,0     -- hrtransf
                       ,rw_craplfp.progress_recid); -- Recid do pagamento para busca da empresa em possiveis estornos
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              vr_blnerror := TRUE;
              vr_dscritic := SQLERRM;
              -- Atualiza com sucesso ou erro
              UPDATE craplfp
                 SET idsitlct = 'E'
                    ,dsobslct = 'Problema encontrado -> '||vr_dscritic
               WHERE ROWID = rw_craplfp.rowid;
          END;

          -- Se ocorreu erro na inclusao da LCS ou atualizacao da LFP
          IF vr_blnerror THEN
            -- Envia o erro para o LOG porem continua o processo
            CECRED.pc_log_programa(pr_dstiplog => 'O'
                                 , pr_cdprograma => 'FOLH0001' 
                                 , pr_cdcooper => pr_cdcooper
                                 , pr_tpexecucao => 0
                                 , pr_tpocorrencia => 2 
                                 , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_cr_pagto_aprovados_ctasal. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(rw_craplfp.nrdconta)) || ' – TRANSFERENCIA ' || vr_cdhistec || ' NO VALOR DE R$ ' || TO_CHAR(rw_craplfp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') || ' NÃO EFETUADA: ' || vr_dscritic
                                 , pr_idprglog => vr_idprglog);
            
          ELSE
            -- Marca como possui CTASAL
            vr_blctasal := TRUE;

            BEGIN
              -- Atualiza a CRAPLOT_TEC (CTASAL)
              UPDATE craplot
                 SET qtinfoln = qtinfoln + 1
                    ,vlinfocr = vlinfocr + rw_craplfp.vllancto
                    ,qtcompln = qtcompln + 1
                    ,vlcompcr = vlcompcr + rw_craplfp.vllancto
                    ,nrseqdig = nrseqdig + 1
               WHERE ROWID = rw_craplot_tec.rowid;
            END;

            BEGIN
              -- Atualiza solicitação da trasferência
              UPDATE craplfp
                 SET dsobslct = 'Transf. solicitada, aguardar transmissão'
               WHERE ROWID = rw_craplfp.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                vr_blnerror := TRUE;
            END;

            -- Adicionamos no LOG o sucesso ocorrido na transferencia do pagamento
            CECRED.pc_log_programa(pr_dstiplog => 'O'
                                 , pr_cdprograma => 'FOLH0001' 
                                 , pr_cdcooper => pr_cdcooper
                                 , pr_tpexecucao => 0
                                 , pr_tpocorrencia => 1 
                                 , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Rotina pc_cr_pagto_aprovados_ctasal. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' – EMPREGADO ' || ltrim(gene0002.fn_mask_conta(rw_craplfp.nrdconta)) || ' – TRANSFERENCIA ' || vr_cdhistec || ' NO VALOR DE R$ ' || TO_CHAR(rw_craplfp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') || ' SOLICITADA COM SUCESSO – AGUARDAR TRANSMISSAO'
                                 , pr_idprglog => vr_idprglog);           

          END IF;

          -- Carrega os dados na PLTABLE
          vr_tab_crappfp(rw_craplfp.pfp_rowid) := rw_craplfp.qtlctpag;

          -- Caso seja do tipo Convencional
          IF rw_craplfp.idtppagt = 'C' THEN
            --Se a empresa escolheu gravar o salario
            IF rw_craplfp.flgrvsal = 1 THEN
              --Atualizaremos o salário com este lançamento
              vr_tab_craplfp(rw_craplfp.nrdconta).vllancto := rw_craplfp.vllancto;
            ELSE
             --Iremos apagar o histórico de salário
             vr_tab_craplfp(rw_craplfp.nrdconta).vllancto := 0;
            END IF;
          END IF;

          -- Caso seja ultimo registro da empresa
          IF rw_craplfp.numempre = rw_craplfp.qtempres THEN

            -- Caso seja debito em folha
            IF rw_craplfp.fldebfol = 1 THEN

              vr_dtexecde := pr_rw_crapdat.dtmvtopr;

              -- Se o dia da dtmvtopr for anterior ao dia limite para debitos
              IF TO_CHAR(vr_dtexecde,'DD') <= rw_crapemp.dtlimdeb THEN
                vr_dtexecde := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                          ,pr_dtmvtolt => TO_DATE(TO_CHAR(rw_crapemp.dtlimdeb,'fm00') || '/' || 
                                                                                  TO_CHAR(pr_rw_crapdat.dtmvtopr,'MM/RRRR'), 
                                                                                  'DD/MM/RRRR'));
              END IF;

              BEGIN
                -- Inserir registro de controle na craptab
                INSERT INTO craptab
                           (nmsistem
                           ,tptabela
                           ,cdempres
                           ,cdacesso
                           ,tpregist
                           ,cdcooper
                           ,dstextab)
                     VALUES('CRED'              -- nmsistem
                           ,'USUARI'            -- tptabela
                           ,rw_crapemp.cdempres -- cdempres
                           ,'EXECDEBEMP'        -- cdacesso
                           ,0                   -- tpregist
                           ,pr_cdcooper         -- cdcooper
                           ,TO_CHAR(rw_craplfp.dtmacred,'DD/MM/RRRR') || ' ' ||
                            TO_CHAR(vr_dtexecde,'DD/MM/RRRR') || ' 0' ); -- dstextab
              EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                  -- Se ja existe deve alterar
                  BEGIN
                    UPDATE craptab
                       SET craptab.dstextab = TO_CHAR(rw_craplfp.dtmacred,'DD/MM/RRRR') || ' ' ||
                                              TO_CHAR(vr_dtexecde,'DD/MM/RRRR') || ' 0'
                     WHERE craptab.cdcooper        = pr_cdcooper
                       AND UPPER(craptab.nmsistem) = 'CRED'
                       AND UPPER(craptab.tptabela) = 'USUARI'
                       AND craptab.cdempres        = rw_crapemp.cdempres
                       AND UPPER(craptab.cdacesso) = 'EXECDEBEMP'
                       AND craptab.tpregist        = 0;
                  END;
              END;

              -- Busca os avisos de debito que tenham ficado pendentes para gerar a CRAPFOL zerada
              FOR rw_avs_fol IN cr_avs_fol(pr_cdcooper => pr_cdcooper,
                                           pr_cdempres => rw_crapemp.cdempres,
                                           pr_dtrefere => rw_craplfp.dtmacred) LOOP
                BEGIN
                  INSERT INTO crapfol
                             (cdcooper
                             ,cdempres
                             ,dtrefere
                             ,nrdconta)
                       VALUES(pr_cdcooper
                             ,rw_crapemp.cdempres
                             ,rw_craplfp.dtmacred
                             ,rw_avs_fol.nrdconta); --> Conta encontrada na AVS
                END;
              END LOOP; -- cr_avs_fol

            END IF; -- fldebfol = 1

            -- Inicializa as avariaveis
            vr_vlsddisp := 0;
            vr_tottarif := 0;
            vr_flsittar := 1;
            vr_dsobstar := NULL;

            -- Percorre a lista de pagamentos
            vr_chave := vr_tab_crappfp.FIRST;
            WHILE vr_chave IS NOT NULL LOOP
              BEGIN
                UPDATE crappfp
                   SET -- Atualiza os pagamentos que foram processados
                       dthorcre = SYSDATE,
                       flsitcre = 1, --> Creditado
                       dsobscre = NULL
                 WHERE ROWID = vr_chave;
              END;
              vr_chave := vr_tab_crappfp.NEXT(vr_chave);
            END LOOP;

            BEGIN
              -- Atualizar a data da ultima utilizacao do produto
              UPDATE crapemp
                 SET crapemp.dtultufp = SYSDATE
               WHERE crapemp.cdcooper = pr_cdcooper
                 AND crapemp.cdempres = rw_crapemp.cdempres;
            END;

            -- Percorre a lista de lancamentos
            vr_chave := vr_tab_craplfp.FIRST;
            WHILE vr_chave IS NOT NULL LOOP
              BEGIN
                -- Atualizar com o ultimo valor liquido pago
                UPDATE crapefp
                   SET vlultsal = vr_tab_craplfp(vr_chave).vllancto
                 WHERE cdcooper = pr_cdcooper
                   AND cdempres = rw_crapemp.cdempres
                   AND nrdconta = vr_chave;
              END;
              vr_chave := vr_tab_craplfp.NEXT(vr_chave);
            END LOOP;

            BEGIN
              -- Atualizar a CRAPTAB
              UPDATE craptab
                 SET craptab.dstextab        = SUBSTR(craptab.dstextab, 1, 13) || '1'
               WHERE craptab.cdcooper        = pr_cdcooper
                 AND UPPER(craptab.nmsistem) = 'CRED'
                 AND UPPER(craptab.tptabela) = 'GENERI'
                 AND craptab.cdempres        = 0
                 AND UPPER(craptab.cdacesso) = 'DIADOPAGTO'
                 AND craptab.tpregist        = rw_crapemp.cdempres;
            END;

            -- Lotes de Folha/Emprestimo/Cotas
            FOR vr_index IN 1..3 LOOP

              -- Carrega os lotes
              CASE vr_index
                WHEN 1 THEN vr_lote_nro := rw_craplot_fol.nrdolote;
                WHEN 2 THEN vr_lote_nro := rw_craplot_emp.nrdolote;
                WHEN 3 THEN vr_lote_nro := rw_craplot_cot.nrdolote;
              END CASE;

              -- Busca o lote FOL/EMP/COT
              OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                              pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                              pr_nrdolote => vr_lote_nro);
              FETCH cr_craplot INTO rw_craplot;
              CLOSE cr_craplot;

              -- Caso os valores de credito/debito estejam zerados
              IF rw_craplot.vlinfodb = 0 AND
                 rw_craplot.vlcompdb = 0 AND
                 rw_craplot.vlinfocr = 0 AND
                 rw_craplot.vlcompcr = 0 THEN
                BEGIN
                  -- Remove o lote zerado
                  DELETE FROM craplot WHERE ROWID = rw_craplot.rowid;
                END;
              END IF;

            END LOOP; -- Fim do loop 1..3 dos lotes

            -- Efetua Commit
            COMMIT;

            -- Caso possua CTASAL
            IF vr_blctasal THEN

              -- Verifica lancamentos pendentes de envio ao SPB
              OPEN cr_lancspb(pr_cdcooper => pr_cdcooper,
                              pr_cdempres => rw_crapemp.cdempres);
              FETCH cr_lancspb INTO rw_lancspb;
              vr_blnfound := cr_lancspb%FOUND;
              CLOSE cr_lancspb;

              -- Se encontrou lancamentos pendentes
              IF vr_blnfound THEN

                -- Chama a rotina PC_TRFSAL_OPCAO_B
                SSPB0001.pc_trfsal_opcao_b(pr_cdcooper => pr_cdcooper
                                          ,pr_cdagenci => 0
                                          ,pr_nrdcaixa => 1
                                          ,pr_cdoperad => 1
                                          ,pr_cdempres => rw_crapemp.cdempres
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);

                -- Se retornar critica
                IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                  
                  -- Envia o erro para o LOG
                  CECRED.pc_log_programa(pr_dstiplog => 'O'
                                       , pr_cdprograma => 'FOLH0001' 
                                       , pr_cdcooper => pr_cdcooper
                                       , pr_tpexecucao => 0
                                       , pr_tpocorrencia => 2 
                                       , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_cr_pagto_aprovados_ctasal. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' – CONTA ' || rw_crapemp.nrdconta || ' –  ERRO COM AS TECS SALARIO: ' || vr_cdcritic || '-' || vr_dscritic
                                       , pr_idprglog => vr_idprglog);

                  -- Destinatarios responsaveis pelos avisos
                  vr_emailds2 :=  GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                           ,pr_cdcooper => pr_cdcooper
                                                           ,pr_cdacesso => 'FOLHAIB_EMAIL_ALERT_FIN');

                  -- Mensagem informando o erro
                  vr_dsmensag := 'Houveram erros inesperados no sistema e as transferências TEC salário ' ||
                                 'da empresa não puderam ser efetuadas automaticamente. Abaixo trazemos o ' ||
                                 'erro ocorrido:<br>' || vr_cdcritic || '-' || vr_dscritic || '<br><br>' ||
                                 'Consulte a tela TRFSAL, opção C para verificar se ainda há lançamentos ' ||
                                 'pendentes.';

                  -- Solicita envio do email
                  GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                            ,pr_cdprogra        => 'FOLH0001'
                                            ,pr_des_destino     => TRIM(vr_emailds2) || ';' || TRIM(vr_emailds1)
                                            ,pr_des_assunto     => 'Folha de Pagamento - Problema com as TECs – Empresa ' || rw_crapemp.cdempres || ' - ' || rw_crapemp.nmresemp
                                            ,pr_des_corpo       => vr_dsmensag
                                            ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                            ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                            ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                            ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                            ,pr_des_erro        => vr_dscritic);

                END IF; -- vr_cdcritic / vr_dscritic

              END IF; -- vr_blnfound

              -- Reseta a variavel
              vr_blctasal := FALSE;

              COMMIT;

            END IF; -- vr_blctasal

          END IF; -- numempre = qtempres

        END LOOP; -- cr_craplfp

        -- Após processar todos os pagamentos da empresa, iremos atualizar
        -- aqueles pagamentos em que só restaram lançamentos de erro, e devido
        -- a isso o mesmo não é processado e ficaria pendente

        BEGIN
          UPDATE crappfp pfp
             SET pfp.dthorcre = SYSDATE
                ,pfp.flsitcre = 1 --> Creditado
           WHERE pfp.cdcooper = pr_cdcooper
             AND pfp.cdempres = rw_crapemp.cdempres
             AND pfp.flsitdeb = 1 -- Já debitado
             AND pfp.flsitcre = 0 -- Com crédito pendente
             -- Não exista nenhum lançamento pendente
             AND NOT EXISTS(SELECT 1
                              FROM craplfp lfp
                             WHERE pfp.cdcooper = lfp.cdcooper
                               AND pfp.cdempres = lfp.cdempres
                               AND pfp.nrseqpag = lfp.nrseqpag
                               AND lfp.idsitlct = 'L'
                               AND lfp.vllancto > 0);
        END;

        -- Atualizar todos os lançamentos sem crédito pois eles estão pendentes devido ao vllancto = 0
        BEGIN
          UPDATE craplfp lfp
             SET lfp.idsitlct = 'C'
                ,lfp.dsobslct = 'Lançamento sem crédito - apenas para emissão do comprovante'
           WHERE lfp.cdcooper = pr_cdcooper
             AND lfp.cdempres = rw_crapemp.cdempres
             AND lfp.idsitlct = 'L' -- Ainda pendentes
             AND lfp.vllancto = 0 -- Somente aqueles sem crédito
             -- E o pagamento tenha sido creditado
             AND EXISTS (SELECT 1
                           FROM crappfp pfp
                          WHERE pfp.cdcooper = lfp.cdcooper
                            AND pfp.cdempres = lfp.cdempres
                            AND pfp.nrseqpag = lfp.nrseqpag
                            AND pfp.flsitcre = 1);
        END;

        -- Adicionamos no LOG o encerramento do processo de credito desta empresa
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                             , pr_cdprograma => 'FOLH0001' 
                             , pr_cdcooper => pr_cdcooper
                             , pr_tpexecucao => 0
                             , pr_tpocorrencia => 1 
                             , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Rotina pc_cr_pagto_aprovados_ctasal. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' – ENCERRAMENTO DO PROCESSO DE CREDITO'
                             , pr_idprglog => vr_idprglog);
        
        -- Gravação final
        COMMIT;
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Desfazemos alterações até o momento adicionamos ao
          -- log da empresa o erro tratado
          ROLLBACK;
          CECRED.pc_log_programa(pr_dstiplog => 'O'
                               , pr_cdprograma => 'FOLH0001' 
                               , pr_cdcooper => pr_cdcooper
                               , pr_tpexecucao => 0
                               , pr_tpocorrencia => 1 
                               , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_cr_pagto_aprovados_ctasal. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' '||vr_dscritic
                               , pr_idprglog => vr_idprglog);
            
        WHEN OTHERS THEN
          -- Desfazemos alterações até o momento adicionamos ao
          -- log da empresa o erro não tratado
          ROLLBACK;
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          CECRED.pc_log_programa(pr_dstiplog => 'O'
                               , pr_cdprograma => 'FOLH0001' 
                               , pr_cdcooper => pr_cdcooper
                               , pr_tpexecucao => 0
                               , pr_tpocorrencia => 1 
                               , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_cr_pagto_aprovados_ctasal. Detalhes: CREDITO DE FOLHA – EMP ' || rw_crapemp.cdempres || ' ' ||SQLERRM
                               , pr_idprglog => vr_idprglog);
          
      END;
    END LOOP; -- cr_crapemp

    -- Busca o lote TEC (Global para a Cooperativa)
    OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                    pr_dtmvtolt => pr_rw_crapdat.dtmvtolt,
                    pr_nrdolote => rw_craplot_tec.nrdolote);
    FETCH cr_craplot INTO rw_craplot_tec;
    CLOSE cr_craplot;

    -- Caso os valores de credito/debito estejam zerados
    IF rw_craplot_tec.vlinfodb = 0 AND
       rw_craplot_tec.vlcompdb = 0 AND
       rw_craplot_tec.vlinfocr = 0 AND
       rw_craplot_tec.vlcompcr = 0 THEN
      BEGIN
        -- Remove o lote zerado
        DELETE FROM craplot WHERE ROWID = rw_craplot_tec.rowid;
      END;
    END IF;

    -- Efetua Commit
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer a operacao
      ROLLBACK;
      -- efetuar o raise
      raise_application_error(-25001, 'Erro FOLH0001.PC_CREDITO_PAGTO_APROVADOS: '||vr_dscritic);
    WHEN OTHERS THEN
      -- Desfazer a operacao
      ROLLBACK;
      
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      
      -- efetuar o raise
      raise_application_error(-25000, 'Erro FOLH0001.PC_CREDITO_PAGTO_APROVADOS: '||vr_dscritic);
  END pc_cr_pagto_aprovados_ctasal;

  /* Busca todos os pagamentos já creditados mas não tarifados ainda para tarifar */
  PROCEDURE pc_cobra_tarifas_pendentes (pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_rw_crapdat IN BTCH0001.CR_CRAPDAT%ROWTYPE) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_cobra_tarifas_pendentes             Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Lucas Afonso Lombardi Moreira
  --  Data     : julho/2015.                   Ultima atualizacao: 31/03/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Busca todos os pagamentos já creditados mas não tarifados ainda para tarifar
  -- Alterações
  --             04/11/2015 - Troca do tipo da variavel decimal para number, pois o saldo
  --                          estava sendo truncado - Marcos(Supero)
  --
  --             12/11/2015 - Migracao da tarifação do sistema da CONFOL para CADTAR (Marcos-Supero)
  --
  --             29/03/2016 - Lançar cobrança da tarifa folha on-line (Guilherme/SUPERO)
  --
  ---------------------------------------------------------------------------------------------------------------


  -- Busca Pagamentos das Folhas de Pagamento
  CURSOR cr_lista_pfp (pr_cdcooper IN crapemp.cdcooper%TYPE) IS
    SELECT pfp.progress_recid
          ,pfp.cdcooper
          ,pfp.cdempres
          ,pfp.nrseqpag
          ,emp.nrdconta
          ,pfp.dtcredit
          ,pfp.qtlctpag * pfp.vltarapr vltottar
          ,pfp.qtlctpag
          ,pfp.vltarapr
          ,pfp.flsitcre
          ,pfp.flsittar
          ,pfp.dthortar
          ,pfp.rowid
      FROM crapemp emp
          ,crappfp pfp
     WHERE pfp.cdcooper = emp.cdcooper
       AND pfp.cdempres = emp.cdempres
       AND pfp.cdcooper = pr_cdcooper
       AND pfp.flsitcre = 1 -- Creditados
       AND pfp.flsittar = 0 -- Nao tarifada ainda
     ORDER BY pfp.cdcooper
             ,pfp.cdempres
             ,pfp.nrseqpag;

  -- Variaveis de Erro
  vr_dscritic VARCHAR2(4000);

  -- Variaveis Excecao
  vr_exc_erro EXCEPTION;

  BEGIN

    -- Update para flagar os pagamentos já creditados, não tarifados, mas que a tarifa seja gratuita
    BEGIN
      UPDATE crappfp
         SET flsittar = 1
       WHERE cdcooper = pr_cdcooper
         AND flsitcre = 1 -- Creditados
         AND flsittar = 0 -- Nao tarifada ainda
         AND vltarapr = 0;-- Sem tarifa...
    EXCEPTION -- Se ocorrer algum erro
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_cobra_tarifas_pendentes. Detalhes: TARIFA DE SERVICO GRATIS – DESCONTAR TARIFA - ' || upper(SQLERRM);
        RAISE vr_exc_erro;
    END;

    -- Pega todos os pagamentos não tarifados e que o crédito já tenha ocorrido,
    FOR rw_lista_pfp IN cr_lista_pfp(pr_cdcooper) LOOP
      BEGIN

        -- Atualiza pagamento da tarifa folha
        BEGIN
          UPDATE crappfp
             SET flsittar = 1
           WHERE crappfp.rowid = rw_lista_pfp.rowid;
        EXCEPTION -- Se ocorrer algum erro
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_cobra_tarifas_pendentes. Detalhes: TARIFA DE SERVICO – EMP ' || rw_lista_pfp.cdempres || ' – CONTA ' || rw_lista_pfp.nrdconta|| ' – LANCAMENTO TARIFA DE R$ ' || to_char(rw_lista_pfp.vltottar,'fm9g999g999g999g999g990d00') || ' - ' || upper(SQLERRM);
            RAISE vr_exc_erro;
        END;

        -- LANCAMENTO DA TARIFA DA FOLHA
        folh0001.pc_cria_tarifa_folha(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => rw_lista_pfp.nrdconta
                             ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                                     ,pr_flgestor => 0   -- Flag Estorno (0-Nao /1-Sim)
                                     ,pr_indrowid => rw_lista_pfp.rowid
                                     ,pr_dscritic => vr_dscritic );
        --Se ocorrer erro
          IF vr_dscritic IS NOT NULL THEN
          --Usar o erro da tab
            RAISE vr_exc_erro;
          END IF;

      END;
      
          -- Efetua Commit
          COMMIT;

    END LOOP; -- FIM -  FOR rw_lista_pfp IN cr_lista_pfp


  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer a operacao
      ROLLBACK;
      -- efetuar o raise
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                               , pr_cdprograma => 'FOLH0001' 
                               , pr_cdcooper => pr_cdcooper
                               , pr_tpexecucao => 0
                               , pr_tpocorrencia => 1 
                               , pr_dsmensagem => vr_dscritic
                               , pr_idprglog => vr_idprglog);
      
    WHEN OTHERS THEN
      -- Desfazer a operacao
      ROLLBACK;
      
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      
      -- efetuar o raise
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'FOLH0001' 
                           , pr_cdcooper => pr_cdcooper
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_cobra_tarifas_pendentes. Detalhes: TARIFA DE SERVICO – ' || SQLERRM
                           , pr_idprglog => vr_idprglog);
     
  END pc_cobra_tarifas_pendentes;



 /* Procedure para criar o lancamento da tarifa da Folha na LAT */
   PROCEDURE pc_cria_tarifa_folha(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                 ,pr_flgestor  IN NUMBER -- Se é estorno ou nao
                                 ,pr_indrowid  IN VARCHAR2
                                 ,pr_dscritic OUT VARCHAR2) IS
   ---------------------------------------------------------------------------------------------------------------
   --  Programa : pc_cria_tarifa_folha             Antigo:
   --  Sistema  : Internet Banking
   --  Sigla    : CRED
   --  Autor    : Guilherme/SUPERO
   --  Data     : Março/2016.                   Ultima atualizacao: 
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Procedure para criar o lancamento da tarifa da Folha na LAT (On-line)
   --
   -- Alterações: 
   --
   ---------------------------------------------------------------------------------------------------------------

      -- Busca o valor da tarifa
      CURSOR cr_crappfp(pr_rowid VARCHAR2) IS
         SELECT pfp.cdempres
               ,emp.cdcontar
               ,pfp.idopdebi
               ,pfp.dtcredit
               ,pfp.qtlctpag
               ,pfp.vllctpag
               ,pfp.qtlctpag * pfp.vltarapr vltottar
               ,pfp.progress_recid
           FROM crapemp emp
               ,crappfp pfp
          WHERE pfp.rowid    = pr_rowid
            AND pfp.cdcooper = emp.cdcooper
            AND pfp.cdempres = emp.cdempres;
      rw_crappfp cr_crappfp%ROWTYPE;

      -- Busca número do lote
      CURSOR cr_craptab (pr_cdcooper IN crapemp.cdcooper%TYPE
                        ,pr_cdempres IN crapemp.cdempres%TYPE) IS
        SELECT to_number(dstextab) nrdolote
               FROM craptab
              WHERE craptab.cdcooper = pr_cdcooper
                AND upper(craptab.nmsistem) = 'CRED'
                AND upper(craptab.tptabela) = 'GENERI'
                AND craptab.cdempres        = 0
                AND upper(craptab.cdacesso) = 'NUMLOTEFOL'
                AND craptab.tpregist = pr_cdempres;
      rw_craptab cr_craptab%ROWTYPE;

      -- Verificar lote
      CURSOR cr_craplot (pr_cdcooper  craplot.cdcooper%TYPE,
                         pr_dtmvtolt  craplot.dtmvtolt%TYPE,
                         pr_cdageope  craplot.cdagenci%TYPE,
                         pr_cdbccxlt  craplot.cdbccxlt%TYPE,
                         pr_nrdolote  craplot.nrdolote%TYPE)IS
        SELECT craplot.rowid,
               craplot.dtmvtolt,
               craplot.cdagenci,
               craplot.cdbccxlt,
               craplot.nrdolote,
               craplot.nrseqdig,
               craplot.cdhistor
          FROM craplot
         WHERE craplot.cdcooper = pr_cdcooper
           AND craplot.dtmvtolt = pr_dtmvtolt
           AND craplot.cdagenci = pr_cdageope
           AND craplot.cdbccxlt = pr_cdbccxlt
           AND craplot.nrdolote = pr_nrdolote
         FOR UPDATE NOWAIT;


      -- Variaveis
      vr_cdlantar craplat.cdlantar%TYPE;
      rw_craplot_lcm cr_craplot%ROWTYPE;
      vr_flgerlog   VARCHAR2(50);

      -- Retorno da rotina de tarifas
      vr_cdhistor INTEGER;
      vr_cdhisdeb INTEGER;
      vr_cdhisest INTEGER;
      vr_dtdivulg DATE;
      vr_vltarfol NUMBER := 0;
      vr_dtvigenc DATE;
      vr_cdfvlcop INTEGER;

      -- Variaveis Excecao
      vr_exc_erro EXCEPTION;

      --Tabela erro
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Variaveis de Erro
      vr_cdcritic NUMBER(10);
      vr_dscritic VARCHAR2(4000);

    ---------------- SUB-ROTINAS ------------------
    -- Procedimento para inserir o lote e não deixar tabela lockada
    PROCEDURE pc_insere_lote (pr_cdcooper IN craplot.cdcooper%TYPE,
                              pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                              pr_cdagenci IN craplot.cdagenci%TYPE,
                              pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                              pr_nrdolote IN craplot.nrdolote%TYPE,
                              pr_tplotmov IN craplot.tplotmov%TYPE,
                              pr_cdhistor IN craplot.cdhistor%TYPE DEFAULT 0,
                              pr_cdoperad IN craplot.cdoperad%TYPE,
                              pr_nrdcaixa IN craplot.nrdcaixa%TYPE,
                              pr_cdopecxa IN craplot.cdopecxa%TYPE,
                              pr_craplot  OUT cr_craplot%ROWTYPE,
                              pr_dscritic OUT VARCHAR2)IS

      -- Pragma - abre nova sessao para tratar a atualizacao
      PRAGMA AUTONOMOUS_TRANSACTION;
        
      rw_craplot cr_craplot%ROWTYPE;
      vr_nrdolote craplot.nrdolote%TYPE;
        
    BEGIN
      vr_nrdolote := pr_nrdolote;
      
      TARI0001.pc_gera_log_lote_uso(pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_nrdolote => vr_nrdolote,
                                    pr_flgerlog => vr_flgerlog,
                                    pr_des_log  =>'Alocando lote -> '||
                                                   'cdcooper: '|| pr_cdcooper ||' '||           
                                                   'dtmvtolt: '|| to_char(pr_dtmvtolt,'DD/MM/RRRR')||' '||           
                                                   'cdagenci: '|| pr_cdagenci||' '||           
                                                   'cdbccxlt: '|| pr_cdbccxlt||' '||           
                                                   'nrdolote: '|| vr_nrdolote||' '|| 
                                                   'nrdconta: '|| pr_nrdconta||' '|| 
                                                   'cdhistor: '|| pr_cdhistor||' '|| 
                                                   'rotina: FOLH00001.pc_cria_tarifa_folha ');
      
      FOR vr_contador IN 1..100 LOOP
        BEGIN         
          -- verificar lote
          OPEN cr_craplot (pr_cdcooper  => pr_cdcooper,
                           pr_dtmvtolt  => pr_dtmvtolt,
                           pr_cdageope  => pr_cdagenci,
                           pr_cdbccxlt  => pr_cdbccxlt,
                           pr_nrdolote  => vr_nrdolote);
          FETCH cr_craplot INTO rw_craplot;
          -- se não deu erro no fecth é pq o registro não esta em lock
          EXIT;           
            
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
          
            IF cr_craplot%ISOPEN THEN
              CLOSE cr_craplot;
            END IF;
            
            TARI0001.pc_gera_log_lote_uso (pr_cdcooper => pr_cdcooper,
                                           pr_nrdconta => pr_nrdconta,
                                           pr_nrdolote => vr_nrdolote,
                                           pr_flgerlog => vr_flgerlog,
                                           pr_des_log  => 'Lote ja alocado('||vr_contador||') -> '||
                                                           'cdcooper: '||pr_cdcooper ||' '||           
                                                           'dtmvtolt: '|| to_char(pr_dtmvtolt,'DD/MM/RRRR') ||' '||           
                                                           'cdagenci: '|| pr_cdagenci||' '||           
                                                           'cdbccxlt: '|| pr_cdbccxlt||' '||           
                                                           'nrdolote: '|| vr_nrdolote||' '|| 
                                                           'nrdconta: '|| pr_nrdconta||' '|| 
                                                           'cdhistor: '|| pr_cdhistor||' '|| 
                                                           'rotina: FOLH00001.pc_cria_tarifa_folha');
            
            -- se for a ultima tentativa, guardar a critica
            IF vr_contador = 100 THEN
              pr_dscritic := 'Tabela CRAPLOT em uso(lote: '||vr_nrdolote||').';
            END IF;
            sys.dbms_lock.sleep(0.1);  
        END;
      END LOOP;
      
      -- se encontrou erro ao buscar lote, abortar programa
      IF pr_dscritic IS NOT NULL THEN
        ROLLBACK;
        RETURN;
      END IF;
        
      IF cr_craplot%NOTFOUND THEN
        -- criar registros de lote na tabela
        INSERT INTO craplot
            (dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             tplotmov,
             cdcooper,
             cdoperad,
             nrdcaixa,
             cdopecxa,
             nrseqdig,
             cdhistor)
          VALUES
            (pr_dtmvtolt,
             pr_cdagenci,
             pr_cdbccxlt,
             vr_nrdolote,
             pr_tplotmov,  -- tplotmov
             pr_cdcooper,
             pr_cdoperad,
             pr_nrdcaixa,
             pr_cdopecxa,
             1,            -- nrseqdig
             pr_cdhistor)
           RETURNING ROWID,
                     craplot.dtmvtolt,
                     craplot.cdagenci,
                     craplot.cdbccxlt,
                     craplot.nrdolote,
                     craplot.nrseqdig
                INTO rw_craplot.rowid,
                     rw_craplot.dtmvtolt,
                     rw_craplot.cdagenci,
                     rw_craplot.cdbccxlt,
                     rw_craplot.nrdolote,
                     rw_craplot.nrseqdig;
          
      ELSE
        -- Atualizar lote para reservar nrseqdig
        UPDATE craplot
           SET craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
         WHERE craplot.rowid = rw_craplot.rowid
        RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig; 
        
      END IF;
      CLOSE cr_craplot;
      pr_craplot := rw_craplot;
        
      COMMIT;
      
    EXCEPTION
      WHEN OTHERS THEN
        IF cr_craplot%ISOPEN THEN
          CLOSE cr_craplot;
        END IF;
        
        ROLLBACK;        
        
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        
        -- se ocorreu algum erro durante a criac?o
        pr_dscritic := 'Erro ao inserir/atualizar lote '||rw_craplot.nrdolote||': '||SQLERRM;
    END pc_insere_lote;



    BEGIN -- Inicio pc_cria_tarifa_folha    
    
      -- Busca o valor da tarifa e a data de debito
      OPEN  cr_crappfp(pr_rowid => pr_indrowid);
      FETCH cr_crappfp INTO rw_crappfp;
      CLOSE cr_crappfp;   

      -- Buscar o nr LOTE da FOLHA
          OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                         ,pr_cdempres => rw_crappfp.cdempres);
          FETCH cr_craptab INTO rw_craptab;
          -- Verificar se existe informacao, e gerar erro caso nao exista
          IF cr_craptab%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_craptab;
            -- Gerar excecao
        vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ': TARIFA DE SERVICO – EMP ' || rw_crappfp.cdempres || ' – CONTA ' || pr_nrdconta || ' – ERRO AO LANCAR TARIFA - ' || upper(gene0001.fn_busca_critica(vr_cdcritic));
            RAISE vr_exc_erro;
          END IF;
          -- Fechar o cursor
          CLOSE cr_craptab;


      -- Buscamos os valores da tarifa vigente no sistema de tarifação (CADTAR)
      tari0001.pc_carrega_dados_tarifa_cobr(pr_cdcooper => pr_cdcooper     --Codigo Cooperativa
                                           ,pr_nrdconta => pr_nrdconta     --Conta da empresa
                                           ,pr_nrconven => rw_crappfp.cdcontar --Numero Convenio
                                           ,pr_dsincide => 'FOLHA'         --Descricao Incidencia
                                           ,pr_cdocorre => rw_crappfp.idopdebi --Codigo Ocorrencia
                                           ,pr_cdmotivo => NULL            --Codigo Motivo
                                           ,pr_inpessoa => 2               --Tipo Pessoa(PJ)
                                           ,pr_vllanmto => rw_crappfp.vllctpag --Valor Lancamento
                                           ,pr_cdprogra => 'FOLH0002'      --Nome Programa
                                           ,pr_flaputar => 1               --Apurar
										   ,pr_cdhistor => vr_cdhisdeb     --Codigo Historico
                                           ,pr_cdhisest => vr_cdhisest     --Historico Estorno
                                           ,pr_vltarifa => vr_vltarfol     --Valor Tarifa
                                           ,pr_dtdivulg => vr_dtdivulg     --Data Divulgacao
                                           ,pr_dtvigenc => vr_dtvigenc     --Data Vigencia
                                           ,pr_cdfvlcop => vr_cdfvlcop
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
      --Se ocorrer erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;


      IF pr_flgestor = 1 THEN -- se for Estorno
        vr_cdhistor := vr_cdhisest; -- Estorno Tarifa
              ELSE
        vr_cdhistor := vr_cdhisdeb; -- Debito Tarifa
              END IF;


      ----------- LANÇAMENTO -----------
      rw_craplot_lcm := NULL;
      -- Criação do lote para lançamento
      pc_insere_lote (pr_cdcooper => pr_cdcooper,
                      pr_dtmvtolt => pr_dtmvtolt,
                      pr_cdagenci => 90,
                      pr_cdbccxlt => 100,
                      pr_nrdolote => rw_craptab.nrdolote,
                      pr_tplotmov => 1,
                      pr_cdoperad => 996,
                      pr_nrdcaixa => 0,
                      pr_cdopecxa => 996,
                      pr_craplot  => rw_craplot_lcm,
                      pr_dscritic => vr_dscritic);      
      IF vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_erro;
      END IF;  

      --Realizar lancamento tarifa
      TARI0001.pc_lan_tarifa_online (pr_cdcooper => pr_cdcooper          --Codigo Cooperativa
                                    ,pr_cdagenci => 90                   --Codigo Agencia destino
                                    ,pr_nrdconta => pr_nrdconta          --Numero da Conta Destino
                                    ,pr_cdbccxlt => 100                  --Codigo banco/caixa
                                    ,pr_nrdolote => rw_craptab.nrdolote  --Numero do Lote
                                    ,pr_tplotmov => 1                    --Tipo Lote
                                    ,pr_cdoperad => 996                  --Codigo Operador
                                    ,pr_dtmvtlat => pr_dtmvtolt          --Data Tarifa
                                    ,pr_dtmvtlcm => pr_dtmvtolt          --Data lancamento
                                    ,pr_nrdctabb => pr_nrdconta          --Numero Conta BB
                                    ,pr_nrdctitg => to_char(pr_nrdconta,'fm00000000')  --Conta Integracao
                                    ,pr_cdhistor => vr_cdhistor          --Codigo Historico
                                    ,pr_cdpesqbb => ''                   --Codigo pesquisa
                                    ,pr_cdbanchq => 0                    --Codigo Banco Cheque
                                    ,pr_cdagechq => 0                    --Codigo Agencia Cheque
                                    ,pr_nrctachq => 0                    --Numero Conta Cheque
                                    ,pr_flgaviso => FALSE                --Flag Aviso
                                    ,pr_tpdaviso => 0                    --Tipo Aviso
                                    ,pr_vltarifa => vr_vltarfol * rw_crappfp.qtlctpag   --Valor tarifa
                                    ,pr_nrdocmto => rw_crappfp.progress_recid  --Numero Documento
                                    ,pr_cdcoptfn => 0                    --Codigo Cooperativa Terminal
                                    ,pr_cdagetfn => 0                    --Codigo Agencia Terminal
                                    ,pr_nrterfin => 0                    --Numero Terminal Financeiro
                                    ,pr_nrsequni => 0                    --Numero Sequencial Unico
                                    ,pr_nrautdoc => rw_craplot_lcm.nrseqdig + 1 --Numero Autenticacao Documento
                                    ,pr_dsidenti => NULL                 --Descricao Identificacao
                                    ,pr_cdfvlcop => vr_cdfvlcop          --Codigo Faixa Valor Cooperativa
                                    ,pr_inproces => 1         -- On-line --Indicador processo
                                    ,pr_cdlantar => vr_cdlantar          --Codigo Lancamento tarifa
                                    ,pr_tab_erro => vr_tab_erro          --Tabela de erro
                                    ,pr_cdcritic => vr_cdcritic          --Codigo do erro
                                    ,pr_dscritic => vr_dscritic);        --Descricao do erro
      --Se ocorrer erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --verificar o erro e criar log
        IF vr_tab_erro.COUNT > 0 THEN
          --Usar o erro da tab
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; --Descricao do erro
                  RAISE vr_exc_erro;
            END IF;
          END IF;


      EXCEPTION
        WHEN vr_exc_erro THEN
       pr_dscritic := vr_dscritic;
     WHEN OTHERS THEN
       CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
       
       pr_dscritic := 'Erro na rotina FOLH0002.pc_cria_tarifa_folha: ' || SQLERRM;

   END pc_cria_tarifa_folha;




  /* Devolver TECs com rejeição e que não foram reprocessadas no mesmo dia.
     ou foram recusadas pelas Instituições Financeiras */
  PROCEDURE pc_estorno_automati_rejeicoes (pr_cdcooper IN crapcop.cdcooper%TYPE
                                          ,pr_rw_crapdat IN BTCH0001.CR_CRAPDAT%ROWTYPE) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_estorno_automati_rejeicoes             Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Lucas Afonso Lombardi Moreira
  --  Data     : Julho/2015.                   Ultima atualizacao: 29/04/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Busca todas as TECs com rejeição e que não foram reprocessadas
  --             no mesmo dia ou no próximo dia útil a rejeição, ou aquelas que
  --             foram recusadas pelas Instituições Financeiras e devem ser
  --             devolvidas automaticamente, sem interação pela tela TRFSAL.
  --
  -- Alterações
  --             25/01/2016 - Melhorias nos tratamentos de erro (Marcos-Supero)
  --
  --             01/03/2016 - Unificação dos controles de LCS (Marcos-Supero)
  --
  --             29/04/2016 - Correção na tipagem da variavel dsdemail (Marcos-Supero)
  ---------------------------------------------------------------------------------------------------------------

  CURSOR cr_craplcs (pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_cdhistor IN craplcs.cdhistor%TYPE
                    ,pr_dtmvtoan IN crapdat.dtmvtoan%TYPE) IS
    SELECT nrdconta
          ,vllanmto
          ,nrridlfp
          ,nrdocmto
          ,idopetrf
          ,ROWID
      FROM craplcs
     WHERE cdcooper = pr_cdcooper
       AND cdhistor = pr_cdhistor
       AND NRRIDLFP > 0
       AND flgenvio = 0 -- Não enviados
       AND( -- Opção 01 – Recusadas na cabine e com prazo de análise expirado
               (flgopfin = 0 -- False
            AND dtmvtolt < pr_dtmvtoan)
          OR
            -- Opção 02 – Recusadas após repasse para a Instituição Financeira (qualquer data)
            flgopfin = 1 --True
          )
       ORDER BY nrdconta, dtmvtolt, nrdocmto;
  rw_craplcs cr_craplcs%ROWTYPE;

  -- Buscar lote
  CURSOR cr_craplot (pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                    ,pr_nrdolote IN VARCHAR2) IS
    SELECT nrseqdig
          ,qtinfoln
          ,qtcompln
          ,vlinfodb
          ,vlcompdb
          ,vlinfocr
          ,vlcompcr
          ,rowid
      FROM craplot
     WHERE craplot.cdcooper = pr_cdcooper
       AND craplot.dtmvtolt = pr_dtmvtolt
       AND craplot.cdagenci = 1
       AND craplot.cdbccxlt = 100
       AND craplot.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;

  -- Busca a empresa do pagamento
  CURSOR cr_crapemp (pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_nrridlfp IN craplcs.nrridlfp%TYPE) IS
   SELECT emp.cdempres
         ,emp.nrdconta
         ,emp.dsdemail
     FROM crapemp emp
         ,craplfp lfp
    WHERE lfp.cdcooper = pr_cdcooper
      AND lfp.progress_recid = pr_nrridlfp
      AND lfp.cdcooper = emp.cdcooper
      AND lfp.cdempres = emp.cdempres;
  rw_crapemp cr_crapemp%ROWTYPE;

  -- Busca o LOTE de folha da empresa
  CURSOR cr_craptab (pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_cdempres IN crapemp.cdempres%TYPE) IS
    SELECT to_number(dstextab) nrdolote
      FROM craptab
     WHERE craptab.cdcooper = pr_cdcooper
       AND upper(craptab.nmsistem) = 'CRED'
       AND upper(craptab.tptabela) = 'GENERI'
       AND craptab.cdempres = 0
       AND upper(craptab.cdacesso) = 'NUMLOTEFOL'
       AND craptab.tpregist = pr_cdempres;
  rw_craptab cr_craptab%ROWTYPE;

  --Tabelas
  TYPE lanc_reg IS
    RECORD (cdempres crapemp.cdempres%TYPE
           ,nrdconta crapemp.nrdconta%TYPE
           ,vllanmto NUMBER
           ,dsdemail crapemp.dsdemail%TYPE);

  TYPE lanc_tab IS
    TABLE OF lanc_reg
    INDEX BY BINARY_INTEGER;

  --Variaveis
  vr_cdhisrec    VARCHAR2(400);
  vr_cdhisdev    VARCHAR2(400);
  vr_cdhisest    VARCHAR2(400);
  vr_nrdlote     VARCHAR2(100);
  vr_nrdocmto    VARCHAR2(100);
  vr_chave       BINARY_INTEGER;
  tb_lancamentos lanc_tab;
  vr_first_reg   BOOLEAN := TRUE;

  --Variaveis de E-mail
  vr_email_assunto VARCHAR2(300);
  vr_email_destino VARCHAR2(300);
  vr_email_corpo   VARCHAR2(2000);
  vr_email_erro    VARCHAR2(1000);
  vr_hasfound      BOOLEAN;

  -- Variaveis de Erro
  vr_dscritic   VARCHAR2(4000);

  -- Variaveis Excecao
  vr_exc_erro EXCEPTION;

  BEGIN
    -- Busca o histórico parametrizado de lançamentos rejeitados/devolvidos e de estorno
    vr_cdhisrec := gene0001.fn_param_sistema('CRED',pr_cdcooper,'FOLHAIB_HIST_REC_TECSAL');
    vr_cdhisdev := gene0001.fn_param_sistema('CRED',pr_cdcooper,'FOLHAIB_HIST_DEV_TECSAL');

    FOR rw_craplcs IN cr_craplcs (pr_cdcooper => pr_cdcooper
                                 ,pr_cdhistor => vr_cdhisrec
                                 ,pr_dtmvtoan => pr_rw_crapdat.dtmvtoan) LOOP
      -- Se for o primeiro registro
      IF vr_first_reg THEN
        -- Buscar numero do lote
        vr_nrdlote := gene0001.fn_param_sistema('CRED',pr_cdcooper, 'FOLHAIB_NRLOTE_CTASAL');

        -- Buscar lote
        OPEN cr_craplot (pr_cdcooper
                        ,pr_rw_crapdat.dtmvtolt
                        ,vr_nrdlote);
        FETCH cr_craplot INTO rw_craplot;
        vr_hasfound := cr_craplot%FOUND;
        CLOSE cr_craplot;
        -- Verifica se existe lote
        -- Se não tiver, cria
        IF NOT vr_hasfound THEN
          BEGIN
            INSERT INTO craplot
                       (cdcooper
                       ,dtmvtolt
                       ,cdagenci
                       ,cdbccxlt
                       ,nrdolote
                       ,tplotmov)
                VALUES(pr_cdcooper
                      ,pr_rw_crapdat.dtmvtolt
                      ,1           -- cdagenci
                      ,100         -- cdbccxlt
                      ,vr_nrdlote
                      ,1)
             RETURNING  nrseqdig
                       ,qtinfoln
                       ,qtcompln
                       ,vlinfodb
                       ,vlcompdb
                       ,ROWID
                  INTO rw_craplot.nrseqdig
                      ,rw_craplot.qtinfoln
                      ,rw_craplot.qtcompln
                      ,rw_craplot.vlinfodb
                      ,rw_craplot.vlcompdb
                      ,rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              vr_email_erro := '060 - LOTE INEXISTENTE';
              vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_estorno_automati_rejeicoes. Detalhes: ESTORNO TEC DE FOLHA – 060 - LOTE INEXISTENTE';
              RAISE vr_exc_erro;
          END;
        END IF;
        vr_first_reg := FALSE;
      END IF;

      -- Busca próximo número de documento não utilizado
      vr_nrdocmto := rw_craplcs.nrdocmto;
      vr_exis_lcs := 0;
      LOOP 
        -- Verifica se existe craplcs com memso numero de documento
        OPEN cr_craplcs_nrdoc (pr_cdcooper => pr_cdcooper
                              ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                              ,pr_nrdconta => rw_craplcs.nrdconta
                              ,pr_cdhisdev => vr_cdhisdev
                              ,pr_nrdocmto => vr_nrdocmto);
        FETCH cr_craplcs_nrdoc 
         INTO vr_exis_lcs;
        -- Sair quando não tiver encontrado
        EXIT WHEN cr_craplcs_nrdoc%NOTFOUND;
        -- Fechamos o CURSOR pois ele será reaberto no próximo LOOP
        CLOSE cr_craplcs_nrdoc;
        -- Se persite no loop é pq existe, então adicionamos o numero documento
        vr_nrdocmto := vr_nrdocmto + 1000000000;
      END LOOP;  
      -- Fechar cursor
      IF cr_craplcs_nrdoc%ISOPEN THEN
        CLOSE cr_craplcs_nrdoc;
      END IF; 
        
      -- Insere lancamento
      BEGIN
        INSERT INTO craplcs(cdcooper
                           ,dtmvtolt
                           ,nrdconta
                           ,nrdocmto
                           ,vllanmto
                           ,cdhistor
                           ,nrdolote
                           ,cdbccxlt
                           ,cdagenci
                           ,flgenvio
                           ,flgopfin
                           ,dttransf
                           ,hrtransf
                           ,idopetrf
                           ,cdopetrf
                           ,cdopecrd
                           ,cdsitlcs
                           ,nrridlfp)
                    VALUES(pr_cdcooper
                          ,pr_rw_crapdat.dtmvtolt
                          ,rw_craplcs.nrdconta
                          ,vr_nrdocmto
                          ,rw_craplcs.vllanmto
                          ,vr_cdhisdev
                          ,vr_nrdlote
                          ,100 -- cdbccxlt
                          ,1   -- cdagenci
                          ,1   -- Enviado
                          ,1   -- Sim
                          ,trunc(pr_rw_crapdat.dtmvtolt) -- dttransf
                          ,gene0002.fn_busca_time -- hrtransf
                          ,rw_craplcs.idopetrf
                          ,'1'
                          ,'1'
                          ,1
                          ,rw_craplcs.nrridlfp);
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          vr_email_erro := SQLERRM;
          vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_estorno_automati_rejeicoes. Detalhes: ESTORNO TEC DE FOLHA – ' || vr_email_erro;
          RAISE vr_exc_erro;
      END;

      -- Atualizar lote
      BEGIN
        UPDATE craplot
           SET qtinfoln = qtinfoln + 1
              ,qtcompln = qtcompln + 1
              ,vlinfodb = vlinfodb + rw_craplcs.vllanmto
              ,vlcompdb = vlcompdb + rw_craplcs.vllanmto
              ,nrseqdig = nrseqdig + 1
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_rw_crapdat.dtmvtolt
           AND cdagenci = 1   -- cdagenci
           AND cdbccxlt = 100 -- cdbccxlt
           AND nrdolote = vr_nrdlote
           AND tplotmov = 1
     RETURNING nrseqdig
              ,qtinfoln
              ,qtcompln
              ,vlinfodb
              ,vlcompdb
              ,ROWID
         INTO rw_craplot.nrseqdig
             ,rw_craplot.qtinfoln
             ,rw_craplot.qtcompln
             ,rw_craplot.vlinfodb
             ,rw_craplot.vlcompdb
             ,rw_craplot.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          vr_email_erro := SQLERRM;
          vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_estorno_automati_rejeicoes. Detalhes: ESTORNO TEC DE FOLHA – ' || vr_email_erro;
          RAISE vr_exc_erro;
      END;

      -- Atualizar o lançamento de pagamento como Devolvido
      BEGIN
        UPDATE craplfp
           SET idsitlct = 'D'
              ,dsobslCt = 'Registro devolvido a empresa por Rejeição da TEC'
         WHERE cdcooper = pr_cdcooper
           AND progress_recid = rw_craplcs.nrridlfp;
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          vr_email_erro := SQLERRM;
          vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_estorno_automati_rejeicoes. Detalhes: ESTORNO TEC DE FOLHA – ' || vr_email_erro;
          RAISE vr_exc_erro;
      END;

      -- Buscamos a empresa do pagamento para o futuro lançamento de estorno
      OPEN cr_crapemp (pr_cdcooper => pr_cdcooper
                      ,pr_nrridlfp => rw_craplcs.nrridlfp);
      FETCH cr_crapemp INTO rw_crapemp;
      vr_hasfound := cr_crapemp%FOUND;
      CLOSE cr_crapemp;
      IF vr_hasfound THEN
        vr_chave := rw_crapemp.cdempres;
        IF tb_lancamentos.EXISTS(vr_chave) THEN
          tb_lancamentos(vr_chave).vllanmto := nvl(tb_lancamentos(vr_chave).vllanmto, 0) + rw_craplcs.vllanmto;
          tb_lancamentos(vr_chave).cdempres := rw_crapemp.cdempres;
          tb_lancamentos(vr_chave).nrdconta := rw_crapemp.nrdconta;
          tb_lancamentos(vr_chave).dsdemail := rw_crapemp.dsdemail;
        ELSE
          tb_lancamentos(vr_chave).vllanmto := rw_craplcs.vllanmto;
          tb_lancamentos(vr_chave).cdempres := rw_crapemp.cdempres;
          tb_lancamentos(vr_chave).nrdconta := rw_crapemp.nrdconta;
          tb_lancamentos(vr_chave).dsdemail := rw_crapemp.dsdemail;
        END IF;
      END IF;

      -- Atualiza o CRAPLCS selecionado como processado para evitar interações futuras
      BEGIN
        UPDATE craplcs lcs
           SET lcs.flgenvio = 1 -- Enviado
         WHERE ROWID = rw_craplcs.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          vr_email_erro := SQLERRM;
          vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_estorno_automati_rejeicoes. Detalhes: ESTORNO TEC DE FOLHA – EMP ' ||rw_crapemp.cdempres|| ' - ' || vr_email_erro;
          RAISE vr_exc_erro;
      END;
    END LOOP;
    -- busca o histórico para crédito na conta da empresa
    vr_cdhisest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'FOLHAIB_HIST_EST_TECSAL');

    vr_chave := tb_lancamentos.first;
    WHILE vr_chave IS NOT NULL LOOP
      -- Busca o LOTE de folha da empresa, através de busca na CRAPTAB:
      OPEN cr_craptab (pr_cdcooper => pr_cdcooper
                      ,pr_cdempres => tb_lancamentos(vr_chave).cdempres);
      FETCH cr_craptab INTO rw_craptab;
      vr_hasfound := cr_craptab%FOUND;
      CLOSE cr_craptab;

      IF NOT vr_hasfound THEN
        vr_email_erro := '060 - LOTE INEXISTENTE';
        vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_estorno_automati_rejeicoes. Detalhes: ESTORNO TEC DE FOLHA - EMP '||tb_lancamentos(vr_chave).cdempres||' - 060 - LOTE INEXISTENTE';
        RAISE vr_exc_erro;
      END IF;

      OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                      ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                      ,pr_nrdolote => rw_craptab.nrdolote);
      FETCH cr_craplot INTO rw_craplot;
      vr_hasfound := cr_craplot%FOUND;
      CLOSE cr_craplot;

      -- Se não existir
      IF NOT vr_hasfound THEN
        BEGIN -- Cria novo
          INSERT INTO craplot
                     (cdcooper
                     ,dtmvtolt
                     ,cdagenci
                     ,cdbccxlt
                     ,nrdolote
                     ,tplotmov
                     ,qtinfoln
                     ,qtcompln
                     ,vlinfocr
                     ,vlcompcr
                     ,nrseqdig)
              VALUES(pr_cdcooper
                    ,pr_rw_crapdat.dtmvtolt
                    ,1           -- cdagenci
                    ,100         -- cdbccxlt
                    ,rw_craptab.nrdolote
                    ,1
                    ,1
                    ,1
                    ,tb_lancamentos(vr_chave).vllanmto
                    ,tb_lancamentos(vr_chave).vllanmto
                    ,1)
           RETURNING nrseqdig
                    ,qtinfoln
                    ,qtcompln
                    ,vlinfocr
                    ,vlcompcr
                    ,nrseqdig
                    ,qtinfoln
                    ,qtcompln
                    ,vlinfodb
                    ,vlcompdb
                    ,ROWID
               INTO rw_craplot.nrseqdig
                   ,rw_craplot.qtinfoln
                   ,rw_craplot.qtcompln
                   ,rw_craplot.vlinfocr
                   ,rw_craplot.vlcompcr
                   ,rw_craplot.nrseqdig
                   ,rw_craplot.qtinfoln
                   ,rw_craplot.qtcompln
                   ,rw_craplot.vlinfodb
                   ,rw_craplot.vlcompdb
                   ,rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            vr_email_erro := '060 - LOTE INEXISTENTE';
            vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_estorno_automati_rejeicoes. Detalhes: ESTORNO TEC DE FOLHA - EMP '||tb_lancamentos(vr_chave).cdempres||' - 060 - LOTE INEXISTENTE';
            RAISE vr_exc_erro;
        END;
      ELSE -- Se existir, atualiza
        BEGIN
          UPDATE craplot
             SET qtinfoln = qtinfoln + 1
                ,qtcompln = qtcompln + 1
                ,vlinfocr = vlinfocr + tb_lancamentos(vr_chave).vllanmto
                ,vlcompcr = vlcompcr + tb_lancamentos(vr_chave).vllanmto
                ,nrseqdig = nrseqdig + 1
           WHERE cdcooper = pr_cdcooper
             AND dtmvtolt = pr_rw_crapdat.dtmvtolt
             AND cdagenci = 1
             AND cdbccxlt = 100
             AND nrdolote = rw_craptab.nrdolote
           RETURNING nrseqdig
                    ,qtinfoln
                    ,qtcompln
                    ,vlinfocr
                    ,vlcompcr
                    ,nrseqdig
                    ,qtinfoln
                    ,qtcompln
                    ,vlinfodb
                    ,vlcompdb
                    ,ROWID
               INTO rw_craplot.nrseqdig
                   ,rw_craplot.qtinfoln
                   ,rw_craplot.qtcompln
                   ,rw_craplot.vlinfocr
                   ,rw_craplot.vlcompcr
                   ,rw_craplot.nrseqdig
                   ,rw_craplot.qtinfoln
                   ,rw_craplot.qtcompln
                   ,rw_craplot.vlinfodb
                   ,rw_craplot.vlcompdb
                   ,rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            vr_email_erro := '060 - LOTE INEXISTENTE';
            vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_estorno_automati_rejeicoes. Detalhes: ESTORNO TEC DE FOLHA - EMP '||tb_lancamentos(vr_chave).cdempres||' - 060 - LOTE INEXISTENTE';
            RAISE vr_exc_erro;
        END;
      END IF;
      -- Cria a LCM do crédito na conta da empresa
      BEGIN
        INSERT INTO craplcm
                   (dtmvtolt
                   ,cdagenci
                   ,cdbccxlt
                   ,nrdolote
                   ,nrdconta
                   ,nrdctabb
                   ,nrdctitg
                   ,nrdocmto
                   ,cdhistor
                   ,vllanmto
                   ,nrseqdig
                   ,cdcooper)
             VALUES(pr_rw_crapdat.dtmvtolt
                   ,1
                   ,100
                   ,rw_craptab.nrdolote
                   ,tb_lancamentos(vr_chave).nrdconta
                   ,tb_lancamentos(vr_chave).nrdconta
                   ,gene0002.fn_mask(tb_lancamentos(vr_chave).nrdconta,'99999999') -- nrdctitg
                   ,rw_craplot.nrseqdig
                   ,vr_cdhisest
                   ,tb_lancamentos(vr_chave).vllanmto
                   ,rw_craplot.nrseqdig
                   ,pr_cdcooper);
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          vr_email_erro := SQLERRM;
          vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro nao tratado na rotina pc_estorno_automati_rejeicoes. Detalhes: ESTORNO TEC DE FOLHA - EMP '||tb_lancamentos(vr_chave).cdempres||' - ' || vr_email_erro;
          RAISE vr_exc_erro;
      END;
      -- Conteudo do e-mail informando para a empresa a devolução
      vr_email_corpo := 'Olá,<br> Houve(ram) problema(s) com o(s) lançamentos de folha de pagamento agendados em sua Conta-Online. <br>'||
                        'Com isso, efetuamos o estorno no valor total de R$ '||TO_CHAR(tb_lancamentos(vr_chave).vllanmto,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')|| '.<br>'||
                        'Para maiores detalhes dos problemas ocorridos, favor verificar sua Conta-Online ou acionar seu Posto de Atendimento. <br><br> ' ||
                        'Atenciosamente,<br>Sistema AILOS.';
      -- Enviar e-mail informando para a empresa a falta de saldo.
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'FOLH0001'
                                ,pr_des_destino     => TRIM(tb_lancamentos(vr_chave).dsdemail)
                                ,pr_des_assunto     => 'Folha de Pagamento - Estorno de Débito'
                                ,pr_des_corpo       => vr_email_corpo
                                ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      -- envia ao LOG
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'FOLH0001' 
                           , pr_cdcooper => pr_cdcooper
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Rotina pc_estorno_automati_rejeicoes. Detalhes: ESTORNO de TRFSAL REJEITADA - EMP ' || tb_lancamentos(vr_chave).cdempres || ' – CONTA ' || tb_lancamentos(vr_chave).nrdconta || ' – DEVOLUÇÃO TOTAL DE R$ ' || to_char(tb_lancamentos(vr_chave).vllanmto,'fm9g999g999g999g999g990d00') || ' EFETUADA COM SUCESSO. '
                           , pr_idprglog => vr_idprglog);
      
      -- Buscar próxim indice
      vr_chave := tb_lancamentos.next(vr_chave);
    END LOOP;

    -- Efetua Commit
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer a operacao
      ROLLBACK;
      -- envia ao LOG o problema ocorrido
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'FOLH0001' 
                           , pr_cdcooper => pr_cdcooper
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem => vr_dscritic
                           , pr_idprglog => vr_idprglog);      

      vr_email_destino := gene0001.fn_param_sistema('CRED',pr_cdcooper, 'FOLHAIB_EMAIL_ALERT_PROC') || ','
                       || gene0001.fn_param_sistema('CRED',pr_cdcooper, 'FOLHAIB_EMAIL_ALERT_FIN');
      vr_email_assunto := 'Folha de Pagamento – Problemas com o Estorno Automático das Rejeições/Devoluções TEC';
      vr_email_corpo   := 'Olá, encontramos problemas durante a rotina de estorno ' ||
                          'automático das rejeições/devoluções TEC não processadas ' ||
                          'pelo Financeiro. Todos os pagamentos permanecem pendentes ' ||
                          'e serão reprocessados em 30 minutos.' ||
                          '<br>' ||
                          '<br>' ||
                          'Detalhes do erro:' || vr_email_erro;
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'FOLH0001'
                                ,pr_des_destino     => vr_email_destino
                                ,pr_des_assunto     => vr_email_assunto
                                ,pr_des_corpo       => vr_email_corpo
                                ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'S' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      COMMIT;
      IF vr_dscritic IS NOT NULL THEN
        -- envia ao LOG o problema ocorrido
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                             , pr_cdprograma => 'FOLH0001' 
                             , pr_cdcooper => pr_cdcooper
                             , pr_tpexecucao => 0
                             , pr_tpocorrencia => 1 
                             , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_estorno_automati_rejeicoes. Detalhes: ESTORNO TEC DE FOLHA - ' || vr_dscritic
                             , pr_idprglog => vr_idprglog);
        
      END IF;
    WHEN OTHERS THEN
      -- Desfazer a operacao
      ROLLBACK;
      
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      
      -- envia ao LOG o problema ocorrido
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'FOLH0001' 
                           , pr_cdcooper => pr_cdcooper
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 1 
                           , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_estorno_automati_rejeicoes. Detalhes: ESTORNO TEC DE FOLHA –  GERAL - ' || SQLERRM
                           , pr_idprglog => vr_idprglog);

      vr_email_destino := gene0001.fn_param_sistema('CRED',pr_cdcooper, 'FOLHAIB_EMAIL_ALERT_PROC') || ','
                       || gene0001.fn_param_sistema('CRED',pr_cdcooper, 'FOLHAIB_EMAIL_ALERT_FIN');
      vr_email_assunto := 'Folha de Pagamento – Problemas com o Estorno Automático das Rejeições/Devoluções TEC';
      vr_email_corpo   := 'Olá, encontramos problemas durante a rotina de estorno ' ||
                          'automático das rejeições/devoluções TEC não processadas ' ||
                          'pelo Financeiro. Todos os pagamentos permanecem pendentes ' ||
                          'e serão reprocessados em 30 minutos.' ||
                          '<br>' ||
                          '<br>' ||
                          'Detalhes do erro:' || SQLERRM;
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'FOLH0001'
                                ,pr_des_destino     => vr_email_destino
                                ,pr_des_assunto     => vr_email_assunto
                                ,pr_des_corpo       => vr_email_corpo
                                ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'S' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      COMMIT;
      IF vr_dscritic IS NOT NULL THEN
        -- envia ao LOG o problema ocorrido
        CECRED.pc_log_programa(pr_dstiplog => 'O'
                             , pr_cdprograma => 'FOLH0001' 
                             , pr_cdcooper => pr_cdcooper
                             , pr_tpexecucao => 0
                             , pr_tpocorrencia => 1 
                             , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_estorno_automati_rejeicoes. Detalhes: ESTORNO TEC DE FOLHA - ' || vr_dscritic
                             , pr_idprglog => vr_idprglog);
        
      END IF;

  END pc_estorno_automati_rejeicoes;


  /* Procedure para realizar processamento de credito dos pagamentos aprovados */
  PROCEDURE pc_atualiza_xml_comprov_liquid(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                          ,pr_rw_crapdat IN BTCH0001.cr_crapdat%ROWTYPE) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_atualiza_xml_comprov_liquid             Antigo:
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Jaison
  --  Data     : Julho/2015.                   Ultima atualizacao: 27/01/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para atualizar o XML do comprovante liquido
  -- Alterações
  --            27/01/2016 - Incluir controle de lançamentos sem crédito (Marcos-Supero)
  ---------------------------------------------------------------------------------------------------------------

    -- Busca os dados do pagamento
    CURSOR cr_crappfp(pr_cdcooper crappfp.cdcooper%TYPE,
                      pr_dtcredit crappfp.dtcredit%TYPE) IS
      SELECT TRUNC(pfp.dthorcre) dthorcre
            , emp.cdempres
            , emp.nmextemp
            , emp.nrdocnpj
            , lfp.nrcpfemp
            , lfp.nrdconta
            , lfp.dsxmlenv
            , lfp.vllancto
            , lfp.rowid lfp_rowid
            , ofp.dsorigem
            , emp.idtpempr
            , CASE lfp.idtpcont
                WHEN 'C' THEN ass.nmprimtl
                ELSE ccs.nmfuncio
              END nmprimtl

         FROM crapemp emp
            , crappfp pfp
            , craplfp lfp
            , crapofp ofp
            , crapass ass
            , crapccs ccs

        WHERE emp.cdcooper = pfp.cdcooper
          AND emp.cdempres = pfp.cdempres
          AND pfp.cdcooper = lfp.cdcooper
          AND pfp.cdempres = lfp.cdempres
          AND pfp.nrseqpag = lfp.nrseqpag
          AND lfp.cdcooper = ofp.cdcooper
          AND lfp.cdorigem = ofp.cdorigem
          AND pfp.flsitcre IN (1,2)          --> Pagos
          AND lfp.idsitlct IN ('C','T') --> Creditado ou Transferido
          AND lfp.vllancto > 0
          AND pfp.cdcooper =  pr_cdcooper
          AND TRUNC(pfp.dthorcre) >= pr_dtcredit

          AND ass.cdcooper(+) = lfp.cdcooper
          AND ass.nrdconta(+) = lfp.nrdconta
          AND ass.nrcpfcgc(+) = lfp.nrcpfemp

          AND ccs.cdcooper(+) = lfp.cdcooper
          AND ccs.nrdconta(+) = lfp.nrdconta
          AND ccs.nrcpfcgc(+) = lfp.nrcpfemp;

    -- Variaveis
    vr_dtcredit crappfp.dtcredit%TYPE;
    vr_dsxmlenv VARCHAR2(32500); -- Auxiliar para XML

  BEGIN
    -- Seta a data atual
    vr_dtcredit := pr_rw_crapdat.dtmvtolt;

    FOR vr_index IN 1..2 LOOP
      -- Subtrai um dia
      vr_dtcredit := vr_dtcredit - 1;
      -- Caso seja final de semana/feriado busca a data anterior
      vr_dtcredit := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                ,pr_dtmvtolt => vr_dtcredit
                                                ,pr_tipo     => 'A');
    END LOOP;

    -- Listagem dos pagamentos
    FOR rw_crappfp IN cr_crappfp(pr_cdcooper => pr_cdcooper,
                                 pr_dtcredit => vr_dtcredit) LOOP
      -- Caso tenha conteudo passa para o proximo
      IF TRIM(rw_crappfp.dsxmlenv) IS NOT NULL THEN
        CONTINUE;
      END IF;

      -- Guarda o XML
      vr_dsxmlenv := '
      <xml>
        <head>
          <dtref>' || TO_CHAR(rw_crappfp.dthorcre,'DD/MM/RRRR') || '</dtref>
          <cdemp>' || rw_crappfp.cdempres || '</cdemp>
          <nmemp>' || rw_crappfp.nmextemp || '</nmemp>
          <nrdocnpj>' || GENE0002.fn_mask_cpf_cnpj(rw_crappfp.nrdocnpj,2) || '</nrdocnpj>
          <nrcpfcgc>' || GENE0002.fn_mask_cpf_cnpj(rw_crappfp.nrcpfemp,1) || '</nrcpfcgc>
          <cdfunc>' || GENE0002.fn_mask_conta(rw_crappfp.nrdconta) || '</cdfunc>
          <nmfunc>' || rw_crappfp.nmprimtl || '</nmfunc>
          <idtpemp>' || rw_crappfp.idtpempr || '</idtpemp>
          <tpcomprv>L</tpcomprv>
        </head>
        <body>
          <item>
            <cod></cod>
            <dscr>' || rw_crappfp.dsorigem || '</dscr>
            <refe></refe>
            <venc>' || TO_CHAR(rw_crappfp.vllancto, 'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.') || '</venc>
            <dsct></dsct>
          </item>
        </body>
      </xml>';

      BEGIN
        -- Atualiza o XML do lancamento
        UPDATE craplfp
           SET craplfp.dsxmlenv = vr_dsxmlenv
         WHERE ROWID = rw_crappfp.lfp_rowid;
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- Envia o erro para o LOG
          CECRED.pc_log_programa(pr_dstiplog => 'O'
                               , pr_cdprograma => 'FOLH0001' 
                               , pr_cdcooper => pr_cdcooper
                               , pr_tpexecucao => 0
                               , pr_tpocorrencia => 2 
                               , pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_atualiza_xml_comprov_liquid. Detalhes: COMPROV. SALARIO LIQ. – EMP ' || rw_crappfp.cdempres || ' – FUNC. ' || rw_crappfp.nrdconta || ' – ' || SQLERRM
                               , pr_idprglog => vr_idprglog);
         
      END;

    END LOOP; -- cr_crappfp

    -- Efetua Commit
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      -- Desfazer a operacao
      ROLLBACK;
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
  END pc_atualiza_xml_comprov_liquid;

  /* Esta rotina é acionada diretamente pelo Job */
  PROCEDURE pc_processo_controlador IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_processo_controlador             Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Lucas Afonso Lombardi Moreira
  --  Data     : Julho/2015.                   Ultima atualizacao: 22/12/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Esta rotina será acionada diretamente pelo Job que
  --             será submetido no banco e executado de 5 em 5 minutos.
  -- Alterações
  --             04/11/2015 - Passar a considerar o horário de operação do SPB
  --                          cadastrado na CADCOP para o processo de crédito - Marcos(Supero)
  --
  --             12/11/2015 - Chamar a rotina de tarifação na mesma frequencia do crédito (Marcos-Supero)
  --
  --             22/12/2015 - Chamar a rotina de debito na mesma frequencia do crédito (Marcos-Suoero)
  --
  --             25/10/2017 - Realizando o processamento dos pagamentos antigos cadastrados na tela SOL062,
  --                          para ajustar o problema relatado no chamado 654712 (Kelvin)
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Busca as cooperativas
  CURSOR cr_crapcop IS
    SELECT cdcooper
          ,nmrescop
          ,iniopstr+600 iniopstr -- 10 minutos depois
          ,fimopstr-600 fimopstr -- 10 minutos antes
      FROM crapcop
     WHERE flgativo = 1
       AND cdcooper <> 3;

  CURSOR cr_existe_folha_antiga(pr_cdcooper crapcop.cdcooper%TYPE
                               ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
    SELECT 1 
      FROM craplcs lcs
     WHERE lcs.cdcooper = pr_cdcooper
       AND lcs.dtmvtolt = pr_dtmvtolt
           -- FOLHA EMAIL   --> 560
           -- CAIXA ON-LINE --> 561
           -- FOLHA IBANK   --> gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'FOLHAIB_HIS_CRE_TECSAL')
       AND lcs.cdhistor IN(560,561,gene0001.fn_param_sistema('CRED',pr_cdcooper,'FOLHAIB_HIS_CRE_TECSAL'))         
       AND lcs.flgenvio = 0 --Nao enviado  
       AND lcs.nrridlfp = 0; --Folha velha
  rw_existe_folha_antiga cr_existe_folha_antiga%ROWTYPE; 
   
  -- Cursor generico de calendario
  rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;

  --Variaveis
  vr_cdcooper    crapcop.cdcooper%TYPE;
  vr_dtsemus     DATE;
  vr_dtexpest    DATE;
  vr_dtultest    DATE;
  vr_dtexppor    DATE;
  vr_dtultpor    DATE;
  vr_hrlimpor    DATE;
  vr_hrlimcop    DATE;
  vr_dtavispb    DATE;
  vr_dtcobtar    DATE;
  vr_hr_valid    BOOLEAN;
  vr_hasfound    BOOLEAN;

  -- Variaveis de Erro
  vr_cdcritic   crapcri.cdcritic%TYPE;
  vr_dscritic   VARCHAR2(4000);

  -- Variaveis Excecao
  vr_exc_erro EXCEPTION;

  vr_cdprogra    VARCHAR2(40) := 'PC_PROCESSO_CONTROLADOR';
  vr_nomdojob    VARCHAR2(40) := 'JBFOLHA_PROCESSO_CONTROLADOR';
  vr_flgerlog    BOOLEAN := FALSE;

  --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    --> Controlar geração de log de execução dos jobs 
    BTCH0001.pc_log_exec_job( pr_cdcooper  => 3    --> Cooperativa
                             ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                             ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                             ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                             ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                             ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
  END pc_controla_log_batch;

  BEGIN
    
    -- Log de inicio de execucao
    pc_controla_log_batch(pr_dstiplog => 'I');
  
    -- Faz laço com todas as cooperativas
    FOR rw_crapcop IN cr_crapcop LOOP
      BEGIN
        -- Grava codigo da cooperativa
        vr_cdcooper := rw_crapcop.cdcooper;

        -- Buscar a data do movimento
        OPEN btch0001.cr_crapdat(vr_cdcooper);
        FETCH btch0001.cr_crapdat INTO rw_crapdat;
        -- Verificar se existe informacao, e gerar erro caso nao exista
        vr_hasfound := btch0001.cr_crapdat%FOUND;
        -- Fechar o cursor
        CLOSE btch0001.cr_crapdat;
        IF NOT vr_hasfound THEN
          -- Gerar excecao
          vr_cdcritic := 1;
          vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Erro tratado na rotina pc_processo_controlador. Detalhes: PROCESSO CONTROLADOR – ' || gene0001.fn_busca_critica(vr_cdcritic);
          RAISE vr_exc_erro;
        END IF;

        -- A) Só pode ser executada dentro do horario padrao para transferencias no IB
        -- Buscar horario padrao para transferencias;
        -- B) A cooperativa não poderá estar com o processo em execução, isto pode
        -- ser verificado através de busca do campo inprocess na CRAPDAT;
        -- C) As rotinas só poderão ser executadas num dia útil;

        vr_hr_valid := fn_valida_hrtransfer(vr_cdcooper);

        IF vr_hr_valid AND
           rw_crapdat.inproces = 1 AND
           trunc(SYSDATE) = gene0005.fn_valida_dia_util(vr_cdcooper, SYSDATE) THEN

  -------- ROTINA 01 - Alerta ou cancelamento automático das empresas sem uso ------------------------

          -- Executada apenas uma vez por dia
          vr_dtsemus := to_date(gene0001.fn_param_sistema('CRED', vr_cdcooper, 'FOLHAIB_CHECK_SEM_USO'),'DD/MM/RRRR');

          IF vr_dtsemus IS NULL OR trunc(SYSDATE) > trunc(vr_dtsemus) THEN
            -- Atualiza ou cria o parâmetro FOLHAIB_CHECK_SEM_USO na tabela CRAPPRM,
            -- caso não exista ainda
            BEGIN
              UPDATE crapprm
                 SET dsvlrprm = to_char(SYSDATE,'DD/MM/RRRR')
               WHERE cdcooper = vr_cdcooper
                 AND nmsistem = 'CRED'
                 AND cdacesso = 'FOLHAIB_CHECK_SEM_USO';
              IF SQL%ROWCOUNT = 0 THEN
                INSERT INTO crapprm
                           (nmsistem
                           ,cdcooper
                           ,cdacesso
                           ,dsvlrprm)
                     VALUES('CRED'
                           ,vr_cdcooper
                           ,'FOLHAIB_CHECK_SEM_USO'
                           ,to_char(SYSDATE,'DD/MM/RRRR'));
              END IF;
            END;
            -- Efetua Commit
            COMMIT;
            -- Acionar a rotina 01 ************************************
            pc_aviso_cancel_emp_sem_uso(vr_cdcooper, rw_crapcop.nmrescop);
          END IF;

  -------- ROTINA 02 - Aprovação automática de estouros com saldo ------------------------------------

          -- Acionar a rotina 02
          pc_aprova_estouros_automatico (vr_cdcooper, rw_crapdat);

  -------- ROTINA 03 - Reprovação automática de estouros com horário de análise expirado -------------

          -- Busca o horário limite para análise de estouros
          vr_dtexpest := to_date(to_char(SYSDATE,'DD/MM/RRRR ') || gene0001.fn_param_sistema('CRED', vr_cdcooper,'FOLHAIB_HOR_LIM_ANA_EST'), 'DD/MM/RRRR HH24:MI');
          -- Se a hora atual for superior a hora retornada
          IF SYSDATE > vr_dtexpest THEN
            -- Busca a última execução de reprovação de estouros fora do horário
            vr_dtultest := to_date(gene0001.fn_param_sistema('CRED', vr_cdcooper, 'FOLHAIB_REPROV_EXPIRA'), 'DD/MM/RRRR HH24:MI:SS');
            IF vr_dtultest IS NULL OR -- se não existir o registro ou a data de expiração de estouro
               vr_dtexpest > vr_dtultest THEN --  for superior a ultima reprovação de estouros
              -- Atualiza o parâmetro FOLHAIB_REPROV_EXPIRA na tabela CRAPPRM, ou insere o
              --registro, caso ele ainda não exista
              BEGIN
                UPDATE crapprm
                   SET dsvlrprm = to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS')
                 WHERE cdcooper = 1
                   AND nmsistem = 'CRED'
                   AND cdacesso = 'FOLHAIB_REPROV_EXPIRA';
                IF SQL%ROWCOUNT = 0 THEN
                  INSERT INTO crapprm
                             (nmsistem
                             ,cdcooper
                             ,cdacesso
                             ,dsvlrprm)
                       VALUES('CRED'
                             ,vr_cdcooper
                             ,'FOLHAIB_REPROV_EXPIRA'
                             ,to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS'));
                END IF;
              END;
              -- Efetua Commit
              COMMIT;
              -- Acionar a rotina 03 **************************************
              pc_reprov_estouro_horario(vr_cdcooper);
            END IF;
          END IF;

  -------- ROTINA 04 - Alerta de créditos após a expiração da portabilidade --------------------------

          -- Busca o horário limite para portabilidade em folha
          vr_dtexppor := to_date(to_char(SYSDATE,'DD/MM/RRRR ') || gene0001.FN_param_sistema('CRED', vr_cdcooper,'FOLHAIB_HOR_LIM_PORTAB'), 'DD/MM/RRRR HH24:MI');
          -- Se a hora atual for superior a hora retornada
          IF SYSDATE > vr_dtexppor THEN
            -- Busca a ultima execução de alerta de portabilidade fora do horário
            vr_dtultpor := to_date(gene0001.fn_param_sistema('CRED',vr_cdcooper,'FOLHAIB_PORTAB_EXPIRA'),'DD/MM/RRRR HH24:MI:SS');
            IF vr_dtultpor IS NULL OR -- se não existir o registro ou a data de expiração de portabilidade
               vr_dtexppor > vr_dtultpor THEN --for superior a ultima vez que alertamos a expiracao da portabilidade
              -- Atualiza o parâmetro FOLHAIB_PORTAB_EXPIRA na tabela CRAPPRM, ou insere o
              -- registro, caso ele ainda não exista
              BEGIN
                UPDATE crapprm
                   SET dsvlrprm = to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS')
                 WHERE cdcooper = vr_cdcooper
                   AND nmsistem = 'CRED'
                   AND cdacesso = 'FOLHAIB_PORTAB_EXPIRA';
                IF SQL%ROWCOUNT = 0 THEN
                  INSERT INTO crapprm
                             (nmsistem
                             ,cdcooper
                             ,cdacesso
                             ,dsvlrprm)
                       VALUES('CRED'
                             ,vr_cdcooper
                             ,'FOLHAIB_PORTAB_EXPIRA'
                             ,to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS'));
                END IF;
              END;
              -- Efetua Commit
              COMMIT;
              -- Acionar a rotina 04
              pc_alerta_creditos_pendentes(vr_cdcooper, rw_crapdat);
            END IF;
          END IF;

  -------- ROTINA 05 - Débitos pendentes -------------------------------------------------------------
  -------- ROTINA 06 - Créditos pendentes ------------------------------------------------------------
  -------- ROTINA 06.01 - Créditos pendentes conta cooperativa ---------------------------------------
  -------- ROTINA 06.02 - Créditos pendentes conta ctasal --------------------------------------------
  -------- ROTINA 06.03 - Atualiza o XML do comprovante liquido --------------------------------------

            -- Acionar a rotina 05
            pc_debito_pagto_aprovados (vr_cdcooper, rw_crapdat);

          -- Horario limite para contas da cooperativa
          vr_hrlimcop := to_date(to_char(SYSDATE,'DD/MM/RRRR ') || gene0001.fn_param_sistema('CRED', vr_cdcooper, 'FOLHAIB_HOR_LIM_PAG_COOP'),'DD/MM/RRRR HH24:MI');
          
          IF vr_hrlimcop > SYSDATE AND FOLH0001.fn_valida_hrtransfer(vr_cdcooper, TO_DATE(TO_CHAR(SYSDATE,'HH24:MI'),'HH24:MI')) THEN

            -- Prepara mensgem de erro
            vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Rotina pc_processo_controlador. Detalhes: PROCESSO CONTROLADOR – ROTINA 06.01 - ';
            
            --Acionar a rotina 6.1
            pc_cr_pagto_aprovados_coop(vr_cdcooper, rw_crapdat);
            
            -- Busca do horário limite para a portabilidade
       	    vr_hrlimpor := to_date(to_char(SYSDATE,'DD/MM/RRRR ') || gene0001.fn_param_sistema('CRED', vr_cdcooper, 'FOLHAIB_HOR_LIM_PORTAB'),'DD/MM/RRRR HH24:MI');
            
            IF vr_hrlimpor > SYSDATE AND to_char(SYSDATE,'sssss') BETWEEN rw_crapcop.iniopstr AND rw_crapcop.fimopstr THEN
               
               vr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - FOLH0001 --> Rotina pc_processo_controlador. Detalhes: PROCESSO CONTROLADOR – ROTINA 06.01 - ';

               --Acionar a rotina 6.2
               pc_cr_pagto_aprovados_ctasal(vr_cdcooper, rw_crapdat);
               
               OPEN cr_existe_folha_antiga(pr_cdcooper => vr_cdcooper
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
                 FETCH cr_existe_folha_antiga
                   INTO rw_existe_folha_antiga;
                 
                 --Valida se há folhas antigas para serem processadas  
                 IF cr_existe_folha_antiga%FOUND THEN
                   CLOSE cr_existe_folha_antiga;
                   --Faz o processamanento dos pagamentos carregados pela tela SOL062 (Antigos)
                   SSPB0001.pc_trfsal_opcao_b(pr_cdcooper => vr_cdcooper
                                             ,pr_cdagenci => 0
                                             ,pr_nrdcaixa => 1
                                             ,pr_cdoperad => 1
                                             ,pr_cdempres => 0
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
               
                 ELSE
               CLOSE cr_existe_folha_antiga;
            END IF;

            END IF;

            -- Acionar a rotina 06.03
            pc_atualiza_xml_comprov_liquid(vr_cdcooper, rw_crapdat);
          END IF;

  -------- ROTINA 07 - Cobrança das tarifas pendentes -----------------------------------------------

          pc_cobra_tarifas_pendentes (vr_cdcooper, rw_crapdat);

  -------- ROTINA 08 - Conciliação dos pagamentos pendentes de devolução -----------------------------

          -- Busca a data e hora da última execucao nos parâmetros de sistema
          vr_dtcobtar := to_date(gene0001.fn_param_sistema('CRED',vr_cdcooper,'FOLHAIB_CONCILI_ESTORNO'),'DD/MM/RRRR HH24:MI:SS');

          -- Se a consulta nao retornar nada ou fizer mais de meia hora desde a ultima execucao
          IF vr_dtcobtar IS NULL OR
            ((SYSDATE - vr_dtcobtar) * 24) >= 0.5 THEN
            -- Atualiza o parâmetro FOLHAIB_CONCILI_ESTORNO na tabela CRAPPRM, ou insere o
            -- registro, caso ele ainda não exista
            BEGIN
              UPDATE crapprm
                 SET dsvlrprm = to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS')
               WHERE cdcooper = vr_cdcooper
                 AND nmsistem = 'CRED'
                 AND cdacesso = 'FOLHAIB_CONCILI_ESTORNO';
              IF SQL%ROWCOUNT = 0 THEN
                INSERT INTO crapprm
                           (nmsistem
                           ,cdcooper
                           ,cdacesso
                           ,dsvlrprm)
                     VALUES('CRED'
                           ,vr_cdcooper
                           ,'FOLHAIB_CONCILI_ESTORNO'
                           ,to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS'));
              END IF;
            END;
            -- Efetua Commit
            COMMIT;
            -- Acionar a rotina 08
            pc_concili_estornos_pendentes (vr_cdcooper, rw_crapdat);
          END IF;

  -------- ROTINA 09 - Estorno automático de rejeições TEC -------------------------------------------

          -- Busca a data e hora da última execucao nos parâmetros de sistema
          vr_dtcobtar := to_date(gene0001.fn_param_sistema('CRED',vr_cdcooper,'FOLHAIB_ESTORNO_TEC'),'DD/MM/RRRR HH24:MI:SS');

          -- Se a consulta nao retornar nada ou fizer mais de meia hora desde a ultima execucao
          IF vr_dtcobtar IS NULL OR
            ((SYSDATE - vr_dtcobtar) * 24) >= 0.5 THEN
            -- Atualiza o parâmetro FOLHAIB_ESTORNO_TEC na tabela CRAPPRM, ou insere o
            -- registro, caso ele ainda não exista
            BEGIN
              UPDATE crapprm
                 SET dsvlrprm = to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS')
               WHERE cdcooper = vr_cdcooper
                 AND nmsistem = 'CRED'
                 AND cdacesso = 'FOLHAIB_ESTORNO_TEC';
              IF SQL%ROWCOUNT = 0 THEN
                INSERT INTO crapprm
                           (nmsistem
                           ,cdcooper
                           ,cdacesso
                           ,dsvlrprm)
                     VALUES('CRED'
                           ,vr_cdcooper
                           ,'FOLHAIB_ESTORNO_TEC'
                           ,to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS'));
              END IF;
            END;
            -- Efetua Commit
            COMMIT;
            -- Acionar a rotina 09
            pc_estorno_automati_rejeicoes (vr_cdcooper, rw_crapdat);
          END IF;

  -------- ROTINA 10 - Alerta as 19:00 de TRFSAL sem retorno SPB -------------------------------------------

          -- Executada apenas uma vez por dia após as 19:00
          vr_dtavispb := to_date(gene0001.fn_param_sistema('CRED', vr_cdcooper, 'FOLHAIB_SEM_RETORN_SPB'),'DD/MM/RRRR');

          IF to_char(SYSDATE,'hh24:mi') > '19:00' AND (vr_dtavispb IS NULL OR trunc(SYSDATE) > trunc(vr_dtavispb))THEN
            -- Atualiza ou cria o parâmetro FOLHAIB_CHECK_SEM_USO na tabela CRAPPRM,
            -- caso não exista ainda
            BEGIN
              UPDATE crapprm
                 SET dsvlrprm = to_char(SYSDATE,'DD/MM/RRRR')
               WHERE cdcooper = vr_cdcooper
                 AND nmsistem = 'CRED'
                 AND cdacesso = 'FOLHAIB_SEM_RETORN_SPB';
              IF SQL%ROWCOUNT = 0 THEN
                INSERT INTO crapprm
                           (nmsistem
                           ,cdcooper
                           ,cdacesso
                           ,dsvlrprm)
                     VALUES('CRED'
                           ,vr_cdcooper
                           ,'FOLHAIB_SEM_RETORN_SPB'
                           ,to_char(SYSDATE,'DD/MM/RRRR'));
              END IF;
            END;
            -- Efetua Commit
            COMMIT;
            -- Acionar a rotina 01 ************************************
            pc_alerta_transf_penden_spb(vr_cdcooper, rw_crapdat);
          END IF;

  -----------------------------TERMINO DAS ROTINAS ---------------------------------------------------
        END IF;
      EXCEPTION
      WHEN vr_exc_erro THEN
        
        -- Log de erro de execucao
        pc_controla_log_batch(pr_dstiplog => 'E',
                              pr_dscritic => vr_dscritic);
      
        -- Desfazer a operacao
        ROLLBACK;

      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);

        -- Log de erro de execucao
        pc_controla_log_batch(pr_dstiplog => 'E',
                              pr_dscritic => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || 
                                             ' - FOLH0001 --> Rotina pc_processo_controlador.' || SQLERRM);
        -- Desfazer a operacao
        ROLLBACK;

      END;
    END LOOP;

    -- Log de fim da execucao
    pc_controla_log_batch(pr_dstiplog => 'F');

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer a operacao
      ROLLBACK;
    WHEN OTHERS THEN
      -- Desfazer a operacao
      ROLLBACK;
      
      CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);
      
  END pc_processo_controlador;

  -- Validar a combinação Conta + CPF
  PROCEDURE pc_valida_lancto_folha(pr_cdcooper  IN     crapass.cdcooper%TYPE --> Cooperativa
                                  ,pr_nrdconta  IN     crapass.nrdconta%TYPE --> Conta
                                  ,pr_nrcpfcgc  IN     crapass.nrcpfcgc%TYPE --> CPF
                                  ,pr_dtcredit  IN     DATE                  --> Data Credito
                                  ,pr_idtpcont  IN OUT VARCHAR2              --> Tipo (C-Conta ou T-CTASAL)
                                  ,pr_nmprimtl     OUT VARCHAR2              --> Nome
                                  ,pr_dsalerta     OUT VARCHAR2              --> Retornar alertas de validação
                                  ,pr_dscritic     OUT VARCHAR2) IS          --> Retornar erros da rotina

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_valida_lancto_folha             Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Renato Darosci
  --  Data     : Junho/2015.                   Ultima atualizacao: 25/09/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Esta rotina será acionada para validar a conta e CPF informado e retornar
  --             se a mesma é de uma associado (CRAPASS) ou CTASAL (CRAPCCS). Quando
  --             a rotina já recebe o tipo da conta, ela somente faz as validações de situação
  --             pois já sabe qual é seu tipo.
  --
  -- Alterações
  --             04/11/2015 - Não mais criticar situações 1,2,3,5,6 e 9 - Marcos(Supero)
  --
  --             22/04/2016 - Verificar a CRAPTRF sempre, não só quando pr_idtpcont for 
  --                          null - Marcos(Supero)
  --
  --             28/04/2016 - Retirada acentos por compatibilidade Ayllos Web (Guilherme/SUPERO)
  --
  --             25/09/2017 - verificar se o banco de destino da TEC esta ativo
  --                          (Douglas - chamado 647346)
  ---------------------------------------------------------------------------------------------------------------


    -- Buscar informações do associado
    CURSOR cr_crapass(pr_cdcooper  crapass.cdcooper%TYPE
                     ,pr_nrdconta  crapass.nrdconta%TYPE
                     ,pr_nrcpfcgc  crapass.nrcpfcgc%TYPE) IS
      SELECT t.cdsitdtl
           , t.nmprimtl
           , t.dtelimin
           , t.cdsitdct
           , t.dtdemiss
        FROM crapass t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND (t.nrcpfcgc = pr_nrcpfcgc OR pr_nrcpfcgc IS NULL);
    rw_crapass  cr_crapass%ROWTYPE;

    -- Busca possíveis transferencias e duplicacoes de matricula
    CURSOR cr_craptrf  IS
      SELECT trf.nrsconta
        FROM craptrf  trf
       WHERE trf.cdcooper = pr_cdcooper
         AND trf.nrdconta = pr_nrdconta
         AND trf.tptransa = 1  -- Transferencia
         AND trf.insittrs = 2; -- Feito
    rw_craptrf     cr_craptrf%ROWTYPE;

    -- Buscar contas de funcionarios optaram pela transferencia do salario para outra instituicao financeira
    CURSOR cr_crapccs(pr_cdcooper  crapass.cdcooper%TYPE
                     ,pr_nrdconta  crapass.nrdconta%TYPE
                     ,pr_nrcpfcgc  crapass.nrcpfcgc%TYPE) IS
      SELECT ccs.cdsitcta
           , ccs.nmfuncio
           , ccs.dtcantrf
           , ccs.cdbantrf
           , ccs.cdagetrf
           , ccs.nrctatrf
        FROM crapccs ccs
       WHERE ccs.cdcooper = pr_cdcooper
         AND ccs.nrdconta = pr_nrdconta
         AND (ccs.nrcpfcgc = pr_nrcpfcgc OR pr_nrcpfcgc IS NULL);
    rw_crapccs  cr_crapccs%ROWTYPE;

    -- Buscar informações da cooperativa
    CURSOR cr_crapcop(pr_cdagetrf   crapcop.cdagectl%TYPE) IS
      SELECT cop.*
        FROM crapcop cop
       WHERE cop.cdagectl = pr_cdagetrf;
     rw_crapcop    cr_crapcop%ROWTYPE;

    -- Buscar informações do associado
    CURSOR cr_assativ(pr_cdcooper  crapass.cdcooper%TYPE
                     ,pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT t.cdcooper
        FROM crapass t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND t.dtdemiss IS NULL;
    rw_assativ  cr_assativ%ROWTYPE;

    -- Verificar se o banco esta ativo
    CURSOR cr_crapban(pr_cdbccxlt crapban.cdbccxlt%TYPE) IS
      SELECT ban.cdbccxlt
        FROM crapban ban
       WHERE ban.cdbccxlt = pr_cdbccxlt
         AND ban.flgdispb = 1; 
    rw_crapban cr_crapban%ROWTYPE; 
    --
    vr_hrlimpor   VARCHAR2(5);    -- Horario Portabilidade
    vr_inestcri   NUMBER;         -- Pj 475 - Marcelo Telles Coelho - Mouts - 16/05/2019
    vr_clobxmlc   CLOB;           -- Pj 475 - Marcelo Telles Coelho - Mouts - 16/05/2019
  BEGIN

    -- Pj 475 - Marcelo Telles Coelho - Mouts - 16/05/2019
    -- Busca o indicador estado de crise
    sspb0001.pc_estado_crise (pr_inestcri => vr_inestcri
                             ,pr_clobxmlc => vr_clobxmlc);
    -- Fim Pj 475
    -- Se não veio parametro de tipo de conta
    IF pr_idtpcont IS NULL THEN
      -- Buscar associado
      OPEN  cr_crapass(pr_cdcooper
                      ,pr_nrdconta
                      ,pr_nrcpfcgc);
      FETCH cr_crapass INTO rw_crapass;

      -- Se encontrar registro
      IF cr_crapass%FOUND THEN

          CLOSE cr_crapass;
        pr_idtpcont := 'C'; -- Associado

      -- Se NÃO encontrou CRAPASS
      ELSE
        CLOSE cr_crapass; 
        -- Se não encontrou a crapass temos que testar se há CTASAL
        OPEN  cr_crapccs(pr_cdcooper
                        ,pr_nrdconta
                        ,pr_nrcpfcgc);
        FETCH cr_crapccs INTO rw_crapccs;

        -- Se não encontrou CRAPCCS -> Deve validar o dígito da conta informado
        IF cr_crapccs%NOTFOUND THEN

          -- Retornar a crítica de associado não cadastrado
          pr_dsalerta := 'Conta e CPF divergentes!';

          CLOSE cr_crapccs;

          -- Saida rotina
          RETURN;

        ELSE
          CLOSE cr_crapccs;
          pr_idtpcont := 'T'; -- CTASAL
        END IF;
      END IF;
    END IF;

    -- Limpar registros
    rw_crapass := NULL;

    -- Conforme o tipo de conta informado ou encontrado, realizar as validações
    IF pr_idtpcont = 'C' THEN -- Para associados

      -- Buscar dados da CRAPASS
      OPEN cr_crapass(pr_cdcooper
                      ,pr_nrdconta
                     ,pr_nrcpfcgc);
      FETCH cr_crapass INTO rw_crapass;
      
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;        
        pr_dsalerta := 'Associado não cadastrado';  
        RETURN;     
      END IF;
      
      CLOSE cr_crapass;      

      -- Guarda o nome encontrado
      pr_nmprimtl := rw_crapass.nmprimtl;

      -- Se encontrar dtelimin
      IF rw_crapass.dtelimin IS NOT NULL THEN
        -- Retorna o alerta com a crítica
        pr_dsalerta := 'Associado excluido';
        RETURN;
      END IF;

      -- Valida conforme a situação do cadastro
      IF rw_crapass.cdsitdtl IN (7,8) THEN
        -- Retorna o alerta com a crítica
        pr_dsalerta := 'Conta com prejuizo nao pode ser utilizada!';
        RETURN;
      END IF;

      -- Verifica a situação da conta
      IF (rw_crapass.cdsitdct IN (4) OR rw_crapass.dtdemiss IS NOT NULL) THEN
        -- Retorna o alerta com a crítica
        pr_dsalerta := 'Conta encerrada';
        RETURN;
      END IF;

      -- Conforme a situação do titular
      IF rw_crapass.cdsitdtl IN (2,4,6,8) THEN
        -- Buscar possíveis transferencias de conta
        OPEN  cr_craptrf;
        FETCH cr_craptrf INTO rw_craptrf;

        -- Se não encontrarmos nenhum registro
        IF cr_craptrf%NOTFOUND THEN
          -- Retornar mensagem de alerta de validação
          pr_dsalerta := 'Titular da conta bloqueado';
        ELSE
          -- Retornar mensagem de alerta de validação
          pr_dsalerta := 'Titular com conta transferida, utilizar a conta: '||rw_craptrf.nrsconta;
        END IF;

        CLOSE cr_craptrf;
        
        -- Sai da procedure retornando um dos alertas acima
        RETURN;
      END IF;


    ELSIF pr_idtpcont = 'T' THEN -- Para CTASAL

      -- Buscar as informações de CTASAL
      OPEN  cr_crapccs(pr_cdcooper
                      ,pr_nrdconta
                      ,NULL);
      FETCH cr_crapccs INTO rw_crapccs;
      
      IF cr_crapccs%NOTFOUND THEN
        CLOSE cr_crapccs;        
        pr_dsalerta := 'Conta não cadastrada!';
        RETURN;        
      END IF;
      
      CLOSE cr_crapccs;

      -- Retornamos o nome
      pr_nmprimtl := rw_crapccs.nmfuncio;

      -- Verifica situação
      IF rw_crapccs.cdsitcta = 2 THEN
        -- Retorna o alerta com a crítica
        pr_dsalerta := 'Conta com situacao invalida!';
        RETURN;
      END IF;

      -- Conta cancelada
      IF rw_crapccs.dtcantrf IS NOT NULL THEN
        -- Retorna o alerta com a crítica
        pr_dsalerta := 'Conta cancelada!';
        RETURN;
      END IF;

      -- Se for CTASAL e banco 085  ( Lógica copiada da BO 151 - Valida_Conta_Salario )
      IF rw_crapccs.cdbantrf = 85 THEN

        -- Registro da coop conforme agencia de controle
        OPEN  cr_crapcop(rw_crapccs.cdagetrf);
        FETCH cr_crapcop INTO rw_crapcop;
        CLOSE cr_crapcop;

        -- Buscar conta da trasferencia
        OPEN  cr_crapass(rw_crapcop.cdcooper
                        ,rw_crapccs.nrctatrf
                        ,NULL);
        FETCH cr_crapass INTO rw_crapass;

        -- Se encontrou registro
        IF cr_crapass%FOUND THEN
          -- Fechar o cursor
          CLOSE cr_crapass;
          -- Se encontrar dtelimin
          IF rw_crapass.dtelimin IS NOT NULL THEN
            -- Retorna o alerta com a crítica
            pr_dsalerta := 'Conta para transferencia excluida';
            RETURN;
          END IF;
          -- Valida conforme a situação do cadastro
          IF rw_crapass.cdsitdtl IN (7,8) THEN
            -- Retorna o alerta com a crítica
            pr_dsalerta := 'Conta com transferencia possui prejuizo!';
            RETURN;
          END IF;
          -- Verifica a situação da conta
          IF (rw_crapass.cdsitdct IN (4) OR rw_crapass.dtdemiss IS NOT NULL) THEN
            -- Retorna o alerta com a crítica
            pr_dsalerta := 'Conta para transferencia esta encerrada';
            RETURN;
          END IF;
        ELSE
          -- Fechar o cursor
          CLOSE cr_crapass;
          -- Retorna o alerta com a crítica
          pr_dsalerta := 'Conta inexistente na cooperativa informada';
          RETURN;
        END IF;

        -- Buscar associado ativo
        OPEN  cr_assativ(rw_crapcop.cdcooper
                        ,pr_nrcpfcgc);
        FETCH cr_assativ INTO rw_assativ;
        -- Se encontrar registros
        IF cr_assativ%FOUND THEN
          -- Fechar o cursor
          CLOSE cr_assativ;
          -- Verifica a cooperativa
          IF rw_assativ.cdcooper = pr_cdcooper THEN
            -- Retorna o alerta com a crítica
            pr_dsalerta := 'Somente pode ser transferido para conta'||
                           ' com CPF diferente ou para outra cooperativa.';
            RETURN;
          END IF;
        END IF;

        -- Se o cursor estiver aberto
        IF cr_assativ%ISOPEN THEN
          CLOSE cr_assativ;
        END IF;

      ELSE
        
        -- Verificar se o banco que vai receber o credito esta ativo
        OPEN cr_crapban (pr_cdbccxlt => rw_crapccs.cdbantrf);
        FETCH cr_crapban INTO rw_crapban;
        
        IF cr_crapban%NOTFOUND THEN
          -- Fechar Cursor 
          CLOSE cr_crapban;
          -- Retorna o alerta com a crítica
          pr_dsalerta := 'Banco destino ' || rw_crapccs.cdbantrf || ' inativo. ' || 
                         'Entre em contato com seu PA.';
          RETURN;
        ELSE 
          -- Fechar cursor
          CLOSE cr_crapban;
      END IF;
        --
        -- Pj 475 - Marcelo Telles Coelho - Mouts - 16/05/2019
        -- Definir a situação como Erro quando for Intercompany e estado de crise ligado
        IF vr_inestcri > 0 THEN
          pr_dsalerta := 'Erro encontrado - Estado de Crise Ativo';
          RETURN;
        END IF;
        -- Fim Pj 475
      END IF;

      -- Busca do horário limite para a portabilidade
      vr_hrlimpor := gene0001.fn_param_sistema('CRED', Pr_cdcooper, 'FOLHAIB_HOR_LIM_PORTAB');
             
      -- não deixar fazer a folha ctasal caso o horario estrapole
      IF vr_hrlimpor < TO_CHAR(SYSDATE,'HH24:MI') AND TO_DATE(PR_dtcredit,'DD/MM/YYYY') = TO_DATE(sysdate,'DD/MM/YYYY') THEN        
         pr_dsalerta := 'Pagamentos para outras instituicoes so podem ser feitos ate as '||vr_hrlimpor;
         RETURN;
    END IF;
      
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      pr_dscritic := 'Erro na PC_VALIDA_LANCTO_FOLHA: '||SQLERRM;
  END pc_valida_lancto_folha;

  /* Rotina para a validação do arquivo de folha - Através do AyllosWeb */
  PROCEDURE pc_valida_arq_folha_web(pr_nrdconta   IN NUMBER              --> Número da conta
                                   ,pr_dsarquiv   IN VARCHAR2            --> Informações do arquivo
                                   ,pr_dsdireto   IN VARCHAR2            --> Informações do diretório do arquivo
                                   ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_valida_arq_folha_web                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Renato Darosci - SUPERO
  --  Data     : Maio/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Rotina para a validação do arquivo de folha
  --
  ---------------------------------------------------------------------------------------------------------------

    -- Variáveis
    vr_cdcooper    NUMBER;
    vr_nmdatela    VARCHAR2(25);
    vr_nmeacao     VARCHAR2(25);
    vr_cdagenci    VARCHAR2(25);
    vr_nrdcaixa    VARCHAR2(25);
    vr_idorigem    VARCHAR2(25);
    vr_cdoperad    VARCHAR2(25);
    vr_retxml      CLOB;

    vr_excerror    EXCEPTION;

  BEGIN

    -- Extrair informacoes padrao do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);

    -- Se houve erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_excerror;
    END IF;

    -- Realiza a chamada da rotina
    pc_valida_arq_folha_ib(pr_cdcooper => vr_cdcooper
                          ,pr_idorigem => vr_idorigem
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_dsarquiv => pr_dsarquiv
                          ,pr_dsdireto => pr_dsdireto
                          ,pr_dssessao => NULL
                          ,pr_dtcredit => NULL -- Valida apenas para IB
                          ,pr_iddspscp => 0
                          ,pr_dscritic => pr_dscritic
                          ,pr_retxml   => vr_retxml);

    -- Se houve erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_excerror;
    END IF;

    -- Cria o XML de retorno
    pr_retxml := XMLType.createXML(vr_retxml);

  EXCEPTION
    WHEN vr_excerror THEN
      pr_des_erro := pr_dscritic;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);
      pr_dscritic := 'Erro geral na rotina pc_valida_arq_folha_web: '||SQLERRM;
      pr_des_erro := pr_dscritic;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_valida_arq_folha_web;

  /* Rotina para a validação do arquivo de folha - Através do IB */
  PROCEDURE pc_valida_arq_folha_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                  ,pr_idorigem  IN NUMBER
                                  ,pr_nrdconta  IN NUMBER
                                  ,pr_dsarquiv  IN VARCHAR2
                                  ,pr_dsdireto  IN VARCHAR2
                                  ,pr_dssessao  IN VARCHAR2 -- Passar NULL quando origem for diferente de 3 - Internet Banking
                                  ,pr_dtcredit  IN VARCHAR2
                                  ,pr_iddspscp  IN NUMBER
                                  ,pr_dscritic  OUT VARCHAR2
                                  ,pr_retxml    OUT CLOB) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_valida_arq_folha_ib                  Antigo: Não há
  --  Sistema  : IB
  --  Sigla    : CRED
  --  Autor    : Renato Darosci - SUPERO
  --  Data     : Maio/2015.                   Ultima atualizacao: 12/08/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Rotina para a validação do arquivo de folha
  --
  -- Alterações:
  --             27/10/2015 - Remoção de campos não utilizados (Marcos-Supero)
  --
  --             04/11/2015 - Validar somente a raiz do CNPJ (Marcos-Supero)
  --
  --             16/12/2015 - Inclusão de validação para lotes vazios (Marcos-Supero)
  --
  --             27/01/2016 - Incluir controle de lançamentos sem crédito (Marcos-Supero)
  --
  --             04/03/2016 - Incluido validacao para não permitir numero no CPF com mais de 11 digito
  --                          (Odirlei-AMcom)  
  --
  --             24/08/2017 - Fechar cursor cr_crapofp caso ele ja esteja aberto (Lucas Ranghetti #729039)
  --
  --             12/08/2019 - Criticar "Nosso Número" zerado no arquivo CNAB 240 pelo IB. Rafael Ferreira (Mouts)
  ---------------------------------------------------------------------------------------------------------------

    -- CURSORES
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.dsdircop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;  
        
    -- Buscar os dados de Origens para Pagamentos de Folha
    CURSOR cr_crapofp(pr_cdcooper  crapofp.cdcooper%TYPE
                     ,pr_cdorigem  crapofp.cdorigem%TYPE) IS
      SELECT ofp.cdhisdeb
           , ofp.cdhiscre
           , ofp.cdhsdbcp
           , ofp.cdhscrcp
           , ofp.cdorigem
           , ofp.dsorigem
           , ofp.idvarmes
        FROM crapofp ofp
       WHERE ofp.cdcooper = pr_cdcooper
         AND ofp.cdorigem = pr_cdorigem;
    rw_crapofp     cr_crapofp%ROWTYPE;

    -- Busca dados da empresa/conta logada
    CURSOR cr_crapemp(pr_cdcooper  crapemp.cdcooper%TYPE
                     ,pr_nrdconta  crapemp.nrdconta%TYPE) IS
      SELECT emp.idtpempr
           , SUBSTR(LPAD(emp.nrdocnpj,14,0),1,8) nrdocnpj
           , emp.cdempres
        FROM crapemp emp
       WHERE emp.cdcooper = pr_cdcooper
         AND emp.nrdconta = pr_nrdconta;

    -- Buscar dados para validar registro repetidos
    CURSOR cr_verifica(pr_cdcooper    crappfp.cdcooper%TYPE
                      ,pr_cdempres    crappfp.cdempres%TYPE
                      ,pr_dtcredit    crappfp.dtcredit%TYPE
                      ,pr_nrdconta    craplfp.nrdconta%TYPE
                      ,pr_cdorigem    craplfp.cdorigem%TYPE) IS
      SELECT COUNT(1)
        FROM craplfp lfp
           , crappfp pfp
       WHERE pfp.cdcooper = lfp.cdcooper
         AND pfp.cdempres = lfp.cdempres
         AND pfp.nrseqpag = lfp.nrseqpag
         AND pfp.cdcooper             = pr_cdcooper
         AND pfp.cdempres             = pr_cdempres
         AND TRUNC(pfp.dtcredit,'MM') = TRUNC(pr_dtcredit,'MM')
         AND lfp.nrdconta             = pr_nrdconta
         AND lfp.cdorigem             = pr_cdorigem;

    -- Registros
    TYPE typ_reccritc IS RECORD (nrdlinha NUMBER
                                ,dsdconta VARCHAR2(20)
                                ,dscpfcgc VARCHAR2(20)
                                ,dsorigem VARCHAR2(50)
                                ,dscritic VARCHAR2(100)
                                ,vlrpagto VARCHAR2(50)
                                ,inderror NUMBER);
    TYPE typ_reclfp   IS RECORD (nrseqlfp NUMBER
                                ,nrdconta NUMBER
                                ,idtpcont VARCHAR2(5)
                                ,nrcpfemp NUMBER
                                ,vllancto NUMBER
                                ,cdorigem VARCHAR2(20)
                                ,dsorigem VARCHAR2(50));
    TYPE typ_tablfp   IS TABLE OF typ_reclfp   INDEX BY BINARY_INTEGER;
    TYPE typ_tabpfp   IS RECORD (qtlctpag NUMBER
                                ,qtregpag NUMBER
                                ,vllctpag NUMBER
                                ,tbreglfp typ_tablfp);
    TYPE typ_tbcritic IS TABLE OF typ_reccritc INDEX BY BINARY_INTEGER;
    TYPE typ_tbdescri IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
    TYPE typ_tbdatpgt IS TABLE OF typ_tabpfp INDEX BY BINARY_INTEGER;
    vr_tbarquiv    typ_tbdescri; -- Tabela com as linhas do arquivo
    vr_tbcritic    typ_tbcritic; -- Tabela de criticas encontradas na validação do arquivo
    vr_tbdatpgt    typ_tbdatpgt;

    -- Variaveis
    vr_excerror    EXCEPTION;

    vr_dsdireto    VARCHAR2(100);
    vr_dsdirgra    VARCHAR2(100);
    vr_dsdlinha    VARCHAR2(500);
    vr_dscrilot    VARCHAR2(500); -- Critica a ser replicada no arquivo
    vr_dscriarq    VARCHAR2(500); -- Critica a ser replicada no arquivo
    vr_dscritic    VARCHAR2(500); -- Critica
    vr_typ_said    VARCHAR2(50); -- Critica
    vr_des_erro    VARCHAR2(500); -- Critica
    vr_dsalert     VARCHAR2(500); -- Critica
    vr_tpregist    NUMBER;
    vr_qtlinhas    NUMBER;
    vr_indatpgt    NUMBER;
    vr_inreglfp    NUMBER;
    vr_idtrllot    BOOLEAN := TRUE;
    vr_idtrlarq    BOOLEAN;
    vr_idcrirga    BOOLEAN; -- Indicar critica na linha A

    vr_tpservic    crapofp.cdorigem%TYPE;
    vr_idtpempr    crapemp.idtpempr%TYPE;
    vr_nrdocnpj    crapemp.nrdocnpj%TYPE;
    vr_cdempres    crapemp.cdempres%TYPE;
    vr_nrcpfcgc    crapass.nrcpfcgc%TYPE;
    vr_nmprimtl    crapass.nmprimtl%TYPE;
    vr_idtpcont    VARCHAR2(1);
    vr_cddbanco    NUMBER;
    vr_idremess    NUMBER;
    vr_nrdconta    NUMBER;
    vr_vlrpagto    NUMBER;
    vr_vltotpag    NUMBER;
    vr_qtdregok    NUMBER;
    vr_qtregerr    NUMBER;
    vr_qttotalr    NUMBER;
    vr_qtalerta    NUMBER;
    vr_nossonum    NUMBER; -- Nosso Numero do arquivo da Febraban
    vr_nmarquiv    VARCHAR2(100); -- Nome do arquivo gerado para gravação dos dados

    vr_utlfileh    UTL_FILE.file_type;
    vr_clitmxml    CLOB;
    vr_dsitmxml    VARCHAR2(32767);

    vr_retxml      XMLType;
    vr_dsauxml     varchar2(32767);

    vr_id_conta_monitorada NUMBER;
    vr_cdcritic NUMBER;
    
    -- Procedure auxiliar para adicionar as criticas do arquivo
    PROCEDURE pc_add_critica(pr_dscritic IN VARCHAR2
                            ,pr_nrdlinha IN NUMBER
                            ,pr_dsdconta IN VARCHAR2
                            ,pr_dscpfcgc IN VARCHAR2
                            ,pr_dsorigem IN VARCHAR2
                            ,pr_vlrpagto IN VARCHAR2
                            ,pr_inderror IN BOOLEAN) IS

      nrindice    NUMBER;

    BEGIN
      -- Indice para inclusão da crítica
      nrindice := vr_tbcritic.count() + 1;

      -- Inserir a critica no registro de memória
      vr_tbcritic(nrindice).nrdlinha := pr_nrdlinha;
      vr_tbcritic(nrindice).dscritic := pr_dscritic;
      vr_tbcritic(nrindice).dsdconta := TRIM(pr_dsdconta);
      vr_tbcritic(nrindice).dscpfcgc := TRIM(pr_dscpfcgc);
      vr_tbcritic(nrindice).dsorigem := pr_dsorigem;

      BEGIN
        vr_tbcritic(nrindice).vlrpagto := to_char((to_number(TRIM(pr_vlrpagto))/100),'FM9G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.');
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          vr_tbcritic(nrindice).vlrpagto := TRIM(pr_vlrpagto);
      END;

      -- Guarda a indicação de erro ou sucesso
      IF pr_inderror THEN
        vr_tbcritic(nrindice).inderror := 1;
      ELSE
        vr_tbcritic(nrindice).inderror := 0; -- Registro de sucesso
      END IF;

    END pc_add_critica;

  BEGIN

    --> Verificar cooperativa
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);    
    FETCH cr_crapcop INTO rw_crapcop;
      
    --> verificar se encontra registro
    IF cr_crapcop%NOTFOUND THEN      
      CLOSE cr_crapcop;    
        
      pr_dscritic := 'Cooperativa de destino nao cadastrada.';      
      RAISE vr_excerror;      
    ELSE
      CLOSE cr_crapcop;
    END IF;   

    -- ranghetti
    -- Verificar se conta esta bloqueada judicialmente (RITM0034650)
    BEGIN
      blqj0002.pc_verifica_conta_bloqueio(pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_id_conta_monitorada => vr_id_conta_monitorada,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);

      IF vr_id_conta_monitorada = 1 THEN
        pr_dscritic := 'Conta liberada apenas para consultas. Para mais informações entre'
                    || ' em contato com o SAC ou pelo Chat e informe o código BLQ01.';
        RAISE vr_excerror;  
      END IF;
    END;

    IF pr_iddspscp = 0 THEN -- Diretorio de upload do gnusites
    -- Busca o diretório do upload do arquivo
    vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => 'upload');

    -- Realizar a cópia do arquivo
    GENE0001.pc_OScommand_Shell(gene0001.fn_param_sistema('CRED',0,'SCRIPT_RECEBE_ARQUIVOS')||pr_dsdireto||pr_dsarquiv||' S'
                               ,pr_typ_saida   => vr_typ_said
                               ,pr_des_saida   => vr_des_erro);

    -- Testar erro
    IF vr_typ_said = 'ERR' THEN
      -- O comando shell executou com erro, gerar log e sair do processo
      pr_dscritic := 'Erro realizar o upload do arquivo: ' || vr_des_erro;
      RAISE vr_excerror;
    END IF;
    ELSE
      vr_dsdireto := gene0001.fn_diretorio('C',0)                                ||
                     gene0001.fn_param_sistema('CRED',0,'PATH_DOWNLOAD_ARQUIVO') ||
                     '/'                                                         ||
                     rw_crapcop.dsdircop                                         ||
                     '/upload';
    END IF;

    -- Verifica se o arquivo existe
    IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdireto||'/'||pr_dsarquiv) THEN
      -- Retorno de erro
      pr_dscritic := 'Erro no upload do arquivo: '||REPLACE(vr_dsdireto,'/','-')||'-'||pr_dsarquiv;
      RAISE vr_excerror;
    END IF;

    -- Criar cabecalho do XML
    vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    -- Abrir o arquivos
    GENE0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto
                            ,pr_nmarquiv => pr_dsarquiv
                            ,pr_tipabert => 'R'
                            ,pr_utlfileh => vr_utlfileh
                            ,pr_des_erro => pr_dscritic);

    -- Verifica se houve erros na abertura do arquivo
    IF pr_dscritic IS NOT NULL THEN
      pr_dscritic := 'Erro ao abrir o arquivo: '||pr_dsarquiv;
      RAISE vr_excerror;
    END IF;

    -- Se o arquivo estiver aberto
    IF utl_file.IS_OPEN(vr_utlfileh) THEN

      -- Percorrer as linhas do arquivo
      LOOP
        -- Limpa a variável que receberá a linha do arquivo
        vr_dsdlinha := NULL;

        BEGIN
          -- Lê a linha do arquivo
          GENE0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsdlinha);

          -- Eliminar possíveis espaços das linhas
          vr_dsdlinha := REPLACE(REPLACE(vr_dsdlinha,chr(10),NULL),chr(13), NULL);

        EXCEPTION
          WHEN no_data_found THEN
            -- Acabou a leitura, então finaliza o loop
            EXIT;
        END;

        -- Copia a linha do arquivo para a tabela de memória
        vr_tbarquiv( vr_tbarquiv.COUNT() + 1 ) := vr_dsdlinha;

      END LOOP; -- Finaliza o loop das linhas do arquivo

      -- Fechar o arquivo
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);

    END IF;

    -- Excluir o arquivo, pois desse ponto em diante irá trabalhar com o registro
    -- de memória. Em caso de erros o programa abortará e o usuário irá realizar
    -- novamente o envio do arquivo
    GENE0001.pc_OScommand_Shell('rm ' || vr_dsdireto || '/' || pr_dsarquiv);

    -- Se não houverem dados no registro de memória
    IF vr_tbarquiv.COUNT() = 0 THEN
      pr_dscritic := 'Dados não encontrados no arquivo.';
      RAISE vr_excerror;
    END IF;

    -- Verifica se a origem é internet Banking
    IF pr_idorigem = 3 THEN
      -- Buscar dados da empresa/conta logada
      OPEN  cr_crapemp(pr_cdcooper, pr_nrdconta);
      FETCH cr_crapemp INTO vr_idtpempr
                          , vr_nrdocnpj
                          , vr_cdempres;
      -- Se não encontrar registro
      IF cr_crapemp%NOTFOUND THEN
        pr_dscritic := 'Dados da empresa não encontrados.';
        RAISE vr_excerror;
      END IF;
      CLOSE cr_crapemp;
    END IF;

    -- Percorrer todos os registros da tabela de memória
    FOR ind IN vr_tbarquiv.FIRST()..vr_tbarquiv.last() LOOP

      -- Verifica se a linha possui a quantidade de caracteres padrão
      IF length(vr_tbarquiv(ind)) <> 240 THEN
        pr_dscritic := 'Linha '||ind||' com tamanho inválido.';
        RAISE vr_excerror;
      END IF;

      /** TIPO DO REGISTRO **/
      -- Verificar se o tipo do registro é numerico
      BEGIN
        vr_tpregist := to_number(substr(vr_tbarquiv(ind), 8, 1));
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- Erro
          pr_dscritic := 'Tipo do registro inválido! Linha: '||ind||'.';
          -- Adiciona a crítica
          RAISE vr_excerror;
      END;

      -- Verificar o tipo de registro - Sendo 0-header ou 9-trailer, ignora a mesma
      IF vr_tpregist = 0 THEN
        -- Verificar o código do banco é numerico - Posição 1 - Apenas validar não grava este campo
        BEGIN
          vr_cddbanco := to_number(substr(vr_tbarquiv(ind),1,3));
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar CNPJ divergente do cadastro da empresa
            vr_dscriarq := 'Banco inválido no header do arquivo!';
            CONTINUE;
        END;
        
        BEGIN
          vr_idremess := to_number(substr(vr_tbarquiv(ind),143,1));
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
            vr_dscriarq := 'Identificador de remessa inválido!';
            CONTINUE;
        END;

        IF vr_idremess <> 1 THEN         
          pr_dscritic := 'Arquivo importado nao e do tipo Remessa';
          -- Adiciona a crítica
          RAISE vr_excerror;       
        END IF;
        
        -- Verifica se o código do banco é 85 - Validando o inicio da linha
        -- Comentado pois já recebemos 001 do Vetor
        --IF vr_cddbanco <> 85 THEN
        --  -- Criticar CNPJ divergente do cadastro da empresa
        --  vr_dscriarq := 'Banco incorreto no header do arquivo!';
        --  CONTINUE;
        --END IF;

        -- pula para a próxima linha
        CONTINUE;

      -- Se tipo de registro for 1-Header do Lote
      ELSIF vr_tpregist = 1 THEN

        -- Cria o registro de memória para o lote
        vr_indatpgt := vr_tbdatpgt.count() + 1; -- Cada lote eh um registro novo
        vr_tbdatpgt(vr_indatpgt).qtlctpag := 0;
        vr_tbdatpgt(vr_indatpgt).qtregpag := 0;
        vr_tbdatpgt(vr_indatpgt).vllctpag := 0;

        -- Se encontrar um lote, verifica se encontrou o trailer do anterior - O primeiro já vem com true
        IF NOT vr_idtrllot THEN
          vr_dscritic := 'Trailer do lote anterior não encontrado no arquivo. ';
          vr_dscrilot := vr_dscritic;
          -- Muda para true pois irá criticar através do lote
          vr_idtrllot := TRUE;

          -- Alterar a critica de todos os registros, atribuindo a critica do trailer do arquivo
          FOR ind IN vr_tbcritic.FIRST..vr_tbcritic.LAST LOOP
            vr_qtdregok := 0; -- Todos com erro
            -- Se for um registro de sucesso
            IF vr_tbcritic(ind).inderror = 0 THEN
              vr_tbcritic(ind).inderror := 1; -- Erro
              vr_tbcritic(ind).dscritic := vr_dscritic;
              vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
            END IF;
          END LOOP;

          CONTINUE;
        END IF;

        -- Inicializa a variavel indicando que não encontrou o trailer do lote
        vr_idtrllot := FALSE;
        vr_idtrlarq := FALSE;

        -- Limpa critica pois é um lote novo
        vr_dscrilot := NULL;
        -- Inicializa o contador de linhas
        vr_qtlinhas := 1; -- Inclui na contagem a primeira linha do lote

        -- Se tem erro no header do arquivo
        IF vr_dscriarq IS NOT NULL THEN
          vr_dscrilot := vr_dscriarq;
          CONTINUE;
        END IF;

        -- Coluna 9 deve conter um caracter "C"
        IF substr(vr_tbarquiv(ind), 9, 1) <> 'C' THEN
          vr_dscrilot := 'Dados inválidos na linha de lote (Linha '||ind||')';
          CONTINUE;
        END IF;

        -- Verificar o tipo do serviço
        BEGIN
          vr_tpservic := substr(vr_tbarquiv(ind), 10, 2);
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Erro
            vr_dscrilot := 'Tipo de Serviço inválido! Código: '||vr_tpservic;
            -- Adiciona a crítica
            CONTINUE;
        END;

        -- Caso o Cursor ja estiver aberto, vamos fecha-lo antes de abrir novamente
        IF cr_crapofp%ISOPEN THEN
          CLOSE cr_crapofp;
        END IF;

        -- Buscar o registro do tipo do serviço na CRAPOFP
        OPEN  cr_crapofp(pr_cdcooper, vr_tpservic);
        FETCH cr_crapofp INTO rw_crapofp;

        -- Se não encontrar registros
        IF cr_crapofp%NOTFOUND THEN
          CLOSE cr_crapofp;
          -- Criticar a falta do registro
          vr_dscrilot := 'Tipo de Serviço inválido! Código: '||vr_tpservic||' [Err.: 001]';
          CONTINUE;
        ELSE
          CLOSE cr_crapofp;
          -- Caso seja cooperativa
          IF vr_idtpempr = 'C' THEN
            -- Os campos de histórico devem estar informados
            IF NVL(rw_crapofp.cdhsdbcp,0) = 0 OR
               NVL(rw_crapofp.cdhscrcp,0) = 0 THEN
              -- Criticar historico não informado
              vr_dscrilot := 'Tipo de Serviço inválido! Código: '||vr_tpservic||' [Err.: 002]';
              CONTINUE;
            END IF;
          ELSIF vr_idtpempr = 'O' THEN -- Caso seja outras
            -- Os campos de histórico devem estar informados
            IF NVL(rw_crapofp.cdhisdeb,0) = 0 OR
               NVL(rw_crapofp.cdhiscre,0) = 0 THEN
              -- Criticar historico não informado
              vr_dscrilot := 'Tipo de Serviço inválido! Código: '||vr_tpservic||' [Err.: 003]';
              CONTINUE;
            END IF;
          END IF;
        END IF;

        -- Verificar o CNPJ
        BEGIN
          -- Validar o CNPJ
          IF vr_nrdocnpj <> to_number(TRIM(substr(vr_tbarquiv(ind), 19, 8))) THEN
            -- Criticar CNPJ divergente do cadastro da empresa
            vr_dscrilot := 'CNPJ arquivo diverge do cadastro da empresa!';
            CONTINUE;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Erro
            vr_dscrilot := 'CNPJ do arquivo inválido! CPNJ: '||TRIM(substr(vr_tbarquiv(ind), 19, 14));
            -- Adiciona a crítica
            CONTINUE;
        END;

        -- Verificar o código do banco é numerico - Posição 1 - Apenas validar não grava este campo
        BEGIN
          vr_cddbanco := to_number(substr(vr_tbarquiv(ind),1,3));
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar CNPJ divergente do cadastro da empresa
            vr_dscrilot := 'Banco inválido no header do lote!';
            CONTINUE;
        END;

        -- Verifica se o código do banco é 85 - Validando o inicio da linha
        -- Comentado pois já recebemos 001 do Vetor
        --IF vr_cddbanco <> 85 THEN
        --  -- Criticar CNPJ divergente do cadastro da empresa
        --  vr_dscrilot := 'Banco incorreto no header do lote!';
        --  CONTINUE;
        --END IF;

      -- Se tipo de registro for 3-Linha de dados do funcionário
      ELSIF vr_tpregist = 3 THEN

        -- Conta a quantidades de linha
        vr_qtlinhas := vr_qtlinhas + 1;

        -- Verifica se há critica do header do lote
        IF vr_dscrilot IS NOT NULL THEN
          IF substr(vr_tbarquiv(ind), 14, 1) = 'A' THEN
            -- Criticar todas as demais linhas
            pc_add_critica(vr_dscrilot -- pr_dscritic
                          ,vr_qtlinhas -- pr_nrdlinha
                          ,substr(vr_tbarquiv(ind),30,13) -- pr_dsdconta
                          ,substr(vr_tbarquiv(ind),74,15) -- pr_dscpfcgc
                          ,rw_crapofp.dsorigem            -- pr_dsorigem
                          ,substr(vr_tbarquiv(ind),120,15)
                          ,TRUE ); -- indicar erro

            vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
          END IF;
          -- Próxima linha
          CONTINUE;
        END IF;

        -- Verifica se o caracter 14 é igual a A...
        IF substr(vr_tbarquiv(ind), 14, 1) = 'A' THEN
          -- Inicializa a variável que indica erro na linha A
          vr_idcrirga := FALSE; -- Nenhum erro

          BEGIN
            -- Totalizador para validar o trailer do arquivo
            vr_vltotpag := NVL(vr_vltotpag,0) + (to_number(TRIM(Substr(vr_tbarquiv(ind),120,15)))/100);
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              NULL; -- Valores inválidos não serão somados
          END;

          -- Verificar o código do banco é numerico - Posição 1 - Apenas validar não grava este campo
          BEGIN
            vr_cddbanco := to_number(substr(vr_tbarquiv(ind),1,3));
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              -- Criticar CNPJ divergente do cadastro da empresa
              vr_dscritic := 'Banco inválido!';
              -- Adiciona a crítica
              pc_add_critica(vr_dscritic -- pr_dscritic
                            ,vr_qtlinhas -- pr_nrdlinha
                            ,substr(vr_tbarquiv(ind),30,13) -- pr_dsdconta
                            ,substr(vr_tbarquiv(ind),74,15) -- pr_dscpfcgc
                            ,rw_crapofp.dsorigem            -- pr_dsorigem
                            ,substr(vr_tbarquiv(ind),120,15)
                            ,TRUE ); -- indicar erro

              vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
              vr_idcrirga := TRUE; -- Ocorrencia de erro

              CONTINUE;
          END;

          -- Verifica se o código do banco é 85 - Validando o inicio da linha
          -- Comentado pois já recebemos 001 do Vetor
          /*IF vr_cddbanco <> 85 THEN
            -- Criticar CNPJ divergente do cadastro da empresa
            vr_dscritic := 'Banco incorreto!';
            -- Adiciona a crítica
            pc_add_critica(vr_dscritic -- pr_dscritic
                          ,vr_qtlinhas -- pr_nrdlinha
                          ,substr(vr_tbarquiv(ind),30,13) -- pr_dsdconta
                          ,substr(vr_tbarquiv(ind),74,15) -- pr_dscpfcgc
                          ,rw_crapofp.dsorigem            -- pr_dsorigem
                          ,substr(vr_tbarquiv(ind),120,15)
                          ,TRUE ); -- indicar erro

            vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
            vr_idcrirga := TRUE; -- Ocorrencia de erro

            CONTINUE;
          END IF;*/

          -- Inicializar novamente para variável para validar o campo que será gravado
          vr_cddbanco := NULL;

          /** BANCO **/
          -- Verificar o código do banco é numerico - Posição 21
          BEGIN
            vr_cddbanco := to_number(substr(vr_tbarquiv(ind),21,3));
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              -- Criticar CNPJ divergente do cadastro da empresa
              vr_dscritic := 'Banco inválido!';
              -- Adiciona a crítica
              pc_add_critica(vr_dscritic -- pr_dscritic
                            ,vr_qtlinhas -- pr_nrdlinha
                            ,substr(vr_tbarquiv(ind),30,13) -- pr_dsdconta
                            ,substr(vr_tbarquiv(ind),74,15) -- pr_dscpfcgc
                            ,rw_crapofp.dsorigem            -- pr_dsorigem
                            ,substr(vr_tbarquiv(ind),120,15)
                            ,TRUE ); -- indicar erro

              vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
              vr_idcrirga := TRUE; -- Ocorrencia de erro

              CONTINUE;
          END;

          -- Verifica se o código do banco é 85
          IF vr_cddbanco <> 85 THEN
            -- Criticar CNPJ divergente do cadastro da empresa
            vr_dscritic := 'Banco incorreto!';
            -- Adiciona a crítica
            pc_add_critica(vr_dscritic -- pr_dscritic
                          ,vr_qtlinhas -- pr_nrdlinha
                          ,substr(vr_tbarquiv(ind),30,13) -- pr_dsdconta
                          ,substr(vr_tbarquiv(ind),74,15) -- pr_dscpfcgc
                          ,rw_crapofp.dsorigem            -- pr_dsorigem
                          ,substr(vr_tbarquiv(ind),120,15)
                          ,TRUE ); -- indicar erro

            vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
            vr_idcrirga := TRUE; -- Ocorrencia de erro

            CONTINUE;
          END IF;

          /** CONTA **/
          -- Verificar se o número da conta é numérico
          BEGIN
            vr_nrdconta := to_number(substr(vr_tbarquiv(ind),30,13));
            -- Se número da conta ficou null
            IF vr_nrdconta IS NULL THEN
              -- Forçamos a execução do when-others abaixo
              RAISE vr_excerror;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              -- Criticar CNPJ divergente do cadastro da empresa
              vr_dscritic := 'Número da Conta inválido!';
              -- Adiciona a crítica
              pc_add_critica(vr_dscritic -- pr_dscritic
                            ,vr_qtlinhas -- pr_nrdlinha
                            ,substr(vr_tbarquiv(ind),30,13) -- pr_dsdconta
                            ,substr(vr_tbarquiv(ind),74,15) -- pr_dscpfcgc
                            ,rw_crapofp.dsorigem            -- pr_dsorigem
                            ,substr(vr_tbarquiv(ind),120,15)
                            ,TRUE ); -- indicar erro

              vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
              vr_idcrirga := TRUE; -- Ocorrencia de erro

              CONTINUE;
          END;

          -- Verificar o valor é numérico
          BEGIN
            vr_vlrpagto := to_number(TRIM(Substr(vr_tbarquiv(ind),120,15)));
            -- Se valor ficou null
            IF vr_vlrpagto IS NULL THEN
              -- Forçamos a execução do when-others abaixo
              RAISE vr_excerror;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              -- Criticar CNPJ divergente do cadastro da empresa
              vr_dscritic := 'Valor de Pagamento inválido!';
              -- Adiciona a crítica
              pc_add_critica(vr_dscritic -- pr_dscritic
                            ,vr_qtlinhas -- pr_nrdlinha
                            ,TRIM(GENE0002.fn_mask_conta(vr_nrdconta))      -- pr_dsdconta
                            ,substr(vr_tbarquiv(ind),74,15)                 -- pr_dscpfcgc
                            ,rw_crapofp.dsorigem                            -- pr_dsorigem
                            ,substr(vr_tbarquiv(ind),120,15)
                            ,TRUE ); -- indicar erro

              vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
              vr_idcrirga := TRUE; -- Ocorrencia de erro

              CONTINUE;
          END;

          -- Testamos a existência do Segmento B do detalhe
          -- Se este for a ultima linha ou a próxima não for do tipo 3 e Segmento B
          IF ind = vr_tbarquiv.last() OR substr(vr_tbarquiv(ind+1), 8, 1) != '3' OR substr(vr_tbarquiv(ind+1), 14, 1) != 'B' THEN
            -- Criticar CNPJ divergente do cadastro da empresa
            vr_dscritic := 'Segmento de Detalhe B não encontrado!.';
            -- Adiciona a crítica
            pc_add_critica(vr_dscritic -- pr_dscritic
                          ,vr_qtlinhas -- pr_nrdlinha
                          ,TRIM(GENE0002.fn_mask_conta(vr_nrdconta))      -- pr_dsdconta
                          ,substr(vr_tbarquiv(ind),74,15)                 -- pr_dscpfcgc
                          ,rw_crapofp.dsorigem                            -- pr_dsorigem
                          ,substr(vr_tbarquiv(ind),120,15)
                          ,TRUE ); -- indicar erro

            vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
            vr_idcrirga := TRUE; -- Ocorrencia de erro

            CONTINUE;
          END IF;

        -- Se for tipo de registro B
        ELSIF substr(vr_tbarquiv(ind), 14, 1) = 'B' THEN

          -- Se encontrou erro na linha A
          IF vr_idcrirga THEN
            CONTINUE;
          END IF;

          -- Testamos a existência do Segmento A do detalhe
          -- Se este for a primeira linha ou a anterior não for do tipo 3 e Segmento A
          IF ind = vr_tbarquiv.first() OR substr(vr_tbarquiv(ind-1), 8, 1) != '3' OR substr(vr_tbarquiv(ind-1), 14, 1) != 'A' THEN
            -- Adiciona a crítica
            vr_dscritic := 'Segmento de Detalhe A não encontrado!.';
            pc_add_critica(vr_dscritic -- pr_dscritic
                          ,vr_qtlinhas -- pr_nrdlinha
                          ,NULL        -- pr_dsdconta
                          ,substr(vr_tbarquiv(ind),19,14)            -- pr_dscpfcgc
                          ,rw_crapofp.dsorigem                       -- pr_dsorigem
                          ,NULL                                      -- Valor
                          ,TRUE ); -- indicar erro

            vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro

            CONTINUE;
          END IF;

          -- Verificar o código do banco é numerico - Posição 1 - Apenas validar não grava este campo
          BEGIN
            vr_cddbanco := to_number(substr(vr_tbarquiv(ind),1,3));
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              -- Criticar CNPJ divergente do cadastro da empresa
              vr_dscritic := 'Banco inválido!';
              -- Adiciona a crítica
              pc_add_critica(vr_dscritic -- pr_dscritic
                            ,vr_qtlinhas -- pr_nrdlinha
                            ,TRIM(GENE0002.fn_mask_conta(vr_nrdconta)) -- pr_dsdconta
                            ,substr(vr_tbarquiv(ind),19,14)            -- pr_dscpfcgc
                            ,rw_crapofp.dsorigem                       -- pr_dsorigem
                            ,vr_vlrpagto
                            ,TRUE ); -- indicar erro

              vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro

              CONTINUE;
          END;

          -- Verifica se o código do banco é 85 - Validando o inicio da linha
          -- Comentado pois já recebemos 001 do Vetor
          /*IF vr_cddbanco <> 85 THEN
            -- Criticar CNPJ divergente do cadastro da empresa
            vr_dscritic := 'Banco incorreto!';
            -- Adiciona a crítica
            pc_add_critica(vr_dscritic -- pr_dscritic
                          ,vr_qtlinhas -- pr_nrdlinha
                          ,TRIM(GENE0002.fn_mask_conta(vr_nrdconta)) -- pr_dsdconta
                          ,GENE0002.fn_mask_cpf_cnpj(vr_nrcpfcgc,1) -- pr_dscpfcgc
                          ,rw_crapofp.dsorigem            -- pr_dsorigem
                          ,vr_vlrpagto
                          ,TRUE ); -- indicar erro

            vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro

            CONTINUE;
          END IF;*/



          -- Verificar o código CPF / CNPJ é numérico
          BEGIN
            vr_nrcpfcgc := to_number(TRIM(Substr(vr_tbarquiv(ind),19,14)));
            IF length(vr_nrcpfcgc) > 11 THEN	
              -- Apenas para levantar exception e tratar mensagem de critica padrao    
              RAISE no_data_found;
            END IF;
            
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              -- Criticar CNPJ divergente do cadastro da empresa
              vr_dscritic := 'Número do CPF inválido!';
              -- Adiciona a crítica
              pc_add_critica(vr_dscritic -- pr_dscritic
                            ,vr_qtlinhas -- pr_nrdlinha
                            ,TRIM(GENE0002.fn_mask_conta(vr_nrdconta)) -- pr_dsdconta
                            ,substr(vr_tbarquiv(ind),19,14) -- pr_dscpfcgc
                            ,rw_crapofp.dsorigem            -- pr_dsorigem
                            ,vr_vlrpagto
                            ,TRUE ); -- indicar erro

              vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
              vr_idcrirga := TRUE; -- Ocorrencia de erro

              CONTINUE;
          END;

          -- Se a origem for internet banking
          IF pr_idorigem = 3 THEN

            -- Limpar a variável de crítica
            pr_dscritic := NULL;
            vr_idtpcont := NULL;
            vr_nmprimtl := NULL;

            -- Efetua a validação do lançamento
            FOLH0001.pc_valida_lancto_folha(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => vr_nrdconta
                                           ,pr_nrcpfcgc => vr_nrcpfcgc
                                           ,pr_dtcredit => TO_DATE(pr_dtcredit,'DD/MM/YYYY')
                                           ,pr_idtpcont => vr_idtpcont
                                           ,pr_nmprimtl => vr_nmprimtl
                                           ,pr_dsalerta => vr_dsalert
                                           ,pr_dscritic => pr_dscritic);

            -- Se ocorreu crítica na validação
            IF vr_dsalert IS NOT NULL THEN
              -- Adiciona a crítica
              pc_add_critica(vr_dsalert  -- pr_dscritic
                            ,vr_qtlinhas -- pr_nrdlinha
                            ,trim(GENE0002.fn_mask_conta(vr_nrdconta))      -- pr_dsdconta
                            ,GENE0002.fn_mask_cpf_cnpj(vr_nrcpfcgc,1) -- pr_dscpfcgc
                            ,rw_crapofp.dsorigem                      -- pr_dsorigem
                            ,vr_vlrpagto
                            ,TRUE ); -- indicar erro

              vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
              vr_idcrirga := TRUE; -- Ocorrencia de erro

              CONTINUE;
            ELSE
              -- Se ocorrer erro de processamento
              IF pr_dscritic IS NOT NULL THEN
                RAISE vr_excerror; -- Finaliza o programa
            END IF;
            END IF;

          END IF;

          -- Guardar a quantidade de registros lidos no lote
          vr_tbdatpgt(vr_indatpgt).qtregpag := vr_tbdatpgt(vr_indatpgt).qtregpag + 1;
          IF vr_vlrpagto > 0 THEN
            vr_tbdatpgt(vr_indatpgt).qtlctpag := vr_tbdatpgt(vr_indatpgt).qtlctpag + 1;
          END IF;

          -- Guardar os dados do registro lido
          vr_inreglfp := vr_tbdatpgt(vr_indatpgt).tbreglfp.COUNT() + 1;
          vr_tbdatpgt(vr_indatpgt).tbreglfp(vr_inreglfp).nrseqlfp := vr_inreglfp;
          vr_tbdatpgt(vr_indatpgt).tbreglfp(vr_inreglfp).nrdconta := vr_nrdconta;
          vr_tbdatpgt(vr_indatpgt).tbreglfp(vr_inreglfp).idtpcont := vr_idtpcont;
          vr_tbdatpgt(vr_indatpgt).tbreglfp(vr_inreglfp).nrcpfemp := vr_nrcpfcgc;
          vr_tbdatpgt(vr_indatpgt).tbreglfp(vr_inreglfp).vllancto := (vr_vlrpagto/100);
          vr_tbdatpgt(vr_indatpgt).tbreglfp(vr_inreglfp).cdorigem := rw_crapofp.cdorigem;

          -- Se a origem for internet banking
          IF pr_idorigem = 3 THEN
            -- Verificar indicador
            IF rw_crapofp.idvarmes = 'A' THEN

              -- Verificar o lançamento
              OPEN  cr_verifica(pr_cdcooper   -- pr_cdcooper
                               ,vr_cdempres   -- pr_cdempres
                               ,to_date(pr_dtcredit,'DD/MM/YY')   -- pr_dtcredit
                               ,vr_nrdconta   -- pr_nrdconta
                               ,vr_tpservic); -- pr_cdorigem
              FETCH cr_verifica INTO vr_qtalerta;
              CLOSE cr_verifica;

              -- Se encontrar ao menos um registro
              IF NVL(vr_qtalerta,0) > 0 THEN
                -------------------------
                -- Aviso de Registro lido com sucesso
                pc_add_critica('Origem já utilizada no mês para a conta! Atenção para evitar duplicidade!' -- pr_dscritic
                              ,vr_qtlinhas                  -- pr_nrdlinha
                              ,TRIM(GENE0002.fn_mask_conta(vr_nrdconta))      -- pr_dsdconta
                              ,GENE0002.fn_mask_cpf_cnpj(vr_nrcpfcgc,1) -- pr_dscpfcgc
                              ,rw_crapofp.dsorigem                      -- pr_dsorigem
                              ,vr_vlrpagto
                              ,FALSE ); -- indicar o NÃO erro

                -- Contabilizar registros de alerta
                vr_qttotalr := NVL(vr_qttotalr,0) + 1;
                --------------------------
                CONTINUE;
              END IF;

            END IF;
          END IF;

          -------------------------
          -- Aviso de Registro lido com sucesso
          pc_add_critica('Registro lido com Sucesso!' -- pr_dscritic
                        ,vr_qtlinhas                  -- pr_nrdlinha
                        ,TRIM(GENE0002.fn_mask_conta(vr_nrdconta))      -- pr_dsdconta
                        ,GENE0002.fn_mask_cpf_cnpj(vr_nrcpfcgc,1) -- pr_dscpfcgc
                        ,rw_crapofp.dsorigem                      -- pr_dsorigem
                        ,vr_vlrpagto
                        ,FALSE ); -- indicar o NÃO erro

          -- Contabilizar registros com sucesso
          vr_qtdregok := NVL(vr_qtdregok,0) + 1;
          --------------------------
          
        -- Rafael Ferreira (Mouts) - INC0021033
        -- Se for tipo de registro P
        ELSIF substr(vr_tbarquiv(ind), 14, 1) = 'P' THEN
          -- Verifica se o campo "Nosso Numero" está zerado no arquivo
          BEGIN
            vr_nossonum := trim(substr(vr_tbarquiv(ind), 45, 9));
            
            IF nvl(vr_nossonum,0) = 0 THEN
              -- Forçamos a execução do when-others abaixo
              RAISE vr_excerror;
            END IF;
            
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              -- Criticar Nosso Número Zerado
              vr_dscritic := 'Nosso Número Inválido!';
              -- Adiciona a crítica
              pc_add_critica(vr_dscritic -- pr_dscritic
                            ,vr_qtlinhas -- pr_nrdlinha
                            ,TRIM(GENE0002.fn_mask_conta(vr_nrdconta)) -- pr_dsdconta
                            ,GENE0002.fn_mask_cpf_cnpj(vr_nrdocnpj,1) -- pr_dscpfcgc
                            ,rw_crapofp.dsorigem            -- pr_dsorigem
                            ,vr_vlrpagto
                            ,TRUE ); -- indicar erro

              vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
              vr_idcrirga := TRUE; -- Ocorrencia de erro

              CONTINUE;
          END;
          
        
        END IF;

      -- Se tipo de registro for 5-Linha de trailer do lote
      ELSIF vr_tpregist = 5 THEN

        -- Indicar que encontrou o trailer do lote
        vr_idtrllot := TRUE;

        -- Incluir a linha do trailer na contagem de linhas
        vr_qtlinhas := vr_qtlinhas + 1;

        -- Se há erro no head do lote, não valida o trailer
        IF vr_dscrilot IS NOT NULL THEN
          CONTINUE;
        END IF;

        -- Verificar o código do banco é numerico - Posição 1 - Apenas validar não grava este campo
        BEGIN
          vr_cddbanco := to_number(substr(vr_tbarquiv(ind),1,3));
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar CNPJ divergente do cadastro da empresa
            vr_dscritic := 'Banco inválido no trailer do lote!';
            -- Refaz a contagem dos registros
            vr_qtregerr := 0;
            vr_qtdregok := 0; -- Todos com erro
            vr_qttotalr := 0;

            -- Alterar a critica de todos os registros, atribuindo a critica do trailer do arquivo
            IF vr_tbcritic.count > 0 THEN
              FOR ind IN vr_tbcritic.FIRST..vr_tbcritic.LAST LOOP
                -- Se for um registro de sucesso
                IF vr_tbcritic(ind).inderror = 0 THEN
                  vr_tbcritic(ind).inderror := 1; -- Erro
                  vr_tbcritic(ind).dscritic := vr_dscritic;
                END IF;
                vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
              END LOOP;
            ELSE
              vr_dscrilot := vr_dscritic;
            END IF;

            CONTINUE;
        END;

        -- Verifica se o código do banco é 85 - Validando o inicio da linha
        -- Comentado pois já recebemos 001 do Vetor
        /*IF vr_cddbanco <> 85 THEN
          -- Criticar CNPJ divergente do cadastro da empresa
          vr_dscritic := 'Banco incorreto no trailer do lote!';
          -- Refaz a contagem dos registros
          vr_qtregerr := 0;
          vr_qtdregok := 0; -- Todos com erro

          -- Alterar a critica de todos os registros, atribuindo a critica do trailer do arquivo
          FOR ind IN vr_tbcritic.FIRST..vr_tbcritic.LAST LOOP
            -- Se for um registro de sucesso
            IF vr_tbcritic(ind).inderror = 0 THEN
              vr_tbcritic(ind).inderror := 1; -- Erro
              vr_tbcritic(ind).dscritic := vr_dscritic;
            END IF;
            vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
          END LOOP;

          CONTINUE;
        END IF;*/

        -- Verifica se a quantidade de linhas lidas e a quantidade presente no trailer está correta
        IF to_number(Substr(vr_tbarquiv(ind),18,6)) <> vr_qtlinhas THEN
          -- Refaz a contagem dos registros
          vr_qtregerr := 0;
          vr_qtdregok := 0; -- Todos com erro
          vr_qttotalr := 0;

          -- Criticar CNPJ divergente do cadastro da empresa
          vr_dscritic := 'Qtde de Pagamentos não confere com o Total do Lote!';

          -- Alterar a critica de todos os registros, atribuindo a critica do trailer do arquivo
          IF vr_tbcritic.count > 0 THEN
            FOR ind IN vr_tbcritic.FIRST..vr_tbcritic.LAST LOOP
              vr_qtdregok := 0; -- Todos com erro

              -- Se for um registro de sucesso
              IF vr_tbcritic(ind).inderror = 0 THEN
                vr_tbcritic(ind).inderror := 1; -- Erro
                vr_tbcritic(ind).dscritic := vr_dscritic;
              END IF;
              vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
            END LOOP;
          ELSE
            vr_dscrilot := vr_dscritic;
          END IF;

          CONTINUE;
        END IF;

        -- Verifica se o valor total do trailer condiz com o valor total lido
        IF (to_number(Substr(vr_tbarquiv(ind),24,18)) / 100) <> vr_vltotpag THEN
          -- Refaz a contagem dos registros
          vr_qtregerr := 0;
          vr_qtdregok := 0; -- Todos com erro
          vr_qttotalr := 0;

          -- Criticar CNPJ divergente do cadastro da empresa
          vr_dscritic := 'Valor Total de Pagamentos não confere com o Total do Lote!';

          -- Alterar a critica de todos os registros, atribuindo a critica do trailer do arquivo
          IF vr_tbcritic.count > 0 THEN
            FOR ind IN vr_tbcritic.FIRST..vr_tbcritic.LAST LOOP
              vr_qtdregok := 0; -- Todos com erro

              -- Se for um registro de sucesso
              IF vr_tbcritic(ind).inderror = 0 THEN
                vr_tbcritic(ind).inderror := 1; -- Erro
                vr_tbcritic(ind).dscritic := vr_dscritic;
              END IF;
              vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
            END LOOP;
          ELSE
            vr_dscrilot := vr_dscritic;
          END IF;

          CONTINUE;
        END IF;

        -- Guarda o valor total do lote lido
        vr_tbdatpgt(vr_indatpgt).vllctpag := vr_vltotpag;

      ELSIF vr_tpregist = 9 THEN
        -- Identifica que encontrou o trailer do arquivo
        vr_idtrlarq := TRUE;

        -- Se há erro no head do lote, não valida o trailer
        IF vr_dscrilot IS NOT NULL THEN
          CONTINUE;
        END IF;

        -- Verificar o código do banco é numerico - Posição 1 - Apenas validar não grava este campo
        BEGIN
          vr_cddbanco := to_number(substr(vr_tbarquiv(ind),1,3));
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar CNPJ divergente do cadastro da empresa
            vr_dscritic := 'Banco inválido no trailer do arquivo!';
            -- Refaz a contagem dos registros
            vr_qtregerr := 0;
            vr_qtdregok := 0; -- Todos com erro
            vr_qttotalr := 0;

            -- Alterar a critica de todos os registros, atribuindo a critica do trailer do arquivo
            FOR ind IN vr_tbcritic.FIRST..vr_tbcritic.LAST LOOP
              -- Se for um registro de sucesso
              IF vr_tbcritic(ind).inderror = 0 THEN
                vr_tbcritic(ind).inderror := 1; -- Erro
                vr_tbcritic(ind).dscritic := vr_dscritic;
              END IF;
              vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
            END LOOP;

            CONTINUE;
        END;

        -- Verifica se o código do banco é 85 - Validando o inicio da linha
        -- Comentado pois já recebemos 001 no Vetor
        /*IF vr_cddbanco <> 85 THEN
          -- Criticar CNPJ divergente do cadastro da empresa
          vr_dscritic := 'Banco incorreto no trailer do arquivo!';
          -- Refaz a contagem dos registros
          vr_qtregerr := 0;
          vr_qtdregok := 0; -- Todos com erro

          -- Alterar a critica de todos os registros, atribuindo a critica do trailer do arquivo
          FOR ind IN vr_tbcritic.FIRST..vr_tbcritic.LAST LOOP
            -- Se for um registro de sucesso
            IF vr_tbcritic(ind).inderror = 0 THEN
              vr_tbcritic(ind).inderror := 1; -- Erro
              vr_tbcritic(ind).dscritic := vr_dscritic;
            END IF;
            vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
          END LOOP;

          CONTINUE;
        END IF;  */

        -- Se chegar ao fim do arquivo verifica se encontrou o trailer
        IF NOT vr_idtrllot THEN
          vr_dscritic := 'Trailer do lote não encontrado no arquivo. ';
          vr_qtdregok := 0; -- Todos com erro
          vr_qttotalr := 0;

          -- Alterar a critica de todos os registros, atribuindo a critica do trailer do arquivo
          FOR ind IN vr_tbcritic.FIRST..vr_tbcritic.LAST LOOP

            -- Se for um registro de sucesso
            IF vr_tbcritic(ind).inderror = 0 THEN
              vr_tbcritic(ind).inderror := 1; -- Erro
              vr_tbcritic(ind).dscritic := vr_dscritic;
              vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
            END IF;

          END LOOP;

        END IF;

      END IF;

    END LOOP; -- Loop das linhas do arquivo

    -- Se chegar ao fim do arquivo verifica se encontrou o trailer DO ARQUIVO
    IF NOT vr_idtrlarq THEN
      vr_dscritic := 'Trailer do arquivo não encontrado. ';

      -- Alterar a critica de todos os registros, atribuindo a critica do trailer do arquivo
      FOR ind IN vr_tbcritic.FIRST..vr_tbcritic.LAST LOOP
        vr_qtdregok := 0; -- Todos com erro
        vr_qttotalr := 0;

        -- Se for um registro de sucesso
        IF vr_tbcritic(ind).inderror = 0 THEN
          vr_tbcritic(ind).inderror := 1; -- Erro
          vr_tbcritic(ind).dscritic := vr_dscritic;
          vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
        END IF;
      END LOOP;

    END IF;

    -- Não podemos receber um lote vazio, portanto vamos checar um a um a procura de problem
    -- Se tem dados para o arquivo... e for IB
    IF vr_tbdatpgt.count() > 0 THEN
      -- Percorre todas as informações
      FOR ind IN vr_tbdatpgt.FIRST..vr_tbdatpgt.LAST LOOP
        -- Se o lote possuir zero lançamentos
        IF vr_tbdatpgt(ind).qtregpag <= 0 THEN
          vr_dscritic := 'Lote vazio no arquivo, favor corrigir! ';
          -- Alterar a critica de todos os registros, atribuindo a critica do trailer do arquivo
          FOR ind IN vr_tbcritic.FIRST..vr_tbcritic.LAST LOOP
            vr_qtdregok := 0; -- Todos com erro
            vr_qttotalr := 0;

            -- Se for um registro de sucesso
            IF vr_tbcritic(ind).inderror = 0 THEN
              vr_tbcritic(ind).inderror := 1; -- Erro
              vr_tbcritic(ind).dscritic := vr_dscritic;
              vr_qtregerr := NVL(vr_qtregerr,0) + 1; -- Contabilizar registros de erro
            END IF;
          END LOOP;
          -- Sair
          EXIT;
        END IF;
      END LOOP;
    END IF;

    -- Se possui críticas a serem retornadas
    IF vr_tbcritic.COUNT() > 0 THEN

      -- Se houver críticas de erro
      IF NVL(vr_qtregerr,0) > 0 THEN
        -- Limpa a tabela afim de não retornar nada
        vr_tbdatpgt.DELETE;
      END IF;

      -- Se a origem for internet banking
      IF pr_idorigem = 3 THEN

        -- Montar o nome do arquivo do XML
        vr_nmarquiv := to_char(pr_cdcooper,'FM000')||'.'||pr_nrdconta||'.'||pr_dssessao||'.XMLDADOSFOLHA.txt';

        -- Inicializar XML de retorno
        dbms_lob.createtemporary(pr_retxml, TRUE);
        dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_dsauxml
                               ,pr_texto_novo     => '<criticas qtregerr="'||NVL(vr_qtregerr,0)||'" '||
                                                     'qtdregok="'||NVL(vr_qtdregok,0)||'" '||
                                                     'qtregale="'||NVL(vr_qttotalr,0)||'" '||
                                                     'qtregtot="'||(NVL(vr_qtdregok,0) + NVL(vr_qtregerr,0) + NVL(vr_qttotalr,0))||'" '||
                                                     'vltotpag="'||to_char(vr_vltotpag,'FM9G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" '||
                                                     'nmarquiv="'||vr_nmarquiv||'">'||chr(13));

        -- Percorre todas as mensagens de alerta
        FOR ind IN vr_tbcritic.FIRST..vr_tbcritic.LAST LOOP
          -- Faz o tratamento dos acentos para o retorno do xml no IB
          vr_dscritic := gene0007.fn_convert_db_web(vr_tbcritic(ind).dscritic);
          -- Criar nodo filho
          gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                                 ,pr_texto_completo => vr_dsauxml
                                 ,pr_texto_novo     => '<critica>'
                                                    ||'<nrseqvld>'||ind||'</nrseqvld>'
                                                    ||'<dsdconta>'||vr_tbcritic(ind).dsdconta||'</dsdconta>'
                                                    ||'<dscpfcgc>'||vr_tbcritic(ind).dscpfcgc||'</dscpfcgc>'
                                                    ||'<dscritic>'||vr_dscritic ||'</dscritic>'
                                                    ||'<dsorigem>'||NVL(vr_tbcritic(ind).dsorigem, ' ')||'</dsorigem>'
                                                    ||'<vlrpagto>'||vr_tbcritic(ind).vlrpagto||'</vlrpagto>'
                                                    ||'<idanalis>'||vr_tbcritic(ind).inderror||'</idanalis>'                                                    
                                                    ||'</critica>'||chr(13));

        END LOOP; -- Loop das críticas

        -- Nodo de finalização
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_dsauxml
                               ,pr_texto_novo     => '</criticas>'
                               ,pr_fecha_xml      => TRUE);

        -- Limpar a variável do XML
        vr_retxml := NULL;

        -- Se tem dados para o arquivo... e for IB
        IF vr_tbdatpgt.count() > 0 THEN

          -- Montar o XML de gravação para ser gravado em arquivo
          vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><root></root>');

          -- Percorre todas as informações
          FOR ind IN vr_tbdatpgt.FIRST..vr_tbdatpgt.LAST LOOP
            -- Limpa o bloco de itens
            dbms_lob.createtemporary(vr_clitmxml, TRUE);
            dbms_lob.open(vr_clitmxml, dbms_lob.lob_readwrite);
            vr_dsitmxml := ' ';

            -- Inicializar o CLOB
            gene0002.pc_escreve_xml(pr_xml            => vr_clitmxml
                                   ,pr_texto_completo => vr_dsitmxml
                                   ,pr_texto_novo     => '<folha qtlctpag="'||vr_tbdatpgt(ind).qtlctpag||'" qtregpag="'||vr_tbdatpgt(ind).qtregpag||'" vllctpag="'||vr_tbdatpgt(ind).vllctpag||'">');


            -- Se há itens
            IF vr_tbdatpgt(ind).tbreglfp.count > 0 THEN
              -- Percorre todos os itens
              FOR itm IN vr_tbdatpgt(ind).tbreglfp.FIRST..vr_tbdatpgt(ind).tbreglfp.LAST LOOP
                -- Adicionar ao CLOB
                gene0002.pc_escreve_xml(pr_xml            => vr_clitmxml
                                       ,pr_texto_completo => vr_dsitmxml
                                       ,pr_texto_novo     => '<info>'||
                                                             '  <nrseqlfp>'||vr_tbdatpgt(ind).tbreglfp(itm).nrseqlfp||'</nrseqlfp>'||
                                                             '  <nrdconta>'||vr_tbdatpgt(ind).tbreglfp(itm).nrdconta||'</nrdconta>'||
                                                             '  <idtpcont>'||vr_tbdatpgt(ind).tbreglfp(itm).idtpcont||'</idtpcont>'||
                                                             '  <nrcpfemp>'||vr_tbdatpgt(ind).tbreglfp(itm).nrcpfemp||'</nrcpfemp>'||
                                                             '  <vllancto>'||vr_tbdatpgt(ind).tbreglfp(itm).vllancto||'</vllancto>'||
                                                             '  <cdorigem>'||vr_tbdatpgt(ind).tbreglfp(itm).cdorigem||'</cdorigem>'||
                                                             '</info>');
              END LOOP;

            END IF;
            -- Finalizar CLOB
            gene0002.pc_escreve_xml(pr_xml            => vr_clitmxml
                                   ,pr_texto_completo => vr_dsitmxml
                                   ,pr_texto_novo     => '</folha>'
                                   ,pr_fecha_xml      => TRUE);

            -- Enviar o CLOB ao XmlType
            vr_retxml := XMLTYPE.appendChildXML(vr_retxml
                                               ,'/root'
                                               ,XMLTYPE(vr_clitmxml));

          END LOOP;

          vr_dsdirgra := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => 'upload');
                                            
          -- Gravar o xml gerado em um arquivo que será lido pela rotina gravar
          GENE0002.pc_xml_para_arquivo(pr_xml      => vr_retxml
                                      ,pr_caminho  => vr_dsdirgra
                                      ,pr_arquivo  => vr_nmarquiv
                                      ,pr_des_erro => pr_dscritic);

          -- Verifica se houve erros na gravação do arquivo
          IF pr_dscritic IS NOT NULL THEN
            pr_dscritic := 'Erro ao gravar arquivo: '||pr_dsarquiv;
            RAISE vr_excerror;
          END IF;

        END IF; -- vr_tbdatpgt.count() > 0

      ELSE -- Se a origem não for IB... monta um XML completo

        -- Recriar cabecalho do XML
        vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><criticas qtregerr="'||NVL(vr_qtregerr,0)||'" '||
                                                                                                   'qtdregok="'||NVL(vr_qtdregok,0)||'" '||
                                                                                                   'qtregtot="'||(NVL(vr_qtdregok,0) + NVL(vr_qtregerr,0))||'" '||
                                                                                                   'vltotpag="'||to_char(vr_vltotpag,'FM9G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'">'||
                                                                                                   '</criticas><arqfolhas></arqfolhas></Root>');

        -- Percorre todas as mensagens de alerta
        FOR ind IN vr_tbcritic.FIRST..vr_tbcritic.LAST LOOP

          -- Criar nodo filho
          vr_retxml := XMLTYPE.appendChildXML(vr_retxml
                                              ,'/Root/criticas'
                                              ,XMLTYPE('<critica>'
                                                     ||'    <nrseqvld>'||ind||'</nrseqvld>'
                                                     ||'    <dsdconta>'||vr_tbcritic(ind).dsdconta||'</dsdconta>'
                                                     ||'    <dscpfcgc>'||vr_tbcritic(ind).dscpfcgc||'</dscpfcgc>'
                                                     ||'    <dscritic>'||vr_tbcritic(ind).dscritic||'</dscritic>'
                                                     ||'    <dsorigem>'||vr_tbcritic(ind).dsorigem||'</dsorigem>'
                                                     ||'    <vlrpagto>'||vr_tbcritic(ind).vlrpagto||'</vlrpagto>'
                                                     ||'</critica>'));

        END LOOP; -- Loop das críticas

        -- Converter o XML em CLOB e retornar
        pr_retxml := vr_retxml.getClobVal();

      END IF; -- IF pr_idorigem = 3

    END IF;

  EXCEPTION
    WHEN vr_excerror THEN
      pr_dscritic := pr_dscritic;

      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
     IF pr_idorigem = 3 THEN
          vr_retxml := XMLType.createXML('<Root><DSMSGERR>Rotina com erros</DSMSGERR></Root>');
      ELSE
          vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Dados>Rotina com erros</Dados></Root>');
      END IF ;
       -- Converter o XML
      pr_retxml := vr_retxml.getClobVal();
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      GENE0001.pc_OScommand_Shell('rm ' || vr_dsdireto || '/' || pr_dsarquiv);

      pr_dscritic := 'Erro geral na rotina pc_valida_arq_folha_ib: '||SQLERRM;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      IF pr_idorigem = 3 THEN

          vr_retxml := XMLType.createXML('<Root><DSMSGERR>Rotina com erros</DSMSGERR></Root>');
       ELSE
          vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Dados>Rotina com erros</Dados></Root>');
     END IF;
       -- Converter o XML
      pr_retxml := vr_retxml.getClobVal();
  END pc_valida_arq_folha_ib;

  /* Rotina para a validação do arquivo de Comprovantes - Através do AyllosWeb */
  PROCEDURE pc_valida_arq_compr_web(pr_nrdconta   IN NUMBER              --> Número da conta
                                   ,pr_dsarquiv   IN VARCHAR2            --> Informações do arquivo
                                   ,pr_dsdireto   IN VARCHAR2            --> Informações do diretório do arquivo
                                   ,pr_nrseqpag   IN NUMBER              --> Número da sequencia do pagamento selecionado em tela
                                   ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_valida_arq_compr_web                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Renato Darosci - SUPERO
  --  Data     : Maio/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Rotina para a validação do arquivo de Comprovantes
  --
  ---------------------------------------------------------------------------------------------------------------

    -- Variáveis
    vr_cdcooper    NUMBER;
    vr_nmdatela    VARCHAR2(25);
    vr_nmeacao     VARCHAR2(25);
    vr_cdagenci    VARCHAR2(25);
    vr_nrdcaixa    VARCHAR2(25);
    vr_idorigem    VARCHAR2(25);
    vr_cdoperad    VARCHAR2(25);
    vr_retxml      CLOB;

    vr_excerror    EXCEPTION;

  BEGIN

    -- Extrair informacoes padrao do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);

    -- Se houve erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_excerror;
    END IF;

    -- Realiza a chamada da rotina
    pc_valida_arq_compr_ib(pr_cdcooper => vr_cdcooper
                          ,pr_idorigem => vr_idorigem
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrseqpag => pr_nrseqpag
                          ,pr_dsarquiv => pr_dsarquiv
                          ,pr_dsdireto => pr_dsdireto
                          ,pr_iddspscp => 0
                          ,pr_dscritic => pr_dscritic
                          ,pr_retxml   => vr_retxml);

    -- Se houve erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_excerror;
    END IF;

    -- Cria o XML de retorno
    pr_retxml := XMLType.createXML(vr_retxml);

  EXCEPTION
    WHEN vr_excerror THEN
      pr_des_erro := pr_dscritic;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);
      pr_dscritic := 'Erro geral na rotina pc_valida_arq_compr_web: '||SQLERRM;
      pr_des_erro := pr_dscritic;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_valida_arq_compr_web;

  /* Rotina para a validação do arquivo de comprovantes de folha */
   PROCEDURE pc_valida_arq_compr_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                   ,pr_idorigem  IN NUMBER
                                   ,pr_nrdconta  IN NUMBER
                                   ,pr_nrseqpag  IN NUMBER
                                   ,pr_dsarquiv  IN VARCHAR2
                                   ,pr_dsdireto  IN VARCHAR2
                                   ,pr_iddspscp  IN NUMBER
                                   ,pr_dscritic  OUT VARCHAR2
                                   ,pr_retxml    OUT CLOB) IS        --> Erros do processo
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_valida_arq_compr_ib                  Antigo: Não há
  --  Sistema  : IB
  --  Sigla    : CRED
  --  Autor    : Renato Darosci - SUPERO
  --  Data     : Maio/2015.                   Ultima atualizacao: 07/12/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Rotina para a validação do arquivo de Comprovantes
  --
  -- Alterações
  --             04/11/2015 - Validar somente a raiz do CNPJ (Marcos-Supero)
  --
  --             07/12/2015 - Ajustando mascara de campo (Andre Santos - SUPERO)
  --
  ---------------------------------------------------------------------------------------------------------------

    -- CURSORES
    -- Buscar o CNPJ da empresa logada no Ibank
    CURSOR cr_crapemp(pr_cdcooper  crapemp.cdcooper%TYPE
                     ,pr_nrdconta  crapemp.nrdconta%TYPE) IS
      SELECT emp.cdempres
           , emp.idtpempr
           , SUBSTR(LPAD(emp.nrdocnpj,14,0),1,8) nrbscnpj
           , emp.nrdocnpj
           , emp.nmextemp
        FROM crapemp emp
       WHERE emp.cdcooper = pr_cdcooper
         AND emp.nrdconta = pr_nrdconta;
    rw_crapemp    cr_crapemp%ROWTYPE;

    -- Buscar a na base de dados nas tabelas de associados e contas salario
    CURSOR cr_crassccs(pr_cdcooper   crapass.cdcooper%TYPE
                      ,pr_nrdconta   crapass.nrdconta%TYPE) IS
      SELECT t.cdcooper
           , t.nrdconta
           , t.nrcpfcgc
        FROM crapass t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
       UNION
      SELECT s.cdcooper
           , s.nrdconta
           , s.nrcpfcgc
        FROM crapccs s
       WHERE s.cdcooper = pr_cdcooper
         AND s.nrdconta = pr_nrdconta;
    rw_crassccs    cr_crassccs%ROWTYPE;

    -- Buscar dados de pagamento de lançamentos de folha
    CURSOR cr_craplfp(pr_cdcooper  craplfp.cdcooper%TYPE
                     ,pr_cdempres  craplfp.cdempres%TYPE
                     ,pr_nrseqpag  craplfp.nrseqpag%TYPE
                     ,pr_nrdconta  craplfp.nrdconta%TYPE) IS
      SELECT lfp.nrseqlfp
           , ofp.dsorigem
           , COUNT(1)          qtlancto
           , SUM(lfp.vllancto) vllancto
        FROM crapofp ofp
           , craplfp lfp
       WHERE ofp.cdcooper = lfp.cdcooper
         AND ofp.cdorigem = lfp.cdorigem
         AND lfp.cdcooper = pr_cdcooper
         AND lfp.cdempres = pr_cdempres
         AND lfp.nrseqpag = pr_nrseqpag
         AND lfp.nrdconta = pr_nrdconta
       GROUP BY lfp.nrseqlfp
               ,ofp.dsorigem ;
    rw_craplfp  cr_craplfp%ROWTYPE;

    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.dsdircop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;    

    -- Registros
    TYPE typ_reccritc IS RECORD (nrdlinha NUMBER
                                ,dsdconta VARCHAR2(20)
                                ,dscpfcgc VARCHAR2(20)
                                ,dsorigem VARCHAR2(100)
                                ,dscritic VARCHAR2(100)
                                ,dsdescri VARCHAR2(100)
                                ,iddstipo VARCHAR2(10)
                                ,vlrpagto VARCHAR2(50)
                                ,inderror NUMBER);
    -- Registro de itens da folha de pagamento e a tabela da mesma
    TYPE typ_rcdatitm IS RECORD (cod      NUMBER         -- Código
                                ,dscr     VARCHAR2(100)  -- Descrição do pagamento
                                ,refe     VARCHAR2(100)  -- VALOR DA COLUNA REFERÊNCIA
                                ,venc     VARCHAR2(100)  -- VALOR DA COLUNA VENCIMENTOS
                                ,dcto     VARCHAR2(100));-- VALOR DA COLUNA DESCONTOS
    TYPE typ_tbdatitm IS TABLE OF typ_rcdatitm INDEX BY BINARY_INTEGER;
    -- Registro de folhas de pagamento
    TYPE typ_rcdatrel IS RECORD (nrseqlfp PLS_INTEGER
                                ,dtref    VARCHAR2(10)
                                ,cdemp    NUMBER
                                ,nmemp    VARCHAR2(100)
                                ,idtpemp  VARCHAR2(10)
                                ,nrdocnpj VARCHAR2(100)
                                ,nrcpfcgc VARCHAR2(100)
                                ,cdfunc   NUMBER
                                ,nmfunc   VARCHAR2(100)
                                ,dtadmis  VARCHAR2(10)
                                ,dscargo  VARCHAR2(100)
                                ,tbdeitm  typ_tbdatitm
                                ,salbase  VARCHAR2(30)
                                ,salinss  VARCHAR2(30)
                                ,faixair  VARCHAR2(30)
                                ,totvenc  VARCHAR2(30)
                                ,totdesc  VARCHAR2(30)
                                ,basefgts VARCHAR2(30)
                                ,fgtsmes  VARCHAR2(30)
                                ,baseirpf VARCHAR2(30)
                                ,vlrliqui VARCHAR2(30));

    TYPE typ_tbdatrel IS TABLE OF typ_rcdatrel INDEX BY BINARY_INTEGER;
    TYPE typ_tbreccri IS TABLE OF typ_reccritc INDEX BY BINARY_INTEGER;
    TYPE typ_tbcritic IS TABLE OF typ_tbreccri INDEX BY BINARY_INTEGER;

    TYPE typ_tbdescri IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
    vr_tbarquiv    typ_tbdescri; -- Tabela com as linhas do arquivo
    vr_tbcritic    typ_tbcritic; -- Tabela de criticas encontradas na validação do arquivo
    vr_tbdatrel    typ_tbdatrel; -- Tabela com todos os dados para o relatório de comprovantes
    vr_cdcompro    NUMBER;

    -- Variaveis
    vr_excerror    EXCEPTION;
    vr_dsdireto    VARCHAR2(100);
    vr_dsdirgra    VARCHAR2(100);
    vr_dsdlinha    VARCHAR2(500);
    vr_dserhead    VARCHAR2(500); -- Critica a ser replicada no arquivo
    vr_dserrfun    VARCHAR2(500); -- Critica a ser replicada para o funcionario
    vr_dscritic    VARCHAR2(500); -- Critica
    vr_typ_said    VARCHAR2(50); -- Critica
    vr_des_erro    VARCHAR2(500); -- Critica
    vr_tpregist    NUMBER;

    vr_nrdocnpj    crapemp.nrdocnpj%TYPE;
    vr_nrcpfcgc    crapass.nrcpfcgc%TYPE;
    vr_nmempres    VARCHAR2(100);
    vr_cdfuncio    NUMBER;
    vr_dtrefere    DATE;
    vr_cdevento    NUMBER;
    vr_dsevento    VARCHAR2(50);
    vr_vlevento    NUMBER;
    vr_indebcre    VARCHAR2(1);
    vr_vlrefere    NUMBER;
    vr_sqevento    NUMBER;
    vr_vltotdes    NUMBER;
    vr_vltotvcm    NUMBER;
    vr_vltotliq    NUMBER;
    vr_qttotarq    PLS_INTEGER;
    vr_vlliqind    NUMBER;
    vr_vlslrbas    NUMBER;
    vr_vlslinss    NUMBER;
    vr_vlfxirpf    NUMBER;
    vr_vlbsfgts    NUMBER;
    vr_vlfgtsms    NUMBER;
    vr_vlbsirpf    NUMBER;
    vr_vltotarq    NUMBER;

    vr_nmprimtl    crapass.nmprimtl%TYPE;
    vr_dsdcargo    VARCHAR2(100);
    vr_dtadmiss    DATE;
    vr_nrdconta    NUMBER;
    vr_qtdregok    NUMBER;
    vr_qtregerr    NUMBER;
    vr_qtdcmpok    NUMBER;
    vr_qtcmperr    NUMBER;
    vr_nrseqvld    NUMBER;
    vr_intemerr    BOOLEAN;
    vr_indeitm     NUMBER;

    vr_utlfileh    UTL_FILE.file_type;
    vr_dsitmxml    VARCHAR2(32500); -- Auxiliar para XML
    vr_retxml      XMLType;
    vr_dsauxml     varchar2(32767);
   -- Procedure auxiliar para adicionar as criticas do arquivo
    PROCEDURE pc_add_critica(vr_cdcompro IN NUMBER
                            ,pr_dsdconta IN VARCHAR2
                            ,pr_dscpfcgc IN VARCHAR2
                            ,pr_dsorigem IN VARCHAR2
                            ,pr_dscritic IN VARCHAR2
                            ,pr_dsdescri IN VARCHAR2
                            ,pr_iddstipo IN VARCHAR2
                            ,pr_vlrpagto IN VARCHAR2
                            ,pr_inderror IN BOOLEAN) IS

      nrindice    NUMBER;

    BEGIN

      BEGIN
        nrindice := 1;
        -- Indice para inclusão da crítica
        nrindice := vr_tbcritic(vr_cdcompro).count() + 1;
      EXCEPTION
        WHEN no_data_found THEN
          nrindice := 1;
      END;

      -- Inserir a critica no registro de memória
      vr_tbcritic(vr_cdcompro)(nrindice).dscritic := pr_dscritic;
      vr_tbcritic(vr_cdcompro)(nrindice).nrdlinha := nrindice;
      vr_tbcritic(vr_cdcompro)(nrindice).dsdconta := TRIM(pr_dsdconta);
      vr_tbcritic(vr_cdcompro)(nrindice).dscpfcgc := TRIM(pr_dscpfcgc);
      vr_tbcritic(vr_cdcompro)(nrindice).dsorigem := pr_dsorigem;
      vr_tbcritic(vr_cdcompro)(nrindice).dscritic := pr_dscritic;
      vr_tbcritic(vr_cdcompro)(nrindice).dsdescri := GENE0007.fn_convert_db_web(pr_dsdescri);
      vr_tbcritic(vr_cdcompro)(nrindice).iddstipo := pr_iddstipo;

      BEGIN
         vr_tbcritic(vr_cdcompro)(nrindice).vlrpagto := to_char((to_number(TRIM(pr_vlrpagto))/100),'FM9G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.');
      EXCEPTION
        WHEN OTHERS THEN
         CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
         vr_tbcritic(vr_cdcompro)(nrindice).vlrpagto := TRIM(pr_vlrpagto);
      END;

      -- Guarda a indicação de erro ou sucesso
      IF pr_inderror THEN
        vr_tbcritic(vr_cdcompro)(nrindice).inderror := 1;
      ELSE
        vr_tbcritic(vr_cdcompro)(nrindice).inderror := 0; -- REgistro de sucesso
      END IF;

    END pc_add_critica;

    -- Procedure auxiliar para adicionar as criticas do arquivo
    PROCEDURE pc_critica_todos(pr_cdcompro IN NUMBER, pr_dscritic IN VARCHAR2) IS

    BEGIN
      -- SE há registros
      IF vr_tbcritic.count() > 0 THEN
        -- Percorrer por comprovantes
        FOR cmp IN vr_tbcritic.FIRST..vr_tbcritic.LAST LOOP

          IF cmp <> NVL(pr_cdcompro,cmp) THEN
            CONTINUE;
          END IF;

          -- Alterar a critica de todos os registros, atribuindo a critica do trailer do arquivo
          FOR ind IN vr_tbcritic(cmp).FIRST..vr_tbcritic(cmp).LAST LOOP
            -- Se for um registro de sucesso
            IF vr_tbcritic(cmp)(ind).inderror = 0 THEN
              vr_tbcritic(cmp)(ind).dscritic := pr_dscritic;
              vr_tbcritic(cmp)(ind).inderror := 1;
            END IF;
          END LOOP;

        END LOOP;
      END IF;
    END pc_critica_todos;

  BEGIN

    --> Verificar cooperativa
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);    
    FETCH cr_crapcop INTO rw_crapcop;
      
    --> verificar se encontra registro
    IF cr_crapcop%NOTFOUND THEN      
      CLOSE cr_crapcop;    
        
      pr_dscritic := 'Cooperativa de destino nao cadastrada.';      
      RAISE vr_excerror;      
    ELSE
      CLOSE cr_crapcop;
    END IF;  

    IF pr_iddspscp = 0 THEN -- Diretorio de upload do gnusites                                           
    -- Busca o diretório do upload do arquivo
    vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => 'upload');

      -- Realizar a cópia do arquivo
      GENE0001.pc_OScommand_Shell(gene0001.fn_param_sistema('CRED',0,'SCRIPT_RECEBE_ARQUIVOS')||pr_dsdireto||pr_dsarquiv||' S'
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_des_erro);

      -- Testar erro
      IF vr_typ_said = 'ERR' THEN
        -- O comando shell executou com erro, gerar log e sair do processo
        pr_dscritic := 'Erro realizar o upload do arquivo: ' || vr_des_erro;
        RAISE vr_excerror;
      END IF;
    ELSE
      vr_dsdireto := gene0001.fn_diretorio('C',0)                                ||
                     gene0001.fn_param_sistema('CRED',0,'PATH_DOWNLOAD_ARQUIVO') ||
                     '/'                                                         ||
                     rw_crapcop.dsdircop                                         ||
                     '/upload';
      END IF;

    -- Verifica se o arquivo existe
    IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdireto||'/'||pr_dsarquiv) THEN
      -- Retorno de erro
      pr_dscritic := 'Erro no upload do arquivo: '||REPLACE(vr_dsdireto,'/','-')||'-'||pr_dsarquiv;
      RAISE vr_excerror;
    END IF;

    -- Criar cabecalho do XML
    IF pr_idorigem <> 3 THEN
       vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    END IF;
    -- Abrir o arquivos
    GENE0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto
                            ,pr_nmarquiv => pr_dsarquiv
                            ,pr_tipabert => 'R'
                            ,pr_utlfileh => vr_utlfileh
                            ,pr_des_erro => pr_dscritic);

    -- Verifica se houve erros na abertura do arquivo
    IF pr_dscritic IS NOT NULL THEN
      pr_dscritic := 'Erro ao abrir o arquivo: '||pr_dsarquiv;
      RAISE vr_excerror;
    END IF;

    -- Se o arquivo estiver aberto
    IF  utl_file.IS_OPEN(vr_utlfileh) THEN

      -- Percorrer as linhas do arquivo
      LOOP
        -- Limpa a variável que receberá a linha do arquivo
        vr_dsdlinha := NULL;

        BEGIN
          -- Lê a linha do arquivo
          GENE0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsdlinha);

          -- Eliminar possíveis espaços das linhas
          vr_dsdlinha := REPLACE(REPLACE(vr_dsdlinha,chr(10),NULL),chr(13), NULL);

        EXCEPTION
          WHEN no_data_found THEN
            -- Acabou a leitura, então finaliza o loop
            EXIT;
        END;

        -- Copia a linha do arquivo para a tabela de memória
        vr_tbarquiv( vr_tbarquiv.COUNT() + 1 ) := vr_dsdlinha;

      END LOOP; -- Finaliza o loop das linhas do arquivo

      -- Fechar o arquivo
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);

    END IF;

    -- Excluir o arquivo, pois desse ponto em diante irá trabalhar com o registro
    -- de memória. Em caso de erros o programa abortará e o usuário irá realizar
    -- novamente o envio do arquivo
    GENE0001.pc_OScommand_Shell('rm ' || vr_dsdireto || '/' || pr_dsarquiv);

    -- Se não houverem dados no registro de memória
    IF vr_tbarquiv.COUNT() = 0 THEN
      pr_dscritic := GENE0007.fn_convert_db_web('Dados nao encontrados no arquivo.');
      RAISE vr_excerror;
    END IF;

    -- Percorrer todos os registros da tabela de memória
    FOR ind IN vr_tbarquiv.FIRST()..vr_tbarquiv.last() LOOP

      -- Verifica se a linha possui a quantidade de caracteres padrão
      IF length(vr_tbarquiv(ind)) <> 160 THEN
        pr_dscritic := GENE0007.fn_convert_db_web('Linha '||ind||' com tamanho invalido. ');
        RAISE vr_excerror;
      END IF;

      /** TIPO DO REGISTRO **/
      -- Verificar se o tipo do registro é numerico
      BEGIN
        vr_tpregist := to_number(substr(vr_tbarquiv(ind), 0, 1));
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- Erro
          pr_dscritic := GENE0007.fn_convert_db_web('Tipo do registro invalido! Linha: '||ind||'.');
          -- Adiciona a crítica
          RAISE vr_excerror;
      END;

      -- Verificar o tipo de registro - 0 - Header do Arquivo
      IF vr_tpregist = 0 THEN

        -- Limpar variável de erro
        vr_dserhead := NULL;

        -- Verificar o código CPF / CNPJ é numérico
        BEGIN
          vr_nrdocnpj := to_number(TRIM(Substr(vr_tbarquiv(ind),83,8)));
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar CNPJ inválido
            pr_dscritic := GENE0007.fn_convert_db_web('Caracteres invalidos no CNPJ!');
            RAISE vr_excerror;
        END;

        -- Verifica se a origem é internet Banking
        IF pr_idorigem = 3 THEN
          -- Buscar dados da empresa/conta logada
          OPEN  cr_crapemp(pr_cdcooper, pr_nrdconta);
          FETCH cr_crapemp INTO rw_crapemp;
          -- Se não encontrar registro
          IF cr_crapemp%NOTFOUND THEN
            pr_dscritic := GENE0007.fn_convert_db_web('Dados da empresa nao encontrados.');
            CLOSE cr_crapemp;
            RAISE vr_excerror;
          END IF;
          CLOSE cr_crapemp;

          -- Verifica se o CNPJ logado eh o mesmo do informado no arquivo
          IF rw_crapemp.nrbscnpj <> vr_nrdocnpj THEN
            -- Criticar CNPJ divergente do cadastro da empresa
            pr_dscritic := GENE0007.fn_convert_db_web('CNPJ do arquivo nao confere com CNPJ Internet Banking!');
            RAISE vr_excerror;
          END IF;

        END IF;

        -- Ler o nome da empresa
        vr_nmempres := TRIM(Substr(vr_tbarquiv(ind),36,47));
        -- Ler a data de referencia
        BEGIN
          vr_dtrefere := to_date(TRIM(Substr(vr_tbarquiv(ind),97,6)), 'YYYYMM');
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar CNPJ inválido
            pr_dscritic := GENE0007.fn_convert_db_web('Caracteres invalidos na Data Referencia!');
            RAISE vr_excerror;
        END;

      -- Se tipo de registro for 1-Header do Funcionario
      ELSIF vr_tpregist = 1 THEN

        -- Limpar erro do cabeçalho do funcionario
        vr_dserrfun := NULL;
        rw_craplfp  := NULL;

        -- Conta a quantidade de comprovantes
        vr_cdcompro := NVL(vr_cdcompro,0) + 1;

        -- Zerar o sequencial a cada nova pessoa
        vr_sqevento := 0;

        -- Ler a conta
        BEGIN
          vr_nrdconta := to_number(TRIM(Substr(vr_tbarquiv(ind),108,12)));
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar CNPJ inválido
            vr_dscritic := GENE0007.fn_convert_db_web('Caracteres inválidos na Conta!');
            vr_dserrfun := vr_dscritic;

            -- Criticar todas as demais linhas
            pc_add_critica(vr_cdcompro
                          ,NULL                                  -- pr_dsdconta
                          ,NULL                                  -- pr_dscpfcgc
                          ,'X'                                   -- pr_dsorigem
                          ,vr_dserhead                           -- pr_dscritic
                          ,NULL                                  -- pr_dsdescri
                          ,NULL                                  -- pr_iddstipo
                          ,NULL                                  -- pr_vlrpagto
                          ,TRUE);                                -- pr_inderror

            CONTINUE;
        END;

        -- Se a origem for internet banking
        IF pr_idorigem = 3 THEN
          -- Buscar informações da CRAPLFP
          OPEN  cr_craplfp(pr_cdcooper          -- Cooperativa logada
                          ,rw_crapemp.cdempres  -- Código da empresa associada
                          ,pr_nrseqpag          -- Pagamento selecionado na tela
                          ,vr_nrdconta);        -- Número de conta lida do arquivo
          FETCH cr_craplfp INTO rw_craplfp;
          CLOSE cr_craplfp;
          -- verifica se encontrou lançamentos
          --IF NVL(rw_craplfp.qtlancto,0) > 0 THEN
          IF NVL(rw_craplfp.qtlancto,0) = 0 THEN
            vr_dscritic := GENE0007.fn_convert_db_web('Número Conta não consta nos lançamentos desse Pagamento!');
            vr_dserrfun := vr_dscritic;

            -- Adiciona a crítica
            pc_add_critica(vr_cdcompro
                          ,TRIM(gene0002.fn_mask_conta(vr_nrdconta))   -- pr_dsdconta
                          ,TRIM(Substr(vr_tbarquiv(ind), 42,11)) -- pr_dscpfcgc
                          ,rw_craplfp.dsorigem                   -- pr_dsorigem
                          ,vr_dscritic                           -- pr_dscritic
                          ,NULL                                  -- pr_dsdescri
                          ,NULL                                  -- pr_iddstipo
                          ,NULL                                  -- pr_vlrpagto
                          ,TRUE);                                -- pr_inderror

            CONTINUE;
          END IF;
         -- CLOSE cr_craplfp;
        END IF;

        -- Verificar o código do funcionário na empresa
        BEGIN
          vr_cdfuncio := to_number(TRIM(Substr(vr_tbarquiv(ind),37,5)));
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar CPF inválido
            vr_dscritic := GENE0007.fn_convert_db_web('Caracteres inválidos no Código do Funcionário!');
            vr_dserrfun := vr_dscritic;

            -- Adiciona a crítica
            pc_add_critica(vr_cdcompro
                          ,TRIM(gene0002.fn_mask_conta(vr_nrdconta))   -- pr_dsdconta
                          ,TRIM(Substr(vr_tbarquiv(ind), 42,11)) -- pr_dscpfcgc
                          ,rw_craplfp.dsorigem                   -- pr_dsorigem
                          ,vr_dscritic                           -- pr_dscritic
                          ,NULL                                  -- pr_dsdescri
                          ,NULL                                  -- pr_iddstipo
                          ,NULL                                  -- pr_vlrpagto
                          ,TRUE);                                -- pr_inderror

            CONTINUE;
        END;

        -- Verificar o código CPF / CNPJ é numérico
        BEGIN
          vr_nrcpfcgc := to_number(TRIM(Substr(vr_tbarquiv(ind),42,11)));
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar CPF inválido
            vr_dscritic := GENE0007.fn_convert_db_web('Caracteres inválidos no CPF!');
            vr_dserrfun := vr_dscritic;

            -- Adiciona a crítica
            pc_add_critica(vr_cdcompro
                          ,TRIM(gene0002.fn_mask_conta(vr_nrdconta))   -- pr_dsdconta
                          ,TRIM(Substr(vr_tbarquiv(ind), 42,11)) -- pr_dscpfcgc
                          ,rw_craplfp.dsorigem                   -- pr_dsorigem
                          ,vr_dscritic                           -- pr_dscritic
                          ,NULL                                  -- pr_dsdescri
                          ,NULL                                  -- pr_iddstipo
                          ,NULL                                  -- pr_vlrpagto
                          ,TRUE);                                -- pr_inderror

            CONTINUE;
        END;

        -- Verifica se o CPF do arquivo é o mesmo do banco de dados
        IF rw_crassccs.nrcpfcgc <> vr_nrcpfcgc THEN
          -- Criticar CPF inválido
          vr_dscritic := GENE0007.fn_convert_db_web('CPF do arquivo diverge do CPF da conta informada!');
          vr_dserrfun := vr_dscritic;

          -- Adiciona a crítica
          pc_add_critica(vr_cdcompro
                        ,TRIM(gene0002.fn_mask_conta(vr_nrdconta))-- pr_dsdconta
                        ,gene0002.fn_mask_cpf_cnpj(vr_nrcpfcgc,1) -- pr_dscpfcgc
                        ,rw_craplfp.dsorigem                      -- pr_dsorigem
                        ,vr_dscritic                              -- pr_dscritic
                        ,NULL                                     -- pr_dsdescri
                        ,NULL                                     -- pr_iddstipo
                        ,NULL                                     -- pr_vlrpagto
                        ,TRUE);                                   -- pr_inderror

          CONTINUE;
        END IF;

        -- Ler e guardar o nome
        vr_nmprimtl := TRIM(Substr(vr_tbarquiv(ind),53,47));

        -- Se for I.Bank
        IF pr_idorigem = 3 THEN

          -- Ler e guardar a descrição do cargo
          vr_dsdcargo := TRIM(Substr(vr_tbarquiv(ind),120,40));

          -- Ler a data de referencia
          BEGIN
            vr_dtadmiss := to_date(TRIM(Substr(vr_tbarquiv(ind),100,8)), 'YYYYMMDD');
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              -- Criticar CNPJ inválido
              vr_dscritic := GENE0007.fn_convert_db_web('Data de admissão inválida!');
              vr_dserrfun := vr_dscritic;

              -- Adiciona a crítica
              pc_add_critica(vr_cdcompro
                            ,TRIM(gene0002.fn_mask_conta(vr_nrdconta))   -- pr_dsdconta
                            ,gene0002.fn_mask_cpf_cnpj(vr_nrcpfcgc,1) -- pr_dscpfcgc
                            ,rw_craplfp.dsorigem                   -- pr_dsorigem
                            ,vr_dscritic                           -- pr_dscritic
                            ,NULL                                  -- pr_dsdescri
                            ,NULL                                  -- pr_iddstipo
                            ,NULL                                  -- pr_vlrpagto
                            ,TRUE);                                -- pr_inderror

              CONTINUE;
          END;

        END IF;

        /******************************************************************************************/
        -------------------------
        -- Aviso de Registro lido com sucesso
        pc_add_critica(vr_cdcompro
                      ,TRIM(gene0002.fn_mask_conta(vr_nrdconta))   -- pr_dsdconta
                      ,gene0002.fn_mask_cpf_cnpj(vr_nrcpfcgc,1) -- pr_dscpfcgc
                      ,rw_craplfp.dsorigem                   -- pr_dsorigem
                      ,'Registro lido com Sucesso!'          -- pr_dscritic
                      ,NULL                                  -- pr_dsdescri
                      ,NULL                                  -- pr_iddstipo
                      ,NULL                                  -- pr_vlrpagto
                      ,FALSE);                               -- pr_inderror

        --------------------------
        -- Registrar os dados na tabela de memória
        vr_tbdatrel(vr_cdcompro).dtref     := to_char(vr_dtrefere,'mm/yyyy');
        vr_tbdatrel(vr_cdcompro).cdemp     := rw_crapemp.cdempres;
        vr_tbdatrel(vr_cdcompro).nmemp     := rw_crapemp.nmextemp;
        vr_tbdatrel(vr_cdcompro).idtpemp   := rw_crapemp.idtpempr;
        vr_tbdatrel(vr_cdcompro).nrdocnpj  := TRIM(GENE0002.fn_mask_cpf_cnpj(rw_crapemp.Nrdocnpj,2));
        vr_tbdatrel(vr_cdcompro).nrcpfcgc  := TRIM(GENE0002.fn_mask_cpf_cnpj(vr_nrcpfcgc,1));
        vr_tbdatrel(vr_cdcompro).cdfunc    := vr_cdfuncio;
        vr_tbdatrel(vr_cdcompro).nmfunc    := vr_nmprimtl;
        vr_tbdatrel(vr_cdcompro).dtadmis   := TO_CHAR(vr_dtadmiss,'DD/MM/RRRR');
        vr_tbdatrel(vr_cdcompro).dscargo   := vr_dsdcargo;
        /******************************************************************************************/

      -- Se tipo de registro for 2-Detalhes do comprovante
      ELSIF vr_tpregist = 2 THEN

        -- Verifica se há critica do header do arquivo
        IF vr_dserhead IS NOT NULL THEN
          -- Criticar todas as demais linhas
          pc_add_critica(vr_cdcompro
                        ,NULL                                  -- pr_dsdconta
                        ,NULL                                  -- pr_dscpfcgc
                        ,NULL                                  -- pr_dsorigem
                        ,vr_dserhead                           -- pr_dscritic
                        ,TRIM(Substr(vr_tbarquiv(ind),32,25))  -- pr_dsdescri
                        ,TRIM(Substr(vr_tbarquiv(ind),69,1))   -- pr_iddstipo
                        ,TRIM(Substr(vr_tbarquiv(ind),58,9))   -- pr_vlrpagto
                        ,TRUE);                                -- pr_inderror

          -- Sequencial dos eventos
          vr_sqevento := to_number(TRIM(substr(vr_tbarquiv(ind),22,3)));

          -- Próxima linha
          CONTINUE;
        END IF;

        -- Verifica se há critica do header do funcionario
        IF vr_dserrfun IS NOT NULL THEN
          -- Criticar todas as demais linhas
          pc_add_critica(vr_cdcompro
                        ,NULL                                  -- pr_dsdconta
                        ,NULL                                  -- pr_dscpfcgc
                        ,NULL                                  -- pr_dsorigem
                        ,vr_dserrfun                           -- pr_dscritic
                        ,TRIM(Substr(vr_tbarquiv(ind),32,25))  -- pr_dsdescri
                        ,TRIM(Substr(vr_tbarquiv(ind),69,1))   -- pr_iddstipo
                        ,TRIM(Substr(vr_tbarquiv(ind),58,9))   -- pr_vlrpagto
                        ,TRUE);                                -- pr_inderror

          -- Sequencial dos eventos
          vr_sqevento := to_number(TRIM(substr(vr_tbarquiv(ind),22,3)));

          -- Próxima linha
          CONTINUE;
        END IF;

        -- Sequencial de controle dos eventos
        IF (NVL(vr_sqevento,0) + 1) <> to_number(TRIM(substr(vr_tbarquiv(ind),22,3))) THEN
          -- Criticar erro no sequencial dos eventos
          vr_dscritic := GENE0007.fn_convert_db_web('Erro('||(NVL(vr_sqevento,0) + 1)||'-'||TRIM(substr(vr_tbarquiv(ind),22,3))||') no Sequencial de Eventos!');

          -- Adiciona a crítica
          pc_add_critica(vr_cdcompro
                        ,NULL                                  -- pr_dsdconta
                        ,NULL                                  -- pr_dscpfcgc
                        ,NULL                                  -- pr_dsorigem
                        ,vr_dscritic                           -- pr_dscritic
                        ,vr_dsevento                           -- pr_dsdescri
                        ,vr_indebcre                           -- pr_iddstipo
                        ,TRIM(Substr(vr_tbarquiv(ind),58,9))   -- pr_vlrpagto
                        ,TRUE);                                -- pr_inderror

          vr_sqevento := (NVL(vr_sqevento,0) + 1);

          CONTINUE;
        ELSE
          vr_sqevento := to_number(TRIM(substr(vr_tbarquiv(ind),22,3)));
        END IF;

        -- Armazenar descrição do evento
        vr_dsevento := TRIM(Substr(vr_tbarquiv(ind),32,25));

        -- Armazenar e validar o codigo do evento
        BEGIN
          vr_cdevento := TRIM(Substr(vr_tbarquiv(ind),25,7));
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar CPF inválido
            vr_dscritic := GENE0007.fn_convert_db_web('Caracteres inválidos no Código do Evento!');
            -- Adiciona a crítica
            pc_add_critica(vr_cdcompro
                          ,NULL                                  -- pr_dsdconta
                          ,NULL                                  -- pr_dscpfcgc
                          ,NULL                                  -- pr_dsorigem
                          ,vr_dscritic                           -- pr_dscritic
                          ,vr_dsevento                           -- pr_dsdescri
                          ,TRIM(Substr(vr_tbarquiv(ind),69,1))   -- pr_iddstipo
                          ,TRIM(Substr(vr_tbarquiv(ind),58,9))   -- pr_vlrpagto
                          ,TRUE);                                -- pr_inderror
            CONTINUE;
        END;

        -- Armazenar e validar o valor do evento
        BEGIN
          vr_vlevento := to_number(TRIM(Substr(vr_tbarquiv(ind),58,9)))/100;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar CPF inválido
            vr_dscritic := GENE0007.fn_convert_db_web('Caracteres inválidos no Valor do Evento!');
            -- Adiciona a crítica
            pc_add_critica(vr_cdcompro
                          ,NULL                                  -- pr_dsdconta
                          ,NULL                                  -- pr_dscpfcgc
                          ,NULL                                  -- pr_dsorigem
                          ,vr_dscritic                           -- pr_dscritic
                          ,vr_dsevento                           -- pr_dsdescri
                          ,TRIM(Substr(vr_tbarquiv(ind),69,1))   -- pr_iddstipo
                          ,TRIM(Substr(vr_tbarquiv(ind),58,9))   -- pr_vlrpagto
                          ,TRUE);                                -- pr_inderror
            CONTINUE;
        END;

        -- Armazenar o indicador de Débito e Crédito
        vr_indebcre := TRIM(Substr(vr_tbarquiv(ind),69,1));

        -- Validar indicador de Débito e Crédito
        IF vr_indebcre NOT IN ('C','D') THEN
          vr_dscritic := GENE0007.fn_convert_db_web('Indicador Débito/Crédito inválido!');

          -- Adiciona a crítica
          pc_add_critica(vr_cdcompro
                        ,NULL                                  -- pr_dsdconta
                        ,NULL                                  -- pr_dscpfcgc
                        ,NULL                                  -- pr_dsorigem
                        ,vr_dscritic                           -- pr_dscritic
                        ,vr_dsevento                           -- pr_dsdescri
                        ,vr_indebcre                           -- pr_iddstipo
                        ,TRIM(Substr(vr_tbarquiv(ind),58,9))   -- pr_vlrpagto
                        ,TRUE);                                -- pr_inderror

          CONTINUE;
        END IF;

        -- Armazenar e validar o valor do evento
        BEGIN
          vr_vlrefere := to_number(TRIM(Substr(vr_tbarquiv(ind),75,5)))/100;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar referência
            vr_dscritic := GENE0007.fn_convert_db_web('Caracteres inválidos na Referência!');

            -- Adiciona a crítica
            pc_add_critica(vr_cdcompro
                          ,NULL                                  -- pr_dsdconta
                          ,NULL                                  -- pr_dscpfcgc
                          ,NULL                                  -- pr_dsorigem
                          ,vr_dscritic                           -- pr_dscritic
                          ,vr_dsevento                           -- pr_dsdescri
                          ,vr_indebcre                           -- pr_iddstipo
                          ,TRIM(Substr(vr_tbarquiv(ind),58,9))   -- pr_vlrpagto
                          ,TRUE);                                -- pr_inderror

            CONTINUE;
        END;

        /********************************************************************************/
        -------------------------
        -- Aviso de Registro lido com sucesso
        pc_add_critica(vr_cdcompro
                      ,NULL                                  -- pr_dsdconta
                      ,NULL                                  -- pr_dscpfcgc
                      ,NULL                                  -- pr_dsorigem
                      ,'Registro lido com Sucesso!'          -- pr_dscritic
                      ,vr_dsevento                           -- pr_dsdescri
                      ,vr_indebcre                           -- pr_iddstipo
                      ,TRIM(Substr(vr_tbarquiv(ind),58,9))   -- pr_vlrpagto
                      ,FALSE);                               -- pr_inderror

        --------------------------
        vr_indeitm := vr_tbdatrel(vr_cdcompro).tbdeitm.COUNT() + 1;
        vr_tbdatrel(vr_cdcompro).tbdeitm(vr_indeitm).cod    := vr_cdevento;
        vr_tbdatrel(vr_cdcompro).tbdeitm(vr_indeitm).dscr   := vr_dsevento;
        vr_tbdatrel(vr_cdcompro).tbdeitm(vr_indeitm).refe   := to_char(vr_vlrefere,'FM99G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.');
        -- Conforme indicador de crédito e débido
        IF vr_indebcre = 'C' THEN
          vr_tbdatrel(vr_cdcompro).tbdeitm(vr_indeitm).venc := to_char(vr_vlevento,'FM99G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.');
        ELSE
          vr_tbdatrel(vr_cdcompro).tbdeitm(vr_indeitm).dcto := to_char(vr_vlevento,'FM99G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.');
        END IF;
        /********************************************************************************/
      -- Se tipo de registro for 3-Rodapé/Trailer
      ELSIF vr_tpregist = 3 THEN
        -- Se há erro no head do lote, não valida o trailer
        IF vr_dserhead IS NOT NULL OR vr_dserrfun IS NOT NULL THEN
          CONTINUE;
        END IF;

        -- Valor total de descontos
        BEGIN
          vr_vltotdes := to_number(TRIM(Substr(vr_tbarquiv(ind),22,15)))/100;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar valor
            vr_dscritic := GENE0007.fn_convert_db_web('Caracteres inválidos no Total de Descontos! ['||TRIM(GENE0002.fn_mask_conta(vr_nrdconta))||']');

            -- Criticar todos os registros de sucesso
            pc_critica_todos(vr_cdcompro, vr_dscritic);

            CONTINUE;
        END;

        -- Valor total de vencimentos
        BEGIN
          vr_vltotvcm := to_number(TRIM(Substr(vr_tbarquiv(ind),37,15)))/100;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar valor
            vr_dscritic := GENE0007.fn_convert_db_web('Caracteres inválidos no Total de Vencimentos! ['||TRIM(GENE0002.fn_mask_conta(vr_nrdconta))||']');

            -- Criticar todos os registros de sucesso
            pc_critica_todos(vr_cdcompro, vr_dscritic);

            CONTINUE;
        END;

        -- Valor líquido
        BEGIN
          vr_vlliqind := to_number(TRIM(Substr(vr_tbarquiv(ind),52,15)))/100;
          vr_vltotliq := NVL(vr_vltotliq,0) + vr_vlliqind;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar valor
            vr_dscritic := GENE0007.fn_convert_db_web('Caracteres inválidos no Valor Líquido! ['||TRIM(GENE0002.fn_mask_conta(vr_nrdconta))||']');

            -- Criticar todos os registros de sucesso
            pc_critica_todos(vr_cdcompro, vr_dscritic);

            CONTINUE;
        END;

        -- Se origem for internet banking
       IF pr_idorigem = 3 THEN
          -- Verifica se o valor que está no campo coincide com o valor da CRAPLFP
          IF vr_vlliqind <> rw_craplfp.vllancto THEN
            -- Criticar diferenças nos valores
            vr_dscritic := GENE0007.fn_convert_db_web('Valor do Crédito diverge do Valor Líquido do arquivo! ['||TRIM(GENE0002.fn_mask_conta(vr_nrdconta))||']');

            -- Criticar todos os registros de sucesso
            pc_critica_todos(vr_cdcompro, vr_dscritic);
            CONTINUE;
          ELSE
            -- Gravamos a chave da tabela de lançamentos
            vr_tbdatrel(vr_cdcompro).nrseqlfp := rw_craplfp.nrseqlfp;
          END IF;
        END IF;

        -- Valor do Salário base
        BEGIN
          vr_vlslrbas := to_number(TRIM(Substr(vr_tbarquiv(ind),77,15)))/100;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar valor
            vr_dscritic := GENE0007.fn_convert_db_web('Caracteres inválidos no Salário Base! ['||TRIM(GENE0002.fn_mask_conta(vr_nrdconta))||']');

            -- Criticar todos os registros de sucesso
            pc_critica_todos(vr_cdcompro, vr_dscritic);

            CONTINUE;
        END;

        -- Valor do Salário CONTR.INSS
        BEGIN
          vr_vlslinss := to_number(TRIM(Substr(vr_tbarquiv(ind),92,15)))/100;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar valor
            vr_dscritic := GENE0007.fn_convert_db_web('Caracteres inválidos no Salário Contr.INSS! ['||TRIM(GENE0002.fn_mask_conta(vr_nrdconta))||']');

            -- Criticar todos os registros de sucesso
            pc_critica_todos(vr_cdcompro, vr_dscritic);

            CONTINUE;
        END;

        -- Valor de faixa IRPF
        BEGIN
          vr_vlfxirpf := to_number(TRIM(Substr(vr_tbarquiv(ind),107,4)))/100;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar valor
            vr_dscritic := GENE0007.fn_convert_db_web('Caracteres inválidos na Faixa IRPF! ['||TRIM(GENE0002.fn_mask_conta(vr_nrdconta))||']');

            -- Criticar todos os registros de sucesso
            pc_critica_todos(vr_cdcompro, vr_dscritic);

            CONTINUE;
        END;

        -- Valor base de calculo FGTS
        BEGIN
          vr_vlbsfgts := to_number(TRIM(Substr(vr_tbarquiv(ind),111,15)))/100;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar valor
            vr_dscritic := GENE0007.fn_convert_db_web('Caracteres inválidos na Base Calc.FGTS! ['||TRIM(GENE0002.fn_mask_conta(vr_nrdconta))||']');

            -- Criticar todos os registros de sucesso
            pc_critica_todos(vr_cdcompro, vr_dscritic);

            CONTINUE;
        END;

        -- Valor de FGTS do mês
        BEGIN
          vr_vlfgtsms := to_number(TRIM(Substr(vr_tbarquiv(ind),126,10)))/100;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar valor
            vr_dscritic := GENE0007.fn_convert_db_web('Caracteres inválidos no FGTS do Mês! ['||TRIM(GENE0002.fn_mask_conta(vr_nrdconta))||']');

            -- Criticar todos os registros de sucesso
            pc_critica_todos(vr_cdcompro, vr_dscritic);

            CONTINUE;
        END;

        -- Valor Base de calculo IRPF
        BEGIN
          vr_vlbsirpf := to_number(TRIM(Substr(vr_tbarquiv(ind),136,15)))/100;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar valor
            vr_dscritic := GENE0007.fn_convert_db_web('Caracteres inválidos no Base Calc.IRPF! ['||TRIM(GENE0002.fn_mask_conta(vr_nrdconta))||']');

            -- Criticar todos os registros de sucesso
            pc_critica_todos(vr_cdcompro, vr_dscritic);

            CONTINUE;
        END;

        /************************************************************************************/
         vr_tbdatrel(vr_cdcompro).salbase  := to_char(vr_vlslrbas,'FM99G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.');
         vr_tbdatrel(vr_cdcompro).salinss  := to_char(vr_vlslinss,'FM99G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.');
         vr_tbdatrel(vr_cdcompro).faixair  := to_char(vr_vlfxirpf,'FM99G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.');
         vr_tbdatrel(vr_cdcompro).totvenc  := to_char(vr_vltotvcm,'FM99G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.');
         vr_tbdatrel(vr_cdcompro).totdesc  := to_char(vr_vltotdes,'FM99G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.');
         vr_tbdatrel(vr_cdcompro).basefgts := to_char(vr_vlbsfgts,'FM99G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.');
         vr_tbdatrel(vr_cdcompro).fgtsmes  := to_char(vr_vlfgtsms,'FM99G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.');
         vr_tbdatrel(vr_cdcompro).baseirpf := to_char(vr_vlbsirpf,'FM99G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.');
         vr_tbdatrel(vr_cdcompro).vlrliqui := to_char(vr_vlliqind,'FM99G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.');

        /************************************************************************************/

      -- Se tipo de registro for 9-Trailer do Arquivo
      ELSIF vr_tpregist = 9 THEN

        -- Valor Total do Arquivo
        BEGIN
          vr_vltotarq := NVL(to_number(TRIM(Substr(vr_tbarquiv(ind),66,15))),0)/100;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar valor
            pr_dscritic := GENE0007.fn_convert_db_web('Caracteres invalidos no Total do Arquivo! ');
            RAISE vr_excerror;
        END;

        -- Quando ib Verificar se o valor total do arquivo bate com o valor líquido
        IF vr_vltotliq <> vr_vltotarq AND pr_idorigem = 3 THEN
          -- Criticar valor
          pr_dscritic := GENE0007.fn_convert_db_web('Valor Total Liquido diverge do somatorio liquido dos funcionarios! ');
          RAISE vr_excerror;
        END IF;

        -- Quantidade total de registros
        BEGIN
          vr_qttotarq := NVL(to_number(TRIM(Substr(vr_tbarquiv(ind),81,10))),0);
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Criticar valor
            pr_dscritic := GENE0007.fn_convert_db_web('Caracteres inválidos no Total de Linhas do Arquivo! ');
           RAISE vr_excerror;
        END;

        -- Verificar se a quantidader total do arquivo bate com o valor líquido
        IF vr_qttotarq <> ind THEN
          -- Criticar valor
          pr_dscritic := GENE0007.fn_convert_db_web('Qtde Total Linhas diverge da Quantidade informada no arquivo! ');
          RAISE vr_excerror;
        END IF;


      END IF;

    END LOOP; -- Loop das linhas do arquivo

    -- Se possui críticas a serem retornadas
    IF vr_tbcritic.COUNT() > 0 THEN

      vr_qtdcmpok := 0;
      vr_qtcmperr := 0;
      vr_qtregerr := 0;
      vr_qtdregok := 0;

      -- Verificar quantos comprovantes foram importados
      -- Percorre todas as mensagens de alerta
      FOR cmp IN vr_tbcritic.FIRST..vr_tbcritic.LAST LOOP
        vr_intemerr := FALSE;

        -- Percorre todas as mensagens de alerta
        FOR ind IN vr_tbcritic(cmp).FIRST..vr_tbcritic(cmp).LAST LOOP
          IF vr_tbcritic(cmp)(ind).inderror = 1 THEN
            vr_qtregerr := NVL(vr_qtregerr,0) + 1;
            vr_intemerr := TRUE;
          ELSE
            vr_qtdregok := NVL(vr_qtdregok,0) + 1;
          END IF;
        END LOOP;

        -- Se encontrou erro
        IF vr_intemerr THEN
          vr_qtcmperr := NVL(vr_qtcmperr,0) + 1;
        ELSE
          vr_qtdcmpok := NVL(vr_qtdcmpok,0) + 1;
        END IF;
      END LOOP;

      -- Se encontrar qualquer registro com erro que seja
      IF NVL(vr_qtregerr,0) > 0 OR NVL(vr_qtcmperr,0) > 0 THEN
        -- Não retorna dados para o relatório
        vr_tbdatrel.DELETE;
      END IF;

      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);

      IF pr_idorigem <> 3 THEN
         gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_dsauxml
                                ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?>' );

      END IF;
      -- Recriar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_dsauxml
                               ,pr_texto_novo     => ('<Root><criticas qtlinerr="'||NVL(vr_qtregerr,0)||'" '||
                                                       'qtdlinok="'||NVL(vr_qtdregok,0)||'" '||
                                                       'dtrefere="'||NVL(to_char(vr_dtrefere,'dd/mm/yyyy'),0)||'" '||
                                                       'qtlintot="'||(NVL(vr_qtdregok,0) + NVL(vr_qtregerr,0))||'" '||
                                                       'qtcmperr="'||NVL(vr_qtcmperr,0)||'" '||
                                                       'qtdcmpok="'||NVL(vr_qtdcmpok,0)||'" '||
                                                       'qtcmptot="'||(NVL(vr_qtdcmpok,0) + NVL(vr_qtcmperr,0))||
                                                       '">'));

           -- Inicializa contador
      vr_nrseqvld := 0;

      -- Percorre todas as mensagens de alerta
      FOR cmp IN vr_tbcritic.FIRST..vr_tbcritic.LAST LOOP
        -- Percorre todas as mensagens de alerta

       FOR ind IN vr_tbcritic(cmp).FIRST..vr_tbcritic(cmp).LAST LOOP

          vr_nrseqvld := NVL(vr_nrseqvld,0) + 1;
          IF vr_tbcritic(cmp)(ind).dscritic <> 'Registro lido com Sucesso!' THEN
              -- Criar nodo filho
               gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                                   ,pr_texto_completo => vr_dsauxml
                                   ,pr_texto_novo     => ('<critica>'
                                                         ||'<nrseqvld>'||to_char(vr_nrseqvld)                    ||'</nrseqvld>'||chr(10)
                                                         ||'<dsdconta>'||NVL(vr_tbcritic(cmp)(ind).dsdconta, ' ')||'</dsdconta>'||chr(10)
                                                         ||'<dscpfcgc>'||NVL(vr_tbcritic(cmp)(ind).dscpfcgc, ' ')||'</dscpfcgc>'||chr(10)
                                                         ||'<dsorigem>'||NVL(vr_tbcritic(cmp)(ind).dsorigem, ' ')||'</dsorigem>'||chr(10)
                                                         ||'<dsdescri>'||NVL(vr_tbcritic(cmp)(ind).dsdescri, ' ')||'</dsdescri>'||chr(10)
                                                         ||'<iddstipo>'||NVL(vr_tbcritic(cmp)(ind).iddstipo, ' ')||'</iddstipo>'||chr(10)
                                                         ||'<vlrpagto>'||NVL(vr_tbcritic(cmp)(ind).vlrpagto, ' ')||'</vlrpagto>'||chr(10)
                                                         ||'<dscritic>'||NVL(vr_tbcritic(cmp)(ind).dscritic, ' ')||'</dscritic>'||chr(10)
                                                         ||'</critica>'||chr(10)));
         END IF;
        END LOOP;
      END LOOP; -- Loop das críticas;
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_dsauxml
                             ,pr_texto_novo     => ('</criticas><folhas>'));

      -- Se encontrar dados de folhas para gerar
      IF vr_tbdatrel.count() > 0 AND pr_idorigem = 3 THEN

        -- Percorre todas as informações para o relatório
        FOR ind IN vr_tbdatrel.FIRST..vr_tbdatrel.LAST LOOP

          -- Limpa o bloco de itens
          vr_dsitmxml := ' ';

          -- Se há itens
          IF vr_tbdatrel(ind).tbdeitm.count > 0 THEN
            -- Gerar sempre 28 linhas
            FOR itm IN 1..28 LOOP
              -- Se posição existe
              IF vr_tbdatrel(ind).tbdeitm.EXISTS(itm) THEN
                -- Monta trecho com dados no XML
                vr_dsitmxml := vr_dsitmxml||
                               '<item>'||
                               '<cod>' ||vr_tbdatrel(ind).tbdeitm(itm).cod ||'</cod>'||
                               '<dscr>'||vr_tbdatrel(ind).tbdeitm(itm).dscr||'</dscr>'||
                               '<refe>'||vr_tbdatrel(ind).tbdeitm(itm).refe||'</refe>'||
                               '<venc>'||vr_tbdatrel(ind).tbdeitm(itm).venc||'</venc>'||
                               '<dsct>'||vr_tbdatrel(ind).tbdeitm(itm).dcto||'</dsct>'||
                               '</item>'||chr(10);
              ELSE
                -- Monta trecho com linha em branco
                vr_dsitmxml := vr_dsitmxml||'<item><cod/><dscr/><refe/><venc/><dsct/></item>'||chr(10);
              END IF;
            END LOOP;
          END IF;

          gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                            ,pr_texto_completo => vr_dsauxml
                            ,pr_texto_novo     => ('<xml nrseqlfp="'||vr_tbdatrel(ind).nrseqlfp||'">'||chr(10)
                                                   ||'<head>'
                                                   ||'<tpcomprv>C</tpcomprv>'
                                                   ||'<dtref>'   ||vr_tbdatrel(ind).dtref   ||'</dtref>'
                                                   ||'<cdemp>'   ||vr_tbdatrel(ind).cdemp   ||'</cdemp>'
                                                   ||'<nmemp>'   ||vr_tbdatrel(ind).nmemp   ||'</nmemp>'
                                                   ||'<idtpemp>' ||vr_tbdatrel(ind).idtpemp ||'</idtpemp>'
                                                   ||'<nrdocnpj>'||vr_tbdatrel(ind).nrdocnpj||'</nrdocnpj>'
                                                   ||'<nrcpfcgc>'||vr_tbdatrel(ind).nrcpfcgc||'</nrcpfcgc>'
                                                   ||'<cdfunc>'  ||vr_tbdatrel(ind).cdfunc  ||'</cdfunc>'
                                                   ||'<nmfunc>'  ||vr_tbdatrel(ind).nmfunc  ||'</nmfunc>'
                                                   ||'<dtadmis>' ||vr_tbdatrel(ind).dtadmis ||'</dtadmis>'
                                                   ||'<dscargo>' ||vr_tbdatrel(ind).dscargo ||'</dscargo>'
                                                   ||'</head>'||chr(10)
                                                   ||'<body>'||chr(10)
                                                   ||vr_dsitmxml
                                                   ||'</body>'||chr(10)
                                                   ||'<foot>'
                                                   ||'<salbase>' ||vr_tbdatrel(ind).salbase ||'</salbase>'
                                                   ||'<salinss>' ||vr_tbdatrel(ind).salinss ||'</salinss>'
                                                   ||'<faixair>' ||vr_tbdatrel(ind).faixair ||'</faixair>'
                                                   ||'<totvenc>' ||vr_tbdatrel(ind).totvenc ||'</totvenc>'
                                                   ||'<totdesc>' ||vr_tbdatrel(ind).totdesc ||'</totdesc>'
                                                   ||'<basefgts>'||vr_tbdatrel(ind).basefgts||'</basefgts>'
                                                   ||'<fgtsmes>' ||vr_tbdatrel(ind).fgtsmes ||'</fgtsmes>'
                                                   ||'<baseirpf>'||vr_tbdatrel(ind).baseirpf||'</baseirpf>'
                                                   ||'<vlrliqui>'||vr_tbdatrel(ind).vlrliqui||'</vlrliqui>'
                                                   ||'</foot>'||chr(10)
                                                   ||'</xml>'));
        END LOOP;
        -- Encerrar tag Folhas
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_dsauxml
                             ,pr_texto_novo     => ('</folhas></Root>'||chr(10))
                             ,pr_fecha_xml      => TRUE);
                             
        vr_dsdirgra := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'upload');
       
        -- Ao final, iremos gravar o XML na pasta Upload para gravação caso o usuário clique no botão gravar
        gene0002.pc_XML_para_arquivo(pr_XML      => pr_retxml
                                    ,pr_caminho  => vr_dsdirgra              -- Diretório Upload
                                    ,pr_arquivo  => pr_dsarquiv||'.proc.xml' -- Nome Original + .proc.xml
                                    ,pr_des_erro => pr_dscritic);
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_excerror;
        END IF;
      ELSE
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_dsauxml
                               ,pr_texto_novo     => ('</folhas></Root>')
                               ,pr_fecha_xml      => TRUE);
      END IF;

    END IF;

  EXCEPTION
    WHEN vr_excerror THEN
      pr_dscritic := pr_dscritic;

      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
     IF pr_idorigem = 3 THEN
          vr_retxml := XMLType.createXML('<Root><DSMSGERR>Rotina com erros</DSMSGERR></Root>');
      ELSE
          vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Dados>Rotina com erros</Dados></Root>');
      END IF ;
       -- Converter o XML
      pr_retxml := vr_retxml.getClobVal();
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      
      GENE0001.pc_OScommand_Shell('rm ' || vr_dsdireto || '/' || pr_dsarquiv);

      pr_dscritic := 'Erro geral na rotina pc_valida_compr_folha: '||SQLERRM;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      IF pr_idorigem = 3 THEN

          vr_retxml := XMLType.createXML('<Root><DSMSGERR>Rotina com erros</DSMSGERR></Root>');
       ELSE
          vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Dados>Rotina com erros</Dados></Root>');
     END IF;
       -- Converter o XML
      pr_retxml := vr_retxml.getClobVal();
  END pc_valida_arq_compr_ib;

  /* Rotina para gravar os dados do arquivo  */
  PROCEDURE pc_gravar_arq_folha_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_nrdconta  IN NUMBER                --> Conta conectada
                                  ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE --> CPF do operador conectado
                                  ,pr_dsrowpfp  IN VARCHAR2              --> Rowid do pagamento
                                  ,pr_idopdebi  IN NUMBER                --> Opção de debito selecionada
                                  ,pr_dtcredit  IN DATE                  --> Data do crédito
                                  ,pr_dtdebito  IN DATE                  --> Data do debito
                                  ,pr_vltararp  IN NUMBER                --> Valor da tarifa aprovada
                                  ,pr_nmarquiv  IN VARCHAR2              --> Nome do arquivo com as informações do pagamento
                                  ,pr_dscritic  OUT VARCHAR2             --> Possível critica
                                  ,pr_retxml    OUT CLOB) IS             --> XML montado de retorno a tela.
 ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gravar_arq_folha_ib                  Antigo: Não há
  --  Sistema  : IB
  --  Sigla    : CRED
  --  Autor    : Renato Darosci - SUPERO
  --  Data     : Maio/2015.                   Ultima atualizacao: 27/01/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Rotina para gravar os dados do arquivo
  -- Alterações:
  --             27/10/2015 - Remoção de campos não mais utilizados (Marcos-Supero)
  --
  --             26/01/2016 - Inclusão de log nas operações (Marcos-Supero)
  --
  --             27/01/2016 - Incluir controle de lançamentos sem crédito (Marcos-Supero)
  --
  ---------------------------------------------------------------------------------------------------------------

    -- Buscar os dados da empresa conectada
    CURSOR cr_crapemp IS
      SELECT emp.cdempres
        FROM crapemp emp
       WHERE emp.cdcooper = pr_cdcooper
         AND emp.nrdconta = pr_nrdconta;
    rw_crapemp cr_crapemp%ROWTYPE;

    -- Buscar o código do próximo crappfp para a empresa
    CURSOR cr_nrseqpag(pr_cdcooper  CRAPPFP.cdcooper%TYPE
                      ,pr_cdempres  CRAPPFP.CDEMPRES%TYPE) IS
      SELECT NVL(MAX(pfp.nrseqpag),0) + 1 nrseqpag
        FROM crappfp pfp
       WHERE pfp.cdcooper = pr_cdcooper
         AND pfp.cdempres = pr_cdempres;


    -- Buscar o código do próximo crappfp para a empresa
    CURSOR cr_crappfp_old(p_dsrowpfp IN VARCHAR2) IS
      SELECT idopdebi
            ,dtdebito
            ,dtcredit
            ,qtlctpag
            ,qtregpag
            ,vllctpag
        FROM crappfp pfp
       WHERE pfp.rowid = p_dsrowpfp;
    rw_crappfp_old cr_crappfp_old%ROWTYPE;

    -- Cursor genérico de calendário
    rw_crapdat     btch0001.cr_crapdat%ROWTYPE;

    -- Cursor com os dados para insert
    rw_craplfp     craplfp%ROWTYPE;

    -- Variáveis
    vr_nrseqpag    crappfp.nrseqpag%TYPE;
    vr_qtlctpag    crappfp.qtlctpag%TYPE;
    vr_qtregpag    crappfp.qtregpag%TYPE;
    vr_vllctpag    crappfp.vllctpag%TYPE;
    vr_dsrowpfp    ROWID;
    vr_dsdireto    VARCHAR2(200);
    vr_qtddados    NUMBER;

    -- Variáveis para tratamento do XML
    vr_xmldados    CLOB;
    vr_node_list   XMLDOM.DOMNodeList;
    vr_childlist   XMLDOM.DOMNodeList;
    vr_parser      XMLPARSER.Parser;
    vr_doc         XMLDOM.DOMDocument;
    vr_lenght      NUMBER;
    vr_qtfilhos    NUMBER;
    vr_node_name   VARCHAR2(100);
    vr_item_node   XMLDOM.DOMNode;
    vr_element     XMLDOM.DOMElement;
    vr_nodenames   XMLDOM.DOMNamedNodeMap;
    vr_nrdrowid    ROWID;
    vr_excerror    EXCEPTION;

  BEGIN

    -- Buscar dados da empresa
    OPEN  cr_crapemp;
    FETCH cr_crapemp INTO rw_crapemp;
    CLOSE cr_crapemp;

    -- Verifica se encontrou o código da empresa
    IF rw_crapemp.cdempres IS NULL THEN
      pr_dscritic := 'Não foi possível localizar dados da empresa. Favor, entre em contato com seu PA!';
      RAISE vr_excerror;
    END IF;

    -- Leitura do calendário da cooperativa
    OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      pr_dscritic := 'Problemas ao recuperar a data do sistema. Favor, entre em contato com seu PA!';
      RAISE vr_excerror;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Evitar espaços na passagem do rowid
    vr_dsrowpfp := TRIM(pr_dsrowpfp);

    -- Busca o diretório do upload do arquivo
    vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => 'upload');

    -- Inicializa
    vr_qtddados := 0;

    -- Se o arquivo foi informado
    IF TRIM(pr_nmarquiv) IS NOT NULL THEN
      -- Ler o arquivo e gravar o mesmo no CLOB
      vr_xmldados := GENE0002.fn_arq_para_clob(pr_caminho => vr_dsdireto, pr_arquivo => pr_nmarquiv);
      vr_qtddados := LENGTH(vr_xmldados);
    END IF;

    -- Se não vieram dados no XML
    IF vr_qtddados <= 0 THEN
      -- Verifica se o Rowid foi informado
      IF vr_dsrowpfp IS NULL THEN
        -- Retorna erro pois em situação de insert deve vir dados
        pr_dscritic := 'XML sem dados para processar. Favor, entre em contato com seu PA!';
        RAISE vr_excerror;
      ELSE

        -- Houve uma alteração de data sem recarga de arquivo - Realizar o update dos campos correspondentes e retornar
        BEGIN
          UPDATE crappfp pfp
             SET pfp.dtmvtolt = SYSDATE
               , pfp.idtppagt = 'A'
               , pfp.idopdebi = pr_idopdebi
               , pfp.dtcredit = pr_dtcredit
               , pfp.dtdebito = pr_dtdebito
               , pfp.flgrvsal = 0
               , pfp.idsitapr = 1 -- Pendente
               , pfp.vltarapr = pr_vltararp
               , pfp.flsitdeb = 0 -- false
               , pfp.flsitcre = 0 -- false
               , pfp.flsittar = 0 -- false
           WHERE pfp.rowid = vr_dsrowpfp
           RETURNING pfp.nrseqpag
                INTO vr_nrseqpag;
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            
            pr_dscritic := 'Erro ao atualizar CRAPPFP: '||SQLERRM;
            RAISE vr_excerror;
        END;

        -- Geração do LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => 996
                            ,pr_dscritic => 'OK'
                            ,pr_dsorigem => gene0001.vr_vet_des_origens(3)
                            ,pr_dstransa => 'Pagto Folha #'||vr_nrseqpag||' alterado com sucesso por '||fn_nmoperad_log(pr_cdcooper,pr_nrdconta,pr_nrcpfope)
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> SUCESSO
                            ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'INTERNETBANK'
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

        -- Adição de detalhes a nivel de item
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Empresa'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => rw_crapemp.cdempres);
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Tipo'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => 'Arquivo');
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Opção Débito'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => fn_nmopdebi_log(pr_idopdebi));
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Data Débito'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => to_char(pr_dtdebito,'dd/mm/rrrr'));
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Data Crédito'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => to_char(pr_dtcredit,'dd/mm/rrrr'));

        -- Commit dos dados atualizados
        COMMIT;

        -- Saída do procedimento
        RETURN;

      END IF;
    END IF;

    -- Faz o parse do XMLTYPE para o XMLDOM
    vr_parser := xmlparser.newParser;
    xmlparser.parseClob(vr_parser,vr_xmldados);

    -- Documento gerado pelo parser
    vr_doc    := xmlparser.getDocument(vr_parser);

    -- libera o parser
    xmlparser.freeParser(vr_parser);

    -- Faz o get de toda a lista de elementos
    vr_node_list := xmldom.getElementsByTagName(vr_doc, '*');
    vr_lenght := xmldom.getLength(vr_node_list);

    BEGIN

      -- Percorrer os elementos
      FOR i IN 0..vr_lenght-1 LOOP
        -- Pega o item
        vr_item_node := xmldom.item(vr_node_list, i);
        -- Captura o nome do nodo
        vr_node_name := xmldom.getNodeName(vr_item_node);
        -- Verifica qual nodo esta sendo lido
        IF LOWER(vr_node_name) = 'root' THEN
          CONTINUE; -- Descer para o próximo filho
        ELSIF vr_node_name IN ('folha') THEN
          -- Limpar variáveis
          vr_qtlctpag := 0;
          vr_qtregpag := 0;
          vr_vllctpag := 0;

          -- Captura o elemento do nodo
          vr_element := xmldom.makeElement(vr_item_node);
          -- Todos os atributos do nodo
          vr_nodenames := xmldom.getAttributes(vr_item_node);

          -- Se encontrar atributos
          IF (NOT xmldom.isNull(vr_nodenames)) THEN
            -- Ler a quantidade de atributos
            vr_qtfilhos := xmldom.getLength(vr_nodenames);

            -- Percorrer os atributos
            FOR i IN 0..vr_qtfilhos-1 loop
              vr_item_node := xmldom.item(vr_nodenames, i);

              -- Verifica o atributo conforme o nome
              IF LOWER(xmldom.getNodeName(vr_item_node)) = 'qtlctpag' THEN
                vr_qtlctpag := TO_NUMBER(xmldom.getNodeValue(vr_item_node));
              ELSIF LOWER(xmldom.getNodeName(vr_item_node)) = 'qtregpag' THEN
                vr_qtregpag := TO_NUMBER(xmldom.getNodeValue(vr_item_node));
              ELSIF LOWER(xmldom.getNodeName(vr_item_node)) = 'vllctpag' THEN
                vr_vllctpag := TO_NUMBER(xmldom.getNodeValue(vr_item_node));
              END IF;

            END LOOP;
          END IF;

          -- Se foi passado rowid deve prosseguir com update
          IF vr_dsrowpfp IS NOT NULL THEN

            -- Buscar histórico para log
            OPEN  cr_crappfp_old(vr_dsrowpfp);
            FETCH cr_crappfp_old INTO rw_crappfp_old;
            CLOSE cr_crappfp_old;

            -- Atualizar a tabela CRAPPFP
            BEGIN
              UPDATE crappfp pfp
                 SET pfp.dtmvtolt = SYSDATE
                   , pfp.idtppagt = 'A'
                   , pfp.idopdebi = pr_idopdebi
                   , pfp.dtcredit = pr_dtcredit
                   , pfp.dtdebito = pr_dtdebito
                   , pfp.qtlctpag = vr_qtlctpag
                   , pfp.qtregpag = vr_qtregpag
                   , pfp.vllctpag = vr_vllctpag
                   , pfp.flgrvsal = 0
                   , pfp.idsitapr = 1 -- Pendente
                   , pfp.vltarapr = pr_vltararp
                   , pfp.flsitdeb = 0 -- false
                   , pfp.flsitcre = 0 -- false
                   , pfp.flsittar = 0 -- false
               WHERE pfp.rowid = vr_dsrowpfp
               RETURNING pfp.nrseqpag INTO vr_nrseqpag;
            EXCEPTION
              WHEN OTHERS THEN
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                
                pr_dscritic := 'Erro ao atualizar CRAPPFP: '||SQLERRM;
                RAISE vr_excerror;
            END;

            -- Excluir todos os registros da craplfp atralados ao registro alterado / inserido
            BEGIN
              DELETE craplfp lfp
               WHERE lfp.cdcooper = pr_cdcooper
                 AND lfp.cdempres = rw_crapemp.cdempres
                 AND lfp.nrseqpag = vr_nrseqpag;
            EXCEPTION
              WHEN OTHERS THEN
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                
                pr_dscritic := 'Erro ao excluir CRAPLFP: '||SQLERRM;
                RAISE vr_excerror;
            END;

            -- Geração do LOG
            gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => 996
                                ,pr_dscritic => 'OK'
                                ,pr_dsorigem => gene0001.vr_vet_des_origens(3)
                                ,pr_dstransa => 'Pagto Folha #'||vr_nrseqpag||' recarregado com sucesso por '||fn_nmoperad_log(pr_cdcooper,pr_nrdconta,pr_nrcpfope)
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => 1 --> SUCESSO
                                ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => 'INTERNETBANK'
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);

          ELSE

            -- Buscar o próximo sequencial para a empresa
            OPEN  cr_nrseqpag(pr_cdcooper,rw_crapemp.cdempres);
            FETCH cr_nrseqpag INTO vr_nrseqpag;
            CLOSE cr_nrseqpag;

            BEGIN
              -- Inserir a informação da CRAPPFP
              INSERT INTO CRAPPFP(cdcooper
                                 ,cdempres
                                 ,nrseqpag
                                 ,dtmvtolt
                                 ,idtppagt
                                 ,idopdebi
                                 ,dtcredit
                                 ,dtdebito
                                 ,qtlctpag
                                 ,qtregpag
                                 ,vllctpag
                                 ,flgrvsal
                                 ,idsitapr
                                 ,vltarapr
                                 ,flsitdeb
                                 ,flsitcre
                                 ,flsittar)
                          VALUES (pr_cdcooper         -- cdcooper
                                 ,rw_crapemp.cdempres -- cdempres
                                 ,vr_nrseqpag         -- nrseqpag
                                 ,SYSDATE             -- dtmvtolt
                                 ,'A'                 -- idtppagt
                                 ,pr_idopdebi         -- idopdebi
                                 ,pr_dtcredit         -- dtcredit
                                 ,pr_dtdebito         -- dtdebito
                                 ,vr_qtlctpag         -- qtlctpag
                                 ,vr_qtregpag         -- qtregpag
                                 ,vr_vllctpag         -- vllctpag
                                 ,0                   -- flgrvsal
                                 ,1   -- Pendente     -- idsitapr
                                 ,pr_vltararp         -- vltarapr
                                 ,0   -- false        -- flsitdeb
                                 ,0   -- false        -- flsitcre
                                 ,0); -- false        -- flsittar

            EXCEPTION
              WHEN OTHERS THEN
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                
                pr_dscritic := 'Erro ao inserir CRAPPFP: '||SQLERRM;
                RAISE vr_excerror;
            END;

            -- Geração do LOG
            gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => 996
                                ,pr_dscritic => 'OK'
                                ,pr_dsorigem => gene0001.vr_vet_des_origens(3)
                                ,pr_dstransa => 'Pagto Folha #'||vr_nrseqpag||' carregado com sucesso por '||fn_nmoperad_log(pr_cdcooper,pr_nrdconta,pr_nrcpfope)
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => 1 --> SUCESSO
                                ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => 'INTERNETBANK'
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
          END IF;

          -- Adição de detalhes a nivel de item
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Empresa'
                                   ,pr_dsdadant => NULL
                                   ,pr_dsdadatu => rw_crapemp.cdempres);
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Tipo'
                                   ,pr_dsdadant => NULL
                                   ,pr_dsdadatu => 'Arquivo');
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Opção Débito'
                                   ,pr_dsdadant => fn_nmopdebi_log(rw_crappfp_old.idopdebi)
                                   ,pr_dsdadatu => pr_idopdebi);
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Data Débito'
                                   ,pr_dsdadant => to_char(rw_crappfp_old.dtdebito,'dd/mm/rrrr')
                                   ,pr_dsdadatu => to_char(pr_dtdebito,'dd/mm/rrrr'));
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Data Crédito'
                                   ,pr_dsdadant => to_char(rw_crappfp_old.dtcredit,'dd/mm/rrrr')
                                   ,pr_dsdadatu => to_char(pr_dtcredit,'dd/mm/rrrr'));
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Quantidade de Pagamentos positivos'
                                   ,pr_dsdadant => rw_crappfp_old.qtlctpag
                                   ,pr_dsdadatu => vr_qtlctpag);
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Valor total dos pagamentos'
                                   ,pr_dsdadant => to_char(rw_crappfp_old.vllctpag,'fm999g999g999g990d00')
                                   ,pr_dsdadatu => to_char(vr_vllctpag,'fm999g999g999g990d00'));
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Quantidade de Pagamentos total'
                                   ,pr_dsdadant => rw_crappfp_old.qtregpag
                                   ,pr_dsdadatu => vr_qtregpag);

        ELSIF vr_node_name IN ('info') THEN

          -- Captura o elemento do nodo
          vr_element := xmldom.makeElement(vr_item_node);
          -- Todos os atributos do nodo
          vr_childlist := xmldom.getChildNodes(vr_item_node);
          vr_qtfilhos := xmldom.getLength(vr_childlist);

          -- Fará um insert para cada conjunto de informações, dessa forma
          -- deve ser realizada a limpeza do registro e a carga para garantir
          -- dados corretos
          rw_craplfp := NULL;
          rw_craplfp.cdcooper := pr_cdcooper;
          rw_craplfp.cdempres := rw_crapemp.cdempres;
          rw_craplfp.nrseqpag := vr_nrseqpag;
          rw_craplfp.idsitlct := 'L'; -- Lançado

          -- Percorrer os elementos
          FOR i IN 0..vr_qtfilhos-1 LOOP
            -- Pega o item
            vr_item_node := xmldom.item(vr_childlist, i);
            -- Captura o elemento do nodo
            vr_element := xmldom.makeElement(vr_item_node);
            -- Captura o nome do nodo
            vr_node_name := LOWER(xmldom.getNodeName(vr_item_node));

            -- Verifica o atributo conforme o nome
            IF    vr_node_name = 'nrseqlfp' THEN
              rw_craplfp.nrseqlfp := TO_NUMBER(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
            ELSIF vr_node_name = 'nrdconta' THEN
              rw_craplfp.nrdconta := TO_NUMBER(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
            ELSIF vr_node_name = 'idtpcont' THEN
              rw_craplfp.idtpcont := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
            ELSIF vr_node_name = 'nrcpfemp' THEN
              BEGIN
                rw_craplfp.nrcpfemp := TO_NUMBER(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
              EXCEPTION
                WHEN OTHERS THEN
                  CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                  
                  pr_dscritic := 'CPF do empregado invalido: '||TO_NUMBER(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node))) ||' conta: '||rw_craplfp.nrdconta ;
                  RAISE vr_excerror;
              END;
            ELSIF vr_node_name = 'vllancto' THEN
              rw_craplfp.vllancto := TO_NUMBER(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
            ELSIF vr_node_name = 'cdorigem' THEN
              rw_craplfp.cdorigem := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
            END IF;

          END LOOP;

          -- Realiza o insert dos dados do registro na CRAPLFP
          BEGIN
            INSERT INTO craplfp VALUES rw_craplfp;
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              
              pr_dscritic := 'Erro ao inserir CRAPLFP: '||SQLERRM;
              RAISE vr_excerror;
          END;

          -- Adição de detalhes a nivel de item
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Conta['||rw_craplfp.nrseqlfp||']'
                                   ,pr_dsdadant => NULL
                                   ,pr_dsdadatu => gene0002.fn_mask_conta(rw_craplfp.nrdconta));
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'CPF['||rw_craplfp.nrseqlfp||']'
                                   ,pr_dsdadant => NULL
                                   ,pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(rw_craplfp.nrcpfemp,1));
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Tipo['||rw_craplfp.nrseqlfp||']'
                                   ,pr_dsdadant => NULL
                                   ,pr_dsdadatu => fn_tpconta_log(rw_craplfp.idtpcont));
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Origem['||rw_craplfp.nrseqlfp||']'
                                   ,pr_dsdadant => NULL
                                   ,pr_dsdadatu => fn_dsorigem_log(pr_cdcooper,rw_craplfp.cdorigem));
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Valor['||rw_craplfp.nrseqlfp||']'
                                   ,pr_dsdadant => NULL
                                   ,pr_dsdadatu => to_char(rw_craplfp.vllancto,'fm999g999g999g990d00'));

        END IF; -- vr_node_name
      END LOOP;

    EXCEPTION
      WHEN vr_excerror THEN
        RAISE vr_excerror;
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        
        pr_dscritic := 'Erro na leitura do XML. Rotina PC_GRAVAR_ARQ_FOLHA_IB: '||SQLERRM;
        RAISE vr_excerror;
    END;

    -- Efetivar as informações na base de dados
    COMMIT;

    -- Excluir o arquivo
    GENE0001.pc_OScommand_Shell('rm ' || vr_dsdireto || '/' || pr_nmarquiv);

  EXCEPTION
    WHEN vr_excerror THEN
      ROLLBACK;
      -- XML de retorno
      pr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                   '<Root><Dados>Rotina com erros</Dados></Root>';
    WHEN OTHERS THEN
      ROLLBACK;
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      
      pr_dscritic := 'Erro geral PC_GRAVAR_ARQ_FOLHA_IB: '||SQLERRM;
      -- Carregar XML
      pr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                   '<Root><Dados>Rotina com erros</Dados></Root>';
  END pc_gravar_arq_folha_ib;

  -- Procedure para atualizar as informações da tela de envio de comprovantes do IB
  PROCEDURE pc_insere_compr_folha(pr_cdcooper IN craplfp.cdcooper%TYPE --> Cooperativa conectada
                                 ,pr_cdempres IN craplfp.cdempres%TYPE --> Empresa conectada
                                 ,pr_nrcpfope IN crapopi.nrcpfope%TYPE --> CPF do operador conectado
                                 ,pr_nrseqpag IN craplfp.nrseqpag%TYPE --> Sequencia do pagamento selecionado
                                 ,pr_dtrefere IN craplfp.dtrefenv%TYPE --> Data de referência
                                 ,pr_dsarquiv IN VARCHAR2              --> Nome do arquivo com os comprovantes
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Erros do processo
                                 ,pr_dscritic OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_insere_compr_folha                   Antigo: Não há
    --  Sistema  : Internet Bankig
    --  Sigla    : CRED
    --  Autor    : Vanessa
    --  Data     : Setembro/2015.                   Ultima atualizacao: 26/01/2016
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que for chamado
    -- Objetivo  : Procedure para gravar os comprovantes
    -- Alterações
    --            26/01/2016 - Inclusão de log sob as operações efetuadas (Marcos-Supero)
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Buscar todos os pagamentos para atualização do comprovante
      CURSOR cr_craplfp IS
        SELECT lfp.nrseqlfp
              ,lfp.rowid
              ,lfp.nrdconta
          FROM craplfp lfp
         WHERE lfp.cdcooper = pr_cdcooper
           AND lfp.cdempres = pr_cdempres
           AND lfp.nrseqpag = pr_nrseqpag;

      -- Busca da conta da empresa
      CURSOR cr_crapemp IS
        SELECT nrdconta
          FROM crapemp
         WHERE cdcooper = pr_cdcooper
           AND cdempres = pr_cdempres;
      vr_nrdconta crapemp.nrdconta%TYPE;

      -- Busca da quantidade de comprovantes antes da carga
      CURSOR cr_lfp_total IS
        SELECT COUNT(1)
          FROM craplfp lfp
         WHERE lfp.cdcooper = pr_cdcooper
           AND lfp.cdempres = pr_cdempres
           AND lfp.nrseqpag = pr_nrseqpag
           AND lfp.dtrefenv IS NOT NULL;
      vr_qtd_ant NUMBER;
      vr_qtd_dep NUMBER;

      -- Variaveis
      vr_dsdireto VARCHAR2(1000);
      vr_erro EXCEPTION;
      vr_dsxmlenv    CLOB;
      vr_dsxmlenv_txt VARCHAR2(32767);

      -- Variáveis para tratamento do XML
      vr_xmltype sys.xmltype;
      vr_xmlenv  sys.xmltype;

      -- Log
      vr_nrdrowid    ROWID;
      TYPE typ_tab_conta IS
        TABLE OF crapass.nrdconta%TYPE
          INDEX BY BINARY_INTEGER;
      vr_reg_conta typ_tab_conta;

    BEGIN
      -- Iremos buscar o XML processado com os dados de comprovantes lidos
      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => 'upload');
      -- Se não existir o arquivo XML processado
      IF NOT gene0001.fn_exis_arquivo(pr_caminho => vr_dsdireto||'/'||pr_dsarquiv||'.proc.xml') THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na leitura dos Comprovantes. Favor entrar em contato com seu Posto de Atendimento!';
        RAISE vr_erro;
      END IF;

      -- Buscar a conta da empresa
      OPEN cr_crapemp;
      FETCH cr_crapemp
       INTO vr_nrdconta;
      CLOSE cr_crapemp;

      -- Busca da quantidade atual
      OPEN cr_lfp_total;
      FETCH cr_lfp_total
       INTO vr_qtd_ant;
      CLOSE cr_lfp_total;

      -- Geração do LOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => 996
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(3)
                          ,pr_dstransa => 'Comprovantes do Pagto Folha #'||pr_nrseqpag||' carregado por '||fn_nmoperad_log(pr_cdcooper,vr_nrdconta,pr_nrcpfope)
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO
                          ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'INTERNETBANK'
                          ,pr_nrdconta => vr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Adicionar a empresa ao log
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Empresa'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => pr_cdempres);
      
      -- Criaremos o XML com base no arquivo lido anteriormente
      vr_xmltype := XMLType.createxml(gene0002.fn_arq_para_clob(pr_caminho => vr_dsdireto
                                                               ,pr_arquivo => pr_dsarquiv||'.proc.xml'));
      -- Buscamos todos os lançamentos do pagamento para carregamento do comprovante
      FOR rw_craplfp IN cr_craplfp LOOP
        -- Se encontrar o No do comprovante atual
        IF vr_xmltype.existsNode('/Root/folhas/xml[@nrseqlfp="'||rw_craplfp.nrseqlfp||'"]') = 1 THEN
          -- Buscar o Noh correspondente ao lançamento atual
          vr_xmlenv := vr_xmltype.extract('/Root/folhas/xml[@nrseqlfp="'||rw_craplfp.nrseqlfp||'"]');
           -- Convertemos o XMLType para CLOB
          vr_dsxmlenv := vr_xmlenv.getClobVal();
           -- E então, para LONG
          vr_dsxmlenv_txt := dbms_lob.substr(vr_dsxmlenv, 32767, 1);
           -- Por fim, atualizamos o campo da tabela
          UPDATE craplfp lfp
             SET lfp.dsxmlenv = vr_dsxmlenv_txt  -- Variavel montada dinamicamente
                ,lfp.dtrefenv = pr_dtrefere -- Lida do arquivo (97,6)
           WHERE lfp.rowid = rw_craplfp.rowid;
          -- Adiciona a conta ao registro
          vr_reg_conta(vr_reg_conta.count()+1) := rw_craplfp.nrdconta;
        END IF;
      END LOOP;

      -- Busca da quantidade após carga
      OPEN cr_lfp_total;
      FETCH cr_lfp_total
       INTO vr_qtd_dep;
      CLOSE cr_lfp_total;

      -- Incluir em log o total carregado antes e depois
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Total Carregado'
                                   ,pr_dsdadant => vr_qtd_ant
                                   ,pr_dsdadatu => vr_qtd_dep);

      -- Incluir log a nivel de item com os comprovantes carregados
      FOR vr_idx IN 1..vr_reg_conta.count() LOOP
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Conta carregada'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => gene0002.fn_mask_conta(vr_reg_conta(vr_idx)));
      END LOOP;

      -- Enfim, enviamos as alterações ao banco
      COMMIT;
    EXCEPTION
      WHEN vr_erro THEN
          NULL; -- Retorna a critica ja informada
      WHEN OTHERS THEN
         CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
         
         pr_cdcritic := 0;
         pr_dscritic := 'Erro ao Gravar Comprovantes - Entre em contato com seu PA: ['||SQLERRM||']';
     END;
   END pc_insere_compr_folha;

 /* Rotina para consultar os dados para a tela de folha de pagamento do IB  */
  PROCEDURE pc_consulta_arq_folha_ib(pr_dsrowpfp  IN VARCHAR2
                                    ,pr_dscritic  OUT VARCHAR2
                                    ,pr_retxml    OUT CLOB) IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_consulta_arq_folha_ib                   Antigo: Não há
  --  Sistema  : Internet Bankig
  --  Sigla    : CRED
  --  Autor    : Renato Darosci - SUPERO
  --  Data     : Setembro/2015.                   Ultima atualizacao: 05/07/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Rotina para consultar os dados para a tela de folha de pagamento do IB
  -- Alterações
  --             27/01/2016 - Incluir controle de lançamentos sem crédito (Marcos-Supero)
  --
  --             05/07/2018 - Inclusao das tags de cdtarifa e cdfaixav no XML de saída, Prj.363 (Jean Michel)
  ---------------------------------------------------------------------------------------------------------------

    -- Buscar o registro pai na tabela CRAPPFP
    CURSOR cr_crappfp IS
      SELECT pfp.cdcooper
           , pfp.cdempres
           , pfp.nrseqpag
           , pfp.dtcredit
           , pfp.dtdebito
           , pfp.idopdebi
           , pfp.qtlctpag
           , pfp.qtregpag
           , pfp.vllctpag
           , pfp.vltarapr
        FROM crappfp pfp
       WHERE pfp.rowid    = pr_dsrowpfp;
    rw_crappfp   cr_crappfp%ROWTYPE;

    -- Buscar os registros filhos na tabela CRAPLFP
    CURSOR cr_craplfp(pr_cdcooper   NUMBER
                     ,pr_cdempres   NUMBER
                     ,pr_nrseqpag   NUMBER) IS
      SELECT lfp.nrseqlfp
           , lfp.nrdconta
           , lfp.idtpcont
           , lfp.nrcpfemp
           , lfp.vllancto
           , ofp.dsorigem
        FROM craplfp lfp
           , crapofp ofp
       WHERE ofp.cdcooper = lfp.cdcooper
         AND ofp.cdorigem = lfp.cdorigem
         AND lfp.cdcooper = pr_cdcooper
         AND lfp.cdempres = pr_cdempres
         AND lfp.nrseqpag = pr_nrseqpag
       ORDER BY lfp.nrseqlfp;

    -- Cursor com os dados para insert
    rw_craplfp     craplfp%ROWTYPE;

    vr_excerror    EXCEPTION;

    vr_cdtarifa VARCHAR2(10);
    vr_cdfaixav VARCHAR2(10);
    vr_dstarfai VARCHAR2(20);
  BEGIN

    -- Buscar os dados da CRAPPFP
    OPEN  cr_crappfp;
    FETCH cr_crappfp INTO rw_crappfp;

    -- Se não encontrar dados
    IF cr_crappfp%NOTFOUND THEN
      -- Fechar o cursor antes de abortar a consulta
      CLOSE cr_crappfp;

      pr_dscritic := 'Dados não puderam ser encontrados. Favor entre em contato com seu PA!';
      RAISE vr_excerror;
    END IF;

    -- Fechar o cursor
    CLOSE cr_crappfp;
    vr_dstarfai := FOLH0001.fn_cdtarifa_cdfaixav(pr_cdocorre => rw_crappfp.idopdebi);
    vr_cdtarifa := gene0002.fn_busca_entrada(1,vr_dstarfai,',');
    vr_cdfaixav := gene0002.fn_busca_entrada(2,vr_dstarfai,',');

    -- Montar o XML com os dados
    pr_retxml := '<criticas dtcredit="'||to_char(rw_crappfp.dtcredit,'DD/MM/RRRR')||'" '||
                           'dtdebito="'||to_char(rw_crappfp.dtdebito,'DD/MM/RRRR')||'" '||
                           'idopdebi="'||rw_crappfp.idopdebi||'" '||
                           'vltarapr="'||NVL(rw_crappfp.vltarapr,0)||'" '||
                           'qtregerr="0" '||
                           'qtdregok="'||NVL(rw_crappfp.qtregpag,0)||'" '||
                           'qtregtot="'||NVL(rw_crappfp.qtregpag,0)||'" '||
                           'vltotpag="'||to_char(rw_crappfp.vllctpag,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.')||'" '||
                           'cdtarifa="'||TO_CHAR(vr_cdtarifa)||'" '||
                           'cdfaixav="'||TO_CHAR(vr_cdfaixav)||'" '||'>';

    -- Listar todos os registros filhos no XML
    FOR rw_craplfp IN cr_craplfp(rw_crappfp.cdcooper
                                ,rw_crappfp.cdempres
                                ,rw_crappfp.nrseqpag)  LOOP

          -- Criar nodo filho
          pr_retxml := pr_retxml|| '<critica>'
                                 ||'    <nrseqvld>'||to_char(rw_craplfp.nrseqlfp)||'</nrseqvld>'
                                 ||'    <dsdconta>'||to_char(TRIM(GENE0002.fn_mask_conta(rw_craplfp.nrdconta)))||'</dsdconta>'
                                 ||'    <dscpfcgc>'||to_char(TRIM(GENE0002.fn_mask_cpf_cnpj(rw_craplfp.nrcpfemp,1)))||'</dscpfcgc>'
                                 ||'    <dscritic>Registro lido com Sucesso!</dscritic>'
                                 ||'    <dsorigem>'||to_char(rw_craplfp.dsorigem)||'</dsorigem>'
                                 ||'    <vlrpagto>'||to_char(rw_craplfp.vllancto,'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS=,.')||'</vlrpagto>'
                                 ||'</critica>';

    END LOOP; -- Loop das críticas

    -- Nodo de finalização
    pr_retxml := pr_retxml|| '</criticas>';

  EXCEPTION
    WHEN vr_excerror THEN
      ROLLBACK;
      -- XML de retorno
      pr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                   '<Root><Dados>Rotina com erros</Dados></Root>';
    WHEN OTHERS THEN
      ROLLBACK;
      CECRED.pc_internal_exception;
      
      pr_dscritic := 'Erro geral PC_CONSULTA_ARQ_FOLHA_IB: '||SQLERRM;
      -- Carregar XML
      pr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                   '<Root><Dados>Rotina com erros</Dados></Root>';
  END pc_consulta_arq_folha_ib;

  /* Verificacao agencia da cooperativa */ 
  PROCEDURE pc_busca_sit_salario(pr_nrdconta IN crapass.nrdconta%TYPE
                                ,pr_xmllog   IN VARCHAR2             --> XML com informac?es de LOG
                                ,pr_cdcritic OUT PLS_INTEGER         --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2            --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2            --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS     
                                
    CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS                              
      SELECT ass.cdcooper,
             ass.nrdconta
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
         

    CURSOR cr_lanaut(pr_cdcooper crapcop.cdcooper%TYPE
                    ,pr_nrdconta craplcm.nrdconta%TYPE
                    ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                    ,pr_hsparfol VARCHAR2) IS 
      SELECT /*+ index (lan TBFOLHA_LANAUT_IDX01) */ 1
        FROM tbfolha_lanaut lan
       WHERE lan.cdcooper = pr_cdcooper
         AND lan.nrdconta = pr_nrdconta
         AND lan.cdhistor IN (SELECT regexp_substr(pr_hsparfol, '[^,]+', 1, LEVEL) FROM dual
                              CONNECT BY regexp_substr(pr_hsparfol, '[^,]+', 1, LEVEL) IS NOT NULL)
         AND lan.dtmvtolt >= pr_dtmvtolt;
    
    rw_lanaut cr_lanaut%ROWTYPE;
                        
                        
    vr_dsconteu VARCHAR2(4000);          
    vr_hsparfol VARCHAR2(4000);
    vr_qtdfolha PLS_INTEGER;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_des_erro VARCHAR2(10);
    vr_tab_erro gene0001.typ_tab_erro;
    
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    vr_response VARCHAR2(3) := 'NAO';
    vr_exc_erro EXCEPTION;
    
    vr_cdcooper INTEGER := 0;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_cdoperad VARCHAR2(100);

                                      
  BEGIN
    
    CECRED.GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                                   ,pr_cdcooper => vr_cdcooper
                                   ,pr_nmdatela => vr_nmdatela
                                   ,pr_nmeacao  => vr_nmeacao
                                   ,pr_cdagenci => vr_cdagenci
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_idorigem => vr_idorigem
                                   ,pr_cdoperad => vr_cdoperad
                                   ,pr_dscritic => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  
    -- Buscar a data do movimento
    OPEN btch0001.cr_crapdat(vr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    
    -- Fechar o cursor
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      RAISE vr_exc_erro;
    END IF;
    
    CLOSE btch0001.cr_crapdat;

    vr_response := NULL;
  
    tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => vr_cdcooper
                                          ,pr_cdbattar => 'HSTPARTICIPAFOL'
                                          ,pr_dsconteu => vr_dsconteu
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic
                                          ,pr_des_erro => vr_des_erro
                                          ,pr_tab_erro => vr_tab_erro);
                                          
    IF vr_des_erro = 'NOK' THEN
       RAISE vr_exc_erro;
    END IF;                                        

    vr_hsparfol := vr_dsconteu;
    vr_dsconteu := '';

    tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => vr_cdcooper
                                          ,pr_cdbattar => 'QTDDIASFLGFOLHA'
                                          ,pr_dsconteu => vr_dsconteu
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic
                                          ,pr_des_erro => vr_des_erro
                                          ,pr_tab_erro => vr_tab_erro);
                                          
    IF vr_des_erro = 'NOK' THEN
       RAISE vr_exc_erro;
    END IF;                                        
  
    vr_qtdfolha := TO_NUMBER(vr_dsconteu);
    
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
  
    FETCH cr_crapass INTO rw_crapass;
    
    IF cr_crapass%NOTFOUND THEN
       CLOSE cr_crapass;
       RAISE vr_exc_erro;
    END IF;
    
    CLOSE cr_crapass;

    -- verifica historico parametrizado 
    FOR rw_lanaut IN cr_lanaut(pr_cdcooper => vr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_dtmvtolt => (rw_crapdat.dtmvtolt - vr_qtdfolha)
                              ,pr_hsparfol => vr_hsparfol) LOOP
         vr_response := 'SIM';
      EXIT;     
    END LOOP;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'flgsal', pr_tag_cont => vr_response, pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN vr_exc_erro THEN                         
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0     , pr_tag_nova => 'flgsal', pr_tag_cont => ' - ', pr_des_erro => vr_dscritic);

    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0     , pr_tag_nova => 'flgsal', pr_tag_cont => ' - ', pr_des_erro => vr_dscritic);                 
  END pc_busca_sit_salario;               

  PROCEDURE pc_busca_rendas_aut(pr_nrdconta IN crapass.nrdconta%TYPE                               
                               ,pr_xmllog   IN VARCHAR2             --> XML com informac?es de LOG
                               ,pr_cdcritic OUT PLS_INTEGER         --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2            --> Descricao da critica
                               ,pr_retxml   IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2            --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS
                                
    CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS                              
      SELECT ass.nrdconta
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
         
    CURSOR cr_tbfolha_lanaut(pr_cdcooper crapcop.cdcooper%TYPE
                            ,pr_nrdconta craplcm.nrdconta%TYPE
                            ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT /*+ INDEX(lan TBFOLHA_LANAUT_IDX01) */ lan.vlrenda, lan.dtmvtolt, his.dshistor
        FROM tbfolha_lanaut lan, craphis his
       WHERE lan.cdcooper = pr_cdcooper
         AND lan.nrdconta = pr_nrdconta
         AND lan.dtmvtolt >= pr_dtmvtolt
         AND lan.cdcooper = his.cdcooper
         AND lan.cdhistor = his.cdhistor
       ORDER BY lan.dtmvtolt;
       
    vr_contlan  PLS_INTEGER;   
    vr_mesatual PLS_INTEGER;
    vr_mesante  PLS_INTEGER;
    vr_vltotmes DECIMAL(10,2);
                     
    vr_dsconteu VARCHAR2(4000);          
    vr_hsparfol VARCHAR2(4000);
    vr_qtdfolha PLS_INTEGER;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_des_erro VARCHAR2(10);
    vr_tab_erro gene0001.typ_tab_erro;
    
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    vr_exc_erro EXCEPTION;
    vr_exc_fim  EXCEPTION;
    
    vr_cdcooper INTEGER := 0;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_cdoperad VARCHAR2(100);
    vr_referenc VARCHAR2(7);

    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);

    --------------------------- SUBROTINAS INTERNAS --------------------------

    FUNCTION fn_busca_data_ret(pr_dtmvtolt crapdat.dtmvtolt%TYPE) RETURN DATE IS
    BEGIN
      RETURN ADD_MONTHS(  TO_DATE('01'||TO_CHAR(pr_dtmvtolt,'MM/RRRR'),'DD/MM/RRRR')   ,-3);                 
    END fn_busca_data_ret;
    
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN

    CECRED.GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                                   ,pr_cdcooper => vr_cdcooper
                                   ,pr_nmdatela => vr_nmdatela
                                   ,pr_nmeacao  => vr_nmeacao
                                   ,pr_cdagenci => vr_cdagenci
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_idorigem => vr_idorigem
                                   ,pr_cdoperad => vr_cdoperad
                                   ,pr_dscritic => vr_dscritic);
                                   
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  

    -- Buscar a data do movimento
    OPEN btch0001.cr_crapdat(vr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    
    -- Fechar o cursor
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      RAISE vr_exc_erro;
    END IF;
    
    CLOSE btch0001.cr_crapdat;
    
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
                   
    FETCH cr_crapass INTO rw_crapass;
    
    IF cr_crapass%NOTFOUND THEN
       CLOSE cr_crapass;
       RAISE vr_exc_erro;
    END IF;    

    vr_contlan := 0; /*conta qtos meses*/

    vr_mesante := 0; /*jogada no loop pra saber qdo quebrou o mes*/
    vr_vltotmes:= 0; /*valor total dos lancamentos em cada mes*/

    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
    
    -- Criar cabeçalho do XML
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root>');                      

    /* ler a tbfolha_lanaut pegar os ultimos 3 resultados da query
     ou se flultimo estiver ativa pegar apenas o ultimo*/    
    FOR rw_tbfolha_lanaut IN cr_tbfolha_lanaut(pr_cdcooper => vr_cdcooper
                                              ,pr_nrdconta => pr_nrdconta
                                              ,pr_dtmvtolt => fn_busca_data_ret(rw_crapdat.dtmvtolt) ) LOOP
      
      vr_mesatual := TO_NUMBER(TO_CHAR(rw_tbfolha_lanaut.dtmvtolt,'MM'));
      
      IF vr_mesante <> vr_mesatual THEN
        
         /*Cria o registro totalizador*/
         IF vr_vltotmes > 0 THEN
           /*VALOR TOTAL DO MES*/
           pc_escreve_xml('<TotalLancMes>'|| TO_CHAR(vr_vltotmes,'fm9g999g999g999g999g990d00') ||'</TotalLancMes>
                           <referencia>'|| vr_referenc ||'</referencia></MES>');        
                                  
           vr_vltotmes := 0;            
         END IF;
      
         vr_referenc :=  LPAD(TO_CHAR(vr_mesatual),2,'0')||'/'||TO_CHAR(rw_tbfolha_lanaut.dtmvtolt,'RRRR');
         
         --Abre tag do mes
         pc_escreve_xml('<MES>');
                               
         vr_contlan := vr_contlan + 1;
         vr_mesante := vr_mesatual;
      END IF;
      
      --Data, valor e histórico
      pc_escreve_xml('<Lancamento><dtalanca>' || TO_CHAR(rw_tbfolha_lanaut.dtmvtolt,'DD/MM/RRRR') || '</dtalanca>
                       <vlrlanca>' || TO_CHAR(rw_tbfolha_lanaut.vlrenda,'fm9g999g999g999g999g990d00') || '</vlrlanca>
                       <dshistor>' || rw_tbfolha_lanaut.dshistor || '</dshistor></Lancamento>');

      vr_vltotmes := vr_vltotmes + rw_tbfolha_lanaut.vlrenda;
      
    END LOOP;
    
    /*Criar lancamento total para ultimo mes do loop*/
    IF vr_vltotmes > 0 THEN
                                  
       /*VALOR TOTAL DO MES E REFERENCIA*/
       pc_escreve_xml('<TotalLancMes>'|| TO_CHAR(vr_vltotmes,'fm9g999g999g999g999g990d00') ||'</TotalLancMes>
                       <referencia>'|| vr_referenc ||'</referencia></MES>');
    END IF;
        
    
    /*Se nao houver lancamentos nos meses pesquisados
      devolver mensagem que nao ha lancamentos*/
    IF vr_contlan = 0 THEN
       RAISE vr_exc_fim;
    END IF;
    
    pc_escreve_xml('</Root>',TRUE);

    pr_retxml := XMLType.createXML(vr_des_xml);
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

  EXCEPTION 
    WHEN vr_exc_fim THEN
      pc_escreve_xml('<ERRO>Nao ha lancamentos para esta conta.</ERRO></Root>',TRUE);
      pr_retxml := XMLType.createXML(vr_des_xml);
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);     
    WHEN vr_exc_erro THEN
      pc_escreve_xml('<ERRO>Problemas ao consultar lancamentos para esta conta.</ERRO></Root>',TRUE);
      pr_retxml := XMLType.createXML(vr_des_xml);
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);
      pc_escreve_xml('<ERRO>Problemas ao consultar lancamentos para esta conta.</ERRO></Root>',TRUE);
      pr_retxml := XMLType.createXML(vr_des_xml);
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);                            
  END pc_busca_rendas_aut;

  PROCEDURE pc_inserir_lanaut(pr_cdcooper IN  tbfolha_lanaut.cdcooper%TYPE
                             ,pr_nrdconta IN  tbfolha_lanaut.nrdconta%TYPE
                             ,pr_dtmvtolt IN  tbfolha_lanaut.dtmvtolt%TYPE
                             ,pr_cdhistor IN  tbfolha_lanaut.cdhistor%TYPE
                             ,pr_vlrenda  IN  tbfolha_lanaut.vlrenda%TYPE
                             ,pr_cdagenci IN  tbfolha_lanaut.cdagenci%TYPE                             
                             ,pr_cdbccxlt IN  tbfolha_lanaut.cdbccxlt%TYPE
                             ,pr_nrdolote IN  tbfolha_lanaut.nrdolote%TYPE
                             ,pr_nrseqdig IN  tbfolha_lanaut.nrseqdig%TYPE
                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS  
  BEGIN
      --Melhoria 195
      --Verifica se esta dentro do range de historicos que serao gravados
      --na nova tabela tbfolha_lanaut
      IF fn_verifica_hist_lanaut(pr_cdcooper => pr_cdcooper
                                ,pr_cdhistor => pr_cdhistor) THEN
         INSERT INTO tbfolha_lanaut
                     (cdcooper
                     ,nrdconta
                     ,dtmvtolt
                     ,cdhistor
                     ,vlrenda
                     ,cdagenci
                     ,cdbccxlt
                     ,nrdolote
                     ,nrseqdig)
              VALUES(pr_cdcooper
                    ,pr_nrdconta
                    ,pr_dtmvtolt
                    ,pr_cdhistor
                    ,pr_vlrenda
                    ,pr_cdagenci
                    ,pr_cdbccxlt
                    ,pr_nrdolote
                    ,pr_nrseqdig);
      END IF; 
      
      pr_dscritic := '';
      
      COMMIT;      
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'ERRO: Nao foi possivel inserir tbfolha_lanaut.';  
      ROLLBACK;      
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
  END pc_inserir_lanaut;

  PROCEDURE pc_excluir_lanaut(pr_cdcooper IN  tbfolha_lanaut.cdcooper%TYPE                                   
                             ,pr_dtmvtolt IN  tbfolha_lanaut.dtmvtolt%TYPE
                             ,pr_cdagenci IN  tbfolha_lanaut.cdagenci%TYPE
                             ,pr_nrdconta IN  tbfolha_lanaut.nrdconta%TYPE
                             ,pr_cdhistor IN  tbfolha_lanaut.cdhistor%TYPE
                             ,pr_cdbccxlt IN  tbfolha_lanaut.cdbccxlt%TYPE
                             ,pr_nrdolote IN  tbfolha_lanaut.nrdolote%TYPE
                             ,pr_nrseqdig IN  tbfolha_lanaut.nrseqdig%TYPE
                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN

    --Melhoria 195
    --Verifica se esta dentro do range de historicos que serao gravados
    --na nova tabela tbfolha_lanaut
    IF fn_verifica_hist_lanaut(pr_cdcooper => pr_cdcooper
                              ,pr_cdhistor => pr_cdhistor) THEN
    
      DELETE 
        FROM tbfolha_lanaut
       WHERE tbfolha_lanaut.cdcooper = pr_cdcooper
         AND tbfolha_lanaut.dtmvtolt = pr_dtmvtolt
         AND tbfolha_lanaut.cdagenci = pr_cdagenci
         AND tbfolha_lanaut.nrdconta = pr_nrdconta
         AND tbfolha_lanaut.cdbccxlt = pr_cdbccxlt
         AND tbfolha_lanaut.nrdolote = pr_nrdolote
         AND tbfolha_lanaut.nrseqdig = pr_nrseqdig;
         
    END IF;     
  
    pr_dscritic := '';
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'ERRO: Nao foi possivel excluir tbfolha_lanaut.';   
      ROLLBACK;      
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
  END pc_excluir_lanaut;                           
  
  
  PROCEDURE pc_excluir_lanaut_dia(pr_cdcooper IN  tbfolha_lanaut.cdcooper%TYPE                                   
                                 ,pr_dtmvtolt IN  tbfolha_lanaut.dtmvtolt%TYPE
                                 ,pr_cdhistor IN  tbfolha_lanaut.cdhistor%TYPE
                                 ,pr_dscritic OUT crapcri.dscritic%TYPE) IS                                 
  BEGIN
    --Melhoria 195
    --Verifica se esta dentro do range de historicos que serao gravados
    --na nova tabela tbfolha_lanaut
    IF fn_verifica_hist_lanaut(pr_cdcooper => pr_cdcooper
                              ,pr_cdhistor => pr_cdhistor) THEN    
      DELETE 
        FROM tbfolha_lanaut
       WHERE tbfolha_lanaut.cdcooper = pr_cdcooper
         AND tbfolha_lanaut.dtmvtolt = pr_dtmvtolt
         AND tbfolha_lanaut.cdhistor = pr_cdhistor;        
    END IF;     
    
    pr_dscritic := '';
    COMMIT;    
  EXCEPTION 
    WHEN OTHERS THEN
      pr_dscritic := 'ERRO: Nao foi possivel excluir tbfolha_lanaut.';   
      ROLLBACK;          
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
  END pc_excluir_lanaut_dia;

  /* Função para validar se a hora informada esta dentro do horário de operacao do SPB*/
  FUNCTION fn_valida_hrportabil(pr_cdcooper    IN craptab.cdcooper%TYPE
                               ,pr_hrvalida    IN DATE DEFAULT SYSDATE) RETURN BOOLEAN IS -- Critica

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_valida_hrportabil                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Kelvin Souza Ott
  --  Data     : Janeiro/2017.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Validar se a hora informada esta dentro do horário de operacao do SPB.
  --
  ---------------------------------------------------------------------------------------------------------------
    CURSOR cr_hrportabil(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.fimopstr-600 fimopstr -- 10 minutos antes
            ,cop.iniopstr+600 iniopstr -- 10 minutos depois
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;    
    
    rw_hrportabil cr_hrportabil%ROWTYPE;
  BEGIN
    
    --Busca horario final de operacao do spb menos 10 minutos
    OPEN cr_hrportabil(pr_cdcooper);
      FETCH cr_hrportabil
       INTO rw_hrportabil;
    CLOSE cr_hrportabil;
   
    -- Se não possuir horário limite, não limita
    IF rw_hrportabil.fimopstr IS NULL OR rw_hrportabil.iniopstr IS NULL  THEN
      RETURN TRUE;
    END IF;
    
    IF to_date(to_char(pr_hrvalida,'HH24:MI'),'HH24:MI') 
       BETWEEN to_date(rw_hrportabil.iniopstr,'sssss') AND 
               to_date(rw_hrportabil.fimopstr,'sssss') THEN
      RETURN TRUE;
    END IF;
    
    --Se nao estiver no horario permitido, retorna false
    RETURN FALSE;  

  END;

END FOLH0001;
/
