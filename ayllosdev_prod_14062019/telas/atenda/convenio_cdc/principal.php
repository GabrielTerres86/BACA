<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Andre Santos (SUPERO)
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Mostrar opcao Principal da rotina de Liberar/Bloquear da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 24/08/2015 - Projeto Reformulacao cadastral		   
 *						  	  (Tiago Castro - RKAM)			 
 *
 *                11/08/2016 - Inclusao de campos para apresentacao no site da cooperativa.
 *                             (Jaison/Anderson)
 *
 *	              29/11/2017 - Inclusão de novos parametros, Prj. 402 (Jean Michel).
 *
 * --------------
 */	

	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();	
		
	$cddopcao        = (isset($_POST['cddopcao']))        ? $_POST['cddopcao']        : 'P' ;
	$operacao        = (isset($_POST['operacao']))        ? $_POST['operacao']        : '' ;
	$nrdconta        = (isset($_POST['nrdconta']))        ? $_POST['nrdconta']        : 0  ;
    $inpessoa        = (isset($_POST['inpessoa']))        ? $_POST['inpessoa']        : 0  ;
    $idmatriz        = (isset($_POST['idmatriz']))        ? $_POST['idmatriz']        : 0  ;
    $idcooperado_cdc = (isset($_POST['idcooperado_cdc'])) ? $_POST['idcooperado_cdc'] : 0  ;

    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
    $xml .= "   <idmatriz>".$idmatriz."</idmatriz>";
    $xml .= "   <idcooperado_cdc>".$idcooperado_cdc."</idcooperado_cdc>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_ATENDA_CVNCDC", "CVNCDC_BUSCA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Aimaro','estadoInicial()', false);
    }

    $registro           = $xmlObject->roottag->tags[0];
	$flgconve           = getByTagName($registro->tags,'FLGCONVE');
	$dtinicon           = getByTagName($registro->tags,'DTINICON');
	$inmotcan           = getByTagName($registro->tags,'INMOTCAN');
	$dtcancon           = getByTagName($registro->tags,'DTCANCON');
	$dsmotcan           = getByTagName($registro->tags,'DSMOTCAN');
	$dtrencon           = getByTagName($registro->tags,'DTRENCON');
  $dtacectr           = getByTagName($registro->tags,'DTACECTR');
	$dttercon           = getByTagName($registro->tags,'DTTERCON');
    $idcooperado_cdc    = getByTagName($registro->tags,'IDCOOPERADO_CDC');
    $nmfantasia         = getByTagName($registro->tags,'NMFANTASIA');
    $cdcnae             = getByTagName($registro->tags,'CDCNAE');
    $dslogradouro       = getByTagName($registro->tags,'DSLOGRADOURO');
    $dscomplemento      = getByTagName($registro->tags,'DSCOMPLEMENTO');
    $nrendereco         = getByTagName($registro->tags,'NRENDERECO');
    $nmbairro           = getByTagName($registro->tags,'NMBAIRRO');
    $nrcep              = getByTagName($registro->tags,'NRCEP');
    $cdufende           = getByTagName($registro->tags,'CDUFENDE');
    $idcidade           = getByTagName($registro->tags,'IDCIDADE');
    $dscidade           = getByTagName($registro->tags,'DSCIDADE');
    $cdestado           = getByTagName($registro->tags,'CDESTADO');
    $dstelefone         = getByTagName($registro->tags,'DSTELEFONE');
    $dsemail            = getByTagName($registro->tags,'DSEMAIL');
  $nrlatitude 		    = str_replace(".",",",getByTagName($registro->tags,'NRLATITUDE'));
  $nrlongitude 		    = str_replace(".",",",getByTagName($registro->tags,'NRLONGITUDE'));
  $idcomissao         = getByTagName($registro->tags,'IDCOMISSAO');
    $nmcomissao         = getByTagName($registro->tags,'NMCOMISSAO');
  $flgitctr           = getByTagName($registro->tags,'FLGITCTR');

  switch ($cddopcao) {
    case "P": //PRINCIPAL
	include('form_convenio_cdc.php');
      break;
    case "S": //SEGMENTOS
      $xml  = "<Root>";
      $xml .= " <Dados>";
      $xml .= "   <idcooperado_cdc>".$idcooperado_cdc."</idcooperado_cdc>";
      $xml .= " </Dados>";
      $xml .= "</Root>";

      $xmlResult = mensageria($xml, "TELA_ATENDA_CVNCDC", "LISTA_SUBSEGMENTOS_COOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
      $xmlObject = getObjectXML($xmlResult);

      if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Aimaro','estadoInicial()', false);
      }
      $subsegmentos = $xmlObject->roottag->tags[0]->tags[1]->tags;
		
      include('form_segmento_cdc.php');
      
      break;
    case "V": //VENDEDORES        
      $xml  = "<Root>";
      $xml .= " <Dados>";
      $xml .= "   <idcooperado_cdc>".$idcooperado_cdc."</idcooperado_cdc>";
      $xml .= " </Dados>";
      $xml .= "</Root>";

      $xmlResult = mensageria($xml, "TELA_ATENDA_CVNCDC", "LISTA_VENDEDORES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
      $xmlObject = getObjectXML($xmlResult);

      if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Aimaro','estadoInicial()', false);
      }
      $vendedores = $xmlObject->roottag->tags[0]->tags[1]->tags;
		
      include('form_vendedores.php');
      
      break;
    case "U": //USUARIOS
      $xml  = "<Root>";
      $xml .= " <Dados>";
      $xml .= "   <idcooperado_cdc>".$idcooperado_cdc."</idcooperado_cdc>";
      $xml .= " </Dados>";
      $xml .= "</Root>";

      $xmlResult = mensageria($xml, "TELA_ATENDA_CVNCDC", "LISTA_USUARIOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
      $xmlObject = getObjectXML($xmlResult);

      if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Aimaro','estadoInicial()', false);
      }
      $usuarios = $xmlObject->roottag->tags[0]->tags[1]->tags;
		
      include('form_usuarios.php');
      
      break;
    default:
      include('form_convenio_cdc.php');
      break;
  } 
?>
<script>
    var idmatriz = '<?php echo $idmatriz; ?>';
    var operacao = '<?php echo $operacao; ?>';
	controlaLayout(operacao);
</script>
