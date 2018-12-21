create or replace package cecred.CXON0054 is

/* .............................................................................

   Programa: siscaixa/web/b1crap54.p
   Sistema : Caixa On-line
   Sigla   : CRED
   Autor   : Antonio R. Jr (mouts).
   Data    : Dezembro/2017                      Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.

   Alteracoes: 

............................................................................. */

   /* Rotina de atualiza operacao  */

   PROCEDURE pc_atualiza_operacao_especie(pr_cdcooper   IN tbcc_operacoes_diarias.cdcooper%TYPE     --> Nome resumido da Coop
                                         ,pr_dtmvtolt   IN tbcc_operacoes_diarias.dtoperacao%TYPE   --> Data
                                         ,pr_nro_conta  IN tbcc_operacoes_diarias.nrdconta%TYPE     --> Nro da Conta
                                         ,pr_valor      IN tbcc_provisao_especie.vlsaque%TYPE       --> Valor saque
                                         ,pr_cm7_cheque IN VARCHAR2                                 --> Dados do cheque            
                                         ,pr_cdcritic   OUT INTEGER                                 --> Codigo da Critica
                                         ,pr_dscritic   OUT VARCHAR2);
   
  PROCEDURE pc_busca_limite_pagto_especie(pr_cdcooper  IN tbcc_monitoramento_parametro.cdcooper%TYPE                      --> Nome resumido da Coop                                          
                                          ,pr_vllimite OUT tbcc_monitoramento_parametro.Vlmonitoracao_Pagamento%TYPE);   --> Valor saque                                            
end CXON0054;
/
create or replace package body cecred.CXON0054 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CXON0054
  --  Sistema  : Caixa Online
  --  Sigla    : CRED
  --  Autor    : Antonio R. Jr(mouts)
  --  Data     : Dezembro/2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Atualizar operacao Caixa online

  -- Alteracoes:
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_atualiza_operacao_especie(pr_cdcooper    IN tbcc_operacoes_diarias.cdcooper%TYPE     --> Nome resumido da Coop
                                         ,pr_dtmvtolt   IN tbcc_operacoes_diarias.dtoperacao%TYPE   --> Data
                                         ,pr_nro_conta  IN tbcc_operacoes_diarias.nrdconta%TYPE     --> Nro da Conta
                                         ,pr_valor      IN tbcc_provisao_especie.vlsaque%TYPE       --> Valor saque
                                         ,pr_cm7_cheque IN VARCHAR2                                 --> Dados do cheque            
                                         ,pr_cdcritic   OUT INTEGER                                 --> Codigo da Critica
                                         ,pr_dscritic   OUT VARCHAR2) IS                            --> Descricao da Critica
  /* .............................................................................

   Programa: siscaixa/web/b1crap54.p
   Sistema : Caixa On-line
   Sigla   : CRED
   Autor   : Antonio R. Jr (mouts).
   Data    : Dezembro/2017                      Ultima atualizacao: 14/12/2018 

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.

   Alteracoes: 14/12/2018 - Andreatta - Mouts : Ajustar para utilizar fn_Sequence e 
                            não mais max na busca no nrsequen para tbcc_operacoes_diarias

............................................................................. */

  --CURSOR
  -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE; 
  
  --Buscar provisao especie
  CURSOR cr_provisoes(pr_cdcooper   IN tbcc_provisao_especie.cdcooper%TYPE
         	           ,pr_nrdconta   IN tbcc_provisao_especie.nrdconta%TYPE
                     ,pr_dtmvtolt   IN tbcc_provisao_especie.dhprevisao_operacao%TYPE
                     ,pr_cm7_cheque IN VARCHAR2
                     ,pr_valor      IN tbcc_provisao_especie.vlsaque%TYPE)IS
  SELECT p.cdcooper,
         p.dhprevisao_operacao,
         p.nrdconta,
         p.nrcpfcgc
  FROM tbcc_provisao_especie p
  WHERE p.cdcooper = pr_cdcooper
        AND p.nrdconta = pr_nrdconta
        AND TRUNC(p.dhprevisao_operacao) <= pr_dtmvtolt
        AND p.insit_provisao = 1
        AND p.vlsaque >= pr_valor
