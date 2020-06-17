-- ajuste do controle de bloqueado prejuizo
UPDATE crapsld sld
  SET sld.vlblqprj = sld.vlblqprj+177
 where sld.cdcooper = 1
   and sld.nrdconta = 9437967;
 
COMMIT;
   
