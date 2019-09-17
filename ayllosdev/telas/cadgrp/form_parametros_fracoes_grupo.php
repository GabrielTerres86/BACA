<?php
/* 
 * FONTE        : from_parametros_fracoes_grupo.php
 * CRIAÇÃO      : Jonata - Mouts
 * DATA CRIAÇÃO : Setembro/2018
 * OBJETIVO     : Formulário de exibição de formulário da opção "P"
 * ALTERACOES   : 05/07/2019 - Alterações referente à segunda fase do projeto P484.2 (Gabriel Marcos - Mouts).
 */
 
 
 session_start();
 require_once('../../includes/config.php');
 require_once('../../includes/funcoes.php');
 require_once('../../includes/controla_secao.php');		
 require_once('../../class/xmlfile.php');
 isPostMethod();	


?>

<form name="frmOpcaoP" id="frmOpcaoP" class="formulario" style="display:block;">	
    	
	<fieldset>
	<legend>Grupos</legend>
		
		<label for="frmideal"><?php echo utf8ToHtml("Fra&ccedil;&atilde;o Ideal:"); ?></label>
		<input type="text" id="frmideal" name="frmideal" value="<?php echo getByTagName($parametros->tags,'fraideal');?>" >

		<br />
		
		<label for="frmmaxim"><?php echo utf8ToHtml("Fra&ccedil;&atilde;o M&aacute;xima:"); ?></label>
		<input type="text" id="frmmaxim" name="frmmaxim" value="<?php echo getByTagName($parametros->tags,'frmaxima');?>" >
		
		<br style="clear:both" />
		
		<label for="intermin"><?php echo utf8ToHtml("Intervalo M&iacute;nimo:"); ?></label>
		<input type="text" id="intermin" name="intermin" value="<?php echo getByTagName($parametros->tags,'intermin');?>" >

		<br style="clear:both" />
		
	</fieldset>
	
	<fieldset>
	
	<legend>Notifica&#231;&#245;es</legend>
		
		<label for="antecedencia_envnot"><?php echo utf8ToHtml("Anteced&ecirc;ncia do envio (dias):"); ?></label>
		<input type="text" id="antecedencia_envnot" name="antecedencia_envnot" value="<?php echo getByTagName($parametros->tags,'antecedencia_envnot');?>" >

		<br />
		
		<div class="tooltip1">
			<label for="hrenvio_mensagem"><?php echo utf8ToHtml("Hor&aacute;rio para envio:"); ?></label>
			<input type="text" id="hrenvio_mensagem" name="hrenvio_mensagem" value="<?php echo getByTagName($parametros->tags,'hrenvio_mensagem');?>" >
			<label class="tooltiptext1"><?php echo utf8ToHtml("Ex: 20:00"); ?></label>
		</div>	
		
		<br style="clear:both" />
		
	</fieldset>
	
	<fieldset>
	
	<legend>Banners - Internet Banking</legend>
		
		<label for="dstitulo_banner"><?php echo utf8ToHtml("T&iacute;tulo do cadastro:"); ?></label>
		<input type="text" id="dstitulo_banner" name="dstitulo_banner" value="<?php echo getByTagName($parametros->tags,'dstitulo_banner');?>" >

		<br />
					
		<div class="tooltip1">
			<label for="dtexibir_de"><?php echo utf8ToHtml("In&iacute;cio de exibi&ccedil;&atilde;o:"); ?></label>
			<input type="text" id="dtexibir_de" name="dtexibir_de" value="<?php echo getByTagName($parametros->tags,'dtexibir_de');?>" >
			<label class="tooltiptext1"><?php echo utf8ToHtml("Caso a data seja nula, busca data de in&iacute;cio de travamento."); ?></label>
		</div>	

		<br style="clear:both" />
		
	</fieldset>

	<fieldset>
	
	<legend>Cargos - Aviso cooperativa</legend>

		<div class="tooltip1">
			<label for="flgemail"><?php echo utf8ToHtml("Status envio de e-mail:"); ?></label>
			<input name="flgemail" id="flgemail" type="checkbox" class="vnccheckbox" <?php if (getByTagName($parametros->tags,'flgemail') == 1 ) { ?> checked <?php } ?> />	
			<label class="tooltiptext1"><?php echo utf8ToHtml("Notificar cooperativa quando houver inativa&ccedil;&atilde;o autom&aacute;tica de cargo de delegado."); ?></label>
		</div>	
		
		<br />
		
		<label for="dstitulo_email"><?php echo utf8ToHtml("T&iacute;tulo do e-mail:"); ?></label>
		<input type="text" id="dstitulo_email" name="dstitulo_email" value="<?php echo getByTagName($parametros->tags,'dstitulo_email');?>" >

		<br style="clear:both" />
		
		<div class="tooltip3">
			<label for="conteudo_email"><?php echo utf8ToHtml("Conte&uacute;do do e-mail:"); ?></label>
			<textarea id="conteudo_email" name="conteudo_email" ><?php echo getByTagName($parametros->tags,'conteudo_email');?></textarea>
			<span class="tooltiptext3"><?php echo utf8ToHtml("Favor entrar em contato com a TI para alterar conte&uacute;do."); ?></span>
		</div>	

		<div class="tooltip3">
			<label for="lstemail"><? echo utf8ToHtml('Lista de e-mail:') ?></label>
			<textarea id="lstemail" name="lstemail"><?php echo getByTagName($parametros->tags,'lstemail');?></textarea>
			<span class="tooltiptext3"><?php echo utf8ToHtml("Ex: maria@ailos.coop.br,jose@ailos.coop.br,fernando@cecred.coop.br"); ?></span>
		</div>	

	</fieldset>

</form>

<div id="divBotoesOpcaoP" style="margin-top:5px; margin-bottom :10px; text-align: center;">	
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1');return false;" >Voltar</a>		
	<a href="#" class="botao" id="btAlterar" onClick="controlaFormOpcaoP();return false;">Alterar</a>
	<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','alterarParametrosFracoesGrupo();','$(\'#btVoltar\',\'#divBotoesOpcaoP\').focus();','sim.gif','nao.gif');return false;">Concluir</a>
			
</div>


<script type="text/javascript">
	
	$('#divBotoesOpcaoP').css('display','block');
	$('#hrenvio_mensagem').setMask('STRING', '99:99', ':', '');	
	formataFormOpcaoP();
	
</script>

<style>

	.tooltiptext1 {

		visibility: hidden;

		background-color: white   !important;
		color: #575d4e            !important;
		text-align: center;
		font-weight: normal       !important;
		border: 1px solid #575d4e !important;
		position: relative;
		left: 10px;
		padding: 0px 5px; 

	}

	.tooltip1:hover .tooltiptext1 {
		visibility: visible;
	}

	.tooltip3 {
		position: relative;
	}

	.tooltip3 .tooltiptext3 {

		visibility: hidden;

		background-color: white   !important;
		color: #575d4e            !important;
		text-align: center;
		
		border: 1px solid #575d4e !important;
		position: relative;
		left: 5px;
		top: -48px;
		padding: 5px 5px;
		
	}

	.tooltip3:hover .tooltiptext3 {
		visibility: visible;
	}

</style>
