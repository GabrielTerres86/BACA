-- INC0071554
update crapcon c set c.nrseqint = 9
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((79, 4, 1));
update crapcon c set c.nrseqint = 3
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((79, 4, 7));
update crapcon c set c.nrseqint = 23
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((1426, 2, 1));
update crapcon c set c.nrseqint = 22
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((1426, 2, 2));
update crapcon c set c.nrseqint = 4
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((1426, 2, 7));
update crapcon c set c.nrseqint = 4
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((1426, 2, 9));
update crapcon c set c.nrseqint = 6
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((1426, 2, 12));
update crapcon c set c.nrseqint = 5
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((1426, 2, 13));
--
update tbconv_deb_nao_efetiv t
   set t.dslinarq = 'F0000097286451            3239000000114185592020121400000000002471101672326542                                                                       0',
       t.dtmvtolt = trunc(sysdate)
 where t.dslinarq =
       'F0000972864510            3239000000114185592020121400000000002471101672326542                                                                       0';
--
commit;
