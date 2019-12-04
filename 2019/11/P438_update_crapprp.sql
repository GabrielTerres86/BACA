update crapprp a set a.dsobserv##1 = REGEXP_REPLACE (a.dsobserv##1, '[^a-zA-Z0-9()-,.#*<>:;|çÇãÃõÕ@%$ ]', '') 
where dtmvtolt >= sysdate -90 and tpctrato = 1;

commit;
