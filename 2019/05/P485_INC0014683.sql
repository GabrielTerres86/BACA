DECLARE 
  -- Registros a serem atualizados
  TYPE typ_rec_registro IS RECORD(nrnuporta   VARCHAR2(21)
                                 ,dtavalret   DATE
                                 ,dsdominio   VARCHAR2(50)
                                 ,cdmotivo    NUMBER
                                 ,idsituac    NUMBER);
  TYPE typ_tab_registros IS TABLE OF typ_rec_registro INDEX BY BINARY_INTEGER;
    
  vr_tbregist   typ_tab_registros;

BEGIN
  
  /** REGISTROS A SEREM ATUALIZADOS **/
  -- 1  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201812210000078068729';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('21/12/2018','dd/mm/yyyy'); 
  vr_tbregist(vr_tbregist.count()  ).dsdominio := NULL;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := NULL; 
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2;
  -- 2
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201812240000078170586';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('24/12/2018','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3;
  -- 3
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201812240000078189101';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('24/12/2018','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  -- 4
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201812240000078189106';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('24/12/2018','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3;
  -- 5
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201812260000078312999';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('26/12/2018','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3;
  -- 6
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201812260000078321152';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('26/12/2018','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3;
  -- 7
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201812260000078321241';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('26/12/2018','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  -- 8
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201812260000078327522';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('26/12/2018','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  -- 9
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201812270000078428535';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('27/12/2018','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3;
  -- 10
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201812270000078469419';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('27/12/2018','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3;
  -- 11
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201812280000078499504';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('28/12/2018','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  -- 12
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201812280000078541134';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('28/12/2018','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3;
  -- 13
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201812280000078543250';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('28/12/2018','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  -- 14
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201812280000078570499';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('28/12/2018','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  -- Percorrer os registros para serem ajustados
  FOR ind IN vr_tbregist.FIRST..vr_tbregist.LAST LOOP

    UPDATE tbcc_portabilidade_recebe t
       SET t.dtavaliacao        = vr_tbregist(ind).dtavalret
         , t.dtretorno          = vr_tbregist(ind).dtavalret
         , t.nmarquivo_resposta = 'RESPOSTA VIA PORTAL'
         , t.dsdominio_motivo   = vr_tbregist(ind).dsdominio
         , t.cdmotivo           = vr_tbregist(ind).cdmotivo
         , t.cdoperador         = '1'
         , t.idsituacao         = vr_tbregist(ind).idsituac
     WHERE t.nrnu_portabilidade = vr_tbregist(ind).nrnuporta;
  
  END LOOP;
   
  COMMIT;
  
END;
