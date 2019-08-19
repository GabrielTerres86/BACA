prompt Importing table tbcobran_dominio_campo...
set feedback off
set define off
insert into tbcobran_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('IDPAGADOR_AGREGADO', '1', 'Ativo');

insert into tbcobran_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('IDPAGADOR_AGREGADO', '2', 'Aguardando Aprovação');

insert into tbcobran_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('IDPAGADOR_AGREGADO', '3', 'Falha (Erro) – Motivo');

insert into tbcobran_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('IDPAGADOR_AGREGADO', '4', 'Enviado');

insert into tbcobran_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('IDPAGADOR_AGREGADO', '5', 'Cancelamento enviado para CIP');

insert into tbcobran_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('IDPAGADOR_AGREGADO', '6', 'Cancelado');

insert into tbcobran_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('IDPAGADOR_AGREGADO', '7', 'Reprovado');

COMMIT;
prompt Done.
