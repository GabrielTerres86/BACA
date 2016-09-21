<?
/*!
 * FONTE        : retorna_dados_reafor.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Outubro/2014
 * OBJETIVO     : Rotina para retornar os dados a serem atualizados - REAFOR
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>

<?
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	// Recebe o POST
	$rowid    = (isset($_POST['rowid'])) ? $_POST['rowid'] : ' '  ;

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
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<rowid>'.$rowid.'</rowid>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "REAFOR", "RETEFOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')));consultaDadosReafor();",false);
	}

	$nrcpfcgc  = $xmlObjeto->roottag->tags[0]->attributes['NRCPFCGC'];
	$nrdconta  = $xmlObjeto->roottag->tags[0]->attributes['NRDCONTA'];
	$nrctremp  = $xmlObjeto->roottag->tags[0]->attributes['NRCTREMP'];
	$nmprimtl  = $xmlObjeto->roottag->tags[0]->attributes['NMPRIMTL'];
	$lstconta  = $xmlObjeto->roottag->tags[0]->attributes['LSTCONTA'];
	$qtcontas  = $xmlObjeto->roottag->tags[0]->attributes['QTCONTAS'];
	$lstcontrato  = $xmlObjeto->roottag->tags[0]->attributes['LSTCONTRATO'];
	$qtdcontrato  = $xmlObjeto->roottag->tags[0]->attributes['QTD'];

	// Separando as contas do associado
	$arrayconta = split(',',$lstconta);

	// Separando os contratos
	$arraycontrato = split(',',$lstcontrato);

	// Exibe o nome do associado no campod da tela
	echo "$('#nrcpfcgc','#frmCab').val('".$nrcpfcgc."');";

	// Exibe o nome do associado no campod da tela
	echo "$('#nmprimtl','#frmCab').val('".$nmprimtl."');";

	// Monta a TAG option dinamicamente para cada conta do associado
	for ($i = 0; $i < $qtcontas; $i++) {
		if (str_replace('.','',$arrayconta[$i]) == str_replace('.','',$nrdconta)) {
			echo "$('#nrdconta','#frmCab').append('<option selected value=".str_replace('.','',$arrayconta[$i]).">".$arrayconta[$i]." </option>');";
		}else{
		    echo "$('#nrdconta','#frmCab').append('<option value=".str_replace('.','',$arrayconta[$i]).">".$arrayconta[$i]."</option>');";
		}
	}

	// Monta a TAG option dinamicamente para cada contrato do associado
	for ($i = 0; $i < $qtdcontrato; $i++) {
		if (str_replace('.','',$arraycontrato[$i]) == str_replace('.','',$nrctremp)) {
			echo "$('#nrctremp','#frmCab').append('<option selected value=".str_replace('.','',str_replace('-','',str_replace(' ','',$arraycontrato[$i]))).">".$arraycontrato[$i]."</option>');";
		}else{
		    echo "$('#nrctremp','#frmCab').append('<option value=".str_replace('.','',str_replace('-','',str_replace(' ','',$arraycontrato[$i]))).">".$arraycontrato[$i]."</option>');";
		}
	}

	echo "$('#btIncluir','#divBotoes').show();";
	echo "cNrctremp.habilitaCampo();";
	echo "cNrctremp.focus();";
?>