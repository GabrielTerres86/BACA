begin
  for creg in (select a.rowid linha, a.* from tbgen_debitador_param a where UPPER(a.cdprocesso) like '%EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB%') loop
    update tbgen_debitador_param a set a.nrprioridade=0 where a.rowid = creg.linha;
    insert into tbgen_debitador_param(cdprocesso, 
                                      dsprocesso, 
                                      indeb_sem_saldo, 
                                      indeb_parcial, 
                                      qtdias_repescagem, 
                                      nrprioridade, 
                                      inexec_cadeia_noturna, 
                                      incontrole_exec_prog)
                                      values
                                      ('TELA_LAUTOM.PC_EFETIVA_LCTO_PENDENTE_JOB', 
                                      creg.dsprocesso, 
                                      creg.indeb_sem_saldo, 
                                      creg.indeb_parcial, 
                                      creg.qtdias_repescagem, 
                                      creg.nrprioridade, 
                                      creg.inexec_cadeia_noturna, 
                                      creg.incontrole_exec_prog);
  end loop;

  UPDATE tbgen_debitador_horario_proc a
  set a.cdprocesso = 'TELA_LAUTOM.PC_EFETIVA_LCTO_PENDENTE_JOB'
  where upper(a.cdprocesso) like '%EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB%';

  delete tbgen_debitador_param a where UPPER(a.cdprocesso) like '%EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB%';
end;
/
commit
/
