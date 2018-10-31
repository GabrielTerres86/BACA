CREATE OR REPLACE PACKAGE RISC0005 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RISC0005
  --  Sistema  : Aimaro
  --  Sigla    : CRED
  --  Autor    : Marcos (Envolti)
  --  Data     : Outubro/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos e funções auxiliares para carga e visualização de Score Behaviour (P442)
  --
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Retorna o Score Behaviour do Cooperado enviado
  FUNCTION fn_score_behaviour(pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE) RETURN VARCHAR2;

END RISC0005;
/
CREATE OR REPLACE PACKAGE BODY RISC0005 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RISC0005
  --  Sistema  : Aimaro
  --  Sigla    : CRED
  --  Autor    : Marcos (Envolti)
  --  Data     : Outubro/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos e funções auxiliares para carga e visualização de Score Behaviour (P442)
  --
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Retorna o Score Behaviour do Cooperado enviado
  FUNCTION fn_score_behaviour(pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE) RETURN VARCHAR2 IS
  BEGIN
    /*OPEN RISC0004.cr_dat(pr_cdcooper);
    FETCH RISC0004.cr_dat INTO rw_dat;
    CLOSE RISC0004.cr_dat;*/
    RETURN 123;
  END fn_score_behaviour;

END RISC0005;
/
