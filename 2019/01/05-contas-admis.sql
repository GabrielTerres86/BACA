insert into Conta (ID
				  ,CreatedOn
                  ,IDPessoa
				  ,NumeroConta
				  ,Status)
select (select max(ID) from Conta) + ROW_NUMBER() OVER (order by tbevento_pessoa_grupos.IDPessoa) ID
     , GETDATE() CreatedOn
     , tbevento_pessoa_grupos.*
  from openquery(ayllosp, '
  select c.idpessoa IDPessoa
	   , agrp0001.md5(d.nrdconta) NumeroConta
	   , case when d.dtdemiss is null then 0
              else 1 end Status
    from tbevento_pessoa_grupos c
       , crapass d
   where c.cdcooper = 1
     and d.cdcooper = c.cdcooper
     and d.nrcpfcgc = d.nrcpfcgc') tbevento_pessoa_grupos
 where not exists (select 1
                     from Contas.NumeroConta = tbevento_pessoa_grupos.NumeroConta)