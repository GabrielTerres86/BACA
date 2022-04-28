begin
update craplft set insitfat = 3 where cdhistor in (3465,3464) and insitfat = 1 and dtmvtolt >= '01/11/2021';
commit;

end;