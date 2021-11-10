begin

update craplau set craplau.dtmvtopg = to_date('08-11-2021', 'dd-mm-yyyy'), craplau.dtrefatu = to_date('08-11-2021', 'dd-mm-yyyy'), craplau.tpdvalor = 1 where craplau.cdcooper = 16 and craplau.nrdconta = 709131 and craplau.dtmvtolt = '03/11/2021';
commit;

end;