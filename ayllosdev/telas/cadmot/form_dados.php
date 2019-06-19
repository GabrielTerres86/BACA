<?php
/* !
 * FONTE        : form_dados.php
 * CRIAÇÃO      : Christian Grauppe - ENVOLTI
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : Mostrar tela CADMOT
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

session_start();
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
isPostMethod();

require_once("../../class/xmlfile.php");

$indrowid     = (isset($_POST['indrowid']))     ? $_POST['indrowid'] : '';
$regIdmotivo  = (isset($_POST['regIdmotivo']))  ? $_POST['regIdmotivo'] : '';
$regDsmotivo  = (isset($_POST['regDsmotivo']))  ? utf8ToHtml($_POST['regDsmotivo']) : '';
$regCdproduto = (isset($_POST['regCdproduto'])) ? $_POST['regCdproduto'] : '';
$regFlgreserva_sistema = (isset($_POST['regFlgreserva_sistema'])) ? $_POST['regFlgreserva_sistema'] : '';
$regFlgativo  = (isset($_POST['regFlgativo'])) ? $_POST['regFlgativo'] : '';
$regFlgtipo   = (isset($_POST['regFlgtipo']))  ? $_POST['regFlgtipo'] : '';
$regFlgexibe  = (isset($_POST['regFlgexibe'])) ? $_POST['regFlgexibe'] : '';

// Monta o xml de requisição
$xml  = '';
$xml .= '<Root>';
$xml .= '   <Dados>';
$xml .= '       <nrregist>500</nrregist>';
$xml .= '       <nriniseq>1</nriniseq>';
$xml .= '   </Dados>';
$xml .= '</Root>';

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = mensageria($xml, "CADMOT", "LISTA_COMBO_PRODUTOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
	$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro);
}

$registros = $xmlObjeto->roottag->tags;
//echo $xmlResult; die;

$combo = '<option value="" >Selecione</option>';
foreach( $registros as $produto ) {
	$cdProduto = getByTagName($produto->tags,'cdproduto');
	$dsProduto = getByTagName($produto->tags,'dsproduto');
	$combo .= '
	<option value="'.$cdProduto.'" '. (($regCdproduto == $cdProduto) ? 'selected="selected"' : '' ). ' >'.$dsProduto.'</option>';
}
?>
<form id="frmDados" name="frmDados" class="formulario" onSubmit="return false;" style="display:block;">

  <br style="clear:both" />

  <fieldset style="width:95%;">
    <legend align="left">
      <?php echo 'Dados do Motivo' ?>
    </legend>

    <input type="hidden" id="indrowid" name="indrowid" value="<? echo $indrowid; ?>" />

    <label for="idmotivo">
      <? echo utf8ToHtml('Id Motivo:') ?>
    </label>
    <input id="idmotivo" name="idmotivo" type="text" value="<? echo $regIdmotivo; ?>" disabled="disabled" />

    <br style="clear:both" />

    <label for="dsmotivo">
      <? echo utf8ToHtml('Descri&ccedil;&atilde;o:') ?>
    </label>
    <input id="dsmotivo" name="dsmotivo" type="text" value="<? echo $regDsmotivo; ?>" />

    <br style="clear:both" />

    <label for="cdproduto">
      <? echo utf8ToHtml('Produto:') ?>
    </label>
    <select id="cdproduto" name="cdproduto">
      <? echo $combo; ?>
    </select>

    <br style="clear:both" />

    <label for="flgreserva_sistema">
      <? echo utf8ToHtml('Reservado Sistema:') ?>
    </label>
    <select id="flgreserva_sistema" name="flgreserva_sistema">
      <option value="1"
        <? echo $regFlgreserva_sistema == '1' ? 'selected' : '' ?> >
        <? echo utf8ToHtml('Sim') ?>
      </option>
      <option value="0"
        <? echo $regFlgreserva_sistema == '0' ? 'selected' : '' ?> ><? echo utf8ToHtml('N&atilde;o') ?>
      </option>
    </select>

    <br style="clear:both" />

    <label for="flgativo">
      <? echo utf8ToHtml('Ativo:') ?>
    </label>
    <select id="flgativo" name="flgativo">
      <option value=""
        <? echo $regFlgativo == '' ? 'selected' : '' ?> >-- Selecione --
      </option>
      <option value="1"
        <? echo $regFlgativo == '1' ? 'selected' : '' ?> >
        <? echo utf8ToHtml('Sim') ?>
      </option>
      <option value="0"
        <? echo $regFlgativo == '0' ? 'selected' : '' ?> ><? echo utf8ToHtml('N&atilde;o') ?>
      </option>
    </select>

    <br style="clear:both"/>

    <label for="flgexibe">
      <? echo utf8ToHtml('Exibe:') ?>
    </label>
    <select id="flgexibe" name="flgexibe">
      <option value=""
        <? echo $regFlgexibe == '' ? 'selected' : '' ?>>-- Selecione --
      </option>
      <option value="1"
        <? echo $regFlgexibe == '1' ? 'selected' : '' ?> >
        <? echo utf8ToHtml('Sim') ?>
      </option>
      <option value="0"
        <? echo $regFlgexibe == '0' ? 'selected' : '' ?> ><? echo utf8ToHtml('N&atilde;o') ?>
      </option>
    </select>

    <br style="clear:both"/>

    <label for="flgtipo">
      <? echo utf8ToHtml('Tipo:') ?>
    </label>
    <select id="flgtipo" name="flgtipo">
      <option value=""
        <? echo $regFlgativo == '' ? 'selected' : '' ?> >-- Selecione --
      </option>
      <option value="0"
        <? echo $regFlgtipo == '0' ? 'selected' : '' ?> >
        <? echo utf8ToHtml('Bloqueio') ?>
      </option>
      <option value="1"
        <? echo $regFlgtipo == '1' ? 'selected' : '' ?> >
        <? echo utf8ToHtml('Desbloqueio') ?>
      </option>
    </select>

    <br style="clear:both"/>

  </fieldset>


  <br style="clear:both"/>

  <div id="divBotoes">
    <input type="image" src="<?php echo $UrlImagens; ?>botoes/ok.gif"     onClick="gravarMotivo();return false;"/>
    <input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="encerraRotina(true);return false;"/>
  </div>

</form>

<script type="text/javascript">
  // Bloqueia o conteudo em volta da divRotina
  blockBackground(parseInt($("#divRotina").css("z-index")));
</script>