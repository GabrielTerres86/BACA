<?php
/*!
 * FONTE        : verifica_logrbc.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Novembro/2014
 * OBJETIVO     : Rotina que verifica se o registro pode ser cancelado - LOGRBC
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

	$retornoAposErro = 'btnVoltar2();';

	// Recebe o POST
	$rowid = (isset($_POST['rowid'])) ? $_POST['rowid'] : 0  ;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'X')) <> '') {
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
	$xml .= '		<rowid>'.$rowid.'</rowid>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "LOGRBC", "SOLCANC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

	// Recebendo os valores atraves de atriburos da TAG
	$idtpreme  = ( isset($xmlObjeto->roottag->tags[0]->attributes['IDTPREME']) ) ? $xmlObjeto->roottag->tags[0]->attributes['IDTPREME'] : '';
	$dtmvtolt  = ( isset($xmlObjeto->roottag->tags[0]->attributes['DTMVTOLT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['DTMVTOLT'] : '';
	$idopreto  = ( isset($xmlObjeto->roottag->tags[0]->attributes['IDOPRETO']) ) ? $xmlObjeto->roottag->tags[0]->attributes['IDOPRETO'] : '';
	$qtarquiv  = ( isset($xmlObjeto->roottag->tags[0]->attributes['QTARQUIV']) ) ? $xmlObjeto->roottag->tags[0]->attributes['QTARQUIV'] : '';
	$lsarquiv  = ( isset($xmlObjeto->roottag->tags[0]->attributes['LSARQUIV']) ) ? $xmlObjeto->roottag->tags[0]->attributes['LSARQUIV'] : '';

	// Atualiza os campos com as informacoes dos atributos retornados
	echo "<script>cTpremess.val('".$idtpreme."');</script>";
	echo "<script>cDtremess.val('".$dtmvtolt."');</script>";
	echo "<script>cIdopreto.val('".$idopreto."');</script>";

	// Guarda o rowid da remessa para ser pesquisada novamente
	echo "<script>cRowid.val('".$rowid."');</script>";
	
	if ($idopreto == "M") {
		
		// Ajustando os espacos para exibicao dos regitros
		$arrayArq = explode(',',str_replace('nbsp','&nbsp;',$lsarquiv));
		
		// Monta a TAG option dinamicamente
		for ($i = 0; $i < $qtarquiv; $i++) {
			echo "<script>$('#lsarqcan','#frmCab').append('<option value=".$arrayArq[$i].">".$arrayArq[$i]."</option>');</script>";
		}
	
		include('tab_eventos_multiplo.php');
	}

?>