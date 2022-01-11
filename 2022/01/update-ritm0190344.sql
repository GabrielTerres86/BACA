BEGIN
update craptab
   set dstextab = dstextab ||'#F0015904|0 0101_digit_9.cecred.coop.br;#F0015121|0 0101_digit_9.cecred.coop.br;'
 where nmsistem = 'CRED'
   and tptabela = 'GENERI'
   and cdempres = 0
   and cdacesso = 'OPEDIGITEXC'
   and tpregist = 0
   and cdcooper = 1;
commit;
END;
