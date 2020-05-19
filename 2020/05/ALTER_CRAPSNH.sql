alter table CECRED.crapsnh modify( vllimite_dep_cheq_mob NUMBER(25,2) default 2000 );  

update crapsnh snh set snh.vllimite_dep_cheq_mob = 2000 where snh.vllimite_dep_cheq_mob = 0;
