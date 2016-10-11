CREATE OR REPLACE PACKAGE CECRED.TELA_RELSEG AS

  PROCEDURE pc_export_seguro_auto_sicr(pr_tpseguro IN PLS_INTEGER  --> Tipo de Seguro (1-Proposta / 2-Apolice / 3-Endosso)
                                      ,pr_tpstaseg IN VARCHAR2      --> Statos do Seguro (A-Ativo / V-Vencido / C-Cancelado)
                                      ,pr_xmllog   IN VARCHAR2     --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2    --> Descricao da critica
                                      ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2    --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);  --> Saida OK/NOK


END TELA_RELSEG;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_RELSEG AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_RELSEG
  --    Autor   : Guilherme/SUPERO
  --    Data    : Junho/2016                   Ultima Atualizacao:
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : BO ref. a Mensageria da tela RELSEG
  --
  --    Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_export_seguro_auto_sicr(pr_tpseguro IN PLS_INTEGER   --> Tipo de Seguro   (1-Proposta / 2-Apolice / 3-Endosso)
                                      ,pr_tpstaseg IN VARCHAR2      --> Statos do Seguro (A-Ativo / V-Vencido / C-Cancelado)
                                      ,pr_xmllog   IN VARCHAR2      --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER  --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2     --> Descricao da critica
                                      ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2     --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................

    Programa: pc_export_seguro_auto_sicr
    Sistema : Ayllos Web
    Autor   : Guilherme/SUPERO
    Data    : Maio/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Efetuar a exportaÁ„o dos dados Seguro Auto Sicredi em arquivo CSV

    Alteracoes: -----
    ..............................................................................*/

    -- Cursor sobre os representantes
    CURSOR cr_seguros(p_tpseguro IN PLS_INTEGER
                     ,p_tpstaseg IN VARCHAR2) IS
           -- p_tpseguro => 1-Proposta / 2-Apolice / 3-Endosso
           -- p_tpstaseg => A-Ativo / V-Vencido / C-Cancelado
    SELECT *
      FROM (SELECT seg.cdcooper       -- PROPOSTAS
                  ,nvl(ass.cdagenci,0) cdagenci
                  ,seg.dtinicio_vigencia
                  ,seg.dttermino_vigencia
                  ,TRIM(UPPER(translate(csg.nmsegura,'¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸'
                                                    ,'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu'))) nmsegura
                  ,TRIM(UPPER(translate(seg.nmsegurado,'¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸'
                                                      ,'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu'))) nmsegurado
                  ,NVL(cop.cdagectl,0) cdagectl
                  ,seg.nrdconta
                  ,seg.nrcpf_cnpj_segurado
                  ,seg.nrproposta
                  ,seg.nrapolice
                  ,seg.nrendosso
                  ,auto.nmmarca
                  ,auto.dsmodelo
                  ,auto.nrano_fabrica
                  ,auto.nrano_modelo
                  ,auto.dsplaca
                  ,auto.dschassi
                  ,seg.vlpremio_liquido
                  ,seg.vlpremio_total
                  ,seg.qtparcelas
                  ,seg.vlparcela
                  ,DECODE(seg.indsituacao,'A','ATIVA','C','CANCELADA','VENCIDA') indsituacao
                  ,seg.percomissao
                  ,seg.dtcancela
                  ,'000000000000'  nrendosso_altera
                  ,seg.tpendosso
                  ,seg.tpsub_endosso
              FROM tbseg_contratos seg
                  ,tbseg_auto_veiculos auto
                  ,crapcsg csg
                  ,crapcop cop
                  ,crapass ass
              WHERE seg.idcontrato  = auto.idcontrato
                AND seg.tpseguro    = 'A'          -- SEGURO AUTO
                AND csg.cdcooper    = 1            -- SEGURADORAS CADASTRADAS NA VIACREDI
                AND csg.cdsegura    = seg.cdsegura
                AND seg.cdcooper    = cop.cdcooper(+)  -- HA SITUACOES COM COOP  0 (QUANDO ERRO)
                AND seg.cdcooper    = ass.cdcooper (+) -- HA SITUACOES COM COOP  0 (QUANDO ERRO)
                AND seg.nrdconta    = ass.nrdconta (+) -- HA SITUACOES COM CONTA 0 (QUANDO ERRO)
                AND seg.indsituacao = p_tpstaseg
                AND p_tpseguro      = 1
                AND seg.nrproposta <> 0 -- APENAS PROPOSTAS
                AND seg.nrapolice   = 0
                AND seg.nrendosso   = 0  
            UNION ALL
            SELECT seg.cdcooper         -- APOLICES
                  ,nvl(ass.cdagenci,0) cdagenci
                  ,seg.dtinicio_vigencia
                  ,seg.dttermino_vigencia
                  ,TRIM(UPPER(translate(csg.nmsegura,'¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸'
                                                    ,'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu'))) nmsegura
                  ,TRIM(UPPER(translate(seg.nmsegurado,'¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸'
                                                      ,'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu'))) nmsegurado
                  ,NVL(cop.cdagectl,0) cdagectl
                  ,seg.nrdconta
                  ,seg.nrcpf_cnpj_segurado
                  ,seg.nrproposta
                  ,seg.nrapolice
                  ,seg.nrendosso
                  ,auto.nmmarca
                  ,auto.dsmodelo
                  ,auto.nrano_fabrica
                  ,auto.nrano_modelo
                  ,auto.dsplaca
                  ,auto.dschassi
                  ,seg.vlpremio_liquido
                  ,seg.vlpremio_total
                  ,seg.qtparcelas
                  ,seg.vlparcela
                  ,DECODE(seg.indsituacao,'A','ATIVA','C','CANCELADA','VENCIDA') indsituacao
                  ,seg.percomissao
                  ,seg.dtcancela
                  ,'000000000000'  nrendosso_altera
                  ,seg.tpendosso
                  ,seg.tpsub_endosso
              FROM tbseg_contratos     seg
                  ,tbseg_auto_veiculos auto
                  ,crapcsg csg
                  ,crapcop cop
                  ,crapass ass
              WHERE seg.idcontrato  = auto.idcontrato
                AND seg.tpseguro    = 'A'          -- SEGURO AUTO
                AND csg.cdcooper    = 1            -- SEGURADORAS CADASTRADAS NA VIACREDI
                AND csg.cdsegura    = seg.cdsegura
                AND seg.cdcooper    = cop.cdcooper(+)  -- HA SITUACOES COM COOP  0 (QUANDO ERRO)
                AND seg.cdcooper    = ass.cdcooper (+) -- HA SITUACOES COM COOP  0 (QUANDO ERRO)
                AND seg.nrdconta    = ass.nrdconta (+) -- HA SITUACOES COM CONTA 0 (QUANDO ERRO)
                AND seg.indsituacao = p_tpstaseg
                AND p_tpseguro      = 2
                AND seg.nrproposta <> 0       -- APENAS APOLICES
                AND seg.nrapolice  <> 0
                AND seg.nrendosso   = 0
            UNION ALL
            SELECT seg.cdcooper               -- ENDOSSOS DE ALTERACAO - SAO CONSIDERADOS APOLICES TB
                  ,nvl(ass.cdagenci,0) cdagenci
                  ,seg.dtinicio_vigencia
                  ,seg.dttermino_vigencia
                  ,TRIM(UPPER(translate(csg.nmsegura,'¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸'
                                                    ,'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu'))) nmsegura
                  ,TRIM(UPPER(translate(seg.nmsegurado,'¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸'
                                                      ,'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu'))) nmsegurado
                  ,NVL(cop.cdagectl,0) cdagectl
                  ,seg.nrdconta
                  ,seg.nrcpf_cnpj_segurado
                  ,seg.nrproposta
                  ,seg.nrapolice
                  ,seg.nrendosso
                  ,auto.nmmarca
                  ,auto.dsmodelo
                  ,auto.nrano_fabrica
                  ,auto.nrano_modelo
                  ,auto.dsplaca
                  ,auto.dschassi
                  ,seg.vlpremio_liquido
                  ,seg.vlpremio_total
                  ,seg.qtparcelas
                  ,seg.vlparcela
                  ,DECODE(seg.indsituacao,'A','ATIVA','C','CANCELADA','VENCIDA') indsituacao
                  ,seg.percomissao
                  ,seg.dtcancela
                  ,'000000000000'  nrendosso_altera
                  ,seg.tpendosso
                  ,seg.tpsub_endosso
              FROM tbseg_contratos     seg
                  ,tbseg_auto_veiculos auto
                  ,crapcsg csg
                  ,crapcop cop
                  ,crapass ass
              WHERE seg.idcontrato  = auto.idcontrato
                AND seg.tpseguro    = 'A'          -- SEGURO AUTO
                AND csg.cdcooper    = 1            -- SEGURADORAS CADASTRADAS NA VIACREDI
                AND csg.cdsegura    = seg.cdsegura
                AND seg.cdcooper    = cop.cdcooper(+)  -- HA SITUACOES COM COOP  0 (QUANDO ERRO)
                AND seg.cdcooper    = ass.cdcooper (+) -- HA SITUACOES COM COOP  0 (QUANDO ERRO)
                AND seg.nrdconta    = ass.nrdconta (+) -- HA SITUACOES COM CONTA 0 (QUANDO ERRO)
                AND seg.indsituacao = p_tpstaseg
                AND p_tpseguro      = 2
                AND seg.nrproposta <> 0         -- APOLICES E ENDOSSOS ALTERACAO
                AND seg.nrapolice  <> 0
                AND seg.nrendosso  <> 0
                AND seg.tpendosso IN (2,3,6,8) -- ENDOSSOS de ALTERACAO
            UNION ALL
            SELECT seg.cdcooper
                  ,nvl(ass.cdagenci,0) cdagenci
                  ,seg.dtinicio_vigencia
                  ,seg.dttermino_vigencia
                  ,TRIM(UPPER(translate(csg.nmsegura,'¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸'
                                                    ,'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu'))) nmsegura
                  ,TRIM(UPPER(translate(seg.nmsegurado,'¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸'
                                                      ,'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu'))) nmsegurado
                  ,NVL(cop.cdagectl,0) cdagectl
                  ,seg.nrdconta
                  ,seg.nrcpf_cnpj_segurado
                  ,seg.nrproposta
                  ,seg.nrapolice
                  ,seg.nrendosso
                  ,auto.nmmarca
                  ,auto.dsmodelo
                  ,auto.nrano_fabrica
                  ,auto.nrano_modelo
                  ,auto.dsplaca
                  ,auto.dschassi
                  ,seg.vlpremio_liquido
                  ,seg.vlpremio_total
                  ,seg.qtparcelas
                  ,seg.vlparcela
                  ,DECODE(seg.indsituacao,'A','ATIVA','C','CANCELADA','VENCIDA') indsituacao
                  ,seg.percomissao
                  ,seg.dtcancela
                  ,'000000000000'  nrendosso_altera
                  ,seg.tpendosso
                  ,seg.tpsub_endosso
              FROM tbseg_contratos     seg
                  ,tbseg_auto_veiculos auto
                  ,crapcsg csg
                  ,crapcop cop
                  ,crapass ass
              WHERE seg.idcontrato  = auto.idcontrato
                AND seg.tpseguro    = 'A'          -- SEGURO AUTO
                AND csg.cdcooper    = 1            -- SEGURADORAS CADASTRADAS NA VIACREDI
                AND csg.cdsegura    = seg.cdsegura
                AND seg.cdcooper    = cop.cdcooper(+)  -- HA SITUACOES COM COOP  0 (QUANDO ERRO)
                AND seg.cdcooper    = ass.cdcooper (+) -- HA SITUACOES COM COOP  0 (QUANDO ERRO)
                AND seg.nrdconta    = ass.nrdconta (+) -- HA SITUACOES COM CONTA 0 (QUANDO ERRO)
                AND seg.indsituacao = p_tpstaseg
                AND p_tpseguro      = 3
                AND seg.nrproposta <> 0       -- APENAS ENDOSSOS
                AND seg.nrapolice  <> 0
                AND seg.nrendosso  <> 0
            ) tmp
        ORDER BY tmp.cdcooper, tmp.cdagenci, tmp.nrdconta, tmp.nrproposta, tmp.nrapolice, tmp.nrendosso;
      rw_seguros cr_seguros%ROWTYPE;

      -- Cria o registro de data
      rw_crapdat    btch0001.cr_crapdat%ROWTYPE;

      -- Tratamento de erros
      vr_exc_erro   EXCEPTION;

      -- Vari·vel de crÌticas
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(10000);
      vr_tab_erro   GENE0001.typ_tab_erro;
      vr_des_reto   VARCHAR2(10);

      -- Variaveis de log
      vr_cdcooper   INTEGER;
      vr_cdoperad   VARCHAR2(100);
      vr_nmdatela   VARCHAR2(100);
      vr_nmeacao    VARCHAR2(100);
      vr_cdagenci   VARCHAR2(100);
      vr_nrdcaixa   VARCHAR2(100);
      vr_idorigem   VARCHAR2(100);

      -- Variaveis
      vr_typ_saida  VARCHAR2(3);
      vr_xml_temp   VARCHAR2(32726) := '';
      vr_clob       CLOB;
      vr_existe     BOOLEAN := FALSE;
      vr_cpftest1   VARCHAR2(15);
      vr_cpftest2   VARCHAR2(15);
      vr_arquivo    utl_file.file_type;       --> Handle para gravar arquivo
      vr_nom_direto VARCHAR2(200);  --> DiretÛrio para gravaÁ„o do arquivo
      vr_dsjasper   VARCHAR2(100);  --> nome do jasper a ser usado
      vr_nmarqim    VARCHAR2(50);   --> nome do arquivo PDF

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Abre o cursor de data
      OPEN btch0001.cr_crapdat(vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      --busca diretorio padrao da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => vr_cdcooper
                                            ,pr_nmsubdir => 'rl');
      -- Verifica o tipo que devera ser impresso
      vr_nmarqim  := 'dados_sicredi_'; --'||to_char(sysdate,'YYYYMMDDHH24MISS')||'.csv';
      CASE pr_tpseguro
        WHEN 1 THEN -- Proposta
          vr_nmarqim := vr_nmarqim || 'proposta_';
        WHEN 2 THEN -- Apolice
          vr_nmarqim := vr_nmarqim || 'apolice_';
        WHEN 3 THEN -- Endosso
          vr_nmarqim := vr_nmarqim || 'endosso_';
        ELSE NULL;
      END CASE;
      CASE pr_tpstaseg
        WHEN 'A' THEN -- Ativa
          vr_nmarqim := vr_nmarqim || 'ativo_';
        WHEN 'V' THEN -- Vencida
          vr_nmarqim := vr_nmarqim || 'vencido_';
        WHEN 'C' THEN -- Cancelada
          vr_nmarqim := vr_nmarqim || 'cancelado_';
        ELSE NULL;
      END CASE;


      vr_nmarqim := vr_nmarqim || to_char(SYSDATE,'sssss') || '.csv';


      -- Cria a variavel CLOB
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

      -- Criar cabeÁalho do CSV
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => 'Cooperativa;PA;Inicio Vigencia;Fim Vigencia;Seguradora;'
                                                 ||'Segurado;Agencia;Conta/DV;CPF/CNPJ;Proposta;Apolice;Endosso;'

                                                 || 'Marca;Modelo;Ano Fabr;Ano Modelo;Placa;Chassi;'

                                                 ||'Altera Endoso;Tipo;Sub Tipo;'
                                                 ||'Valor Premio Liq;Valor Premio Total;Qtde Parcelas;Valor Parcela;'
                                                 ||'Situacao;% Comissao;Data Cancelamento;' ||chr(10));

      -- LEITURA DOS DADOS DE TODOS SEGUROS / CONFORME PARAMETROS
      FOR rw_seguros IN cr_seguros(pr_tpseguro
                                  ,pr_tpstaseg) LOOP

        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => rw_seguros.cdcooper            || ';' ||
                                                     rw_seguros.cdagenci            || ';' ||
                                                     to_char(rw_seguros.dtinicio_vigencia ,'dd/mm/rrrr')  || ';' ||
                                                     to_char(rw_seguros.dttermino_vigencia,'dd/mm/rrrr')  || ';' ||
                                                     rw_seguros.nmsegura            || ';' ||
                                                     rw_seguros.nmsegurado          || ';' ||
                                                     rw_seguros.cdagectl            || ';' ||
                                                     rw_seguros.nrdconta            || ';' ||
                                                     rw_seguros.nrcpf_cnpj_segurado || ';' ||
                                                     rw_seguros.nrproposta                                                       || ';' ||
                                                     rw_seguros.nrapolice                                                        || ';' ||
                                                     rw_seguros.nrendosso                                                        || ';' ||

                                                     rw_seguros.nmmarca                                                          || ';' ||
                                                     rw_seguros.dsmodelo                                                         || ';' ||
                                                     rw_seguros.nrano_fabrica                                                    || ';' ||
                                                     rw_seguros.nrano_modelo                                                     || ';' ||
                                                     rw_seguros.dsplaca                                                          || ';' ||
                                                     rw_seguros.dschassi                                                         || ';' ||
                                                     
                                                     rw_seguros.nrendosso_altera                                                 || ';' ||
                                                     rw_seguros.tpendosso                                                        || ';' ||
                                                     rw_seguros.tpsub_endosso                                                    || ';' ||

                                                     to_Char(rw_seguros.vlpremio_liquido,'FM9G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || ';' ||
                                                     to_Char(rw_seguros.vlpremio_total,'FM9G999G990D00','NLS_NUMERIC_CHARACTERS=,.')   || ';' ||
                                                     rw_seguros.qtparcelas                                                             || ';' ||
                                                     to_Char(rw_seguros.vlparcela,'FM9G999G990D00','NLS_NUMERIC_CHARACTERS=,.')        || ';' ||
                                                     rw_seguros.indsituacao                                                            || ';' ||
                                                     to_Char(rw_seguros.percomissao,'FM990D00','NLS_NUMERIC_CHARACTERS=,.')            || ';' ||
                                                     to_char(rw_seguros.dtcancela,'dd/mm/rrrr')
                                                     || chr(10));
      END LOOP;
      -- FIM LEITURA SEGUROS


      -- Encerrar o Clob
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => ' '
                             ,pr_fecha_xml      => TRUE);

      -- Gera o relatorio
      gene0002.pc_clob_para_arquivo(pr_clob => vr_clob,
                                    pr_caminho => vr_nom_direto,
                                    pr_arquivo => vr_nmarqim,
                                    pr_des_erro => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- copia contrato pdf do diretorio da cooperativa para servidor web
      gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                 , pr_cdagenci => NULL
                                 , pr_nrdcaixa => NULL
                                 , pr_nmarqpdf => vr_nom_direto||'/'||vr_nmarqim
                                 , pr_des_reto => vr_des_reto
                                 , pr_tab_erro => vr_tab_erro
                                 );

      -- caso apresente erro na operaÁ„o
      IF nvl(vr_des_reto,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_erro; -- encerra programa
        END IF;
      END IF;

      -- Remover relatorio do diretorio padrao da cooperativa
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm '||vr_nom_direto||'/'||vr_nmarqim
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);

      -- Se retornou erro
      IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT null THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_erro; -- encerra programa
      END IF;

      -- Criar XML de retorno para uso na Web
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqcsv>' || vr_nmarqim|| '</nmarqcsv>');


    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n„o OK
        pr_des_erro := 'NOK';

        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Existe para satisfazer exigÍncia da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic || '-' ||
                                       pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        -- Retorno n„o OK
        pr_des_erro := 'NOK';

        -- Erro
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na TELA_PENSEG.pc_busca_seguros_pend --> ' ||
                       SQLERRM;

        -- Existe para satisfazer exigÍncia da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic || '-' ||
                                       pr_dscritic || '</Erro></Root>');

  END pc_export_seguro_auto_sicr;


END TELA_RELSEG;
/
