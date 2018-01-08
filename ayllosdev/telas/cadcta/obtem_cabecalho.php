<?php
/*!
 * FONTE        : obtem_cabecalho.php
 * CRIAÇÃO      : Alexandre Scola (DB1)
 * DATA CRIAÇÃO : Janeiro/2007
 * OBJETIVO     : Capturar dados de cabecalho da tela CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [01/04/2010] Rodolpho Telmo (DB1) : Retirado formulário das tabelas e adequada ao novo padrão
 * 002: [11/05/2011] Gabriel Ramirez	  : Incluir Rotina DDA 
 * 003: [31/08/2011] Guilherme            : Incluir rotina Participacao empresas
 * 004: [18/11/2011] David (CECRED)       : Ajuste para atualização do cabeçalho em background
 * 005: [24/04/2012] Adriano (CECRED)     : Ajuste referente ao projeto GP - Sócios Menores.
 * 006: [05/07/2013] Lucas R (CECRED)     : Incluir case "IMUNIDADE TRIBUTARIA".
 * 007: [11/08/2014] Jonata (RKAM)        : Nova rotina "Protecao ao Credito".
 * 008: [05/01/2015] James Prust Junior   : Incluir o item Liberar/Bloquear
 * 009: [30/01/2015] Andre Santos(SUPERO) : Incluir o item Convenio CDC
 * 010: [20/02/2015] Lucas R. (CECRED)    : Alterado Codificação da tela para ANSI.
 * 011: [29/07/2015] Lucas Ranghetti (CECRED): Alterado logica rotina de procuradores para $cabecalho[6]->cdata > 1(inpessoa > 1).
 * 012: [01/09/2015] Gabriel (RKAM)       : Reformulacao Cadastral. 
 * 013: [14/09/2016] Kelvin (Cecred)      : Ajuste feito para resolver o problema relatado no chamado 506554. 
 * 014: [11/07/2017] Mauro (MOUTS)        : Desenvolvimento da melhoria 364 - Grupo Economico
 * 015: [24/05/2017] Lucas Reinert		  : Nova rotina "Impedimentos Desligamento" (PRJ364).
 */ 

	session_start();	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");	
	isPostMethod();		
	
	$opbackgr = (!isset($_POST["opbackgr"]) || $_POST["opbackgr"] == "") ? "true" : $_POST["opbackgr"];
	
	// Verifica Permissão
	if ($opbackgr == 'true' && (($msgError = validaPermissao($glbvars['nmdatela'],'','C')) <> '')) {
		exibeErro($msgError);		
	}
	
	// Pega opções em que o operador tem permissão
	if (isset($glbvars["rotinasTela"])) {
		$rotinasTela = $glbvars["rotinasTela"];
	}else{
		exibeErro("Parâmetros incorretos.");
	}	
    
   // echo "ODIRLEI - " . $rotinasTela;
	
	// Se campos necessários para carregar dados não foram informados	
	if (!isset($_POST["nrdconta"]))  {
		exibeErro("Parâmetros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"] == "" ? 1 : $_POST["idseqttl"];	
			
	// Se conta informada não for um número inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inválida.");
	}		
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0051.p</Bo>";
	$xml .= "		<Proc>carrega_dados_conta</Proc>";
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
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	

	$xmlResult = getDataXML($xml,($opbackgr == 'true' ? true : false));
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	function exibeErro($msgErro) {
		echo 'hideMsgAguardo();';
		echo 'showError("error"," '.$msgErro.'","Alerta - Contas","$(\'#nrdconta\',\'#frmCabCadcta\').focus()");';
		echo 'limparDadosCampos();';
		echo 'flgAcessoRotina = false;';
		exit();	
	}		
		
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msg = Array();	
		
	//Atribuições
	$cabecalho  = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	$Titulares  = ( isset($xmlObjeto->roottag->tags[2]->tags) ) ? $xmlObjeto->roottag->tags[2]->tags : array();
	$mensagens  = ( isset($xmlObjeto->roottag->tags[3]->tags) ) ? $xmlObjeto->roottag->tags[3]->tags : array();

	$tpNatureza = $cabecalho[6]->cdata;	
	
	// Dados do Cabeçalho da Conta
	echo '$("#nrdconta","#frmCabCadcta").val("'.$cabecalho[0]->cdata.'").formataDado("INTEGER","zzzz.zzz-z","",false);';
	echo '$("#nrmatric","#frmCabCadcta").val("'.$cabecalho[1]->cdata.'").formataDado("INTEGER","zzz.zzz","",false);'; //certo
	echo '$("#cdagenci","#frmCabCadcta").val("'.$cabecalho[2]->cdata.' - '.$cabecalho[3]->cdata.'");'; 
	echo '$("#nmextttl","#frmCabCadcta").val("'.$cabecalho[5]->cdata.'");'; //certo
	echo '$("#inpessoa","#frmCabCadcta").val("'.$cabecalho[6]->cdata.' - '.$cabecalho[7]->cdata.'");'; //pos.7 descricao
	echo '$("#nrcpfcgc","#frmCabCadcta").val("'.$cabecalho[8]->cdata.'");'; //certo
	echo '$("#cdsexotl","#frmCabCadcta").val("'.$cabecalho[9]->cdata.'");'; 
	echo '$("#cdestcvl","#frmCabCadcta").val("'.$cabecalho[10]->cdata.' - '.$cabecalho[11]->cdata.'");';     
    echo '$("#cdtipcta_idx","#frmCabCadcta").val("'.$cabecalho[12]->cdata.'");';
	echo '$("#cdtipcta","#frmCabCadcta").val("'.$cabecalho[12]->cdata.' - '.$cabecalho[13]->cdata.'");'; //pos.12 descricao tp.conta
	echo '$("#cdsitdct","#frmCabCadcta").val("'.$cabecalho[14]->cdata.' - '.$cabecalho[15]->cdata.'");'; //pos.14 descricao
    echo '$("#nrdctitg","#frmCabCadcta").val("'.$cabecalho[16]->cdata.'").formataDado("STRING","9.999.999-9",".-",false);';
	
	echo 'var strHTMLTTL = \'\';'; 
	// PJ
	if ($tpNatureza >= 2) { 
		
		// Preenche nome fantasia somente qdo for pessoa juridica
		echo '$("#nmfansia","#frmCabCadcta").val("'.$cabecalho[17]->cdata.'");'; 
	
		// Popula combo de sequencia dos titulares
		echo 'strHTMLTTL = \'<option value="1">1 - '.$cabecalho[5]->cdata.'</option>\';';
		
	// PF
	} else {   
	    
		// Popula combo de seq.titulares
		$totalReg = count($Titulares);
		for ($i = 1; $i <= $totalReg; $i++){
			
			// Seleciona por padrão sempre o primeiro registro
			if ($Titulares[$i - 1]->tags[0]->cdata == $cabecalho[4]->cdata) { 
				$selected = ' selected="selected"'; 
			} else { 
				$selected = ''; 
			}
			// Monta string dos options
			echo 'strHTMLTTL += \'<option value="'.$Titulares[$i - 1]->tags[0]->cdata.'" '.$selected.'>'.
					$Titulares[$i - 1]->tags[0]->cdata.' - '.addslashes($Titulares[$i - 1]->tags[1]->cdata).
			     '</option>\';'; 
		} 
	} 
	// Atualiza combo com html
	echo '$("#idseqttl","#frmCabCadcta").html(strHTMLTTL);';	
	// Reposiciona com na mesma posição do titular
	echo '$("#idseqttl","#frmCabCadcta").val("'.$cabecalho[4]->cdata.'");';
	
	// Verifica quantidade de rotinas que o operador pode visualizar
	$totalRot = count($rotinasTela); 
	
	// Limpa resumos devido diferenças entre pessoa física e jurídica		
	for ($i = 0; $i < $totalRot; $i++) {				
		echo '$("#labelRot'.$i.'").html("").unbind("click");';
	}
	
	// Flag para acesso a rotinas
	echo 'flgAcessoRotina = true;';
	
	// Variáveis globais
	echo 'nrdconta = "'.$cabecalho[0]->cdata.'";';
	echo 'nrdctitg = "'.$cabecalho[16]->cdata.'";';
	echo 'inpessoa = "'.$cabecalho[6]->cdata.'";';
	echo 'cpfprocu = "'.$cabecalho[8]->cdata.'";';
	echo 'dtdenasc = "'.$cabecalho[18]->cdata.'";';
	echo 'cdhabmen = "'.$cabecalho[19]->cdata.'";';
	
	if ( $opbackgr == 'true' ) echo 'hideMsgAguardo();';
		
	/*Alteração: Mostrar mensagens de alerta em uma tabela de mensagens*/	
	if ( ( count($mensagens) > 0 or count($msg) > 0 ) and $opbackgr == 'true' ) {	
		
		if ( $mensagens != ''and $mensagens != null ){
			foreach ( $mensagens as $mensagem ){
				$msg[] = getByTagName($mensagem->tags,'dsmensag');
			}
		}
		
		mostraTabelaAlertas($msg);
	} else if ( $opbackgr == 'true' ) {
		echo 'unblockBackground();';
	}
		
	if ( $opbackgr == 'true' ) setVarSession("nmrotina","");
	
?>
