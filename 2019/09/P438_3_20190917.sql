begin
dbms_scheduler.set_attribute(name      => 'cecred.JBEPR_REENVIO_ANALISE',
                               attribute => 'repeat_interval',
                               value     => 'Freq=minutely;ByHour=8,9,10,11,12,13,14,15,16,17,18,19,20,21,22;BySecond=0');
                               

INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)
VALUES (1004,701,'Solicitação de Empréstimo',5,1,1,'2.4.0.0',NULL);


update tbcadast_pessoa_email e
   set e.insituacao = 1
 where e.insituacao is null;  

commit;
end;                               
