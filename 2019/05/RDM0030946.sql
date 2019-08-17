prompt RDM0030946

set feedback off
set define off


update tbcadast_pessoa
set tpcadastro = 3
where idpessoa = 12255469;

update tbcadast_pessoa_fisica
set vlrenda_presumida = 998
where idpessoa = 12255469;

insert into tbcadast_pessoa_email ( idpessoa, nrseq_email, dsemail )
                           values ( 12255469, 1, 'douglas@diasengenharia.com.br' );



commit;

prompt Done.
