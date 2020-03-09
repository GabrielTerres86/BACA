--Refente ao chamado INC0037577 onde não esta sendo possivel realizar o pagamento de Boletos no IB e App Mobile.

   update craptab t
   set 
   dstextab = '0 79200 21600 SIM'
   WHERE 
       t.cdcooper = 11
   AND t.nmsistem = 'CRED'
   AND t.tptabela = 'GENERI'
   AND t.cdempres = 00
   AND t.cdacesso = 'HRTRTITULO'
   AND t.tpregist = 90;
   
   commit; 
