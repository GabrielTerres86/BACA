update craptab
   set dstextab = '#1269|0 0101_digit_3.cecred.coop.br;'||
                  '#1406|0 0101_digit_11.cecred.coop.br;'||
                  '#1724|0 0101_digit_11.cecred.coop.br;'||
                  '#F0011021|0 0101_digit_11.cecred.coop.br;'||
                  '#F0011291|0 0101_digit_11.cecred.coop.br;'||
                  '#F0010694|0 0101_digit_9.cecred.coop.br;'||
                  '#F0011369|0 0101_digit_11.cecred.coop.br;'||
                  '#F0012388|0 0101_digit_9.cecred.coop.br;'||
                  '#F0012267|0 0101_digit_9.cecred.coop.br;'||
                  '#F0013938|0 0101_digit_11.cecred.coop.br;'||
                  '#F0013990|0 0101_digit_11.cecred.coop.br;'||
                  '#F0014249|0 0101_digit_11.cecred.coop.br;'||
                  '#F0015055|0 0101_digit_9.cecred.coop.br;'||
                  '#F0013938|0 0101_digit_9.cecred.coop.br;' ||
                  '#F0015462|0 0101_digit_9.cecred.coop.br;'    -- NOVO OPERADOR
 where nmsistem = 'CRED'
   and tptabela = 'GENERI'
   and cdempres = 0
   and cdacesso = 'OPEDIGITEXC'
   and tpregist = 0
   and cdcooper = 1;
commit;
