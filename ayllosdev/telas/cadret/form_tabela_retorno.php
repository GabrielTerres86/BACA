<? 
/*!
 * FONTE        : form_tabela_retorno.php
 * CRIA��O      : Jorge I. Hamaguchi
 * DATA CRIA��O : Setembro/2013 
 * OBJETIVO     : Tabela com os dados de Retorno (Tela CADRET)
 * --------------
 * ALTERA��ES   : 
 * --------------
 */	
 ?>
 <br/>
<form id="frmConsultaDados" class="frmConsultaDados" name="frmConsultaDados">
<div class="divRegistros" >
	<table>
		<thead>
		<tr>
			<th>C&oacute;digo</th>
			<th>Descri&ccedil;&atilde;o</th>
		</tr>			
		</thead>
		<tbody> 
			<?  if(count($cadret) > 0){
					foreach( $cadret as $dados) { ?>
					<tr> 
						<td><span><?php echo getByTagName($dados->tags,'CDRETORN'); ?></span>
								  <?php echo getByTagName($dados->tags,'CDRETORN'); ?>
						</td>
						<td><span><?php echo getByTagName($dados->tags,'DSRETORN'); ?></span>
								  <?php echo getByTagName($dados->tags,'DSRETORN'); ?>
						</td>				
					</tr>												
     	    <? 		}
				}else{ ?>
				<tr><td colspan="2">Nenhum cadastro de retorno encontrado</td></tr>
			<?	} ?> 
		</tbody>		
	</table>
</form>
