begin

update tbblqj_ordem_online set instatus = 8 where idordem between 2784005 and 2785800 and instatus = 1;

commit;

end;