declare

begin

insert into CECRED.TBEPR_DOMINIO_CAMPO (nmdominio, cddominio, dscodigo)
values ('TPAMORTIZACAO_ANTECIPACAO', '1', 'Parcial');
insert into CECRED.TBEPR_DOMINIO_CAMPO (nmdominio, cddominio, dscodigo)
values ('TPAMORTIZACAO_ANTECIPACAO', '2', 'Total');
insert into CECRED.TBEPR_DOMINIO_CAMPO (nmdominio, cddominio, dscodigo)
values ('TPPAGAMENTO_ANTECIPACAO', '1', 'Postecipado');

commit;

end;