--elton        AND ((pr_cm7_cheque IS NULL AND p.incheque = 0) OR (pr_cm7_cheque IS NOT NULL AND p.incheque = 1))
         AND (pr_cm7_cheque IS NULL OR p.cdbanchq = SUBSTR(pr_cm7_cheque,2,3))
         AND (pr_cm7_cheque IS NULL OR p.cdagechq = SUBSTR(pr_cm7_cheque,5,4))
         AND (pr_cm7_cheque IS NULL OR p.nrctachq = SUBSTR(pr_cm7_cheque,23,10))
         AND (pr_cm7_cheque IS NULL OR p.nrcheque = SUBSTR(pr_cm7_cheque,14,6))
  ORDER BY p.dhprevisao_operacao;
  rw_provisao cr_provisoes%ROWTYPE;

  -- Variaveis Erro
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;

  -- Variavel
  vr_retorno  VARCHAR2(10);
  pr_retorno  VARCHAR2(10);
  vr_nrcheque NUMBER;
  vr_p_registro ROWID;

  BEGIN     
     --> Buscarprovisoes
      OPEN cr_provisoes(pr_cdcooper    => pr_cdcooper                                  
                        ,pr_nrdconta   => pr_nro_conta
                        ,pr_dtmvtolt   => pr_dtmvtolt
                        ,pr_cm7_cheque => trim(pr_cm7_cheque)
                        ,pr_valor      => pr_valor);
      FETCH cr_provisoes INTO rw_provisao;
      
      -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;    
      -- Fechar o cursor
      CLOSE btch0001.cr_crapdat;
              
      -- Se nao encontrar
      IF cr_provisoes%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_provisoes;              
      ELSE
        -- Fechar o cursor
        CLOSE cr_provisoes;
                             
          UPDATE tbcc_provisao_especie p 
          SET p.insit_provisao = 2
              ,p.vlpagamento = pr_valor
              ,p.dhoperacao = SYSDATE
          WHERE p.cdcooper = rw_provisao.cdcooper
                AND p.dhprevisao_operacao = rw_provisao.dhprevisao_operacao
                AND p.nrcpfcgc = rw_provisao.nrcpfcgc
                AND p.nrdconta = rw_provisao.nrdconta
                AND dhcadastro||vlsaque = (SELECT min(aa.dhcadastro)|| min(aa.vlsaque)
                                        FROM tbcc_provisao_especie aa
                                       WHERE aa.cdcooper            = p.cdcooper
                                         AND aa.cdagenci_saque      = p.cdagenci_saque
                                         AND aa.nrcpfcgc            = p.nrcpfcgc
                                         AND aa.nrdconta            = p.nrdconta
                                         AND aa.vlsaque            >= pr_valor
                                         AND aa.dhprevisao_operacao = p.dhprevisao_operacao                                         
                                         AND aa.insit_provisao      = 1);                                                           
      END IF;
      
      INSERT INTO tbcc_operacoes_diarias( cdcooper, 
                                          nrdconta, 
                                          cdoperacao, 
                                          dtoperacao, 
                                          nrsequen, 
                                          flgisencao_tarifa, 
                                          vloperacao)
           VALUES(pr_cdcooper,
                  pr_nro_conta,
                  22,
                  pr_dtmvtolt,
                  fn_sequence('TBCC_OPERACOES_DIARIAS','NRSEQUEN',to_char(pr_cdcooper)||';'||to_char(pr_nro_conta)||';22;'||to_char(rw_crapdat.dtmvtolt,'dd/mm/rrrr')),
                  0,
                  pr_valor);
      COMMIT;
  EXCEPTION
     WHEN vr_exc_erro THEN
        pr_retorno  := 'NOK';
        ROLLBACK; -- Desfazer a operacao

     WHEN OTHERS THEN
         ROLLBACK; -- Desfazer a operacao
         pr_retorno  := 'NOK';
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina CXON0054.pc_atualiza_operacao_especie: '||SQLERRM;        

         -- Se ocorreu algum erro interno
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
         END IF;

  END pc_atualiza_operacao_especie;

  PROCEDURE pc_busca_limite_pagto_especie(pr_cdcooper  IN tbcc_monitoramento_parametro.cdcooper%TYPE                      --> Nome resumido da Coop                                          
                                          ,pr_vllimite OUT tbcc_monitoramento_parametro.Vlmonitoracao_Pagamento%TYPE)IS   --> Valor saque
  /* .............................................................................

   Programa: siscaixa/web/b1crap51.p
   Sistema : Caixa On-line
   Sigla   : CRED
   Autor   : Antonio R. Jr (mouts).
   Data    : Dezembro/2017                      Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.

   Alteracoes: 

  ............................................................................ */

  --CURSOR
  --Buscar monitoramento parametro
  CURSOR cr_monit_param(pr_cdcooper IN tbcc_monitoramento_parametro.cdcooper%TYPE) IS
  SELECT p.vlmonitoracao_pagamento
  FROM tbcc_monitoramento_parametro p
  WHERE p.cdcooper = pr_cdcooper;         
  rw_monit_param cr_monit_param%ROWTYPE;

  -- Variaveis Erro
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  pr_cdcritic crapcri.cdcritic%TYPE;
  pr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;

  -- Variavel
  vr_retorno  VARCHAR2(10);
  pr_retorno  VARCHAR2(10);
  vr_nrcheque NUMBER;
  vr_p_registro ROWID;

  BEGIN         
     --> Buscar parametros
      OPEN cr_monit_param(pr_cdcooper => pr_cdcooper);
      FETCH cr_monit_param INTO rw_monit_param;
    
      -- Se nao encontrar
      IF cr_monit_param%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_monit_param;      
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Parametro nao encontrado!';
        -- volta para o programa chamador
        RAISE vr_exc_erro;
      ELSE
        -- Fechar o cursor
        CLOSE cr_monit_param;   
      END IF;
      
      pr_vllimite := rw_monit_param.vlmonitoracao_pagamento;
  EXCEPTION
     WHEN vr_exc_erro THEN
        pr_retorno  := 'NOK';
        ROLLBACK; -- Desfazer a operacao

     WHEN OTHERS THEN
         ROLLBACK; -- Desfazer a operacao
         pr_retorno  := 'NOK';
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina CXON0054.pc_busca_limite_pagto_especie: '||SQLERRM;        

         -- Se ocorreu algum erro interno
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
         END IF;

  END pc_busca_limite_pagto_especie;

end CXON0054;
/
