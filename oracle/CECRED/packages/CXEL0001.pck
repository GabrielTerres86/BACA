CREATE OR REPLACE PACKAGE CECRED.CXEL0001 is
  /*---------------------------------------------------------------------------------------------------------------
   --
  --  Programa : CXEL0001
  --  Sistema  : CRM
  --  Sigla    : CXEL - CAIXA ELETR�NICO
  --  Autor    : Everton Souza - Mouts
  --  Data     : Abril/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para grava��o e leitura da estrutura de Token no TAA
  --
  -- Alteracoes:
  --
  --
  ---------------------------------------------------------------------------------------------------------------*/


  /*****************************************************************************/
  /**            Procedure para criar TOKEN de autentica��o do cart�o TAA     **/
  /*****************************************************************************/
  PROCEDURE pc_cria_autenticacao_cartao(pr_cdcooper    IN NUMBER     --> C�digo da cooperativa
                                       ,pr_nrdconta    IN NUMBER     --> N�mero da Conta do associado
                                       ,pr_nrcartao    IN VARCHAR2    --> N�mero do cart�o do associado
                                       ,pr_cdoperacao  IN VARCHAR2   --> ID da Opera��o que est� sendo executado (Ex: "IB027","TA037","IB181") 
                                       ,pr_tpinteracao IN VARCHAR2   --> Tipo de Intera��o (O IB181 , al�m de outros, que possuim mais de uma operacao mas sempre sao chamados pelo mesmo codigo)
                                       ,pr_token      OUT VARCHAR2   --> Token gerado na transa��o
                                       ,pr_dscritic   OUT VARCHAR2   --> Retornar Critica
                                        );

  /*****************************************************************************/
  /**            Procedure para buscar TOKEN de autentica��o do cart�o TAA    **/
  /*****************************************************************************/
  PROCEDURE pc_busca_autenticacao_cartao(pr_cdcooper    IN NUMBER     --> C�digo da cooperativa
                                        ,pr_nrdconta    IN NUMBER     --> N�mero da Conta do associado
                                        ,pr_token       IN VARCHAR2   --> Token gerado na transa��o
                                        ,pr_dscritic    OUT VARCHAR2  --> Retornar Critica
                                        );

END CXEL0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CXEL0001 IS
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CXEL0001
  --  Sistema  : CRM
  --  Sigla    : CXEL - CAIXA ELETR�NICO
  --  Autor    : Everton Souza - Mouts
  --  Data     : Abril/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para grava��o e leitura da estrutura de Token no TAA
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------*/


  /*****************************************************************************/
  /**            Procedure para criar TOKEN de autentica��o do cart�o TAA     **/
  /*****************************************************************************/
  PROCEDURE pc_cria_autenticacao_cartao(pr_cdcooper    IN NUMBER     --> C�digo da cooperativa
                                       ,pr_nrdconta    IN NUMBER     --> N�mero da Conta do associado
                                       ,pr_nrcartao    IN VARCHAR2    --> N�mero do cart�o do associado
                                       ,pr_cdoperacao  IN VARCHAR2   --> ID da Opera��o que est� sendo executado (Ex: "IB027","TA037","IB181") 
                                       ,pr_tpinteracao IN VARCHAR2   --> Tipo de Intera��o (O IB181 , al�m de outros, que possuim mais de uma operacao mas sempre sao chamados pelo mesmo codigo)
                                       ,pr_token      OUT VARCHAR2   --> Token gerado na transa��o
                                       ,pr_dscritic   OUT VARCHAR2   --> Retornar Critica
                                        ) IS

  /* ..........................................................................
    --
    --  Programa : pc_cria_autenticacao_cartao
    --  Autor    : Everton Souza(Mouts)
    --  Data     : Abril/2018.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para criar TOKEN de autentica��o do cart�o TAA
    --
    --  Altera��o :
    --
    --
    -- ..........................................................................*/

    ---------------> VARIAVEIS <-----------------
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION;

  BEGIN
     --Em caso de exclusao deve ser limpo os campos
     BEGIN
        INSERT INTO tbtaa_autenticacao_cartao 
        (cdcooper
        ,nrdconta
        ,nrcartao
        ,cdoperacao
        ,tpinteracao
        ,flagativo
        ,dtcriacao
        ,dtencerramento        
        )
        VALUES
        (pr_cdcooper
        ,pr_nrdconta
        ,to_number(pr_nrcartao)
        ,pr_cdoperacao
        ,NVL(pr_tpinteracao,' ') 
        ,1
        ,SYSDATE
        ,NULL
        )
        RETURNING ROWID 
             INTO pr_token;       
     EXCEPTION
       WHEN OTHERS THEN
         vr_dscritic := 'Erro ao inserir tbtaa_autenticacao_cartao: '||SQLERRM;
         RAISE vr_exc_erro;
     END;
     --
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral rotina CXEL0001.pc_cria_autenticacao_cartao: '||SQLERRM;
  END pc_cria_autenticacao_cartao;

  /*****************************************************************************/
  /**            Procedure para buscar TOKEN de autentica��o do cart�o TAA    **/
  /*****************************************************************************/
  PROCEDURE pc_busca_autenticacao_cartao(pr_cdcooper    IN NUMBER     --> C�digo da cooperativa
                                        ,pr_nrdconta    IN NUMBER     --> N�mero da Conta do associado
                                        ,pr_token       IN VARCHAR2   --> Token gerado na transa��o
                                        ,pr_dscritic    OUT VARCHAR2  --> Retornar Critica
                                        ) IS

  /* ..........................................................................
    --
    --  Programa : pc_cria_autenticacao_cartao
    --  Autor    : Everton Souza(Mouts)
    --  Data     : Abril/2018.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para buscar TOKEN de autentica��o do cart�o TAA
    --
    --  Altera��o :
    --
    --
    -- ..........................................................................*/

    ---------------> CURSORES <-----------------
    -- Buscar informa��es da pessoa
    CURSOR cr_token IS
      SELECT cdcooper,
             nrdconta,
             flagativo,
             rowid
        FROM tbtaa_autenticacao_cartao 
       WHERE rowid = pr_token;    
       
    ---------------> VARIAVEIS <-----------------
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION;
    vr_existe      VARCHAR2(1):='N';

  BEGIN
    FOR rw_token IN cr_token LOOP
       -- Validar se o TOKEN � valido
       IF rw_token.flagativo <> 1 THEN
          vr_dscritic := 'Senha inv�lida';
          RAISE vr_exc_erro;
       ELSIF rw_token.cdcooper <> pr_cdcooper then
          vr_dscritic := 'Senha inv�lida';
          RAISE vr_exc_erro;         
       ELSIF rw_token.nrdconta <> pr_nrdconta then
          vr_dscritic := 'Senha inv�lida';
          RAISE vr_exc_erro;  
       END IF;
       --
       vr_existe := 'S';

       -- Inativar o TOKEN para que n�o seja utilizado novamente
       UPDATE tbtaa_autenticacao_cartao
          SET tbtaa_autenticacao_cartao.flagativo = 0,
              tbtaa_autenticacao_cartao.dtencerramento = SYSDATE
        WHERE tbtaa_autenticacao_cartao.rowid = rw_token.rowid; 
    END LOOP;
    --
    IF vr_existe = 'N' THEN
       vr_dscritic := 'Senha inv�lida';
       RAISE vr_exc_erro;       
    END IF; 
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Senha inv�lida';
  END pc_busca_autenticacao_cartao;

END CXEL0001;
/
