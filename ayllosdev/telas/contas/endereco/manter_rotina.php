<?php 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 20/04/2010 
 * OBJETIVO     : Rotina para validar/alterar os dados de Ativo/Passivo da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 001: [03/05/2011] Rogérius Militao   (DB1) Adicionado o campo "dtinires" (inicio de residencia) com o tratamento
 * 002: [05/07/2011] Henrique Pettenuci       Adicionado os campos nrdoapto e cddbloco.
 * 003: [22/07/2015] Gabriel	       (RKAM) Reformulacao Cadastral.
 * 004: [14/07/2016] Carlos R. Corrigi o tratamento da variavel tpendass que era string e estava sendo comparada 
 *									        como int e passei a mesma para a funcao validaDados que ha usava como sendo global.SD 479874.
 * 005: [01/12/2016] Renato Darosci (Supero): P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                                            pois a BO não utiliza o mesmo.
 * 006: [08/05/2017] Rafael Monteiro (Mouts): Remover caracteres especiais do campo complemento do endereco. Chamado 664305.
 */

    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();

	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';

	// Guardo os parâmetos do POST em variáveis
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$incasprp = (isset($_POST['incasprp'])) ? $_POST['incasprp'] : '';
	$vlalugue = (isset($_POST['vlalugue'])) ? $_POST['vlalugue'] : '';
	$dsendere = (isset($_POST['dsendere'])) ? $_POST['dsendere'] : '';
	$nrendere = (isset($_POST['nrendere'])) ? $_POST['nrendere'] : '';
	$complend = (isset($_POST['complend'])) ? $_POST['complend'] : '';
	$nrdoapto = (isset($_POST['nrdoapto'])) ? $_POST['nrdoapto'] : '';
	$cddbloco = (isset($_POST['cddbloco'])) ? $_POST['cddbloco'] : '';
	$nmbairro = (isset($_POST['nmbairro'])) ? $_POST['nmbairro'] : '';
	$nrcepend = (isset($_POST['nrcepend'])) ? $_POST['nrcepend'] : '';
	$nmcidade = (isset($_POST['nmcidade'])) ? $_POST['nmcidade'] : '';
	$cdufende = (isset($_POST['cdufende'])) ? $_POST['cdufende'] : '';
	$nrcxapst = (isset($_POST['nrcxapst'])) ? $_POST['nrcxapst'] : '';
	$dtinires = (isset($_POST['dtinires'])) ? $_POST['dtinires'] : '';
	$nranores = (isset($_POST['nranores'])) ? $_POST['nranores'] : '';
	$qtprebem = (isset($_POST['qtprebem'])) ? $_POST['qtprebem'] :  0;
	$vlprebem = (isset($_POST['vlprebem'])) ? $_POST['vlprebem'] :  0;
	$tpendass = (isset($_POST['tpendass'])) ? intval($_POST['tpendass']) :  0;
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';
	$idorigem = (isset($_POST['idorigem'])) ? $_POST['idorigem'] : 0;

	$nrcepend = str_replace('-','',$nrcepend);
	
	if(in_array($operacao,array('AV'))) validaDados($tpendass);

	// Dependendo da operação, chamo uma procedure diferente
	$procedure = "";
	$bo = ($operacao == 'CC') ? 'b1wgen0052.p' : 'b1wgen0038.p';

	switch($operacao) {
		case 'AV': $procedure = 'validar-endereco'; $cddopcao = ''; $op = 'A'; break;
		case 'VA': $procedure = 'alterar-endereco'; $cddopcao = ''; $op = 'A'; break;
		case 'AE': $procedure = 'gerenciar-atualizacao-endereco'; $cddopcao = 'A'; $op = 'A'; break;
		case 'EI': $procedure = 'gerenciar-atualizacao-endereco'; $cddopcao = 'E'; $op = 'E'; break;
		case 'CC': $procedure = 'Valida_Cidades';   $cddopcao = ''; $op = '@'; break;
		default: return false;
	}	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$op)) <> "") exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>" .$bo . "</Bo>";
	$xml .= "		<Proc>".$procedure."</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";				
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";	            
	$xml .= "		<incasprp>".$incasprp."</incasprp>";                
	$xml .= "		<vlalugue>".$vlalugue."</vlalugue>";                
	$xml .= "		<dsendere>".$dsendere."</dsendere>";                
	$xml .= "		<nrendere>".$nrendere."</nrendere>";                
	$xml .= "		<complend>".removeCaracteresInvalidos(retiraAcentos($complend))."</complend>";
	$xml .= "		<nrdoapto>".$nrdoapto."</nrdoapto>";  
	$xml .= "		<cddbloco>".$cddbloco."</cddbloco>";  
	$xml .= "		<nrcepend>".$nrcepend."</nrcepend>";                
	$xml .= "		<nmbairro>".$nmbairro."</nmbairro>";                
	$xml .= "		<nmcidade>".$nmcidade."</nmcidade>";                
	$xml .= "		<cdufende>".$cdufende."</cdufende>";                
	$xml .= "		<nrcxapst>".$nrcxapst."</nrcxapst>";	           
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";	
	$xml .= "		<dtinires>".$dtinires."</dtinires>";	  
	$xml .= "		<qtprebem>".$qtprebem."</qtprebem>";
	$xml .= "		<vlprebem>".$vlprebem."</vlprebem>";	
	$xml .= "		<tpendass>".$tpendass."</tpendass>";
	
	if ($procedure == 'alterar-endereco') {
		$xml .= '       <idorigee>'.$idorigem.'</idorigee>';
	}
	
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	$metodo = (in_array($operacao,array('AE','EI'))) ? 'controlaOperacao' : 'bloqueiaFundo(divRotina)';
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$mtdErro = 'bloqueiaFundo(divRotina);';
		$mtdErro .= ($operacao == 'CC' || $operacao == 'AV') ? '' : 'controlaOperacao();';
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
	}
	
	
	$msg  		= Array();
	$msgRetorno = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGRETOR']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'] : '';
	$msgAlerta    = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'] : '';
	$msgRvcad   = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGRVCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGRVCAD'] : '';
	
	if ($msgRetorno !='' ) $msg[] = $msgRetorno;
	if ($msgRvcad   !='' ) $msg[] = $msgRvcad;
	if ($msgAlerta  !='' ) $msg[] = $msgAlerta;
		
	$stringArrayMsg = implode( "|", $msg);
	
	// Verificação da revisão Cadastral
	$msgAtCad = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGATCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'] : '';
	$chaveAlt	  = ( isset($xmlObjeto->roottag->tags[0]->attributes['CHAVEALT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'] : '';
	$tpAtlCad    = ( isset($xmlObjeto->roottag->tags[0]->attributes['TPATLCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'] : '';
	
	if ($operacao == 'CC') {
		echo 'hideMsgAguardo();bloqueiaFundo(divRotina);';
		exit();	
	}

	// Se é Validação
	if( $operacao == 'AV' ) {

		if ($tpendass == 9 || $tpendass == 10 )  {
		    echo "manterRotina('AV' , 'fieldCorrespondencia');";
		} else if ($tpendass == 13) {
			echo "manterRotina('AV' , 'fieldComplementar');";
		} else {
			exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Ayllos','controlaOperacao(\'VA\');','bloqueiaFundo(divRotina)',false);
		}
		
	// Se é Inclusão ou Alteração
	} else {
		
		if ($tpendass == 9 || $tpendass == 10 )  {
		    echo "manterRotina('VA' , 'fieldCorrespondencia');";
		} else if ($tpendass == 13) {
			echo "manterRotina('VA' , 'fieldComplementar');";
		} else {
		
			// Verificar se existe "Verificação de Revisão Cadastral"
			if( $msgAtCad != '' && $flgcadas != 'M' ) {			
				
				if($operacao=='VA') exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0038.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FA\")\')',false);		
				if($operacao=='AE') exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0038.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FAE\")\')',false);		
				if($operacao=='EI') exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0038.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FEI\")\')',false);		
				
			// Se não existe necessidade de Revisão Cadastral
			} else {				
				// Chama o controla Operação Finalizando a Inclusão ou Alteração			
				if($operacao=='VA') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FA\")\');';
				if($operacao=='AE') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FAE\")\');';
				if($operacao=='EI') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FEI\")\');';
			}
		}
	}
	
	function validaDados($tpendass) {
	
		$data 	= explode('/',$GLOBALS['dtinires']);
		$mes 	= $data[0];
		$ano 	= $data[1];
	
		// No início das validações, primeiro remove a classe erro de todos os campos
		echo '$("input, select","#frmEndereco").removeClass("campoErro");';
		
		// Número da conta e o titular são inteiros válidos
		if (!validaInteiro($GLOBALS['nrdconta'])) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);				
		if (!validaInteiro($GLOBALS['idseqttl'])) exibirErro('error','Seq. Titular inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);	
		
		//Campo imóvel
		if ( $GLOBALS['incasprp'] == "" ) exibirErro('error','Tipo de imóvel inválido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'incasprp\',\'frmEndereco\')',false);

		//Campo CEP
		if ( (( $GLOBALS['nrcepend'] == "" ) || ( $GLOBALS['nrcepend'] == 0 ))  && ($tpendass == 10 || $tpendass == 9)) exibirErro('error','CEP inválido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nrcepend\',\'frmEndereco\')',false);

		// Campo endereço
		if ( $GLOBALS['dsendere'] == ""  && ($tpendass == 10 || $tpendass == 9)) exibirErro('error','Endereço inválido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dsendere\',\'frmEndereco\')',false);
		
		//Campo bairro
		if ( $GLOBALS['nmbairro'] == ""  && ($tpendass == 10 || $tpendass == 9)) exibirErro('error','Nome do bairro inválido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nmbairro\',\'frmEndereco\')',false);
			
		//Campo cidade
		if ( $GLOBALS['nmcidade'] == ""  && ($tpendass == 10 || $tpendass == 9)) exibirErro('error','Nome da cidade inválido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nmcidade\',\'frmEndereco\')',false);
		
		//Campo UF
		if ( $GLOBALS['cdufende'] == ""  && ($tpendass == 10 || $tpendass == 9)) exibirErro('error','Cód. do estado (UF) inválido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdufende\',\'frmEndereco\')',false);

		//Campo Inicio de Residencia
		if ( $GLOBALS['dtinires'] == "" ) exibirErro('error','Inicio de residencia deve ser informado.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dtinires\',\'frmEndereco\')',false);

		//Campo Inicio de Residencia
		if ( !is_numeric($mes) or $mes < 1 or $mes > 12) exibirErro('error','Data invalida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dtinires\',\'frmEndereco\')',false);

		//Campo Inicio de Residencia
		if ( !is_numeric($ano) or $ano < 1850 or $ano > date('Y')) exibirErro('error','Data invalida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dtinires\',\'frmEndereco\')',false);
		
		//Campo Origem
		if (( $GLOBALS['idorigem'] == "" ) && ( $GLOBALS['nrcepend'] != 0 )) exibirErro('error','Origem do endereco deve ser informada.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'idorigem\',\'frmEndereco\')',false); 
	}	
?>									 