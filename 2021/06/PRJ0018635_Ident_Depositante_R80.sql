/*

	Inserção de parâmetro e controle para rotina 80 do Caixa Online.
	
	Daniel D.
	Daniel Lombardi (Mout'S)

*/
insert into crapprm
  (nmsistem,
   cdcooper,
   cdacesso,
   dstexprm,
   dsvlrprm)
values
  ('CRED',
   0,
   'IDENT_DEPOSITANTE_R80',
   'Indica se a rotina 80 deve identificar o depositante em caso de pagamentos em espécie para prevenção de fraudes.',
   'S');
commit;
