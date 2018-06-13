CREATE OR REPLACE PACKAGE CECRED.TELA_LIMCRD  IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_LIMCRD
  --  Sistema  : Ayllos Web
  --  Autor    :
  --  Data     :                  Ultima atualizacao: 25/04/2018
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas à tela de limite de crédito
  --
  -- Alteracoes: 25/04/2018  Carlos Lima - Supero
  --             Inicio da construção da package e inclusão da procedure de busca.
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_busca_limite_cartao_crd(pr_cdcooper  IN tbcrd_limite_atualiza.cdcooper%TYPE       --> Cooperativa
                                    ,pr_cdadmcrd  IN tbcrd_limite_atualiza.nrdconta%TYPE       --> Administradora
                                    ,pr_pagenumber  IN NUMBER --> Número da página
                                    ,pr_pagesize   IN NUMBER --> Quantidade de resgistros por página
                                    ,pr_only_cecred IN NUMBER --> Somente registros da cecred
                                    ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2           --> Descricao da critica
                                    ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);         --> Erros do processo

  PROCEDURE pc_salva_limite_cartao_crd(pr_cdcooper  IN CRAPTLC.cdcooper%TYPE       --> Cooperativa
                                    ,pr_cdadmcrd  IN CRAPTLC.CDADMCRD%TYPE       --> Administradora
                                    ,pr_vllimite_min IN TBCRD_CONFIG_CATEGORIA.VLLIMITE_MINIMO%TYPE --> Valor limite minimo
                                    ,pr_vllimite_max IN TBCRD_CONFIG_CATEGORIA.VLLIMITE_MAXIMO%TYPE --> Valor limite maximo
                                    ,pr_vllimite IN TBCRD_CONFIG_CATEGORIA.VLLIMITE_MAXIMO%TYPE --> Valor limite maximo
                                    ,pr_cdlimcrd IN CRAPTLC.CDLIMCRD%TYPE -- Código do limite de credito
                                    ,pr_nrctamae IN CRAPTLC.nrctamae%TYPE -- Numero da conta mae
                                    ,pr_insittab IN CRAPTLC.insittab%TYPE -- Situação tabela
                                    ,pr_tpcartao IN CRAPTLC.TPCARTAO%TYPE -- Tipo de cartão
                                    ,pr_dddebito IN VARCHAR2 -- Dia de debito
                                    ,pr_tpproces IN VARCHAR2              --Alterar, Inserir e Excluir
                                    ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2           --> Descricao da critica
                                    ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2); --> Erros do processo

END;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_LIMCRD  IS

