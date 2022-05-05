begin

   update craplft lft
      set lft.insitfat = 2
    where lft.dtmvtolt = TO_DATE('05/05/2022','DD/MM/RRRR')  
      and trim(lft.cdbarras) is not null
      and lft.vllanmto = 7.74;

  commit;
end;
/