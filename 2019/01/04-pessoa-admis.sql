/* Script de atualizacao de demissao sql server */
/* Tempo: 00:04:28 - Registros 1920             */

insert into Pessoa (ID
                   ,CreatedOn
                   ,IDIntegracao
				   ,Empresa
				   ,Nome
				   ,TipoPessoa
				   ,DataAdmissao
				   ,CPFCNPJ
				   ,DataNascimento
				   ,PA
				   ,Grupo
				   ,Status
				   ,Vinculo)
select (select max(ID) from Pessoa) + ROW_NUMBER() OVER (order by tbevento_pessoa_grupos.Nome) ID
     , GETDATE() CreatedOn
     , tbevento_pessoa_grupos.*
  from openquery(ayllosp,'
  select d.idpessoa IDIntegracao
       , c.cdcooper Empresa
	   , c.nmprimtl Nome
	   , case c.inpessoa when 1 then ''0''
                         when 2 then ''1'' end TipoPessoa
       , c.dtmvtolt DataAdmissao
	   , c.nrcpfcgc CPFCNPJ
	   , c.dtnasctl DataNascimento
       , d.cdagenci PA
	   , d.nrdgrupo Grupo
	   , ''0'' Status 
       , case when  trim(c.tpvincul) is null then ''Vazio'' 
              else upper(c.tpvincul)
         end Vinculo
    from crapass c
       , tbevento_pessoa_grupos d
   where c.cdcooper = 1
     and c.dtdemiss is null
     and d.cdcooper = c.cdcooper
	 and d.nrdconta = c.nrdconta') tbevento_pessoa_grupos
  where not exists (select 1
                      from Pessoa 
					 where Pessoa.IDIntegracao = tbevento_pessoa_grupos.IDIntegracao)