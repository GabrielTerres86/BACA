begin 
update tbseg_parametros_prst t
   set t.dtfimvigencia = to_date('01/03/2035', 'dd/mm/rrrr')
 where cdcooper = 1
   and idseqpar = 1046;
   commit;
end;
/
