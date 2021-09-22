begin

 delete from cecred.tbchq_processamento_parceiro a
where  a.dtimportacao_parceiro = to_date('22/09/2021','DD/MM/YYYY');
commit;

end;
