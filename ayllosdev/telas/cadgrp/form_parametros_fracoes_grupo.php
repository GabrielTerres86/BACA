<?php
/* 
 * FONTE        : from_parametros_fracoes_grupo.php
 * CRIAÇÃO      : Jonata - Mouts
 * DATA CRIAÇÃO : Setembro/2018
 * OBJETIVO     : Formulário de exibição de formulário da opção "P"
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
	<legend>Par&acirc;metros</legend>
		
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
	
</form>

<div id="divBotoesOpcaoP" style="margin-top:5px; margin-bottom :10px; text-align: center;">	
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1');return false;" >Voltar</a>		
	<a href="#" class="botao" id="btAlterar" onClick="controlaFormOpcaoP();return false;">Alterar</a>
	<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','alterarParametrosFracoesGrupo();','$(\'#btVoltar\',\'#divBotoesOpcaoP\').focus();','sim.gif','nao.gif');return false;">Concluir</a>
			
</div>


<script type="text/javascript">
	
	$('#divBotoesOpcaoP').css('display','block');
	formataFormOpcaoP();
	
</script>
