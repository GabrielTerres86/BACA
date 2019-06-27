<?php
/* !
 * FONTE        : upload_cargas_sas.php
 * CRIAÇÃO      : Christian Grauppe - ENVOLTI
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : Rotina para buscar as cargas
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

	// Ler parametros passados via POST
	$operacao	= (isset($_POST["operacao"])) ? $_POST["operacao"] : '';

	if ($operacao == 'L') {
		$legend = "Importar carga via Arquivo";
		$opcaotela = "L";
	} else { // (E)
		$legend = "Importar arquivo de Exclusão";
		$opcaotela = "E";
	}

	if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $opcaotela, false )) <> '') {
		exibirErro('error', $msgError, 'Alerta - Ayllos', '');
	}
?>

<style type="text/css" media="all">
	.adisabled {
		pointer-events: none;
		cursor: default;
		opacity: 0.6;
	}
</style>

<div id="divArquivos" name="divArquivos">
	<form id="frmArquivo" name="frmArquivo" class="formulario" enctype="multipart/form-data" >
		<fieldset>
			<legend><?php echo utf8ToHtml($legend); ?></legend>
			<table width="100%" >
				<tr>
					<td>
						<div id="divuploadfile" style="height:30px;" center >
							<input type="hidden" name="MAX_FILE_SIZE" value="8388608" />
							<input name="userfile" id="userfile" size="115" type="file" class="campo" style="height:25px;" alt="<? echo utf8ToHtml('Informe o caminho do arquivo.'); ?>" />
						</div>	
					</td>
				</tr>
			</table>
		</fieldset>
		<br />
	</form>

	<div id="divBotoes" style='text-align:center; margin-bottom: 10px;' >
		<a href="#" class="botao" id="btVoltar" name="btVoltar" onClick="btnVoltar();return false;" style="float:none;">Voltar</a>
		<a href="#" class="botao" id="btEnviar" name="btEnviar" onClick="enviarCargas('<?php echo $operacao; ?>');return false;" style="float:none;">Enviar</a>
	</div>
</div>

<div id="divListMsg" > </div>
