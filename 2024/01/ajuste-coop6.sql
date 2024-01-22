begin
delete from crapsda a
where a.cdcooper = 6
and   a.dtmvtolt >= '20/01/2024';
commit;
end;
