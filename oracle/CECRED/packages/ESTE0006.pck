create or replace package cecred.ESTE0006 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : ESTE0006
      Sistema  : Rotinas referentes a comunica�ao com a ESTEIRA de CREDITO da IBRATAN para Border� de T�tulos
      Sigla    : CADA
      Autor    : Andrew Albuquerque (GFT)
      Data     : Abril/2018.                   Ultima atualizacao: 21/08/2018

      Dados referentes ao programa:
      Frequencia: Sempre que solicitado
      Objetivo  : Rotinas referentes a comunica�ao com a ESTEIRA de CREDITO da IBRATAN

      Alteracoes: 21/08/2018 - Altera��es de formato de data na pc_enviar_analise_manual. (Andrew Albuquerque - GFT)
                  24/08/2018 - Altera��o na pc_enviar_analise_manual, pois a mensagem de retorno da IBRATAN referente 
                               a bordero j� existente na esteira foi alterada, causando erro no envio de altera��o
                               de bordero/proposta (Andrew Albuquerque - GFT)
  ---------------------------------------------------------------------------------------------------------------*/

--> Tratamento de erro
vr_des_erro varchar2(4000);
vr_exc_erro exception;

--> Descri�ao e c�digo da critica
vr_cdcritic crapcri.cdcritic%type;
vr_dscritic varchar2(4000);


--> Rotina responsavel por verificar o stado de contingencia na esteira
PROCEDURE pc_verifica_contigenc_esteira(pr_cdcooper in crapcop.cdcooper%type       --> Codigo da cooperativa
                                       ,pr_flctgest out boolean                    --> Flag que indica o status de contigencia do motor.
                                       ,pr_dsmensag out varchar2                   --> Mensagem
                                       ,pr_dscritic out varchar2                   --> Descricao da critica
                                       );

--> Rotina responsavel por enviar o border� para a esteira
PROCEDURE pc_enviar_bordero_esteira(pr_cdcooper in  crapbdt.cdcooper%type             --> Codigo da cooperativa
                                   ,pr_cdagenci in  crapbdt.cdagenci%type             --> Codigo da agencia
                                   ,pr_cdoperad in  crapbdt.cdoperad%type             --> codigo do operador
                                   ,pr_idorigem in  integer                           --> Origem da operacao
                                   ,pr_tpenvest in  varchar2                          --> Tipo do envio esteira
                                   ,pr_nrborder in  crapbdt.nrborder%TYPE             --> N�mero do Border�
                                   ,pr_nrdconta in  crapbdt.nrdconta%type             --> Conta do associado
                                   ,pr_dtmovito in  varchar2                          --> Data do movimento atual
                                   ,pr_dsmensag out varchar2                          --> Mensagem
                                   ,pr_cdcritic out pls_integer                       --> Codigo da critica
                                   ,pr_dscritic out varchar2                          --> Descricao da critica
                                   ,pr_des_erro out varchar2                          --> Erros do processo OK ou NOK
                                   );

--> Rotina responsavel por executa a analise auto m�tica da esteira
procedure pc_obrigacao_analise_autom(pr_cdcooper in crapcop.cdcooper%type  --> C�d. cooperativa
                                    ,pr_inobriga out varchar2              --> Indicador de obriga�ao de an�lisa autom�tica ('S' - Sim / 'N' - Nao)
                                    ,pr_cdcritic out pls_integer           --> C�d. da cr�tica
                                    ,pr_dscritic out varchar2              --> Desc. da cr�tica
                                    );

procedure pc_verifica_regras(pr_cdcooper  in crapbdt.cdcooper%type  --> Codigo da cooperativa
                            ,pr_nrdconta  in crapbdt.nrdconta%type  --> Numero da conta do cooperado
                            ,pr_nrborder in  crapbdt.nrborder%TYPE  --> N�mero do Border�
                            ,pr_tpenvest  in varchar2 default null  --> Tipo de envio
                            ,pr_cdcritic out number                 --> Codigo da critica
                            ,pr_dscritic out varchar2               --> Descricao da critica
                            );

--> Rotina responsavel por incluir o border� na esteira
procedure pc_incluir_bordero_esteira(pr_cdcooper  in crapbdt.cdcooper%type     --> Codigo da cooperativa
                                    ,pr_cdagenci  in crapbdt.cdagenci%type     --> Codigo da cooperativa
                                    ,pr_cdoperad  in crapbdt.cdoperad%TYPE     --> codigo do operador
                                    ,pr_cdorigem  in integer                   --> Origem da operacao
                                    ,pr_nrdconta  in crapbdt.nrdconta%type     --> Numero da conta do cooperado
                                    ,pr_nrborder  IN crapbdt.nrborder%TYPE     --> N�mero do Border�
                                    ,pr_dtmvtolt  in crapdat.dtmvtolt%TYPE     --> Data do movimento
                                    ,pr_nmarquiv  in varchar2                  --> Nome DO arquivo
                                    ,pr_dsmensag out varchar2                  --> Descri�ao da mensagem
                                    ,pr_cdcritic out number                    --> Codigo da cr�tica
                                    ,pr_dscritic out varchar2                  --> Descri�ao da cr�tica
                                    );

--> Rotina responsavel por enviar border� para a esteira
PROCEDURE pc_enviar_analise_bordero(pr_cdcooper    IN crapbdt.cdcooper%type  --> Codigo da cooperativa
                                   ,pr_cdagenci    IN crapage.cdagenci%type  --> Codigo da agencia
                                   ,pr_cdoperad    IN crapope.cdoperad%type  --> codigo do operador
                                   ,pr_cdorigem    IN integer                --> Origem da operacao
                                   ,pr_nrdconta    IN crapbdt.nrdconta%type  --> Numero da conta do cooperado
                                   ,pr_nrborder    IN crapbdt.nrborder%type  --> Numero do border�
                                   ,pr_dtmvtolt    IN crapdat.dtmvtolt%type  --> Data do movimento
                                   ,pr_comprecu    IN varchar2               --> Complemento do recuros da URI
                                   ,pr_dsmetodo    IN varchar2               --> Descricao do metodo
                                   ,pr_conteudo    IN clob                   --> Conteudo no Json para comunicacao
                                   ,pr_dsoperacao  IN varchar2               --> Operacao realizada
                                   ,pr_tpenvest    IN VARCHAR2 DEFAULT null  --> Tipo de envio, I-Inclusao C - Consultar(Get)
                                   ,pr_dsprotocolo OUT varchar2              --> Protocolo retornado na requisi�ao
                                   ,pr_dscritic    OUT VARCHAR2
                                   );

--> Rotina responsavel por enviar o border� para a analise manual.
procedure pc_enviar_analise_manual(pr_cdcooper    in crapbdt.cdcooper%type  --> Codigo da cooperativa
                                  ,pr_cdagenci    in crapage.cdagenci%type  --> Codigo da agencia
                                  ,pr_cdoperad    in crapope.cdoperad%type  --> codigo do operador
                                  ,pr_cdorigem    in integer                --> Origem da operacao
                                  ,pr_nrdconta    in crapbdt.nrdconta%type  --> Numero da conta do cooperado
                                  ,pr_nrborder    in crapbdt.nrborder%type  --> Numero do Border� de Desconto de T�tulo
                                  ,pr_dtmvtolt  IN crapbdt.dtmvtolt%TYPE
                                  ,pr_nmarquiv  in varchar2                 --> Diretorio e nome do arquivo pdf do border�
                                  ,vr_flgdebug  IN VARCHAR2                 --> Flag se debug ativo
                                  ,pr_dsmensag OUT VARCHAR2
                                  ,pr_cdcritic OUT NUMBER                --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                  ,pr_des_erro out varchar2              --> Erros do processo OK ou NOK
                                  );

  PROCEDURE pc_gera_json_bordero(pr_cdcooper in crapbdt.cdcooper%type
                                ,pr_cdagenci in crapage.cdagenci%type
                                ,pr_cdoperad in crapope.cdoperad%type
                                ,pr_nrdconta in crapbdt.nrdconta%type
                                ,pr_nrborder in crapbdt.nrborder%type
                                ,pr_nmarquiv in varchar2               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                ---- OUT ----
                                ,pr_bordero_envio out json                   --> Retorno do clob em modelo json da proposta de emprestimo
--                                ,pr_bordero_clob out CLOB -- ANDREW: APENAS PARA TESTES
                                ,pr_cdcritic out number                 --> Codigo da critica
                                ,pr_dscritic out varchar2               --> Descricao da critica
                              );
end ESTE0006;
/
create or replace package body cecred.ESTE0006 is

vr_dsmensag varchar2(1000);
vr_flctgest boolean;

PROCEDURE pc_verifica_contigenc_esteira(pr_cdcooper in crapcop.cdcooper%type    --> Codigo da cooperativa
                                       ,pr_flctgest out boolean                 --> flag de contingencia da esteira
                                       ,pr_dsmensag out varchar2                --> Descri�ao da Mensagen
                                       ,pr_dscritic out varchar2                --> Descri�ao da Cr�tica
                                       ) is
   vr_contige_este VARCHAR2(500);
   vr_exc_erro EXCEPTION;
   vr_dscritic VARCHAR2(4000);

BEGIN
   pr_flctgest := false;

   vr_contige_este := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'                           --> Nome DO sistema
                                               ,pr_cdcooper => pr_cdcooper                      --> Codigo da cooperativa
                                               ,pr_cdacesso => 'CONTIGENCIA_ESTEIRA_DESC');     --> C�digo de acesso.
   if  vr_contige_este is null then
       vr_dscritic := 'Parametro CONTIGENCIA_ESTEIRA_DESC n�o encontrado.';
       raise vr_exc_erro;
   end if;

   if  vr_contige_este = '1' then
       pr_flctgest := true;
       pr_dsmensag := 'Aten�ao! O Envio para Esteira est� em Conting�ncia';
   end if;

EXCEPTION
   when vr_exc_erro then
        pr_dscritic := vr_dscritic;

   when others then
        pr_dscritic := 'Nao foi poss�vel buscar parametros da esteira: '||sqlerrm;
END;

PROCEDURE pc_enviar_bordero_esteira(pr_cdcooper in  crapbdt.cdcooper%type             --> Codigo da cooperativa
                                   ,pr_cdagenci in  crapbdt.cdagenci%type             --> Codigo da agencia
                                   ,pr_cdoperad in  crapbdt.cdoperad%type             --> codigo do operador
                                   ,pr_idorigem in  integer                           --> Origem da operacao
                                   ,pr_tpenvest in  varchar2                          --> Tipo do envio esteira
                                   ,pr_nrborder in  crapbdt.nrborder%TYPE
                                   ,pr_nrdconta in  crapbdt.nrdconta%type             --> Conta do associado
                                   ,pr_dtmovito in  varchar2                          --> Data do movimento atual
                                   ,pr_dsmensag out varchar2                          --> Mensagem
                                   ,pr_cdcritic out pls_integer                       --> Codigo da critica
                                   ,pr_dscritic out varchar2                          --> Descricao da critica
                                   ,pr_des_erro out varchar2                          --> Erros do processo OK ou NOK
                                   ) is

  vr_dtmvtolt DATE;

  vr_cdagenci crapage.cdagenci%type; --> Codigo da agencia
  vr_inobriga varchar2(1);
  vr_tpenvest varchar2(1);

  --> Vari�vel de cr�ticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);

  --> Tratamento de erros
  vr_exc_saida EXCEPTION;

  --> Busca do nome do associado
  cursor cr_crapass is
  select ass.nmprimtl
        ,ass.inpessoa
        ,ass.cdagenci
  from   crapass ass
  where  ass.cdcooper = pr_cdcooper
  and    ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%rowtype;

  -->busca do border� de t�tulos
  CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%TYPE
                    ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                    ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
    SELECT bdt.rowid
          ,bdt.*
      FROM crapbdt bdt
     WHERE bdt.cdcooper = pr_cdcooper
       AND bdt.nrdconta = pr_nrdconta
       AND bdt.nrborder = pr_nrborder;
  rw_crapbdt cr_crapbdt%ROWTYPE;

