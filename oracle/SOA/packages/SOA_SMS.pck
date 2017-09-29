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
    
  PROCEDURE pc_atualiza_status_msg (pr_xmlrequi   IN xmltype,  --> XML de Requisição
                                    pr_idlote_sms IN INTEGER); --> Codigo do Lote SMS
  
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

  --> Rotina responsavel por atualizar o status dos SMS - Chamada utilizada via SOA 
  PROCEDURE pc_atualiza_status_msg (pr_xmlrequi   IN xmltype,    --> XML de Requisição
                                    pr_idlote_sms IN INTEGER) IS --> Código do lote sms
    
  /* ............................................................................

       Programa: pc_atualiza_status_msg
       Sigla   : SOA_SMS
       Autor   : Anderson Fossa
       Data    : Setembro/2017.                    Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para atualizar situação do SMS - Chamada utilizada via SOA

       Alteracoes: ----

    ............................................................................ */
  BEGIN
  
    ESMS0001.pc_atualiza_status_msg_soa ( pr_idlotsms   => pr_idlote_sms,  --> Numer do lote de SMS
                                          pr_xmlrequi   => pr_xmlrequi);   --> XML de Requisição
                                          
  END pc_atualiza_status_msg;
                                                              	
END SOA_SMS;
/
