DECLARE

  CURSOR cr_prioridade IS 
    SELECT NVL(MAX(t.nrprioridade),0) + 1
      FROM tbgen_debitador_param t;

  -- Variaveis
  vr_cdprocesso     CONSTANT tbgen_debitador_param.cdprocesso%TYPE := 'COBR0011.PC_PROC_CUSTA_PENDENTE';
  vr_nrprioridade   tbgen_debitador_param.nrprioridade%TYPE;
BEGIN 
  
  -- Buscar código para cadastro
  OPEN  cr_prioridade;
  FETCH cr_prioridade INTO vr_nrprioridade;
  CLOSE cr_prioridade;
 
  -- Incluir dados 
  INSERT INTO tbgen_debitador_param(cdprocesso
                                   ,dsprocesso
                                   ,indeb_sem_saldo
                                   ,indeb_parcial
                                   ,qtdias_repescagem
                                   ,nrprioridade
                                   ,inexec_cadeia_noturna
                                   ,incontrole_exec_prog)
                            VALUES (vr_cdprocesso
                                   ,'EFETUAR AS COBRANCAS DE CUSTAS PENDENTES DE ENTES PUBLICOS'
                                   ,'N'
                                   ,'N'
                                   ,NULL
                                   ,vr_nrprioridade
                                   ,'N'
                                   ,0);
        
  FOR ind IN 1..4 LOOP                            
    -- Inserir os horários de execução
    INSERT INTO tbgen_debitador_horario_proc
                      (cdprocesso
                      ,idhora_processamento)
               VALUES (vr_cdprocesso
                      ,ind);
  END LOOP;
  
  
  COMMIT;
  
END;
