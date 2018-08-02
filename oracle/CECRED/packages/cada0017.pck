CREATE OR REPLACE PACKAGE CECRED.cada0017 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : cada0017
  --  Sistema  : Rotinas para informações de cadastro. Chamada pela SOA
  --  Sigla    : CADA
  --  Autor    : Claudio Toshio Nagao (CIS Corporate)
  --  Data     : Maio/2018.                   Ultima atualizacao: 01/08/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: OnLine
  -- Objetivo  :
  --
  --    Alteracoes:
  --
  --  12/06/2018 - Correção da consulta (Cláudio - CIS Corporate)
  --  13/06/2018 - Alteração dos valores da tag dados_conta (Cláudio - CIS Corporate)
  --  15/06/2018 - Melhoria de performance pc_listar_coop_demitidos (Cláudio - CIS Corporate)
  --  01/08/2018 - Cód. Cooperativa Opcional e filtragem por datas (CIS Corporate)
  ---------------------------------------------------------------------------------------------------------------
  PROCEDURE pc_listar_coop_demitidos(pr_cdcooper  IN NUMBER DEFAULT 0, -- Codigo da cooperativa
                                     pr_dtinicio  IN DATE, -- Data de Inicio da Pesquisa
                                     pr_dtfim     IN DATE, -- Data de Fim da Pesquisa
                                     pr_posicao   IN NUMBER, -- Posição do primeiro registro
                                     pr_registros IN NUMBER, -- Registros a serem retornados
                                     pr_cdoperad  IN crapope.cdoperad%type, -- Codigo de Operador
                                     pr_xml_param IN XMLType, -- XML de parametros de entrada
                                     pr_xml_ret   OUT XMLType, -- XML de saida
                                     pr_dscritic  OUT VARCHAR2);
