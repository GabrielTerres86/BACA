CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_PREAPV IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_SCORE
  --  Sistema  : Aimaro
  --  Sigla    : CRED
  --  Autor    : Marcos (Envolti)
  --  Data     : Outubro/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para interface Web da opção Pre Aprovado na Atenda
  --
  --
  ---------------------------------------------------------------------------------------------------------------                     
  
  /* Resumo Pre Aprovado na Tela Atenda*/
  PROCEDURE pc_resumo_pre_aprovado(pr_nrdconta IN crapass.nrdconta%TYPE -- Conta desejado
                                   /* Parametros base da Mensageria */
                                  ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);        --> Erros do processo  


  /* Motivos de Não Ter Pre-Aprovado na Carga Atual */
  PROCEDURE pc_lista_motivos_sem_preapv(pr_nrdconta IN crapass.nrdconta%TYPE -- Conta desejado
                                        /* Parametros base da Mensageria */
                                       ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);        --> Erros do processo  

  -- Lista de motivos filtrando por tipo 0-DESbloqueio 1-Bloqueio 
  PROCEDURE pc_combo_motivos(pr_flgtipo   IN NUMBER                --> MENSAGERIA flgtipo 0-DESbloqueio 1-Bloqueio 
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
									   
									   -- Listagem dos Motivos
  PROCEDURE pc_lista_motivos_tela(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
  
  -- Mantem status do pre aprovado do cooperado
  PROCEDURE pc_mantem_param_preapv(pr_nrdconta              IN crapass.nrdconta%TYPE
                                  ,pr_flglibera_pre_aprv    IN NUMBER
                                  ,pr_dtatualiza_pre_aprv   IN VARCHAR2
                                  ,pr_idmotivo              IN NUMBER DEFAULT 0
                                  -- Mensageria
                                  ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK

END TELA_ATENDA_PREAPV;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_PREAPV AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_PREAPV
  --  Sistema  : Aimaro
  --  Sigla    : CRED
  --  Autor    : Marcos (Envolti)
  --  Data     : Outubro/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para interface Web da opção Pre Aprovado na Atenda
  --
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Resumo Pre Aprovado na Tela Atenda*/
  PROCEDURE pc_resumo_pre_aprovado(pr_nrdconta IN crapass.nrdconta%TYPE -- Conta desejado
                                   /* Parametros base da Mensageria */
                                  ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_resumo_pre_aprovado
    Sistema : Ayllos Web
    Autor   : Marcos Martini (Envolti)
    Data    : Fevereiro - 2019.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar o Resumo do Calculo do Pre Aprovado

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variaveis de locais
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_sempaprv PLS_INTEGER := 0;

      -- Busca do CPF ou CNPJ base do Cooperado
      CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT ass.inpessoa
              ,ass.nrcpfcnpj_base
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      vr_inpessoa crapass.inpessoa%TYPE;
      vr_nrcpfcnpj_base crapass.nrcpfcnpj_base%TYPE;

      -- Buscar dados da configuração Pessoa X Produto X Operação
      vr_flgativa    NUMBER;
      vr_dtatualiza  DATE;
      vr_idmotivo    NUMBER;

      -- Busca do histórico de manutenção da configuração Pessoa X Produto X Operação
      CURSOR cr_hist_param(pr_cdcooper crapcop.cdcooper%TYPE
                          ,pr_tppessoa crapass.indnivel%TYPE
                          ,pr_nrcpfcnpj_base crapass.nrcpfcnpj_base%TYPE) IS
        SELECT decode(hst.flglibera,1,'Liberar','Bloquear') flglibera
              ,to_char(hst.dtoperac,'dd/mm/rrrr hh24:mi') dtoperac
              ,to_char(hst.dtvigencia_paramet,'dd/mm/rr') dtvigencia_paramet
              ,case when mot.flgexibe = 1 then
                    hst.idmotivo|| ' - ' || mot.dsmotivo
               else '' end dsmotivo
              ,decode(ope.cdoperad,'1',NULL,ope.cdoperad||'-'||ope.nmoperad) nmoperad
          FROM tbcc_hist_param_pessoa_prod hst
              ,tbgen_motivo                mot
              ,crapope                     ope
         WHERE hst.cdcooper = ope.cdcooper
           AND hst.cdoperad = ope.cdoperad
           AND hst.idmotivo = mot.idmotivo
           AND hst.cdproduto        = 25 -- PreAprovado
           AND hst.cdoperac_produto = 1  -- Oferta produto
           AND hst.cdcooper = pr_cdcooper
           AND hst.tppessoa = pr_tppessoa
           AND hst.nrcpfcnpj_base = pr_nrcpfcnpj_base
         ORDER BY hst.dtoperac DESC;
      vr_contador INTEGER := 0;

      -- Busca dos detalhes da Carga
      CURSOR cr_carga(pr_idcarga  tbepr_carga_pre_aprv.idcarga%TYPE
                     ,pr_dtmvtolt DATE) IS
        SELECT decode(car.tpcarga,1,'Manual',2,'Automática') dstpcarga
              ,car.dscarga
              ,decode(car.flgcarga_bloqueada,1,'Sim',0,'Não') flgcarga_bloqueada
              ,decode(car.tpcarga,1,'Vigencia da Carga:'||to_char(car.dtliberacao,'DD/MM/RRRR')|| ' a '||nvl(to_char(car.dtfinal_vigencia,'DD/MM/RRRR'),'indeterminado'),NULL) dsvigencia
              ,CASE WHEN car.tpcarga = 1 THEN
                 TO_CHAR(car.dtliberacao,'DD/MM/RRRR')
               ELSE
                 NULL
               END dtliberacao
              ,CASE WHEN car.tpcarga = 1 THEN
                 NVL(to_char(car.dtfinal_vigencia,'DD/MM/RRRR'),'indeterminado')
               ELSE
                 NULL
               END dtfinal_vigencia
              ,CASE WHEN car.tpcarga = 1 THEN
                 CASE
                  WHEN NVL(dtfinal_vigencia, pr_dtmvtolt +1) < pr_dtmvtolt THEN
                       'Fora da vigência'
                  WHEN car.flgcarga_bloqueada = 1 THEN
                       'Bloqueada'
                 ELSE 'Liberada'
                 END
               ELSE
                 NULL
               END SITUACAO_CARGA -- Utilizado para tratar na tela a informação correta P442 CARD 6.3.18
              ,car.tpcarga
          FROM tbepr_carga_pre_aprv car
         WHERE car.idcarga = pr_idcarga;
      rw_carga cr_carga%ROWTYPE;

      -- Busca contratos aprovados sem liberação para finalidade 68
      CURSOR cr_crawepr(pr_nrcpfcnpj_base  crapass.nrcpfcnpj_base%TYPE
                       ,pr_cdcooper        crawepr.cdcooper%TYPE) IS
        SELECT SUM(wer.vlemprst) vlemprst
        FROM crawepr wer
        WHERE wer.insitapr = 1
          AND wer.insitest = 3
          AND wer.dtaprova IS NOT NULL
          AND wer.nrdconta IN (SELECT ass.nrdconta
                               FROM crapass ass
                               WHERE ass.cdcooper = wer.cdcooper
                                 AND ass.nrcpfcnpj_base = pr_nrcpfcnpj_base)
          AND wer.cdfinemp = 68
          AND wer.cdcooper = pr_cdcooper
          AND NOT EXISTS (SELECT 1
                          FROM crapepr epr
                          WHERE epr.cdcooper = wer.cdcooper
                            AND epr.nrdconta = wer.nrdconta
                            AND epr.nrctremp = wer.nrctremp);
      rw_crawepr cr_crawepr%ROWTYPE;

      -- Cursor para buscar registros de bloqueio de carga manual
      CURSOR cr_regbloq(pr_cdcooper        tbcc_hist_param_pessoa_prod.cdcooper%TYPE
                       ,pr_nrcpfcnpj_base  tbcc_hist_param_pessoa_prod.nrcpfcnpj_base%TYPE
                       ,pr_dtsistema       DATE) IS
        SELECT flglibera
        FROM (SELECT h.*
              FROM tbcc_hist_param_pessoa_prod h
              WHERE h.cdcooper = pr_cdcooper
                AND h.nrcpfcnpj_base = pr_nrcpfcnpj_base
                AND (TRUNC(h.dtvigencia_paramet) IS NULL
                     OR h.dtvigencia_paramet >= trunc(pr_dtsistema))
              ORDER BY h.idregistro DESC)
        WHERE ROWNUM = 1;
      rw_regbloq cr_regbloq%ROWTYPE;
      
      -- Busca contratos liberados com saldo em aberto para finalidade 68
      CURSOR cr_crapepr(pr_nrcpfcnpj_base  crapass.nrcpfcnpj_base%TYPE
                       ,pr_cdcooper        crapepr.cdcooper%TYPE) IS
        SELECT SUM(vlsdeved) vlsdeved
        FROM(SELECT CASE WHEN epr.vlsdevat = 0 THEN
                       epr.vlsdeved
                     ELSE
                       epr.vlsdevat
                     END vlsdeved
              FROM crapepr epr
              WHERE epr.cdcooper = pr_cdcooper
                AND epr.inliquid = 0
                AND epr.nrdconta IN (SELECT ass.nrdconta
                                     FROM crapass ass
                                     WHERE ass.cdcooper = epr.cdcooper
                                       AND ass.nrcpfcnpj_base = pr_nrcpfcnpj_base)
                AND epr.cdfinemp = 68);
      rw_crapepr cr_crapepr%ROWTYPE;

      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Variaveis do Calculo do Pre Aprovado
      vr_idcarga           crapcpa.iddcarga%TYPE;
      vr_idcargablq        crapcpa.iddcarga%TYPE;
      vr_nrfimpre          craplcr.nrfimpre%TYPE;
      vr_vlpot_parc_max    crapcpa.vlpot_parc_maximo%TYPE;
      vr_vlpot_lim_max     crapcpa.vlpot_lim_max%TYPE;
      vr_vl_scr_61_90      crapvop.vlvencto%TYPE;
      vr_vl_scr_61_90_cje  crapvop.vlvencto%TYPE;
      vr_vlope_pos_scr     crapepr.vlsdeved%TYPE;
      vr_vlope_pos_scr_cje crapepr.vlsdeved%TYPE;
      vr_vlprop_andamt     crapepr.vlsdeved%TYPE;
      vr_vlprop_andamt_cje crapepr.vlsdeved%TYPE;
      vr_vlparcel          NUMBER;
      vr_vldispon          NUMBER;
      vr_dscarga           VARCHAR2(1000);
      vr_sumempr           NUMBER;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;


      -- Reaproveitamento de codigo
      PROCEDURE pc_envia_chave_valor(pr_posicao IN NUMBER
                                    ,pr_deschav IN VARCHAR2
                                    ,pr_dsvalor IN VARCHAR2) IS
      BEGIN
        -- Enviar Chave
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Valores'
                              ,pr_posicao  => pr_posicao
                              ,pr_tag_nova => 'Chave'
                              ,pr_tag_cont => pr_deschav
                              ,pr_des_erro => vr_dscritic);
        -- Enviar Valor
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Valores'
                              ,pr_posicao  => pr_posicao
                              ,pr_tag_nova => 'Valor'
                              ,pr_tag_cont => pr_dsvalor
                              ,pr_des_erro => vr_dscritic);
      END;

    BEGIN
      -- Validar chamada
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
        RAISE vr_exc_saida;
      END IF;

      -- Leitura do calendario da CECRED
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      -- Buscar cpf ou cnpj base
      OPEN cr_crapass(vr_cdcooper);
      FETCH cr_crapass
       INTO vr_inpessoa,vr_nrcpfcnpj_base;
      CLOSE cr_crapass;

      -- Busca dados do pre aprovado
      cada0006.pc_busca_param_pessoa_prod(pr_cdcooper           => vr_cdcooper
                                         ,pr_nrdconta           => pr_nrdconta
                                         ,pr_tppessoa           => vr_inpessoa
                                         ,pr_nrcpfcnpj_base     => vr_nrcpfcnpj_base
                                         ,pr_cdproduto          => 25 -- PreAprovado
                                         ,pr_cdoperac_produto   => 1 -- Oferta
                                         ,pr_flglibera          => vr_flgativa
                                         ,pr_dtvigencia_paramet => vr_dtatualiza
                                         ,pr_idmotivo           => vr_idmotivo
                                         ,pr_dscritic           => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'PreAprv'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Buscar a carga atual
      vr_idcargablq := empr0002.fn_idcarga_pre_aprovado(pr_cdcooper        => vr_cdcooper
                                                       ,pr_tppessoa        => vr_inpessoa
                                                       ,pr_nrcpf_cnpj_base => vr_nrcpfcnpj_base);
      vr_idcarga := empr0002.fn_idcarga_pre_aprovado(pr_cdcooper        => vr_cdcooper
                                                    ,pr_tppessoa        => vr_inpessoa
                                                    ,pr_nrcpf_cnpj_base => vr_nrcpfcnpj_base);

      -- Busca dos detalhes da Carga
      IF vr_idcarga > 0 THEN
        OPEN cr_carga(vr_idcarga, rw_crapdat.dtmvtolt);
        FETCH cr_carga INTO rw_carga;
        CLOSE cr_carga;
      END IF;
      
      -- Buscar se existe carga manual e seus respectivos bloqueios
      OPEN cr_regbloq(pr_cdcooper        => vr_cdcooper
                     ,pr_nrcpfcnpj_base  => vr_nrcpfcnpj_base
                     ,pr_dtsistema       => rw_crapdat.dtmvtolt);
      FETCH cr_regbloq INTO rw_regbloq;
        
      IF cr_regbloq%FOUND THEN
        vr_flgativa := rw_regbloq.flglibera;
      ELSE     
        vr_flgativa := 1;
      END IF;
        
      CLOSE cr_regbloq;

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'PreAprv'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'flgbloq'
                            ,pr_tag_cont => vr_flgativa
                            ,pr_des_erro => vr_dscritic);
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'PreAprv'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'idmotivo'
                            ,pr_tag_cont => vr_idmotivo
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'PreAprv'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dsmotivo'
                            ,pr_tag_cont => empr0002.fn_busca_motivo(pr_idmotivo => vr_idmotivo)
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'PreAprv'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dtatualiza'
                            ,pr_tag_cont => vr_dtatualiza
                            ,pr_des_erro => vr_dscritic);

      -- No raiz do Lista Históricos
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'PreAprv'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Historicos'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Histórico do PreAprovado - somente para cargas manuais
      FOR rw_hist IN cr_hist_param(vr_cdcooper,vr_inpessoa,vr_nrcpfcnpj_base) LOOP
        -- Enviar os campos
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Historicos'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Historico'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Historico'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'flglibera'
                              ,pr_tag_cont => rw_hist.flglibera
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Historico'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dtoperac'
                              ,pr_tag_cont => rw_hist.dtoperac
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Historico'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dtvigencia_paramet'
                              ,pr_tag_cont => rw_hist.dtvigencia_paramet
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Historico'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dsmotivo'
                              ,pr_tag_cont => rw_hist.dsmotivo
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Historico'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'nmoperad'
                              ,pr_tag_cont => rw_hist.nmoperad
                              ,pr_des_erro => vr_dscritic);
        -- Incrementar
        vr_contador := vr_contador + 1;
      END LOOP;

      -- Se encontrou Carga Ativa
      IF vr_idcarga IS NULL OR vr_idcarga = 0 THEN
        -- Mostrar mensagem que condizem com o fato de não existir PreAprovado
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'PreAprv'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Mensagem'
                              ,pr_tag_cont => 'Cooperado sem Pre-Aprovado disponivel.'
                              ,pr_des_erro => vr_dscritic);
      ELSE
        -- Acionar o calculo do PreAprovado
        empr0002.pc_calc_pre_aprovado_analitico(pr_cdcooper          => vr_cdcooper
                                               ,pr_tppessoa          => vr_inpessoa
                                               ,pr_nrcpf_cnpj_base   => vr_nrcpfcnpj_base
                                               ,pr_idcarga           => vr_idcarga
                                               ,pr_nrfimpre          => vr_nrfimpre
                                               ,pr_vlpot_parc_max    => vr_vlpot_parc_max
                                               ,pr_vlpot_lim_max     => vr_vlpot_lim_max
                                               ,pr_vl_scr_61_90      => vr_vl_scr_61_90
                                               ,pr_vl_scr_61_90_cje  => vr_vl_scr_61_90_cje
                                               ,pr_vlope_pos_scr     => vr_vlope_pos_scr
                                               ,pr_vlope_pos_scr_cje => vr_vlope_pos_scr_cje
                                               ,pr_vlprop_andamt     => vr_vlprop_andamt
                                               ,pr_vlprop_andamt_cje => vr_vlprop_andamt_cje
                                               ,pr_vlparcel          => vr_vlparcel
                                               ,pr_vldispon          => vr_vldispon
                                               ,pr_dscritic          => vr_dscritic);

        -- Se houve critica
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        IF rw_carga.tpcarga = 1 THEN
          vr_dscarga := vr_idcarga||' - '||rw_carga.dscarga;
        END IF;

        -- Enviar a mensagem resumo do PreAprovado disponivel
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'PreAprv'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Mensagem'
                              ,pr_tag_cont => 'Cooperado com Pre-Aprovado disponivel:<br>'
                                           || 'Identificacao da Carga:'||vr_idcarga||'-'||rw_carga.dscarga||'<br>'
                                           || 'Tipo da Carga:'||rw_carga.dstpcarga||'<br>'
                                           || rw_carga.dsvigencia
                              ,pr_des_erro => vr_dscritic);
      END IF;

      -- No raiz do Lista Valores
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'PreAprv'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Valores'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      IF vr_inpessoa <> 1 THEN
         vr_vlope_pos_scr_cje := NULL;
         vr_vlprop_andamt_cje := NULL;
         vr_vl_scr_61_90_cje := NULL;
      END IF;

      -- Cara variavel do calculo será enviada num conceito de chave/valor
      IF vr_idcargablq = 0 THEN
        pc_envia_chave_valor(0,'Quantidade máxima de prestações da linha de crédito',NULL);
        pc_envia_chave_valor(0,'Parcela de Pré-Aprovado Disponível',NULL);
        pc_envia_chave_valor(0,'Limite de Pré-Aprovado Disponível',NULL);
        pc_envia_chave_valor(0,'Potencial máximo de limite do CPF/CNPJ',NULL);
        pc_envia_chave_valor(0,'Potencial máximo de parcela do CPF/CNPJ',NULL);
        pc_envia_chave_valor(0,'Utilização do valor da parcela',NULL);
        pc_envia_chave_valor(0,'Parcela SCR 61 a 90 proponente',NULL);
        pc_envia_chave_valor(0,'Parcela SCR 61 a 90 cônjuge',NULL);
        pc_envia_chave_valor(0,'Parcela de operações internas que ainda não constam no SCR proponente',NULL);
        pc_envia_chave_valor(0,'Parcela de operações internas que ainda não constam no SCR cônjuge',NULL);
        pc_envia_chave_valor(0,'Parcela de operações internas aprovadas e não liberadas proponente',NULL);
        pc_envia_chave_valor(0,'Parcela de operações internas aprovadas e não liberadas cônjuge',NULL);
        pc_envia_chave_valor(0,'Tipo de Carga',NULL);
        pc_envia_chave_valor(0,'SAS Potencial Limite',NULL);
        pc_envia_chave_valor(0,'Valor utilizado de pré-aprovado (finalidade 68)',NULL);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'PreAprv'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'statusCarga'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
      ELSE
        --Buscar somário de empréstimos
        OPEN cr_crawepr(pr_nrcpfcnpj_base  => vr_nrcpfcnpj_base
                       ,pr_cdcooper        => vr_cdcooper);
        FETCH cr_crawepr INTO rw_crawepr;
        CLOSE cr_crawepr;

        OPEN cr_crapepr(pr_nrcpfcnpj_base  => vr_nrcpfcnpj_base
                       ,pr_cdcooper        => vr_cdcooper);
        FETCH cr_crapepr INTO rw_crapepr;
        CLOSE cr_crapepr;

        vr_sumempr := NVL(rw_crawepr.vlemprst, 0) + NVL(rw_crapepr.vlsdeved, 0);

        pc_envia_chave_valor(0,'Quantidade máxima de prestações da linha de crédito',vr_nrfimpre);
        pc_envia_chave_valor(0,'Parcela de Pré-Aprovado Disponível',TO_CHAR(vr_vlparcel, 'FM999G999G990D00'));
        pc_envia_chave_valor(0,'Limite de Pré-Aprovado Disponível',TO_CHAR(vr_vldispon, 'FM999G999G990D00'));
        pc_envia_chave_valor(0,'Potencial máximo de limite do CPF/CNPJ',TO_CHAR(vr_vlpot_lim_max, 'FM999G999G990D00'));
        pc_envia_chave_valor(0,'Potencial máximo de parcela do CPF/CNPJ',TO_CHAR(vr_vlpot_parc_max, 'FM999G999G990D00'));
        pc_envia_chave_valor(0,'Utilização do valor da parcela',NULL);
        pc_envia_chave_valor(0,'Parcela SCR 61 a 90 proponente',TO_CHAR(vr_vl_scr_61_90, 'FM999G999G990D00'));
        pc_envia_chave_valor(0,'Parcela SCR 61 a 90 cônjuge',TO_CHAR(vr_vl_scr_61_90_cje, 'FM999G999G990D00'));
        pc_envia_chave_valor(0,'Parcela de operações internas que ainda não constam no SCR proponente',TO_CHAR(vr_vlope_pos_scr, 'FM999G999G990D00'));
        pc_envia_chave_valor(0,'Parcela de operações internas que ainda não constam no SCR cônjuge',TO_CHAR(vr_vlope_pos_scr_cje, 'FM999G999G990D00'));
        pc_envia_chave_valor(0,'Parcela de operações internas aprovadas e não liberadas proponente',TO_CHAR(vr_vlprop_andamt, 'FM999G999G990D00'));
        pc_envia_chave_valor(0,'Parcela de operações internas aprovadas e não liberadas cônjuge',TO_CHAR(vr_vlprop_andamt_cje, 'FM999G999G990D00'));
        pc_envia_chave_valor(0,'Tipo de Carga',rw_carga.dstpcarga);
        pc_envia_chave_valor(0,'SAS Potencial Limite',vr_vlpot_lim_max);
        pc_envia_chave_valor(0,'Valor utilizado de pré-aprovado (finalidade 68)',TO_CHAR(vr_sumempr, 'FM999G999G990D00'));

        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'PreAprv'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'statusCarga'
                              ,pr_tag_cont => rw_carga.flgcarga_bloqueada
                              ,pr_des_erro => vr_dscritic);
      END IF;

      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'PreAprv'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'idCarga'
                            ,pr_tag_cont => vr_dscarga
                            ,pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'PreAprv'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vigInicial'
                            ,pr_tag_cont => rw_carga.dtliberacao
                            ,pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'PreAprv'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vigFinal'
                            ,pr_tag_cont => rw_carga.dtfinal_vigencia
                            ,pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'PreAprv'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'SITUACAO_CARGA'
                            ,pr_tag_cont => rw_carga.SITUACAO_CARGA
                            ,pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'PreAprv'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'tpMensagem'
                            ,pr_tag_cont => vr_sempaprv
                            ,pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'PreAprv'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'tpPessoa'
                            ,pr_tag_cont => vr_inpessoa
                            ,pr_des_erro => vr_dscritic);
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'ERRO 1 => ' || gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'ERRO 2 => ' || vr_dscritic;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'ERRO 1 => ' || 'Erro geral na rotina da tela PRE APROVADO: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_resumo_pre_aprovado;

  /* Motivos de Não Ter Pre-Aprovado na Carga Atual */
  PROCEDURE pc_lista_motivos_sem_preapv(pr_nrdconta IN crapass.nrdconta%TYPE -- Conta desejado
                                        /* Parametros base da Mensageria */
                                       ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_lista_motivos_sem_preapv
    Sistema : Ayllos Web
    Autor   : Marcos Martini (Envolti)
    Data    : Fevereiro - 2019.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os motivos do Cooperato não possuir Pre Aprovado

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variaveis de locais
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Busca do CPF ou CNPJ base do Cooperado
      CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT ass.inpessoa
              ,ass.nrcpfcnpj_base
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      vr_inpessoa crapass.inpessoa%TYPE;
      vr_nrcpfcnpj_base crapass.nrcpfcnpj_base%TYPE;

      -- Busca dos Motivos de não haver pre-aprovado
      CURSOR cr_motivos(pr_cdcooper      crapcop.cdcooper%TYPE
                       ,pr_inpessoa      crapass.inpessoa%TYPE
                       ,pr_nrcpfcnpjbase tbcrd_score.nrcpfcnpjbase%TYPE) IS
        SELECT  mna.idmotivo
               ,NVL2(mot.dsmotivo, mot.dsmotivo, mna.dsmotivo_sas) dsmotivo
               ,mna.dsvalor
               ,mna.dtbloqueio
               ,mna.dtregulariza
        FROM tbepr_motivo_nao_aprv mna
            ,tbepr_carga_pre_aprv  car
            ,tbgen_motivo          mot
        WHERE mna.nrcpfcnpj_base = pr_nrcpfcnpjbase
          AND mna.cdcooper       = pr_cdcooper
          AND mna.tppessoa       = pr_inpessoa
          AND NVL(car.dtfinal_vigencia,TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
          AND (mna.idcarga = empr0002.fn_carga_pre_sem_vig_status(pr_cdcooper        => mna.cdcooper
                                                                ,pr_tppessoa        => mna.tppessoa
                                                                ,pr_nrcpf_cnpj_base => mna.nrcpfcnpj_base)
               OR 0 = empr0002.fn_carga_pre_sem_vig_status(pr_cdcooper        => mna.cdcooper
                                                          ,pr_tppessoa        => mna.tppessoa
                                                          ,pr_nrcpf_cnpj_base => mna.nrcpfcnpj_base))
          AND car.cdcooper = mna.cdcooper
          AND car.idcarga = mna.idcarga
          AND car.flgcarga_bloqueada = 0
          AND car.indsituacao_carga = 2
          AND mna.idmotivo = mot.idmotivo(+)
          AND mot.cdproduto (+)  = 25
          AND mna.nrdconta = 0;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis auxiliares
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

    BEGIN

      -- Validar chamada
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
        RAISE vr_exc_saida;
      END IF;

      -- Buscar cpf ou cnpj base
      OPEN cr_crapass(vr_cdcooper);
      FETCH cr_crapass
       INTO vr_inpessoa,vr_nrcpfcnpj_base;
      CLOSE cr_crapass;

      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Buscar
      FOR rw_mot IN cr_motivos(vr_cdcooper,vr_inpessoa,vr_nrcpfcnpj_base) LOOP
        -- No raiz do Score
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Motivo'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
        -- Campos
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Motivo'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'idmotivo'
                              ,pr_tag_cont => rw_mot.idmotivo
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Motivo'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsmotivos'
                              ,pr_tag_cont => rw_mot.dsmotivo
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Motivo'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsvalor'
                              ,pr_tag_cont => rw_mot.dsvalor
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Motivo'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dtbloqueio'
                              ,pr_tag_cont => to_char(rw_mot.dtbloqueio,'dd/mm/rrrr')
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Motivo'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dtregulariza'
                              ,pr_tag_cont => to_char(rw_mot.dtregulariza,'dd/mm/rrrr')
                              ,pr_des_erro => vr_dscritic);
        vr_auxconta := vr_auxconta + 1;
      END LOOP;
      -- Retornar quantidade de registros
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtdregis'
                            ,pr_tag_cont => vr_auxconta
                            ,pr_des_erro => vr_dscritic);
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela ATENDA PREAPV: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_lista_motivos_sem_preapv;


 -- Listagem dos Motivos
  PROCEDURE pc_combo_motivos(pr_flgtipo   IN NUMBER            --> Parametro da mensageria
                             ,pr_xmllog   IN VARCHAR2          --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER      --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2         --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype--> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2         --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS     --> Descricao do Erro
  -- ..........................................................................
    --
    --  Programa : pc_combo_motivos
    --  Sistema  : Cred
    --  Sigla    : GENE
    --  Autor    : David Valente [Envolti]
    --  Data     : Abril/2019.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --
    --  Objetivo  : Retornar a lista de Motivos de bloqueio ou desbloqueio
    --
    --  Alteracoes:
    --
    -- .............................................................................

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Cursores
    CURSOR cr_motivos (pr_flgtipo tbgen_motivo.flgtipo%TYPE) IS
      SELECT mot.idmotivo
            ,mot.dsmotivo
        FROM tbgen_motivo mot
       WHERE mot.flgreserva_sistema = 0
         AND mot.flgativo  = 1
         AND mot.cdproduto = 25 -- Pre Aprovador
         AND mot.flgtipo = pr_flgtipo
       ORDER BY mot.idmotivo;

    -- Variaveis locais
    vr_contador INTEGER := 0;
    vr_clobxml  CLOB;
    vr_dstexto  VARCHAR2(32767);

    -- Variável de críticas
    vr_dscritic VARCHAR2(10000);
    vr_exc_erro EXCEPTION;


  BEGIN
    -- Incluir nome do módulo logados
    GENE0001.pc_informa_acesso(pr_module => 'ATENDA_PREAPV'
                              ,pr_action => 'pc_combo_motivos');

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

    -- Inicializar as informações do XML de dados para o relatório
    dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

    -- Percorre todos os produtos a serem exibidos na tela
    FOR rw_motivos IN cr_motivos(pr_flgtipo) LOOP
      -- SOmente na primeira linha
      IF vr_contador = 0 THEN
        --Escrever no arquivo XML
        gene0002.pc_escreve_xml(vr_clobxml
                               ,vr_dstexto
                               ,'<?xml version="1.0" encoding="ISO-8859-1" ?>' ||
                                    '<Root><Dados>');
      END IF;
      -- Incrementar o contador
      vr_contador := vr_contador + 1;
      -- Enviar o registro
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_dstexto
                             ,'<Motivos>' ||
                                '<idmotivo>' || rw_motivos.idmotivo || '</idmotivo>' ||
                                '<dsmotivo>' || rw_motivos.dsmotivo || '</dsmotivo>' ||
                              '</Motivos>');

    END LOOP;

    -- Houveram registros, então finalizamos o XML
    gene0002.pc_escreve_xml(vr_clobxml
                           ,vr_dstexto
                           ,'</Dados></Root>'
                           ,TRUE);

    -- Devolver o XML
    pr_retxml := xmltype.createXML(vr_clobxml);
    --Fechar Clob e Liberar Memoria
    dbms_lob.close(vr_clobxml);
    dbms_lob.freetemporary(vr_clobxml);
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_des_erro := 'Erro geral em pc_lista_motivos_tela: ' || SQLERRM;
      pr_dscritic := 'Erro geral em pc_lista_motivos_tela: ' || SQLERRM;
  END pc_combo_motivos;



  -- Listagem dos Motivos
  PROCEDURE pc_lista_motivos_tela(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_motivos_tela
    --  Sistema  : Cred
    --  Sigla    : GENE
    --  Autor    : Marcos Martini
    --  Data     : Fevereiro/2019.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de Motivos a serem exibidos na tela de motivos
    --
    --  Alteracoes:
    --
    -- .............................................................................

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Cursores
    CURSOR cr_motivos IS
      SELECT mot.idmotivo
            ,mot.dsmotivo
            ,mot.flgativo
        FROM tbgen_motivo mot
       WHERE mot.flgreserva_sistema = 0
         AND mot.flgativo = 1
         AND mot.cdproduto = 25 -- Pre Aprovador
       ORDER BY mot.idmotivo;

    -- Variaveis locais
    vr_contador INTEGER := 0;
    vr_clobxml  CLOB;
    vr_dstexto  VARCHAR2(32767);

    -- Variável de críticas
    vr_dscritic VARCHAR2(10000);
    vr_exc_erro EXCEPTION;


  BEGIN

    --
    BTCH0001.pc_gera_log_batch(pr_cdcooper     => 1,
                               pr_ind_tipo_log => 2,
                               pr_nmarqlog     => 'CAPTURA_MOTIVOS_ATENDA.LOG',
                               pr_des_log      => 'INICIO PROGRAMA');
    --

    -- Incluir nome do módulo logados
    GENE0001.pc_informa_acesso(pr_module => 'ATENDA_PREAPV'
                              ,pr_action => 'pc_motivos_tela');

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

    -- Inicializar as informações do XML de dados para o relatório
    dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

    -- Percorre todos os produtos a serem exibidos na tela
    FOR rw_motivos IN cr_motivos LOOP
      -- SOmente na primeira linha
      IF vr_contador = 0 THEN
        --Escrever no arquivo XML
        gene0002.pc_escreve_xml(vr_clobxml
                               ,vr_dstexto
                               ,'<?xml version="1.0" encoding="ISO-8859-1" ?>' ||
                                    '<Root><Dados>');
      END IF;
      -- Incrementar o contador
      vr_contador := vr_contador + 1;
      -- Enviar o registro
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_dstexto
                             ,'<Motivos>' ||
                                '<idmotivo>' || rw_motivos.idmotivo || '</idmotivo>' ||
                                '<dsmotivo>' || rw_motivos.dsmotivo || '</dsmotivo>' ||
                              '</Motivos>');
    END LOOP;

    -- Houveram registros, então finalizamos o XML
    gene0002.pc_escreve_xml(vr_clobxml
                           ,vr_dstexto
                           ,'</Dados></Root>'
                           ,TRUE);

    -- Devolver o XML
    pr_retxml := xmltype.createXML(vr_clobxml);
    --Fechar Clob e Liberar Memoria
    dbms_lob.close(vr_clobxml);
    dbms_lob.freetemporary(vr_clobxml);
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_des_erro := 'Erro geral em pc_lista_motivos_tela: ' || SQLERRM;
      pr_dscritic := 'Erro geral em pc_lista_motivos_tela: ' || SQLERRM;
  END pc_lista_motivos_tela;

  -- Mantem status do pre aprovado do cooperado
  PROCEDURE pc_mantem_param_preapv(pr_nrdconta              IN crapass.nrdconta%TYPE
                                  ,pr_flglibera_pre_aprv    IN NUMBER
                                  ,pr_dtatualiza_pre_aprv   IN VARCHAR2
                                  ,pr_idmotivo              IN NUMBER DEFAULT 0
                                  -- Mensageria
                                  ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK

  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_mantem_param_preapv
    --  Sistema  : Emprestimo Pre-Aprovado - Cooperativa de Credito
    --  Sigla    : EMPR
    --  Autor    : Marcos (Envolti)
    --  Data     : Fevereiro/2019                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Mantem status do pre aprovado do cooperado
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE

      -- Variaveis de locais
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- buscar parametros de emprestimo da conta
      CURSOR cr_param_conta (pr_cdcooper crapcop.cdcooper%TYPE
                            ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT flglibera_pre_aprv
              ,dtatualiza_pre_aprv
              ,idmotivo
          FROM tbepr_param_conta
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_param_conta cr_param_conta%ROWTYPE;

      --Variaveis Auxiliares
      vr_nrdrowid            ROWID;
      vr_dtatualiza_pre_aprv DATE;

      -- Variaveis de Erro
      vr_dscritic  VARCHAR2(1000);
      vr_exc_saida EXCEPTION;
      vr_dataAtu   DATE;

    BEGIN
      pr_des_erro := 'OK';

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'ATENDA_PREAPV'
                                ,pr_action => 'pc_mantem_param_preapv');

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

      -- Tratar recepção de data
      IF pr_dtatualiza_pre_aprv IS NOT NULL THEN
        vr_dataAtu := TO_DATE(pr_dtatualiza_pre_aprv, 'DD/MM/RRRR');
      END IF;

      -- Verifica se houve erro recuperando informacoes de log
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Direcionar para rotina genérica
      cada0006.pc_mantem_param_pessoa_prod(pr_cdcooper           => vr_cdcooper
                                          ,pr_nrdconta           => pr_nrdconta
                                          ,pr_cdproduto          => 25 -- Pré-Aprovado
                                          ,pr_cdoperac_produto   => 1  -- Oferta
                                          ,pr_flglibera          => pr_flglibera_pre_aprv
                                          ,pr_dtvigencia_paramet => vr_dataAtu
                                          ,pr_idmotivo           => pr_idmotivo
                                          ,pr_cdoperad           => vr_cdoperad
                                          ,pr_idorigem           => vr_idorigem
                                          ,pr_nmdatela           => vr_nmdatela
                                          ,pr_dscritic           => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Gravar
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral em CONTAS_DESAB: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    END;
  END pc_mantem_param_preapv;

END TELA_ATENDA_PREAPV;