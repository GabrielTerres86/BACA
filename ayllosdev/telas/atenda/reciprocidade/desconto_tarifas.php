<?php
/*************************************************************************
  Fonte: desconto_convenio.php
  Autor: Fabio Stein (Supero)       Ultima atualizacao: 
  Data : Julho/2018
  
  Objetivo: Listar os convenios para desconto de reciprocidade.
  
  Alteracoes: 

*************************************************************************/

session_start();
  
// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");    
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod(); 
    
// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");


// Carrega permissões do operador
include("../../../includes/carrega_permissoes.php");  

if (!isset($_POST["tipo"]) || !isset($_POST["inpessoa"]) || !isset($_POST["convenios"])) {
  exibeErro("Par&acirc;metros incorretos.");
} 
  
$tipo = $_POST["tipo"];
$inpessoa = $_POST["inpessoa"];
$convenios = $_POST["convenios"];

if (!validaInteiro($tipo)) {
  exibeErro("Tipo de tarifa inv&aacute;lido.");
}

if (!validaInteiro($inpessoa)) {
  exibeErro("Tipo de pessoa inv&aacute;lido.");
}

// tipo == 0 (COO)
// tipo == 1 (CEE)
$desTipo = "";
if ($tipo == 0) {
  $cdcatego_liq = array(20, 18);
  $cdcatego_reg = array(24);
  $desTipo = "COO";
} else {
  $cdcatego_liq = array(19);
  $cdcatego_reg = array(23);
  $desTipo = "CEE";
}

// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {
  echo '<script type="text/javascript">';
  echo 'hideMsgAguardo();';
  echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
  echo '</script>';
  exit();
}

function buscaTarifas($nrconven, $cdcatego, $inpessoa) {
  global $glbvars;
  $xml  = "";
  $xml .= "<Root>";
  $xml .= " <Dados>";	
  $xml .= "   <nrconven>".$nrconven."</nrconven>";
  $xml .= "   <cdcatego>".$cdcatego."</cdcatego>";
  $xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
  $xml .= " </Dados>";
  $xml .= "</Root>";

  $xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "BUSCA_TARIFAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
  $xmlObject = getObjectXML($xmlResult);

  if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
    exibeErro(utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata));
  }

  return $xmlObject->roottag->tags[0]->tags;
}

?>
<div id="divResultado" class="closeEvent">
  <div class="divRegistros" style="height: auto; max-height: 285px; overflow-y:auto;">
  <?php
  $contTar = 0;
  foreach ($convenios as $convenio) {
    echo "<div style='padding: 10px 5px;text-align: left;background-color: #CBD1C5;font-weight: bolder;color: #60635d;'>Conv&ecirc;nio $convenio - $desTipo</div>";
    foreach ($cdcatego_liq as $cdcatego) {
  ?>
    <table cellspacing="1" cellpadding="0" bgcolor="#CBD1C5" style="border-collapse: separate;">
      <tr style="background-color:#6B7984;">
          <td class="txtBrancoBold" width="76%" style="color:#fff;padding:2px;">Tarifa: Liquida&ccedil;&atilde;o</td>
          <td class="txtBrancoBold" width="12%" style="color:#fff;padding:2px;">Tarifa Original:</td>
          <td class="txtBrancoBold" width="12%" style="color:#fff;padding:2px;">Tarifa c/ Desc.:</td>
      </tr>
      <?php
        // Listagem das tarifas de liquidação
          $xmlTarifaLiq = buscaTarifas($convenio, $cdcatego, $inpessoa);
          foreach ($xmlTarifaLiq as $tar) {
            $tar_cdtarifa = getByTagName($tar->tags,'CDTARIFA');
            $tar_dstarifa = getByTagName($tar->tags,'DSTARIFA');
            $tar_vltarifa = getByTagName($tar->tags,'VLTARIFA');
            ?>
            <tr style="background-color:#FFFFFF;" class="clsTar<?php echo $desTipo; ?> clsTar<?php echo $contTar; ?>">
                <td class="txtNormal"><?php echo $tar_cdtarifa.' - '.$tar_dstarifa; ?></td>
                <td class="txtNormal clsTarValorOri<?php echo $contTar; ?>"><?php echo formataMoeda($tar_vltarifa); ?></td>
                <td class="txtNormal clsTarValorDes<?php echo $contTar; ?>">0,00</td>
            </tr>
            <?php
            $contTar++;
          }
        ?>
      </table>
  <?php 
    }
  foreach ($cdcatego_reg as $cdcatego) {
  ?>
    <table cellspacing="1" cellpadding="0" bgcolor="#CBD1C5" style="border-collapse: separate;">
      <tr style="background-color:#6B7984;">
          <td class="txtBrancoBold" width="76%" style="color:#fff;padding:2px;">Tarifa: Registro</td>
          <td class="txtBrancoBold" width="12%" style="color:#fff;padding:2px;">Tarifa Original:</td>
          <td class="txtBrancoBold" width="12%" style="color:#fff;padding:2px;">Tarifa c/ Desc.:</td>
      </tr>
      <?php
        // Listagem das tarifas de liquidação
          $xmlTarifaLiq = buscaTarifas($convenio, $cdcatego, $inpessoa);
          foreach ($xmlTarifaLiq as $tar) {
            $tar_cdtarifa = getByTagName($tar->tags,'CDTARIFA');
            $tar_dstarifa = getByTagName($tar->tags,'DSTARIFA');
            $tar_vltarifa = getByTagName($tar->tags,'VLTARIFA');
            ?>
            <tr style="background-color:#FFFFFF;" class="clsTar<?php echo $desTipo; ?> clsTar<?php echo $contTar; ?>">
                <td class="txtNormal"><?php echo $tar_cdtarifa.' - '.$tar_dstarifa; ?></td>
                <td class="txtNormal clsTarValorOri<?php echo $contTar; ?>"><?php echo formataMoeda($tar_vltarifa); ?></td>
                <td class="txtNormal clsTarValorDes<?php echo $contTar; ?>">0,00</td>
            </tr>
            <?php
            $contTar++;
          }
        ?>
      </table>
  <?php 
    }
  }
  ?>
  </div>
</div>

<div id="divBotoes">
  <a href="#" id="btVoltar" class="botao" onclick="sairDescontoConvenio(); return false;">Voltar</a>
</div>

<script type="text/javascript">

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

var ordemInicial = new Array();

var arrayLargura = new Array();
arrayLargura[0] = '20px';
arrayLargura[1] = '80px';
arrayLargura[2] = '200px';
arrayLargura[3] = '80px';


var arrayAlinha = new Array();
arrayAlinha[0] = 'center';
arrayAlinha[1] = 'center';
arrayAlinha[2] = 'left';
arrayAlinha[3] = 'left';

$('body').unbind('click').bind('click', function (ev) {
	if (($(ev.target).find('.closeEvent:visible').length && $('#divBloqueio').is(':visible')) || (ev.target.id == 'divBloqueio'))  {
    sairDescontoConvenio();
  }
  // return false;
})
</script>
