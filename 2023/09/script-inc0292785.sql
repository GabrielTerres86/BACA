BEGIN

update investimento.tbinvest_saldo_base_fria t 
   set t.NRCONTA = 100002450 
 where t.NMPRODUTO  like 'RDC PÓS%' 
   and t.NRCONTA =  805777 
   and t.IDINSTITUICAOEMISSAO = 1;
   
update investimento.tbinvest_base_fria_moviment t 
   set t.NRCONTA = 100002450 
 where t.NMPRODUTO  like 'RDC PÓS%' 
   and t.NRCONTA =  805777 
   and t.IDINSTITUICAOEMISSAO = 1;
   
commit;

end;   
