<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 21/06/2011 
 * OBJETIVO     : Rotina para manter as operações da tela MANTAL
 * --------------
 * ALTERAÇÕES   : 06/06/2016 - Adicionar .focus no metodo de erro (Lucas Ranghetti #462172)
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
	$mtdErro		= '';
	$mtdRetorno		= '';
	$nmdcampo 		= '';

	
	// Recebe a operação que está sendo realizada
	$operacao 		= (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ; 
	
	// Cabecalho
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 	
	$nrdconta		= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ; 	
	$idseqttl		= 1 ; 	

	// Banco
	$nrctachq		= (isset($_POST['nrctachq'])) ? $_POST['nrctachq'] : 0 ; 	
	$cdbanchq		= (isset($_POST['cdbanchq'])) ? $_POST['cdbanchq'] : 0 ; 	
	$cdagechq		= (isset($_POST['cdagechq'])) ? $_POST['cdagechq'] : 0 ; 	
	$nrinichq 		= (isset($_POST['nrinichq'])) ? $_POST['nrinichq'] : 0 ; 
	$nrfimchq		= (isset($_POST['nrfimchq'])) ? $_POST['nrfimchq'] : 0 ; 	

	//
	$nriniche		= (isset($_POST['nriniche'])) ? $_POST['nriniche'] : 0 ;
	$nrfimche		= (isset($_POST['nrfimche'])) ? $_POST['nrfimche'] : 0 ;
	
	//
	$imp_cheques	= (!empty($_POST['imp_cheques'])) 	? unserialize($_POST['imp_cheques']) : array()  ;
	$imp_criticas	= (!empty($_POST['imp_criticas']))	? unserialize($_POST['imp_criticas']) : array() ;
	
	
	// Dependendo da operação, chamo uma procedure diferente
	switch($operacao) {

		case 'B1': $procedure = 'Busca_Agencia'; $mtdErro = "cBanco.habilitaCampo().focus(); cAgencia.val('0');"; 	break;
		case 'D1': $procedure = 'Busca_Agencia'; $mtdErro = "cBanco.habilitaCampo().focus(); cAgencia.val('0');"; 	break;

		case 'B2': $procedure = 'Valida_Dados';  $mtdErro = "cNrChequeFim.habilitaCampo().focus();";				break;
		case 'D2': $procedure = 'Valida_Dados';  $mtdErro = "cNrChequeFim.habilitaCampo().focus();";				break;

		case 'B3': $procedure = 'Grava_Dados';   $mtdErro = 'estadoInicial();';								break;
		case 'D3': $procedure = 'Grava_Dados';   $mtdErro = 'estadoInicial();';								break;
			
		default:   $mtdErro   = 'estadoInicial();'; return false; 											break;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0094.p</Bo>';
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
	$xml .= '		<nrctachq>'.$nrctachq.'</nrctachq>';
	$xml .= '		<cdbanchq>'.$cdbanchq.'</cdbanchq>';
	$xml .= '		<cdagechq>'.$cdagechq.'</cdagechq>';
	$xml .= '		<nrinichq>'.$nrinichq.'</nrinichq>';
	$xml .= '		<nrfimchq>'.$nrfimchq.'</nrfimchq>';
	$xml .= '		<nriniche>'.$nriniche.'</nriniche>'; // parametro passado pelo valida-dados
	$xml .= '		<nrfimche>'.$nrfimche.'</nrfimche>'; // parametro passado pelo valida-dados
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if (!empty($nmdcampo)) { $mtdErro = $mtdErro . "focaCampoErro('".$nmdcampo."','frmMantal');"; }
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);
	}	
	
	// Busca agencia
	if ( $operacao == 'B1' or $operacao == 'D1' ) {
		$aux_cdagechq = $xmlObjeto->roottag->tags[0]->attributes['CDAGECHQ'];
		echo "aux_cdagechq = '".$aux_cdagechq."';";
		echo "controlaLayout();";
	}
	
	// Valida dados
	if ( $operacao == 'B2' or $operacao == 'D2' ) {

		// Recebe os atributos passado pelo valida-dados que ser autilizado no grava-dados
		$aux_nriniche = $xmlObjeto->roottag->tags[0]->attributes['NRINICHE'];
		$aux_nrfimche = $xmlObjeto->roottag->tags[0]->attributes['NRFIMCHE'];
		echo "aux_nriniche = '".$aux_nriniche."';";
		echo "aux_nrfimche = '".$aux_nrfimche."';";
		
		// Inicializa a cheque
		echo "cheque = '';";
		$c = array();
		
		// Pega o total de cheques com custodia/desconto retornados
		$total = count($xmlObjeto->roottag->tags[0]->tags);
		
		// Armazena os cheques em custodia/desconto
		for ( $i = 0; $i < $total; $i++ ) {
			$cheque = $xmlObjeto->roottag->tags[0]->tags[$i]->tags;
			$c[$i]['nrdconta'] = getByTagName($cheque,'nrdconta');
			$c[$i]['nmprimtl'] = getByTagName($cheque,'nmprimtl');
			$c[$i]['nrcheque'] = getByTagName($cheque,'nrcheque');
			$c[$i]['nrborder'] = getByTagName($cheque,'nrborder');
			$c[$i]['dtlibera'] = getByTagName($cheque,'dtlibera');
			$c[$i]['cdpesqui'] = getByTagName($cheque,'cdpesqui');
			$c[$i]['tpcheque'] = (getByTagName($cheque,'tpcheque') == 'C' ? 'Custodia' : (getByTagName($cheque,'tpcheque') == 'D' ? 'Desconto' : ''));
		}
		
		if ($total > 0) {
			echo "cheque='".serialize($c)."';";
		}
		
		echo "controlaLayout();";
	}

	
	// Grava dados 
	if ( $operacao == 'B3' or $operacao == 'D3' ) {

		/*************************
				  TABELA
		**************************/
		// Armazena as contra-ordens para visualizar na tabela
		echo 'var aux = new Array();';
		echo 'var i = arrayMantal.length;';

		echo 'aux[\'cdbanchq\'] = "'.$cdbanchq.'";'; // banco
		echo 'aux[\'cdagechq\'] = "'.$cdagechq.'";'; // agencia
		echo 'aux[\'nrctachq\'] = "'.$nrctachq.'";'; // contra cheque
		echo 'aux[\'nrinichq\'] = "'.$nrinichq.'";'; // inicial
		echo 'aux[\'nrfimchq\'] = "'.$nrfimchq.'";'; // final
		
		// recebe nova contra-ordem
		echo 'arrayMantal[i] = aux;';
		

		/*************************
			IMPRESSÃO CRITICAS
		**************************/
		// Pega o total de criticas para impressão
		$total = count($xmlObjeto->roottag->tags[0]->tags);
		
		// Armazena as criticas
		for ( $i = 0; $i < $total; $i++ ) {
		
			$criticas = $xmlObjeto->roottag->tags[0]->tags[$i]->tags;
			
			// Inicializa 
			$aux = array();

			$aux['cdbanchq'] = getByTagName($criticas,'cdbanchq');
			$aux['cdagechq'] = getByTagName($criticas,'cdagechq');
			$aux['nrctachq'] = getByTagName($criticas,'nrctachq');
			$aux['nrcheque'] = getByTagName($criticas,'nrcheque');
			$aux['cdcritic'] = getByTagName($criticas,'cdcritic');

			array_push($imp_criticas, $aux);

		}
			
		if ( $total > 0 ) {
			// Serialize para enviar via ajax na hora da impressão
			echo "imp_criticas='".serialize($imp_criticas)."';";		
		}
		
		
		/*************************
			IMPRESSÃO CHEQUES
		**************************/
		// Pega o total de cheques para impressão
		$total = count($xmlObjeto->roottag->tags[1]->tags);

		// Armazena os cheques
		for ( $i = 0; $i < $total; $i++ ) {
			$cheques = $xmlObjeto->roottag->tags[1]->tags[$i]->tags;

			// Inicializa 
			$aux = array();
			
			$aux['cdbanchq'] = getByTagName($cheques,'cdbanchq');
			$aux['cdagechq'] = getByTagName($cheques,'cdagechq');
			$aux['nrctachq'] = getByTagName($cheques,'nrctachq');
			$aux['nrcheque'] = getByTagName($cheques,'nrcheque');

			array_push($imp_cheques, $aux);
			
		}
		
		if ( $total > 0 ) {
			// Serialize para enviar via ajax na hora da impressão
			echo "imp_cheques='".serialize($imp_cheques)."';";		
		}
		
		//
		echo "controlaLayout();";
	}
	
	
?>