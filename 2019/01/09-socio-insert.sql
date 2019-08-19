/* Quantidade: 329 Tempo: 00:09:15 */

insert into Socio (ID
                  ,IDpessoapj
				  ,IDpessoapf
				  ,CPF
				  ,Nome
				  ,Status
				  ,DataNascimento)
select (select max(ID) from Socio) + ROW_NUMBER() OVER (order by tbevento_pessoa_grupos.IDpessoapj) ID
     , (select id from pessoa where idintegracao = tbevento_pessoa_grupos.IDpessoapj) IDpessoapj
	 , (select id from pessoa where idintegracao = tbevento_pessoa_grupos.IDpessoapf) IDpessoapf
	 , tbevento_pessoa_grupos.CPF
	 , tbevento_pessoa_grupos.Nome
	 , '0' Status
	 , tbevento_pessoa_grupos.DataNascimento 
	 , tbevento_pessoa_grupos.IDpessoapj
  from openquery(ayllosp,'
  select a.idpessoa IDpessoapj
	   , d.idpessoa IDpessoapf
	   , d.nrcpfcgc CPF
	   , d.nmpessoa Nome
	   , e.dtnascimento DataNascimento
    from tbevento_pessoa_grupos a
   inner join tbcadast_pessoa b              on (b.idpessoa = a.idpessoa and b.tppessoa = 2) 
   inner join tbcadast_pessoa_juridica_rep c on (c.idpessoa = b.idpessoa)
   inner join tbcadast_pessoa d              on (d.idpessoa = c.idpessoa_representante)
   inner join tbcadast_pessoa_fisica e       on (e.idpessoa = d.idpessoa)
   where a.cdcooper = 1
     and exists (select 1 
                   from tbevento_pessoa_grupos 
				  where idpessoa = d.idpessoa 
				    and cdcooper = 1)') tbevento_pessoa_grupos
 where not exists (select 1
                     from Socio
					where Socio.IDpessoapj = IDpessoapj
					  and Socio.IDpessoapf = IDpessoapf
					  and Socio.CPF        = tbevento_pessoa_grupos.CPF)
