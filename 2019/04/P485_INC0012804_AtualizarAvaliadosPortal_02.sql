DECLARE 

  TYPE typ_rec_registro IS RECORD(nrnuporta   VARCHAR2(21)
                                 ,dtavalret   DATE
                                 ,dsdominio   VARCHAR2(50)
                                 ,cdmotivo    NUMBER
                                 ,idsituac    NUMBER);
  TYPE typ_tab_registros IS TABLE OF typ_rec_registro INDEX BY BINARY_INTEGER;
  
  vr_tbregist   typ_tab_registros;

BEGIN
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901020000078625507';
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('02/01/2019','dd/mm/yyyy'); 
  vr_tbregist(vr_tbregist.count()  ).dsdominio := NULL;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := NULL; 
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901020000078645711';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('02/01/2019','dd/mm/yyyy'); 
  vr_tbregist(vr_tbregist.count()  ).dsdominio := NULL;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := NULL; 
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901020000078712129';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('02/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := NULL;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := NULL;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901030000078779406';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('03/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901030000078779411';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('03/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901030000078837167';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('03/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901040000078877779';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('04/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901040000078941920';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('04/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901040000078945157';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('04/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901040000078957613';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('04/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901040000078971279';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('04/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901070000079127600';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('07/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901070000079131455';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('07/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901080000079147181';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('08/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901080000079197668';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('08/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901080000079250175';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('08/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901080000079252486';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('08/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901080000079253224';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('08/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901090000079275320';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('09/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901090000079313432';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('09/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901090000079368186';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('09/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901100000079473065';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('10/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901100000079473077';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('10/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901100000079473217';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('10/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVACTECOMPRIOPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 1;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901100000079476913';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('10/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901110000079560178';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('11/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901110000079579620';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('11/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901110000079610496';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('11/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901140000079636684';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('14/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901140000079639789';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('14/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVACTECOMPRIOPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 1;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2 ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901140000079641293';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('14/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901140000079668463';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('14/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901140000079702531';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('14/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901140000079743791';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('14/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901150000079777152';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('15/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901150000079821654';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('15/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901150000079857673';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('15/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901150000079863071';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('15/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901160000079960094';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('16/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901160000079972454';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('16/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901170000080119324';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('17/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901170000080120034';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('17/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901180000080236235';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('18/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901210000080280325';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('21/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901210000080285732';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('21/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901230000080568807';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('23/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901240000080734923';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('24/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVACTECOMPRIOPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 1;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901250000080759441';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('25/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901250000080761017';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('25/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901250000080822030';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('25/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901280000081089770';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('28/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901290000081230021';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('29/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901290000081239398';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('29/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := null;
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := null;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 2  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901020000078702633';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('02/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901020000078714778';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('02/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 1;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901030000078778824';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('03/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901030000078832482';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('03/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901030000078849488';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('03/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 1;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901030000078849802';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('03/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 2;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901040000078944654';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('04/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 1;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901040000078961263';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('04/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 2;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901040000078971077';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('04/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901040000078979565';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('04/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901040000078980012';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('04/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 2;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901040000078984165';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('04/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901070000079012592';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('07/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901070000079017476';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('07/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 2;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901070000079129034';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('07/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901080000079171050';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('08/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 1;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901080000079224728';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('08/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901080000079225703';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('08/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 2;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901080000079251082';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('08/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 1;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901090000079275710';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('09/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901090000079305546';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('09/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901090000079331329';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('09/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901090000079368348';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('09/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901100000079447680';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('10/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901100000079468336';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('10/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901100000079476864';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('10/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901100000079476870';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('10/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901100000079483180';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('10/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901100000079484238';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('10/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901110000079530436';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('11/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901110000079569750';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('11/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901110000079598304';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('11/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901110000079604941';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('11/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901110000079607927';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('11/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 2;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901110000079610015';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('11/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901110000079610305';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('11/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901140000079642371';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('14/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901140000079661946';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('14/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901140000079699383';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('14/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901140000079705313';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('14/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901140000079717403';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('14/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901140000079741385';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('14/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901150000079777041';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('15/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901150000079841991';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('15/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901150000079852712';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('15/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901150000079857625';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('15/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 6;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901150000079870183';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('15/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901160000079962571';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('16/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901160000079980541';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('16/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901160000079981369';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('16/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901160000079989982';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('16/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901170000080086490';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('17/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901180000080222707';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('18/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901180000080223010';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('18/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 1;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901180000080225446';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('18/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 1;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901180000080236287';  
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('18/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3  ;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901180000080236396';   
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('18/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 1;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3	;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901230000080567247';   
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('23/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3	;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901250000080930781';   
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('25/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3	;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901280000080957715';   
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('28/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3	;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901280000081002888';   
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('28/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3	;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901280000081075489';   
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('28/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3	;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901280000081098714';   
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('28/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3	;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901290000081166224';   
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('29/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 2;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3	;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901290000081176010';   
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('29/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3	;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901290000081240438';   
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('29/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3	;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901070000079120367';   
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('07/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3	;
  
  vr_tbregist(vr_tbregist.count()+1).nrnuporta := '201901160000079942654';   
  vr_tbregist(vr_tbregist.count()  ).dtavalret := to_date('16/01/2019','dd/mm/yyyy');
  vr_tbregist(vr_tbregist.count()  ).dsdominio := 'MOTVREPRVCPORTDDCTSALR';
  vr_tbregist(vr_tbregist.count()  ).cdmotivo  := 7;
  vr_tbregist(vr_tbregist.count()  ).idsituac  := 3	;

    
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
