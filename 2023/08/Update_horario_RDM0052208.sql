begin

  update cecred.tbgen_debitador_horario set dhprocessamento = to_date('03/01/2022 19:30:00','dd/mm/yyyy hh24:mi:ss') where idhora_processamento =4;
  commit;

end ;
