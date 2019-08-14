<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 16/06/2011 
 * OBJETIVO     : Rotina para manter as operações da tela DCTROR
 * --------------
 * ALTERAÇÕES   : 24/06/2016 - Ajustado para chamar formulario de impressão para Opcao "A" (Lucas Ranghetti #448006 )
 * -------------- 
 *				  12/01/2017 - Incluir flprovis no array da custodia/desconto (Lucas Ranghetti #571653)
 *				  
 *				  09/08/2019 - Incluida mensagem de aviso quando é incluído um cheque compensado 
 *				  			   para contra-ordem. RITM0023830 (Lombardi)
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
	$procedure 	= '';
	$mtdErro	= '';
	$mtdRetorno	= '';
	$dsdctitg	= '';
	$posvalid	= '';

	// Recebe a operação que está sendo realizada
	$operacao 	= (isset($_POST['operacao']))  ? $_POST['operacao']  : '' ; 
	$controle 	= (isset($_POST['controle']))  ? $_POST['controle']  : '' ; 
	
	// Cabecalho
	$cddopcao 	= (isset($_POST['cddopcao']))  ? $_POST['cddopcao']  : '' ; 
	$tptransa 	= (isset($_POST['tptransa']))  ? $_POST['tptransa']  : '' ; 
	$nrdconta 	= (isset($_POST['nrdconta']))  ? $_POST['nrdconta']  : '' ; 
	$idseqttl	= 1;
	
	// Situacao
	$cdsitdtl	= (isset($_POST['cdsitdtl']))  ? $_POST['cdsitdtl']  : '' ; 
	$dtemscch	= (isset($_POST['dtemscch']))  ? $_POST['dtemscch']  : '' ; 
	$dtemscor	= (isset($_POST['dtemscor']))  ? $_POST['dtemscor']  : '' ; 
	
	// Banco
	$cdhistor 	= (isset($_POST['cdhistor']))  ? $_POST['cdhistor']  : '' ; 
	$cdbanchq 	= (isset($_POST['cdbanchq']))  ? $_POST['cdbanchq']  : '' ; 
	$cdagechq 	= (isset($_POST['cdagechq']))  ? $_POST['cdagechq']  : '' ; 
	$nrctachq 	= (isset($_POST['nrctachq']))  ? $_POST['nrctachq']  : '' ; 
	$nrinichq 	= (isset($_POST['nrinichq']))  ? $_POST['nrinichq']  : '' ; 
	$nrfinchq 	= (isset($_POST['nrfinchq']))  ? $_POST['nrfinchq']  : '' ; 

	// Senha
	$operauto 	= (isset($_POST['operauto']))  ? $_POST['operauto']  : '' ; 
	
	// Varivel de controle do caracter
	$tplotmov 	= (isset($_POST['tplotmov']))  ? $_POST['tplotmov']  : '' ;
	$dsdctitg	= (isset($_POST['dsdctitg']))  ? $_POST['dsdctitg']  : '' ;
	$camposDc 	= (isset($_POST['camposDc']))  ? $_POST['camposDc']  : '' ; // ContraOrdens
	$dadosDc 	= (isset($_POST['dadosDc']))   ? $_POST['dadosDc']   : '' ; // ContraOrdens
	$camposDc1 	= (isset($_POST['camposDc1'])) ? $_POST['camposDc1'] : '' ; // Custodia
	$dadosDc1 	= (isset($_POST['dadosDc1']))  ? $_POST['dadosDc1']  : '' ; // Custodia
	$cheques	= (!empty($_POST['cheques']))  ? unserialize($_POST['cheques']) : array()  ;
	
	$dtvalcor   = (isset($_POST['dtvalcor']))  ? $_POST['dtvalcor']  : '?' ;       // Sustacao Provisoria
    $flprovis   = (isset($_POST['flprovis']))  ? $_POST['flprovis']  : 'FALSE' ; // Sustacao Provisoria
	
	// Dependendo da operação, chamo uma procedure diferente
	switch($operacao) {
		// Consulta 
		case 'C21': $procedure = 'valida-agechq'; 	$mtdErro = 'cBanco.habilitaCampo().focus();';							break;
		case 'C22': $procedure = 'valida-ctachq'; 	$mtdErro = 'cNrChequeIni.habilitaCampo().focus();'; 					break;
		case 'C23': $procedure = 'busca-ctachq'; 	$mtdErro = 'btnVoltar()';		 										break;
						
		// Alteracao				
		case 'A21': $procedure = 'busca-ctachq'; 	$posvalid = '1'; 														break;
		case 'A22': $procedure = 'valida-agechq'; 	$mtdErro  = 'cBanco.habilitaCampo().focus();';							break;
		case 'A23': $procedure = 'valida-ctachq'; 	$mtdErro  = 'cNrChequeIni.habilitaCampo().focus();'; 					break;
		case 'A24': $procedure = 'busca-ctachq'; 	$posvalid = '2'; 	$mtdErro='estadoCabecalho()';						break;
		case 'A25': $procedure = 'valida-hist';  	$mtdErro  = 'cCdHistor.habilitaCampo();';								break;
		case 'A26': $procedure = 'grava-dados';  	$mtdErro  = 'cCdHistor.habilitaCampo();';	$stlcmexc = 2;  	$stlcmcad = 1; 		break;
	 
		// Exclusao
		case 'E11': $procedure = 'grava-dados'; 	$stlcmexc = 1; 		$stlcmcad = 2; 										break;
		case 'E31': $procedure = 'grava-dados'; 	$stlcmexc = 1; 		$stlcmcad = 2; 										break;
		case 'E21': $procedure = 'busca-ctachq'; 																			break;
		case 'E22': $procedure = 'valida-agechq';  	$mtdErro  = 'cBanco.habilitaCampo().focus();';							break;
		case 'E23': $procedure = 'valida-ctachq';  	$mtdErro  = 'cNrChequeFim.habilitaCampo();';							break;
		case 'E24': $procedure = 'busca-contra-ordens'; 	$mtdErro='btnVoltar()'; 										break;
		case 'E25': $procedure = 'valida-contra'; 												 							break;
		case 'E26': $procedure = 'grava-dados'; 	$stlcmexc = 1; 		$stlcmcad = 2; 			 							break;

		// Inclusao
		case 'I11': $procedure = 'grava-dados'; 	$stlcmexc = 2; 		$stlcmcad = 1;  	$mtdErro='cConta.focus();';		break;
		case 'I31': $procedure = 'grava-dados'; 	$stlcmexc = 2; 		$stlcmcad = 1; 		$mtdErro='cConta.focus();';		break;
		case 'I21': $procedure = 'busca-ctachq'; 																			break;
		case 'I22': $procedure = 'valida-agechq'; 	$mtdErro = 'cBanco.habilitaCampo().focus();';							break;
		case 'I23': $procedure = 'valida-ctachq'; 	$mtdErro = 'cNrChequeFim.habilitaCampo();';								break;
		case 'I24': $procedure = 'busca-contra-ordens'; 				$mtdErro = 'btnVoltar()'; 							break;
		case 'I25': $procedure = 'valida-contra'; 												 							break;
		case 'I26': $procedure = 'grava-dados'; 	$stlcmexc = 2; 		$stlcmcad = 1;			 							break;
		case 'I27': $procedure = 'valida-hist';  	$mtdErro  = 'cCdHistor.habilitaCampo();';								break;
	
		default:   $mtdErro   = 'estadoInicial();'; return false; 															break;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0095.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
    $xml .= '       <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<tptransa>'.$tptransa.'</tptransa>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<cdsitdtl>'.$cdsitdtl.'</cdsitdtl>';
	$xml .= '		<cdhistor>'.$cdhistor.'</cdhistor>';
	$xml .= '		<cdbanchq>'.$cdbanchq.'</cdbanchq>';
	$xml .= '		<cdagechq>'.$cdagechq.'</cdagechq>';
	$xml .= '		<nrctachq>'.$nrctachq.'</nrctachq>';
	$xml .= '		<nrinichq>'.$nrinichq.'</nrinichq>';
	$xml .= '		<nrfinchq>'.$nrfinchq.'</nrfinchq>'; // inclusao e exclusao
    $xml .= '       <dtemscch>'.$dtemscch.'</dtemscch>';
    $xml .= '       <stlcmexc>'.$stlcmexc.'</stlcmexc>'; // exclusao
    $xml .= '       <stlcmcad>'.$stlcmcad.'</stlcmcad>'; // inclusao
 	$xml .= '		<tplotmov>'.$tplotmov.'</tplotmov>';
	$xml .= '		<dsdctitg>'.$dsdctitg.'</dsdctitg>';
	$xml .= '		<posvalid>'.$posvalid.'</posvalid>';
	$xml .= '		<dtemscor>'.$dtemscor.'</dtemscor>';
	$xml .= '		<dtvalcor>'.$dtvalcor.'</dtvalcor>';
	$xml .= '		<flprovis>'.$flprovis.'</flprovis>';
	$xml .= '		<flgsenha>yes</flgsenha>'; // exclusao
	$xml .= '		<operauto>'.$operauto.'</operauto>'; // exclusao
	$xml .= 		retornaXmlFilhos( $camposDc, $dadosDc, 'ContraOrdens', 'Itens');
	$xml .=			xmlFilho($cheques,'Cheques','Itens');
	$xml .= 		retornaXmlFilhos( $camposDc1, $dadosDc1, 'Custodia', 'Itens');
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
		if (!empty($nmdcampo)) { $mtdErro = $mtdErro . "$('#".$nmdcampo."','#frmDctror').focus();";  }
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);
	}	
	
	// Consulta e Alteracao - valida-agechq
	if ( $operacao == 'C21' or $operacao == 'A22' ) {
		$aux_cdagechq = $xmlObjeto->roottag->tags[0]->attributes['CDAGECHQ'];

		echo "aux_cdagechq = '".$aux_cdagechq."';";
		echo "controlaLayout();";
	}
	
	// Consulta e Alteracao - Valida-ctachq
	if ( $operacao == 'C22'  or $operacao == 'A23' ) {
		$dsdctitg     = $xmlObjeto->roottag->tags[0]->attributes['DSDCTITG'];

		echo "dsdctitg = '".$dsdctitg."';";
		echo "controlaLayout();";
	}

	// Consulta e Alteracao - busca-ctachq
	if ( $operacao == 'C23' or $operacao == 'A24' ) {
		$aux_cdhistor = $xmlObjeto->roottag->tags[0]->attributes['CDHISTOR'];
		$aux_dtemscor = $xmlObjeto->roottag->tags[0]->attributes['DTEMSCOR'];
		$aux_nrfinchq = $xmlObjeto->roottag->tags[0]->attributes['NRFINCHQ'];
		$aux_dtvalcor = $xmlObjeto->roottag->tags[0]->attributes['DTVALCOR'];
        $aux_flprovis = $xmlObjeto->roottag->tags[0]->attributes['FLPROVIS'];

		//AQUI - Mostrar dtvalcor na tela.
		echo "aux_cdhistor = '".$aux_cdhistor."';";
		echo "aux_dtemscor = '".$aux_dtemscor."';";
		echo "aux_nrfinchq = '".$aux_nrfinchq."';";
		echo "aux_dtvalcor = '".$aux_dtvalcor."';";
        echo "aux_flprovis = '".$aux_flprovis."';";
		echo "controlaLayout();";

		if ( $operacao == 'A24' ) {
		    if ($aux_flprovis == 'yes' ) {
			exibirConfirmacao('Passar Contra-Ordem Provisória para Permanente?','Confirmação - Aimaro','setaFlag(0);','setaFlag(1);',false);
			}
		}
	}
	
	// Alteração - busca-ctachq
	if ( $operacao == 'A21' ) {
		echo "controlaLayout();";
	}

	// Alteração - Valida-hist
	if ( $operacao == 'A25' ) {

	    $tplotmov = $xmlObjeto->roottag->tags[0]->attributes['TPLOTMOV'];
		echo "tplotmov = '".$tplotmov."';";
		echo "controle = '6';";
		echo "operacao = 'A26';";
		exibirConfirmacao('Confirma a operação?','Confirmação - Aimaro','manterRotina();','estadoInicial();',false);
	}

	// Exclusao e Inclusão - Grava-dados
	if ( $operacao == 'E11' or $operacao == 'E31' or $operacao == 'I11' or $operacao == 'I31') {
		$aux_dssitdtl = $xmlObjeto->roottag->tags[1]->attributes['DSSITDTL'];
		$aux_cdsitdtl = $xmlObjeto->roottag->tags[1]->attributes['CDSITDTL']; 
		$aux_tpatlcad = $xmlObjeto->roottag->tags[1]->attributes['TPATLCAD']; 
		$aux_msgatcad = $xmlObjeto->roottag->tags[1]->attributes['MSGATCAD']; 
		$aux_chavealt = $xmlObjeto->roottag->tags[1]->attributes['CHAVEALT']; 		
		$aux_msgrecad = $xmlObjeto->roottag->tags[1]->attributes['MSGRECAD']; 		
		
		echo "aux_dssitdtl = '".$aux_dssitdtl."';";
		echo "aux_cdsitdtl = '".$aux_cdsitdtl."';";
		echo "aux_tpatlcad = '".$aux_tpatlcad."';";
		echo "aux_msgatcad = '".$aux_msgatcad."';";
		echo "aux_chavealt = '".$aux_chavealt."';";
		echo "aux_msgrecad = '".$aux_msgrecad."';";
		
		echo "controlaLayout();";
	}
	
	// Exclusao - Busca-ctachq
	if ( $operacao == 'E21' or $operacao == 'I21' ) {
		$aux_dtemscor = $xmlObjeto->roottag->tags[0]->attributes['DTEMSCOR'];
		echo "aux_dtemscor = '".$aux_dtemscor."';";
		echo "controlaLayout();";
	} 

	// Exclusao e Inclusão - Valida-agechq
	if ( $operacao == 'E22' or $operacao == 'I22' ) {
		$aux_cdagechq = $xmlObjeto->roottag->tags[0]->attributes['CDAGECHQ'];

		echo "aux_cdagechq = '".$aux_cdagechq."';";
		echo "controlaLayout();";
	}

	// Exclusao e Inclusão - Valida-ctachq
	if ( $operacao == 'E23' or $operacao == 'I23' ) {
		$dsdctitg = $xmlObjeto->roottag->tags[0]->attributes['DSDCTITG'];
		echo "dsdctitg = '".$dsdctitg."';";
		echo "controlaLayout();";
	}

	// Exclusao e Inclusão - Busca-contra-ordens
	if ( $operacao == 'E24' or $operacao == 'I24' ) {

		$registro = $xmlObjeto->roottag->tags[0]->tags[0]->tags;

		echo 'var aux = new Array();';
		echo 'var i = arrayDctror.length;';

		echo 'aux[\'cdhistor\'] = "'.getByTagName($registro,'cdhistor').'";';
		echo 'aux[\'cdbanchq\'] = "'.getByTagName($registro,'cdbanchq').'";';
		echo 'aux[\'cdagechq\'] = "'.getByTagName($registro,'cdagechq').'";';
		echo 'aux[\'nrctachq\'] = "'.getByTagName($registro,'nrctachq').'";';
		echo 'aux[\'nrinichq\'] = "'.getByTagName($registro,'nrinichq').'";';
		echo 'aux[\'nrfinchq\'] = "'.getByTagName($registro,'nrfinchq').'";';
		echo 'aux[\'nrdconta\'] = "'.getByTagName($registro,'nrdconta').'";';
        echo 'aux[\'flprovis\'] = "'.getByTagName($registro,'flprovis').'";';
		echo 'aux[\'dtvalcor\'] = "'.getByTagName($registro,'dtvalcor').'";';
		echo 'aux[\'dsprovis\'] = "'.getByTagName($registro,'dsprovis').'";';

		echo "aux_dtvalcor = '".getByTagName($registro,'dtvalcor')."';";
        echo "aux_dtemscor = '".getByTagName($registro,'dtemscor')."';";

		// recebe nova contra-ordem
		echo 'arrayDctror[i] = aux;';

		//bruno - prj 470 - tela autorizacao
		echo '
			if(typeof arrayDctror != "undefined"){
				if(arrayDctror.length > 0){
					__aux_arrayDctror = Array();
					$(arrayDctror).each(function(i, elem){
						__aux_arrayDctror.push(elem);
					});
				}
			}

		';
		
		if ($operacao == 'I24' && strlen(getByTagName($registro,'dtliqchq')) > 0) {
			echo 'hideMsgAguardo();';
			echo 'showError("error","Cheque j&aacute; pago, validar informa&ccedil;&otilde;es pela tela CHEQUE!","Alerta - Aimaro","controlaLayout();","NaN");';
		} else {		
			echo "controlaLayout();";
		}
	}

	// Exclusao e Inclusão - Valida contra
	if ( $operacao == 'E25' or $operacao == 'I25' ) {
		
		// Flag senha
		$aux_pedsenha = $xmlObjeto->roottag->tags[0]->attributes['PEDSENHA'];
		
		if ( $aux_pedsenha == 'yes' ) {
			echo "mostraSenha();";
			
		} else {

			/*************************
					TT CHEQUES
			**************************/
			$total_cheques	= count($xmlObjeto->roottag->tags[1]->tags);

			// Inicializa 
			$cheques = array();

			// Armazena os cheques
			for ( $i = 0; $i < $total_cheques; $i++ ) {
				
				$registro = $xmlObjeto->roottag->tags[1]->tags[$i]->tags;
				
				$cheques[$i]['cdbanchq'] = getByTagName($registro,'cdbanchq');
				$cheques[$i]['cdagechq'] = getByTagName($registro,'cdagechq');
				$cheques[$i]['nrctachq'] = getByTagName($registro,'nrctachq');
				$cheques[$i]['nrcheque'] = getByTagName($registro,'nrcheque');
				$cheques[$i]['nrinichq'] = getByTagName($registro,'nrinichq');
				$cheques[$i]['nrfinchq'] = getByTagName($registro,'nrfinchq');
				$cheques[$i]['nrdconta'] = getByTagName($registro,'nrdconta');
				$cheques[$i]['cdhistor'] = getByTagName($registro,'cdhistor');
				$cheques[$i]['dscritic'] = getByTagName($registro,'dscritic');
				$cheques[$i]['dtvalcor'] = getByTagName($registro,'dtvalcor');
				$cheques[$i]['dsprovis'] = getByTagName($registro,'dsprovis');
				$cheques[$i]['flprovis'] = getByTagName($registro,'flprovis');
			}
			
			if ( $total_cheques > 0 ) {
				// Serialize para enviar via ajax 
				echo "cheques='".serialize($cheques)."';";
			}
			
			/*************************
					TT CUSTODIA
			**************************/
			$total_custdesc	= count($xmlObjeto->roottag->tags[2]->tags);

			// Inicializa 
			$custdesc = array();
			echo 'var aux = new Array();';

			
			// Armazena os custdesc
			for ( $i = 0; $i < $total_custdesc; $i++ ) {
				
				$registro = $xmlObjeto->roottag->tags[2]->tags[$i]->tags;
				
				echo 'aux[\'nrdconta\'] = "'.getByTagName($registro,'nrdconta').'";';
				echo 'aux[\'nmprimtl\'] = "'.getByTagName($registro,'nmprimtl').'";';
				echo 'aux[\'dtliber1\'] = "'.getByTagName($registro,'dtliber1').'";';
				echo 'aux[\'cdpesqu1\'] = "'.getByTagName($registro,'cdpesqu1').'";';
				echo 'aux[\'dtliber2\'] = "'.getByTagName($registro,'dtliber2').'";';
				echo 'aux[\'cdpesqu2\'] = "'.getByTagName($registro,'cdpesqu2').'";';
				echo 'aux[\'cdbanchq\'] = "'.getByTagName($registro,'cdbanchq').'";';
				echo 'aux[\'cdagechq\'] = "'.getByTagName($registro,'cdagechq').'";';
				echo 'aux[\'nrctachq\'] = "'.getByTagName($registro,'nrctachq').'";';
				echo 'aux[\'nrcheque\'] = "'.getByTagName($registro,'nrcheque').'";';
				echo 'aux[\'flgselec\'] = "'.getByTagName($registro,'flgselec').'";';
				echo 'aux[\'flgcusto\'] = "'.getByTagName($registro,'flgcusto').'";';
				echo 'aux[\'flgdesco\'] = "'.getByTagName($registro,'flgdesco').'";';
				echo 'aux[\'cdhistor\'] = "'.getByTagName($registro,'cdhistor').'";';
				echo 'aux[\'flprovis\'] = "'.getByTagName($registro,'flprovis').'";';  				

				echo 'arrayCustdesc['.$i.'] = aux;';

			}
			
			if ( $total_custdesc > 0 ) {
				// Serialize para enviar via ajax 
				echo 'mostraCustdesc();';
			} else {			
				echo "controlaLayout();";
			}
		}
		
	}
	
	// // Exclusao e Inclusão - Grava-dados
	if ( $operacao == 'E26' || $operacao == 'I26' || $operacao == 'A26') {
		
		/*************************
				TT CRITICAS
		**************************/
		$total_criticas	= count($xmlObjeto->roottag->tags[0]->tags);

		// Inicializa 
		$criticas = array();
		
		// Armazena as criticas
		for ( $i = 0; $i < $total_criticas; $i++ ) {
			
			$registro = $xmlObjeto->roottag->tags[0]->tags[$i]->tags;
			
			$criticas[$i]['cdbanchq'] = getByTagName($registro,'cdbanchq');
			$criticas[$i]['cdagechq'] = getByTagName($registro,'cdagechq');
			$criticas[$i]['nrctachq'] = getByTagName($registro,'nrctachq');
			$criticas[$i]['nrcheque'] = getByTagName($registro,'nrcheque');
			$criticas[$i]['dscritic'] = getByTagName($registro,'dscritic');

		}
		
		if ( $total_criticas > 0 ) {
			// Serialize para enviar via ajax 
			echo "criticas='".serialize($criticas)."';";
		}
		
		/*************************
				TT CONTRA
		**************************/
		$total_contra	= count($xmlObjeto->roottag->tags[1]->tags);

		// Inicializa 
		$contra = array();

		// Armazena os contra
		for ( $i = 0; $i < $total_contra; $i++ ) {
			
			$registro = $xmlObjeto->roottag->tags[1]->tags[$i]->tags;

			$contra[$i]['cdhistor'] = getByTagName($registro,'cdhistor');
			$contra[$i]['nrinichq'] = getByTagName($registro,'nrinichq');
			$contra[$i]['nrfinchq'] = getByTagName($registro,'nrfinchq');
			$contra[$i]['nrctachq'] = getByTagName($registro,'nrctachq');
			$contra[$i]['cdbanchq'] = getByTagName($registro,'cdbanchq');
			$contra[$i]['cdagechq'] = getByTagName($registro,'cdagechq');
			$contra[$i]['nrdconta'] = getByTagName($registro,'nrdconta');
			$contra[$i]['flprovis'] = getByTagName($registro,'flprovis');
			$contra[$i]['dsprovis'] = getByTagName($registro,'dsprovis');
			$contra[$i]['dtvalcor'] = getByTagName($registro,'dtvalcor');

			if ($contra[$i]['flprovis'] == 'no' ){
				echo "aux_imprimir = 'SIM';";
			}

		}
		
		if ( $total_contra > 0 ) {
			// Serialize para enviar via ajax 
			echo "contra='".serialize($contra)."';";
		}			
		
		echo "controlaLayout();";	
	}
	
	if ( $operacao == 'I27' ) {
		echo "hideMsgAguardo();";
		echo "operacao ='I22';";
		echo "cCdHistor.desabilitaCampo();";
		echo "cBanco.habilitaCampo().focus();";	
	}
	
?>