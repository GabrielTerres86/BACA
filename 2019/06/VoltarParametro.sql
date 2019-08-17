update crapprm p 
   set p.dstexprm = NULL
 where p.nmsistem = 'CRED'
   and p.cdcooper = 0
   and p.cdacesso = 'XSLPROCESSOR';
/
