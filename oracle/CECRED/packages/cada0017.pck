CREATE OR REPLACE PACKAGE CECRED.cada0017 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : cada0017
  --  Sistema  : Rotinas para informa��es de cadastro. Chamada pela SOA
  --  Sigla    : CADA
  --  Autor    : Claudio Toshio Nagao (CIS Corporate)
  --  Data     : Maio/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: OnLine
  -- Objetivo  :
  --
  --    Alteracoes:
  --
  --  12/06/2018 - Corre��o da consulta (Cl�udio - CIS Corporate)
  --  13/06/2018 - Altera��o dos valores da tag dados_conta (Cl�udio - CIS Corporate)
  ---------------------------------------------------------------------------------------------------------------
  PROCEDURE pc_listar_coop_demitidos(pr_cdcooper  IN NUMBER, -- Codigo da cooperativa
                                     pr_dtinicio  IN DATE, -- Data de Inicio da Pesquisa
                                     pr_dtfim     IN DATE, -- Data de Fim da Pesquisa
                                     pr_posicao   IN NUMBER, -- Posi��o do primeiro registro
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
  --  Sistema  : Rotinas para informa��es de cadastro. Chamada pela SOA
  --  Sigla    : CADA
  --  Autor    : Claudio Toshio Nagao (CIS Corporate)
  --  Data     : Maio/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: OnLine
  -- Objetivo  :
  --
  --    Alteracoes:
  --
  --  12/06/2018 - Corre��o da consulta (Cl�udio - CIS Corporate)
  --  13/06/2018 - Altera��o dos valores da tag dados_conta (Cl�udio - CIS Corporate)
  ---------------------------------------------------------------------------------------------------------------
  PROCEDURE pc_listar_coop_demitidos(pr_cdcooper  IN NUMBER, -- Codigo da cooperativa
                                     pr_dtinicio  IN DATE, -- Data de Inicio da Pesquisa
                                     pr_dtfim     IN DATE, -- Data de Fim da Pesquisa
                                     pr_posicao   IN NUMBER, -- Posi��o do primeiro registro
                                     pr_registros IN NUMBER, -- Registros a serem retornados
                                     pr_cdoperad  IN crapope.cdoperad%type, -- Codigo de Operador
                                     pr_xml_param IN XMLType, -- XML de parametros de entrada
                                     pr_xml_ret   OUT XMLType, -- XML de saida
                                     pr_dscritic  OUT VARCHAR2 -- Retorno de Erro
                                     ) IS
    -- pr_xml_param
    --        flgprevi         - Retorna os registros com previdencia
    -- pr_xml_ret
    --        nrdconta         - N�mero de conta
    --        dtdesligamento   - Data Desligamento
    --        nrcpfcgc         - N�mero do CPF/CNPJ do Titular da Conta Corrente
    -- Variaveis gerais
  BEGIN
    DECLARE
      vr_xml xmltype; -- XML que sera enviado
      vr_exc_erro EXCEPTION;
      pr_flgprevi NUMBER := TO_NUMBER(TRIM(pr_xml_param.extract('/Root/params/flgprevi/text()')
                                           .getstringval())); --> Flag para retornar os registros com previdencia
      vr_tagpos   PLS_INTEGER := 0;
      vr_posfim   NUMBER := pr_posicao + pr_registros;
    
      -- Cursor para buscar os dados da contas
      CURSOR cr_dados_contas IS
        SELECT a.NRDCONTA NRDCONTA -- NUMERO DE CONTA
              ,
               to_char(a.dtdemiss, 'dd/mm/yyyy HH24:mi:ss') DTDESLIGAMENTO -- DATA DESLIGAMENTO
              ,
               to_char(sysdate, 'yyyy') - to_char(a.dtdemiss, 'yyyy') QTANOS_DESLIGAMENTO -- TEMPO DE DESLIGAMENTO
              ,
               a.cdmotdem CDMOTIVO_DESLIGAMENTO -- MOTIVO DE DEMISS�O
              ,
               a.inrisctl INRISCO_CREDITO -- INDICADOR DE RISCO DO COOPERADO (DE A ATE H)
              ,
               a.dtrisctl DTRISCO_CREDITO -- Data em que foi atribuida a nota do risco do titular
              ,
               decode(a.inpessoa, 1, 'F', 'J') tppessoa,
               a.inpessoa,
               a.nrcpfcgc
          FROM crapass A
         WHERE A.CDCOOPER = pr_cdcooper
           AND a.dtdemiss BETWEEN pr_dtinicio and pr_dtfim
           AND ((EXISTS (select nrdconta
                          from tbprevidencia_conta
                         where nrdconta = a.nrdconta
                            and CDCOOPER = pr_cdcooper)) OR
               pr_flgprevi = 0)
           AND rownum >= pr_posicao
           AND rownum <= pr_registros;
    
    BEGIN
      vr_xml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      FOR r_dados_contas in cr_dados_contas LOOP
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
      pr_xml_ret := vr_xml;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Erro j� tratado, pr_dscritic j� esta populado.
        NULL;
      WHEN OTHERS THEN
        -- Montar descri��o de erro n�o tratado
        pr_dscritic := 'Erro n�o tratado na pc_listar_coop_demitidos: ' ||
                       SQLERRM;
    END;
  END pc_listar_coop_demitidos;
END cada0017;
/
