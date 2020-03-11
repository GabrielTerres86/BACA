DECLARE
  -- Cooperativas
  CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE
                   ) IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.cdcooper = NVL(pr_cdcooper, cop.cdcooper)
       AND cop.flgativo = 1;
       
  -- Calculo dos Valores Pagos em Emprestimos e Financiamentos no ano
  CURSOR cr_apuraepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_cdoperac IN NUMBER
                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                    ) IS
    SELECT t.nrdconta
         , SUM(t.vloperacao)  vllanmto
      FROM cecred.tbcc_operacoes_diarias t
     WHERE t.cdcooper   = pr_cdcooper
       AND t.cdoperacao = pr_cdoperac
       AND t.dtoperacao BETWEEN trunc(pr_dtmvtolt, 'yyyy') and pr_dtmvtolt
     GROUP BY t.nrdconta;
     
  vr_dtmvtolt DATE                  := to_date('31/12/2019', 'dd/mm/yyyy');
  vr_cdcooper crapcop.cdcooper%TYPE := NULL;
  vr_cdoperac_pagepr NUMBER;
  --
BEGIN
  FOR rw_crapcop IN cr_crapcop(vr_cdcooper
                              ) LOOP
    -----------------------------------------------------------------------------------------------
    -- Buscar o código de operação para os registros de lançamento de históricos de empréstimos
    vr_cdoperac_pagepr := to_number(gene0001.fn_param_sistema('CRED',0,'CDOPERAC_HIS_PAGTO_EPR'));
    -----------------------------------------------------------------------------------------------
    
    ------------------------------------------------------------------------------
    -- Deve executar a rotina de apuração para o dia do fechamento, afim de 
    -- calcular os valores para o último dia do mês
    PAGA0002.pc_apura_lcm_his_emprestimo(pr_cdcooper => vr_cdcooper
                                        ,pr_dtrefere => vr_dtmvtolt);
                                        
    -- Após realizar a apuração dos dados ... deve agrupar os valores na tabela de memória
    FOR rw_apuraepr IN cr_apuraepr(vr_cdcooper
                                  ,vr_cdoperac_pagepr
                                  ,vr_dtmvtolt
                                  ) LOOP
      BEGIN
        UPDATE crapdir dir
           SET dir.vlprepag = rw_apuraepr.vllanmto
         WHERE dir.cdcooper = vr_cdcooper
           AND dir.nrdconta = rw_apuraepr.nrdconta
           AND dir.dtmvtolt = vr_dtmvtolt;
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Erro: ' || rw_apuraepr.nrdconta || ' - ' || SQLERRM);
          ROLLBACK;
      END;
      COMMIT;
    END LOOP;
    ------------------------------------------------------------------------------
  END LOOP;
END;
