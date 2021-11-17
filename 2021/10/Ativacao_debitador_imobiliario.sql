DECLARE
  -- Variaveis
  vr_cdprocesso     CONSTANT tbgen_debitador_param.cdprocesso%TYPE := 'EMPR0025.PC_DEBITAR_IMOBILIARIO';
 
BEGIN 
  
  UPDATE tbgen_debitador_param P
     SET NRPRIORIDADE = NRPRIORIDADE + 1
   WHERE P.NRPRIORIDADE >= 6;

  -- Atualiza
  UPDATE tbgen_debitador_param
     SET nrprioridade = 6
   WHERE dsprocesso = 'EFETUAR DEBITOS CONTRATOS IMOBILIARIO';

  FOR ind IN 1..5 LOOP                            
    -- Inserir os horários de execução
    INSERT INTO tbgen_debitador_horario_proc
                      (cdprocesso
                      ,idhora_processamento)
               VALUES (vr_cdprocesso
                      ,ind);
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;