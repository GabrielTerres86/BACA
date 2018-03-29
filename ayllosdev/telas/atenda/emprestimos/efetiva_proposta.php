<? 
/*!
 * FONTE        : grava_dados_proposta.php
 * CRIA��O      : Marcelo L. Pereira (GATI)
 * DATA CRIA��O : 29/07/2011 
 * OBJETIVO     : Rotina de grava��o da aprova��o da proposta
 *
 *---------------------
 *      ALTERACOES
 *---------------------
 *
 * 000: [06/03/2012] Tiago: Incluido cdagenci e cdpactra.
 * 001: [18/11/2014] Jaison: Inclusao do parametro nrcpfope.
         17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) 	
 * 002: [05/03/2018] Reinert: Incluido validacao de bloqueio de garantia de emprestimo.
 */
?>
 
<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();
	
	// Guardo os par�metos do POST em vari�veis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
	$insitapv = (isset($_POST['insitapv'])) ? $_POST['insitapv'] : '';
	$dsobscmt = (isset($_POST['dsobscmt'])) ? $_POST['dsobscmt'] : '';
	$dtdpagto = (isset($_POST['dtdpagto'])) ? $_POST['dtdpagto'] : '';
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$idcobope = (isset($_POST['idcobope'])) ? $_POST['idcobope'] : '';
		
	if ($idcobope > 0){
				
		// Monta o xml dinâmico de acordo com a operação 
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <nmdatela>ATENDA</nmdatela>';
		$xml .= '       <idcobert>'.$idcobope.'</idcobert>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';

		$xmlResult = mensageria($xml, "BLOQ0001", "REVALIDA_BLOQ_GARANTIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto = getObjectXML($xmlResult);

		//----------------------------------------------------------------------------------------------------------------------------------	
		// Controle de Erros
		//----------------------------------------------------------------------------------------------------------------------------------
		if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
			echo "showConfirmacao('Garantia de aplica&ccedil;&atilde;o resgatada/bloqueada. Deseja alterar a proposta?', 'Confirma&ccedil;&atilde;o - Ayllos', 'controlaOperacao(\'A_NOVA_PROP\');', 'hideMsgAguardo(); bloqueiaFundo($(\'#divRotina\'))', 'sim.gif', 'nao.gif');";
			exit();
		}

	}

	// Monta o xml de requisi��o
	$xml  = "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0084.p</Bo>";
	$xml .= "		<Proc>grava_efetivacao_proposta</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";		
	$xml .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";		
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<flgerlog>true</flgerlog>";
	$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
	$xml .= "		<dtdpagto>".$dtdpagto."</dtdpagto>";
    $xml .= "		<nrcpfope>0</nrcpfope>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo($(\'#divRotina\'));',false);
	}
	
	$registros  = $xmlObj->roottag->tags[0]->tags;
	$mensagem = $xmlObj->roottag->tags[0]->attributes["MENSAGEM"];
	$retorno = "hideMsgAguardo(); $('#linkAba0').html('Principal');";
	$retorno .= "arrayRatings.length = 0;";
	foreach($registros as $indice => $registro)
	{
		$retorno .= 'var arrayRating'.$indice.' = new Object();
					 arrayRating'.$indice.'[\'dtmvtolt\'] = "'.getByTagName($registro->tags,'dtmvtolt').'";
					 arrayRating'.$indice.'[\'dsdopera\'] = "'.getByTagName($registro->tags,'dsdopera').'"; 
					 arrayRating'.$indice.'[\'nrctrrat\'] = "'.getByTagName($registro->tags,'nrctrrat').'"; 
					 arrayRating'.$indice.'[\'indrisco\'] = "'.getByTagName($registro->tags,'indrisco').'"; 
					 arrayRating'.$indice.'[\'nrnotrat\'] = "'.getByTagName($registro->tags,'nrnotrat').'"; 
					 arrayRating'.$indice.'[\'vlutlrat\'] = "'.getByTagName($registro->tags,'vlutlrat').'"; 
					 arrayRatings['.$indice.'] = arrayRating'.$indice.';';
	}
    
    if ($mensagem != '') {
	   $retorno .= 'exibirMensagens(\''.$mensagem.'\',\'controlaOperacao(\"RATING\")\');';
    }
	else{
	   $retorno .=  "controlaOperacao('T_C');";	
	}
    
	echo $retorno;

?>