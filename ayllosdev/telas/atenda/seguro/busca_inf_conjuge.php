<? 
/*!
 * FONTE        : buscar_inf_conjuge.php
 * CRIA��O      : Michel M Candido
 * DATA CRIA��O : 21/09/2011
 * OBJETIVO     : montar o formul�rio com as informa��es de retorno, se n�o houver erro
 * ALTERAC��ES  : 20/12/2012 - Ajuste para verificar se o conjuge possui uma conta (Adriano).
 */
	session_start();
		
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
		
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}
		
	// Verifica se n�mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}


	// Monta o xml de requisi��o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0033.p</Bo>";
	$xml .= "		<Proc>buscar_inf_conjuge</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<nmdatela>".$glbvars['nmdatela']."</nmdatela>";
	$xml .= "       <idseqttl>1</idseqttl>";
	$xml .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";
	$xml .= "		<flgerlog>FALSE</flgerlog>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO' ) {
		$mtdErro = 'bloqueiaFundo(divRotina);';
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$mtdErro,false);
	}


	$conjuge  = $xmlObjeto->roottag->tags[0]->tags[0];
	$nrctacje = getByTagName($conjuge->tags,'nrctacje');

	$data = array();

	if($nrctacje > 0){
		// Monta o xml de requisi��o
		$xmlAsso  = "";
		$xmlAsso .= "<Root>";
		$xmlAsso .= "	<Cabecalho>";
		$xmlAsso .= "		<Bo>b1wgen0033.p</Bo>";
		$xmlAsso .= "		<Proc>buscar_associados</Proc>";
		$xmlAsso .= "	</Cabecalho>";
		$xmlAsso .= "	<Dados>";
		$xmlAsso .= "		<cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xmlAsso .= "		<cdagenci>0</cdagenci>";
		$xmlAsso .= "		<nrdcaixa>0</nrdcaixa>";
		$xmlAsso .= "		<cdoperad>".$glbvars['cdoperad']."</cdoperad>";
		$xmlAsso .= "		<dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";
		$xmlAsso .= "		<nrdconta>".$nrctacje."</nrdconta>";
		$xmlAsso .= "		<idseqttl>1</idseqttl>";
		$xmlAsso .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";
		$xmlAsso .= "		<nmdatela>".$glbvars['nmdatela']."</nmdatela>";
		$xmlAsso .= "		<flgerlog>FALSE</flgerlog>";
		$xmlAsso .= "	</Dados>";
		$xmlAsso .= "</Root>";

		// Executa script para envio do XML
		$xmlResultAsso = getDataXML($xmlAsso);

		// Cria objeto para classe de tratamento de XML
		$xmlObjetoAsso = getObjectXML($xmlResultAsso);

		if ( strtoupper($xmlObjetoAsso->roottag->tags[0]->name) == 'ERRO' ) {
				$mtdErro = 'bloqueiaFundo(divRotina);';
				exibirErro('error',$xmlObjetoAsso->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$mtdErro,false);
		}

		$associado  = $xmlObjetoAsso->roottag->tags[0]->tags[0];
		
		$nmconjug 		= getByTagName($associado->tags,'nmprimtl');
		$nrcpf 			= getByTagName($associado->tags,'nrcpfcgc');
		$dtnascimento 	= getByTagName($associado->tags,'dtnasctl');
		
		
	}else{
		$nmconjug 		= getByTagName($conjuge->tags,'nmconjug');
		$nrcpf 			= getByTagName($conjuge->tags,'nrcpfcjg');
		$dtnascimento 	= getByTagName($conjuge->tags,'dtnasccj');

	}
	
	echo "
		
		$('#nmdsegur').val('{$nmconjug}');
		$('#nrcpfcgc', '#forSeguro').val('{$nrcpf}');
		$('#dtnascsg').val('{$dtnascimento}');
		$('#nrcpfcgc', '#forSeguro').desabilitaCampo();
		nrcpfcgc = '{$nrcpf}';
		dtnascsg = '{$dtnascimento}';
		
	";
	



