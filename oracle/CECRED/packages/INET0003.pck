CREATE OR REPLACE PACKAGE CECRED.INET0003 IS
  /*---------------------------------------------------------------------------------------------------------------
    Programa : INET0003
    Sistema  : 
    Sigla    : INET
    Autor    : Paulo Penteado GFT 
    Data     : Junho/2018

    Dados referentes ao programa:

    Objetivo  : Rotinas para gravação e leitura da estrutura de Token das transações no Internet Bank

    Alteracoes: 23/06/2018 Criação (Paulo Penteado GFT)

  ---------------------------------------------------------------------------------------------------------------*/

  -- Procedure para criar TOKEN
  PROCEDURE pc_cria_autenticacao_ib(pr_cdcooper	   IN	NUMBER   --> Codigo que identifica a Cooperativa
                                   ,pr_nrdconta	   IN	NUMBER   --> Numero da conta/dv do associado
                                   ,pr_idseqttl	   IN NUMBER   --> Indentificacao de titularidade da conta
                                   ,pr_nrcpfope	   IN NUMBER   --> CPF do operador de conta juridica
                                   ,pr_tokenib    OUT VARCHAR2 --> Token gerado na transação
                                   ,pr_dscritic   OUT VARCHAR2 --> Retornar Critica
                                   );

  -- Procedure para validar o TOKEN de autenticação
  PROCEDURE pc_utiliza_autenticacao_ib(pr_cdcooper IN NUMBER    --> Código da cooperativa
                                      ,pr_nrdconta IN NUMBER    --> Número da Conta do associado
                                      ,pr_tokenib  IN VARCHAR2  --> Token gerado na transação
                                      ,pr_dscritic OUT VARCHAR2 --> Retornar Critica
                                      );

END INET0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.INET0003 IS
  /*---------------------------------------------------------------------------------------------------------------
    Programa : INET0003
    Sistema  : 
    Sigla    : INET
    Autor    : Paulo Penteado GFT 
    Data     : Junho/2018

    Dados referentes ao programa:

    Objetivo  : Rotinas para gravação e leitura da estrutura de Token das transações no Internet Bank

    Alteracoes: 23/06/2018 Criação (Paulo Penteado GFT)

  ---------------------------------------------------------------------------------------------------------------*/

  PROCEDURE pc_cria_autenticacao_ib(pr_cdcooper    IN NUMBER   --> Codigo que identifica a Cooperativa
                                   ,pr_nrdconta    IN NUMBER   --> Numero da conta/dv do associado
                                   ,pr_idseqttl    IN NUMBER   --> Indentificacao de titularidade da conta
                                   ,pr_nrcpfope    IN NUMBER   --> CPF do operador de conta juridica
                                   ,pr_tokenib    OUT VARCHAR2 --> Token gerado na transação
                                   ,pr_dscritic   OUT VARCHAR2 --> Retornar Critica
                                   ) IS 
  /*---------------------------------------------------------------------------------------------------------
    Programa : pc_cria_autenticacao_ib
    Sistema  : 
    Sigla    : INET
    Autor    : Paulo Penteado (GFT)
    Data     : Junho/2018

    Objetivo  : Procedure para criar o token de autenticação de uma transação no Internet Bank

                pr_idtransacao = 1-Bordero Desc. Tit.

    Alteração : 26/03/2018 - Criação (Paulo Penteado (GFT))

  ----------------------------------------------------------------------------------------------------------*/
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_erro EXCEPTION;

  BEGIN
    BEGIN
      INSERT INTO tbib_autentica_transacao 
             (/*01*/ cdcooper
             ,/*02*/ nrdconta
             ,/*03*/ idseqttl
             ,/*04*/ nrcpfope
             ,/*05*/ dtcriacao
             ,/*06*/ flagativo
             ,/*07*/ dtencerramento)
      VALUES (/*01*/ pr_cdcooper
             ,/*02*/ pr_nrdconta
             ,/*03*/ pr_idseqttl
             ,/*04*/ pr_nrcpfope
             ,/*05*/ SYSDATE
             ,/*06*/ 1
             ,/*07*/ NULL
             )
      RETURNING ROWID 
      INTO      pr_tokenib;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir tbib_autentica_transacao: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral rotina INET0003.pc_cria_autenticacao_ib: '||SQLERRM;
      ROLLBACK;
  END pc_cria_autenticacao_ib;


  PROCEDURE pc_utiliza_autenticacao_ib(pr_cdcooper IN NUMBER    --> Código da cooperativa
                                      ,pr_nrdconta IN NUMBER    --> Número da Conta do associado
                                      ,pr_tokenib  IN VARCHAR2  --> Token gerado na transação
                                      ,pr_dscritic OUT VARCHAR2 --> Retornar Critica
                                      ) IS
  /*---------------------------------------------------------------------------------------------------------
    Programa : pc_utiliza_autenticacao_ib
    Sistema  : 
    Sigla    : INET
    Autor    : Paulo Penteado (GFT)
    Data     : Junho/2018

    Objetivo  : Procedure para validar o token de autenticação criado em uma transação no Internet Bank

    Alteração : 26/03/2018 - Criação (Paulo Penteado (GFT))

  ----------------------------------------------------------------------------------------------------------*/
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_erro EXCEPTION;
    vr_existe   VARCHAR2(1);

    CURSOR cr_token IS
    SELECT cdcooper
          ,nrdconta
          ,flagativo
          ,rowid
    FROM   tbib_autentica_transacao 
    WHERE  rowid = pr_tokenib;
  BEGIN
    vr_existe := 'N';

    FOR rw_token IN cr_token LOOP
      -- Validar se o TOKEN é valido
      IF rw_token.flagativo <> 1 THEN
        vr_dscritic := 'Token IB inválido';
        RAISE vr_exc_erro;
      
      ELSIF rw_token.cdcooper <> pr_cdcooper THEN
        vr_dscritic := 'Token IB inválido';
        RAISE vr_exc_erro;         
      
      ELSIF rw_token.nrdconta <> pr_nrdconta THEN
        vr_dscritic := 'Token IB inválido';
        RAISE vr_exc_erro;  
      END IF;
      
      vr_existe := 'S';

      -- Inativar o TOKEN para que não seja utilizado novamente
      UPDATE tbib_autentica_transacao
      SET    tbib_autentica_transacao.flagativo = 0
            ,tbib_autentica_transacao.dtencerramento = SYSDATE
      WHERE  tbib_autentica_transacao.rowid = rw_token.rowid; 
    END LOOP;

    IF vr_existe = 'N' THEN
      vr_dscritic := 'Token IB inválido';
      RAISE vr_exc_erro;       
    END IF; 

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      pr_dscritic := 'Token IB inválido';
      ROLLBACK;
  END pc_utiliza_autenticacao_ib;

END INET0003;
/
