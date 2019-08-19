/* 
Solicitação: INC0014909
Objetivo   : Manter apenas e-mails válidos na tabela de parâmetros crapprm
             para o progress_recid 27
Autor      : Jackson
*/

update crapprm
   set dsvlrprm = 'fernanda.eccher@ailos.coop.br;marcelo.silva@ailos.coop.br;elisangela.junges@ailos.coop.br'
 where progress_recid = 27;

COMMIT;

