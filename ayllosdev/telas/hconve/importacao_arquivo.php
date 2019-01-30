<?php
/*!
 * FONTE        : importacao_arquivo.php
 * CRIAÇÃO      : Andrey Formigari - (Mouts)
 * DATA CRIAÇÃO : 21/10/2018 
 * OBJETIVO     : 
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

require_once("../../includes/carrega_permissoes.php");	
	
?>

<form id="frmOpcaoI" name="frmOpcaoI" class="formulario" enctype="multipart/form-data" target="blank" method="POST">
	<fieldset style="padding:0px; margin:0px; padding-bottom:10px;">
		<legend>Importar Arquivo</legend>
		
			<br />
			<table width="100%" >
				<tr>		
					<td>
						<div id="divuploadfile" style="height: 30px;" center>
							<input type="hidden" name="MAX_FILE_SIZE" value="8388608" />
 							<input name="userfile" id="userfile" size="106" type="file" class="campo" style="height: 25px;" alt="<? echo utf8ToHtml('Informe o caminho do arquivo.'); ?>" />
						</div>	
					</td>
				</tr>
			</table>
		 
	</fieldset>
</form>


<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; text-align: center;">

	<a href="#" class="botao" id="btVoltar"    		onclick="controlaVoltar('1');return false;">Voltar</a>

	<div class="tooltip">
		<a href="#" class="botao" id="btEnvImporArq"  	onclick="btnEnviarImportacaoArquivo(); return false;">Enviar</a>
	    <span class="tooltiptext"><?php echo utf8ToHtml("Convênios unificados geram arquivos apenas na central."); ?></span>
    </div>
	
</div>

<script type="text/javascript">
	formataformOpcaoI();
	
</script>

<style>
	input[name="userfile"] {
	  width: 404px;
	  height: 27px;
	}
</style>

<style type="text/css">
	.msg-guia{
		list-style: none;
		padding: 10px 0 0 15px;
		line-height: 20px;
	}
	.tooltip {
	  position: relative;
	  display: inline-block;
	  border-bottom: 1px dotted black;
	}
	.tooltip .tooltiptext {
	  visibility: hidden;
	  width: 120px;
	  background-color: black;
	  color: #fff;
	  text-align: center;
	  border-radius: 6px;
	  padding: 5px 0;
	  
	  /* Position the tooltip */
	  position: absolute;
	  z-index: 1;
	  top: 100%;
	  left: 50%;
	  margin-left: -60px;
	}
	.tooltip:hover .tooltiptext {
	  visibility: visible;
	}
</style>