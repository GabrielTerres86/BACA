CREATE OR REPLACE PACKAGE SOA.SOA_INTERFACE_KONVIVA IS
  ---------------------------------------------------------------------------
  --
  --  Programa : SOA_INTERFACE_KONVIVA
  --  Sistema  : Rotinas referentes ao WebService de Interfaces do SGE com o Konviva
  --  Autor    : M�rcio Jos� de Carvalho (Mouts)
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

  -- Efetuar a valida��o da conta informada pelo usu�rio no cadastro do Konviva
  PROCEDURE pc_valida_conta(pr_cdcooper    IN NUMBER,  -- cooperativa informado pelo usu�rio no cadastro do Konviva
                            pr_nrcpfcta    IN NUMBER,  -- CPF do usu�rio que est� efetuando o cadastro -- Sem formata��o 
                            pr_nrdconta    IN NUMBER,  -- Numero da conta do usu�rio que est� efetuando o cadastro -- Sem formata��o 
                            pr_cdretval   OUT NUMBER,  -- Codigo de retorno onde 1 - Conta Existente, 2 - Conta Inexistente ou 3 - Demitido
                            pr_cdcritic   OUT NUMBER,  -- Codigo da critica
                            pr_dscritic   OUT VARCHAR2, -- Texto de erro/critica encontrada
                            pr_nrpaconta  OUT NUMBER    -- PA da CONTA 
                            
);

END SOA_INTERFACE_KONVIVA;
/
CREATE OR REPLACE PACKAGE BODY SOA.SOA_INTERFACE_KONVIVA IS

 
  
  -- Efetuar a valida��o da conta informada pelo usu�rio no cadastro do Konviva
  PROCEDURE pc_valida_conta(pr_cdcooper    IN NUMBER,  -- cooperativa informado pelo usu�rio no cadastro do Konviva
                            pr_nrcpfcta    IN NUMBER,  -- CPF do usu�rio que est� efetuando o cadastro -- Sem formata��o 
                            pr_nrdconta    IN NUMBER,  -- Numero da conta do usu�rio que est� efetuando o cadastro -- Sem formata��o 
                            pr_cdretval   OUT NUMBER,  -- Codigo de retorno onde 1 - Conta Existente, 2 - Conta Inexistente ou 3 - Demitido
                            pr_cdcritic   OUT NUMBER,  -- Codigo da critica
                            pr_dscritic   OUT VARCHAR2, -- Texto de erro/critica encontrada
                            pr_nrpaconta  OUT NUMBER    -- PA da CONTA 
                            
) IS 
  BEGIN
    BEGIN
    -- Chama a rotina de valida��o original
      progrid.wpgd0193.pc_valida_conta(pr_cdcooper => pr_cdcooper,
                                       pr_nrcpfcta => pr_nrcpfcta,
                                       pr_nrdconta => pr_nrdconta,
                                       pr_cdretval => pr_cdretval,     
                                       pr_cdcritic => pr_cdcritic,    
                                       pr_dscritic => pr_dscritic,
                                       pr_nrpaconta=> pr_nrpaconta );
    END;
    IF pr_dscritic IS NULL THEN
      pr_cdcritic := 0;
    ELSE
      pr_cdcritic := 90;
    END IF;    
  END pc_valida_conta;
END SOA_INTERFACE_KONVIVA;
/
