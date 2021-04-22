update gnsbmod
set    dssubmod = 'Financiamento/Garantia de Imóvel'
where  cdmodali = '02' 
AND    cdsubmod = '11';
commit;
