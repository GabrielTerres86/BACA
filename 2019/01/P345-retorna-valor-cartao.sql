
/* Retorna valores originais da proposta do cartao */
/* Backup da proposta realizado */

update crawcrd 
   set cdadmcrd = 17
      ,insitcrd = 4
      ,nrcrcard = 6393500011309268
      ,cdgraupr = 0
      ,vlsalari = 0.01
      ,dddebito = 32
      ,dtpropos = to_date('22/01/2016','dd/mm/rrrr')
      ,cdoperad = '2853'
      ,dtmvtolt = to_date('22/01/2016','dd/mm/rrrr')
      ,dtsolici = to_date('22/01/2016','dd/mm/rrrr')
      ,dtentreg = to_date('07/03/2016','dd/mm/rrrr')
      ,dtvalida = to_date('31/10/2019','dd/mm/rrrr')
      ,dtlibera = to_date('25/01/2016','dd/mm/rrrr')
      ,flgimpnp = 0
      ,nrrepinc = 0
      ,nmextttl = 'TELMO OTAVIO ROSA'
      ,tpenvcrd = 0
      ,vllimcrd = 0
      ,flgprcrd = 1
      ,dsprotoc = null
      ,dsjustif = null
      ,dtenvest = null
 where cdcooper = 1 and nrdconta = 2464322 and nrctrcrd = 857143;

commit;
