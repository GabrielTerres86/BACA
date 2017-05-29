<? 
/*!
 * FONTE        : form_filtro_cooperativa.php.php						Última alteração:  
 * CRIAÇÃO      : Jonata - RKAM
 * DATA CRIAÇÃO : Maio/2017
 * OBJETIVO     : Apresenta o form com os filtros da tela MOVRGP
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
?>

<form id="frmFiltroCoop" name="frmFiltroCoop" class="formulario" style="display:none;">

	<fieldset id="fsetFiltroCoop" name="fsetFiltroCoop" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Filtros"; ?></legend>
		
		<label for="cdcopsel"><? echo utf8ToHtml('Cooperativa:') ?></label>
		<select id="cdcopsel" name="cdcopsel" ></select>		
		
		<label for="dtrefere"><? echo utf8ToHtml('Dt. Ref:') ?></label>
		<input type="text" id="dtrefere" name="dtrefere"/>		
				
		<br style="clear:both" />
		
	</fieldset>
	
</form>

<div id="divBotoesFiltroCoop" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
																			
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1'); return false;">Voltar</a>		

	<?if($cddopcao == 'F'){?>
	
		<a href="#" class="botao" id="btProsseguir" onClick="efetuarFechamentoDigitacao(); return false;">Prosseguir</a>	
	
	<?}else if($cddopcao == 'R'){ ?>
	
		<a href="#" class="botao" id="btProsseguir" onClick="efetuarReaberturaDigitacao(); return false;">Prosseguir</a>	
		
	<?}else{?>
	
		<a href="#" class="botao" id="btProsseguir" onClick="carregaBotaoProdutos(); return false;">Prosseguir</a>	
	
	<?}?>
	
</div>


<script type="text/javascript">
	
	formataFiltroCoop();
	
	<?for ($i = 0; $i < count($cooperativas); $i++){
		
		$cdcooper = getByTagName($cooperativas[$i]->tags,"CDCOOPER");
		$nmrescop = getByTagName($cooperativas[$i]->tags,"NMRESCOP");
		?>
		
		$('#cdcopsel','#frmFiltroCoop').append('<option value="<?echo $cdcooper;?>"><? echo $nmrescop;?></option>');

	<?}?>	
	
	$('#dtrefere','#frmFiltroCoop').val('<?echo $dtrefere;?>');
		
				
</script>



	
	
	
 