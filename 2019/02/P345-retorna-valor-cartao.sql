
/* Retorna valores originais da proposta do cartao */

/* INC0032885 */

update crawcrd 
   set cdadmcrd = 85
      ,insitcrd = 4
      ,nrcrcard = 84299984
      ,nmtitcrd = 'MARCIA M GAULKE'
      ,vlsalari = 1
      ,vlsalcon = 5000
      ,vloutras = 5000
      ,dddebito = 1
      ,cdlimcrd = 23
      ,dtpropos = to_date('14/01/2014','dd/mm/rrrr')
      ,cdoperad = 'f0030426'      
      ,dtmvtolt = to_date('14/01/2014','dd/mm/rrrr')
      ,cdagenci = 8
      ,cdbccxlt = 200
      ,nrdolote = 3000
      ,nrseqdig = 1
      ,dtsolici = to_date('17/01/2014','dd/mm/rrrr')
      ,dtentreg = to_date('20/01/2014','dd/mm/rrrr')
      ,dtanuida = to_date('20/01/2014','dd/mm/rrrr')
      ,nrdoccrd = '3.393.915'
      ,flgctitg = 2
      ,flgdebcc = 0
      ,tpenvcrd = 0
      ,tpdpagto = 0
      ,vllimcrd = 0
      ,flgprcrd = 0
      ,flgdebit = 0
      ,cdopeori = ' '
      ,cdageori = 0
      ,dsjustif = null
 where cdcooper = 1 and nrdconta = 2160218 and nrctrcrd = 648209;

update crawcrd 
   set cdadmcrd = 16
      ,insitcrd = 4
      ,nrcrcard = 6393500042237371
      ,dddebito = 32
      ,dtpropos = to_date('13/10/2017','dd/mm/rrrr')
      ,cdoperad = 'f0012115'
      ,dtmvtolt = null
      ,dtsolici = to_date('16/10/2017','dd/mm/rrrr')
      ,dtentreg = to_date('27/11/2017','dd/mm/rrrr')
      ,dtvalida = to_date('31/08/2023','dd/mm/rrrr')
      ,dtlibera = to_date('18/10/2017','dd/mm/rrrr')
      ,dtcancel = null
      ,vllimcrd = 0
      ,flgprcrd = 1
      ,cdopeori = 'f0011868'
      ,dsjustif = null
 where cdcooper = 1 and nrdconta = 2160218 and nrctrcrd = 1108035;


/* INC0031712 */

update crawcrd 
   set insitcrd = 6
      ,cdlimcrd = 0
      ,dtcancel = '27/10/2017'
      ,cdmotivo = 4
 where cdcooper = 1 and nrdconta = 6875157 and nrctrcrd = 996885;
 
 
update crawcrd 
   set nrcrcard = 6393500014089396
      ,nmtitcrd = 'JULIANA PORFIRIO SOARES'
      ,cdgraupr = 0
      ,vlsalari = 1450
      ,cdlimcrd = 0
      ,dtpropos = to_date('09/03/2017','dd/mm/rrrr')
      ,cdoperad = null
      ,insitcrd = 4
      ,dtmvtolt = null
      ,dtsolici = null
      ,dtlibera = to_date('10/03/2017','dd/mm/rrrr')
      ,dtentr2v = to_date('09/03/2017','dd/mm/rrrr')
      ,cdadmcrd = 16
      ,flgimpnp = 0
      ,dddebant = 32
      ,nmextttl = 'JULIANA PORFIRIO SOARES'
      ,dtrejeit = null
      ,cdopeori = ' '
      ,cdageori = 0
      ,insitdec = 1
      ,dsprotoc = null
      ,dsjustif = null
      ,dtenefes = null
 where cdcooper = 1 and nrdconta = 6875157 and nrctrcrd = 1021267;


/* INC0031524 */

