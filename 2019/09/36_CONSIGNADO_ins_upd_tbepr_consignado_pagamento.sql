update tbcadast_dominio_campo set dscodigo = 'Pendente' where nmdominio = 'INSTATUS' and cddominio = '1';
update tbcadast_dominio_campo set dscodigo = 'Processado' where nmdominio = 'INSTATUS' and cddominio = '2';
update tbcadast_dominio_campo set dscodigo = 'Erro' where nmdominio = 'INSTATUS' and cddominio = '3';
insert into tbcadast_dominio_campo values ('INSTATUS','4','Estornado');
commit;