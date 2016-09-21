CREATE OR REPLACE PACKAGE CECRED.IMUT0001 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : IMUT0001
  --  Sistema  : Rotinas referentes a Imunidade Tributaria.
  --  Sigla    : IMUT
  --  Autor    : Odirlei - AMcom
  --  Data     : outubro/2013.                   Ultima atualizacao: 24/10/2013
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas referentes a Imunidade Tributaria.

  -- Alterações
  --  Alteracoes: 14/08/2013 - Alterado para que seja possivel imprimir relatorio
  --                           de imunidade por periodo e situação.
  --                           (Anderson/Amcom).
  --
  --              27/08/2013 - Ajustando BO para Ayllos(WEB)
  --                           (Andre Santos - SUPERO)
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Procedure para verificar imunidade tributaria e inserir valor de insenção */
  PROCEDURE pc_verifica_imunidade_trib( pr_cdcooper  IN  INTEGER               --> Codigo Cooperativa
                                       ,pr_nrdconta  IN  INTEGER               --> Numero da Conta
                                       ,pr_dtmvtolt  IN  DATE                  --> Data movimento
                                       ,pr_flgrvvlr  IN  BOOLEAN               --> Identificador se deve gravar valor
                                       ,pr_cdinsenc  IN  crapvin.cdinsenc%TYPE --> Codigo da insenção
                                       ,pr_vlinsenc  IN  crapvin.vlinsenc%TYPE --> Valor insento
                                       ,pr_flgimune  OUT BOOLEAN               --> Identificador se é imune
                                       ,pr_dsreturn  OUT VARCHAR2              --> Descricao retorno(NOK/OK)
                                       ,pr_tab_erro  OUT GENE0001.typ_tab_erro);--> Tabela erros

  /* Procedure para verificar periodo de imunidade tributaria */
  PROCEDURE pc_verifica_periodo_imune( pr_cdcooper  IN  INTEGER   --> Codigo Cooperativa
                                      ,pr_nrdconta  IN  INTEGER   --> Numero da Conta
                                      ,pr_flgimune  OUT BOOLEAN   --> Identificador se é imune
                                      ,pr_dtinicio  OUT  DATE     --> Data de inicio da imunidade
                                      ,pr_dttermin  OUT  DATE     --> Data termino da imunidadeValor insento
                                      ,pr_dsreturn  OUT VARCHAR2               --> Descricao retorno(NOK/OK)
                                      ,pr_tab_erro  OUT GENE0001.typ_tab_erro);--> Tabela erros
END IMUT0001;
/