END cada0017;
/
CREATE OR REPLACE PACKAGE BODY CECRED.cada0017 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : cada0017
  --  Sistema  : Rotinas para informações de cadastro. Chamada pela SOA
  --  Sigla    : CADA
  --  Autor    : Claudio Toshio Nagao (CIS Corporate)
  --  Data     : Maio/2018.                   Ultima atualizacao: 01/08/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: OnLine
  -- Objetivo  :
  --
  --    Alteracoes:
  --
  --  12/06/2018 - Correção da consulta (Cláudio - CIS Corporate)
  --  13/06/2018 - Alteração dos valores da tag dados_conta (Cláudio - CIS Corporate)
  --  15/06/2018 - Melhoria de performance pc_listar_coop_demitidos (Cláudio - CIS Corporate)
  --  01/08/2018 - Cód. Cooperativa Opcional (CIS Corporate)
  ---------------------------------------------------------------------------------------------------------------
  
  PROCEDURE pc_listar_coop_demitidos(pr_cdcooper  IN NUMBER DEFAULT 0,       -- Codigo da cooperativa
                                     pr_dtinicio  IN DATE, -- Data de Inicio da Pesquisa
                                     pr_dtfim     IN DATE, -- Data de Fim da Pesquisa
                                     pr_posicao   IN NUMBER, -- Posição do primeiro registro
                                     pr_registros IN NUMBER, -- Registros a serem retornados
                                     pr_cdoperad  IN crapope.cdoperad%type, -- Codigo de Operador
                                     pr_xml_param IN XMLType, -- XML de parametros de entrada
                                     pr_xml_ret   OUT XMLType, -- XML de saida
                                     pr_dscritic  OUT VARCHAR2 -- Retorno de Erro
                                     ) IS
    -- pr_xml_param
    --        flgprevi         - Retorna os registros com previdencia
    -- pr_xml_ret
    --        nrdconta         - Número de conta
    --        dtdesligamento   - Data Desligamento
    --        nrcpfcgc         - Número do CPF/CNPJ do Titular da Conta Corrente
    -- Variaveis gerais
  BEGIN
    DECLARE
      vr_xml xmltype; -- XML que sera enviado
      vr_exc_erro EXCEPTION;
      pr_flgprevi BOOLEAN := (TO_NUMBER(TRIM(pr_xml_param.extract('/Root/params/flgprevi/text()')
                                             .getstringval())) = 1); --> Flag para retornar os registros com previdencia
      vr_tagpos   PLS_INTEGER := 0;
      vr_posfim   NUMBER := pr_posicao + pr_registros - 1;
    
      -- Por motivos de desempenhos serão criados 4 cursores no lugar de uma expressão "true"
      -- Cursor para buscar os dados da contas
         
      -- Filtro por cooperativa
      CURSOR cr_dados_coop_contas IS
        Select /*+ FIRST_ROWS(75) */
         CDCOOPER, -- COD COOPERATIVA
         NRDCONTA, -- NUMERO DE CONTA
         to_char(DTDEMISS, 'dd/mm/yyyy HH24:mi:ss') DTDESLIGAMENTO, -- DATA DESLIGAMENTO
         floor(months_between(sysdate, DTDEMISS) / 12) QTANOS_DESLIGAMENTO, -- TEMPO DE DESLIGAMENTO
         CDMOTDEM CDMOTIVO_DESLIGAMENTO, -- MOTIVO DE DEMISSÃO
         INRISCTL INRISCO_CREDITO, -- INDICADOR DE RISCO DO COOPERADO (DE A ATE H)
         DTRISCTL DTRISCO_CREDITO, -- Data em que foi atribuida a nota do risco do titular
         decode(INPESSOA, 1, 'F', 'J') TPPESSOA,
         INPESSOA,
         NRCPFCGC
          From (Select A.CDCOOPER,
                       A.NRDCONTA,
                       A.DTDEMISS,
                       A.CDMOTDEM,
                       A.INRISCTL,
                       A.DTRISCTL,
                       A.INPESSOA,
                       A.NRCPFCGC,
                       row_number() over (order by A.CDCOOPER,A.NRDCONTA) ROWNUMBER
                  From crapass A
                 Where A.CDCOOPER = pr_cdcooper 
                   and A.DTDEMISS between pr_dtinicio and pr_dtfim)
         Where ROWNUMBER between pr_posicao and vr_posfim;

      -- Todas as cooperativas
      CURSOR cr_dados_contas IS
        Select /*+ FIRST_ROWS(75) */
         CDCOOPER, -- COD COOPERATIVA
         NRDCONTA, -- NUMERO DE CONTA
         to_char(DTDEMISS, 'dd/mm/yyyy HH24:mi:ss') DTDESLIGAMENTO, -- DATA DESLIGAMENTO
         floor(months_between(sysdate, DTDEMISS) / 12) QTANOS_DESLIGAMENTO, -- TEMPO DE DESLIGAMENTO
         CDMOTDEM CDMOTIVO_DESLIGAMENTO, -- MOTIVO DE DEMISSÃO
         INRISCTL INRISCO_CREDITO, -- INDICADOR DE RISCO DO COOPERADO (DE A ATE H)
         DTRISCTL DTRISCO_CREDITO, -- Data em que foi atribuida a nota do risco do titular
         decode(INPESSOA, 1, 'F', 'J') TPPESSOA,
         INPESSOA,
         NRCPFCGC
          From (Select A.CDCOOPER,
                       A.NRDCONTA,
                       A.DTDEMISS,
                       A.CDMOTDEM,
                       A.INRISCTL,
                       A.DTRISCTL,
                       A.INPESSOA,
                       A.NRCPFCGC,
                       row_number() over(order by A.CDCOOPER,A.NRDCONTA) ROWNUMBER
                  From crapass A
                 Where A.DTDEMISS between pr_dtinicio and pr_dtfim)
         Where ROWNUMBER between pr_posicao and vr_posfim;

      -- Previdencia contratada e filtrada por cooperativa
      CURSOR cr_dados_coop_contas_prev IS
        Select 
               CDCOOPER, -- COD COOPERATIVA
               NRDCONTA, -- NUMERO DE CONTA
               to_char(DTDEMISS, 'dd/mm/yyyy HH24:mi:ss') DTDESLIGAMENTO, -- DATA DESLIGAMENTO
               floor(months_between(sysdate, DTDEMISS) / 12) QTANOS_DESLIGAMENTO, -- TEMPO DE DESLIGAMENTO
               CDMOTDEM CDMOTIVO_DESLIGAMENTO, -- MOTIVO DE DEMISSÃO
               INRISCTL INRISCO_CREDITO, -- INDICADOR DE RISCO DO COOPERADO (DE A ATE H)
               DTRISCTL DTRISCO_CREDITO, -- Data em que foi atribuida a nota do risco do titular
               decode(INPESSOA, 1, 'F', 'J') TPPESSOA,
               INPESSOA,
               NRCPFCGC
          From (Select A.CDCOOPER,
                       A.NRDCONTA,
                       A.DTDEMISS,
                       A.CDMOTDEM,
                       A.INRISCTL,
                       A.DTRISCTL,
                       A.INPESSOA,
                       A.NRCPFCGC,
                       row_number() over (order by A.CDCOOPER,A.NRDCONTA) ROWNUMBER
                  From crapass A, tbprevidencia_conta P
                 Where A.CDCOOPER = pr_cdcooper
                   and A.CDCOOPER = P.CDCOOPER
                   and A.NRDCONTA = P.NRDCONTA
                   and A.DTDEMISS between pr_dtinicio and pr_dtfim)
         Where ROWNUMBER between pr_posicao and vr_posfim;

      -- Previdencia contratada e todas as cooperativas 
      CURSOR cr_dados_contas_prev IS
        Select 
               CDCOOPER, -- COD COOPERATIVA
               NRDCONTA, -- NUMERO DE CONTA
               to_char(DTDEMISS, 'dd/mm/yyyy HH24:mi:ss') DTDESLIGAMENTO, -- DATA DESLIGAMENTO
               floor(months_between(sysdate, DTDEMISS) / 12) QTANOS_DESLIGAMENTO, -- TEMPO DE DESLIGAMENTO
               CDMOTDEM CDMOTIVO_DESLIGAMENTO, -- MOTIVO DE DEMISSÃO
               INRISCTL INRISCO_CREDITO, -- INDICADOR DE RISCO DO COOPERADO (DE A ATE H)
               DTRISCTL DTRISCO_CREDITO, -- Data em que foi atribuida a nota do risco do titular
               decode(INPESSOA, 1, 'F', 'J') TPPESSOA,
               INPESSOA,
               NRCPFCGC
          From (Select A.CDCOOPER,
                       A.NRDCONTA,
                       A.DTDEMISS,
                       A.CDMOTDEM,
                       A.INRISCTL,
                       A.DTRISCTL,
                       A.INPESSOA,
                       A.NRCPFCGC,
                       row_number() over (order by A.CDCOOPER,A.NRDCONTA) ROWNUMBER
                  From crapass A, tbprevidencia_conta P
                 Where A.CDCOOPER = P.CDCOOPER
                   and A.NRDCONTA = P.NRDCONTA
                   and A.DTDEMISS between pr_dtinicio and pr_dtfim)
         Where ROWNUMBER between pr_posicao and vr_posfim;

      r_dados_contas cr_dados_contas%ROWTYPE;
    
    BEGIN
      vr_xml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
      IF pr_cdcooper = 0 THEN -- Todas as cooperativas
        IF pr_flgprevi THEN
          OPEN cr_dados_contas_prev;
        ELSE
          OPEN cr_dados_contas;
        END IF;
      ELSE -- Filtro por cooperativa
        IF pr_flgprevi THEN
          OPEN cr_dados_coop_contas_prev;
        ELSE
          OPEN cr_dados_coop_contas;
        END IF;
      END IF;
    
      LOOP
        IF cr_dados_contas%ISOPEN THEN
            FETCH cr_dados_contas INTO r_dados_contas;
            EXIT WHEN cr_dados_contas%NOTFOUND;
        ELSIF cr_dados_coop_contas%ISOPEN THEN
            FETCH cr_dados_coop_contas INTO r_dados_contas;
            EXIT WHEN cr_dados_coop_contas%NOTFOUND;
        ELSIF cr_dados_contas_prev%ISOPEN THEN
            FETCH cr_dados_contas_prev INTO r_dados_contas;
            EXIT WHEN cr_dados_contas_prev%NOTFOUND;
        ELSIF cr_dados_coop_contas_prev%ISOPEN THEN
            FETCH cr_dados_coop_contas_prev INTO r_dados_contas;
            EXIT WHEN cr_dados_coop_contas_prev%NOTFOUND;
        END IF;  

        IF (vr_tagpos = 0) THEN
        gene0007.pc_insere_tag(pr_xml      => vr_xml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'dados_conta',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);
        END IF;
        -- Insere os detalhes
        gene0007.pc_insere_tag(pr_xml      => vr_xml,
                               pr_tag_pai  => 'dados_conta',
                               pr_posicao  => 0,
                               pr_tag_nova => 'conta',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_xml,
                               pr_tag_pai  => 'conta',
                               pr_posicao  => vr_tagpos,
                               pr_tag_nova => 'cdcooper',
                               pr_tag_cont => r_dados_contas.cdcooper,
                               pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_xml,
                               pr_tag_pai  => 'conta',
                               pr_posicao  => vr_tagpos,
                               pr_tag_nova => 'nrdconta',
                               pr_tag_cont => r_dados_contas.nrdconta,
                               pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_xml,
                               pr_tag_pai  => 'conta',
                               pr_posicao  => vr_tagpos,
                               pr_tag_nova => 'dtdesligamento',
                               pr_tag_cont => r_dados_contas.dtdesligamento,
                               pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_xml,
                               pr_tag_pai  => 'conta',
                               pr_posicao  => vr_tagpos,
                               pr_tag_nova => 'qtanos_desligamento',
                               pr_tag_cont => r_dados_contas.qtanos_desligamento,
                               pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_xml,
                               pr_tag_pai  => 'conta',
                               pr_posicao  => vr_tagpos,
                               pr_tag_nova => 'cdmotivo_desligamento',
                               pr_tag_cont => r_dados_contas.cdmotivo_desligamento,
                               pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_xml,
                               pr_tag_pai  => 'conta',
                               pr_posicao  => vr_tagpos,
                               pr_tag_nova => 'inrisco_credito',
                               pr_tag_cont => r_dados_contas.inrisco_credito,
                               pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_xml,
                               pr_tag_pai  => 'conta',
                               pr_posicao  => vr_tagpos,
                               pr_tag_nova => 'dtrisco_credito',
                               pr_tag_cont => to_char(r_dados_contas.dtrisco_credito,
                                                      'dd/mm/yyyy hh24:mi:ss'),
                               pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_xml,
                               pr_tag_pai  => 'conta',
                               pr_posicao  => vr_tagpos,
                               pr_tag_nova => 'tppessoa',
                               pr_tag_cont => r_dados_contas.tppessoa,
                               pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_xml,
                               pr_tag_pai  => 'conta',
                               pr_posicao  => vr_tagpos,
                               pr_tag_nova => 'inpessoa',
                               pr_tag_cont => r_dados_contas.inpessoa,
                               pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_xml,
                               pr_tag_pai  => 'conta',
                               pr_posicao  => vr_tagpos,
                               pr_tag_nova => 'nrcpfcgc',
                               pr_tag_cont => r_dados_contas.nrcpfcgc,
                               pr_des_erro => pr_dscritic);
      
        vr_tagpos := vr_tagpos + 1;
      END LOOP;
      IF cr_dados_contas%ISOPEN THEN
         CLOSE cr_dados_contas;
      ELSIF cr_dados_coop_contas%ISOPEN THEN
         CLOSE cr_dados_coop_contas;  
      ELSIF cr_dados_contas_prev%ISOPEN THEN
         CLOSE cr_dados_contas_prev;  
      ELSIF cr_dados_coop_contas_prev%ISOPEN THEN
         CLOSE cr_dados_coop_contas_prev;  
      END IF;
      
      pr_xml_ret := vr_xml;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Erro já tratado, pr_dscritic já esta populado.
        NULL;
      WHEN OTHERS THEN
        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na pc_listar_coop_demitidos: ' ||
                       SQLERRM;
    END;
  END pc_listar_coop_demitidos;
END cada0017;
/
