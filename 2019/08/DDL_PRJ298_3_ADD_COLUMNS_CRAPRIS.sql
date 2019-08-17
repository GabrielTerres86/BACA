ALTER TABLE cecred.crapris
  ADD (vlmrapar60 NUMBER(25,2)
      ,vljuremu60 NUMBER(25,2)
      ,vljurcor60 NUMBER(25,2));

comment on column CECRED.CRAPRIS.vlmrapar60
  is 'Valor dos juros mora das parcelas em atraso a mais de 60 dias';

comment on column CECRED.CRAPRIS.vljuremu60
  is 'Valor dos juros remuneracao das parcelas em atraso a mais de 60 dias';

comment on column CECRED.CRAPRIS.vljurcor60
  is 'Valor dos juros correcao das parcelas em atraso a mais de 60 dias';
