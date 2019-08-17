PL/SQL Developer Test script 3.0
26
-- INC0031506 - Atualizar data de retorno dos sms de majoracao de limite
declare 

  cursor cr_lote_sms is
   select dtenvio, idlote from (select max(a.dhenvio_sms) dtenvio, a.idlote_sms idlote
          from tbgen_sms_lote e, tbgen_sms_controle a
         where e.idtpreme = 'SMSCRDBCB'
           and e.cdproduto = 21
           and e.dhretorno is null
           and a.idlote_sms = e.idlote_sms
         group by a.idlote_sms
         order by a.idlote_sms);        
begin
  
  for rw_lote_sms in cr_lote_sms loop
     
     update tbgen_sms_lote lote 
        set lote.dhretorno = rw_lote_sms.dtenvio
           ,lote.idsituacao = 'P'
      where lote.idlote_sms = rw_lote_sms.idlote;
     
     dbms_output.put_line('idlote_sms: '|| rw_lote_sms.idlote|| ' atualizado.');
  end loop;
  
  commit;  
end;
0
0
