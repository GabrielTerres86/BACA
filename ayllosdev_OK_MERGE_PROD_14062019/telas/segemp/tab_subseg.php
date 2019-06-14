<? 
/*!
 * FONTE        : tab_subseg.php
 * CRIAÇÃO      : Douglas Pagel (AMcom)
 * DATA CRIAÇÃO : 11/02/2019 
 * OBJETIVO     : Tabela que apresenta os subsegmentos
 * --------------
 * ALTERACOES   : 
 * --------------
 */ 

session_start();

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');	
require_once('../../class/xmlfile.php');

isPostMethod();	


?>
<div class="divRegistros" id="divSubsegmentos">		
		<table class="tituloRegistros" id="tableSubsegmento" name="tableSubsegmento">
			<thead>
				<tr>
					<th><?php echo utf8ToHtml('Código'); ?></th>
					<th><?php echo utf8ToHtml('Descrição'); ?></th>
					<th><?php echo utf8ToHtml('Linha de Crédito'); ?></th>
				</tr>
				</tr>
			</thead>
			<tbody>		
				<?php
					if(count($subseg) > 0){
						foreach($subseg as $subsegmento){
				?>
							<tr>
								<td><?php echo getByTagName($subsegmento->tags, 'codigo_subsegmento'); ?></td>
								<td><?php echo getByTagName($subsegmento->tags, 'nome_subsegmento'); ?></td>
								<td><?php echo getByTagName($subsegmento->tags, 'descricao_linha_credito'); ?></td>
								<input type="hidden" id="cdsubsegmento" value="<?php echo getByTagName($subsegmento->tags, 'codigo_subsegmento'); ?>"/>
								<input type="hidden" id="cdsegmento" value="<?php echo getByTagName($linha->tags,'codigo_segmento'); ?>"/>
							</tr>                                             
				<?php
						}
					}else{
				?>
						<tr>
							<td colspan="2">
								<b>N&atilde;o h&aacute; registros de subsegmentos cadastrados</b>
							</td>
							</td>
						</tr>
				<?php
					}
				?>
			</tbody>
		</table>
	</div>
<script type="text/javascript">

	  formataTabelaSubsegmento();

</script>