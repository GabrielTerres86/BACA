CREATE OR REPLACE PACKAGE SOA.SOA_SMS IS
  -- ..........................................................................
    --
    --  Programa : SOA_SMS
    --  Sigla    : SOA_SMS
    --  Autor    : Anderson Fossa
    --  Data     : Setembro/2017.                   Ultima atualizacao: 
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Centralizar funcoes para utilizacao do SMS atraves do Aymaru / Zenvia.
    --
    -- .............................................................................
  --> Retornar o saldo do contrado do cooperado
  FUNCTION fn_busca_token_zenvia(pr_cdproduto IN NUMBER) RETURN VARCHAR2; --> Codigo do Produto utilizado para o servico SMS 
  
END SOA_SMS;
/
CREATE OR REPLACE PACKAGE BODY SOA.SOA_SMS IS

    FUNCTION fn_busca_token_zenvia(pr_cdproduto IN NUMBER) RETURN VARCHAR2 IS --> Codigo do Produto utilizado para o servico SMS 
    -- ..........................................................................
    --
    --  Programa : fn_busca_token_zenvia
    --  Sigla    : SOA_SMS
    --  Autor    : Anderson Fossa
    --  Data     : Setembro/2017.                   Ultima atualizacao: 
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Rotina para buscar o usuario e senha para envio de SMS atraves da Zenvia
    --
    -- .............................................................................
  BEGIN
      
      RETURN ESMS0001.fn_busca_token_zenvia(pr_cdproduto => pr_cdproduto);
      
  END fn_busca_token_zenvia;
                                                              	
END SOA_SMS;
/
