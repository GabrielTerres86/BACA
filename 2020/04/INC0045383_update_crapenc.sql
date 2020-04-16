-- INC0045383 - Alteracao do endereco


update crapenc
   set dsendere = 'RUA OSWALDO REICHERT'
      ,nrendere = 208
      ,complend = 'CASA'
      ,nmbairro = 'PROGRESSO'
      ,nrcepend = 89026070
      ,vlalugue = 400000
      ,incasprp = 1
      ,dtinires = '01/01/2019'
where cdcooper = 1
  and nrdconta = 6066666
  and tpendass = 10;
  
update crapenc
   set dsendere = 'RUA VINTE E UM DE ABRIL'
 where cdcooper = 1
   and nrdconta = 80187986
   and tpendass = 10
   and idseqttl = 1;
   
update crapenc
   set nmbairro = 'VELHA CENTRAL'
      ,vlalugue = 170000
 where cdcooper = 1
   and nrdconta = 9114394
   and tpendass = 10
   and idseqttl = 1;
   
COMMIT;        
