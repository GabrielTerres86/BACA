/* Script de atualizacao de demissao sql server */
/* Tempo: 00:02:14 - Registros 0001             */

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
select (select max(ID) from Pessoa) + 10 + ROW_NUMBER() OVER (order by tbevento_pessoa_grupos.Nome) ID
     , GETDATE() CreatedOn
     , tbevento_pessoa_grupos.*
  from openquery(ayllosp,'
  select d.idpessoa IDIntegracao
       , c.cdcooper Empresa
	   , c.nmprimtl Nome
	   , case c.inpessoa when 1 then ''0''
	                     when 2 then ''1'' end TipoPessoa
       , c.dtmvtolt DataAdmissao
	   , case c.inpessoa when 1 then rpad(c.nrcpfcgc,11,0) 
	                     when 2 then to_char(c.nrcpfcgc) end CPFCNPJ
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
	 and c.dtmvtolt < to_date(''27/02/2019'',''dd/mm/yyyy'')
     and d.cdcooper = c.cdcooper
	 and d.nrdconta = c.nrdconta') tbevento_pessoa_grupos
  where not exists (select 1
                      from Pessoa 
					 where Pessoa.IDIntegracao = tbevento_pessoa_grupos.IDIntegracao);

DELETE FROM AAA_OBJSEQUENCES;