PROCEDURE pc_busca_limite_cartao_crd(pr_cdcooper  IN tbcrd_limite_atualiza.cdcooper%TYPE       --> Cooperativa
                                    ,pr_cdadmcrd  IN tbcrd_limite_atualiza.nrdconta%TYPE       --> Administradora
                                    ,pr_pagenumber  IN NUMBER --> Número da página
                                    ,pr_pagesize   IN NUMBER --> Quantidade de resgistros por página
                                    ,pr_only_cecred IN NUMBER --> Somente registros da cecred
                                    ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2           --> Descricao da critica
                                    ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

  CURSOR cur_lmt_cred(prm_pagenumber IN NUMBER
                     ,prm_pagesize   IN NUMBER) IS
    SELECT * FROM
    (
        SELECT a.*, rownum r__
        FROM
        (
          SELECT tcca.cdcooper
              ,tcca.cdadmcrd
              ,tcca.vllimite_minimo
              ,tcca.vllimite_maximo
              ,tcca.dsdias_debito
              ,NULL AS cdlimcrd
              ,NULL AS nrctamae
              ,NULL AS tpcartao
          FROM   TBCRD_CONFIG_CATEGORIA tcca
          WHERE  nvl(pr_only_cecred,1) = 1
          AND    CDCOOPER = nvl(pr_cdcooper,CDCOOPER)
          AND    CDADMCRD = nvl(pr_cdadmcrd,CDADMCRD)
          UNION ALL
          SELECT crap.CDCOOPER
                  ,crap.CDADMCRD
                  ,0 AS vl_lmt_minimo
                  ,crap.vllimcrd AS vl_lmt_maximo
                   ,regexp_replace(
                          LISTAGG(crap.dddebito,',') WITHIN GROUP (ORDER BY crap.cdadmcrd,crap.dddebito)
                           ,'([^,]+)(,\1)*(,|$)', '\1\3'
                    ) dias_debito
                   ,crap.cdlimcrd
                   ,crap.nrctamae
                   ,crap.tpcartao
            FROM   CRAPTLC crap
            WHERE  crap.CDADMCRD NOT BETWEEN 10 AND 80
            AND    crap.INSITTAB  = 0
            AND    CDCOOPER = nvl(pr_cdcooper,CDCOOPER)
            AND    CDADMCRD = nvl(pr_cdadmcrd,CDADMCRD)
            AND   nvl(pr_only_cecred,0) = 0
            AND    NOT EXISTS (SELECT 1
                               FROM   TBCRD_CONFIG_CATEGORIA tca
                               WHERE  tca.cdcooper = crap.cdcooper
                               AND    tca.cdadmcrd = crap.cdadmcrd
                               )
            GROUP BY crap.CDCOOPER ,crap.CDADMCRD,crap.vllimcrd,crap.cdlimcrd,crap.nrctamae,crap.tpcartao
          ) a
        WHERE 1=1
        AND rownum < ((prm_pagenumber * prm_pagesize) + 1 )
    )
    WHERE r__ >= (((prm_pagenumber-1) * prm_pagesize) + 1);

  -- Variavel de criticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(10000);

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;

  -- Variaveis gerais
  vr_cont_tag PLS_INTEGER := 0;

  -- Total de registros
  vr_totalregistros     NUMBER:=0;

BEGIN
  pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

  GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                        ,pr_tag_pai  => 'Root'
                        ,pr_posicao  => 0
                        ,pr_tag_nova => 'Dados'
                        ,pr_tag_cont => NULL
                        ,pr_des_erro => vr_dscritic);

  -- Para cada um dos históricos de alteração de limite
  FOR rw_lmt_cred IN cur_lmt_cred(pr_pagenumber
                                 ,pr_pagesize) LOOP
    -- Insere o nodo de limite
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'limite'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    -- Insere o código da cooperativa
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'limite'
                          ,pr_posicao  => vr_cont_tag
                          ,pr_tag_nova => 'cdcooper'
                          ,pr_tag_cont => rw_lmt_cred.cdcooper
                          ,pr_des_erro => vr_dscritic);

    -- Insere o código da administradora
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'limite'
                          ,pr_posicao  => vr_cont_tag
                          ,pr_tag_nova => 'cdadmcrd'
                          ,pr_tag_cont => rw_lmt_cred.cdadmcrd
                          ,pr_des_erro => vr_dscritic);

    -- Insere o valor do limite mínimo
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'limite'
                          ,pr_posicao  => vr_cont_tag
                          ,pr_tag_nova => 'vllimite_minimo'
                          ,pr_tag_cont => rw_lmt_cred.vllimite_minimo
                          ,pr_des_erro => vr_dscritic);

    -- Insere o valor do limite máximo
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'limite'
                          ,pr_posicao  => vr_cont_tag
                          ,pr_tag_nova => 'vllimite_maximo'
                          ,pr_tag_cont => rw_lmt_cred.vllimite_maximo
                          ,pr_des_erro => vr_dscritic);

    -- Insere o valor de dias de debito
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'limite'
                          ,pr_posicao  => vr_cont_tag
                          ,pr_tag_nova => 'dsdias_debito'
                          ,pr_tag_cont => rw_lmt_cred.dsdias_debito
                          ,pr_des_erro => vr_dscritic);

    -- Insere o código de limite de crédito
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'limite'
                          ,pr_posicao  => vr_cont_tag
                          ,pr_tag_nova => 'cdlimcrd'
                          ,pr_tag_cont => rw_lmt_cred.cdlimcrd
                          ,pr_des_erro => vr_dscritic);

    -- Insere a conta mãe
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'limite'
                          ,pr_posicao  => vr_cont_tag
                          ,pr_tag_nova => 'nrctamae'
                          ,pr_tag_cont => rw_lmt_cred.nrctamae
                          ,pr_des_erro => vr_dscritic);

     -- Insere a conta mãe
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'limite'
                          ,pr_posicao  => vr_cont_tag
                          ,pr_tag_nova => 'tpcartao'
                          ,pr_tag_cont => rw_lmt_cred.tpcartao
                          ,pr_des_erro => vr_dscritic);

    -- Incrementa o contador de tags
    vr_cont_tag := vr_cont_tag + 1;

  END LOOP;

  BEGIN
    SELECT COUNT(*) total
    INTO   vr_totalregistros
    FROM (
          SELECT 1
          FROM   TBCRD_CONFIG_CATEGORIA tcca
          WHERE  nvl(pr_only_cecred,1) = 1
          AND    CDCOOPER = nvl(pr_cdcooper,CDCOOPER)
          AND    CDADMCRD = nvl(pr_cdadmcrd,CDADMCRD)
          UNION ALL
          SELECT 1
          FROM   CRAPTLC crap
          WHERE  crap.CDADMCRD NOT BETWEEN 10 AND 80
          AND    CDCOOPER = nvl(pr_cdcooper,CDCOOPER)
          AND    CDADMCRD = nvl(pr_cdadmcrd,CDADMCRD)
          AND    nvl(pr_only_cecred,0) = 0
          AND    crap.INSITTAB  = 0
          AND    NOT EXISTS (SELECT 1
                             FROM   TBCRD_CONFIG_CATEGORIA tca
                             WHERE  tca.cdcooper = crap.cdcooper
                             AND    tca.cdadmcrd = crap.cdadmcrd
                             )
            GROUP BY crap.CDCOOPER ,  crap.CDADMCRD, crap.cdlimcrd,crap.nrctamae
          );
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := SQLERRM;
      RAISE vr_exc_saida;
  END;

  -- Insere o total de registros
  GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                        ,pr_tag_pai  => 'Dados'
                        ,pr_posicao  => 0
                        ,pr_tag_nova => 'totalregistros'
                        ,pr_tag_cont => vr_totalregistros
                        ,pr_des_erro => vr_dscritic);

