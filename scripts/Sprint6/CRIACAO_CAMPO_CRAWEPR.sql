alter table cecred.crawepr
add column inliquid_operac_atraso number(1) default 0 not null;
Comment on column cecred.crawepr.inliquid_operac_atraso 'Contem o identificador da operacao de credito em atraso que vai para esteira';