BEGIN
   pr_des_erro := 'OK';
   vr_tpenvest := pr_tpenvest;
   vr_dtmvtolt := TO_DATE(pr_dtmovito, 'DD/MM/YYYY');

   pc_verifica_contigenc_esteira(pr_cdcooper => pr_cdcooper   --> Codigo da Cooperativa
                                ,pr_flctgest => vr_flctgest   --> Flag de contingencia flag de
                                ,pr_dsmensag => pr_dsmensag   --> Flag descri�ao da mensagem
                                ,pr_dscritic => pr_dscritic); --> Descri�ao da Cr�tica

   if  vr_flctgest then
       pr_cdcritic := 0;
       pr_dscritic := '';
       pr_dsmensag := 'A esteira est� em conting�ncia.';
       return;
   end if;

   open  cr_crapass;
   fetch cr_crapass into rw_crapass;
   if    cr_crapass%notfound then
         close cr_crapass;
         vr_dscritic := 'Associado n�o cadastrado. Conta: ' || pr_nrdconta;
         raise vr_exc_saida;
   end   if;
   close cr_crapass;

   vr_cdagenci := nvl(nullif(pr_cdagenci, 0), rw_crapass.cdagenci);

   -- abrindo o cursor de Border�
   OPEN cr_crapbdt(pr_cdcooper => pr_cdcooper
                  ,pr_nrdconta => pr_nrdconta
                  ,pr_nrborder => pr_nrborder);
   FETCH cr_crapbdt into rw_crapbdt;
   IF cr_crapbdt%NOTFOUND THEN
     CLOSE cr_crapbdt;
         vr_dscritic := 'Associado n�o possui Border� de T�tulos. Conta: ' || pr_nrdconta || '.Border�: ' || pr_nrborder;
         RAISE vr_exc_saida;
   END IF;
   CLOSE cr_crapbdt;

   if  vr_tpenvest = 'I' then
       vr_inobriga := 'N';

       --> Verificar se o border� devera passar por analise automatica
       pc_obrigacao_analise_autom(pr_cdcooper => pr_cdcooper    --> Codigo da Cooperativa
                                 ,pr_inobriga => vr_inobriga    --> �ndice de Obriga�ao
                                 ,pr_cdcritic => vr_cdcritic    --> Codigo da Critica
                                 ,pr_dscritic => vr_dscritic);  --> Descri�ao da Critica

       --> Se: 1 - Ja houve envio para a Esteira (Pelo Status)
       -->     2 - n�o precisar passar por Analise Automatica

       if rw_crapbdt.insitapr = 6 and vr_inobriga <> 'S' THEN
           --> Significa que o border� jah foi para a Esteira, entao devemos mandar um reinicio de Fluxo
           vr_tpenvest := 'A';
       end if;
   end if;

   /***** Verificar se a Esteira esta em contigencia *****/
   pc_verifica_regras(pr_cdcooper => pr_cdcooper          --> Codigo da Cooperativa
                     ,pr_nrdconta => rw_crapbdt.nrdconta  --> Numero da conta
                     ,pr_nrborder => pr_nrborder          --> Numero de crontrole de bordero
                     ,pr_tpenvest => vr_tpenvest          --> Tipo de Envio para a Esteira
                     ,pr_cdcritic => vr_cdcritic          --> C�digo da cr�tica
                     ,pr_dscritic => vr_dscritic);        --> descri�ao da cr�tica

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;

   /***** INCLUIR O BORDER� NA ESTEIRA *****/
   pc_incluir_bordero_esteira(pr_cdcooper => pr_cdcooper         --> Codigo da Cooperativa
                          ,pr_cdagenci => vr_cdagenci         --> Numero da agencia
                          ,pr_cdoperad => pr_cdoperad         --> C�digo DO Operador
                          ,pr_cdorigem => pr_idorigem         --> C�digo da Origem
                          ,pr_nrdconta => pr_nrdconta         --> Numero da conta
                          ,pr_nrborder => pr_nrborder         --> N�mero do Border�
                          ,pr_dtmvtolt => vr_dtmvtolt         --> Data DO Movimento
                          ,pr_nmarquiv => null                --> Nome DO arquivo
                          ,pr_dsmensag => pr_dsmensag         --> Descriao da Mensagem
                          ,pr_cdcritic => vr_cdcritic         --> C�digo da Critica
                          ,pr_dscritic => vr_dscritic);       --> Descri�ao da cr�tica

   if  vr_cdcritic > 0  or vr_dscritic is not null then
     raise vr_exc_saida;
   end if;

   COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
       --> Se possui c�digo de cr�tica e n�o foi informado a descri�ao
       IF  vr_cdcritic <> 0 and TRIM(vr_dscritic) IS NULL THEN
           --> Busca descri�ao da cr�tica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;

       --> Atribui exce�ao para os parametros de cr�tica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_des_erro := 'NOK';

       ROLLBACK;

  WHEN OTHERS THEN
       --> Atribui exce�ao para os parametros de cr�tica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro n�o tratado na este0006.pc_enviar_bordero_esteira: ' || SQLERRM;
       pr_des_erro := 'NOK';

       ROLLBACK;
END pc_enviar_bordero_esteira;


PROCEDURE pc_obrigacao_analise_autom(pr_cdcooper in crapcop.cdcooper%type  --> C�d. cooperativa
                                    ---- OUT ----
                                    ,pr_inobriga out varchar2              --> Indicador de obriga�ao de an�lisa autom�tica ('S' - Sim / 'N' - Nao)
                                    ,pr_cdcritic out pls_integer           --> C�d. da cr�tica
                                    ,pr_dscritic out varchar2) is          --> Desc. da cr�tica
vr_dsmensag varchar2(1000);
begin

   pc_verifica_contigenc_esteira(pr_cdcooper => pr_cdcooper        --> Codigo da cooperativa
                                ,pr_flctgest => vr_flctgest        --> Flag que indica o status de contigencia da esteira.
                                ,pr_dsmensag => vr_dsmensag        --> Mensagem
                                ,pr_dscritic => pr_dscritic);      --> Descricao da critica

   --> OU Esteira est� em contingencia
   --> OU a Cooperativa n�o Obriga An�lise Autom�tica
   if  vr_flctgest then
       pr_inobriga := 'N';
   else
       pr_inobriga := 'S';
   end if;

exception
   when others then
        pr_cdcritic := 0;
        pr_dscritic := 'Erro inesperado na rotina que verifica o tipo de an�lise do border�: '||sqlerrm;
end pc_obrigacao_analise_autom;

procedure pc_verifica_regras(pr_cdcooper  in crapbdt.cdcooper%type  --> Codigo da cooperativa
                            ,pr_nrdconta  in crapbdt.nrdconta%type  --> Numero da conta do cooperado
                            ,pr_nrborder in  crapbdt.nrborder%TYPE  --> N�mero do Border�
                            ,pr_tpenvest  in varchar2 default null  --> Tipo de envio
                            ,pr_cdcritic out number                 --> Codigo da critica
                            ,pr_dscritic out varchar2               --> Descricao da critica
                            ) IS
/* ..........................................................................

    Programa : pc_verifica_regras_esteira
    Sistema  :
    Sigla    : CRED
    Autor    : Paulo Penteado GFT
    Data     : Fevereiro/2018.                   Ultima atualizacao: 16/02/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento para verificar as regras da esteira

    Altera�ao :

  ..........................................................................*/
    -----------> CURSORES <-----------
    --> buscar os dados do Border� de Desconto de T�tulos
    CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%TYPE
                      ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                      ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
    SELECT bdt.insitbdt
          ,bdt.insitapr
          ,bdt.cdopeapr
      FROM crapbdt bdt
     WHERE bdt.cdcooper = pr_cdcooper
       AND bdt.nrdconta = pr_nrdconta
       AND bdt.nrborder = pr_nrborder;
    rw_crapbdt cr_crapbdt%ROWTYPE;


    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;

  BEGIN
    --> Para inclusao, e altera�ao
    IF nvl(pr_tpenvest,' ') IN ('I','A') THEN

      --> Buscar dados do Border�
      OPEN cr_crapbdt(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrborder => pr_nrborder);
      FETCH cr_crapbdt into rw_crapbdt;
      IF cr_crapbdt%NOTFOUND THEN
            CLOSE cr_crapbdt;
            vr_cdcritic := 1166; --> 1166 - Bordero nao encontrado.
            RAISE vr_exc_erro;
      END IF;

      --> Somente permitir� se ainda n�o analisada e ainda n�o enviada
      IF (rw_crapbdt.insitbdt = 1 AND rw_crapbdt.insitapr = 0) THEN -- insitbdt 1-Em Estudo / insitapr 0-Aguardando An�lise
        --> Sair pois pode ser enviada
        RETURN;
      END IF;
      --> n�o ser� poss�vel enviar/reenviar para a Esteira
      vr_dscritic := 'O Border� n�o pode ser enviado para An�lise de cr�dito, verifique a situa��o do Border�!';
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND
        TRIM(vr_dscritic) IS NULL THEN
        --> Busca descricao
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi poss�vel  verificar regras da An�lise de Cr�dito: '||SQLERRM;
END pc_verifica_regras;

procedure pc_incluir_bordero_esteira(pr_cdcooper  in crapbdt.cdcooper%type     --> Codigo da cooperativa
                                    ,pr_cdagenci  in crapbdt.cdagenci%type     --> Codigo da cooperativa
                                    ,pr_cdoperad  in crapbdt.cdoperad%TYPE     --> codigo do operador
                                    ,pr_cdorigem  in integer                   --> Origem da operacao
                                    ,pr_nrdconta  in crapbdt.nrdconta%type     --> Numero da conta do cooperado
                                    ,pr_nrborder  IN crapbdt.nrborder%TYPE     --> N�mero do Border�
                                    ,pr_dtmvtolt  in crapdat.dtmvtolt%TYPE     --> Data do movimento
                                    ,pr_nmarquiv  in varchar2                  --> Nome DO arquivo
                                    ,pr_dsmensag out varchar2                  --> Descri�ao da mensagem
                                    ,pr_cdcritic out number                    --> Codigo da cr�tica
                                    ,pr_dscritic out varchar2) IS              --> Descri�ao da cr�tica
  /* ...........................................................................

    Programa : pc_incluir_bordero_esteira
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrew Albuquerque - GFT-Brasil
    Data     : Abril/2018.          Ultima atualizacao: 20/04/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina responsavel por gerar a inclusao do Border� para a esteira de cr�dito.
    Altera�ao :

  ..........................................................................*/

  ----------- VARIAVEIS <-----------
  --> Tratamento de erros
  vr_cdcritic NUMBER := 0;
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;

  --> Buscar informa��es do Border�
  CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%TYPE
                    ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                    ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
  SELECT bdt.rowid
        ,bdt.nrborder
        ,bdt.cdcooper
        ,bdt.nrdconta
        ,bdt.nrdolote
        ,bdt.insitbdt
        ,bdt.nrctrlim
        ,bdt.insitapr
        ,ass.cdagenci
        ,ass.inpessoa
    FROM crapbdt bdt
   INNER JOIN crapass ass
      ON ass.cdcooper = bdt.cdcooper
     AND ass.nrdconta = bdt.nrdconta
   WHERE bdt.cdcooper = pr_cdcooper
     AND bdt.nrdconta = pr_nrdconta
     AND bdt.nrborder = pr_nrborder;
  rw_crapbdt cr_crapbdt%ROWTYPE;

  --> Variaveis para DEBUG
  vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
  vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;