EXCEPTION
  WHEN vr_exc_saida THEN

    IF vr_cdcritic <> 0 THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    ELSE
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    END IF;

    pr_des_erro := 'NOK';
    -- Carregar XML padrão para variável de retorno não utilizada.
    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    ROLLBACK;
  WHEN OTHERS THEN
    pr_dscritic := 'Erro na rotina pc_busca_limite_cartao_crd: ' || SQLERRM;

    -- Carregar XML padrão para variavel de retorno
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    ROLLBACK;
END pc_busca_limite_cartao_crd;

PROCEDURE pc_salva_limite_cartao_crd(pr_cdcooper  IN CRAPTLC.cdcooper%TYPE       --> Cooperativa
                                    ,pr_cdadmcrd  IN CRAPTLC.CDADMCRD%TYPE       --> Administradora
                                    ,pr_vllimite_min IN TBCRD_CONFIG_CATEGORIA.VLLIMITE_MINIMO%TYPE --> Valor limite minimo
                                    ,pr_vllimite_max IN TBCRD_CONFIG_CATEGORIA.VLLIMITE_MAXIMO%TYPE --> Valor limite maximo
                                    ,pr_vllimite IN TBCRD_CONFIG_CATEGORIA.VLLIMITE_MAXIMO%TYPE --> Valor limite maximo
                                    ,pr_cdlimcrd IN CRAPTLC.CDLIMCRD%TYPE -- Código do limite de credito
                                    ,pr_nrctamae IN CRAPTLC.nrctamae%TYPE -- Numero da conta mae
                                    ,pr_insittab IN CRAPTLC.insittab%TYPE -- Situação tabela
                                    ,pr_tpcartao IN CRAPTLC.TPCARTAO%TYPE -- Tipo de cartão
                                    ,pr_dddebito IN VARCHAR2              -- Dia de debito
                                    ,pr_tpproces IN VARCHAR2              --Alterar, Inserir e Excluir
                                    ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2           --> Descricao da critica
                                    ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  -- Tratamento de erros
  vr_exc_saida EXCEPTION;

  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(1000); --> Desc. Erro

  vr_insert   BOOLEAN;
  vr_update   BOOLEAN;
  vr_delete   BOOLEAN;
  --
  vr_cont_tag PLS_INTEGER := 0;
  vr_achou    NUMBER;
BEGIN

  pr_des_erro := 'OK';

  -- Se código de credito for nulo, limites não são da cecred
  IF pr_cdadmcrd NOT BETWEEN 10 AND 80 THEN

    --Se Alteração ou Inserção
    IF pr_tpproces IN ('A','I') THEN
      BEGIN
        SELECT 1
        INTO   vr_achou
        FROM   CRAPTLC t
        WHERE  t.cdadmcrd = pr_cdadmcrd
        AND    t.cdcooper = pr_cdcooper
        AND    t.cdlimcrd = pr_cdlimcrd
        AND    t.tpcartao = pr_tpcartao
        AND    t.dddebito = pr_dddebito;

        UPDATE CRAPTLC t
        SET    t.nrctamae = nvl(pr_nrctamae,t.nrctamae) -- conta mae
              ,t.insittab = nvl(pr_insittab,t.insittab) -- situação
              ,t.vllimcrd = nvl(pr_vllimite,t.vllimcrd) -- valor limite
        WHERE  t.cdadmcrd = pr_cdadmcrd
        AND    t.cdcooper = pr_cdcooper
        AND    t.cdlimcrd = pr_cdlimcrd
        AND    t.tpcartao = pr_tpcartao
        AND    ((pr_dddebito IS NULL AND t.dddebito IS NULL) OR
                (pr_dddebito IS NOT NULL AND t.dddebito = pr_dddebito));

        vr_update := TRUE;

      EXCEPTION
        WHEN no_data_found THEN
          BEGIN
            INSERT INTO CRAPTLC(cdcooper
                               ,cdadmcrd
                               ,insittab
                               ,vllimcrd
                               ,nrctamae
                               ,TPCARTAO
                               ,DDDEBITO
                               ,CDLIMCRD)
                         VALUES(pr_cdcooper
                               ,pr_cdadmcrd
                               ,pr_insittab
                               ,pr_vllimite
                               ,pr_nrctamae
                               ,pr_tpcartao
                               ,pr_dddebito
                               ,pr_cdlimcrd);

            vr_insert := TRUE;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := SQLERRM;
              RAISE vr_exc_saida;
          END;
        WHEN OTHERS THEN
          vr_dscritic := SQLERRM;
          RAISE vr_exc_saida;
      END;
    ELSE
      BEGIN
        DELETE FROM craptlc t
        WHERE  t.cdadmcrd = pr_cdadmcrd
        AND    t.cdcooper = pr_cdcooper
        AND    t.cdlimcrd = pr_cdlimcrd
        AND    t.tpcartao = pr_tpcartao
        AND    ((pr_dddebito IS NULL AND t.dddebito IS NULL) OR
                (pr_dddebito IS NOT NULL AND t.dddebito = pr_dddebito));

        vr_delete := TRUE;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := SQLERRM;
          RAISE vr_exc_saida;
      END;
    END IF;
  ELSE
    --Se Alteração ou Inserção
    IF pr_tpproces IN ('A','I') THEN
      BEGIN
        SELECT 1
        INTO   vr_achou
        FROM   TBCRD_CONFIG_CATEGORIA t
        WHERE  t.cdadmcrd = pr_cdadmcrd
        AND    t.cdcooper = pr_cdcooper;

        UPDATE TBCRD_CONFIG_CATEGORIA t
        SET    t.vllimite_minimo = nvl(pr_vllimite_min,t.vllimite_minimo)
              ,t.vllimite_maximo = nvl(pr_vllimite_max,t.vllimite_maximo)
              ,t.dsdias_debito = nvl(pr_dddebito,t.dsdias_debito)
        WHERE  t.cdadmcrd = pr_cdadmcrd
        AND    t.cdcooper = pr_cdcooper;

         vr_update := TRUE;

      EXCEPTION
        WHEN no_data_found THEN
          BEGIN
            INSERT INTO TBCRD_CONFIG_CATEGORIA(cdcooper
                                              ,cdadmcrd
                                              ,dsdias_debito
                                              ,VLLIMITE_MINIMO
                                              ,VLLIMITE_MAXIMO)
                         VALUES(pr_cdcooper
                               ,pr_cdadmcrd
                               ,pr_dddebito
                               ,pr_vllimite_min
                               ,pr_vllimite_max);

            vr_insert := TRUE;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := SQLERRM;
              RAISE vr_exc_saida;
          END;
        WHEN OTHERS THEN
          vr_dscritic := SQLERRM;
          RAISE vr_exc_saida;
      END;
    ELSE
      BEGIN
        DELETE FROM tbcrd_config_categoria t
        WHERE  t.cdadmcrd = pr_cdadmcrd
        AND    t.cdcooper = pr_cdcooper;

        vr_delete := TRUE;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := SQLERRM;
          RAISE vr_exc_saida;
      END;
    END IF;
  END IF;

  COMMIT;

  IF vr_insert THEN
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'status', pr_tag_cont => 'Cadastro realizado com sucesso', pr_des_erro => vr_dscritic);
  ELSIF vr_update THEN
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'status', pr_tag_cont => 'Atualizaçao realizada com sucesso', pr_des_erro => vr_dscritic);
  ELSE
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'status', pr_tag_cont => 'Exclusao realizada com sucesso', pr_des_erro => vr_dscritic);
  END IF;

EXCEPTION
  WHEN vr_exc_saida THEN

    IF vr_cdcritic <> 0 THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    ELSE
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    END IF;

    pr_des_erro := 'NOK';
    -- Carregar XML padrão para variável de retorno não utilizada.
    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    ROLLBACK;

  WHEN OTHERS THEN
    pr_dscritic := 'Erro na rotina pc_salva_limite_cartao_crd: ' || SQLERRM;

    -- Carregar XML padrão para variavel de retorno
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    ROLLBACK;
END pc_salva_limite_cartao_crd;


END;
/
