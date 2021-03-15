-- Mateus Zimmermann (Mouts)
-- RITM0106072

-- Deletar Faturas
delete from craplft lft
where lft.cdcooper = 1
  and lft.nrdconta = 6904890
  and lft.dtmvtolt = '25/11/2020'
  and lft.nrautdoc = 21471;
  
delete from craplft lft
where lft.cdcooper = 1
  and lft.nrdconta = 6904890
  and lft.dtmvtolt = '25/11/2020'
  and lft.nrautdoc = 21467;
  
delete from craplft lft
where lft.cdcooper = 1
  and lft.nrdconta = 6904890
  and lft.dtmvtolt = '25/11/2020'
  and lft.nrautdoc = 21469; 
  
delete from craplft lft
where lft.cdcooper = 1
  and lft.nrdconta = 3614948
  and lft.dtmvtolt = '25/11/2020'
  and lft.nrautdoc = 51326;
  
delete from craplft lft
where lft.cdcooper = 1
  and lft.nrdconta = 3614948
  and lft.dtmvtolt = '25/11/2020'
  and lft.nrautdoc = 51322;   

-- Deletar protocolos (comprovantes)
delete from crappro pro
where pro.cdcooper = 1
  and pro.nrdconta = 6904890
  and pro.dtmvtolt = '25/11/2020'
  and pro.cdtippro = 16
  and pro.nrseqaut = 21471;
  
delete from crappro pro
where pro.cdcooper = 1
  and pro.nrdconta = 6904890
  and pro.dtmvtolt = '25/11/2020'
  and pro.cdtippro = 16
  and pro.nrseqaut = 21467;
  
delete from crappro pro
where pro.cdcooper = 1
  and pro.nrdconta = 6904890
  and pro.dtmvtolt = '25/11/2020'
  and pro.cdtippro = 16
  and pro.nrseqaut = 21469;  
  
delete from crappro pro
where pro.cdcooper = 1
  and pro.nrdconta = 3614948
  and pro.dtmvtolt = '25/11/2020'
  and pro.cdtippro = 16
  and pro.nrseqaut = 51326;

delete from crappro pro
where pro.cdcooper = 1
  and pro.nrdconta = 3614948
  and pro.dtmvtolt = '25/11/2020'
  and pro.cdtippro = 16
  and pro.nrseqaut = 51322;     
  
COMMIT;  
   
