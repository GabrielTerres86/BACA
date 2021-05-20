-- INC0079656  remoção de grupo econômico e ajuste em CPF/CNPJs
delete tbcc_grupo_economico_integ
where nrdconta = 2751950
and cdcooper = 1
and idgrupo = 81473;

update tbcc_grupo_economico_integ
set nrcpfcgc = 00430725930
where cdcooper = 1
and idintegrante = 327216;

update tbcc_grupo_economico_integ
set nrcpfcgc = 79468560910
where cdcooper = 1
and idintegrante = 221438;

update tbcc_grupo_economico_integ
set nrcpfcgc = 81814062904
where cdcooper = 1
and idintegrante = 301239;
-- INC0079656  remoção de grupo econômico e ajuste em CPF/CNPJs

COMMIT;
