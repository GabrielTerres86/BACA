DECLARE
BEGIN
  UPDATE credito.tbcred_preaprov_det
     SET credito.tbcred_preaprov_det.insituacao          = 'B',
         credito.tbcred_preaprov_det.dtbloqueio          = SYSDATE,
         credito.tbcred_preaprov_det.cdoperador_bloqueio = user
   WHERE credito.tbcred_preaprov_det.idcarga in
         (select distinct c.idcarga
            from credito.tbcred_preaprov c, credito.tbcred_preaprov_det cd
           where c.idcarga = cd.idcarga
             and cd.insituacao = 'A'
             and c.insituacao = 4);
  COMMIT;
END;
