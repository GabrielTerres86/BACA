<?
/*!
 * FONTE        : monta_select.php
 * CRIAÇÃO      : Gabriel C. dos Santos - DB1 Informatica
 * DATA CRIAÇÃO : Março/2010 
 * OBJETIVO     : Montar dinamicamente selects de acordo com os parametros
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [19/04/2010] Rodolpho Telmo (DB1): Alterada função "montaSelect" acrescentando o parâmetro "filtros"
 * 002: [22/04/2010] Rodolpho Telmo (DB1): Acrescentado o parâmetro "retornoAdicional" que será inserido na propriedade "alt" de cada option
 * 003: [22/10/2010] David       (CECRED): Incluir novo parametro para a funcao getDataXML (David).
 * 004: [21/07/2015] Gabriel       (RKAM): Suporte para chamar rotinas Oracle.
 */
?>

<?	
	session_start();
	require_once("../config.php");
	require_once("../funcoes.php");
	require_once("../controla_secao.php");
	require_once("../../class/xmlfile.php");	
	isPostMethod();	
	
	// Verifica se os parâmetros de desenvolvimento necessávios
	if ( !isset($_POST["businessObject"  ]) || 
	     !isset($_POST["nomeProcedure"   ]) || 
		 !isset($_POST["campoTela"       ]) ||
		 !isset($_POST["valorRetorno"    ]) ||
		 !isset($_POST["descricaoRetorno"]) ) { 
		 exibirErro("Par&acirc;metros incorretos para a pesquisa."); 
	}
	
	// Pega os valores nas devidas variáveis
	$businessObject	  = $_POST["businessObject"  ];
	$nomeProcedure	  = $_POST["nomeProcedure"   ];
	$campoTela	      = $_POST["campoTela"       ];
	$valorRetorno	  = $_POST["valorRetorno"    ];
	$descricaoRetorno = $_POST["descricaoRetorno"];
	$filtros	 	  = $_POST["filtros"         ];	
	$retornoAdicional = $_POST["retornoAdicional"];	
	
	// Verifica se e' uma rotina Progress ou Oracle
	$flgProgress = (substr($businessObject,0,6) == 'b1wgen');
	
	// Monta o xml de requisição
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
	
		$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	
	}
	
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
	
	$xml .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<nriniseq>1</nriniseq>";
	$xml .= "		<nrregist>100</nrregist>";	
	$xml .= "  </Dados>";
	$xml .= "</Root>";			
	
	// Executa script para envio do XML e Cria objeto para classe de tratamento de XML	
	if ($flgProgress) {
		$xmlResult = getDataXML($xml,false);
	} else {
		$xmlResult = mensageria($xml, $businessObject, $nomeProcedure, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	}
	
	$xmlObjConjuge = getObjectXML($xmlResult);
	$registros = $xmlObjConjuge->roottag->tags[0]->tags;
?>
<option value="" selected> - </option>
<? 	
for ($i = 0; $i < count($registros); $i++) {		
	$resultado    = $registros[$i]->tags;	
	$valor		  = '';
	$descricao    = '';
	$adicional    = '';
	
	// Obtém o valor do option
	$valor = getByTagName($resultado,$valorRetorno);
	
	// Obtém a descrição do option	
	$arrayFiltros = explode(';', $descricaoRetorno);	
	foreach( $arrayFiltros as $itemDescricao ) {
		$descricao .= ($descricao == '') ? getByTagName($resultado,$itemDescricao) : ' - '.getByTagName($resultado,$itemDescricao);
	}
	
	// ALTERAÇÃO 002
	// Obtém os retornos adicionais do option	
	$arrayAdicional = explode(';', $retornoAdicional);
	foreach( $arrayAdicional as $itemAdicional ) {
		$adicional .= ($adicional == '') ? getByTagName($resultado,$itemAdicional) : ';'.getByTagName($resultado,$itemAdicional);
	}
	
	?> <option value="<? echo $valor; ?>" alt="<? echo $adicional; ?>"><? echo htmlentities($descricao); ?></option> <?
}
?>