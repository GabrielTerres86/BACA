<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Lucas R. (CECRED)
 * DATA CRIAÇÃO : Julho/2013
 * OBJETIVO     : Mostrar opcao Principal da rotina de imunidade tributaria da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :20/09/2013 - Corrigindo os campos cddentid e cdsitcad
							  para exibir os dados que vem da base e mostrar corretamente
							  na tela (André Santos/ SUPERO)
				 
				 30/10/2013 - Incluir campo $opcao passado por POST (Lucas R.)
				 
				 06/08/2015 - Reformulacao Cadastral (Gabriel-RKAM)
				 
 */	
?>

<?	
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
		
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$opcao    = $_POST["cddopcao"];
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';	

	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$opcao)) <> "") exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);	
		
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0159.p</Bo>";					
	$xml .= "		<Proc>consulta-imunidade-contas</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjRegistro = getObjectXML($xmlResult);
	
	$registro = $xmlObjRegistro->roottag->tags[0]->tags;
		
    if (strtoupper($xmlObjRegistro->roottag->tags[0]->name) == 'ERRO') {
        exibirErro('error',$xmlObjRegistro->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
    }
	
    if (getByTagName($registro[0]->tags,'cddentid') == 0) {
        $cddentid = 99;
    }else{
        $cddentid = getByTagName($registro[0]->tags,'cddentid');
    }
    
	if (getByTagName($registro[0]->tags,'cdsitcad') == 0 &&
        getByTagName($registro[0]->tags,'cddentid') == 0 ) {
        $cdsitcad = 99;
    }else{
        $cdsitcad = getByTagName($registro[0]->tags,'cdsitcad');
    }
	    
	include('form_imunidade_tributaria.php');

?>


