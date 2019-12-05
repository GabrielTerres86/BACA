-- corrige os casos antigos de seqtel com 60 posições

update crapatr set cdseqtel = LPAD(cdrefere,8,'0') where cdhistor = 961 and cdseqtel like '000000000000000000000000000000%';
commit;