CREATE OR REPLACE PACKAGE CECRED.SOAP0003 IS

  ---------------------------------------------------------------------------
  --
  --  Programa : SOAP0003
  --  Sistema  : Rotinas referentes ao SOA Suite
  --  Sigla    : CRED
  --  Autor    : Rafael Faria (supero)
  --  Data     : Julho/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao SOA Suite
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_gerar_evento_soa(pr_cdcooper                  IN tbgen_evento_soa.cdcooper%type -- Codigo da cooperativa
                               ,pr_nrdconta                  IN tbgen_evento_soa.nrdconta%type -- numero da conta
                               ,pr_nrctrprp                  IN tbgen_evento_soa.nrctrprp%type -- numero do contrato
                               ,pr_tpevento                  IN tbgen_evento_soa.tpevento%type -- tipo de evento (Exemplo: ATUALIZASTATUS)
                               ,pr_tproduto_evento           IN tbgen_evento_soa.tproduto_evento%type -- tipo produto (Exemplo: CDC)
                               ,pr_tpoperacao                IN tbgen_evento_soa.tpoperacao%type -- Tipo operacao (Exemplo: INSERT, UPDATE, DELETE)
                               ,pr_dhoperacao                IN tbgen_evento_soa.dhoperacao%type DEFAULT SYSTIMESTAMP -- data/hora da operacao
                               ,pr_dsprocessamento           IN tbgen_evento_soa.dsprocessamento%type DEFAULT NULL -- controle de processamento
                               ,pr_dsstatus                  IN tbgen_evento_soa.dsstatus%type DEFAULT NULL -- status do processamento
                               ,pr_dhevento                  IN tbgen_evento_soa.dhevento%type DEFAULT NULL -- data/hora do evento
                               ,pr_dserro                    IN tbgen_evento_soa.dserro%type DEFAULT NULL -- descricao do erro do processamento
                               ,pr_nrtentativas              IN tbgen_evento_soa.nrtentativas%type DEFAULT NULL -- numero de tentativas
                               ,pr_dsconteudo_requisicao     IN tbgen_evento_soa.dsconteudo_requisicao%type -- CLOB do conteudo enviado (XML)
                               ,pr_idevento                  OUT tbgen_evento_soa.idevento%type -- identificacao do evento
                               ,pr_dscritic                  OUT VARCHAR2); -- descricao de erro

END SOAP0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.SOAP0003 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : SOAP0003
  --  Sistema  : Rotinas referentes ao SOA Suite
  --  Sigla    : CRED
  --  Autor    : Rafael Faria (supero)
  --  Data     : Julho/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao SOA Suite
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------


  PROCEDURE pc_gerar_evento_soa(pr_cdcooper                  IN tbgen_evento_soa.cdcooper%type -- Codigo da cooperativa
                               ,pr_nrdconta                  IN tbgen_evento_soa.nrdconta%type -- numero da conta
                               ,pr_nrctrprp                  IN tbgen_evento_soa.nrctrprp%type -- numero do contrato
                               ,pr_tpevento                  IN tbgen_evento_soa.tpevento%type -- tipo de evento (Exemplo: ATUALIZASTATUS)
                               ,pr_tproduto_evento           IN tbgen_evento_soa.tproduto_evento%type -- tipo produto (Exemplo: CDC)
                               ,pr_tpoperacao                IN tbgen_evento_soa.tpoperacao%type -- Tipo operacao (Exemplo: INSERT, UPDATE, DELETE)
                               ,pr_dhoperacao                IN tbgen_evento_soa.dhoperacao%type DEFAULT SYSTIMESTAMP -- data/hora da operacao
                               ,pr_dsprocessamento           IN tbgen_evento_soa.dsprocessamento%type DEFAULT NULL -- controle de processamento
                               ,pr_dsstatus                  IN tbgen_evento_soa.dsstatus%type DEFAULT NULL -- status do processamento
                               ,pr_dhevento                  IN tbgen_evento_soa.dhevento%type DEFAULT NULL -- data/hora do evento
                               ,pr_dserro                    IN tbgen_evento_soa.dserro%type DEFAULT NULL -- descricao do erro do processamento
                               ,pr_nrtentativas              IN tbgen_evento_soa.nrtentativas%type DEFAULT NULL -- numero de tentativas
                               ,pr_dsconteudo_requisicao     IN tbgen_evento_soa.dsconteudo_requisicao%type -- CLOB do conteudo enviado (XML)
                               ,pr_idevento                  OUT tbgen_evento_soa.idevento%type -- identificacao do evento
                               ,pr_dscritic                  OUT VARCHAR2) IS -- descricao de erro

    /* ..........................................................................

      Programa : pc_grava_evento_soa
      Sistema  : Generico comunicao SOA Suite
      Sigla    : GENE
      Autor    : Rafael Faria (SUPERO)
      Data     : Julho/2018.                   Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Grava registro para acionamento servico SOA

      Alteração :

    ..........................................................................*/
    BEGIN
      insert into tbgen_evento_soa
                 (cdcooper
                 ,nrdconta
                 ,nrctrprp
                 ,tpevento
                 ,tproduto_evento
                 ,tpoperacao
                 ,dhoperacao
                 ,dsprocessamento
                 ,dsstatus
                 ,dhevento
                 ,dserro
                 ,nrtentativas
                 ,dsconteudo_requisicao)
           values
                 (pr_cdcooper
                 ,pr_nrdconta
                 ,pr_nrctrprp
                 ,pr_tpevento
                 ,pr_tproduto_evento
                 ,pr_tpoperacao
                 ,pr_dhoperacao
                 ,pr_dsprocessamento
                 ,pr_dsstatus
                 ,pr_dhevento
                 ,pr_dserro
                 ,pr_nrtentativas
                 ,pr_dsconteudo_requisicao)
        RETURNING tbgen_evento_soa.idevento INTO pr_idevento;

    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao inserir tbgen_evento_soa: ' || SQLERRM;
  END pc_gerar_evento_soa;

END SOAP0003;
/
