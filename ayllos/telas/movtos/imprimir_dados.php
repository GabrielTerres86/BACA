<?
/*!
 * FONTE        : imprimir_dados.php
 * CRIAÇÃO      : Jéssica (DB1)							Última Alteração: 03/12/2014
 * DATA CRIAÇÃO : 13/03/2014
 * OBJETIVO     : Realiza as impressões da tela MOVTOS.	
 * --------------
 * ALTERAÇÕES   : 03/12/2014 - Ajustes para liberação (Adriano).
 *
 *                05/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
 *                             departamento como parametros e passar o o código (Renato Darosci)
 * -------------- 
 */
?>

<? 
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
		
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$_POST['cddopcao'])) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);	
	}	
	
	// Recebe as variaveis
	$dsiduser = session_id();	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0; 
	$tpdopcao = (isset($_POST['tpdopcao'])) ? $_POST['tpdopcao'] : '';  
	$dtinicio = (isset($_POST['dtinicio'])) ? $_POST['dtinicio'] : '?'; 
	$dttermin = (isset($_POST['dttermin'])) ? $_POST['dttermin'] : '?';   
	$cdempres = (isset($_POST['cdempres'])) ? $_POST['cdempres'] : 0; 
	$tppessoa = (isset($_POST['tppessoa'])) ? $_POST['tppessoa'] : 0; 
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0; 
	$dtmvtopr = (isset($_POST['dtmvtopr'])) ? $_POST['dtmvtopr'] : '?';
	$lgvisual = (isset($_POST['lgvisual'])) ? $_POST['lgvisual'] : ''; 
	$ddtfinal = (isset($_POST['ddtfinal'])) ? $_POST['ddtfinal'] : '?';
	$cdultrev = (isset($_POST['cdultrev'])) ? $_POST['cdultrev'] : 0; 
	$tpcontas = (isset($_POST['tpcontas'])) ? $_POST['tpcontas'] : ''; 
	$tpdomvto = (isset($_POST['tpdomvto'])) ? $_POST['tpdomvto'] : ''; 
	$dsadmcrd = (isset($_POST['dsadmcrd'])) ? $_POST['dsadmcrd'] : ''; 
	$linhacre = (isset($_POST['linhacre'])) ? $_POST['linhacre'] : '';
    $finalida = (isset($_POST['finalida'])) ? $_POST['finalida'] : '';
	$situacao = (isset($_POST['situacao'])) ? $_POST['situacao'] : ''; 
	$nmarquiv = (isset($_POST['nmarquiv'])) ? $_POST['nmarquiv'] : '';
	$gerarpdf = (isset($_POST['gerarpdf'])) ? $_POST['gerarpdf'] : 0;
		
	validaDados();
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0185.p</Bo>';
	$xml .= '		<Proc>Gera_Impressao</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '       <inproces>'.$glbvars['inproces'].'</inproces>';	
	$xml .= '       <cddepart>'.$glbvars['cddepart'].'</cddepart>';		
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '		<cdagenca>'.$cdagenci.'</cdagenca>';
	$xml .= '		<tpdopcao>'.$tpdopcao.'</tpdopcao>';	
	$xml .= '		<dtinicio>'.$dtinicio.'</dtinicio>';
	$xml .= '		<dttermin>'.$dttermin.'</dttermin>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<cdempres>'.$cdempres.'</cdempres>';
	$xml .= '		<tppessoa>'.$tppessoa.'</tppessoa>';
	$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';
	$xml .= '		<dtmvtopr>'.$dtmvtopr.'</dtmvtopr>';
	$xml .= '		<lgvisual>'.$lgvisual.'</lgvisual>';
	$xml .= '		<ddtfinal>'.$ddtfinal.'</ddtfinal>';
	$xml .= '		<cdultrev>'.$cdultrev.'</cdultrev>';
	$xml .= '		<tpcontas>'.$tpcontas.'</tpcontas>';
	$xml .= '		<tpdomvto>'.$tpdomvto.'</tpdomvto>';
	$xml .= '		<dsadmcrd>'.$dsadmcrd.'</dsadmcrd>';
	$xml .= '		<linhacre>'.$linhacre.'</linhacre>';	
	$xml .= '		<finalida>'.$finalida.'</finalida>';	
	$xml .= '		<situacao>'.$situacao.'</situacao>';	
	$xml .= '		<nmarquiv>'.$nmarquiv.'</nmarquiv>';	
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';	
	
	//Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);
		
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == 'ERRO') {
		$msgErro	= $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;	
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);	
				
	}
		
	if ($gerarpdf == 1){
	
		$nmarqpdf = $xmlObjDados->roottag->tags[0]->attributes["NMARQPDF"];
				
		echo 'Gera_Impressao("'.$nmarqpdf.'")';
		
	}else{
		echo 'fechaRotina($("#divRotina"),"","controlaLayout();");';
	}
	
	function validaDados(){
	

		if ( $GLOBALS["cddopcao"] == "E"){
		
			//Tipo de impressão
			if ( $GLOBALS["lgvisual"] == ''){ 
				exibirErro('error','Tipo de sa&iacute;da n&atilde;o informado.','Alerta - Ayllos','focaCampoErro(\'lgvisual\',\'divOpcaoE\');',false);
			}
			
		}else if( $GLOBALS["cddopcao"] == "S"){
		
			//Agência selecionada
			if ( $GLOBALS["cdagenci"] == 0){ 				
				exibirErro('error','PA n&atilde;o informado.','Alerta - Ayllos','focaCampoErro(\'cdagenci\',\'divOpcaoS\');',false);
			}
			
			//Tipo de conta
			if ( $GLOBALS["tpcontas"] == ''){ 
				exibirErro('error','Tipo de conta n&atilde;o informado.','Alerta - Ayllos','focaCampoErro(\'tpcontas\',\'divOpcaoS\');',false);
			}
			
			//Tipo de impressão
			if ( $GLOBALS["lgvisual"] == ''){ 
				exibirErro('error','Tipo de sa&iacute;da n&atilde;o informado.','Alerta - Ayllos','focaCampoErro(\'lgvisual\',\'divOpcaoS\');',false);
			}
		
		}else if( $GLOBALS["cddopcao"] == "R"){
		
			//Agência selecionada
			if ( $GLOBALS["cdagenci"] == 0){ 				
				exibirErro('error','PA n&atilde;o informado.','Alerta - Ayllos','focaCampoErro(\'cdagenci\',\'divOpcaoR\');',false);
			}
			
			//Tipo de natureza
			if ( $GLOBALS["tppessoa"] == 0){ 
				exibirErro('error','Tipo de natureza n&atilde;o informado.','Alerta - Ayllos','focaCampoErro(\'tppessoa\',\'divOpcaoR\');',false);
			}
			
			//Revisão
			if ( $GLOBALS["cdultrev"] == 0){ 
				exibirErro('error','Revis&atilde;o n&atilde;o informado.','Alerta - Ayllos','focaCampoErro(\'cdultrev\',\'divOpcaoR\');',false);
			}
			
			//Tipo de impressão
			if ( $GLOBALS["lgvisual"] == ''){ 
				exibirErro('error','Tipo de sa&iacute;da n&atilde;o informado.','Alerta - Ayllos','focaCampoErro(\'lgvisual\',\'divOpcaoR\');',false);
			}
		
		}else if( $GLOBALS["cddopcao"] == "L"){
		
			//Data de inicio
			if ( $GLOBALS["dtinicio"] == '?' || $GLOBALS["dtinicio"] == ''){ 				
				exibirErro('error','Data de inicio n&atilde;o informada.','Alerta - Ayllos','focaCampoErro(\'dtinicio\',\'divOpcaoL\');',false);
			}
			
			//Data final
			if ( $GLOBALS["ddtfinal"] == '?' || $GLOBALS["ddtfinal"] == ''){ 
				exibirErro('error','Data final n&atilde;o informada.','Alerta - Ayllos','focaCampoErro(\'ddtfinal\',\'divOpcaoL\');',false);
			}
			
			//Tipo de impressão
			if ( $GLOBALS["lgvisual"] == ''){ 
				exibirErro('error','Tipo de sa&iacute;da n&atilde;o informado.','Alerta - Ayllos','focaCampoErro(\'lgvisual\',\'divOpcaoL\');',false);
			}
		
		}else if($GLOBALS["cddopcao"] == "A"){
		
			//Código da Linha crédito
			if ( $GLOBALS["linhacre"] == ''){ 
				exibirErro('error','Nenhuma linha de cr&eacute;dito foi selecionada.','Alerta - Ayllos','focaCampoErro(\'btVoltar\',\'divBotoes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
			}
			
			//Código da Finalida
			if ( $GLOBALS["finalida"] == ''){ 
				exibirErro('error','Nenhuma finalidade foi selecionada.','Alerta - Ayllos','focaCampoErro(\'btVoltar\',\'divBotoes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
			}
			
			//Nome do arquivo
			if ( $GLOBALS["nmarquiv"] == ''){ 
				exibirErro('error','Nome do arquivo inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'btVoltar\',\'divBotoes\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
			}
		
		}				
			
	}
	
?>