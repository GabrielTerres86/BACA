/*****************************************************************************************************************
21/04/2020 - P577 - INC0043759 - Cessão Renegociada.
             Ao renegociar contratos de cessão de cartão está ficando incorreto os dias de atraso no Cyber. Isso
             acarreta a negativação indevida do cooperado podendo gerar processo contra a cooperativa.
             Alteração: Se o contrato de cessão de cartão foi renegociado/efetivado, a data de pagamento enviada
             para o Cyber deve ser a Data Pagamento da Primeira Prestação da Renegociação e não a Data da Cessão.
*****************************************************************************************************************/
DECLARE
  --Empréstimos de Cessão de Cartão Renegociados
  CURSOR cr_emp_cessao_reneg IS
     SELECT epr.cdcooper          
           ,epr.nrdconta
           ,epr.nrctremp
           ,epr.dtmvtolt
           ,epr.dtdpagto
           ,epr.vlpapgat
           ,epr.vlppagat
           ,epr.cdlcremp
           ,epr.cdfinemp
           ,epr.vlemprst                         
          ,(SELECT ces.dtvencto
            FROM   tbcrd_cessao_credito ces
            WHERE  ces.cdcooper = epr.cdcooper
            AND    ces.nrdconta = epr.nrdconta
            AND    ces.nrctremp = epr.nrctremp ) dtvencto_original
      FROM  crapepr epr
           ,crawepr wepr
      WHERE epr.cdcooper = wepr.cdcooper
      AND   epr.nrdconta = wepr.nrdconta
      AND   epr.nrctremp = wepr.nrctremp    
      AND   epr.cdlcremp = 6901      --Cessão de Cartão    
      AND   Nvl(wepr.flgreneg,0) = 1 --Renegociado
      AND   EXISTS (SELECT 1
                    FROM   crapcyb  cyb                                            
                    WHERE  cyb.cdcooper = epr.cdcooper
                    AND    cyb.cdorigem = 3 --Empréstimo
                    AND    cyb.nrdconta = epr.nrdconta
                    AND    cyb.nrctremp = epr.nrctremp) --Contratos que estão no Cyber
      ORDER BY epr.cdcooper          
              ,epr.nrdconta
              ,epr.nrctremp;
  --            
  --Variáveis de Erro
  vr_erro             EXCEPTION;
  vr_ds_erro          VARCHAR2(1000);            
  --
  -- Variáveis  
  vr_reneg_efetivada  NUMBER := 0;           
  vr_qt_reg_lido      NUMBER := 0;
  vr_qt_reg_alterado  NUMBER := 0;
  
  vr_dtdpagto  date;
BEGIN
  
  dbms_output.put_line('Início Execução: '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
  dbms_output.put_line(' ');
  
  --Para cada Empréstimo de Cessão de Cartão Renegociado
  FOR rw_emp_cessao_reneg IN cr_emp_cessao_reneg LOOP
    --Incrementa Qtde de Registros Lidos
    vr_qt_reg_lido := Nvl(vr_qt_reg_lido,0) + 1;
    
    --Verifica se a Renegociação está efetivada
    vr_reneg_efetivada := 0;
    vr_reneg_efetivada := empr0021.fn_retorna_qtd_renegociacoes(pr_cdcooper => rw_emp_cessao_reneg.cdcooper
                                                               ,pr_nrdconta => rw_emp_cessao_reneg.nrdconta
                                                               ,pr_nrctremp => rw_emp_cessao_reneg.nrctremp
                                                               ,pr_tplibera => 1); --Renegociação Efetivada
    --Se a Renegociação estiver Efetivada                                                           
    IF Nvl(vr_reneg_efetivada,0) = 1 THEN
      --Altera a Data do Pagamento na Tabela do Cyber para Contabilizar os Dias de Atraso Corretamente.
      --A Data do pagamento deve ser a Data do Pagamento da Primeira Prestação da Renegociação e não mais
      --a Data da Cessão do Cartão.                                       
      BEGIN
        UPDATE crapcyb  cyb 
        SET    cyb.dtdpagto  = rw_emp_cessao_reneg.dtdpagto                            
        WHERE  cyb.cdcooper  = rw_emp_cessao_reneg.cdcooper
        AND    cyb.cdorigem  = 3 --Empréstimo
        AND    cyb.nrdconta  = rw_emp_cessao_reneg.nrdconta
        AND    cyb.nrctremp  = rw_emp_cessao_reneg.nrctremp
        AND    cyb.dtdpagto <> rw_emp_cessao_reneg.dtdpagto; --Se a data estiver diferente              
      EXCEPTION
        WHEN OTHERS THEN
          vr_ds_erro := 'Erro ao Atualizar a Data de Pagamento na Tabela do Cyber (crapcyb). Cooper: '||rw_emp_cessao_reneg.cdcooper||' | Conta: '||rw_emp_cessao_reneg.nrdconta||' | Contrato: '||rw_emp_cessao_reneg.nrctremp||'. Erro: '||SubStr(SQLERRM,1,255);      
          RAISE vr_erro;
      END;    
    
      --Incrementa Qtde de Registros Alterados
      IF Nvl(SQL%RowCount,0) > 0 THEN        
        vr_qt_reg_alterado := vr_qt_reg_alterado + Nvl(SQL%RowCount,0);
      END IF;
                          
    END IF;
     
  END LOOP;
  
  dbms_output.put_line(Lpad(vr_qt_reg_lido,6,0)||' Registro(s) Lido(s)');
  dbms_output.put_line(Lpad(vr_qt_reg_alterado,6,0)||' Registro(s) Alterado(s)');
  
  dbms_output.put_line(' ');
  dbms_output.put_line('Fim Execução: '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
  
  --Salva
  COMMIT;
 
EXCEPTION
  WHEN vr_erro THEN
    dbms_output.put_line(vr_ds_erro);
    ROLLBACK;
    Raise_application_error(-20000,vr_ds_erro);
  WHEN OTHERS THEN
    dbms_output.put_line('Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));
    ROLLBACK;
    Raise_application_error(-20001,'Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255)); 
END;
/
