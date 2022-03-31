BEGIN
update crapass a
set a.nmprimtl = a.nmprimtl||' LERIANO'
where a.nrdconta = 80089534
and   a.cdcooper = 1;
COMMIT;
END;
