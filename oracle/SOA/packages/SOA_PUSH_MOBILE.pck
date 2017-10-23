CREATE OR REPLACE PACKAGE SOA.SOA_PUSH_MOBILE IS

  ---------------------------------------------------------------------------
  --
  --  Programa : SOA_PUSH_MOBILE
  --  Autor    : Dionathan Henchel
  --  Data     : Outubro - 2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas referentes ao envio de push notification ao Cecred Mobile
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
  
--> Rotina responsavel por atualizar o status dos pushes enviados em um determinado lote
  PROCEDURE pc_processa_retorno_push ( pr_cdlote_push IN NUMBER,       --> Código do lote de Push
                                       pr_xmlerros    IN XMLTYPE );  --> XML contendo os erros do itens do lote

END SOA_PUSH_MOBILE;
/
CREATE OR REPLACE PACKAGE BODY SOA.SOA_PUSH_MOBILE IS
  
  --> Rotina responsavel por atualizar o status dos pushes enviados em um determinado lote
  PROCEDURE pc_processa_retorno_push ( pr_cdlote_push IN NUMBER,       --> Código do lote de Push
                                       pr_xmlerros    IN XMLTYPE ) IS  --> XML contendo os erros do itens do lote
  BEGIN
    NOTI0001.pc_processa_retorno_push(pr_cdlote_push => pr_cdlote_push
                                     ,pr_xmlerros    => pr_xmlerros);
    
  END pc_processa_retorno_push;

END SOA_PUSH_MOBILE;
/
