DECLARE

  -- Atualização de status das remessas enviadas para TIVIT
  -- Muitas remessas foram conciliadas fora da data de movimento   
  
  vr_exc_erro EXCEPTION; 
  
  vr_flgocorrencia    tbconv_remessa_pagfor.flgocorrencia%TYPE;
  vr_cdstatus_retorno tbconv_remessa_pagfor.cdstatus_retorno%TYPE;  
  
  CURSOR cr_remessa IS
    SELECT p.flgocorrencia,
           p.idremessa
      FROM tbconv_remessa_pagfor p
     WHERE p.dtmovimento BETWEEN TO_DATE('21/10/2020','dd/mm/rrrr') AND TO_DATE('30/10/2020','dd/mm/rrrr')
       AND p.cdstatus_remessa     = 1  -- Enviada
       AND p.cdagente_arrecadacao = 3; -- TIVIT
  rw_remessa cr_remessa %ROWTYPE;
  
  CURSOR cr_reg_remessa (pr_idremessa tbconv_registro_remessa_pagfor.idremessa%TYPE) IS
    SELECT reg.cdstatus_processamento,
           COUNT(*) qtdregis
      FROM tbconv_registro_remessa_pagfor reg
     WHERE reg.idremessa = pr_idremessa
  GROUP BY reg.cdstatus_processamento
  ORDER BY reg.cdstatus_processamento;
  rw_reg_remessa cr_reg_remessa%ROWTYPE;  
   
BEGIN
  
  FOR rw_remessa IN cr_remessa LOOP

    vr_flgocorrencia    := rw_remessa.flgocorrencia;
    vr_cdstatus_retorno := 0;

    FOR rw_reg_remessa IN cr_reg_remessa (pr_idremessa => rw_remessa.idremessa) LOOP
      
      IF rw_reg_remessa.cdstatus_processamento = 1 THEN -- Pendente de processamento
        vr_cdstatus_retorno := 1; -- Pendente de retorno
      END IF;

      IF rw_reg_remessa.cdstatus_processamento = 2 THEN -- Incluso para processamento
        vr_cdstatus_retorno := 2; -- Retorno parcial
      END IF;

      IF rw_reg_remessa.cdstatus_processamento IN (3,4) THEN -- Aceito para processamento ou rejeitado
        IF vr_cdstatus_retorno IN (1,2) THEN -- Se ainda existe registro pendente de processamento
          vr_cdstatus_retorno := 2; -- Retorno parcial
        ELSE
          vr_cdstatus_retorno := 3; -- Retorno total
        END IF;

        IF rw_reg_remessa.cdstatus_processamento = 4 THEN -- Rejeitado
          vr_flgocorrencia := 1; --Indica que existe algum rejeição na remessa
        END IF;
      END IF;
      
    END LOOP;

    BEGIN
      UPDATE tbconv_remessa_pagfor rem
         SET rem.flgocorrencia    = vr_flgocorrencia,
             rem.cdstatus_retorno = vr_cdstatus_retorno
       WHERE rem.idremessa = rw_remessa.idremessa;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Erro ao atualizar registro da remessa na tbconv_remessa_pagfor. Erro -> ' || SQLERRM);
        RAISE vr_exc_erro;
    END;
  END LOOP;
  
  COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
    WHEN OTHERS THEN
      dbms_output.put_line('Erro não tratado no script. Erro -> '|| SQLERRM);
      ROLLBACK;
      
END;
