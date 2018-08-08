DECLARE
BEGIN
  BEGIN
    -- Insert da priorização
    INSERT INTO tbgen_debitador_param (cdprocesso, dsprocesso, indeb_sem_saldo, indeb_parcial, qtdias_repescagem, nrprioridade) 
      VALUES('PC_CRPS735', 'DESCONTO DE TÍTULOS','N', 'S', '',4);
    EXCEPTION 
      WHEN OTHERS THEN   
          UPDATE tbgen_debitador_param SET nrprioridade = nrprioridade+1 WHERE nrprioridade >= 4; -- Move todos os que tem priorização >= 4 para poder colocar o Desc.Tit  
          COMMIT;
          INSERT INTO tbgen_debitador_param (cdprocesso, dsprocesso, indeb_sem_saldo, indeb_parcial, qtdias_repescagem, nrprioridade) 
      VALUES('PC_CRPS735', 'DESCONTO DE TÍTULOS','N', 'S', '',4);  
  END;
  -- Insert dos horários
  INSERT  /*+ ignore_row_on_dupkey_index(tbgen_debitador_horario, tbgen_debitador_horario_uk1) */ INTO tbgen_debitador_horario (idhora_processamento, dhprocessamento)
       VALUES((SELECT MAX(idhora_processamento)+1 FROM tbgen_debitador_horario), to_date(to_char(trunc(SYSDATE), 'DD/MM/YYYY') || ' 07:00', 'DD/MM/YYYY HH24:MI'));
  INSERT  /*+ ignore_row_on_dupkey_index(tbgen_debitador_horario, tbgen_debitador_horario_uk1) */ INTO tbgen_debitador_horario (idhora_processamento, dhprocessamento)
       VALUES((SELECT MAX(idhora_processamento)+1 FROM tbgen_debitador_horario), to_date(to_char(trunc(SYSDATE), 'DD/MM/YYYY') || ' 12:30', 'DD/MM/YYYY HH24:MI'));
  INSERT  /*+ ignore_row_on_dupkey_index(tbgen_debitador_horario, tbgen_debitador_horario_uk1) */ INTO tbgen_debitador_horario (idhora_processamento, dhprocessamento)
       VALUES((SELECT MAX(idhora_processamento)+1 FROM tbgen_debitador_horario), to_date(to_char(trunc(SYSDATE), 'DD/MM/YYYY') || ' 17:30', 'DD/MM/YYYY HH24:MI'));
  INSERT  /*+ ignore_row_on_dupkey_index(tbgen_debitador_horario, tbgen_debitador_horario_uk1) */ INTO tbgen_debitador_horario (idhora_processamento, dhprocessamento)
       VALUES((SELECT MAX(idhora_processamento)+1 FROM tbgen_debitador_horario), to_date(to_char(trunc(SYSDATE), 'DD/MM/YYYY') || ' 21:00', 'DD/MM/YYYY HH24:MI'));

  -- Insert do vinculo da priorização e horário
  INSERT INTO tbgen_debitador_horario_proc (cdprocesso, idhora_processamento)
       VALUES('PC_CRPS735', (SELECT idhora_processamento FROM tbgen_debitador_horario WHERE to_char(dhprocessamento,'DD/MM/YYYY HH24:MI') LIKE '%07:00%'));
  INSERT INTO tbgen_debitador_horario_proc (cdprocesso, idhora_processamento)
       VALUES('PC_CRPS735', (SELECT idhora_processamento FROM tbgen_debitador_horario WHERE to_char(dhprocessamento,'DD/MM/YYYY HH24:MI') LIKE '%12:30%'));
  INSERT INTO tbgen_debitador_horario_proc (cdprocesso, idhora_processamento)
       VALUES('PC_CRPS735', (SELECT idhora_processamento FROM tbgen_debitador_horario WHERE to_char(dhprocessamento,'DD/MM/YYYY HH24:MI') LIKE '%17:30%'));  
  INSERT INTO tbgen_debitador_horario_proc (cdprocesso, idhora_processamento)
       VALUES('PC_CRPS735', (SELECT idhora_processamento FROM tbgen_debitador_horario WHERE to_char(dhprocessamento,'DD/MM/YYYY HH24:MI') LIKE '%21:00%'));
  COMMIT;
END;