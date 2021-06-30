declare

begin

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('MANPLD_PRODUTOS', '17', 'Rotina 41 - DARF');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('MANPLD_PRODUTOS', '18', 'Rotina 80 - Correspondente');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('MANPLD_PRODUTOS', '19', 'Rotina 22 - Depósito entre Coop.');

insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('MANPLD_PRODUTOS', '20', 'Rotina 51 - Depósito');

 UPDATE crapprm
    SET dsvlrprm = '0'
  WHERE cdacesso = 'MANPLD_VLCORTE_14';
 commit;
 
 end;