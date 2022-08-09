BEGIN
  UPDATE tbblqj_ordem_online ordem
     SET ordem.instatus = 1
   WHERE ordem.instatus = 5
     AND ordem.idordem = 2785805;
END;