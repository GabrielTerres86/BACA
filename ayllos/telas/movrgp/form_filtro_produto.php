<? 
/*!
 * FONTE        : form_filtro_produto.php.php						Última alteração:  
 * CRIAÇÃO      : Jonata - RKAM
 * DATA CRIAÇÃO : Maio/2017
 * OBJETIVO     : Apresenta o form com os filtros de produtos da tela MOVRGP
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

<form id="frmFiltroProduto" name="frmFiltroProduto" class="formulario" style="display:none;">

	<fieldset id="fsetFiltroProduto" name="fsetFiltroProduto" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Produto"; ?></legend>
		
		<label for="cdproduto"><? echo utf8ToHtml('Produto:') ?></label>
		<select id="cdproduto" name="cdproduto" ></select>					
				
		<br style="clear:both" />
		
	</fieldset>
	
</form>

<div id="divBotoesFiltroProduto" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
																			
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2'); return false;">Voltar</a>																																							
	<a href="#" class="botao" id="btProsseguir" onClick="controleOperacao(); return false;">Prosseguir</a>	
			
</div>


<script type="text/javascript">
	
	formataFiltroProduto();
	
	<?for ($i = 0; $i < count($produtos); $i++){
		
		$idproduto = getByTagName($produtos[$i]->tags,"IDPRODUTO");
		$dsproduto = getByTagName($produtos[$i]->tags,"DSPRODUTO");
		?>
		
		$('#cdproduto','#frmFiltroProduto').append('<option value="<?echo $idproduto;?>"><? echo $dsproduto;?></option>');

	<?}?>	
	
				
</script>



	
	
	
 