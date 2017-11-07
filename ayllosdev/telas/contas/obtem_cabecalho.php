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
 * 014: [24/05/2017] Lucas Reinert		  : Nova rotina "Impedimentos Desligamento" (PRJ364). 
 * 015: [11/07/2017] Mauro (MOUTS)        : Desenvolvimento da melhoria 364 - Grupo Economico 
 * 017: [17/10/2017] Kelvin (CECRED)      : Adicionando a informacao nmctajur no cabecalho da tela contas (PRJ339).
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
		echo 'showError("error"," '.$msgErro.'","Alerta - Contas","$(\'#nrdconta\',\'#frmCabContas\').focus()");';
		echo 'limparDadosCampos();';
		echo 'flgAcessoRotina = false;';
		exit();	
	}		
		
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msg = Array();	
		
	//Atribuições
	$cabecalho    = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	$Titulares       = ( isset($xmlObjeto->roottag->tags[2]->tags) ) ? $xmlObjeto->roottag->tags[2]->tags : array();
	$mensagens  = ( isset($xmlObjeto->roottag->tags[3]->tags) ) ? $xmlObjeto->roottag->tags[3]->tags : array();

	$tpNatureza = $cabecalho[6]->cdata;
	
	// Monta div com os dados de Pessoa Jurídica
	if ($tpNatureza >= 2) {
	
		// Prepara o html para div PJ
		echo 'var strHTML  = \'<label for="nmextttl">Raz&atilde;o Social:</label>\';';
		echo '    strHTML += \'<input name="nmextttl" id="nmextttl" type="text" /><br />\';';
		
		echo '    strHTML += \'<label for="nmfansia">Nome Fantasia:</label>\';';
		echo '    strHTML += \'<input name="nmfansia" id="nmfansia" type="text" /><br />\';';
		
		echo '    strHTML += \'<label for="nmctajur">Nome da Conta:</label>\';';
		echo '    strHTML += \'<input name="nmctajur" id="nmctajur" type="text" /><br />\';';
		
		echo '    strHTML += \'<label for="nrcpfcgc">CNPJ:</label>\';';
		echo '    strHTML += \'<input name="nrcpfcgc" id="nrcpfcgc" type="text" />\';';
		
		echo '    strHTML += \'<label for="inpessoa">Natureza:</label>\';';
		echo '    strHTML += \'<input name="inpessoa" id="inpessoa" type="text" />\';';
		
		echo '    strHTML += \'<label for="cdsitdct">Situa&ccedil;&atilde;o:</label>\';';
		echo '    strHTML += \'<input name="cdsitdct" id="cdsitdct" type="text" /><br />\';';

		// Coloca conteúdo HTML no div e exibe
		echo '$("#divRotinaPJ").html(strHTML);';
		echo '$("#divRotinaPJ").css("display","block");';
		echo '$("#divRotinaPF").css("display","none");';	 	 
		
	// Monta div com os dados de Pessoa Física	
	} else {
		
		// Prepara o html para div PF
		echo 'var strHTML  = \'<label for="nmextttl">Titular:</label>\';';
		echo '    strHTML += \'<input name="nmextttl" id="nmextttl" type="text"  />\';';
		
		echo '    strHTML += \'<label for="inpessoa">Nat.:</label>\';';
		echo '    strHTML += \'<input name="inpessoa" id="inpessoa" type="text" /><br />\';';
		
		echo '    strHTML += \'<label for="nrcpfcgc">C.P.F.:</label>\';';
		echo '    strHTML += \'<input name="nrcpfcgc" id="nrcpfcgc" type="text" />\';';
		
		echo '    strHTML += \'<label for="cdsexotl">Sexo:</label>\';';
		echo '    strHTML += \'<input name="cdsexotl" id="cdsexotl" type="text" />\';';
		
		echo '    strHTML += \'<label for="cdestcvl">Est.Civil:</label>\';';
		echo '    strHTML += \'<input name="cdestcvl" id="cdestcvl" type="text" />\';';
		
		echo '    strHTML += \'<label for="cdsitdct">Sit.:</label>\';';
		echo '    strHTML += \'<input name="cdsitdct" id="cdsitdct" type="text" /><br />\';';
		
		// Coloca conteúdo HTML no div e exibe
		echo '$("#divRotinaPF").html(strHTML);';
		echo '$("#divRotinaPF").css("display","block");';
		echo '$("#divRotinaPJ").css("display","none");';	 
	}	
	
	// Dados do Cabeçalho da Conta
	echo '$("#nrdconta","#frmCabContas").val("'.$cabecalho[0]->cdata.'").formataDado("INTEGER","zzzz.zzz-z","",false);';
	echo '$("#nrmatric","#frmCabContas").val("'.$cabecalho[1]->cdata.'").formataDado("INTEGER","zzz.zzz","",false);'; //certo
	echo '$("#cdagenci","#frmCabContas").val("'.$cabecalho[2]->cdata.' - '.$cabecalho[3]->cdata.'");'; 
	echo '$("#nmextttl","#frmCabContas").val("'.$cabecalho[5]->cdata.'");'; //certo
	echo '$("#inpessoa","#frmCabContas").val("'.$cabecalho[6]->cdata.' - '.$cabecalho[7]->cdata.'");'; //pos.7 descricao
	echo '$("#nrcpfcgc","#frmCabContas").val("'.$cabecalho[8]->cdata.'");'; //certo
	echo '$("#cdsexotl","#frmCabContas").val("'.$cabecalho[9]->cdata.'");'; 
	echo '$("#cdestcvl","#frmCabContas").val("'.$cabecalho[10]->cdata.' - '.$cabecalho[11]->cdata.'");'; 
	echo '$("#cdtipcta","#frmCabContas").val("'.$cabecalho[12]->cdata.' - '.$cabecalho[13]->cdata.'");'; //pos.12 descricao tp.conta
	echo '$("#cdsitdct","#frmCabContas").val("'.$cabecalho[14]->cdata.' - '.$cabecalho[15]->cdata.'");'; //pos.14 descricao
    echo '$("#nrdctitg","#frmCabContas").val("'.$cabecalho[16]->cdata.'").formataDado("STRING","9.999.999-9",".-",false);';
	echo '$("#nmctajur","#frmCabContas").val("'.$cabecalho[21]->cdata.'");';
	
	echo 'var strHTMLTTL = \'\';'; 
	// PJ
	if ($tpNatureza >= 2) { 
		
		// Preenche nome fantasia somente qdo for pessoa juridica
		echo '$("#nmfansia","#frmCabContas").val("'.$cabecalho[17]->cdata.'");'; 
	
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
	echo '$("#idseqttl","#frmCabContas").html(strHTMLTTL);';	
	// Reposiciona com na mesma posição do titular
	echo '$("#idseqttl","#frmCabContas").val("'.$cabecalho[4]->cdata.'");';
	
	// Verifica quantidade de rotinas que o operador pode visualizar
	$totalRot = count($rotinasTela); 
	
	// Limpa resumos devido diferenças entre pessoa física e jurídica		
	for ($i = 0; $i < $totalRot; $i++) {				
		echo '$("#labelRot'.$i.'").html("").unbind("click");';
	}
	
	$flgDadosPessoais   = false;
	$flgContatosPF      = false;
	$flgComercialPF     = false;
	$flgContaCorrentePF = false;
	
	// Mostra resumo de dados das rotinas (saldos, situações, etc) ...
	$contRotina = 0; 	 
	for ($i = 0; $i < $totalRot; $i++) {
		
		$nomeRotina = '';		
		
		if ( $cabecalho[6]->cdata == 1) { // Pessoa fisica
		
			switch (strtoupper($rotinasTela[$i])) {
						
				case "IDENTIFICACAO": 
				case "RESPONSAVEL LEGAL":
				case "PESSOAS DE RELACIONAMENTO":
				case "CONJUGE": {
					if ($flgDadosPessoais == false) {
						$nomeRotina = "Dados Pessoais"; 
						$urlRotina  = "dados_pessoais"; 
						$flgDadosPessoais = true;	
						break;			
					}
					continue;
				}
				case "ENDERECO": 
				case "TELEFONES":
				case "E_MAILS": {	
					if ($flgContatosPF == false) {	
						$nomeRotina = "Contatos"; 
						$urlRotina  = "contatos_pf";
						$flgContatosPF = true;		
						break;			
					}					
					continue;
				}
				case "COMERCIAL":
				case "BENS": {
					if ($flgComercialPF == false) {
						$nomeRotina = "Comercial"; 
						$urlRotina  = "comercial_pf"; 
						$flgComercialPF	= true;	
						break;			
					}					
					continue;
				}
				case "CONTA CORRENTE":
				case "CLIENTE FINANCEIRO":
				case "INFORMATIVOS": 
				case "FINANCEIRO-INF.ADICIONAIS": {
					if ($flgContaCorrentePF == false) {
					    $nomeRotina = "Conta Corrente"; 
						$urlRotina  = "conta_corrente_pf"; 	
						$flgContaCorrentePF = true;
						break;
					}		
					continue;
				}
				case "ORGAOS PROT. AO CREDITO": {
					$nomeRotina = "Órgãos de Proteção ao Crédito";
					$urlRotina = "protecao_credito";
					break;
				}	
				case "FICHA CADASTRAL": {
					$nomeRotina = "Ficha Cadastral"; 
					$urlRotina  = "ficha_cadastral"; 				
					break;
				}
				case "IMPRESSOES": {
					$nomeRotina = "Impressões"; 
					$urlRotina  = "impressoes"; 				
					break;
				}
				case "DESABILITAR OPERACOES": {
					$nomeRotina = "Desabilitar Operações"; 
					$urlRotina  = "liberar_bloquear";
					break;
				}				
				case "GRUPO ECONOMICO": {
					$nomeRotina = "Grupo Econômico"; 
					$urlRotina  = "grupo_economico";
					break;
				}				
				case "IMPEDIMENTOS DESLIGAMENTO": {
					$nomeRotina = "Impedimentos Desligamento"; 
					$urlRotina  = "impedimentos_desligamento";
					break;					
				}
				default: {		
					$nomeRotina = "";    
					$urlRotina  = "";    				 
					break;
				}
				
			}		
		}
		else { // Pessoa Juridica
			
			switch (strtoupper($rotinasTela[$i])) {
				
				case "ORGAOS PROT. AO CREDITO": {
					$nomeRotina = "Órgãos de Proteção ao Crédito";
					$urlRotina = "protecao_credito";
					break;
				}
				case "BENS": {
					$nomeRotina = "Bens"; 
					$urlRotina  = "bens"; 				
					break;
				}
				case "CLIENTE FINANCEIRO": {
					$nomeRotina = "Cliente Financeiro"; 
					$urlRotina  = "cliente_financeiro"; 				
					break;
				}
				case "CONTA CORRENTE": {
					$nomeRotina = "Conta Corrente"; 
					$urlRotina  = "conta_corrente"; 				
					break;
				}
				case "ENDERECO": {
					$nomeRotina = "Endereço"; 
					$urlRotina  = "endereco"; 				
					break;
				}
				case "E_MAILS": {
					$nomeRotina = "E-Mails"; 
					$urlRotina  = "emails"; 				
					break;
				}
				case "FICHA CADASTRAL": {
					$nomeRotina = "Ficha Cadastral"; 
					$urlRotina  = "ficha_cadastral"; 				
					break;
				}
				case "FINANCEIRO-ATIVO/PASSIVO": {
					$nomeRotina = "Ativo/Passivo"; 
					$urlRotina  = "ativo_passivo"; 				
					break;
				}	
				case "FINANCEIRO-INF.ADICIONAIS": {
					$nomeRotina = "Inf. Adicionais"; 
					$urlRotina  = "inf_adicionais"; 				
					break;
				}
				case "FINANCEIRO-RESULTADO": {  
					$nomeRotina = "Resultado"; 
					$urlRotina  = "resultado"; 				
					break;
				}
				case "IDENTIFICACAO": {
					$nomeRotina = "Identificação";	
					$urlRotina  = "identificacao_juridica";		
					break;
				}
				case "IMPRESSOES": {
					$nomeRotina = "Impressões"; 
					$urlRotina  = "impressoes"; 				
					break;
				}
				case "PROCURADORES" : { 
					$urlRotina  = "procuradores";
					$nomeRotina = "Representante/Procurador"; 
					break;
				}
				case "PARTICIPACAO": { 
					$urlRotina  = "participacao";
					$nomeRotina = "Participação Empresas"; 
					break;
				}
				case "REFERENCIAS": {  
					$nomeRotina = "Referências"; 
					$urlRotina  = "referencias"; 			    
					break;
				}
				case "REGISTRO": {  
					$nomeRotina = "Registro"; 
					$urlRotina  = "registro"; 				
					break;
				}
				case "TELEFONES": {
					$nomeRotina = "Telefones"; 
					$urlRotina  = "telefones"; 				
					break;
				}
				case "IMUNIDADE TRIBUTARIA": {
					$nomeRotina = "Imunidade Tributaria";
					$urlRotina = "imunidade_tributaria";
					break;
				}
//				case "DESABILITAR OPERACOES": {
//					$nomeRotina = "Desabilitar Operações"; 
//					$urlRotina  = "liberar_bloquear";
//					break;
//				}				
				case "FINANCEIRO-BANCO": { 
					$nomeRotina = "Banco"; 
					$urlRotina  = "banco"; 				
					break;
				}
				case "FINANCEIRO-FATURAMENTO": {  
					$nomeRotina = "Faturamento"; 
					$urlRotina  = "faturamento"; 				
					break;
				}
				case "GRUPO ECONOMICO": {
					$nomeRotina = "Grupo Econômico"; 
					$urlRotina  = "grupo_economico";
					break;
				}
				case "IMPEDIMENTOS DESLIGAMENTO": {
					$nomeRotina = "Impedimentos Desligamento"; 
					$urlRotina  = "impedimentos_desligamento";
					break;					
				}				
				default: {		
					$nomeRotina = "";    
					$urlRotina  = "";    				 
					break;
				}		
			}
		}
		 
		// Caso o xml retornou uma rotina que não deve ser mostrada no Ayllos Web
		if ($nomeRotina == '') { continue; }
			
		echo '$("#labelRot'.$contRotina.'").html("'.$nomeRotina.'");';
		
		if (trim($urlRotina) <> '') {			
		
			echo '$("#labelRot'.$contRotina.'").unbind("click");';
			echo '$("#labelRot'.$contRotina.'").bind("click",function() { acessaRotina("'.$rotinasTela[$i].'","'.$nomeRotina.'","'.$urlRotina.'"); nmrotina = "'.retiraAcentos($nomeRotina).'"; });';
			
		}
		
		$contRotina++;
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
