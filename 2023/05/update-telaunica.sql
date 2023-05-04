begin

update tbgen_analise_credito set nrversao_analise = 2 where idanalise_contrato = 5778545 and nrdconta = 99998270;

update tbgen_analise_credito set nrversao_analise = 1 where idanalise_contrato = 5778546 and nrdconta = 99998270;

commit;

end;