CREATE OR REPLACE PACKAGE BODY CECRED.IMUT0001 AS

  --Tipo de Dados para cursor data
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

  /* Procedure para verificar imunidade tributaria e inserir valor de insenção */
  PROCEDURE pc_verifica_imunidade_trib( pr_cdcooper  IN  INTEGER               --> Codigo Cooperativa
                                       ,pr_nrdconta  IN  INTEGER               --> Numero da Conta
                                       ,pr_dtmvtolt  IN  DATE                  --> Data movimento
                                       ,pr_flgrvvlr  IN  BOOLEAN               --> Identificador se deve gravar valor
                                       ,pr_cdinsenc  IN  crapvin.cdinsenc%TYPE --> Codigo da insenção
                                       ,pr_vlinsenc  IN  crapvin.vlinsenc%TYPE --> Valor insento
                                       ,pr_flgimune  OUT BOOLEAN               --> Identificador se é imune
                                       ,pr_dsreturn  OUT VARCHAR2              --> Descricao retorno(NOK/OK)
                                       ,pr_tab_erro  OUT GENE0001.typ_tab_erro)--> Tabela erros
                                      IS


  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_verifica_imunidade_trib        Antigo: sistema/generico/procedures/b1wgen0159.p>>verifica-imunidade-tributaria
  --  Sistema  : Credito
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : outubro/2013.                   Ultima atualizacao: 24/10/2013
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para verificar a imunidade tributaria da conta
  --
  ---------------------------------------------------------------------------------------------------------------

    --Buscar associados
    CURSOR cr_crapass IS
      SELECT inpessoa,
             nrcpfcgc
        FROM crapass
        WHERE cdcooper = pr_cdcooper
          AND nrdconta = pr_nrdconta;
    rw_crapass  cr_crapass%rowtype;

    -- Buscar Cadastro de Imunidade Tributaria
    CURSOR cr_crapimt(pr_nrcpfcgc crapass.nrcpfcgc%type) IS
      SELECT dtcadast,
             cdsitcad
        FROM crapimt a
        WHERE a.progress_recid =
                  (SELECT MAX(a1.progress_recid)
                     FROM crapimt a1
                    WHERE a1.cdcooper = pr_cdcooper
                      AND a1.nrcpfcgc = pr_nrcpfcgc);
    rw_crapimt  cr_crapimt%rowtype;

    vr_exc_erro exception;
    vr_dtmvtolt date;
    vr_cdcritic INTEGER;         --> Codigo Critica
    vr_dscritic VARCHAR2(1000);   --> Descricao Critica

  BEGIN
    pr_flgimune := false;
    --Validar nrdconta
    IF pr_nrdconta = 0 THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Informar o numero da Conta';
      RAISE vr_exc_erro;
    END IF;

    -- Buscar associados
    OPEN cr_crapass;
    FETCH cr_crapass
      INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      --gerar critica
      vr_cdcritic:= 9;
      vr_dscritic:= NULL;
      CLOSE cr_crapass;
      RAISE vr_exc_erro;

    ELSE
      CLOSE cr_crapass;
    END IF;

    -- Se for diferente de pessoa Juridica,
    -- Deve retornar ao programa chamador sem erro
    IF rw_crapass.inpessoa <> 2 THEN
       pr_dsreturn := 'OK';
       RETURN;
    END IF;

    -- Buscar Cadastro de Imunidade Tributaria
    OPEN cr_crapimt(pr_nrcpfcgc => rw_crapass.nrcpfcgc);
    FETCH cr_crapimt
      INTO rw_crapimt;
    IF cr_crapimt%NOTFOUND THEN
      CLOSE cr_crapimt;
      pr_dsreturn := 'OK';
      RETURN;
    ELSE
      CLOSE cr_crapimt;
    END IF;

    -- Se a data do cadastro da Imunidade tributaria for menor ou igual a data do movimento
    -- e se estiver ativa
    IF rw_crapimt.dtcadast <= pr_dtmvtolt AND
       rw_crapimt.cdsitcad = 1            THEN  /* Situacao Aprovado */
      --verificar se deve gravar
      IF pr_flgrvvlr THEN
         --Verificar se existe os valores para gravar
         IF NVL(pr_cdinsenc,0) = 0 OR
            NVL(pr_vlinsenc,0) = 0 THEN
           --gerar critica e sair
           vr_cdcritic:= 0;
           vr_dscritic:= 'Informar os parametros de gravacao';
           RAISE vr_exc_erro;
         END IF;

         /*  Tratamento para o debito do IR em cotas -
             Nao grava com o ultimo dia do ano        */
         IF pr_cdinsenc = 6 THEN
           -- Leitura do calendario da cooperativa
           OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
           FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
           -- Se nao encontrar
           IF btch0001.cr_crapdat%NOTFOUND THEN
             -- Apenas fechar o cursor
             CLOSE btch0001.cr_crapdat;
           ELSE
             vr_dtmvtolt := rw_crapdat.dtmvtolt;
             CLOSE btch0001.cr_crapdat;
           END IF;
         END IF; -- fim pr_cdinsenc = 6

         BEGIN
           --Gravar cadastro dos valores insentos de IOF e IRRF
           INSERT INTO CRAPVIN
                    ( cdcooper
                     ,dtmvtolt
                     ,nrdconta
                     ,nrcpfcgc
                     ,cdinsenc
                     ,vlinsenc)
                  VALUES
                    ( pr_cdcooper -- cdcooper
                     ,nvl(vr_dtmvtolt,pr_dtmvtolt) -- dtmvtolt
                     ,pr_nrdconta -- nrdconta
                     ,rw_crapass.nrcpfcgc -- nrcpfcgc
                     ,pr_cdinsenc -- cdinsenc
                     ,pr_vlinsenc -- vlinsenc
                     );
         EXCEPTION
           WHEN OTHERS THEN
             vr_dscritic := 'Erro ao inserir CRAPVIN(nrdconta:'||pr_nrdconta||'): '||SQLerrm;
             RAISE vr_exc_erro;
         END;

      END IF; -- FIM flgrvvlr

      pr_flgimune := TRUE;

    END IF;

    pr_dsreturn := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      --Gerar Erro
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 0
                           ,pr_nrdcaixa => 0
                           ,pr_nrsequen => 1
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
      pr_dsreturn := 'NOK';
    WHEN OTHERS THEN
      vr_dscritic := 'Erro na IMUT0001.pc_verifica_imunidade_trib :'||SQLerrm;
      --Gerar Erro
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 0
                           ,pr_nrdcaixa => 0
                           ,pr_nrsequen => 1
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
      pr_dsreturn := 'NOK';
  END pc_verifica_imunidade_trib;

  /* Procedure para verificar periodo de imunidade tributaria */
  PROCEDURE pc_verifica_periodo_imune( pr_cdcooper  IN  INTEGER   --> Codigo Cooperativa
                                      ,pr_nrdconta  IN  INTEGER   --> Numero da Conta
                                      ,pr_flgimune  OUT BOOLEAN   --> Identificador se é imune
                                      ,pr_dtinicio  OUT  DATE     --> Data de inicio da imunidade
                                      ,pr_dttermin  OUT  DATE     --> Data termino da imunidadeValor insento
                                      ,pr_dsreturn  OUT VARCHAR2              --> Descricao retorno(NOK/OK)
                                      ,pr_tab_erro  OUT GENE0001.typ_tab_erro)--> Tabela erros
                                      IS


  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_verifica_periodo_imune        Antigo: sistema/generico/procedures/b1wgen0159.p>> verifica-periodo-imune
  --  Sistema  : Credito
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : outubro/2013.                   Ultima atualizacao: 24/10/2013
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  :  Procedure para verificar periodo de imunidade tributaria
  --
  ---------------------------------------------------------------------------------------------------------------

    --Buscar associados
    CURSOR cr_crapass IS
       SELECT inpessoa,
              nrcpfcgc
         FROM crapass
        WHERE cdcooper = pr_cdcooper
          AND nrdconta = pr_nrdconta;
    rw_crapass  cr_crapass%rowtype;

    -- Buscar Cadastro de Imunidade Tributaria
    CURSOR cr_crapimt(pr_nrcpfcgc crapass.nrcpfcgc%type) IS
      SELECT cdsitcad,
             dtcadast,
             dtcancel
        FROM crapimt a
        WHERE a.progress_recid =
                  (SELECT MAX(a1.progress_recid)
                     FROM crapimt a1
                    WHERE a1.cdcooper = pr_cdcooper
                      AND a1.nrcpfcgc = pr_nrcpfcgc);
    rw_crapimt  cr_crapimt%rowtype;

    vr_exc_erro exception;
    vr_cdcritic INTEGER;         --> Codigo Critica
    vr_dscritic VARCHAR2(1000);  --> Descricao Critica

  BEGIN

    pr_flgimune := false;
    pr_dtinicio := null;
    pr_dttermin := null;

    --Validar nrdconta
    IF pr_nrdconta = 0 THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Informar o numero da Conta';
      RAISE vr_exc_erro;
    END IF;

    -- Buscar associados
    OPEN cr_crapass;
    FETCH cr_crapass
      INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      --gerar critica
      vr_cdcritic:= 9;
      vr_dscritic:= NULL;
      CLOSE cr_crapass;
      RAISE vr_exc_erro;

    ELSE
      CLOSE cr_crapass;
    END IF;

    -- Se for diferente de pessoa Juridica,
    -- Deve retornar ao programa chamador sem erro
    IF rw_crapass.inpessoa <> 2 THEN
       pr_dsreturn := 'OK';
       RETURN;
    END IF;

    -- Buscar Cadastro de Imunidade Tributaria
    OPEN cr_crapimt(pr_nrcpfcgc => rw_crapass.nrcpfcgc);
    FETCH cr_crapimt
      INTO rw_crapimt;
    IF cr_crapimt%NOTFOUND THEN
      CLOSE cr_crapimt;
      pr_dsreturn := 'OK';
      RETURN;
    ELSE
      IF rw_crapimt.cdsitcad > 0  THEN
        pr_dtinicio := rw_crapimt.dtcadast;
        pr_dttermin := rw_crapimt.dtcancel;
        pr_flgimune := TRUE;
      END IF;
      CLOSE cr_crapimt;
    END IF;

    pr_dsreturn := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      --Gerar Erro
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 0
                           ,pr_nrdcaixa => 0
                           ,pr_nrsequen => 1
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
      pr_dsreturn := 'NOK';
    WHEN OTHERS THEN
      vr_dscritic := 'Erro na IMUT0001.pc_verifica_periodo_imune :'||SQLerrm;
      --Gerar Erro
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 0
                           ,pr_nrdcaixa => 0
                           ,pr_nrsequen => 1
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
      pr_dsreturn := 'NOK';
  END pc_verifica_periodo_imune;
END IMUT0001;
/

