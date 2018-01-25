<?php
	/*!
	* FONTE        : form_filtros.php
	* DATA CRIAÇÃO : 18/01/2018
	* OBJETIVO     : Filtros para a tela TAB057
	* --------------
	*/

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
  
  $xml = "<Root>";
  $xml .= " <Dados>";
  $xml .= "   <cdcooper>0</cdcooper>";
  $xml .= "   <flgativo>1</flgativo>";
  $xml .= " </Dados>";
  $xml .= "</Root>";

  $xmlResult = mensageria($xml, "TAB057", "TAB057_LISTA_COOPER", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
  $xmlObj = getObjectXML($xmlResult);

  if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
      $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
      if ($msgErro == "") {
          $msgErro = $xmlObj->roottag->tags[0]->cdata;
      }

      exibeErroNew($msgErro);
      exit();
  }

  $registros = $xmlObj->roottag->tags[0]->tags;

  function exibeErroNew($msgErro) {
      echo 'hideMsgAguardo();';
      echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
      exit();
  }
?>

<form id="frmFiltros" name="frmFiltros" class="formulario" width="800px">
	
	<!-- Fieldset para os campos de filtro da consulta -->
	<fieldset id="fsetFiltroConsultar" name="fsetFiltroConsultar" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Filtro</legend>

		<table width="100%">
      <tr>
        <td>
        <label for="tlcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
        <select id="tlcooper" name="tlcooper">
        <option value="0"><? echo utf8ToHtml(' Todas') ?></option> 
        <?php
        foreach ($registros as $r) {
          
          if ( getByTagName($r->tags, 'cdcooper') <> '' ) {
        ?>
          <option value="<?= getByTagName($r->tags, 'cdcooper'); ?>"><?= getByTagName($r->tags, 'nmrescop'); ?></option> 
          
          <?php
          }
        }
        ?>
        </select>
        </td>
      </tr>
			<tr>
				<td>
					<label for="cdempres"><? echo utf8ToHtml('Convênio:') ?></label>
					<input id="cdempres" name="cdempres" type="text"/>
          <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
          <input type="text" id="nmextcon" name="nmextcon" />
        </td>
			</tr>
      <tr>
        <td>
          <label for="dtiniper"><? echo utf8ToHtml('Data:') ?></label>
          <input id="dtiniper" name="dtiniper" type="text"/>
          <label for="dtfimper"><? echo utf8ToHtml(' a ') ?></label>
          <input id="dtfimper" name="dtfimper" type="text"/>
        </td>
      </tr>
      <tr>
        <td>
          <label for="nmarquiv"><? echo utf8ToHtml('Arquivo:') ?></label>
					<input id="nmarquiv" name="nmarquiv" type="text"/>
        </td>
      </tr>
      <tr>
        <td>
          <label for="nrsequen"><? echo utf8ToHtml('Nro. Seq.:') ?></label>
					<input id="nrsequen" name="nrsequen" type="text"/>
        </td>
      </tr>
		</table>
	</fieldset>
</form>
