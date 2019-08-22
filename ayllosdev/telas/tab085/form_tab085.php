<?php
/* 
 * FONTE        : form_tab085.php
 * CRIAÇÃO      : Jonata - Mouts
 * DATA CRIAÇÃO : Agosto/2018
 * OBJETIVO     : Formulário de exsdfibição da tela TAB085
 */
 
 
 session_start();
 require_once('../../includes/config.php');
 require_once('../../includes/funcoes.php');
 require_once('../../includes/controla_secao.php');		
 require_once('../../class/xmlfile.php');
 isPostMethod();	

 
?>

<form name="frmTab085" id="frmTab085" class="formulario" style="display:block;">	
    	
	<fieldset id="spb_str">
	<legend>Par&acirc;metros SPB-STR</legend>
		<label for="flgopstr"><?php echo utf8ToHtml("Operando com SPB-STR:"); ?></label>
		<select  id="flgopstr" name="flgopstr" value="<?php echo getByTagName($parametros->tags,'flgopstr'); ?>">
			<option value="0" <?php if (getByTagName($parametros->tags,'flgopstr') == "0") { ?> selected <?php } ?> >N&atilde;o</option>
			<option value="1" <?php if (getByTagName($parametros->tags,'flgopstr') == "1") { ?> selected <?php } ?> >Sim</option>
		</select>

		</br >
		
		<label for="iniopstr"><?php echo utf8ToHtml("Hor&aacute;rio para SPB-STR:"); ?></label>
		<input type="text" id="iniopstr" name="iniopstr" value="<?php echo getByTagName($parametros->tags,'iniopstr');?>" >

		<label for="fimopstr"><?php echo utf8ToHtml("at&eacute;:"); ?></label>
		<input type="text" id="fimopstr" name="fimopstr" value="<?php echo getByTagName($parametros->tags,'fimopstr');?>" >

		<br style="clear:both" />
		
	</fieldset>
	
	<fieldset id="spb_pag">
	<legend>Par&acirc;metros SPB-PAG</legend>
		<label for="flgoppag" >Operando com SPB-PAG:</label>
		<select  id="flgoppag" name="flgoppag" value="<?php echo getByTagName($parametros->tags,'flgoppag'); ?>">
			<option value="0" <?php if (getByTagName($parametros->tags,'flgoppag') == "0") { ?> selected <?php } ?> >N&atilde;o</option>
			<option value="1" <?php if (getByTagName($parametros->tags,'flgoppag') == "1") { ?> selected <?php } ?> >Sim</option>
		</select>
		
		</br >
		
		<label for="inioppag"><?php echo utf8ToHtml("Hor&aacute;rio para SPB-PAG:"); ?></label>
		<input type="text" id="inioppag" name="inioppag" value="<?php echo getByTagName($parametros->tags,'inioppag');?>" >

		<label for="fimoppag"><?php echo utf8ToHtml("at&eacute;:"); ?></label>
		<input type="text" id="fimoppag" name="fimoppag" value="<?php echo getByTagName($parametros->tags,'fimoppag');?>" >

		</br >
		
		<label for="vlmaxpag"><?php echo utf8ToHtml("Valor m&aacute;ximo:"); ?></label>
		<input type="text" id="vlmaxpag" name="vlmaxpag" value="<?php echo getByTagName($parametros->tags,'vlmaxpag');?>" >
		
		<br style="clear:both" />
		
	</fieldset>

	<fieldset id="vr_boleto">
	<legend>Par&acirc;metros VR-BOLETO</legend>
		<label for="flgopbol"><?php echo utf8ToHtml("Pagamento VR-Boleto:"); ?></label>
		<select  id="flgopbol" name="flgopbol" value="<?php echo getByTagName($parametros->tags,'flgopbol'); ?>">
			<option value="0" <?php if (getByTagName($parametros->tags,'flgopbol') == "0") { ?> selected <?php } ?> >N&atilde;o</option>
			<option value="1" <?php if (getByTagName($parametros->tags,'flgopbol') == "1") { ?> selected <?php } ?> >Sim</option>
		</select>
		
		</br>
		
		<label for="iniopbol"><?php echo utf8ToHtml("Hor&aacute;rio VR-Boleto:"); ?></label>
		<input type="text" id="iniopbol" name="iniopbol" value="<?php echo getByTagName($parametros->tags,'iniopbol');?>" >

		<label for="fimopbol"><?php echo utf8ToHtml("at&eacute;:"); ?></label>
		<input type="text" id="fimopbol" name="fimopbol" value="<?php echo getByTagName($parametros->tags,'fimopbol');?>" >

		<br style="clear:both" />
		
	</fieldset>  

	<fieldset id="estado_crise">
	<legend>Par&acirc;metros Estado de Crise</legend>
		
		<label for="flgcrise"><?php echo utf8ToHtml("Sistema em estado de crise:"); ?></label>
		<select  id="flgcrise" name="flgcrise" value="<?php echo getByTagName($parametros->tags,'flgcrise'); ?>">
			<option value="0" <?php if (getByTagName($parametros->tags,'flgcrise') == "0") { ?> selected <?php } ?> >N&atilde;o</option>
			<option value="1" <?php if (getByTagName($parametros->tags,'flgcrise') == "1") { ?> selected <?php } ?> >Sim</option>
		</select>
		
		<br style="clear:both" />
		
	</fieldset>  	

	<fieldset id="trans_agendada">
	<legend>Par&acirc;metros SPB - Transa&ccedil;&otilde;es Agendadas</legend>
		
		<label for="hrtrpen1"><?php echo utf8ToHtml("Execu&ccedil;&atilde;o 1:"); ?></label>
		<input type="text" id="hrtrpen1" name="hrtrpen1" value="<?php echo getByTagName($parametros->tags,'hrtrpen1');?>" >

		<label for="hrtrpen2"><?php echo utf8ToHtml("Execu&ccedil;&atilde;o 2:"); ?></label>
		<input type="text" id="hrtrpen2" name="hrtrpen2" value="<?php echo getByTagName($parametros->tags,'hrtrpen2');?>" >

		<label for="hrtrpen3"><?php echo utf8ToHtml("Execu&ccedil;&atilde;o 3:"); ?></label>
		<input type="text" id="hrtrpen3" name="hrtrpen3" value="<?php echo getByTagName($parametros->tags,'hrtrpen3');?>" >

		<br style="clear:both" />
		
	</fieldset>   	
				
	
</form>

<div id="divBotoesTab085" style="margin-top:5px; margin-bottom :10px; text-align: center;">	
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2');return false;" >Voltar</a>
	<?
		if ($cddopcao == 'A' || $cddopcao == 'H'){?>		
			<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','alterarParametros();','$(\'#btVoltar\',\'#divBotoesTab085\').focus();','sim.gif','nao.gif');return false;">Concluir</a>
	<? } ?>
</div>


<script type="text/javascript">

	
	$('#divBotoesFiltro').css('display','none');
	$('#divTab085').css('display','block');
	formataFormularioTab085();
	
</script>
