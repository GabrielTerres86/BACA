begin

UPDATE gncontr SET gncontr.dtmvtolt = to_date('03/01/2022','DD/MM/YYYY') WHERE gncontr.cdcooper = 9 AND gncontr.dtmvtolt = to_date('05/01/2022','DD/MM/YYYY');
COMMIT;

end;