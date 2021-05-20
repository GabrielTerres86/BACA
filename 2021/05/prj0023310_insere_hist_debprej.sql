BEGIN
  UPDATE craphis a
     SET a.indebprj = 1
   WHERE a.cdhistor IN (1441, 1465, 1215, 1188, 1219, 1208, 1493, 2084, 2087, 2093, 2090);
  UPDATE crapprm c
     SET C.DSVLRPRM = C.DSVLRPRM||';1441;1465;1215;1188;1219;1208;1493;2084;2087;2093;2090'
   WHERE c.cdacesso = 'HISTOR_PREJ_N_SALDO'
     AND cdcooper = 0
     AND nmsistem = 'CRED';
  COMMIT;
END;
