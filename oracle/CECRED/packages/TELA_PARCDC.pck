CREATE OR REPLACE PACKAGE CECRED.TELA_PARCDC AS

  -- Rotina para manter Parâmetros CDC
  PROCEDURE pc_manter_parametros(pr_cddopcao IN VARCHAR2                                          --> Código da Opção
                                ,pr_cdcooper_param   IN tbepr_cdc_parametro.cdcooper%TYPE         --> Código da Cooperativa
                                ,pr_inintegra_cont   IN tbepr_cdc_parametro.inintegra_cont%TYPE   --> Flag de Integração de Contingência
                                ,pr_nrprop_env       IN tbepr_cdc_parametro.nrprop_env%TYPE       --> Limite máximo de propostas
                                ,pr_intempo_prop_env IN tbepr_cdc_parametro.intempo_prop_env%TYPE --> Intervalo de tempo de propostas
                                ,pr_xmllog   IN VARCHAR2                                          --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                                      --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2                                         --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype                                --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                                         --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);                                       --> Saida OK/NOK

  -- Rotina para manter Segmentos CDC
  PROCEDURE pc_manter_segmentos(pr_cddopcao IN VARCHAR2                             --> Código da Opção
                               ,pr_tpproduto IN tbepr_cdc_segmento.tpproduto%TYPE   --> Tipo de produto
                               ,pr_cdsegmento IN tbepr_cdc_segmento.cdsegmento%TYPE --> Código do Segmento
                               ,pr_dssegmento IN tbepr_cdc_segmento.dssegmento%TYPE --> Descrição do Segmento
                               ,pr_xmllog   IN VARCHAR2                             --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                         --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                            --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype                   --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                            --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);                          --> Saida OK/NOK

  -- Rotina para manter Subsegmentos CDC
  PROCEDURE pc_manter_subsegmentos(pr_cdcooper       IN tbepr_cdc_subsegmento_coop.cdcooper%TYPE          --> Código da Cooperativa
                                  ,pr_cddopcao       IN VARCHAR2                                          --> Código da Opção
                                  ,pr_cdsegmento     IN tbepr_cdc_subsegmento.cdsegmento%TYPE             --> Código do Segmento
                                  ,pr_cdsubsegmento  IN tbepr_cdc_subsegmento.cdsegmento%TYPE             --> Código do Subsegmento
                                  ,pr_dssubsegmento  IN tbepr_cdc_subsegmento.dssubsegmento%TYPE          --> Descrição do Subsegmento
                                  ,pr_nrmax_parcela  IN tbepr_cdc_subsegmento_coop.nrmax_parcela%TYPE         --> Número máximo de parcelas
                                  ,pr_vlmax_financ   IN tbepr_cdc_subsegmento_coop.vlmax_financ%TYPE  --> Valor máximo de financiamento
                                  ,pr_nrcarecia      IN tbepr_cdc_subsegmento_coop.nrcarencia%TYPE        --> Quantidade dias da carência
                                  ,pr_xmllog         IN VARCHAR2                                          --> XML com informações de LOG
                                  ,pr_cdcritic      OUT PLS_INTEGER                                       --> Código da crítica
                                  ,pr_dscritic      OUT VARCHAR2                                          --> Descrição da crítica
                                  ,pr_retxml        IN OUT NOCOPY xmltype                                 --> Arquivo de retorno do XML
                                  ,pr_nmdcampo      OUT VARCHAR2                                          --> Nome do Campo
                                  ,pr_des_erro      OUT VARCHAR2);                                        --> Saida OK/NOK

  -- Rotina para listar os produtos CDC
  PROCEDURE pc_listar_produtos(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2          --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2);        --> Saida OK/NOK

  -- Rotina para consultar o subsegmento
  PROCEDURE pc_consulta_subsegmento(pr_cdsubsegmento  IN tbepr_cdc_subsegmento.cdsubsegmento%TYPE --> Código do Subsegmento
                                   ,pr_xmllog   IN VARCHAR2                                       --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER                                   --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                                      --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype                             --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                                      --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2);                                    --> Saida OK/NOK

  -- Rotina para consultar o segmento
  PROCEDURE pc_consulta_segmento(pr_cdsegmento  IN tbepr_cdc_segmento.cdsegmento%TYPE --> Código do Segmento
                                ,pr_xmllog   IN VARCHAR2                              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2                             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype                    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                             --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);                           --> Saida OK/NOK

  -- Rotina para consultar sequencia comissao
  PROCEDURE pc_consulta_seq_comissao(pr_cdcooper IN crapdat.cdcooper%TYPE  --> Código da Cooperativa
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK

  PROCEDURE pc_consulta_comissao(pr_idcomissao IN tbepr_cdc_parm_comissao.idcomissao %TYPE --> Código da Comissão
                                ,pr_xmllog     IN VARCHAR2                                 --> XML com informações de LOG
                                ,pr_cdcritic   OUT PLS_INTEGER                             --> Código da crítica
                                ,pr_dscritic   OUT VARCHAR2                                --> Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                                ,pr_nmdcampo   OUT VARCHAR2                                --> Nome do Campo
                                ,pr_des_erro   OUT VARCHAR2);                              --> Saida OK/NOK

  PROCEDURE pc_incluir_comissao(pr_cdcooper IN crapdat.cdcooper%TYPE                      --> Código da Cooperativa
                               ,pr_idcomissao IN tbepr_cdc_parm_comissao.idcomissao %TYPE --> Código da Comissão
                               ,pr_nmcomissao IN tbepr_cdc_parm_comissao.nmcomissao %TYPE --> Descrição da Comissão
                               ,pr_tpcomissao IN tbepr_cdc_parm_comissao.tpcomissao %TYPE --> Tipo da Comissão
                               ,pr_flgativo   IN tbepr_cdc_parm_comissao.flgativo %TYPE   --> Status
                               ,pr_xmllog     IN VARCHAR2                                 --> XML com informações de LOG
                               ,pr_cdcritic   OUT PLS_INTEGER                             --> Código da crítica
                               ,pr_dscritic   OUT VARCHAR2                                --> Descrição da crítica
                               ,pr_retxml     IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                               ,pr_nmdcampo   OUT VARCHAR2                                --> Nome do Campo
                               ,pr_des_erro   OUT VARCHAR2);                              --> Saida OK/NOK

  PROCEDURE pc_alterar_comissao(pr_cdcooper IN crapdat.cdcooper%TYPE                      --> Código da Cooperativa
                               ,pr_idcomissao IN tbepr_cdc_parm_comissao.idcomissao %TYPE --> Código da Comissão
                               ,pr_tpcomissao IN tbepr_cdc_parm_comissao.tpcomissao %TYPE --> Tipo da Comissão
                               ,pr_flgativo   IN tbepr_cdc_parm_comissao.flgativo %TYPE   --> Status
                               ,pr_xmllog     IN VARCHAR2                                 --> XML com informações de LOG
                               ,pr_cdcritic   OUT PLS_INTEGER                             --> Código da crítica
                               ,pr_dscritic   OUT VARCHAR2                                --> Descrição da crítica
                               ,pr_retxml     IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                               ,pr_nmdcampo   OUT VARCHAR2                                --> Nome do Campo
                               ,pr_des_erro   OUT VARCHAR2);                              --> Saida OK/NOK

  PROCEDURE pc_excluir_comissao(pr_idcomissao IN tbepr_cdc_parm_comissao.idcomissao %TYPE --> Código da Comissão
                               ,pr_xmllog     IN VARCHAR2                                 --> XML com informações de LOG
                               ,pr_cdcritic   OUT PLS_INTEGER                             --> Código da crítica
                               ,pr_dscritic   OUT VARCHAR2                                --> Descrição da crítica
                               ,pr_retxml     IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                               ,pr_nmdcampo   OUT VARCHAR2                                --> Nome do Campo
                               ,pr_des_erro   OUT VARCHAR2);                              --> Saida OK/NOK

  PROCEDURE pc_listar_detalhamentos(pr_idcomissao IN tbepr_cdc_parm_comissao.idcomissao %TYPE --> Código da Comissão
                                   ,pr_xmllog     IN VARCHAR2                                 --> XML com informações de LOG
                                   ,pr_cdcritic   OUT PLS_INTEGER                             --> Código da crítica
                                   ,pr_dscritic   OUT VARCHAR2                                --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                                   ,pr_nmdcampo   OUT VARCHAR2                                --> Nome do Campo
                                   ,pr_des_erro   OUT VARCHAR2);                              --> Saida OK/NOK

  PROCEDURE pc_consulta_seq_detalhamento(pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                        ,pr_cdcritic   OUT PLS_INTEGER       --> Código da crítica
                                        ,pr_dscritic   OUT VARCHAR2          --> Descrição da crítica
                                        ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                        ,pr_nmdcampo   OUT VARCHAR2          --> Nome do Campo
                                        ,pr_des_erro   OUT VARCHAR2);        --> Saida OK/NOK

  PROCEDURE pc_manter_detalhamento(pr_cddopdet    IN VARCHAR2                                       --> Opção do detalhamento
                                  ,pr_cdfaixa     IN tbepr_cdc_parm_comissao_regra.idregra %TYPE    --> Código da regra
                                  ,pr_idcomissao  IN tbepr_cdc_parm_comissao_regra.idcomissao %TYPE --> Código da Comissão
                                  ,pr_vlinicial   IN tbepr_cdc_parm_comissao_regra.vlinicial %TYPE  --> Valor inicial
                                  ,pr_vlfinal     IN tbepr_cdc_parm_comissao_regra.vlfinal %TYPE    --> Valor final
                                  ,pr_vlcomiss  IN tbepr_cdc_parm_comissao_regra.vlcomissao %TYPE --> Valor comissão
                                  ,pr_xmllog      IN VARCHAR2                                       --> XML com informações de LOG
                                  ,pr_cdcritic    OUT PLS_INTEGER                                   --> Código da crítica
                                  ,pr_dscritic    OUT VARCHAR2                                      --> Descrição da crítica
                                  ,pr_retxml      IN OUT NOCOPY xmltype                             --> Arquivo de retorno do XML
                                  ,pr_nmdcampo    OUT VARCHAR2                                      --> Nome do Campo
                                  ,pr_des_erro    OUT VARCHAR2);                                    --> Saida OK/NOK


END TELA_PARCDC;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PARCDC AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_PARCDC
  --    Autor   : Jean Michel
  --    Data    : Dezembro/2017                   Ultima Atualizacao: 23/04/2018
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package ref. a tela PARCDC (Ayllos Web)
  --
  --    Alteracoes:         23/04/2018 - Alteração para atender o projeto CDC (PRJ 439)
  --                                     Diego Simas (AMcom)
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina para manter Parâmetros CDC
  PROCEDURE pc_manter_parametros(pr_cddopcao         IN VARCHAR2                                  --> Código da Opção
                                ,pr_cdcooper_param   IN tbepr_cdc_parametro.cdcooper%TYPE         --> Código da Cooperativa
                                ,pr_inintegra_cont   IN tbepr_cdc_parametro.inintegra_cont%TYPE   --> Flag de Integração de Contingência
                                ,pr_nrprop_env       IN tbepr_cdc_parametro.nrprop_env%TYPE       --> Limite máximo de propostas
                                ,pr_intempo_prop_env IN tbepr_cdc_parametro.intempo_prop_env%TYPE --> Intervalo de tempo de propostas
                                ,pr_xmllog   IN VARCHAR2                                          --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                                      --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2                                         --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype                                --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                                         --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2) IS                                     --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_manter_parametros
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Dezembro/2017                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para manter cadastro de parametros CDC da tela PARCDC

    Alteracoes:
    ............................................................................. */

    -- CURSORES --
    CURSOR cr_tbepr_cdc_parametro(pr_cdcooper tbepr_cdc_parametro.cdcooper%TYPE) IS
      SELECT cdc.cdcooper
            ,cdc.inintegra_cont
            ,cdc.nrprop_env
            ,cdc.intempo_prop_env
        FROM tbepr_cdc_parametro cdc
       WHERE cdc.cdcooper = pr_cdcooper;

    rw_tbepr_cdc_parametro cr_tbepr_cdc_parametro%ROWTYPE;

    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE (cop.cdcooper = pr_cdcooper OR pr_cdcooper = 99)
         AND cop.flgativo = 1;

    rw_crapcop cr_crapcop%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN

    IF UPPER(pr_cddopcao) = 'C' THEN
      OPEN cr_tbepr_cdc_parametro(pr_cdcooper => pr_cdcooper_param);
      FETCH cr_tbepr_cdc_parametro INTO rw_tbepr_cdc_parametro;

      IF cr_tbepr_cdc_parametro%NOTFOUND THEN
        CLOSE cr_tbepr_cdc_parametro;
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'cdcooper',         pr_tag_cont => '99', pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'inintegra_cont',   pr_tag_cont => '0', pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'nrprop_env',       pr_tag_cont => '10', pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'intempo_prop_env', pr_tag_cont => '60', pr_des_erro => vr_dscritic);
      ELSE
        CLOSE cr_tbepr_cdc_parametro;
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'cdcooper',         pr_tag_cont => TO_CHAR(rw_tbepr_cdc_parametro.cdcooper), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'inintegra_cont',   pr_tag_cont => TO_CHAR(rw_tbepr_cdc_parametro.inintegra_cont), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'nrprop_env',       pr_tag_cont => TO_CHAR(rw_tbepr_cdc_parametro.nrprop_env), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'intempo_prop_env', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_parametro.intempo_prop_env), pr_des_erro => vr_dscritic);
      END IF;

    ELSIF UPPER(pr_cddopcao) = 'A' THEN
      FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcooper_param) LOOP
        BEGIN
          INSERT INTO tbepr_cdc_parametro(cdcooper, inintegra_cont, nrprop_env, intempo_prop_env)
            VALUES(rw_crapcop.cdcooper, pr_inintegra_cont, pr_nrprop_env, pr_intempo_prop_env);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            BEGIN
              UPDATE tbepr_cdc_parametro
                SET inintegra_cont   = pr_inintegra_cont
                   ,nrprop_env       = pr_nrprop_env
                   ,intempo_prop_env = pr_intempo_prop_env
                WHERE tbepr_cdc_parametro.cdcooper = rw_crapcop.cdcooper;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar registro de parâmetros CDC. Erro: ' || SQLERRM;
                RAISE vr_exc_erro;
            END;
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro de parâmetros CDC. Erro: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      END LOOP;
    END IF;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PARCDC.PC_MANTER_PARAMETROS --> ' || SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

  END pc_manter_parametros;

  -- Rotina para manter Segmentos CDC
  PROCEDURE pc_manter_segmentos(pr_cddopcao IN VARCHAR2                             --> Código da Opção
                               ,pr_tpproduto IN tbepr_cdc_segmento.tpproduto%TYPE   --> Tipo de produto
                               ,pr_cdsegmento IN tbepr_cdc_segmento.cdsegmento%TYPE --> Código do Segmento
                               ,pr_dssegmento IN tbepr_cdc_segmento.dssegmento%TYPE --> Descrição do Segmento
                               ,pr_xmllog   IN VARCHAR2                             --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                         --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                            --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype                   --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                            --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2) IS                        --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_manter_segmentos
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Dezembro/2017                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para manter cadastro de segmentos da tela PARCDC

    Alteracoes:
    ............................................................................. */

    -- CURSORES --
    CURSOR cr_tbepr_cdc_segmento IS
      SELECT distinct seg.cdsegmento cdsegmento
            ,c.dsfinemp tpproduto
            ,seg.dssegmento dssegmento
        FROM tbepr_cdc_segmento seg,
             crapfin c
       WHERE seg.cdsegmento = pr_cdsegmento OR pr_cdsegmento = 0
         AND c.cdfinemp = seg.tpproduto
         AND c.tpfinali = 3
         AND c.flgstfin = 1
    GROUP BY seg.cdsegmento
            ,c.dsfinemp
            ,seg.dssegmento
    ORDER BY seg.cdsegmento;
    rw_tbepr_cdc_segmento cr_tbepr_cdc_segmento%ROWTYPE;

    CURSOR cr_tbepr_cdc_subsegmento IS
      SELECT sub.cdsubsegmento
        FROM tbepr_cdc_subsegmento sub
     WHERE sub.cdsegmento = pr_cdsegmento;
    rw_tbepr_cdc_subsegmento cr_tbepr_cdc_subsegmento%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    --Variáveis auxiliares
    vr_clobxml   CLOB;

    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_contaseg INTEGER := 0;

  BEGIN
    IF UPPER(pr_cddopcao) = 'A' THEN

      BEGIN
        UPDATE tbepr_cdc_segmento
           SET tbepr_cdc_segmento.dssegmento = UPPER(pr_dssegmento)
              ,tbepr_cdc_segmento.tpproduto = pr_tpproduto
         WHERE tbepr_cdc_segmento.cdsegmento = pr_cdsegmento;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar registro de Segmento. Erro: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

    ELSIF UPPER(pr_cddopcao) = 'C' THEN

      -- Informacoes de cabecalho de pacote
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'segmentos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

      FOR rw_tbepr_cdc_segmento IN cr_tbepr_cdc_segmento LOOP

        -- Informacoes de cabecalho de pacote
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'segmentos', pr_posicao => 0, pr_tag_nova => 'segmento', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'segmento',   pr_posicao => vr_contaseg, pr_tag_nova => 'dsproduto', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_segmento.tpproduto), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'segmento',   pr_posicao => vr_contaseg, pr_tag_nova => 'cdsegmento', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_segmento.cdsegmento), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'segmento',   pr_posicao => vr_contaseg, pr_tag_nova => 'dssegmento', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_segmento.dssegmento), pr_des_erro => vr_dscritic);
        vr_contaseg := vr_contaseg + 1;

      END LOOP;

    ELSIF UPPER(pr_cddopcao) = 'E' THEN

      OPEN cr_tbepr_cdc_subsegmento;

      FETCH cr_tbepr_cdc_subsegmento INTO rw_tbepr_cdc_subsegmento;

      IF cr_tbepr_cdc_subsegmento%NOTFOUND THEN
        BEGIN
          DELETE tbepr_cdc_segmento WHERE tbepr_cdc_segmento.cdsegmento = pr_cdsegmento;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro de Segmento. Erro: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      ELSE
        vr_dscritic := 'Segmento não pode ser excluído, possui subsegmentos vinculados.';
        RAISE vr_exc_erro;
      END IF;

    ELSIF UPPER(pr_cddopcao) = 'I' THEN

      BEGIN
        INSERT INTO tbepr_cdc_segmento(cdsegmento,dssegmento,tpproduto) VALUES(pr_cdsegmento,UPPER(pr_dssegmento),pr_tpproduto);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          vr_dscritic := 'Codigo de Segmento ja cadastrado.';
          RAISE vr_exc_erro;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir registro de Segmento. Erro: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

    END IF;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PARCDC.PC_MANTER_SEGMENTOS --> ' || SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

  END pc_manter_segmentos;

  -- Rotina para manter Subsegmentos CDC
  PROCEDURE pc_manter_subsegmentos(pr_cdcooper       IN tbepr_cdc_subsegmento_coop.cdcooper%TYPE          --> Código da Cooperativa
                                  ,pr_cddopcao       IN VARCHAR2                                          --> Código da Opção
                                  ,pr_cdsegmento     IN tbepr_cdc_subsegmento.cdsegmento%TYPE             --> Código do Segmento
                                  ,pr_cdsubsegmento  IN tbepr_cdc_subsegmento.cdsegmento%TYPE             --> Código do Subsegmento
                                  ,pr_dssubsegmento  IN tbepr_cdc_subsegmento.dssubsegmento%TYPE          --> Descrição do Subsegmento
                                  ,pr_nrmax_parcela  IN tbepr_cdc_subsegmento_coop.nrmax_parcela%TYPE         --> Número máximo de parcelas
                                  ,pr_vlmax_financ   IN tbepr_cdc_subsegmento_coop.vlmax_financ%TYPE  --> Valor máximo de financiamento
                                  ,pr_nrcarecia      IN tbepr_cdc_subsegmento_coop.nrcarencia%TYPE        --> Quantidade dias da carência
                                  ,pr_xmllog         IN VARCHAR2                                          --> XML com informações de LOG
                                  ,pr_cdcritic      OUT PLS_INTEGER                                       --> Código da crítica
                                  ,pr_dscritic      OUT VARCHAR2                                          --> Descrição da crítica
                                  ,pr_retxml        IN OUT NOCOPY xmltype                                 --> Arquivo de retorno do XML
                                  ,pr_nmdcampo      OUT VARCHAR2                                          --> Nome do Campo
                                  ,pr_des_erro      OUT VARCHAR2) IS                                      --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_manter_subsegmentos
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Dezembro/2017                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para manter cadastro de subsegmentos da tela PARCDC

    Alteracoes:
    ............................................................................. */

    -- CURSORES --

    -- Cursor para listar subsegmentos da cooperativa ativa
    CURSOR cr_tbepr_cdc_subsegmento_c(pr_cdcooper tbepr_cdc_subsegmento_coop.cdcooper%TYPE
                                     ,pr_cdsegmento tbepr_cdc_subsegmento.cdsegmento%TYPE) IS
      SELECT sub.cdsubsegmento cdsubsegmento
             ,sub.dssubsegmento dssubsegmento
             ,sub.cdsegmento cdsegmento
             ,subCoop.nrmax_parcela
             ,subCoop.vlmax_financ 
             ,subCoop.Nrcarencia nrcarencia
        FROM tbepr_cdc_subsegmento sub,
             tbepr_cdc_subsegmento_coop subCoop
       WHERE sub.cdsegmento = pr_cdsegmento
         AND subCoop.Cdcooper = pr_cdcooper
         AND subCoop.Cdsubsegmento = sub.cdsubsegmento;
    rw_tbepr_cdc_subsegmento_c cr_tbepr_cdc_subsegmento_c%ROWTYPE;

    -- Cursor para listar todos os subsegmentos das cooperativas (CECRED)
    CURSOR cr_tbepr_cdc_subseg_cecred(pr_cdsegmento tbepr_cdc_subsegmento.cdsegmento%TYPE) IS
      SELECT distinct sub.cdsubsegmento cdsubsegmento
                     ,sub.dssubsegmento dssubsegmento
             ,sub.cdsegmento cdsegmento
             ,subCoop.nrmax_parcela
             ,subCoop.vlmax_financ 
             ,subCoop.Nrcarencia nrcarencia
        FROM tbepr_cdc_subsegmento sub,
             tbepr_cdc_subsegmento_coop subCoop
       WHERE sub.cdsegmento = pr_cdsegmento
         AND subCoop.Cdsubsegmento = sub.cdsubsegmento;
    rw_tbepr_cdc_subseg_cecred cr_tbepr_cdc_subseg_cecred%ROWTYPE;

    -- cursor para sugestionar ao usuário qual o próximo código do subsegmento
    CURSOR cr_tbepr_cdc_subsegmento IS
      SELECT (MAX(sub.cdsubsegmento) + 1) proxCodSub
        FROM tbepr_cdc_subsegmento sub;
    rw_tbepr_cdc_subsegmento cr_tbepr_cdc_subsegmento%ROWTYPE;

    CURSOR cr_consulta_subsegmento_coop(pr_cdcooper tbepr_cdc_subsegmento_coop.cdcooper%TYPE
                                       ,pr_cdsubsegmento tbepr_cdc_subsegmento_coop.cdsubsegmento%TYPE) IS
      SELECT subCoop.cdsubsegmento cdsubsegmento
        FROM tbepr_cdc_subsegmento_coop subCoop
       WHERE subCoop.Cdcooper = pr_cdcooper
         AND subCoop.Cdsubsegmento = pr_cdsubsegmento;
    rw_consulta_subsegmento_coop cr_consulta_subsegmento_coop%ROWTYPE;

    CURSOR cr_crapcop IS
      SELECT c.cdcooper
        FROM crapcop c
       WHERE c.cdcooper <> 3 -- CECRED
         AND c.flgativo = 1
    ORDER BY c.cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    --- VARIAVEIS ERRO ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_erro EXCEPTION;

    --- VARIAVEIS ---
    aux_sub_seg_existe INTEGER :=0;
    vr_contasub INTEGER := 0;

  BEGIN

    IF UPPER(pr_cddopcao) = 'A' THEN

      BEGIN
        UPDATE tbepr_cdc_subsegmento sub
           SET sub.cdsegmento = pr_cdsegmento
              ,sub.dssubsegmento = UPPER(pr_dssubsegmento)
         WHERE sub.cdsubsegmento = pr_cdsubsegmento;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar registro de Subsegmento. Erro: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      BEGIN
        UPDATE tbepr_cdc_subsegmento_coop subCoop
           SET subCoop.Cdsubsegmento = pr_cdsubsegmento
              ,subCoop.nrmax_parcela = pr_nrmax_parcela
              ,subCoop.vlmax_financ = pr_vlmax_financ
              ,subCoop.Nrcarencia = pr_nrcarecia
         WHERE subCoop.cdcooper = pr_cdcooper
           AND subCoop.cdsubsegmento = pr_cdsubsegmento;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar registro de Subsegmento Coop. Erro: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

    ELSIF UPPER(pr_cddopcao) = 'C' THEN

      -- Quando for Cecred listar todos os segmentos
      IF pr_cdcooper = 3 THEN
        -- Informacoes de cabecalho de pacote
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'subsegmentos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

        FOR rw_tbepr_cdc_subseg_cecred IN cr_tbepr_cdc_subseg_cecred(pr_cdsegmento    => pr_cdsegmento) LOOP
          -- Informacoes de cabecalho de pacote
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmentos', pr_posicao => 0, pr_tag_nova => 'subsegmento', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmento',  pr_posicao => vr_contasub, pr_tag_nova => 'cdsegmento', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_subseg_cecred.cdsegmento), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmento',  pr_posicao => vr_contasub, pr_tag_nova => 'cdsubsegmento', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_subseg_cecred.cdsubsegmento), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmento',  pr_posicao => vr_contasub, pr_tag_nova => 'dssubsegmento', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_subseg_cecred.dssubsegmento), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmento',  pr_posicao => vr_contasub, pr_tag_nova => 'nrmax_parcela', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_subseg_cecred.nrmax_parcela), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmento',  pr_posicao => vr_contasub, pr_tag_nova => 'vlmax_financ', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_subseg_cecred.vlmax_financ,'FM999G999G990D00'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmento',  pr_posicao => vr_contasub, pr_tag_nova => 'nrcarencia', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_subseg_cecred.nrcarencia), pr_des_erro => vr_dscritic);
          vr_contasub := vr_contasub + 1;
        END LOOP;
      ELSE
        -- Informacoes de cabecalho de pacote
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'subsegmentos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

        FOR rw_tbepr_cdc_subsegmento_c IN cr_tbepr_cdc_subsegmento_c(pr_cdcooper      => pr_cdcooper
                                                                    ,pr_cdsegmento    => pr_cdsegmento) LOOP
          -- Informacoes de cabecalho de pacote
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmentos', pr_posicao => 0, pr_tag_nova => 'subsegmento', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmento',  pr_posicao => vr_contasub, pr_tag_nova => 'cdsegmento', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_subsegmento_c.cdsegmento), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmento',  pr_posicao => vr_contasub, pr_tag_nova => 'cdsubsegmento', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_subsegmento_c.cdsubsegmento), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmento',  pr_posicao => vr_contasub, pr_tag_nova => 'dssubsegmento', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_subsegmento_c.dssubsegmento), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmento',  pr_posicao => vr_contasub, pr_tag_nova => 'nrmax_parcela', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_subsegmento_c.nrmax_parcela), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmento',  pr_posicao => vr_contasub, pr_tag_nova => 'vlmax_financ', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_subsegmento_c.vlmax_financ,'FM999G999G990D00'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'subsegmento',  pr_posicao => vr_contasub, pr_tag_nova => 'nrcarencia', pr_tag_cont => TO_CHAR(rw_tbepr_cdc_subsegmento_c.nrcarencia), pr_des_erro => vr_dscritic);
          vr_contasub := vr_contasub + 1;
        END LOOP;
      END IF;

    ELSIF UPPER(pr_cddopcao) = 'E' THEN

      OPEN cr_consulta_subsegmento_coop(pr_cdcooper => pr_cdcooper
                                       ,pr_cdsubsegmento => pr_cdsubsegmento);
      FETCH cr_consulta_subsegmento_coop INTO rw_consulta_subsegmento_coop;

      IF cr_consulta_subsegmento_coop%NOTFOUND THEN
        CLOSE cr_consulta_subsegmento_coop;
        BEGIN
          DELETE tbepr_cdc_subsegmento WHERE tbepr_cdc_subsegmento.cdsubsegmento = pr_cdsubsegmento;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro de Subsegmento. Erro: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      ELSE
        CLOSE cr_consulta_subsegmento_coop;
        vr_dscritic := 'Subsegmento não pode ser excluído, possui lojistas vinculados. Cod: ' || pr_cdsubsegmento;
        RAISE vr_exc_erro;
      END IF;

    ELSIF UPPER(pr_cddopcao) = 'I' THEN

      -- Grava subsegmento
      BEGIN
        INSERT INTO tbepr_cdc_subsegmento(cdsubsegmento, dssubsegmento, cdsegmento)
             VALUES(pr_cdsubsegmento,UPPER(pr_dssubsegmento),pr_cdsegmento);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          OPEN cr_tbepr_cdc_subsegmento();
          FETCH cr_tbepr_cdc_subsegmento INTO rw_tbepr_cdc_subsegmento;
          IF cr_tbepr_cdc_subsegmento%NOTFOUND THEN
            CLOSE cr_tbepr_cdc_subsegmento;
            NULL;
          ELSE
            aux_sub_seg_existe := rw_tbepr_cdc_subsegmento.proxcodsub;
            vr_dscritic := 'Este subsegmento ja existe nesta ou em outra cooperativa! Sugestao para o Codigo do Subsegmento ' || aux_sub_seg_existe;
            RAISE vr_exc_erro;
            CLOSE cr_tbepr_cdc_subsegmento;
          END IF;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir registro de Subsegmento. Erro: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      FOR rw_crapcop IN cr_crapcop LOOP
        -- Grava subsegmento coop
        BEGIN
          INSERT INTO tbepr_cdc_subsegmento_coop(cdcooper
                                                ,cdsubsegmento
                                                ,nrmax_parcela
                                                ,vlmax_financ
                                                ,nrcarencia)
               VALUES(rw_crapcop.cdcooper
                     ,pr_cdsubsegmento
                     ,pr_nrmax_parcela
                     ,pr_vlmax_financ
                     ,pr_nrcarecia);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro de Subsegmento Cooperativa. Erro: ' || SQLERRM;
           RAISE vr_exc_erro;
        END;
      END LOOP;

    END IF;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PARCDC.PC_MANTER_SUBSEGMENTOS --> ' || SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

  END pc_manter_subsegmentos;

  -- Rotina para listar produtos CDC
  PROCEDURE pc_listar_produtos(pr_xmllog   IN VARCHAR2                             --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER                         --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2                            --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype                   --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2                            --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2) IS                        --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_lista_produto
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Diego Simas
    Data    : Abril/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para listar os produtos para o segmento.

    Alteracoes:
    ............................................................................. */

    -- CURSORES --
    CURSOR cr_lista_produto IS
      SELECT c.cdfinemp cdProduto
            ,c.dsfinemp dsProduto
        FROM crapfin c
       WHERE c.tpfinali = 3
         AND c.flgstfin = 1
    GROUP BY c.cdfinemp
            ,c.dsfinemp;
    rw_lista_produto cr_lista_produto%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    --Variáveis auxiliares
    vr_clobxml   CLOB;
    vr_contaprod INTEGER := 0;

    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN
    -- Informacoes de cabecalho de pacote
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'produtos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_lista_produto IN cr_lista_produto LOOP
      -- Informacoes de cabecalho de pacote
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'produtos', pr_posicao => 0, pr_tag_nova => 'produto', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'produto',  pr_posicao => vr_contaprod, pr_tag_nova => 'codproduto', pr_tag_cont => TO_CHAR(rw_lista_produto.cdproduto), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'produto',  pr_posicao => vr_contaprod, pr_tag_nova => 'desproduto', pr_tag_cont => TO_CHAR(rw_lista_produto.dsproduto), pr_des_erro => vr_dscritic);
      vr_contaprod := vr_contaprod + 1;
    END LOOP;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PARCDC.PC_LISTA_PRODUTOS --> ' || SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

  END pc_listar_produtos;

  -- Rotina para consultar subsegmento CDC
  PROCEDURE pc_consulta_subsegmento(pr_cdsubsegmento  IN tbepr_cdc_subsegmento.cdsubsegmento%TYPE --> Código do Subsegmento
                                   ,pr_xmllog   IN VARCHAR2                                    --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER                                --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                                   --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype                          --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                                   --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2) IS                        --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_consulta_subsegmento
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Diego Simas
    Data    : Abril/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar subsegmento.

    Alteracoes:
    ............................................................................. */

    -- CURSORES --
    CURSOR cr_consulta_subsegmento(pr_cdsubsegmento tbepr_cdc_subsegmento.cdsubsegmento%TYPE) IS
      SELECT  sub.cdsubsegmento cdsubsegmento
             ,sub.dssubsegmento dssubsegmento
             ,sub.cdsegmento cdsegmento
             ,subCoop.nrmax_parcela 
             ,subCoop.vlmax_financ 
             ,subCoop.Nrcarencia nrcarencia
        FROM tbepr_cdc_subsegmento sub,
             tbepr_cdc_subsegmento_coop subCoop
       WHERE sub.cdsubsegmento = pr_cdsubsegmento
         AND subCoop.cdsubsegmento = sub.cdsubsegmento;
    rw_consulta_subsegmento cr_consulta_subsegmento%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    --Variáveis auxiliares
    vr_clobxml   CLOB;

    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN

    OPEN cr_consulta_subsegmento(pr_cdsubsegmento => pr_cdsubsegmento);
    FETCH cr_consulta_subsegmento INTO rw_consulta_subsegmento;
    IF cr_consulta_subsegmento%NOTFOUND THEN
      CLOSE cr_consulta_subsegmento;
      vr_dscritic := 'Subsegmento não encontrado. SubSegmento: ' || pr_cdsubsegmento;
      RAISE vr_exc_erro;
    ELSE

      CLOSE cr_consulta_subsegmento;
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      -- Informacoes retorno da mensageria
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'codsubsegmento', pr_tag_cont => TO_CHAR(rw_consulta_subsegmento.cdsubsegmento), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'dessubsegmento', pr_tag_cont => TO_CHAR(rw_consulta_subsegmento.dssubsegmento), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'codsegmento', pr_tag_cont => TO_CHAR(rw_consulta_subsegmento.cdsegmento), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'nrmaxparcelas', pr_tag_cont => TO_CHAR(rw_consulta_subsegmento.nrmax_parcela), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'vlmaxproposta', pr_tag_cont => TO_CHAR(rw_consulta_subsegmento.vlmax_financ,'FM999G999G999D90', 'nls_numeric_characters='',.'''), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'nrcarencia', pr_tag_cont => TO_CHAR(rw_consulta_subsegmento.nrcarencia), pr_des_erro => vr_dscritic);
    END IF;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PARCDC.PC_LISTA_SUBSEGMENTOS --> ' || SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

  END pc_consulta_subsegmento;

  -- Rotina para consultar subsegmento CDC
  PROCEDURE pc_consulta_segmento(pr_cdsegmento  IN tbepr_cdc_segmento.cdsegmento%TYPE --> Código do Subsegmento
                                ,pr_xmllog   IN VARCHAR2                              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2                             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype                    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                             --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2) IS                        --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_consulta_subsegmento
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Diego Simas
    Data    : Abril/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar subsegmento.

    Alteracoes:
    ............................................................................. */

    -- CURSORES --
    CURSOR cr_consulta_segmento(pr_cdsegmento tbepr_cdc_segmento.cdsegmento%TYPE) IS
      SELECT  seg.cdsegmento cdsegmento
             ,seg.dssegmento dssegmento
             ,seg.tpproduto tpproduto
        FROM tbepr_cdc_segmento seg
       WHERE seg.cdsegmento = pr_cdsegmento;
    rw_consulta_segmento cr_consulta_segmento%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    --Variáveis auxiliares
    vr_clobxml   CLOB;

    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN

    OPEN cr_consulta_segmento(pr_cdsegmento => pr_cdsegmento);
    FETCH cr_consulta_segmento INTO rw_consulta_segmento;
    IF cr_consulta_segmento%NOTFOUND THEN
      CLOSE cr_consulta_segmento;
      vr_dscritic := 'Segmento nao encontrado. Segmento: ' || pr_cdsegmento;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_consulta_segmento;
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      -- Informacoes retorno da mensageria
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'codsegmento', pr_tag_cont => TO_CHAR(rw_consulta_segmento.cdsegmento), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'dessegmento', pr_tag_cont => TO_CHAR(rw_consulta_segmento.dssegmento), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'tpproduto', pr_tag_cont => TO_CHAR(rw_consulta_segmento.tpproduto), pr_des_erro => vr_dscritic);
    END IF;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PARCDC.PC_LISTA_SEGMENTOS --> ' || SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

  END pc_consulta_segmento;

  -- Rotina para consultar sequencia comissao CDC
  PROCEDURE pc_consulta_seq_comissao(pr_cdcooper IN crapdat.cdcooper%TYPE  --> Código da Cooperativa
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2) IS                        --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_consulta_seq_comissao
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Diego Simas
    Data    : Abril/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar sequencia comissao.

    Alteracoes:
    ............................................................................. */

    -- CURSORES --

    CURSOR cr_consulta_seq_comissao IS
      SELECT (MAX(comissao.idcomissao) + 1) sequencia
        FROM tbepr_cdc_parm_comissao comissao;
    rw_consulta_seq_comissao cr_consulta_seq_comissao%ROWTYPE;

    CURSOR cr_consulta_data (pr_cdcooper crapdat.cdcooper%TYPE)IS
      SELECT c.dtmvtolt dataAtual
        FROM crapdat c
       WHERE c.cdcooper = pr_cdcooper;
    rw_consulta_data cr_consulta_data%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    --Variáveis auxiliares
    vr_clobxml   CLOB;

    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN

    -- Cabecalho mensageria
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    -- Informacoes retorno da mensageria
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    OPEN cr_consulta_seq_comissao;
    FETCH cr_consulta_seq_comissao INTO rw_consulta_seq_comissao;
    IF cr_consulta_seq_comissao%NOTFOUND THEN
      CLOSE cr_consulta_seq_comissao;
      vr_dscritic := 'Sequencia de comissao nao encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_consulta_seq_comissao;
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'cdseqcomissao', pr_tag_cont => TO_CHAR(rw_consulta_seq_comissao.sequencia), pr_des_erro => vr_dscritic);
    END IF;

    OPEN cr_consulta_data(pr_cdcooper => pr_cdcooper);
    FETCH cr_consulta_data INTO rw_consulta_data;
    IF cr_consulta_data%NOTFOUND THEN
      CLOSE cr_consulta_data;
      vr_dscritic := 'Data da cooperativa nao encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_consulta_data;
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'dtcriacao', pr_tag_cont => TO_CHAR(rw_consulta_data.dataatual,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);
    END IF;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PARCDC.PC_CONSULTA_SEQ_COMISSAO --> ' || SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

  END pc_consulta_seq_comissao;

  -- Rotina para consultar comissao CDC
  PROCEDURE pc_consulta_comissao(pr_idcomissao IN tbepr_cdc_parm_comissao.idcomissao %TYPE --> Código da Cooperativa
                                ,pr_xmllog     IN VARCHAR2                                 --> XML com informações de LOG
                                ,pr_cdcritic   OUT PLS_INTEGER                             --> Código da crítica
                                ,pr_dscritic   OUT VARCHAR2                                --> Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                                ,pr_nmdcampo   OUT VARCHAR2                                --> Nome do Campo
                                ,pr_des_erro   OUT VARCHAR2) IS                            --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_consulta_comissao
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Diego Simas
    Data    : Abril/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar comissao.

    Alteracoes:
    ............................................................................. */

    -- CURSORES --

    CURSOR cr_consulta_comissao (pr_idcomissao tbepr_cdc_parm_comissao.idcomissao%TYPE) IS
      SELECT comissao.idcomissao
            ,comissao.nmcomissao
            ,comissao.tpcomissao
            ,comissao.flgativo
            ,comissao.dtinsori
            ,comissao.dtrefatu
        FROM tbepr_cdc_parm_comissao comissao
       WHERE comissao.idcomissao = pr_idcomissao;
    rw_consulta_comissao cr_consulta_comissao%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    --Variáveis auxiliares
    vr_clobxml   CLOB;

    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN

    -- Cabecalho mensageria
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    -- Informacoes retorno da mensageria
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    OPEN cr_consulta_comissao(pr_idcomissao => pr_idcomissao);
    FETCH cr_consulta_comissao INTO rw_consulta_comissao;
    IF cr_consulta_comissao%NOTFOUND THEN
      CLOSE cr_consulta_comissao;
      vr_dscritic := 'Comissao inexistente.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_consulta_comissao;
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'idcomissao', pr_tag_cont => TO_CHAR(rw_consulta_comissao.idcomissao), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'nmcomissao', pr_tag_cont => TO_CHAR(rw_consulta_comissao.nmcomissao), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'tpcomissao', pr_tag_cont => TO_CHAR(rw_consulta_comissao.tpcomissao), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'flgativo', pr_tag_cont => TO_CHAR(rw_consulta_comissao.flgativo), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'dtinsori', pr_tag_cont => TO_CHAR(rw_consulta_comissao.dtinsori, 'DD/MM/YYYY'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'dtrefaut', pr_tag_cont => TO_CHAR(rw_consulta_comissao.dtrefatu, 'DD/MM/YYYY'), pr_des_erro => vr_dscritic);
    END IF;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PARCDC.PC_CONSULTA_SEQ_COMISSAO --> ' || SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

  END pc_consulta_comissao;

  -- Rotina para inserir comissao CDC
  PROCEDURE pc_incluir_comissao(pr_cdcooper IN crapdat.cdcooper%TYPE                      --> Código da Cooperativa
                               ,pr_idcomissao IN tbepr_cdc_parm_comissao.idcomissao %TYPE --> Código da Comissão
                               ,pr_nmcomissao IN tbepr_cdc_parm_comissao.nmcomissao %TYPE --> Descrição da Comissão
                               ,pr_tpcomissao IN tbepr_cdc_parm_comissao.tpcomissao %TYPE --> Tipo da Comissão
                               ,pr_flgativo   IN tbepr_cdc_parm_comissao.flgativo %TYPE   --> Status
                               ,pr_xmllog     IN VARCHAR2                                 --> XML com informações de LOG
                               ,pr_cdcritic   OUT PLS_INTEGER                             --> Código da crítica
                               ,pr_dscritic   OUT VARCHAR2                                --> Descrição da crítica
                               ,pr_retxml     IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                               ,pr_nmdcampo   OUT VARCHAR2                                --> Nome do Campo
                               ,pr_des_erro   OUT VARCHAR2) IS                            --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_incluir_comissao
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Diego Simas
    Data    : Abril/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para incluir comissao.

    Alteracoes:
    ............................................................................. */

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_idcomcor INTEGER;
    --Variáveis auxiliares
    vr_clobxml   CLOB;

    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN

    -- Grava comissão
    BEGIN

      INSERT INTO tbepr_cdc_parm_comissao(nmcomissao
                                         ,tpcomissao
                                         ,flgativo)
           VALUES(UPPER(pr_nmcomissao)
                 ,pr_tpcomissao
                 ,pr_flgativo)
      RETURNING idcomissao into vr_idcomcor;

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir registro de Comissao. Erro: ' || SQLERRM;
        RAISE vr_exc_erro;

    END;

    -- Cabecalho mensageria
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    -- Informacoes retorno da mensageria
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'idcomcor', pr_tag_cont => TO_CHAR(vr_idcomcor), pr_des_erro => vr_dscritic);

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PARCDC.PC_INCLUIR_COMISSAO --> ' || SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

  END pc_incluir_comissao;

  -- Rotina para alterar comissao CDC
  PROCEDURE pc_alterar_comissao(pr_cdcooper IN crapdat.cdcooper%TYPE                      --> Código da Cooperativa
                               ,pr_idcomissao IN tbepr_cdc_parm_comissao.idcomissao %TYPE --> Código da Comissão
                               ,pr_tpcomissao IN tbepr_cdc_parm_comissao.tpcomissao %TYPE --> Tipo da Comissão
                               ,pr_flgativo   IN tbepr_cdc_parm_comissao.flgativo %TYPE   --> Status
                               ,pr_xmllog     IN VARCHAR2                                 --> XML com informações de LOG
                               ,pr_cdcritic   OUT PLS_INTEGER                             --> Código da crítica
                               ,pr_dscritic   OUT VARCHAR2                                --> Descrição da crítica
                               ,pr_retxml     IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                               ,pr_nmdcampo   OUT VARCHAR2                                --> Nome do Campo
                               ,pr_des_erro   OUT VARCHAR2) IS                            --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_alterar_comissao
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Diego Simas
    Data    : Abril/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para alterar comissao.

    Alteracoes:
    ............................................................................. */

    -- CURSORES --

    -- Consulta comissão vinculada ao vendedor ou cooperado
    CURSOR cr_consulta_comiss_vinc(pr_idcomissao tbepr_cdc_parm_comissao.idcomissao%TYPE)IS
      SELECT COUNT(*) ttcomvinc
        FROM tbepr_cdc_vendedor v,
             tbsite_cooperado_cdc c
       WHERE v.idcomissao = pr_idcomissao
          OR c.idcomissao = pr_idcomissao;
    rw_consulta_comiss_vinc cr_consulta_comiss_vinc%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    --Variáveis auxiliares
    vr_clobxml   CLOB;

    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN

    -- Consulta se comissão está vinculada ao cooperado ou vendedor
    OPEN cr_consulta_comiss_vinc(pr_idcomissao => pr_idcomissao);
    FETCH cr_consulta_comiss_vinc INTO rw_consulta_comiss_vinc;
    IF cr_consulta_comiss_vinc%NOTFOUND THEN
      CLOSE cr_consulta_comiss_vinc;
      vr_dscritic := 'Nao ha vinculo cadastrado para esta comissao.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_consulta_comiss_vinc;
      IF rw_consulta_comiss_vinc.ttcomvinc > 0 THEN
        IF pr_flgativo = 0 THEN
          vr_dscritic := 'Esta comissao possui vinculo. A flag ativo deve estar checada!';
          RAISE vr_exc_erro;
        END IF;
      END IF;
    END IF;

    -- altera comissão
    BEGIN
      UPDATE tbepr_cdc_parm_comissao
        SET tpcomissao = pr_tpcomissao
           ,flgativo   = pr_flgativo        
        WHERE tbepr_cdc_parm_comissao.idcomissao = pr_idcomissao;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar comissão CDC. Erro: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;

      pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PARCDC.PC_ALTERAR_COMISSAO --> ' || SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

  END pc_alterar_comissao;

  -- Rotina para excluir comissao CDC e suas regras/detalhamentos
  PROCEDURE pc_excluir_comissao(pr_idcomissao IN tbepr_cdc_parm_comissao.idcomissao %TYPE --> Código da Comissão
                               ,pr_xmllog     IN VARCHAR2                                 --> XML com informações de LOG
                               ,pr_cdcritic   OUT PLS_INTEGER                             --> Código da crítica
                               ,pr_dscritic   OUT VARCHAR2                                --> Descrição da crítica
                               ,pr_retxml     IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                               ,pr_nmdcampo   OUT VARCHAR2                                --> Nome do Campo
                               ,pr_des_erro   OUT VARCHAR2) IS                            --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_excluir_comissao
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Diego Simas
    Data    : Abril/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para excluir comissao CDC e suas regras/detalhamentos.

    Alteracoes:
    ............................................................................. */

    -- CURSORES --
    CURSOR cr_comissao(pr_idcomissao tbepr_cdc_parm_comissao.idcomissao%TYPE)IS
      SELECT c.nmcomissao
        FROM tbepr_cdc_parm_comissao c
       WHERE c.idcomissao = pr_idcomissao;
    rw_comissao cr_comissao%ROWTYPE;

    CURSOR cr_valida_com (pr_idcomissao tbepr_cdc_parm_comissao.idcomissao%TYPE) IS
      select c.idcomissao
        from tbsite_cooperado_cdc c
       where c.idcomissao = pr_idcomissao
     union all
       select v.idcomissao
        from tbepr_cdc_vendedor v
       where v.idcomissao = pr_idcomissao;
    rw_valida_com cr_valida_com%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    --Variáveis auxiliares
    vr_clobxml   CLOB;

    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN

    OPEN cr_valida_com(pr_idcomissao => pr_idcomissao);
    FETCH cr_valida_com INTO rw_valida_com;

    IF cr_valida_com%FOUND THEN
      CLOSE cr_valida_com;
      vr_dscritic := 'Nao foi possivel excluir a comissao, existem lojistas e/ou vendedores associados a mesma!';
      RAISE vr_exc_erro;
    END IF;

    OPEN cr_comissao(pr_idcomissao => pr_idcomissao);
    FETCH cr_comissao INTO rw_comissao;
    IF cr_comissao%FOUND THEN

      CLOSE cr_comissao;

      BEGIN
        DELETE tbepr_cdc_parm_comissao_regra
         WHERE tbepr_cdc_parm_comissao_regra.idcomissao = pr_idcomissao;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir o registro do detalhamento da regra. Erro: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      BEGIN
        DELETE tbepr_cdc_parm_comissao
         WHERE tbepr_cdc_parm_comissao.idcomissao = pr_idcomissao;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir registro de comissao. Erro: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

    ELSE

      CLOSE cr_comissao;
      vr_dscritic := 'Comissao inexistente.';
      RAISE vr_exc_erro;

    END IF;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PARCDC.PC_ALTERAR_COMISSAO --> ' || SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_excluir_comissao;

  -- Rotina para listar detalhamentos da comissão
  PROCEDURE pc_listar_detalhamentos(pr_idcomissao IN tbepr_cdc_parm_comissao.idcomissao %TYPE --> Código da Comissão
                                   ,pr_xmllog     IN VARCHAR2                                 --> XML com informações de LOG
                                   ,pr_cdcritic   OUT PLS_INTEGER                             --> Código da crítica
                                   ,pr_dscritic   OUT VARCHAR2                                --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                                   ,pr_nmdcampo   OUT VARCHAR2                                --> Nome do Campo
                                   ,pr_des_erro   OUT VARCHAR2) IS                            --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_listar_detalhamentos
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Diego Simas
    Data    : Abril/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para listar detalhamentos da comissão.

    Alteracoes:
    ............................................................................. */

    -- CURSORES --

    CURSOR cr_comissao_regra(pr_idcomissao tbepr_cdc_parm_comissao_regra.idcomissao%TYPE)IS
      SELECT c.idregra faixa
            ,c.vlinicial vlinicial
            ,c.vlfinal vlfinal
            ,c.vlcomissao vlcomiss
        FROM tbepr_cdc_parm_comissao_regra c
       WHERE c.idcomissao = pr_idcomissao;
    rw_comissao_regra cr_comissao_regra%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    --Variáveis auxiliares
    vr_clobxml   CLOB;
    vr_contadet INTEGER := 0;

    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN

    -- Informacoes de cabecalho de pacote
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'detalhamentos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_comissao_regra IN cr_comissao_regra(pr_idcomissao => pr_idcomissao) LOOP
      -- Informacoes de cabecalho de pacote
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhamentos', pr_posicao => 0, pr_tag_nova => 'detalhe', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',  pr_posicao => vr_contadet, pr_tag_nova => 'faixa', pr_tag_cont => TO_CHAR(rw_comissao_regra.faixa), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',  pr_posicao => vr_contadet, pr_tag_nova => 'vlinicial', pr_tag_cont => TO_CHAR(rw_comissao_regra.vlinicial), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',  pr_posicao => vr_contadet, pr_tag_nova => 'vlfinal', pr_tag_cont => TO_CHAR(rw_comissao_regra.vlfinal), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe',  pr_posicao => vr_contadet, pr_tag_nova => 'vlcomiss', pr_tag_cont => TO_CHAR(rw_comissao_regra.vlcomiss), pr_des_erro => vr_dscritic);
      vr_contadet := vr_contadet + 1;
    END LOOP;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PARCDC.PC_LISTAR_DETALHAMENTOS --> ' || SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

  END pc_listar_detalhamentos;

  -- Rotina para consultar sequencia detalhamento CDC
  PROCEDURE pc_consulta_seq_detalhamento(pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2) IS                        --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_consulta_seq_detalhamento
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Diego Simas
    Data    : Abril/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar sequencia detalhamento CDC.

    Alteracoes:
    ............................................................................. */

    -- CURSORES --

    CURSOR cr_consulta_seq_com_regra IS
      SELECT (MAX(comregra.idregra) + 1) sequencia
        FROM tbepr_cdc_parm_comissao_regra comregra;
    rw_consulta_seq_com_regra cr_consulta_seq_com_regra%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    --Variáveis auxiliares
    vr_clobxml   CLOB;

    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN

    -- Cabecalho mensageria
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    -- Informacoes retorno da mensageria
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    OPEN cr_consulta_seq_com_regra;
    FETCH cr_consulta_seq_com_regra INTO rw_consulta_seq_com_regra;
    IF cr_consulta_seq_com_regra%NOTFOUND THEN
      CLOSE cr_consulta_seq_com_regra;
      vr_dscritic := 'Sequencia de detalhamento da regra nao encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_consulta_seq_com_regra;
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdseqdetalhe', pr_tag_cont => TO_CHAR(rw_consulta_seq_com_regra.sequencia), pr_des_erro => vr_dscritic);
    END IF;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PARCDC.PC_CONSULTA_SEQ_COMISSAO --> ' || SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

  END pc_consulta_seq_detalhamento;

  -- Rotina para manter o detalhamento PARCDC
  PROCEDURE pc_manter_detalhamento(pr_cddopdet    IN VARCHAR2                                       --> Opção do detalhamento
                                  ,pr_cdfaixa     IN tbepr_cdc_parm_comissao_regra.idregra %TYPE    --> Código da regra
                                  ,pr_idcomissao  IN tbepr_cdc_parm_comissao_regra.idcomissao %TYPE --> Código da Comissão
                                  ,pr_vlinicial   IN tbepr_cdc_parm_comissao_regra.vlinicial %TYPE  --> Valor inicial
                                  ,pr_vlfinal     IN tbepr_cdc_parm_comissao_regra.vlfinal %TYPE    --> Valor final
                                  ,pr_vlcomiss    IN tbepr_cdc_parm_comissao_regra.vlcomissao %TYPE --> Valor comissão
                                  ,pr_xmllog      IN VARCHAR2                                       --> XML com informações de LOG
                                  ,pr_cdcritic    OUT PLS_INTEGER                                   --> Código da crítica
                                  ,pr_dscritic    OUT VARCHAR2                                      --> Descrição da crítica
                                  ,pr_retxml      IN OUT NOCOPY xmltype                             --> Arquivo de retorno do XML
                                  ,pr_nmdcampo    OUT VARCHAR2                                      --> Nome do Campo
                                  ,pr_des_erro    OUT VARCHAR2) IS                                  --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_manter_detalhamento
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Diego Simas
    Data    : Abril/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para manter detalhamento PARCDC.

    Alteracoes:
    ............................................................................. */

    -- CURSORES --

    CURSOR cr_comissao_regra(pr_idregra tbepr_cdc_parm_comissao_regra.idregra%TYPE)IS
      SELECT c.idregra
        FROM tbepr_cdc_parm_comissao_regra c
       WHERE c.idregra = pr_idregra;
    rw_comissao_regra cr_comissao_regra%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_iddetcor INTEGER;

    --Variáveis auxiliares
    vr_clobxml   CLOB;

    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN

    IF UPPER(pr_cddopdet) = 'I' THEN
      -- inclui detalhe da regra
      BEGIN
        INSERT INTO tbepr_cdc_parm_comissao_regra(idregra
                                                 ,idcomissao
                                                 ,vlinicial
                                                 ,vlfinal
                                                 ,vlcomissao)
             VALUES(null
                   ,pr_idcomissao
                   ,pr_vlinicial
                   ,pr_vlfinal
                   ,pr_vlcomiss);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          vr_dscritic := 'Esta regra ja esta cadastrada no sistema.';
          RAISE vr_exc_erro;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir registro de detalhamento na tabela de regras CDC. Erro: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      SELECT SEQ_TBEPR_CDC_PARM_COMISSAO_RG.CURRVAL
        INTO vr_iddetcor
        FROM DUAL;

      -- Cabecalho mensageria
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      -- Informacoes retorno da mensageria
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'iddetcor', pr_tag_cont => TO_CHAR(vr_iddetcor), pr_des_erro => vr_dscritic);


    ELSIF UPPER(pr_cddopdet) = 'A' THEN
      -- altera detalhe da regra
      BEGIN
        UPDATE tbepr_cdc_parm_comissao_regra t
          SET t.vlinicial    = pr_vlinicial
             ,t.vlfinal      = pr_vlfinal
             ,t.vlcomissao   = pr_vlcomiss
          WHERE t.idregra    = pr_cdfaixa
            AND t.idcomissao = pr_idcomissao;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar os detalhes da regra CDC. Erro: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    ELSIF UPPER(pr_cddopdet) = 'E' THEN
      OPEN cr_comissao_regra(pr_idregra => pr_cdfaixa);
      FETCH cr_comissao_regra INTO rw_comissao_regra;

      IF cr_comissao_regra%FOUND THEN
        CLOSE cr_comissao_regra;
        BEGIN
          DELETE tbepr_cdc_parm_comissao_regra
           WHERE tbepr_cdc_parm_comissao_regra.idregra = pr_cdfaixa;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro de regra PARCDC. Erro: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      ELSE
        CLOSE cr_comissao_regra;
        vr_dscritic := 'Regra inexistente.';
        RAISE vr_exc_erro;
      END IF;

    END IF;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PARCDC.PC_MANTER_DETALHAMENTO --> ' || SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');

  END pc_manter_detalhamento;

END TELA_PARCDC;
/
