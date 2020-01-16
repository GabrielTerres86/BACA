DECLARE
    -- Variaveis gerais
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    vr_dtddutl crapdat.dtmvtolt%TYPE;
    vr_committ BOOLEAN := FALSE;
      
    -- Variaveis critica
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_erro EXCEPTION;
      
    -- Cursores
    -- Cooperativas
    CURSOR cr_cooperativas IS
      SELECT c.cdcooper
             ,c.nmextcop
        FROM crapcop c;
    rw_cooperativas cr_cooperativas%ROWTYPE;
    
    -- Faturas    
    CURSOR cr_tbcrd_fatura IS
      SELECT f.idfatura
             ,pf.tporigem
             ,pf.idpagamento_fatura
             ,f.vlfatura
             ,f.vlminimo_pagamento
             ,f.vlpendente
             ,f.dtmovimento
             ,f.dtvencimento
             ,f.dtpagamento  dtpagamentof
             ,pf.dtpagamento dtpagamentopf
             ,pf.vlpagamento
             ,pf.vlsaldo_conta
        FROM tbcrd_fatura f
        LEFT JOIN tbcrd_pagamento_fatura pf ON (f.idfatura = pf.idfatura)
       WHERE pf.tporigem = 2 -- repique noturno
         AND f.dtmovimento < to_date('22/11/2019') -- intervalo das datas eh do inicio do ano ate liberacao da RITM0031165 
         AND f.dtmovimento > to_date('31/12/2018')
       ORDER BY f.idfatura, pf.idpagamento_fatura ASC;
      
    rw_tbcrd_fatura cr_tbcrd_fatura%ROWTYPE;

BEGIN
  
    -- loop cooperativas
    FOR rw_cooperativas IN cr_cooperativas LOOP
      
        -- Leitura do calendario da cooperativa
        OPEN  btch0001.cr_crapdat(pr_cdcooper => rw_cooperativas.cdcooper);
        FETCH btch0001.cr_crapdat INTO rw_crapdat;

        IF btch0001.cr_crapdat%NOTFOUND THEN
           CLOSE btch0001.cr_crapdat;
           vr_dscritic := 'Sistema sem data de movimento.';
           RAISE vr_exc_erro;
        ELSE
           CLOSE btch0001.cr_crapdat;
        END IF;
        --       
        
        -- loop faturas
        FOR rw_tbcrd_fatura IN cr_tbcrd_fatura LOOP
              
            -- Verifica se data de vencimento eh em finais de semana e busca proximo dia util
            vr_dtddutl := gene0005.fn_valida_dia_util(pr_cdcooper  => rw_cooperativas.cdcooper
                                                      ,pr_dtmvtolt => rw_tbcrd_fatura.dtvencimento
                                                      ,pr_tipo     => 'P'); 
              
            -- Verificamos se a data de vencimento for diferente do dia util, se for, quer dizer que a data
            -- de vencimento caiu em um final de semana
            -- Verificamos tbm se a data de pagamento foi no proximo dia util, se for, entao não é considero repique
            -- No OR é verificado se o pagamento é igual a data de vencimento, se é, o registro não é considerado repique
            
            IF (vr_dtddutl != rw_tbcrd_fatura.dtvencimento AND vr_dtddutl = rw_tbcrd_fatura.dtpagamentopf)
               OR (rw_tbcrd_fatura.dtvencimento = rw_tbcrd_fatura.dtpagamentopf) THEN
               /*dbms_output.put_line('Id fatura: ' || rw_tbcrd_fatura.idpagamento_fatura);
               dbms_output.put_line('Vencimento: ' || rw_tbcrd_fatura.dtvencimento);
               dbms_output.put_line('Dia util: ' || vr_dtddutl);
               dbms_output.put_line('Data pagamento fatura: ' || rw_tbcrd_fatura.dtvencimento);*/
               
               -- Alteramos o registo para a origem ser normal e não mais repique
               BEGIN
                 UPDATE tbcrd_pagamento_fatura pf
                    SET pf.tporigem = 1 
                  WHERE pf.idpagamento_fatura = rw_tbcrd_fatura.idpagamento_fatura;
               EXCEPTION
                 WHEN OTHERS THEN
                   dbms_output.put_line('Erro ao alterar o registro: idpagamento_fatura: ' || rw_tbcrd_fatura.idpagamento_fatura);
               END;
               
               --
               IF vr_committ THEN
                  COMMIT;
               END IF;
               --
            END IF;
            -- 
              
        END LOOP;
        -- end loop faturas
        
    END LOOP; 
    -- end loop cooperativas     
      
EXCEPTION
  WHEN vr_exc_erro THEN
    dbms_output.put_line(vr_dscritic);
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao efetuar validação do repique para informações do legado: ' || SQLERRM);
END;
