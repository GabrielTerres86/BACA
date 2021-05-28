update crapass c
set c.cdsitdct = 4
where c.dtdemiss is not null
and c.cdsitdct = 7
and c.dtdemiss < to_date('01/01/2019','DD/MM/YYYY');

commit;