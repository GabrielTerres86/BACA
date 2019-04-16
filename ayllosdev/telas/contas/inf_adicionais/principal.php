<?php
/*!
 * FONTE        : principal.php
 * CRIA��O      : Rodolpho Telmo (DB1)
 * DATA CRIA��O : Abril/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de Inf. Adicionais da tela de CONTAS
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 *                06/08/2015 - Reformulacao Cadastral (Gabriel-RKAM)
 *                14/07/2016 - Correcao no tratamento da msg de retorno XML. SD 479874. Carlos R.
 *
 *                01/12/2016 - P341-Automatiza��o BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO n�o utiliza o mesmo (Renato Darosci)
 */	
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';
	
	$glbvars["nmrotina"] = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : $glbvars["nmrotina"];
	
	switch( $operacao ) {
		case 'CA': $op = "A"; break;
		case 'AC': $op = "@"; break;
		case ''  : $op = "@"; break;
		default  : $op = "@"; break;
	}
	
	// Verifica permiss�es de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op,false)) <> '') {
		$metodo =  ($flgcadas == 'M') ? 'proximaRotina();' : 'encerraRotina(false);';
		exibirErro('error',$msgError,'Alerta - Ayllos',$metodo,false);
	}
	
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	// Carrega permiss�es do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);

	$qtOpcoesTela = count($opcoesTela);

	// Carregas as op��es da Rotina de Bens
	$flgAlterar  = (in_array("A", $glbvars["opcoesTela"]));
	
	$nrdconta = $_POST['nrdconta'] == '' ? 0 : $_POST['nrdconta'];
	$idseqttl = $_POST['idseqttl'] == '' ? 0 : $_POST['idseqttl'];
	
	// Verifica se o n�mero da conta e o titular s�o inteiros v�lidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq. Titular n&atilde;o foi informada.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);	
	if ($idseqttl==0) exibirErro('error','Seq. Titular n&atilde;o foi informada.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0048.p</Bo>';
	$xml .= '		<Proc>obtem-informacoes-adicionais</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjFiliacao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjFiliacao->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
	
	$infAdicionais = $xmlObjFiliacao->roottag->tags[0]->tags[0]->tags;


	//------------
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResultModalidade = mensageria($xml, "ATENDA", "BUSCA_MODALIDADE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjModalidade = getObjectXML($xmlResultModalidade);

	if (strtoupper($xmlObjModalidade->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjModalidade->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjModalidade->roottag->tags[0]->cdata;
		}
		exibeErro($msgErro);
	}
	$modalidade = $xmlObjModalidade->roottag->tags[0]->cdata;
	//------------
	$nrinfcad = 0;
	$nrpatlvr = 0;
	if (!empty($infAdicionais)) {
		$nrinfcad = getByTagName($infAdicionais,'nrinfcad');
		$nrpatlvr = getByTagName($infAdicionais,'nrpatlvr');
	}
	// Se for conta salário e for inclusão
	if ($flgcadas == 'M' && $modalidade == 2) {
		$nrinfcad = 1;
		$nrpatlvr = 1;
	}
	
	$textareaTags = $xmlObjFiliacao->roottag->tags[0]->tags[0]->tags[3]->tags;
	
	// Se n�o retornou erro, ent�o pegar a mensagem de alerta do Progress na vari�vel msgAlert, para ser utilizada posteriormente
	$msgAlert = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) : '';	
	
	include('formulario_inf_adicionais.php');
?>
<script type='text/javascript'>
	msgAlert = '<? echo $msgAlert; ?>';
	operacao = '<? echo $operacao; ?>';	
	inpessoa = $('#inpessoa','#frmCabContas').val().substring(0,1);
	
	if (inpessoa == 1) {
		var flgAlterar   = "<? echo $flgAlterar;   ?>";
		var flgcadas     = "<? echo $flgcadas;     ?>";
		
		if (flgcadas == 'M' && operacao != 'CA') {
			controlaOperacao('CA');
		}
		
	}
	
	controlaLayout();
	
	if ( msgAlert != '' ) { 
		showError('inform',msgAlert,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaFoco();');
	}else{
		controlaFoco();
	}
</script>