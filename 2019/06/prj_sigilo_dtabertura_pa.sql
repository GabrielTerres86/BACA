DECLARE
  -- Dados da Agencia
  TYPE typ_rec_pa IS RECORD (cdcooper INTEGER
                            ,cdagenci INTEGER
                            ,dtabertu DATE
                            ,dstelefo VARCHAR2(20));
  -- Agencia
  TYPE typ_tbpa IS TABLE OF typ_rec_pa INDEX BY VARCHAR2(10);
  vr_tbpa typ_tbpa;
  
  vr_index VARCHAR2(10);
BEGIN
  -- Coop: 1 - PA: 1
  vr_tbpa('001_0001').cdcooper := 1;
  vr_tbpa('001_0001').cdagenci := 1;
  vr_tbpa('001_0001').dtabertu := to_date('17/01/1968','DD/MM/YYYY');
  vr_tbpa('001_0001').dstelefo := '4733314665';

  -- Coop: 1 - PA: 2
  vr_tbpa('001_0002').cdcooper := 1;
  vr_tbpa('001_0002').cdagenci := 2;
  vr_tbpa('001_0002').dtabertu := to_date('02/05/1983','DD/MM/YYYY');
  vr_tbpa('001_0002').dstelefo := '4733284803';

  -- Coop: 1 - PA: 3
  vr_tbpa('001_0003').cdcooper := 1;
  vr_tbpa('001_0003').cdagenci := 3;
  vr_tbpa('001_0003').dtabertu := to_date('01/07/1985','DD/MM/YYYY');
  vr_tbpa('001_0003').dstelefo := '4733283900';

  -- Coop: 1 - PA: 7
  vr_tbpa('001_0007').cdcooper := 1;
  vr_tbpa('001_0007').cdagenci := 7;
  vr_tbpa('001_0007').dtabertu := to_date('05/10/1988','DD/MM/YYYY');
  vr_tbpa('001_0007').dstelefo := '4733572520';

  -- Coop: 1 - PA: 8
  vr_tbpa('001_0008').cdcooper := 1;
  vr_tbpa('001_0008').cdagenci := 8;
  vr_tbpa('001_0008').dtabertu := to_date('07/07/1986','DD/MM/YYYY');
  vr_tbpa('001_0008').dstelefo := '4733371157';

  -- Coop: 1 - PA: 9
  vr_tbpa('001_0009').cdcooper := 1;
  vr_tbpa('001_0009').cdagenci := 9;
  vr_tbpa('001_0009').dtabertu := to_date('01/06/1984','DD/MM/YYYY');
  vr_tbpa('001_0009').dstelefo := '4733323958';

  -- Coop: 1 - PA: 15
  vr_tbpa('001_0015').cdcooper := 1;
  vr_tbpa('001_0015').cdagenci := 15;
  vr_tbpa('001_0015').dtabertu := to_date('30/09/2014','DD/MM/YYYY');
  vr_tbpa('001_0015').dstelefo := '4733440836';

  -- Coop: 1 - PA: 18
  vr_tbpa('001_0018').cdcooper := 1;
  vr_tbpa('001_0018').cdagenci := 18;
  vr_tbpa('001_0018').dtabertu := to_date('01/11/2001','DD/MM/YYYY');
  vr_tbpa('001_0018').dstelefo := '4733339564';

  -- Coop: 1 - PA: 19
  vr_tbpa('001_0019').cdcooper := 1;
  vr_tbpa('001_0019').cdagenci := 19;
  vr_tbpa('001_0019').dtabertu := to_date('25/07/2002','DD/MM/YYYY');
  vr_tbpa('001_0019').dstelefo := '4733400885';

  -- Coop: 1 - PA: 21
  vr_tbpa('001_0021').cdcooper := 1;
  vr_tbpa('001_0021').cdagenci := 21;
  vr_tbpa('001_0021').dtabertu := to_date('01/08/2003','DD/MM/YYYY');
  vr_tbpa('001_0021').dstelefo := '4733721302';

  -- Coop: 1 - PA: 22
  vr_tbpa('001_0022').cdcooper := 1;
  vr_tbpa('001_0022').cdagenci := 22;
  vr_tbpa('001_0022').dtabertu := to_date('05/03/2004','DD/MM/YYYY');
  vr_tbpa('001_0022').dstelefo := '4733321243';

  -- Coop: 1 - PA: 23
  vr_tbpa('001_0023').cdcooper := 1;
  vr_tbpa('001_0023').cdagenci := 23;
  vr_tbpa('001_0023').dtabertu := to_date('17/03/2004','DD/MM/YYYY');
  vr_tbpa('001_0023').dstelefo := '4733826433';

  -- Coop: 1 - PA: 25
  vr_tbpa('001_0025').cdcooper := 1;
  vr_tbpa('001_0025').cdagenci := 25;
  vr_tbpa('001_0025').dtabertu := to_date('07/04/2004','DD/MM/YYYY');
  vr_tbpa('001_0025').dstelefo := '4733498304';

  -- Coop: 1 - PA: 28
  vr_tbpa('001_0028').cdcooper := 1;
  vr_tbpa('001_0028').cdagenci := 28;
  vr_tbpa('001_0028').dtabertu := to_date('11/05/2005','DD/MM/YYYY');
  vr_tbpa('001_0028').dstelefo := '4733383326';

  -- Coop: 1 - PA: 30
  vr_tbpa('001_0030').cdcooper := 1;
  vr_tbpa('001_0030').cdagenci := 30;
  vr_tbpa('001_0030').dtabertu := to_date('18/07/2005','DD/MM/YYYY');
  vr_tbpa('001_0030').dstelefo := '4733490939';

  -- Coop: 1 - PA: 31
  vr_tbpa('001_0031').cdcooper := 1;
  vr_tbpa('001_0031').cdagenci := 31;
  vr_tbpa('001_0031').dtabertu := to_date('02/08/2005','DD/MM/YYYY');
  vr_tbpa('001_0031').dstelefo := '4733254366';

  -- Coop: 1 - PA: 34
  vr_tbpa('001_0034').cdcooper := 1;
  vr_tbpa('001_0034').cdagenci := 34;
  vr_tbpa('001_0034').dtabertu := to_date('01/12/2005','DD/MM/YYYY');
  vr_tbpa('001_0034').dstelefo := '4733339523';

  -- Coop: 1 - PA: 37
  vr_tbpa('001_0037').cdcooper := 1;
  vr_tbpa('001_0037').cdagenci := 37;
  vr_tbpa('001_0037').dtabertu := to_date('27/11/2008','DD/MM/YYYY');
  vr_tbpa('001_0037').dstelefo := '4733732726';

  -- Coop: 1 - PA: 41
  vr_tbpa('001_0041').cdcooper := 1;
  vr_tbpa('001_0041').cdagenci := 41;
  vr_tbpa('001_0041').dtabertu := to_date('05/12/2007','DD/MM/YYYY');
  vr_tbpa('001_0041').dstelefo := '4733260132';

  -- Coop: 1 - PA: 42
  vr_tbpa('001_0042').cdcooper := 1;
  vr_tbpa('001_0042').cdagenci := 42;
  vr_tbpa('001_0042').dtabertu := to_date('04/06/2008','DD/MM/YYYY');
  vr_tbpa('001_0042').dstelefo := '4733974854';

  -- Coop: 1 - PA: 44
  vr_tbpa('001_0044').cdcooper := 1;
  vr_tbpa('001_0044').cdagenci := 44;
  vr_tbpa('001_0044').dtabertu := to_date('01/09/2008','DD/MM/YYYY');
  vr_tbpa('001_0044').dstelefo := '4733430073';

  -- Coop: 1 - PA: 45
  vr_tbpa('001_0045').cdcooper := 1;
  vr_tbpa('001_0045').cdagenci := 45;
  vr_tbpa('001_0045').dtabertu := to_date('23/09/2008','DD/MM/YYYY');
  vr_tbpa('001_0045').dstelefo := '4733860660';
    
  -- Coop: 1 - PA: 46
  vr_tbpa('001_0046').cdcooper := 1;
  vr_tbpa('001_0046').cdagenci := 46;
  vr_tbpa('001_0046').dtabertu := to_date('30/10/2008','DD/MM/YYYY');
  vr_tbpa('001_0046').dstelefo := '4733943644';
    
  -- Coop: 1 - PA: 48
  vr_tbpa('001_0048').cdcooper := 1;
  vr_tbpa('001_0048').cdagenci := 48;
  vr_tbpa('001_0048').dtabertu := to_date('16/02/2009','DD/MM/YYYY');
  vr_tbpa('001_0048').dstelefo := '4733391874';

  -- Coop: 1 - PA: 49
  vr_tbpa('001_0049').cdcooper := 1;
  vr_tbpa('001_0049').cdagenci := 49;
  vr_tbpa('001_0049').dtabertu := to_date('27/03/2009','DD/MM/YYYY');
  vr_tbpa('001_0049').dstelefo := '4733292882';

  -- Coop: 1 - PA: 51
  vr_tbpa('001_0051').cdcooper := 1;
  vr_tbpa('001_0051').cdagenci := 51;
  vr_tbpa('001_0051').dtabertu := to_date('04/09/2009','DD/MM/YYYY');
  vr_tbpa('001_0051').dstelefo := '4733277868';

  -- Coop: 1 - PA: 52
  vr_tbpa('001_0052').cdcooper := 1;
  vr_tbpa('001_0052').cdagenci := 52;
  vr_tbpa('001_0052').dtabertu := to_date('14/10/2009','DD/MM/YYYY');
  vr_tbpa('001_0052').dstelefo := '4733326266';

  -- Coop: 1 - PA: 58
  vr_tbpa('001_0058').cdcooper := 1;
  vr_tbpa('001_0058').cdagenci := 58;
  vr_tbpa('001_0058').dtabertu := to_date('01/01/2011','DD/MM/YYYY');
  vr_tbpa('001_0058').dstelefo := '4733556501';

  -- Coop: 1 - PA: 61
  vr_tbpa('001_0061').cdcooper := 1;
  vr_tbpa('001_0061').cdagenci := 61;
  vr_tbpa('001_0061').dtabertu := to_date('20/01/2011','DD/MM/YYYY');
  vr_tbpa('001_0061').dstelefo := '4733543897';

  -- Coop: 1 - PA: 62
  vr_tbpa('001_0062').cdcooper := 1;
  vr_tbpa('001_0062').cdagenci := 62;
  vr_tbpa('001_0062').dtabertu := to_date('12/04/2011','DD/MM/YYYY');
  vr_tbpa('001_0062').dstelefo := '4735218082';

  -- Coop: 1 - PA: 63
  vr_tbpa('001_0063').cdcooper := 1;
  vr_tbpa('001_0063').cdagenci := 63;
  vr_tbpa('001_0063').dtabertu := to_date('07/07/2011','DD/MM/YYYY');
  vr_tbpa('001_0063').dstelefo := '4733947718';

  -- Coop: 1 - PA: 64
  vr_tbpa('001_0064').cdcooper := 1;
  vr_tbpa('001_0064').cdagenci := 64;
  vr_tbpa('001_0064').dtabertu := to_date('15/09/2011','DD/MM/YYYY');
  vr_tbpa('001_0064').dstelefo := '4733232602';

  -- Coop: 1 - PA: 71
  vr_tbpa('001_0071').cdcooper := 1;
  vr_tbpa('001_0071').cdagenci := 71;
  vr_tbpa('001_0071').dtabertu := to_date('25/10/2012','DD/MM/YYYY');
  vr_tbpa('001_0071').dstelefo := '4733399054';

  -- Coop: 1 - PA: 72
  vr_tbpa('001_0072').cdcooper := 1;
  vr_tbpa('001_0072').cdagenci := 72;
  vr_tbpa('001_0072').dtabertu := to_date('19/12/2012','DD/MM/YYYY');
  vr_tbpa('001_0072').dstelefo := '4732738017';

  -- Coop: 1 - PA: 73
  vr_tbpa('001_0073').cdcooper := 1;
  vr_tbpa('001_0073').cdagenci := 73;
  vr_tbpa('001_0073').dtabertu := to_date('01/09/2008','DD/MM/YYYY');
  vr_tbpa('001_0073').dstelefo := '4733430073';

  -- Coop: 1 - PA: 76
  vr_tbpa('001_0076').cdcooper := 1;
  vr_tbpa('001_0076').cdagenci := 76;
  vr_tbpa('001_0076').dtabertu := to_date('21/06/2013','DD/MM/YYYY');
  vr_tbpa('001_0076').dstelefo := '4733557894';

  -- Coop: 1 - PA: 79
  vr_tbpa('001_0078').cdcooper := 1;
  vr_tbpa('001_0078').cdagenci := 78;
  vr_tbpa('001_0078').dtabertu := to_date('15/10/2013','DD/MM/YYYY');
  vr_tbpa('001_0078').dstelefo := '4733469505';    

  -- Coop: 1 - PA: 79
  vr_tbpa('001_0079').cdcooper := 1;
  vr_tbpa('001_0079').cdagenci := 79;
  vr_tbpa('001_0079').dtabertu := to_date('17/12/2013','DD/MM/YYYY');
  vr_tbpa('001_0079').dstelefo := '4733469505';    
    
  -- Coop: 1 - PA: 85
  vr_tbpa('001_0085').cdcooper := 1;
  vr_tbpa('001_0085').cdagenci := 85;
  vr_tbpa('001_0085').dtabertu := to_date('02/01/2014','DD/MM/YYYY');
  vr_tbpa('001_0085').dstelefo := '4733873403';
    
  -- Coop: 1 - PA: 86
  vr_tbpa('001_0086').cdcooper := 1;
  vr_tbpa('001_0086').cdagenci := 86;
  vr_tbpa('001_0086').dtabertu := to_date('02/01/2014','DD/MM/YYYY');
  vr_tbpa('001_0086').dstelefo := '4733380290';

  -- Coop: 1 - PA: 87
  vr_tbpa('001_0087').cdcooper := 1;
  vr_tbpa('001_0087').cdagenci := 87;
  vr_tbpa('001_0087').dtabertu := to_date('02/01/2014','DD/MM/YYYY');
  vr_tbpa('001_0087').dstelefo := '4733873797';

  -- Coop: 1 - PA: 88
  vr_tbpa('001_0088').cdcooper := 1;
  vr_tbpa('001_0088').cdagenci := 88;
  vr_tbpa('001_0088').dtabertu := to_date('02/01/2014','DD/MM/YYYY');
  vr_tbpa('001_0088').dstelefo := '4733875544';    
  
  -- Coop: 2 - PA: 6
  vr_tbpa('002_0006').cdcooper := 2;
  vr_tbpa('002_0006').cdagenci := 6;
  vr_tbpa('002_0006').dtabertu := to_date('08/10/2007','DD/MM/YYYY');
  vr_tbpa('002_0006').dstelefo := '4733380290';

  -- Coop: 2 - PA: 7
  vr_tbpa('002_0007').cdcooper := 2;
  vr_tbpa('002_0007').cdagenci := 7;
  vr_tbpa('002_0007').dtabertu := to_date('08/10/2007','DD/MM/YYYY');
  vr_tbpa('002_0007').dstelefo := '4733873797';

  -- Coop: 2 - PA: 8
  vr_tbpa('002_0008').cdcooper := 2;
  vr_tbpa('002_0008').cdagenci := 8;
  vr_tbpa('002_0008').dtabertu := to_date('01/12/2006','DD/MM/YYYY');
  vr_tbpa('002_0008').dstelefo := '4734679950';

  -- Coop: 2 - PA: 10
  vr_tbpa('002_0010').cdcooper := 2;
  vr_tbpa('002_0010').cdagenci := 10;
  vr_tbpa('002_0010').dtabertu := to_date('23/03/2010','DD/MM/YYYY');
  vr_tbpa('002_0010').dstelefo := '4734667722';

  -- Coop: 2 - PA: 11
  vr_tbpa('002_0011').cdcooper := 2;
  vr_tbpa('002_0011').cdagenci := 11;
  vr_tbpa('002_0011').dtabertu := to_date('01/11/2010','DD/MM/YYYY');
  vr_tbpa('002_0011').dstelefo := '4733875544';

  -- Coop: 2 - PA: 13
  vr_tbpa('002_0013').cdcooper := 2;
  vr_tbpa('002_0013').cdagenci := 13;
  vr_tbpa('002_0013').dtabertu := to_date('01/12/2006','DD/MM/YYYY');
  vr_tbpa('002_0013').dstelefo := '4734679950';

  -- Coop: 2 - PA: 14
  vr_tbpa('002_0014').cdcooper := 2;
  vr_tbpa('002_0014').cdagenci := 14;
  vr_tbpa('002_0014').dtabertu := to_date('18/11/2013','DD/MM/YYYY');
  vr_tbpa('002_0014').dstelefo := '4734339946';
  
  -- Coop: 6 - PA: 5
  vr_tbpa('006_0005').cdcooper := 6;
  vr_tbpa('006_0005').cdagenci := 5;
  vr_tbpa('006_0005').dtabertu := to_date('09/07/2014','DD/MM/YYYY');
  vr_tbpa('006_0005').dstelefo := '4832830064';
    
  -- Coop: 7 - PA: 1
  vr_tbpa('007_0001').cdcooper := 7;
  vr_tbpa('007_0001').cdagenci := 1;
  vr_tbpa('007_0001').dtabertu := to_date('17/05/2004','DD/MM/YYYY');
  vr_tbpa('007_0001').dstelefo := '4833240306';
    
  -- Coop: 7 - PA: 2
  vr_tbpa('007_0002').cdcooper := 7;
  vr_tbpa('007_0002').cdagenci := 2;
  vr_tbpa('007_0002').dtabertu := to_date('17/07/2006','DD/MM/YYYY');
  vr_tbpa('007_0002').dstelefo := '4732732155';
    
  -- Coop: 7 - PA: 3
  vr_tbpa('007_0003').cdcooper := 7;
  vr_tbpa('007_0003').cdagenci := 3;
  vr_tbpa('007_0003').dtabertu := to_date('05/02/2007','DD/MM/YYYY');
  vr_tbpa('007_0003').dstelefo := '4732491501';

  -- Coop: 7 - PA: 6
  vr_tbpa('007_0006').cdcooper := 7;
  vr_tbpa('007_0006').cdagenci := 6;
  vr_tbpa('007_0006').dtabertu := to_date('22/01/2010','DD/MM/YYYY');
  vr_tbpa('007_0006').dstelefo := '4832342831';
    
  -- Coop: 7 - PA: 9
  vr_tbpa('007_0009').cdcooper := 7;
  vr_tbpa('007_0009').cdagenci := 9;
  vr_tbpa('007_0009').dtabertu := to_date('11/11/2013','DD/MM/YYYY');
  vr_tbpa('007_0009').dstelefo := '4132236162';
    
  -- Coop: 8 - PA: 1
  vr_tbpa('008_0001').cdcooper := 8;
  vr_tbpa('008_0001').cdagenci := 1;
  vr_tbpa('008_0001').dtabertu := to_date('25/07/2007','DD/MM/YYYY');
  vr_tbpa('008_0001').dstelefo := '4833221111';
    
  -- Coop: 9 - PA: 1
  vr_tbpa('009_0001').cdcooper := 9;
  vr_tbpa('009_0001').cdagenci := 1;
  vr_tbpa('009_0001').dtabertu := to_date('29/07/2013','DD/MM/YYYY');
  vr_tbpa('009_0001').dstelefo := '4833481722';

  -- Coop: 9 - PA: 4
  vr_tbpa('009_0004').cdcooper := 9;
  vr_tbpa('009_0004').cdagenci := 4;
  vr_tbpa('009_0004').dtabertu := to_date('25/04/2007','DD/MM/YYYY');
  vr_tbpa('009_0004').dstelefo := '4933294430';

  -- Coop: 9 - PA: 5
  vr_tbpa('009_0005').cdcooper := 9;
  vr_tbpa('009_0005').cdagenci := 5;
  vr_tbpa('009_0005').dtabertu := to_date('27/04/2010','DD/MM/YYYY');
  vr_tbpa('009_0005').dstelefo := '4733478502';

  -- Coop: 11 - PA: 1
  vr_tbpa('011_0001').cdcooper := 11;
  vr_tbpa('011_0001').cdagenci := 1;
  vr_tbpa('011_0001').dtabertu := to_date('15/05/2008','DD/MM/YYYY');
  vr_tbpa('011_0001').dstelefo := '4733499085';

  -- Coop: 11 - PA: 2
  vr_tbpa('011_0002').cdcooper := 11;
  vr_tbpa('011_0002').cdagenci := 2;
  vr_tbpa('011_0002').dtabertu := to_date('30/04/2009','DD/MM/YYYY');
  vr_tbpa('011_0002').dstelefo := '4733481818';

  -- Coop: 11 - PA: 4
  vr_tbpa('011_0004').cdcooper := 11;
  vr_tbpa('011_0004').cdagenci := 4;
  vr_tbpa('011_0004').dtabertu := to_date('15/06/2011','DD/MM/YYYY');
  vr_tbpa('011_0004').dstelefo := '4733634025';

  -- Coop: 11 - PA: 6
  vr_tbpa('011_0006').cdcooper := 11;
  vr_tbpa('011_0006').cdagenci := 6;
  vr_tbpa('011_0006').dtabertu := to_date('18/12/2012','DD/MM/YYYY');
  vr_tbpa('011_0006').dstelefo := '4732687088';

  -- Coop: 13 - PA: 1
  vr_tbpa('013_0001').cdcooper := 13;
  vr_tbpa('013_0001').cdagenci := 1;
  vr_tbpa('013_0001').dtabertu := to_date('12/08/2008','DD/MM/YYYY');
  vr_tbpa('013_0001').dstelefo := '4736342211';

  -- Coop: 13 - PA: 4
  vr_tbpa('013_0004').cdcooper := 13;
  vr_tbpa('013_0004').cdagenci := 4;
  vr_tbpa('013_0004').dtabertu := to_date('29/07/2013','DD/MM/YYYY');
  vr_tbpa('013_0004').dstelefo := '4736331100';

  -- Coop: 13 - PA: 7
  vr_tbpa('013_0007').cdcooper := 13;
  vr_tbpa('013_0007').cdagenci := 7;
  vr_tbpa('013_0007').dtabertu := to_date('01/12/2014','DD/MM/YYYY');
  vr_tbpa('013_0007').dstelefo := '4235236462';

  -- Coop: 14 - PA: 1
  vr_tbpa('014_0001').cdcooper := 14;
  vr_tbpa('014_0001').cdagenci := 1;
  vr_tbpa('014_0001').dtabertu := to_date('01/08/2017','DD/MM/YYYY');
  vr_tbpa('014_0001').dstelefo := '4635237333';

  -- Coop: 14 - PA: 3
  vr_tbpa('014_0003').cdcooper := 14;
  vr_tbpa('014_0003').cdagenci := 3;
  vr_tbpa('014_0003').dtabertu := to_date('06/05/2013','DD/MM/YYYY');
  vr_tbpa('014_0003').dstelefo := '4635361225';

  -- Coop: 15 - PA: 1
  vr_tbpa('015_0001').cdcooper := 15;
  vr_tbpa('015_0001').cdagenci := 1;
  vr_tbpa('015_0001').dtabertu := to_date('14/04/2012','DD/MM/YYYY');
  vr_tbpa('015_0001').dstelefo := '4235236462';

  -- Coop: 16 - PA: 4
  vr_tbpa('016_0004').cdcooper := 16;
  vr_tbpa('016_0004').cdagenci := 4;
  vr_tbpa('016_0004').dtabertu := to_date('02/01/2013','DD/MM/YYYY');
  vr_tbpa('016_0004').dstelefo := '4733520765';

  -- Coop: 16 - PA: 6
  vr_tbpa('016_0006').cdcooper := 16;
  vr_tbpa('016_0006').cdagenci := 6;
  vr_tbpa('016_0006').dtabertu := to_date('02/01/2013','DD/MM/YYYY');
  vr_tbpa('016_0006').dstelefo := '4735218082';

  -- Coop: 16 - PA: 8
  vr_tbpa('016_0008').cdcooper := 16;
  vr_tbpa('016_0008').cdagenci := 8;
  vr_tbpa('016_0008').dtabertu := to_date('28/10/2013','DD/MM/YYYY');
  vr_tbpa('016_0008').dstelefo := '4735231509';

  -- Coop: 16 - PA: 9
  vr_tbpa('016_0009').cdcooper := 16;
  vr_tbpa('016_0009').cdagenci := 9;
  vr_tbpa('016_0009').dtabertu := to_date('03/12/2013','DD/MM/YYYY');
  vr_tbpa('016_0009').dstelefo := '4733523023';

  -- Coop: 16 - PA: 1
  vr_tbpa('016_0011').cdcooper := 16;
  vr_tbpa('016_0011').cdagenci := 11;
  vr_tbpa('016_0011').dtabertu := to_date('04/11/2014','DD/MM/YYYY');
  vr_tbpa('016_0011').dstelefo := '4735334418';

  -- Coop: 16 - PA: 12
  vr_tbpa('016_0012').cdcooper := 16;
  vr_tbpa('016_0012').cdagenci := 12;
  vr_tbpa('016_0012').dtabertu := to_date('10/08/2015','DD/MM/YYYY');
  vr_tbpa('016_0012').dstelefo := '4735452947';
  
  vr_index := vr_tbpa.first;
  
  WHILE vr_index IS NOT NULL LOOP
    UPDATE crapage
       SET dtabertu = vr_tbpa(vr_index).dtabertu
     WHERE cdcooper = vr_tbpa(vr_index).cdcooper
       AND cdagenci = vr_tbpa(vr_index).cdagenci;
  
    vr_index := vr_tbpa.next(vr_index);
  END LOOP;
  
  COMMIT;
END;