CREATE OR REPLACE PACKAGE PROGRID.WPGD0193 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : WPGD0193
  --  Sistema  : Rotinas referentes ao WebService de Interfaces do SGE com o Konviva
  --  Autor    : Márcio José de Carvalho (Mouts)
  --  Data     : Fevereiro - 2017.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao WebService de Interface do SGE com a plataforma EAD Konviva
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------

  -- Efetuar a validação da conta informada pelo usuário no cadastro do Konviva
  PROCEDURE pc_valida_conta(pr_cdcooper    IN NUMBER,  -- cooperativa informado pelo usuário no cadastro do Konviva
                            pr_nrcpfcta    IN NUMBER,  -- CPF do usuário que está efetuando o cadastro -- Sem formatação 
                            pr_nrdconta    IN NUMBER,  -- Numero da conta do usuário que está efetuando o cadastro -- Sem formatação 
                            pr_cdretval   OUT NUMBER,  -- Codigo de retorno onde 1 - Conta Existente, 2 - Conta Inexistente ou 3 - Demitido
                            pr_cdcritic   OUT NUMBER,  -- Codigo da critica
                            pr_dscritic   OUT VARCHAR2, -- Texto de erro/critica encontrada   
                            pr_nrpaconta  OUT NUMBER    -- PA da CONTA                   
);

END WPGD0193;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0193 IS

  -- Efetuar a validação da conta informada pelo usuário no cadastro do Konviva
  PROCEDURE pc_valida_conta(pr_cdcooper    IN NUMBER,  -- cooperativa informado pelo usuário no cadastro do Konviva
                            pr_nrcpfcta    IN NUMBER,  -- CPF do usuário que está efetuando o cadastro -- Sem formatação 
                            pr_nrdconta    IN NUMBER,  -- Numero da conta do usuário que está efetuando o cadastro -- Sem formatação 
                            pr_cdretval   OUT NUMBER,  -- Codigo de retorno onde 1 - Conta Existente, 2 - Conta Inexistente ou 3 - Demitido
                            pr_cdcritic   OUT NUMBER,  -- Codigo da critica
                            pr_dscritic   OUT VARCHAR2, -- Texto de erro/critica encontrada
                            pr_nrpaconta  OUT NUMBER    -- PA da CONTA 
) IS 

   /* .............................................................................

       Programa: pc_valida_conta
       Sistema : PROGRID
       Sigla   : CRED
       Autor   : 
       Data    :                            Ultima atualizacao: 12/09/2017

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : 
       
       Alteracoes: 12/09/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                          crapass, crapttl, crapjur 
              							    (Adriano - P339).

    ..............................................................................*/
    
    vr_inpessoa crapass.inpessoa%TYPE;
    vr_dtdemiss crapass.dtdemiss%TYPE;
    vr_cdsitdct crapass.cdsitdct%TYPE;

    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro   
    vr_exc_saida  EXCEPTION; --> Excecao prevista

  BEGIN
    -- Verificar se a conta existe
    BEGIN
      SELECT 
             c.inpessoa,
             c.dtdemiss,
             c.cdsitdct,
             99, -- Atribui valor 99 para identificar que a conta existe
             c.cdagenci
        INTO
             vr_inpessoa,
             vr_dtdemiss,
             vr_cdsitdct,
             pr_cdretval,
             pr_nrpaconta
        FROM
             CECRED.crapass c

       WHERE
            c.cdcooper = pr_cdcooper
        and c.nrdconta = pr_nrdconta;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN      
         -- Se conta não existe
         pr_cdretval:= 2; -- Conta Inexistente  
         pr_nrpaconta:=0;   
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao selecionar na tabela crapass: '||SQLERRM;
        RAISE vr_exc_saida;            
    END;
    -- Se conta existe
    IF pr_cdretval = 99 THEN
      -- Se conta existe e dtdemiss não é nula - Demitido
      IF vr_dtdemiss is not null THEN
        pr_cdretval:= 3; -- Demitido  
        pr_nrpaconta:=0;     
      ELSE
        IF vr_inpessoa = 1 THEN -- Pessoa Física
          --validar na CRAPTTL se o CPF informado existe
          BEGIN
            SELECT
                   1 -- Conta existente
            INTO
                   pr_cdretval
            FROM
                   crapttl ct
            WHERE
                   ct.cdcooper = pr_cdcooper
               and ct.nrdconta = pr_nrdconta
               and ct.nrcpfcgc = pr_nrcpfcta;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
            -- Se o CPF passado como parâmetro não estiver associado a conta passada como parâmetro,
            -- Considerar como conta inexistente
            pr_cdretval:= 2; -- Conta Inexistente                           
            pr_nrpaconta:=0;     
           WHEN OTHERS THEN
             vr_dscritic := 'Erro ao selecionar na tabela crapttl: '||SQLERRM;
             RAISE vr_exc_saida;            
          END;
          
        ELSIF vr_inpessoa = 2 THEN --Pessoa Jurídica
          --validar na CRAPAVT se o CPF informado existe para tipo 6  
          BEGIN
            SELECT
                   1 -- Conta existente
            INTO
                   pr_cdretval
            FROM
                   crapavt ca
            WHERE
                   ca.cdcooper = pr_cdcooper
               and ca.nrdconta = pr_nrdconta
               and ca.nrcpfcgc = pr_nrcpfcta
               and ca.tpctrato = 6; -- PJ
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
            -- Se o CPF passado como parâmetro não estiver associado a conta passada como parâmetro,
            -- Considerar como conta inexistente
              pr_cdretval:= 2; -- Conta Inexistente                           
              pr_nrpaconta:=0;     
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao selecionar na tabela crapavt: '||SQLERRM;
              RAISE vr_exc_saida;            
          END;
        ELSE -- Considera como conta inexistente
         pr_cdretval:= 2; -- Conta Inexistente               
         pr_nrpaconta:=0;              
        END IF;
      END IF;
    END IF;
--      pr_dhbloqueio := to_char(vr_dhbloqueio,'DD/MM/YYYY hh24:mi:ss');
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
           
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      -- Desfaz o que foi feito
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro BLQJ0002.pc_recebe_solicitacao: '||sqlerrm;

      -- Desfaz o que foi feito
      ROLLBACK;            
  END pc_valida_conta;
END WPGD0193;
/