insert into crawcrd (NRCRCARD, NRDCONTA, NMTITCRD, NRCPFTIT, CDGRAUPR, VLSALARI, VLSALCON, VLOUTRAS, VLALUGUE, DDDEBITO, CDLIMCRD, DTPROPOS, CDOPERAD, INSITCRD, NRCTRCRD, DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRSEQDIG, DTSOLICI, DTENTREG, DTVALIDA, DTANUIDA, VLANUIDA, INANUIDA, QTANUIDA, QTPARCAN, DTLIBERA, DTCANCEL, CDMOTIVO, NRPROTOC, DTENTR2V, TPCARTAO, CDADMCRD, DTNASCCR, NRDOCCRD, DTULTVAL, NRCTAAV1, FLGIMPNP, NMDAVAL1, DSCPFAV1, DSENDAV1##1, DSENDAV1##2, NRCTAAV2, NMDAVAL2, DSCPFAV2, DSENDAV2##1, DSENDAV2##2, DSCFCAV1, DSCFCAV2, NMCJGAV1, NMCJGAV2, DTSOL2VI, VLLIMDLR, CDCOOPER, FLGCTITG, DTECTITG, FLGDEBCC, FLGRMCOR, FLGPROTE, FLGMALAD, NRCCTITG, DT2VIASN, NRREPINC, NRREPENT, NRREPLIM, NRREPVEN, NRREPSEN, NRREPCAR, NRREPCAN, DDDEBANT, NMEXTTTL, PROGRESS_RECID, TPENVCRD, TPDPAGTO, VLLIMCRD, NMEMPCRD, FLGPRCRD, NRSEQCRD, CDORIGEM, FLGDEBIT, DTREJEIT, CDOPEEXC, CDAGEEXC, DTINSEXC, CDOPEORI, CDAGEORI, DTINSORI, DTREFATU, INSITDEC, DTAPROVA, DSPROTOC, DSJUSTIF, CDOPEENT, INUPGRAD, CDOPESUP, DSOBSCMT, DTENVEST, DTENEFES)
values (5474080090707090.00, 34991, 'WALMIR DJALMA GOMES', 486779904.00, 0, 0.00, 0.00, 0.00, 0.00, 3, 72, to_date('26-10-2018', 'dd-mm-yyyy'), null, 4, 94108, to_date('26-10-2018', 'dd-mm-yyyy'), 0, 0, 0, 0, to_date('26-10-2018', 'dd-mm-yyyy'), null, null, null, 0.00, 0, 0, 0, to_date('26-10-2018', 'dd-mm-yyyy'), null, 0, 0.00, null, 2, 15, to_date('26-03-1938', 'dd-mm-yyyy'), '66047          ', null, 0, 0, null, null, null, null, 0, null, null, null, null, null, null, null, null, null, 0.00, 7, 3, null, 0, 0, 0, 0, 7564416008217, null, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 'WALMIR DJALMA GOMES', null, 0, 3, 2500.00, ' ', 1, 24340, 0, 1, null, ' ', 0, null, ' ', 0, null, to_date('26-10-2018', 'dd-mm-yyyy'), 1, null, null, null, null, 0, null, null, null, null);

update crapcrd set nrctrcrd = 94108 where cdcooper = 7 and nrdconta = 34991 and nrcrcard = 5474080090707090;
update crawcrd set insitcrd = 3, flgprcrd = 0 where cdcooper = 7 and nrdconta = 34991 and nrctrcrd = 96789;
update crawcrd set flgprcrd = 0 where cdcooper = 7 and nrdconta = 34991 and nrctrcrd = 79603;

/* INC0031687 */

update crawcrd set insitcrd = 6, dtcancel = '31/08/2018',nrcrcard = 0.00, flgprcrd = 0 where cdcooper = 11 and nrdconta = 454680 and nrctrcrd = 78249;


/* INC0031198 */
update crawcrd 
   set insitcrd = 3
      ,dtlibera = to_date('21/01/2019','dd/mm/rrrr')
 where cdcooper = 9 and nrdconta = 217999 and nrctrcrd = 37771;
 
/* Contato Daiane skype */
update crawcrd set dtcancel = null where cdcooper = 1 and nrdconta = 10205152 and nrctrcrd = 1321538;

commit;
