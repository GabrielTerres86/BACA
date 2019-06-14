<?php
	/*!
	* FONTE        : consulta_contrato_associ.php
	* CRIAÇÃO      : Andre Santos - SUPERO
	* DATA CRIAÇÃO : Outubro/2014
	* OBJETIVO     : Rotina para buscar os contratos do associado
	* --------------
	* ALTERAÇÕES   : 29/07/2016 - Corrigi o uso da funcao split depreciada. SD 480705 (Carlos R.)
	* --------------
	*/

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	// Recebe o POST
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;

	$retornoAposErro = 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));cNrcpfcgc.habilitaCampo();focaCampoErro(\'nrcpfcgc\', \'frmCab\');';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "REAFOR", "CONTCTR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

	// Recebendo os valores atraves de atriburos da TAG
	$lstcontrato  = ( isset($xmlObjeto->roottag->tags[0]->attributes['LSTCONTRATO']) ) ? $xmlObjeto->roottag->tags[0]->attributes['LSTCONTRATO'] : '';
	$qtdcontrato  = ( isset($xmlObjeto->roottag->tags[0]->attributes['QTD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['QTD'] : 0;

	// Separando os contratos
	$arraycontrato = explode(',',$lstcontrato);

	// Monta a TAG option dinamicamente para cada contrato do associado
	for ($i = 0; $i < $qtdcontrato; $i++) {
		echo "$('#nrctremp','#frmCab').append('<option value=".str_replace('.',''
		                                                                  ,str_replace('-',''
																		  ,str_replace(' ','',$arraycontrato[$i]))).">".$arraycontrato[$i]."</option>');";
	}
?>