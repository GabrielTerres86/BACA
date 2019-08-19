/* Qtd 3168 Tempo 00:05:09 */

insert into Cartao (ID
                   ,CreatedOn
				   ,Status
				   ,IDConta
				   ,NumeroCartao)
select (select max(ID) from Cartao) + ROW_NUMBER() OVER (order by tbevento_pessoa_grupos.IDPessoa) ID
     , GETDATE() CreatedOn
	 , '0' Status
	 , Conta.ID IDConta
     , tbevento_pessoa_grupos.NumeroCartao
  from openquery(ayllosp, '
    select distinct
           agrp0001.md5(crd.nrcrcard) NumeroCartao
		 , pes.idpessoa
      from crawcrd crd
         , crapass ass
		 , tbcadast_pessoa pes
     where crd.cdcooper = 1
       and crd.insitcrd not in (5,6)
       and nvl(crd.nrcrcard,0) > 0
       and ass.cdcooper = crd.cdcooper
       and ass.nrdconta = crd.nrdconta
	   and ass.nrcpfcgc = crd.nrcpftit
	   and pes.nrcpfcgc = ass.nrcpfcgc') tbevento_pessoa_grupos
     , Pessoa inner join Conta on (Pessoa.id = Conta.IDPessoa)
 where Pessoa.IDIntegracao = tbevento_pessoa_grupos.idpessoa
   and not exists (select 1
                     from Cartao
					where Cartao.NumeroCartao = tbevento_pessoa_grupos.NumeroCartao)