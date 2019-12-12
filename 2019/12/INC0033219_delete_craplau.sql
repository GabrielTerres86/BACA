--Exclusão de registro da tabela craplau - INC0033219

delete from craplau
where cdcooper = 6
  and cdagenci = 1
  and dtmvtolt = '16/07/2019'
  and ((nrdconta = 76066  and nrdocmto = 129) or
       (nrdconta = 87262  and nrdocmto = 130) or
       (nrdconta = 107468 and nrdocmto = 131) or
       (nrdconta = 107859 and nrdocmto = 132) or
       (nrdconta = 113964 and nrdocmto = 133) or
       (nrdconta = 125776 and nrdocmto = 134) or
       (nrdconta = 129763 and nrdocmto = 135) or
       (nrdconta = 136930 and nrdocmto = 136) or
       (nrdconta = 137863 and nrdocmto = 137) or
       (nrdconta = 157384 and nrdocmto = 138) or
       (nrdconta = 157414 and nrdocmto = 139) or
       (nrdconta = 504734 and nrdocmto = 140));
	   
	COMMIT;	   
