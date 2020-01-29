DECLARE

  CURSOR cr_prioridade IS 
    SELECT NVL(MAX(t.nrprioridade),0) + 1
      FROM tbgen_debitador_param t;

  -- Variaveis
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
                            VALUES ('COBR0011.PC_PROC_CUSTA_PENDENTE'
                                   ,'EFETUAR AS COBRANCAS DE CUSTAS PENDENTES DE ENTES PUBLICOS'
                                   ,'N'
                                   ,'N'
                                   ,NULL
                                   ,vr_nrprioridade
                                   ,'N'
                                   ,0);
                                   
  COMMIT;
  
END;
