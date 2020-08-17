begin

  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('MANPLD_PRODUTOS', '17', 'Rotina 14 - Pagamentos');
  
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'MANPLD_VLCORTE_14', 'Valor de corte que obriga preenchimento de campos.', 2000);
  
  commit;
  
end;