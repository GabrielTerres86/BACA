CREATE OR REPLACE PACKAGE CECRED.CADA0015 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CADA0015
  --  Sistema  : Rotinas para leitura das tabelas Ayllos e atualizacao das tabelas do cadastro unificado
  --  Sigla    : CADA
  --  Autor    : Andrino Carlos de Souza Junior (Mouts)
  --  Data     : Agosto/2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: OnLine
  -- Objetivo  :
  --
  ---------------------------------------------------------------------------------------------------------------

   -- Funcao que recebera a conta e retornara o IDPESSOA
  FUNCTION fn_busca_pessoa(pr_cdcooper crapass.cdcooper%TYPE  --> Codigo da cooperativa
                          ,pr_nrdconta crapass.nrdconta%TYPE  --> Numero da conta
                          ,pr_idseqttl crapttl.idseqttl%TYPE  --> Sequencia do titular
                          ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE DEFAULT NULL ) --> CPF/CNPJ da pessoa
             RETURN NUMBER ;

  -- Rotina para atualizacao da tabela de enderecos (CRAPENC)
  PROCEDURE pc_crapenc(pr_crapenc     IN crapenc%ROWTYPE  --> Tabela de Endereco atual
                      ,pr_tpoperacao  IN INTEGER          --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2);       --> Retorno de Erro

  -- Rotina para buscar o municipio com base no nome
  PROCEDURE pc_trata_municipio(pr_dscidade  IN crapmun.dscidade%TYPE, -- Descricao da cidade
                               pr_cdestado  IN crapmun.cdestado%TYPE, -- Sigla de estado
                               pr_idcidade OUT crapmun.idcidade%TYPE, -- Identificador de cidade
                               pr_dscritic OUT VARCHAR2); -- Erro de execucao

  -- Rotina para atualizacao da tabela de telefones (CRAPTFC)
  PROCEDURE pc_craptfc(pr_craptfc     IN craptfc%ROWTYPE            --> Tabela de telefone atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2);                 --> Retorno de Erro


  -- Rotina para atualizacao da tabela de emails (CRAPCEM)
  PROCEDURE pc_crapcem(pr_crapcem     IN crapcem%ROWTYPE            --> Tabela de email atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2);                 --> Retorno de Erro

  -- Rotina para atualizacao da tabela de bens (CRAPBEM)
  PROCEDURE pc_crapbem(pr_crapbem     IN crapbem%ROWTYPE            --> Tabela de bem atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2);                 --> Retorno de Erro

  -- Rotina para atualizacao da tabela de empresa participacao societaria (CRAPEPA)
  PROCEDURE pc_crapepa(pr_crapepa     IN crapepa%ROWTYPE            --> Tabela de empresa participacao societaria atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2);                 --> Retorno de Erro

  -- Rotina para atualizacao da tabela de responsavel legal (CRAPCRL)
  PROCEDURE pc_crapcrl(pr_crapcrl     IN crapcrl%ROWTYPE            --> Tabela de responsavel legal atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2);                 --> Retorno de Erro

  -- Rotina para atualizacao da tabela de dependentes(CRAPDEP)
  PROCEDURE pc_crapdep(pr_crapdep     IN crapdep%ROWTYPE            --> Tabela de responsavel legal atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2);                 --> Retorno de Erro

  -- Rotina para atualizacao da tabela de conjuge (CRAPCJE)
  PROCEDURE pc_crapcje(pr_crapcje     IN crapcje%ROWTYPE            --> Tabela de conjuge atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2);                 --> Retorno de Erro

  -- Rotina para atualizacao da tabela de avalista (CRAPAVT)
  PROCEDURE pc_crapavt(pr_crapavt     IN crapavt%ROWTYPE            --> Tabela de avalista atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2);                 --> Retorno de Erro

  -- Rotina para atualizacao da tabela de politico exposto (tbcadast_politico_exposto)
  PROCEDURE pc_politico_exposto( pr_politico_exposto  IN tbcadast_politico_exposto%ROWTYPE            --> Tabela de avalista atual
                                ,pr_tpoperacao        IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                ,pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                                ,pr_cdoperad          IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                                ,pr_dscritic         OUT VARCHAR2);                 --> Retorno de Erro

  -- Rotina para atualizacao da tabela de dados financeiros (CRAPJFN)
  PROCEDURE pc_crapjfn(pr_crapjfn     IN crapjfn%ROWTYPE            --> Tabela de email atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2);                 --> Retorno de Erro

  -- Rotina para atualizacao da tabela de dados titulares (CRAPTTL)
  PROCEDURE pc_crapttl(pr_crapttl     IN crapttl%ROWTYPE            --> Tabela de titular atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2);                 --> Retorno de Erro

  -- Rotina para atualizacao da tabela de dados pessoa juridica (CRAPJUR)
  PROCEDURE pc_crapjur(pr_crapjur     IN crapjur%ROWTYPE            --> Tabela de juridica atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2);                 --> Retorno de Erro

  -- Rotina para atualizacao da tabela de dados pessoa (CRAPASS)
  PROCEDURE pc_crapass(pr_crapass     IN crapass%ROWTYPE            --> Tabela de associado atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2);                 --> Retorno de Erro

  -- Rotina para processar registros pendentes de atualização
  PROCEDURE pc_processa_pessoa_atlz( pr_cdcooper  IN INTEGER DEFAULT NULL, --> Codigo da coperativa quando processo de replic. online
                                     pr_nrdconta  IN INTEGER DEFAULT NULL, --> Nr. da conta quando processo de replic. online
                                     pr_dscritic   OUT VARCHAR2);          --> Retorno de Erro
  -- Rotina para criar a associacao da conta com a pessoa de representante e 
  -- responsavel legal
  PROCEDURE pc_cria_pessoa_conta(wp_idalteracao tbhistor_pessoa_conta.idalteracao%TYPE,
                                 wp_intabela    tbhistor_pessoa_conta.intabela%TYPE,
                                 wp_idpessoa    tbcadast_pessoa.idpessoa%TYPE,
                                 wp_cdcooper    crapass.cdcooper%TYPE,
                                 wp_nrdconta    crapass.nrdconta%TYPE);


