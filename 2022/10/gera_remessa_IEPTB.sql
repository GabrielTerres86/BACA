-- Created on 05/10/2022 by T0034369 
DECLARE
  vr_dtmvprocessar DATE := to_date('01/04/2022', 'DD/MM/YYYY');
  vr_dscritic VARCHAR2(4000);

  PROCEDURE PC_CRPS729p (pr_dscritic OUT VARCHAR2
                                               ) IS
  /* .............................................................................

     Programa: pc_crps729
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Supero
     Data    : Fevereiro/2018                    Ultima atualizacao: 02/12/2019

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo: Integrar as remessas com o IEPTB

     Alteracoes: 
     
     10/10/2018 - Ajustado campo t06 para informar o CPF/CNPJ do cooperado (Cechet).

     12/12/2018 - Adicionado numero do endereço do beneficiario e pagador na remessa (Cechet).
     
     13/12/2018 - Ajuste na passagem de parametros do header dos arquivos de desistencia 
                  e cancelamento de protesto (Fábio/Supero).
     
     14/01/2019 - Ajuste no campo t13 - nrdocmto para dsdoccop. 
                - Adicionado campo de complemento de endereço no endereço do pagador. (Cechet).
     
     06/03/2019 - Executar apenas em dias úteis na Central (Cechet)
     
     10/05/2019 - Estavam sendo incluídos indevidamente registros de confirmação com retorno
                  do IEPTB 5 (Devolvido pelo cartório por irregularidade - Sem custas) e
                  6 (Devolvido pelo cartório por irregularidade - Com custas). Na procedure
                  pc_gera_desistencia e cursor cr_craprem foi incluido restrição desses
                  tpocorre. (PRB0041759 - AJFink)

     21/05/2019 - Arquivo de remessa gerado com XML quebrado devido dtdocmto vazio.
                  Na procedcure pc_gera_remessa e cursor cr_craprem foi incluido nvl no
                  dtdocmto. (PRB0041801 - AJFink)

     16/05/2019 - Alterado o campo 49 de I para espaco em branco (INC0012559 - Joao Mannes - Mouts)
     
     23/05/2019 - inc0014378 na rotina pc_gera_remessa, fixar o endereço do primeiro titular para evitar
                  duplicidade no envio dos arquivos (Carlos)
                  
     22/07/2019 - Inclusão de logs de execução de arquivos e itens
                  (Renato / Supero)			   

     02/12/2019 - Ajuste para enviar a agencia do cooperado no t03 (Lucas Ranghetti RITM0039430)

     24/03/2020 - Alteracoes nas regras de negocio para execucoes nos dias 24 e 31 de dezembro.
                  PRB0042699 - Gabriel Fronza Marcos (Mouts).

     28/04/2020 - Alteração no cursor cr_craprem onde ele não achava alguns boletos.
                  INC0045491 - Daniel Lombardi (Mout'S)

     22/10/2020 - Ajuste no numero de documento do arquivo de remessa.
                  PRB0043721 - Jose Dill (Mouts)

     08/01/2021 - Incluir um commit para evitar lock das tabelas e problemas no mobile e conta online 
                  devido a um problema no processo do IEPTB - PRB0043862 (Jose Dill - Mouts)                
                  
     09/03/2021 - Processar o arquivo response de retorno para efetuar a rejeição cartorária dos boletos,
                  quando a comarca estiver bloqueada - PRB0044207 (Jose Dill - Mouts)                             
                  
    ............................................................................. */


    -- Declarações
    -- Tipo de registro linha
    TYPE typ_reg_linha IS RECORD
      (ds_registro VARCHAR2(600)
      ,cdcooper    crapcop.cdcooper%TYPE
      ,ds_rowid    VARCHAR2(400)
      );
    -- Tabela para tip de registro linha
    TYPE typ_tab_arquivo IS TABLE OF typ_reg_linha INDEX BY PLS_INTEGER;
    -- Tabela para tip de registro de item de log
    TYPE typ_tab_itemlog IS TABLE OF tbcobran_log_item_arq_ieptb%ROWTYPE INDEX BY BINARY_INTEGER;


    -- Tipo de registro linha
    TYPE typ_reg_linha_response IS RECORD
      (municipio VARCHAR2(20)
      ,codigo    VARCHAR2(20)
      ,descricao VARCHAR2(800)
      ,uf        VARCHAR2(10)
      );
    -- Tabela para tipo de registro linha
    TYPE typ_tab_arquivo_response IS TABLE OF typ_reg_linha_response INDEX BY PLS_INTEGER;
    -- Tabela que contém o arquivo
    vr_tab_arquivo_response  typ_tab_arquivo_response;

    -- Tabela que contém o arquivo
    vr_index_arq   NUMBER := 0;
    vr_tab_arquivo typ_tab_arquivo;
    vr_tab_itemlog typ_tab_itemlog;
    vr_cdprogra_cpl VARCHAR2(20) := 'PC_CRPS729';



    vr_exc_erro EXCEPTION;
    -- Registro de Data
    rw_crapdat    BTCH0001.cr_crapdat%ROWTYPE;  

    -- RECEBER DATAS EM QUE O ARQUIVO NAO SERA ENVIADO
    -- ARQUIVO SERA GERADO COM DATA DO PROXIMO DIA UTIL
    vr_dtnaoenv  GENE0002.TYP_SPLIT;
    vr_flenviar  BOOLEAN := TRUE;
    vr_dtmvutil  DATE;

    vr_cdcritic  INTEGER;
    vr_cdproint  VARCHAR2 (100); -- Posiciona procedure interna
    vr_texto     CLOB;
    vr_dscritic  VARCHAR2 (4000);

    -- Selecionar os dados da Cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.cdcooper
            ,cop.cdbcoctl
            ,cop.cdagectl
            ,cop.dsdircop
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Subrotinas
    -- Controla Controla log
    PROCEDURE pc_controla_log_batch(pr_idtiplog IN NUMBER   -- Tipo de Log
                                   ,pr_dscritic IN VARCHAR2 -- Descrição do Log
                                   ) IS
      --
      vr_dstiplog VARCHAR2(10);
      --
     BEGIN
       -- Descrição do tipo de log
       IF pr_idtiplog = 2 THEN
         --
         vr_dstiplog := 'ERRO: ';
         --
       ELSE
         --
         vr_dstiplog := 'ALERTA: ';
         --
       END IF;
       -- Envio centralizado de log de erro
       btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Fixo?
                                 ,pr_ind_tipo_log => pr_idtiplog
                                 ,pr_cdprograma   => 'CRPS729'
                                 ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED', 3 /*pr_cdcooper*/, 'NOME_ARQ_LOG_MESSAGE')
                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') || ' - '
                                                             || 'CRPS729' || ' --> ' || vr_dstiplog
                                                             || pr_dscritic );
     EXCEPTION
       WHEN OTHERS THEN
         -- No caso de erro de programa gravar tabela especifica de log
         CECRED.pc_internal_exception (pr_cdcooper => 3);
     END pc_controla_log_batch;

    -- Rotina que insere uma linha na tabela em memória
    PROCEDURE pc_insere_linha(pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_rowid IN VARCHAR2
                             ,pr_linha IN VARCHAR2) IS
      vr_linha VARCHAR2(5000);
    BEGIN
      --
      vr_index_arq := vr_index_arq + 1;
      --
      vr_linha := translate(pr_linha, 'ºª', 'oa');
      --
      vr_tab_arquivo(vr_index_arq).cdcooper    := pr_cdcooper;
      vr_tab_arquivo(vr_index_arq).ds_rowid    := pr_rowid;    
      vr_tab_arquivo(vr_index_arq).ds_registro := vr_linha;

      --
    END pc_insere_linha;

   -- Atualiza o status dos títulos enviados para protesto
    PROCEDURE pc_atualiza_status_enviados(pr_rowid    IN  VARCHAR2
                                         ,pr_cdcooper IN  crapcop.cdcooper%TYPE
                                         ,pr_dscritic OUT VARCHAR2
                                         ) IS
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(1000);
      pr_nrremret crapret.nrremret%TYPE;                                     
      vr_des_erro VARCHAR2(100);
    BEGIN
      
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;
      
      -- pc_crps729 só roda na Central
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;    

      --
      UPDATE crapcob
         SET crapcob.insitcrt = 2 -- Entrada no cartório
            ,crapcob.dtsitcrt = rw_crapdat.dtmvtolt
       WHERE crapcob.rowid = pr_rowid;
       
       PAGA0001.pc_cria_log_cobranca(pr_idtabcob => pr_rowid
                                   , pr_cdoperad => '1'
                                   , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   , pr_dsmensag => 'Boleto enviado ao cartorio para Protesto'
                                   , pr_des_erro => vr_des_erro
                                   , pr_dscritic => vr_dscritic);
       
      /* Preparar Lote de Retorno Cooperado */
      PAGA0001.pc_prep_retorno_cooperado (pr_idregcob => pr_rowid            --ROWID da cobranca
                                         ,pr_cdocorre => 22                  --Codigo Ocorrencia
                                         ,pr_dsmotivo => NULL                --Descricao Motivo
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Movimento
                                         ,pr_cdoperad => '1'                 --Codigo Operador
                                         ,pr_nrremret => pr_nrremret         --Numero Retorno
                                         ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                         ,pr_dscritic => vr_dscritic);       --Descricao Critica
      --Se Ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;     
       
      -- gera movimentação de retorno do titulo 
      PAGA0001.pc_prepara_retorno_cooperativa(pr_idtabcob => pr_rowid
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_dtocorre => rw_crapdat.dtmvtolt
                                             ,pr_cdoperad => '1'
                                             ,pr_vlabatim => 0
                                             ,pr_vldescto => 0
                                             ,pr_vljurmul => 0
                                             ,pr_vlrpagto => 0
                                             ,pr_vltarifa => 0
                                             ,pr_flgdesct => FALSE
                                             ,pr_flcredit => FALSE
                                             ,pr_nrretcoo => pr_nrremret
                                             ,pr_cdmotivo => NULL
                                             ,pr_cdocorre => 22
                                             ,pr_cdbanpag => rw_crapcop.cdbcoctl
                                             ,pr_cdagepag => rw_crapcop.cdagectl
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             );

      --Se Ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;     
      --
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        pr_dscritic := 'Erro ao atualizar o status do título enviado: ' || SQLERRM;
    END pc_atualiza_status_enviados;

    -- Gera o header da remessa
    PROCEDURE pc_gera_header_remessa(pr_cdbandoc IN  VARCHAR2
                                    ,pr_nmresbcc IN  VARCHAR2
                                    ,pr_dtmvtolt IN  VARCHAR2
                                    ,pr_nrsequen IN  VARCHAR2
                                    ,pr_qtregrem IN  VARCHAR2
                                    ,pr_qttitrem IN  VARCHAR2
                                    ,pr_qtindrem IN  VARCHAR2
                                    ,pr_qtorirem IN  VARCHAR2
                                    ,pr_idagecen IN  VARCHAR2
                                    ,pr_cdprapag IN  VARCHAR2
                                    ,pr_nrseqarq IN  VARCHAR2
                                    ,pr_dsheader OUT VARCHAR2
                                    ,pr_dscritic OUT VARCHAR2
                                    ) IS
      --
    BEGIN
      --
      pr_dsheader := '0'                                        -- 01 -- Identificação do registro                -- Fixo: 0 - Header
                  || lpad(pr_cdbandoc, 3, '0')                  -- 02 -- Código do banco/portador
                  || rpad(substr(pr_nmresbcc, 0, 40), 40, ' ')  -- 03 -- Nome do portador
                  || pr_dtmvtolt                                -- 04 -- Data do movimento
                  || 'BFO'                                      -- 05 -- Sigla do remetente
                  || 'SDT'                                      -- 06 -- Sigla do destinatário
                  || 'TPR'                                      -- 07 -- Sigla de identificação da transação
                  || lpad(fn_sequence(pr_nmtabela => 'CRAPMUN'
                                     ,pr_nmdcampo => 'SQARQREM'
                                     ,pr_dsdchave => lpad(pr_cdbandoc, 3, '0') || ';' || rpad(pr_cdprapag, 7, ' ')
                                     ), 6, '0')                 -- 08 -- Seqüencial de remessas
                  || lpad(pr_qtregrem, 4, '0')                  -- 09 -- Quantidade de registro na remessa
                  || lpad(pr_qttitrem, 4, '0')                  -- 10 -- Quantidade de títulos na remessa
                  || lpad(pr_qtindrem, 4, '0')                  -- 11 -- Quantidade de indicações na remessa
                  || lpad(pr_qtorirem, 4, '0')                  -- 12 -- Quantidade de originais na remessa
                  || rpad(pr_idagecen, 6, ' ')                  -- 13 -- Identificar a agência centralizadora
                  || '043'                                      -- 14 -- Versão do layout                         -- Fixo: 043
                  || rpad(pr_cdprapag, 7, ' ')                  -- 15 -- Código da praça de pagamento
                  || rpad(' ', 497, ' ')                        -- 16 -- Complemento do registro                  -- Fixo: vazio
                  || lpad(pr_nrseqarq, 4, '0')                  -- 17 -- Número seqüencial do registro no arquivo
                  ;
      --
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        pr_dscritic := 'Erro ao gerar o header da remessa: ' || SQLERRM;
    END pc_gera_header_remessa;

  -- Grava o registro header no arquivo XML
    PROCEDURE pc_grava_header_remessa(pr_dsheader   IN     VARCHAR2
                                     ,pr_input_file IN OUT utl_file.file_type
                                     ,pr_dscritic   OUT    VARCHAR2
                                     ) IS
      --
      vr_dsdlinha VARCHAR2(4000);
      --
    BEGIN
      --
      vr_dsdlinha := '<hd h01="' || substr(pr_dsheader, 000, 001)   || '"' ||
                        ' h02="' || substr(pr_dsheader, 002, 003)   || '"' ||
                        ' h03="' || substr(pr_dsheader, 005, 040)   || '"' ||
                        ' h04="' || to_char(vr_dtmvutil,'ddmmyyyy') || '"' ||
                        ' h05="' || substr(pr_dsheader, 053, 003)   || '"' ||
                        ' h06="' || substr(pr_dsheader, 056, 003)   || '"' ||
                        ' h07="' || substr(pr_dsheader, 059, 003)   || '"' ||
                        ' h08="' || substr(pr_dsheader, 062, 006)   || '"' ||
                        ' h09="' || substr(pr_dsheader, 068, 004)   || '"' ||
                        ' h10="' || substr(pr_dsheader, 072, 004)   || '"' ||
                        ' h11="' || substr(pr_dsheader, 076, 004)   || '"' ||
                        ' h12="' || substr(pr_dsheader, 080, 004)   || '"' ||
                        ' h13="' || substr(pr_dsheader, 084, 006)   || '"' ||
                        ' h14="' || substr(pr_dsheader, 090, 003)   || '"' ||
                        ' h15="' || substr(pr_dsheader, 093, 007)   || '"' ||
                        ' h16="' || substr(pr_dsheader, 100, 497)   || '"' ||
                        ' h17="' || substr(pr_dsheader, 597, 004)   || '" />';
      -- Escrever o registro no arquivo
      gene0001.pc_escr_linha_arquivo(pr_utlfileh  => pr_input_file -- Handle do arquivo aberto
                                    ,pr_des_text  => vr_dsdlinha   -- Texto para escrita
                                    );
      --
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        pr_dscritic := 'Erro ao gerar o header da remessa: ' || SQLERRM;  
    END pc_grava_header_remessa;

  -- Gera o registro de transação da remessa
    PROCEDURE pc_gera_registro_remessa(pr_cdbandoc IN  VARCHAR2
                                      ,pr_nrdconta IN  VARCHAR2
                                      ,pr_nmprimtl IN  VARCHAR2
                                      ,pr_nrcpfcgc IN  VARCHAR2
                                      ,pr_dsendere IN  VARCHAR2
                                      ,pr_nrcepend IN  VARCHAR2
                                      ,pr_nmcidade IN  VARCHAR2
                                      ,pr_cdufende IN  VARCHAR2
                                      ,pr_nrnosnum IN  VARCHAR2
                                      ,pr_cddespec IN  VARCHAR2
                                      ,pr_nrdocmto IN  VARCHAR2
                                      ,pr_dtemiexp IN  VARCHAR2
                                      ,pr_dtvencto IN  VARCHAR2
                                      ,pr_vltitulo IN  VARCHAR2
                                      ,pr_dsdpraca IN  VARCHAR2
                                      ,pr_nmdsacad IN  VARCHAR2
                                      ,pr_cdtpinsc IN  VARCHAR2
                                      ,pr_nrinssac IN  VARCHAR2
                                      ,pr_dsendsac IN  VARCHAR2
                                      ,pr_nrcepsac IN  VARCHAR2
                                      ,pr_nmcidsac IN  VARCHAR2
                                      ,pr_cdufsaca IN  VARCHAR2
                                      ,pr_nmbaisac IN  VARCHAR2
                                      ,pr_nrseqarq IN  VARCHAR2
                                      ,pr_dstransa OUT VARCHAR2
                                      ,pr_dscritic OUT VARCHAR2
                                      ) IS
    BEGIN
      --
      pr_dstransa := '1'                                                                            -- 01 -- Identifição do registro -- Fixo: 1 - Transação
                  || lpad(pr_cdbandoc, 3, '0')                                                      -- 02 -- Número do código portador
                  || rpad(pr_nrdconta, 15, ' ')                                                     -- 03 -- Agência/Código do cedente
                  || rpad(substr(pr_nmprimtl, 0, 45), 45, ' ')                                      -- 04 -- Nome do cedente/favorecido
                  || rpad(substr(pr_nmprimtl, 0, 45), 45, ' ')                                      -- 05 -- Nome do sacador/vendedor
                  || rpad(pr_nrcpfcgc, 14, ' ')                                                     -- 06 -- Documento do Sacador
                  || rpad(substr(pr_dsendere, 0, 45), 45, ' ')                                      -- 07 -- Endereço do sacador/vendedor
                  || lpad(pr_nrcepend, 8, '0')                                                      -- 08 -- CEP do sacador/vendedor
                  || rpad(substr(pr_nmcidade, 0, 20), 20, ' ')                                      -- 09 -- Cidade do sacador/vendedor
                  || nvl(pr_cdufende, '  ')                                                         -- 10 -- UF do sacador/vendedor
                  || rpad(nvl(pr_nrnosnum, ' '), 15, ' ')                                           -- 11 -- Nosso número
                  || rpad(nvl(pr_cddespec, ' '), 3, ' ')                                            -- 12 -- Espécie do título
                  || rpad(nvl(pr_nrdocmto, ' '), 11, ' ')                                           -- 13 -- Número do título
                  || lpad(nvl(pr_dtemiexp, '0'), 8, '0')                                            -- 14 -- Data da emissão do título
                  || lpad(nvl(pr_dtvencto, '0'), 8, '0')                                            -- 15 -- Data de vencimento do título
                  || '001'                                                                          -- 16 -- Tipo de moeda -- Fixo: 001 - Real
                  || lpad(pr_vltitulo, 14, '0')                                                     -- 17 -- Valor do título
                  || lpad(pr_vltitulo, 14, '0')                                                     -- 18 -- Saldo do título
                  || rpad(substr(nvl(pr_dsdpraca, '0'), 0, 20), 20, '0')                            -- 19 -- Praça de protesto
                  || 'M'                                                                            -- 20 -- Tipo de Endesso -- Fixo: Endosso Mandato
                  || 'N'                                                                            -- 21 -- Informação sobre aceite -- Fixo: Não Aceitos
                  || '1'                                                                            -- 22 -- Número de controle do(s) devedor(es) -- Fixo: 1
                  || rpad(substr(pr_nmdsacad, 0, 45), 45, ' ')                                      -- 23 -- Nome do devedor
                  || lpad(pr_cdtpinsc, 3, '0')                                                      -- 24 -- Tipo de identificação do devedor
                  || lpad(pr_nrinssac, 14, '0')                                                     -- 25 -- Número de identificação do devedor
                  || rpad(' ', 11, ' ')                                                             -- 26 -- Documento do devedor -- Fixo: Vazio
                  || rpad(substr(pr_dsendsac, 0, 45), 45, ' ')                                      -- 27 -- Endereço do devedor
                  || lpad(pr_nrcepsac, 8, '0')                                                      -- 28 -- CEP do devedor
                  || rpad(substr(pr_nmcidsac, 0, 20), 20, ' ')                                      -- 29 -- Cidade do devedor
                  || pr_cdufsaca                                                                    -- 30 -- UF do devedor
                  || '00'                                                                           -- 31 -- Código do cartório -- Uso restrito do serviço de distribuição
                  || rpad(' ', 10, ' ')                                                             -- 32 -- Número do protocolo do cartório -- Uso restrito do serviço de distribuição
                  || ' '                                                                            -- 33 -- Tipo de ocorrência -- Uso restrito do serviço de distribuição
                  || lpad('0', 8, '0')                                                              -- 34 -- Data do protocolo -- Uso restrito do serviço de distribuição
                  || lpad('0', 10, '0')                                                             -- 35 -- Valor das custas do cartório -- Uso restrito do serviço de distribuição
                  || 'D'                                                                            -- 36 -- Declaração do portador
                  || lpad('0', 8, '0')                                                              -- 37 -- Data da ocorrência -- Uso restrito do serviço de distribuição
                  || '  '                                                                           -- 38 -- Código de irregularidade -- Uso restrito do serviço de distribuição
                  || rpad(substr(pr_nmbaisac, 0, 20), 20, ' ')                                      -- 39 -- Bairro do devedor
                  || lpad('0', 10, '0')                                                             -- 40 -- Valor das custas do cartório distribuidor -- Uso restrito do serviço de distribuição
                  || lpad('0', 6, '0')                                                              -- 41 -- Registro de distribuição -- Uso restrito do 7ª ofício do Rio de Janeiro
                  || lpad('0', 10, '0')                                                             -- 42 -- Valor da gravação eletrônica e demais despesas -- Uso restrito da Centralizadora de Remessa de Arquivos (CRA)
                  || lpad('0', 5, '0')                                                              -- 43 -- Número da operação do banco -- Exclusivo para protesto de letra de câmbio
                  || lpad('0', 15, '0')                                                             -- 44 -- Número do contrato do banco -- Exclusivo para protesto de letra de câmbio
                  || lpad('0', 3, '0')                                                              -- 45 -- Número da parcela do contrato -- Exclusivo para protesto de letra de câmbio
                  || ' '                                                                            -- 46 -- Tipo da letra de câmbio -- Exclusivo para protesto de letra de câmbio
                  || rpad(' ', 8, ' ')                                                              -- 47 -- Complemento código de irregularidade -- Uso restrito do serviço de distribuição
                  || ' '                                                                            -- 48 -- Protesto por motivo de falência -- Fixo: vazio
                  || ' '                                                                            -- 49 -- Instrumento de protesto -- Fixo: Espaço em branco (Era letra I)
                  || lpad('0', 10, '0')                                                             -- 50 -- Valor das demais despesas -- Uso restrito dos cartórios
                  || rpad(' ', 19, ' ')                                                             -- 51 -- Complemento do registro -- Fixo branco
                  || lpad(pr_nrseqarq, 4, '0')                                                      -- 52 -- Número seqüencial do registro no arquivo 
                  ;        
      --
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        pr_dscritic := 'Erro ao gerar a transação da remessa: ' || SQLERRM;
    END pc_gera_registro_remessa;

   -- Grava o registro transação no arquivo XML
    PROCEDURE pc_grava_transacao_remessa(pr_dstransa   IN     VARCHAR2
                                        ,pr_input_file IN OUT utl_file.file_type
                                        ,pr_dscritic   OUT    VARCHAR2
                                        ) IS
      --
      vr_dsdlinha VARCHAR2(4000);
      --
    BEGIN
      --
      vr_dsdlinha := '<tr t01="' || substr(pr_dstransa, 000, 001) || '"' ||
                        ' t02="' || substr(pr_dstransa, 002, 003) || '"' ||
                        ' t03="' || substr(pr_dstransa, 005, 015) || '"' ||
                        ' t04="' || substr(pr_dstransa, 020, 045) || '"' ||
                        ' t05="' || substr(pr_dstransa, 065, 045) || '"' ||
                        ' t06="' || substr(pr_dstransa, 110, 014) || '"' ||
                        ' t07="' || substr(pr_dstransa, 124, 045) || '"' ||
                        ' t08="' || substr(pr_dstransa, 169, 008) || '"' ||
                        ' t09="' || substr(pr_dstransa, 177, 020) || '"' ||
                        ' t10="' || substr(pr_dstransa, 197, 002) || '"' ||
                        ' t11="' || substr(pr_dstransa, 199, 015) || '"' ||
                        ' t12="' || substr(pr_dstransa, 214, 003) || '"' ||
                        ' t13="' || substr(pr_dstransa, 217, 011) || '"' ||
                        ' t14="' || substr(pr_dstransa, 228, 008) || '"' ||
                        ' t15="' || substr(pr_dstransa, 236, 008) || '"' ||
                        ' t16="' || substr(pr_dstransa, 244, 003) || '"' ||
                        ' t17="' || substr(pr_dstransa, 247, 014) || '"' ||
                        ' t18="' || substr(pr_dstransa, 261, 014) || '"' ||
                        ' t19="' || substr(pr_dstransa, 275, 020) || '"' ||
                        ' t20="' || substr(pr_dstransa, 295, 001) || '"' ||
                        ' t21="' || substr(pr_dstransa, 296, 001) || '"' ||
                        ' t22="' || substr(pr_dstransa, 297, 001) || '"' ||
                        ' t23="' || substr(pr_dstransa, 298, 045) || '"' ||
                        ' t24="' || substr(pr_dstransa, 343, 003) || '"' ||
                        ' t25="' || substr(pr_dstransa, 346, 014) || '"' ||
                        ' t26="' || substr(pr_dstransa, 360, 011) || '"' ||
                        ' t27="' || substr(pr_dstransa, 371, 045) || '"' ||
                        ' t28="' || substr(pr_dstransa, 416, 008) || '"' ||
                        ' t29="' || substr(pr_dstransa, 424, 020) || '"' ||
                        ' t30="' || substr(pr_dstransa, 444, 002) || '"' ||
                        ' t31="' || substr(pr_dstransa, 446, 002) || '"' ||
                        ' t32="' || substr(pr_dstransa, 448, 010) || '"' ||
                        ' t33="' || substr(pr_dstransa, 458, 001) || '"' ||
                        ' t34="' || substr(pr_dstransa, 459, 008) || '"' ||
                        ' t35="' || substr(pr_dstransa, 467, 010) || '"' ||
                        ' t36="' || substr(pr_dstransa, 477, 001) || '"' ||
                        ' t37="' || substr(pr_dstransa, 478, 008) || '"' ||
                        ' t38="' || substr(pr_dstransa, 486, 002) || '"' ||
                        ' t39="' || substr(pr_dstransa, 488, 020) || '"' ||
                        ' t40="' || substr(pr_dstransa, 508, 010) || '"' ||
                        ' t41="' || substr(pr_dstransa, 518, 006) || '"' ||
                        ' t42="' || substr(pr_dstransa, 524, 010) || '"' ||
                        ' t43="' || substr(pr_dstransa, 534, 005) || '"' ||
                        ' t44="' || substr(pr_dstransa, 539, 015) || '"' ||
                        ' t45="' || substr(pr_dstransa, 554, 003) || '"' ||
                        ' t46="' || substr(pr_dstransa, 557, 001) || '"' ||
                        ' t47="' || substr(pr_dstransa, 558, 008) || '"' ||
                        ' t48="' || substr(pr_dstransa, 566, 001) || '"' ||
                        ' t49="' || substr(pr_dstransa, 567, 001) || '"' ||
                        ' t50="' || substr(pr_dstransa, 568, 010) || '"' ||
                        ' t51="' || substr(pr_dstransa, 578, 019) || '"' ||
                        ' t52="' || substr(pr_dstransa, 597, 004) || '" />';
      -- Escrever o registro no arquivo
      gene0001.pc_escr_linha_arquivo(pr_utlfileh  => pr_input_file -- Handle do arquivo aberto
                                    ,pr_des_text  => vr_dsdlinha   -- Texto para escrita
                                    );
      --
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        pr_dscritic := 'Erro ao gerar a transação da remessa: ' || SQLERRM;  
    END pc_grava_transacao_remessa;


    -- Gera o trailler da remessa
    PROCEDURE pc_gera_trailler_remessa(pr_cdbandoc IN  VARCHAR2
                                      ,pr_nmresbcc IN  VARCHAR2
                                      ,pr_dtmvtolt IN  VARCHAR2
                                      ,pr_vltotrem IN  VARCHAR2
                                      ,pr_nrseqarq IN  VARCHAR2
                                      ,pr_dstraill OUT VARCHAR2
                                      ,pr_dscritic OUT VARCHAR2
                                      ) IS
    BEGIN
      --
      pr_dstraill := '9'                                                                                -- 01 -- Identificação do registro -- Fixo: 9 - Trailler
                  || lpad(pr_cdbandoc, 3, '0')                                                          -- 02 -- Número do código do portador
                  || rpad(substr(pr_nmresbcc, 0, 40), 40, ' ')                                          -- 03 -- Nome do portador
                  || pr_dtmvtolt                                                                        -- 04 -- Data do movimento
                  || lpad('0', 5, '0')                                                                  -- 05 -- Somatório de segurança - Quantidade de remessa
                  || lpad(pr_vltotrem, 18, '0')                                                         -- 06 -- Somatório de segurança - Valor da remessa
                  || rpad(' ', 521, ' ')                                                                -- 07 -- -- Complemento do registro -- Fixo: vazio
                  || lpad(pr_nrseqarq, 4, '0')                                                          -- 08 -- Número sequencial do registro
                  ;
      --
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        pr_dscritic := 'Erro ao gerar o trailler da remessa: ' || SQLERRM;
    END pc_gera_trailler_remessa;

   -- Grava o registro trailler no arquivo XML
    PROCEDURE pc_grava_trailler_remessa(pr_dstraill   IN     VARCHAR2
                                       ,pr_input_file IN OUT utl_file.file_type
                                       ,pr_dscritic   OUT    VARCHAR2
                                       ) IS
      --
      vr_dsdlinha VARCHAR2(4000);
      --
    BEGIN
      --
      vr_dsdlinha := '<tl t01="' || substr(pr_dstraill, 000, 001)   || '"' ||
                        ' t02="' || substr(pr_dstraill, 002, 003)   || '"' ||
                        ' t03="' || substr(pr_dstraill, 005, 040)   || '"' ||
                        ' t04="' || to_char(vr_dtmvutil,'ddmmyyyy') || '"' ||
                        ' t05="' || substr(pr_dstraill, 053, 005)   || '"' ||
                        ' t06="' || substr(pr_dstraill, 058, 018)   || '"' ||
                        ' t07="' || substr(pr_dstraill, 076, 521)   || '"' ||
                        ' t08="' || substr(pr_dstraill, 597, 004)   || '" />';
      -- Escrever o registro no arquivo
      gene0001.pc_escr_linha_arquivo(pr_utlfileh  => pr_input_file -- Handle do arquivo aberto
                                    ,pr_des_text  => vr_dsdlinha   -- Texto para escrita
                                    );
      --
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        pr_dscritic := 'Erro ao gerar o trailler da remessa: ' || SQLERRM;  
    END pc_grava_trailler_remessa;

    -- Gera remessas a serem enviadas
    PROCEDURE pc_gera_remessa(pr_dscritic OUT VARCHAR2
                             ) IS
      --
      CURSOR cr_craprem (pr_dtmvtolt IN DATE) IS
        SELECT DISTINCT
               crapcob.cdcooper
              ,crapcob.nrcnvcob
              ,crapcob.nrdconta  nrctalog  -- Número da conta para o log
              ,crapcob.nrdocmto            -- Número do documento para o log
              ,crapcob.nrdctabb            -- Conta para log
              ,crapcob.vltitulo  vltitlog  -- Valor do titulo para log
              ,crapcob.cdbandoc  cdbanlog  -- Banco para o log
              ,lpad(crapcob.cdbandoc, 3, '0') cdbandoc                                                      -- Campo 02 - Header/Transação
              ,rpad(crapban.nmresbcc, 40, ' ') nmresbcc                                                     -- Campo 03 - Header
              ,to_char(crapdat.dtmvtopr, 'DDMMYYYY') dtmvtolt                                               -- Campo 04 - Header
              ,rpad(crapcop.cdagectl, 6, ' ') cdagectl                                                      -- Campo 13 - Header
              ,crapmun.cdcomarc                                                                             -- Campo 15 - Header
              ,lpad(crapcop.cdagectl, 4, '0') || lpad(crapass.cdagenci, 3, '0') ||
               lpad(crapcob.nrdconta, 8, '0') nrdconta                                                      -- Campo 03 - Transação
              ,rpad(crapass.nmprimtl, 45, ' ') nmprimtl                                                     -- Campo 04/05 - Transação
              ,lpad(to_char(crapass.nrcpfcgc), 14, '0') nrcpfcgc                                            -- Campo 06 - Transação
              ,rpad(crapenc.dsendere || CASE WHEN nvl(crapenc.nrendere,0) > 0 THEN ' ' || to_char(crapenc.nrendere) END
                                    , 45, ' ') dsendere                                                     -- Campo 07 - Transação
              ,lpad(crapenc.nrcepend, 8, '0') nrcepend                                                      -- Campo 08 - Transação
              ,rpad(crapenc.nmcidade, 20, ' ') nmcidade                                                     -- Campo 09 - Transação
              ,rpad(crapenc.cdufende, 2, ' ') cdufende                                                      -- Campo 10 - Transação
              ,lpad(crapcob.nrcnvcob, 6, '0') || lpad(crapcob.nrdocmto, 9, '0') nrnosnum                    -- Campo 11 - Transação
              ,decode(crapcob.cddespec, 1, 'DMI', 2, 'DSI', '   ') cddespec                                 -- Campo 12 - Transação
              ,rpad(crapcob.dsdoccop, 11, ' ') dsdoccop                                                     -- Campo 13 - Transação
              --,to_char(crapcob.dtemiexp, 'DDMMYYYY') dtemiexp                                               -- Campo 14 - Transação
              ,to_char(nvl(crapcob.dtdocmto,crapcob.dtmvtolt), 'DDMMYYYY') dtemiexp                         -- Campo 14 - Transação --PRB0041801
              ,to_char(crapcob.dtvencto, 'DDMMYYYY') dtvencto                                               -- Campo 15 - Transação
              --,lpad(replace(trim(to_char(crapcob.vltitulo, '999999999990D90')), ',', ''), 14, '0') vltitulo -- Campo 17/18 - Transação
              ,lpad(TRUNC(crapcob.vltitulo * 100), 14, '0') vltitulo                                        -- Campo 17/18 - Transação
              ,rpad(SUBSTR(comarca.dscidade, 0, 20), 20, ' ') dscidade                                      -- Campo 19 - Transação
              ,rpad(substr(gene0007.fn_caract_especial(crapsab.nmdsacad), 0, 45), 45, ' ') nmdsacad         -- Campo 23 - Transação
              ,lpad(decode(crapsab.cdtpinsc, 1, 2, 2, 1, 0), 3, '0') cdtpinsc                               -- Campo 24 - Transação
              ,lpad(crapsab.nrinssac, 14, '0') nrinssac                                                     -- Campo 25 - Transação
              ,rpad(substr(gene0007.fn_caract_especial(crapsab.dsendsac) || CASE WHEN NVL(crapsab.nrendsac,0) > 0 THEN ' ' || to_char(crapsab.nrendsac) END ||
                                               CASE WHEN TRIM(crapsab.complend) IS NOT NULL THEN ' ' || TRIM(gene0007.fn_caract_especial(crapsab.complend)) END
                                           , 0, 45), 45, ' ') dsendsac                                      -- Campo 27 - Transação
              ,lpad(crapsab.nrcepsac, 8, '0') nrcepsac                                                      -- Campo 28 - Transação
              ,rpad(substr(gene0007.fn_caract_especial(crapsab.nmcidsac), 0, 20), 20, ' ') nmcidsac                                      -- Campo 29 - Transação
              ,crapsab.cdufsaca                                                                             -- Campo 30 - Transação
              ,rpad(substr(gene0007.fn_caract_especial(crapsab.nmbaisac), 0, 20), 20, ' ') nmbaisac                                      -- Campo 39 - Transação
              ,crapcob.rowid
          FROM craprem
              ,crapcob
              ,crapdat
              ,crapban
              ,crapcop
              ,crapass
              ,crapenc
              ,crapsab
              ,crapmun
              ,crapmun comarca
              ,crapcco
              ,crapcre
              ,crapdne 
         WHERE crapcco.cdcooper > 0
           AND crapcco.cddbanco = 85
           AND crapcre.cdcooper = crapcco.cdcooper
           AND crapcre.nrcnvcob = crapcco.nrconven
           AND crapcre.dtmvtolt = pr_dtmvtolt
           AND crapcre.intipmvt = 1
           AND craprem.cdcooper = crapcre.cdcooper
           AND craprem.nrcnvcob = crapcre.nrcnvcob
           AND craprem.nrremret = crapcre.nrremret
           AND crapcob.cdcooper = craprem.cdcooper
           AND crapcob.nrdconta = craprem.nrdconta
           AND crapcob.nrcnvcob = craprem.nrcnvcob
           AND crapcob.nrdocmto = craprem.nrdocmto
           AND crapdat.cdcooper = crapcob.cdcooper
           AND crapban.cdbccxlt = crapcob.cdbandoc
           AND crapcop.cdcooper = crapcob.cdcooper
           AND crapass.nrdconta = crapcob.nrdconta
           AND crapass.cdcooper = crapcob.cdcooper
           AND crapenc.cdcooper = crapass.cdcooper
           AND crapenc.nrdconta = crapass.nrdconta
           AND crapenc.tpendass = 9 -- Comercial
           AND crapenc.idseqttl = 1
           AND crapsab.cdcooper = crapcob.cdcooper
           AND crapsab.nrdconta = crapcob.nrdconta
           AND crapsab.nrinssac = crapcob.nrinssac
           AND crapdne.nrceplog = crapsab.nrcepsac
           AND crapdne.idoricad = 1 -- CEP dos correios
             AND LPAD(crapmun.cdufibge, 2, '0') || LPAD(crapmun.cdcidbge, 5, '0') = crapdne.cdcidibge 
           AND LPAD(comarca.cdufibge, 2, '0') || LPAD(comarca.cdcidbge, 5, '0') = crapmun.cdcomarc
           AND crapcob.cdbandoc = 85
           AND crapcob.insrvprt = 1
           AND crapcob.insitcrt = 1 -- Com instrução de protesto
           AND craprem.cdocorre = 9 -- Somente boletos c/ instrução de protesto
         ORDER BY crapmun.cdcomarc;
      --
      rw_craprem cr_craprem%ROWTYPE;
      --
      vr_arq_xml CLOB;
      --
      vr_nmcidsac crapsab.nmcidsac%TYPE;
      vr_qtregist NUMBER;
      vr_qtnumarq NUMBER;
      vr_dsdlinha VARCHAR2(600);
      vr_vlsomseg NUMBER;
      --
      vr_exc_erro EXCEPTION;
      --
    BEGIN
      -- Incluido controle de Log inicio programa
      pc_controla_log_batch(1, 'Início pc_crps729.pc_gera_remessa');
      -- Inicializa variáveis
      vr_nmcidsac  := NULL;
      vr_qtregist  := 1;
      vr_qtnumarq  := 0;
      vr_vlsomseg  := 0;
      vr_index_arq := 0;
      
      -- Limpar possiveis registros de logs anteriores
      vr_tab_itemlog.DELETE;
      
      --
      OPEN cr_craprem(pr_dtmvtolt => vr_dtmvprocessar);
      --
      LOOP
        --
        FETCH cr_craprem INTO rw_craprem;
        EXIT WHEN cr_craprem%NOTFOUND;
        -- Verifica se precisa inicializar uma nova remessa
        IF nvl(vr_nmcidsac, '0') <> rw_craprem.dscidade THEN
          -- Verifica se finaliza a remessa anterior
          IF vr_qtnumarq > 0 THEN
            --
            vr_dsdlinha := NULL;
            --
            pc_gera_trailler_remessa(pr_cdbandoc => rw_craprem.cdbandoc -- IN
                                    ,pr_nmresbcc => rw_craprem.nmresbcc -- IN
                                    ,pr_dtmvtolt => rw_craprem.dtmvtolt -- IN
                                    ,pr_vltotrem => vr_vlsomseg         -- IN
                                    ,pr_nrseqarq => vr_qtregist         -- IN
                                    ,pr_dstraill => vr_dsdlinha         -- OUT
                                    ,pr_dscritic => pr_dscritic         -- OUT
                                    );
            --
            IF pr_dscritic IS NOT NULL THEN
              --
              RAISE vr_exc_erro;
              --
            ELSE
              --
              pc_insere_linha(pr_linha => vr_dsdlinha      -- IN
                             ,pr_cdcooper => rw_craprem.cdcooper
                             ,pr_rowid => rw_craprem.rowid -- IN
                             );
              --
            END IF;
            --
            vr_qtregist := 1;
            --
          END IF;
          --
          vr_qtregist := 1;
          vr_nmcidsac := rw_craprem.dscidade;
          vr_qtnumarq := vr_qtnumarq + 1;
          vr_vlsomseg := 0;
          --
        END IF;     
        
        -- Se for o primeiro registro, gerar o cabeçalho
        IF vr_qtregist = 1 THEN
          --
          vr_dsdlinha := NULL;
          --
          pc_gera_header_remessa(pr_cdbandoc => rw_craprem.cdbandoc -- IN
                                ,pr_nmresbcc => rw_craprem.nmresbcc -- IN
                                ,pr_dtmvtolt => rw_craprem.dtmvtolt -- IN
                                ,pr_nrsequen => vr_qtnumarq         -- IN
                                ,pr_qtregrem => 0                   -- IN
                                ,pr_qttitrem => 0                   -- IN
                                ,pr_qtindrem => 0                   -- IN
                                ,pr_qtorirem => 0                   -- IN
                                ,pr_idagecen => rw_craprem.cdagectl -- IN
                                ,pr_cdprapag => rw_craprem.cdcomarc -- IN
                                ,pr_nrseqarq => vr_qtregist         -- IN
                                ,pr_dsheader => vr_dsdlinha         -- OUT
                                ,pr_dscritic => pr_dscritic         -- OUT
                                );
          --
          IF pr_dscritic IS NOT NULL THEN
            --
            RAISE vr_exc_erro;
            --
          ELSE
            --
            pc_insere_linha(pr_linha => vr_dsdlinha      -- IN
                           ,pr_cdcooper => rw_craprem.cdcooper
                           ,pr_rowid => rw_craprem.rowid -- IN
                           );
            --
          END IF;
          --
          vr_qtregist := vr_qtregist + 1;
          --
        END IF;
        --
        vr_dsdlinha := null;
        --
        pc_gera_registro_remessa(pr_cdbandoc => rw_craprem.cdbandoc -- IN
                                ,pr_nrdconta => rw_craprem.nrdconta -- IN
                                ,pr_nmprimtl => rw_craprem.nmprimtl -- IN
                                ,pr_nrcpfcgc => rw_craprem.nrcpfcgc -- IN
                                ,pr_dsendere => rw_craprem.dsendere -- IN
                                ,pr_nrcepend => rw_craprem.nrcepend -- IN
                                ,pr_nmcidade => rw_craprem.nmcidade -- IN
                                ,pr_cdufende => rw_craprem.cdufende -- IN
                                ,pr_nrnosnum => rw_craprem.nrnosnum -- IN
                                ,pr_cddespec => rw_craprem.cddespec -- IN
                                ,pr_nrdocmto => rw_craprem.nrdocmto -- IN
                                ,pr_dtemiexp => rw_craprem.dtemiexp -- IN
                                ,pr_dtvencto => rw_craprem.dtvencto -- IN
                                ,pr_vltitulo => rw_craprem.vltitulo -- IN
                                ,pr_dsdpraca => rw_craprem.dscidade -- IN
                                ,pr_nmdsacad => rw_craprem.nmdsacad -- IN
                                ,pr_cdtpinsc => rw_craprem.cdtpinsc -- IN
                                ,pr_nrinssac => rw_craprem.nrinssac -- IN
                                ,pr_dsendsac => rw_craprem.dsendsac -- IN
                                ,pr_nrcepsac => rw_craprem.nrcepsac -- IN
                                ,pr_nmcidsac => rw_craprem.nmcidsac -- IN
                                ,pr_cdufsaca => rw_craprem.cdufsaca -- IN
                                ,pr_nmbaisac => rw_craprem.nmbaisac -- IN
                                ,pr_nrseqarq => vr_qtregist         -- IN
                                ,pr_dstransa => vr_dsdlinha         -- OUT
                                ,pr_dscritic => pr_dscritic         -- OUT
                                );
        --
        IF pr_dscritic IS NOT NULL THEN
          --
          RAISE vr_exc_erro;
          --
        ELSE
          --
            pc_insere_linha(pr_linha => vr_dsdlinha      -- IN
                           ,pr_cdcooper => rw_craprem.cdcooper
                           ,pr_rowid => rw_craprem.rowid -- IN
                           );
          --
        END IF;
        --
        vr_qtregist := vr_qtregist + 1;
        --
        vr_vlsomseg := vr_vlsomseg + rw_craprem.vltitulo;
        --
        -- Adicionar item no log
        vr_tab_itemlog(vr_tab_itemlog.count()+1).cdcooper := rw_craprem.cdcooper;
        vr_tab_itemlog(vr_tab_itemlog.count()  ).cdbandoc := rw_craprem.cdbanlog;
        vr_tab_itemlog(vr_tab_itemlog.count()  ).nrdctabb := rw_craprem.nrdctabb;
        vr_tab_itemlog(vr_tab_itemlog.count()  ).nrcnvcob := rw_craprem.nrcnvcob;
        vr_tab_itemlog(vr_tab_itemlog.count()  ).nrdconta := rw_craprem.nrctalog;
        vr_tab_itemlog(vr_tab_itemlog.count()  ).nrdocmto := rw_craprem.nrdocmto;
        vr_tab_itemlog(vr_tab_itemlog.count()  ).vltitulo := rw_craprem.vltitlog;
      END LOOP;
      -- Verifica se finaliza a remessa anterior
      IF vr_qtregist > 1 THEN
        --
        vr_dsdlinha := NULL;
        --

        pc_gera_trailler_remessa(pr_cdbandoc => rw_craprem.cdbandoc -- IN
                                ,pr_nmresbcc => rw_craprem.nmresbcc -- IN
                                ,pr_dtmvtolt => rw_craprem.dtmvtolt -- IN
                                ,pr_vltotrem => vr_vlsomseg         -- IN
                                ,pr_nrseqarq => vr_qtregist         -- IN
                                ,pr_dstraill => vr_dsdlinha         -- OUT
                                ,pr_dscritic => pr_dscritic         -- OUT
                                );
        --
        IF pr_dscritic IS NOT NULL THEN
          --
          RAISE vr_exc_erro;
          --
        ELSE
          --
          pc_insere_linha(pr_linha => vr_dsdlinha      -- IN
                         ,pr_cdcooper => rw_craprem.cdcooper
                         ,pr_rowid => rw_craprem.rowid -- IN
                         );
          --
        END IF;
        --
      END IF;
      --
      CLOSE cr_craprem;
      -- Escrever o log no arquivo
      pc_controla_log_batch(1, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_remessa --> Finalizado o processamento das remessas.'); -- Texto para escrita
      --
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Incluído controle de Log
        pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_remessa --> ' || rw_craprem.cdcooper || '/' || rw_craprem.nrdconta || '/' || rw_craprem.nrnosnum || ' não processado devido ao ERRO: ' || pr_dscritic);
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        -- Incluído controle de Log
        pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_remessa --> ' || rw_craprem.cdcooper || '/' || rw_craprem.nrdconta || '/' || rw_craprem.nrnosnum || ' não processado devido ao ERRO: ' || SQLERRM);
    END pc_gera_remessa;

  -- Gera o arquivo de remessa
    PROCEDURE pc_gera_arquivo_remessa(pr_dscritic OUT VARCHAR2
                                     ) IS
      --
      vr_dtmvtolt   crapdat.dtmvtolt%TYPE;
      vr_input_file utl_file.file_type;
      vr_nmarqtxt   VARCHAR2(13);
      vr_nmdirtxt   VARCHAR2(400);
      --
      vr_dslinhea   VARCHAR2(600);
      vr_dslintra   VARCHAR2(600);
      vr_qtregrem   NUMBER;
      vr_qtindrem   NUMBER;
      vr_qtorirem   NUMBER;
      vr_idlogarq   tbcobran_log_arquivo_ieptb.idlog_arquivo%TYPE;
      vr_dscrilog   VARCHAR2(1000);
      --
      vr_index_arq_ant NUMBER;
      vr_index_reg     NUMBER;
      --
      vr_exc_erro EXCEPTION;
      vr_aux INTEGER;
      --
    BEGIN
      -- Incluido controle de Log inicio programa
      pc_controla_log_batch(1, 'Início crps729.pc_gera_arquivo_remessa');
      --
      IF vr_tab_arquivo.count > 0 THEN

        vr_dtmvtolt := TRUNC(SYSDATE);

        -- Busca o nome do arquivo
        vr_nmarqtxt := cobr0011.fn_gera_nome_arquivo_remessa(pr_cdbandoc => 85          -- IN
                                                            ,pr_dtmvtolt => vr_dtmvutil -- IN
                                                            );
                                                                  
        -- Diretório onde deverá gerar o arquivo de remessa
        --vr_nmdirtxt := '/micros/cecred/ieptb/remessa/';
        vr_nmdirtxt := gene0001.fn_param_sistema (pr_nmsistem => 'CRED'              -- IN
                                                 ,pr_cdcooper => 3                   -- IN
                                                 ,pr_cdacesso => 'DIR_IEPTB_REMESSA' -- IN
                                                 );
        -- Abre o arquivo de dados em modo de gravação
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirtxt   -- IN -- Diretório do arquivo
                                ,pr_nmarquiv => vr_nmarqtxt   -- IN -- Nome do arquivo
                                ,pr_tipabert => 'W'           -- IN -- Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_input_file -- IN -- Handle do arquivo aberto
                                ,pr_des_erro => pr_dscritic   -- IN -- Erro
                                );
        --
        IF pr_dscritic IS NOT NULL THEN
          --
          RAISE vr_exc_erro;
          --
        END IF;
        -- Escrever o registro no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file            -- Handle do arquivo aberto
                                      ,pr_des_text  => '<?xml version="1.0"?> ' -- Texto para escrita
                                      );
        -- Abre a remessa
        -- Escrever o registro no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file -- Handle do arquivo aberto
                                      ,pr_des_text  => '<remessa>'   -- Texto para escrita
                                      );
        -- Busca o primeiro registro
        vr_index_arq := vr_tab_arquivo.first;
        -- Percorre todos os registros para gerar os totalizadores
        WHILE vr_index_arq IS NOT NULL LOOP
          -- Verifica se o registro é do tipo header
          IF substr(vr_tab_arquivo(vr_index_arq).ds_registro, 0, 1) = 0 THEN
            --
            vr_dslinhea      := vr_tab_arquivo(vr_index_arq).ds_registro;
            vr_index_arq_ant := NULL;
            vr_qtregrem      := 0;
            vr_qtindrem      := 0;
            vr_qtorirem      := 0;
            --
          -- Verifica se o registro é do tipo transação
          ELSIF substr(vr_tab_arquivo(vr_index_arq).ds_registro, 0, 1) = 1 THEN
            -- Guarda a posição do primeiro registro de transação da remessa
            IF vr_index_arq_ant IS NULL THEN
              --
              vr_index_arq_ant := vr_index_arq;
              --
            END IF;
            --
            vr_qtregrem := vr_qtregrem + 1; -- Campo 09/10
            --
            IF substr(vr_tab_arquivo(vr_index_arq).ds_registro, 214, 3) IN('DMI', 'DRI', 'CBI') THEN
              --
              vr_qtindrem := vr_qtindrem + 1; -- Campo 11
              --
            ELSE
              --
              vr_qtorirem := vr_qtorirem + 1; -- Campo 12
              --
            END IF;
            --
          -- Verifica se o registro é do tipo trailler
          ELSIF substr(vr_tab_arquivo(vr_index_arq).ds_registro, 0, 1) = 9 THEN
            --
            vr_dslintra := vr_tab_arquivo(vr_index_arq).ds_registro;
            -- Joga os totais no header
            vr_dslinhea := substr(vr_dslinhea, 0, 67) || lpad(vr_qtregrem, 4, '0') || lpad(vr_qtregrem, 4, '0') || lpad(vr_qtindrem, 4, '0') || lpad(vr_qtorirem, 4, '0') || substr(vr_dslinhea, 84, 517);
            -- Grava o header
            pc_grava_header_remessa(pr_dsheader   => vr_dslinhea   -- IN
                                   ,pr_input_file => vr_input_file -- IN OUT
                                   ,pr_dscritic   => pr_dscritic   -- OUT
                                   );
            --
            IF pr_dscritic IS NOT NULL THEN
              --
              RAISE vr_exc_erro;
              --
            END IF;
            --
            vr_index_reg := vr_index_arq_ant;
            -- Grava as transações
            WHILE vr_index_reg IS NOT NULL LOOP
              -- Finaliza
              IF substr(vr_tab_arquivo(vr_index_reg).ds_registro, 0, 1) = 9 THEN
                --
                vr_index_reg := NULL;
                EXIT;
                --
              ELSE
                -- Gravar a transação
                pc_grava_transacao_remessa(pr_dstransa   => vr_tab_arquivo(vr_index_reg).ds_registro -- IN
                                          ,pr_input_file => vr_input_file                            -- IN OUT
                                          ,pr_dscritic   => pr_dscritic                              -- OUT
                                          );
                --
                IF pr_dscritic IS NOT NULL THEN
                  --
                  RAISE vr_exc_erro;
                  --
                END IF;
                --
                pc_atualiza_status_enviados(pr_rowid    => vr_tab_arquivo(vr_index_reg).ds_rowid -- IN
                                           ,pr_cdcooper => vr_tab_arquivo(vr_index_reg).cdcooper
                                           ,pr_dscritic => pr_dscritic                           -- OUT
                                           );
                --
              END IF;
              -- Próximo registro
              vr_index_reg := vr_tab_arquivo.next(vr_index_reg);
              --
            END LOOP;
            -- Joga os totais no trailler
            vr_dslintra := substr(vr_dslintra, 0, 52) || lpad((vr_qtregrem + vr_qtregrem + vr_qtindrem + vr_qtorirem), 5, '0') || substr(vr_dslintra, 058, 543);
            -- Grava o trailler
            pc_grava_trailler_remessa(pr_dstraill   => vr_dslintra   -- IN
                                     ,pr_input_file => vr_input_file -- IN OUT
                                     ,pr_dscritic   => pr_dscritic   -- OUT
                                     );
            --
            IF pr_dscritic IS NOT NULL THEN
              --
              RAISE vr_exc_erro;
              --
            END IF;
          -- Se não for de nenhum dos tipos anteriores, gera erro
          ELSE
            -- Incluído controle de Log
            pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_remessa --> Tipo de registro inexistente!');
            RAISE vr_exc_erro;
            --
          END IF;
          -- Próximo registro
          vr_index_arq := vr_tab_arquivo.next(vr_index_arq);
          --
        END LOOP;
        -- Fecha a remessa
        -- Escrever o registro no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file -- Handle do arquivo aberto
                                      ,pr_des_text  => '</remessa>'   -- Texto para escrita
                                      );
        -- Fechar Arquivo dados
        BEGIN
          --
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
          --
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
            pr_dscritic := 'Problema ao fechar o arquivo: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        -- Gravar o registro de log do arquivo
        COBR0011.pc_gera_log_iptb(pr_nmarquiv => vr_nmarqtxt
                                 ,pr_dtarquiv => vr_dtmvtolt
                                 ,pr_qtregarq => vr_tab_itemlog.count()
                                 ,pr_idfrmprc => 2 -- Automático
                                 ,pr_cdoperad => '1' 
                                 ,pr_idlogarq => vr_idlogarq
                                 ,pr_cdsituac => 1
                                 ,pr_dscritic => vr_dscrilog); -- Não parar o processo em caso de erro no log
        
        -- Se apresentar erro
        IF vr_dscrilog IS NOT NULL THEN 
          -- Incluído controle de Log, mas sem afetar o processamento
          pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_remessa --> Erro ao gravar log:' || vr_dscrilog);
        ELSE
          -- Se tem itens de log
          IF vr_tab_itemlog.count > 0 THEN
            -- Percorre todos os itens do log
            FOR ind IN vr_tab_itemlog.FIRST..vr_tab_itemlog.LAST LOOP
            
              -- Gravar o registro de log
              COBR0011.pc_gera_log_item_iptb(pr_idlogarq => vr_idlogarq
                                            ,pr_cdcooper => vr_tab_itemlog(ind).cdcooper
                                            ,pr_cdbandoc => vr_tab_itemlog(ind).cdbandoc
                                            ,pr_nrdctabb => vr_tab_itemlog(ind).nrdctabb
                                            ,pr_nrcnvcob => vr_tab_itemlog(ind).nrcnvcob
                                            ,pr_nrdconta => vr_tab_itemlog(ind).nrdconta
                                            ,pr_nrdocmto => vr_tab_itemlog(ind).nrdocmto
                                            ,pr_vltitulo => vr_tab_itemlog(ind).vltitulo
                                            ,pr_dscritic => vr_dscrilog); -- Não parar o processo em caso de erro no log
            
              -- Se apresentar erro
              IF vr_dscrilog IS NOT NULL THEN 
                -- Incluído de Log do item, mas sem afetar o processamento
                pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_remessa --> Erro ao gravar item do log:' || vr_dscrilog);
                
                -- Limpar registro de erro para a próxima iteração
                vr_dscrilog := NULL;
              END IF; -- Erro log item
            
            END LOOP; -- Loop itens
          END IF; -- Se existe itens
        END IF; -- Não ocorreu erro na inclusão do log
        --
      END IF;
      --
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se tem nome de arquivo
        IF vr_nmarqtxt IS NOT NULL THEN
          -- Gravar o registro de log do arquivo - Erro na geração do arquivo
          COBR0011.pc_gera_log_iptb(pr_nmarquiv => vr_nmarqtxt
                                   ,pr_dtarquiv => vr_dtmvtolt
                                   ,pr_qtregarq => 0
                                   ,pr_idfrmprc => 2 -- Automático
                                   ,pr_cdoperad => '1' 
                                   ,pr_dserrarq => 'Erro ao gerar arquivo remessa: '||pr_dscritic
                                   ,pr_cdsituac => 2
                                   ,pr_idlogarq => vr_idlogarq
                                   ,pr_dscritic => vr_dscrilog); -- Não parar o processo em caso de erro no log
          
          -- Se apresentar erro
          IF vr_dscrilog IS NOT NULL THEN 
            -- Incluído controle de Log, mas sem afetar o processamento
            pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_remessa --> Erro ao gravar log:' || vr_dscrilog);  
          END IF;
        END IF;
        
        -- Incluído controle de Log
        pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_remessa --> ' || pr_dscritic);
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        -- Retornar o erro
        pr_dscritic := SQLERRM;
        
        -- Se tem nome de arquivo
        IF vr_nmarqtxt IS NOT NULL THEN
          -- Gravar o registro de log do arquivo - Erro na geração do arquivo
          COBR0011.pc_gera_log_iptb(pr_nmarquiv => vr_nmarqtxt
                                   ,pr_dtarquiv => vr_dtmvtolt
                                   ,pr_qtregarq => 0
                                   ,pr_idfrmprc => 2 -- Automático
                                   ,pr_cdoperad => '1' 
                                   ,pr_dserrarq => 'Erro ao gerar arquivo remessa: '||pr_dscritic
                                   ,pr_cdsituac => 2
                                   ,pr_idlogarq => vr_idlogarq
                                   ,pr_dscritic => vr_dscrilog); -- Não parar o processo em caso de erro no log
          
          -- Se apresentar erro
          IF vr_dscrilog IS NOT NULL THEN 
            -- Incluído controle de Log, mas sem afetar o processamento
            pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_remessa --> Erro ao gravar log:' || vr_dscrilog);  
          END IF;
        END IF;
        
        -- Incluído controle de Log
        pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_remessa --> ' || pr_dscritic);
    END pc_gera_arquivo_remessa;
    
        -- Gera o header do arquivo de desistência
    PROCEDURE pc_gera_header_arq_desist(pr_cdaprese IN  NUMBER
                                       ,pr_nmaprese IN  VARCHAR2
                                       ,pr_dtmvtolt IN  VARCHAR2
                                       ,pr_qtdesist IN  NUMBER
                                       ,pr_qtregtp2 IN  NUMBER
                                       ,pr_nrseqreg IN  NUMBER
                                       ,pr_dsheader OUT VARCHAR2
                                       ,pr_dscritic OUT VARCHAR2
                                       ) IS
    BEGIN
      --
      pr_dsheader := '0'                                       -- 01 -- Tipo do registro -- Fixo 0 - Header do arquivo de desistência
                  || lpad(pr_cdaprese, 3, '0')                 -- 02 -- Código do apresentante -- REVISAR
                  || rpad(substr(pr_nmaprese, 0, 45), 45, ' ') -- 03 -- Nome do apresentante -- REVISAR
                  || pr_dtmvtolt                                -- 04 -- Data do movimento
                  || lpad(pr_qtdesist, 5, '0')                 -- 05 -- Quantidade de desistências -- REVISAR
                  || lpad(pr_qtregtp2, 5, '0')                 -- 06 -- Quantidade de registros tipo 2 no arquivo
                  || rpad(' ', 55, ' ')                        -- 07 -- Reservado
                  || lpad(pr_nrseqreg, 5, '0')                 -- 08 -- Seqüência do registro -- Constante 00001
                  ;
      --
    END pc_gera_header_arq_desist;
    
    -- Grava o header do arquivo de desistência no arquivo XML
    PROCEDURE pc_grava_header_arq_desist(pr_dsheader   IN     VARCHAR2
                                        ,pr_input_file IN OUT utl_file.file_type
                                        ,pr_dscritic   OUT    VARCHAR2
                                        ) IS
      --
      vr_dsdlinha VARCHAR2(4000);
      --
    BEGIN
      --
      vr_dsdlinha := '<hdb h01="' || substr(pr_dsheader, 000, 001)   || '"' ||
                         ' h02="' || substr(pr_dsheader, 002, 003)   || '"' ||
                         ' h03="' || substr(pr_dsheader, 005, 045)   || '"' ||
                         ' h04="' || to_char(vr_dtmvutil,'ddmmyyyy') || '"' ||
                         ' h05="' || substr(pr_dsheader, 058, 005)   || '"' ||
                         ' h06="' || substr(pr_dsheader, 063, 005)   || '"' ||
                         ' h07="' || substr(pr_dsheader, 068, 055)   || '"' ||
                         ' h08="' || substr(pr_dsheader, 123, 005)   || '" />';
      -- Escrever o registro no arquivo
      gene0001.pc_escr_linha_arquivo(pr_utlfileh  => pr_input_file -- Handle do arquivo aberto
                                    ,pr_des_text  => vr_dsdlinha   -- Texto para escrita
                                    );
      --
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        pr_dscritic := 'Erro ao gerar o header do arquivo de desistência: ' || SQLERRM;  
    END pc_grava_header_arq_desist;

    -- Gera o header do cartório no arquivo de desistência
    PROCEDURE pc_gera_header_cart_arq_desist(pr_cdcartor IN  NUMBER
                                            ,pr_qtdesist IN  NUMBER
                                            ,pr_cdmunici IN  NUMBER
                                            ,pr_nrseqreg IN  NUMBER
                                            ,pr_dsheader OUT VARCHAR2
                                            ,pr_dscritic OUT VARCHAR2
                                            ) IS
    BEGIN
      --
      pr_dsheader := '1'                                       -- 01 -- Tipo do registro -- Fixo 0 - Header do cartório no arquivo de desistência
                  || lpad(pr_cdcartor, 2, '0')                 -- 02 -- Código do cartório -- REVISAR
                  || lpad(pr_qtdesist, 5, '0')                 -- 03 -- Quantidade de desistências -- REVISAR
                  || lpad(pr_cdmunici, 7, '0')                 -- 04 -- Código do Município
                  || rpad(' ', 107, ' ')                       -- 05 -- Reservado
                  || lpad(pr_nrseqreg, 5, '0')                 -- 06 -- Seqüência do registro -- Constante 00001
                  ;
      --
    END pc_gera_header_cart_arq_desist;

     -- Grava o header do cartório no arquivo de desistência no XML
    PROCEDURE pc_grava_head_cart_arq_desist(pr_dsheader   IN     VARCHAR2
                                           ,pr_input_file IN OUT utl_file.file_type
                                           ,pr_dscritic   OUT    VARCHAR2
                                           ) IS
      --
      vr_dsdlinha VARCHAR2(4000);
      --
    BEGIN
      --
      vr_dsdlinha := '<hdc h01="' || substr(pr_dsheader, 000, 001) || '"' ||
                         ' h02="' || substr(pr_dsheader, 002, 002) || '"' ||
                         ' h03="' || substr(pr_dsheader, 004, 005) || '"' ||
                         ' h04="' || substr(pr_dsheader, 009, 007) || '"' ||
                         ' h05="' || substr(pr_dsheader, 016, 107) || '"' ||
                         ' h06="' || substr(pr_dsheader, 123, 005) || '" />';
      -- Escrever o registro no arquivo
      gene0001.pc_escr_linha_arquivo(pr_utlfileh  => pr_input_file -- Handle do arquivo aberto
                                    ,pr_des_text  => vr_dsdlinha   -- Texto para escrita
                                    );
      --
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        pr_dscritic := 'Erro ao gerar o header do cartório no arquivo de desistência: ' || SQLERRM;  
    END pc_grava_head_cart_arq_desist;
    
     -- Gera o registro da transação de desistência
    PROCEDURE pc_gera_reg_desist(pr_nrprotoc IN  VARCHAR2
                                ,pr_dtprotoc IN  VARCHAR2
                                ,pr_nrtitulo IN  VARCHAR2
                                ,pr_nmdevedo IN  VARCHAR2
                                ,pr_vltitulo IN  VARCHAR2
                                ,pr_cdagectl IN  VARCHAR2
                                ,pr_nrnosnum IN  VARCHAR2
                                ,pr_nrseqreg IN  VARCHAR2
                                ,pr_dsregist OUT VARCHAR2
                                ,pr_dscritic OUT VARCHAR2
                                ) IS
      --
    BEGIN
      --
      pr_dsregist := '2'                                                                            -- 01 -- Identificação do registro -- Fixo: 2 - Registro de transação
                  || rpad(pr_nrprotoc, 10, ' ')                                                     -- 02 -- Número do protocolo
                  || lpad(pr_dtprotoc, 8, '0')                                                      -- 03 -- Data de protocolagem
                  || lpad(pr_nrtitulo, 11, '0')                                                     -- 04 -- Número do título
                  || substr(pr_nmdevedo, 0, 45)                                                     -- 05 -- Nome do primeiro devedor
                  || lpad(pr_vltitulo, 14, '0')                                                     -- 06 -- Valor do título
                  || 'S'                                                                            -- 07 -- Solicitação de Sustação -- Fixo S
                  || rpad(pr_cdagectl, 12, ' ')                                                     -- 08 -- Agência/Conta
                  || rpad(pr_nrnosnum, 12, ' ')                                                     -- 09 -- Carteira/N.Número
                  || rpad(' ', 2, ' ')                                                              -- 10 -- Reservado
                  || rpad(' ', 6, ' ')                                                              -- 11 -- Número de controle de recebimento (não utilizar)
                  || lpad(pr_nrseqreg, 5, '0')                                                      -- 12 -- Seqüência do registro
                  ;
      --
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        pr_dscritic := 'Erro ao gerar o registro de transação da desistência: ' || SQLERRM;
    END pc_gera_reg_desist; 
    
     -- Grava o registro da transação de desistência
    PROCEDURE pc_grava_reg_desist(pr_dsregist   IN     VARCHAR2
                                 ,pr_input_file IN OUT utl_file.file_type
                                 ,pr_dscritic   OUT    VARCHAR2
                                 ) IS
      --
      vr_dsdlinha VARCHAR2(4000);
      --
    BEGIN
      --
      vr_dsdlinha := '<tr t01="' || substr(pr_dsregist, 000, 001) || '"' ||
                        ' t02="' || substr(pr_dsregist, 002, 010) || '"' ||
                        ' t03="' || substr(pr_dsregist, 012, 008) || '"' ||
                        ' t04="' || substr(pr_dsregist, 020, 011) || '"' ||
                        ' t05="' || substr(pr_dsregist, 031, 045) || '"' ||
                        ' t06="' || substr(pr_dsregist, 076, 014) || '"' ||
                        ' t07="' || substr(pr_dsregist, 090, 001) || '"' ||
                        ' t08="' || substr(pr_dsregist, 091, 012) || '"' ||
                        ' t09="' || substr(pr_dsregist, 103, 012) || '"' ||
                        ' t10="' || substr(pr_dsregist, 115, 002) || '"' ||
                        ' t11="' || substr(pr_dsregist, 117, 006) || '"' ||
                        ' t12="' || substr(pr_dsregist, 123, 005) || '" />';
      -- Escrever o registro no arquivo
      gene0001.pc_escr_linha_arquivo(pr_utlfileh  => pr_input_file -- Handle do arquivo aberto
                                    ,pr_des_text  => vr_dsdlinha   -- Texto para escrita
                                    );
      --
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        pr_dscritic := 'Erro ao gravar o registro de transação da desistência: ' || SQLERRM;  
    END pc_grava_reg_desist;

      -- Gera o trailler do cartório no arquivo de desistência
    PROCEDURE pc_gera_trail_cart_arq_desist(pr_cdcartor IN  NUMBER
                                           ,pr_qtdesist IN  NUMBER
                                           ,pr_cdmunici IN  NUMBER
                                           ,pr_nrseqreg IN  NUMBER
                                           ,pr_dsheader OUT VARCHAR2
                                           ,pr_dscritic OUT VARCHAR2
                                           ) IS
    BEGIN
      --
      pr_dsheader := '8'                                       -- 01 -- Tipo do registro -- Fixo 8 - Trailler do cartório no arquivo de desistência
                  || lpad(pr_cdcartor, 2, '0')                 -- 02 -- Código do cartório -- REVISAR
                  || lpad(pr_qtdesist, 5, '0')                 -- 03 -- Soma do total de desistências informada no header do cartório e registros tipo 2 do mesmo 
                  || rpad(' ', 114, ' ')                       -- 04 -- Reservado
                  || lpad(pr_nrseqreg, 5, '0')                 -- 05 -- Seqüência do registro
                  ;
      --
    END pc_gera_trail_cart_arq_desist;
    
     -- Grava o trailler do cartório no arquivo de desistência no XML
    PROCEDURE pc_grava_trail_cart_arq_desist(pr_dsheader   IN     VARCHAR2
                                            ,pr_input_file IN OUT utl_file.file_type
                                            ,pr_dscritic   OUT    VARCHAR2
                                            ) IS
      --
      vr_dsdlinha VARCHAR2(4000);
      --
    BEGIN
      --
      vr_dsdlinha := '<tlc t01="' || substr(pr_dsheader, 000, 001) || '"' ||
                         ' t02="' || substr(pr_dsheader, 002, 002) || '"' ||
                         ' t03="' || substr(pr_dsheader, 004, 008) || '"' ||
                         ' t04="' || substr(pr_dsheader, 009, 114) || '"' ||
                         ' t05="' || substr(pr_dsheader, 123, 005) || '" />';
      -- Escrever o registro no arquivo
      gene0001.pc_escr_linha_arquivo(pr_utlfileh  => pr_input_file -- Handle do arquivo aberto
                                    ,pr_des_text  => vr_dsdlinha   -- Texto para escrita
                                    );
      --
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        pr_dscritic := 'Erro ao gerar o trailler do cartório no arquivo de desistência: ' || SQLERRM;  
    END pc_grava_trail_cart_arq_desist;

    -- Gera o trailler do arquivo de desistência
    PROCEDURE pc_gera_trail_arq_desist(pr_cdaprese IN  NUMBER
                                      ,pr_nmaprese IN  VARCHAR2
                                      ,pr_dtmvtolt IN  VARCHAR2
                                      ,pr_qtdesist IN  NUMBER
                                      ,pr_vltitulo IN  NUMBER
                                      ,pr_nrseqreg IN  NUMBER
                                      ,pr_dstraill OUT VARCHAR2
                                      ,pr_dscritic OUT VARCHAR2
                                      ) IS
    BEGIN
      --
      pr_dstraill := '9'                                                                            -- 01 -- Tipo do registro -- Fixo 9 - Trailler do arquivo de desistência
                  || lpad(pr_cdaprese, 3, '0')                                                      -- 02 -- Código do apresentante -- REVISAR
                  || rpad(substr(pr_nmaprese, 0, 45), 45, ' ')                                      -- 03 -- Nome do apresentante -- REVISAR
                  || pr_dtmvtolt                                                                    -- 04 -- Data do movimento
                  || lpad(pr_qtdesist, 5, '0')                                                      -- 05 -- Soma do total de desistências informada no header do arquivo e registros tipo 2 do mesmo
                  || lpad(pr_vltitulo, 14, '0')                                                     -- 06 -- Somatória do campo Valor do título
                  || rpad(' ', 46, ' ')                                                             -- 07 -- Reservado
                  || lpad(pr_nrseqreg, 5, '0')                                                      -- 08 -- Seqüência do registro
                  ;
      --
    END pc_gera_trail_arq_desist;
    
    
    -- Grava o trailler do arquivo de desistência no XML
    PROCEDURE pc_grava_trail_arq_desist(pr_dstraill   IN     VARCHAR2
                                       ,pr_input_file IN OUT utl_file.file_type
                                       ,pr_dscritic   OUT    VARCHAR2
                                       ) IS
      --
      vr_dsdlinha VARCHAR2(4000);
      --
    BEGIN
      --
      vr_dsdlinha := '<tlb t01="' || substr(pr_dstraill, 000, 001)   || '"' ||
                         ' t02="' || substr(pr_dstraill, 002, 003)   || '"' ||
                         ' t03="' || substr(pr_dstraill, 005, 045)   || '"' ||
                         ' t04="' || to_char(vr_dtmvutil,'ddmmyyyy') || '"' ||
                         ' t05="' || substr(pr_dstraill, 058, 005)   || '"' ||
                         ' t06="' || substr(pr_dstraill, 063, 014)   || '"' ||
                         ' t07="' || substr(pr_dstraill, 077, 046)   || '"' ||
                         ' t08="' || substr(pr_dstraill, 123, 005)   || '" />';
      -- Escrever o registro no arquivo
      gene0001.pc_escr_linha_arquivo(pr_utlfileh  => pr_input_file -- Handle do arquivo aberto
                                    ,pr_des_text  => vr_dsdlinha   -- Texto para escrita
                                    );
      --
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        pr_dscritic := 'Erro ao gerar o trailler do cartório no arquivo de desistência: ' || SQLERRM;  
    END pc_grava_trail_arq_desist;
    
     -- Gera desistências a serem enviadas
    PROCEDURE pc_gera_desistencia(pr_dscritic OUT VARCHAR2
                                 ) IS
      --
      CURSOR cr_craprem (pr_dtmvtolt IN date) IS
        SELECT DISTINCT 
               lpad(crapcob.cdbandoc, 3, '0') cdbandoc                                                      -- Campo 02 - Header Arquivo
              ,rpad(crapban.nmresbcc, 40, ' ') nmresbcc                                                     -- Campo 03 - Header Arquivo
              ,to_char(crapdat.dtmvtopr, 'DDMMYYYY') dtmvtolt                                               -- Campo 04 - Header Arquivo
              ,lpad(tbcobran_confirmacao_ieptb.cdcartorio, 2, '0') cdcartor                                 -- Campo 02 - Header Cartório
              ,lpad(tbcobran_confirmacao_ieptb.cdcomarc, 7, '0') cdcomarc                                   -- Campo 04 - Header Cartório
              ,lpad(tbcobran_confirmacao_ieptb.nrprotoc_cartorio, 10, '0') nrprotoc                         -- Campo 02 - Transação
              ,to_char(tbcobran_confirmacao_ieptb.dtprotocolo, 'DDMMYYYY') dtprotoc                         -- Campo 03 - Transação
              ,lpad(crapcob.nrdocmto, 11, '0') nrdocmto                                                     -- Campo 04 - Transação
              ,rpad(gene0007.fn_caract_especial(crapsab.nmdsacad), 45, ' ') nmdsacad                        -- Campo 05 - Transação
              --,lpad(replace(trim(to_char(crapcob.vltitulo, '999999999990D90')), ',', ''), 14, '0') vltitulo -- Campo 06 - Transação
              ,lpad(TRUNC(crapcob.vltitulo * 100), 14, '0') vltitulo                                        -- Campo 06 - Transação
              ,lpad(crapcop.cdagectl, 4, '0') || lpad(crapcob.nrdconta, 8, '0') nrdconta                    -- Campo 08 - Transação
              ,lpad(crapcob.nrnosnum, 12, '0') nrnosnum                                                     -- Campo 09 - Transação
              ,crapcob.rowid
              ,crapcob.cdcooper
              ,crapdat.dtmvtolt dtmvtolt_dat
              -- Campos log
              ,crapcob.cdcooper   cdcoplog
              ,crapcob.cdbandoc   cdbanlog
              ,crapcob.nrdctabb   nrcbblog
              ,crapcob.nrcnvcob   nrcnvlog
              ,crapcob.nrdconta   nrctalog
              ,crapcob.nrdocmto   nrdoclog
              ,crapcob.vltitulo   vltitlog
          FROM craprem
              ,crapcob
              ,crapdat
              ,crapban
              ,crapcop
              ,crapsab
              ,tbcobran_confirmacao_ieptb
              ,crapcco
              ,crapcre
         WHERE crapcco.cdcooper > 0
           AND crapcco.cddbanco = 85
           AND crapcre.cdcooper = crapcco.cdcooper
           AND crapcre.nrcnvcob = crapcco.nrconven
           AND crapcre.dtmvtolt = pr_dtmvtolt
           AND crapcre.intipmvt = 1
           AND craprem.cdcooper = crapcre.cdcooper
           AND craprem.nrcnvcob = crapcre.nrcnvcob
           AND craprem.nrremret = crapcre.nrremret            
           AND craprem.cdcooper                    = crapcob.cdcooper
           AND craprem.nrcnvcob                    = crapcob.nrcnvcob
           AND craprem.nrdconta                    = crapcob.nrdconta
           AND craprem.nrdocmto                    = crapcob.nrdocmto
           AND crapdat.cdcooper                    = crapcob.cdcooper
           AND crapban.cdbccxlt                    = crapcob.cdbandoc
           AND crapcop.cdcooper                    = crapcob.cdcooper
           AND crapsab.cdcooper                    = crapcob.cdcooper
           AND crapsab.nrdconta                    = crapcob.nrdconta
           AND crapsab.nrinssac                    = crapcob.nrinssac
           AND crapcco.cddbanco                    = crapcob.cdbandoc
           AND crapcco.nrdctabb                    = crapcob.nrdctabb
           AND tbcobran_confirmacao_ieptb.cdcooper = craprem.cdcooper
           AND tbcobran_confirmacao_ieptb.nrdconta = craprem.nrdconta
           AND tbcobran_confirmacao_ieptb.nrcnvcob = craprem.nrcnvcob
           AND tbcobran_confirmacao_ieptb.nrdocmto = craprem.nrdocmto
           AND tbcobran_confirmacao_ieptb.tpocorre not in ('5','6') --PRB0041759
           AND crapcob.cdbandoc                    = 85 -- REVISAR
           AND crapcob.insrvprt                    = 1  -- REVISAR
           AND craprem.cdocorre                    IN(10, 11)
         ORDER BY 5, 4;
      --
      rw_craprem cr_craprem%ROWTYPE;
      --
      vr_arq_xml CLOB;
      --
      vr_cdcartor tbcobran_confirmacao_ieptb.cdcartorio%TYPE;
      vr_cdcomarc tbcobran_confirmacao_ieptb.cdcomarc%TYPE;
      vr_qtregist NUMBER;
      vr_qtnumarq NUMBER;
      vr_dsdlinha VARCHAR2(600);
      vr_qtregtra NUMBER;
      vr_vlsomseg NUMBER;
      vr_idgercab BOOLEAN;
      --
      vr_exc_erro EXCEPTION;
      vr_des_erro VARCHAR2(100);
      vr_dscritic VARCHAR2(1000);
      --
    BEGIN
      -- Incluido controle de Log inicio programa
      pc_controla_log_batch(1, 'Início pc_crps729.pc_gera_desistencia');
      -- Inicializa variáveis
      vr_qtregist  := 1;
      vr_qtnumarq  := 0;
      vr_vlsomseg  := 0;
      vr_idgercab  := TRUE;
      vr_index_arq := 0;
      --
      vr_tab_arquivo.delete;
      vr_tab_itemlog.delete;

      --
      OPEN cr_craprem(pr_dtmvtolt => vr_dtmvprocessar);
      --
      LOOP
        --
        FETCH cr_craprem INTO rw_craprem;
        EXIT WHEN cr_craprem%NOTFOUND;
        --
        IF vr_qtregist = 1 THEN
          -- Inicializa o arquivo de desistências
          

          pc_gera_header_arq_desist(pr_cdaprese => rw_craprem.cdbandoc -- IN
                                   ,pr_nmaprese => rw_craprem.nmresbcc -- IN
                                   ,pr_dtmvtolt => rw_craprem.dtmvtolt -- IN
                                   ,pr_qtdesist => 0                   -- IN
                                   ,pr_qtregtp2 => 0                   -- IN
                                   ,pr_nrseqreg => vr_qtregist         -- IN
                                   ,pr_dsheader => vr_dsdlinha         -- OUT
                                   ,pr_dscritic => pr_dscritic         -- OUT
                                   );
          --
          IF pr_dscritic IS NOT NULL THEN
            --
            RAISE vr_exc_erro;
            --
          ELSE
            --
            pc_insere_linha(pr_linha => vr_dsdlinha      -- IN
                           ,pr_cdcooper => rw_craprem.cdcooper
                           ,pr_rowid => rw_craprem.rowid -- IN
                           );
            --
          END IF;
          --
          vr_qtregist := vr_qtregist + 1;
          --
        END IF;
        -- Verifica se precisa inicializar um novo cartório
        IF (nvl(vr_cdcartor, 0) <> to_number(rw_craprem.cdcartor) OR (nvl(vr_cdcomarc, 0) <> to_number(rw_craprem.cdcomarc))) THEN
          -- Verifica se finaliza a remessa anterior
          IF vr_qtnumarq > 0 THEN
            --
            vr_dsdlinha := NULL;
            --
            pc_gera_trail_cart_arq_desist(pr_cdcartor => vr_cdcartor -- IN
                                         ,pr_qtdesist => 0           -- IN
                                         ,pr_cdmunici => vr_cdcomarc -- IN
                                         ,pr_nrseqreg => vr_qtregist -- IN
                                         ,pr_dsheader => vr_dsdlinha -- OUT
                                         ,pr_dscritic => pr_dscritic -- OUT
                                         );
            --
            IF pr_dscritic IS NOT NULL THEN
              --
              RAISE vr_exc_erro;
              --
            ELSE
              --
              pc_insere_linha(pr_linha => vr_dsdlinha      -- IN
                             ,pr_cdcooper => rw_craprem.cdcooper
                             ,pr_rowid => rw_craprem.rowid -- IN
                             );
              --
            END IF;
            --
            vr_qtregist := vr_qtregist + 1;
            --
          END IF;
          --
          vr_qtnumarq := vr_qtnumarq + 1;
          --vr_vlsomseg := 0;
          vr_idgercab := TRUE;
          vr_cdcartor := rw_craprem.cdcartor;
          vr_cdcomarc := rw_craprem.cdcomarc;
          --
        END IF;
        -- Se for o primeiro registro, gerar o cabeçalho
        IF vr_idgercab THEN
          --
          vr_dsdlinha := NULL;
          --
          pc_gera_header_cart_arq_desist(pr_cdcartor => rw_craprem.cdcartor -- IN
                                        ,pr_qtdesist => 0                   -- IN
                                        ,pr_cdmunici => rw_craprem.cdcomarc -- IN
                                        ,pr_nrseqreg => vr_qtregist         -- IN
                                        ,pr_dsheader => vr_dsdlinha         -- OUT
                                        ,pr_dscritic => pr_dscritic         -- OUT
                                        );
          --
          IF pr_dscritic IS NOT NULL THEN
            --
            RAISE vr_exc_erro;
            --
          ELSE
            --
            pc_insere_linha(pr_linha => vr_dsdlinha      -- IN
                           ,pr_cdcooper => rw_craprem.cdcooper
                           ,pr_rowid => rw_craprem.rowid -- IN
                           );
            --
          END IF;
          --
          vr_qtregist := vr_qtregist + 1;
          vr_idgercab := FALSE;
          --
        END IF;
        --
        vr_dsdlinha := null;
        --
        pc_gera_reg_desist(pr_nrprotoc => rw_craprem.nrprotoc -- IN
                          ,pr_dtprotoc => rw_craprem.dtprotoc -- IN
                          ,pr_nrtitulo => rw_craprem.nrdocmto -- IN
                          ,pr_nmdevedo => rw_craprem.nmdsacad -- IN
                          ,pr_vltitulo => rw_craprem.vltitulo -- IN
                          ,pr_cdagectl => rw_craprem.nrdconta -- IN
                          ,pr_nrnosnum => rw_craprem.nrnosnum -- IN
                          ,pr_nrseqreg => vr_qtregist         -- IN
                          ,pr_dsregist => vr_dsdlinha         -- OUT
                          ,pr_dscritic => pr_dscritic         -- OUT
                          );
        --
        IF pr_dscritic IS NOT NULL THEN
          --
          RAISE vr_exc_erro;
          --
        ELSE
          --
          pc_insere_linha(pr_linha => vr_dsdlinha      -- IN
                         ,pr_cdcooper => rw_craprem.cdcooper
                         ,pr_rowid => rw_craprem.rowid -- IN
                         );
          --
          -- Adicionar item no log
          vr_tab_itemlog(vr_tab_itemlog.count()+1).cdcooper := rw_craprem.cdcoplog;
          vr_tab_itemlog(vr_tab_itemlog.count()  ).cdbandoc := rw_craprem.cdbanlog;
          vr_tab_itemlog(vr_tab_itemlog.count()  ).nrdctabb := rw_craprem.nrcbblog;
          vr_tab_itemlog(vr_tab_itemlog.count()  ).nrcnvcob := rw_craprem.nrcnvlog;
          vr_tab_itemlog(vr_tab_itemlog.count()  ).nrdconta := rw_craprem.nrctalog;
          vr_tab_itemlog(vr_tab_itemlog.count()  ).nrdocmto := rw_craprem.nrdoclog;
          vr_tab_itemlog(vr_tab_itemlog.count()  ).vltitulo := rw_craprem.vltitlog;
        END IF;
        --
        vr_qtregist := vr_qtregist + 1;
        --
        vr_vlsomseg := vr_vlsomseg + rw_craprem.vltitulo;
        --
      END LOOP;
      -- Verifica se finaliza a remessa anterior
      IF vr_qtregist > 1 THEN
        --
        vr_dsdlinha := NULL;
        --
        pc_gera_trail_cart_arq_desist(pr_cdcartor => rw_craprem.cdcartor -- IN
                                     ,pr_qtdesist => 0                   -- IN
                                     ,pr_cdmunici => rw_craprem.cdcomarc -- IN
                                     ,pr_nrseqreg => vr_qtregist         -- IN
                                     ,pr_dsheader => vr_dsdlinha         -- OUT
                                     ,pr_dscritic => pr_dscritic         -- OUT
                                     );
        --
        IF pr_dscritic IS NOT NULL THEN
          --
          RAISE vr_exc_erro;
          --
        ELSE
          --
          pc_insere_linha(pr_linha => vr_dsdlinha      -- IN
                         ,pr_cdcooper => rw_craprem.cdcooper
                         ,pr_rowid => rw_craprem.rowid -- IN
                         );

          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_craprem.rowid
                                      , pr_cdoperad => '1'
                                      , pr_dtmvtolt => rw_craprem.dtmvtolt_dat
                                      , pr_dsmensag => 'Solicitacao de cancelamento enviada ao cartorio'
                                      , pr_des_erro => vr_des_erro
                                      , pr_dscritic => vr_dscritic);                               
                                      
          -- LOG de processo
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_craprem.rowid --ROWID da Cobranca
                                       ,pr_cdoperad => '1'   --Operador
                                       ,pr_dtmvtolt => rw_craprem.dtmvtolt_dat   --Data movimento
                                       ,pr_dsmensag => 'Aguardando o cancelamento do cartorio' --Descricao Mensagem
                                       ,pr_des_erro => vr_des_erro   --Indicador erro
                                       ,pr_dscritic => vr_dscritic); --Descricao erro
                                      
          --
        END IF;
        --
        vr_qtregist := vr_qtregist + 1;
        --
      END IF;
      --
      CLOSE cr_craprem;
      -- Verifica se finaliza o arquivo
      IF vr_qtregist > 1 THEN
        --
        vr_dsdlinha := NULL;
        --

        pc_gera_trail_arq_desist(pr_cdaprese => rw_craprem.cdbandoc -- IN
                                ,pr_nmaprese => rw_craprem.nmresbcc -- IN
                                ,pr_dtmvtolt => rw_craprem.dtmvtolt -- IN
                                ,pr_qtdesist => 0                   -- IN
                                ,pr_vltitulo => vr_vlsomseg         -- IN
                                ,pr_nrseqreg => vr_qtregist         -- IN
                                ,pr_dstraill => vr_dsdlinha         -- OUT
                                ,pr_dscritic => pr_dscritic         -- OUT
                                );
        --
        IF pr_dscritic IS NOT NULL THEN
          --
          RAISE vr_exc_erro;
          --
        ELSE
          --
          pc_insere_linha(pr_linha => vr_dsdlinha      -- IN
                         ,pr_cdcooper => rw_craprem.cdcooper
                         ,pr_rowid => rw_craprem.rowid -- IN
                         );
          --
        END IF;
        --
      END IF;
      -- Escrever o log no arquivo
      pc_controla_log_batch(1, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_desistencia --> Finalizado o processamento das desistências.'); -- Texto para escrita
      --
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Incluído controle de Log
        --pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_desistencia --> ' || rw_craprem.cdcooper || '/' || rw_craprem.nrdconta || '/' || rw_craprem.nrcnvcob || '/' || rw_craprem.nrdocmto || ' não processado devido ao ERRO: ' || pr_dscritic);
        
        NULL;
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        -- Incluído controle de Log
        --pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_desistencia --> ' || rw_craprem.cdcooper || '/' || rw_craprem.nrdconta || '/' || rw_craprem.nrcnvcob || '/' || rw_craprem.nrdocmto || ' não processado devido ao ERRO: ' || SQLERRM);
        pr_dscritic := SQLERRM;
    END pc_gera_desistencia;
    
     -- Gera o arquivo de desistência
    PROCEDURE pc_gera_arquivo_desistencia(pr_dscritic OUT VARCHAR2
                                         ) IS
      --
      vr_dtmvtolt   crapdat.dtmvtolt%TYPE;
      vr_input_file utl_file.file_type;
      vr_nmarqtxt   VARCHAR2(13);
      vr_nmdirtxt   VARCHAR2(400);
      --
      vr_dslinhea   VARCHAR2(600);
      vr_dslintra   VARCHAR2(600);
      vr_qtregdes   NUMBER;
      vr_qttotdes   NUMBER;
      vr_qtorirem   NUMBER;
      vr_idlogarq   tbcobran_log_arquivo_ieptb.idlog_arquivo%TYPE;
      vr_dscrilog   VARCHAR2(1000);
      --
      vr_index_arq_ant NUMBER;
      vr_index_reg     NUMBER;
      --
      vr_exc_erro EXCEPTION;
      --
    BEGIN
      -- Incluido controle de Log inicio programa
      pc_controla_log_batch(1, 'Início crps729.pc_gera_arquivo_desistencia');
      --
      IF vr_tab_arquivo.count > 0 THEN
        --
        vr_dtmvtolt := TRUNC(SYSDATE);

        -- Busca o nome do arquivo
        vr_nmarqtxt := cobr0011.fn_gera_nome_arq_desistencia(pr_cdbandoc => '85'        -- IN
                                                            ,pr_dtmvtolt => vr_dtmvutil -- IN
                                                            );                                                          
                                                            
        -- Diretório onde deverá gerar o arquivo de desistência
        --vr_nmdirtxt := '/micros/cecred/ieptb/remessa/';
        vr_nmdirtxt := gene0001.fn_param_sistema (pr_nmsistem => 'CRED'              -- IN
                                                 ,pr_cdcooper => 3                   -- IN
                                                 ,pr_cdacesso => 'DIR_IEPTB_REMESSA' -- IN
                                                 );
        -- Abre o arquivo de dados em modo de gravação
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirtxt   -- IN -- Diretório do arquivo
                                ,pr_nmarquiv => vr_nmarqtxt   -- IN -- Nome do arquivo
                                ,pr_tipabert => 'W'           -- IN -- Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_input_file -- IN -- Handle do arquivo aberto
                                ,pr_des_erro => pr_dscritic   -- IN -- Erro
                                );
        --
        IF pr_dscritic IS NOT NULL THEN
          --
          RAISE vr_exc_erro;
          --
        END IF;
        -- Escrever o registro no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file            -- Handle do arquivo aberto
                                      ,pr_des_text  => '<?xml version="1.0"?> ' -- Texto para escrita
                                      );
        -- Abre a desistência
        -- Escrever o registro no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file -- Handle do arquivo aberto
                                      ,pr_des_text  => '<sustacao>'   -- Texto para escrita
                                      );
        -- Busca o primeiro registro
        vr_index_arq := vr_tab_arquivo.first;
        -- Percorre todos os registros para gerar os totalizadores
        WHILE vr_index_arq IS NOT NULL LOOP
          -- Verifica se o registro é do tipo header do arquivo
          IF substr(vr_tab_arquivo(vr_index_arq).ds_registro, 0, 1) = 0 THEN
            --
            vr_dslinhea  := vr_tab_arquivo(vr_index_arq).ds_registro;
            vr_qttotdes  := 0;
            vr_index_reg := vr_index_arq;
            --
            WHILE vr_index_reg IS NOT NULL LOOP
              --
              IF substr(vr_tab_arquivo(vr_index_reg).ds_registro, 0, 1) = 2 THEN
                --
                vr_qttotdes := vr_qttotdes + 1;
                --
              END IF;
              -- Próximo registro
              vr_index_reg := vr_tab_arquivo.next(vr_index_reg);
              --
            END LOOP;
            -- Joga os totais no header do arquivo
            vr_dslinhea := substr(vr_dslinhea, 0, 57) || lpad((vr_qttotdes), 5, '0') || lpad((vr_qttotdes), 5, '0') || substr(vr_dslinhea, 68, 60);
            -- Grava o header do arquivo
            pc_grava_header_arq_desist(pr_dsheader   => vr_dslinhea   -- IN
                                      ,pr_input_file => vr_input_file -- IN OUT
                                      ,pr_dscritic   => pr_dscritic   -- OUT
                                      );
            --
            IF pr_dscritic IS NOT NULL THEN
              --
              RAISE vr_exc_erro;
              --
            END IF;
            --
            vr_dslinhea := NULL;
          -- Verifica se o registro é do tipo header do cartório
          ELSIF substr(vr_tab_arquivo(vr_index_arq).ds_registro, 0, 1) = 1 THEN
            --
            vr_dslinhea      := vr_tab_arquivo(vr_index_arq).ds_registro;
            vr_index_arq_ant := NULL;
            vr_qtregdes      := 0;
            --
          -- Verifica se o registro é do tipo transação
          ELSIF substr(vr_tab_arquivo(vr_index_arq).ds_registro, 0, 1) = 2 THEN
            -- Guarda a posição do primeiro registro de transação da desistência
            IF vr_index_arq_ant IS NULL THEN
              --
              vr_index_arq_ant := vr_index_arq;
              --
            END IF;
            --
            vr_qtregdes := vr_qtregdes + 1;
            --
          -- Verifica se o registro é do tipo trailler do cartório
          ELSIF substr(vr_tab_arquivo(vr_index_arq).ds_registro, 0, 1) = 8 THEN
            --
            vr_dslintra := vr_tab_arquivo(vr_index_arq).ds_registro;
            -- Joga os totais no header do cartório
            vr_dslinhea := substr(vr_dslinhea, 0, 3) || lpad(vr_qtregdes, 5, '0') || substr(vr_dslinhea, 9, 119);
            -- Grava o header do cartório
            pc_grava_head_cart_arq_desist(pr_dsheader   => vr_dslinhea   -- IN
                                         ,pr_input_file => vr_input_file -- IN OUT
                                         ,pr_dscritic   => pr_dscritic   -- OUT
                                         );
            --
            IF pr_dscritic IS NOT NULL THEN
              --
              RAISE vr_exc_erro;
              --
            END IF;
            --
            vr_index_reg := vr_index_arq_ant;
            -- Grava as transações
            WHILE vr_index_reg IS NOT NULL LOOP
              -- Finaliza
              IF substr(vr_tab_arquivo(vr_index_reg).ds_registro, 0, 1) = 8 THEN
                --
                vr_index_reg := NULL;
                EXIT;
                --
              ELSE
                -- Gravar a transação
                pc_grava_reg_desist(pr_dsregist   => vr_tab_arquivo(vr_index_reg).ds_registro -- IN
                                   ,pr_input_file => vr_input_file                            -- IN OUT
                                   ,pr_dscritic   => pr_dscritic                              -- OUT
                                   );
                --
                IF pr_dscritic IS NOT NULL THEN
                  --
                  RAISE vr_exc_erro;
                  --
                END IF;
                --
              END IF;
              -- Próximo registro
              vr_index_reg := vr_tab_arquivo.next(vr_index_reg);
              --
            END LOOP;
            -- Joga os totais no trailler do cartório
            vr_dslintra := substr(vr_dslintra, 0, 3) || lpad((vr_qtregdes + vr_qtregdes), 5, '0') || substr(vr_dslintra, 009, 119);
            -- Grava o trailler do cartório
            pc_grava_trail_cart_arq_desist(pr_dsheader   => vr_dslintra   -- IN
                                          ,pr_input_file => vr_input_file -- IN OUT
                                          ,pr_dscritic   => pr_dscritic   -- OUT
                                          );
            --
            IF pr_dscritic IS NOT NULL THEN
              --
              RAISE vr_exc_erro;
              --
            END IF;
          -- Verifica se o registro é do tipo trailler do arquivo
          ELSIF substr(vr_tab_arquivo(vr_index_arq).ds_registro, 0, 1) = 9 THEN
            --
            vr_dslintra := vr_tab_arquivo(vr_index_arq).ds_registro;
            -- Joga os totais no trailler do arquivo
            vr_dslintra := substr(vr_dslintra, 0, 57) || lpad((vr_qttotdes + vr_qttotdes), 5, '0') || substr(vr_dslintra, 063, 78);
            -- Grava o trailler do arquivo
            pc_grava_trail_arq_desist(pr_dstraill   => vr_dslintra   -- IN
                                     ,pr_input_file => vr_input_file -- IN OUT
                                     ,pr_dscritic   => pr_dscritic   -- OUT
                                     );
            --
            IF pr_dscritic IS NOT NULL THEN
              --
              RAISE vr_exc_erro;
              --
            END IF;
          -- Se não for de nenhum dos tipos anteriores, gera erro
          ELSE
            -- Incluído controle de Log
            pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_desistencia --> Tipo de registro inexistente!');
            RAISE vr_exc_erro;
            --
          END IF;
          -- Próximo registro
          vr_index_arq := vr_tab_arquivo.next(vr_index_arq);
          --
        END LOOP;
        -- Fecha a remessa
        -- Escrever o registro no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file -- Handle do arquivo aberto
                                      ,pr_des_text  => '</sustacao>'  -- Texto para escrita
                                      );
        -- Fechar Arquivo dados
        BEGIN
          --
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
          --
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
            pr_dscritic := 'Problema ao fechar o arquivo: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        --
        
        -- Gravar o registro de log do arquivo
        COBR0011.pc_gera_log_iptb(pr_nmarquiv => vr_nmarqtxt
                                 ,pr_dtarquiv => vr_dtmvtolt
                                 ,pr_qtregarq => vr_tab_itemlog.count()
                                 ,pr_idfrmprc => 2 -- Automático
                                 ,pr_cdoperad => '1' 
                                 ,pr_idlogarq => vr_idlogarq
                                 ,pr_cdsituac => 1
                                 ,pr_dscritic => vr_dscrilog); -- Não parar o processo em caso de erro no log
        
        -- Se apresentar erro
        IF vr_dscrilog IS NOT NULL THEN 
          -- Incluído controle de Log, mas sem afetar o processamento
          pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_desistencia --> Erro ao gravar log:' || vr_dscrilog);
        ELSE
          -- Se tem itens de log
          IF vr_tab_itemlog.count > 0 THEN
            -- Percorre todos os itens do log
            FOR ind IN vr_tab_itemlog.FIRST..vr_tab_itemlog.LAST LOOP
            
              -- Gravar o registro de log
              COBR0011.pc_gera_log_item_iptb(pr_idlogarq => vr_idlogarq
                                            ,pr_cdcooper => vr_tab_itemlog(ind).cdcooper
                                            ,pr_cdbandoc => vr_tab_itemlog(ind).cdbandoc
                                            ,pr_nrdctabb => vr_tab_itemlog(ind).nrdctabb
                                            ,pr_nrcnvcob => vr_tab_itemlog(ind).nrcnvcob
                                            ,pr_nrdconta => vr_tab_itemlog(ind).nrdconta
                                            ,pr_nrdocmto => vr_tab_itemlog(ind).nrdocmto
                                            ,pr_vltitulo => vr_tab_itemlog(ind).vltitulo
                                            ,pr_dscritic => vr_dscrilog); -- Não parar o processo em caso de erro no log
            
              -- Se apresentar erro
              IF vr_dscrilog IS NOT NULL THEN 
                -- Incluído de Log do item, mas sem afetar o processamento
                pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_desistencia --> Erro ao gravar item do log:' || vr_dscrilog);
                
                -- Limpar registro de erro para a próxima iteração
                vr_dscrilog := NULL;
              END IF; -- Erro log item
            
            END LOOP; -- Loop itens
          END IF; -- Se existe itens
        END IF; -- Não ocorreu erro na inclusão do log
      END IF;
      --
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se tem nome de arquivo
        IF vr_nmarqtxt IS NOT NULL THEN
          -- Gravar o registro de log do arquivo - Erro na geração do arquivo
          COBR0011.pc_gera_log_iptb(pr_nmarquiv => vr_nmarqtxt
                                   ,pr_dtarquiv => vr_dtmvtolt
                                   ,pr_qtregarq => 0
                                   ,pr_idfrmprc => 2 -- Automático
                                   ,pr_cdoperad => '1' 
                                   ,pr_dserrarq => 'Erro ao gerar arquivo desistencia: '||pr_dscritic
                                   ,pr_cdsituac => 2
                                   ,pr_idlogarq => vr_idlogarq
                                   ,pr_dscritic => vr_dscrilog); -- Não parar o processo em caso de erro no log
          
          -- Se apresentar erro
          IF vr_dscrilog IS NOT NULL THEN 
            -- Incluído controle de Log, mas sem afetar o processamento
            pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_desistencia --> Erro ao gravar log:' || vr_dscrilog);  
          END IF;
        END IF;      
        
        -- Incluído controle de Log
        pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_desistencia --> ' || pr_dscritic);
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        -- Retornar o erro
        pr_dscritic := SQLERRM;
        
        -- Se tem nome de arquivo
        IF vr_nmarqtxt IS NOT NULL THEN
          -- Gravar o registro de log do arquivo - Erro na geração do arquivo
          COBR0011.pc_gera_log_iptb(pr_nmarquiv => vr_nmarqtxt
                                   ,pr_dtarquiv => vr_dtmvtolt
                                   ,pr_qtregarq => 0
                                   ,pr_idfrmprc => 2 -- Automático
                                   ,pr_cdoperad => '1' 
                                   ,pr_dserrarq => 'Erro ao gerar arquivo desistencia: '||pr_dscritic
                                   ,pr_cdsituac => 2
                                   ,pr_idlogarq => vr_idlogarq
                                   ,pr_dscritic => vr_dscrilog); -- Não parar o processo em caso de erro no log
          
          -- Se apresentar erro
          IF vr_dscrilog IS NOT NULL THEN 
            -- Incluído controle de Log, mas sem afetar o processamento
            pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_desistencia --> Erro ao gravar log:' || vr_dscrilog);  
          END IF;

        END IF;   
        
        -- Incluído controle de Log
        pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_desistencia --> ' || pr_dscritic);
    END pc_gera_arquivo_desistencia;
    -- --------------------------------------------------------------------------------------------------
    
    -- Gera o header do arquivo de cancelamento
    PROCEDURE pc_gera_header_arq_cancel(pr_cdaprese IN  NUMBER
                                       ,pr_nmaprese IN  VARCHAR2
                                       ,pr_dtmvtolt IN  VARCHAR2
                                       ,pr_qtdesist IN  NUMBER
                                       ,pr_qtregtp2 IN  NUMBER
                                       ,pr_nrseqreg IN  NUMBER
                                       ,pr_dsheader OUT VARCHAR2
                                       ,pr_dscritic OUT VARCHAR2
                                       ) IS
    BEGIN
      --
      pr_dsheader := '0'                                       -- 01 -- Tipo do registro -- Fixo 0 - Header do arquivo de cancelamento
                  || lpad(pr_cdaprese, 3, '0')                 -- 02 -- Código do apresentante -- REVISAR
                  || rpad(substr(pr_nmaprese, 0, 45), 45, ' ') -- 03 -- Nome do apresentante -- REVISAR
                  || pr_dtmvtolt                               -- 04 -- Data do movimento
                  || lpad(pr_qtdesist, 5, '0')                 -- 05 -- Quantidade de cancelamentos -- REVISAR
                  || lpad(pr_qtregtp2, 5, '0')                 -- 06 -- Quantidade de registros tipo 2 no arquivo
                  || rpad(' ', 55, ' ')                        -- 07 -- Reservado
                  || lpad(pr_nrseqreg, 5, '0')                 -- 08 -- Seqüência do registro -- Constante 00001
                  ;
      --
    END pc_gera_header_arq_cancel;
    -- Grava o header do arquivo de cancelamento no arquivo XML
    PROCEDURE pc_grava_header_arq_cancel(pr_dsheader   IN     VARCHAR2
                                        ,pr_input_file IN OUT utl_file.file_type
                                        ,pr_dscritic   OUT    VARCHAR2
                                        ) IS
      --
      vr_dsdlinha VARCHAR2(4000);
      --
    BEGIN
      --
      vr_dsdlinha := '<hd h01="' || substr(pr_dsheader, 000, 001)   || '"' ||
                        ' h02="' || substr(pr_dsheader, 002, 003)   || '"' ||
                        ' h03="' || substr(pr_dsheader, 005, 045)   || '"' ||
                        ' h04="' || to_char(vr_dtmvutil,'ddmmyyyy') || '"' ||
                        ' h05="' || substr(pr_dsheader, 058, 005)   || '"' ||
                        ' h06="' || substr(pr_dsheader, 063, 005)   || '"' ||
                        ' h07="' || substr(pr_dsheader, 068, 055)   || '"' ||
                        ' h08="' || substr(pr_dsheader, 123, 005)   || '" />';
      -- Escrever o registro no arquivo
      gene0001.pc_escr_linha_arquivo(pr_utlfileh  => pr_input_file -- Handle do arquivo aberto
                                    ,pr_des_text  => vr_dsdlinha   -- Texto para escrita
                                    );
      --
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao gerar o header do arquivo de cancelamento: ' || SQLERRM;  
    END pc_grava_header_arq_cancel;

    -- Gera o header do cartório no arquivo de cancelamento
    PROCEDURE pc_gera_header_cart_arq_cancel(pr_cdcartor IN  NUMBER
                                            ,pr_qtdesist IN  NUMBER
                                            ,pr_cdmunici IN  NUMBER
                                            ,pr_nrseqreg IN  NUMBER
                                            ,pr_dsheader OUT VARCHAR2
                                            ,pr_dscritic OUT VARCHAR2
                                            ) IS
    BEGIN
      --
      pr_dsheader := '1'                                       -- 01 -- Tipo do registro -- Fixo 0 - Header do cartório no arquivo de cancelamento
                  || lpad(pr_cdcartor, 2, '0')                 -- 02 -- Código do cartório -- REVISAR
                  || lpad(pr_qtdesist, 5, '0')                 -- 03 -- Quantidade de cancelamentos -- REVISAR
                  || lpad(pr_cdmunici, 7, '0')                 -- 04 -- Código do Município
                  || rpad(' ', 107, ' ')                       -- 05 -- Reservado
                  || lpad(pr_nrseqreg, 5, '0')                 -- 06 -- Seqüência do registro -- Constante 00001
                  ;
      --
    END pc_gera_header_cart_arq_cancel;

    -- Grava o header do cartório no arquivo de cancelamento no XML
    PROCEDURE pc_grava_head_cart_arq_cancel(pr_dsheader   IN     VARCHAR2
                                           ,pr_input_file IN OUT utl_file.file_type
                                           ,pr_dscritic   OUT    VARCHAR2
                                           ) IS
      --
      vr_dsdlinha VARCHAR2(4000);
      --
    BEGIN
      --
      vr_dsdlinha := '<hd h01="' || substr(pr_dsheader, 000, 001) || '"' ||
                        ' h02="' || substr(pr_dsheader, 002, 002) || '"' ||
                        ' h03="' || substr(pr_dsheader, 004, 005) || '"' ||
                        ' h04="' || substr(pr_dsheader, 009, 007) || '"' ||
                        ' h05="' || substr(pr_dsheader, 016, 107) || '"' ||
                        ' h06="' || substr(pr_dsheader, 123, 005) || '" />';
      -- Escrever o registro no arquivo
      gene0001.pc_escr_linha_arquivo(pr_utlfileh  => pr_input_file -- Handle do arquivo aberto
                                    ,pr_des_text  => vr_dsdlinha   -- Texto para escrita
                                    );
      --
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao gerar o header do cartório no arquivo de cancelamento: ' || SQLERRM;  
    END pc_grava_head_cart_arq_cancel;

    -- Gera o registro da transação de cancelamento
    PROCEDURE pc_gera_reg_cancel(pr_nrprotoc IN  VARCHAR2
                                ,pr_dtprotoc IN  VARCHAR2
                                ,pr_nrtitulo IN  VARCHAR2
                                ,pr_nmdevedo IN  VARCHAR2
                                ,pr_vltitulo IN  VARCHAR2
                                ,pr_cdagectl IN  VARCHAR2
                                ,pr_nrnosnum IN  VARCHAR2
                                ,pr_nrseqreg IN  VARCHAR2
                                ,pr_dsregist OUT VARCHAR2
                                ,pr_dscritic OUT VARCHAR2
                                ) IS
      --
    BEGIN
      --
      pr_dsregist := '2'                                                                            -- 01 -- Identificação do registro -- Fixo: 2 - Registro de transação
                  || rpad(pr_nrprotoc, 10, ' ')                                                     -- 02 -- Número do protocolo
                  || lpad(pr_dtprotoc, 8, '0')                                                      -- 03 -- Data de protocolagem
                  || lpad(pr_nrtitulo, 11, '0')                                                     -- 04 -- Número do título
                  || substr(pr_nmdevedo, 0, 45)                                                     -- 05 -- Nome do primeiro devedor
                  || lpad(pr_vltitulo, 14, '0')                                                     -- 06 -- Valor do título
                  || 'C'                                                                            -- 07 -- Solicitação de Cancelamento de Protesto -- Fixo C
                  || rpad(pr_cdagectl, 12, ' ')                                                     -- 08 -- Agência/Conta
                  || rpad(nvl(pr_nrnosnum, ' '), 12, ' ')                                           -- 09 -- Carteira/N.Número
                  || rpad(' ', 2, ' ')                                                              -- 10 -- Reservado
                  || rpad(' ', 6, ' ')                                                              -- 11 -- Número de controle de recebimento (não utilizar)
                  || lpad(pr_nrseqreg, 5, '0')                                                      -- 12 -- Seqüência do registro
                  ;
      --
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao gerar o registro de transação de cancelamento: ' || SQLERRM;
    END pc_gera_reg_cancel;

    -- Gera o registro da transação de cancelamento
    PROCEDURE pc_grava_reg_cancel(pr_dsregist   IN     VARCHAR2
                                 ,pr_input_file IN OUT utl_file.file_type
                                 ,pr_dscritic   OUT    VARCHAR2
                                 ) IS
      --
      vr_dsdlinha VARCHAR2(4000);
      --
    BEGIN
      --
      vr_dsdlinha := '<hd h01="' || substr(pr_dsregist, 000, 001) || '"' ||
                        ' h02="' || substr(pr_dsregist, 002, 010) || '"' ||
                        ' h03="' || substr(pr_dsregist, 012, 008) || '"' ||
                        ' h04="' || substr(pr_dsregist, 020, 011) || '"' ||
                        ' h05="' || substr(pr_dsregist, 031, 045) || '"' ||
                        ' h06="' || substr(pr_dsregist, 076, 014) || '"' ||
                        ' h07="' || substr(pr_dsregist, 090, 001) || '"' ||
                        ' h08="' || substr(pr_dsregist, 091, 012) || '"' ||
                        ' h09="' || substr(pr_dsregist, 103, 012) || '"' ||
                        ' h10="' || substr(pr_dsregist, 115, 002) || '"' ||
                        ' h11="' || substr(pr_dsregist, 117, 006) || '"' ||
                        ' h12="' || substr(pr_dsregist, 123, 005) || '" />';
      -- Escrever o registro no arquivo
      gene0001.pc_escr_linha_arquivo(pr_utlfileh  => pr_input_file -- Handle do arquivo aberto
                                    ,pr_des_text  => vr_dsdlinha   -- Texto para escrita
                                    );
      --
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao gravar o registro de transação de cancelamento: ' || SQLERRM;  
    END pc_grava_reg_cancel;

    -- Gera o trailler do cartório no arquivo de cancelamento
    PROCEDURE pc_gera_trail_cart_arq_cancel(pr_cdcartor IN  NUMBER
                                           ,pr_qtdesist IN  NUMBER
                                           ,pr_cdmunici IN  NUMBER
                                           ,pr_nrseqreg IN  NUMBER
                                           ,pr_dsheader OUT VARCHAR2
                                           ,pr_dscritic OUT VARCHAR2
                                           ) IS
    BEGIN
      --
      pr_dsheader := '8'                                       -- 01 -- Tipo do registro -- Fixo 8 - Trailler do cartório no arquivo de cancelamento
                  || lpad(pr_cdcartor, 2, '0')                 -- 02 -- Código do cartório -- REVISAR
                  || lpad(pr_qtdesist, 5, '0')                 -- 03 -- Soma do total de desistências informada no header do cartório e registros tipo 2 do mesmo 
                  || rpad(' ', 114, ' ')                       -- 04 -- Reservado
                  || lpad(pr_nrseqreg, 5, '0')                 -- 05 -- Seqüência do registro
                  ;
      --
    END pc_gera_trail_cart_arq_cancel;

    -- Grava o trailler do cartório no arquivo de cancelamento no XML
    PROCEDURE pc_grava_trail_cart_arq_cancel(pr_dsheader   IN     VARCHAR2
                                            ,pr_input_file IN OUT utl_file.file_type
                                            ,pr_dscritic   OUT    VARCHAR2
                                            ) IS
      --
      vr_dsdlinha VARCHAR2(4000);
      --
    BEGIN
      --
      vr_dsdlinha := '<hd h01="' || substr(pr_dsheader, 000, 001) || '"' ||
                        ' h02="' || substr(pr_dsheader, 002, 002) || '"' ||
                        ' h03="' || substr(pr_dsheader, 004, 008) || '"' ||
                        ' h04="' || substr(pr_dsheader, 009, 114) || '"' ||
                        ' h05="' || substr(pr_dsheader, 123, 005) || '" />';
      -- Escrever o registro no arquivo
      gene0001.pc_escr_linha_arquivo(pr_utlfileh  => pr_input_file -- Handle do arquivo aberto
                                    ,pr_des_text  => vr_dsdlinha   -- Texto para escrita
                                    );
      --
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao gerar o trailler do cartório no arquivo de cancelamento: ' || SQLERRM;  
    END pc_grava_trail_cart_arq_cancel;

    -- Gera o trailler do arquivo de cancelamento
    PROCEDURE pc_gera_trail_arq_cancel(pr_cdaprese IN  NUMBER
                                      ,pr_nmaprese IN  VARCHAR2
                                      ,pr_dtmvtolt IN  VARCHAR2
                                      ,pr_qtdesist IN  NUMBER
                                      ,pr_vltitulo IN  NUMBER
                                      ,pr_nrseqreg IN  NUMBER
                                      ,pr_dstraill OUT VARCHAR2
                                      ,pr_dscritic OUT VARCHAR2
                                      ) IS
    BEGIN
      --
      pr_dstraill := '9'                                                                            -- 01 -- Tipo do registro -- Fixo 9 - Trailler do arquivo de cancelamento
                  || lpad(pr_cdaprese, 3, '0')                                                      -- 02 -- Código do apresentante -- REVISAR
                  || rpad(substr(pr_nmaprese, 0, 45), 45, ' ')                                      -- 03 -- Nome do apresentante -- REVISAR
                  || lpad(pr_dtmvtolt, 8, '0')                                                      -- 04 -- Data do movimento
                  || lpad(pr_qtdesist, 5, '0')                                                      -- 05 -- Soma do total de cancelamentos informada no header do arquivo e registros tipo 2 do mesmo
                  || lpad(pr_vltitulo, 14, '0')                                                     -- 06 -- Somatória do campo Valor do título
                  || rpad(' ', 46, ' ')                                                             -- 07 -- Reservado
                  || lpad(pr_nrseqreg, 5, '0')                                                      -- 08 -- Seqüência do registro
                  ;
      --
    END pc_gera_trail_arq_cancel;

    -- Grava o trailler do arquivo de cancelamento no XML
    PROCEDURE pc_grava_trail_arq_cancel(pr_dstraill   IN     VARCHAR2
                                       ,pr_input_file IN OUT utl_file.file_type
                                       ,pr_dscritic   OUT    VARCHAR2
                                       ) IS
      --
      vr_dsdlinha VARCHAR2(4000);
      --
    BEGIN
      --
      vr_dsdlinha := '<hd h01="' || substr(pr_dstraill, 000, 001)   || '"' ||
                        ' h02="' || substr(pr_dstraill, 002, 003)   || '"' ||
                        ' h03="' || substr(pr_dstraill, 005, 045)   || '"' ||
                        ' h04="' || to_char(vr_dtmvutil,'ddmmyyyy') || '"' ||
                        ' h05="' || substr(pr_dstraill, 058, 005)   || '"' ||
                        ' h06="' || substr(pr_dstraill, 063, 014)   || '"' ||
                        ' h07="' || substr(pr_dstraill, 077, 046)   || '"' ||
                        ' h08="' || substr(pr_dstraill, 123, 005)   || '" />';
      -- Escrever o registro no arquivo
      gene0001.pc_escr_linha_arquivo(pr_utlfileh  => pr_input_file -- Handle do arquivo aberto
                                    ,pr_des_text  => vr_dsdlinha   -- Texto para escrita
                                    );
      --
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao gerar o trailler do cartório no arquivo de cancelamento: ' || SQLERRM;  
    END pc_grava_trail_arq_cancel;

    -- Gera cancelamentos a serem enviados -- REVISAR
    PROCEDURE pc_gera_cancelamento(pr_dscritic OUT VARCHAR2
                                  ) IS
      --
      CURSOR cr_craprem (pr_dtmvtolt IN date) IS
        SELECT lpad(crapcob.cdbandoc, 3, '0') cdbandoc                                                      -- Campo 02 - Header Arquivo
              ,rpad(crapban.nmresbcc, 40, ' ') nmresbcc                                                     -- Campo 03 - Header Arquivo
              ,to_char(crapdat.dtmvtopr, 'DDMMYYYY') dtmvtolt                                               -- Campo 04 - Header Arquivo
              ,lpad(tbcobran_retorno_ieptb.cdcartorio, 2, '0') cdcartor                                 -- Campo 02 - Header Cartório
              ,lpad(tbcobran_retorno_ieptb.cdcomarc, 7, '0') cdcomarc                                   -- Campo 04 - Header Cartório
              ,lpad(tbcobran_retorno_ieptb.nrprotoc_cartorio, 10, '0') nrprotoc                         -- Campo 02 - Transação
              ,to_char(tbcobran_retorno_ieptb.dtprotocolo, 'DDMMYYYY') dtprotoc                         -- Campo 03 - Transação
              ,lpad(crapcob.nrdocmto, 11, '0') nrdocmto                                                     -- Campo 04 - Transação
              ,rpad(gene0007.fn_caract_especial(crapsab.nmdsacad), 45, ' ') nmdsacad                        -- Campo 05 - Transação
              --,lpad(replace(trim(to_char(crapcob.vltitulo, '999999999990D90')), ',', ''), 14, '0') vltitulo -- Campo 06 - Transação
              ,lpad(TRUNC(crapcob.vltitulo * 100), 14, '0') vltitulo                                        -- Campo 06 - Transação
              ,lpad(crapcop.cdagectl, 4, '0') || lpad(crapcob.nrdconta, 8, '0') nrdconta                    -- Campo 08 - Transação
              ,lpad(crapcob.nrnosnum, 12, '0') nrnosnum                                                     -- Campo 09 - Transação
              ,crapcob.rowid
              ,crapcob.cdcooper
              ,crapdat.dtmvtolt dtmvtolt_dat
          FROM craprem
              ,crapcob
              ,crapdat
              ,crapban
              ,crapcop
              ,crapsab
              ,tbcobran_retorno_ieptb
              ,crapcco
              ,crapcre
         WHERE crapcco.cdcooper > 0
           AND crapcco.cddbanco = 85
           AND crapcre.cdcooper = crapcco.cdcooper
           AND crapcre.nrcnvcob = crapcco.nrconven
           AND crapcre.dtmvtolt = pr_dtmvtolt
           AND crapcre.intipmvt = 1
           AND craprem.cdcooper = crapcre.cdcooper
           AND craprem.nrcnvcob = crapcre.nrcnvcob
           AND craprem.nrremret = crapcre.nrremret
           AND craprem.cdcooper                = crapcob.cdcooper
           AND craprem.nrcnvcob                = crapcob.nrcnvcob
           AND craprem.nrdconta                = crapcob.nrdconta
           AND craprem.nrdocmto                = crapcob.nrdocmto
           AND crapdat.cdcooper                = crapcob.cdcooper
           AND crapban.cdbccxlt                = crapcob.cdbandoc
           AND crapcop.cdcooper                = crapcob.cdcooper
           AND crapsab.cdcooper                = crapcob.cdcooper
           AND crapsab.nrdconta                = crapcob.nrdconta
           AND crapsab.nrinssac                = crapcob.nrinssac
           AND tbcobran_retorno_ieptb.cdcooper = craprem.cdcooper
           AND tbcobran_retorno_ieptb.nrdconta = craprem.nrdconta
           AND tbcobran_retorno_ieptb.nrcnvcob = craprem.nrcnvcob
           AND tbcobran_retorno_ieptb.nrdocmto = craprem.nrdocmto
           AND crapcob.cdbandoc                = 85 -- REVISAR
           AND crapcob.insrvprt                = 1  -- REVISAR
           AND craprem.cdocorre                IN(81)
         ORDER BY tbcobran_retorno_ieptb.cdcomarc, tbcobran_retorno_ieptb.cdcartorio;
      --
      rw_craprem cr_craprem%ROWTYPE;
      --
      vr_arq_xml CLOB;
      --
      vr_cdcartor tbcobran_confirmacao_ieptb.cdcartorio%TYPE;
      vr_qtregist NUMBER;
      vr_qtnumarq NUMBER;
      vr_dsdlinha VARCHAR2(600);
      vr_qtregtra NUMBER;
      vr_vlsomseg NUMBER;
      vr_idgercab BOOLEAN;
      --
      vr_exc_erro EXCEPTION;
      vr_des_erro VARCHAR2(100);
      vr_dscritic VARCHAR2(1000);
      --
    BEGIN
      -- Incluido controle de Log inicio programa
      pc_controla_log_batch(1, 'Início pc_crps729.pc_gera_cancelamento');
      -- Inicializa variáveis
      vr_qtregist  := 1;
      vr_qtnumarq  := 0;
      vr_vlsomseg  := 0;
      vr_idgercab  := TRUE;
      vr_index_arq := 0;
      --
      vr_tab_arquivo.delete;
      
      --
      OPEN cr_craprem(pr_dtmvtolt => vr_dtmvprocessar);
      --
      LOOP
        --
        FETCH cr_craprem INTO rw_craprem;
        EXIT WHEN cr_craprem%NOTFOUND;
        --
        IF vr_qtregist = 1 THEN
          -- Inicializa o arquivo de cancelamentos       
          
          pc_gera_header_arq_cancel(pr_cdaprese => rw_craprem.cdbandoc -- IN
                                   ,pr_nmaprese => rw_craprem.nmresbcc -- IN
                                   ,pr_dtmvtolt => rw_craprem.dtmvtolt -- IN
                                   ,pr_qtdesist => 0                   -- IN
                                   ,pr_qtregtp2 => 0                   -- IN
                                   ,pr_nrseqreg => vr_qtregist         -- IN
                                   ,pr_dsheader => vr_dsdlinha         -- OUT
                                   ,pr_dscritic => pr_dscritic         -- OUT
                                   );
          --
          IF pr_dscritic IS NOT NULL THEN
            --
            RAISE vr_exc_erro;
            --
          ELSE
            --
            pc_insere_linha(pr_linha => vr_dsdlinha      -- IN
                           ,pr_cdcooper => rw_craprem.cdcooper
                           ,pr_rowid => rw_craprem.rowid -- IN
                           );
                           
            PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_craprem.rowid
                                        , pr_cdoperad => '1'
                                        , pr_dtmvtolt => rw_craprem.dtmvtolt_dat
                                        , pr_dsmensag => 'Exclusao Protesto - Carta de anuencia eletronica enviada'
                                        , pr_des_erro => vr_des_erro
                                        , pr_dscritic => vr_dscritic);                                                        
            --
          END IF;
          --
          vr_qtregist := vr_qtregist + 1;
          --
        END IF;
        -- Verifica se precisa inicializar um novo cartório
        IF nvl(vr_cdcartor, '0') <> rw_craprem.cdcartor THEN
          -- Verifica se finaliza a remessa anterior
          IF vr_qtnumarq > 0 THEN
            --
            vr_dsdlinha := NULL;
            --
            pc_gera_trail_cart_arq_cancel(pr_cdcartor => rw_craprem.cdcartor -- IN
                                         ,pr_qtdesist => 0                   -- IN
                                         ,pr_cdmunici => rw_craprem.cdcomarc -- IN
                                         ,pr_nrseqreg => vr_qtregist         -- IN
                                         ,pr_dsheader => vr_dsdlinha         -- OUT
                                         ,pr_dscritic => pr_dscritic         -- OUT
                                         );
            --
            IF pr_dscritic IS NOT NULL THEN
              --
              RAISE vr_exc_erro;
              --
            ELSE
              --
              pc_insere_linha(pr_linha => vr_dsdlinha      -- IN
                             ,pr_cdcooper => rw_craprem.cdcooper
                             ,pr_rowid => rw_craprem.rowid -- IN
                             );
              --
            END IF;
            --
            vr_qtregist := vr_qtregist + 1;
            --
          END IF;
          --
          vr_qtnumarq := vr_qtnumarq + 1;
          vr_vlsomseg := 0;
          vr_idgercab := TRUE;
          vr_cdcartor := rw_craprem.cdcartor;
          --
        END IF;
        -- Se for o primeiro registro, gerar o cabeçalho
        IF vr_idgercab THEN
          --
          vr_dsdlinha := NULL;
          --
          pc_gera_header_cart_arq_cancel(pr_cdcartor => rw_craprem.cdcartor -- IN
                                        ,pr_qtdesist => 0                   -- IN
                                        ,pr_cdmunici => rw_craprem.cdcomarc -- IN
                                        ,pr_nrseqreg => vr_qtregist         -- IN
                                        ,pr_dsheader => vr_dsdlinha         -- OUT
                                        ,pr_dscritic => pr_dscritic         -- OUT
                                        );
          --
          IF pr_dscritic IS NOT NULL THEN
            --
            RAISE vr_exc_erro;
            --
          ELSE
            --
            pc_insere_linha(pr_linha => vr_dsdlinha      -- IN
                           ,pr_cdcooper => rw_craprem.cdcooper
                           ,pr_rowid => rw_craprem.rowid -- IN
                           );
            --
          END IF;
          --
          vr_qtregist := vr_qtregist + 1;
          vr_idgercab := FALSE;
          --
        END IF;
        --
        vr_dsdlinha := null;
        --
        pc_gera_reg_cancel(pr_nrprotoc => rw_craprem.nrprotoc -- IN
                          ,pr_dtprotoc => rw_craprem.dtprotoc -- IN
                          ,pr_nrtitulo => rw_craprem.nrdocmto -- IN
                          ,pr_nmdevedo => rw_craprem.nmdsacad -- IN
                          ,pr_vltitulo => rw_craprem.vltitulo -- IN
                          ,pr_cdagectl => rw_craprem.nrdconta -- IN
                          ,pr_nrnosnum => rw_craprem.nrnosnum -- IN
                          ,pr_nrseqreg => vr_qtregist         -- IN
                          ,pr_dsregist => vr_dsdlinha         -- OUT
                          ,pr_dscritic => pr_dscritic         -- OUT
                          );
        --
        IF pr_dscritic IS NOT NULL THEN
          --
          RAISE vr_exc_erro;
          --
        ELSE
          --
          pc_insere_linha(pr_linha => vr_dsdlinha      -- IN
                         ,pr_cdcooper => rw_craprem.cdcooper
                         ,pr_rowid => rw_craprem.rowid -- IN
                         );
          --
        END IF;
        --
        vr_qtregist := vr_qtregist + 1;
        --
        vr_vlsomseg := vr_vlsomseg + rw_craprem.vltitulo;
        --
      END LOOP;
      -- Verifica se finaliza a remessa anterior
      IF vr_qtregist > 1 THEN
        --
        vr_dsdlinha := NULL;
        --
        pc_gera_trail_cart_arq_cancel(pr_cdcartor => rw_craprem.cdcartor -- IN
                                     ,pr_qtdesist => 0                   -- IN
                                     ,pr_cdmunici => rw_craprem.cdcomarc -- IN
                                     ,pr_nrseqreg => vr_qtregist         -- IN
                                     ,pr_dsheader => vr_dsdlinha         -- OUT
                                     ,pr_dscritic => pr_dscritic         -- OUT
                                     );
        --
        IF pr_dscritic IS NOT NULL THEN
          --
          RAISE vr_exc_erro;
          --
        ELSE
          --
          pc_insere_linha(pr_linha => vr_dsdlinha      -- IN
                         ,pr_cdcooper => rw_craprem.cdcooper
                         ,pr_rowid => rw_craprem.rowid -- IN
                         );
          --
        END IF;
        --
        vr_qtregist := vr_qtregist + 1;
        --
      END IF;
      --
      CLOSE cr_craprem;
      -- Verifica se finaliza o arquivo
      IF vr_qtregist > 1 THEN
        --
        vr_dsdlinha := NULL;
        --

        pc_gera_trail_arq_cancel(pr_cdaprese => rw_craprem.cdbandoc -- IN
                                ,pr_nmaprese => rw_craprem.nmresbcc -- IN
                                ,pr_dtmvtolt => rw_craprem.dtmvtolt -- IN
                                ,pr_qtdesist => 0                   -- IN
                                ,pr_vltitulo => vr_vlsomseg         -- IN
                                ,pr_nrseqreg => vr_qtregist         -- IN
                                ,pr_dstraill => vr_dsdlinha         -- OUT
                                ,pr_dscritic => pr_dscritic         -- OUT
                                );
        --
        IF pr_dscritic IS NOT NULL THEN
          --
          RAISE vr_exc_erro;
          --
        ELSE
          --
          pc_insere_linha(pr_linha => vr_dsdlinha      -- IN
                         ,pr_cdcooper => rw_craprem.cdcooper
                         ,pr_rowid => rw_craprem.rowid -- IN
                         );
          --
        END IF;
        --
      END IF;
      -- Escrever o log no arquivo
      pc_controla_log_batch(1, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_cancelamento --> Finalizado o processamento dos cancelamentos.'); -- Texto para escrita
      --
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Incluído controle de Log
        --pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_cancelamento --> ' || rw_craprem.cdcooper || '/' || rw_craprem.nrdconta || '/' || rw_craprem.nrcnvcob || '/' || rw_craprem.nrdocmto || ' não processado devido ao ERRO: ' || pr_dscritic);
        
        NULL;
      WHEN OTHERS THEN
        -- Incluído controle de Log
        --pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_cancelamento --> ' || rw_craprem.cdcooper || '/' || rw_craprem.nrdconta || '/' || rw_craprem.nrcnvcob || '/' || rw_craprem.nrdocmto || ' não processado devido ao ERRO: ' || SQLERRM);
        pr_dscritic := SQLERRM;
    END pc_gera_cancelamento;

    -- Gera o arquivo de cancelamento -- REVISAR
    PROCEDURE pc_gera_arquivo_cancelamento(pr_dscritic OUT VARCHAR2
                                          ) IS
      --
      vr_dtmvtolt   crapdat.dtmvtolt%TYPE;
      vr_input_file utl_file.file_type;
      vr_nmarqtxt   VARCHAR2(13);
      vr_nmdirtxt   VARCHAR2(400);
      --
      vr_dslinhea   VARCHAR2(600);
      vr_dslintra   VARCHAR2(600);
      vr_qtregdes   NUMBER;
      vr_qttotdes   NUMBER;
      vr_qtorirem   NUMBER;
      --
      vr_index_arq_ant NUMBER;
      vr_index_reg     NUMBER;
      --
      vr_exc_erro EXCEPTION;
      --
    BEGIN
      -- Incluido controle de Log inicio programa
      pc_controla_log_batch(1, 'Início crps729.pc_gera_arquivo_cancelamento');
      --
      IF vr_tab_arquivo.count > 0 THEN
        --
        vr_dtmvtolt := TRUNC(SYSDATE);

        -- Busca o nome do arquivo
        vr_nmarqtxt := cobr0011.fn_gera_nome_arq_cancelamento(pr_cdbandoc => '85'        -- IN
                                                             ,pr_dtmvtolt => vr_dtmvutil -- IN
                                                             );
                                                             
        -- Diretório onde deverá gerar o arquivo de cancelamento
        --vr_nmdirtxt := '/micros/cecred/ieptb/remessa/';
        vr_nmdirtxt := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'              -- IN
                                                ,pr_cdcooper => 3                   -- IN
                                                ,pr_cdacesso => 'DIR_IEPTB_REMESSA' -- IN
                                                );
        -- Abre o arquivo de dados em modo de gravação
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirtxt   -- IN -- Diretório do arquivo
                                ,pr_nmarquiv => vr_nmarqtxt   -- IN -- Nome do arquivo
                                ,pr_tipabert => 'W'           -- IN -- Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_input_file -- IN -- Handle do arquivo aberto
                                ,pr_des_erro => pr_dscritic   -- IN -- Erro
                                );
        --
        IF pr_dscritic IS NOT NULL THEN
          --
          RAISE vr_exc_erro;
          --
        END IF;
        -- Escrever o registro no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file            -- Handle do arquivo aberto
                                      ,pr_des_text  => '<?xml version="1.0"?> ' -- Texto para escrita
                                      );
        -- Abre o cancelamento
        -- Escrever o registro no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file -- Handle do arquivo aberto
                                      ,pr_des_text  => '<cancelamento>'   -- Texto para escrita
                                      );
        -- Busca o primeiro registro
        vr_index_arq := vr_tab_arquivo.first;
        -- Percorre todos os registros para gerar os totalizadores
        WHILE vr_index_arq IS NOT NULL LOOP
          -- Verifica se o registro é do tipo header do arquivo
          IF substr(vr_tab_arquivo(vr_index_arq).ds_registro, 0, 1) = 0 THEN
            --
            vr_dslinhea  := vr_tab_arquivo(vr_index_arq).ds_registro;
            vr_qttotdes  := 0;
            vr_index_reg := vr_index_arq;
            --
            WHILE vr_index_reg IS NOT NULL LOOP
              --
              IF substr(vr_tab_arquivo(vr_index_reg).ds_registro, 0, 1) = 2 THEN
                --
                vr_qttotdes := vr_qttotdes + 1;
                --
              END IF;
              -- Próximo registro
              vr_index_reg := vr_tab_arquivo.next(vr_index_reg);
              --
            END LOOP;
            -- Joga os totais no header do arquivo
            vr_dslinhea := substr(vr_dslinhea, 0, 57) || lpad((vr_qttotdes), 5, '0') || lpad((vr_qttotdes), 5, '0') || substr(vr_dslinhea, 68, 60);
            -- Grava o header do arquivo
            pc_grava_header_arq_cancel(pr_dsheader   => vr_dslinhea   -- IN
                                      ,pr_input_file => vr_input_file -- IN OUT
                                      ,pr_dscritic   => pr_dscritic   -- OUT
                                      );
            --
            IF pr_dscritic IS NOT NULL THEN
              --
              RAISE vr_exc_erro;
              --
            END IF;
            --
            vr_dslinhea := NULL;
          -- Verifica se o registro é do tipo header do cartório
          ELSIF substr(vr_tab_arquivo(vr_index_arq).ds_registro, 0, 1) = 1 THEN
            --
            vr_dslinhea      := vr_tab_arquivo(vr_index_arq).ds_registro;
            vr_index_arq_ant := NULL;
            vr_qtregdes      := 0;
            --
          -- Verifica se o registro é do tipo transação
          ELSIF substr(vr_tab_arquivo(vr_index_arq).ds_registro, 0, 1) = 2 THEN
            -- Guarda a posição do primeiro registro de transação do cancelamento
            IF vr_index_arq_ant IS NULL THEN
              --
              vr_index_arq_ant := vr_index_arq;
              --
            END IF;
            --
            vr_qtregdes := vr_qtregdes + 1;
            --
          -- Verifica se o registro é do tipo trailler do cartório
          ELSIF substr(vr_tab_arquivo(vr_index_arq).ds_registro, 0, 1) = 8 THEN
            --
            vr_dslintra := vr_tab_arquivo(vr_index_arq).ds_registro;
            -- Joga os totais no header do cartório
            vr_dslinhea := substr(vr_dslinhea, 0, 3) || lpad(vr_qtregdes, 5, '0') || substr(vr_dslinhea, 9, 119);
            -- Grava o header do cartório
            pc_grava_head_cart_arq_cancel(pr_dsheader   => vr_dslinhea   -- IN
                                         ,pr_input_file => vr_input_file -- IN OUT
                                         ,pr_dscritic   => pr_dscritic   -- OUT
                                         );
            --
            IF pr_dscritic IS NOT NULL THEN
              --
              RAISE vr_exc_erro;
              --
            END IF;
            --
            vr_index_reg := vr_index_arq_ant;
            -- Grava as transações
            WHILE vr_index_reg IS NOT NULL LOOP
              -- Finaliza
              IF substr(vr_tab_arquivo(vr_index_reg).ds_registro, 0, 1) = 8 THEN
                --
                vr_index_reg := NULL;
                EXIT;
                --
              ELSE
                -- Gravar a transação
                pc_grava_reg_cancel(pr_dsregist   => vr_tab_arquivo(vr_index_reg).ds_registro -- IN
                                   ,pr_input_file => vr_input_file                            -- IN OUT
                                   ,pr_dscritic   => pr_dscritic                              -- OUT
                                   );
                --
                IF pr_dscritic IS NOT NULL THEN
                  --
                  RAISE vr_exc_erro;
                  --
                END IF;
                --
              END IF;
              -- Próximo registro
              vr_index_reg := vr_tab_arquivo.next(vr_index_reg);
              --
            END LOOP;
            -- Joga os totais no trailler do cartório
            vr_dslintra := substr(vr_dslintra, 0, 3) || lpad((vr_qtregdes + vr_qtregdes), 5, '0') || substr(vr_dslintra, 009, 119);
            -- Grava o trailler do cartório
            pc_grava_trail_cart_arq_cancel(pr_dsheader   => vr_dslintra   -- IN
                                          ,pr_input_file => vr_input_file -- IN OUT
                                          ,pr_dscritic   => pr_dscritic   -- OUT
                                          );
            --
            IF pr_dscritic IS NOT NULL THEN
              --
              RAISE vr_exc_erro;
              --
            END IF;
          -- Verifica se o registro é do tipo trailler do arquivo
          ELSIF substr(vr_tab_arquivo(vr_index_arq).ds_registro, 0, 1) = 9 THEN
            --
            vr_dslintra := vr_tab_arquivo(vr_index_arq).ds_registro;
            -- Joga os totais no trailler do arquivo
            vr_dslintra := substr(vr_dslintra, 0, 57) || lpad((vr_qttotdes + vr_qttotdes), 5, '0') || substr(vr_dslintra, 063, 78);
            -- Grava o trailler do arquivo
            pc_grava_trail_arq_cancel(pr_dstraill   => vr_dslintra   -- IN
                                     ,pr_input_file => vr_input_file -- IN OUT
                                     ,pr_dscritic   => pr_dscritic   -- OUT
                                     );
            --
            IF pr_dscritic IS NOT NULL THEN
              --
              RAISE vr_exc_erro;
              --
            END IF;
          -- Se não for de nenhum dos tipos anteriores, gera erro
          ELSE
            -- Incluído controle de Log
            pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_cancelamento --> Tipo de registro inexistente!');
            RAISE vr_exc_erro;
            --
          END IF;
          -- Próximo registro
          vr_index_arq := vr_tab_arquivo.next(vr_index_arq);
          --
        END LOOP;
        -- Fecha a remessa
        -- Escrever o registro no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file -- Handle do arquivo aberto
                                      ,pr_des_text  => '</cancelamento>'  -- Texto para escrita
                                      );
        -- Fechar Arquivo dados
        BEGIN
          --
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
          --
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Problema ao fechar o arquivo: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        --
      END IF;
      --
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Incluído controle de Log
        pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_cancelamento --> ' || pr_dscritic);
      WHEN OTHERS THEN
        -- Incluído controle de Log
        pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_cancelamento --> ' || SQLERRM);
    END pc_gera_arquivo_cancelamento;
    --
    PROCEDURE pc_gera_cancelamento_ieptb(pr_dscritic OUT VARCHAR2
                                        ) IS
      --
      CURSOR cr_craprem (pr_dtmvtolt IN DATE) IS
        SELECT lpad(crapcob.cdbandoc, 3, '0') cdbandoc                                                  -- Campo 02 - Header Arquivo
              ,rpad(crapban.nmresbcc, 40, ' ') nmresbcc                                                 -- Campo 03 - Header Arquivo
              ,to_char(crapdat.dtmvtopr, 'DDMMYYYY') dtmvtolt                                           -- Campo 04 - Header Arquivo
              ,lpad(tbcobran_retorno_ieptb.cdcartorio, 2, '0') cdcartor                                 -- Campo 02 - Header Cartório
              ,lpad(tbcobran_retorno_ieptb.cdcomarc, 7, '0') cdcomarc                                   -- Campo 04 - Header Cartório
              ,lpad(tbcobran_retorno_ieptb.nrprotoc_cartorio, 10, '0') nrprotoc                         -- Campo 02 - Transação
              ,to_char(tbcobran_retorno_ieptb.dtprotocolo, 'DDMMYYYY') dtprotoc                         -- Campo 03 - Transação
              ,lpad(crapcob.nrdocmto, 11, '0') nrdocmto                                                 -- Campo 04 - Transação
              ,rpad(crapsab.nmdsacad, 45, ' ') nmdsacad                                                 -- Campo 05 - Transação
              --,replace(to_char(crapcob.vltitulo),',','.') vltitulo                                      -- Campo 06 - Transação
              ,lpad(TRUNC(crapcob.vltitulo * 100), 14, '0') vltitulo                                    -- Campo 06 - Transação
              ,lpad(crapcop.cdagectl, 4, '0') || lpad(crapcob.nrdconta, 8, '0') nrdconta                -- Campo 08 - Transação
              ,lpad(crapcob.nrnosnum, 12, '0') nrnosnum                                                 -- Campo 09 - Transação
              ,crapcob.rowid
              -- Campos log
              ,crapcob.cdcooper   cdcoplog
              ,crapcob.cdbandoc   cdbanlog
              ,crapcob.nrdctabb   nrcbblog
              ,crapcob.nrcnvcob   nrcnvlog
              ,crapcob.nrdconta   nrctalog
              ,crapcob.nrdocmto   nrdoclog
              ,crapcob.vltitulo   vltitlog
          FROM craprem
              ,crapcob
              ,crapdat
              ,crapban
              ,crapcop
              ,crapsab
              ,tbcobran_retorno_ieptb
              ,crapcco
              ,crapcre
         WHERE crapcco.cdcooper > 0
           AND crapcco.cddbanco = 85
           AND crapcre.cdcooper = crapcco.cdcooper
           AND crapcre.nrcnvcob = crapcco.nrconven
           AND crapcre.dtmvtolt = pr_dtmvtolt
           AND crapcre.intipmvt = 1
           AND craprem.cdcooper = crapcre.cdcooper
           AND craprem.nrcnvcob = crapcre.nrcnvcob
           AND craprem.nrremret = crapcre.nrremret
           AND craprem.cdcooper                = crapcob.cdcooper
           AND craprem.nrcnvcob                = crapcob.nrcnvcob
           AND craprem.nrdconta                = crapcob.nrdconta
           AND craprem.nrdocmto                = crapcob.nrdocmto
           AND crapdat.cdcooper                = crapcob.cdcooper
           AND crapban.cdbccxlt                = crapcob.cdbandoc
           AND crapcop.cdcooper                = crapcob.cdcooper
           AND crapsab.cdcooper                = crapcob.cdcooper
           AND crapsab.nrdconta                = crapcob.nrdconta
           AND crapsab.nrinssac                = crapcob.nrinssac
           AND tbcobran_retorno_ieptb.cdcooper = craprem.cdcooper
           AND tbcobran_retorno_ieptb.nrdconta = craprem.nrdconta
           AND tbcobran_retorno_ieptb.nrcnvcob = craprem.nrcnvcob
           AND tbcobran_retorno_ieptb.nrdocmto = craprem.nrdocmto
           AND crapcob.cdbandoc                = 85 -- REVISAR
           AND crapcob.insrvprt                = 1  -- REVISAR
           AND craprem.cdocorre                IN(81)
         ORDER BY tbcobran_retorno_ieptb.cdcomarc, tbcobran_retorno_ieptb.cdcartorio;
      --
      rw_craprem cr_craprem%ROWTYPE;
      --
      vr_arq_xml CLOB;
      --
      vr_cdcomarc tbcobran_confirmacao_ieptb.cdcomarc%TYPE;
      vr_cdcartor tbcobran_confirmacao_ieptb.cdcartorio%TYPE;
      vr_qtregist NUMBER;
      vr_qtcartor NUMBER;
      vr_qtnumarq NUMBER;
      vr_dsdlinha VARCHAR2(600);
      vr_qtregtra NUMBER;
      vr_vlsomseg NUMBER;
      vr_idgercab BOOLEAN;
      vr_arquivo  CLOB;
      --
      vr_dtmvtolt   crapdat.dtmvtolt%TYPE;
      vr_input_file utl_file.file_type;
      vr_nmarqtxt   VARCHAR2(13);
      vr_nmdirtxt   VARCHAR2(400);
      --
      vr_idlogarq   tbcobran_log_arquivo_ieptb.idlog_arquivo%TYPE;
      vr_dscrilog   VARCHAR2(1000);
      --
      vr_exc_erro EXCEPTION;
      --
    BEGIN
      -- Incluido controle de Log inicio programa
      pc_controla_log_batch(1, 'Início pc_crps729.pc_gera_cancelamento');
      -- Inicializa variáveis
      vr_qtregist  := 1;
      vr_qtcartor  := 1;
      vr_qtnumarq  := 0;
      vr_vlsomseg  := 0;
      vr_idgercab  := TRUE;
      vr_index_arq := 0;
      --
      vr_tab_arquivo.delete;
      vr_tab_itemlog.delete; -- Limpar itens log

      -- buscar a data da Central para buscar o movimento de remessa
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => 3);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;            
      --
      OPEN cr_craprem(pr_dtmvtolt => vr_dtmvprocessar);
      --
      LOOP
        --
        FETCH cr_craprem INTO rw_craprem;
        EXIT WHEN cr_craprem%NOTFOUND;
        --
        IF vr_qtregist = 1 THEN
          -- Inicializa o arquivo de cancelamentos
          vr_arquivo := '<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?><cancelamento>';
          --
        END IF;
        -- Verifica se precisa inicializar uma nova comarca
        IF nvl(vr_cdcomarc, '0') <> rw_craprem.cdcomarc THEN
          --
          IF vr_qtregist > 1 THEN
            --
            vr_arquivo := vr_arquivo || '</cartorio></comarca>' ;
            --
          END IF;
          --
          vr_arquivo := vr_arquivo || '<comarca><CodMun>' || trim(rw_craprem.cdcomarc) || '</CodMun>';
          --
          vr_cdcomarc := rw_craprem.cdcomarc;
          vr_qtcartor := 1;
          vr_cdcartor := 0;
          --
        END IF;
        -- Verifica se precisa inicializar um novo cartório
        IF nvl(vr_cdcartor, 0) <> to_number(rw_craprem.cdcartor) THEN
          --
          IF vr_qtcartor > 1 THEN
            --
            vr_arquivo := vr_arquivo || '</cartorio>' ;
            --
          END IF;
          --
          vr_arquivo := vr_arquivo || '<cartorio><numero_cartorio>' || trim(rw_craprem.cdcartor) || '</numero_cartorio>';
          vr_cdcartor := rw_craprem.cdcartor;
          vr_qtcartor := vr_qtcartor + 1;
          --
        END IF;
        --
        vr_arquivo := vr_arquivo || '<titulo>';
        vr_arquivo := vr_arquivo || '<numero_protocolo>' || trim(rw_craprem.nrprotoc) || '</numero_protocolo>';
        vr_arquivo := vr_arquivo || '<data_protocolo>' || trim(rw_craprem.dtprotoc) || '</data_protocolo>';
        vr_arquivo := vr_arquivo || '<numero_titulo>' || trim(rw_craprem.nrdocmto) || '</numero_titulo>';
        vr_arquivo := vr_arquivo || '<nome_devedor>' || trim(rw_craprem.nmdsacad) || '</nome_devedor>';
        vr_arquivo := vr_arquivo || '<valor_titulo>' || trim(rw_craprem.vltitulo) || '</valor_titulo>';
        vr_arquivo := vr_arquivo || '</titulo>';
        --
        vr_qtregist := vr_qtregist + 1;
        --
        -- Adicionar item no log
        vr_tab_itemlog(vr_tab_itemlog.count()+1).cdcooper := rw_craprem.cdcoplog;
        vr_tab_itemlog(vr_tab_itemlog.count()  ).cdbandoc := rw_craprem.cdbanlog;
        vr_tab_itemlog(vr_tab_itemlog.count()  ).nrdctabb := rw_craprem.nrcbblog;
        vr_tab_itemlog(vr_tab_itemlog.count()  ).nrcnvcob := rw_craprem.nrcnvlog;
        vr_tab_itemlog(vr_tab_itemlog.count()  ).nrdconta := rw_craprem.nrctalog;
        vr_tab_itemlog(vr_tab_itemlog.count()  ).nrdocmto := rw_craprem.nrdoclog;
        vr_tab_itemlog(vr_tab_itemlog.count()  ).vltitulo := rw_craprem.vltitlog;
        
      END LOOP;
      --
      CLOSE cr_craprem;
      
      -- Verifica se finaliza o arquivo
      IF vr_qtregist > 1 THEN
        --
        vr_arquivo := vr_arquivo || '</cartorio></comarca></cancelamento>' ;

        -- utilizar a data do dia da Central
        vr_dtmvtolt := rw_crapdat.dtmvtocd;
        
        -- Busca o nome do arquivo
        vr_nmarqtxt := cobr0011.fn_gera_nome_arq_cancelamento(pr_cdbandoc => '85'        -- IN
                                                             ,pr_dtmvtolt => vr_dtmvutil -- IN
                                                              );
        
        -- Faz o envelopamento SOAP
        vr_arquivo := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:protesto_brIntf-Iprotesto_br">'
                   || '<soapenv:Header/>'
                   || '<soapenv:Body>'
                   || '<urn:Cancelamento soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
                   || '<user_arq xsi:type="xsd:string">' || vr_nmarqtxt || '</user_arq>'
                   || '<user_dados xsi:type="xsd:string">' || htf.escape_sc(vr_arquivo) || '</user_dados>'
                   || '</urn:Cancelamento>'
                   || '</soapenv:Body>'
                   || '</soapenv:Envelope>';
        
        -- Diretório onde deverá gerar o arquivo de cancelamento
        --vr_nmdirtxt := '/micros/cecred/ieptb/remessa/';
        vr_nmdirtxt := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'              -- IN
                                                ,pr_cdcooper => 3                   -- IN
                                                ,pr_cdacesso => 'DIR_IEPTB_REMESSA' -- IN
                                                );
        -- Abre o arquivo de dados em modo de gravação
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirtxt   -- IN -- Diretório do arquivo
                                ,pr_nmarquiv => vr_nmarqtxt   -- IN -- Nome do arquivo
                                ,pr_tipabert => 'W'           -- IN -- Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_input_file -- IN -- Handle do arquivo aberto
                                ,pr_des_erro => pr_dscritic   -- IN -- Erro
                                );
        --
        IF pr_dscritic IS NOT NULL THEN
          --
          RAISE vr_exc_erro;
          --
        END IF;
        -- Escrever o registro no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file            -- Handle do arquivo aberto
                                      ,pr_des_text  => vr_arquivo -- Texto para escrita
                                      );
        -- Fechar Arquivo dados
        BEGIN
          --
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
          --
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
            pr_dscritic := 'Problema ao fechar o arquivo: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        -- Escrever o log no arquivo
        pc_controla_log_batch(1, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_cancelamento --> Finalizado o processamento dos cancelamentos.'); -- Texto para escrita
        
        -- Gravar o registro de log do arquivo
        COBR0011.pc_gera_log_iptb(pr_nmarquiv => vr_nmarqtxt
                                 ,pr_dtarquiv => vr_dtmvtolt
                                 ,pr_qtregarq => vr_tab_itemlog.count()
                                 ,pr_idfrmprc => 2 -- Automático
                                 ,pr_cdoperad => '1' 
                                 ,pr_idlogarq => vr_idlogarq
                                 ,pr_cdsituac => 1
                                 ,pr_dscritic => vr_dscrilog); -- Não parar o processo em caso de erro no log
        
        -- Se apresentar erro
        IF vr_dscrilog IS NOT NULL THEN 
          -- Incluído controle de Log, mas sem afetar o processamento
          pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_cancelamento --> Erro ao gravar log:' || vr_dscrilog);
        ELSE
          -- Se tem itens de log
          IF vr_tab_itemlog.count > 0 THEN
            -- Percorre todos os itens do log
            FOR ind IN vr_tab_itemlog.FIRST..vr_tab_itemlog.LAST LOOP
            
              -- Gravar o registro de log
              COBR0011.pc_gera_log_item_iptb(pr_idlogarq => vr_idlogarq
                                            ,pr_cdcooper => vr_tab_itemlog(ind).cdcooper
                                            ,pr_cdbandoc => vr_tab_itemlog(ind).cdbandoc
                                            ,pr_nrdctabb => vr_tab_itemlog(ind).nrdctabb
                                            ,pr_nrcnvcob => vr_tab_itemlog(ind).nrcnvcob
                                            ,pr_nrdconta => vr_tab_itemlog(ind).nrdconta
                                            ,pr_nrdocmto => vr_tab_itemlog(ind).nrdocmto
                                            ,pr_vltitulo => vr_tab_itemlog(ind).vltitulo
                                            ,pr_dscritic => vr_dscrilog); -- Não parar o processo em caso de erro no log
            
              -- Se apresentar erro
              IF vr_dscrilog IS NOT NULL THEN 
                -- Incluído de Log do item, mas sem afetar o processamento
                pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_cancelamento --> Erro ao gravar item do log:' || vr_dscrilog);
                
                -- Limpar registro de erro para a próxima iteração
                vr_dscrilog := NULL;
              END IF; -- Erro log item
            
            END LOOP; -- Loop itens
          END IF; -- Se existe itens
        END IF; -- Não ocorreu erro na inclusão do log
        
      END IF;
      
      --
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se tem nome de arquivo
        IF vr_nmarqtxt IS NOT NULL THEN
          -- Gravar o registro de log do arquivo - Erro na geração do arquivo
          COBR0011.pc_gera_log_iptb(pr_nmarquiv => vr_nmarqtxt
                                   ,pr_dtarquiv => vr_dtmvtolt
                                   ,pr_qtregarq => 0
                                   ,pr_idfrmprc => 2 -- Automático
                                   ,pr_cdoperad => '1' 
                                   ,pr_dserrarq => 'Erro ao gerar arquivo cancelamento: '||pr_dscritic
                                   ,pr_cdsituac => 2
                                   ,pr_idlogarq => vr_idlogarq
                                   ,pr_dscritic => vr_dscrilog); -- Não parar o processo em caso de erro no log
          
          -- Se apresentar erro
          IF vr_dscrilog IS NOT NULL THEN 
            -- Incluído controle de Log, mas sem afetar o processamento
            pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_cancelamento --> Erro ao gravar log:' || vr_dscrilog);  
          END IF;

        END IF;   
        
        -- Incluído controle de Log
        --pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_cancelamento --> ' || rw_craprem.cdcooper || '/' || rw_craprem.nrdconta || '/' || rw_craprem.nrcnvcob || '/' || rw_craprem.nrdocmto || ' não processado devido ao ERRO: ' || pr_dscritic);
        
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
        -- Incluído controle de Log
        --pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_cancelamento --> ' || rw_craprem.cdcooper || '/' || rw_craprem.nrdconta || '/' || rw_craprem.nrcnvcob || '/' || rw_craprem.nrdocmto || ' não processado devido ao ERRO: ' || SQLERRM);
        pr_dscritic := SQLERRM;
        
        -- Se tem nome de arquivo
        IF vr_nmarqtxt IS NOT NULL THEN
          -- Gravar o registro de log do arquivo - Erro na geração do arquivo
          COBR0011.pc_gera_log_iptb(pr_nmarquiv => vr_nmarqtxt
                                   ,pr_dtarquiv => vr_dtmvtolt
                                   ,pr_qtregarq => 0
                                   ,pr_idfrmprc => 2 -- Automático
                                   ,pr_cdoperad => '1' 
                                   ,pr_dserrarq => 'Erro ao gerar arquivo cancelamento: '||pr_dscritic
                                   ,pr_cdsituac => 2
                                   ,pr_idlogarq => vr_idlogarq
                                   ,pr_dscritic => vr_dscrilog); -- Não parar o processo em caso de erro no log
          
          -- Se apresentar erro
          IF vr_dscrilog IS NOT NULL THEN 
            -- Incluído controle de Log, mas sem afetar o processamento
            pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_gera_arquivo_cancelamento --> Erro ao gravar log:' || vr_dscrilog);  
          END IF;


        END IF;
        
    END pc_gera_cancelamento_ieptb;
    --
    PROCEDURE pc_insere_valor_response(pr_nrattrib  IN      NUMBER
                             ,pr_dsvalue   IN      CLOB
                             ,pr_reg_linha IN OUT  typ_reg_linha_response
                             ,pr_cdcritic  OUT     NUMBER
                             ,pr_dscritic  OUT     VARCHAR2
                             ) IS
    /* ..........................................................................
      
    Procedure: pc_insere_valor_response
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Autor    : Jose Dill (Mouts)
    Data     : Marco/2021                        Ultima atualizacao: 
      
    Dados referentes ao programa:
      
    Frequencia: Sempre que for chamado
    Objetivo  : Gravar as informações do arquivo response numa estrutura temporária
      
    Alteracoes: 
    ............................................................................. */
    BEGIN
      -- Posiciona procedure - 09/11/2018 - SCTASK0034650
      vr_cdproint := vr_cdprogra_cpl || '.pc_insere_valor_response';
      -- Inclusão do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      -- Inicializa retorno
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
      --
      CASE
        WHEN pr_nrattrib = 0 THEN
          pr_reg_linha.municipio := pr_dsvalue;
        WHEN pr_nrattrib = 1 THEN
          pr_reg_linha.codigo := pr_dsvalue;
        WHEN pr_nrattrib = 2 THEN
          pr_reg_linha.descricao := pr_dsvalue;
        WHEN pr_nrattrib = 3 THEN
          pr_reg_linha.uf := pr_dsvalue;
          
      END CASE;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log
        cecred.pc_internal_exception(pr_cdcooper => 3);    
        -- Monta mensagem
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       vr_cdproint ||
                       '. ' || SQLERRM ||
                       '. pr_nrattrib:' || pr_nrattrib ||
                       ', pr_dsvalue:'  || pr_dsvalue;                   
    END pc_insere_valor_response;
    

    PROCEDURE pc_insere_registro_response(pr_dsdireto IN  VARCHAR2
                                ,pr_dsarquiv IN  VARCHAR2
                                ,pr_cdcritic OUT NUMBER
                                ,pr_dscritic OUT VARCHAR2
                                ) IS
    /* ..........................................................................
      
    Procedure: pc_insere_registro_response
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Autor    : Jose Dill (Mouts)
    Data     : Marco/2021                        Ultima atualizacao: 
      
    Dados referentes ao programa:
      
    Frequencia: Sempre que for chamado
    Objetivo  : Ler o arquivo XML e gravar os registros do arquivo response
      
    Alteracoes: 
    ............................................................................. */
      --
      p   xmlparser.parser;
      doc xmldom.DOMDocument;
      --
      nl       xmldom.DOMNodeList;
      len1     NUMBER;
      len2     NUMBER;
      n        xmldom.DOMNode;
      n2       xmldom.DOMNode;
      e        xmldom.DOMElement;
      nnm      xmldom.DOMNamedNodeMap;
      attrname VARCHAR2(4000);
      attrval  VARCHAR2(4000);
      --
      vr_reg_linha_response typ_reg_linha_response;
      -- Trata os erros específicos dentro da procedure - 09/11/2018 - SCTASK0034650
      vr_cdcritic crapcri.cdcritic%TYPE := NULL;
      vr_dscritic VARCHAR2(4000) := NULL;
      vr_exc_erro EXCEPTION;
      -- CLOB para o arquivo
      vr_arquivo_clob CLOB;
      vr_oracle_dir varchar2(128);
    BEGIN
      -- Posiciona procedure - 09/11/2018 - SCTASK0034650
      vr_cdproint := vr_cdprogra_cpl || '.pc_insere_registro_response';
      -- Inclusão do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      -- Inicializa retorno
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
      
      -- new parser
      p := xmlparser.newParser;
      
      --seta o diretorio do oralce
      vr_oracle_dir:= sistema.obternomedirectory(pr_dsdireto);
      
      -- set some characteristics
      xmlparser.setValidationMode(p, FALSE);
      xmlparser.setBaseDir(p, vr_oracle_dir);

      -- Trata problema de arquivo - 09/11/2018 - SCTASK0034650
      IF pr_dsdireto IS NULL OR pr_dsarquiv IS NULL THEN
        vr_cdcritic := 1048;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);      
        RAISE vr_exc_erro;
      END IF;
      
      BEGIN
        vr_arquivo_clob := COBRANCA.obterArqClobIeptb(pr_dsdireto, pr_dsarquiv);      
        xmlparser.parseClob(p, vr_arquivo_clob);
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log
          cecred.pc_internal_exception(pr_cdcooper => 3);    
          -- Monta mensagem
          vr_cdcritic := 1038; -- Erro ao abrir o arquivo
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         vr_cdproint ||
                         '. ' || SQLERRM ||
                         '. xmlparser.parse' ||
                         ', pr_dsdireto:' || pr_dsdireto || 
                         ', pr_dsarquiv:' || pr_dsarquiv; 
          --
          pc_controla_log_batch(pr_idtiplog => 1
                               ,pr_dscritic => vr_dscritic);
          --
          RAISE vr_exc_erro;      
      END;

      -- get document
      doc := xmlparser.getDocument(p);

      -- Get document element attributes
      -- get all elements
      nl := xmldom.getElementsByTagName(doc, '*');
      len1 := xmldom.getLength(nl);
      
      -- loop through elements
      FOR j in 0..len1-1 LOOP
        --
        vr_reg_linha_response := NULL;
        --
        n := xmldom.item(nl, j);
        e := xmldom.makeElement(n);
        
        -- get all attributes of element
        nnm := xmldom.getAttributes(n);
        --
        IF (xmldom.isNull(nnm) = FALSE) THEN
          --
          IF xmldom.getNodeName(n) = 'mensagem' THEN
            --
            len2 := xmldom.getLength(nnm);
            -- loop through attributes
            FOR i IN 0..len2-1 LOOP
              --
              n2 := xmldom.item(nnm, i);
              attrname := xmldom.getNodeName(n2);
              attrval := xmldom.getNodeValue(n2);
              --
              pc_insere_valor_response(pr_nrattrib  => i   -- IN
                             ,pr_dsvalue   => attrval      -- IN
                             ,pr_reg_linha => vr_reg_linha_response -- IN OUT
                             ,pr_cdcritic  => vr_cdcritic  -- OUT
                             ,pr_dscritic  => vr_dscritic  -- OUT
                             );
              IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
              -- Retorna módulo e ação logado
              GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
              --
              dbms_lob.createtemporary(vr_texto, TRUE);
              dbms_lob.OPEN(vr_texto,dbms_lob.lob_readwrite);
              --
              xmldom.writeToClob(n,vr_texto);
              --
            END LOOP;
            --
            vr_tab_arquivo_response(vr_tab_arquivo_response.count()) := vr_reg_linha_response;
            --
          END IF;
          --
        END IF;
        --
      END LOOP;

    EXCEPTION
      -- Eliminada exceções por não cair nelas, e também não haver necessidade - 09/11/2018 - SCTASK0034650
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic);   
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log
        cecred.pc_internal_exception(pr_cdcooper => 3);    
        -- Monta mensagem
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       vr_cdproint ||
                       '. ' || SQLERRM;                  
      --
    END pc_insere_registro_response;

    PROCEDURE pc_carrega_arquivo_response(pr_cdcooper IN  crapcop.cdcooper%TYPE
                                        ,pr_cdcritic OUT NUMBER
                                        ,pr_dscritic OUT VARCHAR2
                                        ) 
    IS
    /* ..........................................................................
      
    Procedure: pc_carrega_arquivo_response
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Autor    : Jose Dill (Mouts)
    Data     : Marco/2021
      
    Dados referentes ao programa:
      
    Frequencia: Sempre que for chamado
    Objetivo  : Carrega arquivo response do retorno (IEPTB_CECRED_B085MMDD.AA1_xxx.RET)
      
    ............................................................................. */
      vr_tab_response TYP_SIMPLESTRINGARRAY := TYP_SIMPLESTRINGARRAY();
      vr_pesq            VARCHAR2(500)         := NULL;
      vr_dsdireto        VARCHAR2(500);

      vr_exc_erro        EXCEPTION;
      --
    BEGIN
        
      vr_cdproint := vr_cdprogra_cpl || '.pc_carrega_arquivo_response';
      --
      pc_controla_log_batch(1, 'Início - '||vr_cdproint);
      -- 
      -- Inclusão do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      -- Inicializa retorno
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
      --
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => 3);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;    
      --    
      vr_dsdireto := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'DIR_IEPTB_RESPOSTA'
                                              );
      -- Buscar arquivos de response do dia atual
      vr_pesq := 'IEPTB_CECRED_B085'||to_char(rw_crapdat.dtmvtolt,'ddmm')||'%.%';

      -- Buscar a lista de arquivos do diretorio
      gene0001.pc_lista_arquivos(pr_lista_arquivo => vr_tab_response
                                ,pr_path          => vr_dsdireto
                                ,pr_pesq          => vr_pesq
                                );
      IF vr_tab_response.COUNT() > 0 THEN
        --
        FOR idx IN 1..vr_tab_response.COUNT() LOOP
          --
          IF vr_tab_response(idx) = '2-Erro: java.lang.NullPointerException' THEN
            vr_cdcritic := 1053;
            vr_dscritic := vr_cdproint   || 
                           '  vr_dsdireto:' || vr_dsdireto ||
                           ', vr_pesq:'     || vr_pesq     ||
                           ', pr_dsarquiv:' || vr_tab_response(idx) ||
                           ', idx:'         || idx;
            --
            pc_controla_log_batch(pr_idtiplog => 1
                                 ,pr_dscritic => vr_dscritic);
            vr_cdcritic := NULL;
            vr_dscritic := NULL;
          ELSE
            -- Gravar informações do arquivo response num estrutura temporária
            pc_insere_registro_response(pr_dsdireto => vr_dsdireto      -- IN
                                ,pr_dsarquiv => vr_tab_response(idx)    -- IN
                                ,pr_cdcritic => vr_cdcritic             -- OUT
                                ,pr_dscritic => vr_dscritic             -- OUT
                              );
            -- Se retornou erro
            IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              IF vr_cdcritic = 1038 THEN
                vr_cdcritic := NULL;
                vr_dscritic := NULL;
              ELSE
                 RAISE vr_exc_erro;
              END IF;
            END IF;
            -- Retorna módulo e ação logado
            GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
            --
          END IF;
          --
        END LOOP;
        --
      ELSE
        vr_cdcritic := 239;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                       vr_cdproint|| ' (1) - '   ||       
                       '  vr_dsdireto:' || vr_dsdireto ||
                       ', vr_pesq:'     || vr_pesq;
        --               
        pc_controla_log_batch(pr_idtiplog => 1
                             ,pr_dscritic => vr_dscritic);
        --                     
        vr_cdcritic := NULL;
        vr_dscritic := NULL;
      END IF;
      --
    EXCEPTION
      -- Tratado erro para não parar o processo 
      WHEN vr_exc_erro THEN     
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic);   
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log
        cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);    
        -- Monta mensagem
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       vr_cdproint ||
                       '. ' || SQLERRM;    
    END pc_carrega_arquivo_response;

    -- 
    PROCEDURE pc_processa_response(pr_cdcooper IN  crapcop.cdcooper%TYPE
                                     ,pr_cdcritic OUT NUMBER
                                     ,pr_dscritic OUT VARCHAR2
                                     ) IS
    /* ..........................................................................
      
    Procedure: pc_processa_response
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Autor    : Jose Dill (Mouts)
    Data     : Marco/2021                        Ultima atualizacao: 
      
    Dados referentes ao programa:
      
    Frequencia: Sempre que for chamado
    Objetivo  : Verificar se alguma comarca esta bloqueada, e retirar a situação de remessa para cartório do título, 
                caso a mesma esteja bloqueada
      
    Alteracoes: 
    ............................................................................. */
      --
      vr_index_comarca NUMBER  := 0;
      vr_nrretcoo NUMBER := 0;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2 (4000);
      --
    BEGIN
      -- Posiciona procedure - 09/11/2018 - SCTASK0034650
      vr_cdproint := vr_cdprogra_cpl || '.pc_processa_response';
      -- Inclusão do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      -- Inicializa retorno
      pr_cdcritic := NULL;
      pr_dscritic := NULL;    
      --
      IF vr_tab_arquivo_response.count() > 0 THEN
        --
        WHILE vr_index_comarca IS NOT NULL LOOP
          --
          IF vr_tab_arquivo_response(vr_index_comarca).codigo = '1003' THEN
            --
            FOR rw_bolpro in (SELECT DISTINCT    
                                 crapcob.cdcooper
                                ,crapcob.nrcnvcob
                                ,crapcop.cdbcoctl
                                ,rpad(crapcop.cdagectl, 6, ' ') cdagectl 
                                ,crapcob.nrdconta nrctalog 
                                ,crapcob.nrdocmto 
                                ,crapcob.rowid
                                ,crapcob.dtmvtolt
                              FROM craprem
                                  ,crapcob
                                  ,crapdat
                                  ,crapban
                                  ,crapcop
                                  ,crapass
                                  ,crapenc
                                  ,crapsab
                                  ,crapmun
                                  ,crapmun comarca
                                  ,crapcco
                                  ,crapcre
                                  ,crapdne
                              WHERE crapcco.cdcooper > 0
                              AND crapcco.cddbanco = 85
                              AND crapcre.cdcooper = crapcco.cdcooper
                              AND crapcre.nrcnvcob = crapcco.nrconven
                              AND crapcre.dtmvtolt = rw_crapdat.dtmvtolt
                              AND crapcre.intipmvt = 1
                              AND craprem.cdcooper = crapcre.cdcooper
                              AND craprem.nrcnvcob = crapcre.nrcnvcob
                              AND craprem.nrremret = crapcre.nrremret
                              AND crapcob.cdcooper = craprem.cdcooper
                              AND crapcob.nrdconta = craprem.nrdconta
                              AND crapcob.nrcnvcob = craprem.nrcnvcob
                              AND crapcob.nrdocmto = craprem.nrdocmto
                              AND crapdat.cdcooper = crapcob.cdcooper
                              AND crapban.cdbccxlt = crapcob.cdbandoc
                              AND crapcop.cdcooper = crapcob.cdcooper
                              AND crapass.nrdconta = crapcob.nrdconta
                              AND crapass.cdcooper = crapcob.cdcooper
                              AND crapenc.cdcooper = crapass.cdcooper
                              AND crapenc.nrdconta = crapass.nrdconta
                              AND crapenc.tpendass = 9 -- Comercial
                              AND crapenc.idseqttl = 1
                              AND crapsab.cdcooper = crapcob.cdcooper
                              AND crapsab.nrdconta = crapcob.nrdconta
                              AND crapsab.nrinssac = crapcob.nrinssac
                              AND crapdne.nrceplog = crapsab.nrcepsac
                              AND crapdne.idoricad = 1 -- CEP dos correios
                              AND LPAD(crapmun.cdufibge, 2, '0') || LPAD(crapmun.cdcidbge, 5, '0') = crapdne.cdcidibge
                              AND LPAD(comarca.cdufibge, 2, '0') || LPAD(comarca.cdcidbge, 5, '0') = crapmun.cdcomarc
                              AND crapcob.cdbandoc = 85
                              AND crapcob.insrvprt = 1
                              AND crapcob.insitcrt = 2 -- Enviado pra cartorio
                              AND craprem.cdocorre = 9 -- Somente boletos c/ instrução de protesto
                              AND crapmun.cdcomarc = vr_tab_arquivo_response(vr_index_comarca).municipio  /*Comarca com bloqueio*/
                              )
              LOOP
                --
                cobr0011.pc_proc_devolucao(pr_idtabcob      => rw_bolpro.rowid                      -- IN
                                          ,pr_cdbanpag     => rw_bolpro.cdbcoctl                   -- IN
                                          ,pr_cdagepag     => rw_bolpro.cdagectl                   -- IN
                                          ,pr_dtocorre     => rw_bolpro.dtmvtolt                   -- IN
                                          ,pr_cdocorre     => 89                                    -- IN
                                          ,pr_dsmotivo     => '98'                                  -- IN
                                          ,pr_crapdat      => rw_crapdat                            -- IN
                                          ,pr_cdoperad     => '1'                                   -- IN
                                          ,pr_vltarifa     => 0                                     -- IN
                                          ,pr_ret_nrremret => vr_nrretcoo                           -- OUT
                                          ,pr_cdcritic     => vr_cdcritic                           -- OUT
                                          ,pr_dscritic     => vr_dscritic                           -- OUT
                                          );
                IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                      vr_cdcritic := 0;
                      vr_dscritic := NULL;
                END IF;      
            END LOOP;  
          END IF;  
          -- Próximo registro
          vr_index_comarca := vr_tab_arquivo_response.next(vr_index_comarca);
          --
        END LOOP;
        --
      END IF;
      --
          pc_controla_log_batch(1, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729.pc_processa_response --> Finalizado o processamento do reponse.'); -- Texto para escrita
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log
        cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);    
        -- Monta mensagem
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       vr_cdproint ||
                       '. ' || SQLERRM ||
                       '. pr_cdcooper:' || pr_cdcooper; 
    END pc_processa_response;


  BEGIN

    -- Executar apenas em dias úteis na Central
    -- Executar no ultimo dia do ano - caso seja dia util
    vr_dtmvutil := gene0005.fn_valida_dia_util(pr_cdcooper => 3,
                                               pr_dtmvtolt => TRUNC(SYSDATE) + 1,
                                               pr_tipo => 'P',
                                               pr_excultdia => TRUE);


    -- Incluido controle de Log inicio programa
    pc_controla_log_batch(1, 'Início crps729');
    --
    pc_gera_remessa(pr_dscritic => pr_dscritic -- OUT
                   );
    --
    IF pr_dscritic IS NOT NULL THEN
      --
      RAISE vr_exc_erro;
      --
    END IF;


    --
    pc_gera_arquivo_remessa(pr_dscritic => pr_dscritic -- OUT
                           );
    IF pr_dscritic IS NOT NULL THEN
      --
      RAISE vr_exc_erro;
      --
    END IF;
    --
    pc_gera_desistencia(pr_dscritic => pr_dscritic -- OUT
                       );
    --
    IF pr_dscritic IS NOT NULL THEN
      --
      RAISE vr_exc_erro;
      --
    END IF;
    --
    pc_gera_arquivo_desistencia(pr_dscritic => pr_dscritic -- OUT
                               );
    --
    IF pr_dscritic IS NOT NULL THEN
      --
      RAISE vr_exc_erro;
      --
    END IF;

    -- Geracao do novo layout do arquivo de cancelamento
    pc_gera_cancelamento_ieptb(pr_dscritic => pr_dscritic -- OUT
                              );
    --
    IF pr_dscritic IS NOT NULL THEN
      --
      RAISE vr_exc_erro;
      --
    END IF;

    -- Escrever o log no arquivo
    pc_controla_log_batch(1, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729 --> Finalizado o processamento das remessas.'); -- Texto para escrita
    --
    COMMIT;
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Incluído controle de Log
      pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729 --> ' || pr_dscritic);
      ROLLBACK;
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'INC0208803');
      -- Incluído controle de Log
      pr_dscritic := SQLERRM;
      pc_controla_log_batch(2, to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - pc_crps729 --> ' || SQLERRM);
      ROLLBACK;
    --
  END pc_crps729p;
BEGIN
  -- Test statements here
  pc_crps729p(pr_dscritic => vr_dscritic);
END;
