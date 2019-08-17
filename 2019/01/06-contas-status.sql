/* Script de atualizacao de status sql server */
/* Tempo: 00:11:58 - Registros 491            */

-- Declaracao de variaveis
declare @vr_nrdconta as varchar(40) = NULL
declare @vr_cdstatus as int = null
declare @vr_contador as int = 0

-- Declaracao do cursor
declare cr_cstatus cursor for
  select Conta.NumeroConta
       , crapass.status
    from Conta
       , openquery(ayllosp,'select agrp0001.md5(nrdconta) nrdconta
	                             , case when trim(dtdemiss) is null then 0
								        else 1 end status
                              from crapass
							 where cdcooper = 1') crapass
   where Conta.NumeroConta  = crapass.nrdconta
     and Conta.Status      <> crapass.status

open cr_cstatus

fetch next from cr_cstatus into @vr_nrdconta, @vr_cdstatus

while @@FETCH_STATUS = 0

  begin

	update Conta
       set Status    = @vr_cdstatus
         , UpdatedOn = GETDATE()
     where NumeroConta  = @vr_nrdconta

    set @vr_contador = @vr_contador + 1

    fetch next from cr_cstatus into @vr_nrdconta, @vr_cdstatus

  end

close cr_cstatus  
deallocate cr_cstatus

print(@vr_contador)