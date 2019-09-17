CREATE OR REPLACE PACKAGE CECRED.TELA_LOGSPB AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_LOGSPB
  --    Autor   : Marcelo Telles Coelho - Mouts
  --    Data    : Outubro/2018                      Ultima Atualizacao:   /  /
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Atender as necessidades da tela LOGSPB
  --                Construido para o Projeto 475
  --
  --    Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  PROCEDURE pc_buscar_filtros(pr_xmllog    IN     VARCHAR2            --> XML com informações de LOG
                             ,pr_cdcritic     OUT PLS_INTEGER         --> Código da crítica
                             ,pr_dscritic     OUT VARCHAR2            --> Descrição da crítica
                             ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                             ,pr_nmdcampo     OUT VARCHAR2            --> Nome do campo com erro
                             ,pr_des_erro     OUT VARCHAR2);          --> Erros do processo

  PROCEDURE pc_buscar_mensagens(pr_opcao           IN VARCHAR2
                               ,pr_dtmensagem_de   IN VARCHAR2
                               ,pr_dtmensagem_ate  IN VARCHAR2
                               ,pr_vlmensagem_de   IN VARCHAR2
                               ,pr_vlmensagem_ate  IN VARCHAR2
                               ,pr_nrdconta        IN VARCHAR2
                               ,pr_inorigem        IN VARCHAR2
                               ,pr_intipo          IN VARCHAR2
                               ,pr_cdcooper        IN VARCHAR2
                               ,pr_dsendere        IN VARCHAR2                               --> Endereço de e-mail para envio do CSV
                               ,pr_nrispbif        IN VARCHAR2
                               ,pr_nrregist        IN INTEGER                                --> Quantidade de registros
                               ,pr_nriniseq        IN INTEGER                                --> Qunatidade inicial
                               ,pr_xmllog          IN VARCHAR2                               --> XML com informações de LOG
                               ,pr_cdcritic       OUT PLS_INTEGER                            --> Código da crítica
                               ,pr_dscritic       OUT VARCHAR2                               --> Descrição da crítica
                               ,pr_retxml      IN OUT NOCOPY xmltype                         --> Arquivo de retorno do XML
                               ,pr_nmdcampo       OUT VARCHAR2                               --> Nome do Campo
                               ,pr_des_erro       OUT VARCHAR2);                             --> Saida OK/NOK

  PROCEDURE pc_buscar_mensagens_opcao_c_m(pr_opcao           IN VARCHAR2
                                         ,pr_dtmensagem_de   IN VARCHAR2
                                         ,pr_dtmensagem_ate  IN VARCHAR2
                                         ,pr_vlmensagem_de   IN VARCHAR2
                                         ,pr_vlmensagem_ate  IN VARCHAR2
                                         ,pr_nrdconta        IN VARCHAR2
                                         ,pr_inorigem        IN VARCHAR2
                                         ,pr_intipo          IN VARCHAR2
                                         ,pr_cdcooper        IN VARCHAR2
                                         ,pr_dsendere        IN VARCHAR2                               --> Endereço de e-mail para envio do CSV
                                         ,pr_nrispbif        IN VARCHAR2
                                         ,pr_nrregist        IN INTEGER                                --> Quantidade de registros
                                         ,pr_nriniseq        IN INTEGER                                --> Qunatidade inicial
                                         ,pr_xmllog          IN VARCHAR2                               --> XML com informações de LOG
                                         ,pr_cdcritic       OUT PLS_INTEGER                            --> Código da crítica
                                         ,pr_dscritic       OUT VARCHAR2                               --> Descrição da crítica
                                         ,pr_retxml      IN OUT NOCOPY xmltype                         --> Arquivo de retorno do XML
                                         ,pr_nmdcampo       OUT VARCHAR2                               --> Nome do Campo
                                         ,pr_des_erro       OUT VARCHAR2);                             --> Saida OK/NOK

  PROCEDURE pc_buscar_mensagens_opcao_s(pr_opcao           IN VARCHAR2
                                       ,pr_dtmensagem_de   IN VARCHAR2
                                       ,pr_dtmensagem_ate  IN VARCHAR2
                                       ,pr_vlmensagem_de   IN VARCHAR2
                                       ,pr_vlmensagem_ate  IN VARCHAR2
                                       ,pr_nrdconta        IN VARCHAR2
                                       ,pr_inorigem        IN VARCHAR2
                                       ,pr_intipo          IN VARCHAR2
                                       ,pr_cdcooper        IN VARCHAR2
                                       ,pr_nrispbif        IN VARCHAR2
                                       ,pr_nrregist        IN INTEGER                                --> Quantidade de registros
                                       ,pr_nriniseq        IN INTEGER                                --> Qunatidade inicial
                                       ,pr_xmllog          IN VARCHAR2                               --> XML com informações de LOG
                                       ,pr_cdcritic       OUT PLS_INTEGER                            --> Código da crítica
                                       ,pr_dscritic       OUT VARCHAR2                               --> Descrição da crítica
                                       ,pr_retxml      IN OUT NOCOPY xmltype                         --> Arquivo de retorno do XML
                                       ,pr_nmdcampo       OUT VARCHAR2                               --> Nome do Campo
                                       ,pr_des_erro       OUT VARCHAR2);                             --> Saida OK/NOK

  PROCEDURE pc_buscar_detalhe_msg(pr_nrseq_mensagem  IN NUMBER
                                 ,pr_idorigem        IN VARCHAR2                               --> E=Enviada, R=Recebida
                                 ,pr_xmllog          IN VARCHAR2                               --> XML com informações de LOG
                                 ,pr_cdcritic       OUT PLS_INTEGER                            --> Código da crítica
                                 ,pr_dscritic       OUT VARCHAR2                               --> Descrição da crítica
                                 ,pr_retxml      IN OUT NOCOPY xmltype                         --> Arquivo de retorno do XML
                                 ,pr_nmdcampo       OUT VARCHAR2                               --> Nome do Campo
                                 ,pr_des_erro       OUT VARCHAR2);                             --> Saida OK/NOK

  FUNCTION fn_seleciona_valor (pr_vlmensagem_de  IN NUMBER
                              ,pr_vlmensagem_ate IN NUMBER
                              ,pr_VlrLanc        IN NUMBER)
                               RETURN VARCHAR2;

  FUNCTION fn_define_situacao_enviada (pr_nrseq_mensagem IN NUMBER)
                                       RETURN VARCHAR2;

  FUNCTION fn_define_situacao_recebida (pr_nrseq_mensagem IN NUMBER
                                       ,pr_nrcontrole IN VARCHAR2
                                       ,pr_nmmensagem IN VARCHAR2)
                                        RETURN VARCHAR2;

  FUNCTION fn_define_origem (pr_nrcontrole_if  IN VARCHAR2
                            ,pr_in_ds          IN VARCHAR2
                            ,pr_cdfase         IN NUMBER)
                             RETURN VARCHAR2;

  FUNCTION fn_define_cnpj_cpf_debito (pr_dsxml_completo IN CLOB)
                                     RETURN VARCHAR2;

  FUNCTION fn_define_nome_debito (pr_dsxml_completo IN CLOB)
                                  RETURN VARCHAR2;

  FUNCTION fn_define_cnpj_cpf_credito (pr_dsxml_completo IN CLOB)
                                       RETURN VARCHAR2;

  FUNCTION fn_define_nome_credito (pr_dsxml_completo IN CLOB)
                                   RETURN VARCHAR2;

