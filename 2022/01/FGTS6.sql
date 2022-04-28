begin

UPDATE gncontr SET gncontr.dtmvtolt = to_date('03/01/2022','DD/MM/YYYY') WHERE gncontr.cdcooper = 9 AND gncontr.nmarquiv like 'fgts0105%';
COMMIT;

end;