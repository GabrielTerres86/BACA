BEGIN
  /* Contratos abertos */
  UPDATE crapepr SET vlpgjmpr = 161.84 WHERE cdcooper = 1 AND nrdconta = 8756368 AND nrctremp = 1100509;
  UPDATE crapepr SET vlpgjmpr = 54.08 WHERE cdcooper = 1 AND nrdconta = 8343144 AND nrctremp = 1837450;
  UPDATE crapepr SET vlpgjmpr = 58.33 WHERE cdcooper = 1 AND nrdconta = 9256466 AND nrctremp = 1733880;
  UPDATE crapepr SET vlpgjmpr = 157.78 WHERE cdcooper = 1 AND nrdconta = 7255594 AND nrctremp = 1705616;
  UPDATE crapepr SET vlpgjmpr = 55.18 WHERE cdcooper = 1 AND nrdconta = 10199659 AND nrctremp = 1828828;
  UPDATE crapepr SET vlpgjmpr = 62.35 WHERE cdcooper = 1 AND nrdconta = 6616143 AND nrctremp = 1787182;
  UPDATE crapepr SET vlpgjmpr = 175.04 WHERE cdcooper = 1 AND nrdconta = 4079710 AND nrctremp = 1794688;
  UPDATE crapepr SET vlpgjmpr = 42.73 WHERE cdcooper = 1 AND nrdconta = 6487343 AND nrctremp = 1977504;
  UPDATE crapepr SET vlpgjmpr = 58.95 WHERE cdcooper = 1 AND nrdconta = 9351981 AND nrctremp = 1816451;
  /* contratos liquidados */
  UPDATE crapepr SET vlpgjmpr = 9.11 , vlpiofpr = 1.9 WHERE cdcooper = 1 AND nrdconta = 7769938 AND nrctremp = 2512245;
  UPDATE crapepr SET vlpgjmpr = 47.59 , vlpiofpr = 4.72 WHERE cdcooper = 1 AND nrdconta = 10290834 AND nrctremp = 1712576;
  UPDATE crapepr SET vlpgjmpr = 7.1 , vlpiofpr = 1.34 WHERE cdcooper = 1 AND nrdconta = 7769938 AND nrctremp = 1910330;
  UPDATE crapepr SET vlpgjmpr = 6.65 , vlpiofpr = 0 WHERE cdcooper = 1 AND nrdconta = 2641321 AND nrctremp = 642548;
  UPDATE crapepr SET vlpgjmpr = 7.28 , vlpiofpr = 1.63 WHERE cdcooper = 12 AND nrdconta = 114464 AND nrctremp = 1784953;
  UPDATE crapepr SET vlpgjmpr = 9.24 , vlpiofpr = 1.32 WHERE cdcooper = 12 AND nrdconta = 112380 AND nrctremp = 1867965;

  /* ------------------ Rollback  ------------------
    UPDATE crapepr SET vlpgjmpr = 323.68 WHERE cdcooper = 1 AND nrdconta = 8756368 AND nrctremp = 1100509;
    UPDATE crapepr SET vlpgjmpr = 108.16 WHERE cdcooper = 1 AND nrdconta = 8343144 AND nrctremp = 1837450;
    UPDATE crapepr SET vlpgjmpr = 116.66 WHERE cdcooper = 1 AND nrdconta = 9256466 AND nrctremp = 1733880;
    UPDATE crapepr SET vlpgjmpr = 315.56 WHERE cdcooper = 1 AND nrdconta = 7255594 AND nrctremp = 1705616;
    UPDATE crapepr SET vlpgjmpr = 110.36 WHERE cdcooper = 1 AND nrdconta = 10199659 AND nrctremp = 1828828;
    UPDATE crapepr SET vlpgjmpr = 124.7 WHERE cdcooper = 1 AND nrdconta = 6616143 AND nrctremp = 1787182;
    UPDATE crapepr SET vlpgjmpr = 221.08 WHERE cdcooper = 1 AND nrdconta = 4079710 AND nrctremp = 1794688;
    UPDATE crapepr SET vlpgjmpr = 85.46 WHERE cdcooper = 1 AND nrdconta = 6487343 AND nrctremp = 1977504;
    UPDATE crapepr SET vlpgjmpr = 117.9 WHERE cdcooper = 1 AND nrdconta = 9351981 AND nrctremp = 1816451;


    UPDATE crapepr SET vlpgjmpr = 18.22 , vlpiofpr = 0 WHERE cdcooper = 1 AND nrdconta = 7769938 AND nrctremp = 2512245;
    UPDATE crapepr SET vlpgjmpr = 190.36 , vlpiofpr = 0 WHERE cdcooper = 1 AND nrdconta = 10290834 AND nrctremp = 1712576;
    UPDATE crapepr SET vlpgjmpr = 28.4 , vlpiofpr = 0 WHERE cdcooper = 1 AND nrdconta = 7769938 AND nrctremp = 1910330;
    UPDATE crapepr SET vlpgjmpr = 13.3 , vlpiofpr = 0 WHERE cdcooper = 1 AND nrdconta = 2641321 AND nrctremp = 642548;
    UPDATE crapepr SET vlpgjmpr = 14.56 , vlpiofpr = 0 WHERE cdcooper = 12 AND nrdconta = 114464 AND nrctremp = 1784953;
    UPDATE crapepr SET vlpgjmpr = 18.48 , vlpiofpr = 0 WHERE cdcooper = 12 AND nrdconta = 112380 AND nrctremp = 1867965;
  */
  COMMIT;
END;