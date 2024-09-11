BEGIN

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 1
     and a.cdlcremp = 61105;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 1
     and a.cdlcremp = 20604;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 1
     and a.cdlcremp = 20704;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 1
     and a.cdlcremp = 60704;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 1
     and a.cdlcremp = 60603;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 1
     and a.cdlcremp = 60703;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 1
     and a.cdlcremp = 21106;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 1
     and a.cdlcremp = 61103;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 1
     and a.cdlcremp = 20705;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 1
     and a.cdlcremp = 10603;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 1
     and a.cdlcremp = 51101;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 1
     and a.cdlcremp = 60604;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 1
     and a.cdlcremp = 20605;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 1
     and a.cdlcremp = 21107;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 1
     and a.cdlcremp = 61102;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 1
     and a.cdlcremp = 50601;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 1
     and a.cdlcremp = 10802;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 2
     and a.cdlcremp = 4405;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 14
     and a.cdlcremp = 8105;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 14
     and a.cdlcremp = 8106;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 14
     and a.cdlcremp = 8107;

  update cecred.craplcr a
     set a.cdmigracao = 517, a.cdconvivencia = 617
   where cdcooper = 16
     and a.cdlcremp = 53207;

  update cecred.craplcr a
     set a.cdmigracao = 518, a.cdconvivencia = 618
   where cdcooper = 2
     and a.cdlcremp = 1251;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