END CADA0015;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CADA0015 IS


  -- Busca os dados da conta
  CURSOR cr_crapass( pr_cdcooper crapass.cdcooper%TYPE,
                     pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT nrcpfcgc
      FROM crapass
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;

  -- Verifica se a pessoa ja possui cadastro de pessoa
  CURSOR cr_pessoa(pr_nrcpfcgc tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT *
      FROM tbcadast_pessoa
     WHERE nrcpfcgc = pr_nrcpfcgc;

  -- Retornar todos os dados da pessoa fisica
  CURSOR cr_pessoa_fis (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
    SELECT *
      FROM vwcadast_pessoa_fisica
     WHERE idpessoa = pr_idpessoa;

  -- Retornar todos os dados da pessoa fisica
  CURSOR cr_pessoa_fis_CPF (pr_nrcpf tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT *
      FROM vwcadast_pessoa_fisica
     WHERE nrcpf = pr_nrcpf;

  -- Retornar todos os dados da pessoa juridica
  CURSOR cr_pessoa_jur (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
    SELECT *
      FROM vwcadast_pessoa_juridica
     WHERE idpessoa = pr_idpessoa;


  vr_exc_saida EXCEPTION;

  -- Rotina para criar a associacao da conta com a pessoa de representante e 
  -- responsavel legal
  PROCEDURE pc_cria_pessoa_conta(wp_idalteracao tbhistor_pessoa_conta.idalteracao%TYPE,
                                 wp_intabela    tbhistor_pessoa_conta.intabela%TYPE,
                                 wp_idpessoa    tbcadast_pessoa.idpessoa%TYPE,
                                 wp_cdcooper    crapass.cdcooper%TYPE,
                                 wp_nrdconta    crapass.nrdconta%TYPE) IS
    -- Cursor para buscar as contas com base no idpessoa
    CURSOR cr_conta IS
      SELECT b.cdcooper,
             b.nrdconta
        FROM crapass b,
             tbcadast_pessoa a
       WHERE a.idpessoa = wp_idpessoa
         AND b.nrcpfcgc = a.nrcpfcgc
         AND b.inpessoa <> 1
         AND (b.cdcooper <> wp_cdcooper
          OR  b.nrdconta <> wp_nrdconta)
       UNION
      SELECT b.cdcooper,
             b.nrdconta
        FROM crapttl b,
             tbcadast_pessoa a
       WHERE a.idpessoa = wp_idpessoa
         AND b.nrcpfcgc = a.nrcpfcgc
         AND (b.cdcooper <> wp_cdcooper
          OR  b.nrdconta <> wp_nrdconta);
  BEGIN
    FOR rw_conta IN cr_conta LOOP
      BEGIN
        INSERT INTO tbhistor_pessoa_conta
          (idalteracao,
           intabela,
           cdcooper,
           nrdconta)
         VALUES
          (wp_idalteracao,
           wp_intabela,
           rw_conta.cdcooper,
           rw_conta.nrdconta);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
  END;                                 

  -- Rotina para criar registro na tbhistor_conta_comunic_soa
  FUNCTION cria_conta_comunic_soa(pr_cdcooper tbhistor_conta_comunic_soa.cdcooper%TYPE,
                                  pr_nrdconta tbhistor_conta_comunic_soa.nrdconta%TYPE,
                                  pr_nmtabela tbhistor_conta_comunic_soa.nmtabela_oracle%TYPE) 
    RETURN NUMBER IS
    
    vr_idalteracao tbhistor_conta_comunic_soa.idalteracao%TYPE;
    
  BEGIN
    -- Busca o sequencial
    vr_idalteracao := fn_sequence(pr_nmtabela => 'TBHISTOR_CONTA_COMUNIC_SOA'
                                 ,pr_nmdcampo => 'IDALTERACAO'
                                 ,pr_dsdchave => '0');
    BEGIN
      INSERT INTO tbhistor_conta_comunic_soa  
        (idalteracao, 
         nmtabela_oracle, 
         cdcooper, 
         nrdconta, 
         dhalteracao, 
         tpsituacao)
       VALUES
        (vr_idalteracao,
         pr_nmtabela,
         pr_cdcooper,
         pr_nrdconta,
         SYSDATE,
         0);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;
    
    RETURN vr_idalteracao;
    
  END;    

  -- Rotina para gerar alerta de inconsistencia de cadastro de pessoa
  -- que não precisam ser enviados aos usuarios
  PROCEDURE pc_gerar_alerta_pessoa(pr_cdcooper    IN NUMBER                    --> Codigo da cooperativa
                                  ,pr_nrdconta    IN NUMBER                    --> Numero da conta  do cooperado
                                  ,pr_idseqttl    IN INTEGER                   --> Sequencial do titular
                                  ,pr_nmtabela    IN VARCHAR2                  --> Nome da tabela
                                  ,pr_dsalerta    IN VARCHAR2 ) IS             --> Descrição do alerta

    /* ..........................................................................
    --
    --  Programa : pc_gerar_alerta_pessoa
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Setembro/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para gerar alerta de inconsistencia de cadastro de pessoa
    --               que não precisam ser enviados aos usuarios
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    -- Cursor sobre os email da pessoa


    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_des_erro crapcri.dscritic%TYPE;
    vr_exc_erro EXCEPTION;

  BEGIN

    /* Ex. Pessoa nao encontrada - erro ocorre qnd é excluido o segundo titular,
           nessa situação, todos os dados como email, endereço também são excluidos, porém
           como a pessoa nao é encontrada gera alerta, mas nesse caso nao deve excluir mesmo
           pois a pessoa continua a existir, podendo até ser de outras contas,
           só perde o vinculo com a conta
    */

    -- Insere na inconsistencia
    gene0005.pc_gera_inconsistencia(pr_cdcooper => nvl(pr_cdcooper,3)
                                   ,pr_iddgrupo => 3 -- CRM
                                   ,pr_tpincons => 1
                                   ,pr_dsregist => ' Cooper  : '||pr_cdcooper ||
                                                   ' Conta   : '||pr_nrdconta ||
                                                   ' Seq.tit.: '||pr_idseqttl ||
                                                   ' Dt.Atlz.: '||to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS')
                                   ,pr_dsincons => substr('Atualização tabela '||pr_nmtabela ||
                                                   ': '||pr_dsalerta,1,500)
                                   ,pr_des_erro => vr_des_erro
                                   ,pr_dscritic => vr_dscritic);

	  IF vr_des_erro <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      NULL;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro nao tratado na pc_gerar_alerta_pessoa: '||SQLERRM;
  END pc_gerar_alerta_pessoa;


  -- Funcao que recebera a conta e retornara o IDPESSOA
  FUNCTION fn_busca_pessoa(pr_cdcooper crapass.cdcooper%TYPE  --> Codigo da cooperativa
                          ,pr_nrdconta crapass.nrdconta%TYPE  --> Numero da conta
                          ,pr_idseqttl crapttl.idseqttl%TYPE  --> Sequencia do titular
                          ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE DEFAULT NULL ) --> CPF/CNPJ da pessoa
             RETURN NUMBER IS
    -- Cursor para buscar o CPF/CNPJ do titular da conta
    CURSOR cr_crapass IS
      SELECT nrcpfcgc
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;

    -- Cursor para buscar o CPF para quando nao for o primeiro titular
    CURSOR cr_crapttl IS
      SELECT nrcpfcgc
        FROM crapttl
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND idseqttl = pr_idseqttl;

    -- Cursor para retornar o IDPESSOA do CPF / CNPJ
    CURSOR cr_pessoa(pr_nrcpfcgc tbcadast_pessoa.nrcpfcgc%TYPE) IS
      SELECT idpessoa
        FROM tbcadast_pessoa
       WHERE nrcpfcgc = pr_nrcpfcgc;

    -- Variaveis gerais
    vr_nrcpfcgc tbcadast_pessoa.nrcpfcgc%TYPE; -- Numero do CPF / CNPJ da pessoa
    vr_idpessoa tbcadast_pessoa.idpessoa%TYPE; -- Identificador de pessoa
  BEGIN
    -- Se for o primeiro titular
    IF nvl(pr_idseqttl,1) = 1 THEN
      -- Busca do cadastro de primeiro titular
      OPEN cr_crapass;
      FETCH cr_crapass INTO vr_nrcpfcgc;
      CLOSE cr_crapass;
    ELSE
      -- Busca do cadastro de titulares da conta
      OPEN cr_crapttl;
      FETCH cr_crapttl INTO vr_nrcpfcgc;
      CLOSE cr_crapttl;
    END IF;

    IF nvl(pr_nrdconta,0) = 0 AND
       nvl(pr_nrcpfcgc,0) > 0 THEN
      vr_nrcpfcgc := pr_nrcpfcgc;
    END IF;

    -- Busca o IDPESSOA
    OPEN cr_pessoa(pr_nrcpfcgc => vr_nrcpfcgc);
    FETCH cr_pessoa INTO vr_idpessoa;
    CLOSE cr_pessoa;

    -- Retorna o ID da pessoa
    RETURN vr_idpessoa;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  -- Rotina para buscar o municipio com base no nome
  PROCEDURE pc_trata_municipio(pr_dscidade  IN crapmun.dscidade%TYPE, -- Descricao da cidade
                               pr_cdestado  IN crapmun.cdestado%TYPE, -- Sigla de estado
                               pr_idcidade OUT crapmun.idcidade%TYPE, -- Identificador de cidade
                               pr_dscritic OUT VARCHAR2) IS -- Erro de execucao
    -- Cursor sobre a tabela de municipios
    CURSOR cr_crapmun IS
      SELECT a.idcidade
        FROM crapmun a
       WHERE a.dscidade = trim(pr_dscidade)
         AND a.cdestado = pr_cdestado;

    -- Cursor sobre a tabela de municipios sem utilizar ESTADO
    CURSOR cr_crapmun_sem_uf IS
      SELECT a.idcidade
        FROM crapmun a
       WHERE a.dscidade = trim(pr_dscidade)
        ORDER BY decode(a.cdestado,'SC',1,
                                   'RS',2,
                                   'PR',3,4), a.cdestado;

  BEGIN
    -- Se nao vier o ESTADO, deve-se priorizar SC, PR e RS.
    -- Foi feito cursor separado para nao perder performance para quando vier CIDADE e ESTADO
    IF pr_cdestado IS NULL THEN
      -- Busca o municipio
      OPEN cr_crapmun_sem_uf;
      FETCH cr_crapmun_sem_uf INTO pr_idcidade;
      CLOSE cr_crapmun_sem_uf;
    ELSE
      -- Busca o municipio
      OPEN cr_crapmun;
      FETCH cr_crapmun INTO pr_idcidade;
      CLOSE cr_crapmun;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_trata_municipio: ' ||SQLERRM;
  END;

  -- Rotina para atualizacao da tabela de enderecos (CRAPENC)
  PROCEDURE pc_crapenc(pr_crapenc     IN crapenc%ROWTYPE  --> Tabela de Endereco atual
                      ,pr_tpoperacao  IN INTEGER          --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2) IS     --> Retorno de Erro
    -- Cursor sobre os enderecos da pessoa
    CURSOR cr_endereco(pr_idpessoa       tbcadast_pessoa.idpessoa%TYPE,
                       pr_tpendereco     tbcadast_pessoa_endereco.tpendereco%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_endereco enc
       WHERE enc.idpessoa   = pr_idpessoa
         AND enc.tpendereco = pr_tpendereco;
    rw_endereco cr_endereco%ROWTYPE;

    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_idpessoa tbcadast_pessoa.idpessoa%TYPE; -- Identificador de pessoa
    vr_pessoa_endereco tbcadast_pessoa_endereco%ROWTYPE; -- Registro de endereco
  BEGIN
    -- Se nao for informado o IDPESSOA, deve-se buscar
    IF pr_idpessoa IS NULL THEN
      -- Busca o ID PESSOA do endereco
      vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapenc.cdcooper,
                                     pr_nrdconta => pr_crapenc.nrdconta,
                                     pr_idseqttl => pr_crapenc.idseqttl);
      IF vr_idpessoa IS NULL THEN
        vr_dscritic := 'Nao encontrado PESSOA para alteracao de endereco';
        RAISE vr_exc_saida;
      END IF;
    ELSE
      vr_idpessoa := pr_idpessoa;
    END IF;

    -- Busca os dados do tipo de endereco
    OPEN cr_endereco(pr_idpessoa   => vr_idpessoa,
                     pr_tpendereco => pr_crapenc.tpendass);

    FETCH cr_endereco INTO rw_endereco;
    CLOSE cr_endereco;

    -- Se for uma exclusao
    IF pr_tpoperacao = 3 THEN
      -- Se encontrou registro na busca
      IF rw_endereco.nrseq_endereco IS NOT NULL THEN
        -- Efetua a exclusao do endereco
        cada0010.pc_exclui_pessoa_endereco(pr_idpessoa => vr_idpessoa,
                                           pr_nrseq_endereco => rw_endereco.nrseq_endereco,
                                           pr_cdoperad_altera => pr_cdoperad,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    ELSE -- Se for alteracao ou inclusao

      --> carregar informações existentes, para garantir que informações
      --> que não existam nesta estrutura sejam perdidas.
      vr_pessoa_endereco := rw_endereco;

      -- Utilizar a sequencia que ja existe da alteracao. Se for inclusao sera vazio
      vr_pessoa_endereco.nrseq_endereco         := rw_endereco.nrseq_endereco;

      -- Busca o municipio
      pc_trata_municipio(pr_dscidade => pr_crapenc.nmcidade,
                         pr_cdestado => TRIM(pr_crapenc.cdufende),
                         pr_idcidade => vr_pessoa_endereco.idcidade,
                         pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Popula os campos para inserir o registro
      vr_pessoa_endereco.idpessoa               := vr_idpessoa;
      vr_pessoa_endereco.tpendereco             := pr_crapenc.tpendass;
      vr_pessoa_endereco.nmlogradouro           := pr_crapenc.dsendere;
      vr_pessoa_endereco.nrlogradouro           := pr_crapenc.nrendere;
      vr_pessoa_endereco.dscomplemento          := pr_crapenc.complend;
      vr_pessoa_endereco.nmbairro               := pr_crapenc.nmbairro;
      vr_pessoa_endereco.nrcep                  := pr_crapenc.nrcepend;
      vr_pessoa_endereco.tpimovel               := pr_crapenc.incasprp;
      vr_pessoa_endereco.vldeclarado            := pr_crapenc.vlalugue;
      vr_pessoa_endereco.dtalteracao            := pr_crapenc.dtaltenc;
      vr_pessoa_endereco.dtinicio_residencia    := pr_crapenc.dtinires;
      vr_pessoa_endereco.tporigem_cadastro      := pr_crapenc.idorigem;
      vr_pessoa_endereco.cdoperad_altera        := pr_cdoperad;

      -- Efetua a inclusao
      cada0010.pc_cadast_pessoa_endereco(pr_pessoa_endereco => vr_pessoa_endereco
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;

	EXCEPTION
    WHEN vr_exc_saida THEN
      --> Apenas gerar alerta
      pc_gerar_alerta_pessoa(pr_cdcooper => pr_crapenc.cdcooper
                            ,pr_nrdconta => pr_crapenc.nrdconta
                            ,pr_idseqttl => pr_crapenc.idseqttl
                            ,pr_nmtabela => 'CRAPENC'
                            ,pr_dsalerta => vr_dscritic);

    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_crapenc: '||SQLERRM;
  END;


  -- Rotina para atualizacao da tabela de operadores de Internet (CRAPOPI)
  PROCEDURE pc_crapopi(pr_crapopi     IN crapopi%ROWTYPE  --> Tabela de operadores de internet
                      ,pr_tpoperacao  IN INTEGER          --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2) IS     --> Retorno de Erro

    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_idalteracao tbhistor_conta_comunic_soa.idalteracao%TYPE; -- Identificador de pessoa
  BEGIN
    -- Insere na tabela de capa
    vr_idalteracao := cria_conta_comunic_soa(pr_crapopi.cdcooper,
                                             pr_crapopi.nrdconta,
                                             'CRAPOPI');

    -- Insere na tabela de detalhes
    BEGIN
      INSERT INTO tbhistor_crapopi
        (idalteracao, 
         dhalteracao, 
         tpoperacao, 
         cdcooper, 
         nrdconta, 
         nrcpfope, 
         dsdcargo,
         nmoperad,
         flgsitop) 
       VALUES
        (vr_idalteracao, 
         SYSDATE, 
         pr_tpoperacao, 
         pr_crapopi.cdcooper, 
         pr_crapopi.nrdconta, 
         pr_crapopi.nrcpfope,
         nvl(pr_crapopi.dsdcargo,' '),
         pr_crapopi.nmoperad,
         pr_crapopi.flgsitop);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir na tbhistor_crapopi: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
	EXCEPTION
    WHEN vr_exc_saida THEN
      --> Apenas gerar alerta
      pc_gerar_alerta_pessoa(pr_cdcooper => pr_crapopi.cdcooper
                            ,pr_nrdconta => pr_crapopi.nrdconta
                            ,pr_idseqttl => 1
                            ,pr_nmtabela => 'CRAPOPI'
                            ,pr_dsalerta => vr_dscritic);

    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_crapopi: '||SQLERRM;
  END;


  -- Rotina para atualizacao da tabela de emails (CRAPCEM)
  PROCEDURE pc_crapcem(pr_crapcem     IN crapcem%ROWTYPE            --> Tabela de email atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2) IS               --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pc_crapcem
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para atualizacao da tabela de emails (CRAPCEM)
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    -- Cursor sobre os email da pessoa
    CURSOR cr_email(pr_idpessoa    tbcadast_pessoa.idpessoa%TYPE,
                    pr_nrseq_email tbcadast_pessoa_email.nrseq_email%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_email
       WHERE idpessoa     = pr_idpessoa
         AND nrseq_email  = pr_nrseq_email;
    rw_email cr_email%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE; -- Identificador de pessoa
    vr_pessoa_email    tbcadast_pessoa_email%ROWTYPE; -- Registro de email
  BEGIN

    -- Se nao for informado o IDPESSOA, deve-se buscar
    IF pr_idpessoa IS NULL THEN
      -- Busca o ID PESSOA do email
      vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapcem.cdcooper,
                                     pr_nrdconta => pr_crapcem.nrdconta,
                                     pr_idseqttl => pr_crapcem.idseqttl);
      IF vr_idpessoa IS NULL THEN
        vr_dscritic := 'Nao encontrado PESSOA para alteracao do email';
        RAISE vr_exc_saida;
      END IF;
    ELSE
      vr_idpessoa := pr_idpessoa;
    END IF;

    -- Busca os dados do email
    OPEN cr_email(pr_idpessoa    => vr_idpessoa,
                  pr_nrseq_email => pr_crapcem.cddemail);

    FETCH cr_email INTO rw_email;
    CLOSE cr_email;

    -- Se for uma exclusao
    IF pr_tpoperacao = 3 THEN
      -- Se encontrou registro na busca
      IF rw_email.nrseq_email IS NOT NULL THEN
        -- Efetua a exclusao do registro
        cada0010.pc_exclui_pessoa_email( pr_idpessoa     => vr_idpessoa,
                                         pr_nrseq_email  => rw_email.nrseq_email,
                                         pr_cdoperad_altera => pr_cdoperad,
                                         pr_cdcritic     => vr_cdcritic,
                                         pr_dscritic     => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    ELSE -- Se for alteracao ou inclusao
      --> carregar informações existentes, para garantir que informações
      --> que não existam nesta estrutura sejam perdidas.
      vr_pessoa_email  := rw_email;

      -- Utilizar a sequencia que ja existe da alteracao. Se for inclusao sera vazio
      vr_pessoa_email.nrseq_email         := rw_email.nrseq_email;

      -- Popula os campos para inserir o registro
      vr_pessoa_email.idpessoa                := vr_idpessoa;
      vr_pessoa_email.dsemail                 := pr_crapcem.dsdemail;
      vr_pessoa_email.nmpessoa_contato        := pr_crapcem.nmpescto;
      vr_pessoa_email.nmsetor_pessoa_contato  := pr_crapcem.secpscto;
      vr_pessoa_email.cdoperad_altera         := pr_cdoperad;
	  vr_pessoa_email.insituacao			  := 1; --Ativo	

      -- Efetua a inclusao
      cada0010.pc_cadast_pessoa_email (pr_pessoa_email => vr_pessoa_email
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;

	EXCEPTION
    WHEN vr_exc_saida THEN
      --> Apenas gerar alerta
      pc_gerar_alerta_pessoa(pr_cdcooper => pr_crapcem.cdcooper
                            ,pr_nrdconta => pr_crapcem.nrdconta
                            ,pr_idseqttl => pr_crapcem.idseqttl
                            ,pr_nmtabela => 'CRAPCEM'
                            ,pr_dsalerta => vr_dscritic);

    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_crapcem: '||SQLERRM;
  END pc_crapcem;

  -- Rotina para atualizacao da tabela de telefones (CRAPTFC)
  PROCEDURE pc_craptfc(pr_craptfc     IN craptfc%ROWTYPE            --> Tabela de telefone atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2) IS               --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pc_craptfc
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para atualizacao da tabela de telefones (CRAPTFC)
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    -- Buscar dados do telefone
    CURSOR cr_telefone( pr_idpessoa    tbcadast_pessoa.idpessoa%TYPE,
                        pr_nrseq_telefone tbcadast_pessoa_telefone.nrseq_telefone%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_telefone
       WHERE idpessoa     = pr_idpessoa
         AND nrseq_telefone  = pr_nrseq_telefone;
    rw_telefone cr_telefone%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE;    -- Identificador de pessoa
    vr_pessoa_telefone tbcadast_pessoa_telefone%ROWTYPE; -- Registro de telefone
  BEGIN

    -- Se nao for informado o IDPESSOA, deve-se buscar
    IF pr_idpessoa IS NULL THEN
      -- Busca o ID PESSOA do telefone
      vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_craptfc.cdcooper,
                                     pr_nrdconta => pr_craptfc.nrdconta,
                                     pr_idseqttl => pr_craptfc.idseqttl);
      IF vr_idpessoa IS NULL THEN
        vr_dscritic := 'Nao encontrado PESSOA para alteracao do telefone';
        RAISE vr_exc_saida;
      END IF;
    ELSE
      vr_idpessoa := pr_idpessoa;
    END IF;

    -- Busca os dados do telefone
    OPEN cr_telefone(pr_idpessoa       => vr_idpessoa,
                     pr_nrseq_telefone => pr_craptfc.cdseqtfc);

    FETCH cr_telefone INTO rw_telefone;
    CLOSE cr_telefone;

    -- Se for uma exclusao
    IF pr_tpoperacao = 3 THEN
      -- Se encontrou registro na busca
      IF rw_telefone.nrseq_telefone IS NOT NULL THEN
        -- Efetua a exclusao do registro
        cada0010.pc_exclui_pessoa_telefone( pr_idpessoa        => vr_idpessoa,
                                            pr_nrseq_telefone  => rw_telefone.nrseq_telefone,
                                            pr_cdoperad_altera => pr_cdoperad,
                                            pr_cdcritic        => vr_cdcritic,
                                            pr_dscritic        => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    ELSE -- Se for alteracao ou inclusao

      --> Carregar informações existentes, para garantir que informações
      --> que não existam nesta estrutura sejam perdidas.
      vr_pessoa_telefone := rw_telefone;

      -- Utilizar a sequencia que ja existe da alteracao. Se for inclusao sera vazio
      vr_pessoa_telefone.nrseq_telefone        := rw_telefone.nrseq_telefone;

      -- Popula os campos para inserir o registro
      vr_pessoa_telefone.idpessoa              := vr_idpessoa;
      vr_pessoa_telefone.cdoperadora           := pr_craptfc.cdopetfn ;
      vr_pessoa_telefone.tptelefone            := pr_craptfc.tptelefo ;
      vr_pessoa_telefone.nmpessoa_contato      := pr_craptfc.nmpescto ;
      vr_pessoa_telefone.nmsetor_pessoa_contato:= pr_craptfc.secpscto ;
      vr_pessoa_telefone.nrddd                 := pr_craptfc.nrdddtfc ;
      vr_pessoa_telefone.nrtelefone            := pr_craptfc.nrtelefo ;
      vr_pessoa_telefone.nrramal               := pr_craptfc.nrdramal ;
      vr_pessoa_telefone.insituacao            := pr_craptfc.idsittfc ;
      vr_pessoa_telefone.tporigem_cadastro     := pr_craptfc.idorigem ;
      vr_pessoa_telefone.flgaceita_sms         := pr_craptfc.flgacsms ;

      vr_pessoa_telefone.cdoperad_altera       := pr_cdoperad;

      -- Efetua a inclusao
      cada0010.pc_cadast_pessoa_telefone (pr_pessoa_telefone => vr_pessoa_telefone
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;

	EXCEPTION
    WHEN vr_exc_saida THEN
      --> Apenas gerar alerta
      pc_gerar_alerta_pessoa(pr_cdcooper => pr_craptfc.cdcooper
                            ,pr_nrdconta => pr_craptfc.nrdconta
                            ,pr_idseqttl => pr_craptfc.idseqttl
                            ,pr_nmtabela => 'CRATFC'
                            ,pr_dsalerta => vr_dscritic);

    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_craptfc: '||SQLERRM;
  END pc_craptfc;

  -- Rotina para atualizacao da tabela de bens (CRAPBEM)
  PROCEDURE pc_crapbem(pr_crapbem     IN crapbem%ROWTYPE            --> Tabela de bem atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2) IS               --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pc_crapbem
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para atualizacao da tabela de bens (CRAPBEM)
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    -- Buscar dados do bem
    CURSOR cr_bem(pr_idpessoa   tbcadast_pessoa.idpessoa%TYPE,
                  pr_nrseq_bem  tbcadast_pessoa_bem.nrseq_bem%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_bem
       WHERE idpessoa   = pr_idpessoa
         AND nrseq_bem  = pr_nrseq_bem;
    rw_bem cr_bem%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE; -- Identificador de pessoa
    vr_pessoa_bem      tbcadast_pessoa_bem%ROWTYPE;   -- Registro de bem
  BEGIN

    -- Se nao for informado o IDPESSOA, deve-se buscar
    IF pr_idpessoa IS NULL THEN
      -- Busca o ID PESSOA do endereco
      vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapbem.cdcooper,
                                     pr_nrdconta => pr_crapbem.nrdconta,
                                     pr_idseqttl => pr_crapbem.idseqttl);
      IF vr_idpessoa IS NULL THEN
        vr_dscritic := 'Nao encontrado PESSOA para alteracao do bem';
        RAISE vr_exc_saida;
      END IF;
    ELSE
      vr_idpessoa := pr_idpessoa;
    END IF;

    -- Busca os dados do bem
    OPEN cr_bem( pr_idpessoa  => vr_idpessoa,
                 pr_nrseq_bem => pr_crapbem.idseqbem);

    FETCH cr_bem INTO rw_bem;
    CLOSE cr_bem;

    -- Se for uma exclusao
    IF pr_tpoperacao = 3 THEN
      -- Se encontrou registro na busca
      IF rw_bem.nrseq_bem IS NOT NULL THEN
        -- Efetua a exclusao do registro
        cada0010.pc_exclui_pessoa_bem  ( pr_idpessoa     => vr_idpessoa,
                                         pr_nrseq_bem    => rw_bem.nrseq_bem,
                                         pr_cdoperad_altera => pr_cdoperad,
                                         pr_cdcritic     => vr_cdcritic,
                                         pr_dscritic     => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    ELSE -- Se for alteracao ou inclusao

      --> Carregar informações existentes, para garantir que informações
      --> que não existam nesta estrutura sejam perdidas.
      vr_pessoa_bem         := rw_bem;

      -- Utilizar a sequencia que ja existe da alteracao. Se for inclusao sera vazio
      vr_pessoa_bem.nrseq_bem         := nvl(rw_bem.nrseq_bem,pr_crapbem.idseqbem);

      -- Popula os campos para inserir o registro
      vr_pessoa_bem.idpessoa                := vr_idpessoa;


      vr_pessoa_bem.dsbem                   := pr_crapbem.dsrelbem;
      vr_pessoa_bem.pebem                   := greatest(pr_crapbem.persemon,0);
      vr_pessoa_bem.qtparcela_bem           := pr_crapbem.qtprebem;
      vr_pessoa_bem.vlbem                   := pr_crapbem.vlrdobem;
      vr_pessoa_bem.vlparcela_bem           := pr_crapbem.vlprebem;
      vr_pessoa_bem.dtalteracao             := pr_crapbem.dtaltbem;

      vr_pessoa_bem.cdoperad_altera         := pr_cdoperad;

      -- Efetua a inclusao
      cada0010.pc_cadast_pessoa_bem (pr_pessoa_bem => vr_pessoa_bem
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;

	EXCEPTION
    WHEN vr_exc_saida THEN
      --> Apenas gerar alerta
      pc_gerar_alerta_pessoa(pr_cdcooper => pr_crapbem.cdcooper
                            ,pr_nrdconta => pr_crapbem.nrdconta
                            ,pr_idseqttl => pr_crapbem.idseqttl
                            ,pr_nmtabela => 'CRAPBEM'
                            ,pr_dsalerta => vr_dscritic);

    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_crapbem: '||SQLERRM;
  END pc_crapbem;

  -- Rotina para atualizacao da tabela de empresa participacao societaria (CRAPEPA)
  PROCEDURE pc_crapepa(pr_crapepa     IN crapepa%ROWTYPE            --> Tabela de empresa participacao societaria atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2) IS               --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pc_crapepa
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para atualizacao da tabela de empresa participacao societaria (CRAPEPA)
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    -- Buscar dados do empresa participacao societaria
    CURSOR cr_juridica_ptp( pr_idpessoa      tbcadast_pessoa.idpessoa%TYPE,
                            pr_idpessoa_par  tbcadast_pessoa_juridica_ptp.idpessoa_participacao%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_juridica_ptp ptp
       WHERE ptp.idpessoa              = pr_idpessoa
         AND ptp.idpessoa_participacao = pr_idpessoa_par;
    rw_juridica_ptp cr_juridica_ptp%ROWTYPE;

    rw_pessoa_par cr_pessoa%ROWTYPE;
    rw_crapass    cr_crapass%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE;           -- Identificador de pessoa
    vr_pessoa_ptp      tbcadast_pessoa_juridica_ptp%ROWTYPE;    -- Registro de bem
    vr_pessoa          vwcadast_pessoa_juridica%ROWTYPE;        -- Registro de pessoa juridica
  BEGIN

    -- Se nao for informado o IDPESSOA, deve-se buscar
    IF pr_idpessoa IS NULL THEN
      -- Busca o ID PESSOA do endereco
      vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapepa.cdcooper,
                                     pr_nrdconta => pr_crapepa.nrdconta,
                                     pr_idseqttl => 1);
      IF vr_idpessoa IS NULL THEN
        vr_dscritic := 'Nao encontrado PESSOA para alteracao da participação societaria';
        RAISE vr_exc_saida;
      END IF;
    ELSE
      vr_idpessoa := pr_idpessoa;
    END IF;


    -- Se a empresa participante possui conta, busca os dados da conta dela
    IF pr_crapepa.nrctasoc > 0 THEN
      rw_crapass := NULL;
      OPEN cr_crapass( pr_cdcooper => pr_crapepa.cdcooper,
                       pr_nrdconta => pr_crapepa.nrctasoc);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_dscritic := 'Nao encontrado a conta da empresa participante';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapass;

      -- Verifica se esta empresa ja possui cadastro de pessoa
      rw_pessoa_par := NULL;
      OPEN cr_pessoa(pr_nrcpfcgc => rw_crapass.nrcpfcgc);
      FETCH cr_pessoa INTO rw_pessoa_par;
      -- Se nao existir pessoa cadastrada, deve-se efetuar o cadastro
      IF cr_pessoa%NOTFOUND THEN
        CLOSE cr_pessoa;
        -- Efetua a inclusao de pessoa
        cada0011.pc_insere_pessoa_crapass(pr_cdcooper => pr_crapepa.cdcooper,
                                          pr_nrdconta => pr_crapepa.nrctasoc,
                                          pr_idseqttl => 1,
                                          pr_cdoperad => pr_cdoperad,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
        -- Verifica se deu erro
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Busca a pessoa que foi cadastrada
        rw_pessoa_par := NULL;
        OPEN cr_pessoa(pr_nrcpfcgc => rw_crapass.nrcpfcgc);
        FETCH cr_pessoa INTO rw_pessoa_par;
        CLOSE cr_pessoa;

      ELSE
        CLOSE cr_pessoa;
      END IF;

    ELSE

      -- Verifica se a empresa participante ja possui cadastro de pessoa
      rw_pessoa_par := NULL;
      OPEN cr_pessoa(pr_nrcpfcgc => pr_crapepa.nrdocsoc);
      FETCH cr_pessoa INTO rw_pessoa_par;
      -- Se nao existir pessoa cadastrada, deve-se efetuar o cadastro
      IF cr_pessoa%NOTFOUND THEN
        CLOSE cr_pessoa;
        -- Efetua a inclusao de pessoa
        vr_pessoa := NULL;
        vr_pessoa.nrcnpj := pr_crapepa.nrdocsoc;
        vr_pessoa.cdoperad_altera     := pr_cdoperad;
        vr_pessoa.tpcadastro          := 1; -- Prospect
        vr_pessoa.tppessoa            := 2; -- Juridico
        vr_pessoa.nmfantasia           := pr_crapepa.nmfansia;
        vr_pessoa.nrinscricao_estadual := pr_crapepa.nrinsest;
        IF nvl(pr_crapepa.natjurid,0) > 0 THEN
          vr_pessoa.cdnatureza_juridica  := pr_crapepa.natjurid;
        END IF;
        vr_pessoa.dtinicio_atividade   := pr_crapepa.dtiniatv;
        vr_pessoa.qtfilial             := pr_crapepa.qtfilial;
        vr_pessoa.qtfuncionario        := pr_crapepa.qtfuncio;
        vr_pessoa.dssite               := pr_crapepa.dsendweb;
        vr_pessoa.cdsetor_economico    := pr_crapepa.cdseteco;
        vr_pessoa.cdramo_atividade     := pr_crapepa.cdrmativ;
        vr_pessoa.nmpessoa             := pr_crapepa.nmprimtl;

        -- Insere o Cadastro de pessoa fisica
        cada0010.pc_cadast_pessoa_juridica(pr_pessoa_juridica => vr_pessoa,
                                           pr_cdcritic        => vr_cdcritic,
                                           pr_dscritic        => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Atualiza o IDPESSOA na variavel de uso
        rw_pessoa_par.idpessoa := vr_pessoa.idpessoa;
      ELSE
        CLOSE cr_pessoa;
      END IF;
    END IF;


    -- Busca os dados empresa participacao societaria
    OPEN cr_juridica_ptp( pr_idpessoa     => vr_idpessoa,
                          pr_idpessoa_par => rw_pessoa_par.idpessoa);

    FETCH cr_juridica_ptp INTO rw_juridica_ptp;
    CLOSE cr_juridica_ptp;

    -- Se for uma exclusao
    IF pr_tpoperacao = 3 THEN
      -- Se encontrou registro na busca
      IF rw_juridica_ptp.nrseq_participacao IS NOT NULL THEN
        -- Efetua a exclusao do registro
        cada0010.pc_exclui_pessoa_juridica_ptp ( pr_idpessoa           => vr_idpessoa,
                                                 pr_nrseq_participacao => rw_juridica_ptp.nrseq_participacao,
                                                 pr_cdoperad_altera    => pr_cdoperad,
                                                 pr_cdcritic           => vr_cdcritic,
                                                 pr_dscritic           => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    ELSE -- Se for alteracao ou inclusao

      --> Carregar informações existentes, para garantir que informações
      --> que não existam nesta estrutura sejam perdidas.
      vr_pessoa_ptp         := rw_juridica_ptp;

      -- Utilizar a sequencia que ja existe da alteracao. Se for inclusao sera vazio
      vr_pessoa_ptp.nrseq_participacao         := rw_juridica_ptp.nrseq_participacao;

      -- Popula os campos para inserir o registro
      vr_pessoa_ptp.idpessoa                   := vr_idpessoa;

      vr_pessoa_ptp.idpessoa_participacao      := rw_pessoa_par.idpessoa;
      vr_pessoa_ptp.persocio                   := pr_crapepa.persocio;
      vr_pessoa_ptp.dtadmissao                 := pr_crapepa.dtadmiss;

      vr_pessoa_ptp.cdoperad_altera         := pr_cdoperad;

      -- Efetua a inclusao
      cada0010.pc_cadast_pessoa_juridica_ptp
                                    (pr_pessoa_juridica_ptp => vr_pessoa_ptp
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;

	EXCEPTION
    WHEN vr_exc_saida THEN
      --> Apenas gerar alerta
      pc_gerar_alerta_pessoa(pr_cdcooper => pr_crapepa.cdcooper
                            ,pr_nrdconta => pr_crapepa.nrdconta
                            ,pr_idseqttl => 1
                            ,pr_nmtabela => 'CRAPEPA'
                            ,pr_dsalerta => vr_dscritic);

    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_crapepa: '||SQLERRM;
  END pc_crapepa;

  -- Rotina para atualizacao da tabela de responsavel legal (CRAPCRL)
  PROCEDURE pc_crapcrl(pr_crapcrl     IN crapcrl%ROWTYPE            --> Tabela de responsavel legal atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2) IS               --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pc_crapcrl
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para atualizacao da tabela de responsavel legal(CRAPCRL)
    --
    --  Alteração : 31/01/2018 - Ajustes para fechar cursores que nao haviam sido fechados corretamente.
    --                           PRJ339 - CRM(Odirlei-AMcom)
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    -- Buscar dados do respponsavel legal
    CURSOR cr_fisica_resp( pr_idpessoa       tbcadast_pessoa.idpessoa%TYPE,
                           pr_idpessoa_resp  tbcadast_pessoa_fisica_resp.idpessoa_resp_legal%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_fisica_resp res
       WHERE res.idpessoa            = pr_idpessoa
         AND res.idpessoa_resp_legal = pr_idpessoa_resp;
    rw_fisica_resp cr_fisica_resp%ROWTYPE;

    -- Verificar se existe a pessoa fisica
    CURSOR cr_pessoa_fisica(pr_nrcpf vwcadast_pessoa_fisica.nrcpf%TYPE) IS
      SELECT *
        FROM vwcadast_pessoa_fisica
       WHERE nrcpf   = pr_nrcpf;
    rw_pessoa_fisica  cr_pessoa_fisica%ROWTYPE;

    -- Buscar dados da pessoa de relacao
    CURSOR cr_pessoa_rel ( pr_idpessoa   tbcadast_pessoa.idpessoa%TYPE,
                           pr_tprelacao  tbcadast_pessoa_relacao.tprelacao%TYPE) IS
      SELECT rel.nrseq_relacao,
             rel.idpessoa_relacao,
             pes.nmpessoa
        FROM tbcadast_pessoa_relacao rel,
             tbcadast_pessoa pes
       WHERE rel.idpessoa         = pr_idpessoa
         AND rel.tprelacao        = pr_tprelacao
         AND rel.idpessoa_relacao = pes.idpessoa;
    rw_pessoa_rel cr_pessoa_rel%ROWTYPE;

    -- Verificar se existe endereco
    CURSOR cr_pessoa_endereco(pr_idpessoa   tbcadast_pessoa_endereco.idpessoa%TYPE,
                              pr_tpendereco tbcadast_pessoa_endereco.tpendereco%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_endereco enc
       WHERE enc.idpessoa   = pr_idpessoa
         AND enc.tpendereco = pr_tpendereco;
    rw_pessoa_endereco cr_pessoa_endereco%ROWTYPE;


    rw_pessoa_resp cr_pessoa%ROWTYPE;
    rw_crapass     cr_crapass%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE;           -- Identificador de pessoa
    vr_pessoa_resp     tbcadast_pessoa_fisica_resp%ROWTYPE;     -- Registro de responsavel legal
    vr_pessoa          vwcadast_pessoa_fisica%ROWTYPE;          -- Registro de pessoa
    vr_pessoa_endereco tbcadast_pessoa_endereco%ROWTYPE;        -- Registro de endereço
  BEGIN

    -- Se nao for informado o IDPESSOA, deve-se buscar
    IF pr_idpessoa IS NULL THEN
      -- Busca o ID PESSOA do endereco
      vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapcrl.cdcooper,
                                     pr_nrdconta => pr_crapcrl.nrctamen,
                                     pr_idseqttl => pr_crapcrl.idseqmen);
      IF vr_idpessoa IS NULL THEN
        vr_dscritic := 'Nao encontrado PESSOA para alteracao do responsavel legal';
        RAISE vr_exc_saida;
      END IF;
    ELSE
      vr_idpessoa := pr_idpessoa;
    END IF;

    -- Se for uma exclusao
    IF pr_tpoperacao = 3 THEN

      IF pr_crapcrl.nrdconta > 0 THEN
        rw_crapass := NULL;
        OPEN cr_crapass( pr_cdcooper => pr_crapcrl.cdcooper,
                         pr_nrdconta => pr_crapcrl.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_dscritic := 'Nao encontrado a conta do responsavel legal';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crapass;
        END IF;

        -- Verifica se este responsavel ja possui cadastro de pessoa
        rw_pessoa_resp := NULL;
        OPEN cr_pessoa(pr_nrcpfcgc => rw_crapass.nrcpfcgc);
        FETCH cr_pessoa INTO rw_pessoa_resp;
        -- Se nao existir pessoa cadastrada, deve-se efetuar o cadastro
        IF cr_pessoa%NOTFOUND THEN
          CLOSE cr_pessoa;
        ELSE 
          CLOSE cr_pessoa;
        END IF;

      ELSE

        -- Verifica se este responsavel ja possui cadastro de pessoa
        rw_pessoa_resp := NULL;
        OPEN cr_pessoa(pr_nrcpfcgc => pr_crapcrl.nrcpfcgc);
        FETCH cr_pessoa INTO rw_pessoa_resp;
        -- Se nao existir pessoa cadastrada, deve-se efetuar o cadastro
        IF cr_pessoa%NOTFOUND THEN
          CLOSE cr_pessoa;
        ELSE
          CLOSE cr_pessoa;
        END IF;
      END IF;

      --> se localizou pessoa, deve excluir registro
      IF nvl(rw_pessoa_resp.idpessoa,0) > 0  THEN

        -- Busca os dados responsavel legal
        rw_fisica_resp := NULL;
        OPEN cr_fisica_resp( pr_idpessoa      => vr_idpessoa,
                             pr_idpessoa_resp => rw_pessoa_resp.idpessoa);

        FETCH cr_fisica_resp INTO rw_fisica_resp;
        CLOSE cr_fisica_resp;

        -- Se encontrou registro na busca
        IF rw_fisica_resp.nrseq_resp_legal IS NOT NULL THEN
          -- Efetua a exclusao do registro
          cada0010.pc_exclui_pessoa_fisica_resp ( pr_idpessoa           => vr_idpessoa,
                                                  pr_nrseq_resp_legal   => rw_fisica_resp.nrseq_resp_legal,
                                                  pr_cdoperad_altera    => pr_cdoperad,
                                                  pr_cdcritic           => vr_cdcritic,
                                                  pr_dscritic           => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END IF;

    ELSE -- Se for alteracao ou inclusao

      -- Se o responsavel legal possui conta, busca os dados da conta dele
      IF pr_crapcrl.nrdconta > 0 THEN
        rw_crapass := NULL;
        OPEN cr_crapass( pr_cdcooper => pr_crapcrl.cdcooper,
                         pr_nrdconta => pr_crapcrl.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_dscritic := 'Nao encontrado a conta do responsavel legal';
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_crapass;

        -- Verifica se este responsavel ja possui cadastro de pessoa
        rw_pessoa_resp := NULL;
        OPEN cr_pessoa(pr_nrcpfcgc => rw_crapass.nrcpfcgc);
        FETCH cr_pessoa INTO rw_pessoa_resp;
        -- Se nao existir pessoa cadastrada, deve-se efetuar o cadastro
        IF cr_pessoa%NOTFOUND THEN
          CLOSE cr_pessoa;
          -- Efetua a inclusao de pessoa
          cada0011.pc_insere_pessoa_crapass(pr_cdcooper => pr_crapcrl.cdcooper,
                                            pr_nrdconta => pr_crapcrl.nrdconta,
                                            pr_idseqttl => 1,
                                            pr_cdoperad => pr_cdoperad,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
          -- Verifica se deu erro
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Busca a pessoa que foi cadastrada
          rw_pessoa_resp := NULL;
          OPEN cr_pessoa(pr_nrcpfcgc => rw_crapass.nrcpfcgc);
          FETCH cr_pessoa INTO rw_pessoa_resp;

        END IF;
        CLOSE cr_pessoa;

      ELSE

        -- Verifica se este responsavel ja possui cadastro de pessoa
        rw_pessoa_resp := NULL;
        OPEN cr_pessoa_fisica(pr_nrcpf => pr_crapcrl.nrcpfcgc);
        FETCH cr_pessoa_fisica INTO rw_pessoa_fisica;
        CLOSE cr_pessoa_fisica;

        -- Efetua a inclusao de pessoa
        vr_pessoa := rw_pessoa_fisica;
        vr_pessoa.nrcpf                := pr_crapcrl.nrcpfcgc;
        vr_pessoa.nmpessoa             := pr_crapcrl.nmrespon;
        vr_pessoa.idorgao_expedidor    := pr_crapcrl.idorgexp;
        vr_pessoa.cduf_orgao_expedidor := TRIM(pr_crapcrl.cdufiden);
        vr_pessoa.dtemissao_documento  := pr_crapcrl.dtemiden;
        vr_pessoa.dtnascimento         := pr_crapcrl.dtnascin;
        vr_pessoa.tpsexo               := pr_crapcrl.cddosexo;
        IF nvl(pr_crapcrl.cdestciv,0) > 0 THEN
          vr_pessoa.cdestado_civil     := pr_crapcrl.cdestciv;
        END IF;
        vr_pessoa.nrdocumento          := pr_crapcrl.nridenti;
        vr_pessoa.tpdocumento          := pr_crapcrl.tpdeiden;
        IF nvl(pr_crapcrl.cdnacion,0) > 0 THEN
          vr_pessoa.cdnacionalidade    := pr_crapcrl.cdnacion;
        END IF;
        vr_pessoa.tppessoa            := nvl(vr_pessoa.tppessoa  ,1); -- Fisica
        vr_pessoa.tpcadastro          := nvl(vr_pessoa.tpcadastro,2); -- Basico
        vr_pessoa.cdoperad_altera     := pr_cdoperad;

        -- Trata o municipio
        IF TRIM(pr_crapcrl.dsnatura) IS NOT NULL THEN
          -- Busca o ID do municipio
          CADA0015.pc_trata_municipio
                            (pr_dscidade => TRIM(pr_crapcrl.dsnatura),
                             pr_cdestado => NULL,
                             pr_idcidade => vr_pessoa.cdnaturalidade,
                             pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Insere o Cadastro de pessoa fisica
        cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => vr_pessoa,
                                         pr_cdcritic      => vr_cdcritic,
                                         pr_dscritic      => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Atualiza o IDPESSOA na variavel de uso
        rw_pessoa_resp.idpessoa := vr_pessoa.idpessoa;

        -- Buscar dados da pessoa de relacao
        OPEN cr_pessoa_rel ( pr_idpessoa  => vr_pessoa.idpessoa,
                             pr_tprelacao => 3); -- Pai
        FETCH cr_pessoa_rel INTO rw_pessoa_rel;
        CLOSE cr_pessoa_rel;

        --> se possia inf do pai, porém agora o campo esta vazio, deve deletar
        IF rw_pessoa_rel.nrseq_relacao > 0 AND
           ( TRIM(pr_crapcrl.nmpairsp) IS NULL OR
             pr_crapcrl.nmpairsp <> rw_pessoa_rel.nmpessoa ) THEN
          -- Efetua a exclusao do registro
          cada0010.pc_exclui_pessoa_relacao ( pr_idpessoa           => vr_pessoa.idpessoa,
                                              pr_nrseq_relacao      => rw_pessoa_rel.nrseq_relacao,
                                              pr_cdoperad_altera    => pr_cdoperad,
                                              pr_cdcritic           => vr_cdcritic,
                                              pr_dscritic           => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- se possui nome do pai, e é diferente do atual
        IF TRIM(pr_crapcrl.nmpairsp) IS NOT NULL AND
           nvl(pr_crapcrl.nmpairsp,' ') <> nvl(rw_pessoa_rel.nmpessoa,' ') THEN

          CADA0011.pc_trata_pessoa_relacao( pr_idpessoa => vr_pessoa.idpessoa,
                                            pr_tprelacao=> 3, -- Pai
                                            pr_nmpessoa => pr_crapcrl.nmpairsp,
                                            pr_cdoperad => pr_cdoperad,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Buscar dados da pessoa de relacao
        rw_pessoa_rel := NULL;
        OPEN cr_pessoa_rel ( pr_idpessoa  => vr_pessoa.idpessoa,
                             pr_tprelacao => 4); -- Mae
        FETCH cr_pessoa_rel INTO rw_pessoa_rel;
        CLOSE cr_pessoa_rel;

        --> se possia inf do mae, porém agora o campo esta vazio, deve deletar
        IF rw_pessoa_rel.nrseq_relacao > 0 AND
           ( TRIM(pr_crapcrl.nmmaersp) IS  NULL OR
             pr_crapcrl.nmmaersp <> rw_pessoa_rel.nmpessoa ) THEN
          -- Efetua a exclusao do registro
          cada0010.pc_exclui_pessoa_relacao ( pr_idpessoa           => vr_pessoa.idpessoa,
                                              pr_nrseq_relacao      => rw_pessoa_rel.nrseq_relacao,
                                              pr_cdoperad_altera    => pr_cdoperad,
                                              pr_cdcritic           => vr_cdcritic,
                                              pr_dscritic           => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- se possui nome do mae, e é diferente do atual
        IF TRIM(pr_crapcrl.nmmaersp) IS NOT NULL AND
           nvl(pr_crapcrl.nmmaersp,' ') <> nvl(rw_pessoa_rel.nmpessoa,' ') THEN

          CADA0011.pc_trata_pessoa_relacao( pr_idpessoa => vr_pessoa.idpessoa,
                                            pr_tprelacao=> 4, -- Mae
                                            pr_nmpessoa => pr_crapcrl.nmmaersp,
                                            pr_cdoperad => pr_cdoperad,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Efetua a tratativa de endereco
        -- Verificar se existe endereco
        OPEN cr_pessoa_endereco(pr_idpessoa   => vr_pessoa.idpessoa,
                                pr_tpendereco => 10); --Residencial
        FETCH cr_pessoa_endereco INTO rw_pessoa_endereco;
        CLOSE cr_pessoa_endereco;

        vr_pessoa_endereco                 := rw_pessoa_endereco;
        vr_pessoa_endereco.idpessoa        := vr_pessoa.idpessoa;
        vr_pessoa_endereco.tpendereco      := 10; --Residencial
        vr_pessoa_endereco.nrcep           := pr_crapcrl.cdcepres;
        vr_pessoa_endereco.nmlogradouro    := pr_crapcrl.dsendres;
        vr_pessoa_endereco.nrlogradouro    := pr_crapcrl.nrendres;
        vr_pessoa_endereco.dscomplemento   := pr_crapcrl.dscomres;
        vr_pessoa_endereco.nmbairro        := pr_crapcrl.dsbaires;
        vr_pessoa_endereco.cdoperad_altera := pr_cdoperad;

        -- Trata o municipio
        IF TRIM(pr_crapcrl.dscidres) IS NOT NULL THEN
          -- Busca o ID do municipio
          CADA0015.pc_trata_municipio
                            (pr_dscidade => TRIM(pr_crapcrl.dscidres),
                             pr_cdestado => TRIM(pr_crapcrl.dsdufres),
                             pr_idcidade => vr_pessoa_endereco.idcidade,
                             pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Efetua a inclusao
        cada0010.pc_cadast_pessoa_endereco(pr_pessoa_endereco => vr_pessoa_endereco
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF; -- Fim da verificacao se o responsavel legal ja possui cadastro como pessoa         ;

      -- Busca os dados responsavel legal
      OPEN cr_fisica_resp( pr_idpessoa      => vr_idpessoa,
                           pr_idpessoa_resp => rw_pessoa_resp.idpessoa);

      FETCH cr_fisica_resp INTO rw_fisica_resp;
      CLOSE cr_fisica_resp;

      --> Carregar informações existentes, para garantir que informações
      --> que não existam nesta estrutura sejam perdidas.
      vr_pessoa_resp     := rw_fisica_resp;

      -- Utilizar a sequencia que ja existe da alteracao. Se for inclusao sera vazio
      vr_pessoa_resp.nrseq_resp_legal     := rw_fisica_resp.nrseq_resp_legal;

      -- Popula os campos para inserir o registro
      vr_pessoa_resp.idpessoa               := vr_idpessoa;

      vr_pessoa_resp.idpessoa_resp_legal    := rw_pessoa_resp.idpessoa;
      vr_pessoa_resp.cdrelacionamento       := pr_crapcrl.cdrlcrsp;

      vr_pessoa_resp.cdoperad_altera        := pr_cdoperad;

      -- Efetua a inclusao
      cada0010.pc_cadast_pessoa_fisica_resp (pr_pessoa_fisica_resp => vr_pessoa_resp
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;

	EXCEPTION
    WHEN vr_exc_saida THEN
      --> Apenas gerar alerta
      pc_gerar_alerta_pessoa(pr_cdcooper => pr_crapcrl.cdcooper
                            ,pr_nrdconta => pr_crapcrl.nrctamen
                            ,pr_idseqttl => pr_crapcrl.idseqmen
                            ,pr_nmtabela => 'CRAPCRL'
                            ,pr_dsalerta => vr_dscritic);

    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_crapcrl: '||SQLERRM;
  END pc_crapcrl;

  -- Rotina para atualizacao da tabela de dependentes(CRAPDEP)
  PROCEDURE pc_crapdep(pr_crapdep     IN crapdep%ROWTYPE            --> Tabela de responsavel legal atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2) IS               --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pc_crapdep
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para atualizacao da tabela de dependentes(CRAPDEP)
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    -- Buscar dados do dependente
    CURSOR cr_fisica_dep( pr_idpessoa  tbcadast_pessoa.idpessoa%TYPE,
                          pr_nmpessoa  tbcadast_pessoa.nmpessoa%TYPE) IS
      SELECT dep.*
        FROM tbcadast_pessoa_fisica_dep dep,
             tbcadast_pessoa pes
       WHERE dep.idpessoa            = pr_idpessoa
         AND dep.idpessoa_dependente = pes.idpessoa
         AND pes.nmpessoa            = pr_nmpessoa;
    rw_fisica_dep cr_fisica_dep%ROWTYPE;

    rw_pessoa_dep  cr_pessoa_fis%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_idpessoa          tbcadast_pessoa.idpessoa%TYPE;           -- Identificador de pessoa
    vr_pessoa_fisica_dep tbcadast_pessoa_fisica_dep%ROWTYPE;      -- Registro de dependete
    vr_pessoa            vwcadast_pessoa_fisica%ROWTYPE;          -- Registro de pessoa

  BEGIN

    -- Se nao for informado o IDPESSOA, deve-se buscar
    IF pr_idpessoa IS NULL THEN
      -- Busca o ID PESSOA do dependente
      vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapdep.cdcooper,
                                     pr_nrdconta => pr_crapdep.nrdconta,
                                     pr_idseqttl => pr_crapdep.idseqdep);
      IF vr_idpessoa IS NULL THEN
        vr_dscritic := 'Nao encontrado PESSOA para alteracao do dependente';
        RAISE vr_exc_saida;
      END IF;
    ELSE
      vr_idpessoa := pr_idpessoa;
    END IF;

    -- Busca os dados do dependente
    OPEN cr_fisica_dep(pr_idpessoa  => vr_idpessoa,
                       pr_nmpessoa  => pr_crapdep.nmdepend);

    FETCH cr_fisica_dep INTO rw_fisica_dep;
    CLOSE cr_fisica_dep;

    -- Se for uma exclusao
    IF pr_tpoperacao = 3 THEN
      -- Se encontrou registro na busca
      IF rw_fisica_dep.nrseq_dependente IS NOT NULL THEN
        -- Efetua a exclusao do registro
        cada0010.pc_exclui_pessoa_fisica_dep( pr_idpessoa        => vr_idpessoa,
                                              pr_nrseq_dependente  => rw_fisica_dep.nrseq_dependente,
                                              pr_cdoperad_altera => pr_cdoperad,
                                              pr_cdcritic        => vr_cdcritic,
                                              pr_dscritic        => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    ELSE -- Se for alteracao ou inclusao

      -- buscar dados pessoa fisica
      rw_pessoa_dep := NULL;
      OPEN cr_pessoa_fis(pr_idpessoa => rw_fisica_dep.idpessoa_dependente);
      FETCH cr_pessoa_fis INTO rw_pessoa_dep;
      CLOSE cr_pessoa_fis;

      -- se nao encontrou a pessoa ou o nome é diferente, deve criar a pessoa
      IF nvl(rw_pessoa_dep.nmpessoa,' ') <> nvl(pr_crapdep.nmdepend,' ') THEN
        -- Cria o prospect de dependente
        vr_pessoa := NULL;
      ELSE
        --> se é o mesmo nome carrega dados
        vr_pessoa := rw_pessoa_dep;
      END IF;

      vr_pessoa.cdoperad_altera     := pr_cdoperad;
      vr_pessoa.tpcadastro          := nvl(vr_pessoa.tpcadastro,1); -- Prospect
      vr_pessoa.tppessoa            := nvl(vr_pessoa.tppessoa  ,1); -- Fisico
      vr_pessoa.nmpessoa            := pr_crapdep.nmdepend;
      vr_pessoa.dtnascimento        := pr_crapdep.dtnascto;

      -- Insere o Cadastro de pessoa fisica
      cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => vr_pessoa,
                                       pr_cdcritic      => vr_cdcritic,
                                       pr_dscritic      => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      --> Carregar informações existentes, para garantir que informações
      --> que não existam nesta estrutura sejam perdidas.
      vr_pessoa_fisica_dep := rw_fisica_dep;

      -- Atualiza a pessoa dependente
      vr_pessoa_fisica_dep.idpessoa_dependente := vr_pessoa.idpessoa;
      vr_pessoa_fisica_dep.idpessoa            := vr_idpessoa;
      vr_pessoa_fisica_dep.tpdependente        := pr_crapdep.tpdepend;
      vr_pessoa_fisica_dep.cdoperad_altera     := pr_cdoperad;

      -- Efetua a inclusao
      cada0010.pc_cadast_pessoa_fisica_dep(pr_pessoa_fisica_dep => vr_pessoa_fisica_dep
                                          ,pr_cdcritic          => vr_cdcritic
                                          ,pr_dscritic          => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;



	EXCEPTION
    WHEN vr_exc_saida THEN
      --> Apenas gerar alerta
      pc_gerar_alerta_pessoa(pr_cdcooper => pr_crapdep.cdcooper
                            ,pr_nrdconta => pr_crapdep.nrdconta
                            ,pr_idseqttl => 1
                            ,pr_nmtabela => 'CRAPDEP'
                            ,pr_dsalerta => vr_dscritic);

    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_crapdep: '||SQLERRM;
  END pc_crapdep;

  -- Rotina para cadastrar/atualizar pessoa conjuge
  PROCEDURE pc_pessoa_cje( pr_crapcje     IN crapcje%ROWTYPE                   --> Tabela de conjuge atual
                          ,pr_idpessoa    IN OUT tbcadast_pessoa.idpessoa%TYPE --> Identificador de pessoa
                          ,pr_cdoperad    IN crapope.cdoperad%TYPE             --> Operador que esta efetuando a operacao
                          ,pr_dscritic   OUT VARCHAR2) IS                      --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pc_pessoa_cje
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 06/09/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para cadastrar/atualizar pessoa conjuge
    --
    --  Alteração : 06/09/2018 - Ajustes nas rotinas envolvidas na unificação cadastral e CRM para
    --                           corrigir antigos e evitar futuros problemas. (INC002926 - Kelvin)
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------

    --> Retornar dados pessoa renda
    CURSOR cr_pessoa_renda (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_renda ren
       WHERE ren.idpessoa = pr_idpessoa;
    rw_pessoa_renda cr_pessoa_renda%ROWTYPE;

    --> Retornar dados pessoa pelo id
    CURSOR cr_pessoa_id (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;

    -- Cursor para verificar se existe a pessoa juridica
    CURSOR cr_pessoa_juridica(pr_nrcnpj vwcadast_pessoa_juridica.nrcnpj%TYPE) IS
      SELECT *
        FROM vwcadast_pessoa_juridica
       WHERE nrcnpj   = pr_nrcnpj;
    rw_pessoa_juridica  cr_pessoa_juridica%ROWTYPE;

    -- Verificar se existe a pessoa fisica
    CURSOR cr_pessoa_fisica(pr_nrcpf vwcadast_pessoa_fisica.nrcpf%TYPE) IS
      SELECT *
        FROM vwcadast_pessoa_fisica
       WHERE nrcpf   = pr_nrcpf;
    rw_pessoa_fisica  cr_pessoa_fisica%ROWTYPE;

    -- Cursor para verificar se existe telefone para o conjuge
    CURSOR cr_pessoa_telefone(pr_idpessoa   tbcadast_pessoa_telefone.idpessoa%TYPE,
                              pr_tptelefone tbcadast_pessoa_telefone.tptelefone%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_telefone
       WHERE idpessoa   = pr_idpessoa
         AND tptelefone = pr_tptelefone;
    rw_pessoa_telefone cr_pessoa_telefone%ROWTYPE;


    rw_pessoa_jur_fonte cr_pessoa_jur%ROWTYPE;
    rw_pessoa           cr_pessoa%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_pessoa_fis      vwcadast_pessoa_fisica%ROWTYPE;          -- Registro de pessoa
    vr_flcria_empresa  BOOLEAN;                                 -- Indicador se deve criar a empresa de trabalho do conjuge
    vr_nrddd           tbcadast_pessoa_telefone.nrddd%TYPE;     -- Numero do DDD
    vr_nrtelefone      tbcadast_pessoa_telefone.nrtelefone%TYPE;-- Numero do telefone
    vr_nrramal         tbcadast_pessoa_telefone.nrramal%TYPE;   -- Numero do Ramal

  BEGIN

    -- Se possuir conta
    IF pr_crapcje.nrctacje > 0 THEN
      -- Se nao existe a pessoa, deve-se criar
      IF nvl(pr_idpessoa,0) = 0 THEN

        -- Efetua a inclusao de pessoa
        cada0011.pc_insere_pessoa_crapass(pr_cdcooper => pr_crapcje.cdcooper,
                                          pr_nrdconta => pr_crapcje.nrctacje,
                                          pr_idseqttl => 1,
                                          pr_cdoperad => pr_cdoperad,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
        -- Verifica se deu erro
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Busca o ID PESSOA
        pr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapcje.cdcooper,
                                       pr_nrdconta => pr_crapcje.nrctacje,
                                       pr_idseqttl => 1);
        IF pr_idpessoa IS NULL THEN
          vr_dscritic := 'Nao encontrado pessoa Conjuge';
          RAISE vr_exc_erro;
        END IF;

      END IF;

    ELSE
      --> Validar dado
      IF nvl(pr_crapcje.nrcpfcjg,0) = 0 AND
         TRIM(pr_crapcje.nmconjug) IS NULL THEN
        vr_dscritic := 'Conjuge sem CPF e nome.';
        RAISE vr_exc_erro;

      ELSE

        --> Inserir/atualizar pessoa
        OPEN cr_pessoa_fis(pr_idpessoa => pr_idpessoa);
        FETCH cr_pessoa_fis INTO vr_pessoa_fis;
        CLOSE cr_pessoa_fis;

        IF nvl(pr_crapcje.nrcpfcjg,0) > 0 THEN
          vr_pessoa_fis.nrcpf                := pr_crapcje.nrcpfcjg;
        END IF;
        vr_pessoa_fis.tppessoa             := nvl(vr_pessoa_fis.tppessoa  ,1); -- Fisica
        vr_pessoa_fis.tpcadastro           := nvl(vr_pessoa_fis.tpcadastro,1); -- Prospect
        vr_pessoa_fis.nmpessoa             := pr_crapcje.nmconjug;
        vr_pessoa_fis.dtnascimento         := pr_crapcje.dtnasccj;
        vr_pessoa_fis.tpdocumento          := pr_crapcje.tpdoccje;
        vr_pessoa_fis.nrdocumento          := pr_crapcje.nrdoccje;
        IF pr_crapcje.idorgexp <> 0 THEN
          vr_pessoa_fis.idorgao_expedidor    := pr_crapcje.idorgexp;
        END IF;
        vr_pessoa_fis.cduf_orgao_expedidor := trim(pr_crapcje.cdufdcje);
        vr_pessoa_fis.dtemissao_documento  := pr_crapcje.dtemdcje;
        IF nvl(pr_crapcje.grescola,0) > 0 THEN
          vr_pessoa_fis.cdgrau_escolaridade  := pr_crapcje.grescola;
        END IF;
        vr_pessoa_fis.cdcurso_superior     := pr_crapcje.cdfrmttl;
        IF pr_crapcje.cdnatopc <> 0 THEN
          vr_pessoa_fis.cdnatureza_ocupacao  := pr_crapcje.cdnatopc;
        END IF;
        vr_pessoa_fis.dsprofissao          := pr_crapcje.dsproftl;
        vr_pessoa_fis.cdoperad_altera      := pr_cdoperad;

        -- Insere o Cadastro de pessoa fisica
        cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => vr_pessoa_fis,
                                         pr_cdcritic      => vr_cdcritic,
                                         pr_dscritic      => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        --> retornar idpessoa gerado
        pr_idpessoa := vr_pessoa_fis.idpessoa;

        -- Verifica se possui informacoes da renda do conjuge
        IF nvl(pr_crapcje.tpcttrab,0) <> 0 OR
           nvl(pr_crapcje.cdnvlcgo,0) <> 0 OR
           nvl(pr_crapcje.cdturnos,0) <> 0 OR
           pr_crapcje.dtadmemp IS NOT NULL OR
           nvl(pr_crapcje.vlsalari,0) <> 0 OR
           nvl(pr_crapcje.nrdocnpj,0) <> 0 OR
           TRIM(pr_crapcje.nmextemp) IS NOT NULL THEN

          --> Retornar dados pessoa renda
          OPEN cr_pessoa_renda (pr_idpessoa => pr_idpessoa);
          FETCH cr_pessoa_renda INTO rw_pessoa_renda;
          CLOSE cr_pessoa_renda;

          -- Se possuir CNPJ, verifica se esta cadastrado
          IF nvl(pr_crapcje.nrdocnpj,0) > 0 THEN

            -- Verifica se existe pessoa
            OPEN cr_pessoa(pr_nrcpfcgc => pr_crapcje.nrdocnpj);
            FETCH cr_pessoa INTO rw_pessoa;
            -- Se nao existir, tem que criar
            IF cr_pessoa%NOTFOUND THEN
              -- Atualiza o indicador para criar o CNPJ
              vr_flcria_empresa := TRUE;

            ELSE -- Se encontrou a pessoa juridica
              --> se o nome estiver diferente, é necessario atualizar pessoa
              IF substr(pr_crapcje.nmextemp,1,40) <> substr(rw_pessoa.nmpessoa,1,40) AND 
                 NVL(rw_pessoa.tpcadastro,4) NOT IN (3,4) THEN
                vr_flcria_empresa := TRUE;
              END IF;
              -- Atualiza o ID da pessoa juridica
              rw_pessoa_renda.idpessoa_fonte_renda := rw_pessoa.idpessoa;
            END IF;
            CLOSE cr_pessoa;

          ELSE

            -- Verifica se existe PJ
            OPEN cr_pessoa_id(pr_idpessoa => rw_pessoa_renda.idpessoa_fonte_renda);
            FETCH cr_pessoa_id INTO rw_pessoa;
            CLOSE cr_pessoa_id;

            IF substr(nvl(pr_crapcje.nmextemp,' '),1,40) <> substr(nvl(rw_pessoa.nmpessoa,' '),1,40) AND
               NVL(rw_pessoa.tpcadastro,4) NOT IN (3,4) THEN
              -- Atualiza o indicador para criar o CNPJ
              vr_flcria_empresa := TRUE;
            END IF;
          END IF;

          -- Se o indicador de criacao/atualizacao de empresa estiver ligado
          IF vr_flcria_empresa THEN
            -- Verifica se a empresa de trabalho eh um CPF ou CNPJ
            -- Se for um CPF
            IF nvl(pr_crapcje.nrdocnpj,0) > 0 AND
               SUBSTR(pr_crapcje.nrdocnpj,LENGTH(pr_crapcje.nrdocnpj)-1) <> gene0005.fn_retorna_digito_cnpj(pr_nrcalcul => SUBSTR(pr_crapcje.nrdocnpj,1,LENGTH(pr_crapcje.nrdocnpj)-2)) THEN

              rw_pessoa_fisica := NULL;
              OPEN cr_pessoa_fisica(pr_nrcpf => pr_crapcje.nrdocnpj);
              FETCH cr_pessoa_fisica INTO rw_pessoa_fisica;
              CLOSE cr_pessoa_fisica;

              -- Popula os dados de pessoa fisica
              rw_pessoa_fisica.nrcpf                := pr_crapcje.nrdocnpj;
              
              -- Feito a validacao abaixo para nao cortar o final do nome da pessoal
              IF substr(nvl(pr_crapcje.nmextemp,' '),1,40) <> substr(nvl(rw_pessoa_fisica.nmpessoa,' '),1,40) THEN
                rw_pessoa_fisica.nmpessoa             := pr_crapcje.nmextemp;
              END IF;
              
              rw_pessoa_fisica.tppessoa             := 1; -- Fisica
              rw_pessoa_fisica.tpcadastro           := nvl(rw_pessoa_fisica.tpcadastro,1); -- Prospect
              rw_pessoa_fisica.cdoperad_altera      := pr_cdoperad;
              -- Cria a pessoa fisica
              cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => rw_pessoa_fisica,
                                               pr_cdcritic      => vr_cdcritic,
                                               pr_dscritic      => vr_dscritic);
              IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
              -- Atualiza com o ID pessoa que foi criado
              rw_pessoa_renda.idpessoa_fonte_renda := rw_pessoa_fisica.idpessoa;

            ELSE -- Se for PJ
              rw_pessoa_juridica := NULL;
              OPEN cr_pessoa_juridica(pr_nrcnpj => pr_crapcje.nrdocnpj);
              FETCH cr_pessoa_juridica INTO rw_pessoa_juridica;
              CLOSE cr_pessoa_juridica;

              -- Popula os dados de pessoa juridica
              IF pr_crapcje.nrdocnpj <> 0 THEN
                rw_pessoa_juridica.nrcnpj               := pr_crapcje.nrdocnpj;
              ELSE
                  rw_pessoa_juridica.nrcnpj             := NULL;
              END IF;
              
              -- Feito a validacao abaixo para nao cortar o final do nome da pessoal
              IF substr(nvl(pr_crapcje.nmextemp,' '),1,40) <> substr(nvl(rw_pessoa_juridica.nmpessoa,' '),1,40) THEN
                rw_pessoa_juridica.nmpessoa             := pr_crapcje.nmextemp;
              END IF;
              
              rw_pessoa_juridica.tppessoa             := nvl(rw_pessoa_juridica.tppessoa,2);   -- Juridica
              rw_pessoa_juridica.tpcadastro           := nvl(rw_pessoa_juridica.tpcadastro,1); -- Prospect
              rw_pessoa_juridica.cdoperad_altera      := pr_cdoperad;
              -- Cria a pessoa juridica
              cada0010.pc_cadast_pessoa_juridica(pr_pessoa_juridica => rw_pessoa_juridica,
                                                 pr_cdcritic      => vr_cdcritic,
                                                 pr_dscritic      => vr_dscritic);
              IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
              -- Atualiza com o ID pessoa que foi criado
              rw_pessoa_renda.idpessoa_fonte_renda := rw_pessoa_juridica.idpessoa;
            END IF;
          END IF;

          -- Atualiza a tabela de renda
          rw_pessoa_renda.idpessoa            := pr_idpessoa;
          IF pr_crapcje.cdocpcje <> 0 THEN
            rw_pessoa_renda.cdocupacao        := pr_crapcje.cdocpcje;
          END IF;
          rw_pessoa_renda.tpcontrato_trabalho := pr_crapcje.tpcttrab;
          rw_pessoa_renda.cdnivel_cargo       := pr_crapcje.cdnvlcgo;
          rw_pessoa_renda.cdturno             := pr_crapcje.cdturnos;
          rw_pessoa_renda.dtadmissao          := pr_crapcje.dtadmemp;
          rw_pessoa_renda.vlrenda             := pr_crapcje.vlsalari;
          rw_pessoa_renda.cdoperad_altera     := pr_cdoperad;

          -- Cria/atualiza o registro de renda
          cada0010.pc_cadast_pessoa_renda(pr_pessoa_renda => rw_pessoa_renda,
                                          pr_cdcritic      => vr_cdcritic,
                                          pr_dscritic      => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

        END IF;

        -- Se possui telefone
        IF TRIM(pr_crapcje.nrfonemp) IS NOT NULL AND
           TRIM(pr_crapcje.nrfonemp) <> '0' THEN
          -- Estrutura o telefone
          CADA0011.pc_trata_telefone( pr_nrtelefone_org => pr_crapcje.nrfonemp,
                                      pr_nrramal_org    => pr_crapcje.nrramemp,
                                      pr_nrddd          => vr_nrddd,
                                      pr_nrtelefone     => vr_nrtelefone,
                                      pr_nrramal        => vr_nrramal,
                                      pr_dscritic       => vr_dscritic);

          -- Verifica se este telefone ja nao existe para a pessoa
          OPEN cr_pessoa_telefone(pr_idpessoa   => pr_idpessoa,
                                  pr_tptelefone => 3);
          FETCH cr_pessoa_telefone INTO rw_pessoa_telefone;
          CLOSE cr_pessoa_telefone;


          rw_pessoa_telefone.idpessoa   := pr_idpessoa;
          rw_pessoa_telefone.tptelefone := 3; -- Comercial
          rw_pessoa_telefone.nrddd      := vr_nrddd;
          rw_pessoa_telefone.nrtelefone := vr_nrtelefone;
          rw_pessoa_telefone.nrramal    := vr_nrramal;
          rw_pessoa_telefone.insituacao := 1; -- Ativo
          rw_pessoa_telefone.cdoperad_altera   := pr_cdoperad;
          rw_pessoa_telefone.tporigem_cadastro := nvl(rw_pessoa_telefone.tporigem_cadastro,2);

          -- Insere o telefone
          cada0010.pc_cadast_pessoa_telefone(pr_pessoa_telefone => rw_pessoa_telefone,
                                             pr_cdcritic        => vr_cdcritic,
                                             pr_dscritic        => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            IF cr_pessoa_telefone%ISOPEN THEN
              CLOSE cr_pessoa_telefone;
            END IF;
            RAISE vr_exc_erro;
          END IF;

        END IF; -- Fim da verificacao se possui telefone da empresa

      END IF;

    END IF;  --> pr_crapcje.nrctacje


	EXCEPTION
    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_pessoa_cje: '||SQLERRM;
  END pc_pessoa_cje;

  -- Rotina para atualizacao da tabela de conjuge (CRAPCJE)
  PROCEDURE pc_crapcje(pr_crapcje     IN crapcje%ROWTYPE            --> Tabela de conjuge atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2) IS               --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pc_crapcje
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para atualizacao da tabela de conjuge(CRAPCJE)
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    -- Buscar dados do conjuge
    CURSOR cr_pessoa_rel ( pr_idpessoa       tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_relacao rel
       WHERE rel.idpessoa         = pr_idpessoa
         AND rel.tprelacao        = 1; --> conjuge
    rw_pessoa_rel cr_pessoa_rel%ROWTYPE;

    rw_pessoa_cje  cr_pessoa_fis%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE;           -- Identificador de pessoa
    vr_idpessoa_cje    tbcadast_pessoa.idpessoa%TYPE;           -- Identificador de pessoa conjuge

  BEGIN

    -- Se nao for informado o IDPESSOA, deve-se buscar
    IF pr_idpessoa IS NULL THEN
      -- Busca o ID PESSOA
      vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapcje.cdcooper,
                                     pr_nrdconta => pr_crapcje.nrdconta,
                                     pr_idseqttl => pr_crapcje.idseqttl);
      IF vr_idpessoa IS NULL THEN
        vr_dscritic := 'Nao encontrado PESSOA para alteracao do conjuge';
        RAISE vr_exc_saida;
      END IF;
    ELSE
      vr_idpessoa := pr_idpessoa;
    END IF;

    -- Busca o ID PESSOA do conjuge
    vr_idpessoa_cje := fn_busca_pessoa(pr_cdcooper => pr_crapcje.cdcooper,
                                       pr_nrdconta => pr_crapcje.nrctacje,
                                       pr_idseqttl => 1,
                                       pr_nrcpfcgc => pr_crapcje.nrcpfcjg);


    -- Buscar dados do conjuge
    rw_pessoa_rel := NULL;
    OPEN cr_pessoa_rel( pr_idpessoa       => vr_idpessoa);
    FETCH cr_pessoa_rel INTO rw_pessoa_rel;
    CLOSE cr_pessoa_rel;

    -- Se for uma exclusao
    IF pr_tpoperacao = 3 THEN
      -- Se encontrou registro na busca
      IF rw_pessoa_rel.nrseq_relacao IS NOT NULL THEN
        -- Efetua a exclusao do registro
        cada0010.pc_exclui_pessoa_relacao ( pr_idpessoa           => vr_idpessoa,
                                            pr_nrseq_relacao      => rw_pessoa_rel.nrseq_relacao,
                                            pr_cdoperad_altera    => pr_cdoperad,
                                            pr_cdcritic           => vr_cdcritic,
                                            pr_dscritic           => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

    ELSE -- Se for alteracao ou inclusao

      --> Se nao localizou a pessoa e não possui numero de cpf
      --> tentar identificar se possui conjuge atual
      IF nvl(vr_idpessoa_cje,0) = 0 AND nvl(pr_crapcje.nrcpfcjg,0) = 0 THEN
        -- buscar dados pessoa fisica
        rw_pessoa_cje := NULL;
        OPEN cr_pessoa_fis(pr_idpessoa => rw_pessoa_rel.idpessoa_relacao);
        FETCH cr_pessoa_fis INTO rw_pessoa_cje;
        CLOSE cr_pessoa_fis;

        IF nvl(pr_crapcje.nmconjug,'XXX') <> nvl(rw_pessoa_cje.nmpessoa,'XXX') THEN
          vr_idpessoa_cje := NULL;
        ELSE
          vr_idpessoa_cje := rw_pessoa_rel.idpessoa_relacao;

          --> Tratativa para não levar para o cadastro unico os dados do cadastro temporario do conjuge
          --> gerado na tela matric
          IF nvl(pr_crapcje.nrcpfcjg,0) = 0 AND
             nvl(rw_pessoa_cje.nrcpf,0) <> nvl(pr_crapcje.nrcpfcjg,0) THEN
            vr_dscritic := 'Cadastro Temporario, não atualizar.';
            RAISE vr_exc_saida;
          END IF;

        END IF;


      END IF;


      -- Cadastrar/atualizar pessoa conjuge
      pc_pessoa_cje( pr_crapcje     => pr_crapcje              --> Tabela de conjuge atual
                    ,pr_idpessoa    => vr_idpessoa_cje         --> Identificador de pessoa
                    ,pr_cdoperad    => pr_cdoperad             --> Operador que esta efetuando a operacao
                    ,pr_dscritic    => vr_dscritic);           --> Retorno de Erro
      -- Verifica se deu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;


      -- Se a pessoa da relacao for diferente do que esta cadastrado
      IF nvl(vr_idpessoa_cje,0) <> vr_idpessoa THEN
        -- Atualiza os dados da relacao
        rw_pessoa_rel.idpessoa          := vr_idpessoa;
        rw_pessoa_rel.idpessoa_relacao  := vr_idpessoa_cje;
        rw_pessoa_rel.tprelacao         := 1; -- Conjuge
        rw_pessoa_rel.cdoperad_altera   := pr_cdoperad;

        -- Cria o relacionamento
        cada0010.pc_cadast_pessoa_relacao(pr_pessoa_relacao => rw_pessoa_rel,
                                          pr_cdcritic       => vr_cdcritic,
                                          pr_dscritic       => vr_dscritic);
        -- Verifica se deu erro
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    END IF;--> tpoperac

	EXCEPTION
    WHEN vr_exc_saida THEN
      --> Apenas gerar alerta
      pc_gerar_alerta_pessoa(pr_cdcooper => pr_crapcje.cdcooper
                            ,pr_nrdconta => pr_crapcje.nrdconta
                            ,pr_idseqttl => pr_crapcje.idseqttl
                            ,pr_nmtabela => 'CRAPCJE'
                            ,pr_dsalerta => vr_dscritic);

    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_crapcje: '||SQLERRM;
  END pc_crapcje;

  -- Rotina para cadastrar/atualizar pessoa de referencia
  PROCEDURE pc_pessoa_referencia ( pr_crapavt     IN crapavt%ROWTYPE                   --> Tabela de avalista atual
                                  ,pr_idpessoa    IN OUT tbcadast_pessoa.idpessoa%TYPE --> Identificador de pessoa
                                  ,pr_cdoperad    IN crapope.cdoperad%TYPE             --> Operador que esta efetuando a operacao
                                  ,pr_dscritic   OUT VARCHAR2) IS                      --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pc_pessoa_referencia
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para cadastrar/atualizar pessoa de referencia
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------

    -- Verificar se existe endereco
    CURSOR cr_pessoa_endereco(pr_idpessoa   tbcadast_pessoa_endereco.idpessoa%TYPE,
                              pr_tpendereco tbcadast_pessoa_endereco.tpendereco%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_endereco enc
       WHERE enc.idpessoa   = pr_idpessoa
         AND enc.tpendereco = pr_tpendereco;
    rw_pessoa_endereco cr_pessoa_endereco%ROWTYPE;

    -- Cursor para verificar se existe telefone para o conjuge
    CURSOR cr_pessoa_telefone(pr_idpessoa   tbcadast_pessoa_telefone.idpessoa%TYPE,
                              pr_tptelefone tbcadast_pessoa_telefone.tptelefone%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_telefone
       WHERE idpessoa   = pr_idpessoa
         AND tptelefone = pr_tptelefone;
    rw_pessoa_telefone cr_pessoa_telefone%ROWTYPE;

    CURSOR cr_email(pr_idpessoa    tbcadast_pessoa.idpessoa%TYPE,
                    pr_nrseq_email tbcadast_pessoa_email.nrseq_email%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_email
       WHERE idpessoa     = pr_idpessoa
         AND nrseq_email  = pr_nrseq_email;
    rw_email cr_email%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_pessoa_fis      vwcadast_pessoa_fisica%ROWTYPE;          -- Registro de pessoa
    vr_nrddd           tbcadast_pessoa_telefone.nrddd%TYPE;     -- Numero do DDD
    vr_nrtelefone      tbcadast_pessoa_telefone.nrtelefone%TYPE;-- Numero do telefone
    vr_nrramal         tbcadast_pessoa_telefone.nrramal%TYPE;   -- Numero do Ramal

  BEGIN

    -- Se possui conta, busca os dados da conta dela
    IF pr_crapavt.nrdctato > 0 THEN

      IF nvl(pr_idpessoa,0) = 0 THEN
        -- Efetua a inclusao de pessoa
        cada0011.pc_insere_pessoa_crapass(pr_cdcooper => pr_crapavt.cdcooper,
                                          pr_nrdconta => pr_crapavt.nrdctato,
                                          pr_idseqttl => 1,
                                          pr_cdoperad => pr_cdoperad,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
        -- Verifica se deu erro
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Busca o ID PESSOA
        pr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapavt.cdcooper,
                                       pr_nrdconta => pr_crapavt.nrdctato,
                                       pr_idseqttl => 1);
        IF pr_idpessoa IS NULL THEN
          vr_dscritic := 'Nao encontrado pessoa referencia';
          RAISE vr_exc_erro;
        END IF;

      END IF;
    ELSE -- Se nao possui conta
      --> Inserir/atualizar pessoa
      IF nvl(pr_idpessoa,0) > 0 THEN
        OPEN cr_pessoa_fis(pr_idpessoa => pr_idpessoa);
        FETCH cr_pessoa_fis INTO vr_pessoa_fis;
        CLOSE cr_pessoa_fis;
      ELSE
        vr_pessoa_fis := NULL;
      END IF;
      -- Efetua a inclusao/alteracao de pessoa
      vr_pessoa_fis.cdoperad_altera     := pr_cdoperad;
      vr_pessoa_fis.tpcadastro          := nvl(vr_pessoa_fis.tpcadastro,1); -- Prospect
      vr_pessoa_fis.tppessoa            := nvl(vr_pessoa_fis.tppessoa,1);   -- Fisico
      vr_pessoa_fis.nmpessoa            := pr_crapavt.nmdavali;

      -- Insere o Cadastro de pessoa fisica
      cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => vr_pessoa_fis,
                                       pr_cdcritic      => vr_cdcritic,
                                       pr_dscritic      => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Atualiza o IDPESSOA na variavel de uso
      pr_idpessoa := vr_pessoa_fis.idpessoa;

      -- Se possui endereco cadastrado
      IF TRIM(pr_crapavt.dsendres##1) IS NOT NULL THEN

        -- Verificar se existe endereco
        OPEN cr_pessoa_endereco(pr_idpessoa   => pr_idpessoa,
                                pr_tpendereco => 10); --Residencial
        FETCH cr_pessoa_endereco INTO rw_pessoa_endereco;
        CLOSE cr_pessoa_endereco;


        -- Efetua a tratativa de endereco
        rw_pessoa_endereco.idpessoa        := pr_idpessoa;
        rw_pessoa_endereco.tpendereco      := 10; --Residencial
        rw_pessoa_endereco.nrcep           := pr_crapavt.nrcepend;
        rw_pessoa_endereco.nmlogradouro    := pr_crapavt.dsendres##1;
        rw_pessoa_endereco.nrlogradouro    := pr_crapavt.nrendere;
        rw_pessoa_endereco.dscomplemento   := pr_crapavt.complend;
        rw_pessoa_endereco.nmbairro        := pr_crapavt.nmbairro;
        rw_pessoa_endereco.cdoperad_altera := pr_cdoperad;
        -- Trata o municipio
        IF TRIM(pr_crapavt.nmcidade) IS NOT NULL THEN
          -- Busca o ID do municipio
          CADA0015.pc_trata_municipio(pr_dscidade => TRIM(pr_crapavt.nmcidade),
                             pr_cdestado => TRIM(pr_crapavt.cdufresd),
                             pr_idcidade => rw_pessoa_endereco.idcidade,
                             pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Efetua a inclusao
        cada0010.pc_cadast_pessoa_endereco(pr_pessoa_endereco => rw_pessoa_endereco
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF; -- Fim da verificacao se possui endereco

      -- Busca os dados do email -> Sempre será o 1 email
      OPEN cr_email(pr_idpessoa    => pr_idpessoa,
                    pr_nrseq_email => 1);

      FETCH cr_email INTO rw_email;
      CLOSE cr_email;

      -- Verifica se possui email
      IF TRIM(pr_crapavt.dsdemail) IS NOT NULL THEN

        rw_email.idpessoa        := pr_idpessoa;
        rw_email.dsemail         := pr_crapavt.dsdemail;
        rw_email.nrseq_email     := 1;
        rw_email.cdoperad_altera := pr_cdoperad;

        -- Efetua a inclusao
        cada0010.pc_cadast_pessoa_email(pr_pessoa_email => rw_email
                                       ,pr_cdcritic     => vr_cdcritic
                                       ,pr_dscritic     => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      --> Se existia email cadastrado, deve exclui-lo
      ELSIF rw_email.nrseq_email > 0 THEN
        -- Efetua a exclusao do registro
        cada0010.pc_exclui_pessoa_email( pr_idpessoa     => pr_idpessoa,
                                         pr_nrseq_email  => rw_email.nrseq_email,
                                         pr_cdoperad_altera => pr_cdoperad,
                                         pr_cdcritic     => vr_cdcritic,
                                         pr_dscritic     => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      END IF;

      -- Verifica se possui telefone
      IF TRIM(pr_crapavt.nrtelefo) IS NOT NULL THEN


        -- Verifica se este telefone ja nao existe para a pessoa
        rw_pessoa_telefone := NULL;
        OPEN cr_pessoa_telefone(pr_idpessoa   => pr_idpessoa,
                                pr_tptelefone => 1); -- Residencial
        FETCH cr_pessoa_telefone INTO rw_pessoa_telefone;
        CLOSE cr_pessoa_telefone;

        -- Estrutura o telefone
        CADA0011.pc_trata_telefone( pr_nrtelefone_org => substr(pr_crapavt.nrtelefo,1,50),
                                    pr_nrramal_org    => NULL,
                                    pr_nrddd          => vr_nrddd,
                                    pr_nrtelefone     => vr_nrtelefone,
                                    pr_nrramal        => vr_nrramal,
                                    pr_dscritic       => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Atualiza os dados do telefone
        rw_pessoa_telefone.idpessoa               := pr_idpessoa;
        rw_pessoa_telefone.tptelefone             := 1; -- Residencial
        rw_pessoa_telefone.nrddd                  := vr_nrddd;
        rw_pessoa_telefone.nrtelefone             := vr_nrtelefone;
        rw_pessoa_telefone.cdoperad_altera        := pr_cdoperad;

        -- Efetua a inclusao
        cada0010.pc_cadast_pessoa_telefone(pr_pessoa_telefone => rw_pessoa_telefone
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF; -- Fim da verificacao se possui telefone


    END IF;

	EXCEPTION
    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_pessoa_referencia: '||SQLERRM;
  END pc_pessoa_referencia;

  -- Rotina para cadastrar/atualizar pessoa representante
  PROCEDURE pc_pessoa_juridica_rep ( pr_crapavt     IN crapavt%ROWTYPE                   --> Tabela de avalista atual
                                    ,pr_idpessoa    IN OUT tbcadast_pessoa.idpessoa%TYPE --> Identificador de pessoa
                                    ,pr_cdoperad    IN crapope.cdoperad%TYPE             --> Operador que esta efetuando a operacao
                                    ,pr_dscritic   OUT VARCHAR2) IS                      --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pc_pessoa_juridica_rep
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para cadastrar/atualizar pessoa representante
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------

    -- Buscar dados da pessoa de relacao
    CURSOR cr_pessoa_rel ( pr_idpessoa   tbcadast_pessoa.idpessoa%TYPE,
                           pr_tprelacao  tbcadast_pessoa_relacao.tprelacao%TYPE) IS
      SELECT rel.nrseq_relacao,
             rel.idpessoa_relacao,
             pes.nmpessoa
        FROM tbcadast_pessoa_relacao rel,
             tbcadast_pessoa pes
       WHERE rel.idpessoa         = pr_idpessoa
         AND rel.tprelacao        = pr_tprelacao
         AND rel.idpessoa_relacao = pes.idpessoa;
    rw_pessoa_rel cr_pessoa_rel%ROWTYPE;

    -- Verificar se existe endereco
    CURSOR cr_pessoa_endereco(pr_idpessoa   tbcadast_pessoa_endereco.idpessoa%TYPE,
                              pr_tpendereco tbcadast_pessoa_endereco.tpendereco%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_endereco enc
       WHERE enc.idpessoa   = pr_idpessoa
         AND enc.tpendereco = pr_tpendereco;
    rw_pessoa_endereco cr_pessoa_endereco%ROWTYPE;

    --> buscar dados do bem
    CURSOR cr_pessoa_bem (pr_idpessa   tbcadast_pessoa_bem.idpessoa%TYPE,
                          pr_nrseq_bem tbcadast_pessoa_bem.nrseq_bem%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_bem bem
       WHERE bem.idpessoa  = pr_idpessa
         AND bem.nrseq_bem = pr_nrseq_bem;
    rw_pessoa_bem cr_pessoa_bem%ROWTYPE;

    -- Cursor para verificar se existe telefone para o conjuge
    CURSOR cr_pessoa_telefone(pr_idpessoa   tbcadast_pessoa_telefone.idpessoa%TYPE,
                              pr_tptelefone tbcadast_pessoa_telefone.tptelefone%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_telefone
       WHERE idpessoa   = pr_idpessoa
         AND tptelefone = pr_tptelefone;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_pessoa_fis      vwcadast_pessoa_fisica%ROWTYPE;          -- Registro de pessoa

  BEGIN

    -- Se possui conta, busca os dados da conta dela
    IF pr_crapavt.nrdctato > 0 THEN

      IF nvl(pr_idpessoa,0) = 0 THEN
        -- Efetua a inclusao de pessoa
        cada0011.pc_insere_pessoa_crapass(pr_cdcooper => pr_crapavt.cdcooper,
                                          pr_nrdconta => pr_crapavt.nrdctato,
                                          pr_idseqttl => 1,
                                          pr_cdoperad => pr_cdoperad,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
        -- Verifica se deu erro
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Busca o ID PESSOA
        pr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapavt.cdcooper,
                                       pr_nrdconta => pr_crapavt.nrdctato,
                                       pr_idseqttl => 1);
        IF pr_idpessoa IS NULL THEN
          vr_dscritic := 'Nao encontrado pessoa representante';
          RAISE vr_exc_erro;
        END IF;

      END IF;
    ELSE -- Se nao possui conta
      --> Inserir/atualizar pessoa
      IF nvl(pr_idpessoa,0) > 0 THEN
        OPEN cr_pessoa_fis(pr_idpessoa => pr_idpessoa);
        FETCH cr_pessoa_fis INTO vr_pessoa_fis;
        CLOSE cr_pessoa_fis;
      ELSE
        vr_pessoa_fis := NULL;
      END IF;

      -- Efetua a inclusao/alteracao de pessoa
      vr_pessoa_fis.nrcpf               := pr_crapavt.nrcpfcgc;
      vr_pessoa_fis.cdoperad_altera     := pr_cdoperad;
      vr_pessoa_fis.tpcadastro          := nvl(vr_pessoa_fis.tpcadastro, 2); -- Basico
      vr_pessoa_fis.tppessoa            := 1; -- Fisica
      vr_pessoa_fis.nmpessoa            := pr_crapavt.nmdavali;
      vr_pessoa_fis.tpdocumento         := pr_crapavt.tpdocava;
      vr_pessoa_fis.nrdocumento         := pr_crapavt.nrdocava;
      IF pr_crapavt.idorgexp <> 0 THEN
        vr_pessoa_fis.idorgao_expedidor := pr_crapavt.idorgexp;
      END IF;
      vr_pessoa_fis.dtemissao_documento := pr_crapavt.dtemddoc;
      vr_pessoa_fis.cduf_orgao_expedidor:= TRIM(pr_crapavt.cdufddoc);
      vr_pessoa_fis.dtnascimento        := pr_crapavt.dtnascto;
      vr_pessoa_fis.tpsexo              := pr_crapavt.cdsexcto;
      IF nvl(pr_crapavt.cdestcvl,0) > 0 THEN
        vr_pessoa_fis.cdestado_civil      := pr_crapavt.cdestcvl;
      END IF;
      vr_pessoa_fis.inhabilitacao_menor := pr_crapavt.inhabmen;
      vr_pessoa_fis.dthabilitacao_menor := pr_crapavt.dthabmen;
      IF nvl(pr_crapavt.cdnacion,0) <> 0 THEN
        vr_pessoa_fis.cdnacionalidade  := pr_crapavt.cdnacion;
      END IF;

      -- Busca o municipio da naturalidade
      CADA0015.pc_trata_municipio(pr_dscidade => pr_crapavt.dsnatura,
                                  pr_cdestado => NULL,
                                  pr_idcidade => vr_pessoa_fis.cdnaturalidade,
                                  pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Insere o Cadastro de pessoa fisica
      cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => vr_pessoa_fis,
                                       pr_cdcritic      => vr_cdcritic,
                                       pr_dscritic      => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Atualiza o IDPESSOA na variavel de uso
      pr_idpessoa := vr_pessoa_fis.idpessoa;

      -- Buscar dados da pessoa de relacao
      OPEN cr_pessoa_rel ( pr_idpessoa  => pr_idpessoa,
                           pr_tprelacao => 3); -- Pai
      FETCH cr_pessoa_rel INTO rw_pessoa_rel;
      CLOSE cr_pessoa_rel;

      --> se possia inf do pai, porém agora o campo esta vazio, deve deletar
      IF rw_pessoa_rel.nrseq_relacao > 0 AND
         ( TRIM(pr_crapavt.nmpaicto) IS NULL OR
           pr_crapavt.nmpaicto <> rw_pessoa_rel.nmpessoa ) THEN
        -- Efetua a exclusao do registro
        cada0010.pc_exclui_pessoa_relacao ( pr_idpessoa           => pr_idpessoa,
                                            pr_nrseq_relacao      => rw_pessoa_rel.nrseq_relacao,
                                            pr_cdoperad_altera    => pr_cdoperad,
                                            pr_cdcritic           => vr_cdcritic,
                                            pr_dscritic           => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- se possui nome do pai, e é diferente do atual
      IF TRIM(pr_crapavt.nmpaicto) IS NOT NULL AND
         nvl(pr_crapavt.nmpaicto,' ') <> nvl(rw_pessoa_rel.nmpessoa,' ') THEN

        CADA0011.pc_trata_pessoa_relacao( pr_idpessoa => pr_idpessoa,
                                          pr_tprelacao=> 3, -- Pai
                                          pr_nmpessoa => pr_crapavt.nmpaicto,
                                          pr_cdoperad => pr_cdoperad,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Buscar dados da pessoa de relacao
      rw_pessoa_rel := NULL;
      OPEN cr_pessoa_rel ( pr_idpessoa  => pr_idpessoa,
                           pr_tprelacao => 4); -- Mae
      FETCH cr_pessoa_rel INTO rw_pessoa_rel;
      CLOSE cr_pessoa_rel;

      --> se possia inf do mae, porém agora o campo esta vazio, deve deletar
      IF rw_pessoa_rel.nrseq_relacao > 0 AND
         ( TRIM(pr_crapavt.nmmaecto) IS NULL OR
           pr_crapavt.nmmaecto <> rw_pessoa_rel.nmpessoa ) THEN
        -- Efetua a exclusao do registro
        cada0010.pc_exclui_pessoa_relacao ( pr_idpessoa           => pr_idpessoa,
                                            pr_nrseq_relacao      => rw_pessoa_rel.nrseq_relacao,
                                            pr_cdoperad_altera    => pr_cdoperad,
                                            pr_cdcritic           => vr_cdcritic,
                                            pr_dscritic           => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- se possui nome do pai, e é diferente do atual
      IF TRIM(pr_crapavt.nmmaecto) IS NOT NULL AND
         nvl(pr_crapavt.nmmaecto,' ') <> nvl(rw_pessoa_rel.nmpessoa,' ') THEN

        CADA0011.pc_trata_pessoa_relacao( pr_idpessoa => pr_idpessoa,
                                          pr_tprelacao=> 4, -- Mae
                                          pr_nmpessoa => pr_crapavt.nmmaecto,
                                          pr_cdoperad => pr_cdoperad,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;


      -- Se possui endereco cadastrado
      IF TRIM(pr_crapavt.dsendres##1) IS NOT NULL THEN

        -- Verificar se existe endereco
        OPEN cr_pessoa_endereco(pr_idpessoa   => pr_idpessoa,
                                pr_tpendereco => 10); --Residencial
        FETCH cr_pessoa_endereco INTO rw_pessoa_endereco;
        CLOSE cr_pessoa_endereco;


        -- Efetua a tratativa de endereco
        rw_pessoa_endereco.idpessoa        := pr_idpessoa;
        rw_pessoa_endereco.tpendereco      := 10; --Residencial
        rw_pessoa_endereco.nrcep           := pr_crapavt.nrcepend;
        rw_pessoa_endereco.nmlogradouro    := pr_crapavt.dsendres##1;
        rw_pessoa_endereco.nrlogradouro    := pr_crapavt.nrendere;
        rw_pessoa_endereco.dscomplemento   := pr_crapavt.complend;
        rw_pessoa_endereco.nmbairro        := pr_crapavt.nmbairro;
        rw_pessoa_endereco.cdoperad_altera := pr_cdoperad;
        -- Trata o municipio
        IF TRIM(pr_crapavt.nmcidade) IS NOT NULL THEN
          -- Busca o ID do municipio
          CADA0015.pc_trata_municipio(pr_dscidade => TRIM(pr_crapavt.nmcidade),
                             pr_cdestado => TRIM(pr_crapavt.cdufresd),
                             pr_idcidade => rw_pessoa_endereco.idcidade,
                             pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Efetua a inclusao
        cada0010.pc_cadast_pessoa_endereco(pr_pessoa_endereco => rw_pessoa_endereco
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF; -- Fim da verificacao se possui endereco

      -- Efetua a tratativa de bens
      -- Efetua loop sobre os bens
      FOR x IN 1..6 LOOP

        --> Buscar dados do bem
        rw_pessoa_bem := NULL;
        OPEN cr_pessoa_bem (pr_idpessa   => pr_idpessoa,
                            pr_nrseq_bem => x);
        FETCH cr_pessoa_bem INTO rw_pessoa_bem;
        CLOSE cr_pessoa_bem;

        rw_pessoa_bem.idpessoa        := pr_idpessoa;
        rw_pessoa_bem.cdoperad_altera := pr_cdoperad;
        rw_pessoa_bem.dtalteracao     := pr_crapavt.dtmvtolt;

        IF x = 1 THEN
          -- Se nao tiver bem cadastrado
          IF TRIM(pr_crapavt.dsrelbem##1) IS NULL THEN
            --> se esta nulo, porem existe registro, necessario excluir
            IF rw_pessoa_bem.nrseq_bem = x THEN
              -- Efetua a inclusao
              cada0010.pc_exclui_pessoa_bem(pr_idpessoa  => pr_idpessoa
                                           ,pr_nrseq_bem => rw_pessoa_bem.nrseq_bem
                                           ,pr_cdoperad_altera => pr_cdoperad
                                           ,pr_cdcritic  => vr_cdcritic
                                           ,pr_dscritic  => vr_dscritic);
              IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
            END IF;
            continue;
          END IF;

          -- Popula os campos para inserir o registro
          rw_pessoa_bem.nrseq_bem       := 1;
          rw_pessoa_bem.dsbem           := pr_crapavt.dsrelbem##1;
          rw_pessoa_bem.pebem           := greatest(0,pr_crapavt.persemon##1);
          rw_pessoa_bem.qtparcela_bem   := pr_crapavt.qtprebem##1;
          rw_pessoa_bem.vlbem           := pr_crapavt.vlrdobem##1;
          rw_pessoa_bem.vlparcela_bem   := pr_crapavt.vlprebem##1;
        ELSIF x = 2 THEN
          -- Se nao tiver bem cadastrado
          IF TRIM(pr_crapavt.dsrelbem##2) IS NULL THEN
            --> se esta nulo, porem existe registro, necessario excluir
            IF rw_pessoa_bem.nrseq_bem = x THEN
              -- Efetua a inclusao
              cada0010.pc_exclui_pessoa_bem(pr_idpessoa  => pr_idpessoa
                                           ,pr_nrseq_bem => rw_pessoa_bem.nrseq_bem
                                           ,pr_cdoperad_altera => pr_cdoperad
                                           ,pr_cdcritic  => vr_cdcritic
                                           ,pr_dscritic  => vr_dscritic);
              IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
            END IF;
            continue;
          END IF;
          -- Popula os campos para inserir o registro
          rw_pessoa_bem.nrseq_bem       := 2;
          rw_pessoa_bem.dsbem           := pr_crapavt.dsrelbem##2;
          rw_pessoa_bem.pebem           := greatest(0,pr_crapavt.persemon##2);
          rw_pessoa_bem.qtparcela_bem   := pr_crapavt.qtprebem##2;
          rw_pessoa_bem.vlbem           := pr_crapavt.vlrdobem##2;
          rw_pessoa_bem.vlparcela_bem   := pr_crapavt.vlprebem##2;
        ELSIF x = 3 THEN
          -- Se nao tiver bem cadastrado
          IF TRIM(pr_crapavt.dsrelbem##3) IS NULL THEN
            --> se esta nulo, porem existe registro, necessario excluir
            IF rw_pessoa_bem.nrseq_bem = x THEN
              -- Efetua a inclusao
              cada0010.pc_exclui_pessoa_bem(pr_idpessoa  => pr_idpessoa
                                           ,pr_nrseq_bem => rw_pessoa_bem.nrseq_bem
                                           ,pr_cdoperad_altera => pr_cdoperad
                                           ,pr_cdcritic  => vr_cdcritic
                                           ,pr_dscritic  => vr_dscritic);
              IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
            END IF;
            continue;
          END IF;
          -- Popula os campos para inserir o registro
          rw_pessoa_bem.nrseq_bem       := 3;
          rw_pessoa_bem.dsbem           := pr_crapavt.dsrelbem##3;
          rw_pessoa_bem.pebem           := greatest(0,pr_crapavt.persemon##3);
          rw_pessoa_bem.qtparcela_bem   := pr_crapavt.qtprebem##3;
          rw_pessoa_bem.vlbem           := pr_crapavt.vlrdobem##3;
          rw_pessoa_bem.vlparcela_bem   := pr_crapavt.vlprebem##3;
        ELSIF x = 4 THEN
          -- Se nao tiver bem cadastrado
          IF TRIM(pr_crapavt.dsrelbem##4) IS NULL THEN
            --> se esta nulo, porem existe registro, necessario excluir
            IF rw_pessoa_bem.nrseq_bem = x THEN
              -- Efetua a inclusao
              cada0010.pc_exclui_pessoa_bem(pr_idpessoa  => pr_idpessoa
                                           ,pr_nrseq_bem => rw_pessoa_bem.nrseq_bem
                                           ,pr_cdoperad_altera => pr_cdoperad
                                           ,pr_cdcritic  => vr_cdcritic
                                           ,pr_dscritic  => vr_dscritic);
              IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
            END IF;
            continue;
          END IF;
          -- Popula os campos para inserir o registro
          rw_pessoa_bem.nrseq_bem       := 4;
          rw_pessoa_bem.dsbem           := pr_crapavt.dsrelbem##4;
          rw_pessoa_bem.pebem           := greatest(0,pr_crapavt.persemon##4);
          rw_pessoa_bem.qtparcela_bem   := pr_crapavt.qtprebem##4;
          rw_pessoa_bem.vlbem           := pr_crapavt.vlrdobem##4;
          rw_pessoa_bem.vlparcela_bem   := pr_crapavt.vlprebem##4;
        ELSIF x = 5 THEN
          -- Se nao tiver bem cadastrado
          IF TRIM(pr_crapavt.dsrelbem##5) IS NULL THEN
            --> se esta nulo, porem existe registro, necessario excluir
            IF rw_pessoa_bem.nrseq_bem = x THEN
              -- Efetua a inclusao
              cada0010.pc_exclui_pessoa_bem(pr_idpessoa  => pr_idpessoa
                                           ,pr_nrseq_bem => rw_pessoa_bem.nrseq_bem
                                           ,pr_cdoperad_altera => pr_cdoperad
                                           ,pr_cdcritic  => vr_cdcritic
                                           ,pr_dscritic  => vr_dscritic);
              IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
            END IF;
            continue;
          END IF;
          -- Popula os campos para inserir o registro
          rw_pessoa_bem.nrseq_bem       := 5;
          rw_pessoa_bem.dsbem           := pr_crapavt.dsrelbem##5;
          rw_pessoa_bem.pebem           := greatest(0,pr_crapavt.persemon##5);
          rw_pessoa_bem.qtparcela_bem   := pr_crapavt.qtprebem##5;
          rw_pessoa_bem.vlbem           := pr_crapavt.vlrdobem##5;
          rw_pessoa_bem.vlparcela_bem   := pr_crapavt.vlprebem##5;
        ELSE
          -- Se nao tiver bem cadastrado
          IF TRIM(pr_crapavt.dsrelbem##6) IS NULL THEN
            --> se esta nulo, porem existe registro, necessario excluir
            IF rw_pessoa_bem.nrseq_bem = x THEN
              -- Efetua a inclusao
              cada0010.pc_exclui_pessoa_bem(pr_idpessoa  => pr_idpessoa
                                           ,pr_nrseq_bem => rw_pessoa_bem.nrseq_bem
                                           ,pr_cdoperad_altera => pr_cdoperad
                                           ,pr_cdcritic  => vr_cdcritic
                                           ,pr_dscritic  => vr_dscritic);
              IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
            END IF;
            continue;
          END IF;
          -- Popula os campos para inserir o registro
          rw_pessoa_bem.nrseq_bem       := 6;
          rw_pessoa_bem.dsbem           := pr_crapavt.dsrelbem##6;
          rw_pessoa_bem.pebem           := greatest(0,pr_crapavt.persemon##6);
          rw_pessoa_bem.qtparcela_bem   := pr_crapavt.qtprebem##6;
          rw_pessoa_bem.vlbem           := pr_crapavt.vlrdobem##6;
          rw_pessoa_bem.vlparcela_bem   := pr_crapavt.vlprebem##6;
        END IF;
        -- Efetua a inclusao
        cada0010.pc_cadast_pessoa_bem(pr_pessoa_bem => rw_pessoa_bem
                                     ,pr_cdcritic   => vr_cdcritic
                                     ,pr_dscritic   => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END LOOP;
    END IF;

	EXCEPTION
    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_pessoa_juridica_rep: '||SQLERRM;
  END pc_pessoa_juridica_rep;

  -- Rotina para atualizacao da tabela de avalista (CRAPAVT)
  PROCEDURE pc_crapavt(pr_crapavt     IN crapavt%ROWTYPE            --> Tabela de avalista atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2) IS               --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pr_crapavt
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para atualizacao da tabela de avalista(CRAPAVT)
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    -- Buscar dados de pesso de referencia
    CURSOR cr_pessoa_referencia ( pr_idpessoa         tbcadast_pessoa.idpessoa%TYPE,
                                  pr_nrseq_referencia tbcadast_pessoa_referencia.nrseq_referencia%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_referencia rfe
       WHERE rfe.idpessoa         = pr_idpessoa
         AND rfe.nrseq_referencia = pr_nrseq_referencia;
    rw_pessoa_referencia cr_pessoa_referencia%ROWTYPE;

    -- Buscar dados de pessoa de representante
    CURSOR cr_pessoa_fisica_rep ( pr_idpessoa               tbcadast_pessoa.idpessoa%TYPE,
                                  pr_idpessoa_representante tbcadast_pessoa_juridica_rep.idpessoa_representante%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_juridica_rep rep
       WHERE rep.idpessoa               = pr_idpessoa
         AND rep.idpessoa_representante = pr_idpessoa_representante;
    rw_pessoa_fisica_rep cr_pessoa_fisica_rep%ROWTYPE;

    --> Identificar pessoa referencia pelo nome
    CURSOR cr_pessoa_ref (pr_idpessoa  tbcadast_pessoa.idpessoa%TYPE,
                               pr_nrseq_ref tbcadast_pessoa_referencia.nrseq_referencia%TYPE) IS
      SELECT rfe.idpessoa_referencia
        FROM tbcadast_pessoa_referencia rfe
       WHERE rfe.idpessoa         = pr_idpessoa
         AND rfe.nrseq_referencia = pr_nrseq_ref;

    --> Identificar pessoa referencia pelo nome
    CURSOR cr_pessoa_ref_nome (pr_idpessoa  tbcadast_pessoa.idpessoa%TYPE,
                               pr_nmpessoa  tbcadast_pessoa.nmpessoa%TYPE) IS
      SELECT rfe.idpessoa_referencia
        FROM tbcadast_pessoa_referencia rfe,
             tbcadast_pessoa pes
       WHERE rfe.idpessoa = pr_idpessoa
         AND rfe.idpessoa_referencia = pes.idpessoa
         AND pes.nmpessoa = pr_nmpessoa;

    --> Identificar pessoa representante pelo nome
    CURSOR cr_pessoa_rep_nome (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE,
                               pr_nmpessoa tbcadast_pessoa.nmpessoa%TYPE) IS
      SELECT rep.idpessoa_representante
        FROM tbcadast_pessoa_juridica_rep rep,
             tbcadast_pessoa pes
       WHERE rep.idpessoa = pr_idpessoa
         AND rep.idpessoa_representante = pes.idpessoa
         AND pes.nmpessoa = pr_nmpessoa;

    --> Identificar tipo de pessoa
    CURSOR cr_crapass(pr_cdcooper  crapass.cdcooper%TYPE,
                      pr_nrdconta  crapass.nrdconta%TYPE)IS
      SELECT ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    --> buscar pessoa pelo id
    CURSOR cr_pessoa_id(pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT pes.tppessoa
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;
    rw_pessoa_id cr_pessoa_id%ROWTYPE;    

    -- Cursor para verificar se existe registro da crapavt duplicado
    CURSOR cr_crapavt_duplicado(pr_cdcooper crapavt.cdcooper%TYPE,
                                pr_nrdconta crapavt.nrdconta%TYPE,
                                pr_idseqttl tbhistor_crapavt.idseqttl%TYPE,
                                pr_idpessoa tbhistor_crapavt.idpessoa_relacao%TYPE,
                                pr_nrcpfcgc tbhistor_crapavt.nrcpfcgc%TYPE) IS
      SELECT 1
        FROM tbhistor_crapavt a
       WHERE a.dhalteracao >= TRUNC(SYSDATE,'MI')
         AND a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.idseqttl = pr_idseqttl
         AND ((pr_idpessoa IS NOT NULL 
         AND   a.idpessoa_relacao = pr_idpessoa)                           
          OR  (pr_idpessoa IS NULL
         AND   a.nrcpfcgc = pr_nrcpfcgc));
    rw_crapavt_duplicado cr_crapavt_duplicado%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE;           -- Identificador de pessoa
    vr_idpessoa_avt    tbcadast_pessoa.idpessoa%TYPE;           -- Identificador de pessoa avt
    vr_idalteracao      tbhistor_conta_comunic_soa.idalteracao%TYPE;
    vr_idpessoa_relacao tbhistor_crapavt.idpessoa_relacao%TYPE;
    vr_idseqttl         tbhistor_crapavt.idseqttl%TYPE;

  BEGIN

    -- Se nao for informado o IDPESSOA, deve-se buscar
    IF pr_idpessoa IS NULL THEN
      -- Busca o ID PESSOA
      vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapavt.cdcooper,
                                     pr_nrdconta => pr_crapavt.nrdconta,
                                     pr_idseqttl => 1);
      IF vr_idpessoa IS NULL THEN
        vr_dscritic := 'Nao encontrado PESSOA para alteracao do avalista';
        RAISE vr_exc_saida;
      END IF;
    ELSE
      vr_idpessoa := pr_idpessoa;
    END IF;

    --> Buscar pessoa pelo ID
    OPEN cr_pessoa_id(pr_idpessoa => vr_idpessoa);
    FETCH cr_pessoa_id INTO rw_pessoa_id;
    CLOSE cr_pessoa_id;

    -- pessoa de referencia
    IF pr_crapavt.tpctrato = 5 THEN
      IF nvl(pr_crapavt.nrdctato,0) > 0 THEN
        -- Busca o ID PESSOA do avalista
        vr_idpessoa_avt := fn_busca_pessoa ( pr_cdcooper => pr_crapavt.cdcooper,
                                             pr_nrdconta => pr_crapavt.nrdctato,
                                             pr_idseqttl => 1);

      ELSE
        --> Identificar pessoa pelo nome
        OPEN cr_pessoa_ref_nome (pr_idpessoa  => vr_idpessoa,
                                 pr_nmpessoa  => pr_crapavt.nmdavali);
        FETCH cr_pessoa_ref_nome INTO vr_idpessoa_avt;
        CLOSE cr_pessoa_ref_nome;
      END IF;

    --> Se for um procurador
    ELSIF pr_crapavt.tpctrato = 6 AND
       (nvl(pr_crapavt.dsproftl,' ') = 'PROCURADOR' OR
        rw_pessoa_id.tppessoa = 1) THEN
      -- verificacao para buscar pessoa de contato
      IF pr_crapavt.nrdctato <> 0 AND pr_tpoperacao <> 3 THEN
        -- Busca o idpessoa da conta de contato
        vr_idpessoa_relacao := fn_busca_pessoa(pr_cdcooper => pr_crapavt.cdcooper,
                                               pr_nrdconta => pr_crapavt.nrdctato,
                                               pr_idseqttl => 1);
        IF vr_idpessoa IS NULL THEN
          vr_dscritic := 'Nao encontrado PESSOA DE CONTATO para alteracao do procurador';
          RAISE vr_exc_saida;
        END IF;
      ELSE
        vr_idpessoa_relacao := NULL;
      END IF;
        
      IF rw_pessoa_id.tppessoa = 2 THEN
        vr_idseqttl := 1;
      ELSE
        vr_idseqttl := pr_crapavt.nrctremp;
      END IF;

      -- Verifica se ja foi inserido o registro no ultimo minuto
      OPEN cr_crapavt_duplicado(pr_cdcooper => pr_crapavt.cdcooper,
                                pr_nrdconta => pr_crapavt.nrdconta,
                                pr_idseqttl => vr_idseqttl,
                                pr_idpessoa => vr_idpessoa_relacao,
                                pr_nrcpfcgc => pr_crapavt.nrcpfcgc);
      FETCH cr_crapavt_duplicado INTO rw_crapavt_duplicado;
      
      -- Se nao encontrou, entao pode inserir novo
      IF cr_crapavt_duplicado%NOTFOUND THEN
        CLOSE cr_crapavt_duplicado;
        -- Cria o cabecalho da comunicacao
      vr_idalteracao := cria_conta_comunic_soa(pr_crapavt.cdcooper,
                                               pr_crapavt.nrdconta,
                                               'CRAPAVT');

      -- Se for uma exclusao
      IF pr_tpoperacao = 3 THEN
        BEGIN
          INSERT INTO tbhistor_crapavt 
            (idalteracao, 
             dhalteracao, 
             tpoperacao, 
             cdcooper, 
             nrdconta, 
             idseqttl, 
             nrcpfcgc) 
           VALUES
            (vr_idalteracao, 
             SYSDATE, 
             pr_tpoperacao, 
             pr_crapavt.cdcooper, 
             pr_crapavt.nrdconta, 
               vr_idseqttl,
             pr_crapavt.nrcpfcgc);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na tbhistor_crapavt: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
      ELSE
        -- Se nao tiver conta de contato, utiliza os dados existentes na tabela
        IF pr_crapavt.nrdctato = 0 THEN
          BEGIN
            INSERT INTO tbhistor_crapavt 
              (idalteracao, 
               dhalteracao, 
               tpoperacao, 
               cdcooper, 
               nrdconta, 
               idseqttl, 
               nrcpfcgc,
               nmdavali, 
               tpdocava, 
               nrdocava, 
               dsendres##1, 
               nrcepend, 
               nmcidade, 
               cdufresd, 
               nrendere, 
               dscomplend, 
               nmbairro, 
               dsproftl, 
               dtemddoc, 
               cdufddoc, 
               dtvalida, 
               nmmaecto, 
               nmpaicto, 
               dtnascto, 
               dsnatura, 
               cdsexcto, 
               cdestcvl, 
               dtadmsoc, 
               idhabmen, 
               dthabmen, 
               cdnacion, 
               idorgexp)
             VALUES
              (vr_idalteracao, 
               SYSDATE, 
               pr_tpoperacao, 
               pr_crapavt.cdcooper, 
               pr_crapavt.nrdconta, 
                 vr_idseqttl,
               pr_crapavt.nrcpfcgc,
               pr_crapavt.nmdavali, 
               pr_crapavt.tpdocava, 
               pr_crapavt.nrdocava, 
               pr_crapavt.dsendres##1, 
               pr_crapavt.nrcepend, 
               pr_crapavt.nmcidade, 
               pr_crapavt.cdufresd, 
               pr_crapavt.nrendere, 
               pr_crapavt.complend, 
               pr_crapavt.nmbairro, 
               pr_crapavt.dsproftl, 
               pr_crapavt.dtemddoc, 
               pr_crapavt.cdufddoc, 
               pr_crapavt.dtvalida, 
               pr_crapavt.nmmaecto, 
               pr_crapavt.nmpaicto, 
               pr_crapavt.dtnascto, 
               pr_crapavt.dsnatura, 
               pr_crapavt.cdsexcto, 
               pr_crapavt.cdestcvl, 
               pr_crapavt.dtadmsoc, 
               pr_crapavt.inhabmen, 
               pr_crapavt.dthabmen, 
               pr_crapavt.cdnacion, 
               pr_crapavt.idorgexp);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir tbhistor_crapavt: '||SQLERRM;
              RAISE vr_exc_erro;
          END;          
        ELSE -- Tem conta de contato
          -- Insere o procurador com a pessoa de contato
          BEGIN
            INSERT INTO tbhistor_crapavt 
              (idalteracao, 
               dhalteracao, 
               tpoperacao, 
               cdcooper, 
               nrdconta, 
               idseqttl,
               idpessoa_relacao)
             VALUES
              (vr_idalteracao, 
               SYSDATE, 
               pr_tpoperacao, 
               pr_crapavt.cdcooper, 
               pr_crapavt.nrdconta, 
                 vr_idseqttl,
               vr_idpessoa_relacao);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro inserir tbhistor_crapavt: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
        END IF;
      END IF;
      ELSE
        CLOSE cr_crapavt_duplicado;
      END IF;
    --> se for representante
    ELSIF pr_crapavt.tpctrato = 6  THEN -- Nao sera levado procuradores
      -- Busca o ID PESSOA do avalista
      vr_idpessoa_avt := fn_busca_pessoa(pr_cdcooper => pr_crapavt.cdcooper,
                                         pr_nrdconta => pr_crapavt.nrdctato,
                                         pr_idseqttl => 1,
                                         pr_nrcpfcgc => pr_crapavt.nrcpfcgc);

      --> Deve tentar pela pessoa que ja esta atrelada se possuir mesmo nome
      IF nvl(vr_idpessoa_avt,0) = 0 AND pr_crapavt.nrcpfcgc = 0 THEN
        --> Identificar pessoa representante pelo nome
        OPEN cr_pessoa_rep_nome (pr_idpessoa => vr_idpessoa,
                                 pr_nmpessoa => pr_crapavt.nmdavali);
        FETCH cr_pessoa_rep_nome INTO vr_idpessoa_avt;
        CLOSE cr_pessoa_rep_nome;
      END IF;
    END IF;


    --> se for pessoa de referencia
    IF pr_crapavt.tpctrato = 5 THEN
    
      -- Buscar dados de pesso de referencia
      rw_pessoa_referencia := NULL;
      OPEN cr_pessoa_referencia ( pr_idpessoa         => vr_idpessoa,
                                  pr_nrseq_referencia => (CASE rw_pessoa_id.tppessoa 
                                                            WHEN 1 THEN pr_crapavt.nrcpfcgc --> para pessoa fisica, o campo nrcpscgc é o seq
                                                            ELSE pr_crapavt.nrctremp --> pessoa jur é o numero do contrato
                                                          END)); 
      FETCH cr_pessoa_referencia INTO rw_pessoa_referencia;
      CLOSE cr_pessoa_referencia;

      -- Se for uma exclusao
      IF pr_tpoperacao = 3 THEN
        -- Se encontrou registro na busca
        IF rw_pessoa_referencia.nrseq_referencia IS NOT NULL THEN
          -- Efetua a exclusao do registro
          cada0010.pc_exclui_pessoa_referencia (pr_idpessoa           => vr_idpessoa,
                                                pr_nrseq_referencia   => rw_pessoa_referencia.nrseq_referencia,
                                                pr_cdoperad_altera    => pr_cdoperad,
                                                pr_cdcritic           => vr_cdcritic,
                                                pr_dscritic           => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

      ELSE -- Se for alteracao ou inclusao

        -- Cadastrar/atualizar pessoa de referencia
        pc_pessoa_referencia ( pr_crapavt     => pr_crapavt      --> Tabela de avalista atual
                              ,pr_idpessoa    => vr_idpessoa_avt --> Identificador de pessoa
                              ,pr_cdoperad    => pr_cdoperad     --> Operador que esta efetuando a operacao
                              ,pr_dscritic    => vr_dscritic);   --> Retorno de Erro

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;


        --> Identificar tipo de pessoa
        rw_crapass := NULL;
        OPEN cr_crapass(pr_cdcooper => pr_crapavt.cdcooper,
                        pr_nrdconta => pr_crapavt.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;

        -- Sera necessario colocar a linha abaixo porque para a pessoa de referencia
        -- nao eh gravado o CPF / CNPJ quando a mesma nao possui conta
        IF rw_crapass.inpessoa > 1 THEN -- Se for um PJ
          rw_pessoa_referencia.nrseq_referencia := pr_crapavt.nrctremp;
        ELSE
          rw_pessoa_referencia.nrseq_referencia := pr_crapavt.nrcpfcgc; -- Para PF, o CPF/CGC eh o sequencial
        END IF;

        rw_pessoa_referencia.idpessoa             := vr_idpessoa;
        rw_pessoa_referencia.idpessoa_referencia  := vr_idpessoa_avt;
        rw_pessoa_referencia.cdoperad_altera      := pr_cdoperad;

        -- Efetua a inclusao
        cada0010.pc_cadast_pessoa_referencia(pr_pessoa_referencia => rw_pessoa_referencia
                                            ,pr_cdcritic          => vr_cdcritic
                                            ,pr_dscritic          => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      END IF;

    --> Se for um procurador
    ELSIF pr_crapavt.tpctrato = 6 AND
       (nvl(pr_crapavt.dsproftl,' ') = 'PROCURADOR' OR
        rw_pessoa_id.tppessoa = 1) THEN
      NULL; -- Ja fez no passo acima
    --> se for pessoa representante
    ELSIF pr_crapavt.tpctrato = 6 AND
          nvl(pr_crapavt.dsproftl,' ') <> 'PROCURADOR' THEN -- Nao sera levado procuradores

      -- Buscar dados de pessoa de representante
      rw_pessoa_fisica_rep := NULL;
      OPEN cr_pessoa_fisica_rep ( pr_idpessoa               => vr_idpessoa,
                                  pr_idpessoa_representante => vr_idpessoa_avt);
      FETCH cr_pessoa_fisica_rep INTO rw_pessoa_fisica_rep;
      CLOSE cr_pessoa_fisica_rep;

      -- Se for uma exclusao
      IF pr_tpoperacao = 3 THEN
        -- Se encontrou registro na busca
        IF rw_pessoa_fisica_rep.nrseq_representante IS NOT NULL THEN
          -- Efetua a exclusao do registro
          cada0010.pc_exclui_pessoa_juridica_rep (pr_idpessoa           => vr_idpessoa,
                                                  pr_nrseq_representante   => rw_pessoa_fisica_rep.nrseq_representante,
                                                  pr_cdoperad_altera    => pr_cdoperad,
                                                  pr_cdcritic           => vr_cdcritic,
                                                  pr_dscritic           => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

      ELSE -- Se for alteracao ou inclusao

        -- Cadastrar/atualizar pessoa representante
        pc_pessoa_juridica_rep ( pr_crapavt     => pr_crapavt      --> Tabela de avalista atual
                                ,pr_idpessoa    => vr_idpessoa_avt --> Identificador de pessoa
                                ,pr_cdoperad    => pr_cdoperad     --> Operador que esta efetuando a operacao
                                ,pr_dscritic    => vr_dscritic);   --> Retorno de Erro

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        rw_pessoa_fisica_rep.idpessoa := vr_idpessoa;
        rw_pessoa_fisica_rep.idpessoa_representante := vr_idpessoa_avt;
        rw_pessoa_fisica_rep.persocio := pr_crapavt.persocio;
        CADA0011.pc_trata_representante( pr_dsproftl              => pr_crapavt.dsproftl,
                                         pt_tpcargo_representante => rw_pessoa_fisica_rep.tpcargo_representante,
                                         pr_dscritic              => vr_dscritic);
        rw_pessoa_fisica_rep.dtvigencia := pr_crapavt.dtvalida;
        rw_pessoa_fisica_rep.dtadmissao := pr_crapavt.dtadmsoc;
        rw_pessoa_fisica_rep.flgdependencia_economica := pr_crapavt.flgdepec;
        rw_pessoa_fisica_rep.cdoperad_altera := pr_cdoperad;

        -- Efetua a inclusao
        cada0010.pc_cadast_pessoa_juridica_rep(pr_pessoa_juridica_rep => rw_pessoa_fisica_rep
                                              ,pr_cdcritic            => vr_cdcritic
                                              ,pr_dscritic            => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      END IF;
    END IF;


  EXCEPTION
    WHEN vr_exc_saida THEN
      --> Apenas gerar alerta
      pc_gerar_alerta_pessoa(pr_cdcooper => pr_crapavt.cdcooper
                            ,pr_nrdconta => pr_crapavt.nrdconta
                            ,pr_idseqttl => pr_crapavt.nrctremp
                            ,pr_nmtabela => 'CRAPAVT'
                            ,pr_dsalerta => vr_dscritic);

    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_crapavt: '||SQLERRM;
  END pc_crapavt;

  -- Rotina para atualizacao da tabela de politico exposto (tbcadast_politico_exposto)
  PROCEDURE pc_politico_exposto( pr_politico_exposto  IN tbcadast_politico_exposto%ROWTYPE            --> Tabela de avalista atual
                                ,pr_tpoperacao        IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                ,pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                                ,pr_cdoperad          IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                                ,pr_dscritic         OUT VARCHAR2) IS               --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pc_politico_exposto
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para atualizacao da tabela de politico exposto(tbcadast_politico_exposto)
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    -- Buscar dados de pessoa politicamente exposta
    CURSOR cr_pessoa_polexp ( pr_idpessoa   tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_polexp pol
       WHERE pol.idpessoa  = pr_idpessoa;
    rw_pessoa_polexp cr_pessoa_polexp%ROWTYPE;

    -- Verificar se existe a pessoa juridica
    CURSOR cr_pessoa_juridica(pr_nrcnpj vwcadast_pessoa_juridica.nrcnpj%TYPE) IS
      SELECT *
        FROM vwcadast_pessoa_juridica
       WHERE nrcnpj   = pr_nrcnpj;
    rw_pessoa_juridica  cr_pessoa_juridica%ROWTYPE;

    -- Verificar se existe a pessoa fisica
    CURSOR cr_pessoa_fisica(pr_nrcpf vwcadast_pessoa_fisica.nrcpf%TYPE) IS
      SELECT *
        FROM vwcadast_pessoa_fisica
       WHERE nrcpf   = pr_nrcpf;
    rw_pessoa_fisica  cr_pessoa_fisica%ROWTYPE;


    rw_pessoa_jur cr_pessoa_jur%ROWTYPE;
    rw_pessoa_fis cr_pessoa_fis%ROWTYPE;
    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE;           -- Identificador de pessoa
    vr_idpessoa_emp    tbcadast_pessoa.idpessoa%TYPE;           -- Identificador de pessoa emp
    vr_idpessoa_poli    tbcadast_pessoa.idpessoa%TYPE;           -- Identificador de pessoa pol
    vr_flgcriar         BOOLEAN;

  BEGIN

    -- Se nao for informado o IDPESSOA, deve-se buscar
    IF pr_idpessoa IS NULL THEN
      -- Busca o ID PESSOA
      vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_politico_exposto.cdcooper,
                                     pr_nrdconta => pr_politico_exposto.nrdconta,
                                     pr_idseqttl => 1);
      IF vr_idpessoa IS NULL THEN
        vr_dscritic := 'Nao encontrado PESSOA para alteracao do politico exposto';
        RAISE vr_exc_saida;
      END IF;
    ELSE
      vr_idpessoa := pr_idpessoa;
    END IF;


    -- Buscar dados de pessoa politicamente exposta
    rw_pessoa_polexp := NULL;
    OPEN cr_pessoa_polexp ( pr_idpessoa   => vr_idpessoa);
    FETCH cr_pessoa_polexp INTO rw_pessoa_polexp;
    CLOSE cr_pessoa_polexp;

    -- Se for uma exclusao
    IF pr_tpoperacao = 3 THEN
      -- Se encontrou registro na busca
      IF rw_pessoa_polexp.idpessoa IS NOT NULL THEN
        -- Efetua a exclusao do registro
        cada0010.pc_exclui_pessoa_polexp (pr_idpessoa         => vr_idpessoa,
                                          pr_cdoperad_altera  => pr_cdoperad,
                                          pr_cdcritic         => vr_cdcritic,
                                          pr_dscritic         => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

    ELSE -- Se for alteracao ou inclusao

      vr_idpessoa_emp := NULL;
      vr_flgcriar     := FALSE;
      rw_pessoa_juridica := NULL;
      vr_idpessoa_emp    := rw_pessoa_polexp.idpessoa_empresa;

      IF nvl(pr_politico_exposto.nrcnpj_empresa,0) > 0 THEN
        -- Busca o ID PESSOA da empresa politicamente exposta
        rw_pessoa_juridica := NULL;
        OPEN cr_pessoa_juridica (pr_nrcnpj => pr_politico_exposto.nrcnpj_empresa);
        FETCH cr_pessoa_juridica INTO rw_pessoa_juridica;
        CLOSE cr_pessoa_juridica;

        --> marcar para criar a pessoa juridica
        vr_flgcriar := TRUE;

      --> se possuir nome
      ELSIF TRIM(pr_politico_exposto.nmempresa) IS NOT NULL THEN

        --> Verificar a informação que ja esta cadastrada
        IF rw_pessoa_polexp.idpessoa_empresa > 0 THEN
          -- Buscar dados pessoa juridica
          OPEN cr_pessoa_jur(pr_idpessoa => rw_pessoa_polexp.idpessoa_empresa);
          FETCH cr_pessoa_jur INTO rw_pessoa_jur;
          CLOSE cr_pessoa_jur;

          --> se é outra pessoa deve criar
          IF nvl(pr_politico_exposto.nmempresa,' ') <> nvl(rw_pessoa_jur.nmpessoa,' ') THEN
            vr_flgcriar := TRUE;
          END IF;
        --> ou se nao tinha pessoa ainda cadastrada
        ELSE
          vr_flgcriar := TRUE;
        END IF;

      END IF;

      --> Verificar se deve criar
      IF vr_flgcriar = TRUE THEN
        IF pr_politico_exposto.nrcnpj_empresa <> 0 THEN
          rw_pessoa_juridica.nrcnpj           := pr_politico_exposto.nrcnpj_empresa;
        END IF;
        rw_pessoa_juridica.nmpessoa         := pr_politico_exposto.nmempresa;
        rw_pessoa_juridica.tppessoa         := nvl(rw_pessoa_juridica.tppessoa  ,2); -- Juridica
        rw_pessoa_juridica.tpcadastro       := nvl(rw_pessoa_juridica.tpcadastro,1); -- Prospect
        rw_pessoa_juridica.cdoperad_altera  := pr_cdoperad;

        -- Cria a pessoa juridica
        cada0010.pc_cadast_pessoa_juridica(pr_pessoa_juridica => rw_pessoa_juridica,
                                           pr_cdcritic      => vr_cdcritic,
                                           pr_dscritic      => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Atualiza o ID da pesssoa juridica
        vr_idpessoa_emp := rw_pessoa_juridica.idpessoa;

      END IF;

      vr_idpessoa_poli := NULL;
      vr_flgcriar      := FALSE;
      rw_pessoa_fisica := NULL;
      vr_idpessoa_poli := rw_pessoa_polexp.idpessoa_politico;

      IF nvl(pr_politico_exposto.nrcpf_politico,0) > 0 THEN

        -- Busca o ID PESSOA da pessoa politicamente exposta
        rw_pessoa_fisica := NULL;
        OPEN cr_pessoa_fisica (pr_nrcpf => pr_politico_exposto.nrcpf_politico);
        FETCH cr_pessoa_fisica INTO rw_pessoa_fisica;
        CLOSE cr_pessoa_fisica;

        vr_flgcriar := TRUE;

      --> se possuir nome
      ELSIF TRIM(pr_politico_exposto.nmpolitico) IS NOT NULL THEN

        --> Verificar a informação que ja esta cadastrada
        IF rw_pessoa_polexp.idpessoa_politico > 0 THEN
          -- Buscar dados pessoa fisica
          OPEN cr_pessoa_fis(pr_idpessoa => rw_pessoa_polexp.idpessoa_politico);
          FETCH cr_pessoa_fis INTO rw_pessoa_fis;
          CLOSE cr_pessoa_fis;

          --> se é outra pessoa deve criar
          IF nvl(pr_politico_exposto.nmpolitico,' ') <> nvl(rw_pessoa_fis.nmpessoa,' ') THEN
            vr_flgcriar := TRUE;
          END IF;
        --> ou se nao tinha pessoa ainda cadastrada
        ELSE
          vr_flgcriar := TRUE;
        END IF;
      END IF;

      --> Verificar se deve criar
      IF vr_flgcriar = TRUE THEN
        IF pr_politico_exposto.nrcpf_politico <> 0 THEN
          rw_pessoa_fisica.nrcpf            := pr_politico_exposto.nrcpf_politico;
        END IF;
        rw_pessoa_fisica.nmpessoa         := pr_politico_exposto.nmpolitico;
        rw_pessoa_fisica.tppessoa         := nvl(rw_pessoa_fisica.tppessoa  ,1); -- Juridica
        rw_pessoa_fisica.tpcadastro       := nvl(rw_pessoa_fisica.tpcadastro,1); -- Prospect
        rw_pessoa_fisica.cdoperad_altera  := pr_cdoperad;

        -- Cria a pessoa fisica
        cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => rw_pessoa_fisica,
                                           pr_cdcritic      => vr_cdcritic,
                                           pr_dscritic      => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Atualiza o ID da pesssoa fisica
        vr_idpessoa_poli := rw_pessoa_fisica.idpessoa;
      END IF;

      rw_pessoa_polexp.idpessoa          := vr_idpessoa;
      rw_pessoa_polexp.tpexposto         := pr_politico_exposto.tpexposto;
      rw_pessoa_polexp.dtinicio          := pr_politico_exposto.dtinicio;
      rw_pessoa_polexp.dttermino         := pr_politico_exposto.dttermino;
      rw_pessoa_polexp.idpessoa_empresa  := vr_idpessoa_emp;
      rw_pessoa_polexp.cdocupacao        := pr_politico_exposto.cdocupacao;
      rw_pessoa_polexp.tprelacao_polexp  := pr_politico_exposto.tpexposto;
      rw_pessoa_polexp.idpessoa_politico := vr_idpessoa_poli;
      rw_pessoa_polexp.cdoperad_altera   := pr_cdoperad;

      -- Efetua a inclusao/alteracao
      cada0010.pc_cadast_pessoa_polexp(pr_pessoa_polexp => rw_pessoa_polexp
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;


  EXCEPTION
    WHEN vr_exc_saida THEN
      --> Apenas gerar alerta
      pc_gerar_alerta_pessoa(pr_cdcooper => pr_politico_exposto.cdcooper
                            ,pr_nrdconta => pr_politico_exposto.nrdconta
                            ,pr_idseqttl => pr_politico_exposto.idseqttl
                            ,pr_nmtabela => 'tbcadast_politico_exposto'
                            ,pr_dsalerta => vr_dscritic);


    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_politico_exposto: '||SQLERRM;
  END pc_politico_exposto;

  -- Rotina para atualizacao da tabela de dados financeiros banco(CRAPJFN)
  PROCEDURE pc_pessoa_jur_bco( pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                              ,pr_crapjfn     IN crapjfn%ROWTYPE            --> Tabela de email atual
                              ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                              ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                              ,pr_dscritic   OUT VARCHAR2) IS               --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pc_pessoa_jur_bco
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para atualizacao da tabela de dados financeiros banco (CRAPJFN)
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    --> buscar dados financeiros de pessoa juridica em outros bancos.
    CURSOR cr_pessoa_bco (pr_idpessoa    tbcadast_pessoa.idpessoa%TYPE,
                          pr_nrseq_banco tbcadast_pessoa_juridica_bco.nrseq_banco%TYPE)IS
      SELECT *
        FROM tbcadast_pessoa_juridica_bco bco
       WHERE bco.idpessoa    = pr_idpessoa
         AND bco.nrseq_banco = decode(pr_nrseq_banco,0,bco.nrseq_banco,pr_nrseq_banco);
    rw_pessoa_bco cr_pessoa_bco%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE; -- Identificador de pessoa

  BEGIN

    -- Se nao for informado o IDPESSOA, deve-se buscar
    IF pr_idpessoa IS NULL THEN
      -- Busca o ID PESSOA do email
      vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapjfn.cdcooper,
                                     pr_nrdconta => pr_crapjfn.nrdconta,
                                     pr_idseqttl => 1);
      IF vr_idpessoa IS NULL THEN
        vr_dscritic := 'Nao encontrado PESSOA para alteracao de dados financeiros';
        RAISE vr_exc_erro;
      END IF;
    ELSE
      vr_idpessoa := pr_idpessoa;
    END IF;

    -- Se for uma exclusao
    IF pr_tpoperacao = 3 THEN

      --> buscar dados financeiros de pessoa juridica em outros bancos.
      FOR rw_pessoa_bco IN cr_pessoa_bco (pr_idpessoa    => vr_idpessoa,
                                          pr_nrseq_banco => 0) LOOP

        -- Excluir registro
        cada0010.pc_exclui_pessoa_juridica_bco (pr_idpessoa    => vr_idpessoa,
                                                pr_nrseq_banco => rw_pessoa_bco.nrseq_banco,
                                                pr_cdoperad_altera    => pr_cdoperad,
                                                pr_cdcritic    => vr_cdcritic,
                                                pr_dscritic    => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END LOOP;

    ELSE -- Se for alteracao ou inclusao

      -- efetua loop sobre os registros
      FOR x IN 1..5 LOOP

        -- Inicializa a variavel
        OPEN cr_pessoa_bco (pr_idpessoa    => vr_idpessoa,
                            pr_nrseq_banco => x);
        FETCH cr_pessoa_bco INTO rw_pessoa_bco;
        CLOSE cr_pessoa_bco;

        rw_pessoa_bco.idpessoa := pr_idpessoa;
        rw_pessoa_bco.cdoperad_altera := pr_cdoperad;
        rw_pessoa_bco.nrseq_banco := x;

        -- Verifica qual o banco devera ser utilizado
        IF x = 1 THEN

          rw_pessoa_bco.cdbanco      := pr_crapjfn.cddbanco##1;
          rw_pessoa_bco.dsoperacao   := pr_crapjfn.dstipope##1;
          rw_pessoa_bco.vloperacao   := pr_crapjfn.vlropera##1;
          rw_pessoa_bco.dsgarantia   := pr_crapjfn.garantia##1;
          -- Feito o processo abaixo, pois dentro do DSVENCTO pode vir escrito VARIOS
          BEGIN
            rw_pessoa_bco.dtvencimento := pr_crapjfn.dsvencto##1;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        ELSIF x = 2 THEN
          rw_pessoa_bco.cdbanco      := pr_crapjfn.cddbanco##2;
          rw_pessoa_bco.dsoperacao   := pr_crapjfn.dstipope##2;
          rw_pessoa_bco.vloperacao   := pr_crapjfn.vlropera##2;
          rw_pessoa_bco.dsgarantia   := pr_crapjfn.garantia##2;
          -- Feito o processo abaixo, pois dentro do DSVENCTO pode vir escrito VARIOS
          BEGIN
            rw_pessoa_bco.dtvencimento := pr_crapjfn.dsvencto##2;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        ELSIF x = 3 THEN
          rw_pessoa_bco.cdbanco      := pr_crapjfn.cddbanco##3;
          rw_pessoa_bco.dsoperacao   := pr_crapjfn.dstipope##3;
          rw_pessoa_bco.vloperacao   := pr_crapjfn.vlropera##3;
          rw_pessoa_bco.dsgarantia   := pr_crapjfn.garantia##3;
          -- Feito o processo abaixo, pois dentro do DSVENCTO pode vir escrito VARIOS
          BEGIN
            rw_pessoa_bco.dtvencimento := pr_crapjfn.dsvencto##3;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        ELSIF x = 4 THEN
          rw_pessoa_bco.cdbanco      := pr_crapjfn.cddbanco##4;
          rw_pessoa_bco.dsoperacao   := pr_crapjfn.dstipope##4;
          rw_pessoa_bco.vloperacao   := pr_crapjfn.vlropera##4;
          rw_pessoa_bco.dsgarantia   := pr_crapjfn.garantia##4;
          -- Feito o processo abaixo, pois dentro do DSVENCTO pode vir escrito VARIOS
          BEGIN
            rw_pessoa_bco.dtvencimento := pr_crapjfn.dsvencto##4;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        ELSE
          rw_pessoa_bco.cdbanco      := pr_crapjfn.cddbanco##5;
          rw_pessoa_bco.dsoperacao   := pr_crapjfn.dstipope##5;
          rw_pessoa_bco.vloperacao   := pr_crapjfn.vlropera##5;
          rw_pessoa_bco.dsgarantia   := pr_crapjfn.garantia##5;
          -- Feito o processo abaixo, pois dentro do DSVENCTO pode vir escrito VARIOS
          BEGIN
            rw_pessoa_bco.dtvencimento := pr_crapjfn.dsvencto##5;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        END IF;

        -- Verifica se existe informacao
        IF nvl(rw_pessoa_bco.cdbanco,0) <> 0 THEN
          -- Efetua a inclusao
          cada0010.pc_cadast_pessoa_juridica_bco(pr_pessoa_juridica_bco => rw_pessoa_bco
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

        --> se banco esta zerado, porém possuia dados, é necessario exluir informação
        ELSIF rw_pessoa_bco.nrseq_banco > 0 THEN
          -- Excluir registro
          cada0010.pc_exclui_pessoa_juridica_bco (pr_idpessoa    => vr_idpessoa,
                                                  pr_nrseq_banco => rw_pessoa_bco.nrseq_banco,
                                                  pr_cdoperad_altera    => pr_cdoperad,
                                                  pr_cdcritic    => vr_cdcritic,
                                                  pr_dscritic    => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

      END LOOP;

    END IF;

	EXCEPTION
    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_pessoa_jur_bco: '||SQLERRM;
  END pc_pessoa_jur_bco;

  -- Rotina para atualizacao da tabela de dados de faturamento(CRAPJFN)
  PROCEDURE pc_pessoa_jur_fat( pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                              ,pr_crapjfn     IN crapjfn%ROWTYPE            --> Tabela de email atual
                              ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                              ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                              ,pr_dscritic   OUT VARCHAR2) IS               --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pc_pessoa_jur_fat
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para atualizacao da tabela de dados de faturamento(CRAPJFN)
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    --> buscar dados de faturamento mensal de Pessoas Juridica
    CURSOR cr_pessoa_fat (pr_idpessoa    tbcadast_pessoa.idpessoa%TYPE,
                          pr_nrseq_fat   tbcadast_pessoa_juridica_fat.nrseq_faturamento%TYPE)IS
      SELECT *
        FROM tbcadast_pessoa_juridica_fat fat
       WHERE fat.idpessoa          = pr_idpessoa
         AND fat.nrseq_faturamento = decode(pr_nrseq_fat,0,fat.nrseq_faturamento,pr_nrseq_fat);
    rw_pessoa_fat cr_pessoa_fat%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE; -- Identificador de pessoa

  BEGIN

    -- Se nao for informado o IDPESSOA, deve-se buscar
    IF pr_idpessoa IS NULL THEN
      -- Busca o ID PESSOA do email
      vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapjfn.cdcooper,
                                     pr_nrdconta => pr_crapjfn.nrdconta,
                                     pr_idseqttl => 1);
      IF vr_idpessoa IS NULL THEN
        vr_dscritic := 'Nao encontrado PESSOA para alteracao de dados financeiros';
        RAISE vr_exc_erro;
      END IF;
    ELSE
      vr_idpessoa := pr_idpessoa;
    END IF;

    -- Se for uma exclusao
    IF pr_tpoperacao = 3 THEN

      --> buscar dados de faturamento mensal de Pessoas Juridica
      FOR rw_pessoa_fat IN cr_pessoa_fat (pr_idpessoa  => vr_idpessoa,
                                          pr_nrseq_fat => 0) LOOP

        -- Excluir registro
        cada0010.pc_exclui_pessoa_juridica_fat (pr_idpessoa    => vr_idpessoa,
                                                pr_nrseq_faturamento  => rw_pessoa_fat.nrseq_faturamento,
                                                pr_cdoperad_altera    => pr_cdoperad,
                                                pr_cdcritic    => vr_cdcritic,
                                                pr_dscritic    => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END LOOP;

    ELSE -- Se for alteracao ou inclusao

      -- Efetua loop sobre os registros
      FOR x IN 1..12 LOOP
        rw_pessoa_fat := NULL;
        -- Inicializa a variavel
        OPEN cr_pessoa_fat (pr_idpessoa  => vr_idpessoa,
                            pr_nrseq_fat => x);
        FETCH cr_pessoa_fat INTO rw_pessoa_fat;
        CLOSE cr_pessoa_fat;

        -- Inicializa a variavel
        rw_pessoa_fat.idpessoa          := pr_idpessoa;
        rw_pessoa_fat.cdoperad_altera   := pr_cdoperad;
        rw_pessoa_fat.nrseq_faturamento := x;

        -- Verifica qual o banco devera ser utilizado
        IF x = 1 THEN
          -- Feito o processo abaixo, pois pode gerar uma data invalida
          BEGIN
            rw_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##1,'fm00')||
                                                      pr_crapjfn.anoftbru##1,'MMYYYY');
          EXCEPTION
            WHEN OTHERS THEN
              rw_pessoa_fat.dtmes_referencia := NULL;
          END;
          rw_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##1;

        ELSIF x = 2 THEN
          -- Feito o processo abaixo, pois pode gerar uma data invalida
          BEGIN
            rw_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##2,'fm00')||
                                                      pr_crapjfn.anoftbru##2,'MMYYYY');
          EXCEPTION
            WHEN OTHERS THEN
              rw_pessoa_fat.dtmes_referencia := NULL;

          END;
          rw_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##2;

        ELSIF x = 3 THEN
          -- Feito o processo abaixo, pois pode gerar uma data invalida
          BEGIN
            rw_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##3,'fm00')||
                                                      pr_crapjfn.anoftbru##3,'MMYYYY');
          EXCEPTION
            WHEN OTHERS THEN
              rw_pessoa_fat.dtmes_referencia := NULL;
          END;
          rw_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##3;

        ELSIF x = 4 THEN
          -- Feito o processo abaixo, pois pode gerar uma data invalida
          BEGIN
            rw_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##4,'fm00')||
                                                      pr_crapjfn.anoftbru##4,'MMYYYY');
          EXCEPTION
            WHEN OTHERS THEN
              rw_pessoa_fat.dtmes_referencia := NULL;
          END;
          rw_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##4;

        ELSIF x = 5 THEN
          -- Feito o processo abaixo, pois pode gerar uma data invalida
          BEGIN
            rw_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##5,'fm00')||
                                                      pr_crapjfn.anoftbru##5,'MMYYYY');
          EXCEPTION
            WHEN OTHERS THEN
              rw_pessoa_fat.dtmes_referencia := NULL;
          END;
          rw_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##5;

        ELSIF x = 6 THEN
          -- Feito o processo abaixo, pois pode gerar uma data invalida
          BEGIN
            rw_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##6,'fm00')||
                                                      pr_crapjfn.anoftbru##6,'MMYYYY');
          EXCEPTION
            WHEN OTHERS THEN
              rw_pessoa_fat.dtmes_referencia := NULL;
          END;
          rw_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##6;

        ELSIF x = 7 THEN
          -- Feito o processo abaixo, pois pode gerar uma data invalida
          BEGIN
            rw_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##7,'fm00')||
                                                      pr_crapjfn.anoftbru##7,'MMYYYY');
          EXCEPTION
            WHEN OTHERS THEN
              rw_pessoa_fat.dtmes_referencia := NULL;
          END;
          rw_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##7;

        ELSIF x = 8 THEN
          -- Feito o processo abaixo, pois pode gerar uma data invalida
          BEGIN
            rw_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##8,'fm00')||
                                                      pr_crapjfn.anoftbru##8,'MMYYYY');
          EXCEPTION
            WHEN OTHERS THEN
              rw_pessoa_fat.dtmes_referencia := NULL;
          END;
          rw_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##8;

        ELSIF x = 9 THEN
          -- Feito o processo abaixo, pois pode gerar uma data invalida
          BEGIN
            rw_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##9,'fm00')||
                                                      pr_crapjfn.anoftbru##9,'MMYYYY');
          EXCEPTION
            WHEN OTHERS THEN
              rw_pessoa_fat.dtmes_referencia := NULL;
          END;
          rw_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##9;

        ELSIF x = 10 THEN
          -- Feito o processo abaixo, pois pode gerar uma data invalida
          BEGIN
            rw_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##10,'fm00')||
                                                      pr_crapjfn.anoftbru##10,'MMYYYY');
          EXCEPTION
            WHEN OTHERS THEN
              rw_pessoa_fat.dtmes_referencia := NULL;
          END;
          rw_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##10;

        ELSIF x = 11 THEN
          -- Feito o processo abaixo, pois pode gerar uma data invalida
          BEGIN
            rw_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##11,'fm00')||
                                                      pr_crapjfn.anoftbru##11,'MMYYYY');
          EXCEPTION
            WHEN OTHERS THEN
              rw_pessoa_fat.dtmes_referencia := NULL;
          END;
          rw_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##11;

        ELSE
          -- Feito o processo abaixo, pois pode gerar uma data invalida
          BEGIN
            rw_pessoa_fat.dtmes_referencia := to_date(to_char(pr_crapjfn.mesftbru##12,'fm00')||
                                                      pr_crapjfn.anoftbru##12,'MMYYYY');
          EXCEPTION
            WHEN OTHERS THEN
              rw_pessoa_fat.dtmes_referencia := NULL;
          END;
          rw_pessoa_fat.vlfaturamento_bruto := pr_crapjfn.vlrftbru##12;
        END IF;

        -- Verifica se existe informacao
        IF rw_pessoa_fat.dtmes_referencia IS NOT NULL THEN
          -- Efetua a inclusao
          cada0010.pc_cadast_pessoa_juridica_fat(pr_pessoa_juridica_fat => rw_pessoa_fat
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

        --> se data esta vazia, porém possuia dados, é necessario exluir informação
        ELSIF rw_pessoa_fat.nrseq_faturamento > 0 THEN
          -- Excluir registro
          cada0010.pc_exclui_pessoa_juridica_fat (pr_idpessoa    => vr_idpessoa,
                                                  pr_nrseq_faturamento => rw_pessoa_fat.nrseq_faturamento,
                                                  pr_cdoperad_altera   => pr_cdoperad,
                                                  pr_cdcritic    => vr_cdcritic,
                                                  pr_dscritic    => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

      END LOOP;

    END IF;

	EXCEPTION
    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_pessoa_jur_fat: '||SQLERRM;
  END pc_pessoa_jur_fat;


  -- Rotina para atualizacao da tabela de dados financeiros (CRAPJFN)
  PROCEDURE pc_crapjfn(pr_crapjfn     IN crapjfn%ROWTYPE            --> Tabela de email atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2) IS               --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pc_crapjfn
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para atualizacao da tabela de dados financeiros (CRAPJFN)
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    rw_pessoa_jur  cr_pessoa_jur%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE; -- Identificador de pessoa

  BEGIN

    -- Se nao for informado o IDPESSOA, deve-se buscar
    IF pr_idpessoa IS NULL THEN
      -- Busca o ID PESSOA do email
      vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapjfn.cdcooper,
                                     pr_nrdconta => pr_crapjfn.nrdconta,
                                     pr_idseqttl => 1);
      IF vr_idpessoa IS NULL THEN
        vr_dscritic := 'Nao encontrado PESSOA para alteracao de dados financeiros';
        RAISE vr_exc_saida;
      END IF;
    ELSE
      vr_idpessoa := pr_idpessoa;
    END IF;

    -- Buscar dados pessoa juridica
    OPEN cr_pessoa_jur(pr_idpessoa => vr_idpessoa);
    FETCH cr_pessoa_jur INTO rw_pessoa_jur;
    CLOSE cr_pessoa_jur;

    -- Se for uma exclusao
    IF pr_tpoperacao = 3 THEN

      --> limpar dados
      rw_pessoa_jur.peunico_cliente          := 0;
      rw_pessoa_jur.vlreceita_bruta          := 0;
      rw_pessoa_jur.vlcusto_despesa_adm      := 0;
      rw_pessoa_jur.vldespesa_administrativa := 0;
      rw_pessoa_jur.qtdias_recebimento       := 0;
      rw_pessoa_jur.qtdias_pagamento         := 0;
      rw_pessoa_jur.vlativo_caixa_banco_apl  := 0;
      rw_pessoa_jur.vlativo_contas_receber   := 0;
      rw_pessoa_jur.vlativo_estoque          := 0;
      rw_pessoa_jur.vlativo_imobilizado      := 0;
      rw_pessoa_jur.vlativo_outros           := 0;
      rw_pessoa_jur.vlpassivo_fornecedor     := 0;
      rw_pessoa_jur.vlpassivo_divida_bancaria:= 0;
      rw_pessoa_jur.vlpassivo_outros         := 0;
      rw_pessoa_jur.dtmes_base               := NULL;

      -- Insere o Cadastro de pessoa fisica
      cada0010.pc_cadast_pessoa_juridica(pr_pessoa_juridica => rw_pessoa_jur,
                                         pr_cdcritic        => vr_cdcritic,
                                         pr_dscritic        => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    ELSE -- Se for alteracao ou inclusao

      rw_pessoa_jur.peunico_cliente          := pr_crapjfn.perfatcl;
      rw_pessoa_jur.vlreceita_bruta          := pr_crapjfn.vlrctbru;
      rw_pessoa_jur.vlcusto_despesa_adm      := pr_crapjfn.vlctdpad;
      rw_pessoa_jur.vldespesa_administrativa := pr_crapjfn.vldspfin;
      rw_pessoa_jur.qtdias_recebimento       := pr_crapjfn.ddprzrec;
      rw_pessoa_jur.qtdias_pagamento         := pr_crapjfn.ddprzpag;
      rw_pessoa_jur.vlativo_caixa_banco_apl  := pr_crapjfn.vlcxbcaf;
      rw_pessoa_jur.vlativo_contas_receber   := pr_crapjfn.vlctarcb;
      rw_pessoa_jur.vlativo_estoque          := pr_crapjfn.vlrestoq;
      rw_pessoa_jur.vlativo_imobilizado      := pr_crapjfn.vlrimobi;
      rw_pessoa_jur.vlativo_outros           := pr_crapjfn.vloutatv;
      rw_pessoa_jur.vlpassivo_fornecedor     := pr_crapjfn.vlfornec;
      rw_pessoa_jur.vlpassivo_divida_bancaria:= pr_crapjfn.vldivbco;
      rw_pessoa_jur.vlpassivo_outros         := pr_crapjfn.vloutpas;
      IF pr_crapjfn.mesdbase BETWEEN 1 AND 12 AND
         pr_crapjfn.anodbase BETWEEN 1900 AND (to_char(SYSDATE,'YYYY')+1) THEN
        rw_pessoa_jur.dtmes_base             := to_date(to_char(pr_crapjfn.mesdbase,'fm00')||
                                                        pr_crapjfn.anodbase,'MMYYYY');
      END IF;

      -- Insere o Cadastro de pessoa fisica
      cada0010.pc_cadast_pessoa_juridica(pr_pessoa_juridica => rw_pessoa_jur,
                                         pr_cdcritic        => vr_cdcritic,
                                         pr_dscritic        => vr_dscritic);
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    --> Atualizacao da tabela de dados financeiros banco(CRAPJFN)
    pc_pessoa_jur_bco( pr_idpessoa    => vr_idpessoa     --> Identificador de pessoa
                      ,pr_crapjfn     => pr_crapjfn      --> Tabela de email atual
                      ,pr_tpoperacao  => pr_tpoperacao   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_cdoperad    => pr_cdoperad     --> Operador que esta efetuando a operacao
                      ,pr_dscritic    => vr_dscritic  ); --> Retorno de Erro

    IF  TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --> Atualizacao da tabela de dados de faturamento(CRAPJFN)
    pc_pessoa_jur_fat( pr_idpessoa    => vr_idpessoa     --> Identificador de pessoa
                      ,pr_crapjfn     => pr_crapjfn      --> Tabela de email atual
                      ,pr_tpoperacao  => pr_tpoperacao   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_cdoperad    => pr_cdoperad     --> Operador que esta efetuando a operacao
                      ,pr_dscritic    => vr_dscritic  ); --> Retorno de Erro

    IF  TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

	EXCEPTION
    WHEN vr_exc_saida THEN
      --> Apenas gerar alerta
      pc_gerar_alerta_pessoa(pr_cdcooper => pr_crapjfn.cdcooper
                            ,pr_nrdconta => pr_crapjfn.nrdconta
                            ,pr_idseqttl => 1
                            ,pr_nmtabela => 'CRAPJFN'
                            ,pr_dsalerta => vr_dscritic);

    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_crapjfn: '||SQLERRM;
  END pc_crapjfn;

  -- Rotina para atualizacao da tabela renda do titular (CRAPTTL)
  PROCEDURE pc_pessoa_renda( pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                            ,pr_crapttl     IN crapttl%ROWTYPE            --> Tabela de titular atual
                            ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                            ,pr_dscritic   OUT VARCHAR2) IS               --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pc_pessoa_renda
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 06/09/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para atualizacao da tabela renda do titular (CRAPTTL)
    --
    --  Alteração : 	06/09/2018 - Ajustes nas rotinas envolvidas na unificação cadastral e CRM para
		--						                 corrigir antigos e evitar futuros problemas. (INC002926 - Kelvin)
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    --> Retornar dados pessoa renda
    CURSOR cr_pessoa_renda (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_renda ren
       WHERE ren.idpessoa = pr_idpessoa;
    rw_pessoa_renda cr_pessoa_renda%ROWTYPE;

    --> Retornar dados pessoa pelo id
    CURSOR cr_pessoa_id (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa;

    -- Cursor para verificar se existe a pessoa juridica
    CURSOR cr_pessoa_juridica(pr_nrcnpj vwcadast_pessoa_juridica.nrcnpj%TYPE) IS
      SELECT *
        FROM vwcadast_pessoa_juridica
       WHERE nrcnpj   = pr_nrcnpj;
    rw_pessoa_juridica  cr_pessoa_juridica%ROWTYPE;
    rw_pessoa_jur_fonte cr_pessoa_juridica%ROWTYPE;

    -- Verificar se existe a pessoa fisica
    CURSOR cr_pessoa_fisica(pr_nrcpf vwcadast_pessoa_fisica.nrcpf%TYPE) IS
      SELECT *
        FROM vwcadast_pessoa_fisica
       WHERE nrcpf   = pr_nrcpf;
    rw_pessoa_fisica  cr_pessoa_fisica%ROWTYPE;

    --> Retornar dados pessoa renda complementar
    CURSOR cr_pessoa_rendacompl ( pr_idpessoa    tbcadast_pessoa.idpessoa%TYPE,
                                  pr_nrseq_renda tbcadast_pessoa_rendacompl.nrseq_renda%TYPE) IS
      SELECT *
        FROM tbcadast_pessoa_rendacompl ren
       WHERE ren.idpessoa    = pr_idpessoa
         AND ren.nrseq_renda = pr_nrseq_renda;
    rw_pessoa_rendacompl cr_pessoa_rendacompl%ROWTYPE;


    rw_pessoa cr_pessoa%ROWTYPE;
    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_flcria_empresa  BOOLEAN := FALSE;
  BEGIN

    --> Retornar dados pessoa renda
    rw_pessoa_renda := NULL;
    OPEN cr_pessoa_renda (pr_idpessoa => pr_idpessoa);
    FETCH cr_pessoa_renda INTO rw_pessoa_renda;
    CLOSE cr_pessoa_renda;

    -- Se possuir CNPJ, verifica se esta cadastrado
    IF nvl(pr_crapttl.nrcpfemp,0) > 0 THEN

      -- Verifica se existe a pessoaPJ
      OPEN cr_pessoa(pr_nrcpfcgc => pr_crapttl.nrcpfemp);
      FETCH cr_pessoa INTO rw_pessoa;
      -- Se nao existir, tem que criar
      IF cr_pessoa%NOTFOUND THEN
        -- Atualiza o indicador para criar o CNPJ
        vr_flcria_empresa := TRUE;

      ELSE -- Se encontrou a pessoa juridica
        --> se o nome estiver diferente, é necessario atualizar pessoa
        IF substr(nvl(pr_crapttl.nmextemp,' '),1,40) <> substr(nvl(rw_pessoa.nmpessoa,' '),1,40) AND
           NVL(rw_pessoa.tpcadastro,4) NOT IN (3,4) THEN
          vr_flcria_empresa := TRUE;
        END IF;
        -- Atualiza o ID da pessoa juridica
        rw_pessoa_renda.idpessoa_fonte_renda := rw_pessoa.idpessoa;
      END IF;
      CLOSE cr_pessoa;

    ELSE

      -- Verifica se existe PJ
      OPEN cr_pessoa_id(pr_idpessoa => rw_pessoa_renda.idpessoa_fonte_renda);
      FETCH cr_pessoa_id INTO rw_pessoa;
      CLOSE cr_pessoa_id;

      -- Feito a validacao abaixo para nao cortar o final do nome da pessoa
      IF substr(nvl(pr_crapttl.nmextemp,' '),1,40) <> substr(nvl(rw_pessoa.nmpessoa,' '),1,40) AND
         NVL(rw_pessoa.tpcadastro,4) NOT IN (3,4) THEN
        -- Atualiza o indicador para criar o CNPJ
        vr_flcria_empresa := TRUE;
      END IF;
    END IF;

    -- Se o indicador de criacao/atualizacao de empresa estiver ligado
    IF vr_flcria_empresa THEN

      -- Verifica se a empresa eh uma pessoa fisica ou juridica
      -- Se o CNPJ nao bater com o calculado
      IF nvl(pr_crapttl.nrcpfemp,0) > 0 AND
         SUBSTR(pr_crapttl.nrcpfemp,LENGTH(pr_crapttl.nrcpfemp)-1) <> gene0005.fn_retorna_digito_cnpj(pr_nrcalcul => SUBSTR(pr_crapttl.nrcpfemp,1,LENGTH(pr_crapttl.nrcpfemp)-2)) THEN

        rw_pessoa_fisica := NULL;
        OPEN cr_pessoa_fisica(pr_nrcpf => pr_crapttl.nrcpfemp);
        FETCH cr_pessoa_fisica INTO rw_pessoa_fisica;
        CLOSE cr_pessoa_fisica;

        -- Popula os dados para PF
        rw_pessoa_fisica.nrcpf                := pr_crapttl.nrcpfemp;
        
        -- Feito a validacao abaixo para nao cortar o final do nome da pessoa
        IF substr(nvl(pr_crapttl.nmextemp,' '),1,40) <> substr(nvl(rw_pessoa_fisica.nmpessoa,' '),1,40) THEN
          rw_pessoa_fisica.nmpessoa             := pr_crapttl.nmextemp;
        END IF;
        rw_pessoa_fisica.tppessoa             := nvl(rw_pessoa_fisica.tppessoa  ,1); -- Fisica
        rw_pessoa_fisica.tpcadastro           := nvl(rw_pessoa_fisica.tpcadastro,1); -- Prospect
        rw_pessoa_fisica.cdoperad_altera      := pr_cdoperad;

        -- Andrino
        -- Se a empresa de trabalho possuir o mesmo CPF do titular e o nome for diferente,
        -- deve-se alterar o nome da empresa
        IF pr_crapttl.nrcpfcgc > 0 AND
           pr_crapttl.nrcpfcgc = pr_crapttl.nrcpfemp THEN
           -- Utiliza o nome do titular, e nao o da empresa
           -- Isso eh necessario, pois se nao fizer isso quando altera o nome do titular
           -- esta rotina volta ao nome anterior
          rw_pessoa_fisica.nmpessoa             := pr_crapttl.nmextttl;
        END IF;

        -- Cria a pessoa fisica
        cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => rw_pessoa_fisica,
                                         pr_cdcritic      => vr_cdcritic,
                                         pr_dscritic      => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Atualiza o ID da pesssoa juridica
        rw_pessoa_renda.idpessoa_fonte_renda := rw_pessoa_fisica.idpessoa;

      ELSE

        rw_pessoa_juridica := NULL;
        OPEN cr_pessoa_juridica(pr_nrcnpj => pr_crapttl.nrcpfemp);
        FETCH cr_pessoa_juridica INTO rw_pessoa_juridica;
        CLOSE cr_pessoa_juridica;

        -- Popula os dados de pessoa juridica
        -- Feito a validacao abaixo para nao cortar o final do nome da pessoa
        IF substr(nvl(pr_crapttl.nmextemp,' '),1,40) <> substr(nvl(rw_pessoa_juridica.nmpessoa,' '),1,40) THEN
          rw_pessoa_juridica.nmpessoa             := pr_crapttl.nmextemp;
        END IF;
        
        IF pr_crapttl.nrcpfemp <> 0 THEN
          rw_pessoa_juridica.nrcnpj               := pr_crapttl.nrcpfemp;
        END IF;
        rw_pessoa_juridica.tppessoa             := nvl(rw_pessoa_juridica.tppessoa,2);   -- Juridica
        rw_pessoa_juridica.tpcadastro           := nvl(rw_pessoa_juridica.tpcadastro,1); -- Prospect
        rw_pessoa_juridica.cdoperad_altera      := pr_cdoperad;
        -- Cria a pessoa juridica
        cada0010.pc_cadast_pessoa_juridica(pr_pessoa_juridica => rw_pessoa_juridica,
                                           pr_cdcritic      => vr_cdcritic,
                                           pr_dscritic      => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Atualiza com o ID pessoa que foi criado
        rw_pessoa_renda.idpessoa_fonte_renda := rw_pessoa_juridica.idpessoa;
      END IF;
    END IF;

    -- Popula os campos para inserir o registro
    rw_pessoa_renda.idpessoa             := pr_idpessoa;
    rw_pessoa_renda.nrseq_renda          := 1;
    rw_pessoa_renda.tpcontrato_trabalho  := pr_crapttl.tpcttrab;
    rw_pessoa_renda.cdturno              := pr_crapttl.cdturnos;
    rw_pessoa_renda.cdnivel_cargo        := pr_crapttl.cdnvlcgo;
    rw_pessoa_renda.dtadmissao           := pr_crapttl.dtadmemp;
    IF pr_crapttl.cdocpttl <> 0 THEN
      rw_pessoa_renda.cdocupacao           := pr_crapttl.cdocpttl;
    END IF;
    rw_pessoa_renda.nrcadastro           := pr_crapttl.nrcadast;
    rw_pessoa_renda.vlrenda              := pr_crapttl.vlsalari;
    rw_pessoa_renda.cdoperad_altera      := pr_cdoperad;

    -- Efetua a inclusao
    cada0010.pc_cadast_pessoa_renda(pr_pessoa_renda => rw_pessoa_renda
                                   ,pr_cdcritic     => vr_cdcritic
                                   ,pr_dscritic     => vr_dscritic);
    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Loop sobre o total de rendimentos possiveis
    FOR x IN 1..6 LOOP

      -- Inicializa a variavel
      rw_pessoa_rendacompl := NULL;

      --> Retornar dados pessoa renda complementar
      OPEN cr_pessoa_rendacompl ( pr_idpessoa    => pr_idpessoa,
                                  pr_nrseq_renda => x);
      FETCH cr_pessoa_rendacompl INTO rw_pessoa_rendacompl;
      CLOSE cr_pessoa_rendacompl;

      -- Verifica qual o rendimento devera ser utilizado
      IF x = 1 THEN
        rw_pessoa_rendacompl.tprenda := pr_crapttl.tpdrendi##1;
        rw_pessoa_rendacompl.vlrenda := pr_crapttl.vldrendi##1;
      ELSIF x = 2 THEN
        rw_pessoa_rendacompl.tprenda := pr_crapttl.tpdrendi##2;
        rw_pessoa_rendacompl.vlrenda := pr_crapttl.vldrendi##2;
      ELSIF x = 3 THEN
        rw_pessoa_rendacompl.tprenda := pr_crapttl.tpdrendi##3;
        rw_pessoa_rendacompl.vlrenda := pr_crapttl.vldrendi##3;
      ELSIF x = 4 THEN
        rw_pessoa_rendacompl.tprenda := pr_crapttl.tpdrendi##4;
        rw_pessoa_rendacompl.vlrenda := pr_crapttl.vldrendi##4;
      ELSIF x = 5 THEN
        rw_pessoa_rendacompl.tprenda := pr_crapttl.tpdrendi##5;
        rw_pessoa_rendacompl.vlrenda := pr_crapttl.vldrendi##5;
      ELSE
        rw_pessoa_rendacompl.tprenda := pr_crapttl.tpdrendi##6;
        rw_pessoa_rendacompl.vlrenda := pr_crapttl.vldrendi##6;
      END IF;

      -- somente efetua a inclusao se o valor for superior a zeros
      IF rw_pessoa_rendacompl.vlrenda > 0 THEN
        -- Popula os campos para inserir o registro
        rw_pessoa_rendacompl.idpessoa        := pr_idpessoa;
        rw_pessoa_rendacompl.nrseq_renda     := x;
        rw_pessoa_rendacompl.cdoperad_altera := pr_cdoperad;

        -- Efetua a inclusao
        cada0010.pc_cadast_pessoa_renda_compl(pr_pessoa_renda_compl => rw_pessoa_rendacompl
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      --> Se nao possui informacao, deve-se excluir
      ELSE
        -- Excluir registro
        cada0010.pc_exclui_pessoa_renda_compl ( pr_idpessoa    => pr_idpessoa,
                                                pr_nrseq_renda => x,
                                                pr_cdoperad_altera   => pr_cdoperad,
                                                pr_cdcritic    => vr_cdcritic,
                                                pr_dscritic    => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      END IF;

    END LOOP; -- Fim do loop renda compl


	EXCEPTION
    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_pessoa_renda: '||SQLERRM;
  END pc_pessoa_renda;

  -- Rotina para atualizacao da tabela de dados titulares (CRAPTTL)
  PROCEDURE pc_crapttl(pr_crapttl     IN crapttl%ROWTYPE            --> Tabela de titular atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2) IS               --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pc_crapttl
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para atualizacao da tabela de dados titulares(CRAPTTL)
    --
    --  Alteração : 12/04/2018 - Alterando tpcadastro ao excluir o titular. (INC0010388 - Kelvin)
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    rw_pessoa_fis  cr_pessoa_fis%ROWTYPE;

    -- Buscar dados da pessoa de relacao
    CURSOR cr_pessoa_rel ( pr_idpessoa   tbcadast_pessoa.idpessoa%TYPE,
                           pr_tprelacao  tbcadast_pessoa_relacao.tprelacao%TYPE) IS
      SELECT rel.nrseq_relacao,
             rel.idpessoa_relacao,
             pes.nmpessoa
        FROM tbcadast_pessoa_relacao rel,
             tbcadast_pessoa pes
       WHERE rel.idpessoa         = pr_idpessoa
         AND rel.tprelacao        = pr_tprelacao
         AND rel.idpessoa_relacao = pes.idpessoa;
    rw_pessoa_rel cr_pessoa_rel%ROWTYPE;

    CURSOR cr_existe_crapttl(pr_nrcpfcgc crapttl.nrcpfcgc%TYPE) IS
      SELECT 1
        FROM crapttl ttl
       WHERE ttl.nrcpfcgc = pr_nrcpfcgc;
    rw_existe_crapttl cr_existe_crapttl%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE; -- Identificador de pessoa
    vr_idalteracao     tbhistor_conta_comunic_soa.idalteracao%TYPE;

  BEGIN


    -- Se for uma exclusao
    IF pr_tpoperacao = 3 THEN
      
      -- Buscar dados pessoa fisica
      OPEN cr_pessoa_fis_cpf(pr_nrcpf => pr_crapttl.nrcpfcgc);
      FETCH cr_pessoa_fis_cpf INTO rw_pessoa_fis;
      CLOSE cr_pessoa_fis_cpf;

      --Se existe titular
      OPEN cr_existe_crapttl(pr_crapttl.nrcpfcgc);
      FETCH cr_existe_crapttl INTO rw_existe_crapttl;
     
      IF cr_existe_crapttl%NOTFOUND THEN 
        CLOSE cr_existe_crapttl;
      
        rw_pessoa_fis.tpcadastro             := 2; -- Cadastro basico
        
        -- Atualiza o Cadastro de pessoa fisica
        cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => rw_pessoa_fis,
                                         pr_cdcritic      => vr_cdcritic,
                                         pr_dscritic      => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      ELSE
        CLOSE cr_existe_crapttl;
      END IF;
      
      -- gera comunicacao de exclusao de titular no SOA
      -- Insere na tabela de capa
      vr_idalteracao := cria_conta_comunic_soa(pr_crapttl.cdcooper,
                                               pr_crapttl.nrdconta,
                                               'CRAPTTL');
                                               
      -- Insere na capa
      BEGIN
        INSERT INTO tbhistor_crapttl
          (idalteracao, 
           dhalteracao, 
           tpoperacao, 
           cdcooper, 
           nrdconta, 
           idseqttl,
           idpessoa)
         VALUES
          (vr_idalteracao, 
           SYSDATE, 
           pr_tpoperacao, 
           pr_crapttl.cdcooper, 
           pr_crapttl.nrdconta, 
           pr_crapttl.idseqttl,
           nvl(rw_pessoa_fis.idpessoa,0));
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na tbhistor_crapttl: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
    ELSE -- Se for alteracao ou inclusao

      -- Se nao for informado o IDPESSOA, deve-se buscar
      IF pr_idpessoa IS NULL THEN
        -- Busca o ID PESSOA do email
        vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapttl.cdcooper,
                                       pr_nrdconta => pr_crapttl.nrdconta,
                                       pr_idseqttl => pr_crapttl.idseqttl);
        --> Caso não encontre irá criar
      ELSE
        vr_idpessoa := pr_idpessoa;
      END IF;

      -- Buscar dados pessoa fisica
      OPEN cr_pessoa_fis(pr_idpessoa => vr_idpessoa);
      FETCH cr_pessoa_fis INTO rw_pessoa_fis;
      CLOSE cr_pessoa_fis;

      --> Caso ainda nao exista cadastro de pessoa
      IF nvl(vr_idpessoa,0) = 0 THEN
        -- Efetua a inclusao de pessoa
        cada0011.pc_insere_pessoa_crapass(pr_cdcooper => pr_crapttl.cdcooper,
                                          pr_nrdconta => pr_crapttl.nrdconta,
                                          pr_idseqttl => pr_crapttl.idseqttl,
                                          pr_cdoperad => pr_cdoperad,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
        -- Verifica se deu erro
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapttl.cdcooper,
                                       pr_nrdconta => pr_crapttl.nrdconta,
                                       pr_idseqttl => pr_crapttl.idseqttl);
        IF vr_idpessoa IS NULL THEN
          vr_dscritic := 'Nao encontrado PESSOA para alteracao de dados do titular';
          RAISE vr_exc_erro;
        END IF;

      ELSE
        -- Se for uma naturalidade estrangeira, gera no campo de estrangeiros
        IF pr_crapttl.cdufnatu = 'EX' THEN
          rw_pessoa_fis.dsnaturalidade := pr_crapttl.dsnatura;
          rw_pessoa_fis.cdpais         := pr_crapttl.cdnacion;
        ELSE
          -- Busca o municipio da naturalidade
          CADA0015.pc_trata_municipio( pr_dscidade => pr_crapttl.dsnatura,
                                       pr_cdestado => TRIM(pr_crapttl.cdufnatu),
                                       pr_idcidade => rw_pessoa_fis.cdnaturalidade,
                                       pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Atualiza os dados de pessoa fisica
        rw_pessoa_fis.nrcpf                  := pr_crapttl.nrcpfcgc;
        rw_pessoa_fis.nmpessoa               := pr_crapttl.nmextttl;
        rw_pessoa_fis.tppessoa               := 1; -- Fisica
        rw_pessoa_fis.dtconsulta_rfb         := pr_crapttl.dtcnscpf;
        rw_pessoa_fis.cdsituacao_rfb         := pr_crapttl.cdsitcpf;
        rw_pessoa_fis.dtatualiza_telefone    := pr_crapttl.dtatutel;
        rw_pessoa_fis.tpcadastro             := 4; -- Cadastro completo
        rw_pessoa_fis.cdoperad_altera        := pr_cdoperad;
        rw_pessoa_fis.tpsexo                 := pr_crapttl.cdsexotl;
        IF nvl(pr_crapttl.cdestcvl,0) > 0 THEN
          rw_pessoa_fis.cdestado_civil       := pr_crapttl.cdestcvl;
        END IF;
        rw_pessoa_fis.dtnascimento           := pr_crapttl.dtnasttl;
        IF nvl(pr_crapttl.cdnacion,0) > 0 THEN
          rw_pessoa_fis.cdnacionalidade      := pr_crapttl.cdnacion;
        END IF;
        rw_pessoa_fis.tpnacionalidade        := pr_crapttl.tpnacion;
        rw_pessoa_fis.tpdocumento            := pr_crapttl.tpdocttl;
        rw_pessoa_fis.nrdocumento            := pr_crapttl.nrdocttl;
        rw_pessoa_fis.dtemissao_documento    := pr_crapttl.dtemdttl;
        IF pr_crapttl.idorgexp <> 0 THEN
          rw_pessoa_fis.idorgao_expedidor    := pr_crapttl.idorgexp;
        END IF;
        rw_pessoa_fis.cduf_orgao_expedidor   := TRIM(pr_crapttl.cdufdttl);
        rw_pessoa_fis.inhabilitacao_menor    := pr_crapttl.inhabmen;
        rw_pessoa_fis.dthabilitacao_menor    := pr_crapttl.dthabmen;
        IF nvl(pr_crapttl.grescola,0) > 0 THEN
          rw_pessoa_fis.cdgrau_escolaridade  := pr_crapttl.grescola;
        END IF;
        rw_pessoa_fis.cdcurso_superior       := pr_crapttl.cdfrmttl;
        IF pr_crapttl.cdnatopc <> 0 THEN
          rw_pessoa_fis.cdnatureza_ocupacao  := pr_crapttl.cdnatopc;
        END IF;
        rw_pessoa_fis.dsprofissao            := pr_crapttl.dsproftl;
        rw_pessoa_fis.dsjustific_outros_rend := pr_crapttl.dsjusren;

        -- Insere o Cadastro de pessoa fisica
        cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => rw_pessoa_fis,
                                         pr_cdcritic      => vr_cdcritic,
                                         pr_dscritic      => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Atualiza o ID PESSOA
        vr_idpessoa := rw_pessoa_fis.idpessoa;

        -- Buscar dados da pessoa de relacao
        OPEN cr_pessoa_rel ( pr_idpessoa  => vr_idpessoa,
                             pr_tprelacao => 3); -- Pai
        FETCH cr_pessoa_rel INTO rw_pessoa_rel;
        CLOSE cr_pessoa_rel;

        --> se possia inf do pai, porém agora o campo esta vazio, deve deletar
        IF rw_pessoa_rel.nrseq_relacao > 0 AND
           ( TRIM(pr_crapttl.nmpaittl) IS NULL OR
             pr_crapttl.nmpaittl <> rw_pessoa_rel.nmpessoa ) THEN
          -- Efetua a exclusao do registro
          cada0010.pc_exclui_pessoa_relacao ( pr_idpessoa           => vr_idpessoa,
                                              pr_nrseq_relacao      => rw_pessoa_rel.nrseq_relacao,
                                              pr_cdoperad_altera    => pr_cdoperad,
                                              pr_cdcritic           => vr_cdcritic,
                                              pr_dscritic           => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- se possui nome do pai, e é diferente do atual
        IF TRIM(pr_crapttl.nmpaittl) IS NOT NULL AND
           nvl(pr_crapttl.nmpaittl,' ') <> nvl(rw_pessoa_rel.nmpessoa,' ') THEN

          CADA0011.pc_trata_pessoa_relacao( pr_idpessoa => vr_idpessoa,
                                            pr_tprelacao=> 3, -- Pai
                                            pr_nmpessoa => pr_crapttl.nmpaittl,
                                            pr_cdoperad => pr_cdoperad,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Buscar dados da pessoa de relacao
        rw_pessoa_rel := NULL;
        OPEN cr_pessoa_rel ( pr_idpessoa  => vr_idpessoa,
                             pr_tprelacao => 4); -- Mae
        FETCH cr_pessoa_rel INTO rw_pessoa_rel;
        CLOSE cr_pessoa_rel;

        --> se possia inf do mae, porém agora o campo esta vazio, deve deletar
        IF rw_pessoa_rel.nrseq_relacao > 0 AND
           ( TRIM(pr_crapttl.nmmaettl) IS NULL OR
             pr_crapttl.nmmaettl <> rw_pessoa_rel.nmpessoa ) THEN
          -- Efetua a exclusao do registro
          cada0010.pc_exclui_pessoa_relacao ( pr_idpessoa           => vr_idpessoa,
                                              pr_nrseq_relacao      => rw_pessoa_rel.nrseq_relacao,
                                              pr_cdoperad_altera    => pr_cdoperad,
                                              pr_cdcritic           => vr_cdcritic,
                                              pr_dscritic           => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- se possui nome do mae, e é diferente do atual
        IF TRIM(pr_crapttl.nmmaettl) IS NOT NULL AND
           nvl(pr_crapttl.nmmaettl,' ') <> nvl(rw_pessoa_rel.nmpessoa,' ') THEN

          CADA0011.pc_trata_pessoa_relacao( pr_idpessoa => vr_idpessoa,
                                            pr_tprelacao=> 4, -- Mae
                                            pr_nmpessoa => pr_crapttl.nmmaettl,
                                            pr_cdoperad => pr_cdoperad,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Atualizacao da tabela renda do titular (CRAPTTL)
        pc_pessoa_renda( pr_idpessoa   => vr_idpessoa  --> Identificador de pessoa
                        ,pr_crapttl    => pr_crapttl   --> Tabela de titular atual
                        ,pr_cdoperad   => pr_cdoperad  --> Operador que esta efetuando a operacao
                        ,pr_dscritic   => vr_dscritic);   --> Retorno de Erro

        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

    END IF;


	EXCEPTION
    WHEN vr_exc_saida THEN
      --> Apenas gerar alerta
      pc_gerar_alerta_pessoa(pr_cdcooper => pr_crapttl.cdcooper
                            ,pr_nrdconta => pr_crapttl.nrdconta
                            ,pr_idseqttl => pr_crapttl.idseqttl
                            ,pr_nmtabela => 'CRAPTTL'
                            ,pr_dsalerta => vr_dscritic);


    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_crapttl: '||SQLERRM;
  END pc_crapttl;

  -- Rotina para atualizacao da tabela de dados pessoa juridica (CRAPJUR)
  PROCEDURE pc_crapjur(pr_crapjur     IN crapjur%ROWTYPE            --> Tabela de juridica atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2) IS               --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pc_crapjur
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para atualizacao da tabela de dados pessoa juridica (CRAPJUR)
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    rw_pessoa_jur  cr_pessoa_jur%ROWTYPE;

    -- Cursor sobre a tabela de associados
    CURSOR cr_crapass IS
      SELECT nmttlrfb,
             dtcnsspc,
             dtcnscpf,
             cdsitcpf,
             inconrfb,
             dtcnsscr,
             nvl(cdclcnae,0) cdclcnae
        FROM crapass
       WHERE cdcooper = pr_crapjur.cdcooper
         AND nrdconta = pr_crapjur.nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE; -- Identificador de pessoa

  BEGIN

    -- Se nao for informado o IDPESSOA, deve-se buscar
    IF pr_idpessoa IS NULL THEN
      -- Busca o ID PESSOA do email
      vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapjur.cdcooper,
                                     pr_nrdconta => pr_crapjur.nrdconta,
                                     pr_idseqttl => 1);
      IF vr_idpessoa IS NULL THEN
        vr_dscritic := 'Nao encontrado PESSOA para alteracao de dados pessoa juridica';
        RAISE vr_exc_saida;
      END IF;
    ELSE
      vr_idpessoa := pr_idpessoa;
    END IF;

    -- Buscar dados pessoa juridica
    OPEN cr_pessoa_jur(pr_idpessoa => vr_idpessoa);
    FETCH cr_pessoa_jur INTO rw_pessoa_jur;
    CLOSE cr_pessoa_jur;

    -- Se for uma exclusao
    IF pr_tpoperacao = 3 THEN
      --> Tabela nao permite exclusão, nao é necessario tratar
      NULL;
    ELSE -- Se for alteracao ou inclusao
      --> Caso ainda nao exista cadastro de pessoa
      IF nvl(vr_idpessoa,0) = 0 THEN
        -- Efetua a inclusao de pessoa
        cada0011.pc_insere_pessoa_crapass(pr_cdcooper => pr_crapjur.cdcooper,
                                          pr_nrdconta => pr_crapjur.nrdconta,
                                          pr_idseqttl => 1,
                                          pr_cdoperad => pr_cdoperad,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
        -- Verifica se deu erro
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapjur.cdcooper,
                                       pr_nrdconta => pr_crapjur.nrdconta,
                                       pr_idseqttl => 1);
        IF vr_idpessoa IS NULL THEN
          vr_dscritic := 'Nao encontrado PESSOA para alteracao de dados pessoa juridica';
          RAISE vr_exc_erro;
        END IF;

      ELSE

        -- Busca os dados na tabela de associado
        OPEN cr_crapass;
        FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;

        -- Atualiza os dados de pessoa juridica
        rw_pessoa_jur.nmpessoa               := pr_crapjur.nmextttl;
        rw_pessoa_jur.dtatualiza_telefone    := pr_crapjur.dtatutel;
        rw_pessoa_jur.cdoperad_altera        := pr_cdoperad;
        rw_pessoa_jur.nmfantasia             := pr_crapjur.nmfansia;
        rw_pessoa_jur.nrinscricao_estadual   := pr_crapjur.nrinsest;
        IF nvl(pr_crapjur.natjurid,0) > 0 THEN
          rw_pessoa_jur.cdnatureza_juridica    := pr_crapjur.natjurid;
        END IF;

        IF nvl(pr_crapjur.vlfatano,0) > 360000  THEN
          rw_pessoa_jur.tpcadastro     := 4; -- completo
        ELSE
          rw_pessoa_jur.tpcadastro     := 3; -- Cadastro Intermediario
        END IF;

        rw_pessoa_jur.dtinicio_atividade     := pr_crapjur.dtiniatv;
        rw_pessoa_jur.qtfilial               := pr_crapjur.qtfilial;
        rw_pessoa_jur.qtfuncionario          := pr_crapjur.qtfuncio;
        rw_pessoa_jur.vlcapital              := pr_crapjur.vlcaprea;
        rw_pessoa_jur.dtregistro             := pr_crapjur.dtregemp;
        rw_pessoa_jur.nrregistro             := pr_crapjur.nrregemp;
        rw_pessoa_jur.dtinscricao_municipal  := pr_crapjur.dtinsnum;
        rw_pessoa_jur.nrnire                 := pr_crapjur.nrcdnire;
        rw_pessoa_jur.inrefis                := pr_crapjur.flgrefis;
        rw_pessoa_jur.dssite                 := pr_crapjur.dsendweb;
        rw_pessoa_jur.nrinscricao_municipal  := pr_crapjur.nrinsmun;
        rw_pessoa_jur.cdsetor_economico      := pr_crapjur.cdseteco;
        rw_pessoa_jur.vlfaturamento_anual    := pr_crapjur.vlfatano;
        rw_pessoa_jur.cdramo_atividade       := pr_crapjur.cdrmativ;
        rw_pessoa_jur.nrlicenca_ambiental    := pr_crapjur.nrlicamb;
        rw_pessoa_jur.dtvalidade_licenca_amb := pr_crapjur.dtvallic;
        rw_pessoa_jur.dsorgao_registro       := pr_crapjur.orregemp;
        rw_pessoa_jur.tpregime_tributacao    := pr_crapjur.tpregtrb;

        -- Atualiza tambem os dados que estao na CRAPASS
        rw_pessoa_jur.nmpessoa_receita       := rw_crapass.nmttlrfb;
        rw_pessoa_jur.dtconsulta_spc         := rw_crapass.dtcnsspc;
        rw_pessoa_jur.dtconsulta_rfb         := rw_crapass.dtcnscpf;
        rw_pessoa_jur.cdsituacao_rfb         := rw_crapass.cdsitcpf;
        IF rw_crapass.inconrfb = 0 THEN
          rw_pessoa_jur.tpconsulta_rfb       := 2; -- Manual
        ELSE
          rw_pessoa_jur.tpconsulta_rfb       := 1; -- Automatica
        END IF;
        rw_pessoa_jur.dtconsulta_scr         := rw_crapass.dtcnsscr;
        IF rw_crapass.cdclcnae > 0 THEN
          rw_pessoa_jur.cdcnae               := rw_crapass.cdclcnae;
        END IF;


        -- Insere o Cadastro de pessoa juridica
        cada0010.pc_cadast_pessoa_juridica(pr_pessoa_juridica => rw_pessoa_jur,
                                           pr_cdcritic        => vr_cdcritic,
                                           pr_dscritic        => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Atualiza o ID PESSOA
        vr_idpessoa := rw_pessoa_jur.idpessoa;

      END IF;
    END IF;


	EXCEPTION
    WHEN vr_exc_saida THEN
      --> Apenas gerar alerta
      pc_gerar_alerta_pessoa(pr_cdcooper => pr_crapjur.cdcooper
                            ,pr_nrdconta => pr_crapjur.nrdconta
                            ,pr_idseqttl => 1
                            ,pr_nmtabela => 'CRAPJUR'
                            ,pr_dsalerta => vr_dscritic);


    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_crapjur: '||SQLERRM;
  END pc_crapjur;


  -- Rotina para atualizacao da tabela de dados pessoa (CRAPASS)
  PROCEDURE pc_crapass(pr_crapass     IN crapass%ROWTYPE            --> Tabela de associado atual
                      ,pr_tpoperacao  IN INTEGER                    --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                      ,pr_idpessoa    IN tbcadast_pessoa.idpessoa%TYPE DEFAULT NULL --> Identificador de pessoa
                      ,pr_cdoperad    IN crapope.cdoperad%TYPE      --> Operador que esta efetuando a operacao
                      ,pr_dscritic   OUT VARCHAR2) IS               --> Retorno de Erro

    /* ..........................................................................
    --
    --  Programa : pr_crapass
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para atualizacao da tabela de dados associado (CRAPASS)
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    rw_pessoa_jur  cr_pessoa_jur%ROWTYPE;
    rw_pessoa_fis  cr_pessoa_fis%ROWTYPE;

    --> Verificar pessoa
    CURSOR cr_pessoa (pr_nrcpfcgc tbcadast_pessoa.nrcpfcgc%TYPE) IS
      SELECT pes.idpessoa,
             pes.tppessoa
        FROM tbcadast_pessoa pes
       WHERE pes.nrcpfcgc = pr_nrcpfcgc;
    rw_pessoa cr_pessoa%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE; -- Identificador de pessoa

  BEGIN

    --> Verificar pessoa
    OPEN cr_pessoa (pr_nrcpfcgc => pr_crapass.nrcpfcgc);
    FETCH cr_pessoa INTO rw_pessoa;
    CLOSE cr_pessoa;

    vr_idpessoa := rw_pessoa.idpessoa;

    -- Se for uma exclusao
    IF pr_tpoperacao = 3 THEN
      --> Tabela nao permite exclusão, nao é necessario tratar
      NULL;
    ELSE -- Se for alteracao ou inclusao
      --> Caso ainda nao exista cadastro de pessoa
      IF nvl(vr_idpessoa,0) = 0 THEN
        -- Efetua a inclusao de pessoa
        cada0011.pc_insere_pessoa_crapass(pr_cdcooper => pr_crapass.cdcooper,
                                          pr_nrdconta => pr_crapass.nrdconta,
                                          pr_idseqttl => 1,
                                          pr_cdoperad => pr_cdoperad,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
        -- Verifica se deu erro
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        vr_idpessoa := fn_busca_pessoa(pr_cdcooper => pr_crapass.cdcooper,
                                       pr_nrdconta => pr_crapass.nrdconta,
                                       pr_idseqttl => 1);
        IF vr_idpessoa IS NULL THEN
          vr_dscritic := 'Nao encontrado PESSOA para alteracao de dados associado';
          RAISE vr_exc_erro;
        END IF;

      ELSE

        --> Pessoa fisica
        IF pr_crapass.inpessoa = 1  THEN

          -- Buscar dados pessoa fisica
          OPEN cr_pessoa_fis(pr_idpessoa => vr_idpessoa);
          FETCH cr_pessoa_fis INTO rw_pessoa_fis;
          CLOSE cr_pessoa_fis;

          rw_pessoa_fis.dtconsulta_scr         := pr_crapass.dtcnsscr;
          rw_pessoa_fis.dtconsulta_spc         := pr_crapass.dtcnsspc;
          rw_pessoa_fis.nmpessoa_receita       := pr_crapass.nmttlrfb;
          rw_pessoa_fis.cdoperad_altera        := pr_cdoperad;
          IF pr_crapass.inconrfb = 0 THEN
            rw_pessoa_fis.tpconsulta_rfb       := 2;
          ELSE
            rw_pessoa_fis.tpconsulta_rfb       := 1;
          END IF;

          -- Insere o Cadastro de pessoa fisica
          cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => rw_pessoa_fis,
                                           pr_cdcritic      => vr_cdcritic,
                                           pr_dscritic      => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

        --> Pessoa Juridica
        ELSE

          -- Buscar dados pessoa juridica
          OPEN cr_pessoa_jur(pr_idpessoa => vr_idpessoa);
          FETCH cr_pessoa_jur INTO rw_pessoa_jur;
          CLOSE cr_pessoa_jur;

          rw_pessoa_jur.nmpessoa_receita       := pr_crapass.nmttlrfb;
          rw_pessoa_jur.dtconsulta_spc         := pr_crapass.dtcnsspc;
          rw_pessoa_jur.dtconsulta_rfb         := pr_crapass.dtcnscpf;
          rw_pessoa_jur.cdsituacao_rfb         := pr_crapass.cdsitcpf;
          IF pr_crapass.inconrfb = 0 THEN
            rw_pessoa_jur.tpconsulta_rfb       := 2; -- Manual
          ELSE
            rw_pessoa_jur.tpconsulta_rfb       := 1; -- Automatica
          END IF;
          rw_pessoa_jur.dtconsulta_scr         := pr_crapass.dtcnsscr;
          rw_pessoa_jur.cdoperad_altera        := pr_cdoperad;
          IF pr_crapass.cdclcnae > 0 THEN
            rw_pessoa_jur.cdcnae               := pr_crapass.cdclcnae;
          END IF;

          -- Insere o Cadastro de pessoa juridica
          cada0010.pc_cadast_pessoa_juridica(pr_pessoa_juridica => rw_pessoa_jur,
                                             pr_cdcritic        => vr_cdcritic,
                                             pr_dscritic        => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

        END IF; --> Fim inpessoa

      END IF;
    END IF;


	EXCEPTION
    WHEN vr_exc_saida THEN
      --> Apenas gerar alerta
      pc_gerar_alerta_pessoa(pr_cdcooper => pr_crapass.cdcooper
                            ,pr_nrdconta => pr_crapass.nrdconta
                            ,pr_idseqttl => 1
                            ,pr_nmtabela => 'CRAPASS'
                            ,pr_dsalerta => vr_dscritic);


    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_crapass: '||SQLERRM;
  END pc_crapass;

  -- Rotina para envio do CPF / CNPJ de um cooperado novo
  PROCEDURE pc_envia_cooperado_crm(pr_nrcpfcgc tbcadast_pessoa.nrcpfcgc%TYPE) IS
    vr_requisicao WRES0001.typ_http_request;
    vr_resposta   WRES0001.typ_http_response;
    vr_dscritic   crapcri.dscritic%TYPE;
    vr_cdcritic   crapcri.cdcritic%TYPE;
    vr_parametros WRES0001.typ_tab_http_parametros;
  BEGIN
    -- Endereço Base 'http://apiaymaruhml.cecred.coop.br'
    vr_requisicao.endereco := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                        pr_cdacesso => 'AYMARU_CRM');

    vr_requisicao.rota := '/CRM/api/Incremental'; -- Rota para a aplicação / serviço solicitado
    vr_requisicao.verbo := CECRED.WRES0001.GET; -- Verbo HTTP (PUT/POST/GET/DELETE)

    -- Parâmetros da URL, ex: "http://apiaymaruhml.cecred.coop.br/CRM/api/Incremental?SCpf=11870846389"
    vr_parametros(1).chave := 'SCpf';
    vr_parametros(1).valor := pr_nrcpfcgc;

    vr_requisicao.parametros := vr_parametros;

    vr_requisicao.timeout := 30; -- Timeout da Requisição HTTP
    
    WRES0001.pc_consumir_rest(pr_requisicao => vr_requisicao
                             ,pr_resposta   => vr_resposta
                             ,pr_dscritic   => vr_dscritic
                             ,pr_cdcritic   => vr_cdcritic);
                                  
    /*
    DBMS_OUTPUT.put_line('HTTP Status Code: ' ||   vr_resposta.status_code); -- HTTP Status Code (200 - OK; 400 Bad Request; 500 Internal Server Error)
    DBMS_OUTPUT.put_line('HTTP Status Message: ' ||   vr_resposta.status_message);
    DBMS_OUTPUT.put_line('Dscritic: ' ||   vr_dscritic);
    */
  EXCEPTION
    WHEN OTHERS THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                  ,pr_nmarqlog => 'CRM' 
                                  ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                     'Erro no envio do CPF / CNPJ '||pr_nrcpfcgc|| ' para o CRM: '||SQLERRM);
  end;  

  -- Rotina para processar registros pendentes de atualização
  PROCEDURE pc_processa_pessoa_atlz( pr_cdcooper  IN INTEGER DEFAULT NULL, --> Codigo da coperativa quando processo de replic. online
                                     pr_nrdconta  IN INTEGER DEFAULT NULL, --> Nr. da conta quando processo de replic. online
                                     pr_dscritic OUT VARCHAR2) IS     --> Retorno de Erro
  /* ..........................................................................
    --
    --  Programa : pc_processa_pessoa_atlz
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 05/07/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para processar registros pendentes de atualização
    --
    --  Alteração : 07/02/2018 - Alterado a prioridade de atualizacao das pessoas no cursor
    --                           cr_pessoa_atlz para olhar a CRAPJUR primeiro (Tiago/Andrino #843413) 
    --
    --
    --              05/07/2018 - Para solucionar o problema do incidente INC0018017 foi necessário
    --                           a priorizar a atualização das pessoas no cursor para olhar a CRAPJFN
    --                           primeiro (Kelvin/Adrino).
	--
	--				11/04/2019 - Reiniciar variáveis de cursores, para que não tenha
	--						     inconsistências de dados ao efetuar atualizações/exclusões
	--						     nas tabelas do cadastro unificado. 
	--							 Alcemir - Mouts (PRB0040624).
	--
	--              07/05/2019 - Ajustado a ordem de priorização entre CRAPJUR e CRAPJFN
	--                           INC0014506 (Jefferson - MoutS)
	--
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    -- Cursor sobre as pessoas à atualizarem os dados cadastrais
    CURSOR cr_pessoa_atlz IS
      SELECT atl.*,
             atl.rowid
        FROM tbcadast_pessoa_atualiza atl
       WHERE (atl.insit_atualiza = 1 AND --> pendente job
              nvl(pr_nrdconta,0) = 0  )
          OR (atl.cdcooper = pr_cdcooper AND
              atl.nrdconta = pr_nrdconta AND
              atl.insit_atualiza = 4  --> pendente processo online
              )
       ORDER BY trunc(atl.dhatualiza,'MI'),
                --> Ordenacao priorizando as tabelas ass e ttl
                decode(atl.nmtabela,'CRAPJUR',0,'CRAPJFN',1,'CRAPASS',2,'CRAPTTL',3,4),
                decode(atl.nmtabela,'CRAPCEM',atl.dschave,'CRAPTFC',atl.dschave,decode(substr(atl.dschave,1,1),'S',1,2)) ; 

    --> dados do conjuge
    CURSOR cr_crapcje( pr_cdcooper crapcje.cdcooper%TYPE,
                       pr_nrdconta crapcje.nrdconta%TYPE,
                       pr_idseqttl crapcje.idseqttl%TYPE) IS
      SELECT *
        FROM crapcje cje
       WHERE cje.cdcooper = pr_cdcooper
         AND cje.nrdconta = pr_nrdconta
         AND cje.idseqttl = pr_idseqttl;
    rw_crapcje cr_crapcje%ROWTYPE;

    --> Buscar dados do telefone
    CURSOR cr_craptfc( pr_cdcooper craptfc.cdcooper%TYPE,
                       pr_nrdconta craptfc.nrdconta%TYPE,
                       pr_idseqttl craptfc.idseqttl%TYPE,
                       pr_cdseqtfc craptfc.cdseqtfc%TYPE) IS
      SELECT *
        FROM craptfc tfc
       WHERE tfc.cdcooper = pr_cdcooper
         AND tfc.nrdconta = pr_nrdconta
         AND tfc.idseqttl = pr_idseqttl
         AND tfc.cdseqtfc = pr_cdseqtfc;
    rw_craptfc cr_craptfc%ROWTYPE;

		--> Buscar dados do e-mail
		CURSOR cr_crapcem( pr_cdcooper crapcem.cdcooper%TYPE,
                       pr_nrdconta crapcem.nrdconta%TYPE,
                       pr_idseqttl crapcem.idseqttl%TYPE,
                       pr_cddemail crapcem.cddemail%TYPE) IS
		  SELECT *
			  FROM crapcem cem
			 WHERE cem.cdcooper = pr_cdcooper
			   AND cem.nrdconta = pr_nrdconta
				 AND cem.idseqttl = pr_idseqttl
				 AND cem.cddemail = pr_cddemail;
		rw_crapcem cr_crapcem%ROWTYPE;

		--> Buscar dados do bem
		CURSOR cr_crapbem( pr_cdcooper crapbem.cdcooper%TYPE,
                       pr_nrdconta crapbem.nrdconta%TYPE,
                       pr_idseqttl crapbem.idseqttl%TYPE,
                       pr_idseqbem crapbem.idseqbem%TYPE) IS
		  SELECT *
			  FROM crapbem bem
			 WHERE bem.cdcooper = pr_cdcooper
			   AND bem.nrdconta = pr_nrdconta
				 AND bem.idseqttl = pr_idseqttl
				 AND bem.idseqbem = pr_idseqbem;
		rw_crapbem cr_crapbem%ROWTYPE;

		--> Buscar empresa com participação societaria em outras empresas
		CURSOR cr_crapepa( pr_cdcooper crapepa.cdcooper%TYPE,
		                   pr_nrdocsoc crapepa.nrdocsoc%TYPE,
                       pr_nrdconta crapepa.nrdconta%TYPE) IS
		  SELECT *
			  FROM crapepa epa
			 WHERE epa.cdcooper = pr_cdcooper
			   AND epa.nrdocsoc = pr_nrdocsoc
			   AND epa.nrdconta = pr_nrdconta;
		rw_crapepa cr_crapepa%ROWTYPE;

		--> Buscar avalistas terceiros, contatos (PF) ou referencias comerciais/bancarias (PJ)
		CURSOR cr_crapavt( pr_cdcooper crapavt.cdcooper%TYPE
		                  ,pr_tpctrato crapavt.tpctrato%TYPE
											,pr_nrdconta crapavt.nrdconta%TYPE
											,pr_nrctremp crapavt.nrctremp%TYPE
											,pr_nrcpfcgc crapavt.nrcpfcgc%TYPE) IS
		  SELECT *
			  FROM crapavt avt
			 WHERE avt.cdcooper = pr_cdcooper
			   AND avt.tpctrato = pr_tpctrato
				 AND avt.nrdconta = pr_nrdconta
				 AND avt.nrctremp = pr_nrctremp
				 AND avt.nrcpfcgc = pr_nrcpfcgc;
		rw_crapavt cr_crapavt%ROWTYPE;

		--> Buscar representante legal
		CURSOR cr_crapcrl( pr_cdcooper crapcrl.cdcooper%TYPE
		                  ,pr_nrctamen crapcrl.nrctamen%TYPE
											,pr_nrcpfmen crapcrl.nrcpfmen%TYPE
											,pr_idseqmen crapcrl.idseqmen%TYPE
											,pr_nrdconta crapcrl.nrdconta%TYPE
											,pr_nrcpfcgc crapcrl.nrcpfcgc%TYPE) IS
		  SELECT *
			  FROM crapcrl crl
			 WHERE crl.cdcooper = pr_cdcooper
			   AND crl.nrctamen = pr_nrctamen
				 AND crl.nrcpfmen = pr_nrcpfmen
				 AND crl.idseqmen = pr_idseqmen
				 AND crl.nrdconta = pr_nrdconta
				 AND crl.nrcpfcgc = pr_nrcpfcgc;
		rw_crapcrl cr_crapcrl%ROWTYPE;

    --> Buscar o dependente do titular da conta
		CURSOR cr_crapdep( pr_cdcooper crapdep.cdcooper%TYPE
		                  ,pr_nrdconta crapdep.nrdconta%TYPE
											,pr_idseqdep crapdep.idseqdep%TYPE
											,pr_nmdepend crapdep.nmdepend%TYPE) IS
			SELECT *
			  FROM crapdep dep
			 WHERE dep.cdcooper = pr_cdcooper
			   AND dep.nrdconta = pr_nrdconta
				 AND dep.idseqdep = pr_idseqdep
				 AND upper(dep.nmdepend) = upper(pr_nmdepend);
		rw_crapdep cr_crapdep%ROWTYPE;

		--> Buscar titulares politicamente expostos
		CURSOR cr_politico_exposto( pr_cdcooper tbcadast_politico_exposto.cdcooper%TYPE
		                           ,pr_nrdconta tbcadast_politico_exposto.nrdconta%TYPE
															 ,pr_idseqttl tbcadast_politico_exposto.idseqttl%TYPE) IS
		  SELECT *
			  FROM tbcadast_politico_exposto pexp
			 WHERE pexp.cdcooper = pr_cdcooper
			   AND pexp.nrdconta = pr_nrdconta
				 AND pexp.idseqttl = pr_idseqttl;
		rw_politico_exposto cr_politico_exposto%ROWTYPE;

		--> Buscar titular da conta (PF)
		CURSOR cr_crapttl( pr_cdcooper crapttl.cdcooper%TYPE
										  ,pr_nrdconta crapttl.nrdconta%TYPE
										  ,pr_idseqttl crapttl.idseqttl%TYPE) IS
		  SELECT *
			  FROM crapttl ttl
			 WHERE ttl.cdcooper = pr_cdcooper
			   AND ttl.nrdconta = pr_nrdconta
				 AND ttl.idseqttl = pr_idseqttl;
		rw_crapttl cr_crapttl%ROWTYPE;

		--> Buscar endereço do cooperado
		CURSOR cr_crapenc( pr_cdcooper crapenc.cdcooper%TYPE
		                  ,pr_nrdconta crapenc.nrdconta%TYPE
											,pr_idseqttl crapenc.idseqttl%TYPE
											,pr_cdseqinc crapenc.cdseqinc%TYPE) IS
		  SELECT *
			  FROM crapenc enc
		   WHERE enc.cdcooper = pr_cdcooper
			   AND enc.nrdconta = pr_nrdconta
				 AND enc.idseqttl = pr_idseqttl
				 AND enc.cdseqinc = pr_cdseqinc;
		rw_crapenc cr_crapenc%ROWTYPE;

		--> Buscar conta do cooperado
		CURSOR cr_crapass( pr_cdcooper crapass.cdcooper%TYPE
		                  ,pr_nrdconta crapass.nrdconta%TYPE) IS
			SELECT ass.*
			  FROM crapass ass
			 WHERE ass.cdcooper = pr_cdcooper
			   AND ass.nrdconta = pr_nrdconta;
		rw_crapass cr_crapass%ROWTYPE;

		CURSOR cr_crapass_2( pr_cdcooper crapass.cdcooper%TYPE
		                    ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT a.cdagenci,
             a.dtdemiss, b.dsmotivo, c.inblqexc, DECODE(a.dtdemiss,NULL,1, -- Ativa
                   DECODE(nvl(b.tpmotivo,0),1,4,  -- Demissao
                          DECODE(c.inblqexc,1,2,  -- Excluída
                                 3))) tpsituacao_matricula -- Reativacao Permitida
        FROM crapcop c,
             TBCOTAS_MOTIVO_DESLIGAMENTO b,
             crapass a
       WHERE a.cdcooper     = pr_cdcooper
         AND a.nrdconta     = pr_nrdconta
         AND b.cdmotivo (+) = a.cdmotdem
         AND c.cdcooper     = a.cdcooper;
    rw_crapass_2 cr_crapass_2%ROWTYPE;
		--> Buscar conta PJ
		CURSOR cr_crapjur( pr_cdcooper crapjur.cdcooper%TYPE
		                  ,pr_nrdconta crapjur.nrdconta%TYPE) IS
		  SELECT *
			  FROM crapjur jur
			 WHERE jur.cdcooper = pr_cdcooper
			   AND jur.nrdconta = pr_nrdconta;
		rw_crapjur cr_crapjur%ROWTYPE;

		--> Buscar dados financeiros dos cooperados com tipo de pessoa juridica
		CURSOR cr_crapjfn ( pr_cdcooper crapjfn.cdcooper%TYPE
		                   ,pr_nrdconta crapjfn.nrdconta%TYPE) IS
		  SELECT *
			  FROM crapjfn jfn
			 WHERE jfn.cdcooper = pr_cdcooper
			   AND jfn.nrdconta = pr_nrdconta;
		rw_crapjfn cr_crapjfn%ROWTYPE;

		--> Buscar dados de operadores de internet
		CURSOR cr_crapopi ( pr_cdcooper crapopi.cdcooper%TYPE
		                   ,pr_nrdconta crapopi.nrdconta%TYPE
                       ,pr_nrcpfope crapopi.nrcpfope%TYPE) IS
		  SELECT *
			  FROM crapopi opi
			 WHERE opi.cdcooper = pr_cdcooper
			   AND opi.nrdconta = pr_nrdconta
         AND opi.nrcpfope = pr_nrcpfope;
		rw_crapopi cr_crapopi%ROWTYPE;

    -- Cursor 
    CURSOR cr_conta_comunic_soa(pr_cdcooper crapass.cdcooper%TYPE,
                                pr_nrdconta crapass.nrdconta%TYPE) IS
       SELECT *
         FROM tbhistor_crapass a
        WHERE cdcooper = pr_cdcooper
          AND nrdconta = pr_nrdconta
        ORDER BY a.dhalteracao DESC;
    rw_conta_comunic_soa cr_conta_comunic_soa%ROWTYPE;

    CURSOR cr_atualiza(pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT 1
        FROM tbcadast_pessoa_atualiza a
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND a.nmtabela = 'CRAPTTL'
         AND substr(a.dschave,1,1) = 'S'
         AND a.insit_atualiza IN (1,4);

    CURSOR cr_atualiza_opi(pr_cdcooper crapass.cdcooper%TYPE,
                           pr_nrdconta crapass.nrdconta%TYPE,
                           pr_dschave  tbcadast_pessoa_atualiza.dschave%TYPE) IS
      SELECT COUNT(*) qt_registro
        FROM tbcadast_pessoa_atualiza a
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND a.nmtabela = 'CRAPOPI'
         AND a.dschave = pr_dschave
         AND a.insit_atualiza = 1;
     rw_atualiza_opi cr_atualiza_opi%ROWTYPE;


    ---------------> VARIAVEIS <-----------------

    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
    vr_des_erro VARCHAR2(10);
		vr_exc_erro EXCEPTION;

    -- Variaveis auxiliares
    vr_tpoperac        INTEGER;
    vr_nmtabela        VARCHAR2(80);
    vr_tab_campos      gene0002.typ_split;
    vr_tpincons        INTEGER;
    vr_insit_atualiza  INTEGER;
    vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE;
    vr_idalteracao     tbhistor_conta_comunic_soa.idalteracao%TYPE;
    vr_tpalteracao     tbhistor_crapass.tpoperacao%TYPE;
    vr_idinclusao      BOOLEAN;

  BEGIN

	  -- Percorrer pessoas com status 'Pendente' a atualizar os dados cadastrais
    FOR rw_pessoa_atlz IN cr_pessoa_atlz LOOP
      -- Inicializar variáveis
      vr_tpoperac   := 0;
      vr_tab_campos := NULL;
      vr_nmtabela   := rw_pessoa_atlz.nmtabela;

			-- Verificar a tabela a ser atualizada
      CASE UPPER(rw_pessoa_atlz.nmtabela)

        WHEN 'CRAPCJE' THEN
          
          rw_crapcje := NULL; -- reiniciar variável do cursor cr_crapcje;
          
          -- Buscar conjuge
          OPEN cr_crapcje( pr_cdcooper => rw_pessoa_atlz.cdcooper,
                           pr_nrdconta => rw_pessoa_atlz.nrdconta,
                           pr_idseqttl => rw_pessoa_atlz.idseqttl);
          FETCH cr_crapcje INTO rw_crapcje;

					-- Se não encontrar registro
          IF cr_crapcje%NOTFOUND THEN
						-- Fechar cursor
            CLOSE cr_crapcje;
            vr_tpoperac := 3; --> exclusao
						-- Atribuir registro da tabela de pessoa a atualizar
            rw_crapcje.cdcooper := rw_pessoa_atlz.cdcooper;
            rw_crapcje.nrdconta := rw_pessoa_atlz.nrdconta;
            rw_crapcje.idseqttl := rw_pessoa_atlz.idseqttl;

          ELSE
            -- Fechar cursor
            CLOSE cr_crapcje;

            --> caso não tenha informações preenchidas,
            --> deve considerar como excluido
            IF nvl(rw_crapcje.nrctacje,0) = 0 AND
               nvl(rw_crapcje.nrcpfcjg,0) = 0  AND
               nvl(rw_crapcje.nmconjug,0) = ' ' THEN
              vr_tpoperac := 3; --> exclusao
            ELSE
              vr_tpoperac := 1; --> inserção/alteração
            END IF;

          END IF;

          -- Rotina para atualizacao da tabela de conjuge (CRAPCJE)
          cada0015.pc_crapcje( pr_crapcje     => rw_crapcje            --> Tabela de conjuge atual
                              ,pr_tpoperacao  => vr_tpoperac           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                              ,pr_idpessoa    => NULL                  --> Identificador de pessoa
                              ,pr_cdoperad    => 1                     --> Operador que esta efetuando a operacao
                              ,pr_dscritic    => vr_dscritic);         --> Retorno de Erro

        WHEN 'CRAPTFC' THEN
          
          rw_craptfc := NULL; -- reiniciar variável do cursor cr_craptfc;
           
          -- Quebrar chave da tabela
          vr_tab_campos := gene0002.fn_quebra_string(rw_pessoa_atlz.dschave,';');

          --> Buscar dados do telefone
          OPEN cr_craptfc( pr_cdcooper => vr_tab_campos(1) ,
													 pr_nrdconta => vr_tab_campos(2),
													 pr_idseqttl => vr_tab_campos(3),
													 pr_cdseqtfc => vr_tab_campos(4));

          FETCH cr_craptfc INTO rw_craptfc;
					-- Se não encontrou registro
          IF cr_craptfc%NOTFOUND THEN
						-- Fechar cursor
            CLOSE cr_craptfc;
            vr_tpoperac := 3; --> exclusao
						-- Atribuir registro da tabela de pessoa a atualizar
            rw_craptfc.cdcooper := vr_tab_campos(1);
            rw_craptfc.nrdconta := vr_tab_campos(2);
            rw_craptfc.idseqttl := vr_tab_campos(3);
            rw_craptfc.cdseqtfc := vr_tab_campos(4);

          ELSE
						-- Fechar cursor
            CLOSE cr_craptfc;
            vr_tpoperac := 1; --> inserção/alteração
          END IF;

          -- Rotina para atualizacao da tabela de telefones (CRAPTFC)
          cada0015.pc_craptfc( pr_craptfc     => rw_craptfc            --> Tabela de telefone atual
                              ,pr_tpoperacao  => vr_tpoperac           --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                              ,pr_idpessoa    => NULL                  --> Identificador de pessoa
                              ,pr_cdoperad    => 1                     --> Operador que esta efetuando a operacao
                              ,pr_dscritic    => vr_dscritic);         --> Retorno de Erro

				WHEN 'CRAPCEM' THEN
          
          rw_crapcem := NULL; -- reiniciar variável do cursor cr_crapcem;
          
          -- Quebrar chave da tabela
          vr_tab_campos := gene0002.fn_quebra_string(rw_pessoa_atlz.dschave,';');

          -- Buscar registro de e-mail
          OPEN cr_crapcem( pr_cdcooper => vr_tab_campos(1),
													 pr_nrdconta => vr_tab_campos(2),
													 pr_idseqttl => vr_tab_campos(3),
													 pr_cddemail => vr_tab_campos(4));

          FETCH cr_crapcem INTO rw_crapcem;
					-- Se não encontrou registro
          IF cr_crapcem%NOTFOUND THEN
						-- Fechar cursor
            CLOSE cr_crapcem;
            vr_tpoperac := 3; --> exclusao
						-- Atribuir registro da tabela de pessoa a atualizar
            rw_crapcem.cdcooper := vr_tab_campos(1);
            rw_crapcem.nrdconta := vr_tab_campos(2);
            rw_crapcem.idseqttl := vr_tab_campos(3);
            rw_crapcem.cddemail := vr_tab_campos(4);

          ELSE
						-- Fechar cursor
            CLOSE cr_crapcem;
            vr_tpoperac := 1; --> inserção/alteração
          END IF;

					-- Rotina para atualização da tabela de e-mails (CRAPCEM)
					cada0015.pc_crapcem( pr_crapcem => rw_crapcem                --> Tabela de telefone atual
                              ,pr_tpoperacao => vr_tpoperac            --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                              ,pr_idpessoa => NULL                     --> Identificador de pessoa
                              ,pr_cdoperad => 1                        --> Operador que esta efetuando a operacao
                              ,pr_dscritic => vr_dscritic);            --> Retorno de Erro
				WHEN 'CRAPBEM' THEN
          
          rw_crapbem := NULL; -- reinciar variável do cursor cr_crapbem;
          
          -- Quebrar chave da tabela
          vr_tab_campos := gene0002.fn_quebra_string(rw_pessoa_atlz.dschave,';');

          -- Buscar registro de bem
          OPEN cr_crapbem( pr_cdcooper => vr_tab_campos(1),
													 pr_nrdconta => vr_tab_campos(2),
													 pr_idseqttl => vr_tab_campos(3),
													 pr_idseqbem => vr_tab_campos(4));

          FETCH cr_crapbem INTO rw_crapbem;
					-- Se não encontrou registro
          IF cr_crapbem%NOTFOUND THEN
						-- Fechar cursor
            CLOSE cr_crapbem;
            vr_tpoperac := 3; --> exclusao
						-- Atribuir registro da tabela de pessoa a atualizar
            rw_crapbem.cdcooper := vr_tab_campos(1);
            rw_crapbem.nrdconta := vr_tab_campos(2);
            rw_crapbem.idseqttl := vr_tab_campos(3);
            rw_crapbem.idseqbem := vr_tab_campos(4);

          ELSE
						-- Fechar cursor
            CLOSE cr_crapbem;
            vr_tpoperac := 1; --> inserção/alteração
          END IF;

					-- Rotina para atualização da tabela de bens (CRAPBEM)
					cada0015.pc_crapbem( pr_crapbem => rw_crapbem                --> Tabela de telefone atual
                              ,pr_tpoperacao => vr_tpoperac            --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                              ,pr_idpessoa => NULL                     --> Identificador de pessoa
                              ,pr_cdoperad => 1                        --> Operador que esta efetuando a operacao
                              ,pr_dscritic => vr_dscritic);            --> Retorno de Erro

				WHEN 'CRAPEPA' THEN
          
          rw_crapepa := NULL; -- reiniciar variável do cursor cr_crapepa;
           
          -- Quebrar chave da tabela
          vr_tab_campos := gene0002.fn_quebra_string(rw_pessoa_atlz.dschave,';');

          -- Buscar registro de empresa com participação societária em outras empresas
          OPEN cr_crapepa( pr_cdcooper => vr_tab_campos(1),
					                 pr_nrdocsoc => vr_tab_campos(2),
													 pr_nrdconta => vr_tab_campos(3));

          FETCH cr_crapepa INTO rw_crapepa;
					-- Se não encontrou registro
          IF cr_crapepa%NOTFOUND THEN
						-- Fechar cursor
            CLOSE cr_crapepa;
            vr_tpoperac := 3; --> exclusao
						-- Atribuir registro da tabela de pessoa a atualizar
            rw_crapepa.cdcooper := vr_tab_campos(1);
            rw_crapepa.nrdocsoc := vr_tab_campos(2);
            rw_crapepa.nrdconta := vr_tab_campos(3);

          ELSE
						-- Fechar cursor
            CLOSE cr_crapepa;
            vr_tpoperac := 1; --> inserção/alteração
          END IF;

					-- Rotina para atualização da tabela de empresas com participação societária em outras empresas (CRAPEPA)
					cada0015.pc_crapepa( pr_crapepa => rw_crapepa                --> Tabela de telefone atual
                              ,pr_tpoperacao => vr_tpoperac            --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                              ,pr_idpessoa => NULL                     --> Identificador de pessoa
                              ,pr_cdoperad => 1                        --> Operador que esta efetuando a operacao
                              ,pr_dscritic => vr_dscritic);            --> Retorno de Erro

				WHEN 'CRAPAVT' THEN
          
          rw_crapavt := NULL; -- reiniciar variavel do cursor cr_crapavt;
          
          -- Quebrar chave da tabela
          vr_tab_campos := gene0002.fn_quebra_string(rw_pessoa_atlz.dschave,';');

          -- Buscar registro de avalista terceiro, contato (PF) ou referencia comercial/bancaria (PJ)
          OPEN cr_crapavt( pr_cdcooper => vr_tab_campos(1),
													 pr_tpctrato => vr_tab_campos(2),
													 pr_nrdconta => vr_tab_campos(3),
													 pr_nrctremp => vr_tab_campos(4),
													 pr_nrcpfcgc => vr_tab_campos(5));

          FETCH cr_crapavt INTO rw_crapavt;
					-- Se não encontrou registro
          IF cr_crapavt%NOTFOUND THEN
						-- Fechar cursor
            CLOSE cr_crapavt;
            vr_tpoperac := 3; --> exclusao
						-- Atribuir registro da tabela de pessoa a atualizar
            rw_crapavt.cdcooper := vr_tab_campos(1);
            rw_crapavt.tpctrato := vr_tab_campos(2);
            rw_crapavt.nrdconta := vr_tab_campos(3);
            rw_crapavt.nrctremp := vr_tab_campos(4);
            rw_crapavt.nrcpfcgc := vr_tab_campos(5);
            rw_crapavt.dsproftl := vr_tab_campos(6);

          ELSE
						-- Fechar cursor
            CLOSE cr_crapavt;
            vr_tpoperac := 1; --> inserção/alteração
          END IF;

					-- Rotina para atualização da tabela de avalistas terceiros, contatos (PF) ou referencias comerciais/bancarias (PJ) (CRAPAVT)
					cada0015.pc_crapavt( pr_crapavt => rw_crapavt                --> Tabela de telefone atual
                              ,pr_tpoperacao => vr_tpoperac            --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                              ,pr_idpessoa => NULL                     --> Identificador de pessoa
                              ,pr_cdoperad => 1                        --> Operador que esta efetuando a operacao
                              ,pr_dscritic => vr_dscritic);            --> Retorno de Erro

				WHEN 'CRAPCRL' THEN
          
          rw_crapcrl := NULL; -- reiniciar variavel do cursor cr_crapcrl;
          
          -- Quebrar chave da tabela
          vr_tab_campos := gene0002.fn_quebra_string(rw_pessoa_atlz.dschave,';');

          -- Buscar representante legal
          OPEN cr_crapcrl( pr_cdcooper => vr_tab_campos(1)
													,pr_nrctamen => vr_tab_campos(2)
													,pr_nrcpfmen => vr_tab_campos(3)
													,pr_idseqmen => vr_tab_campos(4)
													,pr_nrdconta => vr_tab_campos(5)
													,pr_nrcpfcgc => vr_tab_campos(6));

          FETCH cr_crapcrl INTO rw_crapcrl;
					-- Se não encontrou registro
          IF cr_crapcrl%NOTFOUND THEN
						-- Fechar cursor
            CLOSE cr_crapcrl;
            vr_tpoperac := 3; --> exclusao
						-- Atribuir registro da tabela de pessoa a atualizar
            rw_crapcrl.cdcooper := vr_tab_campos(1);
            rw_crapcrl.nrctamen := vr_tab_campos(2);
            rw_crapcrl.nrcpfmen := vr_tab_campos(3);
            rw_crapcrl.idseqmen := vr_tab_campos(4);
            rw_crapcrl.nrdconta := vr_tab_campos(5);
            rw_crapcrl.nrcpfcgc := vr_tab_campos(6);

          ELSE
						-- Fechar cursor
            CLOSE cr_crapcrl;
            vr_tpoperac := 1; --> inserção/alteração
          END IF;

					-- Rotina para atualização da tabela de representante legal
					cada0015.pc_crapcrl( pr_crapcrl => rw_crapcrl                --> Tabela de telefone atual
                              ,pr_tpoperacao => vr_tpoperac            --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                              ,pr_idpessoa => NULL                     --> Identificador de pessoa
                              ,pr_cdoperad => 1                        --> Operador que esta efetuando a operacao
                              ,pr_dscritic => vr_dscritic);            --> Retorno de Erro

        WHEN 'CRAPDEP' THEN
          
          rw_crapdep := NULL; -- reiniciar variavel do cursor cr_crapdep;
          
          -- Quebrar chave da tabela
          vr_tab_campos := gene0002.fn_quebra_string(rw_pessoa_atlz.dschave,';');

          -- Buscar dependente do titular da conta
          OPEN cr_crapdep( pr_cdcooper => vr_tab_campos(1)
													,pr_nrdconta => vr_tab_campos(2)
													,pr_idseqdep => vr_tab_campos(3)
													,pr_nmdepend => vr_tab_campos(4));
          FETCH cr_crapdep INTO rw_crapdep;

					-- Se não encontrou registro
          IF cr_crapdep%NOTFOUND THEN
						-- Fechar cursor
            CLOSE cr_crapdep;
            vr_tpoperac := 3; --> exclusao
						-- Atribuir registro da tabela de pessoa a atualizar
            rw_crapdep.cdcooper := vr_tab_campos(1);
            rw_crapdep.nrdconta := vr_tab_campos(2);
            rw_crapdep.idseqdep := vr_tab_campos(3);
            rw_crapdep.nmdepend := UPPER(vr_tab_campos(4));

          ELSE
						-- Fechar cursor
            CLOSE cr_crapdep;
            vr_tpoperac := 1; --> inserção/alteração
          END IF;

					-- Rotina para atualização da tabela de dependentes dos titulares da conta
					cada0015.pc_crapdep( pr_crapdep => rw_crapdep                --> Tabela de dependentes do titular atual
                              ,pr_tpoperacao => vr_tpoperac            --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                              ,pr_idpessoa => NULL                     --> Identificador de pessoa
                              ,pr_cdoperad => 1                        --> Operador que esta efetuando a operacao
                              ,pr_dscritic => vr_dscritic);            --> Retorno de Erro

				WHEN 'TBCADAST_POLITICO_EXPOSTO' THEN
          
          rw_politico_exposto := NULL; -- reiniciar variavel do cursor cr_politico_exposto;
          
          -- Buscar titular politicamento exposto
          OPEN cr_politico_exposto( pr_cdcooper => rw_pessoa_atlz.cdcooper
																	 ,pr_nrdconta => rw_pessoa_atlz.nrdconta
																	 ,pr_idseqttl => rw_pessoa_atlz.idseqttl);
          FETCH cr_politico_exposto INTO rw_politico_exposto;

					-- Se não encontrou registro
          IF cr_politico_exposto%NOTFOUND THEN
						-- Fechar cursor
            CLOSE cr_politico_exposto;
            vr_tpoperac := 3; --> exclusao
						-- Atribuir registro da tabela de pessoa a atualizar
            rw_politico_exposto.cdcooper := rw_pessoa_atlz.cdcooper;
            rw_politico_exposto.nrdconta := rw_pessoa_atlz.nrdconta;
            rw_politico_exposto.idseqttl := rw_pessoa_atlz.idseqttl;

          ELSE
						-- Fechar cursor
            CLOSE cr_politico_exposto;
            vr_tpoperac := 1; --> inserção/alteração
          END IF;

					-- Rotina para atualização da tabela de titular politicamento exposto
					cada0015.pc_politico_exposto( pr_politico_exposto => rw_politico_exposto  --> Tabela de titular politicamento exposto atual
																			 ,pr_tpoperacao => vr_tpoperac                --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
																			 ,pr_idpessoa => NULL                         --> Identificador de pessoa
																			 ,pr_cdoperad => 1                            --> Operador que esta efetuando a operacao
																			 ,pr_dscritic => vr_dscritic);                --> Retorno de Erro

				WHEN 'CRAPTTL' THEN
          
          rw_crapttl := NULL; -- reiniciar variavel do cursor cr_crapttl;
        
          -- Buscar titular da conta
          OPEN cr_crapttl( pr_cdcooper => rw_pessoa_atlz.cdcooper
												  ,pr_nrdconta => rw_pessoa_atlz.nrdconta
												  ,pr_idseqttl => rw_pessoa_atlz.idseqttl);
          FETCH cr_crapttl INTO rw_crapttl;

					-- Se não encontrou registro
          IF cr_crapttl%NOTFOUND THEN
						-- Fechar cursor
            CLOSE cr_crapttl;
            vr_tpoperac := 3; --> exclusao
						-- Atribuir registro da tabela de pessoa a atualizar
            rw_crapttl.cdcooper := rw_pessoa_atlz.cdcooper;
            rw_crapttl.nrdconta := rw_pessoa_atlz.nrdconta;
            rw_crapttl.idseqttl := rw_pessoa_atlz.idseqttl;
            -- Passa o CPF que eh atualizado na trigger quando ocorre delecao
            BEGIN
              rw_crapttl.nrcpfcgc := rw_pessoa_atlz.dschave;
            EXCEPTION
              WHEN OTHERS THEN
                rw_crapttl.nrcpfcgc := 0;
            END;

          ELSE
						-- Fechar cursor
            CLOSE cr_crapttl;
            vr_tpoperac := 1; --> inserção/alteração
          END IF;

					-- Rotina para atualização da tabela de titulares da conta
					cada0015.pc_crapttl( pr_crapttl => rw_crapttl           --> Tabela de titular da conta atual
														  ,pr_tpoperacao => vr_tpoperac       --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
														  ,pr_idpessoa => NULL                --> Identificador de pessoa
														  ,pr_cdoperad => 1                   --> Operador que esta efetuando a operacao
														  ,pr_dscritic => vr_dscritic);       --> Retorno de Erro

          -- Se for um cadastro novo, deve-se enviar para o CRM
          IF nvl(rw_pessoa_atlz.dschave,' ') = 'S' THEN
            pc_envia_cooperado_crm(pr_nrcpfcgc => rw_crapttl.nrcpfcgc);
            
            -- Busca o ID PESSOA do email
            vr_idpessoa := fn_busca_pessoa(pr_cdcooper => rw_crapttl.cdcooper,
                                           pr_nrdconta => rw_crapttl.nrdconta,
                                           pr_idseqttl => rw_crapttl.idseqttl);

            -- Processo da CRAPASS
            -- Busca o ID PESSOA do email
            IF rw_crapttl.idseqttl = 1 THEN
              vr_idinclusao := FALSE;
              rw_conta_comunic_soa := NULL; -- reiniciar variavel do cursor cr_conta_comunic_soa;
              
              -- Busca os dados da ultima inclusao do historico
              OPEN cr_conta_comunic_soa(rw_crapttl.cdcooper, rw_crapttl.nrdconta);
              FETCH cr_conta_comunic_soa INTO rw_conta_comunic_soa;
              IF cr_conta_comunic_soa%NOTFOUND THEN
                vr_idinclusao := TRUE;
              END IF;
              CLOSE cr_conta_comunic_soa;
                  
              IF vr_idinclusao THEN
                
                rw_crapass := NULL; -- reiniciar variavel do cursor cr_crapass;
                
                -- Buscar conta do cooperado
                OPEN cr_crapass( pr_cdcooper => rw_crapttl.cdcooper
                                ,pr_nrdconta => rw_crapttl.nrdconta);
                FETCH cr_crapass INTO rw_crapass;
                CLOSE cr_crapass;
                  
                -- Insere na tabela de capa
                vr_idalteracao := cria_conta_comunic_soa(rw_crapass.cdcooper,
                                                         rw_crapass.nrdconta,
                                                         'CRAPASS');
                                                             
                -- Insere na capa
                BEGIN
                  INSERT INTO tbhistor_crapass
                    (idalteracao, 
                     dhalteracao, 
                     tpoperacao, 
                     cdcooper, 
                     nrdconta, 
                     idpessoa,
                     nrmatric, 
                     tpsituacao_matricula, 
                     cdagenci,
                     dtdemiss)
                   VALUES
                    (vr_idalteracao, 
                     SYSDATE, 
                     1,  -- Inclusao
                     rw_crapass.cdcooper, 
                     rw_crapass.nrdconta, 
                     vr_idpessoa,
                     rw_crapass.nrmatric, 
                     1, 
                     rw_crapass.cdagenci,
                     rw_crapass.dtdemiss);
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir tbhistor_crapass: '||SQLERRM;
                    RAISE vr_exc_erro;
                END;
                
                -- Insere a associacao da pessoa com as contas
                cada0015.pc_cria_pessoa_conta(wp_idalteracao => vr_idalteracao,
                                              wp_intabela    => 1,
                                              wp_idpessoa    => vr_idpessoa,
                                              wp_cdcooper    => rw_crapass.cdcooper,
                                              wp_nrdconta    => rw_crapass.nrdconta);

              END IF;
            END IF;
                
            -- Insere na tabela de capa
            vr_idalteracao := cria_conta_comunic_soa(rw_crapttl.cdcooper,
                                                     rw_crapttl.nrdconta,
                                                     'CRAPTTL');
                                                         
            -- Insere na capa
            BEGIN
              INSERT INTO tbhistor_crapttl
                (idalteracao, 
                 dhalteracao, 
                 tpoperacao, 
                 cdcooper, 
                 nrdconta, 
                 idseqttl,
                 idpessoa)
               VALUES
                (vr_idalteracao, 
                 SYSDATE, 
                 1,  -- Inclusao
                 rw_crapttl.cdcooper, 
                 rw_crapttl.nrdconta, 
                 rw_crapttl.idseqttl,
                 vr_idpessoa);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir tbhistor_crapttl: '||SQLERRM;
                RAISE vr_exc_erro;
            END;
          END IF;

				WHEN 'CRAPENC' THEN
          
          rw_crapenc := NULL; -- reiniciar variavel do cursor cr_crapenc; 
          
          -- Quebrar chave da tabela
          vr_tab_campos := gene0002.fn_quebra_string(rw_pessoa_atlz.dschave,';');

          -- Buscar endereço do cooperado
          OPEN cr_crapenc( pr_cdcooper => vr_tab_campos(1)
												  ,pr_nrdconta => vr_tab_campos(2)
												  ,pr_idseqttl => vr_tab_campos(3)
													,pr_cdseqinc => vr_tab_campos(4));
          FETCH cr_crapenc INTO rw_crapenc;

					-- Se não encontrou registro
          IF cr_crapenc%NOTFOUND THEN
						-- Fechar cursor
            CLOSE cr_crapenc;
            vr_tpoperac := 3; --> exclusao
						-- Atribuir registro da tabela de pessoa a atualizar
            rw_crapenc.cdcooper := vr_tab_campos(1);
            rw_crapenc.nrdconta := vr_tab_campos(2);
            rw_crapenc.idseqttl := vr_tab_campos(3);
            rw_crapenc.cdseqinc := vr_tab_campos(4);
            rw_crapenc.tpendass := vr_tab_campos(5);

          ELSE
						-- Fechar cursor
            CLOSE cr_crapenc;
            vr_tpoperac := 1; --> inserção/alteração
          END IF;

					-- Rotina para atualização da tabela de endereços do cooperado
					CADA0015.pc_crapenc( pr_crapenc => rw_crapenc           --> Tabela de endereço atual
														  ,pr_tpoperacao => vr_tpoperac       --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
														  ,pr_idpessoa => NULL                --> Identificador de pessoa
														  ,pr_cdoperad => 1                   --> Operador que esta efetuando a operacao
														  ,pr_dscritic => vr_dscritic);       --> Retorno de Erro

        WHEN 'CRAPASS' THEN
          
          rw_crapass := NULL; -- reiniciar variavel do cursor cr_crapenc; 
          rw_conta_comunic_soa := NULL; -- reiniciar variavel do cursor cr_conta_comunic_soa;
          rw_crapass_2 := NULL; -- reiniciar variavel do cursor cr_crapass_2;  

          -- Buscar conta do cooperado
          OPEN cr_crapass( pr_cdcooper => rw_pessoa_atlz.cdcooper
												  ,pr_nrdconta => rw_pessoa_atlz.nrdconta);
          FETCH cr_crapass INTO rw_crapass;

					-- Se não encontrou registro
          IF cr_crapass%NOTFOUND THEN
						-- Fechar cursor
            CLOSE cr_crapass;
            vr_tpoperac := 3; --> exclusao
						-- Atribuir registro da tabela de pessoa a atualizar
            rw_crapass.cdcooper := rw_pessoa_atlz.cdcooper;
            rw_crapass.nrdconta := rw_pessoa_atlz.nrdconta;

          ELSE
						-- Fechar cursor
            CLOSE cr_crapass;
            vr_tpoperac := 1; --> inserção/alteração
          END IF;

					-- Rotina para atualização da tabela de associados
					cada0015.pc_crapass( pr_crapass => rw_crapass           --> Tabela de associados atual
														  ,pr_tpoperacao => vr_tpoperac       --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
														  ,pr_idpessoa => NULL                --> Identificador de pessoa
														  ,pr_cdoperad => 1                   --> Operador que esta efetuando a operacao
														  ,pr_dscritic => vr_dscritic);       --> Retorno de Erro

          -- Se for um cadastro novo, deve-se enviar para o CRM
          IF substr(nvl(rw_pessoa_atlz.dschave,' '),1,1) = 'S' THEN
            pc_envia_cooperado_crm(pr_nrcpfcgc => rw_crapass.nrcpfcgc);

            vr_idinclusao := FALSE;
            -- Busca os dados da ultima inclusao do historico
            OPEN cr_conta_comunic_soa(rw_crapass.cdcooper, rw_crapass.nrdconta);
            FETCH cr_conta_comunic_soa INTO rw_conta_comunic_soa;
            IF cr_conta_comunic_soa%NOTFOUND THEN
              vr_idinclusao := TRUE;
            -- Se possuir alguma informacao diferente
            ELSIF rw_conta_comunic_soa.tpsituacao_matricula <> 1 OR
                  rw_conta_comunic_soa.cdagenci <> rw_crapass.cdagenci OR
                  nvl(rw_conta_comunic_soa.dtdemiss,to_date('31/12/2999','DD/MM/YYYY')) <> nvl(rw_crapass.dtdemiss,to_date('31/12/2999','DD/MM/YYYY')) THEN
              vr_idinclusao := TRUE;
            END IF;
              CLOSE cr_conta_comunic_soa;

            IF vr_idinclusao THEN
              -- Busca o ID PESSOA do email
              vr_idpessoa := fn_busca_pessoa(pr_cdcooper => rw_crapass.cdcooper,
                                             pr_nrdconta => rw_crapass.nrdconta,
                                             pr_idseqttl => 1);

              -- Insere na tabela de capa
              vr_idalteracao := cria_conta_comunic_soa(rw_crapass.cdcooper,
                                                       rw_crapass.nrdconta,
                                                       'CRAPASS');
                                                       
              -- Insere na capa
              BEGIN
                INSERT INTO tbhistor_crapass
                  (idalteracao, 
                   dhalteracao, 
                   tpoperacao, 
                   cdcooper, 
                   nrdconta, 
                   idpessoa,
                   nrmatric, 
                   tpsituacao_matricula, 
                   cdagenci,
                   dtdemiss)
                 VALUES
                  (vr_idalteracao, 
                   SYSDATE, 
                   1,  -- Inclusao
                   rw_crapass.cdcooper, 
                   rw_crapass.nrdconta, 
                   vr_idpessoa,
                   rw_crapass.nrmatric, 
                   1, 
                   rw_crapass.cdagenci,
                   rw_crapass.dtdemiss);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir tbhistor_crapass: '||SQLERRM;
                  RAISE vr_exc_erro;
              END;

              -- Insere a associacao da pessoa com as contas
              cada0015.pc_cria_pessoa_conta(wp_idalteracao => vr_idalteracao,
                                            wp_intabela    => 1,
                                            wp_idpessoa    => vr_idpessoa,
                                            wp_cdcooper    => rw_crapass.cdcooper,
                                            wp_nrdconta    => rw_crapass.nrdconta);

            END IF;
          -- Se teve alteracao da data da demissao ou 
          ELSIF substr(nvl(rw_pessoa_atlz.dschave,'   '),3,1) = 'S' THEN
            -- Buscar conta do cooperado
            OPEN cr_crapass_2( pr_cdcooper => rw_crapass.cdcooper
                              ,pr_nrdconta => rw_crapass.nrdconta);
            FETCH cr_crapass_2 INTO rw_crapass_2;
            CLOSE cr_crapass_2;

            vr_idinclusao := FALSE;
            -- Busca os dados da ultima inclusao do historico
            OPEN cr_conta_comunic_soa(rw_crapass.cdcooper, rw_crapass.nrdconta);
            FETCH cr_conta_comunic_soa INTO rw_conta_comunic_soa;
            IF cr_conta_comunic_soa%NOTFOUND THEN
              vr_idinclusao := TRUE;
            -- Se possuir alguma informacao diferente
            ELSIF rw_conta_comunic_soa.tpsituacao_matricula <> rw_crapass_2.tpsituacao_matricula OR
                  rw_conta_comunic_soa.cdagenci <> rw_crapass.cdagenci OR
                  nvl(rw_conta_comunic_soa.dtdemiss,to_date('31/12/2999','DD/MM/YYYY')) <> nvl(rw_crapass.dtdemiss,to_date('31/12/2999','DD/MM/YYYY')) THEN
              vr_idinclusao := TRUE;
            END IF;
              CLOSE cr_conta_comunic_soa;

            IF vr_idinclusao THEN
              -- Busca o ID PESSOA do email
              vr_idpessoa := fn_busca_pessoa(pr_cdcooper => rw_crapass.cdcooper,
                                             pr_nrdconta => rw_crapass.nrdconta,
                                             pr_idseqttl => 1);

              -- Buscar conta do cooperado
              OPEN cr_crapass_2( pr_cdcooper => rw_crapass.cdcooper
                                ,pr_nrdconta => rw_crapass.nrdconta);
              FETCH cr_crapass_2 INTO rw_crapass_2;
              CLOSE cr_crapass_2;
              
              -- Insere na tabela de capa
              vr_idalteracao := cria_conta_comunic_soa(rw_crapass.cdcooper,
                                                       rw_crapass.nrdconta,
                                                       'CRAPASS');
                                                         
              -- Verifica se existe registro pendente de inclusao na CRAPTTL
              OPEN cr_atualiza(rw_crapass.cdcooper,
                               rw_crapass.nrdconta);
              FETCH cr_atualiza INTO vr_tpalteracao;
              IF cr_atualiza%NOTFOUND THEN
                vr_tpalteracao := 2;
              END IF;
              CLOSE cr_atualiza;
              
              -- Insere na capa
              BEGIN
                INSERT INTO tbhistor_crapass
                  (idalteracao, 
                   dhalteracao, 
                   tpoperacao, 
                   cdcooper, 
                   nrdconta, 
                   idpessoa,
                   nrmatric, 
                   tpsituacao_matricula, 
                   cdagenci,
                   dtdemiss)
                 VALUES
                  (vr_idalteracao, 
                   SYSDATE, 
                   vr_tpalteracao,
                   rw_crapass.cdcooper, 
                   rw_crapass.nrdconta, 
                   vr_idpessoa,
                   rw_crapass.nrmatric, 
                   rw_crapass_2.tpsituacao_matricula, 
                   rw_crapass.cdagenci,
                   rw_crapass.dtdemiss);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir na tbhistor_crapass: '||SQLERRM;
                  RAISE vr_exc_erro;
              END;
              
              IF vr_tpalteracao = 1 THEN
                -- Insere a associacao da pessoa com as contas
                cada0015.pc_cria_pessoa_conta(wp_idalteracao => vr_idalteracao,
                                              wp_intabela    => 1,
                                              wp_idpessoa    => vr_idpessoa,
                                              wp_cdcooper    => rw_crapass.cdcooper,
                                              wp_nrdconta    => rw_crapass.nrdconta);
              END IF;
              
            END IF;

          END IF;

			  WHEN 'CRAPJUR' THEN
          
          rw_crapjur := NULL; -- reiniciar variavel do cursor cr_crapjur; 
          
          -- Buscar conta PJ
          OPEN cr_crapjur( pr_cdcooper => rw_pessoa_atlz.cdcooper
												  ,pr_nrdconta => rw_pessoa_atlz.nrdconta);
          FETCH cr_crapjur INTO rw_crapjur;

					-- Se não encontrou registro
          IF cr_crapjur%NOTFOUND THEN
						-- Fechar cursor
            CLOSE cr_crapjur;
            vr_tpoperac := 3; --> exclusao
						-- Atribuir registro da tabela de pessoa a atualizar
            rw_crapjur.cdcooper := rw_pessoa_atlz.cdcooper;
            rw_crapjur.nrdconta := rw_pessoa_atlz.nrdconta;

          ELSE
						-- Fechar cursor
            CLOSE cr_crapjur;
            vr_tpoperac := 1; --> inserção/alteração
          END IF;

					-- Rotina para atualização da tabela de contas PJ
					cada0015.pc_crapjur( pr_crapjur => rw_crapjur           --> Tabela de conta PJ atual
														  ,pr_tpoperacao => vr_tpoperac       --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
														  ,pr_idpessoa => NULL                --> Identificador de pessoa
														  ,pr_cdoperad => 1                   --> Operador que esta efetuando a operacao
														  ,pr_dscritic => vr_dscritic);       --> Retorno de Erro

			  WHEN 'CRAPJFN' THEN
          
          rw_crapjfn := NULL; -- reiniciar variavel do cursor cr_crapjur; 
          
          -- Buscar dados financeiros dos cooperados PJ
          OPEN cr_crapjfn( pr_cdcooper => rw_pessoa_atlz.cdcooper
												  ,pr_nrdconta => rw_pessoa_atlz.nrdconta);
          FETCH cr_crapjfn INTO rw_crapjfn;

					-- Se não encontrou registro
          IF cr_crapjfn%NOTFOUND THEN
						-- Fechar cursor
            CLOSE cr_crapjfn;
            vr_tpoperac := 3; --> exclusao
						-- Atribuir registro da tabela de pessoa a atualizar
            rw_crapjfn.cdcooper := rw_pessoa_atlz.cdcooper;
            rw_crapjfn.nrdconta := rw_pessoa_atlz.nrdconta;

          ELSE
						-- Fechar cursor
            CLOSE cr_crapjfn;
            vr_tpoperac := 1; --> inserção/alteração
          END IF;

					-- Rotina para atualização da tabela de dados financeiros de contas PJ
					cada0015.pc_crapjfn( pr_crapjfn => rw_crapjfn           --> Tabela de dados financeiros de contas PJ atual
														  ,pr_tpoperacao => vr_tpoperac       --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
														  ,pr_idpessoa => NULL                --> Identificador de pessoa
														  ,pr_cdoperad => 1                   --> Operador que esta efetuando a operacao
														  ,pr_dscritic => vr_dscritic);       --> Retorno de Erro

				WHEN 'CRAPOPI' THEN
          
          rw_atualiza_opi := NULL; -- reiniciar variavel do cursor cr_atualiza_opi; 
          rw_crapopi := NULL; -- reiniciar variavel do cursor cr_crapopi; 

          -- Quebrar chave da tabela
          vr_tab_campos := gene0002.fn_quebra_string(rw_pessoa_atlz.dschave,';');

          -- Verifica se existe mais de um registro para processar. Em caso
          -- positivo, ignora o registro atual, pois sera processado somente no ultimo
          -- registro pendente da TBCADAST_PESSOA_ATUALIZA.
          -- Isso se faz necessário para nao inserir duas vezes o mesmo registro, 
          -- gerando assim erro no SOA
          OPEN cr_atualiza_opi(rw_pessoa_atlz.cdcooper,
                               rw_pessoa_atlz.nrdconta,
                               rw_pessoa_atlz.dschave);
          FETCH cr_atualiza_opi INTO rw_atualiza_opi;
          CLOSE cr_atualiza_opi;

          IF rw_atualiza_opi.qt_registro < 2 THEN

          -- Buscar registro de avalista terceiro, contato (PF) ou referencia comercial/bancaria (PJ)
          OPEN cr_crapopi( pr_cdcooper => rw_pessoa_atlz.cdcooper,
													 pr_nrdconta => rw_pessoa_atlz.nrdconta,
													 pr_nrcpfope => vr_tab_campos(1));

          FETCH cr_crapopi INTO rw_crapopi;
					-- Se não encontrou registro
          IF cr_crapopi%NOTFOUND THEN
						-- Fechar cursor
            CLOSE cr_crapopi;
            vr_tpoperac := 3; --> exclusao
						-- Atribuir registro da tabela de pessoa a atualizar
            rw_crapopi.cdcooper := rw_pessoa_atlz.cdcooper;
            rw_crapopi.nrdconta := rw_pessoa_atlz.nrdconta;
            rw_crapopi.nrcpfope := vr_tab_campos(1);

          ELSE
						-- Fechar cursor
            CLOSE cr_crapopi;
            vr_tpoperac := 1; --> inserção/alteração
          END IF;

					-- Rotina para atualização da tabela de operadores de internet
					cada0015.pc_crapopi( pr_crapopi => rw_crapopi                --> Tabela de operadores
                              ,pr_tpoperacao => vr_tpoperac            --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                              ,pr_idpessoa => NULL                     --> Identificador de pessoa
                              ,pr_cdoperad => 1                        --> Operador que esta efetuando a operacao
                              ,pr_dscritic => vr_dscritic);            --> Retorno de Erro
          END IF;                                
        ELSE
          vr_dscritic := 'Tabela nao configurada.';

      END CASE;

      --> Verificar se gerou critica
      IF vr_dscritic IS NOT NULL THEN
				-- Efetuar rollback
        ROLLBACK;
        -- PRB0040696 - Tratar casos de Deadlock, onde o processo será executado novamente 
        -- na próxima execucao e apenas iremos gerar o alerta, sem envio de email
        IF  UPPER(rw_pessoa_atlz.nmtabela) = 'CRAPTTL' AND instr(vr_dscritic,'ORA-00060') >= 1 THEN
          --> Apenas alertar e manter situacao pendente de processamento
          vr_tpincons := 1;
          vr_insit_atualiza := rw_pessoa_atlz.insit_atualiza; 
        ELSE
          --> Manter erro
          vr_tpincons := 2;
          vr_insit_atualiza := 3; 
        END IF;

        -- Insere na inconsistencia
        gene0005.pc_gera_inconsistencia(pr_cdcooper => nvl(rw_pessoa_atlz.cdcooper,3)
                                       ,pr_iddgrupo => 3 -- Erros de Script CRM
                                       ,pr_tpincons => vr_tpincons
                                       ,pr_dsregist => ' Cooper  : '||rw_pessoa_atlz.cdcooper ||
                                                       ' Conta   : '||rw_pessoa_atlz.nrdconta ||
                                                       ' Seq.tit.: '||rw_pessoa_atlz.idseqttl ||
                                                       ' Dt.Atlz.: '||to_char(rw_pessoa_atlz.dhatualiza,'DD/MM/RRRR HH24:MI:SS')
                                       ,pr_dsincons => substr('Atualização tabela '||rw_pessoa_atlz.nmtabela ||
                                                       ': '||vr_dscritic,1,500)
                                       ,pr_des_erro => vr_des_erro
                                       ,pr_dscritic => vr_dscritic);

        IF vr_des_erro <> 'OK' THEN
          RAISE vr_exc_erro;
        END IF;
      ELSE
        vr_insit_atualiza := 2; --> Processado
      END IF;

      --> Atualizar tabela de controle
      BEGIN
        UPDATE tbcadast_pessoa_atualiza atl
           SET atl.insit_atualiza = vr_insit_atualiza,
               atl.dhprocessa     =  SYSDATE
          WHERE atl.rowid         =  rw_pessoa_atlz.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar :'||SQLERRM;
          RAISE vr_exc_erro;
      END;

			-- Efetuar commit
      COMMIT;

    END LOOP;


	EXCEPTION
    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;

      -- Insere na inconsistencia
      gene0005.pc_gera_inconsistencia(pr_cdcooper => 3
                                     ,pr_iddgrupo => 3 -- Erros de Script CRM
                                     ,pr_tpincons => 2
                                     ,pr_dsregist => ' '
                                     ,pr_dsincons => substr('Atualização tabela '||vr_nmtabela ||
                                                     ': '||pr_dscritic,1,500)
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);

      IF vr_des_erro <> 'OK' THEN
        raise_application_error(-20500,vr_dscritic||': '||pr_dscritic);
      END IF;

    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro nao tratado na pc_processa_pessoa_atlz: '||SQLERRM;

      -- Insere na inconsistencia
      gene0005.pc_gera_inconsistencia(pr_cdcooper => 3
                                     ,pr_iddgrupo => 3 -- Erros de Script CRM
                                     ,pr_tpincons => 2
                                     ,pr_dsregist => ' '
                                     ,pr_dsincons => substr('Atualização tabela '||vr_nmtabela ||
                                                     ': '||pr_dscritic,1,500)
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);

      IF vr_des_erro <> 'OK' THEN
        raise_application_error(-20500,vr_dscritic||': '||pr_dscritic);
      END IF;

  END pc_processa_pessoa_atlz;


END CADA0015;
/
