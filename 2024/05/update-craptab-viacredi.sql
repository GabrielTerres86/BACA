begin
update cecred.craptab
   set dstextab =  '#F0015055|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0013938|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0015551|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0016271|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0016748|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0015395|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0016837|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0015036|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0016418|0 0101_digit_9.ailos.coop.br;' 
           
where UPPER(nmsistem) = 'CRED'
   and UPPER(tptabela) = 'GENERI'
   and cdempres = 0
   and UPPER(cdacesso) = 'OPEDIGITEXC'
   and tpregist = 0
   and cdcooper = 1;
commit;
end;
