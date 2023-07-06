   begin
update cecred.craptab
   set dstextab =  '#F0015055|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0013938|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0015855|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0015904|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0015121|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0015551|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0015294|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0016271|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0016223|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0016748|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0015395|0 0101_digit_9.ailos.coop.br;' ||
                   '#F0016218|0 0101_digit_9.ailos.coop.br;'
           
where UPPER(nmsistem) = 'CRED'
   and UPPER(tptabela) = 'GENERI'
   and cdempres = 0
   and UPPER(cdacesso) = 'OPEDIGITEXC'
   and tpregist = 0
   and cdcooper = 1;
commit;
end;
