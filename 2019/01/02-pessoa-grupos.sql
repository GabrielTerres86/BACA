/* Script de atualizacao de grupo sql server */
/* Tempo: 00:01:15 - Registros 006           */

-- Declaracao de variaveis
declare @vr_nrdgrupo as int = NULL
declare @vr_idpessoa as int = NULL
declare @vr_contador as int = 0

-- Declaracao do cursor
declare cr_nrgrupo cursor for
                   select tbevento_pessoa_grupos.nrdgrupo
                        , tbevento_pessoa_grupos.idpessoa
                     from openquery(ayllosp,'select c.*
                                               from tbevento_pessoa_grupos c
                                                  , crapass d
                                              where d.cdcooper = c.cdcooper
                                                and d.nrdconta = c.nrdconta
                                                and d.cdagenci = c.cdagenci') tbevento_pessoa_grupos
                        , Pessoa
                    where Pessoa.IDIntegracao =  tbevento_pessoa_grupos.idpessoa
                      and Pessoa.PA           =  tbevento_pessoa_grupos.cdagenci
                      and Pessoa.Grupo        <> tbevento_pessoa_grupos.nrdgrupo

open cr_nrgrupo

fetch next from cr_nrgrupo into @vr_nrdgrupo, @vr_idpessoa

while @@FETCH_STATUS = 0

  begin

    update Pessoa
       set Grupo        = @vr_nrdgrupo
         , UpdatedOn    = GETDATE()
     where IDIntegracao = @vr_idpessoa

    set @vr_contador = @vr_contador + 1

    fetch next from cr_nrgrupo into @vr_nrdgrupo, @vr_idpessoa

  end

close cr_nrgrupo  
deallocate cr_nrgrupo

print(@vr_contador)