update gnsbmod
set    dssubmod = 'Financiamento/Garantia de Im�vel'
where  cdmodali = '02' 
AND    cdsubmod = '11';
commit;
