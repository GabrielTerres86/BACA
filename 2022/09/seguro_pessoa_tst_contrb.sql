begin
  update crawseg w
     set w.tpcustei = 1
   where w.cdcooper = 14
     and w.nrdconta = 99669234
     and w.nrctrato = 74521;

  update crapprm p
     set p.dsvlrprm = '22/09/2022'
   where p.cdcooper = 14
     and p.cdacesso = 'DIA_ATIVA_CONTRB_SEGPRE';
  commit;
end;
/
