begin

UPDATE gncontr SET gncontr.dtmvtolt = to_date('03/01/2022','dd/mm/RRRR') WHERE gncontr.cdcooper = 9 AND gncontr.dtmvtolt = '05/01/2022';
COMMIT;

end;