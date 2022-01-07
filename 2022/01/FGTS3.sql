begin

UPDATE gncontr SET gncontr.dtmvtolt = '03/01/2022' WHERE gncontr.cdcooper = 9 AND gncontr.dtmvtolt = '05/01/2022';
COMMIT;

end;