<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogério Giacomini (GATI)
 * DATA CRIAÇÃO : 13/09/2011
 * OBJETIVO     : Cabeçalho para a tela GARSEG
 * --------------
 * ALTERAÇÕES   :
 * 001: 18/01/2013 - Daniel (CECRED) : Implantacao novo layout.
 * --------------
 */ 
?>
<form id="frmGarseg" name="frmGarseg" class="formulario cabecalho" >	
	<label for="cdsegura"><? echo utf8ToHtml('Código Seguradora:');?></label>
	<input type="text" id="cdsegura" name="cdsegura" alt="Informe o c&oacute;digo da seguradora." />	
	<a href="#" style="margin-top:5px" class="lupa" onclick="buscarSeguradora();"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	
	<input name="nmsegura" id="nmsegura" type="text" alt=""/>
	<br>
	<label for="tpseguro">Tipo Seguro:</label>
<!--	<input name="tpseguro" id="tpseguro" type="text" alt="Tipo 3 - Vida, 4 - Prestamista, 11 - Casa."/> -->
	<select id="tpseguro" name="tpseguro" alt="<? echo utf8ToHtml('Clique no botão PROSSEGUIR ou  pressione ENTER para continuar.') ?>">
		<option value="3" <?php echo $tpseguro == '3' ? 'selected' : '' ?> > 3 - Vida </option> 
		<option value="4" <?php echo $tpseguro == '4' ? 'selected' : '' ?> > 4 - Prestamista </option>
		<option value="11" <?php echo $tpseguro == '11' ? 'selected' : '' ?> > 11 - Casa </option>
	</select>
	
	<label for="tpplaseg">Tipo Plano:</label>
	<input name="tpplaseg" id="tpplaseg" type="text" alt="Informe o n&uacute;mero do plano."/>
	
	<a href="#" class="botao" id="btBuscaGarantias" >OK</a>
	<br style="clear:both" />	
</form>