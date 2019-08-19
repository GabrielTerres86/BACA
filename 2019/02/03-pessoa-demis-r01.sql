/* Script de atualizacao de demissao sql server */
/* Tempo: 00:01:18 - Registros 1006             */

-- Declaracao de variaveis
declare @vr_idpessoa as int = NULL
declare @vr_contador as int = 0

-- Declaracao do cursor
declare cr_dmissao cursor for
  select Pessoa.ID
    from Pessoa left join
         openquery(ayllosp,'select cdcooper
  	                             , idpessoa
  	                          from tbevento_pessoa_grupos') tbevento_pessoa_grupos
      on (Pessoa.Empresa      = tbevento_pessoa_grupos.cdcooper and
  	      Pessoa.IDIntegracao = tbevento_pessoa_grupos.idpessoa)
   where Pessoa.Empresa = 1
     and Pessoa.Status  = 0
     and tbevento_pessoa_grupos.idpessoa is null

open cr_dmissao

fetch next from cr_dmissao into @vr_idpessoa

while @@FETCH_STATUS = 0

  begin

    update Pessoa
       set Status    = 1
         , UpdatedOn = GETDATE()
     where ID        = @vr_idpessoa
	 
	update Conta
       set Status    = 1
         , UpdatedOn = GETDATE()
     where IDPessoa  = @vr_idpessoa

    set @vr_contador = @vr_contador + 1

    fetch next from cr_dmissao into @vr_idpessoa

  end

close cr_dmissao  
deallocate cr_dmissao

print(@vr_contador)