-- BACAS IMOBILIARIO MVP (PRJ0023311)
-- SEGUNDA ENTREGA
DECLARE
  vr_cdprocesso     CONSTANT tbgen_debitador_param.cdprocesso%TYPE := 'EMPR0025.PC_DEBITAR_IMOBILIARIO';
 
BEGIN 
  
  UPDATE tbgen_debitador_param P
     SET NRPRIORIDADE = NRPRIORIDADE + 1
   WHERE P.NRPRIORIDADE >= 6;
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
                                   ,'EFETUAR DEBITOS CONTRATOS IMOBILIARIO'
                                   ,'N'
                                   ,'S'
                                   ,NULL
                                   ,6
                                   ,'N'
                                   ,0);
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
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
/
Begin
update crapaca a
   set a.lstparam = a.lstparam||',pr_imobiliario'
 where nmpackag = 'TELA_RATMOV'
   AND nmdeacao = 'PC_IMPRIMIR';
commit;
exception
  when others then
    RAISE_application_error(-20500,SQLERRM);
    rollback;
end;
/
BEGIN
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','0','Desconhecido');
    COMMIT;
EXCEPTION
 WHEN OTHERS THEN
  RAISE_application_error(-20500,SQLERRM);
  ROLLBACK;
END;
/