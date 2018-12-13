<?php
/* 
 * FONTE        : form_periodo_edital_assembleias.php.php
 * CRIAÇÃO      : Jonata - Mouts
 * DATA CRIAÇÃO : Setembro/2018
 * OBJETIVO     : Formulário de exibição de formulário da opção "E"
 */
 
 
 
 require_once('../../includes/config.php');
 require_once('../../includes/funcoes.php');
 require_once('../../includes/controla_secao.php');		
 require_once('../../class/xmlfile.php');
 isPostMethod();	

 
?>
 
<form name="frmOpcaoE" id="frmOpcaoE" class="formulario" style="display:block;">	
    	
	<input type="hidden" id="rowid" name="rowid" value="<? echo $rowid; ?>" />
		
	<fieldset>
	<legend>Exerc&iacute;cio</legend>
		
		<label for="nrano_exercicio"><?php echo utf8ToHtml("Exerc&iacute;cio:"); ?></label>
		<input type="text" id="nrano_exercicio" name="nrano_exercicio" value="<?php echo $nrano_exercicio;?>" >

		<br style="clear:both" />
		
	</fieldset>
	
	<fieldset>
	<legend>Travamento de grupos</legend>
		
		<label for="dtinicio_grupo"><?php echo utf8ToHtml("Inicio:"); ?></label>
		<input type="text" id="dtinicio_grupo" name="dtinicio_grupo" value="<?php echo $dtinicio_grupo ;?>" >
	
		<br />
		
		<label for="dtfim_grupo"><?php echo utf8ToHtml("Fim:"); ?></label>
		<input type="text" id="dtfim_grupo" name="dtfim_grupo" value="<?php echo $dtfim_grupo;?>" >
	
	</fieldset>
	
</form>

<div id="divBotoesOpcaoE" style="margin-top:5px; margin-bottom :10px; text-align: center;">	
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2');return false;" >Voltar</a>	
	
	<?
		if ($ope == 'I'){?>		
			<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','incluirPeriodoEditalAssembleias();','$(\'#btVoltar\',\'#divBotoesOpcaoE\').focus();','sim.gif','nao.gif');return false;">Concluir</a>
	<? }else{?>
			<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','alterarPeriodoEditalAssembleias();','$(\'#btVoltar\',\'#divBotoesOpcaoE\').focus();','sim.gif','nao.gif');return false;">Concluir</a>
	<? }?>
	   																			
</div>


<script type="text/javascript">
	
	$('#divCadgrp').css('display','none');
	$('#divBotoesOpcaoE').css('display','block');
	$('#divForms').css('display','block');
	formataFormOpcaoE('<?echo $ope; ?>');
				
</script>