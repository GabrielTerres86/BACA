<? 
/*!
 * FONTE        : busca_cooperativas.php
 * CRIAÇÃO      : Renato Darosci - Supero
 * DATA CRIAÇÃO : 05/06/2015 
 * OBJETIVO     : Rotina para busca as cooperativas a serem listadas
 * ALTERAÇÕES   : 21/10/2015 - Envio da opção "@" na validaPermissao (Marcos-Supero)
 */
?>
 
<?
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
	
	// Verifica Permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],"","@")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','voltar()',false);
	}	
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "PAGFOL", "CONSCOOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");	
	$xmlObjeto 	= getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}

	// Agrupar nós num array
	$tagsCoop = $xmlObjeto->roottag->tags;
	$tamArray = count($tagsCoop);

	echo 'cCdcooper.empty();';
	
	// Percorrer cada nó do xml - cada um é uma cooperativa retonada
	for ($i = 0;$i < $tamArray; $i++) {	
		echo 'cCdcooper.append(\'<option value="'.$tagsCoop[$i]->tags[0]->cdata.'">'.$tagsCoop[$i]->tags[1]->cdata.'</option>\');';		
	}
		
	// Se o tamanho do array for 1, bloqueia o campo
	if ($tamArray == 1) {
		echo 'cCdcooper.desabilitaCampo();';
		echo 'cCdempres.focus();';
	} else {
		echo 'cCdcooper.habilitaCampo();';
	}
	
?>
