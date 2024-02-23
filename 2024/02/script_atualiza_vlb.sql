begin
  update cecred.craptab
     set dstextab = '5000,00;0,00;1000,00'
   where cdacesso = 'VALORESVLB'
     and cdcooper = 1;
  commit;
end;


