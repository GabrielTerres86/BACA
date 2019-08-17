begin

  update crawcrd wcrd
  set wcrd.dddebito = 22
     ,wcrd.flgimpnp = 1
     ,wcrd.flgdebcc = 1
     ,wcrd.tpenvcrd = 1
     ,wcrd.tpdpagto = 1
     ,wcrd.vllimcrd = 5000
     ,wcrd.nmempcrd = 'FOLHATEC '
     ,wcrd.cdageori = 21
  where wcrd.cdcooper = 1
    and wcrd.nrdconta = 9799222
    and wcrd.nrctrcrd = 1301030
    and wcrd.nrcrcard = 5474080096742927;

  update crapcrd crd
  set crd.dddebito = 22
  where crd.cdcooper = 1
    and crd.nrdconta = 9799222
    and crd.nrctrcrd = 1301030
    and crd.nrcrcard = 5474080096742927;

  commit;

end;
