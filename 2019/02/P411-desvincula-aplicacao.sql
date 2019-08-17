
-- Altera o tipo da aplicacao para ela não ser exportada
update tbcapt_custodia_aplicacao set tpaplicacao = 9 where idaplicacao = 2594670;

/*
"IDAPLICACAO";"TPAPLICACAO";"DTREGISTRO";"DSCODIGO_B3";"DTCONCILIA";"IDSITUA_CONCILIA";"QTCOTAS";"VLPRECO_UNITARIO";"VLREGISTRO";"VLPRECO_REGISTRO"
"2594670";"4";"";"";"";"";"100000";"0,01000000";"1000,00";"0,01000000"
*/

-- Seta como saque total para não apresentar problema em tela.
update craprac set idsaqtot = 1 where cdcooper = 16 and nrdconta = 6284337 and nraplica = 9;

commit;
