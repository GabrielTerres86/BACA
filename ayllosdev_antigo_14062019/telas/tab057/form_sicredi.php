<?php
	/*!
	* FONTE        : form_sicredi.php
	* DATA CRIAÇÃO : 22/01/2018
	* OBJETIVO     : Formulario de consulta e alteração de dados
	*
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
  
  $cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
  $cdempres = (isset($_POST['cdempres'])) ? $_POST['cdempres'] : 0;
	
  
  $xml = "<Root>";
  $xml .= " <Dados>";
  $xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
  $xml .= " </Dados>";
  $xml .= "</Root>";

  $xmlResult = mensageria($xml, "TAB057", "TAB057_SEQS_SICREDI", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
  $xmlObj = getObjectXML($xmlResult);
  
  if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
      $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
      if ($msgErro == "") {
          $msgErro = $xmlObj->roottag->tags[0]->cdata;
      }

      echo 'hideMsgAguardo();';
      echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
      exit();
  }

  $registros = $xmlObj->roottag->tags[0]->tags[1]->tags;
?>

<form id="frmDadosSicredi" name="frmDadosSicredi" class="formulario">
	<div id="divDadosSicredi" >

		<!-- Fieldset para os campos de DADOS GERAIS-->
		<fieldset id="fsetDadosSicredi" name="fsetDadosSicredi" style="padding-bottom:10px;">
			
			<legend>Dados Sicredi</legend>

			<table width="100%">
				<tr>
					<td>
						<label for="seqarfat"><? echo utf8ToHtml('Seq. Arq. Arrec. Faturas:') ?></label>
						<input id="seqarfat" name="seqarfat" type="text" value="<?php echo getByTagName($registros,'seqarfat') ?>"/>
					</td>
				</tr>
        <tr>
          <td>
            <label for="seqtrife"><? echo utf8ToHtml('Seq. Arq. Trib. Federal:') ?></label>
						<input id="seqtrife" name="seqtrife" type="text" value="<?php echo getByTagName($registros,'seqtrife') ?>"/>
					</td>
        </tr>
				<tr>
          <td>
						<label for="seqconso"><? echo utf8ToHtml('Seq. Arq. Atualização Consórcios:') ?></label>
						<input id="seqconso" name="seqconso" type="text" value="<?php echo getByTagName($registros,'seqconso') ?>"/>
					</td>
				</tr>
			</table>
		</fieldset>
	</div>
</form>
