<?php  
	/*********************************************************************
	 Fonte: form_filtro.php                                                 
	 Autor: Jonata - Mouts
	 Data : Agosto/2018                 Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o de filtro para pesquisa da TAB085.                                  
	                                                                  
	 Alterações: 
	 
	 
	
	**********************************************************************/
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
		
?>


<form name="frmFiltro" id="frmFiltro" class="formulario" >
		
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Filtro</legend>

		<label for="cdcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
		<select id="cdcooper" name="cdcooper">
			<?php 
				if($glbvars["cdcooper"] == 3 && $cddopcao == 'H'){	?>
					<option value="0">Todas</option>
				<?php
				} else {
					echo ($glbvars["cdcooper"] == 3 && $cddopcao == 'A' ?  '<option value="0">Todas</option>' : '');
					foreach ($registros as $r) {
						if ( getByTagName($r->tags, 'cdcooper') <> '' ) {
							?>
								<option value="<?= getByTagName($r->tags, 'cdcooper'); ?>"><?= getByTagName($r->tags, 'nmrescop'); ?></option> 
								
							<?php
						}
					}
				}
			?>
		</select>

	</fieldset>

</form>	

<div id="divBotoesFiltro" style="margin-top:5px; margin-bottom :10px; text-align: center;">
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1');return false;" >Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onClick="consultaParametros();return false;">Prosseguir</a>	

</div>

<script type="text/javascript">

	formataFiltro();
	//Bruno  - prj 475 - passar cd cooper
	__CDCOOPER = '<?php echo $glbvars["cdcooper"] ?>';
	
</script>
	




