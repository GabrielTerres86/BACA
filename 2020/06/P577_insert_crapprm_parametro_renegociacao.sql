/*
Ambientes de desenv
-------------------
insert into crapprm ( NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
             values ('CRED', 0, 'TPDOCMTO_ADITIVO_RENEG', 'Tipo de documento de aditivo de renegociação', '229') -- Homologação
/

declare
   cursor CR_CRAPCOP is
      select  CDCOOPER
      from    CRAPCOP;
begin
   for RW_CRAPCOP in CR_CRAPCOP loop
      insert into crapprm ( NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
                   values ('CRED', RW_CRAPCOP.CDCOOPER, 'TPDOCMTO_ADITIVO_RENEG', 'Tipo de documento de aditivo de renegociação', '229'); -- Homologação
   end loop;
end;
/
*/
insert into crapprm ( NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
             values ('CRED', 0, 'TPDOCMTO_ADITIVO_RENEG', 'Tipo de documento de aditivo de renegociação', '226'); -- Produção
/

declare
   cursor CR_CRAPCOP is
      select  CDCOOPER
      from    CRAPCOP;
begin
   for RW_CRAPCOP in CR_CRAPCOP loop
      insert into crapprm ( NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
                   values ('CRED', RW_CRAPCOP.CDCOOPER, 'TPDOCMTO_ADITIVO_RENEG', 'Tipo de documento de aditivo de renegociação', '226'); -- Produção
   end loop;
end;
/

commit
/
