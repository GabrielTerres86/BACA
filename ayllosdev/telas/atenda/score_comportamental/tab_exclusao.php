
<?php 

	/****************************************************************
	 Fonte: tab_exclusao.php                                            
	 Autor: Thaise Medeiros - Envolti                                                  
	 Data : Outubro/2018                 Última Alteração: 
	                                                                 
	 Objetivo  : Mostrar a exclusão do Score Comportamental da tela ATENDA                                   
	                                                                 
	 Alter.:  
																   	 
	*****************************************************************/


	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
?>


<div id="divExclusao" class="divRegistros">
	<table class="">
		<thead>
			<tr>
				<th><? echo utf8ToHtml('Código'); ?></th>
				<th><? echo utf8ToHtml('Exclusão'); ?></th>
			</tr>
		</thead>
		<tbody><?
		if(count($exclusoes) == 0){
			?>
			<tr>
				<td colspan="11" style="width: 80px; text-align: center;">
					<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
					<b>N&atilde;o h&aacute; registros para exibir.</b>
				</td>
			</tr>
			<?
		} else{
			foreach($exclusoes as $exclusao){
				?>
				<tr id="<? echo getByTagName($exclusao->tags, 'cdexclusao'); ?>">
					<td>
						<span><? echo getByTagName($exclusao->tags,'cdexclusao'); ?></span>
						<? echo getByTagName($exclusao->tags,'cdexclusao'); ?>
					</td>
					<td id="dsmodelo">
						<span><? echo getByTagName($exclusao->tags,'dsexclusao'); ?></span>
						<? echo getByTagName($exclusao->tags,'dsexclusao'); ?>
					</td>
				</tr>
				<?
			}
		}
		?>
		</tbody>
	</table>
</div>

<div id="divBotoes" style="margin-top: 5px; margin-bottom: 10px; text-align: center;">
	<a href="#" class="botao" id="btVoltar" >Voltar</a>
</div>