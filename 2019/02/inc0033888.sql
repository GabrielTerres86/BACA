--Updata da lote
update craplot l set l.vlcompdb = 606, l.vlinfodb = 606 where l.progress_recid = 23831214;

--UPdata na craplcm
update craplcm l set l.vllanmto = 606 where l.progress_recid = 652521563; 

COMMIT;
