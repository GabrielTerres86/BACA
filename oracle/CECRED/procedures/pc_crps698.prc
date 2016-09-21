CREATE OR REPLACE PROCEDURE CECRED.pc_crps698(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                             ,pr_flgresta IN PLS_INTEGER --> Flag padr?o para utilizac?o de restart
                                             ,pr_stprogra OUT PLS_INTEGER --> Saida de termino da execuc?o
                                             ,pr_infimsol OUT PLS_INTEGER --> Saida de termino da solicitac?o
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS --> Texto de erro/critica encontrada
BEGIN
  /* ............................................................................

    Programa: pc_crps698
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Dionathan Henchel
    Data    : Outubro/2015                     Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Diario.
    Objetivo  : Armazenar o valor tarifado por conta mensalmente, agilizando cálculos futuros

    Alteracoes:
  .......................................................................... */

  DECLARE
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Codigo do Programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS698';

    -- Tratamento de Erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_exc_next   EXCEPTION;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis Diversas
    vr_nrmesref NUMBER(2);

    ------------------------------- CURSORES ---------------------------------

    -- Busca Dados das Cooperativa (Cecred)
    CURSOR cr_crabcop IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             cop.nmextcop,
             cop.dsdircop,
             cop.nrdocnpj,
             cop.dsnomscr,
             cop.dstelscr,
             cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;

    rw_crabcop cr_crabcop%ROWTYPE;

    -- Cursor Generico de Calendario
    rw_crabdat btch0001.cr_crapdat%ROWTYPE;
    
    -- Busca a soma de todas as tarifas pagas no mês por conta
    CURSOR cr_tarifas_pagas(pr_dtmvtolt IN DATE) IS
    SELECT lcm.cdcooper
          ,lcm.nrdconta
          ,SUM(vdc.vldebcre * lcm.vllanmto) vltottar -- Valor total das tarifas no mês, se for crédito soma, se for débito subtrai
      FROM craplcm lcm
          ,(SELECT his.cdcooper
                  ,his.cdhistor
                  ,DECODE(his.indebcre, 'C', -1, 'D', 1, 0) vldebcre -- Sinais D/C invertidos pois esta coluna é utilizada no calculo de sobras, ou seja, as tarifas que foras debitadas devem somar no montante das sobras
              FROM craphis his
             WHERE his.cdcooper = pr_cdcooper
               AND his.cdhistor IN (SELECT cdhistor
                                      FROM crapfvl
                                    UNION
                                    SELECT cdhisest
                                      FROM crapfvl)) vdc
      WHERE lcm.cdcooper = vdc.cdcooper
       AND lcm.cdhistor = vdc.cdhistor
       AND lcm.cdcooper = pr_cdcooper
       AND lcm.dtmvtolt BETWEEN TRUNC(pr_dtmvtolt, 'MM') AND last_day(pr_dtmvtolt)
       --AND TRUNC(lcm.dtmvtolt, 'MM') = TRUNC(pr_dtmvtolt, 'MM')
      GROUP BY lcm.cdcooper
             ,lcm.nrdconta;

  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir Nome do Modulo Logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => NULL);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crabcop;
    FETCH cr_crabcop INTO rw_crabcop;
    -- Se não encontrar
    IF cr_crabcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crabcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crabcop;
    END IF;

    -- Leitura do calendario da cooperativa
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crabcop.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crabdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    -- Validac?es Iniciais do Programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Caso tenha Erro
    IF vr_cdcritic <> 0 THEN
      -- Envio Centralizado de LOG de Erro
      RAISE vr_exc_saida;
    END IF;

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
    
    vr_nrmesref := EXTRACT (MONTH FROM rw_crabdat.dtmvtolt); -- Variável para receber o mês atual
    
    -- Busca a soma de todas as tarifas pagas no mês por conta
    FOR rw_tarifas_pagas IN cr_tarifas_pagas(rw_crabdat.dtmvtolt) LOOP
      BEGIN
        --Update atualiza apenas a coluna referente ao mês corrente, caso contrário mantém valor anterior
        UPDATE tbcotas_tarifas_pagas ctp
           SET ctp.vlpagomes1 = DECODE(vr_nrmesref,1,rw_tarifas_pagas.vltottar,ctp.vlpagomes1)
              ,ctp.vlpagomes2 = DECODE(vr_nrmesref,2,rw_tarifas_pagas.vltottar,ctp.vlpagomes2)
              ,ctp.vlpagomes3 = DECODE(vr_nrmesref,3,rw_tarifas_pagas.vltottar,ctp.vlpagomes3)
              ,ctp.vlpagomes4 = DECODE(vr_nrmesref,4,rw_tarifas_pagas.vltottar,ctp.vlpagomes4)
              ,ctp.vlpagomes5 = DECODE(vr_nrmesref,5,rw_tarifas_pagas.vltottar,ctp.vlpagomes5)
              ,ctp.vlpagomes6 = DECODE(vr_nrmesref,6,rw_tarifas_pagas.vltottar,ctp.vlpagomes6)
              ,ctp.vlpagomes7 = DECODE(vr_nrmesref,7,rw_tarifas_pagas.vltottar,ctp.vlpagomes7)
              ,ctp.vlpagomes8 = DECODE(vr_nrmesref,8,rw_tarifas_pagas.vltottar,ctp.vlpagomes8)
              ,ctp.vlpagomes9 = DECODE(vr_nrmesref,9,rw_tarifas_pagas.vltottar,ctp.vlpagomes9)
              ,ctp.vlpagomes10 = DECODE(vr_nrmesref,10,rw_tarifas_pagas.vltottar,ctp.vlpagomes10)
              ,ctp.vlpagomes11 = DECODE(vr_nrmesref,11,rw_tarifas_pagas.vltottar,ctp.vlpagomes11)
              ,ctp.vlpagomes12 = DECODE(vr_nrmesref,12,rw_tarifas_pagas.vltottar,ctp.vlpagomes12)
         WHERE ctp.cdcooper = rw_tarifas_pagas.cdcooper
           AND ctp.nrdconta = rw_tarifas_pagas.nrdconta;
           
       EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao atualizar registro na tabela TBCOTAS_TARIFAS_PAGAS: ' || sqlerrm;
            RAISE vr_exc_saida;
       END;
         
       -- Se não atualizou nada insere um registro novo
       IF SQL%ROWCOUNT = 0 THEN
         BEGIN
           -- Cria um registro novo e popula apenas o mês corrente, os demais popula com "0"
           INSERT INTO tbcotas_tarifas_pagas ctp
                       (cdcooper
                       ,nrdconta
                       ,nranolct
                       ,vlpagomes1
                       ,vlpagomes2
                       ,vlpagomes3
                       ,vlpagomes4
                       ,vlpagomes5
                       ,vlpagomes6
                       ,vlpagomes7
                       ,vlpagomes8
                       ,vlpagomes9
                       ,vlpagomes10
                       ,vlpagomes11
                       ,vlpagomes12
                       ,vlpagoanoant)
                       VALUES
                       (rw_tarifas_pagas.cdcooper
                       ,rw_tarifas_pagas.nrdconta
                       ,EXTRACT (YEAR FROM rw_crabdat.dtmvtolt)
                       ,DECODE(vr_nrmesref,1,rw_tarifas_pagas.vltottar,0)
                       ,DECODE(vr_nrmesref,2,rw_tarifas_pagas.vltottar,0)
                       ,DECODE(vr_nrmesref,3,rw_tarifas_pagas.vltottar,0)
                       ,DECODE(vr_nrmesref,4,rw_tarifas_pagas.vltottar,0)
                       ,DECODE(vr_nrmesref,5,rw_tarifas_pagas.vltottar,0)
                       ,DECODE(vr_nrmesref,6,rw_tarifas_pagas.vltottar,0)
                       ,DECODE(vr_nrmesref,7,rw_tarifas_pagas.vltottar,0)
                       ,DECODE(vr_nrmesref,8,rw_tarifas_pagas.vltottar,0)
                       ,DECODE(vr_nrmesref,9,rw_tarifas_pagas.vltottar,0)
                       ,DECODE(vr_nrmesref,10,rw_tarifas_pagas.vltottar,0)
                       ,DECODE(vr_nrmesref,11,rw_tarifas_pagas.vltottar,0)
                       ,DECODE(vr_nrmesref,12,rw_tarifas_pagas.vltottar,0)
                       ,0
                       );
         EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Problema ao inserir registro na tabela TBCOTAS_TARIFAS_PAGAS: ' || sqlerrm;
              RAISE vr_exc_saida;
         END;
       END IF;
    
    END LOOP;

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Finaliza Execucão do Programa
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper, /* cecred */
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- Salvar informações
    COMMIT;

  EXCEPTION
  WHEN vr_exc_fimprg THEN

    -- Se retornou apenas o codigo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Busca descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;

    -- Se foi gerado critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN

      -- Envio Centralizado de Log de Erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- ERRO TRATATO
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                    ' -' || vr_cdprogra || ' --> ' ||
                                                    vr_dscritic);

    END IF;

    -- Chamos o pc_valida_fimprg para encerrar o processo sem parar a cadeia
    BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- Salva informações no banco de dados
    COMMIT;

  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas codigo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos codigo e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic, 0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
  END;

END pc_crps698;
/

