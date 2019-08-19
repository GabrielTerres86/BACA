/* Script de atualizacao de agencia sql server */
/* Tempo: 00:02:00 - Registros 277             */

-- Declaracao de variaveis
declare @vr_cdagenci as int = NULL
declare @vr_nrdgrupo as int = NULL
declare @vr_idpessoa as int = NULL
declare @vr_contador as int = 0

-- Declaracao do cursor
declare cr_agencia cursor for
                   select tbevento_pessoa_grupos.cdagenci
                        , tbevento_pessoa_grupos.nrdgrupo
                        , tbevento_pessoa_grupos.idpessoa
                     from openquery(ayllosp,'select c.*
                                               from tbevento_pessoa_grupos c
                                                  , crapass d
                                              where d.cdcooper = c.cdcooper
                                                and d.nrdconta = c.nrdconta
                                                and d.cdagenci = c.cdagenci') tbevento_pessoa_grupos
                        , Pessoa
                    where Pessoa.IDIntegracao = tbevento_pessoa_grupos.idpessoa
                      and Pessoa.PA <> tbevento_pessoa_grupos.cdagenci

open cr_agencia

fetch next from cr_agencia into @vr_cdagenci, @vr_nrdgrupo, @vr_idpessoa

while @@FETCH_STATUS = 0

  begin

    update Pessoa
       set PA           = @vr_cdagenci
         , Grupo        = @vr_nrdgrupo
         , UpdatedOn    = GETDATE()
     where IDIntegracao = @vr_idpessoa

    set @vr_contador = @vr_contador + 1

    fetch next from cr_agencia into @vr_cdagenci, @vr_nrdgrupo, @vr_idpessoa

  end

close cr_agencia  
deallocate cr_agencia

print(@vr_contador)