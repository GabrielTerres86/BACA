begin

update cecred.craptab
   set dstextab =  '#1269|0 0101_digit_3.ailos.coop.br;' ||
                   '#1406|0 0101_digit_11.ailos.coop.br;'||
                   '#1724|0 0101_digit_11.ailos.coop.br;'||
                   '#F0011021|0 0101_digit_11.ailos.coop.br;'||
                   '#F0011291|0 0101_digit_11.ailos.coop.br;'||
                   '#F0010694|0 0101_digit_9.ailos.coop.br;'||
                   '#F0011369|0 0101_digit_11.ailos.coop.br;'||
                   '#F0012388|0 0101_digit_9.ailos.coop.br;'||
                   '#F0012267|0 0101_digit_9.ailos.coop.br;'||
                   '#F0013938|0 0101_digit_11.ailos.coop.br;'||
                   '#F0013990|0 0101_digit_11.ailos.coop.br;'||
                   '#F0014249|0 0101_digit_11.ailos.coop.br;'||
                   '#F0015055|0 0101_digit_9.ailos.coop.br;'||
                   '#F0013938|0 0101_digit_9.ailos.coop.br;'||
                   '#F0015855|0 0101_digit_9.ailos.coop.br;'||
                   '#F0015904|0 0101_digit_9.ailos.coop.br;'||
                   '#F0015121|0 0101_digit_9.ailos.coop.br;'||
                   '#F0015551|0 0101_digit_9.ailos.coop.br;'||
                   '#F0015294|0 0101_digit_9.ailos.coop.br;' 
where nmsistem = 'CRED'
   and tptabela = 'GENERI'
   and cdempres = 0
   and cdacesso = 'OPEDIGITEXC'
   and tpregist = 0
   and cdcooper = 1;
commit;
end;
