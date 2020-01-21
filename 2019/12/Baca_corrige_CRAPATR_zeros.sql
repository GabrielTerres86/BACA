-- corrige os casos antigos de seqtel com 60 posições

update crapatr set cdseqtel = LPAD(cdrefere,8,'0') where cdhistor = 961 and cdseqtel like '000000000000000000000000000000%';
commit;

update crapatr set cdseqtel = LPAD(cdrefere,8,'0') where cdhistor = 48 and (cdseqtel like '9807  %' or cdseqtel like '9806  %') ;
commit;