<? 
/*!
 * FONTE        : manter_rotina.php
 * DATA CRIAÇÃO : 23/01/2018
 * OBJETIVO     : Rotina para controlar as operações da tela TAB057
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
 
  session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
  
  $cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
  $seqarfat = (isset($_POST['seqarfat'])) ? $_POST['seqarfat'] : 0;
  $seqtrife = (isset($_POST['seqtrife'])) ? $_POST['seqtrife'] : 0;
  $seqconso = (isset($_POST['seqconso'])) ? $_POST['seqconso'] : 0;
  
  if ($cddopcao == 'A') {
    if ((!isset($_POST['seqarfat'])) || $_POST['seqarfat'] == ''){
      echo 'hideMsgAguardo();';
      echo 'showError("error","Regra An&aacute;lise Autom&aacute;tica PJ &eacute; obrigat&oacute;ria! Favor preench&ecirc;-la","Alerta - Ayllos","$(\'#seqarfat\', \'#frmDadosSicredi\').focus()");';
      exit();
    }
    if ((!isset($_POST['seqtrife'])) || $_POST['seqtrife'] == ''){
      echo 'hideMsgAguardo();';
      echo 'showError("error","Regra An&aacute;lise Autom&aacute;tica PJ &eacute; obrigat&oacute;ria! Favor preench&ecirc;-la","Alerta - Ayllos","$(\'#seqtrife\', \'#frmDadosSicredi\').focus()");';
      exit();
    }
    if ((!isset($_POST['seqconso'])) || $_POST['seqconso'] == ''){
      echo 'hideMsgAguardo();';
      echo 'showError("error","Regra An&aacute;lise Autom&aacute;tica PJ &eacute; obrigat&oacute;ria! Favor preench&ecirc;-la","Alerta - Ayllos","$(\'#seqconso\', \'#frmDadosSicredi\').focus()");';
      exit();
    }
    
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
    $xml .= "   <seqarfat>".$seqarfat."</seqarfat>";
    $xml .= "   <seqtrife>".$seqtrife."</seqtrife>";
    $xml .= "   <seqconso>".$seqconso."</seqconso>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TAB057", "TAB057_UPD_SEQS_SICREDI", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    
    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
      $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
      if ($msgErro == "") {
          $msgErro = $xmlObj->roottag->tags[0]->cdata;
      }

      exibeErroNew($msgErro);
      exit();
    }
    
    echo 'showError("inform","Parametro alterado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';

  }
  function exibeErroNew($msgErro) {
    echo 'hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
    exit();
  }
?>
