BEGIN
  
  UPDATE tbcc_portabilidade_recebe t
     SET t.dsnome_empregador  = 'RODOVI�RIO AGUIA CARGAS EIRELI ME'
   WHERE t.nrnu_portabilidade = 201901300000081334386;
   
  UPDATE tbcc_portabilidade_recebe t
     SET t.dsnome_empregador  = 'PRE FABRICAR CONSTRU��ES LTDA'
   WHERE t.nrnu_portabilidade = 201901250000080759482;
   
  UPDATE tbcc_portabilidade_recebe t
     SET t.dsnome_empregador  = 'SANTINO INSTALA��ES ELETRICAS EIRELI'
   WHERE t.nrnu_portabilidade = 201901290000081166224;
  
  UPDATE tbcc_portabilidade_recebe t
     SET t.dsnome_empregador  = 'PREVEN��O EXTINTORES'
   WHERE t.nrnu_portabilidade = 201901240000080657006;
   
  UPDATE tbcc_portabilidade_recebe t
     SET t.dsnome_empregador  = 'CARLOS ALBERTO FERNANDES FAC��O'
   WHERE t.nrnu_portabilidade = 201901240000080717859;
  
  COMMIT;
     
END;
