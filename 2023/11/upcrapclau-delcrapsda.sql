begin
update cecred.craplau l set l.dtmvtopg=to_date('11/07/2022','dd/mm/yyyy')
where l.nrdconta=82303142 and l.dtmvtolt=to_date('16/11/2023','dd/mm/yyyy');

delete from cecred.crapsda where PROGRESS_RECID=3262622273;

commit;
end;




