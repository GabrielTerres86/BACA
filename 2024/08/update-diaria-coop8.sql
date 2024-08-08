BEGIN
  
delete 
from cecred.crapsqu 
where UPPER(nmtabela)  = upper('CRAPNEG')
and UPPER(nmdcampo)  = upper('NRSEQDIG')
and UPPER(dsdchave)  like upper('8;%');

insert into cecred.crapsqu (nmtabela, nmdcampo, dsdchave, nrseqatu)
select 'CRAPNEG', 'NRSEQDIG', '8;'||nrdconta, 2000 from crapass where cdcooper = 8;

COMMIT;

END;
