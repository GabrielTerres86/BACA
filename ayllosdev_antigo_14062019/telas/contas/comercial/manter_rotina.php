<?php
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 12/03/2010 
 * OBJETIVO     : Rotina para validar/alterar os dados do CÔNJUGE da tela de CONTAS
 *
 * ALTERACOES   : 19/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
				  08/09/2015 - Adicionado função para remover caracteres inválidos SD 317628 (Kelvin)
				  23/12/2015 - #350828 Adicionada a operação para a aba PPE (Carlos) 
							  14/07/2016 - Correcao na forma de recuperacao das variaveis do XML. SD 479874. Carlos R. 
                              11/10/2017 - Removendo campo caixa postal (PRJ339 - Kelvin).								  
 */
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;	
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ; 
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '' ;	
	$cdnatopc = (isset($_POST['cdnatopc'])) ? $_POST['cdnatopc'] : '' ; 
	$cdocpttl = (isset($_POST['cdocpttl'])) ? $_POST['cdocpttl'] : '' ; 
	$tpcttrab = (isset($_POST['tpcttrab'])) ? $_POST['tpcttrab'] : '' ; 
	$cdempres = (isset($_POST['cdempres'])) ? $_POST['cdempres'] : '' ; 
	$nmextemp = (isset($_POST['nmextemp'])) ? $_POST['nmextemp'] : '' ; 
	$nrcpfemp = (isset($_POST['nrcpfemp'])) ? $_POST['nrcpfemp'] : '' ; 
	$dsproftl = (isset($_POST['dsproftl'])) ? $_POST['dsproftl'] : '' ; 
	$cdnvlcgo = (isset($_POST['cdnvlcgo'])) ? $_POST['cdnvlcgo'] : '' ; 
	$nrcadast = (isset($_POST['nrcadast'])) ? $_POST['nrcadast'] : '' ; 
	$cdturnos = (isset($_POST['cdturnos'])) ? $_POST['cdturnos'] : '' ; 
	$dtadmemp = (isset($_POST['dtadmemp'])) ? $_POST['dtadmemp'] : '' ; 
	$vlsalari = (isset($_POST['vlsalari'])) ? $_POST['vlsalari'] : '' ; 
	$endrect1 = (isset($_POST['endrect1'])) ? $_POST['endrect1'] : '' ; 
	$nrendcom = (isset($_POST['nrendcom'])) ? $_POST['nrendcom'] : '' ; 
	$complcom = (isset($_POST['complcom'])) ? $_POST['complcom'] : '' ; 
	$bairoct1 = (isset($_POST['bairoct1'])) ? $_POST['bairoct1'] : '' ; 
	$cepedct1 = (isset($_POST['cepedct1'])) ? $_POST['cepedct1'] : '' ; 
	$cidadct1 = (isset($_POST['cidadct1'])) ? $_POST['cidadct1'] : '' ; 
	$ufresct1 = ($_POST['ufresct1'] == 'null') ? '' : $_POST['ufresct1']; 
	$tpdrendi = (isset($_POST['tpdrendi'])) ? $_POST['tpdrendi'] : '' ; 
	$vldrendi = (isset($_POST['vldrendi'])) ? $_POST['vldrendi'] : '' ; 
	$tpdrend2 = (isset($_POST['tpdrend2'])) ? $_POST['tpdrend2'] : '' ; 
	$vldrend2 = (isset($_POST['vldrend2'])) ? $_POST['vldrend2'] : '' ; 
	$tpdrend3 = (isset($_POST['tpdrend3'])) ? $_POST['tpdrend3'] : '' ; 
	$vldrend3 = (isset($_POST['vldrend3'])) ? $_POST['vldrend3'] : '' ; 
	$tpdrend4 = (isset($_POST['tpdrend4'])) ? $_POST['tpdrend4'] : '' ; 
	$vldrend4 = (isset($_POST['vldrend4'])) ? $_POST['vldrend4'] : '' ; 
	$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '' ; 	
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '' ;
	$inpolexp = (isset($_POST['inpolexp'])) ? $_POST['inpolexp'] : '' ;
	$inpolexpAnt = (isset($_POST['inpolexpAnt'])) ? $_POST['inpolexpAnt'] : '' ;

															
	if( $operacao == 'AV' || $operacao == 'PPE') validaDados();	                            
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = "";
	switch($operacao) {
		case 'AV': $procedure = 'valida_dados'; $cddopcao = 'A'; break;				
		case 'VA': $procedure = 'grava_dados' ; $cddopcao = 'A'; break;
		case 'PPE': $procedure = 'valida_dados'; $cddopcao = 'A'; break;
		case 'PPE_ABA': $procedure = 'grava_dados'; $cddopcao = 'A'; break;
		default: return false;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],
									 $glbvars['nmrotina'],
									 $cddopcao)) <> '') {
		exibirErro('error', 'nmrotina: ' . $glbvars['nmrotina'] . ' ' . $msgError, 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)', false);
	}
	
	// Monta o xml dinâmico de acordo com a operação
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0075.p</Bo>";
	$xml .= "		<Proc>".$procedure."</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>"; 
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "       <nrdrowid>".$nrdrowid."</nrdrowid>";  	
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "       <cdnatopc>".$cdnatopc."</cdnatopc>";  
	$xml .= "       <cdocpttl>".$cdocpttl."</cdocpttl>";  
	$xml .= "       <tpcttrab>".$tpcttrab."</tpcttrab>";
	$xml .= "       <cdempres>".$cdempres."</cdempres>"; 
	$xml .= "       <nmextemp>".retiraAcentos(removeCaracteresInvalidos($nmextemp))."</nmextemp>";   
	$xml .= "       <nrcpfemp>".$nrcpfemp."</nrcpfemp>";   
	$xml .= "       <dsproftl>".$dsproftl."</dsproftl>";   
	$xml .= "       <cdnvlcgo>".$cdnvlcgo."</cdnvlcgo>";   
	$xml .= "       <nrcadast>".$nrcadast."</nrcadast>";   
	$xml .= "       <cdturnos>".$cdturnos."</cdturnos>";   
	$xml .= "       <dtadmemp>".$dtadmemp."</dtadmemp>";   
	$xml .= "       <vlsalari>".$vlsalari."</vlsalari>";   
	$xml .= "       <endrect1>".$endrect1."</endrect1>";   
	$xml .= "       <nrendcom>".$nrendcom."</nrendcom>";   
	$xml .= "       <complcom>".$complcom."</complcom>";   
	$xml .= "       <bairoct1>".$bairoct1."</bairoct1>";   
	$xml .= "       <cepedct1>".$cepedct1."</cepedct1>";   
	$xml .= "       <cidadct1>".$cidadct1."</cidadct1>";   
	$xml .= "       <ufresct1>".$ufresct1."</ufresct1>";   
	$xml .= "       <cxpotct1>". 0 ."</cxpotct1>";   
	$xml .= "       <tpdrendi>".$tpdrendi."</tpdrendi>";   
	$xml .= "       <vldrendi>".$vldrendi."</vldrendi>";   
	$xml .= "       <tpdrend2>".$tpdrend2."</tpdrend2>";   
	$xml .= "       <vldrend2>".$vldrend2."</vldrend2>";   
	$xml .= "       <tpdrend3>".$tpdrend3."</tpdrend3>";   
	$xml .= "       <vldrend3>".$vldrend3."</vldrend3>";   
	$xml .= "       <tpdrend4>".$tpdrend4."</tpdrend4>";   
	$xml .= "       <vldrend4>".$vldrend4."</vldrend4>"; 
	$xml .= "       <inpolexp>".$inpolexp."</inpolexp>"; 
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") 
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	$msg = Array();
	
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msgRetorno = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGRETOR']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'] : '';	
	$msgAlerta    = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'] : '';
	$msgRvcad   = (isset($xmlObjeto->roottag->tags[0]->attributes['MSGRVCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGRVCAD'] : '';
	
	if ($msgRetorno!='') $msg[] = $msgRetorno;
	if ($msgAlerta!='' ) $msg[] = $msgAlerta;
	if ($msgRvcad!='' )  $msg[] = $msgRvcad;
	
	$stringArrayMsg = implode( "|", $msg);
	
	// Verificação da revisão Cadastral
	$msgAtCad = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGATCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'] : '';
	$chaveAlt = ( isset($xmlObjeto->roottag->tags[0]->attributes['CHAVEALT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'] : '';
	$tpAtlCad = ( isset($xmlObjeto->roottag->tags[0]->attributes['TPATLCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'] : '';
	
	if ($operacao == 'AV' || $operacao == 'PPE') {
		
		if ($operacao == 'AV') {
			exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Aimaro','controlaOperacao(\'VA\')','bloqueiaFundo(divRotina)',false);	
		}
		if ($operacao == 'PPE') {			
			exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Aimaro','controlaOperacao(\'PPE_ABA\')','bloqueiaFundo(divRotina)',false);	
		}
	// Se é Alteração
	} else {
	
		// Verificar se existe "Verificação de Revisão Cadastral"
		if($msgAtCad!='' && $flgcadas != 'M') {			
			
			if( $operacao == 'VA' ) 
			exibirConfirmacao($msgAtCad,
			'Confirmação - Aimaro',
			'revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0075.p\',\''.$stringArrayMsg.'\')',
			'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);

			if( $operacao == 'PPE_ABA') {
				exibirConfirmacao($msgAtCad,
								  'Confirmação - Aimaro',
								  'revisaoCadastral(\''.$chaveAlt.'\', \''.$tpAtlCad.'\', \'b1wgen0075.p\', \''.$stringArrayMsg.'\', \'controlaOperacao(\"PPE_ABA_ABRE\")\');',
								  'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"PPE_ABA_ABRE\")\')',false);
			}
		
		// Se não existe necessidade de Revisão Cadastral
		} else {
			
			//exibirConfirmacao('operacao' . $operacao,'Confirmação - Aimaro','alert(\'PPE_ABA_ABRE\')','bloqueiaFundo(divRotina)',false);
			
			if($operacao == 'VA')      echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\');';
			if($operacao == 'PPE_ABA') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"PPE_ABA_ABRE\")\');';
		}
	} 
		
	function validaDados(){	
		
		echo '$("input,select","#frmDadosComercial").removeClass("campoErro");';	
		
		// Campo Nat. da Ocupação
		if ( ($GLOBALS['cdnatopc'] == '' ) || ($GLOBALS['cdnatopc'] == 0 ) ) exibirErro('error','Natureza da Ocupação inválida.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdnatopc\',\'frmDadosComercial\')',false);
		
		//Campo Ocupação
		if ( ($GLOBALS['cdocpttl'] == '' ) || ($GLOBALS['cdocpttl'] == 0 ) ) exibirErro('error','Ocupação inválida.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdocpttl\',\'frmDadosComercial\')',false);		
		
		//Campo Tp. Ctr. Trb.
		if ( $GLOBALS['tpcttrab'] == '' ) exibirErro('error','Tipo Ctr. Trb. inválido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'tpcttrab\',\'frmDadosComercial\')',false);		

	}
		
?>