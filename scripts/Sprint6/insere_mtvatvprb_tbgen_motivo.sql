-- Insere Motivos de Ativo Problemático
insert into tbcc_produto values(42, 'ATIVO PROBLEMATICO', 0, 0, 0, 0);
--
insert into tbgen_motivo values(57, 'Atraso > 90 dias (Reestruturação)', 42);
insert into tbgen_motivo values(58, 'Atraso > 90 dias', 42);
insert into tbgen_motivo values(59, 'Prejuizo', 42);
insert into tbgen_motivo values(60, 'Socio falecido', 42);
insert into tbgen_motivo values(61, 'Acao contra', 42);
insert into tbgen_motivo values(62, 'Cooperado preso', 42);
insert into tbgen_motivo values(63, 'Falencia PJ', 42);
insert into tbgen_motivo values(64, 'Recuperacao judicial PJ', 42);
insert into tbgen_motivo values(65, 'Outros', 42);
commit;
/