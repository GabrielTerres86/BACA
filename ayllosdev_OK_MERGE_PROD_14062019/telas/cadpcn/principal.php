<?php
/*!
 * FONTE        : principal.php
 * CRIA��O      : Andr� (DB1)
 * DATA CRIA��O : Janeiro/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de identifica��o jur�dica da tela de CONTAS 
 * --------------
 * ALTERA��ES   :
 * --------------
 * 001: [24/03/2010] Rodolpho Telmo  	(DB1): Adequa��o no novo padr�o
 * 002: [20/12/2010] Gabriel Capoia  	(DB1): Chamada fun��o validaPermissao
 * 003: [03/08/2015] Gabriel        	(RKAM): Reformulacao cadastral
 * 003: [21/03/2018] Andr� �vila    	(RKAM): Utiliza��o parte do c�digo para cria��o de uma nova fun��o CADPCN
  */
?>

<?php	

	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
	//setVarSession("nmrotina","CADPCN");
	setVarSession("nmrotina","");

	isPostMethod();	

	$operacao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';

	switch( $operacao ) {
		case 'C' : $op = "C"; break;
		case 'A' : $op = "A"; break;
		case 'I' : $op = "I"; break;
		case 'E' : $op = "E"; break;
	}
	
    $dsmsgseg   = (isset($_POST['dsmsgseg'])) ? $_POST['dsmsgseg'] : '';
	$procedure = "";

	// Verifica permiss�es de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$op)) <> "") exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);


	// Verifica se o n�mero do CNAE
	if (!isset($_POST["cdcnae"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	$cdcnae = $_POST["cdcnae"] == "" ? 0  : $_POST["cdcnae"];
	$vlcnae = $_POST["vlcnae"] == "" ? 0  : $_POST["vlcnae"];
		
    //if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	// Dependendo da opera��o, chamo uma procedure diferente
	switch($operacao) {

		case 'I': $procedure_acao = 'CADPCN_INCLUSAO'; 	break;		//pr_cdcooper,pr_cdcnae,pr_vlmaximo,pr_cdoperad
		case 'A': $procedure_acao = 'CADPCN_ALTERACAO'; break;		//pr_cdcooper,pr_cdcnae,pr_vlmaximo,pr_cdoperad
		case 'E': $procedure_acao = 'CADPCN_EXCLUSAO'; 	break;		//pr_cdcooper,pr_cdcnae,pr_vlmaximo,pr_cdoperad
		case 'C': $procedure_acao = 'CADPCN_BUSCAR'; 	break;		//pr_cdcooper,pr_cdcnae,pr_vlmaximo,pr_cdoperad
	}

	$nmdatela = 'CADPCN';
	$vlcnae = converteFloat($vlcnae,'float');

	// Monta o xml de requisi��o		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <cdcnae>".$cdcnae."</cdcnae>";

	if($operacao == "I" || $operacao == "A"){
		$xml 	   .= "     <vlmaximo>".$vlcnae."</vlmaximo>";
	}

	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "CADPCN", $procedure_acao,  $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		
		$msgErro =  $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;

		echo $msgErro;


	} elseif($operacao == 'E'){ 

		$valor_cnae = $xmlObjeto->roottag->tags[1]->cdata == "" ? 0  : $xmlObjeto->roottag->tags[1]->cdata;
		echo($valor_cnae);

	} elseif($operacao == 'I'){ 

		$msgOK = "Dados inclu&iacute;dos com sucesso";
		exibirErro('inform',$msgOK,'Alerta - Ayllos',"estadoInicial();",true);	

	} elseif($operacao == 'A'){ 

		$valor_cnae = $xmlObjeto->roottag->tags[1]->cdata == "" ? 0  : $xmlObjeto->roottag->tags[1]->cdata;
		//$valor_cnae = number_format($valor_cnae, 2, ',', ' ');
		echo($valor_cnae);
		

	} elseif($operacao == 'C'){ 

		$valor_cnae = $xmlObjeto->roottag->tags[2]->cdata == "" ? ""  : $xmlObjeto->roottag->tags[2]->cdata;

		if($valor_cnae <> "" ){

			echo($valor_cnae);
		}
	}
?>
