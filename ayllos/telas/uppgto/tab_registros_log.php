<? 
/*!
 * FONTE        : tab_registros_log.php						Última alteração:  19/09/2017
 * CRIAÇÃO      : Tiago
 * DATA CRIAÇÃO : Setembro/2017
 * OBJETIVO     : Tabela que apresenta os detalhes
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

<form id="frmDetalhesLog" name="frmDetalhesLog" class="formulario" style="display:block;">

	<fieldset id="fsetRatings" name="fsetRatings" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Remessas"; ?></legend>
		
		<div class="divRegistros">
		
			<table>
				<thead>
					<tr>
						<th>Nome Arquivo</th>
						<th>Mensagem</th>
						<th>Data/Hora</th>						
						<th>Operador</th>
					</tr>
				</thead>
				<tbody>
				
					<? foreach( $registros as $result ) {    ?>
						<tr>	
							<td><span><? echo getByTagName($result->tags,'nmarquiv'); ?></span> <? echo getByTagName($result->tags,'nmarquiv'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'dsmsglog'); ?></span> <? echo getByTagName($result->tags,'dsmsglog'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'dhgerlog'); ?></span> <? echo getByTagName($result->tags,'dhgerlog'); ?> </td>							
							<td><span><? echo getByTagName($result->tags,'nmoperad'); ?></span> <? echo getByTagName($result->tags,'nmoperad'); ?> </td>
						</tr>	
					<? } ?>
				</tbody>	
			</table>
		</div>
	</fieldset>
	
</form>
