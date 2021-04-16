begin

  update tbcc_lancamentos_pendentes tbcc
     set tbcc.idsituacao = 'M',
         tbcc.dscritica  = 'INC0086649 Sala de crise 15/04, pix afetado em decorrencia da RDM0038933'
   where tbcc.idtransacao in (7626536,7626561,7626572,7626573,7626575,7626578,7626590,7626618,7626625,7626635,7626748,7626750,7626751,7626753,7626754,7626755,7626772,7626775,7626776,7626777,7626779,7626783)
     and tbcc.dtmvtolt >= '15/04/2021'
     and tbcc.idsituacao = 'E';
  
  commit;
end;
