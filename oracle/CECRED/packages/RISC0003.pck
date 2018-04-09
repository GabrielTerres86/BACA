CREATE OR REPLACE PACKAGE CECRED.RISC0003 is

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RISC0003
  --  Sistema  : Rotinas para Riscos de Garantia e Provisão
  --  Sigla    : RISC
  --  Autor    : Andrei Vieira - MOUTs
  --  Data     : Abril/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas genericas para tratamento de Produtos e Contratos de Riscos
  --             das operações das Filiadas na Central
  --
  -- Atualizações: 09/04/2018 - Incluída procedure para cálculo dos dados Brutos do Risco - Daniel(AMcom)
  --                            pc_risco_central_ocr - tabela TBRISCO_CENTRAL_OCR
  --
  ---------------------------------------------------------------------------------------------------------------

  ----------------------------- TIPOS E REGISTROS -------------------------

    -- Registro dos riscos
    TYPE typ_risco IS
      RECORD(cdcooper       tbcrd_risco.cdcooper%TYPE
            ,nrdconta       tbcrd_risco.nrdconta%TYPE
            ,nrcontrato     tbcrd_risco.nrcontrato%TYPE
            ,nrseqctr       crapris.nrseqctr%TYPE
            ,cdagencia      crapris.cdagenci%TYPE
            ,nrmodalidade   tbcrd_risco.nrmodalidade%TYPE
            ,dtcadastro     tbcrd_risco.dtcadastro%TYPE
            ,dtvencimento   tbcrd_risco.dtvencimento%TYPE
            ,innivris       crapris.innivris%TYPE
            ,vldivida       crapris.vldivida%TYPE
            ,inpessoa       crapris.inpessoa%TYPE
            ,dtvencop       crapris.dtvencop%TYPE
            ,qtdiaatr       crapris.qtdiaatr%TYPE
            ,nrcpfcgc       crapris.nrcpfcgc%TYPE
            ,dtprxpar       crapris.dtprxpar%TYPE
            ,vlprxpar       crapris.vlprxpar%TYPE
            ,qtparcel       crapris.qtparcel%TYPE
            ,vlvec180       crapris.vlvec180%TYPE
            ,vlvec360       crapris.vlvec360%TYPE
            ,vlvec999       crapris.vlvec999%TYPE
            ,vldiv060       crapris.vldiv060%TYPE
            ,vldiv180       crapris.vldiv180%TYPE
            ,vldiv360       crapris.vldiv360%TYPE
            ,vldiv999       crapris.vldiv999%TYPE
            ,vlprjano       crapris.vlprjano%TYPE
            ,vlprjaan       crapris.vlprjaan%TYPE
            ,vlprjant       crapris.vlprjant%TYPE
            ,cdinfadi       crapris.cdinfadi%TYPE
            ,dsinfaux       crapris.dsinfaux%TYPE
            ,flgindiv       crapris.flgindiv%TYPE);

    -- Definição de um tipo de tabela com o registro acima
    TYPE typ_tab_risco IS
      TABLE OF typ_risco
        INDEX BY VARCHAR2(60);

    -- Registro dos riscos
    TYPE typ_risco_venc IS
      RECORD(cdcooper       tbcrd_risco.cdcooper%TYPE
            ,nrdconta       tbcrd_risco.nrdconta%TYPE
            ,nrcontrato     tbcrd_risco.nrcontrato%TYPE
            ,nrseqctr       crapris.nrseqctr%TYPE
            ,nrmodalidade   tbcrd_risco.nrmodalidade%TYPE
            ,cdvencto       crapvri.cdvencto%TYPE
            ,innivris       crapvri.innivris%TYPE
            ,vldivida       crapvri.vldivida%TYPE);

    -- Definição de um tipo de tabela com o registro acima
    TYPE typ_tab_risco_venc IS
      TABLE OF typ_risco_venc
        INDEX BY VARCHAR2(70);

      TYPE typ_tab_risco_temp IS
        TABLE OF typ_risco
          INDEX BY PLS_INTEGER;

      TYPE typ_tab_risco_venc_temp IS
        TABLE OF typ_risco_venc
          INDEX BY PLS_INTEGER;



  -- Busca da configuração do produto
  CURSOR cr_prod(pr_idproduto tbrisco_provisgarant_prodt.idproduto%TYPE) IS
    SELECT pr.*
      FROM tbrisco_provisgarant_prodt pr
     WHERE pr.idproduto = pr_idproduto;

  -- Função que irá retornar se o operador poderá fazer alterações no período informado
  FUNCTION fn_periodo_habilitado(pr_cdcooper  IN NUMBER
                                ,pr_dtbase    IN DATE
                                ,pr_prmfinan IN BOOLEAN DEFAULT TRUE) RETURN NUMBER;
  -- Calculo do nivel de risco
  FUNCTION fn_calcula_nivel_risco(pr_dsnivris IN VARCHAR2) RETURN NUMBER;

  -- Calculo do nivel de risco
  FUNCTION fn_nivel_risco(pr_aux_nivel IN NUMBER) RETURN VARCHAR2;

  -- Trazer o tamanho do valor do domínio
  FUNCTION fn_tamanho_dominio(pr_idtipo_dominio IN NUMBER) RETURN NUMBER;

  -- Trazer o valor a ser visualizado da opção de domínio repassada
  FUNCTION fn_valor_opcao_dominio(pr_iddominio NUMBER) RETURN VARCHAR2;

  -- Trazer o valor a ser visualizado da opção de domínio repassada
  FUNCTION fn_descri_opcao_dominio(pr_iddominio NUMBER) RETURN VARCHAR2;

  -- Buscar o valor (id interno) da opção selecioado para a tabela e valor do domínio passado como parâmetro
  FUNCTION fn_busca_iddominio(pr_idtipo_dominio IN NUMBER
                             ,pr_dsvlrdom       IN VARCHAR2) RETURN VARCHAR2;

  -- Criar os contratos novos na virada de mês para os produtos que permitirem
  PROCEDURE pc_cria_contratos_novo_mes(pr_cdcooper  IN NUMBER
                                      ,pr_idproduto IN NUMBER
                                      ,pr_dtbase    IN DATE
                                      ,pr_dscritic OUT varchar2);

  -- Criar novo procedimento que irá gerar as informações do movimento para CSV
  PROCEDURE pc_exporta_dados_csv(pr_dtbase    IN DATE
                                ,pr_dsarquiv OUT CLOB
                                ,pr_dscritic OUT varchar2);

  -- Gerar as importar as informações de movimento conforme arquivo passado
  PROCEDURE pc_importa_arquivo(pr_cdcooper  IN NUMBER
                              ,pr_idproduto IN NUMBER
                              ,pr_dtbase    IN DATE
                              ,pr_dsinform OUT VARCHAR2
                              ,pr_dscritic OUT VARCHAR2);

  /* Arrastar o risco dos contratos após integração inddocto=5 */
  PROCEDURE pc_efetua_arrasto_docto5(pr_cdcooper IN crapcop.cdcooper%TYPE  --> codigo da cooperativa
                                    ,pr_dtrefere IN DATE                   --> Data de Referencia
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da critica
                                    ,pr_dscritic OUT VARCHAR2);          --> Descricao da critica

  -- Gerar riscos da tabela de movimento para a tabela de risco
  PROCEDURE pc_fecham_risco_garantia_prest(pr_cdcooper   IN crapcop.cdcooper%TYPE        --> codigo da cooperativa
                                          ,pr_dtrefere   IN DATE                         --> Data de Referencia
                                          ,pr_cdcritic   OUT PLS_INTEGER                 --> Código da critica
                                          ,pr_dscritic   OUT VARCHAR2);                  --> Descricao da crit

  /* Reabrir a digitação dos contratos de risco com base nas informações cadastradas ou importadas na tela MOVRGP */
  PROCEDURE pc_reabre_risco_garantia_prest(pr_cdcooper   IN crapcop.cdcooper%TYPE        --> codigo da cooperativa
                                          ,pr_dtrefere   IN DATE                         --> Data de Referencia
                                          ,pr_cdcritic   OUT PLS_INTEGER                 --> Código da critica
                                          ,pr_dscritic   OUT VARCHAR2);                  --> Descricao da critica

  PROCEDURE pc_risco_central_ocr(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa
                                ,pr_cdcritic OUT PLS_INTEGER            --> Critica encontrada
                                ,pr_dscritic OUT VARCHAR2);             --> Texto de erro/critica encontrada                                          

