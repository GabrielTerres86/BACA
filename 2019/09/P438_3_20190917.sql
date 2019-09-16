begin
dbms_scheduler.set_attribute(name      => 'cecred.JBEPR_REENVIO_ANALISE',
                               attribute => 'repeat_interval',
                               value     => 'Freq=minutely;ByHour=8,9,10,11,12,13,14,15,16,17,18,19,20,21,22;BySecond=0');
                               

INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)
VALUES (1004,701,'Solicitação de Empréstimo',5,1,1,'2.4.0.0',NULL);


update tbcadast_pessoa_email e
   set e.insituacao = 1
 where e.insituacao is null;  
 
update tbepr_segmento_canais_perm e
   set e.tppermissao = 2,
       e.vlmax_autorizado = (select x.vlmax_autorizado 
                               from tbepr_segmento_canais_perm x
                              where x.cdcooper   = e.cdcooper
                                and x.idsegmento = e.idsegmento
                                and x.cdcanal = 3)
 where e.cdcanal = 10
   and e.cdcooper <> 8;
 
 
 update crapprm p
   set p.dsvlrprm = '16;6;9;10;12;2;5;13;14;1;11;7'
 where p.cdacesso = 'LIBERA_COOP_SIMULA_IB'; 

commit;
end;                               
