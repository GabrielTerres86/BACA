/* -----------------------------------------------------------------
|| AUTOR   : Tiago Pimenta
|| EMPRESA : AMcom
|| VERSAO  : V1.00
|| DATA    : 21/01/2022
|| OBJETIVO: Insert na tabela craprel
*/ -----------------------------------------------------------------
begin
  insert into craprel (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO, NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, CDFILREL, NRSEQPRI)
  values (1002, 1, 1, 'RELATORIO SENHA TA', 1, 'cartoes\claudio', 'padrao', 0, 3, 'M', 1, 1, 2, ' ', null, null);
  commit;
end;