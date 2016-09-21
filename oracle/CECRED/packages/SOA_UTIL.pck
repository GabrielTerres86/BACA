CREATE OR REPLACE PACKAGE CECRED.SOA_UTIL IS
  ---------------------------------------------------------------------------
  --
  --  Programa : SOA_UTIL
  --  Sistema  : Fun��es �teis para utiliza��o no Aymaru
  --  Sigla    : SOA_UTIL
  --  Autor    : Anderson Fossa
  --  Data     : Setembro/2016.                   Ultima atualizacao: 
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Centralizar fun��es �teis para utiliza��o no Aymaru.
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
  --> Retornar o saldo do contrado do cooperado
  FUNCTION fn_caract_acento(pr_texto IN VARCHAR2,                                                     --> String para limpeza
                            pr_insubsti IN PLS_INTEGER DEFAULT 0,                                     --> Flag para substituir
                            pr_dssubsin IN VARCHAR2 DEFAULT '@#$&%������*!?<>/\|',                    --> String de entrada
                            pr_dssubout IN VARCHAR2 DEFAULT '                   ') RETURN VARCHAR2;   --> String de saida
  

  
END SOA_UTIL;
/
CREATE OR REPLACE PACKAGE BODY CECRED.SOA_UTIL IS

    FUNCTION fn_caract_acento(pr_texto IN VARCHAR2,                                                   --> String para limpeza
                            pr_insubsti IN PLS_INTEGER DEFAULT 0,                                     --> Flag para substituir
                            pr_dssubsin IN VARCHAR2 DEFAULT '@#$&%������*!?<>/\|',                    --> String de entrada
                            pr_dssubout IN VARCHAR2 DEFAULT '                   ') RETURN VARCHAR2 IS --> String de saida
    -- ..........................................................................
    --
    --  Programa : fn_caract_acento
    --  Sistema  : Rotina para remo��o de Acento
    --  Sigla    : SOA_UTIL
    --  Autor    : Anderson Fossa
    --  Data     : Setembro/2016.                   Ultima atualizacao: 
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Disponibilizar a fun��o de remo��o de acentos e caracteres especiais 
    --              no Aymaru.
    -- .............................................................................
  BEGIN
      
      RETURN GENE0007.fn_caract_acento(pr_texto    => pr_texto
                                      ,pr_insubsti => pr_insubsti
                                      ,pr_dssubsin => pr_dssubsin
                                      ,pr_dssubout => pr_dssubout);
  END fn_caract_acento;
                                                              	
END SOA_UTIL;
/
