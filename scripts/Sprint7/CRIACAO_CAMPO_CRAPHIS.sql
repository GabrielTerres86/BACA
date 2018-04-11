alter table cecred.craphis
add column inestoura_conta number(1) default 0 not null;
Comment on column cecred.craphis.inestoura_conta 'Contém o identificador para indicar se o histórico estoura conta 0-Não e 1-Sim';