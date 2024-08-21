BEGIN
  
  UPDATE cecred.crawseg w
     SET w.nrcpfcgc = 47777303953
   WHERE cdcooper = 1
     AND nrdconta = 801950
     AND nrcpfcgc IN ('477.773.039-53','0');
     
 COMMIT;
END;
