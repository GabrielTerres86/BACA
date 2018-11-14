<?
/*
 * FONTE        : consulta_situacao_empr.php
 * CRIAÇÃO      : Diego Simas (AMcom)
 * DATA CRIAÇÃO : 02/08/2018
 * OBJETIVO     : Realizar consulta a situação do empréstimo.
   ALTERACOES   :
 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');

	$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
    $nrctremp = (isset($_POST['nrctremp'])) ? str_replace(".","",$_POST['nrctremp']) : 0;    
	
    // pagamento de empréstimo	

	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_ATENDA_DEPOSVIS", "CONSULTA_SIT_EMPR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
    $xmlObjeto = getObjectXML($xmlResult);	

    $param = $xmlObjeto->roottag->tags[0]->tags[0];

    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
        exibirErro('error',utf8ToHtml($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos',"",false);
    }else{
        $inprejuz = getByTagName($param->tags,'inprejuz');	        
        if($inprejuz == 1){
            // Incluido setTimeout pois na formatação da tela escondia o campo, fazendo com que as vezes nao exibia o campo
            echo " setTimeout(function(){ ";
            echo "$('#vlabono', '#frmEmpCC').show();";  
            echo "$('label[for=\'vlabono\']', '#frmEmpCC').show();";
            echo "    }, 150)";
        }else{
            echo " setTimeout(function(){ "; 
            echo "$('#vlabono', '#frmEmpCC').hide();";  
            echo "$('label[for=\'vlabono\']', '#frmEmpCC').hide();";
            echo "    }, 150)";
        }
    }    

?>
