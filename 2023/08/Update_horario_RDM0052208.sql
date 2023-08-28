begin

  update cecred.tbgen_debitador_horario set dhprocessamento = '03/01/2022 19:30:00' where idhora_processamento =4;

  commit;

end ;
