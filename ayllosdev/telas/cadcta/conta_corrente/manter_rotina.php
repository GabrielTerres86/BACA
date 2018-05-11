<?php
/* FONTE        : manter_rotina.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 26/04/2010 
 * OBJETIVO     : Rotina para validar/alterar/excluir os dados da CONTA-CORRENTE da tela de CONTAS
 * 
 * ALTERACOES   : Adicionado confirmacao de impressao na chamada imprimeCritica(). (Jorge)
 *
 *  			        08/02/2013 - Incluir campo flgrestr em procedure grava_dados (Lucas R.)
 *
 *			  	      12/06/2013 - Consorcio (Gabriel).
 *
 *			  	      14/08/2013 - Alteração da sigla PAC para PA (Carlos).
 *
 *                28/05/2014 - Inclusao do campo Libera Credito Pre Aprovado 'flgcrdpa' (Jaison).
 *
 *			  	      10/07/2014 - Alterações para criticar propostas de cart. cred. em aberto durante exclusão de titulares 
 *                             (Lucas Lunelli - Projeto Bancoob).
 *
 *			  	      05/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *
 *                11/08/2015 - Projeto 218 - Melhorias Tarifas (Carlos Rafael Tanholi).
 *
 *				        27/10/2015 - Projeto 131 - Inclusão do campo “Exige Assinatura Conjunta em Autoatendimento” (Jean Michel).
 *
 *				        02/11/2015 - Melhoria 126 - Encarteiramento de cooperados (Heitor - RKAM).
 *
 *                05/01/2016 - Chamado 375708 - Estava permitindo selecionar o tipo de conta '-', gerando erro ao 
 *                             consultar a conta posteriormente.
 *
 *                07/01/2016 - Remover campo de Libera Credito Pre Aprovado (Anderson).
 *
 *			          15/07/2016 - Incluir rotina para atualizar o flg de devolução automatica - Melhoria 69(Lucas Ranghetti #484923)
 *
 *                01/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO não utiliza o mesmo (Renato Darosci)
 *
 *                03/05/2017 - Ajuste na chamada de Revisão Cadastral. (SD: 654355, Andrey Formigari - Mouts).
 *
 *                05/06/2017 - Alteração nas chamadas AJAX da revisão cadastral e no processo de salvar (CONTA-CORRENTE).
 *                             (Andrey Formigari - Mouts. SD 678767)
 */
    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();

	// Guardo os parâmetos do POST em variáveis
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;		
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '' ;		
	$cdagepac = (isset($_POST['cdagepac'])) ? $_POST['cdagepac'] : '' ;
	$cdsitdct = (isset($_POST['cdsitdct'])) ? $_POST['cdsitdct'] : '' ;
	$cdtipcta = (isset($_POST['cdtipcta'])) ? $_POST['cdtipcta'] : '' ;
	$cdbcochq = (isset($_POST['cdbcochq'])) ? $_POST['cdbcochq'] : '' ;
	$nrdctitg = (isset($_POST['nrdctitg'])) ? $_POST['nrdctitg'] : '' ;
	$cdagedbb = (isset($_POST['cdagedbb'])) ? $_POST['cdagedbb'] : '' ;
	$cdbcoitg = (isset($_POST['cdbcoitg'])) ? $_POST['cdbcoitg'] : '' ;
	$cdsecext = (isset($_POST['cdsecext'])) ? $_POST['cdsecext'] : '' ;
	$dtcnsscr = (isset($_POST['dtcnsscr'])) ? $_POST['dtcnsscr'] : '' ;
	$dtcnsspc = (isset($_POST['dtcnsspc'])) ? $_POST['dtcnsspc'] : '' ;
	$dtdsdspc = (isset($_POST['dtdsdspc'])) ? $_POST['dtdsdspc'] : '' ;
	$dtabtcoo = (isset($_POST['dtabtcoo'])) ? $_POST['dtabtcoo'] : '' ;
	$dtelimin = (isset($_POST['dtelimin'])) ? $_POST['dtelimin'] : '' ;
	$dtabtcct = (isset($_POST['dtabtcct'])) ? $_POST['dtabtcct'] : '' ;
	$dtdemiss = (isset($_POST['dtdemiss'])) ? $_POST['dtdemiss'] : '' ;
	$flgiddep = (isset($_POST['flgiddep'])) ? $_POST['flgiddep'] : '' ;
	$tpavsdeb = (isset($_POST['tpavsdeb'])) ? $_POST['tpavsdeb'] : '' ;
	$tpextcta = (isset($_POST['tpextcta'])) ? $_POST['tpextcta'] : '' ;
	$inadimpl = (isset($_POST['inadimpl'])) ? $_POST['inadimpl'] : '' ;
	$inlbacen = (isset($_POST['inlbacen'])) ? $_POST['inlbacen'] : '' ;
	$flgexclu = (isset($_POST['flgexclu'])) ? $_POST['flgexclu'] : '' ;
	$flgcreca = (isset($_POST['flgcreca'])) ? $_POST['flgcreca'] : '' ;			
	$flgrestr = (isset($_POST['flgrestr'])) ? $_POST['flgrestr'] : '' ;
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '' ;
	$indserma = (isset($_POST['indserma'])) ? $_POST['indserma'] : '' ;
    $idastcjt = (isset($_POST['idastcjt'])) ? $_POST['idastcjt'] : '' ;
    $cdcatego = (isset($_POST['cdcatego'])) ? $_POST['cdcatego'] : '' ;
	$cdconsul = (isset($_POST['cdconsul'])) ? $_POST['cdconsul'] : '' ; //Melhoria 126
	$cdageant = (isset($_POST['cdageant'])) ? $_POST['cdageant'] : '' ; //Melhoria 147
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '' ;

	$cdopecor        = (isset($_POST['cdopecor'])) ? $_POST['cdopecor'] : '' ; //Melhoria 69
	$flgdevolu_autom = (isset($_POST['flgdevolu_autom'])) ? $_POST['flgdevolu_autom'] : '' ; //Melhoria 69

	if( $operacao == 'AV' ) validaDados();
	
	if ( $operacao == 'VA' ) {
	  // Tipo de Conta
		if ( $GLOBALS['cdtipcta'] == '' ) exibirErro('error','Tipo de conta deve ser selecionado.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdtipcta\',\'frmContaCorrente\')',false); 
	}
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = '';
	switch ($operacao){
		case 'AV': $procedure = 'valida_dados'; $cddopcao = 'A'; $tpevento = 'A'; break;
		case 'VA': $procedure = 'grava_dados' ; $cddopcao = 'A'; $tpevento = 'A'; break;
		case 'VT': $procedure = 'valida_dados'; $cddopcao = 'E'; $tpevento = 'X'; break;
		case 'TE': $procedure = 'grava_dados' ; $cddopcao = 'E'; $tpevento = 'X'; break;
		case 'VG': $procedure = 'valida_dados'; $cddopcao = 'E'; $tpevento = 'E'; break;
		case 'GE': $procedure = 'grava_dados' ; $cddopcao = 'E'; $tpevento = 'E'; break;
		case 'VS': $procedure = 'valida_dados'; $cddopcao = 'S'; $tpevento = 'S'; break;
		case 'SE': $procedure = 'grava_dados' ; $cddopcao = 'S'; $tpevento = 'S'; break;
		case 'GC': $procedure = 'Gera_Conta_Consorcio' ; $cddopcao = 'A'; $tpevento = 'A'; break;
		case 'VE': $procedure = 'verifica_exclusao_titulares'; $cddopcao = 'A'; $tpevento = ''; break;
		case 'BC': $nmdeacao  = 'CADCON_CONSULTAR_AGENCIAS'; break;
		case 'EE': $nmdeacao  = 'ENVIA_EMAIL_TRANSFERENCIA_PA'; break;
		default: return false; 
		break;
	}
	
	if ($operacao == 'BC') { //Melhoria 126
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "  <Dados>";
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdconsultor>".$cdconsul."</cdconsultor>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = mensageria($xml, "CADCON", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");

		// Cria objeto para classe de tratamento de XML
		//$xmlObjeto = getObjectXML($xmlResult);
		$xmlObjeto = simplexml_load_string($xmlResult);
		
		// Se ocorrer um erro, mostra crítica
		if ($xmlObjeto->Erro->Registro->dscritic != "") {
			$msgErro = $xmlObjeto->Erro->Registro->dscritic;
			exibirErro("error",$msgErro,"Alerta - Ayllos","",false);
		}
		
		foreach($xmlObjeto->operador as $operador){
			echo "associaNomeConsultor('" . $operador->nmoperad ."');";
		}

		echo 'hideMsgAguardo();';
		//Fim Melhoria 126
	} else if ($operacao == 'EE') { //Melhoria 147
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "  <Dados>";
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<cdageant>".$cdageant."</cdageant>";
		$xml .= "		<cdagenci>".$cdagepac."</cdagenci>";
		$xml .= "  </Dados>";
		$xml .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = mensageria($xml, "CONTAS", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");

		// Cria objeto para classe de tratamento de XML
		//$xmlObjeto = getObjectXML($xmlResult);
		$xmlObjeto = simplexml_load_string($xmlResult);
		
		// Se ocorrer um erro, mostra crítica
		if ($xmlObjeto->Erro->Registro->dscritic != "") {
			$msgErro = $xmlObjeto->Erro->Registro->dscritic;
			exibirErro("error",$msgErro,"Alerta - Ayllos","",false);
		}
		
		echo 'hideMsgAguardo();';
		//Fim Melhoria 147
	} else {
		if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

		// Monta o xml dinâmico de acordo com a operação
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Cabecalho>';
		$xml .= '		<Bo>b1wgen0074.p</Bo>';
		$xml .= '		<Proc>'.$procedure.'</Proc>';
		$xml .= '	</Cabecalho>';
		$xml .= '	<Dados>';
		$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
		$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
		$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
		$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
		$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
		$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
		$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
		$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
		$xml .= '		<cdagepac>'.$cdagepac.'</cdagepac>';
		$xml .= '		<cdsitdct>'.$cdsitdct.'</cdsitdct>';	
		$xml .= '		<cdtipcta>'.$cdtipcta.'</cdtipcta>';
		$xml .= '		<cdbcochq>'.$cdbcochq.'</cdbcochq>';
		$xml .= '		<nrdctitg>'.$nrdctitg.'</nrdctitg>';
		$xml .= '		<cdagedbb>'.$cdagedbb.'</cdagedbb>';
		$xml .= '		<cdbcoitg>'.$cdbcoitg.'</cdbcoitg>';
		$xml .= '		<cdsecext>'.$cdsecext.'</cdsecext>';
		$xml .= '		<dtcnsscr>'.$dtcnsscr.'</dtcnsscr>';
		$xml .= '		<dtcnsspc>'.$dtcnsspc.'</dtcnsspc>';
		$xml .= '		<dtdsdspc>'.$dtdsdspc.'</dtdsdspc>';
		$xml .= '		<dtabtcoo>'.$dtabtcoo.'</dtabtcoo>';
		$xml .= '		<dtelimin>'.$dtelimin.'</dtelimin>';
		$xml .= '		<dtabtcct>'.$dtabtcct.'</dtabtcct>';
		$xml .= '		<dtdemiss>'.$dtdemiss.'</dtdemiss>';
		$xml .= '		<flgiddep>'.$flgiddep.'</flgiddep>';
		$xml .= '		<tpavsdeb>'.$tpavsdeb.'</tpavsdeb>';
		$xml .= '		<tpextcta>'.$tpextcta.'</tpextcta>';
		$xml .= '		<inadimpl>'.$inadimpl.'</inadimpl>';
		$xml .= '		<inlbacen>'.$inlbacen.'</inlbacen>';
		$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
		$xml .= '		<tpevento>'.$tpevento.'</tpevento>';
		$xml .= '		<flgexclu>'.$flgexclu.'</flgexclu>';
		$xml .= '		<flgcreca>'.$flgcreca.'</flgcreca>';
		$xml .= '		<flgrestr>'.$flgrestr.'</flgrestr>';
		$xml .= '		<indserma>'.$indserma.'</indserma>';
		$xml .= '		<idastcjt>'.$idastcjt.'</idastcjt>';
		$xml .= '		<cdcatego>'.$cdcatego.'</cdcatego>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xml);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjeto = getObjectXML($xmlResult);	
		
		// Se ocorrer um erro, mostra crítica
		if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
			$nmdcampo = ( isset($xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO']) ) ? $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'] : '';

			if ( $nmdcampo == "" ) {
				exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
			} else {
				exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina,\''.$nmdcampo.'\',\'frmContaCorrente\')',false);
			}
		}
    
		// Verificação da revisão Cadastral
		$msgAtCad = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGATCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'] : '';
		$chaveAlt = ( isset($xmlObjeto->roottag->tags[0]->attributes['CHAVEALT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'] : '';
		$tpAtlCad = ( isset($xmlObjeto->roottag->tags[0]->attributes['TPATLCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'] : '';

		// Se é Validação
		if( in_array($operacao,array('AV','VT','VG','VS','VE')) ) {
			$tipconfi = $xmlObjeto->roottag->tags[0]->attributes['TIPCONFI'];
			$msgconfi = $xmlObjeto->roottag->tags[0]->attributes['MSGCONFI'];

			if ( $operacao == 'VE' ) {	
				if ( $tipconfi == 1 ) {
					$registros = $xmlObjeto->roottag->tags[0]->tags;				
					for ($i = 0; $i < count($registros); $i++){
						echo "CriticasExcTitulares[".$i."] = '".$registros[$i]->tags[2]->cdata."';";
					}				
					
					echo "CriticasExcTitulares[CriticasExcTitulares.length] = '".$msgconfi."';";
					
					echo "exibeConfirmacao(0);";
					
				} else {
					echo 'hideMsgAguardo();';
					echo 'bloqueiaFundo(divRotina);';
				}
			} else {		
				if ( $operacao == 'AV' ) $opeconfi = 'VA';
				if ( $operacao == 'VT' ) $opeconfi = 'TE';
				if ( $operacao == 'VG' ) $opeconfi = 'GE';
				if ( $operacao == 'VS' ) $opeconfi = 'SE';
				echo 'flgcreca = "'.$xmlObjeto->roottag->tags[0]->attributes['FLGCRECA'].'";';			
				
				if ( $tipconfi == 0 || $tipconfi == 1 ) {			
					if ($operacao == 'VT') {
						echo 'msgconfi = "'.$msgconfi.'";';
						echo 'mostraTabelaTitulares();';
					} else {			
						if ( $tipconfi == 0 ) $msgconfi = 'Deseja confirmar altera&ccedil;&atilde;o?';			
						exibirConfirmacao($msgconfi,'Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao(\''.$opeconfi.'\')','bloqueiaFundo(divRotina)',false);
					}
				} else if ( $tipconfi == 2 ) {
					echo 'hideMsgAguardo();';
					echo "showConfirmacao('Deseja visualizar as cr&iacute;ticas?','Confirma&ccedil;&atilde;o - Ayllos','imprimeCritica(\'\');','bloqueiaFundo(divRotina)','sim.gif','nao.gif');";		
				}		
			}
		
		
		} else if ( in_array($operacao,array('GC') ) ) {
			
			$nrctacns = formataContaDVsimples($xmlObjeto->roottag->tags[0]->attributes['NRCTACNS']);
			
			 echo "$('#nrctacns','#frmContaCorrente').val (' $nrctacns ');";
			 echo 'hideMsgAguardo();';
			 echo 'bloqueiaFundo(divRotina);';

		}
		else { // Se é Inclusão	
			// Melhoria 126
		
				$nmdeacao = "CADCON_TRANSFERE_CONTA";

				$xml  = "";
				$xml .= "<Root>";
				$xml .= "  <Dados>";
				$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
				$xml .= '       <cdconsultordst>'.$cdconsul.'</cdconsultordst>';
				$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
				$xml .= '       <cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
				$xml .= "  </Dados>";
				$xml .= "</Root>";

				$nmrotina = $glbvars["nmrotina"];
				$glbvars["nmrotina"] = "CONTA CORRENTE";

				// Executa script para envio do XML
				$xmlResult = mensageria($xml, "CADCON", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");

				$xmlObjeto = simplexml_load_string($xmlResult);

				$glbvars["nmrotina"] = $nmrotina;

				if ($xmlObjeto->Erro->Registro->dscritic != "") {
					$msgErro = $xmlObjeto->Erro->Registro->dscritic;
					exibirErro("error",$msgErro,"Alerta - Ayllos","",false);
				
			}
			//Fim Melhoria 126

	        // Melhoria 69
			$xml  = "";
			$xml .= "<Root>";
			$xml .= "  <Dados>";
			$xml .= '       <cddopcao>A</cddopcao>';
			$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
			$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
			$xml .= '       <flgdevolu_autom>'.$flgdevolu_autom.'</flgdevolu_autom>';
			$xml .= '       <cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
			$xml .= '       <cdopecor>'.$cdopecor.'</cdopecor>';
			$xml .= "  </Dados>";
			$xml .= "</Root>";

			// Executa script para envio do XML
			$xmlResult = mensageria($xml, "GRAVA_DEVOLU_AUTOM", 'GRAVA_DEVOLU_AUTOM_XML', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");
			$xmlObjeto1 = getObjectXML($xmlResult); 
			
			//-----------------------------------------------------------------------------------------------
			// Controle de Erros
			//-----------------------------------------------------------------------------------------------
			if(strtoupper($xmlObjeto1->roottag->tags[0]->name == 'ERRO')){	
			
				$msgErro = $xmlObjeto1->roottag->tags[0]->cdata;
				$nmdcampo = $xmlObjeto1->roottag->tags[0]->attributes["NMDCAMPO"];					
				
				if($msgErro == null || $msgErro == ''){
					$msgErro = $xmlObjeto1->roottag->tags[0]->tags[0]->tags[4]->cdata;
				}								
				exibirErro('error',$msgErro,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);								
			} 			
			//Fim melhoria 69
			
			// Verificar se existe "Verificacaoo de Revisão Cadastral"
			$stringArrayMsg = "";
			if ($msgAtCad != '' && $flgcadas != 'M') {
				exibirConfirmacao($msgAtCad,'Confirma&ccedil;&atilde;o - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0074.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"OC\")\')',false);
			} else {
				echo 'controlaOperacao(\''.$opeconfi.'\')';
			}
		} 
	}
	
	function validaDados() {			
		// No início das validações, primeiro remove a classe erro de todos os campos
		echo '$("input","#frmContaCorrente").removeClass("campoErro");';
	
		// PA
		if ( $GLOBALS['cdagepac'] == '' ) exibirErro('error','PA deve ser informado.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdagepac\',\'frmContaCorrente\')',false); 
		
		// Situação
		if ( $GLOBALS['cdsitdct'] == '' ) exibirErro('error','Situação deve ser selecionada.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdsitdct\',\'frmContaCorrente\')',false); 
		
		// Tipo de Conta
		if ( $GLOBALS['cdtipcta'] == '' ) exibirErro('error','Tipo de conta deve ser selecionado.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdtipcta\',\'frmContaCorrente\')',false); 
		
		// Categoria
		if ( $GLOBALS['inpessoa'] == 1 && $GLOBALS['cdcatego'] == '') exibirErro('error','Categoria deve ser informada.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdcatego\',\'frmContaCorrente\')',false); 
		
		// Banco emi. cheque
		if ( ($GLOBALS['cdbcochq'] == '') ) exibirErro('error','Banco emissão do cheque deve ser informado.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdbcochq\',\'frmContaCorrente\')',false);
		
		// Destino extrato
		if ( ($GLOBALS['cdsecext'] == '') ) exibirErro('error','Destino extrato deve ser informado.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdsecext\',\'frmContaCorrente\')',false);	
	}
?>