BEGIN

  --> Se o DEBUG estiver habilitado
  IF vr_flgdebug = 'S' THEN
    --> Gravar dados log acionamento
    ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,                    --> Codigo da cooperativa
                                  pr_cdagenci              => pr_cdagenci,                    --> Codigo da agencia
                                  pr_cdoperad              => pr_cdoperad,                    --> Codigo do operador
                                  pr_cdorigem              => pr_cdorigem,                    --> Origem da operacao
                                  pr_nrctrprp              => pr_nrborder,                    --> N�mero do Border� de Desconto de T�tulo
                                  pr_nrdconta              => pr_nrdconta,                    --> Numero da Conta
                                  pr_tpacionamento         => 0,  /* 0 - DEBUG */             --> Tipo de Acionamento
                                  pr_dsoperacao            => 'INICIO INCLUIR BORDERO',      --> Descri�ao da Opera�ao
                                  pr_dsuriservico          => NULL,                           --> Descri�ao DO Servi�o
                                  pr_dtmvtolt              => pr_dtmvtolt,                    --> Data DO Movimento
                                  pr_cdstatus_http         => 0,                              --> C�digo de STATUS
                                  pr_dsconteudo_requisicao => null,                           --> Descri�ao DO conteudo da requisi�ao
                                  pr_dsresposta_requisicao => null,                           --> Descri�ao da Resposta da requisi�ao
                                  pr_tpproduto             => 7, --> Desconto de T�tulo � Border�      --> Tipo DO Produto
                                  pr_idacionamento         => vr_idaciona,                    --> Identificadordo acionamento
                                  pr_dscritic              => vr_dscritic);                   --> Descri�ao da critica

    --> Sem tratamento de exce�ao para DEBUG
    --IF TRIM(vr_dscritic) IS NOT NULL THEN
    -->  RAISE vr_exc_erro;
    --END IF;
  END IF;

  --> Buscando as Informa��es de Bol�to de Desconto de T�tulo.
  OPEN cr_crapbdt (pr_cdcooper => pr_cdcooper
                  ,pr_nrdconta => pr_nrdconta
                  ,pr_nrborder => pr_nrborder);
  FETCH cr_crapbdt INTO rw_crapbdt;
  CLOSE cr_crapbdt;

  pc_enviar_analise_manual(pr_cdcooper => pr_cdcooper      --> Codigo da cooperativa
                          ,pr_cdagenci => pr_cdagenci      --> Codigo da agencia
                          ,pr_cdoperad => pr_cdoperad      --> codigo do operador
                          ,pr_cdorigem => pr_cdorigem      --> Origem da operacao
                          ,pr_nrdconta => pr_nrdconta      --> Numero da conta do cooperado
                          ,pr_nrborder => pr_nrborder      --> Numero do Border� de Desconto de T�tulos
                          ,pr_dtmvtolt => pr_dtmvtolt      --> Data do movimento
                          ,pr_nmarquiv => pr_nmarquiv      --> Indica se deve reiniciar o fluxo de aprovacao na esteira
                          ,vr_flgdebug => vr_flgdebug      --> Diretorio e nome do arquivo pdf do Border� de Desconto de T�tulo
                          ,pr_dsmensag => pr_dsmensag
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic      --> Descricao da critica
                          ,pr_des_erro => vr_des_erro);    -- Descri�a� do ee

  IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN

    --> Buscar critica
    IF nvl(vr_cdcritic,0) > 0 AND
      TRIM(vr_dscritic) IS NULL THEN
      --> Busca descricao
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;

    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;

  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'N�o foi poss�vel realizar a inclus�o do Border� de Desconto de T�tulos: '||SQLERRM;
