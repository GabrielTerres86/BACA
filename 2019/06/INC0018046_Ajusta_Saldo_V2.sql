-- DIF.: 05/06/2019: Vlsddisp: -2400  Vlsdchsl: 0  Vlsdbloq: 0  Vlsdblpr: 0  Vlsdblfp: 0
-- DIF.: 06/06/2019: Vlsddisp: -2400  Vlsdchsl: 0  Vlsdbloq: 0  Vlsdblpr: 0  Vlsdblfp: 0
-- DIF.: 07/06/2019: Vlsddisp: -2400  Vlsdchsl: 0  Vlsdbloq: 0  Vlsdblpr: 0  Vlsdblfp: 0
-- DIF.: 10/06/2019: Vlsddisp: -2400  Vlsdchsl: 0  Vlsdbloq: 0  Vlsdblpr: 0  Vlsdblfp: 0
-- DIF.: 11/06/2019: Vlsddisp: -2400  Vlsdchsl: 0  Vlsdbloq: 0  Vlsdblpr: 0  Vlsdblfp: 0
-- DIF.: 12/06/2019: Vlsddisp: -2400  Vlsdchsl: 0  Vlsdbloq: 0  Vlsdblpr: 0  Vlsdblfp: 0
-- DIF.: 13/06/2019: Vlsddisp: -2400  Vlsdchsl: 0  Vlsdbloq: 0  Vlsdblpr: 0  Vlsdblfp: 0
-- DIF.: 14/06/2019: Vlsddisp: -2400  Vlsdchsl: 0  Vlsdbloq: 0  Vlsdblpr: 0  Vlsdblfp: 0
-- LISTAGEM DE UPDATES PARA CORRECAO DE SALDO
--05/06/2019
update crapsda c set c.vlsddisp = c.vlsddisp - 2400  where c.rowid = 'AAs4KzADSAACFSCABf';

--06/06/2019
update crapsda c set c.vlsddisp = c.vlsddisp - 2400  where c.rowid = 'AAs4KzADUAABwETAA8';

--07/06/2019
update crapsda c set c.vlsddisp = c.vlsddisp - 2400  where c.rowid = 'AAs4KzADSAACIhsAA7';

--10/06/2019
update crapsda c set c.vlsddisp = c.vlsddisp - 2400  where c.rowid = 'AAs4KzADTAAB7yHADV';

--11/06/2019
update crapsda c set c.vlsddisp = c.vlsddisp - 2400  where c.rowid = 'AAs4KzADVAABlbJAAt';

--12/06/2019
update crapsda c set c.vlsddisp = c.vlsddisp - 2400  where c.rowid = 'AAs4KzADWAABZmcAC+';

--13/06/2019
update crapsda c set c.vlsddisp = c.vlsddisp - 2400  where c.rowid = 'AAs4KzADXAABaUJAA7';

--14/06/2019
update crapsda c set c.vlsddisp = c.vlsddisp - 2400  where c.rowid = 'AAs4KzADTAAB+XcADG';

--CRAPSLD
update crapsld c set c.vlsddisp = c.vlsddisp - 2400  where c.cdcooper = 1    and c.nrdconta = 10536698;

COMMIT;
