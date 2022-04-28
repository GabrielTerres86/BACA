BEGIN
  UPDATE tbseg_nrproposta p
     SET p.dtseguro = TO_DATE('06/02/2025','DD/MM/RRRR')
   WHERE p.dtseguro IS NULL;

  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (770119444136);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (77011944413);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (770119444144);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (77011944414);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (770119444152);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (77011944415);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (770119444160);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (77011944416);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (770119444179);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (77011944417);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (770119444187);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (77011944418);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (770119444195);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (77011944419);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (770119444209);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (77011944420);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (770119444217);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (77011944421);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (770119444225);
  INSERT INTO cecred.tbseg_nrproposta (nrproposta) VALUES (77011944422);
  COMMIT;
END;
/
