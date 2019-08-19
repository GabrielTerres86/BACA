UPDATE crapcrb x
   SET x.dtcancel = null, x.cdopecan = null, x.dsmotcan = null
 where x.idtpreme = 'SERASA'
   and x.dtmvtolt = '23/05/2019';

COMMIT;