END RISC0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.RISC0003 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RISC0003
  --  Sistema  : Rotinas para Riscos de Garantia e Provisão
  --  Sigla    : RISC
  --  Autor    : Andrei Vieira - MOUTs
  --  Data     : Abril/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas genericas para tratamento de Produtos e Contratos de Riscos
  --             das operações das Filiadas na Central
  --
  -- Atualizações: 09/04/2018 - Incluída procedure para cálculo dos dados Brutos do Risco - Daniel(AMcom)
  --                            pc_risco_central_ocr - tabela TBRISCO_CENTRAL_OCR
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Cursor Generico para busca das informações dos domínios
  CURSOR cr_dominio(pr_iddominio IN NUMBER) IS
    SELECT opc.cddominio
          ,opc.dsdominio
          ,opc.cdsubdominio
          ,opc.dssubdominio
          ,tab.cdtamanho_dominio
          ,tab.flpossui_subdominio
          ,tab.cdtamanho_subdominio
      FROM tbrisco_dominio_tipo tab
          ,tbrisco_dominio      opc
     WHERE opc.idtipo_dominio       = tab.idtipo_dominio
       AND opc.iddominio            = pr_iddominio;
  rw_dominio cr_dominio%ROWTYPE;

  -- Cursor Generico para busca das informações dos domínios
  CURSOR cr_dominio_tipo(pr_idtipo_dominio IN NUMBER) IS
    SELECT tab.cdtamanho_dominio
          ,tab.flpossui_subdominio
          ,tab.cdtamanho_subdominio
      FROM tbrisco_dominio_tipo tab
     WHERE tab.idtipo_dominio = pr_idtipo_dominio;
  rw_dominio_tipo cr_dominio_tipo%ROWTYPE;

  -- Buscar todos os contratos criados
  CURSOR cr_crapris (pr_cdcooper  IN crapris.cdcooper%TYPE
                    ,pr_dtrefere  IN crapris.dtrefere%TYPE
                    ,pr_vlarrasto IN NUMBER) IS
    SELECT cdcooper
          ,nrdconta
          ,nrctremp
          ,cdmodali
          ,dtrefere
          ,innivori
          ,nrseqctr
          ,qtdiaatr
          ,innivris
          ,rowid
          ,ROW_NUMBER () OVER (PARTITION BY nrdconta
                                   ORDER BY nrdconta,innivris DESC) sequencia
      FROM crapris
     WHERE cdcooper = pr_cdcooper
       AND dtrefere = pr_dtrefere
       AND inddocto IN(1,5)
       AND vldivida > pr_vlarrasto --> Valor dos parâmetros
  ORDER BY nrdconta
          ,innivris DESC;

  -- Buscar o pior risco para a conta
  CURSOR cr_crapris_last(pr_cdcooper IN crapris.cdcooper%TYPE
                        ,pr_nrdconta IN crapris.nrdconta%TYPE
                        ,pr_dtrefere IN crapris.dtrefere%TYPE
                        ,pr_vlarrast IN crapris.vldivida%TYPE) IS
    SELECT /*+index_desc (crapris CRAPRIS##CRAPRIS1)*/
           innivris
      FROM crapris
     WHERE crapris.cdcooper = pr_cdcooper
       AND crapris.nrdconta = pr_nrdconta
       AND crapris.dtrefere = pr_dtrefere
       AND crapris.inddocto IN(1,5)
       AND (crapris.vldivida > pr_vlarrast OR pr_vlarrast = 0);
  rw_crapris_last cr_crapris_last%ROWTYPE;

  -- Buscar risco de grupo econônomico
  CURSOR cr_crapgrp(pr_cdcooper IN crapgrp.cdcooper%TYPE
                   ,pr_nrctasoc IN crapgrp.nrctasoc%TYPE) IS
    SELECT crapgrp.innivrge,
           crapgrp.nrdgrupo
      FROM crapgrp
     WHERE crapgrp.cdcooper = pr_cdcooper
       AND crapgrp.nrctasoc = pr_nrctasoc;
  rw_crapgrp cr_crapgrp%ROWTYPE;


  -- Função que irá retornar se o operador poderá fazer alterações no período informado
  FUNCTION fn_periodo_habilitado(pr_cdcooper IN NUMBER
                                ,pr_dtbase   IN DATE
                                ,pr_prmfinan IN BOOLEAN DEFAULT TRUE) RETURN NUMBER IS
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : fn_periodo_habilitado
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Andrei Vieira - Mouts
    --  Data     : Abril/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Função que irá retornar se o operador poderá fazer alterações no período informado
    --
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      -- Busca TAB
      vr_dstextab craptab.dstextab%TYPE;
      -- Busca DAT
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    BEGIN
      -- Busca calendário
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      -- Busca registro risco
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                                pr_nmsistem => 'CRED',
                                                pr_tptabela => 'USUARI',
                                                pr_cdempres => 11,
                                                pr_cdacesso => 'RISCOBACEN',
                                                pr_tpregist => 000);
      -- Somente liberar se posição 1 = 0
      -- e a data solicitada for igual ao mês anterior
      -- e o parâmetro de sistema que libera a digitação financiera estiver ativo (Se solicitado)
      IF SUBSTR(vr_dstextab,1,1) = '0' AND pr_dtbase = rw_crapdat.dtultdma
      AND (NOT pr_prmfinan OR gene0001.fn_param_sistema('CRED',pr_cdcooper,'DIGIT_RISCO_FINAN_LIBERA') = 1) THEN
        -- Liberado
        RETURN 1;
      ELSE
        -- Não liberado
        RETURN 0;
      END IF;
    END;
  END fn_periodo_habilitado;

  -- Calculo do nivel de risco
  FUNCTION fn_calcula_nivel_risco(pr_dsnivris IN VARCHAR2) RETURN NUMBER IS
    vr_aux_nivel INTEGER;
  BEGIN
    -- Vamos verificar qual nivel de risco esta na proposto do emprestimo
    CASE
      WHEN pr_dsnivris = ' '  THEN
        vr_aux_nivel := 2;
      WHEN pr_dsnivris = 'AA' THEN
        vr_aux_nivel := 1;
      WHEN pr_dsnivris = 'A'  THEN
        vr_aux_nivel := 2;
      WHEN pr_dsnivris = 'B'  THEN
        vr_aux_nivel := 3;
      WHEN pr_dsnivris = 'C'  THEN
        vr_aux_nivel := 4;
      WHEN pr_dsnivris = 'D'  THEN
        vr_aux_nivel := 5;
      WHEN pr_dsnivris = 'E'  THEN
        vr_aux_nivel := 6;
      WHEN pr_dsnivris = 'F'  THEN
        vr_aux_nivel := 7;
      WHEN pr_dsnivris = 'G'  THEN
        vr_aux_nivel := 8;
      ELSE
        vr_aux_nivel := 9;
    END CASE;

    RETURN vr_aux_nivel;
  END;

  -- Calculo do nivel de risco
  FUNCTION fn_nivel_risco(pr_aux_nivel IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    -- Vamos verificar qual nivel de risco esta na proposto do emprestimo
    CASE
      WHEN nvl(pr_aux_nivel,0) IN(0,2) THEN
        RETURN 'A';
      WHEN pr_aux_nivel = 1 THEN
        RETURN 'AA';
      WHEN pr_aux_nivel = 3  THEN
        RETURN 'B';
      WHEN pr_aux_nivel = 4 THEN
        RETURN 'C';
      WHEN pr_aux_nivel = 5  THEN
        RETURN 'D';
      WHEN pr_aux_nivel = 6 THEN
        RETURN 'E';
      WHEN pr_aux_nivel = 7 THEN
        RETURN 'F';
      WHEN pr_aux_nivel = 8 THEN
        RETURN 'G';
      ELSE
        RETURN 'H';
    END CASE;

    RETURN 'A';
  END;

  -- Trazer o tamanho do valor do domínio
  FUNCTION fn_tamanho_dominio(pr_idtipo_dominio IN NUMBER) RETURN NUMBER IS
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : fn_tamanho_dominio
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Andrei Vieira - Mouts
    --  Data     : Junho/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Trazer o tamanho do valor do domínio
    --
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_qtvalorop NUMBER;
    BEGIN
      -- Buscar as informações do domínio
      OPEN cr_dominio_tipo(pr_idtipo_dominio);
      FETCH cr_dominio_tipo
       INTO rw_dominio_tipo;
      -- Se por ventura a consulta não retornar nenhum registro então sairemos retornando 0;
      IF cr_dominio_tipo%NOTFOUND THEN
        CLOSE cr_dominio_tipo;
        RETURN 0;
      ELSE
        CLOSE cr_dominio_tipo;
        -- Começar a conta pelo domínio:
        vr_qtvalorop := rw_dominio_tipo.cdtamanho_dominio;
        -- Se tabela possui subdomínio, então adicionamos seu tamanho
        IF rw_dominio_tipo.flpossui_subdominio = 1 THEN
          vr_qtvalorop := vr_qtvalorop + rw_dominio_tipo.cdtamanho_subdominio;
        END IF;
        -- Ao final, retornar a string montada:
        RETURN vr_qtvalorop;
      END IF;
    END;
  END fn_tamanho_dominio;


  -- Trazer o valor a ser visualizado da opção de domínio repassada
  FUNCTION fn_valor_opcao_dominio(pr_iddominio NUMBER) RETURN VARCHAR2 IS
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : fn_valor_opcao_dominio
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Andrei Vieira - Mouts
    --  Data     : Abril/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Trazer o valor a ser visualizado da opção de domínio repassada
    --
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_dsvalorop VARCHAR2(20);
    BEGIN
      -- Buscar as informações do domínio
      OPEN cr_dominio(pr_iddominio);
      FETCH cr_dominio
       INTO rw_dominio;
      -- Se por ventura a consulta não retornar nenhum registro então sairemos retornando 0;
      IF cr_dominio%NOTFOUND THEN
        CLOSE cr_dominio;
        RETURN ' ';
      ELSE
        CLOSE cr_dominio;
        -- Começar a montagem do valor pelo domínio:
        vr_dsvalorop := lpad(rw_dominio.cddominio,rw_dominio.cdtamanho_dominio,'0');
        -- Se tabela possui subdomínio, então adicionário a resposta:
        IF rw_dominio.flpossui_subdominio = 1 THEN
          vr_dsvalorop := vr_dsvalorop
                       || lpad(rw_dominio.cdsubdominio,rw_dominio.cdtamanho_subdominio,'0');
        END IF;
        -- Ao final, retornar a string montada:
        RETURN vr_dsvalorop;
      END IF;
    END;
  END fn_valor_opcao_dominio;


  -- Trazer a descrição a ser visualizado da opção de domínio repassada
  FUNCTION fn_descri_opcao_dominio(pr_iddominio NUMBER) RETURN VARCHAR2 IS
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : fn_descri_opcao_dominio
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Andrei Vieira - Mouts
    --  Data     : Abril/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Trazer a descrição a ser visualizado da opção de domínio repassada
    --
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_dsdescop VARCHAR2(600);
    BEGIN
      -- Buscar as informações do domínio
      OPEN cr_dominio(pr_iddominio);
      FETCH cr_dominio
       INTO rw_dominio;
      -- Se por ventura a consulta não retornar nenhum registro então sairemos retornando ---
      IF cr_dominio%NOTFOUND THEN
        CLOSE cr_dominio;
        RETURN '---';
      ELSE
        CLOSE cr_dominio;
        -- Começar a montagem pelo domínio:
        vr_dsdescop := rw_dominio.dsdominio;
        -- Se tabela possui subdomínio, então adicionário a resposta:
        IF rw_dominio.flpossui_subdominio = 1 THEN
          vr_dsdescop := vr_dsdescop
                      || '/' || rw_dominio.dssubdominio;
        END IF;
      END IF;
      -- Ao final, retornar a string montada:
      RETURN vr_dsdescop;
    END;
  END fn_descri_opcao_dominio;

  -- Buscar o valor (id interno) da opção selecioado para a tabela e valor do domínio passado como parâmetro
  FUNCTION fn_busca_iddominio(pr_idtipo_dominio IN NUMBER
                             ,pr_dsvlrdom       IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : fn_busca_iddominio
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Andrei Vieira - Mouts
    --  Data     : Abril/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Buscar o valor (id interno) da opção selecioado para a tabela e valor do domínio passado como parâmetro
    --
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Varredura dos valores da tabela passada
      CURSOR cr_vlrdom IS
        SELECT iddominio
          FROM tbrisco_dominio
         WHERE idtipo_dominio = pr_idtipo_dominio
           AND risc0003.fn_valor_opcao_dominio(iddominio) = pr_dsvlrdom;
      vr_iddominio tbrisco_dominio.iddominio%TYPE := 0;
    BEGIN
      -- Buscar dentre todos os registros de opções do domínio passado qual é o que resulta no valor passado:
      OPEN cr_vlrdom;
      FETCH cr_vlrdom
       INTO vr_iddominio;
      CLOSE cr_vlrdom;
      -- Retornar o valor encontrado ou null caso não tenha achado nada
      RETURN vr_iddominio;
    END;
  END fn_busca_iddominio;

  -- Criar os contratos novos na virada de mês para os produtos que permitirem
  PROCEDURE pc_cria_contratos_novo_mes(pr_cdcooper  IN NUMBER
                                      ,pr_idproduto IN NUMBER
                                      ,pr_dtbase    IN DATE
                                      ,pr_dscritic OUT varchar2) IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_cria_contratos_novo_mes
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Andrei Vieira - Mouts
    --  Data     : Abril/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Criar os contratos novos na virada de mês para os produtos que permitirem
    --
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Saida de erros
      vr_dscritic varchar2(4000);
      vr_excsaida EXCEPTION;
      -- Verifica se existem contratos para o produto, mes e coop atual
      CURSOR cr_movto(pr_dtbusca DATE) IS
        SELECT mvt.nrdconta
              ,mvt.nrctremp
              ,mvt.nrcpfcgc
              ,mvt.idorigem_recurso
              ,mvt.idindexador
              ,mvt.perindexador
              ,mvt.vltaxa_juros
              ,mvt.idgarantia
              ,mvt.dtlib_operacao
              ,mvt.idnat_operacao
              ,mvt.dtvenc_operacao
              ,mvt.cdclassifica_operacao
              ,mvt.qtdparcelas
              ,mvt.vlparcela
              ,mvt.dtproxima_parcela
              ,mvt.flsaida_operacao
              ,mvt.vloperacao
              ,ass.inpessoa
          FROM tbrisco_provisgarant_movto mvt
              ,crapass                    ass
         WHERE mvt.cdcooper  = ass.cdcooper
           AND mvt.nrdconta  = ass.nrdconta
           AND mvt.cdcooper  = pr_cdcooper
           AND mvt.idproduto = pr_idproduto
           AND mvt.dtbase    = pr_dtbusca;
      rw_movto cr_movto%ROWTYPE;

      -- Busca a configuração do produto
      CURSOR cr_produt IS
        SELECT flreaprov_mensal
          FROM tbrisco_provisgarant_prodt
         WHERE idproduto = pr_idproduto;
      rw_produt cr_produt%ROWTYPE;

    BEGIN
      -- Primeiramente vamos verificar se não existe nenhum contrato
      -- para o produto na cooperativa e mês atual
      OPEN cr_movto(pr_dtbase);
      FETCH cr_movto
       INTO rw_movto;
      -- Se não existir nenhum contrato ainda
      IF cr_movto%NOTFOUND THEN
        CLOSE cr_movto;
        -- Vamos verificar se a tabela de lançamentos está liberada.
        IF gene0001.fn_param_sistema('CRED',pr_cdcooper,'DIGIT_RISCO_FINAN_LIBERA') = 0 THEN
          -- Vamos liberar a digitação
          BEGIN
            UPDATE CRAPPRM
               SET dsvlrprm = 1
             WHERE nmsistem = 'CRED'
               AND cdcooper = pr_cdcooper
               AND cdacesso = 'DIGIT_RISCO_FINAN_LIBERA';
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro na Liberacao da Digitacao de Riscos > '||sqlerrm;
              RAISE vr_excsaida;
          END;
        END IF;
        -- Busca a configuração do produto
        OPEN cr_produt;
        FETCH cr_produt
         INTO rw_produt;
        CLOSE cr_produt;
        -- Se o produto permite o reaproveitamento mensal
        IF rw_produt.flreaprov_mensal = 1 THEN
          -- Buscar todos os movtos do mÊs anterior
          OPEN cr_movto(add_months(pr_dtbase,-1));
          LOOP
            FETCH cr_movto
             INTO rw_movto;
            EXIT WHEN cr_movto%NOTFOUND;
            -- Somente se o movto não for de saída
            IF rw_movto.flsaida_operacao = 0 THEN
              -- PAra cada registro, vamos criar o mesmo no mês atual com saldo e valor zerado
              BEGIN
                INSERT INTO tbrisco_provisgarant_movto(cdcooper
                                                      ,idproduto
                                                      ,dtbase
                                                      ,nrdconta
                                                      ,nrctremp
                                                      ,nrcpfcgc
                                                      ,idorigem_recurso
                                                      ,idindexador
                                                      ,perindexador
                                                      ,vltaxa_juros
                                                      ,dtlib_operacao
                                                      ,idnat_operacao
                                                      ,idgarantia
                                                      ,dtvenc_operacao
                                                      ,cdclassifica_operacao
                                                      ,qtdparcelas
                                                      ,vlparcela
                                                      ,dtproxima_parcela
                                                      ,vloperacao
                                                      ,vlsaldo_pendente
                                                      ,flsaida_operacao)
                                                VALUES(pr_cdcooper
                                                      ,pr_idproduto
                                                      ,pr_dtbase
                                                      ,rw_movto.nrdconta
                                                      ,rw_movto.nrctremp
                                                      ,rw_movto.nrcpfcgc
                                                      ,rw_movto.idorigem_recurso
                                                      ,rw_movto.idindexador
                                                      ,rw_movto.perindexador
                                                      ,rw_movto.vltaxa_juros
                                                      ,rw_movto.dtlib_operacao
                                                      ,rw_movto.idnat_operacao
                                                      ,rw_movto.idgarantia
                                                      ,rw_movto.dtvenc_operacao
                                                      ,rw_movto.cdclassifica_operacao
                                                      ,rw_movto.qtdparcelas
                                                      ,rw_movto.vlparcela
                                                      ,rw_movto.dtproxima_parcela
                                                      ,rw_movto.vloperacao
                                                      ,0
                                                      ,0);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro na copia do Movto > '||sqlerrm;
                  RAISE vr_excsaida;
              END;

              -- Gera log
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_nmarqlog     => 'movrgp.log'
                                        ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                            ' -->  Operador 1 - SUPER USUARIO - ' ||
                                                            'Recriacao mensal de Contrato: ' ||
                                                            'Produto: ' || gene0002.fn_mask(pr_idproduto,'z.zzz.zz9') ||
                                                            ', Dt.Ref: ' || to_char(pr_dtbase,'dd/mm/rrrr') ||
                                                            ', Conta: ' || gene0002.fn_mask_conta(rw_movto.nrdconta) ||
                                                            ', CPF/CNPJ: ' || gene0002.fn_mask_cpf_cnpj(rw_movto.nrcpfcgc,rw_movto.inpessoa) ||
                                                            ', Contrato: ' || rw_movto.nrctremp ||
                                                            ', Origem Recurso: ' || risc0003.fn_valor_opcao_dominio(rw_movto.idorigem_recurso) ||
                                                            ', Indexador: ' || risc0003.fn_valor_opcao_dominio(rw_movto.idindexador) ||
                                                            ', Perc. Indexador: ' || to_char(rw_movto.perindexador,'990D0000000','NLS_NUMERIC_CHARACTERS='',.''') ||
                                                            ', Valor taxa de juros: ' || to_char(rw_movto.vltaxa_juros,'990D0000000','NLS_NUMERIC_CHARACTERS='',.''') ||
                                                            ', Dt. Lib. Op: ' || to_char(rw_movto.dtlib_operacao,'dd/mm/rrrr') ||
                                                            ', Valor Operacao: ' || to_char(0.00,'990D00','NLS_NUMERIC_CHARACTERS='',.''') ||
                                                            ', Nat. Operacao: ' || RISC0003.fn_valor_opcao_dominio(rw_movto.idnat_operacao) ||
                                                            ', Dt. Venc. Op: ' || to_char(rw_movto.dtvenc_operacao,'dd/mm/rrrr') ||
                                                            ', Classificacao da operacao: ' ||rw_movto.cdclassifica_operacao  ||
                                                            ', Qtd. Parcelas: ' || to_char(rw_movto.qtdparcelas,'999G999G990','NLS_NUMERIC_CHARACTERS='',.''') ||
                                                            ', Vlr. Parcelas: ' || to_char(rw_movto.vlparcela,'999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS='',.''') ||
                                                            ', Dt. Prox. Parcela: ' || to_char(rw_movto.dtproxima_parcela,'dd/mm/rrrr') ||
                                                            ', Valor Operacao: ' || to_char(rw_movto.vloperacao,'999G999G999G999G990D00','NLS_NUMERIC_CHARACTERS='',.''') ||
                                                            ', Saldo Pendente: ' || to_char(0.00,'990D00','NLS_NUMERIC_CHARACTERS='',.''') || '.');
            END IF;
          END LOOP;
          CLOSE cr_movto;
        END IF;
      ELSE
        -- Já existem, então só fechamos o cursor e continuamos
        CLOSE cr_movto;
      END IF;
    EXCEPTION
      WHEN vr_excsaida THEN
        IF cr_movto%ISOPEN THEN
          CLOSE cr_movto;
        END IF;
        pr_dscritic := 'RISC0003.pc_cria_contratos_novo_mes - Erro tratado -> '||vr_dscritic;
      WHEN OTHERS THEN
        IF cr_movto%ISOPEN THEN
          CLOSE cr_movto;
        END IF;
        pr_dscritic := 'RISC0003.pc_cria_contratos_novo_mes - Erro nao tratado -> '||sqlerrm;
    END;
  END pc_cria_contratos_novo_mes;

  -- Criar novo procedimento que irá gerar as informações do movimento para CSV
  PROCEDURE pc_exporta_dados_csv(pr_dtbase    IN DATE
                                ,pr_dsarquiv OUT CLOB
                                ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_exporta_dados_csv
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Andrei Vieira - Mouts
    --  Data     : Abril/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Criar novo procedimento que irá gerar as informações do movimento para CSV
    --
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Tratamento de exceção
      vr_dscritic varchar2(4000);
      vr_excsaida EXCEPTION;

      -- Busca os movimentos para os parâmetros enviados
      CURSOR cr_movto(pr_dtbusca DATE) IS
        SELECT mvt.cdcooper
              ,to_char(mvt.dtbase,'dd/mm/rrrr') dtbase
              ,mvt.idproduto
              ,prd.dsproduto
              ,mvt.nrdconta
              ,gene0002.fn_mask_conta(mvt.nrdconta) nrdconta_mask
              ,decode(ass.inpessoa,1,'PF','PJ') inpessoa
              ,ass.nmprimtl
              ,mvt.nrctremp
              ,gene0002.fn_mask_cpf_cnpj(mvt.nrcpfcgc,ass.inpessoa) nrcpfcgc
              ,risc0003.fn_valor_opcao_dominio(mvt.idorigem_recurso) idorigem_recurso
              ,risc0003.fn_valor_opcao_dominio(mvt.idindexador) idindexador
              ,to_char(mvt.perindexador,'fm9g990d0000000') perindexador
              ,fn_descri_opcao_dominio(mvt.idgarantia) desgarantia
              ,to_char(mvt.vltaxa_juros,'fm999g999g990d00000000') vltaxa_juros
              ,to_char(mvt.dtlib_operacao,'dd/mm/rrrr') dtlib_operacao
              ,to_char(mvt.vloperacao,'fm999g999g999g999g990d00') vloperacao
              ,risc0003.fn_valor_opcao_dominio(mvt.idnat_operacao) idnat_operacao
              ,to_char(mvt.dtvenc_operacao,'dd/mm/rrrr') dtvenc_operacao
              ,mvt.cdclassifica_operacao
              ,fn_calcula_nivel_risco(mvt.cdclassifica_operacao) innivris
              ,to_char(mvt.qtdparcelas,'fm999g999g990') qtdparcelas
              ,to_char(mvt.vlparcela,'fm999g999g999g999g990d00') vlparcela
              ,to_char(mvt.dtproxima_parcela,'dd/mm/rrrr') dtproxima_parcela
              ,to_char(mvt.vlsaldo_pendente,'fm999g999g999g999g990d00') dssaldo_pendente
              ,mvt.vlsaldo_pendente
              ,decode(mvt.flsaida_operacao,0,'Não','Sim') flsaida_operacao
              ,ROW_NUMBER () OVER (PARTITION BY mvt.cdcooper,mvt.nrdconta
                                       ORDER BY mvt.cdcooper,mvt.nrdconta,risc0003.fn_calcula_nivel_risco(mvt.cdclassifica_operacao) desc) sequencia
          FROM tbrisco_provisgarant_movto mvt
              ,crapass                    ass
              ,tbrisco_provisgarant_prodt     prd
         WHERE mvt.idproduto = prd.idproduto
           AND mvt.cdcooper  = ass.cdcooper
           AND mvt.nrdconta  = ass.nrdconta
           AND mvt.dtbase    = pr_dtbusca
         ORDER BY mvt.cdcooper, mvt.nrdconta, risc0003.fn_calcula_nivel_risco(mvt.cdclassifica_operacao) desc;
      -- Variaveis para gravação no arquivo
      vr_clobarqu     CLOB;
      vr_txtoarqu     varchar2(32767);
      -- Calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Tabela temporaria para os percentuais de risco
      TYPE typ_reg_percentual IS
       RECORD(percentual NUMBER(7,2));

      TYPE typ_tab_percentual IS
        TABLE OF typ_reg_percentual
          INDEX BY PLS_INTEGER;
      vr_tab_percentual       typ_tab_percentual;

      -- Buscar todos os percentual de cada nivel de risco
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT craptab.dstextab
          FROM craptab
         WHERE craptab.cdcooper = pr_cdcooper
           AND UPPER(craptab.nmsistem) = 'CRED'
           AND UPPER(craptab.tptabela) = 'GENERI'
           AND craptab.cdempres = 00
           AND UPPER(craptab.cdacesso) = 'PROVISAOCL';
      -- Calculo provisão
      vr_cdcooper NUMBER := 0;
      vr_vlpercen NUMBER;
      vr_vlpreatr NUMBER;

      -- Auxiliares para arrasto
      vr_dstextab     craptab.dstextab%TYPE;
      vr_innivris     crapris.innivris%TYPE;
      vr_innivris_csv crapris.innivris%TYPE;
      vr_nrdgrupo     crapgrp.nrdgrupo%TYPE;
      vr_vlarrasto    NUMBER;
      vr_fcrapris     BOOLEAN;

      -- Buscar o pior risco para a conta nas tabelas temporárias
      CURSOR cr_movto_last(pr_cdcooper IN crapris.cdcooper%TYPE
                          ,pr_nrdconta IN crapris.nrdconta%TYPE
                          ,pr_dtrefere IN crapris.dtrefere%TYPE
                          ,pr_vlarrast IN crapris.vldivida%TYPE) IS
        SELECT cdclassifica_operacao
          FROM tbrisco_provisgarant_movto
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dtbase = pr_dtrefere
           AND (vlsaldo_pendente > pr_vlarrast OR pr_vlarrast = 0)
         ORDER BY cdclassifica_operacao DESC;
      vr_cdclassifica_operacao tbrisco_provisgarant_movto.cdclassifica_operacao%TYPE;

    BEGIN
      -- Busca da data atual
      OPEN btch0001.cr_crapdat(3);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      -- Abrir os CLOBs para o Arquivo
      dbms_lob.createtemporary(vr_clobarqu, TRUE);
      dbms_lob.open(vr_clobarqu, dbms_lob.lob_readwrite);
      -- Escrever o header do arquivo
      gene0002.pc_escreve_xml(vr_clobarqu
                             ,vr_txtoarqu
                             ,'Cooper.;Dt.Ref.;Produto;Conta;Contrato;CPF/CGC;Tp.Pessoa;Origem Recurso;Indexador;Perc.Indexador;Garantia;Taxa de Juros a.a;Dt. Lib. Op;Valor Op;Natureza Operacação;Dt. Venc. OP;Qtd. Parcelas;Vlr. Parcelas;Dt. Prox. Parcela;Saldo Pendente;ClassOp(Tela);ClassOp(Arrast);Percent. Provisão;Provisão;É saida?;'||CHR(10));
      -- Buscar os movimentos conforme filtragem
      FOR rw_movto IN cr_movto(pr_dtbase) LOOP

        -- Se mudou a Coop
        IF rw_movto.cdcooper <> vr_cdcooper THEN
          -- CRAPTAB -> 'PROVISAOCL'
          vr_tab_percentual.delete();
          FOR rw_craptab IN cr_craptab(pr_cdcooper => rw_movto.cdcooper) LOOP
            vr_tab_percentual(substr(rw_craptab.dstextab,12,2)).percentual := SUBSTR(rw_craptab.dstextab,1,6);
          END LOOP;
          -- Gravar a coop
          vr_cdcooper := rw_movto.cdcooper;

          -- Chamar função que busca o dstextab para retornar o valor de arrasto
          -- no parâmetro de sistema RISCOBACEN
          vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => rw_movto.cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'USUARI'
                                                   ,pr_cdempres => 11
                                                   ,pr_cdacesso => 'RISCOBACEN'
                                                   ,pr_tpregist => 000);
          -- Se a variavel voltou vazia
          IF vr_dstextab IS NULL THEN
            vr_vlarrasto := 100;
          ELSE
            -- Por fim, tenta converter o valor de arrasto presente na posição 3 até 12
            vr_vlarrasto := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,3,9));
          END IF;
        END IF;

        -- No primeiro registro da conta
        -- Para o primeiro registro da conta
        IF rw_movto.sequencia = 1 THEN
          vr_nrdgrupo := 0;
          -- Risco calculado do cartao de credito
          vr_innivris := rw_movto.innivris;
          -- Vamos verificar se possui operacao na mensal acima do valor de arrasto
          OPEN cr_crapris_last(pr_cdcooper => rw_movto.cdcooper
                              ,pr_nrdconta => rw_movto.nrdconta
                              ,pr_dtrefere => pr_dtbase
                              ,pr_vlarrast => vr_vlarrasto);
          FETCH cr_crapris_last INTO rw_crapris_last;
          vr_fcrapris := cr_crapris_last%FOUND;
          CLOSE cr_crapris_last;
          -- Condicao para verificar se existe registro
          IF vr_fcrapris THEN
            vr_innivris := rw_crapris_last.innivris;
          ELSE
            -- Vamos verificar se possui operacao na mensal abaixo de 100,00
            OPEN cr_crapris_last(pr_cdcooper => rw_movto.cdcooper
                                ,pr_nrdconta => rw_movto.nrdconta
                                ,pr_dtrefere => pr_dtbase
                                ,pr_vlarrast => 0);
            FETCH cr_crapris_last INTO rw_crapris_last;
            vr_fcrapris := cr_crapris_last%FOUND;
            CLOSE cr_crapris_last;
            -- Condicao para verificar se existe registro
            IF vr_fcrapris THEN
              vr_innivris := rw_crapris_last.innivris;
            END IF;
          END IF;

          -- As operações de tbmovto ainda não estão na CRAPRIS, portanto temos
          -- que verificar se o risco delas não é superior ao calculado acima

          -- Vamos verificar se possui grupo economico
          OPEN cr_crapgrp(pr_cdcooper => rw_movto.cdcooper
                         ,pr_nrctasoc => rw_movto.nrdconta);
          FETCH cr_crapgrp INTO rw_crapgrp;
          IF cr_crapgrp%FOUND THEN
            CLOSE cr_crapgrp;
            vr_nrdgrupo := rw_crapgrp.nrdgrupo;
            -- Caso nao possuir nenhuma operacao na mensal, vamos assumir o risco do grupo economico
            IF NOT vr_fcrapris THEN
              vr_innivris := rw_crapgrp.innivrge;
            END IF;
          ELSE
            CLOSE cr_crapgrp;
          END IF;


          -- Buscar o pior risco para a conta nas tabelas temporárias
          OPEN cr_movto_last(pr_cdcooper => rw_movto.cdcooper
                            ,pr_nrdconta => rw_movto.nrdconta
                            ,pr_dtrefere => pr_dtbase
                            ,pr_vlarrast => vr_vlarrasto);
          FETCH cr_movto_last
           INTO vr_cdclassifica_operacao;
          -- se não encontrou
          IF cr_movto_last%NOTFOUND THEN
            CLOSE cr_movto_last;
            -- Buscar sem valor minimo
            OPEN cr_movto_last(pr_cdcooper => rw_movto.cdcooper
                              ,pr_nrdconta => rw_movto.nrdconta
                              ,pr_dtrefere => pr_dtbase
                              ,pr_vlarrast => 0);
            FETCH cr_movto_last
             INTO vr_cdclassifica_operacao;
            CLOSE cr_movto_last;
          ELSE
            CLOSE cr_movto_last;
          END IF;

          -- Se o risco da nossa tabela é superior ao da CRAPRIS
          -- Significa que quando arrastar, este será o usado
          IF fn_calcula_nivel_risco(vr_cdclassifica_operacao) > vr_innivris THEN
            vr_innivris := fn_calcula_nivel_risco(vr_cdclassifica_operacao);
          END IF;

          -- Prejuizo não arrastará o HH
          IF vr_innivris = 10 THEN
            vr_innivris := 9;
          END IF;

        END IF; /* END IF rw_crapris.sequencia = 1 THEN */

        -- Somente arrastar as operações que não estão enquadradas no risco AA
        -- Ou que não estejam em Prejuizo, pois estas devem permanecer HH
        IF rw_movto.innivris > 1 AND rw_movto.innivris < 10 THEN
          rw_movto.innivris := vr_innivris;
          vr_innivris_csv   := vr_innivris;
        ELSE
          vr_innivris_csv   := rw_movto.innivris;
        END IF;

        -- Calculo do % de provisao do Risco
        IF vr_tab_percentual.exists(rw_movto.innivris) THEN
          vr_vlpercen := vr_tab_percentual(rw_movto.innivris).percentual / 100;
        ELSE
          vr_vlpercen := 0;
        END IF;

        vr_vlpreatr := ROUND((rw_movto.vlsaldo_pendente *  vr_vlpercen), 2);

        -- Enviar cada registro para o arquivo
        gene0002.pc_escreve_xml(vr_clobarqu
                               ,vr_txtoarqu
                               ,rw_movto.cdcooper||';'||
                                rw_movto.dtbase||';'||
                                rw_movto.idproduto||'-'||rw_movto.dsproduto||';'||
                                rw_movto.nrdconta_mask||'-'||rw_movto.nmprimtl||';'||
                                rw_movto.nrctremp||';'||
                                rw_movto.nrcpfcgc||';'||
                                rw_movto.inpessoa||';'||
                                rw_movto.idorigem_recurso||';'||
                                rw_movto.idindexador||';'||
                                rw_movto.perindexador||';'||
                                rw_movto.desgarantia||';'||
                                rw_movto.vltaxa_juros||';'||
                                rw_movto.dtlib_operacao||';'||
                                rw_movto.vloperacao||';'||
                                rw_movto.idnat_operacao||';'||
                                rw_movto.dtvenc_operacao||';'||
                                rw_movto.qtdparcelas||';'||
                                rw_movto.vlparcela||';'||
                                rw_movto.dtproxima_parcela||';'||
                                rw_movto.dssaldo_pendente||';'||
                                rw_movto.cdclassifica_operacao||';'||
                                fn_nivel_risco(vr_innivris_csv)||';'||
                                to_char(vr_vlpercen,'fm990d00')||';'||
                                to_char(vr_vlpreatr,'fm999g999g999g999g990d00')||';'||
                                rw_movto.flsaida_operacao||';'||
                                CHR(10));
      END LOOP;

      -- Finalizar o arquivo
      gene0002.pc_escreve_xml(vr_clobarqu
                             ,vr_txtoarqu
                             ,' '
                             ,true);

      -- Ao final, devolver o CLOB
      pr_dsarquiv := vr_clobarqu;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_clobarqu);
      dbms_lob.freetemporary(vr_clobarqu);

      -- Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        -- Levantar Excecao
        RAISE vr_excsaida;
      END IF;


    EXCEPTION
      WHEN vr_excsaida THEN
        pr_dscritic := 'RISC0003.pc_exporta_dados_csv - Erro tratado -> '||vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'RISC0003.pc_exporta_dados_csv - Erro nao tratado -> '||sqlerrm;
    END;
  END pc_exporta_dados_csv;

  /* Importação dos Arquivos BRDE */
  PROCEDURE pc_importa_arq_layout_brde(pr_cdcooper  IN NUMBER
                                      ,pr_rw_prod   IN risc0003.cr_prod%ROWTYPE
                                      ,pr_dtbase    IN DATE
                                      ,pr_dsinform OUT VARCHAR2
                                      ,pr_dscritic OUT VARCHAR2) IS                        --> Descricao da critica IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_importa_arq_layout_brde
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Andrei Vieira - MOUTs
    --  Data     : Maio/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Importa o arquivo de layout BRDE
    --
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
    DECLARE

      vr_dsdirarq           VARCHAR2(1000);                   -- Diretorio para processamento
      vr_listadir           VARCHAR2(4000);                   -- Lista de arquivos para processamento
      vr_datbusca           DATE;                             -- Data de Busca do Arquivo
      vr_nombusca           VARCHAR2(1000);                   -- Nome do arquivo para busca
      vr_vet_arquivos       gene0002.typ_split;               -- Array de arquivos
      vr_ind_arquivo        VARCHAR2(100);                    -- Indice do arquivo
      vr_nrcontad           PLS_INTEGER := 0;                 -- Contador de linhas
      vr_contador           PLS_INTEGER := 0;                 -- Contador de registros

      vr_input_file         UTL_FILE.FILE_TYPE;               -- Handle para leitura de arquivo
      vr_setlinha           VARCHAR2(4000);                   -- Texto do arquivo lido
      vr_vet_campos       gene0002.typ_split;               -- Array de arquivos


      -- Informações para seração dos dados do arquivo
      vr_cdctabnd NUMBER;
      vr_nrcpfcgc NUMBER;
      vr_nrctremp NUMBER;
      vr_idindexa NUMBER;
      vr_dsindexa VARCHAR2(100);
      vr_perindex NUMBER;
      vr_txdjuros NUMBER;
      vr_dtinictr DATE;
      vr_vlcontra NUMBER;
      vr_vldsaldo NUMBER;
      vr_dsnatope VARCHAR2(100);
      vr_idnatope NUMBER;
      vr_dsorigem VARCHAR2(100);
      vr_idorigem NUMBER;
      vr_dtprxpar DATE;
      vr_vlprxpar NUMBER;
      vr_qtdparce NUMBER;
      vr_dtfimctr DATE;
      vr_qtsemcta NUMBER := 0;

      -- Definicao de tipo de registro para guardar a COOP por Conta BRDE
      TYPE typ_tab_crapcop IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
      vr_tab_crapcop typ_tab_crapcop;

      -- Busca as cooperativas
      CURSOR cr_crapcop IS
        SELECT cdcooper
          FROM crapcop
         ORDER BY cdcooper;

      -- Encontrar a conta pelo CPF/CNPJ
      CURSOR cr_crapass(pr_cdcooper crapass.nrcpfcgc%TYPE
                       ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
        SELECT nvl(MIN(ass.nrdconta),0) nrdconta
              ,nvl(TRIM(MAX(ass.dsnivris)),'A') dsnivris
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrcpfcgc = pr_nrcpfcgc;
      vr_nrdconta NUMBER;
      vr_dsnivris crapass.dsnivris%TYPE;


      -- Variaveis tratamento de erro
      vr_excsaida           EXCEPTION;
      vr_dscritic           VARCHAR2(4000);
      vr_dscribas           VARCHAR2(4000);
    BEGIN

      -- Buscaremos os arquivos do mês anterior a referência
      vr_datbusca := last_day(add_months(pr_dtbase,-1));

      -- Buscar diretório para processamento
      vr_dsdirarq := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DIRETORIO_CONVEN_BRDE');

      -- Busca do arquivo conforme tipo do Produto
      IF lower(pr_rw_prod.tparquivo) = 'inovacred_brde' THEN
        vr_nombusca := to_char(vr_datbusca,'YYYYMM')||'%_02106_CECREDACATE_SALDOS.TXT';
      ELSIF lower(pr_rw_prod.tparquivo) = 'finame_brde' THEN
        vr_nombusca := to_char(vr_datbusca,'YYYYMM')||'%_02105_CECRED_SALDOS.TXT';
      ELSIF lower(pr_rw_prod.tparquivo) = 'cartao_bndes_brde' THEN
        vr_nombusca := to_char(vr_datbusca,'YYYYMM')||'%_02075_CECRED_CARTAO_BNDES_SALDOS.TXT';
      ELSE
        -- Gerar erro
        pr_dscritic := 'Produto id['||pr_rw_prod.idproduto||'] nao eh do tipo BRDE!';
        RETURN;
      END IF;

      -- Iniciando LOG
      pr_dsinform := 'Iniciando Importacao - Produto id['||pr_rw_prod.idproduto||']-'||pr_rw_prod.dsproduto||'<br>'
                  || 'Busca de arquivos '||vr_nombusca||' em '||vr_dsdirarq||'<br>';


      -- Buscar os arquivos VIPS do mês de referência
      gene0001.pc_lista_arquivos(pr_path     => vr_dsdirarq,
                                 pr_pesq     => vr_nombusca,
                                 pr_listarq  => vr_listadir,
                                 pr_des_erro => vr_dscritic);

      -- Separar os arquivos de retorno em um Array
      vr_vet_arquivos := gene0002.fn_quebra_string(pr_string => vr_listadir);
      -- Vamos verificar se possui algum arquivo na pasta para importar
      IF vr_vet_arquivos.COUNT <= 0 THEN
        -- Sai da procedure pois não existem arquivos para processamento
        pr_dsinform := pr_dsinform
                    || ' Sem arquivos para processamento';
        RETURN;
      END IF;

      BEGIN
        -- Eliminar os registros deste produto na cooperativa e data
        -- pois as informações serão sobescritas
        DELETE FROM TBRISCO_PROVISGARANT_MOVTO mov
              WHERE mov.idproduto = pr_rw_prod.idproduto
                AND mov.dtbase    = pr_dtbase;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao limpar tabela TBRISCO_PROVISGARANT_MOVTO -->'||SQLERRM;
          RAISE vr_excsaida;
      END;

      -- Vamos percorrer todas as cooperativas e gravar na tabela temporaria
      FOR rw_crapcop IN cr_crapcop LOOP
        -- O indice será o numero da conta no BRDE
        vr_tab_crapcop(gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'CONTA_CONVEN_BRDE')) := rw_crapcop.cdcooper;
      END LOOP;

      -- Leitura da PL/Table e processamento dos arquivos
      vr_ind_arquivo := vr_vet_arquivos.first;
      WHILE vr_ind_arquivo IS NOT NULL LOOP

        -- Sair quando não existir mais arquivos
        EXIT WHEN vr_ind_arquivo IS NULL;

        pr_dsinform := pr_dsinform
                    || ' Integrando arquivo '||vr_vet_arquivos(vr_ind_arquivo)||'...<br>';

        -- Zerar contador de linhas
        vr_nrcontad := 0;

        -- Carrega arquivo
        gene0001.pc_abre_arquivo(pr_nmcaminh => vr_dsdirarq||'/'||vr_vet_arquivos(vr_ind_arquivo)   --> Nome do arquivo
                                ,pr_tipabert => 'R'           --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic); --> Descricao do erro

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_excsaida;
        END IF;

        -- Laco para leitura de linhas do arquivo
        LOOP
          BEGIN
            -- Carrega handle do arquivo
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido

            -- Incrementar quantidade linhas
            vr_nrcontad := vr_nrcontad + 1;

            -- HEADER
            IF vr_nrcontad = 1 THEN
              -- Proxima Linha
              CONTINUE;
            END IF;

            -- Remover possiveis " no começo e final
            vr_setlinha := rtrim(ltrim(vr_setlinha,'"'),'"');

            -- Separar os campos da linha em um vetor
            vr_vet_campos := gene0002.fn_quebra_string(vr_setlinha,';');

            BEGIN
              -- Montar inicio de mensagem de erro padrão
              vr_dscribas := 'Erro na leitura da linha '||vr_nrcontad||' campo ';

              -- Cooperativa
              vr_dscritic := vr_dscribas || ' Cooperativa = '||vr_vet_campos(6);
              vr_cdctabnd := vr_vet_campos(6);
              -- Verificar se a Cooperativa do registro não está com o período fechado
              IF fn_periodo_habilitado(pr_cdcooper => vr_tab_crapcop(vr_cdctabnd)
                                      ,pr_dtbase => pr_dtbase) = 0 THEN
                -- Gerar critica período fechado
                vr_dscritic := vr_dscribas || ' Cooperativa = '||vr_tab_crapcop(vr_cdctabnd)||' com periodo fechado, favor reabrir para proceder com a importacao!';
                RAISE vr_excsaida;
              END IF;
              -- CPF/CNPJ do Cooperado, primeiro retornando CPF/CNPJ
              vr_dscritic := vr_dscribas || ' CPF/CNPJ = '||vr_vet_campos(3);
              vr_nrcpfcgc := vr_vet_campos(3);
              -- Buscar a conta
              vr_nrdconta := 0;
              vr_dsnivris := 'A';
              OPEN cr_crapass(vr_tab_crapcop(vr_cdctabnd),vr_nrcpfcgc);
              FETCH cr_crapass
               INTO vr_nrdconta
                   ,vr_dsnivris;
              CLOSE cr_crapass;
              -- Se não encontrar vamos indicar que há registros sem conta
              IF vr_nrdconta = 0 THEN
                vr_qtsemcta := vr_qtsemcta + 1;
              END IF;
              -- Contrato
              vr_dscritic := vr_dscribas || ' Contratro = '||vr_vet_campos(1);
              vr_nrctremp := vr_vet_campos(1);
              -- Indexador
              vr_dscritic := vr_dscribas || ' Indexador = '||vr_vet_campos(20);
              vr_dsindexa := lpad(vr_vet_campos(20),fn_tamanho_dominio(4),'0');
              -- Busca o ID conforme descrição Indexador encontrado
              vr_idindexa := fn_busca_iddominio(4,vr_dsindexa);
              IF nvl(vr_idindexa,0) = 0 AND nvl(pr_rw_prod.idindexador,0) = 0 THEN
                RAISE vr_excsaida;
              END IF;
              -- Percentual indexador
              vr_dscritic := vr_dscribas || ' Indexador = '||vr_vet_campos(21);
              vr_perindex := vr_vet_campos(21);
              -- Taxa de Juros
              vr_dscritic := vr_dscribas || ' Taxa de Juros = '||vr_vet_campos(9);
              vr_txdjuros := vr_vet_campos(9);
              -- DAta Contratação
              vr_dscritic := vr_dscribas || ' Data Contratação = '||vr_vet_campos(17);
              vr_dtinictr := TO_date(vr_vet_campos(17),'YYYYMMDD');
              -- Valor Contratado
              vr_dscritic := vr_dscribas || ' Valor Contratação = '||vr_vet_campos(18);
              vr_vlcontra := gene0002.fn_char_para_number(vr_vet_campos(18));
              -- Saldo
              vr_dscritic := vr_dscribas || ' Valor Saldo = '||vr_vet_campos(16);
              vr_vldsaldo := gene0002.fn_char_para_number(replace(replace(vr_vet_campos(16),'+',''),'-',''));
              -- Busca o ID conforme descrição Natureza Operação
              vr_dscritic := vr_dscribas || ' Nat.Op = '||vr_vet_campos(24);
              vr_dsnatope:= lpad(vr_vet_campos(24),fn_tamanho_dominio(6),'0');
              vr_idnatope := fn_busca_iddominio(6,vr_dsnatope);
              IF nvl(vr_idnatope,0) = 0 AND nvl(pr_rw_prod.idnat_operacao,0) = 0 THEN
                RAISE vr_excsaida;
              END IF;
              -- DAta Fim Contrato
              vr_dscritic := vr_dscribas || ' Data Fim Contrato = '||vr_vet_campos(14);
              vr_dtfimctr := TO_date(vr_vet_campos(14),'YYMMDD');
              -- Busca o ID conforme descrição Origem Recurso
              vr_dscritic := vr_dscribas || ' Origem Recurso = '||vr_vet_campos(25);
              vr_dsorigem:= lpad(vr_vet_campos(25),fn_tamanho_dominio(3),'0');
              vr_idorigem := fn_busca_iddominio(3,vr_dsorigem);
              IF nvl(vr_idorigem,0) = 0 AND nvl(pr_rw_prod.idorigem_recurso,0) = 0 THEN
                RAISE vr_excsaida;
              END IF;

              -- Campos fluxo financeiro somente se produto permite
              IF pr_rw_prod.flpermite_fluxo_financeiro = 1 THEN
                -- DAta Proxima Parcela
                vr_dscritic := vr_dscribas || ' Data Proxima Parcela = '||vr_vet_campos(26);
                vr_dtprxpar := NULL;
                IF vr_vet_campos(26) <> 0 THEN
                  vr_dtprxpar := TO_date(vr_vet_campos(26),'YYYYMMDD');
                END IF;
                -- Valor Proxima Parcela
                vr_dscritic := vr_dscribas || ' Valor Proxima Parcela = '||vr_vet_campos(27);
                vr_vlprxpar := gene0002.fn_char_para_number(vr_vet_campos(27));
                -- Quantidade Parcela
                vr_dscritic := vr_dscribas || ' Quantidade Parcela = '||vr_vet_campos(28);
                vr_qtdparce := gene0002.fn_char_para_number(vr_vet_campos(28));
              END IF;

            EXCEPTION
              WHEN vr_excsaida THEN
                -- propagar
                RAISE vr_excsaida;
              WHEN OTHERS THEN
                -- incrementar o erro e propagar
                vr_dscritic := vr_dscribas || ' indefinido -> Erro --> '||SQLERRM;
                RAISE vr_excsaida;
            END;


            -- Efetuar a gravação em tabela
            BEGIN
              INSERT INTO TBRISCO_PROVISGARANT_MOVTO(cdcooper
                                                    ,idproduto
                                                    ,dtbase
                                                    ,nrdconta
                                                  ,nrctremp
                                                    ,nrcpfcgc
                                                    ,idorigem_recurso
                                                    ,idindexador
                                                    ,perindexador
                                                    ,idgarantia
                                                    ,vltaxa_juros
                                                    ,dtlib_operacao
                                                    ,vloperacao
                                                    ,idnat_operacao
                                                    ,dtvenc_operacao
                                                    ,cdclassifica_operacao
                                                    ,qtdparcelas
                                                    ,vlparcela
                                                    ,dtproxima_parcela
                                                    ,vlsaldo_pendente
                                                    ,flsaida_operacao)
                                              VALUES(vr_tab_crapcop(vr_cdctabnd)
                                                    ,pr_rw_prod.idproduto
                                                    ,pr_dtbase
                                                    ,vr_nrdconta
                                                    ,vr_nrctremp
                                                    ,vr_nrcpfcgc
                                                    ,decode(nvl(vr_idorigem,0),0,pr_rw_prod.idorigem_recurso,vr_idorigem)
                                                    ,decode(nvl(vr_idindexa,0),0,pr_rw_prod.idindexador,vr_idindexa)
                                                    ,nvl(vr_perindex,pr_rw_prod.perindexador)
                                                    ,pr_rw_prod.idgarantia
                                                    ,nvl(vr_txdjuros,pr_rw_prod.vltaxa_juros)
                                                    ,vr_dtinictr
                                                    ,vr_vlcontra
                                                    ,decode(nvl(vr_idnatope,0),0,pr_rw_prod.idnat_operacao,vr_idnatope)
                                                    ,vr_dtfimctr
                                                    ,decode(pr_rw_prod.cdclassifica_operacao,'RS',vr_dsnivris,pr_rw_prod.cdclassifica_operacao)
                                                    ,vr_qtdparce
                                                    ,vr_vlprxpar
                                                    ,vr_dtprxpar
                                                    ,vr_vldsaldo
                                                    ,decode(pr_rw_prod.flpermite_saida_operacao,1,decode(nvl(vr_vldsaldo,0),0,1,0),0));
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao criar contratos na tabela TBRISCO_PROVISGARANT_MOVTO linha '||vr_nrcontad||'-->'||SQLERRM;
                RAISE vr_excsaida;
            END;

            vr_contador := vr_contador + 1;

          EXCEPTION
            WHEN no_data_found THEN
              -- final do arquivo
              EXIT;
            WHEN vr_excsaida THEN
              RAISE vr_excsaida;
            WHEN OTHERS THEN
              vr_dscritic := 'Erro na leitura da linha '||vr_nrcontad||SQLERRM;
              RAISE vr_excsaida;
          END;
        END LOOP; /* END LOOP */

        -- Incrementar LOG
        pr_dsinform := pr_dsinform || 'Registros integrados: '||(vr_contador)||'<br>';

        -- Verificar se existem linhas sem conta
        IF vr_qtsemcta = 1 THEN
          pr_dsinform := pr_dsinform || 'Observacao: Existe um registro com CPF/CNPJ sem conta na Cooperativa!<br>';
        ELSIF vr_qtsemcta > 1 THEN
          pr_dsinform := pr_dsinform || 'Observacao: Existem '||vr_qtsemcta||' registros com CPF/CNPJ sem conta na Cooperativa!<br>';
        END IF;

        -- Proximo arquivo
        vr_ind_arquivo := vr_vet_arquivos.next(vr_ind_arquivo);
      END LOOP;

      -- Ao final, gerar texto informativo
      pr_dsinform := pr_dsinform || 'Importacao efetuada com sucesso!';
    EXCEPTION
      WHEN vr_excsaida THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'RISC0003.pc_importa_arq_layout_brde --> Erro nao tratado: '||SQLERRM;
    END;
  END pc_importa_arq_layout_brde;

  -- Importar os registros dos cartões Bancoob
  PROCEDURE pc_leitura_registros_bancoob(pr_cdcooper  IN NUMBER
                                        ,pr_rw_prod   IN risc0003.cr_prod%ROWTYPE
                                        ,pr_dtbase    IN DATE
                                        ,pr_dsinform OUT VARCHAR2
                                        ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_leitura_registros_bancoob
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Andrei Vieira - Mouts
    --  Data     : Maio/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Aproveitar as informações já importadas dos arquivos Bancoob para
    --             garantias na Central
    --
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Tratamento de exceção
      vr_dscritic varchar2(4000);
      vr_excsaida EXCEPTION;
      -- Busca das Cooperativas ativas
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper
              ,cop.nrctactl
              ,cop.nrdocnpj
              ,NVL(TRIM(ass.dsnivris),'A') dsnivris
          FROM crapcop cop
              ,crapass ass
         WHERE ass.cdcooper = 3   -- Na central
           AND ass.nrdconta = cop.nrctactl
           AND cop.flgativo = 1   -- Somente ativas
           AND cop.cdcooper <> 3; -- Fora da Central
      -- Saldos e Limites e Data
      vr_vlrsaldo NUMBER;
      vr_vlrlimit NUMBER;
      vr_dtmaxvct DATE;
      vr_drminctr DATE;

      -- Contador de registros e data de busca
      vr_contador PLS_INTEGER := 0;
      vr_dtdbusca DATE := last_day(add_months(pr_dtbase,-1));

      -- Busca dos limites sempre dois meses atrás
      CURSOR cr_limite(pr_cdcooper NUMBER) IS
        SELECT SUM(vlsaldo_devedor)
          FROM TBCRD_RISCO
         WHERE cdcooper = pr_cdcooper
           AND cdtipo_cartao = 1 --Bancoob
           AND dtrefere = vr_dtdbusca;

      -- Busca dos Saldos Devedores sempre dois meses atrás
      CURSOR cr_saldo(pr_cdcooper NUMBER) IS
        SELECT SUM(vlsaldo_devedor)
          FROM TBCRD_RISCO
         WHERE cdcooper = pr_cdcooper
           AND cdtipo_cartao = 1 --Bancoob
           AND dtrefere = vr_dtdbusca
           AND cdtipo_saldo IN(1,2,3,4);

      -- Buscar datas de contrato e do ultimo vencimento
      CURSOR cr_datas(pr_cdcooper NUMBER) IS
        SELECT min(dtcadastro)
              ,MAX(dtvencimento)
          FROM TBCRD_RISCO
         WHERE cdcooper = pr_cdcooper
           AND cdtipo_cartao = 1 --Bancoob
           AND dtrefere = vr_dtdbusca;

    BEGIN

      BEGIN
        -- Eliminar os registros deste produto na cooperativa e data
        -- pois as informações serão sobescritas
        DELETE FROM TBRISCO_PROVISGARANT_MOVTO mov
              WHERE mov.cdcooper  = 3 -- Central
                AND mov.idproduto = pr_rw_prod.idproduto
                AND mov.dtbase    = pr_dtbase;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao limpar tabela TBRISCO_PROVISGARANT_MOVTO -->'||SQLERRM;
          RAISE vr_excsaida;
      END;

      -- Iniciando LOG
      pr_dsinform := 'Iniciando Importacao - Produto id['||pr_rw_prod.idproduto||']-'||pr_rw_prod.dsproduto||'<br>'
                  || 'Busca de registros criados para os cartoes Bancoob...<br>';

      -- Buscar todas as Cooperativas
      FOR rw_cop IN cr_crapcop LOOP
        -- Buscar Limites
        vr_vlrlimit := 0;
        OPEN cr_limite(rw_cop.cdcooper);
        FETCH cr_limite
         INTO vr_vlrlimit;
        CLOSE cr_limite;
        -- Buscar Saldo Devedor
        vr_vlrsaldo := 0;
        OPEN cr_saldo(rw_cop.cdcooper);
        FETCH cr_saldo
         INTO vr_vlrsaldo;
        CLOSE cr_saldo;
        -- Buscar menor data de contrato e maior vencimento
        vr_drminctr := NULL;
        vr_dtmaxvct := NULL;
        OPEN cr_datas(rw_cop.cdcooper);
        FETCH cr_datas
         INTO vr_drminctr,vr_dtmaxvct;
        CLOSE cr_datas;
        -- Efetuar gravação na tabela de movimento
        BEGIN
          INSERT INTO TBRISCO_PROVISGARANT_MOVTO(cdcooper
                                                ,idproduto
                                                ,dtbase
                                                ,nrdconta
                                                ,nrctremp
                                                ,nrcpfcgc
                                                ,idorigem_recurso
                                                ,idindexador
                                                ,perindexador
                                                ,idgarantia
                                                ,vltaxa_juros
                                                ,dtlib_operacao
                                                ,vloperacao
                                                ,idnat_operacao
                                                ,dtvenc_operacao
                                                ,cdclassifica_operacao
                                                ,qtdparcelas
                                                ,vlparcela
                                                ,dtproxima_parcela
                                                ,vlsaldo_pendente
                                                ,flsaida_operacao)
                                          VALUES(pr_cdcooper
                                                ,pr_rw_prod.idproduto
                                                ,pr_dtbase
                                                ,rw_cop.nrctactl
                                                ,lpad(rw_cop.nrctactl,8,'0')||lpad(pr_rw_prod.idproduto,2,'0')
                                                ,rw_cop.nrdocnpj
                                                ,pr_rw_prod.idorigem_recurso
                                                ,pr_rw_prod.idindexador
                                                ,pr_rw_prod.perindexador
                                                ,pr_rw_prod.idgarantia
                                                ,pr_rw_prod.vltaxa_juros
                                                ,vr_drminctr
                                                ,nvl(vr_vlrlimit,0)
                                                ,pr_rw_prod.idnat_operacao
                                                ,vr_dtmaxvct
                                                ,decode(pr_rw_prod.cdclassifica_operacao,'RS',rw_cop.dsnivris,pr_rw_prod.cdclassifica_operacao)
                                                ,NULL
                                                ,NULL
                                                ,NULL
                                                ,nvl(vr_vlrsaldo,0)
                                                ,decode(pr_rw_prod.flpermite_saida_operacao,1,decode(nvl(vr_vlrsaldo,0),0,1,0),0));
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao criar contratos na tabela TBRISCO_PROVISGARANT_MOVTO -->'||SQLERRM;
            RAISE vr_excsaida;
        END;
        -- Incrementar contador
        vr_contador := vr_contador + 1;
      END LOOP;

      IF vr_contador = 0 THEN
      -- Ao final, gerar texto informativo
        pr_dsinform := pr_dsinform||'Sem registros para integracao na Central.';

      ELSE
        -- Ao final, gerar texto informativo
        pr_dsinform := pr_dsinform||'Total de registros integrados: '||vr_contador||'<br>'
                    || 'Importacao efetuada com sucesso!';

      END IF;

    EXCEPTION
      WHEN vr_excsaida THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'RISC0003.pc_leitura_registros_bancoob --> Erro nao tratado: '||SQLERRM;
    END;
  END pc_leitura_registros_bancoob;

  -- Importar os registros dos cartões BB
  PROCEDURE pc_leitura_registros_bb(pr_cdcooper  IN NUMBER
                                   ,pr_rw_prod   IN risc0003.cr_prod%ROWTYPE
                                   ,pr_dtbase    IN DATE
                                   ,pr_dsinform OUT VARCHAR2
                                   ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_leitura_registros_bb
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Andrei Vieira - Mouts
    --  Data     : Maio/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Aproveitar as informações já importadas dos arquivos BB para
    --             garantias na Central
    --
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Tratamento de exceção
      vr_dscritic varchar2(4000);
      vr_excsaida EXCEPTION;

      -- Calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Busca das Cooperativas ativas
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper
              ,cop.nrctactl
              ,cop.nrdocnpj
          FROM crapcop cop
         WHERE cop.flgativo = 1   -- Somente ativas
           AND cop.cdcooper <> 3; -- Fora da Central
      -- Saldos e Limites e Data
      vr_vlrsaldo NUMBER;
      vr_vlrlimit NUMBER;
      vr_dtmaxvct DATE;
      vr_drminctr DATE;

      -- Buscar nivel ASS
      CURSOR cr_crapass(pr_nrctactl crapcop.nrctactl%TYPE) IS
        SELECT NVL(TRIM(ass.dsnivris),'A') dsnivris
          FROM crapass ass
         WHERE ass.cdcooper = 3   -- Na central
           AND ass.nrdconta = pr_nrctactl;
      vr_dsnivris crapass.dsnivris%TYPE;

      /*-- Verificar existencia de integração de arquivos VIP na singular
      CURSOR cr_riscar(pr_cdcooper NUMBER) IS
        SELECT 1
          FROM tbcrd_risco riscar
         WHERE riscar.cdcooper = pr_cdcooper
           AND riscar.cdtipo_cartao = 2 -- BB
           AND riscar.dtrefere = pr_dtbase;
      vr_indregis NUMBER;*/

      -- Busca dos limites sempre dois meses atrás
      CURSOR cr_limite(pr_cdcooper NUMBER) IS
        SELECT SUM(vlsaldo_devedor)
          FROM TBCRD_RISCO
         WHERE cdcooper = pr_cdcooper
           AND cdtipo_cartao = 2 -- BB
           AND dtrefere = pr_dtbase;

      -- Busca dos Saldos Devedores sempre dois meses atrás
      CURSOR cr_saldo(pr_cdcooper NUMBER) IS
        SELECT SUM(vlsaldo_devedor)
          FROM TBCRD_RISCO
         WHERE cdcooper = pr_cdcooper
           AND cdtipo_cartao = 2 -- BB
           AND dtrefere = pr_dtbase
           AND cdtipo_saldo IN(1);

      -- Buscar datas de contrato e do ultimo vencimento
      CURSOR cr_datas(pr_cdcooper NUMBER) IS
        SELECT min(dtcadastro)
              ,MAX(dtvencimento)
          FROM TBCRD_RISCO
         WHERE cdcooper = pr_cdcooper
           AND cdtipo_cartao = 2 -- BB
           AND dtrefere = pr_dtbase;

      -- Contador de registros
      vr_contador PLS_INTEGER := 0;

    BEGIN

      -- Busca do calendário
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      -- Eliminar os registros deste produto na cooperativa e data
      -- pois as informações serão sobescritas
      BEGIN
        DELETE FROM TBRISCO_PROVISGARANT_MOVTO mov
              WHERE mov.cdcooper  = pr_cdcooper
                AND mov.idproduto = pr_rw_prod.idproduto
                AND mov.dtbase    = pr_dtbase;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao limpar tabela TBRISCO_PROVISGARANT_MOVTO -->'||SQLERRM;
          RAISE vr_excsaida;
      END;

      -- Iniciando LOG
      pr_dsinform := 'Iniciando Importacao - Produto id['||pr_rw_prod.idproduto||']-'||pr_rw_prod.dsproduto||'<br>'
                  || 'Busca de registros criados para os cartoes BB...<br>';

      -- Buscar todas as Cooperativas
      FOR rw_cop IN cr_crapcop LOOP

        -- Verificar se por algum motivo não houve ainda
        -- a integração dos arquivos VIP nesta Singular
        /* REMOVIDO POR QUESTAO DE PERFORMANCE, SE POR ALGUM MOTIVO NÃO OCORRER,
           DEVE SER SUBMETIDO JOB OU ACIONADO POR BACA
        OPEN cr_riscar(pr_cdcooper => rw_cop.cdcooper);
        FETCH cr_riscar
         INTO vr_indregis;
        -- Se não encontrar
        IF cr_riscar%NOTFOUND THEN
          CLOSE cr_riscar;
          -- Como não houve vamos solicitar
          risc0002.pc_gera_risco_cartao_vip_proc(pr_cdcooper => rw_cop.cdcooper
                                                ,pr_cdprogra => 'MOVRGP'
                                                ,pr_dtmvtolt => to_char(rw_crapdat.dtmvtolt,'dd/mm/rrrr')
                                                ,pr_dtrefere => to_char(pr_dtbase,'dd/mm/rrrr'));
        ELSE
          CLOSE cr_riscar;
        END IF;*/

        -- Buscar nivel ASS
        OPEN cr_crapass(rw_cop.nrctactl);
        FETCH cr_crapass
          INTO vr_dsnivris;
        CLOSE cr_crapass;

        -- Buscar Limites
        vr_vlrlimit := 0;
        OPEN cr_limite(rw_cop.cdcooper);
        FETCH cr_limite
         INTO vr_vlrlimit;
        CLOSE cr_limite;
        -- Buscar Saldo Devedor
        vr_vlrsaldo := 0;
        OPEN cr_saldo(rw_cop.cdcooper);
        FETCH cr_saldo
         INTO vr_vlrsaldo;
        CLOSE cr_saldo;
        -- Buscar menor data de contrato e maior vencimento
        vr_drminctr := NULL;
        vr_dtmaxvct := NULL;
        OPEN cr_datas(rw_cop.cdcooper);
        FETCH cr_datas
         INTO vr_drminctr,vr_dtmaxvct;
        CLOSE cr_datas;
        -- Efetuar gravação na tabela de movimento
        BEGIN
          INSERT INTO TBRISCO_PROVISGARANT_MOVTO(cdcooper
                                                ,idproduto
                                                ,dtbase
                                                ,nrdconta
                                                ,nrctremp
                                                ,nrcpfcgc
                                                ,idorigem_recurso
                                                ,idindexador
                                                ,perindexador
                                                ,idgarantia
                                                ,vltaxa_juros
                                                ,dtlib_operacao
                                                ,vloperacao
                                                ,idnat_operacao
                                                ,dtvenc_operacao
                                                ,cdclassifica_operacao
                                                ,qtdparcelas
                                                ,vlparcela
                                                ,dtproxima_parcela
                                                ,vlsaldo_pendente
                                                ,flsaida_operacao)
                                          VALUES(pr_cdcooper
                                                ,pr_rw_prod.idproduto
                                                ,pr_dtbase
                                                ,rw_cop.nrctactl
                                                ,lpad(rw_cop.nrctactl,8,'0')||lpad(pr_rw_prod.idproduto,2,'0')
                                                ,rw_cop.nrdocnpj
                                                ,pr_rw_prod.idorigem_recurso
                                                ,pr_rw_prod.idindexador
                                                ,pr_rw_prod.perindexador
                                                ,pr_rw_prod.idgarantia
                                                ,pr_rw_prod.vltaxa_juros
                                                ,vr_drminctr
                                                ,nvl(vr_vlrlimit,0)
                                                ,pr_rw_prod.idnat_operacao
                                                ,vr_dtmaxvct
                                                ,decode(pr_rw_prod.cdclassifica_operacao,'RS',vr_dsnivris,pr_rw_prod.cdclassifica_operacao)
                                                ,NULL
                                                ,NULL
                                                ,NULL
                                                ,nvl(vr_vlrsaldo,0)
                                                ,decode(pr_rw_prod.flpermite_saida_operacao,1,decode(nvl(vr_vlrsaldo,0),0,1,0),0));
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao criar contratos na tabela TBRISCO_PROVISGARANT_MOVTO -->'||SQLERRM;
            RAISE vr_excsaida;
        END;
        -- Incrementar contador
        vr_contador := vr_contador + 1;
      END LOOP;

      IF vr_contador = 0 THEN
        -- Ao final, gerar texto informativo
        pr_dsinform := pr_dsinform||'Sem registros para integracao na Central.';

      ELSE
        -- Ao final, gerar texto informativo
        pr_dsinform := pr_dsinform||'Total de registros integrados: '||vr_contador||'<br>'
                    || 'Importacao efetuada com sucesso!';

      END IF;
    EXCEPTION
      WHEN vr_excsaida THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'RISC0003.pc_leitura_registros_bb --> Erro nao tratado: '||SQLERRM;
    END;
  END pc_leitura_registros_bb;

  -- Gerar as importar as informações de movimento conforme arquivo passado
  PROCEDURE pc_importa_arquivo(pr_cdcooper  IN NUMBER
                              ,pr_idproduto IN NUMBER
                              ,pr_dtbase    IN DATE
                              ,pr_dsinform OUT VARCHAR2
                              ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_importa_arquivo
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Andrei Vieira - Mouts
    --  Data     : Abril/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Gerar as importar as informações de movimento conforme arquivo passado
    --
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      rw_prod risc0003.cr_prod%ROWTYPE;
    BEGIN
      -- Primeiro checar se o período não está fechado
      IF fn_periodo_habilitado(pr_cdcooper => pr_cdcooper
                              ,pr_dtbase => pr_dtbase) = 0 THEN
        -- Gerar critica 411
        pr_dscritic := gene0001.fn_busca_critica(411);
      ELSE
        -- Buscar a configuração do produto
        OPEN cr_prod(pr_idproduto);
        FETCH cr_prod
         INTO rw_prod;
        -- Se não encontrar
        IF cr_prod%NOTFOUND THEN
          CLOSE cr_prod;
          -- Gerar critica
          pr_dscritic := 'Problema na Importacao -> Produto ID['||pr_idproduto||'] nao cadastrado!';
          RETURN;
        END IF;
        CLOSE cr_prod;
        -- Garantir que o produto seja de importação
        IF lower(rw_prod.tparquivo) = 'nao' THEN
          -- Gerar critica
          pr_dscritic := 'Problema na Importacao -> Produto ID['||pr_idproduto||'] nao permite importacao de arquivo!';
          RETURN;
        ELSE
          -- Importações só podem ser feitas na central
          IF pr_cdcooper <> 3 THEN
            -- Gerar critica
            pr_dscritic := 'Problema na Importacao -> Favor selecionar a Cooperativa 3 - Cecred (Central)!';
            RETURN;
          END IF;
          -- Para Bancoob
          IF lower(rw_prod.tparquivo) = 'cartao_bancoob' THEN
            -- Acionar rotina para importação dos registros Bancoob
            pc_leitura_registros_bancoob(pr_cdcooper  => pr_cdcooper
                                        ,pr_rw_prod   => rw_prod
                                        ,pr_dtbase    => pr_dtbase
                                        ,pr_dsinform  => pr_dsinform
                                        ,pr_dscritic  => pr_dscritic);
          -- Para BB
          ELSIF lower(rw_prod.tparquivo) = 'cartao_bb' THEN
            -- Acionar rotina para importação dos registros Bancoob
            pc_leitura_registros_bb(pr_cdcooper  => pr_cdcooper
                                   ,pr_rw_prod   => rw_prod
                                   ,pr_dtbase    => pr_dtbase
                                   ,pr_dsinform  => pr_dsinform
                                   ,pr_dscritic  => pr_dscritic);
          ELSE
            -- Será BRDE
            pc_importa_arq_layout_brde(pr_cdcooper  => pr_cdcooper
                                      ,pr_rw_prod   => rw_prod
                                      ,pr_dtbase    => pr_dtbase
                                      ,pr_dsinform  => pr_dsinform
                                      ,pr_dscritic  => pr_dscritic);
          END IF;

          -- Tratar erros
          IF pr_dscritic IS NOT NULL THEN
            pr_dscritic := 'Problema na Importacao -> '||pr_dscritic;
            -- Desfazer alterações e retornar
            ROLLBACK;
            RETURN;
          ELSE
            -- Commitar e retornar
            COMMIT;
            RETURN;
          END IF;
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'RISC0003.pc_importa_arquivo --> Problema na Importacao -> '||SQLERRM;
        -- Desfazer alterações e retornar
        ROLLBACK;
    END;

  END pc_importa_arquivo;


  PROCEDURE pc_grava_crapris_temporaria(pr_cdcooper          IN tbcrd_risco.cdcooper%TYPE         -- Codigo da cooperativa
                                       ,pr_nrdconta          IN tbcrd_risco.nrdconta%TYPE         -- Numero da conta
                                       ,pr_inpessoa          IN crapris.inpessoa%TYPE             -- Tipo de pessoa
                                       ,pr_nrcontrato        IN tbcrd_risco.nrcontrato%TYPE       -- Numero do contrato
                                       ,pr_nrseqctr          IN crapris.nrseqctr%TYPE             -- Sequencia contrato
                                       ,pr_cdagencia         IN crapris.cdagenci%TYPE             -- Numero da agencia
                                       ,pr_nrcpfcnpj         IN tbcrd_risco.nrcpfcnpj%TYPE        -- CPF/CNPJ
                                       ,pr_nrmodalidade      IN tbcrd_risco.nrmodalidade%TYPE     -- Codigo da modalidade
                                       ,pr_dtultdma_util     IN DATE                              -- Ultima dia util do mes anterior
                                       ,pr_dsnivel_risco     IN VARCHAR2                          -- Nivel do Risco
                                       ,pr_dtcadastro        IN tbcrd_risco.dtcadastro%TYPE       -- Data de abertura da conta cartao
                                       ,pr_dtvencimento      IN tbcrd_risco.dtvencimento%TYPE     -- Data de vencimento
                                       ,pr_vlsaldo_devedor   IN tbcrd_risco.vlsaldo_devedor%TYPE  -- Saldo Devedor
                                       ,pr_dtprxpar          IN crapris.dtprxpar%TYPE             -- Data proxima parcela
                                       ,pr_vlprxpar          IN crapris.vlprxpar%TYPE             -- Valor proxima parcela
                                       ,pr_qtparcel          IN crapris.qtparcel%TYPE             -- Quantidade de parcelas
                                       ,pr_cdinfadi          IN crapris.cdinfadi%TYPE             -- Saida de operação
                                       ,pr_dsinfaux          IN crapris.dsinfaux%TYPE             -- Informação auxiliar
                                       ,pr_calcparc          IN BOOLEAN                           -- Inidica se calcularemos as parcelas ou não
                                       ,pr_tab_risco      IN OUT NOCOPY risc0003.typ_tab_risco      --> Temp-Table dos Riscos
                                       ,pr_tab_risco_venc IN OUT NOCOPY risc0003.typ_tab_risco_venc --> Risco de vencimentos
                                       ,pr_cdcritic          OUT PLS_INTEGER                     --> Código da critica
                                       ,pr_dscritic          OUT VARCHAR2) IS                    --> Descricao da critica IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_grava_crapris_temporaria
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : James Prust Junior
    --  Data     : Fevereiro/2016.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para gravar os dados na crapris temporaria
    --
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_ind_risco          VARCHAR2(60);
      vr_indice             VARCHAR2(70);
      vr_cdvencto           NUMBER;
      vr_vlparcel           NUMBER := 0;
      vr_vlsdeved           NUMBER := 0;
      vr_diasvenc           NUMBER := 0;
      vr_dtparcel           date;

      -- Variaveis tratamento de erro
      vr_exc_erro           EXCEPTION;
      vr_cdcritic           crapcri.cdcritic%TYPE;
      vr_dscritic           VARCHAR2(4000);


      vr_vldiv060     crapris.vldiv060%TYPE := 0; --> Valor do atraso quando prazo inferior a 60
      vr_vldiv180     crapris.vldiv180%TYPE := 0; --> Valor do atraso quando prazo inferior a 180
      vr_vldiv360     crapris.vldiv360%TYPE := 0; --> Valor do atraso quando prazo inferior a 360
      vr_vldiv999     crapris.vldiv999%TYPE := 0; --> Valor do atraso para outros casos
      vr_vlvec180     crapris.vlvec180%TYPE := 0; --> Valor a vencer nos próximos 180 dias
      vr_vlvec360     crapris.vlvec360%TYPE := 0; --> Valor a vencer nos próximos 360 dias
      vr_vlvec999     crapris.vlvec999%TYPE := 0; --> Valor a vencer para outros casos
      vr_vlprjano     crapris.vlprjano%TYPE := 0; --> Valor prejuizo no ano corrente
      vr_vlprjaan     crapris.vlprjaan%TYPE := 0; --> Valor prejuizo no ano anterior
      vr_vlprjant     crapris.vlprjant%TYPE := 0; --> Valor prejuizo anterior

      -- Vetor para armazenar parcelas
      TYPE typ_reg_parcel IS
        RECORD(dtvencto DATE
              ,cdvencto NUMBER
              ,vlvencto NUMBER);
      TYPE typ_tab_parcel IS
        TABLE OF typ_reg_parcel
          INDEX BY BINARY_INTEGER; --> Id
      vr_tab_parcel typ_tab_parcel;

      -- Calcula os dias de atraso do cartao de credito
      FUNCTION fn_calcula_dias_atraso(pr_dtvencimento  IN DATE
                                     ,pr_dtultdma_util IN DATE) RETURN NUMBER IS
      BEGIN
        IF (pr_dtvencimento - pr_dtultdma_util) <= 0 THEN
          RETURN ABS(pr_dtvencimento - pr_dtultdma_util);
        END IF;

        RETURN 0;
      END;

      -- Subrotina para calculo do código de vencimento
      FUNCTION fn_calc_codigo_vcto(pr_diasvenc IN OUT NUMBER
                                  ,pr_qtdiapre IN NUMBER DEFAULT 0
                                  ,pr_flgempre IN BOOLEAN DEFAULT FALSE) RETURN NUMBER IS
      BEGIN
        -- Se for crédito a vencer
        IF pr_diasvenc >= 0  THEN
          IF  pr_diasvenc <= 30 THEN
            RETURN 110;
          ELSIF pr_diasvenc <= 60 THEN
            IF pr_qtdiapre <= 30 AND pr_flgempre THEN
              RETURN 110;
            ELSE
             RETURN 120;
            END IF;
          ELSIF pr_diasvenc <= 90 THEN
            IF pr_qtdiapre <= 60 AND pr_flgempre THEN
              RETURN 120;
            ELSE
              RETURN 130;
            END IF;
          ELSIF pr_diasvenc <= 180 THEN
            IF pr_qtdiapre <= 90 AND pr_flgempre THEN
              RETURN 130;
            ELSE
              RETURN 140;
            END IF;
          ELSIF pr_diasvenc <= 360 THEN
            IF pr_qtdiapre <= 180 AND pr_flgempre THEN
              RETURN 140;
            ELSE
              RETURN 150;
            END IF;
          ELSIF pr_diasvenc <= 720 THEN
            IF pr_qtdiapre <= 360 AND pr_flgempre THEN
              RETURN 150;
            ELSE
              RETURN 160;
            END IF;
          ELSIF pr_diasvenc <= 1080 THEN
            IF pr_qtdiapre <= 720 AND pr_flgempre THEN
              RETURN 160;
            ELSE
              RETURN 165;
            END IF;
          ELSIF  pr_diasvenc <= 1440 THEN
            IF pr_qtdiapre <= 1080 AND pr_flgempre THEN
              RETURN 165;
            ELSE
              RETURN 170;
            END IF;
          ELSIF pr_diasvenc <= 1800 THEN
            IF pr_qtdiapre <= 1440 AND pr_flgempre THEN
              RETURN 170;
            ELSE
              RETURN 175;
            END IF;
          ELSIF pr_diasvenc <= 5400 THEN
            IF pr_qtdiapre <= 1800 AND pr_flgempre THEN
              RETURN 175;
            ELSE
              RETURN 180;
            END IF;
          ELSIF pr_qtdiapre <= 5400 AND pr_flgempre THEN
            RETURN 180;
          ELSE
            RETURN 190;
          END IF;
        ELSE -- Creditos Vencidos
          -- Multiplicar por -1 para que os dias fiquem no passado
          pr_diasvenc := pr_diasvenc * -1;
          IF pr_diasvenc <= 14 THEN
            RETURN 205;
          ELSIF pr_diasvenc <= 30 THEN
            RETURN 210;
          ELSIF pr_diasvenc <= 60 THEN
            RETURN 220;
          ELSIF pr_diasvenc <= 90 THEN
            RETURN 230;
          ELSIF pr_diasvenc <= 120 THEN
            RETURN 240;
          ELSIF pr_diasvenc <= 150 THEN
            RETURN 245;
          ELSIF pr_diasvenc <= 180 THEN
            RETURN 250;
          ELSIF pr_diasvenc <= 240 THEN
            RETURN 255;
          ELSIF pr_diasvenc <= 300 THEN
            RETURN 260;
          ELSIF pr_diasvenc <= 360 THEN
            RETURN 270;
          ELSIF pr_diasvenc <= 540 THEN
            RETURN 280;
          ELSE
            RETURN 290;
          END IF;
        END IF;
      END;


    BEGIN
      vr_ind_risco := LPAD(pr_nrdconta,20,'0') || LPAD(pr_nrcontrato,20,'0') || LPAD(pr_nrmodalidade,10,'0') ||lpad(pr_nrseqctr,10,'0');
      IF NOT pr_tab_risco.EXISTS(vr_ind_risco) THEN
        pr_tab_risco(vr_ind_risco).cdcooper     := pr_cdcooper;
        pr_tab_risco(vr_ind_risco).nrdconta     := pr_nrdconta;
        pr_tab_risco(vr_ind_risco).nrcontrato   := pr_nrcontrato;
        pr_tab_risco(vr_ind_risco).nrseqctr     := pr_nrseqctr;
        pr_tab_risco(vr_ind_risco).nrmodalidade := pr_nrmodalidade;
        pr_tab_risco(vr_ind_risco).dtcadastro   := pr_dtcadastro;
        pr_tab_risco(vr_ind_risco).inpessoa     := pr_inpessoa;
        pr_tab_risco(vr_ind_risco).dtvencimento := pr_dtvencimento;
        pr_tab_risco(vr_ind_risco).dtvencop     := pr_dtvencimento;
        pr_tab_risco(vr_ind_risco).cdagencia    := pr_cdagencia;
        pr_tab_risco(vr_ind_risco).qtdiaatr     := 0;
        pr_tab_risco(vr_ind_risco).nrcpfcgc     := pr_nrcpfcnpj;
        pr_tab_risco(vr_ind_risco).vldivida     := 0;
        pr_tab_risco(vr_ind_risco).dtprxpar     := pr_dtprxpar;
        pr_tab_risco(vr_ind_risco).vlprxpar     := pr_vlprxpar;
        pr_tab_risco(vr_ind_risco).qtparcel     := pr_qtparcel;
        pr_tab_risco(vr_ind_risco).flgindiv     := 0;
        pr_tab_risco(vr_ind_risco).cdinfadi     := pr_cdinfadi;
        pr_tab_risco(vr_ind_risco).dsinfaux     := pr_dsinfaux;
      ELSE
        -- Data de vencimento da operacao
        IF (pr_dtvencimento > pr_tab_risco(vr_ind_risco).dtvencop) THEN
          pr_tab_risco(vr_ind_risco).dtvencop := pr_dtvencimento;
        END IF;

        -- Menor data de vencimento
        IF (pr_dtvencimento < pr_tab_risco(vr_ind_risco).dtvencimento) THEN
          pr_tab_risco(vr_ind_risco).dtvencimento := pr_dtvencimento;
        END IF;

      END IF;

      pr_tab_risco(vr_ind_risco).vldivida := pr_tab_risco(vr_ind_risco).vldivida + NVL(pr_vlsaldo_devedor,0);

      -- Calculo da quantidade de dias em atraso somente quando há saldo
      IF pr_tab_risco(vr_ind_risco).vldivida > 0 THEN
        pr_tab_risco(vr_ind_risco).qtdiaatr := fn_calcula_dias_atraso(pr_dtvencimento  => pr_tab_risco(vr_ind_risco).dtvencimento
                                                                     ,pr_dtultdma_util => pr_dtultdma_util);
      END IF;

      -- Calculo do nivel de risco
      pr_tab_risco(vr_ind_risco).innivris := fn_calcula_nivel_risco(pr_dsnivel_risco);

      -- Saída ou Operação sem Saldo não necessita VRI
      IF pr_cdinfadi != '0301' AND pr_tab_risco(vr_ind_risco).vldivida > 0 THEN

        -- Se operação vencida ou Para cartões ou Remessas sem Fluxo Financeiro
        IF pr_tab_risco(vr_ind_risco).qtdiaatr > 0 OR NOT pr_calcparc THEN
          -- Sem atraso
          IF pr_tab_risco(vr_ind_risco).qtdiaatr > 0 THEN
            -- Multiplicar por -1 para significar atraso
            pr_tab_risco(vr_ind_risco).qtdiaatr := pr_tab_risco(vr_ind_risco).qtdiaatr *-1;
          ELSE
            -- Para cartões ou sem Fluxo Financeiro, não há atraso
            pr_tab_risco(vr_ind_risco).qtdiaatr := 0;
          END IF;

          -- Calcular o código do vencimento conforme dias de atraso
          vr_cdvencto := fn_calc_codigo_vcto(pr_diasvenc => pr_tab_risco(vr_ind_risco).qtdiaatr);

          -- Posicionar
          IF pr_tab_risco(vr_ind_risco).qtdiaatr = 0 THEN
            vr_vlvec180 := vr_vlvec180 + pr_tab_risco(vr_ind_risco).vldivida;
          ELSIF pr_tab_risco(vr_ind_risco).qtdiaatr <= 60 THEN
            vr_vldiv060 := vr_vldiv060 + pr_tab_risco(vr_ind_risco).vldivida;
          ELSIF pr_tab_risco(vr_ind_risco).qtdiaatr <= 180 THEN
            vr_vldiv180 := vr_vldiv180 + pr_tab_risco(vr_ind_risco).vldivida;
          ELSIF pr_tab_risco(vr_ind_risco).qtdiaatr <= 360 THEN
            vr_vldiv360 := vr_vldiv360 + pr_tab_risco(vr_ind_risco).vldivida;
          ELSE
            vr_vldiv999 := vr_vldiv999 + pr_tab_risco(vr_ind_risco).vldivida;
          END IF;

          -- Criar o único registro na VRI lançando todo o saldo vencido
          vr_indice    := LPAD(pr_nrdconta,20,'0') || LPAD(pr_nrcontrato,20,'0') || lpad(pr_nrmodalidade,10,'0') ||lpad(pr_nrseqctr,10,'0') || LPAD(vr_cdvencto,10,'0');
          IF NOT pr_tab_risco_venc.EXISTS(vr_indice) THEN
            pr_tab_risco_venc(vr_indice).cdcooper     := pr_cdcooper;
            pr_tab_risco_venc(vr_indice).nrdconta     := pr_nrdconta;
            pr_tab_risco_venc(vr_indice).nrcontrato   := pr_nrcontrato;
            pr_tab_risco_venc(vr_indice).nrseqctr     := pr_nrseqctr;
            pr_tab_risco_venc(vr_indice).innivris     := pr_tab_risco(vr_ind_risco).innivris;
            pr_tab_risco_venc(vr_indice).nrmodalidade := pr_nrmodalidade;
            pr_tab_risco_venc(vr_indice).cdvencto     := vr_cdvencto;
            pr_tab_risco_venc(vr_indice).vldivida     := 0;
          END IF;
          pr_tab_risco_venc(vr_indice).vldivida := pr_tab_risco_venc(vr_indice).vldivida + NVL(pr_vlsaldo_devedor,0);

        ELSE
          -- Calcular quantas parcelas serão necessárias para a quitação
          vr_vlsdeved := pr_tab_risco(vr_ind_risco).vldivida;
          vr_tab_parcel.delete();
          vr_dtparcel := nvl(pr_tab_risco(vr_ind_risco).dtprxpar,pr_dtultdma_util+1);
          -- Adicionar primeira parcela
          vr_tab_parcel(0).dtvencto := vr_dtparcel;
          LOOP
            -- Próxima data
            vr_dtparcel := add_months(vr_dtparcel,1);
            -- Sair quando próxima ultrapassar o vencimento
            EXIT WHEN vr_dtparcel > pr_tab_risco(vr_ind_risco).dtvencimento;
            -- Adicionar ao vetor
            vr_tab_parcel(vr_tab_parcel.count()).dtvencto := vr_dtparcel;
          END LOOP;
          -- Calcular o valor da parcela
          IF vr_tab_parcel.count() = 1 THEN
            -- Valor da parcela é o saldo devedor
            vr_vlparcel := pr_tab_risco(vr_ind_risco).vldivida;
          ELSE
            -- Dividir valor da divida pela quantidade parcelas
            vr_vlparcel := round(pr_tab_risco(vr_ind_risco).vldivida / vr_tab_parcel.count(),2);
          END IF;
          -- Para cada parcela
          FOR vr_idx IN 0..vr_tab_parcel.count()-1 LOOP
            -- Calcular o código do vencimento conforme dias até próxima parcela
            vr_diasvenc := vr_tab_parcel(vr_idx).dtvencto-(pr_dtultdma_util+1);
            vr_tab_parcel(vr_idx).cdvencto := fn_calc_codigo_vcto(pr_diasvenc => vr_diasvenc);

            -- Na ultima parcela
            IF vr_idx = vr_tab_parcel.count()-1 THEN
              -- Utilizar o resto
              vr_tab_parcel(vr_idx).vlvencto := vr_vlsdeved;
            ELSE
              -- Utilizar valor da parcela
              vr_tab_parcel(vr_idx).vlvencto := vr_vlparcel;
              -- Decrementar
              vr_vlsdeved := vr_vlsdeved - vr_vlparcel;
            END IF;
            -- Acumular na variavel correspondente de acordo com a quantidade de dias
            IF vr_diasvenc <= 180 THEN
              vr_vlvec180 := vr_vlvec180 + vr_tab_parcel(vr_idx).vlvencto;
            ELSIF vr_diasvenc <= 360 THEN
              vr_vlvec360 := vr_vlvec360 + vr_tab_parcel(vr_idx).vlvencto;
            ELSE
              vr_vlvec999 := vr_vlvec999 + vr_tab_parcel(vr_idx).vlvencto;
            END IF;
          END LOOP;

          -- Iterar novamente para criação da VRI
          FOR vr_idx IN 0..vr_tab_parcel.count()-1 LOOP
            vr_indice    := LPAD(pr_nrdconta,20,'0') || LPAD(pr_nrcontrato,20,'0') || lpad(pr_nrmodalidade,10,'0') ||lpad(pr_nrseqctr,10,'0') || LPAD(vr_tab_parcel(vr_idx).cdvencto,10,'0');
            IF NOT pr_tab_risco_venc.EXISTS(vr_indice) THEN
              pr_tab_risco_venc(vr_indice).cdcooper     := pr_cdcooper;
              pr_tab_risco_venc(vr_indice).nrdconta     := pr_nrdconta;
              pr_tab_risco_venc(vr_indice).nrcontrato   := pr_nrcontrato;
              pr_tab_risco_venc(vr_indice).nrseqctr     := pr_nrseqctr;
              pr_tab_risco_venc(vr_indice).innivris     := pr_tab_risco(vr_ind_risco).innivris;
              pr_tab_risco_venc(vr_indice).nrmodalidade := pr_nrmodalidade;
              pr_tab_risco_venc(vr_indice).cdvencto     := vr_tab_parcel(vr_idx).cdvencto;
              pr_tab_risco_venc(vr_indice).vldivida     := 0;
            END IF;
            pr_tab_risco_venc(vr_indice).vldivida := pr_tab_risco_venc(vr_indice).vldivida + NVL(vr_tab_parcel(vr_idx).vlvencto,0);
          END LOOP;
        END IF;
      END IF;

      -- Gravar nos campos de vencimentos, a vencer, e projeções
      pr_tab_risco(vr_ind_risco).vlvec180 := nvl(vr_vlvec180,0);
      pr_tab_risco(vr_ind_risco).vlvec360 := nvl(vr_vlvec360,0);
      pr_tab_risco(vr_ind_risco).vlvec999 := nvl(vr_vlvec999,0);
      pr_tab_risco(vr_ind_risco).vldiv060 := nvl(vr_vldiv060,0);
      pr_tab_risco(vr_ind_risco).vldiv180 := nvl(vr_vldiv180,0);
      pr_tab_risco(vr_ind_risco).vldiv360 := nvl(vr_vldiv360,0);
      pr_tab_risco(vr_ind_risco).vldiv999 := nvl(vr_vldiv999,0);
      pr_tab_risco(vr_ind_risco).vlprjano := nvl(vr_vlprjano,0);
      pr_tab_risco(vr_ind_risco).vlprjaan := nvl(vr_vlprjaan,0);
      pr_tab_risco(vr_ind_risco).vlprjant := nvl(vr_vlprjant,0);

    EXCEPTION
      WHEN vr_exc_erro THEN
        --Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Descricao do erro
        pr_dscritic := 'Erro nao tratado na risc0003.pc_grava_crapris_temporaria ' || SQLERRM;
    END;

  END pc_grava_crapris_temporaria;

  /* Arrastar o risco dos contratos após integração inddocto=5 */
  PROCEDURE pc_efetua_arrasto_docto5(pr_cdcooper IN crapcop.cdcooper%TYPE  --> codigo da cooperativa
                                    ,pr_dtrefere IN DATE                   --> Data de Referencia
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da critica
                                    ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_efetua_arrasto_docto5
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : James Prust Junior
    --  Data     : Fevereiro/2016.                   Ultima atualizacao: 24/10/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Efetua o arrasto das operacoes
    --
    -- Alterações: 24/10/2017 - Atualizacao do Grupo Economico fora do loop da crapris com valor de arrasto.
    --                          (Jaison/James)
    ---------------------------------------------------------------------------------------------------------------
    DECLARE

      CURSOR cr_upd_ris(pr_cdcooper IN crapris.cdcooper%TYPE
                       ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
        SELECT crapris.ROWID
              ,crapris.nrcpfcgc
          FROM crapris
         WHERE crapris.cdcooper = pr_cdcooper
           AND crapris.dtrefere = pr_dtrefere
           AND crapris.inddocto = 5;

      CURSOR cr_max_ris(pr_cdcooper IN crapris.cdcooper%TYPE
                       ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
        SELECT NVL(MAX(crapris.nrdgrupo),0) nrdgrupo
              ,crapris.nrcpfcgc
          FROM crapris
         WHERE crapris.cdcooper = pr_cdcooper
           AND crapris.dtrefere = pr_dtrefere
           AND crapris.inddocto IN (1,3)
      GROUP BY crapris.nrcpfcgc;

      TYPE typ_tab_max_ris IS TABLE OF crapris.nrdgrupo%TYPE INDEX BY VARCHAR2(25);

      TYPE typ_upd_ris IS RECORD (regrowid ROWID
                                 ,nrdgrupo crapris.nrdgrupo%TYPE);
      TYPE typ_tab_upd_ris IS TABLE OF typ_upd_ris INDEX BY PLS_INTEGER;

      vr_tab_grupo    typ_tab_max_ris;
      vr_tab_upris    typ_tab_upd_ris;

      -- Auxiliares
      vr_dstextab     craptab.dstextab%TYPE;
      vr_innivris     crapris.innivris%TYPE;
      vr_vlarrasto    NUMBER;
      vr_fcrapris     BOOLEAN;
      vr_ind_upris    PLS_INTEGER;

      -- Variaveis tratamento de erro
      vr_exc_erro     EXCEPTION;
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     VARCHAR2(4000);
    BEGIN
      -- Chamar função que busca o dstextab para retornar o valor de arrasto
      -- no parâmetro de sistema RISCOBACEN
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'RISCOBACEN'
                                               ,pr_tpregist => 000);
      -- Se a variavel voltou vazia
      IF vr_dstextab IS NULL THEN
        vr_cdcritic := 55;
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;
      -- Por fim, tenta converter o valor de arrasto presente na posição 3 até 12
      vr_vlarrasto := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,3,9));
      -- Efetua o arrasto para as operacoes acima do valor de arrasto
      FOR rw_crapris IN cr_crapris(pr_cdcooper  => pr_cdcooper
                                  ,pr_dtrefere  => pr_dtrefere
                                  ,pr_vlarrasto => vr_vlarrasto) LOOP

        -- Para o primeiro registro da conta
        IF rw_crapris.sequencia = 1 THEN
          -- Risco calculado do cartao de credito
          vr_innivris := rw_crapris.innivris;
          -- Vamos verificar se possui operacao na mensal acima do valor de arrasto
          OPEN cr_crapris_last(pr_cdcooper => rw_crapris.cdcooper
                              ,pr_nrdconta => rw_crapris.nrdconta
                              ,pr_dtrefere => pr_dtrefere
                              ,pr_vlarrast => vr_vlarrasto);
          FETCH cr_crapris_last INTO rw_crapris_last;
          vr_fcrapris := cr_crapris_last%FOUND;
          CLOSE cr_crapris_last;
          -- Condicao para verificar se existe registro
          IF vr_fcrapris THEN
            vr_innivris := rw_crapris_last.innivris;
          ELSE
            -- Vamos verificar se possui operacao na mensal abaixo de 100,00
            OPEN cr_crapris_last(pr_cdcooper => rw_crapris.cdcooper
                                ,pr_nrdconta => rw_crapris.nrdconta
                                ,pr_dtrefere => pr_dtrefere
                                ,pr_vlarrast => 0);
            FETCH cr_crapris_last INTO rw_crapris_last;
            vr_fcrapris := cr_crapris_last%FOUND;
            CLOSE cr_crapris_last;
            -- Condicao para verificar se existe registro
            IF vr_fcrapris THEN
              vr_innivris := rw_crapris_last.innivris;
            END IF;
          END IF;

        END IF; /* END IF rw_crapris.sequencia = 1 THEN */

        -- Prejuizo
        IF vr_innivris = 10 THEN
          vr_innivris := 9;
        END IF;

        -- Somente arrastar as operações que não estão enquadradas no risco AA
        -- OU que não estejam em Prejuizo (HH), pois este deverá permanecer HH
        IF rw_crapris.innivris > 1 AND rw_crapris.innivris < 10 THEN

          -- Atualizar o risco no contrato
          BEGIN
            UPDATE crapris
               SET innivris = vr_innivris
                  ,inindris = vr_innivris
             WHERE rowid = rw_crapris.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar a tabela crapris. --> '
                             || 'Conta: '||rw_crapris.nrdconta||', Rowid: '||rw_crapris.rowid
                             || '. Detalhes:'||sqlerrm;
              RAISE vr_exc_erro;
          END;

          -- Atualizar o risco no vencimento
          BEGIN
            UPDATE crapvri
               SET innivris = vr_innivris
             WHERE cdcooper = rw_crapris.cdcooper
               AND nrdconta = rw_crapris.nrdconta
               AND nrctremp = rw_crapris.nrctremp
               AND cdmodali = rw_crapris.cdmodali
               AND dtrefere = rw_crapris.dtrefere
               AND nrseqctr = rw_crapris.nrseqctr;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar a tabela crapvri. --> '
                             || 'Conta: '||rw_crapris.nrdconta||', Rowid: '||rw_crapris.rowid
                             || '. Detalhes:'||sqlerrm;
              RAISE vr_exc_erro;
          END;
        END IF;

      END LOOP; -- Fim riscos

      -- Carrega maior grupo economico do CPF/CNPJ
      FOR rw_max_ris IN cr_max_ris(pr_cdcooper => pr_cdcooper
                                  ,pr_dtrefere => pr_dtrefere) LOOP
        vr_tab_grupo(rw_max_ris.nrcpfcgc) := rw_max_ris.nrdgrupo;
      END LOOP;

      -- Listagem dos registros
      FOR rw_upd_ris IN cr_upd_ris(pr_cdcooper => pr_cdcooper
                                  ,pr_dtrefere => pr_dtrefere) LOOP
        -- Se existir o CPF/CNPJ nos grupos carregados
        IF vr_tab_grupo.EXISTS(rw_upd_ris.nrcpfcgc) THEN
          -- Se grupo maior que zero, carrega na tabela para update
          IF vr_tab_grupo(rw_upd_ris.nrcpfcgc) > 0 THEN
            vr_ind_upris := vr_tab_upris.COUNT + 1;
            vr_tab_upris(vr_ind_upris).regrowid := rw_upd_ris.ROWID;
            vr_tab_upris(vr_ind_upris).nrdgrupo := vr_tab_grupo(rw_upd_ris.nrcpfcgc);
          END IF;
        END IF;
      END LOOP;

      -- Atualizar registros
      BEGIN
        FORALL idx IN 1..vr_tab_upris.COUNT SAVE EXCEPTIONS
        UPDATE crapris
           SET nrdgrupo = vr_tab_upris(idx).nrdgrupo
         WHERE ROWID    = vr_tab_upris(idx).regrowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar crapris: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
          RAISE vr_exc_erro;
      END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Descricao do erro
        pr_dscritic := 'Erro nao tratado na RISC0003.pc_efetua_arrasto_docto5 ' || SQLERRM;
    END;

  END pc_efetua_arrasto_docto5;

  /* Gerar os contratos de risco com base nas informações cadastradas ou importadas na tela MOVRGP */
  PROCEDURE pc_fecham_risco_garantia_prest(pr_cdcooper   IN crapcop.cdcooper%TYPE        --> codigo da cooperativa
                                          ,pr_dtrefere   IN DATE                         --> Data de Referencia
                                          ,pr_cdcritic   OUT PLS_INTEGER                 --> Código da critica
                                          ,pr_dscritic   OUT VARCHAR2) IS                --> Descricao da critica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_fecham_risco_garantia_prest
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Andrei Vieira
    --  Data     : Maio/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Converter os movimentos criados na tabela tbrisco_provisgarant_movto para crapris
    --
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
    DECLARE

    ----------------------------- CURSORES -------------------------------

      -- Busca as cooperativas
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdagebcb
              ,crapcop.nmrescop
              ,crapcop.dsdircop
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Busca dos associados unindo com seu saldo na conta
      CURSOR cr_crapass IS
        SELECT crapass.nrdconta,
               crapass.cdagenci,
               crapass.inpessoa,
               crapass.nrcpfcgc
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND EXISTS(SELECT 1
                        FROM tbrisco_provisgarant_movto
                       WHERE tbrisco_provisgarant_movto.cdcooper = crapass.cdcooper
                         AND tbrisco_provisgarant_movto.nrdconta = crapass.nrdconta
                         AND tbrisco_provisgarant_movto.dtbase   = pr_dtrefere);

      TYPE typ_crapass_bulk IS TABLE OF cr_crapass%ROWTYPE INDEX BY PLS_INTEGER;
      vr_crapass_bulk typ_crapass_bulk;

      -- Verificar se existe lançamento sem conta
      CURSOR cr_movto_sem_conta IS
        SELECT 1
          FROM tbrisco_provisgarant_movto mvto
         WHERE mvto.cdcooper  = pr_cdcooper
           AND mvto.dtbase    = pr_dtrefere
           AND mvto.nrdconta  = 0;
      vr_exis_cta_zero NUMBER;

      -- Busca os movimentos lançados para a data de referência
      CURSOR cr_movto IS
        SELECT mvto.idmovto_risco
              ,mvto.idproduto
              ,mvto.cdcooper
              ,mvto.nrdconta
              ,mvto.nrctremp
              ,mvto.nrcpfcgc
              ,mvto.cdclassifica_operacao
              ,mvto.dtvenc_operacao
              ,mvto.vlsaldo_pendente
              ,fn_valor_opcao_dominio(prod.idmodalidade) nrmodalidade
              ,mvto.dtproxima_parcela
              ,mvto.vlparcela
              ,mvto.qtdparcelas
              ,mvto.dtlib_operacao
              ,upper(prod.tparquivo) tparquivo
              ,prod.flpermite_fluxo_financeiro
              ,decode(mvto.flsaida_operacao,1,'0301',' ') cdinfadi
              ,ROW_NUMBER ()
                 OVER (PARTITION BY mvto.nrdconta/*,mvto.nrctremp,prod.idmodalidade*/
                           ORDER BY mvto.nrdconta/*,mvto.nrctremp,prod.idmodalidade*/) nrseqctr
          FROM tbrisco_provisgarant_prodt prod
              ,tbrisco_provisgarant_movto mvto
         WHERE mvto.idproduto = prod.idproduto
           AND mvto.cdcooper  = pr_cdcooper
           AND mvto.dtbase    = pr_dtrefere
         ORDER BY mvto.nrdconta/*
                 ,mvto.nrctremp
                 ,risc0003.fn_valor_opcao_dominio(prod.idmodalidade)*/;

    ----------------- TIPOS E REGISTROS -------------------

      -- Definicao dos registros da tabela crapass
      TYPE typ_reg_crapass IS
        RECORD(inpessoa crapass.inpessoa%TYPE
              ,cdagenci crapass.cdagenci%TYPE
              ,nrcpfcgc crapass.nrcpfcgc%TYPE);

      TYPE typ_tab_crapass IS
        TABLE OF typ_reg_crapass
          INDEX BY VARCHAR2(50);

      -- Tabela para armazenar os registros do arquivo
      vr_tab_risco           typ_tab_risco;
      vr_tab_risco_temp      typ_tab_risco_temp;
      vr_tab_risco_venc      typ_tab_risco_venc;
      vr_tab_risco_venc_temp typ_tab_risco_venc_temp;
      vr_tab_crapass         typ_tab_crapass;

      -------------------------- Variaveis ----------------------------------------
      vr_indice               VARCHAR2(70);
      vr_ind_crapvri          VARCHAR2(70);
      vr_dtultdma_util        DATE;                             -- Data do ultimo dia util do mes anterior
      vr_calcparc             BOOLEAN;
      -- Variaveis de Erro
      vr_cdcritic             crapcri.cdcritic%TYPE;
      vr_dscritic             VARCHAR2(4000);

      -- Variaveis Excecao
      vr_exc_erro             EXCEPTION;
    BEGIN
      vr_tab_crapass.DELETE;

      -- Ignorar o parâmetro financeiro, para checarmos se a central de risco está liberada
      IF fn_periodo_habilitado(pr_cdcooper => pr_cdcooper
                              ,pr_dtbase   => pr_dtrefere
                              ,pr_prmfinan => FALSE) = 0 THEN
        -- Gerar critica 411
        vr_cdcritic := 411;
        RAISE vr_exc_erro;
      END IF;

      -- Se a digitação já estiver fechada
      IF fn_periodo_habilitado(pr_cdcooper => pr_cdcooper
                              ,pr_dtbase => pr_dtrefere) = 0 THEN
        -- Nao conseguiremos reabrir a digitação pois a TAB principal já não está liberada
        vr_dscritic := 'Periodo de digitacao nao liberado - Nao eh necessario fecha-lo!';
        RAISE vr_exc_erro;
      END IF;

      -- Ultima data util do mes anterior
      vr_dtultdma_util := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper, -- Cooperativa
                                                      pr_dtmvtolt  => pr_dtrefere, -- Data de referencia
                                                      pr_tipo      => 'A');
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Verificar se existe lançamentos sem conta
      OPEN cr_movto_sem_conta;
      FETCH cr_movto_sem_conta
       INTO vr_exis_cta_zero;
      -- Se encontrar
      IF cr_movto_sem_conta%FOUND THEN
        -- Gerar critica
        CLOSE cr_movto_sem_conta;
        vr_dscritic := 'Existe movimentos sem Conta - Favor ajustar o cadastro dos mesmos!';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_movto_sem_conta;
      END IF;

      -- Buscar todas os tipos de pessoa
      OPEN cr_crapass;
      LOOP
        FETCH cr_crapass BULK COLLECT INTO vr_crapass_bulk LIMIT 50000; -- carrega de 50 em 50 mil registros
        EXIT WHEN vr_crapass_bulk.COUNT = 0;
        IF vr_crapass_bulk.COUNT > 0 THEN
          -- percorre a PLTABLE refazendo o indice com a composicao dos campos
          FOR idx IN vr_crapass_bulk.FIRST..vr_crapass_bulk.LAST LOOP
            -- Armazenar na tabela de memória
            vr_tab_crapass(vr_crapass_bulk(idx).nrdconta).inpessoa := vr_crapass_bulk(idx).inpessoa;
            vr_tab_crapass(vr_crapass_bulk(idx).nrdconta).cdagenci := vr_crapass_bulk(idx).cdagenci;
            vr_tab_crapass(vr_crapass_bulk(idx).nrdconta).nrcpfcgc := vr_crapass_bulk(idx).nrcpfcgc;
          END LOOP;
        END IF;
        vr_crapass_bulk.DELETE;
      END LOOP;
      CLOSE cr_crapass;

      vr_cdcritic  := 0;
      vr_dscritic  := '';

      -- Busca os registros da tabela de Movimento
      FOR rw_movto IN cr_movto LOOP

        -- Se cartão ou remessa sem fluxo financeiro
        IF rw_movto.tparquivo LIKE '%CARTAO%' OR rw_movto.flpermite_fluxo_financeiro = 0 OR rw_movto.dtproxima_parcela IS NULL THEN
          vr_calcparc := FALSE;
        ELSE
          vr_calcparc := TRUE;
        END IF;

        -----------------------------------------------------------------------------------------------------------
        --  INICIO PARA MONTAR OS REGISTROS PARA A CENTRAL DE RISCO
        -----------------------------------------------------------------------------------------------------------
        pc_grava_crapris_temporaria(pr_cdcooper          => rw_movto.cdcooper
                                   ,pr_nrdconta          => rw_movto.nrdconta
                                   ,pr_inpessoa          => vr_tab_crapass(rw_movto.nrdconta).inpessoa
                                   ,pr_nrcontrato        => rw_movto.nrctremp
                                   ,pr_nrseqctr          => rw_movto.nrseqctr
                                   ,pr_cdagencia         => vr_tab_crapass(rw_movto.nrdconta).cdagenci
                                   ,pr_nrcpfcnpj         => rw_movto.nrcpfcgc
                                   ,pr_nrmodalidade      => rw_movto.nrmodalidade
                                   ,pr_dsnivel_risco     => rw_movto.cdclassifica_operacao
                                   ,pr_dtultdma_util     => vr_dtultdma_util
                                   ,pr_dtcadastro        => rw_movto.dtlib_operacao
                                   ,pr_dtvencimento      => rw_movto.dtvenc_operacao
                                   ,pr_vlsaldo_devedor   => rw_movto.vlsaldo_pendente
                                   ,pr_dtprxpar          => rw_movto.dtproxima_parcela
                                   ,pr_vlprxpar          => rw_movto.vlparcela
                                   ,pr_qtparcel          => rw_movto.qtdparcelas
                                   ,pr_cdinfadi          => rw_movto.cdinfadi
                                   ,pr_dsinfaux          => rw_movto.idmovto_risco
                                   ,pr_calcparc          => vr_calcparc
                                   ,pr_tab_risco         => vr_tab_risco
                                   ,pr_tab_risco_venc    => vr_tab_risco_venc
                                   ,pr_cdcritic          => vr_cdcritic
                                   ,pr_dscritic          => vr_dscritic);

        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      END LOOP;

      -----------------------------------------------------------------------------------------------------------
      --  INICIO PARA GRAVAR OS REGISTROS CRAPRIS
      -----------------------------------------------------------------------------------------------------------
      vr_indice := vr_tab_risco.first;
      WHILE vr_indice IS NOT NULL LOOP
        -- Reposicionar na tabela
        vr_tab_risco_temp(vr_tab_risco_temp.count + 1) := vr_tab_risco(vr_indice);
        -- Proximo idx
        vr_indice := vr_tab_risco.next(vr_indice);
      END LOOP;

      BEGIN
        FORALL idx IN INDICES OF vr_tab_risco_temp SAVE EXCEPTIONS
          INSERT INTO crapris
                   (  nrdconta,
                      dtrefere,
                      innivris,
                      qtdiaatr,
                      vldivida,
                      inpessoa,
                      nrcpfcgc,
                      inddocto,
                      cdmodali,
                      nrctremp,
                      nrseqctr,
                      dtinictr,
                      cdorigem,
                      cdagenci,
                      innivori,
                      cdcooper,
                      inindris,
                      cdinfadi,
                      dtvencop,
                      vlvec180,
                      vlvec360,
                      vlvec999,
                      vldiv060,
                      vldiv180,
                      vldiv360,
                      vldiv999,
                      vlprjano,
                      vlprjaan,
                      vlprjant,
                      vlprxpar,
                      dtprxpar,
                      qtparcel,
                      dsinfaux,
                      flgindiv)
              VALUES (vr_tab_risco_temp(idx).nrdconta,
                      pr_dtrefere,
                      vr_tab_risco_temp(idx).innivris,
                      ABS(vr_tab_risco_temp(idx).qtdiaatr),
                      vr_tab_risco_temp(idx).vldivida,
                      vr_tab_risco_temp(idx).inpessoa,
                      vr_tab_risco_temp(idx).nrcpfcgc,
                      5, --inddocto
                      vr_tab_risco_temp(idx).nrmodalidade,
                      vr_tab_risco_temp(idx).nrcontrato,
                      vr_tab_risco_temp(idx).nrseqctr,
                      vr_tab_risco_temp(idx).dtcadastro,
                      7, --cdorigem
                      vr_tab_risco_temp(idx).cdagencia,
                      vr_tab_risco_temp(idx).innivris, --innivori
                      vr_tab_risco_temp(idx).cdcooper,
                      vr_tab_risco_temp(idx).innivris, --inindris
                      vr_tab_risco_temp(idx).cdinfadi, --cdinfadi
                      vr_tab_risco_temp(idx).dtvencop,
                      vr_tab_risco_temp(idx).vlvec180,
                      vr_tab_risco_temp(idx).vlvec360,
                      vr_tab_risco_temp(idx).vlvec999,
                      vr_tab_risco_temp(idx).vldiv060,
                      vr_tab_risco_temp(idx).vldiv180,
                      vr_tab_risco_temp(idx).vldiv360,
                      vr_tab_risco_temp(idx).vldiv999,
                      vr_tab_risco_temp(idx).vlprjano,
                      vr_tab_risco_temp(idx).vlprjaan,
                      vr_tab_risco_temp(idx).vlprjant,
                      vr_tab_risco_temp(idx).vlprxpar,
                      vr_tab_risco_temp(idx).dtprxpar,
                      vr_tab_risco_temp(idx).qtparcel,
                      vr_tab_risco_temp(idx).dsinfaux,
                      vr_tab_risco_temp(idx).flgindiv);
      EXCEPTION
        WHEN others THEN
          -- Gerar erro
          vr_dscritic := 'Erro ao inserir na tabela crapris. '|| SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
          RAISE vr_exc_erro;
      END;

      -----------------------------------------------------------------------------------------------------------
      --  INICIO PARA GRAVAR OS REGISTROS CRAPVRI
      -----------------------------------------------------------------------------------------------------------
      vr_indice := vr_tab_risco_venc.first;
      WHILE vr_indice IS NOT NULL LOOP
        -- Indice da tabela de memoria crapvri
        vr_ind_crapvri := vr_tab_risco_venc_temp.count + 1;
        -- Reposicionar a tabela
        vr_tab_risco_venc_temp(vr_ind_crapvri)          := vr_tab_risco_venc(vr_indice);
        -- Proximo indice
        vr_indice := vr_tab_risco_venc.next(vr_indice);
      END LOOP;

      BEGIN
        FOR idx IN 1..vr_tab_risco_venc_temp.count LOOP

          INSERT INTO crapvri(cdcooper
                             ,nrdconta
                             ,dtrefere
                             ,innivris
                             ,cdmodali
                             ,cdvencto
                             ,nrctremp
                             ,nrseqctr
                             ,vldivida)
                      VALUES (vr_tab_risco_venc_temp(idx).cdcooper
                             ,vr_tab_risco_venc_temp(idx).nrdconta
                             ,pr_dtrefere
                             ,vr_tab_risco_venc_temp(idx).innivris
                             ,vr_tab_risco_venc_temp(idx).nrmodalidade
                             ,vr_tab_risco_venc_temp(idx).cdvencto
                             ,vr_tab_risco_venc_temp(idx).nrcontrato
                             ,vr_tab_risco_venc_temp(idx).nrseqctr
                             ,nvl(vr_tab_risco_venc_temp(idx).vldivida,0));

        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPVRI. ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Efetuar o arrasto das operações
      pc_efetua_arrasto_docto5(pr_cdcooper => pr_cdcooper --> codigo da cooperativa
                              ,pr_dtrefere => pr_dtrefere --> Data de Referencia
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
      -- Em caso de erro
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Vamos efetuar o fechamento da digitação
      BEGIN
        UPDATE CRAPPRM
           SET dsvlrprm = 0
         WHERE nmsistem = 'CRED'
           AND cdcooper = pr_cdcooper
           AND cdacesso = 'DIGIT_RISCO_FINAN_LIBERA';
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro no Fechamento da Digitacao de Riscos > '||sqlerrm;
          RAISE vr_exc_erro;
      END;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        ROLLBACK;
        -- Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        ROLLBACK;
        -- Descricao do erro
        pr_dscritic := 'Erro nao tratado na risc0003.pc_fecham_risco_garantia_prest --> ' || SQLERRM;
    END;

  END pc_fecham_risco_garantia_prest;

  /* Reabrir a digitação dos contratos de risco com base nas informações cadastradas ou importadas na tela MOVRGP */
  PROCEDURE pc_reabre_risco_garantia_prest(pr_cdcooper   IN crapcop.cdcooper%TYPE        --> codigo da cooperativa
                                          ,pr_dtrefere   IN DATE                         --> Data de Referencia
                                          ,pr_cdcritic   OUT PLS_INTEGER                 --> Código da critica
                                          ,pr_dscritic   OUT VARCHAR2) IS                --> Descricao da critica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_reabre_risco_garantia_prest
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Andrei Vieira
    --  Data     : Maio/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Elimitar os movimentos criados inddocto=5 e reliberar a digitação
    --
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
    DECLARE

    ----------------------------- CURSORES -------------------------------

      -- Busca as cooperativas
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdagebcb
              ,crapcop.nmrescop
              ,crapcop.dsdircop
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Variaveis de Erro
      vr_cdcritic             crapcri.cdcritic%TYPE;
      vr_dscritic             VARCHAR2(4000);
      vr_exc_erro             EXCEPTION;
    BEGIN

      -- Se a digitação não estiver fechada (olhar parametro geral e financeiro)
      IF fn_periodo_habilitado(pr_cdcooper => pr_cdcooper
                              ,pr_dtbase   => pr_dtrefere) = 1 THEN
        -- Gerar critica específica
        vr_dscritic := 'Periodo de digitacao ja liberado - Nao eh necessario re-liberar!';
        RAISE vr_exc_erro;
      END IF;

      -- Ignorar o parâmetro financeiro, para checarmos se a central de risco está liberada
      IF fn_periodo_habilitado(pr_cdcooper => pr_cdcooper
                              ,pr_dtbase   => pr_dtrefere
                              ,pr_prmfinan => FALSE) = 0 THEN
        -- Nao conseguiremos reabrir a digitação pois a TAB principal já não está liberada
        vr_cdcritic := 411;
        RAISE vr_exc_erro;
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Eliminar CRAPVRI gerado
      BEGIN
        DELETE
          FROM crapvri vri
         WHERE vri.cdcooper = pr_cdcooper
           AND vri.dtrefere = pr_dtrefere
           -- Incluir ligação na CRAPRIS pois inddocto existe só lá
           AND EXISTS(SELECT 1
                        FROM crapris ris
                       WHERE ris.cdcooper = vri.cdcooper
                         AND ris.dtrefere = vri.dtrefere
                         AND ris.nrdconta = vri.nrdconta
                         AND ris.innivris = vri.innivris
                         AND ris.cdmodali = vri.cdmodali
                         AND ris.nrctremp = vri.nrctremp
                         AND ris.nrseqctr = vri.nrseqctr
                         AND ris.inddocto = 5
                         AND ris.cdorigem = 7);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao elimiar tabela crapvri --> '|| SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Eliminar CRAPRIS gerado
      BEGIN
        DELETE
          FROM crapris ris
         WHERE ris.cdcooper = pr_cdcooper
           AND ris.dtrefere = pr_dtrefere
           AND ris.inddocto = 5
           AND ris.cdorigem = 7;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao elimiar tabela crapris --> '|| SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Vamos efetuar a reabertura da digitação
      BEGIN
        UPDATE CRAPPRM
           SET dsvlrprm = 1
         WHERE nmsistem = 'CRED'
           AND cdcooper = pr_cdcooper
           AND cdacesso = 'DIGIT_RISCO_FINAN_LIBERA';
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro no Fechamento da Digitacao de Riscos > '||sqlerrm;
          RAISE vr_exc_erro;
      END;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        ROLLBACK;
        -- Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        ROLLBACK;
        -- Descricao do erro
        pr_dscritic := 'Erro nao tratado na risc0003.pc_reabre_risco_garantia_prest --> ' || SQLERRM;
    END;

  END pc_reabre_risco_garantia_prest;
  
  PROCEDURE PC_RISCO_CENTRAL_OCR(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                ,pr_cdcritic OUT PLS_INTEGER           --> Critica encontrada
                                ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  BEGIN
    /* ............................................................................
     Programa: RISCO_CENTRAL_OCR
     Sistema : Atenda - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Daniel Silva(AMcom)
     Data    : Março/2018                           Ultima atualizacao: 09/03/2018

     Dados referentes ao programa:

     Frequencia: Diária
     Objetivo  : Gerar base consolidada da Central de Risco
     Alteracoes:
    ..............................................................................*/

  DECLARE
  --*** VARIÁVEIS ***--
    vr_exc_saida exception;
    vr_exc_fimprg exception;
    vr_inrisco_inclusao NUMBER(2) := NULL;
    vr_inrisco_rating   NUMBER(2) := NULL;
    vr_inrisco_atraso   NUMBER(2) := NULL;
    vr_inrisco_agravado NUMBER(2) := NULL;
    vr_inrisco_melhora  NUMBER(2) := NULL;
    vr_inrisco_operacao NUMBER(2) := NULL;
    vr_inrisco_cpf      NUMBER(2) := NULL;
    vr_inrisco_grupo    NUMBER(2) := NULL;
    vr_inrisco_final    NUMBER(2) := NULL;
    vr_inrisco_refin    NUMBER(2) := NULL;
    vr_nrcpfcgc         NUMBER(25):= NULL;

    vr_valor_arrasto    NUMBER;

    vr_grupo_economico  NUMBER(11):= NULL;
    
  --**************************--
  --*** CURSORES GENÉRICOS ***--
  --**************************--
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

    -- Calendário da cooperativa selecionada
    CURSOR cr_dat(pr_cdcooper INTEGER) IS
    SELECT dat.dtmvtolt
         , (CASE WHEN TO_CHAR(trunc(dat.dtmvtolt), 'mm') = TO_CHAR(trunc(dat.dtmvtoan), 'mm')
              THEN dat.dtmvtoan
              ELSE dat.dtultdma END) dtmvtoan
         , dat.dtultdma
         , (CASE WHEN TO_CHAR(trunc(dat.dtmvtolt), 'mm') = TO_CHAR(trunc(dat.dtmvtoan), 'mm')
              THEN dat.dtmvtoan
              ELSE dat.dtultdma END)-5 dtdelreg
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
    rw_dat cr_dat%ROWTYPE;

    -- Parâmetro do arrasto
    CURSOR cr_tab(pr_cdcooper IN crawepr.cdcooper%TYPE) IS
    SELECT t.dstextab
      FROM craptab t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nmsistem = 'CRED'
       AND t.tptabela = 'USUARI'
       AND t.cdempres = 11
       AND t.cdacesso = 'RISCOBACEN'
       AND t.tpregist = 000;
    rw_tab cr_tab%ROWTYPE;

    -- Cursor ajusta CPF
    CURSOR cr_ajusta_CPF(pr_cdcooper IN crawepr.cdcooper%TYPE) IS
    SELECT max(t.inrisco_cpf) inrisco_cpf, t.nrdconta
      FROM tbrisco_central_ocr t
         , crapris r
     WHERE t.cdcooper = pr_cdcooper
       AND t.dtrefere = rw_dat.dtmvtoan
       AND t.nrdgrupo is not null
       and r.cdcooper = t.cdcooper
       and r.nrdconta = t.nrdconta
       and r.nrctremp = t.nrctremp
       and r.dtrefere = t.dtrefere
       and r.vldivida > vr_valor_arrasto
  GROUP BY t.nrdconta;
    rw_ajusta_CPF cr_ajusta_CPF%ROWTYPE;    

    -- Cursor SEMRISCO - Busca contas que não possuem Central de Risco(CRAPRIS)
    CURSOR cr_semrisco(pr_cdcooper IN crapass.cdcooper%TYPE) IS
      SELECT DISTINCT
             ass.cdcooper
           , ass.nrcpfcgc
           , ass.nrdconta
           , nvl(grp.nrdgrupo,0) nrdgrupo
           , CASE WHEN ass.dsnivris = 'A'  THEN 2
                  WHEN ass.dsnivris = 'B'  THEN 3
                  WHEN ass.dsnivris = 'C'  THEN 4
                  WHEN ass.dsnivris = 'D'  THEN 5
                  WHEN ass.dsnivris = 'E'  THEN 6
                  WHEN ass.dsnivris = 'F'  THEN 7
                  WHEN ass.dsnivris = 'G'  THEN 8
                  WHEN ass.dsnivris = 'H'  THEN 9
                  WHEN ass.dsnivris = 'HH' THEN 10
               ELSE NULL END innivris_cta
           , 2 innivris
           , CASE WHEN ass.inrisctl = 'A'  THEN 2
                  WHEN ass.inrisctl = 'B'  THEN 3
                  WHEN ass.inrisctl = 'C'  THEN 4
                  WHEN ass.inrisctl = 'D'  THEN 5
                  WHEN ass.inrisctl = 'E'  THEN 6
                  WHEN ass.inrisctl = 'F'  THEN 7
                  WHEN ass.inrisctl = 'G'  THEN 8
                  WHEN ass.inrisctl = 'H'  THEN 9
                  WHEN ass.inrisctl = 'HH' THEN 10
               ELSE NULL END innivris_ctl
        FROM crapass ass
           , crapgrp grp
       WHERE ass.cdcooper = pr_cdcooper
         --AND ass.dtdemiss IS NULL ???
         AND ass.cdcooper = grp.cdcooper(+)
         AND ass.nrdconta = grp.nrctasoc(+)
         AND ass.nrcpfcgc = grp.nrcpfcgc(+)
         AND NOT EXISTS (SELECT 1
                           FROM crapris ris
                          WHERE ris.dtrefere = rw_dat.dtmvtoan
                            AND ris.cdcooper = ass.cdcooper
                            AND ris.nrdconta = ass.nrdconta);

    -- Cursor EMP - EMPRESTIMOS
    CURSOR cr_risco_emp(pr_cdcooper IN crapass.cdcooper%TYPE) IS
      SELECT ris.cdcooper
           , ris.nrcpfcgc
           , ris.nrdconta
           , ris.nrctremp
           , ris.cdmodali
           , ris.dtrefere
           , ris.dtdrisco
           , ris.cdorigem
           , ris.inddocto
           , ris.vldivida
           , ris.qtdiaatr
           , ris.innivris
           , ris.innivori
           , epr.inrisco_refin inrisco_refin
           , CASE WHEN ass.dsnivris = 'A'  THEN 2
                  WHEN ass.dsnivris = 'B'  THEN 3
                  WHEN ass.dsnivris = 'C'  THEN 4
                  WHEN ass.dsnivris = 'D'  THEN 5
                  WHEN ass.dsnivris = 'E'  THEN 6
                  WHEN ass.dsnivris = 'F'  THEN 7
                  WHEN ass.dsnivris = 'G'  THEN 8
                  WHEN ass.dsnivris = 'H'  THEN 9
                  WHEN ass.dsnivris = 'HH' THEN 10
               ELSE NULL END innivris_cta
           , CASE WHEN ass.inrisctl = 'A'  THEN 2
                  WHEN ass.inrisctl = 'B'  THEN 3
                  WHEN ass.inrisctl = 'C'  THEN 4
                  WHEN ass.inrisctl = 'D'  THEN 5
                  WHEN ass.inrisctl = 'E'  THEN 6
                  WHEN ass.inrisctl = 'F'  THEN 7
                  WHEN ass.inrisctl = 'G'  THEN 8
                  WHEN ass.inrisctl = 'H'  THEN 9
                  WHEN ass.inrisctl = 'HH' THEN 10
               ELSE NULL END innivris_ctl                 
           , CASE WHEN wpr.dsnivori = 'A'  THEN 2
                  WHEN wpr.dsnivori = 'B'  THEN 3
                  WHEN wpr.dsnivori = 'C'  THEN 4
                  WHEN wpr.dsnivori = 'D'  THEN 5
                  WHEN wpr.dsnivori = 'E'  THEN 6
                  WHEN wpr.dsnivori = 'F'  THEN 7
                  WHEN wpr.dsnivori = 'G'  THEN 8
                  WHEN wpr.dsnivori = 'H'  THEN 9
                  WHEN wpr.dsnivori = 'HH' THEN 10
               ELSE 2 END innivori_ctr
           , CASE WHEN wpr.dsnivris = 'A'  THEN 2
                  WHEN wpr.dsnivris = 'B'  THEN 3
                  WHEN wpr.dsnivris = 'C'  THEN 4
                  WHEN wpr.dsnivris = 'D'  THEN 5
                  WHEN wpr.dsnivris = 'E'  THEN 6
                  WHEN wpr.dsnivris = 'F'  THEN 7
                  WHEN wpr.dsnivris = 'G'  THEN 8
                  WHEN wpr.dsnivris = 'H'  THEN 9
                  WHEN wpr.dsnivris = 'HH' THEN 10
               ELSE 2 END innivris_ctr                
        FROM crapris ris
           , crapass ass
           , crawepr wpr
           , crapepr epr
       WHERE ris.cdcooper = ass.cdcooper
         AND ris.nrdconta = ass.nrdconta
         AND ris.cdcooper = wpr.cdcooper
         AND ris.nrdconta = wpr.nrdconta
         AND ris.nrctremp = wpr.nrctremp
         AND ris.cdcooper = epr.cdcooper
         AND ris.nrdconta = epr.nrdconta
         AND ris.nrctremp = epr.nrctremp         
         AND ris.cdmodali IN(299,499) -- Empréstimos         
        -- AND ris.inddocto = 1
         AND ris.cdorigem = 3
         AND ris.cdcooper = pr_cdcooper
         AND ris.dtrefere = rw_dat.dtmvtoan;

    -- Cursor AL - ADP/LIMITE
    CURSOR cr_riscoAL(pr_cdcooper IN crapass.cdcooper%TYPE) IS
      SELECT DISTINCT ris.cdcooper
           , ris.nrcpfcgc
           , ris.nrdconta
           , ris.nrctremp
           , ris.cdmodali
           , ris.dtrefere
           , ris.dtdrisco
           , ris.cdorigem
           , ris.inddocto           
           , ris.qtdiaatr
           , ris.innivris
           , ris.innivori
           , CASE WHEN ass.dsnivris = 'A'  THEN 2
                  WHEN ass.dsnivris = 'B'  THEN 3
                  WHEN ass.dsnivris = 'C'  THEN 4
                  WHEN ass.dsnivris = 'D'  THEN 5
                  WHEN ass.dsnivris = 'E'  THEN 6
                  WHEN ass.dsnivris = 'F'  THEN 7
                  WHEN ass.dsnivris = 'G'  THEN 8
                  WHEN ass.dsnivris = 'H'  THEN 9
                  WHEN ass.dsnivris = 'HH' THEN 10
               ELSE NULL END innivris_cta
           , CASE WHEN ass.inrisctl = 'A'  THEN 2
                  WHEN ass.inrisctl = 'B'  THEN 3
                  WHEN ass.inrisctl = 'C'  THEN 4
                  WHEN ass.inrisctl = 'D'  THEN 5
                  WHEN ass.inrisctl = 'E'  THEN 6
                  WHEN ass.inrisctl = 'F'  THEN 7
                  WHEN ass.inrisctl = 'G'  THEN 8
                  WHEN ass.inrisctl = 'H'  THEN 9
                  WHEN ass.inrisctl = 'HH' THEN 10
               ELSE NULL END innivris_ctl                 
        FROM crapris ris
           , crapass ass
       WHERE ris.cdcooper = ass.cdcooper
         AND ris.nrdconta = ass.nrdconta
         AND ((ris.cdmodali IN(101,201) AND ris.inddocto = 1) 
              OR (ris.cdmodali = 1901 AND ris.inddocto = 3     -- ADP/Limite
                  AND NOT EXISTS (SELECT 1
                                    FROM crapris 
                                   WHERE cdcooper = pr_cdcooper
                                     AND dtrefere = rw_dat.dtmvtoan
                                     AND nrdconta = ris.nrdconta
                                     AND nrctremp = ris.nrctremp
                                     AND cdmodali IN(101,201))))
         AND ris.cdcooper = pr_cdcooper
         AND ris.dtrefere = rw_dat.dtmvtoan;

    -- Cursor LD - LIMITE DESCONTO
    CURSOR cr_riscoLD(pr_cdcooper IN crapass.cdcooper%TYPE) IS
      SELECT DISTINCT cdcooper
           , nrcpfcgc
           , nrdconta
           , nrctremp
           , cdmodali
           , cdorigem
           , inddocto           
           , dtrefere
           , min(dtdrisco) dtdrisco
           , qtdiaatr
           , innivris           
           , innivris_cta
           , innivris_ctl
      FROM (           
      SELECT DISTINCT ris.cdcooper
           , ris.nrcpfcgc
           , ris.nrdconta
           , bdt.nrctrlim nrctremp
           , ris.cdmodali
           , ris.cdorigem
           , ris.inddocto           
           , ris.dtrefere
           , max(ris.dtdrisco) dtdrisco
           , MAX(ris.qtdiaatr) qtdiaatr
           , ris.innivris           
           , CASE WHEN ass.dsnivris = 'A'  THEN 2
                  WHEN ass.dsnivris = 'B'  THEN 3
                  WHEN ass.dsnivris = 'C'  THEN 4
                  WHEN ass.dsnivris = 'D'  THEN 5
                  WHEN ass.dsnivris = 'E'  THEN 6
                  WHEN ass.dsnivris = 'F'  THEN 7
                  WHEN ass.dsnivris = 'G'  THEN 8
                  WHEN ass.dsnivris = 'H'  THEN 9
                  WHEN ass.dsnivris = 'HH' THEN 10
               ELSE NULL END innivris_cta
           , CASE WHEN ass.inrisctl = 'A'  THEN 2
                  WHEN ass.inrisctl = 'B'  THEN 3
                  WHEN ass.inrisctl = 'C'  THEN 4
                  WHEN ass.inrisctl = 'D'  THEN 5
                  WHEN ass.inrisctl = 'E'  THEN 6
                  WHEN ass.inrisctl = 'F'  THEN 7
                  WHEN ass.inrisctl = 'G'  THEN 8
                  WHEN ass.inrisctl = 'H'  THEN 9
                  WHEN ass.inrisctl = 'HH' THEN 10
               ELSE NULL END innivris_ctl                 
        FROM crapris ris
           , crapass ass
           , crapbdt bdt -- Desconto títulos
       WHERE ris.cdcooper = ass.cdcooper
         AND ris.nrdconta = ass.nrdconta
         AND ris.cdcooper = bdt.cdcooper
         AND ris.nrdconta = bdt.nrdconta               
         AND ris.nrctremp = bdt.nrborder
         --AND ris.inddocto = 1
         AND ris.cdmodali = 301 -- Desconto títulos
         AND ris.vldivida > vr_valor_arrasto -- Materialidade(Arrasto)
         AND ris.cdcooper = pr_cdcooper
         AND ris.dtrefere = rw_dat.dtmvtoan
    GROUP BY ris.cdcooper
           , ris.nrcpfcgc
           , ris.nrdconta
           , bdt.nrctrlim
           , ris.cdmodali
           , ris.cdorigem
           , ris.inddocto           
           , ris.dtrefere
           , ris.innivris
           , CASE WHEN ass.dsnivris = 'A'  THEN 2
                  WHEN ass.dsnivris = 'B'  THEN 3
                  WHEN ass.dsnivris = 'C'  THEN 4
                  WHEN ass.dsnivris = 'D'  THEN 5
                  WHEN ass.dsnivris = 'E'  THEN 6
                  WHEN ass.dsnivris = 'F'  THEN 7
                  WHEN ass.dsnivris = 'G'  THEN 8
                  WHEN ass.dsnivris = 'H'  THEN 9
                  WHEN ass.dsnivris = 'HH' THEN 10
               ELSE NULL END
           , CASE WHEN ass.inrisctl = 'A'  THEN 2
                  WHEN ass.inrisctl = 'B'  THEN 3
                  WHEN ass.inrisctl = 'C'  THEN 4
                  WHEN ass.inrisctl = 'D'  THEN 5
                  WHEN ass.inrisctl = 'E'  THEN 6
                  WHEN ass.inrisctl = 'F'  THEN 7
                  WHEN ass.inrisctl = 'G'  THEN 8
                  WHEN ass.inrisctl = 'H'  THEN 9
                  WHEN ass.inrisctl = 'HH' THEN 10
               ELSE NULL END
    UNION
      SELECT DISTINCT ris.cdcooper
           , ris.nrcpfcgc
           , ris.nrdconta
           , bdc.nrctrlim nrctremp
           , ris.cdmodali
           , ris.cdorigem
           , ris.inddocto           
           , ris.dtrefere
           , max(ris.dtdrisco) dtdrisco
           , MAX(ris.qtdiaatr) qtdiaatr
           , ris.innivris
           , CASE WHEN ass.dsnivris = 'A'  THEN 2
                  WHEN ass.dsnivris = 'B'  THEN 3
                  WHEN ass.dsnivris = 'C'  THEN 4
                  WHEN ass.dsnivris = 'D'  THEN 5
                  WHEN ass.dsnivris = 'E'  THEN 6
                  WHEN ass.dsnivris = 'F'  THEN 7
                  WHEN ass.dsnivris = 'G'  THEN 8
                  WHEN ass.dsnivris = 'H'  THEN 9
                  WHEN ass.dsnivris = 'HH' THEN 10
               ELSE NULL END innivris_cta
           , CASE WHEN ass.inrisctl = 'A'  THEN 2
                  WHEN ass.inrisctl = 'B'  THEN 3
                  WHEN ass.inrisctl = 'C'  THEN 4
                  WHEN ass.inrisctl = 'D'  THEN 5
                  WHEN ass.inrisctl = 'E'  THEN 6
                  WHEN ass.inrisctl = 'F'  THEN 7
                  WHEN ass.inrisctl = 'G'  THEN 8
                  WHEN ass.inrisctl = 'H'  THEN 9
                  WHEN ass.inrisctl = 'HH' THEN 10
               ELSE NULL END innivris_ctl                 
        FROM crapris ris
           , crapass ass
           , crapbdc bdc -- Desconto cheques
       WHERE ris.cdcooper = ass.cdcooper
         AND ris.nrdconta = ass.nrdconta
         AND ris.cdcooper = bdc.cdcooper
         AND ris.nrdconta = bdc.nrdconta         
         AND ris.nrctremp = bdc.nrborder
         --AND ris.inddocto = 1
         AND ris.cdmodali = 302 -- Desconto cheques
         AND ris.vldivida > vr_valor_arrasto -- Materialidade(Arrasto)
         AND ris.cdcooper = pr_cdcooper
         AND ris.dtrefere = rw_dat.dtmvtoan
    GROUP BY ris.cdcooper
           , ris.nrcpfcgc
           , ris.nrdconta
           , bdc.nrctrlim
           , ris.cdmodali
           , ris.cdorigem
           , ris.inddocto           
           , ris.dtrefere
           , ris.innivris
           , CASE WHEN ass.dsnivris = 'A'  THEN 2
                  WHEN ass.dsnivris = 'B'  THEN 3
                  WHEN ass.dsnivris = 'C'  THEN 4
                  WHEN ass.dsnivris = 'D'  THEN 5
                  WHEN ass.dsnivris = 'E'  THEN 6
                  WHEN ass.dsnivris = 'F'  THEN 7
                  WHEN ass.dsnivris = 'G'  THEN 8
                  WHEN ass.dsnivris = 'H'  THEN 9
                  WHEN ass.dsnivris = 'HH' THEN 10
               ELSE NULL END
           , CASE WHEN ass.inrisctl = 'A'  THEN 2
                  WHEN ass.inrisctl = 'B'  THEN 3
                  WHEN ass.inrisctl = 'C'  THEN 4
                  WHEN ass.inrisctl = 'D'  THEN 5
                  WHEN ass.inrisctl = 'E'  THEN 6
                  WHEN ass.inrisctl = 'F'  THEN 7
                  WHEN ass.inrisctl = 'G'  THEN 8
                  WHEN ass.inrisctl = 'H'  THEN 9
                  WHEN ass.inrisctl = 'HH' THEN 10
               ELSE NULL END)
    GROUP BY cdcooper
           , nrcpfcgc
           , nrdconta
           , nrctremp
           , cdmodali
           , cdorigem
           , inddocto           
           , dtrefere
           , qtdiaatr
           , innivris
           , innivris_cta
           , innivris_ctl;

    -- Cursor contaX
    CURSOR cr_contaX(pr_cdcooper IN crapass.cdcooper%TYPE) IS
      SELECT DISTINCT risX.cdcooper
           , risX.nrcpfcgc
           , risX.nrdconta
           , MAX(risX.qtdiaatr) qtdiaatr
           , MAX(innivris_cta) innivris_cta   
           , MAX(innivris_ctl) innivris_ctl
              -- Emprestimos
        FROM (SELECT ris.cdcooper
                   , ris.nrcpfcgc
                   , ris.nrdconta
                   , ris.nrctremp
                   , ris.cdmodali
                   , ris.qtdiaatr
                   , ris.cdorigem
                   , (CASE WHEN ass.dsnivris = 'A'  THEN 2
                          WHEN ass.dsnivris = 'B'  THEN 3
                          WHEN ass.dsnivris = 'C'  THEN 4
                          WHEN ass.dsnivris = 'D'  THEN 5
                          WHEN ass.dsnivris = 'E'  THEN 6
                          WHEN ass.dsnivris = 'F'  THEN 7
                          WHEN ass.dsnivris = 'G'  THEN 8
                          WHEN ass.dsnivris = 'H'  THEN 9
                          WHEN ass.dsnivris = 'HH' THEN 10
                      ELSE NULL END) innivris_cta
                   , CASE WHEN ass.inrisctl = 'A'  THEN 2
                         WHEN ass.inrisctl = 'B'  THEN 3
                         WHEN ass.inrisctl = 'C'  THEN 4
                         WHEN ass.inrisctl = 'D'  THEN 5
                         WHEN ass.inrisctl = 'E'  THEN 6
                         WHEN ass.inrisctl = 'F'  THEN 7
                         WHEN ass.inrisctl = 'G'  THEN 8
                         WHEN ass.inrisctl = 'H'  THEN 9
                         WHEN ass.inrisctl = 'HH' THEN 10
                      ELSE NULL END innivris_ctl
                FROM crapris ris
                   , crapass ass
                   , crawepr wpr
               WHERE ris.cdcooper = ass.cdcooper
                 AND ris.nrdconta = ass.nrdconta
                 AND ris.cdcooper = wpr.cdcooper
                 AND ris.nrdconta = wpr.nrdconta
                 AND ris.nrctremp = wpr.nrctremp
                 AND ris.cdmodali IN(299,499)
                 --AND ris.inddocto = 1
                 AND ris.cdorigem = 3
                 AND ris.cdcooper = pr_cdcooper
                 AND ris.dtrefere = rw_dat.dtmvtoan
            UNION
              -- Limite desconto
              SELECT DISTINCT cdcooper
                            , nrcpfcgc
                            , nrdconta
                            , nrctremp
                            , cdmodali
                            , cdorigem
                            , MAX(qtdiaatr) qtdiaatr
                            , MAX(innivris_cta) innivris_cta
                            , MAX(innivris_ctl) innivris_ctl
                       FROM ( SELECT DISTINCT ris.cdcooper
                                            , ris.nrcpfcgc
                                            , ris.nrdconta
                                            , bdt.nrctrlim nrctremp
                                            , ris.cdmodali
                                            , ris.cdorigem
                                            , ris.qtdiaatr
                                            , (CASE WHEN ass.dsnivris = 'A'  THEN 2
                                                    WHEN ass.dsnivris = 'B'  THEN 3
                                                    WHEN ass.dsnivris = 'C'  THEN 4
                                                    WHEN ass.dsnivris = 'D'  THEN 5
                                                    WHEN ass.dsnivris = 'E'  THEN 6
                                                    WHEN ass.dsnivris = 'F'  THEN 7
                                                    WHEN ass.dsnivris = 'G'  THEN 8
                                                    WHEN ass.dsnivris = 'H'  THEN 9
                                                    WHEN ass.dsnivris = 'HH' THEN 10
                                                ELSE NULL END) innivris_cta
                                            , CASE WHEN ass.inrisctl = 'A'  THEN 2
                                                  WHEN ass.inrisctl = 'B'  THEN 3
                                                  WHEN ass.inrisctl = 'C'  THEN 4
                                                  WHEN ass.inrisctl = 'D'  THEN 5
                                                  WHEN ass.inrisctl = 'E'  THEN 6
                                                  WHEN ass.inrisctl = 'F'  THEN 7
                                                  WHEN ass.inrisctl = 'G'  THEN 8
                                                  WHEN ass.inrisctl = 'H'  THEN 9
                                                  WHEN ass.inrisctl = 'HH' THEN 10
                                               ELSE NULL END innivris_ctl                                                  
                                         FROM crapris ris
                                            , crapass ass
                                            , crapbdt bdt -- Desconto títulos
                                        WHERE ris.cdcooper = ass.cdcooper
                                          AND ris.nrdconta = ass.nrdconta
                                          AND ris.cdcooper = bdt.cdcooper
                                          AND ris.nrdconta = bdt.nrdconta               
                                          AND ris.nrctremp = bdt.nrborder
                                          --AND ris.inddocto = 1
                                          AND ris.cdmodali = 301 -- Desconto títulos
                                          AND ris.vldivida > vr_valor_arrasto -- Materialidade(Arrasto)
                                          AND ris.cdcooper = pr_cdcooper
                                          AND ris.dtrefere = rw_dat.dtmvtoan
                                     UNION
                                       SELECT DISTINCT ris.cdcooper
                                                     , ris.nrcpfcgc
                                                     , ris.nrdconta
                                                     , bdc.nrctrlim nrctremp
                                                     , ris.cdmodali
                                                     , ris.cdorigem
                                                     , ris.qtdiaatr
                                                     , (CASE WHEN ass.dsnivris = 'A'  THEN 2
                                                             WHEN ass.dsnivris = 'B'  THEN 3
                                                             WHEN ass.dsnivris = 'C'  THEN 4
                                                             WHEN ass.dsnivris = 'D'  THEN 5
                                                             WHEN ass.dsnivris = 'E'  THEN 6
                                                             WHEN ass.dsnivris = 'F'  THEN 7
                                                             WHEN ass.dsnivris = 'G'  THEN 8
                                                             WHEN ass.dsnivris = 'H'  THEN 9
                                                             WHEN ass.dsnivris = 'HH' THEN 10
                                                         ELSE NULL END) innivris_cta
                                            , CASE WHEN ass.inrisctl = 'A'  THEN 2
                                                  WHEN ass.inrisctl = 'B'  THEN 3
                                                  WHEN ass.inrisctl = 'C'  THEN 4
                                                  WHEN ass.inrisctl = 'D'  THEN 5
                                                  WHEN ass.inrisctl = 'E'  THEN 6
                                                  WHEN ass.inrisctl = 'F'  THEN 7
                                                  WHEN ass.inrisctl = 'G'  THEN 8
                                                  WHEN ass.inrisctl = 'H'  THEN 9
                                                  WHEN ass.inrisctl = 'HH' THEN 10
                                               ELSE NULL END innivris_ctl                                                           
                                         FROM crapris ris
                                            , crapass ass
                                            , crapbdc bdc -- Desconto cheques
                                        WHERE ris.cdcooper = ass.cdcooper
                                          AND ris.nrdconta = ass.nrdconta
                                          AND ris.cdcooper = bdc.cdcooper
                                          AND ris.nrdconta = bdc.nrdconta         
                                          AND ris.nrctremp = bdc.nrborder
                                          --AND ris.inddocto = 1
                                          AND ris.cdmodali = 302 -- Desconto cheques
                                          AND ris.vldivida > vr_valor_arrasto -- Materialidade(Arrasto)
                                          AND ris.cdcooper = pr_cdcooper
                                          AND ris.dtrefere = rw_dat.dtmvtoan)
                        GROUP BY cdcooper
                            , nrcpfcgc
                            , nrdconta
                            , nrctremp
                            , cdmodali
                            , cdorigem) risX
       -- Somentes as contasX que não possuem Limite/ ADP
       WHERE NOT EXISTS (SELECT 1
                           FROM crapris r
                          WHERE r.cdcooper = risX.cdcooper
                            AND r.nrdconta = risX.nrdconta
                            AND r.dtrefere = rw_dat.dtmvtoan
                            AND r.cdmodali IN (201,101,1901))
    GROUP BY risX.cdcooper
           , risX.nrcpfcgc
           , risX.nrdconta;
                            
      vr_cdcritic crapcri.cdcritic%TYPE; -- Codigo da critica
      vr_dscritic VARCHAR2(2000);        -- Descricao da critica

  --***************************--
  --***      FUNCTIONS      ***--
  --***************************--
    -- Busca risco agravado
     FUNCTION fn_busca_risco_agravado(pr_cdcooper NUMBER
                                    ,pr_nrdconta NUMBER
                                    ,pr_dtmvtoan DATE)
      RETURN tbrisco_cadastro_conta.cdnivel_risco%TYPE AS vr_risco_agr tbrisco_cadastro_conta.cdnivel_risco%TYPE;
       CURSOR cr_agravado IS
         SELECT agr.cdnivel_risco
           FROM tbrisco_cadastro_conta agr
          WHERE agr.cdcooper  = pr_cdcooper
            AND agr.nrdconta  = pr_nrdconta
            AND agr.dtmvtolt <= pr_dtmvtoan;
      rw_agravado cr_agravado%ROWTYPE;
    BEGIN
      OPEN cr_agravado;
      FETCH cr_agravado INTO rw_agravado;
      vr_risco_agr := rw_agravado.cdnivel_risco;
      CLOSE cr_agravado;
      RETURN vr_risco_agr;
    END fn_busca_risco_agravado;

    -- Busca risco rating
    FUNCTION fn_busca_rating(pr_cdcooper NUMBER
                            ,pr_nrdconta NUMBER
                            ,pr_nrctremp NUMBER
                            ,pr_cdorigem NUMBER
                            ,pr_dtmvtoan DATE)
      RETURN crapnrc.indrisco%TYPE AS vr_rating crapnrc.indrisco%TYPE;
      CURSOR cr_rating IS
      SELECT CASE WHEN rat.indrisco = 'A'  THEN 2
                  WHEN rat.indrisco = 'B'  THEN 3
                  WHEN rat.indrisco = 'C'  THEN 4
                  WHEN rat.indrisco = 'D'  THEN 5
                  WHEN rat.indrisco = 'E'  THEN 6
                  WHEN rat.indrisco = 'F'  THEN 7
                  WHEN rat.indrisco = 'G'  THEN 8
                  WHEN rat.indrisco = 'H'  THEN 9
                  WHEN rat.indrisco = 'HH' THEN 10
               ELSE 2 END indrisco
         FROM crapnrc rat
        WHERE rat.cdcooper =  pr_cdcooper
          AND rat.nrdconta =  pr_nrdconta
          AND rat.nrctrrat =  pr_nrctremp
          AND rat.dteftrat <= pr_dtmvtoan
          AND rat.tpctrrat =  DECODE(pr_cdorigem
                                    , 1, 1
                                    , 2, 2
                                    , 3, 90
                                    , 4, 3
                                    , 5, 3)
          AND rat.insitrat =  2;
      rw_rating cr_rating%ROWTYPE;
    BEGIN
      OPEN cr_rating;
      FETCH cr_rating INTO rw_rating;

      vr_rating := rw_rating.indrisco;

      CLOSE cr_rating;

      RETURN vr_rating;
    END fn_busca_rating;

    -- Busca risco grupo economico
    FUNCTION fn_busca_grupo_economico(pr_cdcooper     IN NUMBER
                                     ,pr_nrdconta     IN NUMBER
                                     ,pr_nrcpfcgc     IN NUMBER)
      RETURN crapgrp.innivrge%TYPE AS vr_risco_grupo crapgrp.innivrge%TYPE;

      CURSOR cr_grupo IS
      SELECT max(g.innivrge) innivrge
        FROM crapgrp g
       WHERE g.cdcooper(+) = pr_cdcooper
         AND g.nrctasoc(+) = pr_nrdconta
         AND g.nrcpfcgc(+) = pr_nrcpfcgc;
--         AND g.nrdgrupo(+) = pr_nrdgrupo;
      rw_grupo cr_grupo%ROWTYPE;
    BEGIN
      OPEN cr_grupo;
      FETCH cr_grupo INTO rw_grupo;

      vr_risco_grupo  := rw_grupo.innivrge;

      CLOSE cr_grupo;

      RETURN vr_risco_grupo;
    END fn_busca_grupo_economico;

    -- Busca grupo economico
    FUNCTION fn_busca_grp_economico(pr_cdcooper     IN NUMBER
                                   ,pr_nrdconta     IN NUMBER)
      RETURN crapgrp.nrdgrupo%TYPE AS vr_grpecn crapgrp.nrdgrupo%TYPE;

      CURSOR cr_grp IS
      SELECT distinct g.nrdgrupo
        FROM crapgrp g
       WHERE g.cdcooper(+) = pr_cdcooper
         AND g.nrctasoc(+) = pr_nrdconta;
      rw_grp cr_grp%ROWTYPE;
    BEGIN
      OPEN cr_grp;
      FETCH cr_grp INTO rw_grp;

      vr_grpecn  := rw_grp.nrdgrupo;

      CLOSE cr_grp;

      RETURN vr_grpecn;
    END fn_busca_grp_economico;

    -- Busca risco atraso
    FUNCTION fn_calcula_risco_atraso(qtdiaatr NUMBER)
      RETURN crawepr.dsnivris%TYPE AS risco_atraso crawepr.dsnivris%TYPE;
    BEGIN
      risco_atraso :=  CASE WHEN qtdiaatr IS NULL THEN 2
                            WHEN qtdiaatr <   15  THEN 2
                            WHEN qtdiaatr <=  30  THEN 3
                            WHEN qtdiaatr <=  60  THEN 4
                            WHEN qtdiaatr <=  90  THEN 5
                            WHEN qtdiaatr <= 120  THEN 6
                            WHEN qtdiaatr <= 150  THEN 7
                            WHEN qtdiaatr <= 180  THEN 8
                            ELSE 9 END;
      RETURN risco_atraso;
    END fn_calcula_risco_atraso;

    -- Busca risco atraso ADP
    FUNCTION fn_calcula_risco_atraso_adp(qtdiaatr NUMBER)
      RETURN crawepr.dsnivris%TYPE AS risco_atraso crawepr.dsnivris%TYPE;
    BEGIN
      risco_atraso :=  CASE WHEN qtdiaatr IS NULL THEN 2
                            WHEN qtdiaatr <   15  THEN 2
                            WHEN qtdiaatr <=  30  THEN 3
                            WHEN qtdiaatr <=  60  THEN 5
                            WHEN qtdiaatr <=  90  THEN 7
                            ELSE 9 END;
      RETURN risco_atraso;
    END fn_calcula_risco_atraso_adp;

  --**************************--
  --***     PROCEDURES     ***--
  --**************************--
    -- Processo de limpeza
    PROCEDURE pc_limpa_dados_risco(pr_cdcooper IN NUMBER         -- Cooperativa
                                  ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo) IS
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;

        -- Efetua limpeza dos registros com referência superior a 5 dias
        DELETE
          FROM tbrisco_central_ocr
         WHERE (dtrefere <= rw_dat.dtdelreg OR dtrefere = rw_dat.dtmvtoan)
           AND cdcooper = pr_cdcooper;
         --
       EXCEPTION
         WHEN OTHERS THEN
           pr_cdcritic := 0;
           pr_dscritic := 'Erro pc_limpa_dados_risco: '||SQLERRM;
           -- Efetuar rollback
           ROLLBACK;
    END pc_limpa_dados_risco;

    -- Insere infomações de EMPRÉSTIMOS
    -- Modalidade 299 e 499
    PROCEDURE pc_insere_dados_risco_emp(pr_cdcooper IN NUMBER         -- Cooperativa
                                       ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                                       ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo) IS
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;

        -- Reset Riscos
        vr_inrisco_inclusao := NULL;
        vr_inrisco_rating   := NULL;
        vr_inrisco_atraso   := NULL;
        vr_inrisco_agravado := NULL;
        vr_inrisco_melhora  := NULL;
        vr_inrisco_operacao := NULL;
        vr_inrisco_cpf      := NULL;
        vr_inrisco_grupo    := NULL;
        vr_inrisco_final    := NULL;
        vr_inrisco_refin    := NULL;
        vr_nrcpfcgc         := NULL;
        vr_grupo_economico  := NULL;
        BEGIN
          FOR rw_risco_emp IN cr_risco_emp(pr_cdcooper) LOOP

            -- Se o valor da dívida é maior que a Materialidade(Arrasto)
            IF rw_risco_emp.vldivida > vr_valor_arrasto THEN
              -- Processa as variáveis de Riscos a serem inseridos
              vr_inrisco_inclusao := rw_risco_emp.innivori_ctr;
              --
              vr_inrisco_rating := fn_busca_rating(rw_risco_emp.cdcooper
                                                  ,rw_risco_emp.nrdconta
                                                  ,rw_risco_emp.nrctremp
                                                  ,3
                                                  ,rw_dat.dtmvtoan);
              --
              vr_inrisco_atraso   := fn_calcula_risco_atraso(rw_risco_emp.qtdiaatr);
              --
              vr_inrisco_agravado := fn_busca_risco_agravado(rw_risco_emp.cdcooper
                                                            ,rw_risco_emp.nrdconta
                                                            ,rw_dat.dtmvtoan);
              --
              -- Só existirá melhora se o nível risco estiver menor que o nível risco inclusão
              vr_inrisco_melhora  := (CASE WHEN rw_risco_emp.innivris_ctr < vr_inrisco_inclusao THEN
                                       rw_risco_emp.innivris_ctr
                                     ELSE NULL END);
              --              
              vr_inrisco_operacao := greatest(nvl(vr_inrisco_rating,2)
                                              ,vr_inrisco_atraso
                                              ,(CASE WHEN rw_risco_emp.innivris_ctr <> rw_risco_emp.innivori_ctr
                                                 AND rw_risco_emp.innivris_ctr = 2 THEN
                                                   rw_risco_emp.innivris_ctr
                                                ELSE rw_risco_emp.innivori_ctr END)
                                               ,nvl(vr_inrisco_agravado, 2));
              --
              IF vr_inrisco_operacao > nvl(rw_risco_emp.innivris_ctl,2)  THEN
                vr_inrisco_cpf      := vr_inrisco_operacao;                
              ELSE
                vr_inrisco_cpf      := nvl(rw_risco_emp.innivris_ctl,2);
              END IF;                            
              --              
              vr_inrisco_grupo    := fn_busca_grupo_economico(rw_risco_emp.cdcooper
                                                             ,rw_risco_emp.nrdconta
                                                             ,rw_risco_emp.nrcpfcgc);
              --
              vr_inrisco_refin    := rw_risco_emp.inrisco_refin;
              
              vr_inrisco_final    := greatest(nvl(rw_risco_emp.innivris,2)
                                             ,nvl(vr_inrisco_cpf,2)
                                             ,nvl(vr_inrisco_grupo,2));
              --
              vr_grupo_economico := fn_busca_grp_economico(rw_risco_emp.cdcooper
                                                          ,rw_risco_emp.nrdconta);
            INSERT INTO tbrisco_central_ocr( cdcooper
                                           , nrcpfcgc
                                           , nrdconta
                                           , nrctremp
                                           , cdmodali
                                           , cdorigem
                                           , inddocto
                                           , nrdgrupo
                                           , dtrefere
                                           , dtdrisco
                                           , inrisco_inclusao
                                           , inrisco_rating
                                           , inrisco_atraso
                                           , inrisco_agravado
                                           , inrisco_melhora
                                           , inrisco_operacao
                                           , inrisco_cpf
                                           , inrisco_grupo
                                           , inrisco_final
                                           , inrisco_refin)
                                    VALUES ( rw_risco_emp.cdcooper
                                           , rw_risco_emp.nrcpfcgc
                                           , rw_risco_emp.nrdconta
                                           , rw_risco_emp.nrctremp
                                           , rw_risco_emp.cdmodali
                                           , rw_risco_emp.cdorigem
                                           , rw_risco_emp.inddocto
                                           , vr_grupo_economico
                                           , rw_risco_emp.dtrefere
                                           , rw_risco_emp.dtdrisco
                                           , vr_inrisco_inclusao
                                           , vr_inrisco_rating
                                           , vr_inrisco_atraso
                                           , vr_inrisco_agravado
                                           , vr_inrisco_melhora
                                           , vr_inrisco_operacao
                                           , vr_inrisco_cpf
                                           , vr_inrisco_grupo
                                           , vr_inrisco_final
                                           , vr_inrisco_refin);
            --
            END IF;
          END LOOP;
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro(EMPRESTIMOS) INSERT TBRISCO_CENTRAL_OCR: '||SQLERRM;
            -- Efetuar rollback
            ROLLBACK;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro pc_insere_dados_risc_emp: '||SQLERRM;
          -- Efetuar rollback
          ROLLBACK;
    END pc_insere_dados_risco_emp;

    -- Insere infomações de ADP ou LIMITE
    -- Modalidade 101, 201 e 1901
    PROCEDURE pc_insere_dados_riscoAL(pr_cdcooper IN NUMBER         -- Cooperativa
                                     ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo) IS
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;

        -- Reset Riscos
        vr_inrisco_inclusao := NULL;
        vr_inrisco_rating   := NULL;
        vr_inrisco_atraso   := NULL;
        vr_inrisco_agravado := NULL;
        vr_inrisco_melhora  := NULL;
        vr_inrisco_operacao := NULL;
        vr_inrisco_cpf      := NULL;
        vr_inrisco_grupo    := NULL;
        vr_inrisco_final    := NULL;
        vr_grupo_economico  := NULL;
        
        BEGIN
          FOR rw_riscoAL IN cr_riscoAL(pr_cdcooper) LOOP

            -- Processa as variáveis de Riscos a serem inseridos
            vr_inrisco_inclusao := 2;
            --
            vr_inrisco_rating := fn_busca_rating(rw_riscoAL.cdcooper
                                                ,rw_riscoAL.nrdconta
                                                ,rw_riscoAL.nrctremp
                                                ,1
                                                ,rw_dat.dtmvtoan);
            --
            vr_inrisco_atraso   := fn_calcula_risco_atraso_adp(rw_riscoAL.qtdiaatr);
            --
            vr_inrisco_agravado := fn_busca_risco_agravado(rw_riscoAL.cdcooper
                                                          ,rw_riscoAL.nrdconta
                                                          ,rw_dat.dtmvtoan);
            --
            vr_inrisco_melhora  := NULL; -- Limite/ ADP não possui Melhora
            --
            vr_inrisco_operacao := greatest(nvl(vr_inrisco_rating, 2)
                                           ,vr_inrisco_inclusao
                                           ,vr_inrisco_atraso
                                           ,nvl(vr_inrisco_agravado, 2));
            --
            IF vr_inrisco_operacao > nvl(rw_riscoAL.innivris_ctl,2) THEN
              vr_inrisco_cpf      := vr_inrisco_operacao;
            ELSE
              vr_inrisco_cpf      := nvl(rw_riscoAL.innivris_ctl,2);
            END IF;                                         
            --
            vr_inrisco_grupo    := fn_busca_grupo_economico(rw_riscoAL.cdcooper
                                                           ,rw_riscoAL.nrdconta
                                                           ,rw_riscoAL.nrcpfcgc);
            --
            vr_inrisco_final    := greatest(nvl(rw_riscoAL.innivris,2)
                                           ,nvl(vr_inrisco_cpf,2)
                                           ,nvl(vr_inrisco_grupo,2));
            --                                 
            vr_grupo_economico := fn_busca_grp_economico(rw_riscoAL.cdcooper
                                                        ,rw_riscoAL.nrdconta);
                                                          
            INSERT INTO tbrisco_central_ocr( cdcooper
                                           , nrcpfcgc
                                           , nrdconta
                                           , nrctremp
                                           , cdmodali
                                           , cdorigem
                                           , inddocto                                                                                      
                                           , nrdgrupo
                                           , dtrefere
                                           , dtdrisco
                                           , inrisco_inclusao
                                           , inrisco_rating
                                           , inrisco_atraso
                                           , inrisco_agravado
                                           , inrisco_melhora
                                           , inrisco_operacao
                                           , inrisco_cpf
                                           , inrisco_grupo
                                           , inrisco_final)
                                    VALUES ( rw_riscoAL.cdcooper
                                           , rw_riscoAL.nrcpfcgc
                                           , rw_riscoAL.nrdconta
                                           , rw_riscoAL.nrctremp
                                           , rw_riscoAL.cdmodali
                                           , rw_riscoAL.cdorigem
                                           , rw_riscoAL.inddocto
                                           , vr_grupo_economico
                                           , rw_riscoAL.dtrefere
                                           , rw_riscoAL.dtdrisco
                                           , vr_inrisco_inclusao
                                           , vr_inrisco_rating
                                           , vr_inrisco_atraso
                                           , vr_inrisco_agravado
                                           , vr_inrisco_melhora
                                           , vr_inrisco_operacao
                                           , vr_inrisco_cpf
                                           , vr_inrisco_grupo
                                           , vr_inrisco_final);
            --
          END LOOP;
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro(ADP LIMITE) INSERT TBRISCO_CENTRAL_OCR: '||SQLERRM;
            -- Efetuar rollback
            ROLLBACK;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro pc_insere_dados_riscoAL: '||SQLERRM;
          -- Efetuar rollback
          ROLLBACK;
    END pc_insere_dados_riscoAL;

    -- Insere infomações de LIMITE DE DESCONTO
    -- Modalidade 301 e 302
    PROCEDURE pc_insere_dados_riscoLD(pr_cdcooper IN NUMBER         -- Cooperativa
                                     ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo) IS
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;

        -- Reset Riscos
        vr_inrisco_inclusao := NULL;
        vr_inrisco_rating   := NULL;
        vr_inrisco_atraso   := NULL;
        vr_inrisco_agravado := NULL;
        vr_inrisco_melhora  := NULL;
        vr_inrisco_operacao := NULL;
        vr_inrisco_cpf      := NULL;
        vr_inrisco_grupo    := NULL;
        vr_inrisco_final    := NULL;
        vr_grupo_economico  := NULL;
    
        BEGIN
          FOR rw_riscoLD IN cr_riscoLD(pr_cdcooper) LOOP

            -- Processa as variáveis de Riscos a serem inseridos
            vr_inrisco_inclusao := 2;
            --
            vr_inrisco_rating := fn_busca_rating(rw_riscoLD.cdcooper
                                                ,rw_riscoLD.nrdconta
                                                ,rw_riscoLD.nrctremp
                                                ,rw_riscoLD.cdorigem
                                                ,rw_dat.dtmvtoan);
            --
            vr_inrisco_atraso   := fn_calcula_risco_atraso(rw_riscoLD.qtdiaatr);
            --
            vr_inrisco_agravado := fn_busca_risco_agravado(rw_riscoLD.cdcooper
                                                          ,rw_riscoLD.nrdconta
                                                          ,rw_dat.dtmvtoan);
            vr_inrisco_melhora  := NULL;
            --
            vr_inrisco_operacao := greatest(nvl(vr_inrisco_rating, 2)
                                            ,vr_inrisco_inclusao
                                            ,vr_inrisco_atraso
                                            ,nvl(vr_inrisco_agravado, 2));
            --
            IF vr_inrisco_operacao > nvl(rw_riscoLD.innivris_ctl,2) THEN
              vr_inrisco_cpf      := vr_inrisco_operacao;
            ELSE
              vr_inrisco_cpf      := nvl(rw_riscoLD.innivris_ctl,2);
            END IF;                                                     
            --
            vr_inrisco_grupo    := fn_busca_grupo_economico(rw_riscoLD.cdcooper
                                                           ,rw_riscoLD.nrdconta
                                                           ,rw_riscoLD.nrcpfcgc);
            --
            vr_inrisco_final    := greatest(nvl(rw_riscoLD.innivris,2)
                                           ,nvl(vr_inrisco_cpf,2)
                                           ,nvl(vr_inrisco_grupo,2));
            --
            vr_grupo_economico := fn_busca_grp_economico(rw_riscoLD.cdcooper
                                                        ,rw_riscoLD.nrdconta);
                                                        
            INSERT INTO tbrisco_central_ocr( cdcooper
                                           , nrcpfcgc
                                           , nrdconta
                                           , nrctremp
                                           , cdmodali
                                           , cdorigem
                                           , inddocto
                                           , nrdgrupo
                                           , dtrefere
                                           , dtdrisco
                                           , inrisco_inclusao
                                           , inrisco_rating
                                           , inrisco_atraso
                                           , inrisco_agravado
                                           , inrisco_melhora
                                           , inrisco_operacao
                                           , inrisco_cpf
                                           , inrisco_grupo
                                           , inrisco_final)
                                    VALUES ( rw_riscoLD.cdcooper
                                           , rw_riscoLD.nrcpfcgc
                                           , rw_riscoLD.nrdconta
                                           , rw_riscoLD.nrctremp
                                           , rw_riscoLD.cdmodali
                                           , rw_riscoLD.cdorigem
                                           , rw_riscoLD.inddocto
                                           , vr_grupo_economico
                                           , rw_riscoLD.dtrefere
                                           , rw_riscoLD.dtdrisco
                                           , vr_inrisco_inclusao
                                           , vr_inrisco_rating
                                           , vr_inrisco_atraso
                                           , vr_inrisco_agravado
                                           , vr_inrisco_melhora
                                           , vr_inrisco_operacao
                                           , vr_inrisco_cpf
                                           , vr_inrisco_grupo
                                           , vr_inrisco_final);
            --
          END LOOP;
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro(LIMITE DESCONTO) INSERT TBRISCO_CENTRAL_OCR: '||SQLERRM;
            -- Efetuar rollback
            ROLLBACK;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro pc_insere_dados_riscoLD: '||SQLERRM;
          -- Efetuar rollback
          ROLLBACK;
    END pc_insere_dados_riscoLD;

    -- Insere Contas/ Contratos que possuem Empréstimo ou Limite Desconto
    -- e não possuem Contrato Limite e/ ou ADP
    PROCEDURE pc_insere_dados_contaX(pr_cdcooper IN NUMBER         -- Cooperativa
                                    ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                                    ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo) IS
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;
        --
        -- Reset Riscos
        vr_inrisco_inclusao := 2;
        vr_inrisco_rating   := NULL;
        vr_inrisco_atraso   := 2;
        vr_inrisco_agravado := NULL;
        vr_inrisco_melhora  := NULL;
        vr_inrisco_operacao := 2;
        vr_inrisco_cpf      := NULL;
        vr_inrisco_grupo    := NULL;
        vr_inrisco_final    := NULL;
        vr_grupo_economico  := NULL;        

        FOR rw_contaX IN cr_contaX(pr_cdcooper) LOOP
          -- Processa as variáveis de Riscos a serem inseridos
          --
          vr_inrisco_agravado := fn_busca_risco_agravado(rw_contaX.cdcooper
                                                        ,rw_contaX.nrdconta
                                                        ,rw_dat.dtmvtoan);
          --
          vr_inrisco_grupo    := fn_busca_grupo_economico(rw_contaX.cdcooper
                                                         ,rw_contaX.nrdconta
                                                         ,rw_contaX.nrcpfcgc);
          --
          vr_inrisco_operacao := greatest(nvl(vr_inrisco_rating, 2)
                                             ,vr_inrisco_inclusao
                                             ,vr_inrisco_atraso
                                             ,nvl(vr_inrisco_agravado, 2));          
          --
          IF vr_inrisco_operacao > nvl(rw_contaX.innivris_ctl,2) THEN
            vr_inrisco_cpf      := vr_inrisco_operacao;
          ELSE
            vr_inrisco_cpf      := nvl(rw_contaX.innivris_ctl,2);
          END IF;                                                   
          --
          vr_inrisco_final    := greatest(nvl(vr_inrisco_cpf,2)
                                         ,nvl(vr_inrisco_grupo,2));
          --
          vr_grupo_economico := fn_busca_grp_economico(rw_contaX.cdcooper
                                                      ,rw_contaX.nrdconta);
                                                      
          INSERT INTO tbrisco_central_ocr( cdcooper
                                         , nrcpfcgc
                                         , nrdconta
                                         , nrctremp
                                         , cdmodali
                                         , cdorigem
                                         , inddocto                                         
                                         , nrdgrupo
                                         , dtrefere                                         
                                         , dtdrisco
                                         , inrisco_inclusao
                                         , inrisco_rating
                                         , inrisco_atraso
                                         , inrisco_agravado
                                         , inrisco_melhora
                                         , inrisco_operacao
                                         , inrisco_cpf
                                         , inrisco_grupo
                                         , inrisco_final)
                                  VALUES ( rw_contaX.cdcooper
                                         , rw_contaX.nrcpfcgc
                                         , rw_contaX.nrdconta
                                         , 0 --nrctremp
                                         , 999 --cdcodali
                                         , NULL
                                         , NULL
                                         , vr_grupo_economico
                                         , rw_dat.dtmvtoan
                                         , NULL --dtdrisco
                                         , vr_inrisco_inclusao
                                         , vr_inrisco_rating
                                         , vr_inrisco_atraso
                                         , vr_inrisco_agravado
                                         , vr_inrisco_melhora
                                         , vr_inrisco_operacao
                                         , vr_inrisco_cpf
                                         , vr_inrisco_grupo
                                         , vr_inrisco_final);
         --
         END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro pc_insere_dados_contaX: '||SQLERRM;
          -- Efetuar rollback
          ROLLBACK;
    END pc_insere_dados_contaX;

    -- Carrega informações(dados crapass inicial)
    -- Insere Contas/ Contratos que não possuem Central de Risco(CRAPRIS)
    PROCEDURE pc_insere_dados_SEMrisco(pr_cdcooper IN NUMBER         -- Cooperativa
                                      ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                                      ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo) IS
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;
        --
        -- Reset Riscos
        vr_inrisco_inclusao := 2;
        vr_inrisco_rating   := NULL;
        vr_inrisco_atraso   := 2;
        vr_inrisco_agravado := NULL;
        vr_inrisco_melhora  := NULL;
        vr_inrisco_operacao := NULL;
        vr_inrisco_cpf      := NULL;
        vr_inrisco_grupo    := NULL;
        vr_inrisco_final    := NULL;
        vr_grupo_economico  := NULL;
    
        FOR rw_semrisco IN cr_semrisco(pr_cdcooper) LOOP
          -- Processa as variáveis de Riscos a serem inseridos
          vr_inrisco_agravado := fn_busca_risco_agravado(rw_semrisco.cdcooper
                                                        ,rw_semrisco.nrdconta
                                                        ,rw_dat.dtmvtoan);
          --
          vr_inrisco_operacao := greatest(nvl(vr_inrisco_rating, 2)
                                             ,vr_inrisco_inclusao
                                             ,vr_inrisco_atraso
                                             ,nvl(vr_inrisco_agravado, 2));
          --
          IF vr_inrisco_operacao > nvl(rw_semrisco.innivris_ctl,2) THEN
            vr_inrisco_cpf      := vr_inrisco_operacao;
          ELSE
            vr_inrisco_cpf      := nvl(rw_semrisco.innivris_ctl,2);
          END IF;                                                             
          --
          vr_inrisco_grupo    := fn_busca_grupo_economico(rw_semrisco.cdcooper
                                                         ,rw_semrisco.nrdconta
                                                         ,rw_semrisco.nrcpfcgc);
          --
          vr_inrisco_final    := greatest(nvl(vr_inrisco_cpf,2)
                                         ,nvl(vr_inrisco_grupo,2));
          --
          vr_grupo_economico := fn_busca_grp_economico(rw_semrisco.cdcooper
                                                      ,rw_semrisco.nrdconta);    
                                                            
          INSERT INTO tbrisco_central_ocr( cdcooper
                                         , nrcpfcgc
                                         , nrdconta
                                         , nrctremp
                                         , cdmodali
                                         , cdorigem
                                         , inddocto
                                         , nrdgrupo
                                         , dtrefere
                                         , dtdrisco
                                         , inrisco_inclusao
                                         , inrisco_rating
                                         , inrisco_atraso
                                         , inrisco_agravado
                                         , inrisco_melhora
                                         , inrisco_operacao
                                         , inrisco_cpf
                                         , inrisco_grupo
                                         , inrisco_final)
                                  VALUES ( rw_semrisco.cdcooper
                                         , rw_semrisco.nrcpfcgc
                                         , rw_semrisco.nrdconta
                                         , 0 --nrctremp
                                         , 0 --cdcodali
                                         , NULL
                                         , NULL
                                         , vr_grupo_economico
                                         , rw_dat.dtmvtoan
                                         , NULL --dtdrisco
                                         , vr_inrisco_inclusao
                                         , vr_inrisco_rating
                                         , vr_inrisco_atraso
                                         , vr_inrisco_agravado
                                         , vr_inrisco_melhora
                                         , vr_inrisco_operacao
                                         , vr_inrisco_cpf
                                         , vr_inrisco_grupo
                                         , vr_inrisco_final);
         --
         END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro pc_insere_dados_SEMrisco: '||SQLERRM;
          -- Efetuar rollback
          ROLLBACK;
    END pc_insere_dados_SEMrisco;

    -- Ajusta Risco CPF
    PROCEDURE pc_ajusta_risco_CPF(pr_cdcooper IN NUMBER         -- Cooperativa
                                 ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                                 ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;
        --
        FOR rw_ajusta_cpf IN cr_ajusta_cpf(pr_cdcooper) LOOP
                                                            
          UPDATE tbrisco_central_ocr
             SET inrisco_cpf = rw_ajusta_cpf.inrisco_cpf
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = rw_ajusta_cpf.nrdconta
             AND cdmodali not in(0,999);
         --
         END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro pc_ajusta_risco_CPF: '||SQLERRM;
          -- Efetuar rollback
          ROLLBACK;
    END pc_ajusta_risco_CPF; 
       
    --************************--
    --   INICIO DO PROGRAMA   --
    --************************--
    BEGIN
      vr_cdcritic := NULL;
      vr_dscritic := NULL;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;

      -- Se não encontrar registro da cooperativa
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcop;
      END IF;

      -- Busca calendário para a cooperativa selecionada
      OPEN cr_dat(pr_cdcooper);
      FETCH cr_dat INTO rw_dat;
      -- Se não encontrar calendário
      IF cr_dat%NOTFOUND THEN
        CLOSE cr_dat;
        -- Montar mensagem de critica
        vr_cdcritic  := 794;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_dat;
      END IF;

      -- Recupera parâmetro da TAB089
      OPEN cr_tab(pr_cdcooper);
      FETCH cr_tab INTO rw_tab;
      CLOSE cr_tab;
      -- Materialidade(Arrasto)
      vr_valor_arrasto := TO_NUMBER(replace(substr(rw_tab.dstextab, 3, 9), '.', ','));

      --INICIO
      -- Chama processo de limpeza
      pc_limpa_dados_risco(pr_cdcooper => pr_cdcooper  -- Cooperativa
                          ,pr_cdcritic => vr_cdcritic  -- Código da crítica
                          ,pr_dscritic => vr_dscritic);-- Erros do processo
        -- Verifica erro no DELETE
        IF vr_cdcritic = 0 THEN
          RAISE vr_exc_saida;
        ELSE
          COMMIT;
        END IF;

      -- Insere infomações de EMPRÉSTIMOS
      -- Modalidade 299 e 499
      pc_insere_dados_risco_emp(pr_cdcooper => pr_cdcooper  -- Cooperativa
                               ,pr_cdcritic => vr_cdcritic  -- Código da crítica
                               ,pr_dscritic => vr_dscritic);-- Erros do processo
        -- Verifica erro
        IF vr_cdcritic = 0 THEN
          RAISE vr_exc_saida;
        END IF;

      -- Insere infomações de ADP ou LIMITE
      -- Modalidade 101, 201 e 1901
      pc_insere_dados_riscoAL(pr_cdcooper => pr_cdcooper  -- Cooperativa
                                     ,pr_cdcritic => vr_cdcritic  -- Código da crítica
                                     ,pr_dscritic => vr_dscritic);-- Erros do processo
        -- Verifica erro
        IF vr_cdcritic = 0 THEN
          RAISE vr_exc_saida;
        END IF;

      -- Insere infomações de LIMITE DE DESCONTO
      -- Modalidade 301 e 302
      pc_insere_dados_riscoLD(pr_cdcooper => pr_cdcooper  -- Cooperativa
                                      ,pr_cdcritic => vr_cdcritic  -- Código da crítica
                                      ,pr_dscritic => vr_dscritic);-- Erros do processo
        -- Verifica erro
        IF vr_cdcritic = 0 THEN
          RAISE vr_exc_saida;
        END IF;

      -- Insere Contas/ Contratos que possuem Empréstimo ou Limite Desconto
      -- e não possuem Contrato Limite e/ ou ADP
      pc_insere_dados_contaX(pr_cdcooper => pr_cdcooper  -- Cooperativa
                            ,pr_cdcritic => vr_cdcritic  -- Código da crítica
                            ,pr_dscritic => vr_dscritic);-- Erros do processo
        -- Verifica erro
        IF vr_cdcritic = 0 THEN
          RAISE vr_exc_saida;
        END IF;

      -- Carrega informações(dados crapass inicial)
      -- Insere Contas/ Contratos que não possuem Central de Risco(CRAPRIS)
      pc_insere_dados_SEMrisco(pr_cdcooper => pr_cdcooper  -- Cooperativa
                              ,pr_cdcritic => vr_cdcritic  -- Código da crítica
                              ,pr_dscritic => vr_dscritic);-- Erros do processo
        -- Verifica erro
        IF vr_cdcritic = 0 THEN
          RAISE vr_exc_saida;
        END IF;
      --
      COMMIT;
      --
      -- Ajustar Risco CPF por Grupo Econômico
      -- Chama processo de ajuste CPF
      pc_ajusta_risco_CPF(pr_cdcooper => pr_cdcooper  -- Cooperativa
                         ,pr_cdcritic => vr_cdcritic  -- Código da crítica
                         ,pr_dscritic => vr_dscritic);-- Erros do processo
        -- Verifica erro no ajuste
        IF vr_cdcritic = 0 THEN
          RAISE vr_exc_saida;
        END IF;       
      --  
      -- Efetuar COMMIT FINAL!
      COMMIT;
      --
   EXCEPTION
      WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro na rotina PC_RISCO_CENTRAL_OCR. Detalhes: '||vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Retornar o erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado na rotina PC_RISCO_CENTRAL_OCR. Detalhes: '||sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
   END;
   END PC_RISCO_CENTRAL_OCR;  

END RISC0003;
/