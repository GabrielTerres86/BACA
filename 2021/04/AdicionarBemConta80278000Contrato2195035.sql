begin
  insert into crapbpr(cdcooper,
                      nrdconta,
                      tpctrpro,
                      nrctrpro,
                      flgalien,
                      dtmvtolt,
                      cdoperad,
                      dsrelbem,
                      persemon,
                      qtprebem,
                      vlrdobem,
                      vlprebem,
                      dscatbem,
                      nranobem,
                      nrmodbem,
                      dscorbem,
                      dschassi,
                      nrdplaca,
                      flgalfid,
                      flgsegur,
                      dtvigseg,
                      flglbseg,
                      tpchassi,
                      ufdplaca,
                      uflicenc,
                      nrrenava,
                      nrcpfbem,
                      vlmerbem,
                      idseqbem,
                      dsbemfin,
                      flgrgcar,
                      vlperbem,
                      cdsitgrv,
                      nrgravam,
                      dtatugrv,
                      flginclu,
                      dtdinclu,
                      dsjstinc,
                      tpinclus,
                      flgalter,
                      dtaltera,
                      tpaltera,
                      flcancel,
                      dtcancel,
                      tpcancel,
                      flgbaixa,
                      dtdbaixa,
                      dsjstbxa,
                      tpdbaixa,
                      nrplnovo,
                      ufplnovo,
                      nrrenovo,
                      flblqjud,
                      dstipbem,
                      dsmarbem,
                      vlfipbem,
                      dstpcomb,
                      dsjuscnc,
                      dsjusjud,
                      qttntinc,
                      qttntbai,
                      qttntcnc,
                      cdufende,
                      dscompend,
                      dsendere,
                      nmbairro,
                      nmcidade,
                      nrcepend,
                      nrendere,
                      dsclassi,
                      vlareuti,
                      vlaretot,
                      nrmatric,
                      dsmarceq,
                      nrnotanf,
                      flgregim,
                      flgregct,
                      flgdonobem,
                      recidobs) 
               select cdcooper,
                      nrdconta,
                      tpctrpro,
                      2195035 nrctrpro,
                      flgalien,
                      dtmvtolt,
                      cdoperad,
                      dsrelbem,
                      persemon,
                      qtprebem,
                      vlrdobem,
                      vlprebem,
                      dscatbem,
                      nranobem,
                      nrmodbem,
                      dscorbem,
                      dschassi,
                      nrdplaca,
                      flgalfid,
                      flgsegur,
                      dtvigseg,
                      flglbseg,
                      tpchassi,
                      ufdplaca,
                      uflicenc,
                      nrrenava,
                      nrcpfbem,
                      vlmerbem,
                      idseqbem,
                      dsbemfin,
                      flgrgcar,
                      vlperbem,
                      0 cdsitgrv,
                      nrgravam,
                      dtatugrv,
                      flginclu,
                      dtdinclu,
                      dsjstinc,
                      tpinclus,
                      flgalter,
                      dtaltera,
                      tpaltera,
                      flcancel,
                      dtcancel,
                      tpcancel,
                      flgbaixa,
                      dtdbaixa,
                      dsjstbxa,
                      tpdbaixa,
                      nrplnovo,
                      ufplnovo,
                      nrrenovo,
                      flblqjud,
                      dstipbem,
                      dsmarbem,
                      vlfipbem,
                      dstpcomb,
                      dsjuscnc,
                      dsjusjud,
                      qttntinc,
                      qttntbai,
                      qttntcnc,
                      cdufende,
                      dscompend,
                      dsendere,
                      nmbairro,
                      nmcidade,
                      nrcepend,
                      nrendere,
                      dsclassi,
                      vlareuti,
                      vlaretot,
                      nrmatric,
                      dsmarceq,
                      nrnotanf,
                      flgregim,
                      flgregct,
                      flgdonobem,
                      recidobs from crapbpr  
                         where cdcooper = 1  
                           and nrdconta = 80278000 
                           and flgalien = 1 
                           and nrctrpro = 1033671;
COMMIT;                           
exception
  when others then 
    null;
end;  
