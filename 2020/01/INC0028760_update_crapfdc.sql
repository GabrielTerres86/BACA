--INC0028760 cancelando as folhas de cheque do pedido 42916, conforme solicitado pela área

update crapfdc
   set dtemschq = '01/01/0001'
      ,dtretchq = '01/01/0001'
      ,cdoperad = 1
      ,incheque = 8
      ,dtrefatu = trunc(sysdate)
      ,dtliqchq = trunc(sysdate)
 where nrpedido = 42916
   and dtconchq = '23/12/2013'
   and dtemschq is null
   and incheque = 0;
    
	COMMIT;