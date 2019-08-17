/* Script de atualizacao de agencia sql server */
/* Tempo: 00:01:08 - Registros 028             */

-- Declaracao de variaveis
declare @vr_tpvincul as varchar(40) = NULL
declare @vr_idpessoa as int = NULL
declare @vr_contador as int = 0

-- Declaracao do cursor
declare cr_vinculo cursor for
                   select tbevento_pessoa_grupos.tpvincul	
                        , tbevento_pessoa_grupos.idpessoa				   
                     from openquery(ayllosp,'select c.idpessoa
					                              , case when trim(d.tpvincul) is null then ''Vazio''
                                                         else d.tpvincul end tpvincul
                                               from tbevento_pessoa_grupos c
                                                  , crapass d
                                              where d.cdcooper = c.cdcooper
                                                and d.nrdconta = c.nrdconta') tbevento_pessoa_grupos
                        , Pessoa
                    where Pessoa.IDIntegracao = tbevento_pessoa_grupos.idpessoa
                      and Pessoa.Vinculo     <> tbevento_pessoa_grupos.tpvincul

open cr_vinculo

fetch next from cr_vinculo into @vr_tpvincul, @vr_idpessoa

while @@FETCH_STATUS = 0

  begin

    update Pessoa
       set Vinculo      = @vr_tpvincul
         , UpdatedOn    = GETDATE()
     where IDIntegracao = @vr_idpessoa

    set @vr_contador = @vr_contador + 1

    fetch next from cr_vinculo into @vr_tpvincul, @vr_idpessoa

  end

close cr_vinculo  
deallocate cr_vinculo

print(@vr_contador)