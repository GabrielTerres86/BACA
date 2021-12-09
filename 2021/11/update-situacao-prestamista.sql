begin
update crapseg set dtcancel = to_date('dd/mm/yyyy','09/12/2021') , cdsitseg = 2 where nrdconta = 558176 and cdcooper = 2 and nrctrseg = 17944;
commit;
end;