BEGIN
  
  INSERT INTO contacorrente.tbcc_solicitacao_bloqueio(idsolblq,
                                                      dtmvtolt,
                                                      nrdconta,
                                                      cdcooper,
                                                      vlbloquear,
                                                      vlbloqueado,
                                                      instatus,
                                                      tpsolicitacaoblq,
                                                      vldevolvido)
                                               VALUES('22ECBDBAC66F0830E0630A29357E1DD1'
                                                     ,to_Date('19/08/2024','dd/mm/yyyy')
                                                     ,81698216
                                                     ,16
                                                     ,77.36
                                                     ,0
                                                     ,0
                                                     ,1
                                                     ,0);
                                                     
  INSERT INTO contacorrente.tbcc_solicitacao_bloqueio(idsolblq,
                                                      dtmvtolt,
                                                      nrdconta,
                                                      cdcooper,
                                                      vlbloquear,
                                                      vlbloqueado,
                                                      instatus,
                                                      tpsolicitacaoblq,
                                                      vldevolvido)
                                               VALUES('22ECBDAFE5CC078AE0630A29357EB092'
                                                     ,to_Date('19/08/2024','dd/mm/yyyy')
                                                     ,81698216
                                                     ,16
                                                     ,163.83
                                                     ,0
                                                     ,0
                                                     ,1
                                                     ,0);
                                                     
  INSERT INTO contacorrente.tbcc_solicitacao_bloqueio(idsolblq,
                                                      dtmvtolt,
                                                      nrdconta,
                                                      cdcooper,
                                                      vlbloquear,
                                                      vlbloqueado,
                                                      instatus,
                                                      tpsolicitacaoblq,
                                                      vldevolvido)
                                               VALUES('22E9B048D8DB037EE0630A293573CC1D'
                                                     ,to_Date('19/08/2024','dd/mm/yyyy')
                                                     ,81698216
                                                     ,16
                                                     ,153.96
                                                     ,0
                                                     ,0
                                                     ,1
                                                     ,0);

  COMMIT;

END;
