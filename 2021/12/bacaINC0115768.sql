begin

insert into cecred.crapprm(
       nmsistem,
       cdcooper,
       cdacesso,
       dstexprm,
       dsvlrprm
)values(
'CRED',
0,
'ALERT_TEAMS_TESOURARIA',
'Email para alertas ao recepcionar mensagens da Cabine JD',
'tesouraria@ailos.coop.br;5a51dc2f.ailos.onmicrosoft.com@amer.teams.ms');


insert into cecred.crapprm(
       nmsistem,
       cdcooper,
       cdacesso,
       dstexprm,
       dsvlrprm
)values(
'CRED',
0,
'ALERT_TEAMS_NUMERARIO',
'Email para alertas da provisao e recepcao de mensagens da Cabine JD',
'carroforte@ailos.coop.br;fd33e61b.ailos.onmicrosoft.com@amer.teams.ms');

commit;

END;