END TELA_LOGSPB;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_LOGSPB AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_LOGSPB
  --    Autor   : Marcelo Telles Coelho - Mouts
  --    Data    : Outubro/2018                      Ultima Atualizacao:   /  /
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Atender as necessidades da tela LOGSPB
  --                Construido para o Projeto 475
  --
  --    Alteracoes:
  --                11-06-2019 - Inclusão de uma coluna nos detalhes das mensagens (Fases).
  --                             Jose Dill - Mouts (P475 - REQ66)
  --
  --				06-09-2019 - Remoção da máscara padrão de contas Ailos para apresentar contas de destino, utilizado máscara única.
  --							 Diógenes Lazzarini - PRB0041598
  --
  ---------------------------------------------------------------------------------------------------------------

  CURSOR cr_crapcop (pr_cdcooper IN NUMBER) IS
    SELECT nmrescop
      FROM crapcop
     WHERE cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  TYPE typ_tab_crapcop IS TABLE OF cr_crapcop%ROWTYPE
       INDEX BY pls_integer;
  vr_tab_crapcop typ_tab_crapcop;

  CURSOR cr_crapban (pr_nrispbif IN NUMBER) IS
    SELECT nrispbif||'-'||UPPER(nmresbcc) nmresbcc
      FROM crapban
     WHERE nrispbif = pr_nrispbif
     and   cdbccxlt not in (911,909,908,903,902,900,800,700,631,500,497,466,400,9)
    UNION
    SELECT nrispbif||'-'||UPPER(nmresbcc) nmresbcc
      FROM crapban A
     WHERE nrispbif = pr_nrispbif
     and   cdbccxlt = 1;
  rw_crapban cr_crapban%ROWTYPE;

  TYPE typ_tab_crapban IS TABLE OF cr_crapban%ROWTYPE
       INDEX BY pls_integer;
  vr_tab_crapban typ_tab_crapban;

  CURSOR cr_craptvl (pr_cdcooper      IN NUMBER
                    ,pr_nrcontrole_if IN VARCHAR2) IS
    SELECT cdoperad
          ,cdbccxlt
      FROM craptvl
     WHERE cdcooper = pr_cdcooper
       AND tpdoctrf = 3
       AND UPPER(idopetrf) = pr_nrcontrole_if;
  rw_craptvl cr_craptvl%ROWTYPE;

  vr_dtmensagem_de    DATE;
  vr_dtmensagem_ate   DATE;
  vr_nmrescop         VARCHAR2(100);
  vr_nmrescop_migrada VARCHAR2(100);
  vr_bancoremet       VARCHAR2(100);
  vr_bancodest        VARCHAR2(100);

  -- Variaveis retornadas da gene0004.pc_extrai_dados
  vr_cdcooper      INTEGER;
  vr_cdoperad      VARCHAR2(100);
  vr_nmdatela      VARCHAR2(100);
  vr_nmeacao       VARCHAR2(100);
  vr_cdagenci      VARCHAR2(100);
  vr_nrdcaixa      VARCHAR2(100);
  vr_idorigem      VARCHAR2(100);

  vr_xml_temp      VARCHAR2(32726) := '';
  vr_clob          CLOB;
  vr_varchar2      VARCHAR2(32726) := '';

  -- Variável de críticas
  vr_cdcritic      crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(32000);

  FUNCTION fn_seleciona_valor (pr_vlmensagem_de  IN NUMBER
                              ,pr_vlmensagem_ate IN NUMBER
                              ,pr_VlrLanc        IN NUMBER)
                              RETURN VARCHAR2 IS
    vr_retorno VARCHAR2(10) := 'NAO';
  BEGIN
    IF pr_vlmensagem_ate IS NULL
    AND pr_vlmensagem_de IS NULL
    THEN
      vr_retorno := 'SIM';
    ELSIF pr_vlmensagem_ate IS NULL
       AND pr_vlmensagem_de IS NOT NULL
    THEN
      IF pr_VlrLanc = pr_vlmensagem_de THEN
        vr_retorno := 'SIM';
      END IF;
    ELSIF pr_vlmensagem_ate IS NOT NULL
       AND pr_vlmensagem_de IS NULL
    THEN
      IF pr_VlrLanc <= pr_vlmensagem_ate THEN
        vr_retorno := 'SIM';
      END IF;
    ELSIF pr_vlmensagem_ate IS NOT NULL
       AND pr_vlmensagem_de IS NOT NULL
    THEN
      IF pr_VlrLanc BETWEEN pr_vlmensagem_de AND pr_vlmensagem_ate THEN
        vr_retorno := 'SIM';
      END IF;
    END IF;
    RETURN(vr_retorno);
  END fn_seleciona_valor;

  FUNCTION fn_define_situacao_enviada (pr_nrseq_mensagem IN NUMBER)
                                       RETURN VARCHAR2 IS
    vr_return     VARCHAR2(100);
    vr_nmmensagem VARCHAR2(100);
    vr_fase_20    NUMBER;
    vr_fase_40    NUMBER;
    vr_fase_43    NUMBER;
    vr_fase_55    NUMBER;
    vr_fase_57    NUMBER;
    vr_fase_56    NUMBER;
    vr_fase_60    NUMBER;
  BEGIN
    vr_fase_20 := 0;
    vr_fase_40 := 0;
    vr_fase_43 := 0;
    vr_fase_55 := 0;
    vr_fase_57 := 0;
    vr_fase_56 := 0;
    vr_fase_60 := 0;
    FOR r1 IN (SELECT *
                 FROM tbspb_msg_enviada_fase
                WHERE nrseq_mensagem = pr_nrseq_mensagem order by cdfase)
    LOOP
      IF r1.cdfase = 20 THEN
        vr_fase_20 := 1;
      ElSIF r1.cdfase = 40 THEN
        vr_fase_40 := 1;
      ElSIF r1.cdfase = 43 THEN
        vr_fase_43 := 1;
      ElSIF r1.cdfase = 55 THEN
        vr_fase_55 := 1;
      ElSIF r1.cdfase = 56 THEN
        vr_fase_56 := 1;
      ElSIF r1.cdfase = 57 THEN
        vr_fase_57 := 1;
      ElSIF r1.cdfase = 60 THEN
        vr_fase_60 := 1;
      END IF;
      vr_nmmensagem := r1.nmmensagem;
    END LOOP;
    IF vr_fase_55 = 1 AND vr_fase_60 = 0 THEN
      vr_return := 'EFETIVADA';
    ELSIF vr_fase_57 = 1 AND vr_fase_60 = 0 THEN
      vr_return := 'EFETIVADA'; 
    ELSIF vr_fase_55 = 1 AND vr_fase_60 = 1 THEN
      vr_return := 'DEVOLVIDA';
    ELSIF vr_fase_20 = 1 AND vr_nmmensagem = 'Reprovada pelo OFSAA' THEN
      vr_return := 'ESTORNADA';
    ELSIF vr_fase_43 = 1 OR (vr_fase_40 = 1 AND vr_nmmensagem = 'Retorno JD Rejeição') THEN
      vr_return := 'REJEITADA';
    ELSIF vr_fase_56 = 1 AND vr_fase_55 = 0 and vr_fase_57 = 0 THEN
      vr_return := 'PENDENTE CAMARA';
    ELSIF vr_fase_40 = 0 AND vr_fase_43 = 0 THEN
      IF (vr_fase_20 = 1 AND vr_nmmensagem <> 'Reprovada pelo OFSAA')
      OR (vr_fase_20 = 0) THEN
        vr_return := 'EM PROCESSAMENTO';
      END IF;
    ELSIF (vr_fase_40 = 1 AND vr_nmmensagem <> 'Retorno JD Rejeição' AND vr_fase_55 = 0 AND vr_fase_56 = 0 AND vr_fase_57 = 0)
      OR (vr_fase_40 = 1 AND vr_nmmensagem = 'Retorno JD') THEN
        vr_return := 'EM PROCESSAMENTO';
      END IF;

    RETURN(vr_return);
  END fn_define_situacao_enviada;

  FUNCTION fn_define_situacao_recebida (pr_nrseq_mensagem IN NUMBER
                                       ,pr_nrcontrole IN VARCHAR2
                                       ,pr_nmmensagem IN VARCHAR2 )
                                        RETURN VARCHAR2 IS
    vr_return     VARCHAR2(100);
    vr_fase_120   NUMBER;
    vr_fase_55    NUMBER;
  BEGIN
    vr_fase_120 := 0;
    vr_fase_55 :=0;
    FOR r1 IN (SELECT *
                 FROM tbspb_msg_recebida_fase
                WHERE nrseq_mensagem = pr_nrseq_mensagem
                  AND cdfase         = 120)
    LOOP
      IF r1.cdfase = 120 THEN
        vr_fase_120 := 1;
      END IF;
    END LOOP;
    --
    IF vr_fase_120 = 1 THEN
      /* Verifica se houve a confirmação da mensagem enviada (Fase 55)*/
      select count(*) into vr_fase_55
      from tbspb_msg_enviada a,
           tbspb_msg_enviada_fase b
      where a.nrseq_mensagem = b.nrseq_mensagem
      and   a.nrcontrole_str_pag_rec = pr_nrcontrole
      and   b.cdfase = 55;
      --
      IF vr_fase_55 = 1 THEN
         vr_return := 'DEVOLVIDA';
      ELSE
         vr_return := 'EM DEVOLUÇÃO';
      END IF;      
    ELSE
      vr_return := 'EFETIVADA';
    END IF;
    RETURN(vr_return);
  END fn_define_situacao_recebida;

  FUNCTION fn_define_origem (pr_nrcontrole_if  IN VARCHAR2
                            ,pr_in_ds          IN VARCHAR2
                            ,pr_cdfase         IN NUMBER)
                            RETURN VARCHAR2 IS
    vr_intexto  VARCHAR2(100);
    vr_inorigem VARCHAR2(100);
    vr_dsorigem VARCHAR2(100);

  BEGIN
    vr_intexto := SUBSTR(pr_nrcontrole_if,LENGTH(pr_nrcontrole_if),1);
    IF pr_cdfase = 15 THEN
      vr_inorigem := 'J';
      vr_dsorigem := 'Cabine JD';
    ELSIF vr_intexto = 'C' THEN
      vr_inorigem := 'C';
      vr_dsorigem := 'Caixa Online';
    ElSIF vr_intexto = 'I' THEN
      vr_inorigem := 'I';
      vr_dsorigem := 'Internet';
    ElSIF vr_intexto = 'M' THEN
      vr_inorigem := 'M';
      vr_dsorigem := 'Mobile';
    ElSIF vr_intexto = 'A' THEN
      vr_inorigem := 'A';
      vr_dsorigem := 'Aimaro';
    ElSIF vr_intexto = 'P' THEN
      vr_inorigem := 'P';
      vr_dsorigem := 'Protesto';
    END IF;
    --
    IF pr_in_ds = 'IN' THEN
      RETURN(vr_inorigem);
    ELSE
      RETURN(vr_dsorigem);
    END IF;
  END fn_define_origem;

  FUNCTION fn_define_cnpj_cpf_debito (pr_dsxml_completo IN CLOB)
                                     RETURN VARCHAR2 IS
    vr_nrcnpjdb VARCHAR2(100);
    vr_inpessoa NUMBER;
  BEGIN
    vr_nrcnpjdb := sspb0003.fn_busca_conteudo_campo(pr_dsxml_completo,'CNPJ_CPFRemet','S'); -- CNPJ_CPFRemet
    IF vr_nrcnpjdb IS NULL THEN
      vr_nrcnpjdb := sspb0003.fn_busca_conteudo_campo(pr_dsxml_completo,'CNPJ_CPFCliDebtd','S'); -- CNPJ_CPFCliDebtd
    END IF;
    IF vr_nrcnpjdb IS NULL THEN
      vr_nrcnpjdb := sspb0003.fn_busca_conteudo_campo(pr_dsxml_completo,'CNPJ_CPFCliDebtd_Remet','S'); -- CNPJ_CPFCliDebtd_Remet
    END IF;
    IF vr_nrcnpjdb IS NULL THEN
      vr_nrcnpjdb := sspb0003.fn_busca_conteudo_campo(pr_dsxml_completo,'CPFCliDebtd','S'); -- CPFCliDebtd
    END IF;
    IF vr_nrcnpjdb IS NULL THEN
      vr_nrcnpjdb := sspb0003.fn_busca_conteudo_campo(pr_dsxml_completo,'CNPJ_CPFSacd','S'); -- CNPJ_CPFSacd
    END IF;
    IF vr_nrcnpjdb IS NOT NULL THEN
      IF LENGTH(to_number(vr_nrcnpjdb)) < 12 THEN
         vr_inpessoa := 1;
      ELSE
         vr_inpessoa := 2;  
      END IF;
      --
      vr_nrcnpjdb := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_nrcnpjdb
                                              ,pr_inpessoa => vr_inpessoa);
    END IF;
    --
    RETURN(vr_nrcnpjdb);
  END fn_define_cnpj_cpf_debito;

  FUNCTION fn_define_nome_debito (pr_dsxml_completo IN CLOB)
                                 RETURN VARCHAR2 IS
    vr_nmcliedb VARCHAR2(100);
  BEGIN
    vr_nmcliedb := sspb0003.fn_busca_conteudo_campo(pr_dsxml_completo,'NomRemet','S'); -- NomRemet
    IF vr_nmcliedb IS NULL THEN
      vr_nmcliedb := sspb0003.fn_busca_conteudo_campo(pr_dsxml_completo,'NomCliDebtd','S'); -- NomCliDebtd
    END IF;
    IF vr_nmcliedb IS NULL THEN
      vr_nmcliedb := sspb0003.fn_busca_conteudo_campo(pr_dsxml_completo,'NomCliDebtd_Remet','S'); -- NomCliDebtd_Remet
    END IF;
    --
    RETURN(Upper(vr_nmcliedb));
  END fn_define_nome_debito;

  FUNCTION fn_define_cnpj_cpf_credito (pr_dsxml_completo IN CLOB)
                                       RETURN VARCHAR2 IS
    vr_nrcnpjcr VARCHAR2(100);
    vr_inpessoa NUMBER;
  BEGIN
    vr_nrcnpjcr := sspb0003.fn_busca_conteudo_campo(pr_dsxml_completo,'CNPJ_CPFCliCredtd','S'); -- CNPJ_CPFCliCredtd
    IF vr_nrcnpjcr IS NULL THEN
      vr_nrcnpjcr:= sspb0003.fn_busca_conteudo_campo(pr_dsxml_completo,'CNPJ_CPFDestinatario','S'); -- CNPJ_CPFDestinatario
    END IF;
    IF vr_nrcnpjcr IS NULL THEN
      vr_nrcnpjcr:= sspb0003.fn_busca_conteudo_campo(pr_dsxml_completo,'CNPJ_CPFCed','S'); -- CNPJ_CPFCed
    END IF;
    IF vr_nrcnpjcr IS NOT NULL THEN
      IF LENGTH(to_number(vr_nrcnpjcr)) < 12 THEN
        vr_inpessoa := 1;
      ELSE
        vr_inpessoa := 2;  
      END IF;
      --
      vr_nrcnpjcr := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_nrcnpjcr
                                              ,pr_inpessoa => vr_inpessoa);
    END IF;
    --
    RETURN(vr_nrcnpjcr);
  END fn_define_cnpj_cpf_credito;

  FUNCTION fn_define_nome_credito (pr_dsxml_completo IN CLOB)
                                   RETURN VARCHAR2 IS
    vr_nmcliecr VARCHAR2(100);
  BEGIN
    vr_nmcliecr := sspb0003.fn_busca_conteudo_campo(pr_dsxml_completo,'NomCliCredtd','S'); -- NomCliCredtd
    IF vr_nmcliecr IS NULL THEN
      vr_nmcliecr := sspb0003.fn_busca_conteudo_campo(pr_dsxml_completo,'NomDestinatario','S'); -- NomDestinatario
    END IF;
    --
    RETURN(Upper(vr_nmcliecr));
  END fn_define_nome_credito;

  FUNCTION fn_busca_devolucao (pr_nrcontrole IN VARCHAR2
                               ,pr_intipo IN VARCHAR2)
                                   RETURN VARCHAR2 IS
    vr_aux_CodDevTransf  VARCHAR2(100):= NULL;
    vr_dsdevolucao       craptab.dstextab%TYPE:= NULL;
  BEGIN
    IF pr_intipo = 'R' THEN
      -- Busca o motivo da devolução de recebimento
      FOR rdev IN (Select sspb0003.fn_busca_conteudo_campo(c.dsxml_completo,'CodDevTransf','S') CodDevTransf
                From tbspb_msg_enviada a
                     ,tbspb_msg_enviada_fase b
                     ,tbspb_msg_xml c
                Where a.nrcontrole_str_pag_rec = pr_nrcontrole
                and   a.nrseq_mensagem = b.nrseq_mensagem
                and   b.cdfase in (10,15)
                and   b.nrseq_mensagem_xml = c.nrseq_mensagem_xml)
      LOOP
        vr_aux_CodDevTransf := rdev.coddevtransf;
      END LOOP;
      --
      If vr_aux_CodDevTransf is not null then
         vr_dsdevolucao:= tabe0001.fn_busca_dstextab(pr_cdcooper => 0
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'GENERI'
                                                   ,pr_cdempres => 0
                                                   ,pr_cdacesso => 'CDERROSSPB'
                                                   ,pr_tpregist => vr_aux_CodDevTransf);
         vr_dsdevolucao := substr(vr_dsdevolucao,1,44);
      End If;
    ELSE
      -- Busca o motivo da devolução da enviada
      FOR rdev IN (Select sspb0003.fn_busca_conteudo_campo(c.dsxml_completo,'CodDevTransf','S') CodDevTransf
                From tbspb_msg_recebida a
                     ,tbspb_msg_recebida_fase b
                     ,tbspb_msg_xml c
                Where a.nrcontrole_if_env = pr_nrcontrole
                and   a.nrseq_mensagem = b.nrseq_mensagem
                and   b.cdfase = 115
                and   b.nrseq_mensagem_xml = c.nrseq_mensagem_xml)
      LOOP
        vr_aux_CodDevTransf := rdev.coddevtransf;
      END LOOP;
      --
      If vr_aux_CodDevTransf is not null then
         vr_dsdevolucao:= tabe0001.fn_busca_dstextab(pr_cdcooper => 0
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'GENERI'
                                                   ,pr_cdempres => 0
                                                   ,pr_cdacesso => 'CDERROSSPB'
                                                   ,pr_tpregist => vr_aux_CodDevTransf);
         vr_dsdevolucao := substr(vr_dsdevolucao,1,44);
      End If;
    END IF;  
    --
    RETURN (vr_dsdevolucao);
  END fn_busca_devolucao;

  -- Busca dados para popular combos de filtragem tela concip
  PROCEDURE pc_buscar_filtros(pr_xmllog    IN     VARCHAR2            --> XML com informações de LOG
                             ,pr_cdcritic     OUT PLS_INTEGER         --> Código da crítica
                             ,pr_dscritic     OUT VARCHAR2            --> Descrição da crítica
                             ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                             ,pr_nmdcampo     OUT VARCHAR2            --> Nome do campo com erro
                             ,pr_des_erro     OUT VARCHAR2) IS        --> Erros do processo

    vr_cdcooper_prm NUMBER;
    vr_contador     NUMBER;

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;

    -- Consulta cooperativas
    CURSOR cr_busca_coop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT 0       cdcooper
            ,'TODAS' nmrescop
        FROM dual
       WHERE pr_cdcooper IS NULL
      UNION
      SELECT a.cdcooper
            ,a.nmrescop
        FROM crapcop a
       WHERE a.cdcooper = NVL(pr_cdcooper,a.cdcooper)
       ORDER BY 1;

    -- Consulta Bancos
    CURSOR cr_busca_IfContraparte IS
      SELECT NULL        nrispbif
            ,' TODOS' dsispbif
            ,' TODOS'    nmresbcc
        FROM DUAL
      UNION
      SELECT a.nrispbif
            ,lpad(a.nrispbif,8,'0')||' - '||UPPER(a.nmresbcc) dsispbif
            ,a.nmresbcc
        FROM crapban a
       WHERE a.cdbccxlt = 1
       UNION
      SELECT a.nrispbif
            ,lpad(a.nrispbif,8,'0')||' - '||UPPER(a.nmresbcc) dsispbif
            ,a.nmresbcc
        FROM crapban a
       WHERE a.nrispbif > 0
       ORDER BY nmresbcc;

  BEGIN -- Inicio pc_buscar_filtros
    gene0001.pc_informa_acesso(pr_module => 'SSPBMSG'
                              ,pr_action => NULL);

    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      vr_cdcooper := 3;
    END IF;
    --
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    --
    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'cooperativas'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);
    SELECT DECODE(vr_cdcooper,3,NULL,vr_cdcooper)
      INTO vr_cdcooper_prm
      FROM DUAL;
    --
    vr_contador := 0;
    --
    FOR rw_busca_coop IN cr_busca_coop(pr_cdcooper => vr_cdcooper_prm) LOOP
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'cooperativas',pr_posicao => 0  , pr_tag_nova => 'item'  , pr_tag_cont => NULL                            , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador, pr_tag_nova => 'codigo', pr_tag_cont => TRIM(rw_busca_coop.cdcooper), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador, pr_tag_nova => 'nome'  , pr_tag_cont => TRIM(rw_busca_coop.nmrescop), pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    END LOOP;
    --
    IF vr_contador > 0 THEN
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'cooperativas'      --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_contador         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
    END IF;
    --
    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'IfContraparte'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);
    --
    vr_contador := 0;
    --
    FOR rw_busca_IfContraparte IN cr_busca_IfContraparte LOOP
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'IfContraparte',pr_posicao => 0  , pr_tag_nova => 'item1'   , pr_tag_cont => NULL                            , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador, pr_tag_nova => 'nrispbif', pr_tag_cont => TRIM(rw_busca_IfContraparte.nrispbif), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador, pr_tag_nova => 'dsispbif', pr_tag_cont => TRIM(rw_busca_IfContraparte.dsispbif), pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    END LOOP;
    --
    IF vr_contador > 0 THEN
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'IfContraparte'     --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_contador         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
    END IF;
    --
    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tipo'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);
    --
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'tipo' ,pr_posicao => 0, pr_tag_nova => 'item2' , pr_tag_cont => NULL   , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item2',pr_posicao => 0, pr_tag_nova => 'intipo', pr_tag_cont => 'T'    , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item2',pr_posicao => 0, pr_tag_nova => 'dstipo', pr_tag_cont => 'TODAS', pr_des_erro => vr_dscritic);
    --
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'tipo' ,pr_posicao => 0, pr_tag_nova => 'item2' , pr_tag_cont => NULL      , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item2',pr_posicao => 1, pr_tag_nova => 'intipo', pr_tag_cont => 'E'       , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item2',pr_posicao => 1, pr_tag_nova => 'dstipo', pr_tag_cont => 'ENVIADAS', pr_des_erro => vr_dscritic);
    --
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'tipo' ,pr_posicao => 0, pr_tag_nova => 'item2' , pr_tag_cont => NULL       , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item2',pr_posicao => 2, pr_tag_nova => 'intipo', pr_tag_cont => 'R'        , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item2',pr_posicao => 2, pr_tag_nova => 'dstipo', pr_tag_cont => 'RECEBIDAS', pr_des_erro => vr_dscritic);
    --
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml        --> XML que irá receber o novo atributo
                             ,pr_tag   => 'tipo'           --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'       --> Nome do atributo
                             ,pr_atval => 3                --> Valor do atributo
                             ,pr_numva => 0                --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic); --> Descrição de erros
    --
    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'origem'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);
    --
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'origem',pr_posicao => 0, pr_tag_nova => 'item3'   , pr_tag_cont => NULL          , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item3' ,pr_posicao => 0, pr_tag_nova => 'inorigem', pr_tag_cont => 'C'           , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item3' ,pr_posicao => 0, pr_tag_nova => 'dsorigem', pr_tag_cont => 'CAIXA ONLINE', pr_des_erro => vr_dscritic);
    --
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'origem',pr_posicao => 0, pr_tag_nova => 'item3'   , pr_tag_cont => NULL      , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item3' ,pr_posicao => 1, pr_tag_nova => 'inorigem', pr_tag_cont => 'I'       , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item3' ,pr_posicao => 1, pr_tag_nova => 'dsorigem', pr_tag_cont => 'INTERNET', pr_des_erro => vr_dscritic);
    --
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'origem',pr_posicao => 0, pr_tag_nova => 'item3'   , pr_tag_cont => NULL    , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item3' ,pr_posicao => 2, pr_tag_nova => 'inorigem', pr_tag_cont => 'M'     , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item3' ,pr_posicao => 2, pr_tag_nova => 'dsorigem', pr_tag_cont => 'MOBILE', pr_des_erro => vr_dscritic);
    --
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'origem',pr_posicao => 0, pr_tag_nova => 'item3'   , pr_tag_cont => NULL    , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item3' ,pr_posicao => 3, pr_tag_nova => 'inorigem', pr_tag_cont => 'A'     , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item3' ,pr_posicao => 3, pr_tag_nova => 'dsorigem', pr_tag_cont => 'AIMARO', pr_des_erro => vr_dscritic);
    --
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'origem',pr_posicao => 0, pr_tag_nova => 'item3'   , pr_tag_cont => NULL       , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item3' ,pr_posicao => 4, pr_tag_nova => 'inorigem', pr_tag_cont => 'J'        , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item3' ,pr_posicao => 4, pr_tag_nova => 'dsorigem', pr_tag_cont => 'CABINE JD', pr_des_erro => vr_dscritic);
    --
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'origem',pr_posicao => 0, pr_tag_nova => 'item3'   , pr_tag_cont => NULL      , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item3' ,pr_posicao => 5, pr_tag_nova => 'inorigem', pr_tag_cont => 'P'       , pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item3' ,pr_posicao => 5, pr_tag_nova => 'dsorigem', pr_tag_cont => 'PROTESTO', pr_des_erro => vr_dscritic);
    --
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml        --> XML que irá receber o novo atributo
                             ,pr_tag   => 'origem'         --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'       --> Nome do atributo
                             ,pr_atval => 6                --> Valor do atributo
                             ,pr_numva => 0                --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic); --> Descrição de erros
    --
  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_busca_filtros: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_buscar_filtros;

  PROCEDURE pc_buscar_mensagens_opcao_c_m(pr_opcao           IN VARCHAR2
                                         ,pr_dtmensagem_de   IN VARCHAR2
                                         ,pr_dtmensagem_ate  IN VARCHAR2
                                         ,pr_vlmensagem_de   IN VARCHAR2
                                         ,pr_vlmensagem_ate  IN VARCHAR2
                                         ,pr_nrdconta        IN VARCHAR2
                                         ,pr_inorigem        IN VARCHAR2
                                         ,pr_intipo          IN VARCHAR2
                                         ,pr_cdcooper        IN VARCHAR2
                                         ,pr_dsendere        IN VARCHAR2                               --> Endereço de e-mail para envio do CSV
                                         ,pr_nrispbif        IN VARCHAR2
                                         ,pr_nrregist        IN INTEGER                                --> Quantidade de registros
                                         ,pr_nriniseq        IN INTEGER                                --> Qunatidade inicial
                                         ,pr_xmllog          IN VARCHAR2                               --> XML com informações de LOG
                                         ,pr_cdcritic       OUT PLS_INTEGER                            --> Código da crítica
                                         ,pr_dscritic       OUT VARCHAR2                               --> Descrição da crítica
                                         ,pr_retxml      IN OUT NOCOPY xmltype                         --> Arquivo de retorno do XML
                                         ,pr_nmdcampo       OUT VARCHAR2                               --> Nome do Campo
                                         ,pr_des_erro       OUT VARCHAR2) IS                           --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_buscar_mensagens_opcao_c_m
    Sistema : Sistema Pagamentos Brasileiros - Cooperativa de Credito
    Sigla   : SPB
    Autor   : Marcelo Telles Coelho
    Data    : Outubro/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar as mensagens SPB a serem apresentadas

    Alteracoes:
    				  06-09-2019 - Remoção da máscara padrão de contas Ailos para apresentar contas de destino, utilizado máscara única.
  							 	   Diógenes Lazzarini - PRB0041598
  							 	       
    ............................................................................. */
    CURSOR cr_mensagem (pr_dtmensagem_de  IN DATE
                       ,pr_dtmensagem_ate IN DATE
                       ,pr_vlmensagem_de  IN VARCHAR2
                       ,pr_vlmensagem_ate IN VARCHAR2
                       ,pr_intipo         IN VARCHAR2
                       ,pr_opcao          IN VARCHAR2
                       ,pr_inorigem       IN VARCHAR2
                       ,pr_nrdconta       IN NUMBER
                       ,pr_cdcooper       IN NUMBER
                       ,pr_nrispbif       IN VARCHAR2) IS
      SELECT 'E' idorigem
            ,a.nrseq_mensagem
            ,a.dhmensagem
            ,a.nmmensagem
            ,a.nrcontrole_if nrcontrole
            ,a.nrcontrole_str_pag_rec nrcontrole_rec_env
            ,a.cdcooper
            ,TO_CHAR(a.nrdconta) CtDebtd
            ,NULL CtCredtd
            ,DECODE(NVL(a.inestado_crise,0),0,'Não','Sim') inestado_crise
            ,c.nrseq_mensagem_xml
            ,NULL nrdconta_migrada
            ,NULL cdcooper_migrada
            ,b.cdfase
            ,a.vlmensagem
            ,a.nrispb_deb
            ,a.nrispb_cre
        FROM tbspb_msg_enviada      a
            ,tbspb_msg_enviada_fase b
            ,tbspb_msg_xml          c
       WHERE b.nrseq_mensagem          = a.nrseq_mensagem
         AND c.nrseq_mensagem_xml      = b.nrseq_mensagem_xml
         AND (b.cdfase                 IN (10, 15)
         OR  (b.cdfase                 IN (992,999) AND pr_intipo = 'T'))
         AND pr_opcao                  = 'C'
         AND pr_intipo                IN ('T','E')
         AND TRUNC(a.dhmensagem) BETWEEN pr_dtmensagem_de
                                     AND pr_dtmensagem_ate
         AND (NVL(pr_vlmensagem_de,pr_vlmensagem_ate)
                                      IS NULL
          OR (NVL(pr_vlmensagem_de,pr_vlmensagem_ate)
                                      IS NOT NULL
           AND TELA_LOGSPB.fn_seleciona_valor(TO_NUMBER(pr_vlmensagem_de )/100
                                             ,TO_NUMBER(pr_vlmensagem_ate)/100
                                             ,a.vlmensagem)
                                       = 'SIM'))
         AND (pr_inorigem             IS NULL
          OR (pr_inorigem             IS NOT NULL
           AND TELA_LOGSPB.fn_define_origem (a.nrcontrole_if
                                            ,'IN'
                                            ,b.cdfase)
                                       = pr_inorigem))
         AND NVL(a.nrdconta,-1)        = NVL(pr_nrdconta,NVL(a.nrdconta,-1))
         AND NVL(a.cdcooper,3)         = DECODE(pr_cdcooper,0,NVL(a.cdcooper,3),pr_cdcooper)
         AND (pr_nrispbif             IS NULL
          OR (pr_nrispbif             IS NOT NULL
           AND a.nrispb_cre            = pr_nrispbif))
      UNION ALL
      SELECT 'R' idorigem
            ,a.nrseq_mensagem
            ,a.dhmensagem
            ,a.nmmensagem
            ,a.nrcontrole_str_pag nrcontrole
            ,a.nrcontrole_if_env nrcontrole_rec_env
            ,a.cdcooper
            ,NULL CtDebtd
            ,TO_CHAR(a.nrdconta) CtCredtd
            ,DECODE(NVL(a.inestado_crise,0),0,'Não','Sim') inestado_crise
            ,c.nrseq_mensagem_xml
            ,a.nrdconta_migrada
            ,a.cdcooper_migrada
            ,b.cdfase
            ,a.vlmensagem
            ,a.nrispb_deb
            ,a.nrispb_cre
        FROM tbspb_msg_recebida      a
            ,tbspb_msg_recebida_fase b
            ,tbspb_msg_xml           c
       WHERE b.nrseq_mensagem          = a.nrseq_mensagem
         AND c.nrseq_mensagem_xml      = b.nrseq_mensagem_xml
         AND (b.cdfase                 IN (115)
         OR  (b.cdfase                 IN (992,999) AND pr_intipo = 'T'))
         AND pr_intipo                IN ('T','R')
         AND ((pr_opcao                = 'C' AND a.nrdconta_migrada IS NULL)
           OR (pr_opcao                = 'M' AND a.nrdconta_migrada IS NOT NULL))
         AND TRUNC(a.dhmensagem) BETWEEN pr_dtmensagem_de
                                     AND pr_dtmensagem_ate
         AND (NVL(pr_vlmensagem_de,pr_vlmensagem_ate)
                                      IS NULL
          OR (NVL(pr_vlmensagem_de,pr_vlmensagem_ate)
                                      IS NOT NULL
           AND TELA_LOGSPB.fn_seleciona_valor(TO_NUMBER(pr_vlmensagem_de )/100
                                             ,TO_NUMBER(pr_vlmensagem_ate)/100
                                             ,a.vlmensagem)
                                       = 'SIM'))
         AND pr_inorigem              IS NULL
         AND NVL(a.nrdconta,-1)        = NVL(pr_nrdconta,NVL(a.nrdconta,-1))
         AND NVL(a.cdcooper,3)         = DECODE(pr_cdcooper,0,NVL(a.cdcooper,3),pr_cdcooper)
         AND (pr_nrispbif             IS NULL
          OR (pr_nrispbif             IS NOT NULL
           AND a.nrispb_deb            = pr_nrispbif))
      ORDER BY dhmensagem;
    rw_mensagem cr_mensagem%ROWTYPE;

    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis locais
    vr_contador INTEGER := 0;
    vr_VlrLanc           VARCHAR2(100);
    vr_CtCredtd          VARCHAR2(1000);
    vr_CtDebtd           VARCHAR2(1000);
    vr_dsorigem          VARCHAR2(1000);
    vr_insituac          VARCHAR2(1000);
    vr_ISPBIFDebtd       VARCHAR2(1000);
    vr_AgDebtd           VARCHAR2(1000);
    vr_CNPJ_CPFCliDebtd  VARCHAR2(1000);
    vr_NomCliDebtd       VARCHAR2(1000);
    vr_ISPBIFCredtd      VARCHAR2(1000);
    vr_AgCredtd          VARCHAR2(1000);
    vr_CNPJ_CPFCliCredtd VARCHAR2(1000);
    vr_NomCliCredtd      VARCHAR2(1000);
    vr_dsxml_completo    VARCHAR2(32000);
    vr_dsdevolucao       craptab.dstextab%TYPE;

    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_exc_email EXCEPTION;

    --Variaveis de controle
    vr_nrregist INTEGER := nvl(pr_nrregist,9999); --> Quantidade de registros a sere processado
    vr_qtregist INTEGER;
    vr_nrdconta VARCHAR2(50);

    TYPE typ_reg_txt IS
      RECORD (ds_txt VARCHAR2(4000));
    TYPE typ_tab_txt IS
      TABLE OF typ_reg_txt
      INDEX BY PLS_INTEGER;
    vr_tab_txt typ_tab_txt;

  BEGIN -- Inicio pc_buscar_mensagens_opcao_c_m
    gene0001.pc_informa_acesso(pr_module => 'LOGSPB'
                              ,pr_action => NULL);

    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      vr_cdcooper := 3;
    END IF;

    --Inicializar Variaveis
    vr_qtregist:= 0;
    --
    -- valida data parametro
    IF pr_dtmensagem_de is null or pr_dtmensagem_ate is null THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Período DE e/ou  ATE deve ser informado!';
      RAISE vr_exc_erro;
    END IF;
    --
    Begin
      vr_dtmensagem_de := NVL(TO_DATE(pr_dtmensagem_de ,'dd/mm/yyyy'),TO_DATE('25-09-2018','dd-mm-yyyy'));
      vr_dtmensagem_ate:= NVL(TO_DATE(pr_dtmensagem_ate,'dd-mm-yyyy'),TO_DATE('01-12-2999','dd-mm-yyyy'));
    Exception
      When others Then
      vr_cdcritic := 0;
      vr_dscritic := 'Erro no formato das datas do período! '||sqlerrm;
      RAISE vr_exc_erro;
    End;
    If pr_opcao = 'C' and (vr_dtmensagem_ate - vr_dtmensagem_de) > 6 then
      vr_cdcritic := 0;
      vr_dscritic := 'Período informado deve ser igual ou inferior a 7 dias!';
      RAISE vr_exc_erro;
    End If;

    --
    IF vr_dtmensagem_de < TO_DATE('25-09-2018','dd-mm-yyyy') THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Período inicial deve ser maior que 24/09/2018!';
      RAISE vr_exc_erro;
    END IF;
    --
    IF vr_dtmensagem_de > vr_dtmensagem_ate THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Data DE deve ser menor que o Data ATE!';
      RAISE vr_exc_erro;
    END IF;
    --
    -- valida valor
    IF TO_NUMBER(NVL(REPLACE(pr_vlmensagem_de,'.',','),0)) > TO_NUMBER(NVL(REPLACE(pr_vlmensagem_ate,'.',','),9999999999)) THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Valor DE deve ser menor que o Valor ATE!';
      RAISE vr_exc_erro;
    END IF;
    --
    If pr_nrdconta is not null Then
     vr_nrdconta := replace(pr_nrdconta,'.','');
     vr_nrdconta := replace(vr_nrdconta,'-','');
    End If;
    --
    vr_xml_temp := NULL;
    vr_varchar2 := NULL;
    vr_tab_txt.DELETE;
    -- Carregar arquivo com a tabela tbspb_fase_mensagem
    FOR rw_mensagem in cr_mensagem (pr_dtmensagem_de  => vr_dtmensagem_de
                                   ,pr_dtmensagem_ate => vr_dtmensagem_ate
                                   ,pr_vlmensagem_de  => pr_vlmensagem_de
                                   ,pr_vlmensagem_ate => pr_vlmensagem_ate
                                   ,pr_intipo         => pr_intipo
                                   ,pr_opcao          => pr_opcao
                                   ,pr_inorigem       => pr_inorigem
                                   ,pr_nrdconta       => vr_nrdconta
                                   ,pr_cdcooper       => pr_cdcooper
                                   ,pr_nrispbif       => pr_nrispbif)
    LOOP
      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;

      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo Titular
        CONTINUE;
      END IF;
      --
      BEGIN
        SELECT CASE
               WHEN LENGTH(dsxml_completo) <= 32000 THEN
                 dsxml_completo
               WHEN LENGTH(dsxml_completo) >  32000 THEN
                 NULL
               END CASE
          INTO vr_dsxml_completo
          FROM tbspb_msg_xml a
         WHERE a.nrseq_mensagem_xml = rw_mensagem.nrseq_mensagem_xml;
        --
        IF vr_dsxml_completo IS NULL THEN
          vr_dsxml_completo :=
          '<XML>' ||
          '<TEXTO> XML muito extenso (maior que 32000 bytes)</TEXTO>'||
          '<TEXTO> para visualizar o seu conteudo solicite a TI </TEXTO>'||
          '</XML>';
        END IF;
      EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao buscar XML - '||rw_mensagem.nrseq_mensagem_xml||' - '||SQLERRM;
        RAISE vr_exc_erro;
      END;
      --
      IF rw_mensagem.CtCredtd IS NULL THEN
        vr_CtCredtd := TO_CHAR(sspb0003.fn_busca_conteudo_campo(vr_dsxml_completo,'CtCredtd','C' ));
      ELSE
        vr_CtCredtd := rw_mensagem.CtCredtd;
      END IF;
      --
      IF rw_mensagem.CtDebtd IS NULL THEN
        vr_CtDebtd := TO_CHAR(sspb0003.fn_busca_conteudo_campo(vr_dsxml_completo,'CtDebtd','C' ));
      ELSE
        vr_CtDebtd := rw_mensagem.CtDebtd;
      END IF;
      --
      IF rw_mensagem.idorigem = 'E' THEN
        vr_dsorigem := TELA_LOGSPB.fn_define_origem (rw_mensagem.nrcontrole,'DS',rw_mensagem.cdfase);
      ELSE
        vr_dsorigem := NULL;
      END IF;
      --
      IF rw_mensagem.idorigem = 'E' THEN
        vr_insituac := TELA_LOGSPB.fn_define_situacao_enviada(rw_mensagem.nrseq_mensagem);
      ELSIF rw_mensagem.idorigem = 'R' Then
        vr_insituac := TELA_LOGSPB.fn_define_situacao_recebida(rw_mensagem.nrseq_mensagem, rw_mensagem.nrcontrole, rw_mensagem.nmmensagem);
      ELSE
        vr_insituac := NULL;  
      END IF;
      --
      vr_VlrLanc           := rw_mensagem.vlmensagem;
      vr_ISPBIFDebtd       := NVL(rw_mensagem.nrispb_deb,'999');
      vr_AgDebtd           := sspb0003.fn_busca_conteudo_campo(vr_dsxml_completo,'AgDebtd','C' );
      vr_CNPJ_CPFCliDebtd  := TELA_LOGSPB.fn_define_cnpj_cpf_debito (vr_dsxml_completo);
      vr_NomCliDebtd       := TELA_LOGSPB.fn_define_nome_debito (vr_dsxml_completo);
      vr_ISPBIFCredtd      := NVL(rw_mensagem.nrispb_cre,'999');
      --
      If pr_opcao = 'C' then
         vr_AgCredtd          := sspb0003.fn_busca_conteudo_campo(vr_dsxml_completo,'AgCredtd','C' );
      Else
         If rw_mensagem.cdcooper is not null then
           Begin 
             Select cop.cdagectl 
             Into vr_AgCredtd
             From Crapcop cop
             Where cop.cdcooper = rw_mensagem.cdcooper;
           Exception
             When others Then
                 vr_AgCredtd := null;
           End;     
         End If;  
      End If;                   
      vr_CNPJ_CPFCliCredtd := TELA_LOGSPB.fn_define_cnpj_cpf_credito (vr_dsxml_completo);
      vr_NomCliCredtd      := TELA_LOGSPB.fn_define_nome_credito (vr_dsxml_completo);
      --
      -- buscar cooperativa
      IF vr_tab_crapcop.EXISTS(NVL(rw_mensagem.cdcooper,3)) THEN
        vr_nmrescop := vr_tab_crapcop(NVL(rw_mensagem.cdcooper,3)).nmrescop;
      ELSE
      OPEN cr_crapcop (NVL(rw_mensagem.cdcooper,3));
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se não existe
      IF cr_crapcop%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_crapcop;
          -- Gera crítica
          vr_cdcritic := 0;
          vr_dscritic := 'Cooperativa não encontrada na CRAPCOP!';
          -- Levanta exceção
          RAISE vr_exc_erro;
      END IF;
      -- Fecha cursor
      CLOSE cr_crapcop;
        vr_tab_crapcop(NVL(rw_mensagem.cdcooper,3)).nmrescop := rw_crapcop.nmrescop;
      vr_nmrescop := rw_crapcop.nmrescop;
      END IF;
      --
      IF rw_mensagem.cdcooper_migrada IS NOT NULL THEN
        IF vr_tab_crapcop.EXISTS(rw_mensagem.cdcooper_migrada) THEN
          vr_nmrescop_migrada := vr_tab_crapcop(rw_mensagem.cdcooper_migrada).nmrescop;
        ELSE
          OPEN cr_crapcop (rw_mensagem.cdcooper_migrada);
        FETCH cr_crapcop INTO rw_crapcop;
        -- Se não existe
        IF cr_crapcop%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_crapcop;
            -- Gera crítica
            vr_cdcritic := 0;
            vr_dscritic := 'Cooperativa migrada não encontrada na CRAPCOP!';
            -- Levanta exceção
            RAISE vr_exc_erro;
        END IF;
        -- Fecha cursor
        CLOSE cr_crapcop;
        vr_tab_crapcop(rw_mensagem.cdcooper_migrada).nmrescop := rw_crapcop.nmrescop;
        vr_nmrescop_migrada := rw_crapcop.nmrescop;
        END IF;
      ELSE
        vr_nmrescop_migrada := NULL;
      END IF;
      --
      -- buscar bancos
      vr_bancoremet := null;
      IF rw_mensagem.nmmensagem <> 'SLC0001' THEN
        IF Nvl(vr_ISPBIFDebtd,999) <> 999 THEN
          IF vr_tab_crapban.EXISTS(vr_ISPBIFDebtd) THEN
            vr_bancoremet := vr_tab_crapban(vr_ISPBIFDebtd).nmresbcc;
          ELSE
            OPEN cr_crapban (vr_ISPBIFDebtd);
            FETCH cr_crapban INTO rw_crapban;
            -- Se não existe
            IF cr_crapban%NOTFOUND THEN
              vr_bancoremet := NULL;
            ELSE
              vr_bancoremet := substr(rw_crapban.nmresbcc,1,44);
            END IF;
            -- Fecha cursor
            CLOSE cr_crapban;
            vr_tab_crapban(vr_ISPBIFDebtd).nmresbcc := vr_bancoremet;
          END IF;
        ELSE
            vr_ISPBIFDebtd:= NULL;
        END IF;
        --
        vr_bancodest := null;
        IF NVL(vr_ISPBIFCredtd,999) <> 999 THEN
          IF vr_tab_crapban.EXISTS(vr_ISPBIFCredtd) THEN
            vr_bancodest := vr_tab_crapban(vr_ISPBIFCredtd).nmresbcc;
          ELSE
            OPEN cr_crapban (vr_ISPBIFCredtd);
            FETCH cr_crapban INTO rw_crapban;
            -- Se não existe
            IF cr_crapban%NOTFOUND THEN
              vr_bancodest := NULL;
            ELSE
              vr_bancodest := substr(rw_crapban.nmresbcc,1,44);
            END IF;
            -- Fecha cursor
            CLOSE cr_crapban;
            vr_tab_crapban(vr_ISPBIFCredtd).nmresbcc := vr_bancodest;
          END IF;
        ELSE
            vr_ISPBIFCredtd := NULL;
        END IF;
      ELSE
        vr_bancodest:= null;
        vr_bancoremet:= null;
      END IF;
      vr_dsdevolucao := NULL;
      -- buscar caixa/operador
      IF rw_mensagem.idorigem = 'E' THEN
        OPEN cr_craptvl (NVL(rw_mensagem.cdcooper,3)
                        ,rw_mensagem.nrcontrole);
        FETCH cr_craptvl INTO rw_craptvl;
        -- Se não existe
        IF cr_craptvl%NOTFOUND THEN
          rw_craptvl.cdbccxlt := NULL;
          rw_craptvl.cdoperad := NULL;
        END IF;
        -- Fecha cursor
        CLOSE cr_craptvl;
        --
        If vr_insituac in ('DEVOLVIDA','EM DEVOLUÇÃO') Then
           --
           vr_dsdevolucao := fn_busca_devolucao (rw_mensagem.nrcontrole,'E');
           --
        End If;
      ELSE
        rw_craptvl.cdbccxlt := NULL;
        rw_craptvl.cdoperad := NULL;
        --
        If vr_insituac in ('DEVOLVIDA','EM DEVOLUÇÃO') Then
           --
           vr_dsdevolucao := fn_busca_devolucao (rw_mensagem.nrcontrole,'R');
           --
        End If;
      END IF;
      --
      --Escrever no XML
      --
      -- Tratar caracteres especiais vindos no xml (geram erro ao converter o clob no xml)
      vr_NomCliCredtd := TRIM(Replace(vr_NomCliCredtd,'&AMP;','e')); 
      vr_NomCliCredtd := TRIM(Replace(vr_NomCliCredtd,'&APOS;','''')); 
      vr_NomCliCredtd := TRIM(Replace(vr_NomCliCredtd,'&LT;','<')); 
      vr_NomCliCredtd := TRIM(Replace(vr_NomCliCredtd,'&GT;','>')); 
      vr_NomCliCredtd := TRIM(Replace(vr_NomCliCredtd,'&QUOT;','"'));                   
      --
      vr_NomCliDebtd := TRIM(Replace(vr_NomCliDebtd,'&AMP;','e')); 
      vr_NomCliDebtd := TRIM(Replace(vr_NomCliDebtd,'&APOS;','''')); 
      vr_NomCliDebtd := TRIM(Replace(vr_NomCliDebtd,'&LT;','<')); 
      vr_NomCliDebtd := TRIM(Replace(vr_NomCliDebtd,'&GT;','>')); 
      vr_NomCliDebtd := TRIM(Replace(vr_NomCliDebtd,'&QUOT;','"')); 
      --        
      IF pr_dsendere IS NULL THEN
        IF vr_nrregist > 0 THEN
            vr_tab_txt(vr_contador+1).ds_txt :=
                       '<item>'
                    || '<idorigem>'       ||rw_mensagem.idorigem                                                       || '</idorigem>'
                    || '<nrseq_mensagem>' || rw_mensagem.nrseq_mensagem                                                || '</nrseq_mensagem>'
                    || '<datamsg>'        || TO_CHAR(rw_mensagem.dhmensagem,'dd-mm-yyyy')                              || '</datamsg>'
                    || '<horamsg>'        || TO_CHAR(rw_mensagem.dhmensagem,'hh24:mi:ss')                              || '</horamsg>'
                    || '<dsmensagem>'     || rw_mensagem.nmmensagem                                                    || '</dsmensagem>'
                    || '<numcontrole>'    || rw_mensagem.nrcontrole                                                    || '</numcontrole>'
                    || '<valor>'          || TRIM(TO_CHAR(vr_VlrLanc,'FM99G999G999G990D00'))                           || '</valor>'
                    || '<situacao>'       || vr_insituac                                                               || '</situacao>'
                    || '<bancoremet>'     || TRIM(vr_bancoremet)                                                       || '</bancoremet>'
                    || '<agenciaremet>'   || TRIM(vr_AgDebtd)                                                          || '</agenciaremet>'
                    || '<contaremet>'     || TRIM(gene0002.fn_mask_conta(pr_nrdconta => vr_CtDebtd))                   || '</contaremet>'
                    || '<cooperativa>'    || vr_nmrescop                                                               || '</cooperativa>'
                    || '<nomeremet>'      || vr_NomCliDebtd                                                            || '</nomeremet>'
                    || '<cpfcnpjremet>'   || TRIM(vr_CNPJ_CPFCliDebtd)                                                 || '</cpfcnpjremet>'
                    || '<bancodest>'      || TRIM(vr_bancodest)                                                        || '</bancodest>'
                    || '<agenciadest>'    || TRIM(vr_AgCredtd)                                                         || '</agenciadest>'
                    || '<contadest>'      || TRIM(gene0002.fn_mask(pr_dsorigi => vr_CtCredtd, pr_dsforma => 'zzzzzzzzzzzzzz.zzz.z')) || '</contadest>'
                    || '<nomedest>'       || vr_NomCliCredtd                                                           || '</nomedest>'
                    || '<cpfcnpjdest>'    || vr_CNPJ_CPFCliCredtd                                                      || '</cpfcnpjdest>'
                      || '<motdev>'         || vr_dsdevolucao                                                            || '</motdev>'
                    || '<origem>'         || vr_dsorigem                                                               || '</origem>'
                    || '<caixa>'          || rw_craptvl.cdbccxlt                                                       || '</caixa>'
                    || '<operador>'       || rw_craptvl.cdoperad                                                       || '</operador>'
                    || '<crise>'          || rw_mensagem.inestado_crise                                                || '</crise>'
                    || '<coopmigrada>'    || TRIM(vr_nmrescop_migrada)                                                 || '</coopmigrada>'
                    || '<nrcontamigrada>' || TRIM(gene0002.fn_mask_conta(pr_nrdconta => rw_mensagem.nrdconta_migrada)) || '</nrcontamigrada>'
                    || '</item>'
                    || CHR(13);
          END IF;
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;
      ELSE
        IF vr_contador = 0 THEN
          vr_tab_txt(1).ds_txt := 'Data;Hora;Mensagem;"Num. Controle";Valor;Situação;'
                               || '"Banco Remet";"Agência Remet";"Conta Remet";"Nome Remet";"CPF/CNPJ Remet";'
                               || '"Banco Dest";"Agência Dest";"Conta Dest";"Nome Dest";"CPF/CNPJ Dest";'
                               || '"Motivo Devolução";"Caixa";"Origem";"Operador";"Crise";"Cooperativa";"Cooperativa Migrada";"Conta Migrada"';
          vr_contador := 2;
        END IF;
        --
        vr_tab_txt(vr_contador).ds_txt := TO_CHAR(rw_mensagem.dhmensagem,'dd-mm-yyyy')
                                  ||';'|| TO_CHAR(rw_mensagem.dhmensagem,'hh24:mi:ss')
                                  ||';'|| rw_mensagem.nmmensagem
                                  ||';'|| rw_mensagem.nrcontrole
                                  ||';'|| TRIM(REPLACE(TO_CHAR(vr_VlrLanc,'FM99999999990.00'),'.',','))
                                  ||';'|| vr_insituac
                                  ||';'|| TRIM(Replace(vr_bancoremet,';',''))
                                  ||';'|| TRIM(vr_AgDebtd)
                                  ||';'|| TRIM(gene0002.fn_mask_conta(pr_nrdconta => vr_CtDebtd))
                                  ||';'|| vr_NomCliDebtd
                                  ||';'|| TRIM(vr_CNPJ_CPFCliDebtd)
                                  ||';'|| TRIM(Replace(vr_bancodest,';',''))
                                  ||';'|| TRIM(vr_AgCredtd)
                                  ||';'|| TRIM(gene0002.fn_mask(pr_dsorigi => vr_CtCredtd, pr_dsforma => 'zzzzzzzzzzzzzz.zzz.z'))
                                  ||';'|| vr_NomCliCredtd
                                  ||';'|| vr_CNPJ_CPFCliCredtd
                                  ||';'|| Replace(vr_dsdevolucao,';','')
                                  ||';'|| rw_craptvl.cdbccxlt
                                  ||';'|| vr_dsorigem
                                  ||';'|| rw_craptvl.cdoperad
                                  ||';'|| rw_mensagem.inestado_crise
                                  ||';'|| TRIM(Replace(vr_nmrescop,';',''))
                                  ||';'|| TRIM(Replace(vr_nmrescop_migrada,';',''))
                                  ||';'|| TRIM(rw_mensagem.nrdconta_migrada)
                                  ||';';
      END IF;
      vr_contador := vr_contador + 1;
    END LOOP;
    --
    IF pr_dsendere IS NULL THEN
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
      vr_varchar2 := '<?xml version="1.0" encoding="WINDOWS-1252"?>'
                  || '<Dados> <mensagem qtregist="'||vr_qtregist||'">';
      dbms_lob.writeappend(vr_clob,length(vr_varchar2),vr_varchar2);
      --
      IF vr_contador > 0 THEN
        FOR i IN 1 .. vr_tab_txt.COUNT LOOP
          dbms_lob.writeappend(vr_clob,length(vr_tab_txt(i).ds_txt),vr_tab_txt(i).ds_txt);
      END LOOP;
      END IF;
      --
      vr_varchar2 := '</mensagem> </Dados>';
      dbms_lob.writeappend(vr_clob,length(vr_varchar2),vr_varchar2);
      pr_retxml := xmltype(vr_clob);
      -- Liberando a mem¿ria alocada pro CLOB
      dbms_lob.close(vr_clob);
      dbms_lob.freetemporary(vr_clob);
    ELSE
      IF vr_contador > 0 THEN
        DECLARE
          vr_dsdircop          VARCHAR2(100);
          vr_dircop_txt        VARCHAR2(1000);
          vr_nom_arquivo       VARCHAR2(1000);
          vr_ind_modo_abertura VARCHAR2(1000);
          vr_ind_arqlog        UTL_FILE.file_type; -- Handle para o arquivo de log
        BEGIN
          BEGIN
            SELECT dsdircop
              INTO vr_dsdircop
              FROM crapcop
             WHERE cdcooper = vr_cdcooper;
          EXCEPTION
          WHEN OTHERS THEN
            vr_dsdircop := 'cecred';
          END;
          --
          vr_dircop_txt        := '/usr/sistemas/SPB/LOGSPB/'||vr_dsdircop;
          vr_nom_arquivo       := 'LOGSPB_'||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')||'.csv';
          vr_ind_modo_abertura := 'W'; --> W_Write, A=Append
          -- Abrir o arquivo
          gene0001.pc_abre_arquivo(pr_nmdireto => vr_dircop_txt         --> Diretório do arquivo
                                  ,pr_nmarquiv => vr_nom_arquivo        --> Nome do arquivo
                                  ,pr_tipabert => vr_ind_modo_abertura  --> Modo de abertura (R,W,A)
                                  ,pr_utlfileh => vr_ind_arqlog         --> Handle do arquivo aberto
                                  ,pr_des_erro => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic := 0;
            RAISE vr_exc_erro;
          END IF;
          --
          FOR i IN 1 .. vr_tab_txt.COUNT LOOP
            -- Adiciona a linha de log
            BEGIN
              gene0001.pc_escr_linha_arquivo(vr_ind_arqlog,vr_tab_txt(i).ds_txt);
            EXCEPTION
            WHEN OTHERS THEN
              -- Retornar erro
              vr_dscritic := 'Problema ao escrever no arquivo <'||vr_dircop_txt||'/'||vr_nom_arquivo||'>: ' || sqlerrm;
              RAISE vr_exc_erro;
            END;
          END LOOP;
          --
          BEGIN
            gene0001.pc_fecha_arquivo(vr_ind_arqlog);
          EXCEPTION
            WHEN OTHERS THEN
              -- Retornar erro
              vr_dscritic := 'Problema ao fechar o arquivo <'||vr_dircop_txt||'/'||vr_nom_arquivo||'>: ' || sqlerrm;
              RAISE vr_exc_erro;
          END;
          --
          pr_dscritic := 'Sua solicitação foi processada com sucesso e o arquivo '||vr_nom_arquivo||' já está disponível no diretório: X:\SPB\LOGSPB\'||vr_dsdircop||'.';
          RAISE vr_exc_email;
        END;
        --
      END IF;
    END IF;
    --
  EXCEPTION
    WHEN vr_exc_email THEN
      DECLARE
        vr_aux_dsdemail VARCHAR2(1000);
      BEGIN
        vr_aux_dsdemail := pr_dscritic;
        pr_cdcritic     := null;
        pr_dscritic     := null;

        -- Enviar Email para o Financeiro
        gene0003.pc_solicita_email(pr_cdcooper        => vr_cdcooper
                                  ,pr_cdprogra        => 'LOGSPB'
                                  ,pr_des_destino     => pr_dsendere
                                  ,pr_des_assunto     => 'LOGSPB - notificação arquivo de TEDs'
                                  ,pr_des_corpo       => vr_aux_dsdemail
                                  ,pr_des_anexo       => ''
                                  ,pr_flg_enviar      => 'S'
                                  ,pr_flg_log_batch   => 'N' --> Incluir inf. no log
                                  ,pr_des_erro        => vr_dscritic);
        -- Se ocorreu erro
        IF trim(vr_dscritic) IS NOT NULL THEN
          NULL;
        END IF;
      END;
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      IF pr_dsendere IS NULL THEN
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ELSE
        RAISE vr_exc_email;
      END IF;
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_LOGSPB.pc_buscar_mensagens_opcao_c_m --> '||vr_nmrescop_migrada ||SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_buscar_mensagens_opcao_c_m;

  PROCEDURE pc_buscar_mensagens_opcao_s(pr_opcao           IN VARCHAR2
                                       ,pr_dtmensagem_de   IN VARCHAR2
                                       ,pr_dtmensagem_ate  IN VARCHAR2
                                       ,pr_vlmensagem_de   IN VARCHAR2
                                       ,pr_vlmensagem_ate  IN VARCHAR2
                                       ,pr_nrdconta        IN VARCHAR2
                                       ,pr_inorigem        IN VARCHAR2
                                       ,pr_intipo          IN VARCHAR2
                                       ,pr_cdcooper        IN VARCHAR2
                                       ,pr_nrispbif        IN VARCHAR2
                                       ,pr_nrregist        IN INTEGER                                --> Quantidade de registros
                                       ,pr_nriniseq        IN INTEGER                                --> Qunatidade inicial
                                       ,pr_xmllog          IN VARCHAR2                               --> XML com informações de LOG
                                       ,pr_cdcritic       OUT PLS_INTEGER                            --> Código da crítica
                                       ,pr_dscritic       OUT VARCHAR2                               --> Descrição da crítica
                                       ,pr_retxml      IN OUT NOCOPY xmltype                         --> Arquivo de retorno do XML
                                       ,pr_nmdcampo       OUT VARCHAR2                               --> Nome do Campo
                                       ,pr_des_erro       OUT VARCHAR2) IS                           --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_buscar_mensagens_opcao_s
    Sistema : Sistema Pagamentos Brasileiros - Cooperativa de Credito
    Sigla   : SPB
    Autor   : Marcelo Telles Coelho
    Data    : Outubro/2018                       Ultima atualizacao:
    
             11/06/2019 - Permitir consultar intervalo de 10 dias.
                          Jose Dill - Mouts (P475 - REQ65)

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar as mensagens SPB a serem apresentadas

    Alteracoes:
    ............................................................................. */

    CURSOR cr_mensagem (pr_dtmensagem_de  IN DATE
                       ,pr_dtmensagem_ate IN DATE
                       ,pr_vlmensagem_de  IN VARCHAR2
                       ,pr_vlmensagem_ate IN VARCHAR2
                       ,pr_cdcooper       IN NUMBER) IS
      SELECT to_char(vldocmto,'999999999.00') vldocmto
            ,nrsequen
            ,cdbandif
            ,cdagedif
            ,DECODE(GREATEST(LENGTH(nrctadif),20),20,nrctadif,0) nrctadif
            ,nmtitdif
            ,nrcpfdif
            ,cdbanctl
            ,cdagectl
            ,nrdconta
            ,nmcopcta
            ,nrcpfcop
            --,TO_CHAR(dttransa,'dd/mm/yyyy')||' '||TO_CHAR(TO_DATE(hrtransa,'sssss'),'hh24:mi:ss') dhtransa
            ,dttransa
            ,hrtransa
            ,dsmotivo
            ,cdagenci
            ,nrdcaixa
            ,cdoperad
            ,idorigem
            ,nrctrlif
            ,nmevento
            ,nrispbif
            ,DECODE(idsitmsg,3,'EFETIVADA','DEVOLVIDA') dstransa
        FROM craplmt
       WHERE cdcooper      IN (SELECT cdcooper FROM crapcop WHERE cdcooper = DECODE(pr_cdcooper,0,NVL(craplmt.cdcooper,3),pr_cdcooper))
         AND dttransa BETWEEN pr_dtmensagem_de
                          AND pr_dtmensagem_ate
         AND (NVL(pr_vlmensagem_de,pr_vlmensagem_ate)
                                      IS NULL
          OR (NVL(pr_vlmensagem_de,pr_vlmensagem_ate)
                                      IS NOT NULL
           AND TELA_LOGSPB.fn_seleciona_valor(TO_NUMBER(pr_vlmensagem_de )/100
                                             ,TO_NUMBER(pr_vlmensagem_ate)/100
                                             ,vldocmto)
                                       = 'SIM'))
         AND cdifconv                  = 1
         AND idsitmsg                 IN (3, 4) -- (1-Enviada-ok, 2-enviada-nok, 3-recebida-ok,4-Recebina-nok,)
       ORDER BY dttransa,hrtransa, nrsequen;
    rw_mensagem cr_mensagem%ROWTYPE;

    CURSOR cr_crapban (pr_cdbccxlt IN NUMBER) IS
      SELECT nrispbif
        FROM crapban
       WHERE cdbccxlt = pr_cdbccxlt;
    rw_crapban cr_crapban%ROWTYPE;

    vr_dtmensagem_de    DATE;
    vr_dtmensagem_ate   DATE;
    vr_contador         NUMBER;
    vr_exc_erro         EXCEPTION;

    --Variaveis de controle
    vr_nrregist INTEGER := nvl(pr_nrregist,9999); --> Quantidade de registros a sere processado
    vr_qtregist INTEGER;


    BEGIN -- Inicio pc_buscar_mensagens_opcao_s
    -- valida data parametro
    vr_dtmensagem_de := NVL(to_date(pr_dtmensagem_de,'dd-mm-yyyy'),'01-01-1900');
    vr_dtmensagem_ate:= NVL(to_date(pr_dtmensagem_ate,'dd-mm-yyyy'),'01-01-2900');
    --
    -- valida se as datas estao sendo passadas em branco
    IF pr_dtmensagem_de is null or pr_dtmensagem_ate is null THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Período DE e/ou  ATE deve ser informado!';
      RAISE vr_exc_erro;
    END IF;
    --
    IF vr_dtmensagem_de > vr_dtmensagem_ate THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Data DE deve ser menor que o Data ATE!';
      RAISE vr_exc_erro;
    END IF;
    --
    -- valida valor
    IF TO_NUMBER(NVL(pr_vlmensagem_de,0)) > TO_NUMBER(NVL(pr_vlmensagem_ate,9999999999)) THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Valor DE deve ser menor que o Valor ATE!';
      RAISE vr_exc_erro;
    END IF;
    -- Validar intervalor de 10 dias
    If (vr_dtmensagem_ate - vr_dtmensagem_de) > 10 then
      vr_cdcritic := 0;
      vr_dscritic := 'Período informado deve ser igual ou inferior a 10 dias!';
      RAISE vr_exc_erro;
    End If;

    --
    --Inicializar Variaveis
    vr_qtregist:= 0;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    --
    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'mensagem'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);
    --
    vr_contador := 0;
    --
    -- Carregar arquivo com a tabela CRAPLMT Efetivada
    FOR rw_mensagem in cr_mensagem (pr_dtmensagem_de  => vr_dtmensagem_de
                                   ,pr_dtmensagem_ate => vr_dtmensagem_ate
                                   ,pr_vlmensagem_de  => pr_vlmensagem_de
                                   ,pr_vlmensagem_ate => pr_vlmensagem_ate
                                   ,pr_cdcooper       => pr_cdcooper
                                   )
    LOOP

      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;

      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo Titular
        CONTINUE;
      END IF;

      -- buscar cooperativa
      OPEN cr_crapban (pr_cdbccxlt => rw_mensagem.cdbanctl);
      FETCH cr_crapban INTO rw_crapban;
      -- Se não existe
      IF cr_crapban%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_crapban;
          -- Gera crítica
          vr_cdcritic := 0;
          vr_dscritic := 'Cooperativa não encontrada na CRAPCOP!';
          -- Levanta exceção
          RAISE vr_exc_erro;
      END IF;
      -- Fecha cursor
      CLOSE cr_crapban;
      --
      --Escrever no XML
      --
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'mensagem',pr_posicao  => 0,pr_tag_nova => 'item',pr_tag_cont => null,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'nmevento' , pr_tag_cont => rw_mensagem.nmevento, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'nrctrlif' , pr_tag_cont => rw_mensagem.nrctrlif, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'vltransa' , pr_tag_cont => rw_mensagem.vldocmto, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'dhtransa' , pr_tag_cont => To_char(rw_mensagem.dttransa,'dd-mm-yyyy'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'hrtransa' , pr_tag_cont => TO_CHAR(TO_DATE(rw_mensagem.hrtransa,'sssss'),'hh24:mi:ss'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'dsmotivo' , pr_tag_cont => rw_mensagem.dsmotivo, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'cdbanren' , pr_tag_cont => rw_mensagem.cdbandif, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'cdispbren', pr_tag_cont => rw_mensagem.nrispbif, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'cdagerem' , pr_tag_cont => rw_mensagem.cdagedif, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'nrctarem' , pr_tag_cont => gene0002.fn_mask_conta(pr_nrdconta => rw_mensagem.nrctadif),pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'dsnomrem' , pr_tag_cont => rw_mensagem.nmtitdif, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'dscpfrem' , pr_tag_cont => rw_mensagem.nrcpfdif, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'cdbandst' , pr_tag_cont => rw_mensagem.cdbanctl, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'cdispbdst', pr_tag_cont => rw_crapban.nrispbif , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'cdagedst' , pr_tag_cont => rw_mensagem.cdagectl, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'nrctadst' , pr_tag_cont => rw_mensagem.nrdconta, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'dsnomdst' , pr_tag_cont => rw_mensagem.nmcopcta, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'dscpfdst' , pr_tag_cont => rw_mensagem.nrcpfcop, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'caixa'    , pr_tag_cont => rw_mensagem.nrdcaixa, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'operador' , pr_tag_cont => rw_mensagem.cdoperad, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item',pr_posicao => vr_contador,pr_tag_nova => 'dstransa' , pr_tag_cont => rw_mensagem.dstransa, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;

      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;

    END LOOP;
    --
    IF vr_contador > 0 THEN
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'mensagem'          --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_qtregist         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
    END IF;
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_LOGSPB.pc_buscar_mensagens_opcao_c_m --> ' ||SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END pc_buscar_mensagens_opcao_s;

  PROCEDURE pc_buscar_mensagens(pr_opcao           IN VARCHAR2
                              ,pr_dtmensagem_de   IN VARCHAR2
                              ,pr_dtmensagem_ate  IN VARCHAR2
                              ,pr_vlmensagem_de   IN VARCHAR2
                              ,pr_vlmensagem_ate  IN VARCHAR2
                              ,pr_nrdconta        IN VARCHAR2
                              ,pr_inorigem        IN VARCHAR2
                              ,pr_intipo          IN VARCHAR2
                              ,pr_cdcooper        IN VARCHAR2
                              ,pr_dsendere        IN VARCHAR2                               --> Endereço de e-mail para envio do CSV
                              ,pr_nrispbif        IN VARCHAR2
                              ,pr_nrregist        IN INTEGER                                  --> Quantidade de registros
                              ,pr_nriniseq        IN INTEGER                                  --> Qunatidade inicial
                              ,pr_xmllog          IN VARCHAR2                               --> XML com informações de LOG
                              ,pr_cdcritic       OUT PLS_INTEGER                            --> Código da crítica
                              ,pr_dscritic       OUT VARCHAR2                               --> Descrição da crítica
                              ,pr_retxml      IN OUT NOCOPY xmltype                         --> Arquivo de retorno do XML
                              ,pr_nmdcampo       OUT VARCHAR2                               --> Nome do Campo
                              ,pr_des_erro       OUT VARCHAR2) IS                           --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_buscar_mensagens
    Sistema : Sistema Pagamentos Brasileiros - Cooperativa de Credito
    Sigla   : SPB
    Autor   : Marcelo Telles Coelho
    Data    : Outubro/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar as mensagens SPB a serem apresentadas

    Alteracoes:
    ............................................................................. */
    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN -- Inicio pc_buscar_mensagens
    gene0001.pc_informa_acesso(pr_module => 'LOGSPB'
                              ,pr_action => NULL);

    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      vr_cdcooper := 3;
    END IF;

    IF pr_opcao = 'C' THEN
      IF pr_dsendere IS NOT NULL THEN
        -- Chamar o JOB
        -- Montar o bloco PLSQL que será executado
        -- Ou seja, executaremos a geração do arquivo CSV
        DECLARE
          vr_dsplsql    VARCHAR2(32000);
          vr_dhexecucao VARCHAR2(100);
          vr_jobname    VARCHAR2(1000);
        BEGIN
          vr_dsplsql := 'DECLARE'||chr(13)
                     || '  vr_cdcritic NUMBER;'||chr(13)
                     || '  vr_dscritic VARCHAR2(4000);'||chr(13)
                     || '  vr_retxml   XMLTYPE;'||chr(13)
                     || '  vr_nmdcampo VARCHAR2(4000);'||chr(13)
                     || '  vr_des_erro VARCHAR2(4000);'||chr(13)
                     || 'BEGIN'||chr(13)
                     || '  cecred.tela_logspb.pc_buscar_mensagens_opcao_c_m '
                     || '               (pr_opcao           => '''||            pr_opcao||''''
                     || '               ,pr_dtmensagem_de   => '''||            pr_dtmensagem_de||''''
                     || '               ,pr_dtmensagem_ate  => '''||            pr_dtmensagem_ate||''''
                     || '               ,pr_vlmensagem_de   => '  ||NVL(TO_CHAR(pr_vlmensagem_de),'NULL')
                     || '               ,pr_vlmensagem_ate  => '  ||NVL(TO_CHAR(pr_vlmensagem_ate),'NULL')
                     || '               ,pr_nrdconta        => '  ||NVL(TO_CHAR(pr_nrdconta),'NULL')
                     || '               ,pr_inorigem        => '''||            pr_inorigem||''''
                     || '               ,pr_intipo          => '''||            pr_intipo||''''
                     || '               ,pr_cdcooper        => '  ||            pr_cdcooper
                     || '               ,pr_dsendere        => '''||            pr_dsendere||''''
                     || '               ,pr_nrispbif        => NULL'
                     || '               ,pr_nrregist        => NULL'
                     || '               ,pr_nriniseq        => '  ||NVL(TO_CHAR(pr_nriniseq),'NULL')
                     || '               ,pr_xmllog          => '  ||NVL(TO_CHAR(''''||pr_xmllog||''''),'NULL')
                     || '               ,pr_cdcritic        => vr_cdcritic'
                     || '               ,pr_dscritic        => vr_dscritic'
                     || '               ,pr_retxml          => vr_retxml  '
                     || '               ,pr_nmdcampo        => vr_nmdcampo'
                     || '               ,pr_des_erro        => vr_des_erro);'
                     || '  COMMIT;'
                     || 'END;';
          -- Montar o prefixo do código do programa para o jobname
          vr_dhexecucao := TO_CHAR(sysdate,'YYYY_MM_DD');
          vr_jobname    := 'LOGSPB_'||vr_dhexecucao||'$';
          -- Faz a chamada ao programa paralelo atraves de JOB
          GENE0001.pc_submit_job(pr_cdcooper  => vr_cdcooper  --> Código da cooperativa
                                ,pr_cdprogra  => 'LOGSPB'     --> Código do programa
                                ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                                ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                                ,pr_interva   => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                                ,pr_jobname   => vr_jobname   --> Nome randomico criado
                                ,pr_des_erro  => pr_dscritic);
          -- Testar saida com erro
          IF pr_dscritic IS NOT NULL THEN
            -- Levantar exceçao
            RAISE vr_exc_erro;
          END IF;
        END;
      ELSE
      pc_buscar_mensagens_opcao_c_m(pr_opcao           => pr_opcao
                                   ,pr_dtmensagem_de   => pr_dtmensagem_de
                                   ,pr_dtmensagem_ate  => pr_dtmensagem_ate
                                   ,pr_vlmensagem_de   => pr_vlmensagem_de
                                   ,pr_vlmensagem_ate  => pr_vlmensagem_ate
                                   ,pr_nrdconta        => pr_nrdconta
                                   ,pr_inorigem        => pr_inorigem
                                   ,pr_intipo          => pr_intipo
                                   ,pr_cdcooper        => pr_cdcooper
                                     ,pr_dsendere        => pr_dsendere
                                   ,pr_nrispbif        => pr_nrispbif
                                   ,pr_nrregist        => pr_nrregist
                                   ,pr_nriniseq        => pr_nriniseq
                                   ,pr_xmllog          => pr_xmllog
                                   ,pr_cdcritic        => pr_cdcritic
                                   ,pr_dscritic        => pr_dscritic
                                   ,pr_retxml          => pr_retxml
                                   ,pr_nmdcampo        => pr_nmdcampo
                                   ,pr_des_erro        => pr_des_erro);
      END IF;
    ELSIF pr_opcao = 'M' THEN
      pc_buscar_mensagens_opcao_c_m(pr_opcao           => pr_opcao
                                   ,pr_dtmensagem_de   => pr_dtmensagem_de
                                   ,pr_dtmensagem_ate  => pr_dtmensagem_ate
                                   ,pr_vlmensagem_de   => pr_vlmensagem_de
                                   ,pr_vlmensagem_ate  => pr_vlmensagem_ate
                                   ,pr_nrdconta        => pr_nrdconta
                                   ,pr_inorigem        => pr_inorigem
                                   ,pr_intipo          => pr_intipo
                                   ,pr_cdcooper        => pr_cdcooper
                                   ,pr_dsendere        => pr_dsendere
                                   ,pr_nrispbif        => pr_nrispbif
                                   ,pr_nrregist        => pr_nrregist
                                   ,pr_nriniseq        => pr_nriniseq
                                   ,pr_xmllog          => pr_xmllog
                                   ,pr_cdcritic        => pr_cdcritic
                                   ,pr_dscritic        => pr_dscritic
                                   ,pr_retxml          => pr_retxml
                                   ,pr_nmdcampo        => pr_nmdcampo
                                   ,pr_des_erro        => pr_des_erro);
    ELSIF pr_opcao = 'S' THEN
      pc_buscar_mensagens_opcao_s(pr_opcao           => pr_opcao
                                 ,pr_dtmensagem_de   => pr_dtmensagem_de
                                 ,pr_dtmensagem_ate  => pr_dtmensagem_ate
                                 ,pr_vlmensagem_de   => pr_vlmensagem_de
                                 ,pr_vlmensagem_ate  => pr_vlmensagem_ate
                                 ,pr_nrdconta        => pr_nrdconta
                                 ,pr_inorigem        => pr_inorigem
                                 ,pr_intipo          => pr_intipo
                                 ,pr_cdcooper        => pr_cdcooper
                                 ,pr_nrispbif        => pr_nrispbif
                                 ,pr_nrregist        => pr_nrregist
                                 ,pr_nriniseq        => pr_nriniseq
                                 ,pr_xmllog          => pr_xmllog
                                 ,pr_cdcritic        => pr_cdcritic
                                 ,pr_dscritic        => pr_dscritic
                                 ,pr_retxml          => pr_retxml
                                 ,pr_nmdcampo        => pr_nmdcampo
                                 ,pr_des_erro        => pr_des_erro);
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_LOGSPB.pc_buscar_mensagens_opcao_c_m --> ' ||SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_buscar_mensagens;

  PROCEDURE pc_buscar_detalhe_msg(pr_nrseq_mensagem  IN NUMBER
                                 ,pr_idorigem        IN VARCHAR2                               --> E=Enviada, R=Recebida
                                 ,pr_xmllog          IN VARCHAR2                               --> XML com informações de LOG
                                 ,pr_cdcritic       OUT PLS_INTEGER                            --> Código da crítica
                                 ,pr_dscritic       OUT VARCHAR2                               --> Descrição da crítica
                                 ,pr_retxml      IN OUT NOCOPY xmltype                         --> Arquivo de retorno do XML
                                 ,pr_nmdcampo       OUT VARCHAR2                               --> Nome do Campo
                                 ,pr_des_erro       OUT VARCHAR2) IS                           --> Saida OK/NOK
    CURSOR cr_ver_layout_1(pr_nrseq_mensagem IN NUMBER
                          ,pr_idorigem       IN VARCHAR2) IS
    SELECT a.dhmensagem dhmensagem_env
          ,b.dhmensagem dhmensagem_rec
          ,a.nrseq_mensagem nrseq_mensagem_env
          ,b.nrseq_mensagem nrseq_mensagem_rec
      FROM tbspb_msg_enviada a
          ,tbspb_msg_recebida b
     WHERE a.nrseq_mensagem         = pr_nrseq_mensagem
       AND b.nrcontrole_str_pag (+) = a.nrcontrole_str_pag_rec
       AND pr_idorigem              = 'E'
    UNION
    SELECT a.dhmensagem dhmensagem_env
          ,b.dhmensagem dhmensagem_rec
          ,a.nrseq_mensagem nrseq_mensagem_env
          ,b.nrseq_mensagem nrseq_mensagem_rec
      FROM tbspb_msg_enviada a
          ,tbspb_msg_recebida b
     WHERE b.nrseq_mensagem    = pr_nrseq_mensagem
       AND a.nrcontrole_if (+) = b.nrcontrole_if_env
       AND pr_idorigem         = 'R';


    CURSOR cr_layout_1(pr_nrseq_mensagem IN NUMBER
                      ,pr_idorigem       IN VARCHAR2) IS
      SELECT 'E' idorigem
            ,a.nrseq_mensagem
            ,a.dhmensagem
            ,a.nmmensagem
            ,a.nrcontrole_if nrcontrole
            ,a.nrcontrole_str_pag_rec nrcontrole_rec_env
            ,a.cdcooper
            ,a.vlmensagem VlrLanc
            ,TELA_LOGSPB.fn_define_situacao_enviada(a.nrseq_mensagem) insituac
            ,a.nrispb_deb ISPBIFDebtd
            ,sspb0003.fn_busca_conteudo_campo(c.dsxml_completo
                                             ,'AgDebtd'
                                             ,'C' ) AgDebtd
            ,TO_CHAR(a.nrdconta) CtDebtd
            ,TELA_LOGSPB.fn_define_cnpj_cpf_debito (pr_dsxml_completo => c.dsxml_completo) CNPJ_CPFCliDebtd
            ,TELA_LOGSPB.fn_define_nome_debito (pr_dsxml_completo => c.dsxml_completo) NomCliDebtd
            ,a.nrispb_cre ISPBIFCredtd
            ,sspb0003.fn_busca_conteudo_campo(c.dsxml_completo
                                             ,'AgCredtd'
                                             ,'C' ) AgCredtd
            ,TO_CHAR(sspb0003.fn_busca_conteudo_campo(c.dsxml_completo
                                                     ,'CtCredtd'
                                                     ,'C' )) CtCredtd
            ,TELA_LOGSPB.fn_define_cnpj_cpf_credito (pr_dsxml_completo => c.dsxml_completo) CNPJ_CPFCliCredtd
            ,TELA_LOGSPB.fn_define_nome_credito (pr_dsxml_completo => c.dsxml_completo) NomCliCredtd
            ,TELA_LOGSPB.fn_define_origem (a.nrcontrole_if
                              ,'DS'
                              ,b.cdfase) dsorigem
            ,DECODE(NVL(a.inestado_crise,0),0,'Não','Sim') inestado_crise
            ,c.dsxml_completo
            ,NULL nrdconta_migrada
            ,NULL cdcooper_migrada
        FROM tbspb_msg_enviada      a
            ,tbspb_msg_enviada_fase b
            ,tbspb_msg_xml          c
       WHERE a.nrseq_mensagem     = pr_nrseq_mensagem
         AND b.nrseq_mensagem     = a.nrseq_mensagem
         AND c.nrseq_mensagem_xml = b.nrseq_mensagem_xml
         AND b.cdfase            IN (10, 15, 992, 999)
         AND pr_idorigem          = 'E'
      UNION ALL
      SELECT 'R' idorigem
            ,a.nrseq_mensagem
            ,a.dhmensagem
            ,a.nmmensagem
            ,a.nrcontrole_str_pag nrcontrole
            ,a.nrcontrole_if_env nrcontrole_rec_env
            ,a.cdcooper
            ,a.vlmensagem VlrLanc
            ,TELA_LOGSPB.fn_define_situacao_recebida(a.nrseq_mensagem, a.nrcontrole_str_pag, a.nmmensagem) insituac
            ,a.nrispb_deb ISPBIFDebtd
            ,sspb0003.fn_busca_conteudo_campo(c.dsxml_completo
                                             ,'AgDebtd'
                                             ,'C' ) AgDebtd
            ,TO_CHAR(sspb0003.fn_busca_conteudo_campo(c.dsxml_completo
                                                     ,'CtDebtd'
                                                     ,'C' )) CtDebtd
            ,TELA_LOGSPB.fn_define_cnpj_cpf_debito (pr_dsxml_completo => c.dsxml_completo) CNPJ_CPFCliDebtd
            ,TELA_LOGSPB.fn_define_nome_debito (pr_dsxml_completo => c.dsxml_completo) NomCliDebtd
            ,a.nrispb_cre ISPBIFCredtd
            ,sspb0003.fn_busca_conteudo_campo(c.dsxml_completo
                                             ,'AgCredtd'
                                             ,'C' ) AgCredtd
            ,TO_CHAR(a.nrdconta) CtCredtd
            ,TELA_LOGSPB.fn_define_cnpj_cpf_credito (pr_dsxml_completo => c.dsxml_completo) CNPJ_CPFCliCredtd
            ,TELA_LOGSPB.fn_define_nome_credito (pr_dsxml_completo => c.dsxml_completo) NomCliCredtd
            ,NULL dsorigem
            ,DECODE(NVL(a.inestado_crise,0),0,'Não','Sim') inestado_crise
            ,c.dsxml_completo
            ,a.nrdconta_migrada
            ,a.cdcooper_migrada
        FROM tbspb_msg_recebida      a
            ,tbspb_msg_recebida_fase b
            ,tbspb_msg_xml           c
       WHERE a.nrseq_mensagem     = pr_nrseq_mensagem
         AND b.nrseq_mensagem     = a.nrseq_mensagem
         AND c.nrseq_mensagem_xml = b.nrseq_mensagem_xml
         AND b.cdfase            IN (115, 992, 999)
         AND pr_idorigem          = 'R';

    CURSOR cr_layout_2(pr_nrseq_mensagem IN NUMBER
                      ,pr_idorigem       IN VARCHAR2) IS
    SELECT b.cdfase
          ,b.nmmensagem
          ,d.nmfase
          ,b.dhmensagem
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 1),'><','>' || CHR(10) || '<') dsxml_completo_1
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 4001),'><','>' || CHR(10) || '<') dsxml_completo_2          
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 8001),'><','>' || CHR(10) || '<') dsxml_completo_3          
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 12001),'><','>' || CHR(10) || '<') dsxml_completo_4          
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 16001),'><','>' || CHR(10) || '<') dsxml_completo_5
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 20001),'><','>' || CHR(10) || '<') dsxml_completo_6
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 24001),'><','>' || CHR(10) || '<') dsxml_completo_7
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 28001),'><','>' || CHR(10) || '<') dsxml_completo_8      
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 32001),'><','>' || CHR(10) || '<') dsxml_completo_9      
          ,a.nrcontrole_str_pag_rec nrcontrole_dev
      FROM tbspb_msg_enviada a
          ,tbspb_msg_enviada_fase b
          ,tbspb_msg_xml c
          ,tbspb_fase_mensagem d
     WHERE a.nrseq_mensagem         = pr_nrseq_mensagem
       AND b.nrseq_mensagem         = a.nrseq_mensagem
       AND c.nrseq_mensagem_xml (+) = b.nrseq_mensagem_xml
       and b.cdfase                 = d.cdfase
       AND pr_idorigem              = 'E'
    UNION
    SELECT b.cdfase
          ,b.nmmensagem
          ,d.nmfase
          ,b.dhmensagem
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 1),'><','>' || CHR(10) || '<') dsxml_completo_1
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 4001),'><','>' || CHR(10) || '<') dsxml_completo_2          
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 8001),'><','>' || CHR(10) || '<') dsxml_completo_3          
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 12001),'><','>' || CHR(10) || '<') dsxml_completo_4          
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 16001),'><','>' || CHR(10) || '<') dsxml_completo_5
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 20001),'><','>' || CHR(10) || '<') dsxml_completo_6
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 24001),'><','>' || CHR(10) || '<') dsxml_completo_7
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 28001),'><','>' || CHR(10) || '<') dsxml_completo_8      
          ,REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 32001),'><','>' || CHR(10) || '<') dsxml_completo_9      
          ,nrcontrole_if_env nrcontrole_dev
      FROM tbspb_msg_recebida a
          ,tbspb_msg_recebida_fase b
          ,tbspb_msg_xml c
          ,tbspb_fase_mensagem d
     WHERE a.nrseq_mensagem         = pr_nrseq_mensagem
       AND b.nrseq_mensagem         = a.nrseq_mensagem
       AND c.nrseq_mensagem_xml (+) = b.nrseq_mensagem_xml
       AND b.cdfase                 = d.cdfase
       AND pr_idorigem              = 'R'
     ORDER BY dhmensagem, cdfase;

    vr_nrseq_mensagem_1 NUMBER;
    vr_nrseq_mensagem_3 NUMBER;
    vr_idorigem_1       VARCHAR2(100);
    vr_idorigem_3       VARCHAR2(100);
    vr_nrcontrole_dev   VARCHAR2(100);
    vr_contador         NUMBER;
    vr_dhmensagem       VARCHAR2(100);
    vr_dsdevolucao       craptab.dstextab%TYPE:= NULL;
    vr_xml_1            VARCHAR2(4000);
    vr_xml_2            VARCHAR2(4000);
    vr_xml_3            VARCHAR2(4000);
    vr_xml_4            VARCHAR2(4000);
    vr_xml_5            VARCHAR2(4000);
    vr_xml_6            VARCHAR2(4000);
    vr_xml_7            VARCHAR2(4000);
    vr_xml_8            VARCHAR2(4000);
    vr_xml_9            VARCHAR2(4000);    
    

    vr_exc_erro       EXCEPTION;
  BEGIN  -- Inicio pc_buscar_detalhe_msg
    gene0001.pc_informa_acesso(pr_module => 'LOGSPB'
                              ,pr_action => NULL);
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    --
    vr_nrseq_mensagem_1 := NULL;
    vr_nrseq_mensagem_3 := NULL;
    vr_idorigem_1       := NULL;
    vr_idorigem_3       := NULL;
    --
    FOR rw_ver_layout_1 IN cr_ver_layout_1(pr_nrseq_mensagem => pr_nrseq_mensagem
                                          ,pr_idorigem       => pr_idorigem) LOOP
      IF  rw_ver_layout_1.dhmensagem_env IS NOT NULL
      AND rw_ver_layout_1.dhmensagem_rec IS NOT NULL
      THEN
        IF rw_ver_layout_1.dhmensagem_env < rw_ver_layout_1.dhmensagem_rec THEN
          vr_nrseq_mensagem_1 := rw_ver_layout_1.nrseq_mensagem_env;
          vr_nrseq_mensagem_3 := rw_ver_layout_1.nrseq_mensagem_rec;
          vr_idorigem_1       := 'E';
          vr_idorigem_3       := 'R';
        ELSE
          vr_nrseq_mensagem_1 := rw_ver_layout_1.nrseq_mensagem_rec;
          vr_nrseq_mensagem_3 := rw_ver_layout_1.nrseq_mensagem_env;
          vr_idorigem_1       := 'R';
          vr_idorigem_3       := 'E';
        END IF;
      ELSE
        IF rw_ver_layout_1.dhmensagem_env IS NOT NULL THEN
          vr_nrseq_mensagem_1 := rw_ver_layout_1.nrseq_mensagem_env;
          vr_nrseq_mensagem_3 := rw_ver_layout_1.nrseq_mensagem_rec;
          vr_idorigem_1       := 'E';
          vr_idorigem_3       := 'R';
        ELSE
          vr_nrseq_mensagem_1 := rw_ver_layout_1.nrseq_mensagem_rec;
          vr_nrseq_mensagem_3 := rw_ver_layout_1.nrseq_mensagem_env;
          vr_idorigem_1       := 'R';
          vr_idorigem_3       := 'E';
        END IF;
      END IF;
    END LOOP;
    --
    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'layout_1'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);
    --
    vr_contador := 0;
    --
    FOR rw_layout_1 IN cr_layout_1 (pr_nrseq_mensagem => vr_nrseq_mensagem_1
                                   ,pr_idorigem       => vr_idorigem_1) LOOP
      -- buscar cooperativa
      OPEN cr_crapcop (NVL(rw_layout_1.cdcooper,3));
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se não existe
      IF cr_crapcop%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_crapcop;
          -- Gera crítica
          vr_cdcritic := 0;
          vr_dscritic := 'Cooperativa não encontrada na CRAPCOP!';
          -- Levanta exceção
          RAISE vr_exc_erro;
      END IF;
      -- Fecha cursor
      CLOSE cr_crapcop;
      vr_nmrescop := rw_crapcop.nmrescop;
      --
      IF rw_layout_1.cdcooper_migrada IS NOT NULL THEN
        OPEN cr_crapcop (NVL(rw_layout_1.cdcooper,3));
        FETCH cr_crapcop INTO rw_crapcop;
        -- Se não existe
        IF cr_crapcop%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_crapcop;
            -- Gera crítica
            vr_cdcritic := 0;
            vr_dscritic := 'Cooperativa migrada não encontrada na CRAPCOP!';
            -- Levanta exceção
            RAISE vr_exc_erro;
        END IF;
        -- Fecha cursor
        CLOSE cr_crapcop;
        vr_nmrescop_migrada := rw_crapcop.nmrescop;
      ELSE
        vr_nmrescop_migrada := NULL;
      END IF;
      --
      IF rw_layout_1.nmmensagem <> 'SLC0001' THEN
        -- buscar bancos
        OPEN cr_crapban (rw_layout_1.ISPBIFDebtd);
        FETCH cr_crapban INTO rw_crapban;
        -- Se não existe
        IF cr_crapban%NOTFOUND THEN
            vr_bancoremet := null;
        ELSE
            vr_bancoremet := rw_crapban.nmresbcc;
        END IF;
          -- Fecha cursor
        CLOSE cr_crapban;
        --
        --
        OPEN cr_crapban (rw_layout_1.ISPBIFCredtd);
        FETCH cr_crapban INTO rw_crapban;
        -- Se não existe
        IF cr_crapban%NOTFOUND THEN
          vr_bancodest := NULL;
        ELSE
           vr_bancodest := rw_crapban.nmresbcc;
        END IF;
        -- Fecha cursor
        CLOSE cr_crapban;
        --
        -- Tratar caracteres especiais vindos no xml (geram erro ao converter o clob no xml)
        rw_layout_1.NomCliDebtd := TRIM(Replace(rw_layout_1.NomCliDebtd,'&AMP;','&')); 
        rw_layout_1.NomCliDebtd := TRIM(Replace(rw_layout_1.NomCliDebtd,'&APOS;','''')); 
        rw_layout_1.NomCliDebtd := TRIM(Replace(rw_layout_1.NomCliDebtd,'&LT;','<')); 
        rw_layout_1.NomCliDebtd := TRIM(Replace(rw_layout_1.NomCliDebtd,'&GT;','>')); 
        rw_layout_1.NomCliDebtd := TRIM(Replace(rw_layout_1.NomCliDebtd,'&QUOT;','"'));                   
        --
        rw_layout_1.NomCliCredtd := TRIM(Replace(rw_layout_1.NomCliCredtd,'&AMP;','&')); 
        rw_layout_1.NomCliCredtd := TRIM(Replace(rw_layout_1.NomCliCredtd,'&APOS;','''')); 
        rw_layout_1.NomCliCredtd := TRIM(Replace(rw_layout_1.NomCliCredtd,'&LT;','<')); 
        rw_layout_1.NomCliCredtd := TRIM(Replace(rw_layout_1.NomCliCredtd,'&GT;','>')); 
        rw_layout_1.NomCliCredtd := TRIM(Replace(rw_layout_1.NomCliCredtd,'&QUOT;','"')); 
      ELSE
        rw_layout_1.AgCredtd := null;
        rw_layout_1.CtCredtd:= null;
        rw_layout_1.AgDebtd  := null;
        rw_layout_1.CtDebtd := null;
        rw_layout_1.NomCliDebtd:= null;
        rw_layout_1.CNPJ_CPFCliDebtd:= null;
        rw_layout_1.CNPJ_CPFCliCredtd:= null;
        rw_layout_1.NomCliCredtd:= null;
        rw_layout_1.dsxml_completo:= null;
      END IF;
      --
      -- buscar caixa/operador
      IF rw_layout_1.idorigem = 'E' THEN
        OPEN cr_craptvl (NVL(rw_layout_1.cdcooper,3)
                        ,rw_layout_1.nrcontrole);
        FETCH cr_craptvl INTO rw_craptvl;
        -- Se não existe
        IF cr_craptvl%NOTFOUND THEN
          rw_craptvl.cdbccxlt := NULL;
          rw_craptvl.cdoperad := NULL;
        END IF;
        -- Fecha cursor
        CLOSE cr_craptvl;
        --
        If rw_layout_1.insituac in ('DEVOLVIDA','EM DEVOLUÇÃO') Then
           --
           vr_dsdevolucao := fn_busca_devolucao (rw_layout_1.nrcontrole,'E');
           --
        End If;
      ELSE
        rw_craptvl.cdbccxlt := NULL;
        rw_craptvl.cdoperad := NULL;
        If rw_layout_1.insituac in ('DEVOLVIDA','EM DEVOLUÇÃO') Then
           --
           vr_dsdevolucao := fn_busca_devolucao (rw_layout_1.nrcontrole,'R');
           --
        End If;
        --
        If rw_layout_1.cdcooper_migrada IS NOT NULL  then
           Begin 
             Select cop.cdagectl 
             Into rw_layout_1.AgCredtd
             From Crapcop cop
             Where cop.cdcooper = rw_layout_1.cdcooper;
           Exception
             When others Then
                 rw_layout_1.AgCredtd := null;
           End;     
        End If;                   
      END IF;
      --
      --Escrever no XML
      --
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'layout_1',pr_posicao  => 0,pr_tag_nova => 'item1',pr_tag_cont => null,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'idorigem'      ,pr_tag_cont => rw_layout_1.idorigem,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'nrseq_mensagem',pr_tag_cont => rw_layout_1.nrseq_mensagem,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'datamsg'       ,pr_tag_cont => TO_CHAR(rw_layout_1.dhmensagem,'dd-mm-yyyy hh24:mi:ss'),pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'dsmensagem'    ,pr_tag_cont => rw_layout_1.nmmensagem,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'numcontrole'   ,pr_tag_cont => rw_layout_1.nrcontrole,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'valor'         ,pr_tag_cont => 
      TRIM(TO_CHAR(rw_layout_1.VlrLanc,'FM99G999G999G990D00')),pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'situacao'      ,pr_tag_cont => rw_layout_1.insituac,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'bancoremet'    ,pr_tag_cont => TRIM(vr_bancoremet),pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'agenciaremet'  ,pr_tag_cont => TRIM(rw_layout_1.AgDebtd),pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'contaremet'    ,pr_tag_cont => TRIM(gene0002.fn_mask_conta(pr_nrdconta => rw_layout_1.CtDebtd)),pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'cooperativa'   ,pr_tag_cont => vr_nmrescop,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'nomeremet'     ,pr_tag_cont => TRIM(rw_layout_1.NomCliDebtd),pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'cpfcnpjremet'  ,pr_tag_cont => TRIM(rw_layout_1.CNPJ_CPFCliDebtd),pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'bancodest'     ,pr_tag_cont => TRIM(vr_bancodest),pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'agenciadest'   ,pr_tag_cont => TRIM(rw_layout_1.AgCredtd),pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'contadest'     ,pr_tag_cont => TRIM(gene0002.fn_mask(pr_dsorigi => rw_layout_1.CtCredtd, pr_dsforma => 'zzzzzzzzzzzzzz.zzz.z')),pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'nomedest'      ,pr_tag_cont => TRIM(rw_layout_1.NomCliCredtd),pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'cpfcnpjdest'   ,pr_tag_cont => rw_layout_1.CNPJ_CPFCliCredtd,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'origem'        ,pr_tag_cont => rw_layout_1.dsorigem,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'motdev'         ,pr_tag_cont => vr_dsdevolucao,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'caixa'         ,pr_tag_cont => rw_craptvl.cdbccxlt,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'operador'      ,pr_tag_cont => rw_craptvl.cdoperad,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'crise'         ,pr_tag_cont => rw_layout_1.inestado_crise,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'coopmigrada'   ,pr_tag_cont => TRIM(vr_nmrescop_migrada),pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'nrcontamigrada',pr_tag_cont => TRIM(gene0002.fn_mask_conta(pr_nrdconta => rw_layout_1.nrdconta_migrada)),pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item1',pr_posicao => vr_contador,pr_tag_nova => 'dsxml_completo',pr_tag_cont => rw_layout_1.dsxml_completo,pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    END LOOP;
    --
    IF vr_contador > 0 THEN
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'layout_1'          --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_contador         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
    END IF;
    --
    --
    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'layout_2'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);
    --
    vr_contador := 0;
    FOR rw_layout_2 IN cr_layout_2 (pr_nrseq_mensagem => vr_nrseq_mensagem_1
                                   ,pr_idorigem       => vr_idorigem_1) LOOP
                                   
      vr_dhmensagem := TO_CHAR(rw_layout_2.dhmensagem,'dd-mm-yyyy hh24:mi:ss');
      --Escrever no XML
      vr_xml_1 := rw_layout_2.dsxml_completo_1;
      vr_xml_2 := rw_layout_2.dsxml_completo_2;
      vr_xml_3 := rw_layout_2.dsxml_completo_3;
      vr_xml_4 := rw_layout_2.dsxml_completo_4;
      vr_xml_5 := rw_layout_2.dsxml_completo_5;
      vr_xml_6 := rw_layout_2.dsxml_completo_6;
      vr_xml_7 := rw_layout_2.dsxml_completo_7;
      vr_xml_8 := rw_layout_2.dsxml_completo_8;
      vr_xml_9 := rw_layout_2.dsxml_completo_9;
      
      --
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'layout_2',pr_posicao => 0          ,pr_tag_nova => 'item'    ,pr_tag_cont => null                      ,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item'    ,pr_posicao => vr_contador,pr_tag_nova => 'cdfase'  ,pr_tag_cont => rw_layout_2.cdfase        ,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item'    ,pr_posicao => vr_contador,pr_tag_nova => 'nmfase'  ,pr_tag_cont => rw_layout_2.nmmensagem    ,pr_des_erro => vr_dscritic);
      --REQ66
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item'    ,pr_posicao => vr_contador,pr_tag_nova => 'dscompl'  ,pr_tag_cont => UPPER(rw_layout_2.nmfase)        ,pr_des_erro => vr_dscritic);
      --
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item'    ,pr_posicao => vr_contador,pr_tag_nova => 'datafase',pr_tag_cont => vr_dhmensagem             ,pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item'    ,pr_posicao => vr_contador,pr_tag_nova => 'xmlfase' ,pr_tag_cont => vr_xml_1||vr_xml_2||vr_xml_3||vr_xml_4||vr_xml_5||vr_xml_6||vr_xml_7||vr_xml_8||vr_xml_9,pr_des_erro => vr_dscritic);
      vr_nrcontrole_dev := rw_layout_2.nrcontrole_dev;
      vr_contador       := vr_contador + 1;
    END LOOP;
    --
    IF vr_contador > 0 THEN
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'layout_2'          --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_contador         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
    END IF;
    --
    IF vr_nrseq_mensagem_3 IS NOT NULL THEN
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'layout_3'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      vr_contador := 0;
      --
      FOR rw_layout_3 IN (SELECT dhmensagem
                                ,nmmensagem
                                ,nrseq_mensagem
                            FROM tbspb_msg_enviada
                           WHERE nrseq_mensagem = vr_nrseq_mensagem_3
                             AND vr_idorigem_3  = 'E'
                           UNION
                          SELECT dhmensagem
                                ,nmmensagem
                                ,nrseq_mensagem
                            FROM tbspb_msg_recebida
                           WHERE nrseq_mensagem = vr_nrseq_mensagem_3
                             AND vr_idorigem_3  = 'R')
      LOOP
        vr_dhmensagem := TO_CHAR(rw_layout_3.dhmensagem,'dd-mm-yyyy hh24:mi:ss');
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'layout_3',pr_posicao => 0          ,pr_tag_nova => 'item3'               ,pr_tag_cont => null                   ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item3'   ,pr_posicao => vr_contador,pr_tag_nova => 'datamsg'             ,pr_tag_cont => vr_dhmensagem          ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item3'   ,pr_posicao => vr_contador,pr_tag_nova => 'mensagem'            ,pr_tag_cont => rw_layout_3.nmmensagem ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item3'   ,pr_posicao => vr_contador,pr_tag_nova => 'numcontroledevolucao',pr_tag_cont => vr_nrcontrole_dev      ,pr_des_erro => vr_dscritic);
      END LOOP;
      --
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'layout_3'          --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_contador         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
      --
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'layout_4'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      vr_contador := 0;
      --
      FOR rw_layout_4 IN (SELECT a.cdfase
                                ,a.nmmensagem
                                ,a.dhmensagem
                                ,c.nmfase
                                ,REPLACE(REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 1),'><','>' || CHR(10) || '<'),' ','') dsxml_completo
                            FROM tbspb_msg_enviada_fase a
                                ,tbspb_msg_xml b
                                ,tbspb_fase_mensagem c
                           WHERE nrseq_mensagem           = vr_nrseq_mensagem_3
                             AND b.nrseq_mensagem_xml (+) = a.nrseq_mensagem_xml
                             AND a.cdfase                 = c.cdfase
                             AND vr_idorigem_3            = 'E'
                           UNION ALL
                          SELECT a.cdfase
                                ,a.nmmensagem
                                ,a.dhmensagem
                                ,c.nmfase
                                ,REPLACE(REPLACE(DBMS_LOB.SUBSTR(dsxml_completo, 4000, 1),'><','>' || CHR(10) || '<'),' ','') dsxml_completo
                           FROM tbspb_msg_recebida_fase a
                               ,tbspb_msg_xml b
                               ,tbspb_fase_mensagem c
                          WHERE nrseq_mensagem           = vr_nrseq_mensagem_3
                            AND b.nrseq_mensagem_xml (+) = a.nrseq_mensagem_xml
                            AND a.cdfase                 = c.cdfase
                            AND vr_idorigem_3            = 'R'
                           ORDER BY cdfase)
      LOOP
        vr_dhmensagem := TO_CHAR(rw_layout_4.dhmensagem,'dd-mm-yyyy hh24:mi:ss');
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'layout_4',pr_posicao => 0          ,pr_tag_nova => 'item4'   ,pr_tag_cont => null                      ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item4'   ,pr_posicao => vr_contador,pr_tag_nova => 'cdfase'  ,pr_tag_cont => rw_layout_4.cdfase        ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item4'   ,pr_posicao => vr_contador,pr_tag_nova => 'nmfase'  ,pr_tag_cont => rw_layout_4.nmmensagem    ,pr_des_erro => vr_dscritic);
        --REQ66
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item4'    ,pr_posicao => vr_contador,pr_tag_nova => 'dscompl' ,pr_tag_cont => UPPER(rw_layout_4.nmfase)        ,pr_des_erro => vr_dscritic);
        --
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item4'   ,pr_posicao => vr_contador,pr_tag_nova => 'datafase',pr_tag_cont => vr_dhmensagem             ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'item4'   ,pr_posicao => vr_contador,pr_tag_nova => 'xmlfase' ,pr_tag_cont => rw_layout_4.dsxml_completo,pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
      END LOOP;
      --
      IF vr_contador > 0 THEN
        -- Insere atributo na tag Dados com a quantidade de registros
        gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                                 ,pr_tag   => 'layout_4'          --> Nome da TAG XML
                                 ,pr_atrib => 'qtregist'          --> Nome do atributo
                                 ,pr_atval => vr_contador         --> Valor do atributo
                                 ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                                 ,pr_des_erro => vr_dscritic);    --> Descrição de erros
      END IF;
    END IF;
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_LOGSPB.pc_buscar_detalhe_msg --> ' ||SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_buscar_detalhe_msg;
END TELA_LOGSPB;
/
