<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 25/07/2011 
 * OBJETIVO     : Rotina para manter as operações da tela ALIENA
 * --------------
 * ALTERAÇÕES   : 21/11/2013 - Novas colunas GRAVAMES (Guilherme/SUPERO)
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
	
	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$operacao 		= (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ; 
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$nrdconta		= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ; 
	$idseqttl		= 0;
	$nrctrpro		= (isset($_POST['nrctrpro'])) ? $_POST['nrctrpro'] : '' ; 
	$nrctremp		= (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0  ; 
	$idseqbem		= (isset($_POST['idseqbem'])) ? $_POST['idseqbem'] : 0  ; 
	$flgalfid		= (isset($_POST['flgalfid'])) ? $_POST['flgalfid'] : '' ; 
	$dtvigseg		= (isset($_POST['dtvigseg'])) ? $_POST['dtvigseg'] : '' ; 
	$flglbseg		= (isset($_POST['flglbseg'])) ? $_POST['flglbseg'] : '' ; 
	$flgrgcar		= (isset($_POST['flgrgcar'])) ? $_POST['flgrgcar'] : '' ; 
	$flgperte		= (isset($_POST['flgperte'])) ? $_POST['flgperte'] : '' ; 
	$indice			= (isset($_POST['indice']))   ? $_POST['indice']   : 0  ; 

	// Dependendo da operação, chamo uma procedure diferente
	switch($operacao) {
		case 'V': $procedure = 'Valida_Dados'; 	$retornoAposErro = 'indice = indice + 1; controlaLayout();'; break;
		case 'G': $procedure = 'Grava_Dados'; 	break;
		default:  $retornoAposErro   = 'estadoInicial();'; return false; break;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0102.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<nrctrpro>'.$nrctrpro.'</nrctrpro>';
	$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';
	$xml .= '		<idseqbem>'.$idseqbem.'</idseqbem>';
	$xml .= '		<flgalfid>'.$flgalfid.'</flgalfid>';
	$xml .= '		<dtvigseg>'.$dtvigseg.'</dtvigseg>';
	$xml .= '		<flglbseg>'.$flglbseg.'</flglbseg>';
	$xml .= '		<flgrgcar>'.$flgrgcar.'</flgrgcar>';
	$xml .= '		<flgperte>'.$flgperte.'</flgperte>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		preencheArray('NAO');
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Verifica se retornou alguma mensagem e armazena	
	//----------------------------------------------------------------------------------------------------------------------------------
	$i 				= 0;
	$stringArrayMsg	= '';
	$mensagem  		= $xmlObjeto->roottag->tags[0]->tags;
	foreach ( $mensagem as $m ) {
		if (!empty($stringArrayMsg)) {
			$stringArrayMsg = getByTagName($m->tags,'dsmensag') . '|' .  $stringArrayMsg ;
		} else {
			$stringArrayMsg = getByTagName($m->tags,'dsmensag');
		}
		$i++;
	}

	if ( $i > 0 ) {
		echo 'mensagemAliena(\''.$stringArrayMsg.'\',\'manterRotina(\"G\")\');'; 
		exit();
	}
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Retorno
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( $operacao == 'V' ) {
		echo "manterRotina('G');";
	} else if ( $operacao == 'G' ) {
		preencheArray('SIM');
		echo "indice = indice + 1;";
		echo "controlaLayout();";
	}

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Preenche o array
	//----------------------------------------------------------------------------------------------------------------------------------
	function preencheArray($flag) {

		echo 'var aux = new Array();';
		echo 'var i = arrayAux.length;';
        //echo 'alert(i + \' - \' + arrayAliena[indice][\'dsbemfin\'] + \' - \' + indice);';
		echo 'aux[\'cdcooper\'] = arrayAliena[indice][\'cdcooper\'];';
		echo 'aux[\'nrdconta\'] = arrayAliena[indice][\'nrdconta\'];';
		echo 'aux[\'tpctrpro\'] = arrayAliena[indice][\'tpctrpro\'];';
		echo 'aux[\'nrctrpro\'] = arrayAliena[indice][\'nrctrpro\'];';
		echo 'aux[\'idseqbem\'] = arrayAliena[indice][\'idseqbem\'];';
		echo 'aux[\'dscatbem\'] = arrayAliena[indice][\'dscatbem\'];';
		echo 'aux[\'dsbemfin\'] = arrayAliena[indice][\'dsbemfin\'];';
		echo 'aux[\'flgperte\'] = arrayAliena[indice][\'flgperte\'];';
                echo 'aux[\'dtatugrv\'] = arrayAliena[indice][\'dtatugrv\'];';
                echo 'aux[\'tpinclus\'] = arrayAliena[indice][\'tpinclus\'];';
                echo 'aux[\'cdsitgrv\'] = arrayAliena[indice][\'cdsitgrv\'];';

		if ($flag == 'NAO') {
			echo 'aux[\'flgalfid\'] = arrayAliena[indice][\'flgalfid\'];';
			echo 'aux[\'dtvigseg\'] = arrayAliena[indice][\'dtvigseg\'];';
			echo 'aux[\'flglbseg\'] = arrayAliena[indice][\'flglbseg\'];';
			echo 'aux[\'flgrgcar\'] = arrayAliena[indice][\'flgrgcar\'];';
		} else {
			echo 'aux[\'flgalfid\'] = "'.$GLOBALS['flgalfid'].'";';
			echo 'aux[\'dtvigseg\'] = "'.$GLOBALS['dtvigseg'].'";';
			echo 'aux[\'flglbseg\'] = "'.$GLOBALS['flglbseg'].'";';
			echo 'aux[\'flgrgcar\'] = "'.$GLOBALS['flgrgcar'].'";';
		}
		
		// recebe nova
		echo 'arrayAux[i] = aux;';
	
	}	
?>