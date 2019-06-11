CREATE OR REPLACE PACKAGE CECRED.APLI0007 AS
       
  -- ------------------------------------------------------------------------------------
  -- Programa: APLI0007
  -- Sistema : Conta-Corrente - Cooperativa de Credito
  -- Sigla   : CRED
  -- 
  -- Autor   : Marcos - Envolti
  -- Data    : Março/2018                       Ultima atualizacao: 03/04/2019
  -- 
  -- Dados referentes ao programa:
  -- 
  -- Frequencia: On-line
  -- Objetivo  : Manter as rotinas específica do processo de Captação e
  --             Custódia das Aplicações junto ao B3
  -- 
  -- Alterações: 21/09/2018 - Ajuste na query da pc_gera_arquivos_envio, incluindo novo índice
  --                        - Alterar nome dos arquivos de conciliação recebidos da B3, incluindo
  --                          o horário no final do nome, pois os nomes não são únicos e ocorria 
  --                          perda de arquivos
  --                        - Remover o tempo de espera para o envio dos arquivos gerados. Passa
  --                          a considerar como processados os arquivos quando são colocados na 
  --                          pasta envia. (Daniel - Envolti)
  --
  -- Alterações: 05/03/2019 - P411 
  --				          Ajuste Calculo da quantidade de cotas referente a operação atual
  --						  alterado para compatibilizar com a B3;							  
  --						  REGRA ANTIGA -> vr_qtcotas_resg := trunc(rw_lcto.vllanmto / vr_vlpreco_unit);
  --						  REGRA NOVA   -> vr_qtcotas_resg := fn_converte_valor_em_cota(rw_lcto.valorbase);						  
  --                        - (David Valente - Envolti)
  --
  --             03/04/2019 - Projeto 411 - Fase 2 - Parte 2 - Conciliação Despesa B3 e Outros Detalhes
  --                          Procedimento para tratar custo fornecedor aplicação - B3 
  --                          Ajusta mensagens de erros e trata de forma a permitir a monitoração automatica.
  --                          Procedimento de Log - tabela: tbgen prglog ocorrencia 
  --                         (Envolti - Belli - PJ411_F2_P2)
  --
  -- ----------------------------------------------------------------------------------- 
  
  -- Retornar tipo da Aplicação enviada
  FUNCTION fn_tip_aplica(pr_cdcooper IN NUMBER
                        ,pr_tpaplica IN NUMBER
                        ,pr_nrdconta IN NUMBER
                        ,pr_nraplica IN NUMBER) RETURN VARCHAR2;
                       
    -- Retornar true caso a aplicação esteja em carencia
  FUNCTION fn_tem_carencia(pr_dtmvtapl crapdat.dtmvtolt%type
                          ,pr_qtdiacar craprac.qtdiacar%TYPE
                          ,pr_dtmvtres crapdat.dtmvtolt%TYPE) RETURN VARCHAR2;      
  
  -- Função para mostrar a descrição conforme o tipo do Arquivo enviado 
  FUNCTION fn_tparquivo_custodia(pr_idtipo_arquivo IN NUMBER        -- Tipo do Arquivo (1-Registro,2-Resgate,3-Exclusão,9-Conciliação)
                                ,pr_idtipo_retorno IN VARCHAR2)     -- Tipo do Retorno (A-Abreviado ou E-Extenso)
                               RETURN VARCHAR2;
  
  -- Função para mostrar a descrição conforme o tipo lancto enviado
  FUNCTION fn_tpregistro_custodia(pr_idtipo_lancto  IN NUMBER    -- Tipo do Registro
                                 ,pr_idtipo_retorno IN VARCHAR2) -- Tipo do Retorno (A-Abreviado ou E-Extenso)
                          RETURN VARCHAR2;  
                          
  -- Rotina para processar retorno de conciliação pendentes de processamento
  PROCEDURE pc_processo_controle(pr_tipexec   IN NUMBER     --> Tipo da Execução
                                ,pr_dsinform OUT CLOB   --> Descrição de informativos na execução
                                ,pr_dscritic OUT VARCHAR2); --> Descrição de critica

  -- Procedimento de Log - tabela: tbgen prglog ocorrencia - 03/04/2019 - PJ411_F2_P2
  PROCEDURE pc_log(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                  ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                  ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                  ,pr_tpexecuc IN NUMBER   DEFAULT 0   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                  ,pr_dscrilog IN VARCHAR2 DEFAULT NULL
                  ,pr_cdcritic IN NUMBER   DEFAULT NULL
                  ,pr_nmrotina IN VARCHAR2 DEFAULT NULL -- Null assume nome da Package
                  ,pr_cdcooper IN VARCHAR2 DEFAULT 0
                  );

  -- Procedimento para tratar custo fornecedor aplicação - B3 - 03/04/2019 - PJ411_F2_P2
  PROCEDURE pc_trt_cst_frn_aplica(pr_cdmodulo IN VARCHAR2           -- Cooperativa selecionada (0 para todas)
                                 ,pr_cdcooper IN crapcop.cdcooper%TYPE -- Cooperativa selecionada (0 para todas)
                                 ,pr_nrdconta IN VARCHAR2           -- Conta informada
                                 ,pr_dtde     IN VARCHAR2           -- Data de 
                                 ,pr_dtate    IN VARCHAR2           -- Date até
                                 ,pr_tpproces IN NUMBER             -- Tipo: 1 - Gera, 2 - Consulta, 3 - Caminho CSV
                                 ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                 ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2          -- Saida OK/NOK 
                                 );

  -- Executa geração do custo fornecedor aplicação - B3
  PROCEDURE pc_exe_grc_cst_frn_aplica(pr_cdmodulo IN VARCHAR2           -- Cooperativa selecionada (0 para todas)
                                     ,pr_cdcooper IN crapcop.cdcooper%TYPE -- Cooperativa selecionada (0 para todas)
                                     ,pr_nrdconta IN VARCHAR2           -- Conta informada
                                     ,pr_dtde     IN VARCHAR2           -- Data de 
                                     ,pr_dtate    IN VARCHAR2           -- Date até
                                     );
                                                                              
  -- Trata a tabela de parâmetro de custo de investidor para de conciliação - 01/04/2019 - PJ411_F2
  PROCEDURE pc_conciliacao_tab_investidor
    (pr_nmmodulo IN VARCHAR2
    ,pr_cdcooper IN crapcop.cdcooper%TYPE
    ,pr_qttabinv OUT NUMBER
    ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
    ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
    );

  -- Trata a tabela de parâmetro de custo de investidor para de conciliação
  PROCEDURE pc_pos_faixa_tab_investidor
    (pr_nmmodulo IN VARCHAR2
    ,pr_cdcooper IN crapcop.cdcooper%TYPE
    ,pr_qttabinv IN NUMBER
    ,pr_vlentrad IN NUMBER
    ,pr_idasitua OUT NUMBER
    ,pr_pctaxmen OUT NUMBER
    ,pr_vladicio OUT NUMBER
    ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
    ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
    );

  -- 
  PROCEDURE pc_concil_tab_investidor(pr_cdmodulo IN VARCHAR2           -- Tela e qual consulta, 48 caractere
                                 ,pr_cdcooper IN crapcop.cdcooper%TYPE  -- Cooperativa selecionada (0 para todas)
                                 ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                 ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2          -- Saida OK/NOK 
                                 );
    
  -- Atualiza tabela investidor
  PROCEDURE pc_atz_faixa_tab_investidor(--pr_cdmodulo IN VARCHAR2           -- Tela e qual consulta, 48 caractere
                                       --,pr_cdcooper IN crapcop.cdcooper%TYPE  -- Cooperativa selecionada (0 para todas)
                                        pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                       ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2          -- Saida OK/NOK 
                                       );

               
END APLI0007;
/
CREATE OR REPLACE PACKAGE BODY CECRED.APLI0007 AS

  -- Constantes
  vr_nomdojob CONSTANT VARCHAR2(30) := 'JBCAPT_CUSTOD_B3';     -- Nome do JOB
  vr_nmsimplf CONSTANT VARCHAR2(20) := RPAD('CECRED',20,' '); -- Nome Simplificado do Participante
  -- Troca diretorio de 1 para 3 porque o executor é a coooper central - 03/04/2019 - PJ411_F2_P2
  vr_dsdirarq CONSTANT VARCHAR2(30) := gene0001.fn_diretorio('C',3,'arq'); -- Diretório temporário para arquivos
  vr_qtdexjob CONSTANT NUMBER(5)    := 500; -- Quantidade de arquivos enviados / recebidos por execução
  -- Pastas Padrão Connect Direct
  vr_dsdirenv CONSTANT VARCHAR2(30) := 'envia';
  vr_dsdirevd CONSTANT VARCHAR2(30) := 'enviados';
  vr_dsdirrec CONSTANT VARCHAR2(30) := 'recebe';
  vr_dsdirrcb CONSTANT VARCHAR2(30) := 'recebidos';
  -- Caracteres de Quebra
  vr_dscarque CONSTANT VARCHAR2(30) := chr(10)||chr(13);  --- Quebra arquivo Texto e tela VERLOG caracter
  vr_dstagque CONSTANT VARCHAR2(30) := '<br><br>';        --- Quebra HTML E-MAIL
  vr_dsfimlin CONSTANT VARCHAR2(01) := '<';
  -- Fator conversão R$ X Cota Unitária
  vr_qtftcota CONSTANT  NUMBER(3,2) := 0.01; -- Cada cota = R$0,01 (1 Centavo)
  -- Variavel para setar pck e e-mail de criticas - 03/04/2019 - PJ411_F2
  vr_nmpackge CONSTANT  VARCHAR2(10) := 'APLI0007';
  vr_dsacseml CONSTANT  VARCHAR2(30) := 'DES_EMAILS_PROC_B3';

  -- Tratamento de criticas
  vr_idcritic  NUMBER;
  vr_cdcritic  NUMBER;
  vr_dscritic  VARCHAR2(32767);
  vr_des_reto  VARCHAR2(3);
  vr_tab_erro  cecred.gene0001.typ_tab_erro;
  -- Variavel para setar parametro para log - 03/04/2019 - PJ411_F2
  vr_nmaction  VARCHAR2    (32) := vr_nmpackge || '.pc_nao_definida';
  vr_dsparame  VARCHAR2  (4000) := NULL;
  vr_ctcritic    NUMBER       (9) := 0;
  vr_ctmensag    NUMBER       (9) := 0;
  vr_ctreg_ok    NUMBER       (9) := 0;
  vr_ctcri_ant   NUMBER       (9) := 0;
  vr_ctcri_fase  NUMBER       (9) := 0;           
  vr_intipexe  NUMBER       (2);
  vr_dslisane  VARCHAR2  (4000);
  vr_dslinha   VARCHAR2  (4000);
  -- Variaveis para e-mail
  vr_cdcooper  NUMBER       (2) := 0;
  vr_dsemldst  VARCHAR2  (4000) := NULL;
  vr_dsassunt  VARCHAR2  (4000) := NULL;
  vr_dscorpo   VARCHAR2 (32700) := NULL;
  --
  vr_fgtempro  BOOLEAN := FALSE;
  --
  vr_inabr_arq_cri_pro_con BOOLEAN      := false;
  vr_inabr_arq_msg_pro_con BOOLEAN      := false;
  vr_inabr_arq_cri_exe_cus BOOLEAN      := false;
  vr_inabr_arq_csv_exe_cus BOOLEAN      := false; 
  --
  vr_nmarq001_msg     VARCHAR2    (100);
  vr_nmdir001_msg     VARCHAR2    (100);
  vr_nmtip001_msg     VARCHAR2      (5);
  vr_dshan001_msg     utl_file.file_type; 
  --
  vr_nmarq001_critic  VARCHAR2    (100);
  vr_nmdir001_critic  VARCHAR2    (100);
  vr_nmtip001_critic  VARCHAR2      (5);
  vr_dshan001_critic  utl_file.file_type;  
  --
  vr_nmarq001_csv     VARCHAR2    (100);
  vr_nmdir001_csv     VARCHAR2    (100);
  vr_nmtip001_csv     VARCHAR2      (5);
  vr_dshan001_csv     utl_file.file_type; 
  --
  vr_nmarq001_html   VARCHAR2    (100);
  vr_nmdir001_html   VARCHAR2    (100);
  --
  vr_inconcil        VARCHAR2      (1); -- Indica que o processo é conciliação 
  vr_dspro001        VARCHAR2(4000) := 'Retorno da Conciliação da B3';
  vr_dspro001_E      VARCHAR2(4000) := 'Iniciando Proc. Integração de Arquivos Conciliação Devolvidos pela B3.';
  vr_dspro002        VARCHAR2(4000) := 'Envio dos Lançamentos a B3';
  vr_dspro002_E      VARCHAR2(4000) := 'Iniciando Proc. Busca de Eventos para Criação de Registros e Operações a enviar.';
  vr_dspro003        VARCHAR2(4000) := 'Retorno dos Lançamentos da B3';
  vr_dspro003_E      VARCHAR2(4000) := 'Iniciando Proc. Integração de Arquivos de Retorno Devolvidos pela B3.';  
  vr_dspro004        VARCHAR2(4000) := 'Iniciando Proc. Monitoramento do recebimento de arquivos de retorno da B3';
  --
  vr_dspro005_E      VARCHAR2(4000) := 'Iniciando Checagem de Arquivos Compactados Devolvidos pela B3.';  
  vr_dspro006_E      VARCHAR2(4000) := 'Iniciando Checagem de Arquivos Devolvidos pela B3.';
  vr_dspro007_E      VARCHAR2(4000) := 'Iniciando Proc. Envio de Arquivos A B3.';
  vr_dspro008_E      VARCHAR2(4000) := 'Iniciando Proc. Agrupamento de Registros para criação de Arquivos a Enviar.';
      
  -- Type criado para garantir a performance - 01/04/2019 - PJ411_F2
  TYPE typ_reg_tabinv IS
        RECORD(idfrninv  tbcapt_custodia_frn_investidor.idfrninv%TYPE
              ,vlfaixde  tbcapt_custodia_frn_investidor.vlfaixade%TYPE
              ,vlfaixate tbcapt_custodia_frn_investidor.vlfaixaate%TYPE
              ,pctaxmen  tbcapt_custodia_frn_investidor.petaxa_mensal%TYPE
              ,vladicio  tbcapt_custodia_frn_investidor.vladicional%TYPE
              );
              
  -- Type criado para garantir a performance - 01/04/2019 - PJ411_F2
  TYPE typ_tab_tabinv IS TABLE OF typ_reg_tabinv INDEX BY VARCHAR2(40);  
  vr_tab_tabinv  typ_tab_tabinv;  

  -- Type criado para acumular valores por dia e melhorar a performance
  TYPE typ_reg_diavlr IS
        RECORD(dtdiaapl NUMBER (8)
              ,vlacudia NUMBER(25,9)
              );              
  TYPE typ_tab_diavlr IS TABLE OF typ_reg_diavlr INDEX BY VARCHAR2(8);  
  vr_tab_diavlr  typ_tab_diavlr;
  


  -- Type criado para garantir a performance - 01/04/2019 - PJ411_F2
  TYPE typ_reg_novtabinv IS
        RECORD(idfrninv  tbcapt_custodia_frn_investidor.idfrninv%TYPE
              ,vlfaixde  tbcapt_custodia_frn_investidor.vlfaixade%TYPE
              ,vlfaixate tbcapt_custodia_frn_investidor.vlfaixaate%TYPE
              ,pctaxmen  tbcapt_custodia_frn_investidor.petaxa_mensal%TYPE
              ,vladicio  tbcapt_custodia_frn_investidor.vladicional%TYPE
              );
              
  -- Type criado para garantir a performance - 01/04/2019 - PJ411_F2
  TYPE typ_tab_novtabinv IS TABLE OF typ_reg_novtabinv INDEX BY VARCHAR2(40);  
  vr_tab_novtabinv  typ_tab_novtabinv;  

  -- Variaveis gerais - 01/04/2019 - PJ411_F2
  vr_dtdiaapl     NUMBER (8);
  vr_vlacudia     NUMBER(25,9);
  vr_dtini        NUMBER (8);
  vr_dtfim        NUMBER (8);
  --
  vr_cdacesso     crapprm.cdacesso%TYPE;
  vr_qtmaxreq     NUMBER (9);
  vr_infimarq_1   VARCHAR2(1);
  vr_fglaberto_1  BOOLEAN;
  vr_infimarq_2   VARCHAR2(1);
  vr_fglaberto_2  BOOLEAN;
  
  -- Retornar tipo da Aplicação enviada
  FUNCTION fn_tip_aplica(pr_cdcooper IN NUMBER
                        ,pr_tpaplica IN NUMBER
                        ,pr_nrdconta IN NUMBER
                        ,pr_nraplica IN NUMBER) RETURN VARCHAR2 IS
    -- Para aplicações de Captação
    CURSOR cr_craprac IS
      SELECT cpc.nmprodut
        FROM crapind ind
            ,crapcpc cpc
            ,craprac rac
       WHERE cpc.cddindex = ind.cddindex
         AND cpc.cdprodut = rac.cdprodut
         AND rac.cdcooper = pr_cdcooper
         AND rac.nrdconta = pr_nrdconta
         AND rac.nraplica = pr_nraplica;
    vr_nmprodut crapcpc.nmprodut%TYPE;
    -- Para aplicações RDA
    CURSOR cr_craprda IS
      SELECT dtc.dsaplica
        FROM craprda rda
            ,crapdtc dtc
       WHERE rda.cdcooper = dtc.cdcooper
         AND rda.tpaplica = dtc.tpaplica
         AND rda.cdcooper = pr_cdcooper
         AND rda.nrdconta = pr_nrdconta
         AND rda.nraplica = pr_nraplica;
  BEGIN
    -- PAra aplicações de Captação
    IF pr_tpaplica IN(3,4) THEN
      -- Buscar CRAPRAC
      OPEN cr_craprac;
      FETCH cr_craprac
       INTO vr_nmprodut;
      CLOSE cr_craprac;
    ELSE
      -- Buscar CRAPRDA
      OPEN cr_craprda;
      FETCH cr_craprda
       INTO vr_nmprodut;
      CLOSE cr_craprda;
    END IF;
    -- Retornar descrição encontrada
    RETURN vr_nmprodut;
  END;

  -- Retornar true caso a aplicação esteja em carencia
  FUNCTION fn_tem_carencia(pr_dtmvtapl crapdat.dtmvtolt%type
                          ,pr_qtdiacar craprac.qtdiacar%TYPE
                          ,pr_dtmvtres crapdat.dtmvtolt%TYPE) RETURN VARCHAR2 IS
  BEGIN
    -- Se a data enviada menos a data do movimento da aplicacao, for inferior a quantidade de dias da aplicacao
    IF (pr_dtmvtres - pr_dtmvtapl) < pr_qtdiacar THEN
      -- Tem carencia
      RETURN 'S';
    ELSE
      -- Não satisfez nenhuma condicao, não tem carencia
      RETURN 'N';
    END IF;
  END;

  -- Função para transformar a taxa ao dia em taxa anual
  -- Exemplo: Taxa ao dia: 0,024583 -> taxa anual: 6,39
  FUNCTION fn_get_taxa_anual (pr_txapldia craplap.txaplica%TYPE) RETURN NUMBER IS
  BEGIN
    RETURN round((power(1+pr_txapldia/100,252)-1)*100,4);
  END;

  -- Função para transformar hora atual em texto para LOGS
  FUNCTION fn_get_time_char RETURN VARCHAR2 IS
  BEGIN
    RETURN to_char(sysdate,'DD/MM/RRRR hh24:mi:ss - ');
  END;

  -- Função para mostrar a descrição conforme o tipo do Arquivo enviado
  FUNCTION fn_tparquivo_custodia(pr_idtipo_arquivo IN NUMBER   -- Tipo do Arquivo (1-Registro,2-Operação,3-Exclusão,9-Conciliação)
                                ,pr_idtipo_retorno IN VARCHAR2) -- Tipo do Retorno (A-Abreviado ou E-Extenso)
                          RETURN VARCHAR2 IS
  BEGIN
    -- Retornar conforme o tipo do Arquivo
    IF pr_idtipo_arquivo = 1 THEN
      IF pr_idtipo_retorno = 'A' THEN
        RETURN 'REG';
      ELSE
        RETURN 'Registro';
      END IF;
    ELSIF pr_idtipo_arquivo = 2 THEN
      IF pr_idtipo_retorno = 'A' THEN
        RETURN 'OPE';
      ELSE
        RETURN 'Operação';
      END IF;
    ELSIF pr_idtipo_arquivo = 5 THEN
      IF pr_idtipo_retorno = 'A' THEN
        RETURN 'RET';
      ELSE
        RETURN 'Retorno';
      END IF;
    ELSE
      IF pr_idtipo_retorno = 'A' THEN
        RETURN 'CNC';
      ELSE
        RETURN 'Conciliação';
      END IF;
    END IF;
  END;

  -- Função para mostrar a descrição conforme o tipo lancto enviado
  FUNCTION fn_tpregistro_custodia(pr_idtipo_lancto  IN NUMBER    -- Tipo do Registro
                                 ,pr_idtipo_retorno IN VARCHAR2) -- Tipo do Retorno (A-Abreviado ou E-Extenso)
                          RETURN VARCHAR2 IS
  BEGIN
    -- Retornar conforme o tipo do Arquivo
    IF pr_idtipo_lancto = 1 THEN
      IF pr_idtipo_retorno = 'A' THEN
        RETURN 'REG';
      ELSE
        RETURN 'Registro';
      END IF;
    ELSIF pr_idtipo_lancto = 2 THEN
      IF pr_idtipo_retorno = 'A' THEN
        RETURN 'RGT';
      ELSE
        RETURN 'Resgate';
      END IF;
    ELSIF pr_idtipo_lancto = 3 THEN
      IF pr_idtipo_retorno = 'A' THEN
        RETURN 'RIR';
      ELSE
        RETURN 'Ret.IR';
      END IF;
    ELSE
      IF pr_idtipo_retorno = 'A' THEN
        RETURN 'CNC';
      ELSE
        RETURN 'Conciliação';
      END IF;
    END IF;
  END;


  -- Função para gerar nome de arquivo conforme ID, Coop, Tipo e Data passada
  FUNCTION fn_nmarquivo_custodia(pr_idarquivo      tbcapt_custodia_arquivo.idarquivo%TYPE       -- ID do arquivo
                                ,pr_cdcooper       crapcop.cdcooper%TYPE                        -- Código da Cooperativa
                                ,pr_idtipo_arquivo tbcapt_custodia_arquivo.idtipo_arquivo%TYPE  -- Tipo do Arquivo
                                ,pr_dtarquivo      tbcapt_custodia_arquivo.dtcriacao%TYPE)      -- Data Arquivo
                         RETURN VARCHAR2 IS
  BEGIN
    -- Padrão
    --   CodigoCliente(5 primeiras posições+000 (Miolo)).AAMMDD_DMOVTRANSF_Tipo_IDArquivo.TXT onde
    RETURN
      substr(gene0001.fn_param_sistema('CRED',pr_cdcooper,'CD_REGISTRADOR_CUSTOD_B3'),1,5)||'000'
      ||'.'||to_char(pr_dtarquivo,'yymmdd')
      ||'_DMOVTRANSF'
      ||'_'||fn_tparquivo_custodia(pr_idtipo_arquivo,'A')
      ||'_'||pr_idarquivo
      ||'.TXT';
  END;

  -- Função para converter o valor enviado em Cota UNitária
  FUNCTION fn_converte_valor_em_cota(pr_vllancto IN NUMBER) RETURN NUMBER IS
  BEGIN
    -- Dividir pelo fator de conversão R$ X Cota Unitária
    RETURN nvl(pr_vllancto,0) / vr_qtftcota;
  END;

  -- Função para remover quebras de linha
  FUNCTION fn_remove_quebra(pr_dstexto IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    -- REmover quebras a direita
    RETURN rtrim(rtrim(pr_dstexto,chr(10)),chr(13));
  END;

  -- Função para validar se codigo cetip recebido está cadastrado em alguma cooperativa do grupo
  FUNCTION fn_valida_codigo_cetip(pr_codcetip VARCHAR2) RETURN BOOLEAN IS
    CURSOR cr_crapcop IS
      SELECT cdcooper
        FROM crapcop
       WHERE substr(gene0001.fn_param_sistema('CRED',cdcooper,'CD_REGISTRADOR_CUSTOD_B3'),1,5) = pr_codcetip;
    vr_cdcooper crapcop.cdcooper%TYPE;
  BEGIN
    -- Buscar alguma cooperativa
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO vr_cdcooper;
    CLOSE cr_crapcop;
    -- Se não achou nenhuma
    IF vr_cdcooper IS NULL THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  END;

  -- Função para validar se o histórico passado é de provisão ou rendicimento
  -- pois estes, quando encontrados no dia do resgate, terão o saldo corredto da aplicação
  FUNCTION fn_valida_histor_rendim(pr_tpaplica IN NUMBER
                                  ,pr_cdprodut IN NUMBER
                                  ,pr_cdhistor IN NUMBER) RETURN BOOLEAN IS

    CURSOR cr_hiscapt IS
      SELECT 1
        FROM crapcpc cpc
       WHERE cpc.cdprodut = pr_cdprodut
         AND pr_cdhistor in(cpc.cdhsprap,cpc.cdhsrdap);
    vr_id_exist NUMBER := 0;
  BEGIN
    -- Para produto novo de captação
    IF pr_tpaplica IN(3,4) THEN
      OPEN cr_hiscapt;
      FETCH cr_hiscapt
       INTO vr_id_exist;
      CLOSE cr_hiscapt;
      -- Se encontrou
      IF vr_id_exist = 1 THEN
        RETURN TRUE;
      END IF;
    ELSE
      -- Históricos fixos
      IF pr_cdhistor IN(474,475,529,532) THEN
         RETURN TRUE;
      END IF;
    END IF;
    -- Se não encontrou nenhum dos históricos, retornar false
    RETURN FALSE;
  END;
  --
  PROCEDURE pc_grava_linha(pr_nmarqger      IN VARCHAR2
                          ,pr_nmdirger      IN VARCHAR2
                          ,pr_utlfileh      IN OUT NOCOPY UTL_FILE.file_type
                          ,pr_des_text      IN VARCHAR2)
  IS
  /* ..........................................................................
    
  Procedure: pc_grava_linha
  Sistema  : Rotina de aplicações
  Autor    : Belli/Envolti
  Data     : 03/04/2019                        Ultima atualizacao: 
    
  Dados referentes ao programa:  Projeto PJ411_F2_P2  
  Frequencia: Sempre que for chamado
  Objetivo  : Tratar gravação de linha no arquivo
    
  Alteracoes: 
    
  ............................................................................. */
    
      vr_nmproint1               VARCHAR2 (100) := 'pc_grava_linha';
  BEGIN                 
    
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => pr_utlfileh
                                  ,pr_des_text => pr_des_text);
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
  EXCEPTION 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Monta mensagem
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     ' ' || SQLERRM     ||
                     ' ' || vr_nmaction ||
                     ' ' || vr_nmproint1 ||
                     ' ' || vr_dsparame ||
                     ', pr_nmdirger:' || pr_nmdirger || 
                     ', pr_nmarqger:' || pr_nmarqger;                  
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);
      -- Parar o processo            
      RAISE_APPLICATION_ERROR (-20000,'vr_cdcritic:' || vr_cdcritic  || '- vr_dscritic:' || vr_dscritic);
  END pc_grava_linha;      
  --  
            
  --
  PROCEDURE pc_abre_arquivo(pr_nmarqger  IN VARCHAR2
                           ,pr_nmdirger  IN VARCHAR2
                           ,pr_dstexcab  IN VARCHAR2 DEFAULT NULL
                           ,pr_tipabert  IN VARCHAR2 DEFAULT 'W' 
                           ,pr_dshandle  OUT UTL_FILE.FILE_TYPE)
  IS
  /* ..........................................................................
    
  Procedure: pc abre arquivo
  Sistema  : Rotina de aplicações
  Autor    : Belli/Envolti
  Data     : 03/04/2019                        Ultima atualizacao: 
    
  Dados referentes ao programa:  Projeto PJ411_F2_P2    
  Frequencia: Sempre que for chamado
  Objetivo  : Tratar abertura de arquivo
    
  Alteracoes:              
    
  ............................................................................. */
    --
    vr_nmproint1               VARCHAR2 (100) := 'pc_abre_arquivo';
    vr_dsparint1               VARCHAR2 (4000); 
    vr_exc_saida_abre_arq      EXCEPTION;
    
  PROCEDURE pc_efetiva_abertura
    IS
  BEGIN         
          
    gene0001.pc_abre_arquivo(pr_nmdireto => pr_nmdirger -- || pr_nmarqger 
                            ,pr_nmarquiv => pr_nmarqger
                            ,pr_tipabert => pr_tipabert         -- Modo de abertura (R,W,A)
                            ,pr_flaltper => 0                  -- Não modifica permissões de arquivo
                            ,pr_utlfileh => pr_dshandle        -- Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);                                
    IF vr_dscritic IS NOT NULL THEN
      vr_cdcritic := 0;
      vr_dscritic := vr_dscritic;
      vr_dsparame := vr_dsparame  ||
                     ' ' || vr_dsparint1;
      RAISE vr_exc_saida_abre_arq;
    END IF;
                     
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
      pc_grava_linha(pr_nmarqger     => pr_nmarqger
                    ,pr_nmdirger     => pr_nmdirger
                    ,pr_utlfileh     => pr_dshandle
                    ,pr_des_text     => pr_dstexcab );
                    
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction); 
      pc_grava_linha(pr_nmarqger     => pr_nmarqger
                    ,pr_nmdirger     => pr_nmdirger
                    ,pr_utlfileh     => pr_dshandle
                    ,pr_des_text     => '' );
  END pc_efetiva_abertura;
    
  BEGIN    
    vr_dsparint1 := ', pr_nmdirger:' || pr_nmdirger || 
                    ', pr_nmarqger:' || pr_nmarqger || 
                    ', pr_dstexcab:' || pr_dstexcab ||
                    ', pr_tipabert:' || pr_tipabert || 
                    ', pr_flaltper:' || '0';
  
    -- Se for rotina 001 e arquivo de critica sem abrir, então abre 
    IF NOT vr_inabr_arq_cri_pro_con    THEN  
      vr_inabr_arq_cri_pro_con := true;    
      pc_efetiva_abertura;
    --
    ELSIF NOT vr_inabr_arq_msg_pro_con    THEN  
      vr_inabr_arq_msg_pro_con := true;
      pc_efetiva_abertura;
    END IF;    
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
  EXCEPTION 
    WHEN vr_exc_saida_abre_arq THEN 
      -- Monta mensagem
      vr_cdcritic := NVL(vr_cdcritic,0);
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     ' ' || vr_nmaction  ||
                     ' ' || vr_nmproint1 ||
                     ' ' || vr_dsparame  ||
                     ' ' || vr_dsparint1;
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Monta mensagem
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     ' ' || SQLERRM      ||
                     ' ' || vr_nmaction  ||
                     ' ' || vr_nmproint1 ||
                     ' ' || vr_dsparame  ||
                     ' ' || vr_dsparint1;                  
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);
  END pc_abre_arquivo;   
  --
  PROCEDURE pc_fecha_arquivo(pr_utlfileh  IN OUT NOCOPY UTL_FILE.file_type)
  IS
  /* ..........................................................................
    
  Procedure: pc fecha arquivo
  Sistema  : Rotina de aplicações
  Autor    : Belli/Envolti
  Data     : 03/04/2019                        Ultima atualizacao: 
    
  Dados referentes ao programa:  Projeto PJ411_F2_P2  
  Frequencia: Sempre que for chamado
  Objetivo  : Tratar fechamento de arquivo
    
  Alteracoes: 
    
  ............................................................................. */

      vr_nmproint1               VARCHAR2 (100) := 'pc_fecha_arquivo';   
  BEGIN                   
    
    IF utl_file.IS_OPEN(pr_utlfileh) THEN
      gene0001.pc_fecha_arquivo(pr_utlfileh => pr_utlfileh);
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
    END IF;
  EXCEPTION 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Monta mensagem
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     ' ' || SQLERRM      ||
                     ' ' || vr_nmaction  ||
                     ' ' || vr_nmproint1 ||
                     ' ' || vr_dsparame;                  
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);
      -- Parar o processo            
      RAISE_APPLICATION_ERROR (-20000,'vr_cdcritic:' || vr_cdcritic  || '- vr_dscritic:' || vr_dscritic);
  END pc_fecha_arquivo; 
  --

  --Procedures Rotina de Log - tabela: tbgen prglog ocorrencia
  PROCEDURE pc_log(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                  ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                  ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                  ,pr_tpexecuc IN NUMBER   DEFAULT 0   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                  ,pr_dscrilog IN VARCHAR2 DEFAULT NULL
                  ,pr_cdcritic IN NUMBER DEFAULT NULL
                  ,pr_nmrotina IN VARCHAR2 DEFAULT NULL -- Null assume nome da Package
                  ,pr_cdcooper IN VARCHAR2 DEFAULT 0
                  ) 
  IS
    -- ..........................................................................
    --
    --  Programa : pc log
    --  Sistema  : Rotina de Log - tabela: tbgen prglog ocorrencia
    --  Sigla    : GENE
    --  Autor    : Envolti - Belli - Projeto 411 - Fase 2 - Conciliação Despesa
    --  Data     : 01/04/2019                       Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Chamar a rotina de Log para gravação de criticas.
    --
    --   Alteracoes: 
    --
    -- .............................................................................
    --
    vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
    vr_nmrotina VARCHAR2 (32)              := vr_nmpackge;
    vr_dscrilog tbgen_prglog_ocorrencia.dsmensagem%TYPE;
  BEGIN
    vr_dscrilog := pr_dscrilog;
    IF pr_nmrotina IS NOT NULL THEN
      vr_nmrotina := pr_nmrotina;      
    END IF;
    -- Controlar geração de log de execução dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog -- I-início/ F-fim/ O-ocorrência/ E-erro 
                          ,pr_tpocorrencia  => pr_tpocorre -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_cdcriticidade => pr_cdcricid -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          ,pr_tpexecucao    => pr_tpexecuc -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                          ,pr_dsmensagem    => vr_dscrilog
                          ,pr_cdmensagem    => pr_cdcritic
                          ,pr_cdprograma    => vr_nmrotina
                          ,pr_cdcooper      => pr_cdcooper 
                          ,pr_idprglog      => vr_idprglog
                          ); 
    IF pr_cdcritic <> 1201 THEN 
      
      IF NVL(pr_tpocorre,2) IN ( 3, 4 ) AND      
         vr_inabr_arq_msg_pro_con  THEN          
        vr_ctmensag := vr_ctmensag + 1;
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_dshan001_msg
                                      ,pr_des_text => '  ' || pr_cdcritic || ' - ' || vr_dscrilog);
                      
      ELSIF vr_inabr_arq_cri_pro_con  THEN          
        vr_ctcritic := vr_ctcritic + 1;
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_dshan001_critic
                                      ,pr_des_text => '  ' || pr_cdcritic || ' - ' || vr_dscrilog);
      END IF;      
    END IF;
    
  EXCEPTION   
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log  
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper
                                   ,pr_compleme => 'pc_log' ||
                                                   ', tp:' || pr_tpocorre ||
                                                   ', cd:' || pr_cdcritic || 
                                                   ', ds:' || vr_dscrilog
                                    );                                                             
  END pc_log;
  --
  PROCEDURE pc_monta_e_mail
  IS
  /* ..........................................................................
    
  Procedure: pc monta e_mail
  Sistema  : Rotina de aplicações
  Autor    : Belli/Envolti
  Data     : 03/04/2019                        Ultima atualizacao: 
    
  Dados referentes ao programa:  Projeto PJ411_F2_P2  
  Frequencia: Sempre que for chamado
  Objetivo  : Montar e-mails de retorno
    
  Alteracoes: 
    
  ............................................................................. */   
    --
    vr_nmproint1               VARCHAR2 (100) := 'pc_monta_e_mail';
    vr_exc_saida_email         EXCEPTION;
  BEGIN
    
    -- Busca o endereco de email para os casos de criticas
    ---vr_dsemldst := 'cesar.belli@anvolti.com.br';

    IF vr_dsemldst IS NULL THEN
      vr_cdcritic := 1230;  -- Registro de parametro não encontrado
      vr_dsparame := vr_dsparame ||
                     ' email não encontrado com o acesso:' || vr_dsacseml ||
                     ',vr_dsemldst:'    || vr_dsemldst ||
                     ',pr_des_assunto:' || vr_dsassunt ||
                     ',pr_des_corpo:'   || vr_dscorpo  ||
                     ',pr_des_anexo:'   || vr_dslisane;
      RAISE vr_exc_saida_email;
    END IF;
    
    -- email no Log    
    pc_log(pr_cdcritic => 1201
                         ,pr_dscrilog => 'Solicita email:' ||
                                         ' vr_nmaction:'    || vr_nmaction ||
                                         ',pr_des_destino:' || vr_dsemldst ||
                                         ',pr_des_assunto:' || vr_dsassunt ||
                                         ',pr_des_corpo:'   || vr_dscorpo  ||
                                         ',pr_des_anexo:'   || vr_dslisane
                          ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                          ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                         ); 
    --  
    IF vr_fgtempro THEN  
      gene0003.pc_solicita_email(pr_cdcooper        => CASE vr_cdcooper
                                                       WHEN NULL THEN 3
                                                       WHEN 0    THEN 3
                                                       ELSE vr_cdcooper
                                                     END
                              ,pr_cdprogra        => vr_nmpackge
                              ,pr_des_destino     => vr_dsemldst
                              ,pr_des_assunto     => vr_dsassunt
                              ,pr_des_corpo       => vr_dscorpo
                              ,pr_des_anexo       => vr_dslisane
                              ,pr_flg_remove_anex => 'N'
                              ,pr_flg_enviar      => 'S'
                              ,pr_des_erro        => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        vr_cdcritic := 0;
        vr_dsparame := vr_dsparame || 
                     ' pr_cdprogra:'     || vr_nmpackge ||
                     ', pr_des_destino:' || vr_dsemldst ||
                     ', pr_des_assunto:' || vr_dsassunt ||
                     ', pr_des_corpo:'   || vr_dscorpo  ||
                     ', pr_des_anexo:'   || vr_dslisane  ||
                     ', pr_flg_remove_anex:' || 'N' ||
                     ', pr_flg_enviar:'      || 'S';
        RAISE vr_exc_saida_email;
      END IF;
    END IF;
    
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);    
  EXCEPTION
    WHEN vr_exc_saida_email THEN 
      -- Monta mensagem
      vr_cdcritic := NVL(vr_cdcritic,0);
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     ' ' || vr_nmaction  ||
                     ' ' || vr_nmproint1 ||
                     ' ' || vr_dsparame;                  
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);
      -- Parar o processo            
      RAISE_APPLICATION_ERROR (-20000,'vr_cdcritic:' || vr_cdcritic  || ' - vr_dscritic:' || vr_dscritic);
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => 0);
      -- Monta mensagem
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     ' ' || SQLERRM ||
                     ' ' || vr_nmaction  ||
                     ' ' || vr_nmproint1 ||
                     ' ' || vr_dsparame;                  
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);
      -- Parar o processo            
      RAISE_APPLICATION_ERROR (-20000,'vr_cdcritic:' || vr_cdcritic  || '- vr_dscritic:' || vr_dscritic);                                                  
  END pc_monta_e_mail;
  
  -- Procedimento que recebe um arquivo e alerta por email a equipe responsável
  PROCEDURE pc_envia_email_alerta_arq(pr_dsdemail  IN VARCHAR2                               --> Destinatários
                                     ,pr_dsjanexe  IN VARCHAR2                               --> Descrição horário execução
                                     ,pr_idarquivo IN tbcapt_custodia_arquivo.idarquivo%TYPE --> ID do arquivo
                                     ,pr_dsdirbkp  IN VARCHAR2                               --> Caminho de backup linux
                                     ,pr_dsredbkp  IN VARCHAR2                               --> Caminho da rede de Backup
                                     ,pr_flgerrger IN BOOLEAN                                --> erro geral do arquivo
                                     ,pr_idcritic OUT NUMBER                                 --> Criticidade da saida
                                     ,pr_cdcritic OUT NUMBER                                 --> Código da critica
                                     ,pr_dscritic OUT VARCHAR2) IS                           --> Descrição da critica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc enviaemail alerta arq
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 03/04/2019
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Diário
    -- Objetivo  : Procedimento responsável por varrer as criticas geradas no processamento do arquivo
    --             e montar email para os responsáveis pela conferência dos problemas
    --
    -- Alteracoes: 07/12/2018 - P411 - Melhoria do anexo e Ajustes no email para guardar anexo em pasta (Marcos-Envolti)
    --
    --             03/04/2019 - Projeto 411 - Fase 2 - Parte 2 - Conciliação Despesa B3 e Outros Detalhes
    --                          Ajusta mensagens de erros e trata de forma a permitir a monitoração automatica.
    --                          Procedimento de Log - tabela: tbgen prglog ocorrencia 
    --                         (Envolti - Belli - PJ411_F2_P2)
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE

      -- -- Anderson
      vr_dtmvtoan         crapdat.dtmvtoan%TYPE;      
      -- tipo de aplicacao (1 - rdc pos e pre / 2 - pcapta / 3 - aplic programada)
      vr_tpaplicacao      tbcapt_saldo_aplica.tpaplicacao%TYPE;
      vr_sldaplic         tbcapt_saldo_aplica.vlsaldo_concilia%TYPE;
      vr_qtde_b3          tbcapt_custodia_aplicacao.qtcotas%TYPE;
      vr_vlpu_b3          tbcapt_custodia_aplicacao.vlpreco_unitario%TYPE;
      vr_vltotal_b3       tbcapt_saldo_aplica.vlsaldo_concilia%TYPE;
      vr_sldaplic_alfa    VARCHAR2(30);
      vr_vltotal_b3_alfa  VARCHAR2(30); 
            
      -- Variaveis para Email
      vr_dsarqanx     VARCHAR2(500);
      vr_conteudo     VARCHAR2(500);
      --
      vr_qtarquiv_1   NUMBER(2);
      vr_assunto_1    VARCHAR2(500);
      vr_conteudo_1   VARCHAR2(4000);
      vr_dsarqanx_1   VARCHAR2(500);
      -- Guardar HMTL texto
      vr_dshmtl_1     clob;
      vr_dshmtl_aux_1 varchar2(32767);
      --
      vr_assunto            VARCHAR2(500);
      vr_idtipo_arquivo     tbcapt_custodia_arquivo.idtipo_arquivo%TYPE;
      vr_nmarquivo          tbcapt_custodia_arquivo.nmarquivo%TYPE;
      vr_dstipo_arquivo     VARCHAR2(4000);
      vr_dtregistro         VARCHAR2(20);
      vr_dtcriacao          VARCHAR2(20);
      vr_dtprocesso         VARCHAR2(20);
      
      vr_dscri_arq          tbcapt_custodia_conteudo_arq.dscritica%TYPE;
      vr_nrseq_linha        tbcapt_custodia_conteudo_arq.nrseq_linha%TYPE;
      vr_dscodigo_b3        tbcapt_custodia_conteudo_arq.dscodigo_b3%TYPE;
      vr_nrdconta           craprda.nrdconta%TYPE;
      vr_tpaplica           VARCHAR2(4000);
      vr_nraplica           craprda.nraplica%TYPE;
      vr_qtcotas            tbcapt_custodia_aplicacao.qtcotas%TYPE;            
        
      --
      -- Variaveis para Email
      vr_qtarquiv_2   NUMBER(2);
      vr_assunto_2    VARCHAR2(500);
      vr_conteudo_2   VARCHAR2(4000);
      vr_dsarqanx_2   VARCHAR2(500);
      -- Guardar HMTL texto
      vr_dshmtl_2     clob;
      vr_dshmtl_aux_2 varchar2(32767);
      --
      vr_nmrescop crapcop.nmrescop%TYPE := 'Nao encontrado';
      vr_cdcooper crapcop.cdcooper%TYPE := 99;
      vr_fglprime VARCHAR2(1)           := 'S';
      --
      vr_qtlin_1 NUMBER(22) := 0;
      vr_qtlin_2 NUMBER(22) := 0;
      --
      
      vr_nmproint1               VARCHAR2 (100) := 'pc_envia_email_alerta_arq';
      vr_exc_saida_mail_alerta   EXCEPTION;
      
      -- Busca das linhas com critica no arquivo enviado
      CURSOR cr_arq IS
        SELECT arqRet.nmarquivo
              ,fn_tparquivo_custodia(arqRet.idtipo_arquivo,'E') dstipo_arquivo
              ,cnt.nrseq_linha
              ,cnt.dslinha
              ,cnt.dscritica
              ,arqRet.idtipo_Arquivo
              ,cnt.idaplicacao
              ,cnt.dscodigo_b3
              ,to_char(arqRet.Dtregistro,'dd/mm/rrrr') dtregistro
              ,to_char(arqRet.Dtcriacao,'dd/mm/rrrr hh24:mi:ss') dtcriacao
              ,to_char(arqRet.Dtprocesso,'dd/mm/rrrr hh24:mi:ss') dtprocesso
          FROM tbcapt_custodia_arquivo      arqRet
              ,tbcapt_custodia_conteudo_arq cnt
         WHERE arqRet.idarquivo = cnt.idarquivo
           AND arqRet.idarquivo = pr_idarquivo
           AND (   cnt.dscritica IS NOT NULL
                OR vr_inconcil   = 'S'       )
           AND cnt.idtipo_linha = 'L' -- Somente registros
         ORDER BY cnt.nrseq_linha;
         
      -- Buscar aplicação em Custódia
      CURSOR cr_aplica(pr_idaplic tbcapt_custodia_aplicacao.idaplicacao%TYPE) IS
        SELECT apl.idaplicacao
              ,apl.tpaplicacao
              ,0 cdcooper
              ,0 nrdconta
              ,0 nraplica
              ,rpad(' ',50,' ') tpaplica
              ,apl.qtcotas
          FROM tbcapt_custodia_aplicacao apl
        WHERE apl.idaplicacao = pr_idaplic;
      rw_aplica cr_aplica%ROWTYPE;

      -- Buscar aplicação RDA
      CURSOR cr_craprda(pr_idaplcus craprda.idaplcus%TYPE) IS
        SELECT rda.cdcooper
              ,rda.nrdconta
              ,rda.nraplica
          FROM craprda rda
         WHERE rda.idaplcus = pr_idaplcus;

      -- Buscar aplicação RAC
      CURSOR cr_craprac(pr_idaplcus craprac.idaplcus%TYPE) IS
        SELECT rac.cdcooper
              ,rac.nrdconta
              ,rac.nraplica
              ,cpc.nmprodut
          FROM craprac rac
              ,crapcpc cpc
         WHERE rac.idaplcus = pr_idaplcus
           AND rac.cdprodut = cpc.cdprodut;
      
      -- -- Anderson
      -- Busca o saldo da aplicacao
      CURSOR cr_saldo(pr_cdcooper    craprda.cdcooper%TYPE   
                     ,pr_nrdconta    craprda.nrdconta%TYPE   
                     ,pr_nraplica    craprda.nraplica%TYPE   
                     ,pr_tpaplicacao craprda.tpaplica%TYPE
                     ,pr_dtmvtolt    craprda.dtmvtolt%TYPE) IS
        SELECT sl.VLSALDO_CONCILIA
          FROM tbcapt_saldo_aplica sl
         WHERE sl.cdcooper    = pr_cdcooper   
           AND sl.nrdconta    = pr_nrdconta   
           AND sl.nraplica    = pr_nraplica   
           AND sl.tpaplicacao = pr_tpaplicacao
           AND sl.dtmvtolt    = pr_dtmvtolt;
    ---       
    PROCEDURE pc_coop
    IS
      vr_nmproint1               VARCHAR2 (100) := 'pc_coop';
    BEGIN
      SELECT   cop.nmrescop 
      INTO     vr_nmrescop
      FROM     crapcop cop
      WHERE    cop.cdcooper = vr_cdcooper;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN      
        -- Efetuar retorno do erro não tratado
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1036) ||
                       ' ' || vr_nmaction || 
                       ' ' || vr_nmproint1 || 
                       ' ' || vr_dsparame ||
                       ', cdcooper:'   || vr_cdcooper;
        -- Log de erro de execucao
        pc_log(pr_cdcritic => 1036
              ,pr_dscrilog => vr_dscritic);
        vr_dscritic := NULL;      
      WHEN OTHERS THEN
        -- Quando erro de programa gravar tabela especifica de log
        CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);      
        -- Efetuar retorno do erro não tratado
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 9999) ||
                       ' ' || SQLERRM || 
                       ' ' || vr_nmaction || 
                       ' ' || vr_nmproint1 || 
                       ' ' || vr_dsparame ||
                       ', cdcooper:'   || vr_cdcooper;
        -- Log de erro de execucao
        pc_log(pr_cdcritic => 9999
              ,pr_dscrilog => vr_dscritic);
        vr_dscritic := NULL;      
    END pc_coop;
    --
    
    --
    PROCEDURE pc_abre_arq_2
      IS
    BEGIN
        
          -- Montar assunto
          vr_assunto_2 := 'Registros processados sem erro do arquivo '||vr_nmarquivo||
                          ' de '||vr_dstipo_arquivo||
                          ' de operações na B3 Ref '||vr_dtregistro;
          -- Se não for um erro geral
          IF NOT pr_flgerrger THEN
            
            vr_dsarqanx_2 := 'PROC_SUCESSO_'|| vr_nmarquivo || '_' || vr_qtarquiv_2 || '.html';
                        
            -- Montar corpo do email
            vr_conteudo_2 := 'Prezados, '||vr_dstagque;
            
            -- Montar o início da tabela (Num clob para evitar estouro)
            dbms_lob.createtemporary(vr_dshmtl_2, TRUE, dbms_lob.CALL);
            dbms_lob.open(vr_dshmtl_2,dbms_lob.lob_readwrite);
            -- Enviar dados do arquivo
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<div align="left" style="margin: 10px auto; font-family: Tahoma,sans-serif; font-size: 12px; color: #686868;">');
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'Dados do arquivo:'||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'Cooperativa: ' || vr_nmrescop || vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'ID: '||pr_idarquivo||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'Nome: '||vr_nmarquivo||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'Tipo: '||vr_dstipo_arquivo||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'Data Base: '||vr_dtregistro||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'Data Recebimento: '||vr_dtcriacao||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'Data Processamento: '||vr_dtprocesso||vr_dstagque||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'Lista de Registros:'||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'</div>');

            -- Preparar tabela de erros
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >');
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<table border="1" style="width:500px; margin: 10px auto; font-family: Tahoma,sans-serif; font-size: 12px; color: #686868;" >');
            -- Montando header
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<th>Nro.Linha</th>');
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<th>Cod.B3</th>');
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<th>Conta</th>');
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<th>Tp.Aplica</th>');
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<th>Aplica</th>');
            
            -- -- Anderson
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<th>Qtd. Aimaro</th>');
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<th>Valor Aimaro</th>');            
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<th>Qtd. B3</th>');
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<th>Valor B3</th>');
                        
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<th>Critica</th>');
            gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<th>Linha Enviada</th>');
            
            vr_qtarquiv_2 := vr_qtarquiv_2 + 1;
          ELSE
            -- Erro geral
            vr_conteudo_2 := 'Prezados, '||vr_dstagque ||
                             'O arquivo apresentou o erro abaixo e não foi processado';
            vr_conteudo_2 := vr_conteudo_2 || ' pelo Aimaro '||vr_dstagque;
            
            -- Continuar
            vr_conteudo_2 := vr_conteudo_2 || '<b>'||vr_dscri_arq||'</b>'||vr_dstagque;
          END IF;
    
      vr_fglaberto_2 := TRUE;
      
    END pc_abre_arq_2;
    --
    
    --
    PROCEDURE pc_fecha_arq_2
      IS
    BEGIN

      -- Encerrar o texto e o clob
      gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'',true);
            
        -- Gerar o arquivo na pasta de backup do financeiro
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_dshmtl_2
                                     ,pr_caminho  => pr_dsdirbkp
                                     ,pr_arquivo  => vr_dsarqanx_2
                                     ,pr_des_erro => vr_dscritic);
        
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_dshmtl_2);
        dbms_lob.freetemporary(vr_dshmtl_2);
        
        -- Em caso de erro
        IF vr_dscritic IS NOT NULL THEN
          -- Propagar a critica
          vr_cdcritic := 1044;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                         ' Caminho: '||vr_dsdirarq||'/'||vr_dsarqanx_2||', erro: '||vr_dscritic;
          RAISE vr_exc_saida_mail_alerta;
      
        END IF;
      
    END pc_fecha_arq_2;
    
    PROCEDURE pc_inclui_arq_2
      IS
    BEGIN              
        -- Cada registro deve ser enviado ao arquivo a anexar
        gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<tr>');
        -- E os detalhes do registro
        gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<td align="right">'||to_char(vr_nrseq_linha)||'</td>');
                  
        -- Enviar dados da aplicacao
        gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<td>'||vr_dscodigo_b3||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<td>'||vr_nrdconta||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<td>'||vr_tpaplica||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<td>'||vr_nraplica||'</td>');
        -- -- Anderson
        gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<td>'||vr_qtcotas||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<td>'||vr_sldaplic_alfa||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<td>'||vr_qtde_b3 ||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<td>'||vr_vltotal_b3_alfa ||'</td>');                               
        -- Enviar linha e critica
        gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<td>'||vr_dscri_arq||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'<td>'||vr_dslinha||'</td>');
        -- Encerrar a tr
        gene0002.pc_escreve_xml(vr_dshmtl_2,vr_dshmtl_aux_2,'</tr>');
        
        vr_qtlin_2 := vr_qtlin_2 + 1;
      
    END pc_inclui_arq_2;
    
    
    --
    PROCEDURE pc_trata_arq_2
      IS
    BEGIN
      --
      IF vr_infimarq_2 = 'S' OR 
        (vr_qtlin_2         >= vr_qtmaxreq AND 
         NVL(vr_qtmaxreq,0) > 0             ) THEN
        --
        IF vr_fglaberto_2 THEN
          pc_fecha_arq_2;
        END IF;
        --
        IF vr_infimarq_2 = 'N' THEN
          vr_qtlin_2 := 0;
          pc_abre_arq_2;
          pc_inclui_arq_2;
        END IF;
        --
      ELSE
        IF NOT vr_fglaberto_2 THEN
          pc_abre_arq_2;
        END IF;
        pc_inclui_arq_2;
      END IF;
      
    END pc_trata_arq_2;
    --
    
    --
    PROCEDURE pc_abre_arq_1
      IS
    BEGIN        
        -- Montar assunto
        vr_assunto_1 := 'Criticas ao processar o arquivo ' || vr_nmarquivo ||
                      ' de ' || vr_dstipo_arquivo ||
                      ' de operações na B3 Ref '  || vr_dtregistro;
        -- Se não for um erro geral
        IF NOT pr_flgerrger THEN

          vr_dsarqanx_1 := 'PROC_ERRO_' || vr_nmarquivo || '_' || vr_qtarquiv_1 || '.html'; 
                                
          -- Montar corpo do email
          vr_conteudo_1 := 'Prezados, '||vr_dstagque;
          -- Caso conciliação
          IF vr_idtipo_arquivo = 9 THEN
            vr_conteudo_1 := vr_conteudo_1 || 
                             'Houve diferença na '|| vr_dstipo_arquivo ||
                             ' das aplicações registradas na B3 em comparação com o Aimaro. '||vr_dstagque;
          ELSE
            vr_conteudo_1 := vr_conteudo_1 || 
               'Os registros listados no anexo apresentaram criticas e não foram processados pela B3. '||vr_dstagque;
          END IF;          
                    
          ---IF vr_dscri_arq IS NOT NULL THEN
            -- Montar o início da tabela (Num clob para evitar estouro)
            dbms_lob.createtemporary(vr_dshmtl_1, TRUE, dbms_lob.CALL);
            dbms_lob.open(vr_dshmtl_1,dbms_lob.lob_readwrite);
            -- Enviar dados do arquivo
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<div align="left" style="margin: 10px auto; font-family: Tahoma,sans-serif; font-size: 12px; color: #686868;">');
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'Dados do arquivo:'||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'ID: '  || pr_idarquivo      || vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'Nome: '|| vr_nmarquivo      || vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'Tipo: '|| vr_dstipo_arquivo ||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'Data Base: '||vr_dtregistro||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'Data Recebimento: '   ||vr_dtcriacao||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'Data Processamento: ' ||vr_dtprocesso||vr_dstagque||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'Lista de Criticas:'   ||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'</div>');

            -- Preparar tabela de erros
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >');
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<table border="1" style="width:500px; margin: 10px auto; font-family: Tahoma,sans-serif; font-size: 12px; color: #686868;" >');
            -- Montando header
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<th>Nro.Linha</th>');
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<th>Cod.B3</th>');
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<th>Conta</th>');
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<th>Tp.Aplica</th>');
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<th>Aplica</th>');
            
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<th>Qtd. Aimaro</th>');
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<th>Valor Aimaro</th>');            
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<th>Qtd. B3</th>');
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<th>Valor B3</th>');                        
            
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<th>Critica</th>');
            gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<th>Linha Enviada</th>');
            
            vr_qtarquiv_1 := vr_qtarquiv_1 + 1;
        ELSE
            -- Erro geral
            vr_conteudo_1 := 'Prezados, '||vr_dstagque
                        || 'O arquivo apresentou o erro abaixo e não foi processado';
            -- Caso conciliação
            IF vr_idtipo_arquivo = 9 THEN
              vr_conteudo_1 := vr_conteudo_1 || ' pelo Aimaro '||vr_dstagque;
            ELSE
              vr_conteudo_1 := vr_conteudo_1 || ' pela B3: '||vr_dstagque;
            END IF;
            -- Continuar
            vr_conteudo_1 := vr_conteudo_1 || '<b>'||vr_dscri_arq||'</b>'||vr_dstagque;
          ---END IF;
          
        END IF;
        
        
      -- Retorno do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);   
    
      vr_fglaberto_1 := TRUE;
      
    END pc_abre_arq_1;
    --
    
    --
    PROCEDURE pc_fecha_arq_1
      IS
    BEGIN
   
      -- Encerrar o texto e o clob
      gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'',true);
                   
      -- Caso conciliação
      IF vr_idtipo_arquivo = 9 THEN
        -- Gerar o arquivo na pasta de backup do financeiro
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_dshmtl_1
                                     ,pr_caminho  => pr_dsdirbkp
                                     ,pr_arquivo  => vr_dsarqanx_1
                                     ,pr_des_erro => vr_dscritic);
      ELSE
        -- Gerar o arquivo na pasta converte
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_dshmtl_1
                                     ,pr_caminho  => vr_dsdirarq
                                     ,pr_arquivo  => vr_dsarqanx_1
                                     ,pr_des_erro => vr_dscritic);
      END IF;
      
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_dshmtl_1);
      dbms_lob.freetemporary(vr_dshmtl_1);
      -- Em caso de erro
      IF vr_dscritic IS NOT NULL THEN
        -- Propagar a critica
        vr_cdcritic := 1044;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                       ' Caminho: '||vr_dsdirarq||'/'||vr_dsarqanx_1||', erro: '||vr_dscritic;
        RAISE vr_exc_saida_mail_alerta;
          
      END IF;
    
      -- Retorno do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
      
    END pc_fecha_arq_1;
    --
    
    --
    PROCEDURE pc_inclui_arq_1
      IS
    BEGIN
              
        -- Cada registro deve ser enviado ao arquivo a anexar
        gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<tr>');
        -- E os detalhes do registro
        gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<td align="right">'||to_char(vr_nrseq_linha)||'</td>');
                        
        -- Enviar dados da aplicacao
        gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<td>'||vr_dscodigo_b3||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<td>'||vr_nrdconta||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<td>'||vr_tpaplica||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<td>'||vr_nraplica||'</td>');

        -- -- Anderson
        gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<td>'||vr_qtcotas ||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<td>'||vr_sldaplic_alfa||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<td>'||vr_qtde_b3    ||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<td>'||vr_vltotal_b3_alfa ||'</td>');
                        
        -- Enviar linha e critica
        gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<td>'||vr_dscri_arq||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'<td>'||vr_dslinha||'</td>');
        -- Encerrar a tr
        gene0002.pc_escreve_xml(vr_dshmtl_1,vr_dshmtl_aux_1,'</tr>');
        
        vr_qtlin_1 := vr_qtlin_1 + 1;
        
        -- Retorno do módulo e ação logado
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
      
    END pc_inclui_arq_1;
    
    --
    PROCEDURE pc_trata_arq_1
      IS
    BEGIN
      --
      IF vr_infimarq_1 = 'S' OR 
        (vr_qtlin_1         >= vr_qtmaxreq AND 
         NVL(vr_qtmaxreq,0) > 0             ) THEN
        --
        IF vr_fglaberto_1 THEN
          pc_fecha_arq_1;
        END IF;
        --
        IF vr_infimarq_1 = 'N' THEN
          vr_qtlin_1 := 0;
          pc_abre_arq_1;
          pc_inclui_arq_1;
        END IF;
        --
      ELSE
        IF NOT vr_fglaberto_1 THEN
          pc_abre_arq_1;
        END IF;
        pc_inclui_arq_1;
      END IF;
    END pc_trata_arq_1;
    --
        
    BEGIN   --       Principal Inicio
      
      vr_cdcritic  := NULL;
      vr_dscritic  := NULL;      
      ---pr_dsdaviso := 'Iniciando arqs';
      -- Controle Entrada  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                         ---   '. ' || pr_dsdaviso  ||
                            '. ' || vr_nmaction  ||
                            '. ' || vr_nmproint1 ||
                            '. ' || vr_dsparame 
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            ); 
            
      vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper  => 3
                                                ,pr_dtmvtolt  => trunc(SYSDATE)-1
                                                ,pr_tipo      => 'A');
      -- Retorno do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
      
      vr_qtarquiv_1  := 1;
      vr_qtarquiv_2  := 1;
      vr_fglaberto_1 := FALSE;
      vr_fglaberto_2 := FALSE;
        
--vr_dtmvtoan := TO_DATE('28/03/2019','dd/mm/rrrr'); -- teste anderson - Teste Belli

      vr_qtmaxreq := 2000;

      -- Busca de todas as linhas com erro
      FOR rw_arq IN cr_arq LOOP
        
        -- Buscar dados da aplicação
        rw_aplica := NULL;
        OPEN cr_aplica(rw_arq.idaplicacao);
        FETCH cr_aplica
         INTO rw_aplica;
        -- Se não encontrar
        IF cr_aplica%NOTFOUND THEN
          -- Só fechar o cursor
          CLOSE cr_aplica;
        ELSE
          -- Fechar o cursor
          CLOSE cr_aplica;
          -- Buscar aplicação RDA ou RAC relacionada
          IF rw_aplica.tpaplicacao IN(3,4) THEN
            -- Buscar aplicação RAC
            OPEN cr_craprac(rw_aplica.idaplicacao);
            FETCH cr_craprac
             INTO rw_aplica.cdcooper
                 ,rw_aplica.nrdconta
                 ,rw_aplica.nraplica
                 ,rw_aplica.tpaplica;
            CLOSE cr_craprac;
            vr_tpaplicacao := 2; -- -- Anderson
          ELSE
            -- Buscar aplicação RDA
            OPEN cr_craprda(rw_aplica.idaplicacao);
            FETCH cr_craprda
             INTO rw_aplica.cdcooper
                 ,rw_aplica.nrdconta
                 ,rw_aplica.nraplica;
            CLOSE cr_craprda;
            -- Montar tipo aplicação
            IF rw_aplica.tpaplicacao = 1 THEN
              rw_aplica.tpaplica := 'RDC Pré';
            ELSE
              rw_aplica.tpaplica := 'RDC Pós';
            END IF;
            vr_tpaplicacao := 1; -- -- Anderson
          END IF;
          vr_sldaplic := 0; -- -- Anderson
          OPEN cr_saldo(rw_aplica.cdcooper
                       ,rw_aplica.nrdconta
                       ,rw_aplica.nraplica
                       ,vr_tpaplicacao
                       ,vr_dtmvtoan);                                      
          FETCH cr_saldo                                       
           INTO vr_sldaplic;   
          CLOSE cr_saldo;  -- -- Anderson
        END IF;
        
        
        BEGIN -- -- Anderson
          /* Tenta buscar os dados do arquivo da B3*/
          vr_qtde_b3 := to_number(gene0002.fn_busca_entrada('14' -- posicao 14
                                                           ,rw_arq.dslinha
                                                           ,';'));
          vr_vlpu_b3 := to_number(gene0002.fn_busca_entrada('16' -- posicao 16
                                                           ,rw_arq.dslinha
                                                           ,';'));
          vr_vltotal_b3 := vr_qtde_b3 * vr_vlpu_b3;
        EXCEPTION
          WHEN OTHERS THEN
             vr_vltotal_b3 := 0;
             vr_qtde_b3    := 0;
             vr_vlpu_b3    := 0;
        END; -- -- Anderson
        -- Retorno do módulo e ação logado
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
        

        IF vr_fglprime = 'S' THEN
          vr_fglprime := 'N';     
          vr_cdcooper := rw_aplica.cdcooper;
          pc_coop;
        END IF;

        vr_dscri_arq          := rw_arq.dscritica;    
        vr_idtipo_arquivo     := rw_arq.idtipo_arquivo;
        vr_nmarquivo          := rw_arq.nmarquivo;
        vr_dstipo_arquivo     := rw_arq.dstipo_arquivo;
        vr_dtcriacao          := rw_arq.dtcriacao;
        vr_dtregistro         := rw_arq.dtregistro;
        vr_dtprocesso         := rw_arq.dtprocesso;
      
        vr_nrseq_linha        := rw_arq.nrseq_linha;
        vr_dscodigo_b3        := rw_arq.dscodigo_b3;
        vr_nrdconta           := rw_aplica.nrdconta;
        vr_tpaplica           := rw_aplica.tpaplica;
        vr_nraplica           := rw_aplica.nraplica;
        vr_qtcotas            := rw_aplica.qtcotas;
        vr_sldaplic_alfa      := CADA0014.fn_formata_valor(vr_sldaplic);
        vr_vltotal_b3_alfa    := CADA0014.fn_formata_valor(vr_vltotal_b3);                          
        
        IF rw_arq.dscritica IS NOT NULL THEN                
          pc_trata_arq_1;
        ELSE
          -- Se for conciliação
          IF vr_idtipo_arquivo = 9 THEN
            pc_trata_arq_2;
          END IF;
        END IF;
      
        IF pr_flgerrger THEN
          -- Quando erro geral processaremos apenas o primeiro registro
          EXIT;
        END IF;
            
        -- Retorno do módulo e ação logado
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
     
        --IF vr_qtlin_1 > 5 AND vr_qtlin_2 > 5 THEN
        --  EXIT;
        --END IF;
     
      END LOOP;

      IF vr_fglaberto_1 THEN        
        pc_fecha_arq_1;
      END IF;
      IF vr_fglaberto_2 THEN    
        pc_fecha_arq_2;
      END IF;
    
      -- Retorno do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
    
      IF vr_idtipo_arquivo <> 9 THEN  
        -- Complementar o conteudo do email caso não seja de conciliação
        vr_conteudo := vr_conteudo_1
                       || 'Lembre que o registro deve ocorrer até 2 dias úteis após sua realização, favor providenciar a correção e re-envio deste(s).'||vr_dstagque
                       || 'O processamento diário ocorre no período de '||pr_dsjanexe||' horas.'||vr_dstagque;
        -- Adicionar o caminho completo ao nome do arquivo
        vr_dsarqanx := vr_dsdirarq||'/'||vr_dsarqanx_1;
          
      ELSE
        IF vr_conteudo_1 IS NOT NULL AND  
           vr_conteudo_2 IS NOT NULL    THEN

          vr_assunto      := vr_assunto_2 ||  ' - mas também -  ' || vr_assunto_1; 
                 
          -- Conciliação teremos o caminho de rede para copiar o anexo
          vr_conteudo := 'Os arquivos encontram-se no caminho de rede abaixo: '||vr_dstagque ||
                         pr_dsredbkp||'\'||vr_dsarqanx_2 ||' '||vr_dstagque || 
                         '  -   '||vr_dstagque ||
                         pr_dsredbkp||'\'||vr_dsarqanx_1 ||' '||vr_dstagque;
          -- Limpar a variavel de nome de anexo pois não será enviado por email, mas somente na pasta
          vr_dsarqanx := NULL;
        
        ELSIF vr_conteudo_1 IS NOT NULL THEN 

          vr_assunto      := vr_assunto_1;   
          -- Conciliação teremos o caminho de rede para copiar o anexo
          vr_conteudo := vr_conteudo_1
                           || 'O arquivo encontra-se no caminho de rede abaixo: '||vr_dstagque
                           || pr_dsredbkp||'\'||vr_dsarqanx_1||' '||vr_dstagque;
          -- Limpar a variavel de nome de anexo pois não será enviado por email, mas somente na pasta
          vr_dsarqanx := NULL;
        ELSE
          
          vr_assunto      := vr_assunto_2;  
          -- Conciliação teremos o caminho de rede para copiar o anexo
          vr_conteudo := vr_conteudo_2
                           || 'O arquivo encontra-se no caminho de rede abaixo: '||vr_dstagque
                           || pr_dsredbkp||'\'||vr_dsarqanx_2||' '||vr_dstagque;
          -- Limpar a variavel de nome de anexo pois não será enviado por email, mas somente na pasta
          vr_dsarqanx := NULL;
        END IF;                
      END IF;
                
      -- Complementar o conteudo do email com texto comum
      vr_conteudo := vr_conteudo|| 'Atenciosamente,'||vr_dstagque || 'Sistema AILOS';
                  
      -- Ao final, solicitar o envio do Email
      gene0003.pc_solicita_email(pr_cdcooper        => 3 -- Fixo Central
                                ,pr_cdprogra        => 'APLI0007'
                                ,pr_des_destino     => pr_dsdemail
                                ,pr_des_assunto     => vr_assunto
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => vr_dsarqanx
                                ,pr_flg_remove_anex => 'S' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      -- Se houver erros
      IF vr_dscritic IS NOT NULL THEN
        -- Gera critica
        vr_cdcritic := 1046;
        vr_dscritic := gene0001.fn_busca_critica||pr_dsdemail||'. Detalhes: '|| vr_dscritic;
        RAISE vr_exc_saida_mail_alerta;
      END IF;
      
	  
      -- Controle Saida  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            '. Finalizado' ||
                            '. '      || vr_nmaction ||
                            '. '      || vr_nmproint1
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            ); 

    EXCEPTION
      WHEN vr_exc_saida_mail_alerta THEN
        vr_cdcritic := NVL(vr_cdcritic,0);
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic) ||
                           ' ' || vr_nmaction  ||
                           ' ' || vr_nmproint1 ||
                           ' ' || vr_dsparame  ||
                           ' ' || vr_nomdojob;
        pr_idcritic := 1; -- Media   
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic
              ,pr_cdcricid => pr_idcritic);    
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Acionar log exceções internas
        CECRED.pc_internal_exception(pr_cdcooper => 3);
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                           ' ' || SQLERRM      ||
                           ' ' || vr_nmaction  ||
                           ' ' || vr_nmproint1 ||
                           ' ' || vr_dsparame  ||
                           ' ' || vr_nomdojob; 
        pr_idcritic := 2; -- Alta                  
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic
              ,pr_cdcricid => pr_idcritic);    
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
    END;
  END pc_envia_email_alerta_arq;

  -- Função para buscar o saldo da aplicação no dia anterior a data passada
  PROCEDURE pc_busca_saldo_anterior(pr_cdcooper  IN craprda.cdcooper%TYPE                  --> Cooperativa
                                   ,pr_nrdconta  IN craprda.nrdconta%TYPE                  --> Conta
                                   ,pr_nraplica  IN craprda.nraplica%TYPE                  --> Aplicação
                                   ,pr_tpaplica  IN crapdtc.tpaplica%TYPE                  --> Tipo aplicacao
                                   ,pr_cdprodut  IN craprac.cdprodut%TYPE                  --> Codigo produto
                                   ,pr_dtmvtolt  IN craprda.dtmvtolt%TYPE                  --> Data movimento
                                   ,pr_dtmvtsld  IN craprda.dtmvtolt%TYPE                  --> Data do saldo desejado
                                   ,pr_tpconsul  IN VARCHAR2                               --> [C]onciliação ou [R]esgate
                                   ,pr_sldaplic OUT craprda.vlsdrdca%TYPE                  --> Saldo no dia desejado
                                   ,pr_idcritic OUT NUMBER                                 --> Criticidade da saida
                                   ,pr_dssqlerr OUT VARCHAR2
                                   ,pr_cdcritic OUT NUMBER                                 --> Código da critica
                                   ,pr_dscritic OUT VARCHAR2) IS                           --> Descrição da critica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc busca saldo_anterior
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Maio/2018.                   Ultima atualizacao: 03/04/2019
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Diário
    -- Objetivo  : Procedimento responsável por varrer o extrato de aplicação buscando pelo saldo no dia
    --             anterior ao resgate para cálculo da P.U. naquele dia
    --
    -- Alteracoes:
    --             03/04/2019 - Projeto 411 - Fase 2 - Parte 2 - Conciliação Despesa B3 e Outros Detalhes
    --                          Ajusta mensagens de erros e trata de forma a permitir a monitoração automatica.
    --                          Procedimento de Log - tabela: tbgen prglog ocorrencia 
    --                         (Envolti - Belli - PJ411_F2_P2)
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Busca dos dados da Aplicação em rotina já preparada
      vr_tbsaldo_rdca     APLI0001.typ_tab_saldo_rdca;
      vr_tab_extrato_rdca cecred.APLI0002.typ_tab_extrato_rdca;
      vr_tab_extrato      apli0005.typ_tab_extrato;
      -- Auxiliares
      vr_vlresgat NUMBER;
      vr_vlrendim NUMBER;
      vr_vldoirrf NUMBER;
      vr_txacumul NUMBER;                  -- Taxa acumulada durante o período total da aplicação
      vr_txacumes NUMBER;                  -- Taxa acumulada durante o mês vigente
      vr_percirrf NUMBER;
      vr_vlsldapl NUMBER;
      vr_cdagenci crapage.cdagenci%TYPE := 1;
      -- Indices das temp-tables
      vr_index_extrato_rdca PLS_INTEGER;
      --
      vr_nmproint1               VARCHAR2 (100) := 'pc_busca_saldo_anterior';
      vr_des_reto                VARCHAR2 (100);
      vr_exc_saida_bus_sal_ant_1 EXCEPTION;
      
    BEGIN
      
      -- Inicializar retorno
      pr_sldaplic := 0;
      -- Limpar toda a tabela de memória
      vr_tbsaldo_rdca.DELETE();

      -- Caso aplicação nova
      IF pr_tpaplica > 2 THEN
        -- Busca a listagem de aplicacoes
        APLI0008.pc_lista_aplicacoes_progr(pr_cdcooper   => pr_cdcooper          -- Código da Cooperativa   
                                    ,pr_cdoperad   => '1'                  -- Código do Operador
                                    ,pr_nmdatela   => 'CUSAPL'             -- Nome da Tela
                                    ,pr_idorigem   => 5                    -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA )
                                    ,pr_nrdcaixa   => 1                    -- Numero do Caixa
                                    ,pr_nrdconta   => pr_nrdconta          -- Número da Conta
                                    ,pr_idseqttl   => 1                    -- Titular da Conta
                                    ,pr_cdagenci   => 1                    -- Codigo da Agencia
                                    ,pr_cdprogra   => 'CUSAPL'             -- Codigo do Programa
                                    ,pr_nraplica   => pr_nraplica          -- Número da Aplicaçao
                                    ,pr_cdprodut   => pr_cdprodut          -- Código do Produto
                                    ,pr_dtmvtolt   => pr_dtmvtolt          -- Data de Movimento
                                    ,pr_idconsul   => 5                    -- Todas
                                    ,pr_idgerlog   => 0                    -- Identificador de Log (0 – Nao / 1 – Sim)
                                    ,pr_tpaplica   => 2                    -- Tipo Aplicacao (0 - Todas / 1 - Não PCAPTA (RDC PÓS, PRE e RDCA) / 2 - Apenas PCAPTA)
                                    ,pr_cdcritic   => vr_cdcritic          -- Código da crítica
                                    ,pr_dscritic   => vr_dscritic          -- Descriçao da crítica
                                    ,pr_saldo_rdca => vr_tbsaldo_rdca);   -- Retorno das aplicações

        -- Verifica se ocorreram erros
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Montar mensagem de critica
          RAISE vr_exc_saida_bus_sal_ant_1;
        ELSIF vr_tbsaldo_rdca.count() = 0 THEN
          vr_cdcritic := 426;
          RAISE vr_exc_saida_bus_sal_ant_1;
        END IF;
      ELSE
        -- Consulta de aplicacoes antigas
        APLI0001.pc_consulta_aplicacoes(pr_cdcooper   => pr_cdcooper   --> Cooperativa
                                       ,pr_cdagenci   => 1             --> Codigo da agencia
                                       ,pr_nrdcaixa   => 1             --> Numero do caixa
                                       ,pr_nrdconta   => pr_nrdconta   --> Conta do associado
                                       ,pr_nraplica   => pr_nraplica   --> Numero da aplicacao
                                       ,pr_tpaplica   => 0             --> Tipo de aplicacao
                                       ,pr_dtinicio   => pr_dtmvtsld   --> Data de inicio da aplicacao
                                       ,pr_dtfim      => pr_dtmvtolt   --> Data final da aplicacao    
                                       ,pr_cdprogra   => 'CUSAPL'      --> Codigo do programa chamador da rotina
                                       ,pr_nrorigem   => 5             --> Origem da chamada da rotina
                                       ,pr_saldo_rdca => vr_tbsaldo_rdca --> Tipo de tabela com o saldo RDCA
                                       ,pr_des_reto   => vr_des_reto   --> OK ou NOK
                                       ,pr_tab_erro   => vr_tab_erro); --> Tabela com erros
        -- Verifica se ocorreram erros
        IF vr_des_reto = 'NOK' THEN
          -- Se existir erro adiciona na crítica
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          -- Montar mensagem de critica
          RAISE vr_exc_saida_bus_sal_ant_1;
        ELSIF vr_tbsaldo_rdca.count() = 0 THEN
          vr_cdcritic := 426;
          RAISE vr_exc_saida_bus_sal_ant_1;
        END IF;
      END IF;
      
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);

      -- Retornaremos o saldo já encontrado
      IF vr_tbsaldo_rdca.exists(vr_tbsaldo_rdca.FIRST) THEN
        pr_sldaplic := vr_tbsaldo_rdca(vr_tbsaldo_rdca.FIRST).VLSDRDAD;
      ELSE
        pr_sldaplic := 0;
      END IF;

      -- Somente quando resgate
      IF pr_tpconsul = 'R' AND pr_dtmvtsld IS NOT NULL THEN
        -- Buscar na pltable dos dados da aplicação
        FOR vr_idx IN vr_tbsaldo_rdca.FIRST..vr_tbsaldo_rdca.LAST LOOP
          IF vr_tbsaldo_rdca.exists(vr_idx) THEN
            -- Buscar o extrato da aplicação para termos a posição do saldo em determinado dia
            --Limpar tabela extrato rdca
            vr_tab_extrato_rdca.DELETE;
            IF vr_tbsaldo_rdca(vr_idx).idtipapl = 'N' THEN
              -- Procedure para buscar informações da aplicação
              APLI0005.pc_busca_extrato_aplicacao(pr_cdcooper => pr_cdcooper        -- Código da Cooperativa
                                                 ,pr_cdoperad => '1'                -- Código do Operador
                                                 ,pr_nmdatela => 'EXTRDA'           -- Nome da Tela
                                                 ,pr_idorigem => 5                  -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                                 ,pr_nrdconta => pr_nrdconta        -- Número da Conta
                                                 ,pr_idseqttl => 1                  -- Titular da Conta
                                                 ,pr_dtmvtolt => pr_dtmvtolt        -- Data de Movimento
                                                 ,pr_nraplica => vr_tbsaldo_rdca(vr_idx).nraplica        -- Número da Aplicação
                                                 ,pr_idlstdhs => 0                  -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                                 ,pr_idgerlog => 0                  -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                                 ,pr_tab_extrato => vr_tab_extrato  -- PLTable com os dados de extrato
                                                 ,pr_vlresgat => vr_vlresgat        -- Valor de resgate
                                                 ,pr_vlrendim => vr_vlrendim        -- Valor de rendimento
                                                 ,pr_vldoirrf => vr_vldoirrf        -- Valor do IRRF
                                                 ,pr_txacumul => vr_txacumul        -- Taxa acumulada durante o período total da aplicação
                                                 ,pr_txacumes => vr_txacumes        -- Taxa acumulada durante o mês vigente
                                                 ,pr_percirrf => vr_percirrf         -- Valor de aliquota de IR
                                                 ,pr_cdcritic => vr_cdcritic        -- Código da crítica
                                                 ,pr_dscritic => vr_dscritic);       -- Descrição da crítica

              -- Se retornou alguma critica
              IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida_bus_sal_ant_1;
              ELSE
                -- Retorno nome do módulo logado
                GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);

                -- Converter o vetor de extrato de aplicações captação em aplicações antigas para reaproveitamento de código
                IF vr_tab_extrato.COUNT > 0 THEN
                  -- Percorre todos os registros da aplicação
                  FOR vr_contador IN vr_tab_extrato.FIRST..vr_tab_extrato.LAST LOOP
                    -- Proximo indice da tabela vr_tab_extrato
                    vr_index_extrato_rdca:= vr_tab_extrato_rdca.COUNT + 1;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).dtmvtolt := vr_tab_extrato(vr_contador).DTMVTOLT;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).dshistor := vr_tab_extrato(vr_contador).DSHISTOR;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).nrdocmto := vr_tab_extrato(vr_contador).NRDOCMTO;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).indebcre := vr_tab_extrato(vr_contador).INDEBCRE;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).vllanmto := NVL(vr_tab_extrato(vr_contador).VLLANMTO,0);
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).vlsldapl := NVL(vr_tab_extrato(vr_contador).VLSLDTOT,0);
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).txaplica := NVL(vr_tab_extrato(vr_contador).TXLANCTO,0);
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).dsaplica := vr_tbsaldo_rdca(vr_idx).DSAPLICA;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).cdagenci := vr_cdagenci;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).vlpvlrgt := vr_vlresgat;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).cdhistor := vr_tab_extrato(vr_contador).CDHISTOR;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).tpaplrdc := 1;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).dsextrat := vr_tab_extrato(vr_contador).DSEXTRAT;
                  END LOOP;
                END IF;
              END IF;
            ELSE
              --Consultar Extrato RDCA
              APLI0002.pc_consulta_extrato_rdca (pr_cdcooper    => pr_cdcooper       --Codigo Cooperativa
                                                ,pr_cdageope    => 1                 --Codigo Agencia
                                                ,pr_nrcxaope    => 1                 --Numero do Caixa
                                                ,pr_cdoperad    => '1'               --Codigo Operador
                                                ,pr_nmdatela    => 'IMPRES'          --Nome da Tela
                                                ,pr_nrdconta    => pr_nrdconta       --Numero da Conta do Associado
                                                ,pr_idseqttl    => 1                 --Sequencial do Titular
                                                ,pr_dtmvtolt    => pr_dtmvtolt       --Data do movimento
                                                ,pr_nraplica    => vr_tbsaldo_rdca(vr_idx).nraplica       --Numero Aplicacao
                                                ,pr_tpaplica    => 0                 --Tipo Aplicacao
                                                ,pr_vlsdrdca    => vr_vlsldapl       --Valor Saldo RDCA
                                                ,pr_dtiniper    => NULL              --Periodo inicial
                                                ,pr_dtfimper    => NULL              --Periodo Final
                                                ,pr_cdprogra    => 'IMPRES'          --Nome da Tela
                                                ,pr_idorigem    => 5                 --Origem dos Dados
                                                ,pr_flgerlog    => FALSE             --Imprimir log
                                                ,pr_tab_extrato_rdca => vr_tab_extrato_rdca  --Tabela Extrato Aplicacao RDCA
                                                ,pr_des_reto     => vr_des_reto        --Retorno OK ou NOK
                                                ,pr_tab_erro     => vr_tab_erro);      --Tabela de Erros
              -- Se retornou erro
              IF vr_des_reto = 'NOK' THEN
                --Se possuir erro na temp-table
                IF vr_tab_erro.COUNT > 0 THEN
                  vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                  vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                ELSE
                  vr_cdcritic:= 1494; -- Nao foi possivel carregar o extrato
                END IF;
                RAISE vr_exc_saida_bus_sal_ant_1;
              END IF;
              -- Retorno nome do módulo logado
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);

            END IF;

            -- Percorrer todos os extratos rdca
            vr_index_extrato_rdca:= vr_tab_extrato_rdca.FIRST;
            WHILE vr_index_extrato_rdca IS NOT NULL LOOP
              -- Se o próximo evento for de data posterior ao resgate
              -- ou chegarmos no dia do resgate e for um histórico de provisão ou rendimento
              IF vr_index_extrato_rdca = vr_tab_extrato_rdca.last
              OR vr_tab_extrato_rdca(vr_tab_extrato_rdca.next(vr_index_extrato_rdca)).dtmvtolt > pr_dtmvtsld
              OR (vr_tab_extrato_rdca(vr_index_extrato_rdca).dtmvtolt = pr_dtmvtsld AND fn_valida_histor_rendim(pr_tpaplica,pr_cdprodut,vr_tab_extrato_rdca(vr_index_extrato_rdca).cdhistor)) THEN
                -- Guardar o saldo
                pr_sldaplic := vr_tab_extrato_rdca(vr_index_extrato_rdca).vlsldapl;
                -- Não necessário mais efetuar busca
                vr_index_extrato_rdca := vr_tab_extrato_rdca.last;
              END IF;
              -- Proximo registro
              vr_index_extrato_rdca:= vr_tab_extrato_rdca.NEXT(vr_index_extrato_rdca);
            END LOOP;
          END IF;
        END LOOP;
      END IF;
                        
      -- Forçado erro - Teste Belli      
      ---vr_cdcritic := 0 / 0;

    EXCEPTION
      WHEN vr_exc_saida_bus_sal_ant_1 THEN
        vr_cdcritic := NVL(vr_cdcritic,0);
        vr_dscritic := ' ' || vr_nmproint1 ||
                       ' ' || vr_dscritic;
        pr_idcritic := 1; -- Media   
        pr_dssqlerr := NULL; 
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;  
        vr_cdcritic := NULL;
        vr_dscritic := NULL;
      WHEN OTHERS THEN
        -- Acionar log exceções internas
        CECRED.pc_internal_exception(pr_cdcooper => 3);
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := ' ' || vr_nmproint1; 
        pr_dssqlerr := SQLERRM;
        pr_idcritic := 2; -- Alta      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;    
        vr_cdcritic := NULL;
        vr_dscritic := NULL;

    END;
  END pc_busca_saldo_anterior;


  -- Varrer os lançamentos e criar registros para envio de Custódia
  PROCEDURE pc_verifi_lanctos_custodia(pr_flenvreg IN VARCHAR2      --> Envio de Registros Habilidade
                                      ,pr_flenvrgt IN VARCHAR2      --> Envio de Operações Habilitado
                                      ,pr_dsdaviso OUT VARCHAR2     --> Avisos dos eventos ocorridos no processo
                                      ,pr_idcritic OUT NUMBER       --> Criticidade da saida
                                      ,pr_cdcritic OUT NUMBER       --> Código da critica
                                      ,pr_dscritic OUT VARCHAR2) IS --> Saida de possível critica no processo
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc verifi lanctos custodia
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 03/04/2019
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Diário
    -- Objetivo  : Procedimento responsável por varrer as tabelas de Lançamento das Aplicações
    --             e identificar registros de Cadastro ou Operações da Aplicação para então gerar
    --             pendências de envio ao B3
    --
    -- Alteracoes:
    --             03/04/2019 - Projeto 411 - Fase 2 - Parte 2 - Conciliação Despesa B3 e Outros Detalhes
    --                          Ajusta mensagens de erros e trata de forma a permitir a monitoração automatica.
    --                          Procedimento de Log - tabela: tbgen prglog ocorrencia 
    --                         (Envolti - Belli - PJ411_F2_P2)
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Dia útil anterior ao dtmvtoan (2 dias atrás)
      vr_dtmvto2a DATE;

      -- Busca de todas as Cooperativas ativas com exceção da Central
      CURSOR cr_crapcop IS
        SELECT cdcooper
          FROM crapcop
         WHERE cdcooper <> 3 /* teste Anderson  and cdcooper = 7 */
           AND flgativo = 1;

      -- Parâmetros de Sistema
      vr_dtinictd DATE;        --> Data de início da Custódia
      vr_vlinictd NUMBER;      --> Valor mínimo envio Custódia

      -- Busca do calendário da Cooperativa
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      vr_exc_sai_lan_arq_1       EXCEPTION;
      vr_exc_sai_lan_arq_1_S     EXCEPTION;
      vr_exc_sai_lan_arq_lop_1   EXCEPTION;
      vr_exc_sai_lan_arq_lop_1_S EXCEPTION;
      vr_exc_sai_lan_arq_lop_2_A EXCEPTION;
      vr_exc_sai_lan_arq_lop_2_B EXCEPTION;
      
      vr_nmproint1               VARCHAR2  (100) := 'pc_verifi_lanctos_custodia';      
      vr_dssqlerrm               VARCHAR2 (4000) := NULL;
      vr_dsparlp1                VARCHAR2 (4000) := NULL;
      vr_dsparlp2                VARCHAR2 (4000) := NULL;
      vr_dsparesp                VARCHAR2 (4000) := NULL;
      vr_qtlimerr                NUMBER      (9);
      --vr_qterro_1493             NUMBER      (9) := 0; -- Forçada variavel Teste Belli

      -- Busca dos lançamentos de aplicação dos ultimos 2 dias
      CURSOR cr_lctos(pr_cdcooper NUMBER
                     ,pr_dtmvtoan DATE
                     ,pr_dtmvtolt DATE
                     ,pr_dtinictd DATE
                     ,pr_vlminctd NUMBER) IS
        -- RDC Pré e RDC Pós
        SELECT rda.rowid rowid_apl
              ,lap.rowid rowid_lct
              ,hst.tpaplicacao tpaplrdc
              ,lap.dtmvtolt
              ,lap.cdhistor
              ,lap.vllanmto
              ,hst.idtipo_arquivo
              ,hst.idtipo_lancto
              ,hst.cdoperacao_b3
              ,rda.nrdconta nrdconta
              ,rda.nraplica nraplica
              ,0            cdprodut
          FROM craplap lap
              ,craprda rda
              ,crapdtc dtc
              ,vw_capt_histor_operac hst
         WHERE rda.cdcooper = dtc.cdcooper
           AND rda.tpaplica = dtc.tpaplica
           AND lap.cdcooper = rda.cdcooper
           AND lap.nrdconta = rda.nrdconta
           AND lap.nraplica = rda.nraplica
           AND lap.cdcooper = pr_cdcooper
           -- Históricos de Aplicação
           AND hst.idtipo_arquivo = 1 -- Aplicação
           AND hst.tpaplicacao = dtc.tpaplrdc
           AND hst.cdhistorico = lap.cdhistor
           -- Utilizar a maior data entre os dois dias úteis anteriores
           -- e a data de início de envio das aplicações para custódia B3
           AND lap.dtmvtolt >= greatest(pr_dtmvtoan,pr_dtinictd)
       -- E não podem ser do dia atual
           AND lap.dtmvtolt < pr_dtmvtolt
           --> Aplicação não custodiada ainda
           AND nvl(rda.idaplcus,0) = 0
           --> Registro não custodiado ainda
           AND nvl(lap.idlctcus,0) = 0
           --> Valor de aplicação maior ou igual ao valor mínimo
           AND lap.vllanmto >= nvl(pr_vlminctd,0)
        UNION
        -- Produtos de Captação
        SELECT rac.rowid
              ,lac.rowid
              ,hst.tpaplicacao
              ,lac.dtmvtolt
              ,lac.cdhistor
              ,lac.vllanmto
              ,hst.idtipo_arquivo
              ,hst.idtipo_lancto
              ,hst.cdoperacao_b3
              ,rac.nrdconta nrdconta
              ,rac.nraplica nraplica
              ,rac.cdprodut cdprodut
          FROM craplac lac
              ,craprac rac
              ,vw_capt_histor_operac hst
         WHERE rac.cdcooper = lac.cdcooper
           AND rac.nrdconta = lac.nrdconta
           AND rac.nraplica = lac.nraplica
           AND lac.cdcooper = pr_cdcooper
           -- Históricos de Aplicação
           AND hst.idtipo_arquivo = 1 -- Aplicação
           AND hst.tpaplicacao in(3,4)
           AND hst.cdprodut    = rac.cdprodut
           AND hst.cdhistorico = lac.cdhistor
           -- Utilizar a maior data entre os dois dias úteis anteriores
           -- e a data de início de envio das aplicações para custódia B3
           AND lac.dtmvtolt >= greatest(pr_dtmvtoan,pr_dtinictd)
       -- E não podem ser do dia atual
           AND lac.dtmvtolt < pr_dtmvtolt
           --> Aplicação não custodiada ainda
           AND nvl(rac.idaplcus,0) = 0
           --> Registro não custodiado ainda
           AND nvl(lac.idlctcus,0) = 0
           --> Valor de aplicação maior ou igual ao valor mínimo
           AND lac.vllanmto >= nvl(pr_vlminctd,0);

      -- Busca das Operações nas aplicações custodiadas não enviados a B3
      CURSOR cr_lctos_rgt(pr_cdcooper NUMBER
                         ,pr_dtmvtoan DATE
                         ,pr_dtmvtolt DATE
                         ,pr_dtinictd DATE) IS
        -- RDC Pré e RDC Pós
        SELECT *
          FROM (SELECT rda.idaplcus
                      ,lap.rowid rowid_lct
                      ,hst.tpaplicacao tpaplrdc
                      ,lap.nrdconta
                      ,lap.nraplica
                      ,0 cdprodut
                      ,lap.dtmvtolt
                      ,lap.cdhistor
                      ,lap.vllanmto * decode(hst.idtipo_lancto,4 /* Rendimento */,-1, 1) vllanmto
                      ,hst.idtipo_arquivo
                      ,hst.idtipo_lancto
                      ,hst.cdoperacao_b3
                      ,capl.qtcotas
                      ,capl.vlpreco_registro
                      ,rda.dtmvtolt dtmvtapl
                      ,decode(capl.tpaplicacao,1,rda.qtdiaapl,rda.qtdiauti) qtdiacar
                      ,lap.progress_recid
                      ,lap.vlpvlrgt valorbase
                      ,hst.cdhistorico
                      ,to_char(lap.progress_recid) ordena
                  FROM craplap lap
                      ,craprda rda
                      ,crapdtc dtc
                      ,tbcapt_custodia_aplicacao capl
                      ,vw_capt_histor_operac hst
                 WHERE rda.cdcooper = dtc.cdcooper
                   AND rda.tpaplica = dtc.tpaplica
                   AND lap.cdcooper = rda.cdcooper
                   AND lap.nrdconta = rda.nrdconta
                   AND lap.nraplica = rda.nraplica
                   AND lap.cdcooper = pr_cdcooper
                   AND rda.idaplcus = capl.idaplicacao
                   -- Somente resgates antecipados
                   AND ( lap.dtmvtolt < rda.dtvencto)
                   -- Utilizar a maior data entre os dois dias úteis anteriores
                   -- e a data de início de envio das aplicações para custódia B3
                   AND lap.dtmvtolt >= greatest(pr_dtmvtoan,pr_dtinictd)
                   -- E não podem ser do dia atual
                   AND lap.dtmvtolt < pr_dtmvtolt
                   -- Históricos de Resgate
                   AND hst.idtipo_arquivo = 2 -- Resgate
                   AND hst.tpaplicacao = dtc.tpaplrdc
                   AND hst.cdhistorico = lap.cdhistor
                   --> Registro não custodiado ainda
                   AND nvl(lap.idlctcus,0) = 0
                   --> Aplicação já custodiada
                   AND nvl(rda.idaplcus,0) > 0
                   AND capl.dscodigo_b3 IS NOT NULL
                UNION
                  -- Produtos de Captação
                SELECT rac.idaplcus
                      ,lac.rowid
                      ,hst.tpaplicacao
                      ,lac.nrdconta
                      ,lac.nraplica
                      ,rac.cdprodut
                      ,lac.dtmvtolt
                      ,lac.cdhistor
                      ,lac.vllanmto * decode(hst.idtipo_lancto,4 /* Rendimento */,-1, 1) vllanmto
                      ,hst.idtipo_arquivo
                      ,hst.idtipo_lancto
                      ,hst.cdoperacao_b3
                      ,capl.qtcotas
                      ,capl.vlpreco_registro
                      ,rac.dtmvtolt dtmvtapl
                      ,rac.qtdiacar
                      ,lac.progress_recid
                      ,lac.vlbasren valorbase
                      ,hst.cdhistorico
                      ,lpad(nrseqrgt,10,0)||hst.idtipo_lancto ordena
                  FROM craplac lac
                      ,craprac rac
                      ,tbcapt_custodia_aplicacao capl
                      ,vw_capt_histor_operac hst
                 WHERE rac.cdcooper = lac.cdcooper
                   AND rac.nrdconta = lac.nrdconta
                   AND rac.nraplica = lac.nraplica
                   AND lac.cdcooper = pr_cdcooper
                   AND rac.idaplcus = capl.idaplicacao
                   -- Somente resgates antecipados OU IRRF
                   AND ( lac.dtmvtolt < rac.dtvencto OR hst.idtipo_lancto = 3 )
                   -- Utilizar a maior data entre os dois dias úteis anteriores
                   -- e a data de início de envio das aplicações para custódia B3
                   AND lac.dtmvtolt >= greatest(pr_dtmvtoan,pr_dtinictd)
                   -- E não podem ser do dia atual
                   AND lac.dtmvtolt < pr_dtmvtolt
                   -- Históricos de Resgate
                   AND hst.idtipo_arquivo = 2 -- Resgate
                   AND hst.tpaplicacao IN(3,4)
                   AND hst.cdprodut    = rac.cdprodut
                   AND hst.cdhistorico = lac.cdhistor
                   --> Registro não custodiado ainda
                   AND nvl(lac.idlctcus,0) = 0
                   --> Aplicação já custodiada
                   AND nvl(rac.idaplcus,0) > 0
                   AND capl.dscodigo_b3 IS NOT NULL) lct
         -- Removido histórico de IRRF (David Valente P411.3 RF1) lct.cdhistorico NOT IN(2744,476, 533) 
         ORDER BY lct.dtmvtolt
                 ,lct.nrdconta
                 ,lct.nraplica
                 --,lct.progress_recid desc; /* Necessario para calcular o valor base */
                 ,lct.ordena desc;

      -- Valor total de resgate no dia
      CURSOR cr_resgat(pr_cdcooper crapcop.cdcooper%TYPE     --> Cooperativa
                      ,pr_nrdconta craprda.nrdconta%TYPE     --> Conta
                      ,pr_nraplica craprda.nraplica%TYPE     --> Aplicação
                      ,pr_tpaplrdc craprda.tpaplica%TYPE     --> TIpo da aplicação
                      ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS --> Data
        SELECT sum(nvl(lct.vllanmto,0))
          FROM (SELECT lap.vllanmto
                  FROM craplap lap
                      ,vw_capt_histor_operac hst
                 WHERE lap.cdcooper = pr_cdcooper
                   AND lap.nrdconta = pr_nrdconta
                   AND lap.nraplica = pr_nraplica
                   AND lap.dtmvtolt = pr_dtmvtolt
                   -- Históricos de Resgate
                   AND hst.idtipo_arquivo = 2 -- Resgate
                   AND hst.tpaplicacao = pr_tpaplrdc
                   AND hst.cdhistorico = lap.cdhistor
                   AND hst.idtipo_lancto = 2 -- Somente Resgate
                UNION
                  -- Produtos de Captação
                SELECT lac.vllanmto
                  FROM craplac lac
                      ,vw_capt_histor_operac hst
                 WHERE lac.cdcooper = pr_cdcooper
                   AND lac.nrdconta = pr_nrdconta
                   AND lac.nraplica = pr_nraplica
                   AND lac.dtmvtolt = pr_dtmvtolt
                   -- Históricos de Resgate
                   AND hst.idtipo_arquivo = 2 -- Resgate
                   AND hst.tpaplicacao = pr_tpaplrdc
                   AND hst.cdhistorico = lac.cdhistor
                   AND hst.idtipo_lancto = 2 -- Somente Resgate
                 ) lct;

      -- Conversão valor em cota
      vr_qtcotas      tbcapt_custodia_aplicacao.qtcotas%TYPE;

      -- Variaveis para armazenar os IDs de aplicação e Registros Lanctos criados
      vr_idaplicacao  tbcapt_custodia_aplicacao.idaplicacao%TYPE;
      vr_idlancamento tbcapt_custodia_lanctos.idlancamento%TYPE;

      -- Variaveis para controle de troca de Data+Conta+Aplica
      vr_dtmvtolt DATE;
      vr_nrdconta craprda.nrdconta%TYPE;
      vr_nraplica craprda.nraplica%TYPE;

      -- Saldo da aplicação + cotas do resgate
      vr_sldaplic     craprda.vlsdrdca%TYPE;
      --vr_vlpreco_unit tbcapt_custodia_aplicacao.vlpreco_unitario%TYPE; --NUMBER(25,8)
      vr_vlpreco_unit NUMBER(38,30);
      vr_vlbase       NUMBER(38,30);
      vr_qtcotas_resg tbcapt_custodia_aplicacao.qtcotas%TYPE;

      -- Controle de lançamento anterior
      /*vr_cdhistor_ant craphis.cdhistor%TYPE;
      vr_idlancto_ant tbcapt_custodia_lanctos.idlancamento%TYPE;*/

      -- variaveis de contadores para geração de LOG
      vr_qtregrgt NUMBER := 0;
      vr_qtregreg NUMBER := 0;

    PROCEDURE pc_finaliza
      IS 
    BEGIN
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := NVL(vr_cdcritic,0);
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic) ||
                           ' ' || vr_dssqlerrm ||
                           ' ' || vr_nomdojob  ||
                           ' ' || vr_nmaction  ||
                           ' ' || vr_nmproint1 ||
                           ' ' || vr_dsparame  ||
                           ' ' || vr_dsparlp1  ||
                           ' ' || vr_dsparlp2  ||
                           ' ' || vr_dsparesp;   
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic
              ,pr_cdcricid => pr_idcritic);    
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK; 
    END pc_finaliza;
    --

    PROCEDURE pc_critica_loop
      IS 
    BEGIN 
            -- Efetuar retorno do erro nao tratado
            vr_cdcritic := NVL(vr_cdcritic,0);
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                                    ,pr_dscritic => vr_dscritic) ||
                           ' ' || vr_dssqlerrm ||
                           ' ' || vr_nomdojob  ||
                           ' ' || vr_nmaction  ||
                           ' ' || vr_nmproint1 ||
                           ' ' || vr_dsparame  ||
                           ' ' || vr_dsparlp1  ||
                           ' ' || vr_dsparlp2  ||
                           ' ' || vr_dsparesp;                      
            -- Log de erro de execucao
            pc_log(pr_cdcritic => vr_cdcritic
                  ,pr_dscrilog => vr_dscritic
                  ,pr_cdcricid => pr_idcritic); 
    END pc_critica_loop;
     
      
    BEGIN   --     PRINCIPAL   INICIO
      
      vr_dsparlp1  := NULL;
      vr_dsparlp2  := NULL;
      vr_dsparesp  := NULL;
      vr_dssqlerrm := NULL;      
      vr_cdcritic  := NULL;
      vr_dscritic  := NULL;
                
      -- Incluir Email
      pr_dsdaviso := '<br><br>' || fn_get_time_char || vr_dspro002_E;
      -- Limite de erros no processo de envio de arquivo ao fornecedor => B3
      vr_qtlimerr := gene0001.fn_param_sistema('CRED',0,'LIMERRO_ENV_REG_CTD_B3');
      vr_qtlimerr := NVL(vr_qtlimerr,0);         
      -- Controle Entrada  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            ' ' || vr_nmaction  ||
                            ' ' || vr_nmproint1 ||
                            ' ' || vr_dsparame  ||
                            ', vr_qtlimerr:'    || vr_qtlimerr
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            ); 
      -- Forçado erro - Teste Belli
     --- vr_cdcritic := 0 / 0;

      -- Buscar todas as cooperatiVas ativas com exceção da Central
      FOR rw_cop IN cr_crapcop LOOP
      BEGIN
          
        vr_dsparlp1  := ', cdcooper ' || rw_cop.cdcooper;
        vr_dsparlp2  := NULL;
        vr_dsparesp  := NULL;
        vr_dssqlerrm := NULL;
        
        -- Verifica se a data esta cadastrada
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_cop.cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        -- Se nao encontrar
        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois havera raise
          CLOSE BTCH0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic := 1;
          pr_idcritic := 1; -- Media    
          RAISE vr_exc_sai_lan_arq_lop_1;
        ELSE
          -- Apenas fechar o cursor
          CLOSE BTCH0001.cr_crapdat;
        END IF;
        
        vr_dsparlp1  := ', cdcooper:' || rw_cop.cdcooper     ||
                        ', dtmvtolt:' || rw_crapdat.dtmvtolt ||
                        ', dtmvtoan:' || rw_crapdat.dtmvtoan;

        -- Buscar o dia útil anterior ao dtmvtoan, ou seja, iremos buscar 2 dias úteis atrás
        vr_dtmvto2a := gene0005.fn_valida_dia_util(pr_cdcooper => rw_cop.cdcooper
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtoan -1
                                                  ,pr_tipo => 'A');
        -- Se por acaso der algum erro
        IF vr_dtmvto2a IS NULL THEN
          -- Montar mensagem de critica
          vr_cdcritic:= 13;
          pr_idcritic := 1; -- Media    
          RAISE vr_exc_sai_lan_arq_lop_1;
        END IF;        
        -- Retorno nome do módulo logado
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);

        -- Buscar parâmetros de sistema
        vr_dtinictd := to_date(gene0001.fn_param_sistema('CRED',rw_cop.cdcooper,'INIC_CUSTODIA_APLICA_B3'),'dd/mm/rrrr');
        vr_vlinictd := to_number(gene0001.fn_param_sistema('CRED',rw_cop.cdcooper,'VLMIN_CUSTOD_APLICA_B3'),'FM999999990D00');
        -- Retorno nome do módulo logado
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
        
        vr_dsparlp1 := ', cdcooper:' || rw_cop.cdcooper     ||
                       ', dtmvtolt:' || rw_crapdat.dtmvtolt ||
                       ', dtmvtoan:' || rw_crapdat.dtmvtoan ||
                       ', vr_dtmvto2a:' || vr_dtmvto2a      ||
                       ', vr_dtinictd:' || vr_dtinictd      ||
                       ', vr_vlinictd:' || vr_vlinictd;
        
        -- Caso esteja habilitado o processo de registro das aplicações na B3
        IF pr_flenvreg = 'S' THEN
                
          -- Buscar todos os movimentos de aplicação dos últimos 2 dias
          -- que ainda não estejam marcados para envio (idlctcus is null)
          FOR rw_lcto IN cr_lctos(rw_cop.cdcooper,vr_dtmvto2a,rw_crapdat.dtmvtolt,vr_dtinictd,vr_vlinictd) LOOP
          BEGIN
            -- Incrementar contador de Registros
            vr_qtregreg := vr_qtregreg + 1;
            vr_dsparlp2 :=  ',L2A rw_lcto, cdhistor:'   || rw_lcto.cdhistor       ||
                            ', pr_nrdconta:'    || rw_lcto.nrdconta       ||
                            ', pr_nraplica:'    || rw_lcto.nraplica       ||
                            ', pr_tpaplica:'    || rw_lcto.tpaplrdc       ||
                            ', pr_cdprodut:'    || rw_lcto.cdprodut       ||
                            ', cdoperacao_b3:'  || rw_lcto.cdoperacao_b3  ||
                            ', idtipo_arquivo:' || rw_lcto.idtipo_arquivo ||
                            ', idtipo_lancto:'  || rw_lcto.idtipo_lancto  ||
                            ', cdhistor:'       || rw_lcto.cdhistor       ||
                            ', dtmvtolt:'       || rw_lcto.dtmvtolt       ||
                            ', vllanmto:'       || rw_lcto.vllanmto       ||
                            ', vr_qtregreg:'    || vr_qtregreg;    
            vr_dsparesp  := NULL;
            vr_dssqlerrm := NULL;
                         
      -- Forçado erro - Teste Belli      
      ---IF vr_qtregreg > 10 THEN
      --- vr_cdcritic := 0 / 0;
      ---END IF;
                
            -- Converter valor aplicação em contas
            vr_qtcotas := fn_converte_valor_em_cota(rw_lcto.vllanmto);
            -- Devemos gerar o registro de Custódia Aplicação
            BEGIN
              INSERT INTO TBCAPT_CUSTODIA_APLICACAO
                         (tpaplicacao
                         ,vlregistro
                         ,qtcotas
                         ,vlpreco_registro
                         ,vlpreco_unitario)
                   VALUES(rw_lcto.tpaplrdc
                         ,rw_lcto.vllanmto
                         ,vr_qtcotas
                         ,vr_qtftcota
                         ,vr_qtftcota)
                RETURNING idaplicacao
                     INTO vr_idaplicacao;
            EXCEPTION
              WHEN OTHERS THEN
                -- Acionar log exceções internas
                CECRED.pc_internal_exception(pr_cdcooper => 3);
                -- Erro não tratado
                vr_cdcritic  := 1034;                 
                vr_dssqlerrm := SQLERRM;
                pr_idcritic  := 2; -- Alto    
                vr_dsparesp  := ', tabela: tbcapt_custodia_aplicacao' ||
                                ', qtcotas: '          || vr_qtcotas ||
                                ', vlpreco_registro: ' || vr_qtftcota ||
                                ', vlpreco_unitario: ' || vr_qtftcota;
                RAISE vr_exc_sai_lan_arq_lop_2_A;
            END;
            -- Devemos gerar o registro de CUstódia do Lançamento
            BEGIN
              INSERT INTO TBCAPT_CUSTODIA_LANCTOS
                         (idaplicacao
                         ,idtipo_arquivo
                         ,idtipo_lancto
                         ,cdhistorico
                         ,cdoperacao_b3
                         ,vlregistro
                         ,qtcotas
                         ,vlpreco_unitario
                         ,idsituacao
                         ,dtregistro)
                   VALUES(vr_idaplicacao
                         ,rw_lcto.idtipo_arquivo
                         ,rw_lcto.idtipo_lancto
                         ,rw_lcto.cdhistor
                         ,rw_lcto.cdoperacao_b3
                         ,rw_lcto.vllanmto
                         ,vr_qtcotas
                         ,vr_qtftcota
                         ,0 -- Pendente de Envio
                         ,rw_lcto.dtmvtolt)
                RETURNING idlancamento
                     INTO vr_idlancamento;
            EXCEPTION
              WHEN OTHERS THEN
                -- Acionar log exceções internas
                CECRED.pc_internal_exception(pr_cdcooper => 3);
                -- Erro não tratado
                vr_cdcritic  := 1034;                 
                vr_dssqlerrm := SQLERRM;
                pr_idcritic  := 2; -- Alto    
                vr_dsparesp  := ', tabela: tbcapt_custodia_lanctos' ||
                                ', idaplicacao: '||vr_idaplicacao
                            || ', qtcotas: '||vr_qtcotas
                            || ', vlpreco_unitario: '||vr_qtftcota
                            || ', idsituacao: 0'; -- Pendente de Envio
                RAISE vr_exc_sai_lan_arq_lop_2_A;
            END;
            -- Para aplicações de captação
            IF rw_lcto.tpaplrdc IN(3,4) THEN
              -- Atualizar a tabela CRAPRAC
              BEGIN
                         
     -- Forçado erro - Teste Belli      
     ---IF vr_qtregreg = 1  THEN
     ---  vr_cdcritic := 0 / 0;
     ---END IF;
                UPDATE craprac
                   SET idaplcus = vr_idaplicacao
                 WHERE ROWID = rw_lcto.rowid_apl;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Acionar log exceções internas
                  CECRED.pc_internal_exception(pr_cdcooper => 3);
                  -- Erro não tratado
                  vr_cdcritic  := 1035;                 
                  vr_dssqlerrm := SQLERRM;
                  pr_idcritic  := 2; -- Alto    
                  vr_dsparesp  := ', tabela: craprac'     ||
                                  ', idaplcus:' || vr_idaplicacao ||
                                  ', ROWID:'    || rw_lcto.rowid_apl;
                  RAISE vr_exc_sai_lan_arq_lop_2_A;
              END;
              -- Atualizar a tabela CRAPLAC
              BEGIN
                UPDATE craplac
                   SET idlctcus = vr_idlancamento
                 WHERE ROWID = rw_lcto.rowid_lct;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Acionar log exceções internas
                  CECRED.pc_internal_exception(pr_cdcooper => 3);
                  -- Erro não tratado
                  vr_cdcritic  := 1035;                 
                  vr_dssqlerrm := SQLERRM;
                  pr_idcritic  := 2; -- Alto    
                  vr_dsparesp  := ', tabela: craplac'      ||
                                   ', idlctcus:' || vr_idlancamento   ||
                                   ', ROWID:'    || rw_lcto.rowid_lct;
                  RAISE vr_exc_sai_lan_arq_lop_2_A;
              END;
            ELSE
              -- Atualizar a tabela CRAPRDA
              BEGIN   
      -- Forçado erro - Teste Belli      
      ---IF vr_qtregreg = 1  THEN
      --- vr_cdcritic := 0 / 0;
      ---END IF;
                UPDATE craprda
                   SET idaplcus = vr_idaplicacao
                 WHERE ROWID = rw_lcto.rowid_apl;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Acionar log exceções internas
                  CECRED.pc_internal_exception(pr_cdcooper => 3);
                  -- Erro não tratado
                  vr_cdcritic  := 1035;                 
                  vr_dssqlerrm := SQLERRM;
                  pr_idcritic  := 2; -- Alto    
                  vr_dsparesp  := ', tabela: craprda'     ||
                                  ', idaplcus:' || vr_idaplicacao   ||
                                  ', ROWID:'    || rw_lcto.rowid_apl;
                  RAISE vr_exc_sai_lan_arq_lop_2_A;
              END;
              -- Atualizar a tabela CRAPLAP
              BEGIN
                UPDATE craplap
                   SET idlctcus = vr_idlancamento
                 WHERE ROWID = rw_lcto.rowid_lct;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Acionar log exceções internas
                  CECRED.pc_internal_exception(pr_cdcooper => 3);
                  -- Erro não tratado
                  vr_cdcritic  := 1035;                 
                  vr_dssqlerrm := SQLERRM;
                  pr_idcritic  := 2; -- Alto    
                  vr_dsparesp  := ', tabela: craplap'     ||
                                  ', idlctcus:' || vr_idlancamento ||
                                  ', ROWID:'    || rw_lcto.rowid_lct;
                  RAISE vr_exc_sai_lan_arq_lop_2_A;
              END;
            END IF;
 

          EXCEPTION
            WHEN vr_exc_sai_lan_arq_lop_2_A THEN
              -- Efetuar retorno do erro tratado
              pc_critica_loop;         
              IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
                RAISE vr_exc_sai_lan_arq_lop_1_S;
              ELSE               
                vr_cdcritic := NULL;
                vr_dscritic := NULL;        
              END IF;  
            WHEN OTHERS THEN
              -- Acionar log exceções internas
              CECRED.pc_internal_exception(pr_cdcooper => 3);
              --
              vr_cdcritic  := 9999;
              vr_dssqlerrm := SQLERRM;
              pr_idcritic  := 2; -- Alta
              pc_critica_loop;                  
              -- Controle maximo de criticas
              IF vr_ctcritic > vr_qtlimerr THEN
                RAISE vr_exc_sai_lan_arq_lop_1_S;
              ELSE               
                vr_cdcritic := NULL;
                vr_dscritic := NULL;        
              END IF;
          END;          
          END LOOP;
        END IF;

        -- Caso esteja habilitado o processo de envio das Operações a B3
        IF pr_flenvrgt = 'S' THEN
          -- Inicializar variáveis
          vr_dtmvtolt := to_date('01011900','ddmmrrrr');
          vr_nrdconta := 0;
          vr_nraplica := 0;
          vr_qtcotas  := 0;
          vr_sldaplic := 0;
          /*vr_cdhistor_ant := 0;
          vr_idlancto_ant := 0;*/

          -- Buscar todos os movimentos de Operações dos últimos 2 dias
          -- que ainda não estejam marcados para envio (idlctcus is null)
          FOR rw_lcto IN cr_lctos_rgt(rw_cop.cdcooper,vr_dtmvto2a,rw_crapdat.dtmvtolt,vr_dtinictd) LOOP
          BEGIN

            -- Incrementar contador de Registros
            vr_qtregrgt := vr_qtregrgt + 1;
              
            vr_dsparlp2 :=  ', cr_lctos_rgt, cdhistor:'   || rw_lcto.cdhistor       ||
                            ', pr_nrdconta:'    || rw_lcto.nrdconta       ||
                            ', pr_nraplica:'    || rw_lcto.nraplica       ||
                            ', pr_tpaplica:'    || rw_lcto.tpaplrdc       ||
                            ', pr_cdprodut:'    || rw_lcto.cdprodut       ||
                            ', cdoperacao_b3:'  || rw_lcto.cdoperacao_b3  ||
                            ', idtipo_arquivo:' || rw_lcto.idtipo_arquivo ||
                            ', idtipo_lancto:'  || rw_lcto.idtipo_lancto  ||
                            ', cdhistor:'       || rw_lcto.cdhistor       ||
                            ', dtmvtolt:'       || rw_lcto.dtmvtolt       ||
                            ', vllanmto:'       || rw_lcto.vllanmto       ||
                            ', vr_qtregrgt:'    || vr_qtregrgt;                                                                                             
            vr_dsparesp  := NULL;
            vr_dssqlerrm := NULL;
                         
      -- Forçado erro - Teste Belli      
      ---IF vr_qtregrgt > 10 AND vr_qtregrgt < 13 THEN
      ---  vr_cdcritic := 0 / 0;
      ---END IF;
            
            -- Se mudou data, conta ou aplicação
            
            IF vr_dtmvtolt <> rw_lcto.dtmvtolt OR 
               vr_nrdconta <> rw_lcto.nrdconta OR 
               vr_nraplica <> rw_lcto.nraplica THEN
              -- Armazenar quantidade de cotas
              vr_qtcotas := rw_lcto.qtcotas;
              vr_vlbase := 0;
              -- Quando não houver carencia
              IF fn_tem_carencia(pr_dtmvtapl => rw_lcto.dtmvtapl
                                ,pr_qtdiacar => rw_lcto.qtdiacar
                                ,pr_dtmvtres => rw_lcto.dtmvtolt) = 'N' THEN
                -- Calcular saldo da aplicação anteriormente ao(s) resgates
                vr_sldaplic := 0;
                pc_busca_saldo_anterior(pr_cdcooper  => rw_cop.cdcooper         --> Cooperativa
                                       ,pr_nrdconta  => rw_lcto.nrdconta        --> Conta
                                       ,pr_nraplica  => rw_lcto.nraplica        --> Aplicação
                                       ,pr_tpaplica  => rw_lcto.tpaplrdc        --> Tipo aplicação
                                       ,pr_cdprodut  => rw_lcto.cdprodut        --> Codigo produto
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt     --> Data movimento
                                       ,pr_dtmvtsld  => rw_lcto.dtmvtolt        --> Data do saldo desejado
                                       ,pr_tpconsul  => 'R'                     --> Resgates
                                       ,pr_sldaplic  => vr_sldaplic             --> Saldo na data
                                       ,pr_idcritic  => vr_idcritic              --> Identificador critica                                       
                                       ,pr_dssqlerr  => vr_dssqlerrm
                                       ,pr_cdcritic  => vr_cdcritic              --> Codigo da critica
                                       ,pr_dscritic  => vr_dsparesp);            --> Retorno de críticaca
                -- Código comum, para gravação do LOG independente de sucesso ou não
                IF vr_dsparesp IS NOT NULL OR 
                   vr_cdcritic IS NOT NULL   THEN
                  pr_idcritic  := vr_idcritic;
                  RAISE vr_exc_sai_lan_arq_lop_2_B;
                END IF;                                      
                vr_dssqlerrm := NULL;
                vr_cdcritic  := NULL;
                vr_dsparesp  := NULL;
                -- Se o saldo for zero, significa que houve um resgate total, então precisamos buscar
                -- o valor dos resgates efetuados neste dia para a conta e aplicação
                IF vr_sldaplic = 0 THEN
                  OPEN cr_resgat(pr_cdcooper  => rw_cop.cdcooper    --> Cooperativa
                                ,pr_nrdconta  => rw_lcto.nrdconta   --> Conta
                                ,pr_nraplica  => rw_lcto.nraplica   --> Aplicação
                                ,pr_tpaplrdc  => rw_lcto.tpaplrdc   --> TIpo da aplicação
                                ,pr_dtmvtolt  => rw_lcto.dtmvtolt); --> Data

                  FETCH cr_resgat
                   INTO vr_sldaplic;
                  CLOSE cr_resgat;
                END IF;
                -- Se mesmo assim ainda está zero, vamos usar o próprio valor do lançamento como saldo
                IF vr_sldaplic = 0 THEN
                  vr_sldaplic := rw_lcto.vllanmto;
                END IF;
                  -- Calcular preço unitario
                  IF vr_qtcotas = 0 THEN
                     
                   -- Forçado Não gravar Erro - Teste Belli
                   ---vr_qterro_1493 := vr_qterro_1493 + 1;           
                   ---IF vr_qterro_1493 < 6  THEN
                     
                    -- Gravar critica e continuar processo  
                    vr_cdcritic := 1493;
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                                            ,pr_dscritic => vr_dscritic) ||
                           ' ' || vr_nomdojob  ||
                           ' ' || vr_nmaction  ||
                           ' ' || vr_nmproint1 ||
                           ' ' || vr_dsparame  ||
                           ' ' || vr_dsparlp1  ||
                           ' ' || vr_dsparlp2;   
                    -- Log de erro de execucao
                    pc_log(pr_cdcritic => vr_cdcritic
                          ,pr_dscrilog => vr_dscritic
                          ,pr_cdcricid => 1); -- Medio
                    vr_cdcritic := NULL;
                    vr_dscritic := NULL;
                        
                    --- pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 
                    ---                ' Resgate com cotas zerada! '||  rw_cop.cdcooper ||
                    ---                ' '|| rw_lcto.nrdconta ||' '|| rw_lcto.nraplica;
                                     
                   ---END IF;
                            
                    --- RAISE vr_exc_sai_lan_arq_lop_2_B;
                    
                    CONTINUE;
                                                           
                  ELSE
                    vr_vlpreco_unit := vr_sldaplic / vr_qtcotas;
                  END IF;
                  vr_qtcotas_resg := fn_converte_valor_em_cota(rw_lcto.valorbase);
              ELSE
                -- Quando carencia usar sempre a pu da emissão
                vr_vlpreco_unit := rw_lcto.vlpreco_registro;
                vr_qtcotas_resg := trunc(rw_lcto.vllanmto / vr_vlpreco_unit);
              END IF;
              -- Armazena informações do registro atual
              vr_dtmvtolt := rw_lcto.dtmvtolt;
              vr_nrdconta := rw_lcto.nrdconta;
              vr_nraplica := rw_lcto.nraplica;
           
             /*  vr_cdhistor_ant := rw_lcto.cdhistor;
              vr_idlancto_ant := NULL;
            ELSE
              -- Se estamos na mesma conta, data e aplicação e não mudou o histórico
              -- Significa que é um novo resgate, então não podemos vincular este ao anterior
              IF vr_cdhistor_ant = rw_lcto.cdhistor THEN
                vr_idlancto_ant := NULL;
              ELSE
                -- Mudou o histórico, então vincularemos este ao anterior e vamos
                -- guardar o histórico deste para o próximo teste
                vr_cdhistor_ant := rw_lcto.cdhistor;
              END IF;*/
            END IF;
            
            /*  Autor : David Valente  Em 05/03/2019
               Calculo da quantidade de cotas referente a operação atual
               alterado para compatibilizar com a B3;
               vr_qtftcota é uma CONSTANTE COM O VALOR  = R$0,01 (1 Centavo)
               REGRA ANTIGA -> vr_qtcotas_resg := trunc(rw_lcto.vllanmto / vr_vlpreco_unit);
            */
            --vr_qtcotas_resg := fn_converte_valor_em_cota(rw_lcto.valorbase);
           
            vr_vlbase := vr_vlbase + rw_lcto.vllanmto;
          
            /* Se for IR e Rendimento nao vamos continuar */
            IF rw_lcto.idtipo_lancto in (3, 4) THEN
               continue;
            END IF;
            
            vr_qtcotas_resg := fn_converte_valor_em_cota(vr_vlbase);
            vr_vlbase := 0; /* Zera para não ficarmos com lixo */
            

            -- Devemos gerar o registro de CUstódia do Lançamento
            BEGIN
              INSERT INTO TBCAPT_CUSTODIA_LANCTOS
                         (idaplicacao
                         ,idtipo_arquivo
                         ,idtipo_lancto
                         ,cdhistorico
                         ,cdoperacao_b3
                         ,vlregistro
                         ,qtcotas
                         ,vlpreco_unitario
                         ,idsituacao
                         ,dtregistro
                         /*,idlancto_origem*/)
                   VALUES(rw_lcto.idaplcus
                         ,rw_lcto.idtipo_arquivo
                         ,rw_lcto.idtipo_lancto
                         ,rw_lcto.cdhistor
                         ,rw_lcto.cdoperacao_b3
                         ,rw_lcto.vllanmto
                         ,vr_qtcotas_resg
                         ,vr_vlpreco_unit
                         ,0 -- Pendente de Envio
                         ,rw_lcto.dtmvtolt
                         /*,vr_idlancto_ant*/)
                RETURNING idlancamento
                     INTO vr_idlancamento;
            EXCEPTION
              WHEN OTHERS THEN
                  -- Acionar log exceções internas
                  CECRED.pc_internal_exception(pr_cdcooper => 3);
                  -- Erro não tratado
                  vr_cdcritic  := 1034;                 
                  vr_dssqlerrm := SQLERRM;
                  pr_idcritic  := 2; -- Alto    
                  vr_dsparesp  := ', tabela: tbcapt_custodia_lanctos'     ||
                                  ', qtcotas: '||vr_qtcotas_resg ||
                                  ', vlpreco_unitario: '||vr_vlpreco_unit ||
                                  ', idsituacao: 0'; -- Pendente de Envio
                  RAISE vr_exc_sai_lan_arq_lop_2_B;
            END;

            -- Guardar id do lançamento gerado
            --vr_idlancto_ant := vr_idlancamento;

            -- Para aplicações de captação
            IF rw_lcto.tpaplrdc in(3,4) THEN
              -- Atualizar a tabela CRAPLAC
              BEGIN
                UPDATE craplac
                   SET idlctcus = vr_idlancamento
                 WHERE ROWID = rw_lcto.rowid_lct;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Acionar log exceções internas
                  CECRED.pc_internal_exception(pr_cdcooper => 3);
                  -- Erro não tratado
                  vr_cdcritic  := 1035;                 
                  vr_dssqlerrm := SQLERRM;
                  pr_idcritic  := 2; -- Alto    
                  vr_dsparesp  := ', tabela: craplac'     ||
                                  ', idlctcus:' || vr_idlancamento
                              || ', ROWID: '||rw_lcto.rowid_lct;
                  RAISE vr_exc_sai_lan_arq_lop_2_B;
              END;
            ELSE
              -- Atualizar a tabela CRAPLAP
              BEGIN
                UPDATE craplap
                   SET idlctcus = vr_idlancamento
                 WHERE ROWID = rw_lcto.rowid_lct;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Acionar log exceções internas
                  CECRED.pc_internal_exception(pr_cdcooper => 3);
                  -- Erro não tratado
                  vr_cdcritic  := 1035;                 
                  vr_dssqlerrm := SQLERRM;
                  pr_idcritic  := 2; -- Alto  
                  vr_dsparesp  := ', tabela: craplap'    ||
                                  ', idlctcus:' || vr_idlancamento ||
                                  ', ROWID:'    || rw_lcto.rowid_lct;
                  RAISE vr_exc_sai_lan_arq_lop_2_B;
              END;
            END IF;

            -- Atualizar a quantidade de cotas e valor unitário no registro da aplicação
            BEGIN
              UPDATE tbcapt_custodia_aplicacao apl
                 SET apl.qtcotas = greatest(0,apl.qtcotas-vr_qtcotas_resg)
                    ,apl.vlpreco_unitario = vr_vlpreco_unit
               WHERE apl.idaplicacao = rw_lcto.idaplcus;
            EXCEPTION
              WHEN OTHERS THEN
                -- Acionar log exceções internas
                CECRED.pc_internal_exception(pr_cdcooper => 3);
                -- Erro não tratado
                vr_cdcritic  := 1035;                 
                vr_dssqlerrm := SQLERRM;
                pr_idcritic  := 2; -- Alto    
                vr_dsparesp  := ', tabela: tbcapt_custodia_aplicacao' ||
                                ', qtcotas_resg:'    || vr_qtcotas_resg  ||
                                ', vr_vlpreco_unit:' || vr_vlpreco_unit;
                RAISE vr_exc_sai_lan_arq_lop_2_B;
            END; 

          EXCEPTION
            WHEN vr_exc_sai_lan_arq_lop_2_B THEN
              -- Efetuar retorno do erro tratado
              pc_critica_loop;         
              IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
                RAISE vr_exc_sai_lan_arq_lop_1_S;
              ELSE               
                vr_cdcritic := NULL;
                vr_dscritic := NULL;        
              END IF;  
            WHEN OTHERS THEN
              -- Acionar log exceções internas
              CECRED.pc_internal_exception(pr_cdcooper => 3);
              --
              vr_cdcritic  := 9999;
              vr_dssqlerrm := SQLERRM;
              pr_idcritic  := 2; -- Alta
              pc_critica_loop;                  
              -- Controle maximo de criticas
              IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
                RAISE vr_exc_sai_lan_arq_lop_1_S;
              ELSE               
                vr_cdcritic := NULL;
                vr_dscritic := NULL;        
              END IF;
          END;          
      
          END LOOP;
        END IF;
 

        EXCEPTION
          WHEN vr_exc_sai_lan_arq_lop_1_S THEN
            IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
              RAISE vr_exc_sai_lan_arq_1_S;
            ELSE               
              vr_cdcritic := NULL;
              vr_dscritic := NULL;        
            END IF;            
          WHEN vr_exc_sai_lan_arq_lop_1 THEN
            -- Efetuar retorno do erro tratado
            pc_critica_loop;         
            IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
              RAISE vr_exc_sai_lan_arq_1_S;
            ELSE               
              vr_cdcritic := NULL;
              vr_dscritic := NULL;        
            END IF;  
          WHEN OTHERS THEN
            -- Acionar log exceções internas
            CECRED.pc_internal_exception(pr_cdcooper => 3);
            --
            vr_cdcritic  := 9999;
            vr_dssqlerrm := SQLERRM;
            pr_idcritic  := 2; -- Alta
            pc_critica_loop;                  
            -- Controle maximo de criticas
            IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
              RAISE vr_exc_sai_lan_arq_1_S;
            ELSE               
              vr_cdcritic := NULL;
              vr_dscritic := NULL;        
            END IF;
      END;          
      END LOOP;

      -- Caso não esteja habilitado o processo de registro das aplicações na B3
      IF pr_flenvreg <> 'S' THEN
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Nenhum Registro será criado pois a opção está Desativada!';
      ELSE
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Total de Registros de Aplicação Gerados: '||vr_qtregreg;
      END IF;

      -- Caso não esteja habilitado o processo de envio dos Resgates a B3
      IF pr_flenvrgt <> 'S' THEN
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Nenhum Registro de Operação será criado pois a opção está Desativada!';
      ELSE
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Total de Operações em Aplicação Gerados: '||vr_qtregrgt;
      END IF;
            
      vr_cdacesso := 'DAT_ENVIA_CUSTODIA_B3';
      BEGIN
        -- Atualizamos o registro que indica quando ocorreu a ultima conciliação com sucesso
        UPDATE crapprm
          SET dsvlrprm = to_char(trunc(SYSDATE),'dd/mm/rrrr')
        WHERE nmsistem = 'CRED'
         AND cdcooper = 0
         AND cdacesso = vr_cdacesso;
      EXCEPTION            
        WHEN OTHERS THEN
            -- Acionar log exceções internas
            CECRED.pc_internal_exception(pr_cdcooper => 3);  
          -- Erro não tratado
          vr_cdcritic  := 1035;
          vr_dssqlerrm := ' ' || SQLERRM;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                         ' ' || vr_dssqlerrm ||
                         ' ' || vr_nomdojob  ||
                         ' ' || vr_nmaction  ||
                         ' ' || vr_nmproint1 ||
                         ' ' || vr_dsparame  ||
                         ', tabela: crapprm'    ||
                         ', cdacesso:'  || vr_cdacesso    ||
                         ', dtregistro:'|| vr_dtmvtolt    ||
                         ', dtprocesso:'|| TRUNC(SYSDATE);
          pr_idcritic := 2; -- Alta                                    
          -- Log de erro de execucao
          pc_log(pr_cdcritic => vr_cdcritic
                ,pr_dscrilog => vr_dscritic
                ,pr_cdcricid => pr_idcritic);    
          RAISE vr_exc_sai_lan_arq_1_S;
      END;      
      
      -- Gravação dos registros atualizados
      --COMMIT;
	  
      -- Controle Saida  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            '. Finalizado' ||
                            ' '      || vr_nmaction  ||
                            ' '      || vr_nmproint1
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            ); 

      -- Forçado erro - Teste Belli
      ---  vr_cdcritic := 0 / 0;

    EXCEPTION
      WHEN vr_exc_sai_lan_arq_1_S THEN 
        -- Finaliza já gerado o log 
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK; 
      WHEN vr_exc_sai_lan_arq_1 THEN 
        -- Finaliza com erro
        pc_finaliza;
      WHEN OTHERS THEN
        -- Acionar log exceções internas
        CECRED.pc_internal_exception(pr_cdcooper => 3);
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic  := 9999;
        pr_idcritic  := 2; -- Alta
        vr_dssqlerrm := SQLERRM;
        -- Finaliza com erro
        pc_finaliza;
    END;
  END pc_verifi_lanctos_custodia;

  -- Função para montar o Header conforme o tipo do arquivo
  FUNCTION fn_gera_header_arquivo(pr_idtipo_arquivo tbcapt_custodia_arquivo.idtipo_arquivo%TYPE  -- Tipo do Arquivo
                                 ,pr_dtarquivo      tbcapt_custodia_arquivo.dtcriacao%TYPE)      -- Data Arquivo
                         RETURN VARCHAR2 IS
  -- Pr_idtipo_arquivo:
  --  1 - Registro  : Layout 4.1.19
  --  2 - Operações : Layout 4.1.37
  BEGIN
    DECLARE
      vr_dsretorn VARCHAR2(44);
    BEGIN
      -- Tipo IF e Tipo Registro
      vr_dsretorn := 'RDB  0';
      -- Ação
      IF pr_idtipo_arquivo = 1 THEN
        vr_dsretorn := vr_dsretorn || 'INCL';
      ELSIF pr_idtipo_arquivo = 2 THEN
        vr_dsretorn := vr_dsretorn || 'LCOP';
      ELSE
        vr_dsretorn := vr_dsretorn || '????';
      END IF;
      -- Nome Simplificado e Data
      vr_dsretorn := vr_dsretorn || vr_nmsimplf || to_char(pr_dtarquivo,'RRRRMMDD');
      -- Versão conforme tipo
      IF pr_idtipo_arquivo = 1 THEN
        vr_dsretorn := vr_dsretorn || '00009';
      ELSIF pr_idtipo_arquivo = 2 THEN
        vr_dsretorn := vr_dsretorn || '00014';
      ELSE
        vr_dsretorn := vr_dsretorn || '00000';
      END IF;
      -- E finalizar com Delimintador de término de linha para tipos 1 e 2
      IF pr_idtipo_arquivo IN(1,2) THEN
        vr_dsretorn := vr_dsretorn || vr_dsfimlin;
      END IF;
      -- Retornar Header montado
      RETURN vr_dsretorn;
    END;
  END fn_gera_header_arquivo;

  -- Função para gerar Lançamento de Registro de Operação
  FUNCTION fn_gera_lancto_operacao(pr_cd_registrador NUMBER                                    -- Código Registrador
                                  ,pr_cd_favorecido  NUMBER                                    -- Código Favorecido
                                  ,pr_idlancamento   tbcapt_custodia_lanctos.idlancamento%TYPE -- ID do lançamento
                                  ,pr_cdcooper       crapcop.cdcooper%TYPE                     -- Cooperativa
                                  ,pr_nrdconta       crapass.nrdconta%TYPE)                    -- Conta
                         RETURN VARCHAR2 IS
  -- Layout Operações : Layout 4.1.37
  BEGIN
    DECLARE
      -- LInha montada
      vr_dsretorn VARCHAR2(523);
      -- BUsca detalhes do lançamento
      CURSOR cr_lcto IS
        SELECT apl.dscodigo_b3
              ,lct.cdoperacao_b3
              ,lct.vlregistro
              ,lct.dtregistro
              ,lct.qtcotas
              ,lct.vlpreco_unitario
              ,lct.idlancto_origem
          FROM tbcapt_custodia_lanctos   lct
              ,tbcapt_custodia_aplicacao apl
         WHERE lct.idaplicacao  = apl.idaplicacao
           AND lct.idlancamento = pr_idlancamento;
      rw_lcto cr_lcto%ROWTYPE;
      -- Quantidade, valores de cotas, e valor aplicado
      vr_vlqtcota VARCHAR2(14);
      vr_vluntemi VARCHAR2(18);
      vr_vlfinemi VARCHAR2(18);
      -- Data quando resgate retroativo
      vr_dsdtretr VARCHAR2(8);
      -- Busca dos dados da conta
      CURSOR cr_crapass IS
        SELECT decode(ass.inpessoa,1,to_char(ass.nrcpfcgc,'fm00000000000'),to_char(ass.nrcpfcgc,'fm00000000000000')) nrcpfcgc
              ,decode(ass.inpessoa,1,'PF','PJ') dspessoa
          FROM crapass ass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_ass cr_crapass%ROWTYPE;
      -- Busca da operação cetip do registro origem
      CURSOR cr_origem(pr_idlancto_origem tbcapt_custodia_lanctos.idlancto_origem%TYPE) IS
        SELECT to_char(lct.cdoperac_cetip,'fm0000000000000000')
          FROM tbcapt_custodia_lanctos lct
         WHERE lct.idlancamento = pr_idlancto_origem
           AND lct.Idsituacao = 8;
      vr_cdoperac_cetip VARCHAR2(16);
    BEGIN
      -- Busca detalhes do lançamento
      OPEN cr_lcto;
      FETCH cr_lcto
       INTO rw_lcto;
      CLOSE cr_lcto;
      -- Busca dos dados da conta
      OPEN cr_crapass;
      FETCH cr_crapass
        INTO rw_ass;
      CLOSE cr_crapass;

      -- Montar data do resgate retroativa pois sempre estamos rodando no dia posterior
      vr_dsdtretr := to_char(rw_lcto.dtregistro,'rrrrmmdd');

      -- Somente para operações de resgate
      IF rw_lcto.cdoperacao_b3 <> '0064' THEN
        -- Converter quantidade de cotas em texto
        vr_vlqtcota := to_char(rw_lcto.qtcotas,'fm00000000000000');
        -- Converter valor unitário para o formato esperado
        vr_vluntemi := REPLACE(REPLACE(TO_CHAR(rw_lcto.vlpreco_unitario,'fm0000000000d00000000'),',',''),'.','');
      ELSE
        vr_vlqtcota := '              ';
        vr_vluntemi := '                  ';
      END IF;

      -- Converter valor da operação
      vr_vlfinemi := replace(replace(to_char(rw_lcto.vlregistro,'fm0000000000000d00'),',',''),'.','');

      -- Se houver operação origem
      IF rw_lcto.idlancto_origem IS NOT NULL THEN
        -- Busca da operação cetip do registro origem
        OPEN cr_origem(rw_lcto.idlancto_origem);
        FETCH cr_origem
         INTO vr_Cdoperac_Cetip;
        CLOSE cr_origem;
      ELSE
        vr_cdoperac_cetip := RPAD(' ',16,' ');
      END IF;

                  
            -- BELLAO5
            IF rw_lcto.dscodigo_b3 = 'RDB0191MAVL' THEN
              NULL;
            END IF;
            
      -- Enfim, enviar as informações para a linha
      vr_dsretorn /* Registro da Operação */
                  := 'RDB  '                                       -- 01 - Tipo IF
                  || '1'                                           -- 02 - TIpo Registro
                  || lpad(rw_lcto.cdoperacao_b3,4,'0')             -- 03 - Código da Operação
                  || lpad(rw_lcto.dscodigo_b3,14,' ')              -- 04 - Código IF
                  || ' '                                           -- 05 - IF Com Restrição
                  || '01'                                          -- 06 - Tipo Compra/Venda
                  || TO_CHAR(pr_cd_favorecido,'fm00000000')        -- 07 - Conta da Parte Transferidor
                  || to_char(fn_sequence('TBCAPT_CUSTODIA_CONTEUDO_ARQ','NRMEUNUM',TO_CHAR(SYSDATE,'rrrrmmdd')),'fm0000000000') -- 08 - Meu Numero
                  || RPAD(' ',16,' ')                              -- 09 - Filler(16)
                  || '      '                                      -- 10 - Número de Associação
                  || TO_CHAR(pr_cd_registrador,'fm00000000')       -- 11 - Conta da Contraparte / Adquirente
                  || vr_vlqtcota                                   -- 12 - Quantidade da operação
                  || vr_vlfinemi                                   -- 13 - Valor da Operação
                  || vr_vluntemi                                   -- 14 - Preço Unitário da Operação
                  || '0'                                           -- 15 - Código da Modalidade de Liquidação
                  || '        '                                    -- 16 - Conta do Banco Liquidate
                  /* Retorno de Compromisso */
                  || '        '                                    -- 17 - Data de Compromisso
                  || '                  '                          -- 18 - Preço Unitário do COmpromisso
                  /* Antecipações/Desvinculações/Lançamentos PU de COmpromisso/TRansferências/Cancelamentos */
                  || ' '                                           -- 19 - Reserva técnica
                  || vr_dsdtretr                                   -- 20 - Data da Operação Original / DAta da Subscrição / Data Operação Original Antecipação
                  || vr_cdoperac_cetip                             -- 21 - Número da Operação Cetip Original
                  /* Transferência de Ativos para Garantia / Margem */
                  || ' '                                           -- 22 - Direitos do Caucionante
                  || '        '                                    -- 23 - Conta Investido / Garantidor
                  || ' '                                           -- 24 - Tipo de Garantia
                  /* Dados Complementares para Especificação Automática do Comitente */
                  || rpad(rw_ass.nrcpfcgc,18,' ')                  -- 25 - CPF/CNPJ Cliente
                  || rw_ass.dspessoa                               -- 26 - Natureza (Emitente)
                  || RPAD(' ',100,' ')                             -- 27 - MOtivo [X(100)] Livre
                  || RPAD(' ',100,' ')                             -- 28 - Filler(100)
                  /* Dados Complementares para TrasnferÊncia de IF Bolsa */
                  || '        '                                    -- 29 - Conta Corretora
                  || '                  '                          -- 30 - CNPJ Corretora
                  || '                  '                          -- 31 - CPF/CNPJ Detentor
                  || ' '                                           -- 32 - Filler (1)
                  || ' '                                           -- 33 - RetiraDEB
                  || '  '                                          -- 34 - Filler(2)
                  || '  '                                          -- 35 - Tipo de Bloqueio
                  || '        '                                    -- 36 - Data de Liquidação
                  || ' '                                           -- 37 - Ciência de Liquidação Antecipada
                  /* Dados Complementares para Depósito de CSEC */
                  || ' '                                           -- 38 - Gerar Eventos Vencidos Não Pagos
                  || '        '                                    -- 39 - Data de Pagamento Eventos Vencidos Não Pagos
                  || '                  '                          -- 40 - CPF /CNPJ Eventos Vencidos Não PAgos
                  || '  '                                          -- 41 - Natureza Eventos Vencidos Não Pagos
                  || RPAD(' ',20,' ')                              -- 42 - Filler (20)
                  || '  '                                          -- 43 - Tipo de Carteira
                  || vr_dsfimlin;                                  -- 44 - Delimitador de Final de Linha
      -- Retornar Linha montada
      RETURN vr_dsretorn;
    END;
  END fn_gera_lancto_operacao;

  -- Função para gerar registro das Aplicações
  FUNCTION fn_gera_regist_operacao(pr_cd_registrador NUMBER                                   -- Código Registrador
                                  ,pr_cd_favorecido  NUMBER                                   -- Código Favorecido
                                  ,pr_idlancamento   tbcapt_custodia_lanctos.idlancamento%TYPE-- ID do lançamento
                                  ,pr_cdcooper       crapcop.cdcooper%TYPE                    -- Cooperativa
                                  ,pr_nrdconta       crapass.nrdconta%TYPE                    -- Conta
                                  ,pr_vet_aplica     APLI0001.typ_reg_saldo_rdca)             -- Tabela com informações da aplicacao
                         RETURN VARCHAR2 IS
  -- Layout Operações : Layout 4.1.19
  BEGIN
    DECLARE
      -- LInha montada
      vr_dsretorn VARCHAR2(1578);
      -- BUsca detalhes do lançamento
      CURSOR cr_lcto IS
        SELECT apl.idaplicacao
              ,apl.dscodigo_b3
              ,lct.cdoperacao_b3
              ,lct.vlregistro
              ,apl.tpaplicacao
              ,lct.dtregistro
              ,lct.qtcotas
              ,lct.vlpreco_unitario
          FROM tbcapt_custodia_lanctos   lct
              ,tbcapt_custodia_aplicacao apl
         WHERE lct.idaplicacao  = apl.idaplicacao
           AND lct.idlancamento = pr_idlancamento;
      rw_lcto cr_lcto%ROWTYPE;

      -- Busca dos dados da conta
      CURSOR cr_crapass IS
        SELECT decode(ass.inpessoa,1,to_char(ass.nrcpfcgc,'fm00000000000'),to_char(ass.nrcpfcgc,'fm00000000000000')) nrcpfcgc
              ,decode(ass.inpessoa,1,'PF','PJ') dspessoa
          FROM crapass ass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_ass cr_crapass%ROWTYPE;

      -- Buscar as taxas contratadas
      CURSOR cr_craplap IS
        SELECT lap.txaplica
          FROM craplap lap
         WHERE lap.cdcooper = pr_cdcooper
           AND lap.nrdconta = pr_nrdconta
           AND lap.nraplica = pr_vet_aplica.nraplica
           AND lap.dtmvtolt = pr_vet_aplica.dtmvtolt
         ORDER BY lap.progress_recid ASC; --> Retornar a primeira encontrada

      -- Campos genéricos cfme tipo
      vr_cdfrmpag VARCHAR2(2);
      vr_nrrentab VARCHAR2(4);
      vr_cricljur VARCHAR2(2);
      vr_vlfinrgt VARCHAR2(18);
      vr_prtaxflt VARCHAR2(7);
      vr_vltxjrsp VARCHAR2(8);

      -- Calculo para RDC PRé
      vr_txaplica NUMBER(18,8); --> Taxa de aplicacao
      vr_dtcalcul DATE;         --> Receber a data de parametro a acumular os dias
      vr_vlrendim NUMBER(18,8); --> Auxiliar para calculo dos rendimentos da aplicacao
      vr_vlsdrdca NUMBER(18,4) := 0; --> Totalizador do saldo rdca

      -- Quantidade, valores de cotas, e valor aplicado
      vr_vlqtcota VARCHAR2(14);
      vr_vluntemi VARCHAR2(18);
      vr_vlfinemi VARCHAR2(18);
      vr_vlunitar VARCHAR2(18);
      vr_dsdataem VARCHAR2(8);


    BEGIN
      -- Busca detalhes do lançamento
      OPEN cr_lcto;
      FETCH cr_lcto
       INTO rw_lcto;
      CLOSE cr_lcto;
      -- Busca dos dados da conta
      OPEN cr_crapass;
      FETCH cr_crapass
        INTO rw_ass;
      CLOSE cr_crapass;
      -- Para aplicações Pré
      IF rw_lcto.tpaplicacao in(1,3) THEN
        vr_cdfrmpag := '01';
        vr_nrrentab := '0099';
        vr_cricljur := '01';
        -- Se houve retorno da taxa já no vetor (Produto nOvo de captação
        IF trim(pr_vet_aplica.txaplmax) IS NOT NULL THEN
          -- Utilizar a mesma
          vr_txaplica := gene0002.fn_char_para_number(pr_vet_aplica.txaplmax);
        ELSE
          -- Buscaremos a taxa contratada
          OPEN cr_craplap;
          FETCH cr_craplap
           INTO vr_txaplica;
          CLOSE cr_craplap;
        END IF;
        -- Calcular percentual
        vr_txaplica := TRUNC(vr_txaplica / 100,8);
        -- Iniciar saldo com valor aplicado
        vr_vlsdrdca := pr_vet_aplica.vlaplica;
        -- Iniciar data para calculo com data inicial enviada
        vr_dtcalcul := pr_vet_aplica.dtmvtolt;
        -- Verifica dias uteis e calcula os rendimentos
        LOOP
          -- Validar se a data auxiliar e util e se não for trazer a primeira apos
          vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => vr_dtcalcul);
          -- Continuar enquanto a data auxiliar de calculo for inferior a data final
          EXIT WHEN vr_dtcalcul >= pr_vet_aplica.dtvencto;
          -- Acumular os rendimentos com base no saldo RCA * taxa
          vr_vlrendim := TRUNC((vr_vlsdrdca * vr_txaplica),8);
          -- Acumular no saldo RCA o rendimento calculado
          vr_vlsdrdca := vr_vlsdrdca + vr_vlrendim;
          -- Incrementar mais um dia na data auxiliar para processar o proximo dia
          vr_dtcalcul := vr_dtcalcul + 1;
        END LOOP; --> Fim da do calculos nos dias uteis
        -- Arredondar saidas de rendimento total e saldo
        --vr_vlsdrdca := apli0001.fn_round(vr_vlsdrdca,2);
        -- Saldo previsto de resgate
        --vr_vlfinrgt := replace(replace(to_char(vr_vlsdrdca,'fm0000000000000000D00'),',',''),'.','');
        vr_prtaxflt := '       ';
        -- Retornar ao valor original
        vr_txaplica := TRUNC(vr_txaplica * 100,8);
    -- Converte para taxa anual
        vr_txaplica := fn_get_taxa_anual(vr_txaplica);
        vr_vltxjrsp := REPLACE(REPLACE(TO_CHAR(vr_txaplica,'fm0000d0000'),',',''),'.','');
      ELSE
        vr_cdfrmpag := '01';
        vr_nrrentab := '0003';
        vr_cricljur := '  ';
        vr_prtaxflt := replace(replace(to_char(gene0002.fn_char_para_number(pr_vet_aplica.txaplmax),'fm00000d00'),',',''),'.','');
        vr_vltxjrsp := '        ';
      END IF;
      -- valor financeiro para resgate
      vr_vlfinrgt := '                  ';
      -- Converter quantidade de cotas em texto
      vr_vlqtcota := to_char(rw_lcto.qtcotas,'fm00000000000000');
      -- Converter valor unitário para o formato esperado
      vr_vluntemi := REPLACE(REPLACE(TO_CHAR(rw_lcto.vlpreco_unitario,'fm0000000000d00000000'),',',''),'.','');
      -- Trasnformar data em texto
      vr_dsdataem := to_char(pr_vet_aplica.dtmvtolt,'RRRRMMDD');
      -- Converter valor unitário para o formato esperado
      vr_vlunitar := REPLACE(REPLACE(TO_CHAR(rw_lcto.vlpreco_unitario,'fm0000000000d00000000'),',',''),'.','');
      -- Converter valor emissão para o formato esperado
      vr_vlfinemi := REPLACE(REPLACE(TO_CHAR(rw_lcto.vlregistro,'fm0000000000000000d00'),',',''),'.','');
      -- Enfim, montar o registro com as informações retornadas
      
      
                  
            -- BELLAO5
            IF rw_lcto.dscodigo_b3 = 'RDB0191MAVL' THEN
              NULL;
            END IF;
            
      vr_dsretorn /* Registro da RDB */
                  := 'RDB  '                                       -- 01 - Tipo IF
                  || '1'                                           -- 02 - TIpo Registro
                  || 'INCL'                                        -- 03 - Ação
                  || lpad(nvl(rw_lcto.dscodigo_b3,' '),14,' ')     -- 04 - Codigo IF
                  || '0000'                                        -- 05 - Quantidade de Linhas Adicionais
                  || TO_CHAR(pr_cd_registrador,'fm00000000')       -- 06 - Conta do Registrador
                  || '            '                                -- 07 - Código ISIN
                  || to_char(pr_vet_aplica.dtmvtolt,'RRRRMMDD')    -- 08 - Data da Emissão
                  || to_char(pr_vet_aplica.dtvencto,'RRRRMMDD')    -- 09 - Data de Vencimento
                  || to_char(pr_vet_aplica.qtdiaapl,'fm0000000000')-- 10 - Prazo de Emissão
                  || vr_vlqtcota                                   -- 11 - Quantidade Emitida
                  || vr_vluntemi                                   -- 12 - VAlor Unitário de Emissão
                  || vr_vlfinemi                                   -- 13 - Valor Financeiro de Emissão
                  || vr_vlunitar                                   -- 14 - Valor Unitário
                  || vr_dsdataem                                   -- 15 - Data Em
                  || vr_vlfinrgt                                   -- 16 - Valor FInanceiro de Resgate
                  || ' '                                           -- 17 - Cód. Múltiplas Curvas
                  || ' '                                           -- 18 - Escalonamento
                  || RPAD(' ',200,' ')                             -- 19 - Descrição Adicional (Campo Livre)
                  || 'N'                                           -- 20 - Condição de Resgate Antecipado
                  || vr_cdfrmpag                                   -- 21 - Forma de PAgamento
                  /*Forma de Pagamento*/
                  || vr_nrrentab                                   -- 22 - Rentabilidade / Indexador / Taxa
                  || ' '                                           -- 23 - Periodicidade de Correção
                  || ' '                                           -- 24 - Pro-Rata de Correção
                  || ' '                                           -- 25 - Tipo de Correção
                  || vr_prtaxflt                                   -- 26 - % Taxa Flutuante
                  || vr_vltxjrsp                                   -- 27 - TAxa de Juros/Spread
                  || vr_cricljur                                   -- 28 - Critério de Cálculo de Juros
                  || '     '                                       -- 29 - Qualificação VCP
                  || RPAD(' ',200,' ')                             -- 30 - Descrição VCP
                  || 'N'                                           -- 31 - Incorpora JUros
                  || '        '                                    -- 32 - Data da Incorporação de JUros
                  || '  '                                          -- 33 - Dia de Atualização
                  || '    '                                        -- 34 - Rentabilidade / Indexador / Taxa
                  || ' '                                           -- 35 - Periodicidade de Correção
                  || ' '                                           -- 36 - Pro-rata de Correção
                  || ' '                                           -- 37 - TIpo de Correção
                  || '       '                                     -- 38 - % da Taxa Flutuante
                  || '        '                                    -- 39 - Taxa de Juros/Spread
                  || '  '                                          -- 40 - Critério de cálculo de juros
                  || '    '                                        -- 41 - Rentabilidade / Indexador / Taxa
                  || ' '                                           -- 42 - Periodicidade de Correção
                  || ' '                                           -- 43 - Pro-rata de Correção
                  || ' '                                           -- 44 - Tipo de Correção
                  || '       '                                     -- 45 - % da TAxa Flutuante
                  || '        '                                    -- 46 - Taxa de Juros/Spread
                  || '  '                                          -- 47 - Critério de cálculo de juros
                  || '    '                                        -- 48 - Rentabilidade / Indexador / Taxa
                  || ' '                                           -- 49 - Periodicidade de Correção
                  || ' '                                           -- 50 - Pro-rata de Correção
                  || ' '                                           -- 51 - Tipo de Correção
                  || '       '                                     -- 52 - %Taxa Flutuante
                  || '        '                                    -- 53 - TAxa de Juros/Spread
                  || '  '                                          -- 54 - Critério de Cálculo de JUros
                  /* Fluxo de PAgamento de JUros Periódicos */
                  || ' '                                           -- 55 - Periodicidade de Juros
                  || '          '                                  -- 56 - Juros a cada
                  || ' '                                           -- 57 - Tipo Unidade de Tempo
                  || ' '                                           -- 58 - Tipo Prazo
                  || '        '                                    -- 59 - Data Início dos JUros
                  || '  '                                          -- 60 - Dia do Evento dos JUros
                  /* Fluxo de Pagamento de Amortização Periódicas */
                  || ' '                                           -- 61 - Tipo de Amortização
                  || '          '                                  -- 62 - Amortização a cada
                  || ' '                                           -- 63 - Tipo Unidade de Tempo
                  || ' '                                           -- 64 - TIpo Prazo
                  || '        '                                    -- 65 - Data Inicio da Amortização
                  || '  '                                          -- 66 - Dia do Evento da Amortização
                  /* Dados para Depósito */
                  || TO_CHAR(pr_cd_favorecido,'fm00000000')        -- 67 - Conta do FAvorecido
                  || rpad(rw_ass.nrcpfcgc,18,' ')                  -- 68 - CPF/CNPJ do Cliente
                  || rw_ass.dspessoa                               -- 69 - NAtureza CLiente
                  || to_char(fn_sequence('TBCAPT_CUSTODIA_CONTEUDO_ARQ','NRMEUNUM',TO_CHAR(SYSDATE,'rrrrmmdd')),'fm0000000000') -- 70 - Meu nùmero
                  || vr_vluntemi                                   -- 71 - P.U.
                  || '0'                                           -- 72 - Modalidade
                  || '        '                                    -- 73 - Banco Liquidante
                  /* Valor após Incorporação de Juros Inicial */
                  || '                  '                          -- 74 - Valor após incorporação
                  /* Descrição dos Direitos Creditórios (DI com Garantia) */
                  || RPAD(' ',200,' ')                             -- 75 - Descrição dos Direitos Creditórios
                  /* LF com Distribuição Pública */
                  || ' '                                           -- 76 - Distribuição Púbica
                  /* DPGE Emitido no âmbito Res. 4.115/12 */
                  || ' '                                           -- 77 - Emitido com Garantia ao FGC
                  /* LF - Possui Opções */
                  || ' '                                           -- 78 - Possui Opção de Recompra / Resgate pelo Emissor
                  /* Cláusulo de Conversibilidade/Extinção para LFSC e LFSN */
                  || ' '                                           -- 79 - Cláusula de Conversão / Extinção
                  || '                '                            -- 80 - Limite Máximo de COnversibilidade
                  || RPAD(' ',500,' ')                             -- 81 - Critérios para Conversão
                  || ' '                                           -- 82 - Forma de Integralização
                  || ' '                                           -- 83 - Tipo de Cálculo
                  /* Alterações de LFSC e LFSCN com depósito ou sem depósito posterior a data de registro */
                  || ' '                                           -- 84 - Tipo de ALteração
                  || '                  '                          -- 85 - Valor de (BAse de Cálculo)
                  || '        '                                    -- 86 - DAta em (Base de Cálculo)
                  || ' '                                           -- 87 - Alterar Agenda de Eventos
                  /* Recompra pelo Emissor e Autorização do BAnco Central para Elegibilidade do Ativo para LFSC e LFSN */
                  || ' '                                           -- 88 - Recompra pelo Emissor
                  || ' '                                           -- 89 - Obteve Autorização do Banco Central
                  || '          '                                  -- 90 - Controle Interno
                  || vr_dsfimlin;                                  -- 91 - Delimitador de Final de Linha
      -- Retornar Linha montada
      RETURN vr_dsretorn;
    END;
  END fn_gera_regist_operacao;

  -- Função para montar a linha do registro conforme o tipo do arquivo
  FUNCTION fn_gera_registro_lancto(pr_cd_registrador NUMBER                                       -- Código Registrador
                                  ,pr_cd_favorecido  NUMBER                                       -- Código Favorecido
                                  ,pr_idtipo_arquivo tbcapt_custodia_arquivo.idtipo_arquivo%TYPE  -- Tipo do Arquivo
                                  ,pr_idlancamento   tbcapt_custodia_lanctos.idlancamento%TYPE    -- ID do lançamento
                                  ,pr_cdcooper       crapcop.cdcooper%TYPE                        -- Cooperativa
                                  ,pr_nrdconta       crapass.nrdconta%TYPE                        -- Conta
                                  ,pr_vet_aplica   APLI0001.typ_reg_saldo_rdca)                   -- Vetor com informações da aplicação
                         RETURN VARCHAR2 IS
  BEGIN
    -- Direcionar a chamada conforme tipo enviado
    IF pr_idtipo_arquivo = 2 THEN
      RETURN fn_gera_lancto_operacao(pr_cd_registrador,pr_cd_favorecido,pr_idlancamento,pr_cdcooper,pr_nrdconta);
    ELSE
      RETURN fn_gera_regist_operacao(pr_cd_registrador,pr_cd_favorecido,pr_idlancamento,pr_cdcooper,pr_nrdconta,pr_vet_aplica);
    END IF;
  END fn_gera_registro_lancto;

  -- Função para gerar registro de Resgate Antecipado
  FUNCTION fn_gera_regist_resg_antec(pr_idlancamento tbcapt_custodia_lanctos.idlancamento%TYPE  -- ID do lançamento
                                    ,pr_vet_aplica   APLI0001.typ_reg_saldo_rdca)               -- Vetor com informações da aplicação
                         RETURN VARCHAR2 IS
  -- Layout Operações : Layout 4.1.19
  BEGIN
    DECLARE
      -- LInha montada
      vr_dsretorn VARCHAR2(84);
      -- BUsca detalhes do lançamento
      CURSOR cr_lcto IS
        SELECT apl.tpaplicacao
          FROM tbcapt_custodia_lanctos   lct
              ,tbcapt_custodia_aplicacao apl
         WHERE lct.idaplicacao  = apl.idaplicacao
           AND lct.idlancamento = pr_idlancamento;
      rw_lcto cr_lcto%ROWTYPE;
      -- Taxas de Juros
      vr_prtaxflt VARCHAR2(7);
      vr_vltxjrsp VARCHAR2(8);
    BEGIN
      -- Busca detalhes do lançamento
      OPEN cr_lcto;
      FETCH cr_lcto
       INTO rw_lcto;
      CLOSE cr_lcto;
      -- PAra aplicações Pré
      IF rw_lcto.tpaplicacao in(1,3) THEN
        -- Enviar os zeros na taxa juros spread
        vr_prtaxflt := '       ';
        vr_vltxjrsp := '00000000';
      ELSE
        -- Enviar .00001 na taxa flutuante
        vr_prtaxflt := '0000001';
        vr_vltxjrsp := '        ';
      END IF;
      -- Enfim, montar o registro com as informações retornadas
      vr_dsretorn /* Condições de Resgate Antecipado */
                  := 'RDB  '                                       -- 01 - Tipo IF
                  || '3'                                           -- 02 - TIpo Registro
                  || 'INCL'                                        -- 03 - Ação
                  || '   '                                         -- 04 - Filler
                  || to_char(least((pr_vet_aplica.dtvencto-1),pr_vet_aplica.dtcarenc),'RRRRMMDD')    -- 05 - Data do Resgate Antecipado
                  || vr_prtaxflt                                   -- 06 - % da Taxa Flutuante
                  || vr_vltxjrsp                                   -- 07 - Taxa de Juros / Spread
                  || RPAD(' ',47,' ')                              -- 08 - Filler
                  || vr_dsfimlin;                                  -- 09 - Delimitador de Final de Linha
      -- Retornar Linha montada
      RETURN vr_dsretorn;
    END;
  END fn_gera_regist_resg_antec;

  -- Procedimento para criação em tabela dos arquivos a serem enviados posteriormente
  PROCEDURE pc_gera_arquivos_envio(pr_dsdaviso OUT VARCHAR2     --> Avisos dos eventos ocorridos no processo
                                  ,pr_idcritic OUT NUMBER       --> Criticidade da saida
                                  ,pr_cdcritic OUT NUMBER       --> Código da critica
                                  ,pr_dscritic OUT VARCHAR2) IS --> Saida de possível critica no processo
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc gera arquivos envio
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 03/04/2019
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Várias vezes ao dia
    -- Objetivo  : Procedimento responsável por varrer a tabela de pendências de envio e criar
    --             os arquivos para envio na tabela TBCAPT_CUSTODIA_ARQUIVO
    --
    -- Alteracoes:
    --             20/08/2018 - P411 - Usar sempre a Cooperativa zero para montagem do nome do
    --                          arquivo conforme solicitação DAniel Heinen (Marcos-Envolti)
    --
    --            10/10/2018 - P411 - Não mais checar tabela de conteudo de arquivos, mas sim
    --                          setar novas situações de lançamentos em arquivos e assim os mesmos
    --                          serão desprezados em novas execuções (Daniel - Envolti)
    --
    --             06/12/2018 - P411 - Ordernar os registros por idlancamento para eviar
    --                          que resgates do mesmo dia sejam enviadas em ordens diferentes (MArcos-Envolti)
    --
    --             03/04/2019 - Projeto 411 - Fase 2 - Parte 2 - Conciliação Despesa B3 e Outros Detalhes
    --                          Ajusta mensagens de erros e trata de forma a permitir a monitoração automatica.
    --                          Procedimento de Log - tabela: tbgen prglog ocorrencia 
    --                         (Envolti - Belli - PJ411_F2_P2)
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Busca dos lançamentos ainda não gerados em arquivos
      CURSOR cr_lctos IS
        select lct.*,
               count(1) over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) qtregis,
               row_number() over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro order by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) nrseqreg
          from (
                -- Registros ligados a RDC PRé e Pós
                select /*+ index (lct tbcapt_custodia_lanctos_idx01) */
                       rda.cdcooper,
                       rda.nrdconta,
                       rda.nraplica,
                       0 cdprodut,
                       lct.*
                  from craprda                   rda,
                       tbcapt_custodia_aplicacao apl,
                       tbcapt_custodia_lanctos   lct
                 where lct.idsituacao in (0, 2) -- Pendente de Envio ou Re-envio
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (1, 2) -- RDC PRé e Pós
                   and rda.idaplcus = apl.idaplicacao
                union
                -- Registros ligados a novo produto de Captação
                select /*+ index (lct tbcapt_custodia_lanctos_idx01) */
                       rac.cdcooper,
                       rac.nrdconta,
                       rac.nraplica,
                       rac.cdprodut,
                       lct.*
                  from craprac                   rac,
                       tbcapt_custodia_aplicacao apl,
                       tbcapt_custodia_lanctos   lct
                 where lct.idsituacao in (0, 2) -- Pendente de Envio ou Re-envio
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (3, 4) -- PCAPTA Pré e Pós
                   and rac.idaplcus = apl.idaplicacao
               ) lct
         WHERE lct.idtipo_arquivo <> 9 -- Não trazer COnciliação
           -- Se este possui registros de origem, os registros de origem devem
           -- ter gerado Numero CETIP e estarem OK
           and (   lct.idlancto_origem is null
                or exists (select 1
                             from tbcapt_custodia_lanctos lctori
                            where lctori.idlancamento = lct.idlancto_origem
                              and lctori.idsituacao = 8
                              and lctori.cdoperac_cetip is not null))
         order by lct.cdcooper,
                  lct.idtipo_arquivo,
                  lct.dtregistro,
                  lct.idlancamento;
      -- Busca dos dados da Aplicação em rotina já preparada
      vr_tbsaldo_rdca APLI0001.typ_tab_saldo_rdca;

      -- Nome, Id e Header do Arquivo
      vr_nmarquivo tbcapt_custodia_arquivo.nmarquivo%TYPE;
      vr_idarquivo tbcapt_custodia_arquivo.idarquivo%TYPE;
      vr_nrseqlinh NUMBER;
      vr_dsdheader VARCHAR2(100);
      vr_dsregistr VARCHAR2(4000);
      -- Calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      -- Contas Registrador e Favorecido cfme cooperativa
      vr_cdcooper NUMBER := 0;
      vr_cdregist NUMBER(8);
      vr_cdfavore NUMBER(8);
      -- variaveis de contadores para geração de LOG
      vr_qtarqrgt NUMBER := 0;
      vr_qtarqreg NUMBER := 0;
      vr_qtdlinhas NUMBER;
      vr_tpaplica  PLS_INTEGER;
      vr_nmproint1               VARCHAR2 (100) := 'pc_gera_arquivos_envio';
      vr_exc_sai_ger_arq_lop_1   EXCEPTION;
      vr_exc_sai_ger_arq_1       EXCEPTION;
      vr_exc_sai_ger_arq_2       EXCEPTION;
      vr_qtlimerr                NUMBER      (9); 
      vr_dsparlp1                VARCHAR2 (4000); 
      vr_dsparesp                VARCHAR2 (4000);
      vr_dssqlerrm               VARCHAR2 (4000);

    --

    PROCEDURE pc_critica_loop
      IS 
    BEGIN 
            -- Efetuar retorno do erro nao tratado
            vr_cdcritic := NVL(vr_cdcritic,0);
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                                    ,pr_dscritic => vr_dscritic) ||
                           ' ' || vr_dssqlerrm ||
                           ' ' || vr_nomdojob  ||
                           ' ' || vr_nmaction  ||
                           ' ' || vr_nmproint1 ||
                           ' ' || vr_dsparame  ||
                           ' ' || vr_dsparlp1  ||
                           ' ' || vr_dsparesp;                      
            -- Log de erro de execucao
            pc_log(pr_cdcritic => vr_cdcritic
                  ,pr_dscrilog => vr_dscritic
                  ,pr_cdcricid => pr_idcritic); 
    END pc_critica_loop;
    --          
    BEGIN
      
      vr_cdcritic := NULL;
      vr_dscritic := NULL;
      -- Incluir Email
      pr_dsdaviso := '<br><br>' || fn_get_time_char || vr_dspro008_E;
      -- Limite de erros no processo de envio de arquivo ao fornecedor => B3
      vr_qtlimerr := gene0001.fn_param_sistema('CRED',0,'LIMERRO_GERA_ARQ_ENV_B3');
      vr_qtlimerr := NVL(vr_qtlimerr,0);              
      -- Controle Entrada  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            ' ' || vr_nmaction  ||
                            ' ' || vr_nmproint1 ||
                            ' ' || vr_dsparame  ||
                            ', vr_qtlimerr:' || vr_qtlimerr
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            );
      -- Forçado erro - Teste Belli
     --- vr_cdcritic := 0 / 0;
            
      -- Trazemos todos os registros pendentes de geração de arquivos agrupados por cooperativa, 
      -- tipo e data, e então criaremos arquivos para cada quebra
      FOR rw_lct IN cr_lctos LOOP
      BEGIN
        vr_dsparlp1 := ', LOOP rw_lct' ||
                       ', nrseqreg:'       || rw_lct.nrseqreg       ||
                       ', idtipo_arquivo:' || rw_lct.idtipo_arquivo ||
                       ', dtregistro:'     || rw_lct.dtregistro ||
                       ', nrseq_linha:'    || rw_lct.nrseqreg   ||
                       ', idtipo_linha:'   || rw_lct.idtipo_lancto
                       ;
        -- Para o primeiro registro
        IF rw_lct.nrseqreg = 1 THEN
          -- Reiniciar contadores
          vr_qtdlinhas := 0;
          vr_nrseqlinh := 1;
          -- Gerar ID do arquivo
          vr_idarquivo := tbcapt_custudia_arquivo_seq.NEXTVAL;
          -- Gerar nome único do arquivo
          vr_nmarquivo := fn_nmarquivo_custodia(vr_idarquivo,0,rw_lct.idtipo_arquivo,rw_lct.dtregistro);
          -- Criaremos o registro de arquivo
          BEGIN
            INSERT INTO TBCAPT_CUSTODIA_ARQUIVO
                       (idarquivo
                       ,nmarquivo
                       ,idtipo_arquivo
                       ,idtipo_operacao
                       ,idarquivo_origem
                       ,idsituacao
                       ,dtcriacao
                       ,dtregistro)
                 VALUES(vr_idarquivo
                       ,vr_nmarquivo
                       ,rw_lct.idtipo_arquivo
                       ,'E' -- Envio
                       ,NULL -- Sem origem
                       ,0 -- Não enviado
                       ,SYSDATE
                       ,rw_lct.dtregistro);
          EXCEPTION
            WHEN OTHERS THEN
              -- Erro não tratado
              vr_cdcritic  := 1034;  
              vr_dssqlerrm := SQLERRM;
              pr_idcritic  := 2; -- Alto    
              vr_dsparesp  := ', tabela: tbcapt_custodia_arquivo' ||
                              ', idarquivo: '||vr_idarquivo
                           || ', nmarquiv: '||vr_nmarquivo
                           || ', idtipo_operacao: E'
                           || ', idarquivo_origem: NULL'
                           || ', idsituacao: 0'; -- Não enviado
              RAISE vr_exc_sai_ger_arq_lop_1;
          END;
          -- Gerar LOG
          BEGIN
            INSERT INTO TBCAPT_CUSTODIA_LOG
                       (idarquivo
                       ,dtlog
                       ,dslog)
                 VALUES(vr_idarquivo
                       ,SYSDATE
                       ,'Iniciando criação do arquivo '||vr_nmarquivo||
                        ' tipo: '||fn_tparquivo_custodia(rw_lct.idtipo_arquivo,'E'));
          EXCEPTION
            WHEN OTHERS THEN
              -- Erro não tratado
              vr_cdcritic := 1034;
              vr_dssqlerrm := SQLERRM;
              pr_idcritic  := 2; -- Alto    
              vr_dsparesp  := ', tabela: tbcapt_custodia_log' ||
                              ', idarquivo: '|| vr_idarquivo ||
                              ', dslog: '    || 'Iniciando criação do arquivo '||vr_nmarquivo ||
                              ', tipo: '     || fn_tparquivo_custodia(rw_lct.idtipo_arquivo,'E');
              RAISE vr_exc_sai_ger_arq_lop_1;
          END;
          -- Incrementar contador de registros conforme o tipo do arquivo
          IF rw_lct.idtipo_arquivo = 1 THEN
            vr_qtarqreg := vr_qtarqreg+1;
          ELSE
            vr_qtarqrgt := vr_qtarqrgt+1;
          END IF;
            
      -- Forçado erro - Teste Belli
      ---IF ( vr_qtarqreg + vr_qtarqrgt ) > 5 THEN
      ---  vr_cdcritic := 0 / 0;
      ---END IF;
      
          -- Gerar o HEADER, sempre utilizando a data do dia
          vr_dsdheader := fn_gera_header_arquivo(rw_lct.idtipo_arquivo,TRUNC(SYSDATE));
          BEGIN
            
      -- Forçado erro - Teste Belli
      ---IF ( vr_qtarqreg + vr_qtarqrgt ) < 6 THEN
      ---  vr_cdcritic := 0 / 0;
      ---END IF;
      
            INSERT INTO TBCAPT_CUSTODIA_CONTEUDO_ARQ
                       (idarquivo
                       ,nrseq_linha
                       ,idtipo_linha
                       ,dslinha
                       ,idaplicacao
                       ,idlancamento)
                 VALUES(vr_idarquivo
                       ,vr_nrseqlinh
                       ,'C'
                       ,vr_dsdheader
                       ,NULL   -- Header nao possui vinculo com aplicação
                       ,NULL); -- Header nao possui vinculo com lançamento
          EXCEPTION
            WHEN OTHERS THEN
              -- Erro não tratado
              vr_cdcritic := 1034;
              vr_dssqlerrm := SQLERRM;
              pr_idcritic  := 2; -- Alto    
              vr_dsparesp  := ', tabela: tbcapt_custodia_conteudo_arq' ||
                              ', idarquivo: '   ||vr_idarquivo ||
                              ', vr_nrseqlinh: '||vr_nrseqlinh ||
                              ', dslinha: '     ||vr_dsdheader;
              RAISE vr_exc_sai_ger_arq_lop_1;
          END;
          -- Se mudou a cooperativa
          IF vr_cdcooper <> rw_lct.cdcooper THEN
            vr_cdcooper := rw_lct.cdcooper;
            vr_cdregist := gene0001.fn_param_sistema('CRED',rw_lct.cdcooper,'CD_REGISTRADOR_CUSTOD_B3');
            vr_cdfavore := gene0001.fn_param_sistema('CRED',rw_lct.cdcooper,'CD_FAVORECIDO_CUSTOD_B3');
            -- Verifica se a data esta cadastrada
            OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_lct.cdcooper);
            FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
            -- Se nao encontrar
            IF BTCH0001.cr_crapdat%NOTFOUND THEN
              -- Fechar o cursor pois havera raise
              CLOSE BTCH0001.cr_crapdat;
              -- Montar mensagem de critica
              vr_cdcritic:= 1;
              RAISE vr_exc_sai_ger_arq_lop_1;
            ELSE
              -- Apenas fechar o cursor
              CLOSE BTCH0001.cr_crapdat;
            END IF;
          END IF;
        END IF;

        IF (rw_lct.cdprodut = 0) THEN
          vr_tpaplica := 1; /* Não Pcapta */
        ELSE
          vr_tpaplica := 2; /* Pcapta */
        END IF;

        -- Limpar toda a tabela de memória
        vr_tbsaldo_rdca.DELETE();

        -- Busca a listagem de aplicacoes
        APLI0008.pc_lista_aplicacoes_progr(pr_cdcooper   => rw_lct.cdcooper      -- Código da Cooperativa
                                    ,pr_cdoperad   => '1'                  -- Código do Operador
                                    ,pr_nmdatela   => 'EXTRDA'             -- Nome da Tela
                                    ,pr_idorigem   => 5                    -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA )
                                    ,pr_nrdcaixa   => 1                    -- Numero do Caixa
                                    ,pr_nrdconta   => rw_lct.nrdconta      -- Número da Conta
                                    ,pr_idseqttl   => 1                    -- Titular da Conta
                                    ,pr_cdagenci   => 1                    -- Codigo da Agencia
                                    ,pr_cdprogra   => 'EXTRDA'             -- Codigo do Programa
                                    ,pr_nraplica   => rw_lct.nraplica      -- Número da Aplicaçao
                                    ,pr_cdprodut   => rw_lct.cdprodut      -- Código do Produto
                                    ,pr_dtmvtolt   => rw_crapdat.dtmvtolt  -- Data de Movimento
                                    ,pr_idconsul   => 5                    -- Todas
                                    ,pr_idgerlog   => 0                    -- Identificador de Log (0 – Nao / 1 – Sim)
                                    ,pr_tpaplica   => vr_tpaplica          -- Tipo Aplicacao (0 - Todas / 1 - Não PCAPTA (RDC PÓS, PRE e RDCA) / 2 - Apenas PCAPTA)
                                    ,pr_cdcritic   => vr_cdcritic          -- Código da crítica
                                    ,pr_dscritic   => vr_dscritic          -- Descriçao da crítica
                                    ,pr_saldo_rdca => vr_tbsaldo_rdca);   -- Retorno das aplicações

        -- Verifica se ocorreram erros
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Montar mensagem de critica
          RAISE vr_exc_sai_ger_arq_lop_1;
        ELSIF vr_tbsaldo_rdca.count() = 0 THEN
          vr_cdcritic := 426;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                      ||' Coop: '||rw_lct.cdcooper
                      ||',Conta: '||rw_lct.nrdconta
                      ||',NrAplica: '||rw_lct.nraplica
                      ||',Produto: '||rw_lct.cdprodut;
          RAISE vr_exc_sai_ger_arq_lop_1;
        END IF;

        -- Acionar rotina para gerar o Registro do Lançamento
        vr_nrseqlinh := vr_nrseqlinh + 1;
        vr_dsregistr := fn_gera_registro_lancto(vr_cdregist,vr_cdfavore,rw_lct.idtipo_arquivo,rw_lct.idlancamento,rw_lct.cdcooper,rw_lct.nrdconta,vr_tbsaldo_rdca(vr_tbsaldo_rdca.first));
        -- GErar registro na tabela de conteudo do arquivo
        BEGIN
          INSERT INTO TBCAPT_CUSTODIA_CONTEUDO_ARQ
                     (idarquivo
                     ,nrseq_linha
                     ,idtipo_linha
                     ,dslinha
                     ,idaplicacao
                     ,idlancamento)
               VALUES(vr_idarquivo
                     ,vr_nrseqlinh
                     ,'L'
                     ,vr_dsregistr
                     ,rw_lct.idaplicacao
                     ,rw_lct.idlancamento);
        EXCEPTION
          WHEN OTHERS THEN
            -- Erro não tratado
            vr_cdcritic := 1034;
              vr_dssqlerrm := SQLERRM;
              pr_idcritic  := 2; -- Alto    
              vr_dsparesp  := ', tabela: tbcapt_custodia_conteudo_arq' ||
                              ', idarquivo: '    ||vr_idarquivo ||
                              ', vr_nrseqlinh: ' ||vr_nrseqlinh ||
                              ', vr_dsregistr: ' ||vr_dsregistr;
            RAISE vr_exc_sai_ger_arq_lop_1;
        END;
        -- Marca o lançamento como incluído no arquivo
        begin
          update tbcapt_custodia_lanctos l
             set l.idsituacao = decode(l.idsituacao, 0, 4, 2, 5)
           where l.idlancamento = rw_lct.idlancamento;
        exception
          when others then
            -- Erro não tratado
            vr_cdcritic := 1035;
              vr_dssqlerrm := SQLERRM;
              pr_idcritic  := 2; -- Alto    
              vr_dsparesp  := ', tabela: tbcapt_custodia_lancto' ||
                              ', decode(idsituacao, 0, 4, 2, 5)';
            raise vr_exc_sai_ger_arq_lop_1;
        end;

        -- Para Registro de Operação, também vamos enviar as condições de resgate (Carência)
        /*IF rw_lct.idtipo_lancto = 1 THEN

          -- Acionar rotina para gerar as informações de Resgate Antecipado (Carência)
          vr_dsregistr := fn_gera_regist_resg_antec(rw_lct.idlancamento,vr_tbsaldo_rdca(vr_tbsaldo_rdca.first));
          vr_nrseqlinh := vr_nrseqlinh + 1;
          -- GErar registro na tabela de conteudo do arquivo
          BEGIN
            INSERT INTO TBCAPT_CUSTODIA_CONTEUDO_ARQ
                       (idarquivo
                       ,nrseq_linha
                       ,idtipo_linha
                       ,dslinha
                       ,idaplicacao
                       ,idlancamento)
                 VALUES(vr_idarquivo
                       ,vr_nrseqlinh
                       ,'D'
                       ,vr_dsregistr
                       ,rw_lct.idaplicacao
                       ,rw_lct.idlancamento);
          EXCEPTION
            WHEN OTHERS THEN
              -- Erro não tratado
              vr_cdcritic := 1034;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_CONTEUDO_ARQ: '
                          || 'idarquivo: '||vr_idarquivo
                          || ', nrseq_linha: '||(rw_lct.nrseqreg + 1)
                          || ', idtipo_linha: '||rw_lct.idtipo_lancto
                          || ', idaplicacao: '||rw_lct.idaplicacao
                          || ', idlancamento: '||rw_lct.idlancamento
                          || ', dslinha: '||vr_dsregistr
                          || '. '||sqlerrm;
              RAISE vr_exc_saida;
          END;
        END IF;*/

        -- Incementar contador de linhas
        vr_qtdlinhas := vr_qtdlinhas+1;

        -- Para o ultimo registro OU para casos em que o registro
        -- seja igual a quantidade máxima de registros por arquivo
        IF rw_lct.qtregis = rw_lct.nrseqreg THEN
          -- Gerar LOG
          BEGIN
            INSERT INTO TBCAPT_CUSTODIA_LOG
                       (idarquivo
                       ,dtlog
                       ,dslog)
                 VALUES(vr_idarquivo
                       ,SYSDATE
                       ,rw_lct.qtregis||' registros de '||fn_tparquivo_custodia(rw_lct.idtipo_arquivo,'E')||
                        ' incluídos no arquivo');
          EXCEPTION
            WHEN OTHERS THEN
              -- Erro não tratado
              vr_cdcritic  := 1034;
              vr_dssqlerrm := SQLERRM;
              pr_idcritic  := 2; -- Alto    
              vr_dsparesp  := ', tabela: tbcapt_custodia_log' ||
                              ', idarquivo: '||vr_idarquivo ||
                              ', dslog: '    ||rw_lct.qtregis || ' registros de '||
                                               fn_tparquivo_custodia(rw_lct.idtipo_arquivo,'E')||
                                               ' incluídos no arquivo';
              RAISE vr_exc_sai_ger_arq_lop_1;
          END;
          -- Incrementar o LOG
          pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Arquivo '||vr_nmarquivo||'('||fn_tparquivo_custodia(rw_lct.idtipo_arquivo,'E')||') gerado com um total de : '||vr_qtdlinhas||' linha(s)';
          
          -- Gravar a cada arquivo gerado
          -- Forçado não gravar - Teste Belli 
          --COMMIT;

        END IF;

      EXCEPTION
        WHEN vr_exc_sai_ger_arq_lop_1 THEN
              -- Efetuar retorno do erro tratado
              pc_critica_loop;         
              IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
                RAISE vr_exc_sai_ger_arq_2;
              ELSE               
                vr_cdcritic := NULL;
                vr_dscritic := NULL;        
              END IF;  
        WHEN OTHERS THEN
              -- Acionar log exceções internas
              CECRED.pc_internal_exception(pr_cdcooper => 3);
              --
              vr_cdcritic  := 9999;
              vr_dssqlerrm := SQLERRM;
              pr_idcritic  := 2; -- Alta
              pc_critica_loop;                  
              -- Controle maximo de criticas
              IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
                RAISE vr_exc_sai_ger_arq_2;
              ELSE               
                vr_cdcritic := NULL;
                vr_dscritic := NULL;        
              END IF;                
      END;
      END LOOP;
      
      /*
      -- Enviar ao LOG resumo da execução
      IF vr_qtarqrgt + vr_qtarqreg > 0 THEN
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Total de arquivos gerados:'
                    ||vr_dscarque||'Registro = '||vr_qtarqreg
                    ||vr_dscarque||'Operação = '||vr_qtarqrgt;
      ELSE
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Nenhum arquivo foi gerado!';
      END IF;
      */

      -- Controle Saida  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            '. Finalizado' ||
                            ' '      || vr_nmaction  ||
                            ' '      || vr_nmproint1 ||
                            ', arquivos gerados => ' ||
                            ', de registro:' || vr_qtarqreg ||
                            ', de operação:' || vr_qtarqrgt                                                        
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            );
            
      -- Forçado erro - Teste Belli
      ---vr_cdcritic := 0 / 0;

    EXCEPTION
      WHEN vr_exc_sai_ger_arq_2 THEN   
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Acionar log exceções internas
        CECRED.pc_internal_exception(pr_cdcooper => 3);
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                           ' ' || SQLERRM      ||
                           ' ' || vr_nmaction  ||
                           ' ' || vr_nmproint1 ||
                           ' ' || vr_dsparame  ||
                           ' ' || vr_nomdojob; 
        pr_idcritic := 2; -- Alta                  
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic
              ,pr_cdcricid => pr_idcritic);    
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_gera_arquivos_envio;

  -- Rotina para enviar o arquivo repassado
  PROCEDURE pc_envia_arquivo_cd(pr_nmarquiv IN VARCHAR2       --> Nome do arquivo a enviar
                               ,pr_nmdireto IN VARCHAR2       --> Caminho dos arquivos a enviar
                               ,pr_dsdirenv IN VARCHAR2       --> Diretório Envia
                               ,pr_dsdirend IN VARCHAR2       --> Diretório Enviados
                               ,pr_flaguard IN BOOLEAN        --> Aguardar
                               ,pr_idcritic OUT NUMBER        --> Criticidade da saida
                               ,pr_cdcritic OUT NUMBER        --> Código da critica
                               ,pr_dscritic OUT VARCHAR2) IS  --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc envia arquivo_cd
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 03/04/2019
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Efetuar o envio dos arquivos repassados ao ConnectDirect
    --             Precisamos apenas mover os arquivos para a pasta correspondente
    --             do envio e aguardar o Software enviar o arquivos. Após, o Software
    --             move estes arquivos para a pasta enviados
    -- Alteracoes:
    --             03/04/2019 - Projeto 411 - Fase 2 - Parte 2 - Conciliação Despesa B3 e Outros Detalhes
    --                          Ajusta mensagens de erros e trata de forma a permitir a monitoração automatica.
    --                          Procedimento de Log - tabela: tbgen prglog ocorrencia 
    --                         (Envolti - Belli - PJ411_F2_P2)
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_exc_tratada_ou_herdada  EXCEPTION;
      vr_typ_saida  VARCHAR2(3);      --> Saída do comando no OS
      vr_nmproint1  VARCHAR2  (100) := 'pc_envia_arquivo_cd';
      vr_dssqlerrm  VARCHAR2 (4000) := NULL;
      vr_dsparesp   VARCHAR2 (4000) := NULL;
    --
    PROCEDURE pc_finaliza
      IS
    BEGIN        
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := NVL(vr_cdcritic,0);
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic) ||
                           ' ' || vr_dssqlerrm || 
                           ' ' || vr_nomdojob  ||
                           ' ' || vr_nmaction  ||
                           ' ' || vr_nmproint1 ||
                           ' ' || vr_dsparame  ||
                           ' ' || vr_dsparesp;    
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic
              ,pr_cdcricid => pr_idcritic);    
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
    END;
    --
    
    BEGIN
      
      vr_cdcritic := NULL;
      vr_dscritic := NULL;        
      vr_dsparesp := ', pr_nmarquiv:' || pr_nmarquiv ||
                     ', pr_nmdireto:' || pr_nmdireto ||
                     ', pr_dsdirenv:' || pr_dsdirenv ||
                     ', pr_dsdirend:' || pr_dsdirend ||
                     ', pr_flaguard:' || CASE pr_flaguard
                                           WHEN TRUE THEN 'TRUE'
                                           ELSE 'FALSE'
                                         END;
                     
      -- Forçado erro - Teste Belli
      ---vr_cdcritic := 0 / 0;

      -- Primeiramente checamos se o arquivo por ventura já não está na pasta enviados
      IF gene0001.fn_exis_arquivo(pr_caminho => pr_dsdirend||'/'||pr_nmarquiv) THEN
        -- O que ocorreu é que a cópia anterior não havia sido enviada na última execução,
        -- mas o envio ocorreu com sucesso entre as duas execuções do job.
        -- Devemos remover o arquivo da pasta temporária, caso exista.
        if gene0001.fn_exis_arquivo(pr_caminho => pr_nmdireto||'/'||pr_nmarquiv) then
          gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||pr_nmdireto||'/'||pr_nmarquiv
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => vr_dscritic);
          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic := '1-' || vr_dscritic;
            RAISE vr_exc_tratada_ou_herdada;
          END IF;
        end if;
      ELSE
        -- Checamos se o arquivo já não foi copiado a envia
        IF NOT gene0001.fn_exis_arquivo(pr_caminho => pr_dsdirenv||'/'||pr_nmarquiv) THEN
          -- Devemos movê-lo para a pasta envia
          gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||pr_nmdireto||'/'||pr_nmarquiv||' '||pr_dsdirenv
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => vr_dscritic);
          -- Se retornou erro, incrementar a mensagem e retornar
          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic := '2-' || vr_dscritic;
            RAISE vr_exc_tratada_ou_herdada;
          END IF;
        else
          -- Se já está na pasta envia, devemos remover o arquivo da pasta temporária
          if gene0001.fn_exis_arquivo(pr_caminho => pr_nmdireto||'/'||pr_nmarquiv) then
            gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||pr_nmdireto||'/'||pr_nmarquiv
                                       ,pr_typ_saida   => vr_typ_saida
                                       ,pr_des_saida   => vr_dscritic);
            IF vr_typ_saida = 'ERR' THEN
              vr_dscritic := '3-' || vr_dscritic;
              RAISE vr_exc_tratada_ou_herdada;
            END IF;
          end if;
        END IF;
        -- Agora devemos checar o envio do arquivo, que é garantido quando o arquivo
        -- é movido da envia para enviados pelo Connect Direct.
        -- Testar envio (Existencia na enviados)
        IF pr_flaguard and 
           NOT gene0001.fn_exis_arquivo(pr_caminho => pr_dsdirend||'/'||pr_nmarquiv) THEN
          -- Se não conseguiu enviar
          vr_cdcritic := 1483; -- Arquivo persiste na pasta ENVIA
          RAISE vr_exc_tratada_ou_herdada;
        END IF;
      END IF;

      -- Forçado erro - Teste Belli
      ---vr_cdcritic := 0 / 0;

    EXCEPTION
      WHEN vr_exc_tratada_ou_herdada THEN
        pr_idcritic  := 1; -- Média  
        pc_finaliza;
      WHEN OTHERS THEN
        -- Acionar log exceções internas
        CECRED.pc_internal_exception(pr_cdcooper => 3);
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic  := 9999;        
        vr_dssqlerrm := SQLERRM;
        pr_idcritic  := 2; -- Alta                
        pc_finaliza;
    END;
  END pc_envia_arquivo_cd;


  -- Rotina para preparar e direcionar o envio dos arquivos pendentes para Custódia
  PROCEDURE pc_processa_envio_arquivos(pr_flenvreg IN VARCHAR2      --> Envio de Registros Habilidade
                                      ,pr_flenvrgt IN VARCHAR2      --> Envio de Resgates Habilitado
                                      ,pr_dsdircnd IN VARCHAR2      --> Caminho raiz Connect Direct
                                      ,pr_dsdirbkp IN VARCHAR2      --> Diretório Backup dos arquivos
                                      ,pr_dsdaviso OUT VARCHAR2     --> Avisos dos eventos ocorridos no processo
                                      ,pr_idcritic OUT NUMBER       --> Criticidade da saida
                                      ,pr_cdcritic OUT NUMBER       --> Código da critica
                                      ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc processa envio_arquivos
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 03/04/2019
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Identificar arquivos pendentes de envio, gerá-los na pasta temporária, e enviar via Connect Direct
    --
    -- Alteracoes:
    --             03/04/2019 - Projeto 411 - Fase 2 - Parte 2 - Conciliação Despesa B3 e Outros Detalhes
    --                          Ajusta mensagens de erros e trata de forma a permitir a monitoração automatica.
    --                          Procedimento de Log - tabela: tbgen prglog ocorrencia 
    --                         (Envolti - Belli - PJ411_F2_P2)
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Variaveis auxiliares
      vr_utl_file utl_file.file_type;

      -- Quantidade de arquivos processados
      vr_qtdaruiv NUMBER := 0;

      -- Busca dos arquivps pendentes e seu conteudo
      CURSOR cr_arquivos IS
        SELECT arq.idarquivo
              ,arq.nmarquivo
              ,arq.idtipo_arquivo
          FROM tbcapt_custodia_arquivo arq
         WHERE arq.idtipo_operacao = 'E'
           AND arq.idsituacao = 0 -- Pendente envio
           -- Conferir Flag de envio ativo
           AND ((arq.idtipo_arquivo = 1 AND pr_flenvreg = 'S')
                OR
                (arq.idtipo_arquivo = 2 AND pr_flenvrgt = 'S'))
         ORDER BY arq.idarquivo
         FOR UPDATE;

      -- Busca do conteudo do arquivo
      CURSOR cr_conteudo(pr_idarquivo tbcapt_custodia_arquivo.idarquivo%TYPE) IS
        SELECT cnt.dslinha
          FROM tbcapt_custodia_conteudo_arq cnt
         WHERE cnt.idarquivo = pr_idarquivo
         ORDER BY cnt.nrseq_linha;

      -- Variaveis de contadores para geração de LOG
      vr_qtdsuces NUMBER := 0;
      vr_qtderros NUMBER := 0;

      --> Vetor de arquivos a ignorar (erro no primeiro laço)
      TYPE vr_typ_tab_arquivos_erro IS TABLE OF tbcapt_custodia_arquivo.nmarquivo%TYPE INDEX BY PLS_INTEGER;
      vr_tab_arqerros vr_typ_tab_arquivos_erro;

      --> Saída do comando no OS
      vr_typ_saida  VARCHAR2(3);
      vr_dsdaviso   VARCHAR2(32767);
      vr_nmproint1               VARCHAR2 (100) := 'pc_processa_envio_arquivos';
      vr_exc_saida_envia_arq_1   EXCEPTION;
      vr_exc_saida_envia_arq_2   EXCEPTION;

    BEGIN
      vr_cdcritic := NULL;
      vr_dscritic := NULL;  
      -- Incluir Email
      pr_dsdaviso := '<br><br>' || fn_get_time_char || vr_dspro007_E; 
      -- Controle Entrada  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            ' ' || vr_nmaction  ||
                            ' ' || vr_nmproint1 ||
                            ' ' || vr_dsparame 
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            );      
      -- Forçado erro - Teste Belli
      ---vr_cdcritic := 0 / 0;
            
      -- Tentaremos duas vezes, a primeira não aguardamos, pois os arquivos são enviados de 1 em 1 minuto,
      -- então primeiro copiamos todos os arquivos e na segunda conferimos se foram enviados
      FOR vr_tentativ IN 1..2 LOOP
        -- Buscamos todos os arquivos pendentes de envio
        FOR rw_arq IN cr_arquivos LOOP
          -- Incrementar contador
          vr_qtdaruiv := vr_qtdaruiv + 1;
          -- Caso o arquivo esteja na lista de arquivos com erro
          IF vr_tab_arqerros.exists(rw_arq.idarquivo) THEN
            -- Ignorá-lo
            CONTINUE;
          END IF;
          -- Somente na primeira vez
          IF vr_tentativ = 1 THEN
            -- Efetuar a criação do arquivo no diretório temporário
            gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdirarq
                                    ,pr_nmarquiv => rw_arq.nmarquivo
                                    ,pr_tipabert => 'W'
                                    ,pr_utlfileh => vr_utl_file
                                    ,pr_des_erro => vr_dscritic);
            -- Se houve erro, não podemos criar o arquivo
            IF vr_dscritic IS NOT NULL THEN
              -- Gerar LOG para o arquivo e continuar
              BEGIN
                INSERT INTO TBCAPT_CUSTODIA_LOG
                           (idarquivo
                           ,dtlog
                           ,dslog)
                     VALUES(rw_arq.idarquivo
                           ,SYSDATE
                           ,'Erro ao criar o arquivo '||rw_arq.nmarquivo||' no diretório temporário '||vr_dsdirarq||' --> '||vr_dscritic);
              EXCEPTION
                WHEN OTHERS THEN
                  -- Erro não tratado
                  vr_cdcritic := 1034;
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_LOG: '
                              || 'idarquivo: '||rw_arq.idarquivo
                              || ', dtlog: '||SYSDATE
                              || ', dslog: '||'Erro ao criar o arquivo '||rw_arq.nmarquivo||' no diretório temporário '||vr_dsdirarq||' --> '||vr_dscritic
                              || '. '||sqlerrm;
                  RAISE vr_exc_saida_envia_arq_2;
              END;
              vr_qtderros := vr_qtderros +1;
              -- Adicionar a lista de ignorados
              vr_tab_arqerros(rw_arq.idarquivo) := rw_arq.nmarquivo;
              -- Ir ao proximo arquivo
              CONTINUE;
            END IF;

            -- Buscar todas as linhas do arquivo
            FOR rw_cnt IN cr_conteudo(rw_arq.idarquivo) LOOP
              -- Adicionar linha ao arquivo
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utl_file
                                            ,pr_des_text => rw_cnt.dslinha);

            END LOOP;

            -- AO final, fechar o arquivo
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utl_file);
          END IF;
          -- Chamar processo de envio via Connect Direct
          -- Na primeira vez não aguardaremos, na segunda sim
          pc_envia_arquivo_cd(pr_nmarquiv => rw_arq.nmarquivo         --> Nome do arquivo a enviar
                             ,pr_nmdireto => vr_dsdirarq              --> Caminho dos arquivos a enviar
                             ,pr_dsdirenv => pr_dsdircnd||vr_dsdirenv --> Diretório a enviar ao CD
                             ,pr_dsdirend => pr_dsdircnd||vr_dsdirevd --> Diretório enviados ao CD
                             ,pr_flaguard => vr_tentativ=2            --> Aguardar na segunda vez
                             ,pr_idcritic => vr_idcritic              --> Identificador critica
                             ,pr_cdcritic => vr_cdcritic              --> Codigo da critica
                             ,pr_dscritic => vr_dscritic);            --> Retorno de crítica

          -- Código comum, para gravação do LOG independente de sucesso ou não
          IF vr_dscritic IS NOT NULL THEN
            -- Houve erro - Adicionar a lista de ignorados
            vr_tab_arqerros(rw_arq.idarquivo) := rw_arq.nmarquivo;
          ELSE
            -- Somente no segundo laço
            IF vr_tentativ=2 THEN
              -- Gerar cópia do arquivo que está na enviados para a pasta de Backup, de onde o financeiro terá acesso
              gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||pr_dsdircnd||vr_dsdirevd||'/'||rw_arq.nmarquivo||' '||pr_dsdirbkp||vr_dsdirevd
                                         ,pr_typ_saida   => vr_typ_saida
                                         ,pr_des_saida   => vr_dscritic);
              -- Se retornou erro, incrementar a mensagem e retornoar
              IF vr_typ_saida = 'ERR' THEN
                -- Houve erro                
                vr_cdcritic := 1484; -- Arquivo enviado, porém nao foi possivel copiar arquivo para pasta de Backup
                vr_cdcritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                              ' ' || vr_dscritic  ||
                              ' ' || vr_nmaction  ||
                              ' ' || vr_nmproint1 ||
                              ' ' || vr_dsparame;                              
                vr_dsdaviso := vr_cdcritic || vr_dscarque;                              
                -- Controle log  
                pc_log(pr_cdcritic => vr_cdcritic
                      ,pr_dscrilog => gene0001.fn_busca_critica(vr_cdcritic) ||
                                      ' ' || vr_nmaction  ||
                                      ' ' || vr_nmproint1 ||
                                      ' ' || vr_dsparame
                      ); 
                vr_cdcritic := NULL;                
                vr_dscritic := NULL;
              END IF;

              -- Gerar LOG
              BEGIN
                INSERT INTO TBCAPT_CUSTODIA_LOG
                           (idarquivo
                           ,dtlog
                           ,dslog)
                     VALUES(rw_arq.idarquivo
                           ,SYSDATE
                           ,'Arquivo '||rw_arq.nmarquivo||' enviado com sucesso!');
              EXCEPTION
                WHEN OTHERS THEN
                  -- Erro não tratado
                  vr_cdcritic := 1034;
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_LOG: '
                              || 'idarquivo: '||rw_arq.idarquivo
                              || ', dtlog: '||SYSDATE
                              || ', dslog: '||'Arquivo '||rw_arq.nmarquivo||' enviado com sucesso!'
                              || '. '||sqlerrm;
                  RAISE vr_exc_saida_envia_arq_2;
              END;
              -- Caso não tenha encontrado erro acima
              IF vr_dscritic IS NULL THEN
                -- Atualizaremos a tabela de envio
                BEGIN
                  UPDATE tbcapt_custodia_arquivo arq
                     SET arq.idsituacao = 1       -- Enviado
                        ,arq.dtprocesso = SYSDATE -- Momento do Envio
                   WHERE arq.idarquivo = rw_arq.idarquivo;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Erro não tratado
                    vr_cdcritic := 1035;
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_arquivo: '
                                || 'idsituacao: 1'
                                || ', dtprocesso: '||SYSDATE
                                || ' com idarquivo: '||rw_arq.idarquivo||'. '||sqlerrm;
                    RAISE vr_exc_saida_envia_arq_2;
                END;
              END IF;
              -- Caso não tenha encontrado erro acima
              IF vr_dscritic IS NULL THEN
                -- Atualizaremos a tabela de Lançamentos em todos os
                -- registros relacionados as linhas deste arquivo
                BEGIN
                  UPDATE tbcapt_custodia_lanctos lct
                     SET lct.idsituacao = decode(lct.idsituacao,4,1,5,3,1) -- Enviado ou Re-envio e aguardando retorno
                        ,lct.dtenvio = SYSDATE
                   WHERE lct.idlancamento IN(SELECT cnt.idlancamento
                                               FROM tbcapt_custodia_conteudo_arq cnt
                                              WHERE cnt.idarquivo = rw_arq.idarquivo);
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Erro não tratado
                    vr_cdcritic := 1035;
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_lanctos: '
                                || 'idsituacao: 1 ou 3 (De acordo com situação anterior)'
                                || ', dtenvio: '||SYSDATE
                                || ' com idlancamento in: SELECT cnt.idlancamento FROM tbcapt_custodia_conteudo_arq cnt WHERE cnt.idarquivo = '||rw_arq.idarquivo||'. '||sqlerrm;
                    RAISE vr_exc_saida_envia_arq_2;
                END;
              END IF;
            END IF;
          END IF;
          -- Em caso de critica
          IF vr_dscritic IS NOT NULL THEN
            -- Adicionar arquivo a lista de ignorados
            vr_tab_arqerros(rw_arq.idarquivo) := rw_arq.nmarquivo;
            -- Gerar LOG
            BEGIN
              INSERT INTO TBCAPT_CUSTODIA_LOG
                         (idarquivo
                         ,dtlog
                         ,dslog)
                   VALUES(rw_arq.idarquivo
                         ,SYSDATE
                         ,vr_dscritic);
            EXCEPTION
              WHEN OTHERS THEN
                -- Erro não tratado
                vr_cdcritic := 1034;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_LOG: '
                            || 'idarquivo: '||rw_arq.idarquivo
                            || ', dtlog: '||SYSDATE
                            || ', dslog: '||vr_dscritic
                            || '. '||sqlerrm;
                RAISE vr_exc_saida_envia_arq_2;
            END;
            vr_qtderros := vr_qtderros +1;
          ELSE
            -- Somente no segundo laço
            IF vr_tentativ = 2 THEN
              vr_qtdsuces := vr_qtdsuces +1;
            END IF;
          END IF;
          -- Sair se processou a quantidade máxima de arquivos por execução
          IF vr_qtdaruiv >= vr_qtdexjob THEN
            EXIT;
          END IF;
        END LOOP;
      END LOOP;
      -- Gravar
      --COMMIT;
      -- Enviar ao LOG resumo da execução
      IF vr_qtdsuces + vr_qtderros > 0 THEN
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Total de arquivos enviados: '||(vr_qtdsuces + vr_qtderros)||', sendo: '
                    ||vr_dscarque||'Sucesso = '||vr_qtdsuces
                    ||vr_dscarque||'Erro = '||vr_qtderros;
        -- Se há avisos
        IF vr_dsdaviso IS NOT NULL THEN
          pr_dsdaviso := pr_dsdaviso ||vr_dscarque||'Avisos: '||vr_dsdaviso;
        END IF;
      ELSE
        -- Houve erro                
        vr_cdcritic := 1485; -- Nenhum arquivo enviado
        vr_cdcritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                      ' ' || vr_dscritic  ||
                      ' ' || vr_nmaction  ||
                      ' ' || vr_nmproint1 ||
                      ' ' || vr_dsparame;           
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || vr_cdcritic;                              
        -- Controle log
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => gene0001.fn_busca_critica(vr_cdcritic) ||
                              ' ' || vr_nmaction  ||
                              ' ' || vr_nmproint1 ||
                              ' ' || vr_dsparame
              ); 
        vr_cdcritic := NULL;                
        vr_dscritic := NULL;
      END IF;
	  
      -- Controle Saida  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            '. Finalizado' ||
                            ' '      || vr_nmaction ||
                            ' '      || vr_nmproint1 ||
                            ' '      || vr_dsparame 
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            ); 

      -- Forçado erro - Teste Belli
      ---vr_cdcritic := 0 / 0;

    EXCEPTION
      WHEN vr_exc_saida_envia_arq_2 THEN   
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN vr_exc_saida_envia_arq_1 THEN
        vr_cdcritic := NVL(vr_cdcritic,0);
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic) ||
                           ' ' || vr_nmaction  ||
                           ' ' || vr_nmproint1 ||
                           ' ' || vr_dsparame  ||
                           ' ' || vr_nomdojob;
        pr_idcritic := 1; -- Media   
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic
              ,pr_cdcricid => pr_idcritic);    
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Acionar log exceções internas
        CECRED.pc_internal_exception(pr_cdcooper => 3);
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                           ' ' || SQLERRM      ||
                           ' ' || vr_nmaction  ||
                           ' ' || vr_nmproint1 ||
                           ' ' || vr_dsparame  ||
                           ' ' || vr_nomdojob; 
        pr_idcritic := 2; -- Alta                  
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic
              ,pr_cdcricid => pr_idcritic);    
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_processa_envio_arquivos;


  -- Rotina checar possives retornos recebidas na pasta repassada
  PROCEDURE pc_checar_recebe_cd(pr_idtiparq IN NUMBER        --> TIpo de Busca (0-Todas,9-Conciliação,5-Retornos)
                               ,pr_dsdirrec IN VARCHAR2      --> Diretorio Recebe
                               ,pr_dsdirrcb IN VARCHAR2      --> Diretório Recebidos
                               ,pr_dsdirbkp IN VARCHAR2      --> Diretório Backup dos arquivos
                               ,pr_dsdaviso OUT VARCHAR2     --> Avisos dos eventos ocorridos no processo
                               ,pr_idcritic OUT NUMBER       --> Criticidade da saida
                               ,pr_cdcritic OUT NUMBER       --> Código da critica
                               ,pr_dscritic OUT VARCHAR2) IS --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc checar recebe
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 03/04/2019
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Verificar o retorno dos arquivos na pasta de recebe
    --             do Connect Direct, gravá-los na tabela e gerar para Recebidos
    --
    -- Alteracoes:
    --             03/04/2019 - Projeto 411 - Fase 2 - Parte 2 - Conciliação Despesa B3 e Outros Detalhes
    --                          Ajusta mensagens de erros e trata de forma a permitir a monitoração automatica.
    --                          Procedimento de Log - tabela: tbgen prglog ocorrencia 
    --                         (Envolti - Belli - PJ411_F2_P2)
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_dspadrao         VARCHAR2(100);                             --> Padrão de busca
      vr_dslstarq         VARCHAR2(32767);                            --> Lista de arquivos encontrados
      vr_lstarqre         gene0002.typ_split;                        --> Split de arquivos encontrados
      vr_utl_file         utl_file.file_type;                        --> Handle
      vr_typ_saida        VARCHAR2(3);                               --> Saída do comando no OS
      vr_idarquivo_origem tbcapt_custodia_arquivo.idarquivo%TYPE;    --> Arquivo de origem
      vr_idarquivo        tbcapt_custodia_arquivo.idarquivo%TYPE;    --> Sequencia de gravação do arquivo
      vr_qtdregist        NUMBER;                                    --> Quantidade de registros
      vr_dslinha          tbcapt_custodia_conteudo_arq.dslinha%TYPE; --> Conteudo das linhas
      vr_idtipo_arquivo   tbcapt_custodia_arquivo.idtipo_arquivo%TYPE; --> Tipo do Arquivo
      vr_dtrefere         DATE;                                        --> Data de referência do arquivo
      vr_idtipo_linha     tbcapt_custodia_conteudo_arq.idtipo_linha%TYPE; --> Tipo da Linha
      v_hora              varchar2(6);

      --> Checar se arquivo já não foi retornado
      CURSOR cr_arq_duplic(pr_nmarquiv VARCHAR2) IS
        SELECT arq.idarquivo
              ,arq.idtipo_arquivo
              ,arq.dtregistro
          FROM tbcapt_custodia_arquivo arq
         WHERE arq.idtipo_operacao = 'R'
           AND arq.nmarquivo = pr_nmarquiv;

      --> Busca do arquivo de origem
      CURSOR cr_arq_origem(pr_nmarquiv VARCHAR2) IS
        SELECT arq.idarquivo
              ,arq.idtipo_arquivo
              ,arq.dtregistro
          FROM tbcapt_custodia_arquivo arq
         WHERE arq.idtipo_operacao = 'E'
           -- Remover o começo do arquivo enviado e o final do arquivo recebeido, o interior deverá ser o mesmo
           AND SUBSTR(arq.nmarquivo,INSTR(arq.nmarquivo,'.',1)+1) = SUBSTR(pr_nmarquiv,1,INSTR(pr_nmarquiv,'.','-1')-1);
      --> Contador de registros
      vr_qtdencon NUMBER := 0;
      vr_qtdignor NUMBER := 0;
      -- Flag de ignorar
      vr_flignore BOOLEAN;
      -- Alertas
      vr_idtiparq NUMBER;
      vr_dsdaviso VARCHAR2(32767);
      --
      vr_nmproint1               VARCHAR2  (100) := 'pc_checar_recebe_cd';
      vr_dsparesp                VARCHAR2 (4000);
      vr_exc_saida_checar_rec_1  EXCEPTION;
      vr_exc_saida_checar_rec_2  EXCEPTION;
      
    BEGIN
      
      vr_cdcritic := NULL;
      vr_dscritic := NULL;        
      vr_dsparesp := ', pr_idtiparq' || pr_idtiparq ||
                     ', pr_dsdirrec' || pr_dsdirrec ||
                     ', pr_dsdirrcb' || pr_dsdirrcb ||
                     ', pr_dsdirbkp' || pr_dsdirbkp;
      -- Incluir Email
      pr_dsdaviso := '<br><br>' || fn_get_time_char || vr_dspro006_E; 
      -- Controle Entrada  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            ' ' || vr_nmaction  ||
                            ' ' || vr_nmproint1 ||
                            ' ' || vr_dsparame 
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            );	  
      -- Forçado erro - Teste Belli
      ---vr_cdcritic := 0 / 0;
	  
      -- Efetuar laço para buscar tanto conciliação quanto retorno, caso solicitado
      FOR vr_loop IN 1..2 LOOP
        -- Somente processar na segunda iteração se foi solicitado todas
        IF vr_loop = 2 AND pr_idtiparq <> 0 THEN
          CONTINUE;
        END IF;
        -- Se solicitado todas
        IF pr_idtiparq = 0 THEN
          IF vr_loop = 1 THEN
            -- Primeiro processar retornos
            vr_idtiparq := 5;
          ELSE
            -- Depois conciliação
            vr_idtiparq := 9;
          END IF;
        ELSE
          -- Processar somente a repassada
          vr_idtiparq := pr_idtiparq;
        END IF;
        -- Incluir LOG
        pr_dsdaviso := fn_get_time_char || 'Iniciando Checagem de Arquivos de '||fn_tparquivo_custodia(vr_idtiparq,'E')||' Devolvidos pela B3...';
        -- BUsca específica conforme a opção
        IF vr_idtiparq = 9 THEN
          -- Conciliação
          vr_dspadrao := 'CETIP%DPOSICAOCUSTODIA%';
          vr_idtipo_arquivo := 9; -- Conciliação
          vr_idarquivo_origem := NULL; -- Sem origem
        ELSE
          -- Retorno
          vr_dspadrao := '%.TXT.S%';
          vr_idtipo_arquivo := 0; -- Será definido depois
        END IF;

        -- Usamos rotina para listar os arquivos da pasta conforme padrão definido acima
        gene0001.pc_lista_arquivos(pr_path     => pr_dsdirrec   --> Dir busca
                                  ,pr_pesq     => vr_dspadrao   --> Chave busca(Padrão passado)
                                  ,pr_listarq  => vr_dslstarq   --> Lista encontrada
                                  ,pr_des_erro => vr_dscritic); --> Possível erro
        -- Se retorno erro:
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida_checar_rec_1;
        END IF;
        -- Separar a lista de arquivos encontradas com função existente
        vr_lstarqre := gene0002.fn_quebra_string(pr_string => vr_dslstarq, pr_delimit => ',');
        -- Se encontrou pelo menos um registro
        IF vr_lstarqre.count() > 0 THEN
          -- Para cada arquivo encontrado na pasta
          FOR vr_idx IN 1..vr_lstarqre.count LOOP
            -- Reiniciar controle de ignore
            vr_flignore := FALSE;
            --
            if vr_dspadrao = 'CETIP%DPOSICAOCUSTODIA%' then
              -- Renomeia arquivo, para que não haja duplicidade com os próximos ZIPs
              v_hora := to_char(sysdate, 'hh24miss');
              gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||pr_dsdirrec||'/'||vr_lstarqre(vr_idx)||' '||pr_dsdirrec||'/'||vr_lstarqre(vr_idx)||'_'||v_hora
                                         ,pr_typ_saida   => vr_typ_saida
                                         ,pr_des_saida   => vr_dscritic);
              vr_lstarqre(vr_idx) := vr_lstarqre(vr_idx)||'_'||v_hora;
            end if;
            -- Devemos checar se o arquivo em questão já não foi retornado
            OPEN cr_arq_duplic(vr_lstarqre(vr_idx));
            FETCH cr_arq_duplic
             INTO vr_idarquivo_origem
                 ,vr_idtipo_arquivo
                 ,vr_dtrefere;
            -- Se encontrar, ignoraremos este arquivo pois ele já foi retornado anteriormente
            IF cr_arq_duplic%FOUND THEN
              CLOSE cr_arq_duplic;
              vr_qtdignor := vr_qtdignor + 1;
              --
              vr_flignore := TRUE;
            ELSE
              CLOSE cr_arq_duplic;
            END IF;
            -- Se não for para ignorar
            IF NOT vr_flignore THEN
              -- Reiniciar o contador
              vr_qtdregist := 1;
              vr_dtrefere  := NULL;
              -- Para retorno vamos buscar o arquivo de envio relacionado
              IF vr_idtiparq = 5 THEN
                --> Busca do arquivo de origem
                OPEN cr_arq_origem(vr_lstarqre(vr_idx));
                FETCH cr_arq_origem
                 INTO vr_idarquivo_origem
                     ,vr_idtipo_arquivo
                     ,vr_dtrefere;
                -- Se não encontrar, ignoraremos este arquivo pois não é relacionado a nenhum envio
                IF cr_arq_origem%NOTFOUND THEN
                  CLOSE cr_arq_origem;
                  vr_qtdignor := vr_qtdignor + 1;
                  --
                  vr_flignore := TRUE;
                ELSE
                  CLOSE cr_arq_origem;
                END IF;
              END IF;
              -- Se não ignorar o mesmo
              IF NOT vr_flignore THEN

                -- Criaremos o registro de arquivo
                BEGIN
                  INSERT INTO TBCAPT_CUSTODIA_ARQUIVO
                             (nmarquivo
                             ,idtipo_arquivo
                             ,idtipo_operacao
                             ,idarquivo_origem
                             ,idsituacao
                             ,dtcriacao
                             ,dtregistro
                             )
                       VALUES(vr_lstarqre(vr_idx)
                             ,vr_idtipo_arquivo
                             ,'R'  -- Retorno
                             ,vr_idarquivo_origem
                             ,0 -- Não Processado
                             ,SYSDATE
                             ,vr_dtrefere
                             )
                       RETURNING idarquivo
                            INTO vr_idarquivo;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Erro não tratado
                    vr_cdcritic := 1034;
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_ARQUIVO: '
                                || ' nmarquiv: '||vr_lstarqre(vr_idx)
                                || ', idtipo_arquivo: '||vr_idtipo_arquivo
                                || ', idtipo_operacao: '||'R'
                                || ', idarquivo_origem: '||vr_idarquivo_origem
                                || ', idsituacao: '||0 -- Não processado
                                || ', dtcriacao: '||SYSDATE
                                || ', dtregistro: '||vr_dtrefere
                                || '. '||sqlerrm;
                    RAISE vr_exc_saida_checar_rec_2;
                END;
                -- Abrir cada arquivo encontrado
                gene0001.pc_abre_arquivo(pr_nmdireto => pr_dsdirrec
                                        ,pr_nmarquiv => vr_lstarqre(vr_idx)
                                        ,pr_tipabert => 'R'
                                        ,pr_utlfileh => vr_utl_file
                                        ,pr_des_erro => vr_dscritic);
                -- Se houve erro, parar o processo
                IF vr_dscritic IS NOT NULL THEN
                  -- Retornar com a critica
                  RAISE vr_exc_saida_checar_rec_1;
                END IF;
                -- Buscar todas as linhas do arquivo
                LOOP
                  BEGIN
                    -- Adicionar linha ao arquivo
                    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utl_file
                                                ,pr_des_text => vr_dslinha);
                    -- Arquivo de retorno na primeira linha
                    IF vr_idtiparq = 5 AND vr_qtdregist = 1 THEN
                      vr_idtipo_linha := 'C'; --> Cabeçalho
                    ELSE
                      vr_idtipo_linha := 'L'; --> Linhas normais
                    END IF;
                    -- GErar registro na tabela de conteudo do arquivo
                    BEGIN
                      INSERT INTO TBCAPT_CUSTODIA_CONTEUDO_ARQ
                                 (idarquivo
                                 ,nrseq_linha
                                 ,idtipo_linha
                                 ,dslinha
                                 ,idaplicacao
                                 ,idlancamento)
                           VALUES(vr_idarquivo
                                 ,vr_qtdregist
                                 ,vr_idtipo_linha
                                 ,vr_dslinha
                                 ,NULL   -- Será atualizado posteriormente
                                 ,NULL); -- Será atualizado posteriormente
                    EXCEPTION
                      WHEN OTHERS THEN
                        -- Erro não tratado
                        vr_cdcritic := 1034;
                        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_CONTEUDO_ARQ: '
                                    || 'idarquivo: '||vr_idarquivo
                                    || ', nrseq_linha: '||vr_qtdregist
                                    || ', idtipo_linha: C se Linha=1, senão L'
                                    || ', dslinha: '||vr_dslinha
                                    || ', idaplicacao: NULL'
                                    || ', idlancamento: NULL'
                                    || '. '||sqlerrm;
                        RAISE vr_exc_saida_checar_rec_2;
                    END;
                    -- Incrementar o contador
                    vr_qtdregist := vr_qtdregist + 1;
                  EXCEPTION
                    WHEN no_data_found THEN
                      EXIT;
                  END;
                END LOOP;
                -- AO final, fechar o arquivo
                gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utl_file);

                -- Gerar LOG
                BEGIN
                  INSERT INTO TBCAPT_CUSTODIA_LOG
                             (idarquivo
                             ,dtlog
                             ,dslog)
                       VALUES(vr_idarquivo
                             ,SYSDATE
                             ,'Arquivo '||vr_lstarqre(vr_idx)||' recebido com sucesso! Total de registros: '||(vr_qtdregist-1)); -- Diminuir um registro do Incremento do LOOP
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Erro não tratado
                    vr_cdcritic := 1034;
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_LOG: '
                                || 'idarquivo: '||vr_idarquivo
                                || ', dtlog: '||SYSDATE
                                || ', dslog: '||'Arquivo '||vr_lstarqre(vr_idx)||' recebido com sucesso! Total de registros: '||(vr_qtdregist-2)
                                || '. '||sqlerrm;
                    RAISE vr_exc_saida_checar_rec_2;
                END;
              END IF;
            END IF;
            -- Mover o arquivo da pasta recebe para recebidos
            gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||pr_dsdirrec||'/'||vr_lstarqre(vr_idx)||' '||pr_dsdirrcb
                                       ,pr_typ_saida   => vr_typ_saida
                                       ,pr_des_saida   => vr_dscritic);
            -- Se retornou erro, retornoar
            IF vr_typ_saida = 'ERR' THEN
              vr_cdcritic := 1040; -- Não foi possivel mover arquivo
              RAISE vr_exc_saida_checar_rec_1;
            END IF;
            -- Copiar arquivo recebido para a pasta de backup, de onde o financeiro terá acesso
            gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||pr_dsdirrcb||'/'||vr_lstarqre(vr_idx)||' '||pr_dsdirbkp
                                       ,pr_typ_saida   => vr_typ_saida
                                       ,pr_des_saida   => vr_dscritic);
            -- Se retornou erro, incrementar a mensagem e retornoar
            IF vr_typ_saida = 'ERR' THEN
              -- Houve erro         
              vr_cdcritic := 1487; -- Arquivo recebido, porém nao foi possivel copiar arquivo para pasta de Backup
              vr_cdcritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                      ' ' || vr_dscritic  ||
                      ' ' || vr_nmaction  ||
                      ' ' || vr_nmproint1 ||
                      ' ' || vr_dsparame;
                      
              vr_dsdaviso := vr_dsdaviso || vr_dscarque || vr_cdcritic||vr_dscarque;                            
              -- Controle log
              pc_log(pr_cdcritic => vr_cdcritic
                    ,pr_dscrilog => gene0001.fn_busca_critica(vr_cdcritic) ||
                              ' ' || vr_nmaction  ||
                              ' ' || vr_nmproint1 ||
                              ' ' || vr_dsparame
                    ); 
              vr_cdcritic := NULL; 
              vr_dscritic := NULL;
            END IF;
            -- Incrementar contador
            vr_qtdencon := vr_qtdencon + 1;
            -- Gravar
            -- Forçado Teste Belli      
            COMMIT; -- -- Anderson
          END LOOP; --> Arquivos retornados
        END IF;
        -- Enviar ao LOG resumo da execução
        IF vr_qtdencon + vr_qtdignor > 0 THEN
          pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Total de arquivos recebidos: '||(vr_qtdencon + vr_qtdignor)||', sendo: '
                      ||vr_dscarque||'Armazenados = '||vr_qtdencon
                      ||vr_dscarque||'Ignorados = '||vr_qtdignor;
          -- Se há avisos
          IF vr_dsdaviso IS NOT NULL THEN
            pr_dsdaviso := pr_dsdaviso ||vr_dscarque||'Avisos: '||vr_dsdaviso;
          END IF;
        ELSE
          pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Nenhum arquivo recebido!';
        END IF;
      END LOOP;

      -- Forçado erro - Teste Belli
      ---vr_cdcritic := 0 / 0;
	  
      -- Controle Saida  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            '. Finalizado' ||
                            ' '      || vr_nmaction ||
                            ' '      || vr_nmproint1 ||
                            ' '      || vr_dsparame 
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            ); 

    EXCEPTION

      WHEN vr_exc_saida_checar_rec_2 THEN   
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN vr_exc_saida_checar_rec_1 THEN
        vr_cdcritic := NVL(vr_cdcritic,0);
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic) ||
                           ' ' || vr_nmaction   ||
                           ' ' || vr_nmproint1 ||
                           ' ' || vr_dsparame  ||
                           ' ' || vr_dsparesp   ||
                           ' ' || vr_nomdojob;
        pr_idcritic := 1; -- Media   
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic
              ,pr_cdcricid => pr_idcritic);    
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Acionar log exceções internas
        CECRED.pc_internal_exception(pr_cdcooper => 3);
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                           ' ' || SQLERRM      ||
                           ' ' || vr_nmaction  ||
                           ' ' || vr_nmproint1 ||
                           ' ' || vr_dsparame  ||
                           ' ' || vr_dsparesp  ||
                           ' ' || vr_nomdojob; 
        pr_idcritic := 2; -- Alta                  
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic
              ,pr_cdcricid => pr_idcritic);    
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_checar_recebe_cd;

  -- Rotina checar possives retornos compactados recebidas na pasta repassada
  PROCEDURE pc_checar_zips_recebe_cd(pr_dsdircnd IN VARCHAR2      --> Diretório Connect Direct Raiz
                                    ,pr_dsdirbkp IN VARCHAR2      --> Diretório Backup dos arquivos
                                    ,pr_dsdaviso OUT VARCHAR2     --> Avisos dos eventos ocorridos no processo
                                    ,pr_idcritic OUT NUMBER       --> Criticidade da saida
                                    ,pr_cdcritic OUT NUMBER       --> Código da critica
                                    ,pr_dscritic OUT VARCHAR2) IS --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc checar zips recebe_cd
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 03/04/2019
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Verificar o retorno de arquivos compactados na pasta de recebe
    --             do Connect Direct, descompacta-los, chamar a rotina para checagem de possiveis
    --             arquivos para processamento, e gerar para Recebidos
    --
    -- Alteracoes:
    --             03/04/2019 - Projeto 411 - Fase 2 - Parte 2 - Conciliação Despesa B3 e Outros Detalhes
    --                          Ajusta mensagens de erros e trata de forma a permitir a monitoração automatica.
    --                          Procedimento de Log - tabela: tbgen prglog ocorrencia 
    --                         (Envolti - Belli - PJ411_F2_P2)
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_dspadrao         VARCHAR2(100);                             --> Padrão de busca
      vr_dslstarq         VARCHAR2(4000);                            --> Lista de arquivos encontrados
      vr_lstarqre         gene0002.typ_split;                        --> Split de arquivos encontrados
      vr_typ_saida        VARCHAR2(3);                               --> Saída do comando no OS
      vr_qtdarquiv        NUMBER := 0;                               --> Quantidade de registros
      vr_qtdignora        NUMBER := 0;                               --> Quantidade de registros
      --
      vr_nmproint1              VARCHAR2 (100) := 'pc_checar_zips_recebe_cd';
      vr_exc_saida_checar_zip_1 EXCEPTION;
      vr_exc_saida_checar_zip_2 EXCEPTION;
      -- Alertas
      vr_dsdaviso VARCHAR2(4000);
      vr_dsparesp VARCHAR2(4000);
      vr_dspares2 VARCHAR2(4000);
    BEGIN
      --
      -- Arquivos possuem o seguinte padrão:
      -- 03021_180504_ArqsBatch.zip.S3379466
      -- onde: 03021 - É a conta Cetip da Cecred
      --       180504 - AAMMDD do arquivo
      --       ArqsBatch - Texto padrão
      --       .zip - Extensão
      --       S - Fixo
      --       S3379466 - Numero referente ao sequencial de processamento

      vr_cdcritic := NULL;
      vr_dscritic := NULL;        
      vr_dsparesp := ', pr_dsdircnd:' || pr_dsdircnd ||
                     ', pr_dsdirbkp:' || pr_dsdirbkp;  
      -- Incluir Email
      pr_dsdaviso := '<br><br>' || fn_get_time_char || vr_dspro005_E;           
      -- Controle Entrada  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            '. Inicio' ||
                            ' ' || vr_nmaction  ||
                            ' ' || vr_nmproint1 ||
                            ' ' || vr_dsparame  ||
                            ' ' || vr_dsparesp
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            );      
      -- Forçado erro - Teste Belli
      ---vr_cdcritic := 0 / 0;      
            
      vr_dspadrao := '%Batch.zip.S%';
      -- Usamos rotina para listar os arquivos da pasta conforme padrão definido acima
      gene0001.pc_lista_arquivos(pr_path     => pr_dsdircnd||vr_dsdirrec --> Dir busca
                                ,pr_pesq     => vr_dspadrao   --> Chave busca(Padrão passado)
                                ,pr_listarq  => vr_dslstarq   --> Lista encontrada
                                ,pr_des_erro => vr_dscritic); --> Possível erro
      -- Se retorno erro:
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida_checar_zip_1;
      END IF;
      -- Separar a lista de arquivos encontradas com função existente
      vr_lstarqre := gene0002.fn_quebra_string(pr_string => vr_dslstarq, pr_delimit => ',');
      -- Se encontrou pelo menos um registro
      IF vr_lstarqre.count() > 0 THEN
        -- Para cada arquivo encontrado na pasta
        FOR vr_idx IN 1..vr_lstarqre.count LOOP
          
          vr_dspares2 := vr_lstarqre(vr_idx);
          
          -- Somente descompactar o ZIP caso seu código CETP (Primeiras 5 posições) seja algum código CETIP das Cooperativas do grupo Cecred
          -- ou seja um arquivo do tipo ArqsBatch, ou seja, os RelsBatch apenas é copiado para a pasta Backup
          IF NOT fn_valida_codigo_cetip(substr(vr_lstarqre(vr_idx),1,5)) THEN
            -- Incrementar quantidade de ignorados
            vr_qtdignora := vr_qtdignora + 1;
            -- Adicionar alerta
            vr_dsdaviso := vr_dsdaviso || vr_dscarque || 'Atenção, arquivo recebido não possui codigo CETIP válido nas cooperativas do grupo, arquivo: '||pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx);
          ELSIF vr_lstarqre(vr_idx) NOT LIKE '%ArqsBatch%' THEN
            -- Incrementar quantidade de ignorados
            vr_qtdignora := vr_qtdignora + 1;
            -- Adicionar alerta
            vr_dsdaviso := vr_dsdaviso || vr_dscarque || 'Atenção, arquivo RelBatchs recebido : '||pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)||', será apenas copiado para a pasta de Backups';
          ELSE
            -- Criaremos uma pasta temporária para descompactação do arquivo
            gene0001.pc_OScommand_Shell(pr_des_comando => 'mkdir '||pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)||'.tmp'
                                       ,pr_typ_saida   => vr_typ_saida
                                       ,pr_des_saida   => vr_dscritic);
            -- Se retornou erro, retornoar
            IF vr_typ_saida = 'ERR' THEN
              vr_dsdaviso := vr_dsdaviso || vr_dscarque || 'Atenção, não foi possivel criar pasta '||pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)||'.tmp para descompactação '|| ' --> '|| vr_dscritic;
              vr_dscritic := NULL;
            END IF;

            -- Descompactaremos o arquivo Zip encontrado criando uma pasta com o mesmo nome na Recebe:
            gene0002.pc_zipcecred(pr_cdcooper => 3
                                 ,pr_tpfuncao => 'E' -- Extrair
                                 ,pr_dsorigem => pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)
                                 ,pr_dsdestin => pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)||'.tmp'
                                 ,pr_dspasswd => NULL
                                 ,pr_des_erro => vr_dscritic);
            -- Se retorno erro:
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida_checar_zip_1;
            END IF;
            -- Chamaremos a rotina que checa se retornou conciliação no diretório
            -- Neste caso enviaremos o diretório recém criado e resultado da descompactação
            pc_checar_recebe_cd(pr_idtiparq => 9                                                                   --> TIpo de Busca (0-Todas,9-Conciliação,5-Retornos)
                               ,pr_dsdirrec => pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)||'.tmp'          --> Diretório dos arquivos compactados
                               ,pr_dsdirrcb => pr_dsdircnd||vr_dsdirrcb                                            --> Diretório Recebidos
                               ,pr_dsdirbkp => pr_dsdirbkp||vr_dsdirrcb                                            --> Diretório Backup dos arquivos
                               ,pr_dsdaviso => pr_dsdaviso                                                         --> Avisos dos eventos ocorridos no processo
                               ,pr_idcritic => pr_idcritic                                                         --> Criticidade da saida
                               ,pr_cdcritic => vr_cdcritic                                                         --> Código da critica
                               ,pr_dscritic => vr_dscritic);                                                       --> Retorno de crítica
            -- Em caso de critica
            IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida_checar_zip_1;
            END IF;
            -- Remover a pasta temporária criada (descompactação)
            gene0001.pc_OScommand_Shell(pr_des_comando => 'rm -r '||pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)||'.tmp'
                                       ,pr_typ_saida   => vr_typ_saida
                                       ,pr_des_saida   => vr_dscritic);
            -- Se retornou erro, retornoar
            IF vr_typ_saida = 'ERR' THEN
              vr_dsdaviso := vr_dsdaviso || vr_dscarque || 'Atenção, não foi possivel remover pasta descompactada '||pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)||'.tmp'|| ' --> '|| vr_dscritic;
              vr_dscritic := NULL;
            END IF;
            -- Incrementar o contador
            vr_qtdarquiv := vr_qtdarquiv + 1;
          END IF;

          -- Mover o arquivo Zip da pasta recebe para recebidos
          gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||pr_dsdircnd||vr_dsdirrec||
                                                        '/'||vr_lstarqre(vr_idx)||' '||pr_dsdircnd||vr_dsdirrcb
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => vr_dscritic);
          -- Se retornou erro, retornoar
          IF vr_typ_saida = 'ERR' THEN
            vr_dspares2 := ', pr_dsdircnd:' || pr_dsdircnd ||
                           ', vr_dsdirrec:' || vr_dsdirrec ||
                           ', vr_lstarqre:' || vr_lstarqre(vr_idx) ||
                           ', vr_dsdirrcb:' || vr_dsdirrcb ||
                           ', vr_idx:' || vr_idx;
            
            RAISE vr_exc_saida_checar_zip_1;
          END IF;
          -- Copiar arquivo recebido para a pasta de backup, de onde o financeiro terá acesso
          gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||pr_dsdircnd||vr_dsdirrcb||'/'||vr_lstarqre(vr_idx)||' '||pr_dsdirbkp||vr_dsdirrcb
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => vr_dscritic);
          -- Se retornou erro, incrementar a mensagem e retornoar
          IF vr_typ_saida = 'ERR' THEN
            -- Houve erro
            vr_dsdaviso := vr_dsdaviso || vr_dscarque || 
                           'Arquivo recebido, porém nao foi possivel copiar arquivo '||vr_lstarqre(vr_idx)||
                           ' para pasta de Backup, motivo:  '|| vr_dscritic||vr_dscarque;
            vr_dscritic := NULL;
          END IF;

          -- Gravar
          -- Forçado Teste Belli      
          COMMIT; -- -- Anderson
        END LOOP; --> Arquivos retornados
      END IF;

      -- Enviar ao LOG resumo da execução
      IF vr_qtdarquiv + vr_qtdignora > 0 THEN
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Total de arquivos compactados recebidos: '||(vr_qtdarquiv+vr_qtdignora)||', onde: '
                      ||vr_dscarque||'Descompactados e processados = '||vr_qtdarquiv
                      ||vr_dscarque||'Ignorados(CETIP desconhecido ou RelBatchs) = '||vr_qtdignora
                      ||vr_dscarque||'Todos os arquivos encontram-se na pasta de backup';
        -- Se há avisos
        IF vr_dsdaviso IS NOT NULL THEN
          pr_dsdaviso := pr_dsdaviso ||vr_dscarque||'Avisos: '||vr_dsdaviso;
        END IF;
      ELSE
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Nenhum arquivo recebido!';
      END IF;
      
      -- Forçado erro - Teste Belli
      ---vr_cdcritic := 0 / 0;
      
      -- Controle Saida  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            '. Finalizado' ||
                            ' '      || vr_nmaction ||
                            ' '      || vr_nmproint1 ||
                            ' '      || vr_dsparame   ||
                            ' ' || vr_dsparesp
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            ); 

    EXCEPTION
      WHEN vr_exc_saida_checar_zip_2 THEN   
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN vr_exc_saida_checar_zip_1 THEN
        vr_cdcritic := NVL(vr_cdcritic,0);
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic) ||
                           ' ' || vr_nmaction   ||
                           ' ' || vr_nmproint1 ||
                           ' ' || vr_dsparame  ||
                           ' ' || vr_nomdojob  ||
                           ' ' || vr_dsparesp  ||
                           ' ' || vr_dspares2;
        pr_idcritic := 1; -- Media   
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic
              ,pr_cdcricid => pr_idcritic);    
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Acionar log exceções internas
        CECRED.pc_internal_exception(pr_cdcooper => 3);
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                           ' ' || SQLERRM      ||
                           ' ' || vr_nmaction  ||
                           ' ' || vr_nmproint1 ||
                           ' ' || vr_dsparame  ||
                           ' ' || vr_dsparesp  ||
                           ' ' || vr_dspares2  ||
                           ' ' || vr_nomdojob; 
        pr_idcritic := 2; -- Alta                  
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic
              ,pr_cdcricid => pr_idcritic);    
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
    END;
  END pc_checar_zips_recebe_cd;

  -- Monitoração para alertar atraso de arquivo  
  PROCEDURE pc_monitora_retorno_arquivos(pr_dsdemail  IN VARCHAR2     --> Destinatários
                                        ,pr_dsjanexe  IN VARCHAR2     --> Descrição horário execução
                                        ,pr_dsdaviso OUT VARCHAR2     --> Avisos dos eventos ocorridos no processo
                                        ,pr_idcritic OUT NUMBER       --> Criticidade da saida
                                        ,pr_cdcritic OUT NUMBER       --> Código da critica
                                        ,pr_dscritic OUT VARCHAR2     --> Retorno de crítica
                                        )
  IS  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc gera arquivos envio
    --  Sistema  : Monitora retorno de arquivos da B3
    --  Sigla    : CRED
    --  Autor    : Belli - Envolti               Projeto: Nr. 411, fase 2 e parte 2.
    --  Data     : Março/2019.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa
    --
    -- Frequencia: Conforme chamada programada do JOB XXXXX 
    --             Atualmente executa todo o dia, a cada hora entre ás 08:00 e as 21:00
    --
    -- Objetivo  : Monitorar retorno de arquivos da B3, e se estiver fora do prazo estabelecido emitir alerta
    --
    -- Alteracoes:
    --
    vr_dtsysdat DATE;
    vr_hrtolret DATE;
    --           
    vr_idarquiv tbcapt_custodia_arquivo.idarquivo%TYPE;
    vr_qtrownum NUMBER      (2) := 0;  
    vr_dslisarq VARCHAR2 (4000) := NULL;
    vr_dsdetalh VARCHAR2 (4000) := NULL;
    vr_hrtolera VARCHAR2    (5) := NULL;
    -- Variaveis de controle de erro e modulo
    vr_dsparint1 VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
    vr_dsparint2 VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
    vr_nmproint1 VARCHAR2  (100) := 'pc_monitora_retorno_arquivos'; -- Rotina e programa
    
  -- Seleção de arquivos enviados e sem retorno
  CURSOR 
    cr_arqsemret
  IS
    SELECT t1.*
    FROM (
      SELECT 
         e.*
        ,TRUNC( SYSDATE - (e.dtprocesso ) )                                              qtdiaatr
        ,TRUNC( SYSDATE - e.dtprocesso) * 24 + 
           TRUNC((( SYSDATE - e.dtprocesso) - TRUNC(( SYSDATE - e.dtprocesso)))*24)       qthoratr
        ,TRUNC((((( SYSDATE - e.dtprocesso) - TRUNC(( SYSDATE - e.dtprocesso)))*24) - 
           TRUNC((( SYSDATE - e.dtprocesso) - TRUNC(( SYSDATE - e.dtprocesso)))*24))*60)  qtminatr               
      FROM   tbcapt_custodia_arquivo e
      WHERE  e.idtipo_operacao = 'E'         
      AND    e.idsituacao      <> 0                         -- Processamento
      AND    e.idtipo_arquivo  <> 9                         -- Ignorar arquivos de conciliação
      AND    e.dtprocesso      IS NOT NULL                  -- Com data de processo
      AND    NOT EXISTS 
            ( SELECT  1 FROM tbcapt_custodia_arquivo r 
              WHERE   r.idarquivo_origem = e.idarquivo )
    ) t1
    WHERE  
            ( t1.qtdiaatr > 0 OR
              t1.qthoratr > NVL(TO_CHAR(vr_hrtolret,'HH24'),2) OR 
              (  t1.qthoratr = NVL(TO_CHAR(vr_hrtolret,'HH24'),2) AND 
                 t1.qtminatr > NVL(TO_CHAR(vr_hrtolret,'MI'),30)  )
            )
    -- Forçado - Teste Belli
    ---AND    t1.idarquivo  < 11
    AND    t1.dtprocesso > ADD_MONTHS(vr_dtsysdat,-10)        
    ORDER BY  t1.dtprocesso;
    
    rw_arqsemret cr_arqsemret%ROWTYPE;
    
  BEGIN                       ---   ROTINA PRINCIPAL INICIO
    
    vr_cdcritic  := NULL;
    vr_dscritic  := NULL;  
    vr_dsparint1 := ', pr_dsdemail:' || pr_dsdemail ||
                    ', pr_dsjanexe:' || pr_dsjanexe;
    -- Incluir Email
    pr_dsdaviso := '<br><br>' || fn_get_time_char || vr_dspro004;                                        
    
    vr_cdacesso  := 'HOR_TOL_CTD_B3';
    -- Busca tolerancia de tempo do retorno de arquivo do fornecedor B3
    vr_hrtolera  := gene0001.fn_param_sistema('CRED',0,vr_cdacesso);
    vr_dsparint1 := vr_dsparint1 ||
                    ', vr_cdacesso:' || vr_cdacesso || 
                    ', vr_hrtolera:' || vr_hrtolera;     
    IF vr_hrtolera IS NULL THEN 
      vr_cdcritic := 1230; -- Registro de parametro não encontrado
      -- Controle Entrada  
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => gene0001.fn_busca_critica(vr_cdcritic) ||
                          ' ' || vr_nmaction  ||
                          ' ' || vr_nmproint1 ||
                          ' ' || vr_dsparame
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            ); 
      vr_cdcritic := NULL;
      vr_hrtolera := '02:30';
    END IF;
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL); 
    -- Retorno nome do módulo logado
    vr_hrtolret  := to_date(to_char(sysdate,'ddmmrrrr')||vr_hrtolera,'ddmmrrrrhh24:mi');      
    vr_dtsysdat  := SYSDATE;
    vr_dsparint1 := vr_dsparint1 || 
                    ', vr_dtsysdat:' || TO_CHAR(vr_dtsysdat,'DD/MM/YYYY HH24:MI:SS') ||
                    ', vr_hrtolret:' || TO_CHAR(vr_hrtolret,'DD/MM/YYYY HH24:MI:SS');
    
    -- selecionar todas cooperativas ativas
    FOR rw_arqsemret IN cr_arqsemret  LOOP
        
      -- verifica a quantidade de cooperativas a processar
      vr_qtrownum := vr_qtrownum + 1; 
      vr_idarquiv := rw_arqsemret.idarquivo;
      --
      vr_dsparint2 := ', vr_idarquivo:' || vr_idarquiv ||
                      ', nmarquivo:'    || rw_arqsemret.nmarquivo ||
                      ', dtcriacao:'    || TO_CHAR(rw_arqsemret.dtcriacao,'DD/MM/YYYY HH24:MI:SS') ||
                      ', dtprocesso:'   || TO_CHAR(rw_arqsemret.dtprocesso,'DD/MM/YYYY HH24:MI:SS') ||
                      ', dtregistro:'   || TO_CHAR(rw_arqsemret.dtregistro,'DD/MM/YYYY HH24:MI:SS') ||
                      ', qtdiaatr:'     || rw_arqsemret.qtdiaatr ||
                      ', qthoratr:'     || rw_arqsemret.qthoratr ||
                      ', qtminatr:'     || rw_arqsemret.qtminatr ||
                      ', vr_qtrownum:'  || vr_qtrownum;

      -- Pode haver muitos arquivos e estourar o e-mail 
      -- então vai para o anexo
      /*              
      vr_dsdetalh := '<br>' || 
                     'Identificador e nome arquivo: ' || vr_idarquiv  ||
                     ' - '           || rw_arqsemret.nmarquivo ||
                     ', data de processo:' || TO_CHAR(rw_arqsemret.dtcriacao, 'DD/MM/YYYY HH24:MI:SS') ||
                     ', data de processo:' || TO_CHAR(rw_arqsemret.dtprocesso,'DD/MM/YYYY HH24:MI:SS') ||
                     ', data de registro:' || TO_CHAR(rw_arqsemret.dtregistro,'DD/MM/YYYY HH24:MI:SS') ||
                     ', atraso de '  || rw_arqsemret.qtdiaatr  ||
                     ' dias, '       || rw_arqsemret.qthoratr  ||
                     ', horas e '    || rw_arqsemret.qtminatr  || 
                     ' minutos.'     ||
                     '</br>';           
        
      IF vr_dslisarq IS NULL THEN
        vr_dslisarq := vr_dsdetalh;
      ELSE
        vr_dslisarq := vr_dslisarq || vr_dsdetalh;
      END IF;
      */
                
      -- Forçado - Teste Belli
      ---IF vr_qtrownum > 4 THEN
      ---  EXIT;
      ---END IF;

      -- Efetuar retorno do erro não tratado
      vr_cdcritic := 1491; -- Processo de retorno de arquivo da B3 em atraso
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                       ' ' || vr_nmaction  ||
                       ' ' || vr_nmproint1 || 
                       ' ' || vr_dsparame  ||
                       ' ' || vr_dsparint1 ||
                       ' ' || vr_dsparint2;
      pr_idcritic := 1; -- Media                  
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic
            ,pr_cdcricid => 1 -- Media
            );
      vr_cdcritic := NULL;
      vr_dscritic := NULL;
                
    END LOOP;
    
    -- Belli - Fica no anexo senão vai estourar o e-mail.
    /*
    -- Emite Alerta
    IF vr_qtrownum > 0 THEN
      pr_dsdaviso := pr_dsdaviso    ||
                     '<br><br><br>' || 
                     '<br>' || gene0001.fn_busca_critica(pr_cdcritic => 1491)      ||
                     '<br>' || 'Quantidade de arquivos em atraso:'  || vr_qtrownum || 
                     ---  '<br>' || vr_dslisarq || 
                     '<br><br>'; 
    END IF;
    */
    
    -- Forçado erro - Teste Belli
    --- vr_cdcritic := 0 / 0;
    
  EXCEPTION
    WHEN OTHERS THEN
      -- Quando erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => 3);      
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                     ' ' || SQLERRM ||
                     ' ' || vr_nmaction  ||
                     ' ' || vr_nmproint1 || 
                     ' ' || vr_dsparame  ||
                     ' ' || vr_dsparint1 ||
                     ' ' || vr_dsparint2; 
      pr_idcritic := 2; -- Alta                  
      -- Log de erro de execucao
      pc_log(pr_cdcritic => pr_cdcritic
            ,pr_dscrilog => pr_dscritic
            ,pr_cdcricid => pr_idcritic);      
      --
  END pc_monitora_retorno_arquivos;

  -- Rotina para processar retorno de arquivos pendentes de processamento
  PROCEDURE pc_processa_retorno_arquivos(pr_dsdemail  IN VARCHAR2     --> Destinatários
                                        ,pr_dsjanexe  IN VARCHAR2     --> Descrição horário execução
                                        ,pr_dsdaviso OUT VARCHAR2     --> Avisos dos eventos ocorridos no processo
                                        ,pr_idcritic OUT NUMBER       --> Criticidade da saida
                                        ,pr_cdcritic OUT NUMBER       --> Código da critica
                                        ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de crítica
   BEGIN 
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc processa retorno arquivos  BEGIN

    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 03/04/2019
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Processar e integrar arquivos de Retorno pendentes de processamento
    -- Alteracoes:
    --             03/04/2019 - Projeto 411 - Fase 2 - Parte 2 - Conciliação Despesa B3 e Outros Detalhes
    --                          Ajusta mensagens de erros e trata de forma a permitir a monitoração automatica.
    --                          Procedimento de Log - tabela: tbgen prglog ocorrencia 
    --                         (Envolti - Belli - PJ411_F2_P2)
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Variaveis auxiliares
      vr_qtlimerr  NUMBER     (12);
      vr_nmproint1 VARCHAR2  (100) := 'pc_processa_retorno_arquivos';
      vr_dspartot  VARCHAR2 (4000);      
      vr_dsparlp1  VARCHAR2 (4000);
      vr_dsparlp2  VARCHAR2 (4000);
      vr_dsparesp  VARCHAR2 (4000);
      vr_dssqlerrm VARCHAR2 (4000);
      vr_exc_saida_ret_arq_1     EXCEPTION;
      vr_exc_saida_ret_arq_2     EXCEPTION;
      vr_exc_sai_ret_arq_lop_1   EXCEPTION;
      vr_exc_sai_ret_arq_lop_1_B EXCEPTION;
      vr_exc_sai_ret_arq_lop_2   EXCEPTION;
      
      vr_txretorn    gene0002.typ_split; --> Separação da linha em vetor
      vr_nrobusca    NUMBER;             --> Variavel para soma no idx da coluna pois o Registro possui um campo adicional
      vr_qtdsuces    NUMBER;             --> Quantidade de Sucessos
      vr_qtderros    NUMBER;             --> Quantidade de Erros
      vr_flerrger    BOOLEAN;            --> Flag de erro geral
      vr_dscodigB3   tbcapt_custodia_aplicacao.dscodigo_b3%TYPE; --> Codigo da aplicação na B3
      vr_cdopercetip tbcapt_custodia_lanctos.cdoperac_cetip%TYPE; -- Codigo da operação Cetip
      -- Quantidade de arquivos processados
      vr_qtdaruiv NUMBER := 0;

      -- Busca dos arquivps pendentes e seu conteudo
      CURSOR cr_arquivos IS
        SELECT arq.idarquivo
              ,arq.nmarquivo
              ,arq.idtipo_arquivo
              ,arq.idarquivo_origem
          FROM tbcapt_custodia_arquivo arq
         WHERE arq.idtipo_operacao = 'R'
           AND arq.idsituacao = 0 -- Pendente Processamento
           AND arq.idtipo_arquivo <> 9 -- Ignorar arquivos de conciliação
         ORDER BY arq.idarquivo
         FOR UPDATE;
      rw_arq cr_arquivos%ROWTYPE;

      -- Busca do conteudo do arquivo
      CURSOR cr_conteudo(pr_idarquivo tbcapt_custodia_arquivo.idarquivo%TYPE) IS
        SELECT cnt.nrseq_linha
              ,cnt.dslinha
          FROM tbcapt_custodia_conteudo_arq cnt
         WHERE cnt.idarquivo = pr_idarquivo
           AND cnt.idtipo_linha IN('L','D') --> Somente as linhas de informações ou detalhes
         ORDER BY cnt.nrseq_linha;

      -- Busca do registro no arquivo de origem
      CURSOR cr_cont_orig(pr_idarquivo tbcapt_custodia_arquivo.idarquivo%TYPE
                         ,pr_nrseq_linha tbcapt_custodia_conteudo_arq.nrseq_linha%TYPE) IS
        SELECT cnt.dslinha
              ,cnt.idaplicacao
              ,cnt.idlancamento
          FROM tbcapt_custodia_conteudo_arq cnt
         WHERE cnt.idarquivo   = pr_idarquivo
           AND cnt.nrseq_linha = pr_nrseq_linha;
      rw_cont_orig cr_cont_orig%ROWTYPE;

    PROCEDURE pc_critica_loop
      IS 
    BEGIN 
            -- Efetuar retorno do erro nao tratado
            vr_cdcritic := NVL(vr_cdcritic,0);
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                                    ,pr_dscritic => vr_dscritic) ||
                           ' ' || vr_dssqlerrm ||
                           ' ' || vr_nomdojob  ||
                           ' ' || vr_nmaction  ||
                           ' ' || vr_nmproint1 ||
                           ' ' || vr_dsparame  ||
                           ' ' || vr_dsparlp1  ||
                           ' ' || vr_dsparlp2  ||
                           ' ' || vr_dsparesp;                      
            -- Log de erro de execucao
            pc_log(pr_cdcritic => vr_cdcritic
                  ,pr_dscrilog => vr_dscritic
                  ,pr_cdcricid => pr_idcritic); 
    END pc_critica_loop;
    
    BEGIN
      
      vr_cdcritic := NULL;
      vr_dscritic := NULL;        
      vr_dspartot := ' ' || vr_nmaction  ||
                     ' ' || vr_nmproint1 ||
                     ' ' || vr_nomdojob  ||
                     ' ' || vr_dsparame  ||
                     ', pr_dsdemail: ' || pr_dsdemail  ||
                     ', pr_dsjanexe: ' || pr_dsjanexe;                           
      -- Incluir Email
      pr_dsdaviso := '<br><br>' || fn_get_time_char || vr_dspro003_E; 
      -- Limite de erros no processo de retorno de arquivo do fornecedor => B3
      vr_qtlimerr := gene0001.fn_param_sistema('CRED',0,'LIMERRO_PROC_RET_ARQ_B3');
      vr_qtlimerr := NVL(vr_qtlimerr,0);                 
      -- Controle Entrada  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            ' ' || vr_nmaction  ||
                            ' ' || vr_nmproint1 ||
                            ' ' || vr_dsparame  ||
                            ', vr_qtlimerr:' || vr_qtlimerr
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            );
      -- Forçado erro - Teste Belli
    ---  vr_cdcritic := 0 / 0;                   
            
      -- Buscamos todos os arquivos pendentes de envio
      LOOP
      BEGIN
        
        OPEN cr_arquivos;
        FETCH cr_arquivos
         INTO rw_arq;
        -- Sair ao não encontrar
        IF cr_arquivos%NOTFOUND THEN
          CLOSE cr_arquivos;
          EXIT;
        ELSE
          CLOSE cr_arquivos;
        END IF;
        -- Incrementar contador
        vr_qtdaruiv := vr_qtdaruiv + 1;
        
        vr_dsparlp1 := ', vr_qtdaruiv'      || vr_qtdaruiv ||
                       ', idarquivo:'       || rw_arq.idarquivo ||
                       ', idtipo_arquivo:'  || rw_arq.idtipo_arquivo ||
                       ', idarquivo_origem' || rw_arq.idarquivo_origem ||
                       ', idarquivo' || rw_arq.idarquivo ||
                       ', idarquivo' || rw_arq.idarquivo ||
                       ', idarquivo' || rw_arq.idarquivo;
        -- Resetar contadores internos
        vr_qtdsuces := 0;
        vr_qtderros := 0;
        vr_cdcritic := NULL;
        vr_dscritic := NULL;
        rw_cont_orig := NULL;
        vr_flerrger := FALSE;
        -- Arquivo de Registro posusi a coluna Código IF, portanto
        -- buscaremos o texto e linha original somando +1 no idx de busca
        IF rw_arq.idtipo_arquivo = 1 THEN
          vr_nrobusca := 1;
        ELSE
          vr_nrobusca := 0;
        END IF;
        
        -- Processar todas as linhas do arquivo
        FOR rw_cnt IN cr_conteudo(rw_arq.idarquivo) LOOP
        BEGIN
          -- Cada linha será separada em vetor para facilitar o processamento
          vr_txretorn := gene0002.fn_quebra_string(rw_cnt.dslinha, ';');
          
          vr_dsparlp2 := ', vr_txretorn.count:' || vr_txretorn.count() ||
                         ', nrseq_linha:'       || rw_cnt.nrseq_linha  ||
                         ', idarquivo:'         || rw_arq.idarquivo ||
                         ', vr_txretorn:'       || vr_txretorn(3+vr_nrobusca) ||
                         ', vr_nrobusca:'       || vr_nrobusca;
          
          -- Verifica se a quebra resultou em um array válido
          -- e com pelo menos 4 posições para RGT e 5 posições para REG
          IF vr_txretorn.count() = 0
          OR (rw_arq.idtipo_arquivo = 2 AND vr_txretorn.count() <> 4)
          OR (rw_arq.idtipo_arquivo = 1 AND vr_txretorn.count() <> 5) THEN
            -- Invalidar a linha pois o Layout da mesma não confere
            BEGIN
              
      -- Forçado erro - Teste Belli
      ---IF (vr_qtdsuces+vr_qtderros) > 0 THEN
      ---  vr_cdcritic := 0 / 0; 
      ---END IF;
      
              UPDATE tbcapt_custodia_conteudo_arq cnt
                 SET cnt.dscritica = 'Retorno não confere com o Layout definido! O mesmo não será processado!'
               WHERE cnt.idarquivo   = rw_arq.idarquivo
                 AND cnt.nrseq_linha = rw_cnt.nrseq_linha;
            EXCEPTION
              WHEN OTHERS THEN
                -- Acionar log exceções internas
                CECRED.pc_internal_exception(pr_cdcooper => 3);
                -- Erro não tratado
                vr_cdcritic  := 1035;
                vr_dssqlerrm := SQLERRM;
                pr_idcritic  := 2; -- Alto    
                vr_dsparesp  := ', tabela: tbcapt_custodia_conteudo_arq' ||
                                ', dscritica: Retorno não confere com o Layout definido!'||
                                              ' O mesmo não será processado!';
                RAISE vr_exc_sai_ret_arq_lop_2;
            END;
            -- Incrementar erro
            vr_qtderros := vr_qtderros + 1;
          ELSE
            -- Testar se o retorno não é um erro geral do arquivo, ou seja, todas as linhas serão invalidadas
            IF vr_txretorn(1) IS NULL AND vr_txretorn(3+vr_nrobusca) IS NOT NULL THEN
              -- Invalidaremos todas as linhas com esta critica
              BEGIN
                UPDATE tbcapt_custodia_conteudo_arq cnt
                   SET cnt.dscritica = vr_txretorn(3+vr_nrobusca)
                 WHERE cnt.idarquivo   IN(rw_arq.idarquivo,rw_arq.idarquivo_origem)
                   AND cnt.idtipo_linha IN('L','D'); --> Somente as linhas de informações
                -- Quantidade de erros é 1 pois é um erro único e geral
                vr_qtderros := 1;
                vr_flerrger := TRUE;
              EXCEPTION
                WHEN OTHERS THEN
                -- Acionar log exceções internas
                CECRED.pc_internal_exception(pr_cdcooper => 3);
                  -- Erro não tratado
                  vr_cdcritic := 1035;
                vr_dssqlerrm := SQLERRM;
                pr_idcritic  := 2; -- Alto    
                vr_dsparesp  := ', tabela: tbcapt_custodia_conteudo_arq' ||
                                'dscritica: '||vr_txretorn(3+vr_nrobusca)
                              || ' com idarquivo in('||rw_arq.idarquivo||','||rw_arq.idarquivo_origem||')'
                              || ' , idtipo_linha: L';
                  RAISE vr_exc_sai_ret_arq_lop_2;
              END;
              -- Atualizaremos todos os lançamentos vinculados ao envio com o erro retornado
              BEGIN
                UPDATE tbcapt_custodia_lanctos lct
                   SET lct.idsituacao = 9 -- Critica
                      ,lct.dtretorno = SYSDATE
                 WHERE lct.idlancamento IN(SELECT cnt.idlancamento
                                             FROM tbcapt_custodia_conteudo_arq cnt
                                            WHERE cnt.idarquivo = rw_arq.idarquivo_origem);
              EXCEPTION
                WHEN OTHERS THEN
                -- Acionar log exceções internas
                CECRED.pc_internal_exception(pr_cdcooper => 3);
                  -- Erro não tratado
                  vr_cdcritic  := 1035;            
                  vr_dssqlerrm := SQLERRM;
                  pr_idcritic  := 2; -- Alto    
                  vr_dsparesp  := ', tabela: tbcapt_custodia_lanctos' ||
                                  ', idsituacao: 9' ||
                                  ' com idlancamento in: '||
                                  'SELECT cnt.idlancamento FROM tbcapt_custodia_conteudo_arq cnt '||
                                  ' WHERE cnt.idarquivo = '||rw_arq.idarquivo_origem;
                  RAISE vr_exc_sai_ret_arq_lop_2;
                END;
            ELSE
              -- Remover quebras de linha
              vr_txretorn(4+vr_nrobusca) := fn_remove_quebra(vr_txretorn(4+vr_nrobusca));
              -- Buscaremos o mesmo registro no arquivo de envio
              OPEN cr_cont_orig(rw_arq.idarquivo_origem,vr_txretorn(1));
              FETCH cr_cont_orig
               INTO rw_cont_orig;
              -- Se não encontrou
              -- OU encontrou mas o conteudo da linha é diferente do recebido
              -- OU encontrou, o conteudo é igual, mas recebemos critica
              IF cr_cont_orig%NOTFOUND
              OR rw_cont_orig.dslinha <> vr_txretorn(4+vr_nrobusca)
              OR UPPER(vr_txretorn(3+vr_nrobusca)) <> 'EXECUCAO OK' THEN
                -- Montar critica conforme a opção que entrou
                IF cr_cont_orig%NOTFOUND THEN
                  vr_cdcritic := 1481; -- Linha Original retornada não encontrada no arquivo de envio
                ELSIF rw_cont_orig.dslinha <> vr_txretorn(4+vr_nrobusca) THEN
                  vr_cdcritic := 1482; -- Conteudo da Linha Original retornado não confere com a linha Original enviada
                ELSE
                  vr_dscritic := vr_txretorn(3+vr_nrobusca);
                  vr_cdcritic := 9999;
                END IF;
                CLOSE cr_cont_orig;
                -- Houve erro         
                vr_cdcritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                      ' ' || vr_dscritic  ||
                      ' ' || vr_nmaction  ||
                      ' ' || vr_nmproint1 ||
                      ' ' || vr_dsparame;
                                              
                -- Controle log
                pc_log(pr_cdcritic => vr_cdcritic
                      ,pr_dscrilog => gene0001.fn_busca_critica(vr_cdcritic) ||
                                ' ' || vr_nmaction  ||
                                ' ' || vr_nmproint1 ||
                                ' ' || vr_dsparame
                      );                                
                -- Geraremos erro
                BEGIN
                  UPDATE tbcapt_custodia_conteudo_arq cnt
                     SET cnt.dscritica = vr_dscritic
                   WHERE cnt.idarquivo   in(rw_arq.idarquivo,rw_arq.idarquivo_origem)
                     AND cnt.nrseq_linha = rw_cnt.nrseq_linha;
                  -- Quantidade de erros incrementada
                  vr_qtderros := vr_qtderros + 1;
                EXCEPTION
                  WHEN OTHERS THEN
                  -- Acionar log exceções internas
                  CECRED.pc_internal_exception(pr_cdcooper => 3);
                  -- Erro não tratado
                  vr_cdcritic  := 1035; 
                  vr_dssqlerrm := SQLERRM;
                  pr_idcritic  := 2; -- Alto    
                  vr_dsparesp  := ', tabela: tbcapt_custodia_conteudo_arq' ||
                                  ', dscritica: '||vr_dscritic ||
                                  ', com idarquivo: in('||rw_arq.idarquivo||
                                  ','||rw_arq.idarquivo_origem||')' ||
                                  ', nrseq_linha: '||rw_cnt.nrseq_linha;
                    RAISE vr_exc_sai_ret_arq_lop_2;
                END;
                -- Atualizaremos o lançamento correspondente vinculado ao envio
                BEGIN
                  UPDATE tbcapt_custodia_lanctos lct
                     SET lct.idsituacao = 9 -- Critica
                        ,lct.dtretorno = SYSDATE
                   WHERE lct.idlancamento IN(SELECT cnt.idlancamento
                                               FROM tbcapt_custodia_conteudo_arq cnt
                                              WHERE cnt.idarquivo = rw_arq.idarquivo_origem
                                                AND cnt.nrseq_linha = rw_cnt.nrseq_linha);
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Acionar log exceções internas
                    CECRED.pc_internal_exception(pr_cdcooper => 3);
                    -- Erro não tratado
                    vr_cdcritic := 1035;
                  vr_dssqlerrm := SQLERRM;
                  pr_idcritic  := 2; -- Alto    
                  vr_dsparesp  := ', tabela: tbcapt_custodia_lanctos' ||
                                  ', idsituacao: 9'
                                || ' com idlancamento in: SELECT cnt.idlancamento ' ||
                                   'FROM tbcapt_custodia_conteudo_arq cnt '||
                                   'WHERE cnt.idarquivo = '||rw_arq.idarquivo_origem||
                                   ' AND cnt.nrseq_linha = '||rw_cnt.nrseq_linha;
                    RAISE vr_exc_sai_ret_arq_lop_2;
                  END;
              ELSE
                CLOSE cr_cont_orig;
                -- Execução OK, guardar codigo B3 para registros e codigo operação cetip para todos
                IF rw_arq.idtipo_arquivo = 1 THEN
                  vr_dscodigB3 := vr_txretorn(2);
                  vr_cdopercetip := vr_txretorn(3);
                  -- Atualizar registro de Custodia Aplicação
                  -- caso ainda não tenhamos o feito
                  BEGIN
                    UPDATE tbcapt_custodia_aplicacao apl
                       SET apl.dscodigo_b3 = vr_dscodigB3
                          ,apl.dtregistro = SYSDATE
                     WHERE apl.idaplicacao = rw_cont_orig.idaplicacao
                       AND apl.dscodigo_b3 IS NULL;
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- Acionar log exceções internas
                      CECRED.pc_internal_exception(pr_cdcooper => 3);
                      -- Erro não tratado
                      vr_cdcritic := 1035;
                      vr_dssqlerrm := SQLERRM;
                      pr_idcritic  := 2; -- Alto    
                      vr_dsparesp  := ', tabela: tbcapt_custodia_aplicacao' ||
                                      'dscodigo_b3: '||vr_dscodigB3
                                  || ' ,dtregistro = '||SYSDATE
                                  || ' com idaplicacao : '||rw_cont_orig.idaplicacao
                                  || ' , dscodigo_b3 : null ';
                      RAISE vr_exc_sai_ret_arq_lop_2;
                  END;
                ELSE
                  vr_dscodigB3 := NULL;
                  vr_cdopercetip := vr_txretorn(2);
                END IF;
            
                -- Atualizaremos o registro de envio e de retorno
                BEGIN
              
      -- Forçado erro - Teste Belli
      ---IF (vr_qtdsuces+vr_qtderros) > 1 THEN
      ---  vr_cdcritic := 0 / 0; 
      ---END IF;
      
                  UPDATE tbcapt_custodia_conteudo_arq cnt
                     SET cnt.idaplicacao  = rw_cont_orig.idaplicacao
                        ,cnt.idlancamento = rw_cont_orig.idlancamento
                        ,cnt.dscodigo_b3  = nvl(vr_dscodigB3,cnt.dscodigo_b3)
                        ,cnt.cdoperac_cetip = vr_cdopercetip
                        ,cnt.dscritica    = NULL
                   WHERE cnt.idarquivo   IN(rw_arq.idarquivo,rw_arq.idarquivo_origem)
                     AND cnt.nrseq_linha = rw_cnt.nrseq_linha;
                  -- Quantidade de erros incrementada
                  vr_qtdsuces := vr_qtdsuces + 1;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Acionar log exceções internas
                    CECRED.pc_internal_exception(pr_cdcooper => 3);
                    -- Erro não tratado
                    vr_cdcritic := 1035;
                      vr_dssqlerrm := SQLERRM;
                      pr_idcritic  := 2; -- Alto    
                      vr_dsparesp  := ', tabela: tbcapt_custodia_conteudo_arq' ||
                                      ', idaplicacao: '||rw_cont_orig.idaplicacao
                                || ', idlancamento: '||rw_cont_orig.idlancamento
                                || ', dscodigo_b3: '||vr_dscodigB3
                                || ' com idarquivo in('||rw_arq.idarquivo||','||rw_arq.idarquivo_origem||')'
                                || ' , nrseq_linha: '||rw_cnt.nrseq_linha;
                    RAISE vr_exc_sai_ret_arq_lop_2;
                END;
                -- Atualizaremos o lançamento correspondente vinculado ao envio
                BEGIN
                  UPDATE tbcapt_custodia_lanctos lct
                     SET lct.idsituacao     = 8 -- Custodiado com sucesso
                        ,lct.dtretorno      = SYSDATE
                        ,lct.cdoperac_cetip = vr_cdopercetip
                   WHERE lct.idlancamento IN(SELECT cnt.idlancamento
                                               FROM tbcapt_custodia_conteudo_arq cnt
                                              WHERE cnt.idarquivo = rw_arq.idarquivo_origem
                                                AND cnt.nrseq_linha = rw_cnt.nrseq_linha);
                EXCEPTION
                  WHEN OTHERS THEN
                -- Acionar log exceções internas
                CECRED.pc_internal_exception(pr_cdcooper => 3);
                    -- Erro não tratado
                    vr_cdcritic := 1035;
                      vr_dssqlerrm := SQLERRM;
                      pr_idcritic  := 2; -- Alto    
                      vr_dsparesp  := ', tabela: tbcapt_custodia_lanctos' ||
                                      ', idsituacao: 8'
                                || ' com idlancamento in: SELECT cnt.idlancamento ' ||
                                   'FROM tbcapt_custodia_conteudo_arq cnt ' ||
                                   'WHERE cnt.idarquivo = '||rw_arq.idarquivo_origem||
                                   ' AND cnt.nrseq_linha = '||rw_cnt.nrseq_linha;
                    RAISE vr_exc_sai_ret_arq_lop_2;
                  END;
              END IF;
            END IF;
          END IF;
          
      -- Forçado erro - Teste Belli
      ---IF (vr_qtdsuces+vr_qtderros) > 10 THEN
      ---  vr_cdcritic := 0 / 0; 
      ---END IF;
      
        EXCEPTION
          WHEN vr_exc_sai_ret_arq_lop_2 THEN
            -- ERRO tratado
            pc_critica_loop;                      
                -- Controle maximo de criticas por Arquivo
                IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
                  RAISE vr_exc_sai_ret_arq_lop_1_B;
                END IF;     
                vr_cdcritic := NULL;
                vr_dscritic := NULL; 
          WHEN OTHERS THEN
            -- Acionar log exceções internas
            CECRED.pc_internal_exception(pr_cdcooper => 3);--
            vr_cdcritic  := 9999;
              vr_dssqlerrm := SQLERRM;
              pr_idcritic  := 2; -- Alta
              pc_critica_loop;                  
              -- Controle maximo de criticas
              IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
                RAISE vr_exc_sai_ret_arq_lop_1_B;
              ELSE               
                vr_cdcritic := NULL;
                vr_dscritic := NULL;        
              END IF;
        END;            
        END LOOP;        
        
        -- Gerar LOG após processar todas as linhas retornadas daquele arquivo
        BEGIN
          INSERT INTO TBCAPT_CUSTODIA_LOG
                     (idarquivo
                     ,dtlog
                     ,dslog)
               VALUES(rw_arq.idarquivo
                     ,SYSDATE
                     ,'Arquivo '||rw_arq.nmarquivo||' processado com:'||vr_dscarque||
                      'Quantidade de Erros: '||vr_qtderros||vr_dscarque||
                      'Quantidade de Sucessos: '||vr_qtdsuces||vr_dscarque||
                      'Total de linhas processadas:'||(vr_qtdsuces+vr_qtderros));
        EXCEPTION
          WHEN OTHERS THEN
            -- Acionar log exceções internas
            CECRED.pc_internal_exception(pr_cdcooper => 3);
            -- Erro não tratado
            vr_cdcritic  := 1034;
            vr_dssqlerrm := SQLERRM;
            pr_idcritic  := 2; -- Alto    
            vr_dsparesp  := ', tabela: tbcapt_custodia_log' ||
                            'idarquivo: '||rw_arq.idarquivo
                         || ', dslog: '||'Arquivo '||rw_arq.nmarquivo||' processado com:'||
                                        'Quantidade de Erros: '||vr_qtderros||
                                        'Quantidade de Sucessos: '||vr_qtdsuces||
                                        'Total de linhas processadas:'||(vr_qtdsuces+vr_qtderros);
            RAISE vr_exc_sai_ret_arq_lop_1;
        END;

        -- Atualizaremos o arquivo de retorno
        BEGIN
          UPDATE tbcapt_custodia_arquivo arq
             SET arq.idsituacao = 1       -- Processado
                ,arq.dtprocesso = SYSDATE -- Momento do Processo
           WHERE arq.idarquivo = rw_arq.idarquivo;
        EXCEPTION
          WHEN OTHERS THEN
                -- Acionar log exceções internas
                CECRED.pc_internal_exception(pr_cdcooper => 3);
            -- Erro não tratado
            vr_cdcritic := 1035;
            vr_dssqlerrm := SQLERRM;
            pr_idcritic  := 2; -- Alto    
            vr_dsparesp  := ', tabela: tbcapt_custodia_arquivo' ||
                            'idsituacao: 1'
                         || ' com idarquivo: '||rw_arq.idarquivo;
            RAISE vr_exc_sai_ret_arq_lop_1;
        END;

        -- Se existe arquivo de origem
        IF rw_arq.idarquivo_origem IS NOT NULL THEN
          -- Atualizar registros no arquivo de Origem que não existe no de Retorno para Erro
          BEGIN
            UPDATE tbcapt_custodia_conteudo_arq cnt
               SET cnt.dscritica = 'Registro sem retorno'
             WHERE cnt.idarquivo = rw_arq.idarquivo_origem
               AND cnt.idtipo_linha IN('L','D') --> Somente as linhas de informações e detalhes
               AND cnt.idlancamento NOT IN(SELECT cnt.idlancamento
                                             FROM tbcapt_custodia_conteudo_arq cnt
                                            WHERE cnt.idarquivo = rw_arq.idarquivo);
            -- Incrementar quantidade de erros
            vr_qtderros := vr_qtderros + SQL%ROWCOUNT;
          EXCEPTION
            WHEN OTHERS THEN
              -- Erro não tratado
              vr_cdcritic := 1035;
            vr_dssqlerrm := SQLERRM;
            pr_idcritic  := 2; -- Alto    
            vr_dsparesp  := ', tabela: tbcapt_custodia_conteudo_arq' ||
                             'dscritica: Registro sem retorno'
                          || ' com idarquivo = '||rw_arq.idarquivo_origem
                          || ' , idtipo_linha: L'
                          || ' , idlancamento not in(SELECT cnt.idlancamento ' ||
                             'FROM tbcapt_custodia_conteudo_arq cnt '||
                             'WHERE cnt.idarquivo = '||rw_arq.idarquivo||')';
              RAISE vr_exc_sai_ret_arq_lop_1;
          END;
          -- Atualizar possíveis lançamentos que não foram retornados no arquivo para erro
          -- pois se encontramos retorno todos os registros devem estar no mesmo
          BEGIN
            UPDATE tbcapt_custodia_lanctos lct
               SET lct.idsituacao = 9 -- Erro
                  ,lct.dtretorno = SYSDATE
             WHERE lct.idsituacao NOT IN(8,9) -- Aqueles não processados ainda
               AND lct.idlancamento IN(SELECT cnt.idlancamento
                                         FROM tbcapt_custodia_conteudo_arq cnt
                                        WHERE cnt.idarquivo = rw_arq.idarquivo_origem
                                          AND cnt.dscritica = 'Registro sem retorno');
          EXCEPTION
            WHEN OTHERS THEN
                -- Acionar log exceções internas
                CECRED.pc_internal_exception(pr_cdcooper => 3);
              -- Erro não tratado
              vr_cdcritic := 1035;
            vr_dssqlerrm := SQLERRM;
            pr_idcritic  := 2; -- Alto    
            vr_dsparesp  := ', tabela: tbcapt_custodia_lanctos' ||
                            ', idsituacao: 9'
                          || ' com idsituacao NOT IN(8,9) '
                          || ' , idlancamento in: SELECT cnt.idlancamento ' ||
                            'FROM tbcapt_custodia_conteudo_arq cnt ' ||
                            'WHERE cnt.idarquivo = '||rw_arq.idarquivo_origem||
                            ' and cnt.dscritica = Registro sem retorno. ';
              RAISE vr_exc_sai_ret_arq_lop_1;
          END;

        END IF;

        -- Após processar o arquivo, se houve algum erro
        IF vr_qtderros > 0 THEN
           pc_envia_email_alerta_arq(pr_dsdemail  => pr_dsdemail      --> Destinatários
                                    ,pr_dsjanexe  => pr_dsjanexe      --> Descrição horário execução
                                    ,pr_idarquivo => rw_arq.idarquivo --> ID do arquivo
                                    ,pr_dsdirbkp  => NULL             --> Caminho de backup linux
                                    ,pr_dsredbkp  => NULL             --> Caminho da rede de Backup
                                    ,pr_flgerrger => vr_flerrger      --> erro geral do arquivo
                                    ,pr_idcritic  => vr_idcritic      --> Criticidade da saida
                                    ,pr_cdcritic  => vr_cdcritic      --> Código da critica
                                    ,pr_dscritic  => vr_dscritic);    --> Descrição da critica
          -- Em caso de erro
          IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_sai_ret_arq_lop_1;
          END IF;
        END IF;
        -- Enviar ao LOG resumo da execução
        IF vr_qtderros + vr_qtdsuces > 0 THEN
          pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char ||
                      'Arquivo '||rw_arq.nmarquivo||' processado com:'||vr_dscarque||
                      'Quantidade de Erros: '||vr_qtderros||vr_dscarque||
                      'Quantidade de Sucessos: '||vr_qtdsuces||vr_dscarque;
        END IF;
        -- Gravar a cada arquivo com sucesso
        -- COMMIT; -- -- Anderson
        -- Sair se processou a quantidade máxima de arquivos por execução
        IF vr_qtdaruiv >= vr_qtdexjob THEN
          EXIT;
        END IF;
        
           

      EXCEPTION
        WHEN vr_exc_sai_ret_arq_lop_1_B THEN      
          -- Controle maximo de criticas por Arquivo
          IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
            RAISE vr_exc_saida_ret_arq_2;
          END IF;  
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        WHEN vr_exc_sai_ret_arq_lop_1 THEN
          -- Efetuar retorno do erro nao tratadotratado
          pc_critica_loop;         
          -- Controle maximo de criticas por Arquivo
          IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
            RAISE vr_exc_saida_ret_arq_2;
          END IF;  
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        WHEN OTHERS THEN
          -- Acionar log exceções internas
          CECRED.pc_internal_exception(pr_cdcooper => 3);  
          -- Efetuar retorno do erro nao tratado--
          vr_cdcritic  := 9999;
          vr_dssqlerrm := SQLERRM;
          pr_idcritic  := 2; -- Alta
          pc_critica_loop;                  
          -- Controle maximo de criticas
          IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
            RAISE vr_exc_saida_ret_arq_2;
          ELSE               
            vr_cdcritic := NULL;
            vr_dscritic := NULL;        
          END IF;                    
      END;                  
      END LOOP;
      
      -- Controle Saida  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            '. Finalizado' ||
                            ' '      || vr_nmaction ||
                            ' '      || vr_nmproint1 ||
                            ' '      || vr_dsparame 
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            ); 
      -- Forçado erro - Teste Belli
      ---vr_cdcritic := 0 / 0;

    EXCEPTION
      WHEN vr_exc_saida_ret_arq_2 THEN   
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN vr_exc_saida_ret_arq_1 THEN
        vr_cdcritic := NVL(vr_cdcritic,0);
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic) ||
                           ' ' || vr_nmaction   ||
                           ' ' || vr_nmproint1 ||
                           ' ' || vr_dsparame  ||
                           ' ' || vr_nomdojob;
        pr_idcritic := 1; -- Media   
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic
              ,pr_cdcricid => pr_idcritic);    
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Acionar log exceções internas
        CECRED.pc_internal_exception(pr_cdcooper => 3);
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                           ' ' || SQLERRM      ||
                           ' ' || vr_nmaction  ||
                           ' ' || vr_nmproint1 ||
                           ' ' || vr_dsparame  ||
                           ' ' || vr_nomdojob;
        pr_idcritic := 2; -- Alta                  
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic
              ,pr_cdcricid => pr_idcritic);    
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_processa_retorno_arquivos;

  -- Rotina para processar retorno de conciliação pendentes de processamento
  PROCEDURE pc_processa_conciliacao(pr_flprccnc  IN VARCHAR2     --> Conciliação ativa
                                   ,pr_dtultcnc  IN DATE         --> Data da ultima conciiação
                                   ,pr_dsdemail  IN VARCHAR2     --> Destinatários
                                   ,pr_dsjanexe  IN VARCHAR2     --> Descrição horário execução
                                   ,pr_dsdirbkp  IN VARCHAR2     --> Caminho de backup linux
                                   ,pr_dsredbkp  IN VARCHAR2      --> Caminho da rede de Backup
                                   ,pr_dsdaviso OUT VARCHAR2     --> Avisos dos eventos ocorridos no processo
                                   ,pr_idcritic OUT NUMBER       --> Criticidade da saida
                                   ,pr_cdcritic OUT NUMBER       --> Código da critica
                                   ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc processa conciliacao
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 03/04/2019
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Processar e integrar arquivos de conciliação
    -- Alteracoes:
    --             06/12/2018 - P411 - Remocao da conciliação por saldo, manter apenas por quantidade (Marcos-Envolti)
    --
    --             12/12/2018 - P411 - Ajustes para o Layout para 15 posições (Marcos-Envolti)
    -- 
    --             19/03/2019 - P411 - Ajustes na conciliação para considerar percentuais de tolerancia (Martini)
    -- 
    --             03/04/2019 - Projeto 411 - Fase 2 - Parte 2 - Conciliação Despesa B3 e Outros Detalhes
    --                          Ajusta mensagens de erros e trata de forma a permitir a monitoração automatica.
    --                          Procedimento de Log - tabela: tbgen prglog ocorrencia 
    --                         (Envolti - Belli - PJ411_F2_P2)
    --                                                      
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Variaveis auxiliares
      vr_txretorn   gene0002.typ_split; --> Separação da linha em vetor
      vr_qtdsuces   NUMBER;             --> Quantidade de Sucessos
      vr_qtderros   NUMBER;             --> Quantidade de Erros
      vr_dtmvtolt   DATE;               --> Data do arquivo
      vr_flerrger   BOOLEAN;            --> Flag de erro geral
      -- BELLI / ANDERSON 18/04/2019
      --vr_qtdausen   NUMBER;             --> Quantidade de aplicações ausentes no arquivo
      -- Quantidade de arquivos processados
      vr_qtdaruiv              NUMBER := 0;
      
      vr_exc_saida_loop_1        EXCEPTION;
      vr_exc_saida_loop_2        EXCEPTION;
      vr_exc_saida_conciliacao_1 EXCEPTION;
      vr_exc_saida_conciliacao_2 EXCEPTION;
      vr_exc_saida_conciliacao_0 EXCEPTION;
      vr_qtlimerr                NUMBER     (12);
      vr_dscriarq                VARCHAR2 (4000);
      --
      vr_dspartot                VARCHAR2 (4000);
      vr_dsparint                VARCHAR2 (4000);
      vr_dsparlp1                VARCHAR2 (4000);
      vr_dsparlp2                VARCHAR2 (4000);
      vr_dsparlp3                VARCHAR2 (4000);
      vr_dsparlp4                VARCHAR2 (4000);
      vr_dsparlp5                VARCHAR2 (4000);
      vr_dsparesp                VARCHAR2 (4000);
      vr_dssqlerr                VARCHAR2 (4000);

      -- Busca dos arquivos pendentes e seu conteudo
      CURSOR cr_arquivos IS
        SELECT arq.idarquivo
              ,arq.nmarquivo
              ,arq.idtipo_arquivo
              ,arq.idarquivo_origem
          FROM tbcapt_custodia_arquivo arq
         WHERE arq.idtipo_operacao = 'R'
           AND arq.idsituacao = 0 -- Pendente Processamento
           AND arq.idtipo_arquivo = 9 -- Concliação
         ORDER BY arq.idarquivo
         FOR UPDATE;
      rw_arq cr_arquivos%ROWTYPE;

      -- Busca do conteudo do arquivo
      CURSOR cr_conteudo(pr_idarquivo tbcapt_custodia_arquivo.idarquivo%TYPE) IS
        SELECT cnt.nrseq_linha
              ,cnt.dslinha
          FROM tbcapt_custodia_conteudo_arq cnt
         WHERE cnt.idarquivo = pr_idarquivo
           AND cnt.idtipo_linha = 'L' --> Somente as linhas de informações
         ORDER BY cnt.nrseq_linha;

      -- Buscar aplicação em Custódia
      CURSOR cr_aplica(pr_dscodigB3 tbcapt_custodia_aplicacao.dscodigo_b3%TYPE) IS
        SELECT apl.idaplicacao
              ,apl.tpaplicacao
              ,0 cdcooper
              ,0 nrdconta
              ,0 nraplica
              ,0 cdprodut
              ,to_date(NULL) dtmvtolt
              ,to_date(NULL) dtvencto
              ,apl.qtcotas
              ,apl.vlpreco_registro
          FROM tbcapt_custodia_aplicacao apl
        WHERE apl.dscodigo_b3 = pr_dscodigB3;
      rw_aplica cr_aplica%ROWTYPE;

      -- Buscar aplicação RDA
      CURSOR cr_craprda(pr_idaplcus craprda.idaplcus%TYPE) IS
        SELECT rda.cdcooper
              ,rda.nrdconta
              ,rda.nraplica
              ,rda.dtmvtolt
              ,rda.dtvencto
          FROM craprda rda
         WHERE rda.idaplcus = pr_idaplcus;

      -- Buscar aplicação RAC
      CURSOR cr_craprac(pr_idaplcus craprac.idaplcus%TYPE) IS
        SELECT rac.cdcooper
              ,rac.nrdconta
              ,rac.nraplica
              ,rac.cdprodut
              ,rac.dtmvtolt
              ,rac.dtvencto
          FROM craprac rac
         WHERE rac.idaplcus = pr_idaplcus;


      -- Buscar todas as aplicações existentes no Ayllos e que não foram conciliadas
      -- Exclusao do cursor cr_aplica_sem_concil - BELLI / ANDERSON 18/04/2019

      -- Saldo da aplicação e preço unitário
      vr_sldaplic craprda.vlsdrdca%TYPE;
      vr_vlpreco_unit tbcapt_custodia_aplicacao.vlpreco_unitario%TYPE;
      vr_valor_tot_b3 NUMBER(38,8); -- -- Anderson

    -- Busca do valor conciliado -- -- Anderson
      CURSOR cr_saldo(pr_cdcooper    craprda.cdcooper%TYPE   
                     ,pr_nrdconta    craprda.nrdconta%TYPE   
                     ,pr_nraplica    craprda.nraplica%TYPE   
                     ,pr_tpaplicacao craprda.tpaplica%TYPE
                     ,pr_dtmvtolt    craprda.dtmvtolt%TYPE) IS
        SELECT sl.VLSALDO_CONCILIA
          FROM tbcapt_saldo_aplica sl
         WHERE sl.cdcooper    = pr_cdcooper   
           AND sl.nrdconta    = pr_nrdconta   
           AND sl.nraplica    = pr_nraplica   
           AND sl.tpaplicacao = pr_tpaplicacao
           AND sl.dtmvtolt    = pr_dtmvtolt;
          
      -- Percentual de tolerancia
      vr_vlpertol NUMBER(25,5);
         
      ---vr_qttot_1470 NUMBER(25,5) := 0; -- Forçada variavel Teste Belli   

      -- Flag de conciliação OK
      vr_flgconcil BOOLEAN := FALSE;

      -- Busca do dia util anterior
      vr_dtmvtoan DATE;
      
      -- Tipo de aplicação da tabela TBCAPT_SALDO_APLICA
      -- tipo de aplicacao (1 - rdc pos e pre / 2 - pcapta / 3 - aplic programada)
      -- David Valente (Envolti) 
      vr_tpaplicacao NUMBER(2);
      
      -- Controle execução
      vr_qthoravicon NUMBER    (2);
      vr_qtminavicon NUMBER    (2);
      vr_qtregavicon NUMBER   (12);
      vr_hraviatrccl VARCHAR2  (5);
      
      vr_flginicio      BOOLEAN;
      vr_flgavitempo    BOOLEAN;
      vr_flgavivolume   BOOLEAN;
      vr_fglatrcclmail  BOOLEAN;
      
      vr_qthorcorrido   NUMBER (3);
      vr_qtmincorrido   NUMBER (2);   
      vr_qtregavivolume NUMBER(12);
      vr_qtregtotal     NUMBER(12);
      
      vr_dthrinicio DATE;
      
      vr_nmproint1      VARCHAR2 (100) := 'pc_processa_conciliacao';

    -- Controle de execução
    PROCEDURE pc_controle_execução
      IS
      -- Controle de execução     
      vr_nmproint2 VARCHAR2 (100) := 'pc_controle_execução';
    BEGIN

      vr_qthorcorrido := TRUNC(( SYSDATE - vr_dthrinicio ))* 24 + TRUNC((( SYSDATE - vr_dthrinicio )  - 
                         TRUNC(( SYSDATE - vr_dthrinicio )))* 24 );

      vr_qtmincorrido := TRUNC((((( SYSDATE - vr_dthrinicio ) - TRUNC(( SYSDATE - vr_dthrinicio )))* 24 ) -
                         TRUNC((( SYSDATE - vr_dthrinicio ) - TRUNC(( SYSDATE - vr_dthrinicio )))* 24 ))* 60 );
      
      vr_qtregavivolume := vr_qtregavivolume + 1;
      
      IF NOT vr_fglatrcclmail THEN
        IF TO_CHAR(SYSDATE,'HH24:MI') > vr_hraviatrccl THEN
          vr_fglatrcclmail := TRUE;
        END IF;
      END IF;
      
      IF vr_qthorcorrido > vr_qthoravicon OR
        ( vr_qthorcorrido = vr_qthoravicon AND
          vr_qtmincorrido > vr_qtminavicon )    THEN
        vr_flgavitempo  := TRUE;
        vr_qthorcorrido := 0;
        vr_qtmincorrido := 0;        
      END IF;
             
      IF vr_qtregavivolume >= vr_qtregavicon THEN
        vr_flgavivolume   := TRUE;
        vr_qtregavivolume := 0;
      END IF;
            
      IF vr_flginicio   OR
         vr_flgavitempo    THEN
        -- registra log
        pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            ' - '     || 'Conciliação em execução  - (T) - ' ||
                            'Registros processados até o momento:' || vr_qtregtotal ||
                            ', vr_qthorcorrido:' || vr_qthorcorrido ||
                            ', vr_qtmincorrido:' || vr_qtmincorrido ||
                            '. '      || vr_dspartot  ||
                            '. '      || vr_nmproint2
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            );
            
        -- Passa email
        IF vr_fglatrcclmail THEN
           vr_cdcooper := 3;
           vr_dsassunt := 'Atraso Conciliação B3';
           vr_dscorpo  := 'Favor avaliar o atraso do processo do B3';
           vr_dslisane := NULL;                        
          pc_monta_e_mail;
          -- Retorno nome do módulo logado
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
        END IF;
        
        vr_flgavitempo  := FALSE;
        vr_dthrinicio   := SYSDATE;
        vr_flgavivolume := FALSE;
      END IF;
            
      IF vr_flgavivolume    THEN
        -- registra log
        pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            ' - '     || 'Conciliação em execução - (V) - ' ||
                            'Registros processados até o momento:' || vr_qtregtotal ||
                            ', vr_qthorcorrido:' || vr_qthorcorrido ||
                            ', vr_qtmincorrido:' || vr_qtmincorrido ||
                            '. '      || vr_dspartot  ||
                            '. '      || vr_nmproint2
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            ); 
        vr_flgavivolume := FALSE;
      END IF;
      
      vr_flginicio := FALSE;
            
    END pc_controle_execução;
    --        
              
    --
    BEGIN                                --   PRINCIPAL - INICIO  
          
      vr_cdcritic := NULL;
      vr_dscritic := NULL;                    
      vr_dsparint := ', pr_flprccnc:' || pr_flprccnc ||
  	                 ', pr_dtultcnc:' || pr_dtultcnc ||
	                   ', pr_dsdemail:' || pr_dsdemail ||
	                   ', pr_dsjanexe:' || pr_dsjanexe ||
	                   ', pr_dsdirbkp:' || pr_dsdirbkp ||
	                   ', pr_dsredbkp:' || pr_dsredbkp ;      
      vr_dspartot := ' ' || vr_nmaction  ||
                     ' ' || vr_nmproint1 ||
                     ' ' || vr_nomdojob  ||
                     ' ' || vr_dsparame  ||
                     ' ' || vr_dsparint;
                       
      -- Incluir Email
      pr_dsdaviso := '<br><br>' || fn_get_time_char || vr_dspro001_E;  
      -- Limite de erros no processo de conciliação com o fornecedor => B3
      vr_qtlimerr := gene0001.fn_param_sistema('CRED',0,'LIMERRO_PROC_CONCILIA_B3');
      vr_qtlimerr := NVL(vr_qtlimerr,0);           
      -- Controle Entrada  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            ' Inicio - ' || vr_dspartot ||
                            ', vr_qtlimerr:' || vr_qtlimerr
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            );       
      -- Forçado erro - Teste Belli
      --- vr_cdcritic := 0 / 0;
      -- Buscar o percentual de tolerancia
      vr_cdacesso := 'CD_TOLERANCIA_DIF_VALOR';
      BEGIN
        vr_vlpertol := NVL(gene0001.fn_param_sistema('CRED',3,'CD_TOLERANCIA_DIF_VALOR'),0);
        -- Retorna do módulo e ação logado
        gene0001.pc_set_modulo(pr_module => null, pr_action => vr_nmaction);
      EXCEPTION
        WHEN OTHERS THEN  
          -- Acionar log exceções internas
          CECRED.pc_internal_exception(pr_cdcooper => 3);
          -- Efetuar retorno do erro nao tratado
          vr_cdcritic := 9999;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                           '. ' || SQLERRM     ||
                           '. ' || vr_dspartot ||
                           ', cdacesso:' || vr_cdacesso;
          -- Log de erro de execucao
          pc_log(pr_cdcritic => vr_cdcritic
                ,pr_dscrilog => vr_dscritic);  
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
          vr_vlpertol := 0;
      END;
            
      -- Somente proceder se conciliação estiver ativa e ainda não efetuada para o dia      
      IF pr_flprccnc = 'S' AND pr_dtultcnc < trunc(SYSDATE) THEN

        vr_fgtempro := TRUE;
                      
        -- Buscar quantidade máxima de registros por arquivo a disponibilizar em HTML referentes a conciliação entre o fornecedor e a cooperativa central, 
        -- os registros são toda a movimentação de aplicações, sendo o fornecedor o B3 que faz a interface com o banco central.         
        -- Vou assumir que Nulo, não cadastrado, erro na busca(Gero critica) ou zero é gerar o arquivo sem limites
        vr_cdacesso := 'QTD_REG_CCL_FRN_APL';
        BEGIN
          vr_qtmaxreq := NVL(gene0001.fn_param_sistema('CRED', 0 ,vr_cdacesso),0);
          -- Retorna do módulo e ação logado
          gene0001.pc_set_modulo(pr_module => null, pr_action => vr_nmaction);
        EXCEPTION
          WHEN OTHERS THEN
            -- Acionar log exceções internas
            CECRED.pc_internal_exception(pr_cdcooper => 3);
            -- Efetuar retorno do erro nao tratado
            vr_cdcritic := 9999;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                           '. ' || SQLERRM     ||
                           '. ' || vr_dspartot || 
                           ', cdacesso:' || vr_cdacesso;
            -- Log de erro de execucao
            pc_log(pr_cdcritic => vr_cdcritic
                  ,pr_dscrilog => vr_dscritic);  
            vr_cdcritic := NULL;
            vr_dscritic := NULL;
            vr_qtmaxreq := 0;
        END;
        vr_infimarq_1 := 'N';
        vr_infimarq_2 := 'N';
        
        -- Busca do dia util anterior
        vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper  => 3
                                                  ,pr_dtmvtolt  => trunc(SYSDATE)-1
                                                  ,pr_tipo      => 'A');
        -- Retorna do módulo e ação logado
        gene0001.pc_set_modulo(pr_module => null, pr_action => vr_nmaction);
                                                  
        -- Forçado controle - mas sera permanente - Teste Belli
        -- inicio da conciliação - tempo
        -- a CADA x TEMPO EXEMPLO 25:00 MINUTOS passa um e-mail para dizer que esta em execução
        -- também resgistra a cada 200.000 reg proc um rgsitro só na base de ALERTA ACOMPANHA
        -- também a cada arquivo registrar o tempo de execução dados gerais log
        
        vr_qthoravicon := NVL(gene0002.fn_busca_entrada(1,gene0001.fn_param_sistema('CRED',0,'CTR_CLC_AVISO_EXE'),';'),0);
        vr_qtminavicon := NVL(gene0002.fn_busca_entrada(2,gene0001.fn_param_sistema('CRED',0,'CTR_CLC_AVISO_EXE'),';'),1);
        vr_qtregavicon := NVL(gene0002.fn_busca_entrada(3,gene0001.fn_param_sistema('CRED',0,'CTR_CLC_AVISO_EXE'),';'),1000);
        -- Horario de inicio do alerta de necessidade de e-mail do atraso da conciliação
        vr_hraviatrccl := NVL(gene0002.fn_busca_entrada(4,gene0001.fn_param_sistema('CRED',0,'CTR_CLC_AVISO_EXE'),';'),'14:45');        
        -- Retorna do módulo e ação logado
        gene0001.pc_set_modulo(pr_module => null, pr_action => vr_nmaction);
        --
        vr_flginicio      := TRUE;
        vr_flgavitempo    := FALSE;
        vr_flgavivolume   := FALSE;        
        vr_fglatrcclmail  := FALSE;
        vr_qtregtotal     := 0;
        vr_qtregavivolume := 0;        
        vr_dthrinicio     := SYSDATE;
        
        -- Buscamos todos os arquivos pendentes de conciliação
        LOOP
        BEGIN
          OPEN cr_arquivos;
          FETCH cr_arquivos
           INTO rw_arq;
          -- Sair ao não encontrar
          IF cr_arquivos%NOTFOUND THEN
            CLOSE cr_arquivos;
            EXIT;
          ELSE
            CLOSE cr_arquivos;
          END IF;
          -- Incrementar contador
          vr_qtdaruiv := vr_qtdaruiv + 1;
          
          vr_dsparlp1 := ', vr_qtdaruiv:'      || vr_qtdaruiv ||
                         ', rw_arq.idarquivo:' || rw_arq.idarquivo ||
                         ', rw_arq.nmarquivo:' || rw_arq.nmarquivo;
          
          -- Resetar contadores internos do arquivo          
          vr_dsparlp2 := NULL;       
          vr_dsparlp3 := NULL;     
          vr_dsparlp4 := NULL;   
          vr_dsparlp5 := NULL;
          vr_dsparesp := NULL;
          vr_dssqlerr := NULL;
          vr_qtdsuces := 0;
          vr_qtderros := 0;
          vr_cdcritic := 0;
          vr_dscritic := NULL;
          vr_dtmvtolt := NULL;
          vr_flerrger := FALSE;
          
      -- Forçado erro - Teste Belli
      --- vr_cdcritic := 0 / 0;
                 
      -- teste anderson                                               
      -- vr_dtmvtoan := TO_DATE('28/03/2019','dd/mm/rrrr');   
          
          -- Buscar data do arquivo ('CETIP_[0-9][0-9][0-9][0-9][0-9][0-9]_[A-Z][A-Z]_.*DPOSICAOCUSTODIA')
          BEGIN
            vr_dtmvtolt := to_date(SUBSTR(rw_arq.nmarquivo,7,6),'rrmmdd');   
          EXCEPTION
            WHEN OTHERS THEN
              -- Acionar log exceções internas
              CECRED.pc_internal_exception(pr_cdcooper => 3);  
              -- Erro tratado
              vr_cdcritic := 13; -- Erro ao definir data a partir do nome do Arquivo
              vr_dscriarq := gene0001.fn_busca_critica(vr_cdcritic);
              vr_dscritic := vr_dscriarq          ||
                             '. ' || SQLERRM      ||                           
                             '. ' || vr_dspartot  ||
                             '. ' || vr_dsparlp1
                             ;
              pr_idcritic := 1; -- Media                                      
              -- Log de erro de execucao
              pc_log(pr_cdcritic => vr_cdcritic
                    ,pr_dscrilog => vr_dscritic
                    ,pr_cdcricid => pr_idcritic);   
              vr_cdcritic := NULL;
              vr_dscritic := NULL;
          END;      
          
          -- A data do arquivo não pode ser inferior ao dia util anterior
          IF vr_dscriarq IS NULL AND 
             vr_dtmvtoan > vr_dtmvtolt THEN
            vr_cdcritic := 1468; -- Recebido arquivo de conciliação com data antiga e será processado apenas o arquivo com a data parametrizada                   
            vr_dscriarq := gene0001.fn_busca_critica(vr_cdcritic) ||
                           ', data antiga:'        || TO_CHAR(vr_dtmvtolt,'DD/MM/RRRR') ||
                           ', data parametrizada:' || TO_CHAR(vr_dtmvtoan,'DD/MM/RRRR');                           

          END IF; 
          
          -- Em caso de erro na definição acima
          IF vr_dscriarq IS NOT NULL THEN
            --            
            vr_dscritic := vr_dscriarq          ||                      
                           ', ' || vr_dspartot  ||
                           ', ' || vr_dsparlp1;
            pr_idcritic := 1; -- Media                                      
            -- Log de erro de execucao
            pc_log(pr_cdcritic => vr_cdcritic
                  ,pr_dscrilog => vr_dscritic
                  ,pr_cdcricid => pr_idcritic);   
            vr_cdcritic := NULL;
            vr_dscritic := NULL;
              
            -- Geraremos erro em todas as linhas do arquivo
            BEGIN
              UPDATE tbcapt_custodia_conteudo_arq cnt
                 SET cnt.dscritica   = vr_dscriarq
               WHERE cnt.idarquivo   = rw_arq.idarquivo;
              -- Quantidade de erros incrementada
              vr_qtderros := SQL%ROWCOUNT;
              vr_flerrger := TRUE; -- Erro geral
            EXCEPTION
              WHEN OTHERS THEN
                -- Acionar log exceções internas
                CECRED.pc_internal_exception(pr_cdcooper => 3);  
                -- Erro não tratado
                vr_cdcritic := 1035;
                vr_dssqlerr := ' ' || SQLERRM;
                vr_dsparesp := ', tabela: tbcapt_custodia_conteudo_arq'  ||
                               ', vr_dscriarq:'  || vr_dscriarq;
                RAISE vr_exc_saida_loop_1;
            END;
            -- Gerar LOG após processar todas as linhas retornadas daquele arquivo
            BEGIN
              INSERT INTO TBCAPT_CUSTODIA_LOG
                         (idarquivo
                         ,dtlog
                         ,dslog)
                   VALUES(rw_arq.idarquivo
                         ,SYSDATE
                         ,'Arquivo '||rw_arq.nmarquivo||' não conciliado!'||vr_dscarque||
                          'Problema encontrado: '||vr_dscriarq||vr_dscarque);
            EXCEPTION
              WHEN OTHERS THEN
                -- Acionar log exceções internas
                CECRED.pc_internal_exception(pr_cdcooper => 3);  
                -- Erro não tratado
                vr_cdcritic := 1034;
                vr_dssqlerr := ' ' || SQLERRM;
                vr_dsparesp := ', tabela: tbcapt_custodia_conteudo_arq' ||
                               ', vr_dscriarq:'  || vr_dscriarq;
                RAISE vr_exc_saida_loop_1;
            END;
          ELSE
            -- Setar a flag de encontro do arquivo de conciliação do dia
            vr_flgconcil := TRUE;
            -- Processar todas as linhas do arquivo
            FOR rw_cnt IN cr_conteudo(rw_arq.idarquivo) LOOP
            BEGIN

              vr_qtregtotal := vr_qtregtotal + 1;  
                           
              vr_dsparlp2   := ', vr_qtregtotal:'      || vr_qtregtotal      ||
                               ', rw_cnt.nrseq_linha:' || rw_cnt.nrseq_linha ||
                               ', rw_cnt.dslinha:'     || rw_cnt.dslinha;      
              vr_dsparlp3 := NULL;     
              vr_dsparlp4 := NULL;   
              vr_dsparlp5 := NULL;
              vr_dsparesp := NULL;
              vr_dssqlerr := NULL;
                                           
              -- Forçado erro - Teste Belli 
             --- IF vr_qtregtotal IN ( 2, 4, 1000 ) THEN
             ---   vr_cdcritic := 0 / 0;
             --- END IF;
            
              -- Limpar criticas
              vr_dscritic := NULL;
              -- Cada linha será separada em vetor para facilitar o processamento
              vr_txretorn := gene0002.fn_quebra_string(rw_cnt.dslinha, ';');
              -- Retorna do módulo e ação logado
              gene0001.pc_set_modulo(pr_module => null, pr_action => vr_nmaction);
              
              -- Verifica se a quebra resultou em um array válido e com pelo menos 27 posições
              IF vr_txretorn.count() = 0 OR vr_txretorn.count() < 27 THEN
                
                vr_cdcritic := 1469; -- Conciliação não confere com o Layout definido! O mesmo não será processado
                vr_dscriarq := gene0001.fn_busca_critica(vr_cdcritic) ||
                               ', quant. de caractres:' || vr_txretorn.count();                       
                --
                vr_dscritic := vr_dscriarq ||
                             ' ' || vr_dspartot  ||
                             ' ' || vr_dsparlp1  ||
                             ' ' || vr_dsparlp2  ||
                             ' ' || vr_dsparesp;
                pr_idcritic := 1; -- Media                                      
                -- Log de erro de execucao
                pc_log(pr_cdcritic => vr_cdcritic
                      ,pr_dscrilog => vr_dscritic
                      ,pr_cdcricid => pr_idcritic);   
                vr_cdcritic := NULL;
                vr_dscritic := NULL;
                
                -- Invalidar a linha pois o Layout da mesma não confere
                BEGIN
                  UPDATE tbcapt_custodia_conteudo_arq cnt
                     SET cnt.dscritica = vr_dscriarq                    
                   WHERE cnt.idarquivo   = rw_arq.idarquivo
                     AND cnt.nrseq_linha = rw_cnt.nrseq_linha;              
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Acionar log exceções internas
                    CECRED.pc_internal_exception(pr_cdcooper => 3);  
                    -- Erro não tratado
                    vr_cdcritic := 1035;
                    vr_dssqlerr := ' ' || SQLERRM;
                    vr_dsparesp := ', tabela: tbcapt_custodia_conteudo_arq' ||
                                   ', vr_dscriarq:' || vr_dscriarq || 
                                   '. vr_txretorn.count():' || vr_txretorn.count();
                    RAISE vr_exc_saida_loop_2;
                END;
                -- Incrementar erro
                vr_qtderros := vr_qtderros + 1;
              ELSE
                       
                -- Validar Tipo ID
                IF vr_txretorn(4) <> 'RDB' THEN
                    
                  vr_cdcritic := 1471; -- Tipo de Instrumento Financeiro diferente de (RDB)
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                                 ' vr_txretorn(4), chegouchegou o indicador:' || vr_txretorn(4);
                -- Validar TIpo de Posição de Custódia
                ELSIF vr_txretorn(13) <> '1' THEN                    
                                 
                  vr_cdcritic := 1472; -- Tipo de Posição em Custódia diferente de (1)
                  vr_cdcritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                                 ', chegou o indicador:' || vr_txretorn(13);
                ELSE
                  -- Busca da aplicação conforme códigoIF
                  rw_aplica := NULL;
                  OPEN cr_aplica(vr_txretorn(5));
                  FETCH cr_aplica
                   INTO rw_aplica;
                  -- Se não encontrar
                  IF cr_aplica%NOTFOUND THEN
                    CLOSE cr_aplica;
                    
                    vr_cdcritic := 1473; -- Aplicação não encontrada para Conciliação
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                                   ', Chave aplicação:' || vr_txretorn(5);
                  ELSIF rw_aplica.qtcotas = 0 THEN
                    CLOSE cr_aplica;
                    
                    vr_cdcritic := 1474; -- Aplicação com Qtde Cotas igual a zero
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                                   ', chave aplicação:'   || vr_txretorn(5)   ||
                                   ', tipo de aplicacao:' || rw_aplica.tpaplicacao ||
                                   ', quant. de cotas:'   || rw_aplica.qtcotas;  
                  ELSE
                           
                    vr_dsparlp3 := ', rw_aplica.idaplicacao:'      || rw_aplica.idaplicacao ||
                                   ', rw_aplica.tpaplicacao:'      || rw_aplica.tpaplicacao ||
                                   ', rw_aplica.qtcotas:'          || rw_aplica.qtcotas     ||
                                   ', rw_aplica.vlpreco_registro:' || rw_aplica.vlpreco_registro;
                               
                    CLOSE cr_aplica;                    
                    
                    -- Variavel de controle com o tipo de aplicação
                    -- se for aplicações do tipo 3 ou 4, recebe 2 senão recebe 1 
                    -- para compatibilizar com os dados da tbcapt_saldo_aplica que recebe somente 1,2 ou 3
                    vr_tpaplicacao := 0;                    
                    
                    -- Buscar aplicação RDA ou RAC relacionada                     
                    IF rw_aplica.tpaplicacao IN(3,4) THEN
                      -- Buscar aplicação RAC
                      OPEN cr_craprac(rw_aplica.idaplicacao);
                      FETCH cr_craprac
                       INTO rw_aplica.cdcooper
                           ,rw_aplica.nrdconta
                           ,rw_aplica.nraplica
                           ,rw_aplica.cdprodut
                           ,rw_aplica.dtmvtolt
                           ,rw_aplica.dtvencto;        
                      IF cr_craprac%FOUND THEN                      
                        vr_dsparlp4 := ', cr_craprac ' ||
                                       ', rw_aplica.cdcooper:' || rw_aplica.cdcooper ||
                                       ', rw_aplica.nrdconta:' || rw_aplica.nrdconta ||
                                       ', rw_aplica.nraplica:' || rw_aplica.nraplica ||
                                       ', rw_aplica.cdprodut:' || rw_aplica.cdprodut ||
                                       ', rw_aplica.dtmvtolt:' || rw_aplica.dtmvtolt ||
                                       ', rw_aplica.dtvencto:' || rw_aplica.dtvencto
                                       ;                    
                      END IF;
                      CLOSE cr_craprac;
                      vr_tpaplicacao := 2;
                    ELSE
                      -- Buscar aplicação RDA
                      OPEN cr_craprda(rw_aplica.idaplicacao);
                      FETCH cr_craprda
                       INTO rw_aplica.cdcooper
                           ,rw_aplica.nrdconta
                           ,rw_aplica.nraplica
                           ,rw_aplica.dtmvtolt
                           ,rw_aplica.dtvencto;                      
                      IF cr_craprda%FOUND THEN                      
                        vr_dsparlp4 := ', cr_craprda ' ||
                                       ', rw_aplica.cdcooper:' || rw_aplica.cdcooper ||
                                       ', rw_aplica.nrdconta:' || rw_aplica.nrdconta ||
                                       ', rw_aplica.nraplica:' || rw_aplica.nraplica ||
                                       ', rw_aplica.cdprodut:' || rw_aplica.cdprodut ||
                                       ', rw_aplica.dtmvtolt:' || rw_aplica.dtmvtolt ||
                                       ', rw_aplica.dtvencto:' || rw_aplica.dtvencto
                                       ;                    
                      END IF;
                      CLOSE cr_craprda;
                      vr_tpaplicacao := 1;                      
                    END IF;
                    -- Caso não tenha encontrado a aplicação correspondente
                    IF NVL(rw_aplica.cdcooper,0) + 
                       NVL(rw_aplica.nrdconta,0) + 
                       NVL(rw_aplica.nraplica,0)   = 0 THEN
                      
                      vr_cdcritic := 1475; -- Aplicação (RDA ou RAC) não encontrada para Conciliação
                      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || vr_dsparlp3; 
                    ELSE
                      -- Buscar o percentual de tolerancia
                      -- -- Anderson
                      -- -- vr_vlpertol := gene0001.fn_param_sistema('CRED',rw_aplica.cdcooper,'CD_TOLERANCIA_DIF_VALOR');                                              
                      -- Validar DAta de Vencimento e Emissão da Aplicação
                      IF TO_CHAR(rw_aplica.dtmvtolt,'RRRRMMDD') <> vr_txretorn(9) THEN
                        
                        vr_cdcritic := 1476; -- Data de Emissão diferente da Data Emissão Aplicação
                        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                                       ', data de emissão B3:'     || vr_txretorn(9) ||
                                       ', data de emissão legado:' || TO_CHAR(rw_aplica.dtmvtolt,'RRRRMMDD');
                                   
                      ELSIF TO_CHAR(rw_aplica.dtvencto,'RRRRMMDD') <> vr_txretorn(10) THEN
                        
                        vr_cdcritic := 1477; -- Data de vencimento diferente da Data Vencimento Aplicação
                        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                                       ', data de vencimento B3:'     ||  vr_txretorn(10) ||
                                       ', data de vencimento legado:' ||  TO_CHAR(rw_aplica.dtvencto,'RRRRMMDD');
                                   
                     /* Conciliar quantidade em cotas */
                      ELSIF TO_NUMBER(rw_aplica.qtcotas) <> TO_NUMBER(vr_txretorn(14)) THEN
                          
                        vr_cdcritic := 1478;
                        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                                       ', quantidade em carteira B3:'     || vr_txretorn(14) ||
                                       ', quantidade em carteira legado:' || rw_aplica.qtcotas;  
                      ELSE
                       -- Buscar  saldo calculado da aplicação
                        vr_sldaplic := 0;
                        OPEN cr_saldo(rw_aplica.cdcooper
                                     ,rw_aplica.nrdconta
                                     ,rw_aplica.nraplica
                                     ,vr_tpaplicacao
                                     ,vr_dtmvtoan);                                      
                        FETCH cr_saldo                                       
                         INTO vr_sldaplic; 
                      
                        vr_dsparlp5 := ', cdcooper:'       || rw_aplica.cdcooper ||
                                       ', nrdconta:'       || rw_aplica.nrdconta ||
                                       ', nraplica:'       || rw_aplica.nraplica ||
                                       ', vr_tpaplicacao:' || vr_tpaplicacao     ||
                                       ', vr_dtmvtoan:'    || vr_dtmvtoan        ||
                                       ', vr_sldaplic:'    || vr_sldaplic;   
                        
                        vr_dssqlerr := NULL;
                        CLOSE cr_saldo;                        
                        
                        -- Calcular valor unitário novamente com base no Saldo Ayllos X Quantidade de cotas
                        vr_vlpreco_unit := vr_sldaplic / rw_aplica.qtcotas;
                        
                        -- -- Anderson
                        vr_valor_tot_b3 := TO_NUMBER(vr_txretorn(14)) * vr_txretorn(16);  -- qtde b3 * pu b3;

                       -- Forçado Teste Belli                          
                       ---IF vr_qttot_1470 > 5 THEN
                       ---   vr_vlpertol := 999999999999;
                       ---END IF;

                       -- Validar valor nominal 
                        IF rw_aplica.vlpreco_registro <> vr_txretorn(15) THEN
                          
                          vr_cdcritic := 1479; -- Valor Nominal diferente do Registrado da Aplicação, com tolerancia
                          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                                         ', valor registrado B3:' || vr_txretorn(15)                  ||
                                         ', valor registrado carteira:' || rw_aplica.vlpreco_registro ||
                                         ', % tolerancia:'              || vr_vlpertol                ||
                                         vr_dsparlp5;                                                          
                          
                        -- Validar a PA atual recebida versus a calculada no 445 no processo
                   --     ELSIF ABS(((vr_vlpreco_unit - vr_txretorn(16)) / vr_txretorn(16)) * 100) < vr_vlpertol THEN
                   --       vr_dscritic := 'Valor da P.U. ('||vr_txretorn(16)||') diferente da P.U. calculada da Aplicação ('||vr_vlpreco_unit||'), tolerancia ('||vr_vlpertol||'%).';
                   
                        ELSIF ABS(((vr_sldaplic - vr_valor_tot_b3) / vr_valor_tot_b3) * 100) > vr_vlpertol THEN

                          -- Forçado Teste Belli  
                          ---vr_qttot_1470 := vr_qttot_1470 + 1;
                                              
                          vr_cdcritic := 1470; -- Valor da Aplic. B3 diferente do valor da aplicação no Aimaro e com tolerancia
                          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)  ||
                                         ', vr_valor_tot_b3:' || vr_valor_tot_b3 ||
                                         ', vr_sldaplic:'     || vr_sldaplic     ||
                                         ', % vr_vlpertol:'   || vr_vlpertol     ||
                                         vr_dsparlp5;
                                           
                        END IF;
                        
                      END IF;
                    END IF;
                  END IF;
                END IF;

                -- Em caso de erro
                IF vr_dscritic IS NOT NULL THEN
                  -- Quantidade de erros incrementada
                  vr_qtderros := vr_qtderros + 1;
                     
                  -- voltar e criar um codigo para cada erro
                  vr_dscritic := vr_dscritic         ||                      
                                 ' ' || vr_dspartot  ||
                                 ' ' || vr_dsparlp1  ||
                                 ' ' || vr_dsparlp2  ||
                                 ' ' || vr_dsparesp;
                  pr_idcritic := 0; -- baixa                                      
                  -- Log de erro de execucao
                  pc_log(pr_cdcritic => vr_cdcritic
                        ,pr_dscrilog => vr_dscritic
                        ,pr_cdcricid => pr_idcritic
                        ,pr_tpocorre => 3); 
                  
                  -- Atualizar erro na conciliação da aplicação
                  IF rw_aplica.idaplicacao IS NOT NULL THEN
                    BEGIN
                      UPDATE tbcapt_custodia_aplicacao apl
                         SET apl.idsitua_concilia = 2
                            ,apl.dtconcilia = SYSDATE
                       WHERE apl.idaplicacao = rw_aplica.idaplicacao;
                    EXCEPTION
                      WHEN OTHERS THEN
                        -- Acionar log exceções internas
                        CECRED.pc_internal_exception(pr_cdcooper => 3);  
                        -- Erro não tratado
                        vr_cdcritic := 1035;
                        vr_dssqlerr := ' ' || SQLERRM;
                        vr_dsparesp := ', tabela: tbcapt_custodia_aplicacao' ||
                                       ', idsitua_concilia: 2';
                        RAISE vr_exc_saida_loop_2;
                    END;
                  END IF;
                 
                  -- Geraremos erro no lançamento
                  BEGIN
                    UPDATE tbcapt_custodia_conteudo_arq cnt
                       SET cnt.dscritica = vr_dscritic
                          ,cnt.dscodigo_b3 = vr_txretorn(5)
                          ,cnt.idaplicacao = rw_aplica.idaplicacao
                     WHERE cnt.idarquivo   = rw_arq.idarquivo
                       AND cnt.nrseq_linha = rw_cnt.nrseq_linha;
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- Acionar log exceções internas
                      CECRED.pc_internal_exception(pr_cdcooper => 3);  
                      -- Erro não tratado
                      vr_cdcritic := 1035;
                      vr_dssqlerr := ' ' || SQLERRM;
                      vr_dsparesp := ', tabela: tbcapt_custodia_conteudo_arq' ||
                                     ', dscritica:'   || vr_dscritic    ||
                                     ', dscodigo_b3:' || vr_txretorn(5);
                      RAISE vr_exc_saida_loop_2;
                  END;  
                  
                  vr_cdcritic := NULL;
                  vr_dscritic := NULL;
                  
                ELSE
                  
              -- Forçado erro - Teste Belli
              ---IF vr_qtdsuces IN ( 9, 10, 11 ) OR vr_qtdsuces > 20 THEN
              ---  vr_cdcritic := 0 / 0;
              ---END IF;
              
                  -- Quantidade de sucessos incrementada
                  vr_qtdsuces := vr_qtdsuces + 1;
                  -- Atualizar aplicação como conciiada
                  BEGIN
                    UPDATE tbcapt_custodia_aplicacao apl
                       SET apl.idsitua_concilia = 1
                          ,apl.dtconcilia = SYSDATE
                          --,apl.vlpreco_unitario = vr_vlpreco_unit
                     WHERE apl.idaplicacao = rw_aplica.idaplicacao;
                  
              -- Forçado erro - Teste Belli
              ---vr_cdcritic := 0 / 0;
              
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- Acionar log exceções internas
                      CECRED.pc_internal_exception(pr_cdcooper => 3);  
                      -- Erro não tratado
                      vr_cdcritic := 1035;
                      vr_dssqlerr := ' ' || SQLERRM;
                      vr_dsparesp := ', tabela: tbcapt_custodia_conteudo_arq' ||
                                     ', idsitua_concilia = 1';
                      RAISE vr_exc_saida_loop_2;
                  END;
                  
                  -- Atualizar dados do registro conciliado
                  BEGIN
                    UPDATE tbcapt_custodia_conteudo_arq cnt
                       SET cnt.dscodigo_b3 = vr_txretorn(5)
                          ,cnt.idaplicacao = rw_aplica.idaplicacao
                          ,cnt.dscritica   = NULL
                     WHERE cnt.idarquivo   = rw_arq.idarquivo
                       AND cnt.nrseq_linha = rw_cnt.nrseq_linha;
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- Acionar log exceções internas
                      CECRED.pc_internal_exception(pr_cdcooper => 3);  
                      -- Erro não tratado
                      vr_cdcritic := 1035;
                      vr_dssqlerr := ' ' || SQLERRM;
                      vr_dsparesp := ', tabela: tbcapt_custodia_conteudo_arq' ||
                                     ', dscodigo_b3: '||vr_txretorn(5);
                      RAISE vr_exc_saida_loop_2;
                  END;
                END IF;
                
                vr_cdcritic := NULL;
                vr_dscritic := NULL;
                 
              END IF;
              
              -- Controle de execução            
              pc_controle_execução;
              
          
              -- Forçado erro - Teste Belli
             --- vr_cdcritic := 0 / 0;

            EXCEPTION
              WHEN vr_exc_saida_loop_2 THEN
                -- Efetuar retorno do erro nao tratado
                vr_cdcritic := NVL(vr_cdcritic,0);
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic) ||
                               ' '  || vr_dssqlerr  ||
                               ' '  || vr_dspartot  ||
                               ' '  || vr_dsparlp1  ||
                               ' '  || vr_dsparlp2  ||
                               ' '  || vr_dsparlp3  ||
                               ' '  || vr_dsparlp4  ||
                               ' '  || vr_dsparlp5  ||
                               ' '  || vr_dsparesp;               
                -- Log de erro de execucao
                pc_log(pr_cdcritic => vr_cdcritic
                      ,pr_dscrilog => vr_dscritic
                      );
                vr_cdcritic := NULL;
                vr_dscritic := NULL;                
                -- Controle maximo de criticas por Arquivo
                IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
                  RAISE vr_exc_saida_loop_1;
                END IF;  
              WHEN OTHERS THEN
                -- Acionar log exceções internas
                CECRED.pc_internal_exception(pr_cdcooper => 3);  
                -- Efetuar retorno do erro nao tratado
                vr_cdcritic := 9999;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                               '. ' || SQLERRM      ||    
                               '. ' || vr_dspartot  ||
                               ' '  || vr_dsparlp1  ||
                               ' '  || vr_dsparlp2  ||
                               ' '  || vr_dsparlp3  ||
                               ' '  || vr_dsparlp4  ||
                               ' '  || vr_dsparlp5  ||
                               ' '  || vr_dsparesp;                                
                -- Log de erro de execucao
                pc_log(pr_cdcritic => vr_cdcritic
                      ,pr_dscrilog => vr_dscritic);
                vr_cdcritic := NULL;
                vr_dscritic := NULL;                       
                -- Controle maximo de criticas
                IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
                  RAISE vr_exc_saida_loop_1;
                END IF;  
            END;  
            END LOOP;
            
            -- Exclusao do cursor cr_aplica_sem_concil - BELLI / ANDERSON 18/04/2019
            
            -- Gerar LOG após processar todas as linhas retornadas daquele arquivo
            BEGIN
              INSERT INTO TBCAPT_CUSTODIA_LOG
                         (idarquivo
                         ,dtlog
                         ,dslog)
                   VALUES(rw_arq.idarquivo
                         ,SYSDATE
                         ,'Arquivo '||rw_arq.nmarquivo||' conciliado com:'||vr_dscarque||
                          'Quantidade de Erros: '||vr_qtderros||vr_dscarque||
                          'Quantidade de Sucessos: '||vr_qtdsuces||vr_dscarque||
                          --'QUantidade de Aplicações ausentes no arquivo: '||vr_qtdausen||vr_dscarque||
                          'Total de linhas processadas:'||(vr_qtdsuces+vr_qtderros));
            EXCEPTION
              WHEN OTHERS THEN
                -- Acionar log exceções internas
                CECRED.pc_internal_exception(pr_cdcooper => 3);  
                -- Erro não tratado
                vr_cdcritic := 1034;
                vr_dssqlerr := ' ' || SQLERRM;
                vr_dscritic := ', tabela tbcapt_custodia_log ' ||
                               ', Quantidade de Erros: '   ||vr_qtderros||
                               ', Quantidade de Sucessos: '||vr_qtdsuces;
                RAISE vr_exc_saida_loop_1;
            END;
          END IF;
          -- Atualizaremos o arquivo de retorno
          BEGIN
            UPDATE tbcapt_custodia_arquivo arq
               SET arq.idsituacao = 1           -- Processado
                  ,arq.dtregistro = vr_dtmvtolt -- DAta Ref Arquivo
                  ,arq.dtprocesso = SYSDATE     -- Momento do Processo
             WHERE arq.idarquivo = rw_arq.idarquivo;
          EXCEPTION
            WHEN OTHERS THEN
                -- Acionar log exceções internas
                CECRED.pc_internal_exception(pr_cdcooper => 3);  
              -- Erro não tratado
              vr_cdcritic := 1035;
              vr_dssqlerr := ' ' || SQLERRM;
              vr_dscritic := ', tabela: tbcapt_custodia_arquivo ' ||
                             ', idsituacao: 1' ||
                             ', dtregistro: '  || vr_dtmvtolt;
              RAISE vr_exc_saida_loop_1;
          END;
          -- Belli -- Caso tenha registro com sucesso, vai gerar arquivo com esse registros 
          IF vr_qtdsuces > 0 THEN
            vr_inconcil := 'S';
          ELSE
            vr_inconcil := 'N';
          END IF;
          -- Após processar o arquivo, se houve algum erro
          ---IF vr_qtderros > 0 THEN
             -- Enviar as informações por Email
             pc_envia_email_alerta_arq(pr_dsdemail  => pr_dsdemail      --> Destinatários
                                      ,pr_dsjanexe  => pr_dsjanexe      --> Descrição horário execução
                                      ,pr_idarquivo => rw_arq.idarquivo --> ID do arquivo
                                      ,pr_dsdirbkp  => pr_dsdirbkp      --> Caminho de backup linux
                                      ,pr_dsredbkp  => pr_dsredbkp      --> Caminho da rede de Backup
                                      ,pr_flgerrger => vr_flerrger      --> erro geral do arquivo
                                      ,pr_idcritic  => vr_idcritic      --> Criticidade da saida
                                      ,pr_cdcritic  => vr_cdcritic      --> Código da critica
                                      ,pr_dscritic  => vr_dscritic);    --> Descrição da critica
            -- Em caso de erro
            IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida_conciliacao_1;
            END IF;
          ---END IF;
          -- Enviar ao LOG resumo da execução
          IF vr_qtderros + vr_qtdsuces > 0 THEN
            pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char ||
                        'Arquivo '||rw_arq.nmarquivo||' conciliado com:'||vr_dscarque||
                        'Quantidade de Erros: '||vr_qtderros||vr_dscarque||
                        'Quantidade de Sucessos: '||vr_qtdsuces||vr_dscarque||
                        -- BELLI / ANDERSON 18/04/2019
                        --'QUantidade de Aplicações ausentes no arquivo: '||vr_qtdausen||vr_dscarque||
                        'Total de linhas processadas:'||(vr_qtdsuces+vr_qtderros);
          END IF;
          
          -- Forçado náo gravar - Teste Belli
          -- Gravar a cada arquivo com sucesso
         --- COMMIT; -- -- Anderson
                    
          -- Sair se processou a quantidade máxima de arquivos por execução
          IF vr_qtdaruiv >= vr_qtdexjob THEN
            EXIT;
          END IF;  

        EXCEPTION
          WHEN vr_exc_saida_loop_1 THEN
            -- Controle maximo de criticas e vem do Loop interior 2 
            IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr AND  
               vr_cdcritic IS NULL        AND 
               vr_dscritic IS NULL            THEN
              RAISE vr_exc_saida_conciliacao_2;
            END IF;                         
            -- Efetuar retorno do erro tratado
            vr_cdcritic := NVL(vr_cdcritic,0);
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || 
                           vr_dssqlerr ||    
                           '. ' || vr_dspartot  ||
                           '. ' || vr_dsparlp1  ||
                           '. ' || vr_dsparesp
                           ;
            pr_idcritic := 1; -- Media                                      
            -- Log de erro de execucao
            pc_log(pr_cdcritic => vr_cdcritic
                  ,pr_dscrilog => vr_dscritic
                  ,pr_cdcricid => pr_idcritic); 
            -- Controle maximo de criticas
            IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
              RAISE vr_exc_saida_conciliacao_2;
            END IF;  
            vr_cdcritic := NULL;
            vr_dscritic := NULL;
          WHEN OTHERS THEN
            -- Acionar log exceções internas
            CECRED.pc_internal_exception(pr_cdcooper => 3);  
            -- Efetuar retorno do erro nao tratado
            vr_cdcritic := 9999;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                           ' ' || SQLERRM      ||
                           ' ' || vr_dspartot  ||
                           ' ' || vr_dsparlp1;
            pr_idcritic := 2; -- Alta                                    
            -- Log de erro de execucao
            pc_log(pr_cdcritic => vr_cdcritic
                  ,pr_dscrilog => vr_dscritic
                  ,pr_cdcricid => pr_idcritic);  
            vr_cdcritic := NULL;
            vr_dscritic := NULL;                    
            -- Controle maximo de criticas
            IF ( vr_ctcritic - vr_ctcri_ant ) > vr_qtlimerr THEN
              RAISE vr_exc_saida_conciliacao_2;
            END IF;  
        END;  
        END LOOP;

        -- Se encontrou o arquivo correto da conciliação
        IF vr_flgconcil THEN
          vr_cdacesso := 'DAT_CONCILIA_CUSTODIA_B3';
          BEGIN
            -- Atualizamos o registro que indica quando ocorreu a ultima conciliação com sucesso
            UPDATE crapprm
              SET dsvlrprm = to_char(trunc(SYSDATE),'dd/mm/rrrr')
            WHERE nmsistem = 'CRED'
             AND cdcooper = 0
             AND cdacesso = vr_cdacesso;
          EXCEPTION            
            WHEN OTHERS THEN
                -- Acionar log exceções internas
                CECRED.pc_internal_exception(pr_cdcooper => 3);  
              -- Erro não tratado
              vr_cdcritic := 1035;
              vr_dssqlerr := ' ' || SQLERRM;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                             vr_dssqlerr ||
                             ', tabela: crapprm'    ||
                             ', cdacesso:'  || vr_cdacesso    ||
                             ', dtregistro:'|| vr_dtmvtolt    ||
                             ', dtprocesso:'|| TRUNC(SYSDATE) ||
                             ', '  || vr_dspartot;
              pr_idcritic := 2; -- Alta                                    
              -- Log de erro de execucao
              pc_log(pr_cdcritic => vr_cdcritic
                    ,pr_dscrilog => vr_dscritic
                    ,pr_cdcricid => pr_idcritic);    
              RAISE vr_exc_saida_conciliacao_2;
          END;
          -- Forçado náo gravar - Teste Belli
          -- Gravar
          ---COMMIT;
          
        END IF;
      ELSE
        vr_cdcritic := 1480; -- Nenhuma Conciliação será efetuada pois a opção está Desativada ou já foi efetuada no dia
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        -- Controle Entrada  
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                            '. '  || vr_dspartot ||
                            '. '  || vr_dscritic ||
                            '. '  || vr_dsassunt
              );  
        vr_cdcritic := NULL;
        vr_dscritic := NULL;
      END IF;

      -- Forçado erro - Teste Belli
      ---vr_cdcritic := 0 / 0;
    
      -- Controle Entrada  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201)||'. Finalizado'||'. '||vr_dspartot 
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            ); 

    EXCEPTION
      WHEN vr_exc_saida_conciliacao_2 THEN   
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN vr_exc_saida_conciliacao_1 THEN
        vr_cdcritic := NVL(vr_cdcritic,0);
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic) || vr_dspartot;
        pr_idcritic := 1; -- Media
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic
              ,pr_cdcricid => pr_idcritic);    
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Acionar log exceções internas
        CECRED.pc_internal_exception(pr_cdcooper => 3);
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' ' || SQLERRM || ' ' || vr_dspartot;  
        pr_idcritic := 2; -- Alta                  
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic
              ,pr_cdcricid => pr_idcritic);    
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_processa_conciliacao;
  
  -- Rotina para processar retorno de conciliação pendentes de processamento
  PROCEDURE pc_processo_controle(pr_tipexec   IN NUMBER       --> Tipo da Execução
                                ,pr_dsinform OUT CLOB     --> Descrição de informativos na execução
                                ,pr_dscritic OUT VARCHAR2) IS --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc processo controle
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 03/04/2019
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Acionado via JOB
    -- Objetivo  : Esta rotina será encarregada de controlar todo o Workflow
    --             das remessas para Custódia das Aplicações no B3.
    --
    --             A mesma só será executada de 2ª a 6ª.
    --
    --             Em resumo, o processo irá gerar as remessas pendentes caso ainda
    --             não existam, e apóps buscar as mesmas e gerar os arquivos para
    --             envio do Registro e Operação no B3.
    --
    --             Haverá também a busca e processamento dos arquivos de retorno
    --             e dos arquivos de Conciliações Diárias
    --
    --             pr_tipexec: 0 - Tudo
    --                         1 - Conciliação do dia anterior
    --                         2 - Envio dos Lançamentos Pendentes
    --                         3 - Retorno de Lançamentos PEndentes
    --                         4 - Monitora retorno  de arquivos
    --
    --             pc_checar_zips_recebe_cd     - 0 e 1 - pc_checar_recebe_cd
    --             pc_checar_recebe_cd          - 0 e 1
    --             pc_processa_conciliacao      - 0 e 1
    --
    --             pc_verifi_lanctos_custodia   - 0 e 2
    --             pc_gera_arquivos_envio       - 0 e 2
    --             pc_processa_envio_arquivos   - 0 e 2 - pc_envia_arquivo_cd
    --
    --             pc_checar_recebe_cd          - 0 e 3
    --             pc_processa_retorno_arquivos - 0 e 3
    --
    --             pc_monitora_retorno_arquivos - 0 e 4
    --
    -- Alteracoes:
    --          18/10/2018 - P411 - Inclusão de tags para monitoramento (Daniel - Envolti)
    --
    --          07/12/2018 - P411 - Passagem de parametros de caminhos de Backup windows (Marcos-Envolti)
    --    
    --          03/04/2019 - Projeto 411 - Fase 2 - Parte 2 - Conciliação Despesa B3 e Outros Detalhes
    --                       Ajusta mensagens de erros e trata de forma a permitir a monitoração automatica.
    --                       Procedimento de Log - tabela: tbgen prglog ocorrencia 
    --                      (Envolti - Belli - PJ411_F2_P2)
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      --
      vr_exc_saida_prc_crt_1 EXCEPTION;
      vr_exc_saida_prc_crt_2 EXCEPTION;
      -- Parâmetros      
      vr_dsdaviso VARCHAR2(32767); --> Variaveis para retornar avisos durante o processo
      vr_hriniprc DATE;           --> Horário Inicial da Janela de Processamento
      vr_hrfimprc DATE;           --> Horário Final da Janela de Processamento
      vr_dsdircnd VARCHAR2(1000); --> Diretório Raiz do Connect Direct
      vr_dsdirbkp VARCHAR2(1000); --> Diretório Backup Connect Direct
      vr_dsredbkp VARCHAR2(1000); --> Diretório Backup Connect Direct pelo caminho Windows
      vr_dsdemail VARCHAR2(1000); --> Lista de destinatários
      vr_dsjanexe VARCHAR2(1000); --> Texto com os horários da janela de execução
      vr_flenvreg VARCHAR2(1); --> Flag de Envio do Registro das Aplicações
      vr_flenvrgt VARCHAR2(1); --> Flag de Envio do Resgate das Aplicações
      vr_flprccnc VARCHAR2(1); --> Flag de Processamento da Conciliação das Aplicações
      vr_dtultcnc  DATE;        --> DAta da ultima conciliação
      vr_dtultenv1 DATE;        --> DAta da ultimo envio1
      vr_dtultenv2 DATE;        --> DAta da ultimo envio2
      vr_dtultenv3 DATE;        --> DAta da ultimo envio3
      --vr_tag_hora varchar2(14) := to_char(sysdate, 'yyyymmddhh24miss');
      -- Busca do calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
    PROCEDURE pc_trata_fim
    IS
    BEGIN
      -- Se arquivo de critica aberto, então fecha 
      IF vr_inabr_arq_cri_pro_con     THEN 
        pc_fecha_arquivo(vr_dshan001_critic);
        vr_inabr_arq_cri_pro_con := false;
      END IF;      
        
      -- Se arquivo de mensagem aberto, então fecha 
      IF vr_inabr_arq_msg_pro_con     THEN 
        pc_fecha_arquivo(vr_dshan001_msg);
        vr_inabr_arq_msg_pro_con := false;
      END IF;      
      
      ROLLBACK;
      -- 
      vr_dslisane := vr_nmdir001_critic || vr_nmarq001_critic || ',' ||
                     vr_nmdir001_msg    || vr_nmarq001_msg;
     
      IF vr_ctcritic > 0 OR 
         vr_ctmensag > 0 THEN
        vr_fgtempro := TRUE;
      END IF;
      
      pc_monta_e_mail;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
      
      -- Após Rollback anterior vai gravar a geração de e-mail no Oracle
      COMMIT;
    
      -- Controle Entrada  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            ' Fim - pc_processo_controle' ||  
                            ' '      || vr_dsassunt ||
                            ' '      || vr_nmaction ||
                            ' '      || vr_dsparame 
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            ); 
    END pc_trata_fim;
    --
    -- Rotina para tratar fim Ok
    PROCEDURE pc_fim_ok
    IS
      vr_aux VARCHAR2 (100);
    BEGIN
      vr_aux := 'Finalização da execução do processo controlador.';
      -- Finalizando LOG
      pr_dsinform := pr_dsinform || '<br><br>' || fn_get_time_char || vr_aux;
      -- Enviar para o arquivo de LOG o texto informativo montado, quebrando a cada 3900 caracteres para evitar estouro de variável na pc_gera_log_batch
      vr_cdcritic := 1201;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                              ' ' || pr_dsinform ||
                              ' ' || vr_dsparame;
      if length(vr_dscritic) <= 3850 then
        -- Enviar para o arquivo de LOG o texto informativo montado
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic
              ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
              ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
              ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
              );
      else
          for i in 1..trunc(length(pr_dsinform)/3850)+1 loop
            pc_log(pr_cdcritic => vr_cdcritic
                  ,pr_dscrilog => substr(vr_dscritic, (i-1) * 3850 + 1, 3850)
                  ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                  ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                  ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                  );
          end loop;
      end if;
      
      vr_cdcritic := NULL;
      vr_dscritic := NULL;
      -- Incluir tag para monitoramento do jo
      -- Belli retirado controle pois coloquei no final mesmo ...   
            
      IF ( NVL(vr_ctcritic,0) +  NVL(vr_ctmensag,0)) = 0 THEN
          vr_dsassunt := 'Processamento com Sucesso - B3';
          vr_dscorpo  := vr_dstagque || vr_dstagque ||
                         'Show!!!'|| vr_dstagque || vr_dstagque ||
                         'Vamos lá !!!';
        ELSE
          vr_dsassunt := 'Criticas no Processamento - B3';
          vr_dscorpo  := 'Verifique as criticas e mensagens no anexo e acione o atendimento !!!' || vr_dstagque ||
                         'Quantidade de criticas:  '  || vr_ctcritic || vr_dstagque ||
                         'Quantidade de mensagens:  ' || vr_ctmensag || vr_dstagque ||
                         pr_dsinform || vr_dstagque || vr_dstagque ||
                         'Vamos lá !!!';
      END IF;
      
      pc_trata_fim;
    END pc_fim_ok;
    --
    -- Rotina para tratar não fim Ok  
    PROCEDURE pc_fim_nao_ok
    IS
    BEGIN
      vr_dsassunt := 'Criticas no Processamento - B3';
      vr_dscorpo  := 'Verifique as criticas e mensagens no anexo e acione o atendimento !!!' || vr_dstagque ||
                     'Quantidade de criticas:  '  || vr_ctcritic || vr_dstagque ||
                     'Quantidade de mensagens:  ' || vr_ctmensag || vr_dstagque ||
                     pr_dsinform || vr_dstagque || vr_dstagque ||
                     'Vamos lá !!!';
      pc_trata_fim;
    END pc_fim_nao_ok;                
    --
    -- Rotina para tratar não fim Ok  
    PROCEDURE pc_trata_envio
    IS
    BEGIN
      IF vr_dtultenv1 IS NULL OR  
         vr_dtultenv2 IS NULL OR 
         vr_dtultenv3 IS NULL   THEN
        -- Gera critica e continua
        NULL;
      ELSE
        IF vr_dtultenv1 < rw_crapdat.dtmvtolt   THEN
          -- processo já executado não repete e continua
          NULL;
        ELSE
                vr_ctcri_ant := vr_ctcritic;
                -- Acionar o processo de busca dos registros pendentes de evnio
                pc_verifi_lanctos_custodia(pr_flenvreg => vr_flenvreg --> Flag de Envio do Registro das Aplicações
                                          ,pr_flenvrgt => vr_flenvrgt --> Flag de Envio do Resgate das Aplicações
                                          ,pr_dsdaviso => vr_dsdaviso
                                          ,pr_idcritic => vr_idcritic
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
                -- Incrementamos os alertas devolvidos para propagarmos na saida desta rotina
                vr_ctcri_fase := vr_ctcritic - vr_ctcri_ant;              
                pr_dsinform := pr_dsinform || vr_dscarque || vr_dsdaviso ||
                               CASE vr_ctcri_fase WHEN 0 THEN NULL
                               ELSE vr_dscarque || ' *** Quantidade de criticas: ' || vr_ctcri_fase END ||
                               vr_dscarque;
                -- Caso tenhamos recebido algum erro
                IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
                  -- Quando não estivermos na execução total
                  IF pr_tipexec <> 0 THEN
                    RAISE vr_exc_saida_prc_crt_2;
                  END IF;
                END IF;
        END IF;
        --
        IF vr_dtultenv2 < rw_crapdat.dtmvtolt   THEN
          -- processo já executado não repete e continua
          NULL;
        ELSE
                vr_ctcri_ant := vr_ctcritic;
                -- Acionar rotina para geração de arquivos para envio
                pc_gera_arquivos_envio(pr_dsdaviso => vr_dsdaviso
                                      ,pr_idcritic => vr_idcritic
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
                -- Incrementamos os alertas devolvidos para propagarmos na saida desta rotina
                vr_ctcri_fase := vr_ctcritic - vr_ctcri_ant;              
                pr_dsinform := pr_dsinform || vr_dscarque || vr_dsdaviso ||
                               CASE vr_ctcri_fase WHEN 0 THEN NULL
                               ELSE vr_dscarque || ' *** Quantidade de criticas: ' || vr_ctcri_fase END ||
                               vr_dscarque;
                -- Caso tenhamos recebido algum erro
                IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
                  -- Quando não estivermos na execução total
                  IF pr_tipexec <> 0 THEN
                    RAISE vr_exc_saida_prc_crt_2;
                  END IF;
                END IF;
        END IF;
        --
        IF vr_dtultenv3 < rw_crapdat.dtmvtolt   THEN
          -- processo já executado não repete e continua
          NULL;
        ELSE
                vr_ctcri_ant := vr_ctcritic;
                -- Acionar rotina para preparação e envio dos arquivos gerado acima
                pc_processa_envio_arquivos(pr_flenvreg => vr_flenvreg --> Flag de Envio do Registro das Aplicações
                                          ,pr_flenvrgt => vr_flenvrgt --> Flag de Envio do Resgate das Aplicações
                                          ,pr_dsdircnd => vr_dsdircnd
                                          ,pr_dsdirbkp => vr_dsdirbkp
                                          ,pr_dsdaviso => vr_dsdaviso
                                          ,pr_idcritic => vr_idcritic
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
                -- Incrementamos os alertas devolvidos para propagarmos na saida desta rotina
                vr_ctcri_fase := vr_ctcritic - vr_ctcri_ant;              
                pr_dsinform := pr_dsinform || vr_dscarque || vr_dsdaviso ||
                               CASE vr_ctcri_fase WHEN 0 THEN NULL
                               ELSE vr_dscarque || ' *** Quantidade de criticas: ' || vr_ctcri_fase END ||
                               vr_dscarque;
                -- Caso tenhamos recebido algum erro
                IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
                  -- Quando não estivermos na execução total
                  IF pr_tipexec <> 0 THEN
                    RAISE vr_exc_saida_prc_crt_2;
                  END IF;
                END IF;
        END IF;
      --                
      END IF;
      
    END pc_trata_envio ;
    --
    
    BEGIN    --- PRINCIPAL INICIO           
      -- setar ação da rotina e programa - 03/04/2019 - PJ411_F2
      vr_nmaction  := vr_nmpackge || '.pc_processo_controle';
      -- Inclusão do módulo e ação logado - 03/04/2019 - PJ411_F2
      gene0001.pc_informa_acesso(pr_module => null, pr_action => vr_nmaction);
      -- Variavel para setar ação - 03/04/2019 - PJ411_F2
      vr_dsparame := 'pr_tipexec:'   || pr_tipexec;
    
      -- Controle Entrada  
      pc_log(pr_cdcritic => 1201
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                            ' Inicio' ||  
                            ' '      || vr_nmaction ||
                            ' '      || vr_dsparame 
            ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
            ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
            ); 
      vr_intipexe := NVL(pr_tipexec,0);
      
      vr_dsdemail := gene0001.fn_param_sistema('CRED',0,'DES_EMAILS_PROC_B3');
      vr_dsemldst := vr_dsdemail; -- seta e-mail - 03/04/2019 - PJ411_F2

      vr_nmtip001_critic := 'txt';
      vr_nmdir001_critic := vr_dsdirarq;
      vr_nmarq001_critic := '/' || 'CUSAPL_CTR_CRITICA' || 
                     '_' || to_char(SYSDATE, 'MMDD_HH24MISS') ||
                     '_TPEXEC_' || vr_intipexe ||
                      '.'       || vr_nmtip001_critic;

      vr_inabr_arq_cri_pro_con := false;                       
      pc_abre_arquivo(pr_nmarqger => vr_nmarq001_critic
                     ,pr_nmdirger => vr_nmdir001_critic
                     ,pr_dstexcab => 'Código e descrição das criticas'
                     ,pr_dshandle => vr_dshan001_critic) ;
                     
      vr_nmtip001_msg := 'txt';
      vr_nmdir001_msg := vr_dsdirarq;
      vr_nmarq001_msg := '/' || 'CUSAPL_CTR_MSG' || 
                     '_' || to_char(SYSDATE, 'MMDD_HH24MISS') ||
                     '_TPEXEC_' || vr_intipexe ||
                      '.'       || vr_nmtip001_msg;
      vr_inabr_arq_msg_pro_con := false;                             
      pc_abre_arquivo(pr_nmarqger => vr_nmarq001_msg
                     ,pr_nmdirger => vr_nmdir001_msg
                     ,pr_dstexcab => 'Código e descrição das mensagens'
                     ,pr_dshandle => vr_dshan001_msg) ;
                   
      -- Buscar Parâmetros Sistema
      vr_hriniprc := to_date(to_char(sysdate,'ddmmrrrr')||gene0001.fn_param_sistema('CRED',0,'HOR_INICIO_CUSTODIA_B3'),'ddmmrrrrhh24:mi');
      vr_hrfimprc := to_date(to_char(sysdate,'ddmmrrrr')||gene0001.fn_param_sistema('CRED',0,'HOR_FINAL_CUSTODIA_B3'),'ddmmrrrrhh24:mi');
      vr_dsdircnd := gene0001.fn_param_sistema('CRED',0,'NOM_CAMINHO_ARQ_ENVI_B3');
      vr_dsdirbkp := gene0002.fn_busca_entrada(1,gene0001.fn_param_sistema('CRED',0,'NOM_CAMINHO_ARQ_BKP_B3'),';');
      vr_dsredbkp := gene0002.fn_busca_entrada(2,gene0001.fn_param_sistema('CRED',0,'NOM_CAMINHO_ARQ_BKP_B3'),';');
      vr_flenvreg := gene0001.fn_param_sistema('CRED',0,'FLG_ENV_REG_CUSTODIA_B3');
      vr_flenvrgt := gene0001.fn_param_sistema('CRED',0,'FLG_ENV_RGT_CUSTODIA_B3');
      vr_flprccnc := gene0001.fn_param_sistema('CRED',0,'FLG_CONCILIA_CUSTODIA_B3');
      vr_dtultcnc := to_date(gene0001.fn_param_sistema('CRED',0,'DAT_CONCILIA_CUSTODIA_B3'),'dd/mm/rrrr');
      vr_dtultenv1 := to_date(gene0001.fn_param_sistema('CRED',0,'DAT_ENVIA_1_CUSTODIA_B3'),'dd/mm/rrrr');
      vr_dtultenv1 := to_date(gene0001.fn_param_sistema('CRED',0,'DAT_ENVIA_1_CUSTODIA_B3'),'dd/mm/rrrr');
      vr_dtultenv1 := to_date(gene0001.fn_param_sistema('CRED',0,'DAT_ENVIA_1_CUSTODIA_B3'),'dd/mm/rrrr');
      -- Variavel para setar ação - 03/04/2019 - PJ411_F2
      vr_dsparame := 'pr_tipexec:'     || pr_tipexec ||
                     ', vr_hriniprc:'   || vr_hriniprc ||
                     ', vr_hrfimprc:'   || vr_hrfimprc ||
                     ', vr_dsdircnd:'   || vr_dsdircnd ||
                     ', vr_dsdirbkp:'   || vr_dsdirbkp ||
                     ', vr_dsredbkp:'   || vr_dsredbkp ||
                     ', vr_flenvreg:'   || vr_flenvreg ||
                     ', vr_flenvrgt:'   || vr_flenvrgt ||
                     ', vr_flprccnc:'   || vr_flprccnc ||
                     ', vr_dtultcnc:'   || vr_dtultcnc ||
                     ', vr_dtultenv1:'  || vr_dtultenv1 ||
                     ', vr_dtultenv2:'  || vr_dtultenv2 ||
                     ', vr_dtultenv3:'  || vr_dtultenv3;      
      
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
      
      -- Forçado Teste Belli - 03/04/2019 - PJ411_F2
      ---vr_cdcritic := 0 / 0;
            
      vr_inconcil := 'N'; -- Processo geral - 03/04/2019 - PJ411_F2

      ---vr_flprccnc := 'S';  -- remover teste -- Forçado Teste Belli - 03/04/2019 - PJ411_F2

      -- Montar o texto da janela de execução
      vr_dsjanexe := 'das '||to_char(vr_hriniprc,'hh24:mi')||' até as '||to_char(vr_hrfimprc,'hh24:mi');

      -- Esta rotina somente poderá ser executada de 2ª a 6ª
      -- Alem da Duvida de Anderson  IF 1 = 1 THEN
      -- Forçado passagem - Teste Belli - 
      ---IF to_char(SYSDATE,'d') > 0  THEN
      IF to_char(SYSDATE,'d') NOT IN(1,7) THEN
        -- Buscar o calendário
        OPEN btch0001.cr_crapdat(3);
        FETCH btch0001.cr_crapdat
         INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;

        -- Somente executar quando ocorreu virada do dia, estamos em dia útil e sem o processo em execução
        IF rw_crapdat.dtmvtolt = TRUNC(SYSDATE) AND rw_crapdat.inproces = 1 THEN
        vr_hrfimprc := vr_hrfimprc + 1;
        ---IF 1 =1 THEN
          -- Caso estejamos dentro da janela de comunição entre Ayllos X B3
          IF  SYSDATE BETWEEN vr_hriniprc AND vr_hrfimprc THEN
            -- Incluir tag para monitoramento do job -- Belli excluido log por arquivo
            -- Iniciando LOG
            pr_dsinform := fn_get_time_char || 'Iniciando execução do processo controlador '||vr_dscarque
                                            || 'Tipo da Execução : '||pr_tipexec|| ' - '
                                            || CASE pr_tipexec
                                                 WHEN 0 THEN 'Completa'
                                                 WHEN 1 THEN vr_dspro001 -- Retorno da Conciliação da B3
                                                 WHEN 2 THEN vr_dspro002 -- Envio dos Lançamentos a B3
                                                 WHEN 3 THEN vr_dspro003 -- Retorno dos Lançamentos da B3
                                                 WHEN 4 THEN vr_dspro004
                                                 ELSE '*** erro de parâmetro do processo ***'
                                              END;

            -- Se solicitado tudo ou só COnciliação
            IF pr_tipexec IN(0,1) THEN

              vr_ctreg_ok  := 0;
              vr_ctcri_ant := vr_ctcritic;
              -- Busca dos Zips recebidos
              pc_checar_zips_recebe_cd(pr_dsdircnd => vr_dsdircnd
                                      ,pr_dsdirbkp => vr_dsdirbkp
                                      ,pr_dsdaviso => vr_dsdaviso
                                      ,pr_idcritic => vr_idcritic
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
              -- Incrementamos os alertas devolvidos para propagarmos na saida desta rotina
              vr_ctcri_fase := vr_ctcritic - vr_ctcri_ant;              
              pr_dsinform := pr_dsinform || vr_dscarque || vr_dsdaviso ||
                               CASE vr_ctcri_fase WHEN 0 THEN NULL
                               ELSE vr_dscarque || ' *** Quantidade de criticas: ' || vr_ctcri_fase END ||
                               vr_dscarque;
              -- Caso tenhamos recebido algum erro
              IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
                -- Quando não estivermos na execução total
                IF pr_tipexec <> 0 THEN
                  RAISE vr_exc_saida_prc_crt_2;
                END IF;
              END IF;

              vr_ctcri_ant := vr_ctcritic;
              -- Checagem do diretório RECEBE de CONCILIAÇÃO
              pc_checar_recebe_cd(pr_idtiparq => 9
                                 ,pr_dsdirrec => vr_dsdircnd||vr_dsdirrec  --> Diretório dos arquivos compactados
                                 ,pr_dsdirrcb => vr_dsdircnd||vr_dsdirrcb  --> Diretório Recebidos
                                 ,pr_dsdirbkp => vr_dsdirbkp||vr_dsdirrcb  --> Diretório Backup dos arquivos
                                 ,pr_dsdaviso => vr_dsdaviso
                                 ,pr_idcritic => vr_idcritic
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
              -- Incrementamos os alertas devolvidos para propagarmos na saida desta rotina
              vr_ctcri_fase := vr_ctcritic - vr_ctcri_ant;              
              pr_dsinform := pr_dsinform || vr_dscarque || vr_dsdaviso ||
                               CASE vr_ctcri_fase WHEN 0 THEN NULL
                               ELSE vr_dscarque || ' *** Quantidade de criticas: ' || vr_ctcri_fase END ||
                               vr_dscarque;
              -- Caso tenhamos recebido algum erro
              IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
                -- Quando não estivermos na execução total
                IF pr_tipexec <> 0 THEN
                  RAISE vr_exc_saida_prc_crt_2;
                END IF;
              END IF;

              vr_ctcri_ant := vr_ctcritic;
              -- Processamento dos arquivos de conciliação pendentes
              pc_processa_conciliacao(pr_flprccnc => vr_flprccnc --> Conciliação ativa
                                     ,pr_dtultcnc => vr_dtultcnc --> Data Ultima Conciliação
                                     ,pr_dsdemail => vr_dsdemail --> Destinatários
                                     ,pr_dsjanexe => vr_dsjanexe --> Descrição horário execução
                                     ,pr_dsdirbkp => vr_dsdirbkp||'concilia' --> Caminho de backup linux
                                     ,pr_dsredbkp => vr_dsredbkp --> Caminho da rede de Backup
                                     ,pr_dsdaviso => vr_dsdaviso
                                     ,pr_idcritic => vr_idcritic
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
              -- Incrementamos os alertas devolvidos para propagarmos na saida desta rotina
              vr_ctcri_fase := vr_ctcritic - vr_ctcri_ant;              
              pr_dsinform := pr_dsinform || vr_dscarque || vr_dsdaviso ||
                               CASE vr_ctcri_fase WHEN 0 THEN NULL
                               ELSE vr_dscarque || ' *** Quantidade de criticas: ' || vr_ctcri_fase END ||
                               vr_dscarque;
              -- Caso tenhamos recebido algum erro
              IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
                -- Quando não estivermos na execução total
                IF pr_tipexec <> 0 THEN
                  RAISE vr_exc_saida_prc_crt_2;
                END IF;
              END IF;

            END IF;

            -- Se solicitado tudo ou Só Envio
            IF pr_tipexec IN(0,2) THEN
              -- Se conciliação estiver ativa e a ultima conciliação não foi feita no dia
              IF vr_flprccnc = 'S'                AND 
                 vr_dtultcnc < rw_crapdat.dtmvtolt   THEN
                -- Envio só poderá ser feito depois da conciliação do dia
                vr_cdcritic := 1492; -- Não será possível enviar! A conciliação do dia anterior ainda não foi efetuada
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                               ' ' || vr_nmaction ||
                               ' ' || vr_dsparame;
                --     
                pr_dsinform := pr_dsinform ||vr_dscarque|| gene0001.fn_busca_critica(vr_cdcritic);
                -- Log de erro de execucao
                pc_log(pr_cdcritic => vr_cdcritic
                      ,pr_dscrilog => vr_dscritic);
                vr_cdcritic := NULL;
                vr_dscritic := NULL;        
              ELSE
                pc_trata_envio;
              END IF;
            END IF;

            -- Se solicitado tudo ou Só Retornos
            IF pr_tipexec in(0,3) THEN

              vr_ctcri_ant := vr_ctcritic;
              -- Checagem do diretório RECEBE de retornos
              pc_checar_recebe_cd(pr_idtiparq => 5
                                 ,pr_dsdirrec => vr_dsdircnd||vr_dsdirrec  --> Diretório dos arquivos compactados
                                 ,pr_dsdirrcb => vr_dsdircnd||vr_dsdirrcb  --> Diretório Recebidos
                                 ,pr_dsdirbkp => vr_dsdirbkp||vr_dsdirrcb  --> Diretório Backup dos arquivos
                                 ,pr_dsdaviso => vr_dsdaviso
                                 ,pr_idcritic => vr_idcritic
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
              -- Incrementamos os alertas devolvidos para propagarmos na saida desta rotina
              vr_ctcri_fase := vr_ctcritic - vr_ctcri_ant;              
              pr_dsinform := pr_dsinform || vr_dscarque || vr_dsdaviso ||
                             CASE vr_ctcri_fase WHEN 0 THEN NULL
                             ELSE vr_dscarque || ' *** Quantidade de criticas: ' || vr_ctcri_fase END ||
                             vr_dscarque;
              -- Caso tenhamos recebido algum erro
              IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
                  -- Quando não estivermos na execução total
                  IF pr_tipexec <> 0 THEN
                    RAISE vr_exc_saida_prc_crt_2;
                  END IF;
              END IF;

              vr_ctcri_ant := vr_ctcritic;
              -- Processamento dos arquivos de retorno encontratos e pendentes
              pc_processa_retorno_arquivos(pr_dsdemail => vr_dsdemail --> Destinatários
                                          ,pr_dsjanexe => vr_dsjanexe --> Descrição horário execução
                                          ,pr_dsdaviso => vr_dsdaviso
                                          ,pr_idcritic => vr_idcritic
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
              -- Incrementamos os alertas devolvidos para propagarmos na saida desta rotina
              vr_ctcri_fase := vr_ctcritic - vr_ctcri_ant;              
              pr_dsinform := pr_dsinform || vr_dscarque || vr_dsdaviso ||
                             CASE vr_ctcri_fase WHEN 0 THEN NULL
                             ELSE vr_dscarque || ' *** Quantidade de criticas: ' || vr_ctcri_fase END ||
                             vr_dscarque;
              -- Caso tenhamos recebido algum erro
              IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
                  -- Quando não estivermos na execução total
                  IF pr_tipexec <> 0 THEN
                    RAISE vr_exc_saida_prc_crt_2;
                  END IF;
              END IF;

            END IF;
            
            --
            -- Se solicitado tudo ou Só MONITORAMENTO
            IF pr_tipexec in(0,4) THEN
              
              vr_ctcri_ant := vr_ctcritic;
              -- Monitoração para alertar atraso de arquivo
              pc_monitora_retorno_arquivos(pr_dsdemail => vr_dsdemail --> Destinatários
                                          ,pr_dsjanexe => vr_dsjanexe --> Descrição horário execução
                                          ,pr_dsdaviso => vr_dsdaviso
                                          ,pr_idcritic => vr_idcritic
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
              --
              vr_ctcri_fase := vr_ctcritic - vr_ctcri_ant;              
              pr_dsinform := pr_dsinform || vr_dscarque || vr_dsdaviso ||
                             CASE vr_ctcri_fase WHEN 0 THEN NULL
                             ELSE vr_dscarque || ' *** Quantidade de criticas: ' || vr_ctcri_fase END ||
                             vr_dscarque;
              -- Caso tenhamos recebido algum erro
              IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
                -- Quando não estivermos na execução total
                IF pr_tipexec <> 0 THEN
                  RAISE vr_exc_saida_prc_crt_2;
                END IF;
              END IF;

            END IF;
                     
          ELSE
            vr_cdcritic := 1488; -- Operação não realizada! Execução liberada somente
            RAISE vr_exc_saida_prc_crt_1;
          END IF;
        ELSE
          vr_cdcritic := 1489; -- Operação não realizada! Processo em Execução ou Sistema Aimaro não liberado
          vr_dsjanexe := NULL;
          RAISE vr_exc_saida_prc_crt_1;
        END IF;
      ELSE
        vr_cdcritic := 1490; -- Operação não realizada! Execução só será efetuada de 2a a 6a feira
        vr_dsjanexe := NULL;
        RAISE vr_exc_saida_prc_crt_1;
      END IF;
      
      pc_fim_ok;
      
    EXCEPTION
      WHEN vr_exc_saida_prc_crt_2 THEN
        -- Efetuar rollback 
        ROLLBACK;
        -- Passa retorno em e-mail da rotina
        pc_fim_nao_ok;
        -- Após Rollback anterior vai gravar a geração de e-mail no Oracle
        COMMIT;
        -- Devolver criticas        
        pr_dscritic := vr_dscritic;
      WHEN vr_exc_saida_prc_crt_1 THEN
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := NVL(vr_cdcritic,0);
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic) ||
                       ' ' || vr_nmaction ||
                       ' ' || vr_dsparame;
        pr_dsinform := gene0001.fn_busca_critica(vr_cdcritic) || vr_dsjanexe;
        -- Efetuar rollback 
        ROLLBACK;  
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic);
        -- Passa retorno em e-mail da rotina
        pc_fim_nao_ok;
        -- Após Rollback anterior vai gravar a geração de e-mail no Oracle
        COMMIT;
        -- Devolver criticas        
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Acionar log exceções internas
        CECRED.pc_internal_exception(pr_cdcooper => 3);
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                       ' ' || SQLERRM ||
                       ' ' || vr_nmaction ||
                       ' ' || vr_dsparame;
        -- Efetuar rollback 
        ROLLBACK;  
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic);
        -- Passa retorno em e-mail da rotina
        pc_fim_nao_ok;
        -- Após Rollback anterior vai gravar a geração de e-mail no Oracle
        COMMIT;
        -- Devolver criticas        
        pr_dscritic := vr_dscritic;
    END;
  END pc_processo_controle;
  

  -- Executa geração do custo fornecedor aplicação - B3
  PROCEDURE pc_exe_grc_cst_frn_aplica(pr_cdmodulo IN VARCHAR2           -- Cooperativa selecionada (0 para todas)
                                     ,pr_cdcooper IN crapcop.cdcooper%TYPE -- Cooperativa selecionada (0 para todas)
                                     ,pr_nrdconta IN VARCHAR2           -- Conta informada
                                     ,pr_dtde     IN VARCHAR2           -- Data de 
                                     ,pr_dtate    IN VARCHAR2           -- Date até
                                     )
  IS 
  /* ..........................................................................
    
  Procedure: pc exe grc cst frn aplica
  Sistema  : Rotina de aplicações
  Autor    : Belli/Envolti
  Data     : 03/04/2019                        Ultima atualizacao: 
    
  Dados referentes ao programa:  Projeto PJ411_F2_P2  
  Frequencia: Sempre que for chamado
  Objetivo  : Executa geração do custo fornecedor aplicação - B3
    
  Alteracoes: 
    
  ............................................................................. */   
    --
    pr_cdcritic  PLS_INTEGER;       -- Código da crítica
    pr_dscritic  VARCHAR2  (4000);  -- Descrição da crítica
    pr_retxml    XMLType;           -- Arquivo de retorno do XML                        
  
    vr_qtmaxerr  CONSTANT NUMBER     (5)  := 200;
    vr_qttoterr           NUMBER    (25,8):= 0;
    vr_prvlrreg           NUMBER    (25,8);
    vr_dtde               date;
    vr_dtate              date;   
        
    -- Busca saldo       
    cursor cr_cusdev IS
      SELECT 
         s.nrdconta
        ,s.dtmvtolt
        ,SUM(s.vlsaldo_concilia)     vlsalcon
        ,COUNT(*)                    qtlansal
      FROM     tbcapt_saldo_aplica s 
      WHERE    s.dtmvtolt BETWEEN vr_dtde AND vr_dtate
      AND      s.cdcooper = pr_cdcooper
      AND      s.nrdconta = DECODE(NVL(pr_nrdconta,0), 0, s.nrdconta, pr_nrdconta)
      GROUP BY s.nrdconta
              ,s.dtmvtolt 
      ORDER BY s.nrdconta
              ,s.dtmvtolt 
      ;
      
    -- Valor registrado para calcular o fator 2 da formula    
    CURSOR cr_vlrreg IS
      SELECT SUM ( t2.vlaplica )  vlaplica
      FROM    craprda t2 
      WHERE   t2.cdcooper        +0 = pr_cdcooper
      AND     ( NVL(pr_nrdconta,0)         = 0 OR 
                t2.nrdconta      +0 = NVL(pr_nrdconta,0) ) 
      AND     t2.idaplcus IN 
        ( SELECT DISTINCT t1.idaplicacao 
          FROM    tbcapt_custodia_lanctos  t1
          WHERE   t1.dtenvio       BETWEEN vr_dtde AND vr_dtate
          AND     t1.idtipo_lancto = 1
          AND     t1.idsituacao    = 8  )  
      UNION    
      SELECT SUM ( t2.vlaplica )  vlaplica
      FROM    craprac t2 
      WHERE   t2.cdcooper        +0 = pr_cdcooper
      AND     ( NVL(pr_nrdconta,0)         = 0 OR 
                t2.nrdconta      +0 = NVL(pr_nrdconta,0) ) 
      AND     t2.idaplcus IN 
        ( SELECT DISTINCT t1.idaplicacao 
          FROM    tbcapt_custodia_lanctos  t1
          WHERE   t1.dtenvio       BETWEEN vr_dtde AND vr_dtate
          AND     t1.idtipo_lancto = 1
          AND     t1.idsituacao    = 8  ) 
      ;

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;
              
    -- Variaveis gerais
    vr_qtdiauti NUMBER    (2)   := 0;
    vr_vlacucta NUMBER   (25,8) := 0;
    vr_vlmedcta NUMBER   (25,8) := 0;
    vr_vlcusdev NUMBER   (25,8) := 0;
    vr_vlacudev NUMBER   (25,8) := 0;
    vr_vlregist NUMBER   (25,8) := 0;
    vr_vlregtot NUMBER   (25,8) := 0;
    vr_qtdiager NUMBER    (2)   := 0;
    vr_vlsaltot NUMBER   (25,8) := 0;
    
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB; 
    -- Buscar custo fixo para calcular custo devido na conciliação de despesa para B3
    vr_dsvlrprm  VARCHAR2 (100);
    vr_nrdconta  tbcapt_saldo_aplica.nrdconta%TYPE := 0;
    vr_vlcusfix  NUMBER    (25,8) := 0;
    vr_qttabinv  NUMBER     (2)   := 0;
    vr_pctaxmen  NUMBER    (25,8) := 0;
    vr_vladicio  NUMBER    (25,9) := 0;
    vr_idasitua  NUMBER     (1)   := 0;
    -- Variavel para setar ação
    vr_nmaction  VARCHAR2  (100) := vr_nmpackge || '.pc_exe_grc_cst_frn_aplica'; -- Rotina e programa
  
  PROCEDURE pc_trata_retorno
  IS
  BEGIN
    -- Se for rotina 001 e arquivo de critica aberto, então fecha 
    IF vr_inabr_arq_csv_exe_cus     THEN 
        
      pc_fecha_arquivo(vr_dshan001_csv);
      vr_inabr_arq_csv_exe_cus := false;
    END IF;
        
    IF vr_nmarq001_csv IS NOT NULL THEN
      IF vr_dslisane IS NULL THEN
        vr_dslisane := vr_nmdir001_csv || vr_nmarq001_csv;
      ELSE
        vr_dslisane := vr_dslisane || ',' || vr_nmdir001_csv || vr_nmarq001_csv;
      END IF;
    END IF;
    
    -- Se arquivo de critica aberto, então fecha 
    IF vr_inabr_arq_cri_exe_cus     THEN 
      pc_fecha_arquivo(vr_dshan001_critic);
      vr_inabr_arq_cri_exe_cus := false;
    END IF;
        
    IF vr_nmarq001_critic IS NOT NULL THEN
      IF vr_dslisane IS NULL THEN
        vr_dslisane := vr_nmdir001_critic || vr_nmarq001_critic;
      ELSE
        vr_dslisane := vr_dslisane || ',' || vr_nmdir001_critic || vr_nmarq001_critic;
      END IF;
    END IF;
    vr_fgtempro := TRUE;
    pc_monta_e_mail;
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => vr_nmaction);
  END pc_trata_retorno;
  
  PROCEDURE pc_trata_conta 
  IS
    vr_nmrotint  VARCHAR2  (100) := 'pc_trata_conta'; -- Variavel para setar a rotina interna
  BEGIN
    IF vr_qtdiauti > 0 THEN
      -- Saldo medio da conta no perido inteiro
      vr_vlmedcta := vr_vlacucta / vr_qtdiauti;
      -- Aqui busca informac tabela investidor para cada conta
      pc_pos_faixa_tab_investidor(pr_nmmodulo => pr_cdmodulo -- Tela e qual consulta, 48 caractere
                                 ,pr_cdcooper => pr_cdcooper -- Cooperativa selecionada (0 para todas)
                                 ,pr_qttabinv => vr_qttabinv
                                 ,pr_vlentrad => vr_vlmedcta
                                 ,pr_idasitua => vr_idasitua
                                 ,pr_pctaxmen => vr_pctaxmen
                                 ,pr_vladicio => vr_vladicio
                                 ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                 ,pr_dscritic => vr_dscritic);       --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSIF vr_idasitua = 2 THEN
        vr_cdcritic := 891; -- Faixa de valores nao cadastrada
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    
      -- Forçado erro - Teste Belli
      --IF vr_nrdconta = 1503 THEN
      --  vr_cdcritic := 891; -- Faixa de valores nao cadastrada
      --  --Levantar Excecao
      --  RAISE vr_exc_erro;
      --END IF;
          
      -- Retorna do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    END IF;                
    -- Custo devido
    vr_vlcusdev := vr_vlmedcta * vr_pctaxmen;
    -- Aacumular Custo devido para ter o total do periodo e cooper
    vr_vlacudev := vr_vlacudev + vr_vlcusdev;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_qttoterr <= vr_qtmaxerr THEN      
        -- Efetuar retorno do erro não tratado
        vr_cdcritic := NVL(vr_cdcritic,0);
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic) ||
                       vr_nmrotint   ||
                       ', nrdconta:' || vr_nrdconta || 
                       ', qttabinv:' || vr_qttabinv ||
                       ', vlentrad:' || vr_vlmedcta ||
                       ', idasitua:' || vr_idasitua ||
                       ', pctaxmen:' || vr_pctaxmen ||
                       ', vladicio:' || vr_vladicio ||
                       '. ' || vr_dsparame;
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic);
      END IF;
      vr_cdcritic := NULL;
      vr_dscritic := NULL;
      vr_qttoterr := vr_qttoterr + 1;
      -- Retorna do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    WHEN OTHERS THEN
      -- Quando erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
      -- Se passar o limite de erros nem gera mais o Log - Chega ...
      IF vr_qttoterr <= vr_qtmaxerr THEN      
        -- Efetuar retorno do erro não tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                       vr_nmrotint   ||
                       ', nrdconta:' || vr_nrdconta || 
                       ', qttabinv:' || vr_qttabinv ||
                       ', vlentrad:' || vr_vlmedcta ||
                       ', idasitua:' || vr_idasitua ||
                       ', pctaxmen:' || vr_pctaxmen ||
                       ', vladicio:' || vr_vladicio ||
                       '. ' || SQLERRM ||
                       '. ' || vr_dsparame;
        -- Log de erro de execucao
        pc_log(pr_cdcritic => vr_cdcritic
              ,pr_dscrilog => vr_dscritic);  
      END IF;
      vr_cdcritic := NULL;
      vr_dscritic := NULL;
      vr_qttoterr := vr_qttoterr + 1; 
      -- Retorna do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
  END pc_trata_conta; 
  --
  
  PROCEDURE pc_CSV
  IS
  BEGIN
   NULL;
  END pc_CSV;
  --
  
  PROCEDURE pc_consulta
  IS
  BEGIN
   NULL;
  END pc_consulta;
  --
  
  --         PRINCIPAL - INICIO DA ROTINA
  BEGIN
    -- Inclusão do módulo e ação logado
    ---gene0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction );
    gene0001.pc_informa_acesso(pr_module => null, pr_action => vr_nmaction);
    -- Variavel para setar ação - 03/04/2019 - PJ411_F2
    vr_dsparame := ', pr_cdmodulo:' || pr_cdmodulo ||
                   ', pr_cdcooper:' || pr_cdcooper ||
                   ', pr_nrdconta:' || NVL(pr_nrdconta,0) ||
                   ', pr_dtde:'     || pr_dtde     ||   
                   ', pr_dtate:'    || pr_dtate;                   
   -- vr_dtde  := pr_dtde;
    --vr_dtate := pr_dtate;
    
    -- Log de erro de execucao
    pc_log(pr_cdcritic => 1201
          ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201)      ||
                          vr_nmaction ||
                          ' ' || vr_dsparame);  
    
    -- Validar os parâmetros data
    BEGIN
      vr_dtde  := TO_DATE(pr_dtde,  'DD/MM/YYYY');
      vr_dtate := TO_DATE(pr_dtate, 'DD/MM/YYYY');
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 13; -- Data errada
        RAISE vr_exc_erro;
    END;

    -- Se enviada as duas datas, temos de validar se até não é inferior a De
    IF vr_dtde > vr_dtate THEN
      vr_cdcritic := 1233; -- Data inicial deve ser menor ou igual a final:
      RAISE vr_exc_erro;
    END IF;

    vr_nmtip001_csv := 'csv';
    vr_nmdir001_csv := vr_dsdirarq;
    vr_nmarq001_csv := '/' || 'CUSAPL_CLC_INF'     || 
                       '_CP' || NVL(pr_cdcooper,'0') ||
                       '_CT' || NVL(pr_nrdconta,'0') ||
                       '_'   || NVL(SUBSTR(pr_dtde, 7, 4 ) ||
                                    SUBSTR(pr_dtde, 4, 2 ) ||
                                    SUBSTR(pr_dtde, 1, 2 ),  '0') ||
                       '_A_' || NVL(SUBSTR(pr_dtate, 7, 4 ) ||
                                    SUBSTR(pr_dtate, 4, 2 ) ||
                                    SUBSTR(pr_dtate, 1, 2 ), '0') ||
                       '.'   || vr_nmtip001_csv;
    pc_abre_arquivo(pr_nmarqger => vr_nmarq001_csv
                   ,pr_nmdirger => vr_nmdir001_csv
                   ,pr_dstexcab => 'Detalhes lista de custo'
                   ,pr_dshandle => vr_dshan001_csv);  
    vr_inabr_arq_csv_exe_cus := true;       
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);  
 
    vr_nmtip001_critic := 'txt';
    vr_nmdir001_critic := vr_dsdirarq;
    vr_nmarq001_critic := 
                   '/'   || 'CUSAPL_CLC_CRI'     || 
                   '_CP' || NVL(pr_cdcooper,'0') ||
                   '_CT' || NVL(pr_nrdconta,'0') ||
                   '_'   || NVL(SUBSTR(pr_dtde, 7, 4 ) ||
                                SUBSTR(pr_dtde, 4, 2 ) ||
                                SUBSTR(pr_dtde, 1, 2 ),  '0') ||
                   '_A_' || NVL(SUBSTR(pr_dtate, 7, 4 ) ||
                                SUBSTR(pr_dtate, 4, 2 ) ||
                                SUBSTR(pr_dtate, 1, 2 ), '0') ||
                   '_'   || TO_CHAR(SYSDATE,'DD HH24MISS') ||
                   '.'   || vr_nmtip001_critic;
                    
    pc_abre_arquivo(pr_nmarqger => vr_nmarq001_critic
                   ,pr_nmdirger => vr_nmdir001_critic
                   ,pr_dstexcab => 'Código e descrição das criticas'
                   ,pr_dshandle => vr_dshan001_critic) ;
    vr_inabr_arq_cri_exe_cus := true;  
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    
    -- Forçado erro - Teste Belli - 001
    -- vr_cdcritic := 0 / 0;
    
    -- Forçado erro - Teste Belli - 002
   -- pc_log(pr_cdcritic => 44
   --       ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 44) || 
   --                        vr_nmaction ||
   --                       '. ' || vr_dsparame);   
      
    IF NVL(pr_cdcooper,0) IN ( 0 , 3 ) THEN
      vr_cdcritic := 794; -- Cooperativa Invalida
      RAISE vr_exc_erro;
    END IF;
    
    -- Fator 1 - Buscar custo fixo para calcular custo devido na conciliação de despesa para B3
    vr_cdacesso := 'CUSTO_FIXO_CCL_DSP_FRN';
    vr_dsvlrprm := gene0001.fn_param_sistema('CRED', pr_cdcooper, vr_cdacesso);
    IF vr_dsvlrprm IS NULL THEN
      vr_cdcritic := 1230; -- Registro de parametro não encontrado
      vr_dsparame := vr_dsparame || ', vr_cdacesso:' || vr_cdacesso;
      RAISE vr_exc_erro;
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    --
    vr_vlcusfix := TO_NUMBER(vr_dsvlrprm);
    
    -- Buscar custo fixo para calcular custo devido na conciliação de despesa para B3
    vr_cdacesso := 'PERC_VLR_REG_CCL_DSP_FRN';
    vr_dsvlrprm := gene0001.fn_param_sistema('CRED', pr_cdcooper ,vr_cdacesso);
    IF vr_dsvlrprm IS NULL THEN
      vr_cdcritic := 1230; -- Registro de parametro não encontrado
      vr_dsparame := vr_dsparame || ', vr_cdacesso:' || vr_cdacesso;
      RAISE vr_exc_erro;
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    --
    vr_prvlrreg := TO_NUMBER(vr_dsvlrprm);
    --
    vr_dtdiaapl := 0;
    vr_tab_diavlr.DELETE;    
    vr_dtini    := TO_CHAR(vr_dtde, 'YYYYMMDD');
    vr_dtfim    := TO_CHAR(vr_dtate,'YYYYMMDD');
    
    IF vr_dtini IS NULL OR vr_dtfim IS NULL THEN
      vr_cdcritic := 13; -- 013 - Data errada.
      vr_dsparame := vr_dsparame || 
                     ', vr_dtde:'  || vr_dtde  ||
                     ', vr_dtate:' || vr_dtate ||
                     ', TO_CHAR(vr_dtde, YYYYMMDD):' || TO_CHAR(vr_dtde, 'YYYYMMDD')  ||
                     ', TO_CHAR(vr_dtate,YYYYMMDD):' || TO_CHAR(vr_dtate,'YYYYMMDD')  ||
                     ', vr_dtini:' || vr_dtini ||
                     ', vr_dtfim:' || vr_dtfim
                     ;
      RAISE vr_exc_erro;
      
    END IF;
    
    -- Log 
    pc_log(pr_cdcritic => 1201
          ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201)      ||
                          vr_nmaction ||
                          ', vr_dtdiaapl:' || vr_dtdiaapl ||
                          ', vr_dtfim:' || vr_dtfim ||
                          ', vr_dtini:' || vr_dtini ||
                          ', ' || vr_dsparame);  
    -- Iniciliza o valor por dia
    FOR vr_dtdiaapl IN vr_dtini..vr_dtfim LOOP
      vr_tab_diavlr(vr_dtdiaapl).vlacudia := 0;
    END LOOP;
     
    pc_conciliacao_tab_investidor(pr_cdmodulo -- Tela e qual consulta, 48 caractere
                                 ,pr_cdcooper -- Cooperativa selecionada (0 para todas)
                                 ,pr_qttabinv => vr_qttabinv
                                 ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                 ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 

    -- Monta documento XML 
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
    -- Gerar a estrutura do XML 
    GENE0002.pc_escreve_xml
       (pr_xml            => vr_clob
       ,pr_texto_completo => vr_xml_temp
       ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?>' ||
                             '<Root><dados><listacusdev qtdiager="0">');    
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 

    -- Retornar os arquivos conforme filtros informados
    FOR rw_cusdev IN cr_cusdev LOOP 
    BEGIN
      -- Custo Devido por conta
      IF vr_nrdconta = 0 THEN
        vr_nrdconta := rw_cusdev.nrdconta;
      ELSE
        IF vr_nrdconta <> rw_cusdev.nrdconta THEN
          
          pc_trata_conta;
    
          IF NVL(pr_nrdconta,0) = 0 THEN
            --vr_qtdiauti := 0;
            vr_vlmedcta := 0;
            vr_pctaxmen := 0;
            vr_vladicio := 0;
            vr_nrdconta := rw_cusdev.nrdconta;
          END IF;
        END IF;
      END IF;
      
      -- Acumular valor por dia  
      vr_dtdiaapl := TO_CHAR(rw_cusdev.dtmvtolt,'YYYYMMDD');
      vr_vlacudia := rw_cusdev.vlsalcon;
      -- vr_tab_diavlr(lpad(vr_dtdiaapl, 2, '0')).vlacudia := 25;
      vr_tab_diavlr(vr_dtdiaapl).vlacudia := vr_tab_diavlr(vr_dtdiaapl).vlacudia + vr_vlacudia;
      
      -- Dias uteis por conta 
      vr_qtdiauti := vr_qtdiauti + 1;
      vr_vlacucta := vr_vlacucta + vr_vlacudia;

    EXCEPTION
      WHEN OTHERS THEN
        -- Quando erro de programa gravar tabela especifica de log
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        -- Se passar o limite de erros nem gera mais o Log - Chega ...
        IF vr_qttoterr <= vr_qtmaxerr THEN      
          -- Efetuar retorno do erro não tratado
          vr_cdcritic := 9999;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         '. ' || SQLERRM ||
                         '. ' || vr_dsparame;
          -- Log de erro de execucao
          pc_log(pr_cdcritic => vr_cdcritic
                ,pr_dscrilog => vr_dscritic);  
        END IF;
        vr_cdcritic := NULL;
        vr_dscritic := NULL;
        vr_qttoterr := vr_qttoterr + 1;
        -- Retorna do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
      END;      
    END LOOP;
    
    -- Ultima conta busca informação da tabela investidor
    pc_trata_conta;   
    
    -- Fator 2
    FOR rw_vlrreg IN cr_vlrreg LOOP
      vr_vlregist := NVL(vr_vlregist, 0) + NVL(rw_vlrreg.vlaplica, 0);
    END LOOP;
    
    vr_vlregtot := vr_vlregist * vr_prvlrreg;
    
    -- Fator 3
    -- Montar os dias e valores acumulados para a saida
    FOR vr_dtdiaapl IN vr_dtini..vr_dtfim LOOP
      IF vr_tab_diavlr(vr_dtdiaapl).vlacudia > 0 THEN
        
        vr_qtdiager := vr_qtdiager + 1;
        --vr_dtdiaapl := vr_dtdiaapl + 1;
        --dbms_output.put_line('Dia:' || vr_dtdiaapl  || ' - valor:'  ||  vr_tab_diavlr(vr_dtdiaapl).vlacudia );

        vr_dslinha :=  SUBSTR(vr_dtdiaapl, 7, 8) || '/' ||
                       SUBSTR(vr_dtdiaapl, 5, 2) || '/' ||
                       SUBSTR(vr_dtdiaapl, 1, 4);
        -- Carrega os dados
        GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '<dia>'||
                              '<dtmvtolt>' || vr_dslinha  || '</dtmvtolt>'||
                              '<vlsalcon>' || vr_tab_diavlr(vr_dtdiaapl).vlacudia ||'</vlsalcon>'||
                              '</dia>');
        -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
        
        -- BELLAO8
        pc_grava_linha(pr_nmarqger => vr_nmarq001_csv
                      ,pr_nmdirger => vr_nmdir001_csv
                      ,pr_utlfileh => vr_dshan001_csv
                      ,pr_des_text => vr_dslinha || ';' ||
                                      vr_tab_diavlr(vr_dtdiaapl).vlacudia
                      );
      
      END IF;
    END LOOP;  
    
    -- Valor devido final 
    vr_vlsaltot :=   vr_vlcusfix -- Fator 1
                   + vr_vlregtot -- Fator 2
                   + vr_vlacudev -- Fator 3
                   ;
                   /*
    dbms_output.put_line( 'vr_vlcusfix:' || vr_vlcusfix  || 
                        ', vr_vlregtot:' || vr_vlregtot  || 
                        ', vr_vlacudev:' || vr_vlacudev  ||
                        ',<qtdiauti>' || vr_qtdiauti || -- Dias Uteis - Só por conta
                        ',<vlsalmed>' || vr_vlmedcta || -- Base Volume - Só por conta
                        ',<prtaxmen>' || vr_pctaxmen || -- Taxa Mensal - Só por conta
                        --
                        ',<vladicio>' || vr_vladicio || -- Valor Adicional - Só por conta
                        ',<vltotadi>' || vr_vlacudev || -- Valor Devido Parcial - Fator 3
                              ---                     
                        ',<vlcusfix>' || vr_vlcusfix || -- Valor fixo - Fator 1 
                        ',<vlregist>' || vr_vlregtot || -- Valor registrado - Fator 2 
                        ',<vlsaltot>' || vr_vlsaltot || -- Valor Devido Total
                              --
                        ',<prvlrreg>' || vr_prvlrreg    -- Percentual - Fator 2
                        ); */

    
    IF NVL(pr_nrdconta,0) = 0 THEN
      --vr_qtdiauti := 0;
      vr_vlmedcta := 0;
      vr_pctaxmen := 0;
      vr_vladicio := 0;
      
      vr_qtdiauti := vr_qtdiager;
            
    END IF;
        
    -- Carrega os "Dados  Finais"
    GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '</listacusdev><dadosfinais>'||
                              '<qtdiauti>' || vr_qtdiauti ||'</qtdiauti>'|| -- Dias Uteis - Só por conta
                              '<vlsalmed>' || TRUNC(vr_vlmedcta,2) ||'</vlsalmed>'|| -- Base Volume - Só por conta
                              --
                              '<prtaxmen>' || vr_pctaxmen ||'</prtaxmen>'|| -- Taxa Mensal - Só por conta
                              '<vladicio>' || vr_vladicio ||'</vladicio>'|| -- Valor Adicional - Só por conta
                              '<vltotadi>' || TRUNC(vr_vlacudev,2) ||'</vltotadi>'|| -- Valor Devido Parcial - Fator 3
                              ---                             
                              '<vlcusfix>' || vr_vlcusfix ||'</vlcusfix>'|| -- Valor fixo - Fator 1 
                              '<vlregist>' || TRUNC(vr_vlregtot,2) ||'</vlregist>'|| -- Valor registrado - Fator 2 
                              '<vlsaltot>' || TRUNC(vr_vlsaltot,2) ||'</vlsaltot>'|| -- Valor Devido Total
                              --
                              '<prvlrreg>' || vr_prvlrreg ||'</prvlrreg>'|| -- Percentual - Fator 2
                              '</dadosfinais>');
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 

    -- Encerrar a tag raiz
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</dados></Root>'
                           ,pr_fecha_xml      => TRUE);
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    
    

    -- Buscar Diretorio Padrao da Cooperativa
    vr_nmdir001_html := gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                         ,pr_cdcooper => 3  -- Central
                                         ,pr_nmsubdir => 'rl');
                                         
    vr_nmarq001_html := '/' || 'CUSAPL_CLC_INF'     || 
                       '_CP' || NVL(pr_cdcooper,'0') ||
                       '_CT' || NVL(pr_nrdconta,'0') ||
                       '_'   || NVL(SUBSTR(pr_dtde, 7, 4 ) ||
                                    SUBSTR(pr_dtde, 4, 2 ) ||
                                    SUBSTR(pr_dtde, 1, 2 ),  '0') ||
                       '_A_' || NVL(SUBSTR(pr_dtate, 7, 4 ) ||
                                    SUBSTR(pr_dtate, 4, 2 ) ||
                                    SUBSTR(pr_dtate, 1, 2 ), '0') ||
                       '.xml';    
            
    -- Gerar o arquivo na pasta converte
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_clob
                                 ,pr_caminho  => vr_nmdir001_html
                                 ,pr_arquivo  => vr_nmarq001_html
                                 ,pr_des_erro => vr_dscritic);
                                                                          

    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Atualizar o atributo com quantidade de registro caso maior que zero
    IF vr_qtdiager > 0 THEN 
      -- Atualizar atributo contador
      gene0007.pc_altera_atributo(pr_xml      => pr_retxml
                                 ,pr_tag      => 'listacusdev'
                                 ,pr_atrib    => 'qtdiager'
                                 ,pr_atval    => vr_qtdiager
                                 ,pr_numva    => 0
                                 ,pr_des_erro => vr_dscritic);
      -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    END IF;

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);
    
    -- Retorno OK
    ---pr_des_erro := 'OK';
        
    --
    ROLLBACK;
    vr_dsemldst := '';
    vr_dsassunt := 'Calculo do valor devido ao B3';
    IF vr_qttoterr > 0 THEN
      vr_dscorpo := '<br>' ||
                    'Processo com erro parcial.'    || '<br>' ||
                    'Verificar os erros no anexo.'  || '<br>' ||
                    'Também as informações calculadas estão em anexo'  || 
                    ' ou consulte na tela CUSAPL.';
    ELSE
      vr_dscorpo := '<br>' ||
                    'Processo Com Sucesso' || '<br>' ||
                    'As informações calculadas estão em anexo.'  || 
                    ' ou consulte na tela CUSAPL.';
    END IF;
    pc_trata_retorno;
    COMMIT;
                                 
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Propagar Erro 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic) ||
                     vr_nmaction ||
                     '. ' || vr_dsparame;
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);   
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
      ROLLBACK;
      vr_dsemldst := '';
      vr_dsassunt := 'Erro de processamento no calculo do valor devido ao B3';
      vr_dscorpo  := 'Erro: ' || vr_cdcritic || ' => ' || vr_dscritic;
      pc_trata_retorno;
      COMMIT;                                                                                                     
    WHEN OTHERS THEN 
      -- Acionar log exceções internas
      CECRED.pc_internal_exception(pr_cdcooper => 3);
      -- Efetuar retorno do erro nao tratado
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                     ' ' || SQLERRM ||
                     vr_nmaction ||
                     ' ' || vr_dsparame;
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);      
      -- Devolver criticas        
      pr_cdcritic := 1495;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
      -                              '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      ROLLBACK;
      vr_dsemldst := '';
      vr_dsassunt := 'Erro de processamento no calculo do valor devido ao B3';
      vr_dscorpo  := 'Erro: ' || vr_cdcritic || ' => ' || vr_dscritic;
      pc_trata_retorno;
      COMMIT;
  END pc_exe_grc_cst_frn_aplica;    
  
  -- Procedimento para tratar custo fornecedor aplicação - B3
  PROCEDURE pc_trt_cst_frn_aplica(pr_cdmodulo IN VARCHAR2           -- Cooperativa selecionada (0 para todas)
                                 ,pr_cdcooper IN crapcop.cdcooper%TYPE -- Cooperativa selecionada (0 para todas)
                                 ,pr_nrdconta IN VARCHAR2           -- Conta informada
                                 ,pr_dtde     IN VARCHAR2           -- Data de 
                                 ,pr_dtate    IN VARCHAR2           -- Date até
                                 ,pr_tpproces IN NUMBER             -- Tipo: 1 - Gera, 2 - Consulta, 3 - Caminho CSV
                                 ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                 ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2          -- Saida OK/NOK 
                                 )
  IS
  /* ..........................................................................
    
  Procedure: pc trt cst frn_aplica
  Sistema  : Rotina de aplicações
  Autor    : Belli/Envolti
  Data     : 03/04/2019                        Ultima atualizacao: 
    
  Dados referentes ao programa:  Projeto PJ411_F2_P2  
  Frequencia: Sempre que for chamado
  Objetivo  : Procedimento para tratar custo fornecedor aplicação - B3
    
  Alteracoes: 
    
  ............................................................................. */   
    ----vr_qttoterr           NUMBER    (25,8):= 0;
    vr_prvlrreg           NUMBER    (25,8);
    vr_dtde               date;
    vr_dtate              date;
    vr_dstipo             VARCHAR2(10);   
        
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --Variaveis de Excecoes
    vr_exc_erro_trt_cst  EXCEPTION;
              
    -- Variaveis gerais
    
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB; 
    -- Buscar custo fixo para calcular custo devido na conciliação de despesa para B3
    vr_dsvlrprm  VARCHAR2 (100);
    vr_vlcusfix  NUMBER    (25,8) := 0;
    -- Variavel para setar ação
    vr_nmaction  VARCHAR2  (100) := vr_nmpackge || '.pc_trt_cst_frn_aplica'; -- Rotina e programa
   
  --
  
  PROCEDURE pc_passagem_nome_arq
  IS
    -- Variaveis de controle de erro e modulo
    vr_dsparint  VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
    vr_nmrotint  VARCHAR2  (100) := 'pc_passagem_nome_arq'; -- Rotina e programa 
    
  BEGIN
    -- Incluido nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    
    -- CUSAPL_CLC_INF_CP13_CT1503_20181201_A_20181231.csv
    
    vr_nmdir001_csv := vr_dsdirarq;
    vr_nmarq001_csv := 'CUSAPL_CLC_INF'     || 
                       '_CP' || NVL(pr_cdcooper,'0') ||
                       '_CT' || NVL(pr_nrdconta,'0') ||
                       '_'   || NVL(SUBSTR(pr_dtde, 7, 4 ) ||
                                    SUBSTR(pr_dtde, 4, 2 ) ||
                                    SUBSTR(pr_dtde, 1, 2 ),  '0') ||
                       '_A_' || NVL(SUBSTR(pr_dtate, 7, 4 ) ||
                                    SUBSTR(pr_dtate, 4, 2 ) ||
                                    SUBSTR(pr_dtate, 1, 2 ), '0') ||
                       '.'   || vr_dstipo; -- 'csv'; 
                             
    vr_dsparint := ', vr_nmdir001:'   || vr_nmdir001_csv || 
                   ', vr_nmarq001:' || vr_nmarq001_csv ||
                   ', vr_dstipo:'   || vr_dstipo;
                   

    -- Log de erro de execucao
    pc_log(pr_cdcritic => 1201
          ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201)      ||
                          ', ' || vr_nmaction ||
                          ', ' || vr_dsparame ||
                          ', ' || vr_dsparint);                      
/*    
    -- Envia-lo ao servidor web.           
    gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_nmarqpdf => vr_nmdir001_csv||'/'|| vr_nmarq001_csv
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);
*/                                    

              --Enviar arquivo para Web
              GENE0002.pc_envia_arquivo_web (
                                    pr_cdcooper => vr_cdcooper        --Codigo Cooperativa
                                   ,pr_cdagenci => vr_cdagenci        --Codigo Agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa        --Numero do Caixa
                                   ,pr_nmarqimp => vr_nmarq001_csv        --Nome Arquivo Impressao
                                   ,pr_nmdireto => vr_nmdir001_csv        --Nome Diretorio
                                   ,pr_nmarqpdf => vr_nmarq001_csv        --Nome Arquivo PDF
                                   ,pr_des_reto => vr_des_reto        --Retorno OK/NOK
                                   ,pr_tab_erro => vr_tab_erro);      --tabela erro                                                                          
    -- Log de erro de execucao
    pc_log(pr_cdcritic => 1201
          ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201)      ||
                          vr_nmaction ||
                                  '  pr_cdcooper =>' || vr_cdcooper      ||   --Codigo Cooperativa
                                  ' ,pr_cdagenci =>' || vr_cdagenci      || --Codigo Agencia
                                  ' ,pr_nrdcaixa =>' || vr_nrdcaixa       ||  --Numero do Caixa
                                  ' ,pr_nmarqimp =>' || vr_nmarq001_csv   ||      --Nome Arquivo Impressao
                                  ' ,pr_nmdireto =>' || vr_nmdir001_csv  ||       --Nome Diretorio
                                  ' ,pr_nmarqpdf =>' || vr_nmarq001_csv  ||       --Nome Arquivo PDF
                                  ' ,pr_des_reto =>' || vr_des_reto       ||       --Nome Arquivo PDF
                                  ' ,vr_tab_erro.COUNT =>' || vr_tab_erro.COUNT   ||      --Retorno OK/NOK
            ', vr_cdcritic:=' || vr_tab_erro(vr_tab_erro.FIRST).cdcritic  ||
            ', vr_dscritic:=' || vr_tab_erro(vr_tab_erro.FIRST).dscritic
                          );   
        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN                  
          --Se tem erro na tabela 
          IF vr_tab_erro.COUNT > 0 THEN
            --Mensagem Erro
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_dscritic:= 'Erro ao devolver arquivo ' ||  vr_dstipo || ' para AimaroWeb.';  
          END IF;                   
          --Sair 
          RAISE vr_exc_erro_trt_cst;                  
        END IF; 
                       
    -- Carrega os dados
    GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '<arq>'||
                              CASE vr_dstipo
                              WHEN 'csv' THEN
                                '<nmarq001csv>' || vr_nmarq001_csv || '</nmarq001csv>'
                              ELSE
                                '<nmarq001xml>' || vr_nmarq001_csv || '</nmarq001xml>'
                              END ||
                              '</arq>');
                              
    -- Limpa nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL ); 
  EXCEPTION
    WHEN OTHERS THEN
      -- Acionar log exceções internas
      CECRED.pc_internal_exception(pr_cdcooper => 3);
      -- Efetuar retorno do erro nao tratado
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                     ' ' || SQLERRM     ||
                     vr_nmaction        ||
                     ' ' || vr_nmrotint ||
                     ' ' || vr_dsparame ||
                     ' ' || vr_dsparint;      
      RAISE vr_exc_erro_trt_cst;                     
  END pc_passagem_nome_arq;
  --
  
  PROCEDURE pc_consulta
  IS                        
      vr_utl_file         utl_file.file_type;                        --> Handle
      vr_typ_saida        VARCHAR2(3);                               --> Saída do comando no OS
      vr_qtdregist        NUMBER;                                    --> Quantidade de registros
      vr_dslinha          tbcapt_custodia_conteudo_arq.dslinha%TYPE; --> Conteudo das linhas
      --
      vr_aux        VARCHAR2(1000) := ' -- ';    
  BEGIN   
    -- BELLI31 
    vr_qtdregist := 0;
    
    pc_log(pr_cdcritic => 1201
          ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201)      ||
                          vr_nmaction         ||
                          ' pc_consulta '     ||
                          ' ' || vr_dsparame  ||
                          ' ' || vr_dsdirarq);

/*                          
    vr_inabr001_critic := false;    
    vr_nmtip001_critic := 'txt';
    vr_nmdir001_critic := vr_dsdirarq;
    vr_nmarq001_critic := 
                   '/'   || 'CUSAPL_CLC_CRI'     || 
                   '_CP' || NVL(pr_cdcooper,'0') ||
                   '_CT' || NVL(pr_nrdconta,'0') ||
                   '_'   || NVL(SUBSTR(pr_dtde, 7, 4 ) ||
                                SUBSTR(pr_dtde, 4, 2 ) ||
                                SUBSTR(pr_dtde, 1, 2 ),  '0') ||
                   '_A_' || NVL(SUBSTR(pr_dtate, 7, 4 ) ||
                                SUBSTR(pr_dtate, 4, 2 ) ||
                                SUBSTR(pr_dtate, 1, 2 ), '0') ||
                   '_'   || TO_CHAR(SYSDATE,'DD HH24MISS') ||
                   '.'   || vr_nmtip001_critic;
                   */
    
    -- Se for rotina 001 e arquivo de critica sem abrir, então abre 
   -- IF NOT vr_inabr001_critic    THEN
       
   --   vr_inabr001_critic := true;
      
      
    --                           
    pc_abre_arquivo(pr_nmarqger =>  '/' || 'CUSAPL_CLC_INF_CP13_CT0_20181201_A_20181231.csv'
                   ,pr_nmdirger => vr_dsdirarq 
                   ,pr_tipabert => 'R'
                   ,pr_dshandle => vr_utl_file) ;
   /*
    -- Abrir cada arquivo encontrado
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdirarq
                            ,pr_nmarquiv => 'CUSAPL_CLC_INF_CP13_CT0_20181201_A_20181231.csv'
                            ,pr_tipabert => 'R'
                            ,pr_utlfileh => vr_utl_file
                            ,pr_des_erro => vr_dscritic);
    -- Se houve erro, parar o processo
    IF vr_dscritic IS NOT NULL THEN
      -- Retornar com a critica
      RAISE vr_exc_erro_trt_cst;
    END IF;
    */
    -- Buscar todas as linhas do arquivo
    LOOP
    BEGIN
                    -- Adicionar linha ao arquivo
                    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utl_file
                                                ,pr_des_text => vr_dslinha);


                    -- Incrementar o contador
                    vr_qtdregist := vr_qtdregist + 1;
                    vr_aux := vr_aux || ' - ' || vr_dslinha;
    EXCEPTION
      WHEN no_data_found THEN
        EXIT;           
      WHEN OTHERS THEN
        -- Acionar log exceções internas
        CECRED.pc_internal_exception(pr_cdcooper => 3);
        pc_log(pr_cdcritic => 9999
            ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 9999)      ||
                          ' ' || SQLERRM      ||
                          vr_nmaction         ||
                          ' pc_consulta - LOOP '     ||
                          ' ' || vr_dsparame  ||
                          ' ' || vr_dsdirarq);                      
    END;
    END LOOP;
    
    -- Se arquivo de critica aberto, então fecha 
   -- IF vr_inabr001_critic     THEN 
      pc_fecha_arquivo(vr_utl_file);
   --   vr_inabr001_critic := false;
   -- END IF;
    
    pc_log(pr_cdcritic => 1201
          ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 1201)      ||
                          vr_nmaction         ||
                          ' pc_consulta FIM OK '     ||
                          ' ' || vr_dsparame  ||
                          ' ' || vr_dsdirarq  ||
                          ' ' || vr_qtdregist ||
                          ' ' || vr_aux  );
    
  EXCEPTION
    WHEN OTHERS THEN
      -- Acionar log exceções internas
      CECRED.pc_internal_exception(pr_cdcooper => 3);
      pc_log(pr_cdcritic => 9999
          ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 9999)      ||
                          ' ' || SQLERRM      ||
                          vr_nmaction         ||
                          ' pc_consulta '     ||
                          ' ' || vr_dsparame  ||
                          ' ' || vr_dsdirarq);
  END pc_consulta;
  --
  
  -- pc_cria_job
  PROCEDURE pc_cria_job
  IS      
    vr_qtminuto       NUMBER      (2)  := 1;                           
    vr_jobname        VARCHAR2  (100);
    vr_qtparametros   PLS_INTEGER      := 1;
    -- Variaveis de controle de erro e modulo
    vr_dsparint       VARCHAR2 (4000)  := NULL; -- Agrupa parametros para gravar em logs
    vr_nmrotint       VARCHAR2  (100)  := 'pc_cria_job'; -- Rotina e programa 
  BEGIN    
        
    -- Geração do custo do fornecedor de movimentação ee aplicações         
    vr_jobname  := 'JBCAPT_CSLFRMAPL_' || '$';
                    
    -- Job que se start e depois se autodestroi
    vr_jobname := dbms_scheduler.generate_job_name(vr_jobname);    
                  
    dbms_scheduler.create_job(job_name     => vr_jobname
                             ,job_type     => 'STORED_PROCEDURE'
                             --,job_action   => 'CECRED.APLI0007.pc_exe_grc_cst_frn_aplica'
                             -- Forçado teste Belli 
                             ,job_action   => 'CECRED.APLI0007.pc_exe_grc_cst_frn_aplica'
                             ,enabled      => FALSE
                             ,number_of_arguments => 5
                             ,start_date          => ( SYSDATE + (vr_qtminuto /1440) ) --> Horario da execução
                             ,repeat_interval     => NULL                              --> apenas uma vez
                              );                                   
    
    vr_qtparametros := 1;
    dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                        ,argument_position => vr_qtparametros
                                        ,argument_value    => anydata.ConvertVarchar2(pr_cdmodulo)
                                        );                                       
    vr_qtparametros := 2;
    dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                        ,argument_position => vr_qtparametros
                                        ,argument_value    => anydata.ConvertNumber(pr_cdcooper)
                                        );
    vr_qtparametros := 3;
    dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                        ,argument_position => vr_qtparametros
                                        ,argument_value    => anydata.ConvertVarchar2(NVL(pr_nrdconta,0))
                                        );      
    vr_qtparametros := 4;
    dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                        ,argument_position => vr_qtparametros
                                        --,argument_value    => anydata.ConvertVarchar2(vr_tab_nmarqtel(1))
                                        ,argument_value    => anydata.ConvertVarchar2(pr_dtde)
                                        );
    vr_qtparametros := 5;    
    dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                        ,argument_position => vr_qtparametros
                                        --,argument_value    => anydata.ConvertCollection(vr_typ_craprej_array)
                                        ,argument_value    => anydata.ConvertVarchar2(pr_dtate)
                                        );     
    
    dbms_scheduler.enable(  name => vr_jobname );
    
    vr_cdcritic := 912;            
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          
    -- Carrega os dados
    GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '<Sucesso>' || vr_dscritic || '</Sucesso>');  
    vr_cdcritic := NULL;            
    vr_dscritic := NULL;
                                          
  EXCEPTION
    WHEN OTHERS THEN
      -- Acionar log exceções internas
      CECRED.pc_internal_exception(pr_cdcooper => 3);
      -- Efetuar retorno do erro nao tratado
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                     vr_nmaction         ||
                     '. ' || vr_nmrotint ||
                     '. ' || SQLERRM     ||
                     '. ' || vr_dsparame ||
                     '. ' || vr_dsparint;      
      RAISE vr_exc_erro_trt_cst;                        
  END pc_cria_job;  
  
  --    
  PROCEDURE pc_gera
  IS
  BEGIN
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    -- Variavel para setar ação - 03/04/2019 - PJ411_F2
    vr_dsparame := vr_dsparame || ' - pc_gera';
    
    -- Forçado erro - Teste Belli - 001
    -- vr_cdcritic := 0 / 0;
    
    -- Forçado erro - Teste Belli - 002
    pc_log(pr_cdcritic => 44
          ,pr_dscrilog => gene0001.fn_busca_critica(pr_cdcritic => 44) || ' mas deve ser a função do Mestre. ' ||
                          vr_nmaction ||
                          '. ' || vr_dsparame);   
      
    IF NVL(pr_cdcooper,0) IN ( 0 , 3 ) THEN
      vr_cdcritic := 794; -- Cooperativa Invalida
      RAISE vr_exc_erro_trt_cst;
    END IF;
    
    -- Fator 1 - Buscar custo fixo para calcular custo devido na conciliação de despesa para B3
    vr_cdacesso := 'CUSTO_FIXO_CCL_DSP_FRN';
    vr_dsvlrprm := gene0001.fn_param_sistema('CRED', pr_cdcooper, vr_cdacesso);
    IF vr_dsvlrprm IS NULL THEN
      vr_cdcritic := 1230; -- Registro de parametro não encontrado
      vr_dsparame := vr_dsparame || ', vr_cdacesso:' || vr_cdacesso;
      RAISE vr_exc_erro_trt_cst;
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    --
    vr_vlcusfix := TO_NUMBER(vr_dsvlrprm);
    
    -- Buscar custo fixo para calcular custo devido na conciliação de despesa para B3
    vr_cdacesso := 'PERC_VLR_REG_CCL_DSP_FRN';
    vr_dsvlrprm := gene0001.fn_param_sistema('CRED', pr_cdcooper ,vr_cdacesso);
    IF vr_dsvlrprm IS NULL THEN
      vr_cdcritic := 1230; -- Registro de parametro não encontrado
      vr_dsparame := vr_dsparame || ', vr_cdacesso:' || vr_cdacesso;
      RAISE vr_exc_erro_trt_cst;
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    --
    vr_prvlrreg := TO_NUMBER(vr_dsvlrprm);
    
    vr_dtini := TO_CHAR(vr_dtde, 'YYYYMMDD');
    vr_dtfim := TO_CHAR(vr_dtate,'YYYYMMDD');
    
    
    -----  negocio NEGOCIO -----------------
    
    /*
    -- Monta documento XML 
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
    -- Gerar a estrutura do XML 
    GENE0002.pc_escreve_xml
       (pr_xml            => vr_clob
       ,pr_texto_completo => vr_xml_temp
       ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?>' ||
                             '<Root><dados><listacusdev qtdiager="0">');    
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 

   */
   
   
    -- Gerar a estrutura do XML 
    GENE0002.pc_escreve_xml
       (pr_xml            => vr_clob
       ,pr_texto_completo => vr_xml_temp
       ,pr_texto_novo     => '<listacusdev qtdiager="0">');   
   
   
    -- Fator 3
    -- Montar os dias e valores acumulados para a saida
    ---FOR vr_dtdiaapl IN vr_dtini..vr_dtfim LOOP      
        -- Carrega os dados
        GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '<dia>'||
                              '<dtmvtolt>' || vr_dslinha  || '</dtmvtolt>'||
                              '<vlsalcon>' || vr_tab_diavlr(vr_dtdiaapl).vlacudia ||'</vlsalcon>'||
                              '</dia>');
        -- Retorno do módulo e ação logado
        GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    ---END LOOP;  
           
    -- Carrega os "Dados  Finais"
    GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '</listacusdev><dadosfinais>'||
                       ---       '<qtdiauti>' || vr_qtdiauti ||'</qtdiauti>'|| -- Dias Uteis - Só por conta                              
                         ---    '<prvlrreg>' || vr_prvlrreg ||'</prvlrreg>'|| -- Percentual - Fator 2
                              '</dadosfinais>');
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
   
    
  end pc_gera;           
                   
               ---   ROTINA PRINCIPAL INICIO
  BEGIN
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    -- Variavel para setar ação - 03/04/2019 - PJ411_F2
    vr_dsparame := 'pr_cdmodulo:'   || pr_cdmodulo ||
                   ', pr_cdcooper:' || pr_cdcooper ||
                   ', pr_nrdconta:' || NVL(pr_nrdconta,0) ||
                   ', pr_dtde:'     || pr_dtde   ||
                   ', pr_dtate:'    || pr_dtate  ||
                   ', pr_tpproces:' || pr_tpproces;

    
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
      vr_cdcritic := 0;
      RAISE vr_exc_erro_trt_cst;      
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    
    
    -- Monta documento XML 
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
    -- Gerar a estrutura do XML 
    GENE0002.pc_escreve_xml
       (pr_xml            => vr_clob
       ,pr_texto_completo => vr_xml_temp
       ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?>' ||
                             '<Root><dados>'); --<listacusdev qtdiager="0">');    
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    
    -- Validar os parâmetros data
    BEGIN
      vr_dtde  := TO_DATE(pr_dtde,  'DD/MM/YYYY');
      vr_dtate := TO_DATE(pr_dtate, 'DD/MM/YYYY');
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 13; -- Data errada
        RAISE vr_exc_erro_trt_cst;
    END;

    -- Se enviada as duas datas, temos de validar se até não é inferior a De
    IF vr_dtde > vr_dtate THEN
      vr_cdcritic := 1233; -- Data inicial deve ser menor ou igual a final:
      RAISE vr_exc_erro_trt_cst;
    END IF;
                       
    IF pr_tpproces = 1 THEN
      --pc_gera;
      pc_cria_job;
    ELSIF pr_tpproces = 2 THEN
      
    -- ATENCAO ESTA OPCAO A TEAL VAI LER DIRETO O BLABLA .HTML E LANÇAR NA TELA SEM O BACK
    -- POIS A OPCAO GERAR JA´GRAVOU O HTML NO DIRETORIO   PARA TELA LER,,, ALEM DO CSV 
    
    ---NULL;
      vr_dstipo := 'xml';
      pc_passagem_nome_arq;
    
    --  pc_consulta;
      
      
    ELSIF pr_tpproces = 3 THEN
      vr_dstipo := 'csv';
      pc_passagem_nome_arq;
    ELSE
      vr_cdcritic := 513;
      RAISE vr_exc_erro_trt_cst;
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 

    -- Encerrar a tag raiz
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</dados></Root>'
                           ,pr_fecha_xml      => TRUE);
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 

    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);

    -- Retorno OK
    pr_des_erro := 'OK';
    
    -- Limpa do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
                     
  EXCEPTION
    WHEN vr_exc_erro_trt_cst THEN                     
      -- Propagar Erro       
      vr_cdcritic := NVL(vr_cdcritic,0);
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);
      IF vr_cdcritic <> 9999 THEN 
        vr_dscritic := vr_dscritic ||
                       vr_nmaction ||
                       '. ' || vr_dsparame;
      END IF;
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic); 
      -- Devolver criticas      
      --     pr_nmdcampo := NULL;       
      pr_cdcritic := 1495;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      pr_des_erro := 'NOK';          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');   
                                                                                                              
    WHEN OTHERS THEN 
      -- Acionar log exceções internas
      CECRED.pc_internal_exception(pr_cdcooper => 3);
      -- Efetuar retorno do erro nao tratado
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                     '. ' || SQLERRM ||
                     vr_nmaction ||
                     '. ' || vr_dsparame;
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);      
      -- Devolver criticas        
      pr_cdcritic := 1495;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      pr_des_erro := 'NOK';          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
            
  END pc_trt_cst_frn_aplica; 
  
  -- Trata a tabela de parâmetro de custo de investidor para de conciliação
  PROCEDURE pc_conciliacao_tab_investidor
    (pr_nmmodulo IN VARCHAR2
    ,pr_cdcooper IN crapcop.cdcooper%TYPE
    ,pr_qttabinv OUT NUMBER
    ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
    ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
    )
  IS    
    -- ..........................................................................
    --
    --  Programa : pc conciliacao tab investidor
    --  Sistema  : Rotina de Log - tabela: tbgen prglog ocorrencia
    --  Sigla    : GENE
    --  Autor    : Envolti - Belli - Projeto 411 - Fase 2 - Conciliação Despesa
    --  Data     : 03/04/2019                        Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Trata a tabela de parâmetro de custo de investidor para de conciliação
    --
    --   Alteracoes: 
    --
    -- .............................................................................
    --

    -- Buscar dados tabela investidor
    CURSOR cr_tabinv
    IS 
        SELECT
               rownum nrrownum
              ,t1.idfrninv
              ,t1.vlfaixade
              ,t1.vlfaixaate
              ,t1.petaxa_mensal
              ,t1.vladicional
        FROM     tbcapt_custodia_frn_investidor t1
        WHERE    t1.flgativo = '1'
        ORDER BY t1.vlfaixade
        ;
        
    rw_tabinv  cr_tabinv%ROWTYPE;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    --           
    vr_qtrownum NUMBER(2) := 0;  
    -- Variaveis de controle de erro e modulo
    vr_dsparame  VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
    vr_nmrotpro  VARCHAR2  (100) := 'APLI0007.pc_conciliacao_tab_investidor'; -- Rotina e programa 
    
  BEGIN
    -- Incluido nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => pr_nmmodulo, pr_action => vr_nmrotpro );        
    vr_dsparame := 'pr_nmmodulo:'  || pr_nmmodulo || 
                   ',pr_cdcooper:' || pr_cdcooper;
                   
    -- CUSAPL_CADASTRO       - faz o tratamento do cadastro
    -- CUSAPL_CALCULO_DEVIDO - gera type                
    IF pr_nmmodulo = 'CUSAPL_CALCULO_DEVIDO' THEN
      NULL;
    END IF;
    
    vr_tab_tabinv.delete;
    FOR rw_tabinv IN cr_tabinv
    LOOP
      vr_qtrownum := vr_qtrownum + 1;
      vr_tab_tabinv(vr_qtrownum).idfrninv  := rw_tabinv.idfrninv;
      vr_tab_tabinv(vr_qtrownum).vlfaixde  := rw_tabinv.vlfaixade;
      vr_tab_tabinv(vr_qtrownum).vlfaixate := rw_tabinv.vlfaixaate;
      vr_tab_tabinv(vr_qtrownum).pctaxmen  := rw_tabinv.petaxa_mensal;
      vr_tab_tabinv(vr_qtrownum).vladicio  := rw_tabinv.vladicional;
    END LOOP;
    
    pr_qttabinv := vr_qtrownum;

    -- Zera nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL );   
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic
                                              ,pr_dscritic => vr_dscritic) ||
                     vr_nmrotpro     ||
                     '. ' || vr_dsparame; 
    WHEN OTHERS THEN
      -- Quando erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);      
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                     '. ' || SQLERRM ||
                     vr_nmrotpro     || 
                     '. ' || vr_dsparame;     
  END pc_conciliacao_tab_investidor;  


  -- Trata a tabela de parâmetro de custo de investidor para de conciliação
  PROCEDURE pc_pos_faixa_tab_investidor
    (pr_nmmodulo IN VARCHAR2
    ,pr_cdcooper IN crapcop.cdcooper%TYPE
    ,pr_qttabinv IN NUMBER
    ,pr_vlentrad IN NUMBER
    ,pr_idasitua OUT NUMBER
    ,pr_pctaxmen OUT NUMBER
    ,pr_vladicio OUT NUMBER
    ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
    ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
   
    )
  IS   
  /* ..........................................................................
    
  Procedure: pc pos faixa tab investidor
  Sistema  : Rotina de aplicações
  Autor    : Belli/Envolti
  Data     : 03/04/2019                        Ultima atualizacao: 
    
  Dados referentes ao programa:  Projeto PJ411_F2_P2  
  Frequencia: Sempre que for chamado
  Objetivo  : Trata a tabela de parâmetro de custo de investidor para de conciliação
    
  Alteracoes: 
    
  ............................................................................. */ 
      
    -- Variaveis de controle de erro e modulo
    vr_dsparame  VARCHAR2 (4000) := NULL; -- Agrupa parametros para gravar em logs
    vr_nmrotpro  VARCHAR2  (100) := 'APLI0007.pc_pos_faixa_tab_investidor'; -- Rotina e programa 

  BEGIN
    -- Incluido nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => pr_nmmodulo, pr_action => vr_nmrotpro );        
    vr_dsparame := 'pr_nmmodulo:'  || pr_nmmodulo || 
                   ',pr_cdcooper:' || pr_cdcooper;
     
    -- 
    pr_idasitua := 2;
    FOR vr_nrrownum IN 1..pr_qttabinv LOOP
    --  dbms_output.put_line('vlfaixde  :' || vr_tab_tabinv(vr_nrrownum).vlfaixde );
      IF pr_vlentrad >= vr_tab_tabinv(vr_nrrownum).vlfaixde  AND
         pr_vlentrad <= vr_tab_tabinv(vr_nrrownum).vlfaixate     THEN
     --   dbms_output.put_line('vlfaixde:' || vr_tab_tabinv(vr_nrrownum).vlfaixde );
        pr_pctaxmen := vr_tab_tabinv(vr_nrrownum).pctaxmen;
        pr_vladicio := vr_tab_tabinv(vr_nrrownum).vladicio;
        pr_idasitua := 1;
    
        EXIT;
      END IF;
    END LOOP;

    -- Zera nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL );   
  EXCEPTION 
    WHEN OTHERS THEN
      -- Quando erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);      
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                     ' ' || SQLERRM ||
                     vr_nmrotpro     || 
                     ' ' || vr_dsparame;
  END pc_pos_faixa_tab_investidor; 

  -- 
  PROCEDURE pc_concil_tab_investidor(pr_cdmodulo IN VARCHAR2           -- Tela e qual consulta, 48 caractere
                                    ,pr_cdcooper IN crapcop.cdcooper%TYPE  -- Cooperativa selecionada (0 para todas)
                                    ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                    ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2          -- Saida OK/NOK 
                                    )
  IS
  /* ..........................................................................
    
  Procedure: pc concil tab investidor
  Sistema  : Rotina de aplicações
  Autor    : Belli/Envolti
  Data     : 03/04/2019                        Ultima atualizacao: 
    
  Dados referentes ao programa:  Projeto PJ411_F2_P2  
  Frequencia: Sempre que for chamado
  Objetivo  : Carrega a tabela de parâmetro de custo de investidor para de conciliação
    
  Alteracoes: 
    
  ............................................................................. */ 
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;
    
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB; 
    
    vr_qttabinv  NUMBER     (2)   := 0;
    
    -- Variavel para setar ação
    vr_nmaction  VARCHAR2  (100) := vr_nmpackge || '.pc_concil_tab_investidor'; -- Rotina e programa
    
    FUNCTION  fn_format2
      ( vr_vlentrada IN NUMBER )  RETURN VARCHAR2
    IS
    BEGIN
     IF vr_vlentrada = 0 THEN
       RETURN '0.00';
     ELSIF vr_vlentrada < 1 THEN
       --RETURN RTRIM((REPLACE(REPLACE(TO_CHAR( vr_vlentrada,'0.00000000'),'.',',') ,' ','')),'0');
       RETURN RTRIM((
                REPLACE(
                    --REPLACE(
                            TO_CHAR( vr_vlentrada,'0.00000000')
                    --       ,'.',',')
                 ,' ','')
              ),'0');
     ELSE
       RETURN vr_vlentrada;
     END IF;
    END;
    ----
    FUNCTION  fn_format
      ( vr_vlentrada IN NUMBER )  RETURN VARCHAR2
    IS
    BEGIN
     RETURN REPLACE(REPLACE(TO_CHAR( vr_vlentrada,'000000000000000.00000000'),'.',',') ,' ','');
    END;
    --
  BEGIN  ---   ROTINA PRINCIPAL INICIO
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction );
    
    --EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '',.''';
     
    -- Variavel para setar ação
    vr_dsparame := 'pr_cdmodulo:'   || pr_cdmodulo ||
                   ', pr_cdcooper:' || pr_cdcooper;
                   
    -- Forçado Log -  Teste Belli - 
    pc_log(pr_cdcritic => 1201
          ,pr_dscrilog => gene0001.fn_busca_critica(1201) ||
                          vr_nmaction ||
                          '. ' || SQLERRM ||
                          '. ' || vr_dsparame);      
    --vr_cdcritic := 0 / 0;
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
      vr_cdcritic := 0;
      RAISE vr_exc_erro;      
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
     
    pc_conciliacao_tab_investidor(pr_cdmodulo -- Tela e qual consulta, 48 caractere
                                 ,pr_cdcooper -- Cooperativa selecionada (0 para todas)
                                 ,pr_qttabinv => vr_qttabinv
                                 ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                 ,pr_dscritic => vr_dscritic);       --Descricao Critica
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 

    -- Monta documento XML 
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
    -- Gerar a estrutura do XML 
    GENE0002.pc_escreve_xml
       (pr_xml            => vr_clob
       ,pr_texto_completo => vr_xml_temp
       ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><listatabinv qttabinv="0">');    
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    -- 
    IF NVL(vr_qttabinv,0) = 0 THEN
      NULL;
    ELSE
      FOR vr_nrrownum IN 1..vr_qttabinv LOOP       
        /*
        dbms_output.put_line('<faixas>'||
                              '<idfrninv>'  || vr_tab_tabinv(vr_nrrownum).idfrninv             || '</idfrninv>'||
                              '<vlfaixde>'  || fn_format2(vr_tab_tabinv(vr_nrrownum).vlfaixde)  || '</vlfaixde>'||
                              '<vlfaixate>' || fn_format2(vr_tab_tabinv(vr_nrrownum).vlfaixate) || '</vlfaixate>'||
                              '<pctaxmen>'  || fn_format2(vr_tab_tabinv(vr_nrrownum).pctaxmen)  || '</pctaxmen>'||
                              '<vladicio>'  || fn_format2(vr_tab_tabinv(vr_nrrownum).vladicio)  || '</vladicio>'||
                              '</faixas>'
                            ); */
        
        -- Carrega os dados
        GENE0002.pc_escreve_xml
        (pr_xml            => vr_clob
        ,pr_texto_completo => vr_xml_temp
        ,pr_texto_novo     => '<faixas>'||
                              '<idfrninv>'  || vr_tab_tabinv(vr_nrrownum).idfrninv  || '</idfrninv>'||
                              '<vlfaixde>'  || fn_format2(vr_tab_tabinv(vr_nrrownum).vlfaixde)  || '</vlfaixde>'||
                              '<vlfaixate>' || fn_format2(vr_tab_tabinv(vr_nrrownum).vlfaixate) || '</vlfaixate>'||
                              '<pctaxmen>'  || fn_format2(vr_tab_tabinv(vr_nrrownum).pctaxmen)  || '</pctaxmen>'||
                              '<vladicio>'  || fn_format2(vr_tab_tabinv(vr_nrrownum).vladicio)  || '</vladicio>'||
                              '</faixas>');
                   
    -- Forçado Log -  Teste Belli - 
    /*
    pc_log(pr_cdcritic => 1201
          ,pr_dscrilog => gene0001.fn_busca_critica(1201) ||
                          vr_nmaction || 'VAMOA LÁ ' || 
                          '<faixas>'||
                              '<idfrninv>'  || vr_tab_tabinv(vr_nrrownum).idfrninv  || '</idfrninv>'||
                              '<vlfaixde>'  || fn_format2(vr_tab_tabinv(vr_nrrownum).vlfaixde)  || '</vlfaixde>'||
                              '<vlfaixate>' || fn_format2(vr_tab_tabinv(vr_nrrownum).vlfaixate) || '</vlfaixate>'||
                              '<pctaxmen>'  || fn_format2(vr_tab_tabinv(vr_nrrownum).pctaxmen)  || '</pctaxmen>'||
                              '<vladicio>'  || fn_format2(vr_tab_tabinv(vr_nrrownum).vladicio)  || '</vladicio>'||
                              '</faixas>'); */
        -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
        
      END LOOP;
    END IF;


    -- Encerrar a tag raiz
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</listatabinv></Root>'
                           ,pr_fecha_xml      => TRUE);
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 

    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Atualizar o atributo com quantidade de registro caso maior que zero
    IF vr_qttabinv > 0 THEN 
      -- Atualizar atributo contador
      gene0007.pc_altera_atributo(pr_xml      => pr_retxml
                                 ,pr_tag      => 'listatabinv'
                                 ,pr_atrib    => 'qttabinv'
                                 ,pr_atval    => vr_qttabinv
                                 ,pr_numva    => 0
                                 ,pr_des_erro => vr_dscritic);
      -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    END IF;

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);

    -- Retorno OK
    pr_des_erro := 'OK';
    --
    
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Propagar Erro 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic) ||
                     vr_nmaction ||
                     '. ' || vr_dsparame;
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);      
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');         
    WHEN OTHERS THEN 
      -- Acionar log exceções internas
      CECRED.pc_internal_exception(pr_cdcooper => 3);
      -- Efetuar retorno do erro nao tratado
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                     ' ' || SQLERRM ||
                     vr_nmaction ||
                     ' ' || vr_dsparame;
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);      
      -- Devolver criticas        
      pr_cdcritic := 1495;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      pr_des_erro := 'NOK';          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>'); 
  END pc_concil_tab_investidor;
      
  
  -- Atualiza tabela investidor
  PROCEDURE pc_atz_faixa_tab_investidor(--pr_cdmodulo IN VARCHAR2           -- Tela e qual consulta, 48 caractere
                                       --,pr_cdcooper IN crapcop.cdcooper%TYPE  -- Cooperativa selecionada (0 para todas)
                                        pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                       ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2          -- Saida OK/NOK 
                                       )
  IS
    /* .............................................................................
     Procedure: pc atz faixa tab investidor
     Sistema  : Rotina de aplicações
     Autor    : Belli/Envolti
     Data    : Abril/2019.                  Ultima atualizacao: 

     Dados referentes ao programa:
     Frequencia: Sempre que for chamado
     Objetivo  : Atualizar o cadastro de investidor de ori o B3gem do fornecedor que nesta data de criação 
     
     Alteracoes:                 
    ..............................................................................*/ 
    
    pr_cdmodulo  VARCHAR2(10)          := 'CUSAPL'; -- Tela e qual consulta, 48 caractere
    pr_cdcooper  crapcop.cdcooper%TYPE := 3;                  
    --Variaveis locais
    vr_cdoperad VARCHAR2(100);
    vr_cdcooper NUMBER;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);  
    x1 VARCHAR2(100);   
    
    vr_id_acesso PLS_INTEGER    := 0;
    vr_qttabinv  NUMBER   (2)   := 0;
    vr_flgativo  NUMBER   (1)   := 2; -- 1 ativado, 2 Inativado
    
    vr_idfrninv  tbcapt_custodia_frn_investidor.idfrninv%TYPE;
    vr_vlfaixde  tbcapt_custodia_frn_investidor.vlfaixade%TYPE;
    vr_vlfaixate tbcapt_custodia_frn_investidor.vlfaixaate%TYPE;
    vr_pctaxmen  tbcapt_custodia_frn_investidor.petaxa_mensal%TYPE;
    vr_vladicio  tbcapt_custodia_frn_investidor.vladicional%TYPE;
    
    vr_qtinclus  NUMBER(2) := 0;
    vr_qtexclus  NUMBER(2) := 0;
    vr_qtaltera  NUMBER(2) := 0;
    vr_qtnaoalt  NUMBER(2) := 0;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    vr_exc_saida EXCEPTION;
    
    -- Variáveis para tratamento do XML
    vr_node_list xmldom.DOMNodeList;
    vr_parser    xmlparser.Parser;
    vr_doc       xmldom.DOMDocument;
    vr_lenght    NUMBER;
    vr_node_name VARCHAR2(100);
    vr_item_node xmldom.DOMNode;    
    
    -- Arq XML
    vr_xmltype sys.xmltype;
    
    -- Variavel para setar ação
    vr_nmaction  VARCHAR2  (100) := vr_nmpackge || '.pc_atz_faixa_tab_investidor'; -- Rotina e programa
  
    --vr_tab_contas_demitidas typ_tab_contas_demitidas;    
    
    -- Retornar o valor do nodo tratando casos nulos
    FUNCTION fn_extract(pr_nodo  VARCHAR2) RETURN VARCHAR2 IS
      
    BEGIN
      -- Extrai e retorna o valor... retornando null em caso de erro ao ler
      RETURN pr_retxml.extract(pr_nodo).getstringval();
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
    --
  BEGIN                                  ---   ROTINA PRINCIPAL INICIO
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    
    
      --gene0001.pc_informa_acesso(pr_module => pr_cdmodulo, pr_action => vr_nmaction);
    --EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''MM/DD/YYYY''
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '',.''';
      
      
      
    -- Variavel para setar ação
    vr_dsparame := 'pr_cdmodulo:'   || pr_cdmodulo ||
                   ', pr_cdcooper:' || pr_cdcooper;
                   
    -- Forçado Log -  Teste Belli - 
    ---pc_log(pr_cdcritic => 1201
    ---      ,pr_dscrilog => gene0001.fn_busca_critica(1201) ||
    ---                      vr_nmaction ||
    ---                      '. ' || vr_dsparame); 
    --vr_cdcritic := 0 / 0;
    -- extrair informações padrão do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml 
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao 
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction);
    
    -- Inicializa variavel
    vr_id_acesso := 0;
    vr_xmltype  := pr_retxml;

    -- Faz o parse do XMLTYPE para o XMLDOM e libera o parser ao fim
    vr_parser := xmlparser.newParser;
    xmlparser.parseClob(vr_parser,vr_xmltype.getClobVal());
    vr_doc    := xmlparser.getDocument(vr_parser);
    xmlparser.freeParser(vr_parser);

    -- Faz o get de toda a lista de elementos
    vr_node_list := xmldom.getElementsByTagName(vr_doc, '*');
    vr_lenght    := xmldom.getLength(vr_node_list);
    
    -- Inicioando Varredura do XML.
    BEGIN
          
      -- Percorrer os elementos
      FOR i IN 0..vr_lenght LOOP
         -- Pega o item
         vr_item_node := xmldom.item(vr_node_list, i);            
             
         -- Captura o nome do nodo
         vr_node_name := xmldom.getNodeName(vr_item_node);
         -- Verifica qual nodo esta sendo lido
         IF vr_node_name IN ('Root') THEN
            CONTINUE; -- Descer para o próximo filho
         ELSIF vr_node_name IN ('Dados') THEN
            CONTINUE; -- Descer para o próximo filho
         ELSIF vr_node_name = 'faixas' THEN 
            vr_id_acesso := vr_id_acesso + 1;
            CONTINUE; 
         ELSIF vr_node_name = 'idfrninv' THEN 
            vr_tab_novtabinv(vr_id_acesso).idfrninv := TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
            CONTINUE;  
         ELSIF vr_node_name = 'vlfaixde' THEN
            x1  := TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
            
            vr_tab_novtabinv(vr_id_acesso).vlfaixde := TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
            CONTINUE;
         ELSIF vr_node_name = 'vlfaixate' THEN 
            vr_tab_novtabinv(vr_id_acesso).vlfaixate := TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
            CONTINUE;  
         ELSIF vr_node_name = 'pctaxmen' THEN 
            vr_tab_novtabinv(vr_id_acesso).pctaxmen := TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
            CONTINUE;  
         ELSIF vr_node_name = 'vladicio' THEN 
            vr_tab_novtabinv(vr_id_acesso).vladicio := TRIM(xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node)));
            CONTINUE; 
         ELSE
            CONTINUE; -- Descer para o próximo filho
         END IF;                       
                                          
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        -- Quando erro de programa gravar tabela especifica de log
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);      
        -- Efetuar retorno do erro não tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                       'Loop lista XML, '    ||
                       vr_dsparame    || 
                       ', x1:' || x1 ||
                       ', vr_id_acesso:' || vr_id_acesso ||
                       ', vr_lenght:' || vr_lenght ||
                       '. ' || SQLERRM;    
        RAISE vr_exc_saida;
    END;
    
    IF vr_id_acesso > 0 THEN
      pc_conciliacao_tab_investidor(pr_cdmodulo -- Tela e qual consulta, 48 caractere
                                   ,pr_cdcooper -- Cooperativa selecionada (0 para todas)
                                   ,pr_qttabinv => vr_qttabinv
                                   ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                   ,pr_dscritic => vr_dscritic);       --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
      -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => pr_cdmodulo, pr_action => vr_nmaction ); 
    END IF;
    
    -- Loop para verificar 
    -- se a faixa ainda esta valendo se não encontrar deve ser inativada
    -- se encontrar a faixa verificar se algum campo mudou se sim alterar o registro
    FOR vr_nrrownum IN 1..vr_qttabinv LOOP

      vr_idfrninv  := vr_tab_tabinv(vr_nrrownum).idfrninv;
      
      vr_flgativo  := 2;
      -- Posiciona no primeiro registro
      vr_id_acesso := vr_tab_novtabinv.FIRST(); 
      WHILE vr_id_acesso IS NOT NULL LOOP
        
        vr_vlfaixde  := vr_tab_novtabinv(vr_id_acesso).vlfaixde;
        vr_vlfaixate := vr_tab_novtabinv(vr_id_acesso).vlfaixate;
        vr_pctaxmen  := vr_tab_novtabinv(vr_id_acesso).pctaxmen;
        vr_vladicio  := vr_tab_novtabinv(vr_id_acesso).vladicio;
        
        --Efetua a reversão da situação da conta
        IF vr_tab_novtabinv(vr_id_acesso).idfrninv IS NULL OR
           vr_tab_novtabinv(vr_id_acesso).idfrninv = 0         THEN
                
          -- Vai incluir depois para não provocar erro na logica
          -- Alem disso no Loop de inclusao é vistoriada se as faixas estão corretas
          NULL;
        ELSIF vr_tab_tabinv(vr_nrrownum).idfrninv = vr_tab_novtabinv(vr_id_acesso).idfrninv THEN
          
          vr_flgativo := 1;
          -- Ver se algum diferente
          IF vr_tab_tabinv(vr_nrrownum).vlfaixde  = vr_tab_novtabinv(vr_id_acesso).vlfaixde  AND
             vr_tab_tabinv(vr_nrrownum).vlfaixate = vr_tab_novtabinv(vr_id_acesso).vlfaixate AND
             vr_tab_tabinv(vr_nrrownum).pctaxmen  = vr_tab_novtabinv(vr_id_acesso).pctaxmen  AND
             vr_tab_tabinv(vr_nrrownum).vladicio  = vr_tab_novtabinv(vr_id_acesso).vladicio      THEN
            ----
            vr_qtnaoalt   := vr_qtnaoalt + 1;
          ELSE
            -- Altera A-Inativa
            BEGIN
              UPDATE tbcapt_custodia_frn_investidor t1
              SET
                 t1.flgativo       = '2'
                ,t1.dhatual        = SYSDATE
                ,t1.dsusuario      = 'User:' || USER || ', usuario:' || vr_cdoperad
              WHERE   t1.idfrninv = vr_idfrninv;
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log
                CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);
                -- Monta Log
                vr_cdcritic := 1035;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         'tbcapt_custodia_frn_investidor:' ||
                         ' vr_idfrninv:'   || vr_idfrninv  || 
                         ', vr_vlfaixde:'  || vr_vlfaixde  || 
                         ', vr_vlfaixate:' || vr_vlfaixate || 
                         ', vr_pctaxmen:'  || vr_pctaxmen  || 
                         ', vr_vladicio:'  || vr_vladicio  ||
                         '. ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
            
            -- B - Gera outro para ficar historico
            BEGIN
              INSERT INTO tbcapt_custodia_frn_investidor t1 (
           t1.idfrninv
          ,t1.vlfaixade
          ,t1.vlfaixaate
          ,t1.petaxa_mensal
          ,t1.vladicional
          ,t1.flgativo
          ,t1.dtinclusao
          ,t1.dsusuario
          ) VALUES (
           NULL -- vr_idfrninv 
          ,vr_vlfaixde 
          ,vr_vlfaixate
          ,vr_pctaxmen 
          ,vr_vladicio
          ,'1'
          ,SYSDATE
          ,'User:' || USER || ', usuario:' || vr_cdoperad
          );
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log
                CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);
                -- Monta Log
                vr_cdcritic := 1034;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         'tbcapt_custodia_frn_investidor:' ||
                         ' vr_idfrninv:'   || vr_idfrninv  || 
                         ', vr_vlfaixde:'  || vr_vlfaixde  || 
                         ', vr_vlfaixate:' || vr_vlfaixate || 
                         ', vr_pctaxmen:'  || vr_pctaxmen  || 
                         ', vr_vladicio:'  || vr_vladicio  ||
                         '. ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
        
            vr_qtaltera := vr_qtaltera + 1;
        
          END IF;
          EXIT;
        END IF;
        
        -- Proximo registro
        vr_id_acesso:= vr_tab_novtabinv.NEXT(vr_id_acesso); 
        
      END LOOP;
      
      IF vr_flgativo = 2 THEN
        -- Inativa
        BEGIN
          UPDATE tbcapt_custodia_frn_investidor t1
          SET
             t1.flgativo    = '2'
            ,t1.dhatual     = SYSDATE
            ,t1.dsusuario   = 'User:' || USER || ', usuario:' || vr_cdoperad
          WHERE   t1.idfrninv = vr_idfrninv;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log
            CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);
            -- Monta Log
            vr_cdcritic := 1035;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         'tbcapt_custodia_frn_investidor(2):' ||
                         ' vr_idfrninv:'   || vr_idfrninv  ||
                         ', flgativo:'     || '2'          ||
                         '. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        vr_qtexclus := vr_qtexclus + 1;
      END IF;   
      
    END LOOP;
    
    -- Posiciona no primeiro registro
    vr_id_acesso := vr_tab_novtabinv.FIRST(); 

    WHILE vr_id_acesso IS NOT NULL LOOP
      
      IF vr_id_acesso > 1 THEN
        -- Se "valor De" da faixa 1 for maior que o "valor De" da faixa 2 critica
        -- Se "valor Até" da faixa 2 for menor que "valor Até" da faixa 1 critica
        IF vr_tab_novtabinv(vr_id_acesso-1).vlfaixde >= vr_tab_novtabinv(vr_id_acesso).vlfaixde    THEN
          vr_cdcritic := 1465; -- Faixa com valor invalido
          RAISE vr_exc_saida;
        END IF;
        IF vr_id_acesso <  vr_tab_novtabinv.LAST() THEN
          IF vr_tab_novtabinv(vr_id_acesso).vlfaixate  <= vr_tab_novtabinv(vr_id_acesso-1).vlfaixate  THEN
            vr_cdcritic := 1465; -- Faixa com valor invalido
            RAISE vr_exc_saida;
          END IF;
        END IF;
        -- Se "valor De" da faixa 2 menos o "valor Até" da faixa 1 der maior que 0,01 critica
        IF (vr_tab_novtabinv(vr_id_acesso).vlfaixde - vr_tab_novtabinv(vr_id_acesso-1).vlfaixate ) > 0.01 THEN
          vr_cdcritic := 1465; -- Faixa com valor invalido
          RAISE vr_exc_saida;
        END IF;
      END IF;
      
      --Efetua a reversão da situação da conta
      IF vr_tab_novtabinv(vr_id_acesso).idfrninv IS NULL OR
         vr_tab_novtabinv(vr_id_acesso).idfrninv = 0         THEN
          
        vr_idfrninv  := vr_tab_novtabinv(vr_id_acesso).idfrninv;      
        vr_vlfaixde  := vr_tab_novtabinv(vr_id_acesso).vlfaixde;
        vr_vlfaixate := vr_tab_novtabinv(vr_id_acesso).vlfaixate;
        vr_pctaxmen  := vr_tab_novtabinv(vr_id_acesso).pctaxmen;
        vr_vladicio  := vr_tab_novtabinv(vr_id_acesso).vladicio;
           /*
        dbms_output.put_line(
        'vr_idfrninv:'    || vr_idfrninv  || 
        ', vr_vlfaixde:'  || vr_vlfaixde  || 
        ', vr_vlfaixate:' || vr_vlfaixate || 
        ', vr_pctaxmen:'  || vr_pctaxmen  || 
        ', vr_vladicio:'  || vr_vladicio 
        ); */
        
        BEGIN
          INSERT INTO tbcapt_custodia_frn_investidor t1 (
           t1.idfrninv
          ,t1.vlfaixade
          ,t1.vlfaixaate
          ,t1.petaxa_mensal
          ,t1.vladicional
          ,t1.flgativo
          ,t1.dtinclusao
          ,t1.dsusuario
          ) VALUES (
           NULL -- vr_idfrninv 
          ,vr_vlfaixde 
          ,vr_vlfaixate
          ,vr_pctaxmen 
          ,vr_vladicio
          ,'1'
          ,SYSDATE
          ,'User:' || USER || ', usuario:' || vr_cdoperad
          );
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log
            CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);
            -- Monta Log
            vr_cdcritic := 1034;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         'tbcapt_custodia_frn_investidor(2):' ||
                         ' vr_idfrninv:'   || vr_idfrninv  || 
                         ', vr_vlfaixde:'  || vr_vlfaixde  || 
                         ', vr_vlfaixate:' || vr_vlfaixate || 
                         ', vr_pctaxmen:'  || vr_pctaxmen  || 
                         ', vr_vladicio:'  || vr_vladicio  ||
                         '. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        vr_qtinclus := vr_qtinclus + 1;
        
      END IF;
        
      -- Proximo registro
      vr_id_acesso:= vr_tab_novtabinv.NEXT(vr_id_acesso); 
        
    END LOOP;
    /*
    dbms_output.put_line(
    'vr_qtinclus:'   || vr_qtinclus  || 
    ', vr_qtaltera:' || vr_qtaltera  || 
    ', vr_qtexclus:' || vr_qtexclus  || 
    ', vr_qtnaoalt:' || vr_qtnaoalt  ); */
        
    IF vr_qtinclus > 0 OR
       vr_qtaltera > 0 OR
       vr_qtexclus > 0    THEN
      --Efetua o commit das informções
      COMMIT; 
      pr_cdcritic := 912;  -- Solicitacao efetuada com sucesso 
    ELSE
      pr_cdcritic := 1466; -- Informacoes passadas iguais as informacoes da base de dadaos 
    END IF;
        
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    pr_des_erro := 'OK';
    -- Existe para satisfazer exigência da interface. 
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Sucesso>' || pr_cdcritic||'-'||pr_dscritic || '</Sucesso></Root>');  

    -- Zera nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL );   
  EXCEPTION
    WHEN vr_exc_saida THEN
      --
      IF vr_qtinclus > 0 OR
         vr_qtaltera > 0 OR
         vr_qtexclus > 0    THEN  
        ROLLBACK; 
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic); 
      -- Log de erro de execucao
      pc_log(pr_cdcritic => pr_cdcritic
            ,pr_dscrilog => pr_dscritic ||
                            ' '  || vr_nmaction     ||
                            ' '  || vr_dsparame);      
      -- Devolver criticas 
      -- Como chega aqui criticas 9999 e outras passar um mensagem generica, 
      -- caso precise passar a especifica programando ela mas deixar a generica
      pr_des_erro := 'NOK';          
      IF pr_cdcritic IN ( 1034, 1035, 1037, 9999) THEN
        pr_cdcritic := 1495;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>'); 
      --
    WHEN OTHERS THEN
      -- Quando erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);      
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                     ' ' || SQLERRM ||
                     vr_nmaction    || 
                     ' ' || vr_dsparame;
      --
      IF vr_qtinclus > 0 OR
         vr_qtaltera > 0 OR
         vr_qtexclus > 0    THEN  
        ROLLBACK; 
      END IF;
      -- Log de erro de execucao
      pc_log(pr_cdcritic => vr_cdcritic
            ,pr_dscrilog => vr_dscritic);      
      -- Devolver criticas        
      pr_cdcritic := 1495;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      pr_des_erro := 'NOK';          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                
    
  END pc_atz_faixa_tab_investidor;
   
  
END APLI0007;
/
