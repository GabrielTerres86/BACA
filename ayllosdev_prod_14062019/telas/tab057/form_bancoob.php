<?php
	/*!
	* FONTE        : form_bancoob.php
	* DATA CRIAÇÃO : 29/01/2018
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
	
	if ($cdcooper != 0 && $cdempres != 0) {
  
	  $xml = "<Root>";
	  $xml .= " <Dados>";
	  $xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
	  $xml .= "   <cdempres>".$cdempres ."</cdempres>";
	  $xml .= " </Dados>";
	  $xml .= "</Root>";

	  $xmlResult = mensageria($xml, "TAB057", "TAB057_SEQS_BANCOOB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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

	  $registros = $xmlObj->roottag->tags[0]->tags[2]->tags;
	}
?>
<form id="frmDadosBancoob" name="frmDadosBancoob" class="formulario">
	<div id="divDadosBancoob" >

		<!-- Fieldset para os campos de DADOS GERAIS-->
		<fieldset id="fsetDadosBancoob" name="fsetDadosBancoob" style="padding-bottom:10px;">
			
			<legend>Sequencial</legend>

			<table width="100%">
				<tr>
					<td> 
						<label for="seqarnsa" class="txtNormalBold rotulo" style="width: 90px;"><? echo utf8ToHtml('Próxima Seq.:') ?></label>
						<input id="seqarnsa" name="seqarnsa" type="text" class="inteiro campo" style="width: 60px; text-align: right;" value="<?php echo getByTagName($registros,'seqarnsa') ?>"/>
					</td>
				</tr>
			</table>
		</fieldset>
	</div>
</form>
<script type="text/javascript">
	/*$('#btVoltar','#divBotoes').css('display','inline');
	$('#btSalvar','#divBotoes').css('display','none');*/
	
	// Se clicar no btVoltar
	$('#btVoltar','#divBotoes').unbind('click').bind('click', function() { 		
		if ( $('#divConsulta').css('display') == 'block' ) {         
            trocaBotao('Prosseguir');
            $("#divConsulta").css({'display':'none'});
            $('a', '#frmFiltros').css({'display':'block'});
            $('#cdempres').habilitaCampo();
		}else{
            estadoInicial();
        }		
		return false;

	});	
</script>