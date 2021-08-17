prompt Importing table juridico.tbjur_config_termo_adesao...
set feedback off
set define off

insert into juridico.tbjur_config_termo_adesao (IDCONFIG_TERMO_ADESAO, TPTERMO_ADESAO, NRVERSAO, NMVIEW, NMDOMINIO)
values (1, 1, 1, 'VWIB_TERMO_MULT_CONTAS', 'CECRED');

prompt Done.