END pc_incluir_bordero_esteira;

  --> Rotina responsavel por gerar a alteracao do Border� para a esteira
  procedure pc_alterar_bordero(pr_cdcooper  in crapbdt.cdcooper%type  --> Codigo da cooperativa
                               ,pr_cdagenci  in crapage.cdagenci%type  --> Codigo da agencia
                               ,pr_cdoperad  in crapope.cdoperad%type  --> codigo do operador
                               ,pr_cdorigem  in integer                --> Origem da operacao
                               ,pr_nrdconta  in crapbdt.nrdconta%type  --> Numero da conta do cooperado
                               ,pr_nrborder  in crapbdt.nrborder%type  --> Numero do Border� de Desconto de T�tulos
                               ,pr_dtmvtolt  in crapdat.dtmvtolt%type  --> Data do movimento
                               ,pr_flreiflx  in integer                --> Indica se deve reiniciar o fluxo de aprovacao na esteira
                               ,pr_nmarquiv  in varchar2               --> Diretorio e nome do arquivo pdf do Border� de Desconto de t�tulo
                               ,pr_cdcritic out number                 --> Codigo da critica
                               ,pr_dscritic out varchar2               --> Descricao da critica
                               ) is
    /* ..........................................................................

      Programa : pc_alterar_bordero
      Sistema  :
      Sigla    : CRED
      Autor    : Paulo Penteado (GFT)
      Data     : Fevereiro/2018.                   Ultima atualizacao: 17/02/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a alteracao do border� para a esteira
      Altera�ao :

    ..........................................................................*/
    -----------> CURSORES <-----------

    --> Buscar operador
    CURSOR cr_crapope (pr_cdcooper  crapope.cdcooper%TYPE,
                       pr_cdoperad  crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND upper(ope.cdoperad) = upper(pr_cdoperad);

    rw_crapope cr_crapope%ROWTYPE;

    -----------> VARIAVEIS <-----------
    --> Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_dsmensag VARCHAR2(4000);
    vr_exc_erro EXCEPTION;

    --> Objeto json da bordero
    vr_obj_alter    json := json();
    vr_obj_bordero json := json();
    vr_obj_agencia  json := json();
    vr_dsprotocolo  VARCHAR2(1000);
    vr_obj_bordero_clob clob;

    --> Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;

    --> Hora de Envio
    vr_hrenvest crawlim.hrenvest%TYPE;
  BEGIN

    --> Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                                    pr_cdagenci              => pr_cdagenci,
                                    pr_cdoperad              => pr_cdoperad,
                                    pr_cdorigem              => pr_cdorigem,
                                    pr_nrctrprp              => pr_nrborder,
                                    pr_nrdconta              => pr_nrdconta,
                                    pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                    pr_dsoperacao            => 'INICIO ALTERAR BORDERO',
                                    pr_dsuriservico          => NULL,
                                    pr_dtmvtolt              => pr_dtmvtolt,
                                    pr_cdstatus_http         => 0,
                                    pr_dsconteudo_requisicao => null,
                                    pr_dsresposta_requisicao => null,
                                    pr_tpproduto             => 7, --> Desconto de T�tulo � Border�      --> Tipo DO Produto
                                    pr_idacionamento         => vr_idaciona,
                                    pr_dscritic              => vr_dscritic);
      --> Sem tratamento de exce�ao para DEBUG
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      -->  RAISE vr_exc_erro;
      --END IF;
    END IF;

    --> Gerar informa�oes no padrao JSON do border� de desconto de t�tulos

             pc_gera_json_bordero(pr_cdcooper  => pr_cdcooper
                                 ,pr_cdagenci  => pr_cdagenci
                                 ,pr_cdoperad  => pr_cdoperad
                                 ,pr_nrdconta  => pr_nrdconta
                                 ,pr_nrborder  => pr_nrborder
                                 ,pr_nmarquiv  => pr_nmarquiv  --> Diretorio e nome do arquivo pdf do border� de desconto de t�tulos
                                 ,pr_bordero_envio  => vr_obj_bordero
-- apenas para teste                                 ,pr_bordero  => vr_obj_bordero  --> Retorno do clob em modelo json do bordero de desconto de t�tulos
                                 ,pr_cdcritic  => vr_cdcritic
                                 ,pr_dscritic  => vr_dscritic);
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --> Buscar dados do operador
    OPEN cr_crapope (pr_cdcooper  => pr_cdcooper,
                     pr_cdoperad  => pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67; --> 067 - Operador nao cadastrado.
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapope;
    END IF;

    --> Incluir objeto bordero
    vr_obj_alter.put('dadosAtualizados'      ,vr_obj_bordero);
    vr_obj_alter.put('operadorAlteracaoLogin',lower(pr_cdoperad));
    vr_obj_alter.put('operadorAlteracaoNome' ,rw_crapope.nmoperad) ;
    vr_obj_alter.put('dataHora'              ,este0001.fn_DataTempo_ibra(SYSDATE)) ;
    vr_obj_alter.put('reiniciaFluxo'         ,(pr_flreiflx = 1) ) ;

    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo'   , pr_cdcooper);
    vr_obj_agencia.put('PACodigo'            , pr_cdagenci);
    vr_obj_alter.put('operadorAlteracaoPA'      , vr_obj_agencia);

    --> Criar o CLOB para converter JSON para CLOB
    dbms_lob.createtemporary(vr_obj_bordero_clob, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_obj_bordero_clob, dbms_lob.lob_readwrite);
    json.to_clob(vr_obj_alter,vr_obj_bordero_clob);

    --> Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                                    pr_cdagenci              => pr_cdagenci,
                                    pr_cdoperad              => pr_cdoperad,
                                    pr_cdorigem              => pr_cdorigem,
                                    pr_nrctrprp              => pr_nrborder,
                                    pr_nrdconta              => pr_nrdconta,
                                    pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                    pr_dsoperacao            => 'ANTES ALTERAR BORDERO',
                                    pr_dsuriservico          => NULL,
                                    pr_dtmvtolt              => pr_dtmvtolt,
                                    pr_cdstatus_http         => 0,
                                    pr_dsconteudo_requisicao => vr_obj_bordero_clob,
                                    pr_dsresposta_requisicao => null,
                                    pr_tpproduto             => 7, --> Bordero de Desconto de T�tulos
                                    pr_idacionamento         => vr_idaciona,
                                    pr_dscritic              => vr_dscritic);
      --> Sem tratamento de exce�ao para DEBUG
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      -->  RAISE vr_exc_erro;
      --END IF;
    END IF;

    --> Enviar dados para Esteira
    pc_enviar_analise_bordero(pr_cdcooper    => pr_cdcooper
                             ,pr_cdagenci    => pr_cdagenci
                             ,pr_cdoperad    => pr_cdoperad
                             ,pr_cdorigem    => pr_cdorigem
                             ,pr_nrdconta    => pr_nrdconta
                             ,pr_nrborder    => pr_nrborder
                             ,pr_dtmvtolt    => pr_dtmvtolt
                             ,pr_comprecu    => null
                             ,pr_dsmetodo    => 'PUT'
                             ,pr_conteudo    => vr_obj_bordero_clob
                             ,pr_dsoperacao  => 'REENVIO DO BORDERO PARA ANALISE DE CREDITO'
                             ,pr_dsprotocolo => vr_dsprotocolo
                             ,pr_dscritic    => vr_dscritic);

    --> Se nao houve erro
    IF vr_dscritic IS NULL THEN

    --> Atualizar bordero
    vr_hrenvest := to_char(SYSDATE,'sssss');
    begin
      update crapbdt bdt
         set bdt.insitbdt = 1 -- Em An�lise
           ,bdt.insitapr = 6 -- Enviado Esteira
           ,bdt.cdopeapr = pr_cdoperad
           ,bdt.dtaprova = trunc(sysdate)
           ,bdt.hraprova = vr_hrenvest
           ,dsprotoc = nvl(vr_dsprotocolo,' ')
       where bdt.cdcooper = pr_cdcooper
         and bdt.nrdconta = pr_nrdconta
         and bdt.nrborder = pr_nrborder;
    exception
      when others then
        vr_dscritic := 'Nao foi poss�vel  atualizar border� apos envio da Analise de Credito: '||sqlerrm;
    end;


    --> Caso tenhamos recebido critica de Border� jah existente na Esteira
    ELSIF lower(vr_dscritic) LIKE '%bordero nao encontrado%' THEN

      --> Tentaremos enviar inclusao novamente na Esteira
      pc_incluir_bordero_esteira(pr_cdcooper => pr_cdcooper         --> Codigo da Cooperativa
                                ,pr_cdagenci => pr_cdagenci         --> Numero da agencia
                                ,pr_cdoperad => pr_cdoperad         --> C�digo DO Operador
                                ,pr_cdorigem => pr_cdorigem         --> C�digo da Origem
                                ,pr_nrdconta => pr_nrdconta         --> Numero da conta
                                ,pr_nrborder => pr_nrborder         --> N�mero do Border�
                                ,pr_dtmvtolt => pr_dtmvtolt         --> Data DO Movimento
                                ,pr_nmarquiv => null                --> Nome DO arquivo
                                ,pr_dsmensag => vr_dsmensag         --> Descriao da Mensagem
                                ,pr_cdcritic => vr_cdcritic         --> C�digo da Critica
                                ,pr_dscritic => vr_dscritic);       --> Descri�ao da cr�tica
    END IF;

    --> verificar se retornou critica
    IF  vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;


    --> Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                                    pr_cdagenci              => pr_cdagenci,
                                    pr_cdoperad              => pr_cdoperad,
                                    pr_cdorigem              => pr_cdorigem,
                                    pr_nrctrprp              => pr_nrborder,
                                    pr_nrdconta              => pr_nrdconta,
                                    pr_tpacionamento         => 0,  /* 0 - DEBUG */
                                    pr_dsoperacao            => 'TERMINO ALTERAR BORDERO',
                                    pr_dsuriservico          => NULL,
                                    pr_dtmvtolt              => pr_dtmvtolt,
                                    pr_cdstatus_http         => 0,
                                    pr_dsconteudo_requisicao => null,
                                    pr_dsresposta_requisicao => null,
                                    pr_tpproduto             => 7, --> Desconto de t�tulos
                                    pr_idacionamento         => vr_idaciona,
                                    pr_dscritic              => vr_dscritic);
      --> Sem tratamento de exce�ao para DEBUG
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      -->  RAISE vr_exc_erro;
      --END IF;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN

      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND
        TRIM(vr_dscritic) IS NULL THEN
        --> Busca descricao
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Nao foi poss�vel  realizar alteracao do B�rdero de Desconto de T�tulos: '||SQLERRM;
  END pc_alterar_bordero;

 --> Rotina responsavel em enviar dos dados para a esteira
  PROCEDURE pc_enviar_analise_bordero(pr_cdcooper    IN crapbdt.cdcooper%type  --> Codigo da cooperativa
                                     ,pr_cdagenci    IN crapage.cdagenci%type  --> Codigo da agencia
                                     ,pr_cdoperad    IN crapope.cdoperad%type  --> codigo do operador
                                     ,pr_cdorigem    IN integer                --> Origem da operacao
                                     ,pr_nrdconta    IN crapbdt.nrdconta%type  --> Numero da conta do cooperado
                                     ,pr_nrborder    IN crapbdt.nrborder%type  --> Numero do Border� de Desconto de T�tulos
                                     ,pr_dtmvtolt    IN crapdat.dtmvtolt%type  --> Data do movimento
                                     ,pr_comprecu    IN varchar2               --> Complemento do recuros da URI
                                     ,pr_dsmetodo    IN varchar2               --> Descricao do metodo
                                     ,pr_conteudo    IN clob                   --> Conteudo no Json para comunicacao
                                     ,pr_dsoperacao  IN varchar2               --> Operacao realizada
                                     ,pr_tpenvest    IN VARCHAR2 DEFAULT null  --> Tipo de envio, I-Inclusao C - Consultar(Get)
                                     ,pr_dsprotocolo OUT varchar2              --> Protocolo retornado na requisi�ao
                                     ,pr_dscritic    OUT VARCHAR2  ) IS

    --Parametros
    vr_host_esteira  VARCHAR2(4000);
    vr_recurso_este  VARCHAR2(4000);
    vr_dsdirlog      VARCHAR2(500);
    vr_autori_este   VARCHAR2(500);
    vr_chave_aplica  VARCHAR2(500);

    vr_dscritic      VARCHAR2(4000);
    vr_dscritic_aux  VARCHAR2(4000);
    vr_exc_erro      EXCEPTION;

    vr_request  json0001.typ_http_request;
    vr_response json0001.typ_http_response;

    vr_idacionamento  tbgen_webservice_aciona.idacionamento%TYPE;

  BEGIN
    pr_dsprotocolo := NULL;
    --> Carregar parametros para a comunicacao com a esteira
    este0001.pc_busca_param_ibra(pr_cdcooper     => pr_cdcooper
                                ,pr_tpenvest     => pr_tpenvest
                                ,pr_host_esteira => vr_host_esteira
                                ,pr_recurso_este => vr_recurso_este
                                ,pr_dsdirlog     => vr_dsdirlog
                                ,pr_autori_este  => vr_autori_este
                                ,pr_chave_aplica => vr_chave_aplica
                                ,pr_dscritic     => vr_dscritic);

    IF vr_dscritic  IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --> Atribuir valores necessarios para comunicacao
    vr_request.service_uri := vr_host_esteira;
    vr_request.api_route := vr_recurso_este||pr_comprecu;
    vr_request.method    := pr_dsmetodo;
    vr_request.timeout   := gene0001.fn_param_sistema('CRED',0,'TIMEOUT_CONEXAO_IBRA');

    vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
    vr_request.headers('Authorization') := vr_autori_este;

    --> Se houver ApplicationKey
    IF vr_chave_aplica IS NOT NULL THEN
      vr_request.headers('ApplicationKey') := vr_chave_aplica;
    END IF;

    vr_request.content := pr_conteudo;

    --> Disparo do REQUEST
    json0001.pc_executa_ws_json(pr_request           => vr_request
                               ,pr_response          => vr_response
                               ,pr_diretorio_log     => vr_dsdirlog
                               ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'-- Este formato � o formato que deve ser passado, conforme alinhado com o Oscar
                               ,pr_dscritic          => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --> Gravar dados log acionamento
    ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                                  pr_cdagenci              => pr_cdagenci,
                                  pr_cdoperad              => pr_cdoperad,
                                  pr_cdorigem              => pr_cdorigem,
                                  pr_nrctrprp              => pr_nrborder,
                                  pr_nrdconta              => pr_nrdconta,
                                  pr_tpacionamento         => 1,  /* 1 - Envio, 2 � Retorno */
                                  pr_dsoperacao            => pr_dsoperacao,
                                  pr_dsuriservico          => vr_host_esteira||vr_recurso_este||pr_comprecu,
                                  pr_dtmvtolt              => pr_dtmvtolt,
                                  pr_cdstatus_http         => vr_response.status_code,
                                  pr_dsconteudo_requisicao => pr_conteudo,
                                  pr_dsresposta_requisicao => '{"StatusMessage":"'||vr_response.status_message||'"'||CHR(13)||
                                                              ',"Headers":"'||RTRIM(LTRIM(vr_response.headers,'""'),'""')||'"'||CHR(13)||
                                                              ',"Content":'||vr_response.content||'}',
                                  pr_tpproduto             => 7, --> Desconto de T�tulo � Border�      --> Tipo DO Produto
                                  pr_idacionamento         => vr_idacionamento,
                                  pr_dscritic              => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    IF vr_response.status_code NOT BETWEEN 200 AND 299 THEN
      --> Definir mensagem de critica
      CASE
        WHEN pr_dsmetodo = 'POST' THEN
          vr_dscritic_aux := 'N�o foi poss�vel enviar Border� para An�lise.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu IS NULL THEN
          vr_dscritic_aux := 'N�o foi poss�vel reenviar a Border� para An�lise.';
/*        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/numeroProposta' THEN
          vr_dscritic_aux := 'N�o foi poss�vel alterar n�mero da Border� de Desconto de T�tulos.';*/
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/cancelar' THEN
          vr_dscritic_aux := 'N�o foi poss�vel excluir o Border� da An�lise.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/efetivar' THEN
          vr_dscritic_aux := 'N�o foi poss�vel enviar a efetiva��o do Border� de Desconto de T�tulos.';
        WHEN pr_dsmetodo = 'GET' THEN
          vr_dscritic_aux := 'N�o foi poss�vel solicitar o retorno da An�lise Autom�tica de Cr�dito.';
        ELSE
          vr_dscritic_aux := 'N�o foi poss�vel enviar informa��es para An�lise de Cr�dito.';
        END CASE;

      IF vr_response.status_code = 400 THEN
        pr_dscritic := este0001.fn_retorna_critica('{"Content":'||vr_response.content||'}');

        IF pr_dscritic IS NOT NULL THEN
          --> Tratar mensagem espec�fica de Fluxo Atacado:
          IF pr_dscritic != 'N�o ser� poss�vel enviar o Border� para an�lise. Classifica��o de risco e endividamento fora dos par�metros da cooperativa' THEN
            --> Mensagens diferentes dela terao o prefixo, somente ela n�o ter�
            pr_dscritic := vr_dscritic_aux||' '||pr_dscritic;
          END IF;
        ELSE
          pr_dscritic := vr_dscritic_aux;
        END IF;

      ELSE
        pr_dscritic := vr_dscritic_aux;
      END IF;

    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi poss�vel enviar Border� para An�lise de Cr�dito: '||SQLERRM;
  END pc_enviar_analise_bordero;


  PROCEDURE pc_enviar_analise_manual(pr_cdcooper  IN crapbdt.cdcooper%TYPE
                                    ,pr_cdagenci  IN crapage.cdagenci%TYPE
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                    ,pr_cdorigem  IN INTEGER
                                    ,pr_nrdconta  IN crapbdt.nrdconta%TYPE
                                    ,pr_nrborder  IN crapbdt.nrborder%TYPE
                                    ,pr_dtmvtolt  IN crapbdt.dtmvtolt%TYPE
                                    ,pr_nmarquiv  IN VARCHAR2
                                    ,vr_flgdebug  IN VARCHAR2
                                     ---- OUT ----
                                    ,pr_dsmensag OUT VARCHAR2
                                    ,pr_cdcritic OUT NUMBER
                                    ,pr_dscritic OUT VARCHAR2
                                    ,pr_des_erro OUT VARCHAR2) IS

 /* ...........................................................................

   Programa : pc_enviar_analise_manual
   Sistema  : Conta-Corrente - Cooperativa de Credito
   Sigla    : CRED
   Autor    : Luis Fernando - GFT-Brasil
   Data     : Mar�o/2018.          Ultima atualizacao: 21/08/2018

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina responsavel por gerar a geracao e inclusao do Border� para a esteira

   Alteracoes: 21/08/2018 - Altera��es de formato de data na pc_enviar_analise_manual. (Andrew Albuquerque - GFT)
               24/08/2018 - Altera��o na pc_enviar_analise_manual, pois a mensagem de retorno da IBRATAN referente 
                            a bordero j� existente na esteira foi alterada, causando erro no envio de altera��o
                            de bordero/proposta (Andrew Albuquerque - GFT)
 ..........................................................................*/

 vr_cdagenci crapage.cdagenci%type; --> Codigo da agencia

 vr_exc_erro EXCEPTION;
 vr_dscritic VARCHAR2(4000);
 vr_cdcritic NUMBER;

 --> Hora de Envio
 vr_hraprova crapbdt.hraprova%TYPE;

 vr_obj_bordero json := json();
 vr_obj_bordero_clob clob;

 vr_dsprotoc VARCHAR2(1000);
 vr_idaciona tbgen_webservice_aciona.idacionamento%type;

  --> Busca do nome do associado
  cursor cr_crapass is
  select ass.nmprimtl
        ,ass.inpessoa
        ,ass.cdagenci
  from   crapass ass
  where  ass.cdcooper = pr_cdcooper
  and    ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%rowtype;

 BEGIN
   pc_verifica_contigenc_esteira(pr_cdcooper => pr_cdcooper
                                ,pr_flctgest => vr_flctgest
                                ,pr_dsmensag => pr_dsmensag
                                ,pr_dscritic => vr_dscritic);

   if  vr_flctgest then
       vr_dscritic := pr_dsmensag;
       raise vr_exc_erro;
   end if;

  open  cr_crapass;
  fetch cr_crapass into rw_crapass;
  if    cr_crapass%notfound then
        close cr_crapass;
        vr_dscritic := 'Associado n�o cadastrado. Conta: ' || pr_nrdconta;
        raise vr_exc_erro;
  end   if;
  close cr_crapass;

  vr_cdagenci := nvl(nullif(pr_cdagenci, 0), rw_crapass.cdagenci);

   --> Gerar informa�oes no padrao JSON do border� de desconto de t�tulos
   pc_gera_json_bordero(pr_cdcooper  => pr_cdcooper
                        ,pr_cdagenci  => vr_cdagenci
                        ,pr_cdoperad  => pr_cdoperad
                        ,pr_nrdconta  => pr_nrdconta
                        ,pr_nrborder  => pr_nrborder
                        ,pr_nmarquiv  => pr_nmarquiv  --> Diretorio e nome do arquivo pdf do border� de desconto de t�tulos
                        ---- OUT ----
                        ,pr_bordero_envio  => vr_obj_bordero  --> Retorno do clob em modelo json do border� de desconto de t�tulos
                        ,pr_cdcritic  => vr_cdcritic
                        ,pr_dscritic  => vr_dscritic);

   IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
     RAISE vr_exc_erro;
   END IF;

   --> Criar o CLOB para converter JSON para CLOB
   dbms_lob.createtemporary(vr_obj_bordero_clob, TRUE, dbms_lob.CALL);
   dbms_lob.open(vr_obj_bordero_clob, dbms_lob.lob_readwrite);
   json.to_clob(vr_obj_bordero,vr_obj_bordero_clob);

   --> Se o DEBUG estiver habilitado
   IF vr_flgdebug = 'S' THEN
     --> Gravar dados log acionamento
     ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,
                                   pr_cdagenci              => vr_cdagenci,
                                   pr_cdoperad              => pr_cdoperad,
                                   pr_cdorigem              => pr_cdorigem,
                                   pr_nrctrprp              => pr_nrborder,
                                   pr_nrdconta              => pr_nrdconta,
                                   pr_tpacionamento         => 0,  --> 0 - DEBUG
                                   pr_dsoperacao            => 'ANTES ENVIAR BORDERO',
                                   pr_dsuriservico          => NULL,
                                   pr_dtmvtolt              => pr_dtmvtolt,
                                   pr_cdstatus_http         => 0,
                                   pr_dsconteudo_requisicao => vr_obj_bordero_clob,
                                   pr_dsresposta_requisicao => null,
                                   pr_tpproduto             => 7, --> Desconto de T�tulo � Border�      --> Tipo DO Produto
                                   pr_idacionamento         => vr_idaciona,
                                   pr_dscritic              => vr_dscritic);
     --> Sem tratamento de exce�ao para DEBUG
     --IF TRIM(vr_dscritic) IS NOT NULL THEN
     -->  RAISE vr_exc_erro;
     --END IF;
   END IF;

   --> Enviar dados para Esteira
   pc_enviar_analise_bordero (pr_cdcooper    => pr_cdcooper
                             ,pr_cdagenci    => vr_cdagenci
                             ,pr_cdoperad    => pr_cdoperad
                             ,pr_cdorigem    => pr_cdorigem
                             ,pr_nrdconta    => pr_nrdconta
                             ,pr_nrborder    => pr_nrborder
                             ,pr_dtmvtolt    => pr_dtmvtolt
                             ,pr_comprecu    => NULL
                             ,pr_dsmetodo    => 'POST'
                             ,pr_conteudo    => vr_obj_bordero_clob
                             ,pr_dsoperacao  => 'ENVIO DO BORDERO PARA ANALISE DE CREDITO'
                             ,pr_tpenvest    => 'I' -- N�o existe deriva��o para Border�
                             ,pr_dsprotocolo => vr_dsprotoc
                             ,pr_dscritic    => vr_dscritic);

   --> Caso tenhamos recebido critica de Bordero jah existente na Esteira
   IF (lower(vr_dscritic) LIKE '%bordero%ja existente na esteira%') OR
      (lower(vr_dscritic) LIKE '%proposta%ja existente na esteira%') THEN

     --> Tentaremos enviar altera�ao com rein�cio de fluxo para a Esteira
     pc_alterar_bordero(pr_cdcooper => pr_cdcooper
                       ,pr_cdagenci => vr_cdagenci
                       ,pr_cdoperad => pr_cdoperad
                       ,pr_cdorigem => pr_cdorigem
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrborder => pr_nrborder
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_flreiflx => 1
                       ,pr_nmarquiv => pr_nmarquiv
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
   END IF;

   --> Liberando a mem�ria alocada pro CLOB
   dbms_lob.close(vr_obj_bordero_clob);
   dbms_lob.freetemporary(vr_obj_bordero_clob);

   --> verificar se retornou critica
   IF vr_dscritic IS NOT NULL THEN
     RAISE vr_exc_erro;
   END IF;

   vr_hraprova := to_char(SYSDATE,'sssss');

   --> Atualizar bordero
   --> atualizar o Border� como enviado para Esteira.
   begin
     update crapbdt bdt
        set bdt.insitbdt = 1 -- Em An�lise
           ,bdt.insitapr = 6 -- Enviado Esteira
           ,bdt.cdopeapr = pr_cdoperad
           ,bdt.dtaprova = trunc(sysdate)
           ,bdt.hraprova = vr_hraprova
           ,dsprotoc = nvl(vr_dsprotoc,' ')
      where bdt.cdcooper = pr_cdcooper
        and bdt.nrdconta = pr_nrdconta
        and bdt.nrborder = pr_nrborder;
   exception
      when others then
           vr_dscritic := 'Nao foi poss�vel atualizar o border� apos envio para An�lise de Cr�dito: '||sqlerrm;
           raise vr_exc_erro;
   end;

   pr_dsmensag := 'Border� Enviado para Analise Manual de Credito.';

   --> Efetuar grava�ao
   COMMIT;

   EXCEPTION
     WHEN vr_exc_erro THEN
          --> Se possui c�digo de cr�tica e n�o foi informado a descri�ao
          IF  vr_cdcritic <> 0 and TRIM(vr_dscritic) IS NULL THEN
              --> Busca descri�ao da cr�tica
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;

          --> Atribui exce�ao para os parametros de cr�tica
          pr_cdcritic := nvl(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
          pr_des_erro := 'NOK';

          ROLLBACK;

     WHEN OTHERS THEN
          --> Atribui exce�ao para os parametros de cr�tica
          pr_cdcritic := nvl(vr_cdcritic,0);
          pr_dscritic := 'Erro n�o tratado na este0006.pc_enviar_analise_manual: ' || SQLERRM;
          pr_des_erro := 'NOK';

          ROLLBACK;
   END pc_enviar_analise_manual;

  --> Rotina responsavel por gerar o objeto Json do border�

  PROCEDURE pc_gera_json_bordero(pr_cdcooper in crapbdt.cdcooper%type
                                ,pr_cdagenci in crapage.cdagenci%type
                                ,pr_cdoperad in crapope.cdoperad%type
                                ,pr_nrdconta in crapbdt.nrdconta%type
                                ,pr_nrborder in crapbdt.nrborder%type
                                ,pr_nmarquiv in varchar2               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                ---- OUT ----
                                ,pr_bordero_envio out json                   --> Retorno do clob em modelo json da proposta de emprestimo
--                                ,pr_bordero_clob out CLOB -- ANDREW: APENAS PARA TESTES
                                ,pr_cdcritic out number                 --> Codigo da critica
                                ,pr_dscritic out varchar2               --> Descricao da critica
                                ) is
  /* ..........................................................................

      Programa : pc_gera_json_bordero
      Sistema  :
      Sigla    : CRED
      Autor    : Paulo Penteado (GFT)
      Data     : Abril/2018.

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por montar o objeto json para analise.

      Altera�ao : 24/04/2018 Cria��o (Paulo Penteado (GFT))

    ..........................................................................*/

  cursor cr_crapass is
  select ass.nrdconta
        ,ass.nmprimtl
        ,ass.cdagenci
        ,age.nmextage
        ,ass.inpessoa
        ,decode(ass.inpessoa,1,0,2,1) inpessoa_ibra
        ,ass.nrcpfcgc
        ,ass.dtmvtolt
  from   crapass ass
        ,crapage age
  where  ass.cdcooper = age.cdcooper
  and    ass.cdagenci = age.cdagenci
  and    ass.cdcooper = pr_cdcooper
  and    ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%rowtype;

  --> buscar dados do Border� de Desconto de T�tulos.
  CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%TYPE
                    ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                    ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
    SELECT bdt.nrborder
          ,bdt.cdagenci
          ,bdt.dtmvtolt
          ,0 as vlborder --> deve ser a soma dos valores dos t�tulos do border� (?)
          ,1 as qtborder
          ,bdt.hrtransa as hrinclus
          ,ldc.cddlinha cdlcremp
          ,ldc.dsdlinha dslcremp
          ,decode(ldc.tpctrato, 1, 4, 0) tpctrato -- Tipo do contrato de Limite Desconto  (0-Generico/ 1-Aplicacao)
          ,decode(ldc.tpctrato, 1, 'APLICACAO FINANCEIRA', 'SEM GARANTIA') dsctrato 
          ,0 cdfinemp -- finalidadeCodigo: Codigo Finalidade da Proposta de Empr�stimo
          ,'' dsfinemp -- finalidadeDescricao: Descricao Finalidade da Proposta de Empr�stimo Paulo Penteado (GFT)teste pois parece que nao aceita nulo
          ,bdt.cdoperad
          ,ope.nmoperad
          ,0 instatus
          ,bdt.insitbdt
          ,bdt.nrctrlim
          ,' ' AS dsnivris
          ,UPPER(bdt.cdopeapr) as cdopeapr
          ,'0,0,0,0,0,0,0,0,0,0' dsliquid
          ,'BT' as tpproduto
      FROM crapbdt bdt
     INNER JOIN craplim lim -- apenas para chegar nas informa��es de linha de credito com um passo a menos no oracle engine. Menor custo para o banco.
        ON lim.nrdconta = bdt.nrdconta
       AND lim.cdcooper = bdt.cdcooper
       AND lim.nrctrlim = bdt.nrctrlim
     INNER JOIN crapldc ldc
        ON ldc.cdcooper = bdt.cdcooper
       AND ldc.cddlinha = bdt.cddlinha
       AND ldc.tpdescto = lim.tpctrlim
     INNER JOIN crapope ope
        ON ope.cdcooper = bdt.cdcooper
       AND UPPER(ope.cdoperad) = UPPER(bdt.cdoperad)
     WHERE lim.tpctrlim = 3 -- Contrato de Desconto de Limite.
       AND lim.insitlim = 2 -- contrato de limite ativo
       AND bdt.cdcooper = pr_cdcooper
       AND bdt.nrdconta = pr_nrdconta
       AND bdt.nrborder = pr_nrborder;
  rw_crapbdt cr_crapbdt%ROWTYPE;

  --> Dados de T�tulos do Border�
  CURSOR cr_craptdb (pr_cdcooper IN crapbdt.cdcooper%TYPE
                    ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                    ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
    -- T�TULOS DO BORDER� + seus documentos de cobran�a
    SELECT tdb.cdcooper
          ,tdb.nrdconta
          ,tdb.nrborder
          ,tdb.nrdocmto --n�mero do boleto
          ,tdb.nrdctabb
          ,tdb.nrcnvcob --convenio
          ,tdb.cdbandoc --banco
          ,sab.nmdsacad -- nome do pagador
          ,sab.cdtpinsc -- Codigo do tipo da inscricao do sacado(0-nenhum/1-CPF/2-CNPJ)
          ,tdb.nrinssac -- cpf cnpj
          ,tdb.dtvencto -- data de vencimento
          ,tdb.vltitulo  -- valor do t�tulo bruto
          ,tdb.vlliquid -- valor do titulo l�quido
          ,tdb.vlliqres -- valor liquido resgate
          ,tdb.insittit -- situa��o do t�tulo
          ,tdb.insitapr -- situa��o da aprova��o do t�tulo. 4-Aprovado  5-Reprovado
          ,tdb.nrtitulo -- Numero unico do t�tulo no bordero
          ,DECODE(tdb.insitapr,1,'APROVADO',2,'REPROVADO',NULL) as dessitapr
          ,sum(tdb.vltitulo) over (partition by tdb.cdcooper, tdb.nrdconta, tdb.nrborder) as vl_border_brt -- Total valor bruto do border�
          ,sum(tdb.vlliquid) over (partition by tdb.cdcooper, tdb.nrdconta, tdb.nrborder) as vl_border_lqd -- Total valor liquido do border�
          ,SUM(DECODE(cob.flgregis,1,tdb.vltitulo,0)) over (partition by tdb.cdcooper, tdb.nrdconta, tdb.nrborder) as vl_border_brt_cr -- Total valor bruto border� Cobran�a Com Registro
          ,SUM(DECODE(cob.flgregis,0,tdb.vltitulo,0)) over (partition by tdb.cdcooper, tdb.nrdconta, tdb.nrborder) as vl_border_brt_sr -- Total valor bruto border� Cobran�a Sem Registro
          ,SUM(DECODE(cob.flgregis,1,tdb.vlliquid,0)) over (partition by tdb.cdcooper, tdb.nrdconta, tdb.nrborder) as vl_border_lqd_cr -- Total valor liquido border� Cobran�a Com Registro
          ,SUM(DECODE(cob.flgregis,0,tdb.vlliquid,0)) over (partition by tdb.cdcooper, tdb.nrdconta, tdb.nrborder) as vl_border_lqd_sr -- Total valor liquido border� Cobran�a Sem Registro
          ,count(1) over (partition by tdb.cdcooper, tdb.nrdconta, tdb.nrborder)          as qtde_titulos
          ,tdb.nrseqdig as cdchavetbd -- chave para ser enviada a IBRATAN
          ,cob.flgregis -- 1 - Com Registro / 0 - Sem Registro
      FROM craptdb tdb
     INNER JOIN crapcob cob
        ON tdb.cdcooper = cob.cdcooper
       AND tdb.nrdconta = cob.nrdconta
       AND tdb.nrdctabb = cob.nrdctabb
       AND tdb.nrdocmto = cob.nrdocmto
       AND tdb.nrinssac = cob.nrinssac
     INNER JOIN cecred.crapsab sab -- dados do sacado, para pegar o nome do sacado corretamente
        ON sab.nrinssac = cob.nrinssac
       AND sab.cdtpinsc = cob.cdtpinsc
       AND sab.cdcooper = cob.cdcooper
       AND sab.nrdconta = cob.nrdconta
     WHERE tdb.cdcooper = pr_cdcooper
       AND tdb.nrborder = pr_nrborder
       AND tdb.nrdconta = pr_nrdconta
      ORDER BY tdb.nrborder, tdb.nrinssac, nrdocmto;
  rw_craptdb cr_craptdb%ROWTYPE;

  -- Buscar Cr�ticas dos T�tulos.
  rw_crapabt dsct0003.cr_crapabt%ROWTYPE;
  vr_tab_criticas dsct0003.typ_tab_critica;
  vr_index_critica PLS_INTEGER;

  --> Totais do Borderos Com An�lise Aprovada e N�o efetivados
  CURSOR cr_border_nefet (pr_cdcooper IN crapabt.cdcooper%TYPE
                         ,pr_nrdconta IN crapabt.nrdconta%TYPE) IS
    SELECT SUM(tdb.vlliquid) as totvlliquid
          ,SUM(tdb.vltitulo) as totvltitulo
      FROM crapbdt bdt
     INNER JOIN craptdb tdb
        ON tdb.cdcooper = bdt.cdcooper
       AND tdb.nrdconta = bdt.nrdconta
       AND tdb.nrborder = bdt.nrborder
     WHERE bdt.cdcooper = pr_cdcooper
       AND bdt.nrdconta = pr_nrdconta
       AND bdt.insitbdt = 2
       AND bdt.insitapr in (3,4);
  rw_border_nefet cr_border_nefet%ROWTYPE;


  --> Dados de Proposta do Limite Ativa mais recente.
  CURSOR cr_crawlim (pr_cdcooper IN crawlim.cdcooper%TYPE
                    ,pr_nrdconta IN crawlim.nrdconta%TYPE
                    ,pr_nrctrlim IN crawlim.nrctrlim%TYPE) IS
    WITH tbl_proposta_vigente AS
      (select max(lim_ativo.dtpropos) dtpropos , max(lim_ativo.progress_recid) recid
         from crawlim lim_ativo
        where lim_ativo.insitlim = 2
          and lim_ativo.tpctrlim = 3
          and lim_ativo.nrdconta = pr_nrdconta
          and lim_ativo.cdcooper = pr_cdcooper
          and (lim_ativo.nrctrlim = pr_nrctrlim or lim_ativo.nrctrmnt = pr_nrctrlim)
      )
      SELECT wlim.nrctrmnt
            ,wlim.nrctrlim
            ,decode(wlim.nrctrmnt, 0, wlim.nrctrlim, wlim.nrctrmnt) as nrctrativo
            ,wlim.vllimite
            ,wlim.dsnivris
            ,wlim.insitlim
            ,wlim.insitapr
            ,wlim.tpctrlim
            ,wlim.progress_recid
            ,wlim.dtpropos as dtvencto
        FROM crawlim wlim
       INNER JOIN tbl_proposta_vigente prop
          on prop.dtpropos = wlim.dtpropos
         and prop.recid    = wlim.progress_recid
       where wlim.tpctrlim = 3
         and wlim.insitlim = 2
         and wlim.cdcooper = pr_cdcooper
         and wlim.nrdconta = pr_nrdconta
         and (wlim.nrctrlim = pr_nrctrlim or wlim.nrctrmnt = pr_nrctrlim)
       ;
  rw_crawlim cr_crawlim%ROWTYPE;

  -->    Selecionar os associados da cooperativa por CPF/CGC
  cursor cr_crapass_cpfcgc(pr_nrcpfcgc crapass.nrcpfcgc%type) is
  select cdcooper
        ,nrdconta
        ,flgcrdpa
  from   crapass
  where  cdcooper = pr_cdcooper
  and    nrcpfcgc = pr_nrcpfcgc -- CPF/CGC passado
  and    dtelimin is null;

  -->    Buscar valor de propostas pendentes
  cursor cr_crawepr_pend is
  select nvl(sum(w.vlemprst),0) vlemprst
  from   crawepr w
    join craplcr l on l.cdlcremp = w.cdlcremp and
                      l.cdcooper = w.cdcooper
  where  w.cdcooper = pr_cdcooper
  and    w.nrdconta = pr_nrdconta
  and    w.insitapr in(1,3)        -- j� estao aprovadas
  and    w.insitest <> 4           -- Expiradas
  --AND w.nrctremp <> pr_nrctremp -- desconsiderar a proposta que esta sendo enviada no momento
  and   not exists( select 1
                    from   crapepr p
                    where  w.cdcooper = p.cdcooper
                    and    w.nrdconta = p.nrdconta
                    and    w.nrctremp = p.nrctremp);
  rw_crawepr_pend cr_crawepr_pend%rowtype;

  -->    Selecionar o saldo disponivel do pre-aprovado da conta em questao  da carga ativa
  cursor cr_crapcpa is
  select cpa.vllimdis
        ,cpa.vlcalpre
        ,cpa.vlctrpre
  from   crapcpa              cpa
        ,tbepr_carga_pre_aprv carga
  where  carga.cdcooper = pr_cdcooper
  and    carga.indsituacao_carga = 1
  and    carga.flgcarga_bloqueada = 0
  and    cpa.cdcooper = carga.cdcooper
  and    cpa.iddcarga = carga.idcarga
  and    cpa.nrdconta = pr_nrdconta;
  rw_crapcpa cr_crapcpa%rowtype;

  -->    Buscar operador
  cursor cr_crapope is
  select ope.nmoperad
        ,ope.cdoperad
  from   crapope ope
  where  ope.cdcooper        = pr_cdcooper
  and    upper(ope.cdoperad) = upper(pr_cdoperad);
  rw_crapope cr_crapope%rowtype;

  -->    Buscar se a conta � de Colaborador Cecred
  cursor cr_tbcolab is
  select substr(lpad(col.cddcargo_vetor,7,'0'),5,3) cddcargo
  from   tbcadast_colaborador col
  where  col.cdcooper = pr_cdcooper
  and    col.nrcpfcgc = rw_crapass.nrcpfcgc
  and    col.flgativo = 'A';

  vr_flgcolab boolean;
  vr_cddcargo tbcadast_colaborador.cdcooper%type;

  -->    Calculo do faturamento PJ
  cursor cr_crapjfn is
  select vlrftbru##1+vlrftbru##2+vlrftbru##3+vlrftbru##4+vlrftbru##5+vlrftbru##6
        +vlrftbru##7+vlrftbru##8+vlrftbru##9+vlrftbru##10+vlrftbru##11+vlrftbru##12 vltotfat
  from   crapjfn
  where  cdcooper = pr_cdcooper
  and    nrdconta = pr_nrdconta;
  rw_crapjfn cr_crapjfn%rowtype;
  -->     Utilizado para verificar restricoes do pagador
  vr_ibratan char(1) := 'N';
  vr_cdbircon crapbir.cdbircon%TYPE;
  vr_dsbircon crapbir.dsbircon%TYPE;
  vr_cdmodbir crapmbr.cdmodbir%TYPE;
  vr_dsmodbir crapmbr.dsmodbir%TYPE;

  CURSOR cr_crapcbd (pr_nrinssac craptdb.nrinssac%TYPE) IS
    SELECT crapcbd.nrconbir,
           crapcbd.nrseqdet
      FROM crapcbd
     WHERE crapcbd.cdcooper = pr_cdcooper
       AND crapcbd.nrdconta = pr_nrdconta 
       AND crapcbd.nrcpfcgc = pr_nrinssac
       AND crapcbd.inreterr = 0  -- Nao houve erros
     ORDER BY crapcbd.dtconbir DESC; -- Buscar a consuilta mais recente
  rw_crapcbd  cr_crapcbd%rowtype;

  -----------> VARIAVEIS <-----------
  -- Tratamento de erros
  vr_cdcritic number;
  vr_dscritic varchar2(500);
  vr_exc_erro exception;

  --Tipo de registro do tipo data
  rw_crapdat btch0001.cr_crapdat%rowtype;

  -- Objeto json da proposta
  vr_obj_bordero  json := json();
  vr_obj_agencia  json := json();
  vr_obj_imagem   json := json();
  vr_lst_doctos   json_list := json_list();
  vr_json_valor   json_value;
  vr_obj_titulos  json := json();
  vr_lst_titulos  json_list := json_list();
  vr_obj_crit_tit json := json();
  vr_lst_crit_tit json_list := json_list();

  -- Variaveis auxiliares
  vr_data_aux     date := null;
  vr_dstextab     craptab.dstextab%type;
  vr_inusatab     boolean;
  vr_vlutiliz     number;
  vr_vlprapne     number;
  vr_vllimdis     number;
  vr_nmarquiv     varchar2(1000);
  vr_dsiduser     varchar2(100);
  vr_dsprotoc  tbgen_webservice_aciona.dsprotocolo%type;
  vr_dsdirarq  varchar2(1000);
  vr_dscomando varchar2(1000);
  vr_vlborder_brt craptdb.vltitulo%TYPE;
  vl_aprov_nefet NUMBER;
  vr_qtde_titulos PLS_INTEGER;

  vr_tab_dados_dsctit_cr cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobran�a Registrada
  vr_tab_dados_dsctit_sr cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobran�a Sem Registro
  vr_tab_cecred_dsctit cecred.dsct0002.typ_tab_cecred_dsctit; -- retorno da TAB052 para CECRED

  BEGIN

     --    Verificar se a data existe
     open  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
     fetch btch0001.cr_crapdat into rw_crapdat;
     if    btch0001.cr_crapdat%notfound then
           vr_cdcritic:= 1;
           close btch0001.cr_crapdat;
           raise vr_exc_erro;
     end   if;
     close btch0001.cr_crapdat;

     -->   Buscar dados do associado
     open  cr_crapass;
     fetch cr_crapass into rw_crapass;
     if    cr_crapass%notfound then
           close cr_crapass;
           vr_cdcritic := 9;
           raise vr_exc_erro;
     else
       -- Busca os Par�metros para o Cooperado e Cobran�a Com Registro
       dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                           pr_cdagenci, --Agencia de opera��o
                                           0, --N�mero do caixa
                                           pr_cdoperad, --Operador
                                           rw_crapdat.dtmvtolt, -- Data da Movimenta��o
                                           1, --Identifica��o de origem 1 Ayllos
                                           1, --pr_tpcobran: 1-REGISTRADA / 0-N�O REGISTRADA
                                           rw_crapass.inpessoa, --1-PESSOA F�SICA / 2-PESSOA JUR�DICA
                                           vr_tab_dados_dsctit_cr,
                                           vr_tab_cecred_dsctit,
                                           vr_cdcritic,
                                           vr_dscritic);

       -- Busca os Par�metros para o Cooperado e Cobran�a Sem Registro
       dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                           pr_cdagenci, --Agencia de opera��o
                                           0, --N�mero do caixa
                                           pr_cdoperad, --Operador
                                           rw_crapdat.dtmvtolt, -- Data da Movimenta��o
                                           1, --Identifica��o de origem 1 Ayllos
                                           0, --pr_tpcobran: 1-REGISTRADA / 0-N�O REGISTRADA
                                           rw_crapass.inpessoa, --1-PESSOA F�SICA / 2-PESSOA JUR�DICA
                                           vr_tab_dados_dsctit_sr,
                                           vr_tab_cecred_dsctit,
                                           vr_cdcritic,
                                           vr_dscritic);
       CLOSE cr_crapass;
     end if;

     --> Buscar o registro de Border� de Desconto
     OPEN cr_crapbdt(pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrborder => pr_nrborder);
     fetch cr_crapbdt into rw_crapbdt;
     if    cr_crapbdt%notfound then
           close cr_crapbdt;
           vr_cdcritic := 1166; --> 1166 - Bordero nao encontrado.
           raise vr_exc_erro;
     end if;
     close cr_crapbdt;

     --> Buscar dados da Proposta de Limite do Border�
     OPEN cr_crawlim (pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctrlim => rw_crapbdt.nrctrlim);
     FETCH cr_crawlim INTO rw_crawlim;
     IF cr_crawlim%NOTFOUND THEN
       CLOSE cr_crawlim;
       vr_cdcritic := 0; --> N�o existe c�digo para esse erro ainda
       vr_dscritic := 'Proposta do Limite n�o Encontrada.';
       RAISE vr_exc_erro;
     END IF;
     CLOSE cr_crawlim;

     --> Buscar o registro de T�tulos do Border� de Desconto
     OPEN cr_craptdb(pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrborder => pr_nrborder);
     fetch cr_craptdb into rw_craptdb;
     if    cr_craptdb%notfound then
           close cr_craptdb;
           vr_cdcritic := 0; --> N�o existe c�digo para esse erro ainda
           vr_dscritic := 'T�tulos do Border� N�o Encontrados.';
           raise vr_exc_erro;
     else
       vr_vlborder_brt := rw_craptdb.vl_border_brt; -- valor total bruto do border� (soma valores brutos de t�tulos desse border�)
       vr_qtde_titulos := rw_craptdb.qtde_titulos; -- quantidade de t�tulos nesse border�.
     end   if;
     close cr_craptdb;

     --> Criar objeto json para agencia da proposta
     vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
     vr_obj_agencia.put('PACodigo', pr_cdagenci);
     vr_obj_bordero.put('PA' ,vr_obj_agencia);
     vr_obj_agencia := json();

     --> Criar objeto json para agencia do cooperado
     vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
     vr_obj_agencia.put('PACodigo', rw_crapass.cdagenci);
     vr_obj_bordero.put('cooperadoContaPA' ,vr_obj_agencia);

     -- Nr. conta sem o digito
     vr_obj_bordero.put('cooperadoContaNum',to_number(substr(rw_crapass.nrdconta,1,length(rw_crapass.nrdconta)-1)));
     -- Somente o digito
     vr_obj_bordero.put('cooperadoContaDv' ,to_number(substr(rw_crapass.nrdconta,-1)));

     vr_obj_bordero.put('cooperadoNome'    , rw_crapass.nmprimtl);

     vr_obj_bordero.put('cooperadoTipoPessoa', rw_crapass.inpessoa_ibra);
     if  rw_crapass.inpessoa = 1 then
         vr_obj_bordero.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,11,'0'));
     else
         vr_obj_bordero.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,14,'0'));
     end if;

     vr_obj_bordero.put('numero'             , rw_crapbdt.nrborder);
     vr_obj_bordero.put('valor'              , to_number(vr_vlborder_brt));

     vr_obj_bordero.put('valorLimiteAtivo', to_number(rw_crawlim.vllimite));
     vr_obj_bordero.put('valorLimiteMaximoPermitido', to_number(vr_tab_dados_dsctit_sr(1).vllimite));
     vr_obj_bordero.put('numeroPropostaLimite', rw_crawlim.nrctrativo);

     --Preenchendo Lista T�tulos e lista de Cr�ticas dos T�tulos.
     -- limpar os objetos jason
     vr_lst_titulos := json_list();
     rw_craptdb := null;
     for rw_craptdb in cr_craptdb (pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrborder => pr_nrborder) loop
         vr_obj_titulos := json();
         -- Popular o Objeto de Lista JSON com os dados do T�tulo.
         vr_obj_titulos.put('idTitulo'       , rw_craptdb.nrtitulo);
         vr_obj_titulos.put('convenio'       , rw_craptdb.nrcnvcob);
         vr_obj_titulos.put('numero'         , rw_craptdb.nrdocmto);
         vr_obj_titulos.put('nome'           , rw_crapass.nmprimtl); -- do cedente
         if  rw_crapass.inpessoa = 1 then
           vr_obj_titulos.put('documento'      , lpad(rw_crapass.nrcpfcgc,11,'0')); -- do cedente
         ELSE
           vr_obj_titulos.put('documento'      , lpad(rw_crapass.nrcpfcgc,14,'0')); -- do cedente
         END IF;
         vr_obj_titulos.put('vencimento'     , TO_CHAR(rw_craptdb.dtvencto,'rrrr-mm-dd') );
	       vr_obj_titulos.put('valor'          , rw_craptdb.vltitulo);
         IF (rw_craptdb.dessitapr IS NOT NULL) THEN
            vr_obj_titulos.put('situacao'       , rw_craptdb.dessitapr);
         END IF;

         if  rw_craptdb.cdtpinsc = 1 then
             vr_obj_bordero.put('cPCCNPJpagador' , lpad(rw_craptdb.nrinssac,11,'0'));
         else
             vr_obj_bordero.put('cPCCNPJpagador' , lpad(rw_craptdb.nrinssac,14,'0'));
         end if;

         rw_crapabt := null;
         -- Popular o Objeto de Lista JSON com os dados de cr�ticas dos t�tulos.
         for rw_crapabt IN dsct0003.cr_crapabt(pr_cdcooper => rw_craptdb.cdcooper
                                     ,pr_nrdconta => rw_craptdb.nrdconta
                                     ,pr_nrborder => rw_craptdb.nrborder
                                     ,pr_cdbandoc => rw_craptdb.cdbandoc
                                     ,pr_nrdctabb => rw_craptdb.nrdctabb
                                     ,pr_nrdocmto => rw_craptdb.nrdocmto) loop

           vr_obj_crit_tit.put('codigo', rw_crapabt.cdcritica);
           vr_obj_crit_tit.put('descricao', rw_crapabt.dscritica);
           vr_lst_crit_tit.append(vr_obj_crit_tit.to_json_value());
         end loop;     
         rw_crapabt := null;               
         -- Popular o Objeto de Lista JSON com os dados de cr�ticas do bordero e do cedente.         
         for rw_crapabt IN dsct0003.cr_crapabt(pr_cdcooper => rw_craptdb.cdcooper
                                     ,pr_nrdconta => rw_craptdb.nrdconta
                                     ,pr_nrborder => rw_craptdb.nrborder
                                     ,pr_cdbandoc => 0
                                     ,pr_nrdctabb => 0
                                     ,pr_nrdocmto => 0) LOOP
           vr_obj_crit_tit.put('codigo', rw_crapabt.cdcritica);
           vr_obj_crit_tit.put('descricao', rw_crapabt.dscritica);
           vr_lst_crit_tit.append(vr_obj_crit_tit.to_json_value());
         end loop;
         -- Busca as criticas do Pagador
         vr_tab_criticas.delete;
         dsct0003.pc_calcula_restricao_pagador(pr_cdcooper => rw_craptdb.cdcooper
                          ,pr_nrdconta => rw_craptdb.nrdconta
                          ,pr_nrinssac => rw_craptdb.nrinssac
                          ,pr_cdbandoc => rw_craptdb.cdbandoc
                          ,pr_nrdctabb => rw_craptdb.nrdctabb
                          ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                          ,pr_nrdocmto => rw_craptdb.nrdocmto
                          ,pr_tab_criticas => vr_tab_criticas
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);
         IF (vr_tab_criticas.count > 0) THEN
           vr_index_critica := vr_tab_criticas.first;
           WHILE vr_index_critica IS NOT NULL LOOP  
             vr_obj_crit_tit.put('codigo', vr_tab_criticas(vr_index_critica).cdcritica);
             vr_obj_crit_tit.put('descricao', vr_tab_criticas(vr_index_critica).dscritica);
             vr_lst_crit_tit.append(vr_obj_crit_tit.to_json_value());
             vr_index_critica := vr_tab_criticas.next(vr_index_critica);
           END LOOP;
         END IF;
          
         vr_ibratan := 'N';
         /*Verifica se possui alguma restricao, se existir, adiciona critica informando*/
         open cr_crapcbd (pr_nrinssac=>rw_craptdb.nrinssac);
         fetch cr_crapcbd into rw_crapcbd;
         IF (cr_crapcbd%FOUND) THEN
           SSPC0001.pc_verifica_situacao(rw_crapcbd.nrconbir,rw_crapcbd.nrseqdet,vr_cdbircon,vr_dsbircon,vr_cdmodbir,vr_dsmodbir,vr_ibratan);
         END IF;
         close cr_crapcbd;
         IF (vr_ibratan='S') THEN --possui restricao
           vr_obj_crit_tit.put('codigo', 21);
           vr_obj_crit_tit.put('descricao', dsct0003.fn_ds_critica(21));
           vr_lst_crit_tit.append(vr_obj_crit_tit.to_json_value());
         END IF; 
         
         vr_obj_titulos.put('criticas',vr_lst_crit_tit.to_json_value());
         vr_lst_titulos.append(vr_obj_titulos.to_json_value());

         -- limpar os objetos jason para pr�xima itera��o
         vr_obj_crit_tit := JSON();
         vr_lst_crit_tit := JSON_LIST();
     end loop;

     -- Armazenando lista no json de Border�
     vr_obj_bordero.put('titulos',vr_lst_titulos.to_json_value());
     vr_obj_bordero.put('titulosQuantidade'  , vr_qtde_titulos);

     vr_obj_bordero.put('parcelaQuantidade'  , 1);

     --> Data e hora da inclusao da proposta
     vr_data_aux := to_date(to_char(rw_crapbdt.dtmvtolt,'DD/MM/RRRR') ||' '||
                            to_char(to_date(rw_crapbdt.hrinclus,'SSSSS'),'HH24:MI:SS'),
                           'DD/MM/RRRR HH24:MI:SS');
     vr_obj_bordero.put('dataHora'           , este0001.fn_datatempo_ibra(vr_data_aux));

     vr_obj_bordero.put('produtoCreditoSegmentoCodigo'    , 6);
     vr_obj_bordero.put('produtoCreditoSegmentoDescricao' , 'Desconto de Titulo Bordero');

     vr_obj_bordero.put('linhaCreditoCodigo'    ,rw_crapbdt.cdlcremp);
     vr_obj_bordero.put('linhaCreditoDescricao' ,rw_crapbdt.dslcremp);
     --vr_obj_bordero.put('finalidadeCodigo'      ,rw_crawlim.cdfinemp);
     --vr_obj_bordero.put('finalidadeDescricao'   ,rw_crawlim.dsfinemp);

     vr_obj_bordero.put('tipoProduto'           ,rw_crapbdt.tpproduto);

     IF rw_crapbdt.tpctrato > 0 THEN
       vr_obj_bordero.put('tipoGarantiaCodigo'   , rw_crapbdt.tpctrato );
       vr_obj_bordero.put('tipoGarantiaDescricao', rw_crapbdt.dsctrato );
     END IF; 

     --    Buscar dados do operador
     open  cr_crapope;
     fetch cr_crapope into rw_crapope;
     if    cr_crapope%notfound then
           close cr_crapope;
           vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
           raise vr_exc_erro;
     end   if;
     close cr_crapope;

     vr_obj_bordero.put('loginOperador'         ,lower(rw_crapope.cdoperad));
     vr_obj_bordero.put('nomeOperador'          ,rw_crapope.nmoperad );

     vr_obj_bordero.put('parecerPreAnalise', 0);

         -- Verificar se usa tabela juros
         vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                  ,pr_nmsistem => 'CRED'
                                                  ,pr_tptabela => 'USUARI'
                                                  ,pr_cdempres => 11
                                                  ,pr_cdacesso => 'TAXATABELA'
                                                  ,pr_tpregist => 0);
         -- Se a primeira posi�ao do campo dstextab for diferente de zero
         vr_inusatab := substr(vr_dstextab,1,1) != '0';

         -- Busca endividamento do cooperado
         rati0001.pc_calcula_endividamento(pr_cdcooper   => pr_cdcooper     --> C�digo da Cooperativa
                                          ,pr_cdagenci   => pr_cdagenci     --> C�digo da agencia
                                          ,pr_nrdcaixa   => 0               --> N�mero do caixa
                                          ,pr_cdoperad   => pr_cdoperad     --> C�digo do operador
                                          ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de par�metro (CRAPDAT)
                                          ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                                          ,pr_dsliquid   => rw_crapbdt.dsliquid --> Lista de contratos a liquidar
                                          ,pr_idseqttl   => 1               --> Sequencia de titularidade da conta
                                          ,pr_idorigem   => 1 /*AYLLOS*/    --> Indicador da origem da chamada
                                          ,pr_inusatab   => vr_inusatab     --> Indicador de utiliza�ao da tabela de juros
                                          ,pr_tpdecons   => 3               --> Tipo da consulta 3 - Considerar a data atual
                                          ,pr_vlutiliz   => vr_vlutiliz     --> Valor da d�vida
                                          ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                                          ,pr_dscritic   => vr_dscritic);   --> Sa�da de erro
         --  Se houve erro
         if  nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
             raise vr_exc_erro;
         end if;

         vr_vllimdis := 0.0;
         vr_vlprapne := 0.0;
         for rw_crapass_cpfcgc in cr_crapass_cpfcgc(pr_nrcpfcgc => rw_crapass.nrcpfcgc)
         loop
             rw_crawepr_pend := null;
             open  cr_crawepr_pend;
             fetch cr_crawepr_pend into rw_crawepr_pend;
             close cr_crawepr_pend;

             vr_vlprapne := nvl(rw_crawepr_pend.vlemprst, 0) + vr_vlprapne;

             --> Selecionar o saldo disponivel do pre-aprovado da conta em questao  da carga ativa
             if  rw_crapass_cpfcgc.flgcrdpa = 1 then
                 rw_crapcpa := null;
                 open  cr_crapcpa;
                 fetch cr_crapcpa into rw_crapcpa;
                 close cr_crapcpa;
                 vr_vllimdis := nvl(rw_crapcpa.vllimdis, 0) + vr_vllimdis;
             end if;
         end loop;

         --> Buscando valor de border� aprovado e n�o efetivado
         vl_aprov_nefet := 0;
         FOR rw_border_nefet in cr_border_nefet (pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta => pr_nrdconta) LOOP
           vl_aprov_nefet := rw_border_nefet.totvltitulo;
         END LOOP;

         -- Na Esteira de Cr�dito o valor total do endividamento utilizado no fluxo de aprova��o ser� composto por:
         --   Valor do Endividamento da conta + valor do Border� que est� sendo inclusa + o valor de�Border�s aprovados e n�o efetivados.
         vr_obj_bordero.put('endividamentoContaValor'     ,(nvl(vr_vlutiliz,0) + nvl(vl_aprov_nefet,0)));

         vr_obj_bordero.put('propostasPendentesValor'     ,vr_vlprapne );
         vr_obj_bordero.put('limiteCooperadoValor'        ,nvl(vr_vllimdis,0) );

         -- Busca PDF gerado pela an�lise autom�tica do Motor
         vr_dsprotoc := este0001.fn_protocolo_analise_auto(pr_cdcooper => pr_cdcooper
                                                          ,pr_nrdconta => pr_nrdconta
                                                          ,pr_nrctremp => rw_crapbdt.nrctrlim);

         vr_obj_bordero.put('protocoloPolitica'          ,vr_dsprotoc);
         IF gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_ESTEIRA_HOMOL') IS NOT NULL THEN

           vr_obj_bordero.put('ambienteTemp','true');
           vr_obj_bordero.put('urlRetornoTemp', gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_ESTEIRA_HOMOL') );

         END IF;

         -- Copiar par�metro
         vr_nmarquiv := pr_nmarquiv;

         --  Caso nao tenhamos recebido o PDF
         if  vr_nmarquiv is null then
           -- Gerar ID aleat�rio
           vr_dsiduser := dbms_random.string('A', 27);

           DSCT0002.pc_gera_impressao_bordero(pr_cdcooper => pr_cdcooper,
                                              pr_cdagecxa => pr_cdagenci,
                                              pr_nrdcaixa => 0,
                                              pr_cdopecxa => pr_cdoperad,
                                              pr_nmdatela => 'ATENDA',
                                              pr_idorigem => 1, -- Ayllos
                                              pr_nrdconta => pr_nrdconta,
                                              pr_idseqttl => 1,
                                              pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                              pr_dtmvtopr => rw_crapdat.dtmvtopr,
                                              pr_inproces => rw_crapdat.inproces,
                                              pr_idimpres => 7,--desc de titulo
                                              pr_nrborder => pr_nrborder,
                                              pr_dsiduser => vr_dsiduser,
                                              pr_flgemail => 0,
                                              pr_flgerlog => 0,
                                              pr_flgrestr => 1, --> Indicador se deve imprimir restricoes(0-nao, 1-sim)
                                              pr_nmarqpdf => vr_nmarquiv,
                                              pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dscritic);

             if  trim(vr_dscritic) is not null then
                 raise vr_exc_erro;
             end if;

             vr_dsdirarq := gene0001.fn_diretorio(pr_tpdireto => 'C' --> cooper
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsubdir => '/rl');

             --  Se o arquivo nao existir, Remover o conteudo do nome do arquivo para nao enviar
             if  not gene0001.fn_exis_arquivo(vr_dsdirarq || '/' || vr_nmarquiv) then
                 vr_nmarquiv := null;
             end if;
         end if;

         if  vr_nmarquiv is not null then
             -- Converter arquivo PDF para clob em base64 para enviar via json
             este0001.pc_arq_para_clob_base64(pr_nmarquiv       => vr_dsdirarq || '/' || vr_nmarquiv
                                             ,pr_json_value_arq => vr_json_valor
                                             ,pr_dscritic       => vr_dscritic);
             if  trim(vr_dscritic) is not null then
                 raise vr_exc_erro;
             end if;

             -- Gerar objeto json para a imagem
             vr_obj_imagem.put('codigo'      , 'BORDERO_TITULO');
             vr_obj_imagem.put('conteudo'    ,vr_json_valor);
             vr_obj_imagem.put('emissaoData' , este0001.fn_data_ibra(sysdate));
             vr_obj_imagem.put('validadeData', '');
             -- incluir objeto imagem na proposta
             vr_lst_doctos.append(vr_obj_imagem.to_json_value());

             --  Caso o PDF tenha sido gerado nesta rotina, Temos de apag�-lo... Em outros casos o PDF � apagado na rotina chamadora
             if  vr_nmarquiv <> nvl(pr_nmarquiv,' ') then
                 gene0001.pc_oscommand_shell(pr_des_comando => 'rm '||vr_nmarquiv);
             end if;
         end if;

         --  Se encontrou PDF de an�lise Motor
         if  vr_dsprotoc is not null then
             -- Diretorio para salvar
             vr_dsdirarq := gene0001.fn_diretorio(pr_tpdireto => 'C' --> usr/coop
                                                 ,pr_cdcooper => 3
                                                 ,pr_nmsubdir => '/log/webservices');

             -- Utilizar o protocolo para nome do arquivo
             vr_nmarquiv := vr_dsprotoc || '.pdf';

             -- Comando para download
             vr_dscomando := gene0001.fn_param_sistema('CRED',3,'SCRIPT_DOWNLOAD_PDF_ANL');

             -- Substituir o caminho do arquivo a ser baixado
             vr_dscomando := replace(vr_dscomando, '[local-name]', vr_dsdirarq || '/' || vr_nmarquiv);

             -- Substiruir a URL para Download
             vr_dscomando := replace(vr_dscomando, '[remote-name]', gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                                             ,pr_cdacesso => 'HOST_WEBSRV_MOTOR_IBRA')||
                                                                    gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                                             ,pr_cdacesso => 'URI_WEBSRV_MOTOR_IBRA')||
                                                                    '_result/' || vr_dsprotoc || '/pdf');

             -- Executar comando para Download
             gene0001.pc_oscommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_dscomando);


             -- Se NAO encontrou o arquivo
             if  not gene0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq || '/' || vr_nmarquiv) then
                 vr_dscritic := 'Problema na recepcao do Arquivo - Tente novamente mais tarde!';
                 raise vr_exc_erro;
             end if;

             -- Converter arquivo PDF para clob em base64 para enviar via json
             este0001.pc_arq_para_clob_base64(pr_nmarquiv       => vr_dsdirarq || '/' || vr_nmarquiv
                                             ,pr_json_value_arq => vr_json_valor
                                             ,pr_dscritic       => vr_dscritic);
             if  trim(vr_dscritic) is not null then
                 raise vr_exc_erro;
             end if;

             -- Gerar objeto json para a imagem
             vr_obj_imagem.put('codigo'      ,'RESULTADO_POLITICA');
             vr_obj_imagem.put('conteudo'    ,vr_json_valor);
             vr_obj_imagem.put('emissaoData' ,este0001.fn_data_ibra(sysdate));
             vr_obj_imagem.put('validadeData','');

             -- incluir objeto imagem na proposta
             vr_lst_doctos.append(vr_obj_imagem.to_json_value());

             -- Temos de apag�-lo... Em outros casos o PDF � apagado na rotina chamadora
             gene0001.pc_oscommand_shell(pr_des_comando => 'rm ' || vr_dsdirarq || '/' || vr_nmarquiv);
         end if;

         -- Incluiremos os documentos ao json principal
         vr_obj_bordero.put('documentos',vr_lst_doctos);

     vr_obj_bordero.put('contratoNumero'     ,rw_crapbdt.nrborder);

     -- Verificar se a conta � de colaborador do sistema Cecred
     vr_cddcargo := null;
     open  cr_tbcolab;
     fetch cr_tbcolab into vr_cddcargo;
     if    cr_tbcolab%found then
           vr_flgcolab := true;
     else
           vr_flgcolab := false;
     end   if;
     close cr_tbcolab;

     -- Enviar tag indicando se � colaborador
     vr_obj_bordero.put('cooperadoColaborador',vr_flgcolab);

     --  Enviar o cargo somente se colaborador
     if  vr_flgcolab then
         vr_obj_bordero.put('codigoCargo',vr_cddcargo);
     end if;

     -- Enviar nivel de risco no momento da criacao
     vr_obj_bordero.put('classificacaoRisco',rw_crapbdt.dsnivris);

     -- Enviar flag se a proposta � de renogocia�ao
     vr_obj_bordero.put('renegociacao',(rw_crapbdt.dsliquid != '0,0,0,0,0,0,0,0,0,0'));

     --  BUscar faturamento se pessoa Juridica
     if  rw_crapass.inpessoa = 2 then
      -- Buscar faturamento
         open  cr_crapjfn;
         fetch cr_crapjfn into rw_crapjfn;
         close cr_crapjfn;
         vr_obj_bordero.put('faturamentoAnual',rw_crapjfn.vltotfat);
     end if;

     -- Devolver o objeto criado
     pr_bordero_envio := vr_obj_bordero;

  EXCEPTION
     when vr_exc_erro then
          if  nvl(vr_cdcritic,0) > 0 and trim(vr_dscritic) is null then
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          end if;

          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;

     when others then
          pr_cdcritic := 0;
          pr_dscritic := 'Nao foi possivel montar objeto json do border�: '||sqlerrm;

  END pc_gera_json_bordero;


END ESTE0006;
/
