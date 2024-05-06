BEGIN
  delete 
from CECRED.crapsqu 
where UPPER(nmtabela)  = upper('CRAPNEG')
and UPPER(nmdcampo)  = upper('NRSEQDIG')
and UPPER(dsdchave)  like upper('6;%');

insert into CECRED.crapsqu (nmtabela, nmdcampo, dsdchave, nrseqatu)
select 'CRAPNEG', 'NRSEQDIG', '6;'||nrdconta, 3000 from crapass where cdcooper = 6;

COMMIT;
END;
