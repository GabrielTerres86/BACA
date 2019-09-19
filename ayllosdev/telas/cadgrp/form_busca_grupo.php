<?php
/* 
 * FONTE        : form_busca_grupo.php.php
 * CRIAÇÃO      : Jonata - Mouts
 * DATA CRIAÇÃO : Setembro/2018
 * OBJETIVO     : Form da opção "B"
 * ALTERACOES   : 05/07/2019 - Alterações referente à segunda fase do projeto P484.2 (Gabriel Marcos - Mouts).
 */
 
 
 session_start();
 require_once('../../includes/config.php');
 require_once('../../includes/funcoes.php');
 require_once('../../includes/controla_secao.php');		
 require_once('../../class/xmlfile.php');
 isPostMethod();	

 
?>
 
<form id="frmDetalhadaGrupo" name="frmDetalhadaGrupo" class="formulario">
	
	<input type="hidden" id="rowid" name="rowid" value="<? echo getByTagName($registros->tags,'rowid'); ?>" />							
							
	<fieldset id="fsetDetalhadaGrupo" name="fsetDetalhadaGrupo" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Grupo"; ?></legend>
		
		<label for="cdagenci"><?php echo utf8ToHtml("PA:"); ?></label>
		<input type="text" id="cdagenci" name="cdagenci" value="<?php echo getByTagName($registros->tags,'cdagenci');?>"/>
        
		<br />
		
		<label for="nrdgrupo"><?php echo utf8ToHtml("Grupo:"); ?></label>
		<input type="text" id="nrdgrupo" name="nrdgrupo" value="<?php echo getByTagName($registros->tags,'nrdgrupo');?>" >
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		
		<br />

		<label style="margin: 1px 0px 0 12px;" for="flgvinculo" >V&iacute;nculo grupo:</label>
		<input id="flgvinculo" type="checkbox" name="flgvinculo" <?php echo getByTagName($registros->tags,'flgvinculo') == 0 ? '' : 'checked'; ?> />

		<label for="dsfuncao"><?php echo utf8ToHtml("Cargo:"); ?></label>
		<input type="text" id="dsfuncao" name="dsfuncao" value="<?php echo getByTagName($registros->tags,'dsfuncao');?>" >
		
		<br />
		
		<label for="nrdconta"><?php echo utf8ToHtml("Conta:"); ?></label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?php echo getByTagName($registros->tags,'nrdconta');?>" >
		
		<br />
		
		<label for="nrcpfcgc"><?php echo utf8ToHtml("CPF/CNPJ:"); ?></label>
		<input type="text" id="nrcpfcgc" name="nrcpfcgc" value="<?php echo getByTagName($registros->tags,'nrcpfcgc');?>" >
		
		<br />
		
		<label for="nmprimtl"><?php echo utf8ToHtml("Nome Completo:"); ?></label>
		<input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo getByTagName($registros->tags,'nmprimtl');?>" >
		
		<br style="clear:both" />	
		
	</fieldset>
	
</form>

<div id="divBotoesBuscaGrupo" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:block;' >
																			
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('6'); return false;">Voltar</a>																																							
	<a href="#" class="botao" id="btAlterar" onClick="controlaBotao(); return false;">Alterar</a>
	<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','alterarGrupoCooperado();','$(\'#btVoltar\',\'#divBotoesBuscaGrupo\').focus();','sim.gif','nao.gif');return false;">Concluir</a>
		   																			
</div>


<script type="text/javascript">
	
	$('input, select','#frmFiltroBuscaGrupo').desabilitaCampo();
	$('#divBotoesFiltroBuscaGrupo').css('display', 'none');
	formataFormBuscaGrupo();	

</script>