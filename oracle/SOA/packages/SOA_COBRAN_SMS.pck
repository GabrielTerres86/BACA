CREATE OR REPLACE PACKAGE SOA.SOA_COBRAN_SMS IS

  ---------------------------------------------------------------------------
  --
  --  Programa : SOA_COBRAN_SMS
  --  Sistema  : Rotinas referentes ao envio de SMS por WebService
  --  Sigla    : COBR
  --  Autor    : Aline Baramarchi
  --  Data     : Novembro - 2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao envio de SMS
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------


  --> Rotina responsavel por atualizar o status do lote de SMS
  PROCEDURE pc_atualiza_status_lote ( pr_idlote_sms IN INTEGER,   --> C�digo do lote sms
                                      pr_idsituacao IN VARCHAR2); --> C�digo da Situa��o

  --> Rotina responsavel por atualizar o status dos SMS
  PROCEDURE pc_atualiza_status_msg ( pr_xmlrequi   IN xmltype,  --> XML de Requisi��o
                                     pr_idlote_sms IN INTEGER); --> C�digo do lote sms


END SOA_COBRAN_SMS;
/
CREATE OR REPLACE PACKAGE BODY SOA.SOA_COBRAN_SMS IS
  ---------------------------------------------------------------------------
  --
  --  Programa : SOA_COBRAN_SMS
  --  Sistema  : Rotinas referentes ao envio de SMS por WebService
  --  Sigla    : COBR
  --  Autor    : Aline Baramarchi
  --  Data     : Novembro - 2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao envio de SMS
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  --> Rotina responsavel por atualizar o status do lote - Chamada utilizada via SOA
  PROCEDURE pc_atualiza_status_lote ( pr_idlote_sms IN INTEGER,       --> C�digo do lote sms
                                      pr_idsituacao IN VARCHAR2 ) IS  --> C�digo da Situa��o

  
  /* ............................................................................

       Programa: pc_atualiza_status_lote
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : SOA
       Autor   : Odirlei Busan - AMcom
       Data    : novembro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina responsavel por atualizar o status do lote - Chamada utilizada via SOA

       Alteracoes: ----

    ............................................................................ */
  
  BEGIN
    --> Rotina para atualizar situa��o do lote de SMS de cobran�a
    COBR0005.pc_atualiza_status_lote (pr_idlotsms   => pr_idlote_sms,  --> C�digo do lote sms
                                      pr_idsituacao => pr_idsituacao); --> C�digo da Situa��o
    
  END pc_atualiza_status_lote;


  --> Rotina responsavel por atualizar o status dos SMS - Chamada utilizada via SOA 
  PROCEDURE pc_atualiza_status_msg (pr_xmlrequi   IN xmltype,    --> XML de Requisi��o
                                    pr_idlote_sms IN INTEGER) IS --> C�digo do lote sms
    
  /* ............................................................................

       Programa: pc_atualiza_status_msg
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : SOA
       Autor   : Odirlei Busan - AMcom
       Data    : novembro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para atualizar situa��o do SMS - Chamada utilizada via SOA

       Alteracoes: ----

    ............................................................................ */
  BEGIN
  
    COBR0005.pc_atualiza_status_msg_soa ( pr_idlotsms   => pr_idlote_sms,  --> Numer do lote de SMS
                                          pr_xmlrequi   => pr_xmlrequi);   --> XML de Requisi��o
                                          
  END pc_atualiza_status_msg;

END SOA_COBRAN_SMS;
/
