begin
update tbcalris_colaboradores a set a.dhalteracao = trunc(SYSDATE - 1) where a.nrcpfcgc = 88154360900;
commit;
end;