<?php
   /* FONTE        : busca_descricao.php
 * CRIAÇÃO      : Rodolpho Telmo ( DB1 )
 * DATA CRIAÇÃO : Fevereiro/2010 
 * OBJETIVO     : Efetuar a busca da descrição de algum código passado como parâmetro. 
 *                Chamada no evento (onBlur) do código de algum campo.
 * --------------
 * ALTERAÇÕES   :
 * --------------
	* 001: [25/03/2010] Rodolpho Telmo (DB1): Alterada função "buscaDescricao" acrescentando os parâmetros "campoRetorno" e "filtros"
	* 002: [31/03/2010] Rodolpho Telmo (DB1): Alterada função "buscaDescricao" acrescentando o parâmetro "nomeFormulario"
	* 003: [22/10/2020] David			(CECRED) : Incluir novo parametro para a funcao getDataXML (David).
 * 004: [17/07/2015] Gabriel        (RKAM): Suporte para chamar rotinas Oracle.
	* 005: [27/07/2016] Carlos R.	    (CECRED): Corrigi o tratamento para o retorno de erro do XML. SD 479874.
    * 006: [06/06/2017] Jonata        (Mouts): Ajuste para inclusão da busca de dominios - P408.
	* 007: [13/08/2017] Jonata       (Mouts): Ajuste para incluir a passagem de novo parâmetro na rotina buscaDescricao - P364.
 * 008 [14/12/2017] Odirlei Busana (AMcom): Ajustado para não validar numerico para BUSCA_DESC_CONVEN. PRJ406 - FGTS
 */	

	session_start();
	require_once("../config.php");
	require_once("../funcoes.php");
	require_once("../controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();		
	
	// Verifica se os par&acirc;metros de desenvolvimento necess&aacute;rios 
	if (!isset($_POST["businessObject"]) || 
	     !isset($_POST["nomeProcedure" ]) || 
		 !isset($_POST["tituloPesquisa"]) ||
		 !isset($_POST["campoCodigo"   ]) || 
		 !isset($_POST["campoDescricao"]) ||
		 !isset($_POST["campoRetorno"  ]) ) { 
		 exibirErro('error','Par&acirc;metros incorretos para a pesquisa.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	}
    
	// Pega os valores nas devidas vari&aacute;veis
	$businessObject  = $_POST["businessObject"];
	$nomeProcedure   = $_POST["nomeProcedure" ];
	$tituloPesquisa  = $_POST["tituloPesquisa"];
	$campoCodigo 	 = $_POST["campoCodigo"   ];
	$campoDescricao	 = $_POST["campoDescricao"];
	$campoRetorno	 = $_POST["campoRetorno"  ];
	$filtros	 	 = $_POST["filtros"       ];	
	$nomeFormulario  = $_POST["nomeFormulario"];
	$executaMetodo   = $_POST["executaMetodo"];
	 
	// Verifica o par&acirc;metro c&oacute;digo
	if ( !isset($_POST["codigoAtual"]) ) exibirErro('error','Par&acirc;metro c&oacute;digo para pesquisa '.$tituloPesquisa.' n&atilde;o foi informado.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Inicializando vari&aacute;veis
	$codigo    = $_POST["codigoAtual"];
	$descricao = "";
	$nriniseq  = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 1;
	$nrregist  = 10;		

	// Valida c&oacute;digo
	if ($codigo == "0") exibirErro('error','O c&oacute;digo '.$tituloPesquisa.' deve ser diferente de zero.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	if (($nomeProcedure != 'BUSCA_ORGAO_EXPEDIDOR' && $nomeProcedure != 'BUSCA_DESC_CONVEN') && !validaInteiro($codigo)) exibirErro('error','C&oacute;digo '.$tituloPesquisa.' inv&aacute;lido, informe somente n&uacute;meros. Valor informado: '.$codigo.'.','Alerta - Ayllos','if( $(\'#divMatric\').css(\'display\') == \'block\' || $(\'#divTela\').css(\'display\') == \'block\' ) { unblockBackground(); }else{ bloqueiaFundo(divRotina); }',false);
	
	
	// Verifica se e' uma rotina Progress ou Oracle
	$flgProgress = (substr($businessObject,0,6) == 'b1wgen');
	
	$xml  = "";
	$xml .= "<Root>";
	
	if ($flgProgress) {
		$xml .= "  <Cabecalho>";
		$xml .= "	    <Bo>".$businessObject."</Bo>";
		$xml .= "        <Proc>".$nomeProcedure."</Proc>";
		$xml .= "  </Cabecalho>";
	}
	
	$xml .= "  <Dados>";
	
	if ($flgProgress) {
		$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";		
	}

	$xml .= "		<".$campoCodigo.">".$codigo."</".$campoCodigo.">";
	$xml .= "		<".$campoDescricao.">".$descricao."</".$campoDescricao.">";
	
	if ( $filtros != '' ) {
		
		$array = explode("|", $filtros);
		foreach( $array as $itens ) {		
			
			// Explodo a variavel para obter seu nome e valor
			$opcao = explode(";", $itens);		
			
			// Recebendo os valores
			$nome	= $opcao[0];
			$valor	= $opcao[1];
			
			// Inserindo no XML
			$xml .= "		<".$nome.">".$valor."</".$nome.">";
		}
	}
	
	if ($flgProgress) {
		$xml .= "		<nriniseq>".$nriniseq."</nriniseq>";
		$xml .= "		<nrregist>".$nrregist."</nrregist>";
	}
		
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	if ($flgProgress) {
		$xmlResult = getDataXML($xml,false);
	} else {
		$xmlResult = mensageria($xml, $businessObject, $nomeProcedure, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	}
		
	// Cria objeto para classe de tratamento de XML
	$xmlObjdescricao = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjdescricao->roottag->tags[0]->name) && strtoupper($xmlObjdescricao->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjdescricao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	}
	
	$descricao = ( isset($xmlObjdescricao->roottag->tags[0]->tags[0]->tags) ) ? $xmlObjdescricao->roottag->tags[0]->tags[0]->tags : array();
	
	if (count($descricao) == 0) {		
		// Atribui descrição ao respectivo campo
		echo '$("input[name=\''.$campoDescricao.'\']").val("");';

		if( $nomeProcedure == 'BUSCADESCDOMINIOS' ){
			echo '$("input[id=\'iddominio_'.$campoCodigo.'\']").val("");';
		}
			
		if ( $nomeFormulario != '' ) {				
			echo '$("#'.$campoCodigo.'","#'.$nomeFormulario.'").addClass("campoErro");';
			exibirErro('error','N&atilde;o h&aacute; '.$tituloPesquisa.' com o c&oacute;digo informado.','Alerta - Ayllos','if( $(\'#divMatric\').css(\'display\') == \'block\' || $(\'#divTela\').css(\'display\') == \'block\' ) { desbloqueia(\''.$campoCodigo.'\',\''.$nomeFormulario.'\'); } else { bloqueiaFundo(divRotina,\''.$campoCodigo.'\',\''.$nomeFormulario.'\'); }',false);
		} else {
			echo '$("input[name=\''.$campoCodigo.'\']").addClass("campoErro");';
			exibirErro('error','N&atilde;o h&aacute; '.$tituloPesquisa.' com o c&oacute;digo informado.','Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
		} 
	}
	
	// Volta a formatação padrão para o campo código
	echo '$("input[name=\''.$campoCodigo.'\']").removeClass("campoErro");';
	// Atribui descrição ao respectivo campo
	echo '$("input[name=\''.$campoDescricao.'\']").val("'.getByTagName($descricao,$campoRetorno).'");';
	    	
	if( $nomeProcedure == 'BUSCADESCDOMINIOS' ){
		echo '$("input[id=\'iddominio_'.$campoCodigo.'\']").val("'.getByTagName($descricao,"iddominio").'");';
		
		if($campoCodigo == 'idgarantia' || $campoCodigo == 'idconta_cosif'){
			
		echo '$("#idconta_cosif","#'.$nomeFormulario.'").val("'.getByTagName($descricao,"nrctacosif").'");';
		echo '$("#dsconta_cosif","#'.$nomeFormulario.'").val("'.getByTagName($descricao,"dsctacosif").'");';
		echo '$("#iddominio_idconta_cosif","#'.$nomeFormulario.'").val("'.getByTagName($descricao,"iddominioctacosif").'");';
			
		}
	}
	
	if( $nomeProcedure == 'BUSCADESCASSOCIADO' ){
		echo 'if($("input[id=\'cdclassificacao_produto\']","#'.$nomeFormulario.'").val() != "AA"){ $("select[id=\'cdclassifica_operacao\']","#'.$nomeFormulario.'").prop(\'selected\',true).val("'.getByTagName($descricao,"dsnivris").'");}';
		echo '$("#nrcpfcgc","#'.$nomeFormulario.'").val("'.getByTagName($descricao,"nrcpfcgc").'");';
		
	}
	
	if ( $campoCodigo == 'cdfinemp' ) {
		echo '$(\'input[name="tpfinali"]\').val("'.getByTagName($descricao,'tpfinali').'");';
	}
	
	if ( $nomeFormulario == 'frmSimulacao' ) {            
		echo 'habilitaModalidade("'.getByTagName($descricao,'tpfinali').'");';
	}
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'bloqueiaFundo(divRotina);';
	echo 'if( $(\'#divMatric\').css(\'display\') == \'block\' || $(\'#divTela\').css(\'display\') == \'block\' ) { unblockBackground(); }';

	//Efetua a chamada das rotinas passadas para serem executadas
	if($executaMetodo != ''){
		
		echo ''.$executaMetodo.'';

	}
?>	
