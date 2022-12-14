begin

update CECRED.PARAMETROMOBILE set valor = '2.51.5' where parametromobileid = 25;
update CECRED.PARAMETROMOBILE set valor = '2.51.6' where parametromobileid = 26;

commit;
end;