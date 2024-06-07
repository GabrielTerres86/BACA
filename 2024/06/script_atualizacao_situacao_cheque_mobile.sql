begin 
  update cecred.tbchq_deposito_cheque_mob mob
         set insituacao = 2
         where mob.cdcooper = 9
           and mob.dtdeposito = '06/06/2024';
  commit;
end;
