BEGIN

  update investimento.tbinvest_saldo_base_fria 
    set NRCONTA = 100001128 
    where NMPRODUTO  like 'RDC P%'
    and NRCONTA =  12609099
    and IDINSTITUICAOEMISSAO = 7;

  update investimento.tbinvest_base_fria_moviment 
    set NRCONTA = 100001128 
    where NMPRODUTO  like 'RDC P%'
    and NRCONTA =  12609099
    and IDINSTITUICAOEMISSAO = 7;

  update investimento.tbinvest_saldo_base_fria 
    set NRCONTA = 100002388 
    where NMPRODUTO  like 'RDC P%'
    and NRCONTA = 560030
    and IDINSTITUICAOEMISSAO = 1;

  update investimento.tbinvest_base_fria_moviment 
    set NRCONTA = 100002388 
    where NMPRODUTO  like 'RDC P%'
    and NRCONTA = 560030
    and IDINSTITUICAOEMISSAO = 1;

  commit;

END;
