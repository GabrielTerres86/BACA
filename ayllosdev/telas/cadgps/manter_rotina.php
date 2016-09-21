<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 08/05/2011 
 * OBJETIVO     : Rotina para manter as operações da tela CADGPS
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
		
	
	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : ''; 

	// Dados do cabecalho	
	$cdidenti = (isset($_POST['cdidenti'])) ? $_POST['cdidenti'] : 0; 
	$cddpagto = (isset($_POST['cddpagto'])) ? $_POST['cddpagto'] : 0; 	
	$chrvalid = '';	
	$posvalid = 0;	
	
	// Dados da conta	
	$tpcontri = ($_POST['tpcontri']!='null')? $_POST['tpcontri'] : 0;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0; 
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : 0; 

	// Dados do contribuinte
	$nmextttl = (isset($_POST['nmextttl'])) ? $_POST['nmextttl'] : '';
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0 ;

	// Dados do endereco
	$nrcepend = (isset($_POST['nrcepend'])) ? $_POST['nrcepend'] : 0 ;
	$dsendres = (isset($_POST['dsendres'])) ? $_POST['dsendres'] : '';
	$cdufresd = ($_POST['cdufresd']!='null')? $_POST['cdufresd'] : '';
	$nrendres = (isset($_POST['nrendres'])) ? $_POST['nrendres'] : 0 ;
	$complend = (isset($_POST['complend'])) ? $_POST['complend'] : '';
	$nrcxapst = (isset($_POST['nrcxapst'])) ? $_POST['nrcxapst'] : 0 ;
	$nmbairro = (isset($_POST['nmbairro'])) ? $_POST['nmbairro'] : '';
	$nmcidade = (isset($_POST['nmcidade'])) ? $_POST['nmcidade'] : '';

	// Outros dados
	$nrfonres = (isset($_POST['nrfonres'])) ? $_POST['nrfonres'] : '';
	$flgrgatv = ($_POST['flgrgatv']!='null') ? $_POST['flgrgatv'] : '';

	// debito
	$flgdbaut = ($_POST['flgdbaut']!='null')? $_POST['flgdbaut'] : '';
	$inpessoa = ($_POST['inpessoa']!='null')? $_POST['inpessoa'] : '';
	$nrctadeb = (isset($_POST['nrctadeb'])) ? $_POST['nrctadeb'] : 0 ; 
	$nmctadeb = (isset($_POST['nmctadeb'])) ? $_POST['nmctadeb'] : '' ;
	$vlrdinss = (isset($_POST['vlrdinss'])) ? str_ireplace('.','',$_POST['vlrdinss']): 0 ;
	$vloutent = (isset($_POST['vloutent'])) ? str_ireplace('.','',$_POST['vloutent']): 0 ;
	$vlrjuros = (isset($_POST['vlrjuros'])) ? str_ireplace('.','',$_POST['vlrjuros']): 0 ;
	$vlrtotal = (isset($_POST['vlrtotal'])) ? str_ireplace('.','',$_POST['vlrtotal']): 0 ;

	// Dependendo da operação, chamo uma procedure diferente
	$procedure 	= '';
	$mtdErro	= 'estadoInicial();';
	$mtdRetorno	= '';
	$flgcontr	= '';
	$nmrescop	= '';

	switch($operacao) {
		// Consulta
		case 'C1': $cddopcao = 'C';	$procedure = 'valida-autori-deb'; 	 $mtdRetorno = 'controlaOperacao();'; $chrvalid ='DEBITO'; 									break;
		case 'C2': $cddopcao = 'C';	$procedure = 'valida-identificador'; $mtdRetorno = 'controlaOperacao();'; $mtdErro  = "if ( $('#divRotina').css('visibility') == 'visible' ) { bloqueiaFundo( $('#divRotina') ); } "; 	break;
		case 'C3': $cddopcao = 'C';	$procedure = 'busca-assoc'; 		 $mtdRetorno = 'controlaOperacao();'; $flgcontr ='no';  									break;
		// Alteracao
		case 'A1': $cddopcao = 'A';	$procedure = 'valida-autori-deb'; 	 $mtdRetorno = 'controlaOperacao();'; $chrvalid ='DEBITO'; 									break;
		case 'A2': $cddopcao = 'A';	$procedure = 'valida-identificador'; $mtdRetorno = 'controlaOperacao();'; $mtdErro  = 'bloqueiaFundo( $(\'#divRotina\') );';  	break;
		case 'A3': $cddopcao = 'A';	$procedure = 'busca-assoc'; 		 $mtdRetorno = 'controlaOperacao();'; $flgcontr ='no';  									break;
		case 'A4': $cddopcao = 'A';	$procedure = 'valida-ins'; 			 $mtdRetorno = 'controlaOperacao();'; $posvalid = 4; 										break;
		case 'A5': $cddopcao = 'A';	$procedure = 'busca-assoc'; 		 $flgcontr   = 'yes'; 																		break;
		case 'A6': $cddopcao = 'A';	$procedure = 'valida-dados'; 		 $mtdRetorno = 'controlaOperacao();'; $mtdErro  = 'operacao=\'A5\';';						break;
		case 'A7': $cddopcao = 'A';	$procedure = 'valida-ins'; 			 $mtdRetorno = 'controlaOperacao();'; $posvalid = 2; 										break;
		case 'A8': $cddopcao = 'A';	$procedure = 'grava-dados'; 		 $mtdRetorno = 'estadoInicial();'; 															break;
		// Inclusao
		case 'I1': $cddopcao = 'I';	$procedure = 'valida-autori-deb'; 	 $mtdRetorno = 'controlaOperacao();'; $chrvalid ='DEBITO';  								break;
		case 'I2': $cddopcao = 'I';	$procedure = 'valida-ins'; 	 		 $mtdRetorno = 'controlaOperacao();'; $posvalid = 1;										break;
		case 'I8': $cddopcao = 'I';	$procedure = 'valida-identificador'; $mtdRetorno = 'controlaOperacao();'; 														break;
		case 'I3': $cddopcao = 'I';	$procedure = 'valida-ins'; 	 		 $mtdRetorno = 'controlaOperacao();'; $posvalid = 3;										break;
		case 'I4': $cddopcao = 'I';	$procedure = 'valida-ins'; 	 		 $mtdRetorno = 'controlaOperacao();'; $posvalid = 4;										break;
		case 'I5': $cddopcao = 'I';	$procedure = 'busca-assoc'; 		 $mtdRetorno = 'controlaOperacao();'; $flgcontr   = 'yes'; 									break;
		case 'I6': $cddopcao = 'I';	$procedure = 'valida-dados'; 		 $mtdRetorno = 'controlaOperacao();'; $mtdErro  = 'operacao=\'I5\';';						break;
		case 'I7': $cddopcao = 'I';	$procedure = 'grava-dados'; 		 $mtdRetorno = 'estadoInicial();'; 															break;
		// Debito
		case 'D1': $cddopcao = 'D';	$procedure = 'valida-autori-deb'; 	 $mtdRetorno = 'controlaOperacao();'; $chrvalid ='DEBITO'; 									break;
		case 'D2': $cddopcao = 'D';	$procedure = 'valida-identificador'; $mtdRetorno = 'controlaOperacao();'; $mtdErro  = 'bloqueiaFundo( $(\'#divRotina\') );'; 	break;
		case 'D3': $cddopcao = 'D';	$procedure = 'busca-assoc'; 		 $mtdRetorno = 'mostraDebitos();'; 	  $flgcontr ='no'; 										break;
		case 'D4': $cddopcao = 'D';	$procedure = 'busca-pagto-nome'; 	 $mtdRetorno = 'controlaOperacao()';  $posvalid = 2; 										break; 
		case 'D5': $cddopcao = 'D';	$procedure = 'valida-autori-deb'; 	 $mtdRetorno = 'bloqueiaFundo($(\'#divRotina\'));'; $mtdErro='bloqueiaFundo( $(\'#divRotina\') ); $(\'#inpessoa\',\'#frmCadgpsDebito\').focus();'; $chrvalid='AUTORI'; break;
		case 'D6': $cddopcao = 'D';	$procedure = 'valida-valores'; 		 $mtdRetorno = 'controlaOperacao();'; $mtdErro  ='bloqueiaFundo( $(\'#divRotina\') );'; 	break;
		case 'D7': $cddopcao = 'D';	$procedure = 'grava-dados'; 		 $mtdRetorno = 'estadoInicial();'; 															break;
		default: $mtdErro = 'estadoInicial();'; return false; break;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0093.p</Bo>";
	$xml .= "		<Proc>".$procedure."</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	//$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	//$xml  .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<nmrescop>".$glbvars["nmcooper"]."</nmrescop>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<cdidenti>".$cdidenti."</cdidenti>";
	$xml .= "		<cddpagto>".$cddpagto."</cddpagto>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "		<chrvalid>".$chrvalid."</chrvalid>";
	$xml .= "		<posvalid>".$posvalid."</posvalid>";
	$xml .= "		<tpcontri>".$tpcontri."</tpcontri>";
	$xml .= "		<flgrgatv>".$flgrgatv."</flgrgatv>";
	$xml .= "		<dsendres>".$dsendres."</dsendres>";
	$xml .= "		<nmbairro>".$nmbairro."</nmbairro>";
	$xml .= "		<nmcidade>".$nmcidade."</nmcidade>";
	$xml .= "		<nrcepend>".$nrcepend."</nrcepend>";
	$xml .= "		<cdufresd>".$cdufresd."</cdufresd>";
	$xml .= "		<nrendres>".$nrendres."</nrendres>";
	$xml .= "		<complend>".$complend."</complend>";
	$xml .= "		<nrcxapst>".$nrcxapst."</nrcxapst>";
	$xml .= "		<nrfonres>".$nrfonres."</nrfonres>";
	$xml .= "		<nmextttl>".$nmextttl."</nmextttl>";
	$xml .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml .= "		<flgdbaut>".$flgdbaut."</flgdbaut>";
	$xml .= "		<inpessoa>".$inpessoa."</inpessoa>";
	$xml .= "		<nrctadeb>".$nrctadeb."</nrctadeb>";
	$xml .= "		<nmctadeb>".$nmctadeb."</nmctadeb>";
	$xml .= "		<vlrdinss>".$vlrdinss."</vlrdinss>";
	$xml .= "		<vloutent>".$vloutent."</vloutent>";
	$xml .= "		<vlrjuros>".$vlrjuros."</vlrjuros>";
	$xml .= "		<vlrtotal>".$vlrtotal."</vlrtotal>";
	$xml .= "		<flgcontr>".$flgcontr."</flgcontr>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$msgErro	= str_ireplace('"','',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if ( !empty($nmdcampo) ) { $mtdErro = $mtdErro . " $('#".$nmdcampo."').focus();";  }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);

	}	
	
	// Coloca as informações no formulario
	if (in_array($operacao,array('C3','A3','D3'))) {
		echo "fechaRotina($('#divRotina'));";
		echo "$('#divRotina').html('');";	
		preencheForm($xmlObjeto->roottag->tags[0]->tags[0]->tags, $operacao);
	}
	
	// Faz a validaçao na procedure valida-ins na alteração e inclusão
	if ($operacao == 'A4' or $operacao == 'I4') {
		$flgconti = $xmlObjeto->roottag->tags[0]->attributes['FLGCONTI'];
		$inpessoa = $xmlObjeto->roottag->tags[0]->attributes['INPESSOA'];
		
		if ( $flgconti == 'yes' and $nrdconta <> 0 and $inpessoa <> 2 ) {
			echo "fConta.desabilitaCampo();";
			echo "$('#idseqttl','#frmCadgps').habilitaCampo().focus();";
			if ( $operacao == 'I4' ) {
				echo "trocaBotao( 'concluir' );";
			}
		} 

	}
	
	// Busca associado na alteração e inclusão 
	if ( $operacao == 'A5' or $operacao == 'I5' ) {
		$flgexass = $xmlObjeto->roottag->tags[0]->attributes['FLGEXASS'];
		$msgretor = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];
		
		if ($flgexass == 'yes') {
			if (!empty($msgretor)) {
				$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
				exibirErro('error',$msgretor,'Alerta - Ayllos',$mtdErro,false);

			} else {
				preencheForm($xmlObjeto->roottag->tags[0]->tags[0]->tags, $operacao);
				if ($operacao == 'A5') {
					echo "$('#flgrgatv','#frmCadgps').habilitaCampo().focus();";
					echo "trocaBotao( 'concluir' );";
				}
			}

		} else {
			$mtdRetorno = '';
		
			if ( $nrdconta == 0 ) {
				echo "$('#idseqttl','#frmCadgps').val('0');";
				echo "formataContribuinte();";
				echo "formataEndereco();";
				echo "formataOutro();";

			} else {
				$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
				exibirErro('error',$msgretor,'Alerta - Ayllos',$mtdErro,false);
			
			}
		}
	}
	
	// Pega o nome do titular da conta para a tela de debito
	if ($operacao == 'D4') {
		$nmprimtl  = $xmlObjeto->roottag->tags[0]->attributes["NMPRIMTL"];
		echo "$('#nmctadeb','#frmCadgpsDebito').val('".$nmprimtl."');";
	}

	// Habilita os campos depois de validar a conta na tela de debito
	if ($operacao == 'D5') {
		echo "$('#inpessoa','#frmCadgpsDebito').desabilitaCampo();";
		echo "$('#nrctadeb','#frmCadgpsDebito').desabilitaCampo();";
		echo "$('#vlrdinss','#frmCadgpsDebito').habilitaCampo().focus();";
		echo "$('#vloutent','#frmCadgpsDebito').habilitaCampo();";
		echo "$('#vlrjuros','#frmCadgpsDebito').habilitaCampo();";
	}
	
	//
	if ( $operacao != 'C3' ) {
		echo "hideMsgAguardo();";
	}
	
	
	echo $mtdRetorno;

	// Função que preenche o formulario	
	function preencheForm($registro, $operacao) {

		if ( $operacao == 'C3' and getByTagName($registro,'flgdbaut') == 'yes' ) {
			echo "mostraDebitos();";
		} else {
			echo "hideMsgAguardo();";		
		}
	
		// No cabecalho e conta nao recebe os valores retornado da xbo caso seja alteração e inserção
		// esses registros podem ter sido alterado pelo usuario, assim mudaria os valores.
		if ($operacao != 'A5' and $operacao != 'I5') {
			// Cabecalho
			echo "$('#cdidenti','#frmCabCadgps').val('".getByTagName($registro,'cdidenti')."');";
			echo "$('#cddpagto','#frmCabCadgps').val('".getByTagName($registro,'cddpagto')."');";

			// Conta
			echo "$('#tpcontri','#frmCadgps').val('".getByTagName($registro,'tpcontri')."');";
			echo "$('#nrdconta','#frmCadgps').val('".getByTagName($registro,'nrdconta')."').trigger('blur');";
			echo "$('#idseqttl','#frmCadgps').val('".getByTagName($registro,'idseqttl')."');";
		}

		// Contribuinte
		echo "$('#nrcpfcgc','#frmCadgps').val('".getByTagName($registro,'nrcpfcgc')."');";
		echo "$('#nmprimtl','#frmCadgps').val('".getByTagName($registro,'nmextttl')."');";
	
		// Endereco
		echo "$('#nrcepend','#frmCadgps').val('".formataCep(getByTagName($registro,'nrcepend'))."');";
		echo "$('#dsendere','#frmCadgps').val('".getByTagName($registro,'dsendres')."');";
		echo "$('#nrendere','#frmCadgps').val('".getByTagName($registro,'nrendres')."').trigger('blur');";
		echo "$('#complend','#frmCadgps').val('".getByTagName($registro,'complend')."');";
		echo "$('#nrcxapst','#frmCadgps').val('".getByTagName($registro,'nrcxapst')."').trigger('blur');";
		echo "$('#nmbairro','#frmCadgps').val('".getByTagName($registro,'nmbairro')."');";
		echo "$('#cdufresd','#frmCadgps').val('".getByTagName($registro,'cdufresd')."');";
		echo "$('#nmcidade','#frmCadgps').val('".getByTagName($registro,'nmcidade')."');";

		// Outros
		echo "$('#nrfonres','#frmCadgps').val('".getByTagName($registro,'nrfonres')."');";
		echo "$('#flgrgatv','#frmCadgps').val('".getByTagName($registro,'flgrgatv')."');";
		echo "$('#debito11','#frmCadgps').val('".getByTagName($registro,'flgdbaut')."');";
		
		
	}
